-- #8
-- curl -v "http://127.0.0.1:8080/lua_redis_basic"

local function close_redis(red)
    if not red then
        return
    end
    local ok, err = red:close()
    if not ok then
        ngx.say("close redis error : ", err)
    end
end

local redis = require("resty.redis")

--创建实例
local red = redis:new()
--设置超时（毫秒）
red:set_timeout(1000)
--建立连接
local ip = "172.19.0.2"
local port = 6379
local ok, err = red:connect(ip, port)
if not ok then
    ngx.say("connect to redis error : ", err)
    return close_redis(red)
end

--调用API进行处理
ok, err = red:set("msg", "hello openresty")
if not ok then
    ngx.say("set msg error : ", err)
    return close_redis(red)
end

--调用API获取数据
local resp, err = red:get("msg")
if not resp then
    ngx.say("get msg error : ", err)
    return close_redis(red)
end

--得到的数据为空处理
if resp == ngx.null then
    resp = 'default'  --比如默认值
end
ngx.say("msg from redis: ", resp)

close_redis(red)
