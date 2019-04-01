Web Apps on Docker

Containers
zjnginx => mynginx, 8081 => entry point
zjtools => data volume => webapp, redis dump
zjredis => myredis => save total access time for mock server
zjmock => mock server => api test
zjvue => myvue => vue demos


URI
# simple static reverse proxy, helloworld
http://helloworld.zj.com:8081
http://helloworld.zj.com:8081/public/helloworld.html
http://helloworld.zj.com:8081/static/pics/1.jpg

# simple reverse proxy, mockserver
http://mockserver.zj.com:8081/images/1.jpg // static
http://mockserver.zj.com:8081/index?isFile=false&wait=1 // mockserver
http://mockserver.zj.com:8081/post/cdnrefresh

# load balance proxy, vueserver
http://vueserver.zj.com:8081
http://vueserver.zj.com:8081/vue.html // static vue
http://vueserver.zj.com:8081/vueapp/vue.html // vue on tomcat


CLI
$ docker-compose -f webapp-docker-compose.yml up -d
$ docker-compose -f webapp-docker-compose.yml down

