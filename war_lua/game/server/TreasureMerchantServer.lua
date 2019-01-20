--
-- Author: huangguofang
-- Date: 2018-08-31 11:06:25
--
local TreasureMerchantServer = class("TreasureMerchantServer",BaseServer)

function TreasureMerchantServer:ctor(data)
    TreasureMerchantServer.super.ctor(self,data)
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._TreasureMerchantModel = self._modelMgr:getModel("TreasureMerchantModel")
end

-- 宝物商人  购买推送接口
function TreasureMerchantServer:onBuyTreasureGift( result, error)
    print("==============宝物商人:购买推送接口===============")
    if error ~= 0 then 
        return
    end
    dump(result,"result",10)
    --
    if result["d"] then
        self._TreasureMerchantModel:setGiftResult(result)
        self._itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
        self._userModel:updateUserData(result["d"])
        self:callback(result)
    end
    -- self:callback(result)
    self._TreasureMerchantModel:setOutOfDate()
end


return TreasureMerchantServer