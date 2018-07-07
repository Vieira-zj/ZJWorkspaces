FROM tomcat

# created at 2018-06-02
MAINTAINER zivieira@163.com

RUN mkdir /usr/local/tomcat/webapps/vueapp \
 && mkdir -p /usr/local/tomcat/webapps/static/css \
 && mkdir -p /usr/local/tomcat/webapps/static/js 

COPY data/webapps/static/vueserver/vue.html /usr/local/tomcat/webapps/vueapp/
COPY data/webapps/static/vueserver/static/css /usr/local/tomcat/webapps/static/css/
COPY data/webapps/static/vueserver/static/js /usr/local/tomcat/webapps/static/js/

EXPOSE "8080"

CMD catalina.sh run
