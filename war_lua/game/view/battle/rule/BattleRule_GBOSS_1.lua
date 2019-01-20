--[[
    Filename:    BattleRule_GBOSS_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-4-17 14:46:53
    Description: File description
--]]

-- 联盟探索BOSS1
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

local objLayer, logic
local delayCall = BC.DelayCall.dc

local SRData = BattleUtils.SRData

local updateCasterPos = BC.updateCasterPos

local rule = {}
function rule.init()

local BattleScene = require("game.view.battle.display.BattleScene")

local INTO_SPEED = 120
local INTO_DIS = 250
-- 游戏时间
local COUNT_TIME = 120

local motionFrame = {21, 0, 42, 20, 31, 42, 66, 86, 0, 0, 0, 0, 0, 0, 25}

local ADD_DEMAGE_RACEID_1 = 101
local ADD_DEMAGE_RACEID_2 = 102

local SKILL_ID_1 = 50423
local SKILL_ID_2 = 50424

local TOTEM_ID = 236

-- 一条血的权值
local hpOneValue = 20
local hpPics = {
                "hpBar1_1_battle.png",
                "hpBar1_2_battle.png",
                "hpBar1_3_battle.png",
                }
local hpColors = {
                cc.c3b(255, 193, 193),
                cc.c3b(253, 222, 194),   
                cc.c3b(255, 255, 179),
                }

local floor = math.floor
local ceil = math.ceil
local BattleTeam = require "game.view.battle.object.BattleTeam"
local BattleTeam_addDamage = BattleTeam.addDamage
local BattleTeam_addHurt = BattleTeam.addHurt
function BattleScene:initBattleUIEx()
    hpOneValue = 100 / self._battleInfo.bossHpCount
    self.CountTime = COUNT_TIME

    self._hpCount = self._battleInfo.bossHpCount

    self._diff = self._battleInfo.diff
    self._subid = self._battleInfo.subid

    self._proBar1 = self._BattleView:getUI("uiLayer.topLayer.pro1")
    self._proBar2 = self._BattleView:getUI("uiLayer.topLayer.pro2")
    self._proBar1:loadTexture("hpBar1_battle.png", 1)

    self._proBar3 = cc.Sprite:create()
    self._proBar3:setAnchorPoint(0, 0)
    self._proBar2:addChild(self._proBar3, -1)
    local proBar4 = cc.Sprite:createWithSpriteFrameName("hpBar1_0_battle.png")
    proBar4:setAnchorPoint(0, 0)
    self._proBar4 = proBar4
    self._proBar2:addChild(proBar4, -2)

    self._countLabel = self._BattleView:getUI("uiLayer.topLayer.countLabel")
    self._countLabel:setVisible(true)

    self._BattleView:getUI("uiLayer.topLayer.timeBg"):setVisible(false)
    self._BattleView:getUI("uiLayer.topLayer.timeLabel"):setPositionY(33)

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
    self._hpUpdateTick = 0
    
    self:updateMutiHpBar(100)

    if self._battleInfo.bossKill then
        self._countLabel:setString("x∞")
    end
    if self._skipBtn then
        self._skipBtn:setVisible(true)
    end
end

-- 显示HP
function BattleScene:countHPEx()
    local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
    local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
    self._destValue1 = ((hp1 + shp1) / (maxhp1 + maxshp1)) * 100
    self._proBar1:setPercent(self._destValue1)
    self:updateMutiHpBar((hp2 / maxhp2) * 100)
end

