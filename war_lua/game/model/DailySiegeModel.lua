--
-- Author: <ligen@playcrab.com>
-- Date: 2017-09-06 18:05:00
--
local DailySiegeModel = class("DailySiegeModel", BaseModel)
local DailySiegeData = class("DailySiegeData")

--[[
	--掉落物品：走配置
	--排行榜：走其他模块
	--目标数据: 走服务器数据然后读配置
	--推荐阵型：走配置
]]

function DailySiegeData:ctor(data)
	self._resetTime 	= data.resetTime    --刷新时间
	self._type1 		= data.type1 		--今日攻城城池类型
	self._type2 		= data.type2        --今日守城城池类型
	self._diff 			= data.diff         --攻城最大挑战难度
	self._maxDamage 	= data.maxDamage    --守城最高伤害
	self._dDamage 		= data.dDamage      --今日伤害
	self._atkTime 		= data.atkTime      --上次挑战时间
	self._atkType 		= data.atkType      --上次挑战类型
	self._atkDiff 		= data.atkDiff      --上次挑战难度
	self._atkId 		= data.atkId        --上次挑战关卡ID
	self._rewardList 	= data.rewardList   --领取过的攻城奖励列表
	self._hValue 		= data.hValue       --守城历史最佳记录
	self._maxValue		= data.maxValue     --攻城历史最大杀敌数
	self._defWin		= data.defWin       --守城胜利次数
end

function DailySiegeData:setDailyInfo(data)
	--日常攻城玩法次数:已经玩了的次数
	if data.day69 then  
		self._day69 = data.day69
	end 
	--日常守城玩法次数:已经玩了的次数
	if data.day70 then
		self._day70 = data.day70
	end 
end

function DailySiegeModel:ctor()
    DailySiegeModel.super.ctor(self) 
    self:_setConfigData()
    self._playerTodayMode = self._modelMgr:getModel("PlayerTodayModel")
    local siegeModel = self._modelMgr:getModel("SiegeModel")
    local isOpenDaily = siegeModel:isSiegeDailyOpen()
    -- if isOpenDaily then
    	self:registerTimer(5, 0, GRandom(0, 5), specialize(self.refleshUIEvent, self))
    -- end
end

function DailySiegeModel:refleshUIEvent()
    -- self._serverMgr:sendMsg("DailySiegeServer", "getDailySiegeInfo", {}, true, {}, function (result, error)
    	self:setForceReflash(true)
        self:reflashData("refleshUIEvent")
    -- end)
end

function DailySiegeData:updateData(data)
	if data.resetTime then
		self._resetTime = data.resetTime    
	end 
	
	if data.type1 then
		self._type1 = data.type1    
	end

	if data.type2 then
		self._type2 = data.type2    
	end


	if data.diff then
		if self._diff == nil then
			self._diff = data.diff
		else
			for k,v in pairs(data.diff) do
				self._diff[k] = v
			end 
		end 
		self._isHistroyMax = true
	else
		self._isHistroyMax = false
	end 


	if data.maxDamage then
		self._maxDamage = data.maxDamage
		self._isHistroyMaxDamage = true
	else
	 	 self._isHistroyMaxDamage = false
	end 

	if data.dDamage then
		self._dDamage = data.dDamage    
	end 

	if data.atkTime then
		self._atkTime = data.atkTime    
	end 

	if data.atkDiff then
		self._atkDiff = data.atkDiff    
	end 

	if data.atkId then
		self._atkId = data.atkId    
	end 

	if data.rewardList then
		if self._rewardList  == nil then
			self._rewardList = data.rewardList
		else
			for k,v in pairs(data.rewardList) do
				self._rewardList[k] = v
			end 
		end 
	end 

	if data.hValue then
		if self._hValue == nil then
			self._hValue = data.hValue
		else
			for k,v in pairs(data.hValue) do
				self._hValue[k] = v
			end
		end  
	end 

	if data.maxValue then
		if self._maxValue == nil then
			self._maxValue = data.maxValue
		else
			for k,v in pairs(data.maxValue) do
				self._maxValue[k] = v
			end 
		end 
		self._isHistroyMaxKillCount = true
	else
		self._isHistroyMaxKillCount = false
	end 

	if data.defWin then
		self._defWin = data.defWin
	end 

