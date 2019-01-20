--[[
 	@FileName 	BackupServer.lua
	@Authors 	yuxiaojing
	@Date    	2018-04-17 17:18:45
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BackupServer = class("BackupServer", BaseServer)

function BackupServer:ctor( data )
	BackupServer.super.ctor(self, data)
	self._backupModel = self._modelMgr:getModel('BackupModel')
end

function BackupServer:onGetBackupInfo( result, error )
	if result["d"]	and result["d"]["backups"] ~= nil then
		self._backupModel:updateData(result["d"]["backups"])
		result["d"]["backups"] = nil
	end
	-- self:handleData(result)
	self:callback(result)
end

--解锁
--[[

	backup.unlock
	@internal bid 后援ID @param

]]
function BackupServer:onUnlock( result, error )
	if error ~= 0 then
		return
	end

	dump(result)
	if result["d"]	and result["d"]["backups"] ~= nil then
		self._backupModel:updateData(result["d"]["backups"])
		result["d"]["backups"] = nil
	end
	self:handleData(result)

	self:callback(result)
end

-- 升级
--[[

	backup.upgrade
     * @internal bid 后援ID @param
     * @inerrnal mode 模式(0.升一级&nbsp1.升五级) @param   0可不传

]]
function BackupServer:onUpgrade( result, error )
	if error ~= 0 then
		return
	end

	dump(result)
	if result["d"]	and result["d"]["backups"] ~= nil then
		self._backupModel:updateData(result["d"]["backups"])
		result["d"]["backups"] = nil
	end
	self:handleData(result)
	self:callback(result)
end

-- 技能升级
--[[

	backup.skillUpgrade
     * @internal bid 后援ID @param
     * @internal sidx 技能索引 @param

]]
function BackupServer:onSkillUpgrade( result, error )
	if error ~= 0 then
		return
	end

	dump(result)
	if result["d"]	and result["d"]["backups"] ~= nil then
		self._backupModel:updateData(result["d"]["backups"])
		result["d"]["backups"] = nil
	end
	self:handleData(result)
	self:callback(result)
end

function BackupServer:handleData( result )
	if result == nil or result["d"] == nil then
		return
	end

	local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])

    if result["d"] and result["d"]["items"] then
	    local itemModel = self._modelMgr:getModel("ItemModel")
	    itemModel:updateItems(result["d"]["items"], true)
	    result["d"]["items"] = nil
	end

	if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
end

return BackupServer