--[[
    Filename:    BattleConst.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-30 14:41:22
    Description: File description
--]]
-- 地图辅助
local cc = cc
local os = os
local pc = pc
local math = math
local pairs = pairs
local next = next
local table = table
local tab = tab
local tonumber = tonumber
local tostring = tostring
local print = print
local string = string
local remove = table.remove
local dump = dump
local XBW_SKILL_DEBUG = BattleUtils.XBW_SKILL_DEBUG
--[[
    a >  b => a > b + e
    a >= b => a > b - e
    a <  b => a < b - e
    a <= b => a < b + e
]]--
BC = {}

BC.Ran = require("game.utils.random").new()
local Ran = BC.Ran
local Ran_ran = Ran.ran
function BC.ranSeed(...)
    return Ran:setSeed(...)
end
function BC.ran(...)
    return Ran_ran(Ran, ...)
end
local ran = BC.ran

BC.Ran2 = require("game.utils.random").new()
local Ran2 = BC.Ran2
local Ran2_ran = Ran2.ran
function BC.ranSeed2(...)
    return Ran2:setSeed(...)
end
function BC.ran2(...)
    return Ran2_ran(Ran2, ...)
end
local ran2 = BC.ran2

BC.PLAYER_LEVEL = {1, 1}

BC.jump = false

-- 是否左右双方颠倒位置
BC.reverse = false

BC.PLAYER_SKILL_ID = {20400, 20100, 20300, 20600, 20300, 20200}
  
-- 格子线
BC.BATTLE_DEBUG_CELL = false

-- 直线连通
BC.BATTLE_DEBUG_LINE_PASSABLE = false
-- 寻路
BC.BATTLE_DEBUG_FINE_PATH = false

-- 自动战斗 敌方
BC.BATTLE_DEBUG_AUTO_RIGHT = false
-- 自动战斗 己方
BC.BATTLE_DEBUG_AUTO_LEFT = false

-- 战斗速度
BC.BATTLE_SPEED = 1
BC.BATTLE_MAX_SPEED = 2

-- 是否可以认输
BC.BATTLE_QUIT = true

-- 战斗相关的常量
BC.MAX_SCENE_WIDTH_PIXEL = 2400
BC.MAX_SCENE_HEIGHT_PIXEL = 640

-- 3D
BC.BATTLE_3D_ANGLE = 25

-- 开场后延迟ai执行单位秒
BC.AI_RUN_DELAY = 5

-- 是否可以选中方阵
BC.CAN_SELECT_TEAM = false

-- 是否显示方阵墓碑
BC.SHOW_TEAM_DIE_ICON = false

-- 阵营常量
BC.ECamp = {
    LEFT = 1,    
    RIGHT = 2
}

-- 方阵内小兵的体积
BC.EVolume = {
    V_16 = 2,
    V_9 = 3,
    V_4 = 4,
    V_1 = 5,
    V_BOSS = 6,
}
-- 引导副本第一关关闭自动战斗
BC.GUIDE_INTANCE_CLOSE_AUTO_BATTLE = 7100101

-- 英雄debug属性
BC.HERODEBUG = {"atk", "def", "int", "ack", "shiQi", "manaRec"}

-- 兵团条件技能强制一帧释放
BC.CONDITIONFORCEKIND = {["40"] = true, ["7"] = true, ["30"] = true, ["22"] = true, ["23"] = true}


-- 不同体型的受击点
local cos = math.cos
local sin = math.sin
local rad = math.rad
local format = string.format
local abs = math.abs
local max = math.max
local function COS_SIN(d)
    local dd
    if d >= 150 then
        dd = abs(d - 180)
    else
        dd = abs(d)
    end
    return tonumber(format("%.2f", cos(rad(d)))), tonumber(format("%.2f", sin(rad(d)))), dd
end
local HitPos_rad = {}
HitPos_rad[5] = {180, 170, 190, 160, 200, 150, 210, 180, 170, 190, 160, 200, 150, 210, 
                180, 170, 190, 160, 200, 150, 210, 180, 170, 190, 160, 200, 150, 210, 
                -30, 30, -20, 20, -10, 10, 0, -30, 30, -20, 20, -10, 10, 0}
