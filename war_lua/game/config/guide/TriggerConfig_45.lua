--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--161 无尽炼狱 领取奖励引导
				{
					delay = 300, unLock = true,
					trigger = "view", name = "purgatory.PurgatoryView",
					event = "click", clickName = "purgatory.PurgatoryView.root.bg.panel.buttons.rewardBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_118", x = 50, y = -100},
				},
}
return config