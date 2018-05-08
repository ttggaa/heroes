--[[
    Filename:    GlobalOkDialog.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-02-10 10:03:31
    Description: File description
--]]

local GlobalOkDialog = class("GlobalOkDialog", BasePopView)

function GlobalOkDialog:ctor()
    GlobalOkDialog.super.ctor(self)

end

function GlobalOkDialog:onInit()
    self._descLabel = self:getUI("bg.descLabel")
    self._descLabel:getVirtualRenderer():setMaxLineWidth(335)
    self._okBtn = self:getUI("bg.okBtn")

    self._title = self:getUI("bg.title")    
    UIUtils:setTitleFormat(self._title, 6)

    self:registerClickEvent(self._okBtn, function ()
        self:close(false, self._callback)
    end)
end

function GlobalOkDialog:reflashUI(data)
    if data.title then
        self._title:setString(data.title)
    end
    self._callback = data.callback
    self._descLabel:setString(data.desc)
    if self._descLabel:getVirtualRenderer():getStringNumLines() > 1 then  
        self._descLabel:setTextHorizontalAlignment(3)
    end
    self._okBtn:setTitleText(data.button)
end


return GlobalOkDialog