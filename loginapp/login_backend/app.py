import json
import logging
import os

from flask import Flask, request
from flask import send_from_directory

from data import (
    select_user_by_name,
    select_many_users,
    insert_new_user,
    update_user_by_name,
    db_clearup,
)
from service import (
    is_auth,
    is_token_valid,
    get_username_from_token,
    get_request_data,
    create_response_allow,
    build_json_response,
    build_ok_json_response,
    build_forbidden_json_response,
)
from utils import (
    string_encode,
    string_decode,
    get_file_type,
    is_valid_file_type,
    create_random_str,
)

logger = logging.getLogger(__name__)

count = 0
app = Flask(__name__)
app.config["upload_dir"] = os.path.join(os.getcwd(), "upload_files")


@app.route("/")
def health():
    global count
    count += 1

    ret = {}
    ret["count"] = count
    ret["status"] = "ok"
    return json.dumps(ret)


@app.route("/login", methods=["POST", "OPTIONS"])
def login():
    req = get_request_data(request)
    if request.method == "OPTIONS":
        return create_response_allow()

    resp = create_response_allow()
    user = json.loads(req)
    db_user = select_user_by_name(user["name"], is_include_password=True)
    if is_auth(user, db_user):
        resp = build_ok_json_response(
            resp, {"key": "issuperuser", "value": db_user["issuperuser"]}
        )
        # issue: https://support.google.com/chrome/thread/34237768?hl=en
        # https://dormousehole.readthedocs.io/en/latest/api.html#response-objects
        resp.set_cookie(
            "user-token", string_encode("|".join(list(user.values()))), samesite=None
        )
    else:
        resp = build_forbidden_json_response(resp)
    return resp


@app.route("/getuser", methods=["POST", "OPTIONS"])
def get_user():
    req_str = get_request_data(request)
    if request.method == "OPTIONS":
        return create_response_allow()

    req = json.loads(req_str)
    resp = create_response_allow()
    token = request.headers.get("Authorization", "")
    if not is_token_valid(token):
        return build_forbidden_json_response(resp)

    user = select_user_by_name(req["name"])
    build_ok_json_response(resp, {"key": "user", "value": user})
    return resp


@app.route("/getusers", methods=["POST", "OPTIONS"])
def get_users():
    req_str = get_request_data(request)
    if request.method == "OPTIONS":
        return create_response_allow()

    req = json.loads(req_str)
    resp = create_response_allow()
    token = request.headers.get("Authorization", "")
    if not is_token_valid(token):
        return build_forbidden_json_response(resp)

    row_count, users = select_many_users(int(req["start"]), int(req["offset"]))
    resp = build_ok_json_response(
        resp,
        {"key": "count", "value": str(row_count)},
        {"key": "users", "value": users},
    )
    return resp


@app.route("/newuser", methods=["POST", "OPTIONS"])
def new_user():
    req_str = get_request_data(request)
    if request.method == "OPTIONS":
        return create_response_allow()

    resp = create_response_allow()
    user = json.loads(req_str)
    try:
        insert_new_user(user)
    except Exception as err:
        ret_json = {}
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = str(err)
        return build_json_response(resp, 400, ret_json)

    resp = build_ok_json_response(resp)
    return resp


@app.route("/edituser", methods=["POST", "OPTIONS"])
def edit_user():
    req_str = get_request_data(request)
    if request.method == "OPTIONS":
        return create_response_allow()

    resp = create_response_allow()
    token = request.headers.get("Authorization", "")
    if not is_token_valid(token):
        return build_forbidden_json_response(resp)

    req = json.loads(req_str)
    try:
        update_user_by_name(req["name"], req["data"])
    except Exception as err:
        ret_json = {}
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = str(err)
        return build_json_response(resp, 400, ret_json)

    resp = build_ok_json_response(resp)
    return resp


@app.route("/issuperuser", methods=["GET", "OPTIONS"])
def is_super_user():
    get_request_data(request)
    if request.method == "OPTIONS":
        return create_response_allow()

    resp = create_response_allow()
    token = request.headers.get("Authorization", "")
    if not is_token_valid(token):
        return build_forbidden_json_response(resp)

    user_name = get_username_from_token(token)
    user = select_user_by_name(user_name)
    resp = build_ok_json_response(
        resp, {"key": "issuperuser", "value": user["issuperuser"]}
    )
    return resp


@app.route("/uploadpic", methods=["POST", "OPTIONS"])
def upload_pic():
    get_request_data(request, is_file=True)
    if request.method == "OPTIONS":
        return create_response_allow()

    resp = create_response_allow()
    token = request.headers.get("Authorization", "")
    if not is_token_valid(token):
        return build_forbidden_json_response(resp)

    if "file" not in request.files:
        ret_json = {}
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = "no file part included!"
        return build_json_response(resp, 400, ret_json)

    upload_file = request.files["file"]
    if upload_file is None or upload_file.filename == "":
        ret_json = {}
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = "no file selected!"
        return build_json_response(resp, 400, ret_json)

    if not is_valid_file_type(upload_file.filename):
        ret_json = {}
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = "upload file type not supported!"
        return build_json_response(resp, 400, ret_json)

    # save upload file
    file_name = create_random_str(12) + "." + get_file_type(upload_file.filename)
    upload_file.save(os.path.join(app.config["upload_dir"], file_name))
    # save file meta info to db
    user_name = request.headers.get("Specified-User")
    try:
        update_user_by_name(user_name, {"picture": file_name})
    except Exception as err:
        ret_json = {}
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = str(err)
        return build_json_response(resp, 400, ret_json)

    resp = build_ok_json_response(
        resp,
        {"key": "msg", "value": "upload file success"},
        {"key": "filename", "value": file_name},
    )
    return resp


@app.route("/downloadpic/<filename>", methods=["GET", "OPTIONS"])
def download_pic(filename):
    get_request_data(request)
    if request.method == "OPTIONS":
        return create_response_allow()

    # no auth token check
    resp = send_from_directory(app.config["upload_dir"], filename, as_attachment=True)
    resp = create_response_allow(resp)
    return resp


if __name__ == "__main__":
    host = "0.0.0.0"
    port = 12340
    is_product = True if os.getenv("FLASK_ENV") == "prod" else False
    is_debug = True if os.getenv("IS_DEBUG") and os.getenv("IS_DEBUG") == "y" else False

    try:
        if is_product:
            from wsgiref.simple_server import make_server

            server = make_server(host, port, app)
            server.serve_forever()
            app.run()
        else:
            app.run(host=host, debug=is_debug, port=port)
    finally:
        db_clearup()
