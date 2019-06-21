-- #7

local count = 0
--闭包
local function hello()
   count = count + 1
   ngx.say("count : ", count)
end

local _M = {
   hello = hello
}

ngx.log(ngx.NOTICE, "======module_1 loaded======")
return _M
