--[[
    Filename:    GuideBattleHelpConfig.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-01-18 13:08:43
    Description: File description
--]]
--[[=======================================================================================================
	参数说明

	delay 延迟时间
	unLock 事件结束后是否解锁
	ing 是否在点击屏幕的时候提示用户正在引导中, 默认false
	event 引导事件类型
		1. click 点击事件
				clickName 控件名称  全名称, 从传入界面搜起, 只要不是重名, 总会搜的到
				mask mask = {type = 1, scalex = 1, scaley = 1, x = 0, y = 0},
					type 1为圆形 2为方形 默认圆形 
					scalex x缩放 默认1.0
					scaley y缩放 默认1.0
					x x微调 默认0
					y y微调 默认0
				clickArea 点击区域微调 clickArea = {x = 0, y = 0, w = 0, h = 0},
					x x微调 默认0
					y y微调 默认0
					w 宽 默认为控件的宽
					h 高 默认为控件的高
				talk 提示文字 没有就不显示 talk = {str = "asdasdasd", x = 0, y = 0}
					str 文字
					x x微调 默认0 位置默认屏幕中心
					y y微调 默认0
				
				shouzhi 提示箭头 shouzhi = {angle = 0}
					angle 角度 0 - 360 默认0
					x x微调 默认0
					y y微调 默认0
		2. point 战斗界面点
				同1
		3. quick 快速释放技能
				camp 阵营1我方， 2敌方
				skillIndex 英雄技能数组下标
				beginP 开始坐标点
					x 坐标x
					y 坐标y
				endP 开始坐标点
					x 坐标x
					y 坐标y
		4. story  对话
				storyid = 1 对话id 详见 GuideStoryConfig
		5. jump 跳过战斗
		6. pause 暂停战斗
		7. resume 恢复战斗
		8. des 技能描述框专用
		9. manatip 耗蓝提示
		10. initcd 前置cd
				value 对应值
		11. initmana 前置魔法
				value 对应值
		12. camera 移动屏幕
				pt
			[3] = 	{
						{
							delay = 0, unLock = false,
							event = "camera",
							pt = {x = 700, y = 400, anim = 0.1}, 
						},
					},
---100_ 第一场
---1 普通战斗
---5 攻城战
=======================================================================================================]]--

