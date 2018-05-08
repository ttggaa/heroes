--[[
    Filename:    GodWarUtil.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-20 16:19:13
    Description: File description
--]]
local GodWarUtil = {}

GodWarUtil.godwarSwitch = true
GodWarUtil.godwarInterval = 300
GodWarUtil.readlyTime = 180 -- 准备间隔
GodWarUtil.fightTime = 120 -- 战斗间隔
GodWarUtil.showScoreTime = 60 -- 比分展示
GodWarUtil.promotion = {
    [1] = {1, 2, 9},
    [2] = {3, 4, 10},
    [3] = {5, 6, 11},
    [4] = {7, 8, 12},
    [5] = {9, 10, 13},
    [6] = {11, 12, 14},
    [7] = {13, 14, 15},
    [8] = {16, 17, 0},
}

GodWarUtil.powPosTab = {
    [1] = {-10, -3, 0.8},
    [2] = {-5, -5, 0.82},
    [3] = {0, 0, 0.9},
    [4] = {3, 0, 1},
}

GodWarUtil.powTimeTab = {
    [32] = {readlyTime = 0, fightTime = 120, roundTime = 360},
    [8] = {readlyTime = 180, fightTime = 120, roundTime = 540},
    [4] = {readlyTime = 180, fightTime = 120, roundTime = 540},
    [2] = {readlyTime = 300, fightTime = 120, roundTime = 660},
}

GodWarUtil.powLineTab = {
    [11] = {posx = 176, posy = 460, rotation = 180, scale = 1, flip = 1},
    [12] = {posx = 176, posy = 410, rotation = 180, scale = 1, flip = -1},
    [21] = {posx = 176, posy = 248, rotation = 180, scale = 1, flip = 1},
    [22] = {posx = 176, posy = 198, rotation = 180, scale = 1, flip = -1},
    [31] = {posx = 788, posy = 460, rotation = 180, scale = 1, flip = -1},
    [32] = {posx = 788, posy = 394, rotation = 0, scale = 1, flip = 1},
    [41] = {posx = 788, posy = 248, rotation = 180, scale = 1, flip = -1},
    [42] = {posx = 788, posy = 180, rotation = 0, scale = 1, flip = 1},
    [51] = {posx = 280, posy = 324, rotation = 90, scale = 1, flip = -1},
    [52] = {posx = 280, posy = 318, rotation = 90, scale = 1, flip = 1},
    [61] = {posx = 688, posy = 326, rotation = 0, scale = 1, flip = -1},
    [62] = {posx = 686, posy = 318, rotation = 270, scale = 1, flip = -1},
    [71] = {posx = 482, posy = 324, rotation = 360, scale = 1, flip = -1},
    [72] = {posx = 482, posy = 324, rotation = 0, scale = 1, flip = 1},
    [81] = {posx = 0, posy = 0, rotation = 0, scale = 1, flip = 1},
}
    
GodWarUtil.numbers = {
    [0] = "godwarImageUI_img230.png",
    [1] = "godwarImageUI_img231.png",
    [2] = "godwarImageUI_img222.png",
    [3] = "godwarImageUI_img223.png",
    [4] = "godwarImageUI_img224.png",
    [5] = "godwarImageUI_img225.png",
    [6] = "godwarImageUI_img226.png",
    [7] = "godwarImageUI_img227.png",
    [8] = "godwarImageUI_img228.png",
    [9] = "godwarImageUI_img229.png",
}

GodWarUtil.watchPowImg = {
    [8] = "godwarImageUI_img249.png",
    [4] = "godwarImageUI_img250.png",
    [2] = "godwarImageUI_img245.png",
}


function GodWarUtil.dtor()
    
end

return GodWarUtil