function BattleScene:updateMutiHpBar(pro)
    local count = ceil(100/hpOneValue)
    local oneBar = hpOneValue
    local a = pro - floor(pro/oneBar)*oneBar -- 余数
    local b = floor(pro/oneBar) -- 除数
    if b == count then
        b = b - 1
        a = oneBar
    end
    self._proBar2:setPercent((a / oneBar) * 100)

    local picIndex = b - floor(b/#hpPics)*#hpPics
    local picName = hpPics[picIndex + 1]
    if picName then
        self._proBar2:loadTexture(picName, 1)
        self._hpShadow2:setColor(hpColors[picIndex + 1])
    end
    picIndex = (b - 1) - floor((b - 1)/#hpPics)*#hpPics
    picName = hpPics[picIndex + 1]
    if picName then
        self._proBar3:setSpriteFrame(picName)
    end
    if not self._battleInfo.bossKill then
        self._countLabel:setVisible(b > 0)
        self._countLabel:setString("x".. b + 1)
        self._proBar3:setVisible(b > 0)
        self._proBar4:setVisible(b > 0)
    end
end

local abs = math.abs
function BattleScene:updateEx(dt)
    local tick = logic.battleTime
    local dest2 = self._proBar2:getPercent()
    if dest2 > self._shadowValue2 then
        self._shadowValue2 = 100
        self._hpShadow2:setPercent(self._shadowValue2)
    end
    if tick > self._hpUpdateTick + 1.0 then
        self._hpUpdateTick = tick
        self._hpAnim1 = false
        self._hpAnim2 = false
    elseif tick > self._hpUpdateTick + 0.8 then
        self._shadowValue1 = self._shadowValue1 + (self._destValue1 - self._shadowValue1) * 0.5
        if abs(self._shadowValue1 - self._destValue1) < 1 then
            self._shadowValue1 = self._destValue1
        end
        self._hpShadow1:setPercent(self._shadowValue1)
        if not dontAnim then 
            self._shadowValue2 = self._shadowValue2 + (dest2 - self._shadowValue2) * 0.5 
            if abs(self._shadowValue2 - dest2) < 1 then
                self._shadowValue2 = dest2
            end
            self._hpShadow2:setPercent(self._shadowValue2)
        end
    else
        if not self._hpAnim1 and abs(self._destValue1 - self._shadowValue1) > 5 then
            self._hpAnim1 = true
            self._hpShadow1:setOpacity(255)
            self._hpShadow1:stopAllActions()
            --self._hpShadow1:runAction(cc.FadeTo:create(0.1, 185))
        end
        if not self._hpAnim2 and abs(dest2 - self._shadowValue2) > 5 then
            self._hpAnim2 = true
            self._hpShadow2:setOpacity(255)
            self._hpShadow2:stopAllActions()
            --self._hpShadow2:runAction(cc.FadeTo:create(0.1, 185))
        end
    end
    local a, b, hp2, c = logic:getCurHP()
    if self.__hp2 == nil then
        self.__hp2 = hp2
    else
        if self.__hp2 < hp2 then
            self._shadowValue2 = dest2
            self._hpShadow2:setPercent(self._shadowValue2)
        end
        self.__hp2 = hp2
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
        self:jumpBattleBeginAnim()
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
    -- 黑屏渐变
    self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
        self._frontLayer:getView():setVisible(false)
    end)))

    self._camera = cc.Node:create()
    self._rootLayer:addChild(self._camera)
    local dx1, dy1 = logic:getLeftTeamCenterPoint()
    -- local dx1 = MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale() + 150
    -- local dy1 = BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 - 20
    local dx2 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5
    local dy2 = dy1
    local dx3 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 - 230
    local dy3 = dy1
    
    self:screenToPos(0, dy1, false)
    self._animId = ScheduleMgr:regSchedule(1, self, function(self)
        if self._follow then
            if self._camera then
                local _x, _y = logic:getLeftTeamCenterPoint()
                self._camera:setPosition(_x, _y)
            else
                self._follow = nil
            end
        end
        if self._camera then
            self:screenToPos(self._camera:getPositionX(), self._camera:getPositionY(), 0.2)
        end
    end)
    local tick = logic:getBossBornTick()
    self._follow = true
    logic:goInto(function ()
        logic.battleState = EState.READY
        self._follow = false
        self._camera:runAction(cc.Sequence:create(
                                            cc.CallFunc:create(function ()
                                                logic:warnning()
                                            end),
                                            cc.DelayTime:create(0.2),
                                            cc.CallFunc:create(function ()
                                                logic:bossInto1()
                                            end),
                                            cc.DelayTime:create(0.3),
                                            cc.CallFunc:create(function ()
                                                logic:bossInto2()
                                            end),
                                            cc.EaseIn:create(cc.MoveTo:create(0.8, cc.p(dx2 - 100, dy2)), 3),
                                            cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(dx2, dy2)), 3),
                                            cc.DelayTime:create(0.3),
                                            cc.CallFunc:create(function ()
                                                logic:bossInto3()
                                            end),
                                            cc.DelayTime:create(tick),
                                            cc.EaseIn:create(cc.MoveTo:create(0.8, cc.p(dx3, dy3)), 3),
                                            cc.CallFunc:create(function ()
                                                self:commonRealBattleBegin()
                                            end)
                                            ))
    end)
