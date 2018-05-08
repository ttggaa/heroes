--[[
    Filename:    TriggerConfig_2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 18:45:30
    Description: File description
--]]

local config = {
				{-- 137 点击英雄查看
					delay = 100, unLock = false,
					event = "story", storyid = 24,
				},
				{-- 137 点击英雄查看
					delay = 100, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "hero.HeroDetailsView.root.bg.layer_hero_basic_information.hero.HeroBasicInformationView.root.bg.layer.layer_right_3.layer_upgrade.btn_upgrade",
					shouzhi = {angle = 270, x = -50},
				},
				{-- 150 点击进阶
					delay = 100, unLock = true,
					trigger = "popclose",name = "hero.HeroUpgradeResultView",
					event = "click", clickName = "hero.HeroDetailsView.root.bg.btn_basic_information",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "JUQING_050", x = 200, y = -80},
				},
				{
					delay = 100, unLock = true,
					trigger = "done",
					event = "herozhuanchang",
					ui = "hero.HeroDetailsView.root.bg.layer_hero_basic_information.hero.HeroBasicInformationView.root.bg.layer.layer_right_2.image_specialty_bg_2",
					uix = 173, uiy = 146,
				},
				{-- 150 点击进阶
					delay = 300, unLock = true,
					trigger = "done",
					event = "story", storyid = 25,
				},
}
return config