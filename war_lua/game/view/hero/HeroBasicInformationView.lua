--[[
    Filename:    HeroBasicInformationView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-07-09 17:08:10
    Description: File description
--]]

local FormationIconView = require("game.view.formation.FormationIconView")
local HeroDetailsView = require("game.view.hero.HeroDetailsView")

local HeroBasicInformationView = class("HeroBasicInformationView", BaseLayer)

HeroBasicInformationView.kMasteryTab = 1
HeroBasicInformationView.kAttributeTab = 2

HeroBasicInformationView.kViewTypeMasteryInformation = HeroDetailsView.kViewTypeMasteryInformation
HeroBasicInformationView.kViewTypeBasicInformation = HeroDetailsView.kViewTypeBasicInformation
HeroBasicInformationView.kViewTypeUpgradeInformation = HeroDetailsView.kViewTypeUpgradeInformation

HeroBasicInformationView.kHeroHeadIconTag = 10
HeroBasicInformationView.kHeroSpecialtyTag = 11
HeroBasicInformationView.kHeroMasteryTag = 12
HeroBasicInformationView.kMoraleTag = 13
HeroBasicInformationView.kMagicTag = 14


HeroBasicInformationView.kHeroTag = 1000
HeroBasicInformationView.kHeroInformationTag = 2000
HeroBasicInformationView.kHeroEquipmentInformationTag = 3000
HeroBasicInformationView.kCurrentMasteryIconTag = 4000
HeroBasicInformationView.kNewestMasteryIconTag = 5000

HeroBasicInformationView.kNormalZOrder = 500
HeroBasicInformationView.kLessNormalZOrder = HeroBasicInformationView.kNormalZOrder - 1
HeroBasicInformationView.kAboveNormalZOrder = HeroBasicInformationView.kNormalZOrder + 1
HeroBasicInformationView.kHighestZOrder = HeroBasicInformationView.kAboveNormalZOrder + 1

HeroBasicInformationView.kHeroLocked = "mastery_locked_hero.png"
HeroBasicInformationView.kHeroUnlocked = "mastery_unlocked_hero.png"
HeroBasicInformationView.kHeroLockDisabled = "mastery_lock_disabled_hero.png"

HeroBasicInformationView.kFragToolId = 3002

function HeroBasicInformationView:ctor(params)
    HeroBasicInformationView.super.ctor(self)
    self._heroData = params.data
    self._container = params.container
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
end

function HeroBasicInformationView:disableTextEffect(element)
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

