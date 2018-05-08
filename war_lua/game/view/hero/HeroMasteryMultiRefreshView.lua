--[[
    Filename:    HeroMasteryMultiRefreshView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-04-21 21:56:29
    Description: File description
--]]

local FormationIconView = require("game.view.formation.FormationIconView")

local HeroMasteryMultiRefreshView = class("HeroMasteryMultiRefreshView", BasePopView)

HeroMasteryMultiRefreshView.kMasteryTag = 1000
HeroMasteryMultiRefreshView.kMasteryIteamTag = 2000

HeroMasteryMultiRefreshView.kNormalZOrder = 500
HeroMasteryMultiRefreshView.kLessNormalZOrder = HeroMasteryMultiRefreshView.kNormalZOrder - 1
HeroMasteryMultiRefreshView.kAboveNormalZOrder = HeroMasteryMultiRefreshView.kNormalZOrder + 1
HeroMasteryMultiRefreshView.kHighestZOrder = HeroMasteryMultiRefreshView.kAboveNormalZOrder + 1

HeroMasteryMultiRefreshView.kHeroLocked = "mastery_locked_hero.png"
HeroMasteryMultiRefreshView.kHeroUnlocked = "mastery_unlocked_hero.png"
HeroMasteryMultiRefreshView.kHeroLockDisabled = "mastery_lock_disabled_hero.png"


function HeroMasteryMultiRefreshView:ctor(params)
    HeroMasteryMultiRefreshView.super.ctor(self)
    self._container = params.container
    self._heroData = params.heroData
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
end

function HeroMasteryMultiRefreshView:disableTextEffect(element)
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

