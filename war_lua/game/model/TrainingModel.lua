--
-- Author: huangguofang
-- Date: 2016-10-15 16:03:37
-- Description: 训练所数据model

local TrainingModel = class("TrainingModel", BaseModel)

function TrainingModel:ctor()
    TrainingModel.super.ctor(self)
    
    self._TrainingData = {}
    self._serverData = {}
    self._userModel = self._modelMgr:getModel("UserModel")
    -- self._acModel = self._modelMgr:getModel("ActivityModel")
    -- 是否要忽略引导
    self._isIgnoreGuide = false

    --主界面icon 是否有红点
    self._isAcBtnRed = true
    
	-- self._isSeniorOpen = false  --高级训练所是否开启
	self._juniorSumNum = 0 		-- 初级总关卡数
	self._juniorPassNum = 0 	-- 初级通关卡数

	self._middleSumNum = 0 		-- 初级总关卡数
	self._middlePassNum = 0 	-- 初级通关卡数

	self._seniorSumNum = 0 		-- 初级总关卡数
	self._seniorPassNum = 0 	-- 初级通关卡数


	self._haveSen	   = false 	-- 是否有高级通关（至少一关）
	self._haveMid	   = false  -- 是否有中级通关（至少一关）
	self._seniorSumScore = 0

	-- 是否需要重新请求
	self._canRequest = true

	self._TrainingData = clone(tab.training)

	-- 格式化数据
	-- state 0 没训练过 1 可领奖励 2 重复训练
	for k,v in pairs(self._TrainingData) do
		v.state = 0
		if v.type then
			if 1 == tonumber(v.type) then
				self._juniorSumNum = self._juniorSumNum + 1
			elseif 2 == tonumber(v.type) then
				self._middleSumNum = self._middleSumNum + 1
			elseif 3 == tonumber(v.type) then
				self._seniorSumNum = self._seniorSumNum + 1
			end
		end
	end
	print("================================训练所数据model=========")


end

function TrainingModel:setData(data)
	-- dump(self._TrainingData,"self._TrainingData")
	if not data then return end
	self._serverData = clone(data)
	self._canRequest = false
	-- if data.sen then
		-- self._isSeniorOpen = 1 == tonumber(data.sen)
	-- end
	-- state 0 没训练过 1 可领奖励 2 重复训练
	-- 已通过关卡
	if data.psid then
		for k,v in pairs(data.psid) do
			local trainD = self._TrainingData[tonumber(v)]
			trainD.state = 1
			if not self._haveSen and 3 == trainD.type then
				self._haveSen = true
			end
			if not self._haveMid and 2 == trainD.type then
				self._haveMid = true
			end
			if 1 == trainD.type then
				self._juniorPassNum = self._juniorPassNum + 1
			elseif 2 == trainD.type then
				self._middlePassNum = self._middlePassNum + 1
			elseif 3 == trainD.type then
				self._seniorPassNum = self._seniorPassNum + 1
			end
		end
	end
	-- 已领取奖励关卡
	if data.grid then
		for k,v in pairs(data.grid) do
			self._TrainingData[tonumber(v)].state = 2
		end
	end

	-- 高级训练所评评分
	if data.sssc then
		for k,v in pairs(data.sssc) do
			self._TrainingData[tonumber(k)].score = tonumber(v)
		end
	end

	-- 高级训练所通关时间
	if data.sst then
		for k,v in pairs(data.sst) do
			self._TrainingData[tonumber(k)].sTime = tonumber(v)
		end
	end

	if data.scoresum then
		self._seniorSumScore = data.scoresum
	end

end

function TrainingModel:getIsNeedRequest()
	return self._canRequest
end
function TrainingModel:setTrainingFightToken(data)
	-- body
	if not data then return end
	self._currFightToken = data.token or nil
end

function TrainingModel:getTrainingFightToken()
	
	return self._currFightToken 
end

