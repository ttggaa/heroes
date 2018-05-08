--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--147 战争器械 点击“配件制造”按钮
				{
					delay = 1500, unLock = false,
					trigger = "view", name = "siege.SigeCardView",
					event = "click", clickName = "weapons.WeaponsView.root.bg.extractBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_100", x = 200, y = 0},
				},
--148 点击“免费制造”按钮
				{
					delay = 300, unLock = true,
					trigger = "view", name = "siege.SigeCardView",								
					event = "click", clickName = "siege.SigeCardView.root.bottomPanel.commonBtn",
					shouzhi = {angle = 90, x = 50},
					talk = {str = "XINSHOU_101", x = 200, y = 0},
				},
--149  点击“返回”按钮
				{
					delay = 1500, unLock = false,
					trigger = "done", name = "siege.SigeCardView",							
					event = "click", clickName = "global.UserInfoView.root.closeBtn",
					shouzhi = {angle = 270, x = -50 ,},
					talk = {str = "XINSHOU_102", x = 100, y = 180},
				},		
--150  点击“改造”页签
				{
					delay = 300, unLock = false,
					trigger = "view", name = "weapons.WeaponsView",							
					event = "click", clickName = "weapons.WeaponsView.root.bg.rightSubBg.tab2",
					shouzhi = {angle = 90, x = 50 ,},
					talk = {str = "XINSHOU_103", x = 100, y = 20},
				},		
--151  点击“材质”下的“+”图标
				{
					delay = 1000, unLock = true,
					trigger = "done",							
					event = "click", clickName = "weapons.WeaponsView.root.bg.rightSubBg.panel1.weapons.WeaponsReformNode.root.bg.equipBg1.notEquip",
					shouzhi = {angle = 90, x = 50 ,},
					talk = {str = "XINSHOU_104", x = 100, y = 20},
				},		
}
return config