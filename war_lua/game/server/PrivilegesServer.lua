--[[
    Filename:    PrivilegesServer.lua
    Author:      qiaohuan@playcrab.com 
    Datetime:    2015-11-04 17:55:19
    Description: File description
--]]
local PrivilegesServer = class("PrivilegesServer", BaseServer)

function PrivilegesServer:ctor(data)
    PrivilegesServer.super.ctor(self, data)
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
end

function PrivilegesServer:onUpPeerage(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function PrivilegesServer:onUpAbility(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 领取每日工资
function PrivilegesServer:onGetWages(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function PrivilegesServer:onGetPrivilegeInfo(result, error)
    if error ~= 0 then 
        return
    end
    self._privilegesModel:setData(result["d"])
    self:callback(result)
end

function PrivilegesServer:onGetShopInfo(result, error)
    if error ~= 0 then 
        return
    end
    dump(result, "result======")
    self:handAboutServerData(result)
    self:callback(result)
end

function PrivilegesServer:onBuyBuff(result, error)
    if error ~= 0 then 
        return
    end
    dump(result, "result======")
    self:handAboutServerData(result)
    self:callback(result)
end

function PrivilegesServer:handAboutServerData(result)
    if result == nil then 
        return 
    end
   -- -- 物品数据处理要优先于怪兽
    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end

    if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end

    if result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result["d"].dayInfo or {})
    end

    if result["d"]["task"] ~= nil  then
        self._modelMgr:getModel("TaskModel"):updateDetailTaskData(result["d"], 0 == tonumber(error))
        result["d"]["task"] = nil
    end
    
    if result["d"]["privileges"] ~= nil  then
        self._privilegesModel:updatePrivilegeData(result["d"]["privileges"])
        result["d"]["privileges"] = nil
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return PrivilegesServer

-- function PrivilegesServer:onUpPrivilegeLevel(result, error)
--     print("打印result")
--     dump("debug", result, "onUpPrivilegeLevel")
--     if error ~= 0 then
--         print("error ....",error)
--         return
--     end
--     self:callback(result)
-- end