end

-- 刷新玩家的攻城/守城的玩法次数
function DailySiegeModel:updateRemainNum(data)
	local playerTodayData = data or self._playerTodayMode:getData()
	if self._serverData and playerTodayData then
		self._serverData:setDailyInfo(playerTodayData)
	end
end

function DailySiegeModel:updateData(data)
	if data then
		if self._serverData == nil then
			self._serverData = DailySiegeData.new(data)
		else
			self._serverData:updateData(data)
		end

		-- 只在第一次的时候用playerTodayMode数据同步
		if self._serverData._day68 == nil and self._serverData._day69 == nil then
			local dayInfo = self._playerTodayMode:getData()
    		self._serverData:setDailyInfo(dayInfo)
		end 
	end 
end

function DailySiegeModel:getData()
    return self._serverData
end

function DailySiegeModel:_setConfigData()
	self._configData = {}
	local configDatas= tab.siegeBasicBattle
	if configDatas then
		for k,v in pairs(configDatas) do
		    local key = v.theme.."_"..v.diff
		    self._configData[key] = clone(v)
		end
	end	
end

 -- @param  theme 关卡目标类型
 -- @param  diff 关卡难度系数
 -- return  某条关卡配置数据
function DailySiegeModel:getConfigDataByTypeAndDiff(theme, diff)
	if theme == nil or diff == nil then return end 
	return self._configData[theme.."_"..diff] or {}
end

 -- @param  id 关卡Id
 -- return  某条关卡配置数据
function DailySiegeModel:getConfigDataById(id)
	if id == nil then return end
	local configDatas= tab.siegeBasicBattle
	return configDatas[id]
end

function DailySiegeModel:updateRankData(rankData)
	table.sort(rankData,function (v1,v2)
		return v1.rank < v2.rank
	end)

	if self._rankData then self._rankData = nil end
	self._rankData = {}
	for i,v in ipairs(rankData) do
		local t = {}
		t.rank = v.rank 
		t.name = v.name
		table.insert(self._rankData,t)
	end
end

function DailySiegeModel:updateMyRankData(rankData)
	self._myRankData = {}
	self._myRankData.rank = rankData.rank
	self._myRankData.name = rankData.name
end

function DailySiegeModel:resetRankData()
	self._rankData = {}
end

function DailySiegeModel:resetMyRankData()
	self._myRankData = {}
end

function DailySiegeModel:getRankData()
	return self._rankData or {}
end

function DailySiegeModel:getMyRankData()
	return self._myRankData or {}
end

function DailySiegeModel:getConfigDataById(id)
	if id == nil then return {} end
	local configDatas= tab.siegeBasicBattle
	if configDatas then
		return configDatas[id]
	end 
	
end

-- 获取掉落物品
function DailySiegeModel:getDropGoods(id)
	local cfgData = self:getConfigDataById(id)
	local drops = {}
	if cfgData == nil then return  end
	for i,v in ipairs(cfgData.drop) do
		local t = {}
		t.type = v[1]
		t.id  = v[2]
		table.insert(drops, t)
	end
	return drops
end

--获取奖励钻石数目
function DailySiegeModel:getRankRewardByRank(rank)
	if rank == nil then return 0 end
	rank = tonumber(rank)
	local rankCfg = tab.siegeBasicWeeklyReward
	for k,cfg in pairs(rankCfg) do
		local pos = cfg.pos
		if rank >= tonumber(pos[1]) and rank <= tonumber(pos[2]) then
			return cfg.award[1][3]
		end 
	end
	return 0
end

-- type: 1 攻城，2 守城
function DailySiegeModel:getCardConfigData(type)
	local cfg = {}
	if self._serverData then
		if type == 1 then
			local levelMax = self:getMaxLevelCfg(self._serverData._type1)
			local diff = 0
			if self._serverData._diff and self._serverData._diff[tostring(self._serverData._type1)] then
				diff = self._serverData._diff[tostring(self._serverData._type1)]
			end 
			diff = math.min(levelMax, diff+1 )
			cfg = self:getConfigDataByTypeAndDiff(self._serverData._type1, diff)
		else
			cfg = self:getDefendCardCfgData(self._serverData._type2)
		end 
	end
	return cfg
