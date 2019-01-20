--[[
    Filename:    ParagonTalentServer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-09-27 18:33
    Description: 巅峰天赋
--]]

local ParagonTalentServer = class("ParagonTalentServer", BaseServer)

function ParagonTalentServer:ctor()
	self.super.ctor(self,data)
	self._paragonModel = self._modelMgr:getModel("ParagonModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end

function ParagonTalentServer:onGetPTalentInfo(result, error)
	if error ~= 0 then
		return
	end
	if result["pTalents"] ~= nil then
		self._paragonModel:setData(result["pTalents"])
		result["pTalents"] = nil
	end
	self:callback(result)
end

function ParagonTalentServer:onUpgradePTalent(result, error)
	if error ~= 0 then
		return
	end

	if result["d"] and result["d"]["pTalents"] ~= nil then
		self._paragonModel:updateData(result["d"]["pTalents"])
		result["d"]["pTalents"] = nil
	end
	self:handleAboutServerData(result)
	self:callback(result)
end

function ParagonTalentServer:onResetPTalents(result, error)
	if error ~= 0 then
		return
	end

	if result["d"] and result["d"]["pTalents"] ~= nil then
		self._paragonModel:setData(result["d"]["pTalents"])
		result["d"]["pTalents"] = nil
	end
	self:handleAboutServerData(result)
	self:callback(result)
end

function ParagonTalentServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"] and result["d"]["dayInfo"] then
    	local playerTodataModel = self._modelMgr:getModel("PlayerTodayModel")
        playerTodataModel:updateDayInfo(result["d"]["dayInfo"])
        result["d"]["dayInfo"] = nil
    end

    if result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end

    if result["d"]["teams"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])

    if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
end

return ParagonTalentServer