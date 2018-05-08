
--[[
    Filename:    BattleSoldierCreator.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-01-08 20:01:28
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
local sfResMgr = sfResMgr

local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType

local ATTR_AtkPro = BC.ATTR_AtkPro
local ATTR_HPPro = BC.ATTR_HPPro
local ATTR_HP = BC.ATTR_HP
local ATTR_Shiqi = BC.ATTR_Shiqi
local ATTR_AtkDis = BC.ATTR_AtkDis
local ATTR_MSpeed = BC.ATTR_MSpeed
local ATTR_COUNT = BC.ATTR_COUNT
local ATTR_Atk = BC.ATTR_Atk
local ATTR_Haste = BC.ATTR_Haste
local ATTR_Def = BC.ATTR_Def
local ATTR_DamageDec = BC.ATTR_DamageDec
local ATTR_DecAll = BC.ATTR_DecAll


local BATTLE_CELL_SIZE = BC.BATTLE_CELL_SIZE
-- 根据英雄ID 品质 等级 兵种阶级 兵种星数 生成方阵

-- 给的ID是英雄的BaseID, 根据英雄的品质找到相对应的英雄表ID, 获取到方阵BaseID, 再根据方阵的的star找到对应的方阵表ID
-- 英雄的level影响英雄的属性和方阵的属性

-- 不同体型占地面积
local teamRadius = {0, 18, 22, 26, 55, 250}

local PokedexAttr = BC.PokedexAttr

local EAtkTypeMELEE = BC.EAtkType.MELEE
local EMoveTypeAIR = BC.EMoveType.AIR
local AnimAP = require "base.anim.AnimAP"
function BC.initTeamAttr_Common(team, hero, info, x, y, scale)
    team.hero = hero
    team.info = info
    team.level = info.level
    team.canDestroy = true
    team.x, team.y = x, y
    team.minx, team.miny, team.maxx, team.maxy = x, y, x, y
    local teamD = tab.team[info.teamid]
    team.D = teamD
    team.DType = 1
    team.race1 = teamD["race"][1]
    team.race2 = teamD["race"][2]
    team.summon = info.summon
    team.building = false
    team.label = teamD["summon"]
    team.label1 = teamD["label1"]
    team.volume = teamD["volume"]
    team.attackRange = 1
    team.maxNumber = BC.VolumeNumber[team.volume]
    if scale then
        team.picScale = scale
    else
        team.picScale = teamD["scale"] * 0.005
    end
    team.scale = team.picScale * 2
    local res, res1
    if info.jx then
        res = teamD["jxart"]
        res1 = teamD["jxart1"]
    else
        res = teamD["art"]
        res1 = teamD["art1"]
    end
    team.jx = info.jx
    -- radius 兵团的接战半径 (多少半径内不能有其他士兵)
    if AnimAP["mcList"][res] then
        team.radius = AnimAP["mcList"][res]["R"] * team.scale
    elseif AnimAP[res] then
        team.radius = AnimAP[res]["R"] * team.scale
    else
        team.radius = teamRadius[team.volume] * team.scale
    end
    if info.number then
        team.number = info.number
    else
        team.number = team.maxNumber
    end
    -- attackArea 停下后的攻击距离
    team.attackArea = teamD["attackarea"]-- * team.scale
    if team.attackArea > 0 and team.attackArea < 80 then
        team.attackArea = 80
    end
    if team.attackArea > 0 and team.attackArea < team.radius + 10 then
        team.attackArea = team.radius + 10
    end
    -- atkrange 进入攻击的范围
    team.patrolArea = teamD["atkrange"] * teamD["atkrange"]
    team.rush = teamD["rush"]
    team.atkType = teamD["atktype"]
    team.moveType = teamD["movetype"]
    team.speedMove = teamD["speedmove"]
    -- 填写-1 说明不会走路, 而且有出生动画
    team.walk = team.speedMove >= 0
    if not team.walk then
        team.attackArea = 9999
    end
    team.speedAttack = teamD["speedattack"]
    team.atkfly = teamD["atkfly"]
    team.bullet = teamD["fly"]
    team.bullet2 = teamD["fly2"]
    team.shadow = teamD["s"]
    team.boom = teamD["boom"]
    team.boom1 = teamD["boom1"]
    team.flyspeed = teamD["flyspeed"]
    team.resID = res
    team.headPic = res1
    team.classLabel = teamD["class"]

    team.calculation = teamD["cf"]
    team.calculation1 = teamD["cf1"]
    team.artzoom = teamD["artzoom"] * 0.01
    team.atkshake = teamD["atkshake"]
    team.dieshake = teamD["dieshake"]
    team.runart = teamD["runart"]
    team.goBack = true -- 绕背
    team.turnFire = teamD["turnfire"] ~= nil
    if teamD["meleepro"] then
        team.meleePro = teamD["meleepro"] * 0.01
    else
        team.meleePro = 1
    end
    if team.meleePro == nil then
        team.meleePro = 1
    end
    team.isMercenary = info.isMercenary

    -- 积分联赛
    team.leagueBuff = info.leagueBuff
    team.hudSp = (team.leagueBuff ~= nil or info.hudSp)

    -- 符文宝石
    team.rune = info.rune

    team.isMelee = team.atkType == EAtkTypeMELEE
    team.isFly = team.moveType == EMoveTypeAIR

    team:setState(ETeamState.MOVE)

    team.skillLevels = info.skill
    BC.initTeamSkill(team, teamD, teamD["skill"], teamD["cs"], teamD["hideSkill"],  team.skillLevels, info)
    BC.initTeamSound(team)

    team:createSoldiers({info, info.equip}, BC.initSoldiersAttr_Common)
end

local ceil = math.ceil
function BC.initSoldiersAttr_Common(team, soldiers, info)
    local count = #soldiers
    if count == 0 then
        return
    end
    local hero = team.hero
    local _v = team.volume - 1
    if _v > 4 then
        _v = 4
    end
    if _v < 1 then
        _v = 1
    end
    local attrAdd = hero.attr[team.moveType][team.classLabel][_v]
    local attrAdd1 = nil
    if team.label1 then
        attrAdd1 = hero.attr1[team.label1]
    end
    local attrAdd2 = hero.attr2
    local attrAdd4_0 = hero.attr4 and hero.attr4[0] and hero.attr4[0][team.moveType][team.classLabel][_v][team.D.race[1]] or {}
    local attrAdd4_1 = hero.attr4 and hero.attr4[BattleUtils.CUR_BATTLE_TYPE] and hero.attr4[BattleUtils.CUR_BATTLE_TYPE][team.moveType][team.classLabel][_v][team.D.race[1]] or {}
    local camp = team.camp
    -- 基础属性
    -- teamid, star, stage, level, equip
    local baseAttr, atkspeed = BattleUtils.getTeamBaseAttr(info[1], info[2], PokedexAttr[camp], BC.ClassCount[camp], BC.MoveTypeCount[camp], BC.Race1Count[camp], team.passives, BC.XCount and BC.XCount[camp])

    local volume = team.volume
    local classLabel = team.classLabel
    local radius = team.radius
    local count = #soldiers
    local soldier

    -- 积分联赛
    if team.leagueBuff then
        local value = team.leagueBuff
        baseAttr[2] = baseAttr[2] + value
        baseAttr[5] = baseAttr[5] + value
    end

    -- 爬塔副本
    if team.purBuff then
        local values = team.purBuff
        for k,value in pairs(values) do
            local a = tonumber(k)
            baseAttr[a] = baseAttr[a] + tonumber(value)
        end
    end 

    if attrAdd1 then
        for a = 1, ATTR_COUNT do
            baseAttr[a] = ceil(baseAttr[a] + attrAdd[a] + attrAdd1[a] + attrAdd2[a] + (attrAdd4_0[a] or 0)+ (attrAdd4_1[a] or 0))
        end
    else
        for a = 1, ATTR_COUNT do
            baseAttr[a] = ceil(baseAttr[a] + attrAdd[a] + attrAdd2[a] + (attrAdd4_0[a] or 0)+ (attrAdd4_1[a] or 0))
        end
    end

    -- 攻击距离
    team.attackArea = team.attackArea + baseAttr[ATTR_AtkDis]
    local attackarea = team.D["attackarea"]
    for i = 1, count do
        soldier = soldiers[i]
        -- 所有base属性的初始值
        for a = 1, ATTR_COUNT do
            soldier.baseAttr[a] = baseAttr[a]
        end
        -- soldier.baseAttr[BC.ATTR_Atk] = 999
        soldier.attackarea = attackarea
        soldier.atkspeed = atkspeed
        soldier.radius = radius
        soldier.resist = {1, 1, 1, 1, 1, 1, 1, 1}
        soldier:resetAttr()
        soldier.HP = soldier.maxHP

        BC["initHitPos"..volume](soldier)
        -- 普攻用, 不另生成
        --[[
            pen :破甲
            hit :命中值
            dmgInc :兵团伤害%
            heal :治疗
            healPro :治疗%
            aHPPro :吸血%
        ]]
        soldier.caster = {
                        x = 0,
                        y = 0,
                        attacker = soldier,
                        atk = 0,
                        crit = 0,
                        critD = 0,
                        pen = 0,
                        hit = 0,
                        dmgInc = 0,
                        heal = 0,
                        healPro = 0,
                        aHPPro = 0,
                        level = team.level,
                        camp = camp,
                    }

        if BattleUtils.XBW_SKILL_DEBUG and i == 1 then
            soldier:printAttr()
        end
    end
    
    if count > 0 then
        team.baseSpeedAdd = soldiers[1].attr[ATTR_MSpeed]
        team.baseShiqi = soldiers[1].attr[ATTR_Shiqi] + hero.shiQi
        team.shiqiValue = team.shiqi * 5
        team:resetAttr()
    end

end
-- 通过npc表生成方阵
function BC.initTeamAttr_Npc(team, hero, info, x, y, scale, isBuilding, summonAttr)
    team.hero = hero
    team.info = info
    team.level = info.level
    team.lzyscore = info.lzyteamscore
    team.lzystar = info.lzyteamstar
    team.lzylvdis = info.lzyteamlvdis
    team.lzyquality = info.lzyteamquality
    team.canDestroy = true
    team.x, team.y = x, y
    team.minx, team.miny, team.maxx, team.maxy = x, y, x, y
    local npcD = tab.npc[info.npcid]
    local teamD
    if npcD["match"] then
        teamD = tab.team[npcD["match"]]
    end

    local skillLevels = nil
    if info.skillLevels then
        skillLevels = info.skillLevels
    end 

    local summonSkills = nil
    if summonAttr and summonAttr[8] then
        summonSkills = summonAttr[8]
    end

    if not info.lzyjx and npcD["jx"] == 1 then
        info.jx = true
        info.jxLv = npcD["jxLv"]
        info.jxSkill1 = npcD["jxSkill1"]
        info.jxSkill2 = npcD["jxSkill2"]
        info.jxSkill3 = npcD["jxSkill3"]
    end

    if teamD then
        -- 为了优化NPC表字段
        team.D = npcD
        team.DType = 2
        if npcD["race"] then
            team.race1 = npcD["race"][1]
            team.race2 = npcD["race"][2]
        end
        team.halo = npcD["hx"] == 1
        team.summon = info.summon
        team.building = isBuilding
        if team.building or team.summon then
            team.showHead = false
        end
        team.label = npcD["summon"] or 1
        team.label1 = npcD["label1"]
        team.volume = npcD["volume"] or teamD["volume"]
        team.attackRange = 1
        team.maxNumber = BC.VolumeNumber[team.volume]
        local _scale = npcD["scale"] or 100
        if scale then
            team.picScale = scale * _scale * 0.005
        else
            team.picScale = _scale * 0.005
        end
        team.scale = team.picScale * 2
        local res = npcD["art"]
        if AnimAP["mcList"][res] then
            team.radius = AnimAP["mcList"][res]["R"] * team.scale
        elseif AnimAP[res] then
            team.radius = AnimAP[res]["R"] * team.scale
        else
            team.radius = teamRadius[team.volume] * team.scale
        end
        if info.number and info.number <= team.maxNumber then
            team.number = info.number
        else
            team.number = team.maxNumber
        end
        team.attackArea = npcD["aa"] or teamD["attackarea"]-- * team.scale
        if team.attackArea > 0 and team.attackArea < 80 then
            team.attackArea = 80
        end
        if team.attackArea > 0 and team.attackArea < team.radius + 10 then
            team.attackArea = team.radius + 10
        end
        team.patrolArea = npcD["ar"] or teamD["atkrange"]
        team.patrolArea = team.patrolArea * team.patrolArea
        team.rush = npcD["rush"] or teamD["rush"]
        team.atkType = npcD["at"] or teamD["atktype"]
        team.moveType = npcD["mot"]
        team.speedMove = npcD["sm"] or teamD["speedmove"]
        -- 填写-1 说明不会走路, 而且有出生动画
        team.walk = team.speedMove >= 0
        if not team.walk then
            team.attackArea = 9999
        end
        team.speedAttack = npcD["sa"] or teamD["speedattack"]
        team.atkfly = npcD["af"] or teamD["atkfly"]
        team.bullet = npcD["fly"] or teamD["fly"]
        team.bullet2 = npcD["fly2"] or teamD["fly2"]
        team.shadow = npcD["s"] or teamD["s"]
        team.boom = npcD["boom"] or teamD["boom"]
        team.boom1 = npcD["boom1"]
        team.flyspeed = npcD["fs"] or teamD["flyspeed"]
        team.resID = npcD["art"]
        team.headPic = npcD["art1"] or teamD["art1"]
        team.classLabel = npcD["class"]
        if team.classLabel == nil then
            team.classLabel = 1
        end

        team.calculation = npcD["cf"] or teamD["cf"]
        team.calculation1 = npcD["cf1"] or teamD["cf1"]
        team.artzoom = (npcD["az"] or teamD["artzoom"]) * 0.01
        team.atkshake = npcD["atkshake"]
        team.dieshake = npcD["dieshake"]
        team.runart = npcD["runart"]
        team.goBack = true -- 绕背
        team.turnFire = false
        team.meleePro = 1
        team.isMelee = team.atkType == EAtkTypeMELEE
        team.isFly = team.moveType == EMoveTypeAIR
        team.bornTime = npcD["borntime"]

        team:setState(ETeamState.MOVE)
        if not skillLevels then
            team.skillLevels = summonSkills or npcD["sl"]
        else
            team.skillLevels = skillLevels
        end 
        BC.initTeamSkill(team, npcD, npcD["skill"] or teamD["skill"], npcD["cs"] or teamD["cs"], npcD["hideSkill"] or teamD["hideSkill"], team.skillLevels, info)
        BC.initTeamSound(team)
    else
        team.D = npcD
        team.DType = 2
        if npcD["race"] then
            team.race1 = npcD["race"][1]
            team.race2 = npcD["race"][2]
        end
        team.halo = npcD["hx"] == 1
        team.summon = info.summon
        team.building = isBuilding
        if team.building or team.summon then
            team.showHead = false
        end
        team.label = npcD["summon"] or 1
        team.label1 = npcD["label1"]
        team.volume = npcD["volume"]
        team.attackRange = 1
        team.maxNumber = BC.VolumeNumber[team.volume]
        local _scale = npcD["scale"] or 100
        if scale then
            team.picScale = scale * _scale * 0.005
        else
            team.picScale = _scale * 0.005
        end
        team.scale = team.picScale * 2
        local res = npcD["art"]
        if AnimAP["mcList"][res] then
            team.radius = AnimAP["mcList"][res]["R"] * team.scale
        elseif AnimAP[res] then
            team.radius = AnimAP[res]["R"] * team.scale
        else
            team.radius = teamRadius[team.volume] * team.scale
        end
        if info.number and info.number <= team.maxNumber then
            team.number = info.number
        else
            team.number = team.maxNumber
        end
        team.attackArea = npcD["aa"]-- * team.scale
        if team.attackArea > 0 and team.attackArea < 80 then
            team.attackArea = 80
        end
        if team.attackArea > 0 and team.attackArea < team.radius + 10 then
            team.attackArea = team.radius + 10
        end
        team.patrolArea = npcD["ar"] * npcD["ar"]
        team.rush = npcD["rush"]
        team.atkType = npcD["at"]
        team.moveType = npcD["mot"]
        team.speedMove = npcD["sm"]
        -- 填写-1 说明不会走路, 而且有出生动画
        team.walk = team.speedMove >= 0
        if not team.walk then
            team.attackArea = 9999
        end
        team.speedAttack = npcD["sa"]
        team.atkfly = npcD["af"]
        team.bullet = npcD["fly"]
        team.bullet2 = npcD["fly2"]
        team.shadow = npcD["s"]
        team.boom = npcD["boom"]
        team.boom1 = npcD["boom1"]
        team.flyspeed = npcD["fs"]
        team.resID = npcD["art"]
        team.headPic = npcD["art1"]
        team.classLabel = npcD["class"]
        if team.classLabel == nil then
            team.classLabel = 1
        end

        team.calculation = npcD["cf"]
        team.calculation1 = npcD["cf1"]
        team.artzoom = npcD["az"] * 0.01
        team.atkshake = npcD["atkshake"]
        team.dieshake = npcD["dieshake"]
        team.runart = npcD["runart"]
        team.goBack = true -- 绕背
        team.turnFire = false
        team.meleePro = 1
        team.isMelee = team.atkType == EAtkTypeMELEE
        team.isFly = team.moveType == EMoveTypeAIR
        team.bornTime = npcD["borntime"]
        team:setState(ETeamState.MOVE)

        if not skillLevels then
            team.skillLevels = summonSkills or npcD["sl"]
        else
            team.skillLevels = skillLevels
        end 
        BC.initTeamSkill(team, npcD, npcD["skill"], npcD["cs"], npcD["hideSkill"], team.skillLevels, info)
        BC.initTeamSound(team)
    end
    team.shield = npcD["shieldRGB"]
    if team.shield then
        team.shieldCur = 0
        team.shieldMax = 100
    end
    local lasttime = npcD["lasttime"]
    if lasttime then
        local now = BC.logic.battleTime
        local time = (lasttime[1] + lasttime[2] * (info.level - 1)) * 0.001
        -- 寿命中止时间
        team.lifeOverTime = now + time
        -- 寿命总时间
        team.lifeTime = time
    end
    
    team:createSoldiers({npcD, info.level, summonAttr, info.fixHP}, BC.initSoldiersAttr_Npc)
end

function BC.initSoldiersAttr_Npc(team, soldiers, info)
    local count = #soldiers
    if count == 0 then
        return
    end
    local hero = team.hero
    local camp = team.camp
    local npcD = info[1]
    local level = info[2]
    -- 召唤物加成
    local summonAttr = info[3]
    -- HP不受BUFF加成
    local fixHP = info[4]
    -- 基础属性
    local baseAttr = {}
    local attr
    local atkspeed = npcD["atkSpeed"][1] + npcD["atkSpeed"][2] * (level - 1)
    for i = 1, ATTR_COUNT do
        attr = npcD["a"..i]
        if attr then
            baseAttr[i] = attr[1] + attr[2] * (level - 1)
        else
            baseAttr[i] = 0
        end
    end
    local _v = team.volume - 1
    if _v > 4 then
        _v = 4
    end
    if _v < 1 then
        _v = 1
    end
    local attrAdd = hero.attr[team.moveType][team.classLabel][_v]
    local attrAdd1 = nil
    if team.label1 then
        attrAdd1 = hero.attr1[team.label1]
    end
    local attrAdd2 = hero.attr2
    local attrAdd3 = hero.attr3

    local offsetDis
    local volume = team.volume
    local radius = team.radius
    local count = #soldiers
    local soldier
    
    -- 把英雄的属性加到召唤物上
    if not team.building then
        if team.summon then
            if attrAdd1 then
                for a = 1, ATTR_COUNT do
                    baseAttr[a] = baseAttr[a] + attrAdd[a] + attrAdd1[a] + attrAdd2[a] + attrAdd3[a]
                end
            else
                for a = 1, ATTR_COUNT do
                    baseAttr[a] = baseAttr[a] + attrAdd[a] + attrAdd2[a] + attrAdd3[a]
                end
            end
        else
            if attrAdd1 then
                for a = 1, ATTR_COUNT do
                    baseAttr[a] = baseAttr[a] + attrAdd[a] + attrAdd1[a] + attrAdd2[a]
                end
            else
                for a = 1, ATTR_COUNT do
                    baseAttr[a] = baseAttr[a] + attrAdd[a] + attrAdd2[a]
                end
            end
        end
    end

    local isHaveSkillBookTalent = false
    local skillid = nil
    if summonAttr then
        local lv, atkPro, hpPro, haste, defPro = summonAttr[1], summonAttr[2], summonAttr[3], summonAttr[4], summonAttr[5]
        local DamageDec, DecAll = summonAttr[6], summonAttr[7]
        baseAttr[ATTR_Atk] = baseAttr[ATTR_Atk] * lv
        baseAttr[ATTR_HP] = baseAttr[ATTR_HP] * lv
        baseAttr[ATTR_AtkPro] = baseAttr[ATTR_AtkPro] + atkPro
        baseAttr[ATTR_HPPro] = baseAttr[ATTR_HPPro] + hpPro
        baseAttr[ATTR_Haste] = baseAttr[ATTR_Haste] + haste
        baseAttr[ATTR_Def] = baseAttr[ATTR_Def] * defPro
        baseAttr[ATTR_DamageDec] = baseAttr[ATTR_DamageDec] + DamageDec
        baseAttr[ATTR_DecAll] = baseAttr[ATTR_DecAll] + DecAll

        -- 添加魔法天赋对召唤物的加成值
        -- 13：提升召唤物血量值 攻击值
        -- 14：提升召唤物血量百分比 攻击百分比
        local summonSkill = summonAttr[9]
        if summonSkill then
            local skillid = summonSkill.id
            if BC.H_SkillBookTalent[camp] and BC.H_SkillBookTalent[camp]["targetSkills"][skillid] then
                BattleUtils.countSkillBookTalent(skillid, baseAttr, {13, 14} ,camp)
            end 
        end 
    end

    -- 被动技能
    -- 暂时只开放给建筑物和冲车
    if team.building or team.label1 == 9 then
        local moveTypeCount = BC.MoveTypeCount[camp]
        local classCount = BC.ClassCount[camp]
        local race1Count = BC.Race1Count[camp]
        local xCount = BC.XCount[camp]
        local passive, attr, value, _level, condition, _count
        local passives = team.passives
        for i = 1, #passives do
           passive = tab.skillPassive[passives[i][1]]
           if passive and passive["compose"] == nil then
                attr = passive["attr"]
                condition = passive["condition"]
                _count = 0
                if condition == 0 then
                   _count = 1
                elseif condition == 1 then
                    if moveTypeCount then
                        _count = moveTypeCount[2]
                    end
                elseif condition < 7 then
                    if classCount then
                        _count = classCount[condition - 1]
                    end
                elseif condition < 16 then
                    if race1Count then
                        _count = race1Count[condition - 6]
                    end
                elseif 16 == condition then
                    local class = npcD["class"]
                    if classCount and class then
                        _count = classCount[class]
                    end
                elseif 17 == condition then
                    local race1 = npcD["race"] and npcD["race"][1]
                    if race1Count and race1 then
                        _count = race1Count[race1 - 100]
                    end
                elseif condition >= 23 and condition <= 25 then
                    if xCount then
                        _count = xCount[26 - condition]
                    end
                else
                    if race1Count then
                        _count = race1Count[condition - 6]
                    end
                end
                _level = passives[i][2]
                for k = 1, #attr do
                    value = (attr[k][2] + (_level - 1) * attr[k][3]) * _count
                    if value > 0 then
                        baseAttr[attr[k][1]] = baseAttr[attr[k][1]] + value
                    end
                end
            end
        end
    end

    for a = 1, ATTR_COUNT do
        baseAttr[a] = ceil(baseAttr[a])
    end

    if fixHP then
        local attr = npcD["a4"]
        if attr then
            baseAttr[4] = attr[1] + attr[2] * (level - 1)
        end
        baseAttr[5] = 0
        baseAttr[6] = 0
        attr = npcD["a7"]
        if attr then
            baseAttr[7] = attr[1] + attr[2] * (level - 1)
        end
        baseAttr[35] = 0
    end

    -- 攻击距离
    team.attackArea = team.attackArea + baseAttr[ATTR_AtkDis]
    local attackarea = team.D["attackarea"]
    local countSkillBookTalent = BattleUtils.countSkillBookTalent
    for i = 1, count do
        soldier = soldiers[i]

        -- 所有base属性的初始值
        for a = 1, ATTR_COUNT do
            soldier.baseAttr[a] = baseAttr[a]
        end
        -- soldier.baseAttr[BC.ATTR_Atk] = 999
        soldier.attackarea = attackarea
        soldier.atkspeed = atkspeed
        soldier.radius = radius
        soldier.resist = {1, 1, 1, 1, 1, 1, 1, 1}
        soldier:resetAttr(true)
        soldier.HP = soldier.maxHP
        
        BC["initHitPos"..volume](soldier)
        -- 普攻用, 不另生成
        soldier.caster = {
                        x = 0,
                        y = 0,
                        attacker = soldier,
                        atk = 0,
                        crit = 0,
                        critD = 0,
                        pen = 0,
                        hit = 0,
                        dmgInc = 0,
                        heal = 0,
                        healPro = 0,
                        aHPPro = 0,
                        level = team.level,
                        volume = team.volume,
                        camp = camp,
                    }


        if BattleUtils.XBW_SKILL_DEBUG and i == 1 then
            soldier:printAttr()
        end
    end
    if count > 0 then
        team.baseSpeedAdd = soldiers[1].attr[ATTR_MSpeed]
        team.baseShiqi = soldiers[1].attr[ATTR_Shiqi] + hero.shiQi
        team.shiqiValue = team.shiqi * 5
        team:resetAttr()
    end
end
-- 16人方阵士兵受击位
function BC.initHitPos2(soldier)
    soldier.hitPos = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end
-- 9人方阵士兵受击位
function BC.initHitPos3(soldier)
    soldier.hitPos = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end
-- 4人方阵士兵受击位
function BC.initHitPos4(soldier)
    soldier.hitPos = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end
-- 1人方阵士兵受击位
function BC.initHitPos5(soldier)
    -- 14 * 3
    soldier.hitPos = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end
-- BOSS方阵士兵受击位
function BC.initHitPos6(soldier)
    soldier.hitPos = {}
    for i = 1, 82 do
        soldier.hitPos[i] = 0
    end
end
local ceil = math.ceil
local insert = table.insert
-- 初始化技能
local G_TEAM_TALENTSKILL = BattleUtils.G_TEAM_TALENTSKILL
function BC.initTeamSkill(team, teamD, skill, classskill, hideskill, skillLevels, info)
    -- 技能防重复表
    local skillmap = {}
    -- 四种类型技能
    local skills = {{}, {}, {}, {}}
    local skillD
    local level

    -- jx = tonumber(v.ast) == 3,
    -- jxLv = tonumber(v.aLvl),
    -- jxSkill1 = jxTree.b1,
    -- jxSkill2 = jxTree.b2,
    -- jxSkill3 = jxTree.b3,
    -- 觉醒技能
    local jxSkill = {}
    if info and info.jx then
        local jxSkill1 = info.jxSkill1
        local jxSkill2 = info.jxSkill2
        local jxSkill3 = info.jxSkill3
        if jxSkill1 and jxSkill1 ~= 0 then
            local talentTree = teamD["talentTree1"]
            local talentSkill = talentTree[jxSkill1 + 1]
            --{配置表里技能的下标(第几个技能)，觉醒技能1，觉醒技能2}
            --觉醒技能 ：{技能类型，技能id, 增加/改变}
            jxSkill[talentTree[1]] = 
            {
                talentSkill[1], talentSkill[2], talentSkill[3]
            }
        end
        if jxSkill2 and jxSkill2 ~= 0 then
            local talentTree = teamD["talentTree2"]
            local talentSkill = talentTree[jxSkill2 + 1]
            jxSkill[talentTree[1]] = 
            {
                talentSkill[1], talentSkill[2], talentSkill[3]
            }
        end
        if jxSkill3 and jxSkill3 ~= 0 then
            local talentTree = teamD["talentTree3"]
            local talentSkill = talentTree[jxSkill3 + 1]
            jxSkill[talentTree[1]] = 
            {
                talentSkill[1], talentSkill[2], talentSkill[3]
            }
        end
    end

    -- 兵团符文加的技能：4套装
    local runeSkill = {}
    if info and info.rune and info.rune["suit"] then
        local suit = info.rune["suit"]
        local effComsStr = suit["4"]
        if effComsStr then
            local effComs = string.split(effComsStr,",")
            for j=1,#effComs do
                local runeId = tonumber(effComs[j])
                local skillsD = tab.rune[runeId]["effect4"]
                for i=1,#skillsD do
                    local skill = skillsD[i]
                    -- 默认是4级
                    insert(skills[skill[1]],{skill[2],1})
                    runeSkill[skill[2]] = {skill[2],1}
                end
                
            end
        end 
    end 


    -- 配置skill字段:基础技能
    skillD = skill
    local __skill, __jxSkill
    if skillD then
        for i = 1, #skillD do
            level = skillLevels[i]
            if level and level > 0 then
                __skill = skillD[i]
                __jxSkill = jxSkill[i]
                if __jxSkill then
                    if __jxSkill[3] == 1 then
                        -- 额外增加
                        insert(skills[__skill[1]], {__skill[2], level})
                        skillmap[__skill[2]] = level

                        insert(skills[__jxSkill[1]], {__jxSkill[2], level})
                        skillmap[__jxSkill[2]] = level
                    else
                        -- 改变
                        insert(skills[__jxSkill[1]], {__jxSkill[2], level})
                        skillmap[__jxSkill[2]] = level
                    end
                else
                    insert(skills[__skill[1]], {__skill[2], level})
                    skillmap[__skill[2]] = level
                end
            end
        end
    end

    local passiveTmp = skills[2]
    if passiveTmp then
        for i = 1, #passiveTmp do
            local skillId = passiveTmp[i][1]
            local skillPassiveD = tab.skillPassive[skillId]
            if skillPassiveD and skillPassiveD.condition then
                local skillLevelUp = function(skillType, skillId, skillValue)
                    skillValue = skillValue or 0
                    local skillsTmp = skills[skillType]
                    for j = 1, #skillsTmp do
                        if skillId == skillsTmp[j][1] then
                            skillsTmp[j][2] = skillsTmp[j][2] + skillValue
                            skillmap[skillId] = skillmap[skillId] + skillValue
                        end
                    end
                end
                if skillPassiveD.condition >= 18 and
                    skillPassiveD.condition <= 20 then
                    team.runeBuffEffect = {
                        condition = skillPassiveD.condition,
                        value = skillPassiveD.value or 0
                    }
                elseif 21 == skillPassiveD.condition then
                    local skillType = teamD["skill"][1][1]
                    local skillId = teamD["skill"][1][2]
                    local value = skillPassiveD.value or 0
                    skillLevelUp(skillType, skillId, value)

                    if info and info.jx and #jxSkill > 0 then
                        local skillType = jxSkill[1][1]
                        local skillId = jxSkill[1][2]
                        local value = skillPassiveD.value or 0
                        skillLevelUp(skillType, skillId, value)
                    end
                elseif 22 == skillPassiveD.condition then
                    for k = 1, 4 do
                        local skillType = teamD["skill"][k][1]
                        local skillId = teamD["skill"][k][2]
                        local value = skillPassiveD.value or 0
                        skillLevelUp(skillType, skillId, value)
                    end

                    if info and info.jx and #jxSkill > 0 then
                        for k, v in pairs(jxSkill) do
                            repeat
                                local skillType = v[1]
                                local skillId = v[2]
                                local value = skillPassiveD.value or 0
                                skillLevelUp(skillType, skillId, value)
                            until true;
                        end
                    end
                end
            end
        end
    end

    -- 兵种技能
    local cskill = classskill
    if cskill and not skillmap[cskill[2]]then
        if info and info.tmScore then
            local score = tonumber(info.tmScore)
            local level = #G_TEAM_TALENTSKILL
            for i = 1, level do
                if score < G_TEAM_TALENTSKILL[i] then
                    level = i - 1
                    break
                end
            end
            -- print("####", level)
            insert(skills[cskill[1]], {cskill[2], level})
            skillmap[cskill[2]] = level
        else
            insert(skills[cskill[1]], {cskill[2], 1})
            skillmap[cskill[2]] = 1
        end
    end

    -- 隐藏技能
    local hskill = hideskill
    if hskill then
        insert(skills[hskill[1]], {hskill[2], 1})
        skillmap[hskill[2]] = 1
    end

    -- 检查被动技能中的组合技能:组合技能的等级和被动技能一样
    local compose
    local passives = skills[2]
    skills[2] = {}
    local skillPassiveD
    for i = 1, #passives do
        skillPassiveD = tab.skillPassive[passives[i][1]]
        -- 符文宝石4件套技能考虑组合技能里的拆分
        local isRune4 = false
        if runeSkill[passives[i][1]] then
            isRune4 = true
        end 
        if skillPassiveD then
            compose = skillPassiveD["compose"]
            if compose then
                for k = 1, #compose do
                    level = passives[i][2]
                    insert(skills[compose[k][1]], {compose[k][2], level})
                    skillmap[compose[k][2]] = level

                    if isRune4 then
                        runeSkill[compose[k][2]] = {compose[k][2], level}
                    end 
                end
                -- 清除原始技能
                if isRune4 then
                    runeSkill[passives[i][1]] = nil
                end 
            else
                level = passives[i][2]
                insert(skills[2], {passives[i][1], level})
                skillmap[passives[i][1]] = level
            end
        end
    end 

    -- 英雄专长附加的技能:技能等级都为1
    local addSkill
    local hero = team.hero
    local _v = team.volume - 1
    if _v > 4 then
        _v = 4
    end
    if _v < 1 then
        _v = 1
    end
    -- 标签:
    --[[
        移动方式 : 1 地面 2 飞行
        兵种类型：1:输出 2：防御 3：突击 4：远程 5：魔法
        体型
    ]]

    addSkill = hero.monsterSkill[team.moveType][team.classLabel][_v]
    for _id, _type in pairs(addSkill) do
        if not skillmap[_id] then
            skillmap[_id] = 1
            -- 技能id,技能等级
            insert(skills[_type], {_id, 1})
        end
    end
    -- label1
    addSkill = hero.monsterSkill1[team.label1]
    if addSkill then
        for _id, _type in pairs(addSkill) do
            if not skillmap[_id] then
                skillmap[_id] = 1
                insert(skills[_type], {_id, 1})
            end
        end
    end
    -- 全局
    addSkill = hero.monsterSkill2
    for _id, _type in pairs(addSkill) do
        if not skillmap[_id] then
            skillmap[_id] = 1
            insert(skills[_type], {_id, 1})
        end
    end
    -- ID
    addSkill = hero.monsterSkill3[team.D["id"]]
    if addSkill then
        for _id, _type in pairs(addSkill) do
            if not skillmap[_id] then
                skillmap[_id] = 1
                insert(skills[_type], {_id, 1})
            end
        end
    end
    -- 前置条件
    addSkill = hero.monsterSkill4
    if addSkill then
        local teamMap = BC.TeamMap
        local condi, param, _type, add
        for _id, info in pairs(addSkill) do
            condi, param, _type = info[1], info[2], info[3]
            add = false
            if condi == 0 then
                add = true
            elseif condi == 1 then
                add = (teamMap[param] ~= nil)
            end
            if add and not skillmap[_id] then
                skillmap[_id] = 1
                insert(skills[_type], {_id, 1})
            end
        end
    end
    -- 召唤物
    if team.summon then
        addSkill = hero.monsterSkill5
        for _id, _type in pairs(addSkill) do
            if not skillmap[_id] then
                skillmap[_id] = 1
                insert(skills[_type], {_id, 1})
            end
        end
    end

    if BattleUtils.XBW_SKILL_DEBUG then print("ID " .. teamD["id"]) dump(skills) end

    local extraAtk = {}
    local extraDef = {}
    local charactersAtk = {}
    local charactersDef = {}
    local characterD, ctype, linear
    local minkey, minvalue, maxkey, dkey, dvalue
    local leveladd
    -- 特性 {特性id, 特性等级}，当成技能理解就行
    for k, v in pairs(skills[3]) do
        leveladd = v[2] - 1
        -- print(v[1])
        characterD = tab.skillCharacter[v[1]]
        ctype = characterD["type"]
        if ctype then
            if ctype == 1 then
                -- 生写表 条件
                local conditiontype = characterD["conditiontype"]
                local characters =  {
                                        characterD["conditionnum"][1] + characterD["conditionnum"][2] * leveladd, -- 几率
                                        characterD["condition"][1], -- 编号
                                        characterD["condition"][2], -- value
                                        {}, -- 属性
                                        v[1],
                                        characterD["double"],
                                    }
                local index = 1
                local attr = characterD["attr"] 
                for i = 1, #attr do
                    -- soldier的buff编号, buff值 
                    characters[4][index] = {attr[i][1], ceil(attr[i][2] + attr[i][3] * leveladd)}
                    index = index + 1
                end
                if conditiontype == 1 then
                    insert(charactersAtk, characters)
                elseif conditiontype == 2 then
                    insert(charactersDef, characters)
                else
                    insert(charactersAtk, characters)
                    insert(charactersDef, characters)
                end
                
            elseif ctype == 2 then
                -- 生写表 免疫buff
                for i = 1, #characterD["immune"] do
                    team.immuneBuff[characterD["immune"][i]] = true
                end
            elseif ctype == 18 then
                -- 生写表 额外防御力
                linear = characterD["linear"]
                minkey = linear[1][1]
                minvalue = linear[1][2] + linear[1][3] * leveladd
                maxkey = linear[2][1]
                dkey = maxkey - minkey
                dvalue = linear[2][2] + linear[2][3] * leveladd - minvalue
                insert(extraDef, {ctype, minkey, minvalue, maxkey, dvalue / dkey, linear[3], v[1]})  -- v[1] 是技能编号 debug
            elseif ctype == 19 then
                -- 生写表 概率免疫buff
                local immunes = characterD["immune"]
                for i = 1, #immunes do
                    local immune = immunes[i]
                    -- 1 buff类型 2 概率
                    team.proImmuneBuff[immune[1]] = immune[2]
                end
            elseif ctype >= 3 then
                -- 生写表 额外攻击力
                linear = characterD["linear"]
                minkey = linear[1][1]
                minvalue = linear[1][2] + linear[1][3] * leveladd
                maxkey = linear[2][1]
                dkey = maxkey - minkey
                dvalue = linear[2][2] + linear[2][3] * leveladd - minvalue
                insert(extraAtk, {ctype, minkey, minvalue, maxkey, dvalue / dkey, linear[3], v[1]})  -- v[1] 是技能编号 debug
            end
        end
    end
    -- 主动条件: BC.updateCaster中使用，攻击时检测buff是否加倍
    team.charactersAtk = charactersAtk
    -- 被动条件: BC.countDamage_attack中使用，被攻击时检测buff是否加倍
    team.charactersDef = charactersDef
    -- 额外攻击力
    team.extraAtk = extraAtk
    -- 额外防御力
    team.extraDef = extraDef
    -- 主动技能
    team.skills = skills[1]
    -- 被动技能 : 修改士兵属性 
    --[[
        1 BattleUtils.getTeamBaseAttr里调用，战斗之前就把属性加上
        2 BC.initSoldiersAttr_Npc调用 暂时只适用建筑物和冲车
    ]]
    team.passives = skills[2]
    -- 攻击特效
    if skills[4][1] then
        team.skillAttackEffect = skills[4][1][1]
    end
    -- 生写表 条件触发
    team.skillCharacters = skills[3]
    team.skillmap = skillmap

    team.runeSkill = runeSkill
end

function BC.initTeamSound(team)
    local teamD = team.D
    if teamD["atksound"] then
        team.sound_atk = teamD["atksound"]
    end
    if teamD["deathsound"] then
        team.sound_die = teamD["deathsound"]
    end
    if teamD["permsound"] then
        local permsound = teamD["permsound"]
        if permsound[1] == 1 then
            team.sound_loop = permsound[2]
        else
            -- team.sound_random = permsound[2]
        end
    end
    if teamD["movesound"] then
        local movesound = teamD["movesound"]
        if type(movesound) == "table" then

        else
            team.sound_move = movesound
        end
    end
    team.nearvol = teamD["nearvol"] or 70
    team.farvol = teamD["farvol"] or 20
    team.disrdcvol = teamD["disrdcvol"] or 70
end

local BattleSoldierCreator = {}
function BattleSoldierCreator.dtor()
    attackDis = nil --{0, 32, 34, 37, 50, 50}
    ATTR_AtkDis = nil --BC.ATTR_AtkDis
    ATTR_AtkPro = nil --BC.ATTR_AtkPro
    ATTR_COUNT = nil --BC.ATTR_COUNT
    ATTR_HP = nil --BC.ATTR_HP
    ATTR_HPPro = nil --BC.ATTR_HPPro
    ATTR_MSpeed = nil --BC.ATTR_MSpeed
    ATTR_Shiqi = nil --BC.ATTR_Shiqi
    BATTLE_CELL_SIZE = nil --BC.BATTLE_CELL_SIZE
    BattleSoldierCreator = nil --{}
    BC = nil --BC
    cc = nil --_G.cc
    ceil = nil --math.ceil
    ceil = nil --math.ceil
    AnimAP = nil
    ECamp = nil --BC.ECamp
    EDirect = nil --BC.EDirect
    EEffFlyType = nil --BC.EEffFlyType
    EMotion = nil --BC.EMotion
    EState = nil --BC.EState
    ETeamState = nil --BC.ETeamState
    insert = nil --table.insert
    math = nil --math
    mcMgr = nil --mcMgr
    next = nil --next
    os = nil --_G.os
    pairs = nil --pairs
    pc = nil --pc
    PokedexAttr = nil --BC.PokedexAttr
    sfResMgr = nil --sfResMgr
    tab = nil --tab
    table = nil --table
    teamRadius = nil --{0, 3, 6, 8, 40, 40}
    tonumber = nil --tonumber
    tostring = nil --tostring
    ATTR_Atk = nil
    ATTR_Haste = nil
    ATTR_Def = nil
end
return BattleSoldierCreator
