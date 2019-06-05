--zhengjin, create at 20190605, module test
--test: curl -v "http://127.0.0.1:8080/lua_module_1"

local module1 = require("module1")
module1.hello()
