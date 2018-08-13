#!/bin/bash
set -ex

# https://jenkins.qiniu.io/job/kodo-consul-deploy/configure
CONSUL_RELEASE="1.0.0"
TEST_ENV="beta"

PACKAGE_NAME="consul_${CONSUL_RELEASE}.tar.gz"
WORKSPACE="/Users/zhengjin/Downloads/tmp_files"

CONSUL_DOWNLOAD_FILE="consul_${CONSUL_RELEASE}.zip"
CONSUL_DOWNLOAD_URL="https://releases.hashicorp.com/consul/${CONSUL_RELEASE}/consul_${CONSUL_RELEASE}_linux_amd64.zip"

BIN_FILE="consul"
TAGNAME="kodo-consul"
DIRPATH="${TAGNAME}_${CONSUL_RELEASE}"
BUILD_DIR="_package"
HOST="cs1"

echo "test env: ${TEST_ENV}"

cd ${WORKSPACE}
if [ ! -f ${CONSUL_DOWNLOAD_FILE} ]; then
  curl -o ${CONSUL_DOWNLOAD_FILE} ${CONSUL_DOWNLOAD_URL}
fi
tar -xzf ${CONSUL_DOWNLOAD_FILE}

if [ -d ${DIRPATH} ]; then
  rm -rf ${DIRPATH}
fi
mkdir -p "${DIRPATH}/${BUILD_DIR}"
mv ${BIN_FILE} "${DIRPATH}/${BUILD_DIR}"

touch "${DIRPATH}/${BUILD_DIR}/README"
echo "download url: ${CONSUL_DOWNLOAD_URL}" > "${DIRPATH}/${BUILD_DIR}/README"

cd ${DIRPATH}
tar zcvf ${WORKSPACE}/${PACKAGE_NAME} ${BUILD_DIR}

# bs_dist_pkg "cs1" ${PACKAGE_NAME}
# floy_deploy ${HOST} ${TAGNAME} ${PACKAGE_NAME}
# remote_supervisorctl "restart" ${TAGNAME}

set +ex
