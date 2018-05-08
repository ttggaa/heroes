--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
				{
					delay = 100, unLock = false,
					event = "story", storyid = 2000,
				},
				{
					delay = 100, unLock = false,
					trigger = "storyover",
					view = "guildmap",
					moveto = {a=34, b=37},
				},
				{
					trigger = "done",
					delay = 1000, unLock = true,
				},
				{
					delay = 0, unLock = false,
					trigger = "done",
					event = "story", storyid = 2001,
				},
				{
					delay = 100, unLock = false,
					trigger = "storyover",
					view = "guildmap",
					moveto = {a=8, b=20},
				},
				{
					trigger = "done",
					delay = 1000, unLock = true,
				},
				{
					delay = 0, unLock = true,
					trigger = "done",
					event = "story", storyid = 2002,
				},
}
return config