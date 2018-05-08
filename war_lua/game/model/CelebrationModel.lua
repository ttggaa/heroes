
--[[
    Filename:    CelebrationModel.lua
    Author:      <huangguofang@playcrab.com>
    Datetime:    2017-06-30 16:59:00
    Description: 公测庆典
--]]

local CelebrationModel = class("CelebrationModel", BaseModel)

function CelebrationModel:ctor()
    CelebrationModel.super.ctor(self)
    self._data = {}
    self._modelMgr = ModelManager:getInstance()
    self._userModel = self._modelMgr:getModel("UserModel")
    self:registerTaskTimer()
end

function CelebrationModel:updateData(data, eventName)
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
    processData(self._data, data)
    -- dump(self._data,"self._data==>",5)
    self:reflashData(eventName)
end

function CelebrationModel:getData()
	return self._data
end
-- 获取集字狂欢数据
function CelebrationModel:getCollectionCeleData()
	return self._data.collectionCele
end

function CelebrationModel:registerTaskTimer()
    local registerTab = {}
    local celebrationTime = tab:CelebrationSetting("lotterytime").num
    for t = celebrationTime[1], celebrationTime[2], 2 do
        registerTab[t .. ":" .. 59 .. ":" .. 55] = true
    end
    for time, _ in pairs(registerTab) do
        local list = string.split(time, ":")
        self:registerTimer(tonumber(list[1]), tonumber(list[2]), tonumber(list[3]), function()
            local intPointData = self:getPunctualityCeleData()
            if intPointData and intPointData.drawCode and type(intPointData.drawCode) == "table" and #intPointData.drawCode > 0 then
                self:setIntPointEffectPlayed(false)
            end
        end)
    end
end

-- 获取整点狂欢数据
function CelebrationModel:getPunctualityCeleData()
	return self._data.punctualityCele
end

-- 获取好友狂欢数据
function CelebrationModel:getFriendCeleData()
	return self._data.friendCele
end

-- 获取公测庆典开始结束时间
function CelebrationModel:getCelebrationTime( )
    local starTime = self._data.startTime or 0
    local endTime = self._data.endTime or 0
    return starTime ,endTime
end

-- 集字狂欢 需要提示
function CelebrationModel:isCollectionNeedRed()

    -- 集字有可以领取的礼物
    if self._data and self._data.collectionCele then
        if self._data.collectionCele.open and self._data.collectionCele.open == 1 then
            if self._data.collectionCele.hasGift and self._data.collectionCele.hasGift == 1 then
                return true
            end
        end
    end

    -- 集字集齐可以领取奖励
    if self._data and self._data.collectionCele then
        if self._data.collectionCele.open and self._data.collectionCele.open == 1 then
            if self._data.collectionCele.hasReceived and self._data.collectionCele.hasReceived == 0  then
                return true
            end
        end
    end

    return false

end

function CelebrationModel:isIntPointNeedRed()
    local intPointData = self:getPunctualityCeleData()
    if not intPointData then return false end
    if 1 ~= intPointData.open then return false end
    local currentTime = self._userModel:getCurServerTime()
    local beginHour = intPointData.hourStart
    local endHour = intPointData.hourEnd
    local nowTime = TimeUtils.date("*t", currentTime)
    if nowTime.hour >= beginHour and nowTime.hour < endHour then
        if beginHour % 2 == nowTime.hour % 2 and #intPointData.drawCode <= 0 then
            return true
        end
    end

    return false
end

function CelebrationModel:setIntPointEffectPlayed(isPlayed)
    SystemUtils.saveAccountLocalData("AC_INT_POINT_EFFECT_PLAYED", isPlayed and 1 or 0)
end

function CelebrationModel:getIntPointEffectPlayed()
    return 1 == SystemUtils.loadAccountLocalData("AC_INT_POINT_EFFECT_PLAYED")
end

function CelebrationModel:isIntPointNeedPlayEffect()
    local intPointData = self:getPunctualityCeleData()
    if not intPointData then return false end
    if 1 ~= intPointData.open then return false end
    local currentTime = self._userModel:getCurServerTime()
    local beginHour = intPointData.hourStart
    local endHour = intPointData.hourEnd
    local nowTime = TimeUtils.date("*t", currentTime)
    if nowTime.hour >= beginHour and nowTime.hour < endHour then
        if beginHour % 2 ~= nowTime.hour % 2 and nowTime.min >= 0 and nowTime.min < 55 and #intPointData.drawCode > 0 and not self:getIntPointEffectPlayed() then
            return true
        end
    end
    return false
end

-- 好友狂欢 需要提示
function CelebrationModel:isFriendNeedRed()
     -- 好友狂欢 有可以领取的奖励
    if self._data and self._data.friendCele then
        if self._data.friendCele.open and self._data.friendCele.open == 1 then
            local isNeedRed = false
            local receiveGift = self._data.friendCele.receiveGift 
            local receiveGiftArr = {}
            if receiveGift then
                receiveGiftArr = json.decode(receiveGift)
            end
            if not receiveGiftArr then
                receiveGiftArr = {}
            end
            for k,v in pairs(receiveGiftArr) do
                if v == 0 then
                    isNeedRed = true 
                    break
                end
            end

            if isNeedRed then
                return true
            end
        end
    end

    return false
end

-- 主界面需要提示
function CelebrationModel:isMainIconNeedRed()

    -- 集字狂欢 
    if self:isCollectionNeedRed() then
        return true 
    end

    -- 整点狂欢
    if self:isIntPointNeedRed() then
        return true 
    end 

    -- 好友狂欢 有可以领取的奖励
    if self:isFriendNeedRed() then       
        return true
    end

    return false
end

-- 活动是否结束
function CelebrationModel:isCelebrationEnd( )
    local currTime = self._userModel:getCurServerTime() 
    -- local starTime = self._data.startTime or currTime
    local endTime = self._data.endTime or currTime
    return endTime > currTime
end

return CelebrationModel