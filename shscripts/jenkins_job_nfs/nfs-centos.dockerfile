FROM centos:7.2.1511 

MAINTAINER zhengjin@qiniu.com

# step1: pre-build
RUN yum -y update && yum -y install flex bison uuid-devel libuuid-devel cmake automake make gcc-c++ openssl-dev git curl libcurl-devel 

# step2: add src
ADD nfs-ganesha /home/nfs-ganesha
ADD deploy-test/floy/nfs/ganesha-build.sh /home/ganesha-build.sh

# step3: build and package
CMD sh /home/ganesha-build.sh;ls /home/nfs-ganesha;cp /home/nfs-ganesha/ganesha.tar.gz /home/build_out
