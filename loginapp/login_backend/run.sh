#!/bin/bash
set -exu

# pip3 freeze > requirements.txt

export FLASK_ENV="test" # test, prod
python3 app.py
