#!/usr/bin/env bash
set -e

# set to project root dir
PWD=$(cd `dirname $0`; pwd)
CWD="$PWD/.."
sslcmd="${CWD}/tools/cfssl"
jsoncmd="${CWD}/tools/cfssljson"
kubectrlraw="${CWD}/tools/kubectl"
etcdctl="${CWD}/tools/etcdctl"
confdir="${CWD}/.output/public_conf"
kubectl="$kubectrlraw --kubeconfig=${confdir}/.kube/config"
addondir="${CWD}/addons"
rpmdir="$CWD/rpm-packages"
deployroot="${CWD}/.output/deploy_conf"
tplroot="$CWD/template"
bindir="$CWD/tools"
imageroot="$CWD/images"
sedcmd="sed"
remote_deploy_root="/opt/k8s"

source "${CWD}/bin/load_configs.sh"
source "${CWD}/bin/get_external_ip.sh"

label_external_ip() {
  for host in ${!hosts_to_external[@]}; do
    $kubectl label --overwrite node ${host} external.ip=${hosts_to_external[$host]}
  done
}

label_nvidia_gpu() {
  echo "add label for nvidia_gpu"
  for host in $nvidia_gpu_hosts; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/nvidia-gpu=true
    $kubectl label --overwrite node $host prophet.4paradigm.com/nvidia-gpu-feature-gate-mode=Accelerators
  done
}

label_nvidia_gpu_scale() {
  echo "add label for nvidia_gpu_scale"
  for line in $nvidia_gpu_scale_hosts; do
    arrline=(${line//:/ })
    $kubectl label --overwrite node ${arrline[0]} prophet.4paradigm.com/nvidia-gpu-feature-gate-mode=DevicePlugins
    $kubectl label --overwrite node ${arrline[0]} prophet.4paradigm.com/nvidia-gpu-scale-ratio=${arrline[1]}
    $ssh root@${arrline[0]} "sed -i 's/Accelerators=true/Accelerators=false/' $remote_deploy_root/etc/kubernetes/kubelet && systemctl restart kubelet" || :
  done
}

label_elastic() {
  echo "add label for elastic"
  for host in $elastic_hosts; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/elasticsearch=true
  done
}

label_addons() {
  echo "add label for kube-system addons"
  for host in $prophetAddon_hosts; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/addon=true
  done
}

label_prophetApp() {
  echo "add label for prophet app nodes"
  for host in $prophetApp_hosts; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/app=true
  done
}

label_prophetSystem() {
  echo "add label for prophet system nodes"
  for host in $prophetSystem_hosts; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/system=true
  done
  $kubectl create ns monitoring 2>/dev/null || :
  $kubectl create -n monitoring secret generic etcd-certs --from-file=${confdir}/kubernetes/ssl/kubernetes.pem --from-file=${confdir}/kubernetes/ssl/kubernetes-key.pem --from-file=${confdir}/kubernetes/ssl/ca.pem 2>/dev/null || :
}

label_online() {
  echo "add label for prophet online nodes"
  for host in $online_hosts; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/online=true
  done
}

label_offline() {
  echo "add label for prophet offline nodes"
  for host in $offline_hosts; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/offline=true
  done
}

label_prom() {
  echo "add label for prophet nodes"
  for host in $prometheus_hosts; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/prometheus=true
  done
}

label_rtidb_ns() {
  echo "add label for rtidb nameserver nodes"
  for host in $rtidb_nameserver; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/rtidb-nameserver=true
  done
}

label_rtidb_tabelet() {
  echo "add label for rtidb tablet nodes"
  for host in $rtidb_tabelet; do
    $kubectl label --overwrite node $host prophet.4paradigm.com/rtidb-tablet=true
  done
}

addon() {
  label_addons
}

prophet() {
  label_external_ip
  label_nvidia_gpu
  label_nvidia_gpu_scale
  label_elastic
  label_addons
  label_prophetApp
  label_prophetSystem
  label_online
  label_offline
  label_prom
  label_rtidb_ns
  label_rtidb_tabelet
}

if [ $# -gt 0 ]; then
  $1
else
  addon
  prophet
fi
