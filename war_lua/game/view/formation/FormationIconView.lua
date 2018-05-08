--[[
    Filename:    FormationIconView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-06-18 14:29:40
    Description: File description
--]]

local tab = tab
local lang = lang
local SkillUtils = SkillUtils

local FormationIconView = class("FormationIconView", BaseMvcs , BaseEvent, function()
    return ccui.Widget:create()
end)

FormationIconView.kIconTypeTeam = 1
FormationIconView.kIconTypeInstrument = 2
FormationIconView.kIconTypeSkill = 3
FormationIconView.kIconTypeTeamSkillType1 = 4
FormationIconView.kIconTypeTeamSkillType2 = 5
FormationIconView.kIconTypeTeamSkillType3 = 6
FormationIconView.kIconTypeTeamSkillType4 = 7
FormationIconView.kIconTypeTeamSkillTypeEnd = 8
FormationIconView.kIconTypeReserved1 = 9
FormationIconView.kIconTypeReserved2 = 10
FormationIconView.kIconTypeInstanceTeam = 11
FormationIconView.kIconTypeInstanceInstrument = 12
FormationIconView.kIconTypeInstanceSkill = 13
FormationIconView.kIconTypeSkillBook = 14
FormationIconView.kIconTypeSkillBookPaper = 15
FormationIconView.kIconTypeHero = 16
FormationIconView.kIconTypeHeroSpecialty = 17
FormationIconView.kIconTypeHeroMastery = 18
FormationIconView.kIconTypeMorale = 22
FormationIconView.kIconTypeMagic = 23
FormationIconView.kIconTypeEquipment = 23
FormationIconView.kIconTypePlaceHolder = 24

FormationIconView.kIconTypeAttributeAtk = 25
FormationIconView.kIconTypeAttributeDef = 26
FormationIconView.kIconTypeAttributeInt = 27
FormationIconView.kIconTypeAttributeAck = 28
FormationIconView.kIconTypeAttributeMorale = 29
FormationIconView.kIconTypeAttributeMagic = 30
FormationIconView.kIconTypeAllAttributes = 100
FormationIconView.kIconTypeHeroSkillDamage = 31

FormationIconView.kIconTypeArenaTeam = 31
FormationIconView.kIconTypeAiRenMuWuTeam = 32 -- reserved
FormationIconView.kIconTypeZombieTeam = 33 -- reserved
FormationIconView.kIconTypeDragonTeam = 34 -- reserved
FormationIconView.kIconTypeCrusadeTeam = 35

FormationIconView.kIconTypeInstanceHero = 36
FormationIconView.kIconTypePVPHero = 37

FormationIconView.kPlaceHolderTeamId = -1

