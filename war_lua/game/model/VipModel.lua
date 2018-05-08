--[[
    Filename:    VipModel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-10-19 15:28:12
    Description: File description
--]]

local VipModel = class("VipModel", BaseModel)
--[[
VipModel.kProductType1 = 1
VipModel.kProductType2 = 2
]]
function VipModel:ctor()
    VipModel.super.ctor(self)
    self._data = {}
    -- 记录礼包tips是否超时(4s)不显示 true没超时显示 false 超时不显示 
    self._giftTipsShow = true
    self:registerVipTimer()
end

function VipModel:isNeedRequest()
    if not self._cached then
        self._cached = true
        return true
    end
    
    return false
end

function VipModel:setData(data)
    -- dump(data, "VipModel")
    if not data or 0 == table.nums(data) then
        data = {
            level = 0, 
            exp = 0,
        }
    end
    self._data = data
    self._cached = true
    self:reflashData()
end

function VipModel:getData()
    return self._data
end

function VipModel:registerVipTimer()
    local registerTab = {}
    registerTab[5 .. ":" .. 0 .. ":" .. 0] = true
    for time, _ in pairs(registerTab) do
        local list = string.split(time, ":")
        self:registerTimer(tonumber(list[1]), tonumber(list[2]), tonumber(list[3]), specialize(self.setOutOfDate, self))
    end
end

function VipModel:setOutOfDate()
    self._cached = false
    self._serverMgr:sendMsg("VipServer", "getVipInfo", {}, true, {}, function(success)
    end)
end

function VipModel:updateData(data)
    if not data then return end
    local function updateSubData(inSubData, inUpData)
        if type(inSubData) == "table" and next(inSubData) ~= nil then
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
        local backData = updateSubData(self._data[k], v)
        self._data[k] = backData
    end    
    local localLvl = SystemUtils.loadAccountLocalData("VIP_GIFT_NOTGET_LVL")
    if not localLvl then
        localLvl = self._data.level
        SystemUtils.saveAccountLocalData("VIP_GIFT_NOTGET_LVL",localLvl)
    end
    if localLvl < self._data.level then
        self:resetGiftClickData()
    end

    if data.level then
        ModelManager:getInstance():getModel("ActivityModel"):pushUserEvent()
    end
    self:reflashData()
end

function VipModel:updateGiftData(data)
    if not data then return end
    if not self._data.privilegeGift then
        self._data.privilegeGift = {}
    end
    table.merge(self._data.privilegeGift, data)
end

function VipModel:isFreeGemGet()
    -- dump(self._data)
    local isBuy = false
    if self._data["recharge"] then
        isBuy = self._data["recharge"]["payment_free"]
    else
        isBuy = false
    end
    return not isBuy
end

function VipModel:isMonthCardBought()
    local flag = false
    if not self._data["monthCard"] then
    else
        flag = true
    end
    return flag
end

function VipModel:getLevel()
    return self._data.level
end

--[[
--! @function getSysVipMaxLimitByField
--! @desc 获取系统vip数据表某字段最大值
--！@param fieldName 字段名
--! @return limitVipLevel, limitVipTimes vip等级，vip字段限制数
--]]
function VipModel:getSysVipMaxLimitByField(fieldName)
    local maxVipLevel = tonumber(tab:Setting("G_MAX_VIP_LEVEL").value)
    local limitVipLevel = 0
    local limitVipTimes = 0
    local sysVip = tab:Vip(0)
    if sysVip[fieldName] == nil then 
        return 0, 0
    end
    for i= maxVipLevel, 0, -1 do
        local sysVip = tab:Vip(i)
        if limitVipTimes == 0 or limitVipTimes <= sysVip[fieldName] then  
            limitVipTimes = sysVip[fieldName]
            limitVipLevel = sysVip.id
        end
    end
    return limitVipLevel, limitVipTimes
end

function VipModel:setGiftTipsShowState(isShow)
    self._giftTipsShow = isShow
end

function VipModel:getGiftTipsShowState()
     return self._giftTipsShow
end

function VipModel:setGiftClickData(clickData)
    -- print("#########===========setGiftClickData=====")
    self._clickData = clickData
end

function VipModel:getGiftClickData()
     return self._clickData
end

function VipModel:saveClickLocalData()
    local jsonStr = ""
    if #self._clickData > 0 then
        jsonStr = json.encode(self._clickData)
    end
    -- print("***********saveClickLocalData()***********",jsonStr)
    SystemUtils.saveAccountLocalData("VIP_GIFT_NOTGET_CLICKDATA",jsonStr)
end

--用于判断当前VIPPanel左右是否有可购买并且没有点击过的礼包
function VipModel:isNeedGiftTip(index)
    local clickData = self._clickData
    local lvl = self._data.level 
    local left = 0          --左边已经获得的礼包数量 + 点击过的礼包数
    local right = 0         --右侧已经获得的礼包数量 + 未达到条件可获得的礼包数 + 点击过的礼包数
    local giftsNum = 15     --礼包总数    
    -- local clickJson = SystemUtils.loadAccountLocalData("VIP_GIFT_NOTGET_CLICKDATA")
    -- local clickData = json.decode(clickJson)
    if #clickData == giftsNum then
        return 0,0
    end    
    if self._data.privilegeGift then
        for k,v in pairs(self._data.privilegeGift) do
            if tonumber(k) <= index then
                left = left + 1
            else
                right = right + 1
            end
        end
    else
        left = 0
        right = 0
    end 

    for k,v in pairs(clickData) do
        -- 过滤掉已经获得的礼包
        if not self._data.privilegeGift or not self._data.privilegeGift[tostring(v.id)] then
            if v.id <= index then                       --左侧点击过的 +1
                left = left + 1
            elseif v.id > index and v.id <= lvl then    --右侧可购买点击过的 +1
                right = right + 1
            end
        end
    end
    -- dump(clickData,"clickData")
    right = right + (giftsNum - lvl)  --加上未获得礼包数
    if index > lvl then
        index = lvl
    end
    return (index - left ),(giftsNum - index - right)