function HeroBasicInformationView:onInit()
    
    self:disableTextEffect()

    self:initSpecialtyData()
    --dump(self._heroData, "self._heroData", 5)

    self._layerInfo = self:getUI("bg.layer.layer_info")
    self._heroName = self:getUI("bg.layer.layer_info.label_hero_name")
    --self._heroName:setFontName(UIUtils.ttfName_Title)
    self._heroName:enable2Color(2, cc.c4b(246, 147, 42, 255))
    self._heroName:enableOutline(cc.c4b(27, 12, 4, 255), 1)
    self._heroCareer = self:getUI("bg.layer.layer_info.label_hero_career")
    --self._heroCareer:setFontName(UIUtils.ttfName_Title)
    --self._heroCareer:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._heroIcon = self:getUI("bg.layer.layer_info.layer_icon")
    --self._heroImage = self:getUI("bg.layer.layer_icon.image_hero")

    self._scheduler = cc.Director:getInstance():getScheduler()
    self._heroStar = {}
    for i = 1, 4 do
        self._heroStar[i] = self:getUI("bg.layer.layer_info.image_star_bg.star_n_" .. i)
    end
    self._layerHeroBody = self:getUI("bg.layer.layer_hero_body")
    self._heroBody = self:getUI("bg.layer.layer_hero_body.hero_body")
    self:registerTouchEvent(self._heroBody, function() return true end, nil, function()
        self:stopHeroMCSwitchTimer()
        self:switchHeroMC()
        self:startHeroMCSwitchTimer()
    end, nil)
    self._heroBodyMC = {}
    self._currentHeroMCIndex = 1
    self._heroMCName = {"stop", "run", "run2", "atk1", "atk2", "atk3"}
    local heroAnim = self._heroData.heroart
    if self._heroData.skin then
        local skinTableData = tab:HeroSkin(tonumber(self._heroData.skin))
        heroAnim = skinTableData and skinTableData.heroart or heroAnim
    end
    mcMgr:loadRes(heroAnim, function()
        if not self._heroMCName then return end
        for i = 1, #self._heroMCName do
            self._heroBodyMC[i] = mcMgr:createViewMC(self._heroMCName[i] .. "_" .. heroAnim, true)
            self._heroBodyMC[i]:setVisible(false)
            self._heroBodyMC[i]:setRotation3D(cc.vec3(0, 180, 0))
            self._heroBodyMC[i]:setScale(0.9)
            self._heroBodyMC[i]:setPosition(self._heroBody:getContentSize().width / 2 + 10, self._heroBody:getContentSize().height / 2 - 55)
            self._heroBody:addChild(self._heroBodyMC[i])
        end

        self:switchHeroMC()
        self:startHeroMCSwitchTimer()
    end)

    -- layer right 1
    self._layerRight1 = self:getUI("bg.layer.layer_right_1")
    self._layerMastery = self:getUI("bg.layer.layer_right_1.layer_mastery")
    self._titleMastery = self:getUI("bg.layer.layer_right_1.layer_mastery.mastery_title_bg.label_title")
    --self._titleMastery:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    --self._titleMastery:setFontName(UIUtils.ttfName_Title)
    self._titleMasteryRefresh = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.image_title_bg.label_title")
    --self._titleMasteryRefresh:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    --self._titleMasteryRefresh:setFontName(UIUtils.ttfName_Title)
    self._masteryUI = {}
    for i=1, 4 do
        self._masteryUI[i] = {}
        self._masteryUI[i]._icon = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery.layer_mastery_%d", i))
        self._masteryUI[i]._level = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery.layer_mastery_%d.label_mastery_level", i))
        --self._masteryUI[i]._level:setFontName(UIUtils.ttfName_Title)
        --self._masteryUI[i]._name = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery.layer_mastery_%d.label_mastery_name", i, i))
        self._masteryUI[i]._recommand = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery.layer_mastery_%d.image_recommand", i))
        self._masteryUI[i]._icon:setAnchorPoint(0.5,0.5)
        if i <= 2 then
            self._masteryUI[i]._icon:setPosition(self._masteryUI[i]._icon:getPositionX()+37,self._masteryUI[i]._icon:getPositionY()+33)
        else
            self._masteryUI[i]._icon:setPosition(self._masteryUI[i]._icon:getPositionX()+37,self._masteryUI[i]._icon:getPositionY()+23)
        end
        self._masteryUI[i]._icon:setScaleAnim(true)
    end
    local formationModel = self._modelMgr:getModel("FormationModel")
    local formationData = self._modelMgr:getModel("FormationModel"):getFormationDataByType(formationModel.kFormationTypeCommon)
    self._isHeroLoaded = formationData and formationData.heroId == self._heroData.id
    self._is_no_refresh = true
    self._is_refresh_btn_clicked = false
    self._layerMasteryRefresh = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh")
    self._currentMastery = {}
    for i=1, 4 do
        self._currentMastery[i] = {}
        self._currentMastery[i]._value = self._heroData["m" .. i]
        self._currentMastery[i]._lock = self._heroData["masteryLock" .. i]
        self._currentMastery[i]._image = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery_refresh.layer_current_bg.layer_icon_%d", i))
        self._currentMastery[i]._image.tipRotation = 90
        --[[
        self._currentMastery[i]._masteryMC = mcMgr:createViewMC("yingxiongzhuanjingshuaxin2_heromasteryrefresh", false, false)
        self._currentMastery[i]._masteryMC:setVisible(false)
        self._currentMastery[i]._masteryMC:setPosition(cc.p(self._currentMastery[i]._image:getContentSize().width * 1.6+90, self._currentMastery[i]._image:getContentSize().height / 2))
        self._currentMastery[i]._image:addChild(self._currentMastery[i]._masteryMC, 100)
        ]]
        self._currentMastery[i]._masteryMC1 = mcMgr:createViewMC("yingxiongzhuanjingshuaxin3_heromasteryrefresh", false, false)
        self._currentMastery[i]._masteryMC1:setVisible(false)
        self._currentMastery[i]._masteryMC1:setPosition(cc.p(self._currentMastery[i]._image:getContentSize().width * 1.6-77, self._currentMastery[i]._image:getContentSize().height / 2))
        self._currentMastery[i]._image:addChild(self._currentMastery[i]._masteryMC1, 100)
        self._currentMastery[i]._labelMasteryLevel = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery_refresh.layer_current_bg.layer_icon_%d.label_mastery_level", i))
        --self._currentMastery[i]._labelMasteryLevel:setFontName(UIUtils.ttfName_Title)
        self._currentMastery[i]._image_recommand = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery_refresh.layer_current_bg.layer_icon_%d.image_recommand", i))
        self._currentMastery[i]._imageLock = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery_refresh.layer_current_bg.layer_icon_%d.image_lock", i))
        self._currentMastery[i]._imageLock:setScaleAnim(true)
        self:registerClickEvent(self._currentMastery[i]._imageLock, function()
           self:onLockButtonClicked(i)
        end)
    end
    
    self._newestMastery = {}
    for i=1, 4 do
        self._newestMastery[i] = {}
        self._newestMastery[i]._value = self._currentMastery[i]._value
        self._newestMastery[i]._lock = self._currentMastery[i]._lock
        self._newestMastery[i]._image = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery_refresh.layer_newest_bg.layer_icon_%d", i))
        self._newestMastery[i]._image.tipRotation= 90
        self._newestMastery[i]._masteryMC = mcMgr:createViewMC("yingxiongzhuanjingshuaxin1_heromasteryrefresh", false, false)
        self._newestMastery[i]._masteryMC:setVisible(false)
        self._newestMastery[i]._masteryMC:setPosition(cc.p(self._newestMastery[i]._image:getContentSize().width * 1.2-50, self._newestMastery[i]._image:getContentSize().height / 2))
        self._newestMastery[i]._image:addChild(self._newestMastery[i]._masteryMC, 100)
        self._newestMastery[i]._labelMasteryLevel = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery_refresh.layer_newest_bg.layer_icon_%d.label_mastery_level", i))
        --self._newestMastery[i]._labelMasteryLevel:setFontName(UIUtils.ttfName_Title)
        self._newestMastery[i]._image_recommand = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery_refresh.layer_newest_bg.layer_icon_%d.image_recommand", i))
        self._newestMastery[i]._image_no_refresh = self:getUI(string.format("bg.layer.layer_right_1.layer_mastery_refresh.layer_newest_bg.layer_icon_%d.image_no_refresh", i))
    end

    --self._btn_refresh = self:getUI("bg.layer.layer_right_1.layer_mastery.btn_refresh")
    --self._btn_refresh:setBright(not not SystemUtils:enableHeroMastery())


    local playerDayInfoData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    self._layer_refresh_consume = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume")
    self._layer_refresh_consume:setVisible(true)
    --self._image_privileges_icon = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_privileges_icon")
    self._first_free_times = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.label_first_free")
    --[[
    self._label_free_times = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_privileges_icon.label_free_times")
    self._label_free_times:setPositionX(self._label_free_times:getPositionX() - 5) -- temp code
    self._label_free_times:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    self._label_free_times_value = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_privileges_icon.label_free_times.label_free_times_value")
    self._label_free_times_value:setPositionX(self._label_free_times_value:getPositionX() + 5) -- temp code
    self._label_free_times_value:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    ]]
    --[[
    local firstFreeTimes = tonumber(self._userModel:getPlayerStatis().snum20)
    self._first_free_times:setVisible(1 ~= firstFreeTimes)
    local freeTimes = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_12) - playerDayInfoData.day4
    self._image_privileges_icon:setVisible(not self._first_free_times:isVisible() and freeTimes > 0)
    self._label_free_times_value:setString("(" .. freeTimes .. ")")
    ]]

    local _, scrollNum = self._itemModel:getItemsById(3015)
    self._imageConsumeScroll = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_consume_scroll")
    --self._imageConsumeScroll:setVisible(not self._first_free_times:isVisible() and freeTimes <= 0 and scrollNum > 0)
    self._labelConsumeScrollValue1 = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_consume_scroll.label_consume_1")
    self._labelConsumeScrollValue = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_consume_scroll.label_consume_value")
    self._labelConsumeScrollValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._labelConsumeScrollValue2 = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_consume_scroll.label_consume_2")
    --[[
    self._labelConsumeScrollValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    self._labelConsumeScrollValue:setString(scrollNum)
    self._labelConsumeScrollValue:setPositionX(self._labelConsumeScrollValue1:getPositionX() + self._labelConsumeScrollValue1:getContentSize().width + 3)
    self._labelConsumeScrollValue2:setPositionX(self._labelConsumeScrollValue:getPositionX() + self._labelConsumeScrollValue:getContentSize().width + 3)
    ]]

    self._refreshConsume = tab:Setting("G_MASTERY_REFRESH").value
    self._imageConsume = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_consume")
    --self._imageConsume:setVisible(freeTimes <= 0)
    self._labelConsumeValue = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_consume.label_consume_value")
    --self._labelConsumeValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    --self._labelConsumeValue:setString(self._refreshConsume[self:getLockedCount() + 1][1])
    self._labelConsumeGoldValue = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_consume.label_consume_gold_value")
    --self._labelConsumeGoldValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    --self._labelConsumeGoldValue:setString(self._refreshConsume[self:getLockedCount() + 1][2])
    --[[
    self._imageConsumeBg = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_privileges_icon.image_consume_bg")
    self._imageConsumeBg:setVisible(freeTimes <= 0)
    ]]

    self._isScrollSelected = scrollNum > 0
    if 1 == SystemUtils.loadAccountLocalData("HERO_MASTERY_REFRESH_SELECTED") then
        self._isScrollSelected = true
    elseif 0 == SystemUtils.loadAccountLocalData("HERO_MASTERY_REFRESH_SELECTED") then
        self._isScrollSelected = false
    end
    self._checkBoxConsumeScroll = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.layer_refresh_consume.image_consume_scroll.check_box_scroll")
    self._checkBoxConsumeScroll:setSelected(self._isScrollSelected)
    self:registerClickEvent(self._checkBoxConsumeScroll, function()
        self._isScrollSelected = not self._isScrollSelected
        self._imageConsume:setVisible(not self._isScrollSelected)
    end)

    self._btn_refresh = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.btn_refresh")
    self._btn_change = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.btn_change")
    self._btn_cancel = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.btn_cancel")
    self._btn_multiple_refresh = self:getUI("bg.layer.layer_right_1.layer_mastery_refresh.btn_multiple_refresh")

    --self:initGrayProgram()
    self:visableLockImage()

    self:registerClickEvent(self._btn_refresh, function()
        self:onButtonRefreshClicked()
    end)

    self:registerClickEvent(self._btn_change, function()
        self:onButtonChangeClicked()
    end)

    self:registerClickEvent(self._btn_cancel, function()
        self:onButtonCancelClicked()
    end)

    self:registerClickEvent(self._btn_multiple_refresh, function()
        self:onButtonMultipleRefreshClicked()
    end)

    self._allMasteryBtn = self:getUI("bg.layer.layer_right_1.layer_mastery.btn_all_mastery")
    self._allMasteryBtn:setTitleFontSize(22)
    self:registerClickEventByName("bg.layer.layer_right_1.layer_mastery.btn_all_mastery", function ()
        if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
            self._container:showTopInfo(false)
        end
        self._viewMgr:showDialog("hero.HeroAllMasteryView", { heroData = self._heroData, callback = function()
            if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                self._container:showTopInfo(true)
            end
        end }, true)
    end)

    -- layer right 2

    self._layerRight2 = self:getUI("bg.layer.layer_right_2")

    self._labelSpecialty = self:getUI("bg.layer.layer_right_2.layer_specialty.label_specialty")
    --self._labelSpecialty:setFontName(UIUtils.ttfName_Title)
    --self._labelSpecialty:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._specialtyName = self:getUI("bg.layer.layer_right_2.layer_specialty.label_specialty_name")
    --self._specialtyName:setFontName(UIUtils.ttfName_Title)
    --self._specialtyName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._heroSpecialtyInfo = {}
    for i = 1, 4 do
        self._heroSpecialtyInfo[i] = {}
        self._heroSpecialtyInfo[i]._imageFrame = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".image_frame")
        self._heroSpecialtyInfo[i]._imageGlobalFrame = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".image_global_frame")
        self._heroSpecialtyInfo[i]._imageStar = {}
        for j = 1, 4 do
            self._heroSpecialtyInfo[i]._imageStar[j] = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".image_star_" .. j)
        end
        self._heroSpecialtyInfo[i]._imageLocked = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".image_locked")
        self._heroSpecialtyInfo[i]._imageMask = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".image_mask")
        self._heroSpecialtyInfo[i]._imageSpecialtyIcon = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".image_specialty_icon")
        self._heroSpecialtyInfo[i]._labelSpecialtyDes = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".layer_specialty_des")
        self._heroSpecialtyInfo[i]._imageGlobalSpecialtyBg = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".image_global_specialty_bg")
        self._heroSpecialtyInfo[i]._labelGlobalTitle = self:getUI("bg.layer.layer_right_2.image_specialty_bg_" .. i .. ".image_global_specialty_bg.label_global_title")
        --self._heroSpecialtyInfo[i]._labelGlobalTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    
    --[[
    self._layerRight2 = self:getUI("bg.layer.layer_right_2")

    self._specialtyIcon = self:getUI("bg.layer.layer_right_2.layer_specialty.image_hero_specialty")
    self._specialtyIcon:setScale(0.8)
    self._specialtyIcon.tipOffset = cc.p(20,70)
    self:registerTouchEvent(self._specialtyIcon, function(x, y)
        self:startClock(self._specialtyIcon, FormationIconView.kIconTypeHeroSpecialty, self._heroData.special)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    
    self._specialtyStar = {}
    for i = 1, 4 do
        self._specialtyStar[i] = self:getUI("bg.layer.layer_right_2.layer_specialty.image_hero_frame.image_star_" .. i)
        self._specialtyStar[i]:setVisible(false)
    end

    self._specialtyName = self:getUI("bg.layer.layer_right_2.layer_specialty.label_specialty_name")
    self._specialtyName:setFontName(UIUtils.ttfName_Title)
    self._specialtyName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    
    --self._specialtyDescription = self:getUI("bg.layer.layer_right_2.layer_specialty.layer_specialty_description")
    ]]

    -- layer attribute
    self._scheduler = cc.Director:getInstance():getScheduler()
    self._layerAttribute = self:getUI("bg.layer.layer_attribute")
    --[[
    self._layerTips = self:getUI("bg.layer.layer_attribute.layer_tips")
    self:registerTouchEvent(self._layerTips, function(x, y)
         self:startClock(self._layerTips, FormationIconView.kIconTypeAllAttributes, 0)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    ]]
    --[[
    self._layerAtkIcon = self:getUI("bg.layer.layer_attribute.layer_atk_icon")
    self:registerTouchEvent(self._layerAtkIcon, function(x, y)
        self:startClock(self._layerAtkIcon, FormationIconView.kIconTypeAttributeAtk, 0)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    self._labelAtkValue = self:getUI("bg.layer.layer_attribute.layer_atk_icon.label_atk_value")
    self._labelAtkValue:setFontSize(18)
    self._labelAtkValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._labelAtkAdditionValue = self:getUI("bg.layer.layer_attribute.layer_atk_icon.label_atk_value_addition")
    self._labelAtkAdditionValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._layerDefIcon = self:getUI("bg.layer.layer_attribute.layer_def_icon")
    self:registerTouchEvent(self._layerDefIcon, function(x, y)
       self:startClock(self._layerDefIcon, FormationIconView.kIconTypeAttributeDef, 0)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    self._labelDefValue = self:getUI("bg.layer.layer_attribute.layer_def_icon.label_def_value")
    self._labelAtkValue:setFontSize(18)
    self._labelDefValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._labelDefAdditionValue = self:getUI("bg.layer.layer_attribute.layer_def_icon.label_def_value_addition")
    self._labelDefAdditionValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._layerIntIcon = self:getUI("bg.layer.layer_attribute.layer_int_icon")
    self:registerTouchEvent(self._layerIntIcon, function(x, y)
        self:startClock(self._layerIntIcon, FormationIconView.kIconTypeAttributeInt, 0)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    self._labelIntValue = self:getUI("bg.layer.layer_attribute.layer_int_icon.label_int_value")
    self._labelAtkValue:setFontSize(18)
    self._labelIntValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._labelIntAdditionValue = self:getUI("bg.layer.layer_attribute.layer_int_icon.label_int_value_addition")
    self._labelIntAdditionValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._layerAckIcon = self:getUI("bg.layer.layer_attribute.layer_ack_icon")
    self:registerTouchEvent(self._layerAckIcon, function(x, y)
        self:startClock(self._layerAckIcon, FormationIconView.kIconTypeAttributeAck, 0)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    self._labelAckValue = self:getUI("bg.layer.layer_attribute.layer_ack_icon.label_ack_value")
    self._labelAtkValue:setFontSize(18)
    self._labelAckValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._labelAckAdditionValue = self:getUI("bg.layer.layer_attribute.layer_ack_icon.label_ack_value_addition")
    self._labelAckAdditionValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    ]]
    self._magicIcon = self:getUI("bg.layer.layer_attribute.morale_magic_bg.layer_magic")
    -- [[
    self:registerTouchEvent(self._magicIcon, function(x, y)
        self:startClock(self._magicIcon, FormationIconView.kIconTypeAttributeMagic, 0)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    --]]
    self._magicValue = self:getUI("bg.layer.layer_attribute.morale_magic_bg.layer_magic.label_magic_value")
    --self._magicValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._magicRecoverIcon = self:getUI("bg.layer.layer_attribute.morale_magic_bg.layer_magic_recover")
    -- [[
    self:registerTouchEvent(self._magicRecoverIcon, function(x, y)
        self:startClock(self._magicRecoverIcon, FormationIconView.kIconTypeAttributeMorale, 0)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    --]]
    self._magicRecoverValue = self:getUI("bg.layer.layer_attribute.morale_magic_bg.layer_magic_recover.label_magic_recover_value")
    --self._magicRecoverValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._damageIcon = self:getUI("bg.layer.layer_attribute.morale_magic_bg.layer_damage")
    -- [[
    self:registerTouchEvent(self._damageIcon, function(x, y)
        self:startClock(self._damageIcon, FormationIconView.kIconTypeHeroSkillDamage, 0)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    --]]
    self._damageValue = self:getUI("bg.layer.layer_attribute.morale_magic_bg.layer_damage.label_damage_value")
    --self._damageValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    -- layer right 3
    self._layerRight3 = self:getUI("bg.layer.layer_right_3")

    -- hero upgrade
    self._upgrade = {}
    --self._upgrade._currentStarName = self:getUI("bg.layer.layer_right_3.layer_attribute.hero_star_bg.layer_current.label_name")
    self._upgrade._currentStar = {}
    for i = 1, 4 do
        self._upgrade._currentStar[i] = self:getUI("bg.layer.layer_right_3.layer_attribute.hero_star_bg.layer_current.layer_star.star_n_" .. i)
    end
    --self._upgrade._nextStarName = self:getUI("bg.layer.layer_right_3.layer_attribute.hero_star_bg.layer_next.label_name")
    self._upgrade._nextStar = {}
    for i = 1, 4 do
        self._upgrade._nextStar[i] = self:getUI("bg.layer.layer_right_3.layer_attribute.hero_star_bg.layer_next.layer_star.star_n_" .. i)
    end

    self._upgrade._imageAttr1 = self:getUI("bg.layer.layer_right_3.layer_attribute.image_attr_1.image_icon")
    --self._upgrade._imageAttr1:setColor(cc.c3b(70, 40, 0))
    self._upgrade._labelName1 = self:getUI("bg.layer.layer_right_3.layer_attribute.image_attr_1.label_name")
    self._upgrade._currentValue1 = self:getUI("bg.layer.layer_right_3.layer_attribute.image_attr_1.label_current_value")
    self._upgrade._currentValue1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._currentValue1:getVirtualRenderer():setAdditionalKerning(1)

    self._upgrade._imageAttr2 = self:getUI("bg.layer.layer_right_3.layer_attribute.image_attr_2.image_icon")
    --self._upgrade._imageAttr2:setColor(cc.c3b(70, 40, 0))
    self._upgrade._labelName2 = self:getUI("bg.layer.layer_right_3.layer_attribute.image_attr_2.label_name")
    self._upgrade._currentValue2 = self:getUI("bg.layer.layer_right_3.layer_attribute.image_attr_2.label_current_value")
    self._upgrade._currentValue2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._currentValue2:getVirtualRenderer():setAdditionalKerning(1)

    self._upgrade._nextValue1 = self:getUI("bg.layer.layer_right_3.layer_attribute.image_attr_1.label_next_value")
    self._upgrade._nextValue1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._nextValue1:getVirtualRenderer():setAdditionalKerning(1)

    self._upgrade._nextValue2 = self:getUI("bg.layer.layer_right_3.layer_attribute.image_attr_2.label_next_value")
    self._upgrade._nextValue2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._nextValue2:getVirtualRenderer():setAdditionalKerning(1)

    --[[
    local imageAtk = self:getUI("bg.layer.layer_right_3.layer_attribute.image_atk_bg.image_icon")
    imageAtk:setColor(cc.c3b(70, 40, 0))
    self._upgrade._currentAtkValue = self:getUI("bg.layer.layer_right_3.layer_attribute.image_atk_bg.label_current_value")
    self._upgrade._currentAtkValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._currentAtkValue:getVirtualRenderer():setAdditionalKerning(1)

    local imageDef = self:getUI("bg.layer.layer_right_3.layer_attribute.image_def_bg.image_icon")
    imageDef:setColor(cc.c3b(70, 40, 0))
    self._upgrade._currentDefValue = self:getUI("bg.layer.layer_right_3.layer_attribute.image_def_bg.label_current_value")
    self._upgrade._currentDefValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._currentDefValue:getVirtualRenderer():setAdditionalKerning(1)

    local imageInt = self:getUI("bg.layer.layer_right_3.layer_attribute.image_int_bg.image_icon")
    imageInt:setColor(cc.c3b(70, 40, 0))
    self._upgrade._currentIntValue = self:getUI("bg.layer.layer_right_3.layer_attribute.image_int_bg.label_current_value")
    self._upgrade._currentIntValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._currentIntValue:getVirtualRenderer():setAdditionalKerning(1)

    local imageAck = self:getUI("bg.layer.layer_right_3.layer_attribute.image_ack_bg.image_icon")
    imageAck:setColor(cc.c3b(70, 40, 0))
    self._upgrade._currentAckValue = self:getUI("bg.layer.layer_right_3.layer_attribute.image_ack_bg.label_current_value")
    self._upgrade._currentAckValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._currentAckValue:getVirtualRenderer():setAdditionalKerning(1)

    self._upgrade._nextAtkValue = self:getUI("bg.layer.layer_right_3.layer_attribute.image_atk_bg.label_next_value")
    self._upgrade._nextAtkValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._nextAtkValue:getVirtualRenderer():setAdditionalKerning(1)
    self._upgrade._nextDefValue = self:getUI("bg.layer.layer_right_3.layer_attribute.image_def_bg.label_next_value")
    self._upgrade._nextDefValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._nextDefValue:getVirtualRenderer():setAdditionalKerning(1)
    self._upgrade._nextIntValue = self:getUI("bg.layer.layer_right_3.layer_attribute.image_int_bg.label_next_value")
    self._upgrade._nextIntValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._nextIntValue:getVirtualRenderer():setAdditionalKerning(1)
    self._upgrade._nextAckValue = self:getUI("bg.layer.layer_right_3.layer_attribute.image_ack_bg.label_next_value")
    self._upgrade._nextAckValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._nextAckValue:getVirtualRenderer():setAdditionalKerning(1)
    ]]
    self._upgrade._layer1 = self:getUI("bg.layer.layer_right_3.layer_unlock_effect.layer_1")
    self._upgrade._layer2 = self:getUI("bg.layer.layer_right_3.layer_unlock_effect.layer_2")
    self._upgrade._unlock = self:getUI("bg.layer.layer_right_3.layer_unlock_effect.layer_1.label_unlock")
    --self._upgrade._unlock:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._upgrade._effectName = self:getUI("bg.layer.layer_right_3.layer_unlock_effect.layer_1.label_effect_name")
    -- self._upgrade._effectName:enableOutline(cc.c4b(81, 19, 0, 255), 2)  --(cc.c4b(0, 78, 0, 255), 2)
    self._upgrade._unlockCondition = self:getUI("bg.layer.layer_right_3.layer_unlock_effect.layer_1.label_unlock_condition")
    -- self._upgrade._unlockCondition:enableOutline(cc.c4b(81, 19, 0, 255), 2)

    self._upgrade._layerEffectDescription = self:getUI("bg.layer.layer_right_3.layer_unlock_effect.layer_1.layer_effect_description")
    self._upgrade._imageProBg = self:getUI("bg.layer.layer_right_3.layer_upgrade.image_pro_bg")
    self._upgrade._proBar = self:getUI("bg.layer.layer_right_3.layer_upgrade.image_pro_bg.upgrade_pro_bar")
    self._upgrade._upgradeValue = self:getUI("bg.layer.layer_right_3.layer_upgrade.image_pro_bg.label_upgrade_value")
    self._upgrade._upgradeValue:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._upgrade._btnAdd = self:getUI("bg.layer.layer_right_3.layer_upgrade.image_pro_bg.btn_add")
    self:registerClickEvent(self._upgrade._btnAdd, function(sender)
        self:onMaterialAdditionButtonClicked()
    end)

    self._upgrade._btnFrag = self:getUI("bg.layer.layer_right_3.layer_upgrade.btn_frag")
    self:registerClickEvent(self._upgrade._btnFrag, function(sender)
        self:onHeroFragButtonClicked()
    end)

    self._upgrade._btnUpgrade = self:getUI("bg.layer.layer_right_3.layer_upgrade.btn_upgrade")
    self:registerClickEvent(self._upgrade._btnUpgrade, function(sender)
        self:onHeroUpgradeButtonClicked()
    end)
    self._upgrade._maxLevel = self:getUI("bg.layer.layer_right_3.layer_upgrade.image_max_level")

    -- self._upgrade._mc1 = mcMgr:createViewMC("jingxiushuaxin_herospellstudyanim", false, false)
    -- self._upgrade._mc1:setVisible(false)
    -- self._widget:addChild(self._upgrade._mc1)

    self._dirdy = true
    --[[
    self:registerClickEvent(self._btn_refresh, function(sender)
        self:refreshMastery()
    end)
    ]]
    --[[
    self:registerTouchEventByName("bg.layer.btn_mastery", function(sender)
        self:onMasteryClicked()
    end)

    self:registerTouchEventByName("bg.layer.btn_attribute", function(sender)
        self:onAttributeClicked()
    end)
    ]]

    --专长tips
    self.tipsBtn = self:getUI("bg.layer.layer_right_2.layer_specialty.tipsBtn")
    local showDes = tab.hero[self._heroData.id]["showdes"]
    self.tipsBtn:setVisible(tonumber(showDes) == 1 and true or false)
    self:registerClickEvent(self.tipsBtn,function ()
        local herodes1 = tab.hero[self._heroData.id]["herodes1"]
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang(herodes1),titleDes = "专长补充"},true)
    end)

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:stopHeroMCSwitchTimer()
            SystemUtils.saveAccountLocalData("HERO_MASTERY_REFRESH_SELECTED", self._isScrollSelected and 1 or 0)
        end 
    end)
end

function HeroBasicInformationView:initSpecialtyData()
    local star = self._heroData.star
    local special = self._heroData.special
    local specialTableData = clone(tab.heroMastery)
    for k, v in pairs(specialTableData) do
        if 1 ~= v.class then
            specialTableData[k] = nil
        end
    end
    self._heroData.specialtyInfo = {
        specials = {},
        nextUnlockSpecialIndex = 0,
    }
    for k, v in pairs(specialTableData) do
        if special == v.baseid then
            v.unlock = star >= v.masterylv 
            table.insert(self._heroData.specialtyInfo.specials, v)
        end
    end
    table.sort(self._heroData.specialtyInfo.specials, function(a, b)
        return a.masterylv < b.masterylv or a.id < b.id
    end)
    for k, v in ipairs(self._heroData.specialtyInfo.specials) do
        if not v.unlock then
            self._heroData.specialtyInfo.nextUnlockSpecialIndex = k
            break
        end
    end
end

function HeroBasicInformationView:onIconPressOn(node, iconType, iconId)
    print("onIconPressOn")
    iconType = node.getIconType and node:getIconType() or iconType
    iconId = node.getIconId and node:getIconId() or iconId
    if not (iconType and iconId) then return end
    print("iconType, iconId", iconType, iconId)
    if iconType == BattleUtils.kIconTypeAllAttributes then
        --[[
        local des = ""
        for itype = BattleUtils.kIconTypeAttributeAtk, BattleUtils.kIconTypeAttributeAck do
            des = des .. BattleUtils.getDescription(itype, 0, self._attributeValues) .. "[][-]"
        end
        self:showHintView("global.GlobalTipView",{tipType = 3, node = node, des = des, center = true})
        ]]
    elseif 0 == iconId then
        local heroId = self._heroData.id
        local star = self._heroData.star
        local heroD = tab:Hero(heroId)
        local base 
        local attr, attr1, attr2, attr3, attr4, attr5, kind, icon
        if iconType == BattleUtils.kIconTypeAttributeAtk then
            kind = lang("ARTIFACTDES_PRO_112")
            icon = 1
            attr = tonumber(string.format("%.01f",self._attributeValues.atk))
            attr2 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_treasure[BattleUtils.HATTR_AtkAdd]))
            attr3 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_special[BattleUtils.HATTR_AtkAdd]))
            attr4 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_mastery[BattleUtils.HATTR_AtkAdd]))
            attr5 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_talent[BattleUtils.HATTR_AtkAdd]))
            attr1 = attr - attr2 - attr3 - attr4 - attr5
            ---[[ -- 修正数值 因 拿到几个attr值不对
            base = heroD["atk"][1]+(star-heroD.star)*heroD["atk"][2]
            attr1 = tonumber(string.format("%.01f",base))
            attr4 = tonumber(string.format("%.01f",attr - attr1 - attr2 - attr3 - attr5))
            --]]
        elseif iconType == BattleUtils.kIconTypeAttributeDef then
            kind = lang("ARTIFACTDES_PRO_115")
            icon = 2
            attr = tonumber(string.format("%.01f",self._attributeValues.def))
            attr2 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_treasure[BattleUtils.HATTR_DefAdd]))
            attr3 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_special[BattleUtils.HATTR_DefAdd]))
            attr4 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_mastery[BattleUtils.HATTR_DefAdd]))
            attr5 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_talent[BattleUtils.HATTR_DefAdd]))
            attr1 = attr - attr2 - attr3 - attr4 - attr5
            ---[[ -- 修正数值 因 拿到几个attr值不对
            base = heroD["def"][1]+(star-heroD.star)*heroD["def"][2]
            attr1 = tonumber(string.format("%.01f",base))
            attr4 = tonumber(string.format("%.01f",attr - attr1 - attr2 - attr3 - attr5))
            --]]
        elseif iconType == BattleUtils.kIconTypeAttributeInt then
            kind = lang("ARTIFACTDES_PRO_118")
            icon = 3
            attr = tonumber(string.format("%.01f",self._attributeValues.int))
            attr2 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_treasure[BattleUtils.HATTR_IntAdd]))
            attr3 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_special[BattleUtils.HATTR_IntAdd]))
            attr4 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_mastery[BattleUtils.HATTR_IntAdd]))
            attr5 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_talent[BattleUtils.HATTR_IntAdd]))
            attr1 = attr - attr2 - attr3 - attr4 - attr5
            ---[[ -- 修正数值 因 拿到几个attr值不对
            base = heroD["int"][1]+(star-heroD.star)*heroD["int"][2]
            attr1 = tonumber(string.format("%.01f",base))
            attr4 = tonumber(string.format("%.01f",attr - attr1 - attr2 - attr3 - attr5))
            --]]
        elseif iconType == BattleUtils.kIconTypeAttributeAck then
            kind = lang("ARTIFACTDES_PRO_121")
            icon = 4
            attr = tonumber(string.format("%.01f",self._attributeValues.ack))
            attr2 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_treasure[BattleUtils.HATTR_AckAdd]))
            attr3 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_special[BattleUtils.HATTR_AckAdd]))
            attr4 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_mastery[BattleUtils.HATTR_AckAdd]))
            attr5 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_talent[BattleUtils.HATTR_AckAdd]))
            attr1 = attr - attr2 - attr3 - attr4 - attr5
            ---[[ -- 修正数值 因 拿到几个attr值不对
            base = heroD["ack"][1]+(star-heroD.star)*heroD["ack"][2]
            attr1 = tonumber(string.format("%.01f",base))
            attr4 = tonumber(string.format("%.01f",attr - attr1 - attr2 - attr3 - attr5))
            --]]
        elseif iconType == BattleUtils.kIconTypeAttributeMagic then -- 魔法
            kind = "魔法" --lang("ARTIFACTDES_PRO_121")
            icon = 5
            attr = tonumber(string.format("%.01f",self._attributeValues.manaBase))
            attr5 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_treasure[BattleUtils.HATTR_Mana]))
            attr4 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_special[BattleUtils.HATTR_Mana]))
            attr3 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_mastery[BattleUtils.HATTR_Mana]))
            attr2 = tonumber(string.format("%.01f",self._attributeValues.heroAttr_talent[BattleUtils.HATTR_Mana]))
            attr1 = attr - attr2 - attr3 - attr4 - attr5
            -- 安德鲁的专长 加魔法
            base = tonumber(string.format("%.01f", tab.hero[heroId].manabase)) 
            if (attr1 - base) > 0 then
               attr4 = attr4 + attr1 - base
               attr1 = base
            end
            self:showHintView("global.GlobalTipView",
            {   
                tipType = 17, node = node,
                heroId = heroId,
                star = heroStar, 
                kind = kind,
                icon = icon,
                attr1 = attr1,
                attr2 = attr2,
                attr3 = attr3,
                attr4 = attr4,
                attr5 = attr5,
                attr6 = attr,
                posCenter = true,
            })
            --[[ -- 修正数值 因 拿到几个attr值不对
            base = self._attributeValues.manaBase
            attr1 = tonumber(string.format("%.01f",base))
            -- attr4 = tonumber(string.format("%.01f",attr - attr1 - attr2 - attr3 - attr5))
            --]]
        elseif iconType == BattleUtils.kIconTypeAttributeMorale then -- 回魔
            kind = "回魔" -- lang("ARTIFACTDES_PRO_121")
            icon = 6
            attr = tonumber(string.format("%.01f", self._attributeValues.manaRec * 2.0))
            local backupAttr = self._modelMgr:getModel("BackupModel"):getBackUpAddAtr() or {}
            local moraleV = backupAttr[104] or 0
            attr6 = tonumber(string.format("%.01f", moraleV * 2.0))
            attr5 = tonumber(string.format("%.01f", self._attributeValues.heroAttr_treasure[BattleUtils.HATTR_ManaRec] * 2.0))
            attr4 = tonumber(string.format("%.01f", self._attributeValues.heroAttr_special[BattleUtils.HATTR_ManaRec] * 2.0))
            attr3 = tonumber(string.format("%.01f", self._attributeValues.heroAttr_mastery[BattleUtils.HATTR_ManaRec] * 2.0))
            attr2 = tonumber(string.format("%.01f", self._attributeValues.heroAttr_talent[BattleUtils.HATTR_ManaRec] * 2.0))
            attr1 = attr - attr2 - attr3 - attr4 - attr5 - attr6
            -- 安德鲁的专长 加回魔
            base = tonumber(string.format("%.01f", tab.hero[heroId].manarec * 2.0)) 
            if (attr1 - base) > 0 then
               attr4 = attr4 + attr1 - base
               attr1 = base
            end
            -- [[新功能，添加法术平均消耗
            local averageMCD,slotMCD = self:caculateAverMCD(heroId)
            --法术平均消耗 end]]
            --[[ -- 修正数值 因 拿到几个attr值不对
            attr1 = tonumber(string.format("%.01f",base))
            attr4 = tonumber(string.format("%.01f",attr - attr1 - attr2 - attr3 - attr5))
            --]]
            self:showHintView("global.GlobalTipView",
            {   
                tipType = 18, node = node,
                heroId = heroId,
                star = heroStar, 
                kind = kind,
                icon = icon,
                attr1 = attr1,
                attr2 = attr2,
                attr3 = attr3,
                attr4 = attr4,
                attr5 = attr5,
                attr6 = attr6,
                attr7 = attr,
                averageMCD = averageMCD,
                slotMCD = slotMCD,
                posCenter = true,
            })
        elseif iconType == BattleUtils.kIconTypeHeroSkillDamage then
            kind = "法伤" -- lang("ARTIFACTDES_PRO_121")
            icon = 7
            local attr1 = 100 
            -- heroAttr_treasure
            local attr4 =  tonumber(string.format("%.01f",self._attributeValues.heroAttr_treasure[BattleUtils.HATTR_AP1All]))
            -- 宝物技能
            local treasureSkillAdd = self._modelMgr:getModel("TreasureModel"):caculateMagicHurtBySkill()
            attr4 = attr4+treasureSkillAdd
            -- heroAttr_special
            local attr3 =  tonumber(string.format("%.01f",self._attributeValues.heroAttr_special[BattleUtils.HATTR_AP1All]))
            -- heroAttr_mastery
            attr3 = attr3 + tonumber(string.format("%.01f",self._attributeValues.heroAttr_mastery[BattleUtils.HATTR_AP1All]))
            -- heroAttr_talent
            local attr2 =  tonumber(string.format("%.01f",self._attributeValues.heroAttr_talent[BattleUtils.HATTR_AP1All]))
            --星图
            local starAttr = self._modelMgr:getModel("UserModel"):getStarHeroAttr() or {}
            local attr6 =  tonumber(string.format("%.01f",starAttr[BattleUtils.HATTR_AP1All + 100] or 0))

            local attr = attr1+attr2+attr3+attr4+attr6
            self:showHintView("global.GlobalTipView",
            {
                tipType = 21, 
                node = node, 
                id = iconId, 
                heroData = clone(self._heroData), 
                attr1 = attr1,
                attr2 = attr2,
                attr3 = attr3,
                attr4 = attr4,
                attr5 = attr,
                attr6 = attr6,
                des = "", 
                posCenter = true
            })
            return 
        end
        if icon == 5 or icon == 6 then return end
        self:showHintView("global.GlobalTipView",
        {   
            tipType = 3, node = node,
            heroId = heroId,
            star = heroStar, 
            kind = kind,
            icon = icon,
            attr = attr,
            attr1 = attr1,
            attr2 = attr2,
            attr3 = attr3,
            attr4 = attr4,
            attr5 = attr5,
            des = BattleUtils.getDescription(iconType, iconId, self._attributeValues),
            posCenter = true,
        })
    elseif iconType == BattleUtils.kIconTypeHeroMastery then
        self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = iconId, des = BattleUtils.getDescription(iconType, iconId, self._attributeValues), posCenter = true})
    elseif iconType == BattleUtils.kIconTypeHeroSpecialty then
        self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = iconId, heroData = clone(self._heroData), des = "", posCenter = true})
    end
