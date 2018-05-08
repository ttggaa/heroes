--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-12-22 22:01:55
--

local tab = tab
local print = print
local dump = dump
local ceil = math.ceil
local pairs = pairs
local table = table
local type = type 
local tonumber = tonumber


local BattleUtils = BattleUtils

-- 战后清除所有战斗相关逻辑方法
function BattleUtils.clearBattleRequire()
    -- 这里不加全了,会出bug
    local requireList = 
    {
        "game.view.battle.object.BattleTotem",
        "game.view.battle.object.BattleObject",
        "game.view.battle.object.BattleBuffer",
        "game.view.battle.object.BattleTeam",
        "game.view.battle.object.BattleSoldier",
        "game.view.battle.object.BattleHero",
        "game.view.battle.object.BattleWeapon",

        "game.view.battle.display.BattleFrontLayer",
        "game.view.battle.display.BattleMapLayer",
        "game.view.battle.display.BattleObjectLayer",
        "game.view.battle.display.BattleObjectLayer_null",
        "game.view.battle.display.BattleScene",
        "game.view.battle.display.BattleWeatherLayer",

        "game.view.battle.logic.BattleConst",
        "game.view.battle.logic.BattleDelayCall",
        "game.view.battle.logic.BattleEffectManager",
        "game.view.battle.logic.BattlePlayerLogic",
        "game.view.battle.logic.BattleSkillLogic",
        "game.view.battle.logic.BattleLogic",
        "game.view.battle.logic.BattleSoldierCreator",
        "game.view.battle.logic.BattleFormationPos",

        "game.view.battle.rule.BattleResEx",
        "game.view.battle.rule.BattleRule_AiRenMuWu",
        "game.view.battle.rule.BattleRule_BOSS_DuLong",
        "game.view.battle.rule.BattleRule_BOSS_SjLong",
        "game.view.battle.rule.BattleRule_BOSS_XnLong",
        "game.view.battle.rule.BattleRule_GBOSS_1",
        "game.view.battle.rule.BattleRule_GBOSS_3",
        "game.view.battle.rule.BattleRule_GBOSS_2",
        "game.view.battle.rule.BattleRule_CloudCity",
        "game.view.battle.rule.BattleRule_CCSiege",
        "game.view.battle.rule.BattleRule_Guide",
        "game.view.battle.rule.BattleRule_PVE1",
        "game.view.battle.rule.BattleRule_PVP1",
        "game.view.battle.rule.BattleRule_PVP2",
        "game.view.battle.rule.BattleRule_Siege",
        "game.view.battle.rule.BattleRule_Zombie",
        "game.view.battle.rule.BattleRule_GVG",
        "game.view.battle.rule.BattleRule_GVGSiege",
        "game.view.battle.rule.BattleRule_GuideSiege",
        "game.view.battle.rule.BattleRule_Elemental_1",
        "game.view.battle.rule.BattleRule_Elemental_2",
        "game.view.battle.rule.BattleRule_Elemental_3",
        "game.view.battle.rule.BattleRule_Elemental_4",
        "game.view.battle.rule.BattleRule_Elemental_5",
        "game.view.battle.rule.BattleRule_Siege_Atk",
        "game.view.battle.rule.BattleRule_Siege_Def",
    }

    if OS_IS_64 then
        for i = 1, #requireList do
            local filename = requireList[i] .. "64"
            local req = package.loaded[filename]
            if req and type(req) == "table" then 
                if req.dtor then req.dtor() end
                if req.dtor1 then req.dtor1() end
                if req.dtor2 then req.dtor2() end
                if req.dtor3 then req.dtor3() end
            end
            package.loaded[filename] = nil
        end
    else
        for i = 1, #requireList do
            local filename = requireList[i]
            local req = package.loaded[filename]
            if req and type(req) == "table" then 
                if req.dtor then req.dtor() end
                if req.dtor1 then req.dtor1() end
                if req.dtor2 then req.dtor2() end
                if req.dtor3 then req.dtor3() end
            end
            package.loaded[filename] = nil
        end
    end

    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
