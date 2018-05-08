--[[
    Filename:    TriggerConfig_2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 18:45:30
    Description: File description
--]]

local config = {
				{
					delay = 100, unLock = true,
				},
				{
					delay = 10, unLock = false,
					trigger = "done",
					event = "story", storyid = 22,
				},
				{
					delay = 100, unLock = false,
					trigger = "storyover",
					event = "click", clickName = "guild.map.GuildMapView.GuildMapLayer.sceneLayer.bgLayer.mapBg.Grid_4,18",
					talk = {str = "GUIDE_GUILD_7", x = 200, y = -100},
					shouzhi = {angle = 270, x = -50},
					tip = {str = "GUIDE_GUILD_4", x = -390, y = 225, filpy=1},
					scaleanim = "global.UserInfoView.root.bg.bar.icon2",

				},
				{
					delay = 1000, unLock = true,
					trigger = "done",
					event = "click", clickName = "guild.map.GuildMapView.GuildMapLayer.sceneLayer.bgLayer.mapBg.Grid_3,18",
					talk = {str = "GUIDE_GUILD_8", x = 200, y = -100},
					shouzhi = {angle = 270, x = -50},
				},
}
return config
