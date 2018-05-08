--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-07-05 14:55:52
--
local LeagueModel = class("LeagueModel", BaseModel)

function LeagueModel:ctor()
    LeagueModel.super.ctor(self)
    self._data = {}
    self._hotSpot = {}
    self._leagueReport = {}
    -- 跨服排行榜
    self._rankList = {}
    self._rankTabCount = 0
    -- 当前服务器排行榜
    self._localRankList = {}
    self._localRankTabCount = 0
    self._leagueHeros = {}
    -- 对存本地的数据 做一份缓存
    self._localDataCache = {}
    self:registerTimer(4, 59, 59, function( )
        -- 周一五点重置连胜
        local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local curWeek = TimeUtils.date("%w",nowTime)
        if tonumber(curWeek) == 1 then -- 周一五点前
            if self._data.league then
                self._data.league.maxWin = 0
            end
        end
    end)
end

function LeagueModel:setData(data)
    self._data = data
    -- dump(data)
    self:setLeagueHeros(data.leagueheros)
    -- 修改上赛季领取状态
    self:setGetInfo(self._data.ifGet)
    self:reflashData()
end

function LeagueModel:getData()
    return self._data
end

-- 积分联赛专用 天平
function LeagueModel:setLeagueHeros( data )
    self._leagueHeros = data
    -- dump(data,"leagueHeros.....................")
    if not data then return end
    local heroModel = self._modelMgr:getModel("HeroModel")
    local tempIds = {}
    local nextHelpClone
    for k,v in pairs(self._leagueHeros) do
        -- print(k,"leagueheros")
        if not nextHelpClone then
            nextHelpClone = clone(v)
        end
        local heroData = clone(tab:Hero(tonumber(k)) or tab:NpcHero(tonumber(k)) or {})
        table.merge(heroData,v)
        self._leagueHeros[k] = heroData
        -- 注释皮肤相关代码
        local haveMyHero = heroModel:getHeroData(k)
        if haveMyHero then
            self._leagueHeros[k].skin = haveMyHero.skin
        end
        tempIds[k] = k 
    end
    local heros = self._modelMgr:getModel("HeroModel"):getData()
    for k,v in pairs(heros) do
        if not tempIds[k] then
            local heroData = clone(tab:Hero(tonumber(k)) or tab:NpcHero(tonumber(k)) or {})
            table.merge(heroData,v)
            self._leagueHeros[k] = heroData
            tempIds[k] = k
        end
    end
    -- 下次助战
    local nextHelpHeroId = self:getNextHelpHeroId()
    if nextHelpHeroId and not tempIds[tostring(nextHelpHeroId)] then
        local heroData = clone(tab:Hero(tonumber(nextHelpHeroId)) or tab:NpcHero(tonumber(nextHelpHeroId)) or {})
        for i=1,4 do
            nextHelpClone["m" .. i] = heroData.recmastery[i]+3
        end
        table.merge(heroData,nextHelpClone)
        self._leagueHeros[tostring(nextHelpHeroId)] = heroData
    end
end

function LeagueModel:upadateLeagueHeros( inData )
    for k,v in pairs(inData) do
        local heroData = clone(tab:Hero(tonumber(k)) or tab:NpcHero(tonumber(k)) or {})
        table.merge(heroData,v)
        self._leagueHeros[k] = heroData
    end
end

-- 
function LeagueModel:getLeagueHeroIds( )
    if not self._leagueHeros then return end
    local heroIds = {}
    local hadIds = {}
    for k,v in pairs(self._leagueHeros) do
        hadIds[tonumber(k)] = true
        table.insert(heroIds,tonumber(k))
    end
    local curHelpHeroId = self:getCurHelpHeroId()
    if curHelpHeroId and not hadIds[curHelpHeroId] then
        table.insert(heroIds,curHelpHeroId)
    end
    local nextHelpHeroId = self:getNextHelpHeroId()
    if nextHelpHeroId and not hadIds[nextHelpHeroId] then
        table.insert(heroIds,nextHelpHeroId)
    end
    dump(heroIds,"heroIds...")
    return heroIds 
end

-- 获得积分联赛试用英雄数据的接口
function LeagueModel:getMyHeroData( heroId )
    if not self._leagueHeros then return end
    return self._leagueHeros[tostring(heroId)]
end

function LeagueModel:getCurZone( )
    return self._data.league and self._data.league.currentZone or 1
end

function LeagueModel:initServerNameMap( inData )
    self._serverNames = {}
    for k,v in pairs(inData) do
        self._serverNames[k] = v.name
    end
