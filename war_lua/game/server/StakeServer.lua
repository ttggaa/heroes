--
-- Author: huangguofang
-- Date: 2018-04-27 17:15:32
--

local StakeServer = class("StakeServer",BaseServer)

function StakeServer:ctor(data)
    StakeServer.super.ctor(self,data)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._stakeModel = self._modelMgr:getModel("StakeModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")    
end

-- 获取信息
function StakeServer:onGetStakeInfo( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result,"result=onGetStakeInfo=11>",5)
	if result["d"] and result["d"]["stake"] then
		self._stakeModel:setData(result["d"]["stake"])
	end
	-- 更新排行榜信息
	if result["d"] and result["d"]["rankList"] then
		self._stakeModel:updateStakeRankList(result["d"]["rankList"])
		result["d"]["rankList"] = nil
	end
	if result["d"] and result["d"]["formations"] then
		self._formationModel:updateAllFormationData(result["d"]["formations"])
		result["d"]["formations"]  = nil
	end
	self:callback(result)
end


---[[战斗相关 站前
function StakeServer:onBeforeStakeAttack( result,error,errorCode )
	if error ~= 0 then 
		-- self:callback({errorCode = error})
		return
	end

	self:callback(result)
end

-- 战后
function StakeServer:onAfterStakeAttack( result,error )
	if error ~= 0 then 
		return
	end
	-- dump(result,"result==>",5)
	if result["d"] and result["d"]["stake"] then
		self._stakeModel:updateData(result["d"]["stake"])
	end
	-- 更新排行榜信息
	if result["d"]["rankList"] then
		self._stakeModel:updateStakeRankList(result["d"]["rankList"])
		result["rankList"] = nil
	end
	self:callback(result)
end

-- 自定义战斗 战前
function StakeServer:onStakeDefiningAttack( result,error )
	if error ~= 0 then 
		return
	end
	
	self:callback(result)
end
-- 自定义战斗 战后
function StakeServer:onStakeDefiningAttackAfter( result,error )
	if error ~= 0 then 
		return
	end
	
	self:callback(result)
end
return StakeServer