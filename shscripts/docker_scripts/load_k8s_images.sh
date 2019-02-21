#/bin/bash
set -ex

load_images_by_args() {
  images=(kube-apiserver:v1.1.13.3 kube-controller-manager:v1.13.3 kube-scheduler:v1.13.3 kube-proxy:v1.13.3 pause:3.1 etcd:3.2.24 coredns:1.2.6)
  if [ -n $1 ]; then
    images=($1)
  fi

  for ima in ${images[@]}; do
    echo "pull image $ima"
    if [ -z $DOCKER_CERT_PATH ]; then  # pull image only if local docker is running
      docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$ima
    fi
    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$ima k8s.gcr.io/$ima
    docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$ima
  done
}

load_images_by_configs() {
  file="./images.properties"
   
  if [ -f $file ]; then
    echo "$file found."
   
    while IFS='=' read -r key value
    do
      echo "${key}=${value}"
      docker pull ${value}
      docker tag ${value} ${key}
      docker rmi ${value}
    done < "$file"
  else
    echo "$file not found."
  fi
}

load_images_by_args $1
load_images_by_configs
echo "load docker images done."

set +ex
