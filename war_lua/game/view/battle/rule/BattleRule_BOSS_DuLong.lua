--[[
    Filename:    BattleRule_BOSS_DuLong.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-11-02 14:46:53
    Description: File description
--]]

-- 龙之国BOSS 毒龙
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
local BUFFID_YUN = 4984
local BUFFID_DUXI = 4983
local BUFFID_DUTAN = 4981
local BUFFID_DUYEPENSHE = 4982
local BUFFID_DU = 4987

local motionFrame = {59, 0, 51, 39, 50, 66, 63, 35}

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

    self._boss:setPos(self._boss.__x, self._boss.__y)
    self._boss:changeMotion(1)
    self._boss:setShadowVisible(true)

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

    self._heros[1]:setPos(15 * 40 - INTO_DIS, 15 * 40)

    self._heros[1]:moveTo(15 * 40, 15 * 40, INTO_SPEED)

	local bossTeam = BattleTeam.new(ECamp.RIGHT, 0)
    self._bossTeam = bossTeam
    bossTeam.showHP = false
    bossTeam.showHead = false

    local info = {npcid = self._battleInfo.bossId, level = LEVEL, summon = false}
    BC.initTeamAttr_Npc(bossTeam, self._heros[2], info, 1200, 320)    
    self:_raceCountAdd(2, bossTeam.race1, bossTeam.race2)
    self.classCount[2][bossTeam.classLabel] = self.classCount[2][bossTeam.classLabel] + 1
    bossTeam.noHUD = true
    self:addTeam(bossTeam)   
    local boss = bossTeam.soldier[1]  
    self._boss = boss
    boss.boss = true
    if not procBattle then
        boss.__x = boss.x
        boss.__y = boss.y
        boss:setPos(boss.x + 10000, boss.y)
    end
    -- 原始出场方阵标记
    bossTeam.boss = true
    bossTeam.original = true
    bossTeam.cantSort = true
    bossTeam.goBack = false
    bossTeam.turnFire = false

    bossTeam.isSiege = true
    bossTeam.radius = 180
    boss.radius = 180

    -- 水系伤害减免50%
    boss.baseAttr[BC.ATTR_RWater] = 50

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

    -- 毒龙3个阶段
    -- 1. 咬, 爪击 
    -- 2. 低于75%血  咬, 爪击 毒谭
    -- 3. 低于30%血  咬, 爪击ex 毒液喷射

    -- 没有近战放毒息

    local tick = 0
    self._bossSkill = {}
    -- 咬
    self._bossSkill[1] = {tick = tick, motion = 3, cd = 0, step = {true, true, true}}
    -- 爪击
    self._bossSkill[2] = {tick = tick, motion = 5, cd = 6, step = {true, true, true}}
    -- 毒息
    self._bossSkill[3] = {tick = tick, motion = 6, cd = 99999, step = {false, false, false}}
    -- 毒谭
    self._bossSkill[4] = {tick = tick, motion = 7, cd = 99999, step = {false, true, false}}
    -- 毒液喷射
    self._bossSkill[5] = {tick = tick, motion = 7, cd = 99999, step = {false, false, true}}

    self._skillSortTab = {4, 5, 3, 2, 1}

    if SRData then
        SRData[104] = self._battleInfo.bossId
        SRData[109] = boss.atk
        SRData[110] = boss.atk * 1.5
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
    self:bossDiaoTu(3)
end

local EMotionBORN = EMotion.BORN

