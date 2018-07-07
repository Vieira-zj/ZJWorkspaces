FROM redis

# created at 2018-07-07
# cur dir: ~/Workspaces/ZJWorkspaces/dockerapps
MAINTAINER zivieira@163.com

COPY configs/redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
