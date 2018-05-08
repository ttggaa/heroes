--[[
    Filename:    HeroUpgradeResultView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-04-08 19:52:31
    Description: File description
--]]
local HeroUpgradeResultView = class("HeroUpgradeResultView", BasePopView)

HeroUpgradeResultView.kHeroTag = 1000

function HeroUpgradeResultView:ctor(params)
    HeroUpgradeResultView.super.ctor(self)
    self._heroData = params.heroData
    self._oldHeroData = params.oldheroData
    self._callback = params.callback
    self._heroModel = self._modelMgr:getModel("HeroModel")
end

function HeroUpgradeResultView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        local name = element:getName()
        if name ~= "label_continue" then
            element:disableEffect()
        end
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

function HeroUpgradeResultView:onInit()
    self:disableTextEffect()

    self._bg = self:getUI("bg")
    self._layer = self:getUI("bg.layer")
    self._imageArrow = self:getUI("bg.layer.image_arrow")
    self._imageArrow:setVisible(false)
    self._layerIcon1 = self:getUI("bg.layer.layer_icon_1")
    self._layerIcon1:setVisible(false)
    self._layerIcon2 = self:getUI("bg.layer.layer_icon_2")
    self._layerIcon2:setVisible(false)

    self._atkBg = self:getUI("bg.layer.layer_attribute.image_atk_bg")
    self._atkBg:setVisible(false)
    self._defBg = self:getUI("bg.layer.layer_attribute.image_def_bg")
    self._defBg:setVisible(false)
    self._intBg = self:getUI("bg.layer.layer_attribute.image_int_bg")
    self._intBg:setVisible(false)
    self._ackBg = self:getUI("bg.layer.layer_attribute.image_ack_bg")
    self._ackBg:setVisible(false)

    self._fight = self:getUI("bg.layer.layer_attribute.image_fight_bg")
    self._fight:setVisible(false)
    self._oldFight = self:getUI("bg.layer.layer_attribute.image_fight_bg.oldFight")
    self._oldFight:setString("a" .. self._oldHeroData.score)
    self._oldFight:setFntFile(UIUtils.bmfName_zhandouli)
    self._oldFight:setScale(0.5)
    local heroDataM = self._modelMgr:getModel("HeroModel"):getData()
    local heroId = self._heroData.id
    local fightScore = heroDataM[tostring(heroId)].score
    self._newFight = self:getUI("bg.layer.layer_attribute.image_fight_bg.newFight")
    self._newFight:setString("a" .. fightScore)
    self._newFight:setFntFile(UIUtils.bmfName_zhandouli)
    self._newFight:setScale(0.5)

    self._imageAttr1 = self:getUI("bg.layer.layer_attribute.image_attr_1")
    self._imageAttrIcon1 = self:getUI("bg.layer.layer_attribute.image_attr_1.image_icon")
    self._labelAttrName1 = self:getUI("bg.layer.layer_attribute.image_attr_1.label_name")
    self._labelAttr1 = self:getUI("bg.layer.layer_attribute.image_attr_1.label_current_value")
    self._labelAttr1:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    self._labelAttr1:getVirtualRenderer():setAdditionalKerning(1)
    self._labelNextAttr1 = self:getUI("bg.layer.layer_attribute.image_attr_1.label_next_value")
    self._labelNextAttr1:enableOutline(cc.c4b(0, 78, 0, 255), 1)
    self._labelNextAttr1:getVirtualRenderer():setAdditionalKerning(1)

    self._imageAttr2 = self:getUI("bg.layer.layer_attribute.image_attr_2")
    self._imageAttrIcon2 = self:getUI("bg.layer.layer_attribute.image_attr_2.image_icon")
    self._labelAttrName2 = self:getUI("bg.layer.layer_attribute.image_attr_2.label_name")
    self._labelAttr2 = self:getUI("bg.layer.layer_attribute.image_attr_2.label_current_value")
    self._labelAttr2:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    self._labelAttr2:getVirtualRenderer():setAdditionalKerning(1)
    self._labelNextAttr2 = self:getUI("bg.layer.layer_attribute.image_attr_2.label_next_value")
    self._labelNextAttr2:enableOutline(cc.c4b(0, 78, 0, 255), 1)
    self._labelNextAttr2:getVirtualRenderer():setAdditionalKerning(1)

    --[[
    self._currentAtkValue = self:getUI("bg.layer.layer_attribute.image_atk_bg.label_current_value")
    self._currentAtkValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    self._currentAtkValue:getVirtualRenderer():setAdditionalKerning(1)
    self._currentDefValue = self:getUI("bg.layer.layer_attribute.image_def_bg.label_current_value")
    self._currentDefValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    self._currentDefValue:getVirtualRenderer():setAdditionalKerning(1)
    self._currentIntValue = self:getUI("bg.layer.layer_attribute.image_int_bg.label_current_value")
    self._currentIntValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    self._currentIntValue:getVirtualRenderer():setAdditionalKerning(1)
    self._currentAckValue = self:getUI("bg.layer.layer_attribute.image_ack_bg.label_current_value")
    self._currentAckValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    self._currentAckValue:getVirtualRenderer():setAdditionalKerning(1)

    self._nextAtkValue = self:getUI("bg.layer.layer_attribute.image_atk_bg.label_next_value")
    self._nextAtkValue:enableOutline(cc.c4b(0, 78, 0, 255), 1)
    self._nextAtkValue:getVirtualRenderer():setAdditionalKerning(1)
    self._nextDefValue = self:getUI("bg.layer.layer_attribute.image_def_bg.label_next_value")
    self._nextDefValue:enableOutline(cc.c4b(0, 78, 0, 255), 1)
    self._nextDefValue:getVirtualRenderer():setAdditionalKerning(1)
    self._nextIntValue = self:getUI("bg.layer.layer_attribute.image_int_bg.label_next_value")
    self._nextIntValue:enableOutline(cc.c4b(0, 78, 0, 255), 1)
    self._nextIntValue:getVirtualRenderer():setAdditionalKerning(1)
    self._nextAckValue = self:getUI("bg.layer.layer_attribute.image_ack_bg.label_next_value")
    self._nextAckValue:enableOutline(cc.c4b(0, 78, 0, 255), 1)
    self._nextAckValue:getVirtualRenderer():setAdditionalKerning(1)
    ]]
    self._imageSpecialtyUnlock = self:getUI("bg.layer.image_specialty_unlock")
    self._imageSpecialtyUnlock:setVisible(false)
    self._imageSpecialtyUnlock:setPositionX(self._imageSpecialtyUnlock:getPositionX() - 300)
    self._layerSpecialty = self:getUI("bg.layer.layer_specialty")
    self._layerSpecialty:setVisible(false)
    self._layerSpecialty:setPositionX(self._layerSpecialty:getPositionX() + 300)
    self._specialtyIcon = self:getUI("bg.layer.layer_specialty.image_hero_specialty")
    self._specialtyDescription = self:getUI("bg.layer.layer_specialty.layer_specialty_description")
    self._labelGlobalTitle = self:getUI("bg.layer.layer_specialty.label_global_title")
    

    self._labelContinue = self:getUI("bg.layer.label_continue")
    self._labelContinue:setVisible(false)
    self._labelContinue:setPositionY(self._labelContinue:getPositionY() - 50)

    self._heroStar = {}
    for i=1, 4 do
        self._heroStar[i] = self:getUI("bg.layer.layer_specialty.image_hero_star_" .. i)
    end

    local layer = ccui.Layout:create()
    layer:setTouchEnabled(true)
    layer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._bg:getParent():addChild(layer,10)

    self._viewMgr:lock()

    self:registerClickEvent(layer, function()
        layer:setTouchEnabled(false)
        if self._callback then
            self._callback()
        end
        self:close()
        UIUtils:reloadLuaFile("hero.HeroUpgradeResultView")
    end)

    self:updateUI()
