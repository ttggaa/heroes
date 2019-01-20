--[[
 	@FileName 	ShadowsModel.lua
	@Authors 	zhangtao
	@Date    	2018-05-11 10:38:23
	@Email    	<zhangtao@playcrad.com>
	@Description   描述
--]]
local ShadowsModel = class("ShadowsModel", BaseModel)

function ShadowsModel:ctor()
    ShadowsModel.super.ctor(self)
    self._data = {}
end

function ShadowsModel:setData(data)
    self._data = data
    self:reflashData()
end

function ShadowsModel:getData()
    return self._data
end

function ShadowsModel:getShadowsFrame()
	return self._data["shadows"] or nil
end

function ShadowsModel:setSelectedShadowId(shadowId)
	if not shadowId then return end
	self._data.shadow = shadowId
end

function ShadowsModel:getSelectedShadowId()
	if self._data.shadow and string.len(tostring(self._data.shadow)) > 0 then
		return self._data.shadow
	end
	return nil
end

return ShadowsModel