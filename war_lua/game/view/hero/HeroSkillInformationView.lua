--[[
    Filename:    HeroSkillInformationView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-07-09 18:06:31
    Description: File description
--]]


local FormationIconView = require("game.view.formation.FormationIconView")
local HeroDetailsView = require("game.view.hero.HeroDetailsView")

local HeroSkillInformationView = class("HeroSkillInformationView", BaseLayer)

HeroSkillInformationView.kHeroEquipmentTag = 1000
HeroSkillInformationView.kHeroSkillTag = 2000

HeroSkillInformationView.kTabTypeEquipment = 3000
HeroSkillInformationView.kTabTypeSkill = 4000

HeroSkillInformationView.kNormalZOrder = 500
HeroSkillInformationView.kLessNormalZOrder = HeroSkillInformationView.kNormalZOrder - 1
HeroSkillInformationView.kAboveNormalZOrder = HeroSkillInformationView.kNormalZOrder + 1
HeroSkillInformationView.kHighestZOrder = HeroSkillInformationView.kAboveNormalZOrder + 1

HeroSkillInformationView.kSkillCount = 4

local skillDefaultIndex = 4

local SKillHurtKindMap = {
    [1] = "物理",
    [2] = "火系",
    [3] = "水系",
    [4] = "风系",
    [5] = "土系",
}

function HeroSkillInformationView:ctor(params)
    HeroSkillInformationView.super.ctor(self)
    self._heroData = params.data
    -- dump(self._heroData)
    self._container = params.container
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
end

function HeroSkillInformationView:disableTextEffect(element)
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

function HeroSkillInformationView:onInit()
    
    --[[
    self._heroIcon = self:getUI("bg.layer.layer_icon")
    self._heroName = self:getUI("bg.layer.label_hero_name")
    self._heroLevel = self:getUI("bg.layer.label_level.label_level_value")
    self._heroCareer = self:getUI("bg.layer.label_career.label_career_value")

    self._specialtyIcon = self:getUI("bg.layer.layer_mastery.layer_specialty_icon")
    self._specialtyName = self:getUI("bg.layer.layer_mastery.layer_specialty_icon.label_specialty_name")
    self._primaryIcon = self:getUI("bg.layer.layer_mastery.layer_primary")
    self._primaryName = self:getUI("bg.layer.layer_mastery.layer_primary.label_primary_name")
    self._intermediateIcon = self:getUI("bg.layer.layer_mastery.layer_intermediate")
    self._intermediateName = self:getUI("bg.layer.layer_mastery.layer_intermediate.label_intermediate_name")
    self._advancedIcon = self:getUI("bg.layer.layer_mastery.layer_advanced")
    self._advancedName = self:getUI("bg.layer.layer_mastery.layer_advanced.label_advanced_name")
    self._professorIcon = self:getUI("bg.layer.layer_mastery.layer_professor")
    self._professorName = self:getUI("bg.layer.layer_mastery.layer_professor.label_professor_name")
    ]]

    --[[ -- version 3.0
    self._layerEquipment = self:getUI("bg.layer.layer_equipment")
    self._layerBody = self:getUI("bg.layer.layer_equipment.layer_body")
    self._artifactIcons = {}
    for i=1, 6 do
        self._artifactIcons[i] = self:getUI(string.format("bg.layer.layer_equipment.image_artifact_%d.layer_artifact", i))
    end
    self._layerSkill = self:getUI("bg.layer.layer_skill")
    ]]
    self:disableTextEffect()
    self._currentSkillIndex = skillDefaultIndex or 4
    self._skills = {}
    for i = 1, HeroSkillInformationView.kSkillCount do
        self._skills[i] = {}
        self._skills[i]._icon = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i)
        self._skills[i].skill_icon_touch = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".skill_icon_touch")
        self._skills[i].skill_icon_touch:setScaleAnim(true)
        self:registerClickEvent(self._skills[i].skill_icon_touch, function()
            self:updateUI(i)
        end)
        
        self._skills[i]._imageFire = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".skill_icon_touch.image_fire")
        -- self._skills[i]._imageFireCircle = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".image_fire_circle")
        self._skills[i]._imageWater = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".skill_icon_touch.image_water")
        -- self._skills[i]._imageWaterCircle = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".image_water_circle")
        self._skills[i]._imageWind = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".skill_icon_touch.image_wind")
        -- self._skills[i]._imageWindCircle = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".image_wind_circle")
        self._skills[i]._imageSoil = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".skill_icon_touch.image_soil")
        -- self._skills[i]._imageSoilCircle = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".image_soil_circle")
        self._skills[i]._labelSkillName = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".label_skill_name")
        --self._skills[i]._labelSkillName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        self._skills[i]._labelSkillLevel = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".label_skill_level")
        --self._skills[i]._labelSkillLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._skills[i]._imageUpgrade = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_" .. i .. ".skill_icon_touch.image_upgrade")
        self._skills[i]._imageUpgrade:setPosition(70, 24)
    end

    -- 单独管理技能书槽
    self._bookSlot = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5")
    if self._bookSlot then
        self._bookSlot.skill_icon_touch = self._bookSlot:getChildByName("skill_icon_touch")
        self._bookSlot._imageFire = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5.skill_icon_touch.image_fire")
        self._bookSlot._imageWater = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5.skill_icon_touch.image_water")
        self._bookSlot._imageWind = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5.skill_icon_touch.image_wind")
        self._bookSlot._imageSoil = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5.skill_icon_touch.image_soil")
        self._bookSlot._labelSkillName = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5.label_skill_name")
        self._bookSlot._labelSkillLevel = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5.label_skill_level")
        self._bookSlot._labelSkillNone = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5.label_skill_none")

        self._bookSlot._imageUpgrade = self:getUI("bg.layer.layer_skill.layer_left.skill_icon_5.skill_icon_touch.image_upgrade")
        self._bookSlot._imageUpgrade:setPosition(70, 14)
        self._bookSlot.textures = {}
        local textureMap = {[0] = "image_unlock","image_fire","image_water","image_wind","image_soil"}
        for k,childName in pairs(textureMap) do
            local node = self._bookSlot.skill_icon_touch:getChildByName(childName)
            if node then 
                node:setVisible(false)
                self._bookSlot.textures[k] = node
                -- table.insert(self._bookSlot.textures,node)
            end
        end
        -- 如果开孔动画
        self:registerClickEvent(self._bookSlot.skill_icon_touch, function()
            print("click newSlot....")
            local isFixed,isOpen,isCanOpen = self:detectIsSlotOpen()
            if self._bookSlot._todigguid then 
                self._bookSlot._todigguid:setVisible(false)
            end
            if isFixed then
                self:updateUI(5)
            elseif isOpen then
                if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                    self._container:showTopInfo(false)
                end
                if self._bookSlot._todigguid then
                    self._bookSlot._todigguid:removeFromParent()
                    self._bookSlot._todigguid = nil
                end
                self._viewMgr:showDialog("spellbook.HeroSpellBookView",{heroData = self._heroData,tabIdx = self._heroData.slot and 1 or 2,callback = function( )
                    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                        self._container:showTopInfo(true)
                        if self._container.updateButtonStatus then
                            self._container:updateButtonStatus()
                        end
                    end
                    if self.updateSpellBookSlot then
                        self:updateSpellBookSlot()
                    end
                    if self._heroData.slot 
                        and self._heroData.slot.sid == 0
                    then
                        print("self._sssssss",self._currentSkillIndex)
                        local selIdx = self._currentSkillIndex == 5 and 4 or self._currentSkillIndex
                        self._modelMgr:getModel("HeroModel"):initSlotSkillex(self._heroData)
                        self:updateUI(selIdx)
                    end
                end})
            elseif isCanOpen then
                -- -- 第一次点击播解锁动画
                -- local isActived = SystemUtils.loadAccountLocalData("heroSlot_opened" .. self._heroData.id)
                -- if not isActived then
                --     local mc = mcMgr:createViewMC("fashushujiesuo_skillbookfashushu-HD",true,true,function( )
                --         SystemUtils.saveAccountLocalData("heroSlot_opened" .. self._heroData.id,true)
                --         self:updateSpellBookSlot()
                --     end)
                --     mc:setPosition(35,35)
                --     mc:setScale(-1,1)
                --     self._bookSlot:addChild(mc,99)
                -- end
            else
                self._viewMgr:showTip(self._notOpenSlotDes)
            end
        end)
        local changeBtn = self._bookSlot:getChildByName("changeBtn")
        self:registerClickEvent(changeBtn,function() 
            self._container:showTopInfo(false)
            self._viewMgr:showDialog("spellbook.HeroSpellBookView",{heroData = self._heroData,callback = function( )
                if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                    self._container:showTopInfo(true)
                    if self._container.updateButtonStatus then
                        self._container:updateButtonStatus()
                    end
                end
                if self.updateSpellBookSlot then
                    self:updateSpellBookSlot()
                end
                if self._heroData.slot 
                    and self._heroData.slot.sid == 0
                then
                    local selIdx = self._currentSkillIndex == 5 and 4 or self._currentSkillIndex
                    self._modelMgr:getModel("HeroModel"):initSlotSkillex(self._heroData)
                    self:updateUI(selIdx)
                end
            end})
        end)
        self:updateSpellBookSlot()
    end
    -- 技能书槽初始化end
    self._skillName = self:getUI("bg.layer.layer_skill.layer_right.skill_name_bg.skill_name")
    -- self._skillName:setFontName(UIUtils.ttfName_Title)
    --self._skillName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._skillCurrentLevel = self:getUI("bg.layer.layer_skill.layer_right.skill_name_bg.label_current_skill_level")
    -- self._skillCurrentLevel:setFontName(UIUtils.ttfName_Title)
    --self._skillCurrentLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._skillCurrentLevel_0 = self:getUI("bg.layer.layer_skill.layer_right.skill_name_bg.label_current_skill_level_0")
    --self._skillCurrentLevel_0:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- self._skillCurrentLevel_0:setFontName(UIUtils.ttfName_Title)
    self._skillCurrentLevel_1 = self:getUI("bg.layer.layer_skill.layer_right.skill_name_bg.label_current_skill_level_1")
    -- self._skillCurrentLevel_1:setFontName(UIUtils.ttfName_Title)
    --self._skillCurrentLevel_1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    --self._skillCurrentLevelName = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.label_current_skill_level_name")
    --self._skillCurrentLevelName:setFontName(UIUtils.ttfName_Title)

    self._skillDesBg2 = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_2")
    self._skillDesBg2:setVisible(false)
    local skillNextLevel = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_2.label_next_skill_level")
    -- skillNextLevel:setFontName(UIUtils.ttfName_Title)
    local skillCurrentPro = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.label_skill_level_pro")
    self._slotExDes = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.label_skill_slot_exdes")
    self._slotExDes:setVisible(false)
    --skillCurrentPro:enableOutline(cc.c3b(60, 30, 10), 1)
    -- skillCurrentPro:setFontName(UIUtils.ttfName_Title)


    self._imageTagType = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.image_tag_type")
    self._imageDmgTagType = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.image_dmgtag_type")

    --self._skillManaImageBg = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.image_mana_bg")
    self._imageUnderline2 = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.image_underline_2")
    self._skillManaValue = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.label_mana_value")
    self:registerClickEvent(self._skillManaValue, function(sender)
        self:showMCDTips()
    end)
    --self._skillManaValueAddition = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.label_mana_value_addition")
    --self._skillCDImageBg = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.image_cd_bg")
    self._imageUnderline1 = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.image_underline_1")
    self._skillCDValue = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.label_cd_value")
    self:registerClickEvent(self._skillCDValue, function(sender)
        self:showCDTips()
    end)
    --self._skillCDValueAddition = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.label_cd_value_addition")
    self._labelSecond = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.label_second")
    self._skillEffectDes = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_1.label_effect_des")
    --self._layerEffect = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_2.layer_effect")
    --self._skillNextLevelEffectDes = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_2.layer_effect.label_effect_des")
    --self._skillTopLevel = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_2.image_skill_top_level")

    self._skillDesBg3 = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3")
    self._skillProgressBarFrame = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.image_pro_bar_frame")
    self._skillProgressBar = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.image_pro_bar_frame.layer_pro")
    self._proLabel = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.image_pro_bar_frame.label_pro")
    self._proLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._proNormal = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.image_pro_bar_frame.pro_normal")
    self._proGray = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.image_pro_bar_frame.pro_gray")
    self._labelEffectDes3 = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.label_effect_des")
    self._skillStudyImageGlod= self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.image_gold")
    self._skillStudyGoldValue = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.gold_value")
    self._skillStudyGoldValue:getVirtualRenderer():setAdditionalKerning(2)
    self._skillStudyGoldValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._skillStudyLayerTool = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.layer_tool")
    self._skillStudyLayerToolGet = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.layer_tool_get")
    self._skillStudyLayerToolGet:setSwallowTouches(false)
    self:registerClickEvent(self._skillStudyLayerToolGet, function(sender)
        self:onButtonToolGetClicked()
    end)
    self._skillStudyToolValue = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.tool_value")
    self._skillStudyToolValue:getVirtualRenderer():setAdditionalKerning(2)
    --self._skillStudyToolValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._skillStudyLevelLimited = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.level_limited")
    --self._skillLabelStudy = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.btn_study.label_study")
    --self._skillLabelStudy:enableOutline(cc.c4b(0, 0, 0,255), 1)
    self._image_add = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.layer_tool_get.image_add")
    self._skillBtnStudy = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.btn_study")
    self:registerClickEvent(self._skillBtnStudy, function(sender)
        if self._skillBtnStudy._tip then
            self._viewMgr:showTip(self._skillBtnStudy._tip)
            return 
        end
        self:onStudyButtonClicked()
    end)

    self._skillBtnStudy10 = self:getUI("bg.layer.layer_skill.layer_right.skill_des_title_bg_3.btn_study_10")
    self:registerClickEvent(self._skillBtnStudy10, function(sender)
        self:onStudy10ButtonClicked()
    end)

    self._skillMaxLevel = self:getUI("bg.layer.layer_skill.layer_right.image_max_level")

    -- self._studyUpgrade1 = mcMgr:createViewMC("jingxiushuaxin_herospellstudyanim", false, false)
    -- self._studyUpgrade1:setVisible(false)
    -- self._widget:addChild(self._studyUpgrade1)
    --[[
    self._studyUpgrade2 = mcMgr:createViewMC("jingxiutiao_herospellstudyanim", false, false)
    self._studyUpgrade2:setVisible(false)
    self._widget:addChild(self._studyUpgrade2)
    ]]

    self._studyMC2 = mcMgr:createViewMC("baoji2_herospellstudyanim", false, false)
    self._studyMC2:setVisible(false)
    self._widget:addChild(self._studyMC2)

    self._studyMC5 = mcMgr:createViewMC("baoji5_herospellstudyanim", false, false)
    self._studyMC5:setVisible(false)
    self._widget:addChild(self._studyMC5)

    self._studyMC10 = mcMgr:createViewMC("baoji10_herospellstudyanim", false, false)
    self._studyMC10:setVisible(false)
    self._widget:addChild(self._studyMC10)

    self._skillSelectedMC = mcMgr:createViewMC("fashuxuanzhong_herospellstudyanim", true)
    self._skillSelectedMC:setVisible(false)
    self._skillSelectedMC:setPlaySpeed(1, true)
    self._widget:addChild(self._skillSelectedMC)

    --self:updateHeroSkillInformation()

    --[[ -- version 3.0
    self._btnEquipment = self:getUI("bg.layer.btn_equipment")
    self._btnSkill = self:getUI("bg.layer.btn_skill")

    self._scheduler = cc.Director:getInstance():getScheduler()
    self:registerClickEvent(self._btnEquipment, function(sender)
        self:onEquipmentButtonClicked()
    end)

    self:registerClickEvent(self._btnSkill, function(sender)
        self:onSkillButtonClicked()
    end)
    ]]
