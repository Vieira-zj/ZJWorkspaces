#!/bin/bash
set -ex

nfs_home="/home/qboxserver/nfs/_package"
nfs_bin="${nfs_home}/ganesha"

# clear
ps aux | grep "gane" | grep -v "grep" | awk '{print $2}' | xargs kill -9
rm -rf ${nfs_home}/ganesha/

# prepare
tar xzvf ${nfs_home}/ganesha.debug.tar.gz -C ${nfs_home}
cp ${nfs_home}/ganesha.conf ${nfs_home}/ganesha

# install
echo installing ganesha ...
mkdir -p /etc/ganesha
echo cp /ganesha.conf /etc/ganesha
cp ${nfs_bin}/ganesha.conf /etc/ganesha
mkdir -p /usr/lib/ganesha
echo cp libfsalkfile.so /usr/lib/ganesha
cp ${nfs_bin}/libfsalkfile.so /usr/lib/ganesha
echo cp libntirpc.so.1.6 /usr/lib
cp ${nfs_bin}/libntirpc.so.1.6 /usr/lib
echo cp ganesha.nfsd /usr/bin
cp ${nfs_bin}/ganesha.nfsd /usr/bin
echo ganesha installed, you may sudo ganesha.nfsd to start

# run
ganesha.nfsd

set +ex

