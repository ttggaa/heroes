--[[
    Filename:    LimitAwakenModel.lua
    Author:      <wangyan02@playcrab.com>
    Datetime:    2017-11-7 14:46:42
    Description: File description
--]]

local LimitAwakenModel = class("LimitAwakenModel", BaseModel)

function LimitAwakenModel:ctor()
	LimitAwakenModel.super.ctor(self)

	self._isReqed = false
	self:onInit()
end

function LimitAwakenModel:onInit()
	self._data = {}
	self._data["notice"] = {}
	self._data["boxPt"] = 0
	self._data["rewardList"] = {}
	self._data["notice"] = {}
end

--是否请求过数据
function LimitAwakenModel:setIsReqed(inState)
	self._isReqed = inState
end

function LimitAwakenModel:getIsReqed()
	return self._isReqed
end

function LimitAwakenModel:setCurAdId(inData)
	self._acID = inData
end

function LimitAwakenModel:getCurAdId()
	return self._acID
end

function LimitAwakenModel:setIsTiped(inState)
	self._isTiped = inState
end

function LimitAwakenModel:getIsTiped()
	return self._isTiped or false
end

function LimitAwakenModel:setData(inData)
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
end

function LimitAwakenModel:getData()
	return self._data or {}
end

function LimitAwakenModel:insertNotice(inData)
	if not (inData and type(inData) == "table") then
		return
	end  

	for i,_info in ipairs(inData) do
		local replaceId = 1   --被替换的cellId
		local lastT
		if #self._data["notice"] >= 40 then  --碎片替换40
			for i,v in ipairs(self._data["notice"]) do
				if v["type"] == 2 and (lastT == nil or lastT > v["time"]) then
					lastT = v["time"]
					replaceId = i
				end
			end

		else 	--添加
			replaceId = #self._data["notice"] + 1
		end
		self._data["notice"][replaceId] = _info
		self:reflashData(tostring(replaceId))
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
        local backData = updateSubData(self._data[k], v)
        self._data[k] = backData
    end
end

function LimitAwakenModel:getRewardListByIntIndex()
	--获取宝箱奖励数据
    local boxRewards = {}

    if self._acID == nil then
    	return {}
    end

    for i,v in ipairs(tab.limitItemsBox) do
    	if v["dynamic"] == self._acID then
    		table.insert(boxRewards, v)
    		boxRewards[#boxRewards]["index"] = i
    	end
    end
    table.sort(boxRewards, function(a,b) return a.index < b.index end)
    -- dump(boxRewards, "boxRewards")

    return boxRewards
end

function LimitAwakenModel:isShowTLRedPoint()
	--免费次数
	local isFree = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(75) or 0
	if isFree == 0 then
		return true
	end

	--有宝箱未领取
	local sysLimitItemBox = self:getRewardListByIntIndex()
	for i=1, 7 do
		local curScore = self._data["boxPt"] or 0
        local needScore = sysLimitItemBox[i].score
        local rwdList = self._data["rewardList"] or {}
        local sysIndex = sysLimitItemBox[i]["index"]
        local isGet = rwdList[tostring(sysIndex)]

        if curScore >= needScore and isGet ~= 1 then
        	return true
        end
	end

	return false
end

return LimitAwakenModel