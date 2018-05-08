--[[
    Filename:    BattleRule_PVE1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-07-01 18:10:49
    Description: File description
--]]

-- 通用PVE1
-- 用于副本, 支线副本, 联盟探索PVE
local BC = BC
local pc = pc
local cc = _G.cc
local os = _G.os
local math = math
local pairs = pairs
local next = next
local tab = tab
local tonumber = tonumber
local tostring = tostring
local table = table
local floor = math.floor
local ceil = math.ceil
local mcMgr = mcMgr


local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType

local logic, objLayer
local delayCall = BC.DelayCall.dc

local rule = {}
function rule.init()

local Y_OFFSET = 30

local BattleScene = require("game.view.battle.display.BattleScene")
local COUNT_TIME = 180
local INTO_SPEED = 140
local INTO_DIS = 800
function BattleScene:initBattleUIEx()
    self.CountTime = COUNT_TIME

    self._proBar1 = self._BattleView:getUI("uiLayer.topLayer.pro1")
    self._proBar2 = self._BattleView:getUI("uiLayer.topLayer.pro2")
    if BC.reverse then
        self._proBar1:loadTexture("hpBar2_battle.png", 1)
        self._proBar2:loadTexture("hpBar1_battle.png", 1)
    else
        self._proBar1:loadTexture("hpBar1_battle.png", 1)
        self._proBar2:loadTexture("hpBar2_battle.png", 1)
    end

    if self._battleInfo.isReport then
        self._autoBtn:loadTextureNormal("autoBtn_battleSelected.png", 1)
        self._autoBtn.lock:setVisible(true)
        self._autoBtn:setTouchEnabled(false)
    end

    self._hpShadow1 = ccui.LoadingBar:create("hpBar1_0_battle.png", 1, 100)
    self._hpShadow1:setAnchorPoint(1, 0)
    self._hpShadow1:setScaleX(-1)
    self._hpShadow1:setOpacity(255)
    self._hpShadow1:setColor(BC.reverse and cc.c3b(255, 193, 193) or cc.c3b(206, 232, 255))
    self._proBar1:addChild(self._hpShadow1, -1)
    self._hpShadow2 = ccui.LoadingBar:create("hpBar1_0_battle.png", 1, 100)
    self._hpShadow2:setAnchorPoint(0, 0)
    self._hpShadow2:setOpacity(255)
    self._hpShadow2:setColor(BC.reverse and cc.c3b(206, 232, 255) or cc.c3b(255, 193, 193))
    self._proBar2:addChild(self._hpShadow2, -1)

    self._shadowValue1 = 100
    self._shadowValue2 = 100
    self._destValue1 = 100
    self._destValue2 = 100
    self._hpUpdateTick = 0

    -- 跨服竞技场镜像挑战不可跳过战斗
    if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_ServerArenaFuben then
        self._skipBtn:setVisible(false)
        self._pauseBtn.lock:setVisible(true)
        self._pauseBtn:setTouchEnabled(false)
        self._surrenderBtn:setVisible(true)
	elseif self._battleInfo.mode == BattleUtils.BATTLE_TYPE_GuildPVE then
		self._skipBtn:setVisible(true)
    end 
end

-- 显示HP
function BattleScene:countHPEx()
    local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
    local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
    self._destValue1 = ((hp1 + shp1) / (maxhp1 + maxshp1)) * 100
    self._destValue2 = ((hp2 + shp2) / (maxhp2 + maxshp2)) * 100
    if BC.reverse then
        self._proBar1:setPercent(self._destValue2)
        self._proBar2:setPercent(self._destValue1)
    else
        self._proBar1:setPercent(self._destValue1)
        self._proBar2:setPercent(self._destValue2)
    end
end

