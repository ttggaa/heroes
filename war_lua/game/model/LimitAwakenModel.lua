--[[
    Filename:    LimitAwakenModel.lua
    Author:      <wangyan02@playcrab.com>
    Datetime:    2017-11-7 14:46:42
    Description: File description
--]]

local LimitAwakenModel = class("LimitAwakenModel", BaseModel)

function LimitAwakenModel:ctor()
	LimitAwakenModel.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")

	self._data = {}
end

--是否请求过数据
function LimitAwakenModel:setIsReqedById(inState, inId)   --isReqed
	if not self._data[inId] then
		return
	end

	self._data[inId]["isReqed"] = inState
end

function LimitAwakenModel:getIsReqedById(inId)    
	if not self._data[inId] then
		return false
	end

	return self._data[inId]["isReqed"] or false
end

function LimitAwakenModel:setIsTipedById(inState, inId)    --isTiped
	if not self._data[inId] then
		return
	end

	self._data[inId]["isTiped"] = inState
end

function LimitAwakenModel:getIsTipedById(inId)
	if not self._data[inId] then
		return false
	end

	return self._data[inId]["isTiped"] or false
end

function LimitAwakenModel:setDataById(inData, inId)
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
	self._data[inId]["isReqed"] = false
	self._data[inId]["isTiped"] = false
end

function LimitAwakenModel:getDataById(inId)
	return self._data[inId] or {}
end

function LimitAwakenModel:insertNoticeById(inData)
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

			if #acData["notice"] >= 40 then  --碎片替换40
				for i,v in ipairs(acData["notice"]) do
					if v["type"] == 2 and (lastT == nil or lastT > v["time"]) then
						lastT = v["time"]
						replaceId = i
					end
				end

			else 	--添加
				replaceId = #acData["notice"] + 1
			end
			acData["notice"][replaceId] = _info
			self:reflashData(tostring(replaceId))
		until true
	end
end

function LimitAwakenModel:updateData(inData) 
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

function LimitAwakenModel:getRewardListById(inId)
	--获取宝箱奖励数据
    local boxRewards = {}

    for i,v in ipairs(tab.limitItemsBox) do
    	if v["dynamic"] == inId then
    		table.insert(boxRewards, v)
    		boxRewards[#boxRewards]["index"] = i
    	end
    end
    table.sort(boxRewards, function(a,b) return a.index < b.index end)

    return boxRewards
end

function LimitAwakenModel:isTodayHasFreeNumById(inId)
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

function LimitAwakenModel:isAcRedPoint(inId)
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

function LimitAwakenModel:isMainViewRedPoint()
	for i,v in pairs(self._data) do
		if self:isAcRedPoint(tonumber(i)) then
			return true
		end
	end

	return false
end

return LimitAwakenModel