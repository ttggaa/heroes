--[[
    Filename:    WebSocket.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-15 10:55:30
    Description: File description
--]]

local WebSocket = class('WebSocket')

local _webSocket = nil
function WebSocket:ctor()
    self:init()
    self._callback = nil
end

function WebSocket:getInstance()
    if _webSocket == nil  then 
        _webSocket = WebSocket.new()
        return _webSocket
    end
    return _webSocket
end

function WebSocket:init()
    self._ip = GameStatic.ipAddress
    print(self._ip)
    self._socket = pc.PCWebSocket:getInstance()
    self._socket:init(self._ip)
    self._socket:setCallBack(self, function (_, event, str)
        if string.len(str) > 0 then
            -- print("recv "..str)
            self:onMessage(event, json.decode(str))
        else
            self:onMessage(event)
        end
    end)

    return true
end

function WebSocket:setCallback(callback)
    self._callback = callback
end

function WebSocket:onMessage(event, data)
    if self._callback then
        self._callback(event, data)
    end
end

function WebSocket:sendMsg(controller, action, context)
    local data = {act = string.lower(string.sub(controller, 1, 1)) .. string.sub(controller, 2, string.len(controller)) .. "." .. action}
    for k, v in pairs(context) do
        data[k] = v
    end
    local msg = json.encode(data)
    print("send "..msg)
    self._socket:sendRequest(msg)
end

return WebSocket