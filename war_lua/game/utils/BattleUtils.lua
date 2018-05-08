--[[
    Filename:    BattleUtils.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-22 17:46:13
    Description: File description
--]]

local tab = tab
local print = print
local dump = dump
local ceil = math.ceil
local floor = math.floor
local pairs = pairs
local table = table
local type = type 
local tonumber = tonumber

local BattleUtils = {}

BattleUtils.DEBUG_FAST_BATTLE = 0

local fupanStr

-- local f = io.open("./script/test/online.txt", 'r')
-- local fupanStr = f:read("*all")
-- f:close()

-- debug是否有宝物
local DEBUG_ENABLE_TREASURE_1 = false
local DEBUG_ENABLE_TREASURE_2 = false


-- 血条类型
-- 1.方阵血条（默认）
-- 2.单兵血条
BattleUtils.HUD_TYPE = 1

-- 觉醒兵团ID增幅， 统计美术资源专用
local JX_ID_ADD = 100000000

-- 界面上，技能icon间距
local invX = floor((1136 - (MAX_SCREEN_WIDTH or 1136)) / 11)
if invX < 0 then
    invX = 0
end
if invX > 16 then
    invX = 16
end
local beginX = floor((1136 - (MAX_SCREEN_WIDTH or 1136)) / 17.6)
if beginX < 0 then
    beginX = 0
end
if beginX > 10 then
    beginX = 10
end
BattleUtils.SKILL_ICON_INV_X_ORI = 106
BattleUtils.SKILL_ICON_BEGIN_X_ORI = 843
BattleUtils.SKILL_ICON_INV_X = 106 - invX
BattleUtils.SKILL_ICON_BEGIN_X = 843 + beginX

-- 输了以后跳转界面过程中为true
BattleUtils.loseReturnMainind = false

-- 英雄解锁动画
-- BattleUtils.unLockSkillIndex = 3
BattleUtils.unLockSkillHero = {}

-- 每日小惊喜
BattleUtils.surpriseList = {0, 0, 0, 0}
BattleUtils.surpriseOpen = false
BattleUtils.surpriseSuccess = false

-- 技能调试信息
BattleUtils.XBW_SKILL_DEBUG = false
-- 统计界面 普攻技能分开统计

BattleUtils.CUR_BATTLE_TYPE = 1
BattleUtils.CUR_BATTLE_SUB_TYPE = 1
BattleUtils.BATTLE_TYPE_Fuben = 1               -- 副本
BattleUtils.BATTLE_TYPE_Arena = 2               -- 竞技场
BattleUtils.BATTLE_TYPE_AiRenMuWu = 3           -- 矮人
BattleUtils.BATTLE_TYPE_Zombie = 4              -- 僵尸
BattleUtils.BATTLE_TYPE_Siege = 5               -- 攻城战(副本&远征)
BattleUtils.BATTLE_TYPE_BOSS_DuLong = 6         -- 毒龙
BattleUtils.BATTLE_TYPE_BOSS_XnLong = 7         -- 仙女龙
BattleUtils.BATTLE_TYPE_BOSS_SjLong = 8         -- 水晶龙
BattleUtils.BATTLE_TYPE_Crusade = 9             -- 远征
BattleUtils.BATTLE_TYPE_GuildPVE = 10           -- 联盟探索PVE
BattleUtils.BATTLE_TYPE_GuildPVP = 11           -- 联盟探索PVP
BattleUtils.BATTLE_TYPE_Biography = 12          -- 英雄传记
BattleUtils.BATTLE_TYPE_League = 13             -- 积分联赛(现在叫冠军对决)
BattleUtils.BATTLE_TYPE_MF = 14                 -- 航海
BattleUtils.BATTLE_TYPE_CloudCity = 15          -- 云中城
BattleUtils.BATTLE_TYPE_CCSiege = 16            -- 云中城攻城战
BattleUtils.BATTLE_TYPE_GVG = 17                -- 大地图GVG遭遇战
BattleUtils.BATTLE_TYPE_GVGSiege = 18           -- 大地图GVG攻城战
BattleUtils.BATTLE_TYPE_Training = 19           -- 训练所
BattleUtils.BATTLE_TYPE_Adventure = 20          -- 大富翁
BattleUtils.BATTLE_TYPE_HeroDuel = 21           -- 英雄交锋
BattleUtils.BATTLE_TYPE_GBOSS_1 = 22            -- 联盟探索石头人1
BattleUtils.BATTLE_TYPE_GBOSS_2 = 23            -- 联盟探索石头人2
BattleUtils.BATTLE_TYPE_GBOSS_3 = 24            -- 联盟探索石头人3
BattleUtils.BATTLE_TYPE_GodWar = 25             -- 争霸赛
BattleUtils.BATTLE_TYPE_Elemental_1 = 26        -- 元素位面 火
BattleUtils.BATTLE_TYPE_Elemental_2 = 27        -- 元素位面 水
BattleUtils.BATTLE_TYPE_Elemental_3 = 28        -- 元素位面 气
BattleUtils.BATTLE_TYPE_Elemental_4 = 29        -- 元素位面 土
BattleUtils.BATTLE_TYPE_Elemental_5 = 30        -- 元素位面 混乱
BattleUtils.BATTLE_TYPE_Siege_Atk = 31          -- 攻城战(进攻)(日常)
BattleUtils.BATTLE_TYPE_Siege_Def = 32          -- 攻城战(防守)(日常)
BattleUtils.BATTLE_TYPE_Siege_Atk_WE = 33       -- 攻城战(进攻)(世界事件)
BattleUtils.BATTLE_TYPE_Siege_Def_WE = 34       -- 攻城战(防守)(世界事件)
BattleUtils.BATTLE_TYPE_GuildFAM = 35           -- 联盟探索密境
BattleUtils.BATTLE_TYPE_ServerArena = 36        -- 跨服竞技场
BattleUtils.BATTLE_TYPE_ServerArenaFuben = 37   -- 跨服竞技场副本(挑战镜像)
BattleUtils.BATTLE_TYPE_ClimbTower = 38         -- 爬塔
BattleUtils.BATTLE_TYPE_Guide = 100             -- 引导战斗

-- 强制自动战斗的类别
BattleUtils.PROC_AUTO_SKILL = 
{
    [BattleUtils.BATTLE_TYPE_Arena] = true,
    [BattleUtils.BATTLE_TYPE_ServerArena] = true,
    [BattleUtils.BATTLE_TYPE_GuildPVP] = true,
    [BattleUtils.BATTLE_TYPE_GVG] = true,
    [BattleUtils.BATTLE_TYPE_GVGSiege] = true,
    [BattleUtils.BATTLE_TYPE_HeroDuel] = true,
    [BattleUtils.BATTLE_TYPE_GodWar] = true,
}

-- 使用攻城器械的战斗
BattleUtils.USE_WEAPONS = 
{
    [BattleUtils.BATTLE_TYPE_Arena] = true,
    [BattleUtils.BATTLE_TYPE_ServerArena] = true,
    [BattleUtils.BATTLE_TYPE_GodWar] = true,
    [BattleUtils.BATTLE_TYPE_League] = true,
    [BattleUtils.BATTLE_TYPE_Siege_Atk] = true,
    [BattleUtils.BATTLE_TYPE_Siege_Atk_WE] = true,
    [BattleUtils.BATTLE_TYPE_GuildPVE] = true,
    [BattleUtils.BATTLE_TYPE_GuildPVP] = true,
    [BattleUtils.BATTLE_TYPE_GVG] = true,
    [BattleUtils.BATTLE_TYPE_GuildFAM] = true,
    [BattleUtils.BATTLE_TYPE_GBOSS_1] = true,
    [BattleUtils.BATTLE_TYPE_GBOSS_2] = true,
    [BattleUtils.BATTLE_TYPE_GBOSS_3] = true,
    [BattleUtils.BATTLE_TYPE_Crusade] = true,   
    [BattleUtils.BATTLE_TYPE_ClimbTower] = true,   
    [BattleUtils.BATTLE_TYPE_ServerArenaFuben] = true,   
}

-- 使用攻城器械的战斗的子类型
BattleUtils.USE_SUNWEAPONS = 
{
    [BattleUtils.BATTLE_TYPE_Crusade] = true, 
}

-- 加强器械的战斗
BattleUtils.SUPER_WEAPONS = 
{
    [BattleUtils.BATTLE_TYPE_Siege_Atk] = true,
}

-- 不使用法术天赋的战斗
BattleUtils.NO_TALENT = 
{
    [BattleUtils.BATTLE_TYPE_League] = true,
    [BattleUtils.BATTLE_TYPE_HeroDuel] = true,
}

-- 伤害类法术不生效的战斗
BattleUtils.NO_DAMAGE = 
{
    [BattleUtils.BATTLE_TYPE_Zombie] = true,
}




BattleUtils.fubenBranch = false
BattleUtils.PVE_INTANCE_ID = 7200104
BattleUtils.PVE_CCT_ID = 20
BattleUtils.PVE_TRAINING_ID = 1

-- BattleUtils.PVE_INTANCE_SIEGE_ID = 7100910 -- 墓园
-- BattleUtils.PVE_INTANCE_SIEGE_ID = 7100105 -- 城堡
-- BattleUtils.PVE_INTANCE_SIEGE_ID = 7100205 -- 要塞
-- BattleUtils.PVE_INTANCE_SIEGE_ID = 7100315 -- 壁垒
-- BattleUtils.PVE_INTANCE_SIEGE_ID = 7100605 -- 地狱
-- BattleUtils.PVE_INTANCE_SIEGE_ID = 7100705 -- 据点
-- BattleUtils.PVE_INTANCE_SIEGE_ID = 7101315 -- 塔楼

BattleUtils.PVE_INTANCE_SIEGE_ID = 7101315
--[[
    1  2  3  4
    5  6  7  8
    9 10 11 12
   13 14 15 16 
]]
-- 基础
BattleUtils.LEFT_TEAM_COUNT = 1
BattleUtils.LEFT_ID = {205, 102, 102, 102, 102, 102, 102, 102, 202, 203, 204, 205, 206, 207, 301, 302}
BattleUtils.LEFT_FORMATION = {1, 2, 5, 6, 9, 10, 13, 14, 1, 2, 5, 6, 9, 10, 13, 14}

--[[
    4  3  2  1
    8  7  6  5
   12 11 10  9
   16 15 14 13 
]]
BattleUtils.RIGHT_TEAM_COUNT = 1
BattleUtils.RIGHT_ID = {205, 205, 305, 306, 307, 401, 402, 403, 404, 405, 406, 407, 501, 502, 502, 503}
BattleUtils.RIGHT_FORMATION = {3, 4, 7, 8, 11, 12, 15, 16, 1, 2, 5, 6, 9, 10, 13, 14}

-- BattleUtils.LEFT_TEAM_COUNT = 2
-- BattleUtils.LEFT_ID = {101, 104, 103, 907, 105, 106, 202, 406}
-- BattleUtils.LEFT_FORMATION = {7, 8, 7, 8, 11, 12, 15, 16, 1, 2, 5, 6, 9, 10, 13, 14}

-- BattleUtils.RIGHT_TEAM_COUNT = 4
-- BattleUtils.RIGHT_ID = {202, 101, 104, 102, 205, 106, 107, 207}
-- BattleUtils.RIGHT_FORMATION = {3, 7, 11, 5, 11, 12, 15, 16, 1, 2, 5, 6, 9, 10, 13, 14}
-- 详细
BattleUtils.LEFT_HERO_ID = 60102

BattleUtils.LEFT_HERO_LEVEL = 1
BattleUtils.LEFT_HERO_SKILL_LEVEL = {1, 1, 1, 1, 1}
BattleUtils.LEFT_HERO_STAR = 2
BattleUtils.LEFT_HERO_MASTERY = {62001}

local level = 5000
BattleUtils.LEFT_LEVEL = {level, level, level, level, level, level, level, level, level, level, level, level, level, level, level, level}
BattleUtils.LEFT_STAR = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
BattleUtils.LEFT_SMALLSTAR = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
BattleUtils.LEFT_STAGE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
BattleUtils.LEFT_SKILL_LEVEL =
                    {
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     }
BattleUtils.LEFT_EQUIP_STAGE = 
                    {
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     }
BattleUtils.LEFT_EQUIP_LEVEL =
                    {
                     {0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},
                     {0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},
                     {0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},
                     {0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},
                     }

BattleUtils.RIGHT_HERO_ID = 60102
BattleUtils.RIGHT_HERO_LEVEL = 1
BattleUtils.RIGHT_HERO_SKILL_LEVEL = {1, 1, 1, 1, 1}
BattleUtils.RIGHT_HERO_STAR = 1
BattleUtils.RIGHT_HERO_MASTERY = {62001}

local level = 5000
BattleUtils.RIGHT_LEVEL = {level, level, level, level, level, level, level, level, level, level, level, level, level, level, level, level}
BattleUtils.RIGHT_STAR = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
BattleUtils.RIGHT_SMALLSTAR = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
BattleUtils.RIGHT_STAGE = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
BattleUtils.RIGHT_SKILL_LEVEL =
                    {
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     }
BattleUtils.RIGHT_EQUIP_STAGE = 
                    {
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     {1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},{1, 1, 1, 1},
                     }
BattleUtils.RIGHT_EQUIP_LEVEL = 
                    {
                     {0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},
                     {0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},
                     {0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},
                     {0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},{0, 0, 0, 0},
                     }

BattleUtils.ENABLE_MASTERY_LEVEL = 30
-- add by vv 
-- 技能阶
-- 1 = 白色 +0 
-- 2 = 绿色 +0
-- 3 = 蓝色 +2 
-- 4 = 紫色 +3
-- 5 = 橙色 +5
-- 6 = 橙色 +5
BattleUtils.TEAM_QUALITY = {
    [1] = {1, 0},
    [2] = {2, 0},
    [3] = {3, 0},
    [4] = {3, 1},
    [5] = {3, 2},
    [6] = {4, 0},
    [7] = {4, 1},
    [8] = {4, 2},
    [9] = {4, 3},
    [10] = {5, 0},
    [11] = {5, 1},
    [12] = {5, 2},
    [13] = {5, 3},
    [14] = {5, 4},
    [15] = {5, 5},
    [16] = {6, 0},
    [17] = {6, 1},
    [18] = {6, 2},
    [19] = {6, 3},
    [20] = {6, 4},
    [21] = {6, 5},
}


BattleUtils.ATTR_Atk = 1            --攻击力
BattleUtils.ATTR_AtkPro = 2         --攻击力%
BattleUtils.ATTR_AtkAdd = 3         --攻击力额外
BattleUtils.ATTR_HP = 4             --生命
BattleUtils.ATTR_HPPro = 5          --生命%
BattleUtils.ATTR_HPAdd = 6          --生命额外
BattleUtils.ATTR_Def = 7            --护甲
BattleUtils.ATTR_Pen = 8            --破甲
BattleUtils.ATTR_Crit = 9           --暴击值
BattleUtils.ATTR_CritD = 10         --暴伤
BattleUtils.ATTR_Resilience = 11    --韧性
BattleUtils.ATTR_Dodge = 12         --闪避值
BattleUtils.ATTR_Hit = 13           --命中值
BattleUtils.ATTR_Haste = 14         --急速值
BattleUtils.ATTR_Hot = 15           --生命回复
BattleUtils.ATTR_Heal = 16          --治疗
BattleUtils.ATTR_HealPro = 17       --治疗%
BattleUtils.ATTR_BeHeal = 18        --被治疗
BattleUtils.ATTR_BeHealPro = 19     --被治疗%
BattleUtils.ATTR_DamageInc = 20     --兵团伤害%
BattleUtils.ATTR_DamageDec = 21     --兵团免伤%
BattleUtils.ATTR_AHP = 22           --吸血
BattleUtils.ATTR_AHPPro = 23        --吸血%
BattleUtils.ATTR_DHP = 24           --反弹
BattleUtils.ATTR_DHPPro = 25        --反弹%
BattleUtils.ATTR_RPhysics = 26      --抗物理%1
BattleUtils.ATTR_RFire = 27         --抗火%1
BattleUtils.ATTR_RWater = 28        --抗水%1
BattleUtils.ATTR_RWind = 29         --抗气%1
BattleUtils.ATTR_REarth = 30        --抗土%1
BattleUtils.ATTR_MSpeed = 31        --移动速度
BattleUtils.ATTR_RAll = 32          --全抗%1
BattleUtils.ATTR_Shiqi = 33         --士气
BattleUtils.ATTR_AtkDis = 34        --攻击距离
BattleUtils.ATTR_DefPro = 35        --护甲%
BattleUtils.ATTR_PenPro = 36        --破防%
BattleUtils.ATTR_DefAdd = 37        --护甲成长
BattleUtils.ATTR_PenAdd = 38        --破甲成长
BattleUtils.ATTR_RPhysics_2 = 39    --抗物理%2
BattleUtils.ATTR_RFire_2 = 40       --抗火%2
BattleUtils.ATTR_RWater_2 = 41      --抗水%2
BattleUtils.ATTR_RWind_2 = 42       --抗气%2
BattleUtils.ATTR_REarth_2 = 43      --抗土%2
BattleUtils.ATTR_RAll_2 = 44        --全抗%2
BattleUtils.ATTR_RPhysics_3 = 45    --抗物理%3
BattleUtils.ATTR_RFire_3 = 46       --抗火%3
BattleUtils.ATTR_RWater_3 = 47      --抗水%3
BattleUtils.ATTR_RWind_3 = 48       --抗气%3
BattleUtils.ATTR_REarth_3 = 49      --抗土%3
BattleUtils.ATTR_RAll_3 = 50        --全抗%3
BattleUtils.ATTR_DecFire = 51       --火系免伤%
BattleUtils.ATTR_DecWater = 52      --水系免伤%
BattleUtils.ATTR_DecWind = 53       --气系免伤%
BattleUtils.ATTR_DecEarth = 54      --土系免伤%
BattleUtils.ATTR_DecAll = 55        --全系免伤%
BattleUtils.ATTR_DecAllEx = 56      --全系免伤_额外
-- 以下这两个属性，成对出现，超过阀值的伤害部分，按照百分比减伤
BattleUtils.ATTR_HDamageDec_Thr = 57  -- 英雄法术减伤血量阀值 threshold
BattleUtils.ATTR_HDamageDec_Pro = 58  -- 英雄法术减伤百分比 

BattleUtils.ATTR_DecFire1 = 59      --火系免伤%
BattleUtils.ATTR_DecWater1 = 60      --水系免伤%
BattleUtils.ATTR_DecWind1 = 61       --气系免伤%
BattleUtils.ATTR_DecEarth1 = 62      --土系免伤%
BattleUtils.ATTR_DecAll1 = 63        --全系免伤%
BattleUtils.ATTR_GlobalAtk = 64      --全局攻击 攻击_%4
BattleUtils.ATTR_GlobalDef = 65      --全局生命 生命_%4
BattleUtils.ATTR_RuneAtk = 66        --宝石攻击
BattleUtils.ATTR_RuneDef = 67        --宝石防御

BattleUtils.ATTR_COUNT = BattleUtils.ATTR_RuneDef

BattleUtils.kIconTypeSkill = 3
BattleUtils.kIconTypeHeroSpecialty = 17
BattleUtils.kIconTypeHeroMastery = 18
BattleUtils.kIconTypeAttributeAtk = 25
BattleUtils.kIconTypeAttributeDef = 26
BattleUtils.kIconTypeAttributeInt = 27
BattleUtils.kIconTypeAttributeAck = 28
BattleUtils.kIconTypeAttributeMorale = 29
BattleUtils.kIconTypeAttributeMagic = 30
BattleUtils.kIconTypeAllAttributes = 100
BattleUtils.kIconTypeHeroSkillDamage = 31

K_ASPEED = 0.01
-- teamid 怪兽ID
-- star 怪兽星
-- smallStar
-- stage 怪兽阶
-- level 怪兽等级
-- equip {{stage, level}, {}, {}, {}} 怪兽装备4件的阶和等级

-- return 
-- e.g. 
-- local baseAttr = BattleUtils.getTeamBaseAttr(teamData, equip)
-- baseAttr[BattleUtils.ATTR_Atk] -- 攻击力
-- classCount 为各兵种数量
-- moveTypeCount
-- race1Count

-- 攻，防，突，射，魔
local classIdxTable = {10, 6, 2, 4, 8}
-- 城堡，壁垒，据点，墓园，地狱，塔楼，地下城，要塞，元素
local raceIdxTable = {1, 3, 5, 7, 9, 11, 13, 14, 12}
local potentialTable = {
    [1]={{5,2},{21,0.5}},
    [2]={{14,0.5},{55,0.5}},
    [3]={{2,2},{20,0.5}},
}
BattleUtils.G_TEAM_TALENTSKILL = {0,1000,2000,3000,4000,5000,6000,7000,8000,10000,12000,14000,16000,18000,20000,22000}
local G_TEAM_TALENTSKILL = BattleUtils.G_TEAM_TALENTSKILL
function BattleUtils.getTeamBaseAttr(teamData, equip, pokedex, classCount, moveTypeCount, race1Count, teampassives, xcount)
    local skillLevel = teamData.skill
    if skillLevel == nil then
        skillLevel = {teamData.sl1, teamData.sl2, teamData.sl3, teamData.sl4}
    end
    local teamid = teamData.teamid or teamData.teamId
    local star = teamData.star 
    local smallStar = teamData.smallStar or 1
    local stage = teamData.stage 
    local level = teamData.level 
    local baseAttr = {}
    for i = 1, BattleUtils.ATTR_COUNT do
        baseAttr[i] = 0
    end

    local teamD = tab.team[teamid]

    local i = teamD["volume"]

    local atk, hp
    if teamData.jx or (teamData.ast == 3) then
        -- 觉醒属性
        local jxLv = teamData.jxLv or teamData.aLvl or 1
        if jxLv then
            atk = (teamD["atkadd"][star] + teamD["atktalent"][jxLv]) * (level + 9) + teamD["atknum"][stage]
            hp = (teamD["hpadd"][star] + teamD["hptalent"][jxLv]) * (level + 9) + teamD["hpnum"][stage]   
        end
    else
        atk = teamD["atkadd"][star] * (level + 9) + teamD["atknum"][stage]
        hp = teamD["hpadd"][star] * (level + 9) + teamD["hpnum"][stage]
    end

    local atkspeedbase = teamD["atkspeedbase"][star] 

    local def = teamD["defadd"][star] * (level + 9) + teamD["defnum"][stage]
    local pen = teamD["penadd"][star] * (level + 9) + teamD["pennum"][stage]

    if smallStar > 0 then
        local smallstaradd = teamD["smallstaraddcount"][smallStar]
        baseAttr[BattleUtils.ATTR_Atk] = atk + smallstaradd[1]
        baseAttr[BattleUtils.ATTR_HP] = hp + smallstaradd[2]
        baseAttr[BattleUtils.ATTR_Def] = def + smallstaradd[3]
        baseAttr[BattleUtils.ATTR_Pen] = pen + smallstaradd[4]
    else
        baseAttr[BattleUtils.ATTR_Atk] = atk
        baseAttr[BattleUtils.ATTR_HP] = hp
        baseAttr[BattleUtils.ATTR_Def] = def
        baseAttr[BattleUtils.ATTR_Pen] = pen
    end

    -- 计算装备增加的属性
    local equipD
    local attr, attr1, adattr
    for i = 1, 4 do
        equipD = tab.equipment[teamD["equip"][i]]
        if equipD then
            attr = equipD["attr"]
            baseAttr[attr] = baseAttr[attr] + (equip[i].level + 9) * equipD["num"][equip[i].stage]
            attr1 = equipD["attr1"]
            baseAttr[attr1] = baseAttr[attr1] + (equip[i].level + 9) * equipD["num1"][equip[i].stage]
            
            for k = 1, BattleUtils.TEAM_QUALITY[equip[i].stage][1] - 2 do
                adattr = equipD["adattr"..k]
                if adattr then
                    attr = adattr[1]
                    baseAttr[attr] = baseAttr[attr] + adattr[2]
                end
            end

        end
    end

    -- 计算被动技能增加的属性
    local passives
    if teampassives then
        passives = teampassives
    else
        -- 觉醒技能
        local jxSkill = {}
        if teamData.jx or (teamData.ast == 3 and teamData.tree) then
            local jxSkill1 = teamData.jxSkill1 or teamData.tree.b1
            local jxSkill2 = teamData.jxSkill2 or teamData.tree.b2
            local jxSkill3 = teamData.jxSkill3 or teamData.tree.b3
            if jxSkill1 and jxSkill1 ~= 0 then
                local talentTree = teamD["talentTree1"]
                local talentSkill = talentTree[jxSkill1 + 1]
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

        passives = {}
        local index = 1
        local skillD = teamD["skill"]
        local __jxSkill, sl
        if skillD then
            for i = 1, #skillD do
                __jxSkill = jxSkill[i]
                sl = skillLevel[i]
                if sl > 0 then
                    if __jxSkill then
                        if __jxSkill[3] == 1 then
                            -- 额外增加
                            if skillD[i][1] == 2 then
                                passives[index] = {skillD[i][2], sl}
                                index = index + 1
                            end
                            if __jxSkill[1] == 2 then
                                passives[index] = {__jxSkill[2], sl}
                                index = index + 1
                            end
                        else
                            -- 改变
                            if __jxSkill[1] == 2 then
                                passives[index] = {__jxSkill[2], sl}
                                index = index + 1
                            end
                        end
                    else
                        if skillD[i][1] == 2 then
                            passives[index] = {skillD[i][2], sl}
                            index = index + 1
                        end
                    end
                end
            end
        end

        -- 兵种技能
        local cskill = teamD["cs"]
        if cskill and cskill[1] == 2 then
            if teamData.tmScore then
                local score = tonumber(teamData.tmScore)
                local level = #G_TEAM_TALENTSKILL
                for i = 1, level do
                    if score < G_TEAM_TALENTSKILL[i] then
                        level = i - 1
                        break
                    end
                end
                -- print("####", level)
                passives[index] = {cskill[2], level}
                index = index + 1
            else
                passives[index] = {cskill[2], 1}
                index = index + 1
            end
        end

        -- 隐藏技能
        local hideSkill = teamD["hideSkill"]
        if hideSkill and hideSkill[1] == 2 then 
            passives[index] = {hideSkill[2], 1}
            index = index + 1
        end

        -- 检查被动技能中的组合技能
        local compose
        local _passives = passives
        index = 1
        passives = {}
        for i = 1, #_passives do
            compose = tab.skillPassive[_passives[i][1]]["compose"]
            if compose then
                for k = 1, #compose do
                    if compose[k][1] == 2 then
                        passives[index] = {compose[k][2], _passives[i][2]}
                        index = index + 1
                    end
                end
            else
                passives[index] = {_passives[i][1], _passives[i][2]}
                index = index + 1
            end
        end 
    end

    local passive, attr, value, level, condition, count
    for i = 1, #passives do
       passive = tab.skillPassive[passives[i][1]]
       if passive and passive["compose"] == nil then
            attr = passive["attr"]
            condition = passive["condition"]
            count = 0
            if condition then
                if condition == 0 then
                   count = 1
                elseif condition == 1 then
                    if moveTypeCount then
                        count = moveTypeCount[2]
                    end
                elseif condition < 7 then
                    if classCount then
                        count = classCount[condition - 1]
                    end
                elseif condition < 16 then
                    if race1Count then
                        count = race1Count[condition - 6]
                    end
                elseif 16 == condition then
                    local class = teamD["class"]
                    if classCount and class then
                        count = classCount[class]
                    end
                elseif 17 == condition then
                    local race1 = teamD["race"][1]
                    if race1Count and race1 then
                        count = race1Count[race1 - 100]
                    end
                elseif condition >= 23 and condition <= 25 then
                    if xcount then
                        count = xcount[26 - condition]
                    end
                end
            end
            level = passives[i][2]
            if attr then
                for k = 1, #attr do
                    value = attr[k][2] + (level - 1) * attr[k][3]
                    baseAttr[attr[k][1]] = baseAttr[attr[k][1]] + value * count
                end
            end
        end
    end

    -- 升星里属性
    if teamData.avn == 1 then
        for k,v in pairs(potentialTable) do
            if teamData.pl and teamData.pl[tostring(k)] then
                local plevel = teamData.pl[tostring(k)]
                for i=1,2 do
                    local attr = v[i][1]
                    local value = v[i][2] * plevel
                    baseAttr[attr] = baseAttr[attr] + value
                end
            end
        end
    end
    -- 兵团天赋
    if teamData.tt then
        local a
        for attr, value in pairs(teamData.tt) do
            a = tonumber(attr)
            baseAttr[a] = baseAttr[a] + tonumber(value)
            -- print(attr, value)
        end
    end

    -- 兵团符文宝石
    if teamData.rune then
        local runes = {}
         -- 基础属性
         local Tostring = tostring
         local Tonumber = tonumber
        for i=1,6 do
            local baseRune = teamData.rune[Tostring(i)]
            if baseRune then
                if teamData.runes and teamData.runes[Tostring(baseRune)] then
                    local t = teamData.runes[Tostring(baseRune)]
                    local runeId = t["id"] -- 宝石id
                    local values = t["p"]
                    if not runes[runeId] then
                        runes[runeId] = {}
                    end 
                    for k,v in pairs(values) do
                        -- 判断是否存在
                        if not runes[runeId][k] then
                            runes[runeId][k] = v
                        else
                            runes[runeId][k] = runes[runeId][k] + v
                        end 
                    end
                end 
            end 
        end

        -- 套装属性
        local suit = teamData.rune["suit"]
        if suit then
            local t = {"2", "6"}  -- "4" 在兵团技能初始化那里加

            for i=1,#t do
                local effComsStr = suit[t[i]]
                if effComsStr then
                    local effComs = string.split(effComsStr,",")
                    for j=1,#effComs do
                        local runeId = Tonumber(effComs[j])
                        local buffData = tab.rune[runeId]["effect"..t[i]]
                        for m=1, #buffData do
                            -- 判断是否存在
                            if not runes[runeId] then
                                 runes[runeId] = {}
                            end

                            if not runes[runeId][buffData[m][1]] then
                                runes[runeId][buffData[m][1]] = buffData[m][2]
                            else
                                runes[runeId][buffData[m][1]] = runes[runeId][buffData[m][1]] + buffData[m][2]
                            end 
                        end
                    end
                end 
            end
        end

        -- 添加符文宝石属性
        for runeId, value in pairs(runes) do
            for attr,v in pairs(value) do
                local a = Tonumber(attr)
                baseAttr[a] = baseAttr[a] + v
            end
        end

        if teamData.rune.castinglv then
            local castinglv = teamData.rune.castinglv
            if castinglv >= 10 then
                local castingid = math.floor(castinglv / 10)
                if castingid > 6 then castingid = 6 end
                local dcasting = tab.runeCastingMastery[castingid]
                if dcasting then
                    local castingattr = dcasting["castingMastery"]
                    for _, attr in ipairs(castingattr) do
                        local a = Tonumber(attr[1])
                        local v = Tonumber(attr[2])
                        baseAttr[a] = baseAttr[a] + v
                    end
                end
            end
        end
    end 

    -- 图鉴
    if pokedex and pokedex[1] ~= false then
        local addValue = pokedex[classIdxTable[teamD["class"]]] or 0
        local idx = raceIdxTable[teamD["race"][1] - 100]
        if pokedex[idx] then
            addValue = addValue + pokedex[idx]
        end
        addValue = addValue * 0.006
        baseAttr[BattleUtils.ATTR_AtkPro] = baseAttr[BattleUtils.ATTR_AtkPro] + addValue
        baseAttr[BattleUtils.ATTR_HPPro] = baseAttr[BattleUtils.ATTR_HPPro] + addValue
    end

    local atkSpeed = atkspeedbase * (1 + K_ASPEED * baseAttr[BattleUtils.ATTR_Haste])
    -- BattleUtils.dumpBaseAttr(baseAttr)
    return baseAttr, atkspeedbase, atkSpeed
end

