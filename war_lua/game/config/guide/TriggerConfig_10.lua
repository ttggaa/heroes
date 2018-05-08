--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {

--99点宝箱 保存点
				{
					delay = 3000, unLock = false,
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.branch_icon_2",
					talk = {str = "XINSHOU_19", x = 200, y = -100},
					shouzhi = {angle = 270, x = -50}, 
				},
--100打开星级宝箱
				{
					delay = 300, unLock = true,  save = 2,
					trigger = "popshow", name = "intance.IntanceBranchView",
					event = "click", clickName = "intance.IntanceBranchView.root.bg1.enterBtn",
					shouzhi = {angle = 270, x = -80},
				},
--101返回主界面
				{
					delay = 300, unLock = false,
					trigger = "popclose", name = "global.GlobalGiftGetDialog",
					event = "click", clickName = "intance.IntanceView.root.closeBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_20", x = -200, y = -100},
					closeWorld = 1,
				},
--53程
				{
					delay = 0, unLock = false,
					trigger = "done",
					event = "close",
				},
-- 2 返回主界面				
				-- {
				-- 	delay = 1000, unLock = false,
				-- 	trigger = "done",
				-- 	event = "click", clickName = "intance.IntanceView.IntanceWorldLayer.intance.WorldElementLayer.root.quickBg.mainBtn",
				-- 	shouzhi = {angle = 270, x = -50},
				-- },
--102点军团 保存点
				{
					delay = 300, unLock = false,
					trigger = "done",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "RUOTIP_11", x = -200, y = -100},
				},
--103点弩手
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.106",
					shouzhi = {angle = 270, x = -50, cx = 0},
					showTeam = 106,
				},
--104点符文1
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamLiftingNode.root.bg.vessel.runeBg.equipBg1",
					shouzhi = {angle = 270, x = -50},
				},
--105升级
				{
					delay = 300, unLock = true, save = 4,
					trigger = "popshow", name = "team.TeamRuneView",
					event = "click", clickName = "team.TeamRuneView.root.bg.panel1.upgradeBg.upgradefiveBtn",
					talk = {str = "XINSHOU_21", x = -200, y = -120},
					shouzhi = {angle = 270, x = -50},
				},
}
return config