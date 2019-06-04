--共享全局内存
local shared_data = ngx.shared.shared_data
shared_data:set("count", 1)

