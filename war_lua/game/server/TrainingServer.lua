--
-- Author: huangguofang
-- Date: 2016-10-18 11:31:58
-- Description: 训练所

local TrainingServer = class("TrainingServer",BaseServer)

function TrainingServer:ctor(data)
    TrainingServer.super.ctor(self,data)
    self._trainingModel = self._modelMgr:getModel("TrainingModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._rankModel = self._modelMgr:getModel("RankModel")
    self._carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")
end

function TrainingServer:onInit( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result)
	self._trainingModel:setData(result)

	self:callback(result)
end

--领取奖励
function TrainingServer:onGetReward(result,error)
	if error ~= 0 then 
		return
	end

	if next(result.d) then
		if result.d.training then
			self._trainingModel:updateData(result.d.training)
			result.d.training = nil
		end

		local itemModel = self._modelMgr:getModel("ItemModel")
		if result["d"]["items"] then
			itemModel:updateItems(result["d"]["items"], true)
		end
		
		self._userModel:updateUserData(result.d)
	end

	self:callback(result)

end

---[[战斗相关
function TrainingServer:onFightBefore( result,error,errorCode )
	if error ~= 0 then 
		-- self:callback({errorCode = error})
		return
	end

 	self._trainingModel:setTrainingFightToken(result)

	self:callback(result)
end

function TrainingServer:onFightAfter( result,error )
	if error ~= 0 then 
		return
	end
	-- dump( result, "result")	
	if result.d then
		self._trainingModel:updateData(result.d.training)
	end

	-- 更新userModel
	-- self._userModel:updateUserData(result.d)
	-- 战后更新嘉年数据
	self._carnivalModel:setNeedUpdate(true)
	self:callback(result)
end


-- 获取排行榜前三信息
function TrainingServer:onGetTrainingRankList(result,error)
	if error ~= 0 then 
		return
	end
	self:callback(result ,0 == error)

end

-- 获取排行榜信息
function TrainingServer:onGetTrainingRankByTrainId( result, error)
	if error ~= 0 then 
		return
	end
	self._rankModel:setData(result)
	self:callback(result)
end

-- 获取直播地址
function TrainingServer:onGetTrainingShowURL( result, error)
	if error ~= 0 then 
		return
	end
	-- dump(result,"result==>",5)
	if result and result.showURL then
		self._trainingModel:setTrainLiveUrl(result.showURL)
	end
	self:callback(result)
end

return TrainingServer