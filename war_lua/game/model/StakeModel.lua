--
-- Author: huangguofang
-- Date: 2018-04-27 17:15:51
-- 木桩model

local StakeModel = class("StakeModel", BaseModel)

function StakeModel:ctor()
    StakeModel.super.ctor(self)
    self._stakeData = {}
    self._userModel = self._modelMgr:getModel("UserModel")
    
end

function StakeModel:setData(data)
    self._stakeData = data or {}
    -- dump(data,"data==>",5)    
    if self:isOutOfData() then
    	self._stakeData.hDamage = 0
    end
end

function StakeModel:getStakeData()
	-- dump(self._lotteryData,"getData=>",5)
    return self._stakeData or {}
end
function StakeModel:setOutOfDate()
    self:reflashData("OutOfDate")
end

function StakeModel:isOutOfData()
    if not self._stakeData then return false end
    local resetTime = self._stakeData.resetTime or 0
    if resetTime == 0 then return true end
    local resetTD = TimeUtils.date("*t", resetTime)
    -- local nextTime = resetTime + 7*86400
    -- 每周一的五点 重置
    local currTime = self._userModel:getCurServerTime()
    local weeklyTemp = resetTD.wday == 1 and 7 or resetTD.wday - 1
    local subDay = weeklyTemp - 1
    -- 周一
    local resetTimeTemp = resetTime - subDay*86400
    -- 重置时间所在周的周一五点时间戳
    local monResetTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(resetTimeTemp,"%Y-%m-%d 05:00:00"))
   
    if currTime > monResetTime + 7*86400 then
        return true
    end

    return false
    
end
function StakeModel:updateData(data, eventName)
    -- self._stakeData
    if not data then return end
    local processData = nil
    processData = function(a, b)
        for k, v in pairs(b) do
            if type(a[k]) == "table" and type(v) == "table" then
                processData(a[k], v)
            else
                a[k] = v
            end
        end
    end
    processData(self._stakeData, data)

end

function StakeModel:updateStakeRankList(rankList)
    if not self._stakeData then return end
    if not rankList then return end

    table.sort(rankList ,function (a,b)
        if a.rank and b.rank then
            return a.rank < b.rank
        else
            return true 
        end
    end)
    self._stakeData.rankList = {}    
    for k,v in pairs(rankList) do
        self._stakeData.rankList[k] = v
        -- print(k,"============vvvvvv=====",v.name)  
    end
end

function StakeModel:initEnemyFormationData( level )
	level = level or 1
	local sysData = tab.stakeBattle[level]
	local enemyFromation = {}
	local score = 0
	enemyFromation.heroId = sysData.enemyhero
	enemyFromation.type = 1
	if sysData.enemyhero then
		score = score + (tab.npcHero[sysData.enemyhero].score or 0)
	end
	local enemynpc = sysData.enemynpc or {}
	for i = 1, 8 do
		local npc =  enemynpc[i]
		if npc then
			enemyFromation["team" .. i] = npc[1]
			enemyFromation["g" .. i] = npc[2]
			local npcData = tab:Npc(npc[1])
			score = score + npcData.score
		end
	end
	enemyFromation.score = score
	return enemyFromation
end


return StakeModel