FROM nfs-build 

# Created at 2018-06-05, nfs-run
MAINTAINER zivieira@163.com

# Step1, pre-build
#RUN apt-get update && apt-get install -y git build-essential gcc g++ autoconf libtool libcurl4-openssl-dev flex bison wget cmake-curses-gui uuid-dev \
# && apt-get -y install software-properties-common \
# && add-apt-repository ppa:ubuntu-toolchain-r/test \
# && apt-get update \
# && apt-get -y install gcc-5 g++-5 cmake3 \
# && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 1 --slave /usr/bin/g++ g++ /usr/bin/g++-5 \
# && apt install -y rpcbind

# Step2, build
#ADD git-repo/nfs-ganesha /home/nfs

#RUN cd /home/nfs && git submodule update --init --recursive \
# && rm -rf build && mkdir build && cd build \
# && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_CONFIG=kfile_only ../src/ && sudo make install 

# Step3, conf and run
RUN cp /home/nfs/ganesha.conf /etc/ganesha/ \
 && mkdir -p /var/lib/nfs/ganesha


CMD rpcbind && ganesha.nfsd -f /etc/ganesha/ganesha.conf && while true; do echo 'hello'; sleep 2; done;

