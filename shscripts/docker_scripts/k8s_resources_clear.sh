#!/bin/bash
set -eu

ns="airpay-qa-testdev"

function clear_resources {
    re_type=$1
    res=$(kubectl get ${re_type} -n airpay-qa-testdev | grep -v -i name | awk '{print $1}')
    echo "clear ${re_type}: ${res}"

    for resource in ${res}; do
      kubectl delete ${re_type}/${resource} -n $ns
    done
}

function clear_ingress {
    clear_resources ing
}
function clear_service {
    clear_resources svc
}
function clear_deploy {
    clear_resources deploy
}

function clear_all {
    clear_ingress
    clear_service
    clear_deploy
}

clear_all
echo "k8s resources clear done"