function HeroMasteryMultiRefreshView:onInit()
    self:disableTextEffect()

    dump(self._heroData, "self._heroData", 5)

    self._is_refresh_btn_clicked = false

    local formationData = self._formationModel:getFormationDataByType(self._formationModel.kFormationTypeCommon)
    self._isHeroLoaded = formationData and formationData.heroId == self._heroData.id

    self._labelTitle = self:getUI("bg.layer.image_title_bg.label_title")
    self._labelTitle:setFontName(UIUtils.ttfName_Title)
    self._labelTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._layerMasteryRefresh = self:getUI("bg.layer.layer_current")

    self._currentMastery = {}
    for i=1, 4 do
        self._currentMastery[i] = {}
        self._currentMastery[i]._value = self._heroData["m" .. i]
        self._currentMastery[i]._image = self:getUI("bg.layer.layer_current.layer_icon_" .. i)
        self._currentMastery[i]._image_recommand = self:getUI("bg.layer.layer_current.image_recommand_" .. i)
        self._currentMastery[i]._lock = self._heroData["masteryLock" .. i]
        self._currentMastery[i]._imageLock = self:getUI("bg.layer.layer_current.layer_icon_" .. i .. ".image_lock")
        self:registerClickEvent(self._currentMastery[i]._imageLock, function()
           self:onLockButtonClicked(i)
        end)
    end

    self._selectedNewMasteryIndex = 0
    self._recommandIndex = 0
    self._newestMastery = {}
    self._newestMasteryScrollView = self:getUI("bg.layer.layer_new.scrollview")
    for i=1, 10 do
        self._newestMastery[i] = {}
        self._newestMastery[i]._layer = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i)
        self:registerClickEvent(self._newestMastery[i]._layer, function()
            if not self._is_refresh_btn_clicked then
                return
            end
            self:onNewMasterySelected(i)
        end)
        self._newestMastery[i]._checkBoxSelect = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i .. ".checkbox_select")
        self._newestMastery[i]._checkBoxSelect:setTouchEnabled(false)
        self._newestMastery[i]._checkBoxSelect:setSelected(false)
        self._newestMastery[i]._imageSelect = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i .. ".image_selected")
        self._newestMastery[i]._imageSelect:setVisible(false)
        self._newestMastery[i]._imageReset = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i .. ".image_reset")
        self._newestMastery[i]._layerIcon = {}
        for j=1, 4 do
            self._newestMastery[i]._layerIcon[j] = {}
            self._newestMastery[i]._layerIcon[j]._image = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i .. ".layer_icon_" .. j)
            self._newestMastery[i]._layerIcon[j]._image_recommand = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i .. ".layer_icon_" .. j .. ".image_recommand")
            self._newestMastery[i]._layerIcon[j]._value = self._currentMastery[j]._value
            self._newestMastery[i]._layerIcon[j]._labelName = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i .. ".layer_icon_" .. j .. ".label_mastery")
            self._newestMastery[i]._layerIcon[j]._labelLevel = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i .. ".layer_icon_" .. j .. ".label_mastery_level")
        end 
        self._newestMastery[i]._imageRecommand = self:getUI("bg.layer.layer_new.scrollview.layer_item_" .. i .. ".image_flag")
    end


    local _, scrollNum = self._itemModel:getItemsById(3015)
    self._imageConsumeScroll = self:getUI("bg.layer.layer_bottom.image_consume_scroll")
    self._labelConsumeScrollValue1 = self:getUI("bg.layer.layer_bottom.image_consume_scroll.label_consume_1")
    self._labelConsumeScrollValue = self:getUI("bg.layer.layer_bottom.image_consume_scroll.label_consume_value")
    self._labelConsumeScrollValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._labelConsumeScrollValue2 = self:getUI("bg.layer.layer_bottom.image_consume_scroll.label_consume_2")

    self._refreshConsume = tab:Setting("G_MASTERY_REFRESH").value
    self._imageConsume = self:getUI("bg.layer.layer_bottom.layer_consume_gold")
    self._labelConsumeGoldValue = self:getUI("bg.layer.layer_bottom.layer_consume_gold.image_gold.label_gold")
    self._labelConsumeValue = self:getUI("bg.layer.layer_bottom.layer_consume_gold.image_diamond.label_diamond")

    self._isScrollSelected = scrollNum >= 10
    if 1 == SystemUtils.loadAccountLocalData("HERO_MASTERY_MULTI_REFRESH_SELECTED") then
        self._isScrollSelected = true
    elseif 0 == SystemUtils.loadAccountLocalData("HERO_MASTERY_MULTI_REFRESH_SELECTED") then
        self._isScrollSelected = false
    end
    self._checkBoxConsumeScroll = self:getUI("bg.layer.layer_bottom.image_consume_scroll.check_box_scroll")
    self._checkBoxConsumeScroll:setSelected(self._isScrollSelected)
    self:registerClickEvent(self._checkBoxConsumeScroll, function()
        self._isScrollSelected = not self._isScrollSelected
        self._imageConsume:setVisible(not self._isScrollSelected)
    end)

    self._btn_refresh = self:getUI("bg.layer.layer_bottom.btn_refresh")
    self._btn_change = self:getUI("bg.layer.layer_bottom.btn_change")
    self._btn_cancel = self:getUI("bg.layer.layer_bottom.btn_cancel")

    self:registerClickEvent(self._btn_refresh, function()
        self:onButtonRefreshClicked()
    end)

    self:registerClickEvent(self._btn_change, function()
        self:onButtonChangeClicked()
    end)

    self:registerClickEvent(self._btn_cancel, function()
        self:onButtonCancelClicked()
    end)

    self:updateUI()

    self:registerScriptHandler(function(state)
        if state == "exit" then
            SystemUtils.saveAccountLocalData("HERO_MASTERY_MULTI_REFRESH_SELECTED", self._isScrollSelected and 1 or 0)
        end 
    end)

    self:registerClickEventByName("bg.layer.btn_close", function ()
        local doClose = function()
            if self._container and self._container.onHeroMasteryMultiRefreshViewClose and type(self._container.onHeroMasteryMultiRefreshViewClose) == "function" then
                self._container:onHeroMasteryMultiRefreshViewClose()
            end
            self:close()
        end

        if self._is_refresh_btn_clicked then
            self._viewMgr:showSelectDialog(lang("TIPS_MASTERYREFLASH_3"), "", function()
                doClose()
            end, "")
            return
        end

        doClose()
    end)
end

function HeroMasteryMultiRefreshView:updateUI()
    self:updateCurrentMastery()
    self:updateNewMastery(true)
    self:visableLockImage()
