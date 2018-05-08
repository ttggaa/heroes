--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--170 圣徽分解引导
				{
					delay = 300, unLock = true,
					trigger = "popshow", name = "team.TeamHolyBreakDialog",
					event = "story", storyid = 50,
				},
}
return config