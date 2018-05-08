--[[
    Filename:    AwakingServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-08-11 17:11:28
    Description: File description
--]]


local AwakingServer = class("AwakingServer", BaseServer)

function AwakingServer:ctor(data)
    AwakingServer.super.ctor(self,data)
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._awakingModel = self._modelMgr:getModel("AwakingModel")

end

function AwakingServer:onOpenAwakingTask(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end


function AwakingServer:onAwakingActivate(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 保存觉醒树
function AwakingServer:onSaveAwakingTree(result, error)
    -- dump("debug",result,"AwakingServer:upgradeTeam")
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 觉醒升级
function AwakingServer:onUpAwakingLevel(result, error)
    -- dump("debug",result,"AwakingServer:upgradeTeam")
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 完成觉醒任务
function AwakingServer:onFinishAwakingTask(result, error)
    if tonumber(error) ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(0 == tonumber(error), result)
end

-- 放弃觉醒任务
function AwakingServer:onAbandonAwakingTask(result, error)
    if tonumber(error) ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(0 == tonumber(error), result)
end

function AwakingServer:handAboutServerData(result)
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

    if result["d"]["awaking"] ~= nil then
        self._awakingModel:updateAwakingTaskData(result["d"]["awaking"])
        result["d"]["awaking"] = nil
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

return AwakingServer