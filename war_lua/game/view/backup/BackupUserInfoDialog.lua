--[[
 	@FileName 	BackupUserInfoDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-26 11:00:01
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BackupUserInfoDialog = class("BackupUserInfoDialog", BasePopView)

function BackupUserInfoDialog:ctor( data )
	self.super.ctor(self)
	self._bid = data.bid
	self._bidData = data.bidData
	self._growData = data.growData or {}
	self._playerData = data.playerData
end

function BackupUserInfoDialog:getAsyncRes(  )
	return {
		-- {"asset/ui/newFormation.plist", "asset/ui/newFormation.png"},
	}
end

function BackupUserInfoDialog:onInit(  )
	self._teamModel = self._modelMgr:getModel("TeamModel")
	self._backupModel = self._modelMgr:getModel("BackupModel")

	self:registerClickEventByName("bg.closeBtn", function(  )
		self:close()
		UIUtils:reloadLuaFile("backup.BackupUserInfoDialog")
	end)

	local title = self:getUI("bg.title_img.title_txt")
    UIUtils:setTitleFormat(title, 1)

    local sysData = tab.backupMain[tonumber(self._bid)]
    local infoBg = self:getUI('bg.infoBg')
    infoBg:getChildByFullName('name'):setString(lang(sysData.name))
    infoBg:getChildByFullName('desBg')
    infoBg:getChildByFullName('level'):setString("Lv." .. (self._growData.lv or 1))

    infoBg:getChildByFullName('icon.Image_88'):loadTexture(sysData.specialSkillIcon .. ".png", 1)

    local labelDiscription = infoBg:getChildByFullName('desBg')
	local attr = {sklevel = (self._growData.lv or 1), artifactlv = 1}
	local desc = "[color=7a5221, fontsize=20]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, sysData.specialSkill, attr, 1, nil, nil, nil) .. "[-]"
	local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, 10)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, -richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)

    local formationIcon = {}
    for i = 1, 16 do
    	formationIcon[i] = infoBg:getChildByFullName('formation_bg.formation.formation_icon_' .. i)
    end
    local classData = sysData.class
	classData, isTop, isDown, nPos = self._backupModel:calClassData(classData, self._bidData.bpos)

	self._backupModel:handleFormation(formationIcon, classData)

	local teamBg = self:getUI('bg.teamBg')
	for i = 1, 3 do
		local iconBg = teamBg:getChildByFullName('bt_' .. i)
		local teamId = self._bidData["bt" .. i]
		if teamId and teamId ~= 0 then
			local sysTeam = tab:Team(teamId)
			local btData = self._bidData["btData" .. i]
			local backQuality = self._teamModel:getTeamQualityByStage(btData["stage"])
			local icon = IconUtils:createTeamIconById({teamData = btData, sysTeamData = sysTeam, quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 3, clickCallback = function( )		
		    	local detailData = {}
		    	detailData.team = btData
		    	detailData.team.teamId = teamId
		  --   	if changeId then
				-- 	detailData.team.teamId = changeId
				-- end    
		    	detailData.pokedex = self._playerData.pokedex 
		    	detailData.treasures = self._playerData.treasures
		    	detailData.runes = self._playerData.runes
		    	detailData.battleArray = self._playerData.battleArray
    			detailData.pTalents = self._playerData.pTalents
		    	ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data = detailData}, true)
		    end})
	        -- icon:setPosition(cc.p(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2))
	        -- icon:setAnchorPoint(cc.p(0.5, 0.5))
	        icon:setPosition(0, 0)
	        icon:setScale(0.90)
	        iconBg:addChild(icon)
	    else
			local bagGrid = ccui.Widget:create()
		    bagGrid:setContentSize(cc.size(107, 107))
		    bagGrid:setAnchorPoint(cc.p(0, 0))

		    local bagGridFrame = ccui.ImageView:create()
		    bagGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
		    bagGridFrame:setName("bagGridFrame")
		    bagGridFrame:setContentSize(cc.size(107, 107))
		    bagGridFrame:ignoreContentAdaptWithSize(false)
		    bagGridFrame:setAnchorPoint(cc.p(0, 0))
		    bagGrid:addChild(bagGridFrame, 1)

		    local bagGridBg = ccui.ImageView:create()
		    bagGridBg:loadTexture("globalImageUI4_itemBg3.png", 1)
		    bagGridBg:setName("bagGridBg")
		    bagGridBg:setContentSize(cc.size(107, 107))
		    bagGridBg:ignoreContentAdaptWithSize(false)
		    bagGridBg:setAnchorPoint(cc.p(0.5 ,0.5))
		    bagGridBg:setPosition(cc.p(bagGrid:getContentSize().width / 2, bagGrid:getContentSize().height / 2))
		    bagGrid:addChild(bagGridBg, -1)

		    bagGrid:setScale(0.90)
		    iconBg:addChild(bagGrid)
		end
	end
end

return BackupUserInfoDialog