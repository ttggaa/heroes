--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-07-05 14:56:15
--

local LeagueServer = class("LeagueServer",BaseServer)

function LeagueServer:ctor(data)
    LeagueServer.super.ctor(self,data)
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
end

function LeagueServer:onEnterLeague( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result,"LeagueServer:onEnterLeaguenew",10)
	local formation = result.d.formations
	result.d.formations = nil
	local resuldD = result.d
	result.d = nil
	
	self._leagueModel:setData(result)
	if resuldD and formation then
		local formationModel = self._modelMgr:getModel("FormationModel")
		formationModel:updateFormationDataByType(formationModel.kFormationTypeLeague,formation)		
		self._modelMgr:getModel("UserModel"):updateUserData(resuldD)		
	end
	self:callback(result)
end

function LeagueServer:onFindEnemy( result, error)
	if error ~= 0 then 
		return
	end
	self:handleServerData(result)
	self:callback(result)
end

function LeagueServer:onMonthRank( result, error)
	if error ~= 0 then 
		return
	end
	self:callback(result)
end

function LeagueServer:onBeforeAtk( result, error)
	if error ~= 0 then 
		return
	end
	self:callback(result)
end

function LeagueServer:onGetBattleAward( result, error)
	if error ~= 0 then 
		return
	end
	dump(result,"onGetBattleAward",10)
	self:handleServerData(result)
	self:callback(result)
end

function LeagueServer:onGetReportList( result, error)
	if error ~= 0 then 
		return
	end
	self._leagueModel:setLeagueReport(result)
	self:callback(result)
end

function LeagueServer:onGetInfo( result, error)
	if error ~= 0 then 
		return
	end
	self:callback(result)
end


function LeagueServer:onGetHot( result, error)
	if error ~= 0 then 
		return
	end
	self._leagueModel:setHot(result)
	self:callback(result)
end

function LeagueServer:onSetHot( result, error)
	if error ~= 0 then 
		return
	end
	self._leagueModel:updateHot(result.d)
	self:handleServerData(result)
	self:callback(result)
end

function LeagueServer:onGetAward( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result,"getaward",10)
	self:handleServerData(result)
	self:callback(result)
end
function LeagueServer:onBuyTicket( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result,"buyTicket",10)
	self:handleServerData(result)
	self:callback(result)
end

function LeagueServer:onGetRank( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result,"onGetRank",10)
	self._leagueModel:setRank(result)
	self:handleServerData(result)
	self:callback(result)
end


function LeagueServer:onGetSecRank( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result,"onGetRank",10)
	self._leagueModel:setLocalRank(result)
	self:handleServerData(result)
	self:callback(result)
end

--获取玩家积分联赛数据
function LeagueServer:onGetInfo(result,error)
	if error ~= 0 then 
		return
	end
	-- dump(result,"getInfo==>",10)
	
	self:callback(result)
end

-- 每日奖励
function LeagueServer:onGetDailyAward( result,error )
	if error ~= 0 then 
		return
	end
	self:handleServerData(result)
	self:callback(result)
end
--晋升奖励
function LeagueServer:onGetChangeZoneAward( result,error )
	if error ~= 0 then 
		return
	end
	self:callback(result)
	self:handleServerData(result)
end

-- 领取上赛季奖励 getPreSeasonAward
function LeagueServer:onGetPreSeasonAward( result,error )
	if error ~= 0 then 
		return
	end
	dump(result,"onGetPreSeasonAward",10)
	self:handleServerData(result)
	self:callback(result)
end

function LeagueServer:handleServerData( result )
	-- dump(result,"LeagueServer:handleServerData%%%%%%%%%%%%%%%%%",10)
	if result and result.d and result.d.dayInfo then
		self._modelMgr:getModel("PlayerTodayModel"):updateDayInfo(result.d.dayInfo)
		result.d.dayInfo = nil
	end
	if result and result.d and result.d.league then
		self._leagueModel:updateLeague(result.d.league)
		result.d.league = nil
	end
	if result and result.ifGet then
		self._leagueModel:setGetInfo(result.ifGet)
		result.ifGet = nil
	end
	if result and result.rank then
		self._leagueModel:setCurRank(result.rank)
	end
	if result and result.d and result.d.items then
		local itemModel = self._modelMgr:getModel("ItemModel")
	    itemModel:updateItems(result["d"]["items"], true)
	    result["d"]["items"] = nil
	end 
	if result and result.d then
		self._modelMgr:getModel("UserModel"):updateUserData(result.d)
	end
	if result then
		self._leagueModel:updateLeagueData(result)
	end
end

return LeagueServer