end

-- 后端json数据转前端数据
function BattleUtils.json2lua_battleData(json)
    return BattleUtils.jsonData2lua_battleData(cjson.decode(json))
end

function BattleUtils.jsonData2lua_battleData(data)
    local battleData = {}
    battleData.ver = data.ver
    battleData.name = data.name
    battleData.guildName = data.guildName
    battleData.score = data.score
    battleData.curScore = data.formation.score
    -- dump(data, "a", 20)
    battleData.lv = data.lv
    local dformation = data.formation
    local dhero = data.hero
    local dteams = data.teams
    -- 把带#的ID转换成正常ID   205#1 => 205
    local list
    local _team = {}
    for ID, team in pairs(dteams) do
        list = string.split(ID, "#")
        if #list > 1 then
            team.dhr = list[2]
            team.ID = list[1]
            _team[#_team + 1] = team
        else
            team.ID = ID
            _team[#_team + 1] = team
        end
    end
    dteams = _team

    if data.skillList and data.skillList ~= "" then
        battleData.skillList = cjson.decode(data.skillList)
    end
    
    local hero
    if data.npcHero ~= nil then
        hero =
        {
            id = data.npcHero,
            npcHero = true,
        }
    else
        hero =
        {
            id = tonumber(dformation.heroId),
            level = data.lv,
            star = dhero.star,
            slevel = {dhero.sl1, dhero.sl2, dhero.sl3, dhero.sl4},
            mastery = {dhero.m1, dhero.m2, dhero.m3, dhero.m4},
            skin = tonumber(dhero.skin),
            sc = dhero.sc,-- 星图数据
        }   
        if dhero.slot and dhero.slot.sid and dhero.slot.sid ~= 0 and data.spellBooks and data.spellBooks.l then
            -- 有可能是专精
            hero.skillex = {dhero.slot.sid, dhero.slot.s, data.spellBooks.l}
        end
    end
    if data.buff then
        local buff = {}
        for k, v in pairs(data.buff) do
            buff[tostring(k)] = tonumber(v)
        end
        hero.buff = buff
    end
    -- 英雄全局属性
    if data.hAb then
        hero.hAb = data.hAb
    end
    if data.branchHAb then
        -- 如果是npc英雄 hab赋值成支线属性
        if hero.npcHero then
            hero.hAb = data.branchHAb
        end
        hero.branchHAb = data.branchHAb
    end
    -- 英雄全局专精
    if data.uMastery then
        hero.uMastery = data.uMastery
    end

    battleData.hero = hero

    battleData.avatar = data.avatar
    battleData.pokedex = data.pokedex
    battleData.treasure = data.treasures
    battleData.hStar = data.hStar
    -- dump(battleData.treasure, "a", 20)
    local tformations = data.tformations
    if tformations then
        local treasureFilter = {}
        local tid = dformation.tid
        local tformation = tformations[tostring(tid)]
        local _treasureId
        if tformation then
            for k, treasureId in pairs(tformation) do
                if treasureId ~= 0 then
                    treasureFilter[treasureId] = true
                end
            end
            for treasureId, v in pairs(battleData.treasure) do
                _treasureId = tonumber(treasureId)
                local tag = tab.comTreasure[_treasureId] and tab.comTreasure[_treasureId]["addtag"]
                if tag == 9 or treasureFilter[_treasureId] then 
                    v.inTForm = true
                end
            end
        end
    end
    -- 天赋 （魔法行会）
    battleData.talent = data.talent
    -- 魔法天赋
    battleData.spTalent = data.spTalent
    -- 英雄全局专长
    battleData.globalMasterys = BattleUtils.getHeroGlobalMasterys(data.globalSpecial)

    --兵团符文宝石库
    battleData.runes = BattleUtils.generateTeamRunsData(clone(data.runes))

    local mercenaryId = data.mercenaryId
    -- 死亡下阵
    local filter = {}
    if dformation.filter then 
        local tempFilter = string.split(dformation.filter, ",")
        for k,v in pairs(tempFilter) do
            if string.len(v) > 0 then 
                filter[tostring(v)] = true
            end
        end
    end
    if next(filter) ~= nil then
        local _team = {}
        for i = 1, #dteams do
            if filter[dteams[i].ID] == nil or mercenaryId == tonumber(dteams[i].ID) then
                _team[#_team + 1] = dteams[i]
            end
        end
        dteams = _team
    end

    local formationPD = {}
    local team, g, d
    for i = 1, 8 do
        team = dformation["team" .. i]
        g = dformation["g" .. i]
        d = dformation["d" .. i]
        if team then
            if d then
                formationPD[team .. "#" .. d] = g
            else
                formationPD[team] = g
            end
        end
    end
    local teams = {}
    local tid, v, fid
    for i = 1, #dteams do
        v = dteams[i]
        tid = tonumber(dteams[i].ID)
        if v.dhr then
            fid = tid .. "#" .. v.dhr
        else
            fid = tid
        end
        local jxTree = v.tree or {}
        local rune = v.rune
        if rune and type(rune) == "table" then
            rune.castinglv = BattleUtils.getHolyMasterLevel(rune, battleData.runes)
        end
        team = {
            id = tid,
            pos = formationPD[fid],
            level = v.level,
            star = v.star,
            smallStar = v.smallStar,
            stage = v.stage,
            dhr = v.dhr,
            -- 里属性
            avn = v.avn,
            pl = clone(v.pl),
            -- 天赋
            tmScore = v.tmScore,
            -- 觉醒
            jx = tonumber(v.ast) == 3,
            jxLv = tonumber(v.aLvl),
            jxSkill1 = jxTree.b1,
            jxSkill2 = jxTree.b2,
            jxSkill3 = jxTree.b3,

            -- 符文宝石
            rune = v.rune,
            -- 是否为雇佣兵
            isMercenary = tid == mercenaryId,
            -- 原始数据
            data = clone(v),
        }
        if team.jxSkill1 == 0 then team.jxSkill1 = nil end
        if team.jxSkill2 == 0 then team.jxSkill2 = nil end
        if team.jxSkill3 == 0 then team.jxSkill3 = nil end
        team.data.teamId = tid
        if v.tt then
            team.tt = {}
            for k, v in pairs(v.tt) do
                team.tt[tostring(k)] = tonumber(v)
            end
        end
        team.equip = 
        {
            {stage = v.es1, level = v.el1},
            {stage = v.es2, level = v.el2},
            {stage = v.es3, level = v.el3},
            {stage = v.es4, level = v.el4},
        }
        team.skill = {v.sl1, v.sl2, v.sl3, v.sl4}
 
        team.leagueBuff = v.leagueBuff

        -- 宝石库加到兵团自己身上
        team.runes = battleData.runes
        team.purBuff    = v.purBuff
        teams[#teams + 1] = team
    end
    battleData.team = teams

    -- 攻城器械
    local weapons = {}
    local dweapons = data.weapons
    for i = 1, 4 do
        local _id = dformation["weapon"..i]
        if _id and _id ~= 0 then
            weapons[i] = clone(dweapons[tostring(_id)])
            if weapons[i] then
                weapons[i].id = tonumber(_id)
            end 
        end
    end
    battleData.weapons = weapons

    -- dump(battleData, "a", 20)
    return battleData
end

-- 获取战前额外传给服务器的数据
-- serverInfoEx = BattleUtils.getBeforeSIE(),
function BattleUtils.getBeforeSIE()
	local info = 
	{
        walleVersion = GameStatic.walleVersion,
        localTime = os.time(),
	}
	return cjson.encode(info)
end

local BattleUtils2 = {}

function BattleUtils2.dtor()
	tab = nil
	print = nil
	dump = nil
	ceil = nil
	pairs = nil
	table = nil
	type = nil 
	tonumber = nil
	BattleUtils = nil
end

return BattleUtils2
