--[[
    Filename:    ArrowSever.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-09-27 21:00
    Description: 射箭小游戏
--]]

local ArrowSever = class("ArrowSever", BaseServer)

function ArrowSever:ctor()
	ArrowSever.super.ctor(self,data)

	self._mul = 111   --防改参数

	self._viewMgr = ViewManager:getInstance()
	self._arrowModel = self._modelMgr:getModel("ArrowModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end

--同步数据
function ArrowSever:onSyncArrowData(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result, "onSyncArrowData", 10)
	
	--重置数据
	self._userModel:getData().arrowNum = -1
	self._arrowModel:initData()
	self:handleAboutServerData(result)
	self._arrowModel:resetArrowLocalData()

	self:callback(result)	
end

function ArrowSever:onGetArrowInfo(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result, "onGetArrowInfo", 10)

	self._arrowModel:updateData(result["arrow"])
	if result["reward"] then
		if result["d"] and result["d"]["arrow"] then
			result["d"]["arrow"] = nil
		end
		self:handleAboutServerData(result)
		self._arrowModel:resetPopBoxReward(result["reward"])
	end
	self:callback(result)
end

--射箭【废弃】
function ArrowSever:onArrowShooting(result, error)
	-- if error ~= 0 then
	-- 	return
	-- end
	-- dump(result, "onArrowShooting", 10)

	-- self:handleAboutServerData(result)
	-- self:callback(result)
end

--射中之后【废弃】
function ArrowSever:onArrowShootingMonsters(result, error)
	-- if error ~= 0 then
	-- 	return
	-- end
	-- dump(result, "onArrowShootingMonsters", 10)

	-- self:handleAboutServerData(result)
	-- self:callback(result)
end

--领取奖励
function ArrowSever:onGetArrowShootingReward(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result, "onGetArrowShootingReward", 10)

	-- 更新用户数据
	if result["d"] == nil then
		result["d"] = {}
	end
	if result["d"]["arrow"] == nil then
		result["d"]["arrow"] = {}
	end
	result["d"]["arrow"]["rewards"] = {["1"] = 0, ["2"] = 0, ["3"] = 0}

	self:handleAboutServerData(result)
	self:callback(result)
end

--领取补给
function ArrowSever:onSupplyArrow(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result, "onSupplyArrow", 10)
	self:handleAboutServerData(result)
	self:callback(result)
end

--领箭
function ArrowSever:onGetSendArrowInfo(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "onGetSendArrowInfo", 10)
	if self._arrowModel:getIsRankView() == true then
		self._arrowModel:setRankDataByType(result["memberList"], "guildMember")
		self:callback(result, error)
		return
	end

	if result["d"] == nil then
		result["d"] = {}
	end
	if result["d"]["arrow"] == nil then
		result["d"]["arrow"] = {}
	end
	result["d"]["arrow"]["rNum"] = 0  --初始化红点
	
	self:handleAboutServerData(result)
	self._arrowModel:insertArrowData(result["memberList"], "memberList")
	self._arrowModel:insertArrowData(result["eventList"], "eventList")
	self:callback(result)
end

--送好友箭
function ArrowSever:onSendArrow(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result, "onSendArrow", 10)
	self:handleAboutServerData(result)
	self:callback(result)
end

--推送好友送箭
function ArrowSever:onPushSendArrow(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "onPushSendArrow", 10)
	-- self:handleAboutServerData(result)
	self._arrowModel:pushSendArrow(result["rNum"])
	self:callback(result)
end

--好友关注
function ArrowSever:onArrowFollow(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "onArrowFollow", 10)
	self:callback(result)
end

--取消关注
function ArrowSever:onArrowCancleFollow(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "onArrowCancleFollow", 10)
	self:callback(result)
end

function ArrowSever:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result["d"]["arrow"] ~= nil then 
    	self._arrowModel:updateData(result["d"]["arrow"])
        result["d"]["arrow"] = nil
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

return ArrowSever
