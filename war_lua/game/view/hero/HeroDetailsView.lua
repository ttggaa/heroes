--[[
    Filename:    HeroDetailsView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-08-08 15:22:38
    Description: File description
--]]

local FormationIconView = require("game.view.formation.FormationIconView")

local HeroDetailsView = class("HeroDetailsView", BasePopView)

HeroDetailsView.kViewTypeSkillInformation = 1
HeroDetailsView.kViewTypeMasteryInformation = 2
HeroDetailsView.kViewTypeBasicInformation = 3
HeroDetailsView.kViewTypeUpgradeInformation = 4

HeroDetailsView.kHeroSkillInformationTag = 1000
HeroDetailsView.kHeroBasicInformationTag = 2000
HeroDetailsView.kHeroUpgradeInformationTag = 3000

HeroDetailsView.kNormalZOrder = 500
HeroDetailsView.kLessNormalZOrder = HeroDetailsView.kNormalZOrder - 1
HeroDetailsView.kAboveNormalZOrder = HeroDetailsView.kNormalZOrder + 1
HeroDetailsView.kHighestZOrder = HeroDetailsView.kAboveNormalZOrder + 1

function HeroDetailsView:ctor(params)
    HeroDetailsView.super.ctor(self)
    self._container = params.container
    self._heroData = params.heroData
    self._heroModel = self._modelMgr:getModel("HeroModel")
end

function HeroDetailsView:getMaskOpacity()
    return 180
end