end

function HeroSkillInformationView:updateSkillIcon()
    local index = self._currentSkillIndex or 1
    if not self._initSkillIcon then
        for i = 1, HeroSkillInformationView.kSkillCount do
            local skillId = self._heroData.spell[i]
            local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
            if isReplaced then
                skillId = skillReplacedId
            end
            local skillData = tab:PlayerSkillEffect(skillId)
            local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png")
            --icon:setScale(0.85)
            icon:setPosition(self._skills[i].skill_icon_touch:getContentSize().width / 2, self._skills[i].skill_icon_touch:getContentSize().height / 2)
            self._skills[i].skill_icon_touch:addChild(icon)
            --[[
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
            self._skills[i]._labelSkillName:setColor(color)
            ]]
            local skillType = skillData.type
            local color = UIUtils.colorTable["ccUIHeroSkillColor" .. skillType]
            self._skills[i]._labelSkillName:setColor(color)
            self._skills[i]._labelSkillName:setString(lang(skillData.name))
            --self._skills[i]._labelSkillLevel:setColor(color)
        end
        self._initSkillIcon = true
    end

    local markSelected = function(node, isSelected)
        if true then return end
        if not isSelected then
            node:stopAllActions()
            node:setRotation(0)
            return
        end
        node:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, -360.0)))
    end

    for i = 1, HeroSkillInformationView.kSkillCount do
        local skillId = self._heroData.spell[i]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillData = tab:PlayerSkillEffect(skillId)
        local skillType = skillData.type

        --add by wangyan
        local sysSkillData = tab.skillBookBase[skillId]
        local imgRes = {"skill_bg_fire01_hero", "skill_bg_water01_hero", "skill_bg_wind01_hero", "skill_bg_soil01_hero"}
        local iconList = {self._skills[i]._imageFire, self._skills[i]._imageWater, self._skills[i]._imageWind, self._skills[i]._imageSoil}
        if sysSkillData and sysSkillData["type"] == 4 then
            for i=1, 4 do
                iconList[i]:loadTexture(imgRes[i] .. ".png", 1)
            end
        end

        self._skills[i]._imageFire:setVisible(skillType ~= 1 and skillType == 2)
        -- self._skills[i]._imageFireCircle:setVisible(skillType ~= 1 and skillType == 2)
        -- markSelected(self._skills[i]._imageFireCircle, self._skills[i]._imageFireCircle:isVisible() and i == index)
        self._skills[i]._imageWater:setVisible(skillType ~= 1 and skillType == 3)
        -- self._skills[i]._imageWaterCircle:setVisible(skillType ~= 1 and skillType == 3)
        -- markSelected(self._skills[i]._imageWaterCircle, self._skills[i]._imageWaterCircle:isVisible() and i == index)
        self._skills[i]._imageWind:setVisible(skillType ~= 1 and skillType == 4)
        -- self._skills[i]._imageWindCircle:setVisible(skillType ~= 1 and skillType == 4)
        -- markSelected(self._skills[i]._imageWindCircle, self._skills[i]._imageWindCircle:isVisible() and i == index)
        self._skills[i]._imageSoil:setVisible(skillType ~= 1 and skillType == 5)
        -- self._skills[i]._imageSoilCircle:setVisible(skillType ~= 1 and skillType == 5)
        -- markSelected(self._skills[i]._imageSoilCircle, self._skills[i]._imageSoilCircle:isVisible() and i == index)
        self._skills[i]._labelSkillLevel:setString(self._heroData["sl" .. i] .. "阶")
        if i == index then
            self._skillSelectedMC:setVisible(true)
            self._skillSelectedMC:retain()
            self._skillSelectedMC:removeFromParentAndCleanup()
            self._skillSelectedMC:setPosition(cc.p(self._skills[i].skill_icon_touch:getContentSize().width / 2, self._skills[i].skill_icon_touch:getContentSize().height / 2))
            self._skills[i].skill_icon_touch:addChild(self._skillSelectedMC, 10)
            self._skillSelectedMC:release()
        end

        local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
        local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
        local skillLevel = self._heroData["sl" .. i]
        self._skills[i]._imageUpgrade:stopAllActions()
        if skillLevel < skillMaxLevel then 
            local levelLimited = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).lvlim[i]
            local ok = true
            local skcost
            if i == 4 then
                skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost2
            elseif i == 5 then
                skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost3
            else
                skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost
            end
            for k, v in pairs(skcost) do
                local have, consume = 0, v[3]
                if "tool" == v[1] then
                    local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                    have = toolNum
                elseif "gold" == v[1] then
                    have = self._modelMgr:getModel("UserModel"):getData().gold
                elseif "gem" == v[1] then
                    have = self._modelMgr:getModel("UserModel"):getData().freeGem
                end
                if consume > have then
                    ok = false
                    break
                end
            end
            if ok and userLevel >= levelLimited then
                self._skills[i]._imageUpgrade:setVisible(true)
                local moveUp = cc.MoveTo:create(0.4, cc.p(70, 30))
                local moveDown = cc.MoveTo:create(0.4, cc.p(70, 24))
                self._skills[i]._imageUpgrade:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
            else
                self._skills[i]._imageUpgrade:setVisible(false)
            end
        else
            self._skills[i]._imageUpgrade:setVisible(false)
        end
    end
    --[=[ -- version 3.0
    for i = 1, 5 do
        --[[
        --print("spellId", self._heroData["spell" .. i])
        local skillData = tab:PlayerSkillEffect(self._heroData["spell" .. i])
        --local icon = self._skills[i]._icon:getChildByTag(self.kHeroSkillTag)
        local clipNode = self._skills[i]._icon:getChildByName("clipNode")
        if not clipNode then
            local icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeSkill, iconId = skillData.id })
            icon:setPosition(self._skills[i]._icon:getContentSize().width / 2, self._skills[i]._icon:getContentSize().height / 2)
            icon:setTag(self.kHeroSkillTag)
            self._skills[i]._icon:addChild(icon)
            IconUtils:setRoundedCorners(icon, "globalImage_IconMaskCircle.png")
        end 
        clipNode = self._skills[i]._icon:getChildByName("clipNode")
        local icon = clipNode:getChildByTag(self.kHeroSkillTag)
        icon:setIconType(FormationIconView.kIconTypeSkill)
        icon:setIconId(skillData.id)
        icon:updateIconInformation()
        ]]
        --[[
        local skillData = tab:PlayerSkillEffect(self._heroData["spell" .. i])
        local icon = cc.Sprite:createWithSpriteFrameName(tostring((skillData.art or skillData.icon)))
        icon:setScale(0.52)
        local clipNode = IconUtils:setRoundedCorners(icon, (skillData.art or skillData.icon), "globalImage_IconMaskCircle.png")
        clipNode:setPosition(self._skills[i]._icon:getContentSize().width / 2, self._skills[i]._icon:getContentSize().height / 2)
        local touchListener = cc.EventListenerTouchOneByOne:create()
        touchListener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local position = clipNode:convertToNodeSpace(location)
            local size = clipNode:getContentSize()
            local rect = cc.rect(0, 0, size.width * clipNode:getScaleX(), size.height * clipNode:getScaleY())
            if not cc.rectContainsPoint(rect, position) then return false end
            self:startClock(clipNode, FormationIconView.kIconTypeSkill, skillData.id)
            return true
        end, cc.Handler.EVENT_TOUCH_BEGAN)

        touchListener:registerScriptHandler(function(touch, event)
        end, cc.Handler.EVENT_TOUCH_MOVED)

        touchListener:registerScriptHandler(function(touch, event)
            self:endClock()
        end, cc.Handler.EVENT_TOUCH_ENDED)

        touchListener:registerScriptHandler(function(touch, event)
            self:endClock()
        end, cc.Handler.EVENT_TOUCH_CANCELLED)

        self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, clipNode)
        self._skills[i]._icon:addChild(clipNode)
        ]]
        local skillData = tab:PlayerSkillEffect(self._heroData["spell" .. i])
        local icon = cc.Sprite:createWithSpriteFrameName(tostring((skillData.art or skillData.icon)))
        icon:setScale(0.52)
        icon:setPosition(self._skills[i]._icon:getContentSize().width / 2, self._skills[i]._icon:getContentSize().height / 2)
        local touchListener = cc.EventListenerTouchOneByOne:create()
        touchListener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local position = icon:convertToNodeSpace(location)
            local size = icon:getContentSize()
            local rect = cc.rect(0, 0, size.width, size.height)
            if not cc.rectContainsPoint(rect, position) then return false end
            self:startClock(icon, FormationIconView.kIconTypeSkill, skillData.id)
            return true
        end, cc.Handler.EVENT_TOUCH_BEGAN)

        touchListener:registerScriptHandler(function(touch, event)
        end, cc.Handler.EVENT_TOUCH_MOVED)

        touchListener:registerScriptHandler(function(touch, event)
            self:endClock()
        end, cc.Handler.EVENT_TOUCH_ENDED)

        touchListener:registerScriptHandler(function(touch, event)
            self:endClock()
        end, cc.Handler.EVENT_TOUCH_CANCELLED)

        self:getEventDispatcher():addEventListenerWithSceneGraphPriority(touchListener, icon)
        self._skills[i]._icon:addChild(icon)
        local skillType = skillData.type
        self._skills[i]._imageFire:setVisible(skillType ~= 1 and skillType == 2)
        self._skills[i]._imageWater:setVisible(skillType ~= 1 and skillType == 3)
        self._skills[i]._imageWind:setVisible(skillType ~= 1 and skillType == 4)
        self._skills[i]._imageSoil:setVisible(skillType ~= 1 and skillType == 5)
        --[[ -- version 3.0
        local skillKind = skillData.kind
        local skillOption = skillData.option
        if 1 == skillKind and 1 == skillOption then
            self._skills[i]._imageDescriptionBg:setVisible(false)
        elseif 1 == skillKind and 2 == skillOption then
            self._skills[i]._labelSkillDescription:setString("划动")
        elseif 1 == skillKind and 3 == skillOption then
            self._skills[i]._labelSkillDescription:setString("拖动")
        elseif 1 == skillKind and 4 == skillOption then
            self._skills[i]._labelSkillDescription:setString("蓄力")
        elseif 2 == skillKind then
            self._skills[i]._labelSkillDescription:setString("瞬发")
        else 
            self._skills[i]._imageDescriptionBg:setVisible(false)
        end
        self._skills[i]._labelSkillName:setString(lang(skillData.name))
        self._skills[i]._labelSkillMagicConsume:setString("魔法值:" .. skillData.manacost)
        ]]
    end
    ]=]
