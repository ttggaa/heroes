--[[
    Filename:    PokedexServer.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-09-28 14:54:43
    Description: File description
--]]

local PokedexServer = class("PokedexServer", BaseServer)

function PokedexServer:ctor(data)
    PokedexServer.super.ctor(self)
    self._pokedexModel = self._modelMgr:getModel("PokedexModel")
end

-- function PokedexServer:onGetPokedex(result, error)
--     --dump(result, "PokedexServer:onGetTask")
--     self._taskModel:setData(result)
--     self:callback(0 == tonumber(error))
-- end

-- function PokedexServer:onPokedexReward(result, error)
--     --dump(0, result, "PokedexServer:onMainTaskReward")
--     self._taskModel:updateMainTaskData(result, 0 == tonumber(error))
--     self:callback(0 == tonumber(error))
-- end

function PokedexServer:onUpPokedexLevel(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:handAboutServerData(result)
    self:callback(result)
end

function PokedexServer:onPutTeamOnPokedexPos(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:handAboutServerData(result)
    self:callback(result)
end

function PokedexServer:onPutOffTeamOnPokedexPos(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:handAboutServerData(result)
    self:callback(result)
end

function PokedexServer:onActivePokedexPos(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    self:handAboutServerData(result)
    self:callback(result)
end

function PokedexServer:onGetPokedexInfo(result, error)
    if error ~= 0 then 
        return
    end
    self._pokedexModel:setData(result["d"])
    self:callback(result)
end

-- 获取图鉴编组数据
function PokedexServer:onGetPFormation(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result)
    -- self:handAboutServerData(result)
    self._pokedexModel:setPFormation(result)
    self:callback(result)
end

-- 开启编组
function PokedexServer:onOpenPFormation(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"]["pFormation"] ~= nil then 
        local pokedexModel = self._modelMgr:getModel("PokedexModel")
        pokedexModel:updatePFormation(result["d"]["pFormation"])
        result["d"]["pFormation"] = nil
    end
    self:handAboutServerData(result)
    self:callback(result)
end

-- 改名
function PokedexServer:onChangePFormationName(result, error)
    if error ~= 0 then 
        return
    end
    if result["d"]["pFormation"] ~= nil then 
        local pokedexModel = self._modelMgr:getModel("PokedexModel")
        pokedexModel:updatePFormation(result["d"]["pFormation"])
        result["d"]["pFormation"] = nil
    end
    self:callback(result)
end

-- 使用图鉴编组
function PokedexServer:onChangePFormation(result, error)
    if error ~= 0 then 
        return
    end
    
    self:handAboutServerData(result)
    self:callback(result)
end

function PokedexServer:handAboutServerData(result)
    -- dump(result, "result ==========", 20)
    if result == nil then 
        return 
    end

   -- -- 物品数据处理要优先于怪兽
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
        result["d"]["formations"] = nil
    end

    if result["d"]["teamPokedex"] ~= nil  then
        self._modelMgr:getModel("PokedexModel"):updateData(result["d"]["teamPokedex"])
    end

    if result["d"]["pokedex"] ~= nil  then
        self._modelMgr:getModel("PokedexModel"):updatePokedexData(result["d"]["pokedex"])
        result["d"]["pokedex"] = nil
    end

    self._modelMgr:getModel("ActivityModel"):pushUserEvent()

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return PokedexServer