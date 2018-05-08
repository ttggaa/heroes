--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-09-14 14:24:54
--
--[[
    Filename:    HeroSpellBookResultView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-02-16 11:06:08
    Description: File description
--]]
local HeroSpellBookResultView = class("HeroSpellBookResultView", BasePopView)

function HeroSpellBookResultView:ctor(params)
    HeroSpellBookResultView.super.ctor(self)
    self._heroModel = self._modelMgr:getModel("HeroModel")
    -- self._heroData = params.heroData
    self._des = params.des
    self._attName = params.attName
    self._skillId = params.skillId
    self._attNum = params.attNum
    self._releaseNum = params.releaseNum
    self._callback = params.callback
    self._isMastery = tab:HeroMastery(self._skillId)
end

function HeroSpellBookResultView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
        local name = element:getName()
        if name ~= "label_continue" then
            element:setFontName(UIUtils.ttfName)
        end
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

function HeroSpellBookResultView:onInit()
    self:disableTextEffect()
    self._bg = self:getUI("bg")
    self._labelEffectDes1 = self:getUI("bg.layer.layer_des_bg.label_effect_des_1")
    self._labelEffectDes1:setVisible(false)
    self._labelEffectDes2 = self:getUI("bg.layer.layer_des_bg.label_effect_des_2")
    self._labelEffectDes2:setVisible(false)

    self._attrBg1 = self:getUI("bg.layer.layer_des_bg.attrBg1")
    self._attrBg1:setVisible(false)
    local oldLabel = self:getUI("bg.layer.layer_des_bg.attrBg1.oldLabel")
    local newLabel = self:getUI("bg.layer.layer_des_bg.attrBg1.newLable")
    oldLabel:setFontName(UIUtils.ttfName)
    newLabel:setFontName(UIUtils.ttfName)
    newLabel:setString("+" .. self._releaseNum or "+1")
    if self._isMastery then
        self:getUI("bg.layer.layer_des_bg.attrBg2"):setPositionY(120)
    end
    
    oldLabel = self:getUI("bg.layer.layer_des_bg.attrBg2.oldLabel")
    newLabel = self:getUI("bg.layer.layer_des_bg.attrBg2.newLable")
    oldLabel:setString(self._attName or "英雄智力")
    newLabel:setString("+" .. self._attNum or "+5")

    self._skills = {}
    self._skills[2] = {}
    self._skills[2]._icon = self:getUI("bg.layer.skill_icon")
    self._skills[2]._icon:setVisible(false)
    self._skills[2]._imageFire = self:getUI("bg.layer.skill_icon.image_fire")
    self._skills[2]._imageWater = self:getUI("bg.layer.skill_icon.image_water")
    self._skills[2]._imageWind = self:getUI("bg.layer.skill_icon.image_wind")
    self._skills[2]._imageSoil = self:getUI("bg.layer.skill_icon.image_soil")
    self._skills[2]._labelSkillName = self:getUI("bg.layer.skill_icon.label_skill_name")
	   
    self._layer = self:getUI("bg.layer")

    self._labelContinue = self:getUI("bg.layer.label_continue")
    self._labelContinue:setVisible(false)
    self._labelContinue:setPositionY(self._labelContinue:getPositionY() - 50)

    local layer = ccui.Layout:create()
    layer:setTouchEnabled(true)
    layer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._bg:getParent():addChild(layer,10)

    self:registerClickEvent(layer, function()
        layer:setTouchEnabled(false)
        if self._callback then 
            self._callback()
        end
        self:close()
        UIUtils:reloadLuaFile("spellbook.HeroSpellBookResultView")
    end)
    self._viewMgr:lock()
    self:updateUI()
end

