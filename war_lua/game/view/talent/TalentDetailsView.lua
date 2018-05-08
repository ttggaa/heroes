--[[
    Filename:    TalentDetailsView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-04-25 17:11:14
    Description: File description
--]]
local TalentDetailsView = class("TalentDetailsView", BasePopView)

TalentDetailsView.kViewType1 = 1
TalentDetailsView.kViewType2 = 2
TalentDetailsView.kViewType3 = 2 --3

function TalentDetailsView:ctor(params)
    TalentDetailsView.super.ctor(self)

    self._container = params.container
    self._talentKindData = params.talentKindData
    self._talentData = params.talentData
    self._lastLv = params.lastLv
    self._isBig = params.isBig

    self._talentModel = self._modelMgr:getModel("TalentModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
end

function TalentDetailsView:disableTextEffect(element)
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

function TalentDetailsView:onInit()
    self:disableTextEffect()

    self._labelTitle = self:getUI("bg.title_bg.label_title")
    UIUtils:setTitleFormat(self._labelTitle, 1)
    -- self._labelTitle:setFontName(UIUtils.ttfName)

    self._iconPanel = self:getUI("bg.iconPanel")
    self._talentName = self:getUI("bg.iconPanel.talentName")
    -- self._talentName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._skillIcon = self:getUI("bg.iconPanel.skill_icon")
    self._labelValue = self:getUI("bg.iconPanel.label_value")
    self._tipDes = self:getUI("bg.iconPanel.tipDes")
    -- self._tipDes:setPosition(self._tipDes:getPositionX(), self._tipDes:getPositionY() -6)
    local bgtitle1 = self:getUI("bg.image_bg_1.layer_condition.label_condition_title")
    bgtitle1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    self._imageBg1 = {}
    self._imageBg1._layer = self:getUI("bg.image_bg_1")
    self._imageBg1._labelEffectDes = self:getUI("bg.image_bg_1.label_effect_des")
    self._imageBg1._conditions = {}
    for i = 1, 3 do
        self._imageBg1._conditions[i] = {}
        self._imageBg1._conditions[i]._label = self:getUI("bg.image_bg_1.layer_condition.label_condition" .. i)
    end

    self._imageBg2 = {}
    self._imageBg2._layer = self:getUI("bg.image_bg_2")
    self._imageBg2._labelCurrentLevelValue = self:getUI("bg.image_bg_2.label_current_level_value")
    self._imageBg2._labelCurrentLevelValue:getVirtualRenderer():setAdditionalKerning(2)
    self._imageBg2._labelCurrentEffectDes = self:getUI("bg.image_bg_2.layer_effect.label_current_effect_des")
    self._imageBg2._labelCurrentEffect = self:getUI("bg.image_bg_2.layer_effect.label_current_effect")
    self._upgradeMC = mcMgr:createViewMC("shuaxinguangxiao_shuaxinguangxiao", true, false)
    self._upgradeMC:setVisible(false)
    self._imageBg2._labelCurrentEffectDes:addChild(self._upgradeMC, 50)
    self._imageBg2._labelNextEffectDes = self:getUI("bg.image_bg_2.layer_effect.label_next_effect_des")
    self._imageBg2._labelNextEffect = self:getUI("bg.image_bg_2.layer_effect.label_next_effect")
    self._imageBg2._labelStarValue = self:getUI("bg.image_bg_2.label_star_value")
    self._imageBg2._labelStarValue:getVirtualRenderer():setAdditionalKerning(2)
    self._imageBg2._btnUpgrade = self:getUI("bg.image_bg_2.btn_upgrade")

    self._imageBg3 = {}
    self._imageBg3._layer = self:getUI("bg.image_bg_3")
    self._imageBg3._labelCurrentLevelValue = self:getUI("bg.image_bg_3.label_current_level_value")
    self._imageBg3._labelCurrentLevelValue:enableOutline(cc.c4b(0, 78, 0, 255), 1)
    self._imageBg3._labelCurrentLevelValue:getVirtualRenderer():setAdditionalKerning(2)
    self._imageBg3._labelCurrentEffectDes = self:getUI("bg.image_bg_3.layer_effect.label_top_level_effect_des")
    self._imageBg3._labelCurrentEffect = self:getUI("bg.image_bg_3.layer_effect.label_top_level_effect")
    self._upgradeMCMax = mcMgr:createViewMC("shuaxinguangxiao_shuaxinguangxiao", true, false)
    self._upgradeMCMax:setVisible(false)
    self._imageBg3._labelCurrentEffectDes:addChild(self._upgradeMCMax, 50)

    self:updateUI()

    self:registerClickEventByName("bg.btn_close", function ()
        self:doClose()
    end)
    self:registerClickEventByName("bg.image_bg_1.btn_close", function ()
        self:doClose()
    end)
end

function TalentDetailsView:setContext(context)
    self._talentKindData = context.talentKindData
    self._talentData = context.talentData
end

function TalentDetailsView:getTalentKindData(talentKindId)
    for k, v in pairs(self._talentInfo) do
        if tonumber(k) == talentKindId then
            return true, v
        end
    end
    return false
end

function TalentDetailsView:getTalentChildData(talentKindId, talentId)
    for k, v in pairs(self._talentInfo) do
        if tonumber(k) == talentKindId then
            for k0, v0 in pairs(v.cl) do
                if tonumber(k0) == talentId then
                    return true, v0
                end
            end
        end
    end
    return false
end

function TalentDetailsView:updateUI()
    self._talentInfo = self._talentModel:getData()

    self:updateIconPanel()
    self._imageBg1._layer:setVisible(0 == self._talentData.s and self._talentData.l < self._talentData.maxLevel)
    self._imageBg2._layer:setVisible(1 == self._talentData.s and self._talentData.l < self._talentData.maxLevel)
    self._imageBg3._layer:setVisible(self._talentData.l >= self._talentData.maxLevel)
    if self._talentData.l < self._talentData.maxLevel then
        if 0 == self._talentData.s then
            self:updateViewType1()
        else
            self:updateViewType2()
        end
    else
        self:updateViewType3()
    end
end

function TalentDetailsView:updateIconPanel()
    self._talentName:setString(lang(self._talentData.name))
    self._skillIcon:loadTexture((self._talentData.res or self._talentData.icon) .. ".png",1)
    self._labelValue:setString(string.format("%d/%d", self._talentData.l, self._talentData.maxLevel))
    if self._talentData.l >= self._talentData.maxLevel then
        self._labelValue:setColor(cc.c3b(121, 249, 0))
        self._labelValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    else
        self._labelValue:setColor(cc.c3b(255, 255, 255))
        self._labelValue:disableEffect()
    end
    self._tipDes:setString("（" .. lang(self._talentData.desFi) .. "）")

    local iconBg = self:getUI("bg.iconPanel.skill_icon_bg")
    if self._isBig == true then
        iconBg:loadTexture("hero_skill_bg1_forma.png", 1)
    else
        iconBg:loadTexture("hero_skill_bg2_forma.png", 1)
    end
end
function TalentDetailsView:updateViewType1()
    --print("updateViewType1")
    local desc = "[color=77461b, fontsize=22]　　　" .. self._container:getDescription(self._talentData) .. "[-]"
    local label = self._imageBg1._labelEffectDes
    local richText = label:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, 345, 70)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height - richText:getInnerSize().height)
    richText:setName("descRichText")
    label:addChild(richText)
    for i = 1, 3 do
        self._imageBg1._conditions[i]._label:setVisible(false)
    end

    for k, v in ipairs(self._talentData.condition) do
        local color = cc.c3b(118, 238, 0)
        local outlineColor = cc.c4b(0, 78, 0)
        local labelCondition = ""
        local labelConditionStatus = "0/0"
        local finish = true
        if 1 == v[1] then
            local userLevel = self._userModel:getData().lvl
            if userLevel < v[2] then
                finish = false
            end
            labelCondition = "玩家等级" .. v[2]
            labelConditionStatus = string.format("%d/%d", userLevel, v[2])
        elseif 2 == v[1] then
            local talentTableData = tab:MagicTalent(v[2])
            local found, talentData = self:getTalentChildData(self._talentKindData.id, v[2])
            if not found or talentData.l < v[3] then
                finish = false
            end
            labelCondition = lang(talentTableData.name) .. "达到" .. v[3] .. "级"
            labelConditionStatus = string.format("%d/%d", found and talentData.l or 0, v[3])
        elseif 3 == v[1] then
            local talentKindTableData = tab:MagicSeries(v[2])
            local found, talentKindData = self:getTalentKindData(v[2])
            if not found or talentKindData.l < v[3] then
                finish = false
            end
            labelCondition = lang(talentKindTableData.name) .. "达到" .. v[3] .. "级"
            labelConditionStatus = string.format("%d/%d", found and talentKindData.l or 0, v[3])
        end
        if not finish then
            self._imageBg1._conditions[k]._label:setColor(UIUtils.colorTable.ccUIBaseColor6)
        else
            self._imageBg1._conditions[k]._label:disableEffect()
        end

        self._imageBg1._conditions[k]._label:setVisible(true)
        self._imageBg1._conditions[k]._label:setString(labelCondition)
    end