end

function HeroSkillInformationView:onButtonToolGetClicked()
    -- remove skill stage
    local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
    local index = self._currentSkillIndex or 1
    local skillData = self._attributeValues.skills
    local skillLevel = skillData[index][2]
        local skcost
        if index == 4 then
            skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost2
        elseif index == 5 then
            skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost3
        else
            skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost
        end
    for k, v in pairs(skcost) do
        if "tool" == v[1] then
            if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                self._container:showTopInfo(false)
            end
            -- 获取途径替换为购买界面 by guojun 2017.3.28
            DialogUtils.showBuyRes({goalType="magicNum",callback = function( )
                if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                    self._container:showTopInfo(true)
                end
            end})
            -- DialogUtils.showItemApproach(v[2], function()
            --     if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
            --         self._container:showTopInfo(true)
            --     end
            -- end)
            break
        end
    end
    --[[
    local index = self._currentSkillIndex or 1
    local skillData = self._attributeValues.skills
    local skillStage = skillData[index][2]
    local skillLevel = skillData[index][3]
    local skcost = 5 == index and tab:PlayerSkillExp(skillLevel).skcost2 or tab:PlayerSkillExp(skillLevel).skcost
    for k, v in pairs(skcost) do
        if "tool" == v[1] then
            DialogUtils.showItemApproach(v[2])
            break
        end
    end
    ]]
end

function HeroSkillInformationView:showMCDTips()
    print("showMCDTips")
    --self._attributeValues.MCD
    local index = self._currentSkillIndex or 1
    local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
    local skillId = self._heroData.spell[index] or (self._heroData.slot and (tonumber(self._heroData.slot.sid)))
    local originSkillId
    if tab.heroMastery[tonumber(skillId) or 0] then return end -- 刻印的被动法术不弹tip
    local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
    if isReplaced then
        originSkillId = skillId
        skillId = skillReplacedId
    end
    self:showHintView("global.GlobalTipView",
        {   
            tipType = 14, 
            id = skillId,
            originId = originSkillId,
            node = self._skillCDValue,
            attributeValues = self._attributeValues,
            skillLevel = self._heroData["sl" .. index] or (self._heroData.slot and (tonumber(self._heroData.slot.s))),
            posCenter = true,
        })
end

function HeroSkillInformationView:showCDTips()
    print("showCDTips")
    --self._attributeValues.CD
    local index = self._currentSkillIndex or 1
    local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
    local skillId = self._heroData.spell[index] or (self._heroData.slot and (tonumber(self._heroData.slot.sid)))
    if tab.heroMastery[tonumber(skillId) or 0] then return end -- 刻印的被动法术不弹tip
    -- 如果因为专长变化 技能id 记录原始的耗魔 记录专长额外加成值
    local originSkillId
    local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
    if isReplaced then
        originSkillId = skillId
        skillId = skillReplacedId
    end
    self:showHintView("global.GlobalTipView",
        {   
            tipType = 13, 
            id = skillId,
            originId = originSkillId,
            node = self._skillCDValue,
            attributeValues = self._attributeValues,
            skillLevel = self._heroData["sl" .. index] or (self._heroData.slot and (tonumber(self._heroData.slot.s))),
            posCenter = true,
        })
end

