--
-- Author: huangguofang
-- Date: 2018-04-12 17:25:03
--

local RuneCardModel = class("RuneCardModel", BaseModel)

function RuneCardModel:ctor()
    RuneCardModel.super.ctor(self)
    self._lotteryData = {}
    self._userModel = self._modelMgr:getModel("UserModel")    
	self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
end

function RuneCardModel:setOutOfDate()
    self:reflashData("OutOfDate")
end

function RuneCardModel:getRuneCardData()
	return self._userModel:getRuneCardData()
end

-- 每日奖励领取状态
function RuneCardModel:getRuneCardDailyStatus()
	local status = 0
	local infoNum = self._playerTodayModel:getDayInfo(87)
	if infoNum then
		status = infoNum
	end
	return status
end

return RuneCardModel

