--[[
    Filename:    NetWorkDialog.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-01-17 11:40:50
    Description: File description
--]]

local NetWorkDialog = class("NetWorkDialog", BasePopView)

function NetWorkDialog:ctor(data)
    NetWorkDialog.super.ctor(self)
    self._data = data
end

function NetWorkDialog:onInit()
	self._bg = self:getUI("bg")
	self._btn0 = self:getUI("bg.btn0")
	self._btn1 = self:getUI("bg.btn1")
	self._btn2 = self:getUI("bg.btn2")
	self._error = self:getUI("bg.error")

    self._btn0:setTitleFontSize(26)
    self._btn1:setTitleFontSize(26)
    self._btn2:setTitleFontSize(26)

	if self._data.errorCode then
		self._error:setString(self._data.errorCode)
	end

    local des = cc.Label:createWithTTF(self._data.msg, UIUtils.ttfName, 18)
    des:setColor(cc.c3b(255, 255, 255))
    des:setAnchorPoint(0.5, 0)
    des:setHorizontalAlignment(1)
    des:setVerticalAlignment(1)
    des:setDimensions(268, 0)
    self._bg:addChild(des)
    self._des = des

    local mc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false)
    mc:getChildren()[1]:setVisible(false)
    mc:setScale(1.5)
    self._bg:addChild(mc)

    local height = des:getContentSize().height
    if height > 50 and height < 260 then
        height = height + 75
        self._bg:setContentSize(self._bg:getContentSize().width, height)
        mc:setPosition(10, height - 50)
        des:setAnchorPoint(0.5, 0)
        des:setPosition(184, 60)
    elseif height >= 260 then
        des:setDimensions(400, 0)
        height = des:getContentSize().height + 75
        self._bg:setContentSize(520, height)
        mc:setPosition(10, height - 50)
        des:setAnchorPoint(0.5, 0)
        des:setPosition(260, 60)    
        self._btn0:setPositionX(260)
        self._btn1:setPositionX(260 - 140)
        self._btn2:setPositionX(260 + 140)
    else
        des:setAnchorPoint(0.5, 0.5)
        des:setPosition(184, 92)
        mc:setPosition(10, 80)
    end
    
    self._btn0:setVisible(self._data.callback1 == nil and self._data.callback2 == nil )
    self._btn1:setVisible(self._data.callback1 ~= nil)
    self._btn2:setVisible(self._data.callback2 ~= nil)

    if self._data.title0 then
        self._btn0:setTitleText(self._data.title0)
    else
        self._btn0:setTitleText("确定")
    end
    if self._data.title1 then
        self._btn1:setTitleText(self._data.title1)
    else
        self._btn1:setTitleText("确定")
    end
    if self._data.title2 then
        self._btn2:setTitleText(self._data.title2)
    else
        self._btn2:setTitleText("取消")
    end

    self:registerClickEvent(self._btn0, function ()
        self:close(false, self._data.callback)
    end)

    self:registerClickEvent(self._btn1, function ()
        self:close(false, self._data.callback1)
    end)

    if self._data.btn2dontClose then
        self:registerClickEvent(self._btn2, function ()
            if self._data.callback2 then
                self._data.callback2()
            end
        end)
    else
        self:registerClickEvent(self._btn2, function ()
            self:close(false, self._data.callback2)
        end)
    end


end

return NetWorkDialog