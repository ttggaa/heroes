--
-- Author: huangguofang
-- Date: 2018-08-01 15:13:31
--
local LimitPrayServer = class("LimitPrayServer", BaseServer)

function LimitPrayServer:ctor()
	LimitPrayServer.super.ctor(self)
	self._limitPrayModel = self._modelMgr:getModel("LimitPrayModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end

function LimitPrayServer:onGetLimitPrayInfo(result, error)
	-- dump(result, "onGetLimitPrayInfo", 10)
	if error ~= 0 then
		return
	end
	self:callback(result, error)
end

--抽卡
function LimitPrayServer:onLimitPrayLottery(result, error)
	-- dump(result, "onLimitPrayLottery", 10)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
	self:callback(result, error)
end

--领奖
function LimitPrayServer:onGetLimitPrayBox(result, error)
	-- dump(result, "onGetLimitPrayBox", 10)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
	self:callback(result, error)
end

function LimitPrayServer:onGetRank(result, error)
	if error ~= 0 then
        return
    end

    self:callback(result, error)
end

function LimitPrayServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result["unset"] then 
        local removeItems = self._itemModel:handelUnsetItems(result["unset"])
        self._itemModel:delItems(removeItems, true)
    end

    if result["d"]["limitPray"] ~= nil then 
    	self._limitPrayModel:updateData(result["d"]["limitPray"])
        result["d"]["limitPray"] = nil
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

return LimitPrayServer