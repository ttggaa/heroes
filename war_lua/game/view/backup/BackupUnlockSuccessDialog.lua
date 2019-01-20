--[[
 	@FileName 	BackupUnlockSuccessDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-25 20:34:57
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BackupUnlockSuccessDialog = class("BackupUnlockSuccessDialog", BasePopView)

function BackupUnlockSuccessDialog:ctor( params )
	self.super.ctor(self)
	params = params or {}
	self._backupId = params.backupId or 1
    self._showType = params.showType or 1
    self._params = params
end

function BackupUnlockSuccessDialog:getAsyncRes(  )
	return {
		-- {"asset/ui/starCharts.plist", "asset/ui/starCharts.png"},
	}
end

function BackupUnlockSuccessDialog:onInit(  )
	self._backupModel = self._modelMgr:getModel("BackupModel")

	self:registerClickEventByName("Panel", function ()
        ScheduleMgr:nextFrameCall(self, function()
            self:close()
            UIUtils:reloadLuaFile("backup.BackupUnlockSuccessDialog")
        end)
    end)

	self._panel = self:getUI("Panel")
    self._bg = self:getUI('Panel.bg')
    self._left = self:getUI('leftbg')
    self._right = self:getUI('rightbg')
    local infoPanel = self:getUI('Panel.Panel1')
    local infoPanel2 = self:getUI('Panel.Panel2')

    if self._showType == 1 then
        infoPanel:setVisible(true)
        infoPanel2:setVisible(false)
        self._infoPanel = infoPanel
        self:updateBackupInfo()
    else
        infoPanel:setVisible(false)
        infoPanel2:setVisible(true)
        self._infoPanel = infoPanel2
        self:updateSkillInfo()
    end

    self._bg:setOpacity(0)
    self._left:setVisible(false)
    self._right:setVisible(false)
    self._left:runAction(cc.MoveTo:create(0.1, cc.p(0, 0)))
    self._right:runAction(cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH, 0)))

    if self._showType == 1 then
        self:addPopViewTitleAnim(self._panel, "jiesuochenggong_jiesuochenggong", self._panel:getContentSize().width / 2, 475)
    else
        self:addPopViewTitleAnim(self._panel, "jinengjiesuo_jinengjiesuo", self._panel:getContentSize().width / 2, 475)
    end

    local bgHeight = 200
    local maxHeight = self._bg:getContentSize().height + 12
    ScheduleMgr:delayCall(500, self, function( )
    	self._bg:setContentSize(cc.size(self._bg:getContentSize().width, bgHeight))
    	self._bg:setOpacity(255)
    	local sizeSchedule
    	local step = 0.5
        local stepConst = 30
        sizeSchedule = ScheduleMgr:regSchedule(1, self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bgHeight = bgHeight + stepConst
            if bgHeight < maxHeight then
                self._bg:setContentSize(cc.size(self._bg:getContentSize().width, bgHeight))
            else
                self._bg:setContentSize(cc.size(self._bg:getContentSize().width, maxHeight))
                self._bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1, 1.05),cc.ScaleTo:create(0.1, 1, 1)))
                ScheduleMgr:unregSchedule(sizeSchedule)

                if self._showType == 1 then
                    self:showBackupInfo()
                else
                    self:showSkillInfo()
                end
            end
        end)
    end)
end

function BackupUnlockSuccessDialog:showBackupInfo(  )
	self._left:setVisible(true)
    self._right:setVisible(true)
    self._left:runAction(cc.MoveTo:create(0.3, cc.p(self._left:getContentSize().width / 2, self._left:getContentSize().height / 2)))
    self._right:runAction(cc.MoveTo:create(0.3, cc.p(MAX_SCREEN_WIDTH - self._right:getContentSize().width / 2, self._right:getContentSize().height / 2)))

	self._infoPanel:setVisible(true)
    self._infoPanel:getChildByFullName('icon'):runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1, 1),cc.ScaleTo:create(0.1, 0.8, 0.8)))
    self._infoPanel:getChildByFullName("namebg"):setVisible(true)
    self._infoPanel:getChildByFullName("namebg"):runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 12)),cc.MoveBy:create(0.1, cc.p(0, -2))))

    local descBg = self._infoPanel:getChildByFullName("descBg")
    local childrens = descBg:getChildren()
    for k, v in pairs(childrens) do
        v:runAction(cc.Sequence:create(
            cc.DelayTime:create(k * 0.02),
            cc.FadeIn:create(0.2)
            ))
    end
    self._infoPanel:getChildByFullName('touchLab'):runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.FadeIn:create(0.2)
            ))
end

