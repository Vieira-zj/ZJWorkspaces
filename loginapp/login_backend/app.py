# coding: utf-8
import json
import logging
import os, sys

from flask import Flask, request

from utils import DBUtils
from services import UserService


logging.basicConfig(
    level=logging.DEBUG, format="%(asctime)s - %(levelname)s: %(message)s"
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config["upload_dir"] = os.path.join(os.getcwd(), "upload_files")
app.config["host"] = "0.0.0.0"
app.config["port"] = 12340
service = UserService(app)


@app.route("/", methods=["GET", "POST", "OPTIONS"])
def home():
    return service.ping(request)


@app.route("/ping", methods=["GET", "POST", "OPTIONS"])
def ping():
    return service.ping(request)


@app.route("/login", methods=["POST", "OPTIONS"])
def login():
    return service.login(request)


@app.route("/getuser", methods=["POST", "OPTIONS"])
def get_user():
    return service.getUser(request)


@app.route("/getusers", methods=["POST", "OPTIONS"])
def get_users():
    return service.getUsers(request)


@app.route("/newuser", methods=["POST", "OPTIONS"])
def new_user():
    return service.newUser(request)


@app.route("/edituser", methods=["POST", "OPTIONS"])
def edit_user():
    return service.editUser(request)


@app.route("/issuperuser", methods=["GET", "OPTIONS"])
def is_super_user():
    return service.isSuperUser(request)


@app.route("/uploadpic", methods=["POST", "OPTIONS"])
def upload_pic():
    return service.uploadPic(request)


@app.route("/downloadpic/<filename>", methods=["GET", "OPTIONS"])
def download_pic(filename):
    return service.downloadPic(request, filename)


if __name__ == "__main__":

    is_product = True if os.getenv("FLASK_ENV") == "prod" else False
    is_debug = True if os.getenv("IS_DEBUG") and os.getenv("IS_DEBUG") == "y" else False

    try:
        if is_product:
            from wsgiref.simple_server import make_server

            server = make_server(app.config["host"], app.config["port"], app)
            server.serve_forever()
            app.run()
        else:
            app.run(host=app.config["host"], debug=is_debug, port=app.config["port"])
    finally:
        DBUtils.closeDBConnection()
