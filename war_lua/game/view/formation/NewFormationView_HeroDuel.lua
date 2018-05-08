--[[
    Filename:    NewFormationView_HeroDuel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-01-23 16:55:16
    Description: File description
--]]


local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local NewFormationView = require("game.view.formation.NewFormationView")

NewFormationView.kHeroDuelStateInit = 1000
NewFormationView.kHeroDuelStateReady = 1100
NewFormationView.kHeroDuelStateNotReady = 1008
NewFormationView.kHeroDuelStatePickTeam = 1001
NewFormationView.kHeroDuelStateWaitTeam = 1002
NewFormationView.kHeroDuelStatePickHero = 1003
NewFormationView.kHeroDuelStateWaitHero = 1009
NewFormationView.kHeroDuelStatePickTeamAI = 1010
NewFormationView.kHeroDuelStateFinish = 1004
NewFormationView.kHeroDuelStateWin = 1005
NewFormationView.kHeroDuelStateLose = 1006
NewFormationView.kHeroDuelStateIgnore = 1007
NewFormationView.kHeroDuelStateError = 2000

NewFormationView.kTagIconEnemy = 10000
NewFormationView.kTagIconEnemyEffect = 10001

function NewFormationView:onInitEx()

    self._heroDuelConfig = {
        _teamPickTime = tab:Setting("DUEL_CHOOSE1").value,
        _heroPickTime = tab:Setting("DUEL_CHOOSE2").value,
        _maxStep = 6,
    }

    self._heroDuelContext = {
        _section = 0,
        _step = 0,
        _state = NewFormationView.kHeroDuelStateInit,
        _remainTime = -1,
        _remainPrintTime = -1,
        _timeStamp = 0,
        _timeTick = 0,
        _remainAITime = -1,
        _heroDuelAIData = {},
        _pickNum = 0,
        _pickedCount = 0,
    }

    self._random = require("game.utils.random").new()

    self._enemyFormationData = {
        [self._context._formationId] = {}
    }

    self._userModel = self._modelMgr:getModel("UserModel")

    self._enemyFormationDataCache = clone(self._enemyFormationData[self._context._formationId])
    self._currentRoundLoadedEnemy = {}
    self._isShowEnemyLoadedEffect = false

    self._heroDuelInfo = {}
    self._heroDuelInfo._ui = self:getUI("bg.layer_information.info_left.hero_duel_info")
    self._heroDuelInfo._ui:setVisible(true)
    self._heroDuelInfo._roundLeftGray = self:getUI("bg.layer_information.info_left.hero_duel_info.image_round_gray_left")
    self._heroDuelInfo._labelRoundLeft = self:getUI("bg.layer_information.info_left.hero_duel_info.label_my_round")
    self._heroDuelInfo._roundRightGray = self:getUI("bg.layer_information.info_left.hero_duel_info.image_round_gray_right")
    self._heroDuelInfo._labelRoundRight = self:getUI("bg.layer_information.info_left.hero_duel_info.label_enemy_round")
    self._heroDuelInfo._labelCountDown = self:getUI("bg.layer_information.info_left.hero_duel_info.count_down_bg.label_count_down")
    self._heroDuelInfo._imageTipsBg = self:getUI("bg.layer_left.image_tips_bg")
    self._heroDuelInfo._labelTips0 = self:getUI("bg.layer_left.image_tips_bg.label_tips_0")
    self._heroDuelInfo._labelTips0:enableOutline(cc.c4b(60, 30, 10), 1)
    self._heroDuelInfo._labelTips1 = self:getUI("bg.layer_left.image_tips_bg.label_tips_1")
    self._heroDuelInfo._labelTips1:enableOutline(cc.c4b(60, 30, 10), 1)
    self._heroDuelInfo._labelTips2 = self:getUI("bg.layer_left.image_tips_bg.label_tips_2")
    self._heroDuelInfo._labelTips2:enableOutline(cc.c4b(60, 30, 10), 1)
    self._heroDuelInfo._labelTips3 = self:getUI("bg.layer_left.image_tips_bg.label_tips_3")
    self._heroDuelInfo._labelTips3:enableOutline(cc.c4b(60, 30, 10), 1)

    self._heroDuelInfo._layerMask = self:getUI("bg.layer_left.layer_list.layer_list_mask")
    self._heroDuelInfo._labelMask = self:getUI("bg.layer_left.layer_list.layer_list_mask.label_mask")
    self._heroDuelInfo._labelMask:enableOutline(cc.c4b(60, 30, 10), 1)
    --self._imageBattle = self:getUI("bg.layer_information.btn_battle.image_battle")
    self._imageOk = self:getUI("bg.layer_information.btn_battle.image_ok")

    self._layerLeft._layerRightFormation._layer:setVisible(true)
    self._layerLeft._layerRightFormation._layer:setTouchEnabled(false)
    self._layerLeft._labelCurrentFightScore:setVisible(false)
    self._layerLeft._layerRightFormationScore:setVisible(false)

    self._myTurnMC = mcMgr:createViewMC("wodehuihe_duizhanui", true, false)
    self._myTurnMC:stop()
    self._myTurnMC:setVisible(false)
    self._myTurnMC:setPosition(self._winSize1.width / 2, self._winSize1.height / 1.8)
    self._layerLeft._layer:addChild(self._myTurnMC, 1000)

    self._youTurnMC = mcMgr:createViewMC("duishouhuihe_duizhanui", true, false)
    self._youTurnMC:stop()
    self._youTurnMC:setVisible(false)
    self._youTurnMC:setPosition(self._winSize1.width / 2, self._winSize1.height / 1.8)
    self._layerLeft._layer:addChild(self._youTurnMC, 1000)

    self._weTurnMC = mcMgr:createViewMC("gongtonghuihe_duizhanui", true, false)
    self._weTurnMC:stop()
    self._weTurnMC:setVisible(false)
    self._weTurnMC:setPosition(self._winSize1.width / 2, self._winSize1.height / 1.8)
    self._layerLeft._layer:addChild(self._weTurnMC, 1000)

    --[[
    self._heroDuelEventDispatcher = cc.Director:getInstance():getEventDispatcher()
    self._heroDuelEventListener = cc.EventListenerCustom:create("HERO_DUEL_EVENT", handler(self, self.onPushHeroDuelEvent))
    self._heroDuelEventDispatcher:addEventListenerWithFixedPriority(self._heroDuelEventListener, 1)
    ]]

    self:setListenReflashWithParam(true)
    self:listenReflash("HeroDuelModel", self.onPushHeroDuelEvent)

    --self:listenRSResponse(specialize(self.onSocektResponse, self))

    self:updateFormationState()
end

function NewFormationView:onEnterEx()

end

function NewFormationView:onExitEx()
    self:endCountDownTimer()
    if self._heroDuelEventDispatcher and self._heroDuelEventListener then
        self._heroDuelEventDispatcher:removeEventListener(self._heroDuelEventListener)
    end
end

function NewFormationView:isShowEnemyFormation()
    return false
end

function NewFormationView:isShowEnemyFormationCheckArrow()
    return false
end

function NewFormationView:showEnemayFormation()

end

