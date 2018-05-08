--[[
    Filename:    GuildMapFamView.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2017-10-30 14:53:42
    Description: File description
--]]

local GuildMapFamView = class("GuildMapFamView", BaseView)

local l_percent = {
	[0] = 0,
	[1] = 20,
	[2] = 40,
	[3] = 60,
	[4] = 80,
	[5] = 100
}

local l_enableColor = cc.c3b(255, 255, 255)
local l_disableColor = cc.c3b(70, 70, 70)

local l_wizardSkinId = 80000001--26050203

function GuildMapFamView:ctor(data)
    GuildMapFamView.super.ctor(self)
	if data then
		self._guildFamData = self._modelMgr:getModel("GuildMapModel"):getShowElementDataByGridKey(data.param.targetId)
		self._gridKey = data.param.targetId
	end
	self._hasJoin = false
	self._famModel = self._modelMgr:getModel("GuildMapFamModel")
end

function GuildMapFamView:getAsyncRes()
	return {
		{"asset/ui/guildMapFam.plist", "asset/ui/guildMapFam.png"},
	}
end

function GuildMapFamView:getBgName()
	self._bgIndex = self._guildFamData.background
    return string.format("mijing%s.jpg", self._bgIndex)
end

function GuildMapFamView:onInit()
	self._famData = self._famModel:getFamDataByGridKey(self._gridKey)
	local returnBtn = self:getUI("returnBtn")
	local effect = mcMgr:createViewMC("mijingrukou1_mijingrukou", true)
	effect:setPosition(cc.p(returnBtn:getContentSize().width/2+2, returnBtn:getContentSize().height/2-4))
	effect:setScale(0.75)
	returnBtn:addChild(effect)
	
	self._qipao = self:getUI("bg.qipao")
	
	local fromLabel = self:getUI("panelTitle.fromLabel")
	local playerNameLabel = self:getUI("panelTitle.playerNameLabel")
	fromLabel:enableOutline(cc.c4b(60, 30, 10, 255))
	playerNameLabel:enableOutline(cc.c4b(60, 30, 10, 255))
	playerNameLabel:setString(self._guildFamData.sname)

	self:registerClickEvent(returnBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("guild.map.GuildMapFamView")
		end
		self:close()
--		self:getReward()
	end)
	
	local nameLabel = self:getUI("panelTitle.mapTitleLabel")
	nameLabel:enable2Color(1, cc.c4b(249, 227, 159, 255))
	nameLabel:setString(lang(tab.famAppear[self._guildFamData.stype].name))
	
	local ruleBtn = self:getUI("panelTitle.ruleBtn")
