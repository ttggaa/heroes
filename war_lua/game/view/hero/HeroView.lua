--[[
    Filename:    HeroView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-07-09 10:19:26
    Description: File description
--]]

local FormationIconView = require("game.view.formation.FormationIconView")
local HeroSelectView = require("game.view.hero.HeroSelectView")
local HeroDetailsView = require("game.view.hero.HeroDetailsView")
local HeroSkillInformationView = require("game.view.hero.HeroSkillInformationView")
local HeroSpine = require("game.view.hero.HeroSpine")

local HeroView = class("HeroView", BaseView)

HeroView.kHeroTag = 1000
HeroView.kHeroInformationTag = 2000
HeroView.kHeroEquipmentInformationTag = 3000
HeroView.kHeroSkillIconTag = 4000
HeroView.kHeroTopAttribute = 5000

HeroView.kNormalZOrder = 500
HeroView.kLessNormalZOrder = HeroView.kNormalZOrder - 1
HeroView.kAboveNormalZOrder = HeroView.kNormalZOrder + 1
HeroView.kHighestZOrder = HeroView.kAboveNormalZOrder + 1

HeroView.kAttributeStep = 60

HeroView.HERO_RACE_TYPE = {
    RACE_1 = 1, -- 城堡
    RACE_2 = 2, -- 壁垒
    RACE_3 = 4, -- 据点
    RACE_4 = 3, -- 墓园
    RACE_5 = 5, -- 地狱 
    RACE_6 = 6, -- 塔楼 
    RACE_7 = 0, -- 全部
    RACE_8 = 9, -- 元素 
    RACE_9 = 7, -- 地下城
    RACE_10 = 8, -- 要塞
    RACE_11 = 10, -- 海盗
}

function HeroView:ctor(params)
    HeroView.super.ctor(self)
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self.fixMaxWidth = 1136
    self._teamType = 7
end

function HeroView:getAsyncRes()
    return 
    {
        {"asset/ui/hero1.plist", "asset/ui/hero1.png"},
        {"asset/ui/hero.plist", "asset/ui/hero.png"},
    }
end

function HeroView:disableTextEffect(element)
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

function HeroView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end

--[[
function HeroView:setNavigation( )
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true})
end
]]
function HeroView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("hero.HeroView")
        end
    end)


    self._viewMgr:enableScreenWidthBar()

    if ADOPT_IPHONEX and not self.isPopView and not self.dontAdoptIphoneX then
        if self.fixMaxWidth then
            self._widget:setContentSize((MAX_SCREEN_WIDTH >= self.fixMaxWidth) and self.fixMaxWidth or MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        else
            self._widget:setContentSize(MAX_SCREEN_WIDTH - 120, MAX_SCREEN_HEIGHT)
            self._widget:setPosition(self._widget:getPositionX()+60, self._widget:getPositionY())
        end
    end

    self:disableTextEffect()
    self._bg = self:getUI("bg")
    self._btn_return = self:getUI("btn_return")
    self._layer = self:getUI("bg.layer")
    self._hero_description_bg = self:getUI("bg.layer.hero_description_bg")
    --[[
    self._specialName = self:getUI("bg.layer.hero_description_bg.label_specialty_name")
    self._specialName:setFontName(UIUtils.ttfName)
    self._attributeName = self:getUI("bg.layer.hero_description_bg.label_attribute")
    self._attributeName:setFontName(UIUtils.ttfName)
    ]]
    self._image_hero_specialty_touch = self:getUI("bg.layer.hero_description_bg.image_hero_specialty_touch")
    self._image_hero_specialty_touch:setScaleAnim(true)
    self._image_hero_specialty = self:getUI("bg.layer.hero_description_bg.image_hero_specialty_touch.image_hero_specialty")
    self._label_hero_description = self:getUI("bg.layer.hero_description_bg.label_hero_description")
    self._label_not_open = self:getUI("bg.layer.hero_description_bg.label_not_open")
    self._label_not_open:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._btn_check = self:getUI("bg.layer.hero_description_bg.btn_check")
    self._btn_unlock = self:getUI("bg.layer.hero_description_bg.btn_unlock")
    self._layer_unlock = self:getUI("bg.layer.hero_description_bg.layer_unlock")
    self._label_unlock_cost = self:getUI("bg.layer.hero_description_bg.layer_unlock.label_unlock_cost")
    self._label_unlock_cost:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._layer_unlock = self:getUI("bg.layer.hero_description_bg.btn_unlock.layer_unlock")
    self._btn_memoirist = self:getUI("bg.layer.hero_description_bg.btn_memoirist")
    self._btn_change_skin = self:getUI("bg.layer.hero_description_bg.btn_change_skin")
    self._appraise = self:getUI("bg.layer.hero_description_bg.appraise")
--    UIUtils:addFuncBtnName(self._appraise,"英雄评价",nil,true)
    self._appraise:setVisible(false)
    
    self._labelAddtionAttribute = self:getUI("bg.layer.hero_description_bg.label_addtion_attribute")
    self._labelAddtionAttribute:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._imageAttr1 = self:getUI("bg.layer.hero_description_bg.image_add_att_1")
    self._imageAttr1:setScale(0.8)
    self._labelAttr1 = self:getUI("bg.layer.hero_description_bg.label_add_att_1")
    self._labelAttr1:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._imageAttr2 = self:getUI("bg.layer.hero_description_bg.image_add_att_2")
    self._imageAttr2:setScale(0.8)
    self._labelAttr2 = self:getUI("bg.layer.hero_description_bg.label_add_att_2")
    self._labelAttr2:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --[[
    self._progressBarDurationTime = 0.3
    self._progressBar = {}
    self._progressBar._atk = self:getUI("bg.layer.hero_description_bg.label_atk.image_progress_bg.progress_bar")
    self._progressBar._atkValue = self:getUI("bg.layer.hero_description_bg.label_atk.label_atk_value")
    self._progressBar._atkValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._progressBar._def = self:getUI("bg.layer.hero_description_bg.label_def.image_progress_bg.progress_bar")
    self._progressBar._defValue = self:getUI("bg.layer.hero_description_bg.label_def.label_def_value")
    self._progressBar._defValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._progressBar._int = self:getUI("bg.layer.hero_description_bg.label_int.image_progress_bg.progress_bar")
    self._progressBar._intValue = self:getUI("bg.layer.hero_description_bg.label_int.label_int_value")
    self._progressBar._intValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._progressBar._ack = self:getUI("bg.layer.hero_description_bg.label_ack.image_progress_bg.progress_bar")
    self._progressBar._ackValue = self:getUI("bg.layer.hero_description_bg.label_ack.label_ack_value")
    self._progressBar._ackValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local word = self:getUI("bg.layer.hero_description_bg.label_atk")
    word:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    word = self:getUI("bg.layer.hero_description_bg.label_def")
    word:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    word = self:getUI("bg.layer.hero_description_bg.label_int")
    word:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    word = self:getUI("bg.layer.hero_description_bg.label_ack")
    word:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    ]]
    --self._panel_star_bg = self:getUI("bg.layer.hero_description_bg.panel_star_bg")

    self._skillIcon = {}
    for i=1, HeroSkillInformationView.kSkillCount do
        self._skillIcon[i] = self:getUI("bg.layer.hero_description_bg.layer_hero_skill.layer_skill_icon_" .. i)
        local iconBg = self._skillIcon[i]:getChildByFullName("skill_icon_bg")
        iconBg:setScaleAnim(true)
    end

    self._slotIcon =  self:getUI("bg.layer.hero_description_bg.layer_hero_skill.layer_skill_icon_5")
    local iconBg = self._slotIcon:getChildByFullName("skill_icon_bg")
    iconBg:setScaleAnim(true)
    --[[
    -- version 3.0
    self._btn_unlock = self:getUI("bg.layer.hero_description_bg.btn_unlock")
    self._image_unlock_gold = self:getUI("bg.layer.hero_description_bg.image_unlock_gold")
    self._label_unlock_gold_value = self:getUI("bg.layer.hero_description_bg.image_unlock_gold.label_unlock_gold_value")
    self._btn_load = self:getUI("bg.layer.hero_description_bg.btn_load")
    self._btn_load_image = self:getUI("bg.layer.hero_description_bg.btn_load.btn_load_image")
    self._btn_loaded_image = self:getUI("bg.layer.hero_description_bg.btn_load.btn_loaded_image")
    ]]
    self._btn_starChart = self:getUI("bg.layer.hero_description_bg.starChartBtn")
    self._heroes = {}
    self._heroes._data = self:initHeroData()
    --dump(self._heroes._data, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    self._heroes._currentSelectedHero = nil
    --self._heroes._currentLoadedHeroId = self._modelMgr:getModel("UserModel"):getData().currentHid or self._heroes._data[0].id -- version 3.0

    self._labelHaveHero = self:getUI("bg.image_hero_get_bg.label_have_hero")
    self._labelHaveHero:setFontName(UIUtils.ttfName)
    self._labelHaveHero:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._labelNowHero = self:getUI("bg.image_hero_get_bg.label_now_hero")
    --self._labelNowHero:setFontName(UIUtils.ttfName)
    self._labelNowHero:setString(self:getCurrentHeroCount())
    self._labelNowHero:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._labelTotalHero = self:getUI("bg.image_hero_get_bg.label_total_hero")
    --self._labelTotalHero:setFontName(UIUtils.ttfName)
    self._labelTotalHero:setString("/" .. self:getTotalHeroCount())
    self._labelTotalHero:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local attribute = self:getUI("bg.top_attribute_bg.label_hero_attribute")
    attribute:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._topAttributeInfo = self:getUI("bg.top_attribute_bg")
    self._tipLayer = self._viewMgr._tipLayer

    self._topInfo = {}
    self._topInfo._atkValue = self:getUI("bg.top_attribute_bg.label_atk_value")
    self._topInfo._atkValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._topInfo._defValue = self:getUI("bg.top_attribute_bg.label_def_value")
    self._topInfo._defValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._topInfo._intValue = self:getUI("bg.top_attribute_bg.label_int_value")
    self._topInfo._intValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._topInfo._ackValue = self:getUI("bg.top_attribute_bg.label_ack_value")
    self._topInfo._ackValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._btn_check_att_info = self:getUI("bg.top_attribute_bg.btn_check_att_info")

    self._scheduler = cc.Director:getInstance():getScheduler()

    self._currentHero = {}
    self._currentHero._data = nil
    self._currentHero._image = nil
    self._currentHero._mp = nil
    self._nextHero = {}
    self._nextHero._data = nil
    self._nextHero._image = nil
    self._nextHero._mp = nil
    self._heroSelect = HeroSelectView.new({container = self, notifyTouchEvent = handler(self, self.notifyTouchEvent),angleSpace = 15.0, heroData = {data = self._heroes._data}})
    self._layer:addChild(self._heroSelect, 9)

    self._size = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
    if ADOPT_IPHONEX then
        self._size = {width = 1136, height = MAX_SCREEN_HEIGHT}
    end

    -- self._heroSelectMask = ccui.ImageView:create("select_mask_hero.png", 1)
    self._heroSelectMask = self:getUI("heroSelectMask")
    self._heroSelectMask:setAnchorPoint(0, 0.5)
    self._heroSelectMask:setTouchEnabled(true)
    self._heroSelectMask:setSwallowTouches(true)
    -- self._heroSelectMask:setPosition(ADOPT_IPHONEX and 125 or 0, self._size.height / 2)
    -- self:addChild(self._heroSelectMask, 200)


    self._image_hero_specialty_touch.tipOffset = cc.p(-265, 0)
    self:registerTouchEvent(self._image_hero_specialty_touch, function(x, y)
        self:startClock(self._image_hero_specialty_touch, self._heroes._currentSelectedHero, 1)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)

    self:registerClickEvent(self._btn_check, function(sender)
        self:onCheckButtonClicked()
    end)

    self:registerClickEvent(self._btn_return, function(sender)
        self:close()
    end)
    
    self:registerClickEvent(self._btn_unlock, function(sender)
        self:onUnlockButtonClicked()
    end)

    self:registerClickEvent(self._btn_memoirist, function(sender)
        self:onMemoiristButtonClicked()
    end)

    self:registerClickEvent(self._appraise, function(sender)
        self:onAppraise()
    end)

    self:registerClickEvent(self._btn_change_skin, function(sender)
        self:onChangeSkinButtonClicked()
    end)

    self:registerClickEvent(self._topAttributeInfo, function(sender)
        self:onCheckAttInfoButtonClicked()
    end)
    --英雄选中Node
    self:initHeroSelectNode()
    self:updateSelectNode()

    --[[
    self:registerClickEvent(self._btn_load, function(sender)
        self:onLoadButtonClicked()
    end)
    ]]
    
    --[[
    self:listenReflash("HeroModel", function( )
         self._heroes._data = self:initHeroData()
         
    end)
    ]]
    self:heroStarEnter()
end


function HeroView:initHeroSelectNode()
    local selectBtn = self:getUI("bg.layer.hero_description_bg.selectBtn")
    local btnBg = self:getUI("bg.layer.hero_description_bg.btnBg")
    btnBg:setAnchorPoint(0, 0)
    btnBg:setVisible(false)
    -- btnBg:setPosition(cc.p(10, 80))
    -- btnBg:setOpacity(150)
    -- btnBg:setScale(0.6)
    selectBtn:setScaleAnim(true)
    local scale = cc.ScaleTo:create(0.1, 0.6)
    local move = cc.MoveTo:create(0.1, cc.p(10, 80))
    local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 0))
    local seq = cc.Sequence:create(spawn)
    btnBg:runAction(seq)

    self:registerClickEvent(selectBtn, function()
        local tflag = not btnBg:isVisible()
        local seq
        if tflag == true then
            local scale = cc.ScaleTo:create(0.1, 1)
            local move = cc.MoveTo:create(0.1, cc.p(10, 138))
            local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 255))
            seq = cc.Sequence:create(cc.CallFunc:create(function()
                btnBg:setVisible(tflag)
            end), spawn)
            btnBg:runAction(seq)
        else
            local scale = cc.ScaleTo:create(0.1, 0.6)
            local move = cc.MoveTo:create(0.1, cc.p(10, 80))
            local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 0))
            seq = cc.Sequence:create(spawn, cc.CallFunc:create(function()
                btnBg:setVisible(tflag)
            end))
            btnBg:runAction(seq)
        end
    end)
