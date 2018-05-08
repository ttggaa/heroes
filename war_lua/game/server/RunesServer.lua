--[[
    Filename:    RunesServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-08 16:29:47
    Description: File description
--]]


local RunesServer = class("RunesServer", BaseServer)

function RunesServer:ctor(data)
    RunesServer.super.ctor(self,data)
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
end

-- 分解符文
function RunesServer:onResolveRunes(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 升级符文
function RunesServer:onUpLvlRunes(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 觉醒符文
function RunesServer:onAwakeRunes(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function RunesServer:handAboutServerData(result)
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
        local teamModel = self._modelMgr:getModel("TeamModel")
        local removeHoly = teamModel:handelUnsetHoly(result["unset"])
        teamModel:removeHoly(removeHoly)

        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end

    if result["d"]["runes"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateHolyData(result["d"]["runes"])
        result["d"]["runes"] = nil
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

return RunesServer
