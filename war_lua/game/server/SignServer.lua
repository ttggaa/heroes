--[[
    Filename:    SignServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-03-22 18:35:06
    Description: File description
--]]

local SignServer = class("SignServer", BaseServer)

function SignServer:ctor(data)
    SignServer.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._signModel = self._modelMgr:getModel("SignModel")
end

function SignServer:onSign(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end

function SignServer:onGetTotalSignReward(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end


function SignServer:onGetSignInfo(result, error)
    if error ~= 0 then 
        return
    end
    self._signModel:setData(result)
    -- dump(result)
    self:callback(result)
end

function SignServer:onReplenishSign(result, error)
    if error ~= 0 then 
        return
    end
    self:handAboutServerData(result)
    self:callback(result)
end



function SignServer:handAboutServerData(result)
    -- dump(result,"result ============")
    if result == nil then 
        return 
    end

   -- -- 物品数据处理要优先于怪兽
    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"], true)
        result["d"]["items"] = nil 
    end

    -- if result["unset"] ~= nil then 
    --     local itemModel = self._modelMgr:getModel("ItemModel")
    --     local removeItems = itemModel:handelUnsetItems(result["unset"])
    --     itemModel:delItems(removeItems, true)
    -- end

    if result["d"]["teams"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end 


    if result["d"]["heros"] ~= nil  then 

        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(result["d"]["heros"])
        result["d"]["heros"] = nil
    end 

    if result["d"]["sign"] ~= nil  then 
        local signModel = self._modelMgr:getModel("SignModel")
        signModel:updateData(result["d"]["sign"])
        result["d"]["sign"] = nil
    end  
    -- if result["d"]["hero"] ~= nil  then 
    --     local teamModel = self._modelMgr:getModel("TeamModel")
    --     teamModel:updateTeamData(result["d"]["teams"])
    --     result["d"]["teams"] = nil
    -- end 

    -- if result["d"]["teams"] ~= nil  then 
    --     local teamModel = self._modelMgr:getModel("TeamModel")
    --     teamModel:updateTeamData(result["d"]["teams"])
    --     result["d"]["teams"] = nil
    -- end 

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return SignServer