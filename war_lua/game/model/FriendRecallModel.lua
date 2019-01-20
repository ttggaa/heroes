--[[
    Filename:    FriendRecallModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-09-11 16:45:51
    Description: 好友召回
--]]

local FriendRecallModel = class("FriendRecallModel", BaseModel)

function FriendRecallModel:ctor()
    FriendRecallModel.super.ctor(self)
    self:listenGlobalResponse(specialize(self.onChangeRecallTask, self))
    self._userModel = self._modelMgr:getModel("UserModel")
    self._acData = {}       --活动
    self._acData["friendAct"] = {}    --活动任务信息
    self._acData["bindInfo"] = {}
    self._acData["dailyFriendScore"] = 0
    self._shopData = {}     --商店
    self._recallData = {}   --召回
    self._bindData = {}     --绑定

    --5点重置
    self:registerTimer(5, 0, GRandom(0, 5), function ()
        self:reflashData("fShop")
        self:getAcFriendData()  --活动数据
    end)
end

function FriendRecallModel:getAcFriendData()
    if self._acData["friendAct"] then
        local startT = self._acData["friendAct"]["startTime"] or 0
        local endT = self._acData["friendAct"]["endTime"] or 0
        local curTime = self._userModel:getCurServerTime()
        if curTime >= startT and curTime < endT and endT > startT then
            self._serverMgr:sendMsg("RecallServer", "getFriendActData", {}, true, {}, function(result, errorCode)
                self:reflashData("friendAct")
            end)
        end
    end
end

----------------------友情活动---------
function FriendRecallModel:setAcData(inData)
    self._acData = inData
    self:setFriendActData(inData["friendAct"])
end

--friendAct
function FriendRecallModel:setFriendActData(inData)
    local tempTask = {{}, {}, {}}
    local tasks = inData["tasks"] or {}
    local sysFriendQuest = tab.friendQuest
    if not sysFriendQuest then
        return
    end
    for k,v in pairs(sysFriendQuest) do
        local curTask = tasks[tostring(k)]
        if curTask == nil then
            local info = {value = 0}
            curTask = info
        else
            if curTask["value"] == nil then
                curTask["value"] = 0
            end
        end

        curTask["taskId"] = tonumber(k)
        table.insert(tempTask[v["type"]], curTask)
    end

    inData["tasks"] = tempTask
    self._acData["friendAct"] = inData
    self:sortAcData()
end

--dailyFriendScore
function FriendRecallModel:setDialyFScore(inData)
    self._acData["dailyFriendScore"] = inData
end

--bindInfo
function FriendRecallModel:setBindInfo(inData)
    self._acData["bindInfo"] = inData
    self:reflashData("friendAct_bind")
end

function FriendRecallModel:getAcData()
	return self._acData or {}
end

function FriendRecallModel:getAcTaskByType(inType)
    if not self._acData["friendAct"] or not self._acData["friendAct"]["tasks"] then 
        return {}
    end

    return self._acData["friendAct"]["tasks"][tonumber(inType)]
end

function FriendRecallModel:getAcReward(inId)
    if not self._acData["friendAct"] or not self._acData["friendAct"]["tasks"] then
        return
    end

    local tasks = self._acData["friendAct"]["tasks"]
    for i,v in ipairs(tasks) do
        for k,q in ipairs(v) do
            if tonumber(q["taskId"]) == tonumber(inId) then
                q["status"] = 1   --1已领 0未领 nil/-1未达到
                break
            end
        end
    end

    self:sortAcData()
    self:reflashData("friendAct")
end

--carry更新
function FriendRecallModel:onChangeRecallTask(data)
    if not (data and data._carry_) then return end
    if data._carry_.friendAct then
        self:updateFriendActData(data._carry_.friendAct)
        -- dump(data._carry_, "carry更新", 10)
    end
end

function FriendRecallModel:updateFriendActData(inData)
    if type(inData) ~= "table" then
        return
    end

    if not self._acData["friendAct"] or not self._acData["friendAct"]["tasks"] then
        return
    end

    local tasks = self._acData["friendAct"]["tasks"]
    for i,v in ipairs(tasks) do
        for k,q in ipairs(v) do
            local id = q["taskId"]
            if inData[tostring(id)] then
                q["value"] = inData[tostring(id)]
            end
        end
    end

    self:sortAcData()
    self:reflashData("friendAct")
end

