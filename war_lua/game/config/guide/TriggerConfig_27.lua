--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--134 点技能
				{
					delay = 0, unLock = false,
					trigger = "view", name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.tab4",
					talk = {str = "XINSHOU_79", x = -200, y = -100},
					shouzhi = {angle = 270, x = -50},
				},
--135 点技能
				{
					delay = 500, unLock = true,
					trigger = "done",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamSkillNode.root.bg.scrollView.skillBg1.permit.Image_52",
					talk = {str = "XINSHOU_80", x = -200, y = -100},
					shouzhi = {angle = 270, x = -50},
				},	
}
return config