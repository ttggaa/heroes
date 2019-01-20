--[[
    Filename:    BackflowModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-07-08 11:43:18
    Description: File description
--]]


local BackflowModel = class("BackflowModel", BaseModel)

function BackflowModel:ctor()
    BackflowModel.super.ctor(self)
    self._data = {}
    -- self._data["abilityList"] = {}
    -- 监听物品数据变化更改提示状态
    -- self:listenReflash("ItemModel", self.checkTips)
    self._baseData = {}
    self._data.returnTask = true
    self:registerTimer(5, 0, 12, function ()
        self:updateEverday()
    end)
end

function BackflowModel:setData(data)
    self:progressBackflowData(data,true)
    self:reflashData()
end

function BackflowModel:getData()
    return self._data
end

function BackflowModel:setBackflowOpen(flag)
    self._flowOpen = flag
end

function BackflowModel:isBackflowOpen()
    return self._flowOpen or false
end

function BackflowModel:updateEverday()
    if not self:isBackflowOpen() then
        return
    end
    print("每日更新=========")
    self._serverMgr:sendMsg("BackFlowServer", "getBackFlowInfo", {}, true, {}, function (result)
    end)
end

function BackflowModel:progressBackflowData(data,isInit)
    dump(data, "data==========", 10)
    local backData = data
    local returnWalfare = backData.returnWalfare
    if not returnWalfare then return end 
    local loginWalfare = returnWalfare.loginWalfare or {}

    -- 回归福利
    local countNum = table.nums(loginWalfare)
    local loginData = {}
    local barrackData = {}
    for i=1,countNum do
        local indexId = tostring(i)
        local tData = loginWalfare[indexId]
        if tData then
            local login = {}
            if tData.login then
                local loginAward = json.decode(tData.login)
                login.loginAward = loginAward
                login.loginReceived = tonumber(tData.loginReceived)
                login.tableType = 2
                loginData[i] = login
            end
            if tData.barrack then
                local barrackAward = json.decode(tData.barrack)
                if not login.loginAward then
                    login.loginAward = {}
                end
                for k,v in pairs(barrackAward) do
                    table.insert(login.loginAward, v)
                end
            end
        end
    end

    -- 回归特卖
    local returnSale = returnWalfare.returnSale or {}
    local countNum = table.nums(returnSale)
    local saleData = {}
    for i=1,countNum do
        local indexId = tostring(i)
        local tData = returnSale[indexId]
        if tData then
            local tPriceInfo = {}
            local priceInfo = json.decode(tData.priceInfo)
            local typeId = tData.typeId
            local ttype = tData.type
            tPriceInfo.priceInfo = priceInfo
            tPriceInfo.typeId = typeId
            tPriceInfo.ttype = ttype
            saleData[i] = tPriceInfo
        end
    end

    -- 回归特权
    local returnPrivilege = returnWalfare.returnPrivilege or {}
    
    -- 充值特惠
    local rechargeWalfare = returnWalfare.rechargeWalfare or {}
    local rechargeData = {}
    if rechargeWalfare.goodDataInfo then
        rechargeData.goodDataInfo = json.decode(rechargeWalfare.goodDataInfo)
        rechargeData.hasReceived = rechargeWalfare.hasReceived
        rechargeData.rechargeLimit = rechargeWalfare.rechargeLimit
        rechargeData.rechargeNum = rechargeWalfare.rechargeNum
    end

    -- 回归许愿 废弃
    -- local returnBless = returnWalfare.returnBless or {}
    -- local blessData = {}
    -- if returnBless.donateRate then
    --     blessData.donateRate = json.decode(returnBless.donateRate)
    --     blessData.exploreSupply = json.decode(returnBless.exploreSupply)
    --     blessData.heroAttr = returnBless.heroAttr
    --     blessData.lastRefreshTime = returnBless.lastRefreshTime
    --     blessData.blessed = returnBless.blessed
    --     blessData.surplusTimes = returnBless.surplusTimes
    -- end
    if not self._taskTb then
        self._taskTb = clone(tab.activetask)
    end
    if not self._integralreward then
        self._integralreward = clone(tab.integralreward)
    end
    local returnTask = returnWalfare.returnTask or {}
    local taskIds = returnTask.taskIds or {}
    local rewardIds = returnTask.rewardIds or {}

    -- dump(taskIds,"taskIds===>",5)
    if isInit and not returnWalfare.returnTask then
        self._data.returnTask = false
    end
    local taskData = {}
    for k,v in pairs(self._taskTb) do
        v.status = 0
        if taskIds[tostring(k)] and taskIds[tostring(k)] == 1 then
            v.status = 1
        end
        table.insert(taskData, v)
    end

    local taskRewardData = {}
    for k,v in pairs(self._integralreward) do
        v.status = 0
        if rewardIds[tostring(k)] and rewardIds[tostring(k)] == 1 then
            v.status = 1
        end
        table.insert(taskRewardData, v)
    end

    self._data.loginData = loginData
    -- self._data.barrackData = barrackData
    -- self._data.activeData = activeData
    self._data.saleData = saleData
    self._data.returnPrivilege = returnPrivilege
    self._data.rechargeData = rechargeData
    self._data.blessData = blessData
    self._data.taskData = taskData
    self._data.taskDataScore = returnTask.score or 0
    self._data.taskRewardData = taskRewardData

    -- returnWalfare.rechargeWalfare = nil
    backData.returnWalfare = nil
    -- dump(backData, "backData==========", 10)
    self._baseData = backData
