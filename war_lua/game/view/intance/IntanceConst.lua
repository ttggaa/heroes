--[[
    Filename:    IntanceConst.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-08-15 11:30:22
    Description: File description
--]]

IntanceConst = {}  


IntanceConst.MAX_VIEW_WIDTH_PIXEL = 20000
IntanceConst.MAX_VIEW_HEIGHT_PIXEL = 20000



IntanceConst.MAX_SCROLL_WIDTH_PIXEL = 1400
IntanceConst.MAX_SCROLL_HEIGHT_PIXEL = 1400


IntanceConst.FIRST_SECTION_ID = 71001

-- 引导自动切换到大地图关卡
IntanceConst.GUILDE_SWITCH_WORLD_STAGE_ID = 7100202


IntanceConst.FIRST_SECTION_FIRST_STAGE_ID = 7100101

IntanceConst.FIRST_SECTION_LAST_STAGE_ID = 7100105

-- 点击建筑直接进战斗的关卡ID
IntanceConst.QUICK_BATTLE_STAGE_ID = 7100102


IntanceConst.FIRST_RECHARGE_LIMIT_STAGE_ID = 7100209

--弹出活动面板
IntanceConst.LOGIN_ACTIVITY_LIMIT_STAGE_ID = 7100311

-- 战斗相关的常量
IntanceConst.MAX_SCREEN_WIDTH = MAX_SCREEN_WIDTH
IntanceConst.MAX_SCREEN_HEIGHT = MAX_SCREEN_HEIGHT

IntanceConst.MIN_SCENE_SCALE = 1
IntanceConst.MAX_SCENE_SCALE = IntanceConst.MIN_SCENE_SCALE * 2
        
IntanceConst.SCENE_SCALE_INIT = 1

-- 是否限制缩放边界值(仅针对windows鼠标滚轮)
IntanceConst.ENABLE_ADJUST_MAP_SCALE = true

IntanceConst.SHOW_POINT_X = IntanceConst.MAX_SCREEN_WIDTH * 0.22
IntanceConst.SHOW_POINT_Y = IntanceConst.MAX_SCREEN_HEIGHT * 0.5

IntanceConst.SHOW_POINT_X_GUIDE = 300
IntanceConst.SHOW_POINT_Y_GUIDE = 100

IntanceConst.MIN_VIEW_SCALE = IntanceConst.MAX_SCREEN_HEIGHT / IntanceConst.MAX_VIEW_HEIGHT_PIXEL
IntanceConst.MAX_VIEW_SCALE = IntanceConst.MIN_VIEW_SCALE * 2
IntanceConst.VIEW_SCALE_INIT = IntanceConst.MIN_VIEW_SCALE

IntanceConst.STAGE_BRANCH_STATE = 
{
	READY = 2,
	FINISH = 3
}

IntanceConst.STAGE_BRANCH_TYPE = {
	REWARD_ITEM = 1,
	REWARD_HERO = 2,
	REWARD_TEAM = 3,
	WAR = 4,
	REWARD_ITEM_TEAM = 5,
	TIP = 6,
    COST_TEAM = 7,
    COST_ITEM_CHIP = 8,
	STAR = 9,
	TALK = 10,
    HERO_ATTR = 11,
    CHOOSE_REWARD = 12,
    MARKET = 13,
}


IntanceConst.FINISH_WAR_TYPE = {
	FIRST_WAR = 1,
	FULL_STAR = 2,
	OTHER = 3,
}

-- 地图绿点最有一个点类型
IntanceConst.LAST_POINT_TYPE = {
	GENERAL = 1,
	PORTAL = 2
}

IntanceConst.GO_STAR_POINT = 0

IntanceConst.SHOW_NEXT_SECTION_TIP = true


IntanceConst.USE_SELECT_SECTION = "USE_SELECT_SECTION11"

IntanceConst.USE_SELECT_ELITE_SECTION = "USE_SELECT_ELITE_SECTION"

IntanceConst.USE_STORY_HERO_SECTION = "USE_STORY_HERO_SECTION"

IntanceConst.FORMATION_TIP_LVL_LIMIT = 7

IntanceConst.ELITE_FORMATION_TIP_LVL_LIMIT = 10

IntanceConst.CACHE_GUIDE_LEVEL_JUMP = 0

-- 是否是从材料点击进入副本
IntanceConst.QUICK_ENTER_BY_ITEM = false

-- 是否是从大世界点击进入副本
IntanceConst.QUICK_ENTER_BY_WORLD = false

--精英副本星星开启关卡数
IntanceConst.STAR_OPEN_PASS = 7200401

-- 临时变量,是否开启支线动画
IntanceConst.IS_OPEN_BRANCH_HERO_ATTR_ANIM = false


-- 特殊支线id
IntanceConst.SPECIAL_BRANCH_1_ID = 700001

IntanceConst.SPECIAL_BRANCH_2_ID = 700002

-- 副本升级到主界面会与部分功能引导冲突，所以增加参数控制是否激活下一章
IntanceConst.PAUSE_ACTIVATE = false