end

-- 获取服务器名称
function LeagueModel:getServerName(serverNum)
    if serverNum == nil then
        return "城市守卫"
    end
    
    if serverNum == "npc" then
        return "城市守卫"
    end
    local serverStr = self._serverNames[tostring(serverNum)]
    return serverStr
end

function LeagueModel:getServerList( )
    if not self._data or not self._data.members or not self._serverNames or not next(self._serverNames) then return "暂无" end
    if not self._serverList then
        local str = ""
        for i,v in ipairs(self._data.members) do
            if self._serverNames[tostring(v)] then -- 容错 防止匹配到members列表 服务器没有在初始化服务器列表里
                if str == "" then
                    str = str .. self._serverNames[tostring(v)] .. " "
                else
                    str = str .. "，" .. self._serverNames[tostring(v)] .. " "
                end
            end
        end
        self._serverList = str
    end
    return self._serverList or "暂无"
end

function LeagueModel:setHot( inData )
	self._hotSpot = inData
end

function LeagueModel:updateHot( inData )
    if not inData then return end
    if inData.league and inData.league.leagueZoneList then
        table.merge(self._hotSpot,inData.league.leagueZoneList)
    end
    self:reflashData()
end

function LeagueModel:getHot( )
    if not next(self._hotSpot) then
        if self._data.league and self._data.league.leagueZoneList then
            self._hotSpot = self._data.league.leagueZoneList
        end
    end
	return self._hotSpot 
end

-- 获得连胜次数
function LeagueModel:getMaxWin( )
    return self._data.league and self._data.league.maxWin or 0
end

function LeagueModel:getCurZoneHot( curZone )
    return self._hotSpot[tostring(curZone)]
end

function LeagueModel:setLeagueReport( data )
    -- dump(data)
    -- 处理数据 后端有十条数据 做缓存
    local list = data.list
    local temp={} 
    local uid = self._modelMgr:getModel("UserModel"):getUID()
    for i,v in ipairs(list) do
        local atkId = v.atkId 
        if atkId == uid then
            table.insert(temp,v)
        end
    end
    data.list = temp 
    list = data.list
    if list and next(list) then
        local num = #list
        local tailData = list[num]
        if tailData then
            if num == 1 then
                tailData.addPoint = (tailData.point or 0) - 1000
                tailData.upZone=0
            end
        end
        local curData
        local tailDay = tonumber(TimeUtils.date("%w",tailData.time))
        local curDay 
        for i=2,num do
            curData = list[num-i+1]
            if curData.zone and tailData.zone then
                curData.upZone = curData.zone - tailData.zone
            end
            curDay = tonumber(TimeUtils.date("%w",curData.time))
            if curDay == 1 and (tailDay == 0 or (curData.time-tailData.time) > 86400) then
                curData.addPoint = (curData.point or 0) - 1000
                curData.upZone=0
            else
                curData.addPoint = (curData.point or 0)-(tailData.point or 0)
            end
            tailData = curData
            tailDay = curDay
        end
    end
    self._leagueReport = data
    self:reflashData(1)
end

function LeagueModel:getLeagueReport( )
    return self._leagueReport
end

function LeagueModel:setRank( data )
    -- dump(data,"setRank...",3)
    local uid = self._modelMgr:getModel("UserModel"):getUID()
    self._data.rank = data.rank 
    data.rank = nil
    for tab,tabD in pairs(data) do
        tab = tonumber(tab)
        if tab > self._rankTabCount then
            self._rankTabCount = tab
        end
        for k,v in pairs(tabD) do
            local rank = 20*(tab-1)+tonumber(k)
            v.rank = rank
            self._rankList[rank] = v
            -- 查找自己排名
            if v._id == uid then
                self._data.historyRank = rank
            end
        end
    end
    
end

function LeagueModel:getNextRankTab( )
    return self._rankTabCount+1
end
--获取当前分页
function LeagueModel:getCurrRankTab( )
    return self._rankTabCount
end

function LeagueModel:getRank( )
    return self._rankList
end

function LeagueModel:setLocalRank( data )
    -- dump(data,"setRank...",3)
    local uid = self._modelMgr:getModel("UserModel"):getUID()
    self._data.localRank = data.rank 
    data.rank = nil
    for tab,tabD in pairs(data) do
        tab = tonumber(tab)
        if tab > self._localRankTabCount then
            self._localRankTabCount = tab
        end
        for k,v in pairs(tabD) do
            local rank = 20*(tab-1)+tonumber(k)
            v.rank = rank
            if rank <= 32 then
                self._localRankList[rank] = v
            end
            -- -- 查找自己排名
            -- if v._id == uid then
            --     self._data.historyRank = rank
            -- end
        end
    end

