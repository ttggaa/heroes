--[[
    Filename:    HeroFormationAppraiseDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local HeroFormationAppraiseDialog = class("HeroFormationAppraiseDialog", BasePopView)

function HeroFormationAppraiseDialog:ctor(data)
    HeroFormationAppraiseDialog.super.ctor(self)
	self._callback = data.callback
end

function HeroFormationAppraiseDialog:onInit()
	local closeBtn = self:getUI("bg.rightBtn")
	self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("hero.HeroFormationAppraiseDialog")
        end
		self:close()
	end)
	
	local sureBtn = self:getUI("bg.leftBtn")
	self:registerClickEvent(sureBtn, function()
--		self._viewMgr:showTip("sureBtn:onClick()")
		self:onSure()
	end)
	self._numLab = self:getUI("bg.labNums")
	self._numLab:setString(0)
	self._inputBox = self:getUI("bg.signBg.inputText")
	self._inputBox:setLineBreakWithoutSpace(true)
	self._inputBox:addEventListener(function(sender, eventType)
		self._inputBox:setColor(cc.c3b(60, 42, 30))
		if self._inputBox:getString() == "" then
			self._inputBox:setPlaceHolder("请输入40字以内说明")
			self._inputBox:setColor(cc.c3b(255, 255, 255))
			self._inputBox:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
		end
		local num = utf8.len(self._inputBox:getString())
		self._numLab:setString(num)
		if num<=40 then
			self._numLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		else
			self._numLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
		end
	end)
end

function HeroFormationAppraiseDialog:onPopEnd()
--	DialogUtils.showGiftGet({gifts = self._rewards})
end

function HeroFormationAppraiseDialog:onSure()
	local tipText = self._inputBox:getString()
	if string.len(tipText)==0 then
		self._viewMgr:showTip(lang("hero_comment_14"))
	else
		if self._callback then
			self._callback(tipText)
--			self:close()
		end
	end
--	self._viewMgr:showTip(tip)
end

return HeroFormationAppraiseDialog