--[[
    Filename:    TriggerConfig_1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 16:26:56
    Description: File description
--]]

local config = {

{-- 95 解锁技能动画 保存点
	delay = 200, unLock = false,
	event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100209",
	talk = {str = "LOSSGUIDE_1", x = 200, y = -100},
	shouzhi = {angle = 270, x = -50}, 
},
{--
	delay = 300, unLock = false,
	trigger = "layer", name = "intance.IntanceStageInfoNode",
	event = "click", clickName = "intance.IntanceStageInfoNode.root.bg.battleBtn",
	shouzhi = {angle = 270, x = -50}, 
},
{--
	delay = 300, unLock = false,
	trigger = "view", name = "formation.NewFormationView",
	event = "drag", 
	dragName1 = "formation.NewFormationView.root.bg.layer_left.layer_team_formation.formation_icon_5",
	dragName2 = "formation.NewFormationView.root.bg.layer_left_touch",
	dragName3 = "formation.NewFormationView.root.bg.layer_left.layer_team_formation.formation_icon_9",
	scale1 = true,
	talk = {str = "LOSSGUIDE_2", x = -200, y = -92},
},
{--
	delay = 300, unLock = false,
	trigger = "done",
	event = "drag", 
	dragName1 = "formation.NewFormationView.root.bg.layer_left.layer_team_formation.formation_icon_6",
	dragName2 = "formation.NewFormationView.root.bg.layer_left_touch",
	dragName3 = "formation.NewFormationView.root.bg.layer_left.layer_team_formation.formation_icon_10",
	scale1 = true,
	talk = {str = "LOSSGUIDE_3", x = -200, y = -92},
},
	{
	delay = 300, unLock = true,
	trigger = "done",
	event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.btn_battle",
	shouzhi = {angle = 270, x = -50}, 
},
}
return config