--[[
 	@FileName 	NewFormationView_GloryArena.lua
	@Authors 	yuxiaojing
	@Date    	2018-08-21 10:44:22
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local NewFormationIconView = require("game.view.formation.NewFormationIconView")

local NewFormationView = require("game.view.formation.NewFormationView")

function NewFormationView:onInitEx(  )
	self._userModel = self._modelMgr:getModel("UserModel")

	local formationTypeList1 = {self._formationModel.kFormationTypeGloryArenaAtk1, self._formationModel.kFormationTypeGloryArenaAtk2, self._formationModel.kFormationTypeGloryArenaAtk3}
	local formationTypeList2 = {self._formationModel.kFormationTypeGloryArenaDef1, self._formationModel.kFormationTypeGloryArenaDef2, self._formationModel.kFormationTypeGloryArenaDef3}
	self._formationTypeList = formationTypeList1
	self._formationTypeInc = 45
	if table.indexof(formationTypeList2, self._formationType) then
		self._formationTypeList = formationTypeList2
		self._formationTypeInc = 108
	end

	self._gloryArenaInfo = {}
	self._gloryArenaInfo._layer = self._layer_information:getChildByFullName("info_left.glory_arena_info")
	self._gloryArenaInfo._layer:setVisible(true)
	self._gloryArenaInfo._btnLeft = self._layer_information:getChildByFullName("info_left.glory_arena_info.image_switch_bg.btn_left")
	self:registerClickEvent(self._gloryArenaInfo._btnLeft, function()
        self:onButtonLeftClicked()
    end)
    self._gloryArenaInfo._btnRight = self._layer_information:getChildByFullName("info_left.glory_arena_info.image_switch_bg.btn_right")
    self:registerClickEvent(self._gloryArenaInfo._btnRight, function()
        self:onButtonRightClicked()
    end)
    self._gloryArenaInfo._labelTitle = self._layer_information:getChildByFullName("info_left.glory_arena_info.image_switch_bg.label_title")
    self._gloryArenaInfo._labelTitle:enable2Color(1, cc.c4b(255, 232, 125, 255))
    self._gloryArenaInfo._labelTitle:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._gloryArenaInfo._labelRemainTime1 = self._layer_information:getChildByFullName("info_left.glory_arena_info.image_switch_bg.label_remain_time_1")
    self._gloryArenaInfo._labelRemainTime1:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._gloryArenaInfo._labelRemainTime2 = self._layer_information:getChildByFullName("info_left.glory_arena_info.image_switch_bg.label_remain_time_2")
    self._gloryArenaInfo._labelRemainTime2:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._gloryArenaInfo._labelRemainTime3 = self._layer_information:getChildByFullName("info_left.glory_arena_info.image_switch_bg.label_remain_time_3")
    self._gloryArenaInfo._labelRemainTime3:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self._gloryArenaInfo._labelRemainTime1:setVisible(false)
    self._gloryArenaInfo._labelRemainTime2:setVisible(false)
    self._gloryArenaInfo._labelRemainTime3:setVisible(false)

    self._gloryArenaInfo._buttonSwapFormation = self._layer_information:getChildByFullName("info_left.glory_arena_info.layer_formation_select.btn_swap_formation")
    self:registerClickEvent(self._gloryArenaInfo._buttonSwapFormation, function()
        self:onButtonSwapClicked()
    end)

    self._gloryArenaInfo._buttonQuickSave = self._layer_information:getChildByFullName("info_left.glory_arena_info.layer_formation_select.btn_info_formation")
    self:registerClickEvent(self._gloryArenaInfo._buttonQuickSave, function()
        self:onFormationInfoClicked()
    end)

    self._gloryArenaInfo._buttonBattle = self._layer_information:getChildByFullName("info_left.glory_arena_info.layer_formation_select.btn_battle")
    self:registerClickEvent(self._gloryArenaInfo._buttonBattle, function()
        self:onButtonBattleClicked()
    end)

    if self._formationTypeInc == 45 then
    	self._gloryArenaInfo._buttonSwapFormation:setVisible(true)
    	self._gloryArenaInfo._buttonBattle:setVisible(true)
    else
    	self._gloryArenaInfo._buttonQuickSave:setVisible(true)
    end

    self._gloryArenaInfo._formationPreview = {}
    self._gloryArenaInfo._formationPreview._dirty = true
    for i = 1, 3 do
        self._gloryArenaInfo._formationPreview[i] = {}
        self._gloryArenaInfo._formationPreview[i]._layer = self._layer_information:getChildByFullName("info_left.glory_arena_info.layer_formation_select.layer_formation_" .. i)
        self:registerClickEvent(self._gloryArenaInfo._formationPreview[i]._layer, function()
            self:onButtonFormationSelectClicked(i)
        end)
        self._gloryArenaInfo._formationPreview[i]._labelIndex = self._layer_information:getChildByFullName("info_left.glory_arena_info.layer_formation_select.layer_formation_" .. i .. ".label_index")
        self._gloryArenaInfo._formationPreview[i]._labelIndex:enableOutline(cc.c4b(60, 30, 10, 255), 1)
        self._gloryArenaInfo._formationPreview[i]._imageSelected = self._layer_information:getChildByFullName("info_left.glory_arena_info.layer_formation_select.layer_formation_" .. i .. ".image_selected")
        self._gloryArenaInfo._formationPreview[i]._formationUI = {}
        for j = 1, NewFormationView.kTeamGridCount do
            self._gloryArenaInfo._formationPreview[i]._formationUI[j] = self._layer_information:getChildByFullName("info_left.glory_arena_info.layer_formation_select.layer_formation_" .. i .. ".formation_icon_" .. j)
        end
    end

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
        local formationId = self._formationTypeList[1] - 1 + index
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
    for formationId = self._formationTypeList[1], self._formationTypeList[3] do
        local formationData = self._layerLeft._teamFormation._data[formationId]
        repeat
            if not formationData then break end
            for i = 1, NewFormationView.kTeamMaxCount do
                repeat
                    local teamId = formationData[string.format("team%d", i)]
                    if not teamId or 0 == teamId then break end
                    self._formationFilterData[teamId] = formationId - self._formationTypeInc
                until true
            end

            for i = 1, NewFormationView.kInsMaxCount do
                repeat
                    local weaponId = formationData[string.format("weapon%d", i)]
                    if not weaponId or 0 == weaponId then break end
                    self._formationFilterData[weaponId] = formationId - self._formationTypeInc
                until true
            end

            local heroId = formationData.heroId
            if heroId and 0 ~= heroId then
                self._formationFilterData[heroId] = formationId - self._formationTypeInc
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
    self._gloryArenaInfo._formationPreview._dirty = true
    self:updateFormationPreview(true)
    self:updateFormationFilterData()
end

function NewFormationView:dealWithGodWarFormationData(iconType, iconId)
    for formationId = self._formationTypeList[1], self._formationTypeList[3] do
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
    if self._gloryArenaInfo._formationPreview._dirty then
        self:updateFormationPreview(true)
    end
end

function NewFormationView:updateRelativeEx()
    self._layerLeft._labelCurrentLoadMC:setVisible(false)
    self._layerLeft._labelNextUnlockLoad:setVisible(false)
    self._gloryArenaInfo._btnLeft:setSaturation(self._context._formationId > self._formationTypeList[1] and 0 or -100)
    self._gloryArenaInfo._btnRight:setSaturation(self._context._formationId < self._formationTypeList[3] and 0 or -100)
    local index = self._context._formationId - self._formationTypeList[1] + 1
    self._gloryArenaInfo._labelTitle:setString("第" .. index .. "局")
    for i = 1, 3 do
        local selected = i == index
        self._gloryArenaInfo._formationPreview[i]._layer:setScale(selected and 0.78 or 0.65)
        self._gloryArenaInfo._formationPreview[i]._imageSelected:setVisible(selected)
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
        self:doGloryArenaSave(function (success)
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
        local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
        self._viewMgr:showDialog("treasure.TreasureSelectFormDialog",{
            tFormId = formationData.tid or 1,
            formationId = self._context._formationId,
            callback = function( formId )
                formationData.tid = formId
                self:updateTreasureInfo()
            end})
    end
    -- 改变宝物编组前先保存编组
    if self:isNeedSaveRequired() then
        self:doGloryArenaSave(function(success)
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
    if self._context._formationId <= self._formationTypeList[1] then return end
    local formationId = self._context._formationId - 1
    self:switchFormation(formationId)
end

function NewFormationView:onButtonRightClicked()
    if self._context._formationId >= self._formationTypeList[3] then return end
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
        self:doGloryArenaSave(function(success)
            if not success then
                self._viewMgr:showTip(lang("GODWARBZ_5"))
                self._viewMgr:unlock()
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
	for formationId = self._formationTypeList[1], self._formationTypeList[3] do
		if self:isSaveRequired(formationId) then
			return true
		end
	end
	return false
end

function NewFormationView:doGloryArenaSave( callback )
	local saveData = {}
	local formationId1 = self._context._formationId
    local formationData1 = self._layerLeft._teamFormation._data[formationId1]
    saveData[formationId1] = formationData1
    for id = self._formationTypeList[1], self._formationTypeList[3] do
    	if id ~= formationId1 then
    		saveData[id] = self._layerLeft._teamFormation._data[id]
    	end
    end

    self._formationModel:saveGloryArenaData(saveData, callback)
end

function NewFormationView:onButtonSwapClicked()
	self._viewMgr:showDialog("formation.NewFormationSwapView", 
        {
            container = self, 
            formationData = clone(self._layerLeft._teamFormation._data),
            swapType = 2,
            formationId = self._formationTypeList[1],
            callback1 = function(newFormationData)
                for formationId = self._formationTypeList[1], self._formationTypeList[3] do
                    self._layerLeft._teamFormation._data[formationId] = clone(newFormationData[formationId])
                end
                self._gloryArenaInfo._formationPreview._dirty = true
                self:updateFormationFilterData()
                self:updateUI()
            end,
            allowBattle = {
            	[self._formationTypeList[1]] = true,
            	[self._formationTypeList[2]] = true,
            	[self._formationTypeList[3]] = true
            },
        }, 
        true)
end

function NewFormationView:onFormationInfoClicked()
    self._viewMgr:showDialog("formation.NewFormationSwapView", 
        {
            container = self, 
            formationData = clone(self._layerLeft._teamFormation._data),
            swapType = 3,
            formationId = self._formationTypeList[1],
            callback1 = function(newFormationData, showState)
                local isSendHideArray = false
                for formationId = self._formationTypeList[1], self._formationTypeList[3] do
                    self._layerLeft._teamFormation._data[formationId] = clone(newFormationData[formationId])
                    if self._extend.showState[formationId] ~= showState[formationId] then
                        isSendHideArray = true
                    end
                    self._extend.showState[formationId] = showState[formationId]
                end
                -- 这里判断self._extend.showState是否变化然后保存
                if isSendHideArray then
                    local hideArray = {}
                    for i, v in pairs(self._extend.showState) do
                        if not v then
                            hideArray[#hideArray + 1] = tonumber(i)
                        end
                    end
                    self._serverMgr:sendMsg("CrossArenaServer", "hiddenFormation", {hiddens = hideArray}, true, {}, function(result)
                        if result and result.errorCode and result.errorCode ~= 0 then
                            local gloryArenaModel = self._modelMgr:getModel("GloryArenaModel")
                            local hideArray = gloryArenaModel:lGetHideArray()
                            local showState = {
                                [self._formationModel.kFormationTypeGloryArenaDef1] = not (hideArray[self._formationModel.kFormationTypeGloryArenaDef1] or false),
                                [self._formationModel.kFormationTypeGloryArenaDef2] = not (hideArray[self._formationModel.kFormationTypeGloryArenaDef2] or false),
                                [self._formationModel.kFormationTypeGloryArenaDef3] = not (hideArray[self._formationModel.kFormationTypeGloryArenaDef3] or false),
                            }
                            gloryArenaModel:reflashEnterCrossArena(function()
                                local rewardData = gloryArenaModel:lGetRankReward()
                                local hideCount = 0
                                if rewardData then
                                    hideCount = rewardData.hideTimeNum or 0
                                end     
                                self._extend.gloryArenaLimit = hideCount
                                self._extend.showState = clone(showState)
                            end)
                        end
                    end)
                end

                self._gloryArenaInfo._formationPreview._dirty = true
                self:updateFormationFilterData()
                self:updateUI()
            end,
            allowBattle = {
            	[self._formationTypeList[1]] = true,
            	[self._formationTypeList[2]] = true,
            	[self._formationTypeList[3]] = true
            },
            showState = clone(self._extend.showState),
            gloryArenaLimit = self._extend.gloryArenaLimit
        }, 
        true)
end

function NewFormationView:onButtonBattleClicked(  )
	if self:isNeedSaveRequired() then
        self:doGloryArenaSave(function(success)
            if not success then
                self._viewMgr:showTip(lang("TIP_BUZHEN_3"))
                return
            end
            self:doBattle()
        end)
        return
    end
    self:doBattle()
end

function NewFormationView:isTeamAndHeroFull(  )
    for formationId = self._formationTypeList[1], self._formationTypeList[3] do
        local data = self._layerLeft._teamFormation._data[formationId]
        local team_count = 0
        local hireTeamId = 0
        table.walk(data, function(v, k)
            if 0 == v or (self:isFiltered(v) and v ~= hireTeamId) then return end
            if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
                team_count = team_count + 1
            end
        end)
        if team_count == 0 then
            return 1
        end
        local data = self._layerLeft._teamFormation._data[formationId]
        if 0 == data.heroId then
            return 1
        end
    end
    return 0
end

function NewFormationView:doBattle()

    if self._formationType == self._formationModel.kFormationTypeAdventure and not self:isCanBattle() then
        self._viewMgr:showTip("小骷髅正在准备开启新的冒险，还请耐心等待一会哦~")
        return 
    end

    local isFull = self:isTeamAndHeroFull()
    if isFull and isFull == 1 then
        self._viewMgr:showTip(lang("honorArena_tip_5"))
        return
    end

    local battle = function()
        local battleData = self._formationModel:initBattleData(self._formationType, clone(self._layerLeft._teamFormation._data[self._context._formationId]))
        if self._battleCallBack and type(self._battleCallBack) == "function" then
            self._battleCallBack(battleData[1], 
                self:getCurrentLoadedTeamCountWithFilter(), 
                self:getCurrentTeamFilterCount(), 
                self._context._formationId, 
                self:isScenarioHero(self._layerLeft._teamFormation._data[self._context._formationId].heroId), 
                self:hireTeamLoadedPosition(),
                self:getLoadedHireTeam())
        end
    end

    local beforeBattle = function()
        audioMgr:playSound("enterBattle")
        if self._extend.physical then
            self._viewMgr:lock(9999)
            local nodes = {}
            nodes[1] = cc.Sprite:createWithSpriteFrameName("globalImageUI4_power.png")
            nodes[2] = cc.Label:createWithTTF("-" .. self._extend.physical, UIUtils.ttfName, 24)
            nodes[2]:setColor(cc.c4b(90, 248, 13, 255))
            nodes[2]:enableOutline(cc.c4b(0, 0, 0,255), 2)
            local node = UIUtils:createHorizontalNode(nodes)
            node:setAnchorPoint(cc.p(0.5, 0.5))
            node:setPosition(self._btnBattle:getPositionX(), self._btnBattle:getPositionY() + 20)
            self._btnBattle:getParent():addChild(node, 100)
            node:setCascadeOpacityEnabled(true, true)
            node:setOpacity(0)
            node:runAction(cc.Sequence:create(
                cc.Spawn:create(cc.MoveBy:create(0.05, cc.p(0, 30)), cc.FadeIn:create(0.05)),
                cc.MoveBy:create(0.3, cc.p(0, 30)),
                cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, 30)), cc.FadeOut:create(0.2)),
                cc.CallFunc:create(function()
                    node:removeFromParent()
                    self._viewMgr:unlock()
                    battle()
            end)))
        elseif self:isShowReadyBattle() then
            self:updateLeagueBattleInfo()
        else
            battle()
        end
    end

    if not self:isTeamLoadedFull() and self:isShowBattleTip() and not self._formationModel.getFormationDialogShowed() then
        self._formationModel.setFormationDialogShowed(true)
        self._viewMgr:showSelectDialog(lang("TIP_YINDAOBUZHEN_BUMAN"), "", function()
            beforeBattle()
        end, "")
    elseif self._formationModel:isFieldSkillEmpty(self._formationType, self:getUsingHireTeamData()) and not self._formationModel:isShowFieldDialogByType(self._formationType) then
        self._formationModel:setShowFieldDialogByType(self._formationType)
        self._viewMgr:showSelectDialog(lang("LINGYUTIPS_COMMON"), "", function()
            beforeBattle()
        end, "")
    else
        beforeBattle()
    end
end

function NewFormationView:onButtonFormationSelectClicked(index)
    if index < 1 or index > 3 then return end
    local formationId = self._formationTypeList[1] - 1 + index
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
            local formationId = self._formationTypeList[1] - 1 + index
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
            local formationId = self._formationTypeList[1] - 1 + index
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

        local currentIndex = formationId - self._formationTypeList[1] + 1
        for i = 1, NewFormationView.kTeamGridCount do
            self._gloryArenaInfo._formationPreview[currentIndex]._formationUI[i]:removeAllChildren()
        end

        local formationData = self._layerLeft._teamFormation._data[formationId]
        for i = 1, NewFormationView.kTeamMaxCount do
            repeat
                local teamId = formationData[string.format("team%d", i)]
                if 0 == teamId then break end
                local teamPositionId = formationData[string.format("g%d", i)]
                local teamTableData = tab:Team(teamId)
                local iconGrid = self._gloryArenaInfo._formationPreview[currentIndex]._formationUI[teamPositionId]
                local imageView = ccui.ImageView:create(IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(teamTableData, "classlabel") .. ".png", 1)
                imageView:setScale(0.75)
                imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
                iconGrid:addChild(imageView)
            until true
        end
    end

    for i=1, 3 do
        local formationId = self._formationTypeList[1] - 1 + i
        self._gloryArenaInfo._formationPreview[i]._layer:setSaturation(0)
    end

    if updateAll then
        if not self._gloryArenaInfo._formationPreview._dirty then return end
        for formationId = self._formationTypeList[1], self._formationTypeList[3] do
            updateFormationPreviewByFormationId(formationId)
        end
        self._gloryArenaInfo._formationPreview._dirty = false
    else
        updateFormationPreviewByFormationId(self._context._formationId)
    end
end