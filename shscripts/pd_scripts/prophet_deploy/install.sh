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
deployroot="${CWD}/.output/deploy_conf"
tplroot="$CWD/template"
bindir="$CWD/tools"
imageroot="$CWD/images"
sedcmd="sed"
remote_deploy_root="/opt/k8s"

source "${CWD}/bin/load_configs.sh"
pht_remote_root=$remote_deploy_root/pht

wait_ok() {
  target=$1
  set +e
  for i in `seq 1 100`; do
    curl -k $target --connect-timeout 1 >/dev/null
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

detect_conf() {
  if [[ -d ${confdir} ]]; then
    red_echo "conf already generated, please delete ${confdir} before continue"
    exit 1
  fi

  $mkdir -p ${confdir}/kubernetes/ssl
  cp $tplroot/ssl/* $confdir/kubernetes/ssl/
  # replace csr ip
  cat $confdir/kubernetes/ssl/kubernetes-csr.json \
  |$sedcmd "s|{{ master_ips }}|$csr_k8smaster_ips|g" \
  |$sedcmd "s|{{ k8s_service_ip }}|$csr_k8sservice_ip|g" \
  > $confdir/kubernetes/ssl/kubernetes-csr.json.tmp
  mv -f $confdir/kubernetes/ssl/kubernetes-csr.json.tmp $confdir/kubernetes/ssl/kubernetes-csr.json
}

detect_deploy() {
  deploy_path=$1
  if [[ ! -d $deploy_path ]]; then
    red_echo "deploy config not exist! please ensure dir ${deploy_path} exist before you continue"
    exit 1
  fi
}

# ------------------------------
# generate
# ------------------------------

gen_ssl() {
  echo "generating ssl cert files"
  cd ${confdir}/kubernetes/ssl
  $sslcmd gencert -initca ca-csr.json | $jsoncmd -bare ca
  $sslcmd gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | $jsoncmd -bare kubernetes
  $sslcmd gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | $jsoncmd -bare kube-proxy
  $sslcmd gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | $jsoncmd -bare admin
  cd -
}

gen_flanneld_ssl() {
  host=$1
  echo "generating flanneld ssl cert for $host"
  cd ${confdir}/kubernetes/ssl
  cat $confdir/kubernetes/ssl/flanneld-csr.json \
  |$sedcmd "s|_flanneld_host_|$host|g" \
  > flanneld-csr-${host}.json.tmp
  mv -f flanneld-csr-${host}.json.tmp flanneld-csr-${host}.json
  $sslcmd gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes flanneld-csr-${host}.json | $jsoncmd -bare flanneld-${host}
  cd -
}

gen_token() {
  echo "generating kubernetes token"
  cd ${confdir}/kubernetes
  export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
  cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
  cd -
}

gen_bootstrap() {
  echo "generating bootstrap config"
  cd ${confdir}/kubernetes
  $kubectrlraw config set-cluster kubernetes \
    --certificate-authority=${confdir}/kubernetes/ssl/ca.pem \
    --embed-certs=true \
    --server=${APISERVER_PROXY} \
    --kubeconfig=bootstrap.kubeconfig
  $kubectrlraw config set-credentials kubelet-bootstrap \
    --token=${BOOTSTRAP_TOKEN} \
    --kubeconfig=bootstrap.kubeconfig
  $kubectrlraw config set-context default \
    --cluster=kubernetes \
    --user=kubelet-bootstrap \
    --kubeconfig=bootstrap.kubeconfig
  $kubectrlraw config use-context default --kubeconfig=bootstrap.kubeconfig
  cd -
}

gen_kubeproxy() {
  echo "generating kube-proxy config"
  cd ${confdir}/kubernetes
    $kubectrlraw config set-cluster kubernetes \
    --certificate-authority=${confdir}/kubernetes/ssl/ca.pem \
    --embed-certs=true \
    --server=${APISERVER_PROXY} \
    --kubeconfig=kube-proxy.kubeconfig
  $kubectrlraw config set-credentials kube-proxy \
    --client-certificate=${confdir}/kubernetes/ssl/kube-proxy.pem \
    --client-key=${confdir}/kubernetes/ssl/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig
  $kubectrlraw config set-context default \
    --cluster=kubernetes \
    --user=kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig
  $kubectrlraw config use-context default --kubeconfig=kube-proxy.kubeconfig
  cd -
}

gen_kubectl() {
  echo "generating kubectl config"
  $mkdir -p ${confdir}/.kube
  $kubectl config set-cluster kubernetes \
    --certificate-authority=${confdir}/kubernetes/ssl/ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER}
  $kubectl config set-credentials admin \
    --client-certificate=${confdir}/kubernetes/ssl/admin.pem \
    --embed-certs=true \
    --client-key=${confdir}/kubernetes/ssl/admin-key.pem
  $kubectl config set-context kubernetes \
    --cluster=kubernetes \
    --user=admin
  $kubectl config use-context kubernetes
}

gen_docker_config() {
  echo "generating docker config: $1"
  host=$1
  deploy_path="${deployroot}/${host}"
  $mkdir -p $deploy_path
  cat $tplroot/docker-install/docker \
  |$sedcmd "s|{{ image_registry }}|$image_registry|g" \
  |$sedcmd "s|{{ docker_root_dir }}|$docker_root_dir|g" \
  > $deploy_path/docker
  cat $tplroot/docker-install/docker.service \
  > $deploy_path/docker.service
}

gen_etcd_config() {
  echo "generating etcd config: $1 $2"
  host=$1
  run_user=$2
  deploy_path="${deployroot}/${host}"
  $mkdir -p $deploy_path/kubernetes/ssl
  $mkdir -p $deploy_path/systemd
  cp $confdir/kubernetes/ssl/{kubernetes.pem,kubernetes-key.pem,ca.pem} $deploy_path/kubernetes/ssl/
  cp $tplroot/etcd $deploy_path/kubernetes/etcd
  cp $tplroot/systemd/kube-etcd.service $deploy_path/systemd
  # gen etcd config
  cat $deploy_path/kubernetes/etcd \
  |$sedcmd "s|{{ external_ip }}|$host|g" \
  |$sedcmd "s|{{ host-name }}|$host|g" \
  |$sedcmd "s|{{ cluster-groups }}|$etcd_cluster_groups|g" \
  |$sedcmd "s|{{ root }}|$etcd_root_dir|g" \
  |$sedcmd "s|{{ etcd_peer_port }}|$etcd_peer_port|g" \
  |$sedcmd "s|{{ etcd_client_port }}|$etcd_client_port|g" \
  > $deploy_path/kubernetes/etcd.tmp
  mv -f $deploy_path/kubernetes/etcd.tmp $deploy_path/kubernetes/etcd
  cat $deploy_path/systemd/kube-etcd.service \
  |$sedcmd "s|{{ root }}|${etcd_root_dir}|g" \
  > $deploy_path/systemd/kube-etcd.service.tmp
  mv -f $deploy_path/systemd/kube-etcd.service.tmp $deploy_path/systemd/kube-etcd.service
}

gen_master_config() {
  echo "generating master config: $1 $2"
  host=$1
  run_user=$2
  deploy_path="${deployroot}/${host}"
  $mkdir -p $deploy_path/kubernetes/ssl
  $mkdir -p $deploy_path/systemd
  cp $tplroot/{apiserver,controller-manager,scheduler,audit-policy.yaml} $deploy_path/kubernetes/
  cp $confdir/kubernetes/token.csv $deploy_path/kubernetes/
  cp $confdir/kubernetes/ssl/{ca,ca-key,kubernetes,kubernetes-key}.pem $deploy_path/kubernetes/ssl/
  cp $tplroot/systemd/{kube-apiserver,kube-controller-manager,kube-scheduler}.service $deploy_path/systemd/
  cp $tplroot/audit-policy.yaml $deploy_path/kubernetes/
  # gen detail config
  cat $deploy_path/kubernetes/apiserver \
  |$sedcmd "s|{{ apiserver_insecure_port }}|$apiserver_insecure_port|g" \
  |$sedcmd "s|{{ apiserver_secure_port }}|$apiserver_secure_port|g" \
  |$sedcmd "s|{{ kubelet_port }}|$kubelet_port|g" \
  |$sedcmd "s|{{ kubelet_max_pods }}|$kubelet_max_pods|g" \
  |$sedcmd "s|{{ host }}|$host|g" \
  |$sedcmd "s|{{ cluster_serviceip_subnet }}|$cluster_serviceip_subnet|g" \
  |$sedcmd "s|{{ audit-log }}|$audit_log_path|g" \
  |$sedcmd "s|{{ etcd-cluster }}|$etcd_cluster|g" \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  > $deploy_path/kubernetes/apiserver.tmp
  mv -f $deploy_path/kubernetes/apiserver.tmp $deploy_path/kubernetes/apiserver
  cat $deploy_path/systemd/kube-apiserver.service \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  > $deploy_path/systemd/kube-apiserver.service.tmp
  mv -f $deploy_path/systemd/kube-apiserver.service.tmp $deploy_path/systemd/kube-apiserver.service
  cat $deploy_path/kubernetes/controller-manager \
  |$sedcmd "s|{{ apiserver_insecure_port }}|$apiserver_insecure_port|g" \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  |$sedcmd "s|{{ cluster_serviceip_subnet }}|$cluster_serviceip_subnet|g" \
  |$sedcmd "s|{{ cluster_podip_subnet }}|$cluster_podip_subnet|g" \
  |$sedcmd "s|{{ apiserver_insecure_port }}|$apiserver_insecure_port|g" \
  > $deploy_path/kubernetes/controller-manager.tmp
  mv -f $deploy_path/kubernetes/controller-manager.tmp $deploy_path/kubernetes/controller-manager
  cat $deploy_path/systemd/kube-controller-manager.service \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  > $deploy_path/systemd/kube-controller-manager.service.tmp
  mv -f $deploy_path/systemd/kube-controller-manager.service.tmp $deploy_path/systemd/kube-controller-manager.service
  cat $deploy_path/systemd/kube-scheduler.service \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  > $deploy_path/systemd/kube-scheduler.service.tmp
  mv -f $deploy_path/systemd/kube-scheduler.service.tmp $deploy_path/systemd/kube-scheduler.service
  cat $deploy_path/kubernetes/scheduler \
  |$sedcmd "s|{{ apiserver_insecure_port }}|$apiserver_insecure_port|g" \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  |$sedcmd "s|{{ apiserver_insecure_port }}|$apiserver_insecure_port|g" \
  > $deploy_path/kubernetes/scheduler.tmp
  mv -f $deploy_path/kubernetes/scheduler.tmp $deploy_path/kubernetes/scheduler
}

gen_kube_nginx_config() {
  echo "generating kube-nginx config: $1 $2"
  host=$1
  run_user=$2
  deploy_path="${deployroot}/${host}"
  $mkdir -p  $deploy_path/systemd
  cp $tplroot/systemd/kube-nginx.service $deploy_path/systemd
  cp $tplroot/kube-nginx.conf $deploy_path/kube-nginx.conf
  $sedcmd -i -e "s|{{ apiserver_secure_proxy_port }}|$apiserver_secure_proxy_port|g" $deploy_path/kube-nginx.conf
  for ip in $master_hosts; do
    sed -i "/#apiserver_list/a\        server $ip:$apiserver_secure_port max_fails=3 fail_timeout=30s;" $deploy_path/kube-nginx.conf
  done
  cp $deploy_path/kube-nginx.conf $deploy_path/kube-nginx.conf.template
  $sedcmd -i -e "s|{{ root }}|$remote_deploy_root|g" $deploy_path/systemd/kube-nginx.service
}

gen_kube_filebeat_config() {
  $mkdir -p ${deployroot}/kube-filebeat
  cp ${tplroot}/systemd/kube-filebeat.service ${deployroot}/kube-filebeat
  $sedcmd -i -e "s|{{ root }}|$remote_deploy_root|g" -e "s|{{ elastic_cluster }}|$actualESIPs|g" ${deployroot}/kube-filebeat/kube-filebeat.service
}

gen_node_config() {
  echo "generating node config: $1 $2"
  host=$1
  run_user=$2
  deploy_path="${deployroot}/${host}"
  $mkdir -p $deploy_path/kubernetes/ssl
  $mkdir -p $deploy_path/systemd
  cp $confdir/kubernetes/{bootstrap,kube-proxy}.kubeconfig $deploy_path/kubernetes/
  cp $confdir/kubernetes/ssl/ca.pem $deploy_path/kubernetes/ssl/
  cp $tplroot/{kubelet,kube-proxy,kube-proxy.config} $deploy_path/kubernetes/
  cp $tplroot/systemd/{kubelet,kube-proxy}.service $deploy_path/systemd/
  # gen detail config
  cat $deploy_path/kubernetes/kubelet \
  |$sedcmd "s|{{ kubelet_port }}|$kubelet_port|g" \
  |$sedcmd "s|{{ kubelet_max_pods }}|$kubelet_max_pods|g" \
  |$sedcmd "s|{{ kubelet_cadvisor_port }}|$kubelet_cadvisor_port|g" \
  |$sedcmd "s|{{ kubelet_evictionhard_condition }}|$kubelet_evictionhard_condition|g" \
  |$sedcmd "s|{{ kubelet_disallow_swap }}|$kubelet_disallow_swap|g" \
  |$sedcmd "s|{{ kubelet_healthz_port }}|$kubelet_healthz_port|g" \
  |$sedcmd "s|{{ kube_reserved }}|$kube_reserved|g" \
  |$sedcmd "s|{{ system_reserved }}|$system_reserved|g" \
  |$sedcmd "s|{{ image_registry }}|$image_registry|g" \
  |$sedcmd "s|{{ cluster_serviceip_subnet }}|$cluster_serviceip_subnet|g" \
  |$sedcmd "s|{{ kubelet_root_dir }}|$kubelet_root_dir|g" \
  |$sedcmd "s|{{ kubelet_pod_manifest }}|$kubelet_pod_manifest|g" \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  |$sedcmd "s|{{ kubelet_node_allocatable }}|$kubelet_node_allocatable|g" \
  |$sedcmd "s|{{ host }}|$host|g" \
  |$sedcmd "s|{{ kubelet_resolv_path }}|$kubelet_resolv_path|g" \
  |$sedcmd "s|{{ home_dir }}|$home_dir|g" \
  > $deploy_path/kubernetes/kubelet.tmp
  mv -f $deploy_path/kubernetes/kubelet.tmp $deploy_path/kubernetes/kubelet
  cat $deploy_path/systemd/kubelet.service \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  |$sedcmd "s|{{ kubelet_root_dir }}|$kubelet_root_dir|g" \
  > $deploy_path/systemd/kubelet.service.tmp
  mv -f $deploy_path/systemd/kubelet.service.tmp $deploy_path/systemd/kubelet.service
  cat $deploy_path/kubernetes/kube-proxy \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  > $deploy_path/kubernetes/kube-proxy.tmp
  mv -f $deploy_path/kubernetes/kube-proxy.tmp $deploy_path/kubernetes/kube-proxy
  cat $deploy_path/kubernetes/kube-proxy.config \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  |$sedcmd "s|{{ kubeproxy_healthz_port }}|$kubeproxy_healthz_port|g" \
  |$sedcmd "s|{{ cluster_podip_subnet }}|$cluster_podip_subnet|g" \
  |$sedcmd "s|{{ host }}|$host|g" \
  > $deploy_path/kubernetes/kube-proxy.config.tmp
  mv -f $deploy_path/kubernetes/kube-proxy.config.tmp $deploy_path/kubernetes/kube-proxy.config
  cat $deploy_path/systemd/kube-proxy.service \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  > $deploy_path/systemd/kube-proxy.service.tmp
  mv -f $deploy_path/systemd/kube-proxy.service.tmp $deploy_path/systemd/kube-proxy.service
  echo -e "$kubelet_resolv_conf" \
  > $deploy_path/kubernetes/resolv.conf.tmp
  mv -f $deploy_path/kubernetes/resolv.conf.tmp $deploy_path/kubernetes/resolv.conf
}

gen_flanneld_config() {
  echo "generating flanneld config: $1 $2"
  host=$1
  run_user=$2
  deploy_path="${deployroot}/${host}"
  $mkdir -p $deploy_path/kubernetes/ssl
  $mkdir -p $deploy_path/systemd

  if [ ! -f $confdir/kubernetes/ssl/flanneld-${host}.pem ]; then
    gen_flanneld_ssl $host
  fi
  cp $confdir/kubernetes/ssl/flanneld-${host}.pem $deploy_path/kubernetes/ssl/flanneld.pem
  cp $confdir/kubernetes/ssl/flanneld-${host}-key.pem $deploy_path/kubernetes/ssl/flanneld-key.pem
  cp $confdir/kubernetes/ssl/ca.pem $deploy_path/kubernetes/ssl/
  cp $tplroot/flanneld $deploy_path/kubernetes/
  cp $tplroot/systemd/flanneld.service $deploy_path/systemd/

  $sedcmd -i -e "s|{{ etcd-cluster }}|$etcd_cluster|g" $deploy_path/kubernetes/flanneld
  cp $deploy_path/kubernetes/flanneld $deploy_path/kubernetes/flanneld.template
  $sedcmd -i -e "s|{{ root }}|$remote_deploy_root|g" $deploy_path/kubernetes/flanneld

  cat $deploy_path/systemd/flanneld.service \
  |$sedcmd "s|{{ root }}|$remote_deploy_root|g" \
  > $deploy_path/systemd/flanneld.service.tmp
  mv -f $deploy_path/systemd/flanneld.service.tmp $deploy_path/systemd/flanneld.service
}

gen_journald_config() {
  echo "generating journald config: $1 $2"
  host=$1
  run_user=$2
  deploy_path="${deployroot}/${host}"
  $mkdir -p $deploy_path
  cp ${tplroot}/99-prophet.conf  $deploy_path/
  $sedcmd -i -e "s|{{ journald_max_disk_size }}|$journald_max_disk_size|g" $deploy_path/99-prophet.conf
  $sedcmd -i -e "s|{{ journald_max_file_size }}|$journald_max_file_size|g" $deploy_path/99-prophet.conf
  $sedcmd -i -e "s|{{ journald_retention_period }}|$journald_retention_period|g" $deploy_path/99-prophet.conf
  $sedcmd -i -e "s|{{ journald_forward_syslog }}|$journald_forward_syslog|g" $deploy_path/99-prophet.conf
}

# ------------------------------
# deploy
# ------------------------------

deploy_docker() {
  echo "deploy docker to $1"
  host=$1
  deploy_path="${deployroot}/${host}"
  detect_deploy $deploy_path
  $ssh root@$host "$mkdir -p /etc/sysconfig $remote_deploy_root/tmp/docker $docker_root_dir"
  $scp ${bindir}/docker/* root@$host:$remote_deploy_root/tmp/docker/
  $scp $deploy_path/docker.service root@$host:/usr/lib/systemd/system/docker.service
  $scp $deploy_path/docker root@$host:/etc/sysconfig/docker
  $ssh root@$host "mv $remote_deploy_root/tmp/docker/* /usr/bin/"
  $ssh root@$host "systemctl daemon-reload && systemctl restart docker"
  $ssh root@$host "systemctl disable docker && systemctl enable docker"
  echo "wait 1 second"
  sleep 1
  $ssh root@$host "docker ps"
}

deploy_etcd() {
  echo "deploy etcd to $1 $2"
  host=$1
  user=$2
  deploy_path="${deployroot}/${host}"
  detect_deploy $deploy_path
  $ssh root@$host "$mkdir -p ${etcd_root_dir}/{bin,lib/etcd,etc/kubernetes/ssl,tmp}"
  $scp -r ${deploy_path}/kubernetes/etcd root@$host:${etcd_root_dir}/etc/kubernetes/
  $scp -r ${deploy_path}/kubernetes/ssl/{kubernetes.pem,kubernetes-key.pem,ca.pem} root@$host:${etcd_root_dir}/etc/kubernetes/ssl/
  $scp -r ${deploy_path}/systemd/kube-etcd.service root@$host:/usr/lib/systemd/system/
  $scp -r ${bindir}/etcd root@$host:${etcd_root_dir}/tmp
  $ssh root@$host "mv ${etcd_root_dir}/tmp/etcd ${etcd_root_dir}/bin && chmod +x ${etcd_root_dir}/bin/*"
  $ssh root@$host "systemctl daemon-reload"
  $ssh root@$host "systemctl restart kube-etcd &"
  $ssh root@$host "systemctl disable kube-etcd && systemctl enable kube-etcd"
}

deploy_flanneld() {
  echo "deploy flanneld to $1"
  host=$1
  deploy_path="${deployroot}/${host}"
  detect_deploy $deploy_path
  $ssh root@$host "$mkdir -p $remote_deploy_root/{bin,etc/kubernetes/ssl,tmp}"
  $scp -r ${deploy_path}/kubernetes/ssl/*.pem root@$host:$remote_deploy_root/etc/kubernetes/ssl/
  $scp -r ${deploy_path}/kubernetes/flanneld* root@$host:$remote_deploy_root/etc/kubernetes/
  $scp -r ${deploy_path}/systemd/flanneld.service root@$host:/usr/lib/systemd/system/
  $scp -r ${bindir}/{flanneld,mk-docker-opts.sh} root@$host:$remote_deploy_root/tmp
  $ssh root@$host "mv $remote_deploy_root/tmp/{flanneld,mk-docker-opts.sh} $remote_deploy_root/bin && chmod +x $remote_deploy_root/bin/*"
  $ssh root@$host "systemctl daemon-reload && systemctl restart flanneld"
  $ssh root@$host "systemctl disable flanneld && systemctl enable flanneld"
}

deploy_kube_nginx() {
  echo "deploy kube-nginx to $1"
  host=$1
  deploy_path="${deployroot}/${host}"
  detect_deploy $deploy_path
  $ssh root@$host "$mkdir -p $remote_deploy_root/kube-nginx/{sbin,conf,logs,tmp}"
  $scp -r ${deploy_path}/kube-nginx.conf* root@$host:$remote_deploy_root/kube-nginx/conf
  $scp -r $deploy_path/systemd/kube-nginx.service root@$host:/usr/lib/systemd/system/
  $scp -r ${bindir}/nginx root@$host:$remote_deploy_root/kube-nginx/tmp
  $ssh root@$host "mv $remote_deploy_root/kube-nginx/tmp/nginx $remote_deploy_root/kube-nginx/sbin && chmod +x $remote_deploy_root/kube-nginx/sbin/*"
  $ssh root@$host "systemctl daemon-reload && systemctl restart kube-nginx"
  $ssh root@$host "systemctl disable kube-nginx && systemctl enable kube-nginx"
}

deploy_kube_filebeat() {
  echo "deploy kube-filebeat to $1"
  # uniq hosts
  local host=$1

  $scp ${deployroot}/kube-filebeat/kube-filebeat.service root@${host}:/usr/lib/systemd/system/
  $ssh root@${host} "$mkdir -p ${remote_deploy_root}"
  # http://jira.4paradigm.com/browse/PHTEE-7040
  for file in $(ls ${bindir}/kube-filebeat/inputs.d/*.tmp); do
    cat $file | sed "s|{{ host }}|$host|g" > ${file%.tmp}
  done
  $scp -r ${bindir}/kube-filebeat root@${host}:${remote_deploy_root}/
  $ssh root@${host} "chmod +x ${remote_deploy_root}/kube-filebeat/kube-filebeat"
  $ssh root@${host} "$mkdir -p /var/lib/docker /var/lib/kubelet"
  $ssh root@${host} "ln -sf ${remote_deploy_root}/lib/kubelet/pods  /var/lib/kubelet/pods"
  $ssh root@${host} "[[ "${docker_root_dir}/containers" == "/var/lib/docker/containers" ]] || ln -sf ${docker_root_dir}/containers /var/lib/docker/containers"
  $ssh root@${host} "systemctl daemon-reload && systemctl restart kube-filebeat"
  $ssh root@${host} "systemctl disable kube-filebeat && systemctl enable kube-filebeat"
}

remove_kube_filebeat() {
  local host=$1
  $ssh root@${host} "systemctl stop kube-filebeat; systemctl disable kube-filebeat" || :
  $ssh root@${host} "rm -f /var/lib/kubelet/pods || :"
  $ssh root@${host} "[[ "${docker_root_dir}/containers" == "/var/lib/docker/containers" ]] || rm -rf /var/lib/docker"
  $ssh root@${host} "rm -rf /usr/lib/systemd/system/kube-filebeat.service ${remote_deploy_root}/kube-filebeat"
  $ssh root@${host} "systemctl daemon-reload; systemctl restart kubelet"
}

deploy_journald() {
  echo "deploy journald to $1"
  host=$1
  deploy_path="${deployroot}/${host}"
  detect_deploy $deploy_path

  $ssh root@$host "$mkdir -p /var/log/journal /etc/systemd/journald.conf.d $remote_deploy_root/etc"
  $scp $deploy_path/99-prophet.conf root@${host}:/etc/systemd/journald.conf.d
  $scp $deploy_path/99-prophet.conf root@${host}:$remote_deploy_root/etc
  $ssh root@${host} "systemctl restart systemd-journald"
}

set_pod_cidr() {
  $etcdctl \
  --ca-file=${confdir}/kubernetes/ssl/ca.pem \
  --cert-file=${confdir}/kubernetes/ssl/kubernetes.pem \
  --key-file=${confdir}/kubernetes/ssl/kubernetes-key.pem \
  --endpoints="${etcd_cluster}" \
  set /kubernetes/network/config '{"Network":"'${cluster_podip_subnet}.0.0/16'", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}'
}

deploy_cfssl() {
  echo "deploy cfssl to $1 $2"
  host=$1
  user=$2
  $ssh $user@$host "$mkdir -p $remote_deploy_root/{bin,etc/kubernetes/ssl}"
  $scp $sslcmd $jsoncmd root@$host:$remote_deploy_root/bin
  # $scp ca.pem、ca-key.pem、ca-config.json
  $scp ${confdir}/kubernetes/ssl/ca* root@$host:$remote_deploy_root/etc/kubernetes/ssl
  $ssh root@$host "chmod a+x $remote_deploy_root/bin/*"
}

gen_pht_tool_config() {
  if [ x"${deploy_pht_tools}" != "xtrue" ]; then
    echo "deploy_pht_tools is not true, skip gen pht_tool config"
    return
  fi
  echo "generating pht tool config: $1 $2"
  host=$1
  run_user=$2
  deploy_path="${deployroot}/${host}"
  $mkdir -p $deploy_path/pht/
  $mkdir -p $deploy_path/systemd/
  ${CWD}/bin/pht genpass --usr ${pht_tool_username} --pwd ${pht_tool_password} --db $deploy_path/pht/.pht.db

  cp $tplroot/systemd/pht.service $deploy_path/systemd/
  cp $tplroot/pht.yaml $deploy_path/pht/

  $sedcmd -i -e "s|{{ root }}|$pht_remote_root|g" $deploy_path/systemd/pht.service
  $sedcmd -i -e "s|{{ root }}|$pht_remote_root|g" $deploy_path/pht/pht.yaml
}

deploy_pht_tool() {
  if [ x"${deploy_pht_tools}" != "xtrue" ]; then
    echo "deploy_pht_tools is not true, skip deploy pht_tool"
    return
  fi
  host=$1
  user=$2
  deploy_path="${deployroot}/${host}"
  $ssh $user@$host "$mkdir -p $pht_remote_root/{tmp,log,etc,data,bin}"
  $scp ${CWD}/bin/pht $user@$host:$pht_remote_root/tmp/
  $ssh $user@$host "mv $pht_remote_root/tmp/pht $pht_remote_root/bin/"
  $scp ${deploy_path}/systemd/pht.service $user@$host:/usr/lib/systemd/system/
  $scp ${deploy_path}/pht/pht.yaml $user@$host:$pht_remote_root/etc/
  $scp ${deploy_path}/pht/.pht.db $user@$host:$pht_remote_root/data/
  $ssh $user@$host "systemctl daemon-reload && systemctl restart pht"
  $ssh $user@$host "systemctl disable pht && systemctl enable pht"
}

add_pht_tools() {
  hostArray=($(printf "%q\n" $node_hosts $master_hosts $etcd_hosts | sort -u))
  for((i=0; i<${#hostArray[@]}; i++)); do
    host=${hostArray[$i]}
    gen_pht_tool_config $host root
    deploy_pht_tool $host root
  done
}

deploy_master() {
  echo "deploy master component to $1 $2"
  host=$1
  user=$2
  deploy_path="${deployroot}/${host}"
  detect_deploy $deploy_path
  $ssh $user@$host "$mkdir -p $remote_deploy_root/{bin,lib,log,etc/kubernetes/ssl,tmp}"
  $scp -r ${deploy_path}/kubernetes/{token.csv,apiserver,controller-manager,scheduler,audit-policy.yaml} root@$host:$remote_deploy_root/etc/kubernetes/
  $scp -r ${deploy_path}/kubernetes/ssl/{ca,ca-key,kubernetes,kubernetes-key}.pem root@$host:$remote_deploy_root/etc/kubernetes/ssl/
  $scp -r ${deploy_path}/systemd/{kube-apiserver,kube-controller-manager,kube-scheduler}.service root@$host:/usr/lib/systemd/system/

  $scp -r ${bindir}/{kube-apiserver,kube-controller-manager,kube-scheduler} root@$host:$remote_deploy_root/tmp
  $ssh root@$host "mv $remote_deploy_root/tmp/{kube-apiserver,kube-controller-manager,kube-scheduler} $remote_deploy_root/bin && chmod +x $remote_deploy_root/bin/*"
  $ssh root@$host "systemctl daemon-reload && systemctl restart kube-apiserver && systemctl restart kube-controller-manager && systemctl restart kube-scheduler"
  $ssh root@$host "systemctl disable kube-apiserver kube-controller-manager kube-scheduler"
  $ssh root@$host "systemctl enable kube-apiserver kube-controller-manager kube-scheduler"
}

deploy_node() {
  echo "deploy node component to $1 $2"
  host=$1
  user=$2
  deploy_path="${deployroot}/${host}"
  detect_deploy $deploy_path
  #$ssh root@$host "yum install -y docker"
  $ssh $user@$host "$mkdir -p $kubelet_root_dir $remote_deploy_root/{bin,lib/kubelet,log/pods,log/containers,etc/kubernetes/ssl,tmp}"
  $scp -r ${deploy_path}/kubernetes/{bootstrap.kubeconfig,kubelet,kube-proxy.kubeconfig,kube-proxy,resolv.conf,kube-proxy.config} root@$host:$remote_deploy_root/etc/kubernetes/
  $scp -r ${deploy_path}/kubernetes/ssl/ca.pem root@$host:$remote_deploy_root/etc/kubernetes/ssl/
  $scp -r ${deploy_path}/systemd/{kubelet,kube-proxy}.service root@$host:/usr/lib/systemd/system/
  $scp -r ${bindir}/{kubelet,kube-proxy} root@$host:$remote_deploy_root/tmp/
  $scp -r ${bindir}/conntrack root@$host:/bin
  $scp -r $imageroot/node.tar root@$host:$remote_deploy_root/tmp/
  $ssh root@$host "mv $remote_deploy_root/tmp/kube* $remote_deploy_root/bin/"
  $ssh root@$host "docker load -i $remote_deploy_root/tmp/node.tar; docker tag docker02:35000/gcr.io/google-containers/pause-amd64:3.1 $image_registry/gcr.io/google-containers/pause-amd64:3.1;"
  $ssh root@$host "systemctl daemon-reload && systemctl restart kube-proxy && systemctl restart kubelet"
  $ssh root@$host "systemctl disable kube-proxy kubelet && systemctl enable kube-proxy kubelet"
}

# ------------------------------
# setup
# ------------------------------

setup() {
  detect_conf
  # gen kube ssl and config
  gen_ssl
  gen_token
  gen_bootstrap
  gen_kubeproxy
  gen_kubectl
  gen_kube_filebeat_config

  # gen systemd script and config
  for host in $etcd_hosts ; do
    gen_etcd_config $host $run_user
    gen_pht_tool_config $host $run_user
  done

  for host in $master_hosts; do
    gen_journald_config $host $run_user
    gen_flanneld_config $host $run_user
    gen_master_config $host $run_user
    gen_pht_tool_config $host $run_user
  done

  setup_nodes
}

setup_nodes() {
  for host in $node_hosts; do
    gen_journald_config $host $run_user
    gen_flanneld_config $host $run_user
    gen_kube_nginx_config $host $run_user
    gen_docker_config $host $run_user
    gen_node_config $host $run_user
    gen_pht_tool_config $host $run_user
  done
}

deploy_one_etcd() {
  host=$1
  run_user=$2
  deploy_etcd $host $run_user
  deploy_pht_tool $host $run_user
}

deploy_etcds() {
  for host in $etcd_hosts; do
    deploy_one_etcd $host $run_user
  done
}

deploy_one_master() {
  host=$1
  run_user=$2
  deploy_cfssl $host $run_user
  deploy_journald $host
  deploy_flanneld $host
  deploy_master $host $run_user
  deploy_pht_tool $host $run_user
}

deploy_masters() {
  set_pod_cidr
  for host in $master_hosts; do
    deploy_one_master $host $run_user
  done
}

check_nodes() {
  source ${PWD}/lib.sh
  for host in $node_hosts; do
    detectFS $host $run_user
  done

  for host in $(for h in $node_hosts $master_hosts $etcd_hosts; do echo $h; done | sort | uniq)
  do
    stopFirewalldSelinux $host $run_user
    otherDirectChange $host $run_user
  done
}

deploy_one_node() {
  host=$1
  source ${PWD}/lib.sh
  detectSwap $host $run_user
  detectForward $host $run_user
  init_config_arp $host $run_user
  detectPortRange $host $run_user
  #preCheckDockerEnv $host $run_user # just comment this line code, it is not necessary, just backup if need  can uncomment

  deploy_cfssl $host $run_user
  deploy_journald $host
  deploy_kube_nginx $host $run_user
  deploy_flanneld $host
  deploy_docker $host $run_user
  deploy_node $host $run_user
  deploy_kube_filebeat $host
  deploy_pht_tool $host $run_user
  echo "waiting 5 seconds for nodes to run"
  csrnode $host
}

deploy_nodes() {
  for host in $node_hosts; do
    for gpu_host in $nvidia_gpu_hosts; do
      if [ x"${host}" == x"${gpu_host}" ]; then
        $ssh root@${host} "$mkdir -p ${deployroot}/"
        $scp "${CWD}/extra-tools/enable_nvidia_gpu.sh"  root@${host}:/"${deployroot}/"
        $scp "${CWD}/tools/generate_cuda_files.sh" root@${host}:/"${deployroot}/"
        $ssh root@${host} "bash -x ${deployroot}/enable_nvidia_gpu.sh" || :
        $ssh root@${host} "bash -x ${deployroot}/generate_cuda_files.sh" || :
      fi
    done
        deploy_one_node $host $run_user
  done
}

deploy_kube_filebeats() {
  gen_kube_filebeat_config
  for host in $node_hosts; do
    deploy_kube_filebeat $host
  done
}

remove_kube_filebeats() {
  for host in $node_hosts; do
    remove_kube_filebeat $host
  done
}

function detectFS() {
    local host=$1
    local user=$2
    $ssh ${user}@${host} "$mkdir -p ${docker_root_dir}" || :
    $ssh ${user}@${host} "$mkdir -p ${remote_deploy_root}" || :
    local result_docker=($($ssh ${user}@${host} "df -Tm ${docker_root_dir} | sed '1d'"))
    local result_k8s=($($ssh ${user}@${host} "df -Tm ${remote_deploy_root} | sed '1d'"))
    echo ${result_docker[1]} | grep -q ext4 || { red_echo "docker filesystem ${docker_root_dir} on ${host} must be ext4 [df -Tm ${docker_root_dir}]" && exit 1; }
    echo ${result_k8s[1]} | grep -q ext4 || { red_echo "k8s filesystem ${remote_deploy_root} on ${host} must be ext4 [df -Tm ${remote_deploy_root}]" && exit 1; }
    if [[ "${result_docker[0]}" == "${result_k8s[0]}" ]]; then
        if [ "${result_docker[4]}" -lt 102400 ]; then
          red_echo "${host} ${docker_root_dir} ${remote_deploy_root} less than 100G"
          exit 1
        fi
    else
        if [ "${result_docker[4]}" -lt 51200 ]; then
          red_echo "${docker_root_dir} less than 50G"
          exit 1
        fi
        if [ "${result_k8s[4]}" -lt 51200 ]; then
          red_echo "${host} ${docker_k8s} less than 50G"
          exit 1
        fi
    fi
}

deploy() {
  # deploy
  deploy_etcds
  deploy_masters
  echo "waiting 5 seconds for master to run"
  sleep 5
  $kubectl create clusterrolebinding kubelet-bootstrap \
    --clusterrole=system:node-bootstrapper \
    --user=kubelet-bootstrap
  deploy_nodes
  echo "waiting 5 seconds for nodes to run"
  sleep 5
}

validate() {
  # etcd
  echo "check etcd state:"
  $etcdctl \
    --ca-file=${confdir}/kubernetes/ssl/ca.pem \
    --cert-file=${confdir}/kubernetes/ssl/kubernetes.pem \
    --key-file=${confdir}/kubernetes/ssl/kubernetes-key.pem \
    --endpoints="${etcd_cluster}" \
    cluster-health

  # master
  echo "check k8s master components:"
  $kubectl get componentstatuses
  # nodes csr
  echo "check k8s node csr request:"
  $kubectl get csr
  echo "you can run: ${kubectl} certificate approve [csrname] to add node"
  echo "after that, you can run ${kubectl} get nodes to see current active nodes"
  $kubectl get nodes
}

csr() {
  wait_ok $KUBE_APISERVER
  case "$1" in
    'list')
      $kubectl get csr
      ;;
    'all')
      csrs=$($kubectl get csr|grep Pending|awk '{print $1}')
      while [ x"${csrs}" == "x" ]; do
        sleep 1
        csrs=$($kubectl get csr|grep Pending|awk '{print $1}')
      done
      $kubectl get csr|grep Pending|awk '{print $1}'|xargs -r $kubectl certificate approve
      ;;
    *)
      $kubectl certificate approve $1 || :
      ;;
  esac
}

registry() {
  case "$1" in
    'meta')
      if [ "$registry_meta_alone" == "true" ]; then
        for host in $registry_meta_hosts; do
          $ssh ${user}@$host "$mkdir -p $registry_meta_hostpath"
          ostype=$($ssh -T ${user}@${host} 'uname -s')
          $scp ${CWD}/tools/fileserver-${ostype} ${user}@$host:$registry_meta_hostpath
          $ssh ${user}@${host} "chmod +x ${registry_meta_hostpath}/fileserver-${ostype}"
          $ssh -f ${user}@$host "${registry_meta_hostpath}/fileserver-${ostype} -addr 0.0.0.0:${registry_meta_port} -dir ${registry_meta_hostpath} 1>/dev/null 2>/dev/null &"
        done
        return
      fi;

      for host in $registry_meta_hosts; do
        echo "deploying meta registry to host $host"
        deploy_path="${deployroot}/${host}"
        $mkdir -p $deploy_path/addon/registry
        cp $tplroot/addon/registry/meta.yaml $deploy_path/addon/registry
        # gen detail config
        cat $deploy_path/addon/registry/meta.yaml \
        |$sedcmd "s|{{ registry_meta_port }}|$registry_meta_port|g" \
        |$sedcmd "s|{{ registry_meta_hostpath }}|$registry_meta_hostpath|g" \
        |$sedcmd "s|{{ image_registry }}|$image_registry|g" \
        > $deploy_path/addon/registry/meta.yaml.tmp
        mv -f $deploy_path/addon/registry/meta.yaml.tmp $deploy_path/addon/registry/meta.yaml
        $ssh ${user}@$host "$mkdir -p $kubelet_pod_manifest $registry_meta_hostpath $remote_deploy_root/tmp"
        $scp -r ${deploy_path}/addon/registry/meta.yaml ${user}@$host:$kubelet_pod_manifest
        $scp -r $imageroot/registry.tar ${user}@$host:$remote_deploy_root/tmp
        $ssh ${user}@$host "docker load -i $remote_deploy_root/tmp/registry.tar; \
          docker tag nginx $image_registry/nginx; systemctl restart kubelet;"
      done
      echo "resitry meta done"
      ;;
    'docker')
      for host in $registry_docker_hosts; do
        echo "deploying docker registry to host $host"
        deploy_path="${deployroot}/${host}"
        $mkdir -p $deploy_path/addon/registry
        cp $tplroot/addon/registry/docker.yaml $deploy_path/addon/registry
        # gen detail config
        cat $deploy_path/addon/registry/docker.yaml \
        |$sedcmd "s|{{ registry_docker_port }}|$registry_docker_port|g" \
        |$sedcmd "s|{{ registry_docker_hostpath }}|$registry_docker_hostpath|g" \
        |$sedcmd "s|{{ image_registry }}|$image_registry|g" \
        |$sedcmd "s|{{ registry_docker_user }}|$registry_docker_user|g" \
        |$sedcmd "s|{{ registry_docker_password }}|$registry_docker_password|g" \
        > $deploy_path/addon/registry/docker.yaml.tmp
        mv -f $deploy_path/addon/registry/docker.yaml.tmp $deploy_path/addon/registry/docker.yaml
        $ssh root@$host "$mkdir -p $kubelet_pod_manifest $registry_docker_hostpath $remote_deploy_root/tmp"
        $scp -r ${deploy_path}/addon/registry/docker.yaml root@$host:$kubelet_pod_manifest
        $scp -r $imageroot/registry.tar root@$host:$remote_deploy_root/tmp
        $ssh root@$host "docker load -i $remote_deploy_root/tmp/registry.tar; \
        docker tag registry:2 $image_registry/registry:2; systemctl restart kubelet;"
      done
      echo "registry docker done"
      ;;
    'all')
      registry meta
      registry docker
      ;;
    *)
      echo "you must specify an argument for registry, it can be meta|docker|all"
      ;;
  esac
}

csrnode() {
  wait_ok $KUBE_APISERVER
  set +e

  new_req=`$kubectl get csr --no-headers | awk '{print $4}' | grep -i  "Pending"`
  while [ x"$new_req" == "x" ]; do
    echo "wait new pending csr request"
    sleep 1
    new_req=`$kubectl get csr --no-headers | awk '{print $4}' | grep -i  "Pending"`
  done
  set -e
  host=$1
  echo "allowing csr for node $host"
  for i in `$kubectl get csr --no-headers|awk '{print $1}'`; do
    $kubectl describe csr $i|grep "system:node:$host" && $kubectl certificate approve $i
  done
  echo "run csrnode done"
}

docker_login() {
  wait_ok $image_registry
  for host in $node_hosts; do
    $ssh root@${host} "HOME=${home_dir} docker login $image_registry -u $registry_docker_user -p $registry_docker_password"
    $ssh root@${host} "systemctl restart kubelet"
  done
}

case "$1" in
    'docker_kubernetes')
        check_nodes
        setup
        deploy
        csr all
        registry docker
        echo "wait 60 for k8s component running"
        sleep 60
        docker_login
        validate
        ;;
    'config')
        case "$2" in
            'node')
                setup_nodes
                ;;
            *)
                setup
                ;;
            esac
        ;;
    'deploy')
        case "$2" in
            'master')
                deploy_masters
                ;;
            'node')
                deploy_nodes
                ;;
            'etcd')
                deploy_etcds
                ;;
            'registry')
                registry all
                ;;
            'filebeat')
                deploy_kube_filebeats
                ;;
            *)
                deploy
                csr all
                registry all
                validate
                ;;
            esac
        ;;
    'remove')
      case "$2" in
        'filebeat')
          remove_kube_filebeats
          ;;
      esac
      ;;
    'validate')
        validate
        ;;
    'csr')
        csr $2
        ;;
    'csrnode')
        csrnode $2
        ;;
    'registry')
        registry $2
        ;;
    *)
        $@
        ;;
    esac
# case end