function BattleLogic:bossInto3()
    self:bossDiaoTu(3)
    self._boss:setPos(self._boss.x - 10000, self._boss.y)
    self._boss:setShadowVisible(false)
    local frame = motionFrame[8]
    self._boss:changeMotion(EMotionBORN)
    ScheduleMgr:delayCall(19 * 50, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(2, 5)
    end)
    ScheduleMgr:delayCall(frame * 50 * 1.33, self, function ()
        if self._jsJumpBeginAnim then return end
        self._boss:changeMotion(1)
        self._boss:setShadowVisible(true)
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

local skillName = {"", "", lang("DULONGSKILL_3"), lang("DULONGSKILL_4"), lang("DULONGSKILL_5")}
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

-- 头咬 打近战1个兵团 100%
function BattleLogic:bossSkillAction1()
    local meleeCount = 0
    for i = 1, #self._teams[1] do
        if self._teams[1][i].state ~= ETeamStateDIE and self._teams[1][i].isMelee then
            meleeCount = meleeCount + 1
        end
    end
    -- 近战都死了, 一直用毒息
    if meleeCount == 0 then
        self:bossSkillAction3()
        return
    end
    delayCall(24 * 0.05, self, function ()
        objLayer:playEffect_skill1("eff3_dulongtexiao", 880 + GRandom(200), 280 + GRandom(70), true, true, 1, 2)
        self:shake(2, 2)
        self:bossDiaoTu(2)

        local targetList = {}
        local team 
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            if not team.state ~= ETeamStateDIE and team.isMelee then
                targetList[#targetList + 1] = team
            end
        end
        local res = randomSelect(#targetList, 1)
        for i = 1, #res do
            self:bossDamage(targetList[res[i]].soldier, 0.04, 1)
        end
    end)  
end

-- 爪击 打近战3个兵团 75%
function BattleLogic:bossSkillAction2()
    local meleeCount = 0
    for i = 1, #self._teams[1] do
        if self._teams[1][i].state ~= ETeamStateDIE and self._teams[1][i].isMelee then
            meleeCount = meleeCount + 1
        end
    end
    -- 近战都死了, 一直用毒息
    if meleeCount == 0 then
        self:bossSkillAction3()
        return
    end
    -- 爪击近战近距离兵团，对5个单位造成基础攻击力的50%
    delayCall(30 * 0.05, self, function ()
        objLayer:playEffect_skill1("eff2_dulongtexiao", self._boss.x - 400, self._boss.y + 120, true, true, 1, 2)
        self:shake(2, 2)
        self:bossDiaoTu(2)

        local targetList = {}
        local team 
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            if not team.state ~= ETeamStateDIE and team.isMelee then
                targetList[#targetList + 1] = team
            end
        end
        local res = randomSelect(#targetList, 3)
        for i = 1, #res do
            team = targetList[res[i]]
            if not team.isFly then
                for k = 1, #team.aliveSoldier do
                    local buff = initSoldierBuff(BUFFID_DU, LEVEL, self._boss.caster, team.aliveSoldier[k])
                    team.aliveSoldier[k]:addBuff(buff)
                end
            end
            self:bossDamage(team.soldier, 0.04, 0.75)
        end
    end)
end

-- 毒息
function BattleLogic:bossSkillAction3()
    self._boss:changeMotion(6)
    -- 毒息吹熄全场敌方单位，造成150%攻击水系法术伤害
    objLayer:showSkillName(self._boss.ID, true, self._boss.x, self._boss.y + 200, 2, skillName[3])
	delayCall(39 * 0.05, self, function ()
        audioMgr:playSound("boss_dl_du")
		objLayer:playEffect_skill1("eff4_dulongtexiao", 1190, 340, true, true, -1, 2)
		self:shake(4, 3)
		self:bossDiaoTu(4)

	    for i = 1, #self._teams[1] do
	        delayCall((i - 1) * 0.025, self, function ()
	        	local team = self._teams[1][i]
	        	if team.state ~= ETeamStateDIE then
                    if self._bossStep == 3 then
                        -- 三阶段毒息 附加debuff
                        for k = 1, #team.aliveSoldier do
                            local buff = initSoldierBuff(BUFFID_DUXI, LEVEL, self._boss.caster, team.aliveSoldier[k])
                            team.aliveSoldier[k]:addBuff(buff)
                        end
                    end
                    if not team.isFly then
                        for k = 1, #team.aliveSoldier do
                            local buff = initSoldierBuff(BUFFID_DU, LEVEL, self._boss.caster, team.aliveSoldier[k])
                            team.aliveSoldier[k]:addBuff(buff)
                        end
                    end
			        self:bossDamage(team.soldier, 0, 1.5, 3)
			    end
		    end)
	    end
	end)
end
-- 毒谭
function BattleLogic:bossSkillAction4()
    if not BC.jump then
        self._control:heroSkillAnim(2, skillName[4], nil, "half_Dulong", 1)
    end
    delayCall(27 * 0.05, self, function ()
        audioMgr:playSound("boss_dl_houjiao")
        self:shake(5, 3)
        for i = 1, #self._teams[1] do
            local team = self._teams[1][i]
            if team.state ~= ETeamStateDIE and not team.isFly then  
                for k = 1, #team.aliveSoldier do
                    local buff = initSoldierBuff(BUFFID_DUTAN, LEVEL, self._boss.caster, team.aliveSoldier[k])
                    team.aliveSoldier[k]:addBuff(buff)
                end
            end
        end
        if not BC.jump then
            objLayer:playEffect_totem("duye2_dulongtexiao", 700, 400, false, false, 1):setScale(1.2)
            objLayer:playEffect_totem("duye2_dulongtexiao", 1000, 400, false, false, 1):setScale(-1.2, 1.2)
            objLayer:playEffect_totem("duye2_dulongtexiao", 1300, 400, false, false, 1):setScale(1.2)
        end
    end)
end
-- 毒液喷射
function BattleLogic:bossSkillAction5()
    if not BC.jump then
        self._control:heroSkillAnim(2, skillName[5], nil, "half_Dulong", 1)
    end
    delayCall(22 * 0.05, self, function ()
        audioMgr:playSound("boss_dl_houjiao")
        self:shake(5, 3)
        for i = 1, #self._teams[1] do
            local team = self._teams[1][i]
            if team.state ~= ETeamStateDIE then  
                for k = 1, #team.aliveSoldier do
                    local buff = initSoldierBuff(BUFFID_DUYEPENSHE, LEVEL, self._boss.caster, team.aliveSoldier[k])
                    team.aliveSoldier[k]:addBuff(buff)
                end
            end
        end
        if not BC.jump then
            objLayer:playEffect_totem("duqi2_dulongtexiao", 700, 330, true, true, 1):setScale(1.2)
            objLayer:playEffect_totem("duqi2_dulongtexiao", 1000, 330, true, true, 1):setScale(-1.2, 1.2)
            objLayer:playEffect_totem("duqi2_dulongtexiao", 1300, 330, true, true, 1):setScale(1.2)
        end
    end)
end

-- 召唤生物 补毒
function BattleLogic:summonTeamEx(team)
    team.goBack = false
    if self._bossStep >= 2 then
        if not team.isFly then
            for k = 1, #team.aliveSoldier do
                local buff = initSoldierBuff(BUFFID_DUTAN, LEVEL, self._boss.caster, team.aliveSoldier[k])
                team.aliveSoldier[k]:addBuff(buff)
            end
        end
    end
    if self._bossStep == 3 then
        for k = 1, #team.aliveSoldier do
            local buff = initSoldierBuff(BUFFID_DUYEPENSHE, LEVEL, self._boss.caster, team.aliveSoldier[k])
            team.aliveSoldier[k]:addBuff(buff)
        end
    end
end

-- 复活 补毒
function BattleLogic:onRevive(soldier)
    if self._bossStep >= 2 then
        if not soldier.team.isFly then
            local buff = initSoldierBuff(BUFFID_DUTAN, LEVEL, self._boss.caster, soldier)
            soldier:addBuff(buff)
        end     
    end
    if self._bossStep == 3 then
        local buff = initSoldierBuff(BUFFID_DUYEPENSHE, LEVEL, self._boss.caster, soldier)
        soldier:addBuff(buff)
    end
end

function BattleLogic:bossDiaoTu(number)
    if BC.jump then return end
	local x, y
	for i = 1, number do
		ScheduleMgr:delayCall((10 + GRandom(25)) * 0.05 * 1000, self, function ()
			x = 700 + GRandom(1000)
			y = 100 + GRandom(440)
			if y < 260 then
				objLayer:playEffect_skill1("eff1_dulongtexiao", x, y, true, true, 1, 1)
			else
				objLayer:playEffect_skill1("eff1_dulongtexiao", x, y, false, true, 1, 1)
			end
		end)
	end
end

function BattleLogic:onTeamDieEx(team)
	if team == self._bossTeam then
		self._bossInBattle = false
        self._control:getBaoxiang(self._battleInfo.bossHpCount)
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
        if not BATTLE_PROC then
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
			local hpPro = self._boss.HP / self._boss.maxHP * 100
			-- 阶段转换
			if self._bossStep == 1 then
				if hpPro < 75 then
					print("进入第二阶段")
					self._bossStep = 2
				end
			elseif self._bossStep == 2 then
				if hpPro < 30 then
					print("进入第三阶段")
					self._bossStep = 3
                    self._bossSkill[3].cd = 8
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
    BattleLogic = nil 
    BattleScene = nil 
    BattleTeam = nil 
    BC = nil -- BC
    cc = nil -- _G.cc
    ceil = nil -- math.ceil
    COUNT_TIME = nil -- 180
    ECamp = nil -- BC.ECamp
    EDirect = nil -- BC.EDirect
    EEffFlyType = nil -- BC.EEffFlyType
    EMotion = nil -- BC.EMotion
    EMotionBORN = nil -- EMotion.BORN
    EState = nil -- BC.EState
    ETeamState = nil -- BC.ETeamState
    ETeamStateDIE = nil -- ETeamState.DIE
    floor = nil -- math.floor
    getRowIndex = nil -- BC.getRowIndex
    hpOneValue = nil -- 20
    hpPics = nil
    hpColors = nil -- {
    initSoldierBuff = nil -- BC.initSoldierBuff 
    INTO_DIS = nil -- 250
    INTO_SPEED = nil -- 120
    LEVEL = nil -- BC.PLAYER_LEVEL
    math = nil -- math
    mcMgr = nil -- mcMgr
    motionFrame = nil 
    next = nil -- next
    objLayer = nil
    logic = nil
    os = nil -- _G.os
    pairs = nil -- pairs
    pc = nil -- pc
    random = nil -- BC.ran
    rule = nil -- {}
    SKILL_ID_3 = nil -- 59001 
    SKILL_ID_4 = nil -- 59002
    SKILL_ID_5 = nil -- 59003
    skillName = nil -- 
    tab = nil -- tab
    table = nil -- table
    tonumber = nil -- tonumber
    tostring = nil -- tostring
    abs = nil
    delayCall = nil
    BUFFID_YUN = nil
    BUFFID_DUXI = nil
    BUFFID_DUTAN = nil
    BUFFID_DUYEPENSHE = nil
    SRData = nil
    BattleTeam_addDamage = nil
    BattleTeam_addHurt = nil
    BattleTeam = nil
    BUFFID_DU = nil
end 
return rule