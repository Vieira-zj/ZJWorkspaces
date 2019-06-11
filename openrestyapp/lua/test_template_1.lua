--pre conditions:
--cd ${HOME}/Workspaces/zj_work_workspace/openrestyapp/lualib
--curl -O https://raw.githubusercontent.com/bungle/lua-resty-template/master/lib/resty/template.lua
--mkdir ${HOME}/Workspaces/zj_work_workspace/openrestyapp/lualib/html
--cd ${HOME}/Workspaces/zj_work_workspace/openrestyapp/lualib/html
--curl -O https://raw.githubusercontent.com/bungle/lua-resty-template/master/lib/resty/template/html.lua

--test: curl -v "http://127.0.0.1:8080/lua_template_1"
local template = require("template")

local context = {
    title = "openresty_test",
    name = "openresty_template_test",
    description = "<script>alert(1);</script>",
    age = 20,
    hobby = {"电影", "音乐", "阅读"},
    score = {语文 = 90, 数学 = 80, 英语 = 70},
    score2 = {
        {name = "语文", score = 90},
        {name = "数学", score = 80},
        {name = "英语", score = 70},
    }
}

template.render("t1.html", context)
