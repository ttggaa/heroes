--[[
    Filename:    CrossPKServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-09 16:03:12
    Description: File description
--]]



local CrossPKServer = class("CrossPKServer", BaseServer)

function CrossPKServer:ctor(data)
    CrossPKServer.super.ctor(self,data)
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
end

-- 获取跨服竞技场数据 1
function CrossPKServer:onGetCrossPKInfo(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] and result["d"]["crossPK"] ~= nil  then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:setData(result["d"]["crossPK"])
        result["d"]["crossPK"] = nil
    end 
    self:handAboutServerData(result)
    self:callback(result)
end

-- 与玩家竞技 2
function CrossPKServer:onCrossPK(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] and result["d"]["crossPK"] ~= nil  then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:updateCrossPKInfo(result["d"]["crossPK"])
        result["d"]["crossPK"] = nil
    end 
    self:handAboutServerData(result)
    self:callback(result)
end

-- 进入竞技场 3
function CrossPKServer:onEnterCrossPK(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "result==============", 10)
    if result["d"] and result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end

    if result["d"] and result["d"]["crossPK"] ~= nil then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:setArenaData(result["d"]["crossPK"])
        result["d"]["crossPK"] = nil
    end

    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 刷新挑战目标 4
function CrossPKServer:onRefreshCrossPK(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] and result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end

    if result["d"] and result["d"]["crossPK"] ~= nil then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:setArenaData(result["d"]["crossPK"])
        result["d"]["crossPK"] = nil
    end

    self:handAboutServerData(result)
    self:callback(result)
end

-- 挑战镜像前 5
function CrossPKServer:onAtkBeforeChallenge(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end


-- 挑战镜像后 6
function CrossPKServer:onAtkAfterChallenge(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] and result["d"]["crossPK"] ~= nil  then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:updateCrossPKInfo(result["d"]["crossPK"])
        result["d"]["crossPK"] = nil
    end 
    self:handAboutServerData(result)
    self:callback(result)
end

-- 购买竞技场挑战次数 7
function CrossPKServer:onBuyCrossPKTimes(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 获取挑战镜像信息 8
function CrossPKServer:onGetChallengeInfo(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"] and result["d"]["crossPK"] ~= nil then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:setSoloArenaData(result["d"]["crossPK"])
        result["d"]["crossPK"] = nil
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 获取本竞技场两个服务器前三玩家信息 9
function CrossPKServer:onGetNowFT(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 获取本竞技场两个服务器前十玩家信息 10
function CrossPKServer:onGetNowFTen(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 获取战报列表 11
function CrossPKServer:onGetReports(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 获取详细信息 12
function CrossPKServer:onGetDetailInfo(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 获取战报信息 13
function CrossPKServer:onGetBattleReport(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 获取排行榜信息 14
function CrossPKServer:onGetRankList(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    if result then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:setRankList(result)
    end
    self:callback(result)
end

-- 扫荡
function CrossPKServer:onSweepPK(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function CrossPKServer:onGetActiveReward( result, error )
    if error ~= 0 then
        return
    end
    dump(result, "result======================")
    if result["d"] and result["d"]["crossPK"] ~= nil and result["d"]["crossPK"]["activeIds"]  then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:setActiveData(result["d"]["crossPK"]["activeIds"])
        result["d"]["crossPK"]["activeIds"] = nil
    end 
    self:handAboutServerData(result)
    self:callback(result)
end

function CrossPKServer:handAboutServerData(result)
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

-- 推送
-- 积分变动
function CrossPKServer:onPushScoreUpdate(result, error)
    if error ~= 0 then 
        return
    end
    dump(result, "result======================")
    if result then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        crossModel:setScoreUpdate(true)
    end
end

-- 被打
function CrossPKServer:onPushUpdate(result, error)
    if error ~= 0 then 
        return
    end
    dump(result, "result======================")
    if result then 
        local crossModel = self._modelMgr:getModel("CrossModel")
        if result['region'] then
            crossModel:updateRegionPrompt(result['region'])
        end
        crossModel:setPkUpdate(true)
    end
end

return CrossPKServer