function HeroSpellBookResultView:updateUI()
    -- audioMgr:playSound("adTitle")
    local nextAnimFunc = function()      
        local skillId = self._skillId
        -- local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
        -- if isReplaced then
        --     skillId = skillReplacedId
        -- end
        local skillTableData = tab:PlayerSkillEffect(skillId) or tab:HeroMastery(skillId)
        local skillLevel = 1
        local skillType = skillTableData.type

        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. (skillTableData.art or skillTableData.icon) .. ".png")
        icon:setScale(0.7)
        icon:setPosition(self._skills[2]._icon:getContentSize().width / 2, self._skills[2]._icon:getContentSize().height / 2)
        self._skills[2]._icon:addChild(icon)

        --add by wangyan
        local sysSkillData = tab.skillBookBase[skillId]
        local imgRes = {"skill_bg_fire01_hero", "skill_bg_water01_hero", "skill_bg_wind01_hero", "skill_bg_soil01_hero"}
        local iconList = {self._skills[2]._imageFire, self._skills[2]._imageWater, self._skills[2]._imageWind, self._skills[2]._imageSoil}
        if sysSkillData and sysSkillData["type"] == 4 then
            for i=1, 4 do
                iconList[i]:loadTexture(imgRes[i] .. ".png", 1)
            end
        end

        local color = UIUtils.colorTable["ccUIHeroSkillColor" .. (skillType or 1)]
        self._skills[2]._labelSkillName:setColor(color)        
        self._skills[2]._labelSkillName:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self._skills[2]._labelSkillName:setString(lang(skillTableData.name))
        self._skills[2]._imageFire:setVisible(skillType ~= 1 and skillType == 2)
        self._skills[2]._imageWater:setVisible(skillType ~= 1 and skillType == 3)
        self._skills[2]._imageWind:setVisible(skillType ~= 1 and skillType == 4)
        self._skills[2]._imageSoil:setVisible(skillType ~= 1 and skillType == 5)
        self._skills[2]._icon:setVisible(true)

        local labelDiscription = self._labelEffectDes2
        local desc = "[color=c49b65, fontsize=20]" .. self._des .. "[-]"
        local richText = labelDiscription:getChildByName("descRichText")
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
        richText:formatText()
        richText:enablePrinter(true)
        local w = richText:getRealSize().width
        local offsetY = 0
        if w < labelDiscription:getContentSize().width - 30 then
            offsetY = -25
        end
        richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2+offsetY)
        richText:setName("descRichText")
        labelDiscription:addChild(richText)
        if w < labelDiscription:getContentSize().width then
            UIUtils:alignRichText(richText,{hAlign = "left",vAlign = "bottom"})
        else
            UIUtils:alignRichText(richText,{vAlign = "center"})
        end
        self._labelEffectDes1:setVisible(true)
        self._labelEffectDes2:setVisible(true)
        -- if not self._isMastery then
        self._attrBg1:setVisible(not self._isMastery)
        -- end

        self._labelContinue:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
            -- self._labelContinue:setVisible(true)
        end), cc.MoveBy:create(0.1, cc.p(0, 55)), cc.MoveBy:create(0.1, cc.p(0, -5)), cc.CallFunc:create(function()
            self._viewMgr:unlock()
        end)))

    end

    local sizeSchedule
    local step = 0.5
    local stepConst = 30
    local bg1Height = 150
    self._bgImg = self:getUI("bg.layer.bgImg")
    self.bgWidth = self._bgImg:getContentSize().width    
    local maxHeight = self._bgImg:getContentSize().height
    self._bgImg:setOpacity(0)
    self._layer:setVisible(false)    
    self._bgImg:setPositionX(self._layer:getContentSize().width*0.5)
    self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height)) 
    self:animBegin(function( )
        self._bgImg:setOpacity(255)
        self._layer:setVisible(true) 
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))                   
            else
                self._bgImg:setContentSize(cc.size(self.bgWidth,maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
                nextAnimFunc()             
            end
        end)
    end)
end

function HeroSpellBookResultView:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")

    self._bg = self:getUI("bg")
    self:addPopViewTitleAnim(self._bg, "gongxihuode_jihuochenggongui", 568, 480)

    ScheduleMgr:delayCall(400, self, function( )        
        if callback and self._bg then
            callback()
        end

    end)
   
end

function HeroSpellBookResultView:getMaskOpacity()
    return 230
end

return HeroSpellBookResultView