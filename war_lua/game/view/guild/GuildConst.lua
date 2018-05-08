--[[
    Filename:    GuildConst.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-14 21:04:43
    Description: File description
--]]

GuildConst = {}

GuildConst.BUTTON_INPUT = 12

GuildConst.ELEMENT_EVENT_TYPE = 
{
    GIVING = 1,             --1：直接领取奖励
    EXCHANGE = 2,           --2：兑换奖励
    BUFFER = 3,             --3：直接获得buff
    FOG = 4,                --4：散迷雾
    ELAPSED_REWARD = 5,     --5：读条获得奖励
    ELAPSED_BUFFER = 6,     --6：读条获得BUFF
    OUTPUT_GOLD  = 7,       --7：金矿、招募点（联盟）
    PVE = 8,                --8：pve战斗
    STORY = 9,              --9：PVE战斗
    PORTAL = 10,            --10：传送门
    BORDER = 11,            --11：边境大门
    TENT  = 12,             --12：首领帐篷
    OBELISK   = 13,         --13：方尖塔
    CITY  = 14,             --14：城池
    DOOR  = 15,             --15：大门
    UNDERGROUND_CITY = 16,  --16：地下城入口
    PORTAL_POINT = 17,      --17：传送门地图内
    TRIGGER_TASK = 18,      --18: 先知小屋
    NPC = 19,               --19: 学者npc
    TEAM_RECRUIT = 20,      --20: 怪物招募
    TEAM_ESCAPE = 21,       --21: 怪物逃跑
    TEAM_JOIN = 22,         --22: 怪物加入
    XUEZHE_BOX = 23,        --23: 先知宝箱
    SPHINX_AQ = 24,         --24: 斯芬克斯答题
    FAM = 25,				--25: 联盟秘境
	YEAR = 26,				--26：新年使者
	OFFICER = 27,			--27：指挥官
	MATERIAL = 28,			--28：军需官
}

GuildConst.ELEMENT_TYPE = 
{
    GUILD = "guild", -- 公会点
    COMMON = "common", -- 公共点
    MY = "my", -- 个人点
}

GuildConst.TASK_TYPE = 
{
    GUILD_MAP_ST_ROLE_REWARD = 1,       --个人点资源
    GUILD_MAP_ST_ROLE_KILL_NPC = 2,     --杀死npc
    GUILD_MAP_ST_GLOBAL_AC_TENT = 3,    --激活联盟帐篷
    GUILD_MAP_ST_ROLE_GO_OTHER = 4,     --去别人家地图
    GUILD_MAP_ST_GLOBAL_AC_TOWER= 5,    --激活方尖塔
    GUILD_MAP_ST_KILL_PVP_NUM = 6,      --联盟击杀敌人（PVP）数量
    GUILD_MAP_ST_FIND_XUEZHE = 7,       --寻找学者
    GUILD_MAP_ST_FIND_BOX = 8,          --寻找宝箱
} 

GuildConst.GUILD_MAP_RESULT_CODE = 
{
    GUILD_MAP_POINT_DIS             = 3001,  --目标点为不可行走区域不可移动
    GUILD_MAP_POINT_FUNC            = 3002,  --目标点有物点不可移动
    GUILD_MAP_POWER_NOT_ENOUGH      = 3003,  --工会行动点不足
    GUILD_MAP_NOT_UP                = 3004,  --地图无更新
    GUILD_THING_DIS                 = 3005,  --物点已被采集消失
    GUILD_THING_TYPE_ERROR          = 3006,  --物点类型错误
    GUILD_THING_REWARD_CANNOT_GET   = 3007,  --时间未到或奖励不可领
    GUILD_THING_REWARD_READING      = 3008,  --正在读条
    GUILD_THING_REWARD_NOT_READING  = 3009,  --尚未读条
    GUILD_THING_MINE_HADAC          = 3010,  --金矿激活
    GUILD_THING_MINE_NOT_AC         = 3011,  --金矿没激活不可攻击
    GUILD_THING_MINE_HAD_ROB        = 3013,  --已掠夺过不可重复掠夺
    GUILD_THING_MINE_ROBING         = 3014,  --正在掠夺
    GUILD_THING_CANNOT_CANCEL_READ  = 3015,  --不能取消读条
    GUILD_MAP_USER_LOCK             = 3016,  --玩家被锁定不能移动
    GUILD_MAP_NOT_YOUTENT           = 3017,  --不是你们家帐篷
    GUILD_MAP_TENT_HAD_AC           = 3018,  --已激活
    GUILD_MAP_NOT_YOUGOLD           = 3019,  --不是你们家金矿
    GUILD_MAP_RENEW                 = 3020,  --工会地图日常更新维护
    GUILD_MAP_NOT_EXIST             = 3021,  --地图数据不存在
    GUILD_MAP_PVE_NOT_EXIST         = 3022,  --战斗点不存在
    GUILD_MAP_PVP_USER_NOT_EXIST    = 3023,  --敌方玩家不存在
    GUILD_MAP_SWITCH_MAP            = 3024,  --切换地图
    GUILD_THING_MINE_NOT_ROBING     = 3025,  --不在抢夺读条
    GUILD_THING_MINE_ROBING_OVER    = 3026,  --抢夺读条结束
    GUILD_THING_MINE_TIMEING        = 3027,  --金矿抢夺读条时间未到
    GUILD_THING_MINE_SELF           = 3028,  --自家工会不能抢夺
    GUILD_CENTER_CITY_HAD_ENEMY     = 3029,  --有敌人驻守
    GUILD_CENTER_MAP_NOTIN          = 3030,  --不在中心地图中
    GUILD_CENTER_CITY_NOT_EXIST     = 3031,  --城点不存在
    GUILD_CENTER_CITY_HAD_LEAVE     = 3032,  --您已离开城池
    GUILD_MAP_POINT_MEMLOCK         = 3033,  --地图目标点锁定中,请稍后重试
    GUILD_MAP_POINT_MEMLOCK         = 3033,  --地图目标点锁定中,请稍后重试
    GUILD_MAP_POINT_MEMLOCK         = 3034,  --目标玩家未锁定物点
    GUILD_MAP_CAN_MOVE_TOHERE       = 3035,  --不能移动或操作到该点
    GUILD_MAP_REPLACE_GUILD         = 3037,  --假公会替换成镇工会
	GUILD_MAP_CANNOT_ATK_SELFGUILD  = 3040, --不能攻击相同工会玩家
    GUILD_MAP_SECRETLAND_NOT_EXIST  = 3041, --联盟秘境不存在
    GUILD_MAP_SECRETLAND_IS_ATTAKED = 3042, --联盟秘境正在被其他人攻击
    GUILD_MAP_SECRETLAND_TYPE_ERROR = 3043, --联盟秘境类型错误
    GUILD_MAP_SECRETLAND_HAS_BEEN_KILLED = 3044, --联盟秘境已被其他人击败或完成
    GUILD_MAP_SECRETLAND_CAN_ONLY_KILL_ONE = 3045, --联盟秘境中每个玩家只能击败一只怪物或完成一个任务
    GUILD_MAP_SECRETLAND_CAN_ONLY_KILL_FIVE_A_DAY = 3046, --联盟秘境每个玩家每天只能击败5只怪物或者完成五次任务
    GUILD_MAP_NOT_INIT              = 3047, --尚未进行联盟初始化未正常进入联盟
}

