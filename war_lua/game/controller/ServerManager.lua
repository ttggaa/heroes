--[[
    Filename:    ServerManager.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-27 18:32:47
    Description: File description
--]]

local kakuraSocket = require("base.network.kakuraSocket")
local ServerManager = class("ServerManager")

local _serverManager = nil
local TIMEOUT = 7
local MAX_TRY_RECONNECT = 5
local httpManager = HttpManager:getInstance()

ServerManager.STATE_NONE = 1 -- 未连接状态
ServerManager.STATE_CONNECTED = 2 -- 已连接状态 
ServerManager.STATE_RECONNECT = 3 -- 重连中状态
ServerManager.STATE_CONNECTING = 4 -- 连接中 
ServerManager.STATE_REINIT = 5 -- 重新连接中

function ServerManager:getInstance()
    if _serverManager == nil  then 
        _serverManager = ServerManager.new()
        return _serverManager
    end
    return _serverManager
end

-- socket 两种通信方式
-- 1. send->response  在send的时候new一个server实例, 收到response返回给serverhtt
-- 2. notify 收到通知的时候new一个server实例
function ServerManager:ctor()
    -- 请求列表
    self._serverRequestMap = {}
    -- 弱网请求，不更新服务器时间差
    self._badNetMap = {}
    -- 重试中发送的请求, 连接成功后, 发送
    self._saveRequestMap = {}
    -- 检查超时列表
    self._checkTimeOutMap = {}

    -- add by vv
    -- server端无法保证不重push ，所以客户端根据roomId与pushId 进行拦截
    self._cachePushIds1 = {}
    self._cachePushIds2 = {}
    self._cachePushTick = 0


    -- 用户ID
    self._pid = nil
    -- 游戏服务器地址
    self._viewMgr = ViewManager:getInstance()
    self._state = ServerManager.STATE_NONE

    self._isSending = 0
    -- 全局response监听者，分发事件之前处理
    self._globalResponseListeners = {}
    -- 全局response监听者，分发事件之后处理
    self._globalResponseListenersAfter = {}
    -- RS response监听
    self._RSResponseListeners = {}

    self._pushEnable = true

    -- 尝试重连次数
    self._reconnectCount = 0

    self._lastSendRequestId = nil
    self._lastRecvRequestId = nil

    -- RS
    self._RS_state = ServerManager.RS_STATE_NONE
end

function ServerManager:getState()
    return self._state
end

function ServerManager:setPushEnabled(enable)
    print("self._pushEnable", enable)
    self._pushEnable = enable
end

function ServerManager:initSocket(callback, errorcallback)
    if self._state == ServerManager.STATE_NONE then
        if string.sub(GameStatic.ipAddress,string.len(GameStatic.ipAddress)) ~= "/" then 
            GameStatic.ipAddress = GameStatic.ipAddress .. "/"
        end
        if self._kakuraSocket == nil then
            self._kakuraSocket = kakuraSocket.new()
        end
        print("kakuraUrl: ", GameStatic.ipAddress)
        self._kakuraSocket:init(GameStatic.ipAddress, function ()
            self._connectingCallback = nil
            self._state = ServerManager.STATE_CONNECTED
            -- 心跳
            self._heartBeatUpdateId = ScheduleMgr:regSchedule(60000, self, function(self, dt)
                if self._state == ServerManager.STATE_CONNECTED then
                    self._kakuraSocket:heartBeat("heartBeat")
                end
            end)
            self._UpdateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
                self:update()
            end)
            if GameStatic.enableSDK and GameStatic.useTss then
                self._TssUpdateId = ScheduleMgr:regSchedule(100, self, function(self, dt)
                    self:tssUpdate()
                end)
            end
            if callback then callback() end
        end)
        self._kakuraSocket:setCallback(function (event, msg, rid)
            if not trycall("onResponse", self.onResponse, self, event, msg, rid) then
                self._viewMgr:unlock(32)
            end
        end)
        self._state = ServerManager.STATE_CONNECTING 
        self._connectingCallback = errorcallback
    end
end

function ServerManager:tss()
    -- 安全sdk
    if GameStatic.enableSDK and GameStatic.useTss then
        -- self._rid = ModelManager:getInstance():getModel("UserModel"):getUID()
        -- local loginUrl = AppInformation:getInstance():getValue("global_server_url", GameStatic.httpAddress_global)
        -- if RestartMgr.globalUrl_planB then
        --     loginUrl = RestartMgr.globalUrl_planB
        -- end
        -- self._tssUrl = loginUrl .. "?mod=global&method=System.sysInterface&act=checkClientData"
        self._tssHead = nil
        self._tssTail = nil
        sdkMgr:setSecurityCallback(function (code, jsondata)
            local data = jsondata--json.decode(jsondata)
            if self._tssHead == nil then
                self._tssHead = {data, nil}
                self._tssTail = self._tssHead
            else
                local node = {data, nil}
                self._tssTail[2] = node
                self._tssTail = node
            end
            -- httpManager:sendMsg(self._tssUrl, nil, {antiData = json.decode(jsondata), roleId = self._rid, sec = GameStatic.sec}, nil, nil, false)
        end)
        sdkMgr:sendSecurityData(GameStatic.sec, ModelManager:getInstance():getModel("UserModel"):getUID())
    end
end

function ServerManager:tssUpdate()
    if self._state == ServerManager.STATE_CONNECTED then
        if self._tssHead and self._kakuraSocket:getSocket() then
            local str = self._tssHead[1]
            self._kakuraSocket:TssUpload(str)
            self._tssHead = self._tssHead[2]
            if self._tssHead == nil then
                self._tssTail = nil
            end
        end
    end
end