function BattleUtils.getTeamBaseAttr1(inTeam, pokedex)
    local tempEquips = inTeam.equip
    if tempEquips == nil then
        tempEquips = {}
        for i=1,4 do
            local tempEquip = {}
            local equipLevel = inTeam["el" .. i]
            local equipStage = inTeam["es" .. i]
            tempEquip.stage = equipStage
            tempEquip.level = equipLevel
            table.insert(tempEquips, tempEquip)
        end
    end

    local backData, backSpeed, atkSpeed = BattleUtils.getTeamBaseAttr(inTeam, tempEquips, pokedex)
    return backData, backSpeed, atkSpeed
end

function BattleUtils.getTeamAttackAttr(baseAttr, flag)
    local attack =  baseAttr[1] * (100+baseAttr[2]) / 100 + baseAttr[3]
    if flag == true then
        return attack
    end
    return ceil(attack)
end

function BattleUtils.getTeamHpAttr(baseAttr, flag)
    local hp =  baseAttr[4] * (100+baseAttr[5]) / 100 + baseAttr[6]
    if flag == true then
        return hp
    end
    return ceil(hp)
end

function BattleUtils.dumpBaseAttr(baseAttr)
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

    print("-----------------------------")
    for i = 1, BattleUtils.ATTR_COUNT do
        print(attr[i].." "..baseAttr[i])
    end
    print("-----------------------------")
end

---- 英雄属性 ----

-- 法伤固定值
BattleUtils.HATTR_APAdd = 1

-- 蓝和士气
BattleUtils.HATTR_Mana = 2
BattleUtils.HATTR_ManaPro = 3
BattleUtils.HATTR_ManaRec = 4
BattleUtils.HATTR_ManaRecPro = 5
BattleUtils.HATTR_ManaMax = 6
BattleUtils.HATTR_Shiqi = 7

-- 法术阻挡, 使对方法术失败
BattleUtils.HATTR_Hinder = 8
-- 护盾加成
BattleUtils.HATTR_ShieldPro = 9

-- 攻击防御智力知识
BattleUtils.HATTR_Atk = 10
BattleUtils.HATTR_AtkPro = 11
BattleUtils.HATTR_AtkAdd = 12
BattleUtils.HATTR_Def = 13
BattleUtils.HATTR_DefPro = 14
BattleUtils.HATTR_DefAdd = 15
BattleUtils.HATTR_Int = 16
BattleUtils.HATTR_IntPro = 17
BattleUtils.HATTR_IntAdd = 18
BattleUtils.HATTR_Ack = 19
BattleUtils.HATTR_AckPro = 20
BattleUtils.HATTR_AckAdd = 21

-- 法伤
BattleUtils.HATTR_APFire = 22
BattleUtils.HATTR_APWater = 23
BattleUtils.HATTR_APWind = 24
BattleUtils.HATTR_APEarth = 25
BattleUtils.HATTR_APAll = 26
-- 分系法伤
BattleUtils.HATTR_AP1Fire = 27
BattleUtils.HATTR_AP1Water = 28
BattleUtils.HATTR_AP1Wind = 29
BattleUtils.HATTR_AP1Earth = 30
BattleUtils.HATTR_AP1All = 31

BattleUtils.HATTR_AP2Fire = 32
BattleUtils.HATTR_AP2Water = 33
BattleUtils.HATTR_AP2Wind = 34
BattleUtils.HATTR_AP2Earth = 35
BattleUtils.HATTR_AP2All = 36
BattleUtils.HATTR_AP3Fire = 37
BattleUtils.HATTR_AP3Water = 38
BattleUtils.HATTR_AP3Wind = 39
BattleUtils.HATTR_AP3Earth = 40
BattleUtils.HATTR_AP3All = 41

-- 初始技能CD%
BattleUtils.HATTR_InitCDProFire = 42
BattleUtils.HATTR_InitCDProWater = 43
BattleUtils.HATTR_InitCDProWind = 44
BattleUtils.HATTR_InitCDProEarth = 45
BattleUtils.HATTR_InitCDProAll = 46
-- 分系初始CD%
BattleUtils.HATTR_InitCDPro1Fire = 47
BattleUtils.HATTR_InitCDPro1Water = 48
BattleUtils.HATTR_InitCDPro1Wind = 49
BattleUtils.HATTR_InitCDPro1Earth = 50
BattleUtils.HATTR_InitCDPro1All = 51
BattleUtils.HATTR_InitCDPro2Fire = 52
BattleUtils.HATTR_InitCDPro2Water = 53
BattleUtils.HATTR_InitCDPro2Wind = 54
BattleUtils.HATTR_InitCDPro2Earth = 55
BattleUtils.HATTR_InitCDPro2All = 56
BattleUtils.HATTR_InitCDPro3Fire = 57
BattleUtils.HATTR_InitCDPro3Water = 58
BattleUtils.HATTR_InitCDPro3Wind = 59
BattleUtils.HATTR_InitCDPro3Earth = 60
BattleUtils.HATTR_InitCDPro3All = 61

-- 技能CD%
BattleUtils.HATTR_CDProFire = 62
BattleUtils.HATTR_CDProWater = 63
BattleUtils.HATTR_CDProWind = 64
BattleUtils.HATTR_CDProEarth = 65
BattleUtils.HATTR_CDProAll = 66
-- 分系CD%
BattleUtils.HATTR_CDPro1Fire = 67
BattleUtils.HATTR_CDPro1Water = 68
BattleUtils.HATTR_CDPro1Wind = 69
BattleUtils.HATTR_CDPro1Earth = 70
BattleUtils.HATTR_CDPro1All = 71
BattleUtils.HATTR_CDPro2Fire = 72
BattleUtils.HATTR_CDPro2Water = 73
BattleUtils.HATTR_CDPro2Wind = 74
BattleUtils.HATTR_CDPro2Earth = 75
BattleUtils.HATTR_CDPro2All = 76
BattleUtils.HATTR_CDPro3Fire = 77
BattleUtils.HATTR_CDPro3Water = 78
BattleUtils.HATTR_CDPro3Wind = 79
BattleUtils.HATTR_CDPro3Earth = 80
BattleUtils.HATTR_CDPro3All = 81

-- 耗魔 ManaCostDec
BattleUtils.HATTR_MCDFire = 82
BattleUtils.HATTR_MCDWater = 83
BattleUtils.HATTR_MCDWind = 84
BattleUtils.HATTR_MCDEarth = 85
BattleUtils.HATTR_MCDAll = 86
-- 分系耗魔
BattleUtils.HATTR_MCD1Fire = 87
BattleUtils.HATTR_MCD1Water = 88
BattleUtils.HATTR_MCD1Wind = 89
BattleUtils.HATTR_MCD1Earth = 90
BattleUtils.HATTR_MCD1All = 91
BattleUtils.HATTR_MCD2Fire = 92
BattleUtils.HATTR_MCD2Water = 93
BattleUtils.HATTR_MCD2Wind = 94
BattleUtils.HATTR_MCD2Earth = 95
BattleUtils.HATTR_MCD2All = 96
BattleUtils.HATTR_MCD3Fire = 97
BattleUtils.HATTR_MCD3Water = 98
BattleUtils.HATTR_MCD3Wind = 99
BattleUtils.HATTR_MCD3Earth = 100
BattleUtils.HATTR_MCD3All = 101

-- 法术范围 RangeInc
BattleUtils.HATTR_RIFire = 102
BattleUtils.HATTR_RIWater = 103
BattleUtils.HATTR_RIWind = 104
BattleUtils.HATTR_RIEarth = 105
BattleUtils.HATTR_RIAll = 106
-- 分系范围
BattleUtils.HATTR_RI1Fire = 107
BattleUtils.HATTR_RI1Water = 108
BattleUtils.HATTR_RI1Wind = 109
BattleUtils.HATTR_RI1Earth = 110
BattleUtils.HATTR_RI1All = 111
BattleUtils.HATTR_RI2Fire = 112
BattleUtils.HATTR_RI2Water = 113
BattleUtils.HATTR_RI2Wind = 114
BattleUtils.HATTR_RI2Earth = 115
BattleUtils.HATTR_RI2All = 116
BattleUtils.HATTR_RI3Fire = 117
BattleUtils.HATTR_RI3Water = 118
BattleUtils.HATTR_RI3Wind = 119
BattleUtils.HATTR_RI3Earth = 120
BattleUtils.HATTR_RI3All = 121

-- 法术效果翻倍 DoubleEffect
BattleUtils.HATTR_DEFire = 122
BattleUtils.HATTR_DEWater = 123
BattleUtils.HATTR_DEWind = 124
BattleUtils.HATTR_DEEarth = 125
BattleUtils.HATTR_DEAll = 126
-- 分析翻倍
BattleUtils.HATTR_DE1Fire = 127
BattleUtils.HATTR_DE1Water = 128
BattleUtils.HATTR_DE1Wind = 129
BattleUtils.HATTR_DE1Earth = 130
BattleUtils.HATTR_DE1All = 131
BattleUtils.HATTR_DE2Fire = 132
BattleUtils.HATTR_DE2Water = 133
BattleUtils.HATTR_DE2Wind = 134
BattleUtils.HATTR_DE2Earth = 135
BattleUtils.HATTR_DE2All = 136
BattleUtils.HATTR_DE3Fire = 137
BattleUtils.HATTR_DE3Water = 138
BattleUtils.HATTR_DE3Wind = 139
BattleUtils.HATTR_DE3Earth = 140
BattleUtils.HATTR_DE3All = 141

-- 法术等级提升
BattleUtils.HATTR_LevelAddFire = 142
BattleUtils.HATTR_LevelAddWater = 143
BattleUtils.HATTR_LevelAddWind = 144
BattleUtils.HATTR_LevelAddEarth = 145
BattleUtils.HATTR_LevelAddAll = 146
-- 分系等级提升
BattleUtils.HATTR_LevelAdd1Fire = 147
BattleUtils.HATTR_LevelAdd1Water = 148
BattleUtils.HATTR_LevelAdd1Wind = 149
BattleUtils.HATTR_LevelAdd1Earth = 150
BattleUtils.HATTR_LevelAdd1All = 151
BattleUtils.HATTR_LevelAdd2Fire = 152
BattleUtils.HATTR_LevelAdd2Water = 153
BattleUtils.HATTR_LevelAdd2Wind = 154
BattleUtils.HATTR_LevelAdd2Earth = 155
BattleUtils.HATTR_LevelAdd2All = 156
BattleUtils.HATTR_LevelAdd3Fire = 157
BattleUtils.HATTR_LevelAdd3Water = 158
BattleUtils.HATTR_LevelAdd3Wind = 159
BattleUtils.HATTR_LevelAdd3Earth = 160
BattleUtils.HATTR_LevelAdd3All = 161
-- 大招
BattleUtils.HATTR_MGTriggerPro1 = 162
BattleUtils.HATTR_MGTriggerPro2 = 163
BattleUtils.HATTR_MGTriggerPro3 = 164
BattleUtils.HATTR_MGTriggerPro4 = 165

-- 召唤物兵团减伤
BattleUtils.HATTR_SummonTeamDamageDec = 166
-- 召唤物法术减伤
BattleUtils.HATTR_SummonHeroDamageDec = 167
-- 控制类BUFF时间减免
BattleUtils.HATTR_TeamControlDec = 168

-- 分系法伤2
BattleUtils.HATTR_AP1Fire1 = 169
BattleUtils.HATTR_AP1Water1 = 170
BattleUtils.HATTR_AP1Wind1 = 171
BattleUtils.HATTR_AP1Earth1 = 172
BattleUtils.HATTR_AP1All1 = 173


BattleUtils.HATTR_COUNT = BattleUtils.HATTR_AP1All1

-- npc英雄
function BattleUtils.getNpcHeroBaseAttr(heroD, treasure, talent, branchHAb, isBattleData)
    local _slevel = clone(heroD["spelllv"])
    if _slevel == nil then
        _slevel = {}
    end
    local _masterys = {}
    for i = 1, 5 do
        if heroD["m"..i] == nil then
            break
        end
        _masterys[i] = heroD["m"..i]
    end
    local hAb
    if branchHAb then
        hAb = {
                ["1"] = heroD["atk"] + (branchHAb["1"] or 0), 
                ["2"] = heroD["def"] + (branchHAb["2"] or 0), 
                ["3"] = heroD["int"] + (branchHAb["3"] or 0), 
                ["4"] = heroD["ack"] + (branchHAb["4"] or 0)
            }
    else
        hAb = {
                ["1"] = heroD["atk"], 
                ["2"] = heroD["def"], 
                ["3"] = heroD["int"], 
                ["4"] = heroD["ack"]
            }
    end
    local values = BattleUtils.getHeroBaseAttr(heroD, heroD["herolv"], _slevel, heroD["herostar"], _masterys, nil, treasure, nil, talent, hAb, nil, nil, nil, isBattleData)
    return values
end
function BattleUtils.getHeroGlobalMasterys(gs)
    local globalMasterys = {}
    if gs == nil then return nil end
    if gs == "" then return nil end
    if type(gs) ~= "string" then return nil end
    globalMasterys = _G.json.decode(gs)
    return globalMasterys
