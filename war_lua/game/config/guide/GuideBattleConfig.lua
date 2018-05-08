--[[
    Filename:    GuideBattleConfig.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-21 16:13:26
    Description: File description
--]]

local BATTLE_TIME = 52
local BEGIN_TIME = 0
local LEFT_HERO_ID = 90001
local LEFT_HERO_LEVEL = 1
local LEFT_HERO_SKILL_LEVEL = {0, 0, 0, 0, 0}
local LEFT_HERO_STAR = 1
local LEFT_HERO_MASTERY = {62001, 62001, 62001, 62001, 62001}

local LEFT_pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0,0,0}

local LEFT_FORMATION = { 6, 2,  7, 11 , 10, 14}
-- 左边人数
local LEFT_TEAM_COUNT = 6
-- 左边方阵id
local LEFT_ID = {2002, 2003,2005, 2006, 2007,2008}
local LEFT_SCALE = {0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,0.5}
-- 等级

local LEFT_LEVEL = {20, 40, 80, 80, 40, 40, 40, 40}
-- 星
local LEFT_STAR = {3, 3, 3, 3, 3, 3, 3, 3,3}
-- 小星
local LEFT_SMALLSTAR = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
-- 阶
local LEFT_STAGE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
-- 技能等级
local LEFT_SKILL_LEVEL =
                    {
                     {1, 0, 0, 0},
                     {1, 0, 0, 0},
                     {1, 0, 0, 0},
                     {1, 0, 0, 0},
                     {1, 0, 0, 0},
                     {1, 1, 1, 1},
                     }
-- 装备阶
local LEFT_EQUIP_STAGE = 
                    {
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     {1, 2, 1, 2},
                     {1, 2, 1, 2},
                     {1, 1, 1, 1},
                     {5, 1, 5, 1},
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     }
-- 装备级
local LEFT_EQUIP_LEVEL =
                    {
                     {80, 0, 80, 0},
                     {80, 40, 80, 40},
                     {80, 80, 80, 80},
                     {80, 80, 80, 80},
                     {80, 40, 80, 40},
                     {80, 40, 80, 40},
                     {80, 40, 80, 40},
                     {80, 40, 80, 40},
                     }

local RIGHT_HERO_ID = 90002
local RIGHT_HERO_LEVEL = 1
local RIGHT_HERO_SKILL_LEVEL = {5, 0, 0, 0, 0}
local RIGHT_HERO_STAR = 1
local RIGHT_HERO_MASTERY = {62001, 62001, 62001, 62001, 62001}

local RIGHT_pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0}

local RIGHT_FORMATION = {8, 12, 4, 16, 7, 11, 10 , 6}
-- 右边人数
local RIGHT_TEAM_COUNT = 8

-- 右边方阵id
local RIGHT_ID = {2101, 2102, 2103, 2104, 2105, 2106, 2107,2108}
local RIGHT_SCALE = {0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,0.5}
local RIGHT_LEVEL = {40, 40, 40, 40, 40, 40, 40, 40}
local RIGHT_STAR = {3, 3, 3, 3, 3, 3, 3, 3,3}
local RIGHT_SMALLSTAR = {50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local RIGHT_STAGE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
-- 技能等级
local RIGHT_SKILL_LEVEL =
                    {
                     {0, 0, 0, 0},
                     {0, 0, 0, 0},
                     {0, 0, 0, 0},
                     {0, 0, 0, 0},
                     {0, 0, 0, 0},
                     {0, 0, 0, 0},
                     {1, 0, 0, 0},
                     {1, 0, 0, 0},
                     }
local RIGHT_EQUIP_STAGE = 
                    {
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     {1, 1, 1, 1},
                     }
local RIGHT_EQUIP_LEVEL = 
                    {
                     {40, 40, 40, 40},
                     {40, 40, 40, 40},
                     {40, 40, 40, 40},
                     {40, 40, 40, 40},
                     {40, 80, 40, 80},
                     {40, 80, 40, 80},
                     {40, 40, 40, 40},
                     {40, 40, 40, 40},
                     }
local function getGuideBattleInfo()
    local count = RIGHT_TEAM_COUNT
    local playerInfo = {
                    team = {}, 
                    hero = {
                            id = LEFT_HERO_ID, 
                            level = LEFT_HERO_LEVEL,
                            slevel = LEFT_HERO_SKILL_LEVEL, 
                            star = LEFT_HERO_STAR, 
                            mastery = LEFT_HERO_MASTERY,
                            },
                    pokedex = LEFT_POKEDEX, 
                    }
    local team
    for i = 1, LEFT_TEAM_COUNT  do
        team = {
                    id = LEFT_ID[i],
                    pos = LEFT_FORMATION[i],
                    level = LEFT_LEVEL[i],
                    star = LEFT_STAR[i],
                    smallStar = LEFT_SMALLSTAR[i],
                    stage = LEFT_STAGE[i],
                    equip = {
                                {stage = LEFT_EQUIP_STAGE[i][1],
                                level = LEFT_EQUIP_LEVEL[i][1]},
                                {stage = LEFT_EQUIP_STAGE[i][2],
                                level = LEFT_EQUIP_LEVEL[i][2]},
                                {stage = LEFT_EQUIP_STAGE[i][3],
                                level = LEFT_EQUIP_LEVEL[i][3]},
                                {stage = LEFT_EQUIP_STAGE[i][4],
                                level = LEFT_EQUIP_LEVEL[i][4]}
                            },
                    skill = LEFT_SKILL_LEVEL[i],
                    scale = LEFT_SCALE[i],
               }
        table.insert(playerInfo.team, team)
    end

    local enemyInfo = { 
                        team = {}, 
                        hero = {
                                id = RIGHT_HERO_ID, 
                                level = RIGHT_HERO_LEVEL,
                                slevel = RIGHT_HERO_SKILL_LEVEL,
                                star = RIGHT_HERO_STAR,
                                mastery = RIGHT_HERO_MASTERY,
                                },
                        pokedex = RIGHT_POKEDEX,
                        }
    local team
    local count = RIGHT_TEAM_COUNT
    for i = 1, count do
        team = {
                    id = RIGHT_ID[i],
                    pos = RIGHT_FORMATION[i],
                    level = RIGHT_LEVEL[i],
                    star = RIGHT_STAR[i],
                    smallStar = RIGHT_SMALLSTAR[i],
                    stage = RIGHT_STAGE[i],
                    equip = {
                                {stage = RIGHT_EQUIP_STAGE[i][1],
                                level = RIGHT_EQUIP_LEVEL[i][1]},
                                {stage = RIGHT_EQUIP_STAGE[i][2],
                                level = RIGHT_EQUIP_LEVEL[i][2]},
                                {stage = RIGHT_EQUIP_STAGE[i][3],
                                level = RIGHT_EQUIP_LEVEL[i][3]},
                                {stage = RIGHT_EQUIP_STAGE[i][4],
                                level = RIGHT_EQUIP_LEVEL[i][4]}
                            },
                    skill = RIGHT_SKILL_LEVEL[i],
                    scale = RIGHT_SCALE[i],
               }
        -- if 1507 == RIGHT_ID[i] then
        --     team.hudSp = true
        -- end
        table.insert(enemyInfo.team, team)
    end
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Guide, resultMode = nil, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        isReport = false,
                        --battleId = 12345,
                        guideTime = BATTLE_TIME,
                        siegeReverse = true,
                        r1 = 12345,
                        mapId = "kaichang", siegeId = 999, siegeLevel = 1, arrowLevel = 1}

    return battleInfo
end

return getGuideBattleInfo()