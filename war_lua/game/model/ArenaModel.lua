--[[
    Filename:    ArenaModel.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-09-23 10:49:22
    Description: File description
--]]
local ArenaModel = class("ArenaModel", BaseModel)

function ArenaModel:ctor()
    ArenaModel.super.ctor(self)
    self._data = {}
    self._arenaShop = {}        -- 
    self._arenaRank = {}        -- 排行榜
    self._arenaReport = {}      -- 战报
    self._curEnemyInfo = {}     -- 缓存挑战敌人信息
    self._friendRankList = {}   -- 平台好友map
    self._preRank = nil
    self._preHRank = nil

    self._refreshTimeMap = nil
    -- self._shopRefreshTimes = tab:Setting("G_MYSTERY_BONUS_REFLASH").value
    -- table.sort(self._shopRefreshTimes)
end

function ArenaModel:setData(data)
    self:setPreRank()
    self._data = data
    if self._preHRank == nil then
        self:setPreRank()
    end
    self:processFriendList()
    -- dump(data)
    self:reflashData()
end

function ArenaModel:getData()
    return self._data
end

-- 处理平台好友数据
function ArenaModel:processFriendList( )
    if not self._data or not self._data.friendList or not next(self._data.friendList) then return end
    local preData = self._data.friendList
    self._friendRankList = {}
    local sortTab = {}
    if not next(self._friendRankList) then
        for k,v in pairs(tab["arenaHighShop"]) do
            self._friendRankList[tonumber(v.ranklim)] = {}
            table.insert(sortTab,tonumber(v.ranklim))
        end 
    end
    table.sort(sortTab,function( a,b )
        return a < b 
    end)
    -- dump(self._friendRankList,"friendLis..t...")
    for k,v in pairs(preData) do
        for i,v1 in ipairs(sortTab) do
            if v.hRank <= v1 and not v.dirty then
                v.dirty = true 
                if not self._friendRankList[v1] then self._friendRankList[v1] = {} end
                table.insert(self._friendRankList[v1],v)
                break
            end
        end
    end
    -- dump(self._friendRankList,"friendList")
end

function ArenaModel:getFriendRankList( )
    return self._friendRankList
end

function ArenaModel:getFriendInRank( ranklim )
    return self._friendRankList[ranklim]
end

function ArenaModel:getEnemys( )
    -- dump(self._data.enemys)
    -- dump(self._data)
    local tempArr = {} -- 去重
    if self._data.enemys and table.nums(self._data.enemys)>0 then
        local enemies = {}
        for k,v in pairs(self._data.enemys) do
            -- local enemy = v.battle
            -- enemy.rank = v.rank
            -- enemy.msg = v.msg
            if not tempArr[v.rank] then
                table.insert(enemies,v)
                tempArr[v.rank] = true
            end
        end
        table.sort(enemies,function ( a,b )
            return a.rank < b.rank
        end)
        return enemies
    end
     --self._data.enemys
end
function ArenaModel:reflashEnemys( enemys )
    -- dump(enemys)
	self._data.enemys = enemys
    table.sort(self._data.enemys,function ( a,b )
        return a.rank < b.rank
    end)
	self:reflashData()
end
function ArenaModel:getArena( )
	return self._data.arena
end

function ArenaModel:setPreRank( )
    if self._data and self._data.rank then
        self._preRank = self._data.rank
    end
    if self._data.arena and self._data.arena.hRank then
        self._preHRank = self._data.arena.hRank
    end
    if self._data.gem and self._data.gem ~= 0 then
        self._firstAwardGem = self._data.gem
        SystemUtils.saveAccountLocalData("firstIn_Arena_award_gem",self._firstAwardGem)
    end
end
function ArenaModel:getFirstAwardGem( )
    local localAccGemD = SystemUtils.loadAccountLocalData("firstIn_Arena_award_gem")

    if localAccGemD then
        return localAccGemD
    end
    return self._firstAwardGem or 10
end
function ArenaModel:getRank( )
    return self._data.rank,self._data.arena and self._data.arena.hRank
end
function ArenaModel:getPreRank( )
    return self._preRank or self._data.rank,self._preHRank or self._data.arena.hRank
end
-- 竞技场商城数据
function ArenaModel:setArenaShop( data )
    self._arenaShop = data.arena
    self:reflashData()
end
function ArenaModel:getArenaShop( )
    return self._arenaShop
end
function ArenaModel:updateArenaShop(data,idx )
    idx = idx or 1
    local shop = self._arenaShop["shop" .. idx]
    for k,v in pairs(data) do
        shop[k] = v
    end
    
    self:reflashData()
end

function ArenaModel:setArenaReport( data )
    self._arenaReport = data
    self:reflashData(1)
end

