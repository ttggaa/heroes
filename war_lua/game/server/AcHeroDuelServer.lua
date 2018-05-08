--[[
    Filename:    AcHeroDuelServer.lua
    Author:      <hexinping@playcrab.com>
    Datetime:    2017-9-20 
    Description: File description
--]]

local AcHeroDuelServer = class("AcHeroDuelServer", BaseServer)

function AcHeroDuelServer:ctor()
    AcHeroDuelServer.super.ctor(self)
    self._activityModel = self._modelMgr:getModel("ActivityModel")
end

function AcHeroDuelServer:onGetAcHeroDuelReward(result, error)
    if 0 ~= tonumber(error) then return end

    if not self._activityModel then
        self._activityModel = self._modelMgr:getModel("ActivityModel")
    end

    self._activityModel:updateAcHeroDuelData(result, 0 == tonumber(error))
    self:callback(0 == tonumber(error), result)
end

return AcHeroDuelServer