FormationIconView.kNormalContainer = 1
FormationIconView.kEditContainer = 2
FormationIconView.kBattaleFormationContainer = 3
FormationIconView.kPveContainer = 4
--[[
FormationIconView.kIconStatus = {
    kStatusUnload = 1,
    kStatusLoaded = 2,
}
]]
function FormationIconView:ctor(params)
    FormationIconView.super.ctor(self)
    self._iconType = params.iconType
    self._iconId = params.iconId
    self._container = params.container
    self._containerType = params.containerType
    self._scheduler = cc.Director:getInstance():getScheduler()
    --self._formationModel = self._modelMgr:getModel("FormationModel")
    --self._isLoaded = self._formationModel:isLoaded(self:getIconType(), self:getIconId())
    --self._currentIconId = currentIconId
    --self._iconStatus = params.iconStatus

    self:setContentSize(90, 90)
    self:setAnchorPoint(cc.p(0.5, 0.5))

    self._isIconMoved = false
    self._disableMove = false

    self._updateFunctionMap = {
        [FormationIconView.kIconTypeTeam] = handler(self, self.updateTeamIconInformation),
        [FormationIconView.kIconTypeInstrument] = handler(self, self.updateInstrumentIconInformation),
        [FormationIconView.kIconTypeSkill] = handler(self, self.updateSkillIconInformation),

        [FormationIconView.kIconTypeTeamSkillType1] = handler(self, self.updateTeamSkillIconInformation),
        [FormationIconView.kIconTypeTeamSkillType2] = handler(self, self.updateTeamSkillIconInformation),
        [FormationIconView.kIconTypeTeamSkillType3] = handler(self, self.updateTeamSkillIconInformation),
        [FormationIconView.kIconTypeTeamSkillType4] = handler(self, self.updateTeamSkillIconInformation),

        [FormationIconView.kIconTypeInstanceTeam] = handler(self, self.updateInstanceTeamIconInformation),
        [FormationIconView.kIconTypeInstanceSkill] = handler(self, self.updateSkillIconInformation),

        [FormationIconView.kIconTypeSkillBook] = handler(self, self.updateSkillBookIconInformation),
        [FormationIconView.kIconTypeSkillBookPaper] = handler(self, self.updateSkillBookPaperIconInformation),
        [FormationIconView.kIconTypeHero] = handler(self, self.updateHeroIconInformation),
        [FormationIconView.kIconTypeHeroSpecialty] = handler(self, self.updateHeroSpecialtyIconInformation),
        [FormationIconView.kIconTypeHeroMastery] = handler(self, self.updateHeroMasteryIconInformation),

        [FormationIconView.kIconTypeMorale] = handler(self, self.updateMoraleIconInformation),
        [FormationIconView.kIconTypeMagic] = handler(self, self.updateMagicIconInformation),

        [FormationIconView.kIconTypeEquipment] = handler(self, self.updateEquipmentIconInformation),

        [FormationIconView.kIconTypeArenaTeam] = handler(self, self.updateArenaTeamIconInformation),
        [FormationIconView.kIconTypeAiRenMuWuTeam] = handler(self, self.updateAiRenMuWuTeamIconInformation),
        [FormationIconView.kIconTypeZombieTeam] = handler(self, self.updateZombieTeamIconInformation),
        [FormationIconView.kIconTypeDragonTeam] = handler(self, self.updateDragonTeamIconInformation),
        [FormationIconView.kIconTypeCrusadeTeam] = handler(self, self.updateCrusadeTeamIconInformation),

        [FormationIconView.kIconTypePlaceHolder] = handler(self, self.updatePlaceHolderIconInformation),
    }

    self._tagNormal = ccui.ImageView:create("globalImageUI6_meiyoutu.png", 1)
    self._tagNormal:setVisible(false)
    self._tagNormal:setScale(0.55, 0.55)
    self._tagNormal:setPosition(cc.p(35, 35))
    self:addChild(self._tagNormal, 15)

    self._tagSelected = ccui.ImageView:create("globalImageUI4_IconSelected1.png", 1)
    self._tagSelected:setScale9Enabled(true)
    self._tagSelected:setCapInsets(cc.rect(20, 20, 1, 1))
    self._tagSelected:setContentSize(cc.size(100, 100))
    self._tagSelected:setPosition(cc.p(43, 41))
    self._tagSelected:setVisible(false)
    self:addChild(self._tagSelected, 20)
    --[[
    self._btnLoad = ccui.Button:create("globalBtnUI_commonBtn5.png", "", "", 1)
    self._btnLoad:setScale(0.5, 0.5)
    self._btnLoad:setPosition(35, 35)
    self._btnLoad:setTitleText("上阵")
    self._btnLoad:setTitleFontSize(26)
    self._btnLoad:setVisible(false)
    self:addChild(self._btnLoad, 10)

    self._btnUnload = ccui.Button:create("globalBtnUI_commonBtn5.png", "", "", 1)
    self._btnUnload:setScale(0.5, 0.5)
    self._btnUnload:setPosition(35, 35)
    self._btnUnload:setTitleText("休息")
    self._btnUnload:setTitleFontSize(26)
    self._btnUnload:setVisible(false)
    self:addChild(self._btnUnload, 10)

    self._tagLoaded = ccui.Button:create("globalImageUI_MoneyBg.png", "", "", 1)
    self._tagLoaded:setTouchEnabled(false)
    self._tagLoaded:setScale(0.4, 0.5)
    self._tagLoaded:setPosition(35, 35)
    self._tagLoaded:setTitleText("已上场")
    self._tagLoaded:setTitleFontSize(26)
    self._tagLoaded:setVisible(false)
    self:addChild(self._tagLoaded, 10)

    self._btnChange = ccui.Button:create("globalBtnUI_commonBtn5.png", "", "", 1)
    self._btnChange:setSwallowTouches(false)
    self._btnChange:setScale(0.5, 0.5)
    self._btnChange:setPosition(35, 35)
    self._btnChange:setTitleText("替换")
    self._btnChange:setTitleFontSize(26)
    self._btnChange:setVisible(false)
    self:addChild(self._btnChange, 10)
    ]]
    self._layerTeamInformation = ccui.Layout:create()
    self._layerTeamInformation:setContentSize(90, 90)
    self._layerTeamInformation:setScale(0.92, 0.92)
    self._layerTeamInformation:setTouchEnabled(false)
    self._layerTeamInformation:setVisible(false)
    self:addChild(self._layerTeamInformation, 5)
    --[[
    -- version 3.0
    self._imageTeamIcon = ccui.ImageView:create("globalImageUI_quality0.png", 1)
    self._imageTeamIcon:ignoreContentAdaptWithSize(false)
    self._imageTeamIcon:setContentSize(90, 90)
    self._imageTeamIcon:setScale(1.07, 1.07)
    self._imageTeamIcon:setPosition(cc.p(52, 52))
    self._layerTeamInformation:addChild(self._imageTeamIcon, 10)
    ]]

    self._imageTeamPlaceHolderIcon = ccui.ImageView:create("globalImageUI4_itemBg3.png", 1)
    self._imageTeamPlaceHolderIcon:setVisible(false)
    self._imageTeamPlaceHolderIcon:setPosition(cc.p(43, 43))
    self._layerTeamInformation:addChild(self._imageTeamPlaceHolderIcon, 10)

    self._imageTeamPlaceHolderFrame = ccui.ImageView:create("globalImageUI4_iquality0.png", 1)
    self._imageTeamPlaceHolderFrame:setPosition(cc.p(45, 45))
    self._imageTeamPlaceHolderIcon:addChild(self._imageTeamPlaceHolderFrame, 5)

    self._tagLoaded = ccui.ImageView:create("", 1)
    self._tagLoaded:setTouchEnabled(false)
    self._tagLoaded:setVisible(false)
    self._tagLoaded:setPosition(cc.p(28, 57))
    self._layerTeamInformation:addChild(self._tagLoaded, 20)

    self._tagFiltered = ccui.ImageView:create("globalImageUI4_dead.png", 1)
    self._tagFiltered:setTouchEnabled(false)
    self._tagFiltered:setVisible(false)
    self._tagFiltered:setScale(1.07, 1.07)
    self._tagFiltered:setPosition(cc.p(52, 45))
    self._layerTeamInformation:addChild(self._tagFiltered, 20)