-- update
local abs = math.abs
function BattleScene:updateEx(dt)
    if not BATTLE_PROC then
        local tick = BC.BATTLE_TICK
        if tick > self._hpUpdateTick + 1.0 then
            self._hpUpdateTick = tick
            self._hpAnim1 = false
            self._hpAnim2 = false
        elseif tick > self._hpUpdateTick + 0.8 then
            self._shadowValue1 = self._shadowValue1 + (self._destValue1 - self._shadowValue1) * 0.5
            self._shadowValue2 = self._shadowValue2 + (self._destValue2 - self._shadowValue2) * 0.5
            if abs(self._shadowValue1 - self._destValue1) < 1 then
                self._shadowValue1 = self._destValue1
            end
            if abs(self._shadowValue2 - self._destValue2) < 1 then
                self._shadowValue2 = self._destValue2
            end
            if BC.reverse then
                self._hpShadow1:setPercent(self._shadowValue2)
                self._hpShadow2:setPercent(self._shadowValue1)
            else
                self._hpShadow1:setPercent(self._shadowValue1)
                self._hpShadow2:setPercent(self._shadowValue2)
            end
        else
            if not self._hpAnim1 and abs(self._destValue1 - self._shadowValue1) > 5 then
                self._hpAnim1 = true
                self._hpShadow1:setOpacity(255)
                self._hpShadow1:stopAllActions()
                --self._hpShadow1:runAction(cc.FadeTo:create(0.1, 185))
            end
            if not self._hpAnim2 and abs(self._destValue2 - self._shadowValue2) > 5 then
                self._hpAnim2 = true
                self._hpShadow2:setOpacity(255)
                self._hpShadow2:stopAllActions()
                --self._hpShadow2:runAction(cc.FadeTo:create(0.1, 185))
            end
        end
    end

    if self.__jump then
        self.__jump = false
        local frame = BC.frameInv
        while logic.battleTime < 5 and self._isWin == nil do
            BC.BATTLE_TICK = BC.BATTLE_TICK + frame
            BC.BATTLE_DISPLAY_TICK = BC.BATTLE_DISPLAY_TICK + frame
            logic:update(true)
        end
        BC.noEff = false
        BC.BATTLE_TICK = BC.BATTLE_TICK + frame
        BC.BATTLE_DISPLAY_TICK = BC.BATTLE_DISPLAY_TICK + frame
        logic:update()
        delayCall(0, self, function()
            self.enableOutEnemy = true
            self._touchMask:removeFromParent()
            self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
                self._frontLayer:getView():setVisible(false)   
            end)))
        end)
    end
end

function BattleScene:setOverTime(time)
    self._timeLabel:setString(formatTime(ceil(COUNT_TIME - time)))
end

function BattleScene:playEx()
    self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL, BC.MAX_SCENE_HEIGHT_PIXEL, false)
    self:screenToSize(BC.SCENE_SCALE_INIT)

    -- 禁止操作挡板
    self._touchMask = ccui.Layout:create()
    self._touchMask:setBackGroundColorOpacity(0)
    self._touchMask:setBackGroundColorType(1)
    self._touchMask:setBackGroundColor(cc.c3b(0,0,0))
    self._touchMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._touchMask:setTouchEnabled(true)
    self._touchMask:addClickEventListener(function (sender)
        if self._battleInfo.showNpc == nil or logic:hasAssist2() then
            self:jumpBattleBeginAnim()
        end
    end)
    self._rootLayer:getParent():addChild(self._touchMask)
end

function BattleScene:updateTouchEx()
    return true
end

function BattleScene:onMouseScrollEx()
    return true
end

function BattleScene:onTouchesBeganEx()
    return true
end

function BattleScene:onTouchesMovedEx()
    return true
end

function BattleScene:onTouchesEndedEx()
    return true
end