end

function HeroMasteryMultiRefreshView:updateMasteryRefreshConsumeInfo()
    local _, scrollNum = self._itemModel:getItemsById(3015)
    self._imageConsumeScroll:setVisible(scrollNum >= 10)
    self._labelConsumeScrollValue:setString(scrollNum)
    self._labelConsumeScrollValue:setPositionX(self._labelConsumeScrollValue1:getPositionX() + self._labelConsumeScrollValue1:getContentSize().width + 3)
    self._labelConsumeScrollValue2:setPositionX(self._labelConsumeScrollValue:getPositionX() + self._labelConsumeScrollValue:getContentSize().width + 3)

    self._imageConsume:setVisible((not self._isScrollSelected or scrollNum < 10))
    local consume = self._refreshConsume[self:getLockedCount() + 1][1] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22)) * 10
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    if totalGem < consume then
        self._labelConsumeValue:setColor(cc.c3b(255, 0, 0))
    else
        self._labelConsumeValue:setColor(cc.c3b(130, 85, 40))
    end
    self._labelConsumeValue:setString(consume)
    local consumeGold = self._refreshConsume[self:getLockedCount() + 1][2] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22)) * 10
    local totalGold = self._modelMgr:getModel("UserModel"):getData().gold
    if totalGold < consumeGold then
        self._labelConsumeGoldValue:setColor(cc.c3b(255, 0, 0))
    else
        self._labelConsumeGoldValue:setColor(cc.c3b(130, 85, 40))
    end
    self._labelConsumeGoldValue:setString(consumeGold)
end

function HeroMasteryMultiRefreshView:updateCurrentMastery()

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
        repeat
            local dataCurrent = tab:HeroMastery(self._currentMastery[i]._value)
            if not dataCurrent then break end
            local iconGrid = self._currentMastery[i]._image
            local icon = iconGrid:getChildByTag(HeroMasteryMultiRefreshView.kMasteryTag)
            if not icon then
                icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataCurrent.id, container = { _container = self }, })
                icon:setScale(0.85)
                icon:setScaleAnim(true)
                icon:setPosition(iconGrid:getContentSize().width / 2 , iconGrid:getContentSize().height / 2)
                icon:setTag(HeroMasteryMultiRefreshView.kMasteryTag)
                iconGrid:addChild(icon)
            end 
            icon = iconGrid:getChildByTag(HeroMasteryMultiRefreshView.kMasteryTag)
            icon:setIconType(FormationIconView.kIconTypeHeroMastery)
            icon:setIconId(dataCurrent.id)
            icon:updateIconInformation()
            self:updateLockImage(i)

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

        until true
    end
    self:updateMasteryRefreshConsumeInfo()
end

function HeroMasteryMultiRefreshView:getLockedCount()
    local lockedCount = 0
    for i=1, 4 do
        if self._currentMastery[i]._lock then
            lockedCount = lockedCount + 1
        end
    end
    return lockedCount
end

function HeroMasteryMultiRefreshView:onLockButtonClicked(index)
    if self._is_refresh_btn_clicked then return end

    if not self._currentMastery[index]._lock then
        local vipLevel = self._vipModel:getData().level
        if self:getLockedCount() >= tab.vip[vipLevel].refreshLock then
            self._viewMgr:showTip(lang("TiPS_VIP_MASTERY_" .. (tab.vip[vipLevel].refreshLock + 1)))
            return
        end
    end
    
    self._currentMastery[index]._lock = not self._currentMastery[index]._lock
    self._heroData["masteryLock" .. index] = self._currentMastery[index]._lock

    local lockedCount = self:getLockedCount()
    self:visableLockImage()
    local consume = self._refreshConsume[lockedCount + 1][1] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22)) * 10
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    if totalGem < consume then
        self._labelConsumeValue:setColor(cc.c3b(255, 0, 0))
    else
        self._labelConsumeValue:setColor(cc.c3b(130, 85, 40))
    end
    self._labelConsumeValue:setString(consume)

    local consumeGold = self._refreshConsume[lockedCount + 1][2] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22)) * 10
    local totalGold = self._modelMgr:getModel("UserModel"):getData().gold
    if totalGold < consumeGold then
        self._labelConsumeGoldValue:setColor(cc.c3b(255, 0, 0))
    else
        self._labelConsumeGoldValue:setColor(cc.c3b(130, 85, 40))
    end
    self._labelConsumeGoldValue:setString(consumeGold)

    self:updateLockImage(index)
