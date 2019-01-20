--[[
    Filename:    AdvertisementModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-05-19 12:12
    Description: 游戏广告model
--]]

local AdvertisementModel = class("AdvertisementModel", BaseModel)

local AdTimeType = {
	common = 1,
	openServer  =2,
	enterServer = 3,
	siege = 4,
	cross = 5,
	cGodWar = 6,
}
local AdType = {
	commonAD = 0,
	festivalAD = 1
}
local channelType = {
	ios = 2,
	android = 3
}

function AdvertisementModel:ctor()
    AdvertisementModel.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")

    self._isHasShowAd = false  	--是否已弹过广告
    self._isAllOpen = false 	--是否全部开启广告
   	self._adTb = {}   			--广告列表

	--获取当前广告列表
	if not GameStatic.appleExamine then
		self:divideAdByType()
	end
	--排序
	local  comp = function(a,b)
		return a["order"] < b["order"] 
	end
	table.sort(self._adTb, comp)
end

function AdvertisementModel:setAdState(adState)
    self._isHasShowAd = adState
end
function AdvertisementModel:getAdState()
    return self._isHasShowAd
end

function AdvertisementModel:getAdList()
	return self._adTb
end

--按类型分类广告
function AdvertisementModel:divideAdByType()
	for id, currAd in pairs(tab.advertise) do
		repeat
			if self._isAllOpen then
				local temp = clone(currAd)
				temp["order"] = 10000
				table.insert(self._adTb, temp)   -- 广告全部开启  测试用
				break
			end

			--by allow_open
			local isOpen = currAd["allow_open"] == 1
			
			--by 区服+首冲
			local isMatch = self:checkByOtherLimit(currAd)
			
			--lvlCheck
            local lvlCheck = true
            if currAd["level_limit"] then
                local curLvl = self._userModel:getData().lvl or 0
                lvlCheck = curLvl >= currAd["level_limit"]
            end

			--vipCheck
			local vipCheck = true
			if currAd["vip_limit"] then
				local curVip = self._vipModel:getData().level or 0
				vipCheck = curVip >= currAd["vip_limit"]
			end

			--开服X天后可见
			local dayCheck = self:checkAdByDayLimit(currAd)

			--进服X天后可见
			local dayCheck2 = self:checkAdByDayLimit2(currAd)

			if not (isMatch == true and isOpen and lvlCheck and vipCheck and dayCheck and dayCheck2) then
				break
			end

			----特殊广告判断
			local isSpecial = self:divideSpecialAdByType(currAd)   
			if isSpecial then
				break
			end

			----普通广告判断
	  		if currAd["start_type"] == AdTimeType.common then   --自然时间 y-m-d 
	  			local timeCheck = false
				local startTime = TimeUtils.getIntervalByTimeString(currAd["start_time"])
	  			local endTime = TimeUtils.getIntervalByTimeString(currAd["end_time"])
  				local currTime = self._userModel:getCurServerTime()
  				if startTime <= currTime and currTime < endTime then
  					timeCheck = true
  				end

	  			if timeCheck == true then
	  				local curAdData = clone(currAd)
	  				self:setAdOrder(curAdData, startTime, currTime)
	  				table.insert(self._adTb, curAdData)
	  			end
			  			
	  		elseif currAd["start_type"] == AdTimeType.openServer then    --开服时间 h
	  			local timeCheck = false
	  			local secTime = self._userModel:getData().sec_open_time
	  			local startTime, currTime
	  			if secTime then
	  				local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(secTime,"%Y-%m-%d 05:00:00"))
					if secTime < sec_time then   --过零点判断
						sec_time = sec_time - 86400
					end

		  			startTime = sec_time + tonumber(currAd["start_time"])*3600
		  			local endTime = sec_time + tonumber(currAd["end_time"])*3600
		  			currTime = self._userModel:getCurServerTime()
		  			if currTime >= startTime and currTime < endTime then
		  				timeCheck = true
		  			end
	  			end

	  			if timeCheck == true then
	  				local curAdData = clone(currAd)
	  				self:setAdOrder(curAdData, startTime, currTime)
	  				table.insert(self._adTb, curAdData)
	  			end

	  		elseif currAd["start_type"] == AdTimeType.enterServer then   --进服时间 h
	  			local timeCheck = false
				local enterTime = self._userModel:getData()._it 
				local startTime, currTime
				if enterTime then
					local enter_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(enterTime,"%Y-%m-%d 05:00:00"))
					if enterTime < enter_time then   --过零点判断
						enter_time = enter_time - 86400
					end

		  			startTime = enter_time + tonumber(currAd["start_time"])*3600
		  			local endTime = enter_time + tonumber(currAd["end_time"])*3600
		  			currTime = self._userModel:getCurServerTime()
		  			if currTime >= startTime and currTime < endTime then
		  				timeCheck = true
		  			end
				end

				if timeCheck then
					local curAdData = clone(currAd)
					self:setAdOrder(curAdData, startTime, currTime)
	  				table.insert(self._adTb, curAdData)
				end
	  		end
	  	until true
	end