--	ruleBtn:setScale(0.7)
	self:registerClickEvent(ruleBtn, function()
		self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = lang("famRule")}, true)
	end)
	
	local boxBtn = self:getUI("panelProgress.boxBtn")
	self:registerClickEvent(boxBtn, function()
		self:getReward()
	end)
	
	self._percentImg = {}
	for i=1, 5 do
		self._percentImg[i] = self:getUI("panelProgress.monster"..i)
		local label = self:getUI("panelProgress.monster"..i..".monsterLabel"..i)
		label:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
	end
	local killLabel = self:getUI("panelProgress.killNumLabel")
	killLabel:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
	if self._guildFamData.stype==2 then
		killLabel:setString("巫师完成数目:")
	end
	
	self._timesLabel = self:getUI("panelTitle.timesBg.timesLabel")
	self._timesLabel:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
	
	local timesTitle = self:getUI("panelTitle.timesBg.timesTitle")
	timesTitle:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
	
	self._progress = self:getUI("panelProgress.progBg.progress")
	
	self._recordNode = {}
	for i=1, 5 do
		self._recordNode[i] = {
			killerLabel = self:getUI("panelUnder.killerBg.killerLabel"..i),
			npcLabel = self:getUI("panelUnder.killerBg.npcLabel"..i),
			tagImg = self:getUI("panelUnder.killerBg.killTag"..i)
		}
		self._recordNode[i].killerLabel:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
		self._recordNode[i].killerLabel:setString(lang(self._guildFamData.stype==1 and "GUILD_FAM_TIPS_25" or "GUILD_FAM_TIPS_26"))
		self._recordNode[i].npcLabel:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
		if self._guildFamData.stype==2 then
			self._recordNode[i].tagImg:loadTexture("guild_fam_changeTag.png", 1)
			self._recordNode[i].tagImg:setPositionY(self._recordNode[i].killerLabel:getPositionY())
		end
		self._recordNode[i].killerLabel:setColor(cc.c4b(200, 200, 200, 255))
		self._recordNode[i].npcLabel:setColor(cc.c4b(200, 200, 200, 255))
		self._recordNode[i].tagImg:setSaturation(-100)
	end

	self:createFamNpc()
	
	local inviteBtn = self:getUI("panelUnder.inviteBtn")
	local myId = self._modelMgr:getModel("UserModel"):getRID()
	inviteBtn:setVisible(self._guildFamData.stid==myId)
	self:registerClickEvent(inviteBtn, function()
--		local dialog = "guild.map.GuildMapFindFamEffectDialog"
		self._viewMgr:showDialog("guild.map.GuildMapFamInviteDialog", {gridKey = self._gridKey})
	end)
	
	self:listenReflash("GuildMapFamModel", self.refreshFamData)
	
	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            self._modelMgr:getModel("GuildMapFamModel"):clearInviteKey()
        end
    end)
end

function GuildMapFamView:createFamNpc()
	self._heroModel = {}
	local famData = self._famData
	local famPosConfig = tab.famMap[self._bgIndex].fight
	local famType = self._guildFamData.stype
	for i,v in ipairs(famData) do
		local heroSkin
		local heroName
		if famType==1 then
			heroName = v.battle.name.."幻像"
			if v.battle.hero.skin then
				heroSkin = tab.heroSkin[v.battle.hero.skin].heroart
			end
		else
			heroName = lang(tab.famWitch[i].name)
			heroSkin = tab.heroSkin[l_wizardSkinId].heroart
		end
		if heroSkin == nil then
			heroSkin = tab.hero[v.battle.formation.heroId].heroart
		end
		local heroSeat = self:createHeroMc(i, heroSkin, heroName, v )
		local heroMc = heroSeat.heroMc
		self:registerClickEvent(heroMc.checkBtn, function()
			self:onCheckNpc(i)
		end)
		self:registerClickEvent(heroMc.challengeBtn, function()
			self:onChallengeNpc(i)
		end)
		self:registerClickEvent(heroMc.modelPanel, function()
			self:onModelClick(i)
		end)
		local pos = famPosConfig[i]
		if famType==1 then--英雄模型默认方向向右
			heroMc:setScaleX(pos[3]==1 and 0.6 or -0.6)
		else--巫师形象默认向左
			heroMc:setScaleX(pos[3]==1 and -0.9 or 0.9)
		end
		heroSeat:setPosition(cc.p(pos[1], pos[2]))
		self._heroModel[i] = heroMc
	end
	self:refreshFamData()
end