function NewFormationView:updateFormationState(data)
    self:endCountDownTimer()
    if self._heroDuelContext._state == NewFormationView.kHeroDuelStateInit then
        self._viewMgr:lock(-1)
        self:setFormationLocked(true)
        self._layerLeft._layerList._btnTabHero:setSaturation(-100)
        --self._layerLeft._layerList._btnTabHero:setEnabled(false)
        self._imageBattle:setVisible(false)
        self._imageOk:setVisible(true)
        self:updateLeftTeamFormationAddition(true)
        self:updateLeftHeroAddition(true)
        self:updateRoundInfo()
        ScheduleMgr:delayCall(0, nil, function()
            if not (self._heroDuelContext and
                self._heroDuelContext._state and
                self.updateFormationState and
                self._viewMgr) then
                ViewManager:getInstance():unlock(-1)
                return
            end
            self._viewMgr:unlock(-1)
            self._heroDuelContext._state = NewFormationView.kHeroDuelStateReady
            self:updateFormationState()
        end)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateNotReady then
        self:setFormationLocked(true)
        self:updateRoundInfo()
        self:startCountDownClock()
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateReady then
        --[[
        self._serverMgr:sendMsg("HeroDuelServer", "hDuelSetFormReady", {args = json.encode({step = 0})}, true, {}, function(success, data)
            if not success then
                self:handleErrorData(data)
                return
            end
            self:handleOptionData(data)
        end)
        ]]
        self._serverMgr:RS_sendMsg("PlayerProcessor", "teamSelectReady", {})
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeam then
        self._viewMgr:lock(-1)

        self._myTurnMC:addEndCallback(function()
            self._myTurnMC:stop()
            self._myTurnMC:setVisible(false)
        end)
        self._myTurnMC:setVisible(true)
        self._myTurnMC:gotoAndPlay(0)

        ScheduleMgr:delayCall(1800, nil, function()
            if not (self._heroDuelContext and
               self._heroDuelContext._pickedCount and
               self.updateLeftTeamFormationAddition and
               self.updateLeftHeroAddition and
               self.setFormationLocked and
               self.updateRoundInfo and
               self.startCountDownClock and 
               self._viewMgr) then
                ViewManager:getInstance():unlock(-1)
                return
            end
            self._heroDuelContext._pickedCount = 0
            self:updateLeftTeamFormationAddition(false)
            self:updateLeftHeroAddition(true)
            self:setFormationLocked(false)
            self:updateRoundInfo(true)
            self:startCountDownClock()
            self._viewMgr:unlock(-1)
        end)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateWaitTeam then
        self._viewMgr:lock(-1)

        self._youTurnMC:addEndCallback(function()
            self._youTurnMC:stop()
            self._youTurnMC:setVisible(false)
        end)
        self._youTurnMC:setVisible(true)
        self._youTurnMC:gotoAndPlay(0)

        ScheduleMgr:delayCall(1800, nil, function()
            if not (self._isShowEnemyLoadedEffect ~= nil and
               self.updateLeftTeamFormationAddition and
               self.updateLeftHeroAddition and
               self.setFormationLocked and
               self.updateRoundInfo and
               self.startCountDownClock and 
               self._viewMgr) then
                ViewManager:getInstance():unlock(-1)
                return
            end
            self._isShowEnemyLoadedEffect = false
            self:updateLeftTeamFormationAddition(true)
            self:updateLeftHeroAddition(true)
            self:setFormationLocked(true)
            self:updateRoundInfo(false)
            self:startCountDownClock()
            self._viewMgr:unlock(-1)
        end)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeamAI then
        self._viewMgr:lock(-1)

        self._youTurnMC:addEndCallback(function()
            self._youTurnMC:stop()
            self._youTurnMC:setVisible(false)
        end)
        self._youTurnMC:setVisible(true)
        self._youTurnMC:gotoAndPlay(0)

        ScheduleMgr:delayCall(1800, nil, function()
            if not (self._isShowEnemyLoadedEffect ~= nil and
               self.updateLeftTeamFormationAddition and
               self.updateLeftHeroAddition and
               self.setFormationLocked and
               self.updateRoundInfo and
               self.startCountDownClock and 
               self._viewMgr) then
                ViewManager:getInstance():unlock(-1)
                return
            end
            self._isShowEnemyLoadedEffect = false
            self:updateLeftTeamFormationAddition(true)
            self:updateLeftHeroAddition(true)
            self:setFormationLocked(true)
            self:updateRoundInfo(false)
            self:startCountDownClock()
            self._viewMgr:unlock(-1)
        end)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickHero then
        self._viewMgr:lock(-1)

        self._weTurnMC:addEndCallback(function()
            self._weTurnMC:stop()
            self._weTurnMC:setVisible(false)
        end)
        self._weTurnMC:setVisible(true)
        self._weTurnMC:gotoAndPlay(0)

        ScheduleMgr:delayCall(1800, nil, function()
            if not (self._heroDuelContext and
               self._heroDuelContext._pickedCount and
               self._layerLeft and
               self._layerLeft._layerList and
               self._layerLeft._layerList._btnTabTeam and
               self._layerLeft._layerList._btnTabTeam.setSaturation and
               self._layerLeft._layerList._btnTabHero and
               self._layerLeft._layerList._btnTabHero.setSaturation and
               self.switchLayerList and
               self._imageBattle and
               self._imageBattle.setVisible and
               self._imageOk and
               self._imageOk.setVisible and
               self.updateLeftTeamFormationAddition and
               self.updateLeftHeroAddition and
               self.setFormationLocked and
               self.updateRoundInfo and
               self.startCountDownClock and 
               self._viewMgr) then
                ViewManager:getInstance():unlock(-1)
                return
            end
            self._heroDuelContext._pickedCount = 0
            self._layerLeft._layerList._btnTabTeam:setSaturation(-100)
            --self._layerLeft._layerList._btnTabTeam:setEnabled(false)
            self._layerLeft._layerList._btnTabHero:setSaturation(0)
            --self._layerLeft._layerList._btnTabHero:setEnabled(true)
            self:switchLayerList(NewFormationView.kGridTypeHero, true)
            self._imageBattle:setVisible(true)
            self._imageOk:setVisible(false)
            self:updateLeftTeamFormationAddition(true)
            self:updateLeftHeroAddition(false)
            self:setFormationLocked(false)
            self:updateRoundInfo()
            self:startCountDownClock()
            self._viewMgr:unlock(-1)
        end)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateWaitHero then
        self:updateLeftTeamFormationAddition(true)
        self:updateLeftHeroAddition(true)
        self:setFormationLocked(true)
        self:updateRoundInfo()
        self:startCountDownClock()
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateWin then
        self:setFormationLocked(true)
        self:closeHeroDuelFormation(NewFormationView.kHeroDuelStateWin, data)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateLose then
        self:setFormationLocked(true)
        self:closeHeroDuelFormation(NewFormationView.kHeroDuelStateLose, data)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateFinish then
        self:setFormationLocked(true)
        self:onBattleButtonClicked()
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateIgnore then
        self:setFormationLocked(true)
        self:closeHeroDuelFormation(NewFormationView.kHeroDuelStateIgnore, data)
    end
end

function NewFormationView:handleErrorData(data)
    self:closeHeroDuelFormation(NewFormationView.kHeroDuelStateIgnore, data)
end

function NewFormationView:checkOptionData(data)
    return data and data.self and data.self.formOp and NewFormationView.kHeroDuelStateError ~= data.self.formOp.turn
end

function NewFormationView:checkCarryData(data)
    return data and data._carry_ and data._carry_.heroDuelAI.time and data._carry_.heroDuelAI.hDuelFormAI
end

function NewFormationView:checkFormationData(data)
    if not data then data = {} end
    local formationData = {}
    for i=1, NewFormationView.kTeamMaxCount do
        formationData["team" .. i] = data["team" .. i] or 0
        formationData["g" .. i] = data["g" .. i] or 0
        formationData["d" .. i] = data["d" .. i] or 0
    end
    if 0 ~= data["heroId"] then
        formationData["heroId"] = data["heroId"] or 0
    end
    return formationData
