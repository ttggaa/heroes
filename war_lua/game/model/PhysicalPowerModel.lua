--
-- Author: huangguofang
-- Date: 2016-10-12 19:26:40
-- description: 领取体力model

local PhysicalPowerModel = class("PhysicalPowerModel", BaseModel)

function PhysicalPowerModel:ctor()
    PhysicalPowerModel.super.ctor(self)
    
    self._physicalData = {}
    self._serverData = {}
    self._userModel = self._modelMgr:getModel("UserModel")
    self:initPhysicalData()

end

function PhysicalPowerModel:initPhysicalData()

	self._physicalData = clone(tab.dailyPhyscal)
	-- if self._userModel:getData().award then
	-- 	self._serverData = self._userModel:getData().award.dailyPy or {}	
	-- end
	-- print("==========================",next(self._serverData))
    self:updatePhysicalPowerData()
    self:registerTaskTimer()
end

function PhysicalPowerModel:updatePhysicalPowerData()
	--四种种状态  0：时间未到不可领取 ; 1：已可领 ; 2：可领 ; 3：补领
	
	if self._userModel:getData().award then
		self._serverData = self._userModel:getData().award.dailyPy or {}
	else
		self._serverData = {}	
	end

 	--时间判断
 	local curTime = self._userModel:getCurServerTime()   --当前时间
	-- print("===updatePhysicalPowerData===更新体力数据==============",curTime)

 	local nextTimeStr = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))  
 	if curTime < nextTimeStr then   --过零点判断
       nextTimeStr = nextTimeStr - 86400
    end	
    --下次刷新时间
    nextTimeStr = nextTimeStr + 86400  
 
 	for i=1,3 do
 		local PhyData = self._physicalData[i]

		PhyData.canNotGet = false   --未到时间
		PhyData.isTimeOut = false 	--时间过期
		PhyData.isCanGet = false 	--可以正常领取

 		local timeStart = "00:00"
 		local timeEnd = "00:00"
 		if PhyData and PhyData.timeLimit then
 			timeStart = PhyData.timeLimit[1] or 0
			timeEnd = PhyData.timeLimit[2] or 0
		end
		local startT = string.split(timeStart, ':')
		local endT = string.split(timeEnd, ':')
		local timeStartStr = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d " .. startT[1] .. ":" .. startT[2] .. ":00"))
		local timeEndStr = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d " .. endT[1] .. ":" .. endT[2] .. ":00"))

		-- print("=========timeStartStr=========",timeStartStr)
		-- print("=========timeEndStr===========",timeEndStr)
		-- print("=========currTime=============",curTime)
		-- print("=========nextTimeStr=============",nextTimeStr)

		-- 00：00 -- 05:00 特殊性处理
	 	if timeStartStr < nextTimeStr then
		    if timeStartStr > curTime then
		    	PhyData.canNotGet = true
		    	PhyData.state = 0
		    else
		    	--开始时间大于当前时间
		    	--结束时间小于当前时间 --可领取
		    	if timeEndStr > curTime then
		    		PhyData.isCanGet = true
		    		
		    	else
		    		PhyData.isTimeOut = true   --时间过期
		    	end
		    end
		    if PhyData.isTimeOut then
		    	if self._serverData[tostring(PhyData.id)] and self._serverData[tostring(PhyData.id)] > 0 then
		    		PhyData.state = 1
		    	else
		    		PhyData.state = 3 	-- 补领
		    	end
		    end 
		    if PhyData.isCanGet then
		    	if self._serverData[tostring(PhyData.id)] and self._serverData[tostring(PhyData.id)] > 0 then
		    		PhyData.state = 1
		    	else
		    		PhyData.state = 2 	-- 可领
		    	end
		    end 
		else
			-- 处于5点之间 只有补领或者已领
			if self._serverData[tostring(PhyData.id)] and self._serverData[tostring(PhyData.id)] > 0 then
	    		PhyData.state = 1
	    	else
	    		PhyData.state = 3 	-- 补领
	    	end
		end

 	end
 	--分发事件
 	self:reflashData()

end

-- 设置刷新状态定时器
function PhysicalPowerModel:registerTaskTimer()
    local registerTab = {}
    registerTab[5 .. ":" .. 0 .. ":" .. 0] = true   --5点刷新  --延迟两秒刷新数据
    for k, v in pairs(self._physicalData) do
        if v.timeLimit then            
            local time1 = string.split(v.timeLimit[1], ':')
            local time2 = string.split(v.timeLimit[2], ':')
            registerTab[time1[1] .. ":" .. time1[2] .. ":" .. 0] = true
            registerTab[time2[1] .. ":" .. time2[2] .. ":" .. 0] = true
        end
    end
    for time, _ in pairs(registerTab) do
        local list = string.split(time, ":")
        --注册定时器

        self:registerTimer(tonumber(list[1]), tonumber(list[2]), tonumber(list[3]), specialize(self.updatePhysicalPowerData, self))
    end

    -- self:registerTimer(5, 0, 0, specialize(self.updatePhysicalPowerData5, self))
end

function PhysicalPowerModel:getData()
	return self._physicalData
end

function PhysicalPowerModel:isHaveRedTag()
	-- 是否有可领的
	local isHaveTip = false -- 1 ~= SystemUtils.loadAccountLocalData("ACTIVITY_99999")
	for k,v in pairs(self._physicalData) do
		if v.state and (2 == v.state or 3 == v.state) then
			isHaveTip = true			
		end
		-- 如果有补领的奖励
        --[[
		if v.state and 3 == v.state then			
			SystemUtils.saveAccountLocalData("ACTIVITY_99999",0)
		end
        ]]
	end

	return isHaveTip
end

return PhysicalPowerModel