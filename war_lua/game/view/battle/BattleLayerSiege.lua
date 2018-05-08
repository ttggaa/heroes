--[[
    Filename:    BattleLayerSiege.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-10-09 10:58:45
    Description: File description
--]]

local BattleLayerSiege = class("BattleLayerSiege", BaseLayer)

function BattleLayerSiege:ctor()
    BattleLayerSiege.super.ctor(self)

end

function BattleLayerSiege:onInit()
	self:setFullScreen()

end

function BattleLayerSiege.dtor()
	BattleLayerSiege = nil
end

return BattleLayerSiege