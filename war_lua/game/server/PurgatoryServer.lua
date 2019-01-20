--
-- Author: <wangguojun@playcrab.com>
-- Date: 2018-02-03 13:23:04
--

local PurgatoryServer = class("PurgatoryServer", BaseServer)

function PurgatoryServer:ctor(data)
    PurgatoryServer.super.ctor(self, data)
end

function PurgatoryServer:onGetPurInfo( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result)
	if result["d"] and result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end

	if result["d"] and result["d"]["purgatory"] ~= nil  then 
        local purModel = self._modelMgr:getModel('PurgatoryModel')
        purModel:setData(result["d"]["purgatory"], true)
        result["d"]["purgatory"] = nil
    end 
	self:callback(result)
end

function PurgatoryServer:onGetStageInfo( result, error)
	if error ~= 0 then 
		return
	end
	local purModel = self._modelMgr:getModel('PurgatoryModel')
	purModel:setStageInfos(result)
	self:callback(result)
end

function PurgatoryServer:onAtkBeforePurgatory( result, error)
	if error ~= 0 then 
		return
	end
	self:handleData(result)
	self:callback(result)
end

function PurgatoryServer:onAtkAfterPurgatory( result, error)
	if error ~= 0 then 
		return
	end
	self:handleData(result)
	self:callback(result)
end

function PurgatoryServer:onSkipStage( result, error )
	if error ~= 0 then
		return
	end
	dump(result, "onSkipStage=======")

	self:handleData(result)
	self:callback(result)
end

function PurgatoryServer:onSwitchBuff( result, error )
	if error ~= 0 then
		return
	end
	dump(result, "PurgatoryServer:switchBuff========")
	self:handleData(result)
	self:callback(result)
end

function PurgatoryServer:onGetStageReward( result, error )
	if error ~= 0 then
		return
	end
	dump(result, "==============PurgatoryServer:onGetStageReward:")
	self:handleData(result)
	self:callback(result)
end

function PurgatoryServer:onQuickSwitch( result, error )
	if error ~= 0 then
		return
	end
	dump(result, "=================PurgatoryServer:onQuickSwitch:")
	self:handleData(result)
	self:callback(result)
end

function PurgatoryServer:onGetAccStageReward( result, error )
	if error ~= 0 then
		return
	end
	dump(result, "PurgatoryServer:onGetAccStageReward=============")
	self:handleData(result)
	self:callback(result)
end

function PurgatoryServer:onGetPlatFriendInfo( result, error )
	if error ~= 0 then
		return
	end
	dump(result, "PurgatoryServer:onGetPlatFriendInfo")
	local purModel = self._modelMgr:getModel('PurgatoryModel')
    purModel:setFriendData(result["friendList"])
	self:callback(result)
end

function PurgatoryServer:handleData( result )
	if result == nil or result["d"] == nil then 
        return 
    end

    if result["d"] and result["d"]["purgatory"] ~= nil  then 
        local purModel = self._modelMgr:getModel('PurgatoryModel')
        purModel:setData(result["d"]["purgatory"], false)
        result["d"]["purgatory"] = nil
    end 

    if result["d"]["items"] ~= nil then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil 
    end

	local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])
end

return PurgatoryServer