--[[
    Filename:    kakuraSocket.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-10-27 14:35:33
    Description: File description
--]]

local kakuraSocket = class('kakuraSocket')

function kakuraSocket:ctor()
    print("kakuraSocket:ctor()")
    self._callback = nil
    self._socket = nil
end

function kakuraSocket:setRequestId(rid)
    self._requestId = rid + 1
end

local __count = 0

function kakuraSocket.getCount()
    return __count
end

function kakuraSocket.getUniqueReqId()
    return tostring(socket.gettime() .. ":" .. os.clock() .. ":" .. math.random(99999999))
end

-- http://www.blue-zero.com/WebSocket/
-- ws://echo.websocket.org:80
-- wss://echo.websocket.org:443
function kakuraSocket:init(ip, callback)
    print("kakuraSocket:init()")

    if GameStatic.useHttpDns_GameServer then
        self._ip = ApiUtils.getHttpDnsUrl(ip)
    else
        self._ip = ip
    end
    print(self._ip)
    -- 后端需要带有版本号
    self._appVersion  = kakura.Config:getInstance():getValue("APP_BUILD_NUM")
    if self._ip == nil or self._ip == "" then
        self._ip = "ws://192.168.0.1"
    end
    self._socket = kakura.Client:create(self._ip, self._appVersion, 1, 2, "") --"asset/other/DST_Root_certificate.pem"
    __count = __count + 1
    print("socket add count: ", __count)
    -- print(debug.traceback("a", 2))
    self._socket:registerNotifyCallback(function (uniqueRequestId, strNotifies)
        -- print(strNotifies)
        local str = json.decode(strNotifies)
        if #str > 0 then
            for i = 1, #str do
               self:onMessage("notify", str[i])
            end
        else
            self:onMessage("notify", str)
        end
    end)
    self._socket:registerErrorCallback(function (errorcode)
        self:onMessage("error", {errorcode = errorcode})
    end)
    self._socket:registerCloseCallback(function ()
        self._isClose = true
        self:onMessage("close")
    end)
    self._openCallback = callback
    self._socket:registerOpenCallback(function ()
        print("onOpen")
        self._isClose = false
        if self._openCallback then
            self._openCallback()
            self._openCallback = nil
        end 
    end)
    return true
end

function kakuraSocket:setCallback(callback)
    self._callback = callback
end

function kakuraSocket:onMessage(event, data, rid)
    if self._callback then
        self._callback(event, data, rid)
    end
end

local OPCODE_KAKURA_INIT = 1000
local OPCODE_KAKURA_HEARTBEAT = 1001
local OPCODE_KAKURA_REAUTH = 1014
local OPCODE_BACKEND_REQUEST = 100001

-- void sendRequest(uint32_t opcode, uint32_t requestId, const string & request, RESPONSE_CALLBACK callbackResponse);
-- int getRequestId();
function kakuraSocket:sendMsg(controller, action, context, rmsg, rid, ropcode, debug)    
    -- if self._socket == nil then return end
    local  isInit = false
    if (controller == "PlayerProcessor" or controller == "User") and action == "login" then
        isInit = true
        self._requestId = 0
    end
    local msg
    if rmsg then
        msg = rmsg
    else
        local data = {method = string.lower(string.sub(controller, 1, 1)) .. string.sub(controller, 2, string.len(controller)) .. "." .. action
    					, params = context}
        for k, v in pairs(data.params) do
            if type(k) == "function" or type(v) == "function" then
                data.params[k] = nil
            end
        end
        msg = json.encode(data)
    end
    print("send ".. msg)

    local opcode
    if ropcode then
        opcode = ropcode
    else
        -- print(controller, action)
        if isInit then
            opcode = OPCODE_KAKURA_INIT
        else
            opcode = OPCODE_BACKEND_REQUEST
        end
    end
    local requestId
    if rid then
        requestId = rid
    else
        requestId = self:getRequestId() 
    end
    if not debug then
        self._socket:sendRequest(opcode, requestId, kakuraSocket.getUniqueReqId(), msg, function (strResponse)
            -- print("strResponse", strResponse)
            local tick = socket.gettime()
            local _d = json.decode(strResponse)
        	self:onMessage("response", _d, requestId)
        end)
    end
    print("requestId="..requestId)
    return requestId, msg, opcode
end

function kakuraSocket:getRequestId()
    self._requestId = self._requestId + 1 --self._socket:getRequestId()
    return self._requestId
end

function kakuraSocket:reSend(msg, rid, ropcode)
    if self._socket == nil then return end
    self:sendMsg(nil, nil, nil, msg, rid, ropcode)
end

function kakuraSocket:heartBeat(method, callback)
    if self._socket == nil then return end
    print(method)
    self._socket:sendRequest(OPCODE_KAKURA_HEARTBEAT, 0, kakuraSocket.getUniqueReqId(), json.encode({method = method}), callback)
end

-- 安全sdk上传数据 -- 此接口有问题, 有可能导致掉线
function kakuraSocket:getSocket()
    return self._socket
end

function kakuraSocket:TssUpload(data)
    if self._socket == nil then return end
    local requestId = self:getRequestId() 
    -- print("tssUpload..opcode:"..OPCODE_BACKEND_REQUEST.." requestId:"..requestId .. data)
    -- print("tssUpload "..requestId)
    self._socket:sendRequest(OPCODE_BACKEND_REQUEST, requestId, kakuraSocket.getUniqueReqId(), json.encode({method = "Tss.checkClientData", params = {antiData = data}}), nil)
end

function kakuraSocket:reauth(network, token, ver, upgrade, pGroup, rid, callback)
    if self._socket == nil then return end
    local data = {method = "reauth", params = {network = network, token = token, ver = ver, upgrade = upgrade, deviceId = ApiUtils.getDeviceID(), pGroup = pGroup}}
    -- dump(data)
    local _rid = rid or self._requestId
    print("reauth", _rid)
    self._socket:sendRequest(OPCODE_KAKURA_REAUTH, _rid, kakuraSocket.getUniqueReqId(), json.encode(data), function (strResponse)
        callback(json.decode(strResponse))
    end)
end

-- RS专用
function kakuraSocket:login(checkKey, mtime, rid, roomId, platform, sec, callback)
    local data = 
    {      
        method = "playerProcessor.login",
        params = 
        {
            checkKey = checkKey,
            mtime = mtime,
            rid = rid,
            roomId = roomId,
            platform = platform,
            sec = sec
        }
    }
    self._socket:sendRequest(OPCODE_KAKURA_INIT, 0, kakuraSocket.getUniqueReqId(), json.encode(data), function (strResponse)
        -- print(strResponse)
        callback(json.decode(strResponse))
    end)
end

function kakuraSocket:clear()
    if self._socket == nil then return end
    print("self._socket:destroy()")
    __count = __count - 1
    print("socket dec count: ", __count)
    local socket = self._socket
    self._socket = nil

    print("self._isClose", self._isClose)
    if self._isClose then
        socket:destroy()
    else
        socket:unregisterNotifyCallback()
        socket:unregisterOpenCallback()
        socket:registerErrorCallback(function (errorcode)
            print("socket destroy error")
        end)
        socket:registerCloseCallback(function ()
            print("socket destroy close")
            socket:destroy()
        end)
        socket:closeAsync()
        self:onMessage("close")
    end
end

function kakuraSocket.dtor()
    _kakuraSocket = nil
    kakuraSocket = nil
end

return kakuraSocket