--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {

{-- 95 解锁技能动画 保存点
	delay = 300, unLock = true,
	event = "click", clickName = "intance.IntanceView.IntanceMapLayer.branch_icon_7100311",
	talk = {str = "XINSHOU_57", x = 200, y = 100},
	shouzhi = {angle = 270, x = -50},
},
{-- 95 解锁技能动画 保存点
	delay = 4000, unLock = true,
	trigger = "popclose", name = "intance.IntanceBranchView",
	event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100313",
	shouzhi = {angle = 270, x = -50},
},
}
return config