end

-- 辅助函数 计算法伤
function HeroBasicInformationView:caculateMagicHurt( )
    local attr1 = 100 
    -- heroAttr_treasure
    local attr4 =  tonumber(string.format("%.01f",self._attributeValues.heroAttr_treasure[BattleUtils.HATTR_AP1All]))
    -- 宝物技能
    local treasureSkillAdd = self._modelMgr:getModel("TreasureModel"):caculateMagicHurtBySkill()
    attr4 = attr4+treasureSkillAdd
    -- heroAttr_special
    local attr3 =  tonumber(string.format("%.01f",self._attributeValues.heroAttr_special[BattleUtils.HATTR_AP1All]))
    -- heroAttr_mastery
    attr3 = attr3 + tonumber(string.format("%.01f",self._attributeValues.heroAttr_mastery[BattleUtils.HATTR_AP1All]))
    -- heroAttr_talent
    local attr2 =  tonumber(string.format("%.01f",self._attributeValues.heroAttr_talent[BattleUtils.HATTR_AP1All]))
    --星图
    local starAttr = self._modelMgr:getModel("UserModel"):getStarHeroAttr() or {}
    local attr5 =  tonumber(string.format("%.01f",starAttr[BattleUtils.HATTR_AP1All + 100] or 0))

    local attr = attr1+attr2+attr3+attr4+attr5
    return attr
end

