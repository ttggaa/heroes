--[[
    Filename:    ChatConst.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-04-01 14:41:31
    Description: File description
--]]
ChatConst = {}

ChatConst.CHAT_CHANNEL = 
{
	SYS = "sys",
	WORLD = "all",
	GUILD = "guild",
	PRIVATE = "pri",
	DEBUG = "debug",
	ARENA_NPC = "arena"
}

ChatConst.CELL_TYPE = {
	VOICE = "voice",   	--语音

	SYS1 = "sys",

	WORLD1 = "all",			
	WORLD2 = "replay",	--战斗回放 (竞技场)
	WORLD3 = "zhaomu",	--联盟招募
	WORLD4 = "guanfang",--官方消息

	GUILD1 = "guild",
	GUILD2 = "log",  	--联盟日志/红包/联盟地图战报
	GUILD3 = "famInvite",

	PRI1 = "pri",
	PRI2 = "debug",			--debug反馈
	PRI3 = "arena",			--竞技场npc
	PRI4 = "priReport", 	--好友切磋战报
	PRI5 = "priZhaomu", 	--联盟招募
	PRI6 = "fakePriZhaomu", --手动联盟招募（假npc）
}

ChatConst.BANNED_TYPE = {
	SYS = 1, 
	IDIP = 2,
}

--聊天信息上线
ChatConst.CHAT_MSG_MAX_LEN = 60
--私聊左侧显示玩家上限
ChatConst.CHAT_PRIVATE_USER_MAX_LEN = 5
--debug功能是否关闭
ChatConst.IS_DEBUG_OPEN = true 
 
--备注 
--[[

1 聊天上限控制：
当前聊天页面控制 + push消息非当前页model控制 

2 tableView：
chatView: DOWN_TOP （cell最底下为下标1）
chatPrivateView: DOWN_TOP

3 进游戏加载的数据
联盟 + 私聊 + 黑名单

]]




