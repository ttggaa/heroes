--[[
    Filename:    NewFormationDescriptionView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-03-04 10:49:48
    Description: File description
--]]


local tab = tab
local lang = lang
local SkillUtils = SkillUtils

local FormationIconView = require("game.view.formation.FormationIconView")
local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local NewFormationDescriptionView = class("NewFormationDescriptionView", BasePopView)

NewFormationDescriptionView.kIconTag = 1000

NewFormationDescriptionView.kTeamScale = 0.75
NewFormationDescriptionView.kHeroScale = 0.75


function NewFormationDescriptionView:ctor(params)
    NewFormationDescriptionView.super.ctor(self)
    self._iconType = params.iconType
    self._iconId = params.iconId
    self._iconSubtype = params.iconSubtype
    self._isChanged = params.isChanged
    self._changedId = params.changedId
    self._formationType = params.formationType
    self._purgatoryId = params.purgatoryId
    print("self._iconType",self._iconType)
    self._isCustom = params.isCustom
    self._isLocal = params.isLocal
    self._isShowOriginScore = params.isShowOriginScore
    self._isShowSkillUnlockEffect = params.isShowSkillUnlockEffect
    self._closeCallback = params.closeCallback

    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._heroDuelModel = self._modelMgr:getModel("HeroDuelModel")
    --self._crusadeModel = self._modelMgr:getModel("CrusadeModel")
    --self._arenaModel = self._modelMgr:getModel("ArenaModel")
    --self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._crossModel = self._modelMgr:getModel("CrossModel")

    self:checkIsHaveSpellSkill()

    self._formationToBattleType = {}
    self._formationToBattleType[self._formationModel.kFormationTypeLeague] = 13 --积分联赛
    self._formationToBattleType[self._formationModel.kFormationTypeHeroDuel] = 21 --英雄交锋
end

--[[
    检测是否有刻印技能
]]
function NewFormationDescriptionView:checkIsHaveSpellSkill()
    self._isHaveSpell = false -- 是否英雄有刻印技能
    local heroData
    if self._iconType == NewFormationIconView.kIconTypeCrusadeHero then
        heroData = self._modelMgr:getModel("CrusadeModel"):getEnemyHeroData()
    elseif self._iconType == NewFormationIconView.kIconTypeArenaHero then
        heroData = self._modelMgr:getModel("ArenaModel"):getEnemyHeroData(self._iconId)
    elseif self._iconType == NewFormationIconView.kIconTypeGuildHero then
        heroData = self._modelMgr:getModel("GuildMapModel"):getEnemyHeroData(self._iconId)
    elseif self._iconType == NewFormationIconView.kIconTypeMFHero then
        heroData = self._modelMgr:getModel("MFModel"):getEnemyHeroData(self._iconId)
    elseif self._iconType == NewFormationIconView.kIconTypeLocalHero 
        or self._iconType == NewFormationIconView.kIconTypeHero and self._isLocal then
            self._isHaveSpell = false
            return
    elseif self._iconType == NewFormationIconView.kIconTypeCrossPKHero then
        heroData = self._crossModel:getEnemyHeroData(self._iconId)
    else
        if self._iconId and not self._isCustom then 
            heroData = self._heroModel:getData()[tostring(self._iconId)]
        end
    end
    if heroData then
        if heroData and heroData.slot and heroData.slot.sid then
            local id = tonumber(heroData.slot.sid)
            if id > 0 then
                self._isHaveSpell = true
                self._spellId = id
            end
        end
    end
end

function NewFormationDescriptionView:onDestroy()
    local tc = cc.Director:getInstance():getTextureCache()
    if self._steamFileName then tc:removeTextureForKey(self._steamFileName) end
    if self._sheroFileName then tc:removeTextureForKey(self._sheroFileName) end
    NewFormationDescriptionView.super.onDestroy(self)
end

function NewFormationDescriptionView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
        element:setFontName(UIUtils.ttfName)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

