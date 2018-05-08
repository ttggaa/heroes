--[[
    Filename:    ArenaServer.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-09-23 10:54:14
    Description: File description
--]]


local ArenaServer = class("ArenaServer",BaseServer)

function ArenaServer:ctor(data)
    ArenaServer.super.ctor(self,data)
    self._arenaModel = self._modelMgr:getModel("ArenaModel")
end

function ArenaServer:onEnterArena( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result)
	self._arenaModel:setData(result)
	self:callback(result)
end

function ArenaServer:onGetRank( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result)
	self._arenaModel:setArenaRank(result)
	self:callback(result)
end

function ArenaServer:onChangeStatus( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result)
	local arena = result.d.arena
	self._arenaModel:updateArena(arena)
	self:callback(result)
end

function ArenaServer:onReflashArena( result, error)
	if error ~= 0 then 
		return
	end
	self._arenaModel:reflashEnemys(result.enemys)
	self:callback(result)
end

function ArenaServer:onBuyChallengeNum( result, error)
	if error ~= 0 then 
		return
	end
	local arena = result.d.arena
	self._arenaModel:updateArena(arena)
	result.d.arena = nil
	local userModel = self._modelMgr:getModel("UserModel")
	userModel:updateUserData(result.d)
	self:callback(result)
end
---[[战斗相关
function ArenaServer:onFightBefore( result,error,errorCode )
	if error ~= 0 then 
		self:callback({errorCode = error})
		return
	end
	self._arenaModel:setCurEnemyInfo(result)
	local arena = result.d.arena
	self._arenaModel:updateArena(arena)
	result.d.arena = nil
	self._modelMgr:getModel("UserModel"):updateUserData(result.d)
	self:callback(result)
end
function ArenaServer:onFightAfter( result,error )
	if error ~= 0 then 
		return
	end
	-- dump( result, "result")
	self:callback(clone(result))
	-- todo 更新物品
	self._modelMgr:getModel("ItemModel"):updateItems(result.d.items)
	result.d.items = nil
	self._arenaModel:updateArena(result.d.arena)
	result.d.arena = nil
	result.d._id = nil
	local currency
	if result.award and result.award.val then
		local currencyHave =  self._modelMgr:getModel("UserModel"):getData().currency
		currency = result.award.val + currencyHave
	end
	self._modelMgr:getModel("UserModel"):updateUserData(result.d)
end
--]]
---[[竞技场商城
-- 获取竞技场商城信息
local count = 0
function ArenaServer:onEnterArenaShop( result, error)
	if error ~= 0 then 
		return
	end
	count = count+1
	self._arenaModel:setArenaShop(result)
	self:callback(result)
end

-- 商城兑换
-- 竞技场生涯
function ArenaServer:onExchangeShop( result, error)
	if error ~= 0 then 
		self:callback({errorCode = error})
		return
	end
	self._arenaModel:updateArenaShop(result.d.arena.shop1)
	result.d.arena.shop1 = nil
	self._arenaModel:updateArena(result.d.arena)
	result.d.arena = nil
	-- todo 更新物品
	self._modelMgr:getModel("ItemModel"):updateItems(result.d.items)
	result.d.items = nil
	self._modelMgr:getModel("UserModel"):updateUserData(result.d)
	self:callback(result)
end
-- 竞技场商店
function ArenaServer:onExchangeShop2( result, error)
	if error ~= 0 then 
		return
	end
	self._arenaModel:updateArenaShop(result.d.arena.shop2,2)
	result.d.arena.shop2 = nil
	self._arenaModel:updateArena(result.d.arena)
	-- todo 更新物品
	self._modelMgr:getModel("ItemModel"):updateItems(result.d.items)
	self:callback(result)
end

-- 刷新商城
function ArenaServer:onRefreshArenaShop( result, error )
	if error ~= 0 then 
		return
	end
	self._arenaModel:updateArenaShop(result.d.arena.shop2,2)
	self:callback(result)
end
-- 竞技场战报
function ArenaServer:onGetReportList( result,error )
	if error ~= 0 then 
		return
	end
	self._arenaModel:setArenaReport(result)
	self:callback(result)
end
-- 保存宣言
function ArenaServer:onSvaeDeclaration( result, errorCode )
	if errorCode ~= 0 then 
		if errorCode == 117 then
			self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_02"))
		end
		return
	end
	self._arenaModel:reflashData()
	self:callback(result)
end
--]]
function ArenaServer:onGetDetailInfo( result, error )
	if error ~= 0 then 
		return
	end
	self:callback(result)
end
function ArenaServer:onGetDetailInfoCross( result, error )
	if error ~= 0 then 
		return
	end
	self:callback(result)
end

function ArenaServer:onClearBattleCd( result, error )
	if error ~= 0 then 
		return
	end
	-- dump(result)
	self:callback(result)
end

function ArenaServer:onCheckTargetRange( result, error )
	if error ~= 0 then 
		return
	end
	self:callback(result)
end

function ArenaServer:onSweepEnemy( result, error )
	if error ~= 0 then 
		return
	end
	self._arenaModel:updateArena(result.d.arena)
	result.d.arena = nil
	-- todo 更新物品
	self._modelMgr:getModel("ItemModel"):updateItems(result.d.items)
	result.d.items = nil
	local rewards = result.d.rewards
	result.d.rewards = nil
	self._modelMgr:getModel("UserModel"):updateUserData(result.d)
	result.d.rewards = rewards
	self:callback(result)
end

return ArenaServer