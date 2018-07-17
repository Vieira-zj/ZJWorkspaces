FROM ubuntu:14.04

MAINTAINER zhengjin@qiniu.com

# step1: pre-build
RUN apt-get update && apt-get -y install flex bison uuid-dev cmake g++ libcurl4-openssl-dev git \
 && mkdir /home/build_out

# step2: add src
ADD nfs-ganesha /home/nfs-ganesha
ADD deploy-test/floy/nfs/ganesha-build.sh /home/ganesha-build.sh

# step3: build and package
CMD sh /home/ganesha-build.sh;ls /home/nfs-ganesha;cp /home/nfs-ganesha/ganesha.tar.gz /home/build_out
