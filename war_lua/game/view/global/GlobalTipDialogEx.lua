--[[
    Filename:    GlobalTipDialogEx.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-04-28 10:18:00
    Description: File description
--]]

local GlobalTipDialogEx = class("GlobalTipDialogEx", BaseLayer)

function GlobalTipDialogEx:ctor()
    GlobalTipDialogEx.super.ctor(self)

end

function GlobalTipDialogEx:onInit()
    self:setFullScreen()
    self._bg = self:getUI("bg")
    self._bg:setCascadeOpacityEnabled(true, true)
    self._bg1 = self:getUI("bg.bg1")
    self._label = self:getUI("bg.tipLab")
    self._label:setVisible(false)

    self:setVisible(false)
    self._widget:setTouchEnabled(false)
end

function GlobalTipDialogEx:showTip(msg)
    if self._richText then
        self._richText:removeFromParent()
    end
    self._richText = RichTextFactory:create(msg, 800, 25)
    self._richText:formatText()
    self._richText:setPosition(self._label:getPositionX() + 400 - self._richText:getRealSize().width * 0.5, self._label:getPositionY())
    self._label:getParent():addChild(self._richText)
    self._bg1:setContentSize(cc.size(self._richText:getRealSize().width + 80, 44))
    self:setVisible(true)
end

function GlobalTipDialogEx:closeTip()
    self:setVisible(false)
end

return GlobalTipDialogEx