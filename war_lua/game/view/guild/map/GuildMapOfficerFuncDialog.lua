--[[
    Filename:    GuildMapOfficerFuncDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-02 15:29:48
    Description: File description
--]]
local GuildMapOfficerFuncDialog = class("GuildMapOfficerFuncDialog", BasePopView)

local l_btnImg = {
	[1] = "globalBtnUI_commonBtnImg_long1.png",
	[2] = "globalBtnUI_commonBtnImg_long2.png",
}

function GuildMapOfficerFuncDialog:ctor(data)
    GuildMapOfficerFuncDialog.super.ctor(self)
	self._targetId = data.targetId
end

function GuildMapOfficerFuncDialog:onInit()
	for i=1, 3 do
		local funcBtn = self:getUI("bg.bgImg.funcBtn"..i)
		local funcNameLab = self:getUI("bg.bgImg.funcNameLab"..i)
		funcNameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		self:registerClickEvent(funcBtn, function()
			self._viewMgr:lock(-1)
			funcBtn:loadTextures(l_btnImg[2], l_btnImg[2], "", 1)
			funcNameLab:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
			local anim = cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(function()
				--[[self._viewMgr:unlock()
				self:close()--]]
				self._serverMgr:sendMsg("GuildMapServer", "acJNpc2", {tagPoint = self._targetId, type = i }, true, {}, function(result)
					self._viewMgr:unlock()
					self._viewMgr:showTip(lang("GUILD_MILITARY_TIP_6"))
					self:close()
				end)
			end))
			funcBtn:runAction(anim)
		end)
	end
end

return GuildMapOfficerFuncDialog