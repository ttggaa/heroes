--
-- Author: huangguofang
-- Date: 2018-08-31 11:09:09
--
local TreasureMerchantModel = class("TreasureMerchantModel", BaseModel)

function TreasureMerchantModel:ctor()
    TreasureMerchantModel.super.ctor(self)
    self._lotteryData = {}
    self._userModel = self._modelMgr:getModel("UserModel")    
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._isQipao = false
end

function TreasureMerchantModel:setOutOfDate()
    print("============TreasureMerchantModel:setOutOfDate=======")
    self:reflashData("OutOfDate")
end

function TreasureMerchantModel:getTreasureMerchant()
    return self._userModel:getTreasureMerchant()
end

function TreasureMerchantModel:isTreasureMerchantOpen()
    local isOpen = false
    if not self._acModel then
        self._acModel = self._modelMgr:getModel("ActivityModel")
    end
    if not self._acData or table.nums(self._acData) == 0 then
        self._acData = self._acModel:getAcShowDataByType(44)
    end
    local userLvl = self._userModel:getPlayerLevel()
    local startTime = self._acData and self._acData.start_time or 0
    local endTime = self._acData and self._acData.end_time or 0
    local currTime = self._userModel:getCurServerTime()

    isOpen = startTime <= currTime and endTime > currTime
    local levelLimit = self._acData.level_limit or 0
    isOpen = isOpen and userLvl >= levelLimit
    return isOpen
end

function TreasureMerchantModel:getAcEndTime()
    if not self._acModel then
        self._acModel = self._modelMgr:getModel("ActivityModel")
    end
    if not self._acData or table.nums(self._acData) == 0 then
        self._acData = self._acModel:getAcShowDataByType(44)
    end
    dump(self._acData,"self._acData==>",5)
    local currTime = self._userModel:getCurServerTime()
    local endTime = self._acData and self._acData.end_time or currTime
    return endTime
end

function TreasureMerchantModel:setGiftResult(result)
    self._giftResut = result
end

function TreasureMerchantModel:getGiftResult()
    return self._giftResut
end
function TreasureMerchantModel:clearGiftResult()
    self._giftResut = nil
end

function TreasureMerchantModel:getQipaoStatus(  )
    return self._isQipao
end

function TreasureMerchantModel:setQipaoStatus( param )
    self._isQipao = param
end

return TreasureMerchantModel