end
-- 获取宝物附加的技能
function BattleUtils.getHerotreasureMasterys(treasure)
    -- 宝物附加专精
    local treasureMasterys = {}

    -- 宝物, 附加属性 有怪兽属性和英雄属性
    local comTreasureD, disTreasureD, t_attr
    local rank = 0
    if treasure then
        for id, com in pairs(treasure) do
            comTreasureD = tab.comTreasure[tonumber(id)]
            if com.stage > 0 then
                if skillType == 2 or skillType == 6 then
                    -- 被动技能 增加一个专精
                    treasureMasterys[#treasureMasterys + 1] = {comTreasureD["skill"], com.stage}
                end
            end
        end
    end
    return treasureMasterys
end

function BattleUtils.getHeroStarChatsMastery( starChats,hStar )
    local starChartsMasterys = {}
    if not hStar then
        return {}
    end
    -- 星体
    for starId,actNum in pairs(hStar.ssmap or {}) do
        local starInfo = tab.starChartsStars[tonumber(starId)]
        if starInfo and actNum > 0 then
            if (starInfo.ability_sort == 1 and starCharts and starCharts.ssIds and starCharts.ssIds[tostring(starId)])
               or starInfo.ability_sort == 2 then -- 全局属性
                -- 英雄
                if starInfo.heroMastery then
                    starChartsMasterys[#starChartsMasterys+1] = {tonumber(starInfo.heroMastery),1}
                end
            end
        end
    end
    -- 星链
    for catenId,catenNum in pairs(hStar.scmap or {}) do
        local catenInfo = tab.starChartsCatena[tonumber(catenId)]
        if catenInfo and catenNum > 0 then
            if (catenInfo.ability_sort == 1 and starCharts and starCharts.scIds and starCharts.scIds[tostring(catenId)])
               or catenInfo.ability_sort == 2
            then
                if catenInfo.heromasteryid then
                    starChartsMasterys[#starChartsMasterys+1] = {tonumber(catenInfo.heromasteryid),1}
                end
            end
        end
    end
    -- 星图(构成)
    for chartsId,chartsNum in pairs(hStar.smap or {}) do
        local starChartsTab = tab.starCharts 
        for i,chartsD in ipairs(starChartsTab) do
            if tonumber(chartsD.hero) == tonumber(chartsId) or chartsD.ability_sort == 2 then
                if chartsD.heromasteryid then
                    starChartsMasterys[#starChartsMasterys+1] = {tonumber(chartsD.heromasteryid),1}
                end
            end
        end
    end
    return starChartsMasterys
end
-- 统计英雄的被动技能-- 来源 专精 专长 全局专长
function BattleUtils.getHeroMasterys(heroD, star, masterys, globalMasterys, treasureMasterys, uMastery, skillex,starChartMasterys)
    if star == nil then 
        star = 1 
        print("getHeroMasterys star == nil")
    end
    -- 被动技能
    local masterysMap = {}
    local masterysArray = {}
    local mid
    -- 专精, 可刷, 来自服务器
    local masteryD
    for i = 1, #masterys do
        mid = masterys[i]
        masteryD = tab.heroMastery[mid]
        if masteryD["global"] == nil and masterysMap[mid] == nil then
            masterysMap[mid] = true
            masterysArray[#masterysArray + 1] = {mid, 1, 3, 1}
        end
    end
    -- 专长, 根据star开放
    local special = heroD["special"]
    if special then
        for i = 1, star do
            mid = special * 10 + i
            if masterysMap[mid] == nil then
                masterysMap[mid] = true
                masterysArray[#masterysArray + 1] = {mid, 1, 1, 1}
            end
        end
    end

    -- 全局专长, 英雄不上场也生效
    if globalMasterys then
        for i = 1, #globalMasterys do
            mid = globalMasterys[i]
            if masterysMap[mid] == nil then
                masterysMap[mid] = true
                masterysArray[#masterysArray + 1] = {mid, 1, 1, 1}
            end
        end
    end

    if treasureMasterys then
        for i = 1, #treasureMasterys do
            mid = treasureMasterys[i][1]
            if masterysMap[mid] == nil then
                masterysMap[mid] = true
                masterysArray[#masterysArray + 1] = {mid, treasureMasterys[i][2], 2, 1}
            end
        end
    end  

    if starChartMasterys then
        for i = 1, #starChartMasterys do
            mid = starChartMasterys[i][1]
            if masterysMap[mid] == nil then
                masterysMap[mid] = true
                masterysArray[#masterysArray + 1] = {mid, starChartMasterys[i][2], 5, 1}
            end
        end
    end

    -- 法术插槽
    if skillex then
        local _id = skillex[1]
        local _level = skillex[2]
        local bookLevel = skillex[3]
        local skillBookBaseD = tab.skillBookBase[_id]
        if skillBookBaseD and skillBookBaseD["skillType"] == 2 then
            -- 被动法术
            if bookLevel and bookLevel > 1 and skillBookBaseD["type"] == 4 then
                local level = bookLevel-1
                local id = _id..level
                id = tonumber(id)
                masterysArray[#masterysArray + 1] = {id, _level, 4, 1}
            else
                masterysArray[#masterysArray + 1] = {_id, _level, 4, 1}
            end    
        end
    end

    if uMastery then
        local array = {}
        for id, count in pairs(uMastery) do
            if count > 0 then
                array[#array + 1] = {tonumber(id), count}
            end
        end
        table.sort(array, function (a, b)
            return a[1] < b[1]
        end)
        for i = 1, #array do
            masterysArray[#masterysArray + 1] = {array[i][1], 1, 3, array[i][2]}
        end
    end
    return masterysArray
end

-- 根据英雄id 等级, 专精 装备, 计算出英雄的属性
function BattleUtils.getHeroBaseAttr(heroD, level, slevel, star, masterys, globalMasterys, treasure, buff, talent, hAb, uMastery, skillex, weapons, isBattleData, isEnemyHero, manabase, manarec,qhab,starCharts,hStar,battleType)
    local heroD = heroD
    -- dump({heroD, level, slevel, star, masterys,
    --  globalMasterys, treasure, buff, talent, hAb, uMastery, skillex, weapons, isBattleData}, "asdbjfgh")
    if star == nil then
        star = 1
    end

    -- 怪兽属性追加 -- [飞行][兵种][体型][属性]
    local monsterAttr = {{{{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}}, {{{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}}}
    local monsterAttrikn
    for i = 1, #monsterAttr do
        for k = 1, #monsterAttr[i] do
            for n = 1, #monsterAttr[i][k] do
                monsterAttrikn = monsterAttr[i][k][n]
                for m = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
                    monsterAttrikn[m] = 0
                end
            end
        end
    end
    -- 怪兽属性追加 -- label1
    local monsterAttr1 = {}

    -- 怪兽属性追加 -- 全局
    local monsterAttr2 = {}
    for m = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        monsterAttr2[m] = 0
    end

    -- 怪兽属性召唤物
    local monsterAttr3 = {}
    for m = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        monsterAttr3[m] = 0
    end

    -- 怪兽属性追加，[飞行][兵种][体型][职业][属性] -- 星图系统增加
    local monsterAttr4 = {}

    -- 主动技能
    local heroSkills = {0, 0, 0, 0}
    local spells = heroD["spell"] -- 英雄表的配置法术
    if spells then
        for i = 1, #spells do
            heroSkills[i] = spells[i]
        end
    end
    -- 开场技能
    local openSkills = {}
    -- 自动释放技能
    local autoSkills = {}
    -- 法术刻印提供的被动技能
    local skillBookPassive = {}

    -- 英雄属性追加
    local heroAttr = {}
    -- 降低对方的属性
    local heroAttrDec = {}
    -- 分开统计英雄属性
    local heroAttr_special = {}
    local heroAttr_treasure = {}
    local heroAttr_mastery = {}
    local heroAttr_talent = {}
    local heroAttr_skillBook = {}
    -- local heroAttr_buff = {}

    for i = 1, BattleUtils.HATTR_COUNT do
        heroAttr[i] = 0
        heroAttrDec[i] = 0
        heroAttr_special[i] = 0
        heroAttr_treasure[i] = 0
        heroAttr_mastery[i] = 0
        heroAttr_talent[i] = 0
        heroAttr_skillBook[i] = 0
        -- heroAttr_buff[i] = 0
    end

    -- 怪兽替换
    local teamReplace = {}
    -- buff替换
    local buffReplace = {}
    -- buff隐藏列
    local buffOpen = {}
    -- 英雄技能替换
    local skillReplace = {}


    -- 宝物附加专精
    local treasureMasterys = {}

    -- 宝物, 附加属性 有怪兽属性和英雄属性
    local comTreasureD, disTreasureD, t_attr
    local treasureEff = {}
    local rank = 0
    local _attr, _value
    local _unlockaddattr, _addattrs, _addattr, _addattr1, _addattr2, _addattr3, monsterAttrknm, _buffid1, _buffid2
    local revivePro = 0
    local reviveBuff = {}
    local allReviveBuff = {}
    local stage
    if treasure then
        for id, com in pairs(treasure) do
            comTreasureD = tab.comTreasure[tonumber(id)]
            stage = com.stage
            if stage > 0 then
                -- 宝物附加属性, 不要了
                -- if comTreasureD then
                --     for i = 1, 6 do
                --         t_attr = comTreasureD["property"][i]
                --         if t_attr then
                --             _attr = t_attr[1] - 100
                --             _value = t_attr[2] + t_attr[3] * (stage - 1)
                --             heroAttr[_attr] = heroAttr[_attr] + _value
                --             heroAttr_treasure[_attr] = heroAttr_treasure[_attr] + _value
                --         else
                --             break
                --         end
                --     end
                -- end
                if comTreasureD["frontstk_v"] then
                    table.insert(treasureEff, tonumber(id))
                end
                -- 宝物附加技能
                if com.inTForm or not isBattleData then -- todo 宝物技能开关
                    _unlockaddattr = comTreasureD["unlockaddattr"]
                    _addattrs =  comTreasureD["addattr"]
                    local step = 0 --宝物阶数
                    local skill1, skill3, skill4
                    for i = 1, #_unlockaddattr do
                        if stage >= _unlockaddattr[i] then
                            _addattr = _addattrs[i]
                            _addattr1 = _addattr[1]
                            _addattr2 = _addattr[2]
                            if _addattr1 == 1 then
                                -- 主动技能
                                skill1 = _addattr2
                            elseif _addattr1 == 2 or _addattr1 == 6 then
                                -- 被动技能 增加一个专精
                                treasureMasterys[#treasureMasterys + 1] = {_addattr2, stage}
                            elseif _addattr1 == 3 then
                                -- 开场技能
                                skill3 = _addattr2 
                            elseif _addattr1 == 5 then
                                -- 开场技能+复活第一个兵团
                                skill3 = _addattr2
                                revivePro = _addattr[3]
                            else 
                                -- 自动技能
                                skill4 = _addattr2
                            end

                            step = i
                        else
                            break
                        end
                    end

                    -- 宝物复活技能触发技能追加buff
                    _buffid1 = comTreasureD["buffid1"]
                    if revivePro ~= 0 and type(_buffid1) == "table" then
                        for bI = 1, #_buffid1 do
                            if _buffid1[bI][1] == step then
                                for sI = 2, #_buffid1[bI] do
                                    reviveBuff[#reviveBuff + 1] = _buffid1[bI][sI]
                                end
                            end
                        end
                    end

                    _buffid2 = comTreasureD["buffid2"]
                    if revivePro ~= 0 and type(_buffid2) == "table" then
                        for bI = 1, #_buffid2 do
                            if _buffid2[bI][1] == step then
                                for sI = 2, #_buffid2[bI] do
                                    allReviveBuff[#allReviveBuff + 1] = _buffid2[bI][sI]
                                end
                            end
                        end
                    end

                    -- 宝物 追加英雄技能
                    if skill1 then
                        heroSkills[#heroSkills + 1] = skill1
                        slevel[#heroSkills] = stage
                    end
                    if skill3 then
                        openSkills[#openSkills + 1] = {skill3, stage, comTreasureD}
                    end
                    if skill4 then
                        autoSkills[#autoSkills + 1] = {skill4, stage}
                    end
                end
            end
            for did, disInfo in pairs(com.treasureDev) do
                local lv = disInfo and disInfo.s or 0
                if lv > 0 then
                    -- 散件附加属性
                    -- 宝物升星附加倍数
                    local comTreasureStarIdx = (disInfo.bs or 0) * 8 + (disInfo.ss or 0) + floor((disInfo.b or 0)/100)
                    local pro
                    if comTreasureStarIdx > 0 then
                        pro = 1 + tab.comTreasureStar[comTreasureStarIdx]["attrprosum"] * 0.01
                    else
                        pro = 1
                    end
                    -- print(pro)
                    disTreasureD = tab.disTreasure[tonumber(did)]
                    if disTreasureD then
                        for i = 1, 6 do
                            t_attr = disTreasureD["property"][i]
                            if t_attr then
                                if t_attr[1] > 100 then
                                    _attr = t_attr[1] - 100
                                    _value = (t_attr[2] + t_attr[3] * (lv - 1)) * pro
                                    heroAttr[_attr] = heroAttr[_attr] + _value
                                    heroAttr_treasure[_attr] = heroAttr_treasure[_attr] + _value
                                else
                                    monsterAttr2[t_attr[1]] = monsterAttr2[t_attr[1]] + (t_attr[2] + t_attr[3] * (lv - 1)) * pro
                                end
                            else
                                break
                            end
                        end
                        -- 解锁体型属性
                        _unlockaddattr = disTreasureD["unlockaddattr"]
                        _addattrs = disTreasureD["addattr"]
                        for i = 1, #_unlockaddattr do
                            if lv >= _unlockaddattr[i] then
                                _addattr = _addattrs[i]
                                _addattr1 = _addattr[1]
                                _addattr2 = _addattr[2]
                                _addattr3 = _addattr[3]
                                for k = 1, #monsterAttr do
                                    for n = 1, #monsterAttr[k] do
                                        monsterAttrknm = monsterAttr[k][n][_addattr1 - 1]
                                        monsterAttrknm[_addattr2] = monsterAttrknm[_addattr2] + _addattr3
                                    end
                                end
                            else
                                break
                            end
                        end
                    end
                end
            end
        end

        local realComTreasure = {}
        for _, id in ipairs(treasureEff) do
            comTreasureD = tab.comTreasure[tonumber(id)]
            if comTreasureD.effdis and comTreasureD.effdis > rank then
                rank = comTreasureD.effdis
            end
        end

        
        for _, id in ipairs(treasureEff) do
            comTreasureD = tab.comTreasure[tonumber(id)]
            if comTreasureD.effdis and comTreasureD.effdis == rank then
                table.insert(realComTreasure, tonumber(id))
            end
        end 

        treasureEff = realComTreasure
    end

    -- 星图专精
    local starChartsMasterys = {}
    local starChartsLevelUp = {}
    --英雄星图等级加成
    if starCharts and starCharts.ssIds then
        for id , v in pairs(starCharts.ssIds) do
            local starInfo = tab.starChartsStars[tonumber(id)]
            if starInfo.ability_sort == 1 then
                -- 加等级
                if starInfo.ability_magic then
                    local skillId = starInfo.ability_magic[1] or 0
                    local addLevel = starInfo.ability_magic[2] or 0
                    starChartsLevelUp[skillId] = (starChartsLevelUp[skillId] or 0) + addLevel
                end
            end
        end
    end
    -- 星图增加的属性
    if hStar then
        -- 星体
        for starId,actNum in pairs(hStar.ssmap or {}) do
            local starInfo = tab.starChartsStars[tonumber(starId)]
            if tonumber(starId) == 22 then
            local x = 1
            end
            if starInfo and actNum > 0 then
                if (starInfo.ability_sort == 1 and starCharts and starCharts.ssIds and starCharts.ssIds[tostring(starId)])
                   or starInfo.ability_sort == 2 then -- 全局属性
                    -- 全局兵团
                    -- 怪兽属性追加 --monsterAttr  [飞行][兵种][体型][职业][属性]
                    -- [[--兵团属性begin
                    local volumChange = {[16]=2,[9]=3,[4]=4,[1]=5}
                    local systemIdx = tonumber(starInfo.ability_system) or 99
                    monsterAttr4[systemIdx] = monsterAttr4[systemIdx] or {}
                    for i = 1, 2 do  -- 是否飞行
                        monsterAttr4[systemIdx][i] = monsterAttr4[systemIdx][i] or {}
                        for k = 1, 5 do -- 兵种
                            monsterAttr4[systemIdx][i][k] = monsterAttr4[systemIdx][i][k] or {}
                            for n = 1, 4 do -- 体型
                                monsterAttr4[systemIdx][i][k][n] = monsterAttr4[systemIdx][i][k][n] or {}
                                for m = 101,110 do -- 职业
                                    monsterAttr4[systemIdx][i][k][n][m] = monsterAttr4[systemIdx][i][k][n][m] or {}
                                    local monsterAttriknm = monsterAttr4[systemIdx][i][k][n][m]
                                    local attrid = tonumber(starInfo.ability_team_sort) or 0
                                    local isMonsterAttr = tonumber(starInfo.ability_showtype) == 2
                                    if isMonsterAttr then
                                        if (tonumber(starInfo.ability_team_movetype) == 0 or i == tonumber(starInfo.ability_team_movetype))
                                            and (tonumber(starInfo.ability_team_posclass) == 0 or k == tonumber(starInfo.ability_team_posclass))
                                            and (tonumber(starInfo.ability_team_type) == 0 or (n == volumChange[tonumber(starInfo.ability_team_type)]-1))
                                            and (tonumber(starInfo.ability_team_camp) == 0 or m == tonumber(starInfo.ability_team_camp))
                                        then
                                            local pro = 1
                                            if tab.attClient[attrid] == 1 then
                                                pro = 0.01
                                            end
                                            monsterAttriknm[attrid] = (monsterAttriknm[attrid] or 0) + starInfo.ability_team_num*actNum*pro
                                        else
                                            monsterAttriknm[attrid] = monsterAttriknm[attrid] or 0
                                        end
                                    end
                                end
                            end
                        end
                    end
                    --]] -- 兵团属性end
                    -- 英雄
                    if (tonumber(starInfo.ability_system)==0 or tonumber(starInfo.ability_system) == battleType) and
                        (tonumber(starInfo.ability_hero_camp) == 0 or tonumber(starInfo.ability_hero_camp) == heroD.masterytype) then
                        -- local aid = tonumber(starInfo.quality_type) or 0
                        -- local value = tonumber(starInfo.quality) or 0
                        -- local pro = 1
                        -- if tab.attClient[aid] == 1 then
                        --     pro = 0.01
                        -- end
                        -- local _attr = aid - 100
                        -- heroAttr[_attr] = heroAttr[_attr] + value*actNum*pro
                        local aid = tonumber(starInfo.ability_hero_type) or 0
                        local value = tonumber(starInfo.ability_hero) or 0
                        local _attr = aid - 100
                        local pro = 1
                        if tab.attClient[aid] == 1 then
                            pro = 0.01
                        end
                        heroAttr[_attr] = heroAttr[_attr] + value*actNum*pro
                    end
                    if starInfo.heroMastery then
                        starChartsMasterys[#starChartsMasterys+1] = {tonumber(starInfo.heroMastery),1}
                    end
                    -- -- 加等级
                    -- if starInfo.ability_magic then
                    --     local skillId = starInfo.ability_magic[1] or 0
                    --     local addLevel = starInfo.ability_magic[2] or 0
                    --     starChartsLevelUp[skillId] = (starChartsLevelUp[skillId] or 0) + addLevel
                    --     -- for i,id in ipairs(heroSkills) do
                    --     --      if skillId == id then
                    --     --         slevel[i] = slevel[i]+addLevel
                    --     --      end
                    --     -- end 
                    -- end
                end
            end
        end


        -- 星链
        for catenId,catenNum in pairs(hStar.scmap or {}) do
            local catenInfo = tab.starChartsCatena[tonumber(catenId)]
            if catenInfo and catenNum > 0 then
                if (catenInfo.ability_sort == 1 and starCharts and starCharts.scIds and starCharts.scIds[tostring(catenId)])
                   -- or catenInfo.ability_sort == 2
                then
                    -- local aid = tonumber(catenInfo.quality_type) or 0
                    -- local value = tonumber(catenInfo.quality) or 0
                    -- local _attr = aid - 100
                    -- local pro = 1
                    -- if tab.attClient[aid] == 1 then
                    --     pro = 0.01
                    -- end
                    -- heroAttr[_attr] = heroAttr[_attr] + value*catenNum*pro
                    if catenInfo.heromasteryid then
                        starChartsMasterys[#starChartsMasterys+1] = {tonumber(catenInfo.heromasteryid),1}
                    end
                end
            end
        end
        -- 星图(构成)
        for chartsId,chartsNum in pairs(hStar.smap or {}) do
            local starChartsTab = tab.starCharts 
            for i,chartsD in ipairs(starChartsTab) do
                if tonumber(chartsD.hero) == tonumber(chartsId) 
                    -- or chartsD.ability_sort == 2 
                then
                    -- local aid = tonumber(chartsD.quality_type1) or 0
                    -- local value = tonumber(chartsD.quality1) or 0
                    -- local _attr = aid - 100
                    -- local pro = 1
                    -- if tab.attClient[aid] == 1 then
                    --     pro = 0.01
                    -- end
                    -- heroAttr[_attr] = heroAttr[_attr] + value*pro
                    -- aid = tonumber(chartsD.quality_type2) or 0
                    -- value = tonumber(chartsD.quality2) or 0
                    -- _attr = aid - 100
                    -- pro = 1
                    -- if tab.attClient[aid] == 1 then
                    --     pro = 0.01
                    -- end
                    -- heroAttr[_attr] = heroAttr[_attr] + value*pro
                    if chartsD.heromasteryid then
                        starChartsMasterys[#starChartsMasterys+1] = {tonumber(chartsD.heromasteryid),1}
                    end
                end
            end
        end
    end

    -- 怪兽技能追加 -- [飞行][兵种][体型]
    local monsterSkill = {{{{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}}, {{{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}}}
    -- 怪兽技能追加 -- label1
    local monsterSkill1 = {}
    -- 怪兽技能追加 -- 全局
    local monsterSkill2 = {}
    -- 怪兽技能追加 -- ID
    local monsterSkill3 = {}
    -- 怪兽技能追加 -- 条件
    local monsterSkill4 = {}
    -- 怪兽技能追加 -- 召唤物
    local monsterSkill5 = {}

    -- 召唤物逻辑
    local summonDie_RecMana = 0
    local summonDie_DecCd = 0
    local summonCount_ApPro = 0

    -- 被动技能
    if level < BattleUtils.ENABLE_MASTERY_LEVEL then
        masterys = {}
    end
    local masterysArray = BattleUtils.getHeroMasterys(heroD, star, masterys, globalMasterys, treasureMasterys, uMastery, skillex,starChartsMasterys)

    local masteryD
    local oid, nid
    local morale, creplace, breplace, buffopen
    local addattrs, addattr, value, attrid
    local apprange0, apprange1, apprange2, apprange3, apprange4, tagaddsk
    local _lv, count
    local _level,_stage -- alter by caijunjie for mastery
    local detailsAttrTab = {heroAttr_special, heroAttr_treasure, heroAttr_mastery, heroAttr_skillBook}
    local detailAttrKind
    local oid, nid
    local mastery
    -- print("==========================\n")

    -- 法术额外逻辑
    local skillExLogic = {}
    for i = 1, #masterysArray do
        mastery = masterysArray[i]
        masteryD = tab.heroMastery[mastery[1]]
        if masteryD["skapprange0"] then
            skillExLogic[#skillExLogic + 1] = mastery[1]
        end
        detailAttrKind = mastery[3]
        _lv = mastery[2]
        _stage = mastery[2]
        if slevel[i] then
            _level = slevel[i]
        else
            _level = (skillex and skillex[3] or 1)
        end
      
        -- 倍数, 全局专长用的倍数  英雄全局专精用服务器来的数据倍数，其余都是一倍
        count = mastery[4]
        -- print(mastery[1], count)
        -- 怪兽替换
        creplace = masteryD["creplace"]
        if creplace then
            if masteryD["crehero"] == nil or masteryD["crehero"] == heroD["id"] then
                for k = 1, #creplace do
                    oid = creplace[k][1]
                    nid = creplace[k][2]
                    -- A->B B->C
                    -- 如果A已经变成B, 后面对A的变化均无效
                    for id1, id2 in pairs(teamReplace) do
                        if id2 == oid then
                            teamReplace[id1] = nid
                        end
                    end
                    if teamReplace[oid] == nil then
                        teamReplace[oid] = nid
                    end
                end
            end
        end

        -- A->B, A->C
        -- buff替换
        breplace = masteryD["breplace"]
        if breplace then
            for k = 1, #breplace do
                buffReplace[breplace[k][1]] = breplace[k][2]
            end
        end

        -- buff隐藏列
        buffopen = masteryD["buffopen"]
        if buffopen then
            for k = 1, #buffopen do
                local bid = buffopen[k][1]
                if buffOpen[bid] == nil then
                    buffOpen[bid] = {false, false, false}
                end
                buffOpen[bid][buffopen[k][2]] = true
            end
        end
        -- A->B, A->C
        -- 技能替换
        if masteryD["skreplace"] then
            for i = 1, #masteryD["skreplace"] do
                skillReplace[masteryD["skreplace"][i][1]] = masteryD["skreplace"][i][2]
            end
        end
        -- 英雄技能追加
        if masteryD["addsk"] and #heroSkills < 7 then
            table.insert(heroSkills, masteryD["addsk"])
        end

        -- 英雄属性加成
        if masteryD["morale"] then
            morale = masteryD["morale"]
            -- 替代公式信息
            local formula = masteryD["formula"] or {}
            for k = 1, #morale do
                _attr = morale[k][1] - 100
                _value = BattleUtils.useFormulaCalculate(morale[k], formula[k], _level, _lv) * count
                heroAttr[_attr] = heroAttr[_attr] + _value
                detailsAttrTab[detailAttrKind][_attr] = detailsAttrTab[detailAttrKind][_attr] + _value
            end
        end
        -- 降低别人属性
        if masteryD["morale1"] then
            morale = masteryD["morale1"]
            -- 替代公式信息
            local formula = masteryD["formula"] or {}
            local _bookLevel = skillex and skillex[3] or 1
            for k = 1, #morale do
                _attr = morale[k][1] - 100
                _value = BattleUtils.useFormulaCalculate(morale[k], formula[k], _level, _lv) * count
                heroAttrDec[_attr] = heroAttrDec[_attr] + _value
            end
        end      

        -- 怪兽
        addattrs = masteryD["addattr"]
        tagaddsk = masteryD["tagaddsk"]
        apprange0 = masteryD["apprange0"]
        apprange1 = masteryD["apprange1"]
        apprange2 = masteryD["apprange2"] 
        apprange3 = masteryD["apprange3"]
        if apprange1 and apprange2 and apprange0 then
            if addattrs then
                for k = 1, #addattrs do
                    addattr = addattrs[k]
                    attrid = addattr[1] --buff编号
                    value = (addattr[2] + addattr[3] * (_lv - 1)) * count
                    for m = 1, 5 do
                        -- 兵种类型
                        if apprange1[m] == 1 then
                            for n = 1, 2 do
                                -- 兵种移动方式：地面或者飞行
                                if apprange2[n] == 1 then
                                    for l = 1, 4 do
                                        -- 适用单位：16 9 4 1
                                        if apprange0[l] == 1 then
                                            monsterAttr[n][m][l][attrid] = monsterAttr[n][m][l][attrid] + value
                                        end
                                    end
                                end
                            end 
                        end
                    end
                end
            end
            -- 兵团额外增加技能：在BC.initTeamSkill中会添加
            if tagaddsk then
                for k = 1, #tagaddsk do
                    for m = 1, 5 do
                        -- 兵种类型
                        if apprange1[m] == 1 then
                            for n = 1, 2 do
                                -- 兵种移动方式：地面或者飞行
                                if apprange2[n] == 1 then
                                    for l = 1, 4 do
                                        -- 适用单位：16 9 4 1
                                        if apprange0[l] == 1 then
                                            -- tagaddsk[k][1] 技能ID
                                            -- tagaddsk[k][2] 技能类型
                                            monsterSkill[n][m][l][tagaddsk[k][2]] = tagaddsk[k][1]
                                        end
                                    end
                                end
                            end 
                        end
                    end     
                end
            end
        elseif apprange3 then
            -- 针对于特殊标签 team表 label1列的属性加成
            if addattrs then
                for k = 1, #addattrs do
                    addattr = addattrs[k]
                    attrid = addattr[1]
                    value = addattr[2] + addattr[3] * (_lv - 1)
                    for m = 1, #apprange3 do
                        local label1 = apprange3[m]
                        if monsterAttr1[label1] == nil then
                            monsterAttr1[label1] = {}
                            for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
                                monsterAttr1[label1][n] = 0
                            end
                        end
                        monsterAttr1[label1][attrid] = monsterAttr1[label1][attrid] + value
                    end
                end
            end
            -- 兵团额外增加技能：在BC.initTeamSkill中会添加
            if tagaddsk then
                for k = 1, #tagaddsk do
                    for m = 1, #apprange3 do
                        --[[ apprange3[m]
                                1.骷髅
                                2.平原城堡
                                3.森林壁垒
                                4.树人
                                5.据点
                                7.地下城
                                10.墓园除骷髅之外兵团
                                不填代表不做筛选
                        ]]
                        local label1 = apprange3[m] 
                        if monsterSkill1[label1] == nil then
                            monsterSkill1[label1] = {}
                        end
                        -- tagaddsk[k][1] 技能ID
                        -- tagaddsk[k][2] 技能类型
                        monsterSkill1[label1][tagaddsk[k][2]] = tagaddsk[k][1]
                    end
                end
            end
        elseif apprange4 and apprange4 == 1 then
            if addattrs then
                for k = 1, #addattrs do
                    addattr = addattrs[k]
                    attrid = addattr[1]
                    value = addattr[2] + addattr[3] * (_lv - 1)
                    monsterAttr3[attrid] = monsterAttr3[attrid] + value
                end
            end
            -- 召唤物技能添加
            if tagaddsk then
                for k = 1, #tagaddsk do
                    monsterSkill5[tagaddsk[k][2]] = tagaddsk[k][1]
                end
            end
        else
            if addattrs then
                for k = 1, #addattrs do
                    addattr = addattrs[k]
                    attrid = addattr[1]
                    value = addattr[2] + addattr[3] * (_lv - 1)
                    monsterAttr2[attrid] = monsterAttr2[attrid] + value
                end
            end

            -- 怪兽全局技能
            if tagaddsk then
                for k = 1, #tagaddsk do
                    monsterSkill2[tagaddsk[k][2]] = tagaddsk[k][1]
                end
            end
        end

        -- 怪兽技能追加 -- 直接加到特定兵团ID的技能
        local cradsk = masteryD["cradsk"]
        if cradsk then
            for k = 1, #cradsk do
                if monsterSkill3[cradsk[k][1]] == nil then
                    monsterSkill3[cradsk[k][1]] = {}
                end
                --cradsk[k][1] 兵团ID
                --cradsk[k][2] 技能类型
                --cradsk[k][3] 技能ID
                monsterSkill3[cradsk[k][1]][cradsk[k][3]] = cradsk[k][2]
            end
        end
        -- 怪兽技能追加 -- 前置条件
        local suradsk = masteryD["suradsk"]
        if suradsk then
            local surlim = masteryD["surlim"]
            if surlim == nil or type(surlim) ~= "table" then
                monsterSkill2[suradsk[2]] = suradsk[1]
            else
                monsterSkill4[suradsk[2]] = {surlim[1], surlim[2], suradsk[1]}
            end
        end

        -- 召唤物相关逻辑
        local sdrm = masteryD["sdrm"]
        if sdrm then
            summonDie_RecMana = summonDie_RecMana + sdrm
        end
        local sddcd = masteryD["sddcd"]
        if sddcd then
            summonDie_DecCd = summonDie_DecCd + sddcd
        end
        local scappro = masteryD["scappro"]
        if scappro then
            summonCount_ApPro = summonCount_ApPro + scappro
        end
    end
    local _attr, _value
    if talent then
        local seriesD, talentD, level, lv, attr1, attr2
        for _series, data in pairs(talent) do
            if type(data) == "table" then
                level = data.l
                if level and level > 0 then
                    seriesD = tab.magicSeries[tonumber(_series)]
                    -- 专精加属性
                    attr1 = seriesD["attr1"]
                    if attr1 then
                        if attr1 > 100 then
                            _attr = attr1 - 100
                            _value = seriesD["attr1value"][level]
                            heroAttr[_attr] = heroAttr[_attr] + _value
                            heroAttr_talent[_attr] = heroAttr_talent[_attr] + _value
                        else
                            monsterAttr2[attr1] = monsterAttr2[attr1] + seriesD["attr1value"][level]
                        end
                    end
                    attr2 = seriesD["attr2"]
                    if attr2 then
                        if attr2 > 100 then
                            heroAttrDec[attr2 - 100] = heroAttrDec[attr2 - 100] + seriesD["attr2value"][level]
                        end
                    end
                end
                for _talent, v in pairs(data.cl) do
                    lv = v.l
                    if lv and lv > 0 then
                        talentD = tab.magicTalent[tonumber(_talent)]
                        -- 天赋加属性
                        attr1 = talentD["attr1"]
                        if attr1 then
                            if attr1 > 100 then
                                _attr = attr1 - 100
                                _value = talentD["attr1value"][lv]
                                heroAttr[_attr] = heroAttr[_attr] + _value
                                heroAttr_talent[_attr] = heroAttr_talent[_attr] + _value
                            else
                                monsterAttr2[attr1] = monsterAttr2[attr1] + talentD["attr1value"][lv]
                            end
                        end
                        attr2 = talentD["attr2"]
                        if attr2 then
                            if attr2 > 100 then
                                heroAttrDec[attr2 - 100] = heroAttrDec[attr2 - 100] + talentD["attr2value"][lv]
                            end
                        end
                    end
                end
            end
        end
    end

    if buff then
        for attrid, value in pairs(buff) do
            local aid = tonumber(attrid)
            if aid > 100 then
                _attr = aid - 100
                heroAttr[_attr] = heroAttr[_attr] + value
                -- heroAttr_buff[_attr] = heroAttr_buff[_attr] + value
            else
                monsterAttr2[aid] = monsterAttr2[aid] + value
            end
        end
    end

    -- 攻城器械
    local weaponSkills = {}
    local attr, skillid, skilllevel

    for i = 1, 3 do
        if weapons and weapons[i] then
            attr, skillid, skilllevel = BattleUtils.getWeaponAttr(weapons[i])
            print("skillid: "..skillid, "skilllevel: "..skilllevel)
            weaponSkills[#weaponSkills + 1] = {skillid, skilllevel, skilllevel, -1, i}
        end
    end
    
    ---- 英雄属性计算 ----

    -- 基础属性
    local heroAtk = 0
    local heroDef = 0
    local heroInt = 0
    local heroAck = 0
    if hAb then
        if hAb["1"] then heroAtk = hAb["1"] end
        if hAb["2"] then heroDef = hAb["2"] end
        if hAb["3"] then heroInt = hAb["3"] end
        if hAb["4"] then heroAck = hAb["4"] end
    end
    -- if qhab then
    --     if qhab["110"] then heroAtk = qhab["110"] + heroAtk end
    --     if qhab["113"] then heroDef = qhab["113"] + heroDef end
    --     if qhab["116"] then heroInt = qhab["116"] + heroInt end
    --     if qhab["119"] then heroAck = qhab["119"] + heroAck end
    -- end
    heroAtk = (heroAtk + heroAttr[BattleUtils.HATTR_Atk]) * (100 + heroAttr[BattleUtils.HATTR_AtkPro]) * 0.01 + heroAttr[BattleUtils.HATTR_AtkAdd]
    heroDef = (heroDef + heroAttr[BattleUtils.HATTR_Def]) * (100 + heroAttr[BattleUtils.HATTR_DefPro]) * 0.01 + heroAttr[BattleUtils.HATTR_DefAdd]
    heroInt = (heroInt + heroAttr[BattleUtils.HATTR_Int]) * (100 + heroAttr[BattleUtils.HATTR_IntPro]) * 0.01 + heroAttr[BattleUtils.HATTR_IntAdd] 
    heroAck = (heroAck + heroAttr[BattleUtils.HATTR_Ack]) * (100 + heroAttr[BattleUtils.HATTR_AckPro]) * 0.01 + heroAttr[BattleUtils.HATTR_AckAdd]

    local heroShiQi = heroD["morale"] + heroAttr[BattleUtils.HATTR_Shiqi]

    -- 蓝相关
    local manaBase = isEnemyHero and manabase or heroD["manabase"]
    local manaRec = isEnemyHero and manarec or heroD["manarec"]
    local heroManaBase = ceil((manaBase + heroAttr[BattleUtils.HATTR_Mana]) * ((100 + heroAttr[BattleUtils.HATTR_ManaPro]) * 0.01))
    local heroManaMax = ceil(heroD["manamax"] + heroAttr[BattleUtils.HATTR_ManaMax])
    local heroManaRec = (manaRec + heroAttr[BattleUtils.HATTR_ManaRec]) * ((100 + heroAttr[BattleUtils.HATTR_ManaRecPro]) * 0.01)

    -- 固定法伤
    local heroApAdd = heroAttr[BattleUtils.HATTR_APAdd]

    -- 法术阻挡
    local heroHinder = heroAttr[BattleUtils.HATTR_Hinder]
    -- 护盾
    local heroShield = heroAttr[BattleUtils.HATTR_ShieldPro]

    local function _setAttr(_heroAttr, beginIdx, isPro, isSpell)
        local values = {{}, {}, {}, {}}
        local _beginIdx = beginIdx
        local k = 1
        if isPro then
            k = 0.01
        end
        for _kind = 1, 5 do
            values[4][_kind] = _heroAttr[_beginIdx] * k
            _beginIdx = _beginIdx + 1
        end
        if isSpell then
            return values
        end 
        for _type = 1, 3 do
            for _kind = 1, 5 do
                values[_type][_kind] = _heroAttr[_beginIdx] * k
                _beginIdx = _beginIdx + 1
            end
        end
        return values
    end

    -- 法伤
    local heroAp = _setAttr(heroAttr, BattleUtils.HATTR_APFire, true)
    local heroAp1 = _setAttr(heroAttr, BattleUtils.HATTR_AP1Fire1, true, true)

    -- cd
    local heroCd = _setAttr(heroAttr, BattleUtils.HATTR_CDProFire, true)
    local heroInitCd = _setAttr(heroAttr, BattleUtils.HATTR_InitCDProFire, true)

    -- 耗蓝
    local heroMCD = _setAttr(heroAttr, BattleUtils.HATTR_MCDFire, true)

    -- 范围
    local heroRI = _setAttr(heroAttr, BattleUtils.HATTR_RIFire)

    -- 效果翻倍
    local heroDE = _setAttr(heroAttr, BattleUtils.HATTR_DEFire)
    

    -- 法术等级提升, 直接在此处加好
    local heroLevelUp = _setAttr(heroAttr, BattleUtils.HATTR_LevelAddFire)

    -- 技能替换
    local id
    for i = 1, #heroSkills do
        id = heroSkills[i]
        if skillReplace[id] then
            heroSkills[i] = skillReplace[id]
        end
    end

    -- 技能等级
    local skillD, skillLevel, _type, _subtype, levelex, starChartsLvlex
    for i = 1, #heroSkills do
        if heroSkills[i] ~= 0 then
            skillD = tab.playerSkillEffect[heroSkills[i]]
            -- {技能ID, 总等级, 原始等级}
            skillLevel = slevel[i]
            if skillLevel == nil then
                skillLevel = 1
            end
            _type = skillD["type"] - 1
            levelex = 0
            if _type > 0 then
                _subtype = skillD["mgtype"]
                levelex = heroLevelUp[4][5] + heroLevelUp[4][_type] + heroLevelUp[_subtype][5] + heroLevelUp[_subtype][_type]
                skillLevel = skillLevel + levelex
            end
            starChartsLvlex = 0
            if starChartsLevelUp then
                starChartsLvlex = starChartsLevelUp[heroSkills[i]] or 0
                skillLevel = skillLevel + starChartsLvlex
            end
            heroSkills[i] = {heroSkills[i], skillLevel, skillLevel - levelex - starChartsLvlex, -1}
        else
            heroSkills[i] = {heroSkills[i]}
        end
    end
    -- 法术插槽-英雄法术
    if skillex then
        local _id = skillex[1]
        local skillBookBaseD = tab.skillBookBase[_id]
        if skillBookBaseD and skillBookBaseD["skillType"] == 1 then
            local _level = skillex[2]
            local _bookLevel = skillex[3]
            -- 英雄法术
            skillD = tab.playerSkillEffect[_id]
            _type = skillD["type"] - 1
            levelex = 0
            if _type > 0 then
                _subtype = skillD["mgtype"]
                levelex = heroLevelUp[4][5] + heroLevelUp[4][_type] + heroLevelUp[_subtype][5] + heroLevelUp[_subtype][_type]
            end
            starChartsLvlex = 0
            if starChartsLevelUp then
                starChartsLvlex = starChartsLevelUp[heroSkills[i]] or 0
                skillLevel = skillLevel + starChartsLvlex
            end
            heroSkills[#heroSkills + 1] = {_id, _level + levelex + starChartsLvlex, _level, tab.skillBookBase[_id]["frequency"][_bookLevel + 1]}
        end

        if skillBookBaseD and 4 == skillBookBaseD["type"] and 2 == skillBookBaseD["skillType"] then
            local _level = skillex[2]
            local _bookLevel = skillex[3]
            table.insert(skillBookPassive, {_id, _level, _bookLevel})
        end
    end

    -- 法术额外逻辑
    local masteryD, skillD
    table.sort(skillExLogic, function (a, b)
        return a < b
    end)
    local skapprange0, skapprange1, skapprange2, dazhao, index, skadd, heroSkills_index
    local effapprange, effadd1, effadd2, effpro, pipei, totemD

    -- 英雄专精表匹配筛选，附带技能
    for i = 1, #skillExLogic do
        masteryD = tab.heroMastery[skillExLogic[i]]
        skapprange0 = masteryD["skapprange0"]
        skapprange1 = masteryD["skapprange1"]
        skapprange2 = masteryD["skapprange2"]
        local skillList = {}
        -- 筛选匹配的技能，放到skillList中
        for k = 1, #heroSkills do
            skillD = tab.playerSkillEffect[heroSkills[k][1]]
            while skillD do
                if skapprange0 then
                    if skapprange0[skillD["type"] - 1] ~= 1 then
                        break
                    end
                end
                if skapprange1 then
                    if skapprange1[skillD["mgtype"]] ~= 1 then
                        break
                    end
                end
                if skapprange2 then
                    if skillD["dazhao"] == 1 then
                        dazhao = 2
                    else
                        dazhao = 1
                    end
                    if skapprange2[dazhao] ~= 1 then
                        break
                    end
                end
                -- skillList里存的是heroSkills的索引
                skillList[#skillList + 1] = k
                break
            end
        end
        -- 针对每一个匹配出的技能，增加额外技能
        skadd = masteryD["skadd"]
        if skadd then
            for k = 1, #skillList do
                index = skillList[k]
                heroSkills_index = heroSkills[index][6]
                for n = 1, #skadd do
                    if heroSkills_index == nil then
                        heroSkills[index][6] = {skadd[n]}
                    else
                        heroSkills_index[#heroSkills_index + 1] = skadd[n]
                    end
                end
            end
        end
        effapprange = masteryD["effapprange"]
        if effapprange then
            local exAction
            -- 附带行为
            effadd1 = masteryD["effadd1"]
            effadd2 = masteryD["effadd2"]
            effpro = masteryD["effpro"]
            if effadd1 and effadd2 then
                local skillDex
                -- skillAction 那边需要用到skillD中的参数，所以这里做一个假的
                if effadd1 == 1 then
                    -- 治疗 
                    skillDex = {valuepro1 = {effadd2[1], effadd2[2]}, valueadd = {effadd2[3], effadd2[4]}, maxhurt1 = {effadd2[5], effadd2[6]}}
                elseif effadd1 == 2 then
                    -- 伤害 
                    skillDex = {valuepro1 = {effadd2[1], effadd2[2]}, valueadd = {effadd2[3], effadd2[4]}, maxhurt1 = {effadd2[5], effadd2[6]}}
                elseif effadd1 == 3 then
                    -- 召唤
                    skillDex = {summon1 = effadd2[1], summonlevel1 = {effadd2[2], effadd2[3]}, summonnum1 = {effadd2[4], effadd2[5]}}
                elseif effadd1 == 4 then
                    -- 驱散
                    skillDex = {dispel1 = effadd2[1], dispellevel1 = effadd2[2]}
                end
                if skillDex then
                    exAction = {effadd1, skillDex}
                end
            end

            if effapprange == 1 then
                for k = 1, #skillList do
                    index = skillList[k]
                    skillD = tab.playerSkillEffect[heroSkills[index][1]]
                    pipei = skillD["damagekind1"] == effapprange or skillD["damagekind2"] == effapprange
                    if not pipei then
                        if skillD["objectid"] then
                            totemD = tab.object[skillD["objectid"]]
                            pipei = totemD["damagekind1"] == effapprange or totemD["damagekind2"] == effapprange
                        end
                    end
                    if pipei then
                        -- 治疗加成%
                        heroSkills[index][7] = effpro
                        -- 治疗附带行为
                        local _skillDex = clone(exAction[2])
                        _skillDex["id"] = skillD["id"]
                        _skillDex["type"] = skillD["type"]
                        _skillDex["dieart"] = skillD["dieart"]
                        if skillD["damagekind1"] == effapprange then
                            _skillDex["hurtkind1"] = skillD["hurtkind1"]
                        else
                            _skillDex["hurtkind1"] = skillD["hurtkind2"] 
                        end
                        exAction[2] = _skillDex
                        heroSkills[index][9] = exAction
                    end
                end
            elseif effapprange == 2 then
                for k = 1, #skillList do
                    index = skillList[k]
                    skillD = tab.playerSkillEffect[heroSkills[index][1]]
                    pipei = skillD["damagekind1"] == effapprange or skillD["damagekind2"] == effapprange
                    if not pipei then
                        if skillD["objectid"] then
                            totemD = tab.object[skillD["objectid"]]
                            pipei = totemD["damagekind1"] == effapprange or totemD["damagekind2"] == effapprange
                        end
                    end
                    if pipei then
                        -- 伤害加成%
                        heroSkills[index][8] = effpro
                        -- 伤害附带行为
                        local _skillDex = clone(exAction[2])
                        _skillDex["id"] = skillD["id"]
                        _skillDex["type"] = skillD["type"]
                        _skillDex["dieart"] = skillD["dieart"]
                        if skillD["damagekind1"] == effapprange then
                            _skillDex["hurtkind1"] = skillD["hurtkind1"]
                        else
                            _skillDex["hurtkind1"] = skillD["hurtkind2"] 
                        end
                        exAction[2] = _skillDex
                        heroSkills[index][10] = exAction
                    end
                end 
            end
        end
    end
    --[[
            heroSkills
            {
                1 = 法术ID,
                2 = 等级，
                3 = 原始等级，
                4 = 释放次数,
                5 = 器械index,
                6 = 额外技能,
                7 = 治疗加成%
                8 = 伤害加成%
                9 = 治疗附带行为
                10 = 伤害附带行为
            }
    ]]
    -- dump(heroSkills, "a", 20)
    -- 学院中级大招几率
    local MGTriggerPro = {
    heroAttr[BattleUtils.HATTR_MGTriggerPro1], 
    heroAttr[BattleUtils.HATTR_MGTriggerPro2], 
    heroAttr[BattleUtils.HATTR_MGTriggerPro3], 
    heroAttr[BattleUtils.HATTR_MGTriggerPro4]}

    -- 不同来源英雄属性
    local heroAttrEx_special = {}
    local heroAttrEx_treasure = {}
    local heroAttrEx_mastery = {}
    local heroAttrEx_talent = {}
    local heroAttrEx_skillBook = {}
    local heroAttrEx_buff = {}

    local function setAttrEx(attrex, attr)
        attrex.cd = _setAttr(attr, BattleUtils.HATTR_CDProFire, true)
        attrex.initCd = _setAttr(attr, BattleUtils.HATTR_InitCDProFire, true)
        attrex.MCD = _setAttr(attr, BattleUtils.HATTR_MCDFire, true)
    end
    setAttrEx(heroAttrEx_special, heroAttr_special)
    setAttrEx(heroAttrEx_treasure, heroAttr_treasure)
    setAttrEx(heroAttrEx_mastery, heroAttr_mastery)
    setAttrEx(heroAttrEx_talent, heroAttr_talent)
    setAttrEx(heroAttrEx_skillBook, heroAttr_skillBook)

    -- setAttrEx(heroAttrEx_buff, heroAttr_buff)
    -- dump(MGTriggerPro)
    local ret =
    {
        attrInc = heroAttr,
        attrDec = heroAttrDec,

        atk = heroAtk,
        def = heroDef, 
        int = heroInt, 
        ack = heroAck, 
        shiQi = heroShiQi, 
        ap = heroAp, 
        ap1 = heroAp1,
        apAdd = heroApAdd,
        isEnemyHero = isEnemyHero,
        manaBase = heroManaBase, 
        manaMax = heroManaMax, 
        manaRec = heroManaRec, 
        shield = heroShield,
        cd = heroCd,
        initCd = heroInitCd,
        MCD = heroMCD,
        RI = heroRI,
        DE = heroDE,
        hinder = heroHinder,
        MGTPro = MGTriggerPro,

        revivePro = revivePro,
        reviveBuff = reviveBuff,
        allReviveBuff = allReviveBuff,
        skills = heroSkills,
        openSkills = openSkills,
        autoSkills = autoSkills,
        weaponSkills = weaponSkills,
        skillBookPassive = skillBookPassive,
        monsterAttr = monsterAttr,
        monsterAttr1 = monsterAttr1,
        monsterAttr2 = monsterAttr2,
        monsterAttr3 = monsterAttr3,
        monsterAttr4 = monsterAttr4,
        teamReplace = teamReplace,
        buffReplace = buffReplace,
        buffOpen = buffOpen,
        monsterSkill = monsterSkill,
        monsterSkill1 = monsterSkill1,
        monsterSkill2 = monsterSkill2,
        monsterSkill3 = monsterSkill3,
        monsterSkill4 = monsterSkill4,
        monsterSkill5 = monsterSkill5,

        summonDie_RecMana = summonDie_RecMana,
        summonDie_DecCd = summonDie_DecCd * 0.001,
        summonCount_ApPro = summonCount_ApPro,

        treasureEff = treasureEff,

        heroAttr_special = heroAttr_special,
        heroAttr_treasure = heroAttr_treasure,
        heroAttr_mastery = heroAttr_mastery,
        heroAttr_talent = heroAttr_talent,
        heroAttr_skillBook = heroAttr_skillBook,
        -- heroAttr_buff = heroAttr_buff,

        heroAttrEx_special = heroAttrEx_special,
        heroAttrEx_treasure = heroAttrEx_treasure,
        heroAttrEx_mastery = heroAttrEx_mastery,
        heroAttrEx_talent = heroAttrEx_talent,
        heroAttrEx_skillBook = heroAttrEx_skillBook,
        -- heroAttrEx_buff = heroAttrEx_buff,

        skillReplace = skillReplace
    }
    return ret
end

-- _subtype 1: 伤害,  2: 辅助,  3: 召唤
-- _type 火水气土全
function BattleUtils.getAttrValue(attrId, _subtype, attributeValues)
    local values
    local _type = 0
    if attrId >= 122 and attrId <= 126 then
        -- 效果翻倍
        _type = attrId - 121
        values = attributeValues.DE
    elseif attrId >= 22 and attrId <= 26 then
        -- 法术伤害
        _type = attrId - 21
        values = attributeValues.ap
    elseif attrId >= 27 and attrId <= 31 then
        -- 法术伤害
        _type = attrId - 26
        values = attributeValues.ap1
    elseif attrId >= 32 and attrId <= 36 then
        -- 辅助伤害
        _type = attrId - 31
        values = attributeValues.ap2
    else
        return 0
    end
    if values then
        if _subtype >= 1 and _subtype <= 3 then
            if _type <= 4 then
                return values[4][5] + values[4][_type] + values[_subtype][5] + values[_subtype][_type]
            else
                return values[4][5] + values[_subtype][5]
            end
        else
            if _type <= 4 then
                return values[4][5] + values[4][_type]
            else
                return values[4][5]
            end
        end
    end
    return 0
end

-- 获取宝物对怪兽的加成
function BattleUtils.getTeamBaseAttr_treasure(treasure)
    -- 怪兽属性追加 -- 全局
    -- 16 9 4 1
    local monsterAttr1 = {{}, {}, {}, {}}
    for i = 1, 4 do
        for m = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
            monsterAttr1[i][m] = 0
        end
    end
    local monsterAttr2 = {}
    for m = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        monsterAttr2[m] = 0
    end
    -- 宝物, 附加属性 有怪兽属性和英雄属性
    local disTreasureD, t_attr
    local _attr, _value
    local _unlockaddattr, _addattrs, _addattr, _addattr1, _addattr2, _addattr3
    if treasure then
        for id, com in pairs(treasure) do
            for did, disInfo in pairs(com.treasureDev) do
                local lv = disInfo and disInfo.s or 0
                if lv > 0 then
                    local comTreasureStarIdx = (disInfo.bs or 0) * 8 + (disInfo.ss or 0) + math.floor((disInfo.b or 0)/100)
                    local pro
                    if comTreasureStarIdx > 0 then
                        pro = 1 + tab.comTreasureStar[comTreasureStarIdx]["attrprosum"] * 0.01
                    else
                        pro = 1
                    end
                    -- 散件附加属性
                    disTreasureD = tab.disTreasure[tonumber(did)]
                    if disTreasureD then
                        for i = 1, 6 do
                            t_attr = disTreasureD["property"][i]
                            if t_attr then
                                if t_attr[1] > 100 then

                                else
                                    monsterAttr2[t_attr[1]] = monsterAttr2[t_attr[1]] + (t_attr[2] + t_attr[3] * (lv - 1)) * pro
                                end
                            else
                                break
                            end
                        end
                        -- 解锁体型属性
                        _unlockaddattr = disTreasureD["unlockaddattr"]
                        _addattrs = disTreasureD["addattr"]
                        for i = 1, #_unlockaddattr do
                            if lv >= _unlockaddattr[i] then
                                _addattr = _addattrs[i]
                                _addattr1 = _addattr[1] -- 体型
                                _addattr2 = _addattr[2] -- 属性
                                _addattr3 = _addattr[3] -- 值
                                monsterAttr1[_addattr1 - 1][_addattr2] = monsterAttr1[_addattr1 - 1][_addattr2] + _addattr3
                            else
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    for i = 1, 4 do
        for m = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
            monsterAttr1[i][m] = monsterAttr1[i][m] + monsterAttr2[m]
        end 
    end
    return monsterAttr1
end

-- 获取图鉴对怪兽的
function BattleUtils.getTeamBaseAttr_pokedex(teamData, pokedex)
    local teamid = teamData.teamid or teamData.teamId
    local baseAttr = {}
    for i = 1, BattleUtils.ATTR_COUNT do
        baseAttr[i] = 0
    end

    local teamD = tab.team[teamid]

    if pokedex and pokedex[1] ~= false then
        local addValue = pokedex[classIdxTable[teamD["class"]]] or 0
        local idx = raceIdxTable[teamD["race"][1] - 100]
        if pokedex[idx] then
            addValue = addValue + pokedex[idx]
        end
        addValue = addValue * 0.006
        baseAttr[BattleUtils.ATTR_AtkPro] = baseAttr[BattleUtils.ATTR_AtkPro] + addValue
        baseAttr[BattleUtils.ATTR_HPPro] = baseAttr[BattleUtils.ATTR_HPPro] + addValue
    end
    return baseAttr
end

--[[
--! @function getEquipArr
--! @desc 获取基础属性公式计算结果
--! @param inSysEquip object 系统装备表数据
--! @param inStage int 阶
--! @param inLevel int 当前装备等级
--! @return tempResult int 计算属性结果
--! @return tempType int 属性类型
--]]
function BattleUtils.getEquipAttr(inSysEquip, inStage, inLevel)
    local tempType =  inSysEquip["attr"]
    local tempValume = inSysEquip["num"][inStage]
    if tempType ~= nil  then
        local tempResult
        -- if tempType == ATTR_Def or tempType == ATTR_Pen then
        --     tempResult = tempValume * inLevel
        -- else
        tempResult = tempValume * (inLevel + 9)
        -- end
        return tempResult
    end
    return 0,0
end

--[[
--! @function getEquipArr
--! @desc 获取基础属性公式计算结果
--! @param inSysEquip object 系统装备表数据
--! @param inStage int 阶
--! @param inLevel int 当前装备等级
--! @return tempResult int 计算属性结果
--! @return tempType int 属性类型
--]]
function BattleUtils.getEquipAttr1(inSysEquip, inStage, inLevel)
    local tempType =  inSysEquip["attr1"]
    local tempValume = inSysEquip["num1"][inStage]
    if tempType ~= nil  then
        local tempResult
        tempResult = tempValume * (inLevel + 9)
        return tempResult
    end
    return 0,0
end

function BattleUtils.getPlayerLevel()
    local userModel = ModelManager:getInstance():getModel("UserModel")
    local level = userModel:getData().lvl
    if level == nil then
        level = 1
    end
    return level
end

-- 计算攻城器械的属性
-- attr是[力,敏,智]
-- skillid
-- skilllevel
BattleUtils.G_WEAPON_SP_LEVEL_UNLOCK = {5,10,15,20,25,30}
local G_WEAPON_SP_LEVEL_UNLOCK = BattleUtils.G_WEAPON_SP_LEVEL_UNLOCK
function BattleUtils.getWeaponAttr(data)
    local attr = {0, 0, 0}
    local attrPro = {0, 0, 0}
    local siegeWeaponD = tab.siegeWeapon[data.id]
    local lv = data.lv
    local intproperty = siegeWeaponD["intproperty"]
    attr[1] = attr[1] + intproperty[1][2] + (lv - 1) * intproperty[1][3]
    attr[2] = attr[2] + intproperty[2][2] + (lv - 1) * intproperty[2][3]
    attr[3] = attr[3] + intproperty[3][2] + (lv - 1) * intproperty[3][3]

    -- 配件
    local sp, siegeEquipD, _intproperty, attrid, _lv, _intpropertyk
    for i = 1, 4 do
        sp = data["sp"..i]
        if sp and sp.id then
            siegeEquipD = tab.siegeEquip[sp.id]
            _lv = sp.lv
            _intproperty = siegeEquipD["intproperty"]
            for k = 1, #_intproperty do
                _intpropertyk = _intproperty[k]
                attrid = _intpropertyk[1]
                attr[attrid] = attr[attrid] + _intpropertyk[2] + (_lv - 1) * _intpropertyk[3]
            end
            local value
            for i = 1, #G_WEAPON_SP_LEVEL_UNLOCK do
                if _lv >= G_WEAPON_SP_LEVEL_UNLOCK[i] then
                    value = siegeEquipD["percent"..i]
                    if value then
                        attrPro[value[1]] = attrPro[value[1]] + value[2]
                    else
                        break
                    end
                else
                    break
                end
            end
        end
    end
    dump(attr, "attrBefore")
    local k = data.k or 1
    for i = 1, 3 do
        attr[i] = (attr[i] * (1 + attrPro[i] * 0.01) * k)
    end
    local siegelv = siegeWeaponD["siegelv"]
    if siegelv then
        local skillid
        if data.ss2 and data.ss2 == 1 then
            skillid = siegeWeaponD["skill3"]
        elseif data.ss1 and data.ss1 == 1 then
            skillid = siegeWeaponD["skill2"]
        else
            skillid = siegeWeaponD["skill1"]
        end
        dump(attrPro, "attrPro")
        dump(attr, "attrAfter")
        dump(siegelv, "siegelv")
        local skilllevel = ceil(attr[1] * siegelv[1] + attr[2] * siegelv[2] + attr[3] * siegelv[3])
        return attr, skillid, skilllevel
    else
        return attr, 0, 0
    end
end

function BattleUtils.doBattle(battleInfo, fastRes, noLoading, switch)
    if BattleUtils.USE_WEAPONS[battleInfo.mode] == nil and BattleUtils.USE_SUNWEAPONS[battleInfo.subType] == nil then
        -- 去除攻城器械
        local len = 4
        -- 4号位置，只在 BATTLE_TYPE_Siege_Def  中使用
        if battleInfo.mode == BattleUtils.BATTLE_TYPE_Siege_Def then
            len = 3
        end
        if battleInfo.playerInfo.weapons then
            for i = 1, len do
                battleInfo.playerInfo.weapons[i] = nil
            end
        end
        if battleInfo.enemyInfo.weapons then
            for i = 1, len do
                battleInfo.enemyInfo.weapons[i] = nil
            end
        end
    else
        if BattleUtils.SUPER_WEAPONS[battleInfo.mode] ~= nil then
            if battleInfo.playerInfo.weapons then
                for i = 1, 2 do
                    if battleInfo.playerInfo.weapons[i] then
                        battleInfo.playerInfo.weapons[i].k = 2
                    end
                end
            end   
        end
    end
    -- dump(battleInfo.playerInfo, "a", 20)
    pcall(function ()
        local bi = {}
        for k, v in pairs(battleInfo) do
            if type(v) ~= "function" then
                bi[k] = v
            end
        end
        pcall(function ()
            bi.version = tab.battleVer[1]["ver"]
            bi.luaver = kakura.Config:getInstance():getValue("APP_BUILD_NUM")
        end)
        BattleUtils.BattleString = cjson.encode(bi)
    end)
    if fupanStr then
        local list = string.split(fupanStr, "::")
        battleInfo = cjson.decode(list[1])
        battleInfo.playerInfo.skillList = cjson.decode(list[2])
    end
    -- 根据布阵位置, 进行排序
    -- 检查数据
    if OS_IS_WINDOWS then
        -- 这里现在用于检查服务器数据的一致性, 不再用于防止战前数据被修改
        if not BattleUtils.dontCheck then
            -- 检查兵团数据
            local teamModel = ModelManager:getInstance():getModel("TeamModel")
            local teams = battleInfo.playerInfo.team
            local value1, value2
            local _team
            for i = 1, #teams do
                if not teams[i].isMercenary then
                    _team = teamModel:getTeamAndIndexById(teams[i]["id"])
                    if _team then
                        value1 = BattleUtils.checkTeamData(teams[i], true)
                        value2 = _team.onCheck
                        if value1 ~= value2 then
                            ViewManager:getInstance():showTip("战前数据出错_兵团")
                            ViewManager:getInstance():onLuaError(serialize(teams[i]).."==="..serialize(_team))
                            break
                        end
                    end
                end
            end

            -- 检查图鉴
            local pokedexModel = ModelManager:getInstance():getModel("PokedexModel")
            local value1 = pokedexModel:getCheckScore()
            local value2 = BattleUtils.checkPokedexScoreData(battleInfo.playerInfo.pokedex)
            if value1 ~= value2 then
                ViewManager:getInstance():showTip("战前数据出错_图鉴")
                ViewManager:getInstance():onLuaError(serialize(battleInfo.playerInfo.pokedex).."==="..serialize(pokedexModel:getScore()))
            end

            -- 检查英雄
            if battleInfo.mode ~= BattleUtils.BATTLE_TYPE_League then
                local heroModel = ModelManager:getInstance():getModel("HeroModel")
                local hero = heroModel:getHeroData(battleInfo.playerInfo.hero.id)
                if hero then
                    local value1 = heroModel:getHeroData(battleInfo.playerInfo.hero.id).heroCheck
                    local value2 = BattleUtils.checkHeroData(battleInfo.playerInfo.hero, true)
                    if value1 ~= value2 then
                        ViewManager:getInstance():showTip("战前数据出错_英雄")
                        ViewManager:getInstance():onLuaError(serialize(battleInfo.playerInfo.hero).."==="..serialize(heroModel:getHeroData(battleInfo.playerInfo.hero.id)))
                    end
                end
            end

            -- 检查宝物数据
            local treasureModel = ModelManager:getInstance():getModel("TreasureModel")
            local value1 = treasureModel:getCheckValue()
            local value2 = BattleUtils.checkTreasureData(battleInfo.playerInfo.treasure)
            if value1 ~= value2 then
                ViewManager:getInstance():showTip("战前数据出错_宝物")
                ViewManager:getInstance():onLuaError(serialize(battleInfo.playerInfo.treasure).."==="..serialize(treasureModel:getData()))
            end
        end
    end
    if not BattleUtils.dontCheck and GameStatic.checkZuoBi_3 then
        print("检查Model数据")
        local checkModelTab = {"TeamModel", "HeroModel", "PokedexModel", "TreasureModel"}
        for i = 1, #checkModelTab do
            local modelName = checkModelTab[i]
            local res = ModelManager:getInstance():getModel(modelName):checkData()
            if res ~= nil then
                if OS_IS_WINDOWS then
                    if ViewManager then ViewManager:getInstance():onLuaError(modelName .. "被修改: "..serialize(res)) end
                else
                    if ViewManager then ViewManager:getInstance():showTip("数据异常.03") end
                    ApiUtils.playcrab_lua_error(modelName .. "_xiugai", serialize(res))
                    if GameStatic.kickZuoBi_3 then
                        do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                    end
                end   
            end
        end
    end

    -- 法术插槽解锁
    if BattleUtils.unLockSkillHero[battleInfo.playerInfo.hero.id] then
        if battleInfo.playerInfo.hero.skillex then
            BattleUtils.unLockSkillHero[battleInfo.playerInfo.hero.id] = nil
            local id = battleInfo.playerInfo.hero.skillex[1]
            local skillBookBaseD = tab.skillBookBase[id]
            if skillBookBaseD then
                if 4 == skillBookBaseD["type"] then
                    BattleUtils.unLockSkillIndex = 7
                else
                    BattleUtils.unLockSkillIndex = 6
                end
            end
        end
    end

    -- 针对战报特殊处理
    if battleInfo.isReport or battleInfo.isShare then
        -- 当前配置和代码的战斗版本号
        local battleVer = tab.battleVer[1]["ver"]
        local reportVer = battleInfo.playerInfo.ver
        if reportVer then
            print("ServerBattleVer:"..reportVer)
        end 
        print("ClientBattleVer:"..battleVer)
        -- 提示战报过期
        if battleVer ~= reportVer then 
            ViewManager:getInstance():showTip(lang("REPLAY_COMPARE"))
            return
        end
    end
    BattleUtils.CUR_BATTLE_TYPE = battleInfo.mode
    BattleUtils.CUR_BATTLE_SUB_TYPE = battleInfo.subType
    BattleUtils.isReport = battleInfo.isReport
    -- 等级
    if not BATTLE_PROC and battleInfo.playerInfo.lv == nil then
        battleInfo.playerInfo.lv = BattleUtils.getPlayerLevel()
    end
    -- 新逻辑 玩家英雄有可能是npcHero
    battleInfo.playerInfo.hero.npcHero = (tab.hero[battleInfo.playerInfo.hero.id] == nil)
    -- 安全日志
    if not BATTLE_PROC then
        if GameStatic.useSR then
            if BattleUtils.SRData == nil then
                BattleUtils.initSRData()
            end
            BattleUtils.clearSRData()
            BattleUtils.beginSRData()
        else
            BattleUtils.disableSRData()
        end
    end
    if BattleUtils.DEBUG_FAST_BATTLE == 1 then fastRes = true end -- debug
    if fastRes then
        local isServerProc = BATTLE_PROC
        BATTLE_PROC = true
        if not isServerProc then 
            BATTLE_PROC = true
            BattleUtils.clearBattleRequire() 
        end
        local srdata = BattleUtils.SRData
        BattleUtils.SRData = nil
        local resData, resString, res = BattleUtils.procBattle(battleInfo)
        BattleUtils.SRData = srdata
        if not isServerProc then 
            BattleUtils.clearBattleRequire()
            audioMgr = AudioManager:getInstance()
            BATTLE_PROC = false
        end
        print(resString)
        dump(resData)
        return resData, resString, res
    else
        if switch then
            ViewManager:getInstance():switchView("battle.BattleView", {battleInfo = battleInfo, noLoading = noLoading, nounloadRes = true, dontCheck = BattleUtils.dontCheck})
        else
            ViewManager:getInstance():showView("battle.BattleView", {battleInfo = battleInfo, noLoading = noLoading, dontCheck = BattleUtils.dontCheck})
        end
    end
end
-- 进入副本战斗
function BattleUtils.enterBattleView_Fuben(playerInfo, intanceId, isReplay, resultcallback, endcallback, fastRes)
    local intanceD = tab.mainStage[intanceId]
    if intanceD == nil then
        return BattleUtils.enterBattleView_FubenBranch(playerInfo, intanceId, isReplay, resultcallback, endcallback, fastRes)
    end
    local monster
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = intanceD["hero"], 
                                }
                        }
    for i = 1, 8 do
        monster = intanceD["m"..i]
        if monster == nil then
            break
        end
        enemyInfo.npc[i] = monster
    end

    -- 判断此关卡是否已经通过
    local isPass = false
    local isElite = false
    if not BATTLE_PROC then
        local modelMgr = ModelManager:getInstance()
        if modelMgr:getModel("UserModel"):getPlayerLevel() then
            if math.mod(floor(intanceId/100000), 10) == 1 then
                local stage = modelMgr:getModel("IntanceModel"):getStageInfo(intanceId)
                if stage.star > 0 then 
                    isPass = true
                end
            else
                isElite = true
                local stage = modelMgr:getModel("IntanceEliteModel"):getStageInfo(intanceId)
                if stage.star > 0 then 
                    isPass = true
                end
            end
        end
    end

    local showNpc = {intanceD["showNpc"], intanceD["showDes"]}
    if intanceD["showNpc"] == nil or isPass then
        showNpc = nil
    end

    local assist = intanceD["helpCondition"] ~= nil and not isPass

    if intanceD["siegeid"] then
        -- 攻城战
        local siege = intanceD["siegeid"]
        return BattleUtils.enterBattleView_Siege(playerInfo, enemyInfo, intanceD, isReplay, false, assist, showNpc, 
            BattleUtils.BATTLE_TYPE_Fuben, intanceD["costPhysical"], intanceD["mapId"], siege[1], siege[2], siege[3], false, nil, resultcallback, endcallback, fastRes)
    end
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Fuben, playerInfo = playerInfo, enemyInfo = enemyInfo,
                        battleId = intanceId,
                        showNpc = showNpc,
                        intanceD = intanceD,
                        r1 = intanceId,
                        isReport = isReplay,
                        isElite = isElite,
                        assist = assist,
                        isPass = isPass,
                        mustWin = ((intanceId <= 7100202) and (not isPass)),
                        physical = intanceD["costPhysical"],
                        mapId = intanceD["mapId"], scaleMin = intanceD["scaleMin"], scaleMax = intanceD["scaleMax"],
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if intanceId <= 7100202 or isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if intanceId <= 7100202 or isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 进入跨服竞技场副本战斗
function BattleUtils.enterBattleView_ServerArenaFuben(playerInfo, enemyInfo, r1, r2 ,resultcallback, endcallback, fastRes)
    local battleInfo = { mode = BattleUtils.BATTLE_TYPE_ServerArenaFuben,
                         playerInfo = playerInfo, 
                         enemyInfo = enemyInfo,
                         mapId = "jingjichang1",
                         r1 = r1, r2 = r2,
                         resultcallback = resultcallback, endcallback = endcallback, isBranch = true}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end

-- 进入副本支线战斗 add by vv
local mustWinTable = {
    [710021] = true,
}
function BattleUtils.enterBattleView_FubenBranch(playerInfo, branchId, isReplay, resultcallback, endcallback, fastRes)
    local branchD = tab.branchMonsterStage[branchId]
    local monster
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = branchD["hero"], 
                                }
                        }
    for i = 1, 8 do
        monster = branchD["m"..i]
        if monster == nil then
            break
        end
        enemyInfo.npc[i] = monster
    end

    local showNpc = {branchD["showNpc"], branchD["showDes"]}
    if branchD["showNpc"] == nil then
        showNpc = nil
    end

    local assist = branchD["helpCondition"] ~= nil
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Fuben, playerInfo = playerInfo, enemyInfo = enemyInfo,
                        mapId = branchD["mapId"],
                        assist = assist,
                        intanceD = branchD,
                        r1 = branchId,
                        isReport = isReplay,
                        showNpc = showNpc,
                        isBranch = true,
                        mustWin = mustWinTable[branchId] ~= nil,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if mustWinTable[branchId] ~= nil or isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if mustWinTable[branchId] ~= nil or isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 进入竞技场战斗
-- replayType
-- 0: 正常
-- 1: 战报回放
-- 2: 战报分享
-- 3: 好友切磋
function BattleUtils.enterBattleView_Arena(playerInfo, enemyInfo, r1, r2, replayType, reverse, resultcallback, endcallback, fastRes)
    local isShare = (replayType == 2)
    local isReplay = (replayType == 1 or isShare)
    local isFriend = (replayType == 3)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Arena, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "jingjichang1",
                        isReport = isReplay,
                        isShare = isShare,
                        isFriend = isFriend,
                        isBranch = isFriend,
                        reverse = reverse,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 进入跨服竞技场战斗
-- replayType
-- 0: 正常
-- 1: 战报回放
-- 2: 战报分享
-- 3: 好友切磋
function BattleUtils.enterBattleView_ServerArena(playerInfo, enemyInfo, r1, r2, replayType, reverse, resultcallback, endcallback, fastRes)
    local isShare = (replayType == 2)
    local isReplay = (replayType == 1 or isShare)
    local isFriend = (replayType == 3)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_ServerArena, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "jingjichang1",
                        isReport = isReplay,
                        isShare = isShare,
                        isFriend = isFriend,
                        isBranch = isFriend,
                        reverse = reverse,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 前端快速战斗检查表格用
function BattleUtils.checkTable_Arena(playerInfo, enemyInfo)
    local teamTab = {}
    local heroTab = {}
    local teams
    teams = playerInfo.team
    for i = 1, #teams do
        teamTab[teams[i].id] = true
    end
    heroTab[playerInfo.hero.id] = true
    teams = enemyInfo.team
    for i = 1, #teams do
        teamTab[teams[i].id] = true
    end
    heroTab[enemyInfo.hero.id] = true
    return tab:checkSignatureTabs(teamTab, nil, heroTab)
end

-- 进入GVG遭遇战
function BattleUtils.enterBattleView_GVG(playerInfo, enemyInfo, r1, r2, resultcallback, endcallback, fastRes)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_GVG, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "yaosai1",
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.dontCheck = true
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    BattleUtils.dontCheck = false
    return res, res1, res2
end

-- 进入矮人战斗
function BattleUtils.enterBattleView_AiRenMuWu(actId, playerInfo, exBattleTime, resultcallback, endcallback, r1, r2, fastRes)
    local actD = tab.pveSetting[actId]
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = actD["hero"], 
                                }
                        }
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_AiRenMuWu, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "airenbaowu1",
                        exBattleTime = exBattleTime,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end
-- 进入僵尸战斗
function BattleUtils.enterBattleView_Zombie(actId, playerInfo, exZhalanHPPro, exZhalanCount, exBattleTime, resultcallback, endcallback, r1, r2)
    local actD = tab.pveSetting[actId]
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = actD["hero"], 
                                }
                        }
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Zombie, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "yinsenmushi1",
                        exZhalanHPPro = exZhalanHPPro,
                        exZhalanCount = exZhalanCount,
                        exBattleTime = exBattleTime,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.doBattle(battleInfo)
end

-- 进入攻城战
-- 增加resultMode 攻城战针对不同场景（副本，远征，需要展示结果页面也不一样）resultMode可以为nil，nil后会用mode的值作为展示结果 edit by vv
function BattleUtils.enterBattleView_Siege(playerInfo, enemyInfo, intanceD, isReplay, siegeReverse, assist, showNpc, subType, physical, mapId, siegeId, siegeLevel, arrowLevel, siegeBroken, resultMode, resultcallback, endcallback, fastRes)
    local battleId, mustWin
    local isPass = false
    if intanceD then
        battleId = intanceD["id"]
        -- 判断此关卡是否已经通过
        
        local isElite = false
        if not BATTLE_PROC then
            local modelMgr = ModelManager:getInstance()
            if modelMgr:getModel("UserModel"):getPlayerLevel() then
                if math.mod(floor(battleId/100000), 10) == 1 then
                    local stage = modelMgr:getModel("IntanceModel"):getStageInfo(battleId)
                    if stage.star > 0 then 
                        isPass = true
                    end
                else
                    isElite = true
                    local stage = modelMgr:getModel("IntanceEliteModel"):getStageInfo(battleId)
                    if stage.star > 0 then 
                        isPass = true
                    end
                end
            end
        end
        mustWin = ((battleId <= 7100202) and (not isPass))
    end
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Siege, resultMode = resultMode, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        subType = subType, physical = physical,
                        intanceD = intanceD,
                        isReport = isReplay,
                        battleId = battleId,
                        assist = assist,
                        showNpc = showNpc,
                        siegeBroken = siegeBroken,
                        reverse = false,
                        siegeReverse = siegeReverse,
                        mustWin = mustWin,
                        isPass = isPass,
                        r1 = siegeId,
                        mapId = mapId, siegeId = siegeId, siegeLevel = siegeLevel, arrowLevel = arrowLevel,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if battleId and battleId <= 7100202 or isReplay or subType == BattleUtils.BATTLE_TYPE_Biography then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if battleId and battleId <= 7100202 or isReplay or subType == BattleUtils.BATTLE_TYPE_Biography then BattleUtils.dontCheck = false end
    return res, res1, res2
end

function BattleUtils.enterBattleView_CCSiege(playerInfo, enemyInfo, cctD, cctD2, isReplay, mapId, siegeId, siegeLevel, arrowLevel, siegeBroken, resultMode, resultcallback, endcallback, fastRes)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_CCSiege, resultMode = resultMode, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        cctD = cctD,
                        cctD2 = cctD2,
                        isReport = isReplay,
                        siegeBroken = siegeBroken,
                        mapId = mapId, siegeId = siegeId, siegeLevel = siegeLevel, arrowLevel = arrowLevel,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 攻城战(进攻)(日常)
function BattleUtils.enterBattleView_Siege_Atk(playerInfo, siegeBattleGroupID, isReplay, resultcallback, endcallback, fastRes)
    local siegeBattleGroupD = tab.siegeBattleGroup[siegeBattleGroupID]
    local monster
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = siegeBattleGroupD["hero"], 
                                }
                        }
    for i = 1, 8 do
        monster = siegeBattleGroupD["m"..i]
        if monster == nil then
            break
        end
        enemyInfo.npc[i] = monster
    end
    local _siegeid = siegeBattleGroupD["siegeid"]

    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Siege_Atk, 
                        playerInfo = playerInfo, 
                        enemyInfo = enemyInfo, 
                        mapId = siegeBattleGroupD["mapID"] or "kaichang", 
                        isReport = isReplay,
                        siegeId = _siegeid[1], siegeLevel = _siegeid[2], arrowLevel = _siegeid[3],
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 攻城战(进攻)(世界事件)
function BattleUtils.enterBattleView_Siege_Atk_WE(playerInfo, siegeBattleGroupID, isReplay, resultcallback, endcallback, fastRes)
    local siegeBattleGroupD = tab.siegeBattleGroup[siegeBattleGroupID]
    local monster
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = siegeBattleGroupD["hero"], 
                                }
                        }
    for i = 1, 8 do
        monster = siegeBattleGroupD["m"..i]
        if monster == nil then
            break
        end
        enemyInfo.npc[i] = monster
    end
    local _siegeid = siegeBattleGroupD["siegeid"]

    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Siege_Atk_WE, 
                        playerInfo = playerInfo, 
                        enemyInfo = enemyInfo, 
                        mapId = siegeBattleGroupD["mapID"] or "kaichang", 
                        isReport = isReplay,
                        siegeId = _siegeid[1], siegeLevel = _siegeid[2], arrowLevel = _siegeid[3],
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 攻城战(防守)(日常)
function BattleUtils.enterBattleView_Siege_Def(playerInfo, siegeBattleGroupID, defWin, isReplay, resultcallback, endcallback, fastRes)
    local siegeBattleGroupD = tab.siegeBattleGroup[siegeBattleGroupID]
    local monster
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = siegeBattleGroupD["hero"], 
                                }
                        }
    local defultMonsters = siegeBattleGroupD["defultMonsters"]
    local pos = {4, 3, 8, 7, 12, 11, 16, 15}
    for i = 1, #defultMonsters do
        monster = siegeBattleGroupD["m"..defultMonsters[i]]
        if monster == nil then
            break
        end
        enemyInfo.npc[i] = {monster, pos[i]}
    end
    local weapon4 = playerInfo.weapons[4]
    local siegeid = siegeBattleGroupD["siegeDefendId"]
    local siegeLevel = 1
    local arrowLevel = 1
    local totemLevel = 1
    -- 通过第四个位置的攻城器械，计算出相关城防等级
    if weapon4 then
        weapon4.k = 2
        local attr = BattleUtils.getWeaponAttr(weapon4)
        local siegeWeaponD = tab.siegeWeapon[weapon4.id]
        siegeid = siegeWeaponD["siegeid"]
        local siegeD = tab.siege[siegeid]
        local totemid = siegeD["moatattrObject"][1]
        local npcD, totemD, siegelv
        
        siegelv = siegeWeaponD["siegelv"]

        if siegelv then
            dump(siegelv)
            siegeLevel = floor(attr[1] * siegelv[1] + attr[2] * siegelv[2] + attr[3] * siegelv[3])

            dump(siegelv)
            arrowLevel = floor(attr[1] * siegelv[1] + attr[2] * siegelv[2] + attr[3] * siegelv[3])
        end
        totemD = tab.object[totemid]
        siegelv = totemD["siegelv"]
        if siegelv then
            dump(siegelv)
            totemLevel = 1 + floor(attr[1] * siegelv[1] + attr[2] * siegelv[2] + attr[3] * siegelv[3])
        end
        dump(attr)
        print(siegeLevel, arrowLevel, totemLevel)
    end
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Siege_Def, 
                        playerInfo = playerInfo, 
                        enemyInfo = enemyInfo, 
                        siegeBattleGroupD = siegeBattleGroupD,
                        mapId = siegeBattleGroupD["mapID"] or "kaichang", 
                        isReport = isReplay,
                        siegeReverse = true,
                        siegeId = siegeid, 
                        defWin = defWin,
                        siegeLevel = siegeLevel, 
                        arrowLevel = arrowLevel,
                        totemLevel = totemLevel,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 攻城战(防守)(世界事件)
--[[
    wallLv：城墙等级
]]
function BattleUtils.enterBattleView_Siege_Def_WE(playerInfo, wallLv, siegeBattleGroupID, isReplay, resultcallback, endcallback, fastRes)
    local siegeBattleGroupD = tab.siegeBattleGroup[siegeBattleGroupID]
    local siegeWallBuildD = tab.siegeWallBuild[wallLv]
    local monster
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = siegeBattleGroupD["hero"], 
                                }
                        }
    local defultMonsters = siegeBattleGroupD["defultMonsters"]
    local pos = {4, 3, 8, 7, 12, 11, 16, 15}
    for i = 1, #defultMonsters do
        monster = siegeBattleGroupD["m"..defultMonsters[i]]
        if monster == nil then
            break
        end
        enemyInfo.npc[i] = {monster, pos[i]}
    end

    local arrowLevel = 0
    if siegeWallBuildD["baseIsOpen"] == 1 then
        arrowLevel = siegeWallBuildD["base"]
    end
    local totemLevel = 0
    if siegeWallBuildD["defenceIsOpen"] == 1 then
        totemLevel = siegeWallBuildD["defence"]
    end
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Siege_Def_WE, 
                        playerInfo = playerInfo, 
                        enemyInfo = enemyInfo, 
                        siegeBattleGroupD = siegeBattleGroupD,
                        mapId = siegeBattleGroupD["mapID"] or "kaichang", 
                        isReport = isReplay,
                        siegeReverse = true,
                        siegeId = siegeBattleGroupD["siegeDefendId"], 
                        defWin = 0,
                        siegeLevel = siegeWallBuildD["wall"], 
                        arrowLevel = arrowLevel,
                        totemLevel = totemLevel,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- BOSS战 毒龙
function BattleUtils.enterBattleView_BOSS_DuLong(actId, playerInfo, resultcallback, endcallback, r1, r2)
    local actD = tab.pveSetting[actId]
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = actD["hero"], 
                                }
                        }
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_BOSS_DuLong, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "dulongxue1", bossId = actD["NPC"][1], bossHpCount = #actD["reward"] - 1,
                        diff = actD["diff"], subid = actD["subid"],
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.doBattle(battleInfo)
end
-- BOSS战 仙女龙
function BattleUtils.enterBattleView_BOSS_XnLong(actId, playerInfo, resultcallback, endcallback, r1, r2)
    local actD = tab.pveSetting[actId]
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = actD["hero"], 
                                }
                        }
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_BOSS_XnLong, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "jinglingsenlin1", bossId = actD["NPC"][1], bossHpCount = #actD["reward"] - 1,
                        diff = actD["diff"], subid = actD["subid"],
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.doBattle(battleInfo)
end

-- BOSS战 水晶龙
function BattleUtils.enterBattleView_BOSS_SjLong(actId, playerInfo, resultcallback, endcallback, r1, r2)
    local actD = tab.pveSetting[actId]
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = actD["hero"], 
                                }
                        }
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_BOSS_SjLong, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "shuijinglongdong1", bossId = actD["NPC"][1], bossHpCount = #actD["reward"] - 1,
                        diff = actD["diff"], subid = actD["subid"],
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.doBattle(battleInfo)
end

-- 联盟探索BOSS1
function BattleUtils.enterBattleView_GBOSS_1(level, kill, playerInfo, resultcallback, endcallback, r1, r2)
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = 70000001, 
                                }
                        }
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_GBOSS_1, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "dixue1", bossId = 8010901, bossHpCount = 10,
                        bossLevel = level, bossKill = kill,
                        diff = 1, subid = 1,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.doBattle(battleInfo)
end
-- 联盟探索BOSS2
function BattleUtils.enterBattleView_GBOSS_2(level, kill, playerInfo, resultcallback, endcallback, r1, r2)
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = 70000001, 
                                }
                        }
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_GBOSS_2, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "jinglingsenlin1", bossId = 8010902, bossHpCount = 10,
                        bossLevel = level, bossKill = kill,
                        diff = 1, subid = 1,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.doBattle(battleInfo)
end

-- 联盟探索BOSS3
function BattleUtils.enterBattleView_GBOSS_3(level, kill, playerInfo, resultcallback, endcallback, r1, r2)
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = 70000001, 
                                }
                        }
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_GBOSS_3, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "emowangzuo1", bossId = 8010903, bossHpCount = 10,
                        bossLevel = level, bossKill = kill,
                        diff = 1, subid = 1,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.doBattle(battleInfo)
end

function BattleUtils.crusadeSiegeUpdateFormation(enemyInfo, enemyD)
    -- 优化布阵
    -- 近战 8 12 4 16 15 3 11 7  
    -- 远程 7 11 3 15 16 4 12 8
    -- 近战 6 10 2 14 13 1 9 5  
    -- 远程 5 9 1 13 14 2 10 6
    local pos = {{6, 10, 2, 14, 13, 1, 9, 5}, {5, 9, 1, 13, 14, 2, 10, 6}}
    local counts = {0, 0}
    local teams = enemyInfo.team
    local teamD, id
    for i = 1, 8 do
        id = enemyD.formation["team"..i]
        if id ~= 0 then
            teamD = tab.team[id]
            local atktype = teamD["atktype"]
            counts[atktype] = counts[atktype] + 1
            enemyD.formation["g"..i] = pos[atktype][counts[atktype]]

            for k = 1, #teams do 
                if teams[k].id == id then
                    enemyInfo.team[k].pos = enemyD.formation["g"..i]
                end
            end
        end
    end
end

-- 进入远征事件战斗
function BattleUtils.enterBattleView_Crusade_Trigger(playerInfo, enemyInfo, resultcallback, endcallback)
    -- 敌方不使用器械
    if enemyInfo.weapons then
        enemyInfo.weapons = {}
    end 
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Crusade, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "shamo1",
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.doBattle(battleInfo)
end

-- 进入远征战斗
function BattleUtils.enterBattleView_Crusade(playerInfo, enemyInfo, crusadeId, siegeBroken, resultcallback, endcallback, fastRes)
    -- 敌方不使用器械
    if enemyInfo.weapons then
        enemyInfo.weapons = {}
    end 
    if crusadeId then
        local crusadeD = tab.crusadeMain[crusadeId]
        if crusadeD["siegeid"] then
            -- 攻城战
            local siege = crusadeD["siegeid"]
            local siegeidRatio = crusadeD["siegeidRatio"]
            local lvl = playerInfo.lv
            return BattleUtils.enterBattleView_Siege(playerInfo, enemyInfo, nil, false, false, false, nil, BattleUtils.BATTLE_TYPE_Crusade, nil, crusadeD["mapId"], 
                siege, siegeidRatio[1] * lvl, siegeidRatio[2] * lvl, siegeBroken, BattleUtils.BATTLE_TYPE_Crusade, resultcallback, endcallback, fastRes)   
        end
    end
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Crusade, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "shamo1",
                        r1 = crusadeId,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end

-- 进入联盟探索战斗
function BattleUtils.enterBattleView_GuildPVE(playerInfo, enemyInfo, resultcallback, endcallback, fastRes)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_GuildPVE, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "pingyuan1",
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end

-- 进入联盟探索战斗
function BattleUtils.enterBattleView_GuildPVP(playerInfo, enemyInfo, resultcallback, endcallback, fastRes)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_GuildPVP, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "pingyuan2",
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end
-- 前端快速战斗检查表格用
function BattleUtils.checkTable_GuildPVP(playerInfo, enemyInfo)
    local teamTab = {}
    local heroTab = {}
    local teams
    teams = playerInfo.team
    for i = 1, #teams do
        teamTab[teams[i].id] = true
    end
    heroTab[playerInfo.hero.id] = true
    teams = enemyInfo.team
    for i = 1, #teams do
        teamTab[teams[i].id] = true
    end
    heroTab[enemyInfo.hero.id] = true
    return tab:checkSignatureTabs(teamTab, nil, heroTab)
end

-- 进入联盟密境战斗
function BattleUtils.enterBattleView_GuildFAM(playerInfo, enemyInfo, resultcallback, endcallback, fastRes)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_GuildFAM, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "pingyuan2",
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end

-- 进入积分战斗
function BattleUtils.enterBattleView_League(playerInfo, enemyInfo, r1, r2, isReplay, resultcallback, endcallback, fastRes)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_League, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "jifenliansai1",
                        isReport = isReplay,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end

-- 进入MF战斗
function BattleUtils.enterBattleView_MF(playerInfo, enemyInfo, resultcallback, endcallback, fastRes)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_MF, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "shatan1",
                        resultcallback = resultcallback, endcallback = endcallback, isBranch = true}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end

-- 云中城
-- buff从cctId2 里面取
function BattleUtils.enterBattleView_CloudCity(playerInfo, cctId, cctId2, isReplay, siegeBroken, resultcallback, endcallback, fastRes)
    local cctD = tab.towerFight[cctId]
    local cctD2 = tab.towerFight[cctId2]
    local monster
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = cctD["hero"], 
                                }
                        }
    for i = 1, 8 do
        monster = cctD["m"..i]
        if monster == nil then
            break
        end
        enemyInfo.npc[i] = monster
    end
    local weatherTab = {"xiayu", "shamo", "xiaxue"}

    -- 兵团技能等级附加
    if cctD2["skill"] then
        local skillAdd = cctD2["skill"]
        local addTab = {}
        for i = 1, #skillAdd do
            addTab[skillAdd[i][1]] = skillAdd[i][2]
        end
        local team, teamD, skills, lv
        for i = 1, #playerInfo.team do
            team = playerInfo.team[i]
            teamD = tab.team[team.id]
            skills = teamD["skill"]
            for k = 1, #skills do
                lv = addTab[skills[k][2]]
                if lv then
                    team.skill[k] = team.skill[k] + lv
                end
            end
        end
    end
    -- 英雄属性加成
    if cctD2["hskill"] then
        local attrAdd = cctD2["hskill"]
        local buff = {}
        for i = 1, #attrAdd do
            buff[attrAdd[i][1]] = attrAdd[i][2]
        end
        if playerInfo.hero.buff then
            for k, v in pairs(buff) do
                if playerInfo.hero.buff[k] then
                    playerInfo.hero.buff[k] = playerInfo.hero.buff[k] + v
                else
                    playerInfo.hero.buff[k] = v
                end
            end
        else
            playerInfo.hero.buff = buff
        end
    end

    if cctD["siegeid"] then
        -- 攻城战
        local siege = cctD["siegeid"]
        return BattleUtils.enterBattleView_CCSiege(playerInfo, enemyInfo, cctD, cctD2, isReplay, cctD["mapId"], siege[1], siege[2], siege[3], siegeBroken, nil, resultcallback, endcallback, fastRes)
    end
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_CloudCity, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        cctD = cctD,
                        cctD2 = cctD2,
                        cctAssist = cctD["hm1"] ~= nil,
                        r1 = cctId,
                        mapId = cctD["mapId"],
                        isReport = isReplay,
                        weather = weatherTab[cctD["weather"]],
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    if isReplay then BattleUtils.dontCheck = true end
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    if isReplay then BattleUtils.dontCheck = false end
    return res, res1, res2
end
-- 训练所战斗
function BattleUtils.enterBattleView_Training(_playerInfo, trainingId, resultcallback, endcallback, fastRes)
    local trainingD = tab.training[trainingId]
    local playerInfo
    if _playerInfo then
        playerInfo = _playerInfo
    else
        playerInfo = { 
                            lv = 1,
                            npc = {}, 
                            hero = {
                                    npcHero = true,
                                    id = trainingD["hero1"], 
                                    }
                            }
        for i = 1, #trainingD["npc1"] do
            playerInfo.npc[i] = trainingD["npc1"][i]
        end
    end
    -- 下面两行为快速复盘
    -- playerInfo.npc = cjson.decode("[[94101,11],[94111,4],[94107,12],[94109,14],[94102,13],[94106,5],[94103,7],[94104,8]]")
    -- playerInfo.skillList = cjson.decode("[[247,2,1172,436],[865,4,932,285],[964,2,1267,358],[1368,1,1578,420],[1654,2,1267,505],[2002,1,1608,337]]")

    local enemyInfo = { 
                        lv = 1,
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = trainingD["enemyhero"], 
                                }
                        }
    for i = 1, #trainingD["enemynpc"] do
        enemyInfo.npc[i] = trainingD["enemynpc"][i]
    end

    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Training, playerInfo = playerInfo, enemyInfo = enemyInfo,
                        battleId = trainingId,
                        trainingD = trainingD,
                        r1 = trainingId,
                        mapId = "xunlianchang1",
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.dontCheck = true
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    BattleUtils.dontCheck = false
    return res, res1, res2
