FROM ubuntu:trusty

LABEL maintainer="zhengjin@qiniu.com"

# dependency 
RUN apt-get clean && apt-get update \
  && apt-get install -y apt-transport-https ca-certificates

# change mirror src
RUN sed -i -E "s/[a-zA-Z0-9]+.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list \
  && sed -i s:http:https:g /etc/apt/sources.list

RUN apt-get clean && apt-get update \
  && apt-get install -y curl tzdata lsof telnet mongodb-clients

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# env
ENV HOME /mgoroll
ENV PATH $HOME:$PATH
ENV APP_BIN mgoroll
ENV APP_CFG qboxmgoroll.conf

# ---------------------------------------------
# exec service
# ---------------------------------------------
WORKDIR $HOME

RUN mkdir -p $HOME/run && mkdir /auditlog

COPY entrypoint.sh .
RUN chmod a+x entrypoint.sh

COPY $APP_BIN .
RUN chmod a+x $APP_BIN

ENTRYPOINT ["entrypoint.sh"]