function HeroSkillInformationView:updateSkillDetails()
    -- remove skill stage
    local index = self._currentSkillIndex or 1
    local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
    local skillId = self._heroData.spell[index]
    local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
    if isReplaced then
        skillId = skillReplacedId
    end
    local skillTableData = tab:PlayerSkillEffect(skillId)
    local skillData = self._attributeValues.skills
    local skillLevel = self._heroData["sl" .. index]
    local skillCurrentExp = self._heroData["se" .. index]
    local skillCurrentTotalExp = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skexp
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl

    local skillType = skillTableData.type
    local color = UIUtils.colorTable["ccUIHeroSkillColor" .. skillType]
    self._skillName:setColor(color)
    self._skillName:setString(lang(skillTableData.name))
    local nameW = self._skillName:getContentSize().width
    self._skillName:setPositionX(nameW>100 and 150 or 130)
    local addLevel = self._attributeValues.skills[index][2]-skillLevel -- 其他地方加成的等级
    self._skillCurrentLevel:setString(skillLevel)
    self._skillCurrentLevel:setPositionX(addLevel>0 and 150 or 170)
    self._skillCurrentLevel_0:setString((addLevel>0 and ("(+".. addLevel ..")") or "" ))
    self._skillCurrentLevel_0:setPositionX(self._skillCurrentLevel:getPositionX()+self._skillCurrentLevel:getContentSize().width+2)
    self._skillCurrentLevel_1:setString("阶")
    self._skillCurrentLevel_1:setPositionX(self._skillCurrentLevel_0:getPositionX()+self._skillCurrentLevel_0:getContentSize().width+2)
    --self._skillCurrentLevelName:setString("阶" .. SKillHurtKindMap[tonumber(skillTableData.hurtkind1)] .. "法术")
    self._imageTagType:loadTexture(string.format("tag_type_%d_hero.png", skillTableData.type), 1)
    self._imageDmgTagType:setVisible(true)
    if skillTableData.dmgtag then
        self._imageDmgTagType:loadTexture(string.format("dmgtag_type_%d_hero.png", skillTableData.dmgtag), 1)
    else
        self._imageDmgTagType:setVisible(false)
    end
    local mcdData = self._attributeValues.MCD
    local mcdAddition = 0
    if skillTableData.type > 1 then
        mcdAddition = (1 - mcdData[skillTableData.mgtype][skillTableData.type - 1] - mcdData[skillTableData.mgtype][5] - mcdData[4][skillTableData.type - 1] - mcdData[4][5])
    else
        mcdAddition = (1 - mcdData[skillTableData.mgtype][5] - mcdData[4][5])
    end
    --self._skillManaValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    --self._skillManaValue:setString(tostring(math.floor((skillTableData.manacost[1] - (skillLevel-1) * skillTableData.manacost[2]) * mcdAddition)))
    local spTalent = self._skillTalentModel:getTalentDataInFormat()
    local value = self._skillTalentModel:getTalentAdd(skillId,spTalent)
    local manaValueW = (string.format("%.1f", skillTableData.manacost[1] - (skillLevel + addLevel - 1) * skillTableData.manacost[2]) * mcdAddition - value["$talent9"] - value["$talent10"]*skillTableData.manacost[1])
    manaValueW = string.format("%.2f",manaValueW*0.1)
    manaValueW = manaValueW*10

    self._skillManaValue:setString(manaValueW)
    self._skillManaValue:setColor((mcdAddition < 1 or isReplaced or (value["$talent9"] + value["$talent10"]*skillTableData.manacost[1]) ~= 0) and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    self._imageUnderline2:setVisible((mcdAddition < 1 or isReplaced or (value["$talent9"] + value["$talent10"]*skillTableData.manacost[1]) ~= 0))

    local cdData = self._attributeValues.cd
    local cdAddition = 0
    if skillTableData.type > 1 then
        cdAddition = (1 - cdData[skillTableData.mgtype][skillTableData.type - 1] - cdData[skillTableData.mgtype][5] - cdData[4][skillTableData.type - 1] - cdData[4][5])
    else
        cdAddition = (1 - cdData[skillTableData.mgtype][5] - cdData[4][5])
    end

    --self._skillCDValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local spTalent = self._skillTalentModel:getTalentDataInFormat()
    local value = self._skillTalentModel:getTalentAdd(skillId,spTalent)
    local result = (skillTableData.cd[1] - (skillLevel + addLevel - 1)*skillTableData.cd[2]) / 100 / 10 * cdAddition
    local resultNoTalent = result
    result = math.ceil(result - value["$talent11"] - value["$talent12"]*skillTableData.cd[1]/1000)
    self._skillCDValue:setString(result .. "秒")
    self._skillCDValue:setColor((cdAddition < 1 or isReplaced or resultNoTalent ~= result) and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    self._imageUnderline1:setVisible((cdAddition < 1 or isReplaced or resultNoTalent ~= result))
    print("skillLLLLevellll",skillLevel)
    local labelDiscription = self._skillEffectDes
    local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
    local desc = "[color=645252, fontsize=20]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, skillTableData.id, self._attributeValues, index,nil,nil,spTalent) .. "[-]"
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

    if skillLevel < skillMaxLevel then 
        --self._layerEffect:setVisible(true)
        --self._skillTopLevel:setVisible(false)
        --self._skillDesBg2:setVisible(true)
        self._skillDesBg3:setVisible(true)
        self._skillMaxLevel:setVisible(false)
        --[[
        local labelDiscription = self._skillNextLevelEffectDes
        local desc = "[color=4d4d4d, fontsize=18]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, skillTableData.id, self._nextLevelAttributeValues, index) .. "[-]"
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

        --self._skillProgressBar:setPercent(skillCurrentExp / skillCurrentTotalExp * 100)

        local labelDiscription = self._labelEffectDes3
        local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
        local desc = "[color=8a5c1d, fontsize=18]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, skillTableData.id, self._nextLevelAttributeValues, index, "PLAYERSKILLDES2_" .. skillTableData.id,nil,spTalent) .. "[-]"
        local richText = labelDiscription:getChildByName("descRichText")
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
        richText:formatText()
        richText:enablePrinter(true)
        richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height/2 )
        richText:setName("descRichText")
        labelDiscription:addChild(richText)
        UIUtils:alignRichText(richText,{hAlign="left"})

        local scaleX = (self._skillProgressBar:getContentSize().width-skillCurrentTotalExp) / skillCurrentTotalExp / self._proNormal:getContentSize().width
        self._skillProgressBar:removeAllChildren()
        for i=1, skillCurrentTotalExp do
            if i <= skillCurrentExp then
                local imageNormal = self._proNormal:clone()
                imageNormal:setVisible(true)
                imageNormal:setScaleX(scaleX)
                imageNormal:setName("imageNormal" .. i)
                imageNormal:setPosition(imageNormal:getBoundingBox().width * (i - 1)+i-1, self._skillProgressBar:getContentSize().height / 2)
                self._skillProgressBar:addChild(imageNormal, 10)
                if self._skillRate and i> skillCurrentExp-self._skillRate then
                    if i~= skillCurrentTotalExp then
                        local increaseMc = mcMgr:createViewMC("yige_herospellstudyanim", false, true)
                        increaseMc:setAnchorPoint(cc.p(0,1))
                        increaseMc:setScaleX(scaleX)
                        increaseMc:setPosition(imageNormal:getBoundingBox().width * (i - 0.5)+i-1, self._skillProgressBar:getContentSize().height / 2)
                        self._skillProgressBar:addChild(increaseMc,99)
                    end
                end
            end
            local imageGray = self._proGray:clone()
            imageGray:setVisible(true)
            imageGray:setScaleX(scaleX)
            imageGray:setName("imageGray" .. i)
            imageGray:setPosition(imageGray:getContentSize().width*scaleX * (i - 1)+i-1, self._skillProgressBar:getContentSize().height / 2)
            self._skillProgressBar:addChild(imageGray, 9)
        end

        self._proLabel:setString(string.format("%d/%d", skillCurrentExp, skillCurrentTotalExp))

        self._skillStudyGoldValue:setColor(cc.c3b(255, 255, 255))
        self._skillStudyToolValue:setColor(cc.c3b(255, 255, 255))
        self._skillBtnStudy._tip = nil
        local skcost
        if index == 4 then
            skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost2
        elseif index == 5 then
            skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost3
        else
            skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost
        end
        for k, v in pairs(skcost) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
                if consume > have then
                    self._skillStudyToolValue:setColor(cc.c3b(255, 30, 30))
                    self._image_add:setVisible(true)
                    self._skillBtnStudy._tip = lang("TIPS_SPELLUP_TOOL")
                else
                    self._skillStudyToolValue:setColor(cc.c3b(28, 162, 22))
                    self._image_add:setVisible(false)
                end
                --self._skillStudyLayerToolGet:setVisible(consume > have)
                self._skillStudyLayerToolGet:setVisible(true)
                local icon = self._skillStudyLayerTool:getChildByName("itemIcon") 
                if not icon then
                    icon = IconUtils:createItemIconById({itemId = v[2],eventStyle = 3,clickCallback = function( ) end})
                    icon:setPosition(cc.p(-15, -10))
                    icon:setName("itemIcon")
                    self._skillStudyLayerTool:addChild(icon)
                else
                    IconUtils:updateItemIconByView(self._skillStudyLayerTool, {itemId = v[2]})
                end
                self._skillStudyToolValue:setString(string.format("%d/%d",  have,consume))
            elseif "gold" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().gold
                if consume > have then
                    self._skillStudyGoldValue:setColor(cc.c3b(255, 30, 30))
                    self._image_add:setVisible(true)
                    self._skillBtnStudy._tip = lang("TIPS_SPELLUP_GOLD")
                else
                    self._skillStudyGoldValue:setColor(cc.c3b(28, 162, 22))
                    self._image_add:setVisible(false)
                end
                self._skillStudyGoldValue:setString(consume)
            elseif "gem" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().freeGem
            end
        end

        local levelLimited = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).lvlim[index]
        --[[
        self._skillStudyImageGlod:setVisible(userLevel >= levelLimited)
        self._skillStudyGoldValue:setVisible(userLevel >= levelLimited)
        ]]
        -- self._skillStudyLayerTool:setVisible(userLevel >= levelLimited)
        -- self._skillStudyToolValue:setVisible(userLevel >= levelLimited)
        
        self._skillStudyLevelLimited:setVisible(userLevel < levelLimited)
        self._skillStudyLevelLimited:setString("需要玩家等级" .. levelLimited .. "级")
        local ok = true
        local ok10 = true
        for k, v in pairs(skcost) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
            elseif "gold" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().gold
            elseif "gem" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().freeGem
            end
            if consume > have then
                ok = false
                break
            end
        end

        for k, v in pairs(skcost) do
            local have, consume10 = 0, v[3] * 10
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
            elseif "gold" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().gold
            elseif "gem" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().freeGem
            end
            if consume10 > have then
                ok10 = false
                break
            end
        end

        -- self._skillBtnStudy:setEnabled(userLevel >= levelLimited and ok)
        if userLevel < levelLimited then
            self._skillBtnStudy._tip = "需要玩家等级" .. levelLimited .. "级"
        end

        UIUtils:setGray(self._skillBtnStudy, not (userLevel >= levelLimited and ok))
        -- self._skillBtnStudy:setBright(userLevel >= levelLimited  and ok)
        UIUtils:setGray(self._skillBtnStudy10, not (userLevel >= 40 and userLevel >= levelLimited and ok10))

        self._labelEffectDes3:setVisible(true)
        self._skillBtnStudy:setVisible(true)
        self._skillBtnStudy10:setVisible(userLevel >= 36)
        self._skillStudyToolValue:setVisible(true)
        self._skillStudyLayerTool:setVisible(true)
    else
        -- self._skillDesBg2:setVisible(false)
        -- self._skillDesBg3:setVisible(false)
        local scaleX = self._skillProgressBar:getContentSize().width / skillCurrentTotalExp / self._proNormal:getContentSize().width
        self._skillProgressBar:removeAllChildren()
        for i=1, skillCurrentTotalExp do
            -- if i <= skillCurrentTotalExp then
                local imageNormal = self._proNormal:clone()
                imageNormal:setVisible(true)
                imageNormal:setScaleX(scaleX)
                imageNormal:setName("imageNormal" .. i)
                imageNormal:setPosition(imageNormal:getBoundingBox().width * (i - 1), self._skillProgressBar:getContentSize().height / 2)
                self._skillProgressBar:addChild(imageNormal, 10)
            -- end
            local imageGray = self._proGray:clone()
            imageGray:setVisible(true)
            imageGray:setScaleX(scaleX)
            imageGray:setName("imageGray" .. i)
            imageGray:setPosition(imageGray:getContentSize().width*scaleX * (i - 1)+i-1, self._skillProgressBar:getContentSize().height / 2)
            self._skillProgressBar:addChild(imageGray, 9)
        end

        self._proLabel:setString(string.format("%d/%d", skillCurrentTotalExp, skillCurrentTotalExp))

        self._labelEffectDes3:setVisible(false)
        self._skillBtnStudy:setVisible(false)
        self._skillBtnStudy10:setVisible(false)
        self._skillStudyToolValue:setVisible(false)
        self._skillStudyLayerTool:setVisible(false)
        self._skillStudyGoldValue:setVisible(false)
        self._skillStudyImageGlod:setVisible(false)
        self._skillMaxLevel:setVisible(true)
    end
    --[=[
    local index = self._currentSkillIndex or 1
    local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
    local skillTableData = tab:PlayerSkillEffect(self._heroData["spell" .. index])
    local skillData = self._attributeValues.skills
    local skillStage = skillData[index][2]
    local skillLevel = skillData[index][3]
    local skillCurrentExp = self._heroData["se" .. index]
    local skillCurrentTotalExp = tab:PlayerSkillExp(skillLevel).skexp
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl

    self._skillName:setString(lang(skillTableData.name))
    self._skillCurrentLevel:setString(skillLevel)
    self._skillCurrentLevelName:setString("阶" .. SKillHurtKindMap[tonumber(skillTableData.hurtkind1)] .. "法术")
    self._skillManaValue:setColor(0 == skillStage and cc.c4b(255, 122, 15) or cc.c3b(118, 238, 0))
    self._skillManaValue:enableOutline(0 == skillStage and cc.c4b(95, 38, 0, 255) or cc.c4b(0, 78, 0, 255), 2)
    self._skillManaValue:setString(tostring(skillTableData.manacost[1] - skillStage * skillTableData.manacost[2]))
    self._skillCDValue:setColor(0 == skillStage and cc.c3b(255, 122, 15) or cc.c3b(118, 238, 0))
    self._skillCDValue:enableOutline(0 == skillStage and cc.c4b(95, 38, 0, 255) or cc.c4b(0, 78, 0, 255), 2)
    self._skillCDValue:setString(tostring(math.round((skillTableData.cd[1] - skillStage * skillTableData.cd[2]) / 1000)))
    --[[
    self._skillManaImageBg:setContentSize(0 == skillStage and cc.size(40, 25) or cc.size(60, 25))
    self._skillManaValue:setString(tostring(skillTableData.manacost[1]))
    self._skillManaValueAddition:setString(0 == skillStage and "" or string.format("(-%d)", skillStage * skillTableData.manacost[2]))
    self._skillCDImageBg:setContentSize(0 == skillStage and cc.size(60, 25) or cc.size(100, 25))
    self._skillCDValue:setString(tostring(math.round(skillTableData.cd[1] / 1000)))
    self._skillCDValueAddition:setString(0 == skillStage and "" or string.format("(-%d)", math.round(skillStage * skillTableData.cd[2] / 1000)))
    self._labelSecond:setPositionX(0 == skillStage and 75 or 110)
    ]]
    local labelDiscription = self._skillEffectDes
    local desc = "[color=4d4d4d, fontsize=18]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, skillTableData.id, self._attributeValues, index) .. "[-]"
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
    if skillLevel < skillMaxLevel then
        --self._layerEffect:setVisible(true)
        --self._skillTopLevel:setVisible(false)
        self._skillDesBg2:setVisible(true)
        self._skillDesBg3:setVisible(true)
        self._skillMaxLevel:setVisible(false)
        local labelDiscription = self._skillNextLevelEffectDes
        local desc = "[color=4d4d4d, fontsize=18]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, skillTableData.id, self._nextLevelAttributeValues, index) .. "[-]"
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
        self._skillProgressBar:setPercent(skillCurrentExp / skillCurrentTotalExp * 100)

        self._skillStudyGoldValue:setColor(cc.c3b(255, 255, 255))
        self._skillStudyToolValue:setColor(cc.c3b(255, 255, 255))
        local skcost = 5 == index and tab:PlayerSkillExp(skillLevel).skcost2 or tab:PlayerSkillExp(skillLevel).skcost
        for k, v in pairs(skcost) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
                if consume > have then
                    self._skillStudyToolValue:setColor(cc.c3b(255, 0, 0))
                end
                self._skillStudyLayerToolGet:setVisible(consume > have)
                local icon = self._skillStudyLayerTool:getChildByName("itemIcon") 
                if not icon then
                    icon = IconUtils:createItemIconById({itemId = v[2]})
                    icon:setPosition(cc.p(-5, 0))
                    self._skillStudyLayerTool:addChild(icon)
                else
                    IconUtils:updateItemIconByView(self._skillStudyLayerTool, {itemId = v[2]})
                end
                self._skillStudyToolValue:setString(string.format("%d/%d", consume, have))
            elseif "gold" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().gold
                if consume > have then
                    self._skillStudyGoldValue:setColor(cc.c3b(255, 0, 0))
                end
                self._skillStudyGoldValue:setString(consume)
            elseif "gem" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().freeGem
            end
        end

        local levelLimited = tab:PlayerSkillExp(skillLevel + 1).lvlim
        self._skillStudyImageGlod:setVisible(userLevel >= levelLimited)
        self._skillStudyGoldValue:setVisible(userLevel >= levelLimited)
        self._skillStudyLayerTool:setVisible(userLevel >= levelLimited)
        self._skillStudyToolValue:setVisible(userLevel >= levelLimited)
        
        self._skillStudyLevelLimited:setVisible(userLevel < levelLimited)
        self._skillStudyLevelLimited:setString("需要玩家等级" .. levelLimited .. "级")
        local ok = true
        for k, v in pairs(skcost) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
            elseif "gold" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().gold
            elseif "gem" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().freeGem
            end
            if consume > have then
                ok = false
                break
            end
        end

        self._skillBtnStudy:setEnabled(userLevel >= levelLimited and ok)
        self._skillBtnStudy:setBright(userLevel >= levelLimited  and ok)
    else
        self._skillDesBg2:setVisible(false)
        self._skillDesBg3:setVisible(false)
        self._skillMaxLevel:setVisible(true)
    end
    ]=]
end

-- 单独更新法术书槽
function HeroSkillInformationView:updateSlotSkillDetails()
    -- remove skill stage
    if not self._heroData.slot then return end
    local index = self._currentSkillIndex or 1
    local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
    local skillId = self._heroData.slot.sid
    if not skillId or skillId == 0 then
        return
    end
    local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
    if isReplaced then
        skillId = skillReplacedId
    end
    local skillBookD = tab:SkillBookBase(skillId)
    local isMastery = not tab:PlayerSkillEffect(skillId)
    -- 刻印被动技能根据法术书变id
    if isMastery and skillBookD then
        local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(skillId)]
        if tonumber(bookInfo.l) > 1 then
            skillId = tonumber(skillId .. (bookInfo.l-1))
        end
    end
    local skillTableData = tab:PlayerSkillEffect(skillId) or tab:HeroMastery(skillId)
    local skillLevel = self._heroData.slot.s or 1
    local skillCurrentExp = self._heroData.slot.e or 0 --["se" .. index]
    local skillCurrentTotalExp = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skexp
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl

    local skillType = skillTableData.type
    local color = UIUtils.colorTable["ccUIHeroSkillColor" .. skillType]
    self._skillName:setColor(color)
    self._skillName:setString(lang(skillTableData.name))
    local nameW = self._skillName:getContentSize().width
    self._skillName:setPositionX(nameW>90 and 150 or 130)
    local addLevel = 0
    for k,v in pairs(self._attributeValues.skills) do
        local sid = v[1]
        if skillId == sid then
            addLevel = v[2]-skillLevel
            break
        end
    end
    --local addLevel = self._attributeValues.skills[index][2]-skillLevel -- 其他地方加成的等级
    self._skillCurrentLevel:setString(skillLevel)
    self._skillCurrentLevel:setPositionX(addLevel>0 and 150 or 170)
    self._skillCurrentLevel_0:setString((addLevel>0 and ("(+".. addLevel ..")") or "" ))
    self._skillCurrentLevel_0:setPositionX(self._skillCurrentLevel:getPositionX()+self._skillCurrentLevel:getContentSize().width+2)
    self._skillCurrentLevel_1:setString("阶")
    self._skillCurrentLevel_1:setPositionX(self._skillCurrentLevel_0:getPositionX()+self._skillCurrentLevel_0:getContentSize().width+2)
    --self._skillCurrentLevelName:setString("阶" .. SKillHurtKindMap[tonumber(skillTableData.hurtkind1)] .. "法术")
    self._imageTagType:loadTexture(string.format("tag_type_%d_hero.png", skillTableData.type), 1)
    self._imageDmgTagType:setVisible(true)
    if skillTableData.dmgtag then
        self._imageDmgTagType:loadTexture(string.format("dmgtag_type_%d_hero.png", skillTableData.dmgtag), 1)
    else
        self._imageDmgTagType:setVisible(false)
    end
    if not isMastery then
        local mcdData = self._attributeValues.MCD
        local mcdAddition = 0
        if skillTableData.type > 1 then
            mcdAddition = (1 - mcdData[skillTableData.mgtype][skillTableData.type - 1] - mcdData[skillTableData.mgtype][5] - mcdData[4][skillTableData.type - 1] - mcdData[4][5])
        else
            mcdAddition = (1 - mcdData[skillTableData.mgtype][5] - mcdData[4][5])
        end
        --self._skillManaValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        --self._skillManaValue:setString(tostring(math.floor((skillTableData.manacost[1] - (skillLevel-1) * skillTableData.manacost[2]) * mcdAddition)))
        
        local spTalent = self._skillTalentModel:getTalentDataInFormat()
        local value = self._skillTalentModel:getTalentAdd(skillId,spTalent)
        local manaValueW = (string.format("%.1f", skillTableData.manacost[1] - (skillLevel+addLevel-1) * skillTableData.manacost[2]) * mcdAddition - value["$talent9"] - value["$talent10"]*skillTableData.manacost[1])
        manaValueW = string.format("%.2f",manaValueW*0.1)
        manaValueW = manaValueW*10
        self._skillManaValue:setString(manaValueW)
        self._skillManaValue:setColor((mcdAddition < 1 or isReplaced or (value["$talent9"] + value["$talent10"]*skillTableData.manacost[1]) ~= 0) and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
        self._imageUnderline2:setVisible((mcdAddition < 1 or isReplaced or (value["$talent9"] + value["$talent10"]*skillTableData.manacost[1]) ~= 0))

        local cdData = self._attributeValues.cd
        local cdAddition = 0
        if skillTableData.type > 1 then
            cdAddition = (1 - cdData[skillTableData.mgtype][skillTableData.type - 1] - cdData[skillTableData.mgtype][5] - cdData[4][skillTableData.type - 1] - cdData[4][5])
        else
            cdAddition = (1 - cdData[skillTableData.mgtype][5] - cdData[4][5])
        end

        --self._skillCDValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        local spTalent = self._skillTalentModel:getTalentDataInFormat()
        local value = self._skillTalentModel:getTalentAdd(skillId,spTalent)
        local result = (skillTableData.cd[1] - (skillLevel-1)*skillTableData.cd[2]) / 100 / 10 * cdAddition
        local resultNotalent = result
        result = math.ceil(result - value["$talent11"] - value["$talent12"]*skillTableData.cd[1]/1000)
        self._skillCDValue:setString( result .. "秒")
        self._skillCDValue:setColor((cdAddition < 1 or isReplaced or resultNotalent ~= result) and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
        self._imageUnderline1:setVisible((cdAddition < 1 or isReplaced or resultNotalent ~= result))
    else
        self._skillManaValue:setString("无")
        self._skillManaValue:setColor(cc.c3b(138, 92, 29))
        self._imageUnderline2:setVisible(false)
        self._skillCDValue:setString("无")
        self._skillCDValue:setColor(cc.c3b(138, 92, 29))
        self._imageUnderline1:setVisible(false)
    end
    print("skillLLLLevellll",skillLevel)
    local artifactlv = 1
        if self._heroData.slot then
            local skillId = self._heroData.slot and self._heroData.slot.sid
            local skillInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(skillId)]
            artifactlv = skillInfo and skillInfo.l
        end
    local attributeValues = clone(self._attributeValues)
    attributeValues.sklevel = skillLevel+addLevel
    attributeValues.artifactlv = artifactlv
    local labelDiscription = self._skillEffectDes
    local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
    local desc = "[color=645252, fontsize=20]" .. BattleUtils.getDescription(isMastery and BattleUtils.kIconTypeHeroMastery or BattleUtils.kIconTypeSkill, skillTableData.id, attributeValues, index,nil,nil,spTalent) .. "[-]"
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

    if skillLevel < skillMaxLevel then 
        self._skillDesBg3:setVisible(true)
        self._skillMaxLevel:setVisible(false)
        local labelDiscription = self._labelEffectDes3
        local nextLevelAttributeValues = clone(self._nextLevelAttributeValues)
        nextLevelAttributeValues.sklevel = skillLevel+1
        
        nextLevelAttributeValues.artifactlv = artifactlv
        local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
        local desc = "[color=8a5c1d, fontsize=18]" .. BattleUtils.getDescription(isMastery and BattleUtils.kIconTypeHeroMastery or BattleUtils.kIconTypeSkill, skillTableData.id, nextLevelAttributeValues, index, (isMastery and "HEROMASTERYDES2_" or "PLAYERSKILLDES2_") .. skillTableData.id,nil,spTalent) .. "[-]"
        local richText = labelDiscription:getChildByName("descRichText")
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
        richText:formatText()
        richText:enablePrinter(true)
        richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height/2 )
        richText:setName("descRichText")
        labelDiscription:addChild(richText)
        UIUtils:alignRichText(richText,{hAlign="left"})

        local scaleX = (self._skillProgressBar:getContentSize().width-skillCurrentTotalExp) / skillCurrentTotalExp / self._proNormal:getContentSize().width
        self._skillProgressBar:removeAllChildren()
        for i=1, skillCurrentTotalExp do
            if i <= skillCurrentExp then
                local imageNormal = self._proNormal:clone()
                imageNormal:setVisible(true)
                imageNormal:setScaleX(scaleX)
                imageNormal:setName("imageNormal" .. i)
                imageNormal:setPosition(imageNormal:getBoundingBox().width * (i - 1)+i-1, self._skillProgressBar:getContentSize().height / 2)
                self._skillProgressBar:addChild(imageNormal, 10)
                if self._skillRate and i> skillCurrentExp-self._skillRate then
                    if i~= skillCurrentTotalExp then
                        local increaseMc = mcMgr:createViewMC("yige_herospellstudyanim", false, true)
                        increaseMc:setAnchorPoint(cc.p(0,1))
                        increaseMc:setScaleX(scaleX)
                        increaseMc:setPosition(imageNormal:getBoundingBox().width * (i - 0.5)+i-1, self._skillProgressBar:getContentSize().height / 2)
                        self._skillProgressBar:addChild(increaseMc,99)
                    end
                end
            end
            local imageGray = self._proGray:clone()
            imageGray:setVisible(true)
            imageGray:setScaleX(scaleX)
            imageGray:setName("imageGray" .. i)
            imageGray:setPosition(imageGray:getContentSize().width*scaleX * (i - 1)+i-1, self._skillProgressBar:getContentSize().height / 2)
            self._skillProgressBar:addChild(imageGray, 9)
        end

        self._proLabel:setString(string.format("%d/%d", skillCurrentExp, skillCurrentTotalExp))

        self._skillStudyGoldValue:setColor(cc.c3b(255, 255, 255))
        self._skillStudyToolValue:setColor(cc.c3b(255, 255, 255))
        self._skillBtnStudy._tip = nil
        local skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost3 --or tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost
        for k, v in pairs(skcost) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
                if consume > have then
                    self._skillStudyToolValue:setColor(cc.c3b(255, 30, 30))
                    self._image_add:setVisible(true)
                    self._skillBtnStudy._tip = lang("TIPS_SPELLUP_TOOL")
                else
                    self._skillStudyToolValue:setColor(cc.c3b(28, 162, 22))
                    self._image_add:setVisible(false)
                end
                --self._skillStudyLayerToolGet:setVisible(consume > have)
                self._skillStudyLayerToolGet:setVisible(true)
                local icon = self._skillStudyLayerTool:getChildByName("itemIcon") 
                if not icon then
                    icon = IconUtils:createItemIconById({itemId = v[2],eventStyle = 3,clickCallback = function( ) end})
                    icon:setPosition(cc.p(-15, -10))
                    icon:setName("itemIcon")
                    self._skillStudyLayerTool:addChild(icon)
                else
                    IconUtils:updateItemIconByView(self._skillStudyLayerTool, {itemId = v[2]})
                end
                self._skillStudyToolValue:setString(string.format("%d/%d",  have,consume))
            elseif "gold" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().gold
                if consume > have then
                    self._skillStudyGoldValue:setColor(cc.c3b(255, 30, 30))
                    self._image_add:setVisible(true)
                    self._skillBtnStudy._tip = lang("TIPS_SPELLUP_GOLD")
                else
                    self._skillStudyGoldValue:setColor(cc.c3b(28, 162, 22))
                    self._image_add:setVisible(false)
                end
                self._skillStudyGoldValue:setString(consume)
            elseif "gem" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().freeGem
            end
        end

        local levelLimited = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).lvlim[index]
        --[[
        self._skillStudyImageGlod:setVisible(userLevel >= levelLimited)
        self._skillStudyGoldValue:setVisible(userLevel >= levelLimited)
        ]]
        -- self._skillStudyLayerTool:setVisible(userLevel >= levelLimited)
        -- self._skillStudyToolValue:setVisible(userLevel >= levelLimited)
        
        self._skillStudyLevelLimited:setVisible(userLevel < levelLimited)
        self._skillStudyLevelLimited:setString("需要玩家等级" .. levelLimited .. "级")
        local ok = true
        local ok10 = true
        for k, v in pairs(skcost) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
            elseif "gold" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().gold
            elseif "gem" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().freeGem
            end
            if consume > have then
                ok = false
                break
            end
        end

        for k, v in pairs(skcost) do
            local have, consume10 = 0, v[3] * 10
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
            elseif "gold" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().gold
            elseif "gem" == v[1] then
                have = self._modelMgr:getModel("UserModel"):getData().freeGem
            end
            if consume10 > have then
                ok10 = false
                break
            end
        end

        -- self._skillBtnStudy:setEnabled(userLevel >= levelLimited and ok)
        if userLevel < levelLimited then
            self._skillBtnStudy._tip = "需要玩家等级" .. levelLimited .. "级"
        end

        UIUtils:setGray(self._skillBtnStudy, not (userLevel >= levelLimited and ok))
        -- self._skillBtnStudy:setBright(userLevel >= levelLimited  and ok)
        UIUtils:setGray(self._skillBtnStudy10, not (userLevel >= 40 and userLevel >= levelLimited and ok10))

        self._labelEffectDes3:setVisible(true)
        self._skillBtnStudy:setVisible(true)
        self._skillBtnStudy10:setVisible(userLevel >= 36)
        self._skillStudyToolValue:setVisible(true)
        self._skillStudyLayerTool:setVisible(true)
    else
        -- self._skillDesBg2:setVisible(false)
        -- self._skillDesBg3:setVisible(false)
        local scaleX = self._skillProgressBar:getContentSize().width / skillCurrentTotalExp / self._proNormal:getContentSize().width
        self._skillProgressBar:removeAllChildren()
        for i=1, skillCurrentTotalExp do
            -- if i <= skillCurrentTotalExp then
                local imageNormal = self._proNormal:clone()
                imageNormal:setVisible(true)
                imageNormal:setScaleX(scaleX)
                imageNormal:setName("imageNormal" .. i)
                imageNormal:setPosition(imageNormal:getBoundingBox().width * (i - 1), self._skillProgressBar:getContentSize().height / 2)
                self._skillProgressBar:addChild(imageNormal, 10)
            -- end
            local imageGray = self._proGray:clone()
            imageGray:setVisible(true)
            imageGray:setScaleX(scaleX)
            imageGray:setName("imageGray" .. i)
            imageGray:setPosition(imageGray:getContentSize().width*scaleX * (i - 1)+i-1, self._skillProgressBar:getContentSize().height / 2)
            self._skillProgressBar:addChild(imageGray, 9)
        end

        self._proLabel:setString(string.format("%d/%d", skillCurrentTotalExp, skillCurrentTotalExp))

        self._labelEffectDes3:setVisible(false)
        self._skillBtnStudy:setVisible(false)
        self._skillBtnStudy10:setVisible(false)
        self._skillStudyToolValue:setVisible(false)
        self._skillStudyLayerTool:setVisible(false)
        self._skillStudyGoldValue:setVisible(false)
        self._skillStudyImageGlod:setVisible(false)
        self._skillMaxLevel:setVisible(true)
    end