--[[
    self._labelTeamName = ccui.Text:create()
    self._labelTeamName:setAnchorPoint(cc.p(0, 0.5))
    self._labelTeamName:setPosition(cc.p(5, 55))
    self._labelTeamName:setFontSize(12)
    self._layerTeamInformation:addChild(self._labelTeamName, 15)

    self._labelTeamStage = ccui.Text:create()
    self._labelTeamStage:setAnchorPoint(cc.p(0.5, 0.5))
    self._labelTeamStage:setPosition(cc.p(15, 30))
    self._labelTeamStage:setFontSize(18)
    self._layerTeamInformation:addChild(self._labelTeamStage, 15)

    self._labelTeamScore = ccui.Text:create()
    self._labelTeamScore:setAnchorPoint(cc.p(0.5, 0.5))
    self._labelTeamScore:setPosition(cc.p(35, -10))
    self._labelTeamScore:setFontSize(15)
    self._labelTeamScore:setVisible(false)
    self._layerTeamInformation:addChild(self._labelTeamScore, 15)

    self._layerStar = ccui.Layout:create()
    self._layerStar:setContentSize(70, 20)
    self._layerStar:setTouchEnabled(false)
    self._layerTeamInformation:addChild(self._layerStar, 15)

    for i=1, 5 do
        local star = ccui.ImageView:create("globalImageUI_gold.png", 1)
        star:setScale(0.25, 0.25)
        star:setPosition(cc.p(10 * i, 10))
        star:setTag(3000+i)
        self._layerStar:addChild(star, 10)
    end
]]
    self._layerSkillInformation = ccui.Layout:create()
    self._layerSkillInformation:setContentSize(90, 90)
    self._layerSkillInformation:setTouchEnabled(false)
    self._layerSkillInformation:setVisible(false)
    self:addChild(self._layerSkillInformation, 5)

    self._imageSkillIcon = ccui.ImageView:create()
    self._imageSkillIcon:ignoreContentAdaptWithSize(false)
    self._imageSkillIcon:setContentSize(60, 60)
    self._imageSkillIcon:setPosition(cc.p(45, 45))
    self._layerSkillInformation:addChild(self._imageSkillIcon, 10)

    self._imageSkillQuality = ccui.ImageView:create()
    self._imageSkillQuality:ignoreContentAdaptWithSize(false)
    self._imageSkillQuality:setContentSize(60, 60)
    self._imageSkillQuality:setPosition(cc.p(45, 45))
    self._layerSkillInformation:addChild(self._imageSkillQuality, 11)

    self._imageSkillItemBg = ccui.ImageView:create("globalImageUI4_itemBg5.png", 1)
    self._imageSkillItemBg:ignoreContentAdaptWithSize(false)
    self._imageSkillItemBg:setContentSize(60, 60)
    self._imageSkillItemBg:setPosition(cc.p(45, 45))
    self._layerSkillInformation:addChild(self._imageSkillItemBg, 5)

    self._labelSkillName = ccui.Text:create()
    self._labelSkillName:ignoreContentAdaptWithSize(false)
    self._labelSkillName:setContentSize(55, 35)
    self._labelSkillName:setAnchorPoint(cc.p(0, 0.5))
    self._labelSkillName:setPosition(cc.p(5, 45))
    self._labelSkillName:setFontSize(12)
    self._layerSkillInformation:addChild(self._labelSkillName, 15)

    self._labelSkillQuality = ccui.Text:create()
    self._labelSkillQuality:setAnchorPoint(cc.p(0.5, 0.5))
    self._labelSkillQuality:setPosition(cc.p(15, 15))
    self._labelSkillQuality:setFontSize(18)
    self._layerSkillInformation:addChild(self._labelSkillQuality, 15)

    self._grayLayer = cc.LayerColor:create(cc.c4b(20, 20, 20, 99), 65, 65)
    self._grayLayer:setVisible(false)
    self._grayLayer:setAnchorPoint(0.5, 0.5)
    self._grayLayer:ignoreAnchorPointForPosition(false)
    self._grayLayer:setPosition(cc.p(35, 35))
    self:addChild(self._grayLayer, 20)
    --[[
    self:registerClickEvent(self._btnLoad, function(sender)
        self:onLoad(sender)
    end)

    self:registerClickEvent(self._btnUnload, function(sender)
        self:onUnload(sender)
    end)

    self:registerClickEvent(self._btnChange, function(sender)
        self:onChange(sender)
    end)
    ]]
    self:enableTouch(true)
    self:updateIconInformation()
