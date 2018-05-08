--[[
    Filename:    BackFlowServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-07-08 14:32:24
    Description: File description
--]]

local BackFlowServer = class("BackFlowServer", BaseServer)

function BackFlowServer:ctor(data)
    BackFlowServer.super.ctor(self, data)
    self._backflowModel = self._modelMgr:getModel("BackflowModel")
end

--  获取回流活动信息
function BackFlowServer:onGetBackFlowInfo(result, error)
    if error ~= 0 then 
        return
    end
    if result and result["backFlow"] then
        self._backflowModel:setData(result["backFlow"])
        self._backflowModel:setBackflowOpen(true)
    end
    self:callback(result)
end

-- 回归祝福许愿
function BackFlowServer:onBlessWishing(result, error)
    if error ~= 0 then 
        return
    end
    if result and result["d"] and result["d"].backFlow then
        self._backflowModel:updateReturnBlessData(result["d"].backFlow)
        result["d"].backFlow = nil
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 领取每日登录奖励
function BackFlowServer:onReceiveLoginWelFare(result, error)
    if error ~= 0 then 
        return
    end
    if result and result["d"] and result["d"].backFlow then
        self._backflowModel:updateLoginWalfareData(result["d"].backFlow)
        result["d"].backFlow = nil
    end
    
    self:handAboutServerData(result)
    self:callback(result)
end

-- 领取活跃奖励
function BackFlowServer:onGetActiveReward(result, error)
    if error ~= 0 then 
        return
    end
    if result and result["d"] and result["d"].backFlow then
        self._backflowModel:updateActiveRewardsData(result["d"].backFlow)
        result["d"].backFlow = nil
    end
    
    self:handAboutServerData(result)
    self:callback(result)
end

-- 购买特卖商品
function BackFlowServer:onBuyReturnSaleGoods(result, error)
    if error ~= 0 then 
        return
    end
    if result and result["d"] and result["d"].backFlow then
        self._backflowModel:updateReturnWalfare(result["d"].backFlow)
        result["d"].backFlow = nil
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 领取充值特惠奖励
function BackFlowServer:onReceiveRechargeWelfare(result, error)
    if error ~= 0 then 
        return
    end
    if result and result["d"] and result["d"].backFlow then
        self._backflowModel:updateRechargeWalfareData(result["d"].backFlow)
        result["d"].backFlow = nil
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function BackFlowServer:handAboutServerData(result)
    if result == nil then 
        return 
    end
   -- -- 物品数据处理要优先于怪兽
    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end

    if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end

    if result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result["d"].dayInfo or {})
    end

    if result["d"]["task"] ~= nil  then
        self._modelMgr:getModel("TaskModel"):updateDetailTaskData(result["d"], 0 == tonumber(error))
        result["d"]["task"] = nil
    end
    
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return BackFlowServer
