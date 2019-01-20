--[[
 	@FileName 	BattleArrayServer.lua
	@Authors 	yuxiaojing
	@Date    	2018-07-19 15:29:51
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BattleArrayServer = class("BattleArrayServer", BaseServer)

function BattleArrayServer:ctor( data )
	BattleArrayServer.super.ctor(self, data)
	self._battleArrayModel = self._modelMgr:getModel('BattleArrayModel')
end

-- 阵图数据初始化
--[[

	battleArray.getInfo

]]
function BattleArrayServer:onGetInfo( result, error )
	if error ~= 0 then
		return
	end

	if result["d"] and result["d"]["battleArray"] ~= nil then
		self._battleArrayModel:setBattleArrayData(result["d"]["battleArray"])
		result["d"]["battleArray"] = nil
	end
	self:callback(result)
end

-- 阵图激活
--[[

	battleArray.active
     * @internal bid 阵营ID @param
     * @internal mid 阵图ID @param

]]
function BattleArrayServer:onActive( result, error )
	if error ~= 0 then
		return
	end

	-- dump(result)
	if result["d"] and result["d"]["battleArray"] ~= nil then
		self._battleArrayModel:updateData(result["d"]["battleArray"])
		result["d"]["battleArray"] = nil
	end
	self:handleData(result)
	self:callback(result)
end

-- 阵图突破
--[[

	battleArray.upgrade
     * @internal bid 阵营ID @param
]]
function BattleArrayServer:onUpgrade( result, error )
	if error ~= 0 then
		return
	end

	-- dump(result)
	if result["d"] and result["d"]["battleArray"] ~= nil then
		self._battleArrayModel:updateData(result["d"]["battleArray"])
		result["d"]["battleArray"] = nil
	end
	self:handleData(result)
	self:callback(result)
end

-- 阵图重置
--[[

	battleArray.reset
     * @internal bid 阵营ID @param
]]
function BattleArrayServer:onReset( result, error )
	if error ~= 0 then
		return
	end

	-- dump(result)
	if result["d"] and result["d"]["battleArray"] ~= nil then
		self._battleArrayModel:updateData(result["d"]["battleArray"])
		result["d"]["battleArray"] = nil
	end
	self:handleData(result)
	self:callback(result)
end

function BattleArrayServer:handleData( result )
	if result == nil or result["d"] == nil then
		return
	end

	if result["d"]["formations"] ~= nil then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        result["d"]["formations"] = nil
    end

    if result["d"]["teams"] ~= nil  then 
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end

	local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateUserData(result["d"])

    if result["d"] and result["d"]["items"] then
	    local itemModel = self._modelMgr:getModel("ItemModel")
	    itemModel:updateItems(result["d"]["items"], true)
	    result["d"]["items"] = nil
	end

	if result["unset"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        local removeItems = itemModel:handelUnsetItems(result["unset"])
        itemModel:delItems(removeItems, true)
    end
end

return BattleArrayServer