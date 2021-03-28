#!/bin/bash

# docker

check_input() {
  local input=$1
  if [[ -z "$input" ]]; then
    echo -e "input is empty"
    exit 1
  fi
}

check_status() {
  local msg=$1
  if [[ $? == 0 ]]; then
    echo -e "success: $msg"
  else
    echo -e "failed: $msg"
    exit 1
  fi
}

main_build_container_pkg() {
  if [[ $UID == 0 ]]; then
    echo 'begin to container package...'
  else
    echo 'current user is not root.'
    exit 1
  fi

  read -p "intput container id: " con_id
  check_input $con_id
  read -p "input new image name: " img_name
  check_input $img_name
  read -p "save file name for image: " tar_file_name
  check_input $tar_file_name

  docker commit $con_id $img_name
  check_status "commit container [$con_id] to image [$img_name]"
  docker save -o $tar $img_name
  check_status "save image [$img_name] to file [$tar_file_name]"
}

# k8s

services=(
  'grpc.service1'
  'grpc.service2'
)

cur_dir=$(pwd)
all_ep_file="${cur_dir}/all_ep.txt"
all_pods_file="${cur_dir}/all_pods.txt"
register_svc_infos_file="${cur_dir}/register_svc_infos_file.txt"
etcd_eps="127.0.0.1"

function get_svc_info() {
  local grpc_svc=$1
  local pod_addr=$(cat $register_svc_infos_file | grep -i $grpc_svc | awk -F ':' '{printf "%s:%s",$3,$4}')
  local svc_name=$(cat $all_ep_file | grep ${pod_addr} | awk '{printf "%s:%s",$1,$2}')
  echo "grpc_svc=${grpc_svc}, pod_addr=${pod_addr}, ns_svc_name=${svc_name}"
}

function get_pod_info() {
  local grpc_svc=$1
  local pod_ip=$(cat $register_svc_infos_file | grep -i $grpc_svc | head -n 1 | awk -F ':' '{print $3}')
  local pod_name=$(cat $all_pods_file | grep ${pod_ip} | head -n 1 | awk '{printf "%s:%s",$1,$2}')
  echo "grpc_svc=${grpc_svc}, pod_ip=${pod_ip}, ns_pod_name=${pod_name}"
}

function main_get_info() {
  # get service info by grpc api
  if [[ ! -f $register_svc_infos_file ]]; then
    etcdctl --endpoints=${etcd_eps} get test --prefix > $register_svc_infos_file
  fi
  if [[ ! -f $all_ep_file ]]; then
    kubectl get ep -A > $all_ep_file
  fi
  if [[ ! -f $all_pods_file ]]; then
    kubectl get pod -A -o wide > $all_pods_file
  fi
  for service in ${services[*]}; do
    get_pod_info $service
  done
}

main_get_info
echo "k8s resource check done."
