#!/bin/bash
set -exu

# pip3 freeze > requirements.txt

export MYSQL="localhost"
export FLASK_ENV="test" # test, prod
export IS_DEBUG="y"
python3 app.py