end

function FormationIconView:enableTouch(enable)
    if not enable then
        self:setTouchEnabled(false)
        return
    end

    self:setTouchEnabled(true)
    self:setSwallowTouches(true)
    self:registerTouchEvent(self, 
        handler(self, self.onTouchBegan), 
        handler(self, self.onTouchMoved), 
        handler(self, self.onTouchEnded), 
        handler(self, self.onTouchCancelled))
end

function FormationIconView:updateIconInformation()
    if not self._iconType then return end
    local updateFunction = self._updateFunctionMap[self._iconType]
    if updateFunction and type(updateFunction) == "function" then
        updateFunction()
    --[[else
        if self.kIconTypeTeam == self._iconType then
            self:updateTeamIconInformation()
        elseif self.kIconTypeInstrument == self._iconType then
            self:updateInstrumentIconInformation()
        elseif self._iconType >= self.kIconTypeTeamSkillType1 and self._iconType < self.kIconTypeTeamSkillTypeEnd then
            self:updateTeamSkillIconInformation()
        elseif self.kIconTypeInstanceTeam == self._iconType then
            self:updateInstanceTeamIconInformation()
        elseif self.kIconTypeSkill == self._iconType or self.kIconTypeInstanceSkill == self._iconType then
            self:updateSkillIconInformation()
        elseif self.kIconTypeSkillBook == self._iconType then
            self:updateSkillBookIconInformation()
        elseif self.kIconTypeSkillBookPaper == self._iconType then
            self:updateSkillBookPaperIconInformation()
        elseif self.kIconTypeHero == self._iconType then
            self:updateHeroIconInformation()
        end ]]
    end
end