function HeroDetailsView:onInit()

    self:getUI("bg.bgl"):loadTexture("asset/bg/bg_magic.png", 0)
    self:getUI("bg.bgr"):loadTexture("asset/bg/bg_magic.png", 0)

    self._buttons = {}
    self._buttons[HeroDetailsView.kViewTypeSkillInformation] = {}
    self._buttons[HeroDetailsView.kViewTypeSkillInformation]._btn = self:getUI("bg.btn_skill_information")
    self._buttons[HeroDetailsView.kViewTypeSkillInformation]._btn:enableOutline(cc.c4b(73,48,29,255), 1)
    --self._buttons[HeroDetailsView.kViewTypeSkillInformation]._image_tab_normal = self:getUI("bg.btn_skill_information.image_normal")
    --self._buttons[HeroDetailsView.kViewTypeSkillInformation]._image_tab_selected = self:getUI("bg.btn_skill_information.image_selected")
    self._buttons[HeroDetailsView.kViewTypeSkillInformation]._image_red_tag = self:getUI("bg.btn_skill_information.image_red_tag")

    self._buttons[HeroDetailsView.kViewTypeMasteryInformation] = {}
    self._buttons[HeroDetailsView.kViewTypeMasteryInformation]._btn = self:getUI("bg.btn_mastery_information")
    self._buttons[HeroDetailsView.kViewTypeMasteryInformation]._btn:enableOutline(cc.c4b(73,48,29,255), 1)
    --self._buttons[HeroDetailsView.kViewTypeMasteryInformation]._image_tab_normal = self:getUI("bg.btn_mastery_information.image_normal")
    --self._buttons[HeroDetailsView.kViewTypeMasteryInformation]._image_tab_selected = self:getUI("bg.btn_mastery_information.image_selected")
    self._buttons[HeroDetailsView.kViewTypeMasteryInformation]._image_red_tag = self:getUI("bg.btn_mastery_information.image_red_tag")

    self._buttons[HeroDetailsView.kViewTypeBasicInformation] = {}
    self._buttons[HeroDetailsView.kViewTypeBasicInformation]._btn = self:getUI("bg.btn_basic_information")
    self._buttons[HeroDetailsView.kViewTypeBasicInformation]._btn:enableOutline(cc.c4b(73,48,29,255), 1)
    --self._buttons[HeroDetailsView.kViewTypeBasicInformation]._image_tab_normal = self:getUI("bg.btn_basic_information.image_normal")
    --self._buttons[HeroDetailsView.kViewTypeBasicInformation]._image_tab_selected = self:getUI("bg.btn_basic_information.image_selected")
    self._buttons[HeroDetailsView.kViewTypeBasicInformation]._image_red_tag = self:getUI("bg.btn_basic_information.image_red_tag")

    self._buttons[HeroDetailsView.kViewTypeUpgradeInformation] = {}
    self._buttons[HeroDetailsView.kViewTypeUpgradeInformation]._btn = self:getUI("bg.btn_upgrade_information")
    self._buttons[HeroDetailsView.kViewTypeUpgradeInformation]._btn:enableOutline(cc.c4b(73,48,29,255), 1)
    --self._buttons[HeroDetailsView.kViewTypeUpgradeInformation]._image_tab_normal = self:getUI("bg.btn_upgrade_information.image_normal")
    --self._buttons[HeroDetailsView.kViewTypeUpgradeInformation]._image_tab_selected = self:getUI("bg.btn_upgrade_information.image_selected")
    self._buttons[HeroDetailsView.kViewTypeUpgradeInformation]._image_red_tag = self:getUI("bg.btn_upgrade_information.image_red_tag")

    self._heroSkillInformation = {}
    self._heroSkillInformation._layer = self:getUI("bg.layer_hero_skill_information")
    self._heroBasicInformation = {}
    self._heroBasicInformation._layer = self:getUI("bg.layer_hero_basic_information")
    self._heroUpgradeInformation = {}
    self._heroUpgradeInformation._layer = self:getUI("bg.layer_hero_basic_information")

    self:registerClickEvent(self._buttons[HeroDetailsView.kViewTypeSkillInformation]._btn, function ()
        self:switchTag(self.kViewTypeSkillInformation)
    end)

    self:registerClickEvent(self._buttons[HeroDetailsView.kViewTypeMasteryInformation]._btn, function ()
        self:switchTag(self.kViewTypeMasteryInformation)
    end)

    self:registerClickEvent(self._buttons[HeroDetailsView.kViewTypeBasicInformation]._btn, function ()
        self:switchTag(self.kViewTypeBasicInformation)
    end)

    self:registerClickEvent(self._buttons[HeroDetailsView.kViewTypeUpgradeInformation]._btn, function ()
        self:switchTag(self.kViewTypeUpgradeInformation)
    end)

    self:switchTag(self:getCurrentViewType())

    self:registerClickEventByName("bg.btn_return", function(sender)
        local doClose = function()
            if self._container and self._container.onDetailsViewClosed then
                self._container:onDetailsViewClosed()
            end
            UIUtils:reloadLuaFile("hero.HeroSkillInformationView")
            self:close()
        end
        if self._viewType == HeroDetailsView.kViewTypeMasteryInformation then
            local heroBasicInformation = self._heroBasicInformation._layer:getChildByTag(self.kHeroBasicInformationTag)
            if heroBasicInformation and heroBasicInformation:isRefreshButtonClicked() then
                self._viewMgr:showSelectDialog(lang("TIPS_MASTERYREFLASH_3"), "", function()
                    doClose()
                end, "")
                return
            end
        end
        doClose()
    end)

    self:listenReflash("ItemModel", function( )
        self:updateUI()
    end)

    self:listenReflash("HeroModel", self.onModelReflash)
end

function HeroDetailsView:onModelReflash()
    self:updateUI(nil, true)
end

function HeroDetailsView:onPopEnd()
    if self._heroModel:isHeroCanUpgrade(self._heroData.id) then
        GuideUtils.checkTriggerByType("action", "6")
    end
end

function HeroDetailsView:getCurrentViewType()
    local viewType = self.kViewTypeSkillInformation
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
    if userLevel < 20 then
        viewType = self.kViewTypeBasicInformation
        if self._heroModel:isHeroRedTagShowByIdAndType(self._heroData.id, self._heroModel.kTagTypeUpgrade) then
            viewType = self.kViewTypeUpgradeInformation
        end
    end
    return viewType
end

