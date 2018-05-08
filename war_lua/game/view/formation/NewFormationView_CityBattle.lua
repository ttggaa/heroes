--[[
    Filename:    NewFormationView_CityBattle.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-12-12 17:39:02
    Description: File description
--]]

local NewFormationIconView = require("game.view.formation.NewFormationIconView")
--local NewFormationDescriptionView = require("game.view.formation.NewFormationDescriptionView")
local NewFormationView = require("game.view.formation.NewFormationView")

function NewFormationView:onInitEx()
    self._openLevelInfo = tab:Setting("G_CITYBATTLE_FORMATION_LV").value
    self._userModel = self._modelMgr:getModel("UserModel")
    self._cityBattleInfo = {}
    self._cityBattleInfo._layer = self:getUI("bg.layer_information.info_left.city_battle_info")
    self._cityBattleInfo._layer:setVisible(true)
    local screenSize = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
    local isPad = (screenSize.width / screenSize.height) <= (3.0 / 2.0)
    self._cityBattleInfo._bg = self:getUI("bg.layer_information.info_left.city_battle_info.city_battle_bg")
    self._cityBattleInfo._bg:setPositionX(self._winSize.width / 2 - self._cityBattleInfo._bg:getContentSize().width / 2 + 60)
    if isPad then
        self._cityBattleInfo._bg:setPositionX(self._winSize.width / 2 - self._cityBattleInfo._bg:getContentSize().width / 2 + 120)
    end
    self._cityBattleInfo._buttonSave = self:getUI("bg.layer_information.info_left.city_battle_info.button_save")
    self._cityBattleInfo._buttonSave:setPositionX(self._winSize.width - self._cityBattleInfo._buttonSave:getContentSize().width / 2 - 10)
    self:registerClickEvent(self._cityBattleInfo._buttonSave, function()
        self:onButtonSaveClicked()
    end)
    self._cityBattleInfo._buttons = {}
    for i = 1, 4 do
        self._cityBattleInfo._buttons[i] = {}
        self._cityBattleInfo._buttons[i]._formationId = self._formationModel.kFormationTypeCityBattle1 + i - 1
        self._cityBattleInfo._buttons[i]._button = self:getUI("bg.layer_information.info_left.city_battle_info.city_battle_bg.city_battle_button_switch_" .. i)
        self:registerClickEvent(self._cityBattleInfo._buttons[i]._button, function()
            self:switchFormation(self._cityBattleInfo._buttons[i]._formationId)
        end)
        self._cityBattleInfo._buttons[i]._name = self:getUI("bg.layer_information.info_left.city_battle_info.city_battle_bg.city_battle_button_switch_" .. i .. ".label_name")
        self._cityBattleInfo._buttons[i]._name:setString("第" .. i .. "队")
        self._cityBattleInfo._buttons[i]._name:setFontName(UIUtils.ttfName)
        self._cityBattleInfo._buttons[i]._state = self:getUI("bg.layer_information.info_left.city_battle_info.city_battle_bg.city_battle_button_switch_" .. i .. ".image_state")
        --self._cityBattleInfo._buttons[i]._state = self:getUI("bg.layer_information.info_left.city_battle_info.city_battle_bg.city_battle_button_switch_" .. i .. ".label_state")
        --self._cityBattleInfo._buttons[i]._state:setFontName(UIUtils.ttfName)
    end

    self._revivingInfo = {}
    for i = 1, 4 do
        local formationId = self._cityBattleInfo._buttons[i]._formationId
        if self:isFormationStateDead(formationId) then
            self:startCountDownClock()
            break
        end
    end
end

function NewFormationView:updateTimeCountDown()
    local found = false
    local currentTime = self._userModel:getCurServerTime()
    for formationId = self._formationModel.kFormationTypeCityBattle1, self._formationModel.kFormationTypeCityBattle4 do
        repeat
            if not self._extend.cityBattleInfo.deadInfo[formationId] then break end
            local remainTime = self._extend.cityBattleInfo.deadInfo[formationId] - currentTime
            if remainTime > 0 then
                found = true
                -- 更新倒计时显示                 
                if self._reviveCDView and self._reviveCDViewId == formationId then
                    self._reviveCDView:CDupdate(remainTime)
                end
            else
                if self._reviveCDView and self._reviveCDViewId == formationId then
                    self._viewMgr:closeDialog(self._reviveCDView)
                    self._reviveCDView = nil
                end
                self:doReset(formationId)
            end
        until true
    end

    if not found then
        self:endCountDownClock()
    end
