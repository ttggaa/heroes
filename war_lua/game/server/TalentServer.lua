--[[
    Filename:    TalentServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-04-20 16:25:03
    Description: File description
--]]


local TalentServer = class("TalentServer", BaseServer)

function TalentServer:ctor()
    TalentServer.super.ctor(self)
    self._talentModel = self._modelMgr:getModel("TalentModel")
end

function TalentServer:onGetTalentInfo(result, error)
    if result then
        self._talentModel:setData(result)
    end
    self:callback(0 == tonumber(error))
end

function TalentServer:onUpTalentChildLv(result, error)
    if 0 == tonumber(error) then
        self._talentModel:updateTalentData(result)
    end
    self:callback(0 == tonumber(error), result)
end

function TalentServer:onResetTanlentSingle(result, error)
    if 0 == tonumber(error) then
        self._talentModel:updateTalentData(result)
    end
    self:callback(0 == tonumber(error), result)
end

function TalentServer:onResetTalent(result, error)
    -- dump(result, "onResetTalent", 10)
    if 0 == tonumber(error) then
        self._talentModel:updateTalentData(result)
    end
    self:callback(0 == tonumber(error), result)
end

return TalentServer