end

function HeroMasteryMultiRefreshView:visableLockImage()
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

function HeroMasteryMultiRefreshView:updateLockImage(index)
    local lock = self._currentMastery[index]._lock
    if self._is_refresh_btn_clicked then
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroLockDisabled, 1)
    elseif lock then
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroLocked, 1)
    else
        self._currentMastery[index]._imageLock:loadTexture(self.kHeroUnlocked, 1)
    end
end

function HeroMasteryMultiRefreshView:updateButtonStatus(isRefresh)
    self._is_refresh_btn_clicked = isRefresh
    for i=1, 4 do
        self:updateLockImage(i) 
    end
    self._btn_refresh:setVisible(not isRefresh)
    self._btn_change:setVisible(isRefresh)
    self._btn_cancel:setVisible(isRefresh)
end

function HeroMasteryMultiRefreshView:onButtonRefreshClicked()

    local lockedCount = self:getLockedCount()
    local consume = self._refreshConsume[lockedCount + 1][1] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22)) * 10
    local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
    local consumeGold = self._refreshConsume[lockedCount + 1][2] * (1 + self._activityModel:getAbilityEffect(self._activityModel.PrivilegIDs.PrivilegID_22)) * 10
    local totalGold = self._userModel:getData().gold
    local _, scrollNum = self._itemModel:getItemsById(3015)
    if (not self._isScrollSelected or scrollNum < 10) and (consume > totalGem or consumeGold > totalGold) then
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
                    self:updateUI()
                end})
            end})
        elseif consumeGold > totalGold then
            DialogUtils.showBuyRes({goalType="gold", callback = function()
                if self._container and self._container.showTopInfo and type(self._container.showTopInfo) == "function" then
                    self._container:showTopInfo(true)
                end
                self:updateUI()
            end})
        end
        return 
    end

    self._btn_refresh:setEnabled(false)
    self._btn_refresh:setBright(false)

    local context = {heroId = self._heroData.id, args = {locks = {}, reduceType = (self._isScrollSelected and scrollNum >= 10) and 1 or 0, refreshNum = 10}}
    for i=1, 4 do
        if self._currentMastery[i]._lock then
            context.args.locks[#context.args.locks+1] = i
        end
    end

    context["args"] = json.encode(context["args"])
    ScheduleMgr:delayCall(400, self, function()
        self._serverMgr:sendMsg("HeroServer", "refreshMastery", context, true, {}, function(result) 
            -- dump(result, "refresh data", 5)
            self:updateButtonStatus(true)

            self._btn_refresh:setEnabled(true)
            self._btn_refresh:setBright(true)

            for i=1, 10 do
                for j=1, 4 do
                    if not self._currentMastery[j]._lock then
                        self._newestMastery[i]._layerIcon[j]._value = result["list"][i][tostring(j)]
                    end
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

            self:updateNewMastery()
            self._viewMgr:lock(-1)
            self:showNewMasteryEffect(function()
                self:scrollToRecommand()
                self._viewMgr:unlock()
            end)
        end)
    end)
end

function HeroMasteryMultiRefreshView:onButtonChangeClicked()
    self._btn_change:setEnabled(false)
    self._btn_change:setBright(false)
    self._btn_cancel:setEnabled(false)
    self._btn_cancel:setBright(false)
    -- print("onButtonChangeClicked")

    self._recommandIndex = 0

    local index = self._selectedNewMasteryIndex
    if 0 == index then
        self._btn_change:setEnabled(true)
        self._btn_change:setBright(true)
        self._btn_cancel:setEnabled(true)
        self._btn_cancel:setBright(true)
        self._viewMgr:showTip(lang("TIPS_MASTERYREFLASH_4"))
        return
    end

    self:scrollByIndex(index)

    --[[
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
    ]]

    local oldScore = self._heroData.score  -- addBy guojun 弹战斗力动画
    -- dump(self._heroData,"herodata ,,,,before....",10)
    self._modelMgr:getModel("HeroModel"):saveMastery(self._heroData, index, function(success)

        if not success then
            self._viewMgr:showTip(lang("TIPS_MASTERYREFLASH_5"))
            return
        end

        for i=1, 4 do
            if not self._heroData["masteryLock" .. i] then
                self._currentMastery[i]._value = self._newestMastery[index]._layerIcon[i]._value
                self._heroData["m" .. i] = self._currentMastery[i]._value
            end
        end

        for i=1, 4 do
        if not self._heroData["masteryLock" .. i] then
            local dataNewest = tab:HeroMastery(self._newestMastery[index]._layerIcon[i]._value)
            local icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataNewest.id, container = { _container = self } })
            icon:setScaleAnim(false)
            icon:enableTouch(false)
            local position1 = cc.p(self._newestMastery[index]._layerIcon[i]._image:getPositionX() + self._newestMastery[index]._layerIcon[i]._image:getContentSize().width / 2, self._newestMastery[index]._layerIcon[i]._image:getPositionY() + self._newestMastery[index]._layerIcon[i]._image:getContentSize().height / 2)
            position1 = self._newestMastery[index]._layerIcon[i]._image:getParent():convertToWorldSpace(position1)
            position1 = self._layerMasteryRefresh:convertToNodeSpace(position1)
            icon:setPosition(position1)
            local position2 = cc.p(self._currentMastery[i]._image:getPositionX() + self._currentMastery[i]._image:getContentSize().width / 2, self._currentMastery[i]._image:getPositionY() + self._currentMastery[i]._image:getContentSize().height / 2)
            position2 = self._currentMastery[i]._image:getParent():convertToWorldSpace(position2)
            position2 = self._layerMasteryRefresh:convertToNodeSpace(position2)
            self._layerMasteryRefresh:addChild(icon, 20)
            icon:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.1), 2),
                cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(position2)), 2),
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.2), 2),
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 0.85), 2),
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
                    icon:setVisible(false)
                    icon:removeFromParentAndCleanup(true)
            end)))
        end
    end

        self:updateButtonStatus(false)
        self._btn_change:setEnabled(true)
        self._btn_change:setBright(true)
        self._btn_cancel:setEnabled(true)
        self._btn_cancel:setBright(true)
        --self._container:updateAttributes(true)
        self:updateCurrentMastery()
        self:resetNewMastery()
        local newScore = self._heroData.score -- addBy guojun 弹战斗力动画
        -- print("newScore,oldScore",newScore,oldScore)
        self:popScoreChangeAnim( oldScore,newScore ) -- addBy guojun 弹战斗力动画
    end)