end

function NewFormationView:startCountDownClock()
    if not (self._extend and self._extend.cityBattleInfo and self._extend.cityBattleInfo.deadInfo) then return end
    if self._cityBattleInfo._timer_id then return end
    self._cityBattleInfo._timer_id = self._scheduler:scheduleScriptFunc(handler(self, self.updateTimeCountDown), 1, false)
end

function NewFormationView:endCountDownClock()
    if not self._cityBattleInfo._timer_id then return end
    if self._cityBattleInfo._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._cityBattleInfo._timer_id)
        self._cityBattleInfo._timer_id = nil
    end
end

function NewFormationView:endClockEx()
    self:endCountDownClock()
end

function NewFormationView:isFormationStateOpened(index)
    local userLevel = self._userModel:getPlayerLevel()
    local levelLimit = self._openLevelInfo[index] or 0
    return (userLevel >= levelLimit)
end

function NewFormationView:isFormationStateDead(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    if not (self._extend and self._extend.cityBattleInfo and self._extend.cityBattleInfo.deadInfo) then return false end
    return self._extend.cityBattleInfo.deadInfo[formationId]
end

function NewFormationView:isFormationStateFighting(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    if not (self._extend and self._extend.cityBattleInfo and self._extend.cityBattleInfo.fightInfo) then return false end
    return self._extend.cityBattleInfo.fightInfo[formationId]
end

function NewFormationView:isFormationStateNull(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    return (self:isLoadedHeroNull(formationId) or 0 == self:getCurrentLoadedTeamCount(formationId))
end

function NewFormationView:isFormationStateFull(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    return (not self:isLoadedHeroNull(formationId) and self:isTeamLoadedFull(formationId))
end

function NewFormationView:isFormationCanOperate(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    return not (self:isFormationStateDead(formationId) or self:isFormationStateFighting(formationId))
end

function NewFormationView:onIconTouchBeganEx(iconView)
    self._isNotShowDesView = false
    if not iconView or not self._layerLeft._isItemsLayerHitted then return true end
    local iconType = iconView:getIconType()
    local iconId = iconView:getIconId()
    local index = self._formationFilterData[iconId]
    if index then
        if iconType == NewFormationView.kGridTypeHero then
            self._isNotShowDesView = true
            return false, lang("GODWARBZ_3")
        end
        local formationId = self._formationModel.kFormationTypeCityBattle1 - 1 + index
        if not self:isFormationCanOperate(formationId) then
            self._isNotShowDesView = true
            return false, lang("CITYBATTLE_TIP_17")
        end

        local teamCount = self:getCurrentLoadedTeamCount(formationId)
        if 1 == teamCount then
            self._isNotShowDesView = true
            return false, lang("GODWARBZ")
        end
    end
    return true
end

function NewFormationView:updateFormationFilterData()
    self._formationFilterData = {}
    for formationId = self._formationModel.kFormationTypeCityBattle1, self._formationModel.kFormationTypeCityBattle4 do
        local formationData = self._layerLeft._teamFormation._data[formationId]
        repeat
            if not formationData then break end
            for i = 1, NewFormationView.kTeamMaxCount do
                repeat
                    local teamId = formationData[string.format("team%d", i)]
                    if not teamId or 0 == teamId then break end
                    self._formationFilterData[teamId] = formationId - 16
                until true
            end

            for i = 1, NewFormationView.kInsMaxCount do
                repeat
                    local weaponId = formationData[string.format("weapon%d", i)]
                    if not weaponId or 0 == weaponId then break end
                    self._formationFilterData[weaponId] = formationId - 16
                until true
            end

            local heroId = formationData.heroId
            if heroId and 0 ~= heroId then
                self._formationFilterData[heroId] = formationId - 16
            end
        until true
    end
end

function NewFormationView:onShowDescriptionView(iconType, iconId, iconSubtype, isChanged, changedId, isCustom, isLocal)
    if self:isFormationLocked() then return end
    if not self:isShowDescriptionView(iconType) or self._isNotShowDesView then return end
    if iconType == NewFormationIconView.kIconTypeIns then
        local weaponData = {
            exp = 0,
            lv = 0,
            score = 0,
            sp1 = {},
            sp2 = {},
            sp3 = {},
            sp4 = {},
            ss1 = 0,
            ss2 = 0,
            unlockIds = {},
        }
        if self:isHaveFixedWeapon() then
            local weaponTableData = tab:SiegeWeaponNpc(iconId)
            if weaponTableData then
                weaponData.lv = weaponTableData.lv
                for i=1, 4 do
                    if weaponTableData["equip" .. i] then
                        weaponData["sp" .. i] = {id = weaponTableData["equip" .. i][1], lv = weaponTableData["equip" .. i][2], score = weaponTableData.score}
                    end
                end
                weaponData.ss1 = weaponTableData.skill
                weaponData.ss2 = weaponTableData.skill1
            end
        else
            weaponData = clone(self._weaponsModel:getWeaponsDataByType(iconSubtype))
            if weaponData then
                for i=1, 4 do
                    local sp = weaponData["sp" .. i]
                    if 0 ~= sp then
                        local propsData = self._weaponsModel:getPropsDataByKey(sp)
                        if propsData then
                            weaponData["sp" .. i] = {id = propsData.id, lv = propsData.lv, score = propsData.score}
                        end
                    else
                        weaponData["sp" .. i] = {}
                    end
                end
            end
        end
        self._viewMgr:showDialog("rank.RankWeaponsDetailView", {userWeapon = weaponData, weaponId = iconId, weaponType = iconSubtype}, true)
    else
        self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = iconType, iconId = iconId, iconSubtype = iconSubtype, isChanged = isChanged, changedId = changedId, formationType = self._formationType, isCustom = isCustom, isLocal = isLocal}, true)
    end
end

function NewFormationView:loadGridIconEx(iconGrid, iconView, realLoaded)
    self:dealWithCityBattleFormationData(iconView:getIconType(), iconView:getIconId())
    self:updateFormationFilterData()
end

function NewFormationView:dealWithCityBattleFormationData(iconType, iconId)
    for formationId = self._formationModel.kFormationTypeCityBattle1, self._formationModel.kFormationTypeCityBattle4 do
        if formationId ~= self._context._formationId then
            local data = self._layerLeft._teamFormation._data[formationId]
            if iconType == NewFormationView.kGridTypeTeam then
                for i=1, NewFormationView.kTeamMaxCount do
                    local teamId = data["team" .. i]
                    if teamId == iconId then
                        data["team" .. i] = 0
                        data["g" .. i] = 0
                        break
                    end
                end
            elseif iconType == NewFormationView.kGridTypeIns then
                for i=1, 4 do
                    local weaponId = data["weapon" .. i]
                    if weaponId == iconId then
                        data["weapon" .. i] = 0
                        break
                    end
                end
            elseif data.heroId == iconId then
                data.heroId = 0
            end
        end
    end
end

function NewFormationView:isTeamCanUnload()
    return true
end

function NewFormationView:unloadGridIconEx(iconGrid, iconView)
    self:updateFormationFilterData()
end

function NewFormationView:initTeamListData()
    self._layerLeft._layerList._teamData = {}
    local data = clone(self._teamModel:getData())
    for k, v in pairs(data) do
        v["race"] = tab:Team(v.teamId).race
    end

    if not self._layerLeft._layerList._allTeamsInit then
        self._layerLeft._layerList._allTeamsData = clone(data)
        self._layerLeft._layerList._allTeamsInit = true
    end

    local t1, t2 = {}, {}
    for k, v in pairs(data) do
        repeat
            if self:isTeamTypeFiltered(v) then break end
            if self:isLoaded(NewFormationView.kGridTypeTeam, v.teamId) then break end
            if not (self._formationFilterData and not not self._formationFilterData[v.teamId]) then
                v.id = v.teamId
                v.teamId = nil
                table.insert(t1, v)
            else
                v.id = v.teamId
                v.teamId = nil
                table.insert(t2, v)
            end
        until true
    end

    table.sort(t1, function(a, b)
        return a.score > b.score
    end)

    table.sort(t2, function(a, b)
        return a.score > b.score
    end)

    for i = 1, #t1 do
        self._layerLeft._layerList._teamData[#self._layerLeft._layerList._teamData + 1] = t1[i]
    end

    for i = 1, #t2 do
        self._layerLeft._layerList._teamData[#self._layerLeft._layerList._teamData + 1] = t2[i]
    end
end

function NewFormationView:updateUIEx()

end

function NewFormationView:updateRelativeEx()
    for i = 1, 4 do
        repeat
            local formationId = self._cityBattleInfo._buttons[i]._formationId
            if not self:isFormationStateOpened(i) then
                self._cityBattleInfo._buttons[i]._button:setVisible(false)
                break
            end
            self._cityBattleInfo._buttons[i]._button:setVisible(true)
            if self:isFormationStateFighting(formationId) then
                self._cityBattleInfo._buttons[i]._state:loadTexture("num_fight_forma.png", 1)
            elseif self:isFormationStateDead(formationId) then
                self._cityBattleInfo._buttons[i]._state:loadTexture("num_die_forma.png", 1)
            else
                local count = self:getCurrentLoadedTeamCount(formationId)
                self._cityBattleInfo._buttons[i]._state:loadTexture("num_" .. count .. "_forma.png", 1)
            end
            if self._cityBattleInfo._buttons[i]._formationId == self._context._formationId then
                self._cityBattleInfo._buttons[i]._button:setEnabled(false)
                self._cityBattleInfo._buttons[i]._button:setBright(true)
                self._cityBattleInfo._buttons[i]._name:setColor(cc.c3b(255, 255, 255))
            else
                self._cityBattleInfo._buttons[i]._button:setEnabled(true)
                self._cityBattleInfo._buttons[i]._button:setBright(false)
                self._cityBattleInfo._buttons[i]._name:setColor(cc.c3b(70, 40, 0))
            end
        until true
    end
end

function NewFormationView:_updateRelativeEx()
    for i = 1, 4 do
        repeat
            local formationId = self._cityBattleInfo._buttons[i]._formationId
            if not self:isFormationStateOpened(i) then
                self._cityBattleInfo._buttons[i]._button:setVisible(false)
                break
            end
            self._cityBattleInfo._buttons[i]._button:setVisible(true)
            if self:isFormationStateFighting(formationId) then
                self._cityBattleInfo._buttons[i]._state:setString("战")
            elseif self:isFormationStateDead(formationId) then
                self._cityBattleInfo._buttons[i]._state:setString("亡")
            elseif self:isFormationStateNull(formationId) then
                self._cityBattleInfo._buttons[i]._state:setString("空")
            elseif self:isFormationStateFull(formationId) then
                self._cityBattleInfo._buttons[i]._state:setString("满")
            else
                self._cityBattleInfo._buttons[i]._state:setString("编")
            end
            if self._cityBattleInfo._buttons[i]._formationId == self._context._formationId then
                self._cityBattleInfo._buttons[i]._button:setEnabled(false)
                self._cityBattleInfo._buttons[i]._button:setBright(true)
                self._cityBattleInfo._buttons[i]._name:setColor(cc.c3b(255, 255, 255))
            else
                self._cityBattleInfo._buttons[i]._button:setEnabled(true)
                self._cityBattleInfo._buttons[i]._button:setBright(false)
                self._cityBattleInfo._buttons[i]._name:setColor(cc.c3b(70, 40, 0))
            end
        until true
    end
end

function NewFormationView:isShowButtonBattle()
    return false
end

function NewFormationView:isShowBattleTip()
    return false
end

function NewFormationView:checkFormationData()
    if self:isLoadedHeroNull() then
        return true, lang("CITYBATTLE_TIP_30")
    elseif 0 == self:getCurrentLoadedTeamCount() then
        return true, lang("CITYBATTLE_TIP_29")
    end
    return false
end

function NewFormationView:doClose()

    if self._musicFileName then
        audioMgr:playMusic(self._musicFileName, true)
    end

    local _doClose = function()
        if self:getSaveRequiredInfo() then
            self._viewMgr:showTip(lang("TIPS_BAOCUNBUZHEN"))
            self:doSave(function (success)
                if not success then
                    self._viewMgr:showTip(lang("GODWARBZ_5"))
                end
                if self._closeCallBack and type(self._closeCallBack) == "function" then
                    self._closeCallBack()
                end
                self:close()
            end)
        else
            if self._closeCallBack and type(self._closeCallBack) == "function" then
                self._closeCallBack()
            end
            self:close()
        end
    end

    local isNull, tips = self:checkFormationData()
    if isNull then
        self._viewMgr:showSelectDialog(tips, "", function()
            _doClose()
        end, "")
    else
        _doClose()
    end
end

function NewFormationView:onButtonSaveClicked()
    if self:getSaveRequiredInfo() then
        self._viewMgr:lock(-1)
        self:doSave(function(success)
            if not success then
                self._viewMgr:showTip(lang("GODWARBZ_5"))
                return
            end
            self._viewMgr:showTip(lang("GODWARBZ_4"))
            self._viewMgr:unlock()
        end)
    end
end

function NewFormationView:doSave(callback)
    local allFormationData = {}
    for formationId = self._formationModel.kFormationTypeCityBattle1, self._formationModel.kFormationTypeCityBattle4 do
        repeat
            if not self._saveRequiredInfo[formationId] then break end
            allFormationData[formationId] = self._layerLeft._teamFormation._data[formationId]
        until true
    end 

    self._formationModel:saveAllData(allFormationData, self._formationModel.kFormationTypeCityBattle1, self._formationModel.kFormationTypeCityBattle4, callback)
end

function NewFormationView:getSaveRequiredInfo()
    local found = false
    self._saveRequiredInfo = {}
    for formationId = self._formationModel.kFormationTypeCityBattle1, self._formationModel.kFormationTypeCityBattle4 do
        if self:isSaveRequired(formationId) then
            self._saveRequiredInfo[formationId] = true
            found = true
        end
    end
    return found
end

function NewFormationView:onButtonChangeTreasureClicked()
    print("onButtonChangeTreasureClicked")
    if self:isFormationLocked() then return end
    local changeTFormFunc = function( )
        local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
        self._viewMgr:showDialog("treasure.TreasureSelectFormDialog",{
            tFormId = formationData.tid or 1,
            formationId = self._context._formationId,
            callback = function( formId )
                -- self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
                -- self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
                formationData.tid = formId
                self:updateTreasureInfo()
            end})
    end
    -- 改变宝物编组前先保存编组
    if self:getSaveRequiredInfo() then
        self:doSave(function(success)
            if not success then
                self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
                return
            end
            changeTFormFunc()
        end)
    else
        changeTFormFunc()
    end
end

function NewFormationView:showResetDialog(formationId)
    local currentTime = self._userModel:getCurServerTime()
    local remaintime = self._extend.cityBattleInfo.deadInfo[formationId] - currentTime
    local revivetimes = self._extend.cityBattleInfo.reviveInfo[formationId] + 1
    if revivetimes > 50 then revivetimes = 50 end
    local reviveCityBattle = tab:ReflashCost(revivetimes).reviveCityBattle
    local cost = reviveCityBattle and reviveCityBattle[3] or 999

    self._reviveCDView = self._viewMgr:showDialog("arena.ArenaDialogCD", {
        desc = "[color=462800,fontsize=24]是否花费[pic=globalImageUI_littleDiamond.png][-][color=462800,fontsize=24]"..cost.."[-][-][color=462800,fontsize=24]消除冷却[-]",
        --确定回调
        callBack1 = function()
            local have = self._userModel:getData().gem
            if cost > have then
                DialogUtils.showNeedCharge({callback1=function( )
                    self._viewMgr:showView("vip.VipView", {viewType = 0, callback = function()

                    end})
                end})
                return
            end
            self:doReset(formationId)
        end,
        --取消回调
         callBack2 = function()
            if self._reviveCDView then
                self._viewMgr:closeDialog(self._reviveCDView)
                self._reviveCDView = nil
            end
        end
    })

    if self._reviveCDView then
        self._reviveCDViewId = formationId
        self._reviveCDView:CDupdate(remaintime)
    end

    --[[
    local descStr = "[color=452900]是否花费[-][color=00ff22,outlinecolor=3c1e0aff]300[-][color=452900]钻石立刻复活部队。[-]"
    local rtx = DialogUtils.createRtxLabel( descStr,{width = 280} )
    rtx:formatText()
    local w,h = rtx:getInnerSize().width,rtx:getInnerSize().height
    local descNode = ccui.Layout:create()
    descNode:setBackGroundColorType(1)
    descNode:setContentSize(cc.size(math.max(w,0),h))
    descNode:setBackGroundColorOpacity(0)
    descNode:setAnchorPoint(cc.p(0.5,0.5))
    descNode:addChild(rtx)
    rtx:setPosition(cc.p(descNode:getContentSize().width/2,descNode:getContentSize().height/2))
    UIUtils:alignRichText(rtx,{hAlign = "center"})
    
    self._viewMgr:showSelectDialog(descNode, "", function()
        local consume = 300
        local totalGem = self._userModel:getData().freeGem + self._userModel:getData().payGem
        if consume > totalGem then
            DialogUtils.showNeedCharge({callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
            return 
        end
        self:doReset()
    end, "")
    ]]
end

function NewFormationView:doReset(formationId)
    if self._revivingInfo[formationId] then return end
    self._revivingInfo[formationId] = true
    self._formationModel:reviveCityBattleFormation(formationId, function(success)
        self._revivingInfo[formationId] = false
        if not success then
            self._viewMgr:showTip("复活部队失败。请策划配表")
            return
        end
        --self._layerLeft._teamFormation._data[formationId] = clone(self._formationModel:getFormationData()[formationId])
        self._extend.cityBattleInfo.deadInfo[formationId] = false

        self:updateRelativeEx()
    end)
end

function NewFormationView:initFormationData()
    self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
    self:updateFormationFilterData()
end

function NewFormationView:switchFormation(formationId)
    -- version 2.0
    if self._context._formationId == formationId then return end

    if self:isFormationStateFighting(formationId) then
        self._viewMgr:showTip(lang("CITYBATTLE_TIP_28"))
        return
    end

    if self:isFormationStateDead(formationId) then
        self:showResetDialog(formationId)
        return
    end
    
    local doSwitchFormation = function()
        self._context._formationId = formationId
        self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
        self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
        self:updateUI()
    end

    local _doSwitchFormation = function()
        if self:getSaveRequiredInfo() then
            self._viewMgr:lock(-1)
            self:doSave(function(success)
                if not success then
                    self._viewMgr:showTip(lang("GODWARBZ_5"))
                    return
                end
                doSwitchFormation()
                self._viewMgr:unlock()
            end)
        else
            self._viewMgr:lock(-1)
            doSwitchFormation()
            self._viewMgr:unlock()
        end
    end
    
    local isNull, tips = self:checkFormationData()
    if isNull then
        self._viewMgr:showSelectDialog(tips, "", function()
            _doSwitchFormation()
        end, "")
    else
        _doSwitchFormation()
    end
end

function NewFormationView:itemsTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    local data = self:getCurrentIconData()
    local iconType = self._context._gridType[self._context._formationId]
    local iconId = data[idx + 1].id
    if nil == cell then
        cell = cc.TableViewCell:new()
        local item = NewFormationIconView.new({iconType = iconType, iconId = iconId, iconSubtype = data[idx + 1].teamSubtype, iconState = NewFormationIconView.kIconStateImage, formationType = self._formationType, isCustom = data[idx + 1].custom, isScenarioHero = false, container = self})
        item:setPosition(iconType == NewFormationView.kGridTypeHero and cc.p(55, 60) or cc.p(55, 50))
        item:setTag(NewFormationView.kItemTag)
        local index = self._formationFilterData[iconId]
        local isShowIndex = not not index
        if isShowIndex then
            local formationId = self._formationModel.kFormationTypeCityBattle1 - 1 + index
            item:showFormationIndexFlag(true, self._formationFilterData[iconId], not self:isFormationCanOperate(formationId))
        else
            item:showFormationIndexFlag(false, self._formationFilterData[iconId], false)
        end
        item:updateState(NewFormationIconView.kIconStateImage, true)
        item:setName("item_"..idx)
        cell:setName("cell_"..idx)
        cell:addChild(item)
    else
        local item = cell:getChildByTag(NewFormationView.kItemTag)
        item:setIconId(iconId)
        local index = self._formationFilterData[iconId]
        local isShowIndex = not not index
        if isShowIndex then
            local formationId = self._formationModel.kFormationTypeCityBattle1 - 1 + index
            item:showFormationIndexFlag(true, self._formationFilterData[iconId], not self:isFormationCanOperate(formationId))
        else
            item:showFormationIndexFlag(false, self._formationFilterData[iconId], false)
        end
        item:setCustom(data[idx + 1].custom)
        item:setScenarioHero(self:isScenarioHero(iconId))
        item:updateState(NewFormationIconView.kIconStateImage, true)
    end
    return cell
end
