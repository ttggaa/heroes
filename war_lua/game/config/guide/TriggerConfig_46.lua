--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--162  点击“镶嵌孔”1
				{
					delay = 300, unLock = true,
					trigger = "view", name = "team.TeamHolyShopView",
					event = "story", storyid = 51,
				},
--163 点击“商店”按钮
				{
					delay = 300, unLock = true,
					trigger = "done",
					event = "click", clickName = "team.TeamHolyView.root.bg.shopBtn",
					shouzhi = {angle = 90, x = 50 ,},
				},
--164 圣徽商店引导
				{
					delay = 300, unLock = true,
					trigger = "view", name = "team.TeamHolyShopView",
					event = "story", storyid = 47,
				},
--165 点击“返回”按钮
				{
					delay = 300, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "global.UserInfoView.root.closeBtn",
					shouzhi = {angle = 270, x = -50},
				},
--166  点击“仓库”页签
				{
					delay = 300, unLock = true,
					trigger = "done",					
					event = "click", clickName = "team.TeamHolyView.root.bg.rightSubBg.tab_bag",
					shouzhi = {angle = 90, x = 50 ,},
					talk = {str = "XINSHOU_121", x = 100, y = 20},
				},
--167  介绍阵营意识
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 48,
				},
--168  点击圣徽“属性”页签
				{
					delay = 300, unLock = true,
					trigger = "done",						
					event = "click", clickName = "team.TeamHolyView.root.bg.rightSubBg.tab_prop",
					shouzhi = {angle = 90, x = 50 ,},
					talk = {str = "XINSHOU_123", x = 100, y = 30},
				},
--169  介绍套装效果
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 49,
				},
}
return config