local TEST_DISCONNECT = false -- 发完就断
local TEST_RECV = false
local TEST_SEND = false
local TEST_REAUTH = false
function ServerManager:setTest_Recv(test)
    TEST_RECV = test
    if test then
        TIMEOUT = 1
    else

    end
end

function ServerManager:setTest_Send(test)
    TEST_SEND = test
    if test then
        TIMEOUT = 1
    else

    end
end

function ServerManager:setTest_Reauth(test)
    TEST_REAUTH = test
end

function ServerManager:setTest_Disconnect(test)
    TEST_DISCONNECT = test
end

GLOBAL_VALUES.last_onResponse = {}
local last_onResponse_index = 1

function ServerManager:onResponse(event, data, rid)
    local server
    local action
    local result
    if event == "response" then
        -- dump(data)
        if TEST_RECV then return end
        local _error = data["error"]
        if _error then
            local _code = _error["code"]
            if _code == 142 then -- 数据库提交冲突，必须更换rid重新请求
                if self._serverRequestMap[rid] then
                    -- 用一个新的rid来接受回应
                    print("onResponse error code:".._code)
                    local newRid = self._kakuraSocket:getRequestId()
                    self._serverRequestMap[newRid] = self._serverRequestMap[rid]
                    self._serverRequestMap[rid] = nil
                    self._badNetMap[newRid] = self._badNetMap[rid]
                    self._badNetMap[rid] = nil
                    self._checkTimeOutMap[newRid] = self._checkTimeOutMap[rid]
                    self._checkTimeOutMap[rid] = nil
                end
                return
            end   
            if _code == 999725 then -- 前一个请求服务器收到，但是还没处理完，就当没收到返回，重发
                print("onResponse error code:".._code)
                return
            end
        end
        self._checkTimeOutMap[rid] = nil
        if next(self._serverRequestMap) == nil then return end
        -- 已经受理过的请求
        if self._serverRequestMap[rid] == nil then
            return
        end

        if _error and _error["code"] == 999721 then
            print("PHP报错")
            return
        end

        self._lastRecvRequestId = rid
        -- 只有正常请求才会校对时间, 误差<TIMEOUT
        if data and data["time"] and TimeUtils.serverTimezone and self._badNetMap[rid] == nil then
            ModelManager:getInstance():getModel("UserModel"):adjustServerTime(data["time"])
        end
        self._badNetMap[rid] = nil

        self._reconnectCount = 0
        -- dump(data, "1", 10)
        -- 回应
        server = self._serverRequestMap[rid][1]
        action = self._serverRequestMap[rid][2]
        result = data["result"]

        self._serverRequestMap[rid] = nil
        self._isSending = self._isSending - 1
        print("-1, self._isSending: ", self._isSending, action)
    elseif event == "notify" then
        if TEST_RECV then return end
        -- 通知
        -- 优先找名为 "on" .. action 的方法, 如果没有, 那么统一由onResponse返回
        if data["method"] == "Tss.broClientData" then
            if GameStatic.enableSDK and GameStatic.useTss then
                print("broClientData , len="..string.len(data["info"]["antiData"]))
                sdkMgr:receiveSecurityData(data["info"]["antiData"])
            end
            return
        end
        if data["method"] == "Indulge.showDialog" then
            self._viewMgr:onIndulge(data["info"]["status"],data["info"])
            return
        end
        if data["error"] then
            self:onError(data["error"])
            return
        end
        if not self._pushEnable then
            return
        end
        -- add by vv
        -- server端无法保证不重push ，所以客户端根据pushId 进行拦截
        if data["pushId"] ~= nil then 
            local pushId  = tostring(data["pushId"])
            if self._cachePushIds1[pushId] ~= nil and self._cachePushIds2[pushId] ~= nil then 
                print("Repeat push id:", pushId)
                return
            end
            local nowTime = os.time()
            local lastTime = self._cachePushTick
            if nowTime - lastTime > 3 * 60 then 
                self._cachePushTick = nowTime
                self._cachePushIds2 = self._cachePushIds1
                self._cachePushIds1 = {}
            end
 
            self._cachePushIds1[pushId] = 1
            -- dump(self._cachePushIds1)
            -- dump(self._cachePushIds2)
        end
        
        if data["method"] == nil then return end
        local method = string.split(data["method"], "%.")
        local system = method[1]
        server = self:_getServer(string.upper(string.sub(system, 1, 1)) .. string.sub(system, 2, string.len(system)) .. "Server")
        action = method[2]
        result = data["info"]

    elseif event == "close" then
        print("server close")
        -- self._viewMgr:showTip("与服务器断开连接, 正在尝试重连")
        self:onDisconnect(1)
        return
    elseif event == "error" then
        -- 
        print("server error", data.errorcode)
        if self._connectingCallback then
            self._state = ServerManager.STATE_NONE
            self._connectingCallback(data.errorcode)
            self._connectingCallback = nil
        end
        self:onDisconnect(2, data.errorcode)
        return
    end
    -- 统一解锁
    if server then
        server:unlockView()
    end
    local _error = data["error"]
    local errorCode
    local errorMsg
    local errorRMsg
    if _error and _error ~= 0 then
        local code = _error["code"]
        local message = _error["message"]
        local replaceMsg = _error["replaceMsg"]
        errorCode = code
        errorMsg = message
        errorRMsg = replaceMsg
        print("errorCode ", errorCode, "errorMsg", errorMsg)
        if code >= 998000 then
            self:onError({code = code, errorMsg = errorMsg})
            return 
        end

        -- errorMsg
        -- 统一错误提示, 如果表里找不到, 则显示绿码
        if tab.errorCode[errorCode] then
            -- 替换提示语
            errorMsg = tab.errorCode[errorCode].lang
            if errorRMsg and errorMsg then
                for k, v in pairs(errorRMsg) do
                    errorMsg = string.gsub(errorMsg, "{$"..k.."}", v)
                end
            end     
            if action ~= "login" then
                if OS_IS_WINDOWS then
                    self._viewMgr:showTip("[debugid:"..errorCode .. "] " .. errorMsg)
                else
                    self._viewMgr:showTip(errorMsg)
                end
            end
        else
            -- 绿码
            showGlobalErrorCodeTip(MAX_SCREEN_WIDTH * 0.5, 100, tostring(errorCode) )
        end
    else
        errorCode = 0
    end
    if result and type(result) ~= "boolean" then
        for sender, callback in pairs(self._globalResponseListeners) do
            trycall("globalResponseListeners_"..sender:getClassName(), callback, result)
        end
    end
    if server then
        -- 首字母大写 e.g. onAddMoney
        local funcName = "on" .. string.upper(string.sub(action, 1, 1)) .. string.sub(action, 2, string.len(action))
        if server[funcName] then
            print("recv " .. server:getClassName() .. ":" .. funcName)
            if result or errorCode then
                server[funcName](server, result, errorCode)
            end
        else
            print("recv " .. server:getClassName() .. ":" .. funcName .. " == nil")
            if result or errorCode then
                server["onResponse"](server, result, errorCode)
            end
        end
        if errorCode ~= 0 then
            server:errorCallback(errorCode, errorMsg, errorRMsg)
        end

        if GLOBAL_VALUES and GLOBAL_VALUES.last_onResponse then
            GLOBAL_VALUES.last_onResponse[last_onResponse_index] = {os.time(), data["error"], server:getClassName(), funcName}
            last_onResponse_index = last_onResponse_index + 1
            if last_onResponse_index > 10 then last_onResponse_index = 1 end
        end
    end
    if result and type(result) ~= "boolean" then
        for sender, callback in pairs(self._globalResponseListenersAfter) do
            trycall("globalResponseListenersAfter_"..sender:getClassName(), callback, result)
        end
    end
