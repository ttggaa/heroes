﻿--[[
    Filename:    AnimAP.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-22 10:42:24
    Description: File description
--]]

-- 定位点

-- "H" 为序列帧兵团血条高度
-- "R" 为接战半径
-- R会影响战斗结果, 慎改
-- 骨骼动画的单兵血条为[0] = {w, h}中的h
-- 序列帧的单兵血条为第一个动作第一帧的图片高度
local AnimAp = 
{
	--===================== 序列帧 =====================--
	-- 1 --
	["jibing"] = 			{ 	[1] = {0, 20},		[2] = {0, 90},		["H"] = 100,   	["R"] = 22,},

	["nushou"] = 			{	[1] = {0, 22.5},	[2] = {0, 78},		["H"] = 88,   	["R"] = 18,},
	["huanyingsheshounan"] ={	[1] = {0, 30},		[2] = {0, 94},		["H"] = 104,   	["R"] = 18,},

	["shijiu"] = 			{	[1] = {0, 50},		[2] = {20, 100},	["H"] = 110,   	["R"] = 26,},

	["shizijun"] = 			{	[1] = {0, 16},		[2] = {0, 86},		["H"] = 96,   	["R"] = 22,},
	["tieshizijun"] = 		{	[1] = {0, 24},		[2] = {0, 87},		["H"] = 97,   	["R"] = 22,},
	["shizijunjuexing"] = 	{	[1] = {0, 30},		[2] = {0, 86},		["H"] = 96,   	["R"] = 22,},

	["senglv"] = 			{	[1] = {10, 25},		[2] = {0, 80},		["H"] = 90,   	["R"] = 18,},
	["senglvjuexing"] = 	{	[1] = {10, 25},		[2] = {0, 80},		["H"] = 90,   	["R"] = 18,},

	["qishi"] = 			{	[1] = {0, 50},		[2] = {0, 112},		["H"] = 122,   	["R"] = 26,},
	["qishijuexing"] = 		{	[1] = {0, 50},		[2] = {0, 112},		["H"] = 122,   	["R"] = 26,},
	["jibingjuexing"] = 	{ 	[1] = {0, 20},		[2] = {0, 90},		["H"] = 100,   	["R"] = 22,},
	["shengqishi"] = 	    { 	[1] = {10, 50},		[2] = {10, 140},	["H"] = 135,   	["R"] = 26,},
	["shengqishijuexing"] = { 	[1] = {10, 50},		[2] = {10, 140},	["H"] = 135,   	["R"] = 26,},
	["shengtangshicong"] = 	{ 	[1] = {5, 30},		[2] = {5, 80}, 	    ["H"] = 80,   	["R"] = 26,},
	["shengtangshicongjuexing"] = 	{ 	[1] = {5, 30},		[2] = {5, 80}, 	    ["H"] = 80,   	["R"] = 26,},

	-- 2 --
	["banrenma"] = 			{ 	[1] = {0, 46}, 		[2] = {13, 119}, 	["H"] = 129,   	["R"] = 26,},
	["banrenmajuexing"] = 	{ 	[1] = {0, 46}, 		[2] = {13, 119}, 	["H"] = 129,   	["R"] = 26,},

	["airen"] = 			{ 	[1] = {0, 15}, 		[2] = {0, 65}, 		["H"] = 75,   	["R"] = 18,},
	
	["mujingling"] = 		{	[1] = {0, 22.5},	[2] = {0, 78},		["H"] = 85,     ["R"] = 18,},
	["mujinglingjuexing"] = {	[1] = {0, 22.5},	[2] = {0, 78},		["H"] = 85,     ["R"] = 18,},
	["mujinglingpifu"] = 	{	[1] = {0, 22.5},	[2] = {0, 78},		["H"] = 85,     ["R"] = 18,},
	["huanyingsheshounv"] = {	[1] = {0, 30},		[2] = {5, 83},		["H"] = 93,   	["R"] = 18,},

	["feima"] = 			{	[1] = {0, 52},		[2] = {-5, 124},	["H"] = 134,   	["R"] = 26,},
	["feimaqishijuexing"] = {	[1] = {10, 70},		[2] = {10, 145},	["H"] = 150,   	["R"] = 30,},

	["dujiaoshou"] = 		{	[1] = {0, 42},		[2] = {33, 90},		["H"] = 100,   	["R"] = 26,},
	["dujiaoshoujuxing"] = 	{	[1] = {0, 42},		[2] = {33, 90},		["H"] = 100,   	["R"] = 26,},
	["deluyi"] = 		    {	[1] = {0, 42},		[2] = {5, 95},		["H"] = 100,   	["R"] = 26,},
	["deluyijuexing"] = 		    {	[1] = {0, 42},		[2] = {5, 95},		["H"] = 100,   	["R"] = 26,},
	["wuqideluyi"] = 		    {	[1] = {0, 42},		[2] = {5, 95},		["H"] = 100,   	["R"] = 26,},

	-- 3 --
	["kuloubing"] = 		{	[1] = {0, 16},		[2] = {0, 82},		["H"] = 92,   	["R"] = 22,},
	["kuloujuexing"] = 		{	[1] = {10, 30},		[2] = {12, 82},		["H"] = 100,   	["R"] = 22,},

	["jiangshi"] = 			{	[1] = {0, 35},		[2] = {5, 90},		["H"] = 100,   	["R"] = 22,},
	["jiangshijuexing"] = 	{	[1] = {0, 35},		[2] = {5, 90},		["H"] = 100,   	["R"] = 22,},

	["youling"] = 			{	[1] = {0, 32},		[2] = {0, 94},		["H"] = 104,   	["R"] = 18,},
	["youlingjuexing"] = 			{	[1] = {0, 32},		[2] = {0, 94},		["H"] = 104,   	["R"] = 18,},

	["xixuegui"] = 			{	[1] = {0, 37},		[2] = {0, 96},		["H"] = 106,   	["R"] = 22,},
	["xixueguijuexing"] = 	{	[1] = {10, 37},		[2] = {10, 110},	["H"] = 120,   	["R"] = 30,},

	["wuyao"] = 			{	[1] = {0, 27},		[2] = {4, 95},		["H"] = 105,   	["R"] = 26,},
	["wuyaojuexing"] = 		{	[1] = {5, 45},		[2] = {10, 105},	["H"] = 105,   	["R"] = 26,},
	["wuqiwuyao"] = 			{	[1] = {0, 27},		[2] = {4, 95},		["H"] = 105,   	["R"] = 26,},

	["heianqishi"] = 		{	[1] = {0, 40},		[2] = {-5, 125},	["H"] = 135,   	["R"] = 22,},
	["wuqiheianqishi"] = 		{	[1] = {0, 40},		[2] = {-5, 125},	["H"] = 135,   	["R"] = 22,},
	["siwangqishi"] = 		{	[1] = {0, 40},		[2] = {-3, 125},	["H"] = 135,   	["R"] = 22,},
	["heianqishijuexing"] = { 	[1] = {0, 55},		[2] = {0, 145},		["H"] = 160,   	["R"] = 40,},

    ["munaiyi"] = 			{	[1] = {0, 50},		[2] = {4, 125},		["H"] = 130,   	["R"] = 30,},
    ["munaiyijuexing"] = 			{	[1] = {0, 50},		[2] = {4, 125},		["H"] = 130,   	["R"] = 30,},

  
	-- 4 --
	["dijingzhanshi"] = 	{	[1] = {0, 20},		[2] = {20, 75},		["H"] = 85,   	["R"] = 22,},
	["dijingzhanshijuexing"] = 	{	[1] = {0, 20},		[2] = {20, 75},		["H"] = 85,   	["R"] = 22,},


	["langqibing"] = 		{	[1] = {0, 46},		[2] = {0, 105},		["H"] = 115,   	["R"] = 22,},
	["langqibingjuexing"] = 		{	[1] = {0, 46},		[2] = {0, 105},		["H"] = 115,   	["R"] = 22,},


	["shourentoufushou"] = 	{	[1] = {-5, 25},		[2] = {5, 90},		["H"] = 100,   	["R"] = 22,},

	["shirenmo"] = 			{	[1] = {10, 40},		[2] = {8, 130},		["H"] = 140,   	["R"] = 26,},
	["shirenmojuexing"] = 	{	[1] = {10, 40},		[2] = {8, 130},		["H"] = 140,   	["R"] = 26,},

	["kuangzhanshi"] = 	{	[1] = {10, 40},		[2] = {8, 130},		["H"] = 140,   	["R"] = 40,},
	["kuangzhanshijuexing"] = 	{	[1] = {10, 40},		[2] = {8, 130},		["H"] = 140,   	["R"] = 40,},

	-- 5 --
	["xiaoemo"] = 			{	[1] = {0, 26},		[2] = {6, 82},		["H"] = 92,   	["R"] = 22,},
	["xiaoemojuexing"] = 	{	[1] = {0, 26},		[2] = {6, 82},		["H"] = 92,   	["R"] = 22,},

	["touhuoguai"] = 		{	[1] = {0, 24},		[2] = {6, 87},		["H"] = 97,   	["R"] = 22,},
	["gegejuexing"] = 		{	[1] = {10, 36},		[2] = {6, 100},		["H"] = 110,   	["R"] = 22,},

	["santouquan"] = 		{	[1] = {7, 25},		[2] = {23, 70},		["H"] = 80,   	["R"] = 22,},

	["changjiaoemo"] = 		{	[1] = {0, 30},		[2] = {28, 104},	["H"] = 114,   	["R"] = 22,},

	["xieshenwang"] = 		{	[1] = {0, 32},		[2] = {0, 111},		["H"] = 121,   	["R"] = 22,},
	["xieshenwangjuexing"] = {	[1] = {0, 32},		[2] = {0, 111},		["H"] = 121,   	["R"] = 22,},

	["liehuojingling"] = 	{	[1] = {7, 57},		[2] = {9, 126},		["H"] = 136,   	["R"] = 26,},
	["lieyanlingzhu"] = 	{	[1] = {7, 57},		[2] = {9, 126},		["H"] = 136,   	["R"] = 26,},
	["huojinglingjuexing"] ={	[1] = {15, 70},		[2] = {9, 135},		["H"] = 145,   	["R"] = 26,},
	["mengyan"] =           {	[1] = {5, 40},		[2] = {30, 110},	["H"] = 110,   	["R"] = 26,},

	-- 6 --
	["shixianggui"] = 		{	[1] = {0, 25},		[2] = {21, 95},		["H"] = 105,   	["R"] = 26,},

	["tieren"] = 			{	[1] = {4, 47},		[2] = {20, 118},	["H"] = 128,   	["R"] = 26,},
	["tierenjuexing"] = 			{	[1] = {4, 47},		[2] = {20, 118},	["H"] = 128,   	["R"] = 26,},

	["dafashi"] = 			{	[1] = {0, 27},		[2] = {0, 92},		["H"] = 102,   	["R"] = 22,},
	["dafashijuxing"] = 	{	[1] = {10, 45},	[2] = {0, 110},		["H"] = 102,   	["R"] = 22,},

	["dengshen"] = 			{	[1] = {0, 62},		[2] = {0, 147},		["H"] = 157,   	["R"] = 26,},
	["dengshenjuexing"] = 	{	[1] = {0, 62},		[2] = {0, 147},		["H"] = 157,   	["R"] = 26,},

	["najianvyao"] = 		{	[1] = {6, 31},		[2] = {6, 110},		["H"] = 140,   	["R"] = 35,},
	["najiajuexing"] = 		{	[1] = {0, 40},		[2] = {0, 130},	["H"] = 140,   	["R"] = 35,},
	["wuqinajianvyao"] = 	{	[1] = {0, 40},		[2] = {0, 130},	["H"] = 140,   	["R"] = 35,},
	["reqiqiu"] = 			{	[1] = {6, 60},		[2] = {0, 180},		["H"] = 120,   	["R"] = 26,},
	-- 7 --
	["yingshenren"] = 		{	[1] = {6, 50},		[2] = {6, 130},		["H"] = 120,   	["R"] = 22,},

	["dongxueren"] = 		{	[1] = {10, 50},		[2] = {30, 120},	["H"] = 130,   	["R"] = 26,},

	["shixie"] =     		{	[1] = {15, 50},		[2] = {30, 120},	["H"] = 130,   	["R"] = 26,},
	["wuqishixie"] =     		{	[1] = {15, 50},		[2] = {30, 120},	["H"] = 130,   	["R"] = 26,},
	["shixiejuexing"] =     		{	[1] = {15, 50},		[2] = {30, 120},	["H"] = 130,   	["R"] = 26,},

	["niutouguai"] =     	{	[1] = {6, 40},		[2] = {20, 100},	["H"] = 90,   	["R"] = 26,},
	["niutouguaijuexing"] =     	{	[1] = {6, 40},		[2] = {20, 100},	["H"] = 90,   	["R"] = 26,},
	-- 8 --
	["langren"] =     		{	[1] = {15, 40},		[2] = {50, 90},	["H"] = 90,   	["R"] = 26,},
	["xiyiren"] =     		{	[1] = {6, 40},		[2] = {20, 100},	["H"] = 90,   	["R"] = 26,},
	["xiyi"] =       		{	[1] = {15, 50},		[2] = {80, 100},	["H"] = 90,   	["R"] = 26,},
	["longying"] =      	{	[1] = {-20, 50},	[2] = {0, 100},	["H"] = 90,   	["R"] = 26,},
	["shuangzufeilong"] =   {	[1] = {30, 70},		[2] = {60, 140},	["H"] = 90,   	["R"] = 26,},
	["shuangzufeilongjuexing"] =   {	[1] = {30, 70},		[2] = {60, 140},	["H"] = 90,   	["R"] = 26,},
	["manniu"] =        	{	[1] = {15, 40},		[2] = {50, 80},	      ["H"] = 90,   	["R"] = 26,},
	["manniujuexing"] =     {	[1] = {15, 40},		[2] = {50, 80},	      ["H"] = 90,   	["R"] = 26,},
	["duotoulong"] =       	{	[1] = {15, 40},		[2] = {50, 80},	      ["H"] = 90,   	["R"] = 85,},
	["wuqiduotoulong"] =       	{	[1] = {15, 40},		[2] = {50, 80},	      ["H"] = 90,   	["R"] = 85,},	

	-- 9 --
	["mofaxianling"] = 		{	[1] = {6, 31},		[2] = {6, 110},		["H"] = 120,   	["R"] = 26,},
	["leiyuansu"] = 		{	[1] = {11, 51},		[2] = {6, 130},		["H"] = 140,   	["R"] = 26,		[3] = {87, 49}},
	["bingyuansu"] = 		{	[1] = {-4, 31},		[2] = {-10, 110},	["H"] = 120,   	["R"] = 32,		[3] = {24, 100}},
	["liehuoyuansu"] = 		{	[1] = {10, 81},	    [2] = {6, 160},		["H"] = 120,   	["R"] = 32,	},
	["youhuoyuansu"] = 		{	[1] = {10, 81},	    [2] = {6, 140},		["H"] = 120,   	["R"] = 32,	},
	["wuqiliehuoyuansu"] = 		{	[1] = {10, 81},	    [2] = {6, 160},		["H"] = 120,   	["R"] = 32,	},
	["jingshenyuansu"] = 	{	[1] = {10, 81},	    [2] = {6, 160},		["H"] = 120,   	["R"] = 32,	},
	["shiyuansu"] = 		{	[1] = {8, 65},	    [2] = {6, 155},		["H"] = 120,   	["R"] = 32,	},
	["wuqishiyuansu"] = 		{	[1] = {8, 65},	    [2] = {6, 155},		["H"] = 120,   	["R"] = 32,	},

    -- 10 --
    ["haidao"] = 		    { 	[1] = {0, 20},		[2] = {0, 90},		["H"] = 100,   	["R"] = 22,},
    ["jingyinghaidao"] = 	{ 	[1] = {0, 20},		[2] = {0, 90},		["H"] = 100,   	["R"] = 22,},

    ["haiyuansu"] = 		{ 	[1] = {0, 20},		[2] = {0, 90},		["H"] = 100,   	["R"] = 22,},
    ["yurenyongshi"] = 		{ 	[1] = {0, 20},		[2] = {0, 90},		["H"] = 100,   	["R"] = 22,},


	-- 矮人宝屋 --
	["airenex"] = 			{ 	[1] = {0, 15}, 		[2] = {0, 53}, 		["H"] = 63,   	["R"] = 18,},
	["jinairen"] = 			{ 	[1] = {0, 40},		[2] = {-5, 110},	["H"] = 120,   	["R"] = 32,},
	-- 阴森墓穴
	["muzhuanga"] = 		{	[1] = {0, 20},		[2] = {0, 53},		["H"] = 53,   	["R"] = 100,},
	["muzhuangb"] = 		{	[1] = {0, 33},		[2] = {0, 75},		["H"] = 75,   	["R"] = 100,},
	["ojiangshi"] = 		{	[1] = {0, 27},		[2] = {0, 78},		["H"] = 88,   	["R"] = 22,},
	-- 野怪
	["lang"] = 				{	[1] = {0, 27.5},	[2] = {12, 50},		["H"] = 58,   	["R"] = 22,},
	["nongmin"] = 			{	[1] = {0, 30},		[2] = {0, 79},		["H"] = 79,   	["R"] = 22,},
	["youmumin"] = 			{	[1] = {0, 31},		[2] = {0, 80},		["H"] = 90,   	["R"] = 22,},
	["daozei"] = 			{	[1] = {0, 25},		[2] = {5, 74},		["H"] = 84,   	["R"] = 22,},
	["zhongzhuangkulou"] = 	{	[1] = {8, 20},		[2] = {5, 78},		["H"] = 88,   	["R"] = 22,},
	
	["shuiyuansu"] = 		{	[1] = {5, 30},		[2] = {5, 95},		["H"] = 105,   	["R"] = 22,},
	["xiaoshuren"] = 		{	[1] = {0, 30},		[2] = {0, 85},		["H"] = 95,   	["R"] = 22,},
	["kulou"] = 			{	[1] = {0, 20},		[2] = {0, 74},		["H"] = 84,   	["R"] = 22,},
	["kulougongjianbing"] = {	[1] = {6, 25},		[2] = {4, 81},		["H"] = 90,   	["R"] = 22,},
	["senlinlang"] = 		{	[1] = {0, 27},		[2] = {24, 48},		["H"] = 58,   	["R"] = 22,},


	-- 城墙
	["chengbao"] = 			{	[1] = {0, 50},		[2] = {0, 145},		["H"] = 145,   	["R"] = 100,},
	["chengbaor"] = 		{	[1] = {0, 50},	 	[2] = {0, 145},	 	["H"] = 145,   	["R"] = 100,},
	["bilei"] = 			{	[1] = {0, 50},		[2] = {0, 145},		["H"] = 145,   	["R"] = 100,},
	["yaosai"] = 			{	[1] = {0, 50},		[2] = {0, 145},		["H"] = 145,   	["R"] = 100,},
	["muyuan"] = 			{	[1] = {0, 50},		[2] = {0, 145},		["H"] = 145,   	["R"] = 100,},
	["diyu"] = 				{	[1] = {0, 50},		[2] = {0, 145},		["H"] = 145,   	["R"] = 100,},
	["judian"] = 			{	[1] = {0, 50},		[2] = {0, 145},		["H"] = 145,   	["R"] = 100,},
	["talou"] = 			{	[1] = {0, 50},		[2] = {0, 145},		["H"] = 145,   	["R"] = 100,},
	["dixiacheng"] = 		{	[1] = {0, 50},		[2] = {0, 145},		["H"] = 145,   	["R"] = 100,},


	
	--===================== 骨骼动画 =====================--
	

	-- 0 宽高 1 身体中心 2 头顶 3 弹道发射点
	["mcList"] = {
		-- 1 --
		["datianshi"] = { ["scale"] = 0.45, ["R"] = 65,
			[0] = {220, 190}, [1] = {8 * 2, 75 * 2}, [2] = {0 * 2, 180 * 2}, [3] = {8 * 2, 75 * 2},},
		["datianshijuexing"] = { ["scale"] = 0.45, ["R"] = 65,
			[0] = {220, 190}, [1] = {8 * 2, 100* 2}, [2] = {0 * 2, 210 * 2}, [3] = {20 * 2, 90 * 2},},
		["datianshipifu"] = { ["scale"] = 0.45, ["R"] = 65,
			[0] = {220, 190}, [1] = {8 * 2, 100* 2}, [2] = {0 * 2, 210 * 2}, [3] = {20 * 2, 90 * 2},},
		["shenpanguan"] = { ["scale"] = 0.45, ["R"] = 65,
			[0] = {220, 190}, [1] = {8 * 2, 75 * 2}, [2] = {0 * 2, 180 * 2}, [3] = {8 * 2, 75 * 2},},
		["shenpanguanpifu"] = { ["scale"] = 0.45, ["R"] = 65,
			[0] = {220, 190}, [1] = {8 * 2, 75 * 2}, [2] = {0 * 2, 180 * 2}, [3] = {8 * 2, 75 * 2},},	

		-- 2 --
		["shuyao"] = {["scale"] = 0.5, ["R"] = 65,
            [0] = {272, 240}, [1] = {17 * 2, 60 * 2}, [2] = {20 * 2, 200 * 2}, [3] = {0 * 2, 107 * 2},},

		["kumuweishio"] = {["scale"] = 0.5, ["R"] = 65,
            [0] = {190, 200}, [1] = {7 * 2, 73 * 2}, [2] = {16 * 2, 190 * 2}, [3] = {7 * 2, 73 * 2},},
        ["jiayuanweishi"] = {["scale"] = 0.5, ["R"] = 65,
            [0] = {190, 200}, [1] = {7 * 2, 73 * 2}, [2] = {16 * 2, 200 * 2}, [3] = {7 * 2, 73 * 2},},

		["lvlong"] = {["scale"] = 0.5, ["R"] = 80,
			[0] = {250, 180}, [1] = {50 * 2, 110 * 2}, [2] = {110 * 2, 170 * 2}, [3] = {189 * 2, 66 * 2},},	
		["jinlong"] = {["scale"] = 0.5, ["R"] = 80,
			[0] = {250, 180}, [1] = {30 * 2, 100 * 2}, [2] = {110 * 2, 170 * 2}, [3] = {189 * 2, 66 * 2},},	

		["bileizhihuiguan"] = {["scale"] = 0.5, ["R"] = 65,
            [0] = {272, 240}, [1] = {17 * 2, 60 * 2}, [2] = {20 * 2, 200 * 2}, [3] = {0 * 2, 107 * 2},},
        ["bileizhihuiguanpifu"] = {["scale"] = 0.5, ["R"] = 65,
            [0] = {272, 240}, [1] = {17 * 2, 60 * 2}, [2] = {20 * 2, 200 * 2}, [3] = {0 * 2, 107 * 2},},

		-- 3 -- 
		["gulong"] = {["scale"] = 0.5, ["R"] = 65,
			[0] = {280, 160}, [1] = {21 * 2, 105 * 2}, [2] = {113 * 2, 145 * 2}, [3] = {46 * 2, 74 * 2},},
		["gulongjuexing"] = {["scale"] = 0.5, ["R"] = 65,
			[0] = {280, 160}, [1] = {21 * 2, 105 * 2}, [2] = {113 * 2, 145 * 2}, [3] = {46 * 2, 74 * 2},},
                ["wuqigulong"] = {["scale"] = 0.5, ["R"] = 65,
			[0] = {280, 160}, [1] = {21 * 2, 105 * 2}, [2] = {113 * 2, 145 * 2}, [3] = {46 * 2, 74 * 2},},
		["sishen"] = {["scale"] = 0.5, ["R"] = 150,
			[0] = {280, 250}, [1] = {21 * 2, 105 * 2}, [2] = {18 * 2, 245 * 2}, [3] = {46 * 2, 150 * 2},},
		["sishenpifu"] = {["scale"] = 0.5, ["R"] = 150,
			[0] = {280, 250}, [1] = {21 * 2, 105 * 2}, [2] = {18 * 2, 245 * 2}, [3] = {46 * 2, 150 * 2},},
		-- 4 --
		["leiniao"] = {["scale"] = 0.5, ["R"] = 80,
			[0] = {295, 260}, [1] = {5 * 2, 136 * 2}, [2] = {46 * 2, 233 * 2}, [3] = {129 * 2, 110 * 2},},

		["duyanjuren"] = {["scale"] = 0.5,["R"] = 65,
			[0] = {230, 210}, [1] = {10 * 2, 100 * 2}, [2] = {25 * 2, 210 * 2}, [3] = {45 * 2, 250 * 2},},
		["duyanjurenjuexing"] = {["scale"] = 0.5,["R"] = 65,
			[0] = {230, 210}, [1] = {10 * 2, 100 * 2}, [2] = {25 * 2, 210 * 2}, [3] = {45 * 2, 250 * 2},},

		["fengbaolingzhu"] = {["scale"] = 0.5, ["R"] = 80,
			[0] = {295, 260}, [1] = {5 * 2, 136 * 2}, [2] = {46 * 2, 233 * 2}, [3] = {129 * 2, 110 * 2},},
			
		["kuangbaojuren"] = {["scale"] = 0.5,["R"] = 65,
			[0] = {230, 210}, [1] = {10 * 2, 100 * 2}, [2] = {25 * 2, 210 * 2}, [3] = {45 * 2, 250 * 2},},

		["bimengjushou"] = {["scale"] = 0.5, ["R"] = 65,
            [0] = {300, 260}, [1] = {4 * 2, 100 * 2}, [2] = {50 * 2, 250 * 2}, [3] = {4 * 2, 126 * 2},},
        ["bimengjushoujuexing"] = {["scale"] = 0.5, ["R"] = 65,
            [0] = {300, 260}, [1] = {4 * 2, 100 * 2}, [2] = {90 * 2, 220 * 2}, [3] = {4 * 2, 126 * 2},},
		["yuangujushou"] = {["scale"] = 0.5, ["R"] = 65,
            [0] = {300, 260}, [1] = {4 * 2, 100 * 2}, [2] = {50 * 2, 250 * 2}, [3] = {4 * 2, 126 * 2},},
        ["leiniaojuexing"] = {["scale"] = 0.5, ["R"] = 65,
           [0] = {295, 260}, [1] = {40 * 2, 200 * 2}, [2] = {80 * 2, 233 * 2}, [3] = {130 * 2, 140 * 2},},

		-- 5 --
		["daemo"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {215, 212}, [1] = {0 * 2, 81 * 2}, [2] = {-10 * 2, 194 * 2}, [3] = {0 * 2, 81 * 2},},	
		["daemoshengji"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {215, 212}, [1] = {0 * 2, 81 * 2}, [2] = {-10 * 2, 194 * 2}, [3] = {0 * 2, 81 * 2},},	
	    ["daemoshengjuexing"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {215, 212}, [1] = {-5 * 2, 140 * 2}, [2] = {-15 * 2, 270 * 2}, [3] = {0 * 2, 81 * 2},},
                ["wuqidaemo"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {215, 212}, [1] = {0 * 2, 81 * 2}, [2] = {-10 * 2, 194 * 2}, [3] = {0 * 2, 81 * 2},},	
		-- 6 --
		["taitan"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {300, 250}, [1] = {10 * 2, 80 * 2}, [2] = {5 * 2, 255 * 2}, [3] = {10 * 2, 62 * 2},},	 
		["taitanjuexing"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {300, 250}, [1] = {10 * 2, 80 * 2}, [2] = {5 * 2, 255 * 2}, [3] = {10 * 2, 62 * 2},},	 
		["kuileilong"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {300, 250}, [1] = {10 * 2, 80 * 2}, [2] = {5 * 2, 255 * 2}, [3] = {10 * 2, 62 * 2},},	 
		["kuileilongpifu"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {300, 250}, [1] = {10 * 2, 80 * 2}, [2] = {5 * 2, 255 * 2}, [3] = {10 * 2, 62 * 2},},	 
		-- 7 --
		["meidusha"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {150, 130}, [1] = {10 * 2, 35 * 2}, [2] = {5 * 2, 180 * 2}, [3] = {50 * 2, 80 * 2},},	 
		["wuqimeidusha"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {150, 130}, [1] = {10 * 2, 35 * 2}, [2] = {5 * 2, 180 * 2}, [3] = {50 * 2, 80 * 2},},	 
		["heilong"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {300, 200}, [1] = {50 * 2, 100 * 2}, [2] = {100 * 2, 230 * 2}, [3] = {0 * 2, 20 * 2},},	 
		["heilongjuexing"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {300, 200}, [1] = {50 * 2, 100 * 2}, [2] = {100 * 2, 230 * 2}, [3] = {0 * 2, 20 * 2},},
		["wuqiheilong"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {300, 200}, [1] = {50 * 2, 100 * 2}, [2] = {100 * 2, 230 * 2}, [3] = {0 * 2, 20 * 2},},	
		["xieyan"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {150, 150}, [1] = {10 * 2, 60 * 2}, [2] = {5 * 2, 145 * 2}, [3] = {18 * 2, 98 * 2},},	 
		["xieyanjuexing"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {150, 150}, [1] = {10 * 2, 60 * 2}, [2] = {5 * 2, 145 * 2}, [3] = {18 * 2, 98 * 2},},	 
		["honglong"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {250, 190}, [1] = {25 * 2, 75 * 2}, [2] = {15 * 2, 210 * 2}, [3] = {0 * 2, 20 * 2},},
		["dixiachengzhihuiguan"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {250, 190}, [1] = {25 * 2, 75 * 2}, [2] = {15 * 2, 210 * 2}, [3] = {0 * 2, 20 * 2},},
		["dixiachengzhihuiguanpifu"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {250, 190}, [1] = {25 * 2, 75 * 2}, [2] = {15 * 2, 210 * 2}, [3] = {0 * 2, 20 * 2},},
		-- 8 --

		["dufengcao"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {150, 150}, [1] = {10 * 2, 60 * 2}, [2] = {5 * 2, 145 * 2}, [3] = {18 * 2, 98 * 2},},
		["dufeng"] = {["scale"] = 0.45, ["R"] = 30,
			[0] = {75, 75}, [1] = {10 * 2, 60 * 2}, [2] = {5 * 2, 145 * 2}, [3] = {18 * 2, 98 * 2},},

		-- 9 --
		["jingshenyuansu"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 40,
			[0] = {150, 180}, [1] = {6 * 2, 35 * 2}, [2] = {10 * 2, 130 * 2}, [3] = {20 * 2, 60 * 2},},	
		["fenghuang"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 80,
			[0] = {270, 309}, [1] = {19 * 2, 137 * 2}, [2] = {42 * 2, 235 * 2}, [3] = {170 * 2, 140 * 2},},	
		["fenghuangjuexing"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 80,
			[0] = {270, 309}, [1] = {19 * 2, 137 * 2}, [2] = {42 * 2, 235 * 2}, [3] = {170 * 2, 140 * 2},},
		["wuqifenghuang"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 80,
			[0] = {270, 309}, [1] = {19 * 2, 137 * 2}, [2] = {42 * 2, 235 * 2}, [3] = {170 * 2, 140 * 2},},	
		["jingshenyuansushengji"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 40,
			[0] = {150, 180}, [1] = {6 * 2, 35 * 2}, [2] = {10 * 2, 130 * 2}, [3] = {20 * 2, 60 * 2},},	
		["jingshenyuansujuexing"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 40,
			[0] = {150, 180}, [1] = {15 * 2, 60 * 2}, [2] = {30 * 2, 160 * 2}, [3] = {20 * 2, 60 * 2},},	
		-- 10 --
        ["longgui"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 80,
			[0] = {280, 200}, [1] = {19 * 2, 90 * 2}, [2] = {20 * 2, 170 * 2}, [3] = {170 * 2, 140 * 2},},	
		["meirenyu"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 80,
			[0] = {270, 309}, [1] = {19 * 2, 137 * 2}, [2] = {42 * 2, 235 * 2}, [3] = {170 * 2, 140 * 2},},	
		["haihou"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 80,
			[0] = {270, 280}, [1] = {10 * 2, 100 * 2}, [2] = {13 * 2, 200 * 2}, [3] = {170 * 2, 140 * 2},},	
		["haihoupifu"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 80,
			[0] = {270, 280}, [1] = {10 * 2, 100 * 2}, [2] = {13 * 2, 200 * 2}, [3] = {170 * 2, 140 * 2},},
		["ruigenanushou"] = {["scale"] = 0.45, ["R"] = 65,
			[0] = {150, 150}, [1] = {10 * 2, 60 * 2}, [2] = {5 * 2, 145 * 2}, [3] = {18 * 2, 98 * 2},},	 
		["haiguai"] = {["dieShadow"] = true,["scale"] = 0.6, ["R"] = 80,
			[0] = {480, 320}, [1] = {19 * 2, 120 * 2}, [2] = {20 * 2, 280 * 2}, [3] = {170 * 2, 180 * 2},},

			
		-- BOSS --
		["dulong"] = 
		{
			["scale"] = 1.0, ["R"] = 180,
			[0] = {390 * 2, 260 * 2}, [1] = {-3 * 2, 94 * 2}, [2] = {130 * 2, 210 * 2}, [3] = {-3 * 2, 94 * 2},
		},	
		["shuijinglong"] = 
		{
			["scale"] = 1.0, ["R"] = 180,
			[0] = {390 * 2, 200 * 2}, [1] = {20 * 2, 94 * 2}, [2] = {130 * 2, 180 * 2}, [3] = {-3 * 2, 94 * 2},
		},	
		["xiannvlong"] = 
		{
			["scale"] = 1.0, ["R"] = 180,
			[0] = {310 * 2, 282 * 2}, [1] = {31 * 2, 112 * 2}, [2] = {110 * 2, 238 * 2}, [3] = {131 * 2, 114 * 2},
		},	
		["shenglongboss"] = 
		{
			["scale"] = 1.0, ["R"] = 180,
			[0] = {390 * 2, 260 * 2}, [1] = {-3 * 2, 94 * 2}, [2] = {130 * 2, 210 * 2}, [3] = {230 * 2, 100 * 2},
		},	
		-- 阴森墓穴
		["baozhajiangshi"] = 	
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {55 * 2, 48 * 2}, [1] = {4 * 2, 38 * 2}, [2] = {4 * 2, 85 * 2}, [3] = {4 * 2, 38 * 2},
		},	
		-- 宝物
		["longwang"] = {["scale"] = 0.5, ["R"] = 65,
			[0] = {387, 240}, [1] = {31 * 2, 141 * 2}, [2] = {110 * 2, 200 * 2}, [3] = {31 * 2, 141 * 2},
		},	
		["shenglong"] = {["scale"] = 0.5, ["R"] = 80,
			[0] = {368, 260}, [1] = {24 * 2, 155 * 2}, [2] = {110 * 2, 216 * 2}, [3] = {205 * 2, 58 * 2},},	
		["shenglongwang"] = {["scale"] = 0.5, ["R"] = 80,
			[0] = {368, 260}, [1] = {24 * 2, 155 * 2}, [2] = {110 * 2, 216 * 2}, [3] = {205 * 2, 58 * 2},},
		["yuansuzhizi"] = {["scale"] = 0.5, ["R"] = 80,
			[0] = {160, 180}, [1] = {24* 2, 60 * 2}, [2] = {30 * 2, 160 * 2}, [3] = {80 * 2, 70 * 2},},	
		["chitianshi"] = {["scale"] = 0.5, ["R"] = 80,
			[0] = {160, 180}, [1] = {20* 2, 60 * 2}, [2] = {20 * 2, 170 * 2}, [3] = {80 * 2, 70 * 2},},							


		-- 云中城
		["ccmofata"] = 
		{
			["scale"] = 0.5, ["R"] = 50,
			[0] = {129, 143}, [1] = {0 * 2, 57 * 2}, [2] = {0 * 2, 152 * 2}, [3] = {0 * 2, 57 * 2},
		},
		["ccshidun"] = 
		{
			["scale"] = 0.5, ["R"] = 50,
			[0] = {80, 147}, [1] = {0 * 2, 80 * 2}, [2] = {0 * 2, 152 * 2}, [3] = {0 * 2, 80 * 2},
		},
		["ccshizhu"] = 
		{
			["scale"] = 0.5, ["R"] = 50,
			[0] = {82, 146}, [1] = {0 * 2, 80 * 2}, [2] = {0 * 2, 152 * 2}, [3] = {0 * 2, 80 * 2},
		},
		["cczhangpeng"] = 
		{
			["scale"] = 0.4, ["R"] = 30,
			[0] = {105, 84}, [1] = {0 * 2, 50 * 2}, [2] = {0 * 2, 120 * 2}, [3] = {0 * 2, 50 * 2},
		},
		["cczhaohuan"] = 
		{
			["scale"] = 0.4, ["R"] = 30,
			[0] = {105, 84}, [1] = {0 * 2, 50 * 2}, [2] = {0 * 2, 120 * 2}, [3] = {0 * 2, 50 * 2},
		},
		["ccjinmota"] = 
		{
			["scale"] = 0.5, ["R"] = 50,
			[0] = {129, 143}, [1] = {0 * 2, 57 * 2}, [2] = {0 * 2, 152 * 2}, [3] = {0 * 2, 57 * 2},
		},
		-- 1-2 石头人 --
		-- 联盟地图BOSS
		["shijuren"] = 
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 200}, [1] = {0 * 2, 78 * 2}, [2] = {42 * 2, 165 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["bingjuren"] = 
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 200}, [1] = {0 * 2, 78 * 2}, [2] = {42 * 2, 165 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["huojuren"] = 
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 200}, [1] = {0 * 2, 78 * 2}, [2] = {42 * 2, 165 * 2}, [3] = {90 * 2, 229 * 2},
		},

		-- 元素位面
		["huonan"] =  
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 285}, [1] = {11 * 2, 135 * 2}, [2] = {14 * 2, 210 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["huonv"] =  
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 285}, [1] = {21 * 2, 147 * 2}, [2] = {27 * 2, 261 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["bingnv"] =  
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 285}, [1] = {-40 * 2, 140 * 2}, [2] = {27 * 2, 261 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["diannan"] =  
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 285}, [1] = {34 * 2, 115 * 2}, [2] = {63 * 2, 237 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["pangshitou"] =  
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 285}, [1] = {34 * 2, 160 * 2}, [2] = {15 * 2, 245 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["shoushitou"] =  
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 285}, [1] = {-4 * 2, 190 * 2}, [2] = {12 * 2, 278 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["hunluanyuansu"] =  
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 285}, [1] = {10 * 2, 100 * 2}, [2] = {4 * 2, 261 * 2}, [3] = {90 * 2, 229 * 2},
		},
		-- 攻城器械
		["chongche"] = 
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 200}, [1] = {0 * 2, 78 * 2}, [2] = {42 * 2, 165 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["tiepiche"] = 
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 200}, [1] = {0 * 2, 78 * 2}, [2] = {42 * 2, 165 * 2}, [3] = {90 * 2, 229 * 2},
		},
		["dongxuefeilong"] = 
		{
			["scale"] = 0.5, ["R"] = 65,
			[0] = {300, 200}, [1] = {20 * 2, 120 * 2}, [2] = {70 * 2, 220 * 2}, [3] = {110 * 2, 130 * 2},
		},
	},

}
return AnimAp