--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-11-09 20:04:23
--
local LeagueUtils = {}

-- @param id 时间开启表对应ID
function LeagueUtils:isLeagueOpen(id,notDetectMidSeason)
    local tabId = id or 101
	local openDes = ""
	local isOpen = true
	
	local serverBeginTime = ModelManager:getInstance():getModel("UserModel"):getData().sec_open_time
	if serverBeginTime then
		local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime,"%Y-%m-%d 05:00:00"))
		if serverBeginTime < sec_time then   --过零点判断
			serverBeginTime = sec_time - 86400
		end
	end
	-- print("serverBeginTime??????????",os.date("%x",serverBeginTime),tab:STimeOpen(tabId).opentime)
	local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
	local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
	local openDay = tab:STimeOpen(tabId).opentime-1
	-- local leftTime = openDay*86400 - (nowTime-serverBeginTime) - (serverHour-5)*3600
	-- local leftTime = openDay*86400 - (nowTime-serverBeginTime) - (serverHour-5)*3600
	local openTimeNotice = tab:STimeOpen(tabId).openhour
	local openHour = string.format("%02d:00:00",openTimeNotice)
	local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
	local isOpen = leftTime <= 0
	print("======================serverBeginTime",TimeUtils.date("%x",serverBeginTime),serverBeginTime,serverHour,leftTime,math.floor(leftTime/3600))
	if leftTime > 86400 and not isOpen then
		openDes = "距玩法开启还有".. ( math.ceil(leftTime/86400) or openDay or 7) .."天"
	elseif leftTime < 86400 and leftTime > 0 then
		openDes = self:upDateLeagueTime(serverBeginTime,openDay,serverHour,openTimeNotice)
	end 
	if isOpen then
		local openTab = tab:STimeOpen(tabId)
		local openLvl = openTab.level
		local userLvl = ModelManager:getInstance():getModel("UserModel"):getData().lvl
		if openLvl > userLvl then
			return false,lang("TIP_LEAGUE") --"用户等级" .. openLvl .. "开启"
		end
	end
	if isOpen and tonumber(os.date("%w",nowTime) == 1) then -- 周一 4:50到5:20的空档期
		local banSet = tab:Setting("G_LEAGUE_BAN").value
		local banPreTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d " .. banSet[1]))
		local banAftTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d " .. banSet[2]))
		if nowTime >= banPreTime and nowTime <= banAftTime then
			isOpen = false 
			openDes = lang("LEAGUETIP_18") or ""
		end
	end
	if isOpen and tabId == 101 and not notDetectMidSeason then
		if ModelManager:getInstance():getModel("LeagueModel"):isInMidSeasonRestTime() then
			isOpen = false
			-- openDes = "即将开启"
			openDes = lang("LEAGUETIP_18")
		end
	end
	return isOpen,openDes -- false,"暂未开启",
end

function LeagueUtils:upDateLeagueTime(serverBeginTime,openDay,serverHour,openTimeNotice )
	local nowTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
	-- local leftTime = openDay*86400 - (nowTime-serverBeginTime) - (serverHour-5)*3600
	local openHour = string.format("%02d:00:00",openTimeNotice)
	local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
	-- leftTime = leftTime-1
	-- print("···",math.floor(leftTime/3600),math.floor(leftTime%3600/60),math.floor(leftTime%60))
	local openDes = --"据玩法开启还有" .. math.floor(leftTime/3600) .. ":" .. math.floor(leftTime%3600/60) .. ":" .. math.floor(leftTime%60)
	string.format("距玩法开启还有%02d:%02d:%02d",math.floor(leftTime/3600),
		math.floor(leftTime%3600/60),math.floor(leftTime%60))
	return openDes
end
return LeagueUtils