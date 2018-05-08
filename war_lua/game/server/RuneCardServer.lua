--
-- Author: huangguofang
-- Date: 2018-04-12 17:10:09
--

local RuneCardServer = class("RuneCardServer",BaseServer)

function RuneCardServer:ctor(data)
    RuneCardServer.super.ctor(self,data)
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._runeCardModel = self._modelMgr:getModel("RuneCardModel")
end

-- 圣徽周卡  推送接口
function RuneCardServer:onBuyRuneCard( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"result",10)
	--
	local old_vip = self._vipModel:getLevel()
    local vip = result["d"].vip
    if vip and vip.level and old_vip then
        if vip.level > old_vip then
            ApiUtils.playcrab_monitor_vip_upgrade(old_vip, vip.level)
        end
    end
    self._vipModel:updateData(result["d"].vip)
	self._userModel:updateUserData(result["d"])
	-- self:callback(result)
	self._runeCardModel:setOutOfDate()
end

-- 领取每日奖励
function RuneCardServer:onGetRuneCardDailyReward(result,error)
	if error ~= 0 then
		return
	end
	dump(result,"result==>",5)
	local itemModel = self._modelMgr:getModel("ItemModel")
    itemModel:updateItems(result["d"]["items"], true)
    result["d"]["items"] = nil
    
	self._userModel:updateUserData(result["d"])
	self:callback(error == 0,result)
end
--领取一次奖励
function RuneCardServer:onGetRuneCardOneTimeReward(result,error)
	if error ~= 0 then
		return
	end
	dump(result,"result==>",5)
	local itemModel = self._modelMgr:getModel("ItemModel")
    itemModel:updateItems(result["d"]["items"], true)
    result["d"]["items"] = nil
    
	self._userModel:updateUserData(result["d"])
	self:callback(error == 0,result)
end

return RuneCardServer