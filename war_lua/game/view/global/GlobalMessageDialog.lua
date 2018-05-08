--[[
    Filename:    GlobalMessageDialog.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-29 15:00:59
    Description: File description
--]]

local GlobalMessageDialog = class("GlobalMessageDialog", BasePopView)

function GlobalMessageDialog:ctor()
    GlobalMessageDialog.super.ctor(self)

end

function GlobalMessageDialog:onInit()
    self._descLabel = self:getUI("bg.descLabel")
    self._descLabel:getVirtualRenderer():setMaxLineWidth(335)
    self._okBtn = self:getUI("bg.okBtn")

    self._title = self:getUI("bg.title")    
    UIUtils:setTitleFormat(self._title, 6)

    self:registerClickEvent(self._okBtn, function ()
        self:close(false, self._callback)
    end)

    self:registerClickEventByName("closePanel", function ()
        self:getUI("closePanel"):setTouchEnabled(false)
        self:close(false)
    end)
    self:registerClickEventByName("bg.closeBtn", function ()
        self:getUI("closePanel"):setTouchEnabled(false)
        self:close(false)
    end)
end

function GlobalMessageDialog:reflashUI(data)
    self._callback = data.callback
    self._descLabel:setString(data.desc)
    if self._descLabel:getVirtualRenderer():getStringNumLines() > 1 then  
        self._descLabel:setTextHorizontalAlignment(3)
    end
    self._okBtn:setTitleText(data.button)
end


return GlobalMessageDialog