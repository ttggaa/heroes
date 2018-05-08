--[[
    Filename:    TriggerConfig_2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 18:45:30
    Description: File description
--]]

local config = {

--80
				{
					delay = 300, unLock = false,
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_left.layer_arrow",
					shouzhi = {angle = 270, x = -50}, 
					talk = {str = "XINSHOU_49", x = -200, y = -100},
					sound = "g91",
				},
--81
				{
					delay = 1000, unLock = false,
					trigger = "done",
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_right.layer_arrow",
					shouzhi = {angle = 270, x = -50}, 
					talk = {str = "XINSHOU_50", x = 200, y = -100},
					sound = "g92",
				},
--82
				{
					delay = 1000, unLock = true,
					trigger = "done",
					event = "rush", kind = 2, str = "XINSHOU_999",
				},
--83	布阵上阵 ===
				{
					delay = 0, unLock = false,
					trigger = "popclose", name ="global.IntroduceRushDialog",
					event = "drag", 
					dragName1 = "formation.NewFormationView.root.bg.layer_left.layer_team_formation.formation_icon_8",
					dragName2 = "formation.NewFormationView.root.bg.layer_left_touch",
					dragName3 = "formation.NewFormationView.root.bg.layer_left.layer_team_formation.formation_icon_3",
					talk = {str = "XINSHOU_51", x = -200, y = -92},
					sound = "g94",
					showtip = "TIP_YINDAOBUZHEN",
				},
--84		详情点战斗
				{
					delay = 300, unLock = true, save =4,
					trigger = "done",
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.btn_battle",
					tip = {str = "RUOTIP_32", x = 0, y = 40},
					sound = "g95",
					shouzhi = {angle = 270, x = -50}, 
				},
}
return config