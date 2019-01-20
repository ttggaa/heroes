--[[
    Filename:    FormationModel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-05-25 18:22:52
    Description: File description
--]]

--[[
    ********数据瘦身记录********
    teamGrid    => g

]]--

local FormationModel = class("FormationModel", BaseModel)

FormationModel.kTeamMaxCount = 8

FormationModel.kFormationTypeCommon = 1
FormationModel.kFormationTypeArena = 2
FormationModel.kFormationTypeAiRenMuWu = 3
FormationModel.kFormationTypeZombie = 4
FormationModel.kFormationTypeDragon = 5
FormationModel.kFormationTypeCrusade = 6
FormationModel.kFormationTypeLeague = 8
FormationModel.kFormationTypeGuild = 9
FormationModel.kFormationTypeDragon1 = 10
FormationModel.kFormationTypeDragon2 = 11
FormationModel.kFormationTypeCloud1 = 12
FormationModel.kFormationTypeCloud2 = 13
FormationModel.kFormationTypeTraining = 14
FormationModel.kFormationTypeMF = 15
FormationModel.kFormationTypeAdventure = 16

FormationModel.kFormationTypeCityBattle1 = 17
FormationModel.kFormationTypeCityBattle2 = 18
FormationModel.kFormationTypeCityBattle3 = 19
FormationModel.kFormationTypeCityBattle4 = 20

FormationModel.kFormationTypeHeroDuel = 21

FormationModel.kFormationTypeGodWar1 = 22
FormationModel.kFormationTypeGodWar2 = 23
FormationModel.kFormationTypeGodWar3 = 24

FormationModel.kFormationTypeElemental1 = 25
FormationModel.kFormationTypeElemental2 = 26
FormationModel.kFormationTypeElemental3 = 27
FormationModel.kFormationTypeElemental4 = 28
FormationModel.kFormationTypeElemental5 = 29

FormationModel.kFormationTypeWeapon = 30
FormationModel.kFormationTypeWeaponDef = 31

FormationModel.kFormationTypeCrossPKAtk1 = 32
FormationModel.kFormationTypeCrossPKAtk2 = 33
FormationModel.kFormationTypeCrossPKAtk3 = 34
FormationModel.kFormationTypeCrossPKFight = 35
FormationModel.kFormationTypeClimbTower = 36
FormationModel.kFormationTypeCrossGodWar1 = 37
FormationModel.kFormationTypeCrossGodWar2 = 38
FormationModel.kFormationTypeCrossGodWar3 = 39
FormationModel.kFormationTypeStakeAtk1 = 40    -- 木桩布阵
FormationModel.kFormationTypeStakeAtk2 = 41    -- 木桩自定义攻击

-- 荣耀竞技场进攻编组
FormationModel.kFormationTypeGloryArenaAtk1 = 46
FormationModel.kFormationTypeGloryArenaAtk2 = 47
FormationModel.kFormationTypeGloryArenaAtk3 = 48

FormationModel.kFormationTypeWorldBoss = 49
FormationModel.kFormationTypeProfession1 = 50    -- pve 军团试炼 攻
FormationModel.kFormationTypeProfession2 = 51    -- pve 军团试炼 防
FormationModel.kFormationTypeProfession3 = 52    -- pve 军团试炼 突
FormationModel.kFormationTypeProfession4 = 53    -- pve 军团试炼 射
FormationModel.kFormationTypeProfession5 = 54    -- pve 军团试炼 魔

FormationModel.kFormationTypeArenaDef = 101
FormationModel.kFormationTypeGuildDef = 102
FormationModel.kFormationTypeMFDef = 103

FormationModel.kFormationTypeCrossPKDef1 = 105
FormationModel.kFormationTypeCrossPKDef2 = 106
FormationModel.kFormationTypeCrossPKDef3 = 107

FormationModel.kFormationTypeStakeDef2 = 108    -- 木桩自定义防御

-- 荣耀竞技场防守编组
FormationModel.kFormationTypeGloryArenaDef1 = 109
FormationModel.kFormationTypeGloryArenaDef2 = 110
FormationModel.kFormationTypeGloryArenaDef3 = 111

FormationModel.isFormationDialogShowed = false --是否显示过进战斗之前提示上阵不满的提示，仅限副本和竞技场使用
FormationModel.isShowFieldEmptyDialog = {}

FormationModel.kFormationName = 
{
    [FormationModel.kFormationTypeCommon] = "战前编组",
    [FormationModel.kFormationTypeArena] = "竞技场进攻编组",
    [FormationModel.kFormationTypeAiRenMuWu] = "矮人宝屋编组",
    [FormationModel.kFormationTypeZombie] = "阴森墓穴编组",
    [FormationModel.kFormationTypeDragon] = "毒龙编组",
    [FormationModel.kFormationTypeCrusade] = "战役编组",

    [FormationModel.kFormationTypeLeague] = "冠军对决编组",
    [FormationModel.kFormationTypeGuild] = "联盟编组",

    [FormationModel.kFormationTypeDragon1] = "仙女龙编组",
    [FormationModel.kFormationTypeDragon2] = "水晶龙编组",

    [FormationModel.kFormationTypeArenaDef] = "竞技场防守编组",
    [FormationModel.kFormationTypeGuildDef] = "联盟防守编组",

    [FormationModel.kFormationTypeMF] = "船坞编组",
    [FormationModel.kFormationTypeMFDef] = "船坞防守编组",

    [FormationModel.kFormationTypeCloud1] = "光之试炼编组",
    [FormationModel.kFormationTypeCloud2] = "暗之试炼编组",

    [FormationModel.kFormationTypeTraining] = "训练所编组",
    [FormationModel.kFormationTypeAdventure] = "神秘宝藏编组",

    [FormationModel.kFormationTypeCityBattle1] = "第一队编组",
    [FormationModel.kFormationTypeCityBattle2] = "第二队编组",
    [FormationModel.kFormationTypeCityBattle3] = "第三队编组",
    [FormationModel.kFormationTypeCityBattle4] = "第四队编组",

    [FormationModel.kFormationTypeHeroDuel] = "英雄交锋编组",

    [FormationModel.kFormationTypeGodWar1] = "诸神之战编组1",
    [FormationModel.kFormationTypeGodWar2] = "诸神之战编组2",
    [FormationModel.kFormationTypeGodWar3] = "诸神之战编组3",

    [FormationModel.kFormationTypeElemental1] = "元素位面编组",
    [FormationModel.kFormationTypeElemental2] = "元素位面编组",
    [FormationModel.kFormationTypeElemental3] = "元素位面编组",
    [FormationModel.kFormationTypeElemental4] = "元素位面编组",
    [FormationModel.kFormationTypeElemental5] = "元素位面编组",

    [FormationModel.kFormationTypeWeapon] = "攻城战编组",
    [FormationModel.kFormationTypeWeaponDef] = "守城战编组",    

    [FormationModel.kFormationTypeCrossPKAtk1] = "进攻编组",
    [FormationModel.kFormationTypeCrossPKAtk2] = "进攻编组",
    [FormationModel.kFormationTypeCrossPKAtk3] = "进攻编组",

    [FormationModel.kFormationTypeCrossPKDef1] = "防守编组",
    [FormationModel.kFormationTypeCrossPKDef2] = "防守编组",
    [FormationModel.kFormationTypeCrossPKDef3] = "防守编组",
    [FormationModel.kFormationTypeCrossPKFight] = "进攻编组",
    [FormationModel.kFormationTypeClimbTower] = "无尽炼狱编组",
    [FormationModel.kFormationTypeCrossGodWar1] = "跨服诸神编组1",
    [FormationModel.kFormationTypeCrossGodWar2] = "跨服诸神编组2",
    [FormationModel.kFormationTypeCrossGodWar3] = "跨服诸神编组3",
    [FormationModel.kFormationTypeStakeAtk1] = "进攻编组",
    [FormationModel.kFormationTypeStakeAtk2] = "进攻编组",
    [FormationModel.kFormationTypeStakeDef2] = "防守编组",

    [FormationModel.kFormationTypeGloryArenaAtk1] = "进攻编组",
    [FormationModel.kFormationTypeGloryArenaAtk2] = "进攻编组",
    [FormationModel.kFormationTypeGloryArenaAtk3] = "进攻编组",
    [FormationModel.kFormationTypeGloryArenaDef1] = "防守编组",
    [FormationModel.kFormationTypeGloryArenaDef2] = "防守编组",
    [FormationModel.kFormationTypeGloryArenaDef3] = "防守编组",

    [FormationModel.kFormationTypeWorldBoss] = "战前编组",
    [FormationModel.kFormationTypeProfession1] = "军团试炼：攻",
    [FormationModel.kFormationTypeProfession2] = "军团试炼：防",
    [FormationModel.kFormationTypeProfession3] = "军团试炼：突",
    [FormationModel.kFormationTypeProfession4] = "军团试炼：射",
    [FormationModel.kFormationTypeProfession5] = "军团试炼：魔",
}

