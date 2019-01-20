--
-- Author: huangguofang
-- Date: 2018-10-09 15:42:41
--

local RaceDrawServer = class("RaceDrawServer", BaseServer)

function RaceDrawServer:ctor(data)
    RaceDrawServer.super.ctor(self,data)
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._raceDrawModel = self._modelMgr:getModel("RaceDrawModel")
end

function RaceDrawServer:onGetDrawCardInfo(result, error)
    dump(result,"result===>",5)
    if error ~= 0 then 
        return
    end
    if result == nil then
        return
    end
    self._raceDrawModel:setData(result)
    self:callback(result)
end

function RaceDrawServer:onDrawCard(result, error)
    dump(result,"result===>",5)
    print("==========onDrawCard==========",error)
    if error ~= 0 then 
        return
    end
    if result == nil then
        return
    end
    self:handAboutServerData(result)
    self:callback(result,error)
end


function RaceDrawServer:handAboutServerData(result)
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

    if result["d"] and result["d"]["drawAward"] then
        self._playerDayModel:updateDrawAward(result["d"]["drawAward"])
    end
   
    if result["d"] and result["d"]["dayInfo"] then
        self._playerDayModel:updateDayInfo(result["d"]["dayInfo"])
    end

    if result["d"] and result["d"]["raceDraws"] then 
        self._raceDrawModel:updateData(result["d"]["raceDraws"])
        result["d"]["raceDraws"] = nil
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return RaceDrawServer