end

-- 更新登录福利
function BackflowModel:updateLoginWalfareData(data)
    dump(data)
    local returnWalfare = data.returnWalfare
    if not returnWalfare then return end 
    local loginWalfare = returnWalfare.loginWalfare
    -- 回归福利
    local barrack = self:getBarrackData()
    local login = self:getLoginData()
    for k,v in pairs(loginWalfare) do
        local indexId = tonumber(k)
        if v.loginReceived then
            login[indexId].loginReceived = tonumber(v.loginReceived)
        end
        if v.barrackReceived then
            barrack[indexId].barrackReceived = tonumber(v.barrackReceived)
        end
    end
end

-- 更新回归任务
function BackflowModel:updateTaskData(data)
    local returnWalfare = data.returnWalfare
    if not returnWalfare then return end 
    local returnTask = returnWalfare.returnTask
    -- 回归福利
    local taskData = self:getTaskData()
    local taskRewardData = self:getTaskRewardData()
    if returnTask.score then
        self._data.taskDataScore = returnTask.score
    end
    local taskIds = returnTask.taskIds or {}
    local rewardIds = returnTask.rewardIds or {}

    for k,v in pairs(taskData) do
        if taskIds[tostring(v.id)] and taskIds[tostring(v.id)] == 1 then
            v.status = 1
        end
    end

    for k,v in pairs(taskRewardData) do
        if rewardIds[tostring(v.id)] and rewardIds[tostring(v.id)] == 1 then
            v.status = 1
        end
    end
end
-- -- 更新活跃福利
-- function BackflowModel:updateActiveRewardsData(data)
--     dump(data, "d===========", 5)
--     local returnWalfare = data.returnWalfare
--     -- 活跃度奖励
--     local activeRewards = returnWalfare.activeRewards
--     local activeData = self:getActiveData()
--     for k,v in pairs(activeRewards) do
--         local indexId = tonumber(k)
--         if v.st then
--             activeData[indexId].st = tonumber(v.st)
--         end
--     end
-- end

-- 更新回归特卖
function BackflowModel:updateReturnWalfare(data)
    local returnWalfare = data.returnWalfare
    if not returnWalfare then return end 

    local returnSale = returnWalfare.returnSale
    local countNum = table.nums(returnSale)
    local saleData = self._data.saleData
    for k,v in pairs(returnSale) do
        local indexId = tonumber(k)
        local tData = returnSale[k]
        if tData then
            local tPriceInfo = saleData[indexId]
            if v.priceInfo then
                local priceInfo = json.decode(tData.priceInfo)
                tPriceInfo.priceInfo = priceInfo
            end
        end
    end