end

function LeagueModel:getNextLocalRankTab( )
    return self._localRankTabCount+1
end
--获取当前分页
function LeagueModel:getCurrLocalRankTab( )
    return self._localRankTabCount
end

function LeagueModel:getLocalRank( )
    return self._localRankList
end

function LeagueModel:getLeague( )
    return self._data.league
end

-- 排名
function LeagueModel:getCurRank( )
    return self._data.rank ,self._preRank or self._data.rank
end

-- 设置排名
function LeagueModel:setCurRank( rank )
    self._preRank = self._data.rank 
    self._data.rank = rank
end

function LeagueModel:getBattleCount( )
    if not self._data.league then return 0 end
    return (self._data.league.win or 0) + (self._data.league.lose or 0) + (self._data.league.draw or 0)
end

-- 处理和league平级的信息 包括 maxWin rank ifGet 等
function LeagueModel:updateLeagueData( inData )
    if not inData then return end
    for k,v in pairs(inData) do
        if self._data[k] and type(self._data[k]) ~= "table" and k ~= "league" and type(v) ~= "table" then
            self._data[k] = v
        end
    end
    self:reflashData()
    self._modelMgr:getModel("ActivityModel"):pushUserEvent()
end

function LeagueModel:updateLeague( inData )
	if not inData or not self._data.league then return end
	for k,v in pairs(inData) do
		if self._data.league[k] then
			if type(v) == "table" then
				for k1,v1 in pairs(v) do
					self._data.league[k][k1] = v1
				end
			else
				self._data.league[k] = v
			end
		else 
			self._data.league[k] = v
		end
	end
	self:reflashData()
end

-- 
function LeagueModel:setGetInfo( ifGet )
    print("ifget......in setInfo",ifGet)
    -- 超出奖励rank 范围 就设置成领过
    local maxHonorD = tab.leagueHonor[#tab.leagueHonor]
    if maxHonorD and maxHonorD.pos and ifGet == 0 then
        local maxRank = maxHonorD.pos[2]
        local preRank = self:getData().preRank or -1
        print("检查这里数据===========================*******preRank....",preRank,"maxRank...",maxRank)
        if preRank > maxRank then
            ifGet = 1
        end
    end
    self._data.ifGet = ifGet 
    self:reflashData()
end

--对外接口
function LeagueModel:haveActiveAward( )
    if not self._data.league then return false end
    local hadNum = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(31) or 0
    local dailyReward = self._data.league.dailyReward or {}
    if hadNum == 0  then
        return false
    end
    
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local day = tonumber(TimeUtils.date("%d",nowTime))
    local nowHour = tonumber(TimeUtils.date("%H",nowTime))
        
    for i,v in ipairs(tab.leagueReward) do
        if not v.condition or v.condition > hadNum then 
            break
        else
            local getDay,getHour = tonumber(TimeUtils.date("%d",dailyReward[tostring(i)])),tonumber(TimeUtils.date("%H",dailyReward[tostring(i)]))
            if not dailyReward[tostring(i)] or ( (day > getDay and (getHour<5 or nowHour >=5)) or (day == getDay and getHour < 5 and nowHour >= 5)) then
                return true
            end
            local getTime = tonumber(dailyReward[tostring(v.id)])
            if getTime then 
                local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:00"))
                local tempPreTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime - 86400,"%Y-%m-%d 05:00:00"))
        
                if ((getTime < tempTodayTime and nowTime >= tempTodayTime) or 
                    (tempTodayTime > nowTime and getTime < tempPreTime)) and 
                    tonumber(v.id) <= hadNum then
                    return true
                end
            end
        end
    end
    return false
end

function LeagueModel:haveAward( )
    return self:canGetPreSeasonAward() or self:haveActiveAward()
end

function LeagueModel:canGetPreSeasonAward( )
    local ifGet = self:getData().ifGet
    return ifGet == 0 and (self:getData().preRank and self:getData().preRank ~= -1)
end

-- 是否有次数
function LeagueModel:haveChallengeNum()
    local league = self:getLeague()
    if not league or not league.ticket then return end
    return (league.ticket.currentCounts or 0) > 0
    -- local vip = self._modelMgr:getModel("VipModel"):getData().level
    -- local canBuyNum = tonumber(tab:Vip(vip).leaguephy) 
    -- return (self._modelMgr:getModel("PlayerTodayModel"):getData().day31 or 0) < canBuyNum -- (tab:Setting("G_LEAGUE_PHYSICAL").value or 5)