end

function TalentDetailsView:updateViewType2()
    --print("updateViewType2")
    self._imageBg2._labelCurrentLevelValue:setString(string.format("%d/%d", self._talentData.l, self._talentData.maxLevel))
    local desc = ""
    if 0 == self._talentData.l then
        desc = "[color=8a5c1d, fontsize=20]无[-]"
    else
        desc = "[color=8a5c1d, fontsize=20]" .. self._container:getDescription(self._talentData) .. "[-]"
    end
    local label = self._imageBg2._labelCurrentEffectDes
    local richText = label:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, label:getContentSize().width, label:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height - 15)
    richText:setName("descRichText")
    label:addChild(richText)

    if self._upgradeClicked then
        self._upgradeMC:addEndCallback(function()
            self._upgradeMC:stop()
            self._upgradeMC:setVisible(false)
        end)
        self._upgradeMC:gotoAndPlay(0)
        self._upgradeMC:setVisible(true)
        self._upgradeMC:setPosition(cc.p(richText:getPosition()))
        self._upgradeClicked = false
    end

    if self._talentData.l < self._talentData.maxLevel then
        local nextLevelTalentData = clone(self._talentData)
        nextLevelTalentData.l = nextLevelTalentData.l + 1
        local desc = "[color=8a5c1d, fontsize=20]" .. self._container:getDescription(nextLevelTalentData) .. "[-]"
        local label = self._imageBg2._labelNextEffectDes
        local richText = label:getChildByName("descRichText")
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, label:getContentSize().width, label:getContentSize().height)
        richText:formatText()
        richText:enablePrinter(true)
        richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height - 15)
        richText:setName("descRichText")
        label:addChild(richText)

        local have, cost = self._userModel:getData().starNum, self._talentData.cost[self._talentData.l + 1]
        self._imageBg2._labelStarValue:setString(cost)
        self._imageBg2._btnUpgrade:setBright(have >= cost)
        self._imageBg2._btnUpgrade:setSaturation(have >= cost and 0 or -100)
        self:registerClickEvent(self._imageBg2._btnUpgrade, function ()
            if have < cost then
                self._viewMgr:showTip(lang("magicResetTip_4"))
                return 
            end
            self._upgradeClicked = true
            self._container:onUpTalentChildLvButtonClicked(self._talentKindData, self._talentData)
        end)
    end
