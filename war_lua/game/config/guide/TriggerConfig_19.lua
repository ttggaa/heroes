--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
{
	delay = 0, unLock = true,
},
{-- 95 解锁技能动画 保存点
	trigger = "popclose", name = "league.LeagueStartFlagView",
	delay = 0, unLock = false,
	event = "story", storyid = 30,
},
{
	delay = 300, unLock = true,
	trigger = "storyover",
	event = "click", clickName = "league.LeagueView.root.bg.btnBg.matchBtn",
	talk = {str = "XINSHOU_73", x = 200, y = -50},
	shouzhi = {angle = 270, x = -50},
},
}
return config