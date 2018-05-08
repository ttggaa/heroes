--[[
    Filename:    LimitTeamsServer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-09-27 21:00
    Description: 限时兵团
--]]

local LimitTeamsServer = class("LimitTeamsServer", BaseServer)

function LimitTeamsServer:ctor()
	LimitTeamsServer.super.ctor(self)
	self._teamTLModel = self._modelMgr:getModel("LimitTeamModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end

function LimitTeamsServer:onGetLimitTeamInfo(result, error)
	-- dump(result, "onGetLimitTeamInfo", 10)
	if error ~= 0 then
		return
	end

	self._teamTLModel:setIsReqed(true)
	self._teamTLModel:setData(result)
	self:callback(result, error)
end

--抽卡
function LimitTeamsServer:onLimitTeamLottery(result, error)
	-- dump(result, "onLimitTeamLottery", 10)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
	self:callback(result, error)
end

--领奖
function LimitTeamsServer:onGetLimitTeamBox(result, error)
	-- dump(result, "onGetLimitTeamBox", 10)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
	self:callback(result, error)
end

function LimitTeamsServer:onPushNotice(result)
	dump(result, "onPushNotice", 10)
	if result == nil or next(result) == nil then
		return
	end

	self._teamTLModel:insertNotice(result)  		--限时兵团界面
	for i,v in ipairs(result) do
		if v["type"] and (v["type"] == 1 or v["type"] == 3) then  --整卡/招募 主界面跑马灯
			local noticeModel = self._modelMgr:getModel("NoticeModel")
			v["bdType"] = "limitTeam"
			noticeModel:insertData({v})
		end
	end
end

function LimitTeamsServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result["d"]["limitTeams"] ~= nil then 
    	self._teamTLModel:updateData(result["d"]["limitTeams"])
        result["d"]["limitTeams"] = nil
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

return LimitTeamsServer