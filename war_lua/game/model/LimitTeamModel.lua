--[[
    Filename:    LimitTeamModel.lua
    Author:      <wangyan02@playcrab.com>
    Datetime:    2016-04-10 14:30:42
    Description: File description
--]]

local LimitTeamModel = class("LimitTeamModel", BaseModel)

function LimitTeamModel:ctor()
	LimitTeamModel.super.ctor(self)

	self._isReqed = false
	self._noticeNum = {[1] = 0, [2] = 0, [3] = 0}   --1整卡 2碎片 3招募
	self:onInit()
end

function LimitTeamModel:onInit()
	self._data = {}
	self._data["notice"] = {}
	self._data["boxPt"] = 0
	self._data["rewardList"] = {}
	self._data["notice"] = {}
end

--是否请求过数据
function LimitTeamModel:setIsReqed(inState)
	self._isReqed = inState
end

function LimitTeamModel:getIsReqed()
	return self._isReqed
end

function LimitTeamModel:setCurAdId(inData)
	self._acID = inData
end

function LimitTeamModel:getCurAdId()
	return self._acID
end

function LimitTeamModel:setData(inData)
	self._data = inData
	self._data["notice"] = inData["notice"] or {}
	self._data["boxPt"] = inData["boxPt"] or 0
	self._data["rewardList"] = inData["rewardList"] or {}

	if inData["notice"] then
		table.sort(inData, function(a, b) return a.time < b.time end)
	else
		inData["notice"] = {}
	end
	self._data["notice"] = inData["notice"]
	
	--记录上限值
	for i,v in ipairs(self._data["notice"]) do
		if v["type"] == 1 and self._noticeNum[1] then   --整卡
			self._noticeNum[1] = self._noticeNum[1] + 1   --10

		elseif v["type"] == 2 and self._noticeNum[2] then
			self._noticeNum[2] = self._noticeNum[2] + 1     --40

		elseif v["type"] == 3 and self._noticeNum[3] then
			self._noticeNum[3] = self._noticeNum[3] + 1     --3
		end
	end
end

function LimitTeamModel:getData()
	return self._data or {}
end

function LimitTeamModel:insertNotice(inData)
	if not (inData and type(inData) == "table") then
		return
	end  

	for i,_info in ipairs(inData) do
		local replaceId = 1   --被替换的cellId
		local lastT
		if _info["type"] == 1 and self._noticeNum[1] >= 10 then   --整卡替换10
			for i,v in ipairs(self._data["notice"]) do
				if v["type"] == 1 and (lastT == nil or lastT > v["time"]) then
					lastT = v["time"]
					replaceId = i
				end
			end

		elseif _info["type"] == 2 and self._noticeNum[2] >= 40 then  --碎片替换40
			for i,v in ipairs(self._data["notice"]) do
				if v["type"] == 2 and (lastT == nil or lastT > v["time"]) then
					lastT = v["time"]
					replaceId = i
				end
			end

		elseif _info["type"] == 3 and self._noticeNum[2] >= 3 then  --碎片替换3
			for i,v in ipairs(self._data["notice"]) do
				if v["type"] == 3 and (lastT == nil or lastT > v["time"]) then
					lastT = v["time"]
					replaceId = i
				end
			end

		else 	--添加
			replaceId = #self._data["notice"] + 1
			if self._noticeNum[_info["type"]] then
				self._noticeNum[_info["type"]] = self._noticeNum[_info["type"]] + 1
			end
		end
		self._data["notice"][replaceId] = _info
		self:reflashData(tostring(replaceId))
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
        local backData = updateSubData(self._data[k], v)
        self._data[k] = backData
    end
end

function LimitTeamModel:getRewardListByIntIndex()
	--获取宝箱奖励数据
    local boxRewards = {}

    if self._acID == nil then
    	return {}
    end

    for i,v in ipairs(tab.limitTeamBox) do
    	if v["dynamic"] == self._acID then
    		table.insert(boxRewards, v)
    		boxRewards[#boxRewards]["index"] = i
    	end
    end
    table.sort(boxRewards, function(a,b) return a.index < b.index end)

    return boxRewards
end

function LimitTeamModel:isShowTLRedPoint()
	--免费次数
	local isFree = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(51) or 0
	if isFree == 0 then
		return true
	end

	--有宝箱未领取
	local sysLimitTeamBox = self:getRewardListByIntIndex()
	for i=1, 7 do
		local curScore = self._data["boxPt"] or 0
        local needScore = sysLimitTeamBox[i].score
        local rwdList = self._data["rewardList"] or {}
        local sysIndex = sysLimitTeamBox[i]["index"]
        local isGet = rwdList[tostring(sysIndex)]

        if curScore >= needScore and isGet ~= 1 then
        	return true
        end
	end

	return false
end

return LimitTeamModel