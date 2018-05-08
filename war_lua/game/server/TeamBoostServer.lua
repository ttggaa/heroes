--[[
    Filename:    TeamBoostServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-10-27 10:25:57
    Description: File description
--]]


local TeamBoostServer = class("TeamBoostServer", BaseServer)

function TeamBoostServer:ctor()
    TeamBoostServer.super.ctor(self)
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function TeamBoostServer:onUpTeamBoostLevel(result, error)
    if error ~= 0 then 
        return
    end

    -- dump(result, "result =======", 10)
    self:handAboutServerData(result)
    -- 
    -- if result["d"]["teams"] then
    --     self._teamModel:updateTeamData(result["d"]["teams"])
    -- end
    self:callback(result)
end

function TeamBoostServer:onBuyTBNum(result, error)
    if error ~= 0 then 
        return
    end

    self:handAboutServerData(result)
    self:callback(result)
end


function TeamBoostServer:handAboutServerData(result)
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

    if result.d and result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
    end
        
    if result["d"]["teamPokedex"] ~= nil  then
        self._modelMgr:getModel("PokedexModel"):updateData(result["d"]["teamPokedex"])
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return TeamBoostServer