function NewFormationDescriptionView:onInit()

    self:disableTextEffect()
    self._scheduler = cc.Director:getInstance():getScheduler()

    self._title = self:getUI("bg.layer.titleImg.titleTxt")
    UIUtils:setTitleFormat(self._title, 1)

    -- -- 新逻辑by guojun 
    --  UIUtils:createShowCGBtn( self ,{id=self._iconId,isTeam=true,pos = cc.p(380,480)} )

    -- team
    self._team = {}
    self._team._layer = self:getUI("bg.layer.layer_team")
    self._team._layerClass = self:getUI("bg.layer.layer_team.layer_left.image_info_bg.layer_class")    
    self._team._layerClass:setAnchorPoint(0.5,0.5)
    self._team._layerClass:setScaleAnim(true)
    self._team._layerClass:setPosition(28,22)
    self._team._labelName = self:getUI("bg.layer.layer_team.layer_left.image_info_bg.label_name")
    self._team._labelName:setFontName(UIUtils.ttfName)
    self._team._labelName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local label_title = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_title")
    UIUtils:setTitleFormat(label_title, 3)
    local label_title1 = self:getUI("bg.layer.layer_team.layer_right.team_info_2.label_title")
    UIUtils:setTitleFormat(label_title1, 3)

    self._team._star = {}
    for i = 1, 6 do
        self._team._star[i] = {}
        self._team._star[i]._normal = self:getUI("bg.layer.layer_team.layer_left.image_info_bg.layer_star.star_n_" .. i)
        self._team._star[i]._disable = self:getUI("bg.layer.layer_team.layer_left.image_info_bg.layer_star.star_d_" .. i)
    end
    self._team._layerBody = self:getUI("bg.layer.layer_team.layer_left.layer_body")
    self._team._labelFightScore = self:getUI("bg.layer.layer_team.layer_left.label_fight_score")
    -- self._team._labelFightScore:setScale(0.7)
    self._team._labelFightScore:setFntFile(UIUtils.bmfName_zhandouli_little)
    self._team._labelFightScore:setScale(0.6)

    self._team._labelLocked = self:getUI("bg.layer.layer_team.layer_left.label_locked")
    -- self._team._labelLocked:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._team._labelGroupDes = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_group_des")
    self._team._labelNumDes = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_num_des")
    self._team._labelZiZhiDes = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_zizhi_des")
    self._team._labelLocationDes = self:getUI("bg.layer.layer_team.layer_right.team_info_1.label_location_des")
    self._team._labelLocationDes:setTextAreaSize(cc.size(264,60))
    self._team._skill = {}
    for i = 1, 4 do
        self._team._skill[i] = {}
        self._team._skill[i]._icon = self:getUI("bg.layer.layer_team.layer_right.team_info_2.layer_skill_icon_" .. i)
        self._team._skill[i]._name = self:getUI("bg.layer.layer_team.layer_right.team_info_2.layer_skill_icon_" .. i .. ".label_skill_name")
        self._team._skill[i]._name:setFontName(UIUtils.ttfName)
        self._team._skill[i]._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        -- self._team._skill[i]._name:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
        self._team._skill[i]._level = self:getUI("bg.layer.layer_team.layer_right.team_info_2.layer_skill_icon_" .. i .. ".label_skill_level")
        self._team._skill[i]._locked = self:getUI("bg.layer.layer_team.layer_right.team_info_2.layer_skill_icon_" .. i .. ".image_skill_locked")
    end

    -- hero
    self._hero = {}
    self._hero._layer = self:getUI("bg.layer.layer_hero")
    self._hero._layerClass = self:getUI("bg.layer.layer_hero.layer_left.image_info_bg.layer_class")
    self._hero._layerClass:setScale(0.7)
    self._hero._layerClass:setAnchorPoint(0.5,0.5)
    self._hero._layerClass:setScaleAnim(true)
    self._hero._layerClass:setPosition(28,22)
    self._hero._labelName = self:getUI("bg.layer.layer_hero.layer_left.image_info_bg.label_name")
    self._hero._labelName:setFontName(UIUtils.ttfName)
    self._hero._labelName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local label_titleHero = self:getUI("bg.layer.layer_hero.layer_right.team_info_1.label_title")
    UIUtils:setTitleFormat(label_titleHero, 3)
    local label_title1Hero = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.label_title")
    UIUtils:setTitleFormat(label_title1Hero, 3)
    local label_title2Hero = self:getUI("bg.layer.layer_hero.layer_right.team_info_keyin.label_title")
    UIUtils:setTitleFormat(label_title2Hero, 3)

    self._hero._star = {}
    for i = 1, 4 do
        self._hero._star[i] = {}
        self._hero._star[i]._normal = self:getUI("bg.layer.layer_hero.layer_left.image_info_bg.layer_star.star_n_" .. i)
        self._hero._star[i]._disable = self:getUI("bg.layer.layer_hero.layer_left.image_info_bg.layer_star.star_d_" .. i)
    end
    self._hero._layerBody = self:getUI("bg.layer.layer_hero.layer_left.layer_body")

    self._hero._layerSpecialtyParent = self:getUI("bg.layer.layer_hero.layer_right.team_info_1.image_specialty_parent")
    self._hero._layerSpecialtyParent:setScaleAnim(true)
    self._hero._layerSpecialty = self:getUI("bg.layer.layer_hero.layer_right.team_info_1.image_specialty_parent.layer_specialty")
    self._hero._layerSpecialty:setSwallowTouches(false)
    self._hero._labelSpecialtyName = self:getUI("bg.layer.layer_hero.layer_right.team_info_1.image_specialty_parent.label_specialty_name")
    -- self._hero._labelSpecialtyName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._hero._labelSpecialtyName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._hero._layerSpecialtyStar = self:getUI("bg.layer.layer_hero.layer_right.team_info_1.image_specialty_parent.specialty_star")

    self._hero._skill = {}
    if self._isHaveSpell then
        for i = 1, 5 do
            self._hero._skill[i] = {}
            self._hero._skill[i]._icon = self:getUI("bg.layer.layer_hero.layer_right.team_info_keyin.layer_skill_icon_" .. i)
            local name = self:getUI("bg.layer.layer_hero.layer_right.team_info_keyin.layer_skill_icon_" .. i .. ".label_skill_name")
            self._hero._skill[i]._name = name
            name:setFontSize(16)
            self._hero._skill[i]._name:setFontName(UIUtils.ttfName)
            local level = self:getUI("bg.layer.layer_hero.layer_right.team_info_keyin.layer_skill_icon_" .. i .. ".label_skill_level")
            self._hero._skill[i]._level = level
            level:setFontSize(16)
        end
        self:getUI("bg.layer.layer_hero.layer_right.team_info_keyin"):setVisible(true)
        self:getUI("bg.layer.layer_hero.layer_right.team_info_2"):setVisible(false)
    else
        for i = 1, 5 do
            self._hero._skill[i] = {}
            self._hero._skill[i]._icon = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.layer_skill_icon_" .. i)
            local name = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.layer_skill_icon_" .. i .. ".label_skill_name")
            self._hero._skill[i]._name = name
            name:setFontName(UIUtils.ttfName)
            -- self._hero._skill[i]._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            -- self._hero._skill[i]._name:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
            local level = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.layer_skill_icon_" .. i .. ".label_skill_level")
            self._hero._skill[i]._level = level
        end
        self:getUI("bg.layer.layer_hero.layer_right.team_info_keyin"):setVisible(false)
        self:getUI("bg.layer.layer_hero.layer_right.team_info_2"):setVisible(true)
    end
    

    self._hero._mastery = {}
    self._hero._mastery._ui = self:getUI("bg.layer.layer_hero.layer_left.layer_mastery")
    self._hero._mastery._ui:setVisible(false)
    for i = 1, 4 do
        self._hero._mastery[i] = {}
        self._hero._mastery[i]._icon = self:getUI("bg.layer.layer_hero.layer_left.layer_mastery.mastery" .. i)
        self._hero._mastery[i]._level = self:getUI("bg.layer.layer_hero.layer_left.layer_mastery.mastery" .. i .. ".level")
    end

    self._updateFunctionMap = {
        -- left
        [NewFormationIconView.kIconTypeTeam] = handler(self, self.updateTeamInformation),
        [NewFormationIconView.kIconTypeHero] = handler(self, self.updateHeroInformation),
        [NewFormationIconView.kIconTypeHireTeam] = handler(self, self.updateHireTeamInformation),
        -- right
        [NewFormationIconView.kIconTypeInstanceTeam] = handler(self, self.updateInstanceTeamInformation),
        [NewFormationIconView.kIconTypeInstanceHero] = handler(self, self.updateInstanceHeroInformation),
        [NewFormationIconView.kIconTypeArenaTeam] = handler(self, self.updateArenaTeamInformation),
        [NewFormationIconView.kIconTypeArenaHero] = handler(self, self.updateArenaHeroInformation),
        [NewFormationIconView.kIconTypeAiRenMuWuTeam] = handler(self, self.updateAiRenMuWuTeamInformation),
        [NewFormationIconView.kIconTypeAiRenMuWuHero] = handler(self, self.updateAiRenMuWuHeroInformation),
        [NewFormationIconView.kIconTypeZombieTeam] = handler(self, self.updateZombieTeamInformation),
        [NewFormationIconView.kIconTypeZombieHero] = handler(self, self.updateZombieHeroInformation),
        [NewFormationIconView.kIconTypeDragonTeam] = handler(self, self.updateDragonTeamInformation),
        [NewFormationIconView.kIconTypeDragonHero] = handler(self, self.updateDragonHeroInformation),
        [NewFormationIconView.kIconTypeCrusadeTeam] = handler(self, self.updateCrusadeTeamInformation),
        [NewFormationIconView.kIconTypeCrusadeHero] = handler(self, self.updateCrusadeHeroInformation),
        [NewFormationIconView.kIconTypeLocalTeam] = handler(self, self.updateLocalTeamInformation),
        [NewFormationIconView.kIconTypeLocalHero] = handler(self, self.updateLocalHeroInformation),
        [NewFormationIconView.kIconTypeGuildTeam] = handler(self, self.updateGuildTeamInformation),
        [NewFormationIconView.kIconTypeGuildHero] = handler(self, self.updateGuildHeroInformation),
        [NewFormationIconView.kIconTypeMFTeam] = handler(self, self.updateMFTeamInformation),
        [NewFormationIconView.kIconTypeMFHero] = handler(self, self.updateMFHeroInformation),
        [NewFormationIconView.kIconTypeCloudTeam] = handler(self, self.updateNpcTeamInformation),
        [NewFormationIconView.kIconTypeCloudHero] = handler(self, self.updateNpcHeroInformation),
        [NewFormationIconView.kIconTypeAdventureTeam] = handler(self, self.updateAdventureTeamInformation),
        [NewFormationIconView.kIconTypeAdventureHero] = handler(self, self.updateAdventureHeroInformation),
        [NewFormationIconView.kIconTypeTrainingTeam] = handler(self, self.updateNpcTeamInformation),
        [NewFormationIconView.kIconTypeTrainingHero] = handler(self, self.updateNpcHeroInformation),
        [NewFormationIconView.kIconTypeElementalTeam] = handler(self, self.updateElementalTeamInformation),
        [NewFormationIconView.kIconTypeElementalHero] = handler(self, self.updateElementalHeroInformation),
        [NewFormationIconView.kIconTypeWeaponTeam] = handler(self, self.updateNpcTeamInformation),
        [NewFormationIconView.kIconTypeWeaponHero] = handler(self, self.updateNpcHeroInformation),
        [NewFormationIconView.kIconTypeCrossPKTeam] = handler(self, self.updateCrossPKTeamInformation),
        [NewFormationIconView.kIconTypeCrossPKHero] = handler(self, self.updateCrossPKHeroInformation),
        [NewFormationIconView.kIconTypeClimbTowerTeam] = handler(self, self.updateClimbTowerTeamInformation),
        [NewFormationIconView.kIconTypeClimbTowerHero] = handler(self, self.updateClimbTowerHeroInformation),
        [1000] = handler(self, self.update1000TeamInformation),
    }

    self:updateInformation()

    self:registerClickEventByName("bg.layer.btn_close", function()
        if self._closeCallback and type(self._closeCallback) == "function" then
            self._closeCallback()
        end
        self:close()
        UIUtils:reloadLuaFile("formation.NewFormationDescriptionView")
    end)
end

function NewFormationDescriptionView:showSpecialtyTip(node, heroData)
    self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = heroData.special, heroData = clone(heroData),isNpc = self._isCustom})
end

function NewFormationDescriptionView:onIconPressOn(node, iconId, heroData,skillIndex)
    local skillLevel = skillIndex == 5 and heroData.slot and heroData.slot.sLvl or nil
    local sklevel = skillIndex == 5 and heroData.slot and heroData.slot.s or nil
    local isSlotMastery = false
    if skillIndex == 5 then
        local heroDataC = clone(heroData)
        local sid = heroDataC.slot and heroDataC.slot.sid and tonumber(heroDataC.slot.sid)
        isSlotMastery = tab.heroMastery[tonumber(sid) or 0]
        if sid and sid ~= 0 then
            local bookId = tonumber(sid)
            local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(bookId)]
            if isSlotMastery and bookInfo then
                if tonumber(bookInfo.l) > 1 then
                    iconId = tonumber(iconId .. (bookInfo.l-1))
                end
            end
            if bookInfo then
                heroDataC.skillex = {heroDataC.slot.sid, heroDataC.slot.s, bookInfo.l}
            end
        end
        local attributeValues = BattleUtils.getHeroAttributes(heroDataC)
        for k,v in pairs(attributeValues.skills) do
            local sid1 = v[1]
            if iconId == sid1 and v[2] then
                sklevel = v[2]
                skillLevel = v[3]
                break
            end
        end
    end
    local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
    self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = iconId,skillLevel = skillLevel,sklevel=sklevel, heroData = not isSlotMastery and clone(heroData),isNpc = self._isCustom, posCenter = true, battleType = self._formationToBattleType[self._formationType], spTalent = spTalent})
end

function NewFormationDescriptionView:onIconPressOff()
    -- self:closeHintView()
end

function NewFormationDescriptionView:startClock(node, iconId, heroData,index)
    if self._timer_id then self:endClock() end
    self._first_tick = true
    -- self._timer_id = self._scheduler:scheduleScriptFunc(function()
    --     if not self._first_tick then return end
    --     self._first_tick = false
    self:onIconPressOn(node, iconId, heroData,index)
    -- end, 0.2, false)
end

function NewFormationDescriptionView:endClock()
   if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
    -- self:onIconPressOff()
end

function NewFormationDescriptionView:updateInformation()
    if not self._iconType then return end
    local updateFunction = self._updateFunctionMap[self._iconType]
    if updateFunction and type(updateFunction) == "function" then
        updateFunction()
    end
    -- 新逻辑by guojun 
    -- print("self._iconType,", self._iconType ,  NewFormationIconView.kIconTypeTeam )
    if self._iconType ==  NewFormationIconView.kIconTypeTeam 
        or self._iconType ==  NewFormationIconView.kIconTypeLocalTeam then
        UIUtils:createShowCGBtn( self:getUI("bg.layer.layer_team") ,{id=self._iconId,isTeam=true,pos = cc.p(250,405)} )
    end

end

