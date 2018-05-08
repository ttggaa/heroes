--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-02-01 14:58:20
--

local AvatarFramesServer = class("AvatarFramesServer",BaseServer)

function AvatarFramesServer:ctor(data)
    AvatarFramesServer.super.ctor(self,data)
    self._avatarModel = self._modelMgr:getModel("AvatarModel")
end

function AvatarFramesServer:onGetAvatarFrameInfo( result, error)
	if error ~= 0 then 
		return
	end
	self._avatarModel:setFrameData(result)
	self:callback(result)
end 

function AvatarFramesServer:onSetAvatarFrame( result, error)
	if error ~= 0 then 
		return
	end
	self._modelMgr:getModel("UserModel"):updateUserData(result.d)
	self:callback(result)
end 

return AvatarFramesServer