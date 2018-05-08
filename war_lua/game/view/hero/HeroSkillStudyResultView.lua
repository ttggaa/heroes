--[[
    Filename:    HeroSkillStudyResultView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-02-16 11:06:08
    Description: File description
--]]
local HeroSkillStudyResultView = class("HeroSkillStudyResultView", BasePopView)

function HeroSkillStudyResultView:ctor(params)
    HeroSkillStudyResultView.super.ctor(self)
    self._heroData = params.heroData
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._skillIndex = params.skillIndex
    self._currentLevelAttributeValues = params.currentLevelAttributeValues
    self._nextLevelAttributeValues = params.nextLevelAttributeValues
    self._oldLevel = params.oldLevel
    self._newLevel = params.newLevel
    self._callback = params.callback
end

function HeroSkillStudyResultView:disableTextEffect(element)
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

function HeroSkillStudyResultView:onInit()
    self:disableTextEffect()
    self._bg = self:getUI("bg")
    self._imageArrow = self:getUI("bg.layer.image_arrow")
    self._imageArrow:setVisible(false)
    self._labelEffectDes1 = self:getUI("bg.layer.layer_des_bg.label_effect_des_1")
    self._labelEffectDes1:setVisible(false)
    self._imageDesArrow = self:getUI("bg.layer.layer_des_bg.image_arrow")
    self._imageDesArrow:setVisible(false)
    self._labelEffectDes2 = self:getUI("bg.layer.layer_des_bg.label_effect_des_2")
    self._labelEffectDes2:setVisible(false)

    self._attrBg = self:getUI("bg.layer.layer_des_bg.attrBg")
    self._attrBg:setVisible(false)
    self._oldLabel = self:getUI("bg.layer.layer_des_bg.attrBg.oldLabel")
    self._newLabel = self:getUI("bg.layer.layer_des_bg.attrBg.newLable")
    self._oldLabel:setFontName(UIUtils.ttfName)
    self._newLabel:setFontName(UIUtils.ttfName)
    
    self._oldLabel:setString(self._oldLevel .. "阶")
    self._newLabel:setString(self._newLevel .. "阶")
    self._skills = {}
    self._skills[2] = {}
    self._skills[2]._icon = self:getUI("bg.layer.skill_icon_2")
    self._skills[2]._icon:setVisible(false)
    self._skills[2]._imageFire = self:getUI("bg.layer.skill_icon_2.image_fire")
    self._skills[2]._imageWater = self:getUI("bg.layer.skill_icon_2.image_water")
    self._skills[2]._imageWind = self:getUI("bg.layer.skill_icon_2.image_wind")
    self._skills[2]._imageSoil = self:getUI("bg.layer.skill_icon_2.image_soil")
    self._skills[2]._labelSkillName = self:getUI("bg.layer.skill_icon_2.label_skill_name")
    self._skills[2]._labelSkillLevel = self:getUI("bg.layer.skill_icon_2.label_skill_level")
   
    self._layer = self:getUI("bg.layer")

    -- for i = 1, 2 do
    --     self._skills[i] = {}
    --     self._skills[i]._icon = self:getUI("bg.layer.skill_icon_" .. i)
    --     self._skills[i]._icon:setVisible(false)
    --     self._skills[i]._imageFire = self:getUI("bg.layer.skill_icon_" .. i .. ".image_fire")
    --     -- self._skills[i]._imageFireCircle = self:getUI("bg.layer.skill_icon_" .. i .. ".image_fire_circle")
    --     self._skills[i]._imageWater = self:getUI("bg.layer.skill_icon_" .. i .. ".image_water")
    --     -- self._skills[i]._imageWaterCircle = self:getUI("bg.layer.skill_icon_" .. i .. ".image_water_circle")
    --     self._skills[i]._imageWind = self:getUI("bg.layer.skill_icon_" .. i .. ".image_wind")
    --     -- self._skills[i]._imageWindCircle = self:getUI("bg.layer.skill_icon_" .. i .. ".image_wind_circle")
    --     self._skills[i]._imageSoil = self:getUI("bg.layer.skill_icon_" .. i .. ".image_soil")
    --     -- self._skills[i]._imageSoilCircle = self:getUI("bg.layer.skill_icon_" .. i .. ".image_soil_circle")
    --     self._skills[i]._labelSkillName = self:getUI("bg.layer.skill_icon_" .. i .. ".label_skill_name")
    --     self._skills[i]._labelSkillLevel = self:getUI("bg.layer.skill_icon_" .. i .. ".label_skill_level")
    -- end
    --[[
    self._labelManaValue1 = self:getUI("bg.layer.layer_des_bg.label_mana_value_1")
    self._labelManaValue1:enableOutline(cc.c4b(95, 38, 0, 255), 2)
    self._labelManaValue2 = self:getUI("bg.layer.layer_des_bg.label_mana_value_2")
    self._labelManaValue2:enableOutline(cc.c4b(0, 78, 0, 255), 2)

    self._labelCDValue1 = self:getUI("bg.layer.layer_des_bg.label_cd_value_1")
    self._labelCDValue1:enableOutline(cc.c4b(95, 38, 0, 255), 2)
    self._labelCDValue2 = self:getUI("bg.layer.layer_des_bg.label_cd_value_2")
    self._labelCDValue2:enableOutline(cc.c4b(0, 78, 0, 255), 2)
    ]]

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
        UIUtils:reloadLuaFile("hero.HeroSkillStudyResultView")
    end)
    self._viewMgr:lock()
    self:updateUI()
