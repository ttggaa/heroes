--[[
 	@FileName 	RoadOfGrowthServer.lua
	@Authors 	cuiyake
	@Date    	2018-05-23 16:13:46
	@Email    	<cuiyake@playcrad.com>
	@Description   成长之路
--]]

local RoadOfGrowthServer = class("RoadOfGrowthServer", BaseServer)

function RoadOfGrowthServer:ctor()
	self.super.ctor(self)
	self._GrowthWayModel = self._modelMgr:getModel("GrowthWayModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end

function RoadOfGrowthServer:onGetRoadOfGrowth(result, error)
	if error ~= 0 then
		return
	end
	self:handleAboutServerData(result)
	self._GrowthWayModel:setData(result)
	self:callback(result, error)
end

function RoadOfGrowthServer:onGetRoadOfGrowthReward(result, error)
	if error ~= 0 then
		return
	end
	self:handleAboutServerData(result)
	self:callback(result, error)
end


function RoadOfGrowthServer:handleAboutServerData(result,upTypeName)
    if result == nil or result["d"] == nil then 
        return
    end

	if result["d"]["items"] then
        self._modelMgr:getModel("ItemModel"):updateItems(result["d"].items)
        result["d"]["items"] = nil
    end
    if result["d"]["vip"] then
        self._modelMgr:getModel("VipModel"):updateData(result["d"]["vip"])
        result["d"]["vip"] = nil
    end
    if result["d"]["activity"] then
        self._modelMgr:getModel("ActivityModel"):updateSpecialData(result["d"]["activity"])
        result["d"]["activity"] = nil
    end

    if result["d"]["sRcg"] then
        self._modelMgr:getModel("ActivityModel"):updateSingleRechargeData(result, true)
        result["d"]["sRcg"] = nil
    end

    if result["d"]["intelligentRecharge"] then
        self._modelMgr:getModel("ActivityModel"):updateIntRechargeData(result, true)
        result["d"]["intelligentRecharge"] = nil
    end

    if result["d"]["teams"] then
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end

    if result["d"]["heros"] then
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(result["d"]["heros"])
        result["d"]["heros"] = nil
    end

    self._userModel:updateUserData(result["d"])
end

return RoadOfGrowthServer