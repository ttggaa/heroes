--[[
    Filename:    BattleRule_Elemental_4.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-08-21 18:10:49
    Description: File description
--]]

-- 元素位面 土

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
local random = BC.ran

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

local mran = math.random
-- 一条血的权值
local hpOneValue = 16.66
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

local Y_OFFSET = 30

local BattleScene = require("game.view.battle.display.BattleScene")
local COUNT_TIME = 180
local INTO_SPEED = 140
local INTO_DIS = 800
function BattleScene:initBattleUIEx()
    hpOneValue = 100 / 6
    self.CountTime = COUNT_TIME

    self._hpCount = 6

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

    -- 特殊资源条
    self._hpFg1_1 = self._BattleView:getUI("uiLayer.bottomLayer2.hpFg1_1")
    self._subPro1 = self._BattleView:getUI("uiLayer.bottomLayer2.hpFg1_1.pro3")
    local text = self._BattleView:getUI("uiLayer.bottomLayer2.hpFg1_1.text")
    text:setString("大地祭祀血量达到满值战斗胜利")
    text:enableOutline(cc.c4b(0,0,0,255), 1)
    self._hpFg1_1:setVisible(true)
    self._subPro1:setVisible(true)
    self._subPro1:setColor(cc.c3b(0, 232, 28))

    local npcD = tab.npc[894101]
    local art1 = npcD["art1"]
    local sp = cc.Sprite:createWithSpriteFrameName(art1 .. ".jpg")
    sp:setPosition(22, 25)
    sp:setScale(.64)
    sp:setLocalZOrder(50)
    self._hpFg1_1:addChild(sp)
    
    self._hpFg2_1 = self._BattleView:getUI("uiLayer.topLayer.hpFg2_1")
    self._subPro2 = self._BattleView:getUI("uiLayer.topLayer.hpFg2_1.pro4")
    self._hpFg2_1:setVisible(false)
    self._subPro2:setVisible(false)
    self._subPro2:setColor(cc.c3b(174, 225, 238))

    self._subDestValue1 = 10
    self._subDestValue2 = 10
end

-- 显示HP
function BattleScene:countHPEx()
    local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
    local boss = logic._boss1
    hp1 = hp1 - boss.HP
    maxhp1 = maxhp1 - boss.maxHP
    local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
    self._destValue1 = ((hp1 + shp1) / (maxhp1 + maxshp1)) * 100
    self._proBar1:setPercent(self._destValue1)
    self:updateMutiHpBar((hp2 / maxhp2) * 100)
    self._subDestValue1 = logic.subDestValue1
    self._subDestValue2 = logic.subDestValue2
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
    self._proBar3:setVisible(b > 0)
    self._proBar4:setVisible(b > 0)
    self._countLabel:setVisible(b > 0)
    self._countLabel:setString("x".. b + 1)
    if b + 1 < self._hpCount then
        self._hpCount = b + 1
    end
end

