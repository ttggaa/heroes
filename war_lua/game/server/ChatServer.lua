--[[
    Filename:    ChatServer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-10 11:43:51
    Description: File description
--]]

local ChatServer = class("ChatServer", BaseServer)

function ChatServer:ctor()
	ChatServer.super.ctor(self,data)
	self._chatModel = self._modelMgr:getModel("ChatModel")
	self._userModel = self._modelMgr:getModel("UserModel")
end


function ChatServer:onSendMessage(result, error)
	-- print("sendMessage=======",error, result)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
	self:callback(result)
end

function ChatServer:onSendPriMessage(result, error)
	-- print("onSendPriMessage=======",error, result)
	if error ~= 0 then
		return
	end
	self:callback(result)
end

function ChatServer:onPushMessage(result, error)
	-- print("pushMessage=======",error, result)
	if error ~= 0 then
		return
	end
	self._chatModel:pushData(result)
end

function ChatServer:onDelPriMessage(result, error)
	-- print("sendMessage=======",error, result)
	if error ~= 0 then
		return
	end
	self:callback(result)
end

function ChatServer:onGetMessage(result, error)
	-- dump(result, "chatGetMessage", 10)
	if error ~= 0 then
		return
	end  
	self._chatModel:checkUnloginData(result)   --未在线未读
	self:callback(result)
end

function ChatServer:onGetMixedMessage(result, error)
	if error ~= 0 then
		return
	end
	self:callback(result)
end

function ChatServer:onPushIdipBanned(result, error)
	-- print("onPushIdipBanned=======",error, result)
	if error ~= 0 then
		return
	end
	-- dump(result, "onPushIdipBanned", 10)
	if result ~= nil and result["d"] ~= nil then 
    	self._modelMgr:getModel("UserModel"):updateUserData(result["d"])
    end
end

function ChatServer:onBanUserChat(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "omBanUserChat", 10)
	if result ~= nil and result["d"] ~= nil then 
    	self._modelMgr:getModel("UserModel"):updateUserData(result["d"])
    end
    self:callback(result)
end

function ChatServer:onPushIdipClear(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "123", 10)
	for i=1,#result do
		self._chatModel:removeBlackChatUser(result[i], false, true, true)
	end
end

function ChatServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result._carry_ and result._carry_.task then
    	self._modelMgr:getModel("TaskModel"):onChangeTask(result)
    	result._carry_.task = nil
    end    

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])
end


return ChatServer