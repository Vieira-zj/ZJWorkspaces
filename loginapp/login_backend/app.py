import json
from flask import Flask, request
from flask import make_response

from data import select_user_by_name, select_all_users, update_user_by_name, db_clearup
from service import is_auth
from utils import string_encode, string_decode, is_token_valid, create_response_allow

count = 0
app = Flask(__name__)


@app.route("/")
def health():
    ret = {}
    global count
    count += 1
    ret["count"] = count
    ret["status"] = "ok"
    return json.dumps(ret)


@app.route("/login", methods=["POST", "OPTIONS"])
def login():
    if request.method == "OPTIONS":
        return create_response_allow()

    ret_json = {}
    resp = create_response_allow()

    print(request.path)
    print(request.headers)
    user = json.loads(request.stream.read())
    print(user)
    if is_auth(user["name"], user["password"]):
        ret_json["code"] = "0"
        ret_json["status"] = "ok"
        ret_json["msg"] = ""
        resp.status_code = 200
        resp.set_cookie("user-token", string_encode("|".join(list(user.values()))))
    else:
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = "auth forbidden"
        resp.status_code = 403

    resp.headers["Content-Type"] = "application/json; charset=utf-8"
    resp.set_data(json.dumps(ret_json))
    return resp


@app.route("/getuser", methods=["POST", "OPTIONS"])
def get_user():
    if request.method == "OPTIONS":
        return create_response_allow()

    ret_json = {}
    resp = create_response_allow()

    token = request.cookies.get("user-token")
    if is_token_valid(token):
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = "auth forbidden"
        resp.set_data(json.dumps(ret_json))
        resp.status_code = 403
        return resp

    req = json.loads(request.stream.read())
    user = select_user_by_name(req["name"])
    ret_json["code"] = "0"
    ret_json["status"] = "ok"
    ret_json["msg"] = ""
    ret_json["user"] = user

    resp.status_code = 200
    resp.headers["Content-Type"] = "application/json; charset=utf-8"
    resp.set_data(json.dumps(ret_json))
    return resp


@app.route("/getusers", methods=["GET", "OPTIONS"])
def get_users():
    if request.method == "OPTIONS":
        return create_response_allow()

    ret_json = {}
    resp = create_response_allow()

    token = request.cookies.get("user-token")
    if is_token_valid(token):
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = "auth forbidden"
        resp.set_data(json.dumps(ret_json))
        resp.status_code = 403
        return resp

    users = select_all_users()
    ret_json["code"] = "0"
    ret_json["status"] = "ok"
    ret_json["msg"] = ""
    ret_json["users"] = users

    resp.status_code = 200
    resp.headers["Content-Type"] = "application/json; charset=utf-8"
    resp.set_data(json.dumps(ret_json))
    return resp


@app.route("/edituser", methods=["POST"])
def edit_user():
    ret_json = {}
    resp = create_response_allow()

    token = request.cookies.get("user-token")
    if is_token_valid(token):
        ret_json["code"] = "499"
        ret_json["status"] = "failed"
        ret_json["msg"] = "auth forbidden"
        resp.set_data(json.dumps(ret_json))
        resp.status_code = 403
        return resp

    req = json.loads(request.stream.read())
    update_user_by_name(req["name"], req["data"])

    ret_json["code"] = "0"
    ret_json["status"] = "ok"
    ret_json["msg"] = ""

    resp.status_code = 200
    resp.set_data(json.dumps(ret_json))
    return resp


if __name__ == "__main__":

    is_debug = True
    try:
        app.run(debug=is_debug, port=12340)
    finally:
        db_clearup()