function FormationIconView:updateTeamIconInformation()
    --print("FormationIconView:updateTeamIconInformation")
    if self._iconId == self.kPlaceHolderTeamId then
        self:updatePlaceHolderIconInformation()
        return 
    end
    local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._iconId)
    if not teamData then print(self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    self._layerTeamInformation:setVisible(true)
    if not self._teamIconNode then
        self._teamIconNode = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2],  eventStyle = 0})
        self._teamIconNode:setPosition(cc.p(-3, -6))
        self._layerTeamInformation:addChild(self._teamIconNode, 15)
    else
        IconUtils:updateTeamIconByView({teamData = teamData, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2],  eventStyle = 0})
    end

    --[[
    self._tagNormal:setVisible(false)
    self._layerTeamInformation:setVisible(true)
    self._imageTeamIcon:loadTexture(tostring(TeamUtils.getNpcTableValueByTeam(teamTableData, "art1"), 1)
    self._labelTeamName:setColor(cc.c3b(255,0,0))
    self._labelTeamName:setString(lang(teamTableData.name))
    self._labelTeamStage:setColor(cc.c3b(255,0,0))
    self._labelTeamStage:setString("+" .. teamData.stage)
    self._labelTeamScore:setColor(cc.c3b(250,0,0))
    self._labelTeamScore:setString(teamData.score)
    ]]
    --[[
    local iconSprite = cc.Sprite:createWithSpriteFrameName(tostring(TeamUtils.getNpcTableValueByTeam(teamTableData, "art1"))
    iconSprite:setScale(0.5)
    iconSprite:setPosition(self._layer:getContentSize().width / 2, self._layer:getContentSize().height / 2)
    layerTeamInformation:addChild(iconSprite, 5)
    ]]
    --[[
    for i=1, 5 do
        local star = self._layerStar:getChildByTag(3000+i)
        star:setVisible(i <= teamData.star)
    end
    ]]
    -- Temp Code Begin
    --local indicateString = string.format("%d", self._iconId)
    --local label = cc.Label:createWithTTF(indicateString, "Arial", 15)
    --local label = cc.LabelTTF:create(indicateString, "Arial", 18)
    --label:setPosition(icon:getContentSize().width / 2, 50)
    --icon:addChild(label)
    -- Temp Code End
    
end

function FormationIconView:updatePlaceHolderIconInformation()
    --print("FormationIconView:updateTeamIconInformation")
    self._layerTeamInformation:setVisible(true)
    self._imageTeamPlaceHolderIcon:setVisible(true)
end

function FormationIconView:updateInstrumentIconInformation()
end

function FormationIconView:updateSkillIconInformation()
    --print("FormationIconView:updateSkillIconInformation")
    --local skillData = self._modelMgr:getModel("SkillModel"):getSkillData()
    local skillTableData = tab:PlayerSkillEffect(self._iconId)

    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. skillTableData.art .. ".jpg", 1)
    --self._labelSkillName:setColor(cc.c3b(255,0,0))
    --self._labelSkillName:setString(lang(skillTableData.name))
    self._tagNormal:setVisible(false)
    --[[
    local labelSkillQuality = self:getUI("layer.layer_skill_information.label_skill_quality")
    labelSkillQuality:setColor(cc.c3b(255,0,0))
    labelSkillQuality:setString("+" .. teamData.teamStage)
    ]]

    --[[
    local iconSprite = cc.Sprite:createWithSpriteFrameName(tostring(skillTableData.art))
    iconSprite:setScale(0.5)
    iconSprite:setPosition(self._layer:getContentSize().width / 2, self._layer:getContentSize().height / 2)
    layerSkillInformation:addChild(iconSprite, 5)
    ]]
end

function FormationIconView:updateTeamSkillIconInformation()
    --[=[
    local skillData = self._modelMgr:getModel("SkillModel"):getSkillData()
    local skillTableData = tab:PlayerSkill(self._iconId)

    local layerSkillInformation = self:getUI("layer.layer_skill_information")
    layerSkillInformation:setVisible(true)

    local labelSkillName = self:getUI("layer.layer_skill_information.label_skill_name")
    labelSkillName:setColor(cc.c3b(255,0,0))
    labelSkillName:setString(lang(skillTableData.name))
    --[[
    local labelSkillQuality = self:getUI("layer.layer_skill_information.label_skill_quality")
    labelSkillQuality:setColor(cc.c3b(255,0,0))
    labelSkillQuality:setString("+" .. teamData.teamStage)
    ]]
    local iconSprite = cc.Sprite:createWithSpriteFrameName(tostring(skillTableData.art))
    iconSprite:setScale(0.5)
    iconSprite:setPosition(self._layer:getContentSize().width / 2, self._layer:getContentSize().height / 2)
    layerSkillInformation:addChild(iconSprite, 5)
    ]=]
    --print("FormationIconView:updateTeamSkillIconInformation")
    local skillType = self._iconType - self.kIconTypeTeamSkillType1 + 1
    local skillId = self._iconId

    local skillTableData = SkillUtils:getTeamSkillByType(skillId, skillType)
    if not skillTableData then print("invalid skill id", skillId, skillType) end
    self._tagNormal:setVisible(false)
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. skillTableData.art .. ".jpg", 1)
    --self._labelSkillName:setString(lang(skillTableData.name))
    self._labelSkillQuality:setVisible(false)
    --[[
    local iconSprite = cc.Sprite:createWithSpriteFrameName("s_10001.jpg")
    iconSprite:setScale(0.5)
    iconSprite:setPosition(self._layer:getContentSize().width / 2, self._layer:getContentSize().height / 2)
    layerSkillInformation:addChild(iconSprite, 5)
    ]]
