--[[
    Filename:    TriggerConfig.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-18 17:30:20
    Description: File description
--]]

-- 触发点配置
local triggerPoint = 
{
	-- 第一次进入界面触发列表
	view = 
	{	-- ex ["bag.BagView"] = "1",
		["arena.ArenaView"] = "11",
	-- ["activity.ActivitySignInView"] = "12",
		--["guild.map.GuildMapView"] = "14",
		["league.LeagueView"] = "19",
		["training.TrainingView"] = "22",
		["nests.NestsView"] = "24",
		["team.TeamView"] = "27",
		["treasure.TreasureView"] = "35",
		["skillCard.SkillCardTakeView"] = "37",
		["weapons.WeaponsView"] = "38",		
		["guild.map.GuildMapFamView"] = "41",
		["cross.CrossMainView"] = "42",
		["purgatory.PurgatoryView"] = "44",
		["team.TeamHolyView"] = "46",
		["starCharts.StarChartsView"] = "48",
	},	-- 第一次按下某按钮触发列表
	btn = 
	{	
	["siegeDaily.SiegeDailySelectView.root.bg.attackBtn"] = "39",
	["siegeDaily.SiegeDailySelectView.root.bg.defendBtn"] = "40",
	["spellbook.SpellBookCaseView.root.bg.ruleBtn"] = "43",
	["team.TeamHolyView.root.bg.breakBtn"] = "47",
	},
	-- 第一次进入副本某章
	section =
	{	-- ex ["71006"] = "1"

	},
	-- 第一次某关副本胜利
	intanceWin = 
	{	-- ex ["7100101"] = "2"
	["7100208"] = "1",
	--升星
	--["7100302"] = "8",
	--圣殿
	["7100312"] = "9",
	--圣殿
	["7100203"] = "10",
	--装备升级
	},
	-- 第一次某关支线胜利
    branchWin = 
	{
	["7100310"] = "15",
	["3"] = "21",
	--3-12凤凰
	},	
	-- 特殊触发
	action = 
	{
	["1"] = "4", 
	-- 第一次兵团进阶至蓝色
	--["2"] = "5", 
	-- 第一次副本战斗失败 主线&精英  退出不算
	["5"] = "6", 
	-- 第一次任意兵团升星 小星满10颗,在兵团升星界面
	--["3"] = "7", 
	-- 获得十字军，进入布阵界面 
	["4"] = "7", 
	-- 获得英雄60303，进入远征布阵战前界面(增加没上场的判断) 
	["6"] = "3",
	-- 进入英雄详情界面，该英雄可升星
	["7"] = "13",
	-- 第一次远征胜利，在远征主界面触发
	
	--积分联赛战斗一次
	--["8"] = "20",

	-- 在主界面判断，道具死神靴（40323）数量大于等于1  触发支线引导
	--["9"] = "23",
	
	-- 在积分联赛主界面  第一赛季 段位=2
	["10"] = "25",

	-- 在积分联赛主界面  第一赛季 段位=3
	["11"] = "26",

	-- 首次进入联盟地图
	--["12"] = "30",

	-- 首次进入联盟地图地下城
	["13"] = "31",

	-- 首次进入联盟地图其他联盟
	["14"] = "32",

	--在积分联赛主界面  第一赛季 段位=9
	["15"] = "34",

	--觉醒的引导
	["16"] = "36",
	},
	-- 第一次进入某副本的布阵
	formation = 
	{
	["7100201"] = "2",
	["7100209"] = "16",
	["7100501"] = "33",
	},
	intanceLose =
	{
	["7100209"] = "17",
	["7100305"] = "18",
	},
	open = 
	{
		-- 积分联赛
	["101"] = "28",
		-- 英雄交锋
	["104"] = "29",
	},
	purgatory = 
	{
		["winFirstStage"] = "45"	--无尽炼狱打完第一关触发
	}
}
return triggerPoint