-- 战斗开始动画
function BattleScene:battleBeginAnimEx()
    if logic:hasAssist2() then
        self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5, false)
        self:battleBegin()
        self.__jump = true
    else
        -- 黑屏渐变
        self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
            self._frontLayer:getView():setVisible(false)
        end)))
        self._camera = cc.Node:create()
        self._rootLayer:addChild(self._camera)
        local sy = BC.MAX_SCENE_HEIGHT_PIXEL - 200
        local dx1, dy1 = logic:getRightTeamCenterPoint(BC.reverse)
        local dx2, dy2 = logic:getLeftTeamCenterPoint(BC.reverse)
        dy1 = dy1 + Y_OFFSET
        dy2 = dy2 + Y_OFFSET
        self._camera:setPosition(dx1, sy)
        self._animId = ScheduleMgr:regSchedule(1, self, function(self)
            if self._follow then
                local x, y
                if logic.battleBeginTick and logic.battleTime > 3 then
                    x, y = logic:getAllTeamCenterPoint(BC.reverse)
                    self:screenToPos(x, nil, 0.05)
                else
                    x, y = logic:getLeftTeamCenterPoint(BC.reverse)
                    y = y + Y_OFFSET
                    self:screenToPos(x, nil, 0.1)
                end 
            elseif self._camera then
                self:screenToPos(self._camera:getPositionX(), self._camera:getPositionY(), false)
            end
        end)

        if self._battleInfo.showNpc == nil then
            self._camera:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), 
                cc.EaseIn:create(cc.MoveTo:create(1.4, cc.p(dx1, dy1)), 2),
                cc.DelayTime:create(0.1),
                cc.EaseIn:create(cc.MoveTo:create(0.8, cc.p(dx2 + 100, dy2)), 3),
                cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(dx2, dy2)), 5),
                cc.DelayTime:create(0.2),
                cc.CallFunc:create(function ()
                    self._follow = true
                    self:commonRealBattleBegin()
                end)
                ))
        else
            self._camera:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), 
                cc.EaseIn:create(cc.MoveTo:create(1.4, cc.p(dx1, dy1)), 2),
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function ()
                    -- 测试介绍NPC
                    -- local function aaa() 
                    --     require "game.view.battle.display.BattleSceneIntroduceNPC"
                    --     self:introduceNPC(self._battleInfo.showNpc, aaa)
                    --     package.loaded["game.view.battle.display.BattleSceneIntroduceNPC"] = nil
                    -- end
                    -- aaa()
                    -- 测试介绍Hero
                    -- local function bbb() 
                    --     require "game.view.battle.display.BattleSceneIntroduceHero"
                    --     self:introduceNPC(self._battleInfo.showNpc, bbb)
                    --     package.loaded["game.view.battle.display.BattleSceneIntroduceHero"] = nil
                    -- end
                    -- bbb()
                    self:introduceNPC(self._battleInfo.showNpc, function ()
                        self._camera:runAction(cc.Sequence:create(
                            cc.EaseIn:create(cc.MoveTo:create(0.8, cc.p(dx2 + 100, dy2)), 3),
                            cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(dx2, dy2)), 5),
                            cc.DelayTime:create(0.2),
                            cc.CallFunc:create(function ()
                                self._follow = true
                                self:commonRealBattleBegin()
                            end)
                            )) 
                    end)
                end)
                ))       
        end
    end
end

-- 战斗开始动画
function BattleScene:battleBeginMCEx()
    audioMgr:playSoundForce("horn")

    local mc = mcMgr:createViewMC("chuihaodonghua_quanjunchuji", false, true)
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 14)
    self._rootLayer:getParent():addChild(mc)
end

--  跳过开场动画
function BattleScene:jumpBattleBeginAnimEx()
    if self._camera then
        self._frontLayer:getView():stopAllActions()
        self._frontLayer:getView():setOpacity(0)
        local dx2, dy2 = logic:getLeftTeamCenterPoint(BC.reverse)
        dy2 = dy2 + Y_OFFSET
        self:screenToPos(dx2, dy2, false)
        self._camera:setPosition(dx2, dy2)

        self:commonRealBattleBegin()                 
    end
end

-- 中断开场动画
function BattleScene:battleBeginAnimCancelEx()
    if self._camera then
        self._camera:stopAllActions()
        self._camera:removeFromParent()
        self._camera = nil
    end
    ScheduleMgr:unregSchedule(self._animId)
end

function BattleScene:onBattleEndEx(res)
    ScheduleMgr:unregSchedule(self._animId)
