--
-- Author: lannan
-- Date: 2018-10-110 10:42:07
--

local RuneLotteryProModel = class("RuneLotteryProModel", BaseModel)

RuneLotteryProModel.lotteryProType = 45
function RuneLotteryProModel:ctor()
    RuneLotteryProModel.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._playDayModel = self._modelMgr:getModel("PlayerTodayModel")
    -- 活动周期
    self._circle = 1
    -- 活动数据
    self._acData = {}
    -- 幸运抽奖数据
    self._goodsData = {}
    -- server数据
    self._serverData = {}

    self._isNeedUpdate = true
end


function RuneLotteryProModel:setData(data)
	self._isNeedUpdate = false
	self._serverData = data or {}   
	if not self._acModel then
		self._acModel = self._modelMgr:getModel("ActivityModel")
	end
	self._goodsData = {}
	-- 活动数据
	self._acData = self._acModel:getAcShowDataByType(RuneLotteryProModel.lotteryProType)
	self._acOpenId = self._acData._id or 46
	self._activityId = self._acData.activity_id or 100
	-- 周期
	local circle = self._acData.templateId or 1
	self._circle = tonumber(circle)

	if not self._lotteryTbData then
		self._lotteryTbData = tab.runeLottery
	end
	for k,v in pairs(self._lotteryTbData) do
		if tonumber(v.cycle) == self._circle then
			table.insert(self._goodsData, v)
		end
	end

	local sortFunc = function(a,b)
		if a.grid and b.grid then
			return a.grid[1] < b.grid[1] 
		else
			return a.id < b.id 
		end
	end

	table.sort(self._goodsData,sortFunc)
end

function RuneLotteryProModel:updateServerData(data)    
	if not data or type(data) ~= "table" then return end
	local processData = nil
	processData = function(a, b)
		for k, v in pairs(b) do
			if type(a[k]) == "table" and type(v) == "table" then
				processData(a[k], v)
			else
				a[k] = v
			end
		end
	end
	processData(self._serverData, data)
end


function RuneLotteryProModel:getGoodsData()    
	return self._goodsData
end

function RuneLotteryProModel:getLotteryData() 
	return self._serverData or {}
end

function RuneLotteryProModel:getRewardData()
	print("===========self._activityId===",self._activityId)
	if not self._activityId then return {} end
	if not self._lotteryReward then  
		self._lotteryReward = tab.lotteryReward
	end
	
	local data = self._lotteryReward[tonumber(self._acOpenId)]
	return data or {}
end

function RuneLotteryProModel:isLotteryProOpen()
	local isOpen = false
	if not self._acModel then
		self._acModel = self._modelMgr:getModel("ActivityModel")
	end
	if not self._acData or table.nums(self._acData) == 0 then
		self._acData = self._acModel:getAcShowDataByType(RuneLotteryProModel.lotteryProType)
	end
	local userLvl = self._userModel:getPlayerLevel()
	local startTime = self._acData and self._acData.start_time or 0
	local endTime = self._acData and self._acData.end_time or 0
	local currTime = self._userModel:getCurServerTime()

	isOpen = startTime <= currTime and endTime > currTime
	local levelLimit = self._acData.level_limit or 0
	isOpen = isOpen and userLvl >= levelLimit
	return isOpen
end

function RuneLotteryProModel:isHaveFreeCount()
	local infoNum = self._playDayModel:getDayInfo(91)
	if not infoNum or infoNum == 0 then
		return true
	end
	
	return false
end

function RuneLotteryProModel:isLotteryOpen()
	local isOpen = false
	if not self._acModel then
		self._acModel = self._modelMgr:getModel("ActivityModel")
	end
	if not self._acData or table.nums(self._acData) == 0 then
		self._acData = self._acModel:getAcShowDataByType(RuneLotteryProModel.lotteryProType)
	end
	local userLvl = self._userModel:getPlayerLevel()
	local startTime = self._acData and self._acData.start_time or 0
	local endTime = self._acData and self._acData.end_time or 0
	local currTime = self._userModel:getCurServerTime()

	isOpen = startTime <= currTime and endTime > currTime
	local levelLimit = self._acData.level_limit or 0
	isOpen = isOpen and userLvl >= levelLimit
	return isOpen
end

function RuneLotteryProModel:getAcOpenID()
	return self._acOpenId
end

-- 获取商店数据
function RuneLotteryProModel:getShopData()
	-- self._circle
	-- 周期
	local acOpenId = self._acOpenId or 1
	local shopData = tab.shopLotteryReward
	local data = {}
	for k,v in pairs(shopData) do
		if v.activityId == acOpenId then
			table.insert(data, v)
		end
	end
	
	local sortFunc = function(a,b)        
		return a.id < b.id         
	end
	table.sort(data,sortFunc)
	return data or {}
end

return RuneLotteryProModel