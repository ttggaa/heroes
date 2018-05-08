--[[
    Filename:    TreasureServer.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-01-27 15:06:11
    Description: File description
--]]


local TreasureServer = class("TreasureServer",BaseServer)

function TreasureServer:ctor(data)
    TreasureServer.super.ctor(self,data)
    self._treasureModel = self._modelMgr:getModel("TreasureModel")
end

function TreasureServer:onGetTreasure( result, error)
	if error ~= 0 then 
		return
	end
	if result.treasures then
		self._treasureModel:setData(result.treasures)
		result.treasures = nil
	end
	self:handleResult( result )
	self:callback(result)
end

function TreasureServer:onActivationComTreasure( result, error)
	if error ~= 0 then 
		return
	end
	-- self._treasureModel:activeComTreasure(result.d.treasures)
	self:handleResult( result )
	self:callback(result)
end

function TreasureServer:onWearDisTreasure( result, error)
	if error ~= 0 then 
		return
	end
	-- self._treasureModel:wearOnDisTreasure(result.d.treasures)
	self:handleResult( result )
	self:callback(result)
end


function TreasureServer:onDrewDisTreasure( result, error)
	if error ~= 0 then 
		return
	end

    local curTreasureCoin = self._modelMgr:getModel("UserModel"):getData().treasureCoin or 0
    if result and result.d and result.d.treasureCoin then
        result.treasureCoinNum = result.d.treasureCoin - curTreasureCoin
    end
	self:handleResult( result )
	self:callback(result)
end

-- 分离出来免费抽的接口 包括特权和黑市币
function TreasureServer:onDrewFreeDisTreasure( result, error)
	if error ~= 0 then 
		return
	end

    local curTreasureCoin = self._modelMgr:getModel("UserModel"):getData().treasureCoin or 0
    if result and result.d and result.d.treasureCoin then
        result.treasureCoinNum = result.d.treasureCoin - curTreasureCoin
    end
	self:handleResult( result )
	self:callback(result)
end


function TreasureServer:onPromoteComTreasure( result, error)
	if error ~= 0 then 
		return
	end
	self:handleResult( result )
	self:callback(result)
end


function TreasureServer:onPromoteDisTreasure( result, error)
	if error ~= 0 then 
		return
	end
	self:handleResult( result )
	self:callback(result)
end


function TreasureServer:onUpStar( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"result..",10)
	self:handleResult( result )
	self:callback(result)
end


function TreasureServer:onDismantlingDisTreasure( result, error)
	if error ~= 0 then 
		return
	end

	self:handleResult( result )
	-- self._treasureModel:upDateTreasure(result.d.treasures)
	self:callback(result)
end

function TreasureServer:handleResult( result )
	if result.d and result.d.drawAward then
		self._modelMgr:getModel("PlayerTodayModel"):updateDrawAward(result.d.drawAward)
		result.d.drawAward = nil
	end
	if result and result.formations then
		self._modelMgr:getModel("FormationModel"):updateAllFormationData(result.formations)
		result.formations = nil
	end
	if result.d and result.d.dayInfo then
		self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
		result.d.drawAward = nil
	end
	local itemModel = self._modelMgr:getModel("ItemModel")
	if result.d and result.d.items then
		itemModel:updateItems(result.d.items)
		result.d.items = nil
	end
	if result.d and result.d.treasures then
		self._treasureModel:upDateTreasure(result.d.treasures)
		result.d.treasures = nil
	end
	if result.d then
		local userModel = self._modelMgr:getModel("UserModel")
		userModel:updateUserData(result.d)
	end
	if result.d and result.d.tformations then
		local tFModel = self._modelMgr:getModel("TformationModel")
		tFModel:updateData( result.d.tformations )
	end
	if result["unset"] then
		local itemModel = self._modelMgr:getModel("ItemModel")
		local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
	end
end

return TreasureServer