end

function ServerManager:listenGlobalResponse(sender, callback)
    self._globalResponseListeners[sender] = callback
end

function ServerManager:removeGlobalResponseListener(sender)
    self._globalResponseListeners[sender] = nil
end

function ServerManager:listenGlobalResponseAfter(sender, callback)
    self._globalResponseListenersAfter[sender] = callback
end

function ServerManager:removeGlobalResponseListenerAfter(sender)
    self._globalResponseListenersAfter[sender] = nil
end

function ServerManager:listenRSResponse(sender, callback)
    self._RSResponseListeners[sender] = callback
end

function ServerManager:removeRSResponseListener(sender)
    self._RSResponseListeners[sender] = nil
end

-- 要求model文件的目录结构正确 game.server.xxx
-- 每一次请求都是一个独立的new, 为了使用一些请求前后需要用的临时变量
function ServerManager:_getServer(name, data)
    local checkServer = function()
        require ("game.server." .. name)
    end
    -- 保证server不存在的情况下不报错
    if not trycall("ServerManager:checkServer", checkServer, self) then 
        return nil
    end

    local server = require("game.server." .. name).new(data)
    server:setClassName(name)
    return server
end

function ServerManager:setPid(pid)
    self._pid = pid
end

function ServerManager:getPid()
    return self._pid
end

function ServerManager:setToken(token)
    self._token = token
end

function ServerManager:setVer(ver)
    self._ver = ver
end

function ServerManager:setUpgrade(upgrade)
    self._upgrade = upgrade
end

function ServerManager:setRequestId(rid)
    self._kakuraSocket:setRequestId(rid)
end

-- 发送短链接请求
--[[
    流程为   view通过ModelManager:listenModelReflash来监听model的数据刷新事件
            view通过ServerManager:sendMsg来发送请求, server的onXXX方法收到回应, 在通过ModelManager:getModel获取到model刷新model的数据
            or
            view通过ServerManager:sendMsg来发送请求, server的onXXX方法收到回应, 通过ViewManager给相应view发命令


    弱网处理
    
--]]
function ServerManager:isSending()
    return self._isSending > 0
end

function ServerManager:setGlobalCallback(callback)
    self._globalCallback = callback
end

function ServerManager:onGlobalCallback()
    if self._globalCallback then
        self._globalCallback()
        self._globalCallback = nil
    end
end

function ServerManager:getLastSendAction()
    if self.__lastSendAction then
        return self.__lastSendAction
    else
        return ""
    end
end

