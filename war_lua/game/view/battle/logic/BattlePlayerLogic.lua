--[[
    Filename:    BattlePlayerLogic.lua
    Author:      <Your EMail in QuickDevX/quickx.py>
    Datetime:    2015-06-23 17:59:41
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
local format = string.format
local table = table  
local mcMgr = mcMgr

local random = BC.ran
local random2 = BC.ran2
 
local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState
local ECastType = BC.ECastType
local GBHU = GuideBattleHelpUtils

local EEffFlyType = BC.EEffFlyType
local initPlayerBuff = BC.initPlayerBuff
local initSoldierBuff = BC.initSoldierBuff

local objLayer = BC.objLayer
local delayCall = BC.DelayCall.dc

local sqrt = math.sqrt
local pow = math.pow
local abs = math.abs
local atan = math.atan
local deg = math.deg
local ceil = math.ceil
local floor = math.floor

local MAX_SKILL_COUNT = 7

local SRData = BattleUtils.SRData

local BC_reverse = BC.reverse
local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL

local BattleSkillLogic = require("game.view.battle.logic.BattleSkillLogic")

local recManaInv = 2
local isOpenAutoBattleForCamp = {}

local super = BattleSkillLogic.super

-- 失败积分相关参数

-- 初始积分
local H_FAILED_INIT = 58
-- 小于多少必定不触发
local H_FAILED_MIN = 0
-- 大于多少必定触发
local H_FAILED_MAX = 100
-- 成功后增加积分
local H_FAILED_ADD_MIN = 5 
local H_FAILED_ADD_MAX = 15
local H_FAILED_ADD_FIX = H_FAILED_ADD_MIN - 1
local H_FAILED_ADD_RAN = H_FAILED_ADD_MAX - H_FAILED_ADD_FIX

-- 失败后减少积分
local H_FAILED_DEC = 100

local initSkillCaster = BC.initSkillCaster

function BattleSkillLogic:ctor_player()
    objLayer = BC.objLayer

    -- 英雄大招动画
    self._enableHeroSkillAnim = true
	-- UI
    if self._skillIcons == nil then
	   self._skillIcons = {}
    end

    if not self._skillBookPassiveIcon then
        self._skillBookPassiveIcon = {}
    end

	-- self._leftSkillIndex = 0
    self._skillIndexes = {0, 0}
    -- 

    -- self._skillIcons
    -- 蓝 回蓝 蓝上限 法强 单系法强
    self.mana = {0, 0}
    self.manaRec = {0, 0}
    self.manaMax = {0, 0}

    self.summonDie_RecMana = {0, 0}
    self.summonDie_DecCd = {0, 0}

    for i = 1, 2 do
        local hero = self._heros[i]
        self.mana[i] = hero.manaBase
        self.manaRec[i] = hero.manaRec
        self.manaMax[i] = hero.manaMax
        if self.mana[i] > self.manaMax[i] then
            self.mana[i] = self.manaMax[i]
        end
        self.summonDie_RecMana[i] = hero.summonDie_RecMana
        self.summonDie_DecCd[i] = hero.summonDie_DecCd
    end

    if SRData then 
        SRData[336] = self.mana[1]
    end

    -- 技能体
    self._skills = {}

    self._lastAddManaTick = 0

    -- 玩家技能
    self._playSkills = {{}, {}}
    self._playOpenSkills = {{}, {}}
    self._playAutoSkills = {{}, {}}
    self._playForceAutoSkills = {{}, {}}
    self._playWeaponSkills = {{}, {}}
    self._playSkillBookPassive = {{}, {}}
    self._playSpecialSkills = {{}, {}}
    -- 玩家条件释放的技能
    self._playConditionSkills = {{}, {}}

    --因为兵团死亡，或者不在场删除掉的自动释放的技能
    self._playerRemoveSkill = {{}, {}}

    -- 释放时间
    self._playCastTime = {}

    -- 失败率积分
    self._failedValue = {H_FAILED_INIT, H_FAILED_INIT}

    -- 同id英雄区分释放技能
    self._sameHeroFirstSkillState = {-1, -1}



    self._autoSkillAttrClass = ""
    if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_League 
        or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_HeroDuel 
        or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_GodWar
        or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_CrossGodWar 
        or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_Arena
        or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_ServerArena then
        self._autoSkillAttrClass = "X"
    end
    local cdPro1 = self._cdPro1
    if cdPro1 == nil then
       cdPro1 = 1
    end
    local cdPro2 = self._cdPro2
    if cdPro2 == nil then
       cdPro2 = 1
    end
    local cdPro = {cdPro1, cdPro2}
    local skill, cd, sysSkill
    local skillTab = {}
    for k = 1, 2 do 
        for i = 1, #self._heros[k].skills do
            skill = self._heros[k].skills[i] 
            if skill[3] then
                -- sysSkill = tab.playerSkillEffect[skill[1]]
                if k == 1 then skillTab[skill[1]] = 0 end
                self._playSkills[k][i] = BC.initPlayerSkill(k, i, skill)
                self._playSkills[k][i].cd = self._playSkills[k][i].cd * cdPro[k]
                self._playSkills[k][i].maxCD = self._playSkills[k][i].maxCD * cdPro[k]
            end
        end
        -- dump(self._playSkills, "test", 10)
        -- 生成适合自动释放技能格式
        self._playAutoSkills[k] = BC.initAutoPlayerSkills(self._playSkills[k], self._autoSkillAttrClass)
        -- 若设置兵团死亡或者没有上阵，则禁止使用技能
        self:excludeSkillWithTarget(k)

        for i = 1, #self._heros[k].openSkills do
            skill = self._heros[k].openSkills[i] 
            -- sysSkill = tab.playerSkillEffect[skill[1]]
            if k == 1 then skillTab[skill[1]] = 0 end
            self._playOpenSkills[k][i] = BC.initPlayerSkill(k, i, skill)
            self._playOpenSkills[k][i].cd = self._playOpenSkills[k][i].cd * cdPro[k]
            self._playOpenSkills[k][i].maxCD = self._playOpenSkills[k][i].maxCD * cdPro[k]
            self._playOpenSkills[k][i].treasureD = skill[3]
        end   

        -- 强制自动释放的技能, 暂时用于龙王神力
        for i = 1, #self._heros[k].autoSkills do
            skill = self._heros[k].autoSkills[i] 
            -- sysSkill = tab.playerSkillEffect[skill[1]]

            self._playForceAutoSkills[k][i] = BC.initPlayerSkill(k, i, skill)
            self._playForceAutoSkills[k][i].cd = self._playForceAutoSkills[k][i].cd * cdPro[k]
            self._playForceAutoSkills[k][i].maxCD = self._playForceAutoSkills[k][i].maxCD * cdPro[k]
        end   

        -- 攻城器械的技能
        for i = 1, #self._heros[k].weaponSkills do
            skill = self._heros[k].weaponSkills[i] 
            -- sysSkill = tab.playerSkillEffect[skill[1]]

            self._playWeaponSkills[k][i] = BC.initPlayerSkill(k, i, skill)
            self._playWeaponSkills[k][i].cd = self._playWeaponSkills[k][i].cd
            self._playWeaponSkills[k][i].maxCD = self._playWeaponSkills[k][i].maxCD
            self._playWeaponSkills[k][i].weaponSkillIndex = skill[5]
        end  
        -- dump(self._playWeaponSkills)

        -- 法术刻印被动技能
        for i = 1, #self._heros[k].skillBookPassive do
            self._playSkillBookPassive[k][i] = self._heros[k].skillBookPassive[i] 
        end

        if self._heros[k].specialSkills then
            for i = 1, #self._heros[k].specialSkills do
                skill = self._heros[k].specialSkills[i]
                self._playSpecialSkills[k][i] = BC.initPlayerSkill(k, i, skill)
                self._playSpecialSkills[k][i].cd = self._playSpecialSkills[k][i].cd * cdPro[k]
                self._playSpecialSkills[k][i].maxCD = self._playSpecialSkills[k][i].maxCD * cdPro[k]
            end
        end

        --条件释放的技能
        if self._heros[k].conditionSkills then
            for i = 1, #self._heros[k].conditionSkills do
                skill = self._heros[k].conditionSkills[i]
                self._playConditionSkills[k][i] = BC.initPlayerSkill(k, i, skill)
                self._playConditionSkills[k][i].cd = self._playConditionSkills[k][i].cd * cdPro[k]
                self._playConditionSkills[k][i].maxCD = self._playConditionSkills[k][i].maxCD * cdPro[k]
            end
        end
    end

    local function skillSort(_table)
        for i,v in ipairs(_table) do
            if v and #v > 2 then
                table.sort(v,  function(_a, _b)
                    if _a.id and  _b.id then
                        return _a.id < _b.id
                    else
                        return true
                    end
                end)
            end 
        end
    end
    --提前排好顺序，否则会影响复盘结果
    skillSort(self._playOpenSkills)
    skillSort(self._playForceAutoSkills)
    skillSort(self._playWeaponSkills)
    skillSort(self._playSkillBookPassive)
    skillSort(self._playSpecialSkills)
    -- AI增加逻辑，若地方存在这些招数，则技能不自动释放，在这些招数释放后1秒追加
    local enemyCamp
    local tmpCountersk
    for k = 1, 2 do
        for i=#self._playAutoSkills[k] ,1, -1 do
            local v = self._playAutoSkills[k][i]
            local skill = self._playSkills[k][v.index]
            if skill["countersk" .. self._autoSkillAttrClass] ~= nil then 
                tmpCountersk = {}
                enemyCamp = (k == 1 and 2 or 1)
                for n,m in pairs(skill["countersk" .. self._autoSkillAttrClass]) do
                    for j=#self._playAutoSkills[enemyCamp] ,1, -1 do
                        local w  = self._playAutoSkills[enemyCamp][j]
                        local enemySkill = self._playSkills[enemyCamp][w.index]
                        if m == enemySkill.id then
                            if skill.counterSkill == nil then 
                                skill.counterSkill = {}
                            end
                            table.insert(skill.counterSkill, w.index)
                            table.remove(self._playAutoSkills[enemyCamp], j)
                        end
                    end
                end
            end
        end
    end

    if self._heroDamagePro == nil then
        self._heroDamagePro = 1
    end

    -- 自动释放技能
    self._autoCastSkill = false
    self._lastHandleTick = -1000

    -----------------------单次增长积分-------------------
    self._useSkill = 0
    -----------------------单次增长积分-------------------
    local funcCount = 3
    self._getTouchSkillPointFunc = {}
    for i = 2, funcCount do
        self._getTouchSkillPointFunc[i] = self["getTouchSkillPoint"..i]
    end
    isOpenAutoBattleForCamp[1] = self:isOpenAutoBattleForLeftCamp()
    isOpenAutoBattleForCamp[2] = self:isOpenAutoBattleForRightCamp()

    -- 每日小惊喜
    self._surpriseOpen = BattleUtils.surpriseOpen
    -- 1->2->3->4->1
    self._surpriseIndex = 1
    -- 记录技能释放顺序
    -- 每次战斗重置, 每次放四个技能 计算一次
    self._surpriseList = {0, 0, 0, 0}

    self._castSkillList = self._battleInfo.playerInfo.skillList
    self._castSkillListIndex = 1

    -- 技能释放队列, 统一下一帧释放
    self._nextFrameCastSkill = {}

    -- 释放技能次数
    -- key为id value 为次数
    self._castSkillCount = {}

    if SRData then
        local hero = self._heros[1]
        SRData[1] = hero.ID
        SRData[2] = hero.atk .. "," .. hero.def .. "," .. hero.int .. "," .. hero.ack
        SRData[3] = self.mana[1]
        SRData[4] = self.manaRec[1]
        SRData[472] = hero.ID
        SRData[473] = hero.atk .. "," .. hero.def .. "," .. hero.int .. "," .. hero.ack
        SRData[474] = self.mana[1]
        SRData[475] = self.manaRec[1]
        local skills = self._playSkills[1]
        local skill, k
        for i = 1, 5 do
            skill = skills[i]
            if skill then
                k = (i - 1) * 4
                SRData[5 + k] = skill.id
                SRData[6 + k] = skill.cd * 1000
                SRData[7 + k] = skill.maxCD
                SRData[8 + k] = skill.level
            end
        end
        -- SRData[97] = 1
        SRData[98] = 2
        if BattleUtils.PROC_AUTO_SKILL[self._battleInfo.mode] then
            SRData[99] = 1
        else
            SRData[99] = 2
        end
        -- SRData[100] = 1
        SRData[101] = hero.ID

        -- 技能部分
        local skillD, sr1, sr2
        for skillid, v in pairs(skillTab) do
            skillD = tab.playerSkillEffect[skillid]
            if skillD["buffid1"] then
                sr1 = tab.skillBuff[skillD["buffid1"]].sr
            end
            if skillD["buffid2"] then
                sr2 = tab.skillBuff[skillD["buffid2"]].sr
            end
            if sr1 or sr2 then
                if sr1 then   
                    if sr2 then
                        skillTab[skillid] = {sr1, sr2}
                    else
                        skillTab[skillid] = {sr1}
                    end
                else
                    skillTab[skillid] = {sr2}
                end
            else
                skillTab[skillid] = nil
            end
        end
        self._lastCastSkillTick = {}
        self._SRSkillTab = skillTab
    end
end

-- 为引导帮助设置前置cd
function BattleSkillLogic:guideHelpUpdateInitCd(inCamp, inSkillIndex, inInitCd)
    if self._playSkills[inCamp][inSkillIndex] == nil then 
        return
    end
    local cd = inInitCd
    self._playSkills[inCamp][inSkillIndex].cd = cd

    local skillIcon = self._skillIcons[inSkillIndex]
    if skillIcon ~= nil then 
        skillIcon.cdLabel:setString(ceil(cd))
        skillIcon.cdLabel:setVisible(cd > 0)
    end
end

-- 为引导帮助设置战前魔法
function BattleSkillLogic:guideHelpUpdatePlayerMana(inCamp, inMana)
    if self.mana[inCamp] ~= nil then 
        self.mana[inCamp] = inMana
    end
end

function BattleSkillLogic:getCurSkillIndex()
    return self._skillIndexes[1]
end

-- 各个技能释放次数
function BattleSkillLogic:getCastSkillCount()
    return self._castSkillCount
end

function BattleSkillLogic:BattleEnd(isTimeUp, isSurrender, isSkip, pos)
    self:clearSkill()
    BattleSkillLogic.super.BattleEnd(self, isTimeUp, isSurrender, isSkip, pos)
end

function BattleSkillLogic:clearSkill()
    if self._skillIndexes and self._skillIndexes[1] ~= 0 then
        self:_onPlayerSkill(self._skillIndexes[1])
    end
end

-- 设置全局蓝耗
function BattleSkillLogic:setManaPro(value)
    self._manaPro[1] = value

    if self._skillIcons then
        for i = 1, #self._skillIcon do
            self._skillIcon[i].label:setString(floor(skill.mana * self._manaPro[1]))
        end
    end
end

function BattleSkillLogic:setCDPro1(pro)
    self._cdPro1 = pro
end

function BattleSkillLogic:setCDPro2(pro)
    self._cdPro2 = pro
end

function BattleSkillLogic:setHeroDamagePro(pro)
    self._heroDamagePro = pro
end

function BattleSkillLogic:resetCD(inCamp)
    local tick = self.battleTime
    for i = 1, MAX_SKILL_COUNT do
        if self._playSkills[inCamp][i] then
            local skill = self._playSkills[inCamp][i]
            skill.castTick = tick
        end
    end
end

function BattleSkillLogic:getSkills()
    return self._heros[BC_reverse and 2 or 1].skills
end

function BattleSkillLogic:getSkillBookPassive()
    return self._heros[BC_reverse and 2 or 1].skillBookPassive
end

function BattleSkillLogic:clear_player()
    self._playCastTime = {}
    self._skillIcons = nil
    self.mana = nil
    self.manaRec = nil
    self.manaMax = nil

    self._skills = nil
    self._playSkills = nil
    self._sameHeroFirstSkillState = nil
    self._playAutoSkills = nil
    self._castSkillX = 0
    self._castSkillY = 0
    -- self._leftSkillIndex = 0
    self._skillIndexes = {0, 0}

    objLayer = nil
end

function BattleSkillLogic:BattleBegin()
    -- 处理玩家技能相关
    for k = 1, 2 do
        for i = 1, MAX_SKILL_COUNT do
            if self._playSkills[k][i] then
                local skill = self._playSkills[k][i]
                if skill.cd > 0 then 
                	skill.castTick = skill.cd
               	end
                if not BATTLE_PROC then
                    self:updatePlayerSkillIconState(i, skill)
                end
            end
        end
        for i = 1, #self._playForceAutoSkills[k] do
            local skill = self._playForceAutoSkills[k][i]
            if skill.cd > 0 then 
                skill.castTick = skill.cd
            end
        end
        for i = 1, #self._playWeaponSkills[k] do
            local skill = self._playWeaponSkills[k][i]
            if skill.cd > 0 then 
                skill.castTick = skill.cd
            end
        end
    end
    super.BattleBegin(self)

end

function BattleSkillLogic:setSkillBookPassiveIcon(icon, index)
    self._skillBookPassiveIcon[index] = icon
end

function BattleSkillLogic:resetSkillIcon()
    for index, v in pairs(self._skillIcons) do
        self:addSkillIcon(v, index)
        self:setIconSelect(index, false, true)
    end
end
-- 技能Icon
function BattleSkillLogic:addSkillIcon(icon, index)
    local camp = BC_reverse and 2 or 1
    self._skillIcons[index] = icon
    icon:setColor(cc.c3b(255, 255, 255))
    local skill = self._playSkills[camp][index]
    if skill == nil then 
        return 
    end
    local sysSkill = tab.playerSkillEffect[skill.id]
    icon.icon:loadTexture(IconUtils.iconPath .. sysSkill.art .. ".png", 1) 
    if skill.castCount >= 0 then
        icon.mask:loadTexture("hero_skill_bg5_forma.png", 1)
    else
        if sysSkill["dazhao"] then
            icon.mask:loadTexture("hero_skill_bg1_forma.png", 1)
        elseif sysSkill["calsstag"] == 3 then
            icon.mask:loadTexture("hero_skill_bg3_forma.png", 1)
        end
    end

    local _mana = true
    if floor(skill.mana * self._manaPro[camp]) > self.mana[camp] then 
        icon.label:setColor(cc.c3b(255, 0, 0))
        icon.mask:setSaturation(-100)
        icon.icon:setSaturation(-100)
        _mana = false
    end
    if skill.castCount >= 0 then
        icon.count:setString(skill.castCount)
        icon.maxCount = skill.castCount
    end

    icon.label:setString(floor(skill.mana * self._manaPro[camp]))
    if skill.oriMana >= 99 then
        icon.__disable = true
    end
    -- 添加操作提示

    -- icon.type:loadTexture("type"..sysSkill["dmgtag"].."_battle.png", 1)
    -- icon.silent:setVisible(true)
    -- icon.icon --图标
    -- icon.label --消耗怒气文字
    -- icon.select --选中状态
    
    local cdMC = mcMgr:createMovieClip("do_colddown")
    cdMC:setCascadeOpacityEnabled(true, true)
    cdMC:addEndCallback(function (_, sender)
        sender:stop()
        sender:setVisible(false)
    end)
    local _cd = skill.cd <= 0
    cdMC:stop()
    cdMC:setPosition(51, 49)
    cdMC:setVisible(false)
    cdMC.isRelease = skill.cd > 0
    icon.skill:addChild(cdMC, 100)
    icon.cdMC = cdMC

    icon.cdLabel:setVisible(skill.cd > 0)
    icon.cdLabel:setString(ceil(skill.cd))

    if not _cd then
        icon.cd:setPercentage(100)
    else
        icon.cd:setPercentage(0)
    end

    if _cd and _mana then
        icon.mask:setSaturation(0)
        icon.icon:setSaturation(0)
    else
        icon.mask:setSaturation(-100)
        icon.icon:setSaturation(-100)
    end
end

--[[
--! @function updatePlayerSkillIconState
--! @desc 更新玩家技能图标状态
--! @param inIndex int 索引
--! @param inSkill object 操作技能（可为nil)
--! @return 
--]]
function BattleSkillLogic:updatePlayerSkillIconState(inIndex, inSkill)
    local camp = BC_reverse and 2 or 1
    if self._skillIcons[inIndex] == nil then return end
	local skill = inSkill
	if skill == nil then 
		skill = self._playSkills[camp][inIndex]
	end
    if self.battleBeginTick == nil then return end

    local tick = self.battleTime

	local skillIcon = self._skillIcons[inIndex]
	local lastcd = 0
	local isOpenClick = true
    -- 沉默判断
    -- if tick > skill.silentTask then

    -- else

    -- end
	-- cd 时间判断
    local _cd, _mana
	if tick < skill.castTick then
        -- cd 状态效果需要/100 
		lastcd = (skill.castTick - tick) / skill.cd * 100
        isOpenClick = false	
        skillIcon.cdLabel:setString(ceil(skill.castTick - tick))
        skillIcon.cdLabel:setVisible(true)
        _cd = false
    else
        skillIcon.cdLabel:setVisible(false)
        _cd = true
    end
	-- 能量值判断
	if floor(skill.mana * self._manaPro[camp]) > self.mana[camp] then 
		skillIcon.label:setColor(cc.c3b(255, 0, 0))
		isOpenClick = false
        _mana = false
	else
		skillIcon.label:setColor(cc.c3b(255, 255, 255))
		isOpenClick = true
        _mana = true
	end

    local _canRelease = false
    if _cd and _mana then
        skillIcon.mask:setSaturation(0)
        skillIcon.icon:setSaturation(0)
        _canRelease = true
    else
        skillIcon.mask:setSaturation(-100)
        skillIcon.icon:setSaturation(-100)
        _canRelease = false
    end

    -- 特殊释放条件
    if inSkill.castCon == 1 then
        if self._teamDieCount[BC_reverse] <= 0 then
            skillIcon.mask:setSaturation(-100)
            skillIcon.icon:setSaturation(-100)
            _canRelease = false
        end
    end

    if skillIcon.xuanzhong then
        skillIcon.xuanzhong:setVisible(_canRelease)
    end

    if inSkill.castCount == 0 then
        skillIcon.mask:setSaturation(-100)
        skillIcon.icon:setSaturation(-100)
        skillIcon.outOfCount = true
    end

    if lastcd <= 0 then 
        -- cd状态处理
        if skillIcon.cdMC:isVisible() == false and 
        skillIcon.cdMC.isRelease == true then 
            skillIcon.cdMC.isRelease = false
            if _mana then
                skillIcon.cdMC:setVisible(true)
                skillIcon.cdMC:gotoAndPlay(1)
            end
        end
    end

    if inSkill.castCount >= 0 and inSkill.castCount ~= skillIcon.count.count then
        skillIcon.count:setString(inSkill.castCount)
        if inSkill.castCount == 0 then
            skillIcon.count:setSaturation(100)
            skillIcon.count:setColor(cc.c3b(255, 0, 0))
        end
        skillIcon.count.count = inSkill.castCount
    end   

    skillIcon.cd:setPercentage(lastcd)
	-- skillIcon:setEnabled(isOpenClick)
    -- if isOpenClick and not self._autoCastSkill then

    -- else

    -- end
end

-- 设置icon选中状态
function BattleSkillLogic:setIconSelect(index, _select, fast)
	if index == 0 then return end
    if BC.jump then return end
    -- self._skillIcons[index].select:setVisible(_select)
    if _select then
        self._skillIcons[index].skill.open = true
        self._skillIcons[index].skill:stopAllActions()
        self._skillIcons[index].skill:setScale(0.8)
        self._skillIcons[index].skill:runAction(cc.Sequence:create(
            cc.Spawn:create(cc.ScaleTo:create(0.10, 1.07), cc.MoveTo:create(0.10, cc.p(50, 57))),
            cc.CallFunc:create(function ()
                local mc = mcMgr:createMovieClip("xuanzhong_skillarea")
                mc:setCascadeOpacityEnabled(false, false)
                mc:setPosition(50, 53)
                mc:setScale(1.07)
                self._skillIcons[index]:addChild(mc, 2)
                self._skillIcons[index].xuanzhong = mc
                -- self._skillIcons[index].xuanzhong:setVisible(false)
            end),
            cc.MoveTo:create(0.08, cc.p(50, 52)),
            cc.MoveTo:create(0.06, cc.p(50, 55)),
            cc.MoveTo:create(0.03, cc.p(50, 54))
        ))
    else
        if self._skillIcons[index].skill.open then
            if self._skillIcons[index].xuanzhong then
                self._skillIcons[index].xuanzhong:removeFromParent()
                self._skillIcons[index].xuanzhong = nil
            end
            self._skillIcons[index].skill.open = false
            self._skillIcons[index].skill:stopAllActions()
            if fast then
                self._skillIcons[index].skill:setPosition(50, 40)
                self._skillIcons[index].skill:setScale(1.0)
            else
                self._skillIcons[index].skill:runAction(cc.Spawn:create(cc.EaseIn:create(cc.MoveTo:create(0.08, cc.p(50, 40)), 1), cc.ScaleTo:create(0.08, 1.0)))
            end
        end
    end
    local alpha = 255
    if _select then
        alpha = 0
    end
end

function BattleSkillLogic:updateSkillLock()
    self:setSkillAuto(self._autoCastSkill)
end

-- 设置自动释放技能
function BattleSkillLogic:setSkillAuto(isAuto)
    self._autoCastSkill = isAuto
    for k,v in pairs(self._skillIcons) do
        local lock = isAuto or v.__disable
        self:setIconSelect(k, false)
        v.lock:setVisible(lock) 
        v.touchEnabled = not lock
        -- v:setTouchEnabled(not lock)
        if lock then
            v:setBrightness(-60)
        else
            v:setBrightness(0)
        end
    end
    -- self._leftSkillIndex = 0
    self._skillIndexes = {0, 0}
-- 
    -- 取消界面变暗效果
    self._control:disableBlack()
    self:setCampBrightness(1, 0)
    self:setCampBrightness(2, 0)
    objLayer:showHP(false, false)
end  

function BattleSkillLogic:lockSkill()
    local isAuto = true
    for k,v in pairs(self._skillIcons) do
        self:setIconSelect(k, false)
        v.lock:setVisible(isAuto) 
        v.touchEnabled = not isAuto
        -- v:setTouchEnabled(not isAuto)
        if isAuto then
            v:setBrightness(-60)
        else
            v:setBrightness(0)
        end
    end
end

-- 点击技能icon
function BattleSkillLogic:onPlayerSkill(index)
    local skill = self._playSkills[1][index]
    if self.battleState ~= EState.ING then
        return
    end
    self:_onPlayerSkill(index)
end

function BattleSkillLogic:onGuildePlayerSkill(index)
    local skill = self._playSkills[1][index]
    if self.battleState ~= EState.ING then 
        return
    end
    -- if GBHU.LOCK then return end
    self:_onPlayerSkill(index)
    return self._skillIndexes[1]
end

function BattleSkillLogic:onPlayerSkillMove(x, y, x1, y1)
    if not GuideUtils.isGuideRunning then
        objLayer:updateSkillAreaPos(x, y, x1, y1)
    end
end

function BattleSkillLogic:getSkillRadius(camp, index)
    local skill = self._playSkills[camp][index]
    local skillD = tab.playerSkillEffect[skill.id]
    local r1 = skillD["range1"]
    local r2 = skillD["range2"]
    local r = r1 or r2 or 0
    if r == 0 then
        if skillD["objectid"] then
            local totemD = tab.object[skillD["objectid"]]
            r1 = totemD["range1"]
            r2 = totemD["range2"]
            r = r1 or r2 or 0
        end
    end
    if r >= 350 then
        return 999
    else
        return (r * (1 + skill.rangePro * 0.01)) / 75
    end
end

--激活拖动施法方式
function BattleSkillLogic:onPlayerSkillMoveBegin(index)
    local skill = self._playSkills[1][index]
    local skillD = tab.playerSkillEffect[skill.id]
    local r = self:getSkillRadius(1, index)
    if not GuideUtils.isGuideRunning then
        objLayer:showSkillArea(r, lang(skillD["name"]), lang(skillD["des3"]), skill.level, self._skillIcons[index], skillD["direction"], skillD["iff2"])

        local tag = skillD["tag"]
        if tag == nil or tag == 0 then
            self:setCampBrightness(1, 0)
            self:setCampBrightness(2, 0)
        elseif tag < 3 then
            self:setCampBrightness(tag, 0)
            self:setCampBrightness(3 - tag, 80)
        else
            self:setCampBrightness(1, 80)
            self:setCampBrightness(2, 80)
        end
    end
end

function BattleSkillLogic:onPlayerSkillMoveEnd()
    objLayer:hideSkillArea()
end

-- 该技能是否被选中
function BattleSkillLogic:isPlayerSkillSelect(index)
    return self._skillIndexes[1] == index
end

local color_red = cc.c3b(255, 0, 0)
function BattleSkillLogic:_onPlayerSkill(index)
    if self._autoCastSkill then return end
    local nowIndex = self._skillIndexes[1]
    self:stopTipEffect(self._playSkills[1][nowIndex])
    self:setIconSelect(self._skillIndexes[1], false)
    self._skillIndexes[1] = 0
    self._control:disableBlack()
    self:setCampBrightness(1, 0)
    self:setCampBrightness(2, 0)
    objLayer:showHP(false, false)
    self._canCast = false
    if nowIndex == index then
        self._playerTouchMovePoint = nil
        self._playerTouchBeginPoint = nil
    else
        -- 统计技能按钮有效点击次数
        if SRData then
            local _idx = 113 + index
            SRData[_idx] = SRData[_idx] + 1
        end
        local skill = self._playSkills[1][index]

        self:setIconSelect(self._skillIndexes[1], false)
        self._skillIndexes[1] = 0

        -- 自动激活技能
        if skill.kind == 3 then 
            return 
        end

        -- 点击直接施放技能
        if skill.kind == 2 
            and self:checkPlayerSkill(skill, 1) then
            self:castPlayerSkill(initSkillCaster(0, 0, 1, skill.id, skill.castCount), skill)
            return
        end

        self._control:enableBlack(tab.playerSkillEffect[skill.id])
        local tag = skill["tag"]
        if tag == nil or tag == 0 then
            objLayer:showHP(false, false)
        elseif tag < 3 then
            objLayer:showHP(tag == 2, tag == 1)
        else
            objLayer:showHP(true, true)
        end
        -- 方阵死亡才能释放
        if BC.SHOW_TEAM_DIE_ICON and skill.castCon == 1 then
            objLayer:showTeamDieHead()
        end
        self:setIconSelect(index, true)
        self._skillIndexes[1] = index
        self._canCast = true
    end
end


function BattleSkillLogic:guidePlayerSkillDown(x, y)
    if self.battleState ~= EState.ING then
        return 
    end
    self:_playerSkillDown(x, y)
end
-- 返回true表示截取事件
function BattleSkillLogic:playerSkillDown(x, y)
    if self.battleState ~= EState.ING
    or BC.BATTLE_SPEED == 0 then
        return
    end
    if self._skillCasting then return end
    return self:_playerSkillDown(x, y)
end


function BattleSkillLogic:_playerSkillDown(x, y)
    if self._autoCastSkill == true then 
        return false
    end
    if self._skillIndexes[1] == 0 then
        return false
    end
    if not self._canCast then return false end
    self:onPlayerSkillMoveBegin(self._skillIndexes[1], x, y)
    self._playerTouchBeginPoint = {x = x, y = y}
    return true
end


function BattleSkillLogic:playerSkillMove(x, y)
    if self._skillIndexes[1] == 0 then
        return false
    end
end

function BattleSkillLogic:playerSkillUp(x, y, dontCancelSkill)
    if self._skillIndexes[1] == 0 then
        objLayer:hideSkillArea()
        return false
    end
    if not self._canCast then
        objLayer:hideSkillArea()
        return false
    end

    local index = self._skillIndexes[1]
    local skill = self._playSkills[1][index]
    -- 检测是否能释放技能
    local res, _type = self:checkPlayerSkill(skill, 1, true)
    if not res then 
        if _type == 1 then
            -- cd没到
            self._skillIcons[index].cdLabel:stopAllActions()
            self._skillIcons[index].cdLabel:setColor(color_red)
            self._skillIcons[index].cdLabel:runAction(cc.Sequence:create(
                cc.TintTo:create(0.3, 255, 255, 255), 
                cc.TintTo:create(0.3, 255, 0, 0), cc.TintTo:create(0.3, 255, 255, 255)))
            self._skillIcons[index].light:setOpacity(255)
            self._skillIcons[index].light:runAction(cc.FadeOut:create(0.3))
            self._control:cdYet(x, y)
        elseif _type == 2 then
            -- 蓝不够
            self._control:outOfMana(x, y)
        elseif _type >= 3 and _type <= 99 then
            -- 字符串提示
            self._control:skillCannotCastTip(_type - 2, x, y)
        end
        if not dontCancelSkill then
            self:setIconSelect(self._skillIndexes[1], false)
            self._skillIndexes[1] = 0
        end
        self._control:disableBlack()
        self:setCampBrightness(1, 0)
        self:setCampBrightness(2, 0)
        objLayer:showHP(false, false)
        self:stopTipEffect(skill)
        objLayer:hideSkillArea()
        return false
    end
    local sysSkill = tab.playerSkillEffect[skill.id]
    if not GuideUtils.isGuideRunning then
        objLayer:flashSkillArea(x, y)
    end
	self._skillCasting = true
    self._nextFrameCastSkill[#self._nextFrameCastSkill + 1] = {skill.index, x, y}
    return true
    -- 如果上述判断不成立则抬起终止技能
    -- self:stopPlayerSkill(caster, skill)
    -- return true
end

--[[
--! @function checkPlayerSkill
--! @desc 检查技能是否可以释放
--! @param inSkill object 技能数据
--! @param isVerify bool 验证状态不扣除相关值
--! @return 
--]]
function BattleSkillLogic:checkPlayerSkill(inSkill, inCamp, isVerify)
	local sysSkill = tab.playerSkillEffect[inSkill.id]

    -- 能量值
    if inSkill.sumnum == inSkill.maxSumnum and
        self.mana[inCamp] - floor(inSkill.mana * self._manaPro[inCamp]) < 0 then 
        return false, 2
    end

    local isOk, ret = self:checkAutoPlayerSkill(inSkill, inCamp)

    if isOk == false then 
        if ret == 0 then
            return false, 1
        else
            return false, ret + 2
        end
    end

    -- 是否是验证
    if isVerify == true then
        return true
    end
 
    -- 能量值消耗
    if inSkill.mana ~= nil then
        self._heroAttrFunc[inCamp](self, - floor(inSkill.mana * self._manaPro[inCamp]))
    end

    -- 单回合释放次数限制
    if inSkill.sumnum ~= nil then 
        inSkill.sumnum = inSkill.sumnum - 1
        if inSkill.sumnum <= 0 then
            -- 技能总释放次数限制
            if inSkill.wholelim ~= nil then 
                inSkill.wholelim = inSkill.wholelim - 1
            end
        end
    end

    return true
end


function BattleSkillLogic:checkAutoPlayerSkill(inSkill, inCamp, isNotCheckMana)
    local tick = self.battleTime
    -- 沉默时间
    if tick < inSkill.silentTask then return false, 0 end
    -- cd时间
    if tick < inSkill.castTick then return false, 0 end

    -- 特殊释放条件
    if inSkill.castCon == 1 then
        if self._teamDieCount[inCamp] <= 0 then
            return false, 1
        end
    end

    local isOk = true

    -- 法术使用次数限制
    if inSkill.castCount == 0 then
        isOk = false
    end

    -- 总次数判断，如果为nil表示没有限制
    if inSkill.wholelim ~= nil and 
        inSkill.wholelim - 1 < 0 then 
        isOk = false
    end
    -- 单回合次数限制
    if inSkill.sumnum ~= nil and 
        inSkill.sumnum - 1 < 0 then
        isOk = false
    end

    -- 自动技能状态下检测
    if self._autoCastSkill == true or inCamp == 2 then
        if inSkill.sumnum == inSkill.maxSumnum and
            inSkill.comboIndex ~= nil and 
            inSkill.comboMana ~= nil and not isNotCheckMana then 
            if self.mana[inCamp] - floor(inSkill.comboMana * self._manaPro[inCamp]) < 0 then
                isOk = false 
            end
        end
    end

    return isOk, 0
end

function BattleSkillLogic:castPlayerSkill(inCaster, inSkill, endPoint, delay, isopenskill)
    inCaster.x = ceil(tonumber(format("%.2f", inCaster.x)))
    inCaster.y = ceil(tonumber(format("%.2f", inCaster.y)))
    if inCaster.camp == 1 and not isopenskill then
        self._playCastTime[#self._playCastTime + 1] = {self.battleFrameCount, inSkill.index, inCaster.x ,inCaster.y}
    end
    if inSkill.camp == 1 then
        self._canCast = false
    end
    if delay == nil then delay = 0.035 end
    if BC.jump then
        delayCall(delay, self, function ()
            self:_castPlayerSkill(inCaster, inSkill, endPoint, isopenskill)
            -- 技能附带技能
            local exSkill = inSkill.exSkill
            if exSkill then
                for i = 1, #exSkill do
                    local _inCaster = clone(inCaster)
                    _inCaster.castType = ECastType.QUICK
                    local _inSkill = clone(inSkill)
                    -- edit by hxp： 附带技能使用自己的范围，不继承
                    -- local skillD = tab.playerSkillEffect[inSkill.id]
                    _inSkill.id = exSkill[i]
                    local skillD1 = tab.playerSkillEffect[_inSkill.id]
                    _inSkill.forbidRange1 = skillD1["range1"]
                    _inSkill.forbidRange2 = skillD1["range2"]
                    self:_castPlayerSkill(_inCaster, _inSkill, endPoint, isopenskill)
                end
            end
        end)
        return
    end
    local sysSkill = tab.playerSkillEffect[inSkill.id]
    if (self._enableHeroSkillAnim and sysSkill["shotcut"] == 1) or inSkill.id == BC.forceHeroSkillAnimId then
        local kind = sysSkill["type"] - 1
        if kind >= 1 and kind <= 4 then
            self._control:heroSkillAnim(inCaster.camp, lang(sysSkill["name"]), sysSkill["id"], self._heros[inCaster.camp].heroHeadName, kind, self._heros[inCaster.camp].ID)
            -- 矮人宝物只显示一次
            if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_AiRenMuWu then
                self._enableHeroSkillAnim = false
            end
        end
    end
    delayCall(delay, self, function ()
        self:_castPlayerSkill(inCaster, inSkill, endPoint, isopenskill)
        -- 技能附带技能
        local exSkill = inSkill.exSkill
        if exSkill then
            for i = 1, #exSkill do
                local _inCaster = clone(inCaster)
                _inCaster.castType = ECastType.QUICK
                local _inSkill = clone(inSkill)
                -- edit by hxp： 附带技能使用自己的范围，不继承
                -- local skillD = tab.playerSkillEffect[inSkill.id]
                _inSkill.id = exSkill[i]
                local skillD1 = tab.playerSkillEffect[_inSkill.id]
                _inSkill.forbidRange1 = skillD1["range1"]
                _inSkill.forbidRange2 = skillD1["range2"]
                self:_castPlayerSkill(_inCaster, _inSkill, endPoint, isopenskill)
            end
        end
    end)
end
--[[
--! @function castPlayerSkill
--! @desc 释放技能
--! @param inSkillKind int 激活特征
--! @param inSkill object 技能数据
--! @return 
--]]
local SRTab = {384, 391, 398, 405, 412, 419, 427, 435, 442, 450, 456, 462}
local BUFF_ID_YUN = 1086
local actionInv = BC.actionInv
local RecordReleaseSkill = BC.RecordReleaseSkill
function BattleSkillLogic:_castPlayerSkill(inCaster, inSkill, endPoint, isopenskill)
    -- print(inCaster.camp, self.battleTime, inSkill.id)
    local ing = self.battleState == EState.ING
    local castTick
    if self.battleBeginTick then
        castTick = self.battleTime
    else
        castTick = 0
    end
    local skillid = inSkill.id
    local sysSkill = tab.playerSkillEffect[skillid]
 
    if inCaster.castType ~= ECastType.QUICK then
        -- 释放次数为0就重置cd
        if inSkill.sumnum <= 0 then
            inSkill.cd = inSkill.maxCD * 0.001
            inSkill.castTick = castTick + inSkill.cd 
        end
    end

    if inSkill.castCount > 0 then
        inSkill.castCount = inSkill.castCount - 1
        if inSkill.castCount == 0 then
            inSkill.castTick = 0
        end
    end

    local camp = inCaster.camp
    -- 英雄动作
    local subCamp = BC.reverse and 1 or 2
    local heroSkinD
    local skin = self._heros[camp].skin
    if skin then
        heroSkinD = tab.heroSkin[skin]
    end
    if not BC.jump then
        if sysSkill["name"] then
            local weaponSkillIndex = inCaster.weaponSkillIndex
            if weaponSkillIndex == nil then
                self._heros[camp]:Cast()
                if sysSkill["dpsshow"] == 1 then
                    if camp == subCamp then
                        self._heros[subCamp]:showSkillName(lang(sysSkill["name"]))
                    else
                        if self._battleInfo.isShare then
                            self._heros[3 - subCamp]:showSkillName(lang(sysSkill["name"]))
                        end
                        objLayer:showHP(false, false)
                    end
                end
                inCaster.dpsshow = sysSkill["dpsshow"]
            else
                -- 器械放技能
                local _weapon = self._weapons[camp][weaponSkillIndex]
                _weapon:Cast()
                if sysSkill["dpsshow"] == 1 then
                    if camp == subCamp then
                        _weapon:showSkillName(lang(sysSkill["name"]))
                    else
                        if self._battleInfo.isShare then
                            self._weapons[3 - subCamp][weaponSkillIndex]:showSkillName(lang(sysSkill["name"]))
                        end
                    end
                end
                inCaster.dpsshow = sysSkill["dpsshow"]

                -- if not BATTLE_PROC then
                --     local x1, y1 = _weapon.x, _weapon.y
                --     local x2, y2 = inCaster.x, inCaster.y
                --     local dis = sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
                --     objLayer:rangeAttackPt2(
                --         x1, y1, 0, 0, 
                --         x2, y2, 0, 0, 
                --         0, -- 延迟
                --         800, -- 速度
                --         2, -- 弹道
                --         "jushi", -- 子弹图片
                --         dis)
                -- end
            end
        end
    end
    local forceDoubleEffect = false
    -- 学院火系大招 双倍效果
    if self:isEnableMG(camp, 1) then
        forceDoubleEffect = true
        self:disableMGTip(camp, 1)
    end
    -- 学院土系大招 晕眩效果
    local yunBuff = false
    if sysSkill["iff2"] == 101 and self:isEnableMG(camp, 4) then
        yunBuff = true
        self:disableMGTip(camp, 4)
    end
    local direct
    if camp == subCamp then
        direct = -1
    else
        if SRData then
            -- 使用次数计数
            local _index = inSkill.index
            local _index1 = 126 + (_index - 1) * 10
            local _index2 = _index1 + 1
            local _index3 = _index2 + 1
            SRData[_index1] = SRData[_index1] + 1
            -- 第一次使用的时间
            local _tick = floor(castTick * 1000)
            if SRData[_index2] == 0 then SRData[_index2] = _tick end
            -- 最小使用间隔
            local lastTick = self._lastCastSkillTick
            if lastTick[_index] then
                local _d = _tick - lastTick[_index] 
                if SRData[_index3] == 0 then 
                    SRData[_index3] = _d
                else
                    if _d < SRData[_index3] then SRData[_index3] = _d end
                end
            end
            lastTick[_index] = _tick
        end
        if self._castSkillCount[skillid] then
            self._castSkillCount[skillid] = self._castSkillCount[skillid] + 1
        else
            self._castSkillCount[skillid] = 1
        end
    end

    local success = false
    if isopenskill or sysSkill["iff2"] ~= 101 or sysSkill["iff2"] ~= 103 then
        -- 开场技能和己方技能，不算失败率
        success = true
    else
        local failedPro = BC.H_failedPro[camp]
        local failedValue = self._failedValue[camp]
        if failedPro > 0 then
            if failedValue < H_FAILED_MIN then
                -- 小于下限，必定成功，增加积分
                success = true
            elseif failedValue > H_FAILED_MAX then
                -- 大于下线，必定失败，减少积分
                success = false
            else
                -- 按几率走
                success = random(100) > failedPro
            end
            if success then
                failedValue = failedValue + H_FAILED_ADD_FIX + random(H_FAILED_ADD_RAN)
            else
                failedValue = failedValue - H_FAILED_DEC
            end
            self._failedValue[camp] = failedValue
        else
            -- 几率小于等于0，必定不会失败
            success = true
        end
    end
    -- print("###", self._failedValue[1], self._failedValue[2])

    if success then
        -- 每日小惊喜
        if self._surpriseOpen and camp == 1 and not isopenskill then
            local _kind = sysSkill["type"] - 1
            -- if _kind == 0 then
            --     _kind = 3
            -- end

            if _kind > 0 then
                 self._surpriseList[self._surpriseIndex] = _kind
                if self._surpriseIndex == 4 then
                    local success = true
                    for i = 1, 4 do
                        if BattleUtils.surpriseList[i] ~= self._surpriseList[i] then
                            success = false
                            break
                        end
                    end
                    if success then
                        BattleUtils.surpriseSuccess = true
                        self._surpriseOpen = false
                        self._control:playSurpriseMC(BattleUtils.surpriseList)
                    end
                end
                self._surpriseIndex = self._surpriseIndex + 1
                if self._surpriseIndex > 4 then
                    self._surpriseIndex = 1
                end
            end 
        end

        if SRData then
            if camp == 1 then
                local sr = self._SRSkillTab[skillid]
                if sr then
                    for i = 1, #sr do
                        local index = SRTab[sr[i]]
                        SRData[index] = SRData[index] + 1
                    end
                end
            end
        end

        local scale
        if sysSkill["stkscale"] then
            scale = sysSkill["stkscale"] * 0.01
        end
            
        local preTick = 0
        delayCall(preTick, self, function()
            -- 声音
            if not BC.jump then 
                local sk_sound = sysSkill["sk_sound"]
                if sk_sound then
                    for i = 1, #sk_sound do
                        ScheduleMgr:delayCall(sk_sound[i][2] * 50, self, function()
                            audioMgr:playSound(sk_sound[i][1])
                        end)
                    end
                end
                self:playerSkillCount(inCaster.index, 0, 0, inCaster.skillid, camp, inCaster.sindex)
            end
            -- local caster = initSkillCaster(self._castSkillX, self._castSkillY, 1)
            local rangePro = 1 + inSkill.rangePro * 0.01
            local summonAdd = inSkill.rangePro

            local doubleEffect = false
            if sysSkill["mgtype"] == 2 then
                local __type = sysSkill["type"] - 1
                if __type > 0 and __type < 5 then
                    doubleEffect = (random(100) <= BC.H_DE_2[camp][__type])
                end
            end
            local delayGetTargetsFun
            for k = 1, 2 do
                local ptx, pty 
                local team
                local rangetype
                local action
                local option
                local buffid, buff, pro 
                local ranbuffids = {}
                local points = {}
                local ranges 
                local range 
                local draglenth 

                local draglenth1 
                local draglenth2 
                local draglenth3 

                local tempTargets 
                local tempKeyTargets
                local tempBeginPoint
                local tempEndPoint                
                local targets

                local _range = inSkill["forbidRange" ..k ] or sysSkill["range" .. k]
                
                rangetype = sysSkill["rangetype"..k]
                if rangetype == nil then break end

                option = sysSkill["option"]
                if sysSkill["iff2"] == 101  then 
                    inCaster.paramAdd = 100 * self._heroDamagePro
                end
            -- 施放操作方式判断
                if option == 1 or 
                    option == 3  then 
                    if _range == nil then 
                        _range = 0
                    end
                    -- 如果点击单位为己方单位或敌方单位需要单独处理
                    local isUseTotem = false
                    if sysSkill["pointkind"] > 1 then
                        local soldier = self._getTouchSkillPointFunc[sysSkill["pointkind"]](self, inCaster)
                        if soldier ~= nil then 
                            ptx, pty = soldier.x, soldier.y
                            -- print("ptx, pty====",ptx, pty, inSkill.id, self.battleTime)
                            isUseTotem = true
                        else
                             ptx, pty = inCaster.x ,inCaster.y
                        end
                    else
                        ptx, pty = inCaster.x ,inCaster.y
                        isUseTotem = true
                    end
                    table.insert(points, {x = ptx, y = pty})
                    delayGetTargetsFun = function(k)
                        if k == 1 and isUseTotem == true then
                            self:useTotem(inCaster, sysSkill, inSkill, {x = ptx, y = pty}, 1, rangePro, forceDoubleEffect, yunBuff)
                        end
                        return self:getSkillTargets(ptx, pty, {x = ptx, y = pty}, inCaster, rangetype, _range * rangePro, sysSkill["target"..k], sysSkill["count"..k], camp)
                    end
                elseif option == 2 then 
                        ranges = {}
                        range = _range
                        if range == nil then 
                            range = 0
                        end
                        draglenth = sysSkill["draglenth"]

                        draglenth1 = draglenth[1]
                        draglenth2 = draglenth[2]
                        draglenth3 = draglenth[3]

                        if endPoint == nil then 
                            endPoint = {}
                        end
                        endPoint.x = inCaster.x
                        endPoint.y = inCaster.y
                        if sysSkill["direction"] ~= nil and sysSkill["direction"] == 2 then 
                                endPoint.y = endPoint.y - 10
                        else
                            if camp == 1 then 
                                endPoint.x = endPoint.x + 10
                            else
                                endPoint.x = endPoint.x - 10
                            end                            
                        end

                        local correctionX = 0.5 * (draglenth1 * (draglenth2 - 1) + (pow(draglenth2,2) - draglenth2) * draglenth3 / 2) / sqrt(pow((endPoint.x - inCaster.x),2) + pow((endPoint.y - inCaster.y),2)) * (endPoint.x - inCaster.x)
                        local correctionY = 0.5 * (draglenth1 * (draglenth2 - 1) + (pow(draglenth2,2) - draglenth2) * draglenth3 / 2) / sqrt(pow((endPoint.x - inCaster.x),2) + pow((endPoint.y - inCaster.y),2)) * (endPoint.y - inCaster.y)

                        table.insert(points, {x = inCaster.x - correctionX, y = inCaster.y - correctionY})
                        table.insert(ranges, range )
                        
                        for n = 2, draglenth2 do 
                            ptx = inCaster.x + (draglenth1 * (n - 1) + (pow(n,2) - n) * draglenth3 / 2) / sqrt(pow((endPoint.x - inCaster.x),2) + pow((endPoint.y - inCaster.y),2)) * (endPoint.x - inCaster.x) - correctionX 
                            pty = inCaster.y + (draglenth1 * (n - 1) + (pow(n,2) - n) * draglenth3 / 2) / sqrt(pow((endPoint.x - inCaster.x),2) + pow((endPoint.y - inCaster.y),2)) * (endPoint.y - inCaster.y) - correctionY
                            table.insert(points,{x = ptx, y = pty})
                            table.insert(ranges,range + (n - 1) * draglenth3)
                        end
                        tempKeyTargets = {}
                        targets = {}
                        delayGetTargetsFun = function(k)
                            local index = 1
                            for k1,v in pairs(points) do
                                if rangetype ~= 0 then
                                    tempTargets = self:getSkillTargets(v.x, v.y, {x = v.x, y = v.y}, inCaster, rangetype, ranges[k1] * rangePro, sysSkill["target"..k], sysSkill["count"..k], camp)
                                    for k2,v in pairs(tempTargets) do
                                        if tempKeyTargets[""..v.ID] == nil then 
                                            tempKeyTargets[""..v.ID] = v
                                            table.insert(targets, v)
                                        end
                                    end
                                end
                                if k == 1 then
                                    delayCall(0.05 * index, self, function ()
                                        self:useTotem(inCaster, sysSkill, inSkill, {x = v.x, y = v.y}, 1, rangePro, forceDoubleEffect, yunBuff)
                                    end, not ing)
                                end
                                index = index + 1
                            end
                            return targets
                        end
                end    
                -- points 
                if #points > 0 then 
                    if option ~= 2 then 
                        for i=1,#points do
                            tempBeginPoint = points[i]
                            -- 通用技能光影
                            if sysSkill["cstktype"] then
                                local _x, _y = tempBeginPoint.x, tempBeginPoint.y
                                if not BC.jump then
                                    objLayer:playEffect_skill1("quan"..camp.."_commoncast", _x, _y, false, true, direct, 1.6)
                                    objLayer:playEffect_skill1("buff"..camp.."-"..sysSkill["cstktype"].."_commoncast", _x, _y, 1, true, direct, 1.6)
                                    if sysSkill["cstk"] then
                                        objLayer:playCommonBuff(sysSkill["cstk"], camp, _x, _y)
                                    end
                                end
                                local adcstk = sysSkill["adcstk"]
                                if adcstk then
                                    for j = 1, #adcstk do
                                        delayCall(j * 0.25, self, function()
                                            if not BC.jump then
                                                objLayer:playCommonAttr(adcstk[j], camp, _x, _y)
                                            end
                                        end)
                                    end
                                end
                            end
                            if not BATTLE_PROC and not BC.jump then
                                local frontstk_v = (heroSkinD and heroSkinD["frontstk_v"]) and sysSkill["frontstk_v".. heroSkinD["frontstk_v"]] or sysSkill["frontstk_v"]
                                if frontstk_v then
                                    objLayer:playEffect_skill1(frontstk_v, tempBeginPoint.x, tempBeginPoint.y, 1, true, direct, scale)
                                end
                                local frontstk_h = (heroSkinD and heroSkinD["frontstk_h"]) and sysSkill["frontstk_h".. heroSkinD["frontstk_h"]] or sysSkill["frontstk_h"]
                                if frontstk_h then
                                    objLayer:playEffect_skill1(frontstk_h, tempBeginPoint.x, tempBeginPoint.y, 1, false, direct, scale)
                                end
                                local backstk_v = (heroSkinD and heroSkinD["backstk_v"]) and sysSkill["backstk_v".. heroSkinD["backstk_v"]] or sysSkill["backstk_v"]
                                if backstk_v then
                                    objLayer:playEffect_skill1(backstk_v, tempBeginPoint.x, tempBeginPoint.y, false, true, direct, scale)
                                end
                                local backstk_h = (heroSkinD and heroSkinD["backstk_h"]) and sysSkill["backstk_h".. heroSkinD["backstk_h"]] or sysSkill["backstk_h"]
                                if backstk_h then
                                    objLayer:playEffect_skill1(backstk_h, tempBeginPoint.x, tempBeginPoint.y, false, false, direct, scale)
                                end 
                            end
                        end
                    else
                        if not BATTLE_PROC and not BC.jump then
                            tempBeginPoint = inCaster
                            tempEndPoint = points[#points]
                            local frontstk_v = (heroSkinD and heroSkinD["frontstk_v"]) and sysSkill["frontstk_v".. heroSkinD["frontstk_v"]] or sysSkill["frontstk_v"]
                            if frontstk_v then
                                objLayer:playEffect_skill2(frontstk_v, tempBeginPoint.x, tempBeginPoint.y, tempEndPoint.x, tempEndPoint.y, 1, direct)
                            end
                            local frontstk_h = (heroSkinD and heroSkinD["frontstk_h"]) and sysSkill["frontstk_h".. heroSkinD["frontstk_h"]] or sysSkill["frontstk_h"]
                            if frontstk_h then
                                objLayer:playEffect_skill2(frontstk_h, tempBeginPoint.x, tempBeginPoint.y, tempEndPoint.x, tempEndPoint.y, 1, direct)
                            end
                            local backstk_v = (heroSkinD and heroSkinD["backstk_v"]) and sysSkill["backstk_v".. heroSkinD["backstk_v"]] or sysSkill["backstk_v"]
                            if backstk_v then
                                objLayer:playEffect_skill2(backstk_v, tempBeginPoint.x, tempBeginPoint.y, tempEndPoint.x, tempEndPoint.y, false, direct)
                            end
                            local backstk_h = (heroSkinD and heroSkinD["backstk_h"]) and sysSkill["backstk_h".. heroSkinD["backstk_h"]] or sysSkill["backstk_h"]
                            if backstk_h then
                                objLayer:playEffect_skill2(backstk_h, tempBeginPoint.x, tempBeginPoint.y, tempEndPoint.x, tempEndPoint.y, false, direct)
                            end
                        end
                    end
                end
                if not BATTLE_PROC and not BC.jump then
                    local quanpingstk
                    if sysSkill["quanpingstk"] and heroSkinD and heroSkinD["quanpingstk"] and sysSkill["quanpingstk"..heroSkinD["quanpingstk"]] then
                        quanpingstk = sysSkill["quanpingstk"..heroSkinD["quanpingstk"]]
                    else
                        quanpingstk = sysSkill["quanpingstk"]
                    end
                    if quanpingstk then
                        for i = 1, #quanpingstk do
                            -- 全屏特效
                            objLayer:playEffect_skill3(quanpingstk[i][1], quanpingstk[i][2], camp ~= 1)
                        end
                    end
                    quanpingstk = sysSkill["quanpingstk_v"]
                    if quanpingstk then
                        for i = 1, #quanpingstk do
                            -- 全屏特效
                            objLayer:playEffect_skill4(quanpingstk[i][1], quanpingstk[i][2], tempBeginPoint.x, tempBeginPoint.y, camp ~= 1)
                        end
                    end
                end

                local hitTick = 0
                if sysSkill["dmgt"..k] then
                    hitTick = sysSkill["dmgt"..k] * actionInv
                end
                -- delayCall(hitTick, self, function()

                -- end, not ing)
                local boom = sysSkill["beatart"..k]
                -- if targets ~= nil and #targets > 0 then
                delayCall(hitTick, self, function()
                    if delayGetTargetsFun ~= nil then 
                        targets = delayGetTargetsFun(k)
                    end
                    
                    -- 特殊条件筛选
                    if targets ~= nil and #targets > 0 then
                        targets = self:countCharacters(inCaster, targets, sysSkill["valid" .. k], sysSkill["condition" .. k], 0)
                    end
                    if not (targets ~= nil and #targets > 0) then
                        return
                    end
                    if k == 2 then
                        if not BATTLE_PROC and not BC.jump then
                            local __delay = sysSkill["adddelay"]
                            if __delay then
                                tempBeginPoint = points[1]
                                tempEndPoint = points[#points]
                                delayCall(__delay * actionInv, self, function()
                                    if sysSkill["addfrontstk_v"] then
                                        objLayer:playEffect_skill1(sysSkill["addfrontstk_v"], tempBeginPoint.x, tempBeginPoint.y, 1, true, direct, scale)
                                    end
                                    if sysSkill["addfrontstk_h"] then
                                        objLayer:playEffect_skill1(sysSkill["addfrontstk_h"], tempBeginPoint.x, tempBeginPoint.y, 1, false, direct, scale)
                                    end
                                    if sysSkill["addbackstk_v"] then
                                        objLayer:playEffect_skill1(sysSkill["addbackstk_v"], tempBeginPoint.x, tempBeginPoint.y, false, true, direct, scale)
                                    end
                                    if sysSkill["addbackstk_h"] then
                                        objLayer:playEffect_skill1(sysSkill["addbackstk_h"], tempBeginPoint.x, tempBeginPoint.y, false, false, direct, scale)
                                    end             
                                end)
                            end
                        end
                    end
                    local hitDelay = 0
                    if sysSkill["hitDelay"..k] then
                        hitDelay = sysSkill["hitDelay"..k] * actionInv
                    end
                    delayCall(hitDelay, self, function()
                        -- 震动
                        if not BC.jump then
                            if sysSkill["shake"..k] then
                                self:shake(sysSkill["shake"..k])
                            end
                        end

                        local inv = 0
                        if sysSkill["linkdelay"..k] then
                            inv = sysSkill["linkdelay"..k] * actionInv
                        end
                        action = sysSkill["damagekind"..k] -- action为空表示有可能用子物体实现技能



                        if action then
                            -- 技能附带基础的成长
                            local valueaddPro
                            -- 技能附带的动作
                            local ExAction, ExSkillD
                            if action == 1 then
                                valueaddPro = inSkill.healBasePro
                                if inSkill.healExAction then
                                    ExAction = inSkill.healExAction[1]
                                    ExSkillD = inSkill.healExAction[2]
                                end
                            elseif action == 2 then
                                valueaddPro = inSkill.damageBasePro
                                if inSkill.damageExAction then
                                    ExAction = inSkill.damageExAction[1]
                                    ExSkillD = inSkill.damageExAction[2]
                                end
                            end
                            if inv == 0 then
                                local success = true
                                if sysSkill["probability"..k] then
                                    success = random(100) <= sysSkill["probability"..k]
                                end
                                if success then
                                    if boom then 
                                        for t = 1, #targets do
                                            objLayer:rangeHit(targets[t], boom) 
                                        end
                                    end
                                    
                                    -- 自残
                                    if sysSkill["valuedraw"..k] then
                                        local _tar, _damage
                                        local _v = sysSkill["valuedraw"..k]
                                        for t = 1, #targets do
                                            _tar = targets[t]
                                            if not _tar.die then
                                                local oldMinHP = _tar.minHP
                                                _tar.minHP = 1
                                                _damage = ceil(_tar.maxHP * (_v[1] + _v[2] * (inSkill.level - 1)) * 0.01)
                                                _tar:beDamaged(attacker, -_damage, false, 0, nil, nil, nil, nil, true)
                                                _tar.minHP = oldMinHP
                                            end
                                        end
                                    else
                                        self._skillActionFunc[action](self, castTick, inCaster, targets, sysSkill, k, inSkill.level, forceDoubleEffect, summonAdd, inSkill.index, nil, valueaddPro)
                                        if ExAction then
                                            self._skillActionFunc[ExAction](self, castTick, inCaster, targets, ExSkillD, 1, inSkill.level, forceDoubleEffect, summonAdd, inSkill.index)
                                        end
                                    end

                                    if not BC.jump and sysSkill["hitfly"..k] then
                                        for t = 1, #targets do
                                            if not targets[t].die then
                                                targets[t]:hitFly()
                                            end
                                        end
                                    end
                                end
                            else
                                for t = 1, #targets do
                                    delayCall((t - 1) * inv, self, function()
                                        local success = true
                                        if sysSkill["probability"..k] then
                                            success = random(100) <= sysSkill["probability"..k]
                                        end
                                        if success then
                                            local _v = sysSkill["valuedraw"..k]
                                            local _tar, _damage
                                            _tar = targets[t]
                                            if boom then objLayer:rangeHit(_tar, boom) end
                                            -- 自残
                                            if _v then
                                                if not _tar.die then
                                                    local oldMinHP = _tar.minHP
                                                    _tar.minHP = 1
                                                    _damage = ceil(_tar.maxHP * (_v[1] + _v[2] * (inSkill.level - 1)) * 0.01)
                                                    _tar:beDamaged(attacker, -_damage, false, 0, nil, nil, nil, nil, true)
                                                    _tar.minHP = oldMinHP
                                                end
                                            else
                                                self._skillActionFunc[action](self, castTick, inCaster, {_tar}, sysSkill, k, inSkill.level, forceDoubleEffect, summonAdd, inSkill.index, nil, valueaddPro)
                                                if ExAction then
                                                    self._skillActionFunc[ExAction](self, castTick, inCaster, {_tar}, ExSkillD, 1, inSkill.level, forceDoubleEffect, summonAdd, inSkill.index)
                                                end
                                            end
                                            if not BC.jump and sysSkill["hitfly"..k] then
                                                _tar:hitFly()
                                            end
                                        end
                                    end, not ing)
                                end
                            end
                        end
                        -- 上buff
                        buffid = sysSkill["buffid"..k]
                        local _sameCamp = sysSkill["iff2"] == 100
                        if buffid then
                            pro = sysSkill["buffpro"..k][1] + sysSkill["buffpro"..k][2] * (inSkill.level - 1)
                            if sysSkill["probability"..k] then
                                pro = pro * 0.01 * sysSkill["probability"..k]
                            end
                            local _target
                            for t = 1, #targets do   
                                delayCall(t * inv, self, function()
                                    _target = targets[t]
                                    if not _target.die and random(100) <= pro then
                                        local buff = initPlayerBuff(camp, buffid, inSkill.level, _target, 100, sysSkill["type"] - 1, doubleEffect or forceDoubleEffect, skillid)

                                        -- 魔法天赋 
                                        -- 3 增加持续时间
                                        -- 4 增加持续时间百分比
                                        -- 7 增加护盾效果值
                                        -- 8 增加护盾效果百分比
                                        if BC.H_SkillBookTalent[camp] and BC.H_SkillBookTalent[camp]["targetSkills"][skillid] then
                                            BattleUtils.countSkillBookTalent(skillid, buff, {3, 4, 7, 8}, camp)
                                            buff.endTick  = buff.duration * 0.001 + BC.BATTLE_BUFF_TICK
                                        end  
                                        _target:addBuff(buff)
                                        if sysSkill["type"] ~= 8 and _sameCamp and _target.camp == camp and _target.skillTab[35] then
                                            _target:invokeSkill(35)
                                        end

                                    end
                                end, not ing)
                            end
                            if SRData then
                                if camp == 1 then
                                    local sr = tab.skillBuff[buffid].sr
                                    local __count = #targets
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

                        local morale = sysSkill["morale"..k]
                        if morale then
                            for t = 1, #targets do   
                                targets[t].team.shiqiValue = targets[t].team.shiqiValue + morale
                            end
                        end

                        if yunBuff then
                            -- 上晕眩BUFF
                            local _target
                            for t = 1, #targets do   
                                _target = targets[t]
                                if _target.caster and not _target.die then
                                    buff = initSoldierBuff(BUFF_ID_YUN, 1, _target.caster, _target)
                                    _target:addBuff(buff)
                                end
                            end
                        end

                        if sysSkill["ranbuffid"..k] and sysSkill["ranbuffnum"..k] then
                            ranbuffids = BC.genRanBuff(sysSkill["ranbuffid"..k], sysSkill["ranbuffnum"..k])
                            if ranbuffids then
                                local ranbuffid
                                for i = 1, #ranbuffids do
                                    ranbuffid = ranbuffids[i]
                                    local _target
                                    for t = 1, #targets do   
                                        delayCall(t * inv, self, function()
                                            _target = targets[t]
                                            if not _target.die then
                                                local ranbuff = initPlayerBuff(camp, ranbuffid, inSkill.level, _target, 100, sysSkill["type"] - 1, doubleEffect or forceDoubleEffect, skillid)

                                                -- 魔法天赋 
                                                -- 3 增加持续时间
                                                -- 4 增加持续时间百分比
                                                -- 7 增加护盾效果值
                                                -- 8 增加护盾效果百分比
                                                if BC.H_SkillBookTalent[camp] and BC.H_SkillBookTalent[camp]["targetSkills"][skillid] then
                                                    BattleUtils.countSkillBookTalent(skillid, ranbuff, {3, 4, 7, 8}, camp)
                                                    ranbuff.endTick  = ranbuff.duration * 0.001 + BC.BATTLE_BUFF_TICK
                                                end  
                                                _target:addBuff(ranbuff)
                                                if sysSkill["type"] ~= 8 and _sameCamp and _target.camp == camp and _target.skillTab[35] then
                                                    _target:invokeSkill(35)
                                                end

                                            end
                                        end, not ing)
                                    end
                                    if SRData then
                                        if camp == 1 then
                                            local sr = tab.skillBuff[ranbuffid].sr
                                            local __count = #targets
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

                        -- 特效
                        local inv = 0
                        if sysSkill["linkdelay"..k] then
                            inv = sysSkill["linkdelay"..k] * actionInv
                        end
                        if sysSkill["implocation"..k] == nil or sysSkill["implocation"..k] == 1 then
                            -- 目标点特效
                            local pos = sysSkill["hitplace"..k]
                            if sysSkill["frontimp_v"..k] then
                                local res = sysSkill["frontimp_v"..k]
                                for t = 1, #targets do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_hit1(res, 1, true, targets[t], pos)
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["frontimp_h"..k] then
                                local res = sysSkill["frontimp_h"..k]
                                for t = 1, #targets do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_hit1(res, 1, false, targets[t], pos)
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["backimp_v"..k] then
                                local res = sysSkill["backimp_v"..k]
                                for t = 1, #targets do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_hit1(res, false, true, targets[t], pos)
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["backimp_h"..k] then
                                local res = sysSkill["backimp_h"..k]
                                for t = 1, #targets do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_hit1(res, false, false, targets[t], pos)
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["frontlink"..k] and #targets > 1 then
                                local res = sysSkill["frontlink"..k]
                                local inv = 0
                                if sysSkill["linkdelay"..k] then
                                    inv = sysSkill["linkdelay"..k] * actionInv
                                end
                                if not BC.jump then
                                    objLayer:playEffect_hit2_pt(res, 1, points[1].x, points[1].y, targets[1])
                                end
                                for t = 1, #targets - 1 do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_hit2(res, 1, targets[t], targets[t + 1])
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["backlink"..k] and #targets > 1 then
                                local res = sysSkill["backlink"..k]
                                if not BC.jump then
                                    objLayer:playEffect_hit2_pt(res, 1, points[1].x, points[1].y, targets[1])
                                end
                                for t = 1, #targets - 1 do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_hit2(res, false, targets[t], targets[t + 1])
                                        end
                                    end, not ing)
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
                            if sysSkill["frontimp_v"..k] then
                                local res = sysSkill["frontimp_v"..k]
                                for t = 1, #list do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_skill1(res, list[t].x, list[t].y, 1, true)
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["frontimp_h"..k] then
                                local res = sysSkill["frontimp_h"..k]
                                for t = 1, #list do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_skill1(res, list[t].x, list[t].y, 1, false)
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["backimp_v"..k] then
                                local res = sysSkill["backimp_v"..k]
                                for t = 1, #list do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_skill1(res, list[t].x, list[t].y, false, true)
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["backimp_h"..k] then
                                local res = sysSkill["backimp_h"..k]
                                for t = 1, #list do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_skill1(res, list[t].x, list[t].y, false, false)
                                        end
                                    end, not ing)
                                end
                            end
                            if sysSkill["frontlink"..k] and #targets > 1 then
                                local res = sysSkill["frontlink"..k]
                                local inv = 0
                                if sysSkill["linkdelay"..k] then
                                    inv = sysSkill["linkdelay"..k] * actionInv
                                end
                                if not BC.jump then
                                    objLayer:playEffect_hit2_pt2(res, 1, points[1].x, points[1].y, list[1].x, list[1].y)
                                    end
                                for t = 1, #list - 1 do     
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_hit2_pt2(res, 1, list[t].x, list[t].y, list[t + 1].x, list[t + 1].y)
                                            end
                                    end, not ing)
                                end
                            end
                            if sysSkill["backlink"..k] and #targets > 1 then
                                local res = sysSkill["backlink"..k]
                                if not BC.jump then
                                    objLayer:playEffect_hit2_pt2(res, false, points[1].x, points[1].y, list[1].x, list[1].y)
                                end
                                for t = 1, #list - 1 do
                                    delayCall(inv * t, self, function()
                                        if not BC.jump then
                                            objLayer:playEffect_hit2_pt2(res, false, list[t].x, list[t].y, list[t + 1].x, list[t + 1].y)
                                        end
                                    end, not ing)
                                end
                            end               
                        end                        
                    end)
                end, not ing)
        
            end
        end)
    else
        -- 释放失败
        if not BC.jump then
            objLayer:playEffect_skill1("shifangfashushibai"..(3 - inCaster.camp).."_shifangfashushibai", inCaster.x, inCaster.y, 1, true)
        end
    end

    -- 能量值相关
    local anger = sysSkill["anger"]
    if anger then
        self._heroAttrFunc[1](self, anger[1])
        self._heroAttrFunc[2](self, -anger[2])
    end
    -- 士气相关
    local morale = sysSkill["morale"]
    if morale then
        self._heroAttrFunc[3](self, morale[1])
        self._heroAttrFunc[4](self, -morale[2])
    end
    -- cd与沉默相关处理
    local silent = sysSkill["silent"]
    if silent then
        for k=1,2 do
            if silent[k]~=nil and silent[k] ~= 0 then 
                -- 处理玩家技能状态
                local skill 
                local subTime1 = self.battleTime + silent[k] * 0.001
                local campSkill
                if i == 1 then 
                    campSkill = self._playSkills[camp]
                else
                    if camp == 1 then 
                        campSkill = self._playSkills[2]
                    else
                        campSkill = self._playSkills[1]
                    end
                end
                local count = #campSkill
                for i = 1, count do
                    skill = campSkill[i]
                    if silent[k] < 0 and 
                        skill.castTick - subTime1 > 0 then 
                        skill.castTick = skill.castTick + silent[k] * 0.001
                    elseif silent[k] > 0 then 
                        skill.silentTask = subTime1
                    end 
                end
            end
        end
    end
    if inCaster.castType ~= ECastType.QUICK then
        -- 释放次数为0就终止技能
        if inSkill.sumnum <= 0 then
            self:stopPlayerSkill(inCaster, inSkill)
        end
    end

    local _type = sysSkill["type"]
    if _type ~= 8 then
        self:invokeSkill22(camp, _type)
        self:invokeSkill23(3 - camp, _type)
        self:invokeSkill32(camp, sysSkill["dmgtag"])
    end

    -- 不耗蓝, 只要释放技能就关闭
    if self:isEnableMG(camp, 2) then
        self:disableMGTip(camp, 2)
    end

    -- 触发学院大招
    local _type = sysSkill["mgtriger"]
    if _type then
        if random(100) <= BC.MGTPro[camp][_type] then
            self:enableMGTip(camp, _type)
        end
    end

    _type = sysSkill["mgtriger1"]
    if _type then
        RecordReleaseSkill[camp + 2][#RecordReleaseSkill[camp + 2] + 1] = sysSkill["objectid"] or 0
        RecordReleaseSkill[camp][#RecordReleaseSkill[camp] + 1] = _type
        if not BATTLE_PROC and not BC.jump then
            self._control:setVisibleEnergyIcon(camp, #RecordReleaseSkill[camp], _type)
        end
        if #RecordReleaseSkill[camp] >= 3 then
            --萨丽尔元素
            self:checkCastPlayerConditionSkill(1, camp, RecordReleaseSkill[camp])
            RecordReleaseSkill[camp] = {}
--            RecordReleaseSkill[camp].disappearStartTime = BC.BATTLE_TOTEM_TICK + 0.10000000001
            if not BATTLE_PROC and not BC.jump then
                self._control:allVisibleEnergyIcon(camp)
            end
        end
    end

    -- self:enableMGTip(camp, random(4))
    return true
end

function BattleSkillLogic:isEnableMG(camp, index)
    return BC.MGTTag[camp][index]
end

function BattleSkillLogic:enableMGTip(camp, index)
    -- print("enableMGTip", camp, index)
    BC.MGTTag[camp][index] = true
    if camp == 1 and not BATTLE_PROC then
        self._control:enableMGTip(index)
    end
    if index == 3 then
        -- 重置CD
        self:resetCD(camp)
        self:disableMGTip(camp, index)
    elseif camp == 1 and not BATTLE_PROC then
        local icon
        for i = 1, MAX_SKILL_COUNT do
            if self._playSkills[1][i] then
                icon = self._skillIcons[i]
                if index == 2 then
                    -- 耗蓝显示
                    icon.label:setString("0")
                end
            end
        end
        if index == 2 then
            self._oriManaPro[camp] = self._manaPro[camp]
            self._manaPro[camp] = 0
        end
    end
end

function BattleSkillLogic:disableMGTip(camp, index)
    -- print("disableMGTip", camp, index)
    BC.MGTTag[camp][index] = false
    if camp == 1 and not BATTLE_PROC then
        self._control:disableMGTip(index)
    end
    if index == 3 then

    elseif camp == 1 and not BATTLE_PROC then
        if index == 2 then
            self._manaPro[camp] = self._oriManaPro[camp]
            print(self._manaPro[camp])
        end
        local icon
        for i = 1, MAX_SKILL_COUNT do
            if self._playSkills[camp][i] then
                icon = self._skillIcons[i]
                if index == 2 then
                    -- 耗蓝显示
                    icon.label:setString(floor(self._playSkills[camp][i].mana * self._manaPro[camp]))
                end
            end
        end

    end
end

function BattleSkillLogic:stopTipEffect(inSkill)
    if not inSkill then return end
    if inSkill.option == 2 then
        if inSkill.mcTip ~= nil then 
           objLayer:stopTipEffect(inSkill.mcTip) 
           inSkill.mcTip = nil 
        end
        if inSkill.mcTip2 ~= nil then 
           objLayer:stopTipEffect(inSkill.mcTip2)
           inSkill.mcTip2 = nil
        end
    else
        if inSkill.mc ~= nil then
            objLayer:stopEffect(inSkill.mcTip)
            objLayer:stopEffect(inSkill.mc)
            inSkill.mc = nil
            inSkill.mcTip = nil
        end
    end
end
--[[
--! @function stopPlayerSkill
--! @desc 终止技能释放，处理相关数据更新
--! @param inSkill object 操作技能
--! @return 
--]]
function BattleSkillLogic:stopPlayerSkill(inCaster, inSkill)
    -- 如果nSkill.sumnum 大于0 说明该技能是强制结束技能需要重置cd时间
    if inSkill.sumnum > 0 then
        inSkill.cd = inSkill.maxCD * 0.001
        inSkill.castTick = self.battleTime + inSkill.cd
    end

    self:stopTipEffect(inSkill)

    inSkill.tmpTick = nil
    -- local sysSkill = tab.playerSkillEffect[inSkill.id]


    

    inSkill.sumnum =  inSkill.maxSumnum
    -- sysSkill["sumnum"]
    inSkill.accum = 0 

    if inCaster.camp == 1 then
        self._playerTouchMovePoint = nil
        self._playerTouchBeginPoint = nil
        -- self._control:fadeOutBlack()
        -- self:setCampBrightness(1, 0)
        -- self:setCampBrightness(2, 0)
        -- objLayer:showHP(false, false)
        -- if self._skillIndexes[1] > 0 then 
        --     self._skillIcons[self._skillIndexes[1]].cdMC.isRelease = true
        --     self:setIconSelect(self._skillIndexes[1], false)
        --     self._skillIndexes[inCaster.camp] = 0
        -- end
        if not BC.jump then
            local tempFlag = self._skillIndexes[inCaster.camp]
            if self._autoCastSkill == true and inSkill.dark > 0 then
                -- dark
                ScheduleMgr:delayCall(inSkill.dark * 1000, self, function()
                    if self._control == nil then return end
                    if self.battleState == EState.ING then
                        self._control:fadeOutBlack()
                        self:setCampBrightness(1, 0)
                        self:setCampBrightness(2, 0)
                        objLayer:showHP(false, false)
                        if self._skillIndexes[1] > 0 then 
                            self._skillIcons[self._skillIndexes[1]].cdMC.isRelease = true
                            self:setIconSelect(self._skillIndexes[1], false)
                        end
                    end
                end)
            else
                if self._skillIndexes[1] > 0 then 
                    self._skillIcons[self._skillIndexes[1]].cdMC.isRelease = true
                    self:setIconSelect(self._skillIndexes[1], false)
                end
                self._control:fadeOutBlack()
                self:setCampBrightness(1, 0)
                self:setCampBrightness(2, 0)
            end
            self._skillIndexes[inCaster.camp] = 0
        else
            self._skillIndexes[inCaster.camp] = 0
        end
    else 
        self._skillIndexes[inCaster.camp] = 0
    end

    if inSkill.counterSkill ~= nil then 
        self:quickHandleEnemyAutoCastSkill(inCaster.camp, inSkill.counterSkill)
    end

    if isOpenAutoBattleForCamp[inCaster.camp] then
        if inCaster.camp ~= 1 or self._autoCastSkill then
            if inSkill.comboIndex ~= nil and inSkill.comboIndex > 0 then 
                local skill = self._playSkills[inCaster.camp][inSkill.comboIndex]
                self:castAutoSkill(inCaster, skill, inSkill.comboIndex)
                return
            end
        end
    end
    
    
    -- if 
    -- self:castPlayerSkill(self._option3Caster[i], skill)
    -- skill.intervalTick = skill.intervalTick +  skill.intervalCD * 0.001
end


--[[
--! @function getTouchSkillPoint2
--! @desc 2.距离最近敌方方阵中的最近的己方单位
--! @param caster object 临时筛选条件对象
--! @return soldier object 小兵 可能为nil
--]]
function BattleSkillLogic:getTouchSkillPoint2(caster)
    local teams = self.targetCache[caster.camp][10]
    return self:getNearbySoldierWithTeams(caster, teams)
end

--[[
--! @function getTouchSkillPoint3
--! @desc 3.距离最近敌方方阵中的最近的敌方单位
--! @param caster object 临时筛选条件对象
--! @return soldier object 小兵 可能为nil
--]]
function BattleSkillLogic:getTouchSkillPoint3(caster)
    local teams = self.targetCache[caster.camp][5]
    return self:getNearbySoldierWithTeams(caster, teams)
end


--[[
--! @function getNearbySoldierWithTeams
--! @desc 获取方阵内距离caster最近的小兵
--! @param caster object 临时筛选条件对象
--! @param teams table 方阵队列
--! @return soldier object 小兵 可能为nil
--]]
local ETeamStateDIE = ETeamState.DIE
function BattleSkillLogic:getNearbySoldierWithTeams(caster, teams, inMinDis, inOnlyTeam)
    local minDis = 99999999
    if inMinDis ~= nil then 
        minDis = inMinDis
    end
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
    if not team then 
        return nil
    end
    if inOnlyTeam == true then 
        return team
    end
    minDis = 99999999
    if inMinDis ~= nil then 
        minDis = inMinDis
    end
    local soldier 
    local soldiers = team.unorderSoldier
    for k = 1, #soldiers do
        if not soldiers[k].die then
            x2, y2 = soldiers[k].x, soldiers[k].y
            d = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
            if d < minDis then
                minDis = d
                soldier = soldiers[k]
            end
        end
    end
    return soldier
end

local ETeamStateDIE = BC.ETeamState.DIE

--[[
--! @function updateSkill
--! @desc 定时器
--]]
function BattleSkillLogic:updateSkill()
    local tick = self.battleTime
    -- 自然增长怒气 1/5s
    for i =1, 2 do
        if tick > self._lastAddManaTick + recManaInv then
            if not BC.jump then
                -- 回蓝动画
                if i == 1 and self.manaRec[1] > 0 then
                    self._control:addManaAnim()
                end
            end
            local rec = self.manaRec[i] * 2
            self._heroAttrFunc[i](self, rec + 0.00000001) -- 避免出现精度问题
            if i == 2 then 
                self._lastAddManaTick = tick
                -- print(self.mana[i])
            end
        end
    end

    -- 处理玩家技能状态
    local mainCamp = BC.reverse and 2 or 1
    for k=1, 2 do
        for i = 1, MAX_SKILL_COUNT do
            if self._playSkills[k][i] then
            	local skill = self._playSkills[k][i]
                if k == mainCamp then
                    if not BATTLE_PROC and not BC.jump then
                        self:updatePlayerSkillIconState(i, skill)
                    end
                end
            end
        end
    end
    -- 玩家手动释放技能, 下一帧释放
    if #self._nextFrameCastSkill > 0 then
        local cskill
        for i = 1, #self._nextFrameCastSkill do
            cskill = self._nextFrameCastSkill[i]
            local index, x, y = cskill[1], cskill[2], cskill[3]
            local skill = self._playSkills[1][index]
            local caster = initSkillCaster(0, 0, 1, skill.id, skill.castCount)
            local back = self:checkPlayerSkill(skill, 1)
            if back then
                caster.x = x
                caster.y = y
                self:castPlayerSkill(caster, skill, {x = x, y = y})
            end
        end
        self._nextFrameCastSkill = {}
    end
    self._skillCasting = false
    -- 复盘技能
    if self._castSkillList then
        if self._castSkillListIndex <= #self._castSkillList then
            local data = self._castSkillList[self._castSkillListIndex]
            while data[1] == self.battleFrameCount do
                local skill = self._playSkills[1][data[2]]
                local caster = initSkillCaster(0, 0, 1, skill.id, skill.castCount)
                local back, _ = self:checkPlayerSkill(skill, 1)
                if back then 
                    caster.x = data[3]
                    caster.y = data[4]
                    self:castPlayerSkill(caster, skill, {x = data[3], y = data[4]})

                    if not BATTLE_PROC and not BC.jump then
                        objLayer:flashSkillAreaEx(self:getSkillRadius(1, data[2]), data[3], data[4], 1)
                    end
                else
                    print("!!!!!!!!!!!!!!!!", back, _)
                end
                self._castSkillListIndex = self._castSkillListIndex + 1
                if self._castSkillListIndex > #self._castSkillList then break end
                data = self._castSkillList[self._castSkillListIndex]
            end
        end
    end

    if tick > self._lastHandleTick then
        self._lastHandleTick = tick + 0.5
        self:handleAutoCastSkill()
        self:handleForceAutoCastSkill()
        self:handleWeaponCastSkill()
    end
 end



--[[
--! @function checkComboSkill
--! @desc 检测combo技能释放条件
--! @param inCamp int 己方or敌方
--! @param inSkill object 英雄技能
--! @param inCheckType int 检测类型是否只检测自动技能条件或全条件
--]]
function BattleSkillLogic:checkComboSkill(inCamp, inSkill, inCheckType)
    if inCheckType == 1 then 
        if not self:checkAutoPlayerSkill(inSkill, inCamp, true) then
            return false
        end
    else
        if not self:checkPlayerSkill(inSkill, inCamp ,true) then
            return false
        end           
    end
    if inSkill.comboIndex == nil or 
        inSkill.comboIndex <= 0 then
        return true
    end
    local skill = self._playSkills[inCamp][inSkill.comboIndex]
    if skill == nil then      
        return true
    end
    return self:checkComboSkill(inCamp, skill, inCheckType)
end

--[[
--! @function quickHandleEnemyAutoCastSkill
--! @param inCamp int 己方or敌方
--! @param inCastSkillList object 技能释放队列
--! @desc 快速处理自动释放技能
--]]
function BattleSkillLogic:quickHandleEnemyAutoCastSkill(inCamp, inCastSkillList)
    local tempSkillIndexes = {{}, {}}
    print("inCamp==================", inCamp)
    local enemyCamp = (inCamp == 1 and 2 or 1)
    local flag = 0

    local tempPriv = {0, 0}
    local skill
    for k,index in pairs(inCastSkillList) do
        skill = self._playSkills[enemyCamp][index]
        if self:checkComboSkill(enemyCamp, skill, 2) then
            flag = 1
            tempSkillIndexes[enemyCamp][#tempSkillIndexes[enemyCamp] + 1] = index
            break
        end
    end

    if flag == 1 and (self._autoCastSkill == true or enemyCamp == 2) then
        self:handleAutoCastSkill(tempSkillIndexes)
    end
end

local ORDER_VOLUME = {BC.EVolume.V_BOSS, BC.EVolume.V_16, BC.EVolume.V_9, BC.EVolume.V_4, BC.EVolume.V_1}

--[[
--! @function handleAutoCastSkill
--! @param inCastSkillList object 技能释放队列
--! @desc 处理自动释放技能
--]]
local floor = floor
local AI_RUN_DELAY = BC.AI_RUN_DELAY
function BattleSkillLogic:handleAutoCastSkill(inCastSkillList)
    -- 开场后延迟ai执行
    if self.battleTime < AI_RUN_DELAY then 
        return
    end
    local skillIndexes = {0, 0}
    local skill
    local tempSkillIndexes = {{}, {}}
    --  临时优先级
    local tempPriv = {0, 0}
    local _ran
    if inCastSkillList ~= nil then 
        tempSkillIndexes = inCastSkillList
    else
        for i = 1, 2 do
            if i == 1 then
                _ran = random2
            else
                _ran = random
            end
            
            if (self._autoCastSkill == true or i == 2) and
                 self._skillIndexes[i] <= 0 and 
                 (isOpenAutoBattleForCamp[i]) then 
                if self._heros[1].ID == self._heros[2].ID and 
                    self._sameHeroFirstSkillState[i] ~= -2 then
                    if self._sameHeroFirstSkillState[i] < 0 then
                        local tempIndexes = {{}, {}}
                        for k,v in pairs(self._playAutoSkills[i]) do
                            skill = self._playSkills[i][v.index]
                            if skill.dazhao ~= 1 and skill.castCount ~= 0 then
                                tempIndexes[i][#tempIndexes[i] + 1] = v.index
                            end
                        end
                        local index = tempIndexes[i][_ran(#tempIndexes[i])]
                        self._sameHeroFirstSkillState[i] = index
                        tempSkillIndexes[i][#tempSkillIndexes[i] + 1] = index
                    else
                        tempSkillIndexes[i][#tempSkillIndexes[i] + 1] = self._sameHeroFirstSkillState[i]
                    end
                else
                    for k,v in pairs(self._playAutoSkills[i]) do
                        skill = self._playSkills[i][v.index]
                        if skill.castCount ~= 0 then
                            if (tempPriv[i] == 0 or 
                                tempPriv[i] == v.comboPriv or
                                (self._HP[i]/self._MaxHP[i]) <= 0.2 ) and
                                self:checkComboSkill(i, skill, 1) then
                                -- skillIndexes[i] = v.index
                                tempPriv[i] = v.comboPriv

                                if (skill.comboIndex == nil and  self.mana[i] - (skill.mana * self._manaPro[i]) >= 0)
                                    or (skill.comboIndex ~= nil and  self.mana[i] - (skill.comboMana * self._manaPro[i]) >= 0) then         
                                    tempSkillIndexes[i][#tempSkillIndexes[i] + 1] = v.index
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local sysSkill
    local caster 
    local draglenth, draglenth1, draglenth2, draglenth3
    for i = 1, 2 do 
        if i == 1 then
            _ran = random2
        else
            _ran = random
        end
        -- 下面全条件判断combo技能是否能释放
        repeat
            if #tempSkillIndexes[i] <= 0 then 
                break
            end
            skillIndexes[i] = tempSkillIndexes[i][_ran(#tempSkillIndexes[i])]
            skill = self._playSkills[i][skillIndexes[i]] 
            if not self:checkComboSkill(i, skill, 2) then
                break 
            end
            self._sameHeroFirstSkillState[i] = -2

            -- -- 点击释放技能不需要经过下面判断，直接输出
            -- if skill.kind == 2 then
            --     if self:checkPlayerSkill(skill, false) then
            --         self:castPlayerSkill(initSkillCaster(0, 0, i, skill.id), skill)
            --     end
            --     break
            -- end

            sysSkill = tab.playerSkillEffect[skill.id]
            caster = self:filterAutoCastSkillTarget(sysSkill, skill, i, _ran)
            if caster ~= nil then
                self:castAutoSkill(caster, skill, skillIndexes[i])
            end
            -- caster = initSkillCaster(0, 0, i, skill.id, skill.castCount)
            -- targets = self["getSkillTarget".. sysSkill["iff" .. self._autoSkillAttrClass]](self, caster)

            -- if #targets > 1 and sysSkill["privspec" .. self._autoSkillAttrClass] ~= nil then 
            --     tempTargets = self:countCharacters(caster, targets, sysSkill["privevalid" .. self._autoSkillAttrClass], sysSkill["privspec" .. self._autoSkillAttrClass], 1)
            --     -- 当无筛选目标的时候，需要随机一个目标
            --     if #tempTargets <= 0 then 
            --         table.insert(tempTargets, targets[_ran(#targets)])
            --     end

            --     if #tempTargets >= 1 then
            --         targets = tempTargets
            --     end
            -- end
            -- -- 优先方阵大小
            -- if #targets > 1 and sysSkill["privgroup" .. self._autoSkillAttrClass] ~= nil then
            --     local e, b  
            --     if sysSkill["privgroup" .. self._autoSkillAttrClass] == 2 then 
            --         b, e=  1, #ORDER_VOLUME
            --     else
            --         e, b =  1, #ORDER_VOLUME
            --     end
            --     for h = b, e do 
            --         tempTargets = self:getAITeamsByVolume(targets, ORDER_VOLUME[h])
            --         if #tempTargets > 0 then 
            --             targets = tempTargets
            --             break
            --         end
            --     end
            -- end
            -- -- 兵种优先级
            -- if #targets > 1 and sysSkill["privcata" .. self._autoSkillAttrClass] ~= nil then
            --     for k,d in pairs(sysSkill["privcata" .. self._autoSkillAttrClass]) do
            --         tempTargets = self:getAITeamsByClass(targets, d)
            --         if #tempTargets > 0 then 
            --             targets = tempTargets
            --             break
            --         end
            --     end
            -- end
            -- -- 血量筛选
            -- if #targets > 1 and sysSkill["privhp" .. self._autoSkillAttrClass] ~= nil then
            --     tempTargets = self:getAITeamsByHp(targets, sysSkill["privhp" .. self._autoSkillAttrClass])
            --     if #tempTargets > 0 then 
            --         targets = tempTargets
            --     end
            -- end
            -- tempTeam1 = nil
            -- tempTeam2 = nil

            -- if #targets > 0 then
            --     tempTeam1 = targets[_ran(#targets)]
            --     caster.x = tempTeam1.x
            --     caster.y = tempTeam1.y
            --     caster.target = tempTeam1
            --     tempTeam2 = self:getNearbySoldierWithTeams(caster, targets, sysSkill["privhp" .. self._autoSkillAttrClass], true)
            --     if tempTeam2 ~= nil then
            --         local tarop = sqrt(pow((tempTeam2.x - tempTeam1.x),2) + pow((tempTeam2.y - tempTeam1.y),2))
            --         if sysSkill["tarop" .. self._autoSkillAttrClass] ~= nil and sysSkill["tarop" .. self._autoSkillAttrClass] <= tarop then 
            --             caster.x = (4/7 * tempTeam1.x) + (3/7 * tempTeam2.x)
            --             caster.y = (4/7 * tempTeam1.y) + (3/7 * tempTeam2.y)
            --         end
            --     end
            --     -- caster.target = tempTeam1
            --     self:castAutoSkill(caster, skill, skillIndexes[i])
            -- end
        until  true
    end
end



function BattleSkillLogic:filterAutoCastSkillTarget(sysSkill, skill, camp, _ran)
    local caster = initSkillCaster(0, 0, camp, skill.id, skill.castCount)
    local tempTargets
    local allTargets
    local tempTeam1
    local tempTeam2
    local targets = self["getSkillTarget".. sysSkill["iff" .. self._autoSkillAttrClass]](self, caster, sysSkill["hitbuilding"] ~= nil)

    if #targets > 1 and sysSkill["privspec" .. self._autoSkillAttrClass] ~= nil then 
        tempTargets = self:countCharacters(caster, targets, sysSkill["privevalid" .. self._autoSkillAttrClass], sysSkill["privspec" .. self._autoSkillAttrClass], 1)
        -- 当无筛选目标的时候，需要随机一个目标
        if #tempTargets <= 0 then 
            table.insert(tempTargets, targets[_ran(#targets)])
        end

        if #tempTargets >= 1 then
            targets = tempTargets
        end
    end

    -- 兵种优先级
    if #targets > 1 and sysSkill["avoidSummon" .. self._autoSkillAttrClass] ~= nil then
        -- 配表描述是：是否回避召唤物 所以用not
        tempTargets = self:getAITeamsBySummon(targets, not sysSkill["avoidSummon" .. self._autoSkillAttrClass])
        if #tempTargets > 0 then 
            targets = tempTargets
        end
    end

    -- 优先方阵大小
    if #targets > 1 and sysSkill["privgroup" .. self._autoSkillAttrClass] ~= nil then
        local e, b  
        if sysSkill["privgroup" .. self._autoSkillAttrClass] == 2 then 
            b, e=  1, #ORDER_VOLUME
        else
            e, b =  1, #ORDER_VOLUME
        end
        for h = b, e do 
            tempTargets = self:getAITeamsByVolume(targets, ORDER_VOLUME[h])
            if #tempTargets > 0 then 
                targets = tempTargets
                break
            end
        end
    end
    -- 兵种优先级
    if #targets > 1 and sysSkill["privcata" .. self._autoSkillAttrClass] ~= nil then
        for k,d in pairs(sysSkill["privcata" .. self._autoSkillAttrClass]) do
            tempTargets = self:getAITeamsByClass(targets, d)
            if #tempTargets > 0 then 
                targets = tempTargets
                break
            end
        end
    end
    -- 血量筛选
    if #targets > 1 and sysSkill["privhp" .. self._autoSkillAttrClass] ~= nil then
        tempTargets = self:getAITeamsByHp(targets, sysSkill["privhp" .. self._autoSkillAttrClass])
        if #tempTargets > 0 then 
            targets = tempTargets
        end
    end
    tempTeam1 = nil
    tempTeam2 = nil

    if #targets > 0 then
        tempTeam1 = targets[_ran(#targets)]
        caster.x = tempTeam1.x
        caster.y = tempTeam1.y
        caster.target = tempTeam1
        tempTeam2 = self:getNearbySoldierWithTeams(caster, targets, sysSkill["privhp" .. self._autoSkillAttrClass], true)
        if tempTeam2 ~= nil then
            local tarop = sqrt(pow((tempTeam2.x - tempTeam1.x),2) + pow((tempTeam2.y - tempTeam1.y),2))
            if sysSkill["tarop" .. self._autoSkillAttrClass] ~= nil and sysSkill["tarop" .. self._autoSkillAttrClass] <= tarop then 
                caster.x = (4/7 * tempTeam1.x) + (3/7 * tempTeam2.x)
                caster.y = (4/7 * tempTeam1.y) + (3/7 * tempTeam2.y)
            end
        end
        return caster
    end
    return nil
end

-- 强制自动释放技能, 用一次就删除
function BattleSkillLogic:handleForceAutoCastSkill()
    local tick = self.battleTime
    local skillData
    for i = 1, 2 do
        for k = 1, #self._playForceAutoSkills[i] do
            skillData = self._playForceAutoSkills[i][k]
            if skillData then
                if tick >= skillData.castTick then
                    local caster = initSkillCaster(0, 0, i, skillData.id, skillData.castCount)
                    local _x, _y = self:getAllTeamCenterPoint()
                    if i == 1 then
                        _x = _x - 200
                    else
                        _x = _x + 200
                    end
                    caster.x = _x
                    caster.y = _y
                    caster.castType = ECastType.QUICK
                    self:castPlayerSkill(caster, skillData, {x = _x, y = _y}, nil, true)
                    self._playForceAutoSkills[i][k] = false
                end
            end
        end
    end
end

-- 器械放技能
function BattleSkillLogic:handleWeaponCastSkill()
    local tick = self.battleTime
    local skillData
    local sysSkill
    for i = 1, 2 do
        for k = 1, #self._playWeaponSkills[i] do
            skillData = self._playWeaponSkills[i][k]
            if skillData then
                if tick >= skillData.castTick then
                    skillData.castTick = tick + skillData.maxCD * 0.001
                    sysSkill = tab.playerSkillEffect[skillData.id]
                    local caster = self:filterAutoCastSkillTarget(sysSkill, skillData, i, random)
                    if caster ~= nil then 
                        caster.castType = ECastType.QUICK
                        caster.weaponSkillIndex = skillData.weaponSkillIndex
                        -- print("weapon skill", tick, skillData.id, caster.x, caster.y)
                        self:castPlayerSkill(caster, skillData, nil, nil, true)
                    end
                end
            end
        end
    end
end

--根据条件判断触发的技能
function BattleSkillLogic:checkCastPlayerConditionSkill(nType, inCamp, parm)
    if nType == 1 then
        --暂时只支持萨丽尔元素
        local skills = self._playConditionSkills[inCamp]
        for key, var in ipairs(skills) do
            if var and var.mgtrigerproduct then
                for _key, _var in ipairs(var.mgtrigerproduct) do
                    if _var and _var[1] == parm[1] and _var[2] == parm[2] and _var[3] == parm[3] then
                        delayCall(2, self, function()
                            --开始删除子物体
                            for i = #RecordReleaseSkill[inCamp + 2] , 1, -1  do
                                if i <= 3 then
                                    self:setDieTotem(RecordReleaseSkill[inCamp + 2][i], nil, 1)
                                    table.remove(RecordReleaseSkill[inCamp + 2], i)
                                end

                            end
                            self:castPlayConditionSkills(inCamp, key)
                        end
                        )
                        return true
                    end 
                end
            end
        end
    end
    return false
end

--条件触发的技能
function BattleSkillLogic:castPlayConditionSkills(inCamp, inSkillIndex)
    local skill = self._playConditionSkills[inCamp][inSkillIndex]
    if skill then
--        print("castPlayConditionSkills " .. skill.id)
        local sysSkill = tab.playerSkillEffect[skill.id]
        local _ran = nil
        if inCamp == 1 then
            _ran = random2
        else
            _ran = random
        end
        local caster = self:filterAutoCastSkillTarget(sysSkill, skill, inCamp, _ran)
        if caster then
            local option = skill.option
            if caster.target == nil or caster.target.state == ETeamStateDIE then 
                local targets = self["getSkillTarget".. sysSkill["iff" .. self._autoSkillAttrClass]](self, caster)
                local tempTeam = self:getNearbySoldierWithTeams(caster, targets, nil, true)
                caster.target = tempTeam  
            end
            if caster.target == nil or caster.target.state == ETeamStateDIE then 
                self:stopPlayerSkill(caster, skill)
                return
            end
            if caster.isFirst == nil then 
                caster.isFirst = true
            end
            -- 首次执行时用偏移坐标
            if not caster.isFirst then 
                caster.x = caster.target.x
                caster.y = caster.target.y
            end
            caster.isFirst = false
            -- 只有高级ai时需要做
            if self._autoSkillAttrClass == "X" then
                -- 【战斗】战斗AI判定位置加振幅 若释放法术的范围＜60，则目标点选择位置+5，用以避免打到只剩两个人这样
                local sysSkill = tab.playerSkillEffect[skill.id]
                local rangetype1 = sysSkill["rangetype1"]
                local range1 = sysSkill["range1"]
                if option == 1 and rangetype1 == 1 and range1 ~= nil and range1 <= 65 then
                    if range1 < 60 then
                        caster.y = caster.y + 20
                    else
                        caster.y = caster.y + 5
                    end
                end
            end
            --条件技能和英雄技能不一样，因此不能存放在技能列表中，不然可能导致复盘和战斗数据不一致
            self:castPlayerSkill(caster, skill, nil, nil, true) 
        end
    end
end


--援助的时候释放的技能
function BattleSkillLogic:quickCastPlayerSpecialSkill(inCamp, inSkillIndex, beginPoint, endPoint)
    local skill = self._playSpecialSkills[inCamp][inSkillIndex]
    local sysSkill = tab.playerSkillEffect[skill.id]
    local _ran = nil
    if inCamp == 1 then
        _ran = random2
    else
        _ran = random
    end
--    local caster = initSkillCaster(0, 0, inCamp, skill.id, skill.castCount)
    local caster = self:filterAutoCastSkillTarget(sysSkill, skill, inCamp, _ran)
    if caster == nil then
        caster = initSkillCaster(0, 0, inCamp, skill.id, skill.castCount)
        caster.x = beginPoint.x
        caster.y = beginPoint.y
        caster.castType = ECastType.QUICK
        self:castPlayerSkill(caster, skill, endPoint, nil, true)  
        return
    end
    local option = skill.option
    if caster.target == nil or caster.target.state == ETeamStateDIE then 
        local targets = self["getSkillTarget".. sysSkill["iff" .. self._autoSkillAttrClass]](self, caster)
        local tempTeam = self:getNearbySoldierWithTeams(caster, targets, nil, true)
        caster.target = tempTeam  
    end
    if caster.target == nil or caster.target.state == ETeamStateDIE then 
        self:stopPlayerSkill(caster, skill)
        return
    end
    if caster.isFirst == nil then 
        caster.isFirst = true
    end
    -- 首次执行时用偏移坐标
    if not caster.isFirst then 
        caster.x = caster.target.x
        caster.y = caster.target.y
    end
    caster.isFirst = false
    -- 只有高级ai时需要做
    if self._autoSkillAttrClass == "X" then
        -- 【战斗】战斗AI判定位置加振幅 若释放法术的范围＜60，则目标点选择位置+5，用以避免打到只剩两个人这样
        local sysSkill = tab.playerSkillEffect[skill.id]
        local rangetype1 = sysSkill["rangetype1"]
        local range1 = sysSkill["range1"]
        if option == 1 and rangetype1 == 1 and range1 ~= nil and range1 <= 65 then
            if range1 < 60 then
                caster.y = caster.y + 20
            else
                caster.y = caster.y + 5
            end
        end
    end
    --援助技能和英雄技能不一样，因此不能存放在技能列表中，不然可能导致复盘和战斗数据不一致
    self:castPlayerSkill(caster, skill, nil, nil, true) 
end

--[[
--! @function quickCastPlayerSkill
--! @desc 快速释放技能，忽略一切条件
--! @param inCamp int 阵营
--! @param inSkillIndex int 技能下标
--! @param beginPoint 开始坐标点
--! @param endPoint 开始坐标点
--! @return 
--]]
function BattleSkillLogic:quickCastPlayerSkill(inCamp, inSkillIndex, beginPoint, endPoint)
    local skill = self._playSkills[inCamp][inSkillIndex]
    local caster = initSkillCaster(0, 0, inCamp, skill.id, skill.castCount)
    caster.x = beginPoint.x
    caster.y = beginPoint.y
    caster.castType = ECastType.QUICK
    self:castPlayerSkill(caster, skill, endPoint)
end
local posIndex = {4, 8, 12, 16, 3, 7, 11, 15, 2, 6, 10, 14, 1, 5, 9, 13}
local posIndexEx = {4, 8, 12, 3, 7, 11, 2, 6, 10, 1, 5, 9, 16, 15, 14, 13}
function BattleSkillLogic:quickCastPlayerOpenSkill(inCamp, inSkillIndex, beginPoint, endPoint)
    if self._playOpenSkills == nil then return end
    local skill = self._playOpenSkills[inCamp][inSkillIndex]
    local caster = initSkillCaster(0, 0, inCamp, skill.id, skill.castCount)
    caster.x = beginPoint.x
    caster.y = beginPoint.y
    caster.castType = ECastType.QUICK
    local sysSkill = tab.playerSkillEffect[skill.id]
    local formationFirst = sysSkill["formationFirst"]
    local posIdx = posIndex
    -- if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_GodWar then
    --     posIdx = posIndexEx
    -- end
    if sysSkill["summon1"] or sysSkill["summon2"] then
        -- 有召唤物 找个有空的地方
        local found = false
        local index = 1
        if formationFirst then
            local row = 1
            local checkIdx = {1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15}
            for i = 1, 12 do
                index = checkIdx[i]
                if not self._initTeamPos[inCamp][index] then
                    local region = {{1, 4}, {5, 8}, {9, 12}, {13, 16}}
                    for k, v in ipairs(region) do
                        if index >= v[1] and index < v[2] then
                            for j = index + 1, v[2] do
                                if self._initTeamPos[inCamp][j] then
                                    self._initTeamPos[inCamp][index] = true
                                    caster.x, caster.y = BC.getFormationScenePos(index, inCamp)
                                    if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_BOSS_SjLong then
                                        caster.x = caster.x + 100
                                    elseif self._battleInfo.mode == BattleUtils.BATTLE_TYPE_BOSS_XnLong then
                                        caster.x = caster.x
                                    end
                                    found = true
                                    break
                                end
                            end
                        end
                        if found then
                            break
                        end
                    end
                end

                if found then
                    break
                end
            end
        end

        if not found then
            for i = 1, 16 do
                index = posIdx[i]
                if self._initTeamPos[inCamp][index] == nil then
                    self._initTeamPos[inCamp][index] = true
                    caster.x, caster.y = BC.getFormationScenePos(index, inCamp)
                    if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_BOSS_SjLong then
                        caster.x = caster.x + 100
                    elseif self._battleInfo.mode == BattleUtils.BATTLE_TYPE_BOSS_XnLong then
                        caster.x = caster.x
                    end
                    break
                end
            end
        end
    end
    self:castPlayerSkill(caster, skill, endPoint, 0, true)
end


--[[
--! @function castAutoSkill
--! @desc 释放自动技能
--! @param caster object 己方
--! @param skill object 英雄技能
--! @param index int index
--]]
function BattleSkillLogic:castAutoSkill(caster, skill, index)
    local option = skill.option

    if caster.target == nil
        or caster.target.state == ETeamStateDIE then 
        local sysSkill = tab.playerSkillEffect[skill.id]
        -- if sysSkill.iff == 16 then 
        --     targets = self:getSkillTarget101(caster)
        -- else
        --     targets = self:getSkillTarget100(caster)
        -- end
        local targets = self["getSkillTarget".. sysSkill["iff" .. self._autoSkillAttrClass]](self, caster)
        local tempTeam = self:getNearbySoldierWithTeams(caster, targets, nil, true)
        caster.target = tempTeam  
    end
    if caster.target == nil or 
        caster.target.state == ETeamStateDIE then 
        self:stopPlayerSkill(caster, skill)
        return
    end
    if caster.isFirst == nil then 
        caster.isFirst = true
    end
    -- 首次执行时用偏移坐标
    if not caster.isFirst then 
        caster.x = caster.target.x
        caster.y = caster.target.y
    end

    caster.isFirst = false
    -- 只有高级ai时需要做
    if self._autoSkillAttrClass == "X" then
        -- 【战斗】战斗AI判定位置加振幅 若释放法术的范围＜60，则目标点选择位置+5，用以避免打到只剩两个人这样
        local sysSkill = tab.playerSkillEffect[skill.id]
        local rangetype1 = sysSkill["rangetype1"]
        local range1 = sysSkill["range1"]
        if option == 1 and rangetype1 == 1 and range1 ~= nil and range1 <= 65 then
            if range1 < 60 then
                caster.y = caster.y + 20
            else
                caster.y = caster.y + 5
            end
        end
    end
    if not BATTLE_PROC and not BC.jump then
        objLayer:flashSkillAreaEx(self:getSkillRadius(caster.camp, index), caster.x, caster.y, caster.camp)
    end
    if caster.camp == 1 then
        if self:checkPlayerSkill(skill, caster.camp, true) then
            self._nextFrameCastSkill[#self._nextFrameCastSkill + 1] = {index, caster.x, caster.y}
        end
    else
        if self:checkPlayerSkill(skill, caster.camp) then
            self._skillIndexes[caster.camp] = index
            self:castPlayerSkill(caster, skill)
        end
    end
end


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
--[[
--! @function useTotem
--! @desc 释放图腾
--! @param inCaster object 临时筛选条件对象
--! @param inSysSkill object 系统机能
--! @param inLevel int 机能等级
--! @param inPoint 操作点
--! @param inType int 操作类型（点或者人)
--]]
function BattleSkillLogic:useTotem(inCaster, inSysSkill, inSkill, inPoint, inType, inRangePro, inForceDoubleEffect, yunBuff)
    if inSysSkill["objectid"] then
        local totemD = tab.object[inSysSkill["objectid"]]
        if inType == 2 then
            self:addTotemToSoldier(totemD, inSkill.level, inCaster, inPoint, inRangePro, inForceDoubleEffect, yunBuff, inSkill.index, inSkill)
        else
            self:addTotemToPos(totemD, inSkill.level, inCaster, inPoint.x, inPoint.y, inRangePro, inForceDoubleEffect, yunBuff, inSkill.index, inSkill)
        end
    end

    if inSysSkill["objectid2"] then
        local totemD = tab.object[inSysSkill["objectid2"]]
        if inType == 2 then
            self:addTotemToSoldier(totemD, inSkill.level, inCaster, inPoint, inRangePro, inForceDoubleEffect, yunBuff, inSkill.index, inSkill)
        else
            self:addTotemToPos(totemD, inSkill.level, inCaster, inPoint.x, inPoint.y, inRangePro, inForceDoubleEffect, yunBuff, inSkill.index, inSkill)
        end
    end
end


--[[
--! @function countCharacters
--! @desc 特殊条件判断（兵种有效性筛选）
--! @param inCaster object 临时筛选条件对象
--! @param inTargets table 操作对象
--! @param inValid int 0 该技能对单位无效, 1 该技能对单位有效
--! @param inCondition Valid对象
--! @return table 新集合
--]]
function BattleSkillLogic:countCharacters(inCaster, inTargets, inValid, inCondition, inIsAuto)
    if inValid == nil or 
         inTargets == nil or 
         #inTargets <= 0 then 
        return inTargets
    end
    local tempTargets = {}
    local v
    local flag
    local operateFun = "countCharacters"
    if inIsAuto == 1 then 
        operateFun = operateFun .. "_team"
    end
    for i=1,#inTargets do
        v = inTargets[i]
        -- inCaster.target = v
        flag = 0
        for k=1,#inCondition do
            -- valid = 0 该技能对单位无效
            -- valid = 1 该技能对单位有效
            -- print("inCondition==================", inCondition[k][1])
            if inValid == 1 and BC[operateFun..inCondition[k][1]] and 
                BC[operateFun..inCondition[k][1]](self, inCaster, v, inCondition[k][2]) then 
                flag = 1
            elseif inValid == 0  then 
                if BC[operateFun..inCondition[k][1]] and BC[operateFun..inCondition[k][1]](self, inCaster, v, inCondition[k][2]) then 
                    flag = 2
                elseif flag ~= 2 then 
                    flag = 1
                end
            end
        end
        if flag == 1 then 
           table.insert(tempTargets, v)
        end 
    end
    -- inCaster.target = nil
    return tempTargets
end


--[[
--! @function getAITeamsBySummon
--! @desc 根据根据召唤物标识进行筛选
--! @param caster object 临时筛选条件对象
--! @param targets table 筛选列表
--! @param inClass int 筛选兵种
--! @return table 筛选结果
--]]
function BattleSkillLogic:getAITeamsBySummon(targets, inSummon)
    local tempTargets = {}
    for i,v in pairs(targets) do
        if v.state ~= ETeamStateDIE and 
            ((inSummon and v.summon) or (inSummon == false and not v.summon)) then
            table.insert(tempTargets, v)
        end
    end
    return tempTargets
end

--[[
--! @function getAITeamsByClass
--! @desc 根据兵种标签筛选数据
--! @param caster object 临时筛选条件对象
--! @param targets table 筛选列表
--! @param inClass int 筛选兵种
--! @return table 筛选结果
--]]
function BattleSkillLogic:getAITeamsByClass(targets, inClass)
    local tempTargets = {}
    for i,v in pairs(targets) do
        if v.state ~= ETeamStateDIE and 
            v.classLabel == inClass then
            table.insert(tempTargets, v)
        end
    end
    return tempTargets
end

--[[
--! @function getAITeamsByVolume
--! @desc 根据兵团大小筛选数据
--! @param caster object 临时筛选条件对象
--! @param targets table 筛选列表
--! @param inVolume int 筛选大小
--! @return table 筛选结果
--]]
function BattleSkillLogic:getAITeamsByVolume(targets, inVolume)
    local tempTargets = {}
    for i,v in pairs(targets) do
        if v.state ~= ETeamStateDIE and 
            v.volume == inVolume then
            table.insert(tempTargets, v)
        end
    end
    return tempTargets
end

function BattleSkillLogic:getAITeamsByHp(targets, inCase)
    local tempTargets = {}
    local pro
    local tempTarget = targets[1]
    local berPro
    local bIsCass = 1
    if inCase == 2 then
        bIsCass = -1
    end
    if tempTarget ~= nil then
        berPro = tempTarget.curHP / ((tempTarget.maxHP / tempTarget.number) * #tempTarget.aliveSoldier) * 100 * bIsCass
        for i,v in pairs(targets) do
            pro = v.curHP / ((v.maxHP / v.number) * #v.aliveSoldier) * 100 * bIsCass
            if v.state ~= ETeamStateDIE and pro > berPro then
                berPro = pro
                tempTarget = v
            end
        end
        table.insert(tempTargets, tempTarget)
    end
    return tempTargets
end

--[[
--! @function getSkillTarget101
--! @desc 敌方方阵
--! @param caster object 筛选条件对象
--! @return table 筛选结果
--]]
function BattleSkillLogic:getSkillTarget101(caster, hitbuilding)
    if hitbuilding then
        -- 先筛建筑
        local teams = self.targetCache[caster.camp][1]

        local tempTargets = {}
        local pro 
        local __team
        for i,v in pairs(teams) do
            __team = v.team
            if __team.state ~= ETeamStateDIE then
                table.insert(tempTargets, __team)
            end
        end
        if #tempTargets > 0 then
            return tempTargets
        end
    end
    local teams = self.targetCache[caster.camp][5]

    local tempTargets = {}
    local pro 
    for i,v in pairs(teams) do
        if v.state ~= ETeamStateDIE then
            table.insert(tempTargets, v)
        end
    end
    return tempTargets

end

--[[
--! @function getSkillTarget100
--! @desc 己方方阵
--! @param caster object 筛选条件对象
--! @return table 筛选结果
--]]
function BattleSkillLogic:getSkillTarget100(caster, hitbuilding)
    if hitbuilding then
        -- 先筛建筑
        local teams = self.targetCache[3 - caster.camp][1]

        local tempTargets = {}
        local pro 
        local __team
        for i,v in pairs(teams) do
            __team = v.team
            if __team.state ~= ETeamStateDIE then
                table.insert(tempTargets, __team)
            end
        end
        if #tempTargets > 0 then
            return tempTargets
        end
    end
    local teams = self.targetCache[caster.camp][10]

    local tempTargets = {}
    local pro 
    for i,v in pairs(teams) do
        if v.state ~= ETeamStateDIE then
            table.insert(tempTargets, v)
        end
    end
    return tempTargets
end


--[[
--! @function getSkillTarget102
--! @desc 己方死亡方阵
--! @param caster object 筛选条件对象
--! @return table 筛选结果
--]]
function BattleSkillLogic:getSkillTarget102(caster)
    local teams = self.targetCache[caster.camp][10]

    local tempTargets = {}
    local pro 
    for i,v in pairs(teams) do
        if v.state == ETeamStateDIE then
            table.insert(tempTargets, v)
        end
    end
    return tempTargets
end


function BattleSkillLogic:getSkillTarget10001(camp, inTeamId)
    local teams = self.targetCache[camp][10]
    local pro 
    for i,v in pairs(teams) do
        if v.state ~= ETeamStateDIE and 
            v.D.id == inTeamId then
            return true
        end
    end
    return false
end



-- 己方士兵死亡
function BattleSkillLogic:onSoldierDie1()

end

-- 敌方士兵死亡
function BattleSkillLogic:onSoldierDie2()

end

-- 己方方阵死亡
function BattleSkillLogic:onTeamDie1()
    self:excludeSkillWithTarget(1)
end

-- 敌方方阵死亡
function BattleSkillLogic:onTeamDie2()
    self:excludeSkillWithTarget(2)
end

-- 己方方阵复活
function BattleSkillLogic:onTeamRevive1(teamId)
    self:addRemoveSkillTarget(1, teamId)
end

-- 敌方方阵复活
function BattleSkillLogic:onTeamRevive2(teamId)
    self:addRemoveSkillTarget(2, teamId)
end

--[[
--! @function excludeSkillWithTarget
--! @desc 若设置兵团死亡或者没有上阵，则禁止使用技能
--! @param caster object 筛选条件对象
--! @return table 筛选结果
--]]
function BattleSkillLogic:excludeSkillWithTarget(camp)
    for i= #self._playAutoSkills[camp], 1, -1 do
        local v = self._playAutoSkills[camp][i]
        
        local skill = self._playSkills[camp][v.index]
        if skill["banlist" .. self._autoSkillAttrClass] ~= nil then
            local flag = -1
            for k,v in pairs(skill["banlist" .. self._autoSkillAttrClass]) do
                if self:getSkillTarget10001(camp, v) == true then
                    flag = i
                    break
                end
            end
            if flag == -1 then
                table.insert(self._playerRemoveSkill[camp], v) 
                table.remove(self._playAutoSkills[camp], i)
            end
        end
    end
end

function BattleSkillLogic:addRemoveSkillTarget(camp, teamId)
    for i= #self._playerRemoveSkill[camp], 1, -1 do
        local var = self._playerRemoveSkill[camp][i]
        if var then
            local skill = self._playSkills[camp][var.index]
            if skill and skill["banlist" .. self._autoSkillAttrClass] ~= nil then
                local flag = -1
                for k,v in pairs(skill["banlist" .. self._autoSkillAttrClass]) do
                    if teamId == v then
                        flag = i
                        break
                    end
                end
                if flag ~= -1 then
                    table.insert(self._playAutoSkills[camp], var) 
                    table.remove(self._playerRemoveSkill[camp], i)

                    --添加之后必须更具权重重新排序
                    local sortFunc = function(a, b) 
                        if a.comboPriv > b.comboPriv then 
                            return true
                        end
                    end
                    table.sort(self._playAutoSkills[camp], sortFunc)
                end
            end
        end
    end
    
end

function BattleSkillLogic:getSkillDesc(index)
    local skill = self._playSkills[1][index]
    return BattleUtils.getDescription(BattleUtils.kIconTypeSkill, skill.id, self._heros[1].attrValues, index, nil, self._battleInfo.mode,-1), lang(tab.playerSkillEffect[skill.id]["name"])
end

-- 召唤物死亡
function BattleSkillLogic:onSummonDie(camp)
    local recMana = self.summonDie_RecMana[camp]
    local decCd = self.summonDie_DecCd[camp]
    if recMana > 0 then
        self._heroAttrFunc[camp](self, recMana + 0.00000001)
    end
    if decCd > 0 then
        local tick = self.battleTime
        local skill
        local skills = self._playSkills[camp]
        for i = 1, MAX_SKILL_COUNT do
            skill = skills[i]
            if skill then
                if skill.castTick > tick then
                    skill.castTick = skill.castTick - decCd
                    if skill.castTick < tick then
                        skill.castTick = tick
                    end
                end
            end
        end
    end
end

function BattleSkillLogic:dtor2()
    H_FAILED_INIT = nil
    H_FAILED_MIN = nil
    H_FAILED_MAX = nil
    H_FAILED_ADD_MIN = nil 
    H_FAILED_ADD_MAX = nil
    H_FAILED_DEC = nil
    H_FAILED_ADD_FIX = nil
    H_FAILED_ADD_RAN = nil
    abs = nil
    actionInv = nil
    atan = nil
    BattleSkillLogic = nil
    BC = nil
    BUFF_ID_YUN = nil
    cc = nil
    color_red = nil
    deg = nil
    ECamp = nil
    ECastType = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil
    EState = nil
    ETeamState = nil
    ETeamStateDIE = nil
    floor = nil
    GBHU = nil
    initPlayerBuff = nil
    initSoldierBuff = nil
    math = nil
    MAX_SKILL_COUNT = nil
    mcMgr = nil
    mgtip_mcname = nil
    next = nil
    objLayer = nil
    ORDER_VOLUME = nil
    os = nil
    pairs = nil
    pc = nil
    posIndex = nil
    pow = nil
    random = nil
    recManaInv = nil
    sqrt = nil
    tab = nil
    table = nil  
    tonumber = nil
    tostring = nil
    super = nil 
    AI_RUN_DELAY = nil
    delayCall = nil
    ceil = nil
    isOpenAutoBattleForCamp = nil
    format = nil
    floor = nil
    SRData = nil
    SRTab = nil
    BC_reverse = nil
    MAX_SCENE_WIDTH_PIXEL = nil
    posIndexEx = nil
    initSkillCaster = nil
end


return BattleSkillLogic