function GuildMapFamView:createHeroMc(index, inMcFileName, inName, npcData)
	local famType = self._guildFamData.stype
	local underSeat = self:getUI("bg.heroSeat"..index)
	local underSize = underSeat:getContentSize()
	
	local underSelectEffect = mcMgr:createViewMC("xuanzhong2_guanqiaxuanzhong", true)
	underSelectEffect:setPosition(underSize.width/2+1, underSize.height/2+8)
	underSelectEffect:setVisible(false)
	underSeat:addChild(underSelectEffect)
	
	local topSelectEffect = mcMgr:createViewMC("xuanzhong1_guanqiaxuanzhong", true)
	topSelectEffect:setPosition(underSize.width/2+1, underSize.height/2+8)
	topSelectEffect:setVisible(false)
	underSeat:addChild(topSelectEffect, 1)
	
	local heiyanEffect = mcMgr:createViewMC("heiyan_guanqiaxuanzhong", true)
	heiyanEffect:setPosition(underSize.width/2+1, underSize.height*1.5)
	heiyanEffect:setScale(0.8)
	heiyanEffect:setVisible(true)
	underSeat:addChild(heiyanEffect, 1)

    local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
    local heroMc = nil
	if npcData.cid~="" then
		heroMc = IntanceMcAnimNode.new({"stop"}, inMcFileName,
			function(sender)
				sender:changeMotion(1, nil, true)
			end
			,100,100,
			{"stop" },{{3,10},1}, true)
		heroMc:stop()
	else
		heroMc = IntanceMcAnimNode.new({"stop", "win"}, inMcFileName,
			function(sender) 
				sender:runStandBy()
			end
			,100,100,
			{"stop"},{{3,10},1})
	end
    heroMc.userId = npcData.battle.rid
    heroMc:setScale(famType==1 and 0.6 or 0.9)
	heroMc:setScaleX(famType==1 and 0.6 or -0.9)
	heroMc:setPosition(underSize.width/2, underSize.height/2+10)
	underSeat:addChild(heroMc)
	heroMc:setColor(l_disableColor)
	heroMc:setOpacity(200)
	
	heroMc.underSelectEffect = underSelectEffect
	heroMc.topSelectEffect = topSelectEffect
	heroMc.heiyanEffect = heiyanEffect
	
	--被击杀标签
	local killTagImg  = ccui.ImageView:create()
	killTagImg:loadTexture(famType==1 and "guild_fam_killed.png" or "guild_fam_finished.png", 1)
	killTagImg:setPosition(underSize.width/2+10, 80)
	killTagImg:setVisible(npcData.cid~="")
	heroMc.killTagImg = killTagImg
	underSeat:addChild(killTagImg, 1)

	--名字背景
    local nameBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_halfBar1.png")
	nameBg:setCapInsets(cc.rect(40, 10, 1, 1))
    nameBg:setPosition(underSize.width/2, 170)--由于巫师秘境的人物小，所以要根据不同类型设置名字位置
    underSeat:addChild(nameBg, 30)
	
    local nameLab = cc.Label:createWithTTF(inName, UIUtils.ttfName, 18)
    local width = 92 
    if (nameLab:getContentSize().width + 60) > width then 
        width = nameLab:getContentSize().width + 60
    end
    nameBg:setContentSize(width, 30)
    nameLab:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2)
    nameBg:addChild(nameLab)
	nameLab:setTextColor(cc.c4b(252, 244, 197, 255))
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
    heroMc.nameBg = nameBg
	heroMc.nameLabel = nameLab
	nameBg:setVisible(false)
	
	--战斗力标签
	if famType==1 then
		local powerText = "战斗力 "..npcData.battle.formation.score
		local powerLabel = cc.Label:createWithTTF(powerText, UIUtils.ttfName, 16)
		powerLabel:setTextColor(cc.c4b(255, 238, 160, 255))
		powerLabel:setPosition(underSize.width/2, powerLabel:getContentSize().height*2.5)
		powerLabel:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
		powerLabel:setVisible(false)
		heroMc.powerLabel = powerLabel
		underSeat:addChild(powerLabel, 1)
	end
	
	heroMc.challengeBtn = underSeat:getChildByFullName("challengeBtn"..index..famType)
	heroMc.checkBtn = underSeat:getChildByFullName("checkBtn"..index..famType)
	heroMc.challengeBtn:setVisible(false)
	heroMc.checkBtn:setVisible(true)
	
	heroMc.modelPanel = underSeat:getChildByFullName("modelPanel"..index)
	
	underSeat.heroMc = heroMc
    return underSeat
end