end

function HeroSkillStudyResultView:updateUI()
    -- audioMgr:playSound("adTitle")

    local nextAnimFunc = function()      
        local index = self._skillIndex
        local skillId = self._heroData.spell[index] or (self._heroData.slot and self._heroData.slot.sid)
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end

        local idTemp = skillId   --不加后缀，取法术id   by wangyan
        local isMastery = not tab:PlayerSkillEffect(skillId)
        if isMastery then
            local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(skillId)]
            if bookInfo and tonumber(bookInfo.l) > 1 then
                skillId = tonumber(skillId .. (bookInfo.l-1))
            end
        end
        local skillTableData = tab:PlayerSkillEffect(skillId) or tab:HeroMastery(skillId)
        local skillData = self._currentLevelAttributeValues.skills
        -- 等级
        local skillLevel = (isMastery and self._heroData.slot and self._heroData.slot.sLvl) or (skillData[index] and skillData[index][2]) or 1
        -- 阶级
        local skLevel = (isMastery and self._heroData.slot and self._heroData.slot.s) or (skillData[index] and skillData[index][2]) or  1
        local skillType = skillTableData.type

        self._nextLevelAttributeValues.sklevel = self._newLevel or skLevel
        self._nextLevelAttributeValues.artifactlv = skillLevel

        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. (skillTableData.art or skillTableData.icon) .. ".png")
        icon:setScale(0.7)
        icon:setPosition(self._skills[2]._icon:getContentSize().width / 2, self._skills[2]._icon:getContentSize().height / 2)
        self._skills[2]._icon:addChild(icon)

        local color = UIUtils.colorTable["ccUIHeroSkillColor" .. skillType]
        self._skills[2]._labelSkillName:setColor(color)        
        self._skills[2]._labelSkillName:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self._skills[2]._labelSkillName:setString(lang(skillTableData.name))

        --add  by wangyan
        local sysSkillData = tab.skillBookBase[idTemp]
        local imgRes = {"skill_bg_fire01_hero", "skill_bg_water01_hero", "skill_bg_wind01_hero", "skill_bg_soil01_hero"}
        local iconList = {self._skills[2]._imageFire, self._skills[2]._imageWater, self._skills[2]._imageWind, self._skills[2]._imageSoil}
        if sysSkillData and sysSkillData["type"] == 4 then
            for i=1, 4 do
                iconList[i]:loadTexture(imgRes[i] .. ".png", 1)
            end
        end
        
        self._skills[2]._imageFire:setVisible(skillType ~= 1 and skillType == 2)
        self._skills[2]._imageWater:setVisible(skillType ~= 1 and skillType == 3)
        self._skills[2]._imageWind:setVisible(skillType ~= 1 and skillType == 4)
        self._skills[2]._imageSoil:setVisible(skillType ~= 1 and skillType == 5)
        self._skills[2]._icon:setVisible(true)
        -- self._skills[2]._icon:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(1 == i and -10 or 10, 0)), cc.MoveBy:create(0.1, cc.p(1 == i and 10 or -10, 0))))
        

        -- for i = 1, 2 do
        --     local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillTableData.art .. ".png")
        --     icon:setScale(0.7)
        --     icon:setPosition(self._skills[i]._icon:getContentSize().width / 2, self._skills[i]._icon:getContentSize().height / 2)
        --     self._skills[i]._icon:addChild(icon)
        --     --[[
        --     local color = cc.c3b(167, 133, 88)
        --     if skillType == 1  then
        --         color = cc.c3b(117, 73, 34)
        --     elseif skillType == 2 then
        --         color = cc.c3b(178, 46, 47)
        --     elseif skillType == 3 then
        --         color = cc.c3b(56, 72, 185)
        --     elseif skillType == 4 then
        --         color = cc.c3b(103, 154, 182)
        --     elseif skillType == 5 then
        --         color = cc.c3b(115, 145, 13)
        --     end

        --     self._skills[i]._labelSkillName:setColor(color)
        --     ]]
        --     self._skills[i]._labelSkillName:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        --     self._skills[i]._labelSkillName:setString(lang(skillTableData.name))

        --     self._skills[i]._imageFire:setVisible(skillType ~= 1 and skillType == 2)
        --     -- self._skills[i]._imageFireCircle:setVisible(skillType ~= 1 and skillType == 2)

        --     self._skills[i]._imageWater:setVisible(skillType ~= 1 and skillType == 3)
        --     -- self._skills[i]._imageWaterCircle:setVisible(skillType ~= 1 and skillType == 3)

        --     self._skills[i]._imageWind:setVisible(skillType ~= 1 and skillType == 4)
        --     -- self._skills[i]._imageWindCircle:setVisible(skillType ~= 1 and skillType == 4)

        --     self._skills[i]._imageSoil:setVisible(skillType ~= 1 and skillType == 5)
        --     -- self._skills[i]._imageSoilCircle:setVisible(skillType ~= 1 and skillType == 5)

        --     --self._skills[i]._labelSkillLevel:setColor(color)
        --     self._skills[i]._labelSkillLevel:setString(self._heroData["sl" .. self._skillIndex] - 1 + (i - 1) .. "阶")

        --     self._skills[i]._icon:setVisible(true)
        --     self._skills[i]._icon:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(1 == i and -10 or 10, 0)), cc.MoveBy:create(0.1, cc.p(1 == i and 10 or -10, 0))))
        -- end

        -- local labelDiscription = self._labelEffectDes1
        -- local desc = "[color=c49b65, fontsize=22]" .. BattleUtils.getDescription(BattleUtils.kIconTypeSkill, skillTableData.id, self._currentLevelAttributeValues, self._skillIndex, "PLAYERSKILLDES_" .. skillTableData.id) .. "[-]"
        -- local richText = labelDiscription:getChildByName("descRichText")
        -- if richText then
        --     richText:removeFromParentAndCleanup()
        -- end
        -- richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
        -- richText:formatText()
        -- richText:enablePrinter(true)
        -- richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
        -- richText:setName("descRichText")
        -- labelDiscription:addChild(richText)
        local labelDiscription = self._labelEffectDes2
        local desc = "[color=c49b65, fontsize=22]" .. BattleUtils.getDescription(isMastery and BattleUtils.kIconTypeHeroMastery or BattleUtils.kIconTypeSkill, skillTableData.id, self._nextLevelAttributeValues, self._skillIndex, not isMastery and ("PLAYERSKILLDES_" .. skillTableData.id)) .. "[-]"
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

        --[[
        self._labelCDValue1:setString(tostring(math.round((skillTableData.cd[1] - skillStage * skillTableData.cd[2]) / 1000)))
        self._labelManaValue1:setString(tostring(skillTableData.manacost[1] - skillStage * skillTableData.manacost[2]))

        local skillNextData = self._nextLevelAttributeValues.skills
        local skillNextStage = skillNextData[index][2]
        local skillNextLevel = skillNextData[index][3]
        self._labelCDValue2:setString(tostring(math.round((skillTableData.cd[1] - skillNextStage * skillTableData.cd[2]) / 1000)))
        self._labelManaValue2:setString(tostring(skillTableData.manacost[1] - skillNextStage * skillTableData.manacost[2]))
        ]]

        self._labelEffectDes2:setVisible(true)
        self._attrBg:setVisible(true)
        self._imageDesArrow:setVisible(true)        

        self._labelContinue:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
            self._labelContinue:setVisible(true)
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

function HeroSkillStudyResultView:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")

    self._bg = self:getUI("bg")
    self:addPopViewTitleAnim(self._bg, "jinjiechenggong_huodetitleanim", 568, 480)

    ScheduleMgr:delayCall(400, self, function( )        
        if callback and self._bg then
            callback()
        end

    end)
   
end

function HeroSkillStudyResultView:getMaskOpacity()
    return 230
end

return HeroSkillStudyResultView