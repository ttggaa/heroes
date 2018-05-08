--[[
    Filename:    PaymentServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-10-31 20:19:42
    Description: File description
--]]

local PaymentServer = class("PaymentServer", BaseServer)

function PaymentServer:ctor()
    PaymentServer.super.ctor(self)
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._activityModel = self._modelMgr:getModel("ActivityModel")
end

function PaymentServer:handlePayment(result, error)
    if 0 == tonumber(error) and result and result["d"] then
        if result["d"]["activity"] then
            self._modelMgr:getModel("ActivityModel"):updateSpecialData(result["d"]["activity"])
            result["d"]["activity"] = nil 
        end
        if result["d"]["backFlow"] then
            self._modelMgr:getModel("BackflowModel"):updateRechargeWalfareData(result["d"]["backFlow"])
            result["d"]["backFlow"] = nil 
        end
        local old_vip = self._vipModel:getLevel()
        local vip = result["d"].vip
        if vip and vip.level and old_vip then
            if vip.level > old_vip then
                ApiUtils.playcrab_monitor_vip_upgrade(old_vip, vip.level)
            end
        end
        self._vipModel:updateData(result["d"].vip)
        self._activityModel:updateSingleRechargeData(result, 0 == tonumber(error))
        self._activityModel:updateAcRmbData(result, 0 == tonumber(error))
        self._activityModel:updateIntRechargeData(result, 0 == tonumber(error))
        self._userModel:updateUserData(result["d"])
    end

    self:callback(0 == tonumber(error), result)
end

function PaymentServer:onBeforePay(result, error)
    self:handlePayment(result, error)
end

function PaymentServer:onAfterPay(result, error)
   self:handlePayment(result, error) 
end

function PaymentServer:onBuyGoods(result, error)
    dump(result)
    if error ~= 0 then
        return
    end
    self:callback(0 == tonumber(error), result)
end

return PaymentServer