-- name为类名 如 UserServer
-- act为行为 如 addMoney
-- context为传入服务器的参数
-- lockview是否锁定view
-- data为传入server的临时变量
-- callback 回调  server:callback()
-- errorCallback 错误回调 **** timeout也会走errorCallback， 通过返回的参数来判断是否有请求错误
function ServerManager:sendMsg(name, act, context, lockview, data, callback, errorCallback, reSend, timeoutCallback)
    self.__lastSendAction = name .. act .. os.time()
    if GuideUtils.unloginGuideEnable then
        self:sendMsgEx(name, act, context, lockview, data, callback, errorCallback, reSend)
        return
    end
    if self._state == ServerManager.STATE_RECONNECT or self._state == ServerManager.STATE_REINIT then
        self._saveRequestMap[#self._saveRequestMap + 1] = {name, act, context, lockview, data, callback, errorCallback, reSend}
        return
    elseif self._state == ServerManager.STATE_NONE then
        return
    end
    local requestId, msg, opcode
    local server = self:_getServer(name, data)
    print("server",name)
    if server then
        self._isSending = self._isSending + 1
        print("+1 self._isSending: ", self._isSending, act)
        server:setCallback(callback)
        server:setErrorCallback(errorCallback)
        server:setTimeOutCallback(timeoutCallback)
        
        local controller = string.sub(name, 1, string.len(name) - 6)
        local action = act
        if GuideUtils.guideChange then
            context["_guide_"] = GuideUtils.guideChange
            GuideUtils.guideChange = nil
        end
        if GuideUtils.triggerTLog then
            local first = true
            local str = ""
            for k, _ in pairs(GuideUtils.triggerTLog) do
                if first then
                    str = k
                    first = false
                else
                    str = str .. "#" .. k
                end
            end
            context["_trigger_"] = str
            GuideUtils.triggerTLog = nil
        end
        requestId, msg, opcode = self._kakuraSocket:sendMsg(controller, action, context, nil, nil, nil, TEST_SEND)
        self._lastSendRequestId = requestId
        self._serverRequestMap[requestId] = {server, action, msg, opcode}
        if reSend == nil then reSend = true end
        self._checkTimeOutMap[requestId] = {reSend, socket.gettime() + TIMEOUT}
        server:lockView(lockview)
    end
    if TEST_DISCONNECT then
        self:disconnect()
    end
    return requestId
end

function ServerManager:update()
    -- 切换界面的时候不检查
    if self._viewMgr:isViewChanging() and not self._viewMgr:isOnBeforeAdd() then return end
    if self._state == ServerManager.STATE_NONE then 
        return 
    elseif self._state == ServerManager.STATE_CONNECTED then
        -- 判断请求超时
        local badNet = false
        local tick = socket.gettime()
        for rid, data in pairs(self._checkTimeOutMap) do
            if tick > data[2] and self._serverRequestMap[rid] ~= nil then
                self._serverRequestMap[rid][1]:timeOutCallback()  
                if data[1] then
                    self._badNetMap[rid] = 1
                    badNet = true
                else
                    -- 不重试
                    if self._serverRequestMap[rid] then
                        self._serverRequestMap[rid][1]:unlockView()
                        self._serverRequestMap[rid] = nil
                    end
                end
            end
        end
        if badNet then
            self:_reinit(1)
        end
    elseif self._state == ServerManager.STATE_RECONNECT then
        local tick = socket.gettime()
        -- 重连超时
        if self._reconnectTimeOutTick and tick > self._reconnectTimeOutTick then
            print("reauth超时")
            self:_reinit(2)
        end
    end
end

function ServerManager:_clearMap()
    for k, v in pairs(self._serverRequestMap) do
        v[1]:onError()
    end
    self._serverRequestMap = {}
    self._saveRequestMap = {}
    self._checkTimeOutMap = {}
    self._badNetMap = {}
end

-- type 1 close   2 error
function ServerManager:onDisconnect(type, errorcode)
    print("onDisconnect", type)
    if type == 1 then
        if self._inOnClose then 
            print("inOnClose")
            return 
        end
        self._inOnClose = true
        if self._returnLogin then
            -- 主动断开连接, 不做任何处理
            print("returnLogin")
            self._inOnClose = false
            return
        else
            -- 掉线, 重新连接
            -- self:setPushEnabled(false)
            print("掉线")--, self._token)
            if self._token ~= nil then
                self._reconnectTimeOutTick = nil
                self:onError({code = 1})
            else
                self._state = ServerManager.STATE_NONE
                self._returnLogin = true
                self:_clearMap()
                self._viewMgr:clearLock()
                self._viewMgr:restart() 
            end
            self._inOnClose = false
        end
    elseif type == 2 then
        self:onError({code = errorcode})
    end
    
end

function ServerManager:_restart(tips, errorCode)
    if self._restarting then return end
    self._restarting = true
    self._state = ServerManager.STATE_NONE
    self._returnLogin = true
    self:_clearMap()
    self._viewMgr:disableChangeView()
    self._viewMgr:clearLock()
    self._viewMgr:guidePause()
    self._viewMgr:onRestart()
    self._viewMgr:closeHintView()
    self._viewMgr:showDialog("global.NetWorkDialog", {msg = tips, callback = function ()
        self._viewMgr:restart() 
    end}) 
end

function ServerManager:getReinitData()
    return self._reinitData
end

