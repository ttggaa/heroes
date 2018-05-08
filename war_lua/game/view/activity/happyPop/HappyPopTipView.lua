--[[
    Filename:    HappyPopTipView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-14 16:17
    Description: 法术特训小游戏 提示界面
--]]

local HappyPopTipView = class("HappyPopTipView", BasePopView)

function HappyPopTipView:ctor(param)
	HappyPopTipView.super.ctor(self)

	self._callback1 = param.callback1
	self._callback2 = param.callback2
	self._type = param.type  --1开始游戏 2退出游戏
end

function HappyPopTipView:onInit()
	if self._type == 1 then
		local des1 = self:getUI("bg.des1")
		des1:setString(lang("MAGICTRAINING_RECOVER_TIPS1"))
		des1:setPositionY(165)
		local des2 = self:getUI("bg.des2")
		des2:setVisible(false)
		self:getUI("bg.enterBtn"):setTitleText("继续特训")
		self:getUI("bg.cancelBtn"):setTitleText("重新开始")
	else
		self:getUI("bg.closeBtn"):setVisible(false)
		self:getUI("bg.des1"):setString(lang("MAGICTRAINING_SAVE_TIPS1"))
		self:getUI("bg.des2"):setString(lang("MAGICTRAINING_SAVE_TIPS2"))
	end

	local enterBtn = self:getUI("bg.enterBtn")
	self:registerClickEvent(enterBtn, function()
		if self._callback1 then
			self._callback1()
		end

		self:close()
		end)

	local cancelBtn = self:getUI("bg.cancelBtn")
	self:registerClickEvent(cancelBtn, function()
		if self._callback2 then
			self._callback2()
		end
		self:close()
		end)

	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		end)

	self:setListenReflashWithParam(true)
	self:listenReflash("HappyPopModel", self.listenModelHandle)

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("activity.happyPop.HappyPopTipView")
        end
    end)
end

function HappyPopTipView:listenModelHandle(inData)
	if inData == "close" then
		self:close()
	end
end

return HappyPopTipView