end

-- 充值特惠
function BackflowModel:updateRechargeWalfareData(data)
    -- 充值特惠
    local returnWalfare = data.returnWalfare
    if not returnWalfare then return end 
    local rechargeWalfare = returnWalfare.rechargeWalfare
    local rechargeData = self._data.rechargeData
    if rechargeWalfare.hasReceived then
        rechargeData.hasReceived = rechargeWalfare.hasReceived
    end
    if rechargeWalfare.rechargeNum then
        rechargeData.rechargeNum = rechargeWalfare.rechargeNum
    end
end

    -- 回归许愿
    --[[
function BackflowModel:updateReturnBlessData(data)
    -- 回归许愿
    local returnWalfare = data.returnWalfare
    if not returnWalfare then return end 
    -- 回归许愿
    local returnBless = returnWalfare.returnBless
    dump(returnBless)
    if returnBless then
        local blessData = self._data.blessData
        if returnBless.donateRate then
            blessData.donateRate = json.decode(returnBless.donateRate)
        end
        if returnBless.exploreSupply then
            blessData.exploreSupply = json.decode(returnBless.exploreSupply)
        end
        if returnBless.heroAttr then
            blessData.heroAttr = returnBless.heroAttr
        end
        if returnBless.lastRefreshTime then
            blessData.lastRefreshTime = returnBless.lastRefreshTime
        end
        if returnBless.blessed then
            blessData.blessed = returnBless.blessed
        end
        if returnBless.surplusTimes then
            blessData.surplusTimes = returnBless.surplusTimes
        end
    end
end
]]

-- 更新回归特权
function BackflowModel:updateReturnPrivileges(data)
    -- 特权
    local returnWalfare = data.returnWalfare
    if not returnWalfare then return end 
    -- 特权
    local returnPrivilege = returnWalfare.returnPrivilege
    -- dump(returnPrivilege)
    if returnPrivilege and self._data and self._data.returnPrivilege then
        local privilegeData = self._data.returnPrivilege or {}
        if returnPrivilege.donateRate then
            privilegeData.donateRate = returnPrivilege.donateRate
        end
        if returnPrivilege.exploreSupply then
            privilegeData.exploreSupply = returnPrivilege.exploreSupply
        end
        if returnPrivilege.heroAttr then
            privilegeData.heroAttr = returnPrivilege.heroAttr
        end
        if returnPrivilege.surplusTimes then
            privilegeData.surplusTimes = returnPrivilege.surplusTimes
        end
    end
end

function BackflowModel:updateBaseData(data)
    for k,v in pairs(data) do
        self._baseData[k] = v
    end
end

function BackflowModel:getBaseData()
    return self._baseData or {}
end

function BackflowModel:getLoginData()
    return self._data.loginData or {}
end

function BackflowModel:getBarrackData()
    return self._data.barrackData or {}
end

function BackflowModel:getActiveData()
    return self._data.activeData or {}
end

function BackflowModel:getSaleData()
    return self._data.saleData or {}
end

function BackflowModel:getReturnPrivilege()
    return self._data.returnPrivilege or {}
end

function BackflowModel:getRechargeData()
    return self._data.rechargeData or {}
end

function BackflowModel:getBlessData()
    return self._data.blessData or {}
end

-- 回归任务
function BackflowModel:getTaskData()
    return self._data.taskData or {}
end
-- 回归任务积分宝箱
function BackflowModel:getTaskRewardData()
    return self._data.taskRewardData or {}
end
-- 回归任务总积分
function BackflowModel:getTaskDataScore()
    return self._data.taskDataScore or 0
end



function BackflowModel:isActivesOpen()
    local flag = false
    if table.nums(self:getActiveData()) > 0 then
        flag = true
    end
    return flag
end

function BackflowModel:isBackNestsOpen()
    local flag = false
    if table.nums(self:getBarrackData()) > 0 then
        flag = true
    end
    return flag
