--[[
 	@FileName 	NewFormationView_CrossGodWar.lua
	@Authors 	yuxiaojing
	@Date    	2018-05-07 20:42:45
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local NewFormationIconView = require("game.view.formation.NewFormationIconView")

local NewFormationView = require("game.view.formation.NewFormationView")

function NewFormationView:onInitEx(  )
	self._userModel = self._modelMgr:getModel("UserModel")
	self._crossGodWarInfo = {}
	self._crossGodWarInfo._layer = self._layer_information:getChildByFullName("info_left.cross_god_war_info")
	self._crossGodWarInfo._layer:setVisible(true)
	self._crossGodWarInfo._btnLeft = self._layer_information:getChildByFullName("info_left.cross_god_war_info.image_switch_bg.btn_left")
	self:registerClickEvent(self._crossGodWarInfo._btnLeft, function()
        self:onButtonLeftClicked()
    end)
    self._crossGodWarInfo._btnRight = self._layer_information:getChildByFullName("info_left.cross_god_war_info.image_switch_bg.btn_right")
    self:registerClickEvent(self._crossGodWarInfo._btnRight, function()
        self:onButtonRightClicked()
    end)
    self._crossGodWarInfo._labelTitle = self._layer_information:getChildByFullName("info_left.cross_god_war_info.image_switch_bg.label_title")
    self._crossGodWarInfo._labelTitle:enable2Color(1, cc.c4b(255, 232, 125, 255))
    self._crossGodWarInfo._labelTitle:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._crossGodWarInfo._labelRemainTime1 = self._layer_information:getChildByFullName("info_left.cross_god_war_info.image_switch_bg.label_remain_time_1")
    self._crossGodWarInfo._labelRemainTime1:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._crossGodWarInfo._labelRemainTime2 = self._layer_information:getChildByFullName("info_left.cross_god_war_info.image_switch_bg.label_remain_time_2")
    self._crossGodWarInfo._labelRemainTime2:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._crossGodWarInfo._labelRemainTime3 = self._layer_information:getChildByFullName("info_left.cross_god_war_info.image_switch_bg.label_remain_time_3")
    self._crossGodWarInfo._labelRemainTime3:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._crossGodWarInfo._buttonSwapFormation = self._layer_information:getChildByFullName("info_left.cross_god_war_info.layer_formation_select.btn_swap_formation")
    self:registerClickEvent(self._crossGodWarInfo._buttonSwapFormation, function()
        self:onButtonSwapClicked()
    end)

    self._crossGodWarInfo._buttonQuickSave = self._layer_information:getChildByFullName("info_left.cross_god_war_info.layer_formation_select.btn_quick_save")
    self:registerClickEvent(self._crossGodWarInfo._buttonQuickSave, function()
        self:onButtonSaveClicked()
    end)

    self._crossGodWarInfo._formationPreview = {}
    self._crossGodWarInfo._formationPreview._dirty = true
    for i = 1, 3 do
        self._crossGodWarInfo._formationPreview[i] = {}
        self._crossGodWarInfo._formationPreview[i]._layer = self._layer_information:getChildByFullName("info_left.cross_god_war_info.layer_formation_select.layer_formation_" .. i)
        self:registerClickEvent(self._crossGodWarInfo._formationPreview[i]._layer, function()
            self:onButtonFormationSelectClicked(i)
        end)
        self._crossGodWarInfo._formationPreview[i]._labelIndex = self._layer_information:getChildByFullName("info_left.cross_god_war_info.layer_formation_select.layer_formation_" .. i .. ".label_index")
        self._crossGodWarInfo._formationPreview[i]._labelIndex:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._crossGodWarInfo._formationPreview[i]._imageSelected = self._layer_information:getChildByFullName("info_left.cross_god_war_info.layer_formation_select.layer_formation_" .. i .. ".image_selected")
        self._crossGodWarInfo._formationPreview[i]._formationUI = {}
        for j = 1, NewFormationView.kTeamGridCount do
            self._crossGodWarInfo._formationPreview[i]._formationUI[j] = self._layer_information:getChildByFullName("info_left.cross_god_war_info.layer_formation_select.layer_formation_" .. i .. ".formation_icon_" .. j)
        end
    end

    self:startCountDownClock()
end

function NewFormationView:updateTimeCountDown()
    local remainTime = self._extend.crossGodWarInfo.endTime - self._userModel:getCurServerTime()
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
    self._crossGodWarInfo._labelRemainTime2:setString(showTime)

    local isShowCountDown = hour <= 0 and minute < 3
    self._crossGodWarInfo._labelRemainTime1:setVisible(isShowCountDown)
    self._crossGodWarInfo._labelRemainTime2:setVisible(isShowCountDown)
    self._crossGodWarInfo._labelRemainTime3:setVisible(not isShowCountDown)
    if remainTime <= 0 then
        self:endCountDownClock()
        self:doClose()
    end
end

function NewFormationView:startCountDownClock()
    if not (self._extend and self._extend.crossGodWarInfo and self._extend.crossGodWarInfo.endTime) then return end
    if self._crossGodWarInfo._timer_id then self:endCountDownClock() return end
    self._crossGodWarInfo._timer_id = self._scheduler:scheduleScriptFunc(function(dt)
        self:updateTimeCountDown(dt)
    end, 0, false)
end

function NewFormationView:endCountDownClock()
    if not self._crossGodWarInfo._timer_id then return end
    if self._crossGodWarInfo._timer_id then 
        self._scheduler:unscheduleScriptEntry(self._crossGodWarInfo._timer_id)
        self._crossGodWarInfo._timer_id = nil
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
        local formationId = self._formationModel.kFormationTypeCrossGodWar1 - 1 + index
        if iconType == NewFormationView.kGridTypeTeam then
            local teamCount = self:getCurrentLoadedTeamCount(formationId)
            if 1 == teamCount then
                self._isNotShowDesView = true
                return false, lang("GODWARBZ")
            end
        end
    end
    return true
end

function NewFormationView:initFormationData()
	self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
    self:updateFormationFilterData()
end

function NewFormationView:updateFormationFilterData()
    self._formationFilterData = {}
    for formationId = self._formationModel.kFormationTypeCrossGodWar1, self._formationModel.kFormationTypeCrossGodWar3 do
        local formationData = self._layerLeft._teamFormation._data[formationId]
        repeat
            if not formationData then break end
            for i = 1, NewFormationView.kTeamMaxCount do
                repeat
                    local teamId = formationData[string.format("team%d", i)]
                    if not teamId or 0 == teamId then break end
                    self._formationFilterData[teamId] = formationId - 36
                until true
            end

            for i = 1, NewFormationView.kInsMaxCount do
                repeat
                    local weaponId = formationData[string.format("weapon%d", i)]
                    if not weaponId or 0 == weaponId then break end
                    self._formationFilterData[weaponId] = formationId - 36
                until true
            end

            local heroId = formationData.heroId
            if heroId and 0 ~= heroId then
                self._formationFilterData[heroId] = formationId - 36
            end
        until true
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
    self._crossGodWarInfo._formationPreview._dirty = true
    self:updateFormationPreview(true)
    self:updateFormationFilterData()
end

function NewFormationView:dealWithGodWarFormationData(iconType, iconId)
    for formationId = self._formationModel.kFormationTypeCrossGodWar1, self._formationModel.kFormationTypeCrossGodWar3 do
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
            end
        end
    end
end

function NewFormationView:unloadGridIconEx(iconGrid, iconView)
    self:updateFormationPreview()
    self:updateFormationFilterData()
end

function NewFormationView:updateUIEx()
    if self._crossGodWarInfo._formationPreview._dirty then
        self:updateFormationPreview(true)
    end
end

function NewFormationView:updateRelativeEx()
    self._layerLeft._labelCurrentLoadMC:setVisible(false)
    self._layerLeft._labelNextUnlockLoad:setVisible(false)
    self._crossGodWarInfo._btnLeft:setSaturation(self._context._formationId > self._formationModel.kFormationTypeCrossGodWar1 and 0 or -100)
    self._crossGodWarInfo._btnRight:setSaturation(self._context._formationId < self._formationModel.kFormationTypeCrossGodWar3 and 0 or -100)
    local index = self._context._formationId - self._formationModel.kFormationTypeCrossGodWar1 + 1
    self._crossGodWarInfo._labelTitle:setString("第" .. index .. "局")
    for i = 1, 3 do
        local selected = i == index
        self._crossGodWarInfo._formationPreview[i]._layer:setScale(selected and 0.78 or 0.65)
        self._crossGodWarInfo._formationPreview[i]._imageSelected:setVisible(selected)
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
    if self:isNeedSaveRequired() then
        self._viewMgr:showTip(lang("TIPS_BAOCUNBUZHEN"))
        self:doCrossGodWarSave(function (success)
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

function NewFormationView:onButtonChangeTreasureClicked()
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
    if self:isNeedSaveRequired() then
        self:doCrossGodWarSave(function(success)
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

function NewFormationView:onButtonLeftClicked()
    if self._context._formationId <= self._formationModel.kFormationTypeCrossGodWar1 then return end
    local formationId = self._context._formationId - 1
    self:switchFormation(formationId)
end

function NewFormationView:onButtonRightClicked()
    if self._context._formationId >= self._formationModel.kFormationTypeCrossGodWar3 then return end
    local formationId = self._context._formationId + 1
    self:switchFormation(formationId)
end

function NewFormationView:switchFormation(formationId)
    if self._context._formationId == formationId then return end

    local doSwitchFormation = function()
        self._context._formationId = formationId
        self._layerLeft._teamFormation._data = clone(self._formationModel:getFormationData())
        self:updateFormationFilterData()
        self:updateUI()
    end
    
    if self:isNeedSaveRequired() then
        self._viewMgr:lock(-1)
        self:doCrossGodWarSave(function(success)
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

function NewFormationView:isNeedSaveRequired(  )
	for formationId = self._formationModel.kFormationTypeCrossGodWar1, self._formationModel.kFormationTypeCrossGodWar3 do
		if self:isSaveRequired(formationId) then
			return true
		end
	end
	return false
end

function NewFormationView:doCrossGodWarSave( callback )
	local saveData = {}
	local formationId1 = self._context._formationId
    local formationData1 = self._layerLeft._teamFormation._data[formationId1]
    saveData[formationId1] = formationData1
    for id = self._formationModel.kFormationTypeCrossGodWar1, self._formationModel.kFormationTypeCrossGodWar3 do
    	if id ~= formationId1 then
    		saveData[id] = self._layerLeft._teamFormation._data[id]
    	end
    end

    self._formationModel:saveCrossGodWarData(saveData, callback)
end

function NewFormationView:onButtonSwapClicked()
	self._viewMgr:showDialog("formation.NewFormationSwapView", 
        {
            container = self, 
            formationData = clone(self._layerLeft._teamFormation._data),
            swapType = 2,
            formationId = self._formationModel.kFormationTypeCrossGodWar1,
            callback1 = function(newFormationData)
                for formationId = self._formationModel.kFormationTypeCrossGodWar1, self._formationModel.kFormationTypeCrossGodWar3 do
                    self._layerLeft._teamFormation._data[formationId] = clone(newFormationData[formationId])
                end
                self._crossGodWarInfo._formationPreview._dirty = true
                self:updateFormationFilterData()
                self:updateUI()
            end,
            allowBattle = {
            	[self._formationModel.kFormationTypeCrossGodWar1] = true,
            	[self._formationModel.kFormationTypeCrossGodWar2] = true,
            	[self._formationModel.kFormationTypeCrossGodWar3] = true
            },
        }, 
        true)
end

function NewFormationView:onButtonSaveClicked()
    if self:isNeedSaveRequired() then
        self._viewMgr:lock(-1)
        self:doCrossGodWarSave(function(success)
            if not success then
                self._viewMgr:showTip(lang("GODWARBZ_5"))
                self._viewMgr:unlock()
                return
            end
            self._viewMgr:showTip(lang("GODWARBZ_4"))
            self._viewMgr:unlock()
        end)
    else
        self._viewMgr:showTip(lang("GODWARBZ_4"))
    end
end

function NewFormationView:onButtonFormationSelectClicked(index)
    if index < 1 or index > 3 then return end
    local formationId = self._formationModel.kFormationTypeCrossGodWar1 - 1 + index
    self:switchFormation(formationId)
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
            local formationId = self._formationModel.kFormationTypeCrossGodWar1 - 1 + index
            item:showFormationIndexFlag(true, self._formationFilterData[iconId], false)
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
            local formationId = self._formationModel.kFormationTypeCrossGodWar1 - 1 + index
            item:showFormationIndexFlag(true, self._formationFilterData[iconId], false)
        else
            item:showFormationIndexFlag(false, self._formationFilterData[iconId], false)
        end
        item:setCustom(data[idx + 1].custom)
        item:setScenarioHero(self:isScenarioHero(iconId))
        item:updateState(NewFormationIconView.kIconStateImage, true)
    end
    return cell
end

function NewFormationView:updateFormationPreview(updateAll)
    local updateFormationPreviewByFormationId = function(formationId)
        if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[formationId]) then return end

        local currentIndex = formationId - self._formationModel.kFormationTypeCrossGodWar1 + 1
        for i = 1, NewFormationView.kTeamGridCount do
            self._crossGodWarInfo._formationPreview[currentIndex]._formationUI[i]:removeAllChildren()
        end

        local formationData = self._layerLeft._teamFormation._data[formationId]
        for i = 1, NewFormationView.kTeamMaxCount do
            repeat
                local teamId = formationData[string.format("team%d", i)]
                if 0 == teamId then break end
                local teamPositionId = formationData[string.format("g%d", i)]
                local teamTableData = tab:Team(teamId)
                local iconGrid = self._crossGodWarInfo._formationPreview[currentIndex]._formationUI[teamPositionId]
                local imageView = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
                imageView:setScale(0.75)
                imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
                iconGrid:addChild(imageView)
            until true
        end
    end

    for i=1, 3 do
        local formationId = self._formationModel.kFormationTypeCrossGodWar1 - 1 + i
        self._crossGodWarInfo._formationPreview[i]._layer:setSaturation(0)
    end

    if updateAll then
        if not self._crossGodWarInfo._formationPreview._dirty then return end
        for formationId = self._formationModel.kFormationTypeCrossGodWar1, self._formationModel.kFormationTypeCrossGodWar3 do
            updateFormationPreviewByFormationId(formationId)
        end
        self._crossGodWarInfo._formationPreview._dirty = false
    else
        updateFormationPreviewByFormationId(self._context._formationId)
    end
end