end

--英雄星图入口
function HeroView:heroStarEnter()
    local starIsOpen = self._heroModel:starOrOpen(self._heroes._currentSelectedHero.id)
    local openLevel = tab:SystemOpen("starCharts")[1]
    local showLevel = tab:SystemOpen("starCharts")[2]
    local systemOpenTip = tab:SystemOpen("starCharts")[3]
    local userLv = self._modelMgr:getModel("UserModel"):getData().lvl
    local redImage = self._btn_starChart:getChildByFullName("redImage")
    local starNum = self._heroes._currentSelectedHero.star
    local firstEnter = SystemUtils.loadAccountLocalData("STARCHARTS_IS_FIRSEENTER")   --第一次进入
    redImage:setVisible(false)
    local isShowTips = false
    if starIsOpen then
        if userLv < showLevel then
            self._btn_starChart:setVisible(false)
        elseif userLv >= showLevel and userLv < openLevel then
            isShowTips = true
            self._btn_starChart:setVisible(true)
            UIUtils:setGray(self._btn_starChart,true)
        elseif userLv >= openLevel then
            redImage:setVisible(not firstEnter and true or false)
            self._btn_starChart:setVisible(true)
            UIUtils:setGray(self._btn_starChart,false)
            if self._btn_starChart.starChartAni == nil then
                local starChartAni = mcMgr:createViewMC("xingturukou_xingtu1", true,false)
                local contentSize = self._btn_starChart:getContentSize()
                starChartAni:setAnchorPoint(0.5,0.5)
                starChartAni:setPosition(contentSize.width/2,contentSize.height/2)
                self._btn_starChart.starChartAni = starChartAni
                self._btn_starChart:addChild(starChartAni)
            end

        end

        self:registerClickEvent(self._btn_starChart, function(sender)
            if isShowTips then
                self._viewMgr:showTip(lang(systemOpenTip))
                return
            end
            self._viewMgr:showView("starCharts.StarChartsView",{container = self, heroData = self._heroes._currentSelectedHero,heroId = self._heroes._currentSelectedHero.id})
        end)
    else
        self._btn_starChart:setVisible(false)
    end
end

function HeroView:onAdd()

end

function HeroView:onTop()
    self._viewMgr:enableScreenWidthBar()
    for k, v in pairs(self._heroes._data) do
        local found, data = self:findHeroData(tonumber(v.id))
        if not found and self:isHeroCanUnlock(tonumber(v.id)) then
            self._heroes._data[k].canUnlock = true
        end
    end
    self:updateUI()
    self:updateSelectNode()
    if self._heroBioView then
        --战后更新传记动画
        if self._heroBioView.bioFightAfterAnim then
            self._heroBioView:bioFightAfterAnim()
        end
        -- 跳转回来之后需要刷新
        if self._heroBioView.goBackAndUpdate then
            self._heroBioView:goBackAndUpdate()
        end
    end
    if self._heroSelect then
        self._heroSelect:registerHeroSelectViewTouchEvent()
    end
    self:onDetailsViewClosed()
end



function HeroView:getBgName()
    --return "bg_001.jpg"
end

--[[
function HeroView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", {hideBtn = true})
end
]]

function HeroView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function HeroView:findHeroData(key)
    local heroData = self._heroModel:getData()
    for k, v in pairs(heroData) do
        if tonumber(k) == tonumber(key) then
            for i=1, 4 do
                v["masteryLock" .. i] = false
            end
            if v.locks and v.locks ~= "" then
                local locks = string.split(tostring(v.locks), ",")
                for _, v0 in pairs(locks) do
                    v["masteryLock" .. v0] = true
                end
                v.locks = nil
            end
            return true, v
        end
    end
    return false
end

function HeroView:isHeroCanUnlock(heroId)
    local heroTableData = clone(tab:Hero(heroId))
    local _, have = self._itemModel:getItemsById(heroTableData.unlockcost[2])
    local consume = heroTableData.unlockcost[3]
    return have >= consume
end

function HeroView:isHeroHaveFrag(heroId)
    local heroTableData = clone(tab:Hero(heroId))
    local _, have = self._itemModel:getItemsById(heroTableData.unlockcost[2])
    return have > 0
end

function HeroView:initHeroData()
    local heroesData = {}
    local heroTableData = clone(tab.hero)
    heroesData = self:orderHeroData(heroTableData) or {}
    return heroesData
end

function HeroView:updateHeroData()
    for k0, v0 in pairs(self._heroes._data) do
        local heroData = self._heroModel:getHeroData(tonumber(v0.id))
        if heroData then
            v0.score = heroData.score
        end
    end
end

function HeroView:unlockHero(result)
    if not result then return end
    for k, v in pairs(result) do
        for k0, v0 in pairs(self._heroes._data) do
            if v0.id == tonumber(k) then
                for k1, v1 in pairs(v) do
                    v0[k1] = v1
                end
                v0.unlock = true
                break
            end
        end
    end
end

function HeroView:upgradeHero(result)
    if not result then return end
    for k, v in pairs(result) do
        for k0, v0 in pairs(self._heroes._data) do
            if v0.id == tonumber(k) then
                -- for k1, v1 in pairs(v) do
                --     v0[k1] = v1
                -- end
                self._modelMgr:getModel("HeroModel"):mergeHeroData(v0,v)
                v0.unlock = true
                break
            end
        end
    end
end

function HeroView:getCurrentLoadedHeroId()
    --return self._heroes._currentLoadedHeroId
end

function HeroView:getCurrentHeroCount()
    local count = 0
    for _, v in pairs(self._heroes._data) do
        if v.unlock then
            count = count + 1
        end
    end
    return count
end

function HeroView:getTotalHeroCount()
    local count = 0
    for _, v in pairs(self._heroes._data) do
        count = count + 1
    end
    return count
end

function HeroView:getHeroDataById(heroId)
    if not self._heroes._data then return end
    for _, v in pairs(self._heroes._data) do
        if tonumber(heroId) == tonumber(v.id) then
            return v
        end
    end
end

function HeroView:topAttributeInfo(isTop)
    self._topAttributeInfo:retain()
    self._topAttributeInfo:removeFromParent()
    if isTop then
        --self._topAttributeInfo:setPosition(MAX_SCREEN_WIDTH * 0.5 - 345, MAX_SCREEN_HEIGHT - 65)
        -- self._topAttributeInfo:setPosition(MAX_SCREEN_WIDTH * 0.5 - self._topAttributeInfo:getContentSize().width / 2, MAX_SCREEN_HEIGHT - self._topAttributeInfo:getContentSize().height)
        if ADOPT_IPHONEX then
            self._topAttributeInfo:setPosition(MAX_SCREEN_WIDTH / 2.0, MAX_SCREEN_HEIGHT - self._topAttributeInfo:getContentSize().height / 2)
        end
        self._tipLayer:addChild(self._topAttributeInfo, -1)
    else
        self._bg:addChild(self._topAttributeInfo, 200)
    end
    self._topAttributeInfo:release()
end

function HeroView:updateRelative()
    self._label_not_open:setVisible(not SystemUtils:enableHeroOpen())
    self._btn_check:setVisible(SystemUtils:enableHeroOpen() and self._heroes._currentSelectedHero.unlock)
    self._btn_unlock:setVisible(SystemUtils:enableHeroOpen() and not self._heroes._currentSelectedHero.unlock)
    self._layer_unlock:setVisible(self._btn_unlock:isVisible())
    -- self._btn_unlock:setBright(self._heroes._currentSelectedHero.canUnlock)
    -- self._btn_unlock:setSaturation(self._heroes._currentSelectedHero.canUnlock and 0 or -100)

    local consume = self._heroes._currentSelectedHero.unlockcost[3]
    local _, have = ModelManager:getInstance():getModel("ItemModel"):getItemsById(self._heroes._currentSelectedHero.unlockcost[2])
    if have < consume then
        self._label_unlock_cost:setColor(cc.c3b(255, 0, 0))
    else
        self._label_unlock_cost:setColor(cc.c3b(118, 238, 0))
    end
    self._label_unlock_cost:setString(string.format("%d/%d", have, consume))

    local color = cc.c3b(255, 236, 69)
    local nowHero = self:getCurrentHeroCount()
    local totalHero = self:getTotalHeroCount()
    if nowHero >= totalHero then
        color = cc.c3b(28, 162, 22)
    end
    self._labelNowHero:setColor(color)
    self._labelNowHero:setString(self:getCurrentHeroCount())
    self._labelTotalHero:setString("/" .. self:getTotalHeroCount())
    self._labelTotalHero:setPositionX(self._labelNowHero:getPositionX() + self._labelNowHero:getContentSize().width / 2 + 1)

    self:updateAttributes()

    -- 更新皮肤和传记按钮的显示
    self:updateSkinBtn()
    self:updateMemoiristBtn()
    self:updateAppriseBtn()
