--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-04-14 10:22:05
--

local AvatarsServer = class("AvatarsServer",BaseServer)

function AvatarsServer:ctor(data)
    AvatarsServer.super.ctor(self,data)
    self._avatarModel = self._modelMgr:getModel("AvatarModel")
end

function AvatarsServer:onGetAvatarInfo( result, error)
	if error ~= 0 then 
		return
	end
	self._avatarModel:setData(result)
	self:callback(result)
end 

function AvatarsServer:onSetAvatar( result, error)
	if error ~= 0 then 
		return
	end
	self._modelMgr:getModel("UserModel"):updateUserData(result.d)
	self:callback(result)
end 

return AvatarsServer