end
--[[
function NewFormationView:onSocektResponse(data)

    if data.error ~= nil then
        return
    end

    local status = 0
    local result = nil
    if data.result and data.result["common"] then
        result = data.result
        status = result["common"].status
    end

    if status == self._heroDuelModel.BATTLE_END and data.result["common"].quit ~= self._heroDuelModel.EXIT_NORMAL then
        self:closeHeroDuelFormation()
    end
end
]]
function NewFormationView:onPushHeroDuelEvent(eventName)
    if not (self._heroDuelModel and self._heroDuelModel.BATTLE_END_EVENT and self.closeHeroDuelFormation and self.handleOptionData) then return end
    if eventName == self._heroDuelModel.BATTLE_END_EVENT then
        self:closeHeroDuelFormation()
        return
    end
    local data = self._heroDuelModel:getFormaRoomData()
--    dump(data, "onPushHeroDuelEvent", 5)
    self:handleOptionData(data)
end

function NewFormationView:handleOptionData(data)
    if not self:checkOptionData(data) then return end
    --self._heroDuelContext._section = data.self.formOp.section
    self._heroDuelContext._step = data.self.formOp.step
    self._heroDuelContext._state = data.self.formOp.turn
    self._heroDuelContext._pickNum = data.self.formOp.num
    self._heroDuelContext._remainTime = data.self.formOp.time - self._userModel:getCurServerTime() + data.self.formOp.lot
    self._heroDuelContext._remainPrintTime = data.self.formOp.ptime - self._userModel:getCurServerTime() + data.self.formOp.lot
    self._heroDuelContext._timeTick = self._heroDuelContext._remainTime / self._heroDuelContext._remainPrintTime
    self._heroDuelContext._remainAITime = -1
    self._layerLeft._teamFormation._data[self._context._formationId] = self:checkFormationData(data.self.form)
    self:updateLeftTeamFormation()
    self:updateLeftHeroFormation()
    self:lockPickedFormation()
    if self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeamAI then
        if not self:checkCarryData(data) then return end
        self._heroDuelContext._remainAITime = data._carry_.heroDuelAI.time - self._userModel:getCurServerTime() + data.self.formOp.lot
        self._heroDuelContext._heroDuelAIData = data._carry_.heroDuelAI.hDuelFormAI
    else
        self._enemyFormationData[self._context._formationId] = data.self.formC
        self:updateRightTeamFormationPreview()
    end
    self:updateFormationState(data)
end
--[[
function NewFormationView:onPushHeroDuelEvent(event)
    if not (event and event.data) then return end
    if self.handleOptionData then
        self:handleOptionData(event.data)
    end
end
]]
function NewFormationView:updateLeftTeamFormationAddition(forceHide)
    --print("update addition:", formationId)
    if forceHide then
        for i = 1, NewFormationView.kTeamGridCount do
            local iconGrid = self._layerLeft._teamFormation._grid[i]
            iconGrid:unsetState(0x20)
            iconGrid:updateState()
        end
    else
        local isTeamLoadedFull = self:isTeamLoadedFull(nil, true)
        for i = 1, NewFormationView.kTeamGridCount do
            local iconGrid = self._layerLeft._teamFormation._grid[i]
            if self:isLeftGridWall(i) then
                iconGrid:setState(0x80)
            elseif not isTeamLoadedFull and not iconGrid:isStateFull() and not iconGrid:isStateWall() then
                iconGrid:setState(0x20)
            else
                iconGrid:unsetState(0x80)
                iconGrid:unsetState(0x20)
            end
            iconGrid:updateState()
        end
    end
end

function NewFormationView:updateLeftHeroAddition(forceHide)
    local iconGrid = self._layerLeft._heroFormation._grid
    if not forceHide then
        iconGrid:setState(0x20)
    else
        iconGrid:unsetState(0x20)
    end
    iconGrid:updateState()
end

function NewFormationView:updateRoundInfo(myTurn)
    if self._heroDuelContext._state == NewFormationView.kHeroDuelStateInit or
       self._heroDuelContext._state == NewFormationView.kHeroDuelStateNotReady then
        self._heroDuelInfo._roundLeftGray:setVisible(false)
        self._heroDuelInfo._labelRoundLeft:setColor(cc.c3b(255, 255, 255))
        self._heroDuelInfo._labelRoundLeft:setString("准备中...")
        self._heroDuelInfo._roundRightGray:setVisible(false)
        self._heroDuelInfo._labelRoundRight:setColor(cc.c3b(255, 255, 255))
        self._heroDuelInfo._labelCountDown:setString(0)
        self._heroDuelInfo._labelRoundRight:setString("准备中...")
        self._heroDuelInfo._imageTipsBg:setVisible(false)
        self._heroDuelInfo._layerMask:setVisible(true)
        self._heroDuelInfo._labelMask:setString("准备中,请稍后...")
        self._btnBattle:setSaturation(-100)
        self._btnBattle:setEnabled(false)
        self._btnBattle:setVisible(false)
        return
    end

    if self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeam or 
        self._heroDuelContext._state == NewFormationView.kHeroDuelStateWaitTeam or
        self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeamAI then
        self._heroDuelInfo._roundLeftGray:setVisible(not myTurn)
        self._heroDuelInfo._labelRoundLeft:setColor(myTurn and cc.c3b(255, 255, 255) or cc.c3b(128, 128, 128))
        self._heroDuelInfo._labelRoundLeft:setString("我的回合")
        self._heroDuelInfo._roundRightGray:setVisible(myTurn)
        self._heroDuelInfo._labelRoundRight:setColor(not myTurn and cc.c3b(255, 255, 255) or cc.c3b(128, 128, 128))
        self._heroDuelInfo._labelRoundRight:setString("对手回合")
        self._heroDuelInfo._labelCountDown:setString(self._heroDuelContext._remainPrintTime)
        self._heroDuelInfo._imageTipsBg:setVisible(myTurn)
        self._heroDuelInfo._labelTips1:setString(0)
        self._heroDuelInfo._labelTips1:setColor(cc.c3b(255, 0, 0))
        self._heroDuelInfo._labelTips2:setString("/" .. self._heroDuelContext._pickNum)
        self._heroDuelInfo._labelTips3:setString("个兵团上阵")
        self._heroDuelInfo._layerMask:setVisible(not myTurn)
        self._heroDuelInfo._labelMask:setString("对手回合，请耐心等待")
        self._btnBattle:setSaturation(myTurn and 0 or -100)
        self._btnBattle:setEnabled(myTurn)
        self._btnBattle:setVisible(myTurn)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickHero then
        self._heroDuelInfo._roundLeftGray:setVisible(false)
        self._heroDuelInfo._labelRoundLeft:setColor(cc.c3b(255, 255, 255))
        self._heroDuelInfo._labelRoundLeft:setString("共同回合")
        self._heroDuelInfo._roundRightGray:setVisible(false)
        self._heroDuelInfo._labelRoundRight:setColor(cc.c3b(255, 255, 255))
        self._heroDuelInfo._labelCountDown:setString(self._heroDuelContext._remainPrintTime)
        self._heroDuelInfo._labelRoundRight:setString("共同回合")
        self._heroDuelInfo._imageTipsBg:setVisible(true)
        self._heroDuelInfo._labelTips1:setString(0)
        self._heroDuelInfo._labelTips1:setColor(cc.c3b(255, 0, 0))
        self._heroDuelInfo._labelTips2:setString("/" .. self._heroDuelContext._pickNum)
        self._heroDuelInfo._labelTips3:setString("个英雄上阵")
        self._heroDuelInfo._layerMask:setVisible(false)
        self._btnBattle:setSaturation(0)
        self._btnBattle:setEnabled(true)
        self._btnBattle:setVisible(true)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateWaitHero then
        self._heroDuelInfo._roundLeftGray:setVisible(false)
        self._heroDuelInfo._labelRoundLeft:setColor(cc.c3b(255, 255, 255))
        self._heroDuelInfo._labelRoundLeft:setString("共同回合")
        self._heroDuelInfo._roundRightGray:setVisible(false)
        self._heroDuelInfo._labelRoundRight:setColor(cc.c3b(255, 255, 255))
        self._heroDuelInfo._labelCountDown:setString(self._heroDuelContext._remainPrintTime)
        self._heroDuelInfo._labelRoundRight:setString("共同回合")
        self._heroDuelInfo._imageTipsBg:setVisible(false)
        self._heroDuelInfo._layerMask:setVisible(true)
        self._heroDuelInfo._labelMask:setString("请等待对方选择英雄")
        self._btnBattle:setSaturation(-100)
        self._btnBattle:setEnabled(false)
        self._btnBattle:setVisible(false)
    end