-- 辅助函数，计算平均法术消耗先写在这里有其他功能需要再迁移到model里
function HeroBasicInformationView:caculateAverMCD( heroId )
    if not self._heroData or not self._attributeValues then return end
    local heroData = self._heroData or clone(self._modelMgr:getModel("HeroModel"):getData()[tostring(heroId)])
    local attributes = self._attributeValues or BattleUtils.getHeroAttributes(self._heroData)
    -- dump(heroData,"heroData...")
    local caculateMcd = function( skillId )
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId or skillId
        end
        local dataD = tab.playerSkillEffect[skillId]
        if dataD and dataD.manacost then --and not data._skillType then
            -- dump(dataD)
            local mcdData = attributes.MCD
            local mcdAddition = 0
            if dataD.type > 1 then
                mcdAddition = (1 - mcdData[dataD.mgtype][dataD.type - 1] - mcdData[dataD.mgtype][5] - mcdData[4][dataD.type - 1] - mcdData[4][5])
            else
                mcdAddition = (1 - mcdData[dataD.mgtype][5] - mcdData[4][5])
            end
            return math.floor(dataD.manacost[1]*mcdAddition)
        end
        return 0
    end
    local caculateCd = function( skillId )
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroData.id), skillId)
        if isReplaced then
            skillId = skillReplacedId or skillId
        end
        local dataD = tab.playerSkillEffect[skillId] or tab.heroMastery[skillId]
        if dataD and dataD.cd then --and not data._skillType then
            -- desTable[#desTable+1] = "冷却时间:[color = d7ad6a]".. data.cd[1]/1000 .."s[-][][-]"math.round((dataD.cd[1] - (skillLevel-1)*dataD.cd[2]) / 100)/10
            local cdData = attributes.cd
            local cdAddition = 0
            if dataD.type > 1 then
                cdAddition = (1 - cdData[dataD.mgtype][dataD.type - 1] - cdData[dataD.mgtype][5] - cdData[4][dataD.type - 1] - cdData[4][5])
            else
                cdAddition = (1 - cdData[dataD.mgtype][5] - cdData[4][5])
            end
            local skillLevel = 1
            for k,v in pairs(attributes.skills) do
                local sid = v[1]
                if skillId == sid then
                    skillLevel = v[2]
                    break
                end
            end
            local cdNum = tonumber(math.ceil((dataD.cd[1] - ((skillLevel or 1)-1)*dataD.cd[2]) / 100 / 10 * cdAddition))
            return cdNum
        end
        return 1
    end
    local sum = 0
    for i = 1, 4 do
        local skillId = self._heroData.spell[i]
        local mcd = caculateMcd(skillId)
        local cd = caculateCd(skillId)
        if cd == 0 then cd = 1 end
        sum = sum + mcd/cd
    end
    local slotMCD
    local sid = heroData.slot and tonumber(heroData.slot.sid) 
    if sid and sid ~= 0 then
        local skillId = sid
        local mcd = caculateMcd(skillId) or 0
        local cd = caculateCd(skillId) or 1
        if cd == 0 then cd = 1 end
        -- sum = sum + mcd/cd
        slotMCD = tonumber(string.format("%.1f",mcd/cd))*2
    end
    return tonumber(string.format("%.1f",sum))*2,slotMCD  
end

function HeroBasicInformationView:onIconPressOff()
    --print("onIconPressOff")
    -- self:closeHintView()
end

function HeroBasicInformationView:startClock(node, iconType, iconId)
    self:onIconPressOn(node, iconType, iconId)
    --[[
    if self._timer_id then self:endClock() end
     self._first_tick = true
     self._timer_id = self._scheduler:scheduleScriptFunc(function()
         if not self._first_tick then return end
         self._first_tick = false
        self:onIconPressOn(node, iconType, iconId)
     end, 0.2, false)
    ]]
end

function HeroBasicInformationView:endClock()
    --[[
    if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
    self:onIconPressOff()
    ]]
end

function HeroBasicInformationView:switchHeroMC()
    if not self._heroMCName then return end
    for i = 1, #self._heroMCName do
        repeat
            if not self._heroBodyMC[i] then break end
            if i == self._currentHeroMCIndex then
                self._heroBodyMC[i]:gotoAndPlay(0)
                self._heroBodyMC[i]:setVisible(true)
            else
                self._heroBodyMC[i]:setVisible(false)
                self._heroBodyMC[i]:stop()
            end
        until true
    end
    self._currentHeroMCIndex = self._currentHeroMCIndex + 1 > 5 and 1 or self._currentHeroMCIndex + 1
end

function HeroBasicInformationView:startHeroMCSwitchTimer()
    if self._heroMCSwitchTimer then return end
    self._heroMCSwitchTimer = self._scheduler:scheduleScriptFunc(function()
        self:switchHeroMC()
    end, 5, false)
end

function HeroBasicInformationView:stopHeroMCSwitchTimer()
    if not self._heroMCSwitchTimer then return end
    self._scheduler:unscheduleScriptEntry(self._heroMCSwitchTimer)
    self._heroMCSwitchTimer = nil
end

function HeroBasicInformationView:onTop()
    self._dirdy = true
    self:updateUI(self._viewType)
end

function HeroBasicInformationView:updateUI(viewType, force)
    if not self._heroData then return end
    if self._viewType == viewType and not self._dirdy and not force then return end
    self._viewType = viewType
    self._attributeValues = BattleUtils.getHeroAttributes(self._heroData)
    for i = 1, 4 do
        if i <= self._heroData.star then
            self._heroStar[i]:setVisible(true)
        else
            self._heroStar[i]:setVisible(false)
        end
    end
    self._heroName:setString(lang(self._heroData.heroname))
    self._heroCareer:setString(lang(string.format("HERO_PROFESSION_%02d", self._heroData.prof)))
    local icon = self._heroIcon:getChildByTag(HeroBasicInformationView.kHeroTag)
    if not icon then
        icon = IconUtils:createHeroIconById({sysHeroData = self._heroData})
        icon:setTag(HeroBasicInformationView.kHeroTag)
        icon:setPosition(self._heroIcon:getContentSize().width / 2, self._heroIcon:getContentSize().height / 2)
        self._heroIcon:addChild(icon)
    else
        IconUtils:updateHeroIconByView(icon, {sysHeroData = self._heroData})
    end
    --self._heroImage:loadTexture(IconUtils.iconPath .. self._heroData.herohead .. ".jpg")
    --self._btn_refresh:setVisible(self._heroData.unlock)

    if self._viewType == self.kViewTypeMasteryInformation then
        self._layerInfo:setVisible(false)
        self._layerAttribute:setVisible(false)
        self._layerRight1:setVisible(true)
        self._layerRight2:setVisible(false)
        self._layerRight3:setVisible(false)
        --self._layerHeroBody:setPosition(78, 90)
    elseif self._viewType == self.kViewTypeBasicInformation then
        self._layerInfo:setVisible(true)
        self._layerAttribute:setVisible(true)
        self._layerRight1:setVisible(false)
        self._layerRight2:setVisible(true)
        self._layerRight3:setVisible(false)
        --self._layerHeroBody:setPosition(78, 90)
    else
        self._layerInfo:setVisible(true)
        self._layerAttribute:setVisible(true)
        self._layerRight1:setVisible(false)
        self._layerRight2:setVisible(false)
        self._layerRight3:setVisible(true)
        --self._layerHeroBody:setPosition(78, 90)
    end

    if self._dirdy then
        self:updateAttribute()
        self:updateMastery()
        self:updateSpecialty()
        self:updateUpgrade()
    end
    self._dirdy = false
end

function HeroBasicInformationView:updateUpgrade()
    local star = self._heroData.star
    local specials = self._heroData.specialtyInfo.specials
    local nextUnlockSpecialIndex = self._heroData.specialtyInfo.nextUnlockSpecialIndex
    local nextStar = 0 == nextUnlockSpecialIndex and star or star + 1

    self._upgrade._layer1:setVisible(nextUnlockSpecialIndex > 0)
    self._upgrade._layer2:setVisible(0 == nextUnlockSpecialIndex)

    --self._upgrade._currentStarName:setString(lang(string.format("HEROSTAR_%02d", star)))
    --self._upgrade._nextStarName:setString(lang(string.format("HEROSTAR_%02d", nextStar)))

    for i = 1, 4 do
        if i <= star then
            self._upgrade._currentStar[i]:setVisible(true)
        else
            self._upgrade._currentStar[i]:setVisible(false)
        end
    end

    for i = 1, 4 do
        if i <= nextStar then
            self._upgrade._nextStar[i]:setVisible(true)
        else
            self._upgrade._nextStar[i]:setVisible(false)
        end
    end

    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "英雄攻击", def = "英雄防御", int = "英雄智力", ack = "英雄知识"}
    local index = 1
    local heroTableData = tab:Hero(self._heroData.id)
    local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local value = 0
            if self._heroModel:checkHero(self._heroData.id) then
                value = heroTableData[att][1] + (star - 1) * heroTableData[att][2]
            end
            self._upgrade["_imageAttr" .. index]:loadTexture(att .. "_icon3_hero.png", 1)
            self._upgrade["_labelName" .. index]:setString(attributesName[att])
            self._upgrade["_currentValue" .. index]:setString(value)
            if self._heroModel:checkHero(self._heroData.id) then
                value = heroTableData[att][1] + (nextStar - 1) * heroTableData[att][2]
            end
            self._upgrade["_nextValue" .. index]:setString(value)
            if star == 4 then
                self._upgrade["_nextValue" .. index]:setString("Max")
                self._upgrade["_nextValue" .. index]:setColor(cc.c3b(255,229,30))
                self._upgrade["_nextValue" .. index]:enableOutline(cc.c4b(126,77,0,255), 1)
            end
            index = math.min(index + 1, 2)
        end
    end

    --[[
    local heroTableData = tab:Hero(self._heroData.id)
    local value = self._heroData.atk[1] + (star - heroTableData.star) * self._heroData.atk[2]
    self._upgrade._currentAtkValue:setString(string.format("%d", value))
    value = self._heroData.def[1] + (star - heroTableData.star) * self._heroData.def[2]
    self._upgrade._currentDefValue:setString(string.format("%d", value))
    value = self._heroData.int[1] + (star - heroTableData.star) * self._heroData.int[2]
    self._upgrade._currentIntValue:setString(string.format("%d", value))
    value = self._heroData.ack[1] + (star - heroTableData.star) * self._heroData.ack[2]
    self._upgrade._currentAckValue:setString(string.format("%d", value))

    value = self._heroData.atk[1] + (nextStar - heroTableData.star) * self._heroData.atk[2]
    self._upgrade._nextAtkValue:setString(string.format("%d", value))
    value = self._heroData.def[1] + (nextStar - heroTableData.star) * self._heroData.def[2]
    self._upgrade._nextDefValue:setString(string.format("%d", value))
    value = self._heroData.int[1] + (nextStar - heroTableData.star) * self._heroData.int[2]
    self._upgrade._nextIntValue:setString(string.format("%d", value))
    value = self._heroData.ack[1] + (nextStar - heroTableData.star) * self._heroData.ack[2]
    self._upgrade._nextAckValue:setString(string.format("%d", value))

    if star == 4 then
        self._upgrade._nextAtkValue:setString("Max")
        self._upgrade._nextAtkValue:setColor(cc.c3b(255,229,30))
        self._upgrade._nextAtkValue:enableOutline(cc.c4b(126,77,0,255), 1)
        self._upgrade._nextDefValue:setString("Max")
        self._upgrade._nextDefValue:setColor(cc.c3b(255,229,30))
        self._upgrade._nextDefValue:enableOutline(cc.c4b(126,77,0,255), 1)
        self._upgrade._nextIntValue:setString("Max")
        self._upgrade._nextIntValue:setColor(cc.c3b(255,229,30))
        self._upgrade._nextIntValue:enableOutline(cc.c4b(126,77,0,255), 1)
        self._upgrade._nextAckValue:setString("Max")
        self._upgrade._nextAckValue:setColor(cc.c3b(255,229,30))
        self._upgrade._nextAckValue:enableOutline(cc.c4b(126,77,0,255), 1)
    end
    ]]
    if nextUnlockSpecialIndex > 0 then
        self._upgrade._imageProBg:setVisible(true)
        self._upgrade._btnFrag:setVisible(true)
        self._upgrade._btnUpgrade:setVisible(true)
        self._upgrade._maxLevel:setVisible(false)
        self._upgrade._unlock:setString(nextStar .."星专长解锁效果:")
        self._upgrade._effectName:setString(lang(specials[nextUnlockSpecialIndex].name))
        self._upgrade._unlockCondition:setString("（" .. lang(string.format("HEROSTAR_%02d", nextStar)) .. "解锁）")
        local labelDiscription = self._upgrade._layerEffectDescription
        local originWidth,originHeight = labelDiscription:getContentSize().width,labelDiscription:getContentSize().height
        local desc = "[color=645252, fontsize=18]" .. lang(specials[nextUnlockSpecialIndex].des) .. "[-]"
        local richText = labelDiscription:getChildByName("descRichText")  cc.c4b(81, 19, 0, 255)
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, originWidth-30, originHeight - 5)
        richText:formatText()
        richText:enablePrinter(true)
        local rtRealHeight = richText:getRealSize().height
        richText:setPosition(originWidth / 2, rtRealHeight/2 )
        richText:setName("descRichText")
        labelDiscription:addChild(richText)
        UIUtils:alignRichText(richText)
        
        labelDiscription:setTouchEnabled(rtRealHeight > originHeight)
        local realHeight = math.max(rtRealHeight,originHeight)
        labelDiscription:setInnerContainerSize(cc.size(originWidth,realHeight))
        labelDiscription:getInnerContainer():setPositionY(originHeight - rtRealHeight)
       

        local ok = true
        local cost = {}
        if 0 == star then
            cost = {[1] = self._heroData.unlockcost}
        else
            cost = self._heroData.starcost[star]
        end
        for k, v in pairs(cost) do
            local have, consume = 0, v[3]
            if "tool" == v[1] then
                local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
                have = toolNum
                self._upgrade._upgradeValue:setString(string.format("%d/%d", have, consume))
                self._upgrade._proBar:setPercent(have / consume * 100)
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
        --self._upgrade._btnUpgrade:setEnabled(ok)
        self._upgrade._btnUpgrade:setBright(ok)
        self._upgrade._btnUpgrade:setSaturation(ok and 0 or -100)

        local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(HeroBasicInformationView.kFragToolId)
        --self._upgrade._btnFrag:setEnabled(toolNum > 0)
        self._upgrade._btnFrag:setBright(toolNum > 0)
        self._upgrade._btnFrag:setSaturation(toolNum > 0 and 0 or -100)
    else
        self._upgrade._imageProBg:setVisible(false)
        self._upgrade._btnFrag:setVisible(false)
        self._upgrade._btnUpgrade:setVisible(false)
        self._upgrade._maxLevel:setVisible(true)
    end
    --[[
    self._upgrade._layerEffectDescription = self:getUI("bg.layer.layer_right_2.layer_unlock_effect.layer_effect_description")

    self._upgrade._proBar = self:getUI("bg.layer.layer_right_2.layer_upgrade.image_pro_bg.upgrade_pro_bar")
    self._upgrade._upgradeValue = self:getUI("bg.layer.layer_right_2.layer_upgrade.image_pro_bg.label_upgrade_value")
    self._upgrade._btnAdd = self:getUI("bg.layer.layer_right_2.layer_upgrade.image_pro_bg.btn_add")
    self:registerTouchEvent(self._upgrade._btnAdd, function(sender)
        print("on add button clicked")
    end)
    self._upgrade._btnUpgrade = self:getUI("bg.layer.layer_right_2.layer_upgrade.btn_upgrade")
    self:registerTouchEvent(self._upgrade._btnUpgrade, function(sender)
        print("on upgrade button clicked")
    end)
    ]]
end

function HeroBasicInformationView:isRefreshButtonClicked()
    return self._is_refresh_btn_clicked
end

function HeroBasicInformationView:updateMasteryRefreshConsumeInfo()
    --local firstFreeTimes = tonumber(self._userModel:getPlayerStatis().snum20)
    local firstFreeTimes = self._modelMgr:getModel("PlayerTodayModel"):getData().day4
    self._first_free_times:setVisible(0 == firstFreeTimes)

    --[[
    local playerDayInfoData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    local freeTimes = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_12) - playerDayInfoData.day4
    self._image_privileges_icon:setVisible(1 == firstFreeTimes and freeTimes > 0)
    self._label_free_times_value:setString("(" .. freeTimes .. ")")
    ]]

    local _, scrollNum = self._itemModel:getItemsById(3015)
    --self._imageConsumeScroll:setVisible(1 == firstFreeTimes and freeTimes <= 0 and scrollNum > 0)
    self._imageConsumeScroll:setVisible(1 == firstFreeTimes and scrollNum > 0)
    self._labelConsumeScrollValue:setString(scrollNum)
    self._labelConsumeScrollValue:setPositionX(self._labelConsumeScrollValue1:getPositionX() + self._labelConsumeScrollValue1:getContentSize().width + 3)
    self._labelConsumeScrollValue2:setPositionX(self._labelConsumeScrollValue:getPositionX() + self._labelConsumeScrollValue:getContentSize().width + 3)

    --self._imageConsume:setVisible(1 == firstFreeTimes and freeTimes <= 0 and (not self._isScrollSelected or scrollNum <= 0))
    self._imageConsume:setVisible(1 == firstFreeTimes and (not self._isScrollSelected or scrollNum <= 0))
    local consume = self._refreshConsume[self:getLockedCount() + 1][1] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22))
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    if totalGem < consume then
        self._labelConsumeValue:setColor(cc.c3b(255, 0, 0))
        --self._labelConsumeValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    else
        self._labelConsumeValue:setColor(cc.c3b(130, 85, 40))
        --self._labelConsumeValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    end
    self._labelConsumeValue:setString(consume)
    local consumeGold = self._refreshConsume[self:getLockedCount() + 1][2] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22))
    local totalGold = self._modelMgr:getModel("UserModel"):getData().gold
    if totalGold < consumeGold then
        self._labelConsumeGoldValue:setColor(cc.c3b(255, 0, 0))
        --self._labelConsumeGoldValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    else
        self._labelConsumeGoldValue:setColor(cc.c3b(130, 85, 40))
        --self._labelConsumeGoldValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    end
    self._labelConsumeGoldValue:setString(consumeGold)
    --self._imageConsumeBg:setVisible(not self._is_refresh_btn_clicked and freeTimes <= 0)
