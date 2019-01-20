--[[
    Filename:    NewFormationView_GodWar.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-04-15 15:33:41
    Description: File description
--]]

local NewFormationIconView = require("game.view.formation.NewFormationIconView")
--local NewFormationDescriptionView = require("game.view.formation.NewFormationDescriptionView")
local NewFormationView = require("game.view.formation.NewFormationView")

function NewFormationView:onInitEx()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._godWarInfo = {}
    self._godWarInfo._layer = self._layer_information:getChildByFullName("info_left.god_war_info")
    self._godWarInfo._layer:setVisible(true)
    self._godWarInfo._btnLeft = self._layer_information:getChildByFullName("info_left.god_war_info.image_switch_bg.btn_left")
    self:registerClickEvent(self._godWarInfo._btnLeft, function()
        self:onButtonLeftClicked()
    end)
    self._godWarInfo._btnRight = self._layer_information:getChildByFullName("info_left.god_war_info.image_switch_bg.btn_right")
    self:registerClickEvent(self._godWarInfo._btnRight, function()
        self:onButtonRightClicked()
    end)
    self._godWarInfo._labelTitle = self._layer_information:getChildByFullName("info_left.god_war_info.image_switch_bg.label_title")
    self._godWarInfo._labelTitle:enable2Color(1, cc.c4b(255, 232, 125, 255))
    self._godWarInfo._labelTitle:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._godWarInfo._labelRemainTime1 = self._layer_information:getChildByFullName("info_left.god_war_info.image_switch_bg.label_remain_time_1")
    self._godWarInfo._labelRemainTime1:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._godWarInfo._labelRemainTime2 = self._layer_information:getChildByFullName("info_left.god_war_info.image_switch_bg.label_remain_time_2")
    self._godWarInfo._labelRemainTime2:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._godWarInfo._labelRemainTime3 = self._layer_information:getChildByFullName("info_left.god_war_info.image_switch_bg.label_remain_time_3")
    self._godWarInfo._labelRemainTime3:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._godWarInfo._layerFormationSelect = self._layer_information:getChildByFullName("info_left.city_battle_info.layer_formation_select")
    --self._godWarInfo._buttonQuickFormat = self._layer_information:getChildByFullName("info_left.god_war_info.layer_formation_select.btn_quick_format")
    self._godWarInfo._buttonSwapFormation = self._layer_information:getChildByFullName("info_left.god_war_info.layer_formation_select.btn_swap_formation")
    self:registerClickEvent(self._godWarInfo._buttonSwapFormation, function()
        self:onButtonSwapClicked()
    end)

    self._godWarInfo._buttonQuickSave = self._layer_information:getChildByFullName("info_left.god_war_info.layer_formation_select.btn_quick_save")
    self:registerClickEvent(self._godWarInfo._buttonQuickSave, function()
        --self:onButtonQuickFormatClicked()
        self:onButtonSaveClicked()
    end)

    self._godWarInfo._formationPreview = {}
    self._godWarInfo._formationPreview._dirty = true
    for i=1, 3 do
        self._godWarInfo._formationPreview[i] = {}
        self._godWarInfo._formationPreview[i]._layer = self._layer_information:getChildByFullName("info_left.god_war_info.layer_formation_select.layer_formation_" .. i)
        self:registerClickEvent(self._godWarInfo._formationPreview[i]._layer, function()
            self:onButtonFormationSelectClicked(i)
        end)
        self._godWarInfo._formationPreview[i]._labelIndex = self._layer_information:getChildByFullName("info_left.god_war_info.layer_formation_select.layer_formation_" .. i .. ".label_index")
        self._godWarInfo._formationPreview[i]._labelIndex:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._godWarInfo._formationPreview[i]._imageSelected = self._layer_information:getChildByFullName("info_left.god_war_info.layer_formation_select.layer_formation_" .. i .. ".image_selected")
        self._godWarInfo._formationPreview[i]._formationUI = {}
        for j=1, NewFormationView.kTeamGridCount do
            self._godWarInfo._formationPreview[i]._formationUI[j] = self._layer_information:getChildByFullName("info_left.god_war_info.layer_formation_select.layer_formation_" .. i .. ".formation_icon_" .. j)
        end
    end

    self:startCountDownClock()
end

