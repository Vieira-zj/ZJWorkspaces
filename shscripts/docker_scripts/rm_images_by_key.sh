#/bin/bash
set -ex

search_key='k8s.gcr.io'
#tag_key='v1.13.0'
images=$(docker images | sort | grep ${search_key} | awk '{print $1":"$2}')
for image in ${images}; do
  echo "remove image ${image}"
  docker rmi ${image}
done

set +ex