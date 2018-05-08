--[[
    Filename:    LimitItemsServer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-7 14:44
    Description: 限时魂石
--]]

local LimitItemsServer = class("LimitItemsServer", BaseServer)

function LimitItemsServer:ctor()
	LimitItemsServer.super.ctor(self)
	self._ltAwkModel = self._modelMgr:getModel("LimitAwakenModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end

function LimitItemsServer:onGetLimitItemsInfo(result, error)
	-- dump(result, "onGetLimitItemsInfo", 10)
	if error ~= 0 then
		return
	end

	self._ltAwkModel:setIsReqed(true)
	self._ltAwkModel:setData(result)
	self:callback(result, error)
end

--抽卡
function LimitItemsServer:onLimitItemsLottery(result, error)
	-- dump(result, "onLimitItemsLottery", 10)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
	self:callback(result, error)
end

--领奖
function LimitItemsServer:onGetLimitItemsBox(result, error)
	-- dump(result, "onGetLimitItemsBox", 10)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
	self:callback(result, error)
end

function LimitItemsServer:onPushNotice(result)
	-- dump(result, "onPushNotice", 10)
	if result == nil or next(result) == nil then
		return
	end

	self._ltAwkModel:insertNotice(result)
end

function LimitItemsServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result["d"]["limitItems"] ~= nil then 
    	self._ltAwkModel:updateData(result["d"]["limitItems"])
        result["d"]["limitItems"] = nil
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

return LimitItemsServer