function NewFormationView:updateTimeCountDown()
    local remainTime = self._extend.godWarInfo.endTime - self._userModel:getCurServerTime()
    local tempValue = remainTime
    local hour = math.floor(tempValue/3600)
    tempValue = tempValue - hour*3600
    local minute = math.floor(tempValue/60)
    tempValue = tempValue - minute*60
    local second = math.fmod(tempValue, 60)
    local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
    if remainTime <= 0 then
        showTime = "00:00:00"
    end
    self._godWarInfo._labelRemainTime2:setString(showTime)

    local isShowCountDown = hour <= 0 and minute < 3
    self._godWarInfo._labelRemainTime1:setVisible(isShowCountDown)
    self._godWarInfo._labelRemainTime2:setVisible(isShowCountDown)
    self._godWarInfo._labelRemainTime3:setVisible(not isShowCountDown)

    local curServerTime = self._userModel:getCurServerTime()
    local endBattleTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
    --小组赛打完时间  打完以后不在 强制关闭布阵界面
    local eTime = endBattleTime - curServerTime
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if 2 == weekday then
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        remainTime = tempTime - self._userModel:getCurServerTime()
    end 
    if remainTime <= 0 and eTime > 0 then
        self:endCountDownClock()
        self:doClose()
    end
end

function NewFormationView:startCountDownClock()
    if not (self._extend and self._extend.godWarInfo and self._extend.godWarInfo.endTime) then return end
    if self._godWarInfo._timer_id then self:endCountDownClock() return end
    self._godWarInfo._timer_id = self._scheduler:scheduleScriptFunc(function(dt)
        self:updateTimeCountDown(dt)
    end, 0, false)
end

function NewFormationView:endCountDownClock()
    if not self._godWarInfo._timer_id then return end
    if self._godWarInfo._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._godWarInfo._timer_id)
        self._godWarInfo._timer_id = nil
    end
end

function NewFormationView:endClockEx()
    self:endCountDownClock()
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
        local formationId = self._formationModel.kFormationTypeGodWar1 - 1 + index
        if not self._extend.allowBattle[formationId] then
            self._isNotShowDesView = true
            return false, lang("GODWARBZ_2")
        end

        local teamCount = self:getCurrentLoadedTeamCount(formationId)
        if 1 == teamCount then
            self._isNotShowDesView = true
            return false, lang("GODWARBZ")
        end
    end
    return true
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

function NewFormationView:swapGridIconEx(iconGrid1, iconView1, iconGrid2)
    self:updateFormationPreview()
end

function NewFormationView:moveGridIconEx(iconGrid1, iconView1, iconGrid2)
    self:updateFormationPreview()
end

function NewFormationView:loadGridIconEx(iconGrid, iconView, realLoaded)
    self:dealWithGodWarFormationData(iconView:getIconType(), iconView:getIconId())
    self._godWarInfo._formationPreview._dirty = true
    self:updateFormationPreview(true)
    self:updateFormationFilterData()
end

function NewFormationView:dealWithGodWarFormationData(iconType, iconId)
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
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
            --elseif data.heroId == iconId then
            --    data.heroId = 0
            end
        end
    end
end

function NewFormationView:unloadGridIconEx(iconGrid, iconView)
    self:updateFormationPreview()
    self:updateFormationFilterData()
end

function NewFormationView:updateUIEx()
    if self._godWarInfo._formationPreview._dirty then
        self:updateFormationPreview(true)
    end

    if self._extend.allowBattle then
        self:setFormationLocked(not self._extend.allowBattle[self._context._formationId])
    end
end

function NewFormationView:updateRelativeEx()
    self._layerLeft._labelCurrentLoadMC:setVisible(false)
    self._layerLeft._labelNextUnlockLoad:setVisible(false)
    self._godWarInfo._btnLeft:setSaturation(self._context._formationId > self._formationModel.kFormationTypeGodWar1 and 0 or -100)
    --self._godWarInfo._btnLeft:setEnabled(self._context._formationId > self._formationModel.kFormationTypeGodWar1)
    --self._godWarInfo._btnLeft:setBright(self._context._formationId > self._formationModel.kFormationTypeGodWar1)
    self._godWarInfo._btnRight:setSaturation(self._context._formationId < self._formationModel.kFormationTypeGodWar3 and 0 or -100)
    --self._godWarInfo._btnRight:setEnabled(self._context._formationId < self._formationModel.kFormationTypeGodWar3)
    --self._godWarInfo._btnRight:setBright(self._context._formationId < self._formationModel.kFormationTypeGodWar3)
    local index = self._context._formationId - self._formationModel.kFormationTypeGodWar1 + 1
    self._godWarInfo._labelTitle:setString("第" .. index .. "局")
    for i=1, 3 do
        local selected = i == index
        self._godWarInfo._formationPreview[i]._layer:setScale(selected and 1.0 or 0.8)
        self._godWarInfo._formationPreview[i]._imageSelected:setVisible(selected)
    end