end

-- 战斗开始动画
function BattleScene:battleBeginMCEx()
    audioMgr:playSoundForce("horn")

    local mc = mcMgr:createViewMC("zaoyuboss_boss", false, true)
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 14)
    self._rootLayer:getParent():addChild(mc)
end

--  跳过开场动画
function BattleScene:jumpBattleBeginAnimEx()
    self._follow = nil
    if self._camera then
        local dx1 = MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale() + 150
        local dy1 = BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 - 20
        local dx2 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5
        local dy2 = dy1
        local dx3 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 - 230
        local dy3 = dy1

        logic:jumpBattleBeginAnimEx()
        self._frontLayer:getView():stopAllActions()
        self._frontLayer:getView():setOpacity(0)

        self._camera:stopAllActions()
        self._camera:setPosition(dx3, dy3)
        self:screenToPos(dx3, dy3, false)

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
    local v1 = logic._boss.maxHP - logic._boss.HP
    local v2 = logic._boss.maxHP
    if not BATTLE_PROC and logic.__HP_1 then
        local v1_1 = 0
        for i = 1, #logic.__HP_1 do
            v1_1 = v1_1 + logic.__HP_1[i]
        end
        local v1_2 = 0
        for i = 1, #logic.__HP_2 do
            v1_2 = v1_2 + (8765 - logic.__HP_2[i])
        end
        if v2 * 7 + 8 ~= logic.__maxHP_1 or v2 * 4 + 6 ~= logic.__maxHP_2 then
            if OS_IS_WINDOWS then
                 ViewManager:getInstance():onLuaError(serialize({2222, v2, logic.__maxHP_1, logic.__maxHP_2}))
            end
            v2 = 9999999999
        end
        if v1 ~= v1_1 or v1 * 11 ~= v1_2 or v1_1 * 11 ~= v1_2 then
            if OS_IS_WINDOWS then
                 ViewManager:getInstance():onLuaError(serialize({1111, v1, v1_1, v1_2}))
            end
            v1 = 0
            v2 = 1
        end
    end
    res["exInfo"] = {diff = self._diff, subid = self._subid, pro = math.floor(v1 / v2 * 100),
                        damage = v1}
end

local BattleLogic = require("game.view.battle.logic.BattleLogic")
local BattleTeam = require("game.view.battle.object.BattleTeam")

local random = BC.ran
local ETeamStateDIE = BC.ETeamState.DIE
local initSoldierBuff = BC.initSoldierBuff 

function BattleLogic:jumpBattleBeginAnimEx()
    self._jsJumpBeginAnim = true

    self._boss:changeMotion(1)

    local team, soldier
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if team.__x then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                soldier:stopMove()
                soldier:setPos(soldier.__x, soldier.__y)
            end
            team.x = team.__x
            team.y = team.__y
        end
    end
    self._heros[1]:stopMove()
    self._heros[1]:setPos(24 * 40, 15 * 40)
    self.battleState = EState.READY
end