function NewFormationDescriptionView:updateTeamInformation()
    -- print("NewFormationDescriptionView:updateTeamInformation")
    if self._isCustom then
        return self:updateNpcTeamInformation()
    end

    if self._isLocal then
        return self:updateLocalTeamInformation()
    end

    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamData = self._teamModel:getTeamAndIndexById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    local teamOwnSkillData = teamTableData.skill

    --   名字、头像、立汇、小人、动画小人
    --   teamName, art1, art2, art3 ,art4
    local isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
    local teamName = teamTableData.name
    local steam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
    local useless1 = nil
    local useless2 = nil
    if isAwaking then
        teamName, useless1, useless2, steam = TeamUtils:getTeamAwakingTab(teamData,self._changedId)
    end

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end

    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    
    -- print("offsetX , offsetY ===========",offsetX , offsetY )
    self._steamFileName = "asset/uiother/steam/".. steam ..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

     --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end

    self._team._labelFightScore:setVisible(true)
    if not self._isShowOriginScore then
        self._team._labelFightScore:setString("a" .. teamData.score)
    else
        self._team._labelFightScore:setString("a" .. (teamData.score - teamData.pScore))
    end

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))

    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    local teamSkillData = clone(teamData)
    teamSkillData.teamId = teamTableData.id
    local rune = teamData.rune
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamData["sl" .. i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)

        local uSkill = false    -- 是否大招技能加成
        local sSkill = false    -- 是否普通技能加成
        local addLevel = 0      -- 额外增加等级
        if rune and rune.suit and rune.suit["4"] then
            local id,level = TeamUtils:getRuneIdAndLv(rune.suit["4"])
            if id == 104 then
                sSkill = true
                uSkill = true
            end
            if i == 1 then
                if id == 403 then
                    uSkill = true 
                end
            end
            addLevel = level
        end
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamSkillData, level = skillLevel,addLevel=addLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))

        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)        
        labelLevel:setString("Lv." .. skillLevel)
        if skillLevel > 0 and addLevel > 0 and ((uSkill and i == 1) or (sSkill and i ~= 1)) then
            local addTxt = ccui.Text:create()
            addTxt:setFontName(UIUtils.ttfName)
            addTxt:setFontSize(22)
            addTxt:setAnchorPoint(0,0.5)
            addTxt:setString("(+" .. addLevel ..")")
            addTxt:setColor(UIUtils.colorTable.ccUIBaseColor9)
            addTxt:setPosition(labelLevel:getPositionX()+labelLevel:getContentSize().width,labelLevel:getPositionY())
            labelLevel:getParent():addChild(addTxt,2)
        end

        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateHireTeamInformation()
    -- print("NewFormationDescriptionView:updateHireTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamData = clone(self._guildModel:getEnemyDataById(self._iconId, self._iconSubtype))
    if not teamData then
        teamData = self._teamModel:getTeamAndIndexById(self._iconId)
    end 
    teamData.teamId = self._iconId
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    local teamOwnSkillData = teamTableData.skill

    --   名字、头像、立汇、小人、动画小人
    --   teamName, art1, art2, art3 ,art4
    local isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
    local teamName = teamTableData.name
    local steam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
    local useless1 = nil
    local useless2 = nil
    if isAwaking then
        teamName, useless1, useless2, steam = TeamUtils:getTeamAwakingTab(teamData,self._changedId)
    end

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end

    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    
    -- print("offsetX , offsetY ===========",offsetX , offsetY )
    self._steamFileName = "asset/uiother/steam/".. steam ..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

     --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end


    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. (teamData.score - teamData.pScore))

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))

    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    local teamSkillData = clone(teamData)
    teamSkillData.teamId = teamTableData.id
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamData["sl" .. i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamSkillData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)

        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateInstanceTeamInformation()
    --print("NewFormationDescriptionView:updateInstanceTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = clone(tab:Npc(self._iconId))
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Npc(self._changedId)
    end
    ]]
    local teamOwnSkillData = TeamUtils.getNpcTableValueByTeam(teamTableData, "skill")

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    local isAwaking, awakingLvl = 1 == teamTableData.jx, teamTableData.jxLv
    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamTableData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end

    if isAwaking then
        teamTableData.ast = 3
        teamTableData.aLvl = awakingLvl
        teamTableData.tree = {
            b1 = teamTableData.jxSkill1, 
            b2 = teamTableData.jxSkill2, 
            b3 = teamTableData.jxSkill3
        }
        teamTableData.npcId = self._iconId
        teamTableData.teamId = self._iconId
    end

    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end

    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi or 0)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamTableData.sl[i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateArenaTeamInformation()
    --print("NewFormationDescriptionView:updateTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamData = self._modelMgr:getModel("ArenaModel"):getEnemyDataById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = teamTableData.skill

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        if i <= teamData.star then
            self._team._star[i]._normal:setVisible(true)
        else
            self._team._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end

    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamData["sl" .. i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateAiRenMuWuTeamInformation()
    --print("NewFormationDescriptionView:updateInstanceTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = TeamUtils.getNpcTableValueByTeam(teamTableData, "skill")

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        if i <= teamTableData.star then
            self._team._star[i]._normal:setVisible(true)
        else
            self._team._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamTableData.sl[i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateZombieTeamInformation()
    --print("NewFormationDescriptionView:updateInstanceTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = TeamUtils.getNpcTableValueByTeam(teamTableData, "skill")

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        if i <= teamTableData.star then
            self._team._star[i]._normal:setVisible(true)
        else
            self._team._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamTableData.sl[i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateDragonTeamInformation()
    --print("NewFormationDescriptionView:updateInstanceTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = TeamUtils.getNpcTableValueByTeam(teamTableData, "skill")

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        if i <= teamTableData.star then
            self._team._star[i]._normal:setVisible(true)
        else
            self._team._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))

    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamTableData.sl[i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateCrusadeTeamInformation()
    --print("NewFormationDescriptionView:updateTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamData = self._modelMgr:getModel("CrusadeModel"):getEnemyTeamDataById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    local teamOwnSkillData = teamTableData.skill

    --   名字、头像、立汇、小人、动画小人
    --   teamName, art1, art2, art3 ,art4
    local isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
    local teamName = teamTableData.name
    local steam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
    local useless1 = nil
    local useless2 = nil
    if isAwaking then
        teamName, useless1, useless2, steam = TeamUtils:getTeamAwakingTab(teamData,self._changedId)
    end

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))
    
    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/".. steam ..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))

    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamData["sl" .. i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateLocalTeamInformation()
    --print("NewFormationDescriptionView:updateLocalTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = tab:Team(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = teamTableData.skill

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        if i <= teamTableData.starlevel then
            self._team._star[i]._normal:setVisible(true)
        else
            self._team._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(false)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(true)
    self._team._labelLocked:setString(self._teamModel:getTeamAndIndexById(self._iconId) and "已获得" or "未获得")
    self._team._labelLocked:setColor(self._teamModel:getTeamAndIndexById(self._iconId) and cc.c3b(28, 162, 22) or cc.c3b(120, 120, 120))

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = 0
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateGuildTeamInformation()
    --print("NewFormationDescriptionView:updateGuildTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamData = self._modelMgr:getModel("GuildMapModel"):getEnemyDataById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = teamTableData.skill
    --   名字、头像、立汇、小人、动画小人
    --   teamName, art1, art2, art3 ,art4
    local isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
    local teamName = teamTableData.name
    local steam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
    local useless1 = nil
    local useless2 = nil
    if isAwaking then
        teamName, useless1, useless2, steam = TeamUtils:getTeamAwakingTab(teamData,self._changedId)
    end
    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end

    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/".. steam ..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamData["sl" .. i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateMFTeamInformation()
    --print("NewFormationDescriptionView:updateMFTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamData = self._modelMgr:getModel("MFModel"):getEnemyDataById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = teamTableData.skill

    --   名字、头像、立汇、小人、动画小人
    --   teamName, art1, art2, art3 ,art4
    local isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
    local teamName = teamTableData.name
    local steam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
    local useless1 = nil
    local useless2 = nil
    if isAwaking then
        teamName, useless1, useless2, steam = TeamUtils:getTeamAwakingTab(teamData,self._changedId)
    end

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/".. steam ..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamData["sl" .. i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:update1000TeamInformation()
    --print("NewFormationDescriptionView:updateLocalTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = tab:Team(self._iconId)
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = teamTableData.skill

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        if i <= 3 then
            self._team._star[i]._normal:setVisible(true)
        else
            self._team._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(false)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(false)
    --self._team._labelLocked:setString(self._teamModel:getTeamAndIndexById(self._iconId) and "已获得" or "未获得")
    --self._team._labelLocked:setColor(self._teamModel:getTeamAndIndexById(self._iconId) and cc.c3b(28, 162, 22) or cc.c3b(120, 120, 120))

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = 0
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateNpcTeamInformation()
    --print("NewFormationDescriptionView:updateNpcTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = nil
    local isAwaking, awakingLvl = false, 0
    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        teamTableData = clone(tab:Team(self._iconId))
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        local awakingData = tab:HeroDuejx(self._iconId)
        if heroDuelTableData then
            teamTableData.star = heroDuelTableData.teamstar
            teamTableData.stage = heroDuelTableData.teamquality
            teamTableData.sl = {}
            for i = 1, 4 do
                teamTableData.sl[i] = heroDuelTableData.teamskill[i]
            end
        end

        if awakingData then
            teamTableData.ast = 3
            teamTableData.aLvl = awakingData.aLvl
            isAwaking = true
            awakingLvl = awakingData.aLvl
            teamTableData.tree = {b1 = awakingData.talentTree1, b2 = awakingData.talentTree2, b3 = awakingData.talentTree3}
            teamTableData.teamId = self._iconId
        end
    else
        teamTableData = clone(tab:Npc(self._iconId))
        isAwaking, awakingLvl = 1 == teamTableData.jx, teamTableData.jxLv
        if isAwaking then
            teamTableData.ast = 3
            teamTableData.aLvl = awakingLvl
            teamTableData.tree = {
                b1 = teamTableData.jxSkill1, 
                b2 = teamTableData.jxSkill2, 
                b3 = teamTableData.jxSkill3
            }
            teamTableData.npcId = self._iconId
            teamTableData.teamId = self._iconId
        end
    end
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = TeamUtils.getNpcTableValueByTeam(teamTableData, "skill")

    local teamName = teamTableData.name
    local steam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
    local useless1 = nil
    local useless2 = nil
    if isAwaking and self._formationType == self._formationModel.kFormationTypeHeroDuel --[[and not self._isChanged]] then
        teamName, useless1, useless2, steam = TeamUtils:getTeamAwakingTab(teamTableData, self._iconId)
    end

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamTableData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end

    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/" .. steam .. ".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(self._formationType ~= self._formationModel.kFormationTypeHeroDuel)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamTableData.sl and teamTableData.sl[i] or 1     --skillLevel
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateElementalTeamInformation()
    --print("NewFormationDescriptionView:updateElementalTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = nil
    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        teamTableData = clone(tab:Team(self._iconId))
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        if heroDuelTableData then
            teamTableData.star = heroDuelTableData.teamstar
            teamTableData.stage = heroDuelTableData.teamquality
            teamTableData.sl = {}
            for i = 1, 4 do
                teamTableData.sl[i] = heroDuelTableData.teamskill[i]
            end
        end
    else
        teamTableData = tab:Npc(self._iconId)
    end
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = TeamUtils.getNpcTableValueByTeam(teamTableData, "skill")

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        if i <= teamTableData.star then
            self._team._star[i]._normal:setVisible(true)
        else
            self._team._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(self._formationType ~= self._formationModel.kFormationTypeHeroDuel)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamTableData.sl and teamTableData.sl[i] or 1     --skillLevel
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateAdventureTeamInformation()
    --print("NewFormationDescriptionView:updateAdventureTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamData = self._modelMgr:getModel("AdventureModel"):getEnemyDataById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = teamTableData.skill

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        if i <= teamData.star then
            self._team._star[i]._normal:setVisible(true)
        else
            self._team._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)
    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamData["sl" .. i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateCrossPKTeamInformation()
    --print("NewFormationDescriptionView:updateCrossPKTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamData = self._crossModel:getEnemyDataById(self._iconId)
    if not teamData then print("invalid team icon id", self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    --[[
    if self._isChanged then
        teamTableData = tab:Team(self._changedId)
    end
    ]]
    local teamOwnSkillData = teamTableData.skill

    --   名字、头像、立汇、小人、动画小人
    --   teamName, art1, art2, art3 ,art4
    local isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
    local teamName = teamTableData.name
    local steam = TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")
    local useless1 = nil
    local useless2 = nil
    if isAwaking then
        teamName, useless1, useless2, steam = TeamUtils:getTeamAwakingTab(teamData,self._changedId)
    end

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamName) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end
    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end

    self._steamFileName = "asset/uiother/steam/".. steam ..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end
    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamData["sl" .. i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamData, level = skillLevel, eventStyle = 1})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateClimbTowerTeamInformation()
    --print("NewFormationDescriptionView:updateInstanceTeamInformation")
    self._team._layer:setVisible(true)
    self._title:setString("兵团信息")
    self._hero._layer:setVisible(false)

    local teamTableData = clone(tab:Npc(self._iconId))
    if not teamTableData then print("invalid team icon id", self._iconId) end
    --[[
    if self._isChanged then
        teamTableData = tab:Npc(self._changedId)
    end
    ]]
    local teamOwnSkillData = TeamUtils.getNpcTableValueByTeam(teamTableData, "skill")

    self._team._layerClass:setBackGroundImage(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
    TeamUtils.showTeamLabelTip(self._team._layerClass, 7, teamTableData.id)

    -- 增加觉醒判断
    local stageId = self._modelMgr:getModel("PurgatoryModel"):getStageId()
    local cfg = tab.purFight[stageId]
    if cfg then
        teamTableData.jxLv = cfg.jxLv
        teamTableData.jxSkill1 = cfg.jxSkill1
        teamTableData.jxSkill2 = cfg.jxSkill2
        teamTableData.jxSkill3 = cfg.jxSkill3
        teamTableData.sl = cfg.teamskill
        teamTableData.stage = cfg.teamquality
        teamTableData.star = cfg.teamstar
        teamTableData.score = cfg.teamscore
    end
    local quality = self._teamModel:getTeamQualityByStage(teamTableData.stage)
    self._team._labelName:setColor(UIUtils.colorTable["ccColorQuality" .. quality[1]])
    self._team._labelName:setString(lang(teamTableData.name) .. (0 == quality[2] and "" or  "+" .. quality[2]))

    local isAwaking, awakingLvl = 1 == teamTableData.jx, teamTableData.jxLv or 0
    for i = 1, 6 do
        self._team._star[i]._disable:setVisible(false)
        local imgName = ""
        if i <= teamTableData.star then
            imgName = "globalImageUI6_star1.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar1.png"
            end
        else            
            imgName = "globalImageUI6_star2.png"
            if isAwaking and i <= awakingLvl then
                imgName = "globalImageUI_teamskillBigStar2.png"
            end
        end

        self._team._star[i]._normal:loadTexture(imgName,1)
    end

    if isAwaking then
        teamTableData.ast = 3
        teamTableData.aLvl = awakingLvl
        teamTableData.tree = {
            b1 = teamTableData.jxSkill1, 
            b2 = teamTableData.jxSkill2, 
            b3 = teamTableData.jxSkill3
        }
        teamTableData.npcId = self._iconId
        teamTableData.teamId = self._iconId
    end

    local offsetX , offsetY = 0,0
    if teamTableData.xiaoren then
        offsetX , offsetY  = tonumber(teamTableData.xiaoren[1]) ,tonumber(teamTableData.xiaoren[2])
    end
    self._steamFileName = "asset/uiother/steam/"..TeamUtils.getNpcTableValueByTeam(teamTableData, "steam")..".png"
    local teamBody = ccui.ImageView:create(self._steamFileName)
    teamBody:setAnchorPoint(cc.p(0.5, 0.1))
    --teamBody:setRotation3D(cc.Vertex3F(0, 180, 0))
    teamBody:setScale(NewFormationDescriptionView.kTeamScale)
    teamBody:setPosition(self._team._layerBody:getContentSize().width / 2+offsetX, self._team._layerBody:getContentSize().height / 4.5+offsetY)
    self._team._layerBody:addChild(teamBody)

    --  team  race$cs   data[1]   race表 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bg")
    local receData = teamTableData.race
    local race = tab:Race(receData[1]).pic
    image_body_bg:loadTexture("asset/uiother/race/race_" .. race ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_team.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        local filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
        if receData[1] then
            filePath = "asset/uiother/dizuo/teamBgDizuo" .. receData[1] .. ".png"
            if not cc.FileUtils:getInstance():isFileExist(filePath) then
                filePath = "asset/uiother/dizuo/teamBgDizuo101.png"
            end
        end
        image_body_bottom:loadTexture(filePath, 0)
    end

    self._team._labelFightScore:setVisible(true)
    self._team._labelFightScore:setString("a" .. teamTableData.score)

    self._team._labelLocked:setVisible(false)

    self._team._labelGroupDes:setString(lang(tab:Race(teamTableData.race[1]).name))
    self._team._labelNumDes:setString((6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")) * (6 - TeamUtils.getNpcTableValueByTeam(teamTableData, "volume")))
    self._team._labelZiZhiDes:setString(12 + teamTableData.zizhi or 0)
    self._team._labelLocationDes:setString(lang(teamTableData.dingwei))
    local dazhaoImg = self:getUI("bg.layer.layer_team.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(10)
    dazhaoImg:setVisible(false)
    local teamSkillS = nil -- 无尽地狱特殊的等级 用于计算技能战斗力 
    if self._purgatoryId then
        local cfg = tab.purFight[self._purgatoryId]
        teamSkillS = cfg["teamlvS"]
    end

    for i = 1, 4 do
        local iconParent = self._team._skill[i]._icon
        local labelName = self._team._skill[i]._name
        local labelLevel = self._team._skill[i]._level
        local imageLocked = self._team._skill[i]._locked
        local skillLevel = teamTableData.sl[i]
        local skillType = teamOwnSkillData[i][1]
        local skillId = teamOwnSkillData[i][2]
        local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = IconUtils:createTeamSkillIconById({teamSkill = skillTableData, teamData = teamTableData, level = skillLevel, eventStyle = 1,teamSkillS= teamSkillS--[[无尽炼狱特殊参数--]]})
        icon:setScale(0.8)
        icon:setPosition(cc.p(-5, -5))
        iconParent:addChild(icon)
        labelName:setString(lang(skillTableData.name))
        labelLevel:setVisible(skillLevel > 0)
        imageLocked:setVisible(skillLevel <= 0)
        labelLevel:setString("Lv." .. skillLevel)
        
        if skillTableData.dazhao and skillTableData.dazhao == 1 then 
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+18, iconParent:getPositionY()+64)         
        end
    end
end

function NewFormationDescriptionView:updateHeroInformation()
    -- print("NewFormationDescriptionView:updateHeroInformation")
    if self._isCustom then
        return self:updateNpcHeroInformation()
    end

    if self._isLocal then
        return self:updateLocalHeroInformation()
    end

    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    local heroData = clone(self._heroModel:getData()[tostring(self._iconId)])
    if not heroData then print("invalid hero icon id", self._iconId) end

    --添加战斗力
    if heroData then
        local heroScore = heroData.score or 0
        local heroFightScore = self._hero._layerBody:getChildByFullName("heroFightScore")
        if heroFightScore then
            heroFightScore:removeFromParent()
        end
        heroFightScore = ccui.TextBMFont:create("a" .. heroScore, UIUtils.bmfName_zhandouli)
        heroFightScore:setAnchorPoint(cc.p(0.5,1))
        heroFightScore:setScale(0.6)
        heroFightScore:setPosition(self._hero._layerBody:getContentSize().width/2, 0)
        heroFightScore:setName("heroFightScore")
        self._hero._layerBody:addChild(heroFightScore)
    end

    heroData.id = self._iconId
    local heroTableData = tab:Hero(heroData.id)
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroData.star and heroData.star >= 1 then
        if heroData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end

    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    local sHero = heroTableData.shero
    local heroSkinPort = nil -- 皮肤换立绘
    if heroData.skin then
        local skinTableData = tab:HeroSkin(tonumber(heroData.skin))
        sHero = skinTableData and skinTableData.shero or sHero
        heroSkinPort = skinTableData and skinTableData.heroport
    end
    self._sheroFileName = "asset/uiother/shero/"..sHero..".png"
    -- 增加展示立绘按钮
    UIUtils:createShowCGBtn( self:getUI("bg.layer.layer_hero") ,{id=self._iconId,isHero=true,heroSkinImgName = heroSkinPort,pos = cc.p(250,405)} )
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")
    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end
    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroData)
    heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroSpecialtyData)
    end)

    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))            
            index = math.min(index + 1, 2)
        end
    end
    ]]
    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]

    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")

    local attrData = BattleUtils.getHeroAttributes(clone(heroData))
    local skinAtt = self._heroModel:getHeroSkinAttr()
    local changeMap = {[1] = "atk",[2] = "def", [3]="int",[4] = "ack"}
    
    -- 全局英雄属性
    -- 1234 攻防智知
    for i=1,4 do
        if attrData[changeMap[i]] then
            attrData[changeMap[i]] = attrData[changeMap[i]] + skinAtt[changeMap[i]]
        else
            attrData[changeMap[i]] = skinAtt[changeMap[i]]
        end
    end

    for i=1,4 do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        if attrData[changeMap[i]] then
            attValue:setString(string.format("%.01f",attrData[changeMap[i]]))
        else
            -- print("=========heroDetail hAb===========",i)
            attValue:setString(0)
        end
    end

    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)

    local heroSkillAttributes = attrData.skills
    for i=1, 4 do
        heroData["sl" .. i] = heroSkillAttributes[i][2]
    end
    
    if self._isHaveSpell then
        print("aaaaaa")
        self:updateHeroSkillDetail2(heroTableData, heroData)
    else
        print("aaaaaab")
        self:updateHeroSkillDetail1(heroTableData, heroData)
    end    
    
end

--[[
更新英雄面板中，技能面板（无刻印技能）
@ heroTableData 英雄模板数据
@ heroData 英雄model数据
]]
function NewFormationDescriptionView:updateHeroSkillDetail1(heroTableData,heroData)
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    for i = 1, 4 do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i]._icon
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true)        
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX() + 7, iconBg:getPositionY() + 7)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type        
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        lableName:setString(lang(skillData.name))

        local level = heroData["sl" .. i] or heroData.slevel[i]
        labelLevel:setString(level .. "阶")

        -- if skillData.dazhao and skillData.dazhao == 1 then 
        if i == 4 then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
    end
end

--[[
更新英雄面板中，技能面板（有刻印技能）
@ heroTableData 英雄模板数据
@ heroData 英雄model数据
]]
function NewFormationDescriptionView:updateHeroSkillDetail2(heroTableData,heroData)
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_keyin.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(true)
    for i = 1, 5 do
        local skillId
        if i <= 4 then
            skillId = heroTableData.spell[i]
            local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
            if isReplaced then
                skillId = skillReplacedId
            end
        else
            skillId = self._spellId
            local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
            if isReplaced then
                skillId = skillReplacedId
            end
        end
        
        local skillData = tab:PlayerSkillEffect(skillId) or tab:HeroMastery(skillId)
        local iconParent = self._hero._skill[i]._icon
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true)        
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroData),i)
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png")
        icon:setScale(0.9)
        icon:setAnchorPoint(0.5,0.5)
        icon:setPosition(iconBg:getContentSize().width*0.5, iconBg:getContentSize().height*0.5)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type        
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        lableName:setString(lang(skillData.name))
        local level = 1
        if i <= 4 then
            level = heroData["sl" .. i] or heroData.slevel[i]
        else
            level = heroData.slot and heroData.slot.s
        end
        if not level then
            level = 1
        end
        if i == 5 then
            local heroDataC = clone(heroData)
            local sid = heroDataC.slot and heroDataC.slot.sid and tonumber(heroDataC.slot.sid)
            if sid and sid ~= 0 then
                local bookId = tonumber(sid)
                local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(bookId)]
                if bookInfo then
                    heroDataC.skillex = {heroDataC.slot.sid, heroDataC.slot.s, bookInfo.l}
                end
            end
            local attributeValues = BattleUtils.getHeroAttributes(heroDataC)
            for k,v in pairs(attributeValues.skills) do
                local sid1 = v[1]
                if skillId == sid1 and v[2] then
                    level = v[2]
                    break
                end
            end
        end
        labelLevel:setPositionX(lableName:getPositionX()+lableName:getContentSize().width)
        labelLevel:setString(level .. "阶")
    end
end


function NewFormationDescriptionView:updateInstanceHeroInformation()
    --[=[
    print("NewFormationDescriptionView:updateInstanceHeroInformation")
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")
    local heroTableData = clone(tab:NpcHero(self._iconId))
    
    self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png")
    self._hero._labelName:setString(lang(heroTableData.heroname))

    for i = 1, 5 do
        if i <= heroTableData.herostar then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end

    self._sheroFileName = "asset/uiother/shero/"..heroTableData.shero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2, self._hero._layerBody:getContentSize().height / 1.28)
    self._hero._layerBody:addChild(heroBody, 10)

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg")
    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]

    for i = 1, 5 do
        self._hero._skill[i]._icon:setVisible(false)
    end

    for i = 1, 4 do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        if not skillData then break end
        local iconParent = self._hero._skill[i]._icon
        iconParent:setVisible(true)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:create(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.8)
        icon:setPosition(iconParent:getContentSize().width / 2, iconParent:getContentSize().height / 2)
        iconParent:addChild(icon)
        local skillType = skillData.type
        local color = nil
        if skillType == 1  then
            color = cc.c3b(117, 73, 34)
        elseif skillType == 2 then
            color = cc.c3b(178, 46, 47)
        elseif skillType == 3 then
            color = cc.c3b(56, 72, 185)
        elseif skillType == 4 then
            color = cc.c3b(103, 154, 182)
        elseif skillType == 5 then
            color = cc.c3b(115, 145, 13)
        end
        lableName:setColor(color)
        lableName:setString(lang(skillData.name))
        labelLevel:setString(heroData["sl" .. i] .. "阶")
    end
    ]=]
