--[[
 	@FileName 	MercenaryModel.lua
	@Authors 	zhangtao
	@Date    	2017-08-11 10:28:21
	@Email    	<zhangtao@playcrad.com>
	@Description   佣兵model
--]]

local MercenaryModel = class("MercenaryModel", BaseModel)

function MercenaryModel:ctor()
    MercenaryModel.super.ctor(self)
    self._data = {}
    self._guildModel = self._modelMgr:getModel("GuildModel")
end

function MercenaryModel:setData(data)
    self._data = data
    self:reflashData()
end

function MercenaryModel:getData()
    return self._data
end
--佣兵被使用推送
function MercenaryModel:needPushData(data)
	if not data then return end
	self._guildModel:needUpdateMercenaryInfo(data["pos"],data["sTimes"],data["sumUse"],function()
		self:reflashData(data["pos"])
	end)
	
end
return MercenaryModel	