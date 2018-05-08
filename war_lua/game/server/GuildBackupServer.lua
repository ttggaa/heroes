--[[
    Filename:    GuildBackupServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-05-30 12:16:41
    Description: File description
--]]

local GuildBackupServer = class("GuildBackupServer", BaseServer)

function GuildBackupServer:ctor(data)
    GuildBackupServer.super.ctor(self)
    self._guildModel = self._modelMgr:getModel("GuildModel")
end

-- 获取联盟增援列表
function GuildBackupServer:onGetNeedBackupList(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result, "result===")
    self:callback(result)
end

-- 请求增援
function GuildBackupServer:onNeedBackup(result, error)
    if error ~= 0 then 
        return
    end
    self:updateUserData(result)
    self:callback(result)
end

-- 撤销请求增援
function GuildBackupServer:onCancleNeedbackup(result, error)
    if error ~= 0 then 
        return
    end
    self:updateUserData(result)
    self:callback(result)
end

-- 捐赠
function GuildBackupServer:onDonate(result, error)
    if error ~= 0 then 
        return
    end
    self:updateUserData(result)
    self:callback(result)
end

-- 处理用户身上的数据
function GuildBackupServer:updateUserData(result)
    dump(result)
    if result == nil then 
        return 
    end

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

    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

-- 请求增援列表更新
function GuildBackupServer:onAddGuildBackup(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end
-- 移除增援列表数据
function GuildBackupServer:onRemoveGuildBackup(result, error)
    if error ~= 0 then 
        return
    end
    self:callback(result)
end


return GuildBackupServer