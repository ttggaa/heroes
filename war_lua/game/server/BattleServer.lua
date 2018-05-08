--[[
    Filename:    BattleServer.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-11-30 20:41:10
    Description: File description
--]]


local BattleServer = class("BattleServer",BaseServer)

function BattleServer:ctor(data)
    BattleServer.super.ctor(self,data)
end

function BattleServer:onGetBattleReport( result, error)
	if error ~= 0 then 
		return
	end
	self:callback(result)
end

function BattleServer:onGetSurprise( result, error)
	if error ~= 0 then 
		return
	end
	if result and result.d and result.d.dayInfo then
		self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
	end
	self:callback(result)
end

return BattleServer