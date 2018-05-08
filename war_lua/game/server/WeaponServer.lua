--[[
    Filename:    WeaponServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-09-08 15:04:36
    Description: File description
--]]


local WeaponServer = class("WeaponServer", BaseServer)

function WeaponServer:ctor(data)
    WeaponServer.super.ctor(self,data)
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
end

-- 获取器械数据
function WeaponServer:onGetWeaponInfo(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] and result["d"]["weaponInfo"] ~= nil  then 
        local weaponsModel = self._modelMgr:getModel("WeaponsModel")
        weaponsModel:setData(result["d"]["weaponInfo"])
        result["d"]["weaponInfo"] = nil
    end 
    self:callback(result)
end

-- 升级器械
function WeaponServer:onUpgradeWeapon(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 解锁器械
function WeaponServer:onUnlockWeapon(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 安装配件
function WeaponServer:onInstallProp(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 卸载配件
function WeaponServer:onUninstallProp(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 升级配件
function WeaponServer:onUpgradeProp(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 分解配件
function WeaponServer:onResolveProp(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 抽取器械
function WeaponServer:onDrawSiegeWeapon(result, error)
    -- dump(result,"resultresult",10)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function WeaponServer:handAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return 
    end
   -- 物品数据处理要优先于怪兽
    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil 
    end

    if result["unset"] ~= nil then 
        local weaponsModel = self._modelMgr:getModel("WeaponsModel")
        local removeProps = weaponsModel:handelUnsetProps(result["unset"])
        weaponsModel:removeProps(removeProps)

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

    if result["d"]["weaponInfo"] ~= nil  then 
        local weaponsModel = self._modelMgr:getModel("WeaponsModel")
        weaponsModel:updateWeaponsInfo(result["d"]["weaponInfo"])
        result["d"]["weaponInfo"] = nil
    end 

        
    if result["d"]["teamPokedex"] ~= nil  then
        self._modelMgr:getModel("PokedexModel"):updateData(result["d"]["teamPokedex"])
    end

    if result["d"]["drawAward"] then
        self._playerTodayModel:updateDrawAward(result["d"]["drawAward"])
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return WeaponServer
