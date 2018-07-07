FROM ansible/ubuntu14.04-ansible

# Created at 2018-06-05, nfs-prebuild
MAINTAINER zivieira@163.com

# Step1, pre-build
RUN apt-get update && apt-get install -y git build-essential gcc g++ autoconf libtool libcurl4-openssl-dev flex bison wget cmake-curses-gui uuid-dev \
 && apt-get -y install software-properties-common \
 && add-apt-repository ppa:ubuntu-toolchain-r/test \
 && apt-get update \
 && apt-get -y install gcc-5 g++-5 cmake3 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 1 --slave /usr/bin/g++ g++ /usr/bin/g++-5 \
 && apt install -y rpcbind

# Step2, build
# ADD git-repo/nfs-ganesha /home/nfs


CMD while true; do echo 'hello'; sleep 2; done;