end

-- 时长奖励已满
function LeagueModel:timeAwardFull( )
    if not self._data.league then return end
    -- 两赛季中间休息期
    if self:isInMidSeasonRestTime() then
        return false
    end
    -- [[ -- 周一重置时
    if self:isMondayRest() then
        return false
    end
    local curLeagueRank = tab:LeagueRank(self._data.league.currentZone or 1)
    if not curLeagueRank then return false end
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local addedScore = math.floor(((nowTime-self._data.league.leagueAward.upDateTime)/3600)*curLeagueRank.timebonus)
        
    awardNum = math.min(curLeagueRank.timemax,addedScore+(self._data.league.leagueAward.sum or 0))+(self._data.league.leagueAward.cs or 0)
    return awardNum >= curLeagueRank.timemax
end

-- 每赛季前n次特做
function LeagueModel:isAIBan(  )
    local banNum = tab.setting["G_LEAGUE_AIBAN"] 
    if not banNum then return false end 
    
end

-- 两赛季中间休息期
function LeagueModel:isInMidSeasonRestTime( )
    -- [[ 周日晚十点后 周一早九点前 不
    local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    if tonumber(os.date("%w",nowTime)) == 0 then
        local afterTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 24:00:00"))
        if nowTime >= afterTime then
            return true
        end
    end
    if tonumber(os.date("%w",nowTime)) == 1 then
        local beforeTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 09:00:00"))
        if nowTime <= beforeTime then
            return true
        end
    end
    --]]
    return false
end

-- 周一休息
function LeagueModel:isMondayRest( )
    local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    if tonumber(os.date("%w",nowTime)) == 1 then
        local banSet = tab:Setting("G_LEAGUE_BAN").value
        local banPreTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d " .. banSet[1]))
        local banAftTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d " .. banSet[2]))
        if nowTime >= banPreTime and nowTime <= banAftTime then
            return true
        end
    end
    return false
end

-- 转化 leaguehero 字段为 当前赛季对应id
function LeagueModel:changeLeagueHero2ItemId( itemId )
    if string.find(itemId,"leaguehero") and self._data.batchId then
        local batchId = self._data.batchId 
        print("batchId--------------------",batchId)
        local leagueActD = tab:LeagueAct(tonumber(batchId) or 0)
        if leagueActD == nil then -- batchId 不可靠的时候 拿一个非空数据
            for k,v in pairs(tab.leagueAct) do
                if v then
                    leagueActD = v
                    break
                end
            end
        end
        itemId = leagueActD[itemId]
    end
    return itemId
end

-- 获得batchId
function LeagueModel:getBatchId( )

    if not self._data then return 2016101 end
    print("self._data.batchId",self._data.batchId)
    return tonumber(self._data.batchId) or 2016101
end

-- 获得当前赛季对应的 batchId leagueActD
function LeagueModel:getCurLeagueActD( )
    return tab.leagueAct[self:getBatchId()]
end
-- 获得助战英雄
function LeagueModel:getCurHelpHeroId( )
    local leagueActD = self:getCurLeagueActD()
    local heroId = leagueActD.freehero[1]
    print("cur ..heroId",heroId)
    
    return heroId or 60502
end

-- 获得下周助战英雄
function LeagueModel:getNextHelpHeroId( )
    local curBatchId = tonumber(self:getBatchId())
    local curYear = math.floor(curBatchId/1000) 
    local curMonth = math.floor((curBatchId%1000)/10)
    local curNum = curBatchId%10 
    local nextNum = curNum+1
    local nextBatchId = tonumber(string.format("%d%02d%d",curYear, curMonth, nextNum))
    local leagueActD = tab.leagueAct[nextBatchId]
    if not leagueActD then
        if curMonth+1 <= 12 then
            nextBatchId = tonumber(string.format("%d%02d%d",curYear, curMonth+1, 1))
        else
            nextBatchId = tonumber(string.format("%d%02d%d",curYear+1, 1, 1))
        end
        leagueActD = tab.leagueAct[nextBatchId]
    end
    if not leagueActD then 
        leagueActD = self:getCurLeagueActD()
    end
    local heroId = leagueActD.freehero[1]
    print("nextBatchId....",nextBatchId,"heroId",heroId)
    -- 如果玩家身上有该英雄，不显示下周助战
    if heroId and self._modelMgr:getModel("HeroModel"):getHeroData(heroId) then 
        return 
    end
    return heroId or 60502
end

-- 第一次进入 特做 展示旗子状态
function LeagueModel:isShowHot( )
    -- [[ 第一赛季特做
    local isFirst = self:getData().first and self:getData().first ~= 0
    local trigger25 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("25")
    local trigger26 = ModelManager:getInstance():getModel("UserModel"):hasTrigger("26")
    
    if not trigger25 or not trigger26  then
        local curZone = self:getCurZone()
        if curZone == 1 then
            if not trigger25 then
                return 1
            elseif not trigger26 then 
                return 2
            end
        elseif curZone == 2 and not trigger26 then
            return 2
        elseif curZone == 3 then
            return 3
        end
    end
    return false
    --]]
end

-- 存本地，是否本赛季第一次进
function LeagueModel:isCurBatchFirstIn( saveStatus )
    local batchId = self:getBatchId()
    if not self._localDataCache["leagueStart"] then
        self._localDataCache["leagueStart"] = SystemUtils.loadAccountLocalData("leagueStart")
    end
    local uploadIndex = self._localDataCache["leagueStart"]
    if ( not uploadIndex or tonumber(uploadIndex) ~= tonumber(batchId) ) then 
        if saveStatus then
            SystemUtils.saveAccountLocalData("leagueStart", batchId)
            self._localDataCache["leagueStart"] = batchId
        end
        return true
    end
    return false
end

function LeagueModel:isShowCurBatchInTipMc( saveStatus )
    local noLeagueStartMcDayStr = SystemUtils.loadAccountLocalData("noLeagueStartMcDayStr")
    if noLeagueStartMcDayStr then
        local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local dayStr = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 00:00:00"))
        local batchId = self:getBatchId()
        if saveStatus then 
            SystemUtils.saveAccountLocalData("leagueStartMc", batchId)
        end
        if dayStr == noLeagueStartMcDayStr then return false end
    end
    local batchId = self:getBatchId()
    local uploadIndex = SystemUtils.loadAccountLocalData("leagueStartMc")
    print("uploadIndex",batchId,"uploadIndex",uploadIndex)
    if ( not uploadIndex or (tonumber(uploadIndex) ~= tonumber(batchId) and batchId ~= 2016101 --[[ 如果是默认值 不显示--]]) )  then
        if saveStatus then 
            SystemUtils.saveAccountLocalData("leagueStartMc", batchId)
        end
        return true
    end
    return false
end

function LeagueModel:notShowBatchTipMc( )
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local dayStr = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 00:00:00"))
    SystemUtils.saveAccountLocalData("noLeagueStartMcDayStr", dayStr)
end

function LeagueModel:isCurBatchFirstInFomation( )
    local batchId = self:getBatchId()
    local uploadIndex = SystemUtils.loadAccountLocalData("leagueStartFormation")
    if ( not uploadIndex or tonumber(uploadIndex) ~= tonumber(batchId) ) then 
        SystemUtils.saveAccountLocalData("leagueStartFormation", batchId) 
        return true
    end
    return false
end

-- 布阵用
--[[
--! @function setEnemyData
--! @desc 设置地方数据提供给远征，竞技场临时存储数据
--！@param inData 怪兽数据
--! @return table
--]]
function LeagueModel:setEnemyData(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        v.teamId = tonumber(k)
        tempData[tonumber(k)] = v
    end
    self._enemyData = tempData
end


function LeagueModel:getEnemyDataById(inTeamId)
    if self._enemyData == nil then 
        return nil
    end
    return self._enemyData[tonumber(inTeamId)]
end
function LeagueModel:setEnemyHeroData(inData)
    self._enemyHeroData = inData
end


function LeagueModel:getEnemyHeroData()
    if self._enemyHeroData == nil then 
        return nil
    end
    return self._enemyHeroData
end

function LeagueModel:setEnemyZone( zone )
    self._enemyZone = zone 
end

function LeagueModel:getEnemyZone( )
    print("enemyZone is ",self._enemyZone,"...")
    return self._enemyZone or 1
end

function LeagueModel:setEnemyMatchScore( score )
    self._enemyMatchScore = score 
end

function LeagueModel:getEnemyMatchScore( )
    return self._enemyMatchScore
end

function LeagueModel:clearRankList( )
    self._rankList = {}
    self._rankTabCount = 0
end
return LeagueModel