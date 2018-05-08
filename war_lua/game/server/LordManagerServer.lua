--[[
    Filename:    LordManagerServer.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-3-15 15:28:47
    Description: File description
--]]

local LordManagerServer = class("LordManagerServer", BaseServer)

function LordManagerServer:ctor()
    LordManagerServer.super.ctor(self)
    self._grModel = self._modelMgr:getModel("GuildRedModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._dailySiegeModel = self._modelMgr:getModel("DailySiegeModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")

end

function LordManagerServer:onGetLordManagerData(result, errorCode)
    if errorCode ~= 0 then 
        return
    end
    if result["1"] then
    	self._grModel:setSysData(result["1"])
    end

    if result["2"] then
    	local dailySiege =  result["2"]["dailySiege"]
    	if dailySiege then
    		self._dailySiegeModel:updateData(dailySiege)
    	end

    	-- 更新阵型数据  
    	local formations =  result["2"]["formations"]
    	if formations then
    		self._formationModel:updateAllFormationData(formations)
    	end
    end

    if result["3"] then
    	self._guildModel:setGuildMercenary(result["3"]["userMercenaryList"])
    end

    if result["dayInfo"] then
    	self._playerTodayModel:setData(result["dayInfo"])
    end
    self:callback()
end

return LordManagerServer