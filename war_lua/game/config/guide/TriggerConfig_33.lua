--[[
    Filename:    TriggerConfig_2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 18:45:30
    Description: File description
--]]

local config = {

{-- 1 点按钮
	delay = 500, unLock = true,
	talk = {str = "LIZHIYUAN_1", x = 200, y = -100},
	event = "click", clickName = "formation.NewFormationView.root.bg.layer_left.layer_list.btn_tab_hero",
	shouzhi = {angle = 270, x = -50},
},
{-- 1 点按钮
	delay = 100, unLock = true,
	trigger = "done",
	event = "prompt",
	text = {str = "LIZHIYUAN_2", x = -360, y = -147},
	shouzhi = {angle = 270, x = -50},
},
}
return config