function HeroDetailsView:updateButtonStatus()
    local btn = self._buttons[HeroDetailsView.kViewTypeSkillInformation]._btn
    -- btn:getTitleRenderer():disableEffect()
    btn:setEnabled(HeroDetailsView.kViewTypeSkillInformation ~= self._viewType)
    btn:setBright(HeroDetailsView.kViewTypeSkillInformation ~= self._viewType)
    --btn:setTitleFontSize(HeroDetailsView.kViewTypeSkillInformation ~= self._viewType and 28 or 32)
    --btn:setTitleText(HeroDetailsView.kViewTypeSkillInformation ~= self._viewType and "  法术" or "  法术")
    btn:setTitleColor(HeroDetailsView.kViewTypeSkillInformation ~= self._viewType and UIUtils.colorTable.ccUIMagicTab2 or UIUtils.colorTable.ccUIMagicTab1)
    local image_red_tag = self._buttons[HeroDetailsView.kViewTypeSkillInformation]._image_red_tag
    image_red_tag:setVisible(self._heroModel:isHeroRedTagShowByIdAndType(self._heroData.id, self._heroModel.kTagTypeSkill))
    --image_red_tag:setPositionX(HeroDetailsView.kViewTypeSkillInformation == self._viewType and 85 or 85)
    
    local btn = self._buttons[HeroDetailsView.kViewTypeMasteryInformation]._btn
    -- btn:getTitleRenderer():disableEffect()
    btn:setEnabled(HeroDetailsView.kViewTypeMasteryInformation ~= self._viewType)
    btn:setBright(HeroDetailsView.kViewTypeMasteryInformation ~= self._viewType)
    btn:setSaturation(not not SystemUtils:enableHeroMastery() and 0 or -100)
    --btn:setTitleFontSize(HeroDetailsView.kViewTypeMasteryInformation ~= self._viewType and 28 or 32)
    --btn:setTitleText(HeroDetailsView.kViewTypeMasteryInformation ~= self._viewType and "  专精" or "  专精")
    btn:setTitleColor(HeroDetailsView.kViewTypeMasteryInformation ~= self._viewType and UIUtils.colorTable.ccUIMagicTab2 or UIUtils.colorTable.ccUIMagicTab1)
    local image_red_tag = self._buttons[HeroDetailsView.kViewTypeMasteryInformation]._image_red_tag
    image_red_tag:setVisible(self._heroModel:isHeroRedTagShowByIdAndType(self._heroData.id, self._heroModel.kTagTypeMastery))
    --image_red_tag:setPositionX(HeroDetailsView.kViewTypeMasteryInformation == self._viewType and 85 or 85)
    
    local btn = self._buttons[HeroDetailsView.kViewTypeBasicInformation]._btn
    -- btn:getTitleRenderer():disableEffect()
    btn:setEnabled(HeroDetailsView.kViewTypeBasicInformation ~= self._viewType)
    btn:setBright(HeroDetailsView.kViewTypeBasicInformation ~= self._viewType)
    --btn:setTitleFontSize(HeroDetailsView.kViewTypeBasicInformation ~= self._viewType and 28 or 32)
    --btn:setTitleText(HeroDetailsView.kViewTypeBasicInformation ~= self._viewType and "  专长" or "  专长")
    btn:setTitleColor(HeroDetailsView.kViewTypeBasicInformation ~= self._viewType and UIUtils.colorTable.ccUIMagicTab2 or UIUtils.colorTable.ccUIMagicTab1)
    local image_red_tag = self._buttons[HeroDetailsView.kViewTypeBasicInformation]._image_red_tag
    image_red_tag:setVisible(false)
    --image_red_tag:setPositionX(HeroDetailsView.kViewTypeBasicInformation == self._viewType and 85 or 85)
    
    local btn = self._buttons[HeroDetailsView.kViewTypeUpgradeInformation]._btn
    -- btn:getTitleRenderer():disableEffect()
    btn:setEnabled(HeroDetailsView.kViewTypeUpgradeInformation ~= self._viewType)
    btn:setBright(HeroDetailsView.kViewTypeUpgradeInformation ~= self._viewType)
    --btn:setTitleFontSize(HeroDetailsView.kViewTypeUpgradeInformation ~= self._viewType and 28 or 32)
    --btn:setTitleText(HeroDetailsView.kViewTypeUpgradeInformation ~= self._viewType and "  晋升" or "  晋升")
    btn:setTitleColor(HeroDetailsView.kViewTypeUpgradeInformation ~= self._viewType and UIUtils.colorTable.ccUIMagicTab2 or UIUtils.colorTable.ccUIMagicTab1)
    local image_red_tag = self._buttons[HeroDetailsView.kViewTypeUpgradeInformation]._image_red_tag
    image_red_tag:setVisible(self._heroModel:isHeroRedTagShowByIdAndType(self._heroData.id, self._heroModel.kTagTypeUpgrade))
    --image_red_tag:setPositionX(HeroDetailsView.kViewTypeUpgradeInformation == self._viewType and 85 or 85)
