--[[
    Filename:    ArrowConst.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-09-27 21:00
    Description: 射箭游戏常量
--]]


ArrowConst = {}

ArrowConst.ARROW_TYPE = {
	COMMON = 1,
	SPECIAL = 2
}

ArrowConst.ARROW_FRIEND = {
    GAME = "game",
    PLAT = "plat"
}

--屏幕最多的箭数
ArrowConst.MAX_ARROW_NUM = 5

--左侧出位置
ArrowConst.APPEAR_LEFT_POS = -50

--右侧出位置
ArrowConst.APPEAR_RIGHT_POS = MAX_SCREEN_WIDTH + 50 

--左侧移除位置
ArrowConst.REMOVE_LEFT_POS = -100

--右侧移除位置
ArrowConst.REMOVE_RIGHT_POS = MAX_SCREEN_WIDTH + 100 

ArrowConst.ERROR_CODE = {
    [208]  = "箭矢不足",
    [3801] = "能量槽未满，不能使用激光箭",
    [3802] = "消耗与怪的血量不一致",
    [3803] = "同步数据，消耗箭矢参数有误",
    [3804] = "箭矢数量已达上限",
    [3805] = "补给时间未到",
    [3806] = "补给数量未配置",
    [3807] = "当前没有奖励可以领取",
    [3808] = "射箭奖励模板不存在",
    [3809] = "奖励领取中，请稍后操作", 
    [3810] = "箭的伤害值未配置",
    [3811] = "激光箭时效已过", 
    [3812] = "射箭怪物类型模板不存在",
    [3813] = "能量槽已满,请使用激光箭",    
    [3814]  = "普通箭数量有误",
    [3815] = "激光箭相关参数有误",
    [3816] = "普通箭相关参数有误",
    [3817] = "区域参数有误",
    [3818] = "激光箭时间参数不存在",
    [3819] = "射箭功能未开启",
    [3820] = "消耗箭矢数量超上限",
    [3821] = "对方不在同一联盟",
    [3822] = "射箭奖励模板不存在",
    [3823] = "今日送箭次数已用完", 
    [3824] = "对方被赠送次数已达上限",
    [3825] = "没有符合条件的联盟成员", 
    [3826] = "不能送给自己",
    [3827] = "送箭指定玩家参数不存在",   
    [3828] = "送箭奖励未配置", 
    [3829] = "送箭类型参数不存在",
    [3830] = "好友ID参数不存在", 
    [3831] = "已关注过该好友",
    [3832] = "不能关注自己",  
    [3833] = "已同步过数据, 主要用于弱网记录的reqId重复判断",
}