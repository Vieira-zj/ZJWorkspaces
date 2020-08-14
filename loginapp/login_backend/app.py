import json
import logging

from flask import Flask, request
from flask import make_response

from data import select_user_by_name, select_all_users, update_user_by_name, db_clearup
from service import (
    is_auth,
    is_token_valid,
    get_request_data,
    create_response_allow,
    build_ok_json_response,
    build_forbidden_json_response,
)
from utils import string_encode, string_decode

logger = logging.getLogger(__name__)

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

    resp = create_response_allow()
    user = json.loads(get_request_data(request))
    if is_auth(user["name"], user["password"]):
        resp = build_ok_json_response(resp)
        resp.set_cookie("user-token", string_encode("|".join(list(user.values()))))
    else:
        resp = build_forbidden_json_response(resp)
    return resp


@app.route("/getuser", methods=["POST", "OPTIONS"])
def get_user():
    if request.method == "OPTIONS":
        return create_response_allow()

    resp = create_response_allow()
    token = request.cookies.get("user-token")
    if is_token_valid(token):
        return build_forbidden_json_response(resp)

    req = json.loads(get_request_data(request))
    user = select_user_by_name(req["name"])
    build_ok_json_response(resp, {"key": "user", "value": user})
    return resp


@app.route("/getusers", methods=["GET", "OPTIONS"])
def get_users():
    if request.method == "OPTIONS":
        return create_response_allow()

    resp = create_response_allow()
    token = request.cookies.get("user-token")
    if is_token_valid(token):
        return build_forbidden_json_response(resp)

    get_request_data(request)
    users = select_all_users()
    resp = build_ok_json_response(resp, {"key": "users", "value": users})
    return resp


@app.route("/edituser", methods=["POST"])
def edit_user():
    ret_json = {}
    resp = create_response_allow()

    token = request.cookies.get("user-token")
    if is_token_valid(token):
        return build_forbidden_json_response(resp)

    req = json.loads(get_request_data(request))
    update_user_by_name(req["name"], req["data"])
    resp = build_ok_json_response(resp)
    return resp


if __name__ == "__main__":

    is_debug = True
    try:
        app.run(debug=is_debug, port=12340)
    finally:
        db_clearup()