-- local BOSS_HP = 100000
function BattleLogic:initLogicEx(procBattle)
    logic = BC.logic
    objLayer = BC.objLayer
    -- 左边不能绕背
    local team, soldier
    if not procBattle then
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            team.goBack = false
            -- 初始位置往后挪
            team.__x = team.x
            team.__y = team.y
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                soldier.__x = soldier.x
                soldier.__y = soldier.y
                soldier:setPos(soldier.x - INTO_DIS, soldier.y)
            end
        end
    else
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            team.goBack = false
        end
    end

    -- 特定阵营的的兵团增加50%兵团上海
    local soldier
    local ATTR_DamageInc = BC.ATTR_DamageInc
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if team.race1 == ADD_DEMAGE_RACEID_1 or team.race1 == ADD_DEMAGE_RACEID_2 then
            soldiers = team.soldier
            for k = 1, #soldiers do
                soldier = soldiers[k]
                soldier.baseAttr[ATTR_DamageInc] = soldier.baseAttr[ATTR_DamageInc] + 50
                soldier.baseSum = nil
                soldier:resetAttr()
            end
        end
    end

    self._heros[1]:setPos(24 * 40 - INTO_DIS, 15 * 40)

    self._heros[1]:moveTo(24 * 40, 15 * 40, INTO_SPEED)

    local bossTeam = BattleTeam.new(ECamp.RIGHT, 0)
    self._bossTeam = bossTeam
    bossTeam.showHP = false
    bossTeam.showHead = false

    local bossLevel = self._battleInfo.bossLevel
    self._bossKill = self._battleInfo.bossKill

    local info = {npcid = self._battleInfo.bossId, level = 1, summon = false}
    BC.initTeamAttr_Npc(bossTeam, self._heros[2], info, 1200, 320)    
    self:_raceCountAdd(2, bossTeam.race1, bossTeam.race2)
    self.classCount[2][bossTeam.classLabel] = self.classCount[2][bossTeam.classLabel] + 1
    bossTeam.noHUD = true
    self:addTeam(bossTeam)   
    local boss = bossTeam.soldier[1]
    boss:changeMotion(17)
    self._boss = boss
    boss.boss = true

    -- 原始出场方阵标记
    bossTeam.boss = true
    bossTeam.original = true
    bossTeam.cantSort = true
    bossTeam.goBack = false
    bossTeam.turnFire = false

    bossTeam.isSiege = true
    bossTeam.radius = 100
    boss.radius = 100

    -- 水系伤害减免50%
    boss.baseAttr[BC.ATTR_RWater] = 50

    -- 攻血
    boss.baseAttr[BC.ATTR_Atk] = boss.baseAttr[BC.ATTR_Atk] * bossLevel
    boss.baseAttr[BC.ATTR_HP] = boss.baseAttr[BC.ATTR_HP] * bossLevel

    bossTeam.immuneBuff[1] = true
    bossTeam.immuneBuff[7] = true
    bossTeam.immuneBuff[9] = true
    bossTeam.immuneBuff[10] = true
    bossTeam.immuneBuff[16] = true

    boss.immuneForbidMove = true
    boss.immuneForbidAttack = true
    boss.immuneForbidSkill = true
    boss.baseSum = nil
    boss:resetAttr()
    boss.maxDamage = floor(boss.maxHP * 0.03)
    if self._bossKill then
        boss.minHPEx = 1
    end

    if not BATTLE_PROC then
        self.__HP_1 = {}
        self.__HP_2 = {}
        self.__HP_1_count = GRandom(10) + GRandom(12)
        self.__HP_2_count = GRandom(10) + GRandom(12)
        for i = 1, self.__HP_1_count do
            self.__HP_1[i] = 0
        end
        for i = 1, self.__HP_2_count do
            self.__HP_2[i] = 8765
        end
        self.__maxHP_1 = boss.maxHP * 7 + 8
        self.__maxHP_2 = boss.maxHP * 4 + 6
    end

    -- BOSS是否在战斗中
    self._bossInBattle = false
    self._bossStep = 1
    self._bossCasting = false

    -- 两个阶段
    -- 第一阶段正常
    -- 第二阶段秒杀

    self._killAll = false

    local tick = 0
    self._bossSkill = {}
    -- 打近战
    self._bossSkill[1] = {tick = tick, motion = 3, cd = 2, step = {true, false}}
    -- AOE近战（无近战时候释放）
    self._bossSkill[2] = {tick = tick, motion = 5, cd = 10, step = {true, false}}
    -- 打远程
    self._bossSkill[3] = {tick = tick, motion = 6, cd = 99999, step = {false, false}}
    -- 随机AOE
    self._bossSkill[4] = {tick = tick, motion = 7, cd = 15, step = {true, false}}
    -- 秒人
    self._bossSkill[5] = {tick = tick, motion = 15, cd = 3, step = {false, true}}

    self._skillSortTab = {5, 4, 2, 3, 1}

    if SRData then
        SRData[104] = self._battleInfo.bossId
        SRData[109] = boss.atk
        SRData[110] = boss.atk * 1.5
        SRData[111] = boss.maxHP
        SRData[112] = boss.maxHP

        SRData[352] = 1
    end

    self:addTotemToPos(tab.object[TOTEM_ID], 1, self._boss, self._boss.x, self._boss.y)
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

