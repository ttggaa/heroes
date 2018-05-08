--[[
    Filename:    GlobalShowTeamDialog.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-26 18:40:16
    Description: File description
--]]

local GlobalShowTeamDialog = class("GlobalShowTeamDialog",BasePopView)
function GlobalShowTeamDialog:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalShowTeamDialog:onInit()
	self._bg = self:getUI("bg")
	local notClose = true
	self:registerClickEvent(self._bg, function( )
		print("GlobalShowTeamDialog, close")
		if notClose then
			notClose = false
			if self._callback then
				self._callback()
			end
			self:close(true)
		end
	end)

	self._name = self:getUI("bg.name")
end


-- 接收自定义消息
function GlobalShowTeamDialog:reflashUI(data)
	local teamId = data.teamId
	local teamD = tab:Team(teamId)
	self._name:setString(lang(teamD.name) or "无名")
	self._callback = data.callback
	local teamVolume = {25,16,9,4,1}
	local teamNode = TeamUtils.showTeamRoles(teamId,teamVolume[tonumber(teamD.volume)])
	teamNode:setPosition(self._bg:getContentSize().width/2, self._bg:getContentSize().height/2)
	-- teamNode:setScale(1)
	self._bg:addChild(teamNode)
	-- 加背景特效
	local mc2 = mcMgr:createViewMC("fangzhenbeijingguang_choukaanim", true)
    mc2:setPosition(self._bg:getContentSize().width/2-250, self._bg:getContentSize().height/2+250)
    self._bg:addChild(mc2,-1)
end

return GlobalShowTeamDialog
