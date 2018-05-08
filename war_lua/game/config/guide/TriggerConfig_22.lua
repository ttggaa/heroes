--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
{-- 95 解锁技能动画 保存点
	delay = 100, unLock = false,
	event = "story", storyid = 38,
},
{
	delay = 100, unLock = true,
	trigger = "storyover",
	event = "click", clickName = "training.TrainingView.root.bg.trainingNode1",
	shouzhi = {angle = 270, x = -50}, 
},
}
return config