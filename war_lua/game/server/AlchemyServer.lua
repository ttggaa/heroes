local AlchemyServer = class("AlchemyServer", BaseServer)

function AlchemyServer:ctor(data)
	AlchemyServer.super.ctor( self, data )
	self._alchemyModel = self._modelMgr:getModel("AlchemyModel")
end

function AlchemyServer:onGetInfo(result, error)
	if error ~= 0 then
		return
	end
	if result and result.d and result.d.alchemyH then
		self._alchemyModel:setData(result.d.alchemyH)
	end
	self:callback(result)
end

function AlchemyServer:onUnlock(result, error)
	if error~=0 then
		return
	end
	self:handleAboutServerData(result)
	self:callback(result)
end

function AlchemyServer:onRefresh(result, error)
	if error~=0 then return end
	self:handleAboutServerData(result)
	self:callback(result)
end

function AlchemyServer:onProduce(result, error)
	if error~=0 then
--		self:errorCallback()
		return
	end
	self:handleAboutServerData(result)
	self:callback(result)
end

function AlchemyServer:onChange(result, error)
	if error~=0 then return end
	self:handleAboutServerData(result)
	self:callback(result)
end

function AlchemyServer:onGetTool(result, error)
	if error~=0 then return end
	self:handleAboutServerData(result)
	self:callback(result)
end

function AlchemyServer:onGetReport(result, error)
	if error~=0 then return end
	self:handleAboutServerData(result)
	self:callback()
end

function AlchemyServer:onSpeedup(result, error)
	if error~=0 then return end
	self:handleAboutServerData(result)
	self:callback(result)
end

function AlchemyServer:onAlchemy(result, error)
	if error~=0 then return end
	self:handleAboutServerData(result)
	self:callback(result)
end

function AlchemyServer:handleAboutServerData(result, reflash)
	if result == nil then
		return 
	end
	if reflash == nil then 
		reflash = false
	end

	if result["d"] == nil then 
		return
	end
	
	if result["d"]["items"] ~= nil then 
		local itemModel = self._modelMgr:getModel("ItemModel")
		itemModel:updateItems(result["d"]["items"])
		result["d"]["items"] = nil
	end

	if result["d"]["battleArray"] ~= nil then
		local baModel = self._modelMgr:getModel("BattleArrayModel")
		baModel:updateSoul(result["d"]["battleArray"])
		result["d"]["battleArray"] = nil
	end
	
	if result["d"]["alchemyH"] ~= nil then 
		self._alchemyModel:updateAlchemyData(result["d"]["alchemyH"])
		result["d"]["alchemyH"] = nil
	end
	if result["d"] ~= nil then 
		local userModel = self._modelMgr:getModel("UserModel")
		userModel:updateUserData(result.d)
	end
	
	
	if result["unset"] ~= nil then 
        local tempK = ""
        for k,v in pairs(result["unset"]) do
            local tempList = string.split(k, "%.")
            if tempList[1] == "guildRoleMapList" then 
                tempK = k
                break
            end
        end
        if tempK ~= "" then 
            result["unset"][tempK] = nil
        end
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
end

return AlchemyServer
