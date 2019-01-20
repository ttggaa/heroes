--[[
    Filename:    WorldCupModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-05-8 19:31:51
    Description: 竞猜活动
--]]

local WorldCupModel = class("WorldCupModel", BaseModel)

function WorldCupModel:ctor()
	WorldCupModel.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")

	self:onInit()

	--奖励定时更新
	local timeLab = tab.setting["GUESS_REWARD_TIME"].value
	local time = string.split(timeLab, ":")
    self:registerTimer(tonumber(time[1]), tonumber(time[2]), GRandom(1, 5), function ()
    	self:refreshAcData()
    end)
end

function WorldCupModel:onInit()
	self._betList = {}
	self._guessInfo = {[1] = {}, [2] = {}, [3] = {}}  --1当前 / 2已下注 / 3已结束
	self._unShowInfo = {}    --当前不需展示的比赛，之后时间到了需要在线刷新出来
	self._teams = {[32] = {}, [16] = {}, [8] = {}, [4] = {}, [2] = {}}   --32强对局队伍
	self._cathectic = {}    --统计值
	self._is32Over = true --32强是否结束
end

function WorldCupModel:setData(inData)
	self:onInit()

	local guessData = inData["data"] or {}
	self._betList = inData["list"] or {}
	local info = inData["info"] or {}

	table.sort(guessData, function(a, b)
		return a["id"] < b["id"]
		end)
	
	for k,v in pairs(guessData) do
		local hasData = self._betList[tostring(v["id"])]
		--当前 / 已下注 / 已结束
		if hasData then    --已投注
			local winTeam = v["gamesesult"]  ---1没结束 / 0平局 / 队伍id
			local selectTeam = hasData[2]
			if winTeam >= 0 then    --投注的比赛已结束
				table.insert(self._guessInfo[3], v)
			else
				table.insert(self._guessInfo[2], v)
			end
		else
			local curTime = self._userModel:getCurServerTime()
			local start_time2 = TimeUtils.getIntervalByTimeString(v["start_time2"])
			local end_time2 = TimeUtils.getIntervalByTimeString(v["end_time2"])
			if curTime >= start_time2 and curTime < end_time2 and v["allow_open"] == 1 then
				table.insert(self._guessInfo[1], v)
			else
				table.insert(self._unShowInfo, v)
			end
		end

		--赛程
		local groupId = v["group_id"]
		if groupId == 32 then
			local tempNum = tonumber(string.sub(v["game_id"], 11, string.len(v["game_id"])))
			if not self._teams[groupId][tempNum] then
				self._teams[groupId][tempNum] = {}
			end
			table.insert(self._teams[groupId][tempNum], v)

			if not v["gamesesult"] or v["gamesesult"] == -1 or v["gamesesult"] == "" then
				self._is32Over = false
			end
		else
			table.insert(self._teams[v["group_id"]], v)
		end
	end
end

function WorldCupModel:getDataByType(inType)
	if inType <= 3 then
		return self._guessInfo[inType]
	elseif inType == 4 then
		return self._teams[32]
	elseif inType == 6 then
		return self._teams
	end
	return {}
end

function WorldCupModel:setCathecticInfo(inData)
	self._cathectic = inData
end

function WorldCupModel:getCathecticInfo()
	return self._cathectic
end

function WorldCupModel:setIsReqed(inData)
	self._isReqed = inData
end

function WorldCupModel:getIsReqed(inType)
	return self._isReqed
end 

function WorldCupModel:setAcData(inData)
	self._acData = inData
end

function WorldCupModel:getAcData()
	return self._acData or {}
end 

function WorldCupModel:setIsOpened(inData)   --是否打开过界面，用来红点判断
	self._isOpened = inData
end

function WorldCupModel:getBetList()
	return self._betList
end

function WorldCupModel:getIs32Over()
	return self._is32Over
end

