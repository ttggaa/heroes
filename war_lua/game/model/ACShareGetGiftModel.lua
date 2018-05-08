--[[
    Filename:    ACShareGetGiftModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-3-23 17:26:00
    Description: 评论引导
--]]

local ACShareGetGiftModel = class("ACShareGetGiftModel", BaseModel)

--[[ 1已分享 2等级不足/服务器时间 3条件未达成 4可分享 
1、xx阵营集齐y个兵团
2、激活一套指定ID宝物，0为任意
3、竞技场累计胜利xx场
4、获得指定ID兵团，0为任意
5、获得指定ID英雄，0为任意
6、英雄交锋单局胜场xx场
]]

function ACShareGetGiftModel:ctor()
	ACShareGetGiftModel.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")
	self._acModel = self._modelMgr:getModel("ActivityModel")

	self._acId = 999
	self._data = {}
end

--开启等级限制判断
function ACShareGetGiftModel:checkLvlLimit(inType)
	local limits = {
		[6001] = "Team",
		[6002] = "Treasure",
		[6003] = "Arena",
		[6004] = "Crusade",
		[6005] = "Hero",
		[6006] = "",
	}

	if inType == 6006 then  --英雄交锋
		local isLV, lv, isTime, time = self:checkHeroDuelLimit()
		if isLV == false then
			return false, lv .. "级"
		end

		if isTime == false then
			return false, time .. "后"
		end
 
		return true

	elseif inType == 6005 then  --英雄格鲁
		local curLv = self._userModel:getData().lvl
		if curLv >= 6 then
			return true
		else
			return false, "6级"
		end

	else
		if SystemUtils["enable" .. limits[inType]] then
			local isOpen, isBeOpen, level = SystemUtils["enable".. limits[inType]]()
			return isOpen, level .. "级"
		end
	end

	return false, ""
end

function ACShareGetGiftModel:checkHeroDuelLimit()
	local sysData = tab.sTimeOpen[104]
	local name = sysData.system
    local openLevel = sysData.level
    local openTime = sysData.opentime
    local openHour = sysData.openhour
	
	local level = self._userModel:getPlayerLevel()
    local serverBeginTime = self._userModel:getData().sec_open_time or 0
    local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
    local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    local openDay = openTime-1
    local openHourStr = string.format("%02d:00:00",openHour)
    local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHourStr))

	if level == nil or openLevel == nil or openTime == nil or openHour == nil then
		return false, 80
	end
	return (level >= openLevel), openLevel, nowTime >= openTime, TimeUtils:getTimeDisByFormat(math.max(openTime - nowTime))
end

--1【巢穴】xx阵营集齐y个兵团
function ACShareGetGiftModel:checkCondition6001()
	local id = 6001
	local isOpen, openStr = self:checkLvlLimit(id)
	if isOpen == false then
		return 2, openStr 
	end

	local sysData = tab.shareActivity[id]
	local teamModel = self._modelMgr:getModel("TeamModel")
	local stageType = TeamUtils.teamRaceType[sysData["task_para"][1]]
	local teams = teamModel:getClassTeam(stageType)
	if #teams >= 5 then
		return 4, #teams
	end

	return 3, #teams
end

--2【宝物】激活一套指定ID宝物，0为任意
function ACShareGetGiftModel:checkCondition6002(inData)
	local id = 6002
	local isOpen, openStr = self:checkLvlLimit(id)
	if isOpen == false then
		return 2, openStr 
	end
	
	local sysData = tab.shareActivity[id]
	local checkId = sysData["task_para"][1]

	local treasureModel = self._modelMgr:getModel("TreasureModel")
	local boxId
	if checkId ~= 0 then
		local boxData = treasureModel:getTreasureById(checkId)
		if boxData ~= nil then
			return 4, boxId
		end
	else
		local boxId = treasureModel:getHightScoreTreasure()
		if boxId ~= nil then
			return 4, tonumber(boxId)
		end
	end

	return 3
end

--3【竞技场】累计胜利xx场
function ACShareGetGiftModel:checkCondition6003(inData)
	local id = 6003
	local isOpen, openStr = self:checkLvlLimit(id)
	if isOpen == false then
		return 2, openStr 
	end

	local sysData = tab.shareActivity[id]
	local aimNum = sysData["task_para"][1]
	local curNum = self:getMaxNumByAcStsId("sts86")
	if curNum >= aimNum then
		return 4, curNum
	end

	return 3, curNum
end

--4【兵团】获得指定ID兵团，0为任意
function ACShareGetGiftModel:checkCondition6004(inData)
	local id = 6004
	local isOpen, openStr = self:checkLvlLimit(id)
	if isOpen == false then
		return 2, openStr 
	end

	local sysData = tab.shareActivity[id]
	local teamId = sysData["task_para"][1]

	local teamModel = self._modelMgr:getModel("TeamModel")
	if teamId ~= 0 then
		local teamData = teamModel:getTeamAndIndexById(teamId)
		if teamData ~= nil then
			return 4, teamId
		end
	else
		local teamId = teamModel:getTeamMaxFightScore()
		if teamId ~= nil then
			return 4, teamId
		end
	end

	return 3
end