end

function NewFormationDescriptionView:updateArenaHeroInformation()
    --print("NewFormationDescriptionView:updateArenaHeroInformation")
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    local heroData = self._modelMgr:getModel("ArenaModel"):getEnemyHeroData(self._iconId)
    if not heroData then print("invalid hero icon id", self._iconId) end
    heroData.id = self._iconId
    local heroTableData = tab:Hero(heroData.id)
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroData.star and heroData.star >= 1 then
        if heroData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    self._sheroFileName = "asset/uiother/shero/"..heroTableData.shero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroData)
    heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroSpecialtyData)
    end)

    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))
            
            index = math.min(index + 1, 2)
        end
    end
    ]]
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    
    -- 1234 攻防智知
    local attributes = {"atk", "def", "int", "ack"}
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    local i = 1
    for _, att in ipairs(attributes) do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        i = i + 1
        attValue:setString(0)
        if heroTableData[att] then            
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            attValue:setString(string.format("%d", value))
        end
    end

    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)
    --[[
    for i = 1, 4 do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i]._icon
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true)        
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX() + 7, iconBg:getPositionY() + 7)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        lableName:setString(lang(skillData.name))
        labelLevel:setString(heroData["sl" .. i] .. "阶")
        if i == 4 then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
    end
    --]]
    if self._isHaveSpell then
        self:updateHeroSkillDetail2(heroTableData, heroData)
    else
        self:updateHeroSkillDetail1(heroTableData, heroData)
    end 
