--[[
    Filename:    LimitTeamModel.lua
    Author:      <wangyan02@playcrab.com>
    Datetime:    2016-04-10 14:30:42
    Description: File description
--]]

local LimitTeamModel = class("LimitTeamModel", BaseModel)

function LimitTeamModel:ctor()
	LimitTeamModel.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")

	self._data = {}
end

--是否请求过数据
function LimitTeamModel:setIsReqedById(inState, inId)
	if not self._data[inId] then
		return
	end

	self._data[inId]["isReqed"] = inState
end

function LimitTeamModel:getIsReqedById(inId)
	if not self._data[inId] then
		return false
	end

	return self._data[inId]["isReqed"] or false
end

function LimitTeamModel:setDataById(inData, inId)
	if not inId or not inData then
		return
	end

	inId = tonumber(inId)
	if inData["notice"] then
		table.sort(inData, function(a, b) return a.time < b.time end)
	end

	self._data[inId] = inData
	self._data[inId]["notice"] = inData["notice"] or {}
	self._data[inId]["boxPt"] = inData["boxPt"] or 0
	self._data[inId]["rewardList"] = inData["rewardList"] or {}
	self._data[inId]["freeNum"] = inData["freeNum"] or 0
	self._data[inId]["upFreeTime"] = inData["upFreeTime"] or 0
	--前端添加
	self._data[inId]["noticeNum"] = {[1] = 0, [2] = 0, [3] = 0}    --1整卡 2碎片 3招募
	self._data[inId]["isReqed"] = false
	
	--记录上限值
	local tempNotice = self._data[inId]["notice"]
	local tempNum = self._data[inId]["noticeNum"]
	for i,v in ipairs(tempNotice) do
		if v["type"] == 1 and tempNum[1] then   --整卡
			tempNum[1] = tempNum[1] + 1   --10

		elseif v["type"] == 2 and tempNum[2] then
			tempNum[2] = tempNum[2] + 1     --40

		elseif v["type"] == 3 and tempNum[3] then
			tempNum[3] = tempNum[3] + 1     --3
		end
	end
end

function LimitTeamModel:getDataById(inId)
	return self._data[inId] or {}
end

function LimitTeamModel:insertNoticeById(inData)
	if not (inData and type(inData) == "table") then
		return
	end

	for i,_info in ipairs(inData) do
		repeat		
			local acData = self._data[_info["acId"]]
			if not acData or next(acData) == nil then
				break
			end

			local replaceId = 1   --被替换的cellId
			local lastT

			if _info["type"] == 1 and acData["noticeNum"] and acData["noticeNum"][1] and acData["noticeNum"][1] >= 10 then   --整卡替换10
				for i,v in ipairs(acData["notice"]) do
					if v["type"] == 1 and (lastT == nil or lastT > v["time"]) then
						lastT = v["time"]
						replaceId = i
					end
				end

			elseif _info["type"] == 2 and acData["noticeNum"] and acData["noticeNum"][2] and acData["noticeNum"][2] >= 40 then  --碎片替换40
				for i,v in ipairs(acData["notice"]) do
					if v["type"] == 2 and (lastT == nil or lastT > v["time"]) then
						lastT = v["time"]
						replaceId = i
					end
				end

			elseif _info["type"] == 3 and acData["noticeNum"] and acData["noticeNum"][3] and acData["noticeNum"][3] >= 3 then  --碎片替换3
				for i,v in ipairs(acData["notice"]) do
					if v["type"] == 3 and (lastT == nil or lastT > v["time"]) then
						lastT = v["time"]
						replaceId = i
					end
				end

			else 	--添加
				replaceId = #acData["notice"] + 1
				if acData["noticeNum"][_info["type"]] then
					acData["noticeNum"][_info["type"]] = acData["noticeNum"][_info["type"]] + 1
				end
			end
			acData["notice"][replaceId] = _info
			self:reflashData(tostring(replaceId))  
		until true
	end
end

function LimitTeamModel:updateData(inData) 
    local function updateSubData(inSubData, inUpData)
        if type(inSubData) == "table" then
            for k,v in pairs(inUpData) do
                local backData = updateSubData(inSubData[k], v)
                inSubData[k] = backData
            end
            return inSubData
        else 
            return inUpData
        end
    end

    for k,v in pairs(inData) do
		local acId = tonumber(k)
		for p,q in pairs(v) do
	        local backData = updateSubData(self._data[acId][p], q)
	        self._data[acId][p] = backData
	    end
	end
end

function LimitTeamModel:getRewardListById(inId)
	--获取宝箱奖励数据
    local boxRewards = {}

    for i,v in ipairs(tab.limitTeamBox) do
    	if v["dynamic"] == inId then
    		table.insert(boxRewards, v)
    		boxRewards[#boxRewards]["index"] = i
    	end
    end
    table.sort(boxRewards, function(a,b) return a.index < b.index end)

    return boxRewards
end

function LimitTeamModel:isTodayHasFreeNumById(inId)
	local acData = self._data[inId]
	if not acData then
		return false
	end

	local freeNum = acData["freeNum"] or 0    --已使用次数
	local upFreeTime = acData["upFreeTime"] or 0
	local curTime = self._userModel:getCurServerTime()
	local time1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
	if curTime < time1 then   --过零点判断
		time1 = time1 - 86400
	end
	if freeNum == 0 or upFreeTime < time1 then
		return true
	end

	return false
end

function LimitTeamModel:isAcRedPoint(inId)
	local acData = self._data[inId]
	if not acData then
		return false
	end

	--免费次数
	if self:isTodayHasFreeNumById(inId) then
		return true
	end

	--有宝箱未领取
	local sysLimitTeamBox = self:getRewardListById(inId)
	for i=1, 7 do
		local curScore = acData["boxPt"] or 0
        local needScore = sysLimitTeamBox[i].score
        local rwdList = acData["rewardList"] or {}
        local sysIndex = sysLimitTeamBox[i]["index"]
        local isGet = rwdList[tostring(sysIndex)]

        if curScore >= needScore and isGet ~= 1 then
        	return true
        end
	end

	return false
end

function LimitTeamModel:isMainViewRedPoint()
	for i,v in pairs(self._data) do
		if self:isAcRedPoint(tonumber(i)) then
			return true
		end
	end

	return false
end

return LimitTeamModel