end

function NewFormationView:updateBattleInfo()

end

function NewFormationView:getCurrentFightScore(formationId)
    return 0
end

function NewFormationView:updateLeftTeamFormation(formationId)
    formationId = tonumber(formationId) or tonumber(self._context._formationId)
    --print("update team formation id:", formationId)

    if not (self._layerLeft._teamFormation._data and self._layerLeft._teamFormation._data[formationId]) then return end

    for i = 1, NewFormationView.kTeamGridCount do
        self._layerLeft._teamFormation._grid[i]:setIconView()
    end

    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = self._layerLeft._teamFormation._data[formationId][string.format("team%d", i)]
            if 0 == teamId then break end
            local teamPositionId = self._layerLeft._teamFormation._data[formationId][string.format("g%d", i)]
            local teamSubtype = self._layerLeft._teamFormation._data[formationId][string.format("d%d", i)]
            local iconGrid = self._layerLeft._teamFormation._grid[teamPositionId]
            local iconView = NewFormationIconView.new({iconType = NewFormationView.kGridTypeTeam, iconId = teamId, iconSubtype = teamSubtype, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, isCustom = true, container = self})
            --[[
            if self:isFiltered(teamId) then
                iconView:showFilter(true)
            end
            ]]
            local isNeedChanged, changeTeamId = self:isTeamNeedChanged(teamId)
            if isNeedChanged then
                iconView:changeProfile(changeTeamId)
            end
            iconView:setName("icon_"..i)
            iconGrid:setIconView(iconView)
            iconGrid:updateState()
        until true
    end
end

function NewFormationView:updateCurrentRoundLoadedEnemy()
    self._currentRoundLoadedEnemy = {}
    for k, v in pairs(self._enemyFormationData[self._context._formationId]) do
        repeat
            if not string.find(tostring(k), "g") then break end
            local found = false
            for k0, v0 in pairs(self._enemyFormationDataCache) do
                repeat
                    if not string.find(tostring(k0), "g") then break end
                    if v0 == v then
                        found = true
                    end
                until true
                if found then break end
            end

            if not found then
                self._currentRoundLoadedEnemy[v] = true
            end
        until true
    end
end

function NewFormationView:updateRightTeamFormationPreview()

    if not (self._enemyFormationData and self._enemyFormationData[self._formationModel.kFormationTypeHeroDuel]) then return end

    for i = 1, NewFormationView.kTeamGridCount do
        if self._layerLeft._layerRightFormation._icon[i]:getChildByTag(NewFormationView.kTagIconEnemy) then
            self._layerLeft._layerRightFormation._icon[i]:removeChildByTag(NewFormationView.kTagIconEnemy)
        end
    end

    for i = 1, NewFormationView.kTeamGridCount do
        local enemyLoadedMC = self._layerLeft._layerRightFormation._icon[i]:getChildByTag(NewFormationView.kTagIconEnemyEffect)
        if not enemyLoadedMC then
            enemyLoadedMC = mcMgr:createViewMC("difangbuzhentishi_duizhanui", true, false)
            enemyLoadedMC:stop()
            enemyLoadedMC:setVisible(false)
            enemyLoadedMC:setTag(NewFormationView.kTagIconEnemyEffect)
            enemyLoadedMC:setPosition(self._layerLeft._layerRightFormation._icon[i]:getContentSize().width / 2, self._layerLeft._layerRightFormation._icon[i]:getContentSize().height / 2)
            self._layerLeft._layerRightFormation._icon[i]:addChild(enemyLoadedMC, 1000)
        end
        enemyLoadedMC = self._layerLeft._layerRightFormation._icon[i]:getChildByTag(NewFormationView.kTagIconEnemyEffect)
        enemyLoadedMC:setVisible(false)
    end

    if not self._isShowEnemyLoadedEffect then
        self:updateCurrentRoundLoadedEnemy()
        self._enemyFormationDataCache = clone(self._enemyFormationData[self._context._formationId])
    end

    local classLabel = {"tl_shuchu.png", "tl_fangyu.png", "tl_tuji.png", "tl_yuancheng.png", "tl_mofa.png"}

    for i = 1, NewFormationView.kTeamMaxCount do
        repeat
            local teamId = self._enemyFormationData[self._context._formationId][string.format("team%d", i)]
            if 0 == teamId or not teamId then break end
            local teamPositionId = self._enemyFormationData[self._context._formationId][string.format("g%d", i)]
            local teamTableData = tab:Team(teamId)
            local iconGrid = self._layerLeft._layerRightFormation._icon[teamPositionId]
            if not iconGrid then break end
            local imageView = ccui.ImageView:create(IconUtils.iconPath .. classLabel[teamId], 1)
            imageView:setScale(0.75)
            imageView:setPosition(cc.p(iconGrid:getContentSize().width / 2, iconGrid:getContentSize().height / 2))
            imageView:setTag(NewFormationView.kTagIconEnemy)           
            iconGrid:addChild(imageView)
            if not self._isShowEnemyLoadedEffect and self._currentRoundLoadedEnemy[teamPositionId] then
                imageView:setVisible(false)
                imageView:runAction(cc.Sequence:create(
                    cc.DelayTime:create(1.5),
                    cc.CallFunc:create(function()
                        imageView:setScale(1.8)
                        imageView:setVisible(true)
                    end),
                    cc.ScaleTo:create(0.2, 0.75),
                    cc.CallFunc:create(function()
                        local enemyLoadedMC = self._layerLeft._layerRightFormation._icon[teamPositionId]:getChildByTag(NewFormationView.kTagIconEnemyEffect)
                        if enemyLoadedMC then
                            enemyLoadedMC:setVisible(true)
                            enemyLoadedMC:gotoAndPlay(0)
                        end
                end)))
            end
        until true
    end

    if not self._isShowEnemyLoadedEffect then
        self._isShowEnemyLoadedEffect = true
    end
end

