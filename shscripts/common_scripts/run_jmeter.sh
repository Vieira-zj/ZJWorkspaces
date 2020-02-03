#!/bin/bash
set -eu

function del_file() {
  local file=$1
  if [[ -f ${file} ]]; then
    rm ${file}
  fi
}

function del_dir() {
  local dir=$1
  if [[ -d ${dir} ]]; then
    rm -rf ${dir}
  fi
}

jmx_file=$1
results_file="jmeter_log.jtl"
log_file="jmeter.log"
report_dir="./reports"

if [[ ! -f ${jmx_file} ]]; then
  echo "jmx file not found!"
  exit 99
fi

del_file ${results_file}
del_file ${log_file}
del_dir ${report_dir}


echo "Jmeter Start"
jmeter -n -t ${jmx_file} -l ${results_file} -j ${log_file} -e -o ${report_dir}
echo "Jmeter Done"

set +eu