GuildConst.GUILD_MAP_RESULT_CODE_TIP =
{
    [3001] = "目标点为不可行走区域不可移动",
    [3002] = "目标点不可移动",
    [3003] = "行动力不足",
    [3004] = "地图无更新",
    [3005] = "目标点已被采集",
    [3006] = "数据不匹配",
    [3007] = "时间未到或奖励不可领",
    [3008] = "占领中",
    [3009] = "尚未读条",
    [3010] = "金矿激活",
    [3011] = "金矿没激活不可攻击",
    [3013] = "今日已掠夺，请明日再来",
    [3014] = "掠夺中",
    [3015] = "不能取消读条",
    [3016] = "正在占领奖励/buff公共点，不能移动",
    [3017] = "不是你们家帐篷",
    [3018] = "已激活",
    [3019] = "不是你们家金矿",
    [3021] = "地图数据不存在",
    [3022] = "战斗点不存在",
    [3023] = "敌方玩家不存在",
    [3024] = "切换地图",
    [3025] = "正在掠夺敌方该联盟矿，不能移动",
    [3026] = "抢夺读条结束",
    [3027] = "金矿抢夺读条时间未到",
    [3028] = "自家工会不能抢夺",
    [3029] = "有敌人驻守",
    [3030] = "不在中心地图中",
    [3031] = "城点不存在",
    [3032] = "您已离开城池",
    [3033] = "地图目标点锁定中,请稍后重试",
    [3034] = "目标玩家未锁定物点",
    [3035] = "不能移动或操作到该点",
    [3036] = "该联盟不可抢夺",
    [3037] = "踢玩家到联盟主界面",
}

--新年使者类型
GuildConst.YEAR_TYPE = {
	REWARD = 1001,
	PEERBUFF = 2001,
	SKIP_MAP = 3001,
	GET_POWER = 3002,
	MISS_FOG = 3003
}

-- 袁天使看这里调参数
GuildConst.TAKE_PHOTO = false  -- 是否拍照


if not OS_IS_WINDOWS then
    GuildConst.HIDE_FOG = false  -- 是否隐藏迷雾

    GuildConst.SHOW_TIP_GRID = false -- 是否显示网格

    GuildConst.SHOW_NOT_GO_GRID = false -- 是否显示不允许通过的往过

    GuildConst.SHOW_GRID_ID = false -- 是否显示格子ID

    GuildConst.SHOW_ELE_ID = false -- 是否元素id
else

    GuildConst.HIDE_FOG = false  -- 是否隐藏迷雾

    GuildConst.SHOW_TIP_GRID = false -- 是否显示网格

    GuildConst.SHOW_NOT_GO_GRID = false -- 是否显示不允许通过的往过

    GuildConst.SHOW_GRID_ID = false -- 是否显示格子ID

    GuildConst.SHOW_ELE_ID = false -- 是否元素id    
end


GuildConst.GUILD_MAP_MINI_MAX_WIDTH = 2048

GuildConst.GUILD_MAP_MINI_MAX_HEIGHT = 1057
