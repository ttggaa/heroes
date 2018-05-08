--[[
    Filename:    GameFriendServer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-26 17:57:51
    Description: File description
--]]

local GameFriendServer = class("GameFriendServer", BaseServer)

function GameFriendServer:ctor()
	GameFriendServer.super.ctor(self)
	self._friendModel = self._modelMgr:getModel("FriendModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._viewMgr = ViewManager:getInstance()
	require("game.view.friend.FriendConst")

end

function GameFriendServer:onGetPlatFriendList(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "platform", 10)	
	-- result = self:addPlatInfo()
	self._friendModel:updateDataByType(result, FriendConst.FRIEND_TYPE.PLATFORM)
	self:callback(result, error)
end

--平台假数据
function GameFriendServer:addPlatInfo()
	local data = {hadGet = 20, fList = {}}
	for i=1, 5 do
		data["fList"][i] = {
			rid = "1_2",
			name = "啦啦啦啦啦啦啦",
			rid =  "1_2",
            name = "鬼才欧文·邓",
            level = 4,
            vipLvl = 10,
            avatar = 1101,
            logoutTime = 1478335039,
            openid = "636BF1F9D35EBF9F8D3D0DCF4FEE5748",
            nickName = "啦啦啦啦啦啦啦啦啦啦啦",
            sex = 1,  --男 2女
           	picUrl = "https://q.qlogo.cn/qqapp/1105405983/636BF1F9D35EBF9F8D3D0DCF4FEE5748/100",
            maxlvl = 4,
            maxpvp = 0,
            maxstory = 0,
            secName = "点点滴滴",
            sendPhy = 0,  --0未发送 1已发送
            getPhy = 1,  --不可领  0 可领  >0已领取时间戳
            storyId = 7100201, --章节id
            loginTime = 1499248346,
            recallTime = 1499166746,
		}
	end
	return data
end

function GameFriendServer:onGetGameFriendList(result, error)
	if error ~= 0 then
		return
	end

	-- dump(result, "friend", 10)
	local arrowModel = self._modelMgr:getModel("ArrowModel")
	if arrowModel:getIsRankView() == true then
		arrowModel:setRankDataByType(result["d"], "friend")
		self:callback(result, error)
		return
	end

	self._friendModel:updateDataByType(result, FriendConst.FRIEND_TYPE.FRIEND)
	self:callback(result, error)
end

function GameFriendServer:onGetApplyList(result, error)
	if error ~= 0 then
		return
	end
	
	-- dump(result, "add", 10)
	self._friendModel:updateDataByType(result, FriendConst.FRIEND_TYPE.ADD)
	self:callback(result, error)
end

function GameFriendServer:onRecommendGameFriend(result, error)
	if error ~= 0 then  
		return
	end

	-- dump(result, "apply", 10)
	self._friendModel:updateDataByType(result, FriendConst.FRIEND_TYPE.APPLY)
	self:callback(result, error)
end

function GameFriendServer:onGetRecallData(result, error)
	if error ~= 0 then  
		return
	end
	
	self._userModel:updateUserData(result)
	self:callback(result, error)
end

--平台好友
function GameFriendServer:onGetPlatPhy(result, error)     --get
	if not result["code"] or result["code"] == 1 then
		return
	end

	if result["type"] == 1 then   --单个
		if error ~= 0 then
			if error == 3413 then
				self._friendModel:setPhyUperPlat(-1)
			end
			return
		end

		self:callback(result, error)

	elseif result["type"] == 2 then  --一键
		if error ~= 0 then
			if error == 3413 then
				self._friendModel:setPhyUperPlat(-1)
				self._friendModel:quickGet(nil, FriendConst.FRIEND_TYPE.PLATFORM)
				self:callback(result, error)
			elseif error == 252 then
				self:callback(result, error)
			end
			return
		end
		self._friendModel:quickGet(nil, FriendConst.FRIEND_TYPE.PLATFORM)
		self:callback(result, error)
	end
end

function GameFriendServer:onSendPlatPhy(result, error)    --send
	if not result["code"] or result["code"] == 1 then
		return
	end

	if result["type"] == 1 then
		if error ~= 0 then
			return
		end

		self:callback(result, error)

	elseif result["type"] == 2 then
		if error ~= 0 then
			return
		end

		self._friendModel:quickSend(FriendConst.FRIEND_TYPE.PLATFORM)
		self:callback(result, error)
	end
end 

function GameFriendServer:onSendRecall(result, error)
	-- dump(result, error)
	if error ~= 0 then
		return
	end

	self:handleAboutServerData(result)
	self:callback(result, error)
end

--游戏好友
function GameFriendServer:onGetSendPhysical(result, error)   --get
	if error ~= 0 then
		if error == 3413 then
			self._friendModel:setPhysicalUper(-1)
		end
		return
	end

	self:callback(result, error)
end

function GameFriendServer:onSendPhysical(result, error) 	--send
	if error ~= 0 then
		return
	end

	self:callback(result, error)
end 

function GameFriendServer:onOnekeyGetPhysical(result, error)  --onekey get
	if error ~= 0 then
		if error == 3413 then
			self._friendModel:setPhysicalUper(-1)
			self._friendModel:quickGet()
			self:callback(result, error)
		elseif error == 252 then
			self:callback(result, error)
		end
		return
	end
	-- self._friendModel:quickGet(result["d"])

	self._friendModel:quickGet()
	self:callback(result, error)
end

function GameFriendServer:onOnekeySendPhysical(result, error)   --onekey send
	if error ~= 0 then
		return
	end

	self._friendModel:quickSend()
	self:callback(result, error)
end

function GameFriendServer:onDeleteGameFriend(result, error)
	if error ~= 0 then
		return
	end

	self._friendModel:deleteFriend()
	self:callback(result, error)  
end 

--申请
function GameFriendServer:onAcceptGameFriend(result, error)
	if error ~= 0 then
		return
	end

	-- 更新元素庆典好友数据 hgf
	if result["d"] and result["d"]["celebrity"] then
		local celebrationModel = self._modelMgr:getModel("CelebrationModel")
        celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end
	self:callback(error, result)
end

function GameFriendServer:onOnekeyAcceptGameFriend(result, error)
	if error ~= 0 then
		return
	end

	self:callback(error,result)
end

--添加
function GameFriendServer:onApplyGameFriend(result, error)
	if error ~= 0 then
		return
	end

	self:callback(result, error)
end

function GameFriendServer:onOnekeyApplyGameFriend(result, error)
	if error ~= 0 then
		return
	end
	self:callback(result, error)
end

function GameFriendServer:onSearchGameFriend(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result)
	self._friendModel:addSearchFriendToApplyList(result)
	self:callback(result, error)
end

--玩家信息
function GameFriendServer:onGetFriendInfo(result, error)
	if error ~= 0 then
		return
	end
	self:callback(result, error)
end

--黑名单
function GameFriendServer:onGetBlackList(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result, "black", 10)
	self._friendModel:updateDataByType(result, FriendConst.FRIEND_TYPE.BLACK)
	self:callback(result, error)
end

function GameFriendServer:onAddBlackList(result, error)
	if error ~= 0 then
		return
	end
	self:callback(result, error)
end

function GameFriendServer:onRemoveBlackList(result, error)
	if error ~= 0 then
		return
	end
	self:callback(result, error)
end

--推送 好友送体力
function GameFriendServer:onPushSendPhysical(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result)
	self._friendModel:insertSendPhysical(result)
end

--推送 好友申请  1
function GameFriendServer:onPushFriendApply(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result)
	self._friendModel:insertFriendApply(result)
end

--推送 删除好友 1
function GameFriendServer:onPushDeleteFriend(result, error)
	if error ~= 0 then
		return
	end
	-- dump(result)
	self._friendModel:insertDeleteFriend(result)
end

--推送 好友同意申请  1
function GameFriendServer:onPushFriendAgreeApply(result, error)
	if error ~= 0 then
		return
	end
	
	-- 更新元素庆典好友数据 hgf
	if result["d"] and result["d"]["celebrity"] then
		local celebrationModel = self._modelMgr:getModel("CelebrationModel")
        celebrationModel:updateData(result["d"]["celebrity"])
        result["d"]["celebrity"] = nil
    end
	-- dump(result)
	self._friendModel:insertAgreeApply(result)
end

function GameFriendServer:onGetMFList(result, error)
	if error ~= 0 then
		return
	end
	
	self:callback(result)
end

function GameFriendServer:onCompete(result, error)
	if error ~= 0 then
		return
	end
	
	self:callback(result)
end
function GameFriendServer:onPlatCompete(result, error)
	if error ~= 0 then
		return
	end
	
	self:callback(result)
end

function GameFriendServer:handleAboutServerData(result)
    if result == nil or result["d"] == nil then 
        return
    end

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"] and result["d"]["dayInfo"] then
    	local playerTodataModel = self._modelMgr:getModel("PlayerTodayModel")
        playerTodataModel:updateDayInfo(result["d"]["dayInfo"])
        result["d"]["dayInfo"] = nil
    end

    -- 更新用户数据
    self._userModel:updateUserData(result["d"])
end

return GameFriendServer