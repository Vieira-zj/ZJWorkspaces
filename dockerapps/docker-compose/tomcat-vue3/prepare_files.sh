#!/bin/bash
set -ue

readonly nginx_configs="${HOME}/Workspaces/zj_work_workspace/dockerapps/configs/vue3_nginx_conf"
readonly nignx_mounted_dir="/tmp/openrestyapp"

readonly mock_data="/${HOME}/Workspaces/zj_js_project/vue_lessons/vue_demo_basic/tests/data"
readonly mock_mounted_dir="/tmp/mockserver"

readonly vue_dist="${HOME}/Workspaces/zj_js_project/vue_lessons/vue_demo_basic/dist"
readonly vue_mounted_dir="/tmp/dist"

CheckAndCopy() {
  local src_dir=$1
  local mounted_dir=$2
  if [ -d ${mounted_dir} ]; then
      rm -rf ${mounted_dir}/*
      cp -r ${src_dir}/* ${mounted_dir}
  else
    echo "mounted dir ${mounted_dir} is NOT exist!"
    exit 99
  fi  
}

CheckAndCopy ${nginx_configs} ${nignx_mounted_dir}

CheckAndCopy ${mock_data} ${mock_mounted_dir}
echo "cp /tmp/mockserver/* /usr/local/bin/" > ${mock_mounted_dir}/setup.sh

CheckAndCopy ${vue_dist} ${vue_mounted_dir}
echo "cd /usr/local/tomcat/webapps && cp -r /tmp/dist/ ./ && mv dist/css/ ./ && mv dist/js ./" > ${vue_mounted_dir}/setup.sh

echo "Prepare files done."