end

--主界面判断vip推送有没有红点（有可购买的礼包）
function VipModel:haveCanGetGift()    
    -- 如果没有数据，则从本地取
    if not self._clickData then
        local jsonStr = SystemUtils.loadAccountLocalData("VIP_GIFT_NOTGET_CLICKDATA")
        if jsonStr and jsonStr ~= "" then            
            self._clickData = json.decode(jsonStr)
        else            
            self._clickData = {}
        end
    end
    local lvl = self._data.level 
    local isCanGet = false
    local count = 0
    -- 四级之前如果没有购买月卡，则显示月卡，且不显示红点
    if lvl <= 3 then
        if not self._data.mCard then
            isCanGet = false
        else
            if not self._data.mCard.payment_month or not self._data.mCard.payment_monthsuper then
                isCanGet = false
            else
                isCanGet = true
            end
        end        
    else
        if self._data.privilegeGift then
            for k,v in pairs(self._data.privilegeGift) do
                if tonumber(k) <= lvl then
                    count = count + 1
                end
            end
        else
            count = 0
        end
    end

    local num = 0       -- 已经获得的礼包数量 + 点击过的礼包数
    if lvl > 4  then
        -- 判断未购买的礼包是否有被点击过
        for k,v in pairs(self._clickData) do
            -- 过滤掉已经获得的礼包
            if not self._data.privilegeGift or not self._data.privilegeGift[v.id] then
                if v.id <= lvl then      --左侧点击过的 +1
                    count = count + 1
                end
            end
        end 
    end
    -- dump(self._clickData,"===>")
    -- print("=======================count====",count,lvl)
    if lvl > 4 and count < lvl then
        isCanGet = true
    end

    return isCanGet
end

function VipModel:resetGiftClickData()
    SystemUtils.saveAccountLocalData("VIP_GIFT_NOTGET_LVL",self._data.level)
    SystemUtils.saveAccountLocalData("VIP_GIFT_NOTGET_CLICKDATA","")
    self._clickData = {}
    self._giftTipsShow = true
end
-- 活动领取奖励 获得vip经验
function VipModel:updateVipExpData(data)
    if data.exp then
        self._data.exp = data.exp
    end

    if data.level then
        self._data.level = data.level
        ModelManager:getInstance():getModel("ActivityModel"):pushUserEvent()
        self._modelMgr:getModel("DirectShopModel"):onLevelUp()
    end

    self:reflashData()
end


--记录充值前充值数  by wangyan
function VipModel:setChargeBeforeSum(num)
    if num then
        self._chargeSum = num
    else
        self._chargeSum = self._data["sum"] or 0
    end
end

function VipModel:getChargeBeforeSum()
    return self._chargeSum or 0
end

--[[
function VipModel:chargeSuccess()
    ViewManager:getInstance():showTip(lang("pay1"))
end

function VipModel:chargeFailed()
    ViewManager:getInstance():showTip(lang("pay2"))
end

function VipModel:chargeCancel()
    ViewManager:getInstance():showTip(lang("pay3"))
end

function VipModel:chargeForbidden()
    ViewManager:getInstance():showTip(lang("pay4"))
end

function VipModel:chargeUnknownError()
    ViewManager:getInstance():showTip(lang("pay5"))
end

function VipModel:charge(productType, productIndex, callback)
    ServerManager:getInstance():sendMsg("VipServer", "beforePay", {}, true, {}, function(success)
        if not success then
            return self:chargeFailed()
        end
        local idToName = {}
        if productType == VipModel.kProductType1 then
            idToName = {
                [1] = "payment_30",
                [2] = "payment_60",
                [3] = "payment_980",
                [4] = "payment_1980",
                [5] = "payment_3280",
                [6] = "payment_6480",
                [7] = "payment_free",
                [8] = "payment_6",
            }
        else
            idToName = {
                [1] = "payment_month",
                [2] = "payment_monthsuper",
            }
        end
        local product_id = idToName[productIndex]
        if not product_id then return self:chargeFailed() end
        local tableData = tab:Payment(product_id)
        if not tableData then return self:chargeFailed() end
        local game_coin = tableData.gem
        local sec = GameStatic.sec
        local price = tableData.cash

        sdkMgr:charge({product_id = product_id, game_coin = game_coin, sec = sec, price = price}, function(code, data)
            if code == sdkMgr.SDK_STATE.SDK_CHARGE_FAIL then
                return self:chargeFailed()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_CANCEL then
                return self:chargeCancel()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_FORBIDDEN then
                return self:chargeForbidden()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_SUCCESS then
                ServerManager:getInstance():sendMsg("VipServer", "afterPay", {ext = data}, true, {}, function(success)
                    if not success then
                        return self:chargeFailed()
                    end
                    self:chargeSuccess()
                    if callback and type(callback) == "function" then
                        callback()
                    end
                end)
            else
                return self:chargeUnknownError()
            end
        end)
    end)
end
]]
return VipModel