end

function HeroView:updateAttributes(dirty)
    if not self._attributeValues or dirty then
        self._attributeValues = BattleUtils.getHeroAttributes(clone(self._heroes._currentSelectedHero))
    end

    -- dump(self._attributeValues, "self._attributeValues", 5)
    -- 皮肤收集是遍历表算出来的，后端仅在战斗时加入hab 结构，平常显示要自己 单加
    local starAttr = self._modelMgr:getModel("UserModel"):getStarHeroAttr() or {}
    local heroSkinAttrs = self._modelMgr:getModel("HeroModel"):getHeroSkinAttr() or {}
    local spellAttrs = self._modelMgr:getModel("SpellBooksModel"):getSpellBookAttrs() or {}
    self._topInfo._atkValue:setString(string.format("%.1f", self._attributeValues.atk+ (heroSkinAttrs.atk or 0) + (starAttr["110"] or starAttr[110] or 0) ))
    self._topInfo._defValue:setString(string.format("%.1f", self._attributeValues.def+ (heroSkinAttrs.def or 0) + (starAttr["113"] or starAttr[113] or 0) ))
    self._topInfo._intValue:setString(string.format("%.1f", self._attributeValues.int+ (heroSkinAttrs.int or 0) + (starAttr["116"] or starAttr[116] or 0) ))
    self._topInfo._ackValue:setString(string.format("%.1f", self._attributeValues.ack+ (heroSkinAttrs.ack or 0) + (starAttr["119"] or starAttr[119] or 0)))
    -- self._topInfo._atkValue:setString(string.format("%.1f", self._attributeValues.atk+ (heroSkinAttrs.atk or 0)))
    -- self._topInfo._defValue:setString(string.format("%.1f", self._attributeValues.def+ (heroSkinAttrs.def or 0)))
    -- self._topInfo._intValue:setString(string.format("%.1f", self._attributeValues.int+ (heroSkinAttrs.int or 0)))
    -- self._topInfo._ackValue:setString(string.format("%.1f", self._attributeValues.ack+ (heroSkinAttrs.ack or 0)))
end

function HeroView:showTopInfo(isShow)
    self._topAttributeInfo:setVisible(isShow)
end

function HeroView:updateUI()
    self:updateRelative()
    local cards = self._heroSelect:getAllCards()
    for _, card in ipairs(cards) do
        card:updateUI()
    end

    --[[
    self._image_unlock_gold:setVisible(not self._heroes._currentSelectedHero.unlock)
    self._btn_load:setVisible(self._heroes._currentSelectedHero.unlock)
    self._btn_load:setEnabled(self._heroes._currentLoadedHeroId ~= self._heroes._currentSelectedHero.id)
    self._btn_load:setBright(self._heroes._currentLoadedHeroId ~= self._heroes._currentSelectedHero.id)
    self._btn_load_image:setVisible(self._heroes._currentLoadedHeroId ~= self._heroes._currentSelectedHero.id)
    self._btn_loaded_image:setVisible(self._heroes._currentLoadedHeroId == self._heroes._currentSelectedHero.id)
    ]]

end

function HeroView:getHeroRaceType(typeId)
    -- self._heroes._data
    -- dump(self._heroes._data)
    local raceTable = {}
    if tonumber(typeId) == 0 then
        return self._heroes._data
    end
    for _ , v in pairs(self._heroes._data) do
        if tonumber(typeId) == tonumber(v.masterytype) then
            table.insert(raceTable,v)
        end
    end
    return raceTable
end

function HeroView:updateSelectNode()
    self:getHeroRaceType()
    local btnBg = self:getUI("bg.layer.hero_description_bg.btnBg")
    for i=1,11 do
        local raceBtn = btnBg:getChildByFullName("raceBtn"..i)
        local selBtn = btnBg:getChildByFullName("raceBtn"..i..".selBtn")
        local txt = btnBg:getChildByFullName("raceBtn" .. i .. ".txt")

        selBtn:setVisible(false)
        raceBtn:setScaleAnim(true)
        local raceTable = self:getHeroRaceType(HeroView.HERO_RACE_TYPE["RACE_" .. i])
        if table.nums(raceTable) >= 1 then
            raceBtn:setSaturation(0)
            txt:setColor(cc.c3b(255,255,255))
            self:registerClickEvent(raceBtn, function()
                if self._teamType == i then
                    return
                end
                local _type = HeroView.HERO_RACE_TYPE["RACE_" .. i]
                -- self._firstFight = true
                self:resetHeroSelectView(_type)
                selBtn:setVisible(true)
                local tempBtn = btnBg:getChildByFullName("raceBtn" .. self._teamType .. ".selBtn")
                tempBtn:setVisible(false)
                self._teamType = i 
                -- local btnBg = self:getUI("btnBg")
                btnBg:setVisible(false)
            end)
        else
            txt:setColor(cc.c3b(60,60,60))
            raceBtn:setSaturation(-100)
            self:registerClickEvent(raceBtn, function()
                self._viewMgr:showTip("暂无该类型英雄")
            end)
        end
    end
end

function HeroView:resetHeroSelectView(typeId)
    if tonumber(typeId) == 0 then
        self._heroes._data = self:initHeroData()
    else
        self._heroes._data = self:getResetHeroData(typeId)
    end
    if self._heroSelect then
        self._heroSelect:removeFromParent()
        self._heroSelect = nil
    end
    self._heroSelect = HeroSelectView.new({container = self, notifyTouchEvent = handler(self, self.notifyTouchEvent),angleSpace = 15.0, heroData = {data = self._heroes._data}})
    self._layer:addChild(self._heroSelect, 9)
end

function HeroView:orderHeroData(heroTableData)
    local currentLoadedHeroId = self._formationModel:getFormationDataByType(self._formationModel.kFormationTypeCommon).heroId
    local isHeroLoaded = function(heroId)
        return tonumber(heroId) == tonumber(currentLoadedHeroId)
    end
    local tn1 = {}
    local t0 = {}
    local t1 = {}
    local t2 = {}
    local heroesData = {}
    for k0, v0 in pairs(heroTableData) do
        repeat
            local isLoaded = isHeroLoaded(tonumber(k0))
            local isCanUnlock = self:isHeroCanUnlock(tonumber(k0))
            local isHaveFrag = self:isHeroHaveFrag(tonumber(k0))
            local found, data = self:findHeroData(tonumber(k0))
            if 0 == v0.visible and not found and not isHaveFrag then break end
            v0.unlock = false
            v0.canUnlock = false
            if not found and isCanUnlock then
                v0.canUnlock = true
                table.insert(t0, v0)
            elseif found then
                for k1, v1 in pairs(data) do
                    v0[tostring(k1)] = v1
                    v0.unlock = true
                end
                if isLoaded then
                    table.insert(tn1, v0)
                else
                    table.insert(t1, v0)
                end
            else
                table.insert(t2, v0)
            end
        until true
    end

    table.sort(tn1, function(a, b)
        return a.obseq < b.obseq
    end)

    table.sort(t0, function(a, b)
        return a.obseq < b.obseq
    end)

    table.sort(t1, function(a, b)
        return a.obseq < b.obseq
    end)

    table.sort(t2, function(a, b)
        return a.obseq < b.obseq
    end)

    local index = 0

    for _, v in ipairs(tn1) do
        heroesData[index] = v
        index = index + 1
    end

    for _, v in ipairs(t0) do
        heroesData[index] = v
        index = index + 1
    end

    for _, v in ipairs(t1) do
        heroesData[index] = v
        index = index + 1
    end

    for _, v in ipairs(t2) do
        heroesData[index] = v
        index = index + 1
    end
    return heroesData
end

function HeroView:getResetHeroData(typeId)
    local heroesData = {}
    local heroTableData = clone(tab.hero)
    
    local selectTable = {}   --选中阵营数据
    local otherTable = {}    --其它阵营数据 
    for k , v in pairs(heroTableData) do
        if tonumber(typeId) == tonumber(v.masterytype) then
            selectTable[k] = v
        else
            otherTable[k] = v
        end
    end
    local orderSelectTable = self:orderHeroData(selectTable)
    local orderOtherTable = self:orderHeroData(otherTable)
    local index = 0
    for _ , v in pairs(orderSelectTable) do
        heroesData[index] = v
        index = index + 1
    end
    for _ , v in pairs(orderOtherTable) do
        heroesData[index] = v
        index = index + 1
    end
    return heroesData
end


function HeroView:notifyTouchEvent(event)
    --[[
    if self._heroSelect:isMidCardClicked() then return end
    if event == HeroSelectView.kTouchEventBegan then
        ScheduleMgr:delayCall(200, self, function()
            self._btn_check:setVisible(false)
            self._btn_check:setEnabled(false)
            self._btn_unlock:setVisible(false)
            self._btn_unlock:setEnabled(false)
            self._btn_return:setEnabled(false)
        end)
    else
        ScheduleMgr:delayCall(0, self, function()
            self._btn_check:setVisible(false)
            self._btn_check:setEnabled(false)
            self._btn_unlock:setVisible(false)
            self._btn_unlock:setEnabled(false)
            self._btn_return:setEnabled(false)
        end)
    end
    ]]
end

