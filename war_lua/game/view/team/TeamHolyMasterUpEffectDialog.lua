--[[
    Filename:    TeamHolyMasterUpEffectDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local TeamHolyMasterUpEffectDialog = class("TeamHolyMasterUpEffectDialog", BaseLayer)

function TeamHolyMasterUpEffectDialog:ctor(data)
    TeamHolyMasterUpEffectDialog.super.ctor(self)
	self._level = data.nowLv
	self._compareData = data.compareData
end

function TeamHolyMasterUpEffectDialog:onInit()
	local bg = self:getUI("bg.bgImg")
	bg:runAction(cc.Sequence:create(
		cc.DelayTime:create(1),
		cc.CallFunc:create(function()
			self:viewFadeOut(0.5)
		end),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			self._viewMgr:closeHintView()
		end))
	)
	local levelLab = self:getUI("bg.bgImg.nowLevelLab")
	levelLab:setString(self._level)
	for i,v in ipairs(self._compareData) do
		local nameLab = self:getUI("bg.bgImg.nameLab"..i)
		nameLab:setString(lang("ATTR_" .. v[1]))
		local oldValueLab = self:getUI("bg.bgImg.oldValue"..i)
		oldValueLab:setString("+"..v[2][1])
		local newValueLab = self:getUI("bg.bgImg.newValue"..i)
		newValueLab:setString("+"..v[2][2])
	end
end

function TeamHolyMasterUpEffectDialog:viewFadeOut(time)
	local bg = self:getUI("bg.bgImg")
	for i,v in ipairs(bg:getChildren()) do
		v:runAction(cc.FadeOut:create(time))
	end
	bg:runAction(cc.FadeOut:create(time))
end

function TeamHolyMasterUpEffectDialog:onShow()
	
end

return TeamHolyMasterUpEffectDialog