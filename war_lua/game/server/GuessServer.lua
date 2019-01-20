--[[
    Filename:    GuessServer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-05-8 19:31:51
    Description: 竞猜活动
--]]

local GuessServer = class("GuessServer", BaseServer)

function GuessServer:ctor()
	GuessServer.super.ctor(self,data)
	self._worldCupModel = self._modelMgr:getModel("WorldCupModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._rankModel = self._modelMgr:getModel("RankModel")
end

function GuessServer:onGetInfos(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "onGetInfos", 10)
	self:handleAboutServerData(result)
	self._worldCupModel:setData(result)
	self:callback(result)
end

function GuessServer:onGetCathecticInfo(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "onGetCathecticInfo", 10)
	self:handleAboutServerData(result)
	self._worldCupModel:setCathecticInfo(result)
	self:callback(result)
end

function GuessServer:onCathectic(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "onCathectic", 10)
	self:handleAboutServerData(result)
	self:callback(result)
end

function GuessServer:onPush(result, error)
	if error ~= 0 then
		return
	end

	self._worldCupModel:refreshAcData()
end

function GuessServer:handleAboutServerData(result)   
    if result == nil or result["d"] == nil then 
        return
    end

    if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
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

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])
end


return GuessServer