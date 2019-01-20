--[[
 	@FileName 	BackupOperateDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-24 10:46:47
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BackupOperateDialog = class("BackupOperateDialog", BasePopView)

function BackupOperateDialog:ctor( params )
	self.super.ctor(self)
	self._classType = params.classType
	self._teamId = params.teamId
	self._isChange = params.isChange
	self._changeId = params.changeId
	self._callback = params.callback
	self._callback1 = params.callback1
end

function BackupOperateDialog:onInit(  )
	
	self._teamModel = self._modelMgr:getModel("TeamModel")
	self._backupModel = self._modelMgr:getModel("BackupModel")

	self:registerClickEventByName("bg.layer.btn_close", function ()
        self:close()
        UIUtils:reloadLuaFile("backup.BackupOperateDialog")
    end)
	UIUtils:setTitleFormat(self:getUI("bg.layer.titleImg.titleTxt"), 1)

	self:getUI('bg.layer.titleType.Image'):loadTexture('backup_icon' .. self._classType .. ".png", 1)

	local data = self._teamModel:getTeamAndIndexById(self._teamId)
	local sysTeam = tab:Team(data.teamId)
	if self._isChange then
		sysTeam = tab:Team(self._changeId)
	end
	local cellItem = self:getUI('bg.layer.cellItem')
	cellItem:getChildByFullName('fightLab'):setString("战斗力:" .. data.score)
	local backQuality = self._teamModel:getTeamQualityByStage(data["stage"])
	local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(data, self._changeId)
	cellItem:getChildByFullName('name'):setString(lang(teamName))
	cellItem:getChildByFullName('name'):setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
	cellItem:getChildByFullName('name'):enableOutline(UIUtils.colorTable["ccColorQualityOutLine" .. backQuality[1]], 1)

	local iconBg = cellItem:getChildByFullName('iconBg')
	local icon = iconBg:getChildByFullName('teamIcon')
	if icon == nil then
		icon = IconUtils:createTeamIconById({teamData = data, sysTeamData = sysTeam, quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
        icon:setName("teamIcon")
        icon:setPosition(cc.p(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setScale(0.90)
        iconBg:addChild(icon)
	else
		IconUtils.updateTeamIconByView(icon, {teamData = data, sysTeamData = sysTeam, quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
	end

	registerTouchEvent(icon, function()
    end,function()
    end,function()
        ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", {iconType = 1, iconId = data.teamId or sysTeam.id, isChanged = self._isChange, changedId = self._changeId}, true)
    end)
    
	icon:setSwallowTouches(false)

	local img_use = cellItem:getChildByFullName('img_use')
	if self._backupModel:isTeamUsing(data.teamId) then
		img_use:setVisible(true)
	else
		img_use:setVisible(false)
	end

	local btn_change = self:getUI('bg.layer.btn_change')
	self:registerClickEvent(btn_change, function (  )
		if self._callback then
			self._callback()
		end
		self:close()
	end)

	local btn_down = self:getUI('bg.layer.btn_down')
	self:registerClickEvent(btn_down, function (  )
		if self._callback1 then
			self._callback1()
		end
		self:close()
	end)

end

function BackupOperateDialog:onDestroy()
	self.super.onDestroy(self)
end

function BackupOperateDialog:getAsyncRes( )
	return {

	}
end

return BackupOperateDialog