--[[
    Filename:    BaseModel.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-27 17:37:39
    Description: File description
--]]

-- 正常情况下, 其他model, view, server无法直接获取到Model的实例, 只能通过manager操作
local BaseModel = class("BaseModel", BaseMvcs)

function BaseModel:ctor()
    BaseModel.super.ctor(self)
    self._data = {}

    self.__listeners = {}
    self.__eventTarget = {}
    self.__lock = false
end

function BaseModel:destroy()
    self._modelMgr:clearSelfTimer(self)
    self._data = nil
    self:removeGlobalResponseListener()
    self:removeGlobalResponseListenerAfter()
    self:removeRSResponseListener()
end

function BaseModel:clear()
    self._data = {}
end

function BaseModel:getData()
    return self._data
end

function BaseModel:checkData()

end
 
-- 子类覆盖此方法来存储数据
function BaseModel:setData(data)
    self._data = data
    self:reflashData()
end

function BaseModel:isEmpty()
    return (next(self._data) == nil)
end

-- 监听数据刷新
function BaseModel:addReflashListener(baseMvcs)
    self.__listeners[baseMvcs] = true
end

function BaseModel:removeReflashListener(baseMvcs)
    self.__listeners[baseMvcs] = nil
end

-- 发送事件刷新的事件
function BaseModel:reflashData(data)
    self:dispatchReflashEvent(data)
    pcall(function () self:patch() end)
end

function BaseModel:patch()

end

function BaseModel:dispatchReflashEvent(data)
    local modelName = self:getClassName()
    for baseMvcs, _ in pairs(self.__listeners) do
        baseMvcs:dispatchReflash(modelName, data)
    end
end

-- 新增model监听
function BaseModel:listenReflash(modelname, callback)
    self._modelMgr:listenModelReflash(modelname, self)
    self.__eventTarget[modelname] = specialize(callback, self)
end

function BaseModel:dispatchReflash(modelname, data)
    -- 避免重复调用
    if self.__lock then return end
    self.__lock = true
    self.__eventTarget[modelname](data)
    self.__lock = false
end

--全局监听，在分发事件之前处理，注意：在同一个model中，仅支持监听一个方法
function BaseModel:listenGlobalResponse(callback)
    self._hasGlobalListener = true
    self._serverMgr:listenGlobalResponse(self, callback)
end

function BaseModel:removeGlobalResponseListener()
    if self._hasGlobalListener then
        self._hasGlobalListener = false
        self._serverMgr:removeGlobalResponseListener(self)
    end
end

--全局监听，在分发事件之后处理，注意：在同一个model中，仅支持监听一个方法
function BaseModel:listenGlobalResponseAfter(callback)
    self._hasGlobalListenerAfter = true
    self._serverMgr:listenGlobalResponseAfter(self, callback)
end

function BaseModel:removeGlobalResponseListenerAfter()
    if self._hasGlobalListenerAfter then
        self._hasGlobalListenerAfter = false
        self._serverMgr:removeGlobalResponseListenerAfter(self)
    end
end

-- 监听来自java服务器的请求
function BaseModel:listenRSResponse(callback)
    self._hasRSListener = true
    self._serverMgr:listenRSResponse(self, callback)
end

function BaseModel:removeRSResponseListener()
    if self._hasRSListener then
        self._hasRSListener = false
        self._serverMgr:removeRSResponseListener(self)
    end
end

function BaseModel:registerTimer(hour, min, sec, callback)
    self._modelMgr:registerTimer(hour, min, sec, self, callback)
end

function BaseModel.dtor()
    BaseModel = nil
end

return BaseModel