end

function HeroSkillInformationView:updateStudyRateEffect(rate, isUpgrade, isStudy10, oldLevel, newLevel, callback)
    local index = self._currentSkillIndex or 1
    rate = tonumber(rate)
    print("updateStudyRateEffect", rate)
    if not rate or 0 == rate then return end
    local fileName = nil
    local studyMC = nil
    if 2 == rate then
        studyMC = self._studyMC2
    elseif 5 == rate then
        studyMC = self._studyMC5
    elseif 10 == rate then
        studyMC = self._studyMC10
    end
    --[[
    if studyMC then
        studyMC:retain()
        studyMC:removeFromParentAndCleanup()
        studyMC:setVisible(true)
        self._skillProgressBarFrame:addChild(studyMC, 100)
        studyMC:release()
        studyMC:addEndCallback(function()
            studyMC:stop()
            studyMC:setVisible(false)
        end)
        studyMC:gotoAndPlay(0)
        studyMC:setPosition(cc.p(self._skillProgressBarFrame:getContentSize().width / 2, self._skillProgressBarFrame:getContentSize().height + 20))

        local studyText = ccui.Text:create()
        studyText:setFontSize(14)
        studyText:setFontName(UIUtils.ttfName_Title)
        studyText:setString("精修进度+" .. rate)
        studyText:setColor(cc.c4b(255, 46, 46, 255))
        studyText:enableOutline(cc.c4b(81, 19, 0, 255), 2)
        studyText:setPosition(cc.p(self._skillProgressBarFrame:getContentSize().width / 2, self._skillProgressBarFrame:getContentSize().height / 1.3))
        self._skillProgressBarFrame:addChild(studyText)
        studyText:setScale(2)
        studyText:runAction(cc.Sequence:create({cc.EaseOut:create(cc.ScaleTo:create(0.1, 0.9), 3), cc.FadeOut:create(0.25), cc.CallFunc:create(function()
            studyText:removeFromParent()
        end)}))
    else
        local studyText = ccui.Text:create()
        studyText:setFontSize(14)
        studyText:setFontName(UIUtils.ttfName_Title)
        studyText:setString("精修进度+" .. rate)
        studyText:setColor(cc.c4b(255, 46, 46, 255))
        studyText:enableOutline(cc.c4b(81, 19, 0, 255), 2)
        studyText:setPosition(cc.p(self._skillProgressBarFrame:getContentSize().width - 30, self._skillProgressBarFrame:getContentSize().height - 10))
        self._skillProgressBarFrame:addChild(studyText)
        studyText:runAction(cc.Sequence:create({cc.Spawn:create({cc.EaseOut:create(cc.MoveBy:create(0.4, cc.p(0, 15)), 3), cc.FadeOut:create(0.4)}), cc.CallFunc:create(function()
            studyText:removeFromParent()
        end)}))
    end
    ]]

    if studyMC then
        studyMC:retain()
        studyMC:removeFromParentAndCleanup()
        studyMC:setVisible(true)
        self._skillProgressBarFrame:addChild(studyMC, 100)
        studyMC:release()
        studyMC:addEndCallback(function()
            studyMC:stop()
            studyMC:setVisible(false)
        end)
        studyMC:gotoAndPlay(0)
        studyMC:setPosition(cc.p(self._skillProgressBarFrame:getContentSize().width / 2, self._skillProgressBarFrame:getContentSize().height + 20))

    end

    local studyText = ccui.Text:create()
    studyText:setFontSize(14)
    studyText:setFontName(UIUtils.ttfName_Title)
    studyText:setString("突破进度+" .. rate)
    studyText:setColor(cc.c4b(255, 46, 46, 255))
    studyText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    studyText:setPosition(cc.p(self._skillProgressBarFrame:getContentSize().width - 30, self._skillProgressBarFrame:getContentSize().height - 10))
    self._skillProgressBarFrame:addChild(studyText,999)
    studyText:runAction(cc.Sequence:create({cc.Spawn:create({cc.EaseOut:create(cc.MoveBy:create(0.9, cc.p(0, 15)), 3), cc.FadeOut:create(0.9)}), cc.CallFunc:create(function()
        studyText:removeFromParent()
    end)}))

    --[[
    local skillData = self._attributeValues.skills
    local skillLevel = self._heroData["sl" .. index]
    local skillCurrentExp = self._heroData["se" .. index]
    -- local skillCurrentTotalExp = tab:PlayerSkillExp(math.min(,skillLevel)).skexp
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
    -- local levelLimited = tab:PlayerSkillExp(skillLevel + 1).lvlim
    ]]
    if isUpgrade then
        self._viewMgr:lock(-1) -- 加锁，防止弹窗期间点击事件 
        local index = self._currentSkillIndex or 1
        local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
        local skillId = self._heroData.spell[index]
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local skillTableData = tab:PlayerSkillEffect(skillId)
        local skillData = self._attributeValues.skills
        local skillLevel = self._heroData["sl" .. index]
        if index == 5 then
            skillLevel = self._heroData.slot and self._heroData.slot.s or 1
        end
        local skillCurrentExp = self._heroData["se" .. index]
        local skillCurrentTotalExp = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skexp
        local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
        local scaleX = self._skillProgressBar:getContentSize().width / skillCurrentTotalExp / self._proNormal:getContentSize().width
        self._skillProgressBar:removeAllChildren()
        for i=1, skillCurrentTotalExp do
            -- if i <= skillCurrentTotalExp then
                local imageNormal = self._proNormal:clone()
                imageNormal:setVisible(true)
                imageNormal:setScaleX(scaleX)
                imageNormal:setName("imageNormal" .. i)
                imageNormal:setPosition(imageNormal:getBoundingBox().width * (i - 1), self._skillProgressBar:getContentSize().height / 2)
                self._skillProgressBar:addChild(imageNormal, 10)
            -- end
            local imageGray = self._proGray:clone()
            imageGray:setVisible(true)
            imageGray:setScaleX(scaleX)
            imageGray:setName("imageGray" .. i)
            imageGray:setPosition(imageGray:getContentSize().width*scaleX * (i - 1)+i-1, self._skillProgressBar:getContentSize().height / 2)
            self._skillProgressBar:addChild(imageGray, 9)
        end
        local increaseMc = mcMgr:createViewMC("tiaomanzhuangtai_herospellstudyanim", false, true)
        increaseMc:gotoAndPlay(0)
        -- increaseMc:setPlaySpeed(5)
        increaseMc:setPosition(self._skillProgressBarFrame:getContentSize().width / 2, self._skillProgressBarFrame:getContentSize().height / 2)
        self._skillProgressBarFrame:addChild(increaseMc,99)
        local tempCur = clone(self._attributeValues)
        local tempNext = nil
        if isStudy10 then
            tempNext = clone(self._nextLevelAttributeValues10)
        else
            tempNext = clone(self._nextLevelAttributeValues)
        end
        ScheduleMgr:delayCall(600, self, function()
            -- self._studyUpgrade1:retain()
            -- self._studyUpgrade1:removeFromParentAndCleanup()
            -- self._studyUpgrade1:setVisible(true)
            -- self._skillProgressBarFrame:addChild(self._studyUpgrade1, 100)
            -- self._studyUpgrade1:release()
            -- self._studyUpgrade1:addEndCallback(function()
                -- self._studyUpgrade1:stop()
                -- self._studyUpgrade1:setVisible(false)
            -- end)
            -- self._studyUpgrade1:gotoAndPlay(0)
            -- self._studyUpgrade1:setPosition(cc.p(self._skillProgressBarFrame:getContentSize().width / 4, self._skillProgressBarFrame:getContentSize().height * 4))
            if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                self._container:showTopInfo(false)
            end
            ViewManager:getInstance():showDialog("hero.HeroSkillStudyResultView", {heroData = self._heroData, skillIndex = index, currentLevelAttributeValues = tempCur, nextLevelAttributeValues = tempNext, oldLevel = oldLevel, newLevel = newLevel, callback=callback}, true)
            -- self._skillBtnStudy:setEnabled(false)
            self._viewMgr:unlock()
        end)
    end
    --[[
    self._studyUpgrade2:retain()
    self._studyUpgrade2:removeFromParentAndCleanup()
    self._studyUpgrade2:setVisible(true)
    self._skillProgressBarFrame:addChild(self._studyUpgrade2, 100)
    self._studyUpgrade2:release()
    self._studyUpgrade2:addEndCallback(function()
        self._studyUpgrade2:stop()
        self._studyUpgrade2:setVisible(false)
    end)
    self._studyUpgrade2:gotoAndPlay(0)
    self._studyUpgrade2:setPosition(self._skillProgressBar:getChildByName("imageGray" .. skillCurrentExp):getPosition())
    ]]
    --[[
    local sprite = cc.Sprite:createWithSpriteFrameName(fileName)
    sprite:setPosition(cc.p(self._skillProgressBarFrame:getContentSize().width, self._skillProgressBarFrame:getContentSize().height + 20))
    sprite:setOpacity(0)
    sprite:runAction(cc.Sequence:create({cc.Spawn:create({cc.MoveBy:create(0.7, cc.p(0, 40)), cc.FadeIn:create(0.7)}), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        sprite:removeFromParentAndCleanup()
    end)}))
    self._skillProgressBarFrame:addChild(sprite)
    ]]
