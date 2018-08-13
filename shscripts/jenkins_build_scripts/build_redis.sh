#!/bin/bash
set -ex

# https://jenkins.qiniu.io/job/kodo-redis-build/configure
REDIS_RELEASE="redis-4.0.7"
PACKAGE_NAME="myredis.tar.gz"

WORKSPACE="/Users/zhengjin/Downloads/tmp_files"
REDIS_DOWNLOAD_FILE="${REDIS_RELEASE}.tar.gz"
REDIS_DOWNLOAD_URL="http://download.redis.io/releases/${REDIS_DOWNLOAD_FILE}"
BUILD_DIR="_package"

cd ${WORKSPACE}
if [ -d "${REDIS_RELEASE}" ]; then
  rm -rf  ${REDIS_RELEASE}
fi

curl -o ${REDIS_DOWNLOAD_FILE} ${REDIS_DOWNLOAD_URL}
tar xzf ${REDIS_DOWNLOAD_FILE}
cd ${REDIS_RELEASE}
make
# make test

mkdir ${BUILD_DIR}
cp src/redis-sentinel ${BUILD_DIR}
cp src/redis-check-aof ${BUILD_DIR}
cp src/redis-check-rdb ${BUILD_DIR}
cp src/redis-benchmark ${BUILD_DIR}
cp src/redis-server ${BUILD_DIR}
cp src/redis-check-aof ${BUILD_DIR}
cp src/redis-cli ${BUILD_DIR}
cp src/mkreleasehdr.sh ${BUILD_DIR}
cp src/redis-trib.rb ${BUILD_DIR}

tar -zcvf $PACKAGE_NAME ${BUILD_DIR}

# bs_dist_pkg "cs1" ${PACKAGE_NAME}

set +ex
