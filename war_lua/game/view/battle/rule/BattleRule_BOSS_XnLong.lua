--[[
    Filename:    BattleRule_BOSS_XnLong.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-5-25 14:46:53
    Description: File description
--]]

-- 龙之国BOSS 仙女龙
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
local INTO_DIS = 300
-- 游戏时间
local COUNT_TIME = 120

local LEVEL = BC.PLAYER_LEVEL[1]
local NPCID_SHIZHU = 8010500
local BUFFID_YUN = 4991
local BUFFID_BING = 4992
local BUFFID_HUO = 4993
local BUFFID_LINGHUNLIANJIE = 4996

local motionFrame = {37, 0, 37, 44, 57, 56, 55}

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
    self._proBar3:setVisible(b > 0)
    self._proBar4:setVisible(b > 0)
    self._countLabel:setVisible(b > 0)
    self._countLabel:setString("x".. b + 1)
    if b + 1 < self._hpCount then
        self._hpCount = b + 1
        self:getBaoxiang(self._battleInfo.bossHpCount - self._hpCount)
    else
        self._baoxiangLabel:setString((self._battleInfo.bossHpCount - (b + 1)) + 1)
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
    local dx3 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 - 130 - 50
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
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 40)
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
        local dx3 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 - 130 - 50
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
            v1_2 = v1_2 + (7554 - logic.__HP_2[i])
        end
        if v2 * 3 + 4 ~= logic.__maxHP_1 or v2 * 5 + 6 ~= logic.__maxHP_2 then
            if OS_IS_WINDOWS then
                 ViewManager:getInstance():onLuaError(serialize({222222, v2, logic.__maxHP_1, logic.__maxHP_2}))
            end
            v2 = 9999999999
        end
        if v1 ~= v1_1 or v1 * 9 ~= v1_2 or v1_1 * 9 ~= v1_2 then
            if OS_IS_WINDOWS then
                 ViewManager:getInstance():onLuaError(serialize({111111, v1, v1_1, v1_2}))
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
    self._heros[1]:setPos(15 * 40, 15 * 40)
    self.battleState = EState.READY
end

local EMotionBORN = EMotion.BORN

function BattleLogic:initLogicEx(procBattle)
    logic = BC.logic
    objLayer = BC.objLayer

    NPCID_SHIZHU = NPCID_SHIZHU + self._battleInfo.diff
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

    self._heros[1]:setPos(15 * 40 - INTO_DIS, 15 * 40)

    self._heros[1]:moveTo(15 * 40 - INTO_DIS, 15 * 40, INTO_SPEED)

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
    
    if not BATTLE_PROC then
        self.__HP_1 = {}
        self.__HP_2 = {}
        self.__HP_1_count = GRandom(10) + GRandom(12)
        self.__HP_2_count = GRandom(10) + GRandom(12)
        for i = 1, self.__HP_1_count do
            self.__HP_1[i] = 0
        end
        for i = 1, self.__HP_2_count do
            self.__HP_2[i] = 7554
        end
        self.__maxHP_1 = boss.maxHP * 3 + 4
        self.__maxHP_2 = boss.maxHP * 5 + 6
    end

    -- BOSS是否在战斗中
    self._bossStep = 1
    self._bossCasting = false

    -- 玩家施法50%几率失败
    BC.H_failedPro[1] = BC.H_failedPro[1] + 50

    -- 初始化石柱
    local xx = 1120
    local yy = 380
    local posx1 = {xx - 73, xx - 120, xx - 127, xx - 80}
    local posy1 = {yy + 152, yy + 65, yy - 75, yy - 170}
    self._pylons = {}
    for i = 1, 4 do
        self._pylons[i] = self:addPylon(NPCID_SHIZHU, posx1[i], posy1[i])
    end
    self._pylons[1].animId = {"shizhu103_shibi", "shizhu203_shibi", "shizhu303_shibi", "shizhu405_shibi"}
    self._pylons[2].animId = {"shizhu101_shibi", "shizhu201_shibi", "shizhu301_shibi", "shizhu404_shibi"}
    self._pylons[3].animId = {"shizhu103_shibi", "shizhu203_shibi", "shizhu303_shibi", "shizhu403_shibi"}
    self._pylons[4].animId = {"shizhu102_shibi", "shizhu202_shibi", "shizhu302_shibi", "shizhu402_shibi"}
    self._pylonsAnim = {}
    for i = 1, 4 do
        self:zhuziAnim(i, 1)
    end
    self._zhuziCount = 4

    self._bossTeam.canDestroy = false

    -- 仙女龙 3个阶段
    -- 26 26 36

    local tick = 0
    self._bossSkill = {}
    -- 雷击
    self._bossSkill[1] = {tick = tick, motion = 3, cd = 2.5, step = {true, true, true}}
    -- 连锁闪电 如果没有近战，一直放
    self._bossSkill[2] = {tick = tick, motion = 3, cd = 9999999, step = {false, false, false}}
    -- 冰袭
    self._bossSkill[3] = {tick = tick, motion = 6, cd = 10, step = {false, true, true}}
    -- 烈火神盾
    self._bossSkill[4] = {tick = tick, motion = 5, cd = 9999999, step = {false, true, false}}
    -- 连锁闪电 切换阶段
    self._bossSkill[5] = {tick = tick, motion = 3, cd = 9999999, step = {false, true, false}}
    -- 连锁闪电 切换阶段
    self._bossSkill[6] = {tick = tick, motion = 3, cd = 9999999, step = {false, false, true}}

    self._skillSortTab = {4, 6, 5, 2, 3, 1}

    -- 石壁破碎之前 不能释放技能
    self._control:onLockSkill()

    if SRData then
        SRData[104] = self._battleInfo.bossId
        SRData[109] = boss.atk
        SRData[110] = boss.atk * 2
        SRData[111] = boss.maxHP
        SRData[112] = boss.maxHP

        SRData[352] = 1
    end
