import json, logging
from flask import make_response

from data import select_user_by_name
from utils import string_decode

logger = logging.getLogger(__name__)


def is_auth(user, db_user):
    if db_user is None:
        return False
    print(user)
    print(db_user)
    return True if user["password"] == db_user.get("password", "") else False


def is_token_valid(token: str) -> bool:
    if token is None or len(token) == 0:
        return False
    text = string_decode(token)
    return len(text.split("|")) == 2


def get_username_from_token(token: str) -> str:
    text = string_decode(token)
    return text.split("|")[0]


def get_request_data(request):
    logger.debug("|" + "*" * 60)
    logger.debug("| Method: " + request.method)
    logger.debug("| Path: " + request.path)
    logger.debug("| Headers:")
    for k, v in request.headers.items():
        logger.debug("|    %s: %s" % (k, v))

    query = request.query_string
    if query is not None and len(query) > 0:
        logger.debug("| Query: " + query.decode(encoding="utf-8"))

    data = request.stream.read()
    if data is not None and len(data) > 0:
        logger.debug("| Data:")
        logger.debug("|    " + data.decode(encoding="utf-8"))

    logger.debug("|" + "*" * 60)
    return data


def create_response_allow():
    resp = make_response()
    resp.headers["Access-Control-Allow-Origin"] = "http://localhost:8080"
    resp.headers[
        "Access-Control-Allow-Headers"
    ] = "Accept,Origin,Content-Type,Authorization"
    resp.headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
    resp.headers["Access-Control-Allow-Credentials"] = "true"
    resp.headers["Access-Control-Max-Age"] = "3600"
    return resp


def build_ok_json_response(resp, *data):
    ret_json = {}
    ret_json["code"] = "0"
    ret_json["status"] = "ok"
    ret_json["msg"] = ""
    for item in data:
        if item is not None and len(item) > 0:
            ret_json[item["key"]] = item["value"]
    resp.set_data(json.dumps(ret_json))

    resp.status_code = 200
    resp.headers["Content-Type"] = "application/json; charset=utf-8"
    return resp


def build_forbidden_json_response(resp):
    ret_json = {}
    ret_json["code"] = "499"
    ret_json["status"] = "failed"
    ret_json["msg"] = "auth forbidden"
    resp.set_data(json.dumps(ret_json))

    resp.status_code = 403
    resp.headers["Content-Type"] = "application/json; charset=utf-8"
    return resp


if __name__ == "__main__":
    pass
