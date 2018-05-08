--[[
    Filename:    BaseMvcs.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-28 11:59:45
    Description: File description
--]]

local BaseMvcs = class("BaseMvcs")

function BaseMvcs:ctor()
    self._viewMgr = ViewManager:getInstance()
    self._serverMgr = ServerManager:getInstance()
    self._modelMgr = ModelManager:getInstance()
    self._userDefault = UserDefault
end

function BaseMvcs:getClassName()
    return self.__filename
end

function BaseMvcs:setClassName(name)
    self.__filename = name
end

-- 本地存储
-- data可以是table也可以是值
function BaseMvcs:saveLocalData(key, data)
    self._userDefault:setStringForKey(self:getClassName() .. "_" .. key, serialize(data))
end

function BaseMvcs:loadLocalData(key)
    return unserialize(self._userDefault:getStringForKey(self:getClassName() .. "_" .. key, ""))
end

function BaseMvcs.dtor()
    BaseMvcs = nil
end

return BaseMvcs
