--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--225 巅峰等级天赋树介绍
				{
					delay = 300, unLock = true,
					trigger = "view", name = "paragon.ParagonTalentView",
					event = "story", storyid = 78,
				},
--226 点击天赋树第一个图标
				{
					delay = 300, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "paragon.ParagonTalentView.root.bg.layer1.icon1.icon1",
					shouzhi = {angle = 90, x = 50 ,},
				},
--227 升级介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 79,
				},
--228 关闭升级页面
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "paragon.ParagonTalentUpDialog.root.bg.btn_close",
					shouzhi = {angle = 270, x = -50},
				},
--229  解锁说明
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 80,
				},
--230  重置说明
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 81,
				},

}
return config