function TrainingModel:updateData(data)
	if not data then return end

	-- 已通过关卡
	if data.psid then
		for k,v in pairs(data.psid) do
			local trainD = self._TrainingData[tonumber(k)]
			trainD.state = 1
			if not self._haveSen and 3 == trainD.type then
				self._haveSen = true
			end
			if 1 == trainD.type then
				self._juniorPassNum = self._juniorPassNum + 1
			elseif 2 == trainD.type then
				self._middlePassNum = self._middlePassNum + 1
			elseif 3 == trainD.type then
				self._seniorPassNum = self._seniorPassNum + 1
			end
			if not self._serverData["psid"] then 
				self._serverData["psid"] = {}
			end
			self._serverData["psid"][k] = v
		end
	end

	-- 已领取奖励关卡
	if data.grid then
		for k,v in pairs(data.grid) do
			self._TrainingData[tonumber(k)].state = 2
			if not self._serverData["grid"] then 
				self._serverData["grid"] = {}
			end
			self._serverData["grid"][k] = v
		end
	end

	-- 高级训练所评评分
	if data.sssc then
		for k,v in pairs(data.sssc) do
			self._TrainingData[tonumber(k)].score = tonumber(v)
			if not self._serverData["sssc"] then 
				self._serverData["sssc"] = {}
			end
			self._serverData["sssc"][k] = v
		end
	end

	-- 高级训练所通关时间
	if data.sst then
		for k,v in pairs(data.sst) do
			self._TrainingData[tonumber(k)].sTime = tonumber(v)
			if not self._serverData["sst"] then 
				self._serverData["sst"] = {}
			end
			self._serverData["sst"][k] = v
		end
	end
	--高级是否开启
	-- if data.sen then
		-- self._isSeniorOpen = 1 == tonumber(data.sen)
	-- end
	--高级总评分
	if data.scoresum then
		self._seniorSumScore = data.scoresum
	end

	--分发事件
 	self:reflashData()
end

function TrainingModel:getDataByType(dataType)
	if not dataType then return end 
	local data = {}
	-- dump(self._TrainingData,"self._TrainingData==>")
	local _isBeforeLive = self:isBeforeLive() 
	for k,v in pairs(self._TrainingData) do
		if not (dataType == 3 and _isBeforeLive and tonumber(v.cType) == 2) then
			if tonumber(v.type) == tonumber(dataType) then
				table.insert(data, v)
			end
		end
	end
	return data
end

function TrainingModel:isSeniorOpen()
	local isSenOpen = false
	local userData = self._userModel:getData()
	local userLvl = userData and tonumber(userData.lvl) or 0
	local senTb = tab:Setting("SENIOR_TRAINING")
    local senLvl = senTb and tonumber(senTb.value) or 0
    if userLvl > 0 and senLvl > 0 and userLvl >= senLvl then
    	isSenOpen = true
    end
    -- print("==========================isSenOpen===",isSenOpen)
	return isSenOpen
end

function TrainingModel:isMiddleOpen()
	local isMiddleOpen = false
	local userData = self._userModel:getData()
	local userLvl = userData and tonumber(userData.lvl) or 0
	local MiddleTb = tab:Setting("JUNIOR_TRAINING")
    local MiddleLvl = MiddleTb and tonumber(MiddleTb.value) or 0
    if userLvl > 0 and MiddleLvl > 0 and userLvl >= MiddleLvl then
    	isMiddleOpen = true
    end
    -- print("==========================isMiddleOpen===",isMiddleOpen)
	return isMiddleOpen
end

-- 初级是否通关
function TrainingModel:isJuniorPass()
	-- print("===================初级是否通关========",self._juniorSumNum > 0 and self._juniorSumNum <= self._juniorPassNum)
	return self._juniorSumNum > 0 and self._juniorSumNum <= self._juniorPassNum
end

-- 初级
function TrainingModel:isTrainPassByType1()
	return self._juniorSumNum > 0 and self._juniorSumNum <= self._juniorPassNum	
end
-- 中级
function TrainingModel:isTrainPassByType2()
	return self._middleSumNum > 0 and self._middleSumNum <= self._middlePassNum
end
-- 高级
function TrainingModel:isTrainPassByType3()
	return self._seniorSumNum > 0 and self._seniorSumNum <= self._seniorPassNum
end

-- 是否通关过高级
function TrainingModel:isHaveSenior()
	return self._haveSen
end

-- 是否通关过中级
function TrainingModel:isHaveMiddle()
	return self._haveMid
end

function TrainingModel:getSeniorSumScore()
	-- body
	return self._seniorSumScore or 0
end

function TrainingModel:isCanGetReward(trainType)
	if not trainType then return end
	local isCanGet = false
	
	for k,v in pairs(self._TrainingData) do
		if tonumber(v.type) == tonumber(trainType) and 1 == v.state then
			isCanGet = true
			break
		end
	end

	return isCanGet
end

