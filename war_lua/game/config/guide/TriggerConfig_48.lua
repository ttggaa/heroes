--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--171 星图介绍
				{
					delay = 300, unLock = true,
					trigger = "view", name = "starCharts.StarChartsView",
					event = "story", storyid = 53,
				},
--172 点击未激活星体按钮
				{
					delay = 300, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "starCharts.StarChartsView.sceneLayer.bgLayer.bodyName726_442.touchBtn",
					shouzhi = {angle = 90, x = 50 ,},
				},
--173 星体激活
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 54,
				},
--174 点击星魂“+”
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "starCharts.StarChartsView.root.Panel2.addBtn",
					shouzhi = {angle = 270, x = -50},
				},
--175  星魂共鸣
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 55,
				},
--176  关闭“星魂共鸣”弹板
				{
					delay = 300, unLock = true,
					trigger = "done",						
					event = "click", clickName = "starCharts.StarChartsResonanceDialog.root.bg.closeBtn",
					shouzhi = {angle = 90, x = 50 ,},
				},
--177  点击构成星体
				{
					delay = 300, unLock = true,
					trigger = "done",						
					event = "click", clickName = "starCharts.StarChartsView.sceneLayer.bgLayer.bodyName656_480.touchBtn",
					shouzhi = {angle = 90, x = 50 ,},
				},
--178  星体构成
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 56,
				},
}
return config