end
-- 英雄传记战斗
function BattleUtils.enterBattleView_Biography(_playerInfo, bioId, resultcallback, endcallback, fastRes)
    local bioD = tab.heroStage[bioId]
    local playerInfo
    if _playerInfo then
        playerInfo = _playerInfo
    else
        playerInfo = { 
                            lv = 1,
                            npc = {}, 
                            hero = {
                                    npcHero = true,
                                    id = bioD["hero1"], 
                                    }
                            }
        for i = 1, #bioD["npc1"] do
            playerInfo.npc[i] = bioD["npc1"][i]
        end
    end

    local enemyInfo = { 
                        lv = 1,
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = bioD["enemyhero"], 
                                }
                        }
    for i = 1, #bioD["enemynpc"] do
        enemyInfo.npc[i] = bioD["enemynpc"][i]
    end

    -- 我方宝物
    local treasure1 = bioD["treasure1"]
    if treasure1 then
        local treasure = {}
        local _id, _stage
        for i = 1, #treasure1 do
            _id = treasure1[i][1]
            _stage = treasure1[i][2]
            treasure[_id] = {stage = _stage, treasureDev = {}}
        end
        playerInfo.treasure = treasure
    end
    -- 敌方宝物
    local treasure2 = bioD["treasure2"]
    if treasure2 then
        local treasure = {}
        local _id, _stage
        for i = 1, #treasure2 do
            _id = treasure2[i][1]
            _stage = treasure2[i][2]
            treasure[_id] = {stage = _stage, treasureDev = {}}
        end
        enemyInfo.treasure = treasure
    end

    if bioD["siegeid"] then
        -- 攻城战
        local siege = bioD["siegeid"]
        return BattleUtils.enterBattleView_Siege(playerInfo, enemyInfo, nil, false, bioD["siegeReverse"] ~= nil, false, nil, BattleUtils.BATTLE_TYPE_Biography,
         nil, bioD["mapId"], siege[1], siege[2], siege[3], nil, BattleUtils.BATTLE_TYPE_Biography, resultcallback, endcallback, fastRes)   
    end

    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Biography, playerInfo = playerInfo, enemyInfo = enemyInfo,
                        battleId = trainingId,
                        intanceD = bioD,
                        r1 = trainingId,
                        assist = bioD["helpCondition"] ~= nil,
                        mapId = bioD["mapId"],
                        endTalkId = bioD["endTalkId"],
                        startTalkId = bioD["startTalkId"],
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.dontCheck = true
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    BattleUtils.dontCheck = false
    return res, res1, res2