function NewFormationView:swapGridIcon(iconGrid1, iconView1, iconGrid2)
    --print("swap icon grid")
    -- swap data
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    local iconType = iconView1:getIconType()
    if iconType == NewFormationView.kGridTypeTeam then
        local positionId1, positionId2 = iconGrid1:getGridIndex(), iconGrid2:getGridIndex()
        local iconSubtype1 = iconView1:getIconSubtype() or 0--
        local iconSubtype2 = 0
        if iconGrid2:getIconView() then
            iconSubtype2 = iconGrid2:getIconView():getIconSubtype() or 0
        end--
        table.walk(data, function(v, k)
            if not string.find(tostring(k), "g") then return end
            if v == positionId1 then 
                data[k] = positionId2
                data[string.format("d%d", tonumber(string.sub(tostring(k), -1)))] = iconSubtype2--
            elseif v == positionId2 then 
                data[k] = positionId1
                data[string.format("d%d", tonumber(string.sub(tostring(k), -1)))] = iconSubtype1--
            end
        end)
    end

    self._layerLeft._teamFormation._data[self._context._formationId] = data

    -- swap ui
    iconGrid1:setIconView(iconGrid2:getIconView())
    iconGrid2:setIconView(iconView1)
    iconGrid2:onLoaded()

    if self:isNewFormationViewEx() then
        self:swapGridIconEx(iconGrid1, iconView1, iconGrid2)
    end
end

function NewFormationView:swapGridIconEx(iconGrid1, iconView1, iconGrid2)

end

function NewFormationView:moveGridIcon(iconGrid1, iconView1, iconGrid2)
    --print("move icon grid")
     -- move data
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    local iconType = iconView1:getIconType()
    if iconType == NewFormationView.kGridTypeTeam then
        local positionId1, positionId2 = iconGrid1:getGridIndex(), iconGrid2:getGridIndex()
        local iconSubtype = iconView1:getIconSubtype() or 0--
        table.walk(data, function(v, k)
            if not string.find(tostring(k), "g") then return end
            if v == positionId1 then 
                data[k] = positionId2
                data[string.format("d%d", tonumber(string.sub(tostring(k), -1)))] = iconSubtype--
            end
        end)
    end
    self._layerLeft._teamFormation._data[self._context._formationId] = data

    -- move ui
    iconGrid2:setIconView(iconView1)
    iconGrid2:onLoaded()

    if self:isNewFormationViewEx() then
        self:moveGridIconEx(iconGrid1, iconView1, iconGrid2)
    end
end

function NewFormationView:moveGridIconEx(iconGrid1, iconView1, iconGrid2)

end

function NewFormationView:loadGridIcon(iconGrid, iconView)
    --print("load icon grid")
    if not (iconGrid and iconView) then return end

    -- data
    local iconType = iconView:getIconType()
    local iconId = iconView:getIconId()
    local iconSubtype = iconView:getIconSubtype() or 0
    local realLoaded = true

    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if iconType == NewFormationView.kGridTypeTeam then
        local gridIndex = iconGrid:getGridIndex()
        local isGridFull = iconGrid:isStateFull()
        if isGridFull then
            local iconView1 = iconGrid:getIconView()
            if not iconView1 then return end
            local iconId1 = iconView1:getIconId()
            local iconSubtype1 = iconView1:getIconSubtype() or 0
            for k, v in pairs(data) do
                if string.find(tostring(k), "team") then
                    local index = tonumber(string.sub(tostring(k), -1))
                    local teamId = data["team" .. index]
                    local teamPosition = data["g" .. index]
                    local teamSubtype = data["d" .. index]
                    if teamId == iconId1 and gridIndex == teamPosition and iconSubtype1 == teamSubtype then
                        data["team" .. index] = iconId
                        data["g" .. index] = gridIndex
                        data["d" .. index] = iconSubtype
                        realLoaded = false
                        break
                    end
                end
            end
        else
            for k, v in pairs(data) do
                if string.find(tostring(k), "team") and 0 == v then
                    data[k] = iconId
                    data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))] = gridIndex
                    data[string.format("d%d", tonumber(string.sub(tostring(k), -1)))] = iconSubtype
                    break
                end
            end
        end
    else
        data.heroId = iconId
    end

    -- ui
    if iconType == NewFormationView.kGridTypeTeam then
        local teamTableData = self:getTableData(iconType, iconId)
        if teamTableData.enemy and teamTableData.soundEnemy then
            -- 兵团上阵 死敌音效
            local hasEnemy = false
            for k, v in pairs(data) do
                if string.find(tostring(k), "team") and v == teamTableData.enemy then
                    hasEnemy = true
                    break
                end
            end
            if hasEnemy then
                if self._selectTeamSoundId then
                    audioMgr:stopSound(self._selectTeamSoundId)
                    self._selectTeamSoundId = nil
                end
                self._selectTeamSoundId = audioMgr:playSound(teamTableData.soundEnemy)
            end
        elseif teamTableData.soundtrigger then
            -- 兵团上阵 彩蛋音效
            local hasCompanion = false
            local heroData = self._heroModel:getHeroData(data.heroId)
            if heroData then
                if not teamTableData.zuhe or (heroData.id == teamTableData.zuhe[1] and heroData.star >= teamTableData.zuhe[2]) then
                    hasCompanion = true
                end
            end
            if hasCompanion then
                if self._selectTeamSoundId then
                    audioMgr:stopSound(self._selectTeamSoundId)
                    self._selectTeamSoundId = nil
                end
                self._selectTeamSoundId = audioMgr:playSound(teamTableData.soundtrigger)
            end
        end
    else
        -- 英雄上阵 普通音效
        local heroTableData = self:getTableData(NewFormationView.kGridTypeHero, iconId)
        if heroTableData.soundUpload then
            if self._selectHeroSoundId then
                audioMgr:stopSound(self._selectHeroSoundId)
                self._selectHeroSoundId = nil
            end
            self._selectHeroSoundId = audioMgr:playSound(heroTableData.soundUpload .. "_0" .. GRandom(4))
        end
    end

    self:dealWithEffect(iconGrid, iconView)

    if self:isNewFormationViewEx() then
        self:loadGridIconEx(iconGrid, iconView, realLoaded)
    end
end

function NewFormationView:loadGridIconEx(iconGrid, iconView, realLoaded)
    if realLoaded then
        self._heroDuelContext._pickedCount = self._heroDuelContext._pickedCount + 1
        self._heroDuelInfo._labelTips1:setString(self._heroDuelContext._pickedCount)
        self._heroDuelInfo._labelTips1:setColor(self._heroDuelContext._pickedCount >= self._heroDuelContext._pickNum and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0))
    end
end

function NewFormationView:unloadGridIcon(iconGrid, iconView)
    --print("unload icon grid")
    if not (iconGrid and iconView) then return end

    local iconType = iconView:getIconType()
    local iconId = iconView:getIconId()
    local gridIndex = iconGrid:getGridIndex()
    local iconSubtype = iconView:getIconSubtype() or 0

    -- data
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if iconType == NewFormationView.kGridTypeTeam then
        for k, v in pairs(data) do
            repeat
                if not string.find(tostring(k), "g") then break end
                local index = tonumber(string.sub(tostring(k), -1))
                local teamId = data["team" .. index]
                local teamPosition = data["g" .. index]
                local teamSubtype = data["d" .. index]
                if teamId == iconId and gridIndex == teamPosition and iconSubtype == teamSubtype then
                    data["team" .. index] = 0
                    data["g" .. index] = 0
                    data["d" .. index] = 0
                    break
                end
            until true
        end
    end
    -- ui
    audioMgr:playSound("Download")
    iconView:removeFromParentAndCleanup()

    self._layerLeft._unloadMC:setPosition(self._layerLeft._ePosition)
    self._layerLeft._unloadMC:setVisible(true)
    self._layerLeft._unloadMC:gotoAndPlay(0)

    if self:isNewFormationViewEx() then
        self:unloadGridIconEx(iconGrid, iconView)
    end
    
    return true
