--[[
    Filename:    TriggerConfig_2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 18:45:30
    Description: File description
--]]

local config = {
-- 1 点击"晋升"页签
				{
					delay = 100, unLock = true,
					trigger = "done",	
					event = "click", clickName = "hero.HeroDetailsView.root.bg.btn_upgrade_information",
					shouzhi = {angle = 270, x = -50},
				},
-- 2 英雄晋升介绍
				{
					delay = 100, unLock = false,
					trigger = "done",
					event = "story", storyid = 24,
				},
-- 3 点击“升星”按钮
				{
					delay = 100, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "hero.HeroDetailsView.root.bg.layer_hero_basic_information.hero.HeroBasicInformationView.root.bg.layer.layer_right_3.layer_upgrade.btn_upgrade",
					shouzhi = {angle = 270, x = -50},
				},
-- 4 点击"专长"页签
				{
					delay = 100, unLock = true,
					trigger = "done",
					event = "click", clickName = "hero.HeroDetailsView.root.bg.btn_basic_information",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "JUQING_050", x = -250, y = -125},
				},
-- 5 专长介绍
				{
					delay = 100, unLock = true,
					trigger = "done",
					event = "story", storyid = 25,
				},
}
return config