end

function HeroSkillInformationView:updateHeroSkillInformation( heroData )
    if not heroData and not self._heroData then return end
    -- 特做加skillex
    local sid = self._heroData.slot 
        and self._heroData.slot.sid 
        or 0
    if tonumber(sid) ~= 0 then
        local bookId = tonumber(sid)
        local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(bookId)]
        if bookInfo then
            self._heroData.skillex = {self._heroData.slot.sid, self._heroData.slot.s, bookInfo.l}
        else
            self._heroData.skillex = nil
        end
    else
        self._heroData.skillex = nil
    end
    self._attributeValues = BattleUtils.getHeroAttributes(self._heroData)
    self._nextLevelAttributeValues = BattleUtils.getHeroAttributes(self._heroData, true)
    self._nextLevelAttributeValues10 = BattleUtils.getHeroAttributes(self._heroData, true)
    self:updateUI(self._currentSkillIndex, true)
    self:updateSpellBookSlot()
    --self:onEquipmentButtonClicked() -- version 3.0
end

function HeroSkillInformationView:updateUI(index, force)
    if index == self._currentSkillIndex and not force then return end
    if index ~= 5 then
        self._currentSkillIndex = index
        skillDefaultIndex = index
        self:updateSkillIcon()
        self:updateSkillDetails()
    else
        -- todo 单独刷新法术书槽
        -- [[
        self._currentSkillIndex = index
        skillDefaultIndex = index
        self:updateSpellBookSlot(function( )
            -- self:updateSkillIcon()
        end)
        self:updateSlotSkillDetails()
        --]]
    end
    self._slotExDes:setVisible(index == 5)
end

-- 更新法术书槽

function HeroSkillInformationView:detectIsSlotOpen( )
    local isOpen = false
    local isCanOpen = false
    local isFixed = false
    local canOpenSlot,isShow,openLvl = SystemUtils:enableSkillBook()
    self._bookSlot:setVisible(isShow)
    print("canOpenSlot,isShow,openLvl",canOpenSlot,isShow,openLvl)
    local star = self._heroData.star or 1
    local needStar = tab.setting["SKILLBOOK_LV"] and tab.setting["SKILLBOOK_LV"].value
    local isStarOk = star >= needStar

    isCanOpen = isStarOk and canOpenSlot
    if not canOpenSlot then
        self._notOpenSlotDes = lang("TIP_SkillBook") --openLvl .. "级解锁"
    elseif not isStarOk then
        self._notOpenSlotDes = lang("TIP_SkillBook2") --"英雄四星解锁"
    end
    if self._heroData and self._heroData.slot then
        isOpen = self._heroData.slot ~= nil or self._heroData.slot.sid == 0
        isFixed = isOpen and self._heroData.slot.sid ~= nil and self._heroData.slot.sid ~= 0
    end
    local isActived = SystemUtils.loadAccountLocalData("heroSlot_opened" .. self._heroData.id)
    isOpen = isOpen or isActived
    return isFixed,isOpen,isCanOpen
end

function HeroSkillInformationView:updateSpellBookSlot(fixedCallback )
    if not self._heroData then return end
    local isFixed,isOpen,isCanOpen = self:detectIsSlotOpen()
    self:updateSlot(isFixed,isOpen,isCanOpen)
    if isFixed then
        if fixedCallback then fixedCallback() end
    elseif isCanOpen then
        
    end
    
end