end

function HeroDetailsView:updateAttributes(dirty)
    if self._container and self._container.updateAttributes and type(self._container.updateAttributes) == "function" then
        self._container:updateAttributes(dirty)
    end
end

function HeroDetailsView:showTopInfo(isShow)
    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
        self._container:showTopInfo(isShow)
    end
end

function HeroDetailsView:upgradeHero(heroData)
    if self._container and self._container.upgradeHero and type(self._container.upgradeHero) == "function" then
        self._container:upgradeHero(heroData)
    end
end

function HeroDetailsView:switchTag(viewType, force)
    if self._viewType == viewType and not force then return end
    
    if viewType == HeroDetailsView.kViewTypeMasteryInformation then
        if not SystemUtils:enableHeroMastery() then
            self._viewMgr:showTip(lang("TIP_HeroMastery"))
            return 
        end
    end
    require("game.view.hero.HeroSkillInformationView").dtor()

    self._viewType = viewType

    self:updateButtonStatus()

    self._heroSkillInformationDirty = true
    self._heroMasteryInformationDirty = true
    self._heroBasicInformationDirty = true
    self._heroUpgradeInformationDirty = true
    self:updateUI()
end

function HeroDetailsView:updateUI(viewType, force)
    viewType = tonumber(viewType) or tonumber(self._viewType)

    if viewType == HeroDetailsView.kViewTypeSkillInformation then
        self._heroBasicInformation._layer:setVisible(false)
        self._heroSkillInformation._layer:setVisible(true)
        self:updateHeroSkillInformation()
    elseif viewType == HeroDetailsView.kViewTypeMasteryInformation then
        self._heroBasicInformation._layer:setVisible(true)
        self._heroSkillInformation._layer:setVisible(false)
        self._heroMasteryInformationDirty = true
        self:updateHeroMasteryInformation(force)
    elseif viewType == HeroDetailsView.kViewTypeBasicInformation then
        self._heroBasicInformation._layer:setVisible(true)
        self._heroSkillInformation._layer:setVisible(false)
        self._heroBasicInformationDirty = true
        self:updateHeroBasicInformation(force)
    else
        self._heroBasicInformation._layer:setVisible(true)
        self._heroSkillInformation._layer:setVisible(false)
        self._heroBasicInformationDirty = true
        self:updateHeroUpgradeInformation(force)
    end
end

function HeroDetailsView:updateHeroSkillInformation()
    if not self._heroSkillInformationDirty or not self._heroData then return end
    local heroSkillInformation = self._heroSkillInformation._layer:getChildByTag(self.kHeroSkillInformationTag)
    if not heroSkillInformation then
        heroSkillInformation = self:createLayer("hero.HeroSkillInformationView",  { data = self._heroData, container = self })
        heroSkillInformation:setTag(self.kHeroSkillInformationTag)
        self._heroSkillInformation._layer:addChild(heroSkillInformation)
    end
    heroSkillInformation:updateHeroSkillInformation()
    --[[
    if not self._heroData then return end
    local heroSkillInformationLayer = self._heroSkillInformation._layer:getChildByTag(self.kHeroSkillInformationTag)
    if not heroSkillInformationLayer then
        local heroSkillInformation = self:createLayer("hero.HeroSkillInformationView")
        heroSkillInformation:setTag(self.kHeroSkillInformationTag)
        self._heroSkillInformation._layer:addChild(heroSkillInformation)
    end
    heroSkillInformationLayer = self._heroSkillInformation._layer:getChildByTag(self.kHeroSkillInformationTag)
    heroSkillInformationLayer:updateHeroSkillInformation(self._heroData)
    ]]
