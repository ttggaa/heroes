--[[
    Filename:    VipServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-10-19 15:28:47
    Description: File description
--]]

local VipServer = class("VipServer", BaseServer)

function VipServer:ctor()
    VipServer.super.ctor(self)
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

function VipServer:onGetVipInfo(result, error)
    -- dump(result, "VipServer:onGetVipInfo", 10)
    self._vipModel:setData(result)
    self:callback(0 == tonumber(error))
end
--[[
function VipServer:handlePayment(result, error)
    if 0 == tonumber(error) and result and result["d"] then
        if result["d"]["activity"] then
            self._modelMgr:getModel("ActivityModel"):updateSpecialData(result["d"]["activity"])
            result["d"]["activity"] = nil 
        end
        
        self._vipModel:updateData(result["d"].vip)
        self._userModel:updateUserData(result["d"])
    end

    self:callback(0 == tonumber(error))
end

function VipServer:onBeforePay(result, error)
    self:handlePayment(result, error)
end

function VipServer:onAfterPay(result, error)
   self:handlePayment(result, error) 
end
]]
function VipServer:onGetMCardGift(result, error)
    -- dump(result, "VipServer:onGetMCardGift", 10)
    if error ~= 0 then
        return
    end

    self._vipModel:updateData(result["d"].vip)
    self._userModel:updateUserData(result["d"])

    self:callback(result)
end

function VipServer:onBuyPrivilageGift(result, error)
    -- dump(result, "VipServer:onBuyPrivilageGift", 10)
    if 0 == tonumber(error) then
        self._vipModel:updateGiftData(result["d"].vip.privilegeGift)
        result["d"].vip = nil

        if result["d"].items then
            self._itemModel:updateItems(result["d"].items)
            result["d"].items = nil
        end

        self._userModel:updateUserData(result["d"])
    end
    self:callback(0 == tonumber(error), result)
end

function VipServer:onGetFreeGem(result, error)
    if 0 == tonumber(error) then
        if result and result["d"] then
            self._vipModel:updateData(result["d"].vip)
            self._userModel:updateUserData(result["d"])
        end
    end
    self:callback(0 == tonumber(error), result)
end

-- 隐藏vip by guojun
function VipServer:onHiddenVip(result, error)
    if 0 == tonumber(error) then
        if result and result["d"] then
            -- self._vipModel:updateData(result["d"].vip)
            self._userModel:updateUserData(result["d"])
        end
    end
    self:callback(0 == tonumber(error), result)
end

return VipServer