end

-- 战斗力变化动画
function HeroMasteryMultiRefreshView:popScoreChangeAnim( old,new )
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

function HeroMasteryMultiRefreshView:onButtonCancelClicked()
    local doCancel = function()
        self:updateButtonStatus(false)
        self:updateUI()
        self:resetNewMastery()
    end
    local found = false
    for i=1, 10 do
        for j=1, 4 do
            if not self._currentMastery[j]._lock then
                local masteryData = tab:HeroMastery(self._newestMastery[i]._layerIcon[j]._value)
                if masteryData.masterylv >= 3 then
                    found = true
                    break
                end
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
    self._recommandIndex = 0
end

function HeroMasteryMultiRefreshView:resetNewMastery()
    for i=1, 10 do
        for j=1, 4 do
            self._newestMastery[i]._layerIcon[j]._value = self._currentMastery[j]._value
        end
    end
    self:updateNewMastery(true)
    self:onNewMasterySelected(0)
    self:scrollByIndex(1)
end

function HeroMasteryMultiRefreshView:updateNewMastery(isReset)
    self._newestMasteryScrollView:setVisible(not isReset)

    local recommandMasteryData = self._heroData.recmastery

    local isMasteryGlobal = function(masteryId)
        local masteryData = tab:HeroMastery(masteryId)
        return masteryData and 1 == masteryData.global
    end

    local isNewestRecommand = function(index, newMasteryId)
        local masteryCurrentData = tab:HeroMastery(self._currentMastery[index]._value)
        local masteryNewestData = tab:HeroMastery(newMasteryId)
        for i = 1, #recommandMasteryData do
            if recommandMasteryData[i] == masteryNewestData.baseid and masteryNewestData.masterylv >= 2 and not (masteryCurrentData.baseid == masteryNewestData.baseid and masteryCurrentData.masterylv > masteryNewestData.masterylv) then
                return true
            end
        end
        return false
    end

    for i=1, 10 do
        self._newestMastery[i]._imageReset:setVisible(not not isReset)
        for j=1, 4 do
            repeat
                local dataNewest = tab:HeroMastery(self._newestMastery[i]._layerIcon[j]._value)
                if not dataNewest then break end
                local iconGrid = self._newestMastery[i]._layerIcon[j]._image
                local icon = iconGrid:getChildByTag(HeroMasteryMultiRefreshView.kMasteryTag)
                if not icon then
                    icon = FormationIconView.new({ iconType = FormationIconView.kIconTypeHeroMastery, iconId = dataNewest.id, container = { _container = self } })
                    icon:setScale(0.85)
                    icon:setScaleAnim(true)
                    icon:setPosition(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2)
                    icon:setTag(HeroMasteryMultiRefreshView.kMasteryTag)
                    iconGrid:addChild(icon)
                end 
                icon = iconGrid:getChildByTag(HeroMasteryMultiRefreshView.kMasteryTag)
                icon:setIconType(FormationIconView.kIconTypeHeroMastery)
                icon:setIconId(dataNewest.id)
                icon:updateIconInformation()

                self._newestMastery[i]._layerIcon[j]._labelName:setString(lang(dataNewest.name))

                local currentLv = dataNewest.masterylv
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
                    self._newestMastery[i]._layerIcon[j]._labelLevel:setString(levelName)    
                end
                self._newestMastery[i]._layerIcon[j]._labelLevel:setColor(color)
                self._newestMastery[i]._layerIcon[j]._labelName:setColor(color)
                if outlineColor then
                    self._newestMastery[i]._layerIcon[j]._labelLevel:enableOutline(outlineColor, 1)
                    self._newestMastery[i]._layerIcon[j]._labelName:enableOutline(outlineColor, 1)
                else
                    self._newestMastery[i]._layerIcon[j]._labelLevel:disableEffect()
                    self._newestMastery[i]._layerIcon[j]._labelName:disableEffect()
                end

                local isRecommend = recommandMasteryData and isNewestRecommand(j, dataNewest.id)
                local isGlobal = isMasteryGlobal(dataNewest.id)
                if self._is_refresh_btn_clicked then
                    if self._isHeroLoaded then
                        if isRecommend then
                            self._newestMastery[i]._layerIcon[j]._image_recommand:setVisible(true)
                            self._newestMastery[i]._layerIcon[j]._image_recommand:loadTexture("mastery_recommand_hero.png", 1)
                        elseif isGlobal then
                            self._newestMastery[i]._layerIcon[j]._image_recommand:setVisible(true)
                            self._newestMastery[i]._layerIcon[j]._image_recommand:loadTexture("mastery_global_hero.png", 1)
                        else
                            self._newestMastery[i]._layerIcon[j]._image_recommand:setVisible(false)
                        end
                    else
                        if isGlobal then
                            self._newestMastery[i]._layerIcon[j]._image_recommand:setVisible(true)
                            self._newestMastery[i]._layerIcon[j]._image_recommand:loadTexture("mastery_global_hero.png", 1)
                        elseif isRecommend then
                            self._newestMastery[i]._layerIcon[j]._image_recommand:setVisible(true)
                            self._newestMastery[i]._layerIcon[j]._image_recommand:loadTexture("mastery_recommand_hero.png", 1)
                        else
                            self._newestMastery[i]._layerIcon[j]._image_recommand:setVisible(false)
                        end
                    end
                else
                    self._newestMastery[i]._layerIcon[j]._image_recommand:setVisible(false)
                end

            until true
        end
    end
