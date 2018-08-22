FROM ubuntu:trusty

LABEL maintainer="qa_test"

# 安装基础依赖
RUN apt-get clean && apt-get update && apt-get install -y apt-transport-https ca-certificates

# 修改镜像源
RUN sed -i -E "s/[a-zA-Z0-9]+.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list
RUN sed -i s:http:https:g /etc/apt/sources.list

RUN apt-get clean && apt-get update && apt-get install -y \
	curl \
	tzdata \
	lsof \
	telnet

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 配置服务环境变量
ENV HOME /cdnrefresh
ENV PATH $HOME:$PATH
ENV APP_BIN qboxcdnrefresh
ENV APP_CFG qboxcdnrefresh.conf

# ---------------------------------------------
# 以下为运行服务和收集日志模块命令模板
# ---------------------------------------------

WORKDIR $HOME

RUN mkdir /auditlog

COPY entrypoint.sh .
RUN chmod a+x entrypoint.sh

COPY $APP_BIN .
RUN chmod a+x $APP_BIN

ENTRYPOINT ["entrypoint.sh"]
