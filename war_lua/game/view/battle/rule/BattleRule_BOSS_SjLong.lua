--[[
    Filename:    BattleRule_BOSS_SjLong.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-5-25 14:46:53
    Description: File description
--]]

-- 龙之国BOSS 水晶龙
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

local rule = {}
function rule.init()

local BattleScene = require("game.view.battle.display.BattleScene")

local INTO_SPEED = 120
local INTO_DIS = 250
-- 游戏时间
local COUNT_TIME = 120

local LEVEL = BC.PLAYER_LEVEL[1]
local NPCID_XIAOJINGLONG = 801041
local BUFFID_HOT1 = 4970
local BUFFID_HOT2 = 4971

-- 护盾值
local MAX_SHIELD = 100

local motionFrame = {35, 0, 33, 55, 46, 37, 31, 65, 0, 0, 0, 0, 0, 0, 56, 0, 0, 34}
local motion_atk = 3
local motion_shuijingci = 18
local motion_jiao = 15
local motion_shuijing = 6
local motion_shuijingpo = 7
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

    self._BattleView:getUI("uiLayer.topLayer.baoxiangbg"):setVisible(true)
    self._baoxiangLabel = self._BattleView:getUI("uiLayer.topLayer.baoxiangbg.baoxiangLabel")
    -- self._baoxiangLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._baoxiangLabel:setString("1")

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
    text:setString("护盾")
    text:enableOutline(cc.c4b(0,0,0,255), 1)
    self._hpFg2_1:setVisible(true)
    self._subPro2:setVisible(true)
    self._subPro2:setColor(cc.c3b(243, 180, 9))

    self._subDestValue1 = 0
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
        self:getBaoxiang(self._battleInfo.bossHpCount - self._hpCount)
    else
        -- self._baoxiangLabel:setString((self._battleInfo.bossHpCount - (b + 1)) + 1)
    end
end

function BattleScene:getBaoxiang(number)
    if BATTLE_PROC then return end
    local mc1 = mcMgr:createViewMC("line_dragonboom", false, true)
    mc1:setPosition(490, 30)
    mc1:setScaleX(1.2)
    self._topLayer:addChild(mc1, 999)
    ScheduleMgr:delayCall(375, self, function ()
        local mc2 = mcMgr:createViewMC("bao_dragonboom", false, true)
        mc2:setPosition(112, 22)
        self._BattleView:getUI("uiLayer.topLayer.baoxiangbg"):addChild(mc2)
        self._baoxiangLabel:setString(number + 1)
    end)
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
    local dx2 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + 100
    local dy2 = dy1
    local dx3 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 - 130
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

    local mc = mcMgr:createViewMC("chuihaodonghua_quanjunchuji", false, true)
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
        local dx3 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 - 230 + 100
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
            v1_2 = v1_2 + (7876 - logic.__HP_2[i])
        end
        if v2 * 3 + 7 ~= logic.__maxHP_1 or v2 * 4 + 3 ~= logic.__maxHP_2 then
            if OS_IS_WINDOWS then
                 ViewManager:getInstance():onLuaError(serialize({22222, v2, logic.__maxHP_1, logic.__maxHP_2}))
            end
            v2 = 9999999999
        end
        if v1 ~= v1_1 or v1 * 7 ~= v1_2 or v1_1 * 7 ~= v1_2 then
            if OS_IS_WINDOWS then
                 ViewManager:getInstance():onLuaError(serialize({11111, v1, v1_1, v1_2}))
            end
            v1 = -1
            v2 = 1
        end
    end
    if v1 ~= -1 then
        v1 = logic._boss.maxHP - logic._bossMinHP
    else
        v1 = 0
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
    self._heros[1]:setPos(15 * 40, 15 * 40)
    self.battleState = EState.READY
end

local EMotionBORN = EMotion.BORN