function BackupUnlockSuccessDialog:updateBackupInfo(  )
	self._infoPanel:setVisible(false)
    self._infoPanel:getChildByFullName("icon"):setScale(0)
    self._infoPanel:getChildByFullName("icon"):setPositionY(self._infoPanel:getChildByFullName("icon"):getPositionY() + 10)
    self._infoPanel:setPositionY(self._infoPanel:getPositionY() - 15)
    self._infoPanel:getChildByFullName("namebg"):setVisible(false)
    local descBg = self._infoPanel:getChildByFullName("descBg")
    local childrens = descBg:getChildren()
    for k, v in pairs(childrens) do
        v:setOpacity(0)
        if v:getChildrenCount() > 0 then
            v:setCascadeOpacityEnabled(true)
        end
    end
    self._infoPanel:getChildByFullName('touchLab'):setOpacity(0)

	local backupData = tab.backupMain[self._backupId]
    self._infoPanel:getChildByFullName('namebg.Label_38'):setString(lang(backupData.name))
	self._infoPanel:getChildByFullName('icon.Image_88'):loadTexture(backupData.specialSkillIcon .. ".png", 1)

	local formationIcons = self._backupModel:handleBackupThumb(descBg, backupData.icon)
	self._backupModel:handleFormation(formationIcons, backupData.icon)

    -- desc
    local sData = self._backupModel:getBackupById(backupData.id)
    local labelDiscription = self._infoPanel:getChildByFullName('descBg.effectdesc')
    local attr = {sklevel = sData.lv, artifactlv = 1}
    local desc = "[color=fce8c9, fontsize=20]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, backupData.specialSkill, attr, 1, nil, nil, nil) .. "[-]"
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)

	descBg:getChildByFullName('formation.grid4'):setCascadeOpacityEnabled(true)
	descBg:getChildByFullName('formation.grid9'):setCascadeOpacityEnabled(true)
	for k, v in pairs(formationIcons) do
		v:setCascadeOpacityEnabled(true)
	end

end

function BackupUnlockSuccessDialog:updateSkillInfo(  )
    self._infoPanel:setVisible(false)
    local label = self._infoPanel:getChildByFullName("Label_38")
    label:setPositionY(label:getPositionY() - 10)
    local descBg = self._infoPanel:getChildByFullName("descBg")
    label:setVisible(false)

    local backupData = tab.backupMain[self._backupId]
    local sData = self._backupModel:getBackupById(backupData.id)
    local skillType = self._params.skillType or 1
    local descText = ""
    if skillType == 1 then
        label:setString(lang("backup_Tips5"))
        descBg:getChildByFullName("name"):setString(lang(backupData.skill1Name))
        descBg:getChildByFullName("icon"):loadTexture(backupData.skill1Icon .. ".png", 1)
        local attr = {sklevel = sData.slv1 or 1, artifactlv = 1}
        descText = "[color=fce8c9, fontsize=16]" .. BattleUtils.getDescription(BattleUtils.kIconTypeHeroMastery, backupData.skill1, attr, 1, nil, nil, nil) .. "[-]"
    else
        label:setString(lang("backup_Tips6"))
        descBg:getChildByFullName("name"):setString(lang(backupData.skill2Name))
        descBg:getChildByFullName("icon"):loadTexture(backupData.skill2Icon .. ".png", 1)
        local attr = {sklevel = sData.slv2 or 1, artifactlv = 1}
        descText = "[color=fce8c9, fontsize=16]" .. BattleUtils.getDescription(BattleUtils.kIconTypeBackupSkill2, backupData.id, attr, 1, nil, nil, nil) .. "[-]"
    end

    -- desc
    local labelDiscription = self._infoPanel:getChildByFullName('descBg.effectdesc')
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then 
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(descText, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)

    local childrens = descBg:getChildren()
    for k, v in pairs(childrens) do
        v:setOpacity(0)
        if v:getChildrenCount() > 0 then
            v:setCascadeOpacityEnabled(true)
        end
    end
end

function BackupUnlockSuccessDialog:showSkillInfo(  )
    self._left:setVisible(true)
    self._right:setVisible(true)
    self._left:runAction(cc.MoveTo:create(0.3, cc.p(self._left:getContentSize().width / 2, self._left:getContentSize().height / 2)))
    self._right:runAction(cc.MoveTo:create(0.3, cc.p(MAX_SCREEN_WIDTH - self._right:getContentSize().width / 2, self._right:getContentSize().height / 2)))

    self._infoPanel:setVisible(true)
    self._infoPanel:getChildByFullName("Label_38"):setVisible(true)
    self._infoPanel:getChildByFullName("Label_38"):runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 12)),cc.MoveBy:create(0.1, cc.p(0, -2))))

    local descBg = self._infoPanel:getChildByFullName("descBg")
    local childrens = descBg:getChildren()
    for k, v in pairs(childrens) do
        v:runAction(cc.Sequence:create(
            cc.DelayTime:create(k * 0.02),
            cc.FadeIn:create(0.2)
            ))
    end
    self._infoPanel:getChildByFullName('touchLab'):runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.FadeIn:create(0.2)
            ))
end

function BackupUnlockSuccessDialog:onDestroy()
    local isNext = self._params.nextSkill
    BackupUnlockSuccessDialog.super.onDestroy(self)
    if isNext then
        self._viewMgr:showDialog("backup.BackupUnlockSuccessDialog", {showType = 2, backupId = self._backupId, skillType = 2})
    end
end

return BackupUnlockSuccessDialog