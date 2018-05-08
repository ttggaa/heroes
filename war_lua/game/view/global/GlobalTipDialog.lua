--[[
    Filename:    GlobalTipDialog.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-06-03 10:28:14
    Description: File description
--]]

local GlobalTipDialog = class("GlobalTipDialog", BaseLayer)

function GlobalTipDialog:ctor()
    GlobalTipDialog.super.ctor(self)

end

function GlobalTipDialog:onInit()
    self:setFullScreen()
    self._bg = self:getUI("bg")
    self._bg:setCascadeOpacityEnabled(true, true)
    self._bg1 = self:getUI("bg.bg1")
    self._label = self:getUI("bg.tipLab")
    self._label:setString("")
    self._label:setFontSize(22)
    self:setVisible(false)
end

function GlobalTipDialog:showTip(msg)
    
    self._bg:stopAllActions()
    self._label:setString(msg)
    self._bg1:setContentSize(cc.size(self._label:getContentSize().width + 80, 44))
    self:setVisible(true)
    self._bg:setOpacity(255)
    self._bg:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.FadeOut:create(0.5), cc.CallFunc:create(function ()
        self:setVisible(false)
    end)))
end

function GlobalTipDialog:closeTip()
    self._bg:stopAllActions()
    self:setVisible(false)
end

return GlobalTipDialog