end

-- 添加石柱子
function BattleLogic:addPylon(npcid, x, y)
    local team = BattleTeam.new(ECamp.RIGHT)   
    local info = {npcid = npcid, level = LEVEL, summon = false}
    BC.initTeamAttr_Npc(team, self._heros[2], info, x, y, nil, true)    
    self:_raceCountAdd(2, team.race1, team.race2)
    self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
    -- team.noHUD = true
    self:addTeam(team)     
    -- 原始出场方阵标记
    -- team.original = true
    team.cantSort = true
    team.isSiege = true
    team.radius = 100
    team.showHP = false
    team.soldier[1].radius = 100
    team.soldier[1]:changeMotion(1)
    team.soldier[1]:setDirect(1)
    local buff = initSoldierBuff(BUFFID_LINGHUNLIANJIE, 1, team.soldier[1].caster, team.soldier[1])
    team.soldier[1]:addBuff(buff)
    team.immuneBuff = {true, true, true, true, true, true, true, true, true, true, true, true, true, true}
    return team
end

function BattleLogic:zhuziAnim(index, anim)
    if BC.jump then return end
    local pylons = self._pylons[index]
    if self._pylonsAnim[index] then
        objLayer:stopEffect(self._pylonsAnim[index])
    end
    self._pylonsAnim[index] = objLayer:playEffect_totem2(pylons.animId[anim], pylons.soldier[1], 3, true, true, 0, 1.2)
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

function BattleLogic:countPylonHP()
    local HP = 0
    local maxHP = 0
    for i = 1, #self._pylons do
        HP = HP + self._pylons[i].curHP
        maxHP = maxHP + self._pylons[i].maxHP
    end
    return HP, maxHP
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

end

function BattleLogic:bossInto2()

end

function BattleLogic:bossInto3()
    self._boss:changeMotion(7)
    ScheduleMgr:delayCall(26 * 50, self, function ()
        if self._jsJumpBeginAnim then return end
        audioMgr:playSound("boss_sjl_houjiao")
        self:shake(5, 5)
    end)
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
    return motionFrame[7] * 0.05
end

local skillName = {lang("XIANNVLONGSKILL_1"), lang("XIANNVLONGSKILL_2"), lang("XIANNVLONGSKILL_3"), lang("XIANNVLONGSKILL_4"), lang("XIANNVLONGSKILL_2"), lang("XIANNVLONGSKILL_2")}
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

-- 石壁破碎
function BattleLogic:bossSkillAction0()
    self._control:onUnlockSkill()
    local team, soldier
    for i = 1, #self._teams[1] do
        if self._teams[1][i].state ~= ETeamStateDIE and self._teams[1][i].isMelee then
            team = self._teams[1][i]
            self:bossDamage(team.soldier, 0, 1)      
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                if not soldier.die then
                    local buff = initSoldierBuff(BUFFID_YUN, LEVEL, self._boss.caster, soldier)
                    soldier:addBuff(buff)
                end
            end
        end
    end
end

