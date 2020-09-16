# coding: utf-8
import os, sys
import logging
import json

from flask import send_from_directory

project_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
try:
    sys.path.index(project_path)
except ValueError:
    sys.path.append(project_path)

from utils import DBUtils

from models import Users
from utils import common, httputils

logger = logging.getLogger(__name__)


def preHandler(func):
    def _deco(*args, **kwargs):
        """
        args[0]: self
        args[1]: request
        """
        request = args[1]
        httputils.log_request_data(request)
        if request.method == "OPTIONS":
            return httputils.create_option_response_allow()
        return func(*args, **kwargs)

    return _deco


class UserService(object):
    count = 0

    def __init__(self, app):
        self._app = app
        self._users = Users()

    @preHandler
    def ping(self, request):
        # if use get_json(), must set request header: "Content-Type: application/json"
        logger.debug("receive json:" + str(request.get_json()))
        self.count += 1
        resp = httputils.create_response_allow()
        httputils.build_ok_json_response(resp, count=str(self.count))
        return resp

    @preHandler
    def login(self, request):
        resp = httputils.create_response_allow()
        user = request.get_json()
        db_user = self._users.selectOneUserByName(
            user["name"], is_include_password=True
        )

        if self._isAuth(user, db_user):
            user_data = {"name": db_user["name"], "issuperuser": db_user["issuperuser"]}
            resp = httputils.build_ok_json_response(resp, user=user_data)
            # issue: https://support.google.com/chrome/thread/34237768?hl=en
            # https://dormousehole.readthedocs.io/en/latest/api.html#response-objects
            resp.set_cookie(
                "User-Token",
                common.string_encode("|".join(list(user.values()))),
                samesite=None,
            )
        else:
            resp = httputils.build_forbidden_json_response(resp)
        return resp

    @preHandler
    def getUser(self, request):
        req_obj = request.get_json()
        resp = httputils.create_response_allow()
        token = request.headers.get("Authorization", "")
        if not self._isTokenValid(token):
            return httputils.build_forbidden_json_response(resp)

        try:
            user = self._users.selectOneUserByName(req_obj["name"])
            httputils.build_ok_json_response(resp, user=user)
            return resp
        except Exception as e:
            return self._dbErrorHandler(resp, e)

    @preHandler
    def getUsers(self, request):
        req_obj = request.get_json()
        resp = httputils.create_response_allow()
        token = request.headers.get("Authorization", "")
        if not self._isTokenValid(token):
            return httputils.build_forbidden_json_response(resp)

        row_count, users = self._users.selectMultipleUsers(
            int(req_obj["start"]), int(req_obj["offset"])
        )
        resp = httputils.build_ok_json_response(resp, count=str(row_count), users=users)
        return resp

    @preHandler
    def newUser(self, request):
        resp = httputils.create_response_allow()
        user = request.get_json()
        try:
            self._users.insertANewUser(user)
            user_data = self._users.selectOneUserByName(user["name"])
            resp = httputils.build_ok_json_response(resp, user=user_data)
            return resp
        except Exception as e:
            return self._dbErrorHandler(resp, e)

    @preHandler
    def editUser(self, request):
        resp = httputils.create_response_allow()
        token = request.headers.get("Authorization", "")
        if not self._isTokenValid(token):
            return httputils.build_forbidden_json_response(resp)

        req_obj = request.get_json()
        try:
            self._users.updateUserByName(req_obj["name"], req_obj["data"])
            user_data = self._users.selectOneUserByName(req_obj["name"])
            resp = httputils.build_ok_json_response(resp, user=user_data)
            return resp
        except Exception as e:
            return self._dbErrorHandler(resp, e)

    @preHandler
    def isSuperUser(self, request):
        resp = httputils.create_response_allow()
        token = request.headers.get("Authorization", "")
        if not self._isTokenValid(token):
            return httputils.build_forbidden_json_response(resp)

        user_name = self._getUsernameFromToken(token)
        user = self._users.selectOneUserByName(user_name)
        user_data = {"name": user["name"], "issuperuser": user["issuperuser"]}
        resp = httputils.build_ok_json_response(resp, user=user_data)
        return resp

    @preHandler
    def uploadPic(self, request):
        resp = httputils.create_response_allow()
        if request.args.get("isauth", "n") == "y":
            token = request.headers.get("Authorization", "")
            if not self._isTokenValid(token):
                return httputils.build_forbidden_json_response(resp)

        if "file" not in request.files:
            ret_json = {}
            ret_json["code"] = "499"
            ret_json["status"] = "failed"
            ret_json["msg"] = "no file part included!"
            return httputils.build_json_response(resp, 400, ret_json)

        upload_file = request.files["file"]
        if upload_file is None or upload_file.filename == "":
            ret_json = {}
            ret_json["code"] = "499"
            ret_json["status"] = "failed"
            ret_json["msg"] = "no file selected!"
            return httputils.build_json_response(resp, 400, ret_json)

        if not common.is_valid_file_type(upload_file.filename):
            ret_json = {}
            ret_json["code"] = "499"
            ret_json["status"] = "failed"
            ret_json["msg"] = "upload file type not supported!"
            return httputils.build_json_response(resp, 400, ret_json)

        user_name = request.headers.get("Specified-User")
        if user_name is None or len(user_name) == 0:
            ret_json = {}
            ret_json["code"] = "499"
            ret_json["status"] = "failed"
            ret_json["msg"] = "specified user name is empty!"
            return httputils.build_json_response(resp, 400, ret_json)

        # save upload file
        file_name = (
            common.create_random_str(12)
            + "."
            + common.get_file_type(upload_file.filename)
        )
        upload_file.save(os.path.join(self._app.config["upload_dir"], file_name))

        # save file meta info to db
        try:
            self._users.updateUserByName(user_name, {"picture": file_name})
        except Exception as e:
            return self._dbErrorHandler(resp, e)
        resp = httputils.build_ok_json_response(
            resp, message="upload file success", filename=file_name
        )
        return resp

    @preHandler
    def downloadPic(self, request, filename):
        file_path = os.path.join(self._app.config["upload_dir"], filename)
        if not os.path.exists(file_path):
            resp = httputils.create_response_allow()
            ret_json = {}
            ret_json["code"] = "499"
            ret_json["status"] = "failed"
            ret_json["msg"] = f"download file [{filename}] not exist"
            return httputils.build_json_response(resp, 400, ret_json)

        # no auth token check
        resp = send_from_directory(
            self._app.config["upload_dir"], filename, as_attachment=True
        )
        resp = httputils.create_response_allow(resp)
        return resp

    def _dbErrorHandler(self, resp, err):
        ret_json = {}
        ret_json["code"] = "599"
        ret_json["status"] = "failed"
        ret_json["msg"] = str(err)
        return httputils.build_json_response(resp, 500, ret_json)

    def _isAuth(self, user, db_user):
        if db_user is None:
            return False
        return True if user["password"] == db_user.get("password", "") else False

    def _isTokenValid(self, token: str) -> bool:
        if token is None or len(token) == 0:
            return False

        try:
            text = common.string_decode(token)
        except:
            return False
        return text.find("|") > -1 and len(text.split("|")) == 2

    def _getUsernameFromToken(self, token: str) -> str:
        text = common.string_decode(token)
        return text.split("|")[0]


if __name__ == "__main__":
    try:
        print(os.getcwd())
        raise ValueError("mock error")
    except:
        print("catch error")
