--
-- Author: <ligen@playcrab.com>
-- Date: 2017-09-06 18:04:02
--
local SiegeServer = class("SiegeServer", BaseServer)

function SiegeServer:ctor()
    SiegeServer.super.ctor(self)
    self._sModel    = self._modelMgr:getModel("SiegeModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

-- 获取关卡信息
-- @param stageId 关卡ID
function SiegeServer:onGetStageInfo(result, error)
    if error ~= 0 then 
		return
	end
	self._sModel:setPrepareData(result)
	self:callback(result)
end

-- 获取关卡周围站位玩家信息
function SiegeServer:onGetStagePlayer(result, error)
    if error ~= 0 then 
		return
	end
	self:callback(result)
end

-- 攻城战前处理
-- @param stageId 关卡ID
function SiegeServer:onAtkBeforeSiege(result, error)
    if error ~= 0 then 
		return
	end
	self:callback(result)
end

-- 攻城战后处理
-- @param args 参数
-- @param stageId 关卡ID
-- @param token
function SiegeServer:onAtkAfterSiege(result, error)
    if error ~= 0 then 
		return
	end
    if result then 
	    if result["d"] and result["d"]["siege"] then
	        self._sModel:updateData(result["d"]["siege"])
	    end
		self:handleAboutServerData(result, 1)
    end
	self:callback(result)
end

-- 领取攻城阶段奖励
-- @param rewardId 奖励ID
function SiegeServer:onGetAtkProgressReward(result, error)
    if error ~= 0 then 
		return
	end
	self:handleAboutServerData(result, 1)
	self:callback(result)
end

-- 领取攻城累计伤害奖励
-- @param stageId 关卡ID
-- @param rewardIds 奖励ID列表
function SiegeServer:onGetSiegeDamageReward(result, error)
    if error ~= 0 then 
		return
	end
    if result then 
	    if result["d"] and result["d"]["siege"] then
	        self._sModel:updateData(result["d"]["siege"])
	    end
		self:handleAboutServerData(result, 1)
    end
	self:callback(result)
end

-- 守城战前处理
function SiegeServer:onAtkBeforeDefend(result, error)
    if error ~= 0 then 
		return
	end
	self:callback(result)
end

-- 守城战后处理
-- @param args 参数
-- @param token 
function SiegeServer:onAtkAfterDefend(result, error)
    if error ~= 0 then 
		return
	end
    if result then 
	    if result["d"] and result["d"]["siege"] then
	        self._sModel:updateData(result["d"]["siege"])
	    end
		self:handleAboutServerData(result, 1)
    end
	self:callback(result)
end

-- 加固城墙
function SiegeServer:onFixTheWall(result, error)
    if error ~= 0 then 
		return
	end
	-- 城墙数据刷新
	local siegeData = result["d"].siege
	if siegeData then
		self._sModel:updateData(siegeData)
	end 

	local  itemDatas = result.unset
	if itemDatas then
		local inItems = {}
		for k,v in pairs(itemDatas) do
			local id = string.sub(k,7,string.len(k))
			table.insert(inItems, id)
		end
		self._itemModel:delItems(inItems)
	end 
	self._userModel:updateUserData(result["d"])
	self:callback(0 == tonumber(error), result)
	result["d"]["siege"] = nil
end

-- 领取守城阶段奖励
-- @param rewardId 奖励ID
function SiegeServer:onGetDefendProgressReward(result, error)
    if error ~= 0 then 
		return
	end
    if result then 
	    if result["d"] and result["d"]["siege"] then
	        self._sModel:updateData(result["d"]["siege"])
	    end
		self:handleAboutServerData(result, 1)
    end
	self:callback(result)
end

-- 领取守城累计伤害奖励
-- @param rewardIds 奖励ID列表
function SiegeServer:onGetDefendDamageReward(result, error)
    if error ~= 0 then 
		return
	end
    if result then 
	    if result["d"] and result["d"]["siege"] then
	        self._sModel:updateData(result["d"]["siege"])
	    end
	    self:handleAboutServerData(result, 1)
    end

	self:callback(result)
end

-- 领取加固城墙奖励
-- @param rewardIds 奖励ID列表
function SiegeServer:onGetFixReward(result, error)
    if error ~= 0 then 
		return
	end
    if result then 
	    if result["d"] and result["d"]["siege"] then
	        self._sModel:updateData(result["d"]["siege"])
	    end
	    self:handleAboutServerData(result, 1)
    end
	self:callback(result)
end

-- 领取支线奖励
function SiegeServer:onGetBranchReward(result, error)
    if error ~= 0 then 
		return
	end
    self:handleAboutServerData(result, 1)
	self:callback(result)
end

-- 攻打支线前
-- @param stageId 关卡Id
-- @param bid 支线Id
function SiegeServer:onAtkBeforeBranch(result, error)
    if error ~= 0 then 
		return
	end

	self:callback(result)
end

-- 攻打支线后
-- @param args json  支线关卡攻打后参数 
function SiegeServer:onAtkAfterBranch(result, error)
    if error ~= 0 then 
		return
	end
    self:handleAboutServerData(result, 1)
	self:callback(result)
end

-- 领取斥候密信进度奖励
-- @param id 章节ID
function SiegeServer:onGetBranchAcReward(result, error)
    if error ~= 0 then 
		return
	end
    self:handleAboutServerData(result, 1)
	self:callback(result)
end

function SiegeServer:handleAboutServerData(result,inType)
    if result == nil or result["d"] == nil then 
        return 
    end
    if inType == 2 then 
        if result["d"]["story"] ~= nil then 
            local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
            intanceEliteModel:updateData(result["d"]["story"])
            result["d"]["story"] = nil
        end
    else
        if result["d"]["story"] ~= nil then 
            dump(result["d"]["story"], "test111", 10)
            local intanceModel = self._modelMgr:getModel("IntanceModel")
            intanceModel:updateMainsData(result["d"]["story"])
            result["d"]["story"] = nil

            -- 精英副本数据依赖于普通副本，当普通副本产生战斗数据变化则更新精英
            local intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
            intanceEliteModel:updateSectionIdAndStageId()
        end
    end

    if result["d"]["items"] ~= nil then 
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(result["d"]["items"])
        result["d"]["items"] = nil
    end

    if result["d"]["heros"] ~= nil then 
        local heroModel = self._modelMgr:getModel("HeroModel")
        heroModel:unlockHero(result["d"]["heros"])
        result["d"]["heros"] = nil
    end

    if result["d"]["formations"] ~= nil then 
        dump(result["d"]["formations"], "test", 10)
        local formationModel = self._modelMgr:getModel("FormationModel")
        formationModel:updateAllFormationData(result["d"]["formations"])
        -- formationModel:updateFormationDataByType(formationModel.kFormationTypeCommon, result["d"]["formations"][tostring(formationModel.kFormationTypeCommon)])
        result["d"]["formations"] = nil
    end

    local tempTeams = nil
    if result["d"]["teams"] ~= nil then
        tempTeams = result["d"]["teams"]
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(result["d"]["teams"])
        result["d"]["teams"] = nil
    end
    
    -- 更新用户数据
    local userModel = self._modelMgr:getModel("UserModel")
    -- 处理英雄皮肤数据   hgf
    if result["d"]["hSkin"] then
        userModel:updateSkinData(result["d"]["hSkin"])
        result["d"]["hSkin"] = nil
    end

    -- 新手引导模拟用参数
    if not result["d"].dontUpdateUser then
        userModel:updateUserData(result["d"])
    end

    result["d"]["teams"] = tempTeams

    if result["d"]["siege"] then
        self._sModel:updateData(result["d"]["siege"])
    end
end


---------------------------- 推送 -------------------------
-- 关卡状态变化
function SiegeServer:onPushSiegeUpdate(result, error)
    if error ~= 0 then 
		return
	end

    dump(result, "onPushSiegeUpdate", 5)
    self._sModel:updatePushData(result["siege"])
	self:callback(result)
end
return SiegeServer