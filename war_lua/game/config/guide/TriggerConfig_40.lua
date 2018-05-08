--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--155 点击“战斗”按钮
				{
					delay = 300, unLock = false,
					trigger = "view", name = "siegeDaily.SiegeDailyView",								
					event = "click", clickName = "siegeDaily.SiegeDailyView.root.bg.right.buttons.battleBtn",
					shouzhi = {angle = 270, x = -30},
					talk = {str = "XINSHOU_110", x = 100, y = -100},
				},
--156  点击“更换主城”页签
				{
					delay = 300, unLock = true,
					trigger = "view", name = "formation.NewFormationView",							
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.btn_city_select",
					shouzhi = {angle = 90, x = 50 ,},
					talk = {str = "XINSHOU_111", x = -100, y = -100},
				},		
}
return config