function BattleLogic:BattleBeginEx()

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

function BattleLogic:bossInto1()
    self:shake(4, 1)
    ScheduleMgr:delayCall(770, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(4, 2)
    end)
    ScheduleMgr:delayCall(770 * 2, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(4, 3)
    end)
    ScheduleMgr:delayCall(770 * 3, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(4, 4)
    end)
end

function BattleLogic:bossInto2()

end

local EMotionBORN = EMotion.BORN

function BattleLogic:bossInto3()
    ScheduleMgr:delayCall(25 * 50 * 1.33, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(2, 4)
    end)
    local frame = motionFrame[8]
    self._boss:changeMotion(EMotionBORN)
    ScheduleMgr:delayCall(49 * 50 * 1.33, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(5, 3)
    end)
    ScheduleMgr:delayCall(frame * 50 * 1.33, self, function ()
        if self._jsJumpBeginAnim then return end
        self._boss:changeMotion(1)
    end)
    return frame
end

function BattleLogic:warnning()
    local team
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if not team.original then break end
        if team.__x then
            team.x = team.__x
            team.y = team.__y
        end
        objLayer:playEffect_skill1("start_tanhao", team.x, team.y + 75, true, true, 1, 2)
    end
end

function BattleLogic:getBossBornTick()
    return motionFrame[8] * 0.05 * 1.3
end

local skillName = {"", "", lang("DULONGSKILL_3"), lang("DULONGSKILL_4"), lang("DULONGSKILL_4")}
function BattleLogic:updateEx()
    if self.battleState ~= EState.OVER then
        if self._bossInBattle and not self._boss.die then
            local tick = self.battleTime
            if not self._killAll then
                if self._bossKill and tick > 60 then
                    self._killAll = true
                    for i = 1, 4 do
                        self._bossSkill[i].step = {false, false}
                    end
                    self._bossSkill[5].step = {true, true}
                end
            end
            if not self._bossCasting then
                local skill
                for i = 1, #self._bossSkill do
                    skill = self._bossSkill[self._skillSortTab[i]]
                    if skill.step[self._bossStep] and tick >= skill.tick then
                        skill.tick = tick + skill.cd
                        self:bossCastSkill(self._skillSortTab[i])
                        break
                    end
                end
            end
        end
    end
end

function BattleLogic:teamAttackOverEx(team)

end

function BattleLogic:bossCastSkill(index)
    local skill = self._bossSkill[index]
    --释放技能
    if skill.motion ~= 0 then
        self._bossCasting = true
        local frame = motionFrame[skill.motion] 
        self._boss:changeMotion(skill.motion)
        delayCall(frame * 0.05, self, function ()
            self._bossCasting = false
        end)
    end
    -- print(index, self.battleTime)
    self["bossSkillAction"..index](self)
end

-- boss造成伤害
local countDamage_attack = BC.countDamage_attack
local randomSelect = BC.randomSelect

