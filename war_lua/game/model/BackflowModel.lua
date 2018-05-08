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
    self:registerTimer(5, 0, 12, function ()
        self:updateEverday()
    end)
end

function BackflowModel:setData(data)
    self:progressBackflowData(data)
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

function BackflowModel:progressBackflowData(data)
    dump(data, "data==========", 10)
    local backData = data
    local returnWalfare = backData.returnWalfare
    local loginWalfare = returnWalfare.loginWalfare or {}

    -- 回归福利
    local countNum = table.nums(loginWalfare)
    local loginData = {}
    local barrackData = {}
    for i=1,countNum do
        local indexId = tostring(i)
        local tData = loginWalfare[indexId]
        if tData then
            local barrack = {}
            if tData.barrack then
                local barrackAward = json.decode(tData.barrack)
                barrack.award = barrackAward
                barrack.barrackReceived = tonumber(tData.barrackReceived)
                barrack.tableType = 1
                barrackData[i] = barrack
            end

            local login = {}
            if tData.login then
                local loginAward = json.decode(tData.login)
                login.loginAward = loginAward
                login.loginReceived = tonumber(tData.loginReceived)
                login.tableType = 2
                loginData[i] = login
            end
        end
    end

    -- 活跃度奖励
    local activeRewards = returnWalfare.activeRewards or {}
    local countNum = table.nums(activeRewards)
    local activeData = {}
    for i=1,countNum do
        local indexId = tostring(i)
        local tData = activeRewards[indexId]
        if tData then
            local active = {}
            if tData.reward then
                local activeAward = json.decode(tData.reward)
                active.award = activeAward
                active.st = tonumber(tData.st)
                active.limit = tonumber(tData.limit)
                active.tableType = 3
                activeData[i] = active
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

    -- 回归许愿
    local returnBless = returnWalfare.returnBless or {}
    local blessData = {}
    if returnBless.donateRate then
        blessData.donateRate = json.decode(returnBless.donateRate)
        blessData.exploreSupply = json.decode(returnBless.exploreSupply)
        blessData.heroAttr = returnBless.heroAttr
        blessData.lastRefreshTime = returnBless.lastRefreshTime
        blessData.blessed = returnBless.blessed
        blessData.surplusTimes = returnBless.surplusTimes
    end


    self._data.loginData = loginData
    self._data.barrackData = barrackData
    self._data.activeData = activeData
    self._data.saleData = saleData
    self._data.returnPrivilege = returnPrivilege
    self._data.rechargeData = rechargeData
    self._data.blessData = blessData

    -- returnWalfare.rechargeWalfare = nil
    backData.returnWalfare = nil
    dump(backData, "backData==========", 10)
    self._baseData = backData
end

    -- 更新登录福利
function BackflowModel:updateLoginWalfareData(data)
    dump(data)
    local returnWalfare = data.returnWalfare
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

    -- 更新活跃福利
function BackflowModel:updateActiveRewardsData(data)
    dump(data, "d===========", 5)
    local returnWalfare = data.returnWalfare
    -- 活跃度奖励
    local activeRewards = returnWalfare.activeRewards
    local activeData = self:getActiveData()
    for k,v in pairs(activeRewards) do
        local indexId = tonumber(k)
        if v.st then
            activeData[indexId].st = tonumber(v.st)
        end
    end
end

    -- 更新回归特卖
function BackflowModel:updateReturnWalfare(data)
    local returnWalfare = data.returnWalfare

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
function BackflowModel:updateReturnBlessData(data)
    -- 回归许愿
    local returnWalfare = data.returnWalfare
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
    local userModel = self._modelMgr:getModel("UserModel")
    local currTime = userModel:getCurServerTime() 
    local endTime = baseData.endTime or 0
    local begTime = baseData.startTime or 0
    if currTime > begTime and currTime < endTime then
        flag = true
    end
    return flag
end

function BackflowModel:getBackflowTip()
    local rechargeTip = self:getBackflowRechargeTip()
    local loginTip = self:getBackflowLoginTip()
    local barrackTip = self:getBackflowBarrackTip()
    local activeTip = self:getBackflowActiveTip()
    local flag = false
    if loginTip == true or barrackTip == true or rechargeTip == true or activeTip == true then
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


-- 联盟科技使用
-- typeId, times, discount
-- typeId 类型
-- times 次数
-- discount 折扣
function BackflowModel:getGuildScience()
    local times = 0
    local discount = 0
    local blessData = self:getBlessData()
    local typeId = 0
    if blessData and blessData.blessed == 1 then
        local taskType = blessData.donateRate.taskType
        if taskType == 1 then
            typeId = 2
        else
            typeId = 3
        end
        if blessData.surplusTimes then
            times = blessData.surplusTimes
        end
        discount = blessData.donateRate.discount
    end
    return typeId, times, discount
end

return BackflowModel