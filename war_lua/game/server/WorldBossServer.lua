--[[
    @FileName   WorldBossServer.lua
    @Authors    zhangtao
    @Date       2018-10-26 14:40:00
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]

local WorldBossServer = class("WorldBossServer",BaseServer)

function WorldBossServer:ctor(data)
    WorldBossServer.super.ctor(self,data)
    self._bossModel = self._modelMgr:getModel("WorldBossModel")
end

function WorldBossServer:onGetInfo(result,error)
    if error ~= 0 then 
        self:callback(result,error)
        return
    end
    -- dump(result,"=====result=======")
    self._bossModel:upWorldBossInfoData(result)
    self:handleAboutServerData(result)
    self:callback(result,error)


end

function WorldBossServer:onRmCD(result,error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result)
    self:callback(result,error)
end

function WorldBossServer:onGetAward(result,error)
    if error ~= 0 then 
        return
    end
    if result then 
        self:handleAboutServerData(result)
    end
    self:callback(result,error)
end

function WorldBossServer:onAtkBefore(result,error)
    if error ~= 0 then 
        return
    end
    self:callback(result,error)
end

function WorldBossServer:onAtkAfter(result,error)
    if error ~= 0 then 
        return
    end
    if result then 
        self:handleAboutServerData(result)
    end

    self:callback(result,error)
end


function WorldBossServer:handleAboutServerData(result,inType)
    if result == nil or result["d"] == nil then 
        return 
    end
    if inType == 2 then 
        if result["d"]["story"] ~= nil then 
            local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
            intanceEliteModel:updateData(result["d"]["story"])
            result["d"]["story"] = nil
        end
    else
        if result["d"]["story"] ~= nil then 
            local intanceModel = self._modelMgr:getModel("IntanceModel")
            intanceModel:updateMainsData(result["d"]["story"])
            result["d"]["story"] = nil

            -- 精英副本数据依赖于普通副本，当普通副本产生战斗数据变化则更新精英
            local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
            intanceEliteModel:updateSectionIdAndStageId()
        end
    end

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"]["heros"] ~= nil then 
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(result["d"]["heros"])
        result["d"]["heros"] = nil
    end

    if result["d"]["formations"] ~= nil then 
        dump(result["d"]["formations"], "test", 10)
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        -- formationModel:updateFormationDataByType(formationModel.kFormationTypeCommon, result["d"]["formations"][tostring(formationModel.kFormationTypeCommon)])
        result["d"]["formations"] = nil
    end

    if result["d"]["worldBoss"] ~= nil then
        local rewardList = result["d"]["worldBoss"]["rewardList"] or {}
        self._bossModel:upDateRankList(rewardList)
    end

    local tempTeams = nil
    if result["d"]["teams"] ~= nil then
        tempTeams = result["d"]["teams"]
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end
    
    -- 更新用户数据
    local userModel = self._modelMgr:getModel("UserModel")
    -- 处理英雄皮肤数据   hgf
    if result["d"]["hSkin"] then
        userModel:updateSkinData(result["d"]["hSkin"])
        result["d"]["hSkin"] = nil
    end

    -- 新手引导模拟用参数
    if not result["d"].dontUpdateUser then
        userModel:updateUserData(result["d"])
    end

    result["d"]["teams"] = tempTeams

    if result["d"]["siege"] then
        self._sModel:updateData(result["d"]["siege"])
    end
end

return WorldBossServer