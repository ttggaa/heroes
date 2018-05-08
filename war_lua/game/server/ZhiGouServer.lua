--[[
    Filename:    ZhiGouServer.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-5-2 18:54:41
    Description: File description
--]]


local ZhiGouServer = class("ZhiGouServer",BaseServer)

function ZhiGouServer:ctor(data)
    ZhiGouServer.super.ctor(self,data)
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._directShopModel = self._modelMgr:getModel("DirectShopModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

--直购推送接口
function ZhiGouServer:onBuyShopItem( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"result",10)

	--更新vip
	local old_vip = self._vipModel:getLevel()
    local vip = result["d"].vip
    if vip and vip.level and old_vip then
        if vip.level > old_vip then
            ApiUtils.playcrab_monitor_vip_upgrade(old_vip, vip.level)
        end
    end
    self._vipModel:updateData(result["d"].vip)

	if result.d.shop.zhigou then
		self._directShopModel:setRmbResult(result)
		self._directShopModel:updateShopGoodsAfterBuy(result.d.shop)
		local data = result.d.shop.zhigou.weekCards or result.d.shop.zhigou
		for key,value in pairs (data) do 
			result.buyId = tonumber(key)
		end
		result.d.shop.zhigou = nil
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

--一元购推送接口

function ZhiGouServer:onPushOneCash(result,error)
	if error ~= 0 then
		return
	end
	dump(result)

	--更新vip
	local old_vip = self._vipModel:getLevel()
    local vip = result["d"].vip
    if vip and vip.level and old_vip then
        if vip.level > old_vip then
            ApiUtils.playcrab_monitor_vip_upgrade(old_vip, vip.level)
        end
    end
    self._vipModel:updateData(result["d"].vip)

	if result["d"] then
		self._directShopModel:setOneCashResult(result)
		self._itemModel:updateItems(result["d"]["items"])
		result["d"]["items"] = nil
		self._userModel:updateUserData(result["d"])
		self:callback(result)
	end
end

return ZhiGouServer