end

function FormationIconView:updateInstanceTeamIconInformation()
    --print("FormationIconView:updateTeamIconInformation")
    --local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(self._iconId)
    local teamTableData = tab:Npc(self._iconId)
    if not teamTableData then print("invalid team id:", self._iconId) end
    local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamTableData.stage)
    --dump(teamTableData)
    self._layerTeamInformation:setVisible(true)
    if not self._teamIconNode then
        self._teamIconNode = IconUtils:createTeamIconById({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2],  eventStyle = 0})
        self._teamIconNode:setPosition(cc.p(-1, -1))
        self._layerTeamInformation:addChild(self._teamIconNode, 15)
    else
        IconUtils:updateTeamIconByView({teamData = {id = self._iconId, star = teamTableData.star}, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2],  eventStyle = 0})
    end

    --[[
    self._labelTeamName:setColor(cc.c3b(255,0,0))
    self._labelTeamName:setString(lang(teamTableData.name))
    self._labelTeamStage:setColor(cc.c3b(255,0,0))
    self._labelTeamStage:setString("+" .. teamData.teamStage)
    self._labelTeamScore:setColor(cc.c3b(250,0,0))
    self._labelTeamScore:setString(teamData.score)
    ]]
    --[[
    for i=1, 5 do
        local star = self._layerStar:getChildByTag(3000+i)
        star:setVisible(i <= teamTableData.monsterStar)
    end
    ]]
    -- Temp Code Begin
    --local indicateString = string.format("%d", self._iconId)
    --local label = cc.Label:createWithTTF(indicateString, "Arial", 15)
    --local label = cc.LabelTTF:create(indicateString, "Arial", 18)
    --label:setPosition(icon:getContentSize().width / 2, 50)
    --icon:addChild(label)
    -- Temp Code End
end

function FormationIconView:updateSkillBookIconInformation()
    local skillTableData = tab:Tool(self._iconId)
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. skillTableData.art, 1)
    self._labelSkillName:setString(lang(skillTableData.name))
    self._labelSkillQuality:setVisible(false)
end

function FormationIconView:updateSkillBookPaperIconInformation()
    local skillTableData = tab:Tool(self._iconId)
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. skillTableData.art, 1)
    self._labelSkillName:setString(lang(skillTableData.name))
    self._labelSkillQuality:setVisible(false)
end

function FormationIconView:updateHeroIconInformation()
    --[[
    local heroData = tab:Hero(self._iconId)
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(tostring(heroData.herobg), 1)
    self._labelSkillName:setString(lang(heroData.heroname))
    self._labelSkillQuality:setVisible(false)
    ]]
end

function FormationIconView:updateHeroSpecialtyIconInformation()
    local masteryData = tab:HeroMastery(self._iconId)
    if not masteryData then
        print("the id is invalid", self._iconId)
    end 
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. masteryData.icon .. ".jpg", 1) -- no data
    --self._labelSkillName:setString(lang(masteryData.name))
    self._labelSkillName:setVisible(false)
    self._labelSkillQuality:setVisible(false)
end

function FormationIconView:updateHeroMasteryIconInformation()
    local masteryData = tab:HeroMastery(self._iconId)
    if not masteryData then print("invalid mastery id, hero id:", self._iconId) end
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:setContentSize(cc.size(55, 55))
    self._imageSkillQuality:setContentSize(cc.size(70, 70))
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. masteryData.icon .. ".jpg", 1)
    self._imageSkillIcon:setScale(1.15)
    local masteryQuality
    if 1 == masteryData.masterylv then
        masteryQuality = "globalImageUI4_squality2.png"
    elseif 2 == masteryData.masterylv then
        masteryQuality = "globalImageUI4_squality3.png"
    else
        masteryQuality = "globalImageUI4_squality4.png"
    end
    self._imageSkillQuality:loadTexture(masteryQuality, 1)
    --self._labelSkillName:setString(lang(masteryData.name))
    self._labelSkillName:setVisible(false)
    self._labelSkillQuality:setVisible(false)
    self._tagNormal:setVisible(false)
end