-- update
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

    -- 特殊资源条
    if self._subPro1:isVisible() then
        local value = self._subPro1:getPercent()
        if value ~= self._subDestValue1 then
            value = value + (self._subDestValue1 - value) * 0.3
            if abs(self._subDestValue1 - value) < 1 then
                value = self._subDestValue1
            end
            self._subPro1:setPercent(value)
        end
    end
    if self._subPro2:isVisible() then
        local value = self._subPro2:getPercent()
        if value ~= self._subDestValue2 then
            value = value + (self._subDestValue2 - value) * 0.3
            if abs(self._subDestValue2 - value) < 1 then
                value = self._subDestValue2
            end
            self._subPro2:setPercent(value)
        end
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
    -- 黑屏渐变
    self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
        self._frontLayer:getView():setVisible(false)
    end)))
    self._camera = cc.Node:create()
    self._rootLayer:addChild(self._camera)
    local sy = BC.MAX_SCENE_HEIGHT_PIXEL - 200
    local dx1, dy1 = logic:getRightTeamCenterPoint(BC.reverse)
    local dx2, dy2 = logic:getLeftTeamCenterPoint(BC.reverse)
    dx1 = 2000
    dy1 = 360 + Y_OFFSET
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
local BattleSoldier = require("game.view.battle.object.BattleSoldier")
local BOSS1_ID
local BOSS2_ID
local SUMMON_NPCID_1
local SUMMON_NPCID_2
local SUMMON_NPCID_3
local SUMMON_NPCID_4
local SUMMON_NPCLV_1
local SUMMON_NPCLV_2
local SUMMON_NPCLV_3
local SUMMON_NPCLV_4
BattleSoldier._HPChange = BattleSoldier.HPChange
local BattleSoldier_HPChange = BattleSoldier._HPChange
function BattleLogic:BattleBeginEx()
    function BattleSoldier:HPChange(attacker, _damage, crit, _damageKind, dieKind, noAnim, param1, bufflabel)
        local id = self.ID
        if self.camp == 1 then
            -- 阵营1
            if id ~= BOSS1_ID then
                -- 不是我方BOSS，则复制治疗量
                local res = BattleSoldier_HPChange(self, attacker, _damage, crit, _damageKind, dieKind, noAnim)
                if res > 0 then
                    local boss1 = logic._boss1
                    boss1:heal(attacker, res, nil, 998877)
                    logic.subDestValue1 = boss1.HP / boss1.maxHP * 100
                end
                return res
            else
                -- 是我方BOSS，如果加血来源是998877，则正常加血。
                if _damage > 0 then
                    if param1 == 998877 then
                        return BattleSoldier_HPChange(self, attacker, _damage, crit, _damageKind, dieKind, noAnim)
                    else
                        return 0, true
                    end
                else
                    local res = BattleSoldier_HPChange(self, attacker, _damage, crit, _damageKind, dieKind, noAnim)
                    logic.subDestValue1 = self.HP / self.maxHP * 100
                    return res
                end
            end
        else
            -- 阵营2
            if id == BOSS2_ID then
                -- 敌方BOSS，免疫一切
                if not BATTLE_PROC then if mran(10) == 1 then self:HPanim_immune() end end
                return 0, true
            else
                return BattleSoldier_HPChange(self, attacker, _damage, crit, _damageKind, dieKind, noAnim)
            end
        end
    end
end

BattleSoldier._addBuff = BattleSoldier.addBuff
local BattleSoldier_addBuff = BattleSoldier._addBuff
function BattleSoldier:addBuff(buff)
    if self.ID == BOSS1_ID then
        return
    else
        BattleSoldier_addBuff(self, buff)
    end
end

local getFormationScenePos = BC.getFormationScenePos

