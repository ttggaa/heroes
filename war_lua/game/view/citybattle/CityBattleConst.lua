--[[
    Filename:    CityBattleConst.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-06-28 21:04:43
    Description: File description
--]]

CityBattleConst = {}


if not OS_IS_WINDOWS then

    CityBattleConst.SHOW_CITY_ID = false  -- 是否显示城池id

else
    CityBattleConst.SHOW_CITY_ID = true  -- 是否显示城池id
end

-- 编组状态
CityBattleConst.FORMATION_STATE = 
{
    CREATE = 1,             --1：可创建
    LOCK = 2,               --2：未解锁
    FREE = 3,               --3：已编组及空闲状态
    DIE = 4,                --4：已死亡，待复活
    READY = 5,              --5：已派遣可撤回(准备中)
    BATTLE = 6,             --6：战斗队列中不可撤回
}



CityBattleConst.RECONNECTCOUNT = 0