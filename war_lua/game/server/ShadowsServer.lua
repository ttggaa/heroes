--[[
 	@FileName 	ShadowsServer.lua
	@Authors 	zhangtao
	@Date    	2018-05-11 10:44:03
	@Email    	<zhangtao@playcrad.com>
	@Description   描述
--]]

local ShadowsServer = class("ShadowsServer",BaseServer)

function ShadowsServer:ctor(data)
    ShadowsServer.super.ctor(self,data)
    self._shadowsModel = self._modelMgr:getModel("ShadowsModel")
end

function ShadowsServer:onGetShadowsInfo( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"======onGetShadowsInfo======")
	self._shadowsModel:setData(result)
	self:callback(result)
end

function ShadowsServer:onSetShadow( result, error)
	dump(result,"======onSetShadow======")
	if error ~= 0 then 
		return
	end
	local shadowId = ""
	if result["d"]["shadow"] then
		shadowId = result["d"]["shadow"]
	end
	self._shadowsModel:setSelectedShadowId(shadowId)
	self:callback(result)
end

return ShadowsServer