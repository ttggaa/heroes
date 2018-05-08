--[[
    Filename:    AdventureConst.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-09-22 15:59
    Description: 大冒险常量
--]]

AdventureConst = {}

AdventureConst.ROUND_GRID_NUM = 22

AdventureConst.GRID_TYPE = {
	START_POINT = 0,
	TREASURE_MAP = 1,
	STAR = 2,
	MAGIC_BOX = 3,
	MAGIC_WELL = 4,
	FINGER_GUESS = 5,
	BATTLE = 6,
	WARPGATE_ENTER = 7,
	WARPGATE_EXIT = 8,
	AWARD_GEM =  9,
	AWARD_BIGGEM =  10,
	AWARD_GOLD =  11,
	AWARD_DICE =  12,
	NULL =  13,
}

AdventureConst.TREASUREMAP_EXCEPTS = {
	[AdventureConst.GRID_TYPE.STAR] = true,
	-- [AdventureConst.GRID_TYPE.TREASURE_MAP] = true,
	[AdventureConst.GRID_TYPE.MAGIC_BOX] = true,
	[AdventureConst.GRID_TYPE.MAGIC_WELL] = true,
	[AdventureConst.GRID_TYPE.WARPGATE_ENTER] = true,
	[AdventureConst.GRID_TYPE.WARPGATE_EXIT] = true,
}

-- 占星
AdventureConst.STATRS = {
	"双鱼座",
	"狮子座",
	"射手座",
	"水瓶座",
	"双子座",
	"摩羯座",
	"天蝎座",
	"天秤座",
	"金牛座",
	"巨蟹座",
	"白羊座",
	"处女座"
}
-- 动画名字 偏移值
AdventureConst.STATR_MCS = {
	{"shuangyu_adventuredianliang",cc.p(-2,-9),0.95},
	{"shizi_adventuredianliang",cc.p(16,-6)},
	{"sheshou_adventuredianliang",cc.p(3,-7),0.97},
	{"shuiping_adventuredianliang",cc.p(-32,-8)},
	{"shuangzi_adventuredianliang",cc.p(5,-8)},
	{"mojie_adventuredianliang",cc.p(9,-5)},
	{"tianxie_adventuredianliang",cc.p(6,-6)},
	{"tianping_adventuredianliang",cc.p(5,-3),{1,0.97}},
	{"jinniu_adventuredianliang",cc.p(-3,-5)},
	{"juxie_adventuredianliang",cc.p(-10,-2)},
	{"baiyang_adventuredianliang",cc.p(-28,-0),{1,.99}},
	{"chunv_adventuredianliang",cc.p(4,-4),.95}
}

-- 猜拳
AdventureConst.GUESS_FINGER = {
	"jiandao_adventure.png",
	"quantou_adventure.png",
	"bu_adventure.png",
}

-- 方向
AdventureConst.ROLE_DIR_LEFT = -3  -- 负值表示左右颠倒
AdventureConst.ROLE_DIR_RIGHT = 3
AdventureConst.ROLE_DIR_UP = 2
AdventureConst.ROLE_DIR_DOWN = 1

-- 角落格子id
AdventureConst.CORNER_1 = 8
AdventureConst.CORNER_2 = 12
AdventureConst.CORNER_3 = 19
AdventureConst.CORNER_4 = 23

-- 格子位置
AdventureConst.gridPoses = 
{
[1]=cc.p(281,414),
[2]=cc.p(379,414),
[3]=cc.p(479,414),
[4]=cc.p(580,414),
[5]=cc.p(680,414),
[6]=cc.p(780,414),
[7]=cc.p(881,414),
[8]=cc.p(981,414),
[9]=cc.p(946,346),
[10]=cc.p(910,278),
[11]=cc.p(871,210),
[12]=cc.p(831,141),
[13]=cc.p(730,141),
[14]=cc.p(629,141),
[15]=cc.p(528,141),
[16]=cc.p(427,141),
[17]=cc.p(326,141),
[18]=cc.p(225,141),
[19]=cc.p(123,141),
[20]=cc.p(166,210),
[21]=cc.p(206,278),
[22]=cc.p(244,346),

}