end

function HeroMasteryMultiRefreshView:showNewMasteryEffect(callback)
    self._newestMasteryScrollView:jumpToTop()
    --self._newestMasteryScrollView:scrollToBottom(0.5, true)
    for i=1, 10 do
        local layer = self._newestMastery[i]._layer
        layer:setOpacity(100)
    end

    for i=1, 10 do
        local layer = self._newestMastery[i]._layer
        layer:runAction(cc.Sequence:create(cc.DelayTime:create(i * 0.05), cc.CallFunc:create(function()
            audioMgr:playSound("adTag")
            self._newestMasteryScrollView:scrollToPercentVertical(i / 10 * 100, 0.1, true)
        end), cc.Spawn:create(cc.FadeIn:create(0.1), cc.MoveBy:create(0.1, cc.p(0, 50))), cc.MoveBy:create(0.1, cc.p(0, -50)), cc.DelayTime:create(0.1), cc.CallFunc:create(function()
            if i < 10 then return end
            callback()
        end)))
    end
end

function HeroMasteryMultiRefreshView:onNewMasterySelected(index)
    self._selectedNewMasteryIndex = index
    for i=1, 10 do
        self._newestMastery[i]._checkBoxSelect:setSelected(i == index)
        self._newestMastery[i]._imageSelect:setVisible(i == index)
        self._newestMastery[i]._imageRecommand:setVisible(i == self._recommandIndex)
    end