end

function NewFormationView:unloadGridIconEx(iconGrid, iconView)
    self._heroDuelContext._pickedCount = self._heroDuelContext._pickedCount - 1
    self._heroDuelInfo._labelTips1:setString(self._heroDuelContext._pickedCount)
    self._heroDuelInfo._labelTips1:setColor(self._heroDuelContext._pickedCount >= self._heroDuelContext._pickNum and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0))
end

function NewFormationView:countDownOver()
    if self._heroDuelContext._state == NewFormationView.kHeroDuelStateNotReady then
        self._heroDuelContext._state = NewFormationView.kHeroDuelStateReady
        self:updateFormationState()
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeam then
        self:releaseLayerLeftTouch()
        if self._heroDuelContext._pickedCount < self._heroDuelContext._pickNum then
            self:autoPickTeam(self._heroDuelContext._pickNum - self._heroDuelContext._pickedCount)
        end
        self:saveHeroDuelFormation()
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateWaitTeam then
        --self:requireHeroDuelFormation()
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickHero then
        self:releaseLayerLeftTouch()
        if self._heroDuelContext._pickedCount < self._heroDuelContext._pickNum then
            self:autoPickHero(self._heroDuelContext._pickNum - self._heroDuelContext._pickedCount)
        end
        self:saveHeroDuelFormation()
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeamAI then
        local data = self._heroDuelContext._heroDuelAIData
        if not self:checkOptionData(data) then return end
        self._heroDuelContext._step = data.self.formOp.step
        self._heroDuelContext._state = data.self.formOp.turn
        self._heroDuelContext._pickNum = data.self.formOp.num
        self._heroDuelContext._remainTime = data.self.formOp.time
        self._heroDuelContext._remainPrintTime = data.self.formOp.ptime
        self._heroDuelContext._timeTick = self._heroDuelContext._remainTime / self._heroDuelContext._remainPrintTime
        self._heroDuelContext._remainAITime = -1
        self._heroDuelContext._heroDuelAIData = {}
        self._layerLeft._teamFormation._data[self._context._formationId] = self:checkFormationData(data.self.form)
        self:updateLeftTeamFormation()
        self:updateLeftHeroFormation()
        self:lockPickedFormation()
        self._enemyFormationData[self._context._formationId] = data.self.formC
        self:updateRightTeamFormationPreview()
        self:updateFormationState(data)
    elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStateWaitHero then
        self:requireHeroDuelFormation()
    end
end

function NewFormationView:isTeamLoadedFull(formationId, realLoaded)
    if realLoaded then
        return self:getCurrentLoadedTeamCount() >= self._layerLeft._teamFormation._allowLoadCount.currentTeamCount
    end
    return self._heroDuelContext._pickedCount >= self._heroDuelContext._pickNum
end

function NewFormationView:lockPickedFormation()
    for i = 1, NewFormationView.kTeamGridCount do
        local iconGrid = self._layerLeft._teamFormation._grid[i]
        if iconGrid:isStateFull() then
            local iconView = iconGrid:getIconView()
            if iconView then
                iconView:showLocked(true)
            end
        end
    end

    local iconGrid = self._layerLeft._heroFormation._grid
    if iconGrid:isStateFull() then
        local iconView = iconGrid:getIconView()
        if iconView then
            iconView:showLocked(true)
        end
    end
end

function NewFormationView:saveHeroDuelFormation()
    print("NewFormationView:saveHeroDuelFormation")
    self:lockPickedFormation()
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    local data = {}
    for i=1, NewFormationView.kTeamMaxCount do
        if formationData["team" .. i] and 0 ~= formationData["team" .. i] then
            data["team" .. i] = formationData["team" .. i]
            data["g" .. i] = formationData["g" .. i]
            data["d" .. i] = formationData["d" .. i]
        end
    end
    if 0 ~= formationData["heroId"] then
        data["heroId"] = formationData["heroId"]
    end
    --local context = {args = json.encode({form = data, step = self._heroDuelContext._step})}
    local context = {args = json.encode({form = data})}
    print("context json", context["args"])
    --print("hDuelSetFormation时间戳" .. self._modelMgr:getModel("UserModel"):getCurServerTime())
    local methodName = "teamSelect"
    if self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickHero then
        methodName = "heroSelect"
    end
    self._serverMgr:RS_sendMsg("PlayerProcessor", methodName, context)
    -- self._heroDuelContext._pickedCount = 0
end

function NewFormationView:_saveHeroDuelFormation()
    print("NewFormationView:saveHeroDuelFormation")
    self:lockPickedFormation()
    local formationData = self._layerLeft._teamFormation._data[self._context._formationId]
    local data = {}
    for i=1, NewFormationView.kTeamMaxCount do
        if formationData["team" .. i] and 0 ~= formationData["team" .. i] then
            data["team" .. i] = formationData["team" .. i]
            data["g" .. i] = formationData["g" .. i]
            data["d" .. i] = formationData["d" .. i]
        end
    end
    if 0 ~= formationData["heroId"] then
        data["heroId"] = formationData["heroId"]
    end
    --[[
    for k, v in pairs(formationData) do
        repeat
            if not string.find(tostring(k), "team") or 0 == v then break end
            local index = tonumber(string.sub(tostring(k), -1))
            data["team" .. index] = formationData["team" .. index]
            data["g" .. index] = formationData["g" .. index]
            data["d" .. index] = formationData["d" .. index]
        until true
    end
    if 0 ~= formationData["heroId"] then
        data["heroId"] = formationData["heroId"]
    end
    ]]
    --local context = {args = json.encode({form = data, step = self._heroDuelContext._step})}
    local context = {args = json.encode({form = data})}
    print("context json", context["args"])
    --print("hDuelSetFormation时间戳" .. self._modelMgr:getModel("UserModel"):getCurServerTime())
    local methodName = "teamSelect"
    if self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickHero then
        methodName = "heroSelect"
    end
    --[[
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelSetFormation", context, true, {}, function(success, data)
        if not success then
            self:handleErrorData(data)
            return
        end
        self:handleOptionData(data)
    end)
    ]]
    self._serverMgr:RS_sendMsg("PlayerProcessor", methodName, context)
    self._heroDuelContext._pickedCount = 0
end

function NewFormationView:requireHeroDuelFormation()
    --[[
    print("NewFormationView:requireHeroDuelFormation")
    --print("hDuelFormReq时间戳" .. self._modelMgr:getModel("UserModel"):getCurServerTime())
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelFormReq", {args = json.encode({step = self._heroDuelContext._step})}, true, {}, function(success, data)
        if not success then
            self:handleErrorData(data)
            return
        end
        self:handleOptionData(data)
    end)
    ]]
end

function NewFormationView:releaseLayerLeftTouch()
    self:onLayerLeftTouchCancelled(nil, self._layerLeft._mPosition.x, self._layerLeft._mPosition.y)
    if self._layerLeft._layerList._itemsTableView then
        self._layerLeft._layerList._itemsTableView:setContentOffset(self._layerLeft._layerList._itemsTableView:maxContainerOffset(), false)
    end
end

