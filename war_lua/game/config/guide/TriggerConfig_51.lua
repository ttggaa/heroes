--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--201 炼金系统介绍
				{
					delay = 300, unLock = true,
					trigger = "view", name = "MF.MFAlchemyView",
					event = "story", storyid = 64,
				},
--202 点击炼化按钮
				{
					delay = 300, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "MF.MFAlchemyView.root.bg.warehouseLayer.artificeBtn",
					shouzhi = {angle = 90, x = 50 ,},
				},
--203 材料炼化介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 65,
				},
--204 关闭炼化界面
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "MF.MFAlchemyMaterialDialog.root.bg.closeBtn",
					shouzhi = {angle = 270, x = -50},
				},

--205 仓库介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 68,
				},
--206  点击配方
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "MF.MFAlchemyView.root.bg.bgImg.tab_formula",
					shouzhi = {angle = 270, x = -50},
				},
--207 配方介绍1
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 66,
				},
--208 配方介绍2
				{
					delay = 300, unLock = true,
					trigger = "storyover",	
					event = "story", storyid = 67,
				},
--209  点击给定配方
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "MF.MFAlchemyView.root.bg.formulaLayer.rightBg.tableBg.alchemyNode11",
					talk = {str = "XINSHOU_142", x = -80, y = 0},
					shouzhi = {angle = 270, x = -50},
				},


}
return config