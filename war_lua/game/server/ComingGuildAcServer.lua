--
-- Author: huangguofang
-- Date: 2018-05-09 21:21:11
--
local ComingGuildAcServer = class("ComingGuildAcServer", BaseServer)

function ComingGuildAcServer:ctor()
	ComingGuildAcServer.super.ctor(self,data)
	self._acUltimateModel = self._modelMgr:getModel("AcUltimateModel")
	self._rankModel = self._modelMgr:getModel("RankModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end

-- 获取活动信息
function ComingGuildAcServer:onGetInfo(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result,"resultonGetInfo==>",5)
	local comingGuildAc = result["comingGuildAc"]
	result["comingGuildAc"] = nil
	self._userModel:updateUserData(result)
	self._acUltimateModel:setData(comingGuildAc)
	self:callback(result)
end

-- 获取排行榜信息
function ComingGuildAcServer:onGetRank(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result,"resultononGetRank==>",5)
	-- self._rankModel:setData(result)
	self:callback(result)
end

-- 捐献
function ComingGuildAcServer:onDonateExp(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result,"resultonGetRoleProcessReward==>",5)
	if result["d"] and result["d"]["comingGuildAc"] then
		self._acUltimateModel:updateUltimateData(result["d"]["comingGuildAc"])
		result["d"]["comingGuildAc"] = nil
	end
	self:handAboutServerData(result)
	self:callback(result)
end

-- 获取进度宝箱奖励
function ComingGuildAcServer:onGetRoleProcessReward(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result,"resultonGetRoleProcessReward==>",5)
	if result["d"] and result["d"]["comingGuildAc"] then
		self._acUltimateModel:updateUltimateData(result["d"]["comingGuildAc"])
		result["d"]["comingGuildAc"] = nil
	end
	self:handAboutServerData(result)
	self:callback(result)
end

-- 领取联盟奖励
function ComingGuildAcServer:onGetGuildReward(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result,"resultonGetGuildReward==>",5)
	if result["d"] and result["d"]["comingGuildAc"] then
		self._acUltimateModel:updateUltimateData(result["d"]["comingGuildAc"])
		result["d"]["comingGuildAc"] = nil
	end
	self:handAboutServerData(result)
    self:callback(result)
end

-- 领取个人奖励
function ComingGuildAcServer:onGetRoleReward(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result,"resultonGetRoleReward==>",5)
	if result["d"] and result["d"]["comingGuildAc"] then
		self._acUltimateModel:updateUltimateData(result["d"]["comingGuildAc"])
		result["d"]["comingGuildAc"] = nil
	end
	self:handAboutServerData(result)
	self:callback(result)
end

--
function ComingGuildAcServer:handAboutServerData(result)
    if result == nil then 
        return 
    end

    if result["d"] and result["d"]["activity"] ~= nil then
        local activityModel = self._modelMgr:getModel("ActivityModel")
        activityModel:updateSpecialData(result["d"]["activity"])
        result["d"]["activity"] = nil 
    end
    -- -- 物品数据处理要优先于怪兽
    if result["d"] and result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end
    -- 删除背包中道具 
    if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end

    if result["d"] and result["d"]["teams"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end 

    if result["d"] and result["d"]["hero"] ~= nil  then 
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(result["d"]["hero"])
        result["d"]["hero"] = nil
    end
    self._userModel:updateUserData(result["d"])
end


return ComingGuildAcServer