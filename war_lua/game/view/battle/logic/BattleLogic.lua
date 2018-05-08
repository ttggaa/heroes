--[[
    Filename:    BattleLogic.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-30 12:00:22
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

local Battle_Delta = BC.Battle_Delta

local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType

local BattleLogic = class("BattleLogic")

-- 灵魂链接结算间隔
local DAMAGESHARE_TICK_INV = 0.2
-- 喊话间隔时间
local SAY_TICK_INV = 3
-- 喊话持续时间
local SAY_TICK_DURATION = 3

local objLayer = BC.objLayer

local SRData = BattleUtils.SRData

local BattleTeam = require("game.view.battle.object.BattleTeam")
local BattleSoldier = require("game.view.battle.object.BattleSoldier")
local BattleTotem = require("game.view.battle.object.BattleTotem")
local BattleHero = require("game.view.battle.object.BattleHero")
local BattleWeapon = require("game.view.battle.object.BattleWeapon")
local random = BC.ran

local EStateING = EState.ING

local BC_reverse = BC.reverse
local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL

function BattleLogic:ctor(control)
    objLayer = BC.objLayer
    BC.logic = self
    self._control = control
    self._updateList = {}

    self.teamSpeSkillCondition = {{}, {}}

    BattleTeam.initialize()
    BattleSoldier.initialize()
    BattleTotem.initialize()
end

local ranRow = 
{{1,2,3,4},{1,2,4,3},{1,3,2,4},{1,3,4,2},{1,4,2,3},{1,4,3,2},{2,1,3,4},{2,1,4,3},{2,3,1,4},{2,3,4,1},{2,4,1,3},{2,4,3,1},
{3,1,2,4},{3,1,4,2},{3,2,1,4},{3,2,4,1},{3,4,1,2},{3,4,2,1},{4,1,2,3},{4,1,3,2},{4,2,1,3},{4,2,3,1},{4,3,1,2},{4,3,2,1}}
local insert = table.insert
local remove = table.removebyvalue
function BattleLogic:initLogic(battleInfo, procBattle)
    -- 初始化Tick
    BC.tickInit()

    BC.resetGenID()
    self._error = false

    -- 战斗经过时间
    self.battleTime = 0
    -- 战斗经过总update
    self.battleFrameCount = 0

    self._battleInfo = battleInfo

    -- self._battleInfo.r2

    self.battleState = EState.READY

    -- 灵魂链接容器, 按照阵营分
    self._damageShareList = {{}, {}, {}}
    self._damageShareValue = {0, 0, 0}
    self._lastCheckDS = 0

    -- 方阵数量 我/敌
    self.teamCount = {0, 0} 

    -- 己方原始上阵方阵存货数量
    self.originalDieCount = 0

    -- 方阵死亡数量
    self._teamDieCount = {0, 0}

    -- 我方种族数量
    self.race1Count = {{}, {}}
    self.race2Count = {{}, {}}
    self.classCount = {{[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0}, {[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0}}

    -- 建立部队
    -- 方阵寻路用
    -- [阵营][行号]
    self._rowTeam = {{{}, {}, {}, {}, {}, {}, {}, {}}, {{}, {}, {}, {}, {}, {}, {}, {}}}

    -- 怪兽
    self._teams = {{}, {}}
    self._allTeams = {}
    -- 英雄
    self._heros = {nil, nil}
    self._weapons = {{}, {}}

    -- 首发阵容9人血量相关
    self._HP = {0, 0}
    self._MaxHP = {0, 0}

    -- 存活人数
    self._lastTeamCount = {0, 0}

    -- 召唤生物的血量
    self._summonHP = {0, 0}
    self._summonMaxHP = {0, 0}

    -- 正在重生的人数, 为了凤凰
    self._reviveCount = {0, 0}

    self:_countTeamClass()
    self._originalTeams = {}
        
    self:_sortTeams()
    self:_initLeftTeam()
    self:_initRightTeam()

    -- 计算技能动态CD
    self:_initTeamSkillDynamicCD()

    BC.initHero(self._heros)

    -- 每一帧都更新buff的方阵, 主要用于BOSS
    self._buffFrameUpdateList = {}
    
    -- 开启寻路筛选
    self._enableFindTargetBlind = false

    -- 场上召唤物数量
    self.summonCount = {0, 0}

    self:initLogicEx(procBattle)

    -- update顺序列表, 先手优势比较大
    self._updateIndex = 1
    self._updateList = {}
    local count1 = #self._teams[1]
    local count2 = #self._teams[2]
    local max = math.max(count1, count2)
    if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_Arena 
       or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_ServerArena then
        local r = 0
        for i = 1, max do
            r = random(2)
            if r == 1 then
                if i <= count2 then
                    self._updateList[#self._updateList + 1] = self._teams[2][i]
                end
                if i <= count1 then
                    self._updateList[#self._updateList + 1] = self._teams[1][i]
                end
            else
                if i <= count1 then
                    self._updateList[#self._updateList + 1] = self._teams[1][i]
                end
                if i <= count2 then
                    self._updateList[#self._updateList + 1] = self._teams[2][i]
                end
            end
        end
    else
        for i = 1, max do
            if i <= count1 then
                self._updateList[#self._updateList + 1] = self._teams[1][i]
            end
            if i <= count2 then
                self._updateList[#self._updateList + 1] = self._teams[2][i]
            end
        end
    end

    -- 优化buff
    self._buffUpdateIndex = 1

    -- 优化
    -- 行动值
    self.frameActionValue = BC.frameInv
    self._actionValue = 0

    -- 认输
    self._surrender = false

    -- 玩家伤害统计
    self._playerSkillCountData = {}

    self._playerDamage = {{}, {}}
    self._playerDamage1 = {{}, {}}
    self._playerHeal = {{}, {}}

    -- 选择方阵
    self._selectTeamList = {}

    -- 喊话
    self._lastSayTick = -SAY_TICK_INV * 0.5

    -- 击杀数量
    self.playerKillCount = 0

    -- 天使联盟 复活第一个死的兵团
    self.firstDie = {random(100) <= self._heros[1].revivePro, random(100) <= self._heros[2].revivePro}
end

function BattleLogic:replay()
    if BattleUtils.XBW_SKILL_DEBUG then self:clearTeamDebugLabel() end
    self._replay = true
    self._battleEnded = nil
    self:initLogic(self._battleInfo)
    self._control:enableBtns()
end

function BattleLogic:_initBattleSkill(list, index, callback, noEff, has)
    if index > #list then
        if has then
            ScheduleMgr:delayCall(750, self, function()
                callback()
            end)
        else
            callback()
        end
        return
    end
    local team = list[index]
    -- 阵营2 不显示特效
    local eff = noEff 
    if team.camp == 2 then
        eff = true
    end
    -- 成功释放
    local succ = team:initBattleSkill(eff)
    if succ and eff then
        ScheduleMgr:delayCall(100, self, function()
            self:_initBattleSkill(list, index + 1, callback, noEff, has or true)
        end)
    else
        self:_initBattleSkill(list, index + 1, callback, noEff, has)
    end

end

function BattleLogic:initBattleSkill(callback, noEff)
    if callback then
        local function __initSkill()
            -- 开场技能
            if self._battleInfo.isShare then
                self:initBattleHeroSkill_Share(function ()
                    self:_initBattleSkill(self._updateList, 1, callback, noEff, true)
                end)
            else
                self:initBattleHeroSkill(function ()
                    self:_initBattleSkill(self._updateList, 1, callback, noEff, true)
                end)
            end
        end
        if not BATTLE_PROC and self._battleInfo.startTalkId then
            ViewManager:getInstance():enableTalking(self._battleInfo.startTalkId, {}, __initSkill)
        else
            __initSkill()
        end
    else
        self:initBattleHeroSkill()
        -- 开场技能
        local has = false
        local count = #self._updateList
        local team
        for i = 1, count do
            team = self._updateList[i]
            if team:initBattleSkill() and team.camp == 1 then
                has = true
            end
        end
        return has
    end
end

function BattleLogic:initBattleHeroSkillBookPassiveSkill(camp, hide)
    local playSkillBookPassive = self._playSkillBookPassive[camp]
    if playSkillBookPassive and type(playSkillBookPassive) == "table" then
        local count = #playSkillBookPassive
        for i = 1, count do
            self._control:addSkillBookPassiveIcon(i, playSkillBookPassive[i][1], camp, i == count, hide)
        end
    end
end

-- 英雄开场技能, 宝物技能, 咱是只播放诅咒铠甲
function BattleLogic:initBattleHeroSkill(callback)
    local playOpenSkills1 = self._playOpenSkills[1]
    local playOpenSkills2 = self._playOpenSkills[2]
    if callback then
        if #playOpenSkills1 == 0 then
            if #playOpenSkills2 == 0 then
                self:initBattleHeroSkillBookPassiveSkill(1)
                self:initBattleHeroSkillBookPassiveSkill(2)
                callback()
            else
                -- 右方释放(无动画)
                local _x, _y = self:getRightTeamCenterPoint()
                local t1 = 800
                local t2 = 1000
                local t3 = 1000
                if not BC_reverse then
                    t1, t2, t3 = 0, 0, 0
                end
                for k = 1, #playOpenSkills2 do
                    ScheduleMgr:delayCall(t1 + t2 * (k - 1), self, function()
                        self:quickCastPlayerOpenSkill(2, k, {x = _x, y = _y})

                        local treasureD = playOpenSkills2[k].treasureD
                        local skillD = tab.playerSkillEffect[playOpenSkills2[k].id]
                        if treasureD["id"] == 30 or treasureD["id"] == 41 then
                            local buffD = tab.skillBuff[skillD["buffid1"]]
                            local lv = playOpenSkills2[k].level
                            self._control:addTreasureSkillIcon(treasureD["id"], treasureD["quality"], skillD, lv, 2, buffD["last1"][1] + buffD["last1"][2] * (lv - 1))
                        end
                        if BC_reverse and (treasureD["id"] == 30 or treasureD["id"] == 41) then
                            self._control:heroSkillAnim(2, lang(skillD["name"]), nil, self._heros[2].heroHeadName, 1, nil, treasureD)
                        end
                        if k == #playOpenSkills2 then
                            ScheduleMgr:delayCall(t3, self, function()
                                self:initBattleHeroSkillBookPassiveSkill(1)
                                self:initBattleHeroSkillBookPassiveSkill(2)
                                callback()
                            end)
                        end
                    end)
                end
            end
        else
            local _x, _y = self:getLeftTeamCenterPoint()
            for i = 1, #playOpenSkills1 do
                local skillD = tab.playerSkillEffect[playOpenSkills1[i].id]
                local treasureD = playOpenSkills1[i].treasureD
                if not BC_reverse and (treasureD["id"] == 30 or treasureD["id"] == 41) then
                    self._control:heroSkillAnim(1, lang(skillD["name"]), nil, self._heros[1].heroHeadName, 2, nil, treasureD)
                end
            end
            
            for i = 1, #playOpenSkills1 do
                local t1 = 800
                local t2 = 1000
                local t3 = 0
                local t4 = 0
                if BC_reverse then
                    t1, t2 = 0, 0
                    t3, t4 = 800, 1000
                end
                ScheduleMgr:delayCall(t1 + t2 * (i - 1), self, function()
                    self:quickCastPlayerOpenSkill(1, i, {x = _x, y = _y})
                    local skillD = tab.playerSkillEffect[playOpenSkills1[i].id]
                    local treasureD = playOpenSkills1[i].treasureD
                    if treasureD["id"] == 30 or treasureD["id"] == 41 then
                        local buffD = tab.skillBuff[skillD["buffid1"]]
                        local lv = playOpenSkills1[i].level
                        self._control:addTreasureSkillIcon(treasureD["id"], treasureD["quality"], skillD, lv, 1, buffD["last1"][1] + buffD["last1"][2] * (lv - 1))
                    end
                    -- 左方释放完成后, 右方释放(无动画)
                    if i == #playOpenSkills1 then
                        if #playOpenSkills2 == 0 then
                            self:initBattleHeroSkillBookPassiveSkill(1)
                            self:initBattleHeroSkillBookPassiveSkill(2)
                            callback()
                        else
                            local _x, _y = self:getRightTeamCenterPoint()
                            for k = 1, #playOpenSkills2 do
                                ScheduleMgr:delayCall(t3 + t4 * (k - 1), self, function()
                                    self:quickCastPlayerOpenSkill(2, k, {x = _x, y = _y})

                                    local treasureD = playOpenSkills2[k].treasureD
                                    local skillD = tab.playerSkillEffect[playOpenSkills2[k].id]
                                    if treasureD["id"] == 30 or treasureD["id"] == 41 then
                                        local buffD = tab.skillBuff[skillD["buffid1"]]
                                        local lv = playOpenSkills2[k].level
                                        self._control:addTreasureSkillIcon(treasureD["id"], treasureD["quality"], skillD, lv, 2, buffD["last1"][1] + buffD["last1"][2] * (lv - 1))
                                    end
                                    if BC_reverse and (treasureD["id"] == 30 or treasureD["id"] == 41) then
                                        self._control:heroSkillAnim(2, lang(skillD["name"]), nil, self._heros[2].heroHeadName, 1, nil, treasureD)
                                    end
                                    if k == #playOpenSkills2 then
                                        ScheduleMgr:delayCall(1000, self, function()
                                            self:initBattleHeroSkillBookPassiveSkill(1)
                                            self:initBattleHeroSkillBookPassiveSkill(2)
                                            callback()
                                        end)
                                    end
                                end)
                            end
                        end
                    end
                end)
            end 
        end
    else
        -- 只有逻辑 (无动画)
        local _x, _y = self:getLeftTeamCenterPoint()
        for i = 1, #playOpenSkills1 do
            self:quickCastPlayerOpenSkill(1, i, {x = _x, y = _y})
        end
        local _x, _y = self:getRightTeamCenterPoint()
        for i = 1, #playOpenSkills2 do
            self:quickCastPlayerOpenSkill(2, i, {x = _x, y = _y})
        end
    end
end

-- 战报分享专用英雄初始技能
function BattleLogic:initBattleHeroSkill_Share(callback)
    local playOpenSkills1 = self._playOpenSkills[1]
    local playOpenSkills2 = self._playOpenSkills[2]
    local delay = 0
    if #playOpenSkills1 > 0 then
        delay = 1200
        local _x, _y = self:getLeftTeamCenterPoint()
        for k = 1, #playOpenSkills1 do
            self:quickCastPlayerOpenSkill(1, k, {x = _x, y = _y})

            local treasureD = playOpenSkills1[k].treasureD
            if treasureD["id"] == 30 or treasureD["id"] == 41 then
                local skillD = tab.playerSkillEffect[playOpenSkills1[k].id]
                local buffD = tab.skillBuff[skillD["buffid1"]]
                local lv = playOpenSkills1[k].level
                self._control:addTreasureSkillIcon(treasureD["id"], treasureD["quality"], skillD, lv, 1, buffD["last1"][1] + buffD["last1"][2] * (lv - 1))
            end
        end
    end
    ScheduleMgr:delayCall(delay, self, function()
        local _x, _y = self:getRightTeamCenterPoint()
        for k = 1, #playOpenSkills2 do
            self:quickCastPlayerOpenSkill(2, k, {x = _x, y = _y})

            local treasureD = playOpenSkills2[k].treasureD
            if treasureD["id"] == 30 or treasureD["id"] == 41 then
                local skillD = tab.playerSkillEffect[playOpenSkills2[k].id]
                local buffD = tab.skillBuff[skillD["buffid1"]]
                local lv = playOpenSkills2[k].level
                self._control:addTreasureSkillIcon(treasureD["id"], treasureD["quality"], skillD, lv, 2, buffD["last1"][1] + buffD["last1"][2] * (lv - 1))
            end
        end
        ScheduleMgr:delayCall(1000, self, function()
            callback()
        end)
    end)
end
local genTeamID = BC.genTeamID
local getRowIndex = BC.getRowIndex
function BattleLogic:addTeam(team, row)
    local camp = team.camp
    self._teams[camp][#self._teams[camp] + 1] = team
    team.ID = genTeamID()
    self._allTeams[team.ID] = team
    if row then
        team.row = row
    else
        team.row = getRowIndex(team.y)
    end
    table.insert(self._rowTeam[camp][team.row], team)
    if not BATTLE_PROC and not team.noHUD then
        local _type = 1
        if team.hudSp then
            _type = 2
        end
        objLayer:addTeamHUD(team, self.battleState == EStateING, _type)
    end

    if not team.building then
        self._lastTeamCount[camp] = self._lastTeamCount[camp] + 1
    end
end

function BattleLogic:addSpeSkillCondition(camp, teamId, condition, value)
    local teamSpeSkillCondition = self.teamSpeSkillCondition[camp]
    if not teamSpeSkillCondition[condition] then
        teamSpeSkillCondition[condition] = {}
    end
    value = value or 0
    table.insert(teamSpeSkillCondition[condition], {teamId, value})
end

function BattleLogic:isSpeSkillConditionSet(camp, condition)
    local teamSpeSkillCondition = self.teamSpeSkillCondition[camp][condition]
    local result = teamSpeSkillCondition and #teamSpeSkillCondition > 0
    local value = 0
    if result then
        for k, v in ipairs(teamSpeSkillCondition) do
            if v[2] > value then
                value = v[2]
            end
        end
    end
    return result, value
end

function BattleLogic:addToUpdateList(team)
    insert(self._updateList, team)
end

function BattleLogic:removeFromUpdateList(team)
    -- remove(self._updateList, team)
    -- remove(self._teams[team.camp], team) 
end

function BattleLogic:_raceCountAdd(camp, race1, race2)
    if self.race1Count[camp][race1] == nil then
        self.race1Count[camp][race1] = 1
    else
        self.race1Count[camp][race1] = self.race1Count[camp][race1] + 1
    end
    if self.race2Count[camp][race2] == nil then
        self.race2Count[camp][race2] = 1
    else
        self.race2Count[camp][race2] = self.race2Count[camp][race2] + 1
    end
end

function BattleLogic:_raceCountDec(camp, race1, race2)
    self.race1Count[camp][race1] = self.race1Count[camp][race1] - 1
    self.race2Count[camp][race2] = self.race2Count[camp][race2] - 1
end

-- 统计兵种
-- MoveTypeCount = {{0, 0}, {0, 0}}
-- ClassCount = {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}
-- Race1Count = {{0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0}}
-- BC.XCount = {{0, 0, 0}, {0, 0, 0}}
function BattleLogic:_countTeamClass()
    local MoveTypeCount = BC.MoveTypeCount
    local ClassCount = BC.ClassCount
    local Race1Count = BC.Race1Count
    local XCount = BC.XCount
    local TeamMap = BC.TeamMap
    local NpcMap = BC.NpcMap
    local class, moveType, race1, x

    -- 我方
    local teamD
    local teams = self._battleInfo.playerInfo.team
    if teams then
        for i = 1, #teams do
            teamD = tab.team[teams[i].id]
            class = teamD["class"]
            moveType = teamD["movetype"]
            race1 = teamD["race"][1] - 100
            x = teamD["x"]
            ClassCount[1][class] = ClassCount[1][class] + 1
            MoveTypeCount[1][moveType] = MoveTypeCount[1][moveType] + 1
            Race1Count[1][race1] = Race1Count[1][race1] + 1
            if type(x) == "number" then
                XCount[1][x] = XCount[1][x] + 1
            elseif type(x) == "table" then
                for i=1, #x do
                    XCount[1][x[i]] = XCount[1][x[i]] + 1
                end
            end
            TeamMap[1][teamD["id"]] = true
        end
    end
    local npcD
    local npcs = self._battleInfo.playerInfo.npc
    if npcs then
        for i = 1, #npcs do
            npcD = tab.npc[npcs[i][1]]
            class = npcD["class"]
            moveType = npcD["mot"]
            race1 = npcD["race"][1] - 100
            x = npcD["x"]
            ClassCount[1][class] = ClassCount[1][class] + 1
            MoveTypeCount[1][moveType] = MoveTypeCount[1][moveType] + 1
            Race1Count[1][race1] = Race1Count[1][race1] + 1 
            if type(x) == "number" then
                XCount[1][x] = XCount[1][x] + 1
            elseif type(x) == "table" then
                for i=1, #x do
                    XCount[1][x[i]] = XCount[1][x[i]] + 1
                end
            end
            NpcMap[1][npcD["id"]] = true
        end
    end

    -- 敌方
    local teams = self._battleInfo.enemyInfo.team
    if teams then
        for i = 1, #teams do
            teamD = tab.team[teams[i].id]
            class = teamD["class"]
            moveType = teamD["movetype"]
            race1 = teamD["race"][1] - 100
            x = teamD["x"]
            ClassCount[2][class] = ClassCount[2][class] + 1
            MoveTypeCount[2][moveType] = MoveTypeCount[2][moveType] + 1
            Race1Count[2][race1] = Race1Count[2][race1] + 1
            if type(x) == "number" then
                XCount[2][x] = XCount[2][x] + 1
            elseif type(x) == "table" then
                for i=1, #x do
                    XCount[2][x[i]] = XCount[2][x[i]] + 1
                end
            end
            TeamMap[2][teamD["id"]] = true
        end
    end
    local npcD
    local npcs = self._battleInfo.enemyInfo.npc
    if npcs then
        for i = 1, #npcs do
            npcD = tab.npc[npcs[i][1]]
            class = npcD["class"]
            moveType = npcD["mot"]
            race1 = npcD["race"][1] - 100
            x = npcD["x"]
            ClassCount[2][class] = ClassCount[2][class] + 1
            MoveTypeCount[2][moveType] = MoveTypeCount[2][moveType] + 1
            Race1Count[2][race1] = Race1Count[2][race1] + 1 
            if type(x) == "number" and x ~= 0 then
                XCount[2][x] = XCount[2][x] + 1
            elseif type(x) == "table" then
                for i=1, #x do
                    XCount[2][x[i]] = XCount[2][x[i]] + 1
                end
            end
            NpcMap[2][npcD["id"]] = true
        end
    end
end

function BattleLogic:getHero(camp)
    return self._heros[camp]
end

function BattleLogic:_sortTeams()
    if self._battleInfo.playerInfo.team then
        table.sort(self._battleInfo.playerInfo.team, function(a, b)
            return tonumber(a.pos) < tonumber(b.pos)
        end)
    end
    if self._battleInfo.enemyInfo.team then
        table.sort(self._battleInfo.enemyInfo.team, function(a, b)
            return tonumber(a.pos) < tonumber(b.pos)
        end)
    end
end

local ATTR_Def = BattleUtils.ATTR_Def
local ATTR_Crit = BattleUtils.ATTR_Crit
local ATTR_CritD = BattleUtils.ATTR_CritD
local ATTR_Dodge = BattleUtils.ATTR_Dodge
local ATTR_AHP = BattleUtils.ATTR_AHP
local ATTR_DHP = BattleUtils.ATTR_DHP
local ATTR_Heal = BattleUtils.ATTR_Heal
local ATTR_BeHeal = BattleUtils.ATTR_BeHeal
local ATTR_Hot = BattleUtils.ATTR_Hot
local ATTR_DamageInc = BattleUtils.ATTR_DamageInc
local ATTR_DamageDec = BattleUtils.ATTR_DamageDec
local ATTR_DecAll = BattleUtils.ATTR_DecAll
-- 初始化我方
function BattleLogic:_initLeftTeam()
    self._teamMap = {}
    local camp = ECamp.LEFT

    -- 英雄
    local playerInfo = self._battleInfo.playerInfo
    self._heros[camp] = BattleHero.new(objLayer, playerInfo, camp)

    local weapon
    local weaponD = playerInfo.weapons or {}
    for i = 1, 3 do
        if weaponD[i] then
            weapon = BattleWeapon.new(objLayer, weaponD[i], i, camp)
            self._weapons[camp][i] = weapon
        end
    end

    local teamReplace = self._heros[camp].teamReplace
    -- 怪兽
    local teamArr = {}
    local teams = playerInfo.team
    self._teams[camp] = {}
    if teams then
        local count = #teams
        local team
        local teamInfo
        local x, y
        local teamid
        for i = 1, count do
            teamInfo = teams[i]
            team = BattleTeam.new(camp)   
            team.dhr = teamInfo.dhr
            x, y = BC.getFormationScenePos(teamInfo.pos, team.camp)
            teamid = teamInfo.id
            self._teamMap[teamid] = true
            if teamReplace[teamid] then
                team.replaceId = teamid
                teamid = teamReplace[teamid]
            end
            teamInfo.teamid = teamid
            BC.initTeamAttr_Common(team, self._heros[camp], teamInfo, x, y, teamInfo.scale)
            team.teamData = teamInfo.data
            self:_raceCountAdd(camp, team.race1, team.race2)
            self.classCount[camp][team.classLabel] = self.classCount[camp][team.classLabel] + 1
            if not BATTLE_PROC and teamArr[teamInfo.pos] then
                ViewManager:getInstance():showTip("我方站位重叠:"..teamInfo.pos)
            end
            teamArr[teamInfo.pos] = team
        end

        if SRData then
           
            local team, soldier, k, teamInfo, attr
            if count > 8 then count = 8 end
            for i = 1, count do
                -- 兵团初始状态
                teamInfo = teams[i]
                team = teamArr[teamInfo.pos]
                soldier = team.soldier[1]
                attr = soldier.attr
                k = (i - 1) * 9 + 25
                SRData[k] = teamInfo.id
                SRData[1 + k] = team.maxNumber
                SRData[2 + k] = soldier.maxHP
                SRData[3 + k] = soldier.maxHP * team.maxNumber
                SRData[4 + k] = soldier.atk
                SRData[5 + k] = attr[ATTR_Def]
                SRData[6 + k] = team.speedMove + team.speedAdd
                SRData[7 + k] = soldier.atkspeed
                SRData[8 + k] = attr[ATTR_Crit] .. "," .. attr[ATTR_CritD] .. "," .. attr[ATTR_Dodge] .. "," .. attr[ATTR_AHP] .. "," .. attr[ATTR_DHP]
                                    .. "," .. attr[ATTR_Heal] .. "," .. attr[ATTR_BeHeal] .. "," .. attr[ATTR_Hot] .. "," .. attr[ATTR_DamageInc]
                                    .. "," .. attr[ATTR_DamageDec] .. "," .. attr[ATTR_DecAll]
                -- 兵团战前状态
                k = (i - 1) * 20 + 176
                SRData[k] = teamInfo.id
                SRData[1 + k] = team.maxNumber
                SRData[3 + k] = soldier.maxHP
                SRData[4 + k] = soldier.maxHP * team.maxNumber
            end
        end
    end

    local npcs = playerInfo.npc
    if npcs then
        -- 怪兽
        local monster
        local team
        local info
        local x, y
        for i = 1, #npcs do
            monster = npcs[i]
            team = BattleTeam.new(camp)   
            x, y = BC.getFormationScenePos(monster[2], team.camp)
            info = {npcid = monster[1], level = monster[3] or 1, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[camp], info, x, y)    
            self:_raceCountAdd(camp, team.race1, team.race2)
            self.classCount[camp][team.classLabel] = self.classCount[camp][team.classLabel] + 1
            if not BATTLE_PROC and teamArr[monster[2]] then
                ViewManager:getInstance():showTip("我方站位重叠:"..monster[2])
            end
            teamArr[monster[2]] = team
        end
    end
    local team
    for i = 1, 16 do
        if teamArr[i] then
            team = teamArr[i]
            self:addTeam(team)
            -- 原始出场方阵标记
            team.original = true
            team.original1 = team.ID <= 8
            self._originalTeams[#self._originalTeams + 1] = team
        end
    end
    self._initTeamPos = {}
    self.teamCount[camp] = #self._teams[camp]
    self._initTeamPos[camp] = teamArr
end

-- 初始化敌方
function BattleLogic:_initRightTeam()
    local camp = ECamp.RIGHT
    self._teams[camp] = {}

    -- 英雄
    local enemyInfo = self._battleInfo.enemyInfo

    self._heros[camp] = BattleHero.new(objLayer, enemyInfo, camp)
    local weapon
    local weaponD = enemyInfo.weapons or {}
    for i = 1, 3 do
        if weaponD[i] then
            weapon = BattleWeapon.new(objLayer, weaponD[i], i, camp)
            self._weapons[camp][i] = weapon
        end
    end

    local teamReplace = self._heros[camp].teamReplace
    -- 怪兽
    local teamArr = {}
    local teams = enemyInfo.team
    if teams then
        local count = #teams
        local team
        local teamInfo
        local x, y
        local teamid
        for i = 1, count do
            teamInfo = teams[i]
            if teamInfo.smallStar == nil then
                teamInfo.smallStar = 0
            end
            -- dump(teamInfo)
            team = BattleTeam.new(camp) 
            team.dhr = teamInfo.dhr  
            x, y = BC.getFormationScenePos(teamInfo.pos, team.camp)
            teamid = teamInfo.id
            if teamReplace[teamid] then
                team.replaceId = teamid
                teamid = teamReplace[teamid]
            end
            teamInfo.teamid = teamid
            BC.initTeamAttr_Common(team, self._heros[camp], teamInfo, x, y, teamInfo.scale)
            team.teamData = teamInfo.data
            self:_raceCountAdd(camp, team.race1, team.race2)
            self.classCount[camp][team.classLabel] = self.classCount[camp][team.classLabel] + 1
            if not BATTLE_PROC and teamArr[teamInfo.pos] then
                ViewManager:getInstance():showTip("敌方站位重叠:"..teamInfo.pos)
            end
            teamArr[teamInfo.pos] = team
        end
        if SRData then
            SRData[102] = count
        end
    end
    local npcs = enemyInfo.npc
    if npcs then
        -- 怪兽
        local monster
        local team
        local info
        local x, y
        for i = 1, #npcs do
            monster = npcs[i]
            team = BattleTeam.new(camp)   
            x, y = BC.getFormationScenePos(monster[2], team.camp)
            info = {
                        npcid = monster[1], level = monster[3] or 1, summon = false, skillLevels = monster[4], 
                        lzyteamscore = monster[5], 
                        lzyteamstar = monster[6], 
                        lzyteamlvdis = monster[7], 
                        lzyteamquality = monster[8],
                        lzyjx = monster[9],
                        jx = monster[9],
                        jxLv = monster[10],
                        jxSkill1 = monster[11],
                        jxSkill2 = monster[12],
                        jxSkill3 = monster[13]
                    }
            BC.initTeamAttr_Npc(team, self._heros[camp], info, x, y)    
            self:_raceCountAdd(camp, team.race1, team.race2)
            self.classCount[camp][team.classLabel] = self.classCount[camp][team.classLabel] + 1
            if not BATTLE_PROC and teamArr[monster[2]] then
                ViewManager:getInstance():showTip("敌方站位重叠:"..monster[2])
            end
            teamArr[monster[2]] = team
        end
        if SRData then
            local count = #npcs
            SRData[103] = count
            local team, soldier, k, monster, attr
            local atkmax = 0
            local hpmin = 99999999
            local hpmax = 0
            for i = 1, count do
                monster = npcs[i]
                team = teamArr[monster[2]]
                soldier = team.soldier[1]
                attr = soldier.attr
                if soldier.atk > atkmax then
                    atkmax = soldier.atk
                end
                if soldier.maxHP > hpmax then
                    hpmax = soldier.maxHP
                end
                if soldier.maxHP < hpmin then
                    hpmin = soldier.maxHP
                end
            end
            SRData[105] = atkmax
            SRData[106] = atkmax
            SRData[107] = hpmax
            SRData[108] = hpmin
        end
    end

    local team
    for i = 1, 16 do
        if teamArr[i] then
            team = teamArr[i]
            self:addTeam(team)
            -- 原始出场方阵标记
            team.original = true
            team.original2 = true
            self._originalTeams[#self._originalTeams + 1] = team
        end
    end

    self.teamCount[camp] = #self._teams[camp]
    self._initTeamPos[camp] = teamArr
end

function BattleLogic:getTeamMap()
    return self._teamMap
end

function BattleLogic:_initTeamSkillDynamicCD()
    local rant = {{6, 10}, {6, 10}, {6, 10}, {6, 10}, {5, 9}, {5, 7}, {4, 8}, {4, 7}}
    local count = #self._teams[1]
    local num
    if self._battleInfo.playerInfo.level then
        num = tab.userLevel[self._battleInfo.playerInfo.level].num
    else
        num = count
    end
    if num < 1 then
        num = 1
    end
    if num > 8 then
        num = 8
    end
    local rmin, rmax = rant[num][1], rant[num][2]
    local randomTab = {}
    local all = 0
    for i = 1, num do
        all = all + rmin + random(100) * (rmax - rmin) * 0.01
        randomTab[i] = all
    end
    randomTab = BC.randomTable(randomTab)
    for i = 1, count do
        if i <= #randomTab then
            self._teams[1][i].dynamicPreCD = randomTab[i]
        else
            self._teams[1][i].dynamicPreCD = randomTab[#randomTab]
        end
        self._teams[1][i].dynamicCD = all
    end
    local count = #self._teams[2]
    local num 
    if self._battleInfo.enemyInfo.level then
        num = tab.userLevel[self._battleInfo.enemyInfo.level].num
    else
        num = count
    end
    if num < 1 then
        num = 1
    end
    if num > 8 then
        num = 8
    end
    local rmin, rmax = rant[num][1], rant[num][2]
    local randomTab = {}
    local all = 0
    for i = 1, num do
        all = all + rmin + random(100) * (rmax - rmin) * 0.01
        randomTab[i] = all
    end
    randomTab = BC.randomTable(randomTab)
    for i = 1, count do
        if i <= #randomTab then
            self._teams[2][i].dynamicPreCD = randomTab[i]
        else
            self._teams[2][i].dynamicPreCD = randomTab[#randomTab]
        end
        self._teams[2][i].dynamicCD = all
    end
    self.dynamicCD = all
end

local ETeamStateIDLE = ETeamState.IDLE
local ETeamStateMOVE = ETeamState.MOVE
local ETeamStateATTACK = ETeamState.ATTACK
local ETeamStateSORT = ETeamState.SORT
local ETeamStateDIE = ETeamState.DIE
function BattleLogic:clear()
    self:clearEx()
    self._teams = nil
    for i = 1, #self._updateList do
        self._updateList[i]:clear()
        delete(self._updateList[i])
    end
    self._updateList = nil
    self._damageShareList = nil

    BC.DelayCall:clear()
    
    self._control = nil
    objLayer = nil

    self._damageShareList = nil
    self._damageShareValue = nil
    self.teamCount = nil
    self.race1Count = nil
    self.race2Count = nil
    self.classCount = nil
    self._rowTeam = nil
    self._teams = nil
    self._allTeams = nil
    self._initTeamPos = nil
    delete(self._heros[1])
    delete(self._heros[2])
    for i = 1, 3 do
        if self._weapons[1][i] then
            delete(self._weapons[1][i])
        end
        if self._weapons[2][i] then
            delete(self._weapons[2][i])
        end
    end
    self._weapons = nil
    self._heros = nil
    -- self._HP = nil
    -- self._MaxHP = nil
    -- self._summonHP = nil
    -- self._summonMaxHP = nil
    self._playerSkillCountData = nil
    self._selectTeamList = nil

end

function BattleLogic:clearTeamStateLabel()
    for i = 1, #self._updateList do
        self._updateList[i].stateLabel = nil
    end
end

function BattleLogic:clearHero()
    self._heros[1]:clear()
    self._heros[2]:clear()
    for i = 1, 3 do
        if self._weapons[1][i] then
            self._weapons[1][i]:clear()
        end
        if self._weapons[2][i] then
            self._weapons[2][i]:clear()
        end
    end
end

function BattleLogic:jumpEnd()
    self.battleState = EState.OVER
end

function BattleLogic:battleBeginMC()
    self._heros[1]:BattleBegin()
    self._heros[2]:BattleBegin()
end

local EMotionBORN = EMotion.BORN
function BattleLogic:BattleBegin()
    -- 战斗开始
    self.battleBeginTick = BC.BATTLE_TICK

    self._control:onBattleBegin()
    self.battleState = EStateING
    self._updateIndex = 1
    self._actionValue = 0
    self:BattleBeginEx()

    for i = 1, #self._updateList do
        local team = self._updateList[i]
        if not team.walk then
            -- 出生动画
            for k = 1, #team.soldier do
                team.soldier[k]:setCanCaught(false)
                team.soldier[k]:changeMotion(EMotionBORN)
            end
        end
        if not BATTLE_PROC then
            ScheduleMgr:delayCall(GRandom(1000), self, function ()
                team:initSound()
            end)
        end
    end
    if not BATTLE_PROC then
        objLayer:showAllTeamHUD(self.battleTime)
    end
    if SRData then
        SRData[476] = os.time()
    end
    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

function BattleLogic:BattleEnd(isTimeUp, isSurrender, isSkip, pos)
    print("BattleLogic:BattleEnd "..pos, BC.jump, BATTLE_PROC)
    if self._battleEnded then 
        print("!!!BattleLogic:BattleEnd, muti")
        return 
    end
    self._battleEnded = true
    -- 血量检查 防止作弊
    local zuobi = false
    if not BATTLE_PROC and not isSurrender and GameStatic.checkZuoBi_1 then
        local ATTR_Atk = BattleUtils.ATTR_Atk
        local ATTR_COUNT = BattleUtils.ATTR_COUNT
        local team, soldier, baseSum
        for i = 1, #self._updateList do
            if zuobi then
                break
            end
            team = self._updateList[i]
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                if soldier.baseSum then
                    baseSum = 0
                    local _baseAttr = soldier.baseAttr
                    for i = ATTR_Atk, ATTR_COUNT do
                        baseSum = baseSum + _baseAttr[i]
                    end
                    if abs(baseSum - soldier.baseSum) > 0.001 then
                        print("基础属性对不上", team.D["id"])
                        zuobi = true
                        break
                    end
                end
            end
        end

        print("检查HP和时间")
        local teams = self._teams[1]
        local team, soldier
        local hp1, maxhp1 = 0, 0
        for i = 1, #teams do
            team = teams[i]
            if not team.building then
                for k = 1, #team.soldier do
                    soldier = team.soldier[k]
                    hp1 = hp1 + soldier.HP
                    maxhp1 = maxhp1 + soldier.maxHP
                end
            end
        end
        print(1, hp1, maxhp1, self._HP[1] + self._summonHP[1], self._MaxHP[1] + self._summonMaxHP[1])
        local teams = self._teams[2]
        local hp2, maxhp2 = 0, 0
        for i = 1, #teams do
            team = teams[i]
            if not team.building then
                for k = 1, #team.soldier do
                    soldier = team.soldier[k]
                    hp2 = hp2 + soldier.HP
                    maxhp2 = maxhp2 + soldier.maxHP
                end
            end
        end
        print(2, hp2, maxhp2, self._HP[2] + self._summonHP[2], self._MaxHP[2] + self._summonMaxHP[2])
        if abs(hp1 - (self._HP[1] + self._summonHP[1])) > 0.0001 or 
            abs(maxhp1 - (self._MaxHP[1] + self._summonMaxHP[1])) > 0.0001 or
            abs(hp2 - (self._HP[2] + self._summonHP[2])) > 0.0001 or
            abs(maxhp2- (self._MaxHP[2] + self._summonMaxHP[2])) > 0.0001 then
            zuobi = true
            if OS_IS_WINDOWS then
                ViewManager:getInstance():showTip("战斗hp数据异常")
                ViewManager:getInstance():onLuaError(serialize({self._battleInfo.mode, self._battleInfo.subType, hp1, maxhp1, self._HP[1] + self._summonHP[1], self._MaxHP[1] + self._summonMaxHP[1], 
                                                    hp2, maxhp2, self._HP[2] + self._summonHP[2], self._MaxHP[2] + self._summonMaxHP[2]}))
            else
                ApiUtils.playcrab_lua_error("hp_yichang", serialize({self._battleInfo.mode, self._battleInfo.subType, hp1, maxhp1, self._HP[1] + self._summonHP[1], self._MaxHP[1] + self._summonMaxHP[1], 
                                                        hp2, maxhp2, self._HP[2] + self._summonHP[2], self._MaxHP[2] + self._summonMaxHP[2]}))
                if GameStatic.kickZuoBi_1 then
                    do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                end
            end

        end
        if BC.zuobi then
            zuobi = true
            if OS_IS_WINDOWS then
                ViewManager:getInstance():showTip("战斗属性数据异常 BC.zuobi")
                ViewManager:getInstance():onLuaError(serialize({self._battleInfo.mode, self._battleInfo.subType, BC.zuobi}))
            else
                ApiUtils.playcrab_lua_error("attr_yichang_" .. BC.zuobi, serialize({self._battleInfo.mode, self._battleInfo.subType, BC.zuobi}))
                if GameStatic.kickZuoBi_1 then
                    do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                end
            end
        end
        if BC.zuobi2 then
            zuobi = true
            if OS_IS_WINDOWS then
                ViewManager:getInstance():showTip("战斗属性数据异常 BC.zuobi2")
                ViewManager:getInstance():onLuaError(serialize({self._battleInfo.mode, self._battleInfo.subType, BC.zuobi2}))
            else
                ApiUtils.playcrab_lua_error("attr2_yichang_" .. BC.zuobi2, serialize({self._battleInfo.mode, self._battleInfo.subType, BC.zuobi2}))
                if GameStatic.kickZuoBi_1 then
                    do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                end
            end
        end
        -- 检查时间和帧数
        if GameStatic.checkZuoBi_4 then
            local value1 = BC.frameInv * self.battleFrameCount
            local value2 = self.battleTime
            if abs(value1 - value2) > 0.001 then
                zuobi = true
                if OS_IS_WINDOWS then
                    ViewManager:getInstance():showTip("时间异常数据异常")
                    ViewManager:getInstance():onLuaError(serialize({battleFrameCount = self.battleFrameCount, battleTime = self.battleTime}))
                else
                    ApiUtils.playcrab_lua_error("time_yichang", serialize({battleFrameCount = self.battleFrameCount, battleTime = self.battleTime, frameInv = BC.frameInv}))
                    if GameStatic.kickZuoBi_4 then
                        do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                    end
                end     
            end
        end
        -- 检查英雄属性
        if GameStatic.checkZuoBi_5 then
            local v1 = BC.__cacheHeroAttr
            local v2 = BC.cacheHeroAttr()
            if abs(v1 - v2) > 0.001 then
                zuobi = true
                if OS_IS_WINDOWS then
                    ViewManager:getInstance():showTip("战斗属性英雄数据异常")
                    ViewManager:getInstance():onLuaError(serialize({self._battleInfo.mode, self._battleInfo.subType, 666}))
                else
                    ApiUtils.playcrab_lua_error("attr_yichang3_666", serialize({self._battleInfo.mode, self._battleInfo.subType, 666}))
                    if GameStatic.kickZuoBi_5 then
                        do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                    end
                end
            end
        end
    end

    -- 检查技能大招的释放频率 
    if not BATTLE_PROC then
        if self:checkDaZhao() then
            zuobi = true
        end
        -- 检查技能的cd和蓝
        self:checkSkillCDAndMana()

        -- 检查技能等级是否异常
        self:checkSkillLevel()
    end

    if BC.fastBattle then
        BATTLE_PROC = false
    end
    if SRData and GameStatic.checkZuoBi_6 then
        local maxValue = GameStatic.checkZuoBi_6_value
        if maxValue == nil then
            maxValue = 1000000
        end
        local __zuobi = false
        if SRData[192] > maxValue then __zuobi = true end
        if SRData[212] > maxValue then __zuobi = true end
        if SRData[232] > maxValue then __zuobi = true end
        if SRData[252] > maxValue then __zuobi = true end
        if SRData[272] > maxValue then __zuobi = true end
        if SRData[292] > maxValue then __zuobi = true end
        if SRData[312] > maxValue then __zuobi = true end
        if SRData[332] > maxValue then __zuobi = true end
        if __zuobi then
            if OS_IS_WINDOWS then
                ViewManager:getInstance():showTip("战斗中单次攻击超过上限")
                ViewManager:getInstance():onLuaError(serialize({self._battleInfo.mode, self._battleInfo.subType, self._heros[1].level, SRData[192], SRData[212], SRData[232], SRData[252], SRData[272], SRData[292], SRData[312], SRData[332]}))
            else
                ApiUtils.playcrab_lua_error("atk_yichang", serialize({self._battleInfo.mode, self._battleInfo.subType, self._heros[1].level, SRData[192], SRData[212], SRData[232], SRData[252], SRData[272], SRData[292], SRData[312], SRData[332]}))
                -- zuobi = true
                -- if GameStatic.kickZuoBi_6 then
                --     do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                -- end
            end
        end
    end

    self._control:battleEnd()
    local leftData = {}
    local rightData = {}
    local dieList = {{}, {}}
    local count, team, data, vd
    local totalDamage1 = 0
    local totalRealDamage1 = 0
    local dieCount1 = 0
    count = #self._teams[1]
    for i = 1, count do
        team = self._teams[1][i]
        totalDamage1 = totalDamage1 + team.damage
        totalRealDamage1 = totalRealDamage1 + team.damage1
        if team.original or team.summon then
            data = {
                    damage = team.damage,
                    realDamage = team.damage1,
                    damageSkill = team.damageSkill,
                    skills = team.skillmap,
                    hurt = team.hurt,
                    realHurt = team.hurt1,
                    heal = team.heal,
                    die = team.dieTick,
                    original = team.original,
                    DType = team.DType,
                    D = team.D,
                    DEx = team.D,
                    dhr = team.dhr,
                    teamData = team.teamData,
                    skillLevels = team.skillLevels,
                    summonTick = team.summonTick,
                    copy = team.copy,
                    jx = team.jx,
                    isMercenary = team.isMercenary,
                    }
            if team.replaceId then
                data.D = tab.team[team.replaceId]
            end
            leftData[#leftData + 1] = data
            if team.state == ETeamState.DIE then
                if not team.reviveing then
                    dieList[1][tostring(data.D["id"])] = true
                end
                if team.original then
                    dieCount1 = dieCount1 + 1
                end
            end
        end
    end
    leftData[0] = {realDamage = self._playerDamage[1], damage = self._playerDamage1[1], heal = self._playerHeal[1]}
    count = #self._teams[2]
    local totalDamage2 = 0
    local totalRealDamage2 = 0
    local dieCount2 = 0
    for i = 1, count do
        team = self._teams[2][i]
        totalDamage2 = totalDamage2 + team.damage
        totalRealDamage2 = totalRealDamage2 + team.damage1
        if team.original or team.summon then
            data = {
                    damage = team.damage,
                    realDamage = team.damage1,
                    damageSkill = team.damageSkill,
                    skills = team.skillmap,
                    hurt = team.hurt,
                    realHurt = team.hurt1,
                    heal = team.heal,
                    die = team.dieTick,
                    original = team.original,
                    DType = team.DType,
                    D = team.D,
                    DEx = team.D,
                    dhr = team.dhr,
                    lzyscore = team.lzyscore,
                    lzystar = team.lzystar,
                    lzylvdis = team.lzylvdis,
                    lzyquality = team.lzyquality,
                    teamData = team.teamData,
                    skillLevels = team.skillLevels,
                    summonTick = team.summonTick,
                    copy = team.copy,
                    jx = team.jx,
                    isMercenary = team.isMercenary,
                    }
            if team.replaceId then
                data.D = tab.team[team.replaceId]
            end
            rightData[#rightData + 1] = data
            if team.state == ETeamState.DIE then
                if not team.reviveing then
                    dieList[2][tostring(data.D["id"])] = true
                end
                if team.original then
                    dieCount2 = dieCount2 + 1
                end
            end
        end
    end
    rightData[0] = {realDamage = self._playerDamage[2], damage = self._playerDamage1[2], heal = self._playerHeal[2]}

    local mode = self._battleInfo.mode
    if BattleUtils.BATTLE_TYPE_BOSS_SjLong == mode then
        -- 水晶龙把所有小龙统计在一起
        rightData[1].boss = true
        if rightData[2] then
            for i = 3, 9 do
                if rightData[i] == nil then break end
                rightData[2].damage = rightData[2].damage + rightData[i].damage
                rightData[2].hurt = rightData[2].hurt + rightData[i].hurt
                rightData[2].heal = rightData[2].heal + rightData[i].heal
                rightData[i] = nil
            end
            rightData[2].boss = true
        end
    end
    if BattleUtils.BATTLE_TYPE_BOSS_DuLong == mode then
        rightData[1].boss = true
    end
    if BattleUtils.BATTLE_TYPE_BOSS_XnLong == mode then
        rightData[1].boss = true
    end
    if mode >= BattleUtils.BATTLE_TYPE_GBOSS_1 and mode <= BattleUtils.BATTLE_TYPE_GBOSS_3 then
        rightData[1].boss = true
    end
    if mode >= BattleUtils.BATTLE_TYPE_Elemental_1 and mode <= BattleUtils.BATTLE_TYPE_Elemental_5 then
        for i = 1, #rightData do
            rightData[i].boss = true
        end
    end
    if mode == BattleUtils.BATTLE_TYPE_Siege_Def or mode == BattleUtils.BATTLE_TYPE_Siege_Def_WE then
        local tempTable = {}
        for i = 0, #rightData do
            if rightData[i]["D"] ~= nil then
                tempTable[rightData[i]["D"]["id"]] = rightData[i]
            else
                tempTable[i] = rightData[i]
            end
        end
        rightData = {}
        for k, v in pairs(tempTable) do
            if v["D"] ~= nil then
                v["hurt"] = -1
                v["heal"] = -1
                v["damage"] = -1
                table.insert(rightData, v)
            else
                rightData[k] = v
            end
        end
    end

    -- 战斗结束
    self._leftData = leftData
    self._rightData = rightData
    -- dump(self._leftData, "1", 2)
    -- dump(self._rightData, "1", 2)

    self._control:battleBeginAnimCancelEx()
    if not BC.jump then
        self._control:disableBtns()
        self._control:disableBlack(true)
        self:setCampBrightness(1, 0)
        self:setCampBrightness(2, 0)
    end
    self:allTeamOver()
    BC.BATTLE_SPEED = 1.0

    if SRData then 
        SRData[477] = os.time()
        -- 蓝量
        SRData[345] = math.floor(self.mana[1] * 10000) * 0.0001
        -- 结束时候兵团状态
        local count, team, k, hp
        count = #self._teams[1]
        for i = 1, count do
            team = self._teams[1][i]
            if team.original1 then
                k = (i - 1) * 20 + 178
                SRData[k] = #team.aliveSoldier
                hp = 0
                for n = 1, #team.aliveSoldier do
                    hp = hp + team.aliveSoldier[n].HP
                end
                SRData[3 + k] = hp
                SRData[7 + k] = team.hurt
                SRData[8 + k] = team.dieCount
                SRData[9 + k] = team.reviveCount    
                SRData[17 + k] = team.damage
            end
        end

        -- monster相关
        local count = #self._teams[2]
        local team, soldier, firstDamageMaxHP
        local _count0 = 0 -- 怪物数
        local _count1 = 0 -- 兵团数
        local _count2 = 0 -- 结束时候剩余怪物数
        local _count3 = 0 -- 初始血量
        local _count4 = 0 -- 存活时间
        local _count5 = 0 -- 总伤害
        local minHP = 9999999
        local maxHP = 0
        local _hp1count = 0
        for i = 1, count do
            team = self._teams[2][i]
            _count0 = _count0 + team.maxNumber
            if team.original then
                _count1 = _count1 + 1
            end
            if team.state ~= ETeamState.DIE then
                _count2 = _count2 + #team.aliveSoldier
                _count4 = _count4 + self.battleTime
            else
                _count4 = _count4 + team.dieTick
            end
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                firstDamageMaxHP = soldier.firstDamageMaxHP
                if firstDamageMaxHP then
                    if firstDamageMaxHP > maxHP then maxHP = firstDamageMaxHP end
                    if firstDamageMaxHP < minHP then minHP = firstDamageMaxHP end
                    _count3 = _count3 + firstDamageMaxHP
                else
                    _count3 = _count3 + soldier.maxHP
                end
            end
            _count5 = _count5 + team.damage
        end
        SRData[346] = _count0
        SRData[347] = _count1
        SRData[348] = _count2
        SRData[349] = self.playerKillCount -- 击杀数量

        SRData[360] = maxHP
        SRData[361] = minHP
        SRData[365] = _count3

        SRData[379] = math.floor(_count4 * 1000)
        SRData[383] = _count5
    end
    local ex = 
    {
        doAssist = self._doAssist,
        totalDamage1 = totalDamage1,
        totalDamage2 = totalDamage2,
        totalRealDamage1 = totalRealDamage1,
        totalRealDamage2 = totalRealDamage2,
        dieCount1 = dieCount1,
        dieCount2 = dieCount2,
    }
    self._control:onBattleEnd(self._leftData, self._rightData, dieList, self.originalDieCount - self._reviveCount[1], isTimeUp, isSurrender, isSkip,
                                self._heros[1], self._heros[2], self._playCastTime, ex, zuobi)
end

function BattleLogic:checkDaZhao()
    local zuobi = false
    if self._battleInfo.mode ~= BattleUtils.BATTLE_TYPE_CloudCity and self._battleInfo.mode ~= BattleUtils.BATTLE_TYPE_CCSiege then
        local dazhaoCount = 0
        for i = 1, #self._playCastTime do
            if self._playCastTime[i][2] == 4 then
                dazhaoCount = dazhaoCount + 1
            end
        end
        if dazhaoCount > 3 then
            local max = 60
            if self._heros[1].ID == 60401 then
                max = 60
            elseif self._battleInfo.mode == BattleUtils.BATTLE_TYPE_AiRenMuWu then
                max = 120
            else
                max = 275
            end
            if self.battleFrameCount / dazhaoCount < max then
                if OS_IS_WINDOWS then
                    ViewManager:getInstance():onLuaError(serialize({self.battleFrameCount, dazhaoCount, max, self._heros[1].ID}))
                else
                    zuobi = true
                    local f = io.open('/proc/self/maps', 'rb')
                    if f then
                        local cmdline = f:read('*all')
                        f:close()
                        ApiUtils.playcrab_lua_error("cmdline", cmdline)
                    end
                    ApiUtils.playcrab_lua_error("jineng0cd", serialize({self.battleFrameCount, dazhaoCount, max, self._heros[1].ID}))
                    do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                end
            end 
        end
    end
    return zuobi
end

function BattleLogic:checkSkillCDAndMana()
    if not GameStatic.checkZuoBi_7 then return end
    -- local skillCastTab = {}
    -- local __id
    -- for i = #self._playCastTime, 1, -1 do
    --     __id = self._playCastTime[i][2]
    --     if skillCastTab[__id] == nil then
    --         skillCastTab[__id] = self._playCastTime[i][1] * BC.frameInv
    --     end
    -- end
    for i = 1, 5 do
        local __skill = self._playSkills[1][i]
        if __skill then
            -- if skillCastTab[i] and __skill.castTick < skillCastTab[i] then
            --     if OS_IS_WINDOWS then
            --         ViewManager:getInstance():showTip("技能cd异常")
            --         print(i, skillCastTab[i], __skill.castTick, self.battleTime)
            --     else
            --         ApiUtils.playcrab_lua_error("jineng0_cd", serialize({skillCastTab, i, __skill.castTick, self.battleTime}))
            --         if GameStatic.kickZuoBi_7 then do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end end
            --         break
            --     end
            -- end
            if __skill.oriMana > 0 then
                if __skill.mana <= 0 or math.abs(__skill.baseMana - (-__skill.mana * 7)) > 0.00001 then
                    if OS_IS_WINDOWS then
                        ViewManager:getInstance():showTip("技能mana异常")
                    else
                        ApiUtils.playcrab_lua_error("jineng0_mana", serialize({i, __skill.id, __skill.mana, __skill.oriMana, __skill.baseMana}))
                        if GameStatic.kickZuoBi_7 then do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end end
                        break
                    end
                end 
            end
        end
    end 
end

function BattleLogic:checkSkillLevel()
    if not GameStatic.checkZuoBi_8 then return end
    for i = 1, 5 do
        if self._playSkills[1][i] and self._playSkills[1][i].level > GameStatic.checkZuoBi_8_value then
            ApiUtils.playcrab_lua_error("jinenglevel", serialize({i, self._playSkills[1][i].level}))
            if GameStatic.kickZuoBi_8 then
                do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
            end
            break
        end
    end
end

function BattleLogic:allTeamOver()
    for i = 1, #self._updateList do
        if self._updateList[i].state ~= ETeamState.DIE then  
            if not self._updateList[i].cantSort then
                self._updateList[i]:stopMove(true)
                -- self:teamSort(self._updateList[i], true)
            else
                self:teamAttackOver(self._updateList[i])
            end
            self:teamOver(self._updateList[i], true)
        end
    end 
end

function BattleLogic:timeUp(winner)
    self:Win(winner, true, false, false)
end

function BattleLogic:surrender(winner)
    self:Win(winner, false, true, false)
end

function BattleLogic:doSkip()
    self._skip = true
end

function BattleLogic:skip(winner)
    self:Win(winner, false, false, true)
end

-- 分出胜负
function BattleLogic:Win(winner, isTimeUp, isSurrender, isSkip)
    -- 英雄动作
    self._heros[winner]:Win()
    BattleTeam.finishSound()
    self.battleState = EState.OVER
    self._control:onWinner(winner)
    self._winCamp = winner
 
    BC.DelayCall:clear()
    objLayer:battleEnd()

    self:clearSkill()
    if isTimeUp == nil then
        isTimeUp = false
    end
    if isSurrender == nil then
        isSurrender = false
    end
    if BC.jump and not BATTLE_PROC then
        self._isTimeUp = isTimeUp
        self._isSurrender = isSurrender
        self._isSkip = isSkip
    else
        self:BattleEnd(isTimeUp, isSurrender, isSkip, 2)
    end
end

function BattleLogic:onSceneScale()
    BattleTeam.onSceneScale()
end

-- 逻辑主循环
local floor = math.floor
function BattleLogic:update()
    if self._error then
        return
    end
    self._error = true
    local ing = self.battleState == EStateING
    if ing then
        self.battleTime = BC.BATTLE_TICK - self.battleBeginTick
        self.battleFrameCount = self.battleFrameCount + 1
    end
    -- 方阵
    if not self:updateBattle() then
        return true
    end
    self:updateEx()

    -- 玩家技能
    if ing then
        self:updateSkill()
    end
    -- 图腾
    self:updateTotem(ing)

    if ing then
        -- buff
        self:updateBuff()

        local tick = self.battleTime
        if tick > self._lastCheckDS + DAMAGESHARE_TICK_INV then
            self._lastCheckDS = tick
            -- 灵魂连接结算
            for i = 1, 2 do
                if self._damageShareValue[i] ~= 0 then
                    local count = 0
                    local array = {}
                    if next(self._damageShareList[i]) ~= nil then
                        for k, v in pairs(self._damageShareList[i]) do
                            count = count + 1
                            array[count] = v
                        end
                        local value = floor(self._damageShareValue[i] / count)
                        for i = 1, count do
                            array[i]:HPChange(nil, value, false, 1)
                        end
                    end
                    self._damageShareValue[i] = 0
                end
            end
        end

        -- delaycall
        BC.DelayCall:update(BC.BATTLE_DELTA)
    elseif self.battleState == EState.INTO then
        BC.DelayCall:update(BC.BATTLE_DELTA)
    end

    if BattleUtils.XBW_SKILL_DEBUG then self:updateTeamDebugLabel() end

    self._error = false
end

function BattleLogic:clearSkill()

end

function BattleLogic:getCurHP()
    return self._HP[1], self._MaxHP[1], self._HP[2], self._MaxHP[2]
end

function BattleLogic:getSummonHP()
    return self._summonHP[1], self._summonMaxHP[1], self._summonHP[2], self._summonMaxHP[2]
end

function BattleLogic:getCampHP(camp)
    return self._HP[camp] + self._summonHP[camp]
end

function BattleLogic:doSurrender()
    self._surrender = true
end
-- 检查比赛结果
function BattleLogic:checkWin()
    return self:checkWinEx()
end

local getCellByScenePos = BC.getCellByScenePos
local ActionValue = BC.ActionValue
local ETeamStateDIE = ETeamState.DIE
local BattleTeam_update = BattleTeam.update
function BattleLogic:updateBattle()
    if self._updateList == nil then
        return false
    end
    local delta = self.frameActionValue

    local tick = BC.BATTLE_TICK
    if self.battleState ~= EState.READY then
        -- 判断是否死亡
        self._actionValue = self._actionValue + delta
        
        --self._updateList 里面存的是team
        local count = #self._updateList
        if count > 0 then
            while self._actionValue > 0.013 do
                self._actionValue = self._actionValue - 0.013 
                -- 方阵的状态改变
                if self._updateIndex > #self._updateList then
                    self._updateIndex = 1
                end
                -- print(self._updateIndex)
                self:updateTeam(self._updateList[self._updateIndex])
                self._updateIndex = self._updateIndex + 1
            end
        end
    end

    -- 方阵中英雄和士兵的状态判断
    local count = #self._updateList
    local res = true
    local team
    local target
    local updateSoldier = (self.battleState == EStateING)
    if updateSoldier then
        for k = 1, count do 
            team = self._updateList[k]
            -- 移动中每帧判断是否进入攻击范围
            target = team.moveTargetT
            if target ~= nil then
                if target.state == ETeamStateDIE or team.state == ETeamStateDIE then
                    -- 已经死了
                    team.moveTargetT = nil
                elseif team.state ~= ETeamStateATTACK then
                    if self:getTeamDis(team, target) < team.attackArea + 0.00000001 then
                        -- 如果进入攻击范围就朝目标前进，并且计算出攻击站位点（近战和远程兵团）
                        self:attackToTarget(team, target)
                    end
                end
            end
        end
    end
    for i = 1, count do 
        -- 更新每个兵团里每个士兵的位置以及刷新每个士兵的状态
        BattleTeam_update(self._updateList[i], tick, delta, updateSoldier)
    end
    if not BC.jump then
        self._heros[1]:update(tick)
        self._heros[2]:update(tick)
        for i = 1, 3 do
            if self._weapons[1][i] then
                self._weapons[1][i]:update(tick)
            end
            if self._weapons[2][i] then
                self._weapons[2][i]:update(tick)
            end
        end
    end

    if self.battleState == EStateING then
        if self:checkWin() then
            return true
        end
    end
    return true
end

function BattleLogic:updateDisplay()
    objLayer:update(self.battleTime)
    local tick = BC.BATTLE_DISPLAY_TICK
    self._heros[1]:displayUpdate(tick)
    self._heros[2]:displayUpdate(tick)
    for i = 1, 3 do
        if self._weapons[1][i] then
            self._weapons[1][i]:displayUpdate(tick)
        end
        if self._weapons[2][i] then
            self._weapons[2][i]:displayUpdate(tick)
        end
    end
end

function BattleLogic:updateBuff()
    local tick = BC.BATTLE_BUFF_TICK + BC.BATTLE_DELTA
    BC.BATTLE_BUFF_TICK = tick
    local teamCount = #self._updateList
    local index = self._buffUpdateIndex
    if index > teamCount then
        index = 1
    end 
    -- 属性hot, 固定三秒回复一次生命
    local shiqiBuff = true
    if self._updateList[index]:hot(tick, shiqiBuff) then
        shiqiBuff = false
    end
    for i = 1, #self._buffFrameUpdateList do
        self._buffFrameUpdateList[i]:updateTeamBuff(tick)
    end
    self._updateList[index]:updateTeamBuff(tick)
    index = index + 1
    if index > teamCount then
        index = 1
    end 

    self._buffUpdateIndex = index
end

-- 状态判断
local SPEED_SORT = BC.SPEED_SORT
local EDirectRIGHT = EDirect.RIGHT
local EDirectLEFT = EDirect.LEFT
function BattleLogic:updateTeam(team)
    local state = team.state
    if state == ETeamStateDIE then
        return
    end
    if self.battleState ~= EStateING and state ~= ETeamStateSORT then
        return
    end
    -- 待机状态
    if state == ETeamStateIDLE then
        if team.walk then
            if team.attackArea > 0 then
                self:findTarget(team, 
                    function () -- 没找到目标
                        -- 原地不动
                    end, nil,
                    function ()
                        -- 警戒范围内有人, 也不动
                    end)
            end
        else
            -- 不会走的兵团，例如大恶魔，待机超过2秒说明有问题
            if self.battleTime > 10 and self.battleTime > team.stateChangeTime + 2 then
                if team.attackArea > 0 then
                    self:findTarget(team, 
                        function () -- 没找到目标
                            -- 原地不动
                        end, nil,
                        function ()
                            -- 警戒范围内有人, 也不动
                        end)
                end
            end
        end
    -- 移动状态
    elseif state == ETeamStateMOVE then
        if team.attackArea > 0 and team.walk then
            -- 找到目标后会调用attackToTarget或者moveToTarget
            self:findTarget(team, 
                function () -- 没找到目标
                    -- 停止移动
                    if team.isMove then
                        team:stopMove(true)
                    end
                end)
        end
    -- 攻击状态
    elseif state == ETeamStateATTACK then
        -- 重新选择微观目标, 如果对方都死了, 就进行整顿
        self:attackUpdate(team)
    -- 整顿状态
    elseif state == ETeamStateSORT then
        local teamList = team.aliveSoldier
        local teamNumber = #teamList
        local sortDone = true
        local _x, _y = team.sortx, team.sorty
        local tsoldier = nil
        local getPosInFormation = BC.getPosInFormation
        local volume = team.volume
        local camp = team.camp
        local direct
        if camp == ECamp.LEFT then
            direct = EDirect.RIGHT
        else
            direct = EDirect.LEFT
        end
        for i = 1, teamNumber do
            tsoldier = teamList[i]
            if tsoldier.unSort then
                local x, y = getPosInFormation(_x, _y, i, volume, camp)
                tsoldier:moveTo(x, y, SPEED_SORT, function (soldier)
                    soldier:setDirect(direct)
                    soldier.unSort = false
                end)
                sortDone = false
            end
        end
        if sortDone then
            if BC.canMove(team) then
                team:setState(ETeamStateMOVE)
            else
                team:setState(ETeamStateIDLE)
            end
        end
    end    
    team:onTickSkill()
end
-- 寻找目标
-- 没找到的回调, 找到攻击目标的回调, 找到警戒目标的回调用
function BattleLogic:findTarget(team, noneCallBack, attackCallBack, alertCallCack)
    local t1, t2 = self:getNearestTarget(team)
    if t1 == nil and t2 == nil then
        if noneCallBack then
            noneCallBack()
        end
    else
        if t2 ~= nil and BC.canAttack(team) then
            if attackCallBack then
                attackCallBack()
            else
                -- 确定双方的攻击位置以及设置攻击目标
                self:attackToTarget(team, t2)
            end
        elseif t1 ~= nil then
            if BC.canMove(team) then
                if alertCallCack then
                    alertCallCack()
                else
                    self:moveToTarget(team, t1)
                end
            end
        else
            if noneCallBack then
                noneCallBack()
            end
        end
    end
end

-- 宏观攻击距离按照格子算
local sqrt = math.sqrt
local ETeamStateDIE = ETeamState.DIE
function BattleLogic:getNearestTarget(team)
    local rush = (team.rush == 2)
    local range = (team.rush == 3)
    local near = (team.rush == 4) -- 就近找目标
    local list
    local target, d
    local x, y = team.x, team.y
    local camp = 3 - team.camp -- 敌对阵营
    local row = team.row
    local rowTeam = self._rowTeam[camp]
    local moveType = team.moveType
    if near then
        -- 特殊, 云中城专用
        target, d = self:getNearestTeam(x, y, self._teams[camp], moveType)
        if self:getTeamDis(team, target) < team.attackArea + 0.00000001 then
            return nil, target
        else
            return target, nil
        end
    elseif range or (not rush and team.hasTargeted) then
        -- 远程方阵, 先判断攻击范围内有没有敌人
        target, d = self:getNearestTeam(x, y, self._teams[camp], moveType)
        if self:getTeamDis(team, target) < team.attackArea + 0.00000001 then
            return nil, target
        end
    end
    -- 找出对面行最近的人
    target = self:getRowNearestTeam(rowTeam[row], camp, moveType, true)
    if target then
        if self:getTeamDis(team, target) < team.attackArea + 0.00000001 then
            return nil, target
        else
            return target, nil
        end
    else
        if range then
            -- 全局找最近单位
            target, d = self:getNearestTeam(x, y, self._teams[camp], moveType)
            return target, nil
        else
            -- 对面行无人, 从其他行找目标
            list = {}
            if rush then
                -- 如果是rush 先找所有远程
                for i = 1, #rowTeam do
                    if i ~= row then
                        target = self:getRowNearestTeam(rowTeam[i], camp, moveType, not rush, true)
                        if target then
                            list[#list + 1] = target
                        end
                    end
                end
            end
            -- 如果没找到或者不是rush在无差别查找
            if #list == 0 then
                for i = 1, #rowTeam do
                    if i ~= row then
                        target = self:getRowNearestTeam(rowTeam[i], camp, moveType, not rush)
                        if target then
                            list[#list + 1] = target
                        end
                    end
                end
            end
            if rush then
                target, d = self:getNearestTeam_rush(x, y, list, moveType)
            else
                target, d = self:getNearestTeam(x, y, list, moveType)
            end
            if self:getTeamDis(team, target) < team.attackArea + 0.00000001 then
                return nil, target
            else
                return target, nil
            end
        end
    end
end
-- 找到行优先目标
-- front 是否从前面找
-- onlyRange 是否只找远程
function BattleLogic:getRowNearestTeam(rowTeam, camp, moveType, front, onlyRange)
    -- 是否找最小的
    local min
    if camp == 1 then
        min = not front
    else
        min = front
    end
    -- 是否找最小的
    local team
    local target = nil
    if self._enableFindTargetBlind then
        if onlyRange then
            if min then
                local minX = 9999999
                for i = 1, #rowTeam do
                    team = rowTeam[i]
                    if team.canDestroy and team.state ~= ETeamStateDIE and not team.isMelee and team.blind_MoveType[moveType] == nil then
                        if team.x < minX - 0.00000001 then
                            minX = team.x
                            target = team
                        end
                    end
                end
            else
                local maxX = 0
                for i = 1, #rowTeam do
                    team = rowTeam[i]
                    if team.canDestroy and team.state ~= ETeamStateDIE and not team.isMelee and team.blind_MoveType[moveType] == nil then
                        if team.x > maxX + 0.00000001 then
                            maxX = team.x
                            target = team
                        end
                    end
                end
            end
        else
            if min then
                local minX = 9999999
                for i = 1, #rowTeam do
                    team = rowTeam[i]
                    if team.canDestroy and team.state ~= ETeamStateDIE and team.blind_MoveType[moveType] == nil then
                        if team.x < minX - 0.00000001 then
                            minX = team.x
                            target = team
                        end
                    end
                end
            else
                local maxX = 0
                for i = 1, #rowTeam do
                    team = rowTeam[i]
                    if team.canDestroy and team.state ~= ETeamStateDIE and team.blind_MoveType[moveType] == nil then
                        if team.x > maxX + 0.00000001 then
                            maxX = team.x
                            target = team
                        end
                    end
                end
            end
        end
    else
        if onlyRange then
            if min then
                local minX = 9999999
                for i = 1, #rowTeam do
                    team = rowTeam[i]
                    if team.canDestroy and team.state ~= ETeamStateDIE and not team.isMelee then
                        if team.x < minX - 0.00000001 then
                            minX = team.x
                            target = team
                        end
                    end
                end
            else
                local maxX = 0
                for i = 1, #rowTeam do
                    team = rowTeam[i]
                    if team.canDestroy and team.state ~= ETeamStateDIE and not team.isMelee then
                        if team.x > maxX + 0.00000001 then
                            maxX = team.x
                            target = team
                        end
                    end
                end
            end
        else
            if min then
                local minX = 9999999
                for i = 1, #rowTeam do
                    team = rowTeam[i]
                    if team.canDestroy and team.state ~= ETeamStateDIE then
                        if team.x < minX - 0.00000001 then
                            minX = team.x
                            target = team
                        end
                    end
                end
            else
                local maxX = 0
                for i = 1, #rowTeam do
                    team = rowTeam[i]
                    if team.canDestroy and team.state ~= ETeamStateDIE then
                        if team.x > maxX + 0.00000001 then
                            maxX = team.x
                            target = team
                        end
                    end
                end
            end
        end
    end
    return target
end
function BattleLogic:getNearestTeam(x, y, list, moveType)
    local d
    local minD = 99999999
    local target = nil
    local tx, ty
    local team
    if self._enableFindTargetBlind then
        for i = 1, #list do
            team = list[i]
            if team.canDestroy and team.state ~= ETeamStateDIE and team.blind_MoveType[moveType] == nil then
                tx, ty = team.x, team.y
                d = (tx - x) * (tx - x) + (ty - y) * (ty - y) * 4
                if d < minD - 0.00000001 then
                    minD = d
                    target = team
                end
            end
        end
    else
        for i = 1, #list do
            team = list[i]
            if team.canDestroy and team.state ~= ETeamStateDIE then
                tx, ty = team.x, team.y
                d = (tx - x) * (tx - x) + (ty - y) * (ty - y) * 4
                if d < minD - 0.00000001 then
                    minD = d
                    target = team
                end
            end
        end
    end
    return target, sqrt(minD)
end
function BattleLogic:getNearestTeam_rush(x, y, list, moveType)
    local d
    local minD = 99999999
    local target = nil
    local tx, ty
    local team
    if self._enableFindTargetBlind then
        for i = 1, #list do
            team = list[i]
            if team.canDestroy and team.state ~= ETeamStateDIE and team.blind_MoveType[moveType] == nil then
                tx, ty = team.x, team.y
                d = (tx - x) * (tx - x) + (ty - y) * (ty - y) * 25
                if d < minD - 0.00000001 then
                    minD = d
                    target = team
                end
            end
        end
    else
        for i = 1, #list do
            team = list[i]
            if team.canDestroy and team.state ~= ETeamStateDIE then
                tx, ty = team.x, team.y
                d = (tx - x) * (tx - x) + (ty - y) * (ty - y) * 25
                if d < minD - 0.00000001 then
                    minD = d
                    target = team
                end
            end
        end
    end
    return target, sqrt(minD)
end
-- 范围内是否有某阵营方阵
function BattleLogic:rangeHasTeam(x, y, dis, camp)
    local list = self._teams[camp]
    local d = dis * dis
    for i = 1, #list do
        if (list.x - x) * (list.x - x) + (list.y - y) * (list.y - y) < d + 0.00000001 then
            return true
        end
    end
    return false
end

-- 计算两个方阵的距离
function BattleLogic:getTeamDis(team1, team2)
    if team2 == nil then
        return 999999
    end
    local dx, dy
    if team1.x > team2.x + 0.00000001 then
        dx = team1.minx - team2.maxx
    else
        dx = team2.minx - team1.maxx
    end
    if team1.y > team2.y + 0.00000001 then
        dy = team1.miny - team2.maxy
    else
        dy = team2.miny - team1.maxy
    end
    if dx < 0 then
        dx = 0
    end
    if dy < 0 then
        dy = 0
    end
    -- 距离应该减去 占地面积
    local dis = sqrt(dx * dx + dy * dy) - team2.radius
    if dis < 0 then 
        dis = 0
    end
    return dis
end

-- 向目标移动
function BattleLogic:moveToTarget(team, target)
    team:setState(ETeamState.MOVE)
    team.moveTargetT = target
    local dx = abs(target.x - team.x)
    local dy = abs(target.y - team.y)
    if dx > 2 * dy then
        team:moveTo(target.x, team.y, team:getMSpeed())
    else
        team:moveTo(target.x, target.y, team:getMSpeed())
    end
    if not team.patrol then
        local dis = dx * dx + dy * dy
        team.patrol = dis < team.patrolArea + 0.00000001
        team.speedDirty = true
        if team.patrol and team.runart == 1 then
            -- 冲刺光影
            team:showRunArt()
        end
    end
end

-- 和目标展开战斗
function BattleLogic:attackToTarget(team, target)
    if target.state == ETeamStateDIE then 
        return 
    end
    if team.patrol then
        team.patrol = false
        team.speedDirty = true
    else
        if team.runart == 1 then
            -- 冲刺光影
            team:showRunArt()
        end
    end
    local teamList = team.aliveSoldier
    local teamNumber = #teamList
    for i = 1, teamNumber do
        teamList[i]:setTargetS(nil)
    end
    team:setState(ETeamStateATTACK)
    team.moveTargetT = nil
    team:stopMove(false)
    team:setTargetT(target)
    if target.state ~= ETeamStateATTACK and team.canDestroy then
        -- 对方没在战斗中
        local x1, y1 = team.x, team.y
        local x2, y2 = target.x, target.y
        local Farthest = (self:getTeamDis(target, team) > target.attackArea + 0.00000001)
        local teamIsMelee = team.isMelee
        local targetIsMelee = target.isMelee
        if not Farthest and target.canTaunt then
            -- 我方比对方射程近, 强制拉对方进入战斗
            target:setState(ETeamStateATTACK)
            target:stopMove()
            target:setTargetT(team, true)
        end
        if not Farthest and target.canTaunt and teamIsMelee and targetIsMelee then
            -- 双方都是近战
            --------------
            -- 双方约战 --
            --------------
            local teamList = team.aliveSoldier
            local targetList = target.aliveSoldier
            local teamNumber = #teamList
            local targetNumber = #targetList
            local atkPt = math.min(teamNumber, targetNumber)
            -- 防守方摆阵
            if team.volume < 5 and target.volume < 5 then
                -- 给对方近战分配攻击站位：方阵里的所有士兵
                target:setMeleeFightPt()
                local offsetX = team.radius + target.radius
                if x1 < x2 then
                    offsetX = -offsetX
                end

                -- 匹配的小兵 互殴
                local obj1, obj2
                if teamNumber > 0 and targetNumber > 0 then
                    for i = 1, atkPt do
                        obj1 = teamList[i]
                        obj2 = targetList[i]
                        -- 设置士兵的攻击目标，如果是近战兵团没有战位就分配战位
                        obj1:setTargetS(obj2)   
                        obj2:setTargetS(obj1)
                        -- 己方士兵的攻击位置
                        obj1.fightPtX = obj2.fightPtX + offsetX
                        obj1.fightPtY = obj2.fightPtY
                    end
                end
                -- 整个兵团的攻击位置
                team.fight_PtX = target.fight_PtX + offsetX
                team.fight_PtY = target.fight_PtY
            end

            -- team ====
            -- 为所有没有目标的小兵分配目标
            local index = 1
            for i = 1, teamNumber do
                local obj1 = teamList[i]
                if obj1.targetS == nil and not obj1.isMove then
                    local obj2 = targetList[index]
                    index = index + 1
                    if index > targetNumber then
                        index = 1
                    end
                    obj1:setTargetS(obj2)
                end
            end
            -- =========
            -- target ==
            index = 1
            for i = 1, targetNumber do
                local obj1 = targetList[i]
                if obj1.targetS == nil and not obj1.isMove then
                    local obj2 = teamList[index]
                    index = index + 1
                    if index > teamNumber then
                        index = 1
                    end
                    obj1:setTargetS(obj2)
                end  
            end
        else
            -- 近打远 远打远 远打近
            -- 至少有一方是远程
            -- 先分配目标
            local teamList = team.aliveSoldier
            local targetList = target.aliveSoldier
            local teamNumber = #teamList
            local targetNumber = #targetList
            local index = 1
            for i = 1, teamNumber do
                local obj1 = teamList[i]
                if obj1.targetS == nil then
                    local obj2 = targetList[index]
                    index = index + 1
                    if index > targetNumber then
                        index = 1
                    end
                    -- 远战兵团这个方法里只设置了攻击目标 兵没有设置战位
                    obj1:setTargetS(obj2)
                end
            end
            if not teamIsMelee then
                -- 设置远程兵团的攻击战位
                team:setRangeFightPt()
            end
            --给未分配的士兵分配目标
            if not Farthest and target.canTaunt then
                local index = 1
                for i = 1, targetNumber do
                    local obj1 = targetList[i]
                    if obj1.targetS == nil then
                        local obj2 = teamList[index]
                        index = index + 1
                        if index > teamNumber then
                            index = 1
                        end
                        obj1:setTargetS(obj2)
                    end
                end
                if not targetIsMelee then
                    target:setRangeFightPt()
                end
            end
        end
        -- =========
    else
        -- 对方在战斗中
        -------------
        -- 单方进攻 -- 只给已方兵团设置攻击目标
        -------------
        local teamList = team.aliveSoldier
        local targetList = target.aliveSoldier
        local teamNumber = #teamList
        local targetNumber = #targetList

        local index = 1
        for i = 1, teamNumber do
            local obj1 = teamList[i]
            if obj1.targetS == nil then
                local obj2 = targetList[index]
                index = index + 1
                if index > targetNumber then
                    index = 1
                end
                obj1:setTargetS(obj2)
            end
        end
        if not team.isMelee then
            team:setRangeFightPt()
        end
    end
end
-- 战斗状态更新
local BATTLE_CELL_SIZE = BC.BATTLE_CELL_SIZE
--[[
    兵团攻击结束：
    1 目标不存在
    2 目标兵团是己方兵团
    3 目标兵团死亡
    4 目标与我方距离超过范围
    5 目标脱离战斗
    6 双方都是近战兵团：我打他，他战斗结束后，选择了一个远程

    士兵打完一场战斗后，调用BattleLogic:teamAttackOver方法，
    里面清除站位以及设置成移动状态或者初始化状态，然后BattleLogic:updateTeam方法里又会根据兵团的状态去寻找目标
]]
function BattleLogic:attackUpdate(team)
    local target = team.targetT
    if target == nil then
        self:teamAttackOver(team)
        return
    end
    if target.camp == team.camp then
        team:setTargetT(nil)
        self:teamAttackOver(team)
        return  
    end
    local isMelee = team.isMelee
    -- 目标方阵死亡
    if target.state == ETeamStateDIE then
        team:onTargetDieSkill(target.original)
        team:setTargetT(nil)
        self:teamAttackOver(team)
        return
    end
    local x1, y1 = team.x, team.y
    local x2, y2 = target.x, target.y

    if self:getTeamDis(team, target) > team.attackArea + 80.0000000001 then
        self:teamAttackOver(team)
        return
    end
    -- 目标脱离战斗
    local needReturn = false
    if isMelee and target.state ~= ETeamStateATTACK then
        if self:getTeamDis(target, team) < target.attackArea + 0.00000001 and target.canTaunt then
            self:attackToTarget(target, team)
            needReturn = true
        end
    end

    local newTT = target.targetT
    if isMelee and target.isMelee then
        if newTT == team then
            if not target.hasMeleeFightPt and not team.hasMeleeFightPt then
                if team.volume < 5 and target.volume < 5 and team.row == target.row then
                    target:setMeleeFightPt()
                end
            end
        elseif newTT ~= nil then
            -- 都是近战，我打他，他战斗结束后，选择了一个远程
            local oldTT = team.targetTTarget
            if oldTT and oldTT ~= newTT and not newTT.isMelee then
                self:teamAttackOver(team)
                return
            end
        end
    end

    if needReturn then return end

    if target.beatPosDirty and team.beatIdx == 2 then
        -- 1号位置的人没了, 2号位置补上去
        target.beatPosDirty = false
        team:setTargetT(target)
    end

    local teamList = team.aliveSoldier
    local targetList = target.aliveSoldier
    local teamNumber = #teamList
    local targetNumber = #targetList
    -- 更新计算受击者数量
    -- 为所有没有目标的小兵分配目标
    local attacker
    for i = 1, teamNumber do
        local obj1 = teamList[i]
        if obj1.targetS == nil then
            attacker = obj1:getAttacker()
            if attacker ~= nil then
                obj1:setTargetS(attacker)
            else
                local obj2 
                if i > targetNumber then
                    obj2 = targetList[random(targetNumber)] 
                else
                    obj2 = targetList[i]
                end
                obj1:setTargetS(obj2)
            end
        end
    end
end

-- 战斗完毕
function BattleLogic:teamAttackOver(team)
    team.hasMeleeFightPt = false
    team.fight_PtX = nil
    team.fight_PtY = nil
    team.isMeleeEx = nil
    team.moveTargetT = nil
    local teamList = team.aliveSoldier
    local soldier
    local clearFightPt = false
    if team.isMelee then
        -- 近战士兵攻击结束一定会清除战位
        clearFightPt = true
    else
        local lastCount = team.setRFPSoldierCount
        if lastCount then
            local count = #team.aliveSoldier
            if count < lastCount * 0.5 then 
                -- 人数少于原来的1/2，整队
                clearFightPt = true
            elseif count > lastCount then
                -- 人数比原来的人多了，整队
                clearFightPt = true
                team.setRFPSoldierCount = count
            end
        end
    end

    if clearFightPt then
        for i = 1, #teamList do
            soldier = teamList[i]
            soldier:setTargetS(nil)
            soldier.fightPtX, soldier.fightPtY = nil, nil
        end
    else
        for i = 1, #teamList do
            soldier = teamList[i]
            soldier:setTargetS(nil) 
        end
    end

    if self:teamAttackOverEx(team) then
        return 
    end
    team:stopMove(true)
    if BC.canMove(team) then
        team:setState(ETeamStateMOVE)
    else
        team:setState(ETeamStateIDLE)
    end
end

-- 战斗结束, 整顿
-- over 战斗结束整顿, 不再继续寻找目标
function BattleLogic:teamSort(team, over)
    if team.state == ETeamStateSORT then
        return
    end

    local teamList = team.aliveSoldier
    local teamNumber = #teamList
    for i = 1, teamNumber do
        teamList[i]:setTargetS(nil)
    end

    if over then

    else
        local t1, d1, t2, d2 = self:getNearestTarget(team)
        if t2 ~= nil and d2 < team.attackArea + 0.00000001 and BC.canAttack(team) then
            if BC.canMove(team) then

                self:attackToTarget(team, t2)
                return
            else
                team:setState(ETeamStateIDLE)
            end
        end
    end

    team:stopMove(true)
    team:setState(ETeamStateSORT)

    local camp = team.camp

    local _x, _y = team.x, team.y
    team.sortx, team.sorty = _x, _y
    local teamList = team.aliveSoldier
    local teamNumber = #teamList
    local _soldier = nil
    local getPosInFormation = BC.getPosInFormation
    local volume = team.volume
    for i = 1, teamNumber do
        local x, y = getPosInFormation(_x, _y, i, volume, camp)
        _soldier = teamList[i]
        _soldier:setOffsetPos(x - _x, y - _y)
        _soldier.unSort = true
    end    
end

function BattleLogic:teamOver(team, noResetAttr)
    local teamList = team.aliveSoldier
    for i = 1, #teamList do
        if teamList[i] then
            teamList[i]:clearBuff(noResetAttr)
        end
    end
end

-- attackTeam的第一次攻击之后2秒, 判断是否需要转火
local sqrt = math.sqrt
function BattleLogic:teamTurnFire(team, attackTeam)
    -- 攻击方阵的目标仍需是该team
    if attackTeam.targetT ~= team then return end
    -- team必须处于攻击状态
    if team.state ~= ETeamStateATTACK then return end
    -- team必须有目标
    if team.targetT == nil then return end

    local turnFire = false
    local x1, y1 = team.x, team.y
    local x2, y2 = team.targetT.x, team.targetT.y
    local x3, y3 = attackTeam.x, attackTeam.y
    -- 用来判断team是转火逻辑中的近战还是远程
    local dis1 = sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
    -- 用来判断attackTeam是转火逻辑中的近战还是远程
    local dis2 = sqrt((x1 - x3) * (x1 - x3) + (y1 - y3) * (y1 - y3))
    local _type = 0
    if dis1 <= 60 then
        -- team是近战
        -- team正在互殴
        if team.targetT.targetT == team then

        else
            if dis2 <= 60 then
                turnFire = true
                -- _type = 1
            end
        end
    else
        -- team是远程
        -- team正在互射
        if team.targetT.targetT == team then
            -- 如果attackTeam是近战就转火
            if dis2 <= 60 then
                turnFire = true
                -- _type = 2
            end
        else
            -- 单方射, 肯定转
            turnFire = true
            -- if dis2 <= 60 then
            --     _type = 3
            -- else
            --     _type = 4
            -- end
        end
    end

    if turnFire then
        -- 转火
        -- local str = ""
        -- if _type == 1 then
        --     str = "近转近"
        -- elseif _type == 2 then
        --     str = "远互殴, 转近"
        -- elseif _type == 3 then
        --     str = "远转近"
        -- else
        --     str = "远转远"
        -- end
        -- print(team.ID .. " => " .. attackTeam.ID, str, math.sqrt(dis1), math.sqrt(dis2))
        self:attackToTarget(team, attackTeam)
    end
end

-- 方阵复活
function BattleLogic:teamRevive(team, noAnim)
    local soldiers = team.soldier
    for i = 1, #soldiers do
        soldiers[i]:setRevive(noAnim)
    end
end

function BattleLogic:getDamageShareList(camp)
    return self._damageShareList[camp]
end

function BattleLogic:addDamageShareValue(camp, value)
    self._damageShareValue[camp] = self._damageShareValue[camp] + value 
end

function BattleLogic:onTeamDie(team)
    local camp = team.camp
    if team.original then
        self.teamCount[camp] = self.teamCount[camp] - 1
        self:_raceCountDec(camp, team.race1, team.race2)
        local class = team.classLabel
        self.classCount[camp][class] = self.classCount[camp][class] - 1
        if not BATTLE_PROC and not team.boss then
            local width, height = team.soldier[1]:getSize()
            self._control:onTeamDieOrRevive(team.ID, camp, true, width * 0.5 + 30, self.teamCount[camp] == 0)
        end
        if camp == 1 then
            self.originalDieCount = self.originalDieCount + 1
        end
    end
    self._teamDieCount[camp] = self._teamDieCount[camp] + 1
    self:onTeamDieEx(team)

    if not team.building then
        self._lastTeamCount[camp] = self._lastTeamCount[camp] - 1
    end
end

function BattleLogic:onTeamRevive(team)
    local camp = team.camp
    if team.original then
        self.teamCount[camp] = self.teamCount[camp] + 1
        self:_raceCountDec(camp, team.race1, team.race2)
        local class = team.classLabel
        self.classCount[camp][class] = self.classCount[camp][class] + 1
        if not BATTLE_PROC and not team.boss then
            self._control:onTeamDieOrRevive(team.ID, camp, false)
        end
        if camp == 1 then
            self.originalDieCount = self.originalDieCount - 1
        end
    end
    self._teamDieCount[camp] = self._teamDieCount[camp] - 1

    if not team.building then
        self._lastTeamCount[camp] = self._lastTeamCount[camp] + 1
    end
end

function BattleLogic:addReviveBuffAll(camp)
    local allReviveBuffs = self:getHero(camp).allReviveBuff
    if not (allReviveBuffs and #allReviveBuffs > 0) then return end
    local teams = self._teams[camp]
    if not teams then return end 
    local team, soldier, buff
    for bI = 1, #allReviveBuffs do
        for i = 1, #teams do
            team = teams[i]
            repeat
                if not team or team.state == ETeamStateDIE or team.building then break end
                for j = 1, #team.aliveSoldier do
                    soldier = team.aliveSoldier[j]
                    local buff = BC.initSoldierBuff(allReviveBuffs[bI], camp, soldier.caster, soldier)
                    soldier:addBuff(buff)
                end
            until true
        end
    end
end

function BattleLogic:onReviveBegin(camp)
    self._reviveCount[camp] = self._reviveCount[camp] + 1
end

function BattleLogic:onReviveEnd(camp, soldier)
    self._reviveCount[camp] = self._reviveCount[camp] - 1
end

function BattleLogic:getOriginalTeamId()
    local list = {{}, {}}
    local team
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if team.original then
            list[1][#list[1] + 1] = team
        else
            break
        end
    end
    for i = 1, #self._teams[2] do
        team = self._teams[2][i]
        if team.original then
            list[2][#list[2] + 1] = team
        else
            break
        end
    end
    return list
end

function BattleLogic:onSpeedChange(speed)
    objLayer:onSpeedChange(speed)
end

function BattleLogic:stopEffect(mc)
    objLayer:stopEffect(mc)
end

function BattleLogic:shake(type, strong)
    self._control:shake(type, strong)
end

function BattleLogic:siegeBroken()
    self._control:siegeBroken()
end

function BattleLogic:siegeHalf()
    self._control:siegeHalf()
end

-- 玩家伤害统计
function BattleLogic:playerSkillCount(index, value, value1, skillid, camp, sindex, dpsshow)
    local skillidStr = tostring(skillid)
    if value > 0 then
        local _v = self._playerHeal[camp][skillidStr]
        if _v then
            _v = _v + value
        else
            _v = value
        end
        self._playerHeal[camp][skillidStr] = _v
        -- print(1, value)
    elseif value < 0 then
        local _v = self._playerDamage[camp][skillidStr]
        if _v then
            -- edit by hxp : value为负值,存在时累计用加号
            _v = _v + value
        else
            _v = value
        end
        self._playerDamage[camp][skillidStr] = _v

        _v = self._playerDamage1[camp][skillidStr]
        if _v then
            -- edit by hxp : value1为正值,存在时累计用加号
            _v = _v + value1
        else
            _v = value1
        end
        self._playerDamage1[camp][skillidStr] = _v
        -- print(2, value)
    end
    if BATTLE_PROC then return end
    if not dpsshow then return end
    -- value负值是伤害, 正值是治疗 
    if self._playerSkillCountData[index] then
        local oldValue = self._playerSkillCountData[index].value
        local newValue = oldValue + value
        -- 判断是否进来的是相反数
        if (oldValue > 0 and value < 0) or (oldValue < 0 and value > 0) then
            if abs(value) <= abs(oldValue) then
                return
            else
                newValue = value
            end
        end
        self._playerSkillCountData[index].value = newValue
        self._control:playerSkillCount(camp, index, sindex, self._playerSkillCountData[index].icon, self._playerSkillCountData[index].skillD, oldValue, newValue)
    else
        local icon = tab.playerSkillEffect[skillid].art
        self._playerSkillCountData[index] = {value = value, icon = icon, skillD = tab.playerSkillEffect[skillid]}
        self._control:playerSkillCount(camp, index, sindex, icon, tab.playerSkillEffect[skillid], 0, value)
    end
end

-- 怪兽技能提示
function BattleLogic:pushSoldierSkillTip(bgType, iconName1, iconName2, subType, value)
    self._control:pushSoldierSkillTip(bgType, iconName1, iconName2, subType, value)
end

-- 方阵选择. 优先级>阵营>距离>编号
function BattleLogic:selectTeam(x, y)
    local list = {}
    local team, dis, data
    local minx, maxx, miny, maxy, d
    local w, h
    for i = 1, #self._updateList do
        team = self._updateList[i]
        w, h = team.soldier[1]:getSize()
        if team.state ~= ETeamStateDIE then
            minx, maxx, miny, maxy = team.minx, team.maxx, team.miny, team.maxy
            d = maxx - minx
            if d < w then
                d = (w - d) * 0.5
                maxx = maxx + d
                minx = minx - d
            end
            d = maxy - miny
            if d < h then
                d = (h - d) * 0.5
                maxy = maxy + 2 * d
                miny = miny
            end
            if minx <= x and x <= maxx and miny <= y and y <= maxy then
                dis = (team.x - x) * (team.x - x) + (team.y - y) * (team.y - y)
                data = {team = team, camp = team.camp, dis = dis, ID = team.ID, priority = 0}    
                if self._selectTeamList[team.ID] then
                    data.priority = self._selectTeamList[team.ID]
                end
                list[#list + 1] = data
            end
        end
    end

    self._selectTeamList = {}
    for i = 1, #list do
        self._selectTeamList[list[i].ID] = list[i].priority
    end
    local sortFunc = function(a, b) 
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            if a.camp ~= b.camp then
                return a.camp < b.camp
            else
                if a.dis ~= b.dis then
                    return a.dis < b.dis
                else
                    return a.ID < b.ID
                end
            end
        end
    end
    table.sort(list, sortFunc)
    if #list > 0 then
        list[1].priority = list[1].priority + 1
        self._selectTeam = list[1].team
        objLayer:setSelectTeam(self._selectTeam)
    else
        objLayer:setSelectTeam(nil)
    end
    self._selectTeamList = {}
    for i = 1, #list do
        self._selectTeamList[list[i].ID] = list[i].priority
    end

end

function BattleLogic:setCampBrightness(camp, value)
    objLayer:setCampBrightness(camp, value)
    if BC.jump then return end
    self:setCampBrightnessEx(camp, value)
end

function BattleLogic:getTeamDieByID(id)
    return self._allTeams[id].state == ETeamStateDIE
end

function BattleLogic:getLeftOriginalTeamCenterPoint()
    local x, y
    local team
    local minx, maxx, miny, maxy = 9999, 0, 9999, 0
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if team.original and team.state ~= ETeamStateDIE then
            x, y = team:getPos()
            if x < minx then minx = x end
            if x > maxx then maxx = x end
            if y < miny then miny = y end
            if y > maxy then maxy = y end
        end
    end
    return (minx + maxx) * 0.5, (miny + maxy) * 0.5
end
-- 获取己方方阵中心点
function BattleLogic:getLeftTeamCenterPoint(reverse)
    local x, y
    local team
    local minx, maxx, miny, maxy = 9999, 0, 9999, 0
    local camp = reverse and 2 or 1
    for i = 1, #self._teams[camp] do
        team = self._teams[camp][i]
        if team.canDestroy and team.state ~= ETeamStateDIE then
            x, y = team:getPos()
            if x < minx then minx = x end
            if x > maxx then maxx = x end
            if y < miny then miny = y end
            if y > maxy then maxy = y end
        end
    end
    local _x = (minx + maxx) * 0.5
    _x = reverse and MAX_SCENE_WIDTH_PIXEL - _x or _x
    return _x, (miny + maxy) * 0.5
end
-- 获取敌方方阵中心点
function BattleLogic:getRightTeamCenterPoint(reverse)
    local x, y
    local team
    local minx, maxx, miny, maxy = 9999, 0, 9999, 0
    local camp = reverse and 1 or 2
    for i = 1, #self._teams[camp] do
        team = self._teams[camp][i]
        if team.canDestroy and team.state ~= ETeamStateDIE then
            x, y = team:getPos()
            if x < minx then minx = x end
            if x > maxx then maxx = x end
            if y < miny then miny = y end
            if y > maxy then maxy = y end
        end
    end
    local _x = (minx + maxx) * 0.5
    _x = reverse and MAX_SCENE_WIDTH_PIXEL - _x or _x
    return _x, (miny + maxy) * 0.5
end

function BattleLogic:getAllTeamCenterPoint(reverse)
    local x, y
    local team
    local minx, maxx, miny, maxy = 9999, 0, 9999, 0
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if team.canDestroy and team.state ~= ETeamStateDIE then
            x, y = team:getPos()
            if x < minx then minx = x end
            if x > maxx then maxx = x end
            if y < miny then miny = y end
            if y > maxy then maxy = y end
        end
    end
    for i = 1, #self._teams[2] do
        team = self._teams[2][i]
        if team.canDestroy and team.state ~= ETeamStateDIE then
            x, y = team:getPos()
            if x < minx then minx = x end
            if x > maxx then maxx = x end
            if y < miny then miny = y end
            if y > maxy then maxy = y end
        end
    end
    local _x = (minx + maxx) * 0.5
    _x = reverse and MAX_SCENE_WIDTH_PIXEL - _x or _x
    return _x, (miny + maxy) * 0.5
end

-- 场景坐标转屏幕坐标
function BattleLogic:convertToScreenPt(x, y)
    return self._control:convertToScreenPt(x, y)
end

function BattleLogic:getTeamScreenPt(id)
    if BC_reverse then
        return self._control:convertToScreenPt(MAX_SCENE_WIDTH_PIXEL - self._allTeams[id].x, self._allTeams[id].y)
    else
        return self._control:convertToScreenPt(self._allTeams[id].x, self._allTeams[id].y)
    end
end

function BattleLogic:getTeamByCampAnaIndex(camp, index)
    return self._teams[camp][index]
end

function BattleLogic:getTeamByCampAnaId(camp, id)
    for i = 1, #self._teams[camp] do
        if self._teams[camp][i].D["id"] == id then
            return self._teams[camp][i]
        end
    end
end

-- 获取屏外敌人列表
function BattleLogic:getOutOfScreenEnemy()
    local team, x
    local list = {}
    local camp = BC_reverse and 1 or 2
    for i = 1, #self._teams[camp] do
        team = self._teams[camp][i]
        x = team:isOutScreen(BC_reverse, MAX_SCENE_WIDTH_PIXEL)
        if x > 0 then
            list[team.ID] = {x, team.screenY}
        end
    end
    return list
end

-- 会影响战斗结果, 慎用
-- 战斗逻辑暂停, 动作不停
function BattleLogic:battlePause()
    self.battleState = EState.INTO
    -- 移动的人停止移动
    local team, soldier
    for i = 1, #self._updateList do
        team = self._updateList[i]
        for k = 1, #team.aliveSoldier do
            soldier = team.aliveSoldier[k]
            if soldier.isMove then
                soldier:stopMove()
            end
        end
    end
    self._battlePauseTick = BC.BATTLE_TICK
end

-- 战斗逻辑恢复
function BattleLogic:battleResume()
    self.battleState = EStateING
    local dt = BC.BATTLE_TICK - self._battlePauseTick
    self.battleBeginTick = self.battleBeginTick + dt
    self._battlePauseTick = nil

    local team, soldier
    for i = 1, #self._updateList do
        team = self._updateList[i]
        for k = 1, #team.aliveSoldier do
            soldier = team.aliveSoldier[k]
            soldier:resetCheckTick(-dt)
        end
    end
end

function BattleLogic:guideAction()

end

function BattleLogic:doSkillUnlock(layer, allMpBg, index, callback)
    if index == 0 then
        -- 解锁两倍速
        local mc = mcMgr:createViewMC("diguang_lianmengjihuo", false, true)         
        mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        layer:addChild(mc)
        local label = cc.Label:createWithTTF(lang("OPEN_SYSTEM_NEW"), UIUtils.ttfName, 40)
        label:setColor(cc.c3b(255, 243, 174))
        label:enable2Color(1, cc.c4b(251, 197, 67, 255))
        label:enableOutline(cc.c4b(0, 0, 0, 255), 3)
        label:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 100)
        layer:addChild(label)
        label:setScale(2.0)
        label:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.0), cc.DelayTime:create(2), cc.ScaleTo:create(0.2, 0), cc.RemoveSelf:create(true)))
        local noticeName = cc.Label:createWithTTF("战斗二倍速", UIUtils.ttfName, 30)
        noticeName:setColor(cc.c3b(255,249,181))
        noticeName:enable2Color(1, cc.c4b(233, 160, 0, 255))
        noticeName:enableOutline(cc.c4b(101, 36, 0, 255), 2)
        noticeName:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 70)
        layer:addChild(noticeName, 2)
        noticeName:setOpacity(0)
        noticeName:runAction(cc.Sequence:create(cc.FadeIn:create(0.1), cc.DelayTime:create(2), cc.FadeOut:create(0.2)))
        local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. "gn_jiasu.png")
        icon:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        layer:addChild(icon)
        icon:setScale(0)
        icon:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.2), cc.ScaleTo:create(0.05, 1.0), cc.DelayTime:create(2), 
            cc.MoveTo:create(0.5, cc.p(134, 42)), 
            cc.FadeOut:create(0.3), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
            if callback then
                callback()
            end
        end), cc.RemoveSelf:create(true)))
    else
        if 7 == index then
            -- 解锁法术刻印被动技能
            ScheduleMgr:delayCall(29 * 50, self, function()
                self:initBattleHeroSkillBookPassiveSkill(1, true)
                local skillBookPassiveIcon = self._skillBookPassiveIcon[1]
                if not skillBookPassiveIcon then return end
                local destX = skillBookPassiveIcon:getPositionX()
                local destY = skillBookPassiveIcon:getPositionY()
                skillBookPassiveIcon:setVisible(false)
                skillBookPassiveIcon:setScale(1.0)
                local mc = mcMgr:createViewMC("start1_skillunlock", false, true)
                mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 10)
                layer:addChild(mc)
                audioMgr:playSound("SpellUnlock_1")
                self:shake(1)
                skillBookPassiveIcon:setVisible(true)
                skillBookPassiveIcon:setPosition(skillBookPassiveIcon:getParent():convertToNodeSpace(cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)))
                ScheduleMgr:delayCall(500, self, function()
                    skillBookPassiveIcon:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(destX, destY)), 1), cc.ScaleTo:create(0.5, 0.55)))
                end)
                ScheduleMgr:delayCall(1100, self, function()
                    audioMgr:playSound("SpellUnlock_2")
                    local mc = mcMgr:createViewMC("over_skillunlock", false, true)
                    mc:setPosition(skillBookPassiveIcon:getContentSize().width * 0.5, 40)
                    skillBookPassiveIcon:addChild(mc, -1)
                end)

                ScheduleMgr:delayCall(1300, self, function()
                    if callback then
                        callback()
                    end
                end)
            end)
        else
            -- 解锁技能
            if index == 6 then
                -- 解锁法术刻印技能
                for i = 1, 6 do
                    if self._skillIcons[i] and self._skillIcons[i].count:isVisible() then
                        index = i
                        break
                    end
                end      
            end

            local max = nil
            for i = 6, 1, -1 do
                if self._skillIcons[i] then
                    max = i
                    break
                end
            end
            if self._skillIcons[index] == nil then
                index = max
            end
            for i = 1, 6 do
                if self._skillIcons[i] then
                    self._skillIcons[i].destX = self._skillIcons[i]:getPositionX()
                    self._skillIcons[i].destY = self._skillIcons[i]:getPositionY()
                end
            end

            local scount = 0
            for i = 1, 6 do
                if self._skillIcons[i] then
                    scount = scount + 1
                end
            end
            local icon_inv
            local icon_begin
            if scount <= 5 then
                icon_inv = BattleUtils.SKILL_ICON_INV_X_ORI
                icon_begin = BattleUtils.SKILL_ICON_BEGIN_X_ORI
            else
                icon_inv = BattleUtils.SKILL_ICON_INV_X
                icon_begin = BattleUtils.SKILL_ICON_BEGIN_X
            end

            allMpBg.destX = allMpBg:getPositionX()
            local beginX = icon_begin
            for i = 4, 1, -1 do
                if self._skillIcons[i] and i ~= index then
                    self._skillIcons[i]:setPositionX(beginX)
                    beginX = beginX - icon_inv
                end
            end
            for i = 5, #self._skillIcons do 
                if self._skillIcons[i] and i ~= index then
                    self._skillIcons[i]:setPositionX(beginX)
                    beginX = beginX - icon_inv
                end
            end
            allMpBg:setPositionX(beginX + 56)
            if self._skillIcons[index] then
                self._skillIcons[index]:setVisible(false)
            end

            local mc = mcMgr:createViewMC("start1_skillunlock", false, true)
            -- local mc = mcMgr:createViewMC("start"..index.."_skillunlock", false, true)
            mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 10)
            layer:addChild(mc)
            audioMgr:playSound("SpellUnlock_1")
            ScheduleMgr:delayCall(29 * 50, self, function()
                self:shake(1)
                self._skillIcons[index]:setVisible(true)
                local scale = self._skillIcons[index]:getScale()
                self._skillIcons[index]:setPosition(self._skillIcons[index]:getParent():convertToNodeSpace(cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)))
                self._skillIcons[index]:setPositionX(self._skillIcons[index]:getPositionX() - self._skillIcons[index]:getContentSize().width * 0.5 * scale)
                self._skillIcons[index]:setPositionY(self._skillIcons[index]:getPositionY() - self._skillIcons[index]:getContentSize().height * 0.5 * scale)
                ScheduleMgr:delayCall(500, self, function()
                    for i = 1, 6 do
                        if self._skillIcons[i] and i ~= index then
                            self._skillIcons[i]:runAction(cc.MoveTo:create(0.2, cc.p(self._skillIcons[i].destX, self._skillIcons[i].destY)))
                        end
                    end
                    allMpBg:runAction(cc.MoveTo:create(0.2, cc.p(allMpBg.destX, allMpBg:getPositionY())))
                end)
                ScheduleMgr:delayCall(500, self, function()
                    self._skillIcons[index]:runAction(cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(self._skillIcons[index].destX, self._skillIcons[index].destY)), 1))
                end)
                ScheduleMgr:delayCall(1100, self, function()
                    audioMgr:playSound("SpellUnlock_2")
                    local mc = mcMgr:createViewMC("over_skillunlock", false, true)
                    mc:setPosition(self._skillIcons[index]:getContentSize().width * 0.5, 40)
                    self._skillIcons[index]:addChild(mc, -1)
                end)
                ScheduleMgr:delayCall(1300, self, function()
                    if callback then
                        callback()
                    end
                end)
            end)
        end
    end
end

-- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG

function BattleLogic:initTeamDebugLabel(view)
    self._debugLabel = {{}, {}}
    for i = 1, #self._teams[1] do
        local label = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
        label:setColor(cc.c3b(50, 255, 255))
        label:enableShadow(cc.c4b(0, 0, 0, 255))
        label:setAnchorPoint(0, 0.5)
        label:setPosition(20, 460 - (i - 1) * 20)
        view:addChild(label)
        self._debugLabel[1][i] = label
    end
    for i = 1, #self._teams[2] do
        local label = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
        label:setColor(cc.c3b(255, 50, 50))
        label:enableShadow(cc.c4b(0, 0, 0, 255))
        label:setAnchorPoint(1, 0.5)
        label:setPosition(MAX_SCREEN_WIDTH - 20, 460 - (i - 1) * 20)
        view:addChild(label)
        self._debugLabel[2][i] = label
    end
end

function BattleLogic:clearTeamDebugLabel()
    if self._debugLabel == nil then return end
    for i = 1, #self._debugLabel[1] do
        self._debugLabel[1][i]:removeFromParent()
    end
    for i = 1, #self._debugLabel[2] do
        self._debugLabel[2][i]:removeFromParent()
    end
    self._debugLabel = nil
end

function BattleLogic:updateTeamDebugLabel()
    if self._debugLabel == nil then
        self:initTeamDebugLabel(self._control._rootLayer)
    end
    local view = self._control._rootLayer
    if #self._debugLabel[1] ~= #self._teams[1] then
        local d = #self._teams[1] - #self._debugLabel[1]
        local _begin = #self._debugLabel[1] + 1
        local _end = #self._teams[1]
        for i = _begin, _end do
            local label = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
            label:setColor(cc.c3b(50, 255, 255))
            label:enableShadow(cc.c4b(0, 0, 0, 255))
            label:setAnchorPoint(0, 0.5)
            label:setPosition(20, 460 - (i - 1) * 20)
            view:addChild(label)
            self._debugLabel[1][i] = label    
        end
    end
    if #self._debugLabel[2] ~= #self._teams[2] then
        local d = #self._teams[2] - #self._debugLabel[2]
        local _begin = #self._debugLabel[2] + 1
        local _end = #self._teams[2]
        for i = _begin, _end do
            local label = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
            label:setColor(cc.c3b(255, 50, 50))
            label:enableShadow(cc.c4b(0, 0, 0, 255))
            label:setAnchorPoint(1, 0.5)
            label:setPosition(MAX_SCREEN_WIDTH - 20, 460 - (i - 1) * 20)
            view:addChild(label)
            self._debugLabel[2][i] = label  
        end
    end
    for i = 1, #self._debugLabel[1] do
        self._debugLabel[1][i]:setString(self._teams[1][i].ID .. " " .. 
            self._teams[1][i].shiqi .. "_" .. self._teams[1][i].shiqiValue .. " " .. 
            self._teams[1][i].curHP .. "/" .. self._teams[1][i].maxHP)
    end
    for i = 1, #self._debugLabel[2] do
        self._debugLabel[2][i]:setString(self._teams[2][i].curHP .. "/" .. self._teams[2][i].maxHP  .. " " .. 
            self._teams[2][i].shiqi .. "_" .. self._teams[2][i].shiqiValue .. " " .. 
            self._teams[2][i].ID)
    end
end

-- 检查战中数据是否有被修改的痕迹
function BattleLogic:checkData()
    local ATTR_Atk = BattleUtils.ATTR_Atk
    local ATTR_COUNT = BattleUtils.ATTR_COUNT
    local team, soldier, baseSum, attrSum, atkSpeedCheck
    for i = 1, #self._updateList do
        team = self._updateList[i]
        for k = 1, #team.soldier do
            soldier = team.soldier[k]
            if soldier.baseSum then
                baseSum = 0
                local _baseAttr = soldier.baseAttr
                for i = ATTR_Atk, ATTR_COUNT do
                    baseSum = baseSum + _baseAttr[i]
                end
                if abs(baseSum - soldier.baseSum) > 0.001 then
                    return {soldier.ID, _baseAttr, soldier.attr}
                end
            end
            if soldier.attrSum then
                attrSum = 0
                local _attr = soldier.attr
                for i = ATTR_Atk, ATTR_COUNT do
                    attrSum = attrSum + _attr[i]
                end
                attrSum = attrSum + soldier.atk
                if abs(attrSum - soldier.attrSum) > 0.001 then
                    return {soldier.ID, soldier.baseAttr, soldier.attr}
                end
            end
            -- 检查攻速
            if soldier.__atkSpeedCheck then
                atkSpeedCheck = soldier.atkspeed * soldier.atkInv * 3
                if abs(atkSpeedCheck - soldier.__atkSpeedCheck) > 0.001 then
                    return {soldier.ID, soldier.atkspeed, soldier.atkInv}
                end
            end
        end
    end
    -- 检查血量
    local teams = self._teams[1]
    local team, soldier
    local hp1, maxhp1 = 0, 0
    for i = 1, #teams do
        team = teams[i]
        if not team.building then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                hp1 = hp1 + soldier.HP
                maxhp1 = maxhp1 + soldier.maxHP
            end
        end
    end
    print(1, hp1, maxhp1, self._HP[1] + self._summonHP[1], self._MaxHP[1] + self._summonMaxHP[1])
    local teams = self._teams[2]
    local hp2, maxhp2 = 0, 0
    for i = 1, #teams do
        team = teams[i]
        if not team.building then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                hp2 = hp2 + soldier.HP
                maxhp2 = maxhp2 + soldier.maxHP
            end
        end
    end
    print(2, hp2, maxhp2, self._HP[2] + self._summonHP[2], self._MaxHP[2] + self._summonMaxHP[2])
    if abs(hp1 - (self._HP[1] + self._summonHP[1])) > 0.0001 or 
        abs(maxhp1 - (self._MaxHP[1] + self._summonMaxHP[1])) > 0.0001 or
        abs(hp2 - (self._HP[2] + self._summonHP[2])) > 0.0001 or
        abs(maxhp2- (self._MaxHP[2] + self._summonMaxHP[2])) > 0.0001 then
        return {hp1, maxhp1, self._HP[1] + self._summonHP[1], self._MaxHP[1] + self._summonMaxHP[1], hp2, maxhp2, self._HP[2] + self._summonHP[2], self._MaxHP[2] + self._summonMaxHP[2]}
    end
end

-- 检查时间
function BattleLogic:checkTime()
    if self.battleTime then
        local value1 = BC.frameInv * self.battleFrameCount
        local value2 = self.battleTime
        if math.abs(value1 - value2) > 0.001 then
            return {battleFrameCount = self.battleFrameCount, battleTime = self.battleTime, frameInv = BC.frameInv}
        end
    end
end

function BattleLogic.dtor()
    abs = nil
    ActionValue = nil
    BATTLE_CELL_SIZE = nil
    Battle_Delta = nil
    
    BattleHero = nil
    BattleLogic = nil
    BattleSoldier = nil
    BattleTeam = nil
    BattleTotem = nil
    BC = nil
    cc = nil
    
    DAMAGESHARE_TICK_INV = nil
    ECamp = nil
    EDirect = nil
    EDirectLEFT = nil
    EDirectRIGHT = nil
    EEffFlyType = nil
    EMotion = nil
    EMotionBORN = nil
    EState = nil
    ETeamState = nil
    ETeamStateATTACK = nil
    ETeamStateDIE = nil
    ETeamStateIDLE = nil
    ETeamStateMOVE = nil
    ETeamStateSORT = nil
    floor = nil
    genTeamID = nil
    getCellByScenePos = nil
    getRowIndex = nil
    insert = nil
    math = nil
    mcMgr = nil
    next = nil
    objLayer = nil
    os = nil
    pairs = nil
    pc = nil
    random = nil
    remove = nil
    SAY_TICK_DURATION = nil
    SAY_TICK_INV = nil
    SPEED_SORT = nil
    sqrt = nil
    tab = nil
    table = nil
    tonumber = nil
    tostring = nil
    BattleTeam_update = nil
end

function BattleLogic.dtor1()
    ATTR_Def = nil
    ATTR_Crit = nil
    ATTR_CritD = nil
    ATTR_Dodge = nil
    ATTR_AHP = nil
    ATTR_DHP = nil
    ATTR_Heal = nil
    ATTR_BeHeal = nil
    ATTR_Hot = nil
    ATTR_DamageInc = nil
    ATTR_DamageDec = nil
    ATTR_DecAll = nil
    SRData = nil
    BC_reverse = nil
    MAX_SCENE_WIDTH_PIXEL = nil
    abs = nil
end

return BattleLogic
