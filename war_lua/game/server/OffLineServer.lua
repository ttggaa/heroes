--[[
    Filename:    OffLineServer.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-6-16 18:54:41
    Description: File description
--]]


local OffLineServer = class("OffLineServer",BaseServer)

function OffLineServer:ctor(data)
    OffLineServer.super.ctor(self,data)
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

--领取玩家离线经验  receiveUserExp
function OffLineServer:onReceiveUserExp( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"result",10)
	if result["d"] then
		self._userModel:updateUserData(result["d"])
	end
	self:callback(result)
end

--领取玩家离线兵团经验  receiveUserTexp
function OffLineServer:onReceiveUserTexp( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"result",10)
	if result["d"] then
		self._userModel:updateUserData(result["d"])
	end
	self:callback(result)
end

--领取玩家离线金币  receiveUserGold
function OffLineServer:onReceiveUserGold ( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"result",10)
	if result["d"] then
		self._userModel:updateUserData(result["d"])
	end
	self:callback(result)
end

return OffLineServer