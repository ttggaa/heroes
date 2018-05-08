--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-10-14 15:42:49
--

local AdventureServer = class("AdventureServer",BaseServer)

function AdventureServer:ctor(data)
    AdventureServer.super.ctor(self,data)
    self._adModel = self._modelMgr:getModel("AdventureModel")
end

function AdventureServer:onInit( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"onInit adventure....")
	self._adModel:setData(result)
	self:callback(result)
end

function AdventureServer:onThrowDice( result, error)
	if error ~= 0 then 
		return
	end
	self:callback(result)
	self:handleResultData(result)
end


function AdventureServer:onThrowDiceTest( result, error)
	if error ~= 0 then 
		return
	end
	self:callback(result)
	self:handleResultData(result)
end

function AdventureServer:onGetRewardList( result, error)
	if error ~= 0 then 
		return
	end
	self:callback(result)
end

function AdventureServer:onGetRoundReward( result, error)
	if error ~= 0 then 
		return
	end
	self:handleResultData(result)
	self:callback(result)
end

function AdventureServer:onGuessFinger( result, error)
	if error ~= 0 then 
		return
	end
	self:handleResultData(result)
	self:callback(result)
end

function AdventureServer:onChooseNum( result, error)
	if error ~= 0 then 
		return
	end
	self:handleResultData(result)
	self:callback(result)
end

function AdventureServer:onFightBefore( result, error)
	if error ~= 0 then 
		return
	end
	self:handleResultData(result)
	self:callback(result)
end

function AdventureServer:onFightAfter( result, error)
	if error ~= 0 then 
		return
	end
	self:handleResultData(result)
	self:callback(result)
end

function AdventureServer:onBuyDice( result, error)
	if error ~= 0 then 
		return
	end
	self:handleResultData(result)
	self:callback(result)
end

function AdventureServer:handleResultData( result )
	if result and result.d and result.d.dayInfo then
		self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
		result.d.dayInfo = nil
	end
	if result and result.d and result.d.items then
		local itemModel = self._modelMgr:getModel("ItemModel")
	    itemModel:updateItems(result["d"]["items"], true)
	    result["d"]["items"] = nil
	end 
	if result and result.d then
		-- dump(result,"adv pro data")
		self._modelMgr:getModel("UserModel"):updateUserData(result.d)
		result.d = nil
	end
	self._adModel:updateAdventure(result)
end


return AdventureServer