--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--152 点击“战斗”按钮
				{
					delay = 300, unLock = false,
					trigger = "view", name = "siegeDaily.SiegeDailyView",								
					event = "click", clickName = "siegeDaily.SiegeDailyView.root.bg.right.buttons.battleBtn",
					shouzhi = {angle = 270, x = -30},
					talk = {str = "XINSHOU_107", x = 100, y = -100},
				},
--153  点击“简单”图标框
				{
					delay = 300, unLock = false,
					trigger = "popshow", name = "siegeDaily.SiegeLevelSelectedView",							
					event = "click", clickName = "siegeDaily.SiegeLevelSelectedView.root.bg.levelView.dragon_level",
					shouzhi = {angle = 90, x = 50 ,},
					talk = {str = "XINSHOU_108", x = 100, y = -100},
				},			
--154  点击“器械”页签
				{
					delay = 300, unLock = true,
					trigger = "view", name = "formation.NewFormationView",							
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_left.layer_list.btn_tab_ins",
					shouzhi = {angle = 90, x = 50 ,},
					talk = {str = "XINSHOU_109", x = 100, y = -100},
				},		
}
return config