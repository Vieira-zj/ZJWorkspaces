import json
import logging

from flask import Flask, request
from flask import make_response

from data import select_user_by_name, select_many_users, update_user_by_name, db_clearup
from service import (
    is_auth,
    is_token_valid,
    get_username_from_token,
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
        resp.set_cookie("user-token", string_encode("|".join(list(user.values()))))
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
    update_user_by_name(req["name"], req["data"])
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


if __name__ == "__main__":

    is_debug = True
    try:
        app.run(debug=is_debug, port=12340)
    finally:
        db_clearup()
