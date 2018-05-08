--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--157 解锁技能动画 保存点
				{
					delay = 300, unLock = true,
					trigger = "view", name = "guild.map.GuildMapFamView",	
					event = "story", storyid = 43,
				},
}
return config