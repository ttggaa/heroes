--
-- Author: <ligen@playcrab.com>
-- Date: 2017-09-06 18:02:20
--
local DailySiegeServer = class("DailySiegeServer", BaseServer)

function DailySiegeServer:ctor()
    DailySiegeServer.super.ctor(self)
    self._dailySiegeModel = self._modelMgr:getModel("DailySiegeModel")
    self._formationModel  = self._modelMgr:getModel("FormationModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._playerTodayMode = self._modelMgr:getModel("PlayerTodayModel")
end

-- 获取日常攻城信息
function DailySiegeServer:onGetDailySiegeInfo(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onGetDailySiegeInfo error:" .. error)
        return 
    end
    if result then
    	-- 更新日常攻城数据
    	local dailySiege =  result["dailySiege"]
    	if dailySiege then
    		self._dailySiegeModel:updateData(dailySiege)
    	end

    	-- 更新阵型数据  
    	local formations =  result["formations"]
    	if formations then
    		self._formationModel:updateAllFormationData(formations)
    	end
        self:callback(0 == tonumber(error), result)
    else
        self:callback(0 == tonumber(error))
    end
end

--日常攻城前处理
function DailySiegeServer:onAtkBeforeSiege(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onAtkBeforeSiege error:" .. error)
        return 
    end
    if result then
        self:callback(0 == tonumber(error), result)
    else
        self:callback(0 == tonumber(error))
    end
end

--日常攻城后处理
function DailySiegeServer:onAtkAfterSiege(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onAtkAfterSiege error:" .. error)
        return 
    end
    if result then
        -- 更新玩家攻城次数
        local dayInfo = result["d"]["dayInfo"]
        if dayInfo then
            self._dailySiegeModel:updateRemainNum(dayInfo)
            self._playerTodayMode:updateDayInfo(dayInfo)
        end
        
        local dailySiege = result["d"]["dailySiege"]
        if dailySiege then
            self._dailySiegeModel:updateData(dailySiege)
        end 

        self._userModel:updateUserData(result["d"])

        self:callback(0 == tonumber(error), result)
        result["d"]["dayInfo"] = nil
        result["d"]["dailySiege"] = nil
    else
        self:callback(0 == tonumber(error))
    end
end

--日常攻城扫荡
function DailySiegeServer:onSweepSiege(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onSweepSiege error:" .. error)
        return 
    end
    if result then
        -- 更新玩家攻城次数
        local dayInfo = result["d"]["dayInfo"]
        if dayInfo then
            self._dailySiegeModel:updateRemainNum(dayInfo)
            self._playerTodayMode:updateDayInfo(dayInfo)
        end 

        local dailySiege = result["d"]["dailySiege"]
        if dailySiege then
            self._dailySiegeModel:updateData(dailySiege)
        end 

        -- -- --更新背包数据
        -- local items = result["d"]["items"]
        -- self._itemModel:updateItems(items)

        self._userModel:updateUserData(result["d"])
        self:callback(0 == tonumber(error), result)
        result["d"]["dayInfo"] = nil
        result["d"]["dailySiege"] = nil
    else
        self:callback(0 == tonumber(error))
    end
end

--日常守城前处理
function DailySiegeServer:onAtkBeforeDefend(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onAtkBeforeDefend error:" .. error)
        return 
    end
    if result then
        self:callback(0 == tonumber(error), result)
    else
        self:callback(0 == tonumber(error))
    end 
end

--日常守城后处理
function DailySiegeServer:onAtkAfterDefend(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onAtkAfterDefend error:" .. error)
        return 
    end
    if result then
        -- 更新玩家守城次数
        local dayInfo = result["d"]["dayInfo"]
        if dayInfo then
            self._dailySiegeModel:updateRemainNum(dayInfo)
            self._playerTodayMode:updateDayInfo(dayInfo)
        end 
        
        -- 更新日常数据
        local dailySiege = result["d"]["dailySiege"]
        if dailySiege then 
            self._dailySiegeModel:updateData(dailySiege)
        end 

        --  -- --更新背包数据
        -- local items = result["d"]["items"]
        -- if items then
        --     self._itemModel:updateItems(items)
        -- end
        
        self._userModel:updateUserData(result["d"])
        self:callback(0 == tonumber(error), result)
        -- result["d"]["items"] = nil
        result["d"]["dailySiege"] = nil
        result["d"]["dayInfo"] = nil
    else
        self:callback(0 == tonumber(error))
    end
end

--日常守城扫荡
function DailySiegeServer:onSweepDefend(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onSweepDefend error:" .. error)
        return 
    end
    if result then
        -- 更新玩家守城次数]
        local dayInfo = result["d"]["dayInfo"]
        if dayInfo then
            self._dailySiegeModel:updateRemainNum(dayInfo)
            self._playerTodayMode:updateDayInfo(dayInfo)
        end 

        -- 更新日常数据
        local dailySiege = result["d"]["dailySiege"]
        if dailySiege then 
            self._dailySiegeModel:updateData(dailySiege)
        end 

        self._userModel:updateUserData(result["d"])
        self:callback(0 == tonumber(error), result)
        result["d"]["dailySiege"] = nil
        result["d"]["dayInfo"] = nil
    else
        self:callback(0 == tonumber(error))
    end
end

--日常守城扫荡奖励
function DailySiegeServer:onGetSweepReward(result, error)
    if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onGetSweepReward error:" .. error)
        return 
    end
    if result then
        self:callback(0 == tonumber(error), result)
    else
        self:callback(0 == tonumber(error))
    end
end


--获取守城累计伤害奖励
function DailySiegeServer:onGetDefendReward(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onGetDefendReward error:" .. error)
        return 
    end
    if result then
        -- 更新日常数据
        local dailySiege = result["d"]["dailySiege"]
        if dailySiege then
            self._dailySiegeModel:updateData(dailySiege)
        end 
        
        self._userModel:updateUserData(result["d"])
        self:callback(0 == tonumber(error), result)
        result["d"]["dailySiege"] = nil
        result["d"]["dayInfo"] = nil
    else
        self:callback(0 == tonumber(error))
    end 
end

--获取展示数据
function DailySiegeServer:onGetSiegeShowData(result, error)
	if 0 ~= tonumber(error) then
        ViewManager:getInstance():onLuaError("DailySiegeServer:onGetSiegeShowData error:" .. error)
        return 
    end

    --rankData
    if result then
    	local rankData =  result["rankData"]
    	local myRankData =  result["owner"]
    	if rankData then
    		self._dailySiegeModel:updateRankData(rankData)
        else
            self._dailySiegeModel:resetRankData()
    	end
    	if myRankData then
    		self._dailySiegeModel:updateMyRankData(myRankData)
        else
            self._dailySiegeModel:resetMyRankData()
    	end
        self:callback(0 == tonumber(error), result)
    else
        self:callback(0 == tonumber(error))
    end
end



return DailySiegeServer