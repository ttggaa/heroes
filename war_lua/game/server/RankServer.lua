--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-06-25 14:55:54
--

local RankServer = class("RankServer",BaseServer)

function RankServer:ctor(data)
    RankServer.super.ctor(self,data)
    self._rankModel = self._modelMgr:getModel("RankModel")
end

function RankServer:onGetMyRank( result, error)
	if error ~= 0 then 
		return
	end
	self._rankModel:setSelfRankInfo(result)
	self:callback(result)
end

function RankServer:onGetRankList( result, error)
	-- dump(result, "onGetRankList", 10)
	if error ~= 0 then 
		return
	end
	self._rankModel:setData(result)
	self:callback(result)
end

function RankServer:onGetDetailRank( result, error )
	if error ~= 0 then 
		return
	end
	self:callback(result)
end

return RankServer