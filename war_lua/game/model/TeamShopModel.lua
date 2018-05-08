--[[
    Filename:    TeamShopModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-29 11:34:05
    Description: File description
--]]

local TeamShopModel = class("TeamShopModel", BaseModel)

function TeamShopModel:ctor()
    TeamShopModel.super.ctor(self)
    self._times = false
end

function TeamShopModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function TeamShopModel:setData(data)
    if self._times == false then
        local value = tab:Setting("G_RUNESHOP_REFRESH").value
        for i,v in pairs(value) do
            self:registerTimer(v, 0, 30, specialize(self.getShopInfo, self))
        end
        self._times = true
    end

    if data.goods then
        self._goods = self:progressGoods(data.goods)
        data.goods = nil 
    end

    if data.award then
        self._award = data.award
        data.award = nil
	else
		self._award = {}
    end
    self._data = data

    self:reflashData()
end

function TeamShopModel:progressGoods(goodsData)
    local backData = {}
    for k,v in pairs(goodsData) do
        local indexId = tonumber(k)
        v.key = indexId
        backData[indexId] = v
    end
    return backData
end

function TeamShopModel:getGoods()
    return self._goods or {}
end

function TeamShopModel:getAwards()
    return self._award or {}
end

function TeamShopModel:setJoinShopView(flag)
    self._joinShop = flag
end

function TeamShopModel:getJoinShopView()
    return self._joinShop or false
end

function TeamShopModel:getShopInfo()
    local flag = self:getJoinShopView()
    if flag == false then
        return 
    end
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type="rune"}, true, {}, function(result)
        
    end)
end

function TeamShopModel:updateShopView(data)
    local oldData = self._data
    for k,v in pairs(data) do
        if k == "goods" then
            if not self._goods then
                self._goods = {}
            end
            for k1,v1 in pairs(v) do
                local indexId = tonumber(k1)
                if self._goods[indexId] then
                    for k2,v2 in pairs(v1) do
                        self._goods[indexId][k2] = v2
                    end
                    v1.key = indexId
                else
                    self._goods[indexId] = v1
                    v1.key = indexId
                end
            end
        elseif k == "award" then
            if not self._award then
                self._award = {}
            end
            for k1,v1 in pairs(v) do
                self._award[k1] = v
            end
        else
            oldData[k] = v
        end
    end
end

return TeamShopModel