end

function HeroBasicInformationView:updateMastery()
    -- mastery
    local recommandMasteryData = self._heroData.recmastery
    local isCurrentRecommand = function(masteryId)
        local masteryData = tab:HeroMastery(masteryId)
        for i = 1, #recommandMasteryData do
            if recommandMasteryData[i] == masteryData.baseid and masteryData.masterylv >= 2 then
                return true
            end
        end
        return false
    end

    local isMasteryGlobal = function(masteryId)
        local masteryData = tab:HeroMastery(masteryId)
        return masteryData and 1 == masteryData.global
    end

    for i=1, 4 do
        local iconGrid = self._masteryUI[i]._icon
        local icon = iconGrid:getChildByTag(self.kHeroMasteryTag)
        if not icon then
            icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = self._heroData["m" .. i], container = { _container = self }, })
            icon:setScale(1.1)
            icon:setScaleAnim(true)
            icon:setPosition(iconGrid:getContentSize().width / 2 , iconGrid:getContentSize().height / 2)
            icon:setTag(self.kHeroMasteryTag)
            self._masteryUI[i]._recommand:retain()
            self._masteryUI[i]._recommand:removeFromParent()
            self._masteryUI[i]._recommand:setScale(0.9)
            self._masteryUI[i]._recommand:setPosition(25, 70)
            icon:addChild(self._masteryUI[i]._recommand, 100)
            self._masteryUI[i]._recommand:release()
            iconGrid:addChild(icon)
        end 
        icon = iconGrid:getChildByTag(self.kHeroMasteryTag)
        icon:setIconType(FormationIconView.kIconTypeHeroMastery)
        icon:setIconId(self._heroData["m" .. i])
        icon:updateIconInformation()
        local isRecommend = recommandMasteryData and isCurrentRecommand(self._heroData["m" .. i])
        local isGlobal = isMasteryGlobal(self._heroData["m" .. i])
        if self._isHeroLoaded then
            if isRecommend then
                self._masteryUI[i]._recommand:setVisible(true)
                self._masteryUI[i]._recommand:loadTexture("mastery_recommand_hero.png", 1)
            elseif isGlobal then
                self._masteryUI[i]._recommand:setVisible(true)
                self._masteryUI[i]._recommand:loadTexture("mastery_global_hero.png", 1)
            else
                self._masteryUI[i]._recommand:setVisible(false)
            end
        else
            if isGlobal then
                self._masteryUI[i]._recommand:setVisible(true)
                self._masteryUI[i]._recommand:loadTexture("mastery_global_hero.png", 1)
            elseif isRecommend then
                self._masteryUI[i]._recommand:setVisible(true)
                self._masteryUI[i]._recommand:loadTexture("mastery_recommand_hero.png", 1)
            else
                self._masteryUI[i]._recommand:setVisible(false)
            end
        end
        local dataCurrent = tab:HeroMastery(self._heroData["m" .. i])
        local currentLv = dataCurrent.masterylv
        local color = nil
        local outlineColor = nil
        local levelName = nil
        if 1 == currentLv then
            color = cc.c3b(118, 238, 0)
            outlineColor = cc.c4b(0, 78, 0, 255)
            levelName = "初级"
        elseif 2 == currentLv then
            color = cc.c3b(72, 210, 255)
            outlineColor = cc.c4b(0, 44, 118, 255)
            levelName = "中级"
        elseif 3 == currentLv then
            color = cc.c3b(239, 109, 254)
            outlineColor = cc.c4b(71, 0, 140, 255)
            levelName = "高级"
        end
        if levelName then
            self._masteryUI[i]._level:setString(levelName)    
        end
        self._masteryUI[i]._level:setColor(color)
        if outlineColor then
            self._masteryUI[i]._level:enableOutline(outlineColor, 1)
        else
            self._masteryUI[i]._level:disableEffect()
        end
        --[[
        local data = tab:HeroMastery(self._heroData["m" .. i])
        local label = self._masteryUI[i]._level
        local desc = lang("HEROMASTERY_LV_" .. data.masterylv)
        local richText = label:getChildByName("descRichText")
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, label:getContentSize().width, label:getContentSize().height)
        richText:formatText()
        richText:enablePrinter(true)
        richText:setPosition(label:getContentSize().width - 3, label:getContentSize().height - richText:getInnerSize().height / 2)
        richText:setName("descRichText")
        label:addChild(richText)
        --self._masteryUI[i]._name:setString(lang(data.name))
        ]]
    end

    local isNewestRecommand = function(index)
        local masteryCurrentData = tab:HeroMastery(self._currentMastery[index]._value)
        local masteryNewestData = tab:HeroMastery(self._newestMastery[index]._value)
        for i = 1, #recommandMasteryData do
            if recommandMasteryData[i] == masteryNewestData.baseid and masteryNewestData.masterylv >= 2 and not (masteryCurrentData.baseid == masteryNewestData.baseid and masteryCurrentData.masterylv > masteryNewestData.masterylv) then
                return true
            end
        end
        return false
    end

    for i=1, 4 do
        -- current mastery
        local dataCurrent = tab:HeroMastery(self._currentMastery[i]._value)
        local icon = self._currentMastery[i]._image:getChildByTag(self.kCurrentMasteryIconTag)
        if not icon then
            icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataCurrent.id, container = { _container = self } })
            icon:setScale(1)
            icon:setScaleAnim(true)
            icon:setPosition(self._currentMastery[i]._image:getContentSize().width / 2, self._currentMastery[i]._image:getContentSize().height / 2)
            icon:setTag(self.kCurrentMasteryIconTag)
            self._currentMastery[i]._image_recommand:retain()
            self._currentMastery[i]._image_recommand:removeFromParent()
            --self._currentMastery[i]._image_recommand:setScale(0.9)
            self._currentMastery[i]._image_recommand:setPosition(25, 70)
            icon:addChild(self._currentMastery[i]._image_recommand, 100)
            self._currentMastery[i]._image_recommand:release()
            self._currentMastery[i]._image:addChild(icon)
        end 
        icon = self._currentMastery[i]._image:getChildByTag(self.kCurrentMasteryIconTag)
        icon:setIconType(FormationIconView.kIconTypeHeroMastery)
        icon:setIconId(dataCurrent.id)
        icon:updateIconInformation()

        --self._currentMastery[i]._labelMasteryName:setString(lang(dataCurrent.name))

        local isRecommend = recommandMasteryData and isCurrentRecommand(dataCurrent.id)
        local isGlobal = isMasteryGlobal(dataCurrent.id)
        if self._isHeroLoaded then
            if isRecommend then
                self._currentMastery[i]._image_recommand:setVisible(true)
                self._currentMastery[i]._image_recommand:loadTexture("mastery_recommand_hero.png", 1)
            elseif isGlobal then
                self._currentMastery[i]._image_recommand:setVisible(true)
                self._currentMastery[i]._image_recommand:loadTexture("mastery_global_hero.png", 1)
            else
                self._currentMastery[i]._image_recommand:setVisible(false)
            end
        else
            if isGlobal then
                self._currentMastery[i]._image_recommand:setVisible(true)
                self._currentMastery[i]._image_recommand:loadTexture("mastery_global_hero.png", 1)
            elseif isRecommend then
                self._currentMastery[i]._image_recommand:setVisible(true)
                self._currentMastery[i]._image_recommand:loadTexture("mastery_recommand_hero.png", 1)
            else
                self._currentMastery[i]._image_recommand:setVisible(false)
            end
        end

        --self._currentMastery[i]._image_recommand:setVisible(recommandMasteryData and isCurrentRecommand(dataCurrent.id))

        -- newest mastery
        local dataNewest = tab:HeroMastery(self._newestMastery[i]._value)
        -- print("dataNewest,,,,,",dataNewest,self._newestMastery[i]._value)
        local icon = self._newestMastery[i]._image:getChildByTag(self.kNewestMasteryIconTag)
        if not icon then
            icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataNewest.id, container = { _container = self } })
            -- icon:setScale(1.17)
            icon:setScaleAnim(true)
            icon:setPosition(self._newestMastery[i]._image:getContentSize().width / 2, self._newestMastery[i]._image:getContentSize().height / 2)
            icon:setTag(self.kNewestMasteryIconTag)
            self._newestMastery[i]._image_recommand:retain()
            self._newestMastery[i]._image_recommand:removeFromParent()
            --self._newestMastery[i]._image_recommand:setScale(0.9)
            self._newestMastery[i]._image_recommand:setPosition(25, 70)
            icon:addChild(self._newestMastery[i]._image_recommand, 100)
            self._newestMastery[i]._image_recommand:release()
            self._newestMastery[i]._image:addChild(icon)
        end 
        icon = self._newestMastery[i]._image:getChildByTag(self.kNewestMasteryIconTag)
        icon:enableTouch(true)
        icon:setIconType(FormationIconView.kIconTypeHeroMastery)
        icon:setIconId(dataNewest.id)
        icon:updateIconInformation()

        self:updateLockRelative(i)

        --self._newestMastery[i]._labelMasteryName:setString(lang(dataNewest.name))

        local isRecommend = recommandMasteryData and isNewestRecommand(i)
        local isGlobal = isMasteryGlobal(dataNewest.id)
        if not self._newestMastery[i]._image_no_refresh:isVisible() then
            if self._isHeroLoaded then
                if isRecommend then
                    self._newestMastery[i]._image_recommand:setVisible(true)
                    self._newestMastery[i]._image_recommand:loadTexture("mastery_recommand_hero.png", 1)
                elseif isGlobal then
                    self._newestMastery[i]._image_recommand:setVisible(true)
                    self._newestMastery[i]._image_recommand:loadTexture("mastery_global_hero.png", 1)
                else
                    self._newestMastery[i]._image_recommand:setVisible(false)
                end
            else
                if isGlobal then
                    self._newestMastery[i]._image_recommand:setVisible(true)
                    self._newestMastery[i]._image_recommand:loadTexture("mastery_global_hero.png", 1)
                elseif isRecommend then
                    self._newestMastery[i]._image_recommand:setVisible(true)
                    self._newestMastery[i]._image_recommand:loadTexture("mastery_recommand_hero.png", 1)
                else
                    self._newestMastery[i]._image_recommand:setVisible(false)
                end
            end
        else
            self._newestMastery[i]._image_recommand:setVisible(false)
        end

        --self._newestMastery[i]._image_recommand:setVisible(not self._newestMastery[i]._image_no_refresh:isVisible() and recommandMasteryData and isNewestRecommand(i))

        --self._newestMastery[i]._image_no_refresh:setVisible(self._is_no_refresh)
    end

    self:updateMasteryRefreshConsumeInfo()
    self:visableLockImage()
end