end

function NewFormationView:isLeftGridWall(gridIndex)
    local wallIndex = {13, 14, 15, 16}
    for _, v in ipairs(wallIndex) do
        if v == gridIndex then 
            return true 
        end
    end
    return false
end

function NewFormationView:updateFormationPreview(updateAll)
    local updateFormationPreviewByFormationId = function(formationId)
        if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[formationId]) then return end

        local currentIndex = formationId - self._formationModel.kFormationTypeGodWar1 + 1
        for i = 1, NewFormationView.kTeamGridCount do
            self._godWarInfo._formationPreview[currentIndex]._formationUI[i]:removeAllChildren()
        end

        local formationData = self._layerLeft._teamFormation._data[formationId]
        for i = 1, NewFormationView.kTeamMaxCount do
            repeat
                local teamId = formationData[string.format("team%d", i)]
                if 0 == teamId then break end
                local teamPositionId = formationData[string.format("g%d", i)]
                local teamTableData = tab:Team(teamId)
                local iconGrid = self._godWarInfo._formationPreview[currentIndex]._formationUI[teamPositionId]
                local className = TeamUtils:getClassIconNameByTeamId(teamId, "classlabel", teamTableData)
                local imageView = ccui.ImageView:create(IconUtils.iconPath .. className .. ".png", 1)
                imageView:setScale(0.75)
                imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
                iconGrid:addChild(imageView)
            until true
        end
    end

    for i=1, 3 do
        local formationId = self._formationModel.kFormationTypeGodWar1 - 1 + i
        self._godWarInfo._formationPreview[i]._layer:setSaturation((self._extend.allowBattle and self._extend.allowBattle[formationId]) and 0 or -100)
    end

    if updateAll then
        if not self._godWarInfo._formationPreview._dirty then return end
        for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
            updateFormationPreviewByFormationId(formationId)
        end
        self._godWarInfo._formationPreview._dirty = false
    else
        updateFormationPreviewByFormationId(self._context._formationId)
    end
end

function NewFormationView:isShowButtonBattle()
    return false
end

function NewFormationView:isShowBattleTip()
    return false
end

function NewFormationView:doClose()
    if self._musicFileName then
        audioMgr:playMusic(self._musicFileName, true)
    end
    if self:getSaveRequiredInfo() then
        self._viewMgr:showTip(lang("TIPS_BAOCUNBUZHEN"))
        self:doSave(function (success)
            if not success then
                self._viewMgr:showTip(lang("GODWARBZ_5"))
            end
            if self._closeCallBack and type(self._closeCallBack) == "function" then
                self._closeCallBack()
            end
            -- self:close()
        end)
    else
        print("hta 123 ")
        if self._closeCallBack and type(self._closeCallBack) == "function" then
            self._closeCallBack()
        end
        -- self:close()
    end
end

function NewFormationView:checkQuickFormation()
    --[[
    local found = false
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
        repeat
            local data = self._layerLeft._teamFormation._data[formationId]
            if not data then break end
            for i=1, NewFormationView.kTeamMaxCount do
                local teamId = data["team" .. i]
                if 0 ~= teamId then
                    found = true
                    break
                end
            end
            local heroId = data["heroId"]
            if 0 ~= heroId then
                found = true
                break
            end

            if found then
                break
            end
        until true

        if found then
            break
        end
    end

    return not found
    ]]
end

function NewFormationView:onButtonQuickFormatClicked()
    --[[
    print("onButtonQuickFormatClicked")
    local doQuickFormat = function()
        self._formationModel:quickFormat(self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3, function()
            self._godWarInfo._formationPreview._dirty = true
            self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
            self:updateFormationFilterData()
            self:updateUI()
        end)
    end

    if not self:checkQuickFormation() then
        self._viewMgr:showTip(lang("GODWARBZ"))
        return
    end
    
    if self:getSaveRequiredInfo() then
        self._viewMgr:lock(-1)
        self:doSave(function(success)
            if not success then
                self._viewMgr:showTip(lang("GODWARBZ_5"))
                return
            end
            doQuickFormat()
            self._viewMgr:unlock()
        end)
    else
        self._viewMgr:lock(-1)
        doQuickFormat()
        self._viewMgr:unlock()
    end
    ]]