local msgTab = 
{
    "您与恩洛斯大陆间的连接出现了波动，需要重新穿越吗？",
    "您与恩洛斯大陆间的连接出现了波动，需要重新穿越。",
    "您与恩洛斯大陆间的连接出现了波动，需要重新穿越",
    "您与恩洛斯大陆间的连接出现了波动，需要重新穿越吗",
}
function ServerManager:_reinit(t)
    if self._isReiniting then return end

    self._reinitData = 
    {
        _type = t,
        time = os.time()
    }
    self._isReiniting = true
    self._returnLogin = true
    -- print("#############", self._state)
    if self._state == ServerManager.STATE_RECONNECT then
        self._viewMgr:unlock(-11)
    end
    self._state = ServerManager.STATE_REINIT
    self:pauseLock()
    self._viewMgr:guidePause()
    self._viewMgr:closeHintView()

    self:setDontReconnect(true)
    self:disconnect()

    if self._heartBeatDCSender then
        ScheduleMgr:cleanMyselfDelayCall(self._heartBeatDCSender)
        self._heartBeatDCSender = nil
    end
    -- 重试次数过多
    if self._reconnectCount >= MAX_TRY_RECONNECT then
        self._viewMgr:showDialog("global.NetWorkDialog", {msg = "服务器开了个小差，需要重新登录啦", title0 = "返回登录", 
            callback = function ()
                self._isReiniting = false
                self._state = ServerManager.STATE_NONE
                self._returnLogin = true
                self:_clearMap()
                self._viewMgr:disableChangeView()
                self._viewMgr:clearLock()
                self._viewMgr:guidePause()
                self._viewMgr:onRestart()
                self._viewMgr:restart() 
            end})
        return
    end
    self._reconnectCount = self._reconnectCount + 1
    if GameStatic.autoReconnectCount == nil or self._reconnectCount > GameStatic.autoReconnectCount then
        local dialog = self._viewMgr:showDialog("global.NetWorkDialog", {msg = msgTab[t], title1 = "重新连接", title2 = "返回登录",
            callback1 = function ()
                self:resumeLock()
                self._viewMgr:guideResume()
                self._isReiniting = false
                self._returnLogin = false
                if self._state ~= ServerManager.STATE_RECONNECT then
                    self._state = ServerManager.STATE_RECONNECT
                    self._viewMgr:lock(502)
                end
                self:setDontReconnect(false)
                ScheduleMgr:delayCall(1000, self, function()
                    self:connect()
                end)
            end,
            callback2 = function ()
                self._isReiniting = false
                self._state = ServerManager.STATE_NONE
                self._returnLogin = true
                self:_clearMap()
                self._viewMgr:disableChangeView()
                self._viewMgr:clearLock()
                self._viewMgr:guidePause()
                self._viewMgr:onRestart()
                self._viewMgr:restart() 
            end}) 
        dialog:setLocalZOrder(10000)
    else
        self:resumeLock()
        self._viewMgr:guideResume()
        self._isReiniting = false
        self._returnLogin = false
        if self._state ~= ServerManager.STATE_RECONNECT then
            self._state = ServerManager.STATE_RECONNECT
            self._viewMgr:lock(502)
        end
        self:setDontReconnect(false)
        ScheduleMgr:delayCall(1000, self, function()
            self:connect()
        end)
    end
end

-- KakuraErrorCode.NEED_RELOGIN = {"error":{"code":999724,"message":"need client relogin"}};
-- KakuraErrorCode.NEED_UPDATECLIENT = {"error":{"code":999723,"message":"need update client"}};
-- KakuraErrorCode.KICKOUT_BY_SERVER = {"error":{"code":999721,"message":"kickouted by server"}};
-- KakuraErrorCode.DUPLICATE_LOGIN = {"error":{'code':999722,"message":"duplicate login"}};
-- KakuraErrorCode.NO_HEARTBEAT = {"error":{"code":999720,"message":"no heart beat"}};

-- KakuraErrorCode.KAKURA_ERROR = {"error":{"code":999999}, "result":{}};

-- KakuraErrorCode.HTTPCLIENT_SENDDATA_ERROR = {"error":{"code":999712,"message":"internal error"}};
-- KakuraErrorCode.RESPONSE_CACHE_ERROR = {"error":{'code':999713,"message":"error occur when get from cahce"}};
-- KakuraErrorCode.PACKAGE_FORMAT_ERROR = {"error":{'code':999714,"message":"error occur when decode package value"}};
-- KakuraErrorCode.PACKAGE_REQUEST_PARAM_ERROR = {"error":{'code':999715,"message":"error occur get request params"}};

function ServerManager:onError(error)
    if self._viewMgr:isViewChanging() then
        self._viewMgr:setViewChangeEndCallback(function ()
            if self.__onError then
                self:__onError(error)
            end
        end)
    else
        self:__onError(error)
    end
end

function ServerManager:__onError(error)
    -- 999720/999721/999722 是push回来的error
    print("onError", error.code)
    if error.code == 1 then
        -- 连接中断, 询问是否尝试重连
        if self._token == nil then
            self:clear()
            self._viewMgr:clearLock()
        else
            self:_reinit(3)
        end   
    elseif error.code == 999721 then
        -- kickouted by server
        -- 强制踢出
        self:_restart("您帐号已被封停", error.code)
    elseif error.code == 999720 then
        -- no heart beat
        -- 没心跳, 会close
    elseif error.code == 999722 then
        -- duplicate login
        -- 重复登录
        self:_restart("您与恩洛斯大陆失去了连接，按确定返回登录界面重新穿越", error.code)   
    elseif error.code == 999733 then
        -- 不能用resend, 要用send
        self:_restart("恩洛斯的天空出现了异象，按确定返回登录界面进行躲避", error.code)  
    elseif error.code == 999724 then
        -- need client relogin
        self:_restart("您的魔法门通行证已过期，按确定返回登录界面进行续签", error.code)   
    elseif error.code == 999723 then
        -- need update client
        self:_restart("领主大人，恩洛斯世界有新事物加入，需重新载入，请返回穿越门重新穿越", error.code)
    elseif error.code == 999712 then
        -- 请求后端或者其他node出现的错误
        self:_restart("您与恩洛斯大陆间的连接出现了波动，按确定返回登录界面重新穿越。", error.code)
    elseif error.code == 999713 then
        -- 发送requestId小于当前的requestId，但是cache中没有找到这个请求的数据
        self:_restart("您与恩洛斯大陆间的连接出现了波动，按确定返回登录界面重新穿越", error.code)
    elseif error.code == 999714 then
        -- 收到的kakurapackage解不开
        self:_restart("您与恩洛斯大陆间的连接出现了波动，按确定返回登录界面，重新穿越。", error.code)
    elseif error.code == 999715 then
        -- backend返回的数据有问题
        self:_restart("您与恩洛斯大陆间的连接出现了波动，按确定返回登录界面，重新穿越", error.code)
    elseif error.code == 998003 then
        -- 服务器维护
        self:_restart("领主大人，恩洛斯世界扩张升级中，请返回穿越门耐心等待施工的完成", error.code)
    elseif error.code == 998001 then
        -- token验证失败 请重新验证登录
        if not GameStatic.enableSDK then
            self:_restart("您的魔法门通行证已过期，按确定返回穿越门进行续签后再次穿越", error.code)
        else
            sdkMgr:logout({}, function(code, data)
                code = tonumber(code)
                if code == sdkMgr.SDK_STATE.SDK_LOGOUT_SUCCESS then
                    self:_restart("您的魔法门通行证已过期，按确定返回穿越门进行续签后再次穿越。", error.code)
                elseif code == sdkMgr.SDK_STATE.SDK_LOGOUT_FAIL then
                    self._viewMgr:showTip("切换账号失败")
                end
            end)
        end
    elseif error.code == 998002 then
        -- 封号提示
        self:_restart(error.errorMsg, error.code)
    else
        if self._token == nil then
            self:clear()
            self._viewMgr:clearLock()
            self._viewMgr:showDialog("global.NetWorkDialog", {msg = "连接服务器失败"})
        else
            self:_restart("穿越至恩洛斯失败，按确定返回穿越门再次尝试", error.code)  
        end
    end