end

function HeroUpgradeResultView:updateUI()
    -- audioMgr:playSound("adTitle")

    local currentHeroData = clone(self._heroData)
    if currentHeroData.star then
        currentHeroData.star = currentHeroData.star - 1
    end
    local nextHeroData = clone(self._heroData)
    local star = currentHeroData.star
    local nextStar = nextHeroData.star
    local heroTableData = tab:Hero(self._heroData.id)
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "英雄攻击", def = "英雄防御", int = "英雄智力", ack = "英雄知识"}
    local index = 1
    local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local value = 0
            if self._heroModel:checkHero(self._heroData.id) then
                value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]
            end
            self["_imageAttrIcon" .. index]:loadTexture(att .. "_icon3_hero.png", 1)
            self["_labelAttrName" .. index]:setString(attributesName[att] .. "：")
            self["_labelAttr" .. index]:setString(string.format("%d", value))
            value = heroTableData[att][1] + (nextStar - 1) * heroTableData[att][2]
            self["_labelNextAttr" .. index]:setString(string.format("%d", value))
            index = math.min(index + 1, 2)
        end
    end


    local nextAnimFunc = function()

        local currentHeroData = clone(self._heroData)
        if currentHeroData.star then
            currentHeroData.star = currentHeroData.star - 1
        end

        local icon = self._layerIcon1:getChildByTag(HeroUpgradeResultView.kHeroTag)
        if not icon then
            icon = IconUtils:createHeroIconById({sysHeroData = currentHeroData})
            icon:setTag(HeroUpgradeResultView.kHeroTag)
            icon:setPosition(self._layerIcon1:getContentSize().width / 2, self._layerIcon1:getContentSize().height / 2)
            self._layerIcon1:addChild(icon)
        else
            IconUtils:updateHeroIconByView(self._layerIcon1, {sysHeroData = currentHeroData})
        end

        self._layerIcon1:setVisible(true)
        self._layerIcon1:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(-10, 0)), cc.MoveBy:create(0.1, cc.p(10, 0))))

        local nextHeroData = clone(self._heroData)
        local icon = self._layerIcon2:getChildByTag(HeroUpgradeResultView.kHeroTag)
        if not icon then
            icon = IconUtils:createHeroIconById({sysHeroData = nextHeroData})
            icon:setTag(HeroUpgradeResultView.kHeroTag)
            icon:setPosition(self._layerIcon2:getContentSize().width / 2, self._layerIcon2:getContentSize().height / 2)
            self._layerIcon2:addChild(icon)
        else
            IconUtils:updateHeroIconByView(self._layerIcon2, {sysHeroData = nextHeroData})
        end

        self._layerIcon2:setVisible(true)
        self._layerIcon2:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(10, 0)), cc.MoveBy:create(0.1, cc.p(-10, 0))))

        local star = currentHeroData.star
        local nextStar = nextHeroData.star
        local heroTableData = tab:Hero(self._heroData.id)
        local attributes = {"atk", "def", "int", "ack"}
        local attributesName = {atk = "英雄攻击", def = "英雄防御", int = "英雄智力", ack = "英雄知识"}
        local index = 1
        local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
        for _, att in ipairs(attributes) do
            if heroTableData[att] then
                local value = 0
                if self._heroModel:checkHero(self._heroData.id) then
                    value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]
                end
                self["_imageAttrIcon" .. index]:loadTexture(att .. "_icon3_hero.png", 1)
                self["_labelAttrName" .. index]:setString(attributesName[att] .. "：")
                self["_labelAttr" .. index]:setVisible(true)
                self["_labelAttr" .. index]:setString(string.format("%d", value))
                value = heroTableData[att][1] + (nextStar - 1) * heroTableData[att][2]
                self["_labelNextAttr" .. index]:setVisible(true)
                self["_labelNextAttr" .. index]:setString(string.format("%d", value))
                index = math.min(index + 1, 2)
            end
        end
        --[[
        local value = self._heroData.atk[1] + (star - heroTableData.star) * self._heroData.atk[2]
        self._currentAtkValue:setString(string.format("%d", value))
        value = self._heroData.def[1] + (star - heroTableData.star) * self._heroData.def[2]
        self._currentDefValue:setString(string.format("%d", value))
        value = self._heroData.int[1] + (star - heroTableData.star) * self._heroData.int[2]
        self._currentIntValue:setString(string.format("%d", value))
        value = self._heroData.ack[1] + (star - heroTableData.star) * self._heroData.ack[2]
        self._currentAckValue:setString(string.format("%d", value))

        value = self._heroData.atk[1] + (nextStar - heroTableData.star) * self._heroData.atk[2]
        self._nextAtkValue:setString(string.format("%d", value))
        value = self._heroData.def[1] + (nextStar - heroTableData.star) * self._heroData.def[2]
        self._nextDefValue:setString(string.format("%d", value))
        value = self._heroData.int[1] + (nextStar - heroTableData.star) * self._heroData.int[2]
        self._nextIntValue:setString(string.format("%d", value))
        value = self._heroData.ack[1] + (nextStar - heroTableData.star) * self._heroData.ack[2]
        self._nextAckValue:setString(string.format("%d", value))
        ]]

        local attributeName = { "_fight" }

        for _, att in ipairs(attributes) do
            if heroTableData[att] then
                table.insert(attributeName, "_" .. attributesName[att] .. "Bg")
            end
        end

        local runAttributeAction = nil
        runAttributeAction = function(index)
            if index > #attributeName then return end
            local attributeBg = self[attributeName[index]]
            if not attributeBg then return end

            local mc = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", false, true)
            mc:setPosition(cc.p(attributeBg:getPositionX() + attributeBg:getContentSize().width / 2 - 80, attributeBg:getPositionY() + attributeBg:getContentSize().height / 2))
            attributeBg:getParent():addChild(mc)

            attributeBg:runAction(
            cc.Sequence:create(cc.CallFunc:create(function()
                attributeBg:setVisible(true)
            end),cc.MoveBy:create(0.1, cc.p(0, 10)), 
            cc.MoveBy:create(0.1, cc.p(0, -10)), cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                runAttributeAction(index + 1)
            end)))
        end

        runAttributeAction(1)

        local star = self._heroData.star
        local specials = self._heroData.specialtyInfo.specials
        self._specialtyIcon:loadTexture(IconUtils.iconPath .. specials[1].icon .. ".jpg", 1)
        --self._specialtyName:setString(lang("HEROSPECIAL_" .. self._heroData.special))
        local labelDiscription = self._specialtyDescription
        local specialData = specials[star]

        local desc = "[color=E0AD74, fontsize=20]" .. lang(specialData.des) .. "[-]"
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

        self._labelGlobalTitle:setVisible(1 == specialData.global)

        for i=1, 4 do
            self._heroStar[i]:setVisible(i == self._heroData.star)
        end

        self._imageSpecialtyUnlock:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
                self._imageSpecialtyUnlock:setVisible(true)
            end), cc.MoveBy:create(0.2, cc.p(310, 0)), 
            cc.MoveBy:create(0.1, cc.p(-10, 0))--[[, cc.CallFunc:create(function()
                local mc = mcMgr:createViewMC("shanguang_intancenopen", false, true)
                mc:setPosition(cc.p(self._imageSpecialtyUnlock:getPositionX() + self._imageSpecialtyUnlock:getContentSize().width / 2, self._imageSpecialtyUnlock:getPositionY()))
                self._imageSpecialtyUnlock:getParent():addChild(mc, 100)
            end)]]))

        self._layerSpecialty:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
                self._layerSpecialty:setVisible(true)
            end), cc.MoveBy:create(0.2, cc.p(-310, 0)), 
            cc.MoveBy:create(0.1, cc.p(10, 0))))

        self._labelContinue:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
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

function HeroUpgradeResultView:animBegin(callback)
    -- 播放获得音效
    audioMgr:playSound("ItemGain_1")

    self._bg = self:getUI("bg")
    --升星成功
    self:addPopViewTitleAnim(self._bg, "shengxingchenggong_huodetitleanim", 568, 480)

    ScheduleMgr:delayCall(400, self, function( )
        if self._bg then                    
            --震屏
            -- UIUtils:shakeWindow(self._bg)
            -- ScheduleMgr:delayCall(200, self, function( )
            if callback and self._bg then
                callback()
            end
            -- end)
        end
    end)
   
end

function HeroUpgradeResultView:getMaskOpacity()
    return 230
end

return HeroUpgradeResultView