function WorldCupModel:refreshGuessInfo()
	local curTime = self._userModel:getCurServerTime()
	local tempData = self._guessInfo[1]
	if not tempData or next(tempData) == nil then
		return
	end

	for i,v in ipairs(self._unShowInfo) do    --需要展示时间到了
		local curTime = self._userModel:getCurServerTime()
		local start_time2 = TimeUtils.getIntervalByTimeString(v["start_time2"])
		local end_time2 = TimeUtils.getIntervalByTimeString(v["end_time2"])
		if curTime >= start_time2 and curTime < end_time2 and v["allow_open"] == 1 then
			table.insert(tempData, v)
			table.remove(self._unShowInfo, i)
		end
	end

	local hasEnd = {}
	for i=#tempData, 1, -1 do
		local data = tempData[i]
		local start_time2 = TimeUtils.getIntervalByTimeString(data["start_time2"])
		local end_time2 = TimeUtils.getIntervalByTimeString(data["end_time2"])
		local game_time = TimeUtils.getIntervalByTimeString(data["game_time"])
		if not (curTime >= start_time2 and curTime < end_time2 and data["allow_open"] == 1) then   --不需展示
			table.remove(tempData, i)
		elseif curTime >= game_time then    --显示但投注已截止
			local temp = tempData[i]
			table.insert(hasEnd, temp)
			table.remove(tempData, i)
		end
	end

	table.sort(tempData, function(a, b)
		return a["id"] < b["id"]
		end)

	table.sort(hasEnd, function(a, b)
		return a["id"] < b["id"]
		end)

	for i,v in ipairs(hasEnd) do
		table.insert(tempData, v)
	end
end

function WorldCupModel:refreshHasEndInfo()
	local tempData = self._guessInfo[3]
	table.sort(tempData, function(a, b)
		local game_time1 = TimeUtils.getIntervalByTimeString(a["game_time"])
		local game_time2 = TimeUtils.getIntervalByTimeString(b["game_time"])
		return game_time1 > game_time2
		end)

	if #tempData > 6 then
		for i=#tempData, 7, -1 do
			table.remove(tempData, i)
		end
	end
end

function WorldCupModel:betSuccess(teamId, betData)
	local tempData = self._guessInfo[1]
	teamId = tonumber(teamId)
	for i=#tempData, 1, -1 do
		if tempData[i]["id"] == teamId then
			local temp = clone(tempData[i])
			temp["jnum"] = (temp["jnum"] or 0) + 1
			table.remove(tempData, i)
			table.insert(self._guessInfo[2], temp)
			self._betList[tostring(teamId)] = betData
			return
		end
	end
end

function WorldCupModel:refreshAcData()
	if not self._acData or next(self._acData) == nil then
		return 
	end

	local curTime = self._userModel:getCurServerTime()
	local limitLvl = self._acData.level_limit or 0
    local userLvl = self._userModel:getData().lvl or 0
    -- 等级限制
    local isOk = limitLvl <= userLvl
    if userLvl < limitLvl or curTime >= self._acData.end_time or curTime < self._acData.start_time then
        return
    end

	self._serverMgr:sendMsg("GuessServer", "getInfos", {}, true, {}, function(result, errorCode)
        self:setIsReqed(true)
        self._serverMgr:sendMsg("GuessServer", "getCathecticInfo", {}, true, {}, function(result, errorCode)
            self:reflashData()
        end)
    end)
end

function WorldCupModel:isMainViewRedPoint()
	if self._isOpened then
		return false
	end

	self:refreshGuessInfo()   --刷新比赛状态

	local tempData = self._guessInfo[1]
	local curTime = self._userModel:getCurServerTime()
	for i,v in ipairs(tempData) do
		local start_time2 = TimeUtils.getIntervalByTimeString(v["start_time2"])
		local end_time2 = TimeUtils.getIntervalByTimeString(v["end_time2"])
		local game_time = TimeUtils.getIntervalByTimeString(v["game_time"])
		if curTime >= start_time2 and curTime < end_time2 and curTime < game_time and v["allow_open"] == 1 then
			return true
		end
	end

	return false
end

return WorldCupModel