-- 2,8,6,7,15,9,32,33,34,35,101,102,103,104,105,106,107
-- 36，25，26，27，28，29，12，13，1
FormationModel.kBackupFormation = {
    FormationModel.kFormationTypeArena,
    FormationModel.kFormationTypeLeague,
    FormationModel.kFormationTypeCrusade,
    FormationModel.kFormationTypeMF,
    FormationModel.kFormationTypeGuild,
    -- FormationModel.kFormationTypeCrossPKAtk1,
    -- FormationModel.kFormationTypeCrossPKAtk2,
    -- FormationModel.kFormationTypeCrossPKAtk3,
    -- FormationModel.kFormationTypeCrossPKFight,
    FormationModel.kFormationTypeArenaDef,
    FormationModel.kFormationTypeGuildDef,
    FormationModel.kFormationTypeMFDef,
    -- FormationModel.kFormationTypeCrossPKDef1,
    -- FormationModel.kFormationTypeCrossPKDef2,
    -- FormationModel.kFormationTypeCrossPKDef3
    FormationModel.kFormationTypeClimbTower,
    FormationModel.kFormationTypeElemental1,
    FormationModel.kFormationTypeElemental2,
    FormationModel.kFormationTypeElemental3,
    FormationModel.kFormationTypeElemental4,
    FormationModel.kFormationTypeElemental5,
    FormationModel.kFormationTypeCloud1,
    FormationModel.kFormationTypeCloud2,
    FormationModel.kFormationTypeCommon,
    FormationModel.kFormationTypeStakeAtk2,
    FormationModel.kFormationTypeStakeDef2
}

