--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-04-14 10:27:54
--
local AvatarModel = class("AvatarModel", BaseModel)

function AvatarModel:ctor()
    AvatarModel.super.ctor(self)
    self._data = {}
    self._frameData = {}
    self._guildAvatar = {}
end

function AvatarModel:setData(data)
    self._data = data
    self:reflashData()
end

function AvatarModel:getData()
    return self._data
end

function AvatarModel:setFrameData( data )
    self._frameData = data
    self:reflashData()
end

function AvatarModel:getFrameData()
    return self._frameData
end

function AvatarModel:updateAvatarData(data)
	if not data then return end
	for k,v in pairs(data) do		
		self._data[k] = v
	end
end

function AvatarModel:setGuildAvatar(data)
    self._guildAvatar = data
    self:reflashData()
end

function AvatarModel:getGuildAvatar()
    return self._guildAvatar
end
return AvatarModel