local guideBattleHelpConfig = {
	ENABLE = true,
	DEBUG = true,
	["100_"] = {
			[3] =  {
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 1004,
						},
						{
							delay = 0, unLock = false,
							event = "resume",
						},
					},
			[14] =  {
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 1005,
						},
						{
							delay = 0, unLock = false,
							event = "resume",
						},
					},	
			[29] =  {
						{
						 	delay = 0, unLock = false,
						 	event = "quick",
							camp = 2, skillIndex = 2, beginP = {x = 1509, y = 279}, endP = {x = 689, y = 402},
						},
					},
			[36] =  {
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 1006,
						},
						{
							delay = 0, unLock = false,
							event = "resume",
						},
					},
			[40] =  {
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 1007,
						},
						{
							delay = 0, unLock = false,
							event = "resume",
						},
						{
						 	delay = 0, unLock = false,
						 	event = "quick",
							camp = 1, skillIndex = 2, beginP = {x = 900, y = 271}, endP = {x = 689, y = 402},
						},
					},
			[43] =  {
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 1008,
						},
						{
							delay = 0, unLock = false,
							event = "resume",
						},
						{
						 	delay = 0, unLock = false,
						 	event = "quick",
							camp = 1, skillIndex = 1, beginP = {x = 900, y = 271}, endP = {x = 689, y = 402},
						},
					},
			[48] =  {
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 1009,
						},
						{
							delay = 0, unLock = false,
							event = "resume",
						},
						{
						 	delay = 0, unLock = false,
						 	event = "quick",
							camp = 2, skillIndex = 1, beginP = {x = 932, y = 271}, endP = {x = 689, y = 402},
						},
					},		
				},
	["1_7100101"] = {
			[-1] =   {
						{
							delay = 0, unLock = false,
							event = "initcd", camp = 1, skillIndex = 1,value = 8,
						},
						{
							delay = 0, unLock = false,
							event = "initcd", camp = 1, skillIndex = 3,value = 12,
						},
						{
							delay = 0, unLock = true,
							event = "initmana", camp = 1, value = 18,
						},			
						{
							delay = 0, unLock = true,
							event = "lockSkill",
						},			
					},
			[1] =  {	
						{
						delay = 0, unLock = false,
						event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 105,
						},							
						{
						delay = 0, unLock = true,
						event = "resume",
						},							
					},
			[9] =  {
						{
							delay = 0, unLock = false,
							event = "camera",
							pt = {x = 1208.36, y = 456.59, anim = 0.1}, 
						},
						{
							delay = 0, unLock = true,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 12,
						},
						{
							delay = 0, unLock = false,
							event = "unlockSkill",
						},	
						{
							delay = 0, unLock = false,
							event = "manatip",
						},						
						{
							delay = 0, unLock = false,
							event = "click", clickName = "battle.BattleView.root.uiLayer.bottomLayer.icon_1",
							shouzhi = {angle = 270, x = -40 ,y=-24 ,cy =-24},
							clickArea = {x = 0, y = -20},
							talk = {str = "XINSHOUZHANDOU_02", x = -200, y = -100},	
							sound ="g17" ,						
						},
						{
							delay = 300, unLock = false,
							event = "point", point = {x = 1551, y = 525}, size = {w = 200, h = 200}, clickName = "battle.BattleView.guildeHelpMask",
							shouzhi = {angle = 270, x = -40 , y = 0 }, 								
						},	
						{
							delay = 0, unLock = true,
							event = "resume",
						},	
					},
			[11] =  {
						{
							delay = 0, unLock = true,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 13,
						},
						{
							delay = 0, unLock = true,
							event = "resume",
						},
					},										
				},
	["1_7100202"] = {
			[-1] =   {
						{
							delay = 0, unLock = false,
							event = "initcd", camp = 1, skillIndex = 4,value = 5,
						},
						{
							delay = 0, unLock = false,
							event = "initmana", camp = 1, value = 33,
						},
						{
							delay = 0, unLock = false,
							event = "initcd", camp = 1, skillIndex = 2,value = 8,
						},						
					},
			[1] =   {
				
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 106,
						},				
						{
							delay = 0, unLock = false,
							event = "resume",
						},							
					},	
			[6] =  {	
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 107,
						},
						{
							delay = 0, unLock = false,
							event = "click", clickName = "battle.BattleView.root.uiLayer.bottomLayer.icon_4",
							sound = "g111",	
							shouzhi = {angle = 270, x = -40},
							clickArea = {x = 0, y = -20},
						},
						{
							delay = 0, unLock = false,
							event = "point", point = {x = 1120, y = 420}, size = {w = 200, h = 200}, clickName = "battle.BattleView.guildeHelpMask",
							shouzhi = {},
							sound = "g112",	 							
						},						
						{
							delay = 0, unLock = true,
							event = "resume",
						},							
					},						
				},
	["1_7100206"] = {
			[1] =  {	
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 110,
						},				
						{
							delay = 0, unLock = true,
							event = "resume",
						},							
					},					
				},
	["5_7100102"] = {
			[6] =  {	
						{
							delay = 0, unLock = true,
						},							
					},	
			[15] =  {	
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 35,
						},				
						{
							delay = 0, unLock = true,
							event = "resume",
						},							
					},
			[26] =  {	
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 36,
						},	
						{
							delay = 0, unLock = true,
							event = "resume",
						},							
					},		
			[32] =  {	
						{
							delay = 0, unLock = false,
							event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "senglv",
						},		
						{
							delay = 0, unLock = true,
							event = "resume",
						},							
					},					
				},
	["5_7100415"] = {
			[1] =  {	
						{
						delay = 0, unLock = false,
						event = "pause",
						},
						{
							delay = 0, unLock = false,
							event = "story", storyid = 7100415,
						},							
						{
						delay = 0, unLock = true,
						event = "resume",
						},							
					},
				},
		--=======================================================================================================
} 
return guideBattleHelpConfig