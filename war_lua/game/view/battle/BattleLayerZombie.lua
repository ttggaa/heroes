--[[
    Filename:    BattleLayerZombie.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-10-26 10:58:45
    Description: File description
--]]

local BattleLayerZombie = class("BattleLayerZombie", BaseLayer)

function BattleLayerZombie:ctor()
    BattleLayerZombie.super.ctor(self)

end

function BattleLayerZombie:onInit()
	self:setFullScreen()

end

function BattleLayerZombie.dtor()
	BattleLayerZombie = nil
end

return BattleLayerZombie