--[[
    Filename:    BattleSkillLogic.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-01-26 14:19:40
    Description: File description
--]]
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
local mcMgr = mcMgr

local Battle_Delta = BC.Battle_Delta
local random = BC.ran

local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType
local actionInv = BC.actionInv

local objLayer = BC.objLayer
local delayCall = BC.DelayCall.dc
local floor = math.floor
local ceil  = math.ceil

local SRData = BattleUtils.SRData

local BattleTotem =  require("game.view.battle.object.BattleTotem")
local BattleTeam = require("game.view.battle.object.BattleTeam")
local BattleTeam_addDamage = BattleTeam.addDamage
local BattleTeam_addHurt = BattleTeam.addHurt
local BattleTeam_addHeal = BattleTeam.addHeal

local BattleSkillLogic = class("BattleSkillLogic", require("game.view.battle.logic.BattleLogic"))
-- 继承自BattleLogic
-- 单纯的把技能相关代码分离出来, BattleLogic代码太长了

local ETeamStateDIE = ETeamState.DIE
local ETeamStateNONE = ETeamState.NONE
local ETeamStateMOVE = ETeamState.MOVE
-- 技能相关
local super = BattleSkillLogic.super
function BattleSkillLogic:ctor(control, view)
    objLayer = BC.objLayer
    super.ctor(self, control, view)
    -- 全局减蓝耗
    self._manaPro = {1.0, 1.0}
    self._oriManaPro = {1.0, 1.0}
end

function BattleSkillLogic:initLogic(mapInfo, stageInfo, playerInfo)
    -- 图腾列表
    self._totems = {}

    -- 加速技能选择目标的速度
    self.targetCache = {}
    -- 兵种cache
    self.targetCacheClass = {}
    -- 兵种team cache
    self.targetTeamCacheClass = {}
    -- 移动方式区分
    self.targetCacheMoveType = {}
    -- 种族cache
    self.targetCacheRace = {}
    for i = ECamp.LEFT, ECamp.RIGHT do
        self.targetCache[i] = {
            [1] = {},   --敌方建筑
            [2] = {},   --敌方怪兽
            [3] = {},   --己方单位
            [4] = {},   --敌方单位
            [5] = {},   --敌方方阵
            [6] = {},   --敌方近战方阵
            [7] = {},   --敌方远程方阵
            [8] = {},   --己方近战单位
            [9] = {},   --己方远程单位
            [10] = {},  --己方方阵
            [11] = {},  --敌方召唤方阵
            [12] = {},  --己方怪兽
            [13] = {},  --己方召唤单位
            [14] = {},  --敌方召唤单位
            [15] = {},  --己方骷髅单位
            [16] = {},  --己方地狱单位
            [17] = {},  --己方飞行方阵
            [18] = {},  --敌方方阵+建筑
            [19] = {},  --己方龙单位
            [20] = {},  --己方后援单位
            [21] = {},  --敌方后援单位
            [22] = {},  --己方后援方阵
            [23] = {},  --敌方后援方阵
        }

        self.targetCacheClass[i] = {{}, {}, {}, {}, {}}
        self.targetTeamCacheClass[i] = {{}, {}, {}, {}, {}}

        self.targetCacheMoveType[i] = {{}, {}}

        self.targetCacheRace[i] = {}

    end
    self.targetCacheAll = {} --全部单位
    self.targetCacheSummon = {} --全部召唤单位

    super.initLogic(self, mapInfo, stageInfo, playerInfo)
    self:ctor_player()

    -- switch替代...
    -- 增减玩家技能属性
    self._heroAttrFunc = {
        self.PlayerMana,
        self.EnemyMana,
        self.PlayerManaRec,
        self.EnemyManaRec,
        self.PlayerExternalInt,
        self.EnemyExternalInt,
        self.PlayerSkillCD,
        self.EnemySkillCD,
        self.PlayerManaPrcRec,
        self.EnemyManaPrcRec,
    }

    -- 选圆心方法表
    local funcCount = 64
    self._getSkillPointFunc = {}
    for i = 1, funcCount do
        self._getSkillPointFunc[i] = self["getSkillPoint"..i]
    end

    -- 技能作用方法表
    funcCount = 11
    self._skillActionFunc = {}
     for i = 1, funcCount do
        self._skillActionFunc[i] = self["skillAction"..i]
    end   

    -- 技能目标选择方法表
    funcCount = 17
    self._getSkillTargetFunc = {}
    for i = 1, funcCount do
        self._getSkillTargetFunc[i] = self["getSkillTarget"..i]
    end    

    -- 技能目标范围筛选方法表
    funcCount = 4
    self._getRangeTargetFunc = {}
    for i = 1, funcCount do
        self._getRangeTargetFunc[i] = self["getRangeTarget"..i]
    end    

    self.onSoldierDieFunc = {self.onSoldierDie1, self.onSoldierDie2}
    self.onTeamDieFunc = {self.onTeamDie1, self.onTeamDie2}
    self.onTeamReviveFunc = {self.onTeamRevive1, self.onTeamRevive2}

    -- 地图切换的table(现在只支持子物体 {子物体id，地图id})
    self._switchMapTable = {}
end

-- 战斗结算弹出的时候 关闭图特
function BattleSkillLogic:totemOver()
    for i = 1, #self._totems do
        self._totems[i]:over()
        self._totems[i]:clear()
        self._totems[i] = nil
    end 
end

function BattleSkillLogic:clear()
    if self._totems == nil then return end
    for i = 1, #self._totems do
        self._totems[i]:clear()
        self._totems[i] = nil
    end
    -- self._totems = nil
    for i = ECamp.LEFT, ECamp.RIGHT do
        self.targetCache[i] = nil
        self.targetCacheClass[i] = nil
        self.targetTeamCacheClass[i] = nil
        self.targetCacheMoveType[i] = nil
        self.targetCacheRace[i] = nil
    end
    self.targetCache = nil
    self.targetCacheClass = nil
    self.targetTeamCacheClass = nil
    self.targetCacheMoveType = nil
    self.targetCacheRace = nil
    self.targetCacheAll = nil
    self.targetCacheSummon = nil
    self._heroAttrFunc = nil

    self._getSkillPointFunc = nil

    self._skillActionFunc = nil   

    self._getSkillTargetFunc = nil

    self._getRangeTargetFunc = nil

    self.onSoldierDieFunc = nil
    self.onTeamDieFunc = nil
    self.onTeamReviveFunc = nil

    self._switchMapTable = nil
    
    objLayer = nil
    super.clear(self)
    self:clearSkill()
    self:clear_player()
end

function BattleSkillLogic:clearSkill()
    super.clearSkill(self)

end
 

--额外修改智力相关 start
function BattleSkillLogic:PlayerExternalInt(value)
    if self._heros and self._heros[1] then
        self._heros[1].int = self._heros[1].int + value * 0.01
        local _int = self._heros[1].int
        local _ack = self._heros[1].ack
        if _int < -300 then
            _int = -300
        end
        BC.formula_hero_intack[1] = (1 + 0.0025 * _int) / (1 + 0.0025 * _ack)
    end
end

function BattleSkillLogic:EnemyExternalInt(value)
    if self._heros and self._heros[2] then
        self._heros[2].int = self._heros[2].int + value * 0.01
        local _int = self._heros[2].int
        local _ack = self._heros[2].ack
        if _int < -300 then
            _int = -300
        end
        BC.formula_hero_intack[2] = (1 + 0.0025 * _int) / (1 + 0.0025 * _ack)
    end
end
--外修改智力相关 end


--修改技能英雄CD start