-- local BOSS_HP = 100000
function BattleLogic:initLogicEx(procBattle)
    logic = BC.logic
    objLayer = BC.objLayer

    self.subDestValue1 = 0
    self.subDestValue2 = 0

    NPCID_XIAOJINGLONG = 8010400 + self._battleInfo.diff
    -- 左边不能绕背
    local team, soldier
    if not procBattle then
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            team.goBack = false
            -- 初始位置往后挪
            team.__x = team.x + 100
            team.__y = team.y
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                soldier.__x = soldier.x + 100
                soldier.__y = soldier.y
                soldier:setPos(soldier.x - INTO_DIS + 100, soldier.y)
            end
        end
    else
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            team.goBack = false
        end
    end

    self._heros[1]:setPos(15 * 40 - INTO_DIS + 100, 15 * 40)

    self._heros[1]:moveTo(15 * 40 + 100, 15 * 40, INTO_SPEED)

    local bossTeam = BattleTeam.new(ECamp.RIGHT, 2) 
    self._bossTeam = bossTeam
    bossTeam.showHP = false
    bossTeam.showHead = false
    self._buffFrameUpdateList[1] = bossTeam

    local info = {npcid = self._battleInfo.bossId, level = LEVEL, summon = false}
    BC.initTeamAttr_Npc(bossTeam, self._heros[2], info, 1300, 340)    
    self:_raceCountAdd(2, bossTeam.race1, bossTeam.race2)
    self.classCount[2][bossTeam.classLabel] = self.classCount[2][bossTeam.classLabel] + 1
    bossTeam.noHUD = true
    self:addTeam(bossTeam)   
    local boss = bossTeam.soldier[1]
    self._boss = boss
    boss.boss = true
    -- 最后阶段才可以死
    boss.minHPEx = 1

    -- 原始出场方阵标记
    bossTeam.boss = true
    bossTeam.original = true
    bossTeam.cantSort = true
    bossTeam.goBack = false
    bossTeam.turnFire = false

    bossTeam.isSiege = true
    bossTeam.radius = 180
    boss.radius = 180
    boss._def = boss.attr[BC.ATTR_Def]

    -- 免疫buff
    bossTeam.immuneBuff[1] = true
    bossTeam.immuneBuff[7] = true
    bossTeam.immuneBuff[9] = true
    bossTeam.immuneBuff[10] = true
    bossTeam.immuneBuff[16] = true

    boss.immuneForbidMove = true
    boss.immuneForbidAttack = true
    boss.immuneForbidSkill = true

    boss:resetAttr()
    boss.maxDamage = floor(boss.maxHP * 0.03)
    self._bossMinHP = boss.HP
    
    if not BATTLE_PROC then
        self.__HP_1 = {}
        self.__HP_2 = {}
        self.__HP_1_count = GRandom(10) + GRandom(12)
        self.__HP_2_count = GRandom(10) + GRandom(12)
        for i = 1, self.__HP_1_count do
            self.__HP_1[i] = 0
        end
        for i = 1, self.__HP_2_count do
            self.__HP_2[i] = 7876
        end
        self.__maxHP_1 = boss.maxHP * 3 + 7
        self.__maxHP_2 = boss.maxHP * 4 + 3
    end

    -- BOSS是否在战斗中
    self._bossInBattle = false
    self._bossStep = 1
    self._bossCasting = false

    -- 进入第二阶段的次数
    self._step2Times = 0
    -- 普攻选择的目标
    self._skill1Targets = {}
    -- 剩余小水晶龙
    self._xiaoshuijinglongCount = 0

    -- 破水晶的HP
    self._shuijingHP = nil


    -- 水晶龙2个阶段

    -- 第一阶段 正常 普攻 水晶刺
    -- 第二阶段 血量首次到达66%/33% 变水晶 召小龙 水晶破碎回第一阶段

    -- 没有近战单位的时候, 水晶刺CD 变为0

    local tick = 0
    self._bossSkill = {}
    -- 普攻
    self._bossSkill[1] = {tick = tick, motion = motion_atk, cd = 2.5, step = {true, false}}
    -- 强化普攻
    self._bossSkill[2] = {tick = tick, motion = motion_atk, cd = 2.5, step = {false, false}} -- 废弃
    -- 水晶刺
    self._bossSkill[3] = {tick = tick, motion = motion_shuijingci, cd = 8, step = {true, false}}
    -- 召唤小龙
    self._bossSkill[4] = {tick = tick, motion = motion_jiao, cd = 99999, step = {false, true}} -- 手动
    -- 水晶爆刺
    self._bossSkill[5] = {tick = tick, motion = 0, cd = 2.5, step = {false, true}}

    self._skillSortTab = {4, 3, 1, 2, 5}

    boss:changeMotion(EMotionBORN, 100000)

    if SRData then
        SRData[104] = self._battleInfo.bossId
        SRData[109] = boss.atk
        SRData[110] = boss.atk
        SRData[111] = boss.maxHP
        SRData[112] = boss.maxHP

        SRData[352] = 1
    end
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

