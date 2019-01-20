--[[
 	@FileName 	TeamSpecialSkillSwitchDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-06-26 18:37:10
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local TeamSpecialSkillSwitchDialog = class("TeamSpecialSkillSwitchDialog", BasePopView)

function TeamSpecialSkillSwitchDialog:ctor(params)
    TeamSpecialSkillSwitchDialog.super.ctor(self)
    if not params then
        params = {}
    end
    self._teamId = params.teamId or 101
end

function TeamSpecialSkillSwitchDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamSpecialSkillSwitchDialog")
        end
        self:close()
    end)

    local title1 = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title1, 1, 1)
    self:getUI("bg.Image_68"):loadTexture("asset/bg/TeamSpecialUI_img2.jpg")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._teamData = self._teamModel:getTeamAndIndexById(self._teamId)
    self._usedSkillId = self._teamData.ss

    self._selectSkillId = 5
    if self._usedSkillId then
    	self._selectSkillId = self._usedSkillId
    end

    self._skillData = {}
    local sysTeam = tab:Team(self._teamId)
    for i = 5, 6 do
        local skillId = sysTeam.skill[i][2]
        local skillType = sysTeam.skill[i][1]
        local skill = SkillUtils:getTeamSkillByType(skillId, skillType)
        self._skillData[i] = clone(skill)
    end

    self._scrollView = self:getUI("bg.infoBg.descScrollView")
    self._scrollViewW = self._scrollView:getContentSize().width + 1
    self._scrollViewH = self._scrollView:getContentSize().height + 1
    self._scrollView:setClippingType(0)

    self._skillIconPos = {}
    self._skillIconPos[5] = self:getUI("bg.skillBg.skillBg1")
    self._skillIconPos[6] = self:getUI("bg.skillBg.skillBg2")
    self._skillIconBg = {}
    self._skillIconBg[5] = self:getUI("bg.skillBg.icon1")
    self._skillIconBg[6] = self:getUI("bg.skillBg.icon2")
    self._usedIconBg = self:getUI("bg.skillBg.selectBg")

    self:updateInfo()
    self:addSkill()
end