end

--[[
function NewFormationView:_onButtonQuickFormatClicked()
    print("onButtonQuickFormatClicked")
    self._viewMgr:lock(-1)
    local allFormationData = {}
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
        allFormationData[formationId] = self._layerLeft._teamFormation._data[formationId]
    end 

    self._formationModel:quickFormat(allFormationData, self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3, function()
        self._godWarInfo._formationPreview._dirty = true
        self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
        self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
        self:updateFormationFilterData()
        self:updateUI()
        self._viewMgr:unlock()
    end)
end
]]
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
    else
        self._viewMgr:showTip(lang("GODWARBZ_4"))
    end
end

function NewFormationView:onButtonSwapClicked()
    self._viewMgr:showDialog("formation.NewFormationSwapView", 
        {
            container = self, 
            formationData = clone(self._layerLeft._teamFormation._data),
            swapType = 1,
            formationId = self._formationModel.kFormationTypeGodWar1,
            callback1 = function(newFormationData)
                for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
                    self._layerLeft._teamFormation._data[formationId] = clone(newFormationData[formationId])
                end
                self._godWarInfo._formationPreview._dirty = true
                self:updateFormationFilterData()
                self:updateUI()
            end,
            allowBattle = self._extend.allowBattle
        }, 
        true)
end

function NewFormationView:doSave(callback)
    local allFormationData = {}
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
        repeat
            if not self._saveRequiredInfo[formationId] then break end
            allFormationData[formationId] = self._layerLeft._teamFormation._data[formationId]
        until true
    end 

    self._formationModel:saveAllData(allFormationData, self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3, callback)
end

function NewFormationView:getSaveRequiredInfo()
    local found = false
    self._saveRequiredInfo = {}
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
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
        local changeTFormFunc = function( )
        local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
        local pFormation = self._pokedexModel:getPFormation()
        self._modelMgr:getModel("FormationModel"):showFormationEditView({
            isShowTreasure = self:isShowTreasureInfo(),
            isShowPokedex = self:isShowPokedexInfo(),
            tFormId = formationData.tid or 1,
            formationId = self._context._formationId,
            pokedexData = pFormation,
            hireTeamData = self:getUsingHireTeamData(),
            callback = function ( formId )
                formationData.tid = formId
                -- self:updatePokedexInfo(true)
                -- self:updateTreasureInfo(true)
            end
            })
    end
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

function NewFormationView:getEmptyFormationCount()
    --[[
    local count = 0
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
        if formationId ~= self._context._formationId then
            local found = false
            local data = self._layerLeft._teamFormation._data[formationId]
            if data then
                for i=1, NewFormationView.kTeamMaxCount do
                    local teamId = data["team" .. i]
                    if 0 ~= teamId then
                        found = true
                        break
                    end
                end

                if not found then
                    count = count + 1
                end
            end
        end
    end

    return count
    ]]
end

function NewFormationView:getCurrentCanLoadTeamCount()
    --[[
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if not data then return 0 end
    local isFiltered = function(teamId)
        for k, v in pairs(data.filter) do
            if v == teamId then
                return true
            end
        end
        return false
    end

    local count = 0

    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = data[string.format("team%d", i)]
            if not teamId or 0 == teamId then break end
            count = count + 1
        until true
    end

    for k, v in ipairs(self._layerLeft._layerList._teamData) do
        if not isFiltered(v.id) then
            count = count + 1
        end
    end
    return count
    ]]
end

function NewFormationView:getCurrentAllowLoadCount()
    local currentTeamCount = NewFormationView.kTeamMaxCount - 2
    local nextTeamCountUnlockLevel = 0
    local nextTeamCount = 0
    return { currentTeamCount = currentTeamCount, nextTeamCount = nextTeamCount, maxTeamCount = NewFormationView.kTeamMaxCount, nextTeamCountUnlockLevel = nextTeamCountUnlockLevel, currentInstrumentCount = 0, nextInstrumentCount = 0, maxInstrumentCount = self.kInsMaxCount, nextInstrumentCountUnlockLevel = 0, }
end

