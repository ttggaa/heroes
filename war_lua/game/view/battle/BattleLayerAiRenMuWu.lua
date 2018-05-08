--[[
    Filename:    BattleLayerAiRenMuWu.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-10-23 14:56:17
    Description: File description
--]]

local BattleLayerAiRenMuWu = class("BattleLayerAiRenMuWu", BaseLayer)

function BattleLayerAiRenMuWu:ctor()
    BattleLayerAiRenMuWu.super.ctor(self)


end

function BattleLayerAiRenMuWu:onInit()
	self:setFullScreen()
	
end

function BattleLayerAiRenMuWu.dtor()
	BattleLayerAiRenMuWu = nil
end

return BattleLayerAiRenMuWu