function HeroView:onSelected(hero, noAction, force)
    print("on selected hero id", hero.id)

    --分享按钮 by wangyan
    if self._shareNode == nil then
        self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareHeroModule"})
        self._shareNode:setPosition(47, 150)
        self._shareNode:setCascadeOpacityEnabled(true, true)
        self._hero_description_bg:addChild(self._shareNode, 5)
    end

    self._shareNode:registerClick(function()
        return {moduleName = "ShareHeroModule", heroId = hero.id}
    end)

    if hero.unlock and hero.unlock == true then
        self._shareNode:setVisible(true)
    else
        self._shareNode:setVisible(false)
    end

    if not noAction then
        if self._soundTimerId then 
            self._scheduler:unscheduleScriptEntry(self._soundTimerId)
            self._soundTimerId = nil
        end

        if not self._soundTimerId then
            self._soundTimerId = self._scheduler:scheduleScriptFunc(function()
                if self._soundTimerId then 
                    self._scheduler:unscheduleScriptEntry(self._soundTimerId)
                    self._soundTimerId = nil
                end
                local heroTableData = tab:Hero(hero.id)
                if heroTableData["soundSelect"] then
                    if self._selectSoundId then
                        audioMgr:stopSound(self._selectSoundId)
                        self._selectSoundId = nil
                    end
                    self._selectSoundId = audioMgr:playSound(heroTableData["soundSelect"])
                end
            end, 1, false)
        end
    end

    self._heroes._currentSelectedHero = hero

    --self._specialName:setString(lang(tab.heroMastery(hero.special).name)) -- version 3.0
    self._attributeValues = BattleUtils.getHeroAttributes(clone(self._heroes._currentSelectedHero))
    --[[
    self._btn_check:setVisible(false)
    self._btn_check:setEnabled(false)
    self._btn_unlock:setVisible(false)
    self._btn_unlock:setEnabled(false)
    self._btn_return:setEnabled(false)
    ]]
    --[[
    local labelDiscription = self._layer_unlock
    local desc = lang(hero.prov)
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setTextAdditionalKerning(0)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    --if self._currentHero._data and self._currentHero._data.herospine ~= hero.herospine or not self._currentHero._data then
    if self._currentHero._data and self._currentHero._data.heroport ~= hero.heroport or not self._currentHero._data or force then
        if self._currentHero._data then
            self._currentHero._image:clear()
        end

        self._currentHero._data = hero
        self._currentHero._image = HeroSpine.new(self._layer, 5, hero.id, false, nil, nil, nil, clone(hero))
    end
    if not noAction then
        self._hero_description_bg:runAction(
            cc.Sequence:create(
                cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(50.0, 0.0)), 2),
                cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(-50.0, 0.0)), 2)
            ))
    end

    --[[
    ScheduleMgr:delayCall(200, self, function()
        self._btn_check:setVisible(SystemUtils:enableHeroOpen() and hero.unlock)
        self._btn_check:setEnabled(true)
        self._btn_unlock:setVisible(not hero.unlock)
        self._btn_unlock:setEnabled(true)
        self._btn_unlock:setBright(self._heroes._currentSelectedHero.canUnlock)
        self._btn_unlock:setSaturation(self._heroes._currentSelectedHero.canUnlock and 0 or -100)
        self._btn_return:setEnabled(true)
    end)
    ]]

    --[[
    local heroTableData = tab:Hero(hero.id)
    local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    local value = hero.atk[1] + (hero.star - heroTableData.star) * hero.atk[2]
    local attributeMaxValue = math.max(HeroView.kAttributeStep * heroMaxStar * (hero.star - heroTableData.star + 1) / (heroMaxStar - heroTableData.star + 1), HeroView.kAttributeStep * hero.star)
    value = math.min(value, attributeMaxValue)
    self._progressBar._atk:setPercent(value / attributeMaxValue * 100, self._progressBarDurationTime)
    self._progressBar._atkValue:setString(value)
    value = hero.def[1] + (hero.star - heroTableData.star) * hero.def[2]
    self._progressBar._def:setPercent(value / attributeMaxValue * 100, self._progressBarDurationTime)
    self._progressBar._defValue:setString(value)
    value = hero.int[1] + (hero.star - heroTableData.star) * hero.int[2]
    self._progressBar._int:setPercent(value / attributeMaxValue * 100, self._progressBarDurationTime)
    self._progressBar._intValue:setString(value)
    value = hero.ack[1] + (hero.star - heroTableData.star) * hero.ack[2]
    self._progressBar._ack:setPercent(value / attributeMaxValue * 100, self._progressBarDurationTime)
    self._progressBar._ackValue:setString(value)
    ]]

    self._labelAddtionAttribute:setString(self._heroModel:checkHero(hero.id) and "收集加成:" or "解锁加成:")
    local attributes = {"atk", "def", "int", "ack"}
    local attributesName = {atk = "英雄攻击", def = "英雄防御", int = "英雄智力", ack = "英雄知识"}
    local index = 1
    local heroTableData = tab:Hero(hero.id)
    local heroMaxStar = tab:Setting("G_HERO_MAX_STAR").value
    for _, att in ipairs(attributes) do
        if heroTableData[att] then
            local value = 0
            if self._heroModel:checkHero(hero.id) then
                value = heroTableData[att][1] + (hero.star - 1) * heroTableData[att][2]
            else
                value = heroTableData[att][1]
            end
            self["_imageAttr" .. index]:loadTexture(att .. "_icon_hero.png", 1)
            self["_labelAttr" .. index]:setString(attributesName[att] .. "+" .. value)
            index = math.min(index + 1, 2)
        end
    end

    -- version 4.0
    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(hero.special)
    self._image_hero_specialty:setScale(0.8)
    self._image_hero_specialty:loadTexture(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)

    --[[
    local heroMasteryData = tab:HeroMastery(hero.special)
    self._image_hero_specialty:loadTexture(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg")
    ]]
    local labelDiscription = self._label_hero_description
    local desc = "[color=a78558, fontsize=20]" .. lang(hero.herodes) .. "[-]"
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)

    for i = 1, HeroSkillInformationView.kSkillCount do
        local skillId = self._heroes._currentSelectedHero.spell[i]
        local skillTemp = skillId
        local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroes._currentSelectedHero.id), skillId)
        if isReplaced then
            skillId = skillReplacedId
        end

        local skillData = tab:PlayerSkillEffect(skillId)
        local iconBg = self._skillIcon[i]:getChildByFullName("skill_icon_bg")
        local icon = iconBg:getChildByTag(HeroView.kHeroSkillIconTag)
        self:registerTouchEvent(iconBg, function(x, y)
            self:startClock(iconBg, clone(self._heroes._currentSelectedHero), 2, skillData.id, skillTemp)
        end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
        if not icon then
            icon = ccui.ImageView:create(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png", 1)
            icon:setScale(0.9)
            --local posY = 4 == i and iconBg:getContentSize().height * 0.5 or iconBg:getContentSize().height * 0.5
            icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
            icon:setTag(HeroView.kHeroSkillIconTag)
            iconBg:addChild(icon,-1)
        else
            icon:loadTexture(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png", 1)
        end
    end
    --[[
    local consume = self._heroes._currentSelectedHero.unlockcost[3]
    local _, have = ModelManager:getInstance():getModel("ItemModel"):getItemsById(self._heroes._currentSelectedHero.unlockcost[2])
    if have < consume then
        self._label_unlock_cost:setColor(cc.c3b(255, 0, 0))
    else
        self._label_unlock_cost:setColor(cc.c3b(118, 238, 0))
    end
    self._label_unlock_cost:setString(string.format("%d/%d", have, consume))
    ]]

    --self:updateUI() --version 3.0
    --[[
    -- 从heroSpine 拷过来
    self._panel_star_bg:removeAllChildren()
    if self._heroes._currentSelectedHero then
        local posX, posY = 200, 20 --self._imageName:getPositionX() - 5, self._imageName:getPositionY() - self._imageName:getContentSize().height / 1.6
        for i=1, 4 do
            if i <= self._heroes._currentSelectedHero.star then
                local starLight = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star3.png")
                starLight:setAnchorPoint(cc.p(1, 0.5))
                starLight:setPosition(posX - (4 - i) * (starLight:getContentSize().width + 8), posY)
                self._panel_star_bg:addChild(starLight, 20)
            end
            local starGray = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star4.png")
            starGray:setAnchorPoint(cc.p(1, 0.5))
            starGray:setPosition(posX - (4 - i) * (starGray:getContentSize().width + 8), posY)
            self._panel_star_bg:addChild(starGray, 15)
        end
    end
    ]]

    self:updateRelative()

    -- 更新法术槽状态
    local allIcons = {} 
    table.insert(allIcons,self._skillIcon[4])
    table.insert(allIcons,self._skillIcon[1])
    table.insert(allIcons,self._skillIcon[2])
    table.insert(allIcons,self._skillIcon[3])
    table.insert(allIcons,self._slotIcon)
    local slot = self._heroes._currentSelectedHero.slot 
    if slot then
        UIUtils:alignNodesToPos(allIcons,220,15)
        self._slotIcon:setVisible(true)
        self:updateSlot()
        self:updateSelectCardImg(slot)
    else
        UIUtils:alignNodesToPos(allIcons,260,30)
        self._slotIcon:setVisible(false)
    end

    --6.5 更新星图入口按钮状态
    self:heroStarEnter()
end

function HeroView:updateSlot( )
    local slot = self._heroes._currentSelectedHero.slot
    if slot then
        local sid = slot.sid 
        local iconBg = self._slotIcon:getChildByFullName("skill_icon_bg")
        local add = iconBg:getChildByFullName("skill_add")
        local icon = iconBg:getChildByTag(HeroView.kHeroSkillIconTag)
        add:setVisible(not sid or sid == 0)
        if sid and sid ~= 0 then
            local skillId = sid
            local skillTemp = sid
            local isReplaced, skillReplacedId = self._heroModel:isSpellReplaced(tonumber(self._heroes._currentSelectedHero.id), skillId)
            if isReplaced then
                skillId = skillReplacedId
            end
            local skillBBData = tab:SkillBookBase(skillId)
            local skillBBType = skillBBData.skillType or 1
            local tipType = nil
            if skillBBType == 2 then
                local heromasteryData = tab:HeroMastery(skillId)
                tipType = 6 -- 英雄被动
            end
            local skillData = tab:PlayerSkillEffect(skillId) or tab:HeroMastery(skillId)
            self:registerTouchEvent(iconBg, function(x, y)
                self:startClock(iconBg, clone(self._heroes._currentSelectedHero), 2, skillData.id, skillTemp,tipType)
            end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
            if not icon then
                icon = ccui.ImageView:create(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png", 1)
                icon:setScale(0.9)
                --local posY = 4 == i and iconBg:getContentSize().height * 0.5 or iconBg:getContentSize().height * 0.5
                icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
                icon:setTag(HeroView.kHeroSkillIconTag)
                iconBg:addChild(icon,-1)
            else
                icon:loadTexture(IconUtils.iconPath .. (skillData.art or skillData.icon) .. ".png", 1)
            end
            icon:setVisible(true)
        else
            if icon then
                icon:setVisible(false)
            end
            self:registerClickEvent(iconBg,function() 
                self:onCheckButtonClicked()
            end)
        end
    end
end

function HeroView:updateSelectCardImg(slot)
    if not self._heroSelect then return end
    local card = self._heroSelect:getCurrentSelectedCard()
    card:updateSelectImage(slot)    
end
-- 关闭传记更新换肤&传记红点
function HeroView:updateSkinBtn()
    local _heroId = self._heroes._currentSelectedHero.id
    -- 获得英雄即可点击皮肤
    local isOpen,_ = SystemUtils:enableHeroOpen() 
    self._btn_change_skin:setVisible(isOpen and not not self._heroes._currentSelectedHero.heroSkinID)  --and self._heroes._currentSelectedHero.unlock)
    local redImg = self._btn_change_skin:getChildByFullName("redNotice")
    if not redImg then
        redImg = ccui.ImageView:create()
        redImg:loadTexture("globalImageUI_bag_keyihecheng.png",1)
        redImg:setPosition(65, 70)
        redImg:setName("redNotice")
        self._btn_change_skin:addChild(redImg,1)
    end
    local isRedVisible = self._heroModel:isSkinHaveNoticeById(_heroId)
    redImg:setVisible(isRedVisible)
end

function HeroView:updateAppriseBtn()
    -- [[
    if SystemUtils:enableHeroOpen() then
        self._appraise:setVisible(true)
    else
        self._appraise:setVisible(false)
    end--]]
    -- self._appraise:setVisible(false)
end

function HeroView:updateMemoiristBtn()
    local _heroId = self._heroes._currentSelectedHero.id
    self._btn_memoirist:setVisible(SystemUtils:enableHeroOpen() and SystemUtils:enableHeroBio() and self._heroes._currentSelectedHero.unlock and not not self._heroes._currentSelectedHero.heroBioID)
    local redImg = self._btn_memoirist:getChildByFullName("redNotice")
    if not redImg then
        redImg = ccui.ImageView:create()
        redImg:loadTexture("globalImageUI_bag_keyihecheng.png",1)
        redImg:setPosition(65, 70)
        redImg:setName("redNotice")
        self._btn_memoirist:addChild(redImg,1)
    end
    local isRedVisible = self._heroModel:isHaveNoticeByheroId(_heroId)
    redImg:setVisible(isRedVisible)
end
--[=[
function HeroView:onSelected(hero)
    self._heroes._currentSelectedHero = hero
    --self._specialName:setString(lang(tab.heroMastery(hero.special).name)) -- version 3.0
    self._btn_check:setVisible(hero.unlock)
    self._btn_check:setTouchEnabled(false)
    self._btn_unlock:setVisible(not hero.unlock)
    local labelDiscription = self._layer_unlock
    local desc = lang(hero.prov)
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setTextAdditionalKerning(0)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    --self._btn_unlock:setTouchEnabled(false) --version 3.0
    if self._currentHero._data and self._currentHero._data.heroport ~= hero.heroport or not self._currentHero._data then
        if self._currentHero._data then
            local mp = self._currentHero._mp
            local image = self._currentHero._image
            mp:runAction(cc.FadeOut:create(0.1))
            image:runAction(cc.Sequence:create(
                cc.FadeOut:create(1), 
                cc.CallFunc:create(function()
                    image:removeFromParent()
            end)))
        end

        self._currentHero._data = hero
        self._currentHero._image = cc.Sprite:create("asset/uiother/hero/" .. hero.heroport .. ".jpg")
        self._currentHero._image:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2)
        self._currentHero._mp = cc.Sprite:createWithSpriteFrameName(hero.heromp .. ".png")
        self._currentHero._mp:setPosition(self._currentHero._image:getContentSize().width / 2 + hero.mppos[1], self._currentHero._image:getContentSize().height / 2 + hero.mppos[2])
        self._currentHero._mp:setOpacity(0)
        self._currentHero._image:addChild(self._currentHero._mp, 0)
        self._currentHero._image:setOpacity(0)
        self._layer:addChild(self._currentHero._image, 5)
        self._currentHero._mp:runAction(cc.FadeIn:create(0.2))
        self._currentHero._image:runAction(cc.FadeIn:create(1.2))
    end
    
    self._hero_description_bg:runAction(cc.Spawn:create(
        cc.Sequence:create(
            cc.FadeOut:create(0.1),
            cc.FadeIn:create(0.1)),
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(50.0, 0.0)), 2),
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(-50.0, 0.0)), 2),
            cc.CallFunc:create(function()
                self._btn_check:setTouchEnabled(true)
                --self._btn_unlock:setTouchEnabled(true) --version 3.0
    end))))

    self._progressBar._atk:setPercent(hero.atk / 20 * 100, self._progressBarDurationTime)
    self._progressBar._atkValue:setString(hero.atk)
    self._progressBar._def:setPercent(hero.def / 20 * 100, self._progressBarDurationTime)
    self._progressBar._defValue:setString(hero.def)
    self._progressBar._int:setPercent(hero.int / 20 * 100, self._progressBarDurationTime)
    self._progressBar._intValue:setString(hero.int)
    self._progressBar._ack:setPercent(hero.ack / 20 * 100, self._progressBarDurationTime)
    self._progressBar._ackValue:setString(hero.ack)

    local heroMasteryData = tab:HeroMastery(hero.special)
    self._image_hero_specialty:loadTexture(heroMasteryData.icon .. ".jpg", 1)

    local labelDiscription = self._label_hero_description
    local desc = "[color=a78558, fontsize=16]" .. lang(hero.herodes) .. "[-]"
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)

    --self:updateUI() --version 3.0
