--[[
    Filename:    SingleRechargeServer.lua
    Author:      <hexinping@playcrab.com>
    Datetime:    2016-11-03 17:33:00
    Description: File description
--]]

local SingleRechargeServer = class("SingleRechargeServer", BaseServer)

function SingleRechargeServer:ctor()
    SingleRechargeServer.super.ctor(self)
    self._activityModel = self._modelMgr:getModel("ActivityModel")
end

function SingleRechargeServer:onGetReward(result, error)
    if 0 ~= tonumber(error) then return end

    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end

    self._activityModel:updateSingleRechargeData(result, 0 == tonumber(error))
    self:callback(0 == tonumber(error), result)
end

return SingleRechargeServer