--[[
    Filename:    GuideStoryConfig.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-01-15 19:23:07
    Description: File description
--]]
-- pingdan
-- jingya
-- weixiao
-- xingfen
-- zhiyin
local guideStoryConfig = {
	[1101] = {	-- 第一章，岸上醒来
		{	
			talk = "JUQING_001",
			sound = "g1",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1102] = {
		{	
			talk = "JUQING_002",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Knight.png", -- 立汇名字
            anchor = {0.,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10040",  -- 骑士
            namePos = {135,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[1103] = {
		{	
			talk = "JUQING_003",
			sound = "g3",	
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1104] = {
		{	
			talk = "JUQING_004",
			roleImg = "xingfen",
			sound = "g4",	
			side = 2   -- 1 or 2
		},
	},
	[1105] = {
		{	
			talk = "JUQING_005",
			sound = "g5",	
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1106] = {
		{	
			talk = "JUQING_006",
			roleImg = "pingdan",
			sound = "g6",	
			side = 2   -- 1 or 2
		},
	},
	[1107] = {	
		{	
			talk = "JUQING_007",
			sound = "g7",	
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1108] = {
		{	
			talk = "JUQING_075",
			roleImg = "weixiao",
			sound = "g8",	
			side = 2   -- 1 or 2
		},	
	},
	[1111] = {	
		{	
			talk = "JUQING_094",
			roleImg = "weixiao",
			sound = "g9",	
			side = 2   -- 1 or 2
		},	
	},
	[1109] = {
		{	
			talk = "JUQING_076",
			sound = "g10",	
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1110] = {	
		{	
			talk = "JUQING_077",
			roleImg = "zhiyin",	
			sound = "g11",
			side = 2   -- 1 or 2
		},			
	},
	[2] = {	-- 关卡1-1结束，获得弩兵
		{	
			talk = "JUQING_010",
			roleImg = "weixiao",
			sound ="g19",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "JUQING_011",
			sound ="g20",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3] = {	-- 关卡1-2开始，攻城战前
		{	
			talk = "JUQING_010",
			roleImg = "weixiao",
			sound ="g19",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "JUQING_011",
			sound ="g20",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[4] = {	-- 关卡1-2结束，进入主城
		{	
			talk = "JUQING_012",
			sound ="g31",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_013",
			roleImg = "weixiao",
			sound ="g32",			
			side = 2   -- 1 or 2
		},
	},
	[5] = {	-- 1-5关卡之前剧情
		{	
			talk = "JUQING_014",
			roleImg = "weixiao",
			sound = "g58",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "JUQING_015",
			sound = "g59",				
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{
			talk = "JUQING_016",
			roleImg = "pingdan",
			sound = "g60",			
			side = 2   -- 1 or 2
		},
	},
	[6] = {	-- 1-5战斗结束
		{	
			talk = "JUQING_017",
			roleImg = "weixiao",
			sound = "g64",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "JUQING_018",
			sound = "g65",		
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_019",
			roleImg = "pingdan",
			sound = "g66",		
			side = 2   -- 1 or 2
		},

	},
	[8] = {	-- 进入第二章节
		{	
			talk = "JUQING_023",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[9] = {	-- 支线开启新技能
		{	
			talk = "JUQING_024",
			roleImg = "xingfen",
			sound = "g96",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "JUQING_025",
			sound = "g97",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[10] = {	-- 获得魔法卷轴
		{	
			talk = "JUQING_026",
			sound = "g105",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[11] = {	-- 2-6结束，强调骑兵突击
		{	
			talk = "JUQING_027",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "JUQING_028",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_029",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
	},
	[12] = {	-- 1-1 开场
		{	
			talk = "XINSHOUZHANDOU_01",
			roleImg = "weixiao",
            sound = "g16",		
			side = 2   -- 1 or 2
		},
	},
	[13] = {	-- 1-1战中
		{	
			talk = "XINSHOUZHANDOU_03",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
	},
--	[14] = {	-- 1-5前往第二张 不许改序号
--		{	
--			talk = "JUQING_020",
--			roleImg = "weixiao",			
--			side = 2   -- 1 or 2
--		},
--		{	
--			talk = "JUQING_021",
--			roleImg = "guideImage_leftRole.png",			
--			side = 1   -- 1 or 2
--		},
--		{	
--			talk = "JUQING_022",
--			roleImg = "xingfen",			
--			side = 2   -- 1 or 2
--		},
--	},
	[1201] = {	--岛上起航
		{	
			talk = "JUQING_020",
			roleImg = "weixiao",
			sound ="g82",			
			side = 2   -- 1 or 2
		},
	},
	[1202] = {	
		{	
			talk = "JUQING_021",
			sound ="g83",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1203] = {	
		{	
			talk = "JUQING_022",
			roleImg = "xingfen",
			sound ="g84",			
			side = 2   -- 1 or 2
		},
	},
	[1204] = {	
		{	
			talk = "JUQING_078",
			sound ="g85",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1301] = {	--解放狮鹫崖
		{	
			talk = "JUQING_079",
			roleImg = "xingfen",			
			side = 2   -- 1 or 2
		},
	},
	[1302] = {	
		{	
			talk = "JUQING_080",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1303] = {	
		{	
			talk = "JUQING_081",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
	},
	[1304] = {	
		{	
			talk = "JUQING_082",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1305] = {	
		{	
			talk = "JUQING_083",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Knight.png", -- 立汇名字
            anchor = {0.,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10040",  -- 骑士
            namePos = {135,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[1401] = {	--恶魔碰面
		{	
			talk = "JUQING_084",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[1402] = {	
		{	
			talk = "JUQING_085",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[1403] = {	
		{	
			talk = "JUQING_086",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[1404] = {	
		{	
			talk = "JUQING_087",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[1405] = {	
		{	
			talk = "JUQING_088",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[1501] = {	--恶魔制造第二个火山
		{	
			talk = "JUQING_089",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[1502] = {	
		{	
			talk = "JUQING_090",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[1503] = {	
		{	
			talk = "JUQING_091",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[1504] = {	
		{	
			talk = "JUQING_092",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[1505] = {	
		{	
			talk = "JUQING_093",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[1601] = {	-- 第9章的剧情动画1
		{	
			talk = "JUQING_1601",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_1602",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shourenzhanshi.png", -- 立汇名字
            anchor = {-0.25,0.27}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10013",  -- 地精战士
            namePos = {398,490},       -- 名字的位置，需要调整
            textOffset = {-5,0}
		},
		{	
			talk = "JUQING_1603",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_1604",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shourenzhanshi.png", -- 立汇名字
            anchor = {-0.25,0.27}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10013",  -- 地精战士
            namePos = {398,490},       -- 名字的位置，需要调整
            textOffset = {-5,0}
		},
	},
	[1602] = {	-- 第9章的剧情动画2
		{	
			talk = "JUQING_1605",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_1606",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shourenzhanshi.png", -- 立汇名字
            anchor = {-0.25,0.27}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10013",  -- 地精战士
            namePos = {398,490},       -- 名字的位置，需要调整
            textOffset = {-5,0}
		},
	},
	[1701] = {	-- 第12章的剧情动画1
		{	
			talk = "JUQING_1701",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_1702",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shourenzhanshi.png", -- 立汇名字
            anchor = {-0.25,0.27}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10013",  -- 地精战士
            namePos = {398,490},       -- 名字的位置，需要调整
            textOffset = {-5,0}
		},
		{	
			talk = "JUQING_1703",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_1704",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shourenzhanshi.png", -- 立汇名字
            anchor = {-0.25,0.27}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10013",  -- 地精战士
            namePos = {398,490},       -- 名字的位置，需要调整
            textOffset = {-5,0}
		},
	},
	[1702] = {	-- 第12章的剧情动画2
		{	
			talk = "JUQING_1705",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1801] = {	-- 第13章的剧情动画1
		{	
			talk = "JUQING_1801",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1802] = {	-- 第13章的剧情动画2
		{	
			talk = "JUQING_1802",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[1803] = {	-- 第13章的剧情动画3
		{	
			talk = "JUQING_1803",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[1804] = {	-- 第13章的剧情动画4
		{	
			talk = "JUQING_1804",
			roleImg = "xingfen",			
			side = 2   -- 1 or 2
		},
	},
	[1901] = {	-- 第15章的剧情动画1
		{	
			talk = "JUQING_1901",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_taitan.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10053", 	-- 泰坦
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[1902] = {	-- 第15章的剧情动画2
		{	
			talk = "JUQING_1902",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[1903] = {	-- 第15章的剧情动画3
		{	
			talk = "JUQING_1903",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_taitan.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10053", 	-- 泰坦
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[11001] = {	-- 第16章的剧情动画1
		{	
			talk = "JUQING_2001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {120,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "JUQING_2003",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {120,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2004",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[11002] = {	-- 第16章的剧情动画2
		{	
			talk = "JUQING_2005",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {120,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[11101] = {	-- 第18章的剧情动画1
		{	
			talk = "JUQING_2101",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "JUQING_2102",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {120,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[11102] = {	-- 第18章的剧情动画2
		{	
			talk = "JUQING_2103",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "JUQING_2104",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "JUQING_2105",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[11201] = {	-- 第19章的剧情动画1
		{	
			talk = "JUQING_2201",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "JUQING_2202",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "JUQING_2203",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "JUQING_2204",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[11301] = {	-- 第22章的剧情动画1
		{	
			talk = "JUQING_2301",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "JUQING_2302",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kilgor.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10024", 	-- 科尔格
            namePos = {160,180}      	-- 名字的位置，需要调整
		},
		{	
			talk = "JUQING_2303",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Boragus.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10046",  -- 伯拉格公爵
            namePos = {190,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2304",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "JUQING_2305",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Boragus.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10046",  -- 伯拉格公爵
            namePos = {190,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2306",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Boragus.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10046",  -- 伯拉格公爵
            namePos = {190,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[11401] = {	-- 第21章的剧情动画1
		{	
			talk = "JUQING_2401",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "JUQING_2402",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10011", 	-- 德肯母亲
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "JUQING_2403",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "JUQING_2404",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10011", 	-- 德肯母亲
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "JUQING_2405",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[11501] = {	-- 第21章的剧情动画1
		{	
			talk = "JUQING_2501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "JUQING_2502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_FaerieDragon.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10058", 	-- 仙女龙
            namePos = {160,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "JUQING_2504",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_FaerieDragon.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10058", 	-- 仙女龙
            namePos = {160,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2505",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_FaerieDragon.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10058", 	-- 仙女龙
            namePos = {160,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2506",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[11601] = {	-- 第25章的剧情动画1
		{	
			talk = "JUQING_2601",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10073", 	-- 萨费罗斯
            namePos = {155,190},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2602",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "JUQING_2603",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10073", 	-- 萨费罗斯
            namePos = {155,190},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "JUQING_2604",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
	},
	[11701] = {	-- 第25章的剧情动画1
		{	
			talk = "JUQING_2701",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "JUQING_2702",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
	},
	[11702] = {	-- 第25章的剧情动画1
		{	
			talk = "JUQING_2703",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
	},
	[11801] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2801",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kendel.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10063", 	-- 肯达尔
            namePos = {70,180},       -- 名字的位置，需要调整
            textOffset = {20,0}
		},
	},
	[11802] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2802",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[11803] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2803",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            flip = 1,
            anchor = {0.,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {110,180},       -- 名字的位置，需要调整
            textOffset = {20,0}
		},
	},
	[11804] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2804",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[11805] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2805",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kendel.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10063", 	-- 肯达尔
            namePos = {70,180},       -- 名字的位置，需要调整
            textOffset = {20,0}
		},
	},
	[11806] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2806",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[11807] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2807",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kendel.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10063", 	-- 肯达尔
            namePos = {70,180},       -- 名字的位置，需要调整
            textOffset = {20,0}
		},
	},
	[11901] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2901",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[11902] = {	-- 第28章的剧情动画1
        {     
            talk = "JUQING_2902",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Roland_01.png", -- 立汇名字
            flip = 1,
            anchor = {-0.15,0},   -- 锚点 调整立汇位置
            zoom = 0.8,         -- 缩放
            name = "Name_10032",  -- 罗兰德
            namePos = {155,220}       -- 名字的位置，需要调整
        },
	},
	[11903] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2903",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[11904] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2904",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Roland_01.png", -- 立汇名字
            flip = 1,
            anchor = {-0.15,0},   -- 锚点 调整立汇位置
            zoom = 0.8,         -- 缩放
            name = "Name_10032",  -- 罗兰德
            namePos = {155,220}       -- 名字的位置，需要调整
        },
	},
	[11905] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2905",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[11906] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2906",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Roland_01.png", -- 立汇名字
            flip = 1,
            anchor = {-0.15,0},   -- 锚点 调整立汇位置
            zoom = 0.8,         -- 缩放
            name = "Name_10032",  -- 罗兰德
            namePos = {155,220}       -- 名字的位置，需要调整
        },
	},
	[11907] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2907",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[11908] = {	-- 第28章的剧情动画1
		{	
			talk = "JUQING_2908",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Roland_01.png", -- 立汇名字
            flip = 1,
            anchor = {-0.15,0},   -- 锚点 调整立汇位置
            zoom = 0.8,         -- 缩放
            name = "Name_10032",  -- 罗兰德
            namePos = {155,220}       -- 名字的位置，需要调整
        },
	},
------------------------------------
	[15] = {	-- 2-1战斗后引导凤凰
		{	
			talk = "JUQING_020",
			roleImg = "xingfen",
			sound ="g82",			
			side = 1   -- 1 or 2
		},
		{	
			talk = "ZHANDOU_21",
			sound ="g83",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_022",
			roleImg = "xingfen",
			sound ="g84",			
			side = 2   -- 1 or 2
		},
	},
	[16] = {	-- 2-5战中
		{	
			talk = "JUQING_030",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[17] = {	-- 1-4
		{	
			talk = "JUQING_044",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[18] = {	-- 
		{	
			talk = "GUIDE_GUILD_1",
			roleImg = "xingfen",			
			side = 2   -- 1 or 2
		},
	},
	[19] = {	-- 
		{	
			talk = "GUIDE_GUILD_2",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_3",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "GUIDE_GUILD_4",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
	},
	[20] = {	-- 
		{	
			talk = "GUIDE_GUILD_5",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[21] = {	-- 
		{	
			talk = "GUIDE_GUILD_6",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},
	},
	[22] = {	-- 
		{	
			talk = "GUIDE_GUILD_1",
			roleImg = "weixiao",			
			side = 1   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_2",
			roleImg = "pingdan",			
			side = 1   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_3",
			roleImg = "xingfen",			
			side = 1   -- 1 or 2
		},
	},
	[24] = {	-- 
		{	
			talk = "JUQING_047",
			roleImg = "weixiao",			
			side = 1   -- 1 or 2
		},
		{	
			talk = "JUQING_048",
			roleImg = "pingdan",			
			side = 1   -- 1 or 2
		},
		{	
			talk = "JUQING_049",
			roleImg = "xingfen",			
			side = 1   -- 1 or 2
		},
	},
	[25] = {	-- 
		{	
			talk = "JUQING_051",
			roleImg = "weixiao",			
			side = 1   -- 1 or 2
		},
	},
	[26] = {	-- 引导英雄升星
		{	
			talk = "JUQING_045",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_046",
			roleImg = "xingfen",			
			side = 2   -- 1 or 2
		},
	},
	[27] = {	-- 凤凰说明
		{	
			talk = "JUQING_052",
			roleImg = "weixiao",			
			side = 1   -- 1 or 2
		},
	},
	[28] = {	-- 特权开启
		{	
			talk = "JUQING_053",
			roleImg = "weixiao",
			sound ="g113",			
			side = 1   -- 1 or 2
		},
	},
	[29] = {	-- 305失败引导
		{	
			talk = "JUQING_054",
			roleImg = "weixiao",			
			side = 1   -- 1 or 2
		},
	},
	[30] = {	-- 引导积分联赛
		{	
			talk = "JUQING_055",
			roleImg = "weixiao",			
			side = 1   -- 1 or 2
		},
		{	
			talk = "JUQING_095",
			roleImg = "weixiao",			
			side = 1   -- 1 or 2
		},
	},
	[31] = {	-- 引导积分联赛
		{	
			talk = "JUQING_056",
			roleImg = "pingdan",			
			side = 1   -- 1 or 2
		},
		{	
			talk = "JUQING_057",
			roleImg = "xingfen",			
			side = 1   -- 1 or 2
		},
		{	
			talk = "JUQING_058",
			roleImg = "weixiao",			
			side = 1   -- 1 or 2
		},
	},
	[32] = {	-- 引导积分联赛
		{	
			talk = "JUQING_059",
			roleImg = "xingfen",			
			side = 1   -- 1 or 2
		},
	},
	[33] = {	-- 引导积分联赛
		{	
			talk = "JUQING_059",
			roleImg = "xingfen",			
			side = 1   -- 1 or 2
		},
	},
	[120] = {	--1-2助战	
		{	
			talk = "JUQING_061",
			roleImg = "pingdan",		
			side = 1   -- 1 or 2
		},	
	},
	[34] = {	--1-2助战	
		{	
			talk = "JUQING_062",
			roleImg = "jingya",	
			sound = "g22",		
			side = 1   -- 1 or 2
		},
		{	
			talk = "JUQING_063",
			sound = "g23",					
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[35] = {	--1-2助战
		{	
			talk = "JUQING_071",
			roleImg = "xingfen",
			sound = "g24",		
			side = 1   -- 1 or 2
		},	
		{	
			talk = "JUQING_064",
			roleImg = "xingfen",
			sound = "g25",			
			side = 2   -- 1 or 2
		},
	},
	[36] = {	--1-2助战
		{	
			talk = "JUQING_072",
			sound = "g26",		
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_065",
			sound = "g27",			
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "JUQING_066",
			sound = "g28",		
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[37] = {	--1-2助战	
		{	
			talk = "JUQING_067",
			sound = "g29",		
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_073",
			sound = "g30",			
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "JUQING_074",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[38] = {	--训练场
		{	
			talk = "JUQING_068",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
	},
	[39] = {	--训练场
		{	
			talk = "JUQING_069",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
		{	
			talk = "JUQING_070",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
	},
	[40] = {	--传奇段位
		{	
			talk = "XINSHOU_91",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
	},
	[41] = {	--联盟探索出传送门
		{	
			talk = "GUIDE_GUILD_9",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
	},
	[42] = {	--联盟探索出传送门
		{	
			talk = "GUIDE_GUILD_10",
			roleImg = "pingdan",		
			side = 2   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_11",
			roleImg = "pingdan",		
			side = 2   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_12",
			roleImg = "pingdan",		
			side = 2   -- 1 or 2
		},

	},
	[43] = {	--联盟秘境引导
		{	
			talk = "GUIDE_GUILD_13",
			roleImg = "xingfen",		
			side = 1   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_14",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
	},
	[44] = {	--王国联赛引导
		{	
			talk = "GUIDE_GUILD_15",
			roleImg = "xingfen",		
			side = 1   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_16",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
	},
	[45] = {	--魔法天赋引导
		{	
			talk = "GUIDE_GUILD_17",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_18",
			roleImg = "xingfen",		
			side = 1   -- 1 or 2
		},
	},
	[46] = {	--无尽炼狱引导
		{	
			talk = "GUIDE_GUILD_19",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
		{	
			talk = "GUIDE_GUILD_20",
			roleImg = "xingfen",		
			side = 1   -- 1 or 2
		},
	},
	[47] = {	--圣徽商店引导
		{	
			talk = "XINSHOU_120",
			roleImg = "weixiao",		
			side = 1   -- 1 or 2
		},
	},
	[48] = {	--圣徽仓库引导
		{	
			talk = "XINSHOU_122",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
	},
	[49] = {	--圣徽套装引导
		{	
			talk = "XINSHOU_124",
			roleImg = "zhiyin",		
			side = 1   -- 1 or 2
		},
	},
	[50] = {	--圣徽分解引导
		{	
			talk = "XINSHOU_125",
			roleImg = "xingfen",		
			side = 2   -- 1 or 2
		},
	},
	[51] = {	--圣徽镶嵌引导
		{	
			talk = "XINSHOU_119",
			roleImg = "zhiyin",		
			side = 2   -- 1 or 2
		},
	},
    [52] = {	--军需官对话
		{	
			talk = "JUNXUGUAN_001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Junxuguan.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10085",  -- 瑞斯卡
            namePos = {50,185},       -- 名字的位置，需要调整
            textOffset = {60,0}
		},
        {	
			talk = "JUNXUGUAN_002",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Junxuguan.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10085",  -- 瑞斯卡
            namePos = {50,185},       -- 名字的位置，需要调整
            textOffset = {60,0}
		},
	},
	[53] = {	--星图引导
		{	
			talk = "XINSHOU_126",
			roleImg = "zhiyin",		
			side = 1   -- 1 or 2
		},
	},
	[54] = {	--星图引导
		{	
			talk = "XINSHOU_127",
			roleImg = "zhiyin",		
			side = 2   -- 1 or 2
		},
	},
	[55] = {	--星图引导
		{	
			talk = "XINSHOU_128",
			roleImg = "zhiyin",		
			side = 1   -- 1 or 2
		},
	},
	[56] = {	--星图引导
		{	
			talk = "XINSHOU_129",
			roleImg = "zhiyin",		
			side = 2   -- 1 or 2
		},
	},
-------------------------------------------
	[1004] = {	--演示战斗
		{	
			talk = "ZHANDOU_29",
			sound ="ZHANDOU_29",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kendel.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10063", 	-- 肯达尔
            namePos = {280,180},      	-- 名字的位置，需要调整
            textOffset = {220,0}
		},
	},
	[1005] = {	--演示战斗
		{	
			talk = "ZHANDOU_32",
			sound ="ZHANDOU_32",			
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},		
		{	
			talk = "ZHANDOU_33",
			sound ="ZHANDOU_33",		
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kendel.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10063", 	-- 肯达尔
            namePos = {280,180},      	-- 名字的位置，需要调整
            textOffset = {220,0}
		},
	},
	[1006] = {	--演示战斗
		{	
			talk = "ZHANDOU_34",
			sound ="ZHANDOU_34",	
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},		
	},
	[1007] = {	--演示战斗
		{	
			talk = "ZHANDOU_35",
			sound ="ZHANDOU_35",		
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kendel.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10063", 	-- 肯达尔
            namePos = {280,180},      	-- 名字的位置，需要调整
            textOffset = {220,0}
		},	
	},
	[1008] = {	--演示战斗	
		{	
			talk = "ZHANDOU_36",
			sound ="ZHANDOU_36",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kendel.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10063", 	-- 肯达尔
            namePos = {280,180},      	-- 名字的位置，需要调整
            textOffset = {220,0}
		},	
	},
	[1009] = {	--演示战斗	
		{	
			talk = "ZHANDOU_37",
			sound ="ZHANDOU_37",			
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},		
	},
	[1010] = {	--演示战斗	
		{	
			talk = "ZHANDOU_41",
			sound ="ZHANDOU_41",		
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},		
		{	
			talk = "ZHANDOU_42",
			sound ="ZHANDOU_42",		
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kendel.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10063", 	-- 肯达尔
            namePos = {280,180},      	-- 名字的位置，需要调整
            textOffset = {220,0}
		},	
	},	
	[105] = {	-- 己方骑兵战斗
		{	
			talk = "ZHANDOU_15",
			sound = "g15",			
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},	
	[106] = {	-- 2-2战斗
		{	
			talk = "ZHANDOU_18",
			sound = "g109",				
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[107] = {	-- 2-2战斗
		{	
			talk = "ZHANDOU_19",
			sound = "110",				
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},	
	[110] = {	-- 敌方骑兵
		{	
			talk = "ZHANDOU_20",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "ZHANDOU_21",	
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},	
	[111] = {	-- 协助1
		{	
			talk = "ZHANDOU_20",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "ZHANDOU_21",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "ZHANDOU_20",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "ZHANDOU_21",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},	
	[112] = {	-- 协助2
		{	
			talk = "ZHANDOU_20",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "ZHANDOU_21",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "ZHANDOU_20",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "ZHANDOU_21",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},	
	[113] = {	-- 第一次战斗失败
		{	
			talk = "JUQING_031",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_032",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
	},	
	[114] = {	-- 引导战斗剧情1
		{	
			talk = "ZHANDOU_1",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[115] = {	--1-2助战
		{	
			talk = "JUQING_034",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[116] = {	--1-2助战
		{	
			talk = "JUQING_035",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "JUQING_036",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi.png", -- 立汇名字
            flip = 1,
            anchor = {1.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10008", 	-- 大天使
            namePos = {750,470},      	-- 名字的位置，需要调整
            textOffset = {-70,0}
		},	
		{	
			talk = "JUQING_037",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[117] = {	--召唤骷髅
		{	
			talk = "JUQING_038",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_daemo.png", -- 立汇名字
            flip =1,
            anchor = {-0.37,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.65,        	 -- 缩放
            name = "Name_10006", 	-- 大恶魔
            namePos = {260,540},      	-- 名字的位置，需要调整
            textOffset = {50,0}
		},
	},
	[118] = {	--末日审判	
		{	
			talk = "JUQING_039",	
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_daemo.png", -- 立汇名字
            flip =1,
            anchor = {-0.37,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.65,        	 -- 缩放
            name = "Name_10006", 	-- 大恶魔
            namePos = {260,540},      	-- 名字的位置，需要调整
            textOffset = {50,0}
		},
	},
	[119] = {	--大天使主站	
		{	
			talk = "JUQING_040",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi.png", -- 立汇名字
            flip = 1,
            anchor = {1.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10008", 	-- 大天使
            namePos = {750,470},      	-- 名字的位置，需要调整
            textOffset = {-70,0}
		},
	},

	[121] = {	--4-15助战	
		{	
			talk = "zhuzhan_7100401",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_daemo.png", -- 立汇名字
            flip =1,
            anchor = {-0.37,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.65,        	 -- 缩放
            name = "Name_10006", 	-- 大恶魔
            namePos = {260,540},      	-- 名字的位置，需要调整
            textOffset = {50,0}
		},
		{	
			talk = "zhuzhan_7100402",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "zhuzhan_7100403",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_daemo.png", -- 立汇名字
            flip =1,
            anchor = {-0.37,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.65,        	 -- 缩放
            name = "Name_10006", 	-- 大恶魔
            namePos = {260,540},      	-- 名字的位置，需要调整
            textOffset = {50,0}
		},
		{	
			talk = "zhuzhan_7100404",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi.png", -- 立汇名字
            flip = 1,
            anchor = {1.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10008", 	-- 大天使
            namePos = {750,470},      	-- 名字的位置，需要调整
            textOffset = {-70,0}
		},	
	},
	[221] = {	--4-15逃跑	
		{	
			talk = "taopao_710041501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},		
	},	
	[122] = {	--9-15助战	
		{	
			talk = "zhuzhan_7100901",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "zhuzhan_7100902",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "zhuzhan_7100903",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi.png", -- 立汇名字
            flip = 1,
            anchor = {1.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10008", 	-- 大天使
            namePos = {750,470},      	-- 名字的位置，需要调整
            textOffset = {-70,0}
		},	
	},
	[123] = {	--9-11助战	
		{	
			talk = "zhuzhan_7100904",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[124] = {	--第7章支线巫妖助战	
		{	
			talk = "zhuzhan_7100906",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "zhuzhan_7100907",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi.png", -- 立汇名字
            flip = 1,
            anchor = {1.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10008", 	-- 大天使
            namePos = {750,470},      	-- 名字的位置，需要调整
            textOffset = {-70,0}
		},	
	},
	[125] = {	--第21章吉恩助战	
		{	
			talk = "zhuzhan_7100908",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            anchor = {1.28,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10007", 	-- 达芙妮
            namePos = {730,475},      	-- 名字的位置，需要调整
            textOffset = {-280,0}
		},
		{	
			talk = "zhuzhan_7100909",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10023", 	-- 加吉恩
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "zhuzhan_7100910",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            anchor = {1.28,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10007", 	-- 达芙妮
            namePos = {730,475},      	-- 名字的位置，需要调整
            textOffset = {-280,0}
		},
		{	
			talk = "zhuzhan_7100911",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10023", 	-- 加吉恩
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "zhuzhan_7100912",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            anchor = {1.28,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10007", 	-- 达芙妮
            namePos = {730,475},      	-- 名字的位置，需要调整
            textOffset = {-280,0}
		},
		{	
			talk = "zhuzhan_7100913",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10023", 	-- 加吉恩
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "zhuzhan_7100914",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10023", 	-- 加吉恩
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "zhuzhan_7100915",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            anchor = {1.28,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10007", 	-- 达芙妮
            namePos = {730,475},      	-- 名字的位置，需要调整
            textOffset = {-280,0}
		},
		{	
			talk = "zhuzhan_7100916",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10023", 	-- 加吉恩
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "zhuzhan_7100917",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10023", 	-- 加吉恩
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "zhuzhan_7100918",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            anchor = {1.28,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10007", 	-- 达芙妮
            namePos = {730,475},      	-- 名字的位置，需要调整
            textOffset = {-280,0}
		},
	},
	[302] = {	--第2章剧情	
		{	
			talk = "sctiongchange_7100201",
			roleImg = "pingdan",
			sound = "g86",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "sctiongchange_7100202",
			sound = "g87",				
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7100203",
			roleImg = "pingdan",
			sound = "g88",				
			side = 2   -- 1 or 2
		},
	},
	[303] = {	--第3章剧情	
		{	
			talk = "sctiongchange_7100301",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "sctiongchange_7100302",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7100303",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
	},
	[304] = {	--第4章剧情	
		{	
			talk = "sctiongchange_7100401",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "sctiongchange_7100402",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7100403",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
	},
	[305] = {	--第5章剧情	
		{	
			talk = "sctiongchange_7100501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
		{	
			talk = "sctiongchange_7100502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "sctiongchange_7100503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[306] = {	--第6章剧情	
		{	
			talk = "sctiongchange_7100601",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
		{	
			talk = "sctiongchange_7100602",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "sctiongchange_7100603",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[307] = {	--第7章剧情	
		{	
			talk = "sctiongchange_7100701",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
		{	
			talk = "sctiongchange_7100702",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[308] = {	--第8章剧情	
		{	
			talk = "sctiongchange_7100801",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "sctiongchange_7100802",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
		{	
			talk = "sctiongchange_7100803",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[309] = {	--第9章剧情	
		{	
			talk = "sctiongchange_7100901",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7100902",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
		{	
			talk = "sctiongchange_7100903",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7100904",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[310] = {	--第10章剧情	
		{	
			talk = "sctiongchange_7101001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "sctiongchange_7101002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7101003",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[311] = {	--第11章剧情	
		{	
			talk = "sctiongchange_7101101",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7101102",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "sctiongchange_7101103",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[312] = {	--第12章剧情	
		{	
			talk = "sctiongchange_7101201",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "sctiongchange_7101202",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7101203",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[313] = {	--第13章剧情	
		{	
			talk = "sctiongchange_7101301",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "sctiongchange_7101302",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "sctiongchange_7101303",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[314] = {	--第14章剧情	
		{	
			talk = "sctiongchange_7101401",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "sctiongchange_7101402",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "sctiongchange_7101403",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[315] = {	--第15章剧情	
		{	
			talk = "sctiongchange_7101501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "sctiongchange_7101502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "sctiongchange_7101503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[316] = {	--第16章剧情	
		{	
			talk = "sctiongchange_7101601",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7101602",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "sctiongchange_7101603",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[317] = {	--第17章剧情	
		{	
			talk = "sctiongchange_7101701",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7101702",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "sctiongchange_7101703",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[318] = {	--第18章剧情	
		{	
			talk = "sctiongchange_7101801",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "sctiongchange_7101802",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "sctiongchange_7101803",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[319] = {	--第19章剧情	
		{	
			talk = "sctiongchange_7101901",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "sctiongchange_7101902",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "sctiongchange_7101903",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[320] = {	--第20章剧情	
		{	
			talk = "sctiongchange_7102001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "sctiongchange_7102002",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "sctiongchange_7102003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[321] = {	--第21章剧情	
		{	
			talk = "sctiongchange_7102101",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "sctiongchange_7102102",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "sctiongchange_7102103",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[322] = {	--第21章剧情	
		{	
			talk = "sctiongchange_7102201",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "sctiongchange_7102202",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "sctiongchange_7102203",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[323] = {	--第22章剧情	
		{	
			talk = "sctiongchange_7102301",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "sctiongchange_7102302",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "sctiongchange_7102303",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[324] = {	--第22章剧情	
		{	
			talk = "sctiongchange_7102401",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "sctiongchange_7102402",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "sctiongchange_7102403",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[325] = {	--第22章剧情	
		{	
			talk = "sctiongchange_7102501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "sctiongchange_7102502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "sctiongchange_7102503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[326] = {	--第22章剧情	
		{	
			talk = "sctiongchange_7102601",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10073", 	-- 萨费罗斯
            namePos = {155,190},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "sctiongchange_7102602",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "sctiongchange_7102603",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10073", 	-- 萨费罗斯
            namePos = {155,190},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[327] = {	--第22章剧情	
		{	
			talk = "sctiongchange_7102701",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10073", 	-- 萨费罗斯
            namePos = {155,190},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "sctiongchange_7102702",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "sctiongchange_7102703",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10073", 	-- 萨费罗斯
            namePos = {155,190},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[401] = {	--第二大章剧情	
		{	
			talk = "story_201",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	

	},
	[7100415] = {	--4-15开场剧情
		{	
			talk = "juqingduihua_710041501",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "juqingduihua_710041502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{
			talk = "juqingduihua_710041503",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7100505] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710050501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{
			talk = "herochange_710050502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{
			talk = "herochange_710050503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7100510] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710051001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710051002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710051003",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7100515] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710051501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710051502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710051503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7100605] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710060501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710060502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710060503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7100610] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710061001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710061002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710061003",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7100615] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710061501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710061502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710061503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7100705] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710070501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710070502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710070503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7100710] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710071001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710071002",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710071003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7100715] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710071501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710071502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710071503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7100805] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710080501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710080502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710080503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7100810] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710081001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710081002",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710081003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7100815] = {	--第5章15关剧情英雄	
		{	
			talk = "herochange_710081501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710081502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10039",  -- 瑞斯卡
            namePos = {300,168},       -- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710081503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7100905] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710090501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{
			talk = "herochange_710090502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{
			talk = "herochange_710090503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7100910] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710091001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710091002",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710091003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7100915] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710091501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710091502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710091503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101005] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710100501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710100502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710100503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7101010] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710101001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710101002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710101003",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7101015] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710101501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710101502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710101503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7101105] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710110501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710110502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710110503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7101110] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710111001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710111002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710111003",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7101115] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710111501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710111502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710111503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7101205] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710120501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710120502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710120503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7101210] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710121001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710121002",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710121003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101215] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710121501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "herochange_710121502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02},   -- 锚点 调整立汇位置
            zoom = 1,          -- 缩放
            name = "Name_10026",  -- 肯洛·哈格
            namePos = {275,188},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710121503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_langqibing.png", -- 立汇名字
            anchor = {-0.2,0.1},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10028",  -- 狼骑兵
            namePos = {390,380},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
	},
	[7101305] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710130501",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "herochange_710130502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710130503",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710130504",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[7101310] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710131001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710131002",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710131003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[7101315] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710131501",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "herochange_710131502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710131503",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
	},
	[7101405] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710140501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710140502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710140503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[7101410] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710141001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710141002",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710141003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[7101415] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710141501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710141502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710141503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[7101505] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710150501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710150502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710150503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[7101510] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710151001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710151002",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710151003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[7101515] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710151501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "herochange_710151502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710151503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[7101605] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710160501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710160502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710160503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101610] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710161001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710161002",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710161003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101615] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710161501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710161502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710161503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101705] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710170501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710170502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710170503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101710] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710171001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710171002",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710171003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101715] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710171501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710171502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710171503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101805] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710180501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710180502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710180503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101810] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710181001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710181002",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710181003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101815] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710181501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "herochange_710181502",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "herochange_710181503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[7101905] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710190501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710190502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {255,180},      	-- 名字的位置，需要调整
            textOffset = {-10,0}
		},
		{	
			talk = "herochange_710190503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[7101910] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710191001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710191002",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {110,180},      	-- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{
			talk = "herochange_710191003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[7101915] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710191501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {100,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "herochange_710191502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710191503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            flip = 1,
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {100,180},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[7102005] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710200501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710200502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "herochange_710200503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[7102010] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710201001",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "herochange_710201002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710201003",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
	},
	[7102015] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710201501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710201502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "herochange_710201503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[7102105] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710210501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710210502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "herochange_710210503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[7102110] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710211001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710211002",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "herochange_710211003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[7102115] = {	--第7章15关剧情英雄	
		{	
			talk = "herochange_710211501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "herochange_710211502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10055", 	-- 铁人
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "herochange_710211503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[7102205] = {	--第8章22关剧情英雄	
		{	
			talk = "herochange_710220501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710220502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710220503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[7102210] = {	--第8章22关剧情英雄	
		{	
			talk = "herochange_710221001",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710221002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710221003",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7102215] = {	--第8章22关剧情英雄	
		{	
			talk = "herochange_710221501",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710221502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710221503",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7102305] = {	--第8章23关剧情英雄	
		{	
			talk = "herochange_710230501",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710230502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710230503",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7102310] = {	--第8章23关剧情英雄	
		{	
			talk = "herochange_710231001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710231002",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710231003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[7102315] = {	--第8章23关剧情英雄	
		{	
			talk = "herochange_710231501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710231502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710231503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[7102405] = {	--第8章24关剧情英雄	
		{	
			talk = "herochange_710240501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710240502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710240503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[7102410] = {	--第8章24关剧情英雄	
		{	
			talk = "herochange_710241001",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710241002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710241003",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[7102415] = {	--第8章24关剧情英雄	
		{	
			talk = "herochange_710241501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
		{	
			talk = "herochange_710241502",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10030", 	-- 僧侣
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "herochange_710241503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Dracon.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10010", 	-- 德肯
            namePos = {315,182},      	-- 名字的位置，需要调整
            textOffset = {120,0}
		},
	},
	[7102505] = {	--第25章剧情英雄	
		{	
			talk = "herochange_710250501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{
			talk = "herochange_710250502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{
			talk = "herochange_710250503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[7102510] = {	--第25章剧情英雄	
		{	
			talk = "herochange_710251001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{
			talk = "herochange_710251002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "herochange_710251003",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[7102515] = {	--第25章剧情英雄	
		{	
			talk = "herochange_710251501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "herochange_710251502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "herochange_710251503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
	},
	[7102605] = {	--第26章剧情英雄	
		{	
			talk = "herochange_710260501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "herochange_710260502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "herochange_710260503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
	},
	[7102610] = {	--第25章剧情英雄	
		{	
			talk = "herochange_710261001",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "herochange_710261002",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "herochange_710261003",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[7102615] = {	--第25章剧情英雄	
		{	
			talk = "herochange_710261501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "herochange_710261502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "herochange_710261503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[7102705] = {	--第25章剧情英雄	
		{	
			talk = "herochange_710270501",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "herochange_710270502",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "herochange_710270503",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[7102710] = {	--第26章剧情英雄	
		{	
			talk = "herochange_710271001",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "herochange_710271002",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "herochange_710271003",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
	},
	[7102715] = {	--第26章剧情英雄	
		{	
			talk = "herochange_710271501",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
		{	
			talk = "herochange_710271502",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Sephinroth.png", -- 立汇名字
            flip = 1,
            anchor = {0,-0.03},   -- 锚点 调整立汇位置
            zoom = 0.9,          -- 缩放
            name = "Name_10073",  -- 萨费罗斯
            namePos = {155,190},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "herochange_710271503",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mutare.png", -- 立汇名字
            flip = 1,
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10072", 	-- 摩莉尔
            namePos = {290,185},      	-- 名字的位置，需要调整
            textOffset = {170,0}
		},
	},
	[401] = {	--第二大章剧情	
		{	
			talk = "story_201",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	

	},
	[402] = {	--第三大章剧情	
		{	
			talk = "story_301",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
	},
	[403] = {	--第四大章剧情	
		{	
			talk = "story_401",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
	},
	[404] = {	--第五大章剧情	
		{	
			talk = "story_501",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
	},
	[405] = {	--第六大章剧情	
		{	
			talk = "story_601",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
	},
	[201] = {	--远征奖励特殊关对话1	
		{	
			talk = "crusade_81001",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "crusade_81002",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "crusade_81003",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "crusade_81004",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[211] = {	--远征奖励特殊关对话2	
		{	
			talk = "crusade_81101",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "crusade_81102",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "crusade_81103",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},			
	},
	[202] = {	--远征战斗特殊关对话1	
		{	
			talk = "crusade_81001",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "crusade_81002",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "crusade_81003",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "crusade_81004",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[212] = {	--远征战斗特殊关对话2	
		{	
			talk = "crusade_82101",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "crusade_82102",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "crusade_82103",
			roleImg = "pingdan",			
			side = 2   -- 1 or 2
		},	
		{	
			talk = "crusade_82104",
			roleImg = "jingya",			
			side = 2   -- 1 or 2
		},			
	},
	[2000] = {	--首次进入联盟地图1
		{	
			talk = "LIANMENGGUIDE_1",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
	},
	[2001] = {	--首次进入联盟地图1
		{	
			talk = "LIANMENGGUIDE_2",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "LIANMENGGUIDE_3",
			roleImg = "xingfen",			
			side = 2   -- 1 or 2
		},		
	},
	[2002] = {	--首次进入联盟地图2
		{	
			talk = "LIANMENGGUIDE_4",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "LIANMENGGUIDE_5",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "LIANMENGGUIDE_6",
			roleImg = "xingfen",			
			side = 2   -- 1 or 2
		},
	},
	[2003] = {	--首次进入地下城
		{	
			talk = "LIANMENGGUIDE_7",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "LIANMENGGUIDE_8",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "LIANMENGGUIDE_9",
			roleImg = "xingfen",			
			side = 2   -- 1 or 2
		},
	},
	[2004] = {	--首次进入地下城
		{	
			talk = "LIANMENGGUIDE_10",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "LIANMENGGUIDE_11",
			roleImg = "weixiao",			
			side = 2   -- 1 or 2
		},
		{	
			talk = "LIANMENGGUIDE_12",
			roleImg = "xingfen",			
			side = 2   -- 1 or 2
		},
	},
	[3001] = {	--传记 凯瑟琳1助战
		{	
			talk = "STAGETALK_60102_1_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jibing.png", -- 立汇名字
            anchor = {-0.26,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.8,        	 -- 缩放
            name = "Name_10005", 	-- 名字 传令官
            namePos = {373,530}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60102_1_02",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3002] = {	--传记 凯瑟琳1结束
		{	
			talk = "STAGETALK_60102_1_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shizijun.png", -- 立汇名字
            flip = 1,
            anchor = {-0.26,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10045", 	-- 十字军
            namePos = {350,550}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60102_1_04",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3003] = {	--传记 凯瑟琳2开始
		{	
			talk = "STAGETALK_60102_2_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi_2.png", -- 立汇名字
            flip = 1,
            anchor = {-0.41,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10062", 	-- 力天使以法塔
            namePos = {200,525}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60102_2_02",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60102_2_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi_2.png", -- 立汇名字
            flip = 1,
            anchor = {-0.41,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10062", 	-- 力天使以法塔
            namePos = {200,525}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60102_2_04",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            anchor = {1.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            color = 1,
            name = "Name_10021", 	-- 黑暗受膏者
            namePos = {780,530},      	-- 名字的位置，需要调整
            textOffset = {-110,0}
		},
	},
	[3004] = {	--传记 凯瑟琳2结束
		{	
			talk = "STAGETALK_60102_2_05",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            anchor = {1.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            color = 1,
            name = "Name_10021", 	-- 黑暗受膏者
            namePos = {780,530},      	-- 名字的位置，需要调整
            textOffset = {-110,0}
		},
		{	
			talk = "STAGETALK_60102_2_06",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi_2.png", -- 立汇名字
            flip = 1,
            anchor = {-0.41,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10062", 	-- 力天使以法塔
            namePos = {200,525}      	-- 名字的位置，需要调整
		},
	},
	[3005] = {	--传记 凯瑟琳3开始
		{	
			talk = "STAGETALK_60102_3_01",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60102_3_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_siwangqishi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10033", 	-- 莫拉斯
            namePos = {205,515}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60102_3_03",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3006] = {	--传记 凯瑟琳3结束
		{	
			talk = "STAGETALK_60102_3_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_siwangqishi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10033", 	-- 莫拉斯
            namePos = {205,515}      	-- 名字的位置，需要调整
		},
	},
	[3007] = {	--传记 凯瑟琳4开始
		{	
			talk = "STAGETALK_60102_4_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60102_4_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_wuyao.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10019", 	-- 骨语者爱莎
            namePos = {295,525}      	-- 名字的位置，需要调整
		},
	},
	[3008] = {	--传记 凯瑟琳4结束
		{	
			talk = "STAGETALK_60102_4_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_wuyao.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10019", 	-- 骨语者爱莎
            namePos = {295,525}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60102_4_04",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3009] = {	--传记 凯瑟琳5开始
		{	
			talk = "STAGETALK_60102_5_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Roland.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10032",  -- 罗兰德
            namePos = {178,180}       -- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60102_5_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3010] = {	--传记 凯瑟琳5结束
		{	
			talk = "STAGETALK_60102_5_04",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Roland.png", -- 立汇名字
            flip = 1,
            anchor = {1,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10032",  -- 罗兰德
            namePos = {300,180},       -- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60102_5_05",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Roland.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10032",  -- 罗兰德
            namePos = {178,180}       -- 名字的位置，需要调整
		},
	},
	[3011] = {	--传记 罗伊德1开始
		{	
			talk = "STAGETALK_60303_1_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_ryland.png", -- 立汇名字
            anchor = {1,-0.03},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10041",  -- 罗伊德
            namePos = {225,160},       -- 名字的位置，需要调整
            textOffset = {105,0}
		},
		{	
			talk = "STAGETALK_60303_1_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_DendroidGuard.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10049",  -- #蛮藤长老
            namePos = {265,180},       -- 名字的位置，需要调整
		},
	},
	[3013] = {	--传记 罗伊德2开始
		{	
			talk = "STAGETALK_60303_2_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_DendroidGuard.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10047",  -- #铁须长老
            namePos = {265,180},       -- 名字的位置，需要调整
		},
	},
	[3015] = {	--传记 罗伊德3开始
		{	
			talk = "STAGETALK_60303_3_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_DendroidGuard.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10048", 	-- #石皮长老
            namePos = {240,180},      	-- 名字的位置，需要调整
		},
	},
	[3017] = {	--传记 罗伊德4开始
		{	
			talk = "STAGETALK_60303_4_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_DendroidGuard.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10049",  -- #蛮藤长老
            namePos = {265,180},       -- 名字的位置，需要调整
		},
	},
	[3019] = {	--传记 罗伊德5开始
		{	
			talk = "STAGETALK_60303_5_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_DendroidGuard.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10047",  -- #铁须长老
            namePos = {265,180},       -- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60303_5_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_DendroidGuard.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10048", 	-- #石皮长老
            namePos = {240,180},      	-- 名字的位置，需要调整
		},
	},
	[3020] = {	--传记 罗伊德5结束
		{	
			talk = "STAGETALK_60303_5_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_DendroidGuard.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10049",  -- #蛮藤长老
            namePos = {265,180},       -- 名字的位置，需要调整
		},
	},
	[3021] = {	--传记 瑞斯卡1开始
		{	
			talk = "STAGETALK_60802_1_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "STAGETALK_60802_1_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shenguai.png", -- 立汇名字
            anchor = {-0.15,0.02},   -- 锚点 调整立汇位置
            zoom = 0.5,         -- 缩放
            name = "Name_10044",  -- 神怪
            namePos = {390,380}       -- 名字的位置，需要调整
		},		
		{	
			talk = "STAGETALK_60802_1_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[3022] = {	--传记 瑞斯卡1结束
		{	
			talk = "STAGETALK_60802_1_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shenguai.png", -- 立汇名字
            anchor = {-0.15,0.02},   -- 锚点 调整立汇位置
            zoom = 0.5,         -- 缩放
            name = "Name_10044",  -- 神怪
            namePos = {390,380}       -- 名字的位置，需要调整
		},
	},
	[3023] = {	--传记 瑞斯卡2开始
		{	
			talk = "STAGETALK_60802_2_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "STAGETALK_60802_2_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10059",  -- 小恶魔
            namePos = {315,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},		
	},
	[3024] = {	--传记 瑞斯卡2结束
		{	
			talk = "STAGETALK_60802_2_04",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[3025] = {	--传记 瑞斯卡3开始
		{	
			talk = "STAGETALK_60802_3_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},
		{	
			talk = "STAGETALK_60802_3_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[3026] = {	--传记 瑞斯卡3结束
		{	
			talk = "STAGETALK_60802_3_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Xeron.png", -- 立汇名字
            anchor = {0,0},   -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10042",  -- 塞尔伦
            namePos = {170,175},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
		{	
			talk = "STAGETALK_60802_3_05",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[3027] = {	--传记 瑞斯卡4开始
		{	
			talk = "STAGETALK_60802_4_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "STAGETALK_60802_4_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_santouquan.png", -- 立汇名字
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10003",  -- 贝莱特
            namePos = {280,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[3028] = {	--传记 瑞斯卡4结束
		{	
			talk = "STAGETALK_60802_4_03",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_santouquan.png", -- 立汇名字
            anchor = {-0.25,0.3},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10003",  -- 贝莱特
            namePos = {280,575},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[3029] = {	--传记 瑞斯卡5开始
		{	
			talk = "STAGETALK_60802_5_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Rashka.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10039", 	-- 瑞斯卡
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "STAGETALK_60802_5_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_changjiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.28,0.3},   -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10012",  -- 狄克提特
            namePos = {233,527},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[3030] = {	--传记 瑞斯卡5结束
		{	
			talk = "STAGETALK_60802_5_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_changjiaoemo.png", -- 立汇名字
            flip = 1,
            anchor = {-0.28,0.3},   -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10012",  -- 狄克提特
            namePos = {233,527},       -- 名字的位置，需要调整
            textOffset = {30,0}
		},	
	},
	[3031] = {	--传记 艾德雷德1开始
		{	
			talk = "STAGETALK_60001_1_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {240,180},      	-- 名字的位置，需要调整
            textOffset = {70,0}
		},
		{	
			talk = "STAGETALK_60001_1_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10043", 	-- 塞普蒂娜
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[3033] = {	--传记 艾德雷德2开始
		{	
			talk = "STAGETALK_60001_2_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {240,180},      	-- 名字的位置，需要调整
            textOffset = {70,0}
		},
	},
	[3034] = {	--传记 艾德雷德2结束
		{	
			talk = "STAGETALK_60001_2_04",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {240,180},      	-- 名字的位置，需要调整
            textOffset = {70,0}
		},
	},
	[3035] = {	--传记 艾德雷德3开始
		{	
			talk = "STAGETALK_60001_3_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {240,180},      	-- 名字的位置，需要调整
            textOffset = {90,0}
		},
		{	
			talk = "STAGETALK_60001_3_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_mujingling.png", -- 立汇名字
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            color = 1,
            zoom = 0.6,         -- 缩放
            name = "Name_10057",  -- 沃里精灵
            namePos = {275,520}       -- 名字的位置，需要调整
		},	
	},
	[3037] = {	--传记 艾德雷德4开始
		{	
			talk = "STAGETALK_60001_4_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {240,180},      	-- 名字的位置，需要调整
            textOffset = {70,0}
		},
		{	
			talk = "STAGETALK_60001_4_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10043", 	-- 塞普蒂娜
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[3039] = {	--传记 艾德雷德5开始
		{	
			talk = "STAGETALK_60001_5_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_wuyao.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10043", 	-- 塞普蒂娜
            namePos = {295,525}      	-- 名字的位置，需要调整
		},
	},
	[3041] = {	--传记 格鲁1开始
		{	
			talk = "STAGETALK_60301_1_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_60301_1_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shirenmo.png", -- 立汇名字
            anchor = {-0.25,0.2},   -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10025",  -- 克拉戈
            namePos = {333,430},       -- 名字的位置，需要调整
            textOffset = {50,0}
		},	
		{	
			talk = "STAGETALK_60301_1_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3042] = {	--传记 格鲁1结束
		{	
			talk = "STAGETALK_60301_1_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shirenmo.png", -- 立汇名字
            anchor = {-0.25,0.2},   -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10025",  -- 克拉戈
            namePos = {333,430},       -- 名字的位置，需要调整
            textOffset = {50,0}
		},	
		{	
			talk = "STAGETALK_60301_1_05",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3043] = {	--传记 格鲁2开始
		{	
			talk = "STAGETALK_60301_2_01",	
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_huanyingsheshounv.png", -- 立汇名字
            flip = 1,
            anchor = {1.15,0.25},   -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10022",  -- 幻影射手
            namePos = {580,475},       -- 名字的位置，需要调整
            textOffset = {-140,0}
		},	
		{	
			talk = "STAGETALK_60301_2_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_nushou.png", -- 立汇名字
            anchor = {-0.25,0},   -- 锚点 调整立汇位置
            zoom = 0.55,         -- 缩放
            name = "Name_10035",  -- 密林强盗
            namePos = {300,330},       -- 名字的位置，需要调整
            textOffset = {50,0}
		},	
		{	
			talk = "STAGETALK_60301_2_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3044] = {	--传记 格鲁2开始
		{	
			talk = "STAGETALK_60301_2_04",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_60301_2_05",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_nushou.png", -- 立汇名字
            anchor = {-0.25,0},   -- 锚点 调整立汇位置
            zoom = 0.55,         -- 缩放
            name = "Name_10035",  -- 密林强盗
            namePos = {300,330},       -- 名字的位置，需要调整
            textOffset = {50,0}
		},	
	},
	[3045] = {	--传记 格鲁3开始
		{	
			talk = "STAGETALK_60301_3_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_60301_3_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_60301_3_03",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_kongbuqishi.png", -- 立汇名字
            anchor = {-0.24,0.23},   -- 锚点 调整立汇位置
            zoom = 0.68,         -- 缩放
            name = "Name_10051",  -- 死亡骑士
            namePos = {375,470},       -- 名字的位置，需要调整
            textOffset = {50,0}
		},
	},
	[3046] = {	--传记 格鲁3结束
		{	
			talk = "STAGETALK_60301_3_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_kongbuqishi.png", -- 立汇名字
            anchor = {-0.24,0.23},   -- 锚点 调整立汇位置
            zoom = 0.68,         -- 缩放
            name = "Name_10051",  -- 死亡骑士
            namePos = {375,470},       -- 名字的位置，需要调整
            textOffset = {50,0}
		},
		{	
			talk = "STAGETALK_60301_3_05",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3047] = {	--传记 格鲁4开始
		{	
			talk = "STAGETALK_60301_4_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xixuegui.png", -- 立汇名字
            flip = 1,
            anchor = {-0.24,0.18},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10009",  -- 德尔加
            namePos = {250,450},       -- 名字的位置，需要调整
		},	
		{	
			talk = "STAGETALK_60301_4_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3048] = {	--传记 格鲁4结束
		{	
			talk = "STAGETALK_60301_4_03",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_xixuegui.png", -- 立汇名字
            flip = 1,
            anchor = {-0.24,0.18},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10009",  -- 德尔加
            namePos = {250,450},       -- 名字的位置，需要调整
		},	
	},
	[3049] = {	--传记 格鲁5开始
		{	
			talk = "STAGETALK_60301_5_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_60301_5_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_lvlong.png", -- 立汇名字
            flip = 1,
            anchor = {-0.24,0.18},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10037",  -- 奈夫莱特
            namePos = {320,450},       -- 名字的位置，需要调整
		},	
		{	
			talk = "STAGETALK_60301_5_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3050] = {	--传记 格鲁5结束
		{	
			talk = "STAGETALK_60301_5_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_lvlong.png", -- 立汇名字
            flip = 1,
            anchor = {-0.24,0.18},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10037",  -- 奈夫莱特
            namePos = {320,450},       -- 名字的位置，需要调整
		},	
		{	
			talk = "STAGETALK_60301_5_05",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_60301_5_06",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_lvlong.png", -- 立汇名字
            flip = 1,
            anchor = {-0.24,0.18},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10037",  -- 奈夫莱特
            namePos = {320,450},       -- 名字的位置，需要调整
		},	
		{	
			talk = "STAGETALK_60301_5_07",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3051] = {	--传记 肯洛·哈格1开始
		{	
			talk = "STAGETALK_60602_1_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60602_1_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shizijun.png", -- 立汇名字
            flip = 1,
            anchor = {-0.26,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10045", 	-- 十字军
            namePos = {350,550},      	-- 名字的位置，需要调整
            textOffset = {80,0}
		},
		{	
			talk = "STAGETALK_60602_1_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3052] = {	--传记 肯洛·哈格1结束
		{	
			talk = "STAGETALK_60602_1_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shizijun.png", -- 立汇名字
            flip = 1,
            anchor = {-0.26,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10045", 	-- 十字军
            namePos = {350,550},      	-- 名字的位置，需要调整
            textOffset = {80,0}
		},
	},
	[3053] = {	--传记 肯洛·哈格2开始
		{	
			talk = "STAGETALK_60602_2_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60602_2_02",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shourentoufushou_1.png", -- 立汇名字
            flip = 1,
            anchor = {-0.28,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10002", 	-- 巴尔森
            namePos = {215,480},      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60602_2_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3054] = {	--传记 肯洛·哈格2结束
		{	
			talk = "STAGETALK_60602_2_04",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shourentoufushou_1.png", -- 立汇名字
            flip = 1,
            anchor = {-0.28,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10002", 	-- 巴尔森
            namePos = {215,480},      	-- 名字的位置，需要调整
		},
	},
	[3055] = {	--传记 肯洛·哈格3开始
		{	
			talk = "STAGETALK_60602_3_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60602_3_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_siwangqishi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10033", 	-- 莫拉斯
            namePos = {205,515}      	-- 名字的位置，需要调整
		},
	},
	[3056] = {	--传记 肯洛·哈格3结束
		{	
			talk = "STAGETALK_60602_3_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_siwangqishi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10033", 	-- 莫拉斯
            namePos = {205,515}      	-- 名字的位置，需要调整
		},
	},
	[3057] = {	--传记 肯洛·哈格4开始
		{	
			talk = "STAGETALK_60602_4_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60602_4_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_youling.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10064", 	-- 幽灵
            namePos = {290,515}      	-- 名字的位置，需要调整
		},
	},
	[3058] = {	--传记 肯洛·哈格4结束
		{	
			talk = "STAGETALK_60602_4_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_youling.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10064", 	-- 幽灵
            namePos = {290,515}      	-- 名字的位置，需要调整
		},
	},
	[3059] = {	--传记 肯洛·哈格5开始
		{	
			talk = "STAGETALK_60602_5_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_CragHack.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10026", 	-- 肯洛·哈格
            namePos = {275,188},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60602_5_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_wuyao.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10004", 	-- 查纳斯
            namePos = {295,525}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60602_5_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_wuyao.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10004", 	-- 查纳斯
            namePos = {295,525}      	-- 名字的位置，需要调整
		},
	},
	[3060] = {	--传记 肯洛·哈格5结束
		{	
			talk = "STAGETALK_60602_5_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_wuyao.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10004", 	-- 查纳斯
            namePos = {295,525}      	-- 名字的位置，需要调整
		},
	},
	[3061] = {	--传记 索姆拉1开始
		{	
			talk = "STAGETALK_61201_1_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10027", 	-- 迷宫守卫
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_61201_1_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_61201_1_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_tieren.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10027", 	-- 迷宫守卫
            namePos = {340,475}      	-- 名字的位置，需要调整
		},
	},
	[3062] = {	--传记 索姆拉1结束
		{	
			talk = "STAGETALK_61201_1_04",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3063] = {	--传记 索姆拉2开始
		{	
			talk = "STAGETALK_61201_2_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi.png", -- 立汇名字
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10008", 	-- 大天使
            namePos = {290,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_61201_2_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_61201_2_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_datianshi.png", -- 立汇名字
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10008", 	-- 大天使
            namePos = {290,475}      	-- 名字的位置，需要调整
		},
	},
	[3064] = {	--传记 索姆拉2结束
		{	
			talk = "STAGETALK_61201_2_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_taitan.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            color = 1,
            name = "Name_10001", 	-- 科洛尼监护人
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[3065] = {	--传记 索姆拉3开始
		{	
			talk = "STAGETALK_61201_3_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_61201_3_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_bingyuansu2.png", -- 立汇名字
            anchor = {-0.35,0.41}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10014", 	-- 元素惩罚者
            namePos = {350,563}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_61201_3_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3067] = {	--传记 索姆拉4开始
		{	
			talk = "STAGETALK_61201_4_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_61201_4_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            color = 1,
            name = "Name_10017", 	-- 加文·玛格努斯
            namePos = {292,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_61201_4_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3068] = {	--传记 索姆拉4结束
		{	
			talk = "STAGETALK_61201_4_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            color = 1,
            name = "Name_10017", 	-- 加文·玛格努斯
            namePos = {292,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_61201_4_05",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3069] = {	--传记 索姆拉5开始
		{	
			talk = "STAGETALK_61201_5_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_61201_5_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10056", 	-- 时光守卫
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_61201_5_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[3070] = {	--传记 索姆拉5结束
		{	
			talk = "STAGETALK_61201_5_04",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
		{	
			talk = "STAGETALK_61201_5_05",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            color = 1,
            name = "Name_10017", 	-- 加文·玛格努斯
            namePos = {292,475}      	-- 名字的位置，需要调整
		},
	},
	[3071] = {	--传记 孟斐拉1开始
		{	
			talk = "STAGETALK_60302_1_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_liehuoyuansu.png", -- 立汇名字
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10050", 	-- 肆虐的火元素
            namePos = {292,475},      	-- 名字的位置，需要调整
            textOffset = {80,0}
		},
		{	
			talk = "STAGETALK_60302_1_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3072] = {	--传记 孟斐拉1结束
		{	
			talk = "STAGETALK_60302_1_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_liehuoyuansu.png", -- 立汇名字
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10050", 	-- 肆虐的火元素
            namePos = {292,475},      	-- 名字的位置，需要调整
            textOffset = {80,0}
		},
	},
	[3073] = {	--传记 孟斐拉2开始
		{	
			talk = "STAGETALK_60302_2_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60302_2_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shizijun.png", -- 立汇名字
            flip = 1,
            anchor = {-0.26,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10031", 	-- 林木滥伐者
            namePos = {350,550}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60302_2_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3074] = {	--传记 孟斐拉2结束
		{	
			talk = "STAGETALK_60302_2_04",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3075] = {	--传记 孟斐拉3开始
		{	
			talk = "STAGETALK_60302_3_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60302_3_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_bingyuansu2.png", -- 立汇名字
            anchor = {-0.35,0.41}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10015", 	-- 泛滥的水元素
            namePos = {350,563}      	-- 名字的位置，需要调整
		},
	},
	[3076] = {	--传记 孟斐拉3结束
		{	
			talk = "STAGETALK_60302_3_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_bingyuansu2.png", -- 立汇名字
            anchor = {-0.35,0.41}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10015", 	-- 泛滥的水元素
            namePos = {350,563}      	-- 名字的位置，需要调整
		},
	},
	[3077] = {	--传记 孟斐拉4开始
		{	
			talk = "STAGETALK_60302_4_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60302_4_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jibing.png", -- 立汇名字
            anchor = {-0.26,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.8,        	 -- 缩放
            name = "Name_10054", 	-- 贪婪的狩猎者
            namePos = {373,530}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60302_4_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3079] = {	--传记 孟斐拉5开始
		{	
			talk = "STAGETALK_60302_5_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
		{	
			talk = "STAGETALK_60302_5_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_bimeng.png", -- 立汇名字
            flip = 0.9,
            anchor = {-0.26,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.8,        	 -- 缩放
            name = "Name_10061", 	-- 岩爪
            namePos = {410,450}      	-- 名字的位置，需要调整
		},
	},
	[3080] = {	--传记 孟斐拉5结束
		{	
			talk = "STAGETALK_60302_5_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_bimeng.png", -- 立汇名字
            flip = 0.9,
            anchor = {-0.26,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.8,        	 -- 缩放
            name = "Name_10061", 	-- 岩爪
            namePos = {410,450}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60302_5_05",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mephala.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10034", 	-- 孟斐拉
            namePos = {320,182},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[3081] = {	--传记 约克1开始
		{	
			talk = "STAGETALK_60604_1_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Boragus.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10046",  -- 伯拉格公爵
            namePos = {190,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "STAGETALK_60604_1_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "STAGETALK_60604_1_03",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Boragus.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10046",  -- 伯拉格公爵
            namePos = {190,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[3083] = {	--传记 约克2开始
		{	
			talk = "STAGETALK_60604_2_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kilgor.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10024", 	-- 科尔格
            namePos = {160,180}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60604_2_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "STAGETALK_60604_2_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kilgor.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10024", 	-- 科尔格
            namePos = {160,180}      	-- 名字的位置，需要调整
		},
	},
	[3084] = {	--传记 约克2结束
		{	
			talk = "STAGETALK_60604_2_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Kilgor.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10024", 	-- 科尔格
            namePos = {160,180}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60604_2_05",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[3085] = {	--传记 约克3开始
		{	
			talk = "STAGETALK_60604_3_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10067", 	-- 先知阿兰多拉
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "STAGETALK_60604_3_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "STAGETALK_60604_3_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10067", 	-- 先知阿兰多拉
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[3086] = {	--传记 约克3结束
		{	
			talk = "STAGETALK_60604_3_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_senglv.png", -- 立汇名字
            flip = 1,
            anchor = {-0.4,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.9,        	 -- 缩放
            name = "Name_10067", 	-- 先知阿兰多拉
            namePos = {270,510},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
	},
	[3087] = {	--传记 约克4开始
		{	
			talk = "STAGETALK_60604_4_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10068", 	-- 隐士特尔文
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60604_4_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
		{	
			talk = "STAGETALK_60604_4_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10068", 	-- 隐士特尔文
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[3088] = {	--传记 约克4结束
		{	
			talk = "STAGETALK_60604_4_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10068", 	-- 隐士特尔文
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[3089] = {	--传记 约克5开始
		{	
			talk = "STAGETALK_60604_5_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10069", 	-- 智者布罗格
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60604_5_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Yog.png", -- 立汇名字
            anchor = {1,0.025}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10065", 	-- 约克
            namePos = {280,182},      	-- 名字的位置，需要调整
            textOffset = {200,0}
		},
	},
	[3090] = {	--传记 约克5结束
		{	
			talk = "STAGETALK_60604_5_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jingshenyuansu.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10069", 	-- 智者布罗格
            namePos = {310,475}      	-- 名字的位置，需要调整
		},
	},
	[3091] = {	--传记 维德尼娜1开始
		{	
			talk = "STAGETALK_60502_1_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            anchor = {0,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {255,180},      	-- 名字的位置，需要调整
            textOffset = {-10,0}
		},
		{	
			talk = "STAGETALK_60502_1_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Vidomina.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {1.2,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10074",  -- 维德尼娜
            namePos = {380,175},       -- 名字的位置，需要调整
            textOffset = {70,0}
		},
	},
	[3093] = {	--传记 维德尼娜2开始
		{	
			talk = "STAGETALK_60502_2_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Sandro.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {-0.15,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10075",  -- 山德鲁
            namePos = {122,180},       -- 名字的位置，需要调整
            textOffset = {-30,0}  -- 文本位置
		},
		{	
			talk = "STAGETALK_60502_2_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Vidomina.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {1.2,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10074",  -- 维德尼娜
            namePos = {380,175},       -- 名字的位置，需要调整
            textOffset = {70,0}
		},
		{	
			talk = "STAGETALK_60502_2_03",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Sandro.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {-0.15,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10075",  -- 山德鲁
            namePos = {122,180},       -- 名字的位置，需要调整
            textOffset = {-45,0}  -- 文本位置
		},
	},
	[3095] = {	--传记 维德尼娜3开始
		{	
			talk = "STAGETALK_60502_3_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_airen.png", -- 立汇名字
            anchor = {-0.2,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10076",  -- 宝物守护者
            namePos = {370,470},       -- 名字的位置，需要调整
            textOffset = {-15,0}  -- 文本位置
		},
		{	
			talk = "STAGETALK_60502_3_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Vidomina.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {1.2,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10074",  -- 维德尼娜
            namePos = {380,175},       -- 名字的位置，需要调整
            textOffset = {70,0}
		},
	},
	[3097] = {	--传记 维德尼娜4开始
		{	
			talk = "STAGETALK_60502_4_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/ta_kulouzhanshi.png", -- 立汇名字
            anchor = {-0.2,0.1}, 	 -- 锚点 调整立汇位置
            zoom = 0.5,         -- 缩放
            name = "Name_10077", 	-- 菲尼斯·威尔玛
            color = 1, 	-- 全黑
            namePos = {280,440},       -- 名字的位置，需要调整
            textOffset = {0,0}  -- 文本位置
		},
		{	
			talk = "STAGETALK_60502_4_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Vidomina.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {1.2,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10074",  -- 维德尼娜
            namePos = {380,175},       -- 名字的位置，需要调整
            textOffset = {70,0}
		},
	},
	[3099] = {	--传记 维德尼娜5开始
		{	
			talk = "STAGETALK_60502_5_01",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Sandro.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {-0.15,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10075",  -- 山德鲁
            namePos = {122,180},       -- 名字的位置，需要调整
            textOffset = {-45,0}  -- 文本位置
		},
		{	
			talk = "STAGETALK_60502_5_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Vidomina.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {1.2,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10074",  -- 维德尼娜
            namePos = {380,175},       -- 名字的位置，需要调整
            textOffset = {70,0}
		},
		{	
			talk = "STAGETALK_60502_5_03",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Sandro.png", -- 立汇名字
            flip = 1, 	 -- 水平翻转
            anchor = {-0.15,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10075",  -- 山德鲁
            namePos = {122,180},       -- 名字的位置，需要调整
            textOffset = {-45,0}  -- 文本位置
		},
	},
	[3101] = {	--传记 姆拉克1开始
		{	
			talk = "STAGETALK_60101_1_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
		{	
			talk = "STAGETALK_60101_1_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_airen.png", -- 立汇名字
            anchor = {-0.2,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10078", 	-- 旅店老板萨维德拉
            namePos = {380,480}      	-- 名字的位置，需要调整
		},
	},
	[3102] = {	--传记 姆拉克1结束
		{	
			talk = "STAGETALK_60101_1_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_airen.png", -- 立汇名字
            anchor = {-0.2,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10078", 	-- 旅店老板萨维德拉
            namePos = {380,480}      	-- 名字的位置，需要调整
		},
	},
	[3103] = {	--传记 姆拉克2开始
		{	
			talk = "STAGETALK_60101_2_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
		{	
			talk = "STAGETALK_60101_2_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_duyanjuren.png", -- 立汇名字
            anchor = {-0.2,0.15}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10079", 	-- 劫掠巨人
            namePos = {210,440},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "STAGETALK_60101_2_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
	},
	[3105] = {	--传记 姆拉克3开始
		{	
			talk = "STAGETALK_60101_3_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
		{	
			talk = "STAGETALK_60101_3_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shengqishi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10080", 	-- 铜盔骑士加尔拉斯果
            namePos = {250,430},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
		{	
			talk = "STAGETALK_60101_3_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
	},
	[3106] = {	--传记 姆拉克3结束
		{	
			talk = "STAGETALK_60101_3_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shengqishi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10080", 	-- 铜盔骑士加尔拉斯果
            namePos = {250,430},      	-- 名字的位置，需要调整
            textOffset = {10,0}
		},
	},
	[3107] = {	--传记 姆拉克4开始
		{	
			talk = "STAGETALK_60101_4_01",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
		{	
			talk = "STAGETALK_60101_4_02",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10081", 	-- 魔尘巫师
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60101_4_03",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
	},
	[3108] = {	--传记 姆拉克4结束
		{	
			talk = "STAGETALK_60101_4_04",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10068", 	-- 隐士特尔文
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[3109] = {	--传记 姆拉克5开始
		{	
			talk = "STAGETALK_60101_5_01",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_youling.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10083", 	-- 幽灵表演者
            namePos = {290,515}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60101_5_02",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
		{	
			talk = "STAGETALK_60101_5_03",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_youling.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10083", 	-- 幽灵表演者
            namePos = {290,515}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60101_5_04",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_wuyao.png", -- 立汇名字
            anchor = {1.3,0.2}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10084", 	-- 旁白
            namePos = {750,430},      	-- 名字的位置，需要调整
            textOffset = {-250,0}
		},
		{	
			talk = "STAGETALK_60101_5_05",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_youling.png", -- 立汇名字
            flip = 1,
            anchor = {-0.38,0.3}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10083", 	-- 幽灵表演者
            namePos = {290,515}      	-- 名字的位置，需要调整
		},
		{	
			talk = "STAGETALK_60101_5_06",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
	},
	[3110] = {	--传记 姆拉克5结束
		{	
			talk = "STAGETALK_60101_5_07",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/ta_siwangqishi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.25,0.15}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10082", 	-- 戏班主安古罗
            namePos = {140,430},      	-- 名字的位置，需要调整
            textOffset = {-30,0}
		},
		{	
			talk = "STAGETALK_60101_5_08",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/ta_siwangqishi.png", -- 立汇名字
            anchor = {1.3,0.15}, 	 -- 锚点 调整立汇位置
            zoom = 0.6,        	 -- 缩放
            name = "Name_10082", 	-- 戏班主安古罗
            namePos = {840,430},      	-- 名字的位置，需要调整
            textOffset = {-70,0}
		},
	},
	[4001] = {	--传记 凯瑟琳5助战
		{	
			talk = "STAGETALK_60102_5_06",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_shenguai.png", -- 立汇名字
            anchor = {-0.15,0.02},   -- 锚点 调整立汇位置
            zoom = 0.5,         -- 缩放
            name = "Name_10044",  -- 神灯
            namePos = {390,380}       -- 名字的位置，需要调整
		},		
		{	
			talk = "STAGETALK_60102_5_07",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/team/t_mujingling.png", -- 立汇名字
            anchor = {1.2,0.28},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10036",  -- 木精灵
            namePos = {740,545},       -- 名字的位置，需要调整
            textOffset = {-125,0}
		},	
	},
	[4002] = {	--传记 罗伊德3助战
		{	
			talk = "STAGETALK_60303_3_06",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_lvlong.png", -- 立汇名字
            flip = 1,
            anchor = {-0.24,0.18},   -- 锚点 调整立汇位置
            zoom = 0.6,         -- 缩放
            name = "Name_10037",  -- 奈夫莱特
            namePos = {320,450}       -- 名字的位置，需要调整
		},	
	},
	[10101] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY1_1",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[10102] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY1_2",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[10103] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY1_3",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_dafashi.png", -- 立汇名字
            flip = 1,
            anchor = {-0.3,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,        	 -- 缩放
            name = "Name_10070", 	-- 大法师
            namePos = {285,475}      	-- 名字的位置，需要调整
		},
	},
	[10104] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY1_4",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Solmyr.png", -- 立汇名字
            anchor = {1,0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10052", 	-- 索姆拉
            namePos = {300,182},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[10201] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY2_1",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {240,180},      	-- 名字的位置，需要调整
            textOffset = {70,0}
		},
	},
	[10202] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY2_2",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jibing.png", -- 立汇名字
            anchor = {-0.26,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.8,        	 -- 缩放
            name = "Name_10005", 	-- 传令官
            namePos = {373,530}      	-- 名字的位置，需要调整
		},
	},
	[10203] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY2_3",
			side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_jibing.png", -- 立汇名字
            anchor = {-0.26,0.35}, 	 -- 锚点 调整立汇位置
            zoom = 0.8,        	 -- 缩放
            name = "Name_10005", 	-- 传令官
            namePos = {373,530}      	-- 名字的位置，需要调整
		},
	},
	[10204] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY2_4",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Adelaide.png", -- 立汇名字
            flip = 1,
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10000", 	-- 艾德雷德
            namePos = {240,180},      	-- 名字的位置，需要调整
            textOffset = {70,0}
		},
	},
	[10301] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY5_1",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[10302] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY5_2",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[10303] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY5_3",
			side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Catherine.png", -- 立汇名字
            anchor = {1,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10029", 	-- 名字 凯瑟琳
            namePos = {335,180},      	-- 名字的位置，需要调整
            textOffset = {100,0}
		},
	},
	[10401] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY3_1",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_huanyingsheshounv.png", -- 立汇名字
            anchor = {-0.2,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10022",  -- 幻影射手
            namePos = {420,475},       -- 名字的位置，需要调整
            textOffset = {40,0}
		},

		{	
			talk = "DIALOG_SIEGE_STORY3_2",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},

		{	
			talk = "DIALOG_SIEGE_STORY3_3",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/team/t_huanyingsheshounv.png", -- 立汇名字
            anchor = {-0.2,0.25}, 	 -- 锚点 调整立汇位置
            zoom = 0.7,         -- 缩放
            name = "Name_10022",  -- 幻影射手
            namePos = {420,475},       -- 名字的位置，需要调整
            textOffset = {40,0}
		},

		{	
			talk = "DIALOG_SIEGE_STORY3_4",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_gelu.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10018", 	-- 格鲁
            namePos = {300,168},      	-- 名字的位置，需要调整
            textOffset = {140,0}
		},
	},
	[10501] = {	--斯坦德维克世界事件剧情
		{	
			talk = "DIALOG_SIEGE_STORY4_1",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Knight.png", -- 立汇名字
            anchor = {0.,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10040",  -- 骑士
            namePos = {135,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},

		{	
			talk = "DIALOG_SIEGE_STORY4_2",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},

		{	
			talk = "DIALOG_SIEGE_STORY4_3",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Knight.png", -- 立汇名字
            anchor = {0.,0}, 	 -- 锚点 调整立汇位置
            zoom = 1,         -- 缩放
            name = "Name_10040",  -- 骑士
            namePos = {135,180},       -- 名字的位置，需要调整
            textOffset = {10,0}
		},

		{	
			talk = "DIALOG_SIEGE_STORY4_4",
            side = 1,   -- 1 or 2
            roleImg1 = "uiother/guide/guideImage_Mullich.png", -- 立汇名字
            anchor = {1,-0.02}, 	 -- 锚点 调整立汇位置
            zoom = 1,        	 -- 缩放
            name = "Name_10071", 	-- 姆拉克
            namePos = {250,168},      	-- 名字的位置，需要调整
            textOffset = {60,0}
		},
	},
	[22222] = {	--第5章剧情	
		{	
			talk = "JUQING_2908",
            side = 2,   -- 1 or 2
            roleImg1 = "uiother/hero/crusade_Roland_01.png", -- 立汇名字
            flip = 1,
            anchor = {-0.15,0},   -- 锚点 调整立汇位置
            zoom = 0.8,         -- 缩放
            name = "Name_10032",  -- 罗兰德
            namePos = {155,220}       -- 名字的位置，需要调整
        },
	},
}
return guideStoryConfig