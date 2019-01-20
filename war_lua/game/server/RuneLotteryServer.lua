--
-- Author: huangguofang
-- Date: 2018-03-16 11:42:07
--
local RuneLotteryServer = class("RuneLotteryServer", BaseServer)

function RuneLotteryServer:ctor(data)
    RuneLotteryServer.super.ctor(self,data)
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._runeLotteryModel = self._modelMgr:getModel("RuneLotteryModel")
end

-- 获取幸运抽奖信息
function RuneLotteryServer:onGetInfo(result, error)
    if error ~= 0 then 
        return
    end
--    dump(result,"onGetInfo==>",5)
    self._runeLotteryModel:setData(result)
    self:handAboutServerData(result)
    self:callback(result)
end

-- 抽奖 1 & 5
function RuneLotteryServer:onDrawRunes(result, error)
    if error ~= 0 then 
        return
    end
    dump(result,"onDrawRunes==>",5)
    self:handAboutServerData(result)
    self:callback(result)
end

-- 幸运夺宝宝箱兑换
function RuneLotteryServer:onGetRuneBox(result, error)
    if error ~= 0 then 
        return
    end
    dump(result,"onGetRuneBox==>",5)
    self._runeLotteryModel:updateServerData(result["runeLottery"])
    self:handAboutServerData(result)
    self:callback(result)
end

--幸运夺宝商店兑换圣徽
function RuneLotteryServer:onBuyRune(result, error)
    if error ~= 0 then 
        return
    end
    dump(result,"onBuyRune==>",5)
    self._runeLotteryModel:updateServerData(result["runeLottery"])
    self:handAboutServerData(result)
    self:callback(result)
end
function RuneLotteryServer:handAboutServerData(result)
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

    if result["d"] and result["d"]["dayInfo"] then
        local playerTodataModel = self._modelMgr:getModel("PlayerTodayModel")
        playerTodataModel:updateDayInfo(result["d"]["dayInfo"])
        result["d"]["dayInfo"] = nil
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return RuneLotteryServer