function ArenaModel:getArenaReport( )
    return self._arenaReport
end

function ArenaModel:getLastReport( )
    return self._arenaReport.list and self._arenaReport.list[1]
end

function ArenaModel:getRefreshCost( )
    local times = tonumber(self._arenaShop.shopNum or 0)
    local cost = tab:ReflashCost(times+1).shopArena
    return cost
end
function ArenaModel:getShopRefreshTime( )
    -- local refreshTime = self._data.arena.shopTime
    -- if refreshTime == 0 then
    local nowTimeSec = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local nowHour = tonumber(TimeUtils.date("%H",nowTimeSec))
    local nowDay = tonumber(TimeUtils.date("%d",nowTimeSec))
    local nextHour
    for k,v in pairs(tab:Setting("G_MYSTERY_BONUS_REFLASH").value) do
        if nowHour < tonumber(v) then
            nextHour = v
            break
        end
    end
    if nextHour == nil then
        nextHour = tab:Setting("G_MYSTERY_BONUS_REFLASH").value[1]+24
    end
    local nowDaySec =  nowTimeSec-(nowTimeSec%86400)+28800 -- 取整得到的是格林乔治时间，加时区
    if nowDay > tonumber(TimeUtils.date("%d",nowDaySec)) then
        nextHour = nextHour+8
    end
    local nextHourSec = nextHour*3600
    local nextRest = TimeUtils.date("%H:%M:%S",nowDaySec+nextHourSec-os.time())
    local hMs = string.split(nextRest, ":")
    local restSec = 0
    local factor = 3600
    for k,v in pairs(hMs) do
        restSec = restSec+factor*tonumber(v)
        factor = factor/60
    end
    local refreshTime =  nowTimeSec+restSec
    -- end
    return refreshTime
end
-- 竞技场战斗相关
-- [[战斗前设置当前挑战对象信息
function ArenaModel:setCurEnemyInfo( data )
    -- 组装数据
    -- local currentHero = data
    self._curEnemyInfo = data
end
-- 获得当前挑战者信息
function ArenaModel:getCurEnemyInfo( ) 
    return self._curEnemyInfo
end

-- for 分享
function ArenaModel:setLastEnemyName( nameStr )
    self._lastEnemyName4Share = nameStr
end

function ArenaModel:getLastEnemyName( )
    return self._lastEnemyName4Share 
end

-- 战斗后更新信息
function ArenaModel:updateArena( data )
    self:setPreRank()
    local arena = self._data.arena
    self._preRank = arena.rank
    for k,v in pairs(data) do
        if arena[k] then
            arena[k] = v
        end
    end
    self:reflashData()
end
--]]

-- 竞技场排行数据
function ArenaModel:setArenaRank( data )
    self._arenaRank = data
    self:reflashData()
end
function ArenaModel:getArenaRank( )
    return self._arenaRank
end
-- 设置宣言
function ArenaModel:setSlogan( msg )
    self._data.arena.msg = msg
end

-- 分享战报的CD
function ArenaModel:getLastShareTime( )
    return self._shareReportCD or 0
end

-- 设置分享战报CD
function ArenaModel:updateShareTime( )
    self._shareReportCD = self._modelMgr:getModel("UserModel"):getCurServerTime()
end

-- 辅助计算函数
-- 获取排行所在范围
function ArenaModel:getArenaAwardByRank( rank )
    if rank > 10000 then -- 万名后按一万算 
        rank = 10000 
    end
    local arenaHonor = tab["arenaHonor"]
    for i,honorD in ipairs(arenaHonor) do
        local low,high = honorD.pos[1],honorD.pos[2]
        if rank >= low and rank <= high then
            return low,high,honorD
        end
    end
end

function ArenaModel:setReportTempRank( rank,hRank )
    self._tempReportRank,self._tempReportHRank = rank,hRank 
end

function ArenaModel:getReportTempRank( )
    return self._tempReportRank or 0,self._tempReportHRank or 0 
end

