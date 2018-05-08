--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--144 法术书 点购买一次
				{
					delay = 1500, unLock = true,
					trigger = "view", name = "skillCard.SkillCardTakeView",
					event = "click", clickName = "skillCard.SkillCardTakeView.root.bottomPanel.oneGet",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_97", x = 200, y = 0},
				},
--145 点书柜
				{
					delay = 300, unLock = false,
					trigger = "popclose", name = "skillCard.SkillCardResultView",								
					event = "click", clickName = "skillCard.SkillCardTakeView.root.skillBtn",
					shouzhi = {angle = 90, x = 50},
					talk = {str = "XINSHOU_98", x = 200, y = 0},
				},
--146  点第一个格
				{
					delay = 300, unLock = true,
					trigger = "view", name = "spellbook.SpellBookCaseView",							
					event = "click", clickName = "spellbook.SpellBookCaseView.root.bg.item1",
					shouzhi = {angle = 90, x = 50 ,},
					talk = {str = "XINSHOU_99", x = 100, y = -100},
				},					
}
return config