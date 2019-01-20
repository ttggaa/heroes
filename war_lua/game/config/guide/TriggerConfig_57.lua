--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--225 军团试炼介绍
				{
					delay = 300, unLock = true,
					trigger = "view", name = "pve.PveView",
					event = "story", storyid = 82,
				},
--226 点击军团试炼第一关前往
				{
					delay = 300, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "pve.ProfessionBattleDialog.root.bg.layer.layerPanel.levelItem.advanceBtn",
					shouzhi = {angle = 90, x = 50 ,},
				},
--227 推荐介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 83,
				},
--228 点击战斗按钮
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "pve.LegionsStageInfoView.root.bg.mainNode.btn_battle",
					shouzhi = {angle = 270, x = -50},
				},
--229  布阵说明
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 84,
				},
--230  最终说明
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 85,
				},

}
return config