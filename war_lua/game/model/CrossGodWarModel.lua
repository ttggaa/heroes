local CrossGodWarModel = class("CrossGodWarModel", BaseModel)

function CrossGodWarModel:ctor()
	CrossGodWarModel.super.ctor(self)
	self._data = {}
	self._playerData = {}--玩家信息
	self._64to8 = {}--64进8数据
	self._eliminate = {}--淘汰赛数据--
end

function CrossGodWarModel:setData(data)
	if not data then
		return
	end
	if data.jn then
		self._playerData = data.jn
		if data.rank then
			local rankData = {}
			for i,v in pairs(data.rank) do
				local playerData = self._playerData[i]
				if not playerData then
					self._viewMgr:showTip("no data:playerId = "..i)
				else
					playerData.intergral = v.s
					playerData.rank = v.r
					local serverData = string.split(i, "-")
					playerData.serverId = serverData[1]
					playerData.playerId = i
					table.insert(rankData, playerData)
				end
			end
			table.sort(rankData, function(a, b)
				return a.rank < b.rank
			end)
			self._playerData = rankData
		end
	end
	if data.elis then
		for i,v in pairs(data.elis) do
			local index = tonumber(i)
			self._64to8[index] = {}
			for groupIndex, groupData in pairs(v) do
				local groupId = tonumber(groupIndex)
				self._64to8[index][groupId] = {}
				for sceneIndex, sceneData in pairs(groupData) do
					local playerData1 = data.jn[sceneData.a]
					local playerData2 = data.jn[sceneData.d]
					local fightData = { player1 = playerData1, player2 = playerData2, key = sceneData.k, win = sceneData.w }
					self._64to8[index][groupId][tonumber(sceneIndex)] = fightData
				end
			end 
		end
		data.elis = nil
	end
	if data.war then
		self._eliminate = {}
		for groupIndex, groupData in pairs(data.war) do
			local groupId = tonumber(groupIndex)
			self._eliminate[groupId] = {}
			for sceneIndex, sceneData in pairs(groupData) do
				local playerData1 = data.jn[sceneData.a]
				playerData1.playerId = sceneData.a
				local playerData2 = data.jn[sceneData.d]
				playerData2.playerId = sceneData.d
				local fightData = { player1 = playerData1, player2 = playerData2, key = sceneData.k, win = sceneData.w }
				self._eliminate[groupId][tonumber(sceneIndex)] = fightData
			end
		end
		data.war = nil
	end
	self._data = data
end

function CrossGodWarModel:getData()
	
end

function CrossGodWarModel:getCurOpenTime()
	local function getTimeDate(timeData, startIndex, endIndex)
		return string.sub(timeData, startIndex, endIndex)
	end
	local curOpenData = self._data._id
	local timeStr = string.format("%s-%s-%s 05:00:00", getTimeDate(curOpenData, 1, 4), getTimeDate(curOpenData, 5, 6), getTimeDate(curOpenData, 7, 8))
	local curOpenTime = TimeUtils.getIntervalByTimeString( timeStr )
	return curOpenTime
end

function CrossGodWarModel:getNextOpenTime()
	local curOpenTime = self:getCurOpenTime()
	local nextOpenTime = curOpenTime + 2*7*24*60*60
	return nextOpenTime
end

function CrossGodWarModel:getPlayerRankData()--获取玩家数据，已排序
	return self._playerData
end

function CrossGodWarModel:changeStateToSignUp(sRank)--改变状态为已报名
	self._data.sRank = sRank
end

function CrossGodWarModel:getHighestFightScore(  )
	return self._data.high or 10000000
end

function CrossGodWarModel:getMyRank()
	return self._data.sRank or -1 -- -1表示没报名参加
end

function CrossGodWarModel:get64to8MatchDataByGroup(group)--根据所在小组获取64进8战斗数据,group:1~8
	return self._64to8[group]
end

function CrossGodWarModel:getEliminateFightData()--获取8进1淘汰赛数据
	return self._eliminate
end

function CrossGodWarModel:setUseFormationId(id)
	id = tonumber(id)
	if id and id>=37 and id<=39 then
		self._data.dFId = id
	end
end

function CrossGodWarModel:getUseFormationId()
	return self._data.dFId
end

function CrossGodWarModel:getMyServerId()
	return self._data.m
end

