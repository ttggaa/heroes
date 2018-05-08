--[[
    Filename:    BattleSurrenderView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-08-26 20:26:13
    Description: File description
--]]

local BattleSurrenderView = class("BattleSurrenderView", BasePopView)

function BattleSurrenderView:ctor(data)
    BattleSurrenderView.super.ctor(self)
    self._mode = data.mode
end

function BattleSurrenderView:close(noAnim, callback)


    BattleSurrenderView.super.close(self, noAnim, callback)
end

function BattleSurrenderView:onInit()
    self._btn1 = self:getUI("bg.btn1")
    self._btn2 = self:getUI("bg.btn2")

    self:registerClickEvent(self._btn1, specialize(self.onQuit, self))
    self:registerClickEvent(self._btn2, specialize(self.onGoOn, self))

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 6)

    local keyStr = "LEAGUETIP_19"
    -- 37：镜像挑战
    if self._mode == 37 then
        keyStr = "CP_LIMIT_EXIT"
    end 
    self._descLabel = self:getUI("bg.descLabel"):setString(lang(keyStr))
    self._descLabel:getVirtualRenderer():setMaxLineWidth(312)
end

function BattleSurrenderView:reflashUI(data)
	self._callback = data.callback
end

function BattleSurrenderView:onQuit()
    if self._callback then
        self._callback(2)
    end
    self:close(true)
end

function BattleSurrenderView:onGoOn()
	if self._callback then
		self._callback(1)
	end
    self:close(true)
end

function BattleSurrenderView.dtor()
    BattleSurrenderView = nil
end

return BattleSurrenderView