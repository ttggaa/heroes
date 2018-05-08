--[[
    Filename:    DefenseServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-09 17:51:49
    Description: File description
--]]


local DefenseServer = class("DefenseServer", BaseServer)

function DefenseServer:ctor(data)
    DefenseServer.super.ctor(self,data)
    self._teamModel = self._modelMgr:getModel("TeamModel")
end


-- 升级主城
function DefenseServer:onUpgradeMain(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 升级城防
function DefenseServer:onUpgradeWall(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 升级护城河
function DefenseServer:onUpgradeRiver(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 设置主城类型
function DefenseServer:onSetCity(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 设置箭塔兵团
function DefenseServer:onSetTeam(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 撤回箭塔兵团
function DefenseServer:onRetractTeam(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

function DefenseServer:handAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return 
    end
   -- 物品数据处理要优先于怪兽
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

    if result["d"]["teams"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end 

    if result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        -- formationModel:updateFormationDataByType(formationModel.kFormationTypeCommon, result["d"]["formations"][tostring(formationModel.kFormationTypeCommon)])
        result["d"]["formations"] = nil
    end
        
    if result["d"]["teamPokedex"] ~= nil  then
        self._modelMgr:getModel("PokedexModel"):updateData(result["d"]["teamPokedex"])
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return DefenseServer