function HeroBasicInformationView:updateSpecialty()
    local star = self._heroData.star
    local specials = self._heroData.specialtyInfo.specials
    local nextUnlockSpecialIndex = self._heroData.specialtyInfo.nextUnlockSpecialIndex
    local nextStar = star + 1
    self._specialtyName:setString(lang("HEROSPECIAL_" .. self._heroData.special))
    local label = self._specialtyDescription
    for i = 1, 4 do
        local isLocked = i >= nextStar
        self._heroSpecialtyInfo[i]._imageFrame:loadTexture("globalImageUI7_hsquality" .. i .. ".png", 1)
        self._heroSpecialtyInfo[i]._imageFrame:setVisible(not self._heroData.global or i ~= self._heroData.global)
        self._heroSpecialtyInfo[i]._imageGlobalFrame:loadTexture("globalImageUI7_ghsquality" .. i .. ".png", 1)
        self._heroSpecialtyInfo[i]._imageGlobalFrame:setVisible(not self._heroSpecialtyInfo[i]._imageFrame:isVisible())
        for j = 1, 4 do
            self._heroSpecialtyInfo[i]._imageStar[j]:setVisible(i == j)
        end
        self._heroSpecialtyInfo[i]._imageLocked:setVisible(isLocked)
        self._heroSpecialtyInfo[i]._imageMask:setVisible(isLocked)
        self._heroSpecialtyInfo[i]._imageSpecialtyIcon:setScale(0.8)
        self._heroSpecialtyInfo[i]._imageSpecialtyIcon:loadTexture(specials[i].icon .. ".jpg", 1)
        local label = self._heroSpecialtyInfo[i]._labelSpecialtyDes
        if label.scrollView then
            label.scrollView:removeFromParentAndCleanup()
        end
        local scrollView = ccui.ScrollView:create()
        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setContentSize(cc.size(265,80))
        scrollView:setAnchorPoint(0,0)
        scrollView:setPosition(0,0)
        scrollView:setBounceEnabled(true)
        label.scrollView = scrollView
        label:addChild(scrollView)

        local descColor = isLocked and "[color=787878, fontsize=18]" or "[color=3c2a1e, fontsize=18]" 
        local desc = descColor .. lang(specials[i].des) .. "[-]"
        -- local richText = label:getChildByName("descRichText" )
        -- if richText then
        --     richText:removeFromParentAndCleanup()
        -- end
        richText = RichTextFactory:create(desc, 252, 80)
        richText:setPixelNewline(true)
        richText:setVerticalSpace(0)
        richText:formatText()
        richText:enablePrinter(true)
        -- local _h = richText:getRealSize().height
        -- local offsetY = 0
        -- if not self._heroSpecialtyInfo[i]._imageGlobalFrame:isVisible() then
        --     offsetY = -5-_h/10
        -- end
        local rtRealHeight = richText:getRealSize().height
        richText:setName("descRichText")
        scrollView:addChild(richText)
        if self._heroSpecialtyInfo[i]._imageGlobalFrame:isVisible() then
            scrollView:setContentSize(cc.size(265,66))
            scrollView:setPosition(0,15)
        end

        richText:setPosition(label:getContentSize().width / 2, rtRealHeight/2)
        scrollView:getInnerContainer():setContentSize(cc.size(265,rtRealHeight))
        scrollView:getInnerContainer():setPositionY(scrollView:getContentSize().height  - rtRealHeight)
        scrollView:setTouchEnabled(rtRealHeight > scrollView:getContentSize().height)
        
        self._heroSpecialtyInfo[i]._imageGlobalSpecialtyBg:setVisible(self._heroSpecialtyInfo[i]._imageGlobalFrame:isVisible())
        --[[
        local color = isLocked and cc.c3b(61, 31, 0) or cc.c3b(0, 255, 30)
        if isLocked then
            self._heroSpecialtyInfo[i]._labelGlobalTitle:disableEffect()
        else
            self._heroSpecialtyInfo[i]._labelGlobalTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
        self._heroSpecialtyInfo[i]._labelGlobalTitle:setColor(color)
        ]]
    end
    
    --[[  temp comment
    local icon = self._specialtyIcon:getChildByTag(self.kHeroSpecialtyTag)
    if not icon then
        icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroSpecialty, iconId = self._heroData.special })
        icon:setPosition(self._specialtyIcon:getContentSize().width / 2, self._specialtyIcon:getContentSize().height / 2)
        icon:setTag(self.kHeroSpecialtyTag)
        self._specialtyIcon:addChild(icon)
    end 
    icon = self._specialtyIcon:getChildByTag(self.kHeroSpecialtyTag)
    icon:setIconType(FormationIconView.kIconTypeHeroSpecialty)
    icon:setIconId(self._heroData.special)
    icon:updateIconInformation()
    ]]
    --[[
    local data = tab:HeroMastery(self._heroData.special)
    self._specialtyIcon:loadTexture(IconUtils.iconPath .. data.icon .. ".jpg")
    self._specialtyName:setString(lang(data.name))
    local label = self._specialtyDescription
    local desc = lang(data.des)
    local richText = label:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, label:getContentSize().width, label:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    label:addChild(richText)
    ]]
    --[=[
    -- version 6.0
    local star = self._heroData.star
    local specials = self._heroData.specialtyInfo.specials
    local nextUnlockSpecialIndex = self._heroData.specialtyInfo.nextUnlockSpecialIndex
    local nextStar = star + 1
    --self._specialtyIcon:loadTexture(IconUtils.iconPath .. specials[1].icon .. ".jpg", 1)
    self._specialtyName:setString(lang("HEROSPECIAL_" .. self._heroData.special))
    local label = self._specialtyDescription
    for k, v in ipairs(specials) do

        local imageSpecialty = ccui.ImageView:create(specials[1].icon .. ".jpg", 1)
        imageSpecialty:setScale(0.6)
        imageSpecialty:setPosition(cc.p(58, 230 - 73 * (k - 1)))
        label:addChild(imageSpecialty)

        local imageSpecialtyFrame = ccui.ImageView:create("specialty_bg_hero.png", 1)
        imageSpecialtyFrame:setScale(1.54)
        imageSpecialtyFrame:setPosition(cc.p(imageSpecialty:getContentSize().width / 2, imageSpecialty:getContentSize().height / 2))
        imageSpecialty:addChild(imageSpecialtyFrame)

        local imageStar = ccui.ImageView:create(string.format("globalImageUI_heroStar%d.png", k), 1)
        imageStar:setScale(1.4)
        imageStar:setPosition(cc.p(imageSpecialty:getContentSize().width / 2, 10))
        imageSpecialty:addChild(imageStar)

        local descColor = k >= nextStar and "[color=787878, fontsize=20]" or "[color=3D1F00, fontsize=20]" 
        local desc = descColor .. lang(v.des) .. "[-]"
        if k >= nextStar then
            local lock = ccui.ImageView:create("globalImageUI5_treasureLock.png", 1)
            lock:setScale(1.54)
            lock:setPosition(cc.p(imageSpecialty:getContentSize().width / 2, imageSpecialty:getContentSize().height / 2))
            imageSpecialty:addChild(lock,99)
            imageSpecialty:setBrightness(-50)
        end
        --[[
        local desc = descColor .. "wrong description[-]"
        if 1 == v.tag then
            desc = descColor .. lang(v.des) .. "[-]"
        elseif 2 == v.tag then
            desc = descColor .. lang(self._heroData.heroname) .. lang("HEROSPECIALDES_" .. self._heroData.special) .. "获得额外技能" .. "[-]"
        else
            desc = descColor .. lang(self._heroData.heroname) .. "获得额外技能" .. "[-]"
        end
        ]]
        local richText = label:getChildByName("descRichText" .. k)
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, 245, 60)
        richText:formatText()
        richText:enablePrinter(true)
        --richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / k)
        richText:setPosition(label:getContentSize().width / 1.58, 230 - 73 * (k - 1))
        richText:setName("descRichText" .. k)
        label:addChild(richText)
    end
    ]=]
    --[[
    -- version 5.0
    local star = self._heroData.star
    local specials = self._heroData.specialtyInfo.specials
    local nextUnlockSpecialIndex = self._heroData.specialtyInfo.nextUnlockSpecialIndex
    local nextStar = star + 1
    self._specialtyIcon:loadTexture(IconUtils.iconPath .. specials[1].icon .. ".jpg", 1)
    for i = 1, star do
        if 1 == i then
            self._specialtyStar[i]:setPositionX(25 + (3 - star) * 7)
        else
            self._specialtyStar[i]:setPositionX(self._specialtyStar[i-1]:getPositionX() + self._specialtyStar[i]:getContentSize().width / 2 + 5)
        end
        self._specialtyStar[i]:setVisible(true)
    end
    self._specialtyName:setString(lang("HEROSPECIAL_" .. self._heroData.special))

    local desc = "[color=664b2f]" .. lang("HEROSPECIALDES_" .. self._heroData.special) .. "[-]"
    local label = self._specialtyDescription
    local richText = label:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, 280, 40)
    richText:formatText()
    richText:enablePrinter(true)
    --richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / k)
    richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
    richText:setName("descRichText")
    label:addChild(richText)
    ]]
    --[=[
    -- version 4.0
    local star = self._heroData.star
    local specials = self._heroData.specialtyInfo.specials
    local nextUnlockSpecialIndex = self._heroData.specialtyInfo.nextUnlockSpecialIndex
    local nextStar = star + 1
    self._specialtyIcon:loadTexture(IconUtils.iconPath .. specials[1].icon .. ".jpg")
    self._specialtyName:setString(lang("HEROSPECIAL_" .. self._heroData.special))
    local label = self._specialtyDescription
    for k, v in ipairs(specials) do
        local imageStar = ccui.ImageView:create("specialty_star_" .. k .. "_hero.png", 1)
        imageStar:setPosition(cc.p(18, 168 - 48 * (k - 1)))
        label:addChild(imageStar)

        local descColor = k >= nextStar and "[color=808080, fontsize=16]" or "[color=664b2f, fontsize=16]" 
        local desc = descColor .. "wrong description[-]"
        if 1 == v.tag then
            desc = descColor .. lang(v.des) .. "[-]"
        elseif 2 == v.tag then
            desc = descColor .. lang(self._heroData.heroname) .. lang("HEROSPECIALDES_" .. self._heroData.special) .. "获得额外技能" .. "[-]"
        else
            desc = descColor .. lang(self._heroData.heroname) .. "获得额外技能" .. "[-]"
        end
        local richText = label:getChildByName("descRichText" .. k)
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, 280, 40)
        richText:formatText()
        richText:enablePrinter(true)
        --richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / k)
        richText:setPosition(label:getContentSize().width / 2, 168 - 45 * (k - 1))
        richText:setName("descRichText" .. k)
        label:addChild(richText)

        if k >= 2 then
            local labelName = label:getChildByName("labelName" .. k)
            if labelName then
                labelName:removeFromParentAndCleanup()
            end
            labelName = ccui.Text:create(lang(v.name), UIUtils.ttfName, 16)
            labelName:setAnchorPoint(cc.p(0, 0.5))
            labelName:setColor(cc.c3b(118, 238, 0))
            labelName:enableOutline(cc.c4b(0, 78, 0, 255), 2)
            labelName:setPosition(cc.p(30, 148 - 45 * (k - 1)))
            richText:setName("labelName" .. k)
            label:addChild(labelName)

            local labelUnlock = label:getChildByName("labelUnlock" .. k)
            if labelUnlock then
                labelUnlock:removeFromParentAndCleanup()
            end

            if k >= nextStar then
                labelUnlock = ccui.Text:create("（" .. lang(string.format("HEROSTAR_%02d", k)) .. "解锁）", UIUtils.ttfName, 16)
                labelUnlock:setAnchorPoint(cc.p(0, 0.5))
                labelUnlock:setColor(cc.c3b(255, 46, 49))
                labelUnlock:enableOutline(cc.c4b(81, 19, 0, 255), 2)
                labelUnlock:setPosition(cc.p(120, 148 - 45 * (k - 1)))
                labelUnlock:setName("labelUnlock" .. k)
                label:addChild(labelUnlock)
            end
        end

    end
    ]=]
    --[==[
    local label = self._specialtyDescription
    for k, v in ipairs(self._heroData.specialtyInfo.specials) do
        local desc = "[color=664b2f, fontsize=18]" .. lang(v.des) .. "[-]"
        local richText = label:getChildByName("descRichText" .. k)
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, 280, 40)
        richText:formatText()
        richText:enablePrinter(true)
        --richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / k)
        richText:setPosition(label:getContentSize().width / 2, 170 - 50 * (k - 1))
        richText:setName("descRichText" .. k)
        label:addChild(richText)
        --[=[
        local label = self._specialtyDescription
        for k, v in ipairs(self._heroData.specialtyInfo.specials) do
            --[[
            local desc = lang(self._heroData.specialtyInfo.specials[i].des)
            local text = label:getChildByName("descRichText" .. i)
            if text then
                text:removeFromParentAndCleanup()
            end
            text = ccui.Text:create(desc, UIUtils.ttfName, 18)
            text:setContentSize(cc.size(100, 50))
            text:setColor(cc.c3b(102, 75, 47))
            text:setPosition(label:getContentSize().width / 2, label:getContentSize().height / i)
            text:setName("descRichText" .. i)
            label:addChild(text, 100)
            ]]
            local desc = "[color=664b2f, fontsize=18]wrong description[-]"
            if 1 == v.tag then
                desc = "[color=664b2f, fontsize=18]" .. lang(v.des) .. "[-]"
            elseif 2 == v.tag then
                desc = "[color=664b2f, fontsize=18]" .. lang(self._heroData.heroname) .. lang("HEROSPECIALDES_" .. self._heroData.special) .. "获得额外技能" .. "[-]"
            else
                desc = "[color=664b2f, fontsize=18]" .. lang(self._heroData.heroname) .. "获得额外技能" .. "[-]"
            end
            local richText = label:getChildByName("descRichText" .. k)
            if richText then
                richText:removeFromParentAndCleanup()
            end
            richText = RichTextFactory:create(desc, 280, 40)
            richText:formatText()
            richText:enablePrinter(true)
            --richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height / k)
            richText:setPosition(label:getContentSize().width / 2, 170 - 50 * (k - 1))
            richText:setName("descRichText" .. k)
            label:addChild(richText)
        ]=]
    end
    ]==]
    --[[
    -- mastery
    for i=1, 4 do
        local iconGrid = self._masteryUI[i]._icon
        local icon = iconGrid:getChildByTag(self.kHeroMasteryTag)
        if not icon then
            icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = self._heroData["m" .. i], container = { _container = self }, })
            icon:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
            icon:setTag(self.kHeroMasteryTag)
            iconGrid:addChild(icon)
        end 
        icon = iconGrid:getChildByTag(self.kHeroMasteryTag)
        icon:setIconType(FormationIconView.kIconTypeHeroMastery)
        icon:setIconId(self._heroData["m" .. i])
        icon:updateIconInformation()
        local data = tab:HeroMastery(self._heroData["m" .. i])
        local label = self._masteryUI[i]._level
        local desc = lang("HEROMASTERY_LV_" .. data.masterylv)
        local richText = label:getChildByName("descRichText")
        if richText then
            richText:removeFromParentAndCleanup()
        end
        richText = RichTextFactory:create(desc, label:getContentSize().width, label:getContentSize().height)
        richText:formatText()
        richText:enablePrinter(true)
        richText:setPosition(label:getContentSize().width / 2, label:getContentSize().height - richText:getInnerSize().height / 2)
        richText:setName("descRichText")
        label:addChild(richText)
        self._masteryUI[i]._name:setString(lang(data.name))
    end
    ]]
end
--[[
self._attributeValues = BattleUtils.getHeroBaseAttr(tab:Hero(id), level, slevel, star, masterys, nil, nil)

    self.atk = self._attributeValues.atk
    self.def = self._attributeValues.def 
    self.shiQi = self._attributeValues.shiQi
    self.int = self._attributeValues.int
    self.ack = self._attributeValues.ack
    self.ap = self._attributeValues.ap
    self.manaBase = self._attributeValues.manaBase
    self.manaMax = self._attributeValues.manaMax
    self.manaRec = self._attributeValues.manaRec
    self.hurtAp = self._attributeValues.hurtAp
    self.skills = self._attributeValues.skills
    self.attr = self._attributeValues.monsterAttr

    攻击 self._attributeValues.atk 攻击加成百分比
    防御 self._attributeValues.def 生命加成百分比
    智力 self._attributeValues.int 法术伤害self._attributeValues.ap
    知识 self._attributeValues.ack 魔法值上限 self._attributeValues.manaMax

    士气 self._attributeValues.shiQi
    魔法值self._attributeValues.manaBase
]]

function HeroBasicInformationView:updateAttribute()
    --dump(self._heroData, "updateAttribute")
    -- dump(self._attributeValues, "self._attributeValues")
    --[[
    local value = self._attributeValues.atk
    self._labelAtkValue:setString(string.format("%.1f", value))

    value = self._attributeValues.def
    self._labelDefValue:setString(string.format("%.1f", value))

    value = self._attributeValues.int
    self._labelIntValue:setString(string.format("%.1f", value))

    value = self._attributeValues.ack
    self._labelAckValue:setString(string.format("%.1f", value))
    ]]
    --[[
    local heroTableData = tab:Hero(self._heroData.id)
    local value = self._heroData.atk[1] + (self._heroData.star - heroTableData.star) * self._heroData.atk[2]
    local addition = self._attributeValues.atk - value
    self._labelAtkValue:setPositionX(addition <= 0 and 35 or 22)
    self._labelAtkValue:setString(string.format("%d", value))
    self._labelAtkAdditionValue:setVisible(addition > 0)
    self._labelAtkAdditionValue:setPositionX(self._labelAtkValue:getPositionX() + self._labelAtkValue:getContentSize().width / 2)
    --self._labelAtkAdditionValue:setString(string.format("+%.1f", addition))
    self._labelAtkAdditionValue:setString(string.format("+%d", math.ceil(addition)))

    value = self._heroData.def[1] + (self._heroData.star - heroTableData.star) * self._heroData.def[2]
    addition = self._attributeValues.def - value
    self._labelDefValue:setPositionX(addition <= 0 and 35 or 22)
    self._labelDefValue:setString(string.format("%d", value))
    self._labelDefAdditionValue:setVisible(addition > 0)
    self._labelDefAdditionValue:setPositionX(self._labelDefValue:getPositionX() + self._labelDefValue:getContentSize().width / 2)
    --self._labelDefAdditionValue:setString(string.format("+%.1f", addition))
    self._labelDefAdditionValue:setString(string.format("+%d", math.ceil(addition)))

    value = self._heroData.int[1] + (self._heroData.star - heroTableData.star) * self._heroData.int[2]
    addition = self._attributeValues.int - value
    self._labelIntValue:setPositionX(addition <= 0 and 35 or 22)
    self._labelIntValue:setString(string.format("%d", value))
    self._labelIntAdditionValue:setVisible(addition > 0)
    self._labelIntAdditionValue:setPositionX(self._labelIntValue:getPositionX() + self._labelIntValue:getContentSize().width / 2)
    --self._labelIntAdditionValue:setString(string.format("+%.1f", addition))
    self._labelIntAdditionValue:setString(string.format("+%d", math.ceil(addition)))

    value = self._heroData.ack[1] + (self._heroData.star - heroTableData.star) * self._heroData.ack[2]
    addition = self._attributeValues.ack - value
    self._labelAckValue:setPositionX(addition <= 0 and 35 or 22)
    self._labelAckValue:setString(string.format("%d", value))
    self._labelAckAdditionValue:setVisible(addition > 0)
    self._labelAckAdditionValue:setPositionX(self._labelAckValue:getPositionX() + self._labelAckValue:getContentSize().width / 2)
    --self._labelAckAdditionValue:setString(string.format("+%.1f", addition))
    self._labelAckAdditionValue:setString(string.format("+%d", math.ceil(addition)))
    ]]
    --[[
    local icon = self._moraleIcon:getChildByTag(self.kMoraleTag)
    if not icon then
        icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeMorale, iconId = self._heroData.special })
        icon:setPosition(self._moraleIcon:getContentSize().width / 2, self._moraleIcon:getContentSize().height / 2)
        icon:setTag(self.kMoraleTag)
        self._moraleIcon:addChild(icon)
    end 
    icon = self._moraleIcon:getChildByTag(self.kMoraleTag)
    icon:setIconType(FormationIconView.kIconTypeMorale)
    icon:setIconId(self._heroData.special)
    icon:updateIconInformation()

    local icon = self._magicIcon:getChildByTag(self.kMagicTag)
    if not icon then
        icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeMagic, iconId = self._heroData.special })
        icon:setPosition(self._magicIcon:getContentSize().width / 2, self._magicIcon:getContentSize().height / 2)
        icon:setTag(self.kMagicTag)
        self._magicIcon:addChild(icon)
    end 
    icon = self._magicIcon:getChildByTag(self.kMagicTag)
    icon:setIconType(FormationIconView.kIconTypeMagic)
    icon:setIconId(self._heroData.special)
    icon:updateIconInformation()
    ]]
    self._magicValue:setString(self._attributeValues.manaBase)
    self._magicRecoverValue:setString(self._attributeValues.manaRec * 2.0)
    self._damageValue:setString(self:caculateMagicHurt() .. "%")
