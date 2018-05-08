--[[
    Filename:    SpringRedModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-01-24 15:42:51
    Description: 春节红包
--]]

local SpringRedModel = class("SpringRedModel", BaseModel)

function SpringRedModel:ctor()
	self.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
	self._data = {}       --红包界面数据
    self._pushData = {}   --全局红包列表
    self._notice = {}     --跑马灯列表
    self._pushRob = {}    --（推送期间 + 红包列表数据未刷新）临时存储数据，判断红点
end

function SpringRedModel:setAcData(inData)
	self._acData = inData
end

function SpringRedModel:getAcData()
	return self._acData or {}
end

function SpringRedModel:setData(inData)
    self._isReqed = true
	self._data = inData
    self:sortData()
end

function SpringRedModel:getData()
	return self._data
end

function SpringRedModel:setLastSentTime(inData)
    self._lSendT = inData
end

function SpringRedModel:getLastSentTime()
    return self._lSendT or 0
end

function SpringRedModel:setIsReqed(inData)
    self._lSendT = inData
end

function SpringRedModel:getIsReqed()
    return self._isReqed
end

function SpringRedModel:updateData(inData)
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

function SpringRedModel:sortData()
    if next(self._data) == nil then
        return
    end

    table.sort(self._data, function(a, b)
        if a.type > b.type then
            return true
        else
            if a.type == b.type then
                if a.sTime > b.sTime then
                    return true
                end
            end
        end
    end)
end

function SpringRedModel:deleteRobedRed(inId)
    for i=#self._data, 1, -1 do
        local tempId = self._data[i]["id"]
        if tempId == inId then
            table.remove(self._data, i)
            if self._pushRob[tempId] then
                self._pushRob[tempId] = nil
            end
            break
        end
    end
end

function SpringRedModel:clearPushRobData()
    self._pushRob = {}
end

--------------------------------------------------
-------------------全局红包推送-------------------
function SpringRedModel:insertPushRed(inData)
    if not inData or not next(inData) then
        return
    end

    for k,v in ipairs(inData) do
        table.insert(self._pushData, v)
        self._pushRob[v["id"]] = 1
    end

    self:reflashData()
end

function SpringRedModel:getPushRed()
    return self._pushData or {}
end

function SpringRedModel:clearPushData()
    self._pushData = {}
end

function SpringRedModel:deleteGlobalRobedRed(inId, isRobed)
    for i=#self._pushData, 1, -1 do
        local tempId = self._pushData[i]["id"]
        if tempId == inId then
            table.remove(self._pushData, i)
            if self._pushRob[tempId] then
                self._pushRob[tempId] = nil
            end
            break
        end
    end

    if isRobed then
        local userId = self._userModel:getData()._id
        for i,v in ipairs(self._data) do
            if v["id"] == inId then
                if v["ids"] == nil then
                    v["ids"] = {}
                end
                table.insert(v["ids"], userId)
            end
        end
    end

    self:reflashData()
end

-----------------------------------------------------
--------------------跑马灯---------------------------
function SpringRedModel:getNotice()
    if next(self._notice) == nil then
        return
    end

    local tempData = self._notice[1]
    table.remove(self._notice, 1)

    return tempData
end

function SpringRedModel:insertNotice(inData)
    if not inData or not next(inData) then
        return
    end

    for k,v in ipairs(inData) do
        table.insert(self._notice, v)
    end
end

function SpringRedModel:checkRobRedTime()
    if not self._acData or next(self._acData) == nil then
        return false
    end

    local limitT = tab.setting["G_REDPACKET_OPEN_TIME"].value   
    local endT = self._acData["end_time"]   
    endT = endT - (TimeUtils.getDateString(endT,"%H") + 24 - limitT[2]) * 3600  --转换成前天9点
    
    local curTime = self._userModel:getCurServerTime()
    local curH = tonumber(TimeUtils.getDateString(curTime,"%H"))
    if curH >= limitT[1] and curH < limitT[2] then
        return true, limitT[1]
    elseif curTime >= endT then
        return false
    end

    return false, limitT[1]
end

function SpringRedModel:isShowRedPoint()
    --开启时间
    local isOpen = self:checkRobRedTime()
    if not isOpen then
        return false
    end

    --全局红包
    if next(self._pushData) ~= nil or next(self._pushRob) ~= nil then
        return true
    end

    --红包列表（不实时刷新）
    local userId = self._userModel:getData()._id
    for i,v in ipairs(self._data) do
        local isHas = true  --未领
        for m,n in ipairs(v["ids"]) do   
            if userId == n then
                isHas = false
            end
        end

        local isCanG = self:checkGetDayInfo(2, v["type"])   --次数可领
        if isHas and isCanG then
            return true
        end
    end

    return false
end

--inType1:发1/领2  inType:类型1/2/3
function SpringRedModel:checkGetDayInfo(inType1, inType2)
    if not inType1 or not inType2 then
        return false    
    end

    local temp, dayInfo = "", {}
    if inType1 == 1 then
        temp = "limit_sent"
        dayInfo = {80, 81, 82}
    else
        temp = "limit_receive"
        dayInfo = {83, 84, 85}
    end
    local playerTModel = self._modelMgr:getModel("PlayerTodayModel")
    local curNum = playerTModel:getDayInfo(dayInfo[inType2])
    local maxNum = tab.actRedPacket[inType2][temp]
    if curNum < maxNum then
        return true
    end

    return false
end

return SpringRedModel