function TrainingModel:getTrainingProgress(datatype)

	if not datatype then return 0 end 
	local trainingNum = 0
	local comNum = 0
	local percent = 0
	-- dump(self._TrainingData,"self._TrainingData==>")
	-- if 3 == datatype then
	-- 	percent = self._seniorSumScore or 0
	-- else
	local _isBeforeLive = self:isBeforeLive()
	for k,v in pairs(self._TrainingData) do
		if tonumber(v.type) == tonumber(datatype) then
			if not (datatype == 3 and _isBeforeLive and tonumber(v.cType) == 2) then
				trainingNum = trainingNum + 1
				if v.state and 0 ~= v.state then
					comNum = comNum + 1
				end
			end
		end
	end
	if 3 == datatype then
		trainingNum = trainingNum - 1
	end

	-- print(comNum,",=========================trainingNum,",trainingNum)
	if 0 ~= trainingNum then
		percent = comNum / trainingNum * 100
		-- percent = string.format("%.2f",percent)
		percent = math.ceil(percent)
	end
	-- end

	return comNum ,percent

end

-- 是否在直播活动中

function TrainingModel:isBeforeLive()
    -- 直播时间
    self._acModel = self._modelMgr:getModel("ActivityModel")
    local acShowList   = self._acModel:getActivityShowList()
    local currTime     = self._userModel:getCurServerTime()
    currTime = tonumber(currTime)
    local liveID = 30001
    -- 直播开始时间
    local liveData
    for k,v in pairs(acShowList) do
        if tonumber(v.activity_id) == tonumber(liveID) then
            liveData = v
            break
        end
    end

    -- 直播前
    local _isBeforeLive = false   
    if liveData then
        local liveStarTime = tonumber(liveData.start_time)
        local liveEndTime = tonumber(liveData.end_time)
        if currTime < liveStarTime then
          _isBeforeLive = true
        end       
    end
    return _isBeforeLive
    -- return true
end

-- 根据得分得到评估数据
function TrainingModel:getEvaluateDataByScore(score)
	local data = tab.evaluate
	-- dump(data,"data==>")
	-- print("========================,",score)
	local evaluateData
	for k,v in pairs(data) do
		local tableScore = v.score
		if tableScore then
			-- 左闭右开
			if tonumber(score) >= tonumber(tableScore[1]) and tonumber(score) < tonumber(tableScore[2]) then
				evaluateData = v
				break
			end
		end
	end
	if not evaluateData then
		evaluateData = data[#data]
	end
	return evaluateData
end

-- 大于某评分的个数
function TrainingModel:getNumByScore(trainScore)
	if not trainScore then
		return 0
	end
	local num = 0
	local tScore = tonumber(trainScore)
	
	-- 高级训练所评评分
	local ssscD = self._serverData and self._serverData.sssc or {}
	if ssscD then
		for k,v in pairs(ssscD) do
			if tonumber(v) >= tScore then 
				num = num + 1
			end
		end
	end

	return num
end

-- 评分为S的个数
function TrainingModel:getScoreSNum(trainType)
	if not trainType then
		trainType = 3
	end
	local num = 0
	local trainData = self:getDataByType(trainType)
	for k,v in pairs(trainData) do
		if v.score and v.score ~= "" then
			local data = self:getEvaluateDataByScore(tonumber(v.score))
			-- print("===============================",data.evaluate)
			if 1 == data.evaluate then
				num = num + 1
			end
		end
	end

	return num
end

-- 根据S的个数获取奖杯数据 金银巴拉巴拉
function TrainingModel:getCupDataBuySNum()
	local cupData = clone(tab.trainingCup)
	table.sort(cupData,function(a,b)
		return a.num < b.num
	end)
	local num = self:getScoreSNum(3)
	-- print("===================金银巴拉巴拉=====",num)
	local data
	-- dump(cupData,"cupData=>")
	for k,v in pairs(cupData) do	
		-- print(num,"===========================",v.num )	
		if v.num > num then
			break
		end	
		data = v
	end

	return data
end

-- 根据关卡ID 获得通关时间
function TrainingModel:getPassTimeById(stageId)
	if not stageId then return 0 end
	local passTime = 0
	if self._TrainingData and self._TrainingData[tonumber(stageId)] then
		passTime = self._TrainingData[tonumber(stageId)].sTime or 0
	end
	
	return passTime
end
-- 屏蔽引导变量
function TrainingModel:setIgnoreGuide(ignoreGuide)
	self._isIgnoreGuide = ignoreGuide
end

function TrainingModel:getIgnoreGuide( )
	return self._isIgnoreGuide
end

-- 主界面活动按钮是否有红点
function TrainingModel:isAcBtnHaveRed( )
	return self._isAcBtnRed
end
function TrainingModel:setAcBtnRed(isRed)
	self._isAcBtnRed = isRed
end

-- 获取直播url地址
function TrainingModel:getTrainLiveUrl()
	return self._trainLiveUrl
end

function TrainingModel:setTrainLiveUrl(trainUrl)
	self._trainLiveUrl = trainUrl
end

return TrainingModel