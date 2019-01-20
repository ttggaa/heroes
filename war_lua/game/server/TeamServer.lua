--[[
    Filename:    TeamServer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-20 19:13:20
    Description: File description
--]]

local TeamServer = class("TeamServer", BaseServer)

function TeamServer:ctor(data)
    TeamServer.super.ctor(self,data)
    self._teamModel = self._modelMgr:getModel("TeamModel")
end

function TeamServer:onGetTeams(result, error)
    if error ~= 0 then 
        return
    end
    -- dump("debug",result,"TeamServer:onGetTeams")
    local d = self._teamModel:setData(result["teams"])
    self:callback()

end

function TeamServer:onDrawAward(result, error)
    if error ~= 0 then 
        return
    end
    if result == nil then
        return
    end
    
    local userModel = self._modelMgr:getModel("UserModel")
    local itemModel = self._modelMgr:getModel("ItemModel")

    if result["unset"] ~= nil then 
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems)
    end
        
    if result["d"] ~= nil then 
        --更新道具数据
        if result["d"]["items"] then
            itemModel:updateItems(result["d"]["items"])
            result["d"]["items"] = nil
        end

        --更新方阵数据
        if result["d"]["teams"] then
            self._teamModel:updateTeamData(result["d"]["teams"])
            result["d"]["teams"] = nil
        end


        if result["d"]["formations"] ~= nil then 
            local formationModel = self._modelMgr:getModel("FormationModel")
            formationModel:updateFormationDataByType(formationModel.kFormationTypeCommon, result["d"]["formations"][tostring(formationModel.kFormationTypeCommon)])
            result["d"]["formations"] = nil
        end

        if result.d.dayInfo then
            self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo or {})
        end
        if result.d.drawAward then
            self._modelMgr:getModel("PlayerTodayModel"):updateDrawAward(result.d["drawAward"])
        end
        --更新用户钻石
        userModel:updateUserData(result["d"])
    end

    self:callback(result)
end

function TeamServer:onUpgradeStar(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onUpgradeMaxStar(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onUpgradeEquip(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end


function TeamServer:onUpgradeStageEquip(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)

    self:callback(result)
end

function TeamServer:onUpgradeTeam(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onUpgradeSkill(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onUpgradeStageTeam(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onBatchUpgradeEquip(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onOpenSkill(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 激活潜能
function TeamServer:onActivationPotential(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 升级潜能
function TeamServer:onUpPotential(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 天赋培养
function TeamServer:onTrainTalent(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 保存天赋
function TeamServer:onSaveTalent(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 解锁符文宝石槽
function TeamServer:onUnlockRuneSlot(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 装备符文
function TeamServer:onEquipRune(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 卸下符文
function TeamServer:onTakeRune(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 更换兵团皮肤
function TeamServer:onSwitchSkin(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onSwitchSpecialSkill( result, error )
    if error ~= 0 then
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onUpExclusiveLv( result, error )
    if error ~= 0 then return end
    -- dump(result)
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:onUpExclusiveStar( result, error )
    if error ~= 0 then return end
    -- dump(result)
    self:handAboutServerData(result)
    self:callback(result)
end

function TeamServer:handAboutServerData(result)
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

return TeamServer