function BattleLogic:bossInto3()
    local frame = motionFrame[8]
    self._boss:changeMotion(1)
    self._boss:changeMotion(EMotionBORN)
    ScheduleMgr:delayCall(21 * 50, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(2, 5)
    end)
    ScheduleMgr:delayCall(46 * 50, self, function ()
        if self._jsJumpBeginAnim then return end
        audioMgr:playSound("boss_sjl_houjiao")
        self:shake(5, 5)
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
    return motionFrame[8] * 0.05
end

local skillName = {"", "", lang("SHUIJINGLONGSKILL_3"), lang("SHUIJINGLONGSKILL_4"), "", ""}
function BattleLogic:updateEx()
    if self.battleState ~= EState.OVER then
        if self._bossInBattle and not self._boss.die then
            local tick = self.battleTime
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
        self._boss:changeMotion(skill.motion, nil, function ()
            self._boss:changeMotion(1)
        end)
        delayCall(frame * 0.05, self, function ()
            self._bossCasting = false
        end)
    end
    -- print(index, BC.BATTLE_TICK)
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

-- 普攻
function BattleLogic:bossSkillAction1()
    local hpPro = self._boss.HP / self._boss.maxHP * 100
    if hpPro > 33 then
        self:_bossAtk(2)
    else
        self:_bossAtk(4)
    end
end
-- 强化普攻
function BattleLogic:bossSkillAction2()
    self:_bossAtk(4)
end

function BattleLogic:_bossAtk(number)
    -- 挑几个单位, 打到死
    -- 重击踩踏周围的近战单位，对周围的2个单位造成33%生命值+100%自身攻击力的伤害。（在水晶龙生命值低于33%时，改为对周围4各单位造成伤害）
    local meleeCount = 0
    for i = 1, #self._teams[1] do
        if self._teams[1][i].state ~= ETeamStateDIE and self._teams[1][i].isMelee then
            meleeCount = meleeCount + 1
        end
    end
    -- 近战都死了, 一直用水晶刺
    if meleeCount == 0 then
        self:bossSkillAction3()
        self._boss:changeMotion(motion_shuijingci)
        return
    end
    delayCall(21 * 0.05, self, function ()
        self:shake(2, 2)
        local needSelectTarget = false
        local needSelectIndexTab = {}
        for i = 1, number do
            if self._skill1Targets[i] then
                if self._skill1Targets[i].die then
                    self._skill1Targets[i] = nil
                    needSelectTarget = true
                    needSelectIndexTab[#needSelectIndexTab + 1] = i
                end
            else
                needSelectTarget = true
                needSelectIndexTab[#needSelectIndexTab + 1] = i
            end
        end
        if needSelectTarget then
            local list = self:getSkillPoint21({camp = 1})
            local targetList = {}
            local has = false
            for i = 1, #list do
                if not list[i].die then
                    has = false
                    for k = 1, 4 do
                        if self._skill1Targets[k] and self._skill1Targets[k].ID == list[i].ID then
                            has = true
                            break
                        end
                    end
                    if not has then
                        targetList[#targetList + 1] = list[i]
                    end
                end
            end
            if #targetList > 0 then
                local res = randomSelect(#targetList, #needSelectIndexTab)
                for i = 1, #res do
                    self._skill1Targets[needSelectIndexTab[i]] = targetList[res[i]]
                end
            end
        end
        local _list = {}
        for i = 1, 4 do
            if self._skill1Targets[i] ~= nil then
                _list[#_list + 1] = self._skill1Targets[i]
            end
        end
        self:bossDamage(_list, 0, 1)
    end)
end

-- 水晶刺
function BattleLogic:bossSkillAction3()
    objLayer:showSkillName(self._boss.ID, true, self._boss.x, self._boss.y + 200, 2, skillName[3])
    delayCall(15 * 0.05, self, function ()
        audioMgr:playSound("boss_sjl_baolieshuijing")
        objLayer:playEffect_skill1("shuijingci_shuijingci", 1000, 340, false, true, 1, 1.5)
        self:shake(4, 3)
        -- 水晶刺 
        -- 输出 防御 突击受到 100%  1 2 3
        -- 魔法 受到 300% 5 
        -- 远程 受到 800% 4
        local delaytab = {0, 0, 0, 0.3, 0.2}
        local damagetab = {1, 1, 1, 1, 1}
        local buffids = {0, 0, 0, 4986, 4986}
        local team, soldier, buff
        for i = 1, #self._teams[1] do
            local team = self._teams[1][i]
            if team.state ~= ETeamStateDIE then
                local class = team.classLabel
                delayCall(delaytab[class], self, function ()
                    local buffid = buffids[class]
                    if not BC.jump then
                        if class <= 3 then
                            for k = 1, #team.aliveSoldier do
                                soldier = team.aliveSoldier[k]
                                if buffid ~= 0 then
                                    buff = initSoldierBuff(buffid, LEVEL, self._boss.caster, soldier)
                                    soldier:addBuff(buff)
                                end
                                objLayer:playEffect_skill1("shouji_shuijingci", soldier.x, soldier.y, true, true, 1, 2)
                            end
                        else
                            for k = 1, #team.aliveSoldier do
                                soldier = team.aliveSoldier[k]
                                if buffid ~= 0 then
                                    buff = initSoldierBuff(buffid, LEVEL, self._boss.caster, soldier)
                                    soldier:addBuff(buff)
                                end
                                soldier:hitFly()
                                objLayer:playEffect_skill1("shouji_shuijingci", soldier.x, soldier.y, true, true, 1, 2)
                            end
                        end
                    end
                    self:bossDamage(team.soldier, 0, damagetab[class])
                end)
            end
        end
    end)
end
-- 全体晕眩+晶化+丢失目标+召唤小龙
function BattleLogic:bossSkillAction4()
    if not BC.jump then
        self._control:heroSkillAnim(2, skillName[4], nil, "half_Shuijinglong", 1)
    end
    delayCall(22 * 0.05, self, function ()
        audioMgr:playSound("boss_sjl_houjiao")
        self:shake(5, 3)
        local team, soldier, buff
        self._bossTeam.canDestroy = false
        self:summonTeam({camp = 2}, nil, NPCID_XIAOJINGLONG, 0, 9, LEVEL, 800, 500)
        self:summonTeam({camp = 2}, nil, NPCID_XIAOJINGLONG, 0, 9, LEVEL, 1050, 500)
        self:summonTeam({camp = 2}, nil, NPCID_XIAOJINGLONG, 0, 9, LEVEL, 800, 180)
        self:summonTeam({camp = 2}, nil, NPCID_XIAOJINGLONG, 0, 9, LEVEL, 1050, 180)
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            if team.state ~= ETeamStateDIE then
                self:teamAttackOver(team)
            end
        end
        self._xiaoshuijinglongCount = 4
    end)
    delayCall(58 * 0.05, self, function ()
        self.subDestValue2 = 100
        local buffid
        if self._step2Times == 1 then
            buffid = BUFFID_HOT1
        else
            buffid = BUFFID_HOT2
        end
        local buff = initSoldierBuff(buffid, LEVEL, self._boss.caster, self._boss)
        self._boss:addBuff(buff)
        self._boss:changeMotion(motion_shuijing, nil, nil, false, true)
    end)
    if SRData then
        SRData[374] = SRData[374] + 1
        SRData[375] = SRData[375] + 4
    end
end
-- 水晶爆刺 我放全体单位 随机出一个
function BattleLogic:bossSkillAction5(callback)
    local targets = self:getSkillPoint16({camp = 1})
    local maxVolume = 0
    local target
    for i = 1, #targets do
        if not targets[i].die then
            if targets[i].team.volume > maxVolume then
                maxVolume = targets[i].team.volume
                target = targets[i]
            end
        end
    end
    if target then
        audioMgr:playSound("boss_sjl_shuijingci")
        target:hitFlyEx(3)
        delayCall(0.2, self, function ()
            self:bossDamage({target}, 500, 1)
        end)
        objLayer:playEffect_skill1("baolieshuijing_baolieshuijing", target.x, target.y, false, true, 1)
    end
end
-- 晶体破碎
function BattleLogic:bossSkillAction6(callback)
    self._boss:delBuff(BUFFID_HOT1)
    self._boss:delBuff(BUFFID_HOT2)
    self._boss.bossDef = 0
    self._boss:changeMotion(motion_shuijingpo, nil, nil, true)
    delayCall(10 * 0.05, self, function ()
        local team, soldier
        local addhp = self._boss.caster.atk * 7
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            if team.state ~= ETeamState.DIE then
                objLayer:playEffect_skill1("rexuesongge2_rexuesongge", team.x, team.y, true, true, 1)
                for k = 1, #team.aliveSoldier do
                    soldier = team.aliveSoldier[k]
                    soldier:heal(self._boss, addhp)
                end
            end
        end
    end)
    delayCall(31 * 0.05, self, function ()
        callback()
    end)
end

-- 召唤生物
function BattleLogic:summonTeamEx(team)
    team.goBack = false
end

function BattleLogic:onTeamDieEx(team)
    if team == self._bossTeam then
        self._bossInBattle = false
        self._control:getBaoxiang(self._battleInfo.bossHpCount)
        if SRData then
            SRData[353] = 1
        end
    elseif team.camp == 2 then
        self._xiaoshuijinglongCount = self._xiaoshuijinglongCount - 1
        if self._xiaoshuijinglongCount == 0 then
            self._bossTeam.canDestroy = true
            self._boss.bossDef = 100000000
            self._shuijingHP = MAX_SHIELD
        end
    end
end

local getRowIndex = BC.getRowIndex

function BattleLogic:onSoldierDieEx(soldier)

end

-- 水晶龙5个阶段

-- 第一阶段 正常 普攻 水晶刺
-- 第二阶段 血量首次到达66%/33% 变水晶 召小龙 水晶破碎回第一阶段
-- 第三阶段 血量低于33% 普攻增强
function BattleLogic:onHPChangeEx(soldier, change)
    if soldier == self._boss then
        if not BATTLE_PROC then
            local index = GRandom(#self.__HP_1)
            self.__HP_1[index] = self.__HP_1[index] - change
            index = GRandom(#self.__HP_2)
            self.__HP_2[index] = self.__HP_2[index] + 7 * change
        end
        if self._boss.HP < self._bossMinHP then
            self._bossMinHP = self._boss.HP
        end
        if not self._bossInBattle then
            -- 第一次受到攻击, 进入战斗
            self._bossInBattle = true
            self._bossSkill[3].tick = self.battleTime + 1
            print("进入第一阶段")
        else
            -- 阶段转换
            if self._bossStep == 1 then
                local hpPro = self._boss.HP / self._boss.maxHP * 100
                if self._step2Times == 0 then
                    if hpPro < 66 then
                        print("进入第二阶段, 66")
                        self._bossSkill[4].tick = -1
                        self._bossStep = 2
                        self._step2Times = 1
                    end
                elseif self._step2Times == 1 then
                    if hpPro < 33 then
                        print("进入第二阶段, 33")
                        self._bossSkill[4].tick = -1
                        self._bossStep = 2
                        self._step2Times = 2
                    end
                end
            elseif self._bossStep == 2 then
                if self._shuijingHP and change <= 0 then
                    self._shuijingHP = self._shuijingHP - 1
                    self.subDestValue2 = self._shuijingHP / MAX_SHIELD * 100
                    if self._shuijingHP == 0 then
                        self._shuijingHP = nil
                        self:bossSkillAction6(function ()
                            print("回到第一阶段")
                            self._bossStep = 1
                            if self._step2Times == 2 then
                                self._boss.minHPEx = 0
                            end
                        end)
                    end
                end
            end
        end
    end
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
    abs = nil--math.abs
    BattleLogic = nil--require("game.view.battle.logic.BattleLogic")
    BattleScene = nil--require("game.view.battle.display.BattleScene")
    BattleTeam = nil--require("game.view.battle.object.BattleTeam")
    BC = nil--BC
    BUFFID_HOT = nil--4971
    cc = nil--_G.cc
    ceil = nil--math.ceil
    ceil = nil--math.ceil
    COUNT_TIME = nil--180
    countDamage_attack = nil--BC.countDamage_attack
    delayCall = nil--BC.DelayCall.dc
    ECamp = nil--BC.ECamp
    EDirect = nil--BC.EDirect
    EEffFlyType = nil--BC.EEffFlyType
    EMotion = nil--BC.EMotion
    EMotionBORN = nil--EMotion.BORN
    EState = nil--BC.EState
    ETeamState = nil--BC.ETeamState
    ETeamStateDIE = nil--BC.ETeamState.DIE
    floor = nil--math.floor
    getRowIndex = nil--BC.getRowIndex
    hpOneValue = nil--20
    hpPics = nil
    hpColors = nil--{
    initSoldierBuff = nil--BC.initSoldierBuff 
    INTO_DIS = nil--250
    INTO_SPEED = nil--120
    LEVEL = nil--BC.PLAYER_LEVEL[1]
    math = nil--math
    mcMgr = nil--mcMgr
    motion_atk = nil--3
    motion_jiao = nil--15
    motion_shuijing = nil--6
    motion_shuijingci = nil--18
    motion_shuijingpo = nil--7
    motionFrame = nil
    next = nil--next
    NPCID_XIAOJINGLONG = nil--801041
    objLayer = nil
    logic = nil
    os = nil--_G.os
    pairs = nil--pairs
    pc = nil--pc
    random = nil--BC.ran
    randomSelect = nil--BC.randomSelect
    rule = nil--{}
    skillName = nil
    tab = nil--tab
    table = nil--table
    tonumber = nil--tonumber
    tostring = nil--tostring
    SRData = nil
    BattleTeam_addDamage = nil
    BattleTeam_addHurt = nil
    BattleTeam = nil
    MAX_SHIELD = nil
end 
return rule