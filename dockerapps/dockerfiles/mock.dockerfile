FROM busybox

# created at 2018-06-02
MAINTAINER zivieira@163.com 

COPY mockserver /usr/local/bin/
COPY configs/mock_conf.json usr/local/bin/

EXPOSE 17891

CMD cd usr/local/bin;./mockserver | tee /tmp/server.log
