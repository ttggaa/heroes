--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--130点
				{
					delay = 100, unLock = false,
					trigger = "View", name = "nests.NestsView",
					event = "click", clickName = "nests.NestsView.root.bg.towerNode.item_2.buildNode.buildBtn102",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_86", x = 200, y = 100},
				},
--129点
				{
					delay = 200, unLock = true,
					trigger = "popshow", name = "nests.NestsBuildView",
					event = "click", clickName = "nests.NestsBuildView.root.bg.buildBtn",
					shouzhi = {angle = 270, x = -50},
				},
--129点
				{
					delay = 200, unLock = true,
					trigger = "popclose", name = "nests.NestsBuildView",
					event = "click", clickName = "nests.NestsView.root.bg.towerNode.item_2",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_87", x = 200, y = 100},
				},

}
return config