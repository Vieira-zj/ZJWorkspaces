#!/usr/bin/env bash

# set to project root dir
PWD=$(cd `dirname $0`; pwd)
CWD="$PWD/.."
kubectrlraw="${CWD}/tools/kubectl"
etcdctl="${CWD}/tools/etcdctl"
confdir="${CWD}/.output/public_conf"
kubectl="$kubectrlraw --kubeconfig=${confdir}/.kube/config"

source "${CWD}/bin/load_configs.sh"

validate() {
    # etcd
    yellow_echo "check etcd state:"
    $etcdctl \
        --ca-file=${confdir}/kubernetes/ssl/ca.pem \
        --cert-file=${confdir}/kubernetes/ssl/kubernetes.pem \
        --key-file=${confdir}/kubernetes/ssl/kubernetes-key.pem \
        --endpoints="${etcd_cluster}" \
        cluster-health

    # master
    yellow_echo "check k8s master components:"
    $kubectl get componentstatuses
}

yellow_echo() {
    str=$1
    echo -e "\033[33m ${str}\033[0m"
}

main() {
    $kubectl cluster-info
    yellow_echo "all nodes in cluster:"
    $kubectl get nodes --no-headers -o wide
    yellow_echo "trying to find unhealth pod:"
    $kubectl get pod --all-namespaces -o wide | grep -v 'Running'
    validate
}

main