function CrossGodWarModel:decodeGroupReportData(data)
	if data then
		self._groupReportData = {}
		for i=table.nums(data), 1, -1 do--倒序排列，因为需要将最近的战斗展示在界面最上方
			local reportData = data[i]
			local atkData = {}
			local defData = {}
			atkData.avatar = reportData.atkAvatar
			atkData.avatarFrame = reportData.atkAvatarFrame
			atkData.level = reportData.atkLvl
			atkData.plvl = reportData.atkPlvl
			atkData.name = reportData.atkName
			atkData.serverId = reportData.atkSec
			atkData.score = reportData.atkNewScore
			atkData.scoreChange = reportData.atkScoreInc
			atkData.teams = reportData.atkTeams
			
			defData.avatar = reportData.defAvatar
			defData.avatarFrame = reportData.defAvatarFrame
			defData.level = reportData.defLvl
			defData.plvl = reportData.defPlvl
			defData.name = reportData.defName
			defData.serverId = reportData.defSec
			defData.score = reportData.defNewScore
			defData.scoreChange = reportData.defScoreInc
			defData.teams = reportData.defTeams
			table.insert(self._groupReportData, {atkData = atkData, defData = defData, warIndex = i, win = reportData.win, key = reportData.reportKey})
		end
	end
end

function CrossGodWarModel:getGroupReportData()
	return self._groupReportData or {}
end


function CrossGodWarModel:setGroupRivalData(data)
	if data then
		self._groupRivalData = data
	end
end

function CrossGodWarModel:getGroupRivalDataByUseId(id)
	if self._groupRivalData.formations then
		return self._groupRivalData.formations[tostring(id)]
	end
	return nil
end

function CrossGodWarModel:getGroupRivalServerId()
	return self._groupRivalData.sid
end

function CrossGodWarModel:getGroupRivalUseId()
	if self._groupRivalData then
		return self._groupRivalData.dFId
	end
end
--获取淘汰赛场次
function CrossGodWarModel:getPowIdAndChang(tabIndex,state)
	local chang,powId,ju = 1,8,1
	local juArray  = { 1, 2, 3, 4, 1, 2, 1, 1}
    local tabArray = { 47, 49, 51, 53, 55, 57, 59, 61 }
    local tabArray2 = {48, 50, 52, 54, 56, 58, 60, 62}
    local array = tabArray
    if state and state == 11 then
    	array = tabArray2
    end
    for i,v in ipairs(array) do
        if tabIndex == v then
            chang = i
            ju = juArray[i]
            break
        end
    end
    if tabIndex < 55 then
        powId = 8
    elseif tabIndex < 59 then
        powId = 4
    elseif tabIndex == 59 or tabIndex == 60 then
        powId = 3
    elseif tabIndex == 61 or tabIndex == 62 then
        powId = 2
    end
    return chang,powId,ju
end

function CrossGodWarModel:getPlayerById(pId)
	for i,v in ipairs(self._playerData) do
		if v.playerId == pId then
			return v
		end
	end
	return nil
end

function CrossGodWarModel:getMyWarData()
	local backData = {
		winRante = self._data.winRate,
		score = self._data.score,
		rank = self._data.sRank,
		winRecord = self._data.winRecord,
	}
	return backData
end

function CrossGodWarModel:getNowSeason()
	return self._data.season
end

--当前是否是比赛周  0 是 1 不是
function CrossGodWarModel:matchIsOpen()
	local godWarConstData = self._modelMgr:getModel("UserModel"):getGodWarConstData()
	local openTime = godWarConstData.FIRST_RACE_BEG + 3600*5 + 3*7*24*60*60 --first season start time
	local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	if curTime < openTime then
		return false
	end
	local weeks = math.floor( (curTime - openTime)/(7*24*60*60) )
	print("===================weeks ",weeks)
	local isOpen = math.fmod(weeks,2)
	return isOpen 
end

-- 主界面左下角气泡展示
function CrossGodWarModel:getTimeSystemOn()
    local flag = false
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curTime))
    local isOpen = self:matchIsOpen()
    if isOpen and isOpen == 0 and (weekday == 2 or weekday == 3 or weekday == 4 )then
    	flag = true
    end
    return flag 
end

--[[
	64进8 检测自己是否在当前比赛中
]]
function CrossGodWarModel:checkIsMyMatch(warIndex)
	local isVisible = false
	local id = self._modelMgr:getModel("UserModel"):getData()._id
	local groupId
	local round
	local sort
	for i=1,8 do
		local groupData = self:get64to8MatchDataByGroup(i)[warIndex]
		if groupData then
			for j,roundData in ipairs(groupData) do
				local p1 = roundData.player1.playerId
				local p2 = roundData.player2.playerId
				local p1Id = string.split(p1,"-")[2]
				local p2Id = string.split(p2,"-")[2]
				if id == p1Id or id == p2Id then
					isVisible = true
					groupId = i
					round = warIndex
					sort = j
					break
				end	
			end
		end
	end
	return isVisible,groupId,round,sort