function TeamSpecialSkillSwitchDialog:updateInfo(  )
	local sysSkill = self._skillData[self._selectSkillId]

	local skillName = self:getUI("bg.infoBg.Label_70")
    skillName:setString(lang(sysSkill.name))
    skillName:setColor(cc.c3b(178, 124, 79))
    skillName:enable2Color(1, cc.c4b(98, 49, 25, 255))

    if OS_IS_WINDOWS then
        local labBg = self:getUI("bg.infoBg")
        local skillIdLab = labBg:getChildByFullName("skillIdLab")
        if skillIdLab == nil then
            skillIdLab = ccui.Text:create()
            skillIdLab:setFontSize(20)
            skillIdLab:setFontName(UIUtils.ttfName)
            skillIdLab:setColor(cc.c4b(0, 0, 0, 255))
            skillIdLab:setPosition(skillName:getPositionX(), skillName:getPositionY() - 40)
            skillIdLab:setName("skillIdLab")
            labBg:addChild(skillIdLab)
        end
        skillIdLab:setString("[id:" .. sysSkill.id .. "]")
    end

    local iconBg = self:getUI("bg.infoBg.iconBg")
    local skillIcon = iconBg:getChildByFullName("skillIcon")
    local param = {teamSkill = sysSkill, eventStyle = 0, level = self._teamData["sl" .. (self._selectSkillId)], levelLab = false, teamData = self._teamData}
    if skillIcon then
        IconUtils:updateTeamSkillIconByView(skillIcon, param)
    else
        skillIcon = IconUtils:createTeamSkillIconById(param)
        skillIcon:setPosition(cc.p(iconBg:getContentSize().width * 0.5, iconBg:getContentSize().height * 0.5))
        skillIcon:setAnchorPoint(cc.p(0.5,0.5))
        skillIcon:setName("skillIcon")
        iconBg:addChild(skillIcon)
    end

    -- 描述
    local richText = self._scrollView:getChildByName("richText")
    if richText ~= nil then
        richText:removeFromParent()
    end
    local skillLevel = self._teamData["sl" .. (self._selectSkillId)]
    if skillLevel < 1 then
        skillLevel = 1
    end
    local addLevel = 0      -- 额外增加等级
    local rune = self._teamData.rune
    if rune and rune.suit and rune.suit["4"] then
        local id,level = TeamUtils:getRuneIdAndLv(rune.suit["4"])
        if id == 104 then
            addLevel = level
        end
        if k == 1 then
            if id == 403 then
                addLevel = level
            end
        end
    end
    local desc = SkillUtils:handleSkillDesc1(lang(sysSkill.des), self._teamData, skillLevel + addLevel)
    if string.find(desc, "color=") == nil then
        desc = "[color=f0e3ca]"..desc.."[-]"
    end
    -- desc = string.gsub(desc, "fae6c8", "8a5c1d")
    richText = RichTextFactory:create(desc, self._scrollView:getContentSize().width - 10, self._scrollView:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    
    richText:setName("richText")
    self._scrollView:addChild(richText)
    local realHeight = self._scrollViewH
    if richText:getInnerSize().height > self._scrollViewH then
        realHeight = richText:getInnerSize().height
        richText:setPosition(self._scrollView:getContentSize().width*0.5 - 5, richText:getInnerSize().height*0.5)
    else
        richText:setPosition(self._scrollView:getContentSize().width*0.5 - 5, self._scrollView:getContentSize().height - richText:getInnerSize().height*0.5)
    end
    self._scrollView:setInnerContainerSize(cc.size(self._scrollViewW,realHeight))
    self._scrollView:getInnerContainer():setPositionY(self._scrollViewH - realHeight)

    local lock_txt = self:getUI("bg.infoBg.lock_txt")
    lock_txt:setColor(cc.c4b(206, 32, 32, 255))
    local btn_save = self:getUI("bg.infoBg.btn_save")
    local already_img = self:getUI("bg.infoBg.already_img")
    local unlockNode = self:getUI("bg.infoBg.unlockNode")
    lock_txt:setVisible(false)
    btn_save:setVisible(false)
    already_img:setVisible(false)
    unlockNode:setVisible(false)
    local quality = self._teamModel:getTeamQualityByStage(self._teamData["stage"])
    if quality[1] < 6 then
        lock_txt:setVisible(true)
    else
        local level = self._teamData["sl" .. self._selectSkillId] or -1
        if level < 1 then
            local goldValue = tab:Setting("G_TEAMSKILL_UNLOCK").value[self._selectSkillId] or 0
            unlockNode:getChildByFullName("goldValue"):setString(goldValue)
            unlockNode:setVisible(true)
            local suo = unlockNode:getChildByFullName("suo")
            self:registerClickEvent(suo, function (  )
                self:unlockSpecialSkill()
            end)
        else
            if self._selectSkillId == self._usedSkillId then
                already_img:setVisible(true)
            else
                btn_save:setVisible(true)
                self:registerClickEvent(btn_save, function (  )
                    self:switchSpecialSkill()
                end)
            end
        end
    end
end

function TeamSpecialSkillSwitchDialog:switchSpecialSkill(  )
    self._serverMgr:sendMsg("TeamServer", "switchSpecialSkill", {ssId = self._selectSkillId, teamId = self._teamId}, true, {}, function ( result )
        self._usedSkillId = self._selectSkillId
        self:moveSkill()
        self:updateInfo()
    end)
    
end

function TeamSpecialSkillSwitchDialog:unlockSpecialSkill(  )
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local goldValue = tab:Setting("G_TEAMSKILL_UNLOCK").value[self._selectSkillId] or 0
    
    if userData.gold >= goldValue then
        local param = {teamId = self._teamId, positionId = 5}
        self._serverMgr:sendMsg("TeamServer", "openSkill", param, true, {}, function (result)
            self._teamData = self._teamModel:getTeamAndIndexById(self._teamId)
            self:updateInfo()
        end)
    else
        DialogUtils.showLackRes({goalType = "gold"})
    end
end

function TeamSpecialSkillSwitchDialog:addSkill(  )
	for i = 5, 6 do
        local iconBg = self._skillIconBg[i]
        local sysSkill = self._skillData[i]
        local param = {teamSkill = sysSkill, eventStyle = 0, level = self._teamData["sl" .. i], levelLab = false, teamData = self._teamData}
        local skillIcon = IconUtils:createTeamSkillIconById(param)
        skillIcon:setPosition(cc.p(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2))
        skillIcon:setAnchorPoint(cc.p(0.5,0.5))
        skillIcon:setName("skillIcon")
        iconBg:addChild(skillIcon)

        local posIcon = self._skillIconPos[i]
        iconBg:setPosition(posIcon:getPosition())

        local xuanzhong = iconBg:getChildByFullName("xuanzhong")
        if xuanzhong == nil then
            xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
            xuanzhong:setName("xuanzhong")
            xuanzhong:gotoAndStop(1)
            xuanzhong:setPosition(iconBg:getContentSize().width * 0.5, iconBg:getContentSize().height * 0.5 + 1)
            xuanzhong:setScale(0.85)
            xuanzhong:setVisible(false)
            iconBg:addChild(xuanzhong,0)
        end
        if self._selectSkillId == i then
            xuanzhong:setVisible(true)
        else
            xuanzhong:setVisible(false)
        end

        self:registerClickEvent(iconBg, function()
            if self._selectSkillId ~= i then
                self._selectSkillId = i
                for i = 5, 6 do
                    local iconBg = self._skillIconBg[i]
                    local xuanzhong = iconBg:getChildByFullName("xuanzhong")
                    if self._selectSkillId == i then
                        xuanzhong:setVisible(true)
                    else
                        xuanzhong:setVisible(false)
                    end
                end
                self:updateInfo()
            end
        end)
    end
    self:moveSkill(true)
end

function TeamSpecialSkillSwitchDialog:moveSkill( noAnim )
    if not self._usedSkillId then
        return
    end
    for i = 5, 6 do
        local icon = self._skillIconBg[i]
        local posIcon = self._skillIconPos[i]
        if self._usedSkillId == i then
            if self._usedIconBg:getPosition() ~= icon:getPosition() then
                if noAnim then
                    icon:setPosition(self._usedIconBg:getPosition())
                else
                    icon:runAction(cc.MoveTo:create(0.2, cc.p(self._usedIconBg:getPosition())))
                end
            end
        else
            if posIcon:getPosition() ~= icon:getPosition() then
                if noAnim then
                    icon:setPosition(posIcon:getPosition())
                else
                    icon:runAction(cc.MoveTo:create(0.2, cc.p(posIcon:getPosition())))
                end
            end
        end
    end
    if not self._usedIconBg:getChildByFullName("specialAnim") then
        local mc = mcMgr:createViewMC("bintuanbianhongtexiao_bingtuanbianhong", true, false)
        mc:setName("specialAnim")
        mc:setPosition(self._usedIconBg:getContentSize().width / 2, self._usedIconBg:getContentSize().height / 2 - 10)
        self._usedIconBg:addChild(mc)
    end
end

return TeamSpecialSkillSwitchDialog