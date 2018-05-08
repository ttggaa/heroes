--[[
    Filename:    BattleFormationPos.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-31 14:22:06
    Description: File description
--]]
-- 建立方阵内坐标的查询表

BC.FORMATION_POS = {}
BC.FORMATION_POS[BC.ECamp.LEFT] = {}
BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_16] = {}
BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_9] = {}
BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_4] = {}
BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_1] = {}
BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_BOSS] = {}
BC.FORMATION_POS[BC.ECamp.RIGHT] = {}
BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_16] = {}
BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_9] = {}
BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_4] = {}
BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_1] = {}
BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_BOSS] = {}


for i = 1, 16 do
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_16][i] = {}
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_16][i].x, BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_16][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_16, BC.ECamp.LEFT)
end
for i = 1, 9 do
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_9][i] = {}
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_9][i].x, BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_9][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_9, BC.ECamp.LEFT)
end
for i = 1, 4 do
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_4][i] = {}
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_4][i].x, BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_4][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_4, BC.ECamp.LEFT)
end
for i = 1, 1 do
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_1][i] = {}
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_1][i].x, BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_1][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_1, BC.ECamp.LEFT)
end
for i = 1, 1 do
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_BOSS][i] = {}
    BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_BOSS][i].x, BC.FORMATION_POS[BC.ECamp.LEFT][BC.EVolume.V_BOSS][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_BOSS, BC.ECamp.LEFT)
end


for i = 1, 16 do
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_16][i] = {}
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_16][i].x, BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_16][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_16, BC.ECamp.RIGHT)
end
for i = 1, 9 do
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_9][i] = {}
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_9][i].x, BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_9][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_9, BC.ECamp.RIGHT)
end
for i = 1, 4 do
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_4][i] = {}
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_4][i].x, BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_4][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_4, BC.ECamp.RIGHT)
end
for i = 1, 1 do
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_1][i] = {}
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_1][i].x, BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_1][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_1, BC.ECamp.RIGHT)
end
for i = 1, 1 do
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_BOSS][i] = {}
    BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_BOSS][i].x, BC.FORMATION_POS[BC.ECamp.RIGHT][BC.EVolume.V_BOSS][i].y
        = BC._getPosInFormation(0, 0, i, BC.EVolume.V_BOSS, BC.ECamp.RIGHT)
end