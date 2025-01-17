--[[
获取腾讯、阿里、白山、阿卡麦默认cdn传递的uuid头，然后赋值给EEO-Request-ID
如果获取不到，赋值nginx内置变量request-id，在自建cdn节点中记录此日志
--]]

local ngx = require "ngx"

local _M = {}

function _M.set_request_id()
    local request_id_headers = {"eeo-request-id","x-nws-log-uuid","Eo-Log-Uuid","eagleid","Request-Id","X-Akamai-Request-ID"}
    local header_request_id
    for _, header in ipairs(request_id_headers) do
        header_request_id = ngx.req.get_headers()[header]
        if header_request_id then
            break
        end
    end

    if not header_request_id then
        header_request_id = ngx.var.request_id
    end

    ngx.req.set_header("EEO-Request-ID", header_request_id)
end

return _M
