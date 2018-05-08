--[[
    Filename:    TriggerConfig_2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 18:45:30
    Description: File description
--]]

local config = {

				{-- 135  20级触发英雄系统
					delay = 100, unLock = true,
					event = "click", clickName = "activity.ActivitySignInView.root.bg.scrollView.itemCell1.itemBg.itemIcon",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "JUQING_041", x = -100, y = -100},
				},
				{-- 137 点击英雄查看
					delay = 100, unLock = true,
					trigger = "popclose", name = "global.GlobalGiftGetDialog",
					event = "prompt",
					text = {str = "JUQING_042", x = 331, y = -187},
				},
}
return config