end
-- 进入大富翁战斗
function BattleUtils.enterBattleView_Adventure(playerInfo, enemyInfo, resultcallback, endcallback, fastRes)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_Adventure, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "xiaguyiji1",
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end

-- 进入英雄交锋战斗
function BattleUtils.enterBattleView_HeroDuel(playerInfo, enemyInfo, r1, r2, replayType, reverse, resultcallback, endcallback, fastRes)
    local isReplay = (replayType > 0)
    local isShare = (replayType == 2)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_HeroDuel, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "fanchuan1",
                        isReport = isReplay,
                        isShare = isShare,
                        reverse = reverse,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.dontCheck = true
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    BattleUtils.dontCheck = false
    return res, res1, res2
end

-- 进入竞技场战斗
-- replayType
-- 0: 正常
-- 1: 战报回放
-- 2: 战报分享
-- 3: 好友切磋
function BattleUtils.enterBattleView_GodWar(playerInfo, enemyInfo, r1, r2, replayType, reverse, winlose, showDraw, showSkill, resultcallback, endcallback, fastRes)
    local isShare = (replayType == 2)
    local isReplay = (replayType == 1 or isShare)
    local isFriend = (replayType == 3)
    local battleInfo = {mode = BattleUtils.BATTLE_TYPE_GodWar, playerInfo = playerInfo, enemyInfo = enemyInfo, 
                        mapId = "migongbaozang1",
                        winlose = winlose,
                        showDraw = showDraw,
                        showSkill = showSkill,
                        isReport = isReplay,
                        isShare = isShare,
                        isFriend = isFriend,
                        isBranch = isFriend,
                        reverse = reverse,
                        r1 = r1, r2 = r2,
                        resultcallback = resultcallback, endcallback = endcallback}
    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    BattleUtils.dontCheck = true
    local res, res1, res2 = BattleUtils.doBattle(battleInfo, fastRes)
    BattleUtils.dontCheck = false
    return res, res1, res2
end

-- 元素位面战斗
-- kind为位面种类
function BattleUtils.enterBattleView_Elemental(playerInfo, kind, id, resultcallback, endcallback, fastRes)
    if kind < 1 or kind > 5 then return end
    local elementalPlane = tab["elementalPlane"..kind]
    if elementalPlane == nil then return end
    local elementalPlaneD = elementalPlane[id]
    if elementalPlaneD == nil then return end

    local monster
    local enemyInfo = { 
                        npc = {}, 
                        hero = {
                                npcHero = true,
                                id = elementalPlaneD["hero"], 
                                }
                        }
    for i = 1, 8 do
        monster = elementalPlaneD["m"..i]
        if monster == nil then
            break
        end
        enemyInfo.npc[i] = monster
    end
    local weatherTab = {"xiayu", "shamo", "xiaxue"}
    local battleInfo = {mode = BattleUtils["BATTLE_TYPE_Elemental_"..kind], playerInfo = playerInfo, enemyInfo = enemyInfo,
                        elementalPlaneD = elementalPlaneD,
                        r1 = tonumber(kind) * 10000 + tonumber(id),
                        weather = weatherTab[elementalPlaneD["weather"]],
                        mapId = elementalPlaneD["mapId"], scaleMin = elementalPlaneD["scaleMin"], scaleMax = elementalPlaneD["scaleMax"],
                        resultcallback = resultcallback, endcallback = endcallback}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end


-- 进入爬塔副本战斗
function BattleUtils.enterBattleView_ClimbTower(playerInfo, enemyInfo, r1, r2 ,resultcallback, endcallback, fastRes)
    local cardId = tonumber(enemyInfo.stageId)
    local cfg = tab.purFight[cardId]
    if cfg == nil then return end 
    local teamlv = cfg["teamlvS"]
    local teamskill = cfg["teamskill"]
    local teamscore = cfg["teamscore"]
    local teamstar = cfg["teamstar"]
    local teamlv2 = cfg["teamlv"]
    local teamquality = cfg["teamquality"]
    local jxLv = cfg["jxLv"]
    local jxSkill1 = cfg["jxSkill1"]
    local jxSkill2 = cfg["jxSkill2"]
    local jxSkill3 = cfg["jxSkill3"]
    -- 拼接hero信息
    local hero = enemyInfo.hero 
    hero.id = enemyInfo.hero.heroId
    hero.star = cfg.herostar or 1
    hero.level = 1
    local slevel = cfg.heroskill or 1
    hero.slevel = {slevel, slevel, slevel, slevel, slevel}
    hero.hAb = {}
    for i=1, 4 do
        hero.hAb[tostring(i)] = cfg.herobase[i]
    end
   
    if enemyInfo.hero and enemyInfo.hero.exSkill then
        hero.skillex = enemyInfo.hero.exSkill
    end

    enemyInfo.manabase = cfg.manabase
    enemyInfo.manarec = cfg.manarec
    -- 初始化npc数据
    enemyInfo.npc = {}
    local monsters = enemyInfo.teams
    local count = 1
    for k,v in pairs(monsters) do
        local npcData = tab.npc[v["npcid"]]
        local jx = npcData and npcData.jx == 1
        enemyInfo.npc[count] = {v["npcid"], v["pos"] , teamlv, teamskill, teamscore, teamstar, teamlv2, teamquality, jx, jxLv, jxSkill1, jxSkill2, jxSkill3}
        count = count + 1
    end
    enemyInfo.teams = nil
    
    local battleInfo = { mode = BattleUtils.BATTLE_TYPE_ClimbTower,
                         playerInfo = playerInfo, 
                         enemyInfo = enemyInfo,
                         mapId = cfg["mapId"],
                         r1 = r1, r2 = r2,
                         resultcallback = resultcallback, endcallback = endcallback, isBranch = true}

    if cc.Director then cc.Director:getInstance():getTextureCache():removeUnusedTextures() end
    return BattleUtils.doBattle(battleInfo, fastRes)
end

-- 进入新手引导战斗
function BattleUtils.enterBattleView_Guide(resultcallback, endcallback)
    tab:initGuideBattle()
    audioMgr:playMusic("siegeBgm", true)
    local battleInfo = GuideUtils.getGuideBattleInfo()
    battleInfo.resultcallback = function (info, callback) callback(info) end
    battleInfo.endcallback = endcallback
    BattleUtils.dontCheck = true
    BattleUtils.doBattle(battleInfo, nil, nil, true)
    BattleUtils.dontCheck = false
end

-- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo --
-- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo --
-- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo ---- 战斗demo --

local playerInfo = {
                    lv = 50,
                    team = {}, 
                    hero = {
                            id = BattleUtils.LEFT_HERO_ID, 
                            level = BattleUtils.LEFT_HERO_LEVEL,
                            star = BattleUtils.LEFT_HERO_STAR,
                            slevel = BattleUtils.LEFT_HERO_SKILL_LEVEL, 
                            mastery = BattleUtils.LEFT_HERO_MASTERY,
                            skillex = {514, 1, 1}
                            },
                    pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                    ver = tab.battleVer[1]["ver"],
                    }

if DEBUG_ENABLE_TREASURE_1 then
    playerInfo.treasure = {
                    [11] = {stage = 1, treasureDev = {}}, 
                    [21] = {stage = 1, treasureDev = {}},
                    [22] = {stage = 1, treasureDev = {}},
                    [30] = {stage = 1, treasureDev = {}},
                    [31] = {stage = 1, treasureDev = {}},
                    [10] = {stage = 1, treasureDev = {}},
                    [32] = {stage = 1, treasureDev = {}},
                    [40] = {stage = 1, treasureDev = {}},
                    [41] = {stage = 1, treasureDev = {}},
                    [42] = {stage = 1, treasureDev = {}},
                    }
end

local team
for i = 1, BattleUtils.LEFT_TEAM_COUNT  do
    team = {
                id = BattleUtils.LEFT_ID[i],
                pos = BattleUtils.LEFT_FORMATION[i],
                level = BattleUtils.LEFT_LEVEL[i],
                star = BattleUtils.LEFT_STAR[i],
                smallStar = BattleUtils.LEFT_SMALLSTAR[i],
                stage = BattleUtils.LEFT_STAGE[i],
                equip = {
                            {stage = BattleUtils.LEFT_EQUIP_STAGE[i][1],
                            level = BattleUtils.LEFT_EQUIP_LEVEL[i][1]},
                            {stage = BattleUtils.LEFT_EQUIP_STAGE[i][2],
                            level = BattleUtils.LEFT_EQUIP_LEVEL[i][2]},
                            {stage = BattleUtils.LEFT_EQUIP_STAGE[i][3],
                            level = BattleUtils.LEFT_EQUIP_LEVEL[i][3]},
                            {stage = BattleUtils.LEFT_EQUIP_STAGE[i][4],
                            level = BattleUtils.LEFT_EQUIP_LEVEL[i][4]}
                        },
                skill = BattleUtils.LEFT_SKILL_LEVEL[i]
           }
    table.insert(playerInfo.team, team)
end
playerInfo.weapons = 
{
    [1] = 
    {
        id = 11,
        lv = 5,
        sp1 = {},
        sp2 = {id = 1, lv = 3},
        sp3 = nil,
        sp4 = {},
        ss1 = 0,
        ss2 = 0,
    },
    [2] = 
    {
        id = 21,
        lv = 5,
        sp1 = {},
        sp2 = {id = 1, lv = 3},
        sp3 = nil,
        sp4 = {},
        ss1 = 0,
        ss2 = 0,
    },
    [3] = 
    {
        id = 31,
        lv = 5,
        sp1 = {},
        sp2 = {id = 1, lv = 3},
        sp3 = nil,
        sp4 = {},
        ss1 = 0,
        ss2 = 0,
    },
    [4] = 
    {
        id = 41,
        lv = 5,
        sp1 = {},
        sp2 = {id = 1, lv = 3},
        sp3 = nil,
        sp4 = {},
        ss1 = 0,
        ss2 = 0,
    }
}