function BattleLogic:bossDamage(targetList, hpPro, atkPro, dk)
    BC.updateCaster(self._boss, logic)
    local atkD = self._boss.caster.atk * atkPro
    local dieKind = 0
    if dk == nil then
        dk = 1
    else
        dieKind = dk
    end
    local hpD
    local target
    local damage, crit, dodge, hurtValue, realDamage
    for i = 1, #targetList do
        target = targetList[i]
        if not target.die then
            hpD = target.maxHP * hpPro
            self._boss.caster.atk = ceil(atkD)
            damage, crit, dodge, hurtValue = countDamage_attack(logic, self._boss.caster, target, 100, 0, 0, dk, 100)
            damage = damage + ceil(hpD)
            realDamage = target:rap(self._boss, -damage, crit, dodge, dk - 1, dieKind)

            -- 伤害统计
            BattleTeam_addDamage(self._bossTeam, hurtValue, -realDamage)
            BattleTeam_addHurt(target.team, hurtValue, -realDamage)
            if SRData then
                if realDamage == 0 then
                    SRData[368] = SRData[368] + 1
                else
                    SRData[367] = SRData[367] + 1
                end
            end
        end
    end
end

-- 打近战 10%生命上限+100%atk
function BattleLogic:bossSkillAction1()
    local meleeCount = 0
    for i = 1, #self._teams[1] do
        if self._teams[1][i].state ~= ETeamStateDIE and self._teams[1][i].isMelee then
            meleeCount = meleeCount + 1
        end
    end
    -- 近战都死了, 一直打远程
    if meleeCount == 0 then
        self:bossSkillAction3()
        return
    end
    -- 打最近的近战兵团
    delayCall(20 * 0.05, self, function ()
        self:shake(2, 2)

        local teams = self.targetCache[2][5]
        local minDis = 99999999
        local team
        local x1, y1 = self._boss.x, self._boss.y
        local x2, y2
        local d
        for i = 1, #teams do
            if teams[i].state ~= ETeamStateDIE then
                x2, y2 = teams[i].x, teams[i].y
                d = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
                if d < minDis then
                    minDis = d
                    team = teams[i]
                end
            end
        end

        if team then
            self:bossDamage(team.soldier, 0.05, 1)
        end
    end)
end

-- AOE近战 10%生命上限+5秒晕眩
function BattleLogic:bossSkillAction2()
    self:soldierCastSkill(nil, tab.skill[SKILL_ID_1], 1, updateCasterPos(self._boss))
    delayCall(14 * 0.05, self, function ()
        self:shake(2, 2)
    end)
end

-- 打远程 15%生命上限+100%atk
function BattleLogic:bossSkillAction3()
    self._boss:changeMotion(6)

    delayCall(26 * 0.05, self, function ()
        local teams = self.targetCache[2][5]
        local minDis = 99999999
        local team
        local x1, y1 = self._boss.x, self._boss.y
        local x2, y2
        local d
        for i = 1, #teams do
            if teams[i].state ~= ETeamStateDIE then
                x2, y2 = teams[i].x, teams[i].y
                d = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
                if d < minDis then
                    minDis = d
                    team = teams[i]
                end
            end
        end

        if team then
            local dis = math.sqrt((team.x - self._boss.x) * (team.x - self._boss.x) + (team.y - self._boss.y) * (team.y - self._boss.y))
            objLayer:rangeAttackPt(self._boss.ID, team.x, team.y, 0, 300, 2, "bingjurendandao", dis, 200)
            local tick = BC.getBulletFlyTime(2, 300, dis)
            -- 打最近的远程兵团
            delayCall(tick, self, function ()
                self:shake(2, 2)
                objLayer:playEffect_skill1("handi_handi", team.x, team.y, 1, true, nil, 2)
                self:bossDamage(team.soldier, 0.075, 1)
            end)
        end
    end)
end
-- 随机AOE 15%生命上限+100%atk+5秒晕眩
function BattleLogic:bossSkillAction4()
    self:soldierCastSkill(nil, tab.skill[SKILL_ID_2], 1, updateCasterPos(self._boss))
    delayCall(28 * 0.05, self, function ()
        self:shake(2, 2)
    end)
end

