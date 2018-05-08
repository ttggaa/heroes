--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {

--109引导挑战
				{
					delay = 300, unLock = false,
					event = "click", clickName = "arena.ArenaView.root.bg.layer.tableView.guidCell.cellBoard.challengeBtn",
					shouzhi = {angle = 270, x = -50},
					sound ="121",
				},
--110前
				{
					delay = 300, unLock = true,
					trigger = "view", name = "formation.NewFormationView",
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.btn_battle",
					shouzhi = {angle = 270, x = -50}, 
					sound ="123",
				},
				{
					delay = 0, unLock = false,
					trigger = "view", name = "arena.ArenaView",
				},
--111返回主界面
				{
					delay = 100, unLock = false,
					trigger = "view", name = "arena.ArenaView",
					event = "click", clickName = "global.UserInfoView.root.closeBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_29", x = 200, y = -100},
					sound ="122",
				},
--112引导领取竞技场奖励
				{
					delay = 0, unLock = false,
					trigger = "done",
					event = "close",
				},
--112引导领取竞技场奖励
				{
					delay = 100, unLock = true,
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.topLayer.mailBtn",
					shouzhi = {angle = 90, x = 50},
				},
--116返回主界面
				{
					delay = 300, unLock = false,
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bg.midBg3.pve",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_32", x = 200, y = -100},
				},
--106级触发引导竞技场
				{
					delay = 100, unLock = false,
					trigger = "view", name = "pvp.PvpInView",
					event = "click", clickName = "pvp.PvpInView.root.bg.scrollView.hole1",
					shouzhi = {angle = 270, x = -50},
				},		
--117引导挑战
				{
					delay = 100, unLock = false,
					trigger = "view", name = "arena.ArenaView",
					event = "click", clickName = "arena.ArenaView.root.bg.layer.mainBg.shopBtn",
					shouzhi = {angle = 270, x = -50},
				},
--118购买僧侣
				{
					delay = 300, unLock = false,
					trigger = "view", name = "shop.ShopView",
					event = "click", clickName = "shop.ShopView.root.bg.mainBg.scrollView.item2",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_33", x = 200, y = -100},
				},
--118购买僧侣
				{
					delay = 300, unLock = true,
					trigger = "popshow", name = "shop.DialogShopBuy",
					event = "click", clickName = "shop.DialogShopBuy.root.bg.btn1",
					shouzhi = {angle = 270, x = -50},
				},
}
return config