--[[
function NewFormationView:getCurrentAllowLoadCount()
    local currentTeamCount = NewFormationView.kTeamMaxCount - 2
    local emptyFormationCount = self:getEmptyFormationCount()
    local currentOwnTeamCount = self:getCurrentCanLoadTeamCount()
    currentTeamCount = math.min(currentTeamCount, currentOwnTeamCount - emptyFormationCount)
    local nextTeamCountUnlockLevel = 0
    local nextTeamCount = 0
    return { currentTeamCount = currentTeamCount, nextTeamCount = nextTeamCount, maxTeamCount = NewFormationView.kTeamMaxCount, nextTeamCountUnlockLevel = nextTeamCountUnlockLevel, currentInstrumentCount = 0, nextInstrumentCount = 0, maxInstrumentCount = self.kInsMaxCount, nextInstrumentCountUnlockLevel = 0, }
end
]]
function NewFormationView:getCurrentAllowLoadTeamCount()
    return 6
end

function NewFormationView:onButtonLeftClicked()
    if self._context._formationId <= self._formationModel.kFormationTypeGodWar1 then return end
    local formationId = self._context._formationId - 1
    local found = false
    for id = self._context._formationId - 1, self._formationModel.kFormationTypeGodWar1, -1 do
        if self._extend.allowBattle and self._extend.allowBattle[id] then
            formationId = id
            found = true
            break
        end
    end

    if not found then
        self._viewMgr:showTip(lang("GODWAR_ARRAY"))
        return
    end

    self:switchFormation(formationId)
end

function NewFormationView:onButtonRightClicked()
    if self._context._formationId >= self._formationModel.kFormationTypeGodWar3 then return end
    local formationId = self._context._formationId + 1
    local found = false
    for id = self._context._formationId + 1, self._formationModel.kFormationTypeGodWar3 do
        if self._extend.allowBattle and self._extend.allowBattle[id] then
            formationId = id
            found = true
            break
        end
    end

    if not found then
        self._viewMgr:showTip(lang("GODWAR_ARRAY"))
        return
    end

    self:switchFormation(formationId)
end

function NewFormationView:onButtonFormationSelectClicked(index)
    if index < 1 or index > 3 then return end
    local formationId = self._formationModel.kFormationTypeGodWar1 - 1 + index
    if not (self._extend.allowBattle and self._extend.allowBattle[formationId]) then
        self._viewMgr:showTip(lang("GODWAR_ARRAY"))
        return
    end
    self:switchFormation(formationId)
end

function NewFormationView:updateFormationFilterData()
    self._formationFilterData = {}
    for formationId = self._formationModel.kFormationTypeGodWar1, self._formationModel.kFormationTypeGodWar3 do
        local formationData = self._layerLeft._teamFormation._data[formationId]
        repeat
            if not formationData then break end
            for i = 1, NewFormationView.kTeamMaxCount do
                repeat
                    local teamId = formationData[string.format("team%d", i)]
                    if not teamId or 0 == teamId then break end
                    self._formationFilterData[teamId] = formationId - 21
                until true
            end

            for i = 1, NewFormationView.kInsMaxCount do
                repeat
                    local weaponId = formationData[string.format("weapon%d", i)]
                    if not weaponId or 0 == weaponId then break end
                    self._formationFilterData[weaponId] = formationId - 21
                until true
            end

            local heroId = formationData.heroId
            if heroId and 0 ~= heroId then
                self._formationFilterData[heroId] = formationId - 21
            end
        until true
    end
end

function NewFormationView:initFormationData()
    self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
    self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
    self:updateFormationFilterData()
end

function NewFormationView:switchFormation(formationId)
    -- version 2.0
    if self._context._formationId == formationId then return end

    local doSwitchFormation = function()
        self._context._formationId = formationId
        self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
        self._layerLeft._teamFormation._allowLoadCount = self:getCurrentAllowLoadCount()
        self:updateFormationFilterData()
        self:updateUI()
    end
    
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
            local formationId = self._formationModel.kFormationTypeGodWar1 - 1 + index
            item:showFormationIndexFlag(true, self._formationFilterData[iconId], not self._extend.allowBattle[formationId])
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
            local formationId = self._formationModel.kFormationTypeGodWar1 - 1 + index
            item:showFormationIndexFlag(true, self._formationFilterData[iconId], not self._extend.allowBattle[formationId])
        else
            item:showFormationIndexFlag(false, self._formationFilterData[iconId], false)
        end
        item:setCustom(data[idx + 1].custom)
        item:setScenarioHero(self:isScenarioHero(iconId))
        item:updateState(NewFormationIconView.kIconStateImage, true)
    end
    return cell
end
