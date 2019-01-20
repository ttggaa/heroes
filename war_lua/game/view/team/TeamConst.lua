--[[
    Filename:    TeamConst.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-02-29 10:44:58
    Description: File description
--]]


TeamConst = {}           

TeamConst.TEAM_ZIZHI_TYPE = {
    ZIZHI_1 = 13,
    ZIZHI_2 = 14,
    ZIZHI_3 = 15,
    ZIZHI_4 = 16
}

-- TeamConst.TEAM_RACE_TYPE = {
--     RACE_0 = 0,
--     RACE_1 = 1, -- 输出 
--     RACE_2 = 2, -- 防御
--     RACE_3 = 3, -- 突击
--     RACE_4 = 4, -- 射手
--     RACE_5 = 5, -- 魔法
--     RACE_6 = 6, -- 平原
--     RACE_7 = 7, -- 森林
--     RACE_8 = 8, -- 据点
--     RACE_9 = 9, -- 墓园
--     RACE_10 = 10, -- 地狱
--     RACE_11 = 11, -- 塔楼
-- }

TeamConst.TEAM_RACE_TYPE = {
    RACE_1 = 6, -- 平原 101
    RACE_2 = 7, -- 森林 102
    RACE_3 = 8, -- 据点 103
    RACE_4 = 9, --- 墓园 104
    RACE_5 = 10, -- 地狱 105
    RACE_6 = 11, -- 塔楼 106
    RACE_7 = 0, -- 全部
    RACE_8 = 12, -- 元素 109
    RACE_9 = 13, -- 地下城 107
    RACE_10 = 14, -- 要塞 108
    RACE_11 = 15, -- 海盗 112
}

TeamConst.TEAM_RACE_COLOR = {
    cc.c4b(132,200,255,255), -- 城堡
    cc.c4b(133,255,150,255), -- 壁垒
    cc.c4b(255,180,69,255),  -- 据点
    cc.c4b(251,148,255,255), -- 墓园
    cc.c4b(255,80,80,255),   -- 地狱
    cc.c4b(138,255,199,255), -- 塔楼
    -- cc.c4b(125,146,255,255), -- 塔楼
    cc.c4b(255,240,218,255), -- 全部
    cc.c4b(255,111,96,255),  -- 元素
    cc.c4b(138,255,199,255), -- 要塞
}

return TeamConst