end
]=]
--[=[
function HeroView:onSelected(hero)
    self._heroes._currentSelectedHero = hero
    --self._specialName:setString(lang(tab.heroMastery(hero.special).name)) -- version 3.0
    self._btn_check:setVisible(hero.unlock)
    self._btn_check:setTouchEnabled(false)
    self._btn_unlock:setVisible(not hero.unlock)
    local labelDiscription = self._layer_unlock
    local desc = lang(hero.prov)
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setTextAdditionalKerning(0)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    --self._btn_unlock:setTouchEnabled(false) --version 3.0
    if self._currentHero._data then
        self._currentHero._mp:runAction(cc.FadeOut:create(0.1))
        --self._currentHero._image:runAction(cc.Sequence:create(
            --cc.FadeOut:create(1), 
            --cc.CallFunc:create(function()
                if self._currentHero._image then
                    if self._currentHero._image.clearHeroSpine then
                        self._currentHero._image:clearHeroSpine()
                    end
                    self._currentHero._image:removeFromParent()
                end
                self._currentHero = nil
                self._currentHero = {}
       --end)))
    end
    if true then
    self._nextHero._data = hero
    self._nextHero._image = HeroSpine.new(hero.id)
    self._nextHero._image:setPosition(self._bg:getContentSize().width / 1.3, 0)
    self._nextHero._mp = cc.Sprite:createWithSpriteFrameName(hero.heromp .. ".png")
    self._nextHero._mp:setPosition(self._bg:getContentSize().width / 2 + hero.mppos[1], self._bg:getContentSize().height / 2 + hero.mppos[2])
    self._nextHero._mp:setOpacity(0)
    self._bg:addChild(self._nextHero._mp, 0)
    self._layer:addChild(self._nextHero._image, 5)
    self._nextHero._mp:runAction(cc.FadeIn:create(0.2))
    --self._nextHero._image:runAction(cc.Sequence:create(
            --cc.FadeIn:create(1.2), 
            --cc.CallFunc:create(function()
                self._currentHero = self._nextHero
                self._nextHero = nil
                self._nextHero = {}
        --end)))
    else
    self._nextHero._data = hero
    self._nextHero._image = cc.Sprite:create("asset/uiother/hero/" .. hero.heroport .. ".jpg")
    self._nextHero._image:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2)
    self._nextHero._mp = cc.Sprite:createWithSpriteFrameName(hero.heromp .. ".png")
    self._nextHero._mp:setPosition(self._nextHero._image:getContentSize().width / 2 + hero.mppos[1], self._nextHero._image:getContentSize().height / 2 + hero.mppos[2])
    self._nextHero._mp:setOpacity(0)
    self._nextHero._image:addChild(self._nextHero._mp, 0)
    self._nextHero._image:setOpacity(0)
    self._layer:addChild(self._nextHero._image, 5)
    self._nextHero._mp:runAction(cc.FadeIn:create(0.2))
    self._nextHero._image:runAction(cc.Sequence:create(
            cc.FadeIn:create(1.2), 
            cc.CallFunc:create(function()
                self._currentHero = self._nextHero
                self._nextHero = nil
                self._nextHero = {}
        end)))
    end
    self._hero_description_bg:runAction(cc.Spawn:create(
        cc.Sequence:create(
            cc.FadeOut:create(0.1),
            cc.FadeIn:create(0.1)),
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(50.0, 0.0)), 2),
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(-50.0, 0.0)), 2),
            cc.CallFunc:create(function()
                self._btn_check:setTouchEnabled(true)
                --self._btn_unlock:setTouchEnabled(true) --version 3.0
    end))))

    self._progressBar._atk:setPercent(hero.atk / 20 * 100, self._progressBarDurationTime)
    self._progressBar._atkValue:setString(hero.atk)
    self._progressBar._def:setPercent(hero.def / 20 * 100, self._progressBarDurationTime)
    self._progressBar._defValue:setString(hero.def)
    self._progressBar._int:setPercent(hero.int / 20 * 100, self._progressBarDurationTime)
    self._progressBar._intValue:setString(hero.int)
    self._progressBar._ack:setPercent(hero.ack / 20 * 100, self._progressBarDurationTime)
    self._progressBar._ackValue:setString(hero.ack)

    local heroMasteryData = tab:HeroMastery(hero.special)
    self._image_hero_specialty:loadTexture(heroMasteryData.icon .. ".jpg", 1)

    local labelDiscription = self._label_hero_description
    local desc = "[color=a78558, fontsize=18]" .. lang(hero.herodes) .. "[-]"
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

    --self:updateUI() --version 3.0
end
]=]
function HeroView:onIconPressOn(node, heroData, iconType, iconId, iconIdTemp,skillType)
    if not heroData then return end
    local spTalent = self._modelMgr:getModel("SkillTalentModel"):getTalentDataInFormat()
    if iconType == 1 then
        dump("sjhfgasduhfgud")
        self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = heroData.special,heroData = clone(heroData), posCenter = true, spTalent = spTalent})
    else
        local index = 1
        local inSpell = false

        --by wangyan 2018.3.10
        for k,v in pairs(heroData.spell) do
            if v == iconIdTemp then   --用转换之前的skillId比较，因为后端给的是这样
                index = k 
                inSpell = true
                break
            end
        end
        local skillLevel = nil
        local sklevel = 1
        local isSlotMastery = false
        if not inSpell then
            skillLevel = heroData.slot and heroData.slot.sLvl
            sklevel = heroData.slot and heroData.slot.s
            local heroDataC = clone(heroData)
            local sid = heroDataC.slot and heroDataC.slot.sid and tonumber(heroDataC.slot.sid)
            isSlotMastery = tab.heroMastery[tonumber(sid) or 0]
            if sid and sid ~= 0 then
                local bookId = tonumber(sid)
                local bookInfo = self._modelMgr:getModel("SpellBooksModel"):getData()[tostring(bookId)]
                -- 刻印被动技能根据法术书变id
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
                if iconId == sid1 then
                    sklevel = v[2] or 1
                    skillLevel = not isSlotMastery and v[3] or v[2] or 1
                    break
                end
            end
        else
            skillLevel = self._attributeValues.skills and 
                         self._attributeValues.skills[index] and
                         self._attributeValues.skills[index][2] or nil
        end
        self:showHintView("global.GlobalTipView",{
            tipType = 2, node = node, id = iconId, heroData = not isSlotMastery and clone(heroData) or nil,
            skillLevel = skillLevel,skillType = skillType, sklevel = sklevel, posCenter = true, spTalent = spTalent})
    end
end

function HeroView:onIconPressOff()
    --self:closeHintView()
end

function HeroView:startClock(node, heroData, iconType, iconId, iconIdTemp,skillType)
    if self._timer_id then self:endClock() end
    self._first_tick = true
    -- self._timer_id = self._scheduler:scheduleScriptFunc(function()
    --     if not self._first_tick then return end
    --     self._first_tick = false
        self:onIconPressOn(node, heroData, iconType, iconId, iconIdTemp,skillType)
    -- end, 0.2, false)
end

function HeroView:endClock()
   if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
     self:onIconPressOff()
end

function HeroView:onCheckButtonClicked()
    print("current check hero id is", self._heroes._currentSelectedHero.id)
    self:topAttributeInfo(true)
    self._viewMgr:showDialog("hero.HeroDetailsView", {container = self, heroData = self._heroes._currentSelectedHero}, true)
end

function HeroView:onUnlockButtonClicked()
    local _, have = self._itemModel:getItemsById(self._heroes._currentSelectedHero.unlockcost[2])
    local consume = self._heroes._currentSelectedHero.unlockcost[3]
    if have < consume then
        --self._viewMgr:showTip(lang("TIPS_HEROUNLOCK_1"))
        DialogUtils.showItemApproach(self._heroes._currentSelectedHero.unlockcost[2])
        return 
    end

    local context = {heroId = self._heroes._currentSelectedHero.id}
    --dump(context, "context")
    self._serverMgr:sendMsg("HeroServer", "unlockHero", context, true, {}, function(result)
        self._heroModel:unlockHero(result["d"]["heros"])
        self:unlockHero(result["d"]["heros"])

        if result["unset"] ~= nil then 
            local removeItems = self._itemModel:handelUnsetItems(result["unset"])
            self._itemModel:delItems(removeItems, true)
        end

        if result["d"].items then
            self._itemModel:updateItems(result["d"].items)
            result["d"].items = nil
        end
        self:showTopInfo(false)
        local heroUnlockLayer = self._viewMgr:createLayer("hero.HeroUnlockView", {heroId = self._heroes._currentSelectedHero.id, callBack = function()
            local card = self._heroSelect:getCurrentSelectedCard()
            if card then
                card:setUnlock(true)
            end
            self:showTopInfo(true)
            self:onSelected(self._heroes._currentSelectedHero, true, true)
            self:updateUI()
        end})

        self:getLayerNode():addChild(heroUnlockLayer)
    end)
end

