--[[
    Filename:    BaseServer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-27 17:37:59
    Description: File description
--]]

local BaseServer = class("BaseServer", BaseMvcs)

-- 请注意, 每一次的请求都会new一个新的BaseServer
-- 所以在BaseServer添加的变量self._data, 只会在ctor和onResponse里面有效, 并不会保存
function BaseServer:ctor(data)
    BaseServer.super.ctor(self)
    self.__callback = nil
    self._data = data
    self.__lockView = nil
end

function BaseServer:lockView(lock)
    self.__lockView = lock
    if self.__lockView then
        self._viewMgr:lock(1000)
    end
end

function BaseServer:unlockView()
    if self.__lockView then
        ScheduleMgr:delayCall(0, self, function()
            self._viewMgr:unlock(31)
        end)
    end
end

function BaseServer:setCallback(callback)
    self.__callback = callback
end

function BaseServer:setErrorCallback(callback)
    self.__errorCallback = callback
end

function BaseServer:setTimeOutCallback(callback)
    self.__timeoutCallback = callback
end

function BaseServer:callback(...)
    self._serverMgr:onGlobalCallback()
    if self.__callback then
        self.__callback(...)
    end
end

function BaseServer:errorCallback(...)
    self._serverMgr:onGlobalCallback()
    if self.__errorCallback then
        self.__errorCallback(...)
    end
end

function BaseServer:timeOutCallback()
    if self.__timeoutCallback then
        self.__timeoutCallback()
    end
end

-- 为添加 onXxxx的方法统一回调到这里, 如有需要请覆盖
function BaseServer:onResponse(result, error)

end

-- 没有传到服务器的请求会统一调用onError用于解锁界面
function BaseServer:onError()
    self._viewMgr:onError()
end

function BaseServer.dtor()
    BaseServer = nil
end

return BaseServer