--[[
    Filename:    BattleSoldier.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-29 17:47:04
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


local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType

local ATTR_HP = BC.ATTR_HP
local ATTR_BeHealPro = BC.ATTR_BeHealPro

local objLayer
local logic
local delayCall = BC.DelayCall.dc

local actionInv = BC.actionInv
local floor = math.floor
local random = BC.ran
local ceil = math.ceil

local SRData = BattleUtils.SRData
-- 小兵
local BattleSoldier = class("BattleSoldier", require("game.view.battle.object.BattleObject"))
local BattleTeam
local BattleTeam_addDamage
local BattleTeam_addHurt
local BattleTeam_addHeal
local BattleTeam_addBeHeal

local enemyHeroShowHP = false
local showImmune = true
local EDirectRIGHT = EDirect.RIGHT
local EDirectLEFT = EDirect.LEFT
-- 类方法, 用于复制本地local
function BattleSoldier.initialize()
    logic = BC.logic
    objLayer = BC.objLayer
    enemyHeroShowHP = (BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_Guide)
    showImmune = (BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_Zombie or BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_AiRenMuWu)
    BattleTeam = require "game.view.battle.object.BattleTeam"
    BattleTeam_addDamage = BattleTeam.addDamage
    BattleTeam_addHurt = BattleTeam.addHurt
    BattleTeam_addHeal = BattleTeam.addHeal
    BattleTeam_addBeHeal = BattleTeam.addBeHeal
end
local super = BattleSoldier.super
function BattleSoldier:ctor(team, x, y)
    super.ctor(self)

    self.ID = BC.genID()
    self.camp = team.camp
    if self.camp == 2 then
        self.direct = EDirectLEFT
    else
        self.direct = EDirectRIGHT   
    end
    self.picScale = team.picScale
    self.team = team

    self.baseAttr = {} -- 一阶属性 上场以后固定
    self.attr = {}     -- 二阶属性 根据BUFF加成后的复合值

    self.minHP = 0 -- 最低血量, > 0 则免死 -- buff用
    self.minHPEx = 0 -- 额外 其他

    self.maxDamage = nil -- 最大可承受的伤害

    self.die = false
    self._lastAttackTick = -1000

    self.still = false -- 动作暂停

    -- 技能
    self.skills = {}

    -- 命中触发技能,下一次普攻时触发,并且取消普攻
    self._nextSkill = false

    -- 自身召唤方阵, 以方阵ID作为key
    self.summonTeam = {}
    -- 从属召唤单位
    self.owner = nil

    self._attacker = {}

    self.radius = 0

    self.canAttack = true

    -- 上一次受到的攻击百分比
    self.beDamagePro = 0
    -- 上一次受到的攻击种类
    self.beDamageKind = 0
    -- 上一次受到的攻击类型
    self.beDamageType = 0
    -- 上一次攻击miss
    self.lastMiss = false
    
    self.totemImmune = {}
    -- 免疫限制
    self.immuneForbidMove = false
    self.immuneForbidAttack = false
    self.immuneForbidSkill = false

    -- buff显示, 三个部位
    self._buffEff = {{}, {}, {}}
    self._buffEffCur = {0, 0, 0}
    self._buffEffTick = {0, 0, 0}
    -- 移动buff
    self._moveBuff = {}

    -- 受到普攻时,给攻击者添加的buff
    -- {id=level}
    self.counterBuff = {} 

    -- 被谁杀死
    self.killer = nil

    self.reviveHPPro = nil

    -- boss专用减伤
    self.bossDef = 0

    -- 兵团伤害免疫
    self.immune = false
    self.immune_skill = {false, false, false, false, false, false, false, false}

    -- 打别人无伤
    self.noDamage = false

    -- 强制不能释放技能
    self.cantSkill = false

    -- 特效
    self.mcCount = 0

    -- 饱和度
    self.saturation = 0

    -- 伤害治疗互换
    self.dmghealrvt = false
    self.dmgrvt1 = false    -- 法术伤害
    self.dmgrvt2 = false    -- 兵团伤害
    self.healrvt1 = false   -- 法术治疗
    self.healrvt2 = false   -- 兵团治疗

    self:initSprite(x, y)
    self:setPos(x, y)
end

function BattleSoldier:initSprite(x, y)
    -- 显示
    local team = self.team
    local shadowScale 
    if team.volume >= 5 then
        shadowScale = team.shadowScale * 1.25
    else
        shadowScale = team.shadowScale
    end
    objLayer:createObj(self, self.ID, team.dieExist, self.camp, self.picScale, x, y, team.resID, 
        team.shadow, shadowScale, team.building, logic.battleState)
    local dir = self.direct
    self.direct = nil
    self:setDirect(dir)
end

-- 更换资源图
function BattleSoldier:changeRes(resname, cacheColor)
    objLayer:changeRes(self.ID, resname, cacheColor)
end

local getCellByScenePos = BC.getCellByScenePos

if BATTLE_PROC then
function BattleSoldier:setPos(x, y)
    self.x, self.y = x, y
    self.team.posDirty = self.team.posDirty + 1
end
else
function BattleSoldier:setPos(x, y)
    self.x, self.y = x, y
    self.team.posDirty = self.team.posDirty + 1
    objLayer:setPos(self.ID, x, y)
end
end

local abs = math.abs
local sqrt = math.sqrt
local EDirectRIGHT = EDirect.RIGHT
local EDirectLEFT = EDirect.LEFT

if BATTLE_PROC then
function BattleSoldier:setDirect(dir)
    self.direct = dir
end
else
function BattleSoldier:setDirect(dir) 
    if self.direct ~= dir then
        self.direct = dir
        objLayer:setDirect(self.ID, dir)
    end
end
end

function BattleSoldier:clear()
    self.totemImmune = nil
    self.baseAttr = nil
    self.attr = nil
    self.skills = nil
    self.summonTeam = nil
    self._attacker = nil
    self.caster = nil
    self.hitPos = nil
    super.clear(self)
end

local EMotionATTACK = EMotion.ATTACK
local EMotionCAST1 = EMotion.CAST1
local EMotionCAST2 = EMotion.CAST2
local EMotionCAST3 = EMotion.CAST3
local EMotionMOVE = EMotion.MOVE
local EMotionBORN = EMotion.BORN
local EMotionIDLE = EMotion.IDLE
local EMotionDIE = EMotion.DIE
if BATTLE_PROC then
function BattleSoldier:changeMotion(motion, inv, callback, idleAfterAttack) 
    self.motion = motion
    local team = self.team
    if team.volume >= 5 and team.isMelee then
        if motion == EMotionATTACK then
            local calculation = team.calculation
            local tick1 = actionInv * (calculation[1] - 5)
            local tick2 = actionInv * (calculation[#calculation] + 3)
            -- 移到前层
            delayCall(tick1, self, function()
            end)
            delayCall(tick2, self, function()
            end)
        end
    end  

    if callback then
        callback()
    end
end
else
function BattleSoldier:changeMotion(motion, inv, callback, idleAfterAttack, noloop, disappearDie)
    -- 冲刺光影
    local ID = self.ID
    if motion ~= EMotionMOVE then
        if self.runeff then
            objLayer:runEffectStop(self.runeff)
            self.runeff = nil
        end
        if self.needRunArt then
            self.needRunArt = nil
        end
    else
        if self.needRunArt then
            self.runeff = objLayer:runEffect(ID, self.needRunArt)
            self.needRunArt = nil
        end
    end
    self.motion = motion
    if idleAfterAttack == nil then
        idleAfterAttack = true
    end
    if noloop == nil then
        noloop = false
    end
    local team = self.team
    if team.volume >= 5 and team.isMelee then
        if motion == EMotionATTACK then
            local calculation = team.calculation
            local tick1 = actionInv * (calculation[1] - 5)
            local tick2 = actionInv * (calculation[#calculation] + 3)
            -- 移到前层
            delayCall(tick1, self, function()
                objLayer:Zfront(ID, 3)
            end)
            delayCall(tick2, self, function()
                objLayer:Zback(ID)
            end)
        elseif (motion >= EMotionCAST1 and motion <= EMotionCAST3) then
            objLayer:Zfront(ID, 3 - team.camp)
        else
            objLayer:Zback(ID)
        end
    end  
    objLayer:setMotion(ID, motion, inv, callback, idleAfterAttack, noloop, disappearDie)
end
end

function BattleSoldier:getSize()
    return objLayer:getSize(self.ID)
end

function BattleSoldier:getRealSize()
    return objLayer:getRealSize(self.ID)
end

-- 海拔高度
function BattleSoldier:setAltitude(x, y)
    objLayer:setAltitude(self.ID, x, y)
end

function BattleSoldier:setVisible(visible)
    objLayer:setVisible(self.ID, visible)
end

function BattleSoldier:setShadowVisible(visible)
    objLayer:setShadowVisible(self.ID, visible)
end

function BattleSoldier:setZ(z)
    objLayer:setZ(self.ID, z)
end

function BattleSoldier:setCanCaught(isCanCaught)
    self.team.canTaunt = isCanCaught
    if not isCanCaught then
        delayCall(1500, self, function ()
            self.team.canTaunt = true
        end)
    end
end

function BattleSoldier:showRunArt(zoom)
    -- 冲刺光影, 如果正在移动中, 则开启光影, 如果不是,则等到移动时开启光影
    if self.motion == EMotionMOVE then
        if self.runeff == nil then
            self.runeff = objLayer:runEffect(self.ID, zoom)
        end
    else
        self.needRunArt = zoom
    end
end
local HitPos = BC.HitPos
local HitPos_Boss = {80, 55, 30, 5}
local beatOrders1 = {{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}}
local beatOrders2 = {{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}, 
                    {15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28},
                    {29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42}}

-- target为nil时只是单纯的朝向目标
function BattleSoldier:setTargetS(target)
    local team = self.team
    local melee = team.isMelee
    -- 移除旧目标的攻击者
    local oldTarget = self.targetS
    if oldTarget then
        oldTarget:removeAttacker(self)
        if melee then
            -- 近战移除攻击站位
            local hitIdx = self.hitIdx
            if hitIdx then
                local hitPos = oldTarget.hitPos
                hitPos[hitIdx] = hitPos[hitIdx] - 1
                if hitIdx == 1 and oldTarget.firstHitter == self then
                    oldTarget.firstHitter = nil
                end
                self.hitIdx = nil
            end
        end
    end
    local targetTeam
    if target then
        targetTeam = target.team
    end
    self:faceToTarget()
    -- 攻击目标
    self.targetS = target
    local canSetAttacker = false
    --[[
        targetTeam.targetT == team  被攻击的兵团的攻击目标是发出攻击的兵团：互殴
    ]]
    if target and targetTeam.targetT == team then
        canSetAttacker = true
        target:setAttacker(self)
    end
    -- 如果有站位就不重新计算站位了
    if target and melee and self.fightPtX == nil then
        -- print(logic.battleTime, "setTargetS", self.ID, target.ID)
        local targetVolume = targetTeam.volume
        -- 近战获取攻击站位
        if team.volume < 5 or targetVolume > team.volume then
            local beatIdx = team.beatIdx
            local beatOrder = beatOrders1[beatIdx]
            local index
            if targetVolume <= 4 then
                beatOrder = beatOrders1[beatIdx]
            else
                beatOrder = beatOrders2[beatIdx]
            end
            local hitPos = target.hitPos
            local min = 999
            local minIdx = 0
            for i = 1, #beatOrder do
                index = beatOrder[i]
                if hitPos[index] == 0 then
                    minIdx = index
                    break
                end
                if hitPos[index] < min then
                    min = hitPos[index]
                    minIdx = index
                end
            end

            if minIdx ~= 0 then
                hitPos[minIdx] = hitPos[minIdx] + 1
                self.hitIdx = minIdx
                if targetVolume == 6 then
                    -- BOSS
                    local radius = target.radius
                    local rMax
                    local dd = HitPos[targetVolume][minIdx][3]
                    if dd <= 10 then
                        rMax = 4
                    elseif dd <= 18 then
                        rMax = 3
                    else
                        rMax = 2
                    end
                    local r = HitPos_Boss[random(rMax)]
                    self._attackOffsetX = HitPos[targetVolume][minIdx][1] * (radius + r)
                    self._attackOffsetY = HitPos[targetVolume][minIdx][2] * (radius + r)
                else
                    local radius
                    if targetVolume <= 4 then
                        radius = target.radius + self.radius
                    else
                        radius = target.radius
                    end
                    if target.camp == 2 then
                        self._attackOffsetX = HitPos[targetVolume][minIdx][1] * radius
                        self._attackOffsetY = HitPos[targetVolume][minIdx][2] * radius
                    else
                        self._attackOffsetX = -HitPos[targetVolume][minIdx][1] * radius
                        self._attackOffsetY = HitPos[targetVolume][minIdx][2] * radius
                    end
                end
            end
        else
            -- 无视站位点
            local tarTeam = targetTeam
            if targetVolume < 5 and tarTeam.isMelee then
                -- 大打小
                local x1, y1 = self.x, self.y
                local x2, y2 = tarTeam.x, tarTeam.y
                local cx = (x1 + x2) * 0.5
                local cy = y2
                if x1 > x2 + 0.00000001 then
                    cx = cx + (self.radius + target.radius) * 0.5
                else
                    cx = cx - (self.radius + target.radius) * 0.5
                end

                self.fightPtX = cx
                self.fightPtY = cy
                self._attackOffsetX = 0
                self._attackOffsetY = 0
            else
                -- 大打大/大打远程
                local hitPos = target.hitPos
                local volume = tarTeam.volume
                local radius = 20
                local self_radius = self.radius
                if target.radius > self_radius then
                    radius = radius + target.radius
                else
                    radius = radius + self_radius
                end
                -- 大体型2号位，增加接战距离
                if team.beatIdx == 2 then
                    radius = radius + self_radius * (tarTeam.isMelee and 0.5 or 0.2)
                end
                local minIdx = 0
                if self.x < target.x + 0.00000001 then
                    minIdx = 1
                else
                    minIdx = #hitPos
                end
                self.hitIdx = minIdx
                self._attackOffsetX = HitPos[volume][minIdx][1] * radius
                self._attackOffsetY = HitPos[volume][minIdx][2] * radius  
            end
        end
        if self.hitIdx == 1 then
            if canSetAttacker then
                target.firstHitter = self
            end
        end
        self._attackOffsetX = self._attackOffsetX - 5 + random(10)
        if team.hasMeleeFightPt then 
            if self.fightPtX == nil then
                self.fightPtX = self._attackOffsetX + target.x 
                self.fightPtY = self._attackOffsetY + target.y 
            end
        end
    end
end

function BattleSoldier:setAttacker(attacker)
    self._attacker[attacker.ID] = attacker

end

function BattleSoldier:removeAttacker(attacker)
    self._attacker[attacker.ID] = nil
end

function BattleSoldier:getAttacker()
    if self.firstHitter then
        return self.firstHitter
    end
    if next(self._attacker) ~= nil then
        for k, v in pairs(self._attacker) do
            return v
        end
    else
        return nil
    end
end

function BattleSoldier:faceToTarget()
    local target = self.targetS
    if target == nil then
        return
    end
    local team = self.team
    if team.isMeleeEx then
        if target.team.x > team.x + 0.00000001 then
            self:setDirect(EDirectRIGHT)
        else
            self:setDirect(EDirectLEFT)
        end
    else
        if target.x > self.x + 0.00000001 then
            self:setDirect(EDirectRIGHT)
        else
            self:setDirect(EDirectLEFT)
        end
    end
end

function BattleSoldier:invokeSkill(skillkind, attacker, param, isForce)
    if self.cantSkill then return false end
    local skillgroup = self.team.skillTab[skillkind]
    if BC.CONDITIONFORCEKIND[tostring(skillkind)] then
        isForce = true
    end 
    if skillgroup then
        local count = #skillgroup
        for i = 1, count do
            if not isForce then
                if self:checkSkill(skillkind, skillgroup[i], attacker, param) then return true end
            else
                -- 考虑到一帧释放多个技能
                self:checkSkill(skillkind, skillgroup[i], attacker, param)
            end 
        end
    end
    return false
end

local BattleSoldier_invokeSkill = BattleSoldier.invokeSkill

function BattleSoldier:setDie(dieKind)
    if self.die then return end
    self.die = true
    local team = self.team
    -- 死
    -- 自己方阵死亡触发技能, 当自己是最后一个活着的单位时, 触发
    if not self.reviveHPPro and #team.aliveSoldier == 1 then
        if self.skillTab[15] then BattleSoldier_invokeSkill(self, 15) end
    end
    self.dieTick = logic.battleTime
    if dieKind == nil then
        self.dieKind = 0
    else
        self.dieKind = dieKind
    end
    -- print(logic.battleTime, "die", self.ID)
    self:onDie(dieKind == 199)
    self:stopMove()
    self:clearBuff()
    if not self.canMove then
        self.team.canMoveDirty = true
    end
    if team.isMelee then
        self.fightPtX = nil 
        self.fightPtY = nil
    end
    objLayer:setScale(self.ID, 1.0)

    local camp = team.camp
    if self.die and self.reviveHPPro then
        local hpPro = self.reviveHPPro
        self.reviveHPPro = nil
        team.reviveing = true
        logic:onReviveBegin(camp)
        delayCall(1, self, function ()
            self:changeMotion(EMotionCAST3, nil, nil, false)
            delayCall(5, self, function ()
                self:changeMotion(EMotionBORN)
                delayCall(1, self, function ()
                    self:setRevive(false, hpPro)
                    team.reviveing = nil
                    logic:onReviveEnd(camp, self)
                    if self.skillTab[41] then BattleSoldier_invokeSkill(self, 41) end
                end)           
            end)
            
        end)
    end

    -- 死亡回调
    team:soldierDie(self.index)

    if team.summon then
        logic.summonCount[camp] = logic.summonCount[camp] - 1
        -- 召唤物死亡回蓝
        -- 召唤物死亡减CD
        logic:onSummonDie(camp)
    end

end

function BattleSoldier:setRevive(noAnim, hppro)
    if not self.die then return end
    self.die = false
    -- 复活
    self:onRevive()
    -- 重新计算属性
    self:clearBuff()
    if hppro == nil then
        hppro = 100
    end
    local team = self.team
    local camp = team.camp

    team:soldierRevive(self.index)
     
    local id = self.aliveID
    
    local _x, _y = team.x, team.y
    local x, y = BC.getPosInFormation(_x, _y, id, team.volume, camp)
    self:setOffsetPos(x - _x, y - _y)
    self:setPos(x, y)

    self:heal(self, floor(self.maxHP * hppro * 0.01), noAnim)
    if logic.onRevive then logic:onRevive(self) end
    if team.summon then
        logic.summonCount[camp] = logic.summonCount[camp] + 1
    end
end

function BattleSoldier:resetCheckTick(dt)
    self._lastCheckTick = self._lastCheckTick + dt
end
local canMove = BC.canMove
function BattleSoldier:updateSoldier(Mspeed)
    local tick = logic.battleTime
    -- 计算免疫图腾伤害计时
    for k, v in pairs(self.totemImmune) do
        if tick > v + 0.00000001 then
            self.totemImmune[k] = nil
        end
    end

    -- 追击目标并揍目标, 知道目标死亡, 由logic重新分派目标
    local speed = Mspeed
    local team = self.team
    local target = self.targetS
    -- print(self.ID, logic.battleTime > self._lastCheckTick)
    if target == nil then
        local teamMoveDstX, teamMoveDstY = self.teamMoveDstX, self.teamMoveDstY
        if teamMoveDstX ~= nil and self.canMove and logic.battleTime > self._lastCheckTick + 0.00000001 then
            -- 如果目标不存在，每0.2秒移动一次
            self._lastCheckTick = logic.battleTime + 0.2 
            if teamMoveDstX ~= self.x or teamMoveDstY ~= self.y then
                self:moveTo(teamMoveDstX, teamMoveDstY, speed)
            end
            self.teamMoveDstX, self.teamMoveDstY = nil, nil
            return 
        end
    else
        local tarTeam = target.team
        if target.die then
            -- 目标死亡触发技能
            if tarTeam.original then
                if self.skillTab[10] then BattleSoldier_invokeSkill(self, 10) end
            end
            -- 目标死亡消除的buff
            self:disappearBuff(1)
            self:setTargetS(nil)
            if canMove(team) then
                self:stopMove()
            end
            return 
        end
        if logic.battleTime > self._lastCheckTick + 0.00000001 then
            self._lastCheckTick = logic.battleTime + 0.2 
            local x1, y1 = self.x, self.y
            local x2, y2 = target.x, target.y
            local attack = false
            local move = false
            local _moveX, _moveY
            local fightPtX, fightPtY = self.fightPtX, self.fightPtY
            if not team.isMelee then
                -- 自己是远程
                local d = 0.999999
                if abs(fightPtX - x1) < d and abs(fightPtY - y1) < d then
                    attack = true
                else
                    move = true
                    _moveX = fightPtX
                    _moveY = fightPtY
                end
            else
                -- 自己是近战
                --[[
                        1 fightPtx什么时候会为nil ==》 自己死的时候以及攻击完毕之后（BattleLogic:teamAttackOver）
                          如果兵团处于攻击状态，BattleLogic:attackUpdate 这个方法会在BattleLogic:updateTeam持续调用

                        2 
                ]]
                local fx, fy
                if fightPtX ~= nil then
                    -- 如果有fightPtX 就强制走到该位置开始攻击
                    fx, fy = fightPtX, fightPtY
                else
                    -- 否则, 追随target的坐标+偏移值 
                    -- BattleSoldier:setTargetS里设置 _attackOffsetX 和 _attackOffsetY
                    fx, fy = x2 + self._attackOffsetX, y2 + self._attackOffsetY
                end
                if team.volume < 5 then
                    if not self.firstAttack then
                        attack = true
                    else
                        local d = 9.999999
                        if abs(fx - x1) < d and abs(fy - y1) < d then
                            attack = true
                        else
                            move = true
                            _moveX = fx
                            _moveY = fy
                        end
                    end
                    -- 防止小兵循环追
                    if tarTeam.isMelee and tarTeam.volume < 5 and fightPtX == nil and target.fightPtX == nil then
                        -- print("#@#", self.ID)
                        self.fightPtX, self.fightPtY = fx, fy
                    end
                else
                    -- 大体型单位

                    -- 如果对方是近战, 并且目标是我
                    -- 为了解决 双方都没有fightPtX, 而导致的追着打的死循环问题
                    if tarTeam.isMelee and fightPtX == nil and target.targetS == self and target.fightPtX == nil then
                        if self._attackOffsetX and tarTeam.volume == 5 then
                            self.fightPtX = (x1 + x2 + self._attackOffsetX) * 0.5
                            self.fightPtY = (y1 + y2 + self._attackOffsetY) * 0.5
                            move = true
                            _moveX = fx
                            _moveY = fy
                        else
                            self.fightPtX, self.fightPtY = x1, y1
                            attack = true
                        end
                    else
                        local d = 9.999999
                        if x1 > x2 + 0.00000001 then
                            if (x1 - fx < d and abs(fy - y1) < d) or team.speedMove == 0 then
                                attack = true
                            else
                                move = true
                                _moveX = fx
                                _moveY = fy
                            end
                        else
                            if (fx - x1 < d and abs(fy - y1) < d) or team.speedMove == 0 then
                                attack = true
                            else
                                move = true
                                _moveX = fx
                                _moveY = fy
                            end
                        end
                    end
                end
            end
            if attack then
                -- 攻击目标
                local tick = logic.battleTime
                if self.canAttack and tick > self._lastAttackTick + self.atkInv then
                    self._lastAttackTick = tick
                    if not team.isMelee then
                        if self.isMove then 
                            self:stopMove()
                        end
                        self:attack(target)
                    else
                        if self.isMove then 
                            self:stopMove()
                        end
                        self:attack(target)    
                    end
                end
                return 
            elseif move then
                if self.canMove and (self._moveDstx ~= _moveX or self._moveDsty ~= _moveY) then
                    self:moveTo(_moveX, _moveY, speed, function ()
                        self:faceToTarget()
                    end)
                end
                return 
            end
        else
            return 
        end
    end
    return 
end

function BattleSoldier:moveTo(x, y, speed, callback, notRandomDest)
    -- print(logic.battleTime, "move", self.ID, x, y, speed)
    -- 过滤同速度同目的地的移动
    if self._moveDstx == x and self._moveDsty == y and self._moveSpeed == speed then
        return
    end
    if not notRandomDest and not self.isMove then
        speed = speed - 2 + random(4)
        if speed < 0 then
            speed = 0
        end
    end
    super.moveTo(self, x, y, speed, callback)
end

local countDamage_attack = BC.countDamage_attack
local formula_vampire_modifier = BC.formula_vampire_modifier
local updateCaster = BC.updateCaster
local updateCasterPos = BC.updateCasterPos
local initSoldierBuff = BC.initSoldierBuff
local sqrt = math.sqrt
-- 普攻
local randomSelect = BC.randomSelect
local getBulletFlyTime = BC.getBulletFlyTime
function BattleSoldier:attack(target)
    if target == nil then
        return
    end
    if target.die then
        return
    end
    self:faceToTarget()
    -- print(logic.battleTime, "attack", self.ID, target.ID)
    local team = self.team
    local tarTeam = target.team
    local melee = team.isMelee
    -- 远程强制使用近战攻击
    local rangeUseMeleeAttack = false
    if not team.isMelee and target.isMelee then
        rangeUseMeleeAttack = self._attacker[target.ID] ~= nil
    end

    local srCount
    if SRData then
        srCount = (team.camp == 2 and not team.boss)
    end
    local skillTab = self.skillTab

    -- 对面是否有xbuff
    if skillTab[24] then BattleSoldier_invokeSkill(self, 24, nil, target) end

    -- 如果目标是某种兵种
    if skillTab[26] then BattleSoldier_invokeSkill(self, 26, nil, target) end

    -- 成功释放替换普攻, 如果释放失败, 资格保留
    if self._nextSkill then
        if skillTab[1] and BattleSoldier_invokeSkill(self, 1) then 
            self._nextSkill = false
            return 
        end
    end

    -- 技能替换普攻
    local isBuilding = tarTeam.building
    if skillTab[8] and BattleSoldier_invokeSkill(self, 8) then
        if not isBuilding then
            local ae = team.skillAttackEffect
            if ae then
                local aeD = tab.skillAttackEffect[ae]
                if aeD then
                    local buffid = aeD["buff"]
                    if buffid then
                        target:addBuff(initSoldierBuff(buffid, 1, updateCaster(self, logic), target))
                    end
                end
            end
        end
        self._nextSkill = true
        return 
    end

    -- 攻击附加
    if skillTab[34] then 
        BattleSoldier_invokeSkill(self, 34) 
        if skillTab[38] then 
            BattleSoldier_invokeSkill(self, 38) 
            if skillTab[39] then 
                BattleSoldier_invokeSkill(self, 39) 
            end
        end
    end

    if tarTeam.volume <= 3 then
        -- 如果对面体型<=3
        if skillTab[29] then BattleSoldier_invokeSkill(self, 29, nil, target)
            if not isBuilding then
                local ae = team.skillAttackEffect
                if ae then
                    local aeD = tab.skillAttackEffect[ae]
                    if aeD then
                        local buffid = aeD["buff"]
                        if buffid then
                            target:addBuff(initSoldierBuff(buffid, 1, updateCaster(self, logic), target))
                        end
                    end
                end
            end
            self._nextSkill = true
            return 
        end
    else
        -- 如果对面体型>=4
        if skillTab[31] then BattleSoldier_invokeSkill(self, 31, nil, target) end
    end
    
    -- 攻击动作结算帧
    local calculation = team.calculation
    if rangeUseMeleeAttack and team.calculation1 then
        calculation = team.calculation1
    end
    local actionCalculation = calculation[#calculation]
    local actionTick = actionCalculation * actionInv
    if self.atkInv < actionTick - 0.00000001 then
        -- 攻击动作加速
        actionTick = self.atkInv
        self:onAttack(rangeUseMeleeAttack, actionTick / actionCalculation)
    else
        self:onAttack(rangeUseMeleeAttack)
    end

    local selfX, selfY = self.x, self.y
    -- 普攻需求拆成N次
    local attackCount = #calculation
    local attackPercent = 1 / attackCount
    for a = 1, attackCount do
        local attackTick = actionTick * (calculation[a] / actionCalculation)
        -- 普攻附带攻击特效
        local targetList = {target}
        -- 伤害比例
        local percent = 100
        local caster = self.caster
        if caster.paramAdd ~= nil 
            and caster.paramAdd > 0 then 
            percent = caster.paramAdd
        end
        percent = percent * attackPercent
        
        local damagePro = 100 * (percent * 0.01)
        local buffid = nil
        if not isBuilding then
            local ae = team.skillAttackEffect
            if ae then
                local aeD = tab.skillAttackEffect[ae]
                if aeD then
                    buffid = aeD["buff"]
                    damagePro = aeD["effect"][2] + aeD["effect"][3]
                    local count = aeD["effect"][1] - 1
                    -- if BattleUtils.XBW_SKILL_DEBUG then print(os.clock(), "攻击特效", ae) end
                    if count > 1 then
                        -- 随机目标
                        local list = tarTeam.aliveSoldier
                        local arr = randomSelect(#list, count, target.aliveID)
                        for i = 1, #arr do
                            targetList[i + 1] = list[arr[i]]
                        end
                    end
                end
            end
        end
        if rangeUseMeleeAttack then
            damagePro = damagePro * team.meleePro
        end

        -- 命中延时结算
        local id = self.ID
        local flyspeed = team.flyspeed
        local atkfly = team.atkfly
        local bullet = team.bullet
        if self.freplace and self.freplace == 1 and team.bullet2 then
            bullet = team.bullet2
        end
        local boom = team.boom
        local boom1 = team.boom1 -- 击地特效
        local critSkill = false
        local dodgeSkill = false
        local hitSkill = false

        if rangeUseMeleeAttack then
            atkfly = 0
            boom = nil
        end
        -- 攻击震动
        local shake = team.atkshake
        if shake then
            delayCall(actionInv * shake[2], self, function ()
                logic:shake(shake[1])
            end)
        end
        local notSoFast
        if BATTLE_PROC then
            notSoFast = false
        else
            if self.atkInv < 0.31 and self.team.volume < 4 and GRandom(3) > 1 then
                notSoFast = false
            else
                notSoFast = true
            end
        end
        delayCall(attackTick, self, function()
            team:playAttackSound()
        end)
        local castTick = logic.battleTime
        local tar, dieTick
        local tarCount = #targetList
        local hitCount = 0
        for i = 1, #targetList do
            tar = targetList[i]
            if not tar.die then
                local sx, sy = tar.x, tar.y
                delayCall(attackTick, self, function()
                    -- 如果自己死了, 箭不出手, 如果对面死了, 照样出手
                    if self.die then 
                        return 
                    end
                    -- 如果对面已经复活, 打死之前的地板
                    dieTick = tar.dieTick
                    if tar.die or (dieTick and castTick < dieTick) then 
                        if atkfly and atkfly > 0 then
                            local dis = sqrt((sx - selfX) * (sx - selfX) + (sy - selfY) * (sy - selfY))
                            if notSoFast then
                                objLayer:rangeAttackPt(id, sx, sy, 0, flyspeed, atkfly, bullet, dis, 100)
                            end
                            local flyTime = getBulletFlyTime(atkfly, flyspeed, dis)
                            delayCall(flyTime, self, function()
                                if boom1 and notSoFast then
                                    objLayer:playEffect_skill1(boom1, sx, sy, true, true)
                                end
                            end)
                        end
                        hitCount = hitCount + 1
                        if hitCount == tarCount then
                            -- 攻击后消除的BUFF
                            -- self:disappearBuff(5)
                        end
                        return 
                    end
                    -- 子弹飞行时间
                    local flyTime = 0
                    if atkfly and atkfly > 0 then
                        local dis = sqrt((tar.x - selfX) * (tar.x - selfX) + (tar.y - selfY) * (tar.y - selfY))
                        flyTime = getBulletFlyTime(atkfly, flyspeed, dis)
                        local _tar = tar
                        if notSoFast then
                            objLayer:rangeAttack(id, tar.ID, 0, flyspeed, atkfly, bullet, dis, 100)
                        end
                        delayCall(flyTime, self, function()
                            if boom1 and notSoFast then
                                objLayer:playEffect_skill1(boom1, _tar.x, _tar.y, true, true)
                            end
                        end)
                    end
                    delayCall(flyTime, self, function()
                        if not (atkfly and atkfly > 0) then
                            -- 近战
                            if boom1 and notSoFast then
                                objLayer:playEffect_skill1(boom1, tar.x, tar.y, true, true)
                            end
                        end
                        -- 如果自己死了, 不结算
                        if self.die then 
                            return 
                        end
                        hitCount = hitCount + 1
                        if self.firstAttack then
                            if skillTab[12] then BattleSoldier_invokeSkill(self, 12) end
                            if skillTab[37] then BattleSoldier_invokeSkill(self, 37) end
                            self.firstAttack = false
                        end
                        -- 如果对面死了, 无效
                        if tar.die then

                        else
                            -- 有可能复活重生, 舍弃死之前的伤害
                            dieTick = tar.dieTick
                            if not (dieTick and castTick < dieTick) then
                                -- 受击动画
                                if boom then
                                    objLayer:rangeHit(tar, boom)
                                end
                                -- 计算伤害
                                local damage, crit, dodge, hurtValue = countDamage_attack(logic, updateCaster(self, logic), tar, 100, 0, 0, 1, damagePro)
                             
                                if self.noDamage then
                                    damage = 0
                                    hurtValue = 0
                                end
                                if hitCount == tarCount then
                                    -- 攻击后消除的BUFF
                                    team:disappearBuff(5)
                                end
                                -- 受击buff
                                if melee then
                                    for bid, lv in pairs(tar.counterBuff) do
                                        self:addBuff(initSoldierBuff(bid, lv, tar.caster, self))
                                    end
                                end
                                if dodge then
                                    if not BATTLE_PROC then tar:HPanim_miss() end
                                    tar:rap(self, 0, false, dodge, 0)
                                    if not dodgeSkill then
                                        self.lastMiss = true
                                        if skillTab[2] then BattleSoldier_invokeSkill(self, 2) end
                                        dodgeSkill = true
                                    end   
                                    if SRData then
                                        if srCount then
                                            SRData[378] = SRData[378] + 1
                                        end
                                    end 
                                else
                                    tar.beDamageType = team.atkType
                                    local realDamage, dontCount, avoidDamage = tar:rap(self, -damage, crit, dodge, 0)
                                    avoidDamage = avoidDamage or 0
                                    
                                    if tar.die then
                                        -- 普攻击杀触发技能
                                        if skillTab[16] then BattleSoldier_invokeSkill(self, 16) end
                                    else
                                        -- 攻击特效buff
                                        if buffid then
                                            local buff = initSoldierBuff(buffid, 1, updateCaster(self, logic), tar)
                                            tar:addBuff(buff)
                                        end
                                    end
                                    -- 战斗统计
                                    if not dontCount then
                                        BattleTeam_addDamage(team, hurtValue, -realDamage)
                                    end
                                    BattleTeam_addHurt(tar.team, hurtValue, -realDamage)
                                    if realDamage ~= 0 and team.canDestroy then    
                                        -- 吸血/反弹
                                        local damage2, avoidDamage2 = formula_vampire_modifier(self.caster, self, tar, -realDamage, avoidDamage)
                                        avoidDamage2 = avoidDamage2 or 0
                                        if damage2 ~= 0 then
                                            if not self.die then
                                                self:beDamaged(tar, damage2, false, 0)
                                            end
                                            if damage2 > 0 then
                                                -- 吸血
                                                BattleTeam_addHeal(team, damage2)
                                            else
                                                -- 反弹
                                                BattleTeam_addDamage(tar.team, -(damage2 + avoidDamage2), -(damage2 + avoidDamage2))
                                            end
                                        end
                                    end
                                    if not hitSkill then
                                        self._nextSkill = true
                                        hitSkill = true
                                    end

                                    if SRData then
                                        if srCount then
                                            SRData[376] = SRData[376] + 1
                                        end
                                    end
                                end
                                if crit and not critSkill then
                                    self:HPanim_crit()
                                    if skillTab[3] then BattleSoldier_invokeSkill(self, 3) end
                                    critSkill = true
                                end  
                            end
                        end
                    end)
                end)
            end
        end
    end

end

-- 与beDamaged区别开, 加了被动技能判定
-- 如果是受击触发的技能,不再触发受击技能, 直接调用beDamaged
function BattleSoldier:rap(attacker, damage, crit, dodge, damageKind, dieKind, noAnim, isPlayer, param1, param2)
    self:onRap(attacker, crit, dodge, isPlayer)
    if not dodge then
        return self:beDamaged(attacker, damage, crit, damageKind, dieKind, noAnim, param1, param2)
    else
        return 0, true
    end
end
function BattleSoldier:heal(healer, heal, noAnim, param1, param2)
    return self:beDamaged(healer, heal, false, 999, nil, noAnim, param1, param2)
end
-- 与HPChange区别开, 加了一层灵魂链接
function BattleSoldier:beDamaged(attacker, damage, crit, damageKind, dieKind, noAnim, param1, param2, isSureNoDie)
    if damage < 0 and logic:getDamageShareList(self.camp)[self.ID] then
        -- 灵魂连接, 每帧最后结算
        logic:addDamageShareValue(self.camp, damage)
        return damage
    end
    if damageKind ~= 999 then
        objLayer:rap(self.ID, 255, 200, 200)
    end
    return self:HPChange(attacker, damage, crit, damageKind, dieKind, noAnim, param1, param2, isSureNoDie)
end

function BattleSoldier:hitFly()
    if not self.die and self.team.volume < 4 then
        objLayer:hitFly(self.ID)
    end
end

function BattleSoldier:hitFlyEx(scale)
    if not self.die then
        objLayer:hitFly(self.ID, scale)
    end
end
local EStateING = EState.ING
-- damageKind 伤害类型 普攻为0
-- damage 伤害为负数  治疗为正数
local BC_reverse = BC.reverse
local mainCamp = BC_reverse and 2 or 1
local subCamp = 3 - mainCamp
function BattleSoldier:HPChange(attacker, _damage, crit, _damageKind, dieKind, noAnim, param1, param2, isSureNoDie)
    if self.die then return 0, true end
    local damage = _damage
    local isDamage = damage < 0
    local isHeal = damage > 0

    local curMinHp = self.minHP -- 重置前的最低血量

    local isHero = attacker == nil

    -- 无敌是多么
    if isHero then
        if isDamage then 
            local _kk = _damageKind
            if _kk == 998 then
                _kk = 3
            end
            if self.immune_skill[_kk] then
                if not BATTLE_PROC then self:HPanim_immune() end
                return 0, true
            end
        end
    else
        if self.immune and isDamage then
            if not BATTLE_PROC then self:HPanim_immune() end
            return 0, true
        end
    end
    
    -- damageKind
    -- 999 治疗
    -- 998 云中城建筑伤害
    -- 0  怪兽普攻
    -- 1-5 技能

    local damageKind = _damageKind
    self.beDamageKind = damageKind
    
    -- 伤害治疗互换逻辑
    if self.dmghealrvt then
        if isDamage then
            if isHero then
                if self.dmgrvt1 then
                    damage = -damage
                    damageKind = 999
                end
            else
                if self.dmgrvt2 then
                    damage = -damage
                    damageKind = 999
                end
            end
        elseif isHeal then
            if isHero then
                if self.healrvt1 then
                    damage = -damage
                    damageKind = 1
                end
            else
                if self.healrvt2 then
                    damage = -damage
                    damageKind = 1
                end
            end
        end
    end

    -- 护盾
    local realDamage = 0
    local avoidDamage = 0
    if isHeal then
        realDamage = damage
    elseif isDamage then
        realDamage = BC.countBuffShield(self, damage)
        avoidDamage = realDamage - damage
        if SRData then
            -- 护盾统计
            if self.camp == 1 then
                local d = damage - realDamage
                if d > 0 then
                    if d > SRData[447] then SRData[447] = d end
                    if d < SRData[448] then SRData[448] = d end
                    SRData[449] = SRData[449] + d
                end
            end
        end
    else
        if not BATTLE_PROC and showImmune and damageKind ~= 999 then self:HPanim_immune() end
        return 0, true
    end
    local proEx
    if not BATTLE_PROC then
        proEx = self.HP / self.maxHP
    end
    local realD = 0
    if realDamage ~= 0 then
        local hp = self.HP + realDamage
        if realDamage < 0 then
            -- 濒死触发
            if hp <= 0 then
                if self.skillTab[42] then BattleSoldier_invokeSkill(self, 42) end
            end
            -- 受到超过血量上限n%的伤害触发技能
            if self.skillTab[14] then BattleSoldier_invokeSkill(self, 14, -realDamage) end

            -- add by hxp : 如果有护盾 伤害溢出时会重置最低血量为0，在保证不死的情况下最低血量外面已经设置了为1
            if isSureNoDie then
                self.minHP = curMinHp
            end 
            local minHP = self.minHP + self.minHPEx
            if hp <= minHP then
                realD = minHP - hp
                hp = minHP
            end
        else
            -- 治疗不能超过血量上限
            local maxHP = self.maxHP
            if hp > maxHP then
                realD = maxHP - hp
                hp = maxHP
            end
            if SRData then
                local heal = realDamage + realD
                if heal > 0 then
                    BattleTeam_addBeHeal(self.team, heal)
                end
            end
        end
        self.HP = hp
        -- 血量到达n%触发技能
        if self.skillTab[11] then 
            BattleSoldier_invokeSkill(self, 11) 
            if self.skillTab[43] then
                BattleSoldier_invokeSkill(self, 43) 
            end
        end
        -- 兵团血量到达n%
        if self.skillTab[36] then BattleSoldier_invokeSkill(self, 36) end

        local result, value = logic:isSpeSkillConditionSet(self.camp, 47)
        if result and self:checkSkill47(value) then 
            logic:invokeSkill47(self.camp) 
        end

        if self.HP == 0 then
            -- 死亡触发的技能
            self.killer = attacker
            self:setDie(dieKind)
            if self.skillTab[9] then BattleSoldier_invokeSkill(self, 9) end
            self:setTargetS(nil)
        end

        if not BATTLE_PROC then
            if BattleUtils.XBW_SKILL_DEBUG then 
                if damageKind == 999 then
                    self:HPanim(realDamage + realD, crit, damageKind, proEx, not noAnim, isHero) -- 有效治疗
                else
                    if damageKind == 0 then
                        self:HPanim(realDamage, crit, 0, proEx, not noAnim, isHero)
                    else
                        self:HPanim(realDamage, crit, damageKind, proEx, not noAnim, isHero) -- 实际伤害
                    end
                end
            else
                if damageKind == 999 then
                    -- 战斗开始前不显示血条
                    if logic.battleState ~= EStateING then
                        proEx = nil
                    end
                    self:HPanim(realDamage + realD, crit, damageKind, proEx, not noAnim, isHero) -- 有效治疗
                else
                    -- 普攻和怪兽技能跳黄字
                    if damageKind == 0 then
                        -- 普攻
                        self:HPanim(realDamage, crit, 0, proEx, self.boss and not noAnim, isHero)
                    else
                        -- 技能
                        self:HPanim(realDamage, crit, damageKind, proEx, (self.camp == subCamp or damageKind == 998) and not noAnim, isHero) -- 实际伤害
                    end
                end
            end
        end
    end
    if not BATTLE_PROC then
        if damage < 0 and realDamage > damage and realDamage == 0 then
            -- 吸收了伤害
            local absorb = realDamage - damage
            self:HPanim_absorb(absorb)
        end
    end

    logic:onHPChange(self, realDamage + realD, noAnim)
    if SRData then
        if self.firstDamageMaxHP == nil then
            self.firstDamageMaxHP = self.maxHP
            self.firstDamageMinHP = self.minHP
        end
    end
    return realDamage + realD, false, avoidDamage
end

function BattleSoldier:HPanim_miss()
    objLayer:HPLabelMove(self.ID, 10, self.camp, 0, true)
end

function BattleSoldier:HPanim_crit()
    if self.camp == 2 then return end
    objLayer:HPLabelMove(self.ID, 11, self.camp, 1, true)
end

function BattleSoldier:HPanim_absorb(absorb)
    if absorb <= 0 then
        return
    end
    objLayer:HPLabelMove(self.ID, 12, self.camp, 2, true)
end

function BattleSoldier:HPanim_immune()
    objLayer:HPLabelMove(self.ID, 13, self.camp, 3, true)
end

function BattleSoldier:HPanim(damage, crit, damageKind, proEx, hpAnim, isHero)
    if damage == 0 then
        return
    end
    local ex = 0
    local hp = damage
    local pro2 = self.HP / self.maxHP
    local pro1 = proEx
    if not self.team.showHP then
        pro1 = nil
    end
    if damage > 0 then
        -- 治疗
        if crit then
            objLayer:HPLabelMove(self.ID, 4, self.camp, hp, hpAnim, pro1, pro2)
        else
            objLayer:HPLabelMove(self.ID, 3, self.camp, hp, hpAnim, pro1, pro2)
        end
    elseif damage < 0 then
        local _type
        if damageKind == 0 then
            -- 普攻
            if crit then
                _type = 6
            else
                _type = 5
            end
        else
            -- 技能
            if isHero then
                if crit then
                    _type = 2
                else
                    _type = 1
                end
                if enemyHeroShowHP then hpAnim = true end   
            else
                if crit then
                    _type = 8
                else
                    _type = 7
                end
            end
        end
        objLayer:HPLabelMove(self.ID, _type, self.camp, -hp, hpAnim, pro1, pro2)
    end
end

-- dot/hot生效
function BattleSoldier:buffDot(buff)
    local buffD = buff.buffD
    if buffD["type"] == 8 then
        -- 概率加buff
        local pro, buffid = buffD["addbuff"][1], buffD["addbuff"][2]
        if random(100) <= pro then
            local _buff = initSoldierBuff(buffid, buff.level, self.caster, self)
            _buff.countDamage = false
            self:addBuff(_buff)
        end
    else
        if buffD["kind"] == 2 then
            -- dot
            local value = buff.value[1] * buff.count
            local realDamage, dontCount = self:beDamaged(buff.attacker, -value, false, buffD["dottype"], nil, nil, nil, buffD["label"])
            if SRData then
                if buff.camp == 1 then
                    local _damage = -realDamage
                    if _damage > SRData[466] then SRData[466] = _damage end
                    if _damage < SRData[467] then SRData[467] = _damage end
                    SRData[471] = SRData[471] + _damage
                end
            end
            -- 战斗统计
            if buff.countDamage and buff.attacker then
                if not dontCount then
                    BattleTeam_addDamage(buff.attacker.team, buff.hurt, -realDamage, buffD["id"])
                end
                BattleTeam_addHurt(self.team, buff.hurt, -realDamage)
            end
        elseif buffD["kind"] == 3 then
            local value = buff.value[1] * buff.count
            if value < 0 then
                -- 第一次生效计算被治疗效果
                local behealpro = self.attr[ATTR_BeHealPro]
                if behealpro < -100 then
                    behealpro = -100
                end
                value = -ceil(value * (100 + behealpro) * 0.01)
            end
            -- hot
            local _, dontCount = self:beDamaged(nil, value, false, 999)
            if buff.countDamage and buff.attacker and not dontCount then
                BattleTeam_addHeal(buff.attacker.team, value)
            end
        end
        if not BC.jump and buffD["boom"] then
            objLayer:rangeHit(self, buffD["boom"]) 
        end
    end
end

function BattleSoldier:onMove()
    super.onMove(self)
    if not self.die and self.team.speedMove > 0 then
        self:changeMotion(EMotionMOVE)
    end
    if BC.jump then return end
    -- 移动buff显示
    for ID, buffEff in pairs(self._moveBuff) do
        if not buffEff.visible then
            buffEff.visible = true
            buffEff:setVisible(true)
        end
    end
end

function BattleSoldier:onStop()
    super.onStop(self)
    self.teamMoveDstX, self.teamMoveDstY = nil, nil
    if self.motion == EMotionMOVE then
        self:changeMotion(EMotionIDLE)
    end
    if BC.jump then return end
    -- 移动buff显示
    for ID, buffEff in pairs(self._moveBuff) do
        if buffEff.visible then
            buffEff.visible = false
            buffEff:setVisible(false)
        end
    end
end

function BattleSoldier:onAttack(rangeUseMeleeAttack, inv)
    local team = self.team
    if team.firstAttack then
        team.firstAttack = false
        team:onFirstAttack()
    end
    if not self.die then
        if rangeUseMeleeAttack then
            self:changeMotion(EMotionCAST1, inv)
        else
            self:changeMotion(EMotionATTACK, inv)
        end
    end
end

function BattleSoldier:onRap(attacker, crit, dodge, isPlayer)
    -- 受击技能判定
    local skillTab = self.skillTab
    if dodge then
        if skillTab[5] then BattleSoldier_invokeSkill(self, 5, attacker) end
    else
        if skillTab[4] then BattleSoldier_invokeSkill(self, 4, attacker) end
        if crit then
            if skillTab[6] then BattleSoldier_invokeSkill(self, 6, attacker) end
        end
        -- 受到英雄法术伤害
        if isPlayer then
            if skillTab[33] then BattleSoldier_invokeSkill(self, 33, attacker) end
        end
    end
end

if BATTLE_PROC then
function BattleSoldier:onDie()
    self:changeMotion(EMotionDIE)

    -- 死亡震动
    if self.team.dieshake then
        delayCall(actionInv * self.team.dieshake[2], self, function ()
        end)
    end
end
else
function BattleSoldier:onDie(disappearDie)
    if self.team.volume < 5 then
        if not self.team.isSiege and self.dieKind then
            objLayer:playEffect_die(self.dieKind, self)
        end
    end
    self:changeMotion(EMotionDIE, nil, nil, nil, nil, disappearDie)

    -- 死亡震动
    local shake = self.team.dieshake
    if shake then
        delayCall(actionInv * shake[2], self, function ()
            logic:shake(shake[1])
        end)
    end
    self.team:playDieSound()
end
end

function BattleSoldier:onRevive()
    if self.motion ~= EMotionBORN then
        self:changeMotion(EMotionIDLE)
        self:changeMotion(EMotionBORN)
    end
end

-- 属性相关
-- BUFF发生增减时,重新计算二阶属性
local ATTR_Haste = BC.ATTR_Haste
local ATTR_Shiqi = BC.ATTR_Shiqi
local K_ASPEED = BC.K_ASPEED 
function BattleSoldier:resetAttr()
    local ID = self.ID
    local canAttack = self.canAttack
    local canSkill = self.canSkill
    local oldMaxHP = self.maxHP
    local oldWindFly = self.windFly

    BC.countBuffAdd(self)
   
    if not canAttack and self.canAttack then
        -- 攻击回复, 重置攻击间隔
        self._lastAttackTick = logic.battleTime
    end
    if not BATTLE_PROC and not BC.jump then
        if canSkill and not self.canSkill and self.mcCount > 0 then
            objLayer:delMCfromUpdatePoolBySoldierId(ID)
            self.mcCount = 0
        end
    end

    -- 动作静止
    if self.still then
        objLayer:pause(ID)
    else
        objLayer:resume(ID)
    end
    -- buff缩放
    objLayer:setScale(ID, self.scale)

    -- 吹飞
    if oldWindFly and not self.windFly then
        objLayer:cancelWindFly(ID)
        -- print(self.ID, "cancelWindFly")
    elseif not oldWindFly and self.windFly then
        objLayer:windFly(ID, 100)
    end

    -- 饱和度
    if self.saturationDirty then
        objLayer:setSaturation(ID, self.saturation)
        self.saturationDirty = nil
    end

    if oldMaxHP then
        local newMaxHP = self.maxHP
        local dHP = newMaxHP - oldMaxHP
        if dHP > 0 then
            -- 血量上限增加
            self:heal(self, dHP)
            logic:onMaxHPChange(self, dHP)
        elseif dHP < 0 then
            -- 血量上限减少
            local pro = self.HP / oldMaxHP

            self:HPChange(nil, floor(newMaxHP * pro - self.HP), false, 1, nil, true)
            logic:onMaxHPChange(self, dHP)
        end
    end

    local checkAtkSpeed = not BATTLE_PROC and GameStatic.checkZuoBi_1
    -- 检查攻速
    if checkAtkSpeed then
        if self.__atkSpeedCheck then
            local atkSpeedCheck = self.atkspeed * self.atkInv * 3
            if abs(atkSpeedCheck - self.__atkSpeedCheck) > 0.001 then
                BC.zuobi2 = 2
            end
        end
    end

    -- 攻速转换
    local atkSpeed = self.atkspeed * (1 + K_ASPEED * self.attr[ATTR_Haste])
    if atkSpeed < 0.1 then
        atkSpeed = 0.1
    end
    self.atkInv = 1 / atkSpeed

    -- 检查攻速
    if checkAtkSpeed then
        self.__atkSpeedCheck = self.atkspeed * self.atkInv * 3
    end

    if self.isMove and not self.canMove then
        self:stopMove()
    end
end

-- buff切换时间
local BUFF_EFF_UPDATE_TICK = 0.75

-- 新加某buff特效, 优先显示
function BattleSoldier:_addBuffEff(idx, eff)
    if eff == nil then return end
    local count = #self._buffEff[idx] + 1
    self._buffEff[idx][count] = eff
    local cur = self._buffEffCur[idx]
    if cur > 0 then
        -- 隐藏前一个BUFF
        self._buffEff[idx][cur]:setVisible(false)
    end
    self._buffEffCur[idx] = count
    self._buffEffTick[idx] = BC.BATTLE_BUFF_TICK
end

local remove = table.removebyvalue
function BattleSoldier:_defBuffEff(idx, eff)
    if eff == nil then return end
    if BC.jump then return end
    local cur = self._buffEffCur[idx]
    -- print("del", cur)
    local buffEff = self._buffEff[idx]
    buffEff[cur]:setVisible(false)
    remove(buffEff, eff)
    local count = #buffEff
    if count == 0 then
        self._buffEffCur[idx] = 0
        return
    end
    if cur > count then
        self._buffEffCur[idx] = 1
        buffEff[1]:setVisible(true)
    else
        buffEff[cur]:setVisible(true)
    end
    if eff ~= buffEff[self._buffEffCur[idx]] then
        self._buffEffTick[idx] = BC.BATTLE_BUFF_TICK
    end
end

function BattleSoldier:_clearBuffEff()
    for i = 1, #self._buffEff do
        self._buffEff[i] = {}
        self._buffEffCur[i] = 0
    end
end

local super_updateBuff = super.updateBuff
function BattleSoldier:updateBuff(tick)
    super_updateBuff(self, tick)
    
    if BC.jump then return end
    for i = 1, #self._buffEff do
        local buffEff = self._buffEff[i]
        if #buffEff > 1 then
            if tick > self._buffEffTick[i] + BUFF_EFF_UPDATE_TICK then
                self._buffEffTick[i] = tick
                -- print("old", self._buffEffCur[i])
                buffEff[self._buffEffCur[i]]:setVisible(false)
                self._buffEffCur[i] = self._buffEffCur[i] + 1
                if self._buffEffCur[i] > #buffEff then
                    self._buffEffCur[i] = 1
                end
                -- print("new", self._buffEffCur[i])
                buffEff[self._buffEffCur[i]]:setVisible(true)
            end
        end
    end
end

function BattleSoldier:clearBuff(noResetAttr)
    for k, v in pairs(self.buff) do
        if v.eff then
            logic:stopEffect(v.eff)
        end
    end
    self._moveBuff = {}
    self:_clearBuffEff()
    objLayer:cancelColor(self.ID)
    super.clearBuff(self)
    logic:getDamageShareList(self.camp)[self.ID] = nil
    if self.windFly then
        objLayer:cancelWindFly(self.ID)
        self.windFly = nil
    end
    if not self.die and not noResetAttr then
        self:resetAttr()
    end
end

-- 安全日志buff
local SRBUFFFUNC
if GameStatic.useSR then
local function SRBUFF_1(buffD, buff)
    SRData[385] = SRData[385] + 1
    local duration = buff.duration
    local value = buff.value[1]
    if value then
        if value < SRData[386] then SRData[386] = value end
        if value > SRData[387] then SRData[387] = value end
    end
    if duration < SRData[388] then SRData[388] = duration end
    if duration > SRData[389] then SRData[389] = duration end
    SRData[390] = SRData[390] + buff.duration
end
local function SRBUFF_2(buffD, buff)
    SRData[392] = SRData[392] + 1
    local duration = buff.duration
    local value = buff.value[1]
    if value then
        if value < SRData[393] then SRData[393] = value end
        if value > SRData[394] then SRData[394] = value end
    end
    if duration < SRData[395]  then SRData[395] = duration end
    if duration > SRData[396] then SRData[396] = duration end
    SRData[397] = SRData[397] + buff.duration
end
local function SRBUFF_3(buffD, buff)
    SRData[399] = SRData[399] + 1
    local duration = buff.duration
    local value = buff.value[1]
    if value then
        if value < SRData[400] then SRData[400] = value end
        if value > SRData[401] then SRData[401] = value end
    end
    if duration < SRData[402] then SRData[402] = duration end
    if duration > SRData[403] then SRData[403] = duration end
    SRData[404] = SRData[404] + buff.duration
end
local function SRBUFF_4(buffD, buff)
    SRData[406] = SRData[406] + 1
    local duration = buff.duration
    local value = buff.value[1]
    if value then
        if value < SRData[407] then SRData[407] = value end
        if value > SRData[408] then SRData[408] = value end
    end
    if duration < SRData[409] then SRData[409] = duration end
    if duration > SRData[410] then SRData[410] = duration end
    SRData[411] = SRData[411] + buff.duration
end
local function SRBUFF_5(buffD, buff)
    SRData[413] = SRData[413] + 1
    local duration = buff.duration
    local value = buff.value[1]
    if value then
        if value < SRData[414] then SRData[414] = value end
        if value > SRData[415] then SRData[415] = value end
    end
    if duration < SRData[416] then SRData[416] = duration end
    if duration > SRData[417] then SRData[417] = duration end
    SRData[418] = SRData[418] + buff.duration
end
local function SRBUFF_6(buffD, buff)
    SRData[421] = SRData[421] + 1
    local duration = buff.duration
    local value = buff.value[1]
    if value then
        if value < SRData[422] then SRData[422] = value end
        if value > SRData[423] then SRData[423] = value end
    end
    if duration < SRData[424] then SRData[424] = duration end
    if duration > SRData[425] then SRData[425] = duration end
    SRData[426] = SRData[426] + buff.duration
end
local function SRBUFF_7(buffD, buff)
    SRData[429] = SRData[429] + 1
    local duration = buff.duration
    local value = buff.value[1]
    if value then
        if value < SRData[430] then SRData[430] = value end
        if value > SRData[431] then SRData[431] = value end
    end
    if duration < SRData[432] then SRData[432] = duration end
    if duration > SRData[433] then SRData[433] = duration end
    SRData[434] = SRData[434] + buff.duration
end
local function SRBUFF_8(buffD, buff)
    -- 暂时没有
    -- SRData[436] = SRData[436] + 1
end
local function SRBUFF_9(buffD, buff)
    SRData[443] = SRData[443] + 1
    local duration = buff.duration
    if duration < SRData[444] then SRData[444] = duration end
    if duration > SRData[445] then SRData[445] = duration end
    SRData[446] = SRData[446] + buff.duration
end
local function SRBUFF_10(buffD, buff)
    SRData[451] = SRData[451] + 1
    local duration = buff.duration
    if duration < SRData[453] then SRData[453] = duration end
    if duration > SRData[454] then SRData[454] = duration end
    SRData[455] = SRData[455] + buff.duration
end
local function SRBUFF_11(buffD, buff)
    SRData[457] = SRData[457] + 1
    local duration = buff.duration
    if duration < SRData[459] then SRData[459] = duration end
    if duration > SRData[460] then SRData[460] = duration end
    SRData[461] = SRData[461] + buff.duration
end
local function SRBUFF_12(buffD, buff)
    SRData[463] = SRData[463] + 1
    local duration = buff.duration
    if duration > SRData[468] then SRData[468] = duration end
    if duration < SRData[469] then SRData[469] = duration end
    SRData[470] = SRData[470] + buff.duration
end
SRBUFFFUNC = 
{SRBUFF_1, SRBUFF_2, SRBUFF_3, SRBUFF_4, SRBUFF_5, SRBUFF_6, SRBUFF_7, SRBUFF_8, SRBUFF_9, SRBUFF_10, SRBUFF_11, SRBUFF_12}
end

local buffFilter = {[449005] = 1, [4490051] = 1, [4490052] = 1, [4490053] = 1, [4490054] = 1, [4490055] = 1}
local copyBuff = BC.copyBuff
function BattleSoldier:addBuff(buff)
    local buffD = buff.buffD
    local team = self.team
    -- 方阵buff
    if buffD["teambuff"] then
        team:addBuff(copyBuff(buff))
    end
    local label = buffD["label"]
    if label and team.immuneBuff[label]  then return end

    -- 带有符文宝石的己方兵团有X%的免疫buff概率(对方释放在我方身上才生效)
    if self.team.rune and self.team.camp ~= buff.camp and label then
        local pro = team.proImmuneBuff[label]
        if pro and random(100) <= pro then 
            self:HPanim_immune()
            return 
        end
    end 
    
    local id, valid = super.addBuff(self, buff)
    if SRData then
        if buffD.sr and buff.camp == 1 then
            local kind = buffD["kind"]
            -- 我方释放的buff或者或者dot
            if kind == 0 or kind == 2 then
                SRBUFFFUNC[buffD.sr](buffD, buff)
            elseif kind == 1 then
                -- 我方释放的冰冻和晕眩
                if label and (label == 7 or label == 10) then
                    SRBUFFFUNC[buffD.sr](buffD, buff)
                end
            end
        end
    end
    -- 获得某类型buff触发技能
    if valid then
        if self.skillTab[30] then BattleSoldier_invokeSkill(self, 30, nil, label) end
        if self.team.rune then
            -- 携带符文宝石的兵团触发
            if self.skillTab[46] then BattleSoldier_invokeSkill(self, 46, nil, label) end 
        end
    end

    if id and not BC.jump and not BATTLE_PROC then
        if buffD["buffart"] then
            if not (team.camp == mainCamp and buffFilter[buffD["id"]]) then
                local buffpoint = buffD["buffpoint"]
                if buffpoint == nil then
                    buffpoint = 1
                end
                local eff = objLayer:playEffect_buff(buffD["buffart"], buffD["buffback"] == nil, true, self, buffpoint)
                self.buff[id].eff = eff
                local showrule = buffD["showrule"]
                if showrule == nil then showrule = 1 end
                if showrule == 1 then
                    self:_addBuffEff(buffpoint, eff) 
                elseif showrule == 2 then
                    if eff then 
                        eff:setVisible(self.isMove)
                        eff.visible = self.isMove
                        self._moveBuff[id] = eff
                    end
                end
            end
        end

        -- 混色
        if not self.customRGB then
            local rgb = buffD["rgb"]
            if rgb then
                self._colorBuffId = id
                objLayer:setPColor(self.ID, rgb[1], rgb[2], rgb[3], rgb[4])
            end
        end
        -- 变换弹道
        local freplace = buffD["freplace"]
        if freplace then
            self.freplace = freplace
            self._freplaceId = id
        end
        if buffD["hitfly"] then
            self:hitFly()
        end
    end
    -- 灵魂链接
    if buffD["kind"] == 4 then
        logic:getDamageShareList(self.camp)[self.ID] = self
    end
end

function BattleSoldier:delBuff(id, reset)
    local buff = self.buff[id]
    local cancelColor = false
    local cancelBullet = false
    if buff then
        -- 灵魂链接
        local buffD = buff.buffD
        if buffD["kind"] == 4 then
            logic:getDamageShareList(self.camp)[self.ID] = nil
        end
        if not BC.jump then
            if buff.eff then
                local buffpoint = buffD["buffpoint"]
                if buffpoint == nil then
                    buffpoint = 1
                end
                local showrule = buffD["showrule"]
                if showrule == nil then showrule = 1 end
                if showrule == 1 then
                    self:_defBuffEff(buffpoint, buff.eff)
                elseif showrule == 2 then
                    self._moveBuff[id] = nil
                end
                logic:stopEffect(buff.eff)
            end
            if self._colorBuffId == id then
                cancelColor = true
                self._colorBuffId = nil
            end
            if self._freplaceId == id then
                cancelBullet = true
                self._freplaceId = nil
                self.freplace = nil
            end
        end
    end
    super.delBuff(self, id, reset)
    if not self.customRGB and cancelColor then
        -- 看看其他BUFF有没有颜色, 没有颜色的话就还原
        local hasColor = false
        local rgb, buffD
        for k, buff in pairs(self.buff) do
            buffD = buff.buffD
            rgb = buffD["rgb"]
            if rgb then
                hasColor = true
                self._colorBuffId = k
                objLayer:setPColor(self.ID, rgb[1], rgb[2], rgb[3], rgb[4])
                break
            end
        end
        if not hasColor then
            objLayer:cancelColor(self.ID)
        end
    end
    if cancelBullet then
        local freplace, buffD
        for k, buff in pairs(self.buff) do
            buffD = buff.buffD
            freplace = buffD["freplace"]
            if freplace then
                self._freplaceId = k
                self.freplace = freplace
                break
            end
        end
    end
end

function BattleSoldier:printAttr()
    -- debug输出属性
    local attr = {}
    attr[1] = "ATTR_Atk"
    attr[2] = "ATTR_AtkPro"
    attr[3] = "ATTR_AtkAdd"
    attr[4] = "ATTR_HP"
    attr[5] = "ATTR_HPPro"
    attr[6] = "ATTR_HPAdd"
    attr[7] = "ATTR_Def"
    attr[8] = "ATTR_Pen"
    attr[9] = "ATTR_Crit"
    attr[10] = "ATTR_CritD"
    attr[11] = "ATTR_Resilience"
    attr[12] = "ATTR_Dodge"
    attr[13] = "ATTR_Hit"
    attr[14] = "ATTR_Haste"
    attr[15] = "ATTR_Hot"
    attr[16] = "ATTR_Heal"
    attr[17] = "ATTR_HealPro"
    attr[18] = "ATTR_BeHeal"
    attr[19] = "ATTR_BeHealPro"
    attr[20] = "ATTR_DamageInc"
    attr[21] = "ATTR_DamageDec"
    attr[22] = "ATTR_AHP"
    attr[23] = "ATTR_AHPPro"
    attr[24] = "ATTR_DHP"
    attr[25] = "ATTR_DHPPro"
    attr[26] = "ATTR_RPhysics"
    attr[27] = "ATTR_RFire"
    attr[28] = "ATTR_RWater"
    attr[29] = "ATTR_RWind"
    attr[30] = "ATTR_REarth"
    attr[31] = "ATTR_MSpeed"
    attr[32] = "ATTR_RAll"
    attr[33] = "ATTR_Shiqi"
    attr[34] = "ATTR_AtkDis"
    attr[35] = "ATTR_DefPro"
    attr[36] = "ATTR_PenPro"
    attr[37] = "ATTR_DefAdd"
    attr[38] = "ATTR_PenAdd"
    attr[39] = "ATTR_RPhysics_2"
    attr[40] = "ATTR_RFire_2"
    attr[41] = "ATTR_RWater_2"
    attr[42] = "ATTR_RWind_2"
    attr[43] = "ATTR_REarth_2"
    attr[44] = "ATTR_RAll_2"
    attr[45] = "ATTR_RPhysics_3"
    attr[46] = "ATTR_RFire_3"
    attr[47] = "ATTR_RWater_3"
    attr[48] = "ATTR_RWind_3"
    attr[49] = "ATTR_REarth_3"
    attr[50] = "ATTR_RAll_3"
    attr[51] = "ATTR_DecFire"
    attr[52] = "ATTR_DecWater"
    attr[53] = "ATTR_DecWind"
    attr[54] = "ATTR_DecEarth"
    attr[55] = "ATTR_DecAll"
    attr[56] = "ATTR_DecAllEx"
    attr[57] = "ATTR_HDamageDec_Thr"
    attr[58] = "ATTR_HDamageDec_Pro"
    attr[59] = "ATTR_DecFire1"
    attr[60] = "ATTR_DecWater1"
    attr[61] = "ATTR_DecWind1"
    attr[62] = "ATTR_DecEarth1"
    attr[63] = "ATTR_DecAll1"
    attr[64] = "ATTR_GlobalAtk"
    attr[65] = "ATTR_GlobalDef"
    attr[66] = "ATTR_RuneAtk"
    attr[67] = "ATTR_RuneDef"

    print("-----------------------------")
    for i = 1, BC.ATTR_COUNT do
        if self.baseAttr[i] ~= 0 or self.attr[i] ~= 0 then
            print(attr[i].." "..self.baseAttr[i].." / "..self.attr[i])
        end
    end
    print("cur hp : "..self.HP)
    print("atkspeedbase: "..self.atkspeed)
    local atkSpeed = self.atkspeed * (1 + BC.K_ASPEED * self.baseAttr[ATTR_Haste])
    print("atkspeed: "..atkSpeed)
    print("-----------------------------")
end

---------------------------技能相关----------------------------
---------------------------技能相关----------------------------
-- 技能判定 按照kind触发技能
-- 1.攻击附加
-- 2.攻击闪避附加
-- 3.攻击暴击附加
-- 4.受击
-- 5.受击闪避
-- 6.受击暴击
-- 7.开场
-- 8.攻击替换
-- 下面是条件 --
-- 9.自己死亡
-- 10.目标死亡
-- 11.自己生命到n 
-- 12.对方阵目标第一次攻击
-- 13.当前目标方阵死亡 
-- 14.单次受到伤害高于生命上限的n%
-- 15.自己方阵死亡 
-- 16.普攻击杀目标
-- 17.法术击杀目标
-- 18.出场时间到n毫秒
-- 19.士气高涨时
-- 20.己方任一方阵出现一次士气高涨
-- 21.己方任意方阵死亡
-- 22.己方英雄释放x系法术 0: 全部  1-4 火水气土
-- 23.敌方英雄释放x系法术 0: 全部  1-4 火水气土
-- 24.攻击时判断目标是否有x类BUFF
-- 25.己方召唤单位死亡
-- 26.如果目标是某兵种
-- 27.敌方兵团死亡
-- 28.当前目标方阵死亡(包括召唤)
-- 29.目标体型<=3
-- 30.自己获得某BUFF
-- 31.目标体型>=4
-- 32.己方英雄释放法术  [1伤害 2辅助 3召唤 4其他]
-- 33.受到英雄法术攻击(伤害)
-- 34.攻击附加1
-- 35.受到己方英雄辅助法术效果 (只给己方兵团加BUff)
-- 36.兵团生命到n 
-- 37.对方阵目标第一次攻击且拥有某buff
-- 38.攻击附加2
-- 39.攻击附加3
-- 40.触发指定id的主动技能 (所有的都改成满足一帧释放多个)
-- 41.复活的时候触发
-- 42.濒死触发
-- 43.自己生命到n 2 同11,会先判断11
-- 44.召唤物召唤出来触发
-- 45.己方任意单位死亡（不包括召唤物）
-- 46.获得多个buff类型中的一种
-- 47.己方任意兵团生命到n 

-- 判断技能是否可以触发
local skillMotion = {3, 5, 6, 7}
local tremove = table.remove
function BattleSoldier:checkSkill(skillkind, skillid, attacker, param)
    local team = self.team
    local teamskill = team.skills[skillid]
    local skill = self.skills[skillid]
    local tick = logic.battleTime
    local skillD = skill.skillD

    if not self.canSkill and skillD["banskill"] == nil then return false end

    -- 检查前置CD
    if skillD["dynamicCD"] and team.dynamicPreCD then
        if tick < team.dynamicPreCD then
            return false
        end
    elseif skillD["cdPre"] then
        if tick < skillD["cdPre"] * 0.001 then
            return false
        end
    end

    -- 特殊检查
    if self["checkSkill"..skillkind] and 47 ~= skillkind then
        if not self["checkSkill"..skillkind](self, skillD, param) then return false end
    end

    -- 检查释放次数
    if teamskill.count == 0 then 
        tremove(team.skillTab[skillkind], skillid)
        return false 
    end
    if skill.count == 0 then return false end
    -- 检查技能cd
    if tick < teamskill.canCastTick - 0.00000001 then return false end
    if tick < skill.canCastTick - 0.00000001 then return false end
    -- 概率
    if random(100) > skill.pro then return false end

    -- 移动中释放技能,没用动作
    if not self.isMove and not self.die then
        local actionart = skillD["actionart"]
        if actionart and actionart ~= 0 then
            if skillD["calculation"] and not skillD["strict"] then
                local actionTick = skillD["calculation"] * actionInv
                if self.atkInv < actionTick - 0.00000001 then
                    -- 动作加速
                    actionTick = self.atkInv
                    self:changeMotion(skillMotion[actionart], actionTick / skillD["calculation"])
                else
                    self:changeMotion(skillMotion[actionart])
                end
            else
                self:changeMotion(skillMotion[actionart])
            end
        end
    end
    -- 释放
    -- if BattleUtils.XBW_SKILL_DEBUG then print(os.clock(), skillid) end
    -- 减少释放次数
    if teamskill.count > 0 then
        teamskill.count = teamskill.count - 1
    end
    if skill.count > 0 then
        skill.count = skill.count - 1
    end
    if skillkind == 18 then
        teamskill.count = 0
        skill.count = 0
    end
    if skillD["dynamicCD"] and team.dynamicCD then
        -- 技能cd
        teamskill.canCastTick = tick + team.dynamicCD
        -- 技能cd
        skill.canCastTick = tick + team.dynamicCD
    else
        -- 技能cd
        teamskill.canCastTick = tick + (skillD["cdLimit"][1] - skillD["cdLimit1"][1] * (skill.level - 1)) * 0.001
        -- 技能cd
        skill.canCastTick = tick + (skillD["cdLimit"][2] - skillD["cdLimit1"][2] * (skill.level - 1)) * 0.001
    end
    
    logic:soldierCastSkill(BC.noEff or self.noEff, skillD, skill.level, updateCasterPos(self), attacker, true)
    if not BATTLE_PROC and not BC.jump and skillD["show"] then
        objLayer:showSkillName(self.ID, #team.aliveSoldier == 1, team.x, team.y, team.camp, lang(skillD["name"]))
    end

    -- 法术触发法术
    if self.skillTab[40] then BattleSoldier_invokeSkill(self, 40, nil, skillD["id"]) end

    return true
end
-- 血量到n%
function BattleSoldier:checkSkill11(skillD, param)
    return self.HP / self.maxHP * 100 < skillD["condition"][2] + 0.00000001
end
-- 单次受到伤害高于生命上限的n%
function BattleSoldier:checkSkill14(skillD, param)
    return param / self.maxHP * 100 > skillD["condition"][2] - 0.00000001
end
-- 出场时间到n毫秒
function BattleSoldier:checkSkill18(skillD, param)
    return param > skillD["condition"][2] * 0.001 - 0.00000001
end
-- 我方英雄释放法术
function BattleSoldier:checkSkill22(skillD, param)
    local kind = skillD["condition"][2]
    if kind == 0 then
        return true
    else
        return param == kind
    end
end
-- 敌方英雄释放法术
function BattleSoldier:checkSkill23(skillD, param)
    local value = skillD["condition"][2]
    if type(value) ~= "table" then
        if value == 0 then
            return true
        else
            return param == value
        end
    else
        for i=1, #value do
            if value[i] == param then
                return true
            end 
        end
        return false
    end 
end
-- 目标是否有x系buff
function BattleSoldier:checkSkill24(skillD, target)
    return target:hasBuffKind(skillD["condition"][2])
end

-- 26.如果目标是某兵种
function BattleSoldier:checkSkill26(skillD, target)
    local value = skillD["condition"][2]
    if type(value) ~= "table" then
        return value == target.team.classLabel
    else
        for i=1, #value do
            if value[i] == target.team.classLabel then
                return true
            end 
        end
        return false
    end 
end

-- 30.自己获得某buff
function BattleSoldier:checkSkill30(skillD, param)
    return skillD["condition"][2] == param
end
-- 32.我方英雄释放法术
function BattleSoldier:checkSkill32(skillD, param)
    local kind = skillD["condition"][2]
    if kind == 0 then
        return true
    else
        return param == kind
    end
end
-- 37.对方阵目标第一次攻击且拥有某buff
function BattleSoldier:checkSkill37(skillD, param)
    return self:hasBuff(skillD["condition"][2]) > 0
end
-- 血量到n%
function BattleSoldier:checkSkill36(skillD, param)
    return self.team.curHP / self.team.maxHP * 100 < skillD["condition"][2] + 0.00000001
end
-- 40.触发指定id的主动技能
function BattleSoldier:checkSkill40(skillD, param)
    return param == skillD["condition"][2] and param ~= skillD["id"]
end
-- 血量到n%
function BattleSoldier:checkSkill43(skillD, param)
    return self.HP / self.maxHP * 100 < skillD["condition"][2] + 0.00000001
end

-- 46.获得多个buff类型中的一种
function BattleSoldier:checkSkill46(skillD, param)
    local  conditions  = skillD["condition"][2]
    if conditions then
        for i=1,#conditions do
            if param == conditions[i] then
                return true
            end 
        end
    end 
    return false
end

-- 47.己方任意兵团生命到n 
function BattleSoldier:checkSkill47(value)
    return self.team.curHP / self.team.maxHP * 100 < value + 0.00000001
end

function BattleSoldier.dtor()
    abs = nil -- math.abs
    actionInv = nil -- BC.actionInv
    ATTR_Haste = nil -- BC.ATTR_Haste
    ATTR_HP = nil -- BC.ATTR_HP
    ATTR_Shiqi = nil -- BC.ATTR_Shiqi
    BattleSoldier = nil 
    BC = nil -- BC
    BUFF_EFF_UPDATE_TICK = nil -- 0.75
    canMove = nil -- BC.canMove
    cc = nil -- _G.cc
    copyBuff = nil -- BC.copyBuff
    countDamage_attack = nil
    ECamp = nil -- BC.ECamp
    EDirect = nil -- BC.EDirect
    EDirectLEFT = nil -- EDirect.LEFT
    EDirectRIGHT = nil -- EDirect.RIGHT
    EEffFlyType = nil -- BC.EEffFlyType
    EMotion = nil -- BC.EMotion
    EMotionATTACK = nil -- EMotion.ATTACK
    EMotionBORN = nil -- EMotion.BORN
    EMotionCAST1 = nil -- EMotion.CAST1
    EMotionCAST2 = nil -- EMotion.CAST2
    EMotionCAST3 = nil -- EMotion.CAST3
    EMotionMOVE = nil -- EMotion.MOVE
    enemyHeroShowHP = nil -- false
    EState = nil -- BC.EState
    EStateING = nil -- EState.ING
    ETeamState = nil -- BC.ETeamState
    floor = nil -- math.floor
    formula_vampire_modifier = nil
    getBulletFlyTime = nil
    getCellByScenePos = nil
    HitPos = nil
    HitPos_Boss = nil
    initSoldierBuff = nil
    K_ASPEED = nil -- BC.K_ASPEED 
    logic = nil
    math = nil -- math
    mcMgr = nil -- mcMgr
    next = nil -- next
    objLayer = nil
    os = nil -- _G.os
    pairs = nil -- pairs
    pc = nil -- pc
    random = nil -- BC.ran
    randomSelect = nil -- BC.randomSelect
    remove = nil -- table.removebyvalue
    skillMotion = nil -- {3, 5, 6, 7}
    sqrt = nil -- math.sqrt
    tab = nil -- tab
    table = nil
    tonumber = nil
    tostring = nil
    tremove = nil
    updateCaster = nil
    updateCasterPos = nil
end

function BattleSoldier.dtor1()
    super = nil
    EMotionIDEL = nil
    EMotionDIE = nil
    BattleSoldier_invokeSkill = nil
    beatOrders1 = nil
    beatOrders2 = nil
    super_updateBuff = nil
    delayCall = nil
    showImmune = nil
    SRData = nil
    SRBUFFFUNC = nil
    SRBUFF_1 = nil
    SRBUFF_2 = nil
    SRBUFF_3 = nil
    SRBUFF_4 = nil
    SRBUFF_5 = nil
    SRBUFF_6 = nil
    SRBUFF_7 = nil
    SRBUFF_8 = nil
    SRBUFF_9 = nil
    SRBUFF_10 = nil
    SRBUFF_11 = nil
    SRBUFF_12 = nil
    BattleTeam = nil
    BattleTeam_addDamage = nil
    BattleTeam_addHurt = nil
    BattleTeam_addHeal = nil
    BattleTeam_addBeHeal = nil
    buffFilter = nil
    EDirectRIGHT = nil
    EDirectLEFT = nil
    ATTR_BeHealPro = nil
    ceil = nil
end

return BattleSoldier
