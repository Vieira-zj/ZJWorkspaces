-- #1
-- test: curl -v "http://127.0.0.1:8080/lua"

ngx.say("hello openresty!");
ngx.say("lua version: ", _VERSION)
