#!/bin/bash
set -eux

# build backend image and test
if [[ $1 == "build" ]]; then
  docker build -f backend.Dockerfile -t login-backend:v1 .
  #docker run --name backend -it --rm login-backend:v1
fi

if [[ $1 == "cp_app" ]]; then
  target="${HOME}/Downloads/tmps/docker_vols/backend"
  if [[ -d $target ]]; then
    rm -rf $target
  fi
  cp -r login_backend/ $target
fi

if [[ $1 == "cp_dist" ]]; then
  # docker run --name proxy -d --rm -p 8080:80 nginx
  docker cp "login_frontend/dist/." "proxy:/usr/share/nginx/html"
fi

if [[ $1 == "up" ]]; then
  docker-compose -f login-demo-compose.yaml up -d
  # login url: http://logindemo.zj.com:8080/index.html
fi

if [[ $1 == "down" ]]; then
  docker-compose -f login-demo-compose.yaml down
fi

echo "done"