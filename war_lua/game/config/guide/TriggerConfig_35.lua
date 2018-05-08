--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
				{
					delay = 100, unLock = false,
					event = "click", clickName = "treasure.TreasureView.root.bg.layer.disPanel.disTreasure_2",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "BAOWUSHENGXING_1", x = 220, y = -100},
				},
				{
					delay = 100, unLock = false,
					trigger = "popshow", name = "treasure.TreasureDisUpView",
					event = "click", clickName = "treasure.TreasureDisUpView.root.bg.layer.tab_upStar",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "BAOWUSHENGXING_2", x = 220, y = -100},
				},
				{
					delay = 500, unLock = true,
					trigger = "done",
					event = "click", clickName = "treasure.TreasureDisUpView.root.bg.layer.treasure.TreasureUpStarLayer.root.bg.layer.upTenceBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "BAOWUSHENGXING_3", x = -220, y = -100},
				},								
}
return config