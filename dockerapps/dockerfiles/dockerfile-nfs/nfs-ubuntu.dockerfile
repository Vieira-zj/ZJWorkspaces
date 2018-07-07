FROM ubuntu:14.04

# Created at 2018-06-23, nfs-ubuntu-build
MAINTAINER zivieira@163.com

# Step1, pre-build
RUN apt-get update && apt-get -y install flex bison uuid-dev cmake g++ libcurl4-openssl-dev git

# Step2, build
ADD git-repo/nfs-ganesha /home/nfs-ganesha
ADD git-repo/ganesha-build.sh /home/ganesha-build.sh

#RUN cd /home/nfs-ganesha && git submodule update --init \ 
# && mkdir target && cd target \ 
# && cmake -DCMAKE_BUILD_TYPE=Release  -DBUILD_CONFIG=kfile_only ../src/ && make \
# && cd - && ./build/package.sh target 


CMD sh /home/ganesha-build.sh;tail -f