end

-- 获取守城的关卡配置数据
function DailySiegeModel:getDefendCardCfgData(theme)
	local configDatas= tab.siegeBasicBattle
	for k,v in pairs(configDatas) do
		if theme == v.theme then
			return v
		end 
	end
end

-- 获取守城今日敌人
function DailySiegeModel:getEnimys(id)
	local cfgData = self:getConfigDataById(id)
	local t = cfgData.showEnemy
	return t or {}
end

-- 获得玩家攻守城的剩余次数
-- type:1=攻城 2=守城
function DailySiegeModel:getRemainNum(type)
	local total = type == 1 and tab.siegeSetting[8].value or tab.siegeSetting[9].value
	local num = 0
	if self._isForceReflash then
		total, num = self:getRemainForceNum(type)
		return total, num
	end 

	if self._serverData then
		if type == 1 then
			num = self._serverData._day69 or 0
		elseif type == 2 then
			num = self._serverData._day70 or 0
		end
	else
		local playerData = self._playerTodayMode:getData()
		local day69 = playerData.day69 or 0
	    local day70 = playerData.day70 or 0
	    return total , type == 1 and total - day69 or total - day70
	end

	local remainNum = total - num
	return total, remainNum
end


-- 返回玩家攻城达到的最大难度
function DailySiegeModel:getChallengeLevelMax()
	if self._serverData and self._serverData._diff then
		local maxLevel = self._serverData._diff[tostring(self._serverData._type1)]
		return maxLevel or 0
	end
	return 0
end

function DailySiegeModel:getRankSetting()
	local attackRankMax = tab.siegeSetting[15].value
	local defendRankMax = tab.siegeSetting[16].value
	return attackRankMax, defendRankMax 
end

-- 获取攻城目标信息
function DailySiegeModel:getAttackThemeInfo(theme)
	local openAtkThemes = tab.siegeSetting[18].value
	local indexT = openAtkThemes
	-- todo
	local tb = {}
	for i,v in ipairs(indexT) do
		local t = {}
		t.iconPng = "globalImgUI_class"..v..".png"
		t.name = lang("NESTS_CAMP_NAME_"..v)
		t.des = "SIEGE_DAILY_THEMEDETAILDES"..v
		table.insert(tb, t)
	end


	if theme then 
		for i,v in ipairs(openAtkThemes) do
			if v == theme then
				return tb[i] 
			end 
		end
	end
	return tb
end

-- 返回攻城开启的主题
function DailySiegeModel:getAtkOpenThemes()
	local openAtkThemes = tab.siegeSetting[18].value
	return openAtkThemes
end

-- 获取已经领过的奖励
function DailySiegeModel:getRawardList()
	if self._serverData then
		return self._serverData._rewardList or {}
	end 
	return {}
end

--返回是否历史挑战的最大难度
function DailySiegeModel:isHisMaxDiff()
	if self._serverData and self._serverData._isHistroyMax then
		return  self._serverData._isHistroyMax
	end 
	return false
end

--返回是否某关卡最大杀敌数
function DailySiegeModel:isHisMaxKillCount()
	if self._serverData and self._serverData._isHistroyMaxKillCount then
		return  self._serverData._isHistroyMaxKillCount
	end 
	return false
end

--返回是否历史守城的最大伤害
function DailySiegeModel:isHisMaxDamage()
	if self._serverData and self._serverData._isHistroyMaxDamage then
		return  self._serverData._isHistroyMaxDamage
	end 
	return false
end 

-- 返回每一主题的开启的最大关卡数
function DailySiegeModel:getMaxLevelCfg(theme)
	local configDatas= tab.siegeBasicBattle
	local level = 0
	local totalLevel = 0
	for k,v in pairs(configDatas) do
		if v.theme == theme then
			totalLevel = totalLevel + 1
			if v.visible == 0 then
				level = level + 1
			end 
		end 
	end
	return level, totalLevel
end

-- 返回今日对应主题和可扫荡难度  --add by haotaian
function DailySiegeModel:getMaxSweepLevelAndThemeByType(type)
	local diff = 0
	local theme = 0
	if self._serverData and self._serverData._diff and type == 1 then
		diff = self._serverData._diff[tostring(self._serverData._type1)] or 0
		theme = self._serverData._type1
	else
		theme = self._serverData._type2
	end
	return theme , diff
