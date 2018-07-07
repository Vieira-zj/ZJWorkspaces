FROM nginx

# created at 2018-06-02
MAINTAINER zivieira@163.com

COPY configs/nginx_conf/nginx.conf /etc/nginx/
COPY configs/nginx_conf/proxy.conf /etc/nginx/
COPY data/webapps /home/zhengjin/webapps

EXPOSE 80

CMD nginx -g 'daemon off;'

