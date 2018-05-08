--[[
    Filename:    RedPacketServer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-01-24 17:57:51
    Description: File description
--]]

local RedPacketServer = class("RedPacketServer", BaseServer)

function RedPacketServer:ctor()
	RedPacketServer.super.ctor(self)
	self._sRedModel = self._modelMgr:getModel("SpringRedModel")
end

function RedPacketServer:onSendRedPacket(result, error)
    -- dump(result, "onSendRedPacket", 10)
	if error ~= 0 then
		return
	end
	
	self:handleAboutServerData(result)
	self:callback(result)
end

function RedPacketServer:onGetRedPacketInfo(result, error)
    -- dump(result, "onGetRedPacketInfo", 10)
	if error ~= 0 then
		return
	end

    self._sRedModel:setData(result["redPacket"])
	self:callback(result)
end

function RedPacketServer:onRedPacketNotice(result, error)
    -- dump(result, "onRedPacketNotice", 10)
	if error ~= 0 then
		return
	end

    for i,v in ipairs(result) do
        local isCanG = self._sRedModel:checkGetDayInfo(2, v["type"])
        if isCanG then
            self._sRedModel:insertPushRed(result)
            self._viewMgr:activeGiftMoneyTip(result, "packet1")   --全局红包
        end

        if v["type"] == 3 then
            self._sRedModel:insertNotice(result)
            self._viewMgr:activeGiftMoneyTip(result, "packet2")   --跑马灯
        end
    end
end

function RedPacketServer:onRobRedPacket(result, error)
    -- dump(result, "onRobRedPacket", 10)
    if error ~= 0 then
        return
    end

    self:handleAboutServerData(result)
    self:callback(result, error)
end

function RedPacketServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return 
    end

    if result["d"]["redPacket"] ~= nil then 
        local sRedModel = self._modelMgr:getModel("SpringRedModel")
        sRedModel:updateData(result["d"]["redPacket"])
        result["d"]["redPacket"] = nil
    end

    if result["d"]["dayInfo"] ~= nil then
    	local playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
		playerTodayModel:updateDayInfo(result["d"]["dayInfo"])
		result["d"]["dayInfo"] = nil
	end

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    -- 更新用户数据
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return RedPacketServer