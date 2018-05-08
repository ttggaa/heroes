--[[
    Filename:    BossModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2015-10-30 14:41:57
    Description: File description
--]]

local BossModel = class("BossModel", BaseModel)

function BossModel:ctor()
    BossModel.super.ctor(self)
    self._bossTimes = {}
    self:registerTimer(5, 0, 0, specialize(self.setOutOfDate, self))
    self._userModel = self._modelMgr:getModel("UserModel")
end

function BossModel:isNeedRequest()
    if not SystemUtils:enableDwarvenTreasury() then return false end

    if not self._cached then
        self._cached = true
        return true
    end
    return false
end

function BossModel:getData()
    return self._data
end

function BossModel:setData(data)
    -- dump(data,"data",10)

    -- 测试保护（猜测data中的key有可能为number类型）
    if type(data) == "table" then
        local normData = {}
        for k,value in pairs(data) do
            normData[tostring(k)] = value
        end
        self._data = normData
    else
        self._data = data
    end
    -- self._data[tostring(pveId)]["rewardList"] = {}
    self._cached = true
    self:reflashData()
end

-- 获取最高伤害记录
-- @param tp 1:矮人木屋  2:阴森墓穴
function BossModel:getMaxDamage(tp)
    if self._data ~= nil then
        if tp == 1 then
            if self._data["4"] and self._data["4"].hValue then
                return self._data["4"].hValue["79001"] or 0
            end
        elseif tp == 2 then
            if self._data["5"] and self._data["5"].hValue then
                return self._data["5"].hValue.damage or 0
            end
        end
    end
    return 0
end

function BossModel:setOutOfDate()
    self._cached = false
    self:reflashData()
end

function BossModel:setTimes(pveId, times)
    self._data[tostring(pveId)].times = times
    self:reflashData()
end

-- 根据PVEId获取最对应数据
function BossModel:getDataByPveId(pveId)
    if self._data[tostring(pveId)] then
        return self._data[tostring(pveId)]
    else
        return nil
    end
end

-- 根据pveId 更新rankList
function BossModel:setrankListByPveId(pveId,rankData)   
    -- print("========================pveId===",pveId)   

    --排序
    local rankListData = rankData and rankData.rankList or {}
    if rankListData then
        table.sort(rankListData, function(a, b)
            if not a.rank or not b.rank then
                return true
            else
                return a.rank < b.rank
            end
        end)
    end
    if self._data[tostring(pveId)] then
        -- dump(rankData,"rankData",5)
        local rankList = self._data[tostring(pveId)].rankList        
        for i=1,3 do
            if rankListData[i] then
                rankList[i] = rankListData[i]
            end
        end
        if rankData.owner and next(rankData.owner) ~= nil then
            self._data[tostring(pveId)].rank = rankData.owner.rank or 0
        end
    end
end

-- 设置 每日积分，总分数 和 总排名 和 前三排行信息 和 hValue
function BossModel:setHighScore( pveId,data )
    if data.highScore then
        self._data[tostring(pveId)].highScore = data.highScore 
    end
    if data.rank then
        self._data[tostring(pveId)].rank = data.rank 
    end
    if data.totalScore then
        self._data[tostring(pveId)].totalScore = data.totalScore 
    end
    if data.rankList then
        self._data[tostring(pveId)].rankList = data.rankList
    end 
    if data.hValue then
        if self._data[tostring(pveId)]["hValue"] == nil then
            self._data[tostring(pveId)]["hValue"] = {}
        end
        for k,v in pairs(data.hValue) do
            self._data[tostring(pveId)]["hValue"][k] = v
        end
    end 
    if data.atkLvl then
        self._data[tostring(pveId)].atkLvl = data.atkLvl
    end 
    if data.atkTime then
        self._data[tostring(pveId)].atkTime = data.atkTime
    end 
    self:reflashData()
end

-- self._bossModel:setPVEScoreRank(result)
function BossModel:setPVEScoreRank( data  )
    self.PVESocreRank = data 
    table.sort(self.PVESocreRank, function(a, b)
        if not a.rank or not b.rank then
            return true
        else
            return a.rank < b.rank
        end
    end)
    -- self:reflashData()
end

function BossModel:reSetPVEScoreRank(  )
    self.PVESocreRank = nil 
end

function BossModel:getPVEScoreRank( id )

    return self.PVESocreRank
end

function BossModel:setRanksAndUserInfo( pveId,data )
    local reward = data.boss[tostring(pveId)].rewardList
    if  not self._data[tostring(pveId)]["rewardList"] then
        self._data[tostring(pveId)]["rewardList"] = {}
    end
    for i,v in pairs(reward) do
        self._data[tostring(pveId)]["rewardList"][i] = 1
    end
    self:reflashData()
end

-- 根据data 自定义的数据
function BossModel:getUserData_rank( pveId )
    local data = {}
    data.rank = self._data[tostring(pveId)].rank 
    data.totoalScore = self._data[tostring(pveId)].totalScore 
    return data 
