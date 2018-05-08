--
-- Author: huangguofang
-- Date: 2018-03-16 11:41:58
--

local RuneLotteryModel = class("RuneLotteryModel", BaseModel)

RuneLotteryModel.lotteryType = 37
function RuneLotteryModel:ctor()
    RuneLotteryModel.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
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

function RuneLotteryModel:setData(data)
    -- print("===================123123123===========")
    self._isNeedUpdate = false
    self._serverData = data or {}   
    if not self._acModel then
        self._acModel = self._modelMgr:getModel("ActivityModel")
    end
    self._goodsData = {}
    -- 活动数据
    self._acData = self._acModel:getAcShowDataByType(RuneLotteryModel.lotteryType)
    dump(self._acData,"self._acData==>",5)
    self._acOpenId = self._acData._id or 46
    self._activityId = self._acData.activity_id or 100
    print(self._activityId,"=========self._acOpenId====",self._acOpenId)
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

function RuneLotteryModel:updateServerData(data)    
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


function RuneLotteryModel:getGoodsData()    
    return self._goodsData
end

-- 
function RuneLotteryModel:getLotteryData() 
    return self._serverData or {}
end

-- 
function RuneLotteryModel:getcircle()
    return self._circle or 1
end

-- 
function RuneLotteryModel:getAcOpenID()
    return self._acOpenId
end

-- 
function RuneLotteryModel:getActivityID()
    return self._activityId
end

-- 获取奖励信息
function RuneLotteryModel:getRewardData()
    print("===========self._activityId===",self._activityId)
    if not self._activityId then return {} end
    if not self._lotteryReward then  
        self._lotteryReward = tab.lotteryReward
    end

    local data = self._lotteryReward[tonumber(self._acOpenId)]
    return data or {}
end

-- 获取商店数据
function RuneLotteryModel:getShopData()
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

function RuneLotteryModel:isLotteryOpen()
	local isOpen = false
	if not self._acData then
		self._acData = self._acModel:getDataByType(RuneLotteryModel.lotteryType)
	end
    -- dump(self._acData,"RuneLotteryModel==>",5)
    local startTime = self._acData and self._acData.start_time or 0
    local endTime = self._acData and self._acData.end_time or 0
    local currTime = self._userModel:getCurServerTime()

    -- print("==================,currTime====",currTime)
	isOpen = startTime <= currTime and endTime > currTime
    return isOpen
end

function RuneLotteryModel:isLuckyLotteryRed()
    return false
end

return RuneLotteryModel