function HeroSkillInformationView:updateSlot( isFixed,isOpen,isCanOpen )
    print("isFixed,isOpen,isCanOpen",isFixed,isOpen,isCanOpen)
    local slot = self._heroData.slot 
    local spellSlot = self._bookSlot 
    local image_unlock = spellSlot.skill_icon_touch:getChildByName("image_unlock")
    local darkBg = spellSlot:getChildByName("darkBg")
    darkBg:setHue(100)
    local lock = image_unlock:getChildByName("lock")
    local add = image_unlock:getChildByName("add")
    if not add._anim then
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.5, 0.9), cc.ScaleTo:create(0.5, 1))
        add:runAction(cc.RepeatForever:create(seq))
        add._anim = true 
    end        
    local changeBtn = spellSlot:getChildByFullName("changeBtn")
    local numLab = spellSlot:getChildByFullName("numLab")
    local numBg = spellSlot:getChildByFullName("numBg")

    image_unlock:setVisible(not isFixed)
    changeBtn:setVisible(isFixed)
    numLab:setVisible(isFixed)
    numBg:setVisible(isFixed)
    
    lock:setVisible(not isFixed and not isOpen)
    add:setVisible(not isFixed and isOpen)
    spellSlot.textures[0]:setVisible(not isFixed)
        
    local icon = spellSlot.skill_icon_touch:getChildByName("skillIcon")
    if isFixed then 
        local skillId = self._heroData.slot and self._heroData.slot.sid
        local skillInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(skillId)]
        local slotLvl = skillInfo and skillInfo.l
        numLab:setString(slotLvl)
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end
        local level = self._heroData.slot and self._heroData.slot.s -- skillInfo and skillInfo.l or 1
        local skillData = tab:PlayerSkillEffect(skillId) or tab:HeroMastery(skillId) -- tab:SkillBookBase(skillId)
        if not icon then
            icon = ccui.ImageView:create()
            icon:setName("skillIcon")
            --cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png")
            --icon:setScale(0.85)
            icon:setPosition(spellSlot.skill_icon_touch:getContentSize().width / 2, spellSlot.skill_icon_touch:getContentSize().height / 2-10)
            spellSlot.icon = icon
            spellSlot.skill_icon_touch:addChild(icon)
        end

        --add  by wangyan
        local sysSkillData = tab.skillBookBase[skillId]
        local imgRes = {"skill_bg_fire01_hero", "skill_bg_water01_hero", "skill_bg_wind01_hero", "skill_bg_soil01_hero"}
        local iconList = {spellSlot._imageFire, spellSlot._imageWater, spellSlot._imageWind, spellSlot._imageSoil}
        if sysSkillData and sysSkillData["type"] == 4 then
            for i=1, 4 do
                iconList[i]:loadTexture(imgRes[i] .. ".png", 1)
            end
        end

        icon:loadTexture(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png",1)
        icon:setVisible(true)
        local skillType = skillData.type
        local color = UIUtils.colorTable["ccUIHeroSkillColor" .. skillType]
        spellSlot._labelSkillName:setColor(color)
        spellSlot._labelSkillName:setString(lang(skillData.name))
        -- spellSlot._labelSkillLevel:setColor(color)
        spellSlot._imageFire:setVisible(skillType == 2)
        spellSlot._imageWater:setVisible(skillType == 3)
        spellSlot._imageWind:setVisible(skillType == 4)
        spellSlot._imageSoil:setVisible(skillType == 5)
        spellSlot._labelSkillLevel:setString(level .. "阶")
        -- 刷图标
        local index = self._currentSkillIndex or 1
        if self._skillSelectedMC and index == 5 then
            self._skillSelectedMC:setVisible(true)
            self._skillSelectedMC:retain()
            self._skillSelectedMC:removeFromParentAndCleanup()
            self._skillSelectedMC:setPosition(cc.p(spellSlot.skill_icon_touch:getContentSize().width / 2, spellSlot.skill_icon_touch:getContentSize().height / 2-10))
            spellSlot.skill_icon_touch:addChild(self._skillSelectedMC, 10)
            self._skillSelectedMC:release()
        end
        local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
        local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
        local function updateUpArrow( node,skillLevel,i )
            node._imageUpgrade:stopAllActions()
            if skillLevel < skillMaxLevel then 
                local levelLimited = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).lvlim[i]
                local ok = true
                local skcost
                if i == 4 then
                    skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost2
                elseif i == 5 then
                    skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost3
                else
                    skcost = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost
                end
                for k, v in pairs(skcost) do
                    local have, consume = 0, v[3]
                    if "tool" == v[1] then
                        local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                        have = toolNum
                    elseif "gold" == v[1] then
                        have = self._modelMgr:getModel("UserModel"):getData().gold
                    elseif "gem" == v[1] then
                        have = self._modelMgr:getModel("UserModel"):getData().freeGem
                    end
                    if consume > have then
                        ok = false
                        break
                    end
                end
                if ok and userLevel >= levelLimited then
                    node._imageUpgrade:setVisible(true)
                    local moveUp = cc.MoveTo:create(0.4, cc.p(70, 20))
                    local moveDown = cc.MoveTo:create(0.4, cc.p(70, 14))
                    node._imageUpgrade:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
                else
                    node._imageUpgrade:setVisible(false)
                end
            else
                node._imageUpgrade:setVisible(false)
            end
        end
        -- for i = 1, HeroSkillInformationView.kSkillCount do
        --     local skillLevel = self._heroData["sl" .. i]
        --     updateUpArrow(self._skills[i],skillLevel,i)
        -- end
        updateUpArrow(spellSlot,self._heroData.slot and self._heroData.slot.s or 1,5)

        spellSlot._labelSkillNone:setVisible(false)
        spellSlot._labelSkillName:setVisible(true)
        spellSlot._labelSkillLevel:setVisible(true)
        UIUtils:center2Widget(self._bookSlot._labelSkillName,self._bookSlot._labelSkillLevel,35,5)
        local isNotDig = SystemUtils.loadAccountLocalData("heroSlot_diged" .. self._heroData.id)
        if not isNotDig then
            SystemUtils.saveAccountLocalData("heroSlot_diged" .. self._heroData.id,true)
        end
        -- 开孔后判断刻印法术书
        local isNotDig = SystemUtils.loadAccountLocalData("heroSlot_unlock" .. self._heroData.id)
        if not isNotDig then
            SystemUtils.saveAccountLocalData("heroSlot_unlock" .. self._heroData.id,true) 
        end        
        if spellSlot._todigguid then
            spellSlot._todigguid:setVisible(false) 
        end
    else
        spellSlot._imageFire:setVisible(false)
        spellSlot._imageWater:setVisible(false)
        spellSlot._imageWind:setVisible(false)
        spellSlot._imageSoil:setVisible(false)
        spellSlot._imageUpgrade:setVisible(false)
        if icon then 
            icon:setVisible(false)
        end
        spellSlot._labelSkillNone:setVisible(true)
        spellSlot._labelSkillName:setVisible(false)
        spellSlot._labelSkillLevel:setVisible(false)
        if isOpen then
            local openDes = ""
            if self._heroData.slot then
                local na = self._heroData.slot.na
                if na and self._heroData.slot.s and self._heroData.slot.s > 1 then
                    local naMap = {3,1,2,4,5}
                    openDes = ""-- lang("SKILLBOOK_TIPS10" .. naMap[na])  .. "刻印孔 " 
                                    --.. self._heroData.slot.s .. "阶"
                    self._bookSlot._labelSkillName:setString(lang("SKILLBOOK_TIPS10" .. naMap[na])  .. "刻印孔")
                    self._bookSlot._labelSkillLevel:setString(self._heroData.slot.s .. "阶")
                    self._bookSlot._labelSkillName:setVisible(true)
                    self._bookSlot._labelSkillLevel:setVisible(true)
                    local colorMap = {2,3,4,5,1}
                    local color = UIUtils.colorTable["ccUIHeroSkillColor" .. colorMap[na]]
                    self._bookSlot._labelSkillName:setColor(color)
                    -- self._bookSlot._labelSkillLevel:setColor(color)
                    UIUtils:center2Widget(self._bookSlot._labelSkillName,self._bookSlot._labelSkillLevel,35,5)
                else 
                    openDes = "未刻印法术书"
                end
                -- 开孔后判断刻印法术书
                local isNotDig = SystemUtils.loadAccountLocalData("heroSlot_diged" .. self._heroData.id)
                if not isNotDig and not spellSlot._todigguid then
                    SystemUtils.saveAccountLocalData("heroSlot_diged" .. self._heroData.id,true)
                    local tipScale = 1 / spellSlot:getScale()
                    local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("qipao_keyinfashushu.png")     
                    tipbg:setName("tipbg_guanjun")
                    tipbg._touchToRemove = true
                    tipbg:setAnchorPoint(0.25, 0)
                    tipbg:setPosition(50, 60)
                    tipbg:setScale(tipScale)
                    local seq = cc.Sequence:create(cc.ScaleTo:create(1, tipScale+tipScale*0.2), cc.ScaleTo:create(1, tipScale))
                    tipbg:runAction(cc.RepeatForever:create(seq))
                    spellSlot._todigguid = tipbg
                    spellSlot:addChild(tipbg, 10000)
                end
            else
                openDes = "未激活刻印孔"
            end
            spellSlot._labelSkillNone:setString(openDes)
        elseif isCanOpen then
            -- 第一次点击播解锁动画
            local isActived = SystemUtils.loadAccountLocalData("heroSlot_opened" .. self._heroData.id)
            if not isActived and self._heroData.slot then
                SystemUtils.saveAccountLocalData("heroSlot_opened" .. self._heroData.id,true)
                self:updateSpellBookSlot()
                isActived = true
            end
            if not isActived then
                if self._bookSlot._todigguid then
                    self._bookSlot._todigguid:setVisible(false)
                end
                self._bookSlot._labelSkillNone:setVisible(false)
                local mc = mcMgr:createViewMC("fashushujiesuo_skillbookfashushu-HD",true,true,function( )
                end)
                mc:addCallbackAtFrame(21,function( )
                    SystemUtils.saveAccountLocalData("heroSlot_opened" .. self._heroData.id,true)
                    if self._bookSlot._todigguid then
                        self._bookSlot._todigguid:setVisible(true)
                    end
                    self._bookSlot._labelSkillNone:setVisible(true)
                    self:updateSpellBookSlot()
                end)
                mc:setPosition(35,35)
                mc:setScale(-1,1)
                self._bookSlot:addChild(mc,99)
            end
            local isNotDig = SystemUtils.loadAccountLocalData("heroSlot_unlock" .. self._heroData.id)
            if not isNotDig and not spellSlot._todigguid then
                SystemUtils.saveAccountLocalData("heroSlot_unlock" .. self._heroData.id,true)
                local tipScale = 1 / spellSlot:getScale()
                local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("qipao_qianwangdakong.png")     
                tipbg:setName("tipbg_guanjun")
                tipbg._touchToRemove = true
                tipbg:setAnchorPoint(0.25, 0)
                tipbg:setPosition(50, 60)
                tipbg:setScale(tipScale)
                local seq = cc.Sequence:create(cc.ScaleTo:create(1, tipScale+tipScale*0.2), cc.ScaleTo:create(1, tipScale))
                tipbg:runAction(cc.RepeatForever:create(seq))
                spellSlot._todigguid = tipbg
                spellSlot:addChild(tipbg, 10000)
            end
        else
            local canOpenSlot,_,openLvl = SystemUtils:enableSkillBook()
            local star = self._heroData.star or 1
            local needStar = tab.setting["SKILLBOOK_LV"] and tab.setting["SKILLBOOK_LV"].value
            local isStarOk = star >= needStar
            spellSlot._labelSkillNone:setString(canOpenSlot and "英雄4星解锁" or "刻印70级解锁" or "未解锁")
        end
    end


end