-- 飞到导航条 金币和钻石 的偏移
AdventureConst.flyOffset = {
    ["jinbi"] = {
        {-22, 40},
        {3, -33},
        {-72, -32},
        {26, 39},
        {-40, -20},
        {-80, 40},
    },
    ["zhuanshi"] = {
        {-19, 22},
        {8, -33},
        {-70, -28},
        {26, 17},
        {-36, -16},
        {-80, 0},
    }
}

-- 格子 类型对应事件
local GRID_TYPE = AdventureConst.GRID_TYPE
AdventureConst.gridEvents = {
	[GRID_TYPE.START_POINT] = {
	    icon = "null",
	    funcName = "startGrid",
	    prompt= {lang("cangbaotu_2")},
	    touchTip = lang("dafuweng_qidian"),
	    },
	[GRID_TYPE.TREASURE_MAP] = {
	    icon = "treasureMap",
	    funcName = "treasureMap",
	    prompt={lang("cangbaotu_1.1"),lang("cangbaotu_1.2")},
	    endPrompt = {lang("cangbaotu_2")},
	    touchTip = lang("dafuweng_cangbaotu"),
	    },
	[GRID_TYPE.STAR] = {
	    icon = "star",
	    funcName = "star",
	    prompt={lang("zhanxing_1.1"),lang("zhanxing_1.2")},
	    touchTip = lang("dafuweng_xingzhou"),
	    },
	[GRID_TYPE.MAGIC_BOX] = {
	    icon = "panduola",
	    funcName = "magicBox",
	    prompt={lang("mohe_1.1"),lang("mohe_1.2"),lang("mohe_1.3")},
	    endPrompt = {lang("mohe_2")},
	    touchTip = {lang("dafuweng_mohe1"),lang("dafuweng_mohe2")},
	    },
	[GRID_TYPE.MAGIC_WELL] = {
	    icon = "magicWell",
	    funcName = "magicWell",
	    prompt={lang("mojing_1.1"),lang("mojing_1.2")},
	    touchTip = {lang("dafuweng_mofaquan1"),lang("dafuweng_mofaquan2"),lang("dafuweng_mofaquan3")},
	    },
	[GRID_TYPE.FINGER_GUESS] = {
		icon = "figerGuess",
		funcName = "fingerGuess",
		touchTip=lang("dafuweng_caiquan")},
	[GRID_TYPE.BATTLE] = {
		icon = "enemy",
		funcName = "battle",
		touchTip = {lang("dafuweng_guaiwu1"),lang("dafuweng_guaiwu2")}},
	[GRID_TYPE.WARPGATE_ENTER] = {
		icon = "warpGate",
		funcName = "warpGateEnter",
		touchTip=lang("dafuweng_chuansongmen1")},
	[GRID_TYPE.WARPGATE_EXIT] = {
		icon = "warpGate",
		funcName = "warpGateExit",
		prompt = {lang("chuansongmenchukou")},
		touchTip=lang("dafuweng_chuansongmen2")},
	[GRID_TYPE.AWARD_GEM] = {
		icon = "gem",
		funcName = "reward",
		touchTip=lang("dafuweng_zuanshi1")},
	[GRID_TYPE.AWARD_BIGGEM] = {
		icon = "bigGem",
		funcName = "reward",
		touchTip=lang("dafuweng_zuanshi2")},
	[GRID_TYPE.AWARD_GOLD] = {
		icon = "gold",
		funcName = "reward",
		touchTip=lang("dafuweng_huangjin")},
	[GRID_TYPE.AWARD_DICE] = {
		icon = "dice",
		funcName = "reward",
		touchTip=lang("dafuweng_touzi")},
	[GRID_TYPE.NULL] = {
		icon = "null",
		funcName = "null"},
}
