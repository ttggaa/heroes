--[[
    Filename:    IdipServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-10-25 16:38:54
    Description: File description
--]]

local IdipServer = class("IdipServer", BaseServer)

function IdipServer:ctor(data)
    IdipServer.super.ctor(self, data)
    self._initModel = false
end

function IdipServer:initModel()
    if self._initModel then return end
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._initModel = true
end

function IdipServer:onChangeFinance(result, error)
    dump(result, "onChangeFinance", 5)
    if 0 ~= tonumber(error) then return end
    self:initModel()
    if result and result.d then
        self._userModel:updateUserData(result.d)
    end
end

function IdipServer:onUpdateItem(result, error)
    dump(result, "onUpdateItem", 5)
    if 0 ~= tonumber(error) then return end
    self:initModel()
    if result and result.unset then 
        local removeItems = self._itemModel:handelUnsetItems(result.unset)
        self._itemModel:delItems(removeItems, true)
    end
    
    if result and result.d and result.d.items then
        self._itemModel:updateItems(result["d"].items)
        result["d"].items = nil
    end
end

function IdipServer:onUpdateVip(result, error)
    dump(result, "onUpdateVip", 5)
    if 0 ~= tonumber(error) then return end
    self:initModel()
    if result and result.d and result.d.vip then
        self._vipModel:updateVipExpData(result.d.vip)
    end
end

function IdipServer:onUpdatePlayerLevel(result, error)
    dump(result, "onUpdatePlayerLevel", 5)
    if 0 ~= tonumber(error) then return end
    self:initModel()
    if result and result.d then
        self._userModel:updateUserData(result.d)
    end
end

return IdipServer
