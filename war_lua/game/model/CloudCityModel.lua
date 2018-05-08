--
-- Author: <ligen@playcrab.com>
-- Date: 2016-08-23 21:53:32
--
local CloudCityModel = class("CloudCityModel", BaseModel)

function CloudCityModel:ctor()
    CloudCityModel.super.ctor(self)

    self._acModel = self._modelMgr:getModel("ActivityModel")
end

function CloudCityModel:setUserData(data)
    -- 已通过最大关卡
    self._data["stageId"] = (data.stageId or 0)
    -- 已领取奖励的最高层
    self._data["fRewardId"] = data.fRewardId
end

---- 设置当前关卡信息
--function CloudCityModel:setCurStageData(data)
--    -- 当前关卡信息
--    if self._data["curStageInfo"] == nil then
--        self._data["curStageInfo"] = {}
--    end

--    local curStageId = (data.stageId or 0) + 1
--    curStageId = curStageId < #tab.towerStage and curStageId or #tab.towerStage
--    self._data["curStageInfo"]["stageId"] = curStageId

--    self._data["curStageInfo"]["firstPass"] = data.firstPass
--    self._data["curStageInfo"]["totalPass"] = data.totalPass
--    self._data["curStageInfo"]["floorName"] = data.floorName

--    -- 前半关的通关信息
--    self._data["curStageInfo"]["stageList"] = data.stageList
--end

--function CloudCityModel:getCurStageData()
--    return self._data["curStageInfo"]
--end

-- 设置已通过最大关卡
function CloudCityModel:setMaxStageId(stageId)
    self._data["stageId"] = stageId
end

-- 获取已通过最大关卡
function CloudCityModel:getPassMaxStageId()
    return self._data["stageId"] or 0
end

-- 获取已打到关卡
function CloudCityModel:getAttainStageId()
    local attainStageId = 0

    -- 判断是否领取层奖励
    if math.floor(self:getPassMaxStageId() / 4) > self:getMaxRewardId() then
        attainStageId = self:getPassMaxStageId()
    else
        attainStageId = self:getPassMaxStageId() + 1
    end
    attainStageId = attainStageId < #tab.towerStage and attainStageId or #tab.towerStage
    return attainStageId
end

-- 判断是否首次挑战本关
function CloudCityModel:getIsFirstFight(stageId)
    if tonumber(stageId) == self:getAttainStageId() then
        if stageId % 4 == 0 and math.floor(stageId / 4) == self:getMaxRewardId() then
            return false
        else
            return true
        end
    else
        return false
    end
end

-- 设置已领取最大奖励ID
function CloudCityModel:setMaxRewardId(fRewardId)
    self._data["fRewardId"] = fRewardId
end

-- 获取已领取最大奖励ID
function CloudCityModel:getMaxRewardId()
    return self._data["fRewardId"] or 0
end

---- 获取已打通到最大层
--function CloudCityModel:getMaxFloor()
--    return tab:TowerStage(self._data["stageId"]).floor
--end

-- 获取挑战剩余次数
function CloudCityModel:getChallengeTimes()
    local challengeTimes = self._modelMgr:getModel("PlayerTodayModel"):getData()["day30"] or 0
    local maxTimes = tab:Setting("G_CLOUD_CITY_TIME").value
    local PrivilegesTimes = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.CloudCityTimes)
    if PrivilegesTimes and PrivilegesTimes > 0 then
        maxTimes = maxTimes + PrivilegesTimes
    end
    local buyTimes = self._modelMgr:getModel("PlayerTodayModel"):getData()["day41"] or 0
    return maxTimes + buyTimes - challengeTimes
end

function CloudCityModel:getMaxChallengeTimes()
    local maxTimes = tab:Setting("G_CLOUD_CITY_TIME").value
    local PrivilegesTimes = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.CloudCityTimes)
    if PrivilegesTimes and PrivilegesTimes > 0 then 
        maxTimes = maxTimes + PrivilegesTimes 
    end
    return maxTimes
end

-- 判断是否有挑战次数
function CloudCityModel:isHaveTimes()
    return self:getChallengeTimes() > 0 and SystemUtils:enableCloudCity()
end

-- 判断关卡是否已经通过
function CloudCityModel:getStageHadPass(stageId)
    return stageId <= self:getPassMaxStageId()
end

-- 判断是否跳到此关卡
function CloudCityModel:canArriveStage(stageId)
    return stageId <= self:getAttainStageId()
end

-- 存储首通关卡奖励信息
function CloudCityModel:setRewardData(data)
    self._firstRewardCache = data
end

-- 获取首通关卡奖励信息
function CloudCityModel:getRewardData()
    return self._firstRewardCache
end

-- 判断云中城双倍活动是否开启
function CloudCityModel:isActivityOpen()
    return self._acModel:getAbilityEffect(self._acModel.PrivilegIDs.PrivilegID_33) > 0
end

-- 是否在大世界显示双倍活动气泡
function CloudCityModel:isShowQipao()
    return self:isHaveTimes() and self:isActivityOpen()
end
return CloudCityModel