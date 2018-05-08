--[[
    Filename:    HttpManager.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-02 11:40:50
    Description: File description
--]]

local HttpManager = class('HttpManager')

local _httpManager = nil
function HttpManager:ctor()

end

function HttpManager:getInstance()
    if _httpManager == nil  then 
        _httpManager = HttpManager.new()
        
        return _httpManager
    end
    return _httpManager
end

function HttpManager:sendMsg(ip, method, context, callback, errorCallback, useHttpDns)
    local req = cc.XMLHttpRequest:new()
    req.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    req:registerScriptHandler(function()
        if callback then
            if req.status == 200 then -- 成功
                print("http_recv " .. req.response)
                if req.response ~= nil and  string.len(req.response) > 0 then 
                    local ret
                    if string.find(req.response, "{") and string.find(req.response, "}") then
                        if not pcall(function ()
                            ret = json.decode(req.response)
                        end) then
                            -- 解析json失败
                            if errorCallback then
                                errorCallback(req.status, 1, req.response)
                            end     
                            return 
                        end
                        callback(ret)
                    else
                        -- 返回不是json
                        if errorCallback then
                            errorCallback(req.status, 2, req.response)
                        end
                    end
                else
                    callback(nil)
                end
            else
                print("http_recv error: " .. req.status)
                -- 连接不成功
                if errorCallback then
                    errorCallback(req.status, 3, req.response)
                end
            end
        end
    end)
    if method == nil then
        method = "post"
    end
    local newIp = ip
    local urlhost
    if useHttpDns == true then 
        newIp, urlhost = ApiUtils.getHttpDnsUrl(ip)
        if newIp ~= ip and urlhost ~= nil then 
            print("urlhost=====", urlhost)
            req:setRequestHeader("host", urlhost)
        end
    end
    req:open(method, newIp)
    local msg = ""
    for k, v in pairs(context) do
        msg = msg .. "&" .. k .. "=" .. v
    end

    print("http_send " .. msg)
    req.timeout = 10
    req:send(msg)
    return newIp
end

-- 简单请求, 返回结果
function HttpManager:simpleReq(url, timeout, callback)
    local req = cc.XMLHttpRequest:new()
    req.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    req:registerScriptHandler(function()
        if callback then
            callback(req.status, req.response)
        end
    end)
    req:open("get", url)
    req.timeout = timeout
    req:send("")
end

function HttpManager.dtor()
    _httpManager = nil
    -- HttpManager = nil
end

return HttpManager