end

function HeroMasteryMultiRefreshView:scrollByIndex(index)
    if index <= 3 then
        --return self._newestMasteryScrollView:scrollToTop(0.1, true)
        return self._newestMasteryScrollView:jumpToTop()
    end
    self._newestMasteryScrollView:scrollToPercentVertical(index / 10 * 100, 0.1, true)
end

function HeroMasteryMultiRefreshView:scrollToRecommand()
    local sumWeight = {}
    for i=1, 10 do
        local sum = 0
        for j=1, 4 do
            local masteryData = tab:HeroMastery(self._newestMastery[i]._layerIcon[j]._value)
            if masteryData and masteryData.weight2 then
                sum = sum + masteryData.weight2
            end
        end
        if not sumWeight[sum] then
            sumWeight[sum] = {}
        end
        table.insert(sumWeight[sum], i)
    end

    --dump(sumWeight, "sumWeight", 5)

    local sumValue = table.keys(sumWeight)
    table.sort(sumValue, function(a, b)
        return a < b
    end)

    local maxWeight = sumWeight[sumValue[1]]
    local maxIndex = maxWeight[1]
    local count = table.nums(maxWeight)
    if count > 1 then
        local recommandMasteryData = self._heroData.recmastery
        local isMasteryRecommand = function(masteryId)
            local masteryData = tab:HeroMastery(masteryId)
            for i = 1, #recommandMasteryData do
                if recommandMasteryData[i] == masteryData.baseid and masteryData.masterylv >= 2 then
                    return true
                end
            end
            return false
        end
        local maxCount = 0
        for i=1, #maxWeight do
            local count = 0
            for j=1, 4 do
                local masteryId = self._newestMastery[maxWeight[i]]._layerIcon[j]._value
                if isMasteryRecommand(masteryId) then
                    count = count + 1
                end
            end
            if count > maxCount then
                maxCount = count
                maxIndex = maxWeight[i]
            end
        end
    end
    self._recommandIndex = maxIndex
    self:onNewMasterySelected(maxIndex)
    self:scrollByIndex(maxIndex)
end

function HeroMasteryMultiRefreshView:onIconPressOn(node, iconType, iconId)
    print("onIconPressOn")
    iconType = node.getIconType and node:getIconType() or iconType
    iconId = node.getIconId and node:getIconId() or iconId
    if not (iconType and iconId) then return end
    print("iconType, iconId", iconType, iconId)
    if iconType == BattleUtils.kIconTypeHeroMastery then
        self:showHintView("global.GlobalTipView",{tipType = 2, node = node, id = iconId, des = BattleUtils.getDescription(iconType, iconId, self._attributeValues), posCenter = true})
    end
end

return HeroMasteryMultiRefreshView