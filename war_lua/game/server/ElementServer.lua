--[[
 	@FileName 	ElementServer.lua
	@Authors 	zhangtao
	@Date    	2017-08-14 15:48:50
	@Email    	<zhangtao@playcrad.com>
	@Description   描述
--]]

local ElementServer = class("ElementServer",BaseServer)

function ElementServer:ctor(data)
    ElementServer.super.ctor(self,data)
   	self._elementModel = self._modelMgr:getModel("ElementModel")
end
--扫荡
function ElementServer:onSweepElement(result, error)
	if error ~= 0 then 
		return
	end
	self:handAboutTeamServerData(result)
	self:callback(result,error)
end

function ElementServer:onGetElementFirstData(result,error)
	if error ~= 0 then 
		return
	end
	self._elementModel:setFirstOrderInfo(result)
	self:callback(result,error)
end

function ElementServer:onGetElementReport(result,error)
	if error ~= 0 then 
		return
	end
	self:callback(result,error)
end

function ElementServer:onAtkBeforeElement(result,error)
	if error ~= 0 then 
		return
	end
	self:callback(result,error)
end

function ElementServer:onAtkAfterElement(result,error)
	if error ~= 0 then 
		return
	end
	self:handAboutTeamServerData(result)
	self:callback(result,error)
end

function ElementServer:handAboutTeamServerData(result)
    if result == nil or result["d"] == nil then 
        return 
    end
    -- 物品数据处理要优先于怪兽
    local itemModel = self._modelMgr:getModel("ItemModel")
    itemModel:updateItems(result["d"]["items"], true)
    result["d"]["items"] = nil

    local userModel = self._modelMgr:getModel("UserModel")
    if result["d"] and result["d"]["element"] then
        self._elementModel:updateElementInfo(result["d"]["element"])
    end
    userModel:updateUserData(result["d"])
end

return ElementServer