import base64
from flask import make_response


def string_encode(text: str) -> str:
    b_encode = base64.b64encode(text.encode(encoding="utf-8"))
    return b_encode.decode(encoding="utf-8")


def string_decode(text: str) -> str:
    return base64.b64decode(text).decode(encoding="utf-8")


def is_token_valid(token: str) -> bool:
    text = string_decode(token)
    return len(text.split("|")) != 2


def create_response_allow():
    resp = make_response()
    resp.headers["Access-Control-Allow-Origin"] = "*"
    resp.headers["Access-Control-Allow-Headers"] = "Accept,Origin,Content-Type"
    resp.headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
    resp.headers["Access-Control-Max-Age"] = "3600"
    return resp


if __name__ == "__main__":
    str_encode = string_encode("hello")
    print(str_encode)

    str_decode = string_decode(str_encode)
    print(str_decode)
