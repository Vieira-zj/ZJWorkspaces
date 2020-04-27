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
import_image_dir="${CWD}/images"

source "${CWD}/bin/load_configs.sh"

user=$(whoami)

docker_push() {
    src=$1
    dest=${src//$source_image_registry/$image_registry}
    docker tag $src $dest
    echo "pushing image $dest"
    docker push $dest
}

function registry_prelogin() {
  if [ -n "${registry_docker_user}" ]; then
    echo "login to registry $image_registry"
    docker login $image_registry -u $registry_docker_user -p $registry_docker_password
    if [ $? != 0 ]; then
      red_echo "docker registry $image_registry should be online"
      exit 1
    fi
  fi
}

# loading......
load_images() {
  registry_prelogin
  green_echo 'load prophet docker image succeed'
}

# pushing......
real_images() {
    registry_prelogin
    echo "push prophet images, it will also take a long long time, please wait"
    chmod +x ${CWD}/bin/rubick_push
    ${CWD}/bin/rubick_push -r http://$image_registry -u $registry_docker_user -p $registry_docker_password -l ${CWD}/images/docker_images_basic.txt
    green_echo 'push prophet docker image succeed'
}

push_images() {
    registry_prelogin
    echo "push prophet images, it will also take a long long time, please wait"
    for host in $registry_docker_hosts; do
        $ssh -Tn ${user}@${host} "mkdir -m 755 -p ${registry_docker_hostpath}/docker/registry/v2"
        $scp -r ${CWD}/docker/registry/v2/blobs ${user}@${host}:"${registry_docker_hostpath}/docker/registry/v2"
        $scp -r ${CWD}/docker/registry/v2/repositories ${user}@${host}:"${registry_docker_hostpath}/docker/registry/v2"
    done
    green_echo 'push prophet docker image succeed'
}

fast_images() {
  push_images
}

import_base_images() {
  registry_prelogin
    echo "loading base images, it will take a short time, please wait"
    docker load -i $imageroot/base.tar
    cat $imageroot/imagelist | while read line
    do
        docker_push $line
    done
    green_echo 'load and push base docker image succeed'
}

import_metas() {
    curl $meta_registry  > /dev/null 2>&1
    if [ $? != 0 ]; then
        red_echo "meta registry $meta_registry should be online"
        exit 1
    fi
    for host in $registry_meta_hosts; do
        echo "pushing meta to $host:$registry_meta_hostpath"
        $ssh ${user}@$host "$mkdir -p $registry_meta_hostpath/tmp $registry_meta_hostpath/env"
        $scp $import_image_dir/metas.tar.gz ${user}@$host:$registry_meta_hostpath/tmp
        $ssh ${user}@$host "cd $registry_meta_hostpath/tmp && tar zxvf metas.tar.gz"
        $ssh ${user}@$host "cp -arf $registry_meta_hostpath/tmp/metas/env/* $registry_meta_hostpath/env"
    done
}

wait_ok() {
    target=$1
    set +e
    for i in `seq 1 100`; do
        curl $target --connect-timeout 1  > /dev/null 2>&1
        if [ $? = 0 ]; then
            set -e
            return 0
        fi
        echo "connect timeout, sleep 1"
        sleep 1
    done
    red_echo "$target is not reachable"
    exit 1
}

metas() {
    wait_ok $meta_registry
    import_metas
}

if [ x"$mode" == x"online" ]; then
  green_echo "online install, skip import images and metas"
  exit 0
fi
if [ $# -gt 0 ]; then
  $1
fi
