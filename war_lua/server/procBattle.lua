--[[
    Filename:    procBattle.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-11-24 17:23:47
    Description: File description
--]]
-- 全局标记, 用于提高效率
BATTLE_PROC = true
local DEBUG_PLAYER_INFO = false

require "game.GameStatic"
ScheduleMgr = require 'game.utils.ScheduleManager'
audioMgr = require("base.audio.AudioManager_null")
Random = require("game.utils.random").new()
socket = {}
socket.gettime = function () return 0 end
function GRandom(...)
    return ...
end
tab = require("game.config.DataTableManager").new(true)
local __print = print
if not BATTLE_PROC_TEST then
    print = function () end
    dump = function () end
end
BattleUtils = require "game.utils.BattleUtils"
require "game.utils.BattleUtils2"
GuildMapUtils = require "game.view.guild.map.GuildMapUtils"

delete = function ()
end
if cjson == nil then
    cjson = require "cjson"
end
if json == nil then
    json = cjson
end

local ERROR_CODE_SUCCESS = 0
local ERROR_CODE_WRONG_TYPE = 1 -- 传入战斗类型错误
local ERROR_CODE_RUN_ERROR = 2  -- 战中发生lua错误
local ERROR_CODE_NO_INTANCEID = 101  -- 没有副本ID
local ERROR_CODE_NO_ACTID = 102  -- 没有actId
local ERROR_CODE_NO_EXBATTLETIME = 103  -- 没有exBattleTime
local ERROR_CODE_NO_CRUSADEID = 104  -- 远征关卡ID
local ERROR_CODE_NO_CCTID = 105  -- 云中城ID
local ERROR_CODE_NO_CCTID2 = 106  -- 云中城ID
local ERROR_CODE_NO_TRAININGID = 107  -- 训练所ID
local ERROR_CODE_NO_ELE_KIND_ID = 108  -- 没有元素位面种类ID
local ERROR_CODE_NO_ELE_LEVEL_ID = 109  -- 没有元素位面关卡ID
local ERROR_CODE_NO_LEVEL_ID = 110  -- 没有关卡ID
local ERROR_CODE_NO_WALL_LEVEL = 111  -- 没有城墙等级

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
    __print(msg)
    return msg
end

function trycall(name, func, ...)
    local args = { ... }
    local a, b
    local ret = xpcall(function() a, b = func(unpack(args)) end, __G__TRACKBACK__)
    return ret, a, b
end

local result = nil
function proc(_type, jsondata)
    local ret, result = trycall("battle", proc_battle, _type, jsondata)
    BattleUtils.clearBattleRequire()
    if ret then
        return result
    else
        return cjson.encode({ret = ERROR_CODE_RUN_ERROR, msg = "ERROR_CODE_RUN_ERROR"})   
    end
end

local BATTLE_TYPE_Fuben = 1
local BATTLE_TYPE_Arena = 2
local BATTLE_TYPE_AiRenMuWu = 3
local BATTLE_TYPE_Zombie = 4
local BATTLE_TYPE_Siege = 5
local BATTLE_TYPE_BOSS_DuLong = 6
local BATTLE_TYPE_BOSS_XnLong = 7
local BATTLE_TYPE_BOSS_SjLong = 8
local BATTLE_TYPE_Crusade = 9
local BATTLE_TYPE_GuildPVE = 10
local BATTLE_TYPE_GuildPVP = 11
local BATTLE_TYPE_Biography = 12
local BATTLE_TYPE_League = 13
local BATTLE_TYPE_MF = 14               
local BATTLE_TYPE_CloudCity = 15        
local BATTLE_TYPE_CCSiege = 16       
local BATTLE_TYPE_GVG = 17                
local BATTLE_TYPE_GVGSiege = 18      
local BATTLE_TYPE_Training = 19   
local BATTLE_TYPE_Adventure = 20
local BATTLE_TYPE_HeroDuel = 21
local BATTLE_TYPE_GBOSS_1 = 22
local BATTLE_TYPE_GBOSS_2 = 23
local BATTLE_TYPE_GBOSS_3 = 24
local BATTLE_TYPE_GodWar = 25
local BATTLE_TYPE_Elemental_1 = 26
local BATTLE_TYPE_Elemental_2 = 27
local BATTLE_TYPE_Elemental_3 = 28
local BATTLE_TYPE_Elemental_4 = 29
local BATTLE_TYPE_Elemental_5 = 30
local BATTLE_TYPE_Siege_Atk = 31
local BATTLE_TYPE_Siege_Def = 32
local BATTLE_TYPE_Siege_Atk_WE = 33
local BATTLE_TYPE_Siege_Def_WE = 34
local BATTLE_TYPE_GuildFAM = 35
local BATTLE_TYPE_ServerArena = 36
local BATTLE_TYPE_ServerArenaFuben = 37
local BATTLE_TYPE_ClimbTower = 38

local proc_functions = {}
function proc_battle(_type, jsondata)
    local ret = nil
    local t = tonumber(_type)
    if proc_functions[t] then
        ret = proc_functions[t](jsondata)
    else
        ret = cjson.encode({ret = ERROR_CODE_WRONG_TYPE, msg = "ERROR_CODE_WRONG_TYPE"})
    end
    return ret
end
--[[
        1
        副本战斗复盘
        支持: 副本 精英副本 副本攻城战 副本支线
        参数: 
            atk: 左方数据
            intanceId: 副本id
            skill: 技能序列
            npcHero: 是否用npc英雄
        注意:   
            r1为id号
            helpCondition不为空 则不能复盘
 ]]--