HitPos_rad[6] = {}
HitPos_rad[6][#HitPos_rad[6] + 1] = 180
local value1, value2 = 180, 180
for i = 1, 20 do
    value1 = value1 - 1.6
    value2 = value2 + 1.1
    HitPos_rad[6][#HitPos_rad[6] + 1] = value1
    HitPos_rad[6][#HitPos_rad[6] + 1] = value2
end
local value1, value2 = 0, 0
for i = 1, 20 do
    value1 = value1 - 1.1
    value2 = value2 + 1.6
    HitPos_rad[6][#HitPos_rad[6] + 1] = value1
    HitPos_rad[6][#HitPos_rad[6] + 1] = value2
end
HitPos_rad[6][#HitPos_rad[6] + 1] = 0
BC.HitPos = {}
for i = 2, 4 do
    BC.HitPos[i] = {}
    local hitPos = BC.HitPos[i]
    hitPos[1] = {-1, 0}
    hitPos[2] = {-1.4, 0}
    hitPos[3] = {-1, 0.5}
    hitPos[4] = {-1, -0.5}
    hitPos[5] = {-2.2, 0}
    hitPos[6] = {-1.8, 0.5}
    hitPos[7] = {-1.8, -0.5}
    hitPos[8] = {-2.2, 0.5}
    hitPos[9] = {1, 0}
    hitPos[10] = {1.4, 0}
    hitPos[11] = {1, -0.5}
    hitPos[12] = {1, 0.5}
end
for i = 5, 6 do
    BC.HitPos[i] = {}
    for k = 1, #HitPos_rad[i] do
        BC.HitPos[i][k] = {COS_SIN(HitPos_rad[i][k])}
    end
    if i == 5 then
        for k = 8, 14 do
            BC.HitPos[i][k][1] = BC.HitPos[i][k][1] - 0.3
        end
        for k = 15, 21 do
            BC.HitPos[i][k][1] = BC.HitPos[i][k][1] - 0.7
        end
        for k = 22, 28 do
            BC.HitPos[i][k][1] = BC.HitPos[i][k][1] - 0.7
        end
        for k = 36, 42 do
            BC.HitPos[i][k][1] = BC.HitPos[i][k][1] + 0.3
        end
    end
end
-- 不同方阵单位数量, 不同的行动所需时间 ms
BC.ActionValue = {}
for i = 1, 25 do
   BC.ActionValue[i] = 306 / i * 0.001
end
BC.ActionValue[1] = 180 * 0.001

BC.VolumeNumber = {25, 16, 9, 4, 1, 1}


-- 兵种数量
BC.MoveTypeCount = {{0, 0}, {0, 0}}
BC.ClassCount = {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}
BC.TotalRace1Count = 12
BC.Race1Count = {{}, {}}
for key = 1, BC.TotalRace1Count do
    BC.Race1Count[1][key] = 0
    BC.Race1Count[2][key] = 0
end

BC.XCount = {{0, 0, 0}, {0, 0, 0}}
-- 方阵IDmap
BC.TeamMap = {{}, {}}
BC.NpcMap = {{}, {}}
-- 记录子物体上面的父类技能Id
BC.ObjectParentSkillId = {}
-- 记录技能释放的mgtriger1（主要是萨丽尔）[1 ,2 技能， 3,4 释放的子物体]
BC.RecordReleaseSkill = {{}, {}, {}, {}}

-- 格子像素大小
BC.BATTLE_CELL_SIZE = 40

-- 格子总数量
BC.MAX_CELL_WIDTH = BC.MAX_SCENE_WIDTH_PIXEL / BC.BATTLE_CELL_SIZE
BC.MAX_CELL_HEIGHT = BC.MAX_SCENE_HEIGHT_PIXEL / BC.BATTLE_CELL_SIZE
-- 场景格子大小 40*40 像素
-- 格子坐标为格子中心点

-- 格子坐标转成场景坐标
local cw = BC.BATTLE_CELL_SIZE
local ch = BC.BATTLE_CELL_SIZE
function BC.getScenePosByCell(x, y)
    return  (x - 0.5) * cw, (y - 0.5) * ch
end

-- 场景坐标转换成格子坐标, 寻路用
-- 结果从1开始
local ceil = math.ceil
function BC.getCellByScenePos(x, y)
    return ceil(x / cw), ceil(y / ch)
end

-- 传入为像素
local abs = math.abs
function BC.getCellDistance(x1, y1, x2, y2)
    local cellx1, celly1 = BC.getCellByScenePos(x1, y1)
    local cellx2, celly2 = BC.getCellByScenePos(x2, y2)
    return abs(cellx2 - cellx1) + abs(celly2 - celly1)
end

BC.BATTLE_TYPE = 0
BC.BATTLE_BG_HEIGHT = 640
function BC.setBattleType(_type, siegeReverse, scaleMin, scaleMax)
    BC.BATTLE_TYPE = _type
    BC.BATTLE_BG_HEIGHT = 640
    BC.BATTLE_3D_ANGLE = 25
    if _type == BattleUtils.BATTLE_TYPE_Siege
        or _type == BattleUtils.BATTLE_TYPE_CCSiege
        or _type == BattleUtils.BATTLE_TYPE_Siege_Atk
        or _type == BattleUtils.BATTLE_TYPE_Siege_Def 
        or _type == BattleUtils.BATTLE_TYPE_Siege_Atk_WE
        or _type == BattleUtils.BATTLE_TYPE_Siege_Def_WE then
        BC.BATTLE_3D_ANGLE = 35
        -- 攻城战 初始坐标
        if siegeReverse then
            BC.FORMATION_START_X_LEFT = 19
            BC.FORMATION_START_Y_LEFT = 11
            BC.FORMATION_INTERVAL_X_LEFT = 2.7
            BC.FORMATION_INTERVAL_Y_LEFT = -2.4

            BC.FORMATION_START_X_RIGHT = 44.4
            BC.FORMATION_START_Y_RIGHT = 11
            BC.FORMATION_INTERVAL_X_RIGHT = -3.1
            BC.FORMATION_INTERVAL_Y_RIGHT = -2.4
        else
            BC.FORMATION_START_X_LEFT = 16
            BC.FORMATION_START_Y_LEFT = 11
            BC.FORMATION_INTERVAL_X_LEFT = 3.1
            BC.FORMATION_INTERVAL_Y_LEFT = -2.4

            BC.FORMATION_START_X_RIGHT = 40.2--45.6
            BC.FORMATION_START_Y_RIGHT = 11
            BC.FORMATION_INTERVAL_X_RIGHT = -2.7
            BC.FORMATION_INTERVAL_Y_RIGHT = -2.4
        end

        if MAX_SCREEN_WIDTH then
            local k = MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT
            -- k = 1.775
            BC.MIN_SCENE_SCALE = 0.895 + 0.155 * ((k - 1.333) / (1.775 - 1.333))
            BC.MAX_SCENE_SCALE = BC.MIN_SCENE_SCALE
            BC.SCENE_SCALE_INIT = BC.MIN_SCENE_SCALE
            BC.MIN_SCENE_SCALE = 0.5
            BC.MAX_SCENE_SCALE = 2
        end
        -- 0.895 -- 1.05
    elseif _type == BattleUtils.BATTLE_TYPE_Zombie then
        -- 僵尸战 坐标
        BC.FORMATION_START_X_LEFT = 15
        BC.FORMATION_START_Y_LEFT = 12.5
        BC.FORMATION_INTERVAL_X_LEFT = 3.4
        BC.FORMATION_INTERVAL_Y_LEFT = -2.4

        BC.FORMATION_START_X_RIGHT = 51
        BC.FORMATION_START_Y_RIGHT = 12.5
        BC.FORMATION_INTERVAL_X_RIGHT = -3.4
        BC.FORMATION_INTERVAL_Y_RIGHT = -2.4

        if MAX_SCREEN_WIDTH then
            local k = MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT
            local baseScale = k / 1.775
            BC.MIN_SCENE_SCALE = baseScale * 1.3
            BC.MAX_SCENE_SCALE = baseScale * 1.7
            
            local k2 = BC.MAX_SCENE_SCALE / BC.MIN_SCENE_SCALE
            BC.MIN_SCENE_SCALE = math.max(BC.MIN_SCENE_SCALE, 1.05)
            BC.MAX_SCENE_SCALE = BC.MIN_SCENE_SCALE * k2

            BC.SCENE_SCALE_INIT = BC.MIN_SCENE_SCALE
            BC.BATTLE_BG_HEIGHT = 550
        end
    elseif _type == BattleUtils.BATTLE_TYPE_Guide then
        -- 方阵初始位置的坐标
        BC.BATTLE_3D_ANGLE = 35

        BC.FORMATION_START_X_LEFT = 16
        BC.FORMATION_START_Y_LEFT = 11
        BC.FORMATION_INTERVAL_X_LEFT = 3.4
        BC.FORMATION_INTERVAL_Y_LEFT = -2.4

        BC.FORMATION_START_X_RIGHT = 44
        BC.FORMATION_START_Y_RIGHT = 11
        BC.FORMATION_INTERVAL_X_RIGHT = -3.4
        BC.FORMATION_INTERVAL_Y_RIGHT = -2.4

        if MAX_SCREEN_WIDTH then
            local k = MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT
            local baseScale = k / 1.775
            BC.MIN_SCENE_SCALE = baseScale * 1.1
            BC.MAX_SCENE_SCALE = baseScale * 1.1
            
            local k2 = BC.MAX_SCENE_SCALE / BC.MIN_SCENE_SCALE
            BC.MIN_SCENE_SCALE = math.max(BC.MIN_SCENE_SCALE, 1.0)
            BC.MAX_SCENE_SCALE = BC.MIN_SCENE_SCALE * k2

            BC.SCENE_SCALE_INIT = BC.MIN_SCENE_SCALE
        end
    elseif _type == BattleUtils.BATTLE_TYPE_CloudCity then
        -- 云中城 
        BC.FORMATION_START_X_LEFT = 11
        BC.FORMATION_START_Y_LEFT = 13
        BC.FORMATION_INTERVAL_X_LEFT = 3
        BC.FORMATION_INTERVAL_Y_LEFT = -2.4

        BC.FORMATION_START_X_RIGHT = 50
        BC.FORMATION_START_Y_RIGHT = 13
        BC.FORMATION_INTERVAL_X_RIGHT = -3
        BC.FORMATION_INTERVAL_Y_RIGHT = -2.4

        -- pad 适配宽一定, 适配高, 最小不能小于< 1.09 否则 会穿帮
        if MAX_SCREEN_WIDTH then
            local k = MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT
            local baseScale = k / 1.775
            if scaleMin then
                BC.MIN_SCENE_SCALE = baseScale * scaleMin
            else
                BC.MIN_SCENE_SCALE = baseScale * 1.3
            end
            if scaleMax then
                BC.MAX_SCENE_SCALE = baseScale * scaleMax
            else
                BC.MAX_SCENE_SCALE = baseScale * 1.7
            end
            local k2 = BC.MAX_SCENE_SCALE / BC.MIN_SCENE_SCALE
            BC.MIN_SCENE_SCALE = math.max(BC.MIN_SCENE_SCALE, 1.09)
            BC.MAX_SCENE_SCALE = BC.MIN_SCENE_SCALE * k2
            
            BC.SCENE_SCALE_INIT = BC.MIN_SCENE_SCALE
            BC.BATTLE_BG_HEIGHT = 512
        end
    else
        -- 方阵初始位置的坐标
        BC.FORMATION_START_X_LEFT = 10
        BC.FORMATION_START_Y_LEFT = 13
        BC.FORMATION_INTERVAL_X_LEFT = 3.4
        BC.FORMATION_INTERVAL_Y_LEFT = -2.4

        BC.FORMATION_START_X_RIGHT = 51
        BC.FORMATION_START_Y_RIGHT = 13
        BC.FORMATION_INTERVAL_X_RIGHT = -3.4
        BC.FORMATION_INTERVAL_Y_RIGHT = -2.4

        -- pad 适配宽一定, 适配高, 最小不能小于< 1.09 否则 会穿帮
        if MAX_SCREEN_WIDTH then
            local k = MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT
            local baseScale = k / 1.775
            if scaleMin then
                BC.MIN_SCENE_SCALE = baseScale * scaleMin
            else
                BC.MIN_SCENE_SCALE = baseScale * 1.3
            end
            if scaleMax then
                BC.MAX_SCENE_SCALE = baseScale * scaleMax
            else
                BC.MAX_SCENE_SCALE = baseScale * 1.7
            end
            local k2 = BC.MAX_SCENE_SCALE / BC.MIN_SCENE_SCALE
            BC.MIN_SCENE_SCALE = math.max(BC.MIN_SCENE_SCALE, 1.09)
            BC.MAX_SCENE_SCALE = BC.MIN_SCENE_SCALE * k2
            
            BC.SCENE_SCALE_INIT = BC.MIN_SCENE_SCALE
            BC.BATTLE_BG_HEIGHT = 512
        end
    end

    local yadd = BC.FORMATION_INTERVAL_Y_LEFT * 40
    local ymax = BC.FORMATION_START_Y_LEFT * 40
    BC.BATTLE_ROW_Y = {ymax, ymax + yadd, ymax + yadd * 2, ymax + yadd * 3}

    BC.rowHeight = -BC.FORMATION_INTERVAL_Y_RIGHT * BC.BATTLE_CELL_SIZE
    BC.rowMinY = (BC.FORMATION_START_Y_LEFT + (3 * BC.FORMATION_INTERVAL_Y_RIGHT)) * BC.BATTLE_CELL_SIZE - BC.rowHeight * 0.5
    BC.rowMaxY = BC.FORMATION_START_Y_LEFT * BC.BATTLE_CELL_SIZE - BC.rowHeight * 0.5
end
BC.NOW_SCENE_SCALE = 1

-- 获取初始阵型位置的格子坐标
-- FormationIndex 1 ~ 16
local modf = math.modf
function BC.getFormationCellPos(FormationIndex, camp)
    local x = 0
    local y = 0
    local a, b = modf(FormationIndex * 0.25)
    local formationX = b * 4
    local formationY = a + 1
    if formationX == 0 then
        formationX = 4
        formationY = formationY - 1
    end
    if camp == BC.ECamp.LEFT then
        x = BC.FORMATION_START_X_LEFT + (formationX - 1) * BC.FORMATION_INTERVAL_X_LEFT
        y = BC.FORMATION_START_Y_LEFT + (formationY - 1) * BC.FORMATION_INTERVAL_Y_LEFT
    elseif camp == BC.ECamp.RIGHT then
        x = BC.FORMATION_START_X_RIGHT + (formationX - 1) * BC.FORMATION_INTERVAL_X_RIGHT
        y = BC.FORMATION_START_Y_RIGHT + (formationY - 1) * BC.FORMATION_INTERVAL_Y_RIGHT  
    else
        -- print("error", "BC.getFormationCellPos wrong camp!!!!") 
    end
    return x, y
end
-- 获取初始阵型位置的屏幕坐标
function BC.getFormationScenePos(FormationIndex, camp)
    local x, y = BC.getFormationCellPos(FormationIndex, camp)
    return x * BC.BATTLE_CELL_SIZE, y * BC.BATTLE_CELL_SIZE
end


-- 根据y坐标, 返回行索引

function BC.getRowIndex(y)
    if y <= BC.rowMinY then
        return 4
    elseif y >= BC.rowMaxY then
        return 1
    else
        local row = modf((y - BC.rowMinY) / BC.rowHeight)
        return 4 - row
    end
end

-- 方阵坐标相关
-- 方阵内小兵间隔
BC.INFORMATION_INTERVAL_4 = {{30, 20}, {30, -20},
                          {-30, 20}, {-30, -20}}
BC.INFORMATION_INTERVAL_9 = {{32+10, 0}, {32-10, 20}, {32-10, -20}, 
                          {0+10, 0}, {0-10, 20}, {0-10, -20}, 
                          {-32+10, 0}, {-32-10, 20}, {-32-10, -20}}
BC.INFORMATION_INTERVAL_16 = {{37.5+5, 7}, {37.5+5, -21}, {37.5-5, 21}, {37.5-5, -7},
                           {12.5+5, 7}, {12.5+5, -21}, {12.5-5, 21}, {12.5-5, -7}, 
                           {-12.5+5, 7}, {-12.5+5, -21}, {-12.5-5, 21}, {-12.5-5, -7}, 
                           {-37.5+5, 7}, {-37.5+5, -21}, {-37.5-5, 21}, {-37.5-5, -7}}
-- 获得基于方阵坐标的坐标差(屏幕坐标)
function BC._getPosInFormation(x, y, index, volume, camp)
    if index ~= 0 then
        local k
        if camp == BC.ECamp.LEFT then 
            k = 1
        elseif camp == BC.ECamp.RIGHT then 
            k = -1
        end
        if volume == BC.EVolume.V_1 or volume == BC.EVolume.V_BOSS then
            return x, y
        elseif volume == BC.EVolume.V_4 then
            return x + BC.INFORMATION_INTERVAL_4[index][1] * k, y + BC.INFORMATION_INTERVAL_4[index][2]
        elseif volume == BC.EVolume.V_9 then
            return x + BC.INFORMATION_INTERVAL_9[index][1] * k, y + BC.INFORMATION_INTERVAL_9[index][2]
        elseif volume == BC.EVolume.V_16 then
            return x + BC.INFORMATION_INTERVAL_16[index][1] * k, y + BC.INFORMATION_INTERVAL_16[index][2]
        end
    else
        return 0, 0
    end
end
-- 建立查询表, 提高效率
function BC.getPosInFormation(x, y, index, volume, camp)
    if index == 0 then
        -- Hero
        return x, y
    end
    local nx, ny = BC.FORMATION_POS[camp][volume][index].x, BC.FORMATION_POS[camp][volume][index].y
    return nx + x, ny + y
end

-- 场上唯一编号
BC.Battle_GenID = 0
BC.Battle_TeamID = 0

function BC.resetGenID()
    BC.Battle_GenID = 1
    BC.Battle_TeamID = 1
end

function BC.genID()
    BC.Battle_GenID = BC.Battle_GenID + 1
    return BC.Battle_GenID - 1
end

function BC.genTeamID()
    BC.Battle_TeamID = BC.Battle_TeamID + 1
    return BC.Battle_TeamID - 1
end

-- 方阵状态
BC.ETeamState = {
    IDLE = 1,     -- 待机状态, 只有守方会有这个状态
    MOVE = 2,     -- 锁定目标以后的移动状态
    ATTACK = 3,   -- 攻击状态
    DIE = 4,      -- 死亡状态
    SORT = 5,     -- 攻击结束之后的整顿状态
    NONE = 6,     -- 不动
}

BC.EMotion = {
    IDLE = 1,
    MOVE = 2,
    ATTACK = 3,
    DIE = 4,
    CAST1 = 5,
    CAST2 = 6,
    CAST3 = 7,
    BORN = 8,
    RAP = 9,
    INIT = 17,
}

BC.EDirect = {
    LEFT = -1,
    RIGHT = 1
}

BC.ECastType = {
    NOMAL = 0, -- 正常释放（玩家点击，自动机能）
    QUICK = 1  -- 配合新手，快速释放
}

BC.SPEED_SORT = 160

BC.DIE_EXIST_TIME = 4.0

-- 攻击距离分类
BC.EAtkType = {
    NONE = 0,
    MELEE = 1,
    RANGE = 2,
}
-- 移动方式分类
BC.EMoveType = {
    NONE = 0,
    ARMY = 1,
    AIR = 2,
}
local EAtkTypeMELEE = BC.EAtkType.MELEE
local EAtkTypeNONE = BC.EAtkType.NONE
local EMoveTypeAIR = BC.EMoveType.AIR
local EMoveTypeNONE = BC.EMoveType.NONE

function BC.canAttack(team)
    return team.atkType ~= EAtkTypeNONE
end

function BC.isFly(team)
    return team.moveType == EMoveTypeAIR
end

function BC.canMove(team)
    return team.moveType ~= EMoveTypeNONE
end
BC.EState = {
    READY = 0,
    INTO = 1,
    ING = 2,    
    OVER = 3,
}

BC.EEffFlyType = {
    NONE = 0,
    LINE = 1,       -- 匀加速直线
    PARABOLA = 2,   -- 抛物线
    PARABOLA_L = 3, -- 抛物线_低
    PARABOLA_R = 4, -- 抛物线_旋转
    PARABOLA_L_R = 5,-- 抛物线_低_旋转
    DISAPPEAR = 6,  -- 消失
}
local EEffFlyTypeNONE = BC.EEffFlyType.NONE
local EEffFlyTypeLINE = BC.EEffFlyType.LINE
local EEffFlyTypePARABOLA = BC.EEffFlyType.PARABOLA
local EEffFlyTypePARABOLA_L = BC.EEffFlyType.PARABOLA_L
local EEffFlyTypePARABOLA_R = BC.EEffFlyType.PARABOLA_R
local EEffFlyTypePARABOLA_L_R = BC.EEffFlyType.PARABOLA_L_R
local EEffFlyTypeDISAPPEAR = BC.EEffFlyType.DISAPPEAR

---- 英雄属性 ----

-- 法伤固定值
BC.HATTR_APAdd = 1

-- 蓝和士气
BC.HATTR_Mana = 2
BC.HATTR_ManaPro = 3
BC.HATTR_ManaRec = 4
BC.HATTR_ManaRecPro = 5
BC.HATTR_ManaMax = 6
BC.HATTR_Shiqi = 7

-- 法术阻挡, 使对方法术失败
BC.HATTR_Hinder = 8
-- 护盾加成
BC.HATTR_ShieldPro = 9

-- 攻击防御智力知识
BC.HATTR_Atk = 10
BC.HATTR_AtkPro = 11
BC.HATTR_AtkAdd = 12
BC.HATTR_Def = 13
BC.HATTR_DefPro = 14
BC.HATTR_DefAdd = 15
BC.HATTR_Int = 16
BC.HATTR_IntPro = 17
BC.HATTR_IntAdd = 18
BC.HATTR_Ack = 19
BC.HATTR_AckPro = 20
BC.HATTR_AckAdd = 21

-- 法伤
BC.HATTR_APFire = 22
BC.HATTR_APWater = 23
BC.HATTR_APWind = 24
BC.HATTR_APEarth = 25
BC.HATTR_APAll = 26
-- 分系法伤
BC.HATTR_AP1Fire = 27
BC.HATTR_AP1Water = 28
BC.HATTR_AP1Wind = 29
BC.HATTR_AP1Earth = 30
BC.HATTR_AP1All = 31
BC.HATTR_AP2Fire = 32
BC.HATTR_AP2Water = 33
BC.HATTR_AP2Wind = 34
BC.HATTR_AP2Earth = 35
BC.HATTR_AP2All = 36
BC.HATTR_AP3Fire = 37
BC.HATTR_AP3Water = 38
BC.HATTR_AP3Wind = 39
BC.HATTR_AP3Earth = 40
BC.HATTR_AP3All = 41

-- 初始技能CD%
BC.HATTR_InitCDProFire = 42
BC.HATTR_InitCDProWater = 43
BC.HATTR_InitCDProWind = 44
BC.HATTR_InitCDProEarth = 45
BC.HATTR_InitCDProAll = 46
-- 分系初始CD%
BC.HATTR_InitCDPro1Fire = 47
BC.HATTR_InitCDPro1Water = 48
BC.HATTR_InitCDPro1Wind = 49
BC.HATTR_InitCDPro1Earth = 50
BC.HATTR_InitCDPro1All = 51
BC.HATTR_InitCDPro2Fire = 52
BC.HATTR_InitCDPro2Water = 53
BC.HATTR_InitCDPro2Wind = 54
BC.HATTR_InitCDPro2Earth = 55
BC.HATTR_InitCDPro2All = 56
BC.HATTR_InitCDPro3Fire = 57
BC.HATTR_InitCDPro3Water = 58
BC.HATTR_InitCDPro3Wind = 59
BC.HATTR_InitCDPro3Earth = 60
BC.HATTR_InitCDPro3All = 61

-- 技能CD%
BC.HATTR_CDProFire = 62
BC.HATTR_CDProWater = 63
BC.HATTR_CDProWind = 64
BC.HATTR_CDProEarth = 65
BC.HATTR_CDProAll = 66
-- 分系CD%
BC.HATTR_CDPro1Fire = 67
BC.HATTR_CDPro1Water = 68
BC.HATTR_CDPro1Wind = 69
BC.HATTR_CDPro1Earth = 70
BC.HATTR_CDPro1All = 71
BC.HATTR_CDPro2Fire = 72
BC.HATTR_CDPro2Water = 73
BC.HATTR_CDPro2Wind = 74
BC.HATTR_CDPro2Earth = 75
BC.HATTR_CDPro2All = 76
BC.HATTR_CDPro3Fire = 77
BC.HATTR_CDPro3Water = 78
BC.HATTR_CDPro3Wind = 79
BC.HATTR_CDPro3Earth = 80
BC.HATTR_CDPro3All = 81

-- 耗魔 ManaCostDec
BC.HATTR_MCDFire = 82
BC.HATTR_MCDWater = 83
BC.HATTR_MCDWind = 84
BC.HATTR_MCDEarth = 85
BC.HATTR_MCDAll = 86
-- 分系耗魔
BC.HATTR_MCD1Fire = 87
BC.HATTR_MCD1Water = 88
BC.HATTR_MCD1Wind = 89
BC.HATTR_MCD1Earth = 90
BC.HATTR_MCD1All = 91
BC.HATTR_MCD2Fire = 92
BC.HATTR_MCD2Water = 93
BC.HATTR_MCD2Wind = 94
BC.HATTR_MCD2Earth = 95
BC.HATTR_MCD2All = 96
BC.HATTR_MCD3Fire = 97
BC.HATTR_MCD3Water = 98
BC.HATTR_MCD3Wind = 99
BC.HATTR_MCD3Earth = 100
BC.HATTR_MCD3All = 101

-- 法术范围 RangeInc
BC.HATTR_RIFire = 102
BC.HATTR_RIWater = 103
BC.HATTR_RIWind = 104
BC.HATTR_RIEarth = 105
BC.HATTR_RIAll = 106
-- 分系范围
BC.HATTR_RI1Fire = 107
BC.HATTR_RI1Water = 108
BC.HATTR_RI1Wind = 109
BC.HATTR_RI1Earth = 110
BC.HATTR_RI1All = 111
BC.HATTR_RI2Fire = 112
BC.HATTR_RI2Water = 113
BC.HATTR_RI2Wind = 114
BC.HATTR_RI2Earth = 115
BC.HATTR_RI2All = 116
BC.HATTR_RI3Fire = 117
BC.HATTR_RI3Water = 118
BC.HATTR_RI3Wind = 119
BC.HATTR_RI3Earth = 120
BC.HATTR_RI3All = 121

-- 法术效果翻倍 DoubleEffect
BC.HATTR_DEFire = 122
BC.HATTR_DEWater = 123
BC.HATTR_DEWind = 124
BC.HATTR_DEEarth = 125
BC.HATTR_DEAll = 126
-- 分析翻倍
BC.HATTR_DE1Fire = 127
BC.HATTR_DE1Water = 128
BC.HATTR_DE1Wind = 129
BC.HATTR_DE1Earth = 130
BC.HATTR_DE1All = 131
BC.HATTR_DE2Fire = 132
BC.HATTR_DE2Water = 133
BC.HATTR_DE2Wind = 134
BC.HATTR_DE2Earth = 135
BC.HATTR_DE2All = 136
BC.HATTR_DE3Fire = 137
BC.HATTR_DE3Water = 138
BC.HATTR_DE3Wind = 139
BC.HATTR_DE3Earth = 140
BC.HATTR_DE3All = 141

-- 法术等级提升
BC.HATTR_LevelAddFire = 142
BC.HATTR_LevelAddWater = 143
BC.HATTR_LevelAddWind = 144
BC.HATTR_LevelAddEarth = 145
BC.HATTR_LevelAddAll = 146
-- 分系等级提升
BC.HATTR_LevelAdd1Fire = 147
BC.HATTR_LevelAdd1Water = 148
BC.HATTR_LevelAdd1Wind = 149
BC.HATTR_LevelAdd1Earth = 150
BC.HATTR_LevelAdd1All = 151
BC.HATTR_LevelAdd2Fire = 152
BC.HATTR_LevelAdd2Water = 153
BC.HATTR_LevelAdd2Wind = 154
BC.HATTR_LevelAdd2Earth = 155
BC.HATTR_LevelAdd2All = 156
BC.HATTR_LevelAdd3Fire = 157
BC.HATTR_LevelAdd3Water = 158
BC.HATTR_LevelAdd3Wind = 159
BC.HATTR_LevelAdd3Earth = 160
BC.HATTR_LevelAdd3All = 161
-- 大招
BC.HATTR_MGTriggerPro1 = 162
BC.HATTR_MGTriggerPro2 = 163
BC.HATTR_MGTriggerPro3 = 164
BC.HATTR_MGTriggerPro4 = 165

-- 召唤物兵团减伤
BC.HATTR_SummonTeamDamageDec = 166
-- 召唤物法术减伤
BC.HATTR_SummonHeroDamageDec = 167
-- 控制类BUFF时间减免
BC.HATTR_TeamControlDec = 168

-- 分系法伤2
BC.HATTR_AP1Fire1 = 169
BC.HATTR_AP1Water1 = 170
BC.HATTR_AP1Wind1 = 171
BC.HATTR_AP1Earth1 = 172
BC.HATTR_AP1All1 = 173

BC.HATTR_COUNT = BC.HATTR_AP1All1

function BC.resetHeroAttr(hero, attrInc, attrDec)
    -- 需要重算的值有 法伤, 初始蓝, 回蓝, CD, 初始CD, 耗魔, 法术范围
    local heroD = hero.heroD
    local heroAttr = {}
    for i = 1, BC.HATTR_COUNT do
        heroAttr[i] = attrInc[i] - attrDec[i]
    end

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
            return  values 
        end 
        for _type = 1, 3 do
            for _kind = 1, 5 do
                values[_type][_kind] = _heroAttr[_beginIdx] * k
                _beginIdx = _beginIdx + 1
            end
        end
        return values
    end

    -- 蓝相关
    local isEnemyHero = hero.isEnemyHero
    local manaBase = isEnemyHero and hero.manaBase or heroD["manabase"]
    local manaRec = isEnemyHero and hero.manaRec or heroD["manarec"]
    local heroManaBase = max(0, ceil((manaBase + heroAttr[BC.HATTR_Mana]) * ((100 + heroAttr[BC.HATTR_ManaPro]) * 0.01)))
    local heroManaRec = max(0, (manaRec + heroAttr[BC.HATTR_ManaRec]) * ((100 + heroAttr[BC.HATTR_ManaRecPro]) * 0.01))

    -- 法伤
    local heroAp = _setAttr(heroAttr, BC.HATTR_APFire, true)
    local heroAp1 = _setAttr(heroAttr, BC.HATTR_AP1Fire1, true, true)

    -- cd
    local heroCd = _setAttr(heroAttr, BC.HATTR_CDProFire, true)
    local heroInitCd = _setAttr(heroAttr, BC.HATTR_InitCDProFire, true)

    -- 耗蓝
    local heroMCD = _setAttr(heroAttr, BC.HATTR_MCDFire, true)

    -- 范围
    local heroRI = _setAttr(heroAttr, BC.HATTR_RIFire)

    -- 效果翻倍
    local heroDE = _setAttr(heroAttr, BC.HATTR_DEFire)

    --[[
        add by hxp: 添加对方导致自己法术技能等级降低的属性影响
                    在BattleHero构造函数里就把自己的buff加上了,所以这里只考虑对方的buff影响
    ]]

    local heroLevelUp = _setAttr(attrDec, BattleUtils.HATTR_LevelAddFire)

    -- 技能等级
    local heroSkills = hero.skills
    local skillD, skillLevel, _type, _subtype, levelex
    local max = math.max
    for i = 1, #heroSkills do

        --[[
            heroSkill
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
        local heroSkill = heroSkills[i]
        local skillId = heroSkill[1]
        if skillId ~= 0 then
            skillD = tab.playerSkillEffect[skillId]
            skillLevel = heroSkill[2]
            if skillLevel == nil then
                skillLevel = 1
            end
            _type = skillD["type"] - 1
            levelex = 0
            if _type > 0 then
                _subtype = skillD["mgtype"]
                levelex = heroLevelUp[4][5] + heroLevelUp[4][_type] + heroLevelUp[_subtype][5] + heroLevelUp[_subtype][_type]
                -- 最低为1级
                skillLevel = max(skillLevel - levelex , 1)
            end
            heroSkill[2] = skillLevel
        end 
    end

    hero.ap = heroAp
    hero.ap1 = heroAp1
    hero.manaBase = heroManaBase
    hero.manaRec = heroManaRec 

    hero.MCD = heroMCD

    hero.RI = heroRI

    hero.DE = heroDE

    hero.cd = heroCd

    hero.initCd = heroInitCd

    hero.summonTDD = heroAttr[BC.HATTR_SummonTeamDamageDec]
    hero.summonHDD = heroAttr[BC.HATTR_SummonHeroDamageDec]
    hero.teamControlDec = heroAttr[BC.HATTR_TeamControlDec]
end

-- 由于战斗公式计算 牵扯到英雄属性, 所以需要注入英雄
local formula_hero_atkdef = {0, 0}

BC.formula_hero_intack = {0, 0}
local formula_hero_intack = BC.formula_hero_intack

-- 全局护盾加成, 百分比
local ShieldProAdd = {0, 0} -- 分阵营
-- 固定法伤
local H_APAdd = {0, 0}

-- 法伤
local H_AP_1 = {0, 0}
local H_AP_2 = {0, 0} -- 治疗
local H_AP_3 = {0, 0}
BC.H_AP_3 = {0, 0}
-- 效果翻倍
local H_DE_1 = {0, 0}
BC.H_DE_2 = {0, 0}
BC.H_DE_3 = {0, 0}
-- 前置CD
local H_ICD_1 = {0, 0}
local H_ICD_2 = {0, 0}
local H_ICD_3 = {0, 0}
-- cd
local H_CD_1 = {0, 0}
local H_CD_2 = {0, 0}
local H_CD_3 = {0, 0}
-- 减少耗蓝
local H_MCD_1 = {0, 0}
local H_MCD_2 = {0, 0}
local H_MCD_3 = {0, 0}
-- 技能范围增加
local H_RI_1 = {0, 0}
local H_RI_2 = {0, 0}
local H_RI_3 = {0, 0}
-- 法术失败率
BC.H_failedPro = {0, 0}

-- 学院四个大招专用参数
BC.MGTPro = {0, 0}
BC.MGTTag = {0, 0}

-- 召唤物AP加成
local H_SummonApPro = {0, 0}
-- 召唤物兵团免伤
BC.H_SummonTDD = {0, 0}
-- 召唤物法术免伤
BC.H_SummonHDD = {0, 0}

-- 控制类法术BUFF时间减免
local H_TeamControlDec = {0, 0}

-- 魔法天赋
BC.H_SkillBookTalent = {0,0}

function BC.initHero(heros)
    local Heros = heros
    local Hero1 = Heros[1]
    local Hero2 = Heros[2]
    -- 由于存在降低别人的属性, 所以这里英雄的一些属性需要重算
    BC.resetHeroAttr(Hero1, Hero1.attrInc, Hero2.attrDec)
    BC.resetHeroAttr(Hero2, Hero2.attrInc, Hero1.attrDec)

    if BattleUtils.XBW_SKILL_DEBUG then 
        -- dump(Hero1, "hero1", 1)
        -- dump(Hero1.skills, "hero1skill", 20)
        -- dump(Hero1.attr)
        -- dump(Hero1.attr2)
        -- dump(Hero2, "hero2", 1) 
        -- dump(Hero1.skills, "hero2skill", 20)
        -- dump(Hero2.attr)
        -- dump(Hero2.attr2)
        -- local attrDec = Hero1.attrDec
        -- for i = 1, #attrDec do
        --     if attrDec[i] ~= 0 then
        --         print("hero1dec", i, attrDec[i])
        --     end
        -- end
        -- attrDec = Hero2.attrDec
        -- for i = 1, #attrDec do
        --     if attrDec[i] ~= 0 then
        --         print("hero2dec", i, attrDec[i])
        --     end
        -- end

        local heroDebug = function (hero, property)
            -- body
            local label = hero._debugLabel
            if label then
                local debugAttr = hero[property]
                local str = ""
                if type(debugAttr) == "table" then
                    local count = 0
                 for k,v in ipairs(debugAttr) do
                       str = str ..k .."_"..v.. "  " 
                       count = count + 1
                       if count % 8 == 0 then
                         str = str .. "\n"
                       end
                 end
                else
                    str = property .. ":"..debugAttr
                end 


                if hero.str == nil then
                    hero.str = ""
                end 
                str = hero.str .. "\n" .. str
                label:setString(str)
                hero.str = str
            end
        end
        
       for i=1,#BC.HERODEBUG do
           local property = BC.HERODEBUG[i]
           heroDebug(Hero1, property)
           heroDebug(Hero2, property)
       end
       
    end

    -- 参与兵团伤害计算的英雄攻击防御修正值.
    local atk1 = Hero1.atk
    local atk2 = Hero2.atk
    local int1 = Hero1.int
    local int2 = Hero2.int
    local def1 = Hero1.def
    local def2 = Hero2.def
    local ack1 = Hero1.ack
    local ack2 = Hero2.ack
    if atk1 < -300 then atk1 = -300 end
    if atk2 < -300 then atk2 = -300 end
    if int1 < -300 then int1 = -300 end
    if int2 < -300 then int2 = -300 end
    if def1 < -300 then def1 = -300 end
    if def2 < -300 then def2 = -300 end
    if ack1 < -300 then ack1 = -300 end
    if ack2 < -300 then ack2 = -300 end
    formula_hero_atkdef[1] = (1 + 0.0025 * atk1) / (1 + 0.0025 * def2)
    formula_hero_atkdef[2] = (1 + 0.0025 * atk2) / (1 + 0.0025 * def1)

    formula_hero_intack[1] = (1 + 0.0025 * int1) / (1 + 0.0025 * ack2)
    formula_hero_intack[2] = (1 + 0.0025 * int2) / (1 + 0.0025 * ack1)

    ShieldProAdd[1] = 1 + Hero1.shield * 0.01
    ShieldProAdd[2] = 1 + Hero2.shield * 0.01

    H_APAdd[1] = Hero1.apAdd
    H_APAdd[2] = Hero2.apAdd

    -- 伤害类法术 提前加好
    local H_AP = {Hero1.ap, Hero2.ap}
    local H_AP1 = {Hero1.ap1, Hero2.ap1}
    for i = 1, 2 do
        for k = 1, 5 do
            H_AP[i][1][k] = H_AP[i][1][k] + H_AP[i][4][k]
        end
        H_AP_1[i] = H_AP[i][1]
        H_AP_2[i] = H_AP[i][2]
        H_AP_3[i] = H_AP1[i][4]
        BC.H_AP_3[i] = H_AP[i][3]
    end
    -- 效果翻倍
    local H_DE = {Hero1.DE, Hero2.DE}
    local H_ICD = {Hero1.initCd, Hero2.initCd}
    local H_CD = {Hero1.cd, Hero2.cd}
    local H_MCD = {Hero1.MCD, Hero2.MCD}
    local H_RI = {Hero1.RI, Hero2.RI}
    for i = 1, 2 do
        for k = 1, 5 do
            for m = 1, 3 do
                H_DE[i][m][k] = H_DE[i][m][k] + H_DE[i][4][k]
                H_ICD[i][m][k] = H_ICD[i][m][k] + H_ICD[i][4][k]
                H_CD[i][m][k] = H_CD[i][m][k] + H_CD[i][4][k]
                H_MCD[i][m][k] = H_MCD[i][m][k] + H_MCD[i][4][k]
                if m ~= 3 then
                    -- 召唤系范围 单独处理
                    H_RI[i][m][k] = H_RI[i][m][k] + H_RI[i][4][k]
                end
            end
        end
        H_DE_1[i] = H_DE[i][1]
        BC.H_DE_2[i] = H_DE[i][2]
        BC.H_DE_3[i] = H_DE[i][3]
        H_ICD_1[i] = H_ICD[i][1]
        H_ICD_2[i] = H_ICD[i][2]
        H_ICD_3[i] = H_ICD[i][3]
        H_CD_1[i] = H_CD[i][1]
        H_CD_2[i] = H_CD[i][2]
        H_CD_3[i] = H_CD[i][3]
        H_MCD_1[i] = H_MCD[i][1]
        H_MCD_2[i] = H_MCD[i][2]
        H_MCD_3[i] = H_MCD[i][3]
        H_RI_1[i] = H_RI[i][1]
        H_RI_2[i] = H_RI[i][2]
        H_RI_3[i] = H_RI[i][3]
    end

    -- 失败率
    BC.H_failedPro[1] = Hero2.hinder
    BC.H_failedPro[2] = Hero1.hinder

    -- 学院大招几率
    BC.MGTPro[1] = Hero1.MGTPro
    BC.MGTPro[2] = Hero2.MGTPro
    BC.MGTTag = {{false, false, false, false}, {false, false, false, false}}

    -- 召唤物AP加成
    H_SummonApPro[1] = Hero1.summonCount_ApPro * 0.01
    H_SummonApPro[2] = Hero2.summonCount_ApPro * 0.01

    BC.H_SummonTDD[1] = Hero1.summonTDD
    BC.H_SummonTDD[2] = Hero2.summonTDD

    BC.H_SummonHDD[1] = Hero1.summonHDD
    BC.H_SummonHDD[2] = Hero2.summonHDD

    H_TeamControlDec[1] = 1 - Hero1.teamControlDec * 0.01
    H_TeamControlDec[2] = 1 - Hero2.teamControlDec * 0.01

    -- 魔法天赋
    BC.H_SkillBookTalent[1] = Hero1.skillBookTalent
    BC.H_SkillBookTalent[2] = Hero2.skillBookTalent

    if not BATTLE_PROC and GameStatic.checkZuoBi_5 then
        BC.cacheHeroAttr()
    end
end

-- 缓存英雄属性，防止修改
function BC.cacheHeroAttr()
    local sum = 0
    sum = sum + H_APAdd[1] + H_APAdd[2]
    local function _countAttr(tab)
        local _sum = 0
        for i = 1, 2 do
            for k = 1, #tab[i] do
                _sum = _sum + tab[i][k]
            end
        end
        return _sum
    end
    sum = sum + _countAttr(H_AP_1)
    sum = sum + _countAttr(H_AP_2)
    sum = sum + _countAttr(H_AP_3)
    sum = sum + _countAttr(BC.H_AP_3)

    sum = sum + _countAttr(H_DE_1)
    sum = sum + _countAttr(BC.H_DE_2)
    sum = sum + _countAttr(BC.H_DE_3)

    sum = sum + _countAttr(H_ICD_1)
    sum = sum + _countAttr(H_ICD_2)
    sum = sum + _countAttr(H_ICD_3)

    sum = sum + _countAttr(H_CD_1)
    sum = sum + _countAttr(H_CD_2)
    sum = sum + _countAttr(H_CD_3)

    sum = sum + _countAttr(H_MCD_1)
    sum = sum + _countAttr(H_MCD_2)
    sum = sum + _countAttr(H_MCD_3)

    sum = sum + _countAttr(H_RI_1)
    sum = sum + _countAttr(H_RI_2)
    sum = sum + _countAttr(H_RI_3)
    BC.__cacheHeroAttr = sum
    return sum
end
-------------------------------------------------------------------------------------------

local ATTR_Atk = 1            --攻击力
local ATTR_AtkPro = 2         --攻击力%
local ATTR_AtkAdd = 3         --攻击力额外
local ATTR_HP = 4             --生命
local ATTR_HPPro = 5          --生命%
local ATTR_HPAdd = 6          --生命额外
local ATTR_Def = 7            --护甲
local ATTR_Pen = 8            --破甲
local ATTR_Crit = 9           --暴击值
local ATTR_CritD = 10         --暴伤
local ATTR_Resilience = 11    --韧性
local ATTR_Dodge = 12         --闪避值
local ATTR_Hit = 13           --命中值
local ATTR_Haste = 14         --急速值
local ATTR_Hot = 15           --生命回复
local ATTR_Heal = 16          --治疗
local ATTR_HealPro = 17       --治疗%
local ATTR_BeHeal = 18        --被治疗
local ATTR_BeHealPro = 19     --被治疗%
local ATTR_DamageInc = 20     --兵团伤害%
local ATTR_DamageDec = 21     --兵团免伤%
local ATTR_AHP = 22           --吸血
local ATTR_AHPPro = 23        --吸血%
local ATTR_DHP = 24           --反弹
local ATTR_DHPPro = 25        --反弹%
local ATTR_RPhysics = 26      --抗物理%1
local ATTR_RFire = 27         --抗火%1
local ATTR_RWater = 28        --抗水%1
local ATTR_RWind = 29         --抗气%1
local ATTR_REarth = 30        --抗土%1
local ATTR_MSpeed = 31        --移动速度
local ATTR_RAll = 32          --全抗%1
local ATTR_Shiqi = 33         --士气
local ATTR_AtkDis = 34        --攻击距离
local ATTR_DefPro = 35        --护甲%
local ATTR_PenPro = 36        --破防%
local ATTR_DefAdd = 37        --护甲成长
local ATTR_PenAdd = 38        --破甲成长
local ATTR_RPhysics_2 = 39    --抗物理%2
local ATTR_RFire_2 = 40       --抗火%2
local ATTR_RWater_2 = 41      --抗水%2
local ATTR_RWind_2 = 42       --抗气%2
local ATTR_REarth_2 = 43      --抗土%2
local ATTR_RAll_2 = 44        --全抗%2
local ATTR_RPhysics_3 = 45    --抗物理%3
local ATTR_RFire_3 = 46       --抗火%3
local ATTR_RWater_3 = 47      --抗水%3
local ATTR_RWind_3 = 48       --抗气%3
local ATTR_REarth_3 = 49      --抗土%3
local ATTR_RAll_3 = 50        --全抗%3
local ATTR_DecFire = 51       --火系免伤%
local ATTR_DecWater = 52      --水系免伤%
local ATTR_DecWind = 53       --气系免伤%
local ATTR_DecEarth = 54      --土系免伤%
local ATTR_DecAll = 55        --全系免伤%
local ATTR_DecAllEx = 56      --全系免伤_额外
-- 以下这两个属性，成对出现，超过阀值的伤害部分，按照百分比减伤
local ATTR_HDamageDec_Thr = 57  -- 英雄法术减伤血量阀值 threshold
local ATTR_HDamageDec_Pro = 58  -- 英雄法术减伤百分比 

local ATTR_DecFire1 = 59      --火系免伤%
local ATTR_DecWater1 = 60      --水系免伤%
local ATTR_DecWind1 = 61       --气系免伤%
local ATTR_DecEarth1 = 62      --土系免伤%
local ATTR_DecAll1 = 63        --全系免伤%
local ATTR_GlobalAtk = 64      --全局攻击 攻击_%4
local ATTR_GlobalDef = 65      --全局生命 生命_%4
local ATTR_RuneAtk = 66        --宝石攻击
local ATTR_RuneDef = 67        --宝石防御

local ATTR_COUNT = ATTR_RuneDef

local ATTR_Shield = 99    --护盾
local ATTR_ShieldPro = 100--护盾百分比


BC.ATTR_Atk = 1            --攻击力
BC.ATTR_AtkPro = 2         --攻击力%
BC.ATTR_AtkAdd = 3         --攻击力额外
BC.ATTR_HP = 4             --生命
BC.ATTR_HPPro = 5          --生命%
BC.ATTR_HPAdd = 6          --生命额外
BC.ATTR_Def = 7            --护甲
BC.ATTR_Pen = 8            --破甲
BC.ATTR_Crit = 9           --暴击值
BC.ATTR_CritD = 10         --暴伤
BC.ATTR_Resilience = 11    --韧性
BC.ATTR_Dodge = 12         --闪避值
BC.ATTR_Hit = 13           --命中值
BC.ATTR_Haste = 14         --急速值
BC.ATTR_Hot = 15           --生命回复
BC.ATTR_Heal = 16          --治疗
BC.ATTR_HealPro = 17       --治疗%
BC.ATTR_BeHeal = 18        --被治疗
BC.ATTR_BeHealPro = 19     --被治疗%
BC.ATTR_DamageInc = 20     --兵团伤害%
BC.ATTR_DamageDec = 21     --兵团免伤%
BC.ATTR_AHP = 22           --吸血
BC.ATTR_AHPPro = 23        --吸血%
BC.ATTR_DHP = 24           --反弹
BC.ATTR_DHPPro = 25        --反弹%
BC.ATTR_RPhysics = 26      --抗物理%1
BC.ATTR_RFire = 27         --抗火%1
BC.ATTR_RWater = 28        --抗水%1
BC.ATTR_RWind = 29         --抗气%1
BC.ATTR_REarth = 30        --抗土%1
BC.ATTR_MSpeed = 31        --移动速度
BC.ATTR_RAll = 32          --全抗%1
BC.ATTR_Shiqi = 33         --士气
BC.ATTR_AtkDis = 34        --攻击距离
BC.ATTR_DefPro = 35        --护甲%
BC.ATTR_PenPro = 36        --破防%
BC.ATTR_DefAdd = 37        --护甲成长
BC.ATTR_PenAdd = 38        --破甲成长
BC.ATTR_RPhysics_2 = 39    --抗物理%2
BC.ATTR_RFire_2 = 40       --抗火%2
BC.ATTR_RWater_2 = 41      --抗水%2
BC.ATTR_RWind_2 = 42       --抗气%2
BC.ATTR_REarth_2 = 43      --抗土%2
BC.ATTR_RAll_2 = 44        --全抗%2
BC.ATTR_RPhysics_3 = 45    --抗物理%3
BC.ATTR_RFire_3 = 46       --抗火%3
BC.ATTR_RWater_3 = 47      --抗水%3
BC.ATTR_RWind_3 = 48       --抗气%3
BC.ATTR_REarth_3 = 49      --抗土%3
BC.ATTR_RAll_3 = 50        --全抗%3
BC.ATTR_DecFire = 51       --火系免伤%
BC.ATTR_DecWater = 52      --水系免伤%
BC.ATTR_DecWind = 53       --气系免伤%
BC.ATTR_DecEarth = 54      --土系免伤%
BC.ATTR_DecAll = 55        --全系免伤%  
BC.ATTR_DecAllEx = 56      --全系免伤_额外
BC.ATTR_HDamageDec_Thr = 57  -- 英雄法术减伤血量阀值 threshold
BC.ATTR_HDamageDec_Pro = 58  -- 英雄法术减伤百分比 

-- 免伤1
BC.ATTR_DecFire1 = 59      --火系免伤%
BC.ATTR_DecWater1 = 60      --水系免伤%
BC.ATTR_DecWind1 = 61       --气系免伤%
BC.ATTR_DecEarth1 = 62      --土系免伤%
BC.ATTR_DecAll1 = 63        --全系免伤%
BC.ATTR_GlobalAtk = 64      --全局攻击 攻击_%4
BC.ATTR_GlobalDef = 65      --全局生命 生命_%4
BC.ATTR_RuneAtk = 66        --宝石攻击
BC.ATTR_RuneDef = 67        --宝石防御

BC.ATTR_COUNT = BC.ATTR_RuneDef

BC.ATTR_Shield = 99    --护盾
BC.ATTR_ShieldPro = 100--护盾百分比


local K_CRIT = 0.0005
local K_DODGE = 0.0005
local K_ARMOR = 0.1
local K_ASPEED = 0.01
BC.K_CRIT = K_CRIT
BC.K_DODGE = K_DODGE
BC.K_ARMOR = K_ARMOR
BC.K_ASPEED = K_ASPEED

-- 圆桌理论 暴击>闪避>命中
local floor = math.floor
local ceil = math.ceil
function BC.formula_crit_dodge(caster, target)
    local crit, dodge
    local dodgeValue = target.attr[ATTR_Dodge] - caster.hit
    if dodgeValue < 0 then
        dodgeValue = 0
    end
    local critPro = floor(K_CRIT * (caster.crit - target.attr[ATTR_Resilience]) * 10000)
    if critPro > 10000 then
        critPro = 10000
    end
    if critPro < 0 then
        critPro = 0
    end
    local dodgePro = floor(K_DODGE * dodgeValue / (1 + K_DODGE * dodgeValue) * 10000)
    if dodgePro > 10000 then
        dodgePro = 10000
    end
    if dodgePro < 0 then
        dodgePro = 0
    end
    local rand = ran(10000)
    if critPro == 0 then
        crit = false
        if dodgePro == 0 then
            dodge = false
        else
            dodge = 1 <= rand and rand <= dodgePro
        end
    else
        crit = 1 <= rand and rand <= critPro
        if dodgePro == 0 then
            dodge = false
        else
            local min = critPro + 1
            local max = critPro + dodgePro
            if min > 10000 then
                dodge = false
            else
                if max > 10000 then
                    max = 10000
                end
                dodge = min <= rand and rand <= max
            end     
        end    
    end

    return crit, dodge
end
-- 护甲修正
local function formula_armor_modifier(caster, target)
    local level = target.team.level
    local tattr = target.attr
    local def = (tattr[ATTR_Def] + tattr[ATTR_DefAdd] * (level + 9)) * (1 + tattr[ATTR_DefPro] * 0.01)
    if caster.pen >= def then
        return 1 + K_ARMOR * (caster.pen - def) / (caster.level + 9)
    else
        return 1 / (1 + K_ARMOR * (def - caster.pen) / (level + 9)) 
    end
end
-- 暴击修正
local function formula_crit_modifier(caster, crit)
    if crit then
        return 2 + caster.critD * 0.01
    else
        return 1
    end
end
-- 抗性修正
local _ap_beginIdx = ATTR_DecFire - 1
local _ap_beginIdx1 = ATTR_DecFire1 - 1
-- 吸血/反弹
function BC.formula_vampire_modifier(caster, attacker, target, damage, avoidDamage) 
    local pro = caster.aHPPro - target.attr[ATTR_DHPPro]
    local add = attacker.attr[ATTR_AHP] - target.attr[ATTR_DHP]
    local res = ceil(damage * pro * 0.01 + add)
    local res2 = floor(avoidDamage * pro * 0.01)
    return res, res2
end
local formula_vampire_modifier = BC.formula_vampire_modifier
-- 用于生写表, 受击前属性加成
-- skillCharacter表 
--[[
    具体看BC.initTeamSkill 方法
    
    ["type"] = 1
    ["conditiontype"] = 2 或者空
    ==》["attr"] 的属性编号
            ||
            ||
            VV
]]
local targetAttr = 
{
    [ATTR_Def] = 0,         --7
    [ATTR_DefAdd] = 0,      --37
    [ATTR_DefPro] = 0,      --35
    [ATTR_AHPPro] = 0,      --23
    [ATTR_Resilience] = 0,  --11
    [ATTR_Dodge] = 0,       --12
    [ATTR_DamageDec] = 0,   --21
    [ATTR_DecAll] = 0,      --55
    [ATTR_AtkPro] = 0,      --2
    [ATTR_RPhysics] = 0,    --26
    [ATTR_RAll] = 0,        --32
}

-- 普攻/技能伤害 = 技能修正 * 护甲修正 * 暴击修正 * 抗性修正(神圣百分比) + 神圣修正
function BC.countDamage_attack(logic, caster, target, pro, add, maxpro, damageKind, damagePro, castCount)
    local attacker = caster.attacker
    local camp = caster.camp
    local tattr = target.attr
    -- 血量百分比部分伤害
    local maxProDamage = target.maxProDamage
    if attacker == nil then
        if damageKind == 8 then
            -- 器械，真实伤害
            local _damage = add + target.maxHP * pro * 0.01
            if _damage < 1 and _damage ~= 0 then
                _damage = 1
            end
            if target then
                local immuneHeroPro = target._immuneHeroPro
                if immuneHeroPro and immuneHeroPro > 0 and pro > 0 and _damage ~= 0 then
                    --这个时候说明是百分比伤害
                    _damage = (100 - immuneHeroPro) * _damage * 0.01
                    if XBW_SKILL_DEBUG then print(os.clock(), "免疫英雄器械百分比伤害", immuneHeroPro) end
                end
            end

            _damage = ceil(_damage)
            return _damage, false, false, _damage
        end
        -- 英雄
        local dk = damageKind - 1
        local summonApPro = H_SummonApPro[camp]
        if summonApPro > 0 then
            summonApPro = summonApPro * logic.summonCount[camp]
        end
        local doubleEffect
        if dk < 5 and dk > 0 then
            doubleEffect = (ran(100) <= H_DE_1[camp][dk])
        else
            doubleEffect = false
        end
        local maxHP = target.maxHP
        local _proDamage = maxHP * pro * 0.01
        -- 技能限制最大百分比伤害
        if maxpro > 0 and _proDamage > maxpro then
            _proDamage = maxpro
        end
        -- 特殊BOSS限定的最大百分比伤害，是个系数
        if maxProDamage then
            _proDamage = _proDamage * maxProDamage
        end
        local _damage       -- 减伤后
        local _damagePre    -- 减伤前
        

        if dk < 5 and dk > 0 then
            local extraAps = target.team.extraAp
            local fExtraAp = 0
            if #extraAps > 0 then
                local ex
                local attrValue = 0
                local value, min
                for i = 1, #extraAps do
                    ex = extraAps[i]
                    if BC["countExtraDef"..ex[1]] then
                        value = BC["countExtraDef"..ex[1]](logic, target, ex[6], target.camp)
                        if value then
                            min = ex[2]
                            if value < min then
                                value = min
                            elseif value > ex[4] then
                                value = ex[4]
                            end

                            attrValue = attrValue + ex[3] + (value - min) * ex[5] 
                            attrValue = tonumber(format("%.6f", attrValue))

                            --发免
                            fExtraAp = fExtraAp + attrValue

                            if XBW_SKILL_DEBUG then print(os.clock(), "生写法免百分比", fExtraAp) end
                        end
                    end
                end
            end
            -- H_AP_1[camp][5]  全系法伤
            -- H_AP_1[camp][dk] 单系法伤
            -- H_APAdd[camp] 固定法伤
            -- tattr[ATTR_DecAll] + tattr[_ap_beginIdx + dk]  法术免伤
            _damage = (add * ((1 + H_AP_1[camp][5] + H_AP_1[camp][dk] + summonApPro) / ((100 + 0.3 * max(-200, tattr[ATTR_DecAll] + tattr[_ap_beginIdx + dk] + fExtraAp)) * 0.01))
                                * max(0.2, 1 + H_AP_3[camp][5] + H_AP_3[camp][dk] - (tattr[ATTR_DecAll1] + tattr[_ap_beginIdx1 + dk])* 0.01) 
                                + H_APAdd[camp] - tattr[ATTR_DecAllEx])
                                * damagePro * 0.01
                                * formula_hero_intack[camp]

            _damagePre = (add * max(0.2, 1 + H_AP_1[camp][5] + H_AP_1[camp][dk] + summonApPro)
                    * max(0.2, 1 + H_AP_3[camp][5] + H_AP_3[camp][dk]) 
                    + H_APAdd[camp])
                    * damagePro * 0.01
                    * formula_hero_intack[camp]
            --[[
            _damage = (add * max(0.2, 1 + H_AP_1[camp][5] + H_AP_1[camp][dk] + summonApPro - (tattr[ATTR_DecAll] + tattr[_ap_beginIdx + dk]) * 0.01)
                                * max(0.2, 1 + H_AP_3[camp][5] + H_AP_3[camp][dk] - (tattr[ATTR_DecAll1] + tattr[_ap_beginIdx1 + dk])* 0.01) 
                                + H_APAdd[camp] - tattr[ATTR_DecAllEx])
                                * damagePro * 0.01
                                * formula_hero_intack[camp]

            _damagePre = (add * max(0.2, 1 + H_AP_1[camp][5] + H_AP_1[camp][dk] + summonApPro)
                    * max(0.2, 1 + H_AP_3[camp][5] + H_AP_3[camp][dk]) 
                    + H_APAdd[camp])
                    * damagePro * 0.01
                    * formula_hero_intack[camp]
            ]]
        else
            _damage = (add * max(0.2, 1 + summonApPro - tattr[ATTR_DecAll] * 0.01)
                                + H_APAdd[camp] - tattr[ATTR_DecAllEx])
                                * damagePro * 0.01
                                * formula_hero_intack[camp]

            _damagePre = (add * max(0.2, 1 + summonApPro)
                                + H_APAdd[camp])
                                * damagePro * 0.01
                                * formula_hero_intack[camp]
        end
        -- 由于老于的宝物法术数值崩了，所以这边新增一个属性控制法术伤害
        local HP_thr = tattr[ATTR_HDamageDec_Thr]
        if HP_thr > 0 then
            local _pro = tattr[ATTR_HDamageDec_Pro]
            if _pro > 0 then
                if castCount then
                    HP_thr = HP_thr / castCount
                end
                local _hpPro = HP_thr * maxHP * 0.01
                if _damage > _hpPro then
                    _damage = _hpPro + (_damage - _hpPro) * (1 - _pro * 0.01)
                end
            end
        end
        local damage = (_damage + _proDamage) * target.resist[damageKind]
        local damagePre = (_damagePre + _proDamage) * target.resist[damageKind]
                            
        if doubleEffect then
            damage = damage * 2
            damagePre = damagePre * 2
        end
        damage = damage - target.bossDef
        damagePre = damagePre - target.bossDef
        if damage < 1 and damage ~= 0 then
            damage = 1
            damagePre = 1
        end
        local maxDamage = target.maxDamage
        if maxDamage and damage > maxDamage then
            damage = maxDamage
            damagePre = maxDamage
        end
        local immuneHeroPro = target._immuneHeroPro
        if immuneHeroPro and immuneHeroPro > 0 and maxpro > 0 and damage ~= 0 then
            --这个时候说明是百分比伤害
            damage = (100 - immuneHeroPro) * damage * 0.01
            damagePre = (100 - immuneHeroPro) * damagePre * 0.01
            if XBW_SKILL_DEBUG then print(os.clock(), "免疫英雄百分比伤害", immuneHeroPro) end
            
        end

        damage = ceil(damage)
        -- damagePre  减伤前
        -- damage 减伤后
        return damage, doubleEffect, false, ceil(damagePre)
    else
        -- 生写表 受击
        local _proDamage = target.maxHP * maxpro * 0.01
        
        -- 特殊BOSS限定的最大百分比伤害，是个系数
        if maxProDamage then
            _proDamage = _proDamage * maxProDamage
        end
        local crit, dodge = BC.formula_crit_dodge(caster, target)
        local charactersDef, double, kk
        local extraDefs
        local nDamageInc = 0 --生写兵团伤害百分比
        if not dodge then
            for k, _ in pairs(targetAttr) do
                targetAttr[k] = 0
            end

            charactersDef = target.team.charactersDef
            if #charactersDef > 0 then
                local char, key, attr
                for i = 1, #charactersDef do
                    char = charactersDef[i]
                    -- buff效果翻倍：被攻击时检查
                    double = char[6]
                    kk = 1
                    if double == nil then
                        kk = 1
                    elseif double[1] == 3 then
                        if attacker:hasBuffKind(double[2]) then
                            kk = 2
                        end
                    elseif double[1] == 4 then
                        if target:hasBuffKind(double[2]) then
                            kk = 2
                        end
                    end
                    if char[2] == 4 then
                        -- 模拟计算伤害
                        local damage = (caster.atk * pro * 0.01 + add + _proDamage) -- 技能修正
                            * formula_crit_modifier(caster, crit)
                            * formula_armor_modifier(caster, target)
                            * formula_hero_atkdef[camp]
                            * damagePro * 0.01
                            * max(0.2, 1 + (caster.dmgInc - tattr[ATTR_DamageDec]) * 0.01)
                            * target.resist[damageKind]
                            * ((1 + 0.0025 * attacker.attr[ATTR_RuneAtk]) / (1 + 0.0025 * tattr[ATTR_RuneDef]))
                        damage = damage - target.bossDef
                        if damage < 1 then
                            damage = 1
                        end
                        attacker.beDamagePro = damage / attacker.HP * 100
                    end
                    -- 0就是无条件
                    if char[2] == 0 or (ran(100) <= char[1] and BC["countCharacters"..char[2]] and BC["countCharacters"..char[2]](logic,  attacker, target, char[3])) then
                        attr = char[4]

                        -- attacker每有一个debuff,target的防御增加
                        if char[2] == 23 then
                            local count , bufft = attacker:getDebuffLabelCount()
                            if count > 0 then
                                kk = math.min(count, 5)
                            end 
                        end

                        -- 目标或者自身每有一个debuff(同类型的debuff算一个)，攻击者攻击力增加
                        if char[2] == 29 then
                            local count1, bufft1 = attacker:getDebuffLabelCount()
                            local count2, bufft2 = target:getDebuffLabelCount()
                            local count = count1 + count2
                            if count > 0 then
                                kk = math.min(count, 8)
                            end 
                        end

                        local __id
                        for k = 1, #attr do
                            __id = attr[k][1]
                            if targetAttr[__id] then
                                targetAttr[__id] = targetAttr[__id] + attr[k][2] * kk
                            end
                        end
                        if XBW_SKILL_DEBUG then print(os.clock(), "生写被动", char[5]) end
                    end     
                end
            end

            --为了减少判断，所有生写兵团伤害百分比也在这个table，这个字段不光是防御力的控制了
            extraDefs = target.team.extraDef
            if #extraDefs > 0 then
                local ex
                local attrValue = 0
                local value, min
                for i = 1, #extraDefs do
                    ex = extraDefs[i]
                    value = BC["countExtraDef"..ex[1]](logic, target, ex[6], target.camp, attacker)
                    if value then
                        min = ex[2]
                        if value < min then
                            value = min
                        elseif value > ex[4] then
                            value = ex[4]
                        end
                        attrValue = attrValue + ex[3] + (value - min) * ex[5] 
                        attrValue = tonumber(format("%.6f", attrValue))
                        if ex[1] == 20 or ex[1] == 18 then
                            targetAttr[ATTR_DefPro] = targetAttr[ATTR_DefPro] + attrValue
                            if XBW_SKILL_DEBUG then print(os.clock(), "生写防御百分比", target.attr[ATTR_DefPro]) end
                        elseif ex[1] == 22 or ex[1] == 23 then
                            nDamageInc = nDamageInc + attrValue
                            if XBW_SKILL_DEBUG then print(os.clock(), "生写兵团伤害百分比", nDamageInc) end
                        end
                    end
                end
            end

            -- 加属性
            for k, _ in pairs(targetAttr) do
                tattr[k] = tattr[k] + targetAttr[k]
            end
        end

        local damage, atkDamage
        if dodge then
            damage = 0
            atkDamage = 0
        else
            atkDamage = (caster.atk * pro * 0.01 + add + _proDamage) -- 技能修正
                        * formula_crit_modifier(caster, crit)
                        * damagePro * 0.01
            damage = atkDamage
                        * formula_hero_atkdef[camp]
                        * formula_armor_modifier(caster, target)
                        * max(0.2, 1 + (caster.dmgInc - tattr[ATTR_DamageDec] + nDamageInc) * 0.01)
                        * target.resist[damageKind]
                        * ((1 + 0.0025 * attacker.attr[ATTR_RuneAtk]) / (1 + 0.0025 * tattr[ATTR_RuneDef]))
        end
        damage = damage - target.bossDef
        if damage < 1 then
            damage = 1
        end
        local maxDamage = target.maxDamage
        if maxDamage and damage > maxDamage then
            damage = maxDamage
        end

        local immuneTeamPro = target._immuneTeamPro
        if immuneTeamPro and immuneTeamPro > 0 and maxpro > 0 and damage ~= 0  then
            --这个时候说明是百分比伤害
            damage = (100 - immuneTeamPro) * damage * 0.01
            if XBW_SKILL_DEBUG then print(os.clock(), "免疫兵团百分比伤害", immuneTeamPro) end
        end

        --特性表中概率免疫兵团伤害
        local proImmuneTeamDamage = target.team.proImmuneTeamDamage
        if proImmuneTeamDamage and damage ~= 0 and attacker.team then
            local attackType = attacker.team.moveType or -1
            local conAttackType = proImmuneTeamDamage[1] or -1
            local proTeamDamage = proImmuneTeamDamage[2] or 0
            local bIsImmune = false
            if ran(100) <= proTeamDamage then
                --0是所有兵团伤害，1是地面兵团，2是飞行兵团, 
                if conAttackType == 0 then
                    bIsImmune = true
                elseif conAttackType == attackType and conAttackType > 0 then
                    bIsImmune = true
                end
            end
            if bIsImmune then
                damage = 0
                if XBW_SKILL_DEBUG then print(os.clock(), "免疫兵团伤害", conAttackType, proTeamDamage) end
            end
        end

        -- 减属性，前面加了一遍属性这里需要减一遍，保持属性不变
        if (charactersDef and #charactersDef > 0) or 
            (extraDefs and #extraDefs > 0) then
            for k, _ in pairs(targetAttr) do
                tattr[k] = tattr[k] - targetAttr[k]
            end
        end
        return ceil(damage), crit, dodge, ceil(atkDamage)
    end
end
-- 治疗 = ((技能修正 * 治疗% + 治疗额外) * 被治疗% + 被治疗额外)
-- 治疗不能暴击
function BC.countDamage_heal(caster, target, pro, add, maxpro, damageKind, damagePro)
    if caster.attacker == nil then
        -- 玩家
        local camp = caster.camp
        local dk = damageKind - 1
        local _proHeal = target.maxHP * pro * 0.01
        if maxpro > 0 and _proHeal > maxpro then
            _proHeal = maxpro
        end
        local tattr = target.attr
        local behealpro = tattr[ATTR_BeHealPro]
        if behealpro < -100 then
            behealpro = -100
        end
        local heal
        if dk < 5 and dk > 0 then
            heal = (_proHeal + add * (1 + 0.4 * (H_AP_1[camp][5] + H_AP_1[camp][dk])))
                        * (1 + H_AP_2[camp][5] + H_AP_2[camp][dk])
                        * damagePro * 0.01
        else
            heal = (_proHeal + add)
                        * damagePro * 0.01            
        end
        -- dump(H_AP_1)
        -- print(_proHeal, add, 1 + 0.6 * (H_AP_1[camp][5] + H_AP_1[camp][dk]), 1 + H_AP_2[camp][5] + H_AP_2[camp][dk], (100 + behealpro) * 0.01, tattr[ATTR_BeHeal])
        heal = heal * (100 + behealpro) * 0.01 + tattr[ATTR_BeHeal]
        heal = ceil(heal)
        return heal, false, false
    else
        local tattr = target.attr
        local behealpro = tattr[ATTR_BeHealPro]
        if behealpro < -100 then
            behealpro = -100
        end
        local heal = (caster.atk * pro * 0.01 + add + target.maxHP * maxpro * 0.01) -- 技能修正
                    * damagePro * 0.01
        heal = heal * (100 + caster.healPro) * 0.01 + caster.heal
        heal = heal * (100 + behealpro) * 0.01 + tattr[ATTR_BeHeal]
        heal = ceil(heal)

        return heal, false, false
    end
end
-- DOT伤害 = 技能修正 * 护甲修正 * 抗性修正(神圣百分比)
local function countDamage_dot(caster, target, value, damageKind)
    local damage
    local tattr = target.attr
    local camp = caster.camp
    if caster.attacker == nil then
        -- 英雄
        if damageKind == 8 then
            -- 器械，真实伤害
            local _damage = ceil(value)
            if _damage < 1 then
                _damage = 1
            end
            return _damage, _damage
        end
        local dk = damageKind - 1
        if dk < 5 and dk > 0 then
            damage = (value
                            * max(0.2, 1 + H_AP_1[camp][5] + H_AP_1[camp][dk] - (tattr[ATTR_DecAll] + tattr[_ap_beginIdx + dk]) * 0.01)
                            + H_APAdd[camp] - tattr[ATTR_DecAllEx])
                            * formula_hero_intack[camp]
                            * target.resist[damageKind]
        else
            damage = (value
                            * max(0.2, 1 - tattr[ATTR_DecAll] * 0.01)
                            + H_APAdd[camp] - tattr[ATTR_DecAllEx])
                            * formula_hero_intack[camp]
                            * target.resist[damageKind]
        end
        damage = damage - target.bossDef
        if damage < 1 and damage ~= 0 then
            damage = 1
        end
    else
        damage = value
                    * formula_armor_modifier(caster, target)
                    * formula_hero_atkdef[camp]
                    * max(0.2, 1 + (caster.dmgInc - tattr[ATTR_DamageDec]) * 0.01)
                    * target.resist[damageKind]
                    * ((1 + 0.0025 * caster.attacker.attr[ATTR_RuneAtk]) / (1 + 0.0025 * tattr[ATTR_RuneDef]))
    end
    damage = damage - target.bossDef
    if damage < 1 then
        damage = 1
    end
    local maxDamage = target.maxDamage
    if maxDamage and damage > maxDamage then
        damage = maxDamage
    end
    return ceil(damage), ceil(value)
end
-- HOT = 技能修正 * 治疗% * 被治疗%
local function countDamage_hot(caster, target, value, damageKind)
    -- ATTR_BeHealPro 移动到hot第一次生效的时候去计算
    -- local behealpro = target.attr[ATTR_BeHealPro]
    -- if behealpro < -100 then
    --     behealpro = -100
    -- end
    local heal
    if caster.attacker == nil then
        -- 玩家
        local dk = damageKind - 1
        local camp = caster.camp
        if dk < 5 and dk > 0 then
            heal = value
                        * (1 + 0.4 * (H_AP_1[camp][5] + H_AP_1[camp][dk]))
                        * (1 + H_AP_2[camp][5] + H_AP_2[camp][dk])
                        -- * (100 + behealpro) * 0.01
        else
            heal = value
                        -- * (100 + behealpro) * 0.01
        end
    else
        heal = value
                    * (100 + caster.healPro) * 0.01
                    -- * (100 + behealpro) * 0.01
    end
    return ceil(heal)
end

-- fps间隔
-- 后面这个1是为了弥补lua精度问题, 这样能保证只会大于某个整数
--            0.00000000000xx 这面这两位有精度问题, 有时+1, 有时-1
BC.frameInv = 0.0250000001
local frameInv = BC.frameInv
-- 动作fps间隔
BC.actionInv = 0.05

-- 逻辑tick
BC.BATTLE_TICK = 0
BC.BATTLE_DELTA = 0
BC.BATTLE_DISPLAY_TICK = 0
function BC.tickInit()
    BC.BATTLE_TICK = 0
end

function BC.tickUpdate()
    BC.BATTLE_DELTA = frameInv
    BC.BATTLE_TICK = BC.BATTLE_TICK + BC.BATTLE_DELTA
end

function BC.displayTickUpdate()
    BC.BATTLE_DISPLAY_TICK = BC.BATTLE_DISPLAY_TICK + frameInv
end

-- BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关
-- BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关 BUFF相关

-- 全局buff替换 {{[1001] = 1002}, {}}
BC.BuffReplace = {{}, {}} -- 分阵营
-- 全局buff隐藏列开启, 由英雄专长开启 {{[label] = {true, false, false}}, {}}
BC.BuffOpen = {{}, {}} 

function BC.countTeamBuffAdd(team)
    local buffs = team.buff
    local buffD
    local shiqi = 0
    local moveSpeed = team.baseSpeedAdd
    local addattr
    if next(buffs) ~= nil then
        for k, buff in pairs(buffs) do
            buffD = buff.buffD
            -- 如果是buff/debuff
            if buffD["kind"] == 0 or buffD["kind"] == 1 then
                addattr = buffD["addattr"]
                if addattr then
                    for i = 1, #addattr do
                        if addattr[i][1] == ATTR_Shiqi then
                            shiqi = shiqi + buff.value[i] * buff.count
                        elseif addattr[i][1] == ATTR_MSpeed then
                            moveSpeed = moveSpeed + buff.value[i] * buff.count
                        end
                    end
                end
            end
        end
    end
    if moveSpeed ~= team.speedAdd then
        team.speedDirty = true
        team.speedAdd = moveSpeed
    end
    team.shiqi = team.baseShiqi + shiqi
end



local RESIST_KEY = 
{
    {ATTR_RPhysics, ATTR_RPhysics_2, ATTR_RPhysics_3},
    {ATTR_RFire, ATTR_RFire_2, ATTR_RFire_3}, 
    {ATTR_RWater, ATTR_RWater_2, ATTR_RWater_3},
    {ATTR_RWind, ATTR_RWind_2, ATTR_RWind_3},
    {ATTR_REarth, ATTR_REarth_2, ATTR_REarth_3}, 
    {ATTR_RAll, ATTR_RAll_2, ATTR_RAll_3}
}
local RK6 = RESIST_KEY[6]
-- 统计所有BUFF的属性加成
local commonBuffAdd = {}
for i = ATTR_Atk, ATTR_COUNT do
    commonBuffAdd[i] = {false, 0}
end
function BC.countBuffAdd(soldier)
    if not BATTLE_PROC then
        if GameStatic.checkZuoBi_1 then
            -- 给baseSum赋值, 结束的时候检查
            if soldier.baseSum == nil then
                local baseSum = 0
                local _baseAttr = soldier.baseAttr
                for i = ATTR_Atk, ATTR_COUNT do
                    baseSum = baseSum + _baseAttr[i]
                end
                soldier.baseSum = baseSum
            end
            if not BC.zuobi then
                if soldier.attrSum then
                    local attrSum = 0
                    local _attr = soldier.attr
                    for i = ATTR_Atk, ATTR_COUNT do
                        attrSum = attrSum + _attr[i]
                    end
                    attrSum = attrSum + soldier.atk
                    if abs(soldier.attrSum - attrSum) > 0.001 then
                        BC.zuobi = 2
                    end
                end
            end
        end
    end
    local buffAdd = commonBuffAdd
    local canMove = true
    local canAttack = true
    local canSkill = true
    local windFly = false
    local minHP = 0
    local bandie = false
    local immune = {false, false, false, false, false}
    local still = false
    local dmghealrvt = false
    local dmgrvt1 = false  
    local dmgrvt2 = false 
    local healrvt1 = false
    local healrvt2 = false  
    local banfuhuo = 0
    for i = ATTR_Atk, ATTR_COUNT do
        buffAdd[i][1] = false
        buffAdd[i][2] = 0
    end
    local counterBuff = {}
    local scale
    if soldier.team.leagueBuff then
        scale = 1.2
    else
        scale = 1.0
    end
    local buffs = soldier.buff
    local buffD
    local attr, buffa
    local addattr
    local label
    local buffOpen
    local saturation = 0
    local _immnue
    local immuneTeamPro = 0
    local immuneHeroPro = 0
    local immuneTeamAttackPro = 0
    --应策划需求加了一个隐藏模型的效果（只有显示，不参与计算逻辑）
    local isVisible = false
    -- 控制吸血/反弹 效果
    local isAntiInjury = false
    -- buff 控制debuff的时间
    local reduceBuffTime = {}
    soldier.buffimmuneBuff = {}
    if next(buffs) ~= nil then
        for k, buff in pairs(buffs) do
            buffD = buff.buffD
            if buffD["scale"] then
                scale = scale + (buffD["scale"] - 1) * buff.count
            end
            local hb = buffD["hitbuff"]
            if hb then
                local lv = counterBuff[hb]
                if lv == nil or buff.level > lv then
                    counterBuff[hb] = buff.level
                end
            end
            -- 如果是buff/debuff
            if buffD["kind"] == 0 or buffD["kind"] == 1 then
                addattr = buffD["addattr"]
                if addattr then
                    for i = 1, #addattr do
                        attr = addattr[i][1]
                        if attr < ATTR_Shield then
                            buffa = buffAdd[attr]
                            buffa[1] = true
                            -- 正值和负值跟buff/debuff标签无关
                            buffa[2] = buffa[2] + buff.value[i] * buff.count
                        end
                    end
                end
                -- 隐藏属性 根据label
                label = buffD["label"]
                buffOpen = BC.BuffOpen[buff.camp][label]
                if buffOpen then
                    for i = 1, 3 do
                        if buffOpen[i] then
                            addattr = buffD["addattr"..i]
                            if addattr then
                                for m = 1, #addattr do
                                    attr = addattr[m][1]
                                    if attr < ATTR_Shield then
                                        -- print(attr, buff.valueEx[i][m] * buff.count)
                                        buffa = buffAdd[attr]
                                        buffa[1] = true
                                        -- 正值和负值跟buff/debuff标签无关
                                        buffa[2] = buffa[2] + buff.valueEx[i][m] * buff.count
                                    end
                                end
                            end
                        end
                    end
                end
                if buffD["banmove"] == 1 then
                    canMove = false
                end
                if buffD["windFly"] == 1 then
                    windFly = true
                end
                if buffD["banattack"] == 1 then
                    canAttack = false
                end
                if buffD["banskill"] == 1 then
                    canSkill = false
                end
                if buffD["bandie"] == 1 then
                    minHP = 1
                    bandie = true
                end
                if buffD["still"] == 1 then
                    still = true
                end
                if buffD["isVisible"] and buffD["isVisible"] == 1 and not isVisible then
                    isVisible = true
                end
                _immnue = buffD["immune"]
                if _immnue then
                    for i = 1, 8 do
                        if _immnue[i] == 1 then
                            immune[i] = true
                        end
                    end 
                end
                if buffD["dmgrvt1"] == 1 then
                    dmghealrvt = true
                    dmgrvt1 = true
                end
                if buffD["dmgrvt2"] == 1 then
                    dmghealrvt = true
                    dmgrvt2 = true
                end
                if buffD["healrvt1"] == 1 then
                    dmghealrvt = true
                    healrvt1 = true
                end
                if buffD["healrvt2"] == 1 then
                    dmghealrvt = true
                    healrvt2 = true
                end
                if buffD["saturation"] then
                    saturation = saturation + buffD["saturation"]
                end
                if buffD["banfuhuo"] then
                    banfuhuo = buffD["banfuhuo"]
                end
                if buffD["immunebuff"] then
                    for key, var in ipairs(buffD["immunebuff"]) do
                        if var then
                            soldier.buffimmuneBuff[var] = true
                        end
                    end
                end
                if buffD["immunePercentDamage"] then
                    if buffD["immunePercentDamage"][1] == 2 then
                        immuneTeamPro = immuneTeamPro + buffD["immunePercentDamage"][2]
                    elseif buffD["immunePercentDamage"][1] == 1 then
                        immuneHeroPro = immuneHeroPro + buffD["immunePercentDamage"][2]
                    elseif buffD["immunePercentDamage"][1] == 3 then
                        immuneTeamAttackPro = immuneTeamAttackPro + buffD["immunePercentDamage"][2]
                    end
                end
                if buffD["isAntiInjury"] and buffD["isAntiInjury"] == 1 then
                    isAntiInjury = true
                end
                if buffD["reduceBuffTime"] then
                    reduceBuffTime[buffD["reduceBuffTime"][1]] = (reduceBuffTime[buffD["reduceBuffTime"][1]] or 0) + buffD["reduceBuffTime"][2]
                end
            end
        end
    end
    if soldier.immuneForbidMove then
        if not soldier.canMove then
            soldier.team.canMoveDirty = true
        end
        soldier.canMove = true
    else
        if soldier.canMove ~= canMove then
            soldier.team.canMoveDirty = true
        end
        soldier.canMove = canMove
    end
    if soldier.immuneForbidAttack then
        soldier.canAttack = true
    else
        soldier.canAttack = canAttack
    end
    if soldier.immuneForbidSkill then
        soldier.canSkill = true
    else
        soldier.canSkill = canSkill
    end
    soldier.minHP = minHP
    soldier.bandie = bandie
    soldier.still = still
    soldier.immune = immune[1]
    soldier.immune_skill[2] = immune[2]
    soldier.immune_skill[3] = immune[3]
    soldier.immune_skill[4] = immune[4]
    soldier.immune_skill[5] = immune[5]
    soldier.immune_skill[8] = immune[8]

    
    
    if soldier._worldBoss then
--        print("-------------------", buffAdd[ATTR_DefPro][2])
        --针对世界娜迦减低护甲%（ATTR_DefPro）是的伤害爆炸，这里对世界boss减低防御做了控制
        if buffAdd[ATTR_DefPro] and buffAdd[ATTR_DefPro][1] then
            buffAdd[ATTR_DefPro][2] = 0
        end
        local _baseAttr = soldier.baseAttr
        --针对世界boss减法抗，做了一个限制
         for i = ATTR_DecFire, ATTR_DecAll do
             if buffAdd[i] and buffAdd[i][1] and _baseAttr[i] and (_baseAttr[i] + buffAdd[i][2]) <= -250 then
                 buffAdd[i][2] = _baseAttr[i] - 250
             end
         end
    end

    local _attr = soldier.attr
    if not BATTLE_PROC and GameStatic.checkZuoBi_1 then
        local attrSum = 0
        local _baseAttr = soldier.baseAttr
        for i = ATTR_Atk, ATTR_COUNT do
            if buffAdd[i][1] then
                _attr[i] = _baseAttr[i] + buffAdd[i][2]
            else
                _attr[i] = _baseAttr[i]
            end
            attrSum = attrSum + _attr[i]
        end
        soldier.attrSum = attrSum
    else
        local _baseAttr = soldier.baseAttr
        for i = ATTR_Atk, ATTR_COUNT do
            if buffAdd[i][1] then
                _attr[i] = _baseAttr[i] + buffAdd[i][2]
            else
                _attr[i] = _baseAttr[i]
            end
        end
    end
    -- 抗性速算
    local RKI
    for i = 1, #soldier.resist do
        RKI = RESIST_KEY[i]
        if RKI == nil then break end
        soldier.resist[i] = 
            (100 - _attr[RKI[1]] - _attr[RK6[1]])
            * (100 - _attr[RKI[2]] - _attr[RK6[2]])
            * (100 - _attr[RKI[3]] - _attr[RK6[3]])
            * 0.000001
    end
    -- 添加符文宝石的专属buff : ATTR_GlobalAtk 和 ATTR_GlobalDef
    local atk = (_attr[ATTR_Atk] * (100 + _attr[ATTR_AtkPro]) * 0.01
        + _attr[ATTR_AtkAdd])
    if atk < 1 then
        atk = 1
    end
    atk = atk * ((100 + _attr[ATTR_GlobalAtk] * (100 + 0.3 * _attr[ATTR_GlobalAtk]) / (100  + _attr[ATTR_GlobalAtk])) * 0.01)
    soldier.atk = ceil(atk)
    if not BATTLE_PROC and GameStatic.checkZuoBi_1 then
        soldier.attrSum = soldier.attrSum + soldier.atk
    end
    local hp = (_attr[ATTR_HP] * (100 + _attr[ATTR_HPPro]) * 0.01
        + _attr[ATTR_HPAdd])
    if hp < 1 then
        hp = 1
    end
    hp = hp * ((100 + _attr[ATTR_GlobalDef] * (100 + 0.3 * _attr[ATTR_GlobalDef]) / (100  + _attr[ATTR_GlobalDef])) * 0.01)
    soldier.maxHP = ceil(hp)
    if scale > 2.0 then
        scale = 2.0
    end
    if scale < 0.5 then
        scale = 0.5
    end
    soldier.counterBuff = counterBuff
    soldier.scale = scale
    soldier.windFly = windFly

    soldier.dmghealrvt = dmghealrvt
    soldier.dmgrvt1 = dmgrvt1  
    soldier.dmgrvt2 = dmgrvt2 
    soldier.healrvt1 = healrvt1
    soldier.healrvt2 = healrvt2  
    soldier.banfuhuo = banfuhuo  

    if soldier.saturation ~= saturation then
        soldier.saturation = saturation
        soldier.saturationDirty = true
    end
    
    soldier._isVisible = isVisible
    soldier._immuneTeamPro = immuneTeamPro
    soldier._immuneHeroPro = immuneHeroPro
    soldier._immuneTeamAttackPro = immuneTeamAttackPro
    soldier._isAntiInjury = isAntiInjury
    soldier._reduceBuffTime = reduceBuffTime
end

-- 计算护盾免伤后的伤害
function BC.countBuffShield(soldier, damage)
    local lastDamage = -damage
    local buffs = soldier.buff
    local buffD
    local reset = false
    if next(buffs) ~= nil then
        for k, buff in pairs(buffs) do
            buffD = buff.buffD
            if buffD["kind"] == 0 then
                if buff.shield > 0 then
                    if buff.shield > lastDamage then
                        buff.shield = buff.shield - lastDamage
                        if reset then soldier:resetAttr() end
                        return 0
                    else
                        lastDamage = lastDamage - buff.shield
                        soldier:delBuff(k)
                        reset = true
                    end 
                    if lastDamage <= 0 then
                        if reset then soldier:resetAttr() end
                        return 0
                    end
                end
            end
        end
    end
    if reset then soldier:resetAttr() end
    return -lastDamage
end

-- buff有可能来自怪兽或者玩家
-- buff的持续时间成长
--  1. 怪兽 技能等级
--  2. 玩家 技能槽
-- buff的数值成长
--  1. 怪兽 技能等级
--  2. 玩家 玩家等级
-- 初始化来自怪兽的BUFF
-- dot/hot的取值有可能跟释放者的攻击力和目标的生命有关
function BC.initSoldierBuff(id, skilllevel, caster, target, fromSkillId)
    local camp = caster.camp
    local buffD
    -- buff替换
    if BC.BuffReplace[camp][id] then
        buffD = tab.skillBuff[BC.BuffReplace[camp][id]]
    else
        buffD = tab.skillBuff[id]
    end
    local buffid = buffD["id"]
    if buffD == nil then
        print("buff ID 不存在 " .. id)
    end
    if buffD["bufftype"] ~= 1 then
        -- print("buffid: "..id.." 为怪兽buff")
    end
    local skilladd = skilllevel - 1
    -- 持续时间
    local duration = buffD["last1"][1] + skilladd * buffD["last1"][2]
    local baseduration = duration
    local value = {0}
    local valueEx
    local shield = 0
    local hurt = 0
    local maxhurt = 0
    local buffOpen
    local _kind = buffD["kind"]
    if _kind == 0 or _kind == 1 then
        -- buff/debuff
        if 0 == _kind then
            if caster.attacker and caster.attacker.team.runeBuffEffect then
                local condition = caster.attacker.team.runeBuffEffect.condition
                local value = caster.attacker.team.runeBuffEffect.value
                if 18 == condition then
                    duration = duration * (100 + value) * 0.01
                end
            end
        end

        --目标的被动技能减少buff的持续时间
        local _nBuffLabel = buffD["label"]
        if target and target.team and target.team.skillPassiveBuff and target.team.skillPassiveBuff[_nBuffLabel] then
            duration = duration * (100 + target.team.skillPassiveBuff[_nBuffLabel]) * 0.01
            if duration < 0 then
                duration = 0
            end
        end 

        --buff 控制debuff的持续时间
        if target and target._reduceBuffTime and target._reduceBuffTime[_nBuffLabel] then
            local curDuration = baseduration * target._reduceBuffTime[_nBuffLabel] * 0.01
            duration = duration + curDuration
            if duration < 0 then
                duration = 0
            end
        end

        local addattr = buffD["addattr"]
        if addattr and #addattr > 0 then
            local valueRuneEffect = 0
            if caster.attacker and caster.attacker.team.runeBuffEffect then
                local condition = caster.attacker.team.runeBuffEffect.condition
                local value = caster.attacker.team.runeBuffEffect.value
                if 19 == condition or 20 == condition then
                    valueRuneEffect = value
                end
            end
            for i = 1, #addattr do
                if addattr[i][1] < ATTR_Shield then
                    value[i] = addattr[i][2] + skilladd * addattr[i][3]
                    value[i] = ceil(value[i] * (100 + valueRuneEffect) * 0.01)
                elseif addattr[i][1] == ATTR_Shield then
                    -- 护盾
                    shield = shield + ceil((addattr[i][2] + skilladd * addattr[i][3]) * ShieldProAdd[camp])
                else
                    -- 百分比护盾
                    shield = shield + ceil((addattr[i][2] + skilladd * addattr[i][3]) * 0.01 * target.maxHP * ShieldProAdd[camp])
                end
            end
        end
        buffOpen = BC.BuffOpen[camp][buffD["label"]]
        if buffOpen then
            valueEx = {}
            for m = 1, 3 do
                if buffOpen[m] then
                    addattr = buffD["addattr"..m]
                    if addattr and #addattr > 0 then
                        valueEx[m] = {}
                        for i = 1, #addattr do
                            if addattr[i][1] < ATTR_Shield then
                                valueEx[m][i] = ceil(addattr[i][2] + skilladd * addattr[i][3])
                            elseif addattr[i][1] == ATTR_Shield then
                                -- 护盾
                                shield = shield + ceil((addattr[i][2] + skilladd * addattr[i][3]) * ShieldProAdd[camp])
                            else
                                -- 百分比护盾
                                shield = shield + ceil((addattr[i][2] + skilladd * addattr[i][3]) * 0.01 * target.maxHP * ShieldProAdd[camp])
                            end
                        end
                    end
                end
            end
        end      
    elseif _kind == 2 or _kind == 3 then
        -- dot/hot
        local _type = buffD["type"]
        -- 8是概率加buff
        if _type ~= 8 then
            if _type == 1 or _type == 4 then
                -- caster攻击力
                value[1] = buffD["hurt"][1] + skilladd * buffD["hurt"][2]
                value[1] = caster.atk * value[1] * 0.01
            elseif _type == 2 or _type == 5 then
                -- target最大血量
                value[1] = buffD["hurt"][1] + skilladd * buffD["hurt"][2]
                value[1] = target.maxHP * value[1] * 0.01
                if buffD["maxhurt"] and buffD["maxhurt"][1] and buffD["maxhurt"][2] then
                    local maxhurt = buffD["maxhurt"][1] + skilladd * buffD["maxhurt"][2]
                    value[1] = math.min(value[1], maxhurt)
                end
            elseif _type == 3 or _type == 6 then
                -- 固定值
                value[1] = buffD["hurt"][1] + skilladd * buffD["hurt"][2]
            elseif _type == 7 then
                -- target当前血量
                value[1] = buffD["hurt"][1] + skilladd * buffD["hurt"][2]
                value[1] = target.HP * value[1] * 0.01      
            end
            -- 计算伤害
            if _kind == 2 then
                value[1], hurt = countDamage_dot(caster, target, value[1], buffD["dottype"])
            else
                -- hot的被治疗效果，第一次生效的时候再计算
                -- 这里用正负来判断，是否计算过
                value[1] = -countDamage_hot(caster, target, value[1], buffD["dottype"])
            end
        end
    end
    local result = BC.initBuff(buffD, skilllevel, duration, value, valueEx, shield, caster.attacker, hurt, camp, target.camp, false)
    -- buff的来源技能id
    result.fromSkillId = fromSkillId
    return result
end

-- 初始化来自玩家的BUFF
-- dot/hot的取值有可能和目标生命有关
-- pro为法强修正

function BC.initPlayerBuff(camp, id, level, target, pro, dk, doubleEffect, fromSkillId)
    local buffD
    -- buff替换
    if BC.BuffReplace[camp][id] then
        buffD = tab.skillBuff[BC.BuffReplace[camp][id]]
    else
        buffD = tab.skillBuff[id]
    end
    if buffD == nil then
        print("buff ID 不存在 " .. id)
    end
    local buffid = buffD["id"]
    if buffD["bufftype"] ~= 2 then
        -- print("buffid: "..id.." 为怪兽buff")
    end

    local leveladd = level - 1
    local duration = buffD["last1"][1] + leveladd * buffD["last1"][2]
    local baseduration = duration
    --目标的被动技能减少buff的持续时间
    local _nBuffLabel = buffD["label"]
    if target and target.team and target.team.skillPassiveBuff and target.team.skillPassiveBuff[_nBuffLabel] then
        duration = duration * (100 + target.team.skillPassiveBuff[_nBuffLabel]) * 0.01
        if duration < 0 then
            duration = 0
        end
    end 

    --buff 控制debuff的持续时间
    if target and target._reduceBuffTime and target._reduceBuffTime[_nBuffLabel] then
        local curDuration = baseduration * target._reduceBuffTime[_nBuffLabel] * 0.01
        duration = duration + curDuration
        if duration < 0 then
            duration = 0
        end
    end

    local value = {0}
    local valuePro = 1 + H_AP_2[camp][5] 
    if dk < 5 and dk > 0 then
        valuePro = valuePro + H_AP_2[camp][dk]
    end
    if doubleEffect then
        valuePro = valuePro * 2
    end
    local valueEx
    local shield = 0
    local hurt = 0
    local maxhurt = 0
    local buffOpen
    local _kind = buffD["kind"]
    if _kind == 0 or _kind == 1 then
        -- buff/debuff
        local addattr = buffD["addattr"]
        local addattri
        if addattr and #addattr > 0 then
            for i = 1, #addattr do
                addattri = addattr[i]
                if addattri[1] < ATTR_Shield then
                    value[i] = ceil((addattri[2] + leveladd * addattri[3]) * valuePro)
                elseif addattri[1] == ATTR_Shield then
                    -- 护盾
                    shield = shield + ceil((addattri[2] + leveladd * addattri[3]) * ShieldProAdd[camp] * (1 + 0.4 * (H_AP_1[camp][5] + H_AP_1[camp][dk])))
                else
                    -- 百分比护盾
                    shield = shield + ceil((1 + (addattri[2] + leveladd * addattri[3]) * 0.01) * target.maxHP * ShieldProAdd[camp])
                end
            end
        end
        buffOpen = BC.BuffOpen[camp][buffD["label"]]
        if buffOpen then
            valueEx = {}
            for m = 1, 3 do
                if buffOpen[m] then
                    addattr = buffD["addattr"..m]
                    if addattr and #addattr > 0 then
                        valueEx[m] = {}
                        for i = 1, #addattr do
                            addattri = addattr[i]
                            if addattri[1] < ATTR_Shield then
                                valueEx[m][i] = ceil((addattri[2] + leveladd * addattri[3]) * valuePro)
                            elseif addattri[1] == ATTR_Shield then
                                -- 护盾
                                shield = shield + ceil((addattri[2] + leveladd * addattri[3]) * ShieldProAdd[camp] * (1 + 0.4 * (H_AP_1[camp][5] + H_AP_1[camp][dk])))
                            else
                                -- 百分比护盾
                                shield = shield + ceil((1 + (addattri[2] + leveladd * addattri[3]) * 0.01) * target.maxHP * ShieldProAdd[camp])
                            end
                        end
                    end
                end
            end
        end  
    elseif _kind == 2 or _kind == 3 then
        local _type = buffD["type"]
        -- dot/hot
        -- 8是概率加buff
        if _type ~= 8 then
            if _type == 1 or _type == 4 then
                -- error
                print("玩家buff的type不能是".._type)
            elseif _type == 2 or _type == 5 then
                -- target最大血量
                value[1] = buffD["hurt"][1] + leveladd * buffD["hurt"][2]
                value[1] = target.maxHP * value[1] * 0.01
                if buffD["maxhurt"] and buffD["maxhurt"][1] and buffD["maxhurt"][2] then
                    local maxhurt = buffD["maxhurt"][1] + leveladd * buffD["maxhurt"][2]
                    value[1] = math.min(value[1], maxhurt)
                end
            elseif _type == 3 or _type == 6 then
                -- 固定值
                value[1] = buffD["hurt"][1] + leveladd * buffD["hurt"][2]
            elseif _type == 7 then
                -- target当前血量
                value[1] = buffD["hurt"][1] + leveladd * buffD["hurt"][2]
                value[1] = target.HP * value[1] * 0.01      
            end
            -- 计算伤害
            --- dongcheng 这里是英雄造成的BUFF 暂不支持减免免疫 2018.05.25
            if _kind == 2 then
--                value[1], hurt = countDamage_dot(nil, target, value[1], buffD["dottype"])
                value[1], hurt = value[1], hurt
--            else
----                value[1] = -countDamage_hot(nil, target, value[1], buffD["dottype"])
--                value[1] = -countDamage_hot(target.caster, target, value[1], buffD["dottype"])
            end
            value[1] = ceil(value[1] * pro * 0.01)
        end
    end

    local result = BC.initBuff(buffD, level, duration, value, valueEx, shield, nil, hurt, camp, target.camp, true)
    result.fromSkillId = fromSkillId
    return result
end

function BC.genRanBuff(ranbuff, ranbuffnum)
    if not (ranbuff and ranbuffnum) then return {} end
    local buffids = {}
    local count = #ranbuff
    if count == ranbuffnum then
        for i = 1, count do
            table.insert(buffids, ranbuff[i][1])
        end
        -- dump(buffids, "buffids")
        return buffids
    end

    local cachebuffids = {}

    local pick = function(total)
        local rd = ran(total)
        local sum, id, wi, found = 0, 0, 0, false
        for i = 1, #ranbuff do
            repeat
                id = ranbuff[i][1]
                wi = ranbuff[i][2]
                if cachebuffids[id] then break end
                sum = sum + wi
                if sum >= rd then
                    table.insert(buffids, id)
                    cachebuffids[id] = true
                    found = true
                end
            until true
            if found then
                break
            end
        end
    end

    count = math.min(#ranbuff, ranbuffnum)

    for i = 1, count do
        local total, id, wi = 0, 0, 0
        for i = 1, #ranbuff do
            repeat
                id = ranbuff[i][1]
                wi = ranbuff[i][2]
                if cachebuffids[id] then break end
                total = total + wi
            until true
        end
        pick(total)
    end
    -- dump(buffids, "buffids")
    return buffids
end

--  持续时间, 单位为ms
-- value为具体数值 本身是个数组
function BC.initBuff(buffD, level, duration, value, valueEx, shield, attacker, hurt, camp, tarCamp, isPlayer)
    local _duration
    local ban = buffD["banmove"] == 1 or buffD["banattack"] == 1 or buffD["banskill"] == 1
    if ban then
        -- 减少控制时间， H_TeamControlDec为剩余百分比
        _duration = duration * H_TeamControlDec[tarCamp]
    else
        _duration = duration
    end
    
    local buff = {
                    buffD = buffD,   
                    level = level,      
                    duration = _duration,                     
                    endTick = _duration * 0.001 + BC.BATTLE_BUFF_TICK,
                    nextDot = 0,
                    value = value,
                    valueEx = valueEx,
                    hurt = hurt,
                    shield = shield,
                    count = 1,       
                    needReset = false,
                    attacker = attacker,
                    firstDot = false,
                    interval = nil,
                    disappear = 0,
                    camp = camp,
                    countDamage = true,
                    isPlayer = isPlayer,
                }
    if buffD["disappear"] then
        buff.disappear = buffD["disappear"]
    end
    -- dot/hot
    if buffD["kind"] == 2 or buffD["kind"] == 3 then
        -- 首跳
        buff.interval = buffD["interval"] * 0.001
        buff.firstDot = (buffD["firsthurt"] == 1)
        buff.nextDot = buff.interval + BC.BATTLE_BUFF_TICK
    end
    if buffD["kind"] == 0 or buffD["kind"] == 1 then
        buff.needReset = true
    end
    if ban or buffD["changecamp"] == 1 then
        buff.needReset = true
    end
    return buff
end

function BC.copyBuff(sbuff)
    local buff = {}
    for k, v in pairs(sbuff) do
        buff[k] = v
    end
    return buff
end

-- 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关
-- 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关 技能相关

-- 挂在方阵和士兵上的技能信息, 主要记录技能cd和剩余释放次数
function BC.initSkill(skillD, level)
    local skill = {
                    skillD = skillD,
                    level = level,
                    canCastTick = -1000, -- 下次可释放的tick  技能cd
                    count = -1,
                    pro = 100 --  概率
                }
    skill.pro = skillD["possiblity"][1] + skillD["possiblity"][2] * (level - 1)
    return skill
end

-- 玩家技能  
function BC.initPlayerSkill(camp, index, skill)
    local id = skill[1]
    local level = skill[2]
    local count = skill[4]

    local skillD = tab.playerSkillEffect[id]
    if skillD == nil then
        print("skill ID 不存在 " .. id)
    end
    local skill = {
                    id = id,                                                        -- ID
                    level = level,                                                  -- 等级
                    castTick = 0,                                                   -- 可以释放的Tick
                    cd = 0,                                                         -- cd, 由于有前置CD,所以cd可变
                    maxCD = skillD["cd"][1] - skillD["cd"][2] * (level - 1),              -- skillD cd 基础，专精成长，法术等级成长
                    mana = skillD["manacost"][1] - skillD["manacost"][2] * (level - 1),   -- 蓝
                    castCon = skillD["integraladd"],                               -- 释放条件
                    sumnum = skillD["sumnum"],                                      -- 单回合点击次数限制
                    maxSumnum = skillD["sumnum"],                                   -- 单回合点击次数限制
                    wholelim = skillD["wholelim"],                                  -- 全场是用次数限制
                    kind = skillD["kind"],                                          -- 技能激活特征
                    option = skillD["option"],                                      -- 技能施放操作方式
                    intervalCD = skillD["unittime"],
                    intervalTick = 0,                                               -- 间隔时间释放技能
                    silentTask = 0,                                                 -- 沉默时间
                    accum = 0,                                                      -- 蓄力技能蓄力数
                    tag = skillD["tag"],
                    -- priv = skillD["priv"],
                    -- priv2 = skillD["privX"],
                    dark = (skillD["dark"] or 0) * 0.001,                           -- 控制自动技能屏幕压黑时间
                    rangePro = 0,                                                   -- 范围加成
                    dazhao = skillD["dazhao"] or 0,
                    index = index,
                    banlist = skillD["banlist"],                                    -- 若兵团死亡或者没有上阵，则禁止使用技能
                    banlistX = skillD["banlistX"], 
                    countersk = skillD["countersk"],                                -- 敌方后置技能，当此技能的后置敌方技能存在时，则延后后置技能的释放时间，等待此技能释放再释放
                    counterskX = skillD["counterskX"],
                    castCount = count or -1,                                        -- 法术可以释放的次数
                    exSkill = skill[6],                                             -- 释放法术的时候额外附带出一个法术
                    healBasePro = skill[7],                                         -- 治疗固定值的成长
                    damageBasePro = skill[8],                                       -- 伤害固定值的成长
                    healExAction = skill[9],                                        -- 治疗附带action
                    damageExAction = skill[10],                                     -- 伤害附带action
                    mgtrigerproduct = skillD["mgtrigerproduct"],                    -- 额外触发的法术
                }
    skill.oriMana = skill.mana
    if skill.castCon == 1 then
        -- 开启墓碑
        BC.SHOW_TEAM_DIE_ICON = true
    end
    -- 前置cd
    if skillD["initcd"] ~= nil then
        skill.cd = (skillD["initcd"][1] - skillD["initcd"][2] * (level - 1)) * 0.001
    end
    -- 英雄缩减初始CD以及CD
    local _type = skillD["type"] - 1
    local _subtype = skillD["mgtype"]
    local icd, cd, mcd, ri
    if _subtype == 1 then
        icd = H_ICD_1[camp]
        cd = H_CD_1[camp]
        mcd = H_MCD_1[camp]
        ri = H_RI_1[camp]
    elseif _subtype == 2 then
        icd = H_ICD_2[camp]
        cd = H_CD_2[camp]
        mcd = H_MCD_2[camp]
        ri = H_RI_2[camp]
    else
        icd = H_ICD_3[camp]
        cd = H_CD_3[camp]
        mcd = H_MCD_3[camp]
        ri = H_RI_3[camp]
    end
    if _type < 5 then
        if _type > 0 then
            skill.cd = skill.cd * (1 - (icd[5] + icd[_type]))
            skill.maxCD = skill.maxCD * (1 - (cd[5] + cd[_type]))
            skill.mana = skill.mana * (1 - (mcd[5] + mcd[_type]))
            skill.rangePro = ri[5] + ri[_type]
        else
            skill.cd = skill.cd * (1 - (icd[5]))
            skill.maxCD = skill.maxCD * (1 - (cd[5]))
            skill.mana = skill.mana * (1 - (mcd[5]))
            skill.rangePro = ri[5]
        end
    end

    -- 魔法天赋
    -- 9 降低技能蓝耗值
    -- 10 降低技能蓝耗百分比
    -- 11 减少技能CD值
    -- 12 减少技能CD百分比
    if BC.H_SkillBookTalent[camp] and BC.H_SkillBookTalent[camp]["targetSkills"][id] then
        BattleUtils.countSkillBookTalent(id, skill, {9, 10, 11, 12}, camp)
    end 
    
    skill.baseMana = -skill.mana * 7

    return skill
end

--[[
--! @function initAutoPlayerSkills
--! @desc 根据优先级初始化玩家技能顺序，并排除COMBO技能
--! @param inSkills table
--! @return table 调整后的新技能
--]]
function BC.initAutoPlayerSkills(inSkills, inAttrClass)
    local comboSKIds = {}
    local orderSkills = {}
    local tempKeySkills = {}
    for k,v in pairs(inSkills) do
        local sysSkill = tab.playerSkillEffect[v.id]
        v.comboMana = 0
        v.comboPriv = sysSkill["priv" .. inAttrClass]
        v.index = k
        -- v.priv = sysSkill["priv"]
        v["priv" .. inAttrClass] = sysSkill["priv" .. inAttrClass]
        tempKeySkills[v.id] = v
    end
    local function handleSkillsCombo(inSkill)
        local sysSkill = tab.playerSkillEffect[inSkill.id]
        if sysSkill["backsk" .. inAttrClass] == nil then 
            return 0, 0, 0
        end

        local skillMana = 0
        local skillPriv = 0
        local backPriv = 0
        local backSkillMana = 0
        -- 后置技能
        for k,id in pairs(sysSkill["backsk" .. inAttrClass]) do
            repeat

                if tempKeySkills[id] == nil then 
                    break
                end
                local baskSkill = tempKeySkills[id]

                local backSysSkill = tab.playerSkillEffect[baskSkill.id]
                -- 如果被其他combo使用，则在当前combo不再出现
                if inSkill.tempIsUse == true then 
                    break
                end
                if baskSkill["priv" .. inAttrClass] > skillPriv then 
                    skillPriv = baskSkill["priv" .. inAttrClass]
                end
                -- 蓝消耗取combo组合技能总值
                skillMana = skillMana + baskSkill.mana
                
                inSkill.tempIsUse = true
                -- table.insert(inList, baskSkill.index)
                tempKeySkills[id] = nil
                backPriv, backSkillMana = handleSkillsCombo(baskSkill)
                if backPriv > skillPriv then 
                   skillPriv = backPriv
                end
                -- 蓝消耗取combo组合技能总值
                skillMana = skillMana + backSkillMana
                -- 技能串联
                inSkill.comboIndex = baskSkill.index
            until true
        end
        return skillPriv, skillMana
    end

    -- 检测并处理combo技能
    for k,v in pairs(inSkills) do
        local sysSkill = tab.playerSkillEffect[v.id]
        -- 前置技能
        if (sysSkill["frontsk" .. inAttrClass] == nil or 
            tempKeySkills[sysSkill["frontsk" .. inAttrClass]] == nil) and 
            tempKeySkills[v.id] ~= nil then
            comboSKIds[v.id] = 1
            local backPriv, backSkillMana = handleSkillsCombo(v)
            if backPriv > v["priv" .. inAttrClass] then 
                v.comboPriv = backPriv
            end
            v.comboMana = v.mana + backSkillMana
            local orderSkill = {}
            orderSkill.comboPriv = v.comboPriv
            orderSkill.index = k
            table.insert(orderSkills, orderSkill)
        end
    end

    -- combo剔除技能
    for k,v in pairs(tempKeySkills) do
        if comboSKIds[k] == nil then 
            local orderSkill = {}
            orderSkill.comboPriv = v["priv" .. inAttrClass]
            orderSkill.index = v.index
            table.insert(orderSkills, orderSkill)
        end
    end
    local sortFunc = function(a, b) 
        if a.comboPriv > b.comboPriv then 
            return true
        end
    end
    table.sort(orderSkills, sortFunc)
    return orderSkills
end

-- 用于释放技能的属性体

-- 玩家用

function BC.initSkillCaster(x, y, camp, skillid, castCount)
    local caster = {
                        x = x,
                        y = y,
                        attacker = nil,
                        target = nil,
                        camp = camp,
                        atk = 0,
                        atkType = 0,
                        damageType = 0,
                        crit = 0,
                        critD = 0,
                        pen = 0,
                        hit = 0,
                        dmgInc = 0,
                        AHP = 0,
                        AHPPro = 0,
                        healPro = 0,
                        heal = 0,
                        level = 1,
                        paramAdd = 100,
                        index = BC.PlayerSkillCasterIndex,
                        sindex = castCount,
                        skillid = skillid,
                        isCaster = true
                    }
    BC.PlayerSkillCasterIndex = BC.PlayerSkillCasterIndex + 1
    return caster
end
-- 属性对应快查表
local  casterAttrTab = 
{
    [ATTR_Crit] = "crit",
    [ATTR_CritD] = "critD",
    [ATTR_Pen] = "pen",
    [ATTR_Hit] = "hit",
    [ATTR_DamageInc] = "dmgInc",
    [ATTR_Heal] = "heal",
    [ATTR_HealPro] = "healPro",
    [ATTR_AHPPro] = "aHPPro",
}

-- 更新数值镜像
local ex_atk = {0, 0, 0}

function BC.updateCasterPos(attacker)
    local caster = attacker.caster
    caster.x, caster.y = attacker.x, attacker.y
    caster.camp = attacker.team.camp
    return caster
end
function BC.updateCaster(attacker, logic)
    local caster = attacker.caster
    caster.x, caster.y = attacker.x, attacker.y
    caster.atk = attacker.atk
    if not BATTLE_PROC and caster.atk ~= attacker.atk then
        BC.zuobi2 = 1
    end
    local attr = attacker.attr
    local team = attacker.team
    caster.crit = attr[ATTR_Crit]
    caster.critD = attr[ATTR_CritD]
    -- 暴击和爆伤不能小于0
    if caster.crit < 0 then
        caster.crit = 0
    end
    if caster.critD < 0 then
        caster.critD = 0
    end
    --[[
        pen :破甲
        hit :命中值
        dmgInc :兵团伤害%
        heal :治疗
        healPro :治疗%
        aHPPro :吸血%
    ]]
    caster.pen = ceil((attr[ATTR_Pen] + attr[ATTR_PenAdd] * (caster.level + 9)) * (1 + attr[ATTR_PenPro] * 0.01))
    caster.hit = attr[ATTR_Hit]
    caster.dmgInc = attr[ATTR_DamageInc]
    caster.heal = attr[ATTR_Heal]
    caster.healPro = attr[ATTR_HealPro]
    caster.aHPPro = attr[ATTR_AHPPro]
    caster.camp = team.camp

    ex_atk[1] = 0 -- 基础
    ex_atk[2] = 0 -- 百分比
    ex_atk[3] = 0 -- 额外
    local ex_penAdd = 0 -- 额外破甲成长

    -- 生写表, 主动
    local charactersAtk = team.charactersAtk
    local target = attacker.targetS
    if #charactersAtk > 0 then
        local char, key, attr1, kk, double
        for i = 1, #charactersAtk do
            char = charactersAtk[i]
            -- 0就是无条件
            if char[2] == 0 or (ran(100) <= char[1] and BC["countCharacters"..char[2]] and BC["countCharacters"..char[2]](logic, attacker, target, char[3])) then
                if XBW_SKILL_DEBUG then print(os.clock(), "生写主动", char[5]) end
                -- buff效果翻倍:攻击时检查
                double = char[6]
                kk = 1
                if double == nil then
                    kk = 1
                elseif double[1] == 1 then
                    if attacker:hasBuffKind(double[2]) then
                        kk = 2
                    end
                elseif double[1] == 2 then
                    if target and target:hasBuffKind(double[2]) then
                        kk = 2
                    end
                end

                -- 目标每有一个debuff(同类型的debuff算一个)，攻击者攻击力增加
                if char[2] == 22 then
                    if target then
                        local count, bufft = target:getDebuffLabelCount()
                        if count > 0 then
                            kk = math.min(count, 5)
                        end 
                    end
                end 

                -- 目标或者自身每有一个debuff(同类型的debuff算一个)，攻击者攻击力增加
                if char[2] == 28 then
                    local count1, bufft1 = 0, 0
                    if target then
                        count1, bufft1 = target:getDebuffLabelCount()
                    end
                    local count2, bufft2 = 0, 0
                    if attacker then
                        count2, bufft2 = attacker:getDebuffLabelCount()
                    end
                    local count = count1 + count2
                    if count > 0 then
                        kk = math.min(count, 8)
                    end 
                end
                
                for k = 1, #char[4] do
                    attr1 = char[4][k][1]
                    if attr1 <= 3 then
                        ex_atk[attr1] = ex_atk[attr1] + char[4][k][2] * kk
                    else
                        key = casterAttrTab[attr1]
                        if key then
                            caster[key] = caster[key] + char[4][k][2] * kk
                        end
                    end
                end
            end
        end
    end

    -- 生写表, 加攻击百分比
    local extraAtks = team.extraAtk
    if #extraAtks > 0 then
        local ex
        local attrValue = 0
        local value, min
        for i = 1, #extraAtks do
            ex = extraAtks[i]
            value = BC["countExtraAtk"..ex[1]](logic, attacker, ex[6], caster.camp)
            if value then
                min = ex[2]
                if value < min then
                    value = min
                elseif value > ex[4] then
                    value = ex[4]
                end
                attrValue = attrValue + ex[3] + (value - min) * ex[5] 

                if ex[1] == 15 then
                    ex_penAdd = ex_penAdd + attrValue
                elseif ex[1] == 16 then
                    caster.crit = caster.crit + attrValue
                else
                    ex_atk[2] = ex_atk[2] + attrValue
                end

                if XBW_SKILL_DEBUG then print(os.clock(), "生写攻击百分比", ex[7]) end
            end
        end
    end
    if ex_atk[1] ~= 0 or ex_atk[2] ~= 0 or ex_atk[3] ~= 0 then
        -- 攻击力发生变化
        local atk = ((attr[ATTR_Atk] + ex_atk[1]) * (1 + (attr[ATTR_AtkPro] + ex_atk[2]) * 0.01)
            + attr[ATTR_AtkAdd] + ex_atk[3])
        if atk < 1 then
            atk = 1
        end
        atk = atk * ((100 + attr[ATTR_GlobalAtk] * (100 + 0.3 * attr[ATTR_GlobalAtk]) / (100  + attr[ATTR_GlobalAtk])) * 0.01)
        caster.atk = ceil(atk)
    end

    if ex_penAdd ~= 0 then
        caster.pen = ceil(attr[ATTR_Pen] + (attr[ATTR_PenAdd] + ex_penAdd) * (caster.level + 9))
    end
    return caster
end
--[[-----------------------生写表 额外攻击力------------------------]]--
--3. 目标方阵人数
function BC.countExtraAtk3(logic, attacker, _)
    if attacker.targetS == nil then return nil end
    return #attacker.targetS.team.aliveSoldier
end
--4. 自己方阵人数
function BC.countExtraAtk4(logic, attacker, _)
    return #attacker.team.aliveSoldier
end
--5. 自身血量百分比
function BC.countExtraAtk5(logic, attacker, _)
    return attacker.HP / attacker.maxHP * 100
end
--6. 目标血量百分比
function BC.countExtraAtk6(logic, attacker, _)
    if attacker.targetS == nil then return nil end
    return attacker.targetS.HP / attacker.targetS.maxHP * 100
end
--7. 我方方阵数量
function BC.countExtraAtk7(logic, attacker, _, camp)
    return logic.teamCount[camp]
end
--8. 敌方方阵数量
function BC.countExtraAtk8(logic, attacker, _, camp)
    return logic.teamCount[3 - camp]
end
--9. 我方方阵race1方阵数量
function BC.countExtraAtk9(logic, attacker, race1, camp)
    return logic.raceCount1[camp][race1]
end
--8. 我方方阵race2方阵数量
function BC.countExtraAtk10(logic, attacker, race2, camp)
    return logic.raceCount2[camp][race2]
end
--11. 目标体型
function BC.countExtraAtk11(logic, attacker, _)
    if attacker.targetS == nil then return nil end
    return attacker.targetS.team.volume
end
--12. 攻击受速度差影响
function BC.countExtraAtk12(logic, attacker, _)
    if attacker.targetS == nil then return nil end
    local dec = (attacker.team.speedMove + attacker.attr[ATTR_MSpeed]) - (attacker.targetS.team.speedMove + attacker.targetS.attr[ATTR_MSpeed])
    if dec < 0 then
        dec = 0
    end
    return dec
end
--13. 攻击受自己速度影响
function BC.countExtraAtk13(logic, attacker, _)
    if attacker.targetS == nil then return nil end
    return attacker.team.speedMove + attacker.attr[ATTR_MSpeed]
end
--14. 攻击受攻击距离(面板值)影响
function BC.countExtraAtk14(logic, attacker, _)
    if attacker.targetS == nil then return nil end
    return attacker.attackarea
end
--15. 破甲成长受攻击距离影响
function BC.countExtraAtk15(logic, attacker, _)

end
--16. 暴击值受攻击距离影响
function BC.countExtraAtk16(logic, attacker, _)

end
--17. 攻击受攻击时实际距离影响
local sqrt = math.sqrt
function BC.countExtraAtk17(logic, attacker, _)
    if attacker.targetS == nil then return nil end
    local x1, y1 = attacker.x, attacker.y
    local x2, y2 = attacker.targetS.x, attacker.targetS.y
    local dx = x1 - x2
    local dy = y1 - y2
    return sqrt(dx * dx + dy * dy)
end

--[[-----------------------生写表 额外防御力------------------------]]--
--18. 自身血量百分比
function BC.countExtraDef18(logic, target, _)
    return target.HP / target.maxHP * 100
end


--[[-----------------------生写表 额外防御力------------------------]]--
--20. 方阵人数影响
function BC.countExtraDef20(logic, target, _)
    return target.team._soldierAliveCount / target.team.number * 100
end

--[[-----------------------生写表 法术发免------------------------]]--
--21. 方阵人数影响
function BC.countExtraDef21(logic, target, _)
    return BC.countExtraDef20(logic, target, _)
end

--[[-----------------------生写表 额外兵团伤害------------------------]]--
--22. 攻击者血量百分比
function BC.countExtraDef22(logic, target, nlinear, camp, attacker)
    if attacker == nil then
        return 0
    end
    return attacker.HP / attacker.maxHP * 100
end


--[[-----------------------生写表 额外兵团伤害------------------------]]--
--23. 攻击者方阵人数影响
function BC.countExtraDef23(logic, target, nlinear, camp, attacker)
    if attacker == nil then
        return 0
    end
    return countExtraDef20(logic, attacker)
end


--[[-----------------------生写表 条件触发------------------------]]--
-- 1:如果目标体型大于 等于1:微型 2:小型 3:中型 4：大型 5：巨型 6：自己
function BC.countCharacters1(logic, _self, target, value)
    if target then
        if value == 6 then
            return target.team.volume >= _self.team.volume
        else
            return target.team.volume >= value
        end
    else 
        return false
    end
end
-- 2:如果目标体型小于等于 1:微型 2:小型 3:中型 4：大型 5：巨型 6：自己
function BC.countCharacters2(logic, _self, target, value)
    if target then
        if value == 6 then
            return target.team.volume <= _self.team.volume
        else
            return target.team.volume <= value
        end
    else 
        return false
    end
end
-- 3如果天气 1:白天 2：夜晚
function BC.countCharacters3(logic, _self, target, value)
    -- todo
    return true
end
-- 4如果一次受到伤害大于当前生命的n%
function BC.countCharacters4(logic, _self, target, value)
    if _self.beDamagePro > value - 0.00000001 then
        _self.beDamagePro = 0
        return true
    else
        return false
    end
end
-- 5如果目标生命百分比低于自己
function BC.countCharacters5(logic, _self, target, value)
    if target then
        return target.HP / target.maxHP < _self.HP / _self.maxHP - 0.00000001
    else
        return false
    end
end
-- 6如果目标是 1：陆军 2：空军
function BC.countCharacters6(logic, _self, target, value)
    if target then 
        if value == 1 then
            return not target.team.isFly
        else
            return target.team.isFly
        end
    else
        return false
    end
end
-- 7如果受到的攻击是 1：近战 2：远程(下次攻击)
function BC.countCharacters7(logic, _self, target, value)
    if _self.beDamageType == value then
        _self.beDamageType = 0
        return true
    else
        return false
    end
end
-- 8如果目标生命百分比低于 
function BC.countCharacters8(logic, _self, target, value)
    if target then
        return target.HP / target.maxHP * 100 < value - 0.00000001
    else
        return false
    end
end

-- -- 9如果目标生命百分比高于 
-- function BC.countCharacters9(logic, _self, target, value)
--     if target then
--         return target.HP / target.maxHP * 100 > value - 0.00000001
--     else
--         return false
--     end
-- end

-- 10如果上一次攻击miss
function BC.countCharacters10(logic, _self, target, value)
    if _self.lastMiss then
        _self.lastMiss = false
        return true
    end
    return false
end
-- 12如果目标单位是特殊单位
function BC.countCharacters12(logic, _self, target, value)
    if target then
        return target.team.label1 == value
    else
        return false
    end
end
-- 13如果攻击目标是 1刺客 2步兵 3骑兵4弓手5法师
function BC.countCharacters13(logic, _self, target, value)
    if target then
        return target.team.classLabel == value
    else
        return false
    end
end
-- 14如果圆范围内存在友方方阵 [14,距离]
function BC.countCharacters14(logic, _self, target, value)
    return BC.logic:rangeHasTeam(_self.x, _self.y, value, _self.team.camp)
end
-- 15如果目标当前有x类型的buff
function BC.countCharacters15(logic, _self, target, value)
    if target then
        local buffs = target.buff
        for _, buff in pairs(buffs) do
            if buff.buffD["label"] == value then
                return true
            end
        end
        return false
    else
        return false
    end
end
-- 16如果受到的攻击是 1：物理 2：非物理（魔法
function BC.countCharacters16(logic, _self, target, value)
    if value == 1 then
        return _self.beDamageKind == 1
    else
        return _self.beDamageKind > 1
    end
end
-- 17如果目标种族标签1为X
function BC.countCharacters17(logic, _self, target, value)
    if target then
        return target.team.race1 == value
    end
    return false
end
-- 18如果目标种族标签2为X
function BC.countCharacters18(logic, _self, target, value)
    if target then
        return target.team.race2 == value
    end
    return false
end
-- 19如果对方收到的伤害大于x%
function BC.countCharacters19(logic, _self, target, value)
    if target.beDamagePro > value - 0.00000001 then
        target.beDamagePro = 0
        return true
    else
        return false
    end
end
-- 20如果目标士气小于0
function BC.countCharacters20(logic, _self, target, value)
    if target then
        return target.team.shiqiValue < 0
    end
    return false
end
-- 21如果目标是城墙
function BC.countCharacters21(logic, _self, target, value)
    if target then
        return target.team.building
    end
    return false
end

-- 针对方阵  AI
-- 22如果目标身上有debuff
function BC.countCharacters22(logic, _self, target, value)
    if target then
        local buffs = target.buff
        for _, buff in pairs(buffs) do
            local buffKind = buff.buffD["kind"]
            local label = buff.buffD["label"]
            if (buffKind == 1 or buffKind == 2) and label ~= 0 then
                return true
            end 
        end
        return false
    else
        return false
    end
end

-- 23如果对方身上有debuff
function BC.countCharacters23(logic, _self, target, value)
    if target then
        local buffs = _self.buff
        for _, buff in pairs(buffs) do
            local buffKind = buff.buffD["kind"]
            local label = buff.buffD["label"]
            if (buffKind == 1 or buffKind == 2) and label ~= 0 then
                return true
            end 
        end
        return false
    else
        return false
    end
end

-- 24如果目标是召唤物
function BC.countCharacters24(logic, _self, target, value)
    if target then
        return target.team.summon
    end
    return false
end

-- 25如果目标生命百分比高于 
function BC.countCharacters25(logic, _self, target, value)
    if target then
        return target.HP / target.maxHP * 100 > value - 0.00000001
    else
        return false
    end
end

-- 26如果敌方兵团少于
function BC.countCharacters26(logic, _self, target, value)
    local camp = 3 - _self.camp
    local teamCount = logic.teamCount[camp] - logic._teamDieCount[camp]
    return teamCount < value
end

-- 27如果敌方兵团多于
function BC.countCharacters27(logic, _self, target, value)
    local camp = 3 - _self.camp
    local teamCount = logic.teamCount[camp] - logic._teamDieCount[camp]
    return teamCount > value
end

-- 28如果目标身上有debuff
function BC.countCharacters28(logic, _self, target, value)
    if target then
        local buffs = target.buff
        for _, buff in pairs(buffs) do
            local buffKind = buff.buffD["kind"]
            local label = buff.buffD["label"]
            if (buffKind == 1 or buffKind == 2) and label ~= 0 then
                return true
            end 
        end
    end

    if _self then
        local buffs = _self.buff
        for _, buff in pairs(buffs) do
            local buffKind = buff.buffD["kind"]
            local label = buff.buffD["label"]
            if (buffKind == 1 or buffKind == 2) and label ~= 0 then
                return true
            end 
        end
    end

    return false
end

-- 29如果自身身上有debuff
function BC.countCharacters29(logic, _self, target, value)
    if _self then
        local buffs = _self.buff
        for _, buff in pairs(buffs) do
            local buffKind = buff.buffD["kind"]
            local label = buff.buffD["label"]
            if (buffKind == 1 or buffKind == 2) and label ~= 0 then
                return true
            end 
        end
    end

    if target then
        local buffs = target.buff
        for _, buff in pairs(buffs) do
            local buffKind = buff.buffD["kind"]
            local label = buff.buffD["label"]
            if (buffKind == 1 or buffKind == 2) and label ~= 0 then
                return true
            end 
        end
    end

    return false
end

-- 30如果自身身上有x类型buff
function BC.countCharacters30(logic, _self, target, value)
    if _self then
        local buffs = _self.buff
        for _, buff in pairs(buffs) do
            local label = buff.buffD["label"]
            if label == value then
                return true
            end 
        end
    end
    return false
end

-- 31如果目标种族标签1不为X
function BC.countCharacters31(logic, _self, target, value)
    if target then
        return target.team.race1 ~= value
    end
    return false
end

-- 32如果目标种族标签2不为X
function BC.countCharacters32(logic, _self, target, value)
    if target then
        return target.team.race2 ~= value
    end
    return false
end

-- 33如果目标当前有x类型的buff并且层数是在范围之类
function BC.countCharacters33(logic, _self, target, value)
    if target then
        local buffs = target.buff
        for _, buff in pairs(buffs) do
            if buff and buff.buffD["label"] == value[1] then
                if buff.count and buff.count >= value[2] and buff.count < value[3] then
                    return true
                end
                return false
            end
        end
        return false
    else
        return false
    end
end

-- 34如果目标当前有x类型的buff并且层数是在范围之类
function BC.countCharacters34(logic, _self, target, value)
    if target then
        local buffs = target.buff
        local tabCount = {}
        local nCount = 0
        for _, buff in pairs(buffs) do
            if buff and buff.buffD["label"] then
                tabCount[buff.buffD["label"]] = true
            end
        end

        for key, var in ipairs(value) do
            if not tabCount[var] then
                return false
            end
        end
        return true
    else
        return false
    end
end



-- 35 更具己方墓园兵团数量动态的检测敌方血量的临界值
function BC.countCharacters35(logic, _self, target, value)
    if target and logic and target.team then
        local team = target.team
        local camp = 3 - target.camp
        local sumTeamCount = logic.race1CountSum[camp][value[1]] or 0
        local teamCount = logic.race1Count[camp][value[1]] or 0
        local hpCriVal = (value[2] + value[3] * teamCount + value[4] * sumTeamCount)
        if (hpCriVal + 0.00000001) > value[5] then
            hpCriVal = value[5]
        end
        hpCriVal = hpCriVal / 100
        if (hpCriVal + 0.00000001) > (team.curHP / team.maxHP) then
            return true
        end
        return false
    else
        return false
    end
end

-- 36如果受到的攻击是 1：近战 2：远程
function BC.countCharacters36(logic, _self, target, value)
    if _self and _self.team and _self.team.atkType == value then
        return true
    else
        return false
    end
end



-- 针对方阵
-- 1:如果目标体型大于 等于1:微型 2:小型 3:中型 4：大型 5：巨型 6：自己
function BC.countCharacters_team1(logic, _self, targetTeam, value)
    if targetTeam then
        if value == 6 then
            return targetTeam.volume >= _self.team.volume
        else
            return targetTeam.volume >= value
        end
    else 
        return false
    end
end
-- 2:如果目标体型小于等于 1:微型 2:小型 3:中型 4：大型 5：巨型 6：自己
function BC.countCharacters_team2(logic, _self, targetTeam, value)
    if targetTeam then
        if value == 6 then
            return targetTeam.volume <= _self.team.volume
        else
            return targetTeam.volume <= value
        end
    else 
        return false
    end
end
-- 6如果目标是 1：陆军 2：空军
function BC.countCharacters_team6(logic, _self, targetTeam, value)
    if targetTeam then 
        if value == 1 then
            return not targetTeam.isFly
        else
            return targetTeam.isFly
        end
    else
        return false
    end
end
-- 12如果目标单位是特殊单位
function BC.countCharacters_team12(logic, _self, targetTeam, value)
    if targetTeam then
        return targetTeam.label1 == value
    else
        return false
    end
end
-- 13如果攻击目标是 1刺客 2步兵 3骑兵4弓手5法师
function BC.countCharacters_team13(logic, _self, targetTeam, value)
    if targetTeam then
        return targetTeam.classLabel == value
    else
        return false
    end
end

-- 15如果目标当前有x类型的buff
function BC.countCharacters_team15(logic, _self, targetTeam, value)
    if targetTeam then
        local soldiers = targetTeam.aliveSoldier
        local buffs
        for i = 1, #soldiers do
            buffs = soldiers[i].buff
            for _, buff in pairs(buffs) do
                if buff.buffD["label"] == value then
                    return true
                end
            end
        end
        return false
    else
        return false
    end
end

-- 17如果目标种族标签1为X
function BC.countCharacters_team17(logic, _self, targetTeam, value)
    if targetTeam then
        return targetTeam.race1 == value
    end
    return false
end
-- 18如果目标种族标签2为X
function BC.countCharacters_team18(logic, _self, targetTeam, value)
    if targetTeam then
        return targetTeam.race2 == value
    end
    return false
end
-- 20如果目标士气小于0
function BC.countCharacters_team20(logic, _self, targetTeam, value)
    if targetTeam then
        return targetTeam.shiqiValue < 0
    end
    return false
end
-- 21如果目标是城墙
function BC.countCharacters_team21(logic, _self, targetTeam, value)
    if targetTeam then
        return targetTeam.building
    end
    return false
end


function BC.copyCaster(attacker)
    local attr = attacker.attr
    local caster = {
        attacker = attacker,
        atk = attacker.atk,
        crit = attr[ATTR_Crit],
        critD = attr[ATTR_CritD],
        pen = attr[ATTR_Pen],
        hit = attr[ATTR_Hit],
        dmgInc = attr[ATTR_DamageInc],
        heal = attr[ATTR_Heal],
        healPro = attr[ATTR_HealPro],
        -- aHP = attr[ATTR_AHP],
        aHPPro = attr[ATTR_AHPPro],
        camp = attacker.team.camp,
    }
    return caster
end

-- 打乱顺序
-- Fisher_Yates算法
function BC.randomTable(tab)
    local count = #tab
    local j
    local temp
    if count == 0 then
        return tab
    end
    for i = 1, count do
        j = ran(i)
        temp = tab[i]
        tab[i] = tab[j]
        tab[j] = temp   
    end
    return tab
end

-- 1-N 随机挑选M个数字
function BC.randomSelect(count, selectCount, filter)
    local t = {}
    local res = {}
    local index = 1
    for i = 1, count do
        if i ~= filter then
            t[index] = i
            index = index + 1
        end
    end
    index = 1
    while #res < selectCount and #t > 0 do
        res[index] = remove(t, ran(#t))
        index = index + 1
    end
    return res
end

local sqrt = math.sqrt
function BC.getBulletFlyTime(_type, speed, dis)
    local ms
    if _type == EEffFlyTypeLINE then
        local a = speed * 5
        local v0 = speed * 0.3
        ms = (sqrt(v0 * v0 + 2 * a * dis) - v0) / a
    elseif _type == EEffFlyTypePARABOLA_L or _type == EEffFlyTypePARABOLA_L_R then
        ms = dis / speed
    else
        ms = dis / speed
    end
    
    return ms
end

function BC.reset(level1, level2, reverse, siegeReverse)
    local BC = BC
    BC.DelayCall = require("game.view.battle.logic.BattleDelayCall").new()
    BC.Ran = require("game.utils.random").new()
    Ran = BC.Ran
    BC.Ran2 = require("game.utils.random").new()
    Ran2 = BC.Ran2
    BC.forceHeroSkillAnimId = nil
    BC.BATTLE_BUFF_TICK = 0
    BC.BATTLE_TOTEM_TICK = 0
    BC.BATTLE_TICK = 0
    BC.BATTLE_DELTA = 0
    BC.BATTLE_DISPLAY_TICK = 0
    BC.CAN_SELECT_TEAM = BattleUtils.XBW_SKILL_DEBUG
    BC.SHOW_TEAM_DIE_ICON = false
    BC.frameInv = 0.0250000001
    frameInv = BC.frameInv
    BC.PlayerSkillCasterIndex = 1
    BC.jump = false
    BC.reverse = reverse
    BC.siegeR_logic = siegeReverse
    BC.siegeR_show = siegeReverse
    if reverse then BC.siegeR_show = not BC.siegeR_show end
    if BC.reverse == nil then BC.reverse = false end
    if BC.siegeR_logic == nil then BC.siegeR_logic = false end
    if BC.siegeR_show == nil then BC.siegeR_show = false end
    BC.MoveTypeCount = {{0, 0}, {0, 0}}
    BC.ClassCount = {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}
    BC.Race1Count = {{}, {}}
    for key = 1, BC.TotalRace1Count do
        BC.Race1Count[1][key] = 0
        BC.Race1Count[2][key] = 0
    end
    BC.ObjectParentSkillId = {}
    BC.RecordReleaseSkill = {{}, {}, {}, {}}
    BC.XCount = {{0, 0, 0}, {0, 0, 0}}
    BC.TeamMap = {{}, {}}
    BC.NpcMap = {{}, {}}
    BC.BuffReplace = {{}, {}}
    BC.BuffOpen = {{}, {}} 
    BC.NOW_SCENE_SCALE = 1
    BC.Battle_GenID = 0
    BC.Battle_TeamID = 0
    BC.noEff = false
    BC.zuobi = nil
    BC.zuobi2 = nil
    if level1 == nil then level1 = 1 end
    if level2 == nil then level2 = 1 end
    BC.PLAYER_LEVEL = {level1, level2}
    if not BATTLE_PROC then
        local userModel = ModelManager:getInstance():getModel("UserModel")
        BC.BATTLE_MAX_SPEED = 2
        BC.BATTLE_QUIT = userModel:getQuit()
        if BC.BATTLE_QUIT == nil then
            BC.BATTLE_QUIT = true
        else
            if BC.BATTLE_QUIT == 0 then
                BC.BATTLE_QUIT = false
            else
                BC.BATTLE_QUIT = true
            end
        end
    end
end

function BC.dtor()
    casterAttrTab = nil
    _ap_beginIdx = nil
    abs = nil
    ATTR_AHP = nil
    ATTR_AHPPro = nil
    ATTR_Atk = nil
    ATTR_AtkAdd = nil
    ATTR_AtkDis = nil
    ATTR_AtkPro = nil
    ATTR_BeHeal = nil
    ATTR_BeHealPro = nil
    ATTR_COUNT = nil
    ATTR_Crit = nil
    ATTR_CritD = nil
    ATTR_DamageDec = nil
    ATTR_DamageInc = nil
    ATTR_DecAll = nil
    ATTR_DecAllEx = nil
    ATTR_DecEarth = nil
    ATTR_DecFire = nil
    ATTR_DecWater = nil
    ATTR_DecWind = nil
    ATTR_Def = nil
    ATTR_DefAdd = nil
    ATTR_DHP = nil
    ATTR_DHPPro = nil
    ATTR_DefPro = nil
    ATTR_PenPro = nil
    ATTR_Dodge = nil
    ATTR_Haste = nil
    ATTR_Heal = nil
    ATTR_HealPro = nil
    ATTR_Hit = nil
    ATTR_Hot = nil
    ATTR_HP = nil
    ATTR_HPAdd = nil
    ATTR_HPPro = nil
    ATTR_MSpeed = nil
    ATTR_Pen = nil
    ATTR_PenAdd = nil
    ATTR_RAll = nil
    ATTR_RAll_2 = nil
    ATTR_RAll_3 = nil
    ATTR_REarth = nil
    ATTR_REarth_2 = nil
    ATTR_REarth_3 = nil
    ATTR_Resilience = nil
    ATTR_RFire = nil
    ATTR_RFire_2 = nil
    ATTR_RFire_3 = nil
    ATTR_RPhysics = nil
    ATTR_RPhysics_2 = nil
    ATTR_RPhysics_3 = nil
    ATTR_RWater = nil
    ATTR_RWater_2 = nil
    ATTR_RWater_3 = nil
    ATTR_RWind = nil
end

function BC.dtor1()
    ATTR_RWind_2 = nil
    ATTR_RWind_3 = nil
    ATTR_Shield = nil
    ATTR_ShieldPro = nil
    ATTR_Shiqi = nil
    ATTR_Unuse_1 = nil
    ATTR_Unuse_2 = nil
    cc = nil
    ceil = nil
    ch = nil
    commonBuffAdd = nil
    cos = nil
    cw = nil
    dump = nil
    EAtkTypeMELEE = nil
    EAtkTypeNONE = nil
    EMoveTypeAIR = nil
    EMoveTypeNONE = nil
    ex_atk = nil
    floor = nil
    format = nil
    formula_hero_atkdef = nil
    formula_hero_intack = nil
    formula_vampire_modifier = nil
    COS_SIN = nil
    countDamage_dot = nil
    countDamage_hot = nil
    formula_armor_modifier = nil
    formula_crit_modifier = nil
    H_AP_1 = nil
    H_AP_2 = nil
    H_APAdd = nil
    H_CD_1 = nil
    H_CD_2 = nil
    H_CD_3 = nil
    H_DE_1 = nil
    H_ICD_1 = nil
    H_ICD_2 = nil
    H_ICD_3 = nil
    H_MCD_1 = nil
    H_MCD_2 = nil
    H_MCD_3 = nil
    H_RI_1 = nil
    H_RI_2 = nil
    H_RI_3 = nil
    HitPos_rad = nil
    K_ARMOR = nil
    K_ASPEED = nil
    K_CRIT = nil
    K_DODGE = nil
    math = nil
    max = nil
    modf = nil

    ATTR_DecFire1 = nil      
    ATTR_DecWater1 = nil     
    ATTR_DecWind1 = nil      
    ATTR_DecEarth1 = nil      
    ATTR_DecAll1 = nil     

end

function BC.dtor2()
    next = nil
    os = nil
    pairs = nil
    pc = nil
    print = nil
    rad = nil
    ran = nil
    Ran = nil
    ran2 = nil
    Ran2 = nil
    RESIST_KEY = nil
    ShieldProAdd = nil
    sin = nil
    sqrt = nil
    string = nil
    tab = nil
    table = nil
    targetAttr = nil
    tonumber = nil
    tostring = nil
    value1 = nil
    value2 = nil
    XBW_SKILL_DEBUG = nil
    sqrt = nil
    RK6 = nil
    H_SummonApPro = nil
    remove = nil
end

return BC