-- 雷击
-- 全打
function BattleLogic:bossSkillAction1()
    local meleeCount = 0
    for i = 1, #self._teams[1] do
        if self._teams[1][i].state ~= ETeamStateDIE and self._teams[1][i].isMelee then
            meleeCount = meleeCount + 1
        end
    end
    -- 近战都死了, 一直用连锁闪电
    if meleeCount == 0 then
        self:bossSkillAction2()
        self._boss:changeMotion(3)
        return
    end

    local number = self._bossStep

    local meleeCount = 0
    local meleeList = {}
    for i = 1, #self._teams[1] do
        if self._teams[1][i].state ~= ETeamStateDIE then
            meleeCount = meleeCount + 1
            meleeList[#meleeList + 1] = self._teams[1][i]
        end
    end
    objLayer:showSkillName(self._boss.ID, true, self._boss.x, self._boss.y + 200, 2, skillName[1])
    delayCall(24 * 0.05, self, function ()
        audioMgr:playSound("boss_xnl_lei")
        self:shake(2, 2)

        local res = randomSelect(#meleeList, number)
        local team
        for i = 1, #res do
            team = meleeList[res[i]]
            objLayer:playEffect_skill1("leiji_xiannvlongtexiao", team.x, team.y, true, true)
            for k = 1, #team.aliveSoldier do
                objLayer:playEffect_hit1("liansuoshandian2_liansuoshandian", true, true, team.aliveSoldier[k], 2)
            end
            self:bossDamage(team.soldier, 0, 1, 4)
        end   
    end)
end

-- 连锁闪电
-- 切换阶段的时候释放, 没有近战的时候释放
function BattleLogic:bossSkillAction5()
    self:bossSkillAction2()
end
function BattleLogic:bossSkillAction6()
    self:bossSkillAction2()
end
function BattleLogic:bossSkillAction2()
    objLayer:showSkillName(self._boss.ID, true, self._boss.x, self._boss.y + 200, 2, skillName[2])
    delayCall(22 * 0.05, self, function ()
        audioMgr:playSound("boss_sjl_baolieshuijing")
        local list = self.targetCache[1][3]

        local rlist = {}
        for i = 1, #list do
            if not list[i].die then
                rlist[#rlist + 1] = list[i]
            end
        end
        
        if #rlist > 0 then
            BC.randomTable(rlist)
            objLayer:playEffect_hit2_pt("liansuoshandian3_liansuoshandian", true, self._boss.x - 100, self._boss.y + 100, rlist[1])
            objLayer:playEffect_skill1("liansuoshandian2_liansuoshandian", rlist[1].x, rlist[1].y, true, true)
            for t = 1, #rlist do
                delayCall(0.05 * t, self, function()
                    self:bossDamage({rlist[t]}, 0, 1, 4)
                    if not BC.jump and t < #rlist then
                        objLayer:playEffect_skill1("liansuoshandian2_liansuoshandian", rlist[t + 1].x, rlist[t + 1].y, true, true)
                        objLayer:playEffect_hit2("liansuoshandian3_liansuoshandian", true, rlist[t], rlist[t + 1])
                    end
                end)
            end
        end
    end)
end

-- 冰袭
-- 全打
function BattleLogic:bossSkillAction3()
    local meleeCount = 0
    for i = 1, #self._teams[1] do
        if self._teams[1][i].state ~= ETeamStateDIE and self._teams[1][i].isMelee then
            meleeCount = meleeCount + 1
        end
    end
    -- 近战都死了, 一直用连锁闪电
    if meleeCount == 0 then
        self:bossSkillAction2()
        self._boss:changeMotion(3)
        return
    end

    objLayer:showSkillName(self._boss.ID, true, self._boss.x, self._boss.y + 200, 2, skillName[3])
    delayCall(30 * 0.05, self, function ()
        audioMgr:playSound("boss_xnl_bing")
        local meleeTeams = {}
        for i = 1, #self._teams[1] do
            if self._teams[1][i].state ~= ETeamStateDIE then
                meleeTeams[#meleeTeams + 1] = self._teams[1][i]
            end
        end
        if #meleeTeams > 0 then
            local tarteam = meleeTeams[random(#meleeTeams)]
            local x, y = tarteam.x, tarteam.y
            local count = 1 + random(9)
            for i = 1, count do
                delayCall((i - 1) * 0.2, self, function ()
                    if not BC.jump then
                        self:shake(2, 2)
                        objLayer:playEffect_skill1("bingxi_xiannvlongtexiao", x, y, true, true, 1, 2)
                    end
                    local list = self:getRangeTarget1(self.targetCache[2][4], {}, x, y, 60, 999, false)
                    self:bossDamage(list, 0, 0.5, 3)
                    local soldier
                    for k = 1, #list do
                        soldier = list[k]
                        if not soldier.die then
                            local buff = initSoldierBuff(BUFFID_BING, LEVEL, self._boss.caster, soldier)
                            soldier:addBuff(buff)
                        end
                    end
                end)
            end
        else
            -- 没打着人
            objLayer:playEffect_skill1("bingxi_xiannvlongtexiao", 1050, 320, true, true)
        end
    end)
end

-- 烈火神盾
function BattleLogic:bossSkillAction4()
    if not BC.jump then
        self._control:heroSkillAnim(2, skillName[4], nil, "half_Xiannvlong", 1)
    end
    delayCall(25 * 0.05, self, function ()
        for i = 1, 4 do
            self:zhuziAnim(i, 4)
        end
        delayCall(25 * 0.05, self, function ()
            if not BC.jump then
                self._eff1 = objLayer:playEffect_totem2("shidun1_shibi", self._boss, 2, true, true, 1, 1.6)
                self._eff2 = objLayer:playEffect_totem2("shidun2_shibi", self._boss, 2, false, true, 1, 1.6)
            end
        end)
    end)
    local boss = self._boss
    boss.baseAttr[BC.ATTR_DHP] = floor(boss.atk * 0.2)
    boss.baseSum = nil
    boss:resetAttr()
end

-- 召唤生物
function BattleLogic:summonTeamEx(team)
    team.goBack = false
    if self._bossStep == 3 then
        if team.isMelee then
            for k = 1, #team.aliveSoldier do
                local buff = initSoldierBuff(BUFFID_HUO, LEVEL, self._boss.caster, team.aliveSoldier[k])
                team.aliveSoldier[k]:addBuff(buff)
            end
        end
    end
end

function BattleLogic:onRevive(soldier)
    if self._bossStep == 3 then
        if soldier.team.isMelee then
            local buff = initSoldierBuff(BUFFID_HUO, LEVEL, self._boss.caster, soldier)
            soldier:addBuff(buff)
        end
    end
end

function BattleLogic:onTeamDieEx(team)
    if team == self._bossTeam then
        self._bossInBattle = false
        self._control:getBaoxiang(self._battleInfo.bossHpCount)
        if not BC.jump and self._eff1 then
            objLayer:stopEffect(self._eff1)
            objLayer:stopEffect(self._eff2)
        end
        if SRData then
            SRData[353] = 1
        end
    elseif team.camp == 2 then
        self._zhuziCount = self._zhuziCount - 1
        if self._zhuziCount == 0 then
            for i = 1, 4 do
                self:zhuziAnim(i, 3)
            end
            self._bossTeam.canDestroy = true
            self._bossStep = 2
            self:bossSkillAction0()
        end
    end
end

local getRowIndex = BC.getRowIndex

function BattleLogic:onSoldierDieEx(soldier)

end

function BattleLogic:onHPChangeEx(soldier, change)
    if not self._bossInBattle and soldier.team.camp == 2 then
        self._bossInBattle = true
        self._bossStep = 1
        print("进入第一阶段")
    end
    if soldier == self._boss then
        if not BATTLE_PROC then
            local index = GRandom(#self.__HP_1)
            self.__HP_1[index] = self.__HP_1[index] - change
            index = GRandom(#self.__HP_2)
            self.__HP_2[index] = self.__HP_2[index] + 9 * change
        end
        if self._bossInBattle then
            local hpPro = self._boss.HP / self._boss.maxHP * 100
            -- 阶段转换
            if self._bossStep == 2 then
                if hpPro < 50 then
                    print("进入第三阶段")
                    self._bossStep = 3
                    self._boss.minHPEx = 0
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
    BUFFID_BING = nil--4992
    BUFFID_HUO = nil--4993
    BUFFID_LINGHUNLIANJIE = nil--4996
    BUFFID_YUN = nil--4991
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
    INTO_DIS = nil--300
    INTO_SPEED = nil--120
    LEVEL = nil--BC.PLAYER_LEVEL[1]
    math = nil--math
    mcMgr = nil--mcMgr
    motionFrame = nil--{37, 0, 37, 44, 57, 56, 55}
    next = nil--next
    NPCID_SHIZHU = nil--801050
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
end 
return rule