end

function HeroBasicInformationView:_updateAttribute()
    --dump(self._heroData, "updateAttribute")
    local attributeValue = {
        atk = self._heroData.atk,
        def = self._heroData.def,
        int = self._heroData.int,
        ack = self._heroData.ack,
        morale = self._heroData.morale,
    }

    local extraValue = {

    }
    --dump(attributeValue, "attributeValue1")
    local artifacts = self._modelMgr:getModel("UserModel"):getData().artifacts
    local artiEffect = tab.artiEffect
    --dump(artifacts, "artifacts")
    for i=1, 6 do
        repeat
            local artifact = self._heroData["artifact" .. i]
            if not artifact then break end
            local artifactTableData = tab:Artifact(artifact)
            --dump(artifactTableData, "artifactTableData")
            for k, v in pairs(attributeValue) do
                repeat
                    if not artifactTableData[k] then break end
                    --dump(artifactTableData[k], k)
                    local stage = artifacts[tostring(artifact)].stage or 0
                    attributeValue[k] = attributeValue[k] + (artifactTableData[k][1] + (stage * artifactTableData[k][2]))
                until true
            end
        until true
    end
    --dump(attributeValue, "attributeValue2")
    self._progressBarAtk:setPercent(attributeValue.atk)
    self._labelAtkValue:setString("增加" .. attributeValue.atk .. "%怪兽攻击力")
    self._progressBarDef:setPercent(attributeValue.def)
    self._labelDefValue:setString("增加" .. attributeValue.def .. "%怪兽血量")
    self._progressBarInt:setPercent(attributeValue.int)
    self._labelIntValue:setString("增加" .. attributeValue.int .. "%法术伤害")
    self._progressBarAck:setPercent(attributeValue.ack)
    self._labelAckValue:setString("增加" .. attributeValue.ack .. "点魔法值上限")

    local icon = self._moraleIcon:getChildByTag(self.kMoraleTag)
    if not icon then
        icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeMorale, iconId = self._heroData.special })
        icon:setPosition(self._moraleIcon:getContentSize().width / 2, self._moraleIcon:getContentSize().height / 2)
        icon:setTag(self.kMoraleTag)
        self._moraleIcon:addChild(icon)
    end 
    icon = self._moraleIcon:getChildByTag(self.kMoraleTag)
    icon:setIconType(FormationIconView.kIconTypeMorale)
    icon:setIconId(self._heroData.special)
    icon:updateIconInformation()

    local icon = self._magicIcon:getChildByTag(self.kMagicTag)
    if not icon then
        icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeMagic, iconId = self._heroData.special })
        icon:setPosition(self._magicIcon:getContentSize().width / 2, self._magicIcon:getContentSize().height / 2)
        icon:setTag(self.kMagicTag)
        self._magicIcon:addChild(icon)
    end 
    icon = self._magicIcon:getChildByTag(self.kMagicTag)
    icon:setIconType(FormationIconView.kIconTypeMagic)
    icon:setIconId(self._heroData.special)
    icon:updateIconInformation()

    self._moraleValue:setString(attributeValue.morale)
    self._magicValue:setString(self._heroData.manamax)
end

function HeroBasicInformationView:updateStudyRateEffect(oldheroData,callback)
    audioMgr:playSound("Reflash")
    -- self._upgrade._mc1:retain()
    -- self._upgrade._mc1:removeFromParentAndCleanup()
    -- self._upgrade._mc1:setVisible(true)
    -- self._layerRight3:addChild(self._upgrade._mc1, 100)
    -- self._upgrade._mc1:release()
    -- self._upgrade._mc1:addEndCallback(function()
        -- self._upgrade._mc1:stop()
        -- self._upgrade._mc1:setVisible(false)
    -- end)
    -- self._upgrade._mc1:gotoAndPlay(0)
    -- self._upgrade._mc1:setPosition(cc.p(self._layerRight3:getContentSize().width / 2.5-150, self._layerRight3:getContentSize().height / 2))
    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
        self._container:showTopInfo(false)
    end
    self._viewMgr:showDialog("hero.HeroUpgradeResultView", {oldheroData = oldheroData,heroData = clone(self._heroData),callback=callback}, true)
end

function HeroBasicInformationView:refreshMastery(heroData)
    if not SystemUtils:enableHeroMastery() then
        self._viewMgr:showTip(lang("TIPS_MASTERYREFLASH_1"))
        return 
    end
    if not self._heroRefreshDialog then
        self._heroRefreshDialog = self._viewMgr:showDialog("hero.HeroMasteryRefreshView", {data = self._heroData, container = self}, true)
        return
    end
    local heroRefreshBg = self._heroRefreshDialog:getBg()
    if not heroRefreshBg then return end
    self._heroRefreshDialog:setVisible(true)
    heroRefreshBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.05), cc.ScaleTo:create(0.03, 1.0)))
    self._heroRefreshDialog:onReshow()
end

function HeroBasicInformationView:onMaterialAdditionButtonClicked()
    local star = self._heroData.star
    local cost = {}
    if 0 == star then
        cost = {[1] = self._heroData.unlockcost}
    else
        cost = self._heroData.starcost[star]
    end
    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
        self._container:showTopInfo(false)
    end
    for k, v in pairs(cost) do
        if "tool" == v[1] then
            DialogUtils.showItemApproach(v[2], function()
                if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                    self._container:showTopInfo(true)
                end
                self:onTop()
            end)
            break
        end
    end
end

function HeroBasicInformationView:onHeroFragButtonClicked()

    local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(HeroBasicInformationView.kFragToolId)
    if toolNum <= 0 then
        if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
            self._container:showTopInfo(false)
        end
        DialogUtils.showItemApproach(HeroBasicInformationView.kFragToolId, function()
            if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                self._container:showTopInfo(true)
            end
        end)
        return
    end

    local _, soulNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._heroData.soul)
    local needSoul = self._heroData.starcost[3][1][3]
    if soulNum >= needSoul then
        self._viewMgr:showTip(lang("TIPS_FRAGMENT_FULL"))
        return
    end
    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
        self._container:showTopInfo(false)
    end
    self._viewMgr:showDialog("hero.HeroFragUseView", { heroData = self._heroData, container = self }, true)
    --[[
    local context = {heroId = self._heroData.id}
    self._serverMgr:sendMsg("HeroServer", "upgradeStar", context, true, {}, function(result, success)

        if result["unset"] ~= nil then 
            local removeItems = self._itemModel:handelUnsetItems(result["unset"])
            self._itemModel:delItems(removeItems, true)
        end
        
        if result["d"].items then
            self._itemModel:updateItems(result["d"].items)
            result["d"].items = nil
        end
        self._heroData.star = result["d"]["heros"][tostring(self._heroData.id)].star
        result["d"]["heros"] = nil
        self._userModel:updateUserData(result["d"])
        self:initSpecialtyData()
        self:updateStudyRateEffect()
        self._dirdy = true
        self:updateUI(self._viewType)
    end)
    ]]
end

function HeroBasicInformationView:onHeroUpgradeButtonClicked()

    local ok = true
    local cost = {}
    local star = self._heroData.star
    if 0 == star then
        cost = {[1] = self._heroData.unlockcost}
    else
        cost = self._heroData.starcost[star]
    end
    for k, v in pairs(cost) do
        local have, consume = 0, v[3]
        if "tool" == v[1] then
            local _, toolNum = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
            have = toolNum
            self._upgrade._upgradeValue:setString(string.format("%d/%d", have, consume))
            self._upgrade._proBar:setPercent(have / consume * 100)
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

    if not ok then
        self._viewMgr:showTip(lang("TIPS_HEROUNLOCK_1"))
        return
    end

    local context = {heroId = self._heroData.id}
    local oldheroData = clone(self._heroData)
    self._serverMgr:sendMsg("HeroServer", "upgradeStar", context, true, {}, function(result, success)

        if result["unset"] ~= nil then 
            local removeItems = self._itemModel:handelUnsetItems(result["unset"])
            self._itemModel:delItems(removeItems, true)
        end
        
        if result["d"].items then
            self._itemModel:updateItems(result["d"].items)
            result["d"].items = nil
        end
        local oldScore = self._heroData.score 
        local newScore = result["d"]["heros"][tostring(self._heroData.id)].score

        --dump(result["d"]["heros"], "heroData", 5)

        self._container:upgradeHero(result["d"]["heros"])

        result["d"]["heros"] = nil
        self._userModel:updateUserData(result["d"])
        self:initSpecialtyData()
        self:updateStudyRateEffect(oldheroData,function( )
            self:popScoreChangeAnim( oldScore,newScore )
            if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                self._container:showTopInfo(true)
            end
        end)
        self._dirdy = true
        self._container:updateButtonStatus()
        self._container:updateAttributes(true)
        self:updateUI(self._viewType)
        DialogUtils.showZuHe(self._heroData.id)
    end)
end

function HeroBasicInformationView:onRefreshViewClose()
    --[[
    self._dirdy = true
    self._container:setMaskLayerOpacity(self._container:getMaskOpacity())
    self._container:_setMaskLayer(self._container)
    self:updateUI(self._viewType)
    ]]
end

function HeroBasicInformationView:onFragViewClose()
    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
        self._container:showTopInfo(true)
    end
    self._dirdy = true
    self:updateUI(self._viewType)
end

function HeroBasicInformationView:onHeroMasteryMultiRefreshViewClose()
    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
        self._container:showTopInfo(true)
    end
    for i=1, 4 do
        self._currentMastery[i]._value = self._heroData["m" .. i]
        self._currentMastery[i]._lock = self._heroData["masteryLock" .. i]
        self._newestMastery[i]._value = self._currentMastery[i]._value
        self._newestMastery[i]._lock = self._currentMastery[i]._lock
    end
    self._dirdy = true
    self:updateUI(self._viewType)
end

function HeroBasicInformationView:getLockedCount()
    local lockedCount = 0
    for i=1, 4 do
        if self._currentMastery[i]._lock then
            lockedCount = lockedCount + 1
        end
    end
    return lockedCount
end

function HeroBasicInformationView:updateLockImage(index)
    local lock = self._currentMastery[index]._lock
    if self._is_refresh_btn_clicked then
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroLockDisabled, 1)
    elseif lock then
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroLocked, 1)
    else
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroUnlocked, 1)
    end
    
end

function HeroBasicInformationView:updateLockRelative(index)
    self:updateLockImage(index)
    local lock = self._currentMastery[index]._lock
    local color = cc.c3b(255, 255, 255)
    if lock then
        color = cc.c3b(160, 151, 151)
    end

    local dataCurrent = tab:HeroMastery(self._currentMastery[index]._value)
    local currentLv = dataCurrent.masterylv
    local color = nil
    local outlineColor = nil
    local levelName = nil
    if lock then
        color = cc.c3b(160, 151, 151)
        if 1 == currentLv then
            levelName = "初级"
            --outlineColor = cc.c4b(0, 78, 0, 255)
        elseif 2 == currentLv then
            levelName = "中级"
            --outlineColor = cc.c4b(0, 44, 118, 255)
        elseif 3 == currentLv then
            levelName = "高级"
            --outlineColor = cc.c4b(71, 0, 140, 255)
        end
    else
        if 1 == currentLv then
            color = cc.c3b(118, 238, 0)
            outlineColor = cc.c4b(0, 78, 0, 255)
            levelName = "初级"
        elseif 2 == currentLv then
            color = cc.c3b(72, 210, 255)
            outlineColor = cc.c4b(0, 44, 118, 255)
            levelName = "中级"
        elseif 3 == currentLv then
            color = cc.c3b(239, 109, 254)
            outlineColor = cc.c4b(71, 0, 140, 255)
            levelName = "高级"
        end
    end
    if levelName then
        self._currentMastery[index]._labelMasteryLevel:setString(levelName)    
    end
    self._currentMastery[index]._labelMasteryLevel:setColor(color)
    if outlineColor then
        self._currentMastery[index]._labelMasteryLevel:enableOutline(outlineColor, 1)
    else
        self._currentMastery[index]._labelMasteryLevel:disableEffect()
    end
    local dataNewest = tab:HeroMastery(self._newestMastery[index]._value)
    local newestLv = dataNewest.masterylv
    if newestLv ~= currentLv then
        local color = nil
        local outlineColor = nil
        local levelName = nil
        if lock then
            color = cc.c3b(160, 151, 151)
            if 1 == newestLv then
                levelName = "初级"
                --outlineColor = cc.c4b(0, 78, 0, 255)
            elseif 2 == newestLv then
                levelName = "中级"
                --outlineColor = cc.c4b(0, 44, 118, 255)
            elseif 3 == newestLv then
                levelName = "高级"
                --outlineColor = cc.c4b(71, 0, 140, 255)
            end
        else
            if 1 == newestLv then
                color = cc.c3b(118, 238, 0)
                outlineColor = cc.c4b(0, 78, 0, 255)
                levelName = "初级"
            elseif 2 == newestLv then
                color = cc.c3b(72, 210, 255)
                outlineColor = cc.c4b(0, 44, 118, 255)
                levelName = "中级"
            elseif 3 == newestLv then
                color = cc.c3b(239, 109, 254)
                outlineColor = cc.c4b(71, 0, 140, 255)
                levelName = "高级"
            end
        end
        self._newestMastery[index]._labelMasteryLevel:setColor(color)
        if outlineColor then
            self._newestMastery[index]._labelMasteryLevel:enableOutline(outlineColor, 1)
        else
            self._newestMastery[index]._labelMasteryLevel:disableEffect()
        end
        if levelName then
            self._newestMastery[index]._labelMasteryLevel:setString(levelName)    
        end
    else
        self._newestMastery[index]._labelMasteryLevel:setColor(color)
        if outlineColor then
            self._newestMastery[index]._labelMasteryLevel:enableOutline(outlineColor, 1)
        else
            self._newestMastery[index]._labelMasteryLevel:disableEffect()
        end
        if levelName then
            self._newestMastery[index]._labelMasteryLevel:setString(levelName)    
        end
    end
    --[[
    local icon = self._currentMastery[index]._image:getChildByTag(self.kCurrentMasteryIconTag)
    if icon then
        --self:markGray(icon, lock)
        icon:setSaturation(lock and -100 or 0)
    end

    local icon = self._newestMastery[index]._image:getChildByTag(self.kNewestMasteryIconTag)
    if icon then
        --self:markGray(icon, lock)
        icon:setSaturation(lock and -100 or 0)
    end
    ]]
    local recommandMasteryData = self._heroData.recmastery
    local isNewestRecommand = function(index)
        local masteryCurrentData = tab:HeroMastery(self._currentMastery[index]._value)
        local masteryNewestData = tab:HeroMastery(self._newestMastery[index]._value)
        for i = 1, #recommandMasteryData do
            if recommandMasteryData[i] == masteryNewestData.baseid and masteryNewestData.masterylv >= 2 and not (masteryCurrentData.baseid == masteryNewestData.baseid and masteryCurrentData.masterylv > masteryNewestData.masterylv) then
                return true
            end
        end
        return false
    end
    local isMasteryGlobal = function(masteryId)
        local masteryData = tab:HeroMastery(masteryId)
        return masteryData and 1 == masteryData.global
    end
    self._newestMastery[index]._image_no_refresh:setVisible(not (self._is_refresh_btn_clicked or lock))
    --self._newestMastery[index]._image_recommand:setVisible(not self._newestMastery[index]._image_no_refresh:isVisible() and recommandMasteryData and isNewestRecommand(index))
    local isRecommend = recommandMasteryData and isNewestRecommand(index)
    local isGlobal = isMasteryGlobal(dataNewest.id)
    if not self._newestMastery[index]._image_no_refresh:isVisible() then
        if self._isHeroLoaded then
            if isRecommend then
                self._newestMastery[index]._image_recommand:setVisible(true)
                self._newestMastery[index]._image_recommand:loadTexture("mastery_recommand_hero.png", 1)
            elseif isGlobal then
                self._newestMastery[index]._image_recommand:setVisible(true)
                self._newestMastery[index]._image_recommand:loadTexture("mastery_global_hero.png", 1)
            else
                self._newestMastery[index]._image_recommand:setVisible(false)
            end
        else
            if isGlobal then
                self._newestMastery[index]._image_recommand:setVisible(true)
                self._newestMastery[index]._image_recommand:loadTexture("mastery_global_hero.png", 1)
            elseif isRecommend then
                self._newestMastery[index]._image_recommand:setVisible(true)
                self._newestMastery[index]._image_recommand:loadTexture("mastery_recommand_hero.png", 1)
            else
                self._newestMastery[index]._image_recommand:setVisible(false)
            end
        end
    else
        self._newestMastery[index]._image_recommand:setVisible(false)
    end

    local icon = self._newestMastery[index]._image:getChildByTag(self.kNewestMasteryIconTag)
    icon:enableTouch(not self._newestMastery[index]._image_no_refresh:isVisible())
