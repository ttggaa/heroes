--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-07-26 19:08:36
--
local GlobalServer = class("GlobalServer",BaseServer)

function GlobalServer:ctor(data)
    GlobalServer.super.ctor(self,data)
    self._globalModel = self._modelMgr:getModel("GlobalModel")
end

function GlobalServer:onGetAll(result, error)
	self._globalModel:setData(result)
	self:callback()
end

return GlobalServer