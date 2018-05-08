--[[
    Filename:    MagicTrainingServer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-13 17:50
    Description: 法术特训小游戏
--]]

local MagicTrainingServer = class("MagicTrainingServer", BaseServer)

function MagicTrainingServer:ctor()
	MagicTrainingServer.super.ctor(self, data)
	self._hPopModel = self._modelMgr:getModel("HappyPopModel")
    self._userModel = self._modelMgr:getModel("UserModel")

end

function MagicTrainingServer:onEnter(result, error)
	dump(result, "onEnter", 10)
	if error ~= 0 then
        self._hPopModel:notifyCheatClose()
		return
	end

	self._hPopModel:setData(result)
	self:callback(result)
end

function MagicTrainingServer:onOpenCard(result, error)
	dump(result, "onOpenCard", 10)
	if error ~= 0 then
	end

    if result["error"] and result["error"] ~= 0 then
        self:callback(result)
        self._hPopModel:notifyCheatClose()
        return
    end

	self._hPopModel:openCards(result)
	self:handleAboutServerData(result)
	self:callback(result)
end

function MagicTrainingServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"]["teams"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end 

    if result["d"] and result["d"]["dayInfo"] then
    	local playerTodataModel = self._modelMgr:getModel("PlayerTodayModel")
        playerTodataModel:updateDayInfo(result["d"]["dayInfo"])
        result["d"]["dayInfo"] = nil
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])
end

return MagicTrainingServer