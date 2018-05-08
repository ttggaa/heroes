--[[
 	@FileName 	MercenaryServer.lua
	@Authors 	zhangtao
	@Date    	2017-08-11 10:25:15
	@Email    	<zhangtao@playcrad.com>
	@Description   佣兵Server
--]]

local  MercenaryServer = class("MercenaryServer",BaseServer)

function MercenaryServer:ctor(data)
    MercenaryServer.super.ctor(self,data)
    self._mercenaryModel = self._modelMgr:getModel("MercenaryModel")
end

function MercenaryServer:onNeedUpdate(result, error)
	if error ~= 0 then
		return
	end
	self._mercenaryModel:needPushData(result)
end

return MercenaryServer