local ETeamStateDIE = BC.ETeamState.DIE
local ETeamStateIDLE = BC.ETeamState.IDLE
local ETeamStateMOVE = BC.ETeamState.MOVE
local ETeamStateNONE = BC.ETeamState.NONE
function BattleLogic:initLogicEx()
    logic = BC.logic
    objLayer = BC.objLayer

    self.subDestValue1 = 10
    self.subDestValue2 = 10

    local param = tab.elementSkillPara[4]
    self._param = param
    local elementalPlaneD = self._battleInfo.elementalPlaneD
    self._elementalPlaneD = elementalPlaneD
        
    local n3 = elementalPlaneD["n3"]
    local n4 = elementalPlaneD["n4"]
    local n5 = elementalPlaneD["n5"]
    local n6 = elementalPlaneD["n6"]
    if n3 then
        SUMMON_NPCID_1 = {n3[1][1], n3[2][1], n3[3][1], n3[4][1]}
        SUMMON_NPCLV_1 = {n3[1][2], n3[2][2], n3[3][2], n3[4][2]}
    end
    if n4 then
        SUMMON_NPCID_2 = {n4[1][1], n4[2][1], n4[3][1], n4[4][1]}
        SUMMON_NPCLV_2 = {n4[1][2], n4[2][2], n4[3][2], n4[4][2]}
    end
    if n5 then
        SUMMON_NPCID_3 = n5[1][1]
        SUMMON_NPCLV_3 = n5[1][2]
    end
    if n6 then
        SUMMON_NPCID_4 = n6[1][1]
        SUMMON_NPCLV_4 = n6[1][2]
    end

    local bossNpcID1 = elementalPlaneD["n1"][1]
    local bossNpcID2 = elementalPlaneD["n2"][1]

    local bossTeam = BattleTeam.new(1, 0)
    local info = {npcid = bossNpcID1, level = 1, summon = false, fixHP = true}
    BC.initTeamAttr_Npc(bossTeam, self._heros[1], info, 900, 320)    
    self:_raceCountAdd(1, bossTeam.race1, bossTeam.race2)
    self.classCount[1][bossTeam.classLabel] = self.classCount[1][bossTeam.classLabel] + 1
    self:addTeam(bossTeam)   
    local boss = bossTeam.soldier[1]  
    boss.boss = true
    -- 原始出场方阵标记
    bossTeam.isbuilding = true
    bossTeam.boss = true
    bossTeam.original = false
    bossTeam.cantSort = true
    bossTeam.goBack = false
    bossTeam.turnFire = false
    bossTeam.isSiege = true

    for i = 1, 17 do
        bossTeam.immuneBuff[i] = true
    end
    bossTeam.immuneBuff[99] = true

    boss.immuneForbidMove = true
    boss.immuneForbidAttack = true
    boss.immuneForbidSkill = true
    boss:resetAttr()
    boss:rap(nil, -ceil(boss.maxHP * 0.9), false, false, 0, 199, true)
    boss.maxProDamage = 0.01

    BOSS1_ID = boss.ID
    self._bossTeam1 = bossTeam
    self._boss1 = boss

    local bossTeam = BattleTeam.new(2, 0)
    local info = {npcid = bossNpcID2, level = 1, summon = false}
    BC.initTeamAttr_Npc(bossTeam, self._heros[1], info, 1800, 320)    
    self:_raceCountAdd(2, bossTeam.race1, bossTeam.race2)
    self.classCount[2][bossTeam.classLabel] = self.classCount[2][bossTeam.classLabel] + 1
    self:addTeam(bossTeam)   
    local boss = bossTeam.soldier[1]  
    boss.boss = true
    -- 原始出场方阵标记
    bossTeam.canDestroy = false
    bossTeam.boss = true
    bossTeam.original = true
    bossTeam.cantSort = true
    bossTeam.goBack = false
    bossTeam.turnFire = false
    bossTeam.isSiege = true

    local immuneBuffTab = {1, 2, 3, 7, 10, 11, 12, 13, 14, 15, 16, 17, 99}
    for i = 1, #immuneBuffTab do
        bossTeam.immuneBuff[immuneBuffTab[i]] = true
    end

    boss.immuneForbidMove = true
    boss.immuneForbidAttack = true
    boss.immuneForbidSkill = true
    boss:resetAttr()
    boss.maxProDamage = 0.01

    BOSS2_ID = boss.ID
    self._bossTeam2 = bossTeam
    self._boss2 = boss

    -- 60s
    self._nextSummonTick1 = 60
    self._nextSummonTick2 = 20

    -- 召唤
    local x, y
    -- 防御
    if SUMMON_NPCID_1 then
        x, y = getFormationScenePos(4, 2)
        self:summonTeam({camp = 2}, nil, SUMMON_NPCID_1[1], 0, nil, SUMMON_NPCLV_1[1], x, y)
        x, y = getFormationScenePos(8, 2)
        self:summonTeam({camp = 2}, nil, SUMMON_NPCID_1[2], 0, nil, SUMMON_NPCLV_1[2], x, y)
        x, y = getFormationScenePos(12, 2)
        self:summonTeam({camp = 2}, nil, SUMMON_NPCID_1[3], 0, nil, SUMMON_NPCLV_1[3], x, y)
        x, y = getFormationScenePos(16, 2)
        self:summonTeam({camp = 2}, nil, SUMMON_NPCID_1[4], 0, nil, SUMMON_NPCLV_1[4], x, y)
    end

    -- 射手
    if SUMMON_NPCID_2 then
        x, y = getFormationScenePos(6, 2)
        self:summonTeam({camp = 2}, nil, SUMMON_NPCID_2[1], 0, nil, SUMMON_NPCLV_2[1], x, y)
        x, y = getFormationScenePos(10, 2)
        self:summonTeam({camp = 2}, nil, SUMMON_NPCID_2[2], 0, nil, SUMMON_NPCLV_2[2], x, y)
        x, y = getFormationScenePos(5, 2)
        self:summonTeam({camp = 2}, nil, SUMMON_NPCID_2[3], 0, nil, SUMMON_NPCLV_2[3], x, y)
        x, y = getFormationScenePos(9, 2)
        self:summonTeam({camp = 2}, nil, SUMMON_NPCID_2[4], 0, nil, SUMMON_NPCLV_2[4], x, y)
    end
