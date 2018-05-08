--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-09-01 21:00:22
--
-- 云中城战斗
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

-- 战斗位置 一共80个
-- 1  5  9 ....  77
-- 2             78
-- 3             79
-- 4             80
local BATTLE_POS = {}

local GLOBAL_SP_SCALE = 0.9

local Y_OFFSET = 30
local LEVEL = BC.PLAYER_LEVEL[1]

local BattleScene = require("game.view.battle.display.BattleScene")
local COUNT_TIME = 180

function BattleScene:initBattleUIEx()
    -- 战斗时间走配置
    COUNT_TIME = self._battleInfo.cctD["time"]
    self.CountTime = COUNT_TIME

    self._proBar1 = self._BattleView:getUI("uiLayer.topLayer.pro1")
    self._proBar2 = self._BattleView:getUI("uiLayer.topLayer.pro2")
    self._proBar1:loadTexture("hpBar1_battle.png", 1)
    self._proBar2:loadTexture("hpBar2_battle.png", 1)
    
    self._BattleView:getUI("uiLayer.topLayer.timeBg"):setVisible(false)
    self._BattleView:getUI("uiLayer.topLayer.timeLabel"):setPositionY(33)
    
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

end

-- 显示HP
function BattleScene:countHPEx()
    local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
    local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
    self._destValue1 = ((hp1 + shp1) / (maxhp1 + maxshp1)) * 100
    self._destValue2 = ((hp2 + shp2) / (maxhp2 + maxshp2)) * 100
    self._proBar1:setPercent(self._destValue1)
    self._proBar2:setPercent(self._destValue2)
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
            self._hpShadow1:setPercent(self._shadowValue1)
            self._hpShadow2:setPercent(self._shadowValue2)
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
        self._touchMask:addClickEventListener(function () end)
        self._frontLayer:getView():stopAllActions()
        self._frontLayer:getView():setOpacity(0)
        local dx2, dy2 = logic:getLeftTeamCenterPoint(BC.reverse)
        dy2 = dy2 + Y_OFFSET
        self:screenToPos(dx2, dy2, false)
        self._camera:setPosition(dx2, dy2)
        self._follow = true 
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
local modf = math.modf
local function getBattlePosByIndex(index)
    local a, b = modf(index * 0.25)
    local formationX = b * 4
    local formationY = a + 1
    if formationX == 0 then
        formationX = 4
        formationY = formationY - 1
    end 
    return {80 + (formationY - 1) * 120, 520 - 96 * (formationX - 1)}
end