function NewFormationView:autoPickTeam(count)
    print("NewFormationView:autoPickTeam", count)
    for i=1, count do
        local found = false
        local iconGrid = nil
        local iconView = nil
        for _, v in ipairs(self._layerLeft._layerList._teamData) do
            repeat
                local teamId = v.id
                if self:isFiltered(teamId) then break end
                local iconSubtype = v.teamSubtype
                local teamTableData = tab:Team(teamId)
                if not teamTableData then break end
                local position = clone(tab:ClassPosition(teamTableData.class).position)
                for i = 1, #position do
                    j = self._random:ran(i)
                    temp = position[i]
                    position[i] = position[j]
                    position[j] = temp   
                end
                for _, p in ipairs(position) do
                    repeat
                        iconGrid = self._layerLeft._teamFormation._grid[p]
                        if not iconGrid then break end
                        if not iconGrid:isStateFull() then
                            iconView = NewFormationIconView.new({iconType = NewFormationView.kGridTypeTeam, iconId = teamId, iconSubtype = iconSubtype, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, isCustom = true, container = self})
                            found = true
                        end
                    until true
                    if found then break end
                end
            until true
            if found then break end
        end
        if found and iconGrid and iconView then
            self:loadGridIcon(iconGrid, iconView)
            self:updateLeftTeamFormationAddition(false)
            self:updateLeftHeroAddition(true)

            for i = 1, NewFormationView.kTeamGridCount do
                self._layerLeft._teamFormation._grid[i]:setState(1)
                self._layerLeft._teamFormation._grid[i]:updateState()
            end

            self._layerLeft._heroFormation._grid:setState(1)
            self._layerLeft._heroFormation._grid:updateState()

            self:updateRelative()
            self:refreshItemsTableView()
        end
    end
end

function NewFormationView:autoPickHero(count)
    print("NewFormationView:autoPickHero", count)
    for i=1, count do
        local found = false
        local iconGrid = nil
        local iconView = nil
        for _, v in ipairs(self._layerLeft._layerList._heroData) do
            repeat
                local heroId = v.id
                if not heroId or self:isFiltered(heroId) then break end
                iconGrid = self._layerLeft._heroFormation._grid
                iconView = NewFormationIconView.new({iconType = NewFormationView.kGridTypeHero, iconId = heroId, iconState = NewFormationIconView.kIconStateBody, formationType = self._formationType, isCustom = true, container = self})
                found = true
            until true
            if found then break end
        end
        if found and iconGrid and iconView then
            self:loadGridIcon(iconGrid, iconView)
            self:updateLeftTeamFormationAddition(true)
            self:updateLeftHeroAddition(false)

            for i = 1, NewFormationView.kTeamGridCount do
                self._layerLeft._teamFormation._grid[i]:setState(1)
                self._layerLeft._teamFormation._grid[i]:updateState()
            end

            self._layerLeft._heroFormation._grid:setState(1)
            self._layerLeft._heroFormation._grid:updateState()
            self:updateRelative()
            self:refreshItemsTableView()
        end
    end
end

function NewFormationView:countDownTick(dt)
    local beginDeltaTime = self._userModel:getCurServerTime() - self._heroDuelContext._timeStamp
    local tickTime = self._heroDuelContext._timeTick
    local remainPrintTime = self._heroDuelContext._remainPrintTime - math.round(beginDeltaTime / tickTime)
    local remainTime = 100

    if self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeamAI then
        remainTime = self._heroDuelContext._remainAITime - beginDeltaTime
    else
        remainTime = self._heroDuelContext._remainTime - beginDeltaTime
    end

    if remainTime <= -3.0 then
        self._heroDuelInfo._labelCountDown:setString(0)
        self:endCountDownTimer()
    elseif remainTime <= 0 then
        self._heroDuelInfo._labelCountDown:setString(0)
        self:endCountDownTimer()
        self:countDownOver()
    end

    if self._heroDuelContext._state == NewFormationView.kHeroDuelStateNotReady then
        self._heroDuelInfo._labelCountDown:setString(0)
    else
        remainPrintTime = math.max(0, remainPrintTime)
        self._heroDuelInfo._labelCountDown:setScale(remainPrintTime <= 5 and 1.5 or 1.0)
        self._heroDuelInfo._labelCountDown:setColor(remainPrintTime <= 5 and cc.c3b(255, 0, 0) or cc.c3b(255, 255, 255))
        self._heroDuelInfo._labelCountDown:setString(remainPrintTime)
    end
end

function NewFormationView:startCountDownClock()
    if self._countDownTimerId then self:endCountDownTimer() end
    self._heroDuelContext._timeStamp = self._userModel:getCurServerTime()
    self._countDownTimerId = self._scheduler:scheduleScriptFunc(function(dt)
        self:countDownTick(dt)
    end, 0, false)
end

function NewFormationView:endCountDownTimer()
    if self._countDownTimerId then 
        self._scheduler:unscheduleScriptEntry(self._countDownTimerId)
        self._countDownTimerId = nil
    end
end

function NewFormationView:switchLayerList(iconType, force)
    if self._context._gridType[self._context._formationId] == iconType and not force then return end

    if NewFormationView.kGridTypeTeam == iconType then
        if self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickHero or self._heroDuelContext._state == NewFormationView.kHeroDuelStateWaitHero then
            self._viewMgr:showTip(lang("HERODUEL10"))
            return
        end
    elseif NewFormationView.kGridTypeHero == iconType then
        if self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeam or
            self._heroDuelContext._state == NewFormationView.kHeroDuelStateWaitTeam or
            self._heroDuelContext._state == NewFormationView.kHeroDuelStateInit or
            self._heroDuelContext._state == NewFormationView.kHeroDuelStateReady then
            self._viewMgr:showTip(lang("HERODUEL6"))
            return
        end
    end

    self._context._gridType[self._context._formationId] = iconType

    self._layerLeft._layerList._btnTabTeam:setEnabled(NewFormationView.kGridTypeTeam ~= iconType)
    self._layerLeft._layerList._btnTabTeam:setBright(NewFormationView.kGridTypeTeam ~= iconType)

    self._layerLeft._layerList._btnTabHero:setEnabled(NewFormationView.kGridTypeHero ~= iconType)
    self._layerLeft._layerList._btnTabHero:setBright(NewFormationView.kGridTypeHero ~= iconType)

    self._layerLeft._layerList._btnFilter:setEnabled(NewFormationView.kGridTypeTeam == iconType)
    self._layerLeft._layerList._btnFilter:setSaturation(NewFormationView.kGridTypeTeam == iconType and 0 or -100)

    if NewFormationView.kGridTypeTeam == iconType then
        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(252, 244, 197, 255))
        -- self._layerLeft._layerList._btnTabTeam:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(147, 107, 81, 255))
        -- self._layerLeft._layerList._btnTabHero:getTitleRenderer():disableEffect()
    else
        self._layerLeft._layerList._btnTabHero:setTitleColor(cc.c4b(252, 244, 197, 255))
        -- self._layerLeft._layerList._btnTabHero:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        self._layerLeft._layerList._btnTabTeam:setTitleColor(cc.c4b(147, 107, 81, 255))
        -- self._layerLeft._layerList._btnTabTeam:getTitleRenderer():disableEffect()
    end

    self:updateLeftTeamFormationAddition(NewFormationView.kGridTypeHero == iconType)
    self:updateLeftHeroAddition(NewFormationView.kGridTypeTeam == iconType)

    self:refreshItemsTableView(true)
end

function NewFormationView:getCurrentAllowLoadCount()
    local currentTeamCount = NewFormationView.kTeamMaxCount
    local nextTeamCountUnlockLevel = 0
    local nextTeamCount = 0
    return { currentTeamCount = currentTeamCount, nextTeamCount = nextTeamCount, maxTeamCount = NewFormationView.kTeamMaxCount, nextTeamCountUnlockLevel = nextTeamCountUnlockLevel, currentInstrumentCount = 0, nextInstrumentCount = 0, maxInstrumentCount = self.kInsMaxCount, nextInstrumentCountUnlockLevel = 0, }
