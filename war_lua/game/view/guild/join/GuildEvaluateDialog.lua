--[[
    Filename:    GuildEvaluateDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-18 21:34:09
    Description: File description
--]]

-- 联盟详细信息
local GuildEvaluateDialog = class("GuildEvaluateDialog",BasePopView)
function GuildEvaluateDialog:ctor(data)
    self.super.ctor(self)
	self._callback = data.callback
end

function GuildEvaluateDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    title:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	
	self._limitTime = tab:Setting("GUILD_EXIT_TIME").value * 60 * 60
	
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		if self._updateId then
			ScheduleMgr:unregSchedule(self._updateId)
			self._updateId = nil
		end
		self:close()
	end)
	
	--左侧小精灵
	self._roleImg = self:getUI("bg.role_img")
	self._roleImg:loadTexture("asset/bg/global_reward_img.png")
	
	--描述富文本
	local richtextBg = self:getUI("bg.richTextBg")
	local guildName = self._modelMgr:getModel("UserModel"):getLastGuildName()
	local desc = string.gsub(lang("Alliance evaluation_1"),"{$guildId}", guildName)
	local richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
	richText:setPixelNewline(true)
	richText:formatText()
	richText:setVerticalSpace(3)
	richText:enablePrinter(true)
	richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
	richText:setName("richText")
	richtextBg:addChild(richText)
	
	--倒计时timeLab
	self._timeLab = self:getUI("bg.timeLab")
	
	--退盟原因选项
	for i=1, 4 do
		local reasonBtn = self:getUI("bg.btn"..i)
		self:registerClickEvent(reasonBtn, function()
			self:quitEvaluate(i)
		end)
	end
	
	self._updateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
		self:update(dt)
	end)
	self:update()
end

function GuildEvaluateDialog:quitEvaluate(index)
	local btn = self:getUI("bg.btn"..index)
	btn:setEnabled(false)
	btn:setBright(false)
	self._viewMgr:lock(-1)
	self._serverMgr:sendMsg("GuildServer", "quitJudge", {type = index}, true, {}, function(result)
		ScheduleMgr:delayCall(800, self, function()
			if self._updateId then
				ScheduleMgr:unregSchedule(self._updateId)
				self._updateId = nil
			end
			self._viewMgr:unlock()
			if self._callback then
				self._callback()
			end
			self:close()
		end)
	end)
end

function GuildEvaluateDialog:update(dTime)
	local leaveTime = self._modelMgr:getModel("GuildModel"):getPlayerLastLeaveTime()
	local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	
	local intervalTime = nowTime - leaveTime
	if intervalTime>=self._limitTime then
		if self._updateId then
			ScheduleMgr:unregSchedule(self._updateId)
			self._updateId = nil
		end
		if self._callback then
			self._callback(true)
		end
		self:close()
	else
		local remainingTime = self._limitTime - intervalTime
		local timeStr = TimeUtils.getTimeStringHMS(remainingTime)
		self._timeLab:setString(timeStr)
	end
end

return GuildEvaluateDialog