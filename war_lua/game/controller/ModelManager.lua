--[[
    Filename:    ModelManager.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-27 18:32:38
    Description: File description
--]]

local ModelManager = class("ModelManager")

local _modelManager = nil

function ModelManager:getInstance()
    if _modelManager == nil  then 
        _modelManager = ModelManager.new()
        return _modelManager
    end
    return _modelManager
end

function ModelManager:ctor()
    self._modelMap = {}
    self._timers = {}
    self._UpdateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
        self:update()
    end)
end

-- 要求model文件的目录结构正确 game.model.xxx
function ModelManager:_getModel(name)
    if self._modelMap[name] then
        return self._modelMap[name]
    else 
        self._modelMap[name] = require("game.model." .. name).new()
        self._modelMap[name]:setClassName(name)
        return self._modelMap[name]
    end
end

function ModelManager:getModel(name)
    return self:_getModel(name)
end

function ModelManager:hasModel(name)
    return self._modelMap[name] ~= nil
end

function ModelManager:listenModelReflash(name, mvcs)
    local model = self:_getModel(name)
    model:addReflashListener(mvcs)
end

function ModelManager:removeModelReflashListener(name, mvcs)
    local model = self:_getModel(name)
    model:removeReflashListener(mvcs)
end

-- 注册定时器, 服务器时间, 所以登陆之前禁止使用
function ModelManager:registerTimer(hour, min, sec, hander, callback)
    local key = hour.."_"..min.."_"..sec
    if self._timers[key] == nil then
        self._timers[key] = {
            callbacks = {},
            destTime = 0, -- 目标时间戳
            hour = hour,
            min = min,
            sec = sec,
            init = false, -- 是否通过服务器时间初始化, 如果此时间已经过了, 就+24h
        }
    end
    local list = self._timers[key].callbacks
    if list[hander] == nil then
        list[hander] = {callback}
    else
        list[hander][#list[hander] + 1] = callback
    end
end

--target 是否注册了相应的时间
function ModelManager:isExistTimeKey(key,target)
    if (not self._timers[key]) or (not self._timers[key].callbacks) then return end
    return self._timers[key].callbacks[target]
end

function ModelManager:clearSelfTimer(hander)
    for key, data in pairs(self._timers) do
        data.callbacks[hander] = nil
        -- 如果没有监听者了, 就清除
        if next(data.callbacks) == nil then
            self._timers[key] = nil
        end
    end
end

function ModelManager:setServerDeltaTime(dtime)
    self._serverDeltaTime = dtime
end

function ModelManager:update()
    if self._serverDeltaTime == nil then return end
    if TimeUtils.serverTimezone == nil then return end
    local serverTime = os.time() + self._serverDeltaTime
    for key, data in pairs(self._timers) do
        -- print((data.destTime - serverTime) / 3600, TimeUtils.date("%X", serverTime), TimeUtils.date("%X", data.destTime), os.date("*t").isdst)
        if not data.init then
            data.init = true
            data.destTime = os.time{year=os.date("%Y", serverTime), month=os.date("%m", serverTime), day=os.date("%d", serverTime), 
                hour=data.hour,min=data.min,sec=data.sec}
            data.hour = nil
            data.min = nil
            data.sec = nil
            data.destTime = data.destTime - (TimeUtils.serverTimezone - TimeUtils.localTimezone) - 86400
            if os.date("*t").isdst then
                data.destTime = data.destTime + 3600
            end
            -- print("###", serverTime, data.destTime, TimeUtils.serverTimezone, TimeUtils.localTimezone)
            while serverTime > data.destTime do
                -- 时间已过, 往后延24小时
                data.destTime = data.destTime + 86400
            end
        end
        if serverTime > data.destTime then
            print("timer", key)
            data.destTime = data.destTime + 86400
            for hander, callbackList in pairs(data.callbacks) do
                for i = 1, #callbackList do
                    callbackList[i](key)
                end
            end
        end
    end
end

-- 需要退出游戏重新登录时候用到
function ModelManager:clear()
    if self._UpdateId then
        ScheduleMgr:unregSchedule(self._UpdateId)
    end
    for k, v in pairs(self._modelMap) do
        v:clear()
        v:destroy()
        delete(self._modelMap[k])
        self._modelMap[k] = nil
    end
    self._modelMap = {}
    self._timers = {}
end

function ModelManager.dtor()
    _modelManager = nil
    ModelManager = nil
end

return ModelManager