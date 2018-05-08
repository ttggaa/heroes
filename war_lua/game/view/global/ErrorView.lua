--[[
    Filename:    ErrorView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-02-24 15:50:28
    Description: File description
--]]

local ErrorView = class("ErrorView", BasePopView)

function ErrorView:ctor()
    ErrorView.super.ctor(self)

end

function ErrorView:onInit()
    self._scrollview = self:getUI("bg.scrollview")
    self._scrollview:setClippingEnabled(true)
    self._btn = self:getUI("bg.btn")
    self._btn:setTitleFontSize(20)

    self:registerClickEvent(self._btn, function ()
    	if self._index <= self._max then
    		self:showMsg()
    	else
        	self:close()
        end
    end)
end

function ErrorView:reflashUI(data)
	self._msgs = data.msg
	self._index = 1
	self._max = #data.msg
	self:showMsg()
end

function ErrorView:showMsg()
	self._scrollview:removeAllChildren()
	self._scrollview:jumpToTop()
	local msg = self._msgs[self._index]
	local label = cc.Label:createWithTTF(msg, UIUtils.ttfName, 20)
	label:setAnchorPoint(0, 0)
	label:setColor(cc.c3b(0,0,0))
	label:setDimensions(700, 0)
	label:setVerticalAlignment(0)
	local height = label:getContentSize().height
	if height < 480 then
		label:setPositionY(480 - height)
		self._scrollview:setInnerContainerSize(cc.size(480, height))
	else
		self._scrollview:setInnerContainerSize(cc.size(700, height))
	end
	self._scrollview:addChild(label)
	if self._index == self._max then
		self._btn:setTitleText("close")
	else
		self._btn:setTitleText(self._index.."/"..self._max)
	end
	self._index = self._index + 1
end


return ErrorView