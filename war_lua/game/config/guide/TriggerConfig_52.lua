--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--210 专属升级引导
				{
					delay = 300, unLock = true,
					trigger = "view", name = "TeamExclusiveUpView",	
					event = "story", storyid = 69,
				},
					{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "team.TeamExclusiveUpView.root.bg.btn_close",
					shouzhi = {angle = 270, x = -50},
				},
}
return config