end

function BackflowModel:isPrivilegeOpen()
    local flag = false
    if self._data.returnPrivilege then
        flag = true
    end
    if flag == true then
        self._userModel = self._modelMgr:getModel("UserModel")
        local curServerTime = self._userModel:getCurServerTime()
        local privilegeData = self:getReturnPrivilege()
        local baseData = self:getBaseData()
        local endTime = privilegeData.endTime or baseData.endTime or 0
        local realTime = endTime - curServerTime
        if realTime < 0 then
            flag = false 
        end
    end
    return flag
end

    -- self._data.loginData = loginData
function BackflowModel:isSaleOpen()
    local flag = false
    if table.nums(self:getSaleData()) > 0 then
        flag = true
    end
    return flag
end

function BackflowModel:isRechargeOpen()
    local flag = false
    if table.nums(self:getRechargeData()) > 0 then
        flag = true
    end
    return flag
end

function BackflowModel:isTaskOpen()
    local flag = false
    if self._data.returnTask and table.nums(self:getTaskData()) > 0 then
        flag = true
    end
    return flag
end

function BackflowModel:isBlessOpen()
    local flag = false
    if table.nums(self:getBlessData()) > 0 then
        flag = true
    end
    return flag
end


function BackflowModel:getBackflowOpen()
    local flag = false
    local baseData = self:getBaseData()
    -- dump(baseData,"baseData",6)
    local userModel = self._modelMgr:getModel("UserModel")
    local currTime = userModel:getCurServerTime() 
    local endTime = baseData.endTime or 0
    local begTime = baseData.startTime or 0
    if currTime > begTime and currTime < endTime and self._data.loginData then
        flag = true
    end
    return flag
end

function BackflowModel:getBackflowTip()
    local rechargeTip = self:getBackflowRechargeTip()
    local loginTip = self:getBackflowLoginTip()
    -- local barrackTip = self:getBackflowBarrackTip()
    -- local activeTip = self:getBackflowActiveTip()
    local taskTip = self:getBackflowTaskTip()
    local flag = false
    -- print("========rechargeTip=loginTip=taskTip==========",rechargeTip,loginTip,taskTip)
    if loginTip == true or taskTip == true or rechargeTip == true then
        flag = true
    end
    return flag
end

function BackflowModel:getBackflowRechargeTip()
    local rechargeData = self:getRechargeData()
    local baseData = self:getBaseData()
    local loginDay = baseData.loginDay
    local flag = false
    local hasReceived = rechargeData.hasReceived or 1
    local rechargeLimit = rechargeData.rechargeLimit or 1000000
    local rechargeNum = rechargeData.rechargeNum or 0
    if hasReceived == 0 then
        if rechargeNum >= rechargeLimit then
            flag = true
        end
    end
    return flag
end



function BackflowModel:getBackflowLoginTip()
    local loginData = self:getLoginData()
    local baseData = self:getBaseData()
    local loginDay = baseData.loginDay
    local flag = false
    local indexId = 1
    for i=1,10 do
        local tData = loginData[i]
        if tData then
            local loginReceived = tData.loginReceived
            if loginDay >= i and loginReceived == 0 then
                flag = true
                indexId = i
                break
            end
        end
    end
    return flag, indexId
end

function BackflowModel:getBackflowBarrackTip()
    local barrackData = self:getBarrackData()
    local baseData = self:getBaseData()
    local loginDay = baseData.loginDay
    local flag = false
    local indexId = 1
    for i=1,10 do
        local tData = barrackData[i]
        if tData then
            local barrackReceived = tData.barrackReceived
            if loginDay >= i and barrackReceived == 0 then
                flag = true
                indexId = i
                break
            end
        end
    end
    return flag, indexId
end

function BackflowModel:getBackflowActiveTip()
    local activeData = self:getActiveData()
    local baseData = self:getBaseData()
    local activeNum = baseData.activeNum
    local flag = false
    local indexId = 1
    for i=1,10 do
        local tData = activeData[i]
        if tData then
            local st = tData.st
            local limit = tData.limit
            if activeNum >= limit and st == 0 then
                flag = true
                indexId = i
                break
            end
        end
    end
    return flag, indexId
