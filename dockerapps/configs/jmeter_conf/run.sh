#!/bin/bash
set -eu

base_dir="${HOME}/Workspaces/zj_work_workspace/dockerapps"
conf_dir="${base_dir}/configs/jmeter_conf"
dkc_dir="${base_dir}/docker-compose-v3"

function start_app() {
  echo "copy configs."
  files=(entrypoint.sh user.properties)
  for file in ${files[*]}; do
    cp ${conf_dir}/${file} /tmp/${file}
  done

  echo "start jmeter cluster."
  docker-compose -f ${dkc_dir}/perf-jmeter-compose.yaml up -d
}

function stop_app() {
  echo "stop jmeter cluster."
  docker-compose -f ${dkc_dir}/perf-jmeter-compose.yaml down
}

function copy_test() {
  echo "copy jmeter test case."
  local target_dir="/tmp/tests"
  if [[ ! -d ${target_dir} ]]; then
      mkdir -p ${target_dir}
  fi
  cp ${conf_dir}/test.jmx /tmp/tests
}

if [[ $1 == "start" ]]; then
  start_app
fi

if [[ $1 == "stop" ]]; then
  stop_app
fi

if [[ $1 == "pre" ]]; then
  copy_test
fi

# RUN JMETER TEST:
# rm -rf out/
# jmeter -n -R jmeter-slave1,jmeter-slave2 -t test.jmx -j out/master.log -l out/result.jtl -e -o out/reports

# JMETER CLI:
# -t, --testfile <argument>
# -R, --remotestart <argument>
# -j, --jmeterlogfile <argument>
# -l, --logfile <argument>
# -X, --remoteexit Exit the remote servers at end of test (non-GUI)
# -e, --reportatendofloadtests generate report dashboard after load test

echo "jmeter cluster done."