function BattleUtils.battleDemo_Fuben()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    if BattleUtils.fubenBranch then
        BattleUtils.enterBattleView_FubenBranch(playerInfo, BattleUtils.PVE_INTANCE_ID, false,
        function (info, callback)
            callback(info)
        end,
        function ()

        end)
    else

        BattleUtils.enterBattleView_Fuben(playerInfo, BattleUtils.PVE_INTANCE_ID,false,
        function (info, callback)
            callback(info)
        end,
        function ()

        end)
    end
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_Arena()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    local count = BattleUtils.RIGHT_TEAM_COUNT
    local enemyInfo = { 
                        lv = 50,
                        team = {}, 
                        hero = {
                                id = BattleUtils.RIGHT_HERO_ID, 
                                level = BattleUtils.RIGHT_HERO_LEVEL,
                                slevel = BattleUtils.RIGHT_HERO_SKILL_LEVEL,
                                star = BattleUtils.RIGHT_HERO_STAR,
                                mastery = BattleUtils.RIGHT_HERO_MASTERY,
                                },
                        pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                        }
    if DEBUG_ENABLE_TREASURE_2 then
        enemyInfo.treasure = {
                        [11] = {stage = 1, treasureDev = {}}, 
                        [21] = {stage = 1, treasureDev = {}},
                        [22] = {stage = 1, treasureDev = {}},
                        [30] = {stage = 1, treasureDev = {}},
                        [31] = {stage = 1, treasureDev = {}},
                        [10] = {stage = 1, treasureDev = {}},
                        [32] = {stage = 1, treasureDev = {}},
                        [40] = {stage = 1, treasureDev = {}},
                        [41] = {stage = 1, treasureDev = {}},
                        [42] = {stage = 1, treasureDev = {}},
                    }
    end
    local team
    local count = BattleUtils.RIGHT_TEAM_COUNT
    for i = 1, count do
        team = {
                    id = BattleUtils.RIGHT_ID[i],
                    pos = BattleUtils.RIGHT_FORMATION[i],
                    level = BattleUtils.RIGHT_LEVEL[i],
                    star = BattleUtils.RIGHT_STAR[i],
                    smallStar = BattleUtils.RIGHT_SMALLSTAR[i],
                    stage = BattleUtils.RIGHT_STAGE[i],
                    equip = {
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][1],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][1]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][2],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][2]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][3],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][3]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][4],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][4]}
                            },
                    skill = BattleUtils.RIGHT_SKILL_LEVEL[i]
               }
        table.insert(enemyInfo.team, team)
    end
    BattleUtils.dontCheck = true

    -- 0: 正常
    -- 1: 战报回放
    -- 2: 战报分享
    -- 3: 好友切磋
    -- playerInfo.hero.skin = 6010201
    -- BattleUtils.enterBattleView_League(playerInfo, enemyInfo, 19870515, 1, false,
    BattleUtils.enterBattleView_Arena(playerInfo, enemyInfo, 19870515, 1, 2, false,
    -- BattleUtils.enterBattleView_GodWar(playerInfo, enemyInfo, 19870515, 1, 1, true,
    -- BattleUtils.enterBattleView_HeroDuel(playerInfo, enemyInfo, 19870515, 1, 0, true,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end
function BattleUtils.battleDemo_ServerArena()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    local count = BattleUtils.RIGHT_TEAM_COUNT
    local enemyInfo = { 
                        lv = 50,
                        team = {}, 
                        hero = {
                                id = BattleUtils.RIGHT_HERO_ID, 
                                level = BattleUtils.RIGHT_HERO_LEVEL,
                                slevel = BattleUtils.RIGHT_HERO_SKILL_LEVEL,
                                star = BattleUtils.RIGHT_HERO_STAR,
                                mastery = BattleUtils.RIGHT_HERO_MASTERY,
                                },
                        pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                        }
    if DEBUG_ENABLE_TREASURE_2 then
        enemyInfo.treasure = {
                        [11] = {stage = 1, treasureDev = {}}, 
                        [21] = {stage = 1, treasureDev = {}},
                        [22] = {stage = 1, treasureDev = {}},
                        [30] = {stage = 1, treasureDev = {}},
                        [31] = {stage = 1, treasureDev = {}},
                        [10] = {stage = 1, treasureDev = {}},
                        [32] = {stage = 1, treasureDev = {}},
                        [40] = {stage = 1, treasureDev = {}},
                        [41] = {stage = 1, treasureDev = {}},
                        [42] = {stage = 1, treasureDev = {}},
                    }
    end
    local team
    local count = BattleUtils.RIGHT_TEAM_COUNT
    for i = 1, count do
        team = {
                    id = BattleUtils.RIGHT_ID[i],
                    pos = BattleUtils.RIGHT_FORMATION[i],
                    level = BattleUtils.RIGHT_LEVEL[i],
                    star = BattleUtils.RIGHT_STAR[i],
                    smallStar = BattleUtils.RIGHT_SMALLSTAR[i],
                    stage = BattleUtils.RIGHT_STAGE[i],
                    equip = {
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][1],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][1]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][2],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][2]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][3],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][3]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][4],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][4]}
                            },
                    skill = BattleUtils.RIGHT_SKILL_LEVEL[i]
               }
        table.insert(enemyInfo.team, team)
    end
    BattleUtils.dontCheck = true

    -- 0: 正常
    -- 1: 战报回放
    -- 2: 战报分享
    -- 3: 好友切磋
    -- playerInfo.hero.skin = 6010201
    -- BattleUtils.enterBattleView_League(playerInfo, enemyInfo, 19870515, 1, false,
    BattleUtils.enterBattleView_ServerArena(playerInfo, enemyInfo, 19870515, 1, 2, false,
    -- BattleUtils.enterBattleView_GodWar(playerInfo, enemyInfo, 19870515, 1, 1, true,
    -- BattleUtils.enterBattleView_HeroDuel(playerInfo, enemyInfo, 19870515, 1, 0, true,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_GVG()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    local count = BattleUtils.RIGHT_TEAM_COUNT
    local enemyInfo = { 
                        lv = 50,
                        team = {}, 
                        hero = {
                                id = BattleUtils.RIGHT_HERO_ID, 
                                level = BattleUtils.RIGHT_HERO_LEVEL,
                                slevel = BattleUtils.RIGHT_HERO_SKILL_LEVEL,
                                star = BattleUtils.RIGHT_HERO_STAR,
                                mastery = BattleUtils.RIGHT_HERO_MASTERY,
                                },
                        pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                        }
    local team
    local count = BattleUtils.RIGHT_TEAM_COUNT
    for i = 1, count do
        team = {
                    id = BattleUtils.RIGHT_ID[i],
                    pos = BattleUtils.RIGHT_FORMATION[i],
                    level = BattleUtils.RIGHT_LEVEL[i],
                    star = BattleUtils.RIGHT_STAR[i],
                    smallStar = BattleUtils.RIGHT_SMALLSTAR[i],
                    stage = BattleUtils.RIGHT_STAGE[i],
                    equip = {
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][1],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][1]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][2],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][2]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][3],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][3]},
                                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][4],
                                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][4]}
                            },
                    skill = BattleUtils.RIGHT_SKILL_LEVEL[i]
               }
        table.insert(enemyInfo.team, team)
    end
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_GVG(playerInfo, enemyInfo, 19870515, 1,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_AiRenMuWu()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_AiRenMuWu(901, playerInfo, 0,
    function (info, callback)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_Zombie()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_Zombie(902, playerInfo, 0, 2, 0,
    function (info, callback)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_Siege()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_Fuben(playerInfo, BattleUtils.PVE_INTANCE_SIEGE_ID, false,
    function (info, callback)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_BOSS_DuLong()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    -- BattleUtils.enterBattleView_BOSS_DuLong(101, playerInfo,
    -- function (info, callback)
    --     callback(info)
    -- end,
    -- function ()

    -- end)
    BattleUtils.enterBattleView_GBOSS_1(100, true, playerInfo,
    function (info, callback)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_BOSS_XnLong()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_BOSS_XnLong(201, playerInfo,
    function (info, callback)
        callback(info)
    end,
    function ()

    end)
    -- BattleUtils.enterBattleView_GBOSS_2(100, true, playerInfo,
    -- function (info, callback)
    --     callback(info)
    -- end,
    -- function ()

    -- end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_BOSS_SjLong()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_BOSS_SjLong(301, playerInfo,
    function (info, callback)
        callback(info)
    end,
    function ()

    end)
    -- BattleUtils.enterBattleView_GBOSS_3(100, true, playerInfo,
    -- function (info, callback)
    --     callback(info)
    -- end,
    -- function ()

    -- end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_Crusade(info)
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    local enemyInfo = { 
        lv = 50,
        team = {}, 
        hero = {
            id = BattleUtils.RIGHT_HERO_ID, 
            level = BattleUtils.RIGHT_HERO_LEVEL,
            slevel = BattleUtils.RIGHT_HERO_SKILL_LEVEL,
            star = BattleUtils.RIGHT_HERO_STAR,
            mastery = BattleUtils.RIGHT_HERO_MASTERY,
        },
        pokedex = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    }
    
    local count = BattleUtils.RIGHT_TEAM_COUNT
    if info and info.enemyInfo then
        count = #info.enemyInfo.team
    end
    for i = 1, count do
        local team = {
            id = BattleUtils.RIGHT_ID[i],
            pos = BattleUtils.RIGHT_FORMATION[i],
            level = BattleUtils.RIGHT_LEVEL[i],
            star = BattleUtils.RIGHT_STAR[i],
            smallStar = BattleUtils.RIGHT_SMALLSTAR[i],
            stage = BattleUtils.RIGHT_STAGE[i],
            equip = {
                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][1],
                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][1]},
                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][2],
                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][2]},
                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][3],
                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][3]},
                {stage = BattleUtils.RIGHT_EQUIP_STAGE[i][4],
                level = BattleUtils.RIGHT_EQUIP_LEVEL[i][4]}
            },
            skill = BattleUtils.RIGHT_SKILL_LEVEL[i]
        }
        table.insert(enemyInfo.team, team)
    end
    
    local crusadePlayerInfo
    if info then
        crusadePlayerInfo = clone(playerInfo)
        local playerData = info.playerInfo
        if playerData then
            crusadePlayerInfo.lv = playerData.lv or crusadePlayerInfo.lv
            
            crusadePlayerInfo.hero.id = playerData.hero.id or crusadePlayerInfo.hero.id
            crusadePlayerInfo.hero.slevel = playerData.hero.slevel or crusadePlayerInfo.hero.slevel
            crusadePlayerInfo.hero.star = playerData.hero.star or crusadePlayerInfo.hero.star
            crusadePlayerInfo.hero.skillex = playerData.hero.skillex or crusadePlayerInfo.hero.skillex
            
            local teamData = playerData.team
            crusadePlayerInfo.team = {}
            local teamCount = teamData and #teamData or BattleUtils.LEFT_TEAM_COUNT
            for i = 1, teamCount do
                local team = {
                    id = teamData[i].id or BattleUtils.LEFT_ID[i],
                    pos = teamData[i].pos or BattleUtils.LEFT_FORMATION[i],
                    level = teamData[i].level or BattleUtils.LEFT_LEVEL[i],
                    star = teamData[i].star or BattleUtils.LEFT_STAR[i],
                    smallStar = BattleUtils.LEFT_SMALLSTAR[i],
                    stage = BattleUtils.LEFT_STAGE[i],
                    equip = {
                        {stage = BattleUtils.LEFT_EQUIP_STAGE[i][1],
                        level = BattleUtils.LEFT_EQUIP_LEVEL[i][1]},
                        {stage = BattleUtils.LEFT_EQUIP_STAGE[i][2],
                        level = BattleUtils.LEFT_EQUIP_LEVEL[i][2]},
                        {stage = BattleUtils.LEFT_EQUIP_STAGE[i][3],
                        level = BattleUtils.LEFT_EQUIP_LEVEL[i][3]},
                        {stage = BattleUtils.LEFT_EQUIP_STAGE[i][4],
                        level = BattleUtils.LEFT_EQUIP_LEVEL[i][4]}
                    },
                    skill = teamData[i].skill or BattleUtils.LEFT_SKILL_LEVEL[i]
                }
                table.insert(crusadePlayerInfo.team, team)
            end
        end
        
        local enemyData = info.enemyInfo
        if enemyData then
            enemyInfo.lv = enemyData.lv or enemyInfo.lv

            enemyInfo.hero.id = enemyData.hero.id or enemyInfo.hero.id
            enemyInfo.hero.slevel = enemyData.hero.slevel or enemyInfo.hero.slevel
            enemyInfo.hero.star = enemyData.hero.star or enemyInfo.hero.star

            local teamData = enemyData.team
            for i,v in ipairs(enemyData.team) do
                enemyInfo.team[i].id = teamData[i].id
                enemyInfo.team[i].level = teamData[i].level
                enemyInfo.team[i].star = teamData[i].star
                enemyInfo.team[i].pos = teamData[i].pos
                enemyInfo.team[i].skill = teamData[i].skill
            end
        end
    end
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_Crusade(crusadePlayerInfo or playerInfo, enemyInfo, 1, false,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_CloudCity()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_CloudCity(playerInfo, BattleUtils.PVE_CCT_ID, BattleUtils.PVE_CCT_ID, false, false,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_Training()
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_Training(nil, BattleUtils.PVE_TRAINING_ID,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_Elemental(kind, id)
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_Elemental(playerInfo, kind or 5, id or 1,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_Siege_Atk(levelid)
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    BattleUtils.enterBattleView_Siege_Atk(playerInfo, levelid, false,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end

function BattleUtils.battleDemo_Siege_Def_WE(levelid)
    tab:initProcBattle()
    BattleUtils.dontInitTab = true
    BattleUtils.dontCheck = true
    -- BattleUtils.enterBattleView_Siege_Atk(playerInfo, levelid, false,
    -- BattleUtils.enterBattleView_Siege_Def_WE(playerInfo, 5, levelid, false,
    BattleUtils.enterBattleView_Siege_Def(playerInfo, levelid, 3, false,
    function (info, callback)
        -- 战斗结束
        -- dump(info)
        callback(info)
    end,
    function ()

    end)
    BattleUtils.dontCheck = false
end


function BattleUtils.battleDemo_Guide()
    tab:initGuideBattle()
    local battleInfo = GuideUtils.getGuideBattleInfo()
    battleInfo.resultcallback = function (info, callback) callback(info) end
    battleInfo.endcallback = function () end

    BattleUtils.dontCheck = true
    BattleUtils.doBattle(battleInfo)
    BattleUtils.dontCheck = false
end

-- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 --
-- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 --
-- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 ---- 战斗复盘 --

function BattleUtils.procBattle(battleInfo) 
    -- 记录战斗用require的lua文件, 结束后释放掉
    require "game.view.battle.logic.BattleConst"
    BC.reset(battleInfo.playerInfo.lv, battleInfo.enemyInfo.lv, battleInfo.reverse, battleInfo.siegeReverse)
    local BattleScene = require("game.view.battle.display.BattleScene")
    local battleScene = BattleScene.new(battleInfo)

    battleScene:setCallBack(function (event, data)
        if event == "onBattleBegin" then

        elseif event == "onBattleEnd" then
            BC = nil
            collectgarbage("collect")
            collectgarbage("collect")
            collectgarbage("collect")

        elseif event == "loadingDone" then
        end
    end)
    return battleScene:procBattle()
end

local table = table
local insert = table.insert

----------------------------- 资源统计 -----------------------------
-- 通过team表或者npc表,统计skill
function BattleUtils.getSkillMap(D, skillLevel, jx)
    local skillMap = {}
    local skillD
    local compose
    local skillList = {}

    local D2 = {}
    if D["match"] then
        D2 = tab.team[D["match"]]
    end

    -- jx = tonumber(v.ast) == 3,
    -- jxLv = tonumber(v.aLvl),
    -- jxSkill1 = jxTree.b1,
    -- jxSkill2 = jxTree.b2,
    -- jxSkill3 = jxTree.b3,
    -- 觉醒技能
    local jxSkill = {}
    -- 为了应付，同时存在选择两种天赋的情况
    local jxSkillex = {}
    if jx and skillLevel then
        local jxSkill1 = skillLevel.jxSkill[1]
        local jxSkill2 = skillLevel.jxSkill[2]
        local jxSkill3 = skillLevel.jxSkill[3]
        if jxSkill1 then
            if jxSkill1 < 3 then 
                local talentTree = D["talentTree1"]
                local talentSkill = talentTree[jxSkill1 + 1]
                jxSkill[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                }
            else
                local talentTree = D["talentTree1"]
                local talentSkill = talentTree[2]
                jxSkill[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                }
                local talentSkill = talentTree[3]
                jxSkillex[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                } 
            end
        end
        if jxSkill2 then
            if jxSkill2 < 3 then 
                local talentTree = D["talentTree2"]
                local talentSkill = talentTree[jxSkill2 + 1]
                jxSkill[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                }
            else
                local talentTree = D["talentTree2"]
                local talentSkill = talentTree[2]
                jxSkill[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                }
                local talentSkill = talentTree[3]
                jxSkillex[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                } 
            end
        end
        if jxSkill3 then
            if jxSkill3 < 3 then 
                local talentTree = D["talentTree3"]
                local talentSkill = talentTree[jxSkill3 + 1]
                jxSkill[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                }
            else
                local talentTree = D["talentTree3"]
                local talentSkill = talentTree[2]
                jxSkill[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                }
                local talentSkill = talentTree[3]
                jxSkillex[talentTree[1]] = 
                {
                    talentSkill[1], talentSkill[2], talentSkill[3]
                } 
            end
        end
    end

    skillD = D["skill"] or D2["skill"]
    if skillD then
        local __jxSkill
        for i = 1, #skillD do
            if skillLevel and skillLevel[i] and skillLevel[i] > 0 then
                __jxSkill = jxSkill[i]
                if __jxSkill then
                    if __jxSkill[3] == 1 then
                        -- 额外增加
                        insert(skillList, skillD[i])
                        insert(skillList, {__jxSkill[1], __jxSkill[2]})
                    else
                        -- 改变
                        insert(skillList, {__jxSkill[1], __jxSkill[2]})
                    end
                else
                    insert(skillList, skillD[i])
                end
                __jxSkill = jxSkillex[i]
                if __jxSkill then
                    if __jxSkill[3] == 1 then
                        -- 额外增加
                        insert(skillList, skillD[i])
                        insert(skillList, {__jxSkill[1], __jxSkill[2]})
                    else
                        -- 改变
                        insert(skillList, {__jxSkill[1], __jxSkill[2]})
                    end
                else
                    insert(skillList, skillD[i])
                end
            end
        end
    end


    skillD = D["skill"] or D2["skill"]
    if skillD then
        for i = 1, #skillD do
            if skillLevel and skillLevel[i] and skillLevel[i] > 0 then
                insert(skillList, skillD[i])
            end
        end
    end

    -- 兵种技能
    local cskill = D["cs"] or D2["cs"]
    if cskill then
        insert(skillList, cskill)
    end

    -- 隐藏技能
    local hideSkill = D["hideSkill"] or D2["hideSkill"]
    if hideSkill then 
        insert(skillList, hideSkill)
    end

    for _, v in pairs(skillList) do
        if v[1] == 1 then
            skillMap[v[2]] = true
        elseif v[1] == 2 and tab.skillPassive[v[2]] then
            compose = tab.skillPassive[v[2]]["compose"]
            if compose then
                for k = 1, #compose do
                    if compose[k][1] == 1 then
                        skillMap[compose[k][2]] = true
                    end
                end
            end
        end
    end
    return skillMap
end

local function getResFileName(resname)
    local list = string.split(resname, "_")
    return list[#list]
end
-- 统计技能资源
local keyTable1 = {"skillart",
                    "frontstk_v", "frontstk_h", "backstk_v", "backstk_h",
                    "frontimp_v1", "frontimp_h1", "backimp_v1", "backimp_h1", "frontlink1", "backlink1",
                    "frontimp_v2", "frontimp_h2", "backimp_v2", "backimp_h2", "frontlink2", "backlink2",
                    "addfrontstk_v", "addfrontstk_h", "addbackstk_v", "addbackstk_h",}

local keyTable2 = {"frontoat_h", "frontoat_v","backoat_h", "backoat_v", "frontdis_v", "frontdis_h", "backdis_v", "backdis_h",
                    "frontstk_v", "frontstk_h", "backstk_v", "backstk_h",
                    "frontimp_v1", "frontimp_h1", "backimp_v1", "backimp_h1", "frontlink1", "backlink1",
                    "frontimp_v2", "frontimp_h2", "backimp_v2", "backimp_h2", "frontlink2", "backlink2"}
local dieEffName = {nil, "ranshaosiwang", "bingdongsiwang", "dianjisiwang"}
function BattleUtils.countSkillRes(skillid, camp, roleMap, effMap, npcMap, soundTab)
    local skillD = tab.skill[skillid]
    local buffD, totemD
    -- print("skillid ", skillid)
    if skillD == nil then
        print("skillid ", skillid)
        return
    end
    local sk_sound = skillD["sk_sound"]
    if sk_sound then
        for i = 1, #sk_sound do
            soundTab[sk_sound[i][1]] = true
        end   
    end
    -- 自身
    for i = 1, #keyTable1 do
        if skillD[keyTable1[i]] then
            effMap[getResFileName(skillD[keyTable1[i]])] = true
        end
    end
    local quanpingstk = skillD["quanpingstk"]
    if quanpingstk then
        for i = 1, #quanpingstk do
            effMap[getResFileName(quanpingstk[i][1])] = true
        end
    end
    if skillD["dieart"] then
        effMap[dieEffName[skillD["dieart"]]] = true
    end
    
    local buffid
    for i = 1, 2 do
        -- buff
        buffid = skillD["buffid"..i]
        if buffid then
            if BattleUtils.buffReplace[buffid] then
                buffD = tab.skillBuff[BattleUtils.buffReplace[buffid]]
            else
                buffD = tab.skillBuff[buffid]
            end
            if buffD == nil then
                print("buffid ", buffid)
                ViewManager:getInstance():showTip("buff: "..buffid.." 不存在")
            end
            if buffD["buffart"] then
                effMap[getResFileName(buffD["buffart"])] = true
            end
            -- print("buffid ", skillD["buffid"..i])
        end
        -- 召唤
        if skillD["summon"..i] then
            BattleUtils.countNpcRes(skillD["summon"..i], camp, roleMap, effMap, npcMap, soundTab)
        end
    end

    -- 子物体
    if skillD["objectid"] then
        -- print("objectid ", skillD["objectid"])
        totemD = tab.object[skillD["objectid"]]

        local sk_sound = totemD["sk_sound"]
        if sk_sound then
            for i = 1, #sk_sound do
                soundTab[sk_sound[i][1]] = true
            end   
        end
        -- 图腾自身
        for i = 1, #keyTable2 do
            if totemD[keyTable2[i]] then
                effMap[getResFileName(totemD[keyTable2[i]])] = true
            end
        end
        local quanpingstk = totemD["quanpingstk"]
        if quanpingstk then
            for i = 1, #quanpingstk do
                effMap[getResFileName(quanpingstk[i][1])] = true
            end
        end
        if totemD["dieart"] then
            effMap[dieEffName[totemD["dieart"]]] = true
        end
        for i = 1, 2 do
            -- buff
            buffid = totemD["buffid"..i]
            if buffid then
                if BattleUtils.buffReplace[buffid] then
                    buffD = tab.skillBuff[BattleUtils.buffReplace[buffid]]
                else
                    buffD = tab.skillBuff[buffid]
                end
                if buffD["buffart"] then
                    effMap[getResFileName(buffD["buffart"])] = true
                end
                -- print("buffid ", skillD["buffid"..i])
            end
            -- 召唤
            if totemD["summon"..i] then
                BattleUtils.countNpcRes(totemD["summon"..i], camp, roleMap, effMap, npcMap, soundTab)
            end
        end
    end
end

function BattleUtils.countPlayerSkillRes(skillid, camp, roleMap, effMap, npcMap, soundTab, heroSkinD)
    if skillid == 0 then return end
    local skillD = tab.playerSkillEffect[skillid]
    local buffD, totemD
    -- print("skillid ", skillid)
    -- 自身
    local sk_sound = skillD["sk_sound"]
    if sk_sound then
        for i = 1, #sk_sound do
            soundTab[sk_sound[i][1]] = true
        end   
    end
    for i = 1, #keyTable1 do
        if skillD[keyTable1[i]] then
            effMap[getResFileName(skillD[keyTable1[i]])] = true
        end
    end
    local quanpingstk
    if skillD["quanpingstk"] and heroSkinD and heroSkinD["quanpingstk"] and skillD["quanpingstk"..heroSkinD["quanpingstk"]] then
        quanpingstk = skillD["quanpingstk"..heroSkinD["quanpingstk"]]
    else
        quanpingstk = skillD["quanpingstk"]
    end
    if quanpingstk then
        for i = 1, #quanpingstk do
            effMap[getResFileName(quanpingstk[i][1])] = true
        end
    end
    quanpingstk = skillD["quanpingstk_v"]
    if quanpingstk then
        for i = 1, #quanpingstk do
            effMap[getResFileName(quanpingstk[i][1])] = true
        end
    end

    if skillD["dieart"] then
        effMap[dieEffName[skillD["dieart"]]] = true
    end
    local buffid
    for i = 1, 2 do
        -- buff
        buffid = skillD["buffid"..i]
        if buffid then
            if BattleUtils.buffReplace[buffid] then
                buffD = tab.skillBuff[BattleUtils.buffReplace[buffid]]
            else
                buffD = tab.skillBuff[buffid]
            end
            if buffD["buffart"] then
                effMap[getResFileName(buffD["buffart"])] = true
            end
            -- print("buffid ", skillD["buffid"..i])
        end
        -- 召唤
        if skillD["summon"..i] then
            BattleUtils.countNpcRes(skillD["summon"..i], camp, roleMap, effMap, npcMap, soundTab)
        end
    end

    -- 子物体
    if skillD["objectid"] then
        print("objectid ", skillD["objectid"])
        totemD = tab.object[skillD["objectid"]]
        local sk_sound = totemD["sk_sound"]
        if sk_sound then
            for i = 1, #sk_sound do
                soundTab[sk_sound[i][1]] = true
            end   
        end
        -- 图腾自身
        for i = 1, #keyTable2 do
            if totemD[keyTable2[i]] then
                effMap[getResFileName(totemD[keyTable2[i]])] = true
            end
        end
        local quanpingstk = totemD["quanpingstk"]
        if quanpingstk then
            for i = 1, #quanpingstk do
                effMap[getResFileName(quanpingstk[i][1])] = true
            end
        end
        if totemD["dieart"] then
            effMap[dieEffName[totemD["dieart"]]] = true
        end
        for i = 1, 2 do
            -- buff
            buffid = totemD["buffid"..i]
            if buffid then
                if BattleUtils.buffReplace[buffid] then
                    buffD = tab.skillBuff[BattleUtils.buffReplace[buffid]]
                else
                    buffD = tab.skillBuff[buffid]
                end
                if buffD["buffart"] then
                    effMap[getResFileName(buffD["buffart"])] = true
                end
                -- print("buffid ", skillD["buffid"..i])
            end
            -- 召唤
            if totemD["summon"..i] then
                BattleUtils.countNpcRes(totemD["summon"..i], camp, roleMap, effMap, npcMap, soundTab)
            end
        end
    end
end
local AnimAP = require "base.anim.AnimAP"
-- 统计team资源
function BattleUtils.countTeamRes(teamid, skillLevel, camp, roleMap, effMap, npcMap, soundTab)
    -- print("teamid", teamid)
    local jx = teamid > JX_ID_ADD
    local teamD = tab.team[teamid % JX_ID_ADD]
    if jx then
        -- 觉醒
        if AnimAP["mcList"][teamD["jxart"]] then
            effMap[teamD["jxart"]] = true
        else
            if roleMap[teamD["jxart"]] == nil then 
                roleMap[teamD["jxart"]] = camp
            elseif camp ~= roleMap[teamD["jxart"]] then
                roleMap[teamD["jxart"]] = 3
            end
        end     
    else
        if AnimAP["mcList"][teamD["art"]] then
            effMap[teamD["art"]] = true
        else
            if roleMap[teamD["art"]] == nil then 
                roleMap[teamD["art"]] = camp
            elseif camp ~= roleMap[teamD["art"]] then
                roleMap[teamD["art"]] = 3
            end
        end
    end
    if teamD["boom1"] then
        effMap[getResFileName(teamD["boom1"])] = true
    end

    local skillMap = BattleUtils.getSkillMap(teamD, skillLevel, jx)
    for skillid, _ in pairs(skillMap) do
        BattleUtils.countSkillRes(skillid, camp, roleMap, effMap, npcMap, soundTab)
    end
end

-- 统计npc资源
function BattleUtils.countNpcRes(npcid, camp, roleMap, effMap, npcMap, soundTab)
    npcMap[npcid] = true
    -- print("npcid", npcid)
    local npcD = tab.npc[npcid]
    if npcD == nil then
        ViewManager:getInstance():onLuaError("cannot found npc id = " .. npcid)
        return
    end
    if AnimAP["mcList"][npcD["art"]] then
        effMap[npcD["art"]] = true
    else
        if roleMap[npcD["art"]] == nil then
            roleMap[npcD["art"]] = camp
        elseif camp ~= roleMap[npcD["art"]] then
            roleMap[npcD["art"]] = 3
        end
    end
    if npcD["boom1"] then
        effMap[getResFileName(npcD["boom1"])] = true
    end

    local skillMap = BattleUtils.getSkillMap(npcD, npcD["sl"])
    for skillid, _ in pairs(skillMap) do
        BattleUtils.countSkillRes(skillid, camp, roleMap, effMap, npcMap, soundTab)
    end
end

-- 统计英雄给怪兽追加的技能
function BattleUtils.countHeroTeamSkill(values, teamIdMap, npcIdMap, roleMap, effMap, npcMap, soundTab, camp)
    local teamDs = {}
    local _teamid
    for teamid, _camp in pairs(teamIdMap) do
        _teamid = JX_ID_ADD % teamid
        if _camp == camp then
            teamDs[_teamid] = tab.team[_teamid]
        end
    end
    local npcDs = {}
    for npcid, _camp in pairs(npcIdMap) do
        if _camp == camp then
            npcDs[npcid] = tab.npc[npcid]
        end
    end
    local skillMap = {}
    local _skills
    local skills = values.monsterSkill
    local _v
    for _, teamD in pairs(teamDs) do
        _v = teamD["volume"] - 1
        if _v > 4 then
            _v = 4
        end
        if _v < 1 then
            _v = 1
        end
        _skills = skills[teamD["movetype"]][teamD["class"]][_v]
        if _skills then
            for id, _type in pairs(_skills) do
                if _type == 1 then
                    skillMap[id] = true
                end
            end
        end
    end
    for _, npcD in pairs(npcDs) do
        _v = npcD["volume"]
        if _v == nil then
            _v = tab.team[npcD["match"]]["volume"]
        end
        _v = _v - 1
        if _v > 4 then
            _v = 4
        end
        if _v < 1 then
            _v = 1
        end
        _skills = skills[npcD["mot"]][npcD["class"]][_v]
        if _skills then
            for id, _type in pairs(_skills) do
                if _type == 1 then
                    skillMap[id] = true
                end
            end
        end
    end

    local skills = values.monsterSkill1
    for _, teamD in pairs(teamDs) do
        _skills = skills[teamD["label1"]]
        if _skills then
            for id, _type in pairs(_skills) do
                if _type == 1 then
                    skillMap[id] = true
                end
            end
        end
    end 
    for _, npcD in pairs(npcDs) do
        _skills = skills[npcD["label1"]]
        if _skills then
            for id, _type in pairs(_skills) do
                if _type == 1 then
                    skillMap[id] = true
                end
            end
        end
    end

    local skills = values.monsterSkill2
    for id, _type in pairs(skills) do
        if _type == 1 then
            skillMap[id] = true
        end
    end 

    local skills = values.monsterSkill3
    for _, teamD in pairs(teamDs) do
        _skills = skills[teamD["id"]]
        if _skills then
            for id, _type in pairs(_skills) do
                if _type == 1 then
                    skillMap[id] = true
                end
            end
        end
    end 

    local skills = values.monsterSkill4
    local condi, param, _type, add
    for id, info in pairs(skills) do
        condi, param, _type = info[1], info[2], info[3]
        add = false
        if condi == 0 then
            add = true
        elseif condi == 1 then
            add = (teamIdMap[param] ~= nil or teamIdMap[JX_ID_ADD + param] ~= nil)
        end
        if add and _type == 1 then
            skillMap[id] = true
        end
    end

    -- 统计学院大招和失败所用的特效
    if values.hinder > 0 then
        effMap["shifangfashushibai"] = true
    end
    if values.MGTPro[1] > 0 or values.MGTPro[2] > 0 or values.MGTPro[4] > 0 then
        effMap["jinengshifangtishi"] = true
    end

    for skillid, _ in pairs(skillMap) do
        BattleUtils.countSkillRes(skillid, camp, roleMap, effMap, npcMap, soundTab)
    end

    -- 宝物特效
    if #values.treasureEff > 0 then
        for i = 1, #values.treasureEff do
            local treasureEff = values.treasureEff[i]
            local comTreasureD = tab.comTreasure[treasureEff]
            if comTreasureD["frontstk_v"] then effMap[getResFileName(comTreasureD["frontstk_v"])] = true end
            if comTreasureD["frontstk_h"] then effMap[getResFileName(comTreasureD["frontstk_h"])] = true end
            if comTreasureD["backstk_v"] then effMap[getResFileName(comTreasureD["backstk_v"])] = true end
            if comTreasureD["backstk_h"] then effMap[getResFileName(comTreasureD["backstk_h"])] = true end
        end
    end
end

function BattleUtils.ResCount(teamIdMap, teamSkillLevel, npcIdMap, playerInfo, enemyInfo, battleMode)
    local EX = require("game.view.battle.rule.BattleResEx")
    local heroInfo1 = playerInfo.hero
    local heroInfo2 = enemyInfo.hero
    local teamEx, npcEx, effEx = EX.teamEx, EX.npcEx, EX.effEx
    local teams = teamEx[battleMode]
    if teams then
        for i = 1, #teams do
            local id = teams[i][1]
            local camp = teams[i][2]
            if teamIdMap[id] and camp ~= teamIdMap[id] then
                teamIdMap[id] = 3
            else
                teamIdMap[id] = camp
            end
        end    
    end
    local npcs = npcEx[battleMode]
    if npcs then
        for i = 1, #npcs do
            npcIdMap[npcs[i][1]] = npcs[i][2]
        end
    end
    local roleMap = {}
    local effMap = {}
    local picMap = {}
    local npcMap = {}
    local soundTab = {}
    local teamD
    for teamid, camp in pairs(teamIdMap) do
        teamD = tab.team[teamid % JX_ID_ADD]
        if teamD["atksound"] then
            soundTab[teamD["atksound"]] = true
        end
        if teamD["deathsound"] then
            soundTab[teamD["deathsound"]] = true
        end
        if teamD["permsound"] then
            local permsound = teamD["permsound"]
            if permsound[1] == 1 then
                soundTab[permsound[2]] = true
            else
                -- team.sound_random = permsound[2]
            end
        end
        if teamD["movesound"] then
            local movesound = teamD["movesound"]
            if type(movesound) == "table" then

            else
                soundTab[movesound] = true
            end
        end

        BattleUtils.countTeamRes(teamid, teamSkillLevel[teamid], camp, roleMap, effMap, npcMap, soundTab)
    end
    for npcid, camp in pairs(npcIdMap) do
        BattleUtils.countNpcRes(npcid, camp, roleMap, effMap, npcMap, soundTab)
    end
    -- 我方英雄资源
    local heroSkinD1
    if heroInfo1.skin then
        heroSkinD1 = tab.heroSkin[heroInfo1.skin]
    end

    local heroD, values
    if heroInfo1.npcHero then
        heroD = tab.npcHero[heroInfo1.id]
        values = BattleUtils.getNpcHeroBaseAttr(heroD)
        for i = 1, #values.skills do
            BattleUtils.countPlayerSkillRes(values.skills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
        end
        for i = 1, #values.openSkills do
            BattleUtils.countPlayerSkillRes(values.openSkills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
        end
        for i = 1, #values.autoSkills do
            BattleUtils.countPlayerSkillRes(values.autoSkills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
        end
        for i = 1, #values.weaponSkills do
            BattleUtils.countPlayerSkillRes(values.weaponSkills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
        end
    else
        heroD = tab.hero[heroInfo1.id]
        values = BattleUtils.getHeroBaseAttr(heroD, heroInfo1.level, heroInfo1.slevel, heroInfo1.star, 
                                                    heroInfo1.mastery, playerInfo.globalMasterys, playerInfo.treasure, nil, playerInfo.talent,
                                                    heroInfo1.hAb, heroInfo1.uMastery, heroInfo1.skillex, playerInfo.weapons,
                                                    true,nil,nil,nil,playerInfo.qhab,heroInfo1.sc,playerInfo.hStar)
        -- 技能开放
        local userModel = ModelManager:getInstance():getModel("UserModel")
        local skillOpen = userModel:getSkillOpen()
        if skillOpen then
            local _open = {false, false, false, false, false, false}
            if BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_Guide then
                _open[1] = true
                _open[2] = true
                _open[4] = true
            elseif BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_Arena 
                or BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_ServerArena
                or BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_GuildPVP
                or BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_GodWar then
                for i = 1, #_open do
                    _open[i] = true
                end
            else
                for i = 1, #_open do
                    if skillOpen[tostring(i)] == 1 then
                        _open[i] = true
                    end
                end
            end
            for i = 1, #values.skills do
                if _open[i] then
                    BattleUtils.countPlayerSkillRes(values.skills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
                    -- 添加额外技能的资源统计
                    if values.skills[i][5] then
                        for k = 1, #values.skills[i][5] do
                            BattleUtils.countPlayerSkillRes(values.skills[i][5][k], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
                        end
                    end
                end
            end
        else
            for i = 1, #values.skills do
                BattleUtils.countPlayerSkillRes(values.skills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
                -- 添加额外技能的资源统计
                if values.skills[i][5] then
                    for k = 1, #values.skills[i][5] do
                        BattleUtils.countPlayerSkillRes(values.skills[i][5][k], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
                    end
                end
            end
        end
        for i = 1, #values.openSkills do
            BattleUtils.countPlayerSkillRes(values.openSkills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
        end
        for i = 1, #values.autoSkills do
            BattleUtils.countPlayerSkillRes(values.autoSkills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
        end
        for i = 1, #values.weaponSkills do
            BattleUtils.countPlayerSkillRes(values.weaponSkills[i][1], 1, roleMap, effMap, npcMap, soundTab, heroSkinD1)
        end
    end
    if values.revivePro then
        effMap["fuhuo"] = true
    end
    BattleUtils.countHeroTeamSkill(values, teamIdMap, npcIdMap, roleMap, effMap, npcMap, soundTab, 1)

    if heroSkinD1 then
        if heroSkinD1["heroart"] then
            effMap[heroSkinD1["heroart"]] = true
        elseif heroD["heroart"] then
            effMap[heroD["heroart"]] = true
        end
        if heroSkinD1["halfcut"] then
            picMap[heroSkinD1["halfcut"]] = true
        elseif heroD["halfcut"] then
            picMap[heroD["halfcut"]] = true
        end
    else
        if heroD["heroart"] then
            effMap[heroD["heroart"]] = true
        end
        if heroD["halfcut"] then
            picMap[heroD["halfcut"]] = true
        end
    end

    -- 敌方英雄资源
    local heroSkinD2
    if heroInfo2.skin then
        heroSkinD2 = tab.heroSkin[heroInfo2.skin]
    end

    local heroD, values
    if heroInfo2.npcHero then
        heroD = tab.npcHero[heroInfo2.id]
        values = BattleUtils.getNpcHeroBaseAttr(heroD)
    else
        heroD = tab.hero[heroInfo2.id]
        values = BattleUtils.getHeroBaseAttr(heroD, 
            heroInfo2.level, 
            heroInfo2.slevel, 
            heroInfo2.star, 
            heroInfo2.mastery, 
            enemyInfo.globalMasterys, 
            enemyInfo.treasure, 
            nil, 
            enemyInfo.talent,
            heroInfo2.hAb, 
            heroInfo2.uMastery,
            heroInfo2.skillex,
            enemyInfo.weapons,
            true,
            nil,
            nil,
            nil,
            enemyInfo.qhab,
            heroInfo2.sc,
            enemyInfo.hStar)
    end
    if values.revivePro then
        effMap["fuhuo"] = true
    end
    BattleUtils.countHeroTeamSkill(values, teamIdMap, npcIdMap, roleMap, effMap, npcMap, soundTab, 2)
    for i = 1, #values.skills do
        BattleUtils.countPlayerSkillRes(values.skills[i][1], 2, roleMap, effMap, npcMap, soundTab, heroSkinD2)
        -- 添加额外技能的资源统计
        if values.skills[i][5] then
            for k = 1, #values.skills[i][5] do
                BattleUtils.countPlayerSkillRes(values.skills[i][5][k], 2, roleMap, effMap, npcMap, soundTab, heroSkinD2)
            end
        end
    end
    for i = 1, #values.openSkills do
        BattleUtils.countPlayerSkillRes(values.openSkills[i][1], 2, roleMap, effMap, npcMap, soundTab, heroSkinD2)
    end
    for i = 1, #values.autoSkills do
        BattleUtils.countPlayerSkillRes(values.autoSkills[i][1], 2, roleMap, effMap, npcMap, soundTab, heroSkinD2)
    end
    for i = 1, #values.weaponSkills do
        BattleUtils.countPlayerSkillRes(values.weaponSkills[i][1], 2, roleMap, effMap, npcMap, soundTab, heroSkinD2)
    end
    if heroSkinD2 then
        if heroSkinD2["heroart"] then
            effMap[heroSkinD2["heroart"]] = true
        elseif heroD["heroart"] then
            effMap[heroD["heroart"]] = true
        end
        if heroSkinD2["halfcut"] then
            picMap[heroSkinD2["halfcut"]] = true
        elseif heroD["halfcut"] then
            picMap[heroD["halfcut"]] = true
        end
    else
        if heroD["heroart"] then
            effMap[heroD["heroart"]] = true
        end
        if heroD["halfcut"] then
            picMap[heroD["halfcut"]] = true
        end
    end


    local roles = {}
    for k, v in pairs(roleMap) do
        table.insert(roles, {k, v})
    end

    local effex = effEx[battleMode]
    if effex then
        for i = 1, #effex do
            if type(effex[i]) == "table" then
                for k, v in pairs(effex[i]) do
                    effMap[k] = true
                end
            else
                effMap[effex[i]] = true
            end
        end
    end
    local effs = {}
    for k, v in pairs(effMap) do
        table.insert(effs, k)
    end

    return roles, effs, picMap, npcMap, soundTab
end

BattleUtils.weatherTab = 
{
    dulongxue1 = "yinqi",
    gebi1 = "shamo",
    gebi2 = "shamo",
    muyuan1 = "yinqi", 
    muyuan2 = "yinqi", 
    pingyuan1 = "xiayu", 
    pingyuan2 = "xiayu", 
    shamo1 = "shamo",
    shamo2 = "shamo",
    shandi1 = "xiayu", 
    shatan1 = "xiayu", 
    zhaoze1 = "yinqi", 
    zhaoze2 = "yinqi", 
    yaosai1 = "xiayu", 
    xueyuan1 = "xiaxue",
    xueyuan2 = "xiaxue",
}

function BattleUtils.getBattleRes(battleInfo)
    local teamIdMap = {} -- 1为左方 2为右方
    local npcIdMap = {} 

    local teamSkillLevel = {}

    local buffReplace = {}
    -- 英雄专精替换怪兽
    local playerInfo = battleInfo.playerInfo
    -- dump(battleInfo, "a", 20)
    local teams = playerInfo.team
    if teams then
        local hero = playerInfo.hero
        local heroD, star, mastery
        if playerInfo.hero.npcHero then
            heroD = tab.npcHero[hero.id]
            mastery = {}
            for i = 1, 5 do
                if heroD["m"..i] == nil then
                    break
                end
                mastery[i] = heroD["m"..i]
            end
            star = heroD["herostar"]
        else
            heroD = tab.hero[hero.id]
            star = hero.star
            mastery = hero.mastery
        end
        local masterys = BattleUtils.getHeroMasterys(heroD, star, mastery, playerInfo.globalMasterys, 
                                                    BattleUtils.getHerotreasureMasterys(playerInfo.treasure), playerInfo.hero.uMastery, playerInfo.hero.skillex,BattleUtils.getHeroStarChatsMastery(playerInfo.hero.sc,playerInfo.hStar))
        local teamReplace = {}
        local masteryD, creplace, ids, idd, breplace
        for i = 1, #masterys do
            masteryD = tab.heroMastery[masterys[i][1]]
            creplace = masteryD["creplace"] 
            if masteryD["crehero"] == nil or masteryD["crehero"] == hero.id then
                if creplace then
                    for k = 1, #creplace do
                        local oid = creplace[k][1]
                        local nid = creplace[k][2]
                        -- A->B B->C
                        -- 如果A已经变成B, 后面对A的变化均无效
                        for id1, id2 in pairs(teamReplace) do
                            if id2 == oid then
                                teamReplace[id1] = nid
                            end
                        end
                        if teamReplace[oid] == nil then
                            teamReplace[oid] = nid
                        end
                    end
                end
            end
            -- buff替换
            breplace = masteryD["breplace"] 
            if breplace then
                for k = 1, #breplace do
                    buffReplace[breplace[k][1]] = breplace[k][2]
                end
            end
        end
        local id
        local _team
        local isReplace
        for i = 1, #teams do
            _team = teams[i]
            if teamReplace[_team.id] then
                id = teamReplace[_team.id]
            else
                id = _team.id
            end
            if _team.jx then
                -- 觉醒
                id = JX_ID_ADD + id
            end
            teamIdMap[id] = 1
            if teamSkillLevel[id] == nil then
                teamSkillLevel[id] = {0, 0, 0, 0}
            end
            for k = 1, #_team.skill do
                if _team.skill[k] > teamSkillLevel[id][k] then
                    teamSkillLevel[id][k] = _team.skill[k]
                end
            end
            if _team.jx then
                if teamSkillLevel[id].jxSkill == nil then
                    teamSkillLevel[id].jxSkill = {_team.jxSkill1, _team.jxSkill2, _team.jxSkill3}
                else
                    local lv1 = teamSkillLevel[id].jxSkill[1]
                    local lv2 = teamSkillLevel[id].jxSkill[2]
                    local lv3 = teamSkillLevel[id].jxSkill[3]
                    if lv1 == nil then
                        lv1 = _team.jxSkill1
                    elseif lv1 ~= 3 and _team.jxSkill1 and lv1 ~= _team.jxSkill1 then
                        lv1 = 3
                    end
                    if lv2 == nil then
                        lv2 = _team.jxSkill2
                    elseif lv2 ~= 3 and _team.jxSkill2 and lv2 ~= _team.jxSkill2 then
                        lv2 = 3
                    end
                    if lv3 == nil then
                        lv3 = _team.jxSkill3
                    elseif lv3 ~= 3 and _team.jxSkill3 and lv3 ~= _team.jxSkill3 then
                        lv3 = 3
                    end
                    teamSkillLevel[id].jxSkill = {lv1, lv2, lv3}
                end
            end
        end
    end
    local enemyInfo = battleInfo.enemyInfo
    local teams = enemyInfo.team
    if teams then
        local hero = enemyInfo.hero
        local heroD, star, mastery
        -- dump(enemyInfo.hero,"a",2)
        if enemyInfo.hero.npcHero then
            heroD = tab.npcHero[hero.id]
            mastery = {}
            for i = 1, 5 do
                if heroD["m"..i] == nil then
                    break
                end
                mastery[i] = heroD["m"..i]
            end
            star = heroD["herostar"]
        else
            heroD = tab.hero[hero.id]
            star = hero.star
            mastery = hero.mastery
        end
        local masterys = BattleUtils.getHeroMasterys(heroD, star, mastery, enemyInfo.globalMasterys, 
                                                     BattleUtils.getHerotreasureMasterys(enemyInfo.treasure), enemyInfo.hero.uMastery, enemyInfo.hero.skillex)
        local teamReplace = {}
        local masteryD, creplace, ids, idd, breplace
        for i = 1, #masterys do
            masteryD = tab.heroMastery[masterys[i][1]]
            creplace = masteryD["creplace"] 
            if masteryD["crehero"] == nil or masteryD["crehero"] == hero.id then
                if creplace then
                    for k = 1, #creplace do
                        teamReplace[creplace[k][1]] = creplace[k][2]
                    end
                end
            end
            -- buff替换
            breplace = masteryD["breplace"] 
            if breplace then
                for k = 1, #breplace do
                    buffReplace[breplace[k][1]] = breplace[k][2]
                end
            end
        end
        local id, _team
        for i = 1, #teams do
            _team = teams[i]
            if teamReplace[_team.id] then
                id = teamReplace[_team.id]
            else
                id = _team.id
            end
            if _team.jx then
                -- 觉醒
                if teamIdMap[JX_ID_ADD + id] == 1 then
                    teamIdMap[JX_ID_ADD + id] = 3
                elseif teamIdMap[JX_ID_ADD + id] ~= 3 then
                    teamIdMap[JX_ID_ADD + id] = 2
                end      
            else
                if teamIdMap[id] == 1 then
                    teamIdMap[id] = 3
                elseif teamIdMap[id] ~= 3 then
                    teamIdMap[id] = 2
                end
            end
            if teamSkillLevel[id] == nil then
                teamSkillLevel[id] = {0, 0, 0, 0}
            end
            for k = 1, #_team.skill do
                if _team.skill[k] > teamSkillLevel[id][k] then
                    teamSkillLevel[id][k] = _team.skill[k]
                end
            end
        end
    end
    local npcs = playerInfo.npc
    if npcs then
        for i = 1, #npcs do
            npcIdMap[npcs[i][1]] = 1
        end
    end
    local npcs = enemyInfo.npc
    if npcs then
        for i = 1, #npcs do
            npcIdMap[npcs[i][1]] = 2
        end
    end
    -- 攻城战的弓箭手资源
    if battleInfo.siegeId then
        local camp = battleInfo.siegeReverse and 1 or 2
        local siegeD = tab.siege[battleInfo.siegeId]
        if siegeD["arrowid"] then
            for i = 1, #siegeD["arrowid"] do
                npcIdMap[siegeD["arrowid"][i]] = camp
            end
        end
        if siegeD["pylonid"] then
            for i = 1, #siegeD["pylonid"] do
                npcIdMap[siegeD["pylonid"][i]] = camp
            end
        end
    end

    -- 副本助战
    if battleInfo.assist then
        -- NPC
        local intanceD = battleInfo.intanceD
        for i = 1, 8 do
            if intanceD["hm"..i] then
                npcIdMap[intanceD["hm"..i][1]] = 1
            else
                break
            end
        end
    end

    if battleInfo.intanceD then
        -- 援助2.0
        local intanceD = battleInfo.intanceD 
        if intanceD["help1"] then
            for i = 2, #intanceD["help1"] do
                npcIdMap[intanceD["help1"][i][1]] = 1
            end
        end
        if intanceD["help2"] then
            for i = 2, #intanceD["help2"] do
                npcIdMap[intanceD["help2"][i][1]] = 2
            end
        end
    end

    -- 云中城助战
    if battleInfo.mode == BattleUtils.BATTLE_TYPE_CloudCity then
        local cctD = battleInfo.cctD
        if battleInfo.cctAssist then
            -- NPC
            local camp = cctD["helpObject"]
            for i = 1, 8 do
                if cctD["hm"..i] then
                    npcIdMap[cctD["hm"..i][1]] = camp
                else
                    break
                end
            end
        end
        for b = 1, 4 do
            local data = cctD["b"..b]
            if data then
                for i = 1, #data do
                    npcIdMap[data[i][1]] = 2
                end
            end
        end
    end

    BattleUtils.buffReplace = buffReplace
    local roles, effs, picMap, npcMap, soundTab = BattleUtils.ResCount(teamIdMap, teamSkillLevel, npcIdMap, battleInfo.playerInfo, battleInfo.enemyInfo, battleInfo.mode)

    local checkValue
    if not BATTLE_PROC and GameStatic.checkTable and battleInfo.mode ~= BattleUtils.BATTLE_TYPE_Guide then
        local heroMap = {}
        local npcHeroMap = {}
        if battleInfo.playerInfo.hero.npcHero then
            npcHeroMap[battleInfo.playerInfo.hero.id] = true
        else
            heroMap[battleInfo.playerInfo.hero.id] = true
        end
        if battleInfo.enemyInfo.hero.npcHero then
            npcHeroMap[battleInfo.enemyInfo.hero.id] = true
        else
            heroMap[battleInfo.enemyInfo.hero.id] = true
        end
        local intanceD, branchD
        
        if not battleInfo.isBranch then
            intanceD = battleInfo.intanceD
        else
            branchD = battleInfo.intanceD
        end
        checkValue = {clone(teamIdMap), clone(npcMap), clone(heroMap), clone(npcHeroMap), intanceD, branchD, battleInfo.cctD, battleInfo.siegeId}
    end

    BattleUtils.buffReplace = nil
    effs[#effs + 1] = "quanjunchuji" --1024
    effs[#effs + 1] = "guochang" --1024
    effs[#effs + 1] = "commoncast" --512
    effs[#effs + 1] = "skillarea"  --512
    
    -- 城墙摧毁特效
    if battleInfo.siegeId then
        local cqchEffTab = 
        {
            ["chengbao"] = "cqchchengbao",
            ["chengbaor"] = "cqchchengbao",
            ["bilei"] = "cqchbilei",
            ["yaosai"] = "cqchbilei",
            ["muyuan"] = "cqchmuyuan",
            ["diyu"] = "cqchmuyuan",
            ["judian"] = "cqchbilei",
            ["talou"] = "cqchchengbao",
            ["dixiacheng"] = "cqchbilei",
        }
        local siegeD = tab.siege[battleInfo.siegeId]
        effs[#effs + 1] = cqchEffTab[siegeD["art"]]
        effs[#effs + 1] = "shiqieff" --512
        if siegeD["moatattrObject"] and battleInfo.mode >= BattleUtils.BATTLE_TYPE_Siege_Atk and battleInfo.mode <= BattleUtils.BATTLE_TYPE_Siege_Def_WE then
            -- 护城河动画
            local cqchTotemTab = 
            {
                ["chengbao"] = "huchenghechengbao",
                ["chengbaor"] = "huchenghechengbao",
                ["bilei"] = "huchenghebilei",
                ["muyuan"] = "huchenghemuyuan",
                ["diyu"] = "huchenghediyu",
            }
            effs[#effs + 1] = cqchEffTab[siegeD["art"]]
        end
    end

    -- 副本助战
    if battleInfo.assist then
        local intanceD = battleInfo.intanceD
        if intanceD["helpType"] == 1 then
            if intanceD["helpEffect"] == 1 then
                -- 复活
                effs[#effs + 1] = "fuhuo"
            end
        end
    end

    -- 云中城助战
    if battleInfo.mode == BattleUtils.BATTLE_TYPE_CloudCity then
        local cctD = battleInfo.cctD
        if battleInfo.cctAssist then
            if cctD["helpEffect"] and cctD["helpEffect"] <= 2 then
                effs[#effs + 1] = "fuhuo"
            end
        end
        if cctD["doorPo"] and #cctD["doorPo"] > 0 then
            effs[#effs + 1] = "ccchuansongmen"
        end
        if cctD["trap"] and #cctD["trap"] > 0 then
            effs[#effs + 1] = "ccxianjing"
        end
        -- 范围帐篷
        if cctD["tar1"] then
            for i = 1, #cctD["tar1"] do
                if cctD["tar1"][i][1] == 10 then
                    effs[#effs + 1] = "fanweihuixue"
                    break
                end
            end
        end

        -- 范围魔法塔
        if cctD["tar2"] then
            for i = 1, #cctD["tar2"] do
                if cctD["tar2"][i][1] == 10 then
                    effs[#effs + 1] = "dianquan"
                    break
                end
            end
        end
    end

    -- 攻城器械资源
    local weapons1 = battleInfo.playerInfo.weapons
    local weapons2 = battleInfo.enemyInfo.weapons
    local siegeWeaponD
    for i = 1, 3 do
        if weapons1 and weapons1[i] then
            siegeWeaponD = tab.siegeWeapon[weapons1[i].id]
            effs[#effs + 1] = siegeWeaponD["steam"]
        end
        if weapons2 and weapons2[i] then
            siegeWeaponD = tab.siegeWeapon[weapons2[i].id]
            effs[#effs + 1] = siegeWeaponD["steam"]
        end
    end

    -- 地图场景资源
    local mapRes = "asset/map/" .. battleInfo.mapId .. "/" .. battleInfo.mapId
    local maps = {
                    mapRes.."_land.jpg",
                    mapRes.."_fg.png", 
                    mapRes.."_mg.png", 
                    mapRes.."_far.png",
                    mapRes.."_bg.jpg"
                }

    -- 天气资源
    local battleWeather = SystemUtils.loadGlobalLocalData("battleWeather")
    if battleWeather == nil then
        SystemUtils.saveGlobalLocalData("battleWeather", 1)
    end
    battleWeather = SystemUtils.loadGlobalLocalData("battleWeather")

    if battleWeather == 1 then
        if BattleUtils.weatherTab[battleInfo.mapId] then
            effs[#effs + 1] = BattleUtils.weatherTab[battleInfo.mapId]
        end
        if battleInfo.mode == BattleUtils.BATTLE_TYPE_CloudCity then
            effs[#effs + 1] = battleInfo.weather
        end
    end

    maps[#maps + 1] = "asset/fnt/hud_yellow.png"
    maps[#maps + 1] = "asset/fnt/hud_green.png"
    maps[#maps + 1] = "asset/fnt/hud_red.png"
    maps[#maps + 1] = "asset/fnt/hud_sp.png"

    for k, v in pairs(picMap) do
        maps[#maps + 1] = "asset/uiother/hero/" .. k .. ".png"
    end
    if battleInfo.mode == BattleUtils.BATTLE_TYPE_BOSS_DuLong then
        maps[#maps + 1] = "asset/uiother/hero/half_Dulong.png"
    elseif battleInfo.mode == BattleUtils.BATTLE_TYPE_BOSS_XnLong then
        maps[#maps + 1] = "asset/uiother/hero/half_Xiannvlong.png"
    elseif battleInfo.mode == BattleUtils.BATTLE_TYPE_BOSS_SjLong then
        maps[#maps + 1] = "asset/uiother/hero/half_Shuijinglong.png"
    end
    local plists = {}
    plists[#plists + 1] = {"asset/role/shadow.plist", "asset/role/shadow.png"}
    plists[#plists + 1] = {"asset/role/bullet.plist", "asset/role/bullet.png"}

    -- soundTab["war_start"] = true
    -- soundTab["war_render"] = true
    
    -- dump(roles)
    -- dump(effs)
    -- dump(maps)
    -- 1 texture
    -- 2 plist
    -- 3 send
    -- 4 mc
    -- 5 sf
    -- 6 table
    -- 7 sound
    local loadingList = {}
    for i = 1, #roles do
        loadingList[#loadingList + 1] = {5, roles[i]}
    end
    for i = 1, #effs do
        loadingList[#loadingList + 1] = {4, effs[i]}
    end
    for i = 1, #maps do
        loadingList[#loadingList + 1] = {1, maps[i]}
    end
    for i = 1, #plists do
        loadingList[#loadingList + 1] = {2, plists[i]}
    end
    for k, v in pairs(soundTab) do
        loadingList[#loadingList + 1] = {7, k}
    end
    for k, v in pairs(npcIdMap) do
        if tab.npc[k]["loading"] then
            teamIdMap[tab.npc[k]["loading"]] = 1
        end
    end
    local teamIdArr = {}
    local raceMap = {}
    local _teamID
    for k, v in pairs(teamIdMap) do
        _teamID = k % JX_ID_ADD
        if tab.team[_teamID] and tab.team[_teamID].show1 == 1 then
            teamIdArr[#teamIdArr + 1] = _teamID 
        end
        raceMap[tab.team[_teamID].race[1]] = 1
    end
    local raceArr = {}
    for k, v in pairs(raceMap) do
        raceArr[#raceArr + 1] = k
    end 
    
    return loadingList, teamIdArr[GRandom(#teamIdArr)], raceArr[GRandom(#raceArr)], checkValue
end

function BattleUtils.playBattleMusic(mode, isElite)
    if mode == BattleUtils.BATTLE_TYPE_BOSS_DuLong
        or mode == BattleUtils.BATTLE_TYPE_BOSS_XnLong 
        or mode == BattleUtils.BATTLE_TYPE_BOSS_SjLong then
        audioMgr:playMusic("bossBgm", true)
    elseif mode == BattleUtils.BATTLE_TYPE_AiRenMuWu then
        audioMgr:playMusic("cryptBgm", true)
    elseif mode == BattleUtils.BATTLE_TYPE_Zombie then
        audioMgr:playMusic("cryptBgm", true)
    elseif mode == BattleUtils.BATTLE_TYPE_Siege 
        or mode == BattleUtils.BATTLE_TYPE_CCSiege
        or mode == BattleUtils.BATTLE_TYPE_Siege_Atk
        or mode == BattleUtils.BATTLE_TYPE_Siege_Def
        or mode == BattleUtils.BATTLE_TYPE_Siege_Atk_WE
        or mode == BattleUtils.BATTLE_TYPE_Siege_Def_WE then
        audioMgr:playMusic("siegeBgm", true)
    elseif mode == BattleUtils.BATTLE_TYPE_Arena
        or mode == BattleUtils.BATTLE_TYPE_ServerArena 
        or mode == BattleUtils.BATTLE_TYPE_GodWar then
        audioMgr:playMusic("siegeBgm", true)
    elseif mode == BattleUtils.BATTLE_TYPE_Fuben or mode == BattleUtils.BATTLE_TYPE_ServerArenaFuben then
        if isElite then
            audioMgr:playMusic("bgm2", true)
        else
            audioMgr:playMusic("bgm", true)
        end
    elseif mode == BattleUtils.BATTLE_TYPE_Guide then
        audioMgr:playMusic("siegeBgm", true)
    else
        audioMgr:playMusic("bgm", true)
    end
end

function BattleUtils.playExitBattleMusic(mode, subType, isElite)
    if mode == BattleUtils.BATTLE_TYPE_BOSS_DuLong
        or mode == BattleUtils.BATTLE_TYPE_BOSS_XnLong 
        or mode == BattleUtils.BATTLE_TYPE_BOSS_SjLong then
        audioMgr:playMusic("mainmenu", true)
    elseif mode == BattleUtils.BATTLE_TYPE_AiRenMuWu then
        audioMgr:playMusic("mainmenu", true)
    elseif mode == BattleUtils.BATTLE_TYPE_Zombie then
        audioMgr:playMusic("mainmenu", true)
    elseif mode == BattleUtils.BATTLE_TYPE_Siege then
        if subType == BattleUtils.BATTLE_TYPE_Fuben or subType == BattleUtils.BATTLE_TYPE_ServerArenaFuben then
            audioMgr:playMusic("campaign", true)
        elseif subType == BattleUtils.BATTLE_TYPE_Crusade then
            audioMgr:playMusic("mainmenu", true)
        end
    elseif mode == BattleUtils.BATTLE_TYPE_CCSiege then
        audioMgr:playMusic("mainmenu", true)
    elseif mode == BattleUtils.BATTLE_TYPE_Arena 
        or mode == BattleUtils.BATTLE_TYPE_ServerArena
        or mode == BattleUtils.BATTLE_TYPE_GodWar then
        audioMgr:playMusic("mainmenu", true)
    elseif mode == BattleUtils.BATTLE_TYPE_Fuben or mode == BattleUtils.BATTLE_TYPE_ServerArenaFuben then
        if isElite then
            audioMgr:playMusic("dungeon", true)
        else
            audioMgr:playMusic("campaign", true)
        end
    elseif mode == BattleUtils.BATTLE_TYPE_Guide then
        -- audioMgr:playMusic("mainmenu", true)
    else
        audioMgr:playMusic("mainmenu", true)
    end
end

function BattleUtils.getSkillDescription(skillid, hero, level, desc)
    local userlvl = ModelManager:getInstance():getModel("UserModel"):getData().lvl or 1
    local varibleNameToValue = 
    {
        ["$atk"] = hero.atk,
        ["$def"] = hero.def,
        ["$int"] = hero.int,
        ["$ack"] = hero.ack,
        ["$mor"] = hero.shiQi,
        ["$artifactlv"] = hero.artifactlv or 0,
        ["$manabase"] = hero.manaBase,
        ["$ap"] = 0,
        ["$manarec"] = hero.manaRec,
        ["$sklevel"] = level,
        ["$level"] = 0,
        ["$valueadd11"] = 0,
        ["$valueadd12"] = 0,
        ["$valueadd21"] = 0,
        ["$valueadd22"] = 0,
        ["$ulevel"] = userlvl or 1,
        ["$aulevel"] = math.min(userlvl,math.max(0,80+(userlvl-80)*0.2)) or 1,
        ["$range1"] = 0,
        ["$unittime"] = 0,
        ["$sumnum"] = 0,
        ["$morale11"] = 0,
        ["$morale12"] = 0,
        ["$morale111"] = 0,
        ["$morale112"] = 0,
        ["$formula1"] = 0,
        ["$formula2"] = 0,
        ["$addattr11"] = 0,
        ["$addattr12"] = 0,
        ["$orange1"] = 0,
        ["$ovalueadd11"] = 0,
        ["$ovalueadd12"] = 0,
        ["$ointerval"] = 0,
        ["$olast11"] = 0,
        ["$olast12"] = 0,
        ["$bufflast11"] = 0,
        ["$bufflast12"] = 0,
        ["$buffaddattr11"] = 0,
        ["$buffaddattr12"] = 0,
        ["$buffaddattr13"] = 0,
        ["$buffaddattr21"] = 0,
        ["$buffaddattr22"] = 0,
        ["$buffaddattr23"] = 0,
        ["$buffhurt"] = 0,
        ["$valuepro11"] = 0,
        ["$valuepro12"] = 0,
        ["$dupliatk11"] = 0,
        ["$dupliatk12"] = 0,
        ["$duplidmg11"] = 0,
        ["$duplidmg12"] = 0,
        ["$initcd1"] = 0,
        ["$initcd2"] = 0,
        ["$cd1"] = 0,
        ["$cd2"] = 0,
    }
    local skillData = tab.playerSkillEffect[skillid]
    local objectData = nil
    if skillData.objectid then
        objectData = tab.object[skillData.objectid]
    end
    local bufferData = nil
    if skillData.buffid1 then
        bufferData = tab.skillBuff[skillData.buffid1]
    end
    varibleNameToValue["$ap"] = hero.ap[skillData["mgtype"]][skillData["type"]]
    varibleNameToValue["$valueadd11"] = skillData["valueadd1"] and skillData["valueadd1"][1] or 0
    varibleNameToValue["$valueadd12"] = skillData["valueadd1"] and skillData["valueadd1"][2] or 0
    varibleNameToValue["$valueadd21"] = skillData["valueadd2"] and skillData["valueadd2"][1] or 0
    varibleNameToValue["$valueadd22"] = skillData["valueadd2"] and skillData["valueadd2"][2] or 0
    varibleNameToValue["$valuepro11"] = skillData["valuepro1"] and skillData["valuepro1"][1] or 0
    varibleNameToValue["$valuepro12"] = skillData["valuepro1"] and skillData["valuepro1"][2] or 0
    varibleNameToValue["$dupliatk11"] = skillData["dupliatk1"] and skillData["dupliatk1"][1] or 0
    varibleNameToValue["$dupliatk12"] = skillData["dupliatk1"] and skillData["dupliatk1"][2] or 0
    varibleNameToValue["$duplidmg11"] = skillData["duplidmg1"] and skillData["duplidmg1"][1] or 0
    varibleNameToValue["$duplidmg12"] = skillData["duplidmg1"] and skillData["duplidmg1"][2] or 0
    varibleNameToValue["$initcd1"] = skillData["initcd"] and skillData["initcd"][1] or 0
    varibleNameToValue["$initcd2"] = skillData["initcd"] and skillData["initcd"][2] or 0
    varibleNameToValue["$cd1"] = skillData["cd"] and skillData["cd"][1] or 0
    varibleNameToValue["$cd2"] = skillData["cd"] and skillData["cd"][2] or 0
    varibleNameToValue["$range1"] = skillData["range1"] or 0
    varibleNameToValue["$unittime"] = skillData["unittime"] or 0
    varibleNameToValue["$sumnum"] = skillData["sumnum"] or 0
    
    if objectData then
        varibleNameToValue["$orange1"] = objectData["range1"] or 0
        varibleNameToValue["$ovalueadd11"] = objectData["valueadd1"] and objectData["valueadd1"][1] or 0
        varibleNameToValue["$ovalueadd12"] = objectData["valueadd1"] and objectData["valueadd1"][2] or 0
        varibleNameToValue["$ovalueadd21"] = objectData["valueadd2"] and objectData["valueadd2"][1] or 0
        varibleNameToValue["$ovalueadd22"] = objectData["valueadd2"] and objectData["valueadd2"][2] or 0
        varibleNameToValue["$ointerval"] = objectData["interval"] or 0
        varibleNameToValue["$olast11"] = objectData["last1"] and objectData["last1"][1] or 0
        varibleNameToValue["$olast12"] = objectData["last1"] and objectData["last1"][2] or 0
    end

    if bufferData then
        varibleNameToValue["$bufflast11"] = bufferData["last1"] and bufferData["last1"][1] or 0
        varibleNameToValue["$bufflast12"] = bufferData["last1"] and bufferData["last1"][2] or 0
        varibleNameToValue["$buffaddattr11"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][1] or 0
        varibleNameToValue["$buffaddattr12"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][2] or 0
        varibleNameToValue["$buffaddattr13"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][3] or 0
        varibleNameToValue["$buffaddattr21"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][1] or 0
        varibleNameToValue["$buffaddattr22"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][2] or 0
        varibleNameToValue["$buffaddattr23"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][3] or 0
        varibleNameToValue["$buffhurt"] = bufferData["hurt"] or 0
    end
    local description = string.gsub(desc, "%b{}", function(substring)
        local equation = "return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
            return tostring(varibleNameToValue[variableName])
        end), "[{}]", "")
        equation = string.gsub(equation,"%-%-","-")
        local functionName = loadstring(equation)
        if not functionName then
            print("wrong equation", equation, iconType, iconId)
            ViewManager:getInstance():onLuaError("hero description error: " .. "equation:" .. equation .. " iconType:" .. iconType .. " iconId" .. iconId)
            return 0
        end
        local result = string.format("%.1f", functionName())
        if checknumber(result) > 100 then
            result = checknumber(result)
        elseif '0' == string.sub(result, -1) then
            result = checkint(result)
        end
        return result
        --[[
        local result = string.format("%.1f", loadstring("return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
            return tostring(varibleNameToValue[variableName])
        end), "[{}]", ""))())
        if checknumber(result) > 100 then
            result = checknumber(result)
        elseif '0' == string.sub(result, -1) then
            result = checkint(result)
        end
        return result
        ]]
    end)
    return description
end

function BattleUtils.getHeroAttributes(heroData, nextLevel, specifiedLevelAndIndex)
    -- dump(heroData, "heroData")
    local id = heroData.id or heroData.heroId
    local userModel = ModelManager:getInstance():getModel("UserModel")
    local treasureModel = ModelManager:getInstance():getModel("TreasureModel")
    local talentModel = ModelManager:getInstance():getModel("TalentModel")
    local heroModel = ModelManager:getInstance():getModel("HeroModel")
    local level = userModel:getData().lvl or 1
    local masterys = {}
    if ModelManager:getInstance():getModel("HeroModel"):checkHero(id) then
        for i=1, 4 do
            masterys[i] = heroData["m" .. i]
        end
    end
    local equips = {}

    local artifacts = userModel:getData().artifacts
    for i=1, 6 do
        repeat
            local artifact = heroData["artifact" .. i]
            if not artifact then break end
            local stage = artifacts[tostring(artifact)].stage or 0
            table.insert(equips, {id = artifact, stage = stage})
        until true
    end
    local slevel = {}
    for i = 1, 5 do
        slevel[i] = heroData["sl" .. i]
    end

    if nextLevel then
        for i = 1, #slevel do
            slevel[i] = slevel[i] + 1
        end
    end

    if specifiedLevelAndIndex and type(specifiedLevelAndIndex) == "table" then
        slevel[specifiedLevelAndIndex[1]] = specifiedLevelAndIndex[2]
    end

    --dump(userModel:getGlobalMasterys(),"userModel:getGlobalMasterys()==>>>")
    local heroTableData = tab.hero[id]
    if not heroTableData then
        heroTableData = heroData
    end


    return BattleUtils.getHeroBaseAttr(heroTableData, level, slevel, heroData.star, masterys, 
        userModel:getGlobalMasterys(), treasureModel:getData(), nil, talentModel:getData(), userModel:getGlobalAttributes(), userModel:getuMastery(), heroData.skillex,nil,nil,nil,nil,nil,userModel:getHeroStarHAb()
        ,heroModel:getStarInfo(id),userModel:getHeroStarInfo())
        -- hAb, uMastery)
end

--排行榜获取英雄详情 
function BattleUtils.getRankHeroAttributes(playerLvl,heroData,globalSpecial,treasureData,talentData,hAb,uMastery)
    --dump(heroData, "heroData", 5)
    local id = heroData.id or heroData.heroId
    local level = playerLvl
    local masterys = {}
    for i=1, 4 do
        masterys[i] = heroData["m" .. i]
    end
    local equips = {}

    local artifacts = treasureData
    for i=1, 6 do
        repeat
            local artifact = heroData["artifact" .. i]
            if not artifact then break end
            local stage = artifacts[tostring(artifact)].stage or 0
            table.insert(equips, {id = artifact, stage = stage})
        until true
    end
    local slevel = {}
    for i = 1, 5 do
        slevel[i] = heroData["sl" .. i]
    end

    -- dump(globalSpecial,"globalSpecial==>>>")
    -- print("+==================+",id)
    
    return BattleUtils.getHeroBaseAttr(tab.hero[id], 
                                        level, 
                                        slevel, 
                                        heroData.star, 
                                        masterys, 
                                        globalSpecial, 
                                        treasureData,
                                        nil,
                                        talentData,
                                        hAb,
                                        uMastery,
                                        heroData.skillex)
end

function BattleUtils.getDescription(iconType, iconId, attributeValues, skillIndex, specifiedDescriptionId, battleType, spTalent)
    --attributeValues = attributeValues or BattleUtils.getHeroAttributes(self._heroData)
    
    print("battleType==================",battleType)
    if not attributeValues then return end
    if iconType == BattleUtils.kIconTypeSkill and not skillIndex then return end
    if not skillIndex then skillIndex = 1 end
    local userlvl = ModelManager:getInstance():getModel("UserModel"):getData().lvl or 1

    local attrLevel = 1
    local attrStage = 1
    if skillIndex == 5 then
        attrLevel = attributeValues.artifactlv or attributeValues.skills[skillIndex][3] or 1
        attrStage = attributeValues.sklevel or attributeValues.skills[skillIndex][2] or 1
    else
        attrLevel = attributeValues.artifactlv or attributeValues.skills[skillIndex][2] or 1
        attrStage = attributeValues.sklevel or attributeValues.skills[skillIndex][2] or 1
    end

    local varibleNameToValue = 
    {
        ["$atk"] = attributeValues.atk,
        ["$def"] = attributeValues.def,
        ["$int"] = attributeValues.int,
        ["$ack"] = attributeValues.ack,
        ["$mor"] = attributeValues.shiQi,
        ["$artifactlv"] = attrLevel,
        ["$manabase"] = attributeValues.manaBase,
        ["$ap"] = 0,
        ["$manarec"] = attributeValues.manaRec,
        ["$sklevel"] = attrStage,
        ["$level"] = 0,
        ["$valueadd11"] = 0,
        ["$valueadd12"] = 0,
        ["$valueadd21"] = 0,
        ["$valueadd22"] = 0,
        ["$ovaluepro11"] = 0,
        ["$ovaluepro12"] = 0,
        ["$ovaluepro21"] = 0,
        ["$ovaluepro22"] = 0,
        ["$ulevel"] = userlvl,
        ["$aulevel"] = math.min(userlvl,math.max(0,80+(userlvl-80)*0.2)) or 1,
        ["$range1"] = 0,
        ["$unittime"] = 0,
        ["$sumnum"] = 0,
        ["$morale11"] = 0,
        ["$morale12"] = 0,
        ["$morale111"] = 0,
        ["$morale112"] = 0,
        ["$formula1"] = 0,
        ["$formula2"] = 0,
        ["$addattr11"] = 0,
        ["$addattr12"] = 0,
        ["$orange1"] = 0,
        ["$ovalueadd11"] = 0,
        ["$ovalueadd12"] = 0,
        ["$ointerval"] = 0,
        ["$olast11"] = 0,
        ["$olast12"] = 0,
        ["$bufflast11"] = 0,
        ["$bufflast12"] = 0,
        ["$buffaddattr11"] = 0,
        ["$buffaddattr12"] = 0,
        ["$buffaddattr13"] = 0,
        ["$buffaddattr21"] = 0,
        ["$buffaddattr22"] = 0,
        ["$buffaddattr23"] = 0,
        ["$buffhurt"] = 0,
        ["$valuepro11"] = 0,
        ["$valuepro12"] = 0,
        ["$dupliatk11"] = 0,
        ["$dupliatk12"] = 0,
        ["$duplidmg11"] = 0,
        ["$duplidmg12"] = 0,
        ["$initcd1"] = 0,
        ["$initcd2"] = 0,
        ["$cd1"] = 0,
        ["$cd2"] = 0,

        ["$a101"] = 0,

        ["$a122"] = 0,
        ["$a123"] = 0,
        ["$a124"] = 0,
        ["$a125"] = 0,
        ["$a126"] = 0,
        ["$a127"] = 0,
        ["$a128"] = 0,
        ["$a129"] = 0,
        ["$a130"] = 0,
        ["$a131"] = 0,
        ["$a127"] = 0,
        ["$a128"] = 0,
        ["$a129"] = 0,
        ["$a130"] = 0,
        ["$a131"] = 0,  

        ["$talent1"] = 0,
        ["$talent2"] = 0,
        ["$talent3"] = 0,
        ["$talent4"] = 0,
        ["$talent5"] = 0,
        ["$talent6"] = 0,
        ["$talent7"] = 0,
        ["$talent8"] = 0,
        ["$talent9"] = 0,
        ["$talent10"] = 0,
        ["$talent11"] = 0,
        ["$talent12"] = 0,
        ["$talent13"] = 0,
        ["$talent14"] = 0,
    }

    local description = ""
    local isRound = false
    if iconType == BattleUtils.kIconTypeAttributeAtk then
        description = lang("HERO_ATTRIBUTE_ATK")
    elseif iconType == BattleUtils.kIconTypeAttributeDef then
        description = lang("HERO_ATTRIBUTE_DEF")
    elseif iconType == BattleUtils.kIconTypeAttributeInt then
        description = lang("HERO_ATTRIBUTE_INT")
    elseif iconType == BattleUtils.kIconTypeAttributeAck then
        description = lang("HERO_ATTRIBUTE_ACK")
    elseif iconType == BattleUtils.kIconTypeAttributeMorale then
        description = "英雄魔法回复速度：{$manarec*2}"--lang("HERO_ATTRIBUTE_MOR")
    elseif iconType == BattleUtils.kIconTypeAttributeMagic then
        description = "英雄初始魔法值：{$manabase}"--lang("HERO_ATTRIBUTE_MANA")
    elseif --[[iconType == BattleUtils.kIconTypeHeroSpecialty or]]
           iconType == BattleUtils.kIconTypeHeroMastery then
        local masteryData = tab.heroMastery[iconId]
        print(iconId,"iconId......")
        varibleNameToValue["$morale11"] = (masteryData["morale"] and masteryData["morale"][1]) and masteryData["morale"][1][1] or 0
        varibleNameToValue["$morale12"] = (masteryData["morale"] and masteryData["morale"][1]) and masteryData["morale"][1][2] or 0
        varibleNameToValue["$morale13"] = (masteryData["morale"] and masteryData["morale"][1]) and masteryData["morale"][1][3] or 0
        varibleNameToValue["$morale111"] = (masteryData["morale1"] and masteryData["morale1"][1]) and masteryData["morale1"][1][1] or 0
        varibleNameToValue["$morale112"] = (masteryData["morale1"] and masteryData["morale1"][1]) and masteryData["morale1"][1][2] or 0
        varibleNameToValue["$morale113"] = (masteryData["morale1"] and masteryData["morale1"][1]) and masteryData["morale1"][1][3] or 0
        varibleNameToValue["$formula11"] = (masteryData["formula"] and masteryData["formula"][1]) and masteryData["formula"][1][1] or 0
        varibleNameToValue["$formula12"] = (masteryData["formula"] and masteryData["formula"][1]) and masteryData["formula"][1][2] or 0
        varibleNameToValue["$formula13"] = (masteryData["formula"] and masteryData["formula"][1]) and masteryData["formula"][1][3] or 0
        varibleNameToValue["$addattr11"] = (masteryData["addattr"] and masteryData["addattr"][1]) and masteryData["addattr"][1][1] or 0
        varibleNameToValue["$addattr12"] = (masteryData["addattr"] and masteryData["addattr"][1]) and masteryData["addattr"][1][2] or 0
        varibleNameToValue["$addattr13"] = (masteryData["addattr"] and masteryData["addattr"][1]) and masteryData["addattr"][1][3] or 0
        varibleNameToValue["$addattr21"] = (masteryData["addattr"] and masteryData["addattr"][2]) and masteryData["addattr"][2][1] or 0
        varibleNameToValue["$addattr22"] = (masteryData["addattr"] and masteryData["addattr"][2]) and masteryData["addattr"][2][2] or 0
        varibleNameToValue["$addattr23"] = (masteryData["addattr"] and masteryData["addattr"][2]) and masteryData["addattr"][2][3] or 0
        description = specifiedDescriptionId and lang(specifiedDescriptionId) or lang(masteryData.des)
    elseif iconType == BattleUtils.kIconTypeSkill then
        local skillData = tab.playerSkillEffect[iconId]
        local objectData = nil
        if skillData.objectid then
            objectData = tab.object[skillData.objectid]
        end
        local bufferData = nil
        if skillData.buffid1 then
            bufferData = tab.skillBuff[skillData.buffid1]
        end
        varibleNameToValue["$ap"] = attributeValues.ap[skillData["mgtype"]][skillData["type"]]
        varibleNameToValue["$valueadd11"] = skillData["valueadd1"] and skillData["valueadd1"][1] or 0
        varibleNameToValue["$valueadd12"] = skillData["valueadd1"] and skillData["valueadd1"][2] or 0
        varibleNameToValue["$valueadd21"] = skillData["valueadd2"] and skillData["valueadd2"][1] or 0
        varibleNameToValue["$valueadd22"] = skillData["valueadd2"] and skillData["valueadd2"][2] or 0
        varibleNameToValue["$valuepro11"] = skillData["valuepro1"] and skillData["valuepro1"][1] or 0
        varibleNameToValue["$valuepro12"] = skillData["valuepro1"] and skillData["valuepro1"][2] or 0
        varibleNameToValue["$dupliatk11"] = skillData["dupliatk1"] and skillData["dupliatk1"][1] or 0
        varibleNameToValue["$dupliatk12"] = skillData["dupliatk1"] and skillData["dupliatk1"][2] or 0
        varibleNameToValue["$duplidmg11"] = skillData["duplidmg1"] and skillData["duplidmg1"][1] or 0
        varibleNameToValue["$duplidmg12"] = skillData["duplidmg1"] and skillData["duplidmg1"][2] or 0
        varibleNameToValue["$initcd1"] = skillData["initcd"] and skillData["initcd"][1] or 0
        varibleNameToValue["$initcd2"] = skillData["initcd"] and skillData["initcd"][2] or 0
        varibleNameToValue["$cd1"] = skillData["cd"] and skillData["cd"][1] or 0
        varibleNameToValue["$cd2"] = skillData["cd"] and skillData["cd"][2] or 0
        varibleNameToValue["$range1"] = skillData["range1"] or 0
        varibleNameToValue["$unittime"] = skillData["unittime"] or 0
        varibleNameToValue["$sumnum"] = skillData["sumnum"] or 0
        if spTalent == -1 then
           spTalent = ModelManager:getInstance():getModel("SkillTalentModel"):getTalentDataInFormat()
        end
        local talentData = ModelManager:getInstance():getModel("SkillTalentModel"):getTalentAdd(iconId, spTalent)
        for key,value in pairs (talentData) do 
            varibleNameToValue[key] = value
        end
        if battleType and BattleUtils.NO_TALENT[battleType] then
            for key,value in pairs (talentData) do 
                varibleNameToValue[key] = 0
            end
        end
        
        if objectData then
            varibleNameToValue["$orange1"] = objectData["range1"] or 0
            varibleNameToValue["$ovalueadd11"] = objectData["valueadd1"] and objectData["valueadd1"][1] or 0
            varibleNameToValue["$ovalueadd12"] = objectData["valueadd1"] and objectData["valueadd1"][2] or 0
            varibleNameToValue["$ovalueadd21"] = objectData["valueadd2"] and objectData["valueadd2"][1] or 0
            varibleNameToValue["$ovalueadd22"] = objectData["valueadd2"] and objectData["valueadd2"][2] or 0
            varibleNameToValue["$ovaluepro11"] = objectData["valuepro1"] and objectData["valuepro1"][1] or 0
            varibleNameToValue["$ovaluepro12"] = objectData["valuepro1"] and objectData["valuepro1"][2] or 0
            varibleNameToValue["$ovaluepro21"] = objectData["valuepro2"] and objectData["valuepro2"][1] or 0
            varibleNameToValue["$ovaluepro22"] = objectData["valuepro2"] and objectData["valuepro2"][2] or 0
            varibleNameToValue["$ointerval"] = objectData["interval"] or 0
            varibleNameToValue["$olast11"] = objectData["last1"] and objectData["last1"][1] or 0
            varibleNameToValue["$olast12"] = objectData["last1"] and objectData["last1"][2] or 0
        end

        if bufferData then
            varibleNameToValue["$bufflast11"] = bufferData["last1"] and bufferData["last1"][1] or 0
            varibleNameToValue["$bufflast12"] = bufferData["last1"] and bufferData["last1"][2] or 0
            varibleNameToValue["$buffaddattr11"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][1] or 0
            varibleNameToValue["$buffaddattr12"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][2] or 0
            varibleNameToValue["$buffaddattr13"] = (bufferData["addattr"] and bufferData["addattr"][1]) and bufferData["addattr"][1][3] or 0
            varibleNameToValue["$buffaddattr21"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][1] or 0
            varibleNameToValue["$buffaddattr22"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][2] or 0
            varibleNameToValue["$buffaddattr23"] = (bufferData["addattr"] and bufferData["addattr"][2]) and bufferData["addattr"][2][3] or 0
            varibleNameToValue["$buffhurt"] = bufferData["hurt"] or 0
        end

        varibleNameToValue["$a101"] = attributeValues.apAdd

        for i=1, 5 do
            local attrId = 121 + i
            varibleNameToValue["$a" .. attrId] = attributeValues.ap[4][i]
        end

        for i=1, 5 do
            local attrId = 126 + i
            varibleNameToValue["$a" .. attrId] = attributeValues.ap[1][i]
        end

        for i=1, 5 do
            local attrId = 131 + i
            varibleNameToValue["$a" .. attrId] = attributeValues.ap[2][i]
        end

        description = specifiedDescriptionId and lang(specifiedDescriptionId) or lang(skillData.des)
        --isRound = true
    end

    -- print("description:",iconType,"...", description)
    -- dump(varibleNameToValue)
    local caculate = function(str)
        local equation = "return " .. string.gsub(string.gsub(str, "%$%w+", function(variableName)
            return tostring(varibleNameToValue[variableName])
        end), "[{<>}]", "")
        equation = string.gsub(equation,"%-%-","-")
        local functionName = loadstring(equation)
        if not functionName then
            if OS_IS_WINDOWS then
                ViewManager:getInstance():showTip(iconId .. "技能描述配置错误")
            end
            print("wrong equation", equation)
            return 0
        end
        return tonumber(functionName())
    end
    if isRound then
    else
        --处理技能持续时间
        description = string.gsub(description, "%b{>", function(substring)
            if string.find(substring,"talent3") or string.find(substring,"talent4") then
                if varibleNameToValue["$talent3"] > 0 or  varibleNameToValue["$talent4"] > 0 then
                    substring = "[color=48b946,fontsize=20]" .. substring .. "[-]"
                end
            else
                return substring
            end
        end)

        
    end
    description = string.gsub(description, "%b{}", function(substring)
        local result = string.format("%.4f", caculate(substring))
        return BattleUtils.formatNumber(result)
    end)

    description = string.gsub(description, "%b<>", function(substring)
        local result = caculate(substring)
        if 0 == result then return "" end
        return BattleUtils.formatRichNumber(result)
    end)

    description = string.gsub(description, "[{<>}]", "")

    return description
end

--[[
--! @function checkTeamData
--! @desc 创建伪装数据
--! @param inTeam 怪兽
--! @param inEquips 怪兽等级
--! @param inSkills 怪兽阶
--! @return table
--]]
local key1 = nil
function BattleUtils.checkTeamData(inTeam, isBattle)
    if key1 == nil then
        key1 = os.time()
    end
    local teamData = {}
    if isBattle == true then 
        teamData = inTeam
    else
        for k,v in pairs(inTeam) do
            teamData[k] = v
        end
        teamData.equip = {}
        for i=1,4 do
            teamData.equip[i] = {level = 0, stage = 0}
            if teamData["el" .. i] ~= nil then 
                teamData.equip[i].level = teamData["el" .. i] 
            end
            if teamData["es" .. i] ~= nil then 
                teamData.equip[i].stage = teamData["es" .. i] 
            end
        end
        teamData.skill = {}
        for i=1,4 do
            if teamData["sl" .. i] ~= nil then 
                teamData.skill[i] = teamData["sl" .. i] 
            end
        end 
        teamData.id = inTeam.teamId
    end

    local checkNum = teamData.level * 20 + (teamData.id * (teamData.stage + teamData.star)) + teamData.smallStar

    checkNum = checkNum - teamData.level - (teamData.id * teamData.star) + (teamData.stage * teamData.star)

    for k,v in pairs(teamData.equip) do
        checkNum = checkNum + v.level * 2+ v.stage * 3
    end

    for k,v in pairs(teamData.skill) do
        checkNum = checkNum + v * 4 
    end
    
    return key1 - checkNum
end

local key2 = nil
function BattleUtils.checkPokedexScoreData(inScores)
    if key2 == nil then
        key2 = os.time()
    end
    local checkNum = 0
    for k,v in pairs(inScores) do
        checkNum = checkNum  + k * 86 + v 
    end
    return key2 - checkNum
end

local key3 = nil
function BattleUtils.checkHeroData(inHero, isBattle)
    if key3 == nil then
        key3 = os.time()
    end
    local heroData
    if isBattle then
        heroData = inHero
    else
        heroData = 
        {
            id = inHero.id,
            star = inHero.star,
            slevel = {inHero.sl1, inHero.sl2, inHero.sl3, inHero.sl4}
        }
    end
    return key3 - (heroData.id * 3 + (heroData.star + 3) * 28 + heroData.slevel[1] * 7 + heroData.slevel[2] * 9 + heroData.slevel[3] * 8 + heroData.slevel[4] * 2)
end

local key4 = nil
function BattleUtils.checkTreasureData(data)
    if key4 == nil then
        key4 = os.time()
    end
    local value = 0
    if data then
        for id, com in pairs(data) do
            if com.stage > 0 then
                value = value + com.stage * id
            end
            for did, disInfo in pairs(com.treasureDev) do
                local lv = disInfo and disInfo.s or 0
                if lv > 0 then
                    value = value + did *lv
                end
            end
        end
    end
    return key4 - value
end

-- 叠加魔法天赋加成值
function BattleUtils.getSkillBookTalent(skillBookTalent, skillReplace)
    local cfgs = clone(tab.skillBookTalent)
    local getSkillBookTalentValue = function (skillBTId, level)
        local t = {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        local tTalent = {}
        local cfg  = cfgs[skillBTId]
        local baseValue = cfg.base +(level - 1 ) * cfg.addition
        t[cfg.sort1] = t[cfg.sort1] + baseValue
        tTalent[cfg.sort1] = cfg.sort1
        local advancedlvs = cfg.advancedlv
        if level < advancedlvs[1] then
            -- 没有进阶魔法天赋
            return t, tTalent
        end
        -- 5  10  15
        if advancedlvs[2] and level < advancedlvs[2] then
            -- 进阶魔法天赋1
            t[cfg.advancedsort1] = t[cfg.advancedsort1] + cfg.advancedbase1
            tTalent[cfg.advancedsort1] = cfg.advancedsort1
        elseif advancedlvs[3] and level < advancedlvs[3] then
            -- 进阶魔法天赋1 2
            t[cfg.advancedsort1] = t[cfg.advancedsort1] + cfg.advancedbase1
            t[cfg.advancedsort2] = t[cfg.advancedsort2] + cfg.advancedbase2
            tTalent[cfg.advancedsort1] = cfg.advancedsort1
            tTalent[cfg.advancedsort2] = cfg.advancedsort2
        else
            -- 进阶魔法天赋1 2 3
            local base1 = cfg.advancedbase1 or 0
            local base2 = cfg.advancedbase2 or 0
            local base3 = cfg.advancedbase3 or 0

            if cfg.advancedsort1 then
                t[cfg.advancedsort1] = t[cfg.advancedsort1] + cfg.advancedbase1
                tTalent[cfg.advancedsort1] = cfg.advancedsort1
            end 
            if cfg.advancedsort2 then
                t[cfg.advancedsort2] = t[cfg.advancedsort2] + cfg.advancedbase2
                tTalent[cfg.advancedsort2] = cfg.advancedsort2
            end 

            if cfg.advancedsort3 then
                t[cfg.advancedsort3] = t[cfg.advancedsort3] + cfg.advancedbase3
                tTalent[cfg.advancedsort3] = cfg.advancedsort3
            end 
        end
        return t, tTalent
    end

    local skillBTalent = {["datas"] = {}, ["targetSkills"] = {}, ["totalValues"] = {} }
    if skillBookTalent then
        local kindCount = 14
        for k,v in pairs(skillBookTalent) do
            local skillBTlevel = v.l
            local id = tonumber(k)
            local cfg = cfgs[id]
            local skillIds = cfg.skillbookex
            local values , tTalent = getSkillBookTalentValue(id, skillBTlevel)
            -- 魔法天赋ID，魔法天赋等级，魔法天赋加成值，单项魔法天赋作用技能，单项魔法天赋加成值类型
            skillBTalent["datas"][id] = {id, skillBTlevel, values, skillIds, tTalent}

            for i = 1, #skillIds do
                local skillId = skillIds[i]

                -- 替换技能考虑
                if skillReplace[skillId] then
                    skillId = skillReplace[skillId]
                end 
                skillBTalent["targetSkills"][skillId] = skillId 
                -- 技能表考虑子物体
                local playerSkillEffect = tab.playerSkillEffect
                local object =  tab.object
                local objectid = playerSkillEffect[skillId]["objectid"] 
                if object[objectid] then
                    skillBTalent["targetSkills"][objectid] = objectid 
                end 
            end
        end
        for i = 1, kindCount do
           -- key: 加成类型
           -- value：加成值来源魔法天赋ID，总加成值，总生效技能
           skillBTalent["totalValues"][i] = {{},0,{}}
        end

        for k,v in pairs(skillBTalent.datas) do
            local values   = v[3]
            local skillIds = v[4]
            local talentT  = v[5]

            for i = 1, kindCount do
                skillBTalent["totalValues"][i][2] = skillBTalent["totalValues"][i][2] + values[i]
                -- 生效技能
                if talentT[i] then
                    skillBTalent["totalValues"][i][1][k] = k
                    for m = 1, #skillIds do
                        local skillId = skillIds[m]

                        -- 替换技能考虑
                        if skillReplace[skillId] then
                            skillId = skillReplace[skillId]
                        end 
                        -- 技能表考虑子物体
                        local playerSkillEffect = tab.playerSkillEffect
                        local object =  tab.object
                        local objectid = playerSkillEffect[skillId]["objectid"]

                        if object[objectid] then
                            skillBTalent["totalValues"][i][3][objectid] = objectid
                        end
                        skillBTalent["totalValues"][i][3][skillId] = skillId
                    end
                end
                
            end
        end
    end
    return skillBTalent
end

function BattleUtils.countSkillBookTalent(skillId, values, talentTypes, camp, keys)
    for i = 1, #talentTypes do
        local talentType = talentTypes[i]
        BattleUtils._countSkillBookTalent(skillId, values, talentType, camp, keys)
    end
end

function BattleUtils._countSkillBookTalent(skillId, values, talentType, camp, keys)
    local result = values
    local proIndex = {["2"] = 1,["4"] = 1,["6"] = 1,["8"] = 1,["10"] = 1,["12"] = 1,}
    
    local updateValueData = function (value, totalValues)
        if not proIndex[tostring(talentType)] then
            value = ceil(value + totalValues)
        else
            value = ceil(value * (1 + totalValues * 0.01))
        end 
        return value
    end

    local updateTBData = function (tb, key, totalValues, isReduce)
        if not isReduce then
            if not proIndex[tostring(talentType)] then
                tb[key] = ceil(tb[key] + totalValues)
            else
                tb[key] = ceil(tb[key] * (1 + totalValues * 0.01))
            end
        else
             local max = math.max
             if not proIndex[tostring(talentType)] then
                tb[key] = max(floor(tb[key] - totalValues), 0)
             else
                tb[key] = max(floor(tb[key] * (1 - totalValues * 0.01)), 0)
             end 
        end 
    end

    if BC.H_SkillBookTalent[camp] and BC.H_SkillBookTalent[camp]["targetSkills"][skillId] then

        local totalValue = BC.H_SkillBookTalent[camp]["totalValues"][talentType][2]
        local targetSkills = BC.H_SkillBookTalent[camp]["totalValues"][talentType][3]
        -- 单个总加成值作用技能判断
        if targetSkills[skillId] and totalValue > 0 then
            if talentType <= 2 then
                result = updateValueData(values, totalValue)
            elseif talentType <= 4 then
                updateTBData(values, "duration", totalValue)
            elseif talentType <= 6 then
                result = updateValueData(values, totalValue) 
            elseif talentType <= 8 then
                updateTBData(values, "shield", totalValue)
            elseif talentType <= 10 then
                updateTBData(values, "mana", totalValue, true)
            elseif talentType <= 12 then
                updateTBData(values, "cd", totalValue, true)
                updateTBData(values, "maxCD", totalValue, true)
            elseif talentType == 13 then
                updateTBData(values, BC.ATTR_HP, totalValue)
                updateTBData(values, BC.ATTR_Atk, totalValue)
            elseif talentType == 14 then
                updateTBData(values, BC.ATTR_HPPro, totalValue)
                updateTBData(values, BC.ATTR_AtkPro, totalValue)
            end 
        end 
    end 


    return result
    
end

function BattleUtils.isEnableSkillBookTalent(talentType, skillId, camp)
    local targetSkills = BC.H_SkillBookTalent[camp]["totalValues"][talentType][3]
    if targetSkills[skillId] then
        return true
    end
    return false
end

-- 兵团符文宝石
function BattleUtils.generateTeamRunsData(runsData)
    if runsData == nil then return end 
    if runsData then
        local stringSub = string.sub
        local stringGsub = string.gsub
        local Tonumber = tonumber
        for k,v in pairs(runsData) do
            local values = v["p"]
            local runes = {}
            values = stringSub(values, 2,-2) 
            values = stringGsub(values, "%b[]", function (str)
                str = stringSub(str, 2,-2)
                local ts = string.split(str, ",")
                ts[1] = Tonumber(ts[1])
                ts[2] = Tonumber(ts[2])
                if runes[ts[1]] then
                    runes[ts[1]] = runes[ts[1]] + ts[2]
                else
                    runes[ts[1]] = ts[2]
                end 
                
            end)
            v["p"] = runes
        end
        return runsData
    end 
end

function BattleUtils.getHolyMasterLevel(rune, runes)
    if not (rune and runes) then return 0 end
    local level = 0
    for i = 1, 6 do
        local runeId = tonumber(rune[i])
        if 0 ~= runeId then
            local drune = runes[runeId]
            if drune and drune.lv then
                level = level + drune.lv
            end
        end
    end
    return level
end

function BattleUtils.useFormulaCalculate(baseParams, advanceParams, lv, bookLevel)
    local formulaFuncs = {}
    formulaFuncs["101"] = function()
        -- dump({baseParams, advanceParams, lv, bookLevel}, "useFormulaCalculate___=====")
        -- dump((baseParams[2]+baseParams[3]*(lv-1))*(advanceParams[2]+advanceParams[3]*(bookLevel-1)), "useFormulaCalculate___ashduawhf")
        return (baseParams[2]+baseParams[3]*(lv-1))*(advanceParams[2]+advanceParams[3]*(bookLevel-1))
    end

    if advanceParams then
        return formulaFuncs[tostring(advanceParams[1])]()
    end

    return baseParams[2]+baseParams[3]*(bookLevel-1)
end

function BattleUtils.formatNumber(num)
    local toNum = tonumber(num)
    if not toNum then
        return '0'
    end
    num = tostring(num)
    if math.floor(toNum+0.9999) > toNum then
        if checknumber(num) > 100 then
            num = floor(num)
        elseif '.0000' == string.sub(num, -5) then
            num = checkint(num)
        elseif '000' == string.sub(num, -3) then
            num = string.format("%.1f", num)
        elseif '00' == string.sub(num, -2) then
            num =  string.format("%.2f", num)
        elseif '0' == string.sub(num, -1) then
            num =  string.format("%.3f", num)
        end
    elseif '.0000' == string.sub(num, -5) then
        num = checkint(num)     
    end
    return num
end

function BattleUtils.formatRichNumber(num)
    local toNum = tonumber(num)
    if not toNum then
        return '0'
    end
    num = tostring(num)
    if math.floor(toNum+0.9999) > toNum then
        if checknumber(num) > 100 then
            return string.format("[color=48b946, fontsize=20](%+d)[-]", floor(num))
        elseif '.0000' == string.sub(num, -5) then
            return string.format("[color=48b946, fontsize=20](%+d)[-]", checkint(num))
        elseif '000' == string.sub(num, -3) then
            return string.format("[color=48b946, fontsize=20](%+.1f)[-]", num)
        elseif '00' == string.sub(num, -2) then
            return string.format("[color=48b946, fontsize=20](%+.2f)[-]", num)
        elseif '0' == string.sub(num, -1) then
            return string.format("[color=48b946, fontsize=20](%+.3f)[-]", num)
        end
        return string.format("[color=48b946, fontsize=20](%+.4f)[-]", num)
    elseif '.0000' == string.sub(num, -5) then
        return string.format("[color=48b946, fontsize=20](%+d)[-]", checkint(num))
    else
        return string.format("[color=48b946, fontsize=20](%+d)[-]", num)
    end
end

function BattleUtils.dtor()
    AnimAP = nil
    ceil = nil
    dieEffName = nil
    dump = nil
    ENABLE_PROC_BATTLE = nil
    getResFileName = nil
    insert = nil
    keyTable1 = nil
    keyTable2 = nil
    mustWinTable = nil
    pairs = nil
    playerInfo = nil
    print = nil
    tab = nil
    table = nil
    team = nil
    tonumber = nil
    type = nil
    classIdxTable = nil
    raceIdxTable = nil
    potentialTable = nil
    key1 = nil
    key2 = nil
    key3 = nil
    key4 = nil
    G_TEAM_TALENTSKILL = nil
end

return BattleUtils