function FormationIconView:updateMoraleIconInformation()
    local masteryData = tab:HeroMastery(self._iconId)
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. masteryData.icon, 1) -- no data
    --self._labelSkillName:setString(lang(masteryData.heroname))
    self._labelSkillName:setVisible(false)
    self._labelSkillQuality:setVisible(false)
end

function FormationIconView:updateMagicIconInformation()
    local masteryData = tab:HeroMastery(self._iconId)
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. masteryData.icon, 1) -- no data
    --self._labelSkillName:setString(lang(masteryData.heroname))
    self._labelSkillName:setVisible(false)
    self._labelSkillQuality:setVisible(false)
end

function FormationIconView:updateEquipmentIconInformation()
    local artifactData = tab:Artifact(self._iconId)
    self._layerSkillInformation:setVisible(true)
    self._imageSkillIcon:loadTexture(IconUtils.iconPath .. artifactData.icon, 1) -- no data
    --self._labelSkillName:setString(lang(artifactData.heroname))
    self._labelSkillName:setVisible(false)
    self._labelSkillQuality:setVisible(false)
    self._tagNormal:setVisible(false)
end

function FormationIconView:updateArenaTeamIconInformation()
end

function FormationIconView:updateAiRenMuWuTeamIconInformation()
end

function FormationIconView:updateZombieTeamIconInformation()
end

function FormationIconView:updateDragonTeamIconInformation()
end

function FormationIconView:updateCrusadeTeamIconInformation()
    local teamData = self._modelMgr:getModel("TeamModel"):getEnemyDataById(self._iconId)
    if not teamData then print(self._iconId) end
    local teamTableData = tab:Team(teamData.teamId)
    local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    self._layerTeamInformation:setVisible(true)
    if not self._teamIconNode then
        self._teamIconNode = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2],  eventStyle = 0})
        self._teamIconNode:setPosition(cc.p(-3, -6))
        self._layerTeamInformation:addChild(self._teamIconNode, 15)
    else
        IconUtils:updateTeamIconByView({teamData = teamData, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2],  eventStyle = 0})
    end
end

function FormationIconView:getContainer()
    return self._container
end

function FormationIconView:setIconType(iconType)
    self._iconType = iconType
end

function FormationIconView:setIconId(iconId)
    self._iconId = iconId
end

function FormationIconView:getIconType()
    return self._iconType
end

function FormationIconView:getIconId()
    return self._iconId
end

function FormationIconView:getContainerType()
    return self._containerType
end

function FormationIconView:showStar(isShow)
    if not self._teamIconNode then return end
    IconUtils:setTeamIconStarVisible(self._teamIconNode, isShow)
end

function FormationIconView:showStage(isShow)
    if not self._teamIconNode then return end
    IconUtils:setTeamIconStageVisible(self._teamIconNode, isShow)
end

function FormationIconView:showLevel(isShow)
    if not self._teamIconNode then return end
    IconUtils:setTeamIconLevelVisible(self._teamIconNode, isShow)
end

function FormationIconView:showTagSelected(isShow)
    self._tagSelected:setVisible(isShow)
end

function FormationIconView:showChange(isShow, Text)
    --if Text then self._btnChange:setTitleText(Text) end
    --self._btnChange:setVisible(isShow) 
end

function FormationIconView:showLoad(isShow)
    --self._btnLoad:setVisible(isShow)
end

function FormationIconView:showUnload(isShow)
    --self._btnUnload:setVisible(isShow)
end

function FormationIconView:showTagLoaded(isShow)
    self._tagLoaded:setVisible(isShow)
end

function FormationIconView:showTagFiltered(isShow)
    if self._teamIconNode then
        self._teamIconNode:setSaturation(isShow and -100 or 0)
    end
    self._tagFiltered:setVisible(isShow)
end

function FormationIconView:showScore(isShow)
    --self._labelTeamScore:setVisible(isShow)
end

function FormationIconView:isTagLoadedShown()
    --return self._tagLoaded:isVisible()
    return false
end

function FormationIconView:disableMove(disable)
    self._disableMove = disable
end

function FormationIconView:grayIcon(disable)
    self._grayLayer:setVisible(true)
end

function FormationIconView:onSelected(sender)
    if not (self._container and self._container._container and self._container._container.onSelected) then return end
    self._container._container:onSelected(self, sender)
end

function FormationIconView:onLoad(sender)
    if not (self._container and self._container._container and self._container._container.onLoad) then return end
    self._container._container:onLoad(self, sender)
end

function FormationIconView:onUnload(sender)
    if not (self._container and self._container._container and self._container._container.onUnload) then return end
    self._container._container:onUnload(self, sender)
