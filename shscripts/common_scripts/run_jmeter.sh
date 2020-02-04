#!/bin/bash
#
# cli:
# ./run_jmeter.sh exec jmeter_test01.jmx
# ./run_jmeter.sh report
#
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

function backup_file() {
  local file=$1
  local dir="./jtl_baks"
  if [[ ! -d ${dir} ]]; then
    mkdir ${dir}
  fi

  if [[ -f ${file} ]]; then
    mv ${file} "${dir}/${file}_$(date +%s)"
  fi
}

# main
#
if [[ $1 == "clear" ]]; then
  del_file jmeter.jtl
  echo "Clear Done"
  exit 0
fi

jtl_file="jmeter_test.jtl"
log_file="jmeter_test.log"
report_dir="./reports"

echo "Jmeter Start"
if [[ $1 == "exec" ]]; then
  jmx_file=$2
  if [[ ! -f ${jmx_file} ]]; then
    echo "jmx file not found: ${jmx_file}"
    exit 99
  fi

  backup_file ${jtl_file}
  del_file ${log_file}
  del_dir ${report_dir}
  set -x
  jmeter -n -t ${jmx_file} -l ${jtl_file} -j ${log_file} -e -o ${report_dir}
  set +x
fi

if [[ $1 == "report" ]]; then
  set +u
  if [[ $2 != "" ]]; then
    jtl_file=$2
  fi
  
  if [[ ! -f ${jtl_file} ]]; then
    echo "jtl file not found: ${jtl_file}"
    exit 99
  fi
  
  del_dir ${report_dir}
  set -x
  jmeter -g ${jtl_file} -o ${report_dir} 
  set +x
fi
echo "Jmeter Done"

set +eu