function HeroView:onAppraise()
    -- dump(self._heroes._currentSelectedHero,"aaaaaaa",10)
    local param = {ctype = 5, id = self._heroes._currentSelectedHero.id}
    self._serverMgr:sendMsg("CommentServer", "getCommentData", param, true, {}, function(result)
        self._viewMgr:showDialog("hero.HeroAppraiseDialog",{id = self._heroes._currentSelectedHero.id,star = self._heroes._currentSelectedHero.star},true)
    end)
end

function HeroView:onMemoiristButtonClicked()
    if not self._heroes._currentSelectedHero then return end
    print("show hero memoirist:", self._heroes._currentSelectedHero.id)
    local isUnlockBio = SystemUtils:enableHeroBio() and self._heroes._currentSelectedHero.unlock and not not self._heroes._currentSelectedHero.heroBioID
    if not self._heroes._currentSelectedHero.id or not isUnlockBio then
        return 
    end

    -- 打开界面 请求数据    
    self._serverMgr:sendMsg("HeroBioServer", "getHeroBioInfo", {heroId=self._heroes._currentSelectedHero.id}, true, {}, function(result)
        self._heroBioView =self._viewMgr:showDialog("hero.HeroBiographyView",{heroId = self._heroes._currentSelectedHero.id,
            callback = function()
                self._heroBioView = nil
                self:updateSkinBtn()
                self:updateMemoiristBtn()
            end})
    end)
   
end

function HeroView:onChangeSkinButtonClicked()
    local _heroId = self._heroes._currentSelectedHero.id
    local isUnlockSkin =  not not self._heroes._currentSelectedHero.heroSkinID --self._heroes._currentSelectedHero.unlock and
    if not _heroId or not isUnlockSkin then
        return 
    end
    self._viewMgr:showDialog("hero.HeroSkinView",{isHaveHero = self._heroes._currentSelectedHero.unlock , heroData = self._heroes._currentSelectedHero,closeCallBack = function ( )
        local redImg = self._btn_change_skin:getChildByFullName("redNotice")
        if redImg then
            local isRedVisible = self._heroModel:isSkinHaveNoticeById(_heroId)
            redImg:setVisible(isRedVisible)
        end
        self:onSelected(self._heroes._currentSelectedHero, true, true)
        self:updateUI()
    end})

    --[[
    if not self._heroes._currentSelectedHero then return end
    print("change hero skin:", self._heroes._currentSelectedHero.id)
    local hero = self._heroes._currentSelectedHero
    if self._currentHero._data then
        self._currentHero._image:clear()
    end

    self._currentHero._data = hero

    local _hero = clone(hero)
    if hero.id == 60102 or hero.id == 60301 or hero.id == 60001 then
        local skin = SystemUtils.loadAccountLocalData("kaiselin_skin" .. hero.id)
        if skin == nil then
            skin = 0
        end
        if skin == 1 then
            skin = 0
        else
            skin = 1
        end
        SystemUtils.saveAccountLocalData("kaiselin_skin" .. hero.id, skin)
        _hero.skin = skin
    end

    self._currentHero._image = HeroSpine.new(self._layer, 5, hero.id, false, nil, nil, nil, _hero)
    local card = self._heroSelect:getCurrentSelectedCard()
    if card then
        card:setCardImage(1 == _hero.skin and self._heroes._currentSelectedHero.herobg .. "_01" or self._heroes._currentSelectedHero.herobg)
    end
    ]]
end

function HeroView:onCheckAttInfoButtonClicked()
    if not self._heroes._currentSelectedHero then return end
    if not self._attributeValues then
        self._attributeValues = BattleUtils.getHeroAttributes(clone(self._heroes._currentSelectedHero))
    end
    print("show hero attributes details:", self._heroes._currentSelectedHero.id)    
    self:closeHintView()
    self:showHintView("global.GlobalTipView",
    {   
        tipType = 3, node = self:getUI("bg.top_attribute_bg"),
        heroData = self._heroes._currentSelectedHero,
        attributes = self._attributeValues,
        posCenter = true,
    })
end

function HeroView:onDetailsViewClosed()
    self:topAttributeInfo(false)
    self:updateHeroData()
    self:onSelected(self._heroes._currentSelectedHero, true, true)
    self:updateUI()
    self:updateSlot()
end

function HeroView:onLoadButtonClicked()

end

function HeroView:onHide()
    self._viewMgr:disableScreenWidthBar()
    if self._heroSelect then
        self._heroSelect:unregisterHeroSelectViewTouchEvent()
    end
end

function HeroView:onDestroy()
    if self._topAttributeInfo then
        self._topAttributeInfo:removeFromParent()
        self._topAttributeInfo = nil
    end

    if self._soundTimerId then 
        self._scheduler:unscheduleScriptEntry(self._soundTimerId)
        self._soundTimerId = nil
    end

    if self._selectSoundId then
        audioMgr:stopSound(self._selectSoundId)
        self._selectSoundId = nil
    end

    self._viewMgr:disableScreenWidthBar()
end

return HeroView

