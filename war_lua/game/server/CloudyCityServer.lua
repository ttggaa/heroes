--
-- Author: <ligen@playcrab.com>
-- Date: 2016-08-23 21:59:59
--
local CloudyCityServer = class("CloudyCityServer", BaseServer)

function CloudyCityServer:ctor()
    CloudyCityServer.super.ctor(self)
    self._cloudCityModel = self._modelMgr:getModel("CloudCityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._playerTodataModel = self._modelMgr:getModel("PlayerTodayModel")
end

-- 获取云中城信息 
function CloudyCityServer:onGetCloudyCityInfo(result, error)
	if error ~= 0 then 
		return
	end

    self._cloudCityModel:setUserData(result)
	self:callback(result)
end

-- 获取关卡信息
function CloudyCityServer:onGetCloudyCityStagePassInfo(result, error)
	if error ~= 0 then 
		return
	end

	self:callback(result)
end

-- 战斗前
function CloudyCityServer:onBeforeAttackCloudyCity(result, error)
	if error ~= 0 then 
		return
	end
    self:callback(result)
end

-- 战斗结束
function CloudyCityServer:onAfterAttackCloudyCity(result, error)
	if error ~= 0 then 
		return
	end

    if result["d"] and result["d"]["dayInfo"] then
        self._playerTodataModel:updateDayInfo(result["d"]["dayInfo"])
    end

    self:callback(result)

    if result["d"] and result["d"]["cloudycity"] and type(result["d"]["cloudycity"]["stageId"]) == "number" then
        self._cloudCityModel:setMaxStageId(result["d"]["cloudycity"]["stageId"])
    end

    if result["reward"] then
        self._cloudCityModel:setRewardData(result["reward"])
        if result["d"]["items"] ~= nil then 
            local itemModel = self._modelMgr:getModel("ItemModel")
            itemModel:updateItems(result["d"]["items"])
            result["d"]["items"] = nil
        end
        -- 更新用户数据
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(result["d"])
    end
end

-- 领取层奖励
function CloudyCityServer:onGetCloudyCityFloorReward(result, error)
	if error ~= 0 then 
		return
	end

    if result["d"] ~= nil then
        if result["d"]["items"] ~= nil then 
            local itemModel = self._modelMgr:getModel("ItemModel")
            itemModel:updateItems(result["d"]["items"])
            result["d"]["items"] = nil
        end
        -- 更新用户数据
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(result["d"])

        if result["d"]["cloudycity"] ~= nil and result["d"]["cloudycity"]["fRewardId"] ~= nil then
            self._cloudCityModel:setMaxRewardId(result["d"]["cloudycity"]["fRewardId"])
        end
    end

    self:callback(result)
end

function CloudyCityServer:onNameOfCity(result, error)
	if error ~= 0 then 
		return
	end

end

-- 重置
function CloudyCityServer:onResetCloudyCityFight(result, error)
	if error ~= 0 then 
		return
	end

    self:callback(result)
end

-- 扫荡
function CloudyCityServer:onSweepCloudyCity(result, error)
    if error ~= 0 then 
		return
	end

    if result["d"] ~= nil then
        if result["d"]["dayInfo"] then
            self._playerTodataModel:updateDayInfo(result["d"]["dayInfo"])
        end

        if result["d"]["items"] ~= nil then 
            local itemModel = self._modelMgr:getModel("ItemModel")
            itemModel:updateItems(result["d"]["items"])
            result["d"]["items"] = nil
        end
        -- 更新用户数据
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(result["d"])
    end

    self:callback(result)
end

-- 购买次数
function CloudyCityServer:onBuyCloudyCityNum(result, error)
    if error ~= 0 then 
		return
	end

    if result["d"] ~= nil then
        if result["d"]["dayInfo"] then
            self._playerTodataModel:updateDayInfo(result["d"]["dayInfo"])
        end

        -- 更新用户数据
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(result["d"])
    end

    self:callback(result)
end

-- 获取战报数据
function CloudyCityServer:onGetCloudyCityReport(result, error)
    if error ~= 0 then 
		return
	end
    self:callback(result)
end

-- 获取最低战力排行榜冠军数据
function CloudyCityServer:onGetCCFirstData(result, error)
    if error ~= 0 then 
		return
	end
    self:callback(result)
end

return CloudyCityServer