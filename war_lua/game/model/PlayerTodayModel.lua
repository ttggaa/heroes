--[[
    Filename:    PlayerTodayModel.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-05-25 12:13:22
    Description: File description
--]]

local PlayerTodayModel = class("PlayerTodayModel", BaseModel)

function PlayerTodayModel:ctor()
    PlayerTodayModel.super.ctor(self)
    self._drawAward = {}
    self._bubble = {}
    self:registerTimer(5,0,0,function( )
        self:checkDay()
    end)
end

function PlayerTodayModel:getData()
    self:checkDay()
    return self._data
end

function PlayerTodayModel:checkDay()
    -- edit by vv 利用服务器时间进行更新
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local lastResetTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._data.restTime,"%Y-%m-%d 05:00:00"))
    local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime >= tempTodayTime and 
        tempTodayTime > lastResetTime then
    -- local currentDay = os.date("*t")
    -- local lastDay = os.date("*t", self._data.restTime)
    -- if lastDay.day ~= currentDay.day then
        -- self._data = {
        --     day1 = 0,
        --     day2 = 0,
        --     day3 = 0,
        --     day4 = 0,
        --     restTime = os.time()
        -- }
        self:initData()
    end
end

function PlayerTodayModel:initData()
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    -- self._data = {}
    if self._data == nil then self._data = {} end
    for k,v in pairs(self._data) do
        self._data[k] = 0
    end
    -- for i =1,50 do
    --     self._data["day" .. i] = 0
    -- end
    self._data.restTime = curServerTime
end

function PlayerTodayModel:setDayInfo(dayType, num)
    self:checkDay()
    self._data["day" .. dayType] = num
    self:reflashData()
end

function PlayerTodayModel:getDayInfo( dayType )
    return self._data["day" .. dayType] or 0
end

-- 子类覆盖此方法来存储数据
function PlayerTodayModel:setData(data)
    if not data then
        self:initData()
    else
        self._data = data
    end
    -- for i =1,50 do
    --     if self._data["day" .. i] == nil then 
    --         self._data["day" .. i] = 0
    --     end
    -- end
    self:checkDay()
    self:reflashData()
end

function PlayerTodayModel:setDrawAward(data )
    self._drawAward  = data or {}
end

function PlayerTodayModel:getDrawAward( )
    return self._drawAward
end

function PlayerTodayModel:updateDayInfo( data )
    dump(data, "data ===========")
    for k,v in pairs(data) do
        -- if self._data[k] then
            self._data[k] = v
        -- end
    end
    self:reflashData()
end

function PlayerTodayModel:updateDrawAward( data )
    for k,v in pairs(data) do
        -- if self._drawAward[k] then
            self._drawAward[k] = v
        -- end
    end
    self:reflashData()
end

function PlayerTodayModel:getNextFreeDrawTime( )
    local toolTime,teamTime = 0,0
    local lastToolTime,lastTeamTime = self._drawAward.drawToolLastTime,(self._drawAward.drawTeamLastTime or 0)
    local now = os.time()
    if now < lastToolTime then
        toolTime = lastToolTime
    end
    if now < lastTeamTime then
        teamTime = lastTeamTime
    end
    return toolTime,teamTime
end

function PlayerTodayModel:updateBubble( inData )
    dump(inData, "updateBubble=====", 10)
    if not inData then return end
    for k,v in pairs(inData) do
        self._bubble[k] = v
        if k == "b1" and tonumber(v) == 2 then
            self.newArenaReport = true
        end
    end
    self:reflashData()
end

function PlayerTodayModel:updateBubble1( inData )
    dump(inData, "updateBubble=====", 10)
    if not inData then return end
    for k,v in pairs(inData) do
        self._bubble[k] = v
        if k == "b1" and tonumber(v) == 2 then
            self.newArenaReport = true
        end
    end
end

function PlayerTodayModel:getBubble()
    return self._bubble
end

return PlayerTodayModel