end

function HeroDetailsView:updateHeroMasteryInformation(force)
    if (not self._heroMasteryInformationDirty and not force) or not self._heroData then return end
    local heroBasicInformation = self._heroBasicInformation._layer:getChildByTag(self.kHeroBasicInformationTag)
    if not heroBasicInformation then
        heroBasicInformation = self:createLayer("hero.HeroBasicInformationView", { data = self._heroData, container = self })
        heroBasicInformation:setTag(self.kHeroBasicInformationTag)
        self._heroBasicInformation._layer:addChild(heroBasicInformation)
    end
    heroBasicInformation:updateUI(self.kViewTypeMasteryInformation, force)
end

function HeroDetailsView:updateHeroBasicInformation(force)
    if (not self._heroBasicInformationDirty and not force) or not self._heroData then return end
    local heroBasicInformation = self._heroBasicInformation._layer:getChildByTag(self.kHeroBasicInformationTag)
    if not heroBasicInformation then
        heroBasicInformation = self:createLayer("hero.HeroBasicInformationView", { data = self._heroData, container = self })
        heroBasicInformation:setTag(self.kHeroBasicInformationTag)
        self._heroBasicInformation._layer:addChild(heroBasicInformation)
    end
    heroBasicInformation:updateUI(self.kViewTypeBasicInformation, force)
    --[[
    if not self._heroData then return end
    local heroBasicInformationLayer = self._heroBasicInformation._layer:getChildByTag(self.kHeroBasicInformationTag)
    if not heroBasicInformationLayer then
        local heroBasicInformation = self:createLayer("hero.HeroBasicInformationView")
        heroBasicInformation:setTag(self.kHeroBasicInformationTag)
        self._heroBasicInformation._layer:addChild(heroBasicInformation)
    end
    heroBasicInformationLayer = self._heroBasicInformation._layer:getChildByTag(self.kHeroBasicInformationTag)
    heroBasicInformationLayer:updateHeroBasicInformation(self._heroData)
    ]]
end

function HeroDetailsView:updateHeroUpgradeInformation(force)
    if (not self._heroUpgradeInformationDirty and not force) or not self._heroData then return end
    local heroBasicInformation = self._heroBasicInformation._layer:getChildByTag(self.kHeroBasicInformationTag)
    if not heroBasicInformation then
        heroBasicInformation = self:createLayer("hero.HeroBasicInformationView", { data = self._heroData, container = self  })
        heroBasicInformation:setTag(self.kHeroBasicInformationTag)
        self._heroUpgradeInformation._layer:addChild(heroBasicInformation)
    end
    heroBasicInformation:updateUI(self.kViewTypeUpgradeInformation, force)
    --[[
    if not self._heroData then return end
    local heroBasicInformationLayer = self._heroBasicInformation._layer:getChildByTag(self.kHeroBasicInformationTag)
    if not heroBasicInformationLayer then
        local heroBasicInformation = self:createLayer("hero.HeroBasicInformationView")
        heroBasicInformation:setTag(self.kHeroBasicInformationTag)
        self._heroBasicInformation._layer:addChild(heroBasicInformation)
    end
    heroBasicInformationLayer = self._heroBasicInformation._layer:getChildByTag(self.kHeroBasicInformationTag)
    heroBasicInformationLayer:updateHeroBasicInformation(self._heroData)
    ]]
