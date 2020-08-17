#!/bin/bash
set -exu

# pip3 freeze > requirements.txt

export MYSQL="localhost"
export FLASK_ENV="test"
python3 app.py
