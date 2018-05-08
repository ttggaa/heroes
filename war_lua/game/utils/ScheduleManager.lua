--[[
    Filename:    updateManager.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-01-16 11:29:11
    Description: File description
--]]
local ScheduleManager = class("ScheduleManager")

function ScheduleManager:ctor()
    self._pool = {}
    self._delayPool = {}
    self._delayCount = 0
    self._delayTicker = nil
    self._pause = false
end

function ScheduleManager:regSchedule(time,target,hander, ... )
    if target then
        -- print("info","regSchedule from view " .. target:className())
    end
    assert(hander ~= nil, "regSchedule func is nil")
    local event = {
        _target     = target,
        _callBack   = target ~= nil and specialize(hander,target) or hander
    }
    local args = { ... }
    local function scheduleFunc(dt)
        event._callBack(dt, unpack(args) )
    end
    local eventId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(scheduleFunc, time * 0.001, false)
    self._pool[eventId] = event;
    return eventId
end
function ScheduleManager:unregSchedule(eventId)
    if eventId == nil then return end
    assert(eventId ~= nil, "unregSchedule entry is nil")
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(eventId) 
    if self._pool[eventId] then 
        if self._pool[eventId]._target then
            -- print("info","unregSchedule from view " .. self._pool[eventId]._target:className())
        end
        self._pool[eventId] = nil
    end 
    return nil
end

function ScheduleManager:update(dt)
    if self._pause then return end
    if self._delayCount == 0 then
        self:unregSchedule(self._delayTicker)
        self._delayTicker = nil
        self._delayPool ={}
        return
    end
    local tick = socket.gettime()
    for k, v in pairs(self._delayPool) do 
        self:dealDelayEvent(k,v,tick)
    end
end

function ScheduleManager:dealDelayEvent(index,event,tick)
    if tick >= event._runTime then
        if event._nextFrame then
            event._nextFrame = nil
            return
        end
        self._delayCount = self._delayCount - 1
        self._delayPool[index] = nil 
        event._callBack()
    end
end
function ScheduleManager:createDelayTicker()
    if self._delayTicker == nil  then 
        self._delayPool = {}
        self._delayTicker = self:regSchedule(0,self,self.update)
    end
    return self._delayTicker

end
function ScheduleManager:delayCall(delayTime,target,hander, ...)
    if delayTime == nil then delayTime = 0 end
    self:createDelayTicker()
    local event = 
    {
        _target = target,
        _callBack = target ~= nil and specialize(hander,target,...) or hander,
        _runTime = socket.gettime() + delayTime * 0.001,
        _force = self._pause,
    }

    table.insert(self._delayPool, event)
    self._delayCount = self._delayCount + 1
end
-- 不受切后台影响
function ScheduleManager:delayCallEx(delayTime,target,hander, ...)
    if delayTime == nil then delayTime = 0 end
    self:createDelayTicker()
    local event = 
    {
        _target = target,
        _callBack = target ~= nil and specialize(hander,target,...) or hander,
        _runTime = socket.gettime() + delayTime * 0.001,
        _force = true,
    }

    table.insert(self._delayPool, event)
    self._delayCount = self._delayCount + 1
end
function ScheduleManager:nextFrameCall(target,hander, ...)
    self:createDelayTicker()
    local event = 
    {
        _target = target,
        _callBack = target ~= nil and specialize(hander,target,...) or hander,
        _runTime = socket.gettime(),
        _nextFrame = true,
    }
    table.insert(self._delayPool, event)
    self._delayCount = self._delayCount + 1
end
function ScheduleManager:cleanMyselfDelayCall(target)
    for k, v in pairs(self._delayPool) do 
        if v._target == target then
            self._delayCount = self._delayCount -1
            self._delayPool[k] = nil 
        end
    end
end
function ScheduleManager:cleanMyselfTicker(target)
    local count = 0
    for k, v in pairs(self._pool) do 
        if v._target == target then 
            count = count + 1
            self:unregSchedule(k)
            self._pool[k] = nil
        end
    end
    return count
end

function ScheduleManager:pause()
    self._pause = true
    self._pauseTick = socket.gettime()
end

function ScheduleManager:resume()
    self._pause = false
    local addTick = socket.gettime() - self._pauseTick
    for k, v in pairs(self._delayPool) do 
        if not v._force then
            v._runTime = v._runTime + addTick
        end
    end    
end

function ScheduleManager:clear()
    self._delayCount = 0
    self:unregSchedule(self._delayTicker)
    self._delayTicker = nil
    self._delayPool = {}
end

function ScheduleManager.dtor()

end

return ScheduleManager