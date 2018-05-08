--[[
    Filename:    TriggerConfig_2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 18:45:30
    Description: File description
--]]

local config = {

--126点击返回
				{
					delay = 100, unLock = true,
					event = "click", clickName = "crusade.CrusadeView.root.ScrollView.Crusade_2",
					talk = {str = "RUOTIP_35", x = 200, y = -100},
					shouzhi = {angle = 270, x = -50},
				},
--126点击返回
				{
					delay = 100, unLock = false,
					trigger = "popclose", name = "global.GlobalGiftGetDialog",
					event = "click", clickName = "global.UserInfoView.root.closeBtn",
					talk = {str = "RUOTIP_24", x = 200, y = -100},
					shouzhi = {angle = 270, x = -50},
				},
--53
				{
					delay = 0, unLock = false,
					trigger = "done",
					event = "close",
				},
--127引导宝物
				{
					delay = 300, unLock = false,
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.treasureBtn",
					tip = {str = "RUOTIP_25", x = 0, y = 50},
					shouzhi = {angle = 270, x = -50},
				},
--128引导宝物
				{
					delay = 100, unLock = true,
					trigger = "view", name = "treasure.TreasureView",
					event = "click", clickName = "treasure.TreasureView.root.bg.layer.disPanel.disTreasure_2",
					talk = {str = "XINSHOU_44", x = 200, y = -100},
					shouzhi = {angle = 270, x = -50},
				},
}
return config