end

local BattleLogic = require("game.view.battle.logic.BattleLogic")
local BattleTeam = require("game.view.battle.object.BattleTeam")

local ETeamStateDIE = BC.ETeamState.DIE
local ETeamStateIDLE = BC.ETeamState.IDLE
local ETeamStateMOVE = BC.ETeamState.MOVE
local ETeamStateNONE = BC.ETeamState.NONE
function BattleLogic:initLogicEx()
    logic = BC.logic
    objLayer = BC.objLayer

    if self:hasAssist2() then
        BC.noEff = true
    end

    self._control.enableOutEnemy = false

    -- 援助逻辑
    self._assist = nil
    self._intanceD = self._battleInfo.intanceD
    if self._battleInfo.assist then
        if self._intanceD["helpCondition"] then
            self._assist = self._intanceD["helpCondition"][1]
            self._assistValue = self._intanceD["helpCondition"][2]
        end
    end
    self.__teamDieCount = 0
    self.__teamDieCount2 = 0

    -- 支援
    if self:hasAssist2() then
        -- 己方不动, 移出屏幕
        local team, soldier
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            team:setState(ETeamStateNONE)
            team.canDestroy = false
            team.__attackArea = team.attackArea
            team.attackArea = -1

            -- 初始位置往后挪
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                soldier:setPos(soldier.x - INTO_DIS, soldier.y)
                if not team.walk then
                    soldier:setVisible(false)
                end
            end
        end

        self._heros[1]:setPos(19 * 40 - INTO_DIS, 15 * 40)
        -- 初始NPC
        for i = 1, 8 do
            if self._intanceD["hm"..i] == nil then break end
            local npcid = self._intanceD["hm"..i][1] 
            local pos = self._intanceD["hm"..i][2]
            local x, y
            if type(pos) == "table" then
                x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + pos[1], BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + pos[2]
            else
                x, y = BC.getFormationScenePos(pos, 1)
            end 
            local team = BattleTeam.new(ECamp.LEFT)   

            local info = {npcid = npcid, level = 1, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[1], info, x, y)    
            self:_raceCountAdd(1, team.race1, team.race2)
            self.classCount[1][team.classLabel] = self.classCount[1][team.classLabel] + 1
            self:addTeam(team)     
        end   
    end

    -- 逃跑逻辑
    if not BATTLE_PROC and self._intanceD then
        local escape = self._intanceD["escape"]
        if escape then
            if self._battleInfo.isPass then
                -- 如果已经通过当前关卡，则隐藏英雄
                self._heros[2]:setVisible(false)
            else
                self._escape = escape[1]
                self._escapeValue = escape[2]
                self._escapeTalkId = escape[3]
            end
        end
    end
end

-- 是否处于援助类型2
function BattleLogic:hasAssist2()
    if BC.jump then return false end
    return (self._assist and self._intanceD["helpType"] == 2)