end

function BossModel:getRawardList(pveId)
    local bossData = self:getDataByPveId(pveId)
    if not bossData then
        bossData = {}
    end
    if not bossData.rewardList then
        bossData["rewardList"] = {}
    end
    return bossData.rewardList
end

function BossModel:updateDiffList(pveId, diffList)
    table.merge(self._data[tostring(pveId)].diffList, diffList)
    self:reflashData()
end

function BossModel:getBossTimes()
    if self._bossTimes then
        self._bossTimes = {}
    end
    for i=1,3 do
        local level
        if i == 1 then
            level = tab:PveSetting(901).level
        elseif i == 2 then
            level = tab:PveSetting(902).level
        elseif i == 3 then
            level =  tab:PveSetting(101).level
        end
        self._bossTimes[i] = level
    end
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local tempLevel = 0
    for k,v in pairs(self._data) do
        if tonumber(k) <= 3 then
            tempLevel = self._bossTimes[3]
        elseif tonumber(k) == 4 then
            tempLevel = self._bossTimes[1]
        elseif tonumber(k) == 5 then
            tempLevel = self._bossTimes[2]
        end
        if tempLevel and userlvl >= tonumber(tempLevel) then
            v.onOpen = true
        else
            v.onOpen = false
        end
    end
end


-- 判断boss战是否有剩余次数
-- @tp 玩法类型  1:矮人宝物  2:阴森墓穴  3:龙之国
function BossModel:haveBossCount(tp)
    self:getBossTimes()

    local flag = false
    for k,v in pairs(self._data) do
        k = tonumber(k)
        if v.onOpen and v.times < 2 then
            if tp == nil then
                flag = true
                break
            elseif (tp == 1 and k == 4) or (tp == 2 and k == 5) or (tp == 3 and k <= 3) then
                flag = true
                break
            end
        end
    end
    return flag
end

-- 主界面是否有红点提示
function BossModel:getHasNotice()
    if self:haveBossCount() then
        return true
    end

    return self:getHasReward()
end

-- 是否有可领奖励
-- @param pType: pve类型  "4":返回矮人宝物  "5":返回阴森墓穴  nil:返回前两个pve
function BossModel:getHasReward(pType)
    local rewardConfigs = {["4"] = tab["dwarfDailyReward"], ["5"] = tab["cryptDailyReward"]}

    local needConfigs = {}
    if pType == nil then
        needConfigs = rewardConfigs
    else
        needConfigs[tostring(pType)] = rewardConfigs[tostring(pType)]
    end

    local bossData = self:getData()
    for k, v in pairs(bossData) do
        local maxScore = v.highScore or 0
        local rewardList  = self:getRawardList(k)
        local awardD = needConfigs[k]
        if awardD ~= nil then
            for id,value in ipairs(awardD) do            
                if maxScore >= value.condition and
                    self._userModel:getPlayerLevel() >= value.effective[1] and
                    self._userModel:getPlayerLevel() <= value.effective[2] and
                    rewardList[tostring(id)] == nil
                then
                    return true
                end
            end
        end
    end
    return false
end

--对应关卡是否可以扫荡   add by haotaian
function BossModel:isPassByPveType(type)
    local bossData = self:getDataByPveId(type) or {}
    local isPass = false
    if bossData.hValue and table.nums(bossData.hValue) > 0 then
        isPass = true
    end
    return isPass
end

--@type PveType    add by haotaian
function BossModel:getRewardIdList( pveId )
    local tabName = {
        ["5"]="cryptDailyReward",
        ["4"]="dwarfDailyReward",
    }
    local bossData = self:getDataByPveId(pveId)
    local rank
    if bossData then
        rank = bossData.highScore or 0
    else
        rank = 0
    end

    local canGetIdData = {}
    local rewardList  = self:getRawardList(pveId)
    local tableDataStatic = clone(tab[tabName[tostring(pveId)]])
    local awardData = {}
    for k,v in pairs(tableDataStatic) do
       v.isGetted = false
       for id,vv in pairs(rewardList) do
            if v.id == tonumber(id) then
                v.isGetted = true
                break
            end
        end
    end

    for k,v in pairs(tableDataStatic) do
        if not v.isGetted then
            table.insert(awardData,v)
        end
    end
    table.sort(awardData,function ( a,b )
        return tonumber(a.condition) < tonumber(b.condition)
    end)

    local vipLv = self._modelMgr:getModel("VipModel"):getData().level or 0
    for k,v in pairs(awardData) do
        local limit = v.viplimit or 0
        -- vip and level 限制
        if vipLv >= limit and self._userModel:getPlayerLevel() >= v.effective[1] and self._userModel:getPlayerLevel() <= v.effective[2] then
            if rank >= v.condition then
                table.insert(canGetIdData,v.id)
            end
        end
    end
    return canGetIdData
end  

return BossModel