local fuben_json
function proc_fuben_1(jsondata)
    if jsondata == "test" then
        jsondata = fuben_json
    end
    local data = cjson.decode(jsondata)
    if data.intanceId == nil then
        return cjson.encode({ret = ERROR_CODE_NO_INTANCEID, msg = "ERROR_CODE_NO_INTANCEID"})
    end
    -- npc英雄
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_Fuben(playerInfo, data.intanceId, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[1] = proc_fuben_1
local fubenid = 7100505
-- fuben_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"intanceId\":"..fubenid.."}"

--[[
        2
        竞技场战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
local arena_json
function proc_arena_2(jsondata)
    if jsondata == "test" then
        jsondata = arena_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    local r1 = data.r1
    local r2 = data.r2
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_Arena(playerInfo, enemyInfo, r1, r2, 0, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[2] = proc_arena_2
-- arena_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"def\":{\"rid\":\"9992_22\",\"usid\":\"999251342147\",\"avatar\":1104,\"name\":\"二狗gogoo\",\"msg\":\"\",\"lv\":80,\"vipLvl\":15,\"score\":1426500,\"hero\":{\"star\":4,\"m1\":62153,\"m2\":62023,\"m3\":62033,\"m4\":62003,\"sl1\":21,\"sl2\":21,\"sl3\":21,\"sl4\":22,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":101923,\"spellNums\":\"0,0,0,0\",\"new1\":62222,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"2,3,4\"},\"globalSpecial\":\"[501022,503013,503032,503023]\",\"formation\":{\"score\":1426500,\"g1\":11,\"team1\":107,\"g2\":15,\"team2\":307,\"g3\":5,\"team3\":102,\"g4\":9,\"team4\":203,\"g5\":7,\"team5\":507,\"g6\":3,\"team6\":407,\"g7\":6,\"team7\":207,\"g8\":10,\"team8\":306,\"lastUpTime\":1473079027,\"heroId\":60301},\"teams\":{\"107\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58597,\"pScore\":14869,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512526},\"307\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":47723,\"pScore\":5188,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512529},\"102\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":52457,\"pScore\":16060,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471502220},\"203\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":54122,\"pScore\":15237,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503691},\"507\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":50268,\"pScore\":6540,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512517},\"407\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":55514,\"pScore\":11786,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"recordTime\":1471512520},\"207\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58031,\"pScore\":15496,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512524},\"306\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":56117,\"pScore\":13582,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503482}},\"pokedex\":[12647,9381,11868,2560,6040,5120,3480,2805,4760,1432],\"treasures\":{\"21\":{\"stage\":12,\"comScore\":27672,\"disScore\":16956,\"treasureDev\":{\"40211\":12,\"40212\":12,\"40213\":12}},\"10\":{\"stage\":12,\"comScore\":24417,\"disScore\":48427,\"treasureDev\":{\"40103\":12,\"40102\":12,\"40101\":12}},\"30\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40301\":12,\"40302\":12,\"40303\":12,\"40304\":12}},\"31\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":58057,\"disScore\":160335,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"11\":{\"stage\":12,\"comScore\":14108,\"disScore\":5322,\"treasureDev\":{\"40111\":12,\"40112\":12,\"40113\":12}},\"22\":{\"stage\":12,\"comScore\":18991,\"disScore\":25638,\"treasureDev\":{\"40221\":12,\"40222\":12,\"40223\":12}},\"32\":{\"stage\":12,\"comScore\":28486,\"disScore\":60635,\"treasureDev\":{\"40321\":12,\"40322\":12,\"40323\":12}},\"41\":{\"stage\":12,\"comScore\":60770,\"disScore\":161692,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5},\"62012\":{\"l\":1},\"62022\":{\"l\":1},\"62032\":{\"l\":1},\"62013\":{\"l\":5},\"62023\":{\"l\":5},\"62033\":{\"l\":5},\"62040\":{\"l\":1}},\"l\":10},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5},\"64012\":{\"l\":1},\"64022\":{\"l\":1},\"64032\":{\"l\":1},\"64013\":{\"l\":5},\"64023\":{\"l\":5},\"64033\":{\"l\":5},\"64040\":{\"l\":1}},\"l\":10},\"63\":{\"cl\":{\"63011\":{\"l\":5},\"63021\":{\"l\":5},\"63031\":{\"l\":5},\"63012\":{\"l\":1},\"63022\":{\"l\":1},\"63032\":{\"l\":1},\"63013\":{\"l\":5},\"63023\":{\"l\":5},\"63033\":{\"l\":5},\"63040\":{\"l\":1}},\"l\":10},\"61\":{\"cl\":{\"61011\":{\"l\":5},\"61021\":{\"l\":5},\"61031\":{\"l\":5},\"61012\":{\"l\":1},\"61022\":{\"l\":1},\"61032\":{\"l\":1},\"61013\":{\"l\":5},\"61023\":{\"l\":5},\"61033\":{\"l\":5},\"61040\":{\"l\":1}},\"l\":10}},\"guildName\":\"y3\"},\"r1\":48851311,\"r2\":14}"

--[[
        3
        矮人战斗复盘
        参数: 
            atk: 左方数据
            actId: 活动id
            exBattleTime: 额外时间, 单位秒
            r1r2: 随机种子
 ]]--
local airen_json
function proc_airen_3(jsondata)
    if jsondata == "test" then
        jsondata = airen_json
    end
    local data = cjson.decode(jsondata)
    if data.actId == nil then
        return cjson.encode({ret = ERROR_CODE_NO_ACTID, msg = "ERROR_CODE_NO_ACTID"})
    end
    if data.exBattleTime == nil then
        return cjson.encode({ret = ERROR_CODE_NO_EXBATTLETIME, msg = "ERROR_CODE_NO_EXBATTLETIME"})
    end

    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local r1 = data.r1
    local r2 = data.r2
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_AiRenMuWu(data.actId, playerInfo, data.exBattleTime, nil, nil, r1, r2, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    return cjson.encode(data)
end
proc_functions[3] = proc_airen_3
local airen_actId = 901
local airen_exBattleTime = 10
-- airen_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"actId\":"..airen_actId..",\"exBattleTime\":"..airen_exBattleTime.."}"

--[[
        9
        远征复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            skill: 技能序列
            crusadeId: 远征关卡ID
 ]]--
local crusade_json
function proc_crusade_9(jsondata)
    if jsondata == "test" then
        jsondata = crusade_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)

    if data.crusadeId == nil then
        return cjson.encode({ret = ERROR_CODE_NO_CRUSADEID, msg = "ERROR_CODE_NO_CRUSADEID"})
    end 
    local crusadeId = tonumber(data.crusadeId)
    local isSiege = tab.crusadeMain[crusadeId]["siegeid"] ~= nil
    if isSiege then
        -- 如果是攻城战需要对敌人重新摆阵
        BattleUtils.crusadeSiegeUpdateFormation(enemyInfo, data.def)
    end
    
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_Crusade(playerInfo, enemyInfo, crusadeId, data.siegeBroken, nil, nil, true)
    local allyDead = {}
    local enemyDead = {}
    for k,v in pairs(data.dieList[1]) do
        table.insert(allyDead, k)
    end
    for k,v in pairs(data.dieList[2]) do
        table.insert(enemyDead, k)
    end
    data.allyDead = allyDead
    data.enemyDead = enemyDead
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[9] = proc_crusade_9
-- crusade_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"def\":{\"rid\":\"9992_22\",\"usid\":\"999251342147\",\"avatar\":1104,\"name\":\"二狗gogoo\",\"msg\":\"\",\"lv\":80,\"vipLvl\":15,\"score\":1426500,\"hero\":{\"star\":4,\"m1\":62153,\"m2\":62023,\"m3\":62033,\"m4\":62003,\"sl1\":21,\"sl2\":21,\"sl3\":21,\"sl4\":22,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":101923,\"spellNums\":\"0,0,0,0\",\"new1\":62222,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"2,3,4\"},\"globalSpecial\":\"[501022,503013,503032,503023]\",\"formation\":{\"score\":1426500,\"g1\":11,\"team1\":107,\"g2\":15,\"team2\":307,\"g3\":5,\"team3\":102,\"g4\":9,\"team4\":203,\"g5\":7,\"team5\":507,\"g6\":3,\"team6\":407,\"g7\":6,\"team7\":207,\"g8\":10,\"team8\":306,\"lastUpTime\":1473079027,\"heroId\":60301},\"teams\":{\"107\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58597,\"pScore\":14869,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512526},\"307\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":47723,\"pScore\":5188,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512529},\"102\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":52457,\"pScore\":16060,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471502220},\"203\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":54122,\"pScore\":15237,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503691},\"507\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":50268,\"pScore\":6540,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512517},\"407\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":55514,\"pScore\":11786,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"recordTime\":1471512520},\"207\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58031,\"pScore\":15496,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512524},\"306\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":56117,\"pScore\":13582,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503482}},\"pokedex\":[12647,9381,11868,2560,6040,5120,3480,2805,4760,1432],\"treasures\":{\"21\":{\"stage\":12,\"comScore\":27672,\"disScore\":16956,\"treasureDev\":{\"40211\":12,\"40212\":12,\"40213\":12}},\"10\":{\"stage\":12,\"comScore\":24417,\"disScore\":48427,\"treasureDev\":{\"40103\":12,\"40102\":12,\"40101\":12}},\"30\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40301\":12,\"40302\":12,\"40303\":12,\"40304\":12}},\"31\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":58057,\"disScore\":160335,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"11\":{\"stage\":12,\"comScore\":14108,\"disScore\":5322,\"treasureDev\":{\"40111\":12,\"40112\":12,\"40113\":12}},\"22\":{\"stage\":12,\"comScore\":18991,\"disScore\":25638,\"treasureDev\":{\"40221\":12,\"40222\":12,\"40223\":12}},\"32\":{\"stage\":12,\"comScore\":28486,\"disScore\":60635,\"treasureDev\":{\"40321\":12,\"40322\":12,\"40323\":12}},\"41\":{\"stage\":12,\"comScore\":60770,\"disScore\":161692,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5},\"62012\":{\"l\":1},\"62022\":{\"l\":1},\"62032\":{\"l\":1},\"62013\":{\"l\":5},\"62023\":{\"l\":5},\"62033\":{\"l\":5},\"62040\":{\"l\":1}},\"l\":10},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5},\"64012\":{\"l\":1},\"64022\":{\"l\":1},\"64032\":{\"l\":1},\"64013\":{\"l\":5},\"64023\":{\"l\":5},\"64033\":{\"l\":5},\"64040\":{\"l\":1}},\"l\":10},\"63\":{\"cl\":{\"63011\":{\"l\":5},\"63021\":{\"l\":5},\"63031\":{\"l\":5},\"63012\":{\"l\":1},\"63022\":{\"l\":1},\"63032\":{\"l\":1},\"63013\":{\"l\":5},\"63023\":{\"l\":5},\"63033\":{\"l\":5},\"63040\":{\"l\":1}},\"l\":10},\"61\":{\"cl\":{\"61011\":{\"l\":5},\"61021\":{\"l\":5},\"61031\":{\"l\":5},\"61012\":{\"l\":1},\"61022\":{\"l\":1},\"61032\":{\"l\":1},\"61013\":{\"l\":5},\"61023\":{\"l\":5},\"61033\":{\"l\":5},\"61040\":{\"l\":1}},\"l\":10}},\"guildName\":\"y3\"},\"r1\":48851311,\"r2\":14}"

--[[
        10
        联盟探索PVE战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据 结果和atk不一样是联盟探索特殊的npc结构
            skill: 技能序列
 ]]--
local gpve_json
function proc_gpve_10(jsondata)
    if jsondata == "test" then
        jsondata = gpve_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = GuildMapUtils:initBattleData(data.def)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end

    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_GuildPVE(playerInfo, enemyInfo, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[10] = proc_gpve_10
-- gpve_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"def\":{\"rid\":\"9992_22\",\"usid\":\"999251342147\",\"avatar\":1104,\"name\":\"二狗gogoo\",\"msg\":\"\",\"lv\":80,\"vipLvl\":15,\"score\":1426500,\"hero\":{\"star\":4,\"m1\":62153,\"m2\":62023,\"m3\":62033,\"m4\":62003,\"sl1\":21,\"sl2\":21,\"sl3\":21,\"sl4\":22,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":101923,\"spellNums\":\"0,0,0,0\",\"new1\":62222,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"2,3,4\"},\"globalSpecial\":\"[501022,503013,503032,503023]\",\"formation\":{\"score\":1426500,\"g1\":11,\"team1\":107,\"g2\":15,\"team2\":307,\"g3\":5,\"team3\":102,\"g4\":9,\"team4\":203,\"g5\":7,\"team5\":507,\"g6\":3,\"team6\":407,\"g7\":6,\"team7\":207,\"g8\":10,\"team8\":306,\"lastUpTime\":1473079027,\"heroId\":60301},\"teams\":{\"107\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58597,\"pScore\":14869,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512526},\"307\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":47723,\"pScore\":5188,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512529},\"102\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":52457,\"pScore\":16060,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471502220},\"203\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":54122,\"pScore\":15237,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503691},\"507\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":50268,\"pScore\":6540,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512517},\"407\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":55514,\"pScore\":11786,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"recordTime\":1471512520},\"207\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58031,\"pScore\":15496,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512524},\"306\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":56117,\"pScore\":13582,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503482}},\"pokedex\":[12647,9381,11868,2560,6040,5120,3480,2805,4760,1432],\"treasures\":{\"21\":{\"stage\":12,\"comScore\":27672,\"disScore\":16956,\"treasureDev\":{\"40211\":12,\"40212\":12,\"40213\":12}},\"10\":{\"stage\":12,\"comScore\":24417,\"disScore\":48427,\"treasureDev\":{\"40103\":12,\"40102\":12,\"40101\":12}},\"30\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40301\":12,\"40302\":12,\"40303\":12,\"40304\":12}},\"31\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":58057,\"disScore\":160335,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"11\":{\"stage\":12,\"comScore\":14108,\"disScore\":5322,\"treasureDev\":{\"40111\":12,\"40112\":12,\"40113\":12}},\"22\":{\"stage\":12,\"comScore\":18991,\"disScore\":25638,\"treasureDev\":{\"40221\":12,\"40222\":12,\"40223\":12}},\"32\":{\"stage\":12,\"comScore\":28486,\"disScore\":60635,\"treasureDev\":{\"40321\":12,\"40322\":12,\"40323\":12}},\"41\":{\"stage\":12,\"comScore\":60770,\"disScore\":161692,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5},\"62012\":{\"l\":1},\"62022\":{\"l\":1},\"62032\":{\"l\":1},\"62013\":{\"l\":5},\"62023\":{\"l\":5},\"62033\":{\"l\":5},\"62040\":{\"l\":1}},\"l\":10},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5},\"64012\":{\"l\":1},\"64022\":{\"l\":1},\"64032\":{\"l\":1},\"64013\":{\"l\":5},\"64023\":{\"l\":5},\"64033\":{\"l\":5},\"64040\":{\"l\":1}},\"l\":10},\"63\":{\"cl\":{\"63011\":{\"l\":5},\"63021\":{\"l\":5},\"63031\":{\"l\":5},\"63012\":{\"l\":1},\"63022\":{\"l\":1},\"63032\":{\"l\":1},\"63013\":{\"l\":5},\"63023\":{\"l\":5},\"63033\":{\"l\":5},\"63040\":{\"l\":1}},\"l\":10},\"61\":{\"cl\":{\"61011\":{\"l\":5},\"61021\":{\"l\":5},\"61031\":{\"l\":5},\"61012\":{\"l\":1},\"61022\":{\"l\":1},\"61032\":{\"l\":1},\"61013\":{\"l\":5},\"61023\":{\"l\":5},\"61033\":{\"l\":5},\"61040\":{\"l\":1}},\"l\":10}},\"guildName\":\"y3\"},\"r1\":48851311,\"r2\":14}"



--[[
        11
        联盟探索PVP战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
 ]]--
local gpvp_json
function proc_gpvp_11(jsondata)
    if jsondata == "test" then
        jsondata = gpvp_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_GuildPVP(playerInfo, enemyInfo, nil, nil, true)
    data.dieList = nil
    data.uhp = math.ceil(data.hp[1] / data.hp[2] * 100)
    data.mhp = math.ceil(data.hp[3] / data.hp[4] * 100)
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[11] = proc_gpvp_11
-- gpvp_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"def\":{\"rid\":\"9992_22\",\"usid\":\"999251342147\",\"avatar\":1104,\"name\":\"二狗gogoo\",\"msg\":\"\",\"lv\":80,\"vipLvl\":15,\"score\":1426500,\"hero\":{\"star\":4,\"m1\":62153,\"m2\":62023,\"m3\":62033,\"m4\":62003,\"sl1\":21,\"sl2\":21,\"sl3\":21,\"sl4\":22,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":101923,\"spellNums\":\"0,0,0,0\",\"new1\":62222,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"2,3,4\"},\"globalSpecial\":\"[501022,503013,503032,503023]\",\"formation\":{\"score\":1426500,\"g1\":11,\"team1\":107,\"g2\":15,\"team2\":307,\"g3\":5,\"team3\":102,\"g4\":9,\"team4\":203,\"g5\":7,\"team5\":507,\"g6\":3,\"team6\":407,\"g7\":6,\"team7\":207,\"g8\":10,\"team8\":306,\"lastUpTime\":1473079027,\"heroId\":60301},\"teams\":{\"107\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58597,\"pScore\":14869,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512526},\"307\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":47723,\"pScore\":5188,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512529},\"102\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":52457,\"pScore\":16060,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471502220},\"203\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":54122,\"pScore\":15237,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503691},\"507\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":50268,\"pScore\":6540,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512517},\"407\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":55514,\"pScore\":11786,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"recordTime\":1471512520},\"207\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58031,\"pScore\":15496,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512524},\"306\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":56117,\"pScore\":13582,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503482}},\"pokedex\":[12647,9381,11868,2560,6040,5120,3480,2805,4760,1432],\"treasures\":{\"21\":{\"stage\":12,\"comScore\":27672,\"disScore\":16956,\"treasureDev\":{\"40211\":12,\"40212\":12,\"40213\":12}},\"10\":{\"stage\":12,\"comScore\":24417,\"disScore\":48427,\"treasureDev\":{\"40103\":12,\"40102\":12,\"40101\":12}},\"30\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40301\":12,\"40302\":12,\"40303\":12,\"40304\":12}},\"31\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":58057,\"disScore\":160335,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"11\":{\"stage\":12,\"comScore\":14108,\"disScore\":5322,\"treasureDev\":{\"40111\":12,\"40112\":12,\"40113\":12}},\"22\":{\"stage\":12,\"comScore\":18991,\"disScore\":25638,\"treasureDev\":{\"40221\":12,\"40222\":12,\"40223\":12}},\"32\":{\"stage\":12,\"comScore\":28486,\"disScore\":60635,\"treasureDev\":{\"40321\":12,\"40322\":12,\"40323\":12}},\"41\":{\"stage\":12,\"comScore\":60770,\"disScore\":161692,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5},\"62012\":{\"l\":1},\"62022\":{\"l\":1},\"62032\":{\"l\":1},\"62013\":{\"l\":5},\"62023\":{\"l\":5},\"62033\":{\"l\":5},\"62040\":{\"l\":1}},\"l\":10},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5},\"64012\":{\"l\":1},\"64022\":{\"l\":1},\"64032\":{\"l\":1},\"64013\":{\"l\":5},\"64023\":{\"l\":5},\"64033\":{\"l\":5},\"64040\":{\"l\":1}},\"l\":10},\"63\":{\"cl\":{\"63011\":{\"l\":5},\"63021\":{\"l\":5},\"63031\":{\"l\":5},\"63012\":{\"l\":1},\"63022\":{\"l\":1},\"63032\":{\"l\":1},\"63013\":{\"l\":5},\"63023\":{\"l\":5},\"63033\":{\"l\":5},\"63040\":{\"l\":1}},\"l\":10},\"61\":{\"cl\":{\"61011\":{\"l\":5},\"61021\":{\"l\":5},\"61031\":{\"l\":5},\"61012\":{\"l\":1},\"61022\":{\"l\":1},\"61032\":{\"l\":1},\"61013\":{\"l\":5},\"61023\":{\"l\":5},\"61033\":{\"l\":5},\"61040\":{\"l\":1}},\"l\":10}},\"guildName\":\"y3\"},\"r1\":48851311,\"r2\":14}"


--[[
        13
        积分联赛复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            skill: 技能序列
            r1r2: 随机种子
 ]]--
local league_json
function proc_league_13(jsondata)
    if jsondata == "test" then
        jsondata = league_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)

    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    local r1 = data.r1
    local r2 = data.r2
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_League(playerInfo, enemyInfo, r1, r2, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[13] = proc_league_13
league_json = "{\"atk\":{\"rid\":\"9991_159\",\"usid\":\"999151342299\",\"avatar\":1101,\"name\":\"最强v10\",\"msg\":\"\",\"lv\":34,\"vipLvl\":10,\"score\":87254,\"hero\":{\"star\":2,\"m1\":62132,\"m2\":62091,\"m3\":62062,\"m4\":62152,\"sl1\":6,\"sl2\":5,\"sl3\":5,\"sl4\":6,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":11618,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":102,\"g3\":8,\"team3\":104,\"g4\":14,\"team4\":907,\"g5\":4,\"team5\":301,\"g6\":15,\"team6\":106,\"g7\":10,\"team7\":105,\"g8\":16,\"team8\":306,\"lt\":1479092294,\"heroId\":60102,\"score\":86313,\"filter\":\"\"},\"teams\":{\"205\":{\"level\":33,\"exp\":0,\"stage\":4,\"star\":3,\"smallStar\":20,\"score\":6949,\"pScore\":944,\"es1\":4,\"el1\":33,\"es2\":4,\"el2\":33,\"es3\":5,\"el3\":33,\"es4\":4,\"el4\":33,\"sl1\":1,\"sl2\":0,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478941197,\"grade\":834},\"102\":{\"level\":28,\"exp\":1530,\"stage\":4,\"star\":1,\"smallStar\":5,\"score\":3975,\"pScore\":764,\"es1\":4,\"el1\":28,\"es2\":4,\"el2\":28,\"es3\":4,\"el3\":28,\"es4\":4,\"el4\":28,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478863821,\"grade\":627},\"104\":{\"level\":33,\"exp\":0,\"stage\":5,\"star\":2,\"smallStar\":13,\"score\":6478,\"pScore\":1075,\"es1\":5,\"el1\":33,\"es2\":5,\"el2\":33,\"es3\":5,\"el3\":33,\"es4\":5,\"el4\":33,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478865760,\"grade\":787},\"907\":{\"level\":33,\"exp\":0,\"stage\":5,\"star\":5,\"smallStar\":40,\"score\":10551,\"pScore\":0,\"es1\":5,\"el1\":33,\"es2\":5,\"el2\":33,\"es3\":5,\"el3\":33,\"es4\":5,\"el4\":33,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478938172,\"grade\":1072},\"301\":{\"level\":33,\"exp\":0,\"stage\":5,\"star\":6,\"smallStar\":50,\"score\":12936,\"pScore\":430,\"es1\":5,\"el1\":28,\"es2\":5,\"el2\":28,\"es3\":5,\"el3\":28,\"es4\":5,\"el4\":28,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478941181,\"grade\":1152},\"106\":{\"level\":33,\"exp\":0,\"stage\":4,\"star\":2,\"smallStar\":10,\"score\":5751,\"pScore\":1312,\"es1\":4,\"el1\":33,\"es2\":4,\"el2\":33,\"es3\":4,\"el3\":33,\"es4\":4,\"el4\":33,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478863821,\"grade\":737},\"105\":{\"level\":33,\"exp\":0,\"stage\":4,\"star\":2,\"smallStar\":15,\"score\":5240,\"pScore\":645,\"es1\":4,\"el1\":33,\"es2\":4,\"el2\":33,\"es3\":4,\"el3\":33,\"es4\":4,\"el4\":33,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478863845,\"grade\":762},\"306\":{\"level\":33,\"exp\":0,\"stage\":5,\"star\":3,\"smallStar\":20,\"score\":8077,\"pScore\":667,\"es1\":5,\"el1\":33,\"es2\":5,\"el2\":33,\"es3\":5,\"el3\":33,\"es4\":5,\"el4\":33,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478938289,\"grade\":872}},\"pokedex\":[2176,2251,1734,400,400,1452,0,0,0,0],\"treasures\":{\"11\":{\"stage\":2,\"comScore\":928,\"disScore\":714,\"treasureDev\":{\"40111\":{\"s\":3},\"40112\":{\"s\":3},\"40113\":{\"s\":3}}},\"21\":{\"stage\":1,\"comScore\":1213,\"disScore\":726,\"treasureDev\":{\"40211\":{\"s\":3},\"40212\":{\"s\":3},\"40213\":{\"s\":3}}},\"30\":{\"stage\":2,\"comScore\":1963,\"disScore\":2902,\"treasureDev\":{\"40301\":{\"s\":3},\"40302\":{\"s\":3},\"40303\":{\"s\":3},\"40304\":{\"s\":3}}},\"10\":{\"stage\":0,\"comScore\":0,\"disScore\":512,\"treasureDev\":{\"40103\":{\"s\":3},\"40102\":{\"s\":3},\"40101\":{\"s\":3}}},\"22\":{\"stage\":2,\"comScore\":1249,\"disScore\":2212,\"treasureDev\":{\"40221\":{\"s\":3},\"40222\":{\"s\":3},\"40223\":{\"s\":3}}},\"31\":{\"stage\":0,\"comScore\":0,\"disScore\":773,\"treasureDev\":{\"40311\":{\"s\":3},\"40312\":{\"s\":3},\"40313\":{\"s\":3},\"40314\":{\"s\":3}}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":1},\"62031\":{\"l\":5}},\"l\":2}},\"skillList\":\"[[322,2,997,326],[482,1,1364,240],[962,4,1228,424],[1282,3,1183,328],[1602,1,1553,238],[1922,2,1191,478],[2302,3,1108,342],[2482,1,1629,323],[2902,2,1011,330],[3122,1,1593,315],[3442,3,1279,345]]\"},\"def\":{\"rid\":\"9991_152\",\"usid\":\"999151342251\",\"avatar\":1101,\"name\":\"续一秒\",\"msg\":\"\",\"lv\":36,\"vipLvl\":4,\"score\":79313,\"hero\":{\"star\":2,\"m1\":62052,\"m2\":62221,\"m3\":62152,\"m4\":62033,\"sl1\":6,\"sl2\":3,\"sl3\":6,\"sl4\":7,\"se1\":10,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"score\":13023,\"spellNums\":\"7,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"\"},\"globalSpecial\":\"[501022,503032]\",\"formation\":{\"g1\":14,\"team1\":103,\"g2\":9,\"team2\":203,\"g3\":13,\"team3\":502,\"g4\":6,\"team4\":907,\"g5\":8,\"team5\":104,\"g6\":5,\"team6\":105,\"g7\":10,\"team7\":102,\"g8\":12,\"team8\":201,\"lt\":1479089993,\"heroId\":60102,\"score\":77085,\"filter\":\"\"},\"teams\":{\"103\":{\"level\":36,\"exp\":0,\"stage\":4,\"star\":3,\"smallStar\":22,\"score\":7273,\"pScore\":1223,\"es1\":4,\"el1\":36,\"es2\":4,\"el2\":36,\"es3\":4,\"el3\":36,\"es4\":4,\"el4\":36,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"rt\":1478950779,\"grade\":868},\"203\":{\"level\":36,\"exp\":0,\"stage\":5,\"star\":2,\"smallStar\":11,\"score\":6911,\"pScore\":1338,\"es1\":5,\"el1\":36,\"es2\":5,\"el2\":36,\"es3\":5,\"el3\":36,\"es4\":5,\"el4\":36,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"rt\":1478984618,\"grade\":798},\"502\":{\"level\":36,\"exp\":0,\"stage\":5,\"star\":3,\"smallStar\":21,\"score\":6335,\"pScore\":0,\"es1\":5,\"el1\":36,\"es2\":5,\"el2\":36,\"es3\":5,\"el3\":36,\"es4\":5,\"el4\":36,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478943291,\"grade\":898},\"907\":{\"level\":36,\"exp\":0,\"stage\":5,\"star\":3,\"smallStar\":20,\"score\":7524,\"pScore\":0,\"es1\":6,\"el1\":36,\"es2\":6,\"el2\":36,\"es3\":6,\"el3\":36,\"es4\":5,\"el4\":36,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478938060,\"grade\":908},\"104\":{\"level\":36,\"exp\":0,\"stage\":5,\"star\":2,\"smallStar\":15,\"score\":6437,\"pScore\":734,\"es1\":5,\"el1\":36,\"es2\":5,\"el2\":36,\"es3\":5,\"el3\":36,\"es4\":5,\"el4\":36,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"rt\":1478896628,\"grade\":818},\"105\":{\"level\":35,\"exp\":2064,\"stage\":5,\"star\":2,\"smallStar\":17,\"score\":6271,\"pScore\":734,\"es1\":5,\"el1\":35,\"es2\":5,\"el2\":35,\"es3\":5,\"el3\":35,\"es4\":5,\"el4\":35,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"rt\":1478854070,\"grade\":821},\"102\":{\"level\":32,\"exp\":70,\"stage\":4,\"star\":2,\"smallStar\":14,\"score\":5594,\"pScore\":1287,\"es1\":5,\"el1\":31,\"es2\":5,\"el2\":31,\"es3\":4,\"el3\":31,\"es4\":4,\"el4\":31,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"rt\":1478854046,\"grade\":756},\"201\":{\"level\":36,\"exp\":0,\"stage\":5,\"star\":3,\"smallStar\":21,\"score\":7120,\"pScore\":785,\"es1\":5,\"el1\":36,\"es2\":5,\"el2\":36,\"es3\":5,\"el3\":36,\"es4\":5,\"el4\":36,\"sl1\":1,\"sl2\":1,\"sl3\":-1,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"rt\":1478950779,\"grade\":898}},\"pokedex\":[2321,1546,2484,1749,0,0,0,0,0,0],\"treasures\":{\"11\":{\"stage\":2,\"comScore\":1006,\"disScore\":677,\"treasureDev\":{\"40111\":{\"s\":3},\"40112\":{\"s\":3},\"40113\":{\"s\":3}}},\"21\":{\"stage\":1,\"comScore\":1316,\"disScore\":897,\"treasureDev\":{\"40211\":{\"s\":3},\"40212\":{\"s\":3},\"40213\":{\"s\":3}}},\"10\":{\"stage\":0,\"comScore\":0,\"disScore\":555,\"treasureDev\":{\"40103\":{\"s\":3},\"40102\":{\"s\":3},\"40101\":{\"s\":3}}},\"22\":{\"stage\":3,\"comScore\":1806,\"disScore\":2399,\"treasureDev\":{\"40221\":{\"s\":3},\"40222\":{\"s\":3},\"40223\":{\"s\":3}}},\"30\":{\"stage\":0,\"comScore\":0,\"disScore\":1187,\"treasureDev\":{\"40301\":{\"s\":3},\"40302\":{\"s\":3},\"40303\":{\"s\":3},\"40304\":{\"s\":3}}},\"31\":{\"stage\":0,\"comScore\":0,\"disScore\":258,\"treasureDev\":{\"40311\":{\"s\":3},\"40312\":{\"s\":3},\"40313\":{\"s\":3},\"40314\":{\"s\":3}}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62022\":{\"l\":1}},\"l\":3}},\"guildName\":\"正义联盟\"},\"skill\":\"[[322,2,997,326],[482,1,1364,240],[962,4,1228,424],[1282,3,1183,328],[1602,1,1553,238],[1922,2,1191,478],[2302,3,1108,342],[2482,1,1629,323],[2902,2,1011,330],[3122,1,1593,315],[3442,3,1279,345]]\",\"r1\":\"67682424\",\"r2\":\"17\"}"

--[[
        14
        航海抢夺复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            skill: 技能序列
 ]]--
local mf_json
function proc_mf_14(jsondata)
    if jsondata == "test" then
        jsondata = mf_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)

    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_MF(playerInfo, enemyInfo, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[14] = proc_mf_14
-- mf_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"def\":{\"rid\":\"9992_22\",\"usid\":\"999251342147\",\"avatar\":1104,\"name\":\"二狗gogoo\",\"msg\":\"\",\"lv\":80,\"vipLvl\":15,\"score\":1426500,\"hero\":{\"star\":4,\"m1\":62153,\"m2\":62023,\"m3\":62033,\"m4\":62003,\"sl1\":21,\"sl2\":21,\"sl3\":21,\"sl4\":22,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":101923,\"spellNums\":\"0,0,0,0\",\"new1\":62222,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"2,3,4\"},\"globalSpecial\":\"[501022,503013,503032,503023]\",\"formation\":{\"score\":1426500,\"g1\":11,\"team1\":107,\"g2\":15,\"team2\":307,\"g3\":5,\"team3\":102,\"g4\":9,\"team4\":203,\"g5\":7,\"team5\":507,\"g6\":3,\"team6\":407,\"g7\":6,\"team7\":207,\"g8\":10,\"team8\":306,\"lastUpTime\":1473079027,\"heroId\":60301},\"teams\":{\"107\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58597,\"pScore\":14869,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512526},\"307\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":47723,\"pScore\":5188,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512529},\"102\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":52457,\"pScore\":16060,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471502220},\"203\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":54122,\"pScore\":15237,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503691},\"507\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":50268,\"pScore\":6540,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512517},\"407\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":55514,\"pScore\":11786,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"recordTime\":1471512520},\"207\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58031,\"pScore\":15496,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512524},\"306\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":56117,\"pScore\":13582,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503482}},\"pokedex\":[12647,9381,11868,2560,6040,5120,3480,2805,4760,1432],\"treasures\":{\"21\":{\"stage\":12,\"comScore\":27672,\"disScore\":16956,\"treasureDev\":{\"40211\":12,\"40212\":12,\"40213\":12}},\"10\":{\"stage\":12,\"comScore\":24417,\"disScore\":48427,\"treasureDev\":{\"40103\":12,\"40102\":12,\"40101\":12}},\"30\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40301\":12,\"40302\":12,\"40303\":12,\"40304\":12}},\"31\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":58057,\"disScore\":160335,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"11\":{\"stage\":12,\"comScore\":14108,\"disScore\":5322,\"treasureDev\":{\"40111\":12,\"40112\":12,\"40113\":12}},\"22\":{\"stage\":12,\"comScore\":18991,\"disScore\":25638,\"treasureDev\":{\"40221\":12,\"40222\":12,\"40223\":12}},\"32\":{\"stage\":12,\"comScore\":28486,\"disScore\":60635,\"treasureDev\":{\"40321\":12,\"40322\":12,\"40323\":12}},\"41\":{\"stage\":12,\"comScore\":60770,\"disScore\":161692,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5},\"62012\":{\"l\":1},\"62022\":{\"l\":1},\"62032\":{\"l\":1},\"62013\":{\"l\":5},\"62023\":{\"l\":5},\"62033\":{\"l\":5},\"62040\":{\"l\":1}},\"l\":10},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5},\"64012\":{\"l\":1},\"64022\":{\"l\":1},\"64032\":{\"l\":1},\"64013\":{\"l\":5},\"64023\":{\"l\":5},\"64033\":{\"l\":5},\"64040\":{\"l\":1}},\"l\":10},\"63\":{\"cl\":{\"63011\":{\"l\":5},\"63021\":{\"l\":5},\"63031\":{\"l\":5},\"63012\":{\"l\":1},\"63022\":{\"l\":1},\"63032\":{\"l\":1},\"63013\":{\"l\":5},\"63023\":{\"l\":5},\"63033\":{\"l\":5},\"63040\":{\"l\":1}},\"l\":10},\"61\":{\"cl\":{\"61011\":{\"l\":5},\"61021\":{\"l\":5},\"61031\":{\"l\":5},\"61012\":{\"l\":1},\"61022\":{\"l\":1},\"61032\":{\"l\":1},\"61013\":{\"l\":5},\"61023\":{\"l\":5},\"61033\":{\"l\":5},\"61040\":{\"l\":1}},\"l\":10}},\"guildName\":\"y3\"},\"r1\":48851311,\"r2\":14}"

--[[
        15
        云中城复盘
        参数: 
            atk: 左方数据
            cctId: 关卡ID
            cctId2: 使用的buff的关卡ID
            skill: 技能序列
 ]]--
local cloud_json
function proc_cloud_15(jsondata)
    if jsondata == "test" then
        jsondata = cloudy_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)

    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    if data.cctId == nil then
        return cjson.encode({ret = ERROR_CODE_NO_CCTID, msg = "ERROR_CODE_NO_CCTID"})
    end
    if data.cctId2 == nil then
        return cjson.encode({ret = ERROR_CODE_NO_CCTID2, msg = "ERROR_CODE_NO_CCTID2"})
    end
    local cctId = data.cctId
    local cctId2 = data.cctId2
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_CloudCity(playerInfo, cctId, cctId2, false, data.siegeBroken, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[15] = proc_cloud_15
-- cloudy_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"def\":{\"rid\":\"9992_22\",\"usid\":\"999251342147\",\"avatar\":1104,\"name\":\"二狗gogoo\",\"msg\":\"\",\"lv\":80,\"vipLvl\":15,\"score\":1426500,\"hero\":{\"star\":4,\"m1\":62153,\"m2\":62023,\"m3\":62033,\"m4\":62003,\"sl1\":21,\"sl2\":21,\"sl3\":21,\"sl4\":22,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":101923,\"spellNums\":\"0,0,0,0\",\"new1\":62222,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"2,3,4\"},\"globalSpecial\":\"[501022,503013,503032,503023]\",\"formation\":{\"score\":1426500,\"g1\":11,\"team1\":107,\"g2\":15,\"team2\":307,\"g3\":5,\"team3\":102,\"g4\":9,\"team4\":203,\"g5\":7,\"team5\":507,\"g6\":3,\"team6\":407,\"g7\":6,\"team7\":207,\"g8\":10,\"team8\":306,\"lastUpTime\":1473079027,\"heroId\":60301},\"teams\":{\"107\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58597,\"pScore\":14869,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512526},\"307\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":47723,\"pScore\":5188,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512529},\"102\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":52457,\"pScore\":16060,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471502220},\"203\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":54122,\"pScore\":15237,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503691},\"507\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":50268,\"pScore\":6540,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512517},\"407\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":55514,\"pScore\":11786,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"recordTime\":1471512520},\"207\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58031,\"pScore\":15496,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512524},\"306\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":56117,\"pScore\":13582,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503482}},\"pokedex\":[12647,9381,11868,2560,6040,5120,3480,2805,4760,1432],\"treasures\":{\"21\":{\"stage\":12,\"comScore\":27672,\"disScore\":16956,\"treasureDev\":{\"40211\":12,\"40212\":12,\"40213\":12}},\"10\":{\"stage\":12,\"comScore\":24417,\"disScore\":48427,\"treasureDev\":{\"40103\":12,\"40102\":12,\"40101\":12}},\"30\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40301\":12,\"40302\":12,\"40303\":12,\"40304\":12}},\"31\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":58057,\"disScore\":160335,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"11\":{\"stage\":12,\"comScore\":14108,\"disScore\":5322,\"treasureDev\":{\"40111\":12,\"40112\":12,\"40113\":12}},\"22\":{\"stage\":12,\"comScore\":18991,\"disScore\":25638,\"treasureDev\":{\"40221\":12,\"40222\":12,\"40223\":12}},\"32\":{\"stage\":12,\"comScore\":28486,\"disScore\":60635,\"treasureDev\":{\"40321\":12,\"40322\":12,\"40323\":12}},\"41\":{\"stage\":12,\"comScore\":60770,\"disScore\":161692,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5},\"62012\":{\"l\":1},\"62022\":{\"l\":1},\"62032\":{\"l\":1},\"62013\":{\"l\":5},\"62023\":{\"l\":5},\"62033\":{\"l\":5},\"62040\":{\"l\":1}},\"l\":10},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5},\"64012\":{\"l\":1},\"64022\":{\"l\":1},\"64032\":{\"l\":1},\"64013\":{\"l\":5},\"64023\":{\"l\":5},\"64033\":{\"l\":5},\"64040\":{\"l\":1}},\"l\":10},\"63\":{\"cl\":{\"63011\":{\"l\":5},\"63021\":{\"l\":5},\"63031\":{\"l\":5},\"63012\":{\"l\":1},\"63022\":{\"l\":1},\"63032\":{\"l\":1},\"63013\":{\"l\":5},\"63023\":{\"l\":5},\"63033\":{\"l\":5},\"63040\":{\"l\":1}},\"l\":10},\"61\":{\"cl\":{\"61011\":{\"l\":5},\"61021\":{\"l\":5},\"61031\":{\"l\":5},\"61012\":{\"l\":1},\"61022\":{\"l\":1},\"61032\":{\"l\":1},\"61013\":{\"l\":5},\"61023\":{\"l\":5},\"61033\":{\"l\":5},\"61040\":{\"l\":1}},\"l\":10}},\"guildName\":\"y3\"},\"r1\":48851311,\"r2\":14}"

--[[
        17
        GVG复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
function proc_gvg_17(jsondata)
    if jsondata == "test" then
        jsondata = arena_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    local r1 = data.r1
    local r2 = data.r2
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_GVG(playerInfo, enemyInfo, r1, r2, nil, nil, true)
    -- data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[17] = proc_gvg_17

--[[
        19
        训练所复盘
        参数: 
            atk: playerInfo 前端传过来的数据
            trainingId: 关卡ID
            skill: 技能序列
 ]]--
local cloud_json
function proc_training_19(jsondata)
    local data = cjson.decode(jsondata)
    local playerInfo = cjson.decode(data.atk)

    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    if data.trainingId == nil then
        return cjson.encode({ret = ERROR_CODE_NO_TRAININGID, msg = "ERROR_CODE_NO_TRAININGID"})
    end
    local trainingId = data.trainingId
    local trainingD = tab.training[trainingId]

    -- 检查数据是否正常
    local heros = trainingD["hero2"]
    local id = playerInfo.hero.id
    local hasHero = false
    for i = 1, #heros do
        if id == heros[i] then
            hasHero = true
            break
        end
    end
    if not hasHero then
        return cjson.encode({ret = ERROR_CODE_SUCCESS, win = false})
    end
    local npcs = playerInfo.npc
    local npc2 = trainingD["npc2"]
    for i = 1, #npcs do
        local hasNpc = false
        local id = npcs[i][1]
        for k = 1, #npc2 do
            if id == npc2[k] then
                hasNpc = true
                break
            end
        end  
        if not hasNpc then
            return cjson.encode({ret = ERROR_CODE_SUCCESS, win = false})
        end
    end

    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_Training(playerInfo, trainingId, nil, nil, true)
    data.dieList = nil
    local hp = data.hpex
    local num = trainingD["num"]
    local score = tonumber(hp[1]) / tonumber(hp[2]) * tonumber(num) * 100 --100--
    score = math.ceil(score)
    data.score = score
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[19] = proc_training_19

--[[
        20
        大富翁战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            skill: 技能序列
 ]]--
function proc_adventure_20(jsondata)
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end

    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_Adventure(playerInfo, enemyInfo, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[20] = proc_adventure_20

--[[
        21
        英雄交锋战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
function proc_duel_21(jsondata)
    if jsondata == "test" then
        jsondata = duel_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    local r1 = data.r1
    local r2 = data.r2
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_HeroDuel(playerInfo, enemyInfo, r1, r2, 0, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[21] = proc_duel_21

--[[
        25
        众神之战战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
function proc_godwar_25(jsondata)
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    local r1 = data.r1
    local r2 = data.r2
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_GodWar(playerInfo, enemyInfo, r1, r2, 0, false, false, false, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[25] = proc_godwar_25

--[[
        26
        元素位面复盘
        参数: 
            atk: 左方数据
            kind: 副本种类
            level 关卡级别
            skill: 技能序列
 ]]--
function proc_ele_26(jsondata)
    local data = cjson.decode(jsondata)
    if data.kind == nil then
        return cjson.encode({ret = ERROR_CODE_NO_ELE_KIND_ID, msg = "ERROR_CODE_NO_ELE_KIND_ID"})
    end
    if data.level == nil then
        return cjson.encode({ret = ERROR_CODE_NO_ELE_LEVEL_ID, msg = "ERROR_CODE_NO_ELE_LEVEL_ID"})
    end
    -- npc英雄
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_Elemental(playerInfo, data.kind, data.level, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[26] = proc_ele_26

--[[
        31
        攻城战(进攻)(日常)复盘
        参数: 
            atk: 左方数据
            levelid: 关卡id
            skill: 技能序列
 ]]--
function proc_siege_atk_31(jsondata)
    local data = cjson.decode(jsondata)
    if data.levelid == nil then
        return cjson.encode({ret = ERROR_CODE_NO_LEVEL_ID, msg = "ERROR_CODE_NO_LEVEL_ID"})
    end
    -- npc英雄
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    BattleUtils.dontCheck = true

    local data, str = BattleUtils.enterBattleView_Siege_Atk(playerInfo, data.levelid, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[31] = proc_siege_atk_31

--[[
        32
        攻城战(防守)(日常)复盘
        参数: 
            atk: 左方数据
            levelid: 关卡id
            skill: 技能序列
 ]]--
function proc_siege_def_32(jsondata)
    local data = cjson.decode(jsondata)
    if data.levelid == nil then
        return cjson.encode({ret = ERROR_CODE_NO_LEVEL_ID, msg = "ERROR_CODE_NO_LEVEL_ID"})
    end
    -- npc英雄
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    BattleUtils.dontCheck = true

    local data, str = BattleUtils.enterBattleView_Siege_Def(playerInfo, data.levelid, data.defWin, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[32] = proc_siege_def_32

--[[
        33
        攻城战(进攻)(世界事件)复盘
        参数: 
            atk: 左方数据
            levelid: 关卡id
            skill: 技能序列
 ]]--
function proc_siege_atk_we_33(jsondata)
    local data = cjson.decode(jsondata)
    if data.levelid == nil then
        return cjson.encode({ret = ERROR_CODE_NO_LEVEL_ID, msg = "ERROR_CODE_NO_LEVEL_ID"})
    end
    -- npc英雄
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    BattleUtils.dontCheck = true

    local data, str = BattleUtils.enterBattleView_Siege_Atk_WE(playerInfo, data.levelid, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[33] = proc_siege_atk_we_33

--[[
        34
        攻城战(防守)(世界事件)复盘
        参数: 
            atk: 左方数据
            levelid: 关卡id
            wallLv: 城墙等级
            skill: 技能序列
 ]]--
function proc_siege_def_we_34(jsondata)
    local data = cjson.decode(jsondata)
    if data.levelid == nil then
        return cjson.encode({ret = ERROR_CODE_NO_LEVEL_ID, msg = "ERROR_CODE_NO_LEVEL_ID"})
    end
    if data.wallLv == nil then
        return cjson.encode({ret = ERROR_CODE_NO_WALL_LEVEL, msg = "ERROR_CODE_NO_WALL_LEVEL"})
    end
    -- npc英雄
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    BattleUtils.dontCheck = true

    local data, str = BattleUtils.enterBattleView_Siege_Def_WE(playerInfo, data.wallLv, data.levelid, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[34] = proc_siege_def_we_34

--[[
        35
        联盟探索密境战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据 
            skill: 技能序列
 ]]--
function proc_gfam_35(jsondata)
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end

    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_GuildFAM(playerInfo, enemyInfo, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[35] = proc_gfam_35

-- local playerInfo = {
--                     lv = 50,
--                     team = {}, 
--                     hero = {
--                             id = BattleUtils.LEFT_HERO_ID, 
--                             level = BattleUtils.LEFT_HERO_LEVEL,
--                             star = BattleUtils.LEFT_HERO_STAR,
--                             slevel = BattleUtils.LEFT_HERO_SKILL_LEVEL, 
--                             mastery = BattleUtils.LEFT_HERO_MASTERY,
--                             },
--                     pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},              
--                     -- treasure = {
--                     --                 [11] = {stage = 1, treasureDev = {}}, 
--                     --                 [21] = {stage = 1, treasureDev = {}},
--                     --                 [22] = {stage = 1, treasureDev = {}},
--                     --                 [30] = {stage = 1, treasureDev = {}},
--                     --                 [31] = {stage = 1, treasureDev = {}},
--                     --                 [10] = {stage = 1, treasureDev = {}},
--                     --                 [32] = {stage = 1, treasureDev = {}},
--                     --                 [40] = {stage = 1, treasureDev = {}},
--                     --                 [41] = {stage = 1, treasureDev = {}},
--                     --             },
--                     }
-- local team
-- local count = BattleUtils.LEFT_TEAM_COUNT
-- for i = 1, count  do
--     team = {
--                 id = BattleUtils.LEFT_ID[i],
--                 pos = BattleUtils.LEFT_FORMATION[i],
--                 level = BattleUtils.LEFT_LEVEL[i],
--                 star = BattleUtils.LEFT_STAR[i],
--                 smallStar = BattleUtils.LEFT_SMALLSTAR[i],
--                 stage = BattleUtils.LEFT_STAGE[i],
--                 equip = {
--                             {stage = BattleUtils.LEFT_EQUIP_STAGE[i][1],
--                             level = BattleUtils.LEFT_EQUIP_LEVEL[i][1]},
--                             {stage = BattleUtils.LEFT_EQUIP_STAGE[i][2],
--                             level = BattleUtils.LEFT_EQUIP_LEVEL[i][2]},
--                             {stage = BattleUtils.LEFT_EQUIP_STAGE[i][3],
--                             level = BattleUtils.LEFT_EQUIP_LEVEL[i][3]},
--                             {stage = BattleUtils.LEFT_EQUIP_STAGE[i][4],
--                             level = BattleUtils.LEFT_EQUIP_LEVEL[i][4]}
--                         },
--                 skill = BattleUtils.LEFT_SKILL_LEVEL[i]
--            }
--     table.insert(playerInfo.team, team)
-- end

-- local enemyInfo = { 
--                     lv = 50,
--                     team = {}, 
--                     hero = {
--                             id = BattleUtils.RIGHT_HERO_ID, 
--                             level = BattleUtils.RIGHT_HERO_LEVEL,
--                             slevel = BattleUtils.RIGHT_HERO_SKILL_LEVEL,
--                             star = BattleUtils.RIGHT_HERO_STAR,
--                             mastery = BattleUtils.RIGHT_HERO_MASTERY,
--                             },
--                     pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
--                     }
-- local team
-- local count = BattleUtils.RIGHT_TEAM_COUNT
-- for i = 1, count do
--     team = {
--                 id = BattleUtils.RIGHT_ID[i],
--                 pos = BattleUtils.RIGHT_FORMATION[i],
--                 level = BattleUtils.RIGHT_LEVEL[i],
--                 star = BattleUtils.RIGHT_STAR[i],
--                 smallStar = BattleUtils.RIGHT_SMALLSTAR[i],
--                 stage = BattleUtils.RIGHT_STAGE[i],
--                 equip = {
--                             {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][1],
--                             level = BattleUtils.RIGHT_EQUIP_LEVEL[i][1]},
--                             {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][2],
--                             level = BattleUtils.RIGHT_EQUIP_LEVEL[i][2]},
--                             {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][3],
--                             level = BattleUtils.RIGHT_EQUIP_LEVEL[i][3]},
--                             {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][4],
--                             level = BattleUtils.RIGHT_EQUIP_LEVEL[i][4]}
--                         },
--                 skill = BattleUtils.RIGHT_SKILL_LEVEL[i]
--            }
--     table.insert(enemyInfo.team, team)
-- end

--[[
        36
        跨服竞技场战斗复盘
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
local serverArena_json
function proc_arena_36(jsondata)
    if jsondata == "test" then
        jsondata = serverArena_json
    end
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    local r1 = data.r1
    local r2 = data.r2
    BattleUtils.dontCheck = true
    local data, str = BattleUtils.enterBattleView_ServerArena(playerInfo, enemyInfo, r1, r2, 0, false, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
        data.enemyInfo = enemyInfo
    end
    return cjson.encode(data)
end
proc_functions[36] = proc_arena_36
-- serverArena_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"def\":{\"rid\":\"9992_22\",\"usid\":\"999251342147\",\"avatar\":1104,\"name\":\"二狗gogoo\",\"msg\":\"\",\"lv\":80,\"vipLvl\":15,\"score\":1426500,\"hero\":{\"star\":4,\"m1\":62153,\"m2\":62023,\"m3\":62033,\"m4\":62003,\"sl1\":21,\"sl2\":21,\"sl3\":21,\"sl4\":22,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":101923,\"spellNums\":\"0,0,0,0\",\"new1\":62222,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"2,3,4\"},\"globalSpecial\":\"[501022,503013,503032,503023]\",\"formation\":{\"score\":1426500,\"g1\":11,\"team1\":107,\"g2\":15,\"team2\":307,\"g3\":5,\"team3\":102,\"g4\":9,\"team4\":203,\"g5\":7,\"team5\":507,\"g6\":3,\"team6\":407,\"g7\":6,\"team7\":207,\"g8\":10,\"team8\":306,\"lastUpTime\":1473079027,\"heroId\":60301},\"teams\":{\"107\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58597,\"pScore\":14869,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512526},\"307\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":47723,\"pScore\":5188,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512529},\"102\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":52457,\"pScore\":16060,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471502220},\"203\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":54122,\"pScore\":15237,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503691},\"507\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":50268,\"pScore\":6540,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512517},\"407\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":55514,\"pScore\":11786,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"recordTime\":1471512520},\"207\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58031,\"pScore\":15496,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512524},\"306\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":56117,\"pScore\":13582,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503482}},\"pokedex\":[12647,9381,11868,2560,6040,5120,3480,2805,4760,1432],\"treasures\":{\"21\":{\"stage\":12,\"comScore\":27672,\"disScore\":16956,\"treasureDev\":{\"40211\":12,\"40212\":12,\"40213\":12}},\"10\":{\"stage\":12,\"comScore\":24417,\"disScore\":48427,\"treasureDev\":{\"40103\":12,\"40102\":12,\"40101\":12}},\"30\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40301\":12,\"40302\":12,\"40303\":12,\"40304\":12}},\"31\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":58057,\"disScore\":160335,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"11\":{\"stage\":12,\"comScore\":14108,\"disScore\":5322,\"treasureDev\":{\"40111\":12,\"40112\":12,\"40113\":12}},\"22\":{\"stage\":12,\"comScore\":18991,\"disScore\":25638,\"treasureDev\":{\"40221\":12,\"40222\":12,\"40223\":12}},\"32\":{\"stage\":12,\"comScore\":28486,\"disScore\":60635,\"treasureDev\":{\"40321\":12,\"40322\":12,\"40323\":12}},\"41\":{\"stage\":12,\"comScore\":60770,\"disScore\":161692,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5},\"62012\":{\"l\":1},\"62022\":{\"l\":1},\"62032\":{\"l\":1},\"62013\":{\"l\":5},\"62023\":{\"l\":5},\"62033\":{\"l\":5},\"62040\":{\"l\":1}},\"l\":10},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5},\"64012\":{\"l\":1},\"64022\":{\"l\":1},\"64032\":{\"l\":1},\"64013\":{\"l\":5},\"64023\":{\"l\":5},\"64033\":{\"l\":5},\"64040\":{\"l\":1}},\"l\":10},\"63\":{\"cl\":{\"63011\":{\"l\":5},\"63021\":{\"l\":5},\"63031\":{\"l\":5},\"63012\":{\"l\":1},\"63022\":{\"l\":1},\"63032\":{\"l\":1},\"63013\":{\"l\":5},\"63023\":{\"l\":5},\"63033\":{\"l\":5},\"63040\":{\"l\":1}},\"l\":10},\"61\":{\"cl\":{\"61011\":{\"l\":5},\"61021\":{\"l\":5},\"61031\":{\"l\":5},\"61012\":{\"l\":1},\"61022\":{\"l\":1},\"61032\":{\"l\":1},\"61013\":{\"l\":5},\"61023\":{\"l\":5},\"61033\":{\"l\":5},\"61040\":{\"l\":1}},\"l\":10}},\"guildName\":\"y3\"},\"r1\":48851311,\"r2\":14}"

--[[
        37
        跨服竞技场副本战斗复盘
        支持: 副本 精英副本
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
local serverArenafuben_json
function proc_serverArenafuben_37(jsondata)
    if jsondata == "test" then
        jsondata = serverArenafuben_json
    end
    local data = cjson.decode(jsondata)
    -- npc英雄
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    BattleUtils.dontCheck = true
    local r1 = data.r1
    local r2 = data.r2
    local data, str = BattleUtils.enterBattleView_ServerArenaFuben(playerInfo, enemyInfo, r1, r2, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[37] = proc_serverArenafuben_37
local serverArenafubenid = 7100505
-- serverArenafuben_json = "{\"atk\":{\"rid\":\"9992_2\",\"usid\":\"999251342082\",\"avatar\":1101,\"name\":\"狂人戴夫·李\",\"msg\":\"\",\"lv\":64,\"vipLvl\":15,\"score\":705143,\"hero\":{\"star\":2,\"m1\":62083,\"m2\":62133,\"m3\":62013,\"m4\":62223,\"sl1\":11,\"sl2\":11,\"sl3\":10,\"sl4\":11,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":36649,\"spellNums\":\"0,0,0,0\",\"new1\":0,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"1,2,3\"},\"globalSpecial\":\"[501022]\",\"formation\":{\"score\":705143,\"g1\":12,\"team1\":205,\"g2\":9,\"team2\":105,\"g3\":13,\"team3\":907,\"g4\":16,\"team4\":104,\"g5\":15,\"team5\":107,\"g6\":11,\"team6\":304,\"g7\":10,\"team7\":203,\"g8\":14,\"team8\":306,\"lastUpTime\":1473773191,\"heroId\":60102},\"teams\":{\"205\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26494,\"pScore\":2166,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506497},\"105\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30018,\"pScore\":5348,\"es1\":7,\"el1\":55,\"es2\":7,\"el2\":55,\"es3\":7,\"el3\":55,\"es4\":7,\"el4\":55,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471497579},\"907\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25595,\"pScore\":1514,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471505460},\"104\":{\"level\":55,\"exp\":3705,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":30680,\"pScore\":5638,\"es1\":8,\"el1\":49,\"es2\":8,\"el2\":49,\"es3\":8,\"el3\":49,\"es4\":7,\"el4\":49,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512499},\"107\":{\"level\":62,\"exp\":2478,\"stage\":8,\"star\":6,\"smallStar\":50,\"score\":34287,\"pScore\":3834,\"es1\":8,\"el1\":62,\"es2\":8,\"el2\":62,\"es3\":8,\"el3\":62,\"es4\":8,\"el4\":62,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472039096},\"304\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":26331,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506106},\"203\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":25772,\"pScore\":2238,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471506742},\"306\":{\"level\":48,\"exp\":255,\"stage\":7,\"star\":6,\"smallStar\":50,\"score\":28137,\"pScore\":3029,\"es1\":7,\"el1\":48,\"es2\":7,\"el2\":48,\"es3\":7,\"el3\":48,\"es4\":7,\"el4\":48,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":-1,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1472184074}},\"pokedex\":[5295,3882,500,2591,1100,2491,300,2091,0,0],\"treasures\":{\"10\":{\"stage\":1,\"comScore\":2729,\"disScore\":5411,\"treasureDev\":{\"40103\":1,\"40102\":1,\"40101\":1}},\"11\":{\"stage\":6,\"comScore\":5518,\"disScore\":2956,\"treasureDev\":{\"40111\":6,\"40112\":11,\"40113\":7}},\"21\":{\"stage\":1,\"comScore\":3092,\"disScore\":1895,\"treasureDev\":{\"40211\":1,\"40212\":1,\"40213\":1}},\"22\":{\"stage\":4,\"comScore\":5305,\"disScore\":7655,\"treasureDev\":{\"40221\":4,\"40222\":5,\"40223\":4}},\"30\":{\"stage\":1,\"comScore\":3335,\"disScore\":12202,\"treasureDev\":{\"40301\":4,\"40302\":1,\"40303\":3,\"40304\":5}},\"31\":{\"stage\":12,\"comScore\":21675,\"disScore\":37438,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":42167,\"disScore\":116451,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"41\":{\"stage\":12,\"comScore\":44137,\"disScore\":117436,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}},\"32\":{\"stage\":1,\"comScore\":3183,\"disScore\":6776,\"treasureDev\":{\"40321\":1,\"40322\":1,\"40323\":1}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5}},\"l\":3},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5}},\"l\":3}},\"guildName\":\"冥王镇狱\"},\"def\":{\"rid\":\"9992_22\",\"usid\":\"999251342147\",\"avatar\":1104,\"name\":\"二狗gogoo\",\"msg\":\"\",\"lv\":80,\"vipLvl\":15,\"score\":1426500,\"hero\":{\"star\":4,\"m1\":62153,\"m2\":62023,\"m3\":62033,\"m4\":62003,\"sl1\":21,\"sl2\":21,\"sl3\":21,\"sl4\":22,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"score\":101923,\"spellNums\":\"0,0,0,0\",\"new1\":62222,\"new2\":0,\"new3\":0,\"new4\":0,\"locks\":\"2,3,4\"},\"globalSpecial\":\"[501022,503013,503032,503023]\",\"formation\":{\"score\":1426500,\"g1\":11,\"team1\":107,\"g2\":15,\"team2\":307,\"g3\":5,\"team3\":102,\"g4\":9,\"team4\":203,\"g5\":7,\"team5\":507,\"g6\":3,\"team6\":407,\"g7\":6,\"team7\":207,\"g8\":10,\"team8\":306,\"lastUpTime\":1473079027,\"heroId\":60301},\"teams\":{\"107\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58597,\"pScore\":14869,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512526},\"307\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":47723,\"pScore\":5188,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512529},\"102\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":52457,\"pScore\":16060,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471502220},\"203\":{\"level\":80,\"exp\":11406,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":54122,\"pScore\":15237,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503691},\"507\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":50268,\"pScore\":6540,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512517},\"407\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":55514,\"pScore\":11786,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":1,\"recordTime\":1471512520},\"207\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":58031,\"pScore\":15496,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471512524},\"306\":{\"level\":80,\"exp\":11781,\"stage\":11,\"star\":6,\"smallStar\":50,\"score\":56117,\"pScore\":13582,\"es1\":11,\"el1\":80,\"es2\":11,\"el2\":80,\"es3\":11,\"el3\":80,\"es4\":11,\"el4\":80,\"sl1\":15,\"sl2\":15,\"sl3\":15,\"sl4\":15,\"se1\":0,\"se2\":0,\"se3\":0,\"se4\":0,\"status\":0,\"recordTime\":1471503482}},\"pokedex\":[12647,9381,11868,2560,6040,5120,3480,2805,4760,1432],\"treasures\":{\"21\":{\"stage\":12,\"comScore\":27672,\"disScore\":16956,\"treasureDev\":{\"40211\":12,\"40212\":12,\"40213\":12}},\"10\":{\"stage\":12,\"comScore\":24417,\"disScore\":48427,\"treasureDev\":{\"40103\":12,\"40102\":12,\"40101\":12}},\"30\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40301\":12,\"40302\":12,\"40303\":12,\"40304\":12}},\"31\":{\"stage\":12,\"comScore\":29843,\"disScore\":51546,\"treasureDev\":{\"40311\":12,\"40312\":12,\"40313\":12,\"40314\":12}},\"40\":{\"stage\":12,\"comScore\":58057,\"disScore\":160335,\"treasureDev\":{\"40401\":12,\"40402\":12,\"40403\":12,\"40404\":12,\"40405\":12,\"40406\":12}},\"11\":{\"stage\":12,\"comScore\":14108,\"disScore\":5322,\"treasureDev\":{\"40111\":12,\"40112\":12,\"40113\":12}},\"22\":{\"stage\":12,\"comScore\":18991,\"disScore\":25638,\"treasureDev\":{\"40221\":12,\"40222\":12,\"40223\":12}},\"32\":{\"stage\":12,\"comScore\":28486,\"disScore\":60635,\"treasureDev\":{\"40321\":12,\"40322\":12,\"40323\":12}},\"41\":{\"stage\":12,\"comScore\":60770,\"disScore\":161692,\"treasureDev\":{\"40411\":12,\"40412\":12,\"40413\":12,\"40414\":12,\"40415\":12,\"40416\":12}}},\"talent\":{\"62\":{\"cl\":{\"62011\":{\"l\":5},\"62021\":{\"l\":5},\"62031\":{\"l\":5},\"62012\":{\"l\":1},\"62022\":{\"l\":1},\"62032\":{\"l\":1},\"62013\":{\"l\":5},\"62023\":{\"l\":5},\"62033\":{\"l\":5},\"62040\":{\"l\":1}},\"l\":10},\"64\":{\"cl\":{\"64011\":{\"l\":5},\"64021\":{\"l\":5},\"64031\":{\"l\":5},\"64012\":{\"l\":1},\"64022\":{\"l\":1},\"64032\":{\"l\":1},\"64013\":{\"l\":5},\"64023\":{\"l\":5},\"64033\":{\"l\":5},\"64040\":{\"l\":1}},\"l\":10},\"63\":{\"cl\":{\"63011\":{\"l\":5},\"63021\":{\"l\":5},\"63031\":{\"l\":5},\"63012\":{\"l\":1},\"63022\":{\"l\":1},\"63032\":{\"l\":1},\"63013\":{\"l\":5},\"63023\":{\"l\":5},\"63033\":{\"l\":5},\"63040\":{\"l\":1}},\"l\":10},\"61\":{\"cl\":{\"61011\":{\"l\":5},\"61021\":{\"l\":5},\"61031\":{\"l\":5},\"61012\":{\"l\":1},\"61022\":{\"l\":1},\"61032\":{\"l\":1},\"61013\":{\"l\":5},\"61023\":{\"l\":5},\"61033\":{\"l\":5},\"61040\":{\"l\":1}},\"l\":10}},\"guildName\":\"y3\"},\"r1\":48851311,\"r2\":14}"


--[[
        38
        爬塔副本战斗复盘
        支持: 副本 精英副本 
        参数: 
            atk: 左方数据
            def: 右方数据
            r1r2: 随机种子
 ]]--
local climbTower_json
function proc_climbTower_38(jsondata)
    if jsondata == "test" then
        jsondata = climbTower_json
    end
    local data = cjson.decode(jsondata)
    -- npc英雄
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    if data.skill then
        playerInfo.skillList = cjson.decode(data.skill)
    end
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)
    BattleUtils.dontCheck = true
    local r1 = data.r1
    local r2 = data.r2
    local data, str = BattleUtils.enterBattleView_ClimbTower(playerInfo, enemyInfo, r1, r2, nil, nil, true)
    data.dieList = nil
    data.ret = ERROR_CODE_SUCCESS
    if DEBUG_PLAYER_INFO then
        data.playerInfo = playerInfo
    end
    return cjson.encode(data)
end
proc_functions[38] = proc_climbTower_38

-- climbTower_json = {}