end
-- 执行支援逻辑
function BattleLogic:doAssist()
    self._assist = nil
    self._doAssist = true
    if BC.jump then return end
    local helpType = self._intanceD["helpType"] 
    if helpType == 1 then
        -- 大天使来复活
        self:battlePause()
        ViewManager:getInstance():enableTalking(self._intanceD["helpDialogue"] , {}, function ()
            for i = 2, 8 do
                if self._intanceD["hm"..i] == nil then break end
                local npcid = self._intanceD["hm"..i][1] 
                local pos = self._intanceD["hm"..i][2]
                local x, y
                if type(pos) == "table" then
                    x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + pos[1], BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + pos[2]
                else
                    x, y = BC.getFormationScenePos(pos, 1)
                end 
                local team = BattleTeam.new(ECamp.LEFT)   

                local info = {npcid = npcid, level = 1, summon = false}
                BC.initTeamAttr_Npc(team, self._heros[1], info, x, y)    
                self:_raceCountAdd(1, team.race1, team.race2)
                self.classCount[1][team.classLabel] = self.classCount[1][team.classLabel] + 1
                self:addTeam(team)     

                self:addToUpdateList(team)
            end
            local npcid = self._intanceD["hm1"][1] 
            local pos = self._intanceD["hm1"][2]
            local x, y
            if type(pos) == "table" then
                x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + pos[1], BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + pos[2]
            else
                x, y = BC.getFormationScenePos(pos, 1)
            end 
            
            local team = BattleTeam.new(ECamp.LEFT)   

            local info = {npcid = npcid, level = 1, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[1], info, x, y)    
            self:_raceCountAdd(1, team.race1, team.race2)
            self.classCount[1][team.classLabel] = self.classCount[1][team.classLabel] + 1
            self:addTeam(team)     

            self:addToUpdateList(team)
            team.soldier[1]:changeMotion(EMotion.BORN)
            delayCall(1.0, self, function()
                if self._intanceD["helpEffect"] == 1 then
                    -- 复活
                    team.soldier[1]:changeMotion(EMotion.CAST1)
                    delayCall(0.5, self, function()
                        delayCall(0.1, self, function()
                            -- 全体复活
                            local _team
                            for i = 1, #self._teams[1] do
                                _team = self._teams[1][i]
                                objLayer:playEffect_skill1("fuhuo1_fuhuo", _team.x, _team.y, true, true, 1)
                                objLayer:playEffect_skill1("fuhuo2_fuhuo", _team.x, _team.y, false, false, 1)
                                if _team.state == ETeamStateDIE then
                                    local _soldier
                                    for k = 1, #_team.soldier do
                                        _soldier = _team.soldier[k]
                                        if _soldier.die then
                                            _soldier:setRevive(false, 100)
                                        end
                                    end
                                end
                            end
                            delayCall(1.3, self, function()
                                self:battleResume()
                            end)
                        end)
                        
                    end)
                else
                    self:battleResume()
                end
            end)
            
        end)
    elseif helpType == 2 then
        -- 玩家进场
        self:battlePause()
        ViewManager:getInstance():enableTalking(self._intanceD["helpDialogue"] , {}, function ()
            local team
            for i = 1, #self._teams[1] do
                team = self._teams[1][i]
                if team.original then
                    team.canDestroy = true
                    team:setState(ETeamStateMOVE)
                    team.attackArea = team.__attackArea
                end
            end

            self._control:battleBeginAnimCancelEx()
            local follow = 0

            local _x, _y = self:getLeftOriginalTeamCenterPoint(BC.reverse)
            _x = MAX_SCREEN_WIDTH * 0.5 - 100
          
            local updateId = ScheduleMgr:regSchedule(1, self, function(self)
                if follow == 1 then
                    self._control:screenToPos(_x, _y, 0.1)
                elseif follow == 2 then
                    local x, y = logic:getLeftOriginalTeamCenterPoint(BC.reverse)
                    self._control:screenToPos(x, nil, 0.7)
                end
            end)
            follow = 1
            delayCall(0.8, self, function()
                follow = 2
                self:heroEnter()
                self:goInto(function ()
                    local tick = 0
                    follow = 0
                    delayCall(0.2, self, function()
                        self._control:initBattleSkill(function ()
                            follow = 1
                            _x, _y = self:getAllTeamCenterPoint(BC.reverse)
                            _y = nil
                            self._control:battleBeginMC()
                            delayCall(1.1, self, function()
                                self:battleResume()
                                follow = 0
                                ScheduleMgr:unregSchedule(updateId)
                            end)
                        end)
                    end)
                end)             
            end)

        end)
    end
end

-- 逃跑逻辑
function BattleLogic:doEscape()
    if BC.jump then return end
    local pauseSpeed = BC.BATTLE_SPEED
    self._control:setBattleSpeed(0)
    ViewManager:getInstance():enableTalking(self._escapeTalkId, {}, function ()
        self._control:setBattleSpeed(pauseSpeed)
        objLayer:playEffect_skill1("fazhenzhaohuan_fazhenzhaohuan", self._heros[2].x, self._heros[2].y, true, true)
        ScheduleMgr:delayCall(1000, self, function()
            self._heros[2]:setVisible(false)
        end)
    end)