end

function BackflowModel:getBackflowBlessTip()
    local blessData = self:getBlessData()
    local blessed = blessData.blessed or 1
    local flag = false
    local isOpen, toBeOpen = SystemUtils["enableGuild"]()
    if blessed == 0 and isOpen == true then
        flag = true
    end
    return flag
end

function BackflowModel:getBackflowTaskTip()
    local taskData,isHaveTip = self:processTaskData()
    local taskRewardData = self:getTaskRewardData()
    local flag = isHaveTip
    local score = self:getTaskDataScore()
    
    for k,v in pairs(taskRewardData) do
        -- score >= accumulatepoints
        if score >= v.accumulatepoints and v.status and v.status == 0 then
            flag = true
            break
        end
    end

    return flag
end

function BackflowModel:processTaskData() 
    if not self._userModel then
        self._userModel = self._modelMgr:getModel("UserModel")
    end  
    local startTime = self._baseData.startTime or 0
    local endTime = self._baseData.endTime or 0   
    
    local taskData = self:getTaskData()
    -- dump(taskData,"taskData==>",5)
    local userLv = self._userModel:getPlayerLevel() or 0
    local acStatis = self._userModel:getActivityStatis() or {}
    local conditionTb = self._conditionTb
    if not conditionTb then 
        self._conditionTb = clone(tab.dailyActivityCondition)
        conditionTb = self._conditionTb
    end
    local isHaveTip = false
    local getConditionNum = function(data)
        local num = 0
        for k,v in pairs(acStatis) do
            -- print("===================data.stsId=======",data.stsId)
            local timeStr = string.sub(tostring(k), 1, 4) .. "-" .. string.sub(tostring(k), 5, 6) .. "-" .. string.sub(tostring(k), -2)  .. " 05:00:00"
            local condition = tonumber(data.condition)
            local stsId = conditionTb[condition] and conditionTb[condition].stsId or 0
            local time = TimeUtils.getIntervalByTimeString(timeStr)
            if time >= startTime and time < endTime then
                if v["sts" .. stsId] then
                    num = num + tonumber(v["sts" .. stsId])
                end
            end
        end
        return num
    end

    local tempTaskData = {}
    for k,v in ipairs(taskData) do
        -- print("========level_limit====",v.level_limit)
        if v.level_limit <= userLv then
            v.haveNum = getConditionNum(v)
            if v.status == 0 then
                v.sortNum = 1
                if v.haveNum >= v.condition_num[1] then
                    isHaveTip = true
                    v.sortNum = 2
                end
            else
                v.sortNum = 0
            end
            table.insert(tempTaskData, v)
        end
    end

    table.sort(tempTaskData,function( a,b )
        if a.sortNum == b.sortNum then
            return a.id < b.id
        else
           return  a.sortNum > b.sortNum
        end
    end)
    -- dump(tempTaskData,"tempTaskData==>",5)

    return tempTaskData,isHaveTip
end

-- 联盟科技使用
-- typeId, times, discount
-- typeId 类型
-- times 次数
-- discount 折扣
function BackflowModel:getGuildScience()
    local times = 0
    local discount = 0    
    local typeId = 0
    if self:isPrivilegeOpen() then
        local privilegesD = self:getReturnPrivilege()
        local donateRate = {}
        if privilegesD.donateRate ~= nil then
            donateRate = json.decode(privilegesD.donateRate)
        end
        local taskType = donateRate.taskType or 1
        if taskType == 1 then
            typeId = 2
        else
            typeId = 3
        end
        -- dump(privilegesD,"privilegesD==>",5)
        -- print("=============privilegesD.surplusTimes====",privilegesD.surplusTimes)
        if privilegesD.surplusTimes then
            times = privilegesD.surplusTimes or 0
        end
        discount = donateRate.discount or 0
    end
    return typeId, times, discount
end

return BackflowModel