end

function NewFormationDescriptionView:updateAiRenMuWuHeroInformation()

end

function NewFormationDescriptionView:updateZombieHeroInformation()

end

function NewFormationDescriptionView:updateDragonHeroInformation()

end

function NewFormationDescriptionView:updateCrusadeHeroInformation()
    -- print("NewFormationDescriptionView:updateCrusadeHeroInformation")
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    local heroData = self._modelMgr:getModel("CrusadeModel"):getEnemyHeroData()
    if not heroData then print("invalid hero icon id", self._iconId) end
    heroData.id = self._iconId


    local heroTableData = tab:Hero(heroData.id)
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroData.star and heroData.star >= 1 then
        if heroData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    local sHero = heroTableData.shero
    if heroData.skin then
        local skinTableData = tab:HeroSkin(tonumber(heroData.skin))
        sHero = skinTableData and skinTableData.shero or sHero
    end
    self._sheroFileName = "asset/uiother/shero/"..sHero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroData)
    heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroSpecialtyData)
    end)
    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))
            
            index = math.min(index + 1, 2)
        end
    end
    ]]

    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")

    -- 1234 攻防智知
    local attributes = {"atk", "def", "int", "ack"}
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    local i = 1
    for _, att in ipairs(attributes) do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        i = i + 1
        if heroTableData[att] then            
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            attValue:setString(string.format("%d", value))
        else
            attValue:setString(0)
        end
    end
    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)
    --[[
    for i = 1, 4 do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i]._icon
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true) 
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX() + 7, iconBg:getPositionY() + 7)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        
        lableName:setString(lang(skillData.name))
        labelLevel:setString(heroData.slevel[i] .. "阶")
        if i == 4 then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
    end
    -]]
    if self._isHaveSpell then
        self:updateHeroSkillDetail2(heroTableData, heroData)
    else
        self:updateHeroSkillDetail1(heroTableData, heroData)
    end 
