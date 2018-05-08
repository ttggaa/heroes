--[[
    Filename:    TriggerConfig_2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 18:45:30
    Description: File description
--]]

local config = {

{-- 1 点按钮
	delay = 100, unLock = false,
	event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.tab4",
	talk = {str = "XINSHOU_45", x = -200, y = 100},
	shouzhi = {angle = 270, x = -50}, 
},
{-- 1 点第1关 保存点
	delay = 500, unLock = true,
	trigger = "done",
	event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamSkillNode.root.bg.scrollView.skillBg2.warn2.suo",
	talk = {str = "XINSHOU_46", x = -200, y = 100},
	shouzhi = {angle = 270, x = -50}, 
},
}
return config