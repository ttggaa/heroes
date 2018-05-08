--[[
    Filename:    CrusadeServer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-23 10:21:30
    Description: File description
--]]

local CrusadeServer = class("CrusadeServer",BaseServer)

function CrusadeServer:ctor(data)
    CrusadeServer.super.ctor(self,data)
    -- self._crusadeModel = self._modelMgr:getModel("CrusadeModel")  
end

function CrusadeServer:onGetCrusadeInfo(result, error)
    -- if error ~= 0 then 
    --     return
    -- end
    self:checkUserFormationData(result, 1)
    self:handleResetCrusadeData(result)
    self:callback(result)
end

function CrusadeServer:onGetRivalInfo(result, error)
    if error ~= 0 then 
        return
    end
    self:checkUserFormationData(result, 2)
    self:callback(result)
end

function CrusadeServer:onBeforeAttackCrusade(result, error)
    if error ~= 0 then 
        return
    end
    self:checkUserFormationData(result, 3)
    self:callback(result)
end

function CrusadeServer:onGetCrusadeEventReward(result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result)
    self:callback(result)
end


function CrusadeServer:onAfterAttackCrusade(result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:onEnterCrusadeEvent(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end

function CrusadeServer:onBuyCrusadeEventReward(result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:onGetCrusadePcsReward(result, error)
    if error ~= 0 then 
        return

    end
    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:onResetCrusade(result, error)
    if error ~= 0 then 
        return
    end
    self:handleResetCrusadeData(result)
    self:callback(result)
end


function CrusadeServer:onGetCrusadeBoxReward(result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:handleResetCrusadeData(result)
    if result == nil then 
        return 
    end
    
    if result["dayInfo"] ~= nil then
        local playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
        playerTodayModel:setDayInfo(8, result["dayInfo"].day8)
    end

    if result["crusade"] ~= nil then 
        local crusadeModel = self._modelMgr:getModel("CrusadeModel")
        crusadeModel:setData(result["crusade"])
    end

    if result["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["formations"])
    end

    if result["resetCrusadeCD"] ~= nil then 
        local userData = self._modelMgr:getModel("UserModel"):getData()
        userData.resetCrusadeCD = result["resetCrusadeCD"]
    end
end 

--wangyan
function CrusadeServer:onEnterTriggerCrusade(result, error)
    if error ~= 0 then 
        return
    end
    local crusadeModel = self._modelMgr:getModel("CrusadeModel")
    self:callback(result)
end

--wangyan
function CrusadeServer:onGetCrusadeTriggerReward(result, error)
    if error ~= 0 then 
        return
    end
    
    -- dump(result, "", 10)
    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:onAbandonTriggerCrusade(result, error)
    if error ~= 0 then 
        return
    end
    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:onSweepCrusade(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "onSweepCrusade", 10)
    self:handleAboutServerData(result)
    self:callback(result)
end


----一键扫荡
function CrusadeServer:onOneKeySweepCrusade(result, error)
    dump(result, "onOneKeySweepCrusade", 10)
    if error ~= 0 then 
        return
    end

    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:onChooseSweepCrusadeBuff(result, error)
    dump(result, "onChooseSweepCrusadeBuff", 10)
    if error ~= 0 then 
        return
    end

    self:handleAboutServerData(result)
    self:callback(result)
end
function CrusadeServer:onOpenSweepCrusadeBox(result, error)
    dump(result, "onOpenSweepCrusadeBox", 10)
    if error ~= 0 then 
        return
    end

    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:onFinishOneKeySweepCrusade(result, error)
    dump(result, "onFinishOneKeySweepCrusade", 10)
    if error ~= 0 then 
        return
    end

    self:handleAboutServerData(result)
    self:callback(result)
end

function CrusadeServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return 
    end

    if result["d"]["crusade"] ~= nil then 
        local crusadeModel = self._modelMgr:getModel("CrusadeModel")
        crusadeModel:updateCrusadeData(result["d"]["crusade"])
        result["d"]["crusade"] = nil
    end


    if result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end


    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"]["teams"] ~= nil then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end

    if result["d"]["handbooks"] ~= nil then 
        local hbModel = self._modelMgr:getModel("HandbookModel")
        hbModel:updateData(result["d"]["handbooks"])
        result["d"]["handbooks"] = nil
    end

    -- 更新用户数据
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

--检查玩家布阵数据结构
function CrusadeServer:checkUserFormationData(inData, inType)
    local fakeFormation = {
            filter = "102,106,105",
            g1 = 0, g2 = 0, g3 = 0, g4 = 0,
            g5 = 0, g6 = 0, g7 = 0, g8 = 0,
            heroId = 60102,
            lt     = 1497409106,
            score  = 8750,
            team1 = 0,team2 = 0,team3 = 0,team4 = 0,
            team5 = 0,team6 = 0,team7 = 0,team8 = 0,
        }
    local checkInfo = {"heroId",  "g1", "team1"}

    local function checkDataFun(inFData)
        if inFData["formation"] == nil then
            return
        end
        -- inFData["formation"] = {}
        for p=#checkInfo, 1, -1 do
            if inFData["formation"][checkInfo[p]] == nil then
                inFData["formation"] = fakeFormation
                if inFData["teams"] then
                    inFData["teams"] = {}
                end
                if inFData["pokedex"] then
                    for k,v in pairs(inFData["pokedex"]) do
                        v = 0
                    end
                end
                
                return 
            end
        end
    end

    if inType == 1 then         --onGetCrusadeInfo
        if inData["crusade"] and inData["crusade"]["fighting"] then
        local fData = inData["crusade"]["fighting"]
        for k,v in pairs(fData) do
            checkDataFun(v)
        end
    end
    elseif inType == 2 then     --onGetRivalInfo
        checkDataFun(inData)

    elseif inType == 3 then     --onBeforeAttackCrusade
        if inData["def"] == nil then
            return
        end
        checkDataFun(inData["def"])
    end
end

return CrusadeServer