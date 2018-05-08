--[[
    Filename:    BattleRule_Elemental_3.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-08-21 18:10:49
    Description: File description
--]]

-- 元素位面 气

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
    self._hpFg1_1:setVisible(false)
    self._subPro1:setVisible(false)
    self._subPro1:setColor(cc.c3b(238, 34, 45))
    
    self._hpFg2_1 = self._BattleView:getUI("uiLayer.topLayer.hpFg2_1")
    self._subPro2 = self._BattleView:getUI("uiLayer.topLayer.hpFg2_1.pro4")
    local text = self._BattleView:getUI("uiLayer.topLayer.hpFg2_1.text")
    text:setString("旋风")
    text:enableOutline(cc.c4b(0,0,0,255), 1)
    self._hpFg2_1:setVisible(true)
    self._subPro2:setVisible(true)
    self._subPro2:setColor(cc.c3b(245, 233, 252))

    self._subDestValue1 = 100
    self._subDestValue2 = 0
end

-- 显示HP
function BattleScene:countHPEx()
    local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
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

BattleSoldier._HPChange = BattleSoldier.HPChange
local BattleSoldier_HPChange = BattleSoldier._HPChange
function BattleSoldier:HPChange(attacker, _damage, crit, _damageKind, dieKind, noAnim, param1, bufflabel)
    if self.ID == BOSS1_ID then
        if logic._shieldCurHP > 0 then
            local res = BattleSoldier_HPChange(self, attacker, _damage, crit, _damageKind, 0, noAnim)
            if res < 0 then
                logic._shieldCurHP = logic._shieldCurHP + res
                logic.subDestValue2 = logic._shieldCurHP / logic._shieldMaxHP * 100
                self.team.shieldCur = logic.subDestValue2
                if logic._shieldCurHP <= 0 then
                    logic.subDestValue2 = 0
                    self.team.shieldCur = 0
                    logic:cancelSkill1()
                end
            end
            
            return res
        else
            return BattleSoldier_HPChange(self, attacker, _damage, crit, _damageKind, dieKind, noAnim)
        end
    else
        return BattleSoldier_HPChange(self, attacker, _damage, crit, _damageKind, dieKind, noAnim)
    end
end

local ETeamStateDIE = BC.ETeamState.DIE
local ETeamStateIDLE = BC.ETeamState.IDLE
local ETeamStateMOVE = BC.ETeamState.MOVE
local ETeamStateNONE = BC.ETeamState.NONE

local SKILL_1_INIT_INV = 5
local SKILL_1_INV = 20
local DOT_INV = 2
function BattleLogic:initLogicEx()
    logic = BC.logic
    objLayer = BC.objLayer

    self.subDestValue1 = 100
    self.subDestValue2 = 0

    local param = tab.elementSkillPara[3]
    self._param = param
    
    local bossTeam1 = self._teams[2][1]
    local boss1 = bossTeam1.soldier[1]

    -- 免疫buff
    local immuneBuffTab = {7, 10, 11, 12, 13, 14, 15, 16, 17, 99}
    for i = 1, #immuneBuffTab do
        bossTeam1.immuneBuff[immuneBuffTab[i]] = true
    end

    boss1.immuneForbidMove = true
    boss1.immuneForbidAttack = true
    boss1.immuneForbidSkill = true
    boss1.boss = true

    boss1:resetAttr()
    boss1.maxProDamage = 0.01
    BOSS1_ID = boss1.ID

    self._bossTeam1 = bossTeam1
    self._boss1 = boss1

    local skillLevel = bossTeam1.D["sl"][1] or 1
    if param["p5"] then
        SKILL_1_INIT_INV = param["p5"] * 0.001
    end
    if param["p6"] then
        SKILL_1_INV = (param["p6"][1] - (skillLevel - 1) * param["p6"][2]) * 0.001
        if SKILL_1_INV < 5 then
            SKILL_1_INV = 5
        end
    end
    if param["p1"] then
        DOT_INV = param["p1"] * 0.001
    end

    self._shieldMaxHP = floor((param["p4"][1] + (skillLevel - 1) * param["p4"][2]) * boss1.maxHP * 0.01)
    self._shieldCurHP = 0

    self._nextSkillTick = SKILL_1_INIT_INV
    
    self._nextDotTick = DOT_INV
    self._dotDamage = floor((param["p3"][1] + (skillLevel - 1) * param["p3"][2]) * boss1.atk * 0.01)
    self._buffid = param["buff1"]
    self._totemid = param["buff"]

    print(skillLevel, SKILL_1_INIT_INV, SKILL_1_INV, DOT_INV, self._shieldMaxHP, self._dotDamage)
end

-- 非飞行单位吹飞
function BattleLogic:doSkill1()
    self._shieldCurHP = self._shieldMaxHP
    logic.subDestValue2 = 100
    self._bossTeam1.shieldCur = 100

    local buffid = self._buffid
    local totemid = self._totemid
    local boss = self._boss1
    local soldier
    for i = 1, #self._teams[1] do
        local team = self._teams[1][i]
        if team.state ~= ETeamStateDIE and not team.isFly and not team.___totem then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                if not soldier.die then
                    local buff = BC.initSoldierBuff(buffid, 1, boss.caster, soldier)
                    soldier:addBuff(buff)
                end
            end
            team.___totem = logic:addTotemToSoldier(tab.object[totemid], 1, boss, team)
        end
    end
end

-- 取消吹飞技能
function BattleLogic:cancelSkill1()
    local boss = self._boss1
    local buffid = self._buffid
    local soldier
    for i = 1, #self._teams[1] do
        local team = self._teams[1][i]
        if team.state ~= ETeamStateDIE and not team.isFly then  
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                if not soldier.die then
                    soldier:delBuff(buffid)
                    soldier:resetAttr()
                end
            end
        end
        if team.___totem then
            team.___totem._endTick = 0
            team.___totem = nil
        end
    end
end

-- dot生效, 所有地面单位
function BattleLogic:doDot()
    if self._shieldCurHP <= 0 then return end
    local soldier
    local boss = self._boss1
    local damage = self._dotDamage
    for i = 1, #self._teams[1] do
        local team = self._teams[1][i]
        if team.state ~= ETeamStateDIE and not team.isFly and team.___totem then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                if not soldier.die then
                    soldier:rap(boss, -damage, false, false, 3, 4) 
                end
            end
        end
    end
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

function BattleLogic:BattleBeginEx()

end

function BattleLogic:updateEx()
    local tick = logic.battleTime
    if tick > self._nextSkillTick then
        self._nextSkillTick = self._nextSkillTick + SKILL_1_INV
        self:doSkill1()
    end
    if tick > self._nextDotTick then
        self._nextDotTick = self._nextDotTick + DOT_INV
        self:doDot()
    end
end

function BattleLogic:teamAttackOverEx(team)

end

function BattleLogic:onTeamDieEx(team)
    if team.___totem then
        team.___totem._endTick = 0
        team.___totem = nil
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