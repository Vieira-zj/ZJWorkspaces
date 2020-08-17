#!/bin/bash
set -eux

# build backend image and test
if [[ $1 == "build" ]]; then
  docker build -f backend.Dockerfile -t login-backend:v1 .
  #docker run --name backend -it --rm login-backend:v1
fi

if [[ $1 == "up" ]]; then
  docker-compose -f login-demo-compose.yaml up -d
fi

if [[ $1 == "down" ]]; then
  docker-compose -f login-demo-compose.yaml down
fi

echo "done"