end

function BattleLogic:heroEnter()
    delayCall(0, self, function()
        self._heros[1]:moveTo(19 * 40, 15 * 40, INTO_SPEED)
    end)
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

-- 进场
function BattleLogic:goInto(callback)
    local allCount = 0
    local count = 0
    for i = 1, #self._teams[1] do
        local team = self._teams[1][i]
        if team.original then
            for k = 1, #team.soldier do
                local soldier = team.soldier[k]
                allCount = allCount + 1
                if not team.walk then
                   soldier:setPos(soldier.x + INTO_DIS, soldier.y)
                   soldier:changeMotion(EMotion.BORN)
                   soldier:setVisible(true)
                   count = count + 1
                else
                    soldier:moveTo(soldier.x + INTO_DIS, soldier.y, INTO_SPEED, function ()
                        count = count + 1
                        if count == allCount then
                            callback()
                        end
                    end, true)
                end
            end
        end
    end
    self.battleState = EState.INTO
end

function BattleLogic:BattleBeginEx()

end

function BattleLogic:updateEx()
    if self._assist == 2 and self.battleBeginTick and self._assistValue <= self.battleTime then
        self:doAssist()
    end
    if self._escape == 2 and self.battleBeginTick and self._escapeValue <= self.battleTime then
        self._escape = nil
        -- 触发逃跑
        self:doEscape()
    end
end

function BattleLogic:teamAttackOverEx(team)

end

function BattleLogic:onTeamDieEx(team)
    if team.camp == 1 then
        self.__teamDieCount = self.__teamDieCount + 1
        if self._assist == 1 and self._assistValue == self.__teamDieCount then
            -- 触发支援
            self:doAssist()
        end
    end
    if team.camp == 2 then
        if self._escape == 1 then
            if team.original then
                self.__teamDieCount2 = self.__teamDieCount2 + 1
                if self._escapeValue == self.__teamDieCount2 then
                    self._escape = nil
                    -- 触发逃跑
                    self:doEscape()
                end
            end
        end
    end
end

function BattleLogic:onSoldierDieEx(soldier)

end

function BattleLogic:onHPChangeEx(soldier, change)

end

-- 胜利条件
function BattleLogic:checkWinEx()
    if self._surrender then
        self:surrender(2)
        return true
    end
    -- 三分钟没结果,算左边输
    if self.battleTime > COUNT_TIME then
        self:timeUp(2)
        return true
    end
    for i = 1, 2 do
        if self._lastTeamCount[i] == 0 and self._reviveCount[i] == 0 then
            if self._battleInfo.mustWin then
                self:Win(1)
            else
                self:Win(3 - i)
            end
            return true
        end
    end
    return false
end

function BattleLogic:setCampBrightnessEx(camp, value)

end

function BattleLogic:setAutoBattleForRightCamp(inValue)
    self._autoBattleRightCamp = inValue
end

function BattleLogic:isOpenAutoBattleForRightCamp()
    if self._autoBattleRightCamp == nil then 
        return true 
    end
    return self._autoBattleRightCamp
end

function BattleLogic:isOpenAutoBattleForLeftCamp()
    return true
end

end 
function rule.dtor()
    BattleLogic = nil
    BattleScene = nil
    BattleTeam = nil
    BC = nil
    cc = nil
    ceil = nil
    delayCall = nil
    COUNT_TIME = nil
    ECamp = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil
    EState = nil
    ETeamState = nil
    ETeamStateIDLE = nil
    ETeamStateMOVE = nil
    ETeamStateNONE = nil
    floor = nil
    INTO_DIS = nil
    INTO_SPEED = nil
    logic = nil
    objLayer = nil
    math = nil
    mcMgr = nil
    next = nil
    os = nil
    pairs = nil
    pc = nil
    rule = nil
    tab = nil
    table = nil
    tonumber = nil
    tostring = nil 
    Y_OFFSET = nil 
    abs = nil
end
return rule