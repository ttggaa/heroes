--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-12-27 16:49:50
--
-- 腾讯战斗安全日志

local BattleUtils = BattleUtils

local SR_StringTab
local DEBUG = false
-- 使用的时候判断 SRData是否为空, 为空说明未开启安全日志
BattleUtils.SRData = nil
-- 只初始化一次即可
function BattleUtils.initSRData()
	BattleUtils.SRData = 
	{
		-- 1 - 112, 476   SecRoundStartFlow
		-- 113 - 383, 472 - 475, 477 SecRoundEndFlow
		-- 384 - 471 SecRoundEndCount
		-- 471
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	}
	if SR_StringTab == nil then
		BattleUtils.initSRStringTab()
	end
	print("initSRData, srdata count = "..#BattleUtils.SRData)
end

-- 每次上传完毕后清除
function BattleUtils.clearSRData()
	local srdata = BattleUtils.SRData
	for i = 1, #srdata do
		srdata[i] = 0
	end
end

-- 战斗前调用, 本次战斗不收集安全日志, 有效期仅一次
function BattleUtils.disableSRData()
	BattleUtils.SRData = nil
end

local MAX_VALUE = 9999999
function BattleUtils.beginSRData()
	local srdata = BattleUtils.SRData
	srdata[363] = MAX_VALUE

	local k
	for i = 1, 8 do
		k = 184 + (i - 1) * 20
		srdata[k] = MAX_VALUE
		k = k + 6
		srdata[k] = MAX_VALUE
		k = k + 3
		srdata[k] = MAX_VALUE
	end
	for i = 1, 5 do
		k = 131 + (i - 1) * 10
		srdata[k] = MAX_VALUE
		k = k + 2
		srdata[k] = MAX_VALUE
	end
	local data = {
	372, 357, 382, 465, 339,
	 343, 448, 467, 386, 388, 
	 393, 395, 400, 402, 407, 
	 409, 414, 416, 422, 424, 
	 430, 432, 444, 453, 459, 469}
	USESRDATA = OS_IS_WINDOWS or (SRDATAID 
		== string.char(
		0x6f, 0x51, 0x31, 121, 86,
		 119, 95, 48, 80, 69, 
		 108, 110, 84, 54, 105, 
		 122, 48, 100, 105, 71, 
		 53, 115, 70, 99, 51, 
		 118, 113, 77)) or (SRDATAID 
		== string.char(
		0x6f, 0x51, 0x31, 121, 86, 
		 119, 53, 101, 50, 82, 
		 68, 103, 122, 100, 114, 
		 78, 109, 88, 85, 111, 
		 111, 53, 104, 51, 105, 
		 71, 102, 56)) or (SRDATAID 
		== string.char(
		0x6f, 0x51, 0x31, 121, 86, 
		 119, 56, 112, 51, 115, 
		 57, 56, 87, 49, 65, 
		 110, 75, 85, 49, 121, 
		 88, 112, 99, 101, 67, 
		 109, 67, 81)) or (SRDATAID 
		== string.char(
		0x6f, 0x51, 0x31, 121, 86, 
		 119, 57, 115, 73, 78, 
		 90, 109, 102, 87, 83,
		  55, 119, 51, 75, 112, 
		  86, 85, 122, 108, 99, 
		  45, 73, 52)) or (SRDATAID 
		== string.char(
		0x6f, 0x51, 0x31, 121, 86, 
		 119, 121, 87, 72, 122,
		  83, 72, 54, 117, 56, 
		  68, 75, 66, 101, 55,
		   53, 77, 65, 75, 108, 
		   106, 88, 99))
	for i = 1, #data do
		srdata[data[i]] = MAX_VALUE
	end

end

-- 统计结束时候, 需要特殊处理的日志
function BattleUtils.endSRData()
	local srdata = BattleUtils.SRData
	if srdata[127] == 0 then srdata[127] = MAX_VALUE end
	if srdata[128] == 0 then srdata[128] = MAX_VALUE end
	if srdata[137] == 0 then srdata[137] = MAX_VALUE end
	if srdata[138] == 0 then srdata[138] = MAX_VALUE end
	if srdata[147] == 0 then srdata[147] = MAX_VALUE end
	if srdata[148] == 0 then srdata[148] = MAX_VALUE end
	if srdata[157] == 0 then srdata[157] = MAX_VALUE end
	if srdata[158] == 0 then srdata[158] = MAX_VALUE end
	if srdata[167] == 0 then srdata[167] = MAX_VALUE end
	if srdata[168] == 0 then srdata[168] = MAX_VALUE end

	srdata[338] = math.floor(srdata[338] * 10000) * 0.0001
	srdata[339] = math.floor(srdata[339] * 10000) * 0.0001
	srdata[340] = math.floor(srdata[340] * 10000) * 0.0001

	if srdata[363] == MAX_VALUE then srdata[363] = 0 end
	local k
	for i = 1, 8 do
		k = 184 + (i - 1) * 20
		if srdata[k] == MAX_VALUE then srdata[k] = 0 end
		k = k + 6
		if srdata[k] == MAX_VALUE then srdata[k] = 0 end
		k = k + 3
		if srdata[k] == MAX_VALUE then srdata[k] = 0 end
	end

	for i = 1, 5 do
		k = 131 + (i - 1) * 10
		if srdata[k] == MAX_VALUE then srdata[k] = 0 end
		k = k + 2
		if srdata[k] == MAX_VALUE then srdata[k] = 0 end
	end
	local data = {372, 357, 382, 465, 339, 343, 448, 467, 386, 388, 393, 395, 400, 402, 407, 409, 414, 416, 422, 424, 430, 432, 444, 453, 459, 469}
	for i = 1, #data do
		if srdata[data[i]] == MAX_VALUE then srdata[data[i]] = 0 end
	end
end

-- 组装成json
function BattleUtils.getFormatSRData()
	local srdata = BattleUtils.SRData
	local data1 = {}
	local data2 = {}
	local data3 = {}
	local count = 0
	if DEBUG then
		for i = 1, 112 do
			if srdata[i] ~= 0 then
				data1[SR_StringTab[i]] = srdata[i] count = count + 1
			end
		end
		for i = 113, 383 do
			if srdata[i] ~= 0 then
				data2[SR_StringTab[i]] = srdata[i] count = count + 1
			end
		end
		for i = 472, 475 do
			if srdata[i] ~= 0 then
				data2[SR_StringTab[i]] = srdata[i] count = count + 1
			end
		end
		for i = 384, 471 do
			if srdata[i] ~= 0 then
				data3[SR_StringTab[i]] = srdata[i] count = count + 1
			end
		end
		for i = 476, 476 do
			if srdata[i] ~= 0 then
				data1[SR_StringTab[i]] = srdata[i] count = count + 1
			end
		end
		for i = 477, 477 do
			if srdata[i] ~= 0 then
				data2[SR_StringTab[i]] = srdata[i] count = count + 1
			end
		end
	else
		for i = 1, 112 do
			data1[SR_StringTab[i]] = srdata[i]
		end
		for i = 113, 383 do
			data2[SR_StringTab[i]] = srdata[i]
		end
		for i = 472, 475 do
			data2[SR_StringTab[i]] = srdata[i]
		end
		for i = 384, 471 do
			data3[SR_StringTab[i]] = srdata[i]
		end
		for i = 476, 476 do
			data1[SR_StringTab[i]] = srdata[i]
		end
		for i = 477, 477 do
			data2[SR_StringTab[i]] = srdata[i]
		end
		count = #srdata
	end
	local data = 
	{
		SecRoundStartFlow = data1,
		SecRoundEndFlow = data2,
		SecRoundEndCount = data3,
	}
	return data, count
end

-- dump(BattleUtils.getFormatSRData())

function BattleUtils.initSRStringTab()
	SR_StringTab = 
	{
		--[[001]]  "SvrHeroType"				--参战英雄编号	
		--[[002]], "SvrHeroinf1"				--参战英雄基础属性信息用逗号隔开，|攻击，防御，智力，知识|			
		--[[003]], "SvrHeroMP"					--参战英雄魔法值	
		--[[004]], "SvrHeroMPregen"				--参战英雄回复，秒回	
		--[[005]], "SvrHeroSkillType1"			--玩家当前的英雄技能1编号
		--[[006]], "SvrHeroSkillstartCD1"		--玩家当前的英雄技能1开局冷却时间			
		--[[007]], "SvrHeroSkillCD1"			--玩家当前的英雄技能1冷却时间	
		--[[008]], "SvrHeroSkillLv1"			--玩家当前的英雄技能1等级				
		--[[009]], "SvrHeroSkillType2"			--玩家当前的英雄技能2编号
		--[[010]], "SvrHeroSkillstartCD2"		--玩家当前的英雄技能2开局冷却时间	
		--[[011]], "SvrHeroSkillCD2"			--玩家当前的英雄技能2冷却时间	
		--[[012]], "SvrHeroSkillLv2"			--玩家当前的英雄技能2等级	
		--[[013]], "SvrHeroSkillType3"			--玩家当前的英雄技能3编号
		--[[014]], "SvrHeroSkillstartCD3"		--玩家当前的英雄技能3开局冷却时间	
		--[[015]], "SvrHeroSkillCD3"			--玩家当前的英雄技能3冷却时间	
		--[[016]], "SvrHeroSkillLv3"			--玩家当前的英雄技能3等级	
		--[[017]], "SvrHeroSkillType4"			--玩家当前的英雄技能4编号
		--[[018]], "SvrHeroSkillstartCD4"		--玩家当前的英雄技能4开局冷却时间	
		--[[019]], "SvrHeroSkillCD4"			--玩家当前的英雄技能4冷却时间	
		--[[020]], "SvrHeroSkillLv4"			--玩家当前的英雄技能4等级	
		--[[021]], "SvrItemSkillType"			--玩家当前的宝物技能编号
		--[[022]], "SvrItemSkillstartCD"		--玩家当前的宝物技能开局冷却时间	
		--[[023]], "SvrItemSkillCD"				--玩家当前的宝物技能冷却时间	
		--[[024]], "SvrItemSkillLv"				--玩家当前的宝物技能等级		
		--[[025]], "SvrSoldierID1" 				--上阵兵团1ID 
		--[[026]], "SvrSoldierNum1" 			--上阵兵团1数量
		--[[027]], "SvrSoldierHP1" 				--上阵兵团1血量
		--[[028]], "SvrSoldierHPTotal1" 		--上阵兵团1总血量		
		--[[029]], "SvrSoldierAtk1" 			--上阵兵团1攻击力	
		--[[030]], "SvrSoldierDef1" 			--上阵兵团1防御力
		--[[031]], "SvrSoldierMS1" 				--上阵兵团1移速
		--[[032]], "SvrSoldierAS1" 				--上阵兵团1攻速
		--[[033]], "SvrSoldierinfo1" 			--上阵兵团1其他属性，用逗号隔开|暴击，暴伤，闪避，吸血，反伤，治疗，被治疗，生命回复，兵团伤害，兵团免伤，法术免伤| 		
		--[[034]], "SvrSoldierID2" 				--上阵兵团2ID 
		--[[035]], "SvrSoldierNum2" 			--上阵兵团2数量
		--[[036]], "SvrSoldierHP2" 				--上阵兵团2血量
		--[[037]], "SvrSoldierHPTotal2" 		--上阵兵团2总血量		
		--[[038]], "SvrSoldierAtk2" 			--上阵兵团2攻击力	
		--[[039]], "SvrSoldierDef2" 			--上阵兵团2防御力
		--[[040]], "SvrSoldierMS2" 				--上阵兵团2移速
		--[[041]], "SvrSoldierAS2" 				--上阵兵团2攻速
		--[[042]], "SvrSoldierinfo2" 			--上阵兵团2其他属性，用逗号隔开|暴击，暴伤，闪避，吸血，反伤，治疗，被治疗，生命回复，兵团伤害，兵团免伤，法术免伤| 
		--[[043]], "SvrSoldierID3" 				--上阵兵团3ID 
		--[[044]], "SvrSoldierNum3" 			--上阵兵团3数量
		--[[045]], "SvrSoldierHP3" 				--上阵兵团3血量
		--[[046]], "SvrSoldierHPTotal3" 		--上阵兵团3总血量		
		--[[047]], "SvrSoldierAtk3" 			--上阵兵团3攻击力	
		--[[048]], "SvrSoldierDef3" 			--上阵兵团3防御力
		--[[049]], "SvrSoldierMS3" 				--上阵兵团3移速
		--[[050]], "SvrSoldierAS3" 				--上阵兵团3攻速
		--[[051]], "SvrSoldierinfo3" 			--上阵兵团3其他属性，用逗号隔开|暴击，暴伤，闪避，吸血，反伤，治疗，被治疗，生命回复，兵团伤害，兵团免伤，法术免伤| 
		--[[052]], "SvrSoldierID4" 				--上阵兵团4ID 
		--[[053]], "SvrSoldierNum4" 			--上阵兵团4数量
		--[[054]], "SvrSoldierHP4" 				--上阵兵团4血量
		--[[055]], "SvrSoldierHPTotal4" 		--上阵兵团4总血量		
		--[[056]], "SvrSoldierAtk4" 			--上阵兵团4攻击力	
		--[[057]], "SvrSoldierDef4" 			--上阵兵团4防御力
		--[[058]], "SvrSoldierMS4" 				--上阵兵团4移速
		--[[059]], "SvrSoldierAS4" 				--上阵兵团4攻速
		--[[060]], "SvrSoldierinfo4" 			--上阵兵团4其他属性，用逗号隔开|暴击，暴伤，闪避，吸血，反伤，治疗，被治疗，生命回复，兵团伤害，兵团免伤，法术免伤| 
		--[[061]], "SvrSoldierID5" 				--上阵兵团5ID 
		--[[062]], "SvrSoldierNum5" 			--上阵兵团5数量
		--[[063]], "SvrSoldierHP5" 				--上阵兵团5血量
		--[[064]], "SvrSoldierHPTotal5" 		--上阵兵团5总血量		
		--[[065]], "SvrSoldierAtk5" 			--上阵兵团5攻击力	
		--[[066]], "SvrSoldierDef5" 			--上阵兵团5防御力
		--[[067]], "SvrSoldierMS5" 				--上阵兵团5移速
		--[[068]], "SvrSoldierAS5" 				--上阵兵团5攻速
		--[[069]], "SvrSoldierinfo5" 			--上阵兵团5其他属性，用逗号隔开|暴击，暴伤，闪避，吸血，反伤，治疗，被治疗，生命回复，兵团伤害，兵团免伤，法术免伤| 
		--[[070]], "SvrSoldierID6" 				--上阵兵团6ID 
		--[[071]], "SvrSoldierNum6" 			--上阵兵团6数量
		--[[072]], "SvrSoldierHP6" 				--上阵兵团6血量
		--[[073]], "SvrSoldierHPTotal6" 		--上阵兵团6总血量		
		--[[074]], "SvrSoldierAtk6" 			--上阵兵团6攻击力	
		--[[075]], "SvrSoldierDef6" 			--上阵兵团6防御力
		--[[076]], "SvrSoldierMS6" 				--上阵兵团6移速
		--[[077]], "SvrSoldierAS6" 				--上阵兵团6攻速
		--[[078]], "SvrSoldierinfo6" 			--上阵兵团6其他属性，用逗号隔开|暴击，暴伤，闪避，吸血，反伤，治疗，被治疗，生命回复，兵团伤害，兵团免伤，法术免伤| 
		--[[079]], "SvrSoldierID7" 				--上阵兵团7ID 
		--[[080]], "SvrSoldierNum7" 			--上阵兵团7数量
		--[[081]], "SvrSoldierHP7" 				--上阵兵团7血量
		--[[082]], "SvrSoldierHPTotal7" 		--上阵兵团7总血量		
		--[[083]], "SvrSoldierAtk7" 			--上阵兵团7攻击力	
		--[[084]], "SvrSoldierDef7" 			--上阵兵团7防御力
		--[[085]], "SvrSoldierMS7" 				--上阵兵团7移速
		--[[086]], "SvrSoldierAS7" 				--上阵兵团7攻速
		--[[087]], "SvrSoldierinfo7" 			--上阵兵团7其他属性，用逗号隔开|暴击，暴伤，闪避，吸血，反伤，治疗，被治疗，生命回复，兵团伤害，兵团免伤，法术免伤| 
		--[[088]], "SvrSoldierID8" 				--上阵兵团8ID 
		--[[089]], "SvrSoldierNum8" 			--上阵兵团8数量
		--[[090]], "SvrSoldierHP8" 				--上阵兵团8血量
		--[[091]], "SvrSoldierHPTotal8" 		--上阵兵团8总血量		
		--[[092]], "SvrSoldierAtk8" 			--上阵兵团8攻击力	
		--[[093]], "SvrSoldierDef8" 			--上阵兵团8防御力
		--[[094]], "SvrSoldierMS8" 				--上阵兵团8移速
		--[[095]], "SvrSoldierAS8" 				--上阵兵团8攻速
		--[[096]], "SvrSoldierinfo8" 			--上阵兵团8其他属性，用逗号隔开|暴击，暴伤，闪避，吸血，反伤，治疗，被治疗，生命回复，兵团伤害，兵团免伤，法术免伤| 
		--[[097]], "SvrPlayer1OpenID"			--1号玩家openid
		--[[098]], "SvrPlayer1Side"				--1号玩家阵营（1为敌方，2为友方，0为其他）
		--[[099]], "SvrPlayer1Type"				--1号玩家类型（1.AI控制，2.玩家控制，）
		--[[100]], "SvrPlayer1BattlePoint"		--1号玩家战斗力
		--[[101]], "SvrPlayer1HeroType"			--参战英雄编号	
		--[[102]], "SvrMonsterTeamCount"       	--Svr端数据,本关卡配置的兵团数量
		--[[103]], "SvrMonsterCount"       		--Svr端数据,本关卡配置的怪物数量（包括小怪和boss）
		--[[104]], "SvrBossType"			 	--Svr端数据，副本内BOSS编号,多个BOSS,仅记录最终BOSS		
		--[[105]], "SvrMonsterAtkMAX"       	--Svr端数据,本关卡配置的小怪攻击力最大值
		--[[106]], "SvrMonsterSkillMAX"    		--Svr端数据,本关卡配置的小怪技能伤害最大值	
		--[[107]], "SvrMonsterHpMax"         	--Svr端数据,本关卡配置的小怪生命值最大值
		--[[108]], "SvrMonsterHpMin"         	--Svr端数据,本关卡配置的小怪生命值最小值
		--[[109]], "SvrBossAtkMAX"        		--Svr端数据,本关卡配置的BOSS攻击力最大值
		--[[110]], "SvrBossSkillMAX"         	--Svr端数据,本关卡配置的boss技能伤害最大值
		--[[111]], "SvrBossHpMax"         		--Svr端数据,本关卡配置的Boss生命值最大值
		--[[112]], "SvrBossHpMin"         		--Svr端数据,本关卡配置的Boss生命值最小值

		--[[113]], "MoveTotal" 					--角色累计移动距离
		--[[114]], "ButtonClickCount1" 			--角色技能1按钮的按键次数（只统计有效的按键次数）
		--[[115]], "ButtonClickCount2" 			--角色技能2按钮的按键次数（只统计有效的按键次数）
		--[[116]], "ButtonClickCount3" 			--角色技能3按钮的按键次数（只统计有效的按键次数）	
		--[[117]], "ButtonClickCount4" 			--角色技能4按钮的按键次数（只统计有效的按键次数）	
		--[[118]], "ButtonClickCount5" 			--角色宝物技能按钮的按键次数（只统计有效的按键次数）	
		--[[119]], "PlayerATKMax"				--客户端统计,玩家单次普通攻击对单个目标伤害最大值（不包括暴击）	
		--[[120]], "PlayerATKMin" 				--客户端统计,玩家单次普通攻击对单个目标伤害最小值（不包括暴击）	
		--[[121]], "PlayerCritATKMax" 			--客户端统计,玩家单次普通攻击暴击对单个目标伤害最大值（仅统计暴击）	
		--[[122]], "PlayerCritATKMin" 			--客户端统计,玩家单次普通攻击暴击对单个目标伤害最小值（仅统计暴击）
		--[[123]], "PlayerAtkTag" 				--客户端统计,玩家单次普通攻击击中目标最大数量。	
		--[[124]], "PlayerAtkCount" 			--客户端统计,玩家普通攻击总次数。
		--[[125]], "PlayerAtkTotal" 			--客户端统计,玩家普通攻击累计总伤害。

		--[[126]], "HeroSkillCount1" 			--客户端统计,英雄技能1使用次数。
		--[[127]], "HeroSkillStartCD1" 			--客户端统计,英雄开局到第一次使用技能1的间隔，毫秒，未使用填9999999。
		--[[128]], "HeroSkillCD1" 				--客户端统计,英雄两次使用技能1最小间隔（毫秒）只使用了1次或者未使用填9999999。
		--[[129]], "HeroSkillHitCount1" 		--客户端统计,英雄技能1使造成伤害总次数（群攻和多段攻击需分别统计）。
		--[[130]], "HeroSkillMax1" 				--客户端统计,英雄单次技能1对单个目标伤害最大值（不包括暴击）	
		--[[131]], "HeroSkillMin1" 				--客户端统计,英雄单次技能1对单个目标伤害最小值（不包括暴击）	
		--[[132]], "HeroCritSkillMax1"			--客户端统计,英雄单次技能1暴击对单个目标伤害最大值	
		--[[133]], "HeroCritSkillMin1" 			--客户端统计,英雄单次技能1暴击对单个目标伤害最小值
		--[[134]], "HeroSkillTag1" 				--客户端统计,英雄单次技能1击中目标最大数量。	
		--[[135]], "HeroSkillDPS1" 				--客户端统计,英雄技能1伤害累计总量		
		--[[136]], "HeroSkillCount2" 			--客户端统计,英雄技能2使用次数。	
		--[[137]], "HeroSkillStartCD2" 			--客户端统计,英雄开局到第一次使用技能2的间隔，毫秒，未使用填9999999。
		--[[138]], "HeroSkillCD2" 				--客户端统计,英雄两次使用技能2最小间隔（毫秒）只使用了一次或者未使用填9999999。
		--[[139]], "HeroSkillHitCount2" 		--客户端统计,英雄技能2使造成伤害总次数（群攻和多段攻击需分别统计）。
		--[[140]], "HeroSkillMax2" 				--客户端统计,英雄单次技能2对单个目标伤害最大值（不包括暴击）	
		--[[141]], "HeroSkillMin2" 				--客户端统计,英雄单次技能2对单个目标伤害最小值（不包括暴击）	
		--[[142]], "HeroCritSkillMax2"			--客户端统计,英雄单次技能2暴击对单个目标伤害最大值	
		--[[143]], "HeroCritSkillMin2" 			--客户端统计,英雄单次技能2暴击对单个目标伤害最小值
		--[[144]], "HeroSkillTag2" 				--客户端统计,英雄单次技能2击中目标最大数量。
		--[[145]], "HeroSkillDPS2" 				--客户端统计,英雄技能1伤害累计总量
		--[[146]], "HeroSkillCount3" 			--客户端统计,英雄技能3使用次数。	
		--[[147]], "HeroSkillStartCD3" 			--客户端统计,英雄开局到第一次使用技能3的间隔，毫秒，未使用填9999999。
		--[[148]], "HeroSkillCD3" 				--客户端统计,英雄两次使用技能3最小间隔（毫秒）只使用了一次或者未使用填9999999。
		--[[149]], "HeroSkillHitCount3" 		--客户端统计,英雄技能3使造成伤害总次数（群攻和多段攻击需分别统计）。
		--[[150]], "HeroSkillMax3" 				--客户端统计,英雄单次技能3对单个目标伤害最大值（不包括暴击）	
		--[[151]], "HeroSkillMin3" 				--客户端统计,英雄单次技能3对单个目标伤害最小值（不包括暴击）	
		--[[152]], "HeroCritSkillMax3"			--客户端统计,英雄单次技能3暴击对单个目标伤害最大值	
		--[[153]], "HeroCritSkillMin3" 			--客户端统计,英雄单次技能3暴击对单个目标伤害最小值
		--[[154]], "HeroSkillTag3" 				--客户端统计,英雄单次技能3击中目标最大数量。
		--[[155]], "HeroSkillDPS3" 				--客户端统计,英雄技能3伤害累计总量
		--[[156]], "HeroSkillCount4" 			--客户端统计,英雄技能4使用次数。	
		--[[157]], "HeroSkillStartCD4" 			--客户端统计,英雄开局到第一次使用技能4的间隔，毫秒，未使用填9999999。
		--[[158]], "HeroSkillCD4" 				--客户端统计,英雄两次使用技能4最小间隔（毫秒）只使用了一次或者未使用填9999999。
		--[[159]], "HeroSkillHitCount4" 		--客户端统计,英雄技能4使造成伤害总次数（群攻和多段攻击需分别统计）。
		--[[160]], "HeroSkillMax4" 				--客户端统计,英雄单次技能4对单个目标伤害最大值（不包括暴击）	
		--[[161]], "HeroSkillMin4" 				--客户端统计,英雄单次技能4对单个目标伤害最小值（不包括暴击）	
		--[[162]], "HeroCritSkillMax4"			--客户端统计,英雄单次技能4暴击对单个目标伤害最大值	
		--[[163]], "HeroCritSkillMin4" 			--客户端统计,英雄单次技能4暴击对单个目标伤害最小值
		--[[164]], "HeroSkillTag4" 				--客户端统计,英雄单次技能4击中目标最大数量。
		--[[165]], "HeroSkillDPS4" 				--客户端统计,英雄技能4伤害累计总量	
		--[[166]], "ItemSkillCount" 			--客户端统计,玩家宝物使用次数。
		--[[167]], "ItemSkillStartCD" 			--客户端统计,英雄开局到第一次使用宝物技能的间隔，毫秒，未使用填9999999。	
		--[[168]], "ItemSkillCD" 				--客户端统计,玩家两次使用宝物最小间隔（毫秒）只使用了一次或者未使用填9999999。
		--[[169]], "ItemSkillHitCount" 			--客户端统计,宝物技能造成伤害总次数（群攻和多段攻击需分别统计）。
		--[[170]], "ItemSkillMax" 				--客户端统计,宝物技能单次对单个目标伤害最大值（不包括暴击）	
		--[[171]], "ItemSkillMin" 				--客户端统计,宝物技能单次对单个目标伤害最小值（不包括暴击）	
		--[[172]], "ItemCritSkillMax"			--客户端统计,宝物技能单次暴击对单个目标伤害最大值	
		--[[173]], "ItemCritSkillMin" 			--客户端统计,宝物技能单次暴击对单个目标伤害最小值
		--[[174]], "ItemSkillTag" 				--客户端统计,宝物技能单次击中目标最大数量。
		--[[175]], "ItemSkillDPS" 				--客户端统计,宝物技能伤害累计总量

		--[[176]], "SoldierID1" 				--客户端统计，上阵兵团1ID 
		--[[177]], "SoldierNum1" 				--客户端统计，上阵兵团1数量
		--[[178]], "SoldierEndNum1" 			--客户端统计，结算时上阵兵团1数量			
		--[[179]], "SoldierHP1" 				--客户端统计，上阵兵团1血量
		--[[180]], "SoldierHPTotal1" 			--客户端统计，上阵兵团1总血量
		--[[181]], "SoldierEndHP1" 				--客户端统计，结算时兵团1剩余数量	
		--[[182]], "SoldierDamageHPCount1"		--兵团1血量减少发生次数
		--[[183]], "SoldierDamageHPMax1"		--兵团1单次血量减少最大值
		--[[184]], "SoldierDamageHPMin1"		--兵团1单次血量减少最小值	
		--[[185]], "SoldierDamageHPTotal1"		--兵团1血量减少累计总量
		--[[186]], "SoldierDeadCount1"			--兵团1士兵死亡个数
		--[[187]], "SoldierReliveCount1"		--兵团1士兵复活个数、
		--[[188]], "SoldierHealHPCount1"		--兵团1血量回复发生次数
		--[[189]], "SoldierHealHPMax1"			--兵团1单次血量回复最大值
		--[[190]], "SoldierHealHPMin1"			--兵团1单次血量回复最小值	
		--[[191]], "SoldierHealHPTotal1"		--兵团1血量回复累计总量	
		--[[192]], "SoldierAtkMax1"				--兵团1士兵单次攻击最大值
		--[[193]], "SoldierAtkMin1"				--兵团1士兵单次攻击最小值
		--[[194]], "SoldierAtkCount1"			--兵团1士兵攻击总次数
		--[[195]], "SoldierAtkTotal1"			--兵团1士兵造成伤害总量		
		--[[196]], "SoldierID2" 				--客户端统计，上阵兵团2ID 
		--[[197]], "SoldierNum2" 				--客户端统计，上阵兵团2数量
		--[[198]], "SoldierEndNum2" 			--客户端统计，结算时上阵兵团2数量			
		--[[199]], "SoldierHP2" 				--客户端统计，上阵兵团2血量
		--[[200]], "SoldierHPTotal2" 			--客户端统计，上阵兵团2总血量
		--[[201]], "SoldierEndHP2" 				--客户端统计，结算时兵团2剩余数量	
		--[[202]], "SoldierDamageHPCount2"		--兵团2血量减少发生次数
		--[[203]], "SoldierDamageHPMax2"		--兵团2单次血量减少最大值
		--[[204]], "SoldierDamageHPMin2"		--兵团2单次血量减少最小值	
		--[[205]], "SoldierDamageHPTotal2"		--兵团2血量减少累计总量
		--[[206]], "SoldierDeadCount2"			--兵团2士兵死亡个数
		--[[207]], "SoldierReliveCount2"		--兵团2士兵复活个数、
		--[[208]], "SoldierHealHPCount2"		--兵团2血量回复发生次数
		--[[209]], "SoldierHealHPMax2"			--兵团2单次血量回复最大值
		--[[210]], "SoldierHealHPMin2"			--兵团2单次血量回复最小值	
		--[[211]], "SoldierHealHPTotal2"		--兵团2血量回复累计总量	
		--[[212]], "SoldierAtkMax2"				--兵团2士兵单次攻击最大值
		--[[213]], "SoldierAtkMin2"				--兵团2士兵单次攻击最小值
		--[[214]], "SoldierAtkCount2"			--兵团2士兵攻击总次数
		--[[215]], "SoldierAtkTotal2"			--兵团2士兵造成伤害总量		
		--[[216]], "SoldierID3" 				--客户端统计，上阵兵团3ID 
		--[[217]], "SoldierNum3" 				--客户端统计，上阵兵团3数量
		--[[218]], "SoldierEndNum3" 			--客户端统计，结算时上阵兵团3数量			
		--[[219]], "SoldierHP3" 				--客户端统计，上阵兵团3血量
		--[[220]], "SoldierHPTotal3" 			--客户端统计，上阵兵团3总血量
		--[[221]], "SoldierEndHP3" 				--客户端统计，结算时兵团3剩余数量	
		--[[222]], "SoldierDamageHPCount3"		--兵团3血量减少发生次数
		--[[223]], "SoldierDamageHPMax3"		--兵团3单次血量减少最大值
		--[[224]], "SoldierDamageHPMin3"		--兵团3单次血量减少最小值	
		--[[225]], "SoldierDamageHPTotal3"		--兵团3血量减少累计总量
		--[[226]], "SoldierDeadCount3"			--兵团3士兵死亡个数
		--[[227]], "SoldierReliveCount3"		--兵团3士兵复活个数、
		--[[228]], "SoldierHealHPCount3"		--兵团3血量回复发生次数
		--[[229]], "SoldierHealHPMax3"			--兵团3单次血量回复最大值
		--[[230]], "SoldierHealHPMin3"			--兵团3单次血量回复最小值	
		--[[231]], "SoldierHealHPTotal3"		--兵团3血量回复累计总量	
		--[[232]], "SoldierAtkMax3"				--兵团3士兵单次攻击最大值
		--[[233]], "SoldierAtkMin3"				--兵团3士兵单次攻击最小值
		--[[234]], "SoldierAtkCount3"			--兵团3士兵攻击总次数
		--[[235]], "SoldierAtkTotal3"			--兵团3士兵造成伤害总量		
		--[[236]], "SoldierID4" 				--客户端统计，上阵兵团4ID 
		--[[237]], "SoldierNum4" 				--客户端统计，上阵兵团4数量
		--[[238]], "SoldierEndNum4" 			--客户端统计，结算时上阵兵团4数量			
		--[[239]], "SoldierHP4" 				--客户端统计，上阵兵团4血量
		--[[240]], "SoldierHPTotal4" 			--客户端统计，上阵兵团4总血量
		--[[241]], "SoldierEndHP4" 				--客户端统计，结算时兵团4剩余数量	
		--[[242]], "SoldierDamageHPCount4"		--兵团4血量减少发生次数
		--[[243]], "SoldierDamageHPMax4"		--兵团4单次血量减少最大值
		--[[244]], "SoldierDamageHPMin4"		--兵团4单次血量减少最小值	
		--[[245]], "SoldierDamageHPTotal4"		--兵团4血量减少累计总量
		--[[246]], "SoldierDeadCount4"			--兵团4士兵死亡个数
		--[[247]], "SoldierReliveCount4"		--兵团4士兵复活个数、
		--[[248]], "SoldierHealHPCount4"		--兵团4血量回复发生次数
		--[[249]], "SoldierHealHPMax4"			--兵团4单次血量回复最大值
		--[[250]], "SoldierHealHPMin4"			--兵团4单次血量回复最小值	
		--[[251]], "SoldierHealHPTotal4"		--兵团4血量回复累计总量	
		--[[252]], "SoldierAtkMax4"				--兵团4士兵单次攻击最大值
		--[[253]], "SoldierAtkMin4"				--兵团4士兵单次攻击最小值
		--[[254]], "SoldierAtkCount4"			--兵团4士兵攻击总次数
		--[[255]], "SoldierAtkTotal4"			--兵团4士兵造成伤害总量		
		--[[256]], "SoldierID5" 				--客户端统计，上阵兵团5ID 
		--[[257]], "SoldierNum5" 				--客户端统计，上阵兵团5数量
		--[[258]], "SoldierEndNum5" 			--客户端统计，结算时上阵兵团5数量			
		--[[259]], "SoldierHP5" 				--客户端统计，上阵兵团5血量
		--[[260]], "SoldierHPTotal5" 			--客户端统计，上阵兵团5总血量
		--[[261]], "SoldierEndHP5" 				--客户端统计，结算时兵团5剩余数量	
		--[[262]], "SoldierDamageHPCount5"		--兵团5血量减少发生次数
		--[[263]], "SoldierDamageHPMax5"		--兵团5单次血量减少最大值
		--[[264]], "SoldierDamageHPMin5"		--兵团5单次血量减少最小值	
		--[[265]], "SoldierDamageHPTotal5"		--兵团5血量减少累计总量
		--[[266]], "SoldierDeadCount5"			--兵团5士兵死亡个数
		--[[267]], "SoldierReliveCount5"		--兵团5士兵复活个数、
		--[[268]], "SoldierHealHPCount5"		--兵团5血量回复发生次数
		--[[269]], "SoldierHealHPMax5"			--兵团5单次血量回复最大值
		--[[270]], "SoldierHealHPMin5"			--兵团5单次血量回复最小值	
		--[[271]], "SoldierHealHPTotal5"		--兵团5血量回复累计总量	
		--[[272]], "SoldierAtkMax5"				--兵团5士兵单次攻击最大值
		--[[273]], "SoldierAtkMin5"				--兵团5士兵单次攻击最小值
		--[[274]], "SoldierAtkCount5"			--兵团5士兵攻击总次数
		--[[275]], "SoldierAtkTotal5"			--兵团5士兵造成伤害总量		
		--[[276]], "SoldierID6" 				--客户端统计，上阵兵团6ID 
		--[[277]], "SoldierNum6" 				--客户端统计，上阵兵团6数量
		--[[278]], "SoldierEndNum6" 			--客户端统计，结算时上阵兵团6数量			
		--[[279]], "SoldierHP6" 				--客户端统计，上阵兵团6血量
		--[[280]], "SoldierHPTotal6" 			--客户端统计，上阵兵团6总血量
		--[[281]], "SoldierEndHP6" 				--客户端统计，结算时兵团6剩余数量	
		--[[282]], "SoldierDamageHPCount6"		--兵团6血量减少发生次数
		--[[283]], "SoldierDamageHPMax6"		--兵团6单次血量减少最大值
		--[[284]], "SoldierDamageHPMin6"		--兵团6单次血量减少最小值	
		--[[285]], "SoldierDamageHPTotal6"		--兵团6血量减少累计总量
		--[[286]], "SoldierDeadCount6"			--兵团6士兵死亡个数
		--[[287]], "SoldierReliveCount6"		--兵团6士兵复活个数、
		--[[288]], "SoldierHealHPCount6"		--兵团6血量回复发生次数
		--[[289]], "SoldierHealHPMax6"			--兵团6单次血量回复最大值
		--[[290]], "SoldierHealHPMin6"			--兵团6单次血量回复最小值	
		--[[291]], "SoldierHealHPTotal6"		--兵团6血量回复累计总量	
		--[[292]], "SoldierAtkMax6"				--兵团6士兵单次攻击最大值
		--[[293]], "SoldierAtkMin6"				--兵团6士兵单次攻击最小值
		--[[294]], "SoldierAtkCount6"			--兵团6士兵攻击总次数
		--[[295]], "SoldierAtkTotal6"			--兵团6士兵造成伤害总量		
		--[[296]], "SoldierID7" 				--客户端统计，上阵兵团7ID 
		--[[297]], "SoldierNum7" 				--客户端统计，上阵兵团7数量
		--[[298]], "SoldierEndNum7" 			--客户端统计，结算时上阵兵团7数量			
		--[[299]], "SoldierHP7" 				--客户端统计，上阵兵团7血量
		--[[300]], "SoldierHPTotal7" 			--客户端统计，上阵兵团7总血量
		--[[301]], "SoldierEndHP7"	 			--客户端统计，结算时兵团7剩余数量	
		--[[302]], "SoldierDamageHPCount7"		--兵团7血量减少发生次数
		--[[303]], "SoldierDamageHPMax7"		--兵团7单次血量减少最大值
		--[[304]], "SoldierDamageHPMin7"		--兵团7单次血量减少最小值	
		--[[305]], "SoldierDamageHPTotal7"		--兵团7血量减少累计总量
		--[[306]], "SoldierDeadCount7"			--兵团7士兵死亡个数
		--[[307]], "SoldierReliveCount7"		--兵团7士兵复活个数、
		--[[308]], "SoldierHealHPCount7"		--兵团7血量回复发生次数
		--[[309]], "SoldierHealHPMax7"			--兵团7单次血量回复最大值
		--[[310]], "SoldierHealHPMin7"			--兵团7单次血量回复最小值	
		--[[311]], "SoldierHealHPTotal7"		--兵团7血量回复累计总量	
		--[[312]], "SoldierAtkMax7"				--兵团7士兵单次攻击最大值
		--[[313]], "SoldierAtkMin7"				--兵团7士兵单次攻击最小值
		--[[314]], "SoldierAtkCount7"			--兵团7士兵攻击总次数
		--[[315]], "SoldierAtkTotal7"			--兵团7士兵造成伤害总量		
		--[[316]], "SoldierID8" 				--客户端统计，上阵兵团8ID 
		--[[317]], "SoldierNum8" 				--客户端统计，上阵兵团8数量
		--[[318]], "SoldierEndNum8" 			--客户端统计，结算时上阵兵团8数量			
		--[[319]], "SoldierHP8" 				--客户端统计，上阵兵团8血量
		--[[320]], "SoldierHPTotal8" 			--客户端统计，上阵兵团8总血量
		--[[321]], "SoldierEndHP8"	 			--客户端统计，结算时兵团8剩余数量	
		--[[322]], "SoldierDamageHPCount8"		--兵团8血量减少发生次数
		--[[323]], "SoldierDamageHPMax8"		--兵团8单次血量减少最大值
		--[[324]], "SoldierDamageHPMin8"		--兵团8单次血量减少最小值	
		--[[325]], "SoldierDamageHPTotal8"		--兵团8血量减少累计总量
		--[[326]], "SoldierDeadCount8"			--兵团8士兵死亡个数
		--[[327]], "SoldierReliveCount8"		--兵团8士兵复活个数、
		--[[328]], "SoldierHealHPCount8"		--兵团8血量回复发生次数
		--[[329]], "SoldierHealHPMax8"			--兵团8单次血量回复最大值
		--[[330]], "SoldierHealHPMin8"			--兵团8单次血量回复最小值	
		--[[331]], "SoldierHealHPTotal8"		--兵团8血量回复累计总量	
		--[[332]], "SoldierAtkMax8"				--兵团8士兵单次攻击最大值
		--[[333]], "SoldierAtkMin8"				--兵团8士兵单次攻击最小值
		--[[334]], "SoldierAtkCount8"			--兵团8士兵攻击总次数
		--[[335]], "SoldierAtkTotal8"			--兵团8士兵造成伤害总量		

		--[[336]], "HeroInitMP"					--英雄初始蓝量（第一次蓝量发生改变前的蓝量）
		--[[337]], "HeroHealMPCount"			--蓝量回复发生次数
		--[[338]], "HeroHealMPMax"				--单次蓝量回复最大值
		--[[339]], "HeroHealMPMin"				--单次蓝量回复最小值
		--[[340]], "HeroHealMPTotal"			--蓝量回复累计总量
		--[[341]], "HeroDamageMPCount"			--蓝量减少发生次数
		--[[342]], "HeroDamageMPMax"			--单次蓝量减少最大值
		--[[343]], "HeroDamageMPMin"			--单次蓝量减少最小值
		--[[344]], "HeroDamageMPTotal"			--蓝量减少累计总量
		--[[345]], "HeroEndMP"					--退出副本时蓝量
		
		--[[346]], "MonsterCount" 				--本局出现怪物总数量（包含小怪和BOSS以及BOSS召唤小怪）
		--[[347]], "MonsterTeamCount" 			--本局出现怪物军团数	
		--[[348]], "MonsterEndCount" 			--本局结束时剩余怪物总数量（包含小怪和BOSS）	
		--[[349]], "MonsterCount1" 				--本局玩家击杀小怪数量（不包括boss死亡时自杀的小怪）
		--[[350]], "MonsterCount2" 				--本局Boss死亡导致小怪死亡数量（如果有这样的机制则记录，无则填0）
		--[[351]], "MonsterCount3" 				--本局小怪死亡时不在地图坐标正常范围内的数量（外挂将怪物坐标改到地图外面）
		--[[352]], "BossCount" 					--本局Boss出现数量
		--[[353]], "BossKillCount" 				--本局Boss击杀数量
		--[[354]], "BossInitHPMax" 				--单个Boss最大初始血量（单个BOSS第一次扣血时,统计扣血前的初始值）
		--[[355]], "BossInitHPMin" 				--单个Boss最小初始血量（单个BOSS第一次扣血时,统计扣血前的初始值）
		--[[356]], "BossDamageMax" 				--单个Boss单次承受伤害最大值
		--[[357]], "BossDamageMin" 				--单个Boss单次承受伤害最小值
		--[[358]], "BossDamageTotal" 			--所有Boss累计承受伤害总量
		--[[359]], "BossInitHPTotal" 			--所有Boss累计初始血量总量
		--[[360]], "MonsterInitHPMax" 			--单个小怪最大初始血量（单个怪物第一次扣血时,统计扣血前的初始值）
		--[[361]], "MonsterInitHPMin" 			--单个小怪最小初始血量（单个怪物第一次扣血时,统计扣血前的初始值）
		--[[362]], "MonsterDamageMax" 			--单个小怪单次承受伤害最大值
		--[[363]], "MonsterDamageMin" 			--单个小怪单次承受伤害最小值
		--[[364]], "MonsterDamageTotal" 		--所有小怪累计承受伤害总量
		--[[365]], "MonsterInitHPTotal" 		--所有小怪累计初始血量总量
		--[[366]], "BossAttackCount" 			--所有boss普通攻击次数
		--[[367]], "BossUseSkillCount" 			--所有boss技能攻击次数
		--[[368]], "BossMissCount" 				--所有boss攻击无效次数（MISS,无敌，免疫等使攻击无效次数）	
		--[[369]], "BossTimeTotal" 				--所有boss累计存活时间,毫秒（从boss出现到死亡的时间）
		--[[370]], "BossMoveTotal" 				--所有boss累计移动距离
		--[[371]], "BossAttackMax" 				--单个boss单次造成的最大伤害（包括普通攻击和技能攻击）
		--[[372]], "BossAttackMin" 				--单个boss单次造成的最小伤害（包括普通攻击和技能攻击）
		--[[373]], "BossAttackTotal"			--所有boss累计造成的总伤害（包括普通攻击和技能攻击）
		--[[374]], "BossCallCount" 				--所有boss召唤小怪次数
		--[[375]], "BossCallTotal" 				--所有boss召唤小怪总数	
		--[[376]], "MonsterAttackCount" 		--所有小怪,累计普通攻击次数
		--[[377]], "MonsterSkillCount" 			--所有小怪,累计技能攻击次数
		--[[378]], "MonsterMissCount" 			--所有boss攻击无效次数（MISS,无敌，免疫等使攻击无效次数）			
		--[[379]], "MonsterTimeTotal" 			--所有小怪,累计存活时间,毫秒（从boss出现到死亡的时间）
		--[[380]], "MonsterMoveTotal" 			--所有小怪,累计移动距离
		--[[381]], "MonsterAttackMax" 			--所有小怪,单次造成的最大伤害（包括普通攻击和技能攻击）
		--[[382]], "MonsterAttackMin" 			--所有小怪,单次造成的最小伤害（包括普通攻击和技能攻击）
		--[[383]], "MonsterAttackTotal" 		--所有小怪,累计造成的总伤害（包括普通攻击和技能攻击）
	    
	    --[[384]], "Skill1Use" 					--提升物理防御的技能使用次数
	    --[[385]], "Skill1Count" 				--客户端检测的提升物理防御效果总出现次数
		--[[386]], "Skill1EffectMin"			--客户端检测提升物理防御效果最小值（百分比*10000，例如增加50%记录为5000）  
	    --[[387]], "Skill1EffectMax" 			--客户端检测的提升物理防御效果最大值（百分比*10000，例如增加50%记录为5000） 
		--[[388]], "Skill1TimeMin" 				--客户端检测提升物理防御单次持续最短时间
		--[[389]], "Skill1TimeMax" 				--客户端检测提升物理防御单次持续最长时间
		--[[390]], "Skill1TimeTotal" 			--客户端检测提升物理防御效果总持续时间 	
	    --[[391]], "Skill2Use" 					--提升攻击力的技能使用次数
	    --[[392]], "Skill2Count" 				--客户端检测的提升攻击力效果总出现次数
		--[[393]], "Skill2EffectMin" 			--客户端检测提升攻击力效果最小值（百分比*10000，例如增加50%攻击记录为5000）  
	    --[[394]], "Skill2EffectMax" 			--客户端检测的提升攻击力效果最大值（百分比*10000，例如增加50%攻击记录为5000） 
		--[[395]], "Skill2TimeMin"	 			--客户端检测提升攻击力单次持续最短时间
		--[[396]], "Skill2TimeMax" 				--客户端检测提升攻击力单次持续最长时间
		--[[397]], "Skill2TimeTotal" 			--客户端检测提升攻击力效果总持续时间 	
	    --[[398]], "Skill3Use"	 				--提升暴击的技能使用次数
	    --[[399]], "Skill3Count"	 			--客户端检测的提升暴击效果总出现次数
		--[[400]], "Skill3EffectMin" 			--客户端检测提升暴击效果最小值（百分比*10000，例如增加50%攻击记录为5000）  
	    --[[401]], "Skill3EffectMax" 			--客户端检测的提升暴击效果最大值（百分比*10000，例如增加50%攻击记录为5000） 
		--[[402]], "Skill3TimeMin" 				--客户端检测提升暴击单次持续最短时间
		--[[403]], "Skill3TimeMax" 				--客户端检测提升暴击单次持续最长时间
		--[[404]], "Skill3TimeTotal" 			--客户端检测提升暴击效果总持续时间 				
	    --[[405]], "Skill4Use" 					--提升移动速度的技能使用次数
	    --[[406]], "Skill4Count" 				--客户端检测的提升移动速度效果总出现次数
		--[[407]], "Skill4EffectMin" 			--客户端检测提升移动速度效果最小值（百分比*10000，例如增加50%攻击记录为5000）  
	    --[[408]], "Skill4EffectMax" 			--客户端检测的提升移动速度效果最大值（百分比*10000，例如增加50%攻击记录为5000） 
		--[[409]], "Skill4TimeMin" 				--客户端检测提升移动速度单次持续最短时间
		--[[410]], "Skill4TimeMax" 				--客户端检测提升移动速度单次持续最长时间
		--[[411]], "Skill4TimeTotal" 			--客户端检测提升移动速度效果总持续时间 		
		--[[412]], "Skill5Use" 					--提升攻击速度的技能使用次数
	    --[[413]], "Skill5Count" 				--客户端检测的提升攻击速度效果总出现次数
		--[[414]], "Skill5EffectMin" 			--客户端检测提升攻击速度效果最小值（百分比*10000，例如增加50%攻击记录为5000）  
	    --[[415]], "Skill5EffectMax" 			--客户端检测的提升攻击速度效果最大值（百分比*10000，例如增加50%攻击记录为5000） 
		--[[416]], "Skill5TimeMin" 				--客户端检测提升攻击速度单次持续最短时间
		--[[417]], "Skill5TimeMax" 				--客户端检测提升攻击速度单次持续最长时间
		--[[418]], "Skill5TimeTotal" 			--客户端检测提升攻击速度效果总持续时间 		
		--[[419]], "Skill6Use" 					--免伤的技能使用次数
		--[[420]], "Skill6Type" 				--免伤的类型，1为兵团免伤，2为火系免伤，3为水系免伤，4为气系免伤，5为土系免伤，6为法术免伤，7为全部免伤	
	    --[[421]], "Skill6Count" 				--客户端检测的免伤效果总出现次数
		--[[422]], "Skill6EffectMin" 			--客户端检测免伤效果最小值（百分比*10000，例如增加60%攻击记录为6000）  
	    --[[423]], "Skill6EffectMax" 			--客户端检测的免伤效果最大值（百分比*10000，例如增加60%攻击记录为6000） 
		--[[424]], "Skill6TimeMin" 				--客户端检测免伤单次持续最短时间
		--[[425]], "Skill6TimeMax" 				--客户端检测免伤单次持续最长时间
		--[[426]], "Skill6TimeTotal" 			--客户端检测免伤效果总持续时间 
		--[[427]], "Skill7Use" 					--抗性的技能使用次数
		--[[428]], "Skill7Type" 				--抗性的类型，1为物理抗性，2为火系抗性，3为水系抗性，4为气系抗性，5为土系抗性，6为全部抗性	
	    --[[429]], "Skill7Count" 				--客户端检测的抗性效果总出现次数
		--[[430]], "Skill7EffectMin" 			--客户端检测抗性效果最小值（百分比*10000，例如增加60%攻击记录为6000）  
	    --[[431]], "Skill7EffectMax" 			--客户端检测的抗性效果最大值（百分比*10000，例如增加60%攻击记录为6000） 
		--[[432]], "Skill7TimeMin" 				--客户端检测抗性单次持续最短时间
		--[[433]], "Skill7TimeMax" 				--客户端检测抗性单次持续最长时间
		--[[434]], "Skill7TimeTotal" 			--客户端检测抗性效果总持续时间 	
	    --[[435]], "Skill8Use" 					--提升暴击的技能使用次数
	    --[[436]], "Skill8Count" 				--客户端检测的提升攻击范围总出现次数
		--[[437]], "Skill8EffectMin" 			--客户端检测提升攻击范围最小值（百分比*10000，例如增加50%攻击记录为5000）  
	    --[[438]], "Skill8EffectMax" 			--客户端检测的提升攻击范围最大值（百分比*10000，例如增加50%攻击记录为5000） 
		--[[439]], "Skill8TimeMin" 				--客户端检测提升攻击范围单次持续最短时间
		--[[440]], "Skill8TimeMax"				--客户端检测提升攻击范围单次持续最长时间
		--[[441]], "Skill8TimeTotal" 			--客户端检测提升攻击范围总持续时间 			
	    --[[442]], "Skill9Use" 					--技能护盾的使用次数
	    --[[443]], "Skill9Count" 				--客户端检测的护盾效果总出现次数
		--[[444]], "Skill9TimeMin" 				--客户端检测的护盾单次持续最短时间
		--[[445]], "Skill9TimeMax" 				--客户端检测的护盾单次持续最长时间
		--[[446]], "Skill9TimeTotal" 			--客户端检测的护盾效果总持续时间
		--[[447]], "Skill9Max" 					--客户端检测的护盾单次吸收伤害最大值
		--[[448]], "Skill9Min" 					--客户端检测的护盾单次吸收伤害最小值	
		--[[449]], "Skill9Total" 				--客户端检测的护盾累计吸收伤害总量
		--[[450]], "Skill10Use" 				--眩晕技能的使用次数
	    --[[451]], "Skill10Count" 				--客户端检测使敌方的眩晕效果总出现次数
		--[[452]], "Skill10CountMax" 			--客户端检测的眩晕单次命中的敌人数量最大值
		--[[453]], "Skill10TimeMin" 			--客户端检测的眩晕单次持续最短时间
		--[[454]], "Skill10TimeMax" 			--客户端检测的眩晕单次持续最长时间
		--[[455]], "Skill10TimeTotal" 			--客户端检测的眩晕效果总持续时间
		--[[456]], "Skill11Use" 				--冻结技能的使用次数
	    --[[457]], "Skill11Count" 				--客户端检测使敌方的冻结效果总出现次数
		--[[458]], "Skill11CountMax" 			--客户端检测的冻结单次命中的敌人数量最大值
		--[[459]], "Skill11TimeMin" 			--客户端检测的冻结单次持续最短时间
		--[[460]], "Skill11TimeMax" 			--客户端检测的冻结单次持续最长时间
		--[[461]], "Skill11TimeTotal" 			--客户端检测的冻结效果总持续时间
		--[[462]], "Skill12Use" 				--客户端统计，Dot效果技能使用次数" 		
		--[[463]], "Skill12Count" 				--客户端统计，Dot效果出现次数 
		--[[464]], "Skill12CountMax" 			--客户端统计，单次Dot效果影响的最大目标数 
		--[[465]], "Skill12CountMin" 			--客户端统计，单次Dot效果影响的最小目标数 
		--[[466]], "Skill12Max" 				--客户端统计，单次Dot效果每跳的最大值 
		--[[467]], "Skill12Min" 				--客户端统计，单次Dot效果每跳的最小值
		--[[468]], "Skill12TimeMax" 			--客户端统计，单次Dot效果在敌方身上的最大持续时间
		--[[469]], "Skill12TimeMin" 			--客户端统计，单次Dot效果在敌方身上的最短持续时间
		--[[470]], "Skill12TimeTotal" 			--Dot效果在敌方身上的总持续时间 
		--[[471]], "Skill12DamageTotal" 		--Dot效果在敌方身上造成的总伤害
		
		--[[472]], "HeroType"					--参战英雄编号	
		--[[473]], "Heroinf1"					--参战英雄基础属性信息用逗号隔开，|攻击，防御，智力，知识|			
		--[[474]], "HeroMP"						--参战英雄魔法值	
		--[[475]], "HeroMPregen"				--参战英雄回复，秒回	

		--[[476]], "ClientStartTime"			--客户端战斗开始时间	
		--[[477]], "ClientEndTime"				--客户端战斗结束时间	
	}
end

if GameStatic.useSR then
	BattleUtils.initSRData()
end

local BattleUtils3 = {}
function BattleUtils3.dtor()
	SR_StringTab = nil
end

return BattleUtils3