end

function NewFormationDescriptionView:updateLocalHeroInformation()
    -- print("NewFormationDescriptionView:updateLocalHeroInformation")
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    -- 英雄详情提示 已获得未获得
    local heroData = clone(self._heroModel:getData()[tostring(self._iconId)])
    local tipTxt = self._hero._layerBody:getChildByFullName("tipTxt")
    if tipTxt then
        tipTxt:removeFromParent()
    end
    tipTxt = ccui.Text:create()
    tipTxt:setFontName(UIUtils.ttfName)
    tipTxt:setPosition(self._hero._layerBody:getContentSize().width/2, 0)
    tipTxt:setAnchorPoint(cc.p(0.5,1))
    tipTxt:setFontSize(24)
    -- tipTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._hero._layerBody:addChild(tipTxt,5)
    if not heroData then
        -- print("invalid hero icon id", self._iconId) 
        tipTxt:setString("未获得")
        tipTxt:setColor(cc.c3b(120, 120, 120))
    else
        tipTxt:setString("已获得")
        tipTxt:setColor(cc.c3b(28, 162, 22))
    end

    local heroTableData = clone(tab:Hero(self._iconId))
    if heroData then
        heroTableData.star = heroData.star
    end
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroTableData.star and heroTableData.star >= 1 then
        if heroTableData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroTableData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroTableData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroTableData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    self._sheroFileName = "asset/uiother/shero/"..heroTableData.shero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroTableData)
    end)
    
    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))
           
            index = math.min(index + 1, 2)
        end
    end
    ]]
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    
    -- 1234 攻防智知
    local attributes = {"atk", "def", "int", "ack"}
    local star = heroData and heroData.star
    if not star then
        star = heroTableData and heroTableData.star or 1
    end
    local i = 1
    for _, att in ipairs(attributes) do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        i = i + 1
        if heroTableData[att] then            
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            attValue:setString(string.format("%d", value))
        else
            attValue:setString(0)
        end
    end

    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)
    
    for i = 1, 4 do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i]._icon
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true) 
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroTableData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX() + 7, iconBg:getPositionY() + 7)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        
        lableName:setString(lang(skillData.name))
        labelLevel:setString("1阶")
        if i == 4 then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
    end
    
end

function NewFormationDescriptionView:updateGuildHeroInformation()
    -- print("NewFormationDescriptionView:updateGuildHeroInformation")
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    local heroData = self._modelMgr:getModel("GuildMapModel"):getEnemyHeroData(self._iconId)
    if not heroData then print("invalid hero icon id", self._iconId) end
    heroData.id = self._iconId
    local heroTableData = tab:Hero(heroData.id)
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroData.star and heroData.star >= 1 then
        if heroData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    self._sheroFileName = "asset/uiother/shero/"..heroTableData.shero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroData)
    heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroSpecialtyData)
    end)
    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))
            index = math.min(index + 1, 2)
        end
    end
    ]]
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    
    -- 1234 攻防智知
    local attributes = {"atk", "def", "int", "ack"}
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    local i = 1
    for _, att in ipairs(attributes) do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        i = i + 1
        if heroTableData[att] then            
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            attValue:setString(string.format("%d", value))
        else
            attValue:setString(0)
        end
    end

    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)
    --[[
    for i = 1, 4 do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i]._icon
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true) 
        
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX() + 7, iconBg:getPositionY() + 7)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        
        lableName:setString(lang(skillData.name))
        labelLevel:setString(heroData["sl" .. i] .. "阶")
        if i == 4 then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
    end
    -]]
    if self._isHaveSpell then
        self:updateHeroSkillDetail2(heroTableData, heroData)
    else
        self:updateHeroSkillDetail1(heroTableData, heroData)
    end 
end

function NewFormationDescriptionView:updateMFHeroInformation()
    -- print("NewFormationDescriptionView:updateMFHeroInformation")
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    local heroData = self._modelMgr:getModel("MFModel"):getEnemyHeroData(self._iconId)
    if not heroData then print("invalid hero icon id", self._iconId) end
    heroData.id = self._iconId
    local heroTableData = tab:Hero(heroData.id)
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroData.star and heroData.star >= 1 then
        if heroData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    self._sheroFileName = "asset/uiother/shero/"..heroTableData.shero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroData)
    heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroSpecialtyData)
    end)
    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))
            index = math.min(index + 1, 2)
        end
    end
    ]]
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    
    -- 1234 攻防智知
    local attributes = {"atk", "def", "int", "ack"}
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    local i = 1
    for _, att in ipairs(attributes) do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        i = i + 1
        if heroTableData[att] then            
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            attValue:setString(string.format("%d", value))
        else
            attValue:setString(0)
        end
    end

    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)
    --[[
    for i = 1, 4 do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i]._icon
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true) 

        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX() + 7, iconBg:getPositionY() + 7)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        
        lableName:setString(lang(skillData.name))
        labelLevel:setString(heroData["sl" .. i] .. "阶")
        if i == 4 then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
    end
    -]]
    if self._isHaveSpell then
        self:updateHeroSkillDetail2(heroTableData, heroData)
    else
        self:updateHeroSkillDetail1(heroTableData, heroData)
    end 
end

function NewFormationDescriptionView:updateNpcHeroInformation()
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")
    
    local heroTableData = nil
    if self._formationType == self._formationModel.kFormationTypeLeague then
        heroTableData = clone(self._leagueModel:getMyHeroData(self._iconId))
        dump(heroTableData,"heroTalbleldatnan=")
        heroTableData.spelllv = {}
        for i = 1, 4 do
            heroTableData.spelllv[i] = heroTableData["sl" .. i]
        end
    elseif self._formationType == self._formationModel.kFormationTypeHeroDuel then
        heroTableData = clone(tab:Hero(self._iconId))
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        if heroDuelTableData then
            heroTableData.star = heroDuelTableData.herostar
            heroTableData.spelllv = {}
            for i = 1, 4 do
                heroTableData.spelllv[i] = heroDuelTableData.heroskill
            end
            heroTableData.herobaseattr = heroDuelTableData.herobase
        end
    else
        heroTableData = clone(tab:NpcHero(self._iconId))
    end
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroTableData.star and heroTableData.star >= 1 then
        if heroTableData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroTableData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroTableData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroTableData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end

    local sHero = heroTableData.shero
    -- begin 积分联赛试用英雄加皮肤
    if self._formationType == self._formationModel.kFormationTypeLeague then
        local heroSkinPort = nil -- 皮肤换立绘
        if heroTableData.skin then
            local skinTableData = tab:HeroSkin(tonumber(heroTableData.skin))
            sHero = skinTableData and skinTableData.shero or sHero
            heroSkinPort = skinTableData and skinTableData.heroport
        end
    end
    -- end  积分联赛试用英雄加皮肤

    self._sheroFileName = "asset/uiother/shero/".. sHero ..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroTableData)
    --heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroTableData)
    end)
    
    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroTableData and heroTableData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            --local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local value = heroTableData[att]
            if not value then 
                value = 0 
            elseif type(value) == "table" then
                value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]
            end
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))
            index = math.min(index + 1, 2)
        end
    end
    ]]

    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
        local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
        -- local hAbData = self._modelMgr:getModel("UserModel"):getHeroGlobalhAb()
        
        -- 1234 攻防智知
        for i=1,4 do
            local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
            if heroTableData.herobaseattr[i] then
                attValue:setString(heroTableData.herobaseattr[i])
            else
                -- print("=========heroDetail hAb===========",i)
                attValue:setString(0)
            end
        end
    else
        self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
        local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
            
        -- 1234 攻防智知
        --[[
        local treasureModel = self._modelMgr:getModel("TreasureModel")
        local talentModel = self._modelMgr:getModel("TalentModel")
        local npcHeroAttributes = BattleUtils.getNpcHeroBaseAttr(heroTableData, treasureModel:getData(), talentModel:getData())
        local branchBuff = self._modelMgr:getModel("UserModel"):getData().branchHAb
        if not branchBuff then branchBuff = {["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0} end
        ]]
        local attributes = {"atk", "def", "int", "ack"}
        local star = heroTableData and heroTableData.star or 1
        if not star then
            star = 1
        end
        local i = 1
        for _, att in ipairs(attributes) do
            local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
            local value = heroTableData[att]
            if not value then 
                value = 0 
            --elseif self._isCustom then
                --value = npcHeroAttributes[att] + branchBuff[tostring(i)]
            elseif type(value) == "table" then
                value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]
            end
            attValue:setString(string.format("%d", value))
            i = i + 1
        end
    end

    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)

    for i = 1, 5 do
        self._hero._skill[i]._icon:setVisible(false)
    end

    for i = 1, #heroTableData.spell do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i == #heroTableData.spell and 4 or i]._icon
        iconParent:setVisible(true)
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true) 
        
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroTableData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i == #heroTableData.spell and 4 or i]._name
        local labelLevel = self._hero._skill[i == #heroTableData.spell and 4 or i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX() + 7, iconBg:getPositionY() + 7)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        
        lableName:setString(lang(skillData.name))
        labelLevel:setString(heroTableData.spelllv[i] .. "阶")
        if i == #heroTableData.spell then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
        if self._isShowSkillUnlockEffect then
            local unlockMC = mcMgr:createViewMC("tianfujiesuo_mofahanghui", false, true)
            unlockMC:setPosition(iconParent:getContentSize().width / 2, iconParent:getContentSize().height / 2)
            iconParent:addChild(unlockMC, 100)
        end
    end
    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        local x = 31
        local y = 30
        local masteryTableData = tab.heroMastery
        local findMasteryId = function(masteryBaseId)
            if not masteryBaseId then return false end
            for k, v in pairs(masteryTableData) do
                if 2 == v.class and masteryBaseId == v.baseid and 3 == v.masterylv then
                    return v.id
                end
            end
            return false
        end
        self._hero._mastery._ui:setVisible(true)
        for i=1, 4 do
            local iconGrid = self._hero._mastery[i]._icon
            local masteryId = findMasteryId(heroTableData.recmastery[i])
            if masteryId then
                -- iconGrid:setEnabled(true)
                iconGrid:setVisible(true)
                iconGrid:setScaleAnim(true)
                iconGrid:setAnchorPoint(0.5,0.5)
                iconGrid:setPosition(x,y)
                x = x + iconGrid:getContentSize().width + 6
                local levelTxt = self._hero._mastery[i]._level
                levelTxt:setFontSize(16)
                levelTxt:setFontName(UIUtils.ttfName)
                local icon = iconGrid:getChildByFullName("masteryIcon")
                if not icon then
                    icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = masteryId, container = { _container = self }, })
                    icon:setScale(0.9)
                    icon:setTouchEnabled(false)
                    icon:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
                    icon:setName("masteryIcon")
                    iconGrid:addChild(icon)
                end 
                icon = iconGrid:getChildByFullName("masteryIcon")
                icon:setIconType(FormationIconView.kIconTypeHeroMastery)
                icon:setIconId(masteryId)
                icon:updateIconInformation()
                self:registerClickEvent(iconGrid, function(x, y)
                    -- print("----------------------------------------")
                    print("self._formationToBattleType[self._formationType]")
                    self:showHintView("global.GlobalTipView",{tipType = 2, node = iconGrid, id = tonumber(masteryId), des = BattleUtils.getDescription(18, tonumber(masteryId), BattleUtils.getHeroAttributes(heroTableData),nil,nil,self._formationToBattleType[self._formationType]),posCenter = true})
                    
                end)
                
                local dataCurrent = tab:HeroMastery(masteryId)
                local currentLv = dataCurrent.masterylv
                local color = nil
                local outlineColor = UIUtils.colorTable.ccUIBaseOutlineColor
                local levelName = nil
                if 1 == currentLv then
                    color = UIUtils.colorTable.ccUIBaseColor2
                    levelName = "初级"
                elseif 2 == currentLv then
                    color = UIUtils.colorTable.ccUIBaseColor3
                    levelName = "中级"
                elseif 3 == currentLv then
                    color = UIUtils.colorTable.ccUIBaseColor4
                    levelName = "高级"
                end
                if levelName then
                    levelTxt:setString(levelName)    
                end
                levelTxt:setColor(color)
                if outlineColor then
                    levelTxt:enableOutline(outlineColor, 2)
                else
                    levelTxt:disableEffect()
                end
            else
                iconGrid:setVisible(false)
            end
        end
    end