end
--[=[
function HeroDetailsView.getHeroAttributes(heroData, nextLevel)
    -- dump(heroData, "heroData")
    local id = heroData.id or heroData.heroId
    local userModel = ModelManager:getInstance():getModel("UserModel")
    local treasureModel = ModelManager:getInstance():getModel("TreasureModel")
    local level = userModel:getData().lvl or 1
    local masterys = {}
    for i=1, 4 do
        masterys[i] = heroData["m" .. i]
    end
    local equips = {}

    local artifacts = userModel:getData().artifacts
    for i=1, 6 do
        repeat
            local artifact = heroData["artifact" .. i]
            if not artifact then break end
            local stage = artifacts[tostring(artifact)].stage or 0
            table.insert(equips, {id = artifact, stage = stage})
        until true
    end
    local slevel = {}
    for i = 1, 5 do
        slevel[i] = heroData["sl" .. i]
    end

    if nextLevel then
        for i = 1, #slevel do
            slevel[i] = slevel[i] + 1
        end
    end
 dump(userModel:getGlobalMasterys(),"userModel:getGlobalMasterys()==>>>")
    return BattleUtils.getHeroBaseAttr(tab:Hero(id), level, slevel, heroData.star, masterys, userModel:getGlobalMasterys(), treasureModel:getData())
end

--排行榜获取英雄详情 
function HeroDetailsView.getRankHeroAttributes(playerLvl,heroData,globalSpecial,treasureData)
    --dump(heroData, "heroData", 5)
    local id = heroData.id or heroData.heroId
    local level = playerLvl
    local masterys = {}
    for i=1, 4 do
        masterys[i] = heroData["m" .. i]
    end
    local equips = {}

    local artifacts = treasureData
    for i=1, 6 do
        repeat
            local artifact = heroData["artifact" .. i]
            if not artifact then break end
            local stage = artifacts[tostring(artifact)].stage or 0
            table.insert(equips, {id = artifact, stage = stage})
        until true
    end
    local slevel = {}
    for i = 1, 5 do
        slevel[i] = heroData["sl" .. i]
    end

    -- dump(globalSpecial,"globalSpecial==>>>")
    -- print("+==================+",id)

    return BattleUtils.getHeroBaseAttr(tab:Hero(id), level, slevel, heroData.star, masterys, globalSpecial, treasureData)
end

function HeroDetailsView.getDescription(iconType, iconId, attributeValues, skillIndex, specifiedDescriptionId)
    --attributeValues = attributeValues or HeroDetailsView.getHeroAttributes(self._heroData)
    if not attributeValues then return end
    if iconType == FormationIconView.kIconTypeSkill and not skillIndex then return end
    if not skillIndex then skillIndex = 1 end

    local varibleNameToValue = 
    {
        ["$atk"] = attributeValues.atk,
        ["$def"] = attributeValues.def,
        ["$int"] = attributeValues.int,
        ["$ack"] = attributeValues.ack,
        ["$mor"] = attributeValues.shiQi,
        ["$artifactlv"] = attributeValues.artifactlv or 0,
        ["$manabase"] = attributeValues.manaBase,
        ["$ap"] = 0,
        ["$manarec"] = attributeValues.manaRec,
        ["$sklevel"] = attributeValues.sklevel or attributeValues.skills[skillIndex][2],
        ["$level"] = 0,
        ["$valueadd11"] = 0,
        ["$valueadd12"] = 0,
        ["$valueadd21"] = 0,
        ["$valueadd22"] = 0,
        ["$ulevel"] = ModelManager:getInstance():getModel("UserModel"):getData().lvl,
        ["$range1"] = 0,
        ["$unittime"] = 0,
        ["$sumnum"] = 0,
        ["$morale11"] = 0,
        ["$morale12"] = 0,
        ["$addattr11"] = 0,
        ["$addattr12"] = 0,
        ["$orange1"] = 0,
        ["$ovalueadd11"] = 0,
        ["$ovalueadd12"] = 0,
        ["$ointerval"] = 0,
        ["$olast11"] = 0,
        ["$olast12"] = 0,
        ["$bufflast11"] = 0,
        ["$bufflast12"] = 0,
        ["$buffaddattr11"] = 0,
        ["$buffaddattr12"] = 0,
        ["$buffaddattr13"] = 0,
        ["$buffaddattr21"] = 0,
        ["$buffaddattr22"] = 0,
        ["$buffaddattr23"] = 0,
        ["$buffhurt"] = 0,
        ["$valuepro11"] = 0,
        ["$valuepro12"] = 0,
        ["$dupliatk11"] = 0,
        ["$dupliatk12"] = 0,
        ["$duplidmg11"] = 0,
        ["$duplidmg12"] = 0,
        ["$initcd1"] = 0,
        ["$initcd2"] = 0,
        ["$cd1"] = 0,
        ["$cd2"] = 0,
    }

    local description = ""
    local isRound = false
    if iconType == FormationIconView.kIconTypeAttributeAtk then
        description = lang("HERO_ATTRIBUTE_ATK")
    elseif iconType == FormationIconView.kIconTypeAttributeDef then
        description = lang("HERO_ATTRIBUTE_DEF")
    elseif iconType == FormationIconView.kIconTypeAttributeInt then
        description = lang("HERO_ATTRIBUTE_INT")
    elseif iconType == FormationIconView.kIconTypeAttributeAck then
        description = lang("HERO_ATTRIBUTE_ACK")
    elseif iconType == FormationIconView.kIconTypeAttributeMorale then
        description = lang("HERO_ATTRIBUTE_MOR")
    elseif iconType == FormationIconView.kIconTypeAttributeMagic then
        description = lang("HERO_ATTRIBUTE_MANA")
    elseif iconType == FormationIconView.kIconTypeHeroSpecialty or
           iconType == FormationIconView.kIconTypeHeroMastery then
        local masteryData = tab:HeroMastery(iconId)
        print(iconId,"iconId......")
        varibleNameToValue["$morale11"] = (masteryData["morale"] and masteryData["morale"][1]) and masteryData["morale"][1][1] or 0
        varibleNameToValue["$morale12"] = (masteryData["morale"] and masteryData["morale"][1]) and masteryData["morale"][1][2] or 0
        varibleNameToValue["$morale13"] = (masteryData["morale"] and masteryData["morale"][1]) and masteryData["morale"][1][3] or 0
        varibleNameToValue["$addattr11"] = (masteryData["addattr"] and masteryData["addattr"][1]) and masteryData["addattr"][1][1] or 0
        varibleNameToValue["$addattr12"] = (masteryData["addattr"] and masteryData["addattr"][1]) and masteryData["addattr"][1][2] or 0
        varibleNameToValue["$addattr13"] = (masteryData["addattr"] and masteryData["addattr"][1]) and masteryData["addattr"][1][3] or 0
        description = lang(masteryData.des)
    elseif iconType == FormationIconView.kIconTypeSkill then
        local skillData = tab:PlayerSkillEffect(iconId)
        local objectData = nil
        if skillData.objectid then
            objectData = tab:Object(skillData.objectid)
        end
        local bufferData = nil
        if skillData.buffid1 then
            bufferData = tab:SkillBuff(skillData.buffid1)
        end
        varibleNameToValue["$ap"] = attributeValues.ap[skillData["mgtype"]][skillData["type"]]
        varibleNameToValue["$valueadd11"] = skillData["valueadd1"] and skillData["valueadd1"][1] or 0
        varibleNameToValue["$valueadd12"] = skillData["valueadd1"] and skillData["valueadd1"][2] or 0
        varibleNameToValue["$valueadd21"] = skillData["valueadd2"] and skillData["valueadd2"][1] or 0
        varibleNameToValue["$valueadd22"] = skillData["valueadd2"] and skillData["valueadd2"][2] or 0
        varibleNameToValue["$valuepro11"] = skillData["valuepro1"] and skillData["valuepro1"][1] or 0
        varibleNameToValue["$valuepro12"] = skillData["valuepro1"] and skillData["valuepro1"][2] or 0
        varibleNameToValue["$dupliatk11"] = skillData["dupliatk1"] and skillData["dupliatk1"][1] or 0
        varibleNameToValue["$dupliatk12"] = skillData["dupliatk1"] and skillData["dupliatk1"][2] or 0
        varibleNameToValue["$duplidmg11"] = skillData["duplidmg1"] and skillData["duplidmg1"][1] or 0
        varibleNameToValue["$duplidmg12"] = skillData["duplidmg1"] and skillData["duplidmg1"][2] or 0
        varibleNameToValue["$initcd1"] = skillData["initcd"] and skillData["initcd"][1] or 0
        varibleNameToValue["$initcd2"] = skillData["initcd"] and skillData["initcd"][2] or 0
        varibleNameToValue["$cd1"] = skillData["cd"] and skillData["cd"][1] or 0
        varibleNameToValue["$cd2"] = skillData["cd"] and skillData["cd"][2] or 0
        varibleNameToValue["$range1"] = skillData["range1"] or 0
        varibleNameToValue["$unittime"] = skillData["unittime"] or 0
        varibleNameToValue["$sumnum"] = skillData["sumnum"] or 0
        
        if objectData then
            varibleNameToValue["$orange1"] = objectData["range1"] or 0
            varibleNameToValue["$ovalueadd11"] = objectData["valueadd1"] and objectData["valueadd1"][1] or 0
            varibleNameToValue["$ovalueadd12"] = objectData["valueadd1"] and objectData["valueadd1"][2] or 0
            varibleNameToValue["$ovalueadd21"] = objectData["valueadd2"] and objectData["valueadd2"][1] or 0
            varibleNameToValue["$ovalueadd22"] = objectData["valueadd2"] and objectData["valueadd2"][2] or 0
            varibleNameToValue["$ointerval"] = objectData["interval"] or 0
            varibleNameToValue["$olast11"] = objectData["last1"] and objectData["last1"][1] or 0
            varibleNameToValue["$olast12"] = objectData["last1"] and objectData["last1"][2] or 0
        end

        if bufferData then
            varibleNameToValue["$bufflast11"] = bufferData["last1"] and bufferData["last1"][1] or 0
            varibleNameToValue["$bufflast12"] = bufferData["last1"] and bufferData["last1"][2] or 0
            varibleNameToValue["$buffaddattr11"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][1] or 0
            varibleNameToValue["$buffaddattr12"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][2] or 0
            varibleNameToValue["$buffaddattr13"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][3] or 0
            varibleNameToValue["$buffaddattr21"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][1] or 0
            varibleNameToValue["$buffaddattr22"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][2] or 0
            varibleNameToValue["$buffaddattr23"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][3] or 0
            varibleNameToValue["$buffhurt"] = bufferData["hurt"] or 0
        end

        description = specifiedDescriptionId and lang(specifiedDescriptionId) or lang(skillData.des)
        --isRound = true
    elseif iconType == FormationIconView.kIconTypeEquipment then

    end

    --print("description:", description)

    if isRound then
        description = string.gsub(description, "%b{}", function(substring)
            local equation = "return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
                return tostring(varibleNameToValue[variableName])
            end), "[{}]", "")
            local functionName = loadstring(equation)
            if not functionName then
                print("wrong equation", equation, iconType, iconId)
                ViewManager:getInstance():onLuaError("hero description error: " .. "equation:" .. equation .. " iconType:" .. iconType .. " iconId" .. iconId)
                return 0
            end
            local result = math.round(functionName())
            return result
            --[[
            return math.round(loadstring("return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
                return tostring(varibleNameToValue[variableName])
            end), "[{}]", ""))())
            ]]
        end)
    else
        -- print("description",description)
        description = string.gsub(description, "%b{}", function(substring)
            local equation = "return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
                return tostring(varibleNameToValue[variableName])
            end), "[{}]", "")
            equation = string.gsub(equation,"%-%-","-")
            local functionName = loadstring(equation)
            if not functionName then
                print("wrong equation", equation, iconType, iconId)
                ViewManager:getInstance():onLuaError("hero description error: " .. "equation:" .. equation .. " iconType:" .. iconType .. " iconId" .. iconId)
                return 0
            end
            local result = string.format("%.1f", functionName())
            if checknumber(result) > 100 then
                result = checknumber(result)
            elseif '0' == string.sub(result, -1) then
                result = checkint(result)
            end
            return result
            --[[
            local result = string.format("%.1f", loadstring("return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
                return tostring(varibleNameToValue[variableName])
            end), "[{}]", ""))())
            if checknumber(result) > 100 then
                result = checknumber(result)
            elseif '0' == string.sub(result, -1) then
                result = checkint(result)
            end
            return result
            ]]
        end)
    end
    --description = string.gsub(description, "%b[]", "")
    --print("description:", description)

    return description
end
]=]
return HeroDetailsView
