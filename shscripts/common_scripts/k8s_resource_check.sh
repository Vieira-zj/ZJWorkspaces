#!/bin/bash

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

function main() {
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
    get_svc_info_v2 $service
  done
}

main
echo "k8s resource check done."
