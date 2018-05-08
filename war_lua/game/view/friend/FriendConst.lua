--[[
    Filename:    FriendConst.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-26 16:13
    Description: 好友系统
--]]

FriendConst = {}

FriendConst.FRIEND_TYPE = {
	PLATFORM = "platform",	--平台好友
	FRIEND = "friend",  	--好友
	ADD = "add",			--申请
	APPLY ="apply",			--添加
	DELETE = "delete",		--删除
	BLACK = "black",		--黑名单
	RECALL = "recall", 		 --好友召回
}

FriendConst.TEQUAN_TYPE = {
	wx_gamecenter = "tencentIcon_wxTequan.png",
	sq_gamecenter = "tencentIcon_qqTequan.png",
}

FriendConst.FRIEND_TOP_NUM = 100
FriendConst.FRIEND_PHY_TOP = 60

FriendConst.ERROR_CODE = {
	[3401] = "游戏好友已满",   --FRIEND_7
	[3402] = "游戏好友已存在",  --FRIEND_13
	[3403] = "要添加的游戏好友不存在",  
	[3404] = "对方申请列表已满",  
	[3405] = "已在对方申请列表中",  
	[3406] = "不在申请列表中",   
	[3407] = "对方不在你的申请列表中",  
	[3408] = "今日赠送次数已用完",  --FRIEND_12
	[3409] = "对方尚未领取", 
	[3410] = "今日已赠送过",  
	[3411] = "没有可领取的体力",  --FRIEND_14
	[3412] = "已领取",   --FRIEND_13
	[3413] = "今日领取次数已用完",  --FRIEND_14
	[3414] = "对方好友已满",  --FRIEND_6
	[3415] = "不能加入黑名单",  
	[3416] = "不能移除黑名单",  
	[3417] = "黑名单已满",  
	[3418] = "对方游戏好友已满",  --FRIEND_6
	[251] = "体力达到上限，无法领取体力"  

}