--[==[
local FormationIconView = require("game.view.formation.FormationIconView")
local HeroSelectView = require("game.view.hero.HeroSelectView")
local HeroDetailsView = require("game.view.hero.HeroDetailsView")
local HeroSpine = require("game.view.hero.HeroSpine")

local HeroView = class("HeroView", BaseView)

HeroView.kHeroTag = 1000
HeroView.kHeroInformationTag = 2000
HeroView.kHeroEquipmentInformationTag = 3000

HeroView.kNormalZOrder = 500
HeroView.kLessNormalZOrder = HeroView.kNormalZOrder - 1
HeroView.kAboveNormalZOrder = HeroView.kNormalZOrder + 1
HeroView.kHighestZOrder = HeroView.kAboveNormalZOrder + 1

HeroView.kAttributeStep = 60

function HeroView:ctor(params)
    HeroView.super.ctor(self)
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
end

function HeroView:disableTextEffect(element)
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

function HeroView:onInit()
    self:disableTextEffect()
    self._bg = self:getUI("bg")
    self._btn_return = self:getUI("btn_return")
    self._layer = self:getUI("bg.layer")
    self._hero_description_bg = self:getUI("bg.layer.hero_description_bg")
    --[[
    self._specialName = self:getUI("bg.layer.hero_description_bg.label_specialty_name")
    self._specialName:setFontName(UIUtils.ttfName)
    self._attributeName = self:getUI("bg.layer.hero_description_bg.label_attribute")
    self._attributeName:setFontName(UIUtils.ttfName)
    ]]
    self._image_hero_specialty = self:getUI("bg.layer.hero_description_bg.image_hero_specialty")
    self._label_hero_description = self:getUI("bg.layer.hero_description_bg.label_hero_description")
    local size = cc.Director:getInstance():getVisibleSize()
    local layer = cc.Layer:create()
    self._btn_check = ccui.Button:create("btn_details_hero.png", "btn_details_s_hero.png", "btn_d_hero.png", 1)
    --[[
    self._btn_check:setTitleText("查看")
    self._btn_check:setTitleFontSize(18)
    self._btn_check:setTitleFontName(UIUtils.ttfName)
    self._btn_check:setColor(cc.c4b(255, 250, 220, 255))
    self._btn_check:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    ]]
    self._btn_check:setPosition(cc.p(self._btn_check:getContentSize().width / 2 + 5, size.height * 0.5))
    self._btn_check:setSwallowTouches(false)
    self._btn_check:setName("btn_check")
    layer:addChild(self._btn_check)
    self._btn_unlock = ccui.Button:create("btn_unlock_hero.png", "btn_unlock_hero_p.png", "btn_d_hero.png", 1)
    --[[
    self._btn_unlock:setTitleText("解锁")
    self._btn_unlock:setTitleFontSize(18)
    self._btn_unlock:setTitleFontName(UIUtils.ttfName)
    self._btn_unlock:setColor(cc.c4b(255, 250, 220, 255))
    self._btn_unlock:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    ]]
    self._btn_unlock:setPosition(cc.p(self._btn_unlock:getContentSize().width / 2 + 5, size.height / 2))
    self._btn_unlock:setSwallowTouches(false)
    self._btn_unlock:setName("btn_unlock")
    layer:addChild(self._btn_unlock)
    --self._btn_check = self:getUI("bg.layer.hero_description_bg.btn_check")
    --self._btn_unlock = self:getUI("bg.layer.hero_description_bg.btn_unlock")
    --self._layer_unlock = self:getUI("bg.layer.hero_description_bg.btn_unlock.layer_unlock")
    self._progressBarDurationTime = 0.3
    self._progressBar = {}
    self._progressBar._atk = self:getUI("bg.layer.hero_description_bg.label_atk.image_progress_bg.progress_bar")
    self._progressBar._atkValue = self:getUI("bg.layer.hero_description_bg.label_atk.label_atk_value")
    self._progressBar._atkValue:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    self._progressBar._def = self:getUI("bg.layer.hero_description_bg.label_def.image_progress_bg.progress_bar")
    self._progressBar._defValue = self:getUI("bg.layer.hero_description_bg.label_def.label_def_value")
    self._progressBar._defValue:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    self._progressBar._int = self:getUI("bg.layer.hero_description_bg.label_int.image_progress_bg.progress_bar")
    self._progressBar._intValue = self:getUI("bg.layer.hero_description_bg.label_int.label_int_value")
    self._progressBar._intValue:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    self._progressBar._ack = self:getUI("bg.layer.hero_description_bg.label_ack.image_progress_bg.progress_bar")
    self._progressBar._ackValue = self:getUI("bg.layer.hero_description_bg.label_ack.label_ack_value")
    self._progressBar._ackValue:enableOutline(cc.c4b(93, 93, 93, 255), 2)

    local word = self:getUI("bg.layer.hero_description_bg.label_atk")
    word:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    word = self:getUI("bg.layer.hero_description_bg.label_def")
    word:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    word = self:getUI("bg.layer.hero_description_bg.label_int")
    word:enableOutline(cc.c4b(93, 93, 93, 255), 2)
    word = self:getUI("bg.layer.hero_description_bg.label_ack")
    word:enableOutline(cc.c4b(93, 93, 93, 255), 2)

    --[[
    -- version 3.0
    self._btn_unlock = self:getUI("bg.layer.hero_description_bg.btn_unlock")
    self._image_unlock_gold = self:getUI("bg.layer.hero_description_bg.image_unlock_gold")
    self._label_unlock_gold_value = self:getUI("bg.layer.hero_description_bg.image_unlock_gold.label_unlock_gold_value")
    self._btn_load = self:getUI("bg.layer.hero_description_bg.btn_load")
    self._btn_load_image = self:getUI("bg.layer.hero_description_bg.btn_load.btn_load_image")
    self._btn_loaded_image = self:getUI("bg.layer.hero_description_bg.btn_load.btn_loaded_image")
    ]]
    
    self._scheduler = cc.Director:getInstance():getScheduler()

    self._heroes = {}
    self._heroes._data = self:initHeroData()
    --dump(self._heroes._data, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    self._heroes._currentSelectedHero = nil
    --self._heroes._currentLoadedHeroId = self._modelMgr:getModel("UserModel"):getData().currentHid or self._heroes._data[0].id -- version 3.0
    self._currentHero = {}
    self._currentHero._data = nil
    self._currentHero._image = nil
    self._currentHero._mp = nil
    self._nextHero = {}
    self._nextHero._data = nil
    self._nextHero._image = nil
    self._nextHero._mp = nil
    self._heroSelect = HeroSelectView.new({container = self, notifyTouchEvent = handler(self, self.notifyTouchEvent),angleSpace = 15.0, heroData = {data = self._heroes._data}})
    self._bg:addChild(self._heroSelect, 100)
    ---[[
    self._image_hero_specialty.tipOffset = cc.p(-265, 0)
    self:registerTouchEvent(self._image_hero_specialty, function(x, y)
        self:startClock(self._image_hero_specialty, self._heroes._currentSelectedHero)
    end,function(x, y) end, function(x, y) self:endClock() end, function(x, y) self:endClock() end)
    --]]
    self._labelHaveHero = ccui.Text:create("已获得英雄：", UIUtils.ttfName, 20)
    self._labelHaveHero:enableOutline(cc.c4b(65, 65, 65, 255), 2)
    self._labelHaveHero:setPosition(cc.p(size.width * 0.26, size.height * 0.1))
    layer:addChild(self._labelHaveHero)

    self._labelNowHero = ccui.Text:create(self:getCurrentHeroCount(), UIUtils.ttfName, 20)
    self._labelNowHero:setColor(cc.c3b(118, 238, 0))
    self._labelNowHero:enableOutline(cc.c4b(65, 65, 65, 255), 2)
    self._labelNowHero:setPosition(cc.p(self._labelHaveHero:getPositionX() + self._labelHaveHero:getContentSize().width / 2 + self._labelNowHero:getContentSize().width / 2, size.height * 0.1))
    layer:addChild(self._labelNowHero)

    self._labelTotalHero = ccui.Text:create("/" .. self:getTotalHeroCount(), UIUtils.ttfName, 20)
    self._labelTotalHero:enableOutline(cc.c4b(65, 65, 65, 255), 2)
    self._labelTotalHero:setPosition(cc.p(self._labelNowHero:getPositionX() + self._labelNowHero:getContentSize().width / 2 + self._labelTotalHero:getContentSize().width / 2, size.height * 0.1))
    layer:addChild(self._labelTotalHero)

    self._bg:addChild(layer, 110)

    self:registerClickEvent(self._btn_check, function(sender)
        self:onCheckButtonClicked()
    end)

    self:registerClickEvent(self._btn_return, function(sender)
        self:close()
    end)

    
    self:registerClickEvent(self._btn_unlock, function(sender)
        self:onUnlockButtonClicked()
    end)

    --[[
    self:registerClickEvent(self._btn_load, function(sender)
        self:onLoadButtonClicked()
    end)
    ]]
end

function HeroView:onAdd()
    -- 新手引导, 凯瑟琳1星+50个魂
    local heroData = self._heroModel:getData()
    if heroData["60102"] and heroData["60102"]["star"] == 1 then
        local _, count = self._itemModel:getItemsById(360102)
        if count >= 50 then
            GuideUtils.checkTriggerByType("action", "6")
        end
    end
end

function HeroView:getBgName()
    --return "bg_001.jpg"
end

--[[
function HeroView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", {hideBtn = true})
end
]]

function HeroView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function HeroView:initHeroData()
    local heroesData = {}
    local heroData = self._heroModel:getData()
    local heroTableData = clone(tab.hero)
    local currentLoadedHeroId = self._formationModel:getFormationDataByType(self._formationModel.kFormationTypeCommon).heroId
    local tn1 = {}
    local t0 = {}
    local t1 = {}
    local t2 = {}
   
    local findHeroData = function(key)
        for k, v in pairs(heroData) do
            if tonumber(k) == tonumber(key) then
                for i=1, 4 do
                    v["masteryLock" .. i] = false
                end
                if v.locks and v.locks ~= "" then
                    local locks = string.split(tostring(v.locks), ",")
                    for _, v0 in pairs(locks) do
                        v["masteryLock" .. v0] = true
                    end
                    v.locks = nil
                end
                return true, v
            end
        end
        return false
    end

    local isHeroLoaded = function(heroId)
        return tonumber(heroId) == tonumber(currentLoadedHeroId)
    end

    local isHeroCanUnlock = function(heroData)
        local _, have = self._itemModel:getItemsById(heroData.unlockcost[2])
        local consume = heroData.unlockcost[3]
        return have >= consume
    end

    for k0, v0 in pairs(heroTableData) do
        repeat
            if 0 == v0.visible then break end
            local isLoaded = isHeroLoaded(k0)
            local isCanUnlock = isHeroCanUnlock(v0)
            local found, data = findHeroData(k0)
            v0.unlock = false
            v0.canUnlock = false
            if not found and isCanUnlock then
                v0.canUnlock = true
                table.insert(t0, v0)
            elseif found then
                for k1, v1 in pairs(data) do
                    v0[tostring(k1)] = v1
                    v0.unlock = true
                end
                if isLoaded then
                    table.insert(tn1, v0)
                else
                    table.insert(t1, v0)
                end
            else
                table.insert(t2, v0)
            end
        until true
    end

    table.sort(tn1, function(a, b)
        return a.obseq < b.obseq
    end)

    table.sort(t0, function(a, b)
        return a.obseq < b.obseq
    end)

    table.sort(t1, function(a, b)
        return a.obseq < b.obseq
    end)

    table.sort(t2, function(a, b)
        return a.obseq < b.obseq
    end)

    local index = 0

    for _, v in ipairs(tn1) do
        heroesData[index] = v
        index = index + 1
    end

    for _, v in ipairs(t0) do
        heroesData[index] = v
        index = index + 1
    end

    for _, v in ipairs(t1) do
        heroesData[index] = v
        index = index + 1
    end

    for _, v in ipairs(t2) do
        heroesData[index] = v
        index = index + 1
    end

    return heroesData
end

function HeroView:unlockHero(result)
    for k, v in pairs(result) do
        for k0, v0 in pairs(self._heroes._data) do
            if v0.id == tonumber(k) then
                for k1, v1 in pairs(v) do
                    v0[k1] = v1
                end
                v0.unlock = true
                break
            end
        end
    end
end

function HeroView:getCurrentLoadedHeroId()
    --return self._heroes._currentLoadedHeroId
end

function HeroView:getCurrentHeroCount()
    local count = 0
    for _, v in pairs(self._heroes._data) do
        if v.unlock then
            count = count + 1
        end
    end
    return count
end

function HeroView:getTotalHeroCount()
    local count = 0
    for _, v in pairs(self._heroes._data) do
        count = count + 1
    end
    return count
end

function HeroView:updateUI()
    self._btn_check:setVisible(SystemUtils:enableHeroOpen() and self._heroes._currentSelectedHero.unlock)
    self._btn_unlock:setVisible(not self._heroes._currentSelectedHero.unlock)
    self._btn_unlock:setBright(self._heroes._currentSelectedHero.canUnlock)

    self._labelNowHero:setString(self:getCurrentHeroCount())
    self._labelTotalHero:setString("/" .. self:getTotalHeroCount())
    self._labelTotalHero:setPositionX(self._labelNowHero:getPositionX() + self._labelNowHero:getContentSize().width / 2 + self._labelTotalHero:getContentSize().width / 2)

    local cards = self._heroSelect:getAllCards()
    for _, card in ipairs(cards) do
        card:updateUI()
    end

    --[[
    self._image_unlock_gold:setVisible(not self._heroes._currentSelectedHero.unlock)
    self._btn_load:setVisible(self._heroes._currentSelectedHero.unlock)
    self._btn_load:setEnabled(self._heroes._currentLoadedHeroId ~= self._heroes._currentSelectedHero.id)
    self._btn_load:setBright(self._heroes._currentLoadedHeroId ~= self._heroes._currentSelectedHero.id)
    self._btn_load_image:setVisible(self._heroes._currentLoadedHeroId ~= self._heroes._currentSelectedHero.id)
    self._btn_loaded_image:setVisible(self._heroes._currentLoadedHeroId == self._heroes._currentSelectedHero.id)
    ]]
end

function HeroView:notifyTouchEvent(event)
    if self._heroSelect:isMidCardClicked() then return end
    if event == HeroSelectView.kTouchEventBegan then
        ScheduleMgr:delayCall(200, self, function()
            self._btn_check:setVisible(false)
            self._btn_check:setEnabled(false)
            self._btn_unlock:setVisible(false)
            self._btn_unlock:setEnabled(false)
            self._btn_return:setEnabled(false)
        end)
    else
        ScheduleMgr:delayCall(0, self, function()
            self._btn_check:setVisible(false)
            self._btn_check:setEnabled(false)
            self._btn_unlock:setVisible(false)
            self._btn_unlock:setEnabled(false)
            self._btn_return:setEnabled(false)
        end)
    end
end

function HeroView:onSelected(hero)
    print("on selected hero id", hero.id)
    self._heroes._currentSelectedHero = hero
    --self._specialName:setString(lang(tab.heroMastery(hero.special).name)) -- version 3.0
    self._btn_check:setVisible(false)
    self._btn_check:setEnabled(false)
    self._btn_unlock:setVisible(false)
    self._btn_unlock:setEnabled(false)
    self._btn_return:setEnabled(false)
    --[[
    local labelDiscription = self._layer_unlock
    local desc = lang(hero.prov)
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setTextAdditionalKerning(0)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    ]]
    --if self._currentHero._data and self._currentHero._data.herospine ~= hero.herospine or not self._currentHero._data then
    if self._currentHero._data and self._currentHero._data.heroport ~= hero.heroport or not self._currentHero._data then
        if self._currentHero._data then
            self._currentHero._image:clear()
        end

        self._currentHero._data = hero
        self._currentHero._image = HeroSpine.new(self._layer, 5, hero.id)
    end
    
    self._hero_description_bg:runAction(cc.Spawn:create(
        cc.Sequence:create(
            cc.FadeOut:create(0.1),
            cc.FadeIn:create(0.1)),
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(50.0, 0.0)), 2),
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(-50.0, 0.0)), 2)
        )))

    ScheduleMgr:delayCall(200, self, function()
        self._btn_check:setVisible(SystemUtils:enableHeroOpen() and hero.unlock)
        self._btn_check:setEnabled(true)
        self._btn_unlock:setVisible(not hero.unlock)
        self._btn_unlock:setEnabled(true)
        self._btn_unlock:setBright(self._heroes._currentSelectedHero.canUnlock)
        self._btn_return:setEnabled(true)
    end)

    local value = hero.atk[1] + (hero.star - 1) * hero.atk[2]
    local attributeMaxValue = hero.star * HeroView.kAttributeStep
    self._progressBar._atk:setPercent(value / attributeMaxValue * 100, self._progressBarDurationTime)
    self._progressBar._atkValue:setString(value)
    value = hero.def[1] + (hero.star - 1) * hero.def[2]
    self._progressBar._def:setPercent(value / attributeMaxValue * 100, self._progressBarDurationTime)
    self._progressBar._defValue:setString(value)
    value = hero.int[1] + (hero.star - 1) * hero.int[2]
    self._progressBar._int:setPercent(value / attributeMaxValue * 100, self._progressBarDurationTime)
    self._progressBar._intValue:setString(value)
    value = hero.ack[1] + (hero.star - 1) * hero.ack[2]
    self._progressBar._ack:setPercent(value / attributeMaxValue * 100, self._progressBarDurationTime)
    self._progressBar._ackValue:setString(value)

    -- version 4.0
    local findHeroSpecialFirstEffectData = function(specialBaseId)
        local specialTableData = clone(tab.heroMastery)
        for k, v in pairs(specialTableData) do
            if 1 == v.class and specialBaseId == v.baseid then
                return v
            end
        end
    end

    local heroMasteryData = findHeroSpecialFirstEffectData(hero.special)
    self._image_hero_specialty:loadTexture(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg", 1)

    --[[
    local heroMasteryData = tab:HeroMastery(hero.special)
    self._image_hero_specialty:loadTexture(IconUtils.iconPath .. heroMasteryData.icon .. ".jpg")
    ]]
    local labelDiscription = self._label_hero_description
    local desc = "[color=a78558, fontsize=20]" .. lang(hero.herodes) .. "[-]"
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)

    --self:updateUI() --version 3.0
