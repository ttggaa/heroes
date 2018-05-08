--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {

{-- 2 返回主界面
	delay = 300, unLock = false,
	trigger = "view", name = "intance.IntanceView",
	event = "click", clickName = "intance.IntanceView.root.closeBtn",
	shouzhi = {angle = 270, x = -50},
	talk = {str = "XINSHOU_1002", x = -200, y = -100},
	closeWorld = 1,
},
{
	delay = 0, unLock = false,
	trigger = "done",
	event = "close",
},
{-- 37 点军团
	delay = 300, unLock = false,
	trigger = "done",
	event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
	shouzhi = {angle = 270, x = -50},
},
{-- 38 点弩手
	delay = 500, unLock = false,
	trigger = "view", name = "team.TeamListView",
	event = "click", clickName = "team.TeamListView.root.tableViewBg.106",
	shouzhi = {angle = 270, x = -50, cx = 0},
	showTeam = 106,
},
{-- 38 点升星
	delay = 300, unLock = false,
	trigger = "view", name = "team.TeamView",
	event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.tab3",
	shouzhi = {angle = 270, x = -50},
},
{-- 15 点升星
	delay = 500, unLock = false,
	trigger = "done",
	event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamUpStarNode.root.bg.upStar",
	talk = {str = "XINSHOU_1003", x = -200, y = -100},
	shouzhi = {angle = 270, x = -50},
},
{-- 15 点升星
	delay = 500, unLock = true,
	trigger = "done",
	event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamUpStarNode.root.bg.upStar",
	talk = {str = "XINSHOU_1004", x = -200, y = -100},
	shouzhi = {angle = 270, x = -50},
},
}
return config