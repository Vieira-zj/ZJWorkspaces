--zhengjin, create at 20190604
--test: curl -v "http://127.0.0.1:8080/lua_set?i=1&j=10"

local uri_args = ngx.req.get_uri_args()
local i = uri_args["i"] or 0
local j = uri_args["j"] or 0
return i + j