end

function FormationIconView:onChange(sender)
    if self._isIconMoved then return end
    if not (self._container and self._container._container and self._container._container.onChange) then return end
    self._container._container:onChange(self, sender)
end

function FormationIconView:resetPosition(iconGridOrigin)
    local iconParent = self:getParent()
    if not iconParent then return end
    if iconGridOrigin then
        local position1 = iconParent:convertToNodeSpace(iconGridOrigin:convertToWorldSpace(cc.p(self:getPosition())))
        local position2 = cc.p(iconParent:getContentSize().width / 2, iconParent:getContentSize().height / 2)
        local position3 = cc.p(position2.x - position1.x, position2.y - position1.y)
        position1 = cc.p(position1.x + 0.75 * position3.x, position1.y + 0.75 * position3.y)
        self:runAction(cc.Sequence:create({cc.CallFunc:create(function()
                self:setPosition(position1)
            end),
            cc.MoveTo:create(0.09, cc.p(position2))
        }))
    else
        self:setPosition(iconParent:getContentSize().width / 2, iconParent:getContentSize().height / 2)
    end
end

function FormationIconView:startClock()
    --print("startClock")
    if not (self._container and self._container._container and self._container._container.onIconPressOn) then return end
    self._container._container:onIconPressOn(self)
    --[[
    if self._timer_id then self:endClock() end
    self._first_tick = true
    self._timer_id = self._scheduler:scheduleScriptFunc(function()
        if self._isIconMoved then return self:endClock() end
        if not self._first_tick then return end
        self._first_tick = false
        if not (self._container and self._container._container and self._container._container.onIconPressOn) then return end
        self._container._container:onIconPressOn(self)
    end, 0.2, false)
    ]]
end

function FormationIconView:endClock()
   --print("endClock")
   if not (self._container and self._container._container and self._container._container.onIconPressOff) then return end
   self._container._container:onIconPressOff(self)
   --[[
   if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
    if not (self._container and self._container._container and self._container._container.onIconPressOff) then return end
    self._container._container:onIconPressOff(self)
    ]]
end

function FormationIconView:onTouchBegan(_, x, y)
    print("began x, y", x, y)
    print(self:getName())
    local position = self:convertToNodeSpace(cc.p(x,y))
    --print("began after convert:", position.x, position.y)
    if self._containerType == self.kBattaleFormationContainer or self._containerType == self.kPveContainer or self._iconType == self.kIconTypeEquipment or self._iconType == self.kIconTypeHeroMastery then
        self:startClock()
    end

    if not (self._container and self._container._container and self._container._container.onIconTouchBegan) then return end
    self._container._container:onIconTouchBegan(self, x, y)
end

function FormationIconView:onTouchMoved(_, x, y)
    --print("moved x, y", x, y)
    self._isIconMoved = true
    if not (not self._disableMove and self._container and self._container._container and self._container._container.onIconTouchMoved) then return end
    self._container._container:onIconTouchMoved(self, x, y)
end

function FormationIconView:onTouchEnded(_, x, y)
    print("ended x, y", x, y)
    self:onSelected()
    self._isIconMoved = false
    if self._containerType == self.kBattaleFormationContainer or self._containerType == self.kPveContainer or self._iconType == self.kIconTypeEquipment or self._iconType == self.kIconTypeHeroMastery then 
        --self:endClock()
    end
    if not (self._container and self._container._container and self._container._container.onIconTouchEnded) then return end
    self._container._container:onIconTouchEnded(self, x, y)
end

function FormationIconView:onTouchCancelled(_, x, y)
    print("canceled x, y", x, y)
    if self._containerType == self.kBattaleFormationContainer or self._iconType == self.kIconTypeEquipment or self._iconType == self.kIconTypeHeroMastery then 
        self:endClock()
    end
    if not (self._container and self._container._container and self._container._container.onIconTouchCancelled) then return end
    self._container._container:onIconTouchCancelled(self, x, y)
end
--[[
function FormationIconView:cloneWithParams(params)
    local node = FormationIconView.new(params)
    local name = "formation.FormationIconView"
    node:setClassName(name)
    local filename = nil
    for i = #name, 1, -1 do
        if string.sub(name, i, i) == "." then
            filename = string.sub(name, i + 1, #name)
            break
        end
    end
    if filename == nil then
        filename = name
    end
    node._widget = self._widget:clone()
    node:L10N_Text()
    node:addChild(node._widget)
    node:onInit()
    return node
end
]]
return FormationIconView