end

function AdvertisementModel:setAdOrder(inAd, inStrT, inCurT)
	if not inStrT or not inCurT then
		return
	end

	local order1 = inAd["order1"]   --不需特殊调整，取order字段
	if not order1 then
		return
	end

	local startT = TimeUtils.formatTimeToFiveOclock(inStrT)
	local curT = TimeUtils.formatTimeToFiveOclock(inCurT)
	local disD = math.modf((curT - startT) / 86400) + 1

	if order1[disD] then
		inAd["order"] = order1[disD]
	else
		inAd["order"] = order1[#order1] or 100000
	end
end

--特殊广告处理
function AdvertisementModel:divideSpecialAdByType(inAd)
	-- 攻城战
	if inAd["start_type"] == AdTimeType.siege then
		local lvlCheck = true
		if inAd["level_limit"] then
			local curLvl = self._userModel:getData().lvl or 0
			lvlCheck = curLvl >= inAd["level_limit"]
		end

		if lvlCheck then
			local siegePic = self._userModel:getData().siegePic or 0
			if inAd["activity_id"] == "ad_siege_open.jpg" and siegePic == 1 then
				table.insert(self._adTb, inAd)
			elseif inAd["activity_id"] == "ad_lv_100.jpg" and siegePic == 2 then
				table.insert(self._adTb, inAd)
			elseif inAd["activity_id"] == "ad_siege_instrument.jpg" and siegePic == 2 then
				table.insert(self._adTb, inAd)
			end
		end

		return true

	-- 跨服竞技场
	elseif inAd["start_type"] == AdTimeType.cross then
		local crossModel = self._modelMgr:getModel("CrossModel")
		local isOpen = crossModel:getOpenActionState()
		local isOpen2 = crossModel:getOpenState()
		if isOpen == 4 and (isOpen2 == 1 or isOpen2 == 2) then
			table.insert(self._adTb, inAd)
		end

		return true

	--跨服诸神
	elseif inAd["start_type"] == AdTimeType.cGodWar then
		local isOpen = self._modelMgr:getModel("CrossGodWarModel"):matchIsOpen()
		local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	    local operateDate = TimeUtils.date("*t", currentTime)
	    local curWakeDay = operateDate.wday
	    if curWakeDay == 1 then 
	        curWakeDay = 7
	    else
	        curWakeDay = curWakeDay - 1
	    end

	    if isOpen and curWakeDay >= 1 and curWakeDay <= 4 then
	    	table.insert(self._adTb, inAd)
	    end

	    return true
	end

	return false
end

--自然时间1/进服时间3 开服X天后可见
function AdvertisementModel:checkAdByDayLimit(currAd)
	if currAd == nil then
		return false
	end

	if currAd["daylimit"] == nil then
		return true
	end

	local secTime = self._userModel:getData().sec_open_time
	if secTime then 
		local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(secTime,"%Y-%m-%d 05:00:00"))
		if secTime < sec_time then   --过零点判断
			sec_time = sec_time - 86400
		end

		local startTime = sec_time + tonumber(currAd["daylimit"])*86400
		local currTime = self._userModel:getCurServerTime()
		if currTime >= startTime then
			return true
		end
	end

	return false
end

--自然时间1/进服时间2 进服X天后可见
function AdvertisementModel:checkAdByDayLimit2(currAd)
	if currAd == nil then
		return false
	end

	if currAd["daylimit2"] == nil then
		return true
	end

	local enterTime = self._userModel:getData()._it 
	if enterTime then 
		local enter_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(enterTime,"%Y-%m-%d 05:00:00"))
		if enterTime < enter_time then   --过零点判断
			enter_time = enter_time - 86400
		end

		local startTime = enter_time + tonumber(currAd["daylimit2"])*86400
		local currTime = self._userModel:getCurServerTime()
		if currTime >= startTime then
			return true
		end
	end

	return false
end

function AdvertisementModel:checkByOtherLimit(currAd)
	--区服匹配
	local isChannelMatch = false 
	local curSec = tonumber(GameStatic.sec)
	if currAd["server"] == 1 then
		isChannelMatch = true 

	elseif currAd["server"] and type(currAd["server"]) == "table" then
		for i,_sec in ipairs(currAd["server"]) do
			if curSec >= _sec[1] and curSec <= _sec[2] then
				isChannelMatch = true
				break
			end
		end
	end	
	
	--首冲广告判断
	local isHasFirstPay = false
	local adName = string.split(currAd["activity_id"], "_")
	local userData = self._userModel:getData()
	local chargNums = userData.statis.snum18 or 0
	if adName[2] == "firstpay.jpg" and chargNums > 0 then  
		isHasFirstPay = true
	end

	if isChannelMatch and not isHasFirstPay then
		return true
	end
	return false
end

return AdvertisementModel