FROM ubuntu:18.04

LABEL maintainer="zivieira@163.com"

# Desc:
# 1. less RUN, less layers, and less image space.
# 2. put unchanged files in lower layer for docker build cache.
#
# Run command:
# docker run --name goci -it --rm -v ${HOME}/Workspaces/golang/goc:/root/go/goc golang-ci:v1.0.4 bash
#

# set timezone
ENV TZ=Asia/Shanghai
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

# install utils
RUN apt-get update && apt-get install -y apt-utils \
    && apt-get install -y git vim wget ssh curl \
    bzip2 ca-certificates sudo locales gcc python3.7 python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# set python env
RUN ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && pip install -i https://pypi.garenanow.com/ diff-cover

# create golang env
# available go versions: go1.12.5, go1.13.5, go1.14.9. default: go1.14.13
ENV GO_VERSION=go1.14.13
RUN cd /tmp && curl -O https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz \
    && tar xvf ${GO_VERSION}.linux-amd64.tar.gz \
    && sudo chown -R root:root ./go && mv go /usr/lib/${GO_VERSION} \
    && ln -s /usr/lib/${GO_VERSION} /usr/lib/go \
    && ln -s /usr/lib/${GO_VERSION}/bin/go /usr/bin/go \
    && rm -r /tmp/*

ENV GOPATH=/root/go
ENV GOROOT=/usr/lib/go

# add tools bin
COPY bin /usr/local/bin

CMD while true; do echo "[$(date +'%Y-%m-%d_%H:%M:%S')]: golang-ci is running ..."; sleep 5; done;
