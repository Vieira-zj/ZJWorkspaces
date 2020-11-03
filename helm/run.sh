#!/bin/bash
set -eu

chart="helloworld"

function create {
    helm create $chart
}

function lint {
    local config=$1
    helm lint -f $config $chart
}

function pkg {
    helm package $chart
}

function debug {
    local config=$1
    helm install --dry-run -f $config --debug $chart --generate-name > helm_debug.txt
}

function install {
    local config=$1
    helm install -f $config ${chart}-app $chart
}

lint helloworld_cfg.yaml
# debug helloworld_cfg.yaml

echo "Done"