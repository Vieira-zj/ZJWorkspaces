# coding: utf-8
import os, sys
import logging
import json

from flask import send_from_directory

project_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_path)
from models import Users
from utils import common, httputils

logger = logging.getLogger(__name__)


class UserService(object):
    count = 0

    def __init__(self, app):
        self._app = app
        self._users = Users()

    def ping(self):
        self.count += 1

        ret = {}
        ret["count"] = self.count
        ret["status"] = "ok"
        return json.dumps(ret)

    def login(self, request):
        req = httputils.get_request_data(request)
        if request.method == "OPTIONS":
            return httputils.create_response_allow()

        resp = httputils.create_response_allow()
        user = json.loads(req)
        db_user = self._users.selectOneUserByName(
            user["name"], is_include_password=True
        )
        if self._isAuth(user, db_user):
            resp = httputils.build_ok_json_response(
                resp, {"key": "issuperuser", "value": db_user["issuperuser"]}
            )
            # issue: https://support.google.com/chrome/thread/34237768?hl=en
            # https://dormousehole.readthedocs.io/en/latest/api.html#response-objects
            resp.set_cookie(
                "user-token",
                common.string_encode("|".join(list(user.values()))),
                samesite=None,
            )
        else:
            resp = httputils.build_forbidden_json_response(resp)
        return resp

    def getUser(self, request):
        req_str = httputils.get_request_data(request)
        if request.method == "OPTIONS":
            return httputils.create_response_allow()

        req = json.loads(req_str)
        resp = httputils.create_response_allow()
        token = request.headers.get("Authorization", "")
        if not self._isTokenValid(token):
            return httputils.build_forbidden_json_response(resp)

        user = self._users.selectOneUserByName(req["name"])
        httputils.build_ok_json_response(resp, {"key": "user", "value": user})
        return resp

    def getUsers(self, request):
        req_str = httputils.get_request_data(request)
        if request.method == "OPTIONS":
            return httputils.create_response_allow()

        req = json.loads(req_str)
        resp = httputils.create_response_allow()
        token = request.headers.get("Authorization", "")
        if not self._isTokenValid(token):
            return httputils.build_forbidden_json_response(resp)

        row_count, users = self._users.selectMultipleUsers(
            int(req["start"]), int(req["offset"])
        )
        resp = httputils.build_ok_json_response(
            resp,
            {"key": "count", "value": str(row_count)},
            {"key": "users", "value": users},
        )
        return resp

    def newUser(self, request):
        req_str = httputils.get_request_data(request)
        if request.method == "OPTIONS":
            return httputils.create_response_allow()

        resp = httputils.create_response_allow()
        user = json.loads(req_str)
        try:
            self._users.insertANewUser(user)
        except Exception as err:
            ret_json = {}
            ret_json["code"] = "499"
            ret_json["status"] = "failed"
            ret_json["msg"] = str(err)
            return httputils.build_json_response(resp, 400, ret_json)

        resp = httputils.build_ok_json_response(resp)
        return resp

    def editUser(self, request):
        req_str = httputils.get_request_data(request)
        if request.method == "OPTIONS":
            return httputils.create_response_allow()

        resp = httputils.create_response_allow()
        token = request.headers.get("Authorization", "")
        if not self._isTokenValid(token):
            return httputils.build_forbidden_json_response(resp)

        req = json.loads(req_str)
        try:
            self._users.updateUserByName(req["name"], req["data"])
        except Exception as err:
            ret_json = {}
            ret_json["code"] = "499"
            ret_json["status"] = "failed"
            ret_json["msg"] = str(err)
            return httputils.build_json_response(resp, 400, ret_json)

        resp = httputils.build_ok_json_response(resp)
        return resp

    def isSuperUser(self, request):
        httputils.get_request_data(request)
        if request.method == "OPTIONS":
            return httputils.create_response_allow()

        resp = httputils.create_response_allow()
        token = request.headers.get("Authorization", "")
        if not self._isTokenValid(token):
            return httputils.build_forbidden_json_response(resp)

        user_name = self._getUsernameFromToken(token)
        user = self._users.selectOneUserByName(user_name)
        resp = httputils.build_ok_json_response(
            resp, {"key": "issuperuser", "value": user["issuperuser"]}
        )
        return resp

    def uploadPic(self, request):
        httputils.get_request_data(request, is_file=True)
        if request.method == "OPTIONS":
            return httputils.create_response_allow()

        resp = httputils.create_response_allow()
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

        # save upload file
        file_name = (
            common.create_random_str(12)
            + "."
            + common.get_file_type(upload_file.filename)
        )
        upload_file.save(os.path.join(self._app.config["upload_dir"], file_name))
        # save file meta info to db
        user_name = request.headers.get("Specified-User")
        try:
            self._users.updateUserByName(user_name, {"picture": file_name})
        except Exception as err:
            ret_json = {}
            ret_json["code"] = "499"
            ret_json["status"] = "failed"
            ret_json["msg"] = str(err)
            return httputils.build_json_response(resp, 400, ret_json)

        resp = httputils.build_ok_json_response(
            resp,
            {"key": "msg", "value": "upload file success"},
            {"key": "filename", "value": file_name},
        )
        return resp

    def downloadPic(self, request, filename):
        httputils.get_request_data(request)
        if request.method == "OPTIONS":
            return httputils.create_response_allow()

        # no auth token check
        resp = send_from_directory(
            self._app.config["upload_dir"], filename, as_attachment=True
        )
        resp = httputils.create_response_allow(resp)
        return resp

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