end

function HeroBasicInformationView:updateButtonStatus(isRefresh)
    self._is_refresh_btn_clicked = isRefresh
    --[[
    for i=1, 4 do
        self._currentMastery[i]._imageLockBg:setVisible(not isRefresh)
        self._newestMastery[i]._imageLockBg:setVisible(not isRefresh)
    end
    ]]
    for i=1, 4 do
        self:updateLockImage(i) 
    end

    self._btn_refresh:setVisible(not isRefresh)
    self._btn_multiple_refresh:setVisible(not isRefresh)
    self._layer_refresh_consume:setVisible(not isRefresh)
    --self._imageConsumeBg:setVisible(not isRefresh)
    self._btn_change:setVisible(isRefresh)
    self._btn_cancel:setVisible(isRefresh)
end

function HeroBasicInformationView:visableLockImage()
    local lockedCount = self:getLockedCount()
    if lockedCount >= 3 then
        for i = 1, 4 do
            if not self._currentMastery[i]._lock then
                self._currentMastery[i]._imageLock:setVisible(false)
            end
        end
    else
        for i = 1, 4 do
            self._currentMastery[i]._imageLock:setVisible(true)
        end
    end
end

function HeroBasicInformationView:onLockButtonClicked(index)
    if self._is_refresh_btn_clicked then return end

    if not self._currentMastery[index]._lock then
        local vipLevel = self._vipModel:getData().level
        if self:getLockedCount() >= tab.vip[vipLevel].refreshLock then
            self._viewMgr:showTip(lang("TiPS_VIP_MASTERY_" .. (tab.vip[vipLevel].refreshLock + 1)))
            return
        end
    end
    
    self._currentMastery[index]._lock = not self._currentMastery[index]._lock
    self._newestMastery[index]._lock = self._currentMastery[index]._lock
    self._heroData["masteryLock" .. index] = self._currentMastery[index]._lock

    local lockedCount = self:getLockedCount()
    self:visableLockImage()
    local consume = self._refreshConsume[lockedCount + 1][1] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22))
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    if totalGem < consume then
        self._labelConsumeValue:setColor(cc.c3b(255, 0, 0))
        --self._labelConsumeValue:enableOutline(cc.c4b(81, 19, 0, 255), 1)
    else
        self._labelConsumeValue:setColor(cc.c3b(130, 85, 40))
        --self._labelConsumeValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    end
    self._labelConsumeValue:setString(consume)

    local consumeGold = self._refreshConsume[lockedCount + 1][2] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22))
    local totalGold = self._modelMgr:getModel("UserModel"):getData().gold
    if totalGold < consumeGold then
        self._labelConsumeGoldValue:setColor(cc.c3b(255, 0, 0))
        --self._labelConsumeGoldValue:enableOutline(cc.c4b(81, 19, 0, 255), 1)
    else
        self._labelConsumeGoldValue:setColor(cc.c3b(130, 85, 40))
        --self._labelConsumeGoldValue:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    end
    self._labelConsumeGoldValue:setString(consumeGold)

    self:updateLockRelative(index)
end

function HeroBasicInformationView:onButtonRefreshClicked()

    local lockedCount = self:getLockedCount()
    local consume = self._refreshConsume[lockedCount + 1][1] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22))
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    local consumeGold = self._refreshConsume[lockedCount + 1][2] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22))
    local totalGold = self._userModel:getData().gold
    --local playerDayInfoData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    --local freeTimes = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_12) - playerDayInfoData.day4
    local _, scrollNum = self._itemModel:getItemsById(3015)
    --local firstFreeTimes = tonumber(self._userModel:getPlayerStatis().snum20)
    local firstFreeTimes = self._modelMgr:getModel("PlayerTodayModel"):getData().day4
    --if 1 == firstFreeTimes and freeTimes <= 0 and (not self._isScrollSelected or scrollNum <= 0) and (consume > totalGem or consumeGold > totalGold) then
    if 1 == firstFreeTimes and (not self._isScrollSelected or scrollNum <= 0) and (consume > totalGem or consumeGold > totalGold) then
        if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
            self._container:showTopInfo(false)
        end

        if consume > totalGem then
            DialogUtils.showNeedCharge({callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0, callback = function()
                    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                        self._container:showTopInfo(true)
                    end
                    self:onTop()
                end})
            end})
        elseif consumeGold > totalGold then
            DialogUtils.showBuyRes({goalType="gold", callback = function()
                if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                    self._container:showTopInfo(true)
                end
                self:onTop()
            end})
        end
        return 
    end

    self._btn_refresh:setEnabled(false)
    self._btn_refresh:setBright(false)

    local context = {heroId = self._heroData.id, args = {locks = {}, reduceType = (self._isScrollSelected and scrollNum > 0) and 1 or 0, refreshNum = 1}}
    for i=1, 4 do
        if self._currentMastery[i]._lock then
            context.args.locks[#context.args.locks+1] = i
        else
            self._newestMastery[i]._masteryMC:setVisible(true)
            self._newestMastery[i]._masteryMC:addEndCallback(function()
                self._newestMastery[i]._masteryMC:stop()
                self._newestMastery[i]._masteryMC:setVisible(false)
            end)
            self._newestMastery[i]._masteryMC:gotoAndPlay(0)
        end
    end

    if self._is_no_refresh then
        self._is_no_refresh = false
        --[[
        for i=1, 4 do
            self._newestMastery[i]._image_no_refresh:setVisible(self._is_no_refresh)
        end
        ]]
    end

    context["args"] = json.encode(context["args"])
    ScheduleMgr:delayCall(400, self, function()
        self._serverMgr:sendMsg("HeroServer", "refreshMastery", context, true, {}, function(result) 
            -- dump(result, "refresh data", 5)
            self:updateButtonStatus(true)

            self._btn_refresh:setEnabled(true)
            self._btn_refresh:setBright(true)

            for i=1, 4 do
                if not self._currentMastery[i]._lock then
                    --self._newestMastery[i]._value = result["d"]["heros"][tostring(self._heroData.id)]["new" .. i]
                    self._newestMastery[i]._value = result["list"][1][tostring(i)]
                end
            end

            result["d"]["heros"] = nil

            if result["unset"] ~= nil then 
                local removeItems = self._itemModel:handelUnsetItems(result["unset"])
                self._itemModel:delItems(removeItems, true)
            end
            
            if result["d"].items then
                self._itemModel:updateItems(result["d"].items)
                result["d"].items = nil
            end

            self._modelMgr:getModel("UserModel"):updateUserData(result["d"])
            self._modelMgr:getModel("HeroModel"):saveLocks(self._heroData)
            if result.d and result.d.dayInfo and result.d.dayInfo.day4 then
                self._modelMgr:getModel("PlayerTodayModel"):setDayInfo(4, result.d.dayInfo.day4)
            end

            self._container:updateButtonStatus()
            self._dirdy = true
            self:updateMastery()
        end)
    end)
end

function HeroBasicInformationView:onButtonChangeClicked()
    self._btn_change:setEnabled(false)
    self._btn_change:setBright(false)
    self._btn_cancel:setEnabled(false)
    self._btn_cancel:setBright(false)
    -- print("onButtonChangeClicked")
    for i=1, 4 do
        if not self._heroData["masteryLock" .. i] then
            self._currentMastery[i]._value = self._newestMastery[i]._value
            self._heroData["m" .. i] = self._currentMastery[i]._value
        end
    end

    for i=1, 4 do
        if not self._heroData["masteryLock" .. i] then
            local dataNewest = tab:HeroMastery(self._newestMastery[i]._value)
            local icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataNewest.id, container = { _container = self } })
            icon:setScaleAnim(false)
            icon:enableTouch(false)
            --icon:setPosition(self._newestMastery[i]._image:getPositionX() + self._newestMastery[i]._image:getContentSize().width / 2, self._newestMastery[i]._image:getPositionY() + self._newestMastery[i]._image:getContentSize().height / 2)
            local position1 = cc.p(self._newestMastery[i]._image:getPositionX() + self._newestMastery[i]._image:getContentSize().width / 2, self._newestMastery[i]._image:getPositionY() + self._newestMastery[i]._image:getContentSize().height / 2)
            position1 = self._newestMastery[i]._image:getParent():convertToWorldSpace(position1)
            position1 = self._layerMasteryRefresh:convertToNodeSpace(position1)
            --icon:setPosition(self._newestMastery[i]._image:getContentSize().width / 2, self._newestMastery[i]._image:getContentSize().height / 2)
            icon:setPosition(position1)
            local position2 = cc.p(self._currentMastery[i]._image:getPositionX() + self._currentMastery[i]._image:getContentSize().width / 2, self._currentMastery[i]._image:getPositionY() + self._currentMastery[i]._image:getContentSize().height / 2)
            position2 = self._currentMastery[i]._image:getParent():convertToWorldSpace(position2)
            position2 = self._layerMasteryRefresh:convertToNodeSpace(position2)
            self._layerMasteryRefresh:addChild(icon, 1000)
            icon:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.1), 2),
                cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(position2)), 2),
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.2), 2),
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.0), 2),
                cc.CallFunc:create(function()
                    if not self._currentMastery[i]._masteryMC1 then return end
                    --self._currentMastery[i]._masteryMC:setVisible(true)
                    self._currentMastery[i]._masteryMC1:setVisible(true)
                    self._currentMastery[i]._masteryMC1:addEndCallback(function()
                        --self._currentMastery[i]._masteryMC:stop()
                        self._currentMastery[i]._masteryMC1:stop()
                        --self._currentMastery[i]._masteryMC:setVisible(false)
                        self._currentMastery[i]._masteryMC1:setVisible(false)
                    end)
                    --self._currentMastery[i]._masteryMC:gotoAndPlay(0)
                    self._currentMastery[i]._masteryMC1:gotoAndPlay(0)
                    icon:removeFromParentAndCleanup(true)
            end)))
        end
    end

    local oldScore = self._heroData.score  -- addBy guojun 弹战斗力动画
    -- dump(self._heroData,"herodata ,,,,before....",10)
    self._modelMgr:getModel("HeroModel"):saveMastery(self._heroData, 1, function(success)
        self:updateButtonStatus(false)
        self._btn_change:setEnabled(true)
        self._btn_change:setBright(true)
        self._btn_cancel:setEnabled(true)
        self._btn_cancel:setBright(true)
        self._container:updateAttributes(true)
        self:updateMastery()
        local newScore = self._heroData.score -- addBy guojun 弹战斗力动画
        -- print("newScore,oldScore",newScore,oldScore)
        self:popScoreChangeAnim( oldScore,newScore ) -- addBy guojun 弹战斗力动画
    end)
end

function HeroBasicInformationView:onButtonCancelClicked()
    local doCancel = function()
        self:updateButtonStatus(false)
        print("onButtonCancelClicked")
        for i=1, 4 do
            self._newestMastery[i]._value = self._currentMastery[i]._value
        end
        self:updateMastery()
    end
    local found = false
    for i = 1, 4 do
        if not self._currentMastery[i]._lock then
            local masteryData = tab:HeroMastery(self._newestMastery[i]._value)
            if masteryData.masterylv >= 3 then
                found = true
                break
            end
        end
    end

    if found then
        self._viewMgr:showSelectDialog(lang("TIPS_MASTERYREFLASH_2"), "", function()
            doCancel()
        end, "")
    else
        doCancel()
    end
end

function HeroBasicInformationView:onButtonMultipleRefreshClicked()
    if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
        self._container:showTopInfo(false)
    end
    self._viewMgr:showDialog("hero.HeroMasteryMultiRefreshView", {container = self, heroData = self._heroData}, true)
end

-- 战斗力变化动画
function HeroBasicInformationView:popScoreChangeAnim( old,new )
    -- 用于弹出战斗力变化动画的回调
    if not old or not new or old >= new then return end
    --local formationModel = self._modelMgr:getModel("FormationModel")
    --local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCommon)
    --if formationData.heroId == self._heroData.id then
    local layer = self:getUI("bg.layer")
    if layer then
        local x = layer:getContentSize().width*0.5
        local y = layer:getContentSize().height - 70
        TeamUtils:setFightAnim(layer, {oldFight = old, 
            newFight = new, x = x - 100, y = y})
    end
    --end
end

--[[
function HeroBasicInformationView:onMasteryClicked(force)
    if not force and self._tabType == self.kMasteryTab then return end
    self._tabType = self.kMasteryTab
    self._layerMastery:setVisible(true)
    self._layerAttribute:setVisible(false)
    
end
]]

--[[
function HeroBasicInformationView:onAttributeClicked(force)
    if not force and self._tabType == self.kAttributeTab then return end
    self._tabType = self.kAttributeTab
    self._layerMastery:setVisible(false)
    self._layerAttribute:setVisible(true)
end
]]
return HeroBasicInformationView
