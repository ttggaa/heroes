--[[
    Filename:    GuildRedServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-07 14:18:39
    Description: File description
--]]


local GuildRedServer = class("GuildRedServer", BaseServer)

function GuildRedServer:ctor(data)
    GuildRedServer.super.ctor(self)
    self._guildRedModel = self._modelMgr:getModel("GuildRedModel")
end

-- 获取工会红包
function GuildRedServer:onGetGuildRed(result, error)
    if error ~= 0 then 
        return
    end
    self._guildRedModel:setSysData(result)
    self:callback(result)
end

-- 抢工会红包
function GuildRedServer:onRobGuildRed(result, error)
    if error ~= 0 then 
        return
    end
    self._guildRedModel:updateSysRedData(result["data"])
    self:updateUserData(result)
    self:callback(result)
end

-- 获取玩家发送红包列表
function GuildRedServer:onGetGuildUserRed(result, error)
    if error ~= 0 then 
        return
    end
    self._guildRedModel:setRobList(result)
    self:callback(result)
end

-- 玩家发送红包
function GuildRedServer:onSendUserRed(result, error)
    if error ~= 0 then 
        return
    end
    self._modelMgr:getModel("GuildRedModel"):setRedSend(false)
    self:updateUserData(result)
    self:callback(result)
end

-- 玩家发送随机红包
function GuildRedServer:onSendRandomRed(result, error)
    if error ~= 0 then 
        return
    end
    dump(result)
    self:updateUserData(result)
    local itemModel = self._modelMgr:getModel("ItemModel")
    if result["unset"] ~= nil then 
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
    self:callback(result)
end

-- 玩家抢随机红包
function GuildRedServer:onRobRandomRed(result, error)
    if error ~= 0 then 
        return
    end
    dump(result)
    self:updateUserData(result)
    self:callback(result)
end


-- 抢工会玩家的红包
function GuildRedServer:onRobGuildUserRed(result, error)
    if error ~= 0 then 
        return
    end
    self._modelMgr:getModel("GuildRedModel"):setRedRob(false)
    self._guildRedModel:updateUserRedData(result["data"])
    self:updateUserData(result)
    self:callback(result)
end

-- 获取抢红包排行
function GuildRedServer:onGetGuildRedRobRank(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- 获取工会玩家发红包额度排行
function GuildRedServer:onGetGuildUserSendRedRank(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- 获取玩家抢红包历史排行
function GuildRedServer:onGetHistroyUserRobRank(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- 获取玩家发红包日志
function GuildRedServer:onGetSendLog(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- 获取玩家抢红包日志
function GuildRedServer:onGetRobLog(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- 获取推送红包数据  wangyan
function GuildRedServer:onRobGuildPlayerRed(result, error)
    -- if error ~= 0 then 
    --     return
    -- end

    -- dump(result, "123", 10)
    self._modelMgr:getModel("GuildRedModel"):updateRobMainRed(result)  
    self._modelMgr:getModel("GuildRedModel"):setUpdateRobList(false)
    for k,v in pairs(result) do
        local chatModel = self._modelMgr:getModel("ChatModel")
        local _, _, sendData = chatModel:paramHandle("log", {infoType = "GUILD_RED_BOX", infoName = v.name})
        if sendData ~= nil then
            chatModel:pushData(sendData)
        end
    end
end


-- 处理用户身上的数据
function GuildRedServer:updateUserData(result)
    dump(result)
    if result["d"] == nil then 
        return 
    end

    if result["d"]["items"] then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end
    if result.d.dayInfo then
        self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result["d"].dayInfo or {})
    end

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

-- function GuildRedServer:handAboutServerData(result)
--     if result == nil then 
--         return 
--     end
--     local userModel = self._modelMgr:getModel("UserModel")
--     userModel:updateUserData(result["d"])
-- end

return GuildRedServer