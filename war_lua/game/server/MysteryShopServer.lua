--[[
    Filename:    ShopServer.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-09 17:20:19
    Description: File description
--]]


local MysteryShopServer = class("MysteryShopServer",BaseServer)

function MysteryShopServer:ctor(data)
    MysteryShopServer.super.ctor(self,data)
    self._MysteryShopModel = self._modelMgr:getModel("MysteryShopModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function MysteryShopServer:onGetMysteryShop( result, error)
	if error ~= 0 then 
		return
	end
	self._MysteryShopModel:setData(result.d or result)
	self:callback(result)
end

function MysteryShopServer:onRefreshMysteryShop( result, error)
	if error ~= 0 then 
		return
	end

	-- dump(result)
	self._userModel:updateUserData({gold = result.d.gold,freeGem = result.d.freeGem})
	result.d.freeGem = nil
	result.d.gold = nil
	self._MysteryShopModel:setData(result.d)
	self:callback(result)
end

function MysteryShopServer:onBuyMysteryShopItem( result, error)
	if error ~= 0 then 
		return
	end
	self._MysteryShopModel:updateGoods(result.d.mysteryShop.mysteryShopGoods)
	result.d.mysteryShop = nil
	result.d._id = nil
	-- 更新用户信息
	self._userModel:updateUserData({gold = result.d.gold,freeGem = result.d.freeGem})
	result.d.freeGem = nil
	result.d.gold = nil
	self._itemModel:updateItems(result["d"]["items"])
	self:callback(result)
end

return MysteryShopServer