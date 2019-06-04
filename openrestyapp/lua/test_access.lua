--zhengjin, create at 20190604
--test 403 forbidden: url -v "http://127.0.0.1:8080/lua_access?token=abc"
--test pass: curl -v "http://127.0.0.1:8080/lua_access?token=test"

if ngx.req.get_uri_args()["token"] ~= "test" then
    return ngx.exit(403)
end

