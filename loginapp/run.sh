#!/bin/bash
set -eux

function cp_app() {
  target="${HOME}/Downloads/tmps/docker_vols/backend"
  if [[ -d $target ]]; then
    rm -rf $target
  fi
  cp -r login_backend/ $target	
}

function cp_dist() {
  # docker run --name frontend -d --rm -p 8080:80 -v ${HOME}/Downloads/tmps/docker_vols/conf.d:/etc/nginx/conf.d nginx
  docker cp login_frontend/dist/. frontend:/usr/share/nginx/html
  docker cp login.conf frontend:/etc/nginx/conf.d/default.conf
  docker exec frontend nginx -s reload
}

# build backend image and test
if [[ $1 == "build" ]]; then
  docker build -f backend.Dockerfile -t login-backend:v1 .
  #docker run --name backend -it --rm login-backend:v1
fi

if [[ $1 == "cp_app" ]]; then
  cp_app
fi

if [[ $1 == "cp_dist" ]]; then
  cp_dist
fi

if [[ $1 == "up" ]]; then
  docker-compose -f login-demo-compose.yaml up -d
fi

if [[ $1 == "down" ]]; then
  docker-compose -f login-demo-compose.yaml down
fi

if [[ $1 == "main" ]]; then
  # login url: http://logindemo.zj.com:8080
  cp_app
  docker-compose -f login-demo-compose.yaml up -d
  cp_dist
fi

echo "done"