end

function DailySiegeModel:getSweepWarning()
	local siegeSet = tab.siegeSetting
	for k,v in pairs(siegeSet) do
		if v.name == "swapeWarining" then
			return v.value or 0
		end 
	end
	return 0
end

-- 返回守城时最高纪录时的战力
function DailySiegeModel:getMaxHisPower()
	if self._serverData and self._serverData._hValue then
		return self._serverData._hValue.score
	end 
	return 0
end

-- 是否守城过
function DailySiegeModel:isDefendCity()
	if self._serverData and self._serverData._maxDamage then
		return self._serverData._maxDamage > 0
	end 
	return false
end

-- 是否可以日常进攻或守城
function DailySiegeModel:canBattle()
	local siegeModel = self._modelMgr:getModel("SiegeModel")
    local isOpenDaily = siegeModel:isSiegeDailyOpen()
    if isOpenDaily then
        local _, remainNum1 = self:getRemainNum(1)
        local _, remainNum2 = self:getRemainNum(2)
        if remainNum1 > 0 or remainNum2 >0 then
            return true
        end 
    end 
    return false
end

-- 返回配置表里配置的最大守城次数
function DailySiegeModel:getTotalDefWinNumFromCfg()
	local svEnforcement = tab.svEnforcement
	local count = 0
	for k,v in pairs(svEnforcement) do
		count = count + 1
	end
	return count - 1
end

-- 返回守城胜利次数
function DailySiegeModel:getDefBattleWinNum()
	if self._serverData and self._serverData._defWin then
		local maxWinNum = self:getTotalDefWinNumFromCfg()
		local isMax = false
		if self._serverData._defWin > maxWinNum then
			isMax = true
		end 
		return math.min(self._serverData._defWin,maxWinNum),isMax
	end 
	return 0
end

-- 返回守城的怪物等级和奖励加成
function DailySiegeModel:getMonsterLevelAndBuff()
	local defWin, isMax = self:getDefBattleWinNum()
	local svEnforcement = tab.svEnforcement
	local t = {}
	for k,v in pairs(svEnforcement) do
		if defWin == tonumber(k) then
			local str = "(无尽)"
			t.level = v.id or 0
			t.buff  = "+" .. v.rewardinc .. "%" or 0
			if isMax then
				local buff = tab.siegeSetting[38]["value"]
				t.level = t.level .. str
				if buff then
					t.buff = "+" .. buff .. "%"
				end 
			end 
			break
		end
	end
	return t
end

-- 返回日常守城的战斗Id
function DailySiegeModel:getDefBattleId()
	local defWin = self:getDefBattleWinNum()
	local svEnforcement = tab.svEnforcement
	for k,v in pairs(svEnforcement) do
		if defWin == tonumber(k) then
			return v.section
		end
	end
end

-- 返回守城的推荐
function DailySiegeModel:getDefendRecommend()
	local defWin, isMax = self:getDefBattleWinNum()
	local svEnforcement = tab.svEnforcement
	-- 如果已经超过策划配置的最大值，直接返回配置最大值配置数据
	if isMax then
		return svEnforcement[defWin].recommend
	end 
	local recommend = {}
	for k,v in pairs(svEnforcement) do
		if defWin == tonumber(k) then
			recommend = v.recommend
		end
	end
	return recommend or {}
end

-- 返回凌晨五点强制刷新数据
function DailySiegeModel:getRemainForceNum(type)
	local total = 2
	local num = 0
	local data = self._playerTodayMode:getData()
	if type == 1 then
		num = data.day69 or 0
		total = tab.siegeSetting[8].value
	elseif type == 2 then
		num = data.day70 or 0
		total = tab.siegeSetting[9].value
	end
	local remainNum = total - num
	return total, remainNum
end

function DailySiegeModel:setForceReflash(isForce)
	self._isForceReflash = isForce
end

function DailySiegeModel:resetDailyNum()
	self._serverData._day69 = 0
    self._serverData._day70 = 0
end

return DailySiegeModel