end

-- 重连, 需要考虑reauth也可能丢包的状况
function ServerManager:reconnect()
    self._reconnectTimeOutTick = socket.gettime() + TIMEOUT
    local _network = 0
    local _netType = AppInformation:getInstance():getNetworkType()
    if _netType == 2 then
        _network = 2
    elseif _netType == 3 then
        _network = 1
    end
    self._kakuraSocket:reauth(_network, self._token, self._ver, self._upgrade, GameStatic.userSimpleChannel, 
        self._lastSendRequestId, function (data)
        print("reauth成功")
        if not TEST_REAUTH then
            -- dump(data)
            if data.error then
                self._reconnectTimeOutTick = nil
                self:onError({code = data.error.code})
                return
            end
            self._reconnectTimeOutTick = nil
            print("重连成功")
            -- self:setPushEnabled(true)
            self._state = ServerManager.STATE_CONNECTED
            self._viewMgr:unlock(-2)

            local data
            -- 把所有在断线过程中发的请求发出去
            for i = 1, #self._saveRequestMap do
                data = self._saveRequestMap[i]
                print("batch send", data[3], data[4])
                self:sendMsg(data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8])
            end
            self._saveRequestMap = {}
            -- 把所有已经发出,没有回应的请求重新请求,并且刷新timeout时间
            for _rid, _data in pairs(self._serverRequestMap) do
                print("resend", _data[3], _data[4])
                self._kakuraSocket:reSend(_data[3], _rid, _data[4])
                self._badNetMap[_rid] = 1
                self._checkTimeOutMap[_rid][2] = socket.gettime() + TIMEOUT
            end
            if self._heartBeatDCSender then
                print("ScheduleMgr:cleanMyselfDelayCall(self._heartBeatDCSender)22")
                ScheduleMgr:cleanMyselfDelayCall(self._heartBeatDCSender)
                self._heartBeatDCSender = nil
            end
            if self.__WillEnterForegroundCallback then
                self._viewMgr:unlock(-532)
                self.__WillEnterForegroundCallback()
                self.__WillEnterForegroundCallback = nil
            end
            self._viewMgr:onReconnect()
            self._reconnectCount = 0
        end
    end)
end

-- 需要退出游戏重新登录时候用到
-- 断线的时候
function ServerManager:clear()
    if self._kakuraSocket then
        self._returnLogin = true
        self._reconnectTimeOutTick = nil
        self._kakuraSocket:clear()
        self._returnLogin = false
    end
    self:_clearMap()
    self._state = ServerManager.STATE_NONE
    if self._heartBeatUpdateId then
        ScheduleMgr:unregSchedule(self._heartBeatUpdateId)
    end
    if self._UpdateId then
        ScheduleMgr:unregSchedule(self._UpdateId)
    end
    if self._TssUpdateId then
        ScheduleMgr:unregSchedule(self._TssUpdateId)
    end
    self._token = nil
    self._isSending = 0
    print("clear self._isSending: ", self._isSending)
    self:RS_clear()
end

-- 主动断开连接
function ServerManager:connect()
    if self._dontReconnect then return end
    print("======connect======")
    self._reconnectTimeOutTick = nil
    ScheduleMgr:nextFrameCall(self, function()
        self._kakuraSocket:init(GameStatic.ipAddress, function ()
            self:reconnect()
        end)         
    end)

end

function ServerManager:disconnect()
    if self._kakuraSocket then
        print("******disconnect******")
        self._reconnectTimeOutTick = nil
        self._kakuraSocket:clear()
    end
end

function ServerManager:setDontReconnect(value)
    self._dontReconnect = value
end

function ServerManager:applicationDidEnterBackground()
    if self._heartBeatDCSender then
        ScheduleMgr:cleanMyselfDelayCall(self._heartBeatDCSender)
        self._heartBeatDCSender = nil
    end
    if self.__WillEnterForegroundCallback then
        self.__WillEnterForegroundCallback = nil
        self._viewMgr:unlock(-533)
    end
end