--5【英雄】获得指定ID英雄，0为任意
function ACShareGetGiftModel:checkCondition6005(inData)
	local id = 6005
	local isOpen, openStr = self:checkLvlLimit(id)
	if isOpen == false then
		return 2, openStr 
	end

	local sysData = tab.shareActivity[id]
	local heroId = sysData["task_para"][1]

	local heroModel = self._modelMgr:getModel("HeroModel")
	if heroId ~= 0 then
		local heroData = heroModel:checkHero(heroId)
		if heroData == true then
			return 4, heroId
		end
	else
		local heroId = heroModel:getTopScoreHero()
		if heroId ~= nil then
			return 4, heroId
		end
	end

	return 3
end

--6【英雄交锋】单局胜场xx场
function ACShareGetGiftModel:checkCondition6006(inData)
	local id = 6006
	local isOpen, openStr = self:checkLvlLimit(id)
	if isOpen == false then
		return 2, openStr 
	end

	local sysData = tab.shareActivity[id]
	local aimNum = sysData["task_para"][1]
	local curNum = self:getMaxNumByAcStsId("sts87")
	if curNum >= aimNum then
		return 4, curNum
	end

	return 3, curNum
end

--sts86竞技场累计胜利次数 
--sts87英雄交锋单局最高胜利场次
function ACShareGetGiftModel:getMaxNumByAcStsId(inSts)
    if not inSts then return end
    
    local startTime, endTime = self:getAcTime()
    local curNum = 0
    local activityStatic = self._userModel:getActivityStatis() or {}
    -- print("*******************************************time", startTime, endTime)
    -- dump(activityStatic, "activityStatic")
    for k,v in pairs(activityStatic) do
        local timeStr = string.sub(tostring(k), 1, 4) .. "-" .. string.sub(tostring(k), 5, 6) .. "-" .. string.sub(tostring(k), -2)  .. " 05:00:00"
        local time = TimeUtils.getIntervalByTimeString(timeStr)
        if time >= startTime and time < endTime then
        	if v[inSts] then
        		if inSts == "sts86" then
	        		curNum = curNum + tonumber(v[inSts])

	        	elseif inSts == "sts87" then
	        		if curNum < tonumber(v[inSts]) then
	        			curNum = tonumber(v[inSts])
	        		end
	        	end
        	end
        end
    end
    return curNum
end

function ACShareGetGiftModel:getAcTime()
	local startTime = 0
    local endTime = 0
    local showList = self._acModel:getActivityShowList() or {}
    local currTime = self._userModel:getCurServerTime() 
    for k,v in pairs(showList) do
        if self._acId == tonumber(v.activity_id) then
            if next(v) and v.start_time <= currTime and v.end_time > currTime then
                startTime = v.start_time  -- - 86400*2
                endTime = v.end_time
                break
            end
        end        
    end

    return startTime, endTime
end

function ACShareGetGiftModel:setData()
	local acSpecialList = self._acModel:getActivitySpecialData() or {}
	-- dump(acSpecialList, "acSpecialList")
	local acData = acSpecialList[tostring(self._acId)] or {}
	self._data = {}

	for i=1, 6 do
		local _id = tostring(6000 + i)
		if acData[_id] == nil then   --未领状态
			local state, info = self["checkCondition600" .. i](self)
			local param = {
				id = 6000 + i,
				state = state,
				tipInfo = info
			}
			table.insert(self._data, param)
		else
			table.insert(self._data, {id = 6000 + i, state = 1})  --已分享
		end
	end

	self:sortDataByType()
end

function ACShareGetGiftModel:getData()
	return self._data
end

--已分享
function ACShareGetGiftModel:refreshShareState(inId)
	if inId == nil then
		return
	end 

	for i=#self._data, 1, -1 do
		if self._data[i]["id"] == tonumber(inId) then
			self._data[i]["state"] = 1
			local data = self._data[i]
			table.remove(self._data, i)
			table.insert(self._data, data)
			break
		end
	end
end

function ACShareGetGiftModel:sortDataByType()
	local list = {[1] = {}, [2] = {}, [3] = {}, [4] = {}}
	for i=#self._data, 1, -1 do
		local v = self._data[i]
		if v["state"] and list[v["state"]] then
			table.insert(list[v["state"]], v)
		end
	end

	self._data = {}
	for i=#list, 1, -1 do
		table.sort(list[i], function(a,b) return a.id < b.id end)
	end

	for i=#list, 1, -1 do
		for k=1, #list[i]do
			table.insert(self._data, list[i][k])
		end
	end
end

function ACShareGetGiftModel:checkAcRedPoint()
	if next(self._data) == nil then
		self:setData()
	end

	if self._isShowList == nil then
		self._isShowList = {}
	end

	for i,v in ipairs(self._data) do
		if not self._isShowList[v["id"]] then
			if v["state"] ~= 1 then
				if v["state"] == 4 then
					return true
				else
					local state, info = self["checkCondition" .. v["id"]](self)
					if state == 4 then
						return true
					end
				end
			end
		end
	end

	return false
end

--触发过的红点不再显示红点
function ACShareGetGiftModel:recordHasShowRedPoint()
	if self._isShowList == nil then
		self._isShowList = {}
	end

	for i,v in ipairs(self._data) do
		if v["state"] == 1 or v["state"] == 4 then
			self._isShowList[v["id"]] = 1
		end
	end
end

return ACShareGetGiftModel
