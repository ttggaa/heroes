--[[
    Filename:    BattleTeam.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-29 17:37:56
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
local abs = math.abs


local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType
local random = BC.ran
local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL
local MAX_SCENE_HEIGHT_PIXEL = BC.MAX_SCENE_HEIGHT_PIXEL
-- 战斗场景元件的方阵, 寻路算法以方阵为单位
-- 方阵相当于一个坐标点, 不做显示
local objLayer
local logic
local delayCall = BC.DelayCall.dc

local BATTLE_ROW_Y

local SRData = BattleUtils.SRData

local BattleSoldier = require "game.view.battle.object.BattleSoldier"
local BattleTeam = class("BattleTeam", require "game.view.battle.object.BattleBuffer")
-- 类方法, 用于复制本地local
function BattleTeam.initialize()
    logic = BC.logic
    objLayer = BC.objLayer
    BATTLE_ROW_Y = BC.BATTLE_ROW_Y
end

local super = BattleTeam.super
function BattleTeam:ctor(camp, shadowScale)
    super.ctor(self)

    self.ID = 0

    self.isSiege = false
    self.x, self.y = 0, 0
    self.posDirty = 0

    self.shadowScale = shadowScale
    if self.shadowScale == nil then
        self.shadowScale = 1
    end
    -- 包围矩形
    self.minx, self.miny = 0, 0
    self.maxx, self.maxy = 0, 0


    self.isMove = false
    self.canMoveDirty = true
    self.canMove = true

    self.canFuhuo = true 
    self.canFuhuoDirty = true

    self.maxHP = 0
    self.curHP = 0

    -- 战斗统计
    self.damage = 0   --  减伤前攻击伤害
    self.damage1 = 0  --  减伤后攻击伤害:真实伤害
    self.damageSkill = {}
    self.damageSkillCount = {} -- 统计触发几次技能
    self.hurt = 0   --  减伤前承受伤害
    self.hurt1 = 0  --  减伤后承受伤害:真实伤害
    self.heal = 0
    self.beheal = 0
    self.dieTick = -1

    self._updateIndex = 1

    self.rush = 1
    self.camp = camp

    self.speedAdd = 0
    self.baseSpeedAdd = 0
    self.speedDirty = true
    self.speed = 0

    --记录死亡的时候，如果复活子物体不消失
    self._hasInvokeRevive = false
    self._soldierAliveCount = 0

    -- 自身召唤方阵, 以方阵ID作为key
    self.summonTeam = {}

    -- 是否可以点选显示头像
    self.showHead = true

    -- 是否显示血条
    self.showHP = true

    -- 1秒心跳, 用于判断不需要特别准确的方法
    -- 岔开每个方阵
    self._1sTick = random(1000) * 0.001

    if BattleUtils.XBW_SKILL_DEBUG and not BATTLE_PROC then
        self.stateLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self.stateLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self.stateLabel:setColor(cc.c3b(128, 255, 128))
        self.stateLabel:setLocalZOrder(2048)
        self.stateLabel:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
        self.stateLabel:setAnchorPoint(0.5, 0)
        objLayer:getView():addChild(self.stateLabel)

    end

    -- hot属性
    self._nextHotTick = 0

    -- 优化
    -- 行动值
    self._actionValue = 0

    -- 免疫buff种类编号 战斗中一直存在的buff
    self.immuneBuff = {}

    -- 概率免疫buff种类编号
    self.proImmuneBuff = {}

    -- 某种移动方式的人, 无法发现自己
    -- = {true, true}
    self.blind_MoveType = {}

    -- 士气
    self.baseShiqi = 0
    self.shiqi = 0
    self.shiqiValue = 0
    self._shiqiBuffTick = 0

    self.patrol = false

    -- 是否可以被别人拉进战斗
    self.canTaunt = true

    -- 常驻音效cd
    self._permSoundPlayTick = BC.BATTLE_TICK

    -- 击打点
    self.beatPos = {0, 0, 0}

    -- mc特效
    self.mcCount = 0

    -- 死人复活统计
    self.dieCount = 0
    self.reviveCount = 0 

    -- 技能触发的特殊标记
    self.skillTag_35 = {}
end

function BattleTeam:addDamage(damage, damage1, skillid)
    self.damage = self.damage + damage
    self.damage1 = self.damage1 + damage1
    -- 统计各个技能造成的伤害
    if skillid and not BATTLE_PROC then

        local damageSkill = self.damageSkill[skillid]
        if damageSkill then
            self.damageSkill[skillid] = damageSkill + damage
        else
            self.damageSkill[skillid] = damage
        end
    end
    -- 统计伤害
    if SRData then
        if damage1 == 0 then return end
        if self.original1 then
            local k = (self.ID - 1) * 20 + 192
            if damage > SRData[k] then SRData[k] = damage end
            k = k + 1
            if damage1 < SRData[k] then SRData[k] = damage1 end
            k = k + 1
            SRData[k] = SRData[k] + 1
        elseif self.camp == 2 then
            if not self.boss then
                if damage1 > SRData[381] then SRData[381] = damage1 end
                if damage1 < SRData[382] then SRData[382] = damage1 end
            else
                if damage1 > SRData[371] then SRData[371] = damage1 end
                if damage1 < SRData[372] then SRData[372] = damage1 end
                SRData[373] = SRData[373] + damage1
            end
        end
    end
end

function BattleTeam:addHurt(hurt, hurt1)
    self.hurt = self.hurt + hurt
    self.hurt1 = self.hurt1 + hurt1
    -- 统计伤害
    if SRData then
        if hurt1 == 0 then return end
        if self.original1 then
            local k = (self.ID - 1) * 20 + 182
            SRData[k] = SRData[k] + 1
            k = k + 1
            if hurt1 > SRData[k] then SRData[k] = hurt1 end
            k = k + 1
            if hurt1 < SRData[k] then SRData[k] = hurt1 end
        elseif self.camp == 2 then
            if not self.boss then
                if hurt1 > SRData[362] then SRData[362] = hurt1 end
                if hurt1 < SRData[363] then SRData[363] = hurt1 end
                SRData[364] = SRData[364] + hurt1
            else
                if hurt1 > SRData[356] then SRData[356] = hurt1 end
                if hurt1 < SRData[357] then SRData[357] = hurt1 end
                SRData[358] = SRData[358] + hurt1       
            end
        end
    end
end

function BattleTeam:addHeal(heal)
    self.heal = self.heal + heal
end

function BattleTeam:addBeHeal(beheal)
    if self.original1 then
        local k = (self.ID - 1) * 20 + 188 
        SRData[k] = SRData[k] + 1
        k = k + 1
        if beheal > SRData[k] then SRData[k] = beheal end
        k = k + 1
        if beheal < SRData[k] then SRData[k] = beheal end
        k = k + 1
        SRData[k] = SRData[k] + beheal
    end 
end

function BattleTeam:clear()
    for i = 1, self.number do
        self.soldier[i]:clear()
        self.soldier[i] = nil
    end
    self.soldier = nil
    self.aliveSoldier = nil
    self.unorderSoldier = nil
    self.dieSoldier = nil 
    self.immuneBuff = nil
    self.skillTab = nil
    self.summonTeam = nil

    self.charactersAtk = nil
    self.charactersDef = nil
    self.extraAtk = nil
    self.skillAttackEffect = nil
    self.skillCharacters = nil

    self.nearvol = nil
    self.farvol = nil
    self.disrdcvol = nil

    BattleTeam.super.clear(self)
end

function BattleTeam:getPos()
    return self.x, self.y
end

function BattleTeam:createSoldiers(info, initAttrFunc)
    local _x, _y = self.x, self.y
    local nx, ny

    local volume = self.volume
    local camp = self.camp

    nx, ny = BC.getPosInFormation(_x, _y, 0, volume, camp)
    self._soldierAliveCount = 0

    self.soldier = {}
    self.aliveSoldier = {}
    self.unorderSoldier = {}
    self.dieSoldier = {}
    local soldier = nil
    local count = self.number
    for i = count, 1, -1 do
        nx, ny = BC.getPosInFormation(_x, _y, i, volume, camp)
        soldier = BattleSoldier.new(self, nx, ny)
        soldier.index = i
        self.soldier[i] = soldier
        self.unorderSoldier[i] = soldier
    end
    self._initAttrFunc = initAttrFunc
    self._createInfo = info
    initAttrFunc(self, self.soldier, info)
    local soldier
    for i = 1, count do
        soldier = self.soldier[i]
        nx, ny = soldier.x, soldier.y
        logic:addSoldier(soldier)

        soldier:setOffsetPos(nx - _x, ny - _y)
        soldier:changeMotion(EMotion.IDLE)
        self.aliveSoldier[i] = soldier
        soldier.aliveID = i
    end
    if not self.walk or self.playBornAnim then
        -- 出生动画
        for i = 1, count do
            self.soldier[i]:changeMotion(EMotion.INIT)
        end
    end
    self._soldierAliveCount = self._soldierAliveCount + count

    self:initSkill()
    if self.halo then
        objLayer:addTeamHalo(self)
    end
end
local initSkill = BC.initSkill
-- 追加士兵
-- 根据self.number以及#self.soldier 决定追加到多少
function BattleTeam:additionSoldiers(addX, addY)
    local volume = self.volume
    if self.number > self.maxNumber then
        self.number = self.maxNumber
    end
    local number = self.number
    if self.number - #self.soldier <= 0 then return end

    local _x, _y = addX, addY
    local nx, ny

    local camp = self.camp

    nx, ny = BC.getPosInFormation(_x, _y, 0, volume, camp)

    local soldier = nil
    local soldiers = {}
    local count = #self.soldier + 1
    local index = 1
    if #self.aliveSoldier > 0 then
        index = count
    end
    for i = count, number do
        nx, ny = BC.getPosInFormation(_x, _y, index, volume, camp)
        soldier = BattleSoldier.new(self, nx, ny)
        soldier.index = i
        soldier.skillTab = self.skillTab
        self.soldier[i] = soldier
        self.unorderSoldier[i] = soldier
        soldiers[#soldiers + 1] = soldier
        index = index + 1
    end
    self._initAttrFunc(self, soldiers, self._createInfo)
    local id
    for i = count, number do
        soldier = self.soldier[i]
        nx, ny = soldier.x, soldier.y
        logic:addSoldier(soldier)

        soldier:setOffsetPos(nx - _x, ny - _y)
        soldier:changeMotion(EMotion.IDLE)
        self._soldierAliveCount = self._soldierAliveCount + 1
        id = self._soldierAliveCount
        self.aliveSoldier[id] = soldier
        soldier.aliveID = id
    end
    local _count = count
    local count = #self.skills
    local skillid, skilllevel, skillD, skill, teamCastCount, soldierCastCount, kind
    local soldier, soldierCount, s

    for k, v in pairs(self.skills) do
        skillid = k
        skilllevel = v.level
        skillD = tab.skill[skillid]
        soldierCastCount = skillD["numLimit"][2]
        if soldierCastCount == 0 then
            soldierCastCount = -1
        end
        local soldierCount = self.number
        for k = _count, number do
            soldier = self.soldier[k]
            -- 挂在每个soldier上的技能信息
            s = initSkill(skillD, skilllevel)
            s.count = soldierCastCount
            soldier.skills[skillid] = s
        end
    end
    local x, y
    if self.state == ETeamState.DIE then
        local list = self.aliveSoldier
        local aliveCount = #list
        local minx, miny, maxx, maxy = MAX_SCENE_WIDTH_PIXEL, MAX_SCENE_HEIGHT_PIXEL, 0, 0
        for i = 1, aliveCount do
            x, y = list[i].x, list[i].y
            if x < minx then minx = x end
            if x > maxx then maxx = x end
            if y < miny then miny = y end
            if y > maxy then maxy = y end
        end
        self.minx, self.miny, self.maxx, self.maxy = minx, miny, maxx, maxy
        if aliveCount > 0 then
            self.x = minx + (maxx - minx) * 0.5
            self.y = miny + (maxy - miny) * 0.5
        end
        logic:teamAttackOver(self)
        logic:onTeamRevive(self)
        self.__needShowHUD = true
    end
    if self.state == ETeamState.ATTACK then
        if self.targetT then
            local _tar = self.targetT
            logic:teamAttackOver(self)
            logic:attackToTarget(self, _tar)
        end
    end
end
-- 判断方阵是否才能再装下人
function BattleTeam:isFull(number)
    if number then
        return self.number + number > self.maxNumber
    else
        return self.number == self.maxNumber
    end
end
local ETeamStateIDLE = ETeamState.IDLE
local ETeamStateMOVE = ETeamState.MOVE
local ETeamStateATTACK = ETeamState.ATTACK
local ETeamStateSORT = ETeamState.SORT
local ETeamStateDIE = ETeamState.DIE
-- 小兵的移动速度取自于方阵
function BattleTeam:getMSpeed()
    if self.speedDirty then
        self.speedDirty = false
        local base = 0
        local state = self.state
        -- ETeamStateIDLE 和 ETeamStateDIE 的base都是0
        if state == ETeamStateMOVE then 
            if self.patrol then
                base = self.speedAttack
            else
                base = self.speedMove
            end
        elseif state == ETeamStateATTACK then 
            base = self.speedAttack
        elseif state == ETeamStateSORT then 
            return BC.SPEED_SORT
        end 
        local speed = base + self.speedAdd
        if speed < 0 then
            speed = 0
        end
        self.speed = speed
        return speed
    else
        return self.speed
    end
end

-- 初始化技能参数
-- team.skills[skillid]
-- soldier.skills[skillid]
function BattleTeam:initSkill()
    local count = #self.skills
    local skillid, skilllevel, skillD, skill, teamCastCount, soldierCastCount, kind
    local soldier, soldierCount, s
    self.skillTab = {}
    for i = 1, count do
        skillid = self.skills[i][1]
        skilllevel = self.skills[i][2]
        skillD = tab.skill[skillid]
        -- 挂在team上的技能信息
        skill = initSkill(skillD, skilllevel)
        teamCastCount = skillD["numLimit"][1]
        if teamCastCount == 0 then
            teamCastCount = -1
        end
        soldierCastCount = skillD["numLimit"][2]
        if soldierCastCount == 0 then
            soldierCastCount = -1
        end
        skill.count = teamCastCount
        self.skills[skillid] = skill
        self.skills[i] = nil

        local soldierCount = self.number
        for k = 1, soldierCount do
            soldier = self.soldier[k]
            -- 挂在每个soldier上的技能信息
            s = initSkill(skillD, skilllevel)
            s.count = soldierCastCount
            soldier.skills[skillid] = s
        end
        kind = skillD["kind"]
        if kind == 9 then
            kind = kind + skillD["condition"][1] - 1
        end
        if self.skillTab[kind] == nil then
            self.skillTab[kind] = {}
        end
        if 47 == kind then
            logic:addSpeSkillCondition(self.camp, self.D.id, kind, skillD["condition"][2])
        end
        -- 技能快查表 数组下标就是技能kind
        table.insert(self.skillTab[kind], skillid)
    end
    for i = 1, self.number do
        self.soldier[i].skillTab = self.skillTab
    end
    if SRData then
        local skillTab = self.skillTab
        local srSkillTab = {}
        local skillid, skillD, buffD, sr1, sr2
        for k, v in pairs(skillTab) do
            for i = 1, #v do
                skillid = v[i]
                skillD = tab.skill[skillid]
                if skillD["buffid1"] then
                    sr1 = tab.skillBuff[skillD["buffid1"]].sr
                end
                if skillD["buffid2"] then
                    sr2 = tab.skillBuff[skillD["buffid2"]].sr
                end
                if sr1 or sr2 then
                    if sr1 then   
                        if sr2 then
                            srSkillTab[skillid] = {sr1, sr2}
                        else
                            srSkillTab[skillid] = {sr1}
                        end
                    else
                        srSkillTab[skillid] = {sr2}
                    end
                end
            end
        end
        -- 计算技能安全日志类型 1 ~ 12
        self.srSkillTab = srSkillTab
    end
    -- dump(self.skillTab)
end

-- 释放开场技能
function BattleTeam:initBattleSkill(noEff)
    -- 开场技能比较特殊, 一个方阵只需要放一次, 选出第一个人放
    local has = false
    if self.skillTab and self.skillTab[7] then
        for i = 1, #self.skillTab[7] do
            self.soldier[1].noEff = noEff
            if self.soldier[1]:invokeSkill(7) then
                has = true
            end
            self.soldier[1].noEff = false
        end
    end
    return has
end

-- 开场技能，复活起来和镜像出来再放一次
function BattleTeam:invokeSkill7()
    --------现在不知道为什么出现了无尽炼狱战斗报错，这里加个容错看看可不可以解决
    if self.aliveSoldier then
        for i = 1, #self.aliveSoldier do
            if self.aliveSoldier[i] then
                self.aliveSoldier[i]:invokeSkill(7)
            end
        end
    end
end

-- 目标方阵死亡触发
function BattleTeam:onTargetDieSkill(original)
    if original then
        for i = 1, #self.aliveSoldier do
            self.aliveSoldier[i]:invokeSkill(13)
            -- 目标方阵死亡消除的buff
            self.aliveSoldier[i]:disappearBuff(2)
        end
    end
    if logic:getCampHP(3 - self.camp) > 0 then
        self:invokeSkill28()
    end
end

function BattleTeam:disappearBuff(kind)
    for i = 1, #self.aliveSoldier do
        self.aliveSoldier[i]:disappearBuff(kind)
    end
end

-- 大恶魔专用
function BattleTeam:invokeSkill28()
    for i = 1, #self.aliveSoldier do
        self.aliveSoldier[i]:invokeSkill(28)
    end
end

-- 时间触发技能
local ETeamStateNONE = ETeamState.NONE
function BattleTeam:onTickSkill()
    if logic.battleTime > self._1sTick - 0.00000001 then
        self._1sTick = self._1sTick + 1
    else
        return
    end
    if self.state == ETeamStateNONE then return end
    for i = 1, #self.aliveSoldier do
        self.aliveSoldier[i]:invokeSkill(18, nil, logic.battleTime)
    end
end

-- 对新目标的第一次攻击
function BattleTeam:onFirstAttack()
    local target = self.targetT
    if target and target.turnFire then
        delayCall(2, nil, function ()
            -- 2秒后, 转火逻辑
            logic:teamTurnFire(target, self)
        end)
    end
end

local floor = math.floor
-- 有小兵死了,重新计算受击点数量
function BattleTeam:soldierDie(id)
    local camp = self.camp
    logic.onSoldierDieFunc[camp](logic)    
    self._soldierAliveCount = self._soldierAliveCount - 1
    local soldier = self.soldier[id]
    local teamDie = false
    if self._soldierAliveCount == 0  then
        if not BC.jump and BC.SHOW_TEAM_DIE_ICON and camp == 1 and not self.building then
            objLayer:updateTeamDieIcon(self.ID, true, self.x, self.y, self.headPic)
        end
        -- print(logic.battleTime, "teamid", self.ID)
        self:setState(ETeamStateDIE)
        logic.onTeamDieFunc[camp](logic)
        self:setTargetT(nil)
        self.dieTick = floor(logic.battleTime)
        self.rangeRan = nil
        logic:onTeamDie(self)
        if not self.summon and soldier.killer then
            logic:pushSoldierSkillTip(3 - soldier.camp, soldier.killer.team.headPic, soldier.team.headPic)
        end
        self:clearBuff()
        if not BATTLE_PROC and not BC.jump then
            objLayer:hideTeamHUD(self)
            if self.mcCount > 0 then
                objLayer:delMCfromUpdatePoolByTeamId(self.ID)
                self.mcCount = 0
            end
        end
        teamDie = true
    end
    self.dieSoldier[id] = soldier 
    -- 己方任意单位死亡（不包括召唤物）
    if  not self.summon then
        logic:invokeSkill45(camp, self)
        -- 己方任意单位死亡触发敌方效果,因为世界boss的技能效果可能会导致当前的兵团死亡，这样上面的逻辑会有问题，因此单独在这里处理了一下，下一帧在触发技能
        logic:invokeSkill49(3 - camp, self)
    end 

    local count = self._soldierAliveCount + 1
    local index = soldier.aliveID
    self.aliveSoldier[index] = nil
    if count ~= index then
        self.aliveSoldier[index] = self.aliveSoldier[count]    
        self.aliveSoldier[count] = nil
        self.aliveSoldier[index].aliveID = index
    end
    if self.summon then
        logic:invokeSkill25(camp)
    end
    logic:onSoldierDieEx(soldier)

    local hasInvokeRevive = false
    if teamDie and (self.original or self.assistance) and not self.reviveing then
        if not soldier.banfuhuo or soldier.banfuhuo == 0 then
            hasInvokeRevive = logic:invokeSkill21(camp)
        end
        logic:invokeSkill46(camp)
        logic:invokeSkill27(3 - camp)
        --因为复活和死亡生效的逻辑冲突，所以这里新加了一个逻辑
        logic:invokeSkill48(camp)
    end

    if SRData then 
        self.dieCount = self.dieCount + 1
        if camp == 2 then
            logic.playerKillCount = logic.playerKillCount + 1
        end
    end
    self._hasInvokeRevive = hasInvokeRevive
    local revive = logic.firstDie[camp]
    -- local canFuhuo = self:getCanFuhuo() -- 增加buff["banfuhuo"] 禁止复活
    if teamDie and (self.original or self.assistance) and revive and not hasInvokeRevive and not self.reviveing  then --and canFuhuo then
        logic.firstDie[camp] = nil
        --由于这个时候的死亡需要计入援助的计算方式
        if logic.updateHelpTeam then
            logic:updateHelpTeam()
        end
        -- 天使联盟复活(宝物天使赞歌)
        for i = 1, #self.soldier do
            self.soldier[i]:setRevive(false, 100)

            local reviveBuffs = logic:getHero(camp).reviveBuff
            if reviveBuffs ~= nil then
                for bI = 1, #reviveBuffs do
                    local buff = BC.initSoldierBuff(reviveBuffs[bI], camp, self.soldier[i].caster, self.soldier[i])
                    self.soldier[i]:addBuff(buff)
                end
            end
        end

        local allReviveBuffs = logic:getHero(camp).allReviveBuff
        if allReviveBuffs and #allReviveBuffs > 0 then
            logic:addReviveBuffAll(camp)
        end

        if not BATTLE_PROC then
            objLayer:playEffect_skill1("tianshilianmengfuhuo1_tianshilianmengfuhuo", self.x, self.y, true, true, nil, 1.2)
            objLayer:playEffect_skill1("tianshilianmengfuhuo2_tianshilianmengfuhuo", self.x, self.y, false, true, nil, 1.2)
        end
    end
    self.posDirty = 99
end
-- 有小兵复活了
function BattleTeam:soldierRevive(id)
    self._soldierAliveCount = self._soldierAliveCount + 1

    local soldier = self.soldier[id]
    self.dieSoldier[id] = nil
    self.aliveSoldier[self._soldierAliveCount] = soldier
    soldier.aliveID = self._soldierAliveCount

    if self.state == ETeamStateDIE then
        -- 死亡的队伍
        self.x, self.y = soldier.x, soldier.y
        if BC.SHOW_TEAM_DIE_ICON and not BC.jump and self.camp == 1 then
            objLayer:updateTeamDieIcon(self.ID, false)
        end
        logic:teamAttackOver(self)
        logic:onTeamRevive(self)
        self.__needShowHUD = true
        self.dieTick = -1
        self:invokeSkill7()
        local iteamId = 0
        if self.D and self.D.id then
            iteamId = self.D.id
        end
        if logic.onTeamReviveFunc[self.camp] then
            logic.onTeamReviveFunc[self.camp](logic, iteamId)
        end
    else
        -- 如果在移动中
        if self.isMove then
            self:moveTo(self._moveDstx, self._moveDsty, self._moveSpeed)
        end
    end
    if SRData then 
        self.reviveCount = self.reviveCount + 1
    end
    self.posDirty = 99
end

if BATTLE_PROC then
function BattleTeam:stopMove(childStop)
    self.isMove = false
    if childStop then
        local soldier = nil
        for i = 1, self.number do
            soldier = self.soldier[i]
            if not soldier.die then
                if soldier.isMove then
                    soldier:stopMove()
                else
                    soldier.teamMoveDstX = nil
                    soldier.teamMoveDstY = nil
                end
            end
        end  
    end
end
else
function BattleTeam:stopMove(childStop)
    if self.isMove then
        self.isMove = false
        self:stopMoveSound()
    end
    if childStop then
        local soldier = nil
        for i = 1, self.number do
            soldier = self.soldier[i]
            if not soldier.die then
                if soldier.isMove then
                    soldier:stopMove()
                else
                    soldier.teamMoveDstX = nil
                    soldier.teamMoveDstY = nil
                end
            end
        end  
    end
end
end

function BattleTeam:moveTo(x, y, speed)
    if not self:getCanMove() then
        return
    end
    if not self.isMove then
        self._updateIndex = 1
        self:playMoveSound()
    end
    self.isMove = true
    self._moveDstx, self._moveDsty = x, y
    self._moveSpeed = speed
    local nx, ny
    local sx, sy = self.x, self.y 
    local count = #self.aliveSoldier
    local soldier = nil
    for i = 1, count do
        soldier = self.aliveSoldier[i]
        if not soldier.die then
            nx, ny = soldier:getOffsetPos()
            soldier.teamMoveDstX, soldier.teamMoveDstY = x + nx, y + ny
        end
    end  
    self.rangeRan = nil
end
function BattleTeam:getCanMove()
    if self.canMoveDirty then
        -- 全队都可以移动, 才可以移动
        local canMove = true
        local list = self.aliveSoldier
        if canMove then
            for i = 1, #list do
                if not list[i].canMove then 
                    canMove = false
                    break
                end
            end
        end
        self.canMove = canMove
        self.canMoveDirty = false
        return canMove
    else
        return self.canMove 
    end
end

-- function BattleTeam:getCanFuhuo()
--     if self.canFuhuoDirty then
--         -- 全队都可以移动, 才可以移动
--         local canFuhuo = true
--         local list = self.aliveSoldier
--         if #list > 0 then
--             for i = 1, #list do
--                 if list[i].banfuhuo and list[i].banfuhuo > 0 and 
--                 (not logic:getHero(self.camp).lastDieId or logic:getHero(self.camp).lastDieId ~= self.ID)  then 
--                     canFuhuo = false
--                     break
--                 end
--             end
--         else
--             canFuhuo = self.soldier[1] and self.soldier[1].banfuhuo <= 0
--         end
--         self.canFuhuo = canFuhuo
--         self.canFuhuoDirty = false
--         return canFuhuo
--     else
--         return self.canFuhuo 
--     end
-- end

local getCellByScenePos = BC.getCellByScenePos
local ActionValue = BC.ActionValue
local BattleSoldier_updateMove = BattleSoldier.updateMove
local BattleTeam_getMSpeed = BattleTeam.getMSpeed
local BattleSoldier_updateSoldier = BattleSoldier.updateSoldier
function BattleTeam:update(tick, delta, updateSoldier)
    local x, y
    local list = self.aliveSoldier
    local soldier
    local aliveCount = #list
    --[[
         每次调用BattleSoldier:setPos，posDirty会加1 《== BattleObject:updateMove
    ]]
    -- 更新士兵的位置
    if self.posDirty >= aliveCount and logic.battleState == 2 then
        if aliveCount > 0 then
            if self.volume < 5 then
                local minx, miny, maxx, maxy = MAX_SCENE_WIDTH_PIXEL, MAX_SCENE_HEIGHT_PIXEL, 0, 0
                for i = 1, aliveCount do
                    soldier = list[i]
                    if soldier.isMove then
                        BattleSoldier_updateMove(soldier, tick)
                    end
                    x, y = soldier.x, soldier.y
                    if x < minx then minx = x end
                    if x > maxx then maxx = x end
                    if y < miny then miny = y end
                    if y > maxy then maxy = y end
                end
                self.minx, self.miny, self.maxx, self.maxy = minx, miny, maxx, maxy
                self.x = (minx + maxx) * 0.5
                self.y = (miny + maxy) * 0.5
            else
                -- 1人方阵
                soldier = list[1]
                if soldier.isMove then
                    BattleSoldier_updateMove(soldier, tick)
                end
                local x, y = soldier.x, soldier.y
                self.x = x
                self.y = y
                self.minx, self.miny, self.maxx, self.maxy = x - 50, y - 50, x + 50, y + 50
            end
        end
        if self.stateLabel then
            local x, y = self.x, self.y
            self.stateLabel:setPosition(x, y)
            local pos = cc.p(self.x, self.y)
            
            local drawNode = objLayer:lGetDrawNode(self.ID, objLayer._rootLayer)
            if drawNode then
                local aPositions = {}
                drawNode:clear()
                local _c4f = cc.c4f(1,0,0,1)
                if self.camp == 1 then
                    _c4f = cc.c4f(0,0,1,1)
                end
                --圆形，参数：原点，半径，弧度，分段(越大越接近圆)，原点到弧度的线是否显示，线条宽度，颜色
                --const Vec2 &center, float radius, float angle, unsigned int segments, bool drawLineToCenter, const Color4F &color
                if BattleUtils.XBW_SKILL_TEAM_ATTACK_ARER_TYPE and BattleUtils.XBW_SKILL_TEAM_ATTACK_ARER_TYPE == 1 then
                    drawNode:drawCircle(pos, self.attackArea, 0, 50, false, _c4f)
                else
                    drawNode:drawDot(pos, 4, _c4f)
                end
            end
        end
        self.posDirty = 0
        if self.__needShowHUD then
            self.__needShowHUD = false
            if not BATTLE_PROC then
                objLayer:showTeamHUD(self)
            end
        end
    else
        for i = 1, aliveCount do
            soldier = list[i]
            if soldier.isMove then
                BattleSoldier_updateMove(soldier, tick)
            end
        end
    end
    if BattleUtils.XBW_SKILL_DEBUG and not BATTLE_PROC then
        if self.stateLabel then
            if self.state == ETeamStateDIE then
                self.stateLabel:setString("")
                local drawNode = objLayer:lGetDrawNode(self.ID, objLayer._rootLayer)
                if drawNode then
                    drawNode:clear()
                end
            else
                local _soldier = self.aliveSoldier[1]
                if _soldier and _soldier._nAttackCount then
                    local targetId = 0
                    if _soldier.targetS ~= nil then
                        targetId = _soldier.targetS.team.ID
                    end  
                    self.stateLabel:setString(_soldier._nAttackCount .. "_" .. self.ID .. "_" .. (targetId or 0))
                end
            end
        end
        
    end
    if updateSoldier then
        local actionValue = self._actionValue
        actionValue = actionValue + delta
        if aliveCount > 0 then
            local oneAction = ActionValue[aliveCount]

            local speed
            if self.speedDirty then
                speed = BattleTeam_getMSpeed(self)
            else
                speed = self.speed
            end
            if actionValue > oneAction then
                local updateIndex = self._updateIndex
                local count = self.number
                while true do    
                    if not self.soldier[updateIndex].die then
                        -- 刷新每个士兵的状态
                        BattleSoldier_updateSoldier(self.soldier[updateIndex], speed)
                        actionValue = actionValue - oneAction 
                        if actionValue <= oneAction then
                            updateIndex = updateIndex + 1
                            if updateIndex > count then
                                updateIndex = 1
                            end
                            break
                        end
                    end
                    updateIndex = updateIndex + 1
                    if updateIndex > count then
                        updateIndex = 1
                    end
                end
                self._updateIndex = updateIndex
            end
        end
        self._actionValue = actionValue
        if self.isMove and not self:getCanMove() then
            self:stopMove(true)
        end
    end
end

function BattleTeam:isOutScreen(BC_reverse, MAX_SCENE_WIDTH_PIXEL)
    local screenX, screenY = logic:convertToScreenPt(BC_reverse and MAX_SCENE_WIDTH_PIXEL - self.x or self.x, self.y)
    local _
    if #self.aliveSoldier == 1 then
       _, screenY = objLayer:getRoleCenterScreenPt(self.aliveSoldier[1].ID)
    end
    if self.state ~= ETeamStateDIE then
        if screenX < 0 then
            self.screenY = screenY
            return 0 + 38
        elseif screenX > MAX_SCREEN_WIDTH then
            self.screenY = screenY
            return MAX_SCREEN_WIDTH - 38
        end
    else
        return 0
    end
    return 0
end

local BattleSoldier_updateBuff = BattleSoldier.updateBuff
function BattleTeam:updateTeamBuff(tick)
    self:updateBuff(tick)
    local soldiers = self.soldier
    for i = 1, #soldiers do   
        if not soldiers[i].die then
            BattleSoldier_updateBuff(soldiers[i], tick)
        end
    end
    -- 召唤物生存时间
    if self.lifeOverTime then
        if self.lifeOverTime < logic.battleTime - 0.00000001 then
            for i = 1, #soldiers do
                if not soldiers[i].die then
                    soldiers[i]:clearBuff()
                    soldiers[i]:rap(nil, -9999999999, false, false, 0, 199, true)
                end
            end
        end
    end
end

--测试的时候强制死亡
function BattleTeam:lSetForceDie()
    local soldiers = self.soldier
    for i = 1, #soldiers do
        if not soldiers[i].die then
            -- soldiers[i]:clearBuff()
            soldiers[i]:rap(nil, -9999999999, false, false, 0, 199, true)
        end
    end
end

local statelabelColor = {cc.c3b(255, 255, 255), cc.c3b(50, 255, 255), cc.c3b(255, 100, 100), cc.c3b(255, 255, 255), cc.c3b(50, 255, 50), cc.c3b(128, 128, 128)}
function BattleTeam:setState(state)
    if self.state ~= state then
        self.speedDirty = true
        self.stateChangeTime = logic.battleTime
    end
    self.state = state
    if self.state == ETeamStateMOVE and not self.walk then
        self.state = ETeamStateIDLE 
    end
    if self.state == ETeamStateATTACK then
        self.firstAttack = true
        local count = self.number
        for i = 1, count do
            self.soldier[i].firstAttack = true
        end
    end
    if self.stateLabel then
        self.stateLabel:setString(self.ID)
        if self.state == ETeamStateDIE then
            self.stateLabel:setString("")
        end
--        self.stateLabel:setColor(statelabelColor[self.state])
    end
end

local ATTR_Hot = BC.ATTR_Hot
local ATTR_Shiqi = BC.ATTR_Shiqi
local initSoldierBuff = BC.initSoldierBuff
local BUFF_ID_SHIQIGAOZHANG = 1999
local BUFF_ID_SHIQIDILUO = 1998
function BattleTeam:hot(tick, shiqiBuff)
    if self.state == ETeamStateDIE then
        return
    end

    if tick > self._nextHotTick + 0.00000001 then
        self._nextHotTick = tick + 3
    else
        return
    end
    local hot
    local list = self.soldier
    local soldier
    for i = 1, #list do
        soldier = list[i]
        if not soldier.die then
            hot = soldier.attr[ATTR_Hot]
            if hot > 0 then
                soldier:heal(nil, hot, true)
            end
        end
    end

    -- 士气
    local shiqi = false
    -- self.shiqiValue = self.shiqiValue + self.shiqi
    -- if shiqiBuff and tick > self._shiqiBuffTick + 5 then
    --     if self.shiqiValue >= 100 then
    --         self._shiqiBuffTick = tick + 5
    --         shiqi = true
    --         -- 士气高涨
    --         self.shiqiValue = 0
    --         objLayer:playEffect_skill1("shiqigaozhang_shiqieff", self.x, self.y, true, true)
    --         local buff
    --         for i = 1, #list do
    --             buff = initSoldierBuff(BUFF_ID_SHIQIGAOZHANG, 1, list[i].caster, nil)
    --             list[i]:addBuff(buff)
    --         end
    --         -- 士气高涨触发技能
    --         if #list > 0 then
    --             list[1]:invokeSkill(19)
    --         end
    --         logic:invokeSkill20(self.camp)
    --     elseif self.shiqiValue <= -100 then
    --         self._shiqiBuffTick = tick + 5
    --         shiqi = true
    --         -- 士气萎靡
    --         self.shiqiValue = 0
    --         local buff
    --         objLayer:playEffect_skill1("shiqidiluo_shiqieff", self.x, self.y, true, true)
    --         for i = 1, #list do
    --             buff = initSoldierBuff(BUFF_ID_SHIQIDILUO, 1, list[i].caster, nil)
    --             list[i]:addBuff(buff)
    --         end
    --     end
    -- end

    return shiqi
end

local invX = {0, 36, 36, 33, 33, 33, 30, 30, 30, 28, 28, 28, 25, 25, 25, 25}
local invY = {0, 22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 17, 16, 16, 15, 15}
local inv_melee_X = {}
local inv_melee_Y = {}
for i = 1, #invX do
    inv_melee_X[i] = invX[i] * 0.6
    inv_melee_Y[i] = invY[i] * 0.8
end

-- 这里适用于 来自不同路的接战位
local meleeEx16_1 = {{-1, 4}, {0, 5}, {-2, 4}, {-2, 3}, {-3, 3}, {-2, 5}, {-2, 2}, {-1, 6},
                   {0, 4}, {0, 4}, {0, 4}, {0, 4}, {0, 4}, {0, 4}, {0, 4}, {0, 4}}
local meleeEx16_2 = {{-1, 4}, {-2, 3}, {-2, 4}, {-3, 3}, {-2, 5}, {0, 5}, {-3, 4}, {-1, 6},
                   {-3, 5}, {-3, 5}, {-3, 5}, {-3, 5}, {-3, 5}, {-3, 5}, {-3, 5}, {-3, 5}}
local melee16Ex = {meleeEx16_1, meleeEx16_2}
-- 方阵接战点, 阵营正方向2个点, 反方向1个点
--[[
        3 方阵-> 1  2        2  1 <-方阵 3
]]--
local order1 = {3, 1, 2}
local order2 = {1, 2, 3}
function BattleTeam:setTargetT(target, dontSetPos)
    self.hasTargeted = true
    local melee = self.isMelee
    local oldTarget = self.targetT
    if oldTarget and melee and self.beatIdx then
        local beatPos = oldTarget.beatPos
        beatPos[self.beatIdx] = beatPos[self.beatIdx] - 1
        if self.beatIdx == 1 then
            self.beatPosDirty = true
        end
        self.beatIdx = nil
    end
    self.targetT = target
    if target then
        -- print(logic.battleTime, "setTargetT", self.ID, target.ID)
        -- 进入战斗的时候目标的目标
        self.targetTTarget = target.targetT 
        if melee then
            -- 如果目标在战斗中并且自己与目标不是同一排的, 就根据Y的方向 固定站位
            
            if target.isMelee and target.state == ETeamStateATTACK and self.row ~= target.row and self.volume < 5 and target.volume < 5 and not dontSetPos then
                -- 目标的目标
                -- 计算出目标与 目标的目标的战斗中心点,  然后在模拟出目标的最终站位点
                -- 摆偏阵
            
                local fx, fy
                if target.fight_PtX then
                    fx, fy = target.fight_PtX, target.fight_PtY
                else
                    -- 没有fight_PtX 说明他的目标目标是远程或者是 （近战单方进攻且同row）
                    local targetTarget = target.targetT 
                    if targetTarget.isMelee and targetTarget.fight_PtX then
                        fx, fy = targetTarget.fight_PtX, targetTarget.fight_PtY             
                    else
                        fx, fy = targetTarget.x, targetTarget.y
                    end
                    local offsetX = targetTarget.radius + target.radius
                    if target.x < fx - 0.00000001 then
                        fx = fx - offsetX
                    else
                        fx = fx + offsetX
                    end     
                end
                local dx, dy
                if target.isMeleeEx then
                    -- 对面是偏阵的时候，y轴-2
                    dy = -2
                    dx = 0
                else
                    dy = 0
                    dx = -1
                end
                -- self.

                local soldiers = self.soldier
                local count = #soldiers

                local meleeExRan = self.meleeExRan
                if meleeExRan == nil then
                    meleeExRan = random(2)
                    self.meleeExRan = meleeExRan
                end

                local meleePos = melee16Ex[meleeExRan]
                local ix = 26
                local iy = 15

                local kx = 1
                local ky = 1
                local x1, y1 = self.x, self.y
                if x1 > fx + 0.00000001 then kx = -1 end
                if y1 < fy - 0.00000001 then ky = -1 end
                local soldier
                for i = 1, count do
                    soldier = soldiers[i]
                    soldier.fightPtX = fx + ix * (meleePos[i][1] + dx) * 0.8 * kx
                    soldier.fightPtY = fy + iy * (meleePos[i][2] + dy) * 0.8 * ky
                end
                self.fight_PtX = soldiers[1].fightPtX
                self.fight_PtY = soldiers[1].fightPtY
                -- 使用了偏阵
                self.isMeleeEx = true
            else
                local beatPos = target.beatPos
                local tarcamp =  target.camp
                if self.classLabel == 2 then
                    -- 防御单位, 只站1号位
                    local order, idx
                    if tarcamp == 1 then
                        -- 目标是左方
                        if self.x < target.x - 0.00000001 then
                            idx = 3
                        else
                            idx = 1
                        end
                    else
                        -- 目标是右方
                        if self.x < target.x - 0.00000001 then
                            idx = 1
                        else
                            idx = 3
                        end
                    end
                    beatPos[idx] = beatPos[idx] + 1
                    self.beatIdx = idx
                elseif self.volume == 5 then
                    -- 大体型单位, 只站2号位
                    local order, idx
                    if tarcamp == 1 then
                        -- 目标是左方
                        if self.x < target.x - 0.00000001 then
                            idx = 3
                        else
                            idx = 2
                        end
                    else
                        -- 目标是右方
                        if self.x < target.x - 0.00000001 then
                            idx = 2
                        else
                            idx = 3
                        end
                    end
                    beatPos[idx] = beatPos[idx] + 1
                    self.beatIdx = idx
                else
                    local min = 99
                    local minIdx = 0
                    local index
                    local order
                    local count = 3
                    if tarcamp == 1 then
                        -- 目标是左方
                        if self.x < target.x - 0.00000001 then
                            order = order1
                            if not self.goBack then count = 1 end
                        else
                            order = order2
                            if not self.goBack then count = 2 end
                        end
                    else
                        -- 目标是右方
                        if self.x < target.x - 0.00000001 then
                            order = order2
                            if not self.goBack then count = 2 end
                        else
                            order = order1
                            if not self.goBack then count = 1 end
                        end
                    end
                    for i = 1, count do
                        index = order[i]
                        if beatPos[index] == 0 then
                            minIdx = index
                            break
                        end
                        if beatPos[index] < min then
                            min = beatPos[index]
                            minIdx = index
                        end
                    end
                    beatPos[minIdx] = beatPos[minIdx] + 1
                    self.beatIdx = minIdx
                end
            end
        end
    else
        self.targetTTarget = nil
    end
end

-- 近战随机
local melee16_1 = {{0, 1}, {0, -1}, {-1, 0}, {1, -1}, {0, -2}, {0, 2}, {-1, 3}, {-1, -3},
                   {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}}
local melee16_2 = {{0, 0}, {1, 1}, {0, 2}, {-1, -1}, {-1, 3}, {0, -3}, {0, 1}, {1, -2},
                   {-1, -2}, {-1, -2}, {-1, -2}, {-1, -2}, {-1, -2}, {-1, -2}, {-1, -2}, {-1, -2}}
local melee16_3 = {{0, -1}, {1, 0}, {-1, 1}, {1, 2}, {-1, -2}, {0, 3}, {-1, -3}, {-1, 2},
                   {1, -1}, {1, -1}, {1, -1}, {1, -1}, {1, -1}, {1, -1}, {1, -1}, {1, -1}}
local melee16 = {melee16_1, melee16_2, melee16_3}

-- 给近战分配站位
local getRowIndex = BC.getRowIndex
function BattleTeam:setMeleeFightPt()
    local meleeRan = self.meleeRan
    if meleeRan == nil then
        meleeRan = random(3)
        self.meleeRan = meleeRan
    end
    local soldier
    local target = self.targetT -- team
    if target == nil then return end
    local list = self.aliveSoldier
    local count = #list
    if count == 0 then return end
    local x1, y1 = self.x, self.y
    local x2, y2 = target.x, target.y
    local centerX = (x1 + x2) * 0.5
    local centerY = (y1 + y2) * 0.5
    local row = getRowIndex(centerY)
    centerY = BATTLE_ROW_Y[row]

    --接站位
    local meleePos = melee16[meleeRan]

    local ix = inv_melee_X[count]
    local iy = inv_melee_Y[count]  
    local offsetX = (self.radius + target.radius) * 0.5
    if x1 < x2 - 0.00000001 then
        offsetX = -offsetX
    end

    for i = 1, count do
        soldier = list[i]
        -- 攻击位置 
        soldier.fightPtX = centerX + ix * meleePos[i][1] * 1.000 --+ offsetX - 5 + random(10)
        soldier.fightPtY = centerY + iy * meleePos[i][2] * 0.9
    end
    self.fight_PtX = centerX
    self.fight_PtY = centerY
    self.hasMeleeFightPt = true
end

local range16_1 = {{0, 0}, {0, 1}, {0, -1}, {0, 2}, {0, 3}, {0, -3}, {-1, -1}, {-1, 1},
                   {1, -2}, {-1, 3}, {1, 1}, {-1, -2}, {0, -4}, {0, 4}, {-2, 2}, {2, -1}}
local range16_2 = {{0, 0}, {0, -1}, {0, 1}, {-1, -1}, {0, 2}, {0, -3}, {1, 1}, {-1, 2},
                   {0, 4}, {1, -2}, {0, -4}, {-1, -2}, {1, 3}, {-1, 1}, {2, 0}, {-2, -1}}
local range16_3 = {{0, 0}, {0, 1}, {0, -1}, {-1, -1}, {0, -2}, {0, 2}, {-1, 1}, {0, -3},
                   {-1, 3}, {0, 4}, {1, -2}, {2, 1}, {0, -4}, {-1, -3}, {-1, -2}, {-2, 0}}
local range16 = {range16_1, range16_2, range16_3}
local range9_1 = {{0, 0}, {0, -1}, {-1, 1}, {-1, -1}, {0, -2}, {0, 2}, {1, 0}, {0, 3}, {1, -3}}
local range9_2 = {{0, 0}, {0, -1}, {0, 1}, {1, 0}, {0, 2}, {-1, -2}, {1, -1}, {0, 3}, {-1, 1}}
local range9_3 = {{0, 0}, {1, -1}, {0, 1}, {0, -1}, {0, 2}, {0, -2}, {0, -3}, {2, 0}, {0, 3}}
local range9 = {range9_1, range9_2, range9_3}
local rangePt = {nil, range16, range9, range9, {{{0,0}}}}
-- 给远程分配站位
local sin = math.sin
local cos = math.cos
local atan = math.atan
function BattleTeam:setRangeFightPt()
    if self.speedMove == 0 then
        -- 不会走的远程，就不用分配站位了
        local soldier
        local aliveSoldier = self.aliveSoldier
        for i = 1, #aliveSoldier do
            soldier = aliveSoldier[i]
            -- 攻击位置就是当前士兵的位置
            soldier.fightPtX = soldier.x
            soldier.fightPtY = soldier.y
        end
        return
    end

    if self.rangeRan == nil then
        self.rangeRan = random(#rangePt[self.volume])
    end
    local soldier
    local target = self.targetT
    if target == nil then return end
    local aliveSoldier = self.aliveSoldier
    if #aliveSoldier == 0 then return end
    if aliveSoldier[1].fightPtX == nil then
        -- 分配站位时候的人数
        self.setRFPSoldierCount = #aliveSoldier
        local x1, y1 = self.x, self.y
        local x2, y2 = target.x, target.y
        local dx = x2 - x1
        local dy = y2 - y1
        if abs(dx) < 0.0000000001 then
            dx = 0
        end
        if abs(dy) < 0.0000000001 then
            dy = 0
        end
        local a
        if dx == 0 then
            a = 0
        else
            a = atan(dy / dx)
        end
        if tostring(a) == "nan" then
            a = 0
        end
        local sina = sin(a)
        local cosa = cos(a)
        local volume = self.volume
        local rangePos = rangePt[volume][self.rangeRan]
        local x, y, s, t
        local count = #aliveSoldier
        local ix = invX[count]
        local iy = invY[count]
        local bx, by

        local walkDis = 40
        if walkDis < 0 then walkDis = 0 end
        if dx > 0 then
            bx = x1 + walkDis * cosa
            by = y1 + walkDis * sina
        else
            bx = x1 - walkDis * cosa
            by = y1 - walkDis * sina
        end

        for i = 1, count do
            soldier = aliveSoldier[i]
            x, y = rangePos[i][1] * ix - 5 + random(10), rangePos[i][2] * iy - 5 + random(10)
            s = x * cosa + y * sina
            t = y * cosa - x * sina
            soldier.fightPtX = bx + s
            soldier.fightPtY = by + t
        end
    else
        self:stopMove(true)
        for i = 1, #aliveSoldier do
            soldier = aliveSoldier[i]
            soldier.fightPtX, soldier.fightPtY = soldier.x, soldier.y
        end
    end
end
-- 冲刺光影
function BattleTeam:showRunArt()
    local zoom = self.artzoom
    local soldier
    for i = 1, #self.aliveSoldier do
        self.aliveSoldier[i]:showRunArt(zoom)
    end
end

function BattleTeam:addBuff(buff)
    local shiqi = self.shiqi
    BattleTeam.super.addBuff(self, buff)
    local newshiqi = self.shiqi
    if shiqi ~= newshiqi then
        self.shiqiValue = self.shiqiValue + (newshiqi - shiqi) * 10
    end
end

function BattleTeam:clearBuff()
    BattleTeam.super.clearBuff(self)
    self:resetAttr()
end

function BattleTeam:resetAttr()
    BC.countTeamBuffAdd(self)
end


-- 音效相关
local audioMgr = audioMgr
local ATTACK_SOUND_POOL = {} -- 攻击音效
local DIE_SOUND_POOL = { } -- 死亡音效
local LOOP_SOUND_POOL = {} -- 常驻循环音效
local PERM_SOUND_POOL = {} -- 常驻随机音效
local MOVE_SOUND_POOL = {} -- 移动音效
function BattleTeam:initSound()
    -- if not OS_IS_ANDROID then
    --     self:_playSingleTrackSound(self.sound_loop, LOOP_SOUND_POOL, true)
    -- end
end

-- 类方法
function BattleTeam.finishSound()
    for _, soundInfo in pairs(LOOP_SOUND_POOL) do
        if soundInfo.playing then
            audioMgr:stopSound(soundInfo.soundId)
        end
    end
end

function BattleTeam:playMoveSound()
    if BC.jump then return end
    local sound = self.sound_move
    if sound then
        local play = false
        local soundInfo = MOVE_SOUND_POOL[sound]
        if soundInfo then
            soundInfo.count = soundInfo.count + 1
        else
            soundInfo = {playing = true, soundId = 0, minVol = self.farvol, dVol = self.nearvol - self.farvol, count = 1}
            play = true
        end
        if play then
            local scale = BC.NOW_SCENE_SCALE - 1
            local sceneVolPro = soundInfo.minVol + soundInfo.dVol * scale
            soundInfo.soundId = audioMgr:playSoundEx(sound, true, sceneVolPro * 0.03)
            MOVE_SOUND_POOL[sound] = soundInfo
        end
    end
end
function BattleTeam:stopMoveSound()
    if BC.jump then return end
    local sound = self.sound_move
    if sound then
        local soundInfo = MOVE_SOUND_POOL[sound]
        if soundInfo then
            soundInfo.count = soundInfo.count - 1
            if soundInfo.count == 0 then
                soundInfo.playing = false
                audioMgr:stopSound(soundInfo.soundId)
            end
        end
    end
end

function BattleTeam:playAttackSound()
    if BC.jump then return end
    if self.sound_atk then
        self:_playSingleTrackSound(self.sound_atk, ATTACK_SOUND_POOL, false)
    end
end
function BattleTeam:playDieSound()
    if BC.jump then return end
    if self.sound_die then
        self:_playSingleTrackSound(self.sound_die, DIE_SOUND_POOL, false, GRandom(3))
    end
end

-- 单音轨音效, 播放完毕才可播放
function BattleTeam:_playSingleTrackSound(name, pool, loop, delay)
    local sound = name
    if sound then
        local play = false
        local soundInfo = pool[sound]
        if soundInfo then
            if not soundInfo.playing then
                soundInfo.playing = true
                play = true
            end
        else
            soundInfo = {playing = true, soundId = 0, minVol = self.farvol, dVol = self.nearvol - self.farvol}
            play = true
        end
        if play then
            local scale = BC.NOW_SCENE_SCALE - 1
            local sceneVolPro = soundInfo.minVol + soundInfo.dVol * scale
            soundInfo.soundId = audioMgr:playSoundEx(sound, loop, sceneVolPro * 0.02)
            pool[sound] = soundInfo

            local d = delay
            if d == nil then
                d = 0
            end
            ScheduleMgr:delayCall(2000 + d * 1000, nil, function()
                pool[sound].playing = false
            end)

        end
    end
end

-- 类方法
function BattleTeam.onSceneScale()
    if BC.jump then return end
    -- if OS_IS_ANDROID then return end
    local scale = BC.NOW_SCENE_SCALE - 1
    local pools = {ATTACK_SOUND_POOL, DIE_SOUND_POOL, LOOP_SOUND_POOL, PERM_SOUND_POOL, MOVE_SOUND_POOL}
    for i = 1, #pools do
        for _, soundInfo in pairs(pools[i]) do
            if soundInfo.playing then
                local sceneVolPro = soundInfo.minVol + soundInfo.dVol * scale
                audioMgr:setVolumeEx(soundInfo.soundId, sceneVolPro * 0.02)
            end
        end
    end
end

function BattleTeam.dtor()
    ActionValue = nil -- BC.ActionValue
    atan = nil -- math.atan
    ATTACK_SOUND_POOL = nil -- {} -- 攻击音效
    ATTR_Hot = nil -- BC.ATTR_Hot
    ATTR_Shiqi = nil -- BC.ATTR_Shiqi
    audioMgr = nil -- audioMgr
    
    BattleSoldier = nil 
    BattleTeam = nil 
    BC = nil -- BC
    BUFF_ID_SHIQIDILUO = nil -- 1998
    BUFF_ID_SHIQIGAOZHANG = nil -- 1999
    cc = nil -- _G.cc
    
    cos = nil -- math.cos
    DIE_SOUND_POOL = nil -- { } -- 死亡音效
    ECamp = nil -- BC.ECamp
    EDirect = nil -- BC.EDirect
    EEffFlyType = nil -- BC.EEffFlyType
    EMotion = nil -- BC.EMotion
    EState = nil -- BC.EState
    ETeamState = nil -- BC.ETeamState
    ETeamStateATTACK = nil -- ETeamState.ATTACK
    ETeamStateDIE = nil -- ETeamState.DIE
    ETeamStateIDLE = nil -- ETeamState.IDLE
    ETeamStateMOVE = nil -- ETeamState.MOVE
    ETeamStateNONE = nil -- ETeamState.NONE
    ETeamStateSORT = nil -- ETeamState.SORT
    getCellByScenePos = nil -- BC.getCellByScenePos
    initSoldierBuff = nil -- BC.initSoldierBuff
    invX = nil 
    invY = nil 
    logic = nil
    LOOP_SOUND_POOL = nil -- {} -- 常驻循环音效
    math = nil -- math
    MAX_SCENE_HEIGHT_PIXEL = nil -- BC.MAX_SCENE_HEIGHT_PIXEL
    MAX_SCENE_WIDTH_PIXEL = nil -- BC.MAX_SCENE_WIDTH_PIXEL
    mcMgr = nil -- mcMgr
    MOVE_SOUND_POOL = nil -- {} -- 移动音效
    next = nil -- next
    objLayer = nil
    os = nil -- _G.os
end

function BattleTeam.dtor1()
    pairs = nil -- pairs
    pc = nil -- pc
    PERM_SOUND_POOL = nil -- {} -- 常驻随机音效
    random = nil -- BC.ran
    range16 = nil -- {range16_1, range16_2, range16_3}
    range16_1 = nil 
    range16_2 = nil 
    range16_3 = nil 
    range9 = nil 
    range9_1 = nil 
    range9_2 = nil 
    range9_3 = nil 
    rangePt = nil 
    sin = nil -- math.sin
    statelabelColor = nil 
    tab = nil -- tab
    table = nil -- table
    tonumber = nil -- tonumber
    tostring = nil -- tostring
    floor = nil
    super = nil
    order1 = nil
    order2 = nil
    melee16_1 = nil
    melee16_2 = nil
    melee16_3 = nil
    BattleSoldier_updateMove = nil
    BattleTeam_getMSpeed = nil
    BattleSoldier_updateSoldier = nil
    BattleSoldier_updateBuff = nil
    BATTLE_ROW_Y = nil
    inv_melee_X = nil
    inv_melee_Y = nil
    getRowIndex = nil
    delayCall = nil
    melee16Ex = nil
    meleeEx16_1 = nil
    meleeEx16_2 = nil
    initSkill = nil
    SRData = nil
    abs = nil
end

return BattleTeam
