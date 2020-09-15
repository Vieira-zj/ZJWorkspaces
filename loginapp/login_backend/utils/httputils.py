# coding: utf-8
import base64
import logging
import json
import os

from flask import make_response

logger = logging.getLogger(__name__)

# front_endpoint = "*"
front_endpoint = "http://localhost:8080"


def log_request_data(request, is_file=False):
    logger.debug("|" + "*" * 60)
    logger.debug("| Method: " + request.method)
    logger.debug("| Path: " + request.path)
    logger.debug("| Headers:")
    for k, v in request.headers.items():
        logger.debug("|    %s: %s" % (k, v))

    query = request.query_string
    if query is not None and len(query) > 0:
        logger.debug("| Query: " + query.decode(encoding="utf-8"))
    # logger.debug("| Query: " + "&".join([f"{k}={v}" for k, v in request.args.items()]))

    if is_file:
        logger.debug("|" + "*" * 60)
        return ""

    # data = request.stream.read()
    data = request.get_data()
    if data is not None and len(data) > 0:
        logger.debug("| Data:")
        try:
            logger.debug("|    " + data.decode(encoding="utf-8"))
        except UnicodeDecodeError as err:
            logger.info(err)
            logger.debug(
                "|    " + base64.b64encode(data[:128]).decode(encoding="utf-8")
            )
    logger.debug("|" + "*" * 60)


def create_response_allow(resp=None):
    if resp is None:
        resp = make_response()
    if os.getenv("FLASK_ENV") != "prod":
        resp.headers["Access-Control-Allow-Origin"] = front_endpoint
    return resp


def create_option_response_allow(resp=None):
    if resp is None:
        resp = make_response()
    if os.getenv("FLASK_ENV") != "prod":
        resp.headers["Access-Control-Allow-Origin"] = front_endpoint
        resp.headers[
            "Access-Control-Allow-Headers"
        ] = "Accept,Origin,Content-Type,Authorization,Specified-User,X-Test"
        resp.headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
        resp.headers["Access-Control-Allow-Credentials"] = "true"
        resp.headers["Access-Control-Max-Age"] = "3600"
    return resp


def build_json_response(resp, status_code, ret_json):
    resp.status_code = status_code
    resp.headers["Content-Type"] = "application/json; charset=utf-8"
    resp.set_data(json.dumps(ret_json))
    return resp


def build_ok_json_response(resp, **kwargs):
    ret_json = {}
    ret_json["code"] = "0"
    ret_json["status"] = "ok"
    ret_json["message"] = ""
    for k, v in kwargs.items():
        if v is not None and len(v) > 0:
            ret_json[k] = v
    return build_json_response(resp, 200, ret_json)


def build_forbidden_json_response(resp):
    ret_json = {}
    ret_json["code"] = "499"
    ret_json["status"] = "failed"
    ret_json["message"] = "auth forbidden"
    return build_json_response(resp, 403, ret_json)