function HeroSkillInformationView:onStudy10ButtonClicked()
    --print("onStudyButtonClicked")
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
    if userLevel < 40 then
        self._viewMgr:showTip("一键突破十次功能在40级开放")
        return
    end

    local skillMaxLevel = tab:Setting("G_HERO_MAX_SKILL_LEVEL").value
    local skillId = self._heroData.spell[self._currentSkillIndex]
    local skillLevel = self._heroData["sl" .. self._currentSkillIndex] 
                       or (self._heroData.slot and self._heroData.slot.s)

    local levelLimited = tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).lvlim[self._currentSkillIndex]

    if userLevel < levelLimited then
        self._viewMgr:showTip("需要玩家等级" .. levelLimited .. "级")
        return
    end

    local skcost = 4 == self._currentSkillIndex and tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost2 or tab:PlayerSkillExp(math.min(skillMaxLevel-1,skillLevel)).skcost
    for k, v in pairs(skcost) do
        local have, consume = 0, v[3] * 10
        if "tool" == v[1] then
            local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
            have = toolNum
            if consume > have then
                self._viewMgr:showTip(lang("TIPS_SPELLUP_TOOL"))
                return
            end
        elseif "gold" == v[1] then
            have = self._modelMgr:getModel("UserModel"):getData().gold
            if consume > have then
                self._viewMgr:showTip(lang("TIPS_SPELLUP_GOLD"))
                return
            end
        elseif "gem" == v[1] then
            have = self._modelMgr:getModel("UserModel"):getData().freeGem
        end
    end
    local context = {heroId = self._heroData.id, positionId = self._currentSkillIndex, exMode = 1}
    --dump(context, "context")
    if self._currentSkillIndex == 5 then
        if not self._heroData.slot or not self._heroData.slot.sid or self._heroData.slot.sid == 0 then
            self._viewMgr:showTip("请先装备法术书")
            return
        end
        self._serverMgr:sendMsg("HeroServer", "upLevelHeroSlot", context, true, {}, function(result, success)
            dump(result, "result", 10)
            local beforeFightNum = self._heroData.score
            local heroData = result["d"]["heros"]
            local currentSkillLevel = heroData[tostring(self._heroData.id)]["sl" .. self._currentSkillIndex] 
                                      or heroData[tostring(self._heroData.id)].slot 
                                      and heroData[tostring(self._heroData.id)].slot.s
                                      or 1
            self._nextLevelAttributeValues10 = BattleUtils.getHeroAttributes(self._heroData, false, {self._currentSkillIndex, currentSkillLevel})
            self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData,heroData[tostring(self._heroData.id)])
            local afterFightNum = self._heroData.score
            result["d"]["heros"] = nil
            self._userModel:updateUserData(result["d"])
            if self.updateStudyRateEffect and currentSkillLevel and skillLevel then 
                self:updateStudyRateEffect(result.rate, currentSkillLevel > skillLevel, true, skillLevel, currentSkillLevel, function( )
                    local layer = self:getUI("bg.layer")
                    if layer then
                        local x = layer:getContentSize().width*0.5
                        local y = layer:getContentSize().height - 70
                        TeamUtils:setFightAnim(layer, {oldFight = beforeFightNum, 
                            newFight = afterFightNum, x = x - 100, y = y})
                    end
                    --end
                    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                        self._container:showTopInfo(true)
                    end
                end)
                self._skillRate = result.rate
                if currentSkillLevel > skillLevel then
                    ScheduleMgr:delayCall(300, self, function ( )
                        if self.updateHeroSkillInformation then
                            self:updateHeroSkillInformation()
                        end
                    end)
                else
                    self:updateHeroSkillInformation()
                end
            end
            self._container:updateButtonStatus()
            self._container:updateAttributes(true)
        end)
    else
        self._serverMgr:sendMsg("HeroServer", "heroSkillUpgrade", context, true, {}, function(result, success)
            dump(result, "result", 10)
            if result["unset"] ~= nil then 
                local removeItems = self._itemModel:handelUnsetItems(result["unset"])
                self._itemModel:delItems(removeItems, true)
            end

            if result["d"].items then
                self._itemModel:updateItems(result["d"].items)
                result["d"].items = nil
            end
            local beforeFightNum = self._heroData.score
            local heroData = result["d"]["heros"]
            local currentSkillLevel = heroData[tostring(self._heroData.id)]["sl" .. self._currentSkillIndex]
            self._nextLevelAttributeValues10 = BattleUtils.getHeroAttributes(self._heroData, false, {self._currentSkillIndex, currentSkillLevel})
            -- table.merge(self._heroData, heroData[tostring(self._heroData.id)])
            self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData,heroData[tostring(self._heroData.id)])
            local afterFightNum = self._heroData.score
            result["d"]["heros"] = nil
            self._userModel:updateUserData(result["d"])
            if self.updateStudyRateEffect and currentSkillLevel and skillLevel then 
                self:updateStudyRateEffect(result.rate, currentSkillLevel > skillLevel, true, skillLevel, currentSkillLevel, function( )
                    --local formationModel = self._modelMgr:getModel("FormationModel")
                    --local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon)
                    --if formationData.heroId == self._heroData.id then
                    local layer = self:getUI("bg.layer")
                    if layer then
                        local x = layer:getContentSize().width*0.5
                        local y = layer:getContentSize().height - 70
                        TeamUtils:setFightAnim(layer, {oldFight = beforeFightNum, 
                            newFight = afterFightNum, x = x - 100, y = y})
                    end
                    --end
                    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                        self._container:showTopInfo(true)
                    end
                end)
                self._skillRate = result.rate
                if currentSkillLevel > skillLevel then
                    ScheduleMgr:delayCall(300, self, function ( )
                        if self.updateHeroSkillInformation then
                            self:updateHeroSkillInformation()
                        end
                    end)
                else
                    self:updateHeroSkillInformation()
                end
            end
            self._container:updateButtonStatus()
            self._container:updateAttributes(true)
        end)
    end
end

function HeroSkillInformationView:onStudyButtonClicked()
    --print("onStudyButtonClicked")
    --[[
    local skillLevel = self._heroData["sl" .. self._currentSkillIndex]
    local skillCurrentCost = tab:PlayerSkillExp(skillLevel).skcost
    local userGold = self._modelMgr:getModel("UserModel"):getData().gold
    if skillCurrentCost > userGold then
        DialogUtils.showLackRes({goalType="gold"})
        -- self._viewMgr:showTip("金币不足。")
        return 
    end
    ]]
    local skillLevel = self._heroData["sl" .. self._currentSkillIndex]
    local context = {heroId = self._heroData.id, positionId = self._currentSkillIndex}
    --dump(context, "context")
    if self._currentSkillIndex == 5 then
        if not self._heroData.slot or not self._heroData.slot.sid or self._heroData.slot.sid == 0 then
            self._viewMgr:showTip("请先装备法术书")
            return
        end
        skillLevel = self._heroData.slot.s or 1
        self._serverMgr:sendMsg("HeroServer", "upLevelHeroSlot", context, true, {}, function(result, success)
            dump(result, "result", 10)
            if result["unset"] ~= nil then 
                local removeItems = self._itemModel:handelUnsetItems(result["unset"])
                self._itemModel:delItems(removeItems, true)
            end

            if result["d"].items then
                self._itemModel:updateItems(result["d"].items)
                result["d"].items = nil
            end
            local beforeFightNum = self._heroData.score
            local heroData = result["d"]["heros"]
            local currentSkillLevel = heroData[tostring(self._heroData.id)].slot.s
            self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData,heroData[tostring(self._heroData.id)])
            local afterFightNum = self._heroData.score
            result["d"]["heros"] = nil
            self._userModel:updateUserData(result["d"])
            if self.updateStudyRateEffect and currentSkillLevel and skillLevel then 
                self:updateStudyRateEffect(result.rate, currentSkillLevel > skillLevel, false, skillLevel, currentSkillLevel, function( )
                    local layer = self:getUI("bg.layer")
                    if layer then
                        local x = layer:getContentSize().width*0.5
                        local y = layer:getContentSize().height - 70
                        TeamUtils:setFightAnim(layer, {oldFight = beforeFightNum, 
                            newFight = afterFightNum, x = x - 100, y = y})
                    end
                    --end
                    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                        self._container:showTopInfo(true)
                    end
                end)
                self._skillRate = result.rate
                if currentSkillLevel > skillLevel then
                    ScheduleMgr:delayCall(300, self, function ( )
                        if self.updateHeroSkillInformation then
                            self:updateHeroSkillInformation()
                        end
                    end)
                else
                    self:updateHeroSkillInformation()
                end
            end
            self._container:updateButtonStatus()
            self._container:updateAttributes(true)
        end)
    else
        self._serverMgr:sendMsg("HeroServer", "heroSkillUpgrade", context, true, {}, function(result, success)
            dump(result, "result", 10)
            if result["unset"] ~= nil then 
                local removeItems = self._itemModel:handelUnsetItems(result["unset"])
                self._itemModel:delItems(removeItems, true)
            end

            if result["d"].items then
                self._itemModel:updateItems(result["d"].items)
                result["d"].items = nil
            end
            local beforeFightNum = self._heroData.score
            local heroData = result["d"]["heros"]
            local currentSkillLevel = heroData[tostring(self._heroData.id)]["sl" .. self._currentSkillIndex]
            -- table.merge(self._heroData, heroData[tostring(self._heroData.id)])
            self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData,heroData[tostring(self._heroData.id)])
            local afterFightNum = self._heroData.score
            result["d"]["heros"] = nil
            self._userModel:updateUserData(result["d"])
            if self.updateStudyRateEffect and currentSkillLevel and skillLevel then 
                self:updateStudyRateEffect(result.rate, currentSkillLevel > skillLevel, false, skillLevel, currentSkillLevel, function( )
                    --local formationModel = self._modelMgr:getModel("FormationModel")
                    --local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon)
                    --if formationData.heroId == self._heroData.id then
                    local layer = self:getUI("bg.layer")
                    if layer then
                        local x = layer:getContentSize().width*0.5
                        local y = layer:getContentSize().height - 70
                        TeamUtils:setFightAnim(layer, {oldFight = beforeFightNum, 
                            newFight = afterFightNum, x = x - 100, y = y})
                    end
                    --end
                    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                        self._container:showTopInfo(true)
                    end
                end)
                self._skillRate = result.rate
                if currentSkillLevel > skillLevel then
                    ScheduleMgr:delayCall(300, self, function ( )
                        if self.updateHeroSkillInformation then
                            self:updateHeroSkillInformation()
                        end
                    end)
                else
                    self:updateHeroSkillInformation()
                end
            end
            self._container:updateButtonStatus()
            self._container:updateAttributes(true)
        end)
    end
end

function HeroSkillInformationView.dtor( )
    skillDefaultIndex = 4
end

--[[
-- version 3.0
function HeroSkillInformationView:updateEquipment()
    for i=1, 6 do
        repeat
            local artifact = self._heroData["artifact" .. i]
            if not artifact then 
                local icon = self._artifactIcons[i]:getChildByTag(self.kHeroEquipmentTag)
                if icon then
                    icon:removeFromParent()
                end 
                break 
            end
            local icon = self._artifactIcons[i]:getChildByTag(self.kHeroEquipmentTag)
            if not icon then
                icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeEquipment, iconId = artifact, container = { _container = self }, })
                icon:setPosition(self._artifactIcons[i]:getContentSize().width / 2, self._artifactIcons[i]:getContentSize().height / 2)
                icon:setTag(self.kHeroEquipmentTag)
                self._artifactIcons[i]:addChild(icon)
            end 
            icon = self._artifactIcons[i]:getChildByTag(self.kHeroEquipmentTag)
            icon:setIconType(FormationIconView.kIconTypeEquipment)
            icon:setIconId(artifact)
            icon:updateIconInformation()
        until true
    end
    
end
]]
--[[
function HeroSkillInformationView:onIconPressOn(node, iconType, iconId)
    print("onIconPressOn")
    iconType = node.getIconType and node:getIconType() or iconType
    iconId = node.getIconId and node:getIconId() or iconId
    if not (iconType and iconId) then return end
    if iconType == FormationIconView.kIconTypeEquipment then
        self:showHintView("global.GlobalTipView",{tipType = 1, node = node, id = iconId, des = BattleUtils.getDescription(iconType, iconId, self._attributeValues)})
    elseif iconType == FormationIconView.kIconTypeSkill then
        self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = iconId, des = BattleUtils.getDescription(iconType, iconId, self._attributeValues)})
    end
end

function HeroSkillInformationView:onIconPressOff()
    print("onIconPressOff")
    self:closeHintView()
end

function HeroSkillInformationView:startClock(node, iconType, iconId)
    if self._timer_id then self:endClock() end
    self._first_tick = true
    self._timer_id = self._scheduler:scheduleScriptFunc(function()
        if not self._first_tick then return end
        self._first_tick = false
        self:onIconPressOn(node, iconType, iconId)
    end, 0.2, false)
end

function HeroSkillInformationView:endClock()
   if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
    self:onIconPressOff()
end
]]
--[[ -- version 3.0
function HeroSkillInformationView:onEquipmentButtonClicked()
    if self._tabType == self.kTabTypeEquipment then return end
    self._tabType = self.kTabTypeEquipment
    self._layerEquipment:setVisible(true)
    self._layerSkill:setVisible(false)
    self._btnEquipment:setVisible(false)
    self._btnSkill:setVisible(true)
    self:updateEquipment()
end

function HeroSkillInformationView:onSkillButtonClicked()
    if self._tabType == self.kTabTypeSkill then return end
    self._tabType = self.kTabTypeSkill
    self._layerEquipment:setVisible(false)
    self._layerSkill:setVisible(true)
    self._btnEquipment:setVisible(true)
    self._btnSkill:setVisible(false)
    self:updateSkillIcon()
end
]]
return HeroSkillInformationView