local initSoldierBuff = BC.initSoldierBuff
local ATTR_MSpeed = BC.ATTR_MSpeed
function BattleLogic:initLogicEx()
    logic = BC.logic
    objLayer = BC.objLayer

    -- 初始化坐标
    local x, y
    for i = 1, 80 do
        BATTLE_POS[i] = getBattlePosByIndex(i)
    end

    local cctD = self._battleInfo.cctD
    local cctD2 = self._battleInfo.cctD2

    -- 我方受到天气影响
    if cctD["weatherEffect"] then
        -- self._weatherBuffId = cctD["weatherEffect"][1]
        -- self._weatherBuffLv = cctD["weatherEffect"][2]
        -- local buffId, lv = self._weatherBuffId, self._weatherBuffLv
        -- local team, soldier, buff
        -- local teams = self._teams[1]
        -- for i = 1, #teams do
        --     team = teams[i]
        --     for k = 1, #team.soldier do
        --         soldier = team.soldier[k]
        --         buff = initSoldierBuff(buffId, lv, soldier.caster, soldier)
        --         buff.countDamage = false
        --         soldier:addBuff(buff)
        --     end
        -- end
    end

    -- 开启寻路筛选
    self._enableFindTargetBlind = true

    -- 我方属性加强, 英雄属性,和兵团技能等级提升 已经在enterBattleView_CloudCity中做过
    local streng = cctD2["streng"]
    local attrAdd = cctD2["pro"]
    if streng and attrAdd then
        local kind, value
        local teamMap = {}
        local teams = self._teams[1]
        local team
        -- 取并集
        for i = 1, #streng do
            kind, value = streng[i][1], streng[i][2]
            if kind == 1 then
                -- 兵团ID
                for k = 1, #teams do
                    team = teams[k]
                    if team.replaceId then
                        if team.replaceId == value then
                            teamMap[team.ID] = team
                        end
                    else
                        if team.D["id"] == value then
                            teamMap[team.ID] = team
                        end
                    end
                end
            elseif kind == 2 then
                -- 阵营ID
                for k = 1, #teams do
                    if teams[k].race1 == value then
                        teamMap[teams[k].ID] = teams[k]
                    end
                end
            elseif kind == 3 then
                -- 兵种ID
                for k = 1, #teams do
                    if teams[k].classLabel == value then
                        teamMap[teams[k].ID] = teams[k]
                    end
                end
            end
        end
        local attr, value, soldier
        for id, team in pairs(teamMap) do
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                for i = 1, #attrAdd do
                    attr, value = attrAdd[i][1], attrAdd[i][2]
                    soldier.baseAttr[attr] = soldier.baseAttr[attr] + value
                end
                soldier.baseSum = nil
                soldier:resetAttr()
                if BattleUtils.XBW_SKILL_DEBUG then
                    if k == 1 then
                        print("云中城附加")
                        soldier:printAttr()
                    end
                end
            end
            team.baseSpeedAdd = team.soldier[1].attr[ATTR_MSpeed]
            team:resetAttr()
        end
    end

    -- 援助
    if cctD["helpCondition"] and cctD["helpCondition"][1] == 1 then
        self._helpCondition1 = {cctD["helpObject"], cctD["helpCondition"][2]}
        self.__teamDieCount = 0
    end

    -- 传送门
    local xx, yy = BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5
    if cctD["doorPo"] then
        local DOOR_WIDTH = 50
        local DOOR_HEIGHT = 50
        self._doors = {}
        local door, pos1, pos2
        local inx, iny
        local x1, y1, x2, y2
        local p1, p2, mc1, mc2
        local effName
        local doorCamp = cctD["door"]
        if doorCamp == 1 then
            effName = "stopr_ccchuansongmen"
        elseif doorCamp == 2 then
            effName = "stop_ccchuansongmen"
        elseif doorCamp == 3 then
            effName = "stop_ccchuansongmen"
        end
        for i = 1, #cctD["doorPo"] do
            -- 支持两种坐标
            p1, p2 = cctD["doorPo"][i][1], cctD["doorPo"][i][2]
            if type(p1) == "table" then
                inx, iny = xx + p1[1], yy + p1[2]
                x1 = inx - DOOR_WIDTH
                y1 = iny - DOOR_HEIGHT
                x2 = inx + DOOR_WIDTH
                y2 = iny + DOOR_HEIGHT
                x1 = x1 - 0.00000001
                x2 = x2 + 0.00000001
                y1 = y1 - 0.00000001
                y2 = y2 + 0.00000001
                door = {x1, y1, x2, y2, p2[1] - p1[1], p2[2] - p1[2], inx, iny}
                if not BATTLE_PROC then
                    mc1 = objLayer:playEffect_totem(effName, inx, iny, true, true, 1, 2)
                    mc2 = objLayer:playEffect_totem(effName, xx + p2[1], yy + p2[2], true, true, 1, 2)
                end
            else
                pos1 = BATTLE_POS[p1]
                pos2 = BATTLE_POS[p2]
                inx, iny = pos1[1], pos1[2]
                x1 = inx - DOOR_WIDTH
                y1 = iny - DOOR_HEIGHT
                x2 = inx + DOOR_WIDTH
                y2 = iny + DOOR_HEIGHT
                x1 = x1 - 0.00000001
                x2 = x2 + 0.00000001
                y1 = y1 - 0.00000001
                y2 = y2 + 0.00000001
                door = {x1, y1, x2, y2, pos2[1] - inx, pos2[2] - iny, inx, iny}
                if not BATTLE_PROC then
                    mc1 = objLayer:playEffect_totem(effName, inx, iny, true, true, 1, 2)
                    mc2 = objLayer:playEffect_totem(effName, pos2[1], pos2[2], true, true, 1, 2)
                end
            end
            -- 使用次数
            local times = cctD["doorT"][i]
            if times == nil or type(times) ~= "number" then
                times = 99999999
            end
            door[#door + 1] = times
            door[#door + 1] = {mc1, mc2}
            self._doors[i] = door
        end
        self._doorCheckIndex = 1
        self._doorCamp1 = (doorCamp == 2 or doorCamp == 3)
        self._doorCamp2 = (doorCamp == 1 or doorCamp == 3)
    end
    -- 陷阱
    if cctD["trap"] then
        local TRAP_WIDTH = 60
        local TRAP_HEIGHT = 40
        self._traps = {}
        local trap, x, y, p, pos
        for i = 1, #cctD["trap"] do
            p = cctD["trap"][i]
            if type(p) == "table" then
                x, y = xx + p[1], yy + p[2]
            else
                pos = BATTLE_POS[p]
                x, y = pos[1], pos[2]
            end
            trap = {x - TRAP_WIDTH - 0.00000001, y - TRAP_HEIGHT - 0.00000001, x + TRAP_WIDTH + 0.00000001, y + TRAP_HEIGHT + 0.00000001, x, y}
            if not BATTLE_PROC then
                trap[7] = objLayer:playEffect_totem("stop_ccxianjing", x, y, false, true, 1, 2)
            end
            self._traps[i] = trap
        end
        self._trapCheckIndex = 1
    end

    -- 帐篷
    self._b1s = {}
    -- 魔法塔
    self._b2s = {}
    -- 召唤小屋
    self._b4s = {}
    -- 禁魔塔
    self._b5s = {}
    -- 减魔的值
    self._b5sValue = {0, 0}
    local commonImmune = {true, true, true, true, true, true, true, true, true, true, true, true, true, true}
    -- 医疗帐篷
    local b1 = cctD["b1"]
    if b1 then
        local data, npcid, x, y, camp, level, tar, atk
        for i = 1, #b1 do
            data = b1[i]
            tar = cctD["tar1"][i]
            atk = cctD["atk1"][i]
            npcid, level, x, y, camp = data[1], data[2], data[4] + xx, data[5] + yy, data[3]
            local team = BattleTeam.new(camp)   
            local info = {npcid = npcid, level = level, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[2], info, x, y, 2 / GLOBAL_SP_SCALE, true)    
            self:_raceCountAdd(2, team.race1, team.race2)
            self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
            self:addTeam(team)     
            team.cantSort = true
            team.radius = 80
            team.soldier[1].radius = 80
            team.showHP = false
            team.immuneBuff = commonImmune
            self._b1s[#self._b1s + 1] = {team, tar[1], tar[2], atk[1], atk[2], atk[3], atk[3], atk[4], camp}
            if not BATTLE_PROC and tar[1] == 10 then
                team.__effect = objLayer:playEffect_totem("fanweihuixue2_fanweihuixue", x, y, false, false, 10, tar[2] / 50)
            end
        end
    end
    -- 魔法塔
    local b2 = cctD["b2"]
    if b2 then
        local data, npcid, x, y, camp, level, tar, atk
        for i = 1, #b2 do
            data = b2[i]
            tar = cctD["tar2"][i]
            atk = cctD["atk2"][i]
            npcid, level, x, y, camp = data[1], data[2], data[4] + xx, data[5] + yy, data[3]
            local team = BattleTeam.new(camp)   
            local info = {npcid = npcid, level = level, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[2], info, x, y, 2 / GLOBAL_SP_SCALE, true)    
            self:_raceCountAdd(2, team.race1, team.race2)
            self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
            self:addTeam(team)     
            team.cantSort = true
            team.radius = 80
            team.soldier[1].radius = 80
            team.showHP = false
            team.immuneBuff = commonImmune
            self._b2s[#self._b2s + 1] = {team, tar[1], tar[2], atk[1], atk[2], atk[3], atk[3], atk[4], 3 - camp}
            if not BATTLE_PROC and tar[1] == 10 then
                team.__effect = objLayer:playEffect_totem("stop_dianquan", x, y, false, false, 10, tar[2] / 50)
            end
        end
    end
    -- 石堆
    local b3 = cctD["b3"]
    if b3 then
        local data, npcid, x, y, camp, level
        for i = 1, #b3 do
            data = b3[i]
            npcid, level, x, y, camp = data[1], data[2], data[4] + xx, data[5] + yy, data[3]
            local team = BattleTeam.new(camp)   
            local info = {npcid = npcid, level = level, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[2], info, x, y, 2 / GLOBAL_SP_SCALE, true)    
            self:_raceCountAdd(2, team.race1, team.race2)
            self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
            self:addTeam(team)     
            team.cantSort = true
            team.radius = 80
            team.soldier[1].radius = 80
            team.showHP = false
            -- 远程路过
            team.blind_MoveType = {nil, true}
            team.immuneBuff = commonImmune
        end
    end
    -- 召唤小屋
    local b4 = cctD["b4"]
    if b4 then
        local data, npcid, x, y, camp, level
        for i = 1, #b4 do
            data = b4[i]
            npcid, level, x, y, camp = data[1], data[2], data[4] + xx, data[5] + yy, data[3]
            tar = cctD["tar4"][i]
            local team = BattleTeam.new(camp)   
            local info = {npcid = npcid, level = level, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[2], info, x, y, 2 / GLOBAL_SP_SCALE, true)    
            self:_raceCountAdd(2, team.race1, team.race2)
            self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
            self:addTeam(team)     
            team.cantSort = true
            team.radius = 80
            team.soldier[1].radius = 80
            team.showHP = false
            team.immuneBuff = commonImmune
            self._b4s[#self._b4s + 1] = {team, tar[1], tar[2], tar[2], camp}
        end
    end
    -- 禁魔塔
    local b5 = cctD["b5"]
    if b5 then
        local data, npcid, x, y, camp, level
        for i = 1, #b5 do
            data = b5[i]
            npcid, level, x, y, camp = data[1], data[2], data[4] + xx, data[5] + yy, data[3]
            tar = cctD["tar5"][i]
            local team = BattleTeam.new(camp)   
            local info = {npcid = npcid, level = level, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[2], info, x, y, 2 / GLOBAL_SP_SCALE, true)    
            self:_raceCountAdd(2, team.race1, team.race2)
            self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
            self:addTeam(team)     
            team.cantSort = true
            team.radius = 80
            team.soldier[1].radius = 80
            team.showHP = false
            team.immuneBuff = commonImmune
            self._b5s[#self._b5s + 1] = {team, tar[1], tar[1], tar[1], tar[1] + tar[2], tar[3], camp, false}
        end
    end
end

-- 召唤生物, 补天气BUFF
function BattleLogic:summonTeamEx(team)
    if team.camp ~= 1 then return end
    if self._weatherBuffId then
        local buffId, lv = self._weatherBuffId, self._weatherBuffLv
        local soldier, buff
        for k = 1, #team.aliveSoldier do
            soldier = team.soldier[k]
            buff = initSoldierBuff(buffId, lv, soldier.caster, soldier)
            buff.countDamage = false
            soldier:addBuff(buff)
        end
    end
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

function BattleLogic:BattleBeginEx()
    local cctD = self._battleInfo.cctD
    -- 提示文字
    if cctD["warn"] then
        for i = 1, #cctD["warn"] do
            delayCall(cctD["warn"][i][1], self, function ()
                if not BATTLE_PROC then
                    self._control:showWarning(lang(cctD["warn"][i][2]), 10, MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 215)
                end
            end)
        end
    end
    -- 支援
    if cctD["helpCondition"] and cctD["helpCondition"][1] == 2 then
        delayCall(cctD["helpCondition"][2], self, function ()
            self:summonHelp()
        end)
    end
    self._doorCheckTick = 0
    self._trapCheckTick = 0.05
    self._b1CheckTick = 0.1
    self._b2CheckTick = 0.15
    self._b4CheckTick = 0.17
    self._b5CheckTick = 0.21
    self._b5CheckTick2 = 2
end

local ETeamStateDIE = ETeamState.DIE
-- 召唤支援
function BattleLogic:summonHelp()
    local cctD = self._battleInfo.cctD
    local camp = cctD["helpObject"]
    local npcid, pos, x, y, team, info
    for i = 1, 8 do
        if cctD["hm"..i] == nil then break end
        npcid = cctD["hm"..i][1] 
        pos = cctD["hm"..i][2]
        if pos == 0 then
            x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5
        else
            x, y = BATTLE_POS[pos][1], BATTLE_POS[pos][2]
        end
        team = BattleTeam.new(camp)   

        info = {npcid = npcid, level = 1, summon = false}
        BC.initTeamAttr_Npc(team, self._heros[camp], info, x, y)    
        self:_raceCountAdd(1, team.race1, team.race2)
        self.classCount[1][team.classLabel] = self.classCount[1][team.classLabel] + 1
        self:addTeam(team)     
        self:addToUpdateList(team)   
    end
    -- 复活逻辑
    if cctD["helpEffect"] then
        local camp = cctD["helpEffect"]
        -- 全体复活
        delayCall(0.1, self, function ()
            local _team
            for i = 1, #self._teams[camp] do
                _team = self._teams[camp][i]
                if not _team.building then
                    objLayer:playEffect_skill1("fuhuo1_fuhuo", _team.x, _team.y, true, true, 1)
                    objLayer:playEffect_skill1("fuhuo2_fuhuo", _team.x, _team.y, false, false, 1)
                    if _team.state == ETeamStateDIE and not _team.reviveing then
                        local _soldier
                        for k = 1, #_team.soldier do
                            _soldier = _team.soldier[k]
                            if _soldier.die then
                                _soldier:setRevive(false, 100)
                            end
                        end
                    end
                end
            end
        end)
    end
end

local getRowIndex = BC.getRowIndex
-- 传送触发
function BattleLogic:teleport(team, _x, _y, dx, dy)
    self:teamAttackOver(team)

    if team.rush <= 2 then
        team.rush = 4
    end

    -- 这里需要改变row
    local camp = team.camp
    table.removebyvalue(self._rowTeam[camp][team.row], team)
    team.row = getRowIndex(_y + dy)
    table.insert(self._rowTeam[camp][team.row], team)

    local soldier
    for i = 1, #team.aliveSoldier do
        soldier = team.aliveSoldier[i]
        soldier.x = soldier.x + dx
        soldier.y = soldier.y + dy
    end
    team.posDirty = 99

    if not BATTLE_PROC then
        objLayer:playEffect_skill1("borm1_ccchuansongmen", _x, _y, true, true, nil, 2)
        objLayer:playEffect_skill1("borm2_ccchuansongmen", _x, _y, false, false, nil, 2)
        objLayer:playEffect_skill1("die1_ccchuansongmen", _x + dx, _y + dy, true, true, nil, 2)
        objLayer:playEffect_skill1("die2_ccchuansongmen", _x + dx, _y + dy, false, false, nil, 2)
    end
end

-- 陷阱触发
function BattleLogic:trapTrigger(team)
    local soldier
    for k = 1, #team.aliveSoldier do
        soldier = team.soldier[k]
        buff = initSoldierBuff(7005, 1, soldier.caster, soldier)
        soldier:addBuff(buff)
    end
end

local EStateING = EState.ING
function BattleLogic:updateEx()
    if self.battleState == EStateING then
        local tick = self.battleTime
        -- 检查传送门
        if self._doorCheckIndex then
            if tick > self._doorCheckTick then
                self._doorCheckTick = self._doorCheckTick + 0.1
                local door = self._doors[self._doorCheckIndex]
                self._doorCheckIndex = self._doorCheckIndex + 1
                if self._doorCheckIndex > #self._doors then
                    self._doorCheckIndex = 1
                end
                local x1, y1, x2, y2, dx, dy, _x, _y = door[1], door[2], door[3], door[4], door[5], door[6], door[7], door[8]
                local x, y
                local times = door[9]
                if times > 0 then
                    if self._doorCamp1 then            
                        local teams = self._teams[1]
                        for i = 1, #teams do
                            team = teams[i]
                            x, y = team.x, team.y
                            if x > x1 and x < x2 and y > y1 and y < y2 then
                                self:teleport(team, _x, _y, dx, dy)
                                times = times - 1
                                if times <= 0 then
                                    break
                                end
                            end
                        end
                    end
                    if self._doorCamp2 and times > 0 then
                        local teams = self._teams[2]
                        for i = 1, #teams do
                            team = teams[i]
                            x, y = team.x, team.y
                            if x > x1 and x < x2 and y > y1 and y < y2 then
                                self:teleport(team, _x, _y, dx, dy)
                                times = times - 1
                                if times <= 0 then
                                    break
                                end
                            end
                        end
                    end
                    door[9] = times
                    if times <= 0 then
                        if not BATTLE_PROC then
                            objLayer:stopEffect(door[10][1])
                            objLayer:stopEffect(door[10][2])
                        end
                    end
                end
            end
        end
        -- 检查陷阱
        if self._trapCheckIndex then
            if tick > self._trapCheckTick then
                self._trapCheckTick = self._trapCheckTick + 0.1
                local trap = self._traps[self._trapCheckIndex]
                self._trapCheckIndex = self._trapCheckIndex + 1
                if self._trapCheckIndex > #self._traps then
                    self._trapCheckIndex = 1
                end
                local x1, y1, x2, y2, _x, _y = trap[1], trap[2], trap[3], trap[4], trap[5], trap[6]
                local x, y
                local teams = self._teams[1]
                for i = 1, #teams do
                    team = teams[i]
                    x, y = team.x, team.y
                    if x > x1 and x < x2 and y > y1 and y < y2 then
                        self:trapTrigger(team)
                        if not BATTLE_PROC then
                            local mc = trap[7]
                            objLayer:playEffect_skill1("borm_ccxianjing", _x, _y - 20, false, false, nil, 2, function ()
                                objLayer:stopEffect(mc)
                            end)
                        end
                        table.removebyvalue(self._traps, trap)
                        if #self._traps == 0 then
                            self._trapCheckIndex = nil
                        else
                            if self._trapCheckIndex > #self._traps then
                                self._trapCheckIndex = 1
                            end
                        end
                        break
                    end
                end
            end
        end
        -- 帐篷
        if #self._b1s > 0 then
            if tick > self._b1CheckTick then
                self._b1CheckTick = self._b1CheckTick + 0.1
                local tar, count, _type, value, inv, time, valueAdd, tarCamp
                local teams, _team
                local caster, info, team
                for i = 1, #self._b1s do
                    info = self._b1s[i]
                    team = info[1]
                    if team.state ~= ETeamStateDIE then
                        time = info[7]
                        if tick > time then
                            caster = team.soldier[1]
                            tar, count, _type, value, inv, valueAdd, tarCamp = info[2], info[3], info[4], info[5], info[6], info[8], info[9]
                            if tar ~= 10 then
                                caster:changeMotion(5)
                            else
                                caster:changeMotion(3)
                            end
                            -- 下一次生效时间
                            info[7] = time + inv
                            -- 递增效果
                            info[5] = value + valueAdd
                            -- 回血
                            teams = self:ccFindTargetTeam(team.x, team.y, tarCamp, tar, count)
                            if _type == 1 then
                                -- 数值
                                for i = 1, #teams do
                                    _team = teams[i]
                                    if not BATTLE_PROC then
                                        if tar ~= 10 then
                                            objLayer:playEffect_skill1("xian2_cczhangpeng", _team.x, _team.y, true, true, nil, 1)
                                            objLayer:playEffect_hit2_pt2("xian_cczhangpeng", true, caster.x, caster.y + 50, _team.x, _team.y, 35, true)
                                        end
                                    end
                                    if not BATTLE_PROC and tar == 10 then
                                        for k = 1, #_team.soldier do
                                            if not _team.soldier[k].die then
                                                objLayer:playEffect_hit1("buff_cczhangpeng", true, true, _team.soldier[k], 2, 2)
                                                _team.soldier[k]:heal(nil, value)
                                            end
                                        end
                                    else
                                        for k = 1, #_team.soldier do
                                            if not _team.soldier[k].die then
                                                _team.soldier[k]:heal(nil, value)
                                            end
                                        end
                                    end
                                end
                            elseif _type == 2 then
                                -- 百分比
                                local soldier
                                for i = 1, #teams do
                                    _team = teams[i]
                                    if not BATTLE_PROC then
                                        if tar ~= 10 then
                                            objLayer:playEffect_skill1("xian2_cczhangpeng", _team.x, _team.y, true, true, nil, 1)
                                            objLayer:playEffect_hit2_pt2("xian_cczhangpeng", true, caster.x, caster.y + 50, _team.x, _team.y, 35, true)
                                        end
                                    end
                                    if not BATTLE_PROC and tar == 10 then
                                        for k = 1, #_team.soldier do
                                            soldier = _team.soldier[k]
                                            if not soldier.die then
                                                objLayer:playEffect_hit1("buff_cczhangpeng", true, true, soldier, 2, 2)
                                                soldier:heal(nil, ceil(soldier.maxHP * value * 0.01))
                                            end
                                        end
                                    else
                                        for k = 1, #_team.soldier do
                                            soldier = _team.soldier[k]
                                            if not soldier.die then
                                                soldier:heal(nil, ceil(soldier.maxHP * value * 0.01))
                                            end
                                        end
                                    end
                                end
                            end
                            if info[5] <= 0 then
                                caster:rap(nil, -caster.maxHP, false, false, 0)
                            elseif valueAdd and valueAdd ~= 0 then
                                objLayer:showSkillName(caster.ID, true, caster.x, caster.y, team.camp, "效果提升")
                            end
                        end
                    end
                end
            end
        end
        -- 魔法塔
        if #self._b2s > 0 then
            if tick > self._b2CheckTick then
                self._b2CheckTick = self._b2CheckTick + 0.1
                local tar, count, _type, value, inv, time, valueAdd, tarCamp
                local teams, _team
                local caster, ex, info, team
                for i = 1, #self._b2s do
                    info = self._b2s[i]
                    team = info[1]
                    if team.state ~= ETeamStateDIE then
                        time = info[7]
                        if tick > time then
                            caster = team.soldier[1]
                            -- caster:changeMotion(3)
                            tar, count, _type, value, inv, valueAdd, tarCamp = info[2], info[3], info[4], info[5], info[6], info[8], info[9]
                            -- 下一次生效时间
                            info[7] = time + inv
                            -- 递增效果
                            info[8] = value + valueAdd
                            -- 打击
                            teams = self:ccFindTargetTeam(team.x, team.y, tarCamp, tar, count)
                            if team.camp == 1 then
                                ex = "_ccmofata"
                            else
                                ex = "r_ccmofata"
                            end
                            if _type == 1 then
                                -- 数值
                                for i = 1, #teams do
                                    _team = teams[i]
                                    -- 特效
                                    if not BATTLE_PROC then
                                        if tar ~= 10 then
                                        local __y = 0
                                            if _team.volume >= 5 then __y = 50 end
                                            objLayer:playEffect_skill1("xian2"..ex, _team.x, _team.y, false, false, nil, 1.5)
                                            objLayer:playEffect_hit2_pt2("xian"..ex, true, caster.x, caster.y + 100, _team.x, _team.y + __y, 100, true)
                                        end
                                    end
                                    if not BATTLE_PROC and tar == 10 then
                                        for k = 1, #_team.soldier do
                                            if not _team.soldier[k].die then
                                                objLayer:playEffect_hit1("buff_dianquan", true, true, _team.soldier[k], 2, 1.2)
                                                _team.soldier[k]:rap(nil, -value, false, false, 998)
                                            end
                                        end
                                    else
                                        for k = 1, #_team.soldier do
                                            if not _team.soldier[k].die then
                                                _team.soldier[k]:rap(nil, -value, false, false, 998)
                                            end
                                        end
                                    end
                                end
                            elseif _type == 2 then
                                -- 百分比
                                local soldier
                                for i = 1, #teams do
                                    _team = teams[i]
                                    -- 特效
                                    if not BATTLE_PROC then
                                        if tar ~= 10 then
                                            local __y = 0
                                            if _team.volume >= 5 then __y = 50 end
                                            objLayer:playEffect_skill1("xian2"..ex, _team.x, _team.y, false, false, nil, 1.5)
                                            objLayer:playEffect_hit2_pt2("xian"..ex, true, caster.x, caster.y + 100, _team.x, _team.y + __y, 100, true)
                                        end
                                    end
                                    if not BATTLE_PROC and tar == 10 then
                                        for k = 1, #_team.soldier do
                                            soldier = _team.soldier[k]
                                            if not soldier.die then
                                                objLayer:playEffect_hit1("buff_dianquan", true, true, soldier, 2, 1.2)
                                                soldier:rap(nil, -ceil(soldier.maxHP * value * 0.01), false, false, 998)
                                            end
                                        end
                                    else
                                        for k = 1, #_team.soldier do
                                            soldier = _team.soldier[k]
                                            if not soldier.die then
                                                soldier:rap(nil, -ceil(soldier.maxHP * value * 0.01), false, false, 998)
                                            end
                                        end
                                    end
                                end
                            end
                            if info[5] <= 0 then
                                caster:rap(nil, -caster.maxHP, false, false, 0)
                            elseif valueAdd and valueAdd ~= 0 then
                                objLayer:showSkillName(caster.ID, true, caster.x, caster.y, team.camp, "伤害提升")
                            end
                        end
                    end
                end
            end
        end
        if #self._b4s > 0 then
            if tick > self._b4CheckTick then
                self._b4CheckTick = self._b4CheckTick + 0.1
                local npcid, inv, time, tarCamp
                local caster, ex, info, team
                for i = 1, #self._b4s do
                    info = self._b4s[i]
                    team = info[1]
                    if team.state ~= ETeamStateDIE then
                        time = info[4]
                        if tick > time then
                            caster = team.soldier[1]
                            npcid, inv, tarCamp = info[2], info[3], info[5]
                            info[4] = time + inv
                            team.soldier[1]:changeMotion(3)
                            if tarCamp == 1 then
                                self:summonTeam({camp = tarCamp}, nil, npcid, 0, nil, 1, team.x + 100, team.y - 50)
                            else
                                self:summonTeam({camp = tarCamp}, nil, npcid, 0, nil, 1, team.x - 100, team.y - 50)
                            end
                        end
                    end
                end
            end
        end
        --          inv     time    inv2     time2   mana 
        -- {team, tar[1], tar[1], tar[2], tar[2], tar[3], camp, false}
        if #self._b5s > 0 then
            if tick > self._b5CheckTick then
                self._b5CheckTick = self._b5CheckTick + 0.1
                local inv, inv2, time, time2, manadec, tarCamp, dir
                local caster, ex, info, team, state
                for i = 1, #self._b5s do
                    info = self._b5s[i]
                    team, inv, time, inv2, time2, manadec, tarCamp, state = info[1], info[2], info[3], info[4], info[5], info[6], 3 - info[7], info[8]
                    caster = team.soldier[1]
                    if tarCamp == 2 then
                        dir = 1
                    else
                        dir = -1
                    end
                    if team.state ~= ETeamStateDIE then
                        -- 释放
                        if tick > time then
                            info[3] = time + inv
                            -- 激活
                            info[8] = true

                            self._b5sValue[tarCamp] = self._b5sValue[tarCamp] + manadec
                            print("manadec + ", tarCamp, self._b5sValue[tarCamp])
                            if not BATTLE_PROC then
                                local name
                                if tarCamp == 2 then
                                    name = "shifang_ccjinmota"
                                else
                                    name = "shifangr_ccjinmota"
                                end
                                objLayer:playEffect_totemDisappear(name, caster.x, caster.y, true, true, 1.5, dir)
                                delayCall(1, self, function ()
                                    local name
                                    if tarCamp == 2 then
                                        name = "chixu_ccjinmota"
                                    else
                                        name = "chixur_ccjinmota"
                                    end
                                    if caster.__buff then
                                        objLayer:stopEffect(caster.__buff)
                                        caster.__buff = nil
                                    end
                                    caster.__buff = objLayer:playEffect_totem(name, caster.x, caster.y, true, true, nil, 1.5, dir)
                                end)
                            else
                                delayCall(1, self, function ()
                                end)
                            end
                        end
                    else
                        if state then
                            -- 回收
                            info[8] = false
                            self._b5sValue[tarCamp] = self._b5sValue[tarCamp] - manadec
                            print("manadec -1 ", tarCamp, self._b5sValue[tarCamp])
                            if not BATTLE_PROC then
                                local name
                                if tarCamp == 2 then
                                    name = "xiaoshi_ccjinmota"
                                else
                                    name = "xiaoshir_ccjinmota"
                                end
                                objLayer:playEffect_totemDisappear(name, caster.x, caster.y, true, true, 1.5, dir)
                                if caster.__buff then
                                    objLayer:stopEffect(caster.__buff)
                                    caster.__buff = nil
                                end
                            end
                        end
                    end
                    -- 回收
                    if tick > time2 then
                        caster = team.soldier[1]
                        info[5] = time2 + inv2
                        if state then
                            -- 回收
                            info[8] = false
                            self._b5sValue[tarCamp] = self._b5sValue[tarCamp] - manadec
                            print("manadec -2 ", tarCamp, self._b5sValue[tarCamp])
                            if not BATTLE_PROC then
                                local name
                                if tarCamp == 2 then
                                    name = "xiaoshi_ccjinmota"
                                else
                                    name = "xiaoshir_ccjinmota"
                                end
                                objLayer:playEffect_totemDisappear(name, caster.x, caster.y, true, true, 1.5, dir)
                                if caster.__buff then
                                    objLayer:stopEffect(caster.__buff)
                                    caster.__buff = nil
                                end
                            end
                        end
                    end
                end
            end
            if tick > self._b5CheckTick2 then
                self._b5CheckTick2 = self._b5CheckTick2 + 2
                -- 扣mana
                if self._b5sValue[1] > 0 then
                    self._heroAttrFunc[1](self, -self._b5sValue[1])
                end
                if self._b5sValue[2] > 0 then
                    self._heroAttrFunc[2](self, -self._b5sValue[2])
                end
            end
            -- 看是否需要在英雄身上挂状态
            if not BATTLE_PROC and not BC.jump then
                pcall(function ()
                    if self._b5sValue[1] > 0 then
                        if self._heros[1].jinmota == nil then
                            self._heros[1].jinmota = mcMgr:createViewMC("buffr_ccjinmota", true, false)
                            self._heros[1].jinmota:setPositionY(120)
                            if self._heros[1]._node then
                                self._heros[1]._node:addChild(self._heros[1].jinmota)
                            else
                                self._heros[1].jinmota = nil
                            end
                        else
                            self._heros[1].jinmota:setVisible(true)
                        end
                    else
                        if self._heros[1].jinmota then
                            self._heros[1].jinmota:setVisible(false)
                        end
                    end
                    if self._b5sValue[2] > 0 then
                        if self._heros[2].jinmota == nil then
                            self._heros[2].jinmota = mcMgr:createViewMC("buff_ccjinmota", true, false)
                            self._heros[2].jinmota:setPositionY(120)
                            if self._heros[2]._node then
                                self._heros[2]._node:addChild(self._heros[2].jinmota)
                            else
                                self._heros[2].jinmota = nil
                            end
                        else
                            self._heros[2].jinmota:setVisible(true)
                        end
                    else
                        if self._heros[2].jinmota then
                            self._heros[2].jinmota:setVisible(false)
                        end
                    end
                end)
            end
        end
    end
end

function BattleLogic:ccFindTargetTeam(x, y, camp, tar, count)
    return self["ccFindTargetTeam"..tar](self, x, y, camp, count)
end

local randomSelect = BC.randomSelect

function BattleLogic:ccGetRandomTeams(array, count)
    local list = {}
    local team
    for i = 1, #array do
        team = array[i]
        if team.state ~= ETeamStateDIE then
            list[#list + 1] = team
        end
    end
    if count >= #list then
        return list
    else
        local arr = randomSelect(#list, count)
        local ret = {}
        for m = 1, #arr do
            ret[m] = list[arr[m]]
        end
        return ret
    end
end

-- 随机
function BattleLogic:ccFindTargetTeam1(x, y, camp, count)
    local array = self.targetCache[camp][10]
    return self:ccGetRandomTeams(array, count)
end

-- 防御
function BattleLogic:ccFindTargetTeam2(x, y, camp, count)
    local array = self.targetTeamCacheClass[camp][2]
    return self:ccGetRandomTeams(array, count)
end

-- 突击
function BattleLogic:ccFindTargetTeam3(x, y, camp, count)
    local array = self.targetTeamCacheClass[camp][3]
    return self:ccGetRandomTeams(array, count)
end

-- 射手
function BattleLogic:ccFindTargetTeam4(x, y, camp, count)
    local array = self.targetTeamCacheClass[camp][4]
    return self:ccGetRandomTeams(array, count)
end

-- 魔法
function BattleLogic:ccFindTargetTeam5(x, y, camp, count)
    local array = self.targetTeamCacheClass[camp][5]
    return self:ccGetRandomTeams(array, count)
end

-- 攻击
function BattleLogic:ccFindTargetTeam6(x, y, camp, count)
    local array = self.targetTeamCacheClass[camp][1]
    return self:ccGetRandomTeams(array, count)
end

-- 最近
function BattleLogic:ccFindTargetTeam7(x, y, camp, count)
    local list = {}
    local array = self.targetCache[camp][10]
    local team, _x, _y
    for i = 1, #array do
        team = array[i]
        
        if team.state ~= ETeamStateDIE then
            list[#list + 1] = team
        end
    end
    if count >= #list then
        return list
    else
        for i = 1, #list do
            team = list[i]
            _x, _y = team.x, team.y
            team.__sortValue = (_x - x) * (_x - x) + (_y - y) * (_y - y)
        end
        local sortFunc = function(a, b)
            return a.__sortValue < b.__sortValue
        end
        table.sort(list, sortFunc)
        local ret = {}
        for i = 1, count do
            ret[i] = list[i]
        end
        return ret
    end
end

-- 最远
function BattleLogic:ccFindTargetTeam8(x, y, camp, count)
    local list = {}
    local array = self.targetCache[camp][10]
    local team, _x, _y
    for i = 1, #array do
        team = array[i]
        if team.state ~= ETeamStateDIE then
            list[#list + 1] = team
        end
    end
    if count >= #list then
        return list
    else
        for i = 1, #list do
            team = list[i]
            _x, _y = team.x, team.y
            team.__sortValue = (_x - x) * (_x - x) + (_y - y) * (_y - y)
        end
        local sortFunc = function(a, b)
            return b.__sortValue < a.__sortValue
        end
        table.sort(list, sortFunc)
        local ret = {}
        for i = 1, count do
            ret[i] = list[i]
        end
        return ret
    end
end

-- 血量最少
function BattleLogic:ccFindTargetTeam9(x, y, camp, count)
    local list = {}
    local array = self.targetCache[camp][10]
    local team, _x, _y
    for i = 1, #array do
        team = array[i]
        if team.state ~= ETeamStateDIE then
            list[#list + 1] = team
        end
    end
    if count >= #list then
        return list
    else
        for i = 1, #list do
            team = list[i]
            _x, _y = team.x, team.y
            team.__sortValue = team.curHP / team.maxHP
        end
        local sortFunc = function(a, b)
            return b.__sortValue > a.__sortValue
        end
        table.sort(list, sortFunc)
        local ret = {}
        for i = 1, count do
            ret[i] = list[i]
        end
        return ret
    end
end

-- 范围半径
function BattleLogic:ccFindTargetTeam10(x, y, camp, radius)
    local dx, dy
    local ret = {}

    local b = radius
    local a = b * 2
    a = a * a
    b = b * b
    local array = self.targetCache[camp][10]
    local team, _x, _y
    for i = 1, #array do
        team = array[i]
        if team.state ~= ETeamStateDIE then
            _x, _y = team.x, team.y
            dx = _x - x
            dy = _y - y
            if dx * dx / a + dy * dy / b < 1.00000001 then
                ret[#ret + 1] = team
            end
        end
    end
    
    return ret
end

function BattleLogic:teamAttackOverEx(team)

end

function BattleLogic:onTeamDieEx(team)
    if team.__effect then
        if not BATTLE_PROC then
            objLayer:stopEffect(team.__effect)
        end
    end
    if self._helpCondition1 then
        local camp, value = self._helpCondition1[1], self._helpCondition1[2]
        if team.camp == camp then
            self.__teamDieCount = self.__teamDieCount + 1
            if value == self.__teamDieCount then
                self._helpCondition1 = nil
                -- 触发支援
                self:summonHelp()
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
    if self.battleTime > COUNT_TIME then
        self:timeUp(2)
        return true
    end
    for i = 1, 2 do
        if self._lastTeamCount[i] == 0 and self._reviveCount[i] == 0 then
            self:Win(3 - i)
            return true
        end
    end
    return false
end

function BattleLogic:setCampBrightnessEx(camp, value)

end

function BattleLogic:isOpenAutoBattleForLeftCamp()
    return true
end

function BattleLogic:isOpenAutoBattleForRightCamp()
    return true
end

end 
function rule.dtor()
    ATTR_MSpeed = nil
    randomSelect = nil
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
    floor = nil
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
    modf = nil
    EStateING = nil
    initSoldierBuff = nil
    ETeamStateDIE = nil
    getRowIndex = nil
end
return rule