end

function NewFormationView:getCurrentAllowLoadTeamCount()
    return 8
end

function NewFormationView:isShowButtonBattle()
    return false
end

function NewFormationView:isShowButtonReturn()
    return false
end

function NewFormationView:isFiltered(iconId)
    if 0 == iconId then return false end

    local found = false
    if self._filter then
        for k, v in pairs(self._filter) do
            if v.id == iconId then
                found = true
                break
            end
        end
    end

    return found
end

function NewFormationView:isLoaded(iconType, iconId, teamSubtype)
    local found = false
    local data = self._layerLeft._teamFormation._data[self._context._formationId]
    if not data then
        ApiUtils.playcrab_lua_error("invalid formation data:" .. tostring(self._context._formationId), serialize(self._modelMgr:getModel("FormationModel"):getFormationData()), "formation")
        self._viewMgr:onLuaError("invalid formation data:" .. tostring(self._context._formationId) .. serialize(self._modelMgr:getModel("FormationModel"):getFormationData()))
    end
    if iconType == NewFormationView.kGridTypeTeam then
        for k, v in pairs(data) do
            if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and v == iconId then
                local subtype = tonumber(data[string.format("d%d", tonumber(string.sub(tostring(k), -1)))])
                if teamSubtype and teamSubtype == subtype then
                    found = true
                    break
                end
            end 
        end
    elseif iconType == NewFormationView.kGridTypeHero then
        if data["heroId"] and data["heroId"] == iconId then
            found = true
        end
    end

    return found
end

function NewFormationView:initCustomTeamData()
    if not (self._extend and self._extend.teams) then return end
    local t = {}
    for _, team in ipairs(self._extend.teams) do
        repeat
            local data = clone(tab:Team(team.id))
            if not data then break end
            data.teamId = data.id
            data.teamSubtype = team.d
            data.id = nil
            table.insert(t, data)
        until true
    end
    self._extend.teams = t
end

function NewFormationView:initCustomHeroData()
    if not (self._extend and self._extend.heroes) then return end
    local t = {}
    for _, id in ipairs(self._extend.heroes) do
        repeat
            local data = clone(tab:Hero(id))
            if not data then break end
            data.heroId = data.id
            data.id = nil
            table.insert(t, data)
        until true
    end
    self._extend.heroes = t
end

function NewFormationView:initTeamListData()
    self._layerLeft._layerList._teamData = {}
    local data = {}
    if self._extend and self._extend.teams then
        if not self._extend.teamsInit then
            self:initCustomTeamData()
            self._extend.teamsInit = true
        end
        data = clone(self._extend.teams)
    end

    if not self._layerLeft._layerList._allTeamsInit then
        self._layerLeft._layerList._allTeamsData = clone(data)
        self._layerLeft._layerList._allTeamsInit = true
    end

    local t1, t2 = {}, {}
    for _, v in ipairs(data) do
        repeat
            if self:isTeamTypeFiltered(v) then break end
            if self:isLoaded(NewFormationView.kGridTypeTeam, v.teamId, v.teamSubtype) then break end
            if not self:isFiltered(v.teamId) then
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

function NewFormationView:initHeroListData()
    self._layerLeft._layerList._heroData = {}
    local data = {}
    if self._extend and self._extend.heroes then
        if not self._extend.heroesInit then
            self:initCustomHeroData()
            self._extend.heroesInit = true
        end
        data = clone(self._extend.heroes)
    end
    local t1, t2 = {}, {}
    for _, v in ipairs(data) do
        repeat
            if self:isLoaded(NewFormationView.kGridTypeHero, tonumber(v.heroId)) then break end
            if not self:isFiltered(tonumber(v.heroId)) then
                v.id = tonumber(v.heroId)
                table.insert(t1, v)
            else
                v.id = tonumber(v.heroId)
                table.insert(t2, v)
            end
        until true
    end

    table.sort(t1, function(a, b)
        return a.obseq > b.obseq
    end)

    table.sort(t2, function(a, b)
        return a.obseq > b.obseq
    end)

    for i = 1, #t1 do
        self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t1[i]
    end

    for i = 1, #t2 do
        self._layerLeft._layerList._heroData[#self._layerLeft._layerList._heroData + 1] = t2[i]
    end
end

function NewFormationView:getTableData(iconType, iconId)
    local tableData = nil
    if iconType == NewFormationView.kGridTypeTeam then
        tableData = tab:Team(iconId)
    else
        tableData = tab:Hero(iconId)
    end
    return tableData
end

function NewFormationView:isTeamCustom(teamId)
    return true
end

function NewFormationView:isHeroCustom(heroId)
    return true
end

function NewFormationView:itemsTableViewCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    local data = self:getCurrentIconData()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local item = NewFormationIconView.new({iconType = self._context._gridType[self._context._formationId], iconId = data[idx + 1].id, iconSubtype = data[idx + 1].teamSubtype, iconState = NewFormationIconView.kIconStateImage, formationType = self._formationType, isCustom = true, container = self})
        item:setPosition(self._context._gridType[self._context._formationId] == NewFormationView.kGridTypeHero and cc.p(50, 60) or cc.p(50, 50))
        item:setTag(NewFormationView.kItemTag)
        item:showFilter(self:isFiltered(data[idx + 1].id))
        item:showRecommand(self:isRecommend(data[idx + 1].id))
        self:showItemFlag(item)
        item:updateState(NewFormationIconView.kIconStateImage, true)
        item:setName("item_"..idx)
        cell:setName("cell_"..idx)
        cell:addChild(item)
    else
        local item = cell:getChildByTag(NewFormationView.kItemTag)
        item:setIconId(data[idx + 1].id)
        item:setIconSubtype(data[idx + 1].teamSubtype)
        item:showFilter(self:isFiltered(data[idx + 1].id))
        item:showRecommand(self:isRecommend(data[idx + 1].id))
        self:showItemFlag(item)
        item:setCustom(true)
        item:updateState(NewFormationIconView.kIconStateImage, true)
    end
    return cell
end

function NewFormationView:onBattleButtonClicked()
    if self._heroDuelContext._state ~= NewFormationView.kHeroDuelStateFinish then
        if self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickTeam then
            if self._heroDuelContext._pickedCount < self._heroDuelContext._pickNum then
                self._viewMgr:showTip(lang("HERODUEL8"))
                return
            end
        elseif self._heroDuelContext._state == NewFormationView.kHeroDuelStatePickHero then
            if self._heroDuelContext._pickedCount < self._heroDuelContext._pickNum then
                self._viewMgr:showTip(lang("HERODUEL11"))
                return
            end
        end
        self._btnBattle:setSaturation(-100)
        self._btnBattle:setEnabled(false)
        self:endCountDownTimer()
        self:saveHeroDuelFormation()
    else
        self:endCountDownTimer()
        if self._battleCallBack and type(self._battleCallBack) == "function" then
            self._battleCallBack()
        end
    end
end

function NewFormationView:doBattle()

end

function NewFormationView:onCloseButtonClicked()

end

function NewFormationView:doClose()

end

function NewFormationView:closeHeroDuelFormation(reason, data)
    print("closeHeroDuelFormation:", reason)
    self:endCountDownTimer()
    if self._musicFileName then
        audioMgr:playMusic(self._musicFileName, true)
    end
    if self._closeCallBack and type(self._closeCallBack) == "function" then
        self._closeCallBack(reason, data)
    end
    self:close()
end
