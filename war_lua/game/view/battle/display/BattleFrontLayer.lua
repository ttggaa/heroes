--[[
    Filename:    BattleFrontLayer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-29 12:52:47
    Description: File description
--]]
local BattleFrontLayer = class("BattleFrontLayer")

function BattleFrontLayer:ctor()
    -- 黑屏
    self._rootLayer = cc.Layer:create()
    self._rootLayer:setAnchorPoint(0, 0)
    self._rootLayer:setCascadeOpacityEnabled(true)
    self._maskLayer = ccui.Layout:create()
    self._maskLayer:setBackGroundColorOpacity(255)
    self._maskLayer:setBackGroundColorType(1)
    self._maskLayer:setBackGroundColor(cc.c3b(0,0,0))
    self._maskLayer:setContentSize(MAX_SCREEN_WIDTH + 120, MAX_SCREEN_HEIGHT)
    self._rootLayer:addChild(self._maskLayer)
    self._rootLayer:setOpacity(255)
    self._rootLayer:setPositionX(-60)
end

function BattleFrontLayer:getView()
    return self._rootLayer
end

function BattleFrontLayer:clear()
    self._rootLayer:removeAllChildren()
    self._rootLayer:removeFromParent(true)
    self._rootLayer = nil
end

function BattleFrontLayer:initLayer()

end

function BattleFrontLayer.dtor()
    BattleFrontLayer = nil
end

return BattleFrontLayer