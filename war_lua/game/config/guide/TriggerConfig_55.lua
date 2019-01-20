--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--221 藏宝图系统介绍
				{
					delay = 300, unLock = true,
					trigger = "view", name = "guild.map.GuildMapView",
					event = "story", storyid = 75,
				},
--222 藏宝图右边界面介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 76,
				},
--223 藏宝图左边界面介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 77,
				},
--224  点击关闭按钮
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "guild.map.GuildMapTreasureDialog.root.bg.closeBtn",
					shouzhi = {angle = 270, x = -50},
				},


}
return config