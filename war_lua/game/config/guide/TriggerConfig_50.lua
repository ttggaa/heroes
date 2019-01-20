--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--187 战阵介绍
				{
					delay = 300, unLock = true,
					trigger = "view", name = "battleArray.BattleArrayView",
					event = "story", storyid = 61,
				},
--188 点击未激活阵点按钮
				{
					delay = 300, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "battleArray.BattleArrayView.sceneLayer.battleArray.BattleArrayMap.root.mapNode.p_1001",
					shouzhi = {angle = 90, x = 50 ,},
				},
--189 阵点介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 62,
				},
--190 点击阵眼
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "battleArray.BattleArrayView.sceneLayer.battleArray.BattleArrayMap.root.mapNode.center",
					shouzhi = {angle = 270, x = -50},
				},
--200  阵眼介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 63,
				},

}
return config