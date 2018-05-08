--
-- Author: huangguofang
-- Date: 2017-09-15 15:41:24
--

local AcLotteryModel = class("AcLotteryModel", BaseModel)

function AcLotteryModel:ctor()
    AcLotteryModel.super.ctor(self)
    self._lotteryData = {}
    self._userModel = self._modelMgr:getModel("UserModel")
    
end

function AcLotteryModel:setData(data)
    self._lotteryData = data    
end

function AcLotteryModel:getData()
	-- dump(self._lotteryData,"getData=>",5)
    return self._lotteryData
end
function AcLotteryModel:setOutOfDate()
    self:reflashData("OutOfDate")
end

function AcLotteryModel:updateData(data, eventName)
    if not self._isRegistered then
        self:registerTaskTimer()
    end
    if not data or type(data) ~= "table" then return end
    local processData = nil
    processData = function(a, b)
        for k, v in pairs(b) do
            if type(a[k]) == "table" and type(v) == "table" then
                processData(a[k], v)
            else
                a[k] = v
            end
        end
    end
    processData(self._lotteryData, data)
    -- dump(self._lotteryData,"self._lotteryData==>",5)
    -- self:reflashData(eventName)
end

function AcLotteryModel:isLotteryOpen()
    if not self._showData then 
        self._showData = self._modelMgr:getModel("ActivityModel"):getAcShowDataByType(28)
    end 
    -- dump(self._showData,"self._showData==>",5)
	local currTime = self._userModel:getCurServerTime() 
    local starTime = self._showData.start_time or currTime
    local endTime = self._showData.end_time or currTime
    local isOpen = starTime <= currTime and endTime > currTime
	return isOpen
end

-- 定时器
function AcLotteryModel:registerTaskTimer()
    if not self:isLotteryOpen() then return end
    self._isRegistered = true 
    self:registerTimer(22, 0, 0, specialize(self.setOutOfDate, self))
    local registerTab = {}
    local lotteryTime = tab:LotterySetting("lotterytime").num
    for t = lotteryTime[1], lotteryTime[2], 2 do
        -- 开奖前5秒钟
        registerTab[t .. ":" .. 59 .. ":" .. 55] = true
    end
    for time, _ in pairs(registerTab) do
        local list = string.split(time, ":")
        self:registerTimer(tonumber(list[1]), tonumber(list[2]), tonumber(list[3]), function()
            local intPointData = self._lotteryData
            -- dump(intPointData,"registerTaskTimer==>",5)
            if intPointData and intPointData.drawCode and type(intPointData.drawCode) == "table" and #intPointData.drawCode > 0 then
                -- 开奖前5秒钟 参与抽奖的人需要播放得奖动画
            -- print("=======registerTaskTimer======")
                self:setIntPointEffectPlayed(false)
            end
        end)
    end
end
function AcLotteryModel:setIntPointEffectPlayed(isPlayed)
    SystemUtils.saveAccountLocalData("AC_LORTTERY_EFFECT_PLAYED", isPlayed and 1 or 0)
end

function AcLotteryModel:getIntPointEffectPlayed()
    return 1 == SystemUtils.loadAccountLocalData("AC_LORTTERY_EFFECT_PLAYED")
end

function AcLotteryModel:isIntPointNeedPlayEffect()
    local intPointData = self:getData()
    if not intPointData then return false end
    if not self:isLotteryOpen() then return false end
    local currentTime = self._userModel:getCurServerTime()
    local beginHour = intPointData.hourStart
    local endHour = intPointData.hourEnd
    local nowTime = TimeUtils.date("*t", currentTime)
    if nowTime.hour >= beginHour and nowTime.hour < endHour then
        -- 参与抽奖，没有播放开奖动画
        -- print("===========",beginHour % 2,nowTime.hour % 2,nowTime.min,nowTime.min,#intPointData.drawCode,self:getIntPointEffectPlayed())
        if beginHour % 2 ~= nowTime.hour % 2 and nowTime.min >= 0 and nowTime.min < 55 and #intPointData.drawCode > 0 and not self:getIntPointEffectPlayed() then
            return true
        end
    end
    return false
end

-- 狂欢有没有奖励
--[[
    status -1   --未参与
            0   --参与了未开奖
            1   --未中奖未领取
            2   --未中奖已领取
            3   --中奖未领取
            4   --中奖已领取
]]
function AcLotteryModel:isLotteryRed()
    if not self._lotteryData or not self._lotteryData.lastTakeHour then 
        return false
    end
    if not self:isLotteryOpen() then return false end
    local isRed = false
    local intPointData = self._lotteryData
    -- 上次抽奖时间 2017100512 年月日时
    local lastTakeHour = intPointData.lastTakeHour or 0
    -- print("===============lastTakeHour==",lastTakeHour)
    local status = intPointData.status or -1
    local currentTime = self._userModel:getCurServerTime()
    local beginHour = intPointData.hourStart
    local endHour = intPointData.hourEnd
    local nowTime = TimeUtils.date("*t", currentTime)
    if nowTime.hour >= beginHour and nowTime.hour < endHour then
        -- 抽奖时间
        if beginHour % 2 == nowTime.hour % 2 then
            isRed = false
        else
            local currTimeStr = string.format("%d%02d%02d%02d", nowTime.year, nowTime.month, nowTime.day, nowTime.hour)
            -- print("================currTimeStr=====",currTimeStr,lastTakeHour)
            local subTime = tonumber(currTimeStr) - tonumber(lastTakeHour)
            if subTime == 1 then 
                return status == 1 or status == 3
            end
        end
    else
        isRed = false
    end
    return isRed
end

return AcLotteryModel
