#!/bin/sh
set -exu

consul_conf="/consul/config"
sum=0

for node in "consul-follower1" "consul-follower2" "consul-client1"; do
  docker cp ${HOME}/Workspaces/zj_work_workspace/dockerapps/mockserver ${node}:/usr/bin
  docker cp ${HOME}/Workspaces/zj_work_workspace/dockerapps/mock_conf.json ${node}:/usr/bin
  docker exec -t ${node} sh -c "cd /usr/bin;mockserver" &

  sum=$((sum+1))
  docker cp consul.mock.service${sum}.json ${node}:${consul_conf}
  docker exec -t ${node} consul reload
done

set +exu