-- 布阵用
--[[
--! @function setEnemyData
--! @desc 设置地方数据提供给远征，竞技场临时存储数据
--！@param inData 怪兽数据
--! @return table
--]]
function ArenaModel:setEnemyData(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        v.teamId = tonumber(k)
        tempData[tonumber(k)] = v
    end
    self._enemyData = tempData
end


function ArenaModel:getEnemyDataById(inTeamId)
    if self._enemyData == nil then 
        return nil
    end
    return self._enemyData[tonumber(inTeamId)]
end
function ArenaModel:setEnemyHeroData(inData)
    self._enemyHeroData = inData
end


function ArenaModel:getEnemyHeroData()
    if self._enemyHeroData == nil then 
        return nil
    end
    return self._enemyHeroData
end

-- 对外接口
function ArenaModel:haveAward( )
    local showAwardOnce = SystemUtils.loadAccountLocalData("arena_showAwardOnce")
    if showAwardOnce then return false end
    local awardD = tab["arenaHighShop"]
    if not self:getData().rank or not self:getArenaShop() then return false end
    local rank = self:getData().rank or 0
    local shopData = self:getArenaShop().shop1
    if not shopData then return false end
    local shopNotice = false

    if shopData then
        local currency = self._modelMgr:getModel("UserModel"):getData().currency or 0
        -- local addTime = self._modelMgr:getModel("UserModel"):getCurServerTime()-self._modelMgr:getModel("ArenaModel"):getArena().shopTime
        for i,v in ipairs(awardD) do
            -- local leftTime = tonumber(v.countlim)-addTime-tonumber(shopData[tostring(v.id)])  
            if v.ranklim and v.cost then
                if rank <= v.ranklim and shopData[tostring(v.id)] == nil and currency >= v.cost then  --and leftTime <= 0 
                    shopNotice = true
                    break
                end
            end
        end
    else
         shopNotice = rank <=  awardD[1].ranklim
    end
    return shopNotice
end

-- 有可挑战次数
function ArenaModel:haveChanllengeNum()
    if self._data.arena and self._data.arena.num then
        return self._data.arena.num > 0
    end
    return false
end

-- 还可购买次数
function ArenaModel:canBuyChanllengeNum( )
    if not self:getArena() then return 0 end
    local buyNum = self:getArena().buyNum
    local vip = self._modelMgr:getModel("VipModel"):getData().level

    local canBuyNum = tonumber(tab:Vip(vip).buyArena)-buyNum
    return canBuyNum 
end

-- 没有冷却时间
function ArenaModel:inChanllengeCD( )
    if self:getArena() then
        return (self:getArena().cdTime or 0) > self._modelMgr:getModel("UserModel"):getCurServerTime()
    else
        return false
    end
end

-- 翻牌有特效的文件
function ArenaModel:isShowTurnAnim( id, num )
    if not self._arenaChooses then
        self._arenaChooses = {}
        for k,v in pairs(tab.arenaChoose) do
            if v.addanm then
                local reward = v.reward
                if reward[1] == "tool" then
                    self._arenaChooses[reward[2] .. "_" .. reward[3]]= true
                else
                    self._arenaChooses[IconUtils.iconIdMap[reward[1]] .. "_" .. reward[3]]=true
                end
            end
        end
    end
    if self._arenaChooses[id .. "_" .. num] then 
        return true
    end
    return false
end

-- 竞技场最佳输出
function ArenaModel:getBestTeamData( leftData,rightData )
    local outputValue = leftData[1].damage or 0
    local defendValue = leftData[1].hurt or 0
    local outputLihuiV = leftData[1].damage or 0
    local shareLeftDamageD = leftData[1].teamData
    local shareLeftHurtD = leftData[1].teamData
    local shareRightDamageD = rightData[1].teamData
    local shareRightHurtD = rightData[1].teamData
    for i = 1,#leftData do
        if leftData[i].damage then
            if tonumber(leftData[i].damage) > tonumber(outputValue) and leftData[i].original then
                if leftData[i].original then
                    outputValue = tonumber(leftData[i].damage)
                    shareLeftDamageD = leftData[i].teamData
                end
            end

            if leftData[i].hurt then
                if tonumber(leftData[i].hurt) > tonumber(defendValue) and leftData[i].original then
                    defendValue = leftData[i].hurt
                    shareLeftHurtD = leftData[i].teamData
                end
            end
        end
    end

    outputValue = rightData[1].damage or 0
    defendValue = rightData[1].hurt or 0
    for i = 1,#rightData do
        if rightData[i].damage then
            if tonumber(rightData[i].damage) > tonumber(outputValue) and rightData[i].original then
                if rightData[i].original then
                    outputValue = tonumber(rightData[i].damage)
                    shareRightDamageD = rightData[i].teamData
                end
            end
        end
        if rightData[i].hurt then
            if tonumber(rightData[i].hurt) > tonumber(defendValue) and rightData[i].original then
                defendValue = rightData[i].hurt
                shareRightHurtD = rightData[i].teamData
            end
        end
    end
    return 
    {
        left = {bestDamage =  shareLeftDamageD.teamId,bestHurt = shareLeftHurtD.teamId,teamDataDamage = shareLeftDamageD,teamDataHurt = shareLeftHurtD},
        right = {bestDamage =  shareRightDamageD.teamId,bestHurt = shareRightHurtD.teamId,teamDataDamage = shareRightDamageD,teamDataHurt = shareRightHurtD}
    }
end

return ArenaModel