-- 秒人
function BattleLogic:bossSkillAction5()
    delayCall(17 * 0.05, self, function ()
        self:shake(5, 3)
        self:killAll(1)
    end)
end

function BattleLogic:onTeamDieEx(team)
    if team == self._bossTeam then
        self._bossInBattle = false
        if SRData then
            SRData[353] = 1
        end
    end
end

local getRowIndex = BC.getRowIndex

function BattleLogic:onSoldierDieEx(soldier)

end

function BattleLogic:onHPChangeEx(soldier, change)
    if soldier == self._boss then
        if not BATTLE_PROC and self._bossStep then
            local index = GRandom(#self.__HP_1)
            self.__HP_1[index] = self.__HP_1[index] - change
            index = GRandom(#self.__HP_2)
            self.__HP_2[index] = self.__HP_2[index] + 11 * change
        end
        if not self._bossInBattle then
            -- 第一次受到攻击, 进入战斗
            self._bossInBattle = true
            print("进入第一阶段")
        else
            if self._bossKill then
                local hpPro = self._boss.HP / self._boss.maxHP * 100
                -- 阶段转换
                if self._bossStep == 1 then
                    if hpPro <= 10 then
                        print("进入第二阶段")
                        if not self._killAll then
                            for i = 1, 4 do
                                self._bossSkill[i].step = {false, false}
                            end
                            self._bossSkill[5].step = {true, true}
                            self._killAll = true
                        end
                        self._bossStep = 2
                    end
                end
            end
        end
    end
end

function BattleScene:getBeginMCDelay()
    return 36 * 0.05
end

-- 胜利条件
function BattleLogic:checkWinEx()
    if self._surrender then
        self:bossOver()
        self:surrender(2)
        return true
    end

    for i = 1, 2 do
        if self._lastTeamCount[i] == 0 and self._reviveCount[i] == 0 then
            self:bossOver()
            self:Win(3 - i)
            return true
        end
    end
    if self.battleTime > COUNT_TIME then
        self:bossOver()
        self:timeUp(2)
        return true
    end
    return false
end

function BattleLogic:bossOver()
    if SRData then
        SRData[354] = self._boss.firstDamageMaxHP
        SRData[355] = self._boss.firstDamageMinHP
        SRData[359] = self._boss.maxHP
        if self._bossTeam.state ~= ETeamState.DIE then
            SRData[369] = self.battleTime
        else
            SRData[369] = self._bossTeam.dieTick
        end
    end
end

function BattleLogic:setCampBrightnessEx(camp, value)

end

function BattleLogic:isOpenAutoBattleForLeftCamp()
    return true
end

function BattleLogic:isOpenAutoBattleForRightCamp()
    return false
end
end
function rule.dtor()
    BattleLogic = nil
    BattleScene = nil
    BattleTeam = nil
    BC = nil
    cc = nil
    ceil = nil
    COUNT_TIME = nil
    ECamp = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil
    EMotionBORN = nil
    EState = nil
    ETeamState = nil
    ETeamStateDIE = nil
    floor = nil
    getRowIndex = nil
    hpOneValue = nil
    hpPics = nil
    hpColors = nil
    initSoldierBuff = nil
    INTO_DIS = nil
    INTO_SPEED = nil
    math = nil
    mcMgr = nil
    motionFrame = nil 
    next = nil
    objLayer = nil
    logic = nil
    os = nil
    pairs = nil
    pc = nil
    random = nil
    rule = nil
    SKILL_ID_3 = nil
    SKILL_ID_4 = nil
    SKILL_ID_5 = nil
    skillName = nil
    tab = nil
    table = nil
    tonumber = nil
    tostring = nil
    abs = nil
    delayCall = nil
    SRData = nil
    BattleTeam_addDamage = nil
    BattleTeam_addHurt = nil
    BattleTeam = nil
    ADD_DEMAGE_RACEID_1 = nil
    ADD_DEMAGE_RACEID_2 = nil
    SKILL_ID_1 = nil
    SKILL_ID_2 = nil
    updateCasterPos = nil
end 
return rule