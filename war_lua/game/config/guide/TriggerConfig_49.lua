--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--179 后援介绍
				{
					delay = 300, unLock = true,
					trigger = "done",
					event = "story", storyid = 57,
				},
--180 后援介绍
				{
					delay = 300, unLock = true,
					trigger = "done",
					event = "story", storyid = 58,
				},
--181 点击“返回”按钮
				{
					delay = 300, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "global.UserInfoView.root.closeBtn",
					shouzhi = {angle = 270, x = -50},
				},
--182 点击“返回”主界面
				{
					delay = 300, unLock = true,
					trigger = "done",
					event = "click", clickName = "global.UserInfoView.root.closeBtn",
					shouzhi = {angle = 270, x = -50},
				},
--183 点击“布阵”按钮
				{
					delay = 300, unLock = true,
					trigger = "done",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.formationBtn",
					shouzhi = {angle = 270, x = -50},
				},
--184  点击“战场后援”按钮
				{
					delay = 300, unLock = true,
					trigger = "view", name = "formation.NewFormationView",
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.backup_bg.Button_83",
					shouzhi = {angle = 90, x = 50 ,},
				},
--185  后援布阵介绍
				{
					delay = 300, unLock = true,
					trigger = "done",
					event = "story", storyid = 59,
				},
--186  后援布阵介绍
				{
					delay = 300, unLock = true,
					trigger = "done",
					event = "story", storyid = 60,
				},
}
return config