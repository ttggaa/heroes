--[[
    Filename:    GuildMapFamModel.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2016-06-13 14:20:16
    Description: File description
--]]


local GuildMapFamModel = class("GuildMapFamModel", BaseModel)

require "game.view.guild.GuildConst"
function GuildMapFamModel:ctor()
    GuildMapFamModel.super.ctor(self)
    self:onInit()
end

function GuildMapFamModel:onInit(isPreview)
    --是否打开过规则界面，用于判断红点    
--    self._isOpenRule = SystemUtils.loadAccountLocalData("GUILD_MAP_RULEVIEW_OPEN_STATE") or false  
	self._type = 0
	self._createTime = 0
	self._gridKeyData = {}
	self._inviteKey = nil
end

function GuildMapFamModel:addData(gridKey, data)
	local famData = {}
	if data then
		for i,v in pairs(data) do
			famData[tonumber(i)] = v
		end
	end
	self._gridKeyData[gridKey] = famData
end

function GuildMapFamModel:getData()
    return self._gridKeyData
end

function GuildMapFamModel:getFamDataByGridKey(gridKey)
	return self._gridKeyData[gridKey]
end

function GuildMapFamModel:noticeKilled(gridKey, id, data)
	if self._gridKeyData[gridKey] then
		for i,v in pairs(data) do
			self._gridKeyData[gridKey][id][i] = v
		end
		self:reflashData(gridKey)
	end
end

function GuildMapFamModel:setInviteKey(inviteKey)
	self._inviteKey = inviteKey
end

function GuildMapFamModel:getInviteKey()
	return self._inviteKey
end

function GuildMapFamModel:clearInviteKey()
	self._inviteKey = nil
end

return GuildMapFamModel