function FriendRecallModel:sortAcData()
    --领取》前往》已领取
    if not self._acData["friendAct"] or not self._acData["friendAct"]["tasks"] then
        return 
    end

    local tempData = {}
    local tasks = self._acData["friendAct"]["tasks"]
    local sysFriendQuest = tab.friendQuest
    if not sysFriendQuest then
        return
    end

    for i,v in ipairs(tasks) do
        local table1 = {}   --可领取
        local table2 = {}   --前往
        local table3 = {}   --已领取
        for p,q in ipairs(v) do
            local taskData = sysFriendQuest[q["taskId"]]
            if q["status"] and q["status"] > 0 then
                table.insert(table3, q)
                
            elseif q["value"] >= taskData["condition"][1] then
                table.insert(table1, q)

            else
                table.insert(table2, q)
            end
        end

        local function sortFunc(a, b)
            local taskId1 = a["taskId"]
            local taskData1 = sysFriendQuest[taskId1]

            local taskId2 = b["taskId"]
            local taskData2 = sysFriendQuest[taskId2]
            
            return taskData1["rank"] < taskData2["rank"]
        end 

        table.sort(table1, sortFunc)
        table.sort(table2, sortFunc)
        table.sort(table3, sortFunc)
        
        for m,n in ipairs(table2) do
             table.insert(table1, n)
        end 

        for m,n in ipairs(table3) do
             table.insert(table1, n)
        end

        table.insert(tempData, i, table1)
    end

    self._acData["friendAct"]["tasks"] = tempData    
end

function FriendRecallModel:checkIsAcOpen()
    if not self._acData["friendAct"] then
        return false
    end

    local startT = self._acData["friendAct"]["startTime"] or 0
    local endT = self._acData["friendAct"]["endTime"] or 0
    local curTime = self._userModel:getCurServerTime()
    if curTime >= startT and curTime < endT and endT > startT then
        return true
    end

    return false
end

--主界面活动icon红点
function FriendRecallModel:checkAcRedPoint()
    if not self._acData or type(self._acData) ~= "table" then
        return
    end
    
    local bindInfo = self._acData["bindInfo"]
    if (not bindInfo or next(bindInfo) == nil) and next(self._bindData) ~= nil then
        return true
    end

    for i=1, 3 do
        if self:getAcRedPoint(i) then
            return true
        end
    end

    return false
end

--页签红点
function FriendRecallModel:getAcRedPoint(inType)
    if not self._acData["friendAct"] or not self._acData["friendAct"]["tasks"] then
        return false
    end

    local sysFriendQuest = tab.friendQuest
    if not sysFriendQuest then
        return
    end
    local tasks = self._acData["friendAct"]["tasks"][inType]
    for i,v in ipairs(tasks) do
        if not v["taskId"] or not v["value"] then
            return false
        end

        local needNum = sysFriendQuest[v["taskId"]]["condition"][1]
        if v["value"] >= needNum and (not v["status"] or v["status"] <= 0) then
            return true
        end
    end

    return false
end

function FriendRecallModel:setIsReqedAcData(inData)
    self._isReqAcData = inData
end

function FriendRecallModel:getIsReqedAcData()
    return self._isReqAcData or false
end

-----------------------------友情商店-------------
function FriendRecallModel:setEnterShopTime()
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
    SystemUtils.saveAccountLocalData("LAST_TIME_ENTER_FSHOP_VIEW", curTime)
    self:reflashData("fShop")
end

function FriendRecallModel:setShopData(inData)
    self._shopData = inData
    self:reflashData()
end

function FriendRecallModel:getShopData()
    return self._shopData or {}
end

function FriendRecallModel:getShopGoodData()
    if not self._shopData then
        return
    end

    return self._shopData["goods"] or {}
end


function FriendRecallModel:clearFriendCoin()
    if not self._shopData then
        return
    end

    self._shopData["friendScore"] = 0
end

function FriendRecallModel:clearShopData()
    self._shopData = {}
end

function FriendRecallModel:updateShopData(data)
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

    for k,v in pairs(data) do
        local backData = updateSubData(self._shopData[k], v)
        self._shopData[k] = backData
    end

    self:reflashData()
end

-------------------------召回好友数据--------------
function FriendRecallModel:setRecallData(inData)
    self._recallData = inData
    table.sort(self._recallData, function(a, b)
        return a.status < b.status
        end)
end

function FriendRecallModel:getRecallData()
    return self._recallData or {}
end

function FriendRecallModel:checkIsHasRecall()
    for i,v in ipairs(self._recallData) do
        if v["status"] == 1 then
            return true
        end
    end

    return false
end

function FriendRecallModel:setBindData(inData)
    self._bindData = inData
end

function FriendRecallModel:getBindData()
    return self._bindData or {}
end

function FriendRecallModel:recallFriend(inId)
    for i,v in ipairs(self._recallData) do
        if v["pId"] == inId then
            v["status"] = 2
            break
        end
    end
end

function FriendRecallModel:getRecalledNum() 
    local num = 0
    for i,v in ipairs(self._recallData) do
        if v["status"] == 3 then
            num = num + 1
        end
    end

    return num
end

function FriendRecallModel:recallFriend(inId)
    for i,v in ipairs(self._recallData) do
        if v["pId"] == inId then
            v["status"] = 2
            break
        end
    end
end

function FriendRecallModel:bindFriend(inId)
    for i,v in ipairs(self._bindData) do
        if v["pId"] == inId then
            v["status"] = 1  --已绑定
            break
        end
    end
end

return FriendRecallModel