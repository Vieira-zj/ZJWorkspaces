#!/bin/bash
set -e

export QBOXROOT=$WORKSPACE

cd $QBOXROOT/kodo && source ./env-jenkins.sh
cp Makefile src/qiniu.com/kodo/biz/app/qboxcdnrefresh && cd $_ && make

cp $WORKSPACE/kodo/bin/qbox$SERVICE $WORKSPACE/kodo/dockerfiles/common && cd $_

docker build --rm --build-arg APP_BIN=qbox$SERVICE --build-arg APP_CFG=conf/qbox$SERVICE.conf -t $IMAGE -f Dockerfile .
docker push $IMAG

