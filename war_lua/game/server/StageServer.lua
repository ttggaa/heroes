--[[
    Filename:    StageServer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-07-09 17:15:35
    Description: File description
--]]

local StageServer = class("StageServer", BaseServer)

function StageServer:ctor(data)
    StageServer.super.ctor(self,data)
    self._intanceModel = self._modelMgr:getModel("IntanceModel")
end

function StageServer:onAtkBeforeEliteStage(result, error)
    if error ~= 0 then
        return
    end
    self:callback(result)
end

function StageServer:onCollectEliteStarReward(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 2)
    self:callback(result)
end

function StageServer:onAtkAfterEliteStage(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 2)
    self:callback(result)
end

function StageServer:onSweepEliteStage(result, error)
    if error ~= 0 then
        return
    end
    
    self:handleAboutServerData(result, 2)
    self:callback(result)
end


function StageServer:onResetAtkNum(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 2)

    self:callback(result)
end

function StageServer:onAtkBeforeStage(result, error)
    if error ~= 0 then
        return
    end
    self:callback(result)
end


function StageServer:onAtkAfterStage(result, error)
	if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end



function StageServer:onSweepStage(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end

function StageServer:onCollectStarReward(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end


function StageServer:onGetBranchAcReward(result, error)
    if error ~= 0 then
        return
    end
    dump(result, "test", 10)
    self:handleAboutServerData(result, 1)
    self:callback(result)
end

function StageServer:onGetSectionBranchReward(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end

function StageServer:onGetMainBranchReward(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end

function StageServer:onAtkBeforeMainBranch(result, error)
    if error ~= 0 then
        return
    end
    self:callback(result)
end

function StageServer:onAtkAfterMainBranch(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end

function StageServer:onGetMStoryReward(result, error)
    print("onGetMainBranchReward==========================")

    if error ~= 0 then
        return
    end
    dump(result, "testt", 10)
    self:handleAboutServerData(result, 1)
    self:callback(result)
end

function StageServer:onGetEliteBranchReward(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 2)
    self:callback(result)
end


function StageServer:onAtkBeforeEliteBranch(result, error)
    if error ~= 0 then
        return
    end
    self:callback(result)
end

function StageServer:onAtkAfterEliteBranch(result, error)
    if error ~= 0 then
        return
    end

    self:callback(result)
end

function StageServer:onGetSectionReward(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end

function StageServer:onAtkStageLose(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end

function StageServer:onAtkEliteStageLose(result, error)
    if error ~= 0 then
        return
    end
    self:handleAboutServerData(result, 1)
    self:callback(result)
end


function StageServer:onShowReport(result, error)
    if error ~= 0 then
        return
    end
    self:callback(result)
end

function StageServer:onSetSectionId(result, error)
    if error ~= 0 then
        return
    end
    if result ~= nil and result["d"] then 
        if result["d"]["story"] ~= nil then 
            if result["d"]["story"]["acSectionId"] ~= nil  then 
                local intanceModel = self._modelMgr:getModel("IntanceModel")
                intanceModel:updateMainsData(result["d"]["story"])
                result["d"]["story"] = nil
            else
                local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
                intanceEliteModel:updateData(result["d"]["story"])
                result["d"]["story"] = nil               
            end
        end
    end
    self:callback(result)
end



function StageServer:handleAboutServerData(result,inType)
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
            dump(result["d"]["story"], "test111", 10)
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
end

return StageServer