FROM centos:7.2.1511 

# Created at 2018-06-23, nfs-centos-build
MAINTAINER zivieira@163.com

# Step1, pre-build
RUN yum -y update && yum -y install flex bison uuid-devel libuuid-devel cmake automake make gcc-c++ openssl-dev git curl libcurl-devel 

# Step2, build
ADD git-repo/nfs-ganesha /home/nfs-ganesha
ADD git-repo/ganesha-build.sh /home/ganesha-build.sh

#RUN cd /home/nfs-ganesha && git submodule update --init \ 
# && mkdir target && cd target \ 
# && cmake -DCMAKE_BUILD_TYPE=Release  -DBUILD_CONFIG=kfile_only ../src/ && make \
# && cd - && ./build/package.sh target 


CMD sh /home/ganesha-build.sh;tail -f

