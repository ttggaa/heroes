--[[
    Filename:    ShopServer.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-11-23 18:54:41
    Description: File description
--]]


local ShopServer = class("ShopServer",BaseServer)

function ShopServer:ctor(data)
    ShopServer.super.ctor(self,data)
    self._shopModel = self._modelMgr:getModel("ShopModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._directShopModel = self._modelMgr:getModel("DirectShopModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._recallModel = self._modelMgr:getModel("FriendRecallModel")
    self._teamShopModel = self._modelMgr:getModel("TeamShopModel")
end

function ShopServer:onGetShopInfo( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result.shop, "onGetShopInfo", 10)
	if result.shop.zhigou or result.zhigou then
		self._directShopModel:setData(result.shop or result)

	elseif result.shop.friend or result.friend then
		local friendData = result.shop.friend or result.friend
    	self._recallModel:setShopData(friendData)

    elseif result.rune or result.shop.rune then
        local shopData = result.shop.rune or result.rune
        self._teamShopModel:setData(shopData)
	else
		self._shopModel:setData(result.shop or result)
	end
	self:callback(result)
end

function ShopServer:onReflashShop( result, error)
	if error ~= 0 then 
		return
	end
    if result and result.d and result.d.shop and result.d.shop.rune then
        local shopData = result.d.shop.rune
        self._teamShopModel:updateShopView(shopData)
        result.d.shop.rune = nil 
    end
	-- dump(result.d.shop)
	self._shopModel:updateShop(result.d.shop)
	if result.d and result.d.dayInfo then
		self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
		result.d.drawAward = nil
	end
	result.d.shop = nil
	self._userModel:updateUserData(result["d"])
	self:callback(result)
end
function ShopServer:onBuyShopItem( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"result",10)
	-- dump(result.d.shop)
	if result.d.shop and result.d.shop.zhigou then
		self._directShopModel:updateShopGoodsAfterBuy(result.d.shop)
		local data = result.d.shop.zhigou.weekCards or result.d.shop.zhigou
		for key,value in pairs (data) do 
			result.buyId = tonumber(key)
		end
		result.d.shop.zhigou = nil

	elseif result.d.shop and result.d.shop.friend then
		self._recallModel:updateShopData(result.d.shop.friend)
		result.d.shop.friend = nil
    elseif result.d.shop and result.d.shop.rune then
        local shopData = result.d.shop.rune
        self._teamShopModel:updateShopView(shopData)
        result.d.shop.rune = nil 
	elseif result.d.shop then
		self._shopModel:updateShopGoodsAfterBuy(result.d.shop)
	else
		self._shopModel:reflashData()
	end

	
	result.d.shop = nil
	self._itemModel:updateItems(result["d"]["items"])
	result["d"]["items"] = nil
	if result["d"].teams then
        self._teamModel:updateTeamData(result["d"].teams)
        result["d"].teams = nil
    end
	self._userModel:updateUserData(result["d"])
	self:callback(result)
end

-- 领取刷新次数奖励
function ShopServer:onGetReflashAward( result, error)
    if error ~= 0 then 
        return
    end
    if result and result.d and result.d.shop and result.d.shop.rune then
        local shopData = result.d.shop.rune
        self._teamShopModel:updateShopView(shopData)
        result.d.shop.rune = nil 
    end
    
    self._itemModel:updateItems(result["d"]["items"])
    result["d"]["items"] = nil
    if result["d"].teams then
        self._teamModel:updateTeamData(result["d"].teams)
        result["d"].teams = nil
    end
    self._userModel:updateUserData(result["d"])
    self:callback(result)
end
return ShopServer