function ServerManager:applicationWillEnterForeground(second, callback)
    -- 返回前台的时候，发送一个心跳去测试连接状况
    if self._state == ServerManager.STATE_CONNECTED then
        print("serverMgr applicationWillEnterForeground STATE_CONNECTED")
        self.__WillEnterForegroundCallback = callback
        self._viewMgr:lock(531)
        self._kakuraSocket:heartBeat("heartBeat", function ()
            if ScheduleMgr == nil then return end
            print("__WillEnterForegroundCallback")
            if self._heartBeatDCSender then
                print("ScheduleMgr:cleanMyselfDelayCall(self._heartBeatDCSender)11")
                ScheduleMgr:cleanMyselfDelayCall(self._heartBeatDCSender)
                self._heartBeatDCSender = nil
            end
            if self.__WillEnterForegroundCallback then
                self._viewMgr:unlock(-531)
                self.__WillEnterForegroundCallback()
                self.__WillEnterForegroundCallback = nil
            end
        end)
        self._heartBeatDCSender = {}
        ScheduleMgr:delayCallEx(3000, self._heartBeatDCSender, function()
            print("ScheduleMgr:delayCallEx(3000, self._heartBeatDCSender")
            self._heartBeatDCSender = nil
            self:_reinit(4)
        end)
    else
        print("serverMgr applicationWillEnterForeground state: ", self._state)
        callback()
    end
end

function ServerManager:pauseLock()
    if self._pauseLockCount == nil then self._pauseLockCount = 0 end
    self._pauseLockCount = self._pauseLockCount + 1
    if self._pauseLockCount == 1 then
        self._viewMgr:pauseLock()
        self._viewMgr:disableChangeView()
    end
end

function ServerManager:resumeLock()
    if self._pauseLockCount == nil then self._pauseLockCount = 0 end
    if self._pauseLockCount <= 0 then return end
    self._pauseLockCount = self._pauseLockCount - 1
    if self._pauseLockCount <= 0 then
        self._viewMgr:resumeLock()
        self._viewMgr:enableChangeView()
    end 
end

-- ========================================================================================================================================================
-- ========================================================================================================================================================
-- ========================================================================================================================================================
-- 实时（java）服务器相关的连接
-- ========================================================================================================================================================
-- ========================================================================================================================================================
-- ========================================================================================================================================================
ServerManager.RS_STATE_NONE = 1 
ServerManager.RS_STATE_CONNECTED = 2 
ServerManager.RS_STATE_RECONNECT = 3
ServerManager.RS_STATE_CONNECTING = 4 
function ServerManager:RS_init()
    if self._RS_isInit then return end
    self._RS_isInit = true
end

-- data 为连接参数
-- data = 
-- {
--     url = url,
--     checkKey = checkKey,
--     mtime = mtime,
--     rid = rid,
--     roomId = roomId,
--     platform = platform,
-- }

-- initCallback 用于首次连接成功
-- 回应需要使用model来监听 :listenRSResponse()

function ServerManager:RS_initSocket(data, initCallback)
    self:RS_init()
    self:RS_clear()

    self._RS_data = data

    self._RS_Socket = kakuraSocket.new()
    self._RS_state = ServerManager.RS_STATE_CONNECTING
    self._RS_initCallback = initCallback

    self._RS_reconnectRef = 0
    self._RS_reconnectCount = 0

    self._RS_lockCount = 0

    self._RS_Socket:setRequestId(100000)
    self:RS_lock(511)

    self._RS_updateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
        self:RS_update()
    end)
    local inv = 5000
    if GameStatic.SR_HeartInv then
        inv = GameStatic.SR_HeartInv
    end
    self._RS_heartBeatUpdateId = ScheduleMgr:regSchedule(inv, self, function(self, dt)
        if self._RS_state == ServerManager.RS_STATE_CONNECTED then
            if self._RS_HeartBeating then
                self:RS_reinit()
                return
            end
            self._RS_HeartBeating = true
            self._RS_Socket:heartBeat("PlayerProcessor.heartBeat", function ()
                print("heartBeat rs ok")
                self._RS_HeartBeating = false
            end)
        end
    end)
    self._RS_initTimeOutTick = socket.gettime() + TIMEOUT
    self._RS_Socket:init(self._RS_data.url, function ()
        self._RS_initTimeOutTick = nil
        self._RS_loginTimeOutTick = socket.gettime() + TIMEOUT
        self:RS_login(function (data)
            self._RS_loginTimeOutTick = nil
            self._RS_reconnectCount = 0
            self._RS_state = ServerManager.RS_STATE_CONNECTED

            if self._RS_initCallback then 
                self._RS_initCallback(0) 
                self._RS_initCallback = nil
            end
            self:RS_onResponse("notify", data)
            self:RS_unlock(11)
        end)
    end)
    self._RS_Socket:setCallback(function (event, msg, rid)
        if not trycall("onResponse", self.RS_onResponse, self, event, msg, rid) then
            
        end
    end)
end

function ServerManager:RS_update()
    if self._RS_state == ServerManager.RS_STATE_RECONNECT or self._RS_state == ServerManager.RS_STATE_CONNECTING then
        local tick = socket.gettime()
        -- init超时
        if self._RS_initTimeOutTick and tick > self._RS_initTimeOutTick then
            print("rs init超时")
            self:RS_unlock(15)
            self._RS_initTimeOutTick = nil
            if self._RS_initCallback then 
                self._RS_initCallback(1) 
                self._RS_initCallback = nil
            end
            self:RS_clear()
        end
        -- 登录超时
        if self._RS_loginTimeOutTick and tick > self._RS_loginTimeOutTick then
            print("rs login超时")
            self:RS_unlock(15)
            self._RS_loginTimeOutTick = nil
            self:RS_reinit()
        end 
    end
end

function ServerManager:RS_onResponse(event, data, rid)
    print("RS_onResponse", event, data, rid)
    -- dump(data)
    if event == "response" then
        self:_RS_onResponse(data)
    elseif event == "notify" then
        self:_RS_onResponse(data)
    elseif event == "close" then
        self:RS_onClose()
    elseif event == "error" then
        self:RS_onError(data)
    end
end

function ServerManager:_RS_onResponse(data)
    for sender, callback in pairs(self._RSResponseListeners) do
        trycall("RSResponseListeners"..sender:getClassName(), callback, data)
    end
end

