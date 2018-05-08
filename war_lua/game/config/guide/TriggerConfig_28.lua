--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
				{
					event = "click", clickName = "main.MainView.root.bg.midBg3.pve",
					shouzhi = {angle = 270, x = -50},
				},
				{
					delay = 100, unLock = true,
					trigger = "view", name = "pvp.PvpInView",
					event = "click", clickName = "pvp.PvpInView.root.bg.scrollView.hole2",
					shouzhi = {angle = 270, x = -50},
				},
}
return config