end

function TalentDetailsView:updateViewType3()
    self._imageBg3._labelCurrentLevelValue:setString(string.format("%d/%d", self._talentData.l, self._talentData.maxLevel))
    local desc = "[color=c44904, fontsize=20]" .. self._container:getDescription(self._talentData) .. "[-]"
    local label = self._imageBg3._labelCurrentEffectDes
    local richText = label:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, label:getContentSize().width, label:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setAnchorPoint(cc.p(0.5, 1))
    richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height + 20)
    richText:setName("descRichText")
    label:addChild(richText)

    if self._upgradeClicked then
        self._upgradeMCMax:addEndCallback(function()
            self._upgradeMCMax:stop()
            self._upgradeMCMax:setVisible(false)
        end)
        self._upgradeMCMax:gotoAndPlay(0)
        self._upgradeMCMax:setVisible(true)
        self._upgradeMCMax:setPosition(cc.p(richText:getPosition()))
        self._upgradeClicked = false
    end
end

function TalentDetailsView:doClose()
    --升级 / 升到最大级
    local isLevelUp = self._talentData.l > self._lastLv and self._talentData.l >= self._talentData.maxLevel
    self._container:onTalentDetailsViewClose(isLevelUp)
    self._modelMgr:getModel("GuildRedModel"):checkRandRed()
    -- UIUtils.reloadLuaFile("talent.TalentDetailsView")
    self:close()
end

return TalentDetailsView