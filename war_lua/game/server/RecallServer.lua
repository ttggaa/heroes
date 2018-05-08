--[[
    Filename:    RecallServer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-09-11 18:14:51
    Description: 好友召回
--]]

local RecallServer = class("RecallServer", BaseServer)

function RecallServer:ctor()
	RecallServer.super.ctor(self,data)
	self._recallModel = self._modelMgr:getModel("FriendRecallModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

--------------------友情商店
function RecallServer:onOneKeyGetFriendActReward(result, error)
    -- dump(result, "onOneKeyGetFriendActReward", 10)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
    self._recallModel:clearFriendCoin()
	self:callback(result)
end

function RecallServer:onGetFriendScoreChangeLog(result, error)
    -- dump(result, "onGetFriendScoreChangeLog", 10)
    if error ~= 0 then
        return
    end

    self:callback(result)
end

function RecallServer:onGetRecallInfo(result, error)
    -- dump(result, "onGetRecallInfo", 10)
    if error ~= 0 then
        return
    end

    self._recallModel:setRecallData(result)
    self:callback(result)
end

function RecallServer:onSendRecall(result, error)
    -- dump(result, "onSendRecall", 10)
    if error ~= 0 then
        return
    end

    self:handleAboutServerData(result)
    self:callback(result)
end

function RecallServer:onBindRecallFriend(result, error)
    -- dump(result, "onBindRecallFriend", 10)
    if error ~= 0 then
        return
    end

    self:handleAboutServerData(result)
    self:callback(result)
end

function RecallServer:onGetCurrentFriendScore(result, error)
    -- dump(result, "onGetCurrentFriendScore", 10)
    if error ~= 0 then
        return
    end

    self:callback(result)
end

--------------------友情活动
function RecallServer:onGetFriendActData(result, error)
    -- dump(result, "onGetFriendActData", 10)
    if error ~= 0 then
        return
    end

    self._recallModel:setIsReqedAcData(true)
    self._recallModel:setAcData(result)
    self:callback(result)
end

function RecallServer:onGetFriendActTaskReward(result, error)
    -- dump(result, "onGetFriendActTaskReward", 10)
    if error ~= 0 then
        return
    end

    self:handleAboutServerData(result)
    self:callback(result)
end

function RecallServer:onGetRecalledList(result, error)
    -- dump(result, "onGetRecalledList", 10)
    if error ~= 0 then
        return
    end

    self._recallModel:setBindData(result)
    self:callback(result)
end

function RecallServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result["dailyFriendScore"] ~= nil then
        self._recallModel:setDialyFScore(result["dailyFriendScore"])
        result["dailyFriendScore"] = nil
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

return RecallServer