end

-- 防御
local posTab1 = {1, 5, 9, 13}
function BattleLogic:doSummon1()
    if SUMMON_NPCID_1 == nil then return end
    local x, y
    local ran = random(4)
    x, y = getFormationScenePos(posTab1[ran], 2)
    self:summonTeam({camp = 2}, nil, SUMMON_NPCID_1[ran], 0, nil, SUMMON_NPCLV_1[ran], x, y)
    self._boss2:changeMotion(3)
end

-- 射手
local posTab2 = {1, 5, 9, 13}
function BattleLogic:doSummon2()
    if SUMMON_NPCID_2 == nil then return end
    local x, y
    local ran = random(4)
    x, y = getFormationScenePos(posTab2[ran], 2)
    self:summonTeam({camp = 2}, nil, SUMMON_NPCID_2[ran], 0, nil, SUMMON_NPCLV_2[ran], x, y)
    self._boss2:changeMotion(3)
end

-- 突击
local posTab3 = {1, 5, 9, 13}
function BattleLogic:doSummon3()
    if SUMMON_NPCID_3 == nil then return end
    local x, y
    local ran = random(4)
    x, y = getFormationScenePos(posTab3[ran], 2)
    self:summonTeam({camp = 2}, nil, SUMMON_NPCID_3, 0, nil, SUMMON_NPCLV_3, x, y)
    self._boss2:changeMotion(3)
end

-- 刺客
function BattleLogic:doSummon4()
    if SUMMON_NPCID_4 == nil then return end
    self:summonTeam({camp = 2}, nil, SUMMON_NPCID_4, 0, nil, SUMMON_NPCLV_4, 800, 320)
    self._boss2:changeMotion(3)
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

function BattleLogic:updateEx()
    local tick = logic.battleTime
    if tick > self._nextSummonTick1 then
        self._nextSummonTick1 = self._nextSummonTick1 + 60
        self:doSummon1()
        self:doSummon2()
    end
    if tick > self._nextSummonTick2 then
        self._nextSummonTick2 = self._nextSummonTick2 + 20
        self:doSummon4()
    end
    if self._boss1.HP == self._boss1.maxHP and not self._fullHP1 then
        self._fullHP1 = true
        self._boss1:changeMotion(9)
        delayCall(3, self, function ()
            self._fullHP2 = true
        end)
    end
end

function BattleLogic:teamAttackOverEx(team)

end

function BattleLogic:onTeamDieEx(team)
    if team.camp == 1 and team.isMelee then 
        self:doSummon3()
    end
end

function BattleLogic:onSoldierDieEx(soldier)

end

function BattleLogic:onHPChangeEx(soldier, change)

end

-- 胜利条件
function BattleLogic:checkWinEx()
    if not self._fullHP1 then
        if self._surrender then
            self:surrender(2)
            return true
        end
        -- 三分钟没结果,算左边输
        if self.battleTime > COUNT_TIME then
            self:timeUp(2)
            return true
        end
        if self._boss1.HP == 0 then
            self:Win(2)
            return true
        end
        if self._boss2.HP == 0 then
            self:Win(1)
            return true
        end
        if self._lastTeamCount[1] == 1 and self._reviveCount[1] == 0 then
            self:Win(2)
            return true
        end

        if self._lastTeamCount[2] == 0 and self._reviveCount[2] == 0 then
            self:Win(1)
            return true
        end
    else
        if self._fullHP2 then
            self:Win(1)
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