function GuildMapFamView:onModelClick(index)
	--[[if self._famData[index].cid~="" then
		
	end--]]
	if index==self._selectIndex then
		if self._famData[index].cid~="" then
			local desc = self._guildFamData.stype==1 and lang("GUILD_FAM_TIPS_16") or lang("GUILD_FAM_TIPS_17")
			self._viewMgr:showTip(desc)
			return
		else
			self:onChallengeNpc(index, self._famData[index].cid~="")
		end
	else
		self:onCheckNpc(index, self._famData[index].cid~="")
	end
end

function GuildMapFamView:onCheckNpc(index, isDie)
	if index==self._selectIndex then return end
	
	local heroMc = self._heroModel[index]
	heroMc:setColor(l_enableColor)
	heroMc:setOpacity(175)
	heroMc.challengeBtn:setVisible(not isDie)
	heroMc.checkBtn:setVisible(false)
	heroMc.underSelectEffect:setVisible(true)
	heroMc.topSelectEffect:setVisible(true)
	heroMc.heiyanEffect:setVisible(false)
	heroMc.nameBg:setVisible(true)
	if heroMc.powerLabel then heroMc.powerLabel:setVisible(true) end
	
	if self._guildFamData.stype==2 then
		if isDie then
			self._qipao:setVisible(false)
		else
			local underSeat = heroMc:getParent()
			if self._qipao:getChildByFullName("qipaoText") then
				self._qipao:getChildByFullName("qipaoText"):removeFromParent()
			end
			
			local item = self._famData[index].battle[2]
			local itemId
			if item[1] == "tool" then
				itemId = item[2]
			else
				itemId = IconUtils.iconIdMap[item[1]]
			end
			local toolData = tab:Tool(tonumber(itemId))
			
			local text = lang("GUILD_FAM_TIPS_12")
			text = string.gsub(text, "$name", lang(toolData.name))
			local qipaoText = RichTextFactory:create(text, 180, 0)
			qipaoText:setPixelNewline(true)
			qipaoText:formatText()
			local realSize = qipaoText:getRealSize()
			if self._qipao:getContentSize().height<realSize.height+40 then
				self._qipao:setContentSize(200, realSize.height+30)
			end
			qipaoText:setPosition(100, self._qipao:getContentSize().height - realSize.height/2-10)
			qipaoText:setName("qipaoText")
			self._qipao:addChild(qipaoText)
			self._qipao:setScaleX(tab.famMap[self._bgIndex].fight[index][3]==1 and 1 or -1)
			local direct = self._qipao:getScaleX()
			local posX = direct>0 and underSeat:getPositionX()+self._qipao:getContentSize().width/5 or underSeat:getPositionX()-self._qipao:getContentSize().width/5
			qipaoText:setScaleX(direct>0 and 1 or -1)
			self._qipao:setPosition(posX, underSeat:getPositionY()+70)
			self._qipao:setVisible(true)
		end
	end
	
	if self._selectIndex then
		local heroMcOld = self._heroModel[self._selectIndex]
		if self._famData[self._selectIndex].cid~="" then
			self:npcToDieState(heroMcOld)
		else
			heroMcOld:setColor(l_disableColor)
			heroMcOld:setOpacity(200)
			heroMcOld.challengeBtn:setVisible(false)
			heroMcOld.checkBtn:setVisible(true)
			heroMcOld.underSelectEffect:setVisible(false)
			heroMcOld.topSelectEffect:setVisible(false)
			heroMcOld.heiyanEffect:setVisible(true)
			heroMcOld.nameBg:setVisible(false)
			if heroMcOld.powerLabel then heroMcOld.powerLabel:setVisible(false) end
		end
	end
	
	self._selectIndex = index
end

