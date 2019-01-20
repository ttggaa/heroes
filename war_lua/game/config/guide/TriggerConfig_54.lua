--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {
--212 3v3竞技场介绍
				{
					delay = 300, unLock = true,
					trigger = "view", name = "gloryArena.GloryArenaView",
					event = "story", storyid = 71,
				},
--213 点击防守按钮
				{
					delay = 300, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "gloryArena.GloryArenaView.root.bg.layer.btnBg_ground.formationBtn",
					shouzhi = {angle = 90, x = 50 ,},
				},
--214 防守介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 72,
				},
--215 点击布阵2按钮
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.info_left.glory_arena_info.layer_formation_select.layer_formation_2",
					shouzhi = {angle = 270, x = -50},
				},

--216 布阵介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 73,
				},
--217  点击编组信息按钮
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.info_left.glory_arena_info.layer_formation_select.btn_info_formation",
					shouzhi = {angle = 270, x = -50},
				},
--218 编组信息介绍
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "story", storyid = 74,
				},
--219 关闭布阵
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "formation.NewFormationSwapView.root.bg.layer_cross2.btn_close",
					shouzhi = {angle = 270, x = -50},
				},
--220 返回竞技场主界面
				{
					delay = 300, unLock = true,
					trigger = "done",	
					event = "click", clickName = "formation.NewFormationView.root.bg.btn_return",
					shouzhi = {angle = 270, x = -50},
				},
}
return config