function ServerManager:RS_onClose()
    self:RS_reinit()
end

function ServerManager:RS_onError(data)
    print("RS_onError", data.errorcode)
    if data.errorcode == 1 then
        if self._RS_reconnectCB then 
            self._RS_reconnectCB() 
            self._RS_reconnectCB = nil
        end
        self:RS_unlock(13)
        print("self._RS_reconnectCount", self._RS_reconnectCount)
        self:RS_reinit()
    else
        self:RS_clear()
        self:_RS_onResponse({error = {code = 222222, message = data}})
    end
end

function ServerManager:RS_lock(...)
    self._RS_lockCount = self._RS_lockCount + 1
    self._viewMgr:lock(...)
end

function ServerManager:RS_unlock(...)
    self._RS_lockCount = self._RS_lockCount - 1
    self._viewMgr:unlock(...)
end

function ServerManager:RS_clearlock()
    if self._RS_lockCount == nil then return end
    for i = 1, self._RS_lockCount do
        self._viewMgr:unlock()
    end
    self._RS_lockCount = 0
end

function ServerManager:RS_reinit()
    if self._RS_state == ServerManager.RS_STATE_NONE then return end
    if self._RS_reconnectRef ~= 0 then return end
    print("RS_reinit")
    self._RS_reconnectCount = self._RS_reconnectCount + 1
    self._RS_reconnectRef = self._RS_reconnectRef + 1
    print("_RS_reconnectRef", self._RS_reconnectRef)
    self:RS_disconnect()
    self._RS_HeartBeating = false
    self._RS_state = ServerManager.RS_STATE_RECONNECT
    
    if self._viewMgr:isViewChanging() then
        self._viewMgr:setViewChangeEndCallback(function ()
            if self.__RS_reinit then
                self:__RS_reinit()
            end
        end)
    else
        self:__RS_reinit()
    end
end
function ServerManager:__RS_reinit()
    self:pauseLock()
    local dialog = self._viewMgr:showDialog("global.NetWorkDialog", {msg = "您的网络打了个小喷嚏，连接断掉了，要重新连接吗？", 
    title1 = "重新连接", 
    callback1 = function ()
        self:resumeLock()
        self:RS_connect()
    end,
    title2 = "放弃重连", 
    callback2 = function ()
        self:resumeLock()
        local value = self._viewMgr:isEnableChangeView()
        self:_RS_onResponse({error = {code = 111111}})
        self:RS_clear()
        self._viewMgr:enableChangeView()
        if value then
            self._viewMgr:disableChangeView()
        else
            self._viewMgr:enableChangeView()
        end
    end})
    dialog:setLocalZOrder(10000)
end

function ServerManager:RS_disconnect()
    if self._RS_Socket then
        self._RS_Socket:clear()
    end
end

function ServerManager:RS_connect()
    ScheduleMgr:nextFrameCall(self, function()
        self._RS_reconnectCB = function ()
            self._RS_reconnectRef = self._RS_reconnectRef - 1
            print("_RS_reconnectRef", self._RS_reconnectRef)
        end
        self:RS_lock(512)
        self._RS_initTimeOutTick = socket.gettime() + TIMEOUT
        self._RS_Socket:init(self._RS_data.url, function ()
            self._RS_initTimeOutTick = nil
            self._RS_reconnectRef = self._RS_reconnectRef - 1
            print("_RS_reconnectRef", self._RS_reconnectRef)
            
            self._RS_loginTimeOutTick = socket.gettime() + TIMEOUT
            -- 重新登录
            self:RS_login(function (data)
                if self._RS_initCallback then 
                    self._RS_initCallback(0) 
                    self._RS_initCallback = nil
                end
                self._RS_state = ServerManager.RS_STATE_CONNECTED
                self._RS_reconnectCount = 0
                self:RS_onResponse("notify", data)
                self._RS_loginTimeOutTick = nil

                self:RS_unlock(14)
            end)
        end)       
    end)
end

-- 每次连接上需要调用
function ServerManager:RS_login(callback)
    print("RS_login")

    local data = self._RS_data
    self._RS_Socket:login(data.checkKey, data.mtime, data.rid, data.roomId, data.platform, data.sec, callback)
end

function ServerManager:RS_sendMsg(name, act, context)
    if not self._RS_isInit then return end
    if self._RS_state ~= ServerManager.RS_STATE_CONNECTED then
        return
    end
    self._RS_Socket:sendMsg(name, act, context)
end

function ServerManager:RS_getState()
    return self._RS_state
end

function ServerManager:RS_clear()
    if not self._RS_isInit then return end
    if self._RS_Socket then
        self._RS_Socket:setCallback(function () end)
        self._RS_state = ServerManager.RS_STATE_NONE
        self._RS_Socket:clear()
    end
    self._RSResponseListeners = {}
    self._RS_loginTimeOutTick = nil
    self._RS_initTimeOutTick = nil
    self._RS_state = ServerManager.RS_STATE_NONE
    if self._RS_updateId then
        ScheduleMgr:unregSchedule(self._RS_updateId)
        self._RS_updateId = nil
    end
    if self._RS_heartBeatUpdateId then
        ScheduleMgr:unregSchedule(self._RS_heartBeatUpdateId)
        self._RS_heartBeatUpdateId = nil
    end
    self:RS_clearlock()
end

function ServerManager:getSocketCount()
    return kakuraSocket.getCount()
end


function ServerManager.dtor()
    _serverManager = nil
    kakuraSocket = nil
    TIMEOUT = nil
    TEST_RECV = nil
    TEST_SEND = nil
    TEST_REAUTH = nil
    TEST_DISCONNECT = nil
    last_onResponse_index = nil
    msgTab = nil
end

return ServerManager