function GuildMapFamView:onChallengeNpc(index)
	--
	local npcData = self._famData[index]
	local famType = self._guildFamData.stype
	if famType==2 then
		npcData.battle.skin = l_wizardSkinId
	end
	local limitTimes = tonumber(tab:Setting("FAMEXPLORATIONTIMES").value)
	local nowTimes = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(74)
	if npcData.cid=="" then		
		if nowTimes>=limitTimes then
			self._viewMgr:showTip(lang("GUILD_FAM_TIPS_8"))
			return
		elseif self._hasJoin then
			self._viewMgr:showTip(famType==1 and lang("GUILD_FAM_TIPS_7") or lang("GUILD_FAM_TIPS_11"))
			return
		end
		self._viewMgr:showDialog("guild.map.GuildMapFamBattleNode", {index = index, targetId = self._gridKey, npcData = npcData.battle, famType = famType})
	end
end

function GuildMapFamView:npcToDieState(heroMc)
	heroMc.killTagImg:setVisible(true)
	heroMc:setColor(l_disableColor)
	heroMc.nameBg:setVisible(false)
	heroMc.challengeBtn:setVisible(false)
	heroMc.checkBtn:setVisible(false)
	heroMc.topSelectEffect:setVisible(false)
	heroMc.underSelectEffect:setVisible(false)
	heroMc.heiyanEffect:setVisible(false)
	if heroMc.powerLabel then
		heroMc.powerLabel:setVisible(false)
	end
end

function GuildMapFamView:refreshFamData(data)
	self._famData = self._famModel:getFamDataByGridKey(self._gridKey)
	local myId = self._modelMgr:getModel("UserModel"):getRID()
	local killCount = 0
	if self._selectIndex and self._famData[self._selectIndex].cid~="" then
		self._selectIndex = nil
	end
	self._qipao:setVisible(false)
	
	local tbNotKilledNpcName = {}
	for i,v in ipairs(self._famData) do
		local heroMc = self._heroModel[i]
		if v.cid~="" then
			killCount = killCount + 1
			if v.cid==myId then
				self._hasJoin = true
			end
			
			self:npcToDieState(heroMc)
			heroMc:stop()
			local recordNode = self._recordNode[killCount]
			recordNode.killerLabel:setString(v.cname)
			recordNode.npcLabel:setString(heroMc.nameLabel:getString())
			recordNode.killerLabel:setColor(cc.c4b(252, 244, 197, 255))
			recordNode.npcLabel:setColor(cc.c4b(205, 32, 30, 255))
			recordNode.tagImg:setSaturation(0)
		else
			if not self._selectIndex then
				self:onCheckNpc(i)
			end
			table.insert(tbNotKilledNpcName, heroMc.nameLabel:getString())
		end
	end
	for i,v in ipairs(tbNotKilledNpcName) do
		local recordNode = self._recordNode[killCount + i]
		recordNode.npcLabel:setString(v)
--		recordNode.npcLabel:setColor(cc.c4b(200, 200, 200, 255))
	end
	self._progress:setPercent(l_percent[killCount])
	for i,v in ipairs(self._percentImg) do
		local img = i>killCount and "guild_fam_percentImg1.png" or "guild_fam_percentImg2.png"
		v:loadTexture(img, 1)
	end
	
	local limitTimes = tonumber(tab:Setting("FAMEXPLORATIONTIMES").value)
	local nowTimes = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(74)
	self._timesLabel:setString(string.format("%s/%s", limitTimes-nowTimes, limitTimes))
	self._timesLabel:setColor(nowTimes>=limitTimes and cc.c4b(205, 32, 30, 255) or cc.c4b(39, 247, 58, 255))
	
end

function GuildMapFamView:getReward()
	local desc = self._guildFamData.stype==1 and lang("GUILD_FAM_TIPS_18") or lang("GUILD_FAM_TIPS_19")
	local killCount = 0
	for i,v in ipairs(self._famData) do
		if v.cid~="" then
			killCount = killCount + 1
		end
	end
	killCount = killCount==#self._famData and killCount or killCount+1
	local rewards = tab.famAppear[self._guildFamData.stype].award[killCount]
	DialogUtils.showGiftGet( {gifts = rewards, viewType = 1, canGet = false, des = desc, isFam = true} )
end

return GuildMapFamView