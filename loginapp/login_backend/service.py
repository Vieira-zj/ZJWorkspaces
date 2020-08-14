import json, logging
from flask import make_response

from data import select_user_by_name
from utils import string_decode

logger = logging.getLogger(__name__)


def is_auth(user_name, password):
    row = select_user_by_name(user_name)
    return True if row.get("password", "") == password else False


def is_token_valid(token: str) -> bool:
    text = string_decode(token)
    return len(text.split("|")) != 2


def get_request_data(request):
    logger.debug("|" + "*" * 60)
    logger.debug("| Method: " + request.method)
    logger.debug("| Path: " + request.path)
    logger.debug("| Headers:")
    for k, v in request.headers.items():
        logger.debug("|    %s: %s" % (k, v))

    query = request.query_string.decode(encoding="utf-8")
    if len(query) > 0:
        logger.debug("| Query: " + query)

    data = request.stream.read().decode(encoding="utf-8")
    if len(data) > 0:
        logger.debug("| Data:")
        logger.debug("|    " + data)

    logger.debug("|" + "*" * 60)
    return data


def create_response_allow():
    resp = make_response()
    resp.headers["Access-Control-Allow-Origin"] = "*"
    resp.headers["Access-Control-Allow-Headers"] = "Accept,Origin,Content-Type"
    resp.headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
    resp.headers["Access-Control-Max-Age"] = "3600"
    return resp


def build_ok_json_response(resp, data={}):
    ret_json = {}
    ret_json["code"] = "0"
    ret_json["status"] = "ok"
    ret_json["msg"] = ""
    if data is not None and len(data) > 0:
        ret_json[data["key"]] = data["value"]
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