function FormationModel:ctor()
    FormationModel.super.ctor(self)
    self._data = {}
    self._modelMgr = ModelManager:getInstance()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._pokedexModel = self._modelMgr:getModel("PokedexModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._treasureModel = self._modelMgr:getModel("TreasureModel")
    self._talentModel = self._modelMgr:getModel("TalentModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
    self._starChartsModel = self._modelMgr:getModel("StarChartsModel")
    self._teamLoadedMap = {}
    self._backupTeamLoadedMap = {}
    self._allFormationType  = {
        [1] = FormationModel.kFormationTypeCommon,
        [2] = FormationModel.kFormationTypeArena,
        [3] = FormationModel.kFormationTypeAiRenMuWu,
        [4] = FormationModel.kFormationTypeZombie,
        [5] = FormationModel.kFormationTypeDragon,
        [6] = FormationModel.kFormationTypeCrusade,
        [7] = FormationModel.kFormationTypeArenaDef,
        [8] = FormationModel.kFormationTypeGuildDef,
        [9] = FormationModel.kFormationTypeLeague,
        [10] = FormationModel.kFormationTypeGuild,
        [11] = FormationModel.kFormationTypeDragon1,
        [12] = FormationModel.kFormationTypeDragon2,
        [13] = FormationModel.kFormationTypeMF,
        [14] = FormationModel.kFormationTypeMFDef,
        [15] = FormationModel.kFormationTypeCloud1,
        [16] = FormationModel.kFormationTypeCloud2,
        [17] = FormationModel.kFormationTypeTraining,
        [18] = FormationModel.kFormationTypeAdventure,
        [19] = FormationModel.kFormationTypeCityBattle1,
        [20] = FormationModel.kFormationTypeCityBattle2,
        [21] = FormationModel.kFormationTypeCityBattle3,
        [22] = FormationModel.kFormationTypeCityBattle4,
        [23] = FormationModel.kFormationTypeHeroDuel,
        [24] = FormationModel.kFormationTypeGodWar1,
        [25] = FormationModel.kFormationTypeGodWar2,
        [26] = FormationModel.kFormationTypeGodWar3,
        [27] = FormationModel.kFormationTypeElemental1,
        [28] = FormationModel.kFormationTypeElemental2,
        [29] = FormationModel.kFormationTypeElemental3,
        [30] = FormationModel.kFormationTypeElemental4,
        [31] = FormationModel.kFormationTypeElemental5,
        [32] = FormationModel.kFormationTypeWeapon,
        [33] = FormationModel.kFormationTypeWeaponDef,
        [34] = FormationModel.kFormationTypeCrossPKAtk1,
        [35] = FormationModel.kFormationTypeCrossPKAtk2,
        [36] = FormationModel.kFormationTypeCrossPKAtk3,
        [37] = FormationModel.kFormationTypeCrossPKDef1,
        [38] = FormationModel.kFormationTypeCrossPKDef2,
        [39] = FormationModel.kFormationTypeCrossPKDef3,
        [40] = FormationModel.kFormationTypeCrossPKFight,
        [41] = FormationModel.kFormationTypeClimbTower,
        [42] = FormationModel.kFormationTypeCrossGodWar1,
        [43] = FormationModel.kFormationTypeCrossGodWar2,
        [44] = FormationModel.kFormationTypeCrossGodWar3,
        [45] = FormationModel.kFormationTypeStakeAtk1,
        [46] = FormationModel.kFormationTypeStakeAtk2,
        [47] = FormationModel.kFormationTypeStakeDef2,
        [48] = FormationModel.kFormationTypeGloryArenaAtk1,
        [49] = FormationModel.kFormationTypeGloryArenaAtk2,
        [50] = FormationModel.kFormationTypeGloryArenaAtk3,
        [51] = FormationModel.kFormationTypeGloryArenaDef1,
        [52] = FormationModel.kFormationTypeGloryArenaDef2,
        [53] = FormationModel.kFormationTypeGloryArenaDef3,
        [54] = FormationModel.kFormationTypeWorldBoss,
        [55] = FormationModel.kFormationTypeProfession1,
        [56] = FormationModel.kFormationTypeProfession2,
        [57] = FormationModel.kFormationTypeProfession3,
        [58] = FormationModel.kFormationTypeProfession4,
        [59] = FormationModel.kFormationTypeProfession5,
    }
end

function FormationModel:saveData(data, formationId, isScenarioHero, hireTeamId, isHaveFixedWeapon, callback)
    -- version 2.0
    --[=[
    dump(data, "data from do save")
    local json = json.decode("{\"teams\":[[1101,1],[1102,3],[1103,5]],\"ins\":[],\"skills\":[[54013,1], [54024,2]]}")
    dump(json, "json from do save")
    ]=]
    -- dump(data, "a", 20)
    local originData = self._data._formationData[formationId]
    if isScenarioHero then
        data.heroId = originData.heroId
    end

    if hireTeamId and 0 ~= hireTeamId then
        for i=1, 8 do
            local teamId = data["team" .. i]
            if teamId and teamId == hireTeamId then
                data["team" .. i] = 0
                data["g" .. i] = 0
            end
        end
    end

    if isHaveFixedWeapon or not self:isHaveWeapon(formationId) then
        for i=1, 3 do
            local weaponId = data["weapon" .. i]
            if weaponId and 0 ~= weaponId then
                data["weapon" .. i] = 0
            end
        end
    end

    self._data._formationDataCache[formationId] = data
    if FormationModel.kFormationTypeTraining ~= formationId then
        local context = {id = tonumber(formationId), args = {teams = {}}}
        table.walk(data, function(v, k)
            if string.find(tostring(k), "g") or (0 == v and not string.find(tostring(k), "heroId")) then return end
            if string.find(tostring(k), "team") then
                table.insert(context["args"]["teams"], {[1] = tonumber(v), [2] = tonumber(data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "heroId") and originData.heroId ~= data.heroId and not isScenarioHero then
                context["args"]["heroId"] = tonumber(v)
            end
        end)

        for i=1, 4 do
            local weaponId = data["weapon" .. i]
            if weaponId and 0 ~= weaponId then
                context["args"]["weapon" .. i] = data["weapon" .. i]
            end
        end

        context["args"]["tid"] = data["tid"]
        context["args"]["areaSkillTeam"] = data["areaSkillTeam"]

        if table.indexof(FormationModel.kBackupFormation, tonumber(formationId)) then
            context["args"]["bid"] = data["bid"]
            context["args"]["backupTs"] = data["backupTs"]
        end

        context["args"] = json.encode(context["args"])
        --print("context json", context["args"])
        self._serverMgr:sendMsg("FormationServer", "setFormation", context, true, {}, function(success)
            if success then
                self:private_saveFormationData(success, formationId)
            end
            if callback then
                callback(success)
            end
        end)
    else
        self:private_saveFormationData(true, formationId)
        if callback then
            callback(true)
        end
    end
    --[==[ -- version 1.0
    --[=[
    dump(data, "data from do save")
    local json = json.decode("{\"teams\":[[1101,1],[1102,3],[1103,5]],\"ins\":[],\"skills\":[[54013,1], [54024,2]]}")
    dump(json, "json from do save")
    ]=]
    self._data._formationDataCache[formationId] = data
    local context = {id = tonumber(formationId), args = { teams = {}, ins = {}, skills ={}}}
    table.walk(data, function(v, k)
        if string.find(tostring(k), "g") or 0 == v then return end
        if string.find(tostring(k), "team") then
            table.insert(context["args"]["teams"], {[1] = tonumber(v), [2] = tonumber(data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
        --elseif string.find(tostring(k), "ins") then
        --  table.insert(context["args"]["ins"], {[1] = tonumber(v), [2] = tonumber(data[string.format("insGrid%d", tonumber(string.sub(tostring(k), -1)))])})
        elseif string.find(tostring(k), "skill") then
            table.insert(context["args"]["skills"], {[1] = tonumber(v), [2] = tonumber(string.sub(tostring(k), -1))})
        end 
    end)

    context["args"] = json.encode(context["args"])
    --print("context json", context["args"])
    self._serverMgr:sendMsg("FormationServer", "setFormation", context, true, {}, function(result) 
        self:private_saveFormationData(result, formationId)
    end)
    ]==]
end

function FormationModel:saveCrossGodWarData( saveData, callback )
    local allContext = {args = {}}

    local index = 0
    for k, v in pairs(saveData) do
        index = index + 1
        self._data._formationDataCache[k] = v
        allContext.args[index] = {id = tonumber(k), data = {teams = {}}}
        table.walk(v, function ( vv, kk )
            if string.find(tostring(kk), "g") or (0 == vv and not string.find(tostring(kk), "heroId")) then return end
            if string.find(tostring(kk), "team") then
                table.insert(allContext["args"][index]["data"]["teams"], {[1] = tonumber(vv), [2] = tonumber(v[string.format("g%d", tonumber(string.sub(tostring(kk), -1)))])})
            elseif string.find(tostring(kk), "heroId") then
                allContext["args"][index]["data"]["heroId"] = tonumber(vv)
            end
        end)
        for i = 1, 4 do
            local weaponId = v["weapon" .. i]
            if weaponId and 0 ~= weaponId then
                allContext["args"][index]["data"]["weapon" .. i] = v["weapon" .. i]
            end
        end
        allContext["args"][index]["data"]["tid"] = v["tid"]
    end

    allContext["args"] = json.encode(allContext["args"])
    print("context json", allContext)
    self._serverMgr:sendMsg("FormationServer", "setCrossGodWarFormations", allContext, true, {}, function(success) 
        if success then
            self:private_saveFormationData(success)
        end
        if callback then
            callback(success)
        end
    end)
end

function FormationModel:saveGloryArenaData( saveData, callback )
    local allContext = {args = {}}

    local index = 0
    for k, v in pairs(saveData) do
        index = index + 1
        self._data._formationDataCache[k] = v
        allContext.args[index] = {id = tonumber(k), data = {teams = {}}}
        table.walk(v, function ( vv, kk )
            if string.find(tostring(kk), "g") or (0 == vv and not string.find(tostring(kk), "heroId")) then return end
            if string.find(tostring(kk), "team") then
                table.insert(allContext["args"][index]["data"]["teams"], {[1] = tonumber(vv), [2] = tonumber(v[string.format("g%d", tonumber(string.sub(tostring(kk), -1)))])})
            elseif string.find(tostring(kk), "heroId") then
                allContext["args"][index]["data"]["heroId"] = tonumber(vv)
            end
        end)
        for i = 1, 4 do
            local weaponId = v["weapon" .. i]
            if weaponId and 0 ~= weaponId then
                allContext["args"][index]["data"]["weapon" .. i] = v["weapon" .. i]
            end
        end
        allContext["args"][index]["data"]["tid"] = v["tid"]
    end

    allContext["args"] = json.encode(allContext["args"])
    print("context json", allContext["args"])
    self._serverMgr:sendMsg("FormationServer", "setCrossArenaFormations", allContext, true, {}, function(success) 
        if success then
            self:private_saveFormationData(success)
        end
        if callback then
            callback(success)
        end
    end)
end

function FormationModel:saveMultipleData(formationData1, formationId1, formationData2, formationId2, callback)
    local allContext = {args = {}}
    local index = 0
    if formationData1 then
        index = index + 1
        self._data._formationDataCache[formationId1] = formationData1
        allContext.args[index] = {id = tonumber(formationId1), data = {teams = {}}}
        table.walk(formationData1, function(v, k)
            if string.find(tostring(k), "g") or (0 == v and not string.find(tostring(k), "heroId")) then return end
            if string.find(tostring(k), "team") then
                table.insert(allContext["args"][index]["data"]["teams"], {[1] = tonumber(v), [2] = tonumber(formationData1[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "heroId") then
                allContext["args"][index]["data"]["heroId"] = tonumber(v)
            end
        end)
        if table.indexof(FormationModel.kBackupFormation, tonumber(formationId1)) then
            allContext["args"][index]["data"]["bid"] = formationData1["bid"]
            allContext["args"][index]["data"]["backupTs"] = formationData1["backupTs"]
        end
    end
    if formationData2 then
        index = index + 1
        self._data._formationDataCache[formationId2] = formationData2
        allContext.args[index] = {id = tonumber(formationId2), data = {teams = {}}}
        table.walk(formationData2, function(v, k)
            if string.find(tostring(k), "g") or (0 == v and not string.find(tostring(k), "heroId")) then return end
            if string.find(tostring(k), "team") then
                table.insert(allContext["args"][index]["data"]["teams"], {[1] = tonumber(v), [2] = tonumber(formationData2[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "heroId") then
                allContext["args"][index]["data"]["heroId"] = tonumber(v)
            end
        end)
        if table.indexof(FormationModel.kBackupFormation, tonumber(formationId2)) then
            allContext["args"][index]["data"]["bid"] = formationData2["bid"]
            allContext["args"][index]["data"]["backupTs"] = formationData2["backupTs"]
        end
    end

    allContext["args"] = json.encode(allContext["args"])
    print("context json", allContext)
    self._serverMgr:sendMsg("FormationServer", "setMultipleFormation", allContext, true, {}, function(success) 
        --self:private_saveMultipleFormationData(success, formationId1, formationId2)
        if success then
            self:private_saveFormationData(success)
        end
        if callback then
            callback(success)
        end
    end)
end

function FormationModel:saveCityBattleData(formationDatas, callback)
    local allContext = {args = {}}
    local index = 1
    for formationId, formationData in pairs(formationDatas) do
        formationId = tonumber(formationId)
        self._data._formationDataCache[formationId] = formationData
        allContext.args[index] = {id = tonumber(formationId), data = {teams = {}}}
        table.walk(formationData, function(v, k)
            if string.find(tostring(k), "g") or (0 == v and not string.find(tostring(k), "heroId")) then return end
            if string.find(tostring(k), "team") then
                table.insert(allContext["args"][index]["data"]["teams"], {[1] = tonumber(v), [2] = tonumber(formationData[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "heroId") then
                allContext["args"][index]["data"]["heroId"] = tonumber(v)
            end
        end)
        index = index + 1
    end

    allContext["args"] = json.encode(allContext["args"])
    print("context json", allContext)
    self._serverMgr:sendMsg("FormationServer", "setCityBattleFormation", allContext, true, {}, function(success, data) 
        --self:private_saveMultipleFormationData(success, formationId1, formationId2)
        if success then
            self:private_saveCityBattleFormationData(success, data)
        end

        if callback then
            callback(success)
        end
    end)
end

function FormationModel:reviveCityBattleFormation(formationId, callback)
    self._serverMgr:sendMsg("CityBattleServer", "reviveFormation", {id = tonumber(formationId)}, true, {}, function(data, success) 
        --self:private_saveMultipleFormationData(success, formationId1, formationId2)
        --[[
        if success then
            -- do nothing
        end
        ]]
        if callback then
            callback(success)
        end
    end)
end

function FormationModel:saveAllData(formationDatas, formationId1, formationId2, callback)
    local allContext = {args = {}}
    local index = 1
    for formationId, formationData in pairs(formationDatas) do
        formationId = tonumber(formationId)
        self._data._formationDataCache[formationId] = formationData
        allContext.args[index] = {id = tonumber(formationId), data = {teams = {}}}
        table.walk(formationData, function(v, k)
            if string.find(tostring(k), "g") or (0 == v and not string.find(tostring(k), "heroId")) then return end
            if string.find(tostring(k), "team") then
                table.insert(allContext["args"][index]["data"]["teams"], {[1] = tonumber(v), [2] = tonumber(formationData[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "heroId") then
                allContext["args"][index]["data"]["heroId"] = tonumber(v)
            end
        end)

        for i=1, 4 do
            local weaponId = formationData["weapon" .. i]
            if weaponId and 0 ~= weaponId then
                allContext["args"][index]["data"]["weapon" .. i] = formationData["weapon" .. i]
            end
        end

        allContext["args"][index]["data"]["tid"] = formationData["tid"]
        allContext["args"][index]["data"]["areaSkillTeam"] = formationData["areaSkillTeam"]
        index = index + 1
    end

    allContext["args"] = json.encode(allContext["args"])
    print("context json", allContext)
    self._serverMgr:sendMsg("FormationServer", "setFormations", allContext, true, {}, function(success, data) 
        --self:private_saveMultipleFormationData(success, formationId1, formationId2)
        if success then
            self:private_saveAllFormationData(success, formationId1, formationId2, data)
        end

        if callback then
            callback(success)
        end
    end)
end

function FormationModel:quickFormat(formationId1, formationId2, callback)
    self._serverMgr:sendMsg("GodWarServer", "fastSetFormations", {}, true, {}, function(success, data) 
        --self:private_saveMultipleFormationData(success, formationId1, formationId2)
        if success then
            if data and data["d"] and data["d"]["formations"] then
                self:updateAllFormationData(data["d"]["formations"])
            end
        end

        if callback then
            callback(success)
        end
    end)
end

--[[
function FormationModel:_quickFormat(formationDatas, formationId1, formationId2, callback)
    local allContext = {args = {}}
    local index = 1
    for formationId, formationData in pairs(formationDatas) do
        formationId = tonumber(formationId)
        self._data._formationDataCache[formationId] = formationData
        allContext.args[index] = {id = tonumber(formationId), data = {teams = {}}}
        table.walk(formationData, function(v, k)
            if string.find(tostring(k), "g") or (0 == v and not string.find(tostring(k), "heroId")) then return end
            if string.find(tostring(k), "team") then
                table.insert(allContext["args"][index]["data"]["teams"], {[1] = tonumber(v), [2] = tonumber(formationData[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "heroId") then
                allContext["args"][index]["data"]["heroId"] = tonumber(v)
            end
        end)
        index = index + 1
    end

    allContext["args"] = json.encode(allContext["args"])
    print("context json", allContext)
    self._serverMgr:sendMsg("GodWarServer", "fastSetFormations", allContext, true, {}, function(success, data) 
        --self:private_saveMultipleFormationData(success, formationId1, formationId2)
        if success then
            self:private_saveAllFormationData(success, formationId1, formationId2, data)
        end

        if callback then
            callback(success)
        end
    end)
end
]]
--[==[
function FormationModel:saveAllData(defaultFormationId, allData)
    --[=[
    dump(data, "data from do save")
    local json = json.decode("{\"teams\":[[1101,1],[1102,3],[1103,5]],\"ins\":[],\"skills\":[[54013,1], [54024,2]]}")
    dump(json, "json from do save")
    ]=]
    --[[
    self._data._formationDataCache = allData
    local allContext = {}
    for formationId = 1, 3 do
        local data = allData[formationId]
        local context = {id = tonumber(formationId) - 1, args = { teams = {}, ins = {}, skills ={}}}
        table.walk(data, function(v, k)
            if string.find(tostring(k), "g") or 0 == v then return end
            if string.find(tostring(k), "team") then
                table.insert(context["args"]["teams"], {[1] = tonumber(v), [2] = tonumber(data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "ins") then
                table.insert(context["args"]["ins"], {[1] = tonumber(v), [2] = tonumber(data[string.format("insGrid%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "skill") then
                table.insert(context["args"]["skills"], {[1] = tonumber(v), [2] = tonumber(string.sub(tostring(k), -1))})
            end 
        end)
        context["args"] = json.encode(context["args"])
        table.insert(allContext, context)
    end
    --print("context json", context["args"])
    self._serverMgr:sendMsg("FormationServer", "setFormation", allContext, true, {}, function(result) 
        self:private_saveFormationData(result, formationId)
    end)
    ]]
    --[[
    self._data._formationDataCache = allData
    self._defaultFormationIdCache = defaultFormationId
    local allContext = {id = self._defaultFormationIdCache, args = {}}
    for formationId = 1, 3 do
        local data = allData[formationId]
        local context = {teams = {}, ins = {}, skills ={}}
        table.walk(data, function(v, k)
            if string.find(tostring(k), "g") or 0 == v then return end
            if string.find(tostring(k), "team") then
                table.insert(context["teams"], {[1] = tonumber(v), [2] = tonumber(data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "ins") then
                table.insert(context["ins"], {[1] = tonumber(v), [2] = tonumber(data[string.format("insGrid%d", tonumber(string.sub(tostring(k), -1)))])})
            elseif string.find(tostring(k), "skill") then
                table.insert(context["skills"], {[1] = tonumber(v), [2] = tonumber(string.sub(tostring(k), -1))})
            end 
        end)
        allContext["args"][tostring(formationId)] = context
    end
    allContext["args"] = json.encode(allContext["args"])
    dump(allContext, "context json")
    self._serverMgr:sendMsg("FormationServer", "setFormation", allContext, true, {}, function(success) 
        self:private_saveFormationData(success, defaultFormationId)
    end)
    ]]
end
]==]
--[==[
function FormationModel:saveHeroDuelData(data, formationId, callback)
    -- version 2.0
    --[=[
    dump(data, "data from do save")
    local json = json.decode("{\"teams\":[[1101,1],[1102,3],[1103,5]],\"ins\":[],\"skills\":[[54013,1], [54024,2]]}")
    dump(json, "json from do save")
    ]=]
    -- dump(data, "a", 20)
    self._data._formationDataCache[formationId] = data
    local formationData = {}
    for k, v in pairs(data) do
        repeat
            if not string.find(tostring(k), "team") or 0 == v then break end
            local index = tonumber(string.sub(tostring(k), -1))
            formationData["team" .. index] = data["team" .. index]
            formationData["g" .. index] = data["g" .. index]
            formationData["d" .. index] = data["d" .. index]
        until true
    end
    local context = {args = json.encode(formationData)}
    print("context json", context["args"])
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelSetFormation", context, true, {}, function(success, data)
        if success then
            self:private_saveFormationData(success, formationId)
        end
        if callback then
            callback(success)
        end
    end)
end
]==]
function FormationModel:private_saveFormationData(success, formationId)
    if success then 
        --[[ version 1.0 self._modelMgr:getModel("UserModel"):setDefaultFormationId(self._defaultFormationIdCache)]]
        self._data._formationData = clone(self._data._formationDataCache) 
        self._defaultFormationId = self._defaultFormationIdCache
        self._formationDataChanged = {}
        self:updateTeamLoadedMap()
    end
    self:reflashData()
end
--[[
function FormationModel:private_saveMultipleFormationData(success, formationId1, formationId2)
    if success then 
        self._data._formationData[formationId1] = clone(self._data._formationDataCache[formationId1])
        self._data._formationData[formationId2] = clone(self._data._formationDataCache[formationId2])
    end
    self:reflashData()
end
]]

function FormationModel:private_saveCityBattleFormationData(success, data)
    if success then 
        if data and data["d"] and data["d"]["formations"] then
            local formationData = data["d"]["formations"]
            for formationId = FormationModel.kFormationTypeCityBattle1, FormationModel.kFormationTypeCityBattle4 do
                repeat
                    if not (self._data._formationDataCache[formationId] and formationData[tostring(formationId)] and formationData[tostring(formationId)].filter) then break end
                    local filter = string.split(tostring(formationData[tostring(formationId)].filter), ",")
                    table.walk(filter, function(v, k)
                        filter[k] = tonumber(filter[k])
                    end)
                    self._data._formationDataCache[formationId].filter = filter
                until true
            end
        end
        self._data._formationData = clone(self._data._formationDataCache) 
        self._defaultFormationId = self._defaultFormationIdCache
        self._formationDataChanged = {}
        self:updateTeamLoadedMap()
    end
    self:reflashData()
end

--检测荣耀竞技场进攻编组，如果是nil初始化成
function FormationModel:private_saveGloryArenaAttackFormationData(success, data)
    if success then 
        if data then
            local formationData = data
            for formationId = FormationModel.kFormationTypeGloryArenaAtk1, FormationModel.kFormationTypeGloryArenaAtk3 do
                if formationData[tostring(formationId)] and not self._data._formationDataCache[formationId] then
                    self._data._formationDataCache[formationId] = clone(formationData[tostring(formationId)])
                end
                 repeat
                     if not (self._data._formationDataCache[formationId] and formationData[tostring(formationId)]) then break end
                      local filter = string.split(tostring(formationData[tostring(formationId)].filter), ",")
                      table.walk(filter, function(v, k)
                          filter[k] = tonumber(filter[k])
                      end)
                     self._data._formationDataCache[formationId].filter = filter
                 until true
            end
        end
        self._data._formationData = clone(self._data._formationDataCache) 
        self._defaultFormationId = self._defaultFormationIdCache
        self._formationDataChanged = {}
        self:updateTeamLoadedMap()
    end
    self:reflashData()

end

--检测荣耀竞技场防御编组，如果是nil初始化成
function FormationModel:private_saveGloryArenaBattleFormationData(success, data)
    if success then 
        if data then
            local formationData = data
            for formationId = FormationModel.kFormationTypeGloryArenaDef1, FormationModel.kFormationTypeGloryArenaDef3 do
                if formationData[tostring(formationId)] and not self._data._formationDataCache[formationId] then
                    self._data._formationDataCache[formationId] = clone(formationData[tostring(formationId)])
                end
                 repeat
                     if not (self._data._formationDataCache[formationId] and formationData[tostring(formationId)]) then break end
                      local filter = string.split(tostring(formationData[tostring(formationId)].filter), ",")
                      table.walk(filter, function(v, k)
                          filter[k] = tonumber(filter[k])
                      end)
                     self._data._formationDataCache[formationId].filter = filter
                 until true
            end
        end
        self._data._formationData = clone(self._data._formationDataCache) 
        self._defaultFormationId = self._defaultFormationIdCache
        self._formationDataChanged = {}
        self:updateTeamLoadedMap()
    end
    self:reflashData()
end


function FormationModel:private_saveAllFormationData(success, formationId1, formationId2, data)
    if success then 
        if data and data["d"] and data["d"]["formations"] then
            local formationData = data["d"]["formations"]
            for formationId = formationId1, formationId2 do
                repeat
                    if not (self._data._formationDataCache[formationId] and formationData[tostring(formationId)] and formationData[tostring(formationId)].filter) then break end
                    local filter = string.split(tostring(formationData[tostring(formationId)].filter), ",")
                    table.walk(filter, function(v, k)
                        filter[k] = tonumber(filter[k])
                    end)
                    self._data._formationDataCache[formationId].filter = filter
                until true

                repeat
                    if not (self._data._formationDataCache[formationId] and formationData[tostring(formationId)] and formationData[tostring(formationId)].lt) then break end
                    local lt = tonumber(formationData[tostring(formationId)].lt)
                    self._data._formationDataCache[formationId].lt = lt
                until true
            end
        end
        self._data._formationData = clone(self._data._formationDataCache) 
        self._defaultFormationId = self._defaultFormationIdCache
        self._formationDataChanged = {}
        self:updateTeamLoadedMap()
    end
    self:reflashData()
end

function FormationModel:private_dealWithFormationFilterByType(formationType)
    local formationId = self:formationTypeToId(formationType)
    local data = self._data._formationData[formationId]

    local isFiltered = function(teamId)
        for k, v in pairs(data.filter) do
            if v == teamId then
                return true
            end
        end
        return false
    end

    if data then
        for k, v in pairs(data) do
            repeat 
                if 0 == v then break end
                if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and isFiltered(v) then
                    data[tostring(k)] = 0
                end 
            until true
        end
    end
end

function FormationModel:isHaveWeapon(formationType)
    return SystemUtils:enableWeapon() and 
           (formationType == FormationModel.kFormationTypeCommon or
           ((formationType == FormationModel.kFormationTypeArena or formationType == FormationModel.kFormationTypeArenaDef) and (self._userModel:getData().lvl >= 16)) or
           formationType == FormationModel.kFormationTypeCrusade or
           formationType == FormationModel.kFormationTypeLeague or
           formationType == FormationModel.kFormationTypeGodWar1 or
           formationType == FormationModel.kFormationTypeGodWar2 or
           formationType == FormationModel.kFormationTypeGodWar3 or
           formationType == FormationModel.kFormationTypeCityBattle1 or
           formationType == FormationModel.kFormationTypeCityBattle2 or
           formationType == FormationModel.kFormationTypeCityBattle3 or
           formationType == FormationModel.kFormationTypeCityBattle4 or
           formationType == FormationModel.kFormationTypeGuild or
           formationType == FormationModel.kFormationTypeGuildDef or
           formationType == FormationModel.kFormationTypeWeapon or 
           formationType == FormationModel.kFormationTypeCrossPKAtk1 or 
           formationType == FormationModel.kFormationTypeCrossPKAtk2 or 
           formationType == FormationModel.kFormationTypeCrossPKAtk3 or 
           formationType == FormationModel.kFormationTypeCrossPKDef1 or 
           formationType == FormationModel.kFormationTypeCrossPKDef2 or 
           formationType == FormationModel.kFormationTypeCrossPKDef3 or
           formationType == FormationModel.kFormationTypeClimbTower or 
           formationType == FormationModel.kFormationTypeCrossGodWar1 or 
           formationType == FormationModel.kFormationTypeCrossGodWar2 or 
           formationType == FormationModel.kFormationTypeCrossGodWar3 or 
           formationType == FormationModel.kFormationTypeCrossPKFight or 
           formationType == FormationModel.kFormationTypeGloryArenaAtk1 or 
           formationType == FormationModel.kFormationTypeGloryArenaAtk2 or 
           formationType == FormationModel.kFormationTypeGloryArenaAtk3 or 
           formationType == FormationModel.kFormationTypeGloryArenaDef1 or 
           formationType == FormationModel.kFormationTypeGloryArenaDef2 or 
           formationType == FormationModel.kFormationTypeGloryArenaDef3 or 
           formationType == FormationModel.kFormationTypeStakeAtk1 or 
           formationType == FormationModel.kFormationTypeStakeAtk2 or 
           formationType == FormationModel.kFormationTypeStakeDef2 or 
           formationType == FormationModel.kFormationTypeWorldBoss)
end

function FormationModel:updateFormationDataByType(formationType, formationData)
    --print("updateFormationDataByType", formationType)
    --dump(formationData, "formationData", 5)
    local formationId = self:formationTypeToId(formationType)
    local data = self._data._formationData[formationId]
    local dataCache = self._data._formationDataCache[formationId]
    if formationData then
        if not formationData.filter then
            if data and data.filter then
                formationData.filter = data.filter
            else
                formationData.filter = {}
            end
        elseif formationData.filter and type(formationData.filter) == "string" then
            local filter = string.split(tostring(formationData.filter), ",")
            table.walk(filter, function(v, k)
                filter[k] = tonumber(filter[k])
            end)
            formationData.filter = filter
        end
        if not (data or formationData.heroId) then
            formationData.heroId = tab:Setting("G_INITIAL_HERO_BUZHEN").value -- fixed me
        end
    else
        formationData = { lt = 0, heroId = tab:Setting("G_INITIAL_HERO_BUZHEN").value, filter = {} } -- fixed me
        for i=1, 8 do
            formationData["team" .. i] = 0
            formationData["g" .. i] = 0
        end
    end
    if not data then
        self._data._formationData[formationId] = {}
        data = self._data._formationData[formationId]

        self._data._formationDataCache[formationId] = {}
        dataCache = self._data._formationDataCache[formationId]
    end
    -- dump(formationData, "formationData before change", 5)
    table.merge(data, formationData)
    table.merge(dataCache, formationData)
    -- dump(data, "data after change", 5)
    self._formationDataChanged[formationType] = true
end

function FormationModel:getAllFormationType()
    return clone(self._allFormationType)
end

function FormationModel:updateAllFormationData(allFormationData)
    local allFormationType = self:getAllFormationType()
    for _, formationType in ipairs(allFormationType) do
        repeat
            if not allFormationData[tostring(formationType)] then break end
            self:updateFormationDataByType(formationType, allFormationData[tostring(formationType)])
        until true
    end
    self._data._formationDataCache = clone(self._data._formationData)
end

function FormationModel:setFormationData(data)
    --dump(data, "FormationModel:data")
    local realData = {}
    if not data then
        realData[1] = { lastUpTime = 0, heroId = tab:Setting("G_INITIAL_HERO_BUZHEN").value, filter = {} } -- fixed me
        for i = 1, 8 do
            realData[1]["team" .. i] = 0
            realData[1]["g" .. i] = 0
        end
    else
        local keys = table.keys(data)
        local count = table.nums(keys)
        for _, v in ipairs(keys) do
            repeat
                if data and data[v] then 
                    realData[tonumber(v)] = data[v]
                    if not realData[tonumber(v)].heroId then
                        realData[tonumber(v)].heroId = tab:Setting("G_INITIAL_HERO_BUZHEN").value -- fixed me
                    end
                    if not realData[tonumber(v)].filter or realData[tonumber(v)].filter == "" then
                        realData[tonumber(v)].filter = {} -- fixed me
                    elseif realData[tonumber(v)].filter and type(realData[tonumber(v)].filter) == "string" then
                        local filter = string.split(tostring(realData[tonumber(v)].filter), ",")
                        table.walk(filter, function(v, k)
                            filter[k] = tonumber(filter[k])
                        end)
                        realData[tonumber(v)].filter = filter
                    end
                    break 
                end
                realData[tonumber(v)] = { lt = 0, heroId = tab:Setting("G_INITIAL_HERO_BUZHEN").value, filter = {} } -- fixed me
                for j=1, 8 do
                    realData[tonumber(v)]["team" .. j] = 0
                    realData[tonumber(v)]["g" .. j] = 0
                end
            until true
        end 
    end

    --dump(realData, "FormationModel:realData")
    self._data._formationData = realData
    self._data._formationDataCache = clone(self._data._formationData)
    self._defaultFormationId = 1 -- version 2.0 --[[ -- version 1.0 self._modelMgr:getModel("UserModel"):getData().defaultForId or 1]]
    self._defaultFormationIdCache = self._defaultFormationId
    self._formationDataChanged = {}
    self:initTeamLoadedMap()
    self:reflashData()
end

function FormationModel:getDefaultFormationData()
    if not self._data._formationData then return {} end
    return self._data._formationData[self._defaultFormationId] and clone(self._data._formationData[self._defaultFormationId]) or {}
end

function FormationModel:getDefaultFormationCount()
    local formationData = self:getDefaultFormationData()
    local team_count = 0
    table.walk(formationData, function(v, k)
        if 0 == v then return end
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            team_count = team_count + 1
        end
    end)
    return team_count
end

function FormationModel:getFormationData()
    return self._data._formationData
end

function FormationModel:getFormationDataByType(formationType)
    local formationId = self:formationTypeToId(formationType)
    local data = clone(self._data._formationData[formationId])
    if not data then
        data = { lastUpTime = 0, heroId = tab:Setting("G_INITIAL_HERO_BUZHEN").value, filter = {} }
        for j=1, 8 do
            data["team" .. j] = 0
            data["g" .. j] = 0
        end
    end
    return data
end

function FormationModel:isFormationDataExistByType(formationType)
    local formationId = self:formationTypeToId(formationType)
    return not not self._data._formationData[formationId]
end

function FormationModel:getFormationTeamDataByType(formationType)
    local teams = {}
    local formationId = self:formationTypeToId(formationType)
    local data = clone(self._data._formationData[formationId])
    if not data then
        data = { lastUpTime = 0, heroId = tab:Setting("G_INITIAL_HERO_BUZHEN").value, filter = {} }
        for j=1, 8 do
            data["team" .. j] = 0
            data["g" .. j] = 0
        end
    end
    for k, v in pairs(data) do
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            table.insert(teams, v)
        end
    end
    return teams
end

function FormationModel:getFormationDataByTypeWithFilter(formationType)
    local formationId = self:formationTypeToId(formationType)
    local data = clone(self._data._formationData[formationId])
    local filterCount = 0
    if not data then
        data = { lastUpTime = 0, heroId = tab:Setting("G_INITIAL_HERO_BUZHEN").value, filter = {} }
        for j=1, 8 do
            data["team" .. j] = 0
            data["g" .. j] = 0
        end
    end

    local isFiltered = function(teamId)
        for k, v in pairs(data.filter) do
            if v == teamId then
                return true
            end
        end
        return false
    end

    for k, v in pairs(data) do
        repeat 
            if 0 == v then break end
            if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and isFiltered(v) then
                data[tostring(k)] = 0
                filterCount = filterCount + 1
            end 
        until true
    end

    return data, filterCount
end

function FormationModel:setFormationDataSpecialHero(heroId)
    --[[
    self:resetFormationDataSpecialHero()
    if 0 == heroId then return end
    local formationId = self:formationTypeToId(FormationModel.kFormationTypeCommon)
    local formationData = self._data._formationData[formationId]
    if not formationData then return end
    self._comFormationDataOriginHeroId = formationData.heroId
    formationData.heroId = heroId
    ]]
end

function FormationModel:resetFormationDataSpecialHero()
    --[[
    if not self._comFormationDataOriginHeroId then return end
    local formationId = self:formationTypeToId(FormationModel.kFormationTypeCommon)
    local formationData = self._data._formationData[formationId]
    if not formationData then return end
    formationData.heroId = self._comFormationDataOriginHeroId
    self._comFormationDataOriginHeroId = nil
    ]]
end

function FormationModel:isWeaponTipsShow(formationType)
    return SystemUtils:enableWeapon() and 1 ~= SystemUtils.loadAccountLocalData("FORMATION_WEAPON_TIPS_SHOW_" .. formationType)
end

function FormationModel:setWeaponTipsShowed(formationType)
    SystemUtils.saveAccountLocalData("FORMATION_WEAPON_TIPS_SHOW_" .. formationType, 1)
end

function FormationModel:isHaveWeaponCanLoaded(formationType)
    if not (SystemUtils:enableWeapon() and 4 == self._weaponsModel:getWeaponState()) then return false end
    local formationData = self._data._formationData[formationType]
    if not formationData then return false end
    local found = false
    for i=1, 3 do--仅用于攻击，可上阵只有三种器械，类型4主城无法上阵，所以只遍历三种判断
        local weaponId = formationData["weapon" .. i]
        if not weaponId or 0 == weaponId then
            local weaponData = self._weaponsModel:getWeaponsDataByType(i)
            if weaponData then
                local unlockIds = weaponData["unlockIds"]
                if unlockIds and type(unlockIds) == "table" then
                    local ids = table.keys(weaponData["unlockIds"])
                    if ids and type(ids) == "table" and #ids > 0 then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function FormationModel:dealWithFormationDataByTypeWithCondition(formationType, filter, position, count)
    if not (formationType == FormationModel.kFormationTypeCloud1 or formationType == FormationModel.kFormationTypeCloud2) then return end
    local formationId = self:formationTypeToId(formationType)
    local formationData = self._data._formationData[formationId]
    if not formationData then return end
    local changed = false
    formationData.filter = filter
    local isFiltered = function(id)
        for k, v in pairs(formationData.filter) do
            if v == id then
                return true
            end
        end
        return false
    end

    local isPositionWall = function(positionId)
        for k, v in pairs(position) do
            if v == positionId then
                return true
            end
        end
        return false
    end

    for k, v in pairs(formationData) do
        repeat 
            if 0 == v then break end
            if (string.find(tostring(k), "team") and not string.find(tostring(k), "g") and isFiltered(v)) or
               (string.find(tostring(k), "g") and isPositionWall(v)) then
                local n = tonumber(string.sub(tostring(k), -1))
                formationData["team" .. n] = 0
                formationData["g" .. n] = 0
                changed = true
            end
        until true
    end

    if count then
        local team_count = 0
        for k, v in pairs(formationData) do
            repeat
                if 0 == v then break end
                if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
                    team_count = team_count + 1
                end
            until true
        end

        if team_count > count then
            for i = 1, team_count - count do
                for k, v in pairs(formationData) do
                    local found = false
                    repeat 
                        if 0 == v then break end
                        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
                            local n = tonumber(string.sub(tostring(k), -1))
                            formationData["team" .. n] = 0
                            formationData["g" .. n] = 0
                            found = true
                        end
                    until true
                    if found then
                        changed = true
                        break
                    end
                end
            end
        end
    end

    local heroId = formationData.heroId
    if isFiltered(heroId) then
        formationData.heroId = 0
        changed = true
    end

    if changed then
       self._formationDataChanged[formationType] = true
    end

    self._data._formationDataCache = clone(self._data._formationData)
end

function FormationModel:isFormationDataChanged(formationType)
    return not not self._formationDataChanged[formationType] 
end

function FormationModel:getFormationTeamCountWithFilter(formationType)
    local data, filterCount = self:getFormationDataByTypeWithFilter(formationType)
    local team_count = 0
    table.walk(data, function(v, k)
        if 0 == v then return end
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            team_count = team_count + 1
        end
    end)
    return team_count, filterCount, #data.filter, self:isFormationTeamFullByType(self.kFormationTypeCrusade)
end

function FormationModel:isTeamLoaded(id)
    --[[
    if not self._teamLoadedMap then
        self:initTeamLoadedMap()
    end
    ]]
    return self._teamLoadedMap[tonumber(id)]
    --[[
    local formationData = self._data._formationData[FormationModel.kFormationTypeCommon]
    if not formationData then return false end
    for k, v in pairs(formationData) do
        repeat 
            if 0 == v then break end
            if string.find(tostring(k), "team") and not string.find(tostring(k), "g") and v == id then
                return true
            end 
        until true
    end

    return false
    ]]
end

function FormationModel:initTeamLoadedMap()
    --if self._teamLoadedMap then return end
    --self._teamLoadedMap = {}
    self:updateTeamLoadedMap()
end

function FormationModel:updateTeamLoadedMap()
    --[[
    if not self._teamLoadedMap then
        self:initTeamLoadedMap()
    end
    ]]
    local formationData = self._data._formationData[FormationModel.kFormationTypeCommon]
    if not formationData then return end
    self._teamLoadedMap = {}
    self._backupTeamLoadedMap = {}
    for i = 1, 8 do
        if formationData["team"..i] ~= 0 then
            self._teamLoadedMap[formationData["team"..i]] = true
        end
    end
    local backupTs = formationData.backupTs or {}
    if formationData.bid then
        local btData = backupTs[tostring(formationData.bid)] or {}
        for i = 1, 3 do
            local teamId = btData["bt" .. i]
            if teamId and teamId ~= 0 then
                self._backupTeamLoadedMap[teamId] = true
            end
        end
    end
end

function FormationModel:getTeamLoadedMap()
    --[[
    if not self._teamLoadedMap then
        self:initTeamLoadedMap()
    end
    ]]
    return self._teamLoadedMap, self._backupTeamLoadedMap
    --[=[
    if self._data == nil or self._data._formationData == nil then return {} end
    local formationData = self._data._formationData[FormationModel.kFormationTypeCommon]
    local map = {}
    for i = 1, 8 do
        if formationData["team"..i] ~= 0 then
            map[formationData["team"..i]] = true
        end
    end
    return map
    ]=]
end

function FormationModel.getFormationDialogShowed()
    return FormationModel.isFormationDialogShowed
end

function FormationModel.setFormationDialogShowed(isShow)
    FormationModel.isFormationDialogShowed = isShow
end

function FormationModel:formationTypeToId(formationType)
    return formationType
    --[[
    if formationType == FormationModel.kFormationTypeArena then
        return 2
    elseif formationType == FormationModel.kFormationTypeAiRenMuWu then
        return 3
    elseif formationType == FormationModel.kFormationTypeZombie then
        return 4
    elseif formationType == FormationModel.kFormationTypeDragon then
        return 5
    elseif formationType == FormationModel.kFormationTypeCrusade then
        return 6
    else
        return 1
    end
    ]]
end 

function FormationModel:getFormationNameById(formationId)
    return self.kFormationName[formationId] and self.kFormationName[formationId] or "其他玩法编组"
end

function FormationModel:getMaxFormationCount()
    return #self:getAllFormationType()
end

function FormationModel:getCommonFormationCount()
    return self:getFormationCountByType(self.kFormationTypeCommon)
end

function FormationModel:isCommonFormationTeamFull()
    return self:isFormationTeamFullByType(self.kFormationTypeCommon)
end

function FormationModel:getFormationCountByType(formationType)
    local formationData = self:getFormationDataByType(formationType)
    local team_count = 0
    table.walk(formationData, function(v, k)
        if 0 == v then return end
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            team_count = team_count + 1
        end
    end)
    return team_count
end

function FormationModel:isFormationTeamFullByType(formationType)
    local currentLoadedTeamCount = self:getFormationCountByType(formationType)
    local currentNotLoadedTeamCount = #self._teamModel:getData() - currentLoadedTeamCount
    local currentAllowedTeamCount = self._userModel:getData().formationTeamNum
    return currentNotLoadedTeamCount <= 0 or currentLoadedTeamCount >= currentAllowedTeamCount
end

--返回该编组后援是否有红点
-- 0：后援无可操作的
-- 1：没有使用后援
-- 2：有空位
-- 3：有冲突
function FormationModel:isFormationBackupFullByType( formationType )
    local backupModel = self._modelMgr:getModel("BackupModel")
    if not table.indexof(FormationModel.kBackupFormation, tonumber(formationType)) or not backupModel:isOpen() then
        return 0
    end
    local formationData = self:getFormationDataByType(formationType)

    if not formationData.bid then
        return 1
    end

    local teamUsing = {}
    for i = 1, FormationModel.kTeamMaxCount do
        local teamId = formationData["team" .. i]
        if teamId and teamId ~= 0 then
            table.insert(teamUsing, teamId)
        end
    end
    
    local isHaveEmptySeat = backupModel:isHaveEmptySeat(formationData.backupTs, formationData.bid, {}, clone(teamUsing))
    if isHaveEmptySeat then
        return 2
    end

    local isHaveConflictTeam = backupModel:isHaveConflictTeam(formationData.backupTs, formationData.bid, clone(teamUsing))
    if isHaveConflictTeam then
        return 3
    end
    return 0
end

function FormationModel.decodeFilterString(filter)
    if not filter then return {}
    elseif type(filter) == "table" then
        return filter
    elseif type(filter) == "string" then
        local result = {}
        filter = string.split(tostring(filter), ",")
        table.walk(filter, function(v, k)
            result[k] = tonumber(filter[k])
        end)
        return result
    end
    return {}
end

function FormationModel:updateFormationFilter(formationId, data)
    if not self._data._formationData[formationId] then return end
    local filter = {}
    if data.filter and type(data.filter) == "string" then
        filter = string.split(tostring(data.filter), ",")
        table.walk(filter, function(v, k)
            filter[k] = tonumber(filter[k])
        end)
    end
    data.filter = filter
    table.merge(self._data._formationData[formationId], data)
end

function FormationModel:getCurrentFightScoreByType(formationType, specifiedFormationData, isHireTeamLoaded, hireTeamId, userId, isFixedWeapon)
    local data = specifiedFormationData or self:getFormationDataByTypeWithFilter(formationType)
    local usingTeamList = {}
    local fightScore = 0
    table.walk(data, function(v, k)
        if 0 == v then return end
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            table.insert(usingTeamList, tonumber(v))
            local teamData = self._teamModel:getTeamAndIndexById(v)
            if isHireTeamLoaded and v == hireTeamId then
                teamData = self._guildModel:getEnemyDataById(hireTeamId, userId)
            end
            -- ugly code
            if not teamData then
                teamData = tab:Npc(v)
            end
            -- ugly code
            if teamData and teamData.score then
                if isHireTeamLoaded and teamData.pscore then
                    fightScore = fightScore + teamData.score - teamData.pscore
                else
                    fightScore = fightScore + teamData.score
                end
            end
        end
    end)
    --冠军对决 NPC英雄用固定的英雄战力计算总战力  edit by yuxiaojing
    if formationType == FormationModel.kFormationTypeLeague then
        fightScore = fightScore + tab:Setting("G_LEAGUE_HEROSCORE").value
    else
        if 0 ~= data.heroId then
            local heroData = self._heroModel:getData()[tostring(data.heroId)]
            print("hero data:", heroData)
            -- ugly code
            if not heroData then
                heroData = tab:NpcHero(data.heroId)
                print("hero data:", heroData)
            end

            if not heroData then
                heroData = self._leagueModel:getMyHeroData(data.heroId)
                print("hero data:", heroData)
            end
            -- ugly code
            if heroData and heroData.score then
                fightScore = fightScore + heroData.score
            end
        end
    end

    if isFixedWeapon then
        for i=1, 3 do
            local weaponId = data["weapon" .. i]
            if weaponId and 0 ~= weaponId then
                local weaponTableData = tab:SiegeWeaponNpc(weaponId)
                if weaponTableData and weaponTableData.score then
                    fightScore = fightScore + weaponTableData.score
                end
            end
        end
    else
        for i=1, 4 do
            local weaponId = data["weapon" .. i]
            if weaponId and 0 ~= weaponId then
                local weaponScore = self._weaponsModel:getWeaponScore(weaponId, i)
                if weaponScore then
                    fightScore = fightScore + weaponScore
                end
            end
        end
    end

    fightScore = fightScore + self._skillTalentModel:getTotalScore()

    if formationType ~= FormationModel.kFormationTypeTraining then
        fightScore = fightScore + self._treasureModel:getTreasureScore()
        local talentScore = self._talentModel:getBattleNum()
        fightScore = fightScore + talentScore
    end
    -- 后援 战力
    local backupData = self._modelMgr:getModel("BackupModel"):getBackupData() or {}
    for k, v in pairs(backupData) do
        if v and v.as then
            fightScore = fightScore + (v.as or 0)
        end
    end
    if table.indexof(FormationModel.kBackupFormation, formationType) then
        local backupTs = data.backupTs or {}
        local useBid = data.bid
        for k, v in pairs(backupData) do
            if tonumber(k) == tonumber(useBid) and v and v.score then
                fightScore = fightScore + (v.score or 0)
                local tsData = backupTs[tostring(useBid)] or {}
                for i = 1, 3 do
                    local teamId = tsData["bt" .. i]
                    if teamId and teamId ~= 0 and not table.indexof(usingTeamList, tonumber(teamId)) then
                        local teamData = self._teamModel:getTeamAndIndexById(teamId)
                        if teamData then
                            fightScore = fightScore + (teamData.score or 0)
                        end
                    end
                end
            end
        end
    end

    fightScore = fightScore + self._starChartsModel:getStarChartsScore(self._userModel:getHeroStarInfo())

    return fightScore
end
--[[
function FormationModel:onPushHeroDuelEvent(success, data)
    if not success then return end
    local heroDuelEvent = cc.EventCustom:new("HERO_DUEL_EVENT")
    heroDuelEvent.data = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(heroDuelEvent)
end
]]

function FormationModel:initBattleData(formationType, specifiedFormationData)
    local result = {}
    local formationData = specifiedFormationData and specifiedFormationData or self:getFormationDataByTypeWithFilter(formationType)
    local currentHid = formationData.heroId
    local heroData = self._heroModel:getData()[tostring(currentHid)]
    local npcHero = false
    if not heroData then
        -- ugly code
        if not heroData then
            heroData = clone(tab:NpcHero(currentHid))
            print("hero data:", heroData)
            npcHero = true
        end

        if not heroData then
            heroData = self._leagueModel:getMyHeroData(currentHid)
            print("hero data:", heroData)
            npcHero = true
        end
        -- ugly code
        if not heroData then
            dump(formationData, "formationData")
            print("invalid hero id", currentHid)
        end
    end
    local hero = {}
    if not npcHero then
        hero = {id = currentHid, level = self._userModel:getData().lvl, slevel = {1, 1, 1, 1, 1}, 
                            star = heroData.star, mastery = {},sc = hero.sc}
    else
        hero = { npcHero = true, id = currentHid}
    end

    local isFiltered = function(teamId)
        if not (formationData.filter and "table" == type(formationData.filter)) then return end
        local found = false
        for k, v in pairs(formationData.filter) do
            if v == teamId then
                found = true
                break
            end
        end
        return found
    end

    local playerInfo = {}
    if formationType ~= FormationModel.kFormationTypeTraining then
        playerInfo = {team = {}, hero = hero, pokedex = self._pokedexModel:getScore(), globalMasterys = self._userModel:getGlobalMasterys(), 
                            treasure = self._treasureModel:getData(), talent = self._talentModel:getData(),
                            hStar = self._userModel:getHeroStarInfo(),qhab = self._userModel:getHeroStarHAb()}
        if not npcHero then
            for i = 1, 4 do
                repeat
                    local mastery = heroData["m" .. i]
                    if not mastery then break end
                    table.insert(playerInfo.hero.mastery, tonumber(mastery))
                until true
            end

            for i = 1, 4 do
                repeat
                    local spellLvl = heroData["sl" .. i]
                    if not spellLvl then break end
                    playerInfo.hero.slevel[i] = spellLvl
                until true
            end

            local artifacts = self._userModel:getData().artifacts
            dump(artifacts, "artifacts")
            if artifacts then 
                for i = 1, 6 do
                    repeat
                        local artifact = heroData["artifact" .. i]
                        if not artifact then break end
                        local stage = artifacts[tostring(artifact)].stage or 1
                        table.insert(playerInfo.hero.equip, {id = tonumber(artifact), stage = tonumber(stage)})
                    until true
                end
            end
        end

        local tSkinData = self._userModel:getTeamSkinData()
        local team
        table.walk(formationData, function(v, k)
            if string.find(tostring(k), "g") or 0 == v or isFiltered(v) then return end
            if string.find(tostring(k), "team") then
                local teamData = self._teamModel:getTeamAndIndexById(v)
                if teamData then
                    local teamTableData = tab:Team(teamData.teamId)
                    local tSkin = nil
                    if tSkinData and next(tSkinData) then
                        if tSkinData[tostring(teamData.teamId)] or tSkinData[teamData.teamId] then
                            tSkin = tSkinData[tostring(teamData.teamId)] or tSkinData[teamData.teamId]
                        end
                    end
                    local jxTree = teamData.tree or {}
                    team = {
                            id = teamData.teamId,
                            pos = tonumber(formationData[string.format("g%d", tonumber(string.sub(tostring(k), -1)))]),
                            level = teamData.level,
                            star = teamData.star,
                            smallStar = teamData.smallStar,
                            stage = teamData.stage,
                            dhr = teamData.dhr,
                            -- 里属性
                            avn = teamData.avn,
                            pl = clone(teamData.pl),
                            -- 天赋
                            tmScore = teamData.tmScore,
                            equip = {
                                        {
                                            stage = teamData.es1,
                                            level = teamData.el1
                                        },

                                        {
                                            stage = teamData.es2,
                                            level = teamData.el2
                                        },

                                        {
                                            stage = teamData.es3,
                                            level = teamData.el3
                                        },

                                        {
                                            stage = teamData.es4,
                                            level = teamData.el4
                                        },
                                    },
                            skill = {teamData.sl1, teamData.sl2, teamData.sl3, teamData.sl4},
                            -- 觉醒
                            jx = tonumber(teamData.ast) == 3,
                            jxLv = tonumber(teamData.aLvl),
                            jxSkill1 = jxTree.b1,
                            jxSkill2 = jxTree.b2,
                            jxSkill3 = jxTree.b3,
                            data = clone(teamData),
                            sId = teamData.sId or 0,
                            tSkin = tSkin,
                       }
                    if team.jxSkill1 == 0 then team.jxSkill1 = nil end
                    if team.jxSkill2 == 0 then team.jxSkill2 = nil end
                    if team.jxSkill3 == 0 then team.jxSkill3 = nil end
                    table.insert(playerInfo.team, team)
                end
            end
        end)
    else
        playerInfo = {lv = 1, npc = {}, hero = hero}
        table.walk(formationData, function(v, k)
            if string.find(tostring(k), "g") or 0 == v or isFiltered(v) then return end
            if string.find(tostring(k), "team") then
                local team = {[1] = v, [2] = tonumber(formationData[string.format("g%d", tonumber(string.sub(tostring(k), -1)))])}
                table.insert(playerInfo.npc, team)
            end
        end)
    end

    table.insert(result, playerInfo)
    --[[
    if 2 == self._stage_formation._data.type then
        local enemyData = self._stage_formation._data
        local enemyInfo = {team = {}, hero = {id = BattleUtils.RIGHT_HERO_ID, level = BattleUtils.RIGHT_HERO_LEVEL, slevel = BattleUtils.RIGHT_HERO_SKILL_LEVEL, mastery = BattleUtils.RIGHT_HERO_MASTERY}, 
                            pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}
        local team
        table.walk(enemyData, function(v, k)
            if string.find(tostring(k), "g") or 0 == v then return end
            if string.find(tostring(k), "team") then
                local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(v)
                local teamTableData = tab:Team(teamData.teamId)
                team = {
                        id = teamData.teamId,
                        pos = tonumber(data[string.format("g%d", tonumber(string.sub(tostring(k), -1)))]),
                        level = teamTableData.level,
                        star = teamData.star,
                        smallStar = teamData.smallStar,
                        stage = teamData.stage,
                        equip = {
                                    {
                                        stage = teamData.es1,
                                        level = teamData.el1
                                    },

                                    {
                                        stage = teamData.es2,
                                        level = teamData.el2
                                    },

                                    {
                                        stage = teamData.es3,
                                        level = teamData.el3
                                    },

                                    {
                                        stage = teamData.es4,
                                        level = teamData.el4
                                    },
                                },
                        skill = {teamData.sl1, teamData.sl2, teamData.sl3, teamData.sl4}
                   }
                table.insert(enemyInfo.team, team)
            end 
        end)
        table.insert(result, enemyInfo)
    end 
    ]]
    return result
end

function FormationModel:getAllRelationBuilds(teams, heroId)
    local fBuildCfg = clone(tab.formation_build)
    local fHeroCfg = clone(tab.formation_hero)
    local fTeamCfg = clone(tab.formation_team)

    if not fBuildCfgReverse then
        fBuildCfgReverse = {}
        local builds = fBuildCfg
        for k, v in ipairs(builds) do
            fBuildCfgReverse[k] = {}
            for i = 1, 4 do
                local build = v["build" .. i]
                for _, v0 in ipairs(build) do
                    if not fBuildCfgReverse[k][v0] then
                        fBuildCfgReverse[k][v0] = {}
                    end
                    table.insert(fBuildCfgReverse[k][v0], i)
                end
            end
        end
    end

    -- dump(fBuildCfgReverse, "fBuildCfgReverse[k][v0]", 10)

    local allBuilds = {}
    for i = 1, #fBuildCfg do
        allBuilds[i] = {{}, {}, {}, {}}
    end

    local buildsReverse = fBuildCfgReverse

    --dump(teams, "teams", 5)
    for teamId, _ in pairs(teams) do
        repeat
            local builds = fTeamCfg[teamId]
            if not builds then break end
            builds = builds["build"]
            if not builds then break end
            for _, build in ipairs(builds) do
                local buildId1 = build[1]
                local buildId2 = build[2]
                local relationItems = fBuildCfg[buildId1]["build" .. buildId2]
                if buildId2 < 3 then
                    for _, item in ipairs(relationItems) do
                        if teams[item] then
                            local buildIds = buildsReverse[buildId1][teamId]
                            if buildIds then
                                for _, id in ipairs(buildIds) do
                                    if not allBuilds[buildId1][id] then
                                        allBuilds[buildId1][id] = {}
                                    end
                                    allBuilds[buildId1][id][teamId] = true
                                end
                            end
                            buildIds = buildsReverse[buildId1][item]
                            if buildIds then
                                for _, id in ipairs(buildIds) do
                                    if not allBuilds[buildId1][id] then
                                        allBuilds[buildId1][id] = {}
                                    end
                                    allBuilds[buildId1][id][item] = true
                                end
                            end
                        end
                    end
                else
                    for _, item in ipairs(relationItems) do
                        if heroId == item then
                            local buildIds = buildsReverse[buildId1][teamId]
                            if buildIds then
                                for _, id in ipairs(buildIds) do
                                    print("buildId1:" .. buildId1)
                                    if not allBuilds[buildId1][id] then
                                        allBuilds[buildId1][id] = {}
                                    end
                                    allBuilds[buildId1][id][teamId] = true
                                end
                            end
                            buildIds = buildsReverse[buildId1][item]
                            if buildIds then
                                for _, id in ipairs(buildIds) do
                                    if not allBuilds[buildId1][id] then
                                        allBuilds[buildId1][id] = {}
                                    end
                                    allBuilds[buildId1][id][item] = true
                                end
                            end
                        end
                    end
                end
            end
        until true
    end

    if heroId and 0 ~= heroId then
        local builds = fHeroCfg[heroId]
        if builds then 
            builds = builds["build"]
            --dump(builds, "builds", 5)
            if builds then 
                for _, build in ipairs(builds) do
                    local buildId1 = build[1]
                    local buildId2 = build[2]
                    local relationItems = fBuildCfg[buildId1]["build" .. buildId2]
                    if buildId2 < 3 then
                        for _, item in ipairs(relationItems) do
                            if teams[item] then
                                local buildIds = buildsReverse[buildId1][heroId]
                                for _, id in ipairs(buildIds) do
                                    if not allBuilds[buildId1][id] then
                                        allBuilds[buildId1][id] = {}
                                    end
                                    allBuilds[buildId1][id][heroId] = true
                                end
                                buildIds = buildsReverse[buildId1][item]
                                for _, id in ipairs(buildIds) do
                                    if not allBuilds[buildId1][id] then
                                        allBuilds[buildId1][id] = {}
                                    end
                                    allBuilds[buildId1][id][item] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- dump(allBuilds, "allBuilds", 10)

    return allBuilds
end

function FormationModel:showFormationEditView( params )
    -- self._serverMgr:sendMsg("UserServer", "getAreaSkillTeam", {}, true, {}, function ( result )
    self._viewMgr:showDialog("formation.FormationEditInfoDialog", params)
    -- end)
end

function FormationModel:getFieldSkillList( hireTeamData )
    local allTeamData = self._teamModel:getData()
    local result = {}
    local teamResult = {}
    for k, v in pairs(allTeamData) do
        local teamId = v.teamId
        local sysData = tab:Team(teamId)
        if sysData then
            local skill = sysData.skill or {}
            local skillInfo = nil
            for k1, v1 in pairs(skill) do
                local skillType = v1[1]
                local skillId = v1[2]
                local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
                if sysSkill and sysSkill.lingyu and sysSkill.lingyu == 1 then
                    skillInfo = clone(v1)
                    skillInfo[3] = teamId
                    break
                end
            end
            if skillInfo and v.sl7 and v.sl7 >= 1 then
                table.insert(result, skillInfo)
                table.insert(teamResult, skillInfo[3])
            end
        end
    end
    if hireTeamData then
        local teamId = hireTeamData.teamId
        local sysData = tab:Team(teamId)
        if sysData then
            local skill = sysData.skill or {}
            local skillInfo = nil
            for k1, v1 in pairs(skill) do
                local skillType = v1[1]
                local skillId = v1[2]
                local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
                if sysSkill and sysSkill.lingyu and sysSkill.lingyu == 1 then
                    skillInfo = clone(v1)
                    skillInfo[3] = teamId
                    break
                end
            end
            if skillInfo and hireTeamData.sl7 and hireTeamData.sl7 >= 1 and not table.indexof(teamResult, skillInfo[3]) then
                table.insert(result, skillInfo)
                table.insert(teamResult, skillInfo[3])
            end
        end
    end
    -- dump(result)
    return result, teamResult
end

function FormationModel:isShowFieldDialogByType( fType )
    return FormationModel.isShowFieldEmptyDialog[fType]
end

function FormationModel:setShowFieldDialogByType( fType )
    FormationModel.isShowFieldEmptyDialog[fType] = true
end

function FormationModel:isFieldSkillEmpty( formationId, hireTeamData )
    formationId = formationId or 1
    local formationData = self:getFormationDataByType(tonumber(formationId))
    if formationData.areaSkillTeam then
        return false
    end
    local _, fieldTeamList = self:getFieldSkillList(hireTeamData)
    if #fieldTeamList <= 0 then
        return false
    end
    local result = false
    table.walk(formationData, function(v, k)
        if not string.find(tostring(k), "team") then return end
        if 0 ~= v and table.indexof(fieldTeamList, v) then
            result = true
        end
    end)
    if hireTeamData then
        local teamId = hireTeamData.teamId
        if teamId and 0 ~= teamId and table.indexof(fieldTeamList, teamId) then
            result = true
        end
    end
    return result
end

function FormationModel:handleUnsetFormationData( unsetData )
    local tempData = {}
    for k, v in pairs(unsetData) do
        if string.find(k, ".") ~= nil then
            local temp = string.split(k, "%.")
            if temp[1] == "formations" and #temp == 3 then
                table.insert(tempData, clone(temp))
            end
        end
    end
    if #tempData <= 0 then
        return
    end
    local allFormationData = self._data._formationData
    for k, v in pairs(tempData) do
        if allFormationData[tonumber(v[2])] and allFormationData[tonumber(v[2])][v[3]] then
            allFormationData[tonumber(v[2])][v[3]] = nil
            self._formationDataChanged[tonumber(v[2])] = true
        end
    end
    self._data._formationDataCache = clone(self._data._formationData)
end

return FormationModel