end

function NewFormationDescriptionView:updateElementalHeroInformation()
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")
    
    local heroTableData = nil
    if self._formationType == self._formationModel.kFormationTypeLeague then
        heroTableData = clone(self._leagueModel:getMyHeroData(self._iconId))
        dump(heroTableData,"heroTalbleldatnan=")
        heroTableData.spelllv = {}
        for i = 1, 4 do
            heroTableData.spelllv[i] = heroTableData["sl" .. i]
        end
    elseif self._formationType == self._formationModel.kFormationTypeHeroDuel then
        heroTableData = clone(tab:Hero(self._iconId))
        local heroDuelId = self._heroDuelModel:getWeekNum()
        local heroDuelTableData = tab:HeroDuel(heroDuelId)
        if heroDuelTableData then
            heroTableData.star = heroDuelTableData.herostar
            heroTableData.spelllv = {}
            for i = 1, 4 do
                heroTableData.spelllv[i] = heroDuelTableData.heroskill
            end
            heroTableData.herobaseattr = heroDuelTableData.herobase
        end
    else
        heroTableData = clone(tab:NpcHero(self._iconId))
    end
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroTableData.star and heroTableData.star >= 1 then
        if heroTableData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroTableData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroTableData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroTableData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end

    local sHero = heroTableData.shero
    -- begin 积分联赛试用英雄加皮肤
    if self._formationType == self._formationModel.kFormationTypeLeague then
        local heroSkinPort = nil -- 皮肤换立绘
        if heroTableData.skin then
            local skinTableData = tab:HeroSkin(tonumber(heroTableData.skin))
            sHero = skinTableData and skinTableData.shero or sHero
            heroSkinPort = skinTableData and skinTableData.heroport
        end
    end
    -- end  积分联赛试用英雄加皮肤

    self._sheroFileName = "asset/uiother/shero/".. sHero ..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroTableData)
    --heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroTableData)
    end)
    
    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroTableData and heroTableData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            --local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local value = heroTableData[att]
            if not value then 
                value = 0 
            elseif type(value) == "table" then
                value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]
            end
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))
            index = math.min(index + 1, 2)
        end
    end
    ]]

    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
        local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
        -- local hAbData = self._modelMgr:getModel("UserModel"):getHeroGlobalhAb()
        
        -- 1234 攻防智知
        for i=1,4 do
            local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
            if heroTableData.herobaseattr[i] then
                attValue:setString(heroTableData.herobaseattr[i])
            else
                -- print("=========heroDetail hAb===========",i)
                attValue:setString(0)
            end
        end
    else
        self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
        local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
            
        -- 1234 攻防智知
        --[[
        local treasureModel = self._modelMgr:getModel("TreasureModel")
        local talentModel = self._modelMgr:getModel("TalentModel")
        local npcHeroAttributes = BattleUtils.getNpcHeroBaseAttr(heroTableData, treasureModel:getData(), talentModel:getData())
        local branchBuff = self._modelMgr:getModel("UserModel"):getData().branchHAb
        if not branchBuff then branchBuff = {["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0} end
        ]]
        local attributes = {"atk", "def", "int", "ack"}
        local star = heroTableData and heroTableData.star or 1
        if not star then
            star = 1
        end
        local i = 1
        for _, att in ipairs(attributes) do
            local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
            local value = heroTableData[att]
            if not value then 
                value = 0 
            --elseif self._isCustom then
                --value = npcHeroAttributes[att] + branchBuff[tostring(i)]
            elseif type(value) == "table" then
                value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]
            end
            attValue:setString(string.format("%d", value))
            i = i + 1
        end
    end

    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)

    for i = 1, 5 do
        self._hero._skill[i]._icon:setVisible(false)
    end

    for i = 1, #heroTableData.spell do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i == #heroTableData.spell and 4 or i]._icon
        iconParent:setVisible(true)
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true) 
        
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroTableData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i == #heroTableData.spell and 4 or i]._name
        local labelLevel = self._hero._skill[i == #heroTableData.spell and 4 or i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX() + 7, iconBg:getPositionY() + 7)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        
        lableName:setString(lang(skillData.name))
        labelLevel:setString(heroTableData.spelllv[i] .. "阶")
        if i == #heroTableData.spell then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
        if self._isShowSkillUnlockEffect then
            local unlockMC = mcMgr:createViewMC("tianfujiesuo_mofahanghui", false, true)
            unlockMC:setPosition(iconParent:getContentSize().width / 2, iconParent:getContentSize().height / 2)
            iconParent:addChild(unlockMC, 100)
        end
    end
    if self._formationType == self._formationModel.kFormationTypeHeroDuel then
        local x = 31
        local y = 30
        local masteryTableData = tab.heroMastery
        local findMasteryId = function(masteryBaseId)
            if not masteryBaseId then return false end
            for k, v in pairs(masteryTableData) do
                if 2 == v.class and masteryBaseId == v.baseid and 3 == v.masterylv then
                    return v.id
                end
            end
            return false
        end
        self._hero._mastery._ui:setVisible(true)
        for i=1, 4 do
            local iconGrid = self._hero._mastery[i]._icon
            local masteryId = findMasteryId(heroTableData.recmastery[i])
            if masteryId then
                -- iconGrid:setEnabled(true)
                iconGrid:setVisible(true)
                iconGrid:setScaleAnim(true)
                iconGrid:setAnchorPoint(0.5,0.5)
                iconGrid:setPosition(x,y)
                x = x + iconGrid:getContentSize().width + 6
                local levelTxt = self._hero._mastery[i]._level
                levelTxt:setFontSize(16)
                levelTxt:setFontName(UIUtils.ttfName)
                local icon = iconGrid:getChildByFullName("masteryIcon")
                if not icon then
                    icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = masteryId, container = { _container = self }, })
                    icon:setScale(0.9)
                    icon:setTouchEnabled(false)
                    icon:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
                    icon:setName("masteryIcon")
                    iconGrid:addChild(icon)
                end 
                icon = iconGrid:getChildByFullName("masteryIcon")
                icon:setIconType(FormationIconView.kIconTypeHeroMastery)
                icon:setIconId(masteryId)
                icon:updateIconInformation()
                self:registerClickEvent(iconGrid, function(x, y)
                    -- print("----------------------------------------")
                    print("self._formationToBattleType[self._formationType]",self._formationToBattleType[self._formationType])
                    self:showHintView("global.GlobalTipView",{tipType = 2, node = iconGrid, id = tonumber(masteryId), des = BattleUtils.getDescription(18, tonumber(masteryId), BattleUtils.getHeroAttributes(heroTableData),nil,nil,self._formationToBattleType[self._formationType]),posCenter = true})
                    
                end)
                
                local dataCurrent = tab:HeroMastery(masteryId)
                local currentLv = dataCurrent.masterylv
                local color = nil
                local outlineColor = UIUtils.colorTable.ccUIBaseOutlineColor
                local levelName = nil
                if 1 == currentLv then
                    color = UIUtils.colorTable.ccUIBaseColor2
                    levelName = "初级"
                elseif 2 == currentLv then
                    color = UIUtils.colorTable.ccUIBaseColor3
                    levelName = "中级"
                elseif 3 == currentLv then
                    color = UIUtils.colorTable.ccUIBaseColor4
                    levelName = "高级"
                end
                if levelName then
                    levelTxt:setString(levelName)    
                end
                levelTxt:setColor(color)
                if outlineColor then
                    levelTxt:enableOutline(outlineColor, 2)
                else
                    levelTxt:disableEffect()
                end
            else
                iconGrid:setVisible(false)
            end
        end
    end