end

function CrossGodWarModel:getPlayerScoreByPlayerId()
	
end

function CrossGodWarModel:getIsInMatchData()
	local backData = {}
	backData.isPromoted = self._data.isPromoted -- 0:未晋级64强, 1:晋级64强, 2:晋级8强
	backData.group = self._data.pGroup
	return backData
end


function CrossGodWarModel:getIsWarOpenWeek()
	local openTime = self:getFirstSeasonOpenTime()
	local weekTime = 7*24*60*60
	local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	local week = tonumber(TimeUtils.getDateString(curTime, "%w"))
	local timeEnd = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))--5:00
	local interval = math.ceil(((timeEnd-openTime)/weekTime)%2)
	if week==1 then
		if interval==0 then
			return true, week
		else
			return false
		end
	else
		if interval==1 then
			return true, week
		else
			return false
		end
	end
end

function CrossGodWarModel:getFirstSeasonOpenTime(isSix)
	local godWarConstData = self._modelMgr:getModel("UserModel"):getGodWarConstData()
	local weekTime = 7*24*60*60
	local openTime = godWarConstData.FIRST_RACE_BEG + 43200 + 3*weekTime
	openTime = TimeUtils.formatTimeToFiveOclock(openTime)
	if isSix then
		return openTime + 3600
	else
		return openTime
	end
end

function CrossGodWarModel:getPlayersByGroup(gId)
	local groupData = self:get64to8MatchDataByGroup(gId)[1]
	local players = {}
	for i,v in ipairs(groupData) do
		table.insert(players,v.player1)
		table.insert(players,v.player2)
	end
	return players
end

function CrossGodWarModel:isShopOpen()
	local isOpen
	local godWarConstData = self._modelMgr:getModel("UserModel"):getGodWarConstData()
	local openTime = godWarConstData.FIRST_RACE_BEG + 3600*5 + 3*7*24*60*60
	openTime = TimeUtils.formatTimeToFiveOclock(openTime)
	local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	return curTime >= openTime
end

function CrossGodWarModel:getShowType(showType)
    local ttype = SystemUtils.loadAccountLocalData("CROSS_GODWAR_DIALOGTYPE1_showtype")
    if showType ~= ttype then
        return true
    end
    return false
end

function CrossGodWarModel:setShowType(showType)
    local ttype = SystemUtils.loadAccountLocalData("CROSS_GODWAR_DIALOGTYPE1_showtype")
    if showType ~= ttype then
        SystemUtils.saveAccountLocalData("CROSS_GODWAR_DIALOGTYPE1_showtype", showType)
    end
end

function CrossGodWarModel:reflashSignUp(data)
	if not data then
		return
	end
	if data.jn then
		if data.rank then
			local rankData = {}
			for i,v in pairs(data.rank) do
				local playerData = data.jn[i]
				if not playerData then
					self._viewMgr:showTip("no data:playerId = "..i)
				else
					playerData.intergral = v.s
					playerData.rank = v.r
					local serverData = string.split(i, "-")
					playerData.serverId = serverData[1]
					playerData.playerId = i
					table.insert(self._playerData, playerData)
				end
			end
			self:reflashData("PushSignUp")
		end
	end
end

function CrossGodWarModel:getServerNameStr(serverId)
    serverId = tonumber(serverId)
    local sdkMgr = SdkManager:getInstance()
    local function getPlatform(sec)
        local platform =""
        local sec = tonumber(sec)
        if sec and sec >= 5001 and sec < 7000 then
            platform = "双线"
        elseif sdkMgr:isQQ() then
            platform = "qq"
        elseif sdkMgr:isWX() then
            platform = "微信"
        else
            platform = "win"
        end
        return platform
    end

    local function getRealNum(sec)
        sec = tonumber(sec)
        local num = 0
        if sec < 5001 then
            num = sec % 1000
        elseif (sec >= 5001 and sec < 5026) or (sec >= 6001 and sec < 6026) then
            num = (sec % 1000)*2 - 1
        elseif (sec >= 5026 and sec < 5501) or (sec >= 6026 and sec < 6501) then   --5025  6025 以后不区分单双号服务器
            local temp = 6025
            if sec < 6000 then
                temp = 5025
            end
            num = sec - temp + 50
        elseif (sec >= 5501 and sec < 6000) or (sec >= 6501 and sec < 7000) then
            num = (sec % 100) * 2
        else
            num = sec % 1000
        end
        return num
    end
    local str1 = getPlatform(serverId) or ""
    local str2 = getRealNum(serverId) or ""
    local serverStr = str1 .. str2 .. "区"
    return serverStr
end

return CrossGodWarModel