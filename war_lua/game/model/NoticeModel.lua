--[[
    Filename:    NoticeModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-02 17:23:46
    Description: File description
--]]
--[[
	GUANGBO_vipgift VIP周礼包类型
]]

local NoticeModel = class("NoticeModel", BaseModel)

function NoticeModel:ctor()
    NoticeModel.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --随机种子
    
    self._data = {}       		--普通广告
    self._topLevelData = {} 	--优先级最高
    self._limitTeam = {} 		--限时兵团
    self._weekActivity = {}		--周礼包

    -- self._scheTime 			--检测时间
    self._sys = {} 				--循环播放总列表
    self._sysShow = {} 			--当前需要滚动的信息
    self._sysFlags = {}  		--当前需要滚动的信息flag
end

function NoticeModel:getData()
    return self._data or {}
end
 
-- 子类覆盖此方法来存储数据
function NoticeModel:setData(data)
	-- self._data =  data
	self:insertData(data)
end

function NoticeModel:insertData(data)
	if data == nil then 
		return 
	end
	for k,v in pairs(data) do
		if v.type == nil or v.type == 0 then
			-- 限时活动
			if v["bdType"] and v["bdType"] == "limitTeam" then
				table.insert(self._limitTeam, v)

			-- 周活动
			elseif self._specailType and self._specailType == v.id then
				table.insert(self._weekActivity, v)

			-- sys(间隔循环播放)
			elseif v["adType"] == "sys" then
				table.insert(self._sys, v)

				--加flag识别标志
				local curTime = self._userModel:getCurServerTime()
				local flag = curTime .. math.random(1, 1000)
				v.flag = flag

				if self._scheTime == nil then
					local nextT = self:getSysCycleNextTime(v)
					self._scheTime = nextT
					self:cycleNoticeScheduler()
				end

				--当前是否展示
				local isShow = self:checkSysIsShow(v)
				if isShow then
					table.insert(self._sysShow, v)
				end
				
			else
				-- 普通公告
				table.insert(self._data, v)
			end
		else
			if v.num == nil or v.num == 0 then v.num = 1 end
			for i=1,v.num do
				table.insert(self._topLevelData, 1, v)
			end
		end
	end

	self:reflashData()
end

function NoticeModel:cycleNoticeScheduler()
	self._modelMgr:clearSelfTimer(self)
	if self._scheTime == nil then
		return
	end

	local curTime = self._userModel:getCurServerTime()

	local hour = TimeUtils.getDateString(self._scheTime, "%H")
	local min = TimeUtils.getDateString(self._scheTime, "%M")
	local sec = TimeUtils.getDateString(self._scheTime, "%S")
	print("=====下次滚动:",TimeUtils.getDateString(self._scheTime), #self._sys, #self._sysShow)
    self:registerTimer(hour, min, sec, function ()
    	-- self._sysShow = {}
		local curTime = self._userModel:getCurServerTime()
		
		-- local temp
		for i=#self._sys, 1, -1 do
			--移除过期信息
			local info = self._sys[i]
			if info["end"] <= curTime then		
				table.remove(self._sys, i)

			else 
				--获取展示信息							
				local isShow = self:checkSysIsShow(info)
				local flag = info["flag"]
				if isShow and self._sysFlags[flag] == nil then
					table.insert(self._sysShow, info)
					self._sysFlags[flag] = 1
				end
			end
		end

		print("****当前滚动:", TimeUtils.getDateString(curTime), hour, min, sec, #self._sys, #self._sysShow)
        self:reflashData()
    end)
end

--当前是否可滚动
function NoticeModel:checkSysIsShow(inData)
	local curTime = self._userModel:getCurServerTime()
	if inData["start"]  <= curTime and inData["end"] > curTime then
		local lastT = inData["lastT"]

		--没有播过直接播
		if not lastT then
			return true
		end

		--超过间隔时间
		local disT = curTime - lastT
		if disT >= inData["interval"] then
			return true
		end
	end

	return false
end

--下次循环开始时间
--支持(开始时间>当前时间)的消息
function NoticeModel:getSysCycleNextTime(inData)
	local curTime = self._userModel:getCurServerTime()
	local lastT = inData["lastT"]
	local nextT

	if curTime >= inData["start"] and curTime < inData["end"] then  --播放中
		if not lastT then
			nextT = curTime + inData["interval"]
		else
			nextT = lastT + inData["interval"]
		end
	
	elseif curTime < inData["start"] then  	--未开始
		nextT = inData["start"]

	else 								--结束
		nextT = inData["end"]
	end
	
	return nextT
end

--对已有公告信息排序
function NoticeModel:setSpecailType(type_)
	self._specailType = type_
end

function NoticeModel:getNoticeData()
	-- 调整顺序找vv
	-- 紧急情况，或者单次出现优先级最搞
	if #self._topLevelData > 0 then 
		local tempData = self._topLevelData[1]
		table.remove(self._topLevelData, 1)
		return tempData
	end

	-- wangyan
	-- idip循环通知
	if #self._sysShow > 0 then
		local tempData = self._sysShow[1]
		table.remove(self._sysShow, 1)

		local flag = tempData["flag"]
		self._sysFlags[flag] = nil
		
		--标记播放时间
		local curTime = self._userModel:getCurServerTime()
		tempData["lastT"] = curTime

		--是否修改定时器
		local temp 
		for i,v in ipairs(self._sys) do
			if v["flag"] == flag then
				v["lastT"] = curTime
			end

			--下次检测时间  temp距当前时间最小差值
			local nextT = self:getSysCycleNextTime(v)
			if not self._scheTime or nextT > curTime and nextT - self._scheTime > 0 and (not temp or nextT - self._scheTime < temp) then
				self._scheTime = nextT
				temp = nextT - self._scheTime
			end
		end

		if temp then
			self:cycleNoticeScheduler()
		end

		return tempData
	end

	-- 调整顺序找树楠
	-- 进入vip周礼包页面，活动推送优先级最高
	if self._specailType ~= nil and #self._weekActivity > 0 then 
		local tempData = self._weekActivity[1]
		table.remove(self._weekActivity, 1)
		return tempData
	end

	-- 调整顺序找王燕
	-- 限时活动
	if #self._limitTeam > 0 then 
		local tempData = self._limitTeam[1]
		table.remove(self._limitTeam, 1)
		return tempData
	end

	-- 调整顺序找树楠
	-- vip周礼包不在页面内，优先级下调
	if #self._weekActivity > 0 then 
		local tempData = self._weekActivity[1]
		table.remove(self._weekActivity, 1)
		return tempData
	end

	if #self._data <= 0 then 
		return nil
	end
	local tempData = self._data[1]
	table.remove(self._data, 1)
	return tempData
end

return NoticeModel