end

function NewFormationDescriptionView:updateAdventureHeroInformation()
    -- print("NewFormationDescriptionView:updateAdventureHeroInformation")
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    local heroData = self._modelMgr:getModel("AdventureModel"):getEnemyHeroData(self._iconId)
    if not heroData then print("invalid hero icon id", self._iconId) end
    heroData.id = self._iconId
    local heroTableData = tab:Hero(heroData.id)
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroData.star and heroData.star >= 1 then
        if heroData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    self._sheroFileName = "asset/uiother/shero/"..heroTableData.shero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroData)
    heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroSpecialtyData)
    end)

    --[[
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "攻击：", def = "防御：", int = "智力：", ack = "知识："}
    local index = 1
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    -- local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local attImgName = att .. ".png"
            if att == "ack" then
                attImgName = "zhishi.png"
            end
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            local attImg = infoPanel:getChildByFullName("att" .. index)
            local attTxt = attImg:getChildByFullName("attTxt")
            local attAdd = attImg:getChildByFullName("attAdd")
            attAdd:setVisible(false)
            attAdd:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

            attImg:loadTexture(attImgName, 1)
            attTxt:setString(attributesName[att])

            attTxt:setString(string.format("%d", value))
            index = math.min(index + 1, 2)
        end
    end
    ]]
    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    
    -- 1234 攻防智知
    local attributes = {"atk", "def", "int", "ack"}
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    local i = 1
    for _, att in ipairs(attributes) do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        i = i + 1
        if heroTableData[att] then            
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            attValue:setString(string.format("%d", value))
        else
            attValue:setString(0)
        end
    end

    --[[
    local labelDiscription = self._hero._labelSpecialtyDes
    local desc = ""
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)
    --[[
    for i = 1, 4 do
        local skillId = heroTableData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(heroTableData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local iconParent = self._hero._skill[i]._icon
        local iconBg = iconParent:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true)         
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, skillData.id, clone(heroData))
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        local lableName = self._hero._skill[i]._name
        local labelLevel = self._hero._skill[i]._level
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillData.art .. ".png")
        icon:setScale(0.97)
        icon:setPosition(iconBg:getPositionX( ) + 7.5, iconBg:getPositionY() + 7.5)
        iconBg:addChild(icon,-1)
        local skillType = skillData.type
        lableName:setColor(UIUtils.colorTable["ccUIHeroSkillColor" .. skillType])
        
        lableName:setString(lang(skillData.name))
        labelLevel:setString(heroData["sl" .. i] .. "阶")
        if i == 4 then
            icon:setPosition(48, 48)
            dazhaoImg:setVisible(true)  
            dazhaoImg:setPosition(iconParent:getPositionX()+15, iconParent:getPositionY()+60)         
        end
    end
    --]]
    if self._isHaveSpell then
        self:updateHeroSkillDetail2(heroTableData, heroData)
    else
        self:updateHeroSkillDetail1(heroTableData, heroData)
    end 
end

function NewFormationDescriptionView:updateCrossPKHeroInformation()
    -- print("NewFormationDescriptionView:updateCrossPKHeroInformation")
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    local heroData = self._crossModel:getEnemyHeroData(self._iconId)
    if not heroData then print("invalid hero icon id", self._iconId) end
    heroData.id = self._iconId
    local heroTableData = tab:Hero(heroData.id)
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroData.star and heroData.star >= 1 then
        if heroData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    self._sheroFileName = "asset/uiother/shero/"..heroTableData.shero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroData)
    heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroSpecialtyData)
    end)

    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    
    -- 1234 攻防智知
    local attributes = {"atk", "def", "int", "ack"}
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    local i = 1
    for _, att in ipairs(attributes) do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        i = i + 1
        attValue:setString(0)
        if heroTableData[att] then            
            local value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]  --(star - self._heroTableData.star)
            attValue:setString(string.format("%d", value))
        end
    end

    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)

    if self._isHaveSpell then
        self:updateHeroSkillDetail2(heroTableData, heroData)
    else
        self:updateHeroSkillDetail1(heroTableData, heroData)
    end 
end

function NewFormationDescriptionView:updateClimbTowerHeroInformation()
    --print("NewFormationDescriptionView:updateArenaHeroInformation")
    -- if true then return end
    self._team._layer:setVisible(false)
    self._hero._layer:setVisible(true)
    self._title:setString("英雄信息")

    local heroData = self._modelMgr:getModel("PurgatoryModel"):getEnemyHeroData(self._iconId)
    dump(heroData)
    if not heroData then print("invalid hero icon id", self._iconId) end
    heroData.id = self._iconId
    local heroTableData = tab:Hero(heroData.id)
    
    -- self._hero._layerClass:setBackGroundImage(IconUtils.iconPath .. "h_prof_" .. heroTableData.prof ..".png", 1)
    -- TeamUtils.showTeamLabelTip(self._hero._layerClass, 11, heroTableData.prof)
    self._hero._labelName:setString(lang(heroTableData.heroname))

    self._hero._labelSpecialtyName:setString(lang("HEROSPECIAL_" .. heroTableData.special))
    if heroData.star and heroData.star >= 1 then
        if heroData.star > 4 then
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        else
            self._hero._layerSpecialtyStar:loadTexture("globalImageUI_heroStar" .. heroData.star .. ".png",1)
        end
    else
        self._hero._layerSpecialtyParent:setVisible(false)
    end
    for i = 1, 4 do
        if i <= heroData.star then
            self._hero._star[i]._normal:setVisible(true)
        else
            self._hero._star[i]._normal:setVisible(false)
        end
    end
    local offsetX , offsetY = 0,0
    if heroTableData.xiaoren then
        offsetX , offsetY  = tonumber(heroTableData.xiaoren[1]) ,tonumber(heroTableData.xiaoren[2])
    end
    self._sheroFileName = "asset/uiother/shero/"..heroTableData.shero..".png"
    local heroBody = ccui.ImageView:create(self._sheroFileName)
    heroBody:setScale(NewFormationDescriptionView.kHeroScale)
    heroBody:setAnchorPoint(0.5,0)
    heroBody:setPosition(self._hero._layerBody:getContentSize().width / 2+offsetX, self._hero._layerBody:getContentSize().height / 1.28+offsetY-150)
    self._hero._layerBody:addChild(heroBody, 10)
    -- hero mestery    rece 1，2，3，4
    local image_body_bg = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bg")
    image_body_bg:loadTexture("asset/uiother/race/race_" .. heroTableData.masterytype ..".png")

    local image_body_bottom = self:getUI("bg.layer.layer_hero.layer_left.layer_body.image_body_bottom")
    if image_body_bottom then
        image_body_bottom:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    end

    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(heroTableData.special)
    self._hero._layerSpecialty:setBackGroundImage(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)
    local heroSpecialtyData = clone(heroData)
    heroSpecialtyData.special = heroTableData.special
    self._hero._layerSpecialty.tipOffset = cc.p(-265, 0)
    self:registerClickEvent(self._hero._layerSpecialtyParent, function(x, y)
        self:showSpecialtyTip(self._hero._layerSpecialtyParent, heroSpecialtyData)
    end)

    self._teamInfo1 = self._hero._layer:getChildByFullName("layer_right.team_info_1")
    local infoPanel = self._teamInfo1:getChildByFullName("infoPanel")
    
    -- 1234 攻防智知
    local stageId = self._modelMgr:getModel("PurgatoryModel"):getStageId()
    local cfg = tab.purFight[stageId]

    local attributes = {"atk", "def", "int", "ack"}
    local star = heroData and heroData.star or 1
    if not star then
        star = 1
    end
    local i = 1
    for _, att in ipairs(attributes) do
        local attValue = infoPanel:getChildByFullName("att" .. i ..".attTxt")
        attValue:setString(0)
        if cfg.herobase then            
            local value = cfg.herobase[i]
            attValue:setString(string.format("%d", value))
        end
        i = i + 1
    end

    local dazhaoImg = self:getUI("bg.layer.layer_hero.layer_right.team_info_2.dazhao")
    dazhaoImg:setZOrder(20)
    dazhaoImg:setVisible(false)

    if self._isHaveSpell then
        self:updateHeroSkillDetail2(heroTableData, heroData)
    else
        self:updateHeroSkillDetail1(heroTableData, heroData)
    end 
end

return NewFormationDescriptionView