function BattleSkillLogic:PlayerSkillCD(value, camp, nType)
    if nType then
        local skillArr = {}
        local tick = self.battleTime
        for k,v in pairs(self._playAutoSkills[1]) do
            if v then
                local skill = self._playSkills[1][v.index]
                if skill then
                    if nType == 1 then
                        if skill.castTick > tick then
                            skillArr[#skillArr + 1] = v.index
                        end
                    elseif nType == 2 then
                        --英雄大招
                        if skill.castTick > tick and skill.dazhao > 0 then
                            skillArr[#skillArr + 1] = v.index
                        end
                    end
                end
            end
        end
--        dump(skillArr)
        if #skillArr > 0 then
            local res = BC.randomSelect(#skillArr, 1)
            local index = skillArr[res[1]]
            local skill = self._playSkills[1][index]
            skill.castTick = skill.castTick - value
            if skill.castTick < tick then
                skill.castTick = tick
            end
            if XBW_SKILL_DEBUG then
                print("修改英雄技能 CD1 ", skill.id, value, nType)
            end
        else
            if XBW_SKILL_DEBUG then
                print("修改英雄技能 CD1 失败")
            end
        end
    end
end

function BattleSkillLogic:EnemySkillCD(value, camp, nType)
    if nType then
        local skillArr = {}
        local tick = self.battleTime
        for k,v in pairs(self._playAutoSkills[2]) do
            if v then
                local skill = self._playSkills[2][v.index]
                if skill then
                    if nType == 1 then
                        if skill.castTick > tick then
                            skillArr[#skillArr + 1] = v.index
                        end
                    elseif nType == 2 then
                        --英雄大招
                        if skill.castTick > tick and skill.dazhao > 0 then
                            skillArr[#skillArr + 1] = v.index
                        end
                    end
                end
            end
        end
        if #skillArr > 0 then
            local res = BC.randomSelect(#skillArr, 1)
            local index = skillArr[res[1]]
            local skill = self._playSkills[2][index]
            skill.castTick = skill.castTick - value
            if skill.castTick < tick then
                skill.castTick = tick
            end
            if XBW_SKILL_DEBUG then
                print("修改英雄技能 CD2", skill.id, value, nType)
            end
        else
            if XBW_SKILL_DEBUG then
                print("修改英雄技能 CD2 失败")
            end
        end
    end
end

--修改技能英雄CD end

if BATTLE_PROC or not GameStatic.checkZuoBi_5 then
function BattleSkillLogic:PlayerMana(value)
    if value == 0 then return end
    local mana = self.mana
    mana[1] = mana[1] + value
    if mana[1] < 0 then
        mana[1] = 0
    end
    if mana[1] > self.manaMax[1] then
        mana[1] = self.manaMax[1]
    end
end

function BattleSkillLogic:EnemyMana(value)
    if value == 0 then return end
    local mana = self.mana
    mana[2] = mana[2] + value
    if mana[2] < 0 then
        mana[2] = 0
    end
    if mana[2] > self.manaMax[2] then
        mana[2] = self.manaMax[2]
    end
end
else
function BattleSkillLogic:PlayerMana(value)
    if value == 0 then return end
    local mana = self.mana
    if mana[1] > self.manaMax[1] + 0.001 then
        BC.zuobi = 5
    end
    local old = mana[1]
    mana[1] = mana[1] + value
    if old == mana[1] then
        BC.zuobi = 6
    end
    if mana[1] < 0 then
        mana[1] = 0
    end
    if mana[1] > self.manaMax[1] then
        mana[1] = self.manaMax[1]
    end
    if SRData then
        if value > 0 then
            SRData[337] = SRData[337] + 1
            if value > SRData[338] then SRData[338] = value end
            if value < SRData[339] then SRData[339] = value end
            SRData[340] = SRData[340] + value
        else
            value = - value
            SRData[341] = SRData[341] + 1
            if value > SRData[342] then SRData[342] = value end
            if value < SRData[343] then SRData[343] = value end
            SRData[344] = SRData[344] + value
        end
    end
end

function BattleSkillLogic:EnemyMana(value)
    if value == 0 then return end
    local mana = self.mana
    if mana[2] > self.manaMax[2] + 0.001 then
        BC.zuobi = 5
    end
    local old = mana[2]
    mana[2] = mana[2] + value
    if old == mana[2] then
        BC.zuobi = 6
    end
    if mana[2] < 0 then
        mana[2] = 0
    end
    if mana[2] > self.manaMax[2] then
        mana[2] = self.manaMax[2]
    end
end
end

function BattleSkillLogic:PlayerManaRec(value)
    self.manaRec[1] = self.manaRec[1] + value  
    if self.manaRec[1] < 0 then
        self.manaRec[1] = 0
    end
end

function BattleSkillLogic:EnemyManaRec(value)
    self.manaRec[2] = self.manaRec[2] + value  
    if self.manaRec[2] < 0 then
        self.manaRec[2] = 0
    end
end

function BattleSkillLogic:PlayerManaPrcRec(value)
    local hero = self._heros[1]
    if hero and hero.manaRec then
        local mana = hero.manaRec
        self.manaRec[1] = mana * value * 0.01 + self.manaRec[1] 
        if self.manaRec[1] < 0 then
            self.manaRec[1] = 0
        end
    end
end

function BattleSkillLogic:EnemyManaPrcRec(value)
    local hero = self._heros[2]
    if hero and hero.manaRec then
        local mana = hero.manaRec
        self.manaRec[2] = mana * value * 0.01 + self.manaRec[2] 
        if self.manaRec[2] < 0 then
            self.manaRec[2] = 0
        end
    end
end

-- 士兵释放技能
-- caster为攻击者的数值容器
-- attacker为触发受击技能的攻击者
local initSoldierBuff = BC.initSoldierBuff 
local initPlayerBuff = BC.initPlayerBuff
local genRanBuff = BC.genRanBuff
local updateCaster = BC.updateCaster
local sqrt = math.sqrt
local getBulletFlyTime = BC.getBulletFlyTime
local angerT = {2, 1, 4, 3, 6, 5, 8, 7, 10, 9}
local SRTab = {384, 391, 398, 405, 412, 419, 427, 435, 442, 450, 456, 462}
function BattleSkillLogic:soldierCastSkill(noEff, skillD, level, caster, hitter, useAttackInv)
    -- print(self.battleTime, caster.attacker.ID, skillD["id"])
    local ing = self.battleState == EState.ING
    local castTick = self.battleTime
    -- 选择圆心
    local attacker = caster.attacker
    local direct = attacker.direct
    local team = attacker.team

    local camp = caster.camp

    if SRData then
        if camp == 1 then
            local skillid = skillD["id"]
            local sr = team.srSkillTab[skillid]
            if sr then
                for i = 1, #sr do
                    local index = SRTab[sr[i]]
                    SRData[index] = SRData[index] + 1
                end
            end
        end
    end
    -- 强制释放, 无视沉默
    local forceSkill = (skillD["banskill"] ~= nil)

    -- 施法光影
    if not BC.jump then
        if not noEff and skillD["skillart"] then
            local scale
            if skillD["skillartscale"] then
                scale = skillD["skillartscale"] * 0.01
            end
            if forceSkill then
                if skillD["stklocation"] and skillD["stklocation"] == 2 then
                    objLayer:playEffect_skill1(skillD["skillart"], team.x, team.y, true, true, direct, scale)
                else
                    objLayer:playEffect_skill1(skillD["skillart"], caster.x, caster.y, true, true, direct, scale)
                end
            else
                if skillD["stklocation"] and skillD["stklocation"] == 2 then
                    local mc = objLayer:playEffect_skill1(skillD["skillart"], team.x, team.y, true, true, direct, scale, function ()
                        attacker.mcCount = attacker.mcCount - 1
                        team.mcCount = team.mcCount - 1
                    end)
                    mc.teamid = team.ID
                    mc.soldierid = attacker.ID
                    attacker.mcCount = attacker.mcCount + 1
                    team.mcCount = team.mcCount + 1
                else
                    local mc = objLayer:playEffect_skill1(skillD["skillart"], caster.x, caster.y, true, true, direct, scale, function ()
                        attacker.mcCount = attacker.mcCount - 1
                        team.mcCount = team.mcCount - 1
                    end)
                    mc.teamid = team.ID
                    mc.soldierid = attacker.ID
                    attacker.mcCount = attacker.mcCount + 1
                    team.mcCount = team.mcCount + 1
                end
            end
        end
    end
    
    -- 通用释放光影
    if skillD["skillcart"] == 1 then
        if not BC.jump then
            objLayer:playEffect_hit1("front"..camp.."_commoncast", true, true, attacker, 2, 0.35)
        end
        delayCall(0.3, self, function()  
            if not BC.jump then
                objLayer:playEffect_skill1("back"..camp.."_commoncast", caster.x, caster.y, false, true, nil, 0.7)
            end
        end)
    end

    -- 声音
    if not BC.jump then 
        local sk_sound = skillD["sk_sound"]
        if sk_sound then
            for i = 1, #sk_sound do
                ScheduleMgr:delayCall(sk_sound[i][2] * 50, self, function()
                    audioMgr:playSound(sk_sound[i][1])
                end)
            end
        end
    end

    -- 出手延迟
    local beginFlyTick = 0
    if skillD["calculation"] then
        if useAttackInv and not skillD["strict"] then
            beginFlyTick = skillD["calculation"] * actionInv
            if attacker.atkInv < beginFlyTick then
                beginFlyTick = attacker.atkInv
            end
        else
            beginFlyTick = skillD["calculation"] * actionInv
        end
    end
    -- 选择圆心点
    if skillD["pointkind"] then
        local points = self:getSkillPoint(caster, 
            skillD["pointrange"], skillD["pointkind"], skillD["pointcount"], hitter)
        -- print(skillD["id"], #points, "points")
        if #points == 0 then return false end

        local update = false
        delayCall(beginFlyTick, self, function()  
            -- if attacker.die then return end

            local point, dis
            local flytick = {}
            -- 飞行光影
            if skillD["fly"] then
                local flytype = skillD["flytype"]
                for i = 1, #points do
                    point = points[i]
                    dis = sqrt((point.x - attacker.x) * (point.x - attacker.x) + (point.y - attacker.y) * (point.y - attacker.y))
                    flytick[i] = getBulletFlyTime(flytype, skillD["flyspeed"], dis)
                    if not BC.jump then
                        if skillD["stklocation"] and skillD["stklocation"] == 2 then
                            objLayer:rangeAttackPt2(
                                attacker.team.x, attacker.team.y, 0, 26,
                                point.x, point.y, 0, 0,
                                0, skillD["flyspeed"], flytype, skillD["fly"], dis, skillD["flyscale"])
                        else
                            if point.ID then
                                objLayer:rangeAttack(attacker.ID, point.ID, 0, skillD["flyspeed"], flytype, skillD["fly"], dis, skillD["flyscale"])
                            else
                                objLayer:rangeAttackPt(attacker.ID, point.x, point.y, 0, skillD["flyspeed"], flytype, skillD["fly"], dis, skillD["flyscale"])
                            end
                        end
                    end
                end
            else
                for i = 1, #points do
                    flytick[i] = 0
                end
            end
            local scale
            if skillD["stkscale"] then
                scale = skillD["stkscale"] * 0.01
            end
            local delaystk = 0
            if skillD["delaystk"] then
                delaystk = skillD["delaystk"] * 0.001
            end

            -- 挂图腾
            if skillD["objectid"] then
                local totemD = tab.object[skillD["objectid"]]
--                totemD._nSkillID = skillD.id      b表中数据不能改    
                if attacker and attacker.team then
                    BC.ObjectParentSkillId[attacker.team.ID] = {}
                    BC.ObjectParentSkillId[attacker.team.ID][skillD["objectid"]] = skillD.id
                end
                local _delay = totemD["objectdelay"]
                if _delay == nil then
                    _delay = 0
                end
                local _forceAddTime = totemD["addtime"] -- 强制延时 暂用于开场技能
                if skillD["kind"] ~= 7 then -- 开场技能不能延迟
                    local __delay = _delay * actionInv
                    if totemD["objecttype"] == 2 then
                        for i = 1, #points do
                            delayCall(__delay + flytick[i], self, function()
                                self:addTotemToSoldier(totemD, level, attacker, points[i])
                            end)
                        end
                    else
                        for i = 1, #points do
                            delayCall(__delay + flytick[i], self, function()
                                self:addTotemToPos(totemD, level, attacker, points[i].x, points[i].y)
                            end)
                        end
                    end
                else
                    if _forceAddTime then
                        local __delay = _forceAddTime * actionInv
                        if totemD["objecttype"] == 2 then
                            for i = 1, #points do
                                delayCall(__delay, self, function()
                                    self:addTotemToSoldier(totemD, level, attacker, points[i])
                                end)
                            end
                        else
                            for i = 1, #points do
                                delayCall(__delay, self, function()
                                    self:addTotemToPos(totemD, level, attacker, points[i].x, points[i].y)
                                end)
                            end
                        end
                    else
                        if totemD["objecttype"] == 2 then
                            for i = 1, #points do
                                self:addTotemToSoldier(totemD, level, attacker, points[i])
                            end
                        else
                            for i = 1, #points do
                                self:addTotemToPos(totemD, level, attacker, points[i].x, points[i].y)
                            end
                        end
                    end
                end
            end
            if skillD["objectid1"] then
                local objs = skillD["objectid1"]
                for i = 1, #objs do
                    local x, y, oid = objs[i][1], objs[i][2], objs[i][3]
                    if camp == 2 then
                        x = -x
                    end
                    local totemD = tab.object[oid]
--                    totemD._nSkillID = skillD.id
                    if attacker and attacker.team then
                        BC.ObjectParentSkillId[attacker.team.ID] = {}
                        BC.ObjectParentSkillId[attacker.team.ID][skillD["objectid1"]] = skillD.id
                    end
                    local _delay = totemD["objectdelay"]
                    if _delay == nil then
                        _delay = 0
                    end
                    local _forceAddTime = totemD["addtime"] -- 强制延时 暂用于开场技能
                    if skillD["kind"] ~= 7 then -- 开场技能不能延迟   
                        local __delay = _delay * actionInv             
                        for k = 1, #points do
                            delayCall(__delay + flytick[k], self, function()  
                                self:addTotemToPos(totemD, level, attacker, points[k].x + x, points[k].y + y)
                            end)
                        end      
                    else
                        if _forceAddTime then
                            local __delay = _forceAddTime * actionInv
                            for k = 1, #points do
                                delayCall(__delay, self, function()
                                    self:addTotemToPos(totemD, level, attacker, points[k].x + x, points[k].y + y)
                                end)
                            end
                        else
                            for k = 1, #points do
                                self:addTotemToPos(totemD, level, attacker, points[k].x + x, points[k].y + y)
                            end
                        end
                    end
                end
            end

            for i = 1, #points do
                local point = points[i] --point就是soldier
                delayCall(flytick[i] + (i - 1) * delaystk, self, function()
                    -- 方阵死亡就取消效果
                    if attacker.team.state == ETeamStateDIE and not forceSkill then
                        return
                    end
                    if not attacker.canSkill and not forceSkill then
                        return
                    end
                    local ptx, pty = point.x, point.y
                    -- 通用技能光影
                    if skillD["cstktype"] then
                        local _x, _y
                        if point.team then
                            _x = point.team.x
                            _y = point.team.y
                        else
                            _x, _y = ptx, pty
                        end
                        if not BC.jump then
                            objLayer:playEffect_skill1("quan"..camp.."_commoncast", _x, _y, false, true, nil, 1.6)
                            objLayer:playEffect_skill1("buff"..camp.."-"..skillD["cstktype"].."_commoncast", _x, _y, true, true, nil, 1.6)
                            if skillD["cstk"] then
                                objLayer:playCommonBuff(skillD["cstk"], camp, _x, _y)
                            end
                        end

                        local adcstk = skillD["adcstk"]
                        if adcstk then
                            for i = 1, #adcstk do
                                delayCall(i * 0.25, self, function()
                                    if not BC.jump then
                                        objLayer:playCommonAttr(adcstk[i], camp, _x, _y)
                                    end
                                end)
                            end
                        end
                    end
                    if not BC.jump then
                        -- 技能光影
                        -- 真正到出光影的时候再确定方向
                        local _direct = attacker.direct
                        if skillD["frontstk_v"] then
                            objLayer:playEffect_skill1(skillD["frontstk_v"], ptx, pty, true, true, _direct, scale, nil, skillD["stkpoint"], attacker)
                        end
                        if skillD["frontstk_h"] then
                            objLayer:playEffect_skill1(skillD["frontstk_h"], ptx, pty, true, false, _direct, scale, nil, skillD["stkpoint"], attacker)
                        end
                        if skillD["backstk_v"] then
                            objLayer:playEffect_skill1(skillD["backstk_v"], ptx, pty, false, true, _direct, scale, nil, skillD["stkpoint"], attacker)
                        end
                        if skillD["backstk_h"] then
                            objLayer:playEffect_skill1(skillD["backstk_h"], ptx, pty, false, false, _direct, scale, nil, skillD["stkpoint"], attacker)
                        end         
                    end

                    for k = 1, 2 do
                        local targets
                        -- local tempTargets
                        local rangetype
                        local buffid, buff, pro
                        local ranbuffids = {}
                        rangetype = skillD["rangetype"..k]
                        if rangetype == nil then 
                            break 
                        end
                        local hitTick = 0
                        if skillD["delay"..k] then
                            hitTick = skillD["delay"..k] * actionInv
                        end
                        delayCall(hitTick, self, function()
                            -- 震动
                            if skillD["shake"..k] then
                                self:shake(skillD["shake"..k])
                            end
                        end, not ing)
                        -- 目标选择
                        targets = self:getSkillTargets(ptx, pty, point, caster, rangetype, skillD["range"..k], skillD["target"..k], skillD["count"..k], camp, skillD["damagekind"..k] == 5)
                        -- print(skillD["id"], #targets, "targets", ptx, pty)
                        --[[
                        -- 规避召唤物
                        if #targets > 0 and skillD["avoidSummon"] and 0 ~= skillD["avoidSummon"] then
                            tempTargets = self:filterTargetsBySummon(targets)                            
                            if tempTargets then
                                targets = tempTargets
                            end
                        end
                        ]]
                        if #targets > 0 then
                            delayCall(hitTick, self, function()
                                -- 方阵死亡就取消效果
                                if attacker.team.state == ETeamStateDIE and not forceSkill then
                                    return
                                end
                                if not attacker.canSkill and not forceSkill then
                                    return
                                end
                                -- 特效
                                if not BC.jump then
                                    -- 受击声音
                                    local sk_sound = skillD["sk_sound2"]
                                    if sk_sound then
                                        for i = 1, #sk_sound do
                                            ScheduleMgr:delayCall(sk_sound[i][2] * 50, self, function()
                                                audioMgr:playSound(sk_sound[i][1])
                                            end)
                                        end
                                    end

                                    local scale
                                    if skillD["impscale"..k] then
                                        scale = skillD["impscale"..k] * 0.01
                                    end
                                    if skillD["implocation"..k] == 1 then
                                        -- 目标点特效
                                        local pos = skillD["hitplace"..k]
                                        if skillD["frontimp_v"..k] then
                                            local res = skillD["frontimp_v"..k]
                                            for t = 1, #targets do
                                                objLayer:playEffect_hit1(res, true, true, targets[t], pos, scale)
                                            end
                                        end
                                        if skillD["frontimp_h"..k] then
                                            local res = skillD["frontimp_h"..k]
                                            for t = 1, #targets do
                                                objLayer:playEffect_hit1(res, true, false, targets[t], pos, scale)
                                            end
                                        end
                                        if skillD["backimp_v"..k] then
                                            local res = skillD["backimp_v"..k]
                                            for t = 1, #targets do
                                                objLayer:playEffect_hit1(res, false, true, targets[t], pos, scale)
                                            end
                                        end
                                        if skillD["backimp_h"..k] then
                                            local res = skillD["backimp_h"..k]
                                            for t = 1, #targets do
                                                objLayer:playEffect_hit1(res, false, false, targets[t], pos, scale)
                                            end
                                        end
                                        if skillD["frontlink"..k] and #targets > 1 then
                                            local res = skillD["frontlink"..k]
                                            for t = 1, #targets - 1 do
                                                objLayer:playEffect_hit2(res, true, targets[t], targets[t + 1])
                                            end
                                        end
                                        if skillD["backlink"..k] and #targets > 1 then
                                            local res = skillD["backlink"..k]
                                            for t = 1, #targets - 1 do
                                                objLayer:playEffect_hit2(res, false, targets[t], targets[t + 1])
                                            end
                                        end
                                        if skillD["link"..k] then
                                            local res = skillD["link"..k]
                                            for t = 1, #targets do
                                                objLayer:playEffect_hit2(res, true, attacker, targets[t])
                                            end
                                        end
                                    else
                                        local scale
                                        if skillD["impscale"..k] then
                                            scale = skillD["impscale"..k] * 0.01
                                        end
                                        -- 目标方阵特效
                                        -- 计算方阵数量
                                        local teams = {}
                                        local list = {}
                                        local team
                                        for t = 1, #targets do
                                            team = targets[t].team
                                            teams[team.ID] = team
                                        end
                                        for _, team in pairs(teams) do
                                            list[#list + 1] = team
                                        end
                                        if skillD["frontimp_v"..k] then
                                            local res = skillD["frontimp_v"..k]
                                            for t = 1, #list do
                                                objLayer:playEffect_skill1(res, list[t].x, list[t].y, true, true, nil, scale)
                                            end
                                        end
                                        if skillD["frontimp_h"..k] then
                                            local res = skillD["frontimp_h"..k]
                                            for t = 1, #list do
                                                objLayer:playEffect_skill1(res, list[t].x, list[t].y, true, false, nil, scale)
                                            end
                                        end
                                        if skillD["backimp_v"..k] then
                                            local res = skillD["backimp_v"..k]
                                            for t = 1, #list do
                                                objLayer:playEffect_skill1(res, list[t].x, list[t].y, false, true, nil, scale)
                                            end
                                        end
                                        if skillD["backimp_h"..k] then
                                            local res = skillD["backimp_h"..k]
                                            for t = 1, #list do
                                                objLayer:playEffect_skill1(res, list[t].x, list[t].y, false, false, nil, scale)
                                            end
                                        end
                                        if skillD["frontlink"..k] and #targets > 1 then
                                            local res = skillD["frontlink"..k]
                                            for t = 1, #list - 1 do                 
                                                objLayer:playEffect_hit2_pt2(res, true, list[t].x, list[t].y, list[t + 1].x, list[t + 1].y)
                                            end
                                        end
                                        if skillD["backlink"..k] and #targets > 1 then
                                            local res = skillD["backlink"..k]
                                            for t = 1, #list - 1 do
                                                objLayer:playEffect_hit2_pt2(res, false, list[t].x, list[t].y, list[t + 1].x, list[t + 1].y)
                                            end
                                        end   
                                        if skillD["link"..k] then
                                            local res = skillD["link"..k]
                                            for t = 1, #list do
                                                objLayer:playEffect_hit2_pt2(res, true, attacker.team.x, attacker.team.y + 40, list[t].x, list[t].y)
                                            end
                                        end            
                                    end
                                end
                                -- 技能效果 --
                                -- 为了节约, 第一个受击到达的时候更新数据
                                if not update then
                                    caster = updateCaster(attacker, self)
                                end
                                -- 受击特效
                                if not BC.jump then
                                    local boom = skillD["beatkart"..k]
                                    if boom then
                                        for t = 1, #targets do
                                            objLayer:rangeHit(targets[t], boom)
                                        end
                                    end
                                end
                                local action = skillD["damagekind"..k]
                                if action then
                                    local muti = skillD["muti"..k]
                                    if muti then
                                        for m = 0, muti[1] - 1 do
                                            delayCall(m * muti[2] * 0.05, self, function ()
                                                self._skillActionFunc[action](self, castTick, caster, targets, skillD, k, level)
                                            end)
                                        end
                                    else
                                        self._skillActionFunc[action](self, castTick, caster, targets, skillD, k, level)
                                    end
                                    if not BC.jump and skillD["hitfly"..k] then
                                        for t = 1, #targets do
                                            if not targets[t].die then
                                                targets[t]:hitFly()
                                            end
                                        end
                                    end
                                end
                                -- 5为图腾
                                if skillD["target"..k] ~= 5 then
                                    -- 上buff
                                    buffid = skillD["buffid"..k]
                                    local buff
                                    if buffid then
                                        pro = skillD["buffpro"..k][1] + skillD["buffpro"..k][2] * (level - 1)
                                        local __count = 0
                                        for t = 1, #targets do
                                            if not targets[t].die and random(100) <= pro then
                                                buff = initSoldierBuff(buffid, level, caster, targets[t], skillD.id)
                                                targets[t]:addBuff(buff)
                                                __count = __count + 1
                                            end
                                        end
                                        if SRData then
                                            if caster.camp == 1 then
                                                local sr = tab.skillBuff[buffid].sr
                                                if sr and __count > 0 then
                                                    if sr == 10 then
                                                        if __count > SRData[452] then SRData[452] = __count end
                                                    elseif sr == 11 then
                                                        if __count > SRData[458] then SRData[458] = __count end
                                                    elseif sr == 12 then
                                                        if __count > SRData[464] then SRData[464] = __count end
                                                        if __count < SRData[465] then SRData[465] = __count end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                    local morale = skillD["morale"..k]
                                    if morale then
                                        local value = morale[1] + (level - 1) * morale[2]
                                        for t = 1, #targets do   
                                            targets[t].team.shiqiValue = targets[t].team.shiqiValue + value
                                        end
                                    end

                                    -- 增减当前目标的方阵的士气值
                                    if skillD["morale"..k] then
                                        local morale = skillD["morale"..k]
                                        if self["changeMorale"..morale[1]] then
                                            self["changeMorale"..morale[1]](self, caster, targets, morale[2] + morale[3] * (level - 1))
                                        end
                                    end

                                    if skillD["ranbuffid"..k] and skillD["ranbuffnum"..k] then
                                        ranbuffids = BC.genRanBuff(skillD["ranbuffid"..k], skillD["ranbuffnum"..k])
                                        if ranbuffids then
                                            local ranbuffid, ranbuff
                                            for i = 1, #ranbuffids do
                                                ranbuffid = ranbuffids[i]
                                                local __count = 0
                                                for t = 1, #targets do
                                                    if not targets[t].die then
                                                        ranbuff = initSoldierBuff(ranbuffid, level, caster, targets[t], skillD.id)
                                                        targets[t]:addBuff(ranbuff)
                                                        __count = __count + 1
                                                    end
                                                end
                                                if SRData then
                                                    if caster.camp == 1 then
                                                        local sr = tab.skillBuff[ranbuffid].sr
                                                        if sr and __count > 0 then
                                                            if sr == 10 then
                                                                if __count > SRData[452] then SRData[452] = __count end
                                                            elseif sr == 11 then
                                                                if __count > SRData[458] then SRData[458] = __count end
                                                            elseif sr == 12 then
                                                                if __count > SRData[464] then SRData[464] = __count end
                                                                if __count < SRData[465] then SRData[465] = __count end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end, not ing)
                        end
                    end
                end, not ing)
            end
        end, not ing)
    end

    -- 怒气/士气/智力
    local anger = skillD["anger"]
    if anger then
        if camp == 1 then  
            if self._heroAttrFunc[anger[1]] then  
                self._heroAttrFunc[anger[1]](self, anger[2] + anger[3] * (level - 1), camp, anger[4])
            end
        else
            if self._heroAttrFunc[angerT[anger[1]]] then
                self._heroAttrFunc[angerT[anger[1]]](self, anger[2] + anger[3] * (level - 1), camp, anger[4])
            end
        end
    end
    return true
end

-- 添加子物体修改地图
function BattleSkillLogic:addSwitchMap(objectId, mapId, posIndex)
    local _table = {objectId, mapId, posIndex}
    table.insert(self._switchMapTable, 1, _table)
    local lowerMapId = nil
--    dump(self._switchMapTable)
    if self._switchMapTable[2] then
        lowerMapId = self._switchMapTable[2][2]
        local totem = self:getTotemId(self._switchMapTable[2][1], self._switchMapTable[2][3])
        if totem and totem.LoopEffectSet then
            totem:LoopEffectSet(true)
        end
    end
    self._control:setMapSceneRes(mapId, lowerMapId, true)
end

-- 添加子物体修改地图
function BattleSkillLogic:delSwitchMap(objectId, totem)
    local bisAnim = false
    for i = #self._switchMapTable, 1, -1 do
        local var = self._switchMapTable[i]
        if var and var[1] == objectId then
            if i == 1 then
                bisAnim = true
                totem:endEffect()
            end
            table.remove(self._switchMapTable, i)
            break
        end
    end
    if self._control then
        if #self._switchMapTable >= 1 then
            local lowerMapId = nil
            if self._switchMapTable[1] then
                lowerMapId = self._switchMapTable[1][2]
                local totem = self:getTotemId(self._switchMapTable[1][1], self._switchMapTable[1][3])
                if totem and totem.LoopEffectSet then
                    totem:LoopEffectSet(false)
                end
            end
            self._control:setMapSceneRes(self._switchMapTable[1][2], lowerMapId, false, bisAnim)
        else
            self._control:setMapSceneRes(nil, nil, false, true)
        end
    end
end

-- 图腾放技能
local BUFF_ID_YUN = 1086
function BattleSkillLogic:totemCastSkill(totem, totemD, level, caster, x, y, yunBuff)
    -- print(self.battleTime, totemD["id"])
    local castTick = self.battleTime
    local rangetype
    local action
    local buffid, buff, pro 
    local ranbuffids = {}
    local direct
    if caster.camp == 2 then
        direct = -1
    end
    if not BC.jump then
        -- 脉冲光影
        if totemD["frontstk_v"] then
            objLayer:playEffect_skill1(totemD["frontstk_v"], x, y, true, true, direct)
        end
        if totemD["frontstk_h"] then
            objLayer:playEffect_skill1(totemD["frontstk_h"], x, y, true, false, direct)
        end
        if totemD["backstk_v"] then
            objLayer:playEffect_skill1(totemD["backstk_v"], x, y, false, true, direct)
        end
        if totemD["backstk_h"] then
            objLayer:playEffect_skill1(totemD["backstk_h"], x, y, false, false, direct)
        end 

        -- 声音
        local sk_sound = totemD["sk_sound"]
        if sk_sound then
            for i = 1, #sk_sound do
                ScheduleMgr:delayCall(sk_sound[i][2] * 50, self, function()
                    audioMgr:playSound(sk_sound[i][1])
                end)
            end
        end
    end

    for k = 1, 2 do
        rangetype = totemD["rangetype"..k]
        if rangetype == nil then break end
        local hitTick = 0
        if totemD["delay"..k] then
            hitTick = totemD["delay"..k] * actionInv
        end
        delayCall(hitTick, self, function()
            -- 震动
            if not BC.jump then
                if totemD["shake"..k] then
                    self:shake(totemD["shake"..k])
                end
            end
        end)
        -- 目标选择
        local range = clone(totemD["range"..k])
        if type(range) == "table" then
            for i = 1, #range do
                range[i] = range[i] * totem.rangePro
            end
        elseif range then
            range = range * totem.rangePro
        end
        local targets = self:getSkillTargets(x, y, totem, caster, rangetype, range, totemD["target"..k], totemD["count"..k], caster.camp, totemD["damagekind"..k] == 5, totemD["dmgarea"])
        -- 特殊条件筛选
        if targets ~= nil and #targets > 0 then
            targets = self:countCharacters(caster, targets, totemD["valid" .. k], totemD["condition" .. k])
        end   
        if #targets > 0 then
            delayCall(hitTick, self, function()
                -- 特效
                if not BC.jump then
                    if totemD["implocation"..k] == 1 then
                        -- 目标点特效
                        local pos = totemD["hitplace"..k]
                        if totemD["frontimp_v"..k] then
                            local res = totemD["frontimp_v"..k]
                            for t = 1, #targets do
                                objLayer:playEffect_hit1(res, true, true, targets[t], pos)
                            end
                        end
                        if totemD["frontimp_h"..k] then
                            local res = totemD["frontimp_h"..k]
                            for t = 1, #targets do
                                objLayer:playEffect_hit1(res, true, false, targets[t], pos)
                            end
                        end
                        if totemD["backimp_v"..k] then
                            local res = totemD["backimp_v"..k]
                            for t = 1, #targets do
                                objLayer:playEffect_hit1(res, false, true, targets[t], pos)
                            end
                        end
                        if totemD["backimp_h"..k] then
                            local res = totemD["backimp_h"..k]
                            for t = 1, #targets do
                                objLayer:playEffect_hit1(res, false, false, targets[t], pos)
                            end
                        end
                        if totemD["frontlink"..k] and #targets > 1 then
                            local res = totemD["frontlink"..k]
                            for t = 1, #targets - 1 do
                                objLayer:playEffect_hit2(res, true, targets[t], targets[t + 1])
                            end
                        end
                        if totemD["backlink"..k] and #targets > 1 then
                            local res = totemD["backlink"..k]
                            for t = 1, #targets - 1 do
                                objLayer:playEffect_hit2(res, false, targets[t], targets[t + 1])
                            end
                        end
                    else
                        -- 目标方阵特效
                        -- 计算方阵数量
                        local teams = {}
                        local list = {}
                        local team
                        for t = 1, #targets do
                            team = targets[t].team
                            teams[team.ID] = team
                        end
                        for _, team in pairs(teams) do
                            list[#list + 1] = team
                        end
                        if totemD["frontimp_v"..k] then
                            local res = totemD["frontimp_v"..k]
                            for t = 1, #list do
                                objLayer:playEffect_skill1(res, list[t].x, list[t].y, true, true)
                            end
                        end
                        if totemD["frontimp_h"..k] then
                            local res = totemD["frontimp_h"..k]
                            for t = 1, #list do
                                objLayer:playEffect_skill1(res, list[t].x, list[t].y, true, false)
                            end
                        end
                        if totemD["backimp_v"..k] then
                            local res = totemD["backimp_v"..k]
                            for t = 1, #list do
                                objLayer:playEffect_skill1(res, list[t].x, list[t].y, false, true)
                            end
                        end
                        if totemD["backimp_h"..k] then
                            local res = totemD["backimp_h"..k]
                            for t = 1, #list do
                                objLayer:playEffect_skill1(res, list[t].x, list[t].y, false, false)
                            end
                        end
                        if totemD["frontlink"..k] and #targets > 1 then
                            local res = totemD["frontlink"..k]
                            for t = 1, #list - 1 do                 
                                objLayer:playEffect_skill2(name, list[t].x, list[t].y, list[t + 1].x, list[t + 1].y, true)
                            end
                        end
                        if totemD["backlink"..k] and #targets > 1 then
                            local res = totemD["backlink"..k]
                            for t = 1, #list - 1 do
                                objLayer:playEffect_skill2(name, list[t].x, list[t].y, list[t + 1].x, list[t + 1].y, false)
                            end
                        end  
                    end  
                end
                -- 技能效果 --
                action = totemD["damagekind"..k]
                if action then

                    -- 技能附带基础的成长
                    local valueaddPro
                    -- 技能附带的动作
                    local ExAction, ExSkillD
                    local heroSkill = totem.heroSkill
                    if heroSkill then
                        if action == 1 then
                            valueaddPro = heroSkill.healBasePro
                            if heroSkill.healExAction then
                                ExAction = heroSkill.healExAction[1]
                                ExSkillD = heroSkill.healExAction[2]
                            end
                        elseif action == 2 then
                            valueaddPro = heroSkill.damageBasePro
                            if heroSkill.damageExAction then
                                ExAction = heroSkill.damageExAction[1]
                                ExSkillD = heroSkill.damageExAction[2]
                            end
                        end
                    end
                    if totemD["overlay"] == 0 then
                        -- 过滤重复伤害
                        local targetsex = {}
                        local index = 1
                        for t = 1, #targets do
                            if not targets[t].isTotem then
                                if targets[t].totemImmune[id] == nil then
                                    targetsex[index] = targets[t]
                                    index = index + 1
                                end
                            else
                                -- 图腾自己
                                targetsex[index] = targets[t]
                                index = index + 1
                            end
                        end
                        -- 受击特效
                        local boom = totemD["beatart"..k]
                        if boom then
                            for t = 1, #targetsex do
                                objLayer:rangeHit(targetsex[t], boom)
                            end
                        end
                        self._skillActionFunc[action](self, castTick, caster, targetsex, totemD, k, level, forceDoubleEffect, nil, totem.skillIndex, totem.castCount, valueaddPro)
                        if ExAction then
                            self._skillActionFunc[ExAction](self, castTick, caster, targetsex, ExSkillD, 1, level, forceDoubleEffect, nil, totem.skillIndex)
                        end
                        local id = totemD["id"]
                        local tick = self.battleTime + totemD["interval"] * 0.001
                        for t = 1, #targetsex do
                            if not targetsex[t].isTotem then
                                targetsex[t].totemImmune[id] = tick
                            end
                        end
                    else
                        -- 受击特效
                        if not BC.jump then
                            local boom = totemD["beatart"..k]
                            if boom then
                                for t = 1, #targets do
                                    objLayer:rangeHit(targets[t], boom)
                                end
                            end
                        end
                        self._skillActionFunc[action](self, castTick, caster, targets, totemD, k, level, totem.forceDoubleEffect, nil, totem.skillIndex, totem.castCount, valueaddPro)
                        if ExAction then
                            self._skillActionFunc[ExAction](self, castTick, caster, targets, ExSkillD, 1, level, forceDoubleEffect, nil, totem.skillIndex)
                        end
                    end
                end
                if totemD["target"..k] ~= 5 then
                    -- 上buff
                    local buff
                    buffid = totemD["buffid"..k]
                    if buffid then
                        pro = totemD["buffpro"..k][1] + totemD["buffpro"..k][2] * (level - 1)
                        local _target
                        local _camp = totem.camp
                        for t = 1, #targets do
                            _target = targets[t]
                            if not _target.die and random(100) <= pro then
                                if totem.isHero then
                                    buff = initPlayerBuff(_camp, buffid, level, _target, 100, totemD["type"] - 1, totem.forceDoubleEffect, totemD.id)
                                    if totemD["calsstag"] ~= 4 and _target.skillTab[35] and _camp == _target.team.camp then
                                        -- 一个技能只会触发一次
                                        local _skillIndex = totem.casterIndex
                                        if _skillIndex then
                                            if _target.team.skillTag_35[_skillIndex] == nil then
                                                _target.team.skillTag_35[_skillIndex] = true
                                                _target:invokeSkill(35)
                                            end
                                        else 
                                            _target:invokeSkill(35)
                                        end
                                    end
                                    -- 魔法天赋 
                                    -- 3 增加持续时间
                                    -- 4 增加持续时间百分比
                                    -- 7 增加护盾效果值
                                    -- 8 增加护盾效果百分比
                                    if BC.H_SkillBookTalent[_camp] and BC.H_SkillBookTalent[_camp]["targetSkills"][totemD.id] then
                                        BattleUtils.countSkillBookTalent(totemD.id, buff, {3, 4, 7, 8}, _camp)
                                        buff.endTick  = buff.duration * 0.001 + BC.BATTLE_BUFF_TICK
                                    end  
                                else    
                                    local _nSkillId = totemD.id
                                    if caster and caster.attacker and caster.attacker.team then
                                        if BC.ObjectParentSkillId[caster.attacker.team.ID] then
                                            _nSkillId = BC.ObjectParentSkillId[caster.attacker.team.ID][totemD.id] or totemD.id
                                        end
                                    end
                                    buff = initSoldierBuff(buffid, level, caster, _target, _nSkillId)
                                end
                                _target:addBuff(buff)
                            end
                        end
                    end

                    if totemD["ranbuffid"..k] and totemD["ranbuffnum"..k] then
                        ranbuffids = BC.genRanBuff(totemD["ranbuffid"..k], totemD["ranbuffnum"..k])
                        if ranbuffids then
                            local ranbuffid, ranbuff
                            for i = 1, #ranbuffids do
                                ranbuffid = ranbuffids[i]
                                local _target
                                local _camp = totem.camp
                                for t = 1, #targets do
                                    _target = targets[t]
                                    if not _target.die then
                                        if totem.isHero then
                                            ranbuff = initPlayerBuff(_camp, ranbuffid, level, _target, 100, totemD["type"] - 1, totem.forceDoubleEffect, totemD.id)
                                            if totemD["calsstag"] ~= 4 and _target.skillTab[35] and _camp == _target.team.camp then
                                                -- 一个技能只会触发一次
                                                local _skillIndex = totem.casterIndex
                                                if _skillIndex then
                                                    if _target.team.skillTag_35[_skillIndex] == nil then
                                                        _target.team.skillTag_35[_skillIndex] = true
                                                        _target:invokeSkill(35)
                                                    end
                                                else 
                                                    _target:invokeSkill(35)
                                                end
                                            end
                                            -- 魔法天赋 
                                            -- 3 增加持续时间
                                            -- 4 增加持续时间百分比
                                            -- 7 增加护盾效果值
                                            -- 8 增加护盾效果百分比
                                            if BC.H_SkillBookTalent[_camp] and BC.H_SkillBookTalent[_camp]["targetSkills"][totemD.id] then
                                                BattleUtils.countSkillBookTalent(totemD.id, ranbuff, {3, 4, 7, 8}, _camp)
                                                ranbuff.endTick  = ranbuff.duration * 0.001 + BC.BATTLE_BUFF_TICK
                                            end  
                                        else
                                            ranbuff = initSoldierBuff(ranbuffid, level, caster, _target, totemD.id)
                                        end
                                        _target:addBuff(ranbuff)
                                    end
                                end
                            end
                        end
                    end
                end
                if yunBuff then
                    -- 上晕眩BUFF
                    local _target
                    for t = 1, #targets do   
                        _target = targets[t]
                        if _target.caster and not _target.die then
                            buff = initSoldierBuff(BUFF_ID_YUN, 1, _target.caster, _target, totemD.id)
                            _target:addBuff(buff)
                        end
                    end
                end
            end)
        end
    end
end

-- 往人身上挂图腾
-- attacker 释放者
-- soldier 挂载者
function BattleSkillLogic:addTotemToSoldier(totemD, level, attacker, soldier, rangePro, forceDoubleEffect, yunBuff, index, inSkill)
    -- print(self.battleTime, totemD["id"], attacker.ID, soldier.ID)
    local posIndex = #self._totems + 1
    local totem = BattleTotem.new(totemD, level, attacker, soldier.x, soldier.y, soldier, index, inSkill, posIndex)
    if rangePro then
        totem.rangePro = rangePro
        totem.isHero = true
    else
        totem.rangePro = 1
        totem.isHero = false
    end
    totem.forceDoubleEffect = forceDoubleEffect
    totem.yunBuff = yunBuff
    totem.casterIndex = attacker.index
    self._totems[posIndex] = totem
    return totem
end

-- 往地上挂图腾
-- attacker 释放者
-- x, y 挂载坐标
local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL
local MAX_SCENE_HEIGHT_PIXEL = BC.MAX_SCENE_HEIGHT_PIXEL
function BattleSkillLogic:addTotemToPos(totemD, level, attacker, x, y, rangePro, forceDoubleEffect, yunBuff, index, inSkill)
    if x < 0 or x > MAX_SCENE_WIDTH_PIXEL or y < 0 or y > MAX_SCENE_HEIGHT_PIXEL then return end
    -- print(self.battleTime, totemD["id"], x, y)
    local posIndex = #self._totems + 1
    local totem = BattleTotem.new(totemD, level, attacker, x, y, nil, index, inSkill, posIndex)
    if rangePro then
        totem.rangePro = rangePro
        totem.isHero = true
    else
        totem.rangePro = 1
        totem.isHero = false
    end
    totem.forceDoubleEffect = forceDoubleEffect
    totem.yunBuff = yunBuff
    totem.casterIndex = attacker.index
    self._totems[posIndex] = totem
    return totem
end

function BattleSkillLogic:updateTotem(canCast)
    local tick = BC.BATTLE_TOTEM_TICK
    if canCast then
        tick = tick + BC.BATTLE_DELTA
        BC.BATTLE_TOTEM_TICK = tick
    end
    for k, totem in pairs(self._totems) do
        if not totem:update(tick) then
            if totem == self._selectTotem then
                self._selectTotem = nil
            end
            
            table.remove(self._totems, k)
        end
    end
    if canCast then
        local totems = self._totems
        for i = 1, #totems do
            totems[i]:updateTotem(tick)
        end
    end
end

function BattleSkillLogic:getTotemId(totemId, nIndexPos)
    for k, totem in ipairs(self._totems) do
--        print(totem._totemD.id, totemId, totem.die)
        if totem and totem._totemD and totem._totemD.id == totemId and not totem.die and nIndexPos == totem._posIndex then
            return totem
        end
    end
    return nil
end


--totemId 子物体Id， nTime 通过时间控制显示 , nCount 消失数量-1 就是全部
function BattleSkillLogic:setDieTotem(totemId, nTime, nCount)
    if self._totems then
        local _nTime = nTime or BC.BATTLE_TOTEM_TICK
        for key, var in ipairs(self._totems) do
            local _nCount = nCount or -1
            if var and var._totemD and var._totemD.id == totemId and not var.die then--and _nTime > var._startTick then
                --下一帧会让这个totem消失
                var:setDie()
--                print("setDieTotem " .. totemId .. " _nCount " .. _nCount, " var._startTick " .. var._startTick .. " _nTime " .. _nTime .. " BATTLE_TOTEM_TICK " .. BC.BATTLE_TOTEM_TICK)
                _nCount = _nCount - 1
                if _nCount == 0 then
                    break
                end
            end
        end
    end
end

function BattleSkillLogic:clearTotemEff()
    for k, totem in pairs(self._totems) do
        totem.eff1 = nil
        totem.eff2 = nil
        totem.eff3 = nil
        totem.eff4 = nil
    end
end

local countDamage_attack = BC.countDamage_attack
local countDamage_heal = BC.countDamage_heal
-- 1.治疗
function BattleSkillLogic:skillAction1(castTick, caster, targets, skillD, k, level, forceDoubleEffect, _, index, castCount, valueaddPro)
    local attacker = caster.attacker
    if attacker then
        if attacker.team.state == ETeamStateDIE then
            return
        end
        if not attacker.canSkill and not skillD["banskill"] then
            return
        end
    end
    local isPlayer = attacker == nil
    local heal
    local pro = 0
    local add = 0
    local maxpro = 0
    local percent = 100
    if caster.paramAdd ~= nil then 
        percent = caster.paramAdd
    end
    local valuepro = skillD["valuepro"..k]
    if valuepro then
        pro = valuepro[1] + valuepro[2] * (level - 1)
    end
    local valueadd = skillD["valueadd"..k]
    if valueadd then
        if valueaddPro then
            add = valueadd[1] * (1 + valueaddPro[1] * 0.01) + valueadd[2] * (level - 1) * (1 + valueaddPro[2] * 0.01)
        else
            add = valueadd[1] + valueadd[2] * (level - 1)
        end
    end
    local camp = caster.camp
    if skillD["calsstag"] == 3 then
        -- 宝物技能需要额外乘以玩家等级
        local playerLevel = BC.PLAYER_LEVEL[camp]
        add = add * playerLevel
    end
    local _maxpro = skillD["maxpro"..k]
    if _maxpro then
        maxpro = _maxpro[1] + _maxpro[2] * (level - 1)
    end
    local _skillIndex = caster.index
    local hurtkind = skillD["hurtkind"..k]
    local value = 0
    local target, dieTick, sameCamp
    local maxhurt
    local maxd
    if isPlayer then
        for i = 1, #targets do
            target = targets[i]
            if not target.die then
                -- 有可能复活重生, 舍弃死之前的治疗
                dieTick = target.dieTick
                if not (dieTick and castTick < dieTick) then
                    if isPlayer then
                        maxhurt = skillD["maxhurt"..k]
                        if maxhurt then
                            maxpro = maxhurt[1] + maxhurt[2] * (level - 1)
                        end
                    end
                    heal = countDamage_heal(caster, target, pro, add, maxpro, hurtkind, percent)

                    -- 魔法天赋:治疗类,针对特定技能
                    if BC.H_SkillBookTalent[camp] and BC.H_SkillBookTalent[camp]["targetSkills"][skillD.id] then
                        -- 5 增加治疗效果值
                        -- 6 增加治疗效果值百分比
                        heal = BattleUtils._countSkillBookTalent(skillD.id, heal, 5, camp)
                        heal = BattleUtils._countSkillBookTalent(skillD.id, heal, 6, camp)
                    end 

                    
                    -- 技能限制最大伤害值
                    if not isPlayer then
                        -- 目标生命比伤害
                        if maxpro > 0 then
                            maxhurt = skillD["maxhurt"..k]
                            if maxhurt then
                                maxd = floor((maxhurt[1] + maxhurt[2] * (level - 1)) * caster.atk * 0.01)
                                if heal > maxd then
                                    heal = maxd
                                end
                            end 
                        end
                    end

                    sameCamp = camp == target.team.camp
                    value = value + target:heal(attacker, heal, not sameCamp)

                    if tab.object[skillD.id] then
                        -- 如果是子物体技能 没有延迟帧的概率 强制释放
                        if skillD["type"] ~= 8 and sameCamp and target.skillTab[35] then
                            -- 一个技能只会触发一次
                            if _skillIndex then
                                if target.team.skillTag_35[_skillIndex] == nil then
                                    target.team.skillTag_35[_skillIndex] = true
                                    target:invokeSkill(35, nil, nil, true)
                                end
                            else 
                                target:invokeSkill(35, nil, nil, true)
                            end
                        end
                    else
                        if skillD["type"] ~= 8 and sameCamp and target.skillTab[35] then
                            -- 一个技能只会触发一次
                            if _skillIndex then
                                if target.team.skillTag_35[_skillIndex] == nil then
                                    target.team.skillTag_35[_skillIndex] = true
                                    target:invokeSkill(35)
                                end
                            else 
                                target:invokeSkill(35)
                            end
                        end
                    end 

                    if attacker then
                        BattleTeam_addHeal(attacker.team, heal)
                    end
                end
            end
        end
    else
        local realHeal
        for i = 1, #targets do
            target = targets[i]
            if not target.die then
                -- 有可能复活重生, 舍弃死之前的治疗
                dieTick = target.dieTick
                if not (dieTick and castTick < dieTick) then
                    heal = countDamage_heal(caster, target, pro, add, maxpro, hurtkind, percent)
                    realHeal, dontCount = target:heal(attacker, heal, camp ~= target.team.camp)
                    value = value + realHeal
                    if attacker and not dontCount then
                        BattleTeam_addHeal(attacker.team, heal)
                    end
                end
            end
        end
    end
    if _skillIndex then
        self:playerSkillCount(_skillIndex, value, value, caster.skillid, camp, caster.sindex, caster.dpsshow == 1)
    end
end
-- 2.伤害
local ATTR_RPhysics = BC.ATTR_RPhysics
-- castCount 为图腾多次伤害，用于限制伤害上限用
function BattleSkillLogic:skillAction2(castTick, caster, targets, skillD, k, level, forceDoubleEffect, _, index, castCount, valueaddPro)
    local attacker = caster.attacker
    if attacker then
        if attacker.team.state == ETeamStateDIE then
            return
        end
        if not attacker.canSkill and not skillD["banskill"] then
            return
        end
    end
    local camp = caster.camp
    local skillid = skillD["id"]
    local isPlayer = attacker == nil 
    local damage, crit, dodge
    local hurtValue = 0
    local critSkill = false
    local pro = 0
    local add = 0
    local maxpro = 0
    local percent = 100

    -- skillD中【“iff2”】字段
    -- 在阴森墓穴战斗中，self._heroDamagePro设置为0，所以percent一定为0
    -- paramAdd 默认是 100 * self._heroDamagePro
    if caster.paramAdd ~= nil then 
        percent = caster.paramAdd
    end
    -- 技能效果附加百分比
    local valuepro = skillD["valuepro"..k]
    if valuepro then
        pro = valuepro[1] + valuepro[2] * (level - 1)
    end

    --[[
        伤害类法术不生效 ：加这条是因为某些靠子物体实现的技能本身有附加伤害 pro不一定为0
        当pro不为0的时候伤害值不为0，伤害值为0的时候提示免疫动画
    ]]
    if isPlayer and BattleUtils.NO_DAMAGE[BattleUtils.CUR_BATTLE_TYPE] then
        pro = 0
        percent = 0
    end 

    -- 技能效果附加值
    local valueadd = skillD["valueadd"..k]
    if valueadd then
        if valueaddPro then
            dump(valueaddPro)
            add = valueadd[1] * (1 + valueaddPro[1] * 0.01) + valueadd[2] * (level - 1) * (1 + valueaddPro[2] * 0.01)
        else
            add = valueadd[1] + valueadd[2] * (level - 1)
        end
    end
    if skillD["calsstag"] == 3 then
        -- 宝物技能需要额外乘以玩家等级
        -- 80级以上，收益变成20%
        local playerLevel = BC.PLAYER_LEVEL[camp]
        if playerLevel > 80 then
            add = add * (80 + 0.2 * (playerLevel - 80))
        else
            add = add * playerLevel
        end
    end
    local _maxpro = skillD["maxpro"..k]
    if _maxpro then
        maxpro = _maxpro[1] + _maxpro[2] * (level - 1)
    end
    local srCount
    if SRData then
        srCount = (attacker and attacker.team.camp == 2 and not attacker.boss)
    end
    local diekind = skillD["dieart"]
    local hurtkind = skillD["hurtkind"..k] or 2
    local value = 0
    local target, dieTick
    local count = #targets
    local hitmin = 9999999
    local hitmax = 0
    local critmin = 9999999
    local critmax = 0
    local maxhurt
    local maxd
    for i = 1, count do
        target = targets[i]
        if target.die then

        else
            -- 有可能复活重生, 舍弃死之前的伤害
            dieTick = target.dieTick
            if not (dieTick and castTick < dieTick) then
                if isPlayer then
                    maxhurt = skillD["maxhurt"..k]
                    if maxhurt then
                        maxpro = maxhurt[1] + maxhurt[2] * (level - 1)
                    end
                end
                damage, crit, dodge, hurtValue = countDamage_attack(self, caster, target, pro, add, maxpro, hurtkind, percent, castCount)

                -- 魔法天赋:伤害类,针对特定技能 add by hxp
                local dk = hurtkind - 1
                if isPlayer and dk < 5 and dk > 0 then
                    if BC.H_SkillBookTalent[camp] and BC.H_SkillBookTalent[camp]["targetSkills"][skillid] then
                        -- 1 附加伤害值
                        -- 2 附加伤害值百分比
                        damage = BattleUtils._countSkillBookTalent(skillid, damage, 1, camp)
                        damage = BattleUtils._countSkillBookTalent(skillid, damage, 2, camp)
                    end 
                end 
                
                -- 技能限制最大伤害值
                if not isPlayer then
                    -- 目标生命比伤害
                    if maxpro > 0 then
                        maxhurt = skillD["maxhurt"..k]
                        if maxhurt then
                            local _maxHurt = maxhurt[1] + maxhurt[2] * (level - 1)
                            if target then
                                local immuneTeamAttackPro = target._immuneTeamAttackPro
                                if immuneTeamAttackPro and immuneTeamAttackPro > 0 and (_maxHurt + 0.00000001) > immuneTeamAttackPro then
                                    --这个时候说明是百分比伤害
                                    _maxHurt = immuneTeamAttackPro
                                    if XBW_SKILL_DEBUG then print(os.clock(), "限制免疫兵团最高伤害百分比",  immuneTeamAttackPro) end
                                end
                            end
                            maxd = floor(_maxHurt * caster.atk * 0.01)
                            if damage > maxd then
                                damage = maxd
                            end
                            if hurtValue > maxd then
                                hurtValue = maxd
                            end
                        end 
                    end
                end
                if attacker and attacker.noDamage then
                    damage = 0
                    hurtValue = 0
                end
                if not crit and forceDoubleEffect then
                    damage = damage * 2
                    crit = true
                end
                if SRData then
                    -- 统计最大最小的暴击和非暴击
                    if damage ~= 0 then
                        if crit then
                            if damage > critmax then critmax = damage end
                            if damage < critmin then critmin = damage end
                        else
                            if damage > hitmax then hitmax = damage end
                            if damage < hitmin then hitmin = damage end
                        end
                    end
                end
                -- print(damage, skillD["id"], pro, add, maxpro, percent)
                if dodge then
                    if not BATTLE_PROC then target:HPanim_miss() end
                    if SRData then
                        if srCount then
                            SRData[378] = SRData[378] + 1
                        end
                    end
                else
                    if attacker and crit then
                        critSkill = true
                        attacker:HPanim_crit()
                    end

                    -- dontCount 为是否不计入伤害统计
                    local realDamage, dontCount, avoidDamage
                    local _kind = skillD["kind"]
                    if _kind and (_kind >= 4 and _kind <= 6) then 
                        -- 受击技能不能继续触发技能
                        realDamage, dontCount, avoidDamage = target:beDamaged(attacker, -damage, crit, hurtkind, diekind, camp == target.team.camp, skillid)
                        avoidDamage = avoidDamage or 0
                    else
                        realDamage, dontCount, avoidDamage = target:rap(attacker, -damage, crit, dodge, hurtkind, diekind, camp == target.team.camp, isPlayer, skillid)
                        avoidDamage = avoidDamage or 0
                    end
                    value = value + realDamage
                    -- hurtValue  减伤前
                    -- realDamage 减伤后
                    BattleTeam_addHurt(target.team, hurtValue, -realDamage)
                    if attacker then
                        local team = attacker.team
                        target.beDamageType = team.atkType
                        if target.die then
                            -- 法术击杀技能
                            if attacker.skillTab[17] then
                                attacker:invokeSkill(17)
                            end
                        end
                        -- 战斗统计
                        if not dontCount then
                            -- hurtValue  减伤前
                            -- realDamage 减伤后
                            local _nSkillId = skillD["id"]
                            if attacker and attacker.team then
                                if BC.ObjectParentSkillId[attacker.team.ID] then
                                    _nSkillId = BC.ObjectParentSkillId[attacker.team.ID][skillD["id"]] or skillD["id"]
                                end
                            end
                            BattleTeam_addDamage(team, hurtValue, -realDamage, _nSkillId)
                        end

                        if realDamage < 0 and team.canDestroy  and not attacker._isAntiInjury then    
                            -- 吸血/反弹
                            local damage2, avoidDamage2 = BC.formula_vampire_modifier(caster, attacker, target, -realDamage, avoidDamage)
                            avoidDamage2 = avoidDamage2 or 0
                            if damage2 ~= 0 then
                                if not attacker.die then
                                    attacker:beDamaged(attacker, damage2, false, 0)
                                end
                                if damage2 > 0 then
                                    -- 吸血
                                    BattleTeam_addHeal(team, damage2)
                                else
                                    -- 反弹
                                    BattleTeam_addDamage(target.team, -(damage2 + avoidDamage2), -(damage2 + avoidDamage2))
                                end
                            end
                        end
                    end
                    if SRData then
                        if srCount then
                            SRData[377] = SRData[377] + 1
                        end
                    end
                end
            end
        end
    end
    if critSkill then
        -- 触发暴击技能
        if attacker.skillTab[3] then
            attacker:invokeSkill(3)
        end
    end
    if caster.index then
        if SRData then
           if camp == 1 and caster.weaponSkillIndex == nil then
                local baseIndex = 126 + (index - 1) * 10
                -- 伤害总次数
                baseIndex = baseIndex + 3
                SRData[baseIndex] = SRData[baseIndex] + count
                baseIndex = baseIndex + 1
                if hitmax ~= 0 and hitmax > SRData[baseIndex] then SRData[baseIndex] = hitmax end
                baseIndex = baseIndex + 1
                if hitmin ~= 9999999 and hitmin < SRData[baseIndex] then SRData[baseIndex] = hitmin end
                baseIndex = baseIndex + 1
                if critmax ~= 0 and critmax > SRData[baseIndex] then SRData[baseIndex] = critmax end
                baseIndex = baseIndex + 1
                if critmin ~= 9999999 and critmin < SRData[baseIndex] then SRData[baseIndex] = critmin end
                -- 最大数量
                baseIndex = baseIndex + 1
                if count > SRData[baseIndex] then SRData[baseIndex] = count end
                -- 总伤害
                baseIndex = baseIndex + 1
                SRData[baseIndex] = SRData[baseIndex] - value
           end 
        end
        -- 玩家法术免伤前伤害需要乘以目标个数
        hurtValue = hurtValue * count 
        self:playerSkillCount(caster.index, value, hurtValue, caster.skillid, camp, caster.sindex, caster.dpsshow == 1)
    end
    return value
end
-- 3.召唤
function BattleSkillLogic:skillAction3(castTick, caster, targets, skillD, k, _level, forceDoubleEffect, summonAdd)
    local num = skillD["summonnum"..k]
    local level = _level
    local summonlevel = skillD["summonlevel"..k]
    if summonlevel then
        level = floor(summonlevel[1] + summonlevel[2] * (_level - 1))
    end
    local number = num[1] + num[2] * (level - 1)
    local camp = caster.camp
    local H_DE_3 = BC.H_DE_3[camp]
    
    local dk = 0
    if skillD["type"] then
        dk = skillD["type"] - 1
    end
    local doubleEffect = false
    if summonAdd == nil then
        summonAdd = 0
    end
    local pro = 0
    if dk < 5 then
        if dk > 0 then
            pro = H_DE_3[dk] + H_DE_3[5]
        end
    end
    for i = 1, #targets do
        if pro > 0 then
            doubleEffect = (random(100) <= pro) 
        end
        if doubleEffect or forceDoubleEffect then
            local x = 10 + random(20)
            local y = 10 + random(20)
            if camp == 1 then
                self:summonTeam(caster, skillD, skillD["summon"..k], dk, number + summonAdd, level, targets[i].x + x, targets[i].y + y)
                self:summonTeam(caster, skillD, skillD["summon"..k], dk, number + summonAdd, level, targets[i].x - x, targets[i].y - y)
            else
                self:summonTeam(caster, skillD, skillD["summon"..k], dk, number + summonAdd, level, targets[i].x - x, targets[i].y + y)
                self:summonTeam(caster, skillD, skillD["summon"..k], dk, number + summonAdd, level, targets[i].x + x, targets[i].y - y)
            end
        else
            self:summonTeam(caster, skillD, skillD["summon"..k], dk, number + summonAdd, level, targets[i].x, targets[i].y)
        end
    end
end
-- 4.驱散
function BattleSkillLogic:skillAction4(castTick, caster, targets, skillD, k, level)
    local dispellevel = skillD["dispellevel"..k]
    if targets[1].isTotem then
        -- 驱散图腾
        if skillD["dispel"..k] == 3 then
            for i = 1, #targets do
                if dispellevel >= targets[i].strength then
                    targets[i].die = true
                end
            end
        else
            if targets[i].camp ~= caster.camp then
                if dispellevel >= targets[i].strength then
                    targets[i].die = true
                end
            end
        end
    else
        if skillD["dispel"..k] == 1 then
            -- 驱散我方不利
            for i = 1, #targets do
                targets[i]:dispelBuff(false, true, dispellevel)
            end
        elseif skillD["dispel"..k] == 2 then
            -- 驱散敌方有利
            for i = 1, #targets do
                targets[i]:dispelBuff(true, false, dispellevel)
            end
        else
            -- 都驱散
            local camp = caster.camp
            for i = 1, #targets do
                if targets[i].team.camp == camp then
                    targets[i]:dispelBuff(false, true, dispellevel)
                else
                    targets[i]:dispelBuff(true, false, dispellevel)
                end
            end
        end
    end
end
-- 5.复活
function BattleSkillLogic:skillAction5(castTick, caster, targets, skillD, k, level)
    local pro, maxpro, valuepro
    for i = 1, #targets do
        maxpro = skillD["maxpro"..k]
        if maxpro then
            pro = maxpro[1] + maxpro[2] * (level - 1)
        else
            valuepro = skillD["valuepro"..k]
            if valuepro then
                pro = valuepro[1] + valuepro[2] * (level - 1)
            else
                pro = 100
            end
        end

        -- 防止策划新手乱配导致 target只是一个坐标点
        if targets[i]["setRevive"] then
             targets[i]:setRevive(false, pro)
        end 
    end
end

local ATTR_RAll = BC.ATTR_RAll
local ATTR_Atk = BC.ATTR_Atk
local ATTR_HP = BC.ATTR_HP
local getRowIndex = BC.getRowIndex
-- 7.复制
function BattleSkillLogic:skillAction7(castTick, caster, targets, skillD, k, level)
    local targetTeam = targets[1].team
    local targetInfo = targetTeam.info
    local x, y = targets[1].x, targets[1].y
    local info = {}
    for k, v in pairs(targetInfo) do
        info[k] = v
    end
    info.number = #targets
    info.summon = true
    local team = BattleTeam.new(caster.camp)  
    team.copy = true 
    local now = self.battleTime
    local lasttime = skillD["duplitime"..k]
    if lasttime then
        local time = (lasttime[1] + lasttime[2] * (level - 1)) * 0.001
        -- 寿命中止时间
        team.lifeOverTime = now + time
        -- 寿命总时间
        team.lifeTime = time
    end
    if targetTeam.DType == 1 then
        BC.initTeamAttr_Common(team, self._heros[caster.camp], info, x, y)
    else
        BC.initTeamAttr_Npc(team, self._heros[caster.camp], info, x, y)
    end
    if caster.attacker then
        self:addTeam(team, caster.attacker.team.row)
    else
        -- 玩家召唤
        self:addTeam(team, getRowIndex(team.y) + 4)
    end
    local count = team.number
    local duplidmg = -200
    local sduplidmg = skillD["duplidmg"..k]
    if sduplidmg then
        duplidmg = -((sduplidmg[1] + (level - 1) * sduplidmg[2]) - 100)
    end
    local dupliatk = targets[1].baseAttr[ATTR_Atk]
    local sdupliatk = skillD["dupliatk"..k]
    if sdupliatk then
        dupliatk = (sdupliatk[1] + (level - 1) * sdupliatk[2]) * targets[1].baseAttr[ATTR_Atk] * 0.01
    end
    if targetTeam.copy then
        duplidmg = 0
        dupliatk = targets[1].baseAttr[ATTR_Atk]
    end

    
                                                
    local buff
    local soldier
    for k = 1, count do
        soldier = team.soldier[k]
        soldier.x, soldier.y = x, y
        soldier.baseAttr[ATTR_RAll] = duplidmg
        soldier.baseAttr[ATTR_Atk] = dupliatk
        soldier.baseSum = nil
        soldier:resetAttr()
        buff = initSoldierBuff(10003, 1, soldier.caster, soldier)
        soldier:addBuff(buff)
        -- if not BC.jump and not BATTLE_PROC and team.isOneBirth and soldier then
        --     --针对有出生动画的的兵团(这个时候丢弃出生动画)
        --     objLayer:setVisible(soldier.ID, true)
        -- end
    end
    team.isOneBirth = false
    team.summonTick = floor(now)
    team.posDirty = 99
    team.dynamicCD = self.dynamicCD
    team.dynamicPreCD = now + random(self.dynamicCD)
    self:addToUpdateList(team)
    team:invokeSkill7()
end
-- 8.传送 打本面
function BattleSkillLogic:skillAction8(castTick, caster, targets, skillD, k, level)
    local attacker = caster.attacker
    if not attacker or attacker.die then return end
    
    local targetTeam = targets[1].team
    local team = attacker.team
    local x, y
    if #targetTeam.aliveSoldier == 1 then
        x, y = targets[1].x, targets[1].y
        local teamR = attacker.radius
        local targetR = targets[1].radius
        if attacker.x < x then
            x = x - (teamR + targetR )
        else
            x = x + (teamR + targetR)
        end
    else
        x, y = targetTeam.x, targetTeam.y
    end
    local soldiers = team.aliveSoldier
    local _soldier
    for i = 1, #soldiers do
        _soldier = soldiers[i]
        _soldier:stopMove()
        _soldier:setPos(x, y)
        _soldier.fightPtX = nil
        _soldier.fightPtY = nil
    end
    team:update(BC.BATTLE_TICK, 0, false)
    
    self:attackToTarget(team, targetTeam)
    team:setTargetT(targetTeam)
    team:setState(ETeamState.ATTACK)
    -- print("skillD ", skillD["id"])
    if skillD and skillD["id"] == 6890006 then
        --死骑强制位移技能，应策划需求强制修改，死骑突击模式
        if team then
            -- print("team.rush ", team.rush)
            team.rush = 3
        end
    end

end

-- 9.复活
function BattleSkillLogic:skillAction9(castTick, caster, targets, skillD, k, level)
    for i = 1, #targets do
        targets[i].reviveHPPro = skillD["maxpro"..k][1] + skillD["maxpro"..k][2] * (level - 1)
    end
end

-- 10.传送 打正面
function BattleSkillLogic:skillAction10(castTick, caster, targets, skillD, k, level)
    local attacker = caster.attacker
    if not attacker or attacker.die then return end
    
    local targetTeam = targets[1].team
    local team = attacker.team
    local x, y
    if #targetTeam.aliveSoldier == 1 then
        x, y = targets[1].x, targets[1].y
        local teamR = attacker.radius
        local targetR = targets[1].radius
        if attacker.x < x then
            x = x + (teamR + targetR)
        else
            x = x - (teamR + targetR)
        end
    else
        x, y = targetTeam.x + 120, targetTeam.y
    end
    local soldiers = team.aliveSoldier
    local _soldier
    for i = 1, #soldiers do
        _soldier = soldiers[i]
        _soldier:stopMove()
        _soldier:setPos(x, y)
        _soldier.fightPtX = nil
        _soldier.fightPtY = nil
    end
    team:update(BC.BATTLE_TICK, 0, false)
    
    self:attackToTarget(team, targetTeam)
    team:setTargetT(targetTeam)
    team:setState(ETeamState.ATTACK)
end

-- 11.斩杀(尽量不要使用，避免破话游戏的平衡)
function BattleSkillLogic:skillAction11(castTick, caster, targets, skillD, k, level)
    for i = 1, #targets do
        if targets[i] and not targets[i].die and targets[i].HPChange then
            -- targets[i]:rap(nil, -9999999999, false, false, 0, 0, true)
            --世界BOSS 斩杀没有效果
            if not targets[i]._worldBoss then
                local damage = ceil(targets[i].HP) * 2 * -1
                targets[i]:HPChange(nil, damage, false, 1, nil, false)
            end
        end
    end
end

local getCellByScenePos = BC.getCellByScenePos
--[[
    101 城堡
    102 壁垒
    103 据点
    104 墓地
    105 地狱
    106 塔楼
    107 地下城 
    108 要塞
    109 元素
]]
-- 根据半径和种类,返回技能圆心列表
-- 圆心表返回的目标点有两个作用：
--[[
     1 当技能damagekind不为空的时候，作为攻击目标的选择
     2 当技能damagekind为空的时候, 且靠子物体实现的时候，会给返回的结果里每一个都加上图腾，然后图腾会单独释放技能
]]
local randomTable = BC.randomTable
--caster, skillD["pointrange"], skillD["pointkind"], skillD["pointcount"], hitter
function BattleSkillLogic:getSkillPoint(caster, range, kind, maxcount, attacker)
    if self._getSkillPointFunc[kind] == nil then
        print("圆心类型没有"..kind)
        return {}
    end
    local list, die = self._getSkillPointFunc[kind](self, caster, attacker)
    -- print(kind, #list, range, maxcount)
    if die == nil then
        die = false
    end
    -- 是否需要进行范围筛选
    if range > 0 then
        local points = {}
        local castx, casty = caster.x, caster.y
        -- local x1, y1 = getCellByScenePos(castx - range, casty - range * 0.5)
        -- local x2, y2 = getCellByScenePos(castx + range, casty + range * 0.5)

        local count = 0
        local listCount = #list
        -- 如果选择目标数量大于待选对象数量, 就不用随机了
        if maxcount < listCount then
            list = randomTable(list)
        end
        local tar, x, y, dis
        for i = 1, listCount do
            tar = list[i]
            if tar.die == die then
                x, y = tar.x, tar.y
                dis = (x - castx) * (x - castx) + (y - casty) * (y - casty)
                if dis <= range * range then
                    count = count + 1
                    points[count] = tar
                    if count >= maxcount then
                        break
                    end
                end
            end
        end
        return points
    else
        local points = {}
        local count = 0
        local listCount = #list
        -- 如果选择目标数量大于待选对象数量, 就不用随机了
        if maxcount < listCount then
            list = randomTable(list)
        end
        local tar, x, y, dis
        for i = 1, listCount do
            tar = list[i]
            if tar.die == die then
                count = count + 1
                points[count] = tar
                if count >= maxcount then
                    break
                end
            end
        end  
        return points
    end
end

-- 1.自己
function BattleSkillLogic:getSkillPoint1(caster)
    local list = {caster.attacker}
    return list, caster.attacker.die
end
-- 2.当前目标
function BattleSkillLogic:getSkillPoint2(caster)
    local list = {caster.attacker.targetS}
    return list
end
-- 3.敌方随机建筑
function BattleSkillLogic:getSkillPoint3(caster)
    local list = self.targetCache[caster.camp][1]
    return list
end
-- 4.敌方随机怪兽
function BattleSkillLogic:getSkillPoint4(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][5]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 5.触发被动技能的攻击者
function BattleSkillLogic:getSkillPoint5(caster, attacker)
    return {attacker}
end
local teams_list = {}
-- 6.随机近战敌方方阵中的随机单位
function BattleSkillLogic:getSkillPoint6(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][6]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 7.随机远程敌方方阵中的随机单位
function BattleSkillLogic:getSkillPoint7(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][7]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 8.距离最近敌方方阵中的随机单位
function BattleSkillLogic:getSkillPoint8(caster)
    local teams = self.targetCache[caster.camp][5]
    local minDis = 99999999
    local team
    local x1, y1 = caster.x, caster.y
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
    if team == nil then
        return {}
    else
        return team.unorderSoldier  
    end
end
-- 9.距离最远敌方方阵中的随机单位
function BattleSkillLogic:getSkillPoint9(caster)
    local teams = self.targetCache[caster.camp][5]
    local maxDis = 0
    local team
    local x1, y1 = caster.x, caster.y
    local x2, y2
    local d
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            x2, y2 = teams[i].x, teams[i].y
            d = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
            if d > maxDis + 0.00000001 then
                maxDis = d
                team = teams[i]
            end
        end
    end
    if team == nil then
        return {}
    else
        return team.unorderSoldier  
    end
end
-- 10.生命最高的敌方方阵随机单位
function BattleSkillLogic:getSkillPoint10(caster)
    local teams = self.targetCache[caster.camp][5]
    local maxHPPro = 0
    local team
    local pro
    local d
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            pro = teams[i].curHP / teams[i].maxHP
            if pro > maxHPPro then
                maxHPPro = pro
                team = teams[i]
            end
        end
    end
    if team == nil then
        return {}
    else
        return team.unorderSoldier  
    end
end
-- 11.生命最低的敌方方阵随机单位
function BattleSkillLogic:getSkillPoint11(caster)
    local teams = self.targetCache[caster.camp][5]
    local minHPPro = 1
    local team
    local pro
    local d
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            pro = teams[i].curHP / teams[i].maxHP
            if pro < minHPPro then
                minHPPro = pro
                team = teams[i]
            end
        end
    end
    if team == nil then
        return {}
    else
        return team.unorderSoldier  
    end
end
-- 12.体型小于自己的敌方方阵随机单位
function BattleSkillLogic:getSkillPoint12(caster)
    local list = {}
    local team
    local volume = caster.volume
    local teams = self.targetCache[caster.camp][5]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            team = teams[i]
            if team.volume < volume then
                list[#list + 1] = team.aliveSoldier[1]
            end
        end
    end
    return list
end
-- 13.体型大于自己的敌方方阵随机单位
function BattleSkillLogic:getSkillPoint13(caster)
    local list = {}
    local team
    local volume = caster.volume
    local teams = self.targetCache[caster.camp][5]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            team = teams[i]
            if team.volume > volume then
                list[#list + 1] = team.aliveSoldier[1]
            end
        end
    end
    return list
end

-- 16.我方所有单位
function BattleSkillLogic:getSkillPoint16(caster)
    local list = self.targetCache[caster.camp][3]
    return list
end
-- 17.敌方所有单位
function BattleSkillLogic:getSkillPoint17(caster)
    local list = self.targetCache[caster.camp][4]
    return list
end
-- 18.全场所有单位
function BattleSkillLogic:getSkillPoint18(caster)
    local list = self.targetCacheAll
    return list
end
-- 19.自身召唤方阵
function BattleSkillLogic:getSkillPoint19(caster)
    local list = {}
    local index = 1
    local team
    for k, v in pairs(caster.attacker.summonTeam) do
        team = v
        for k = 1, #team.aliveSoldier do
            list[index] = team.aliveSoldier[k]
            index = index + 1
        end
    end
    return list
end
-- 20.从属召唤单位
function BattleSkillLogic:getSkillPoint20(caster)
    if caster.attacker.owner then
        return {caster.attacker.owner}
    else
        return {}
    end
end
-- 21.己方近战单位
function BattleSkillLogic:getSkillPoint21(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][8]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 22,己方远程单位
function BattleSkillLogic:getSkillPoint22(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][9]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 23.己方刺客单位
function BattleSkillLogic:getSkillPoint23(caster)
    local list = {}
    local teams = self.targetTeamCacheClass[caster.camp][1]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 24.己方步兵单位
function BattleSkillLogic:getSkillPoint24(caster)
    local list = {}
    local teams = self.targetTeamCacheClass[caster.camp][2]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 25.己方骑兵单位
function BattleSkillLogic:getSkillPoint25(caster)
    local list = {}
    local teams = self.targetTeamCacheClass[caster.camp][3]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 26.己方弓手单位
function BattleSkillLogic:getSkillPoint26(caster)
    local list = {}
    local teams = self.targetTeamCacheClass[caster.camp][4]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 27.己方法师单位
function BattleSkillLogic:getSkillPoint27(caster)
    local list = {}
    local teams = self.targetTeamCacheClass[caster.camp][5]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 28.己方飞行单位
function BattleSkillLogic:getSkillPoint28(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][17]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 29.己方随机怪兽
function BattleSkillLogic:getSkillPoint29(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 31.所在方阵的所有单位
function BattleSkillLogic:getSkillPoint31(caster)
    local list = {}
    local soldiers = caster.attacker.team.aliveSoldier
    for i = 1, #soldiers do
       list[i] = soldiers[i] 
    end
    return list
end
-- 32.己方所有人族单位
function BattleSkillLogic:getSkillPoint32(caster)
    local list = self.targetCacheRace[caster.camp][208]
    return list
end
-- 33.己方所有飞行单位
function BattleSkillLogic:getSkillPoint33(caster)
    local list = self.targetCacheMoveType[caster.camp][2]
    return list
end
-- 34.己方所有射手单位
function BattleSkillLogic:getSkillPoint34(caster)
    local list = self.targetCacheClass[caster.camp][4]
    return list
end
-- 35.己方可复活的方阵
function BattleSkillLogic:getSkillPoint35(caster)
    local list = {}
    local teams = self._teams[caster.camp]
    local team
    for i = 1, #teams do
        team = teams[i]
        if (team.original or team.assistance) and team.state == ETeamStateDIE and not team.reviveing then
            list[#list + 1] = team.soldier[1]
        end
    end
    return list, true
end
-- 36.己方所有输出单位
function BattleSkillLogic:getSkillPoint36(caster)
    local list = self.targetCacheClass[caster.camp][1]
    return list
end
-- 37.对线最后的方阵中随机单位，如果没有则其他线最后的单位  
function BattleSkillLogic:getSkillPoint37(caster)
    local curTarget = caster.attacker.targetS
    if curTarget and not curTarget.die then
        return {curTarget}
    end
    local camp = 3 - caster.camp
    local rowTeam = self._rowTeam[camp]
    local target = nil
    target = self:getRowNearestTeam(rowTeam[caster.attacker.team.row], camp, false)
    if target then
        return {target.aliveSoldier[1]}
    else
        -- 对面行无人, 从其他行找远程目标
        local teams = {}
        for i = 1, 8 do
            if i ~= row then
                target = self:getRowNearestTeam(rowTeam[i], camp, false, nil, true)
                if target then
                    teams[#teams + 1] = target
                end
            end
        end
        if #teams > 0 then
            local list = {}
            for i = 1, #teams do
                list[#list + 1] = teams[i].aliveSoldier[1]
            end
            return list
        else
            -- 如果没有远程了，跳其他人
            local teams = {}
            for i = 1, 8 do
                if i ~= row then
                    target = self:getRowNearestTeam(rowTeam[i], camp, false)
                    if target then
                        teams[#teams + 1] = target
                    end
                end
            end
            local list = {}
            for i = 1, #teams do
                list[#list + 1] = teams[i].aliveSoldier[1]
            end
            return list
        end
    end
end

-- 38.己方生命比例最低方阵中的随机单位 
function BattleSkillLogic:getSkillPoint38(caster)
    local teams = self.targetCache[caster.camp][10]
    local minHPPro = 1
    local team
    local pro
    local d
    local _team
    for i = 1, #teams do
        _team = teams[i]
        if _team.state ~= ETeamStateDIE and not _team.isbuilding then
            pro = _team.curHP / _team.maxHP
            if pro < minHPPro then
                minHPPro = pro
                team = _team
            end
        end
    end
    if team == nil then
        return {}
    else
        return team.unorderSoldier  
    end
end

-- 39.己方输出或防御兵团单位 1 和 2
function BattleSkillLogic:getSkillPoint39(caster)
    local list = {}
    for i = 1, #self.targetCacheClass[caster.camp][1] do
        list[#list + 1] = self.targetCacheClass[caster.camp][1][i]
    end
    for i = 1, #self.targetCacheClass[caster.camp][2] do
        list[#list + 1] = self.targetCacheClass[caster.camp][2][i]
    end
    return list
end

-- 40. 己方所有骷髅单位
function BattleSkillLogic:getSkillPoint40(caster)
    local list = self.targetCache[caster.camp][15]
    return list
end

-- 41. 己方所有地狱单位
function BattleSkillLogic:getSkillPoint41(caster)
    local list = self.targetCache[caster.camp][16]
    return list
end

-- 42. 敌方后排
function BattleSkillLogic:getSkillPoint42(caster)
    local teams = self.targetCache[caster.camp][5]
    local minX = 99999999
    local team
    local x
    if caster.camp == 1 then
        minX = 0
        for i = 1, #teams do
            if teams[i].state ~= ETeamStateDIE then
                x = teams[i].x
                if x > minX + 0.00000001 then
                    minX = x
                    team = teams[i]
                end
            end
        end
    else
        minX = 999999
        for i = 1, #teams do
            if teams[i].state ~= ETeamStateDIE then
                x = teams[i].x
                if x < minX - 0.00000001 then
                    minX = x
                    team = teams[i]
                end
            end
        end
    end
    if team == nil then
        return {}
    else
        return {team.aliveSoldier[1]}
    end
end

-- 43. 距离自己最近的己方兵团
function BattleSkillLogic:getSkillPoint43(caster)
    local teams = self.targetCache[caster.camp][10]
    local minDis = 99999999
    local team
    local x1, y1 = caster.x, caster.y
    local x2, y2
    local d
    local casterTeam
    if caster.attacker then
        casterTeam = caster.attacker.team
    end
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE and casterTeam ~= teams[i] then
            x2, y2 = teams[i].x, teams[i].y
            d = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
            if d < minDis then
                minDis = d
                team = teams[i]
            end
        end
    end
    if team == nil then
        return {}
    else
        return {team.aliveSoldier[1]}
    end
end

-- 44. 距离自己最近的敌方兵团
function BattleSkillLogic:getSkillPoint44(caster)
    local teams = self.targetCache[caster.camp][5]
    local minDis = 99999999
    local team
    local x1, y1 = caster.x, caster.y
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
    if team == nil then
        return {}
    else
        return {team.aliveSoldier[1]}
    end
end

-- 45. 地狱族
function BattleSkillLogic:getSkillPoint45(caster)
    local list = self.targetCacheRace[caster.camp][105]
    return list
end

-- 46. 己方随机地狱兵团
function BattleSkillLogic:getSkillPoint46(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE and teams[i].race1 == 105 then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end
-- 47. 敌方魔法兵团
function BattleSkillLogic:getSkillPoint47(caster)
    local list = self.targetCacheClass[3 - caster.camp][5]
    return list
end

-- 48.己方生命比例最低方阵中的随机单位 (计算剩余兵团数)
function BattleSkillLogic:getSkillPoint48(caster)
    local teams = self.targetCache[caster.camp][10]
    local minHPPro = 1
    local team
    local pro
    local d
    local _team
    for i = 1, #teams do
        _team = teams[i]
        if _team.state ~= ETeamStateDIE and not _team.isbuilding then
            pro = _team.curHP / _team.maxHP / (#_team.aliveSoldier / #_team.soldier)
            if pro < minHPPro then
                minHPPro = pro
                team = _team
            end
        end
    end
    if team == nil then
        return {}
    else
        return team.unorderSoldier  
    end
end

-- 49.己方所有据点单位
function BattleSkillLogic:getSkillPoint49(caster)
    local list = self.targetCacheRace[caster.camp][103]
    return list
end

-- 50.己方据点兵团中的随机单位
function BattleSkillLogic:getSkillPoint50(caster)
    local list = {}
    local teams = self.targetCacheRace[caster.camp][103]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end


-- 51.己方墓园兵团中的所有单位
function BattleSkillLogic:getSkillPoint51(caster)
    local list = self.targetCacheRace[caster.camp][104]
    return list
end

-- 52.己方塔楼兵团中的所有单位
function BattleSkillLogic:getSkillPoint52(caster)
    local list = self.targetCacheRace[caster.camp][106]
    return list
end

-- 53. 己方塔楼兵团
function BattleSkillLogic:getSkillPoint53(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE and teams[i].race1 == 106 then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end

-- 54. 己方墓园兵团
function BattleSkillLogic:getSkillPoint54(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE and teams[i].race1 == 104 then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end


-- 55.己方墓园近战兵团所有单位
function BattleSkillLogic:getSkillPoint55(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][8]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE and teams[i].race1 == 104 then
            local aliveSoldier = teams[i].aliveSoldier
            for m = 1,#aliveSoldier do
                list[#list + 1] = teams[i].aliveSoldier[m]
            end
        end
    end
    return list
end

-- 56.己方地下城兵团中的所有单位
function BattleSkillLogic:getSkillPoint56(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE and teams[i].race1 == 107 then
            local aliveSoldier = teams[i].aliveSoldier
            for m = 1,#aliveSoldier do
                list[#list + 1] = teams[i].aliveSoldier[m]
            end
        end
    end
    return list
end

-- 57.我方随机怪兽
function BattleSkillLogic:getSkillPoint57(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end

-- 58. 己方所有龙单位
function BattleSkillLogic:getSkillPoint58(caster)
    local list = self.targetCache[caster.camp][19]
    return list or {}
end

-- 59.己方所有元素单位
function BattleSkillLogic:getSkillPoint59(caster)
    local list = self.targetCacheRace[caster.camp][109]
    return list or {}
end

-- 60.己方所有非地狱单位
function BattleSkillLogic:getSkillPoint60(caster)
    return {}
end

-- 61.己方所有非地狱兵团
function BattleSkillLogic:getSkillPoint61(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    for i = 1, #teams do
        if teams[i].state ~= ETeamStateDIE and teams[i].race1 ~= 105 then
            list[#list + 1] = teams[i].aliveSoldier[1]
        end
    end
    return list
end

-- 62.己方所有港口兵团（排除自己）
function BattleSkillLogic:getSkillPoint62(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    local attacker = caster.attacker
    if attacker and attacker.team then
        for i = 1, #teams do
            if teams[i] and teams[i].state ~= ETeamStateDIE and teams[i].race1 == 112 and attacker.team.ID ~= teams[i].ID then
                list[#list + 1] = teams[i].aliveSoldier[1]
            end
        end
    end
    return list
end

-- 63.己方所有小于等于4体型的兵团（排除自己）
function BattleSkillLogic:getSkillPoint63(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    local attacker = caster.attacker
    if attacker and attacker.team then
        for i = 1, #teams do
            if teams[i] and teams[i].state ~= ETeamStateDIE and teams[i].volume and teams[i].volume <= 4 and attacker.team.ID ~= teams[i].ID then
                list[#list + 1] = teams[i].aliveSoldier[1]
            end
        end
    end
    return list
end

-- 64.己方非自己的兵团（排除自己）
function BattleSkillLogic:getSkillPoint64(caster)
    local list = {}
    local teams = self.targetCache[caster.camp][10]
    local attacker = caster.attacker
    if attacker and attacker.team then
        for i = 1, #teams do
            if teams[i] and teams[i].state ~= ETeamStateDIE and attacker.team.ID ~= teams[i].ID then
                list[#list + 1] = teams[i].aliveSoldier[1]
            end
        end
    end
    return list
end

-- 
-- 根据半径和种类,返回目标列表
local randomSelect = BC.randomSelect
function BattleSkillLogic:getSkillTargets(x, y, point, caster, rangetype, range, target, count, camp, selectDieSoldier, targetmovetype)
    local targets
    if rangetype == 0 then
        -- 圆心目标
        targets= {point}
    elseif rangetype == 3 then
        -- 圆心目标所在的方阵的小兵
        local soldiers
        if selectDieSoldier then
            soldiers = point.team.dieSoldier
        else
            soldiers = point.team.aliveSoldier
        end
        local maxcount = count[2]
        if maxcount == 0 or maxcount >= #soldiers then
            targets = {}
            for m = 1, #soldiers do
                targets[m] = soldiers[m]
            end
        else
            local arr = randomSelect(#soldiers, count[2])
            targets = {}
            for m = 1, #arr do
                targets[m] = soldiers[arr[m]]
            end
        end
    elseif rangetype == 5 then
        local totem = point
        -- 图腾挂点的小兵的方阵的小兵
        if totem._attacker then
            local team = totem._attacker.team
            if team then
                local soldiers = team.aliveSoldier
                local maxcount = count[2]
                if maxcount == 0 or maxcount >= #soldiers then
                    targets = {}
                    for m = 1, #soldiers do
                        targets[m] = soldiers[m]
                    end
                else
                    local arr = randomSelect(#soldiers, count[2])
                    targets = {}
                    for m = 1, #arr do
                        targets[m] = soldiers[arr[m]]
                    end
                end
            else
                return {}
            end
        else
            return {}
        end
    else
        -- 圆/矩形
        targets = self._getSkillTargetFunc[target](self, x, y, caster, rangetype, range, count, camp, targetmovetype)
    end
    return targets
end
local ETeamStateDIE = BC.ETeamState.DIE

function BattleSkillLogic:filterTargetsBySummon(targets)
    local tempTargets = {}
    for i,v in pairs(targets) do
        local team = v.team
        if team and team.state ~= ETeamStateDIE and not team.summon then
            table.insert(tempTargets, v)
        end
    end
    return tempTargets
end
-- 1.己方方阵
function BattleSkillLogic:getSkillTarget1(x, y, caster, rangetype, range, count, camp, targetmovetype)
    return self:getSkillTargetTeam(self.targetCache[camp][10], x, y, caster, rangetype, range, count, nil, targetmovetype)
end
-- 2.敌方方阵
function BattleSkillLogic:getSkillTarget2(x, y, caster, rangetype, range, count, camp, targetmovetype)
    return self:getSkillTargetTeam(self.targetCache[camp][5], x, y, caster, rangetype, range, count, nil, targetmovetype)
end
-- 3.敌方召唤生物方阵
function BattleSkillLogic:getSkillTarget3(x, y, caster, rangetype, range, count, camp, targetmovetype)
    return self:getSkillTargetTeam(self.targetCache[camp][11], x, y, caster, rangetype, range, count, nil, targetmovetype)
end
-- 挑选方阵
function BattleSkillLogic:getSkillTargetTeam(list, x, y, caster, rangetype, range, count, die, targetmovetype)
    if die then
        local teams = {}
        local index = 1
        for i = 1, #list do
            if list[i].state == ETeamStateDIE then
                teams[index] = list[i]
                index = index + 1
            end
        end
        local maxcount = count[1]
        if maxcount == 0 then
            maxcount = 999
        end
        teams = self._getRangeTargetFunc[rangetype](self, teams, caster, x, y, range, maxcount)
        local targets = {}
        index = 1
        local soldiers
        local maxcount = count[2]
        if maxcount == 0 then
            maxcount = 999
        end
        for i = 1, #teams do
            repeat
                local movetype = teams[i].D.movetype
                if movetype and targetmovetype and 0 ~= targetmovetype and movetype ~= targetmovetype then break end
                local _count = 0
                soldiers = teams[i].unorderSoldier
                for k = 1, #soldiers do
                    if soldiers[k].die then
                        targets[index] = soldiers[k]
                        index = index + 1
                        _count = _count + 1
                    end
                    if _count == maxcount then
                        break
                    end
                end
            until true
        end
        return targets
    else
        local teams = {}
        local index = 1
        for i = 1, #list do
            if list[i].state ~= ETeamStateDIE then
                teams[index] = list[i]
                index = index + 1
            end
        end
        local maxcount = count[1]
        if maxcount == 0 then
            maxcount = 999
        end
        teams = self._getRangeTargetFunc[rangetype](self, teams, caster, x, y, range, maxcount)
        local targets = {}
        index = 1
        local soldiers
        local maxcount = count[2]
        if maxcount == 0 then
            maxcount = 999
        end
        for i = 1, #teams do
            repeat
                local movetype = teams[i].D.movetype
                if movetype and targetmovetype and 0 ~= targetmovetype and movetype ~= targetmovetype then break end
                local _count = 0
                soldiers = teams[i].unorderSoldier
                for k = 1, #soldiers do
                    if not soldiers[k].die then
                        targets[index] = soldiers[k]
                        index = index + 1
                        _count = _count + 1
                    end
                    if _count == maxcount then
                        break
                    end
                end
            until true
        end
        return targets
    end
end
-- 4.所有单位
function BattleSkillLogic:getSkillTarget4(x, y, caster, rangetype, range, count, camp)
    local targets = self.targetCacheAll
    return self._getRangeTargetFunc[rangetype](self, targets, caster, x, y, range, count[2], false)
end
-- 5.子物体
function BattleSkillLogic:getSkillTarget5(x, y, caster, rangetype, range, count)
    local targets = self._totems
    return self._getRangeTargetFunc[rangetype](self, targets, caster, x, y, range, count[2], false)
end
-- 7.己方方阵
function BattleSkillLogic:getSkillTarget7(x, y, caster, rangetype, range, count, camp)
    return self:getSkillTargetTeam(self.targetCache[camp][10], x, y, caster, rangetype, range, count, true)
end
-- 8.己方单位
function BattleSkillLogic:getSkillTarget8(x, y, caster, rangetype, range, count, camp)
    local targets = self.targetCache[camp][3]
    return self._getRangeTargetFunc[rangetype](self, targets, caster, x, y, range, count[2], false)
end
-- 9.敌方单位
function BattleSkillLogic:getSkillTarget9(x, y, caster, rangetype, range, count, camp)
    local targets = self.targetCache[camp][4]
    return self._getRangeTargetFunc[rangetype](self, targets, caster, x, y, range, count[2], false)
end
-- 10.所有召唤物
function BattleSkillLogic:getSkillTarget10(x, y, caster, rangetype, range, count, camp)
    local targets = self.targetCacheSummon
    return self._getRangeTargetFunc[rangetype](self, targets, caster, x, y, range, count[2], false) 
end
-- 11.己方魔法军团
function BattleSkillLogic:getSkillTarget11(x, y, caster, rangetype, range, count, camp)
    local targets = self.targetCacheClass[camp][5]
    return self._getRangeTargetFunc[rangetype](self, targets, caster, x, y, range, count[2], false) 
end
-- 13.敌方建筑
function BattleSkillLogic:getSkillTarget13(x, y, caster, rangetype, range, count, camp)
    return self:getSkillTargetTeam(self.targetCache[camp][18], x, y, caster, rangetype, range, count)
end
-- 14.己方后援单位
function BattleSkillLogic:getSkillTarget14(x, y, caster, rangetype, range, count, camp)
    local targets = self.targetCache[camp][20]
    return self._getRangeTargetFunc[rangetype](self, targets, caster, x, y, range, count[2], false)
end
-- 15.敌方后援单位
function BattleSkillLogic:getSkillTarget15(x, y, caster, rangetype, range, count, camp)
    local targets = self.targetCache[camp][21]
    return self._getRangeTargetFunc[rangetype](self, targets, caster, x, y, range, count[2], false)
end
-- 16.己方后援方阵
function BattleSkillLogic:getSkillTarget16(x, y, caster, rangetype, range, count, camp)
    return self:getSkillTargetTeam(self.targetCache[camp][22], x, y, caster, rangetype, range, count)
end
-- 17.敌方后援方阵
function BattleSkillLogic:getSkillTarget17(x, y, caster, rangetype, range, count, camp)
    return self:getSkillTargetTeam(self.targetCache[camp][23], x, y, caster, rangetype, range, count)
end
-- 1.圆形
local sqrt = math.sqrt
function BattleSkillLogic:getRangeTarget1(list, caster, ptx, pty, range, maxcount, die)
    local targets = {}
    local count = 0
    local listCount = #list
    if maxcount == 0 then
        maxcount = 999
    end
    list = randomTable(list)

    if caster.isCaster then
        -- 玩家技能 用椭圆
        local b = range
        local a = b * 2
        a = a * a
        b = b * b
        local tar, x, y, dx, dy
        for i = 1, listCount do
            tar = list[i]
            if tar.die == die then
                x, y = tar.x, tar.y
                dx = x - ptx
                dy = y - pty
                if dx * dx / a + dy * dy / b < 1.00000001 then
                    count = count + 1
                    targets[count] = tar

                    if count >= maxcount then
                        break
                    end
                end
            end
        end     
    else
        local _range = range + 0.00000001
        local tar, x, y, dis
        for i = 1, listCount do
            tar = list[i]
            if tar.die == die then
                x, y = tar.x, tar.y
                dis = (x - ptx) * (x - ptx) + (y - pty) * (y - pty)
                if sqrt(dis) - tar.radius * 0.5 < _range then
                    count = count + 1
                    targets[count] = tar

                    if count >= maxcount then
                        break
                    end
                end
            end
        end
    end
    return targets
end
-- 2.矩形
function BattleSkillLogic:getRangeTarget2(list, caster, ptx, pty, range, maxcount, die)
    --       ___________________ x2,y2
    --      |                   |
    --      . x, y              |  h
    -- x1,y1|___________________|
    --      方向为英雄面朝方向
    local targets = {}
    local count = 0
    local listCount = #list
    if maxcount == 0 then
        maxcount = 999
    end
    list = randomTable(list)
    local tar, x, y, dis
    local x1, y1, x2, y2
    local w = range[1]
    local h = range[2]
    if w > 0 then
        if caster.attacker and caster.attacker.direct == -1 then
            x1 = ptx - w
            x2 = ptx
            y1 = pty - h * 0.5
            y2 = y1 + h
        else
            x1 = ptx
            x2 = ptx + w
            y1 = pty - h * 0.5
            y2 = y1 + h
        end
    else
        w = -w
        if caster.attacker and caster.attacker.direct == -1 then
            x1 = ptx
            x2 = ptx + w
            y1 = pty - h * 0.5
            y2 = y1 + h
        else
            x1 = ptx - w
            x2 = ptx
            y1 = pty - h * 0.5
            y2 = y1 + h
        end
    end
    x1 = x1 - 0.00000001
    x2 = x2 + 0.00000001
    y1 = y1 - 0.00000001
    y2 = y2 + 0.00000001
    local radius
    for i = 1, listCount do
        tar = list[i]
        radius = tar.radius * 0.5
        if tar.die == die then
            x, y = tar.x, tar.y
            if x > x1 - radius and x < x2 + radius and y > y1 - radius and y < y2 + radius then
                count = count + 1
                targets[count] = tar

                if count >= maxcount then
                    break
                end
            end
        end
    end 
    return targets
end

-- 4. 自身为圆心的矩形
function BattleSkillLogic:getRangeTarget4(list, caster, ptx, pty, range, maxcount, die)
    --       ___________________ x2,y2
    --      |                   |
    --      |         . x, y    |  h
    -- x1,y1|___________________|
    local targets = {}
    local count = 0
    local listCount = #list
    if maxcount == 0 then
        maxcount = 999
    end
    list = randomTable(list)
    local tar, x, y, dis
    local x1, y1, x2, y2
    local w = range[1]
    local h = range[2]

    if w < 0 then
        w = -w
    end
    x1 = ptx - w * 0.5 - 0.00000001
    x2 = x1 + w + 0.00000001
    y1 = pty - h * 0.5 - 0.00000001
    y2 = y1 + h + 0.00000001
    local radius
    for i = 1, listCount do
        tar = list[i]
        radius = tar.radius * 0.5
        if tar.die == die then
            x, y = tar.x, tar.y
            if x > x1 - radius and x < x2 + radius and y > y1 - radius and y < y2 + radius then
                count = count + 1
                targets[count] = tar

                if count >= maxcount then
                    break
                end
            end
        end
    end 
    return targets
end

-- 1. 改变方阵士气值
function BattleSkillLogic:changeMorale1(caster, list, value)
    for t = 1, #list do
        list[t].team.shiqiValue = list[t].team.shiqiValue + value
    end
end

local ATTR_AtkPro = BC.ATTR_AtkPro
local ATTR_HPPro = BC.ATTR_HPPro
local ATTR_Haste = BC.ATTR_Haste
local ATTR_Def = BC.ATTR_Def
local EMotionBORN = EMotion.BORN
function BattleSkillLogic:summonTeam(caster, skillD, npcid, dk, number, level, x, y)
    if x > MAX_SCENE_WIDTH_PIXEL then return end
    if y > MAX_SCENE_HEIGHT_PIXEL then return end
    if x < 0 then return end
    if y < 0 then return end

    local attacker = caster.attacker
    local camp = caster.camp
    local addTeam = nil
    if attacker ~= nil then
        -- 怪兽召唤才合并
        for _, team in pairs(attacker.team.summonTeam) do
            if npcid == team.D["id"] and not team:isFull(number) then
                addTeam = team
                break
            end
        end
    end

    if addTeam == nil then
        local isTreasureSummon = (skillD and skillD["calsstag"] == 3)
        local team = BattleTeam.new(camp)   
        local info = {npcid = npcid, number = number, level = level, summon = true}
        local lv
        local skillLevel
        if attacker then
            lv = attacker.team.level + 9
            -- 召唤物的技能跟着召唤者走
            skillLevel = attacker.team.skillLevels
        else
            if isTreasureSummon then
                lv = BC.PLAYER_LEVEL[camp]
            else
                lv = 1
            end
        end
        
        if attacker then
            -- team.noHUD = true
            BC.initTeamAttr_Npc(team, self._heros[camp], info, x, y, nil, nil, {lv, 0, 0, 0, 1, 0, 0, skillLevel})
            self:addTeam(team, attacker.team.row)
        else
            -- 玩家召唤
            if isTreasureSummon then
                BC.initTeamAttr_Npc(team, self._heros[camp], info, x, y, nil, nil, {lv, 0, 0, 0, 1, 0, 0, skillLevel, skillD})
                self:addTeam(team, getRowIndex(team.y))
            else
                local ap3 = BC.H_AP_3[camp]
                local value = 0
                if ap3[5] then
                    value = ap3[5]
                end

                local atkPro = 0
                local hpPro = 0
                local haste = 0
                local defPro = 1

                if ap3[1] then
                    atkPro = (ap3[1] + value) * 100
                end
                if ap3[2] then
                    defPro = 1 + ap3[2] + value
                end
                if ap3[3] then
                    haste = (ap3[3] + value) * 100
                end
                if ap3[4] then
                    hpPro = (ap3[4] + value) * 100
                end

                local DamageDec = BC.H_SummonTDD[camp]
                local DecAll = BC.H_SummonHDD[camp]
                BC.initTeamAttr_Npc(team, self._heros[camp], info, x, y, nil, nil, {lv, atkPro, hpPro, haste, defPro, DamageDec, DecAll, skillLevel, skillD})
                self:addTeam(team, getRowIndex(team.y) + 4)
            end
        end
        local count = team.number
        local _soldier
        for k = 1, count do
            _soldier = team.soldier[k]
            _soldier.owner = attacker
            _soldier:invokeSkill(44)
        end
        if count == 1 then
            team.soldier[1]:setPos(x, y)
        end
        self:addToUpdateList(team)

        -- 召唤方阵
        if attacker then
            attacker.summonTeam[team.ID] = team
            attacker.team.summonTeam[team.ID] = team
        end
        -- 出生动作,如果会移动,则会被移动动作替换

        local soldier
        for i = 1, #team.soldier do
            soldier = team.soldier[i]
            soldier:changeMotion(1)
            soldier:changeMotion(EMotion.BORN)
        end
        if team.bornTime then
            team:setState(ETeamStateNONE)
            team.canDestroy = false
            team.borning = true
            delayCall(team.bornTime * actionInv, self, function()
                if team.state ~= ETeamStateDIE then
                    team:setState(ETeamStateMOVE)
                end
                team.canDestroy = true
                team.borning = false
            end)
        end
        team.summonTick = floor(self.battleTime)
        team.dynamicCD = self.dynamicCD
        team.dynamicPreCD = self.battleTime + random(self.dynamicCD)
        if self.summonTeamEx then
            self:summonTeamEx(team)
        end
        self:_raceCountAddSum(camp, team.race1, team.race2)
        return team
    else
        addTeam.number = addTeam.number + number
        addTeam:additionSoldiers(x, y)

        local _soldier
        for i = addTeam.number - number + 1, #addTeam.soldier do
            _soldier = addTeam.soldier[i]
            _soldier.owner = attacker
            _soldier:invokeSkill(44)
        end

        if self.summonTeamEx then
            self:summonTeamEx(addTeam)
        end
        self:_raceCountAddSum(addTeam.camp, addTeam.race1, addTeam.race2)
        return addTeam
    end
end 
-- self.targetCache
-- 敌方建筑
-- 敌方怪兽
-- 己方单位
-- 敌方单位
local ATTR_HP = BC.ATTR_HP
local ECampLEFT = ECamp.LEFT
local ECampRIGHT = ECamp.RIGHT
function BattleSkillLogic:addSoldier(soldier)
    local team = soldier.team
    if not team.canDestroy and not team.borning then
        return
    end
    local count
    local camp = team.camp
    local isSummon = team.summon
    local isBuilding = team.building
    local skilllabel = team.D["x"]
    local ishelpteam = team.ishelpteam
    for i = ECampLEFT, ECampRIGHT do
        if camp ~= i then
            -- 敌方
            if isBuilding then
                count = #self.targetCache[i][1] + 1
                self.targetCache[i][1][count] = soldier
            else
                count = #self.targetCache[i][2] + 1
                self.targetCache[i][2][count] = soldier

                count = #self.targetCache[i][4] + 1
                self.targetCache[i][4][count] = soldier

                -- 召唤
                if isSummon then
                    count = #self.targetCache[i][14] + 1
                    self.targetCache[i][14][count] = soldier
                end

                if ishelpteam then
                    count = #self.targetCache[i][21] + 1
                    self.targetCache[i][21][count] = soldier
                end
            end
        else
            -- 己方
            if not isBuilding then
                count = #self.targetCache[i][12] + 1
                self.targetCache[i][12][count] = soldier

                count = #self.targetCache[i][3] + 1
                self.targetCache[i][3][count] = soldier

                -- 兵种
                if team.classLabel ~= 0 then
                    count = #self.targetCacheClass[i][team.classLabel] + 1
                    self.targetCacheClass[i][team.classLabel][count] = soldier
                end
                -- 移动方式
                count = #self.targetCacheMoveType[i][team.moveType] + 1
                self.targetCacheMoveType[i][team.moveType][count] = soldier

                -- 种族1&2
                if self.targetCacheRace[i][team.race1] == nil then
                    self.targetCacheRace[i][team.race1] = {}
                end
                if self.targetCacheRace[i][team.race2] == nil then
                    self.targetCacheRace[i][team.race2] = {}
                end
                count = #self.targetCacheRace[i][team.race1] + 1
                self.targetCacheRace[i][team.race1][count] = soldier     
                count = #self.targetCacheRace[i][team.race2] + 1
                self.targetCacheRace[i][team.race2][count] = soldier   

                -- 召唤
                if isSummon then
                    count = #self.targetCache[i][13] + 1
                    self.targetCache[i][13][count] = soldier
                end

                if ishelpteam then
                    count = #self.targetCache[i][20] + 1
                    self.targetCache[i][20][count] = soldier
                end

                if type(skilllabel) == "number" then
                    if skilllabel == 1 then
                        -- 骷髅标签
                        count = #self.targetCache[i][15] + 1
                        self.targetCache[i][15][count] = soldier
                    elseif skilllabel == 2 then
                        -- 地狱标签
                        count = #self.targetCache[i][16] + 1
                        self.targetCache[i][16][count] = soldier
                    elseif skilllabel == 3 then
                        -- 龙标签
                        count = #self.targetCache[i][19] + 1
                        self.targetCache[i][19][count] = soldier
                    end
                elseif type(skilllabel) == "table" then
                    for j=1, #skilllabel do
                        if skilllabel[j] == 1 then
                            -- 骷髅标签
                            count = #self.targetCache[i][15] + 1
                            self.targetCache[i][15][count] = soldier
                        elseif skilllabel[j] == 2 then
                            -- 地狱标签
                            count = #self.targetCache[i][16] + 1
                            self.targetCache[i][16][count] = soldier
                        elseif skilllabel[j] == 3 then
                            -- 龙标签
                            count = #self.targetCache[i][19] + 1
                            self.targetCache[i][19][count] = soldier
                        end
                    end
                end
            end
        end
    end

    if not isBuilding then
        -- 全部
        count = #self.targetCacheAll + 1
        self.targetCacheAll[count] = soldier
        -- 召唤生物
        if isSummon then
            count = #self.targetCacheSummon + 1
            self.targetCacheSummon[count] = soldier
            self._summonMaxHP[camp] = self._summonMaxHP[camp] + soldier.maxHP
            self._summonHP[camp] = self._summonHP[camp] + soldier.maxHP

            self.summonCount[camp] = self.summonCount[camp] + 1
        else
            self._MaxHP[camp] = self._MaxHP[camp] + soldier.maxHP
            self._HP[camp] = self._HP[camp] + soldier.maxHP
        end
    end

    team.maxHP = team.maxHP + soldier.maxHP
    team.curHP = team.maxHP
end

function BattleSkillLogic:addTeam(team, row)
    super.addTeam(self, team, row)
    local count
    local camp = team.camp
    for i = ECampLEFT, ECampRIGHT do
        if not team.building then
            if camp ~= i then
                -- 敌方
                count = #self.targetCache[i][5] + 1
                self.targetCache[i][5][count] = team  
                if team.atkType ~= 0 then
                    count = #self.targetCache[i][5 + team.atkType] + 1
                    self.targetCache[i][5 + team.atkType][count] = team  
                end
                -- 召唤生物
                if team.summon then
                    count = #self.targetCache[i][11] + 1
                    self.targetCache[i][11][count] = team
                end

                if team.ishelpteam then
                    count = #self.targetCache[i][23] + 1
                    self.targetCache[i][23][count] = team
                end

                -- 敌方建筑+敌方兵团
                count = #self.targetCache[i][18] + 1
                self.targetCache[i][18][count] = team  
            else
                -- 兵种
                if team.classLabel ~= 0 then
                    count = #self.targetTeamCacheClass[i][team.classLabel] + 1
                    self.targetTeamCacheClass[i][team.classLabel][count] = team
                end

                -- 近战/远程
                if team.atkType ~= 0 then
                    count = #self.targetCache[i][7 + team.atkType] + 1
                    self.targetCache[i][7 + team.atkType][count] = team
                end
                count = #self.targetCache[i][10] + 1
                self.targetCache[i][10][count] = team  

                if team.ishelpteam then
                    count = #self.targetCache[i][22] + 1
                    self.targetCache[i][22][count] = team
                end


                if team.moveType == 2 then
                    -- 飞行单位
                    count = #self.targetCache[i][17] + 1
                    self.targetCache[i][17][count] = team
                end
            end
        else
            if camp ~= i then
                -- 敌方建筑+敌方兵团
                count = #self.targetCache[i][18] + 1
                self.targetCache[i][18][count] = team  
            end
        end
    end
end

function BattleSkillLogic:onHPChange(soldier, change, noAnim)
    local team = soldier.team
    local camp = team.camp
    if not team.building then
        if team.summon then
            self._summonHP[camp] = self._summonHP[camp] + change
        else
            self._HP[camp] = self._HP[camp] + change
        end
    end

    team.curHP = team.curHP + change
    if not noAnim and self.onHPChangeEx then
        self:onHPChangeEx(soldier, change)
    end

    if not BATTLE_PROC then
        local hteams = self._hteams[camp] 
        if hteams and hteams.havehteams and hteams.diedCount < 1 then
            local curHP = self._HP[camp]
            local maxHP = self._MaxHP[camp]
            self._control:updateBackupInfoNode(camp, 2, maxHP - curHP, maxHP - hteams.diedCount * maxHP)
        end
    end
end

function BattleSkillLogic:onMaxHPChange(soldier, change)
    local team = soldier.team
    local camp = team.camp
    if not team.building then
        if team.summon then
            self._summonMaxHP[camp] = self._summonMaxHP[camp] + change
        else
            self._MaxHP[camp] = self._MaxHP[camp] + change
        end
    end

    team.maxHP = team.maxHP + change
end

-- 移动图腾
function BattleSkillLogic:totemDown(x, y)
    local dis
    local minDis = 99999999
    local minTotem = nil
    for k, totem in pairs(self._totems) do
        if totem.drag > 0 then
            dis = (totem.x - x) * (totem.x - x) + (totem.y - y) * (totem.y - y)
            if dis < minDis then
                minTotem = totem
                minDis = dis
            end
        end
    end
    if minDis <= 2500 then
        self._selectTotem = minTotem
        self._dTotemX = x - minTotem.x
        self._dTotemY = y - minTotem.y
        self._downTotemX = x
        self._downTotemY = y
        return true
    else
        return false
    end
end

function BattleSkillLogic:totemMove(x, y)
    if self._selectTotem and self._selectTotem.drag == 1 then
        -- 拖动
        self._selectTotem.x, self._selectTotem.y = x - self._dTotemX, y - self._dTotemY
    end
end

function BattleSkillLogic:totemUp(x, y)
    if self._selectTotem then
        if self._selectTotem.drag == 2 then
            -- 固定速度移动
            local k = (y - self._downTotemY) / (x - self._downTotemX)
            local destX
            if x > self._downTotemX then
                destX = MAX_SCENE_WIDTH_PIXEL
            else
                destX = 0
            end 
            local destY = k * (destX - self._downTotemX + self._downTotemY)
            if destY < 0 then 
                destY = 0
                destX = (destY - self._downTotemY) / k + self._downTotemX
            elseif destY > MAX_SCENE_HEIGHT_PIXEL then
                destY = MAX_SCENE_HEIGHT_PIXEL
                destX = (destY - self._downTotemY) / k + self._downTotemX
            end
            self._selectTotem:stopMove()
            self._selectTotem:moveTo(destX, destY, self._selectTotem.speed)
        end
        self._selectTotem = nil
    end
end
-- 以下技能都是由方阵中的一个人释放
-- 20.己方任一方阵出现一次士气高涨
function BattleSkillLogic:invokeSkill20(camp)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[20] and team.aliveSoldier[1] then
            team.aliveSoldier[1]:invokeSkill(20)
        end
    end
end
-- 21.己方任意方阵死亡
function BattleSkillLogic:invokeSkill21(camp)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[21] and team.aliveSoldier[1] then
            return team.aliveSoldier[1]:invokeSkill(21)
        end
    end
    return false
end
-- 22.己方英雄释放x系法术 0: 全部  1-4 火水气土
function BattleSkillLogic:invokeSkill22(camp, kind)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[22] and team.aliveSoldier[1] then
            team.aliveSoldier[1]:invokeSkill(22, nil, kind)
        end
    end
end
-- 23.敌方英雄释放x系法术 0: 全部  1-4 火水气土
function BattleSkillLogic:invokeSkill23(camp, kind)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[23] and team.aliveSoldier[1] then
            team.aliveSoldier[1]:invokeSkill(23, nil, kind)
        end
    end
end
-- 25.己方召唤单位死亡
function BattleSkillLogic:invokeSkill25(camp)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[25] and team.aliveSoldier[1] then
            team.aliveSoldier[1]:invokeSkill(25)
        end
    end
end
-- 27.敌方任意方阵死亡
function BattleSkillLogic:invokeSkill27(camp)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[27] and team.aliveSoldier[1] then
            team.aliveSoldier[1]:invokeSkill(27)
        end
    end
end
-- 32.己方英雄释放法术  [1伤害 2辅助 3召唤 4其他]
function BattleSkillLogic:invokeSkill32(camp, kind)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[32] and team.aliveSoldier[1] then
            team.aliveSoldier[1]:invokeSkill(32, nil, kind)
        end
    end
end

-- 45.己方任意单位死亡（不包括召唤物）
function BattleSkillLogic:invokeSkill45(camp)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[45] and team.aliveSoldier[1] then
               team.aliveSoldier[1]:invokeSkill(45)
        end
    end
end

-- 46.存在相应的buff
function BattleSkillLogic:invokeSkill46(camp)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[46] and team.aliveSoldier[1] then
            return team.aliveSoldier[1]:invokeSkill(46)
        end
    end
    return false
end

-- 47.获得多个buff类型中的一种
function BattleSkillLogic:invokeSkill47(camp)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[47] and team.aliveSoldier[1] then
            team.aliveSoldier[1]:invokeSkill(47)
        end
    end
    return false
end

-- 48.己方任意方阵死亡(和复活的死亡逻辑分开)
function BattleSkillLogic:invokeSkill48(camp)
    local list = self._teams[camp]
    local team
    local bIsSucess = false 
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[48] and team.aliveSoldier[1] then
            local _bIsSucess = team.aliveSoldier[1]:invokeSkill(48)
            if _bIsSucess then
                bIsSucess = _bIsSucess
            end
        end
    end
    return bIsSucess
end

-- 49.敌方任意单位死亡
function BattleSkillLogic:invokeSkill49(camp)
    local list = self._teams[camp]
    local team
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE and team.skillTab[49] and team.aliveSoldier[1] then
            team.aliveSoldier[1]:invokeSkill(49)
        end
    end
end

-- 秒杀全场
function BattleSkillLogic:killAll(camp)
    local list = self._teams[camp]
    local team, soldier
    for i = 1, #list do
        team = list[i]
        if team.state ~= ETeamStateDIE then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                if not soldier.die then
                    soldier.cantSkill = true
                    soldier.reviveHPPro = nil
                    soldier:rap(soldier, -soldier.maxHP * 500, false, false, 1)
                    soldier.cantSkill = false
                end
            end 
        end
    end
end

function BattleSkillLogic:dtor1()
    actionInv = nil
    ATTR_Atk = nil
    ATTR_AtkPro = nil
    ATTR_Def = nil
    ATTR_Haste = nil
    ATTR_HP = nil
    ATTR_HPPro = nil
    ATTR_RAll = nil
    ATTR_RPhysics = nil
    Battle_Delta = nil
    BattleSkillLogic = nil
    BattleTeam = nil
    BattleTotem =  nil
    BC = nil
    BUFF_ID_YUN = nil
    cc = nil
    countDamage_attack = nil
    countDamage_heal = nil
    ECamp = nil
    ECampLEFT = nil
    ECampRIGHT = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil
    EState = nil
    ETeamState = nil
    ETeamStateDIE = nil
    getBulletFlyTime = nil
    getCellByScenePos = nil
    getRowIndex = nil
    initPlayerBuff = nil
    initSoldierBuff = nil 
    math = nil
    MAX_SCENE_HEIGHT_PIXEL = nil
    MAX_SCENE_WIDTH_PIXEL = nil
    mcMgr = nil
    next = nil
    objLayer = nil
    os = nil
    pairs = nil
    pc = nil
    random = nil
    randomSelect = nil
    randomTable = nil
    sqrt = nil
    tab = nil
    table = nil
    teams_list = nil
    tonumber = nil
    tostring = nil
    updateCaster = nil
    angerT = nil
    super = nil
    delayCall = nil
    ETeamStateNONE = nil
    ETeamStateMOVE = nil
    EMotionBORN = nil
    BC_EXT_H_APAdd = nil
end

function BattleSkillLogic:dtor3()
    SRData = nil
    SRTab = nil
    BattleTeam_addDamage = nil
    BattleTeam_addHurt = nil
    BattleTeam_addHeal = nil
    floor = nil
end

return BattleSkillLogic