end
--[=[
function HeroView:onSelected(hero)
    self._heroes._currentSelectedHero = hero
    --self._specialName:setString(lang(tab.heroMastery(hero.special).name)) -- version 3.0
    self._btn_check:setVisible(hero.unlock)
    self._btn_check:setTouchEnabled(false)
    self._btn_unlock:setVisible(not hero.unlock)
    local labelDiscription = self._layer_unlock
    local desc = lang(hero.prov)
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setTextAdditionalKerning(0)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    --self._btn_unlock:setTouchEnabled(false) --version 3.0
    if self._currentHero._data and self._currentHero._data.heroport ~= hero.heroport or not self._currentHero._data then
        if self._currentHero._data then
            local mp = self._currentHero._mp
            local image = self._currentHero._image
            mp:runAction(cc.FadeOut:create(0.1))
            image:runAction(cc.Sequence:create(
                cc.FadeOut:create(1), 
                cc.CallFunc:create(function()
                    image:removeFromParent()
            end)))
        end

        self._currentHero._data = hero
        self._currentHero._image = cc.Sprite:create("asset/uiother/hero/" .. hero.heroport .. ".jpg")
        self._currentHero._image:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2)
        self._currentHero._mp = cc.Sprite:createWithSpriteFrameName(hero.heromp .. ".png")
        self._currentHero._mp:setPosition(self._currentHero._image:getContentSize().width / 2 + hero.mppos[1], self._currentHero._image:getContentSize().height / 2 + hero.mppos[2])
        self._currentHero._mp:setOpacity(0)
        self._currentHero._image:addChild(self._currentHero._mp, 0)
        self._currentHero._image:setOpacity(0)
        self._layer:addChild(self._currentHero._image, 5)
        self._currentHero._mp:runAction(cc.FadeIn:create(0.2))
        self._currentHero._image:runAction(cc.FadeIn:create(1.2))
    end
    
    self._hero_description_bg:runAction(cc.Spawn:create(
        cc.Sequence:create(
            cc.FadeOut:create(0.1),
            cc.FadeIn:create(0.1)),
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(50.0, 0.0)), 2),
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(-50.0, 0.0)), 2),
            cc.CallFunc:create(function()
                self._btn_check:setTouchEnabled(true)
                --self._btn_unlock:setTouchEnabled(true) --version 3.0
    end))))

    self._progressBar._atk:setPercent(hero.atk / 20 * 100, self._progressBarDurationTime)
    self._progressBar._atkValue:setString(hero.atk)
    self._progressBar._def:setPercent(hero.def / 20 * 100, self._progressBarDurationTime)
    self._progressBar._defValue:setString(hero.def)
    self._progressBar._int:setPercent(hero.int / 20 * 100, self._progressBarDurationTime)
    self._progressBar._intValue:setString(hero.int)
    self._progressBar._ack:setPercent(hero.ack / 20 * 100, self._progressBarDurationTime)
    self._progressBar._ackValue:setString(hero.ack)

    local heroMasteryData = tab:HeroMastery(hero.special)
    self._image_hero_specialty:loadTexture(heroMasteryData.icon .. ".jpg", 1)

    local labelDiscription = self._label_hero_description
    local desc = "[color=a78558, fontsize=16]" .. lang(hero.herodes) .. "[-]"
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)

    --self:updateUI() --version 3.0
end
]=]
--[=[
function HeroView:onSelected(hero)
    self._heroes._currentSelectedHero = hero
    --self._specialName:setString(lang(tab.heroMastery(hero.special).name)) -- version 3.0
    self._btn_check:setVisible(hero.unlock)
    self._btn_check:setTouchEnabled(false)
    self._btn_unlock:setVisible(not hero.unlock)
    local labelDiscription = self._layer_unlock
    local desc = lang(hero.prov)
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setTextAdditionalKerning(0)
    richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    --self._btn_unlock:setTouchEnabled(false) --version 3.0
    if self._currentHero._data then
        self._currentHero._mp:runAction(cc.FadeOut:create(0.1))
        --self._currentHero._image:runAction(cc.Sequence:create(
            --cc.FadeOut:create(1), 
            --cc.CallFunc:create(function()
                if self._currentHero._image then
                    if self._currentHero._image.clearHeroSpine then
                        self._currentHero._image:clearHeroSpine()
                    end
                    self._currentHero._image:removeFromParent()
                end
                self._currentHero = nil
                self._currentHero = {}
       --end)))
    end
    if true then
    self._nextHero._data = hero
    self._nextHero._image = HeroSpine.new(hero.id)
    self._nextHero._image:setPosition(self._bg:getContentSize().width / 1.3, 0)
    self._nextHero._mp = cc.Sprite:createWithSpriteFrameName(hero.heromp .. ".png")
    self._nextHero._mp:setPosition(self._bg:getContentSize().width / 2 + hero.mppos[1], self._bg:getContentSize().height / 2 + hero.mppos[2])
    self._nextHero._mp:setOpacity(0)
    self._bg:addChild(self._nextHero._mp, 0)
    self._layer:addChild(self._nextHero._image, 5)
    self._nextHero._mp:runAction(cc.FadeIn:create(0.2))
    --self._nextHero._image:runAction(cc.Sequence:create(
            --cc.FadeIn:create(1.2), 
            --cc.CallFunc:create(function()
                self._currentHero = self._nextHero
                self._nextHero = nil
                self._nextHero = {}
        --end)))
    else
    self._nextHero._data = hero
    self._nextHero._image = cc.Sprite:create("asset/uiother/hero/" .. hero.heroport .. ".jpg")
    self._nextHero._image:setPosition(self._bg:getContentSize().width / 2, self._bg:getContentSize().height / 2)
    self._nextHero._mp = cc.Sprite:createWithSpriteFrameName(hero.heromp .. ".png")
    self._nextHero._mp:setPosition(self._nextHero._image:getContentSize().width / 2 + hero.mppos[1], self._nextHero._image:getContentSize().height / 2 + hero.mppos[2])
    self._nextHero._mp:setOpacity(0)
    self._nextHero._image:addChild(self._nextHero._mp, 0)
    self._nextHero._image:setOpacity(0)
    self._layer:addChild(self._nextHero._image, 5)
    self._nextHero._mp:runAction(cc.FadeIn:create(0.2))
    self._nextHero._image:runAction(cc.Sequence:create(
            cc.FadeIn:create(1.2), 
            cc.CallFunc:create(function()
                self._currentHero = self._nextHero
                self._nextHero = nil
                self._nextHero = {}
        end)))
    end
    self._hero_description_bg:runAction(cc.Spawn:create(
        cc.Sequence:create(
            cc.FadeOut:create(0.1),
            cc.FadeIn:create(0.1)),
        cc.Sequence:create(
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(50.0, 0.0)), 2),
            cc.EaseOut:create(cc.MoveBy:create(0.05, cc.p(-50.0, 0.0)), 2),
            cc.CallFunc:create(function()
                self._btn_check:setTouchEnabled(true)
                --self._btn_unlock:setTouchEnabled(true) --version 3.0
    end))))

    self._progressBar._atk:setPercent(hero.atk / 20 * 100, self._progressBarDurationTime)
    self._progressBar._atkValue:setString(hero.atk)
    self._progressBar._def:setPercent(hero.def / 20 * 100, self._progressBarDurationTime)
    self._progressBar._defValue:setString(hero.def)
    self._progressBar._int:setPercent(hero.int / 20 * 100, self._progressBarDurationTime)
    self._progressBar._intValue:setString(hero.int)
    self._progressBar._ack:setPercent(hero.ack / 20 * 100, self._progressBarDurationTime)
    self._progressBar._ackValue:setString(hero.ack)

    local heroMasteryData = tab:HeroMastery(hero.special)
    self._image_hero_specialty:loadTexture(heroMasteryData.icon .. ".jpg", 1)

    local labelDiscription = self._label_hero_description
    local desc = "[color=a78558, fontsize=18]" .. lang(hero.herodes) .. "[-]"
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

    --self:updateUI() --version 3.0
end
]=]
function HeroView:onIconPressOn(node, heroData)
    if not heroData then return end
    self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = heroData.special,heroData = clone(heroData), des = BattleUtils.getDescription(BattleUtils.kIconTypeHeroSpecialty, heroData.special, self._attributeValues)})
end

function HeroView:onIconPressOff()
    --self:closeHintView()
end

function HeroView:startClock(node, heroData)
    if self._timer_id then self:endClock() end
    self._first_tick = true
    -- self._timer_id = self._scheduler:scheduleScriptFunc(function()
    --     if not self._first_tick then return end
    --     self._first_tick = false
        self:onIconPressOn(node, heroData)
    -- end, 0.2, false)
end

function HeroView:endClock()
   if self._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._timer_id)
        self._timer_id = nil
    end
     self:onIconPressOff()
end

function HeroView:onCheckButtonClicked()
    print("current check hero id is", self._heroes._currentSelectedHero.id)
    self._viewMgr:showDialog("hero.HeroDetailsView", {container = self, heroData = self._heroes._currentSelectedHero}, true)
end

function HeroView:onUnlockButtonClicked()
    local _, have = self._itemModel:getItemsById(self._heroes._currentSelectedHero.unlockcost[2])
    local consume = self._heroes._currentSelectedHero.unlockcost[3]
    if have < consume then
        self._viewMgr:showTip(lang("TIPS_HEROUNLOCK_1"))
        return 
    end

    local context = {heroId = self._heroes._currentSelectedHero.id}
    --dump(context, "context")
    self._serverMgr:sendMsg("HeroServer", "unlockHero", context, true, {}, function(result)
        self._heroModel:unlockHero(result["d"]["heros"])
        self:unlockHero(result["d"]["heros"])

        if result["unset"] ~= nil then 
            local removeItems = self._itemModel:handelUnsetItems(result["unset"])
            self._itemModel:delItems(removeItems, true)
        end

        if result["d"].items then
            self._itemModel:updateItems(result["d"].items)
            result["d"].items = nil
        end

        local heroUnlockLayer = self._viewMgr:createLayer("hero.HeroUnlockView", {heroId = self._heroes._currentSelectedHero.id, callBack = function()
            local card = self._heroSelect:getCurrentSelectedCard()
            if card then
                card:setUnlock(true)
            end
            self:updateUI()
        end})

        self:getLayerNode():addChild(heroUnlockLayer)
    end)
end

function HeroView:onDetailsViewClosed()
    self:updateUI()
end

function HeroView:onLoadButtonClicked()
    --[[
    -- version 3.0
    local context = {heroId = self._heroes._currentSelectedHero.id}
    --dump(context, "context")
    self._serverMgr:sendMsg("HeroServer", "setWarHero", context, true, {}, function(result) 
        --dump(result, "refresh data")
        local oldLoadedHeroId = self._heroes._currentLoadedHeroId
        local oldCard = self._heroSelect:getCardById(oldLoadedHeroId)
        if oldCard then
            oldCard:setLoaded(false)
        end 
        self._heroes._currentLoadedHeroId = self._heroes._currentSelectedHero.id
        local card = self._heroSelect:getCurrentSelectedCard()
        if card then
            card:setLoaded(true)
        end

        self._modelMgr:getModel("UserModel"):setWarHero(self._heroes._currentLoadedHeroId)
        self:updateUI()
    end)
    ]]
end

return HeroView
]==]