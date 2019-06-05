--zhengjin, create at 20190605, module test

local count = 0
local function hello()
   count = count + 1
   ngx.say("count : ", count)
end

local _M = {
   hello = hello
}

ngx.log(ngx.NOTICE, "======module_1 loaded======")
return _M
