--
-- Author: huangguofang
-- Date: 2018-10-09 15:41:17
--
local RaceDrawModel = class("RaceDrawModel", BaseModel)

function RaceDrawModel:ctor()
    RaceDrawModel.super.ctor(self)
    self._raceDrawData = {}
    self._userModel = self._modelMgr:getModel("UserModel")
    
end

function RaceDrawModel:setData(data)
    if not data.raceDraws then 
        return
    end
    self._raceDrawData = data.raceDraws or {}
    dump(self._raceDrawData,"self._raceDrawData==>",5)
end

function RaceDrawModel:updateData(data)
    if not data then 
        return
    end
    if table.nums(self._raceDrawData) == 0 then
        self._raceDrawData = data
        return
    end
    for k,v in pairs(data) do
        if self._raceDrawData[k] then
            for kk,vv in pairs(v) do
                self._raceDrawData[k][kk] = vv
            end
        end
    end

end

function RaceDrawModel:getData()
    -- dump(self._raceDrawData,"getData=>",5)
    return self._raceDrawData
end

-- 是否免费 主界面提示
function RaceDrawModel:haveFreeTips()
    -- dump(self._raceDrawData,"getData=>",5)
    if not SystemUtils["enableRaceDraw"]() then
        return false
    end
    local stateNum = 1
    local isHave = false
    for k,v in pairs(self._raceDrawData) do
        stateNum = self:getStateNum(k)
        if stateNum == 0 then
            isHave = true
            break
        end
    end

    return isHave
end

-- 是否半价 主界面提示
function RaceDrawModel:haveHalfTips()
    -- dump(self._raceDrawData,"getData=>",5)
    if not SystemUtils["enableRaceDraw"]() then
        return false
    end
    local stateNum = 1
    local isHave = false
    for k,v in pairs(self._raceDrawData) do
        stateNum = self:getStateNum(k)
        if stateNum == 0.5 then
            isHave = true
            break
        end
    end

    return isHave
end

--[[
-- 某阵营是免费或者半价
    1   ------>  全价
    0.5 ------>  半价
    0   ------>  免费
]]
function RaceDrawModel:getStateNum(pRaceId)
    -- print("==========pRaceId=====",pRaceId)
    -- dump(self._raceDrawData,"self._raceDrawData==>",5)
    local raceId = tostring(pRaceId)
    if not self._raceDrawData[raceId] then
        return 1
    end
    if not SystemUtils["enableRaceDraw"]() then
        return 1
    end
    local raceData = self._raceDrawData[raceId] or {}
    -- 有免费次数
    if raceData.freeTimes and raceData.freeTimes == 0 then 
        return 0
    end

    -- 有半价次数
    if raceData.halfPriceTimes and raceData.halfPriceTimes == 0 then 
        return 0.5
    end

    if raceData.UpdateHalfPriceTime then 
        -- 半价
        local lastUpdateTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(raceData.UpdateHalfPriceTime,"%Y-%m-%d 05:00:00"))
        if lastUpdateTime > raceData.UpdateHalfPriceTime then
            lastUpdateTime = lastUpdateTime - 86400
        end
        -- print("============lastUpdateTime====",lastUpdateTime,currTime)
        local currTime = self._userModel:getCurServerTime()
        if currTime - lastUpdateTime > 86400 then
            return 0.5
        end
    end

    return 1
end


return RaceDrawModel