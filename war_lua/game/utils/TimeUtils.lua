--[[
    Filename:    TimeUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-25 11:37:55
    Description: File description
--]]
local TimeUtils = {}

function TimeUtils.getGMTDelta()
    local now = os.time()
    return os.difftime(now, os.time(os.date("!*t", now)))
end

TimeUtils.localUTC = TimeUtils.getGMTDelta() / 3600
TimeUtils.localTimezone = TimeUtils.getGMTDelta()
TimeUtils.serverUTC = TimeUtils.localUTC

TimeUtils.serverTimezone = nil

-- 替代原来的os.date(), os.date()只能转出GMT的日期和本地时区的日期
-- 未登录之前 这里返回值为格林尼治时间时间
function TimeUtils.date(format, time)
    if TimeUtils.serverTimezone == nil then
        return os.date(format, time)
    end
    local _time
    if time then
        _time = time + TimeUtils.serverTimezone
    end
    return os.date("!"..format, _time)
end

function TimeUtils.getDateString(seconds,dataformat)
    dataformat = dataformat or "%Y-%m-%d %H:%M:%S"
    return TimeUtils.date(dataformat, seconds)
end

function TimeUtils.getStringTimeForInt(timeInt)
	if(tonumber(timeInt) <= 0)then
		return "00:00:00"
	elseif(timeInt/60 >= 60)then
		return string.format("%.2d:%.2d:%.2d",timeInt/3600,(timeInt/60)%60,timeInt%60)
	elseif(timeInt >= 60)then
		return string.format("00:%.2d:%.2d",(timeInt/60)%60,timeInt%60)
	else
		return string.format("00:00:%.2d",timeInt%60)
	end
end

function TimeUtils.getTimeStringHMS(timeInt)
	if(tonumber(timeInt) <= 0)then
		return "00h00m00s"
	else
		return string.format("%02dh%02dm%02ds", math.floor(timeInt/(60*60)), math.floor((timeInt/60)%60), timeInt%60)
	end
end

--分别获取 时 分 秒
function TimeUtils.getTimeStringSplitHMS(timeInt)
	if(tonumber(timeInt) <= 0)then
		return "00","00","00"
	else
		return string.format("%02d", math.floor(timeInt/(60*60))), 
		string.format("%02d", math.floor((timeInt/60)%60)),
		string.format("%02d", math.floor(timeInt%60))  
	end
end

-- 将一个时间数转换成"00:00:00"格式
function TimeUtils.getTimeString(timeInt)
	if(tonumber(timeInt) <= 0)then
		return "00:00:00"
	else
		return string.format("%02d:%02d:%02d", math.floor(timeInt/(60*60)), math.floor((timeInt/60)%60), timeInt%60)
	end
end


-- 将一个时间数转换成"00:00"格式(分秒)
function TimeUtils.getTimeStringMS(timeInt)
	if(tonumber(timeInt) <= 0)then
		return "00:00"
	else
		return string.format("%02d:%02d", math.floor((timeInt/60)%60), timeInt%60)
	end
end

-- 将一个时间数转换成"00时00分00秒"格式(小时分)
function TimeUtils.getTimeStringHM(timeInt)
	if(tonumber(timeInt) <= 0)then
		return "00:00"
	else
		return string.format("%02d:%02d", math.floor(timeInt/(60*60)), math.floor((timeInt/60)%60))
	end
end


-- 将一个时间数转换成"00时00分00秒"格式
function TimeUtils.getTimeStringFont1(timeInt)
    if(tonumber(timeInt) <= 0)then
        return "0天00:00:00"
    else

        local formatStr = "%01d天%02d:%02d:%02d"
        local days = math.floor(timeInt / 86400)
        if days >= 10 then 
            formatStr = "%02d天%02d:%02d:%02d"
        end
        local timeInt = timeInt - (days * 86400)
        local hours = math.floor(timeInt/(60*60))
        timeInt = timeInt - (hours * (60*60))
        local minutes = math.floor(timeInt / 60)
        timeInt = timeInt - (minutes * 60)

        return string.format(formatStr, days, hours, minutes, timeInt)
    end
end


-- 将一个时间数转换成"00时00分00秒"格式
function TimeUtils.getTimeStringFont(timeInt)
	if(tonumber(timeInt) <= 0)then
		return "00时00分00秒"
	else
		return string.format("%02d时%02d分%02d秒", math.floor(timeInt/(60*60)), math.floor((timeInt/60)%60), timeInt%60)
	end
end

-- nGenTime: 产生时间戳（也可以是一个未来的时间，比如CD时间戳）
-- nDuration: 固定的有效期间，单位秒，计算某个未来时间的剩余时间时不需要指定
-- serverNowTime: 当前服务器时间
-- 返回3个结果，第一个是剩余到期时间的字符串，"HH:MM:SS", 不足2位自动补零；第二个是bool，标识nGenTime是否到期；第三个是剩余秒数
function TimeUtils.expireTimeString( nGenTime, nDuration, serverNowTime)
    local nNow = serverNowTime or os.time() -- BTUtil:getSvrTimeInterval()  -- 
    --CCLuaLog("nGenTime = " .. nGenTime .. " nNow = " .. nNow)
    local nViewSec = (nDuration or 0) - (nNow - nGenTime)
    return TimeUtils.getTimeString(nViewSec), nViewSec <= 0, nViewSec
end


--得到一个时间戳timeInt与当前时间的相隔天数
--offset是偏移量,例如凌晨4点:4*60*60
--return type is integer, 0--当天, n--不在同一天,相差n天
function TimeUtils.getDifferDay(timeInt, offset)
	timeInt = tonumber(timeInt or 0)
	offset = tonumber(offset or 0)
    local curTime = tonumber(os.time()) + offset
    if(os.date("%j",curTime) == 1 and os.date("%j",timeInt - offset) ~= 1)then
    	return os.date("%j",curTime) - (os.date("%j",timeInt - offset) - os.date("%j",curTime-24*60*60))
    else--if(os.date("%j",curTime) ~= os.date("%j",timeInt - offset))then
    	return os.date("%j",curTime) - os.date("%j",timeInt - offset)
    end
end

-- 指定一个日期时间字符串，返回与之对应的东八区（服务器时区）时间戳
-- sTime: 格式 "2013-07-02 20:00:00"
function TimeUtils.getIntervalByTimeString( sTime , isLocalTime)
    local t = string.split(sTime, " ")
    local tTime = string.split(t[2], ":")
    local tDate
    if string.find(sTime, "-") == nil then
        tDate = string.split(t[1], "/")
    else
        tDate = string.split(t[1], "-")
    end

    local tt = os.time({year = tDate[1], month = tDate[2], day = tDate[3], hour = tTime[1], min = tTime[2], sec = tTime[3]}) or 0
    if not isLocalTime and TimeUtils.localTimezone and TimeUtils.serverTimezone then
        tt = tt + (TimeUtils.localTimezone - TimeUtils.serverTimezone)
        if os.date("*t").isdst then
            tt = tt + 3600
        end
    end
    return tt
end

--给一个时间如:153000,得到今天15:30:00的时间戳 
-- function getIntervalByTime( time )
-- 	local curTime = BTUtil:getSvrTimeInterval()
-- 	local temp = os.date("*t",curTime)
-- 	time = string.format("%06d", time)

-- 	local h,m,s = string.match(time, "(%d%d)(%d%d)(%d%d)" )
-- 	local timeString = temp.year .."-".. temp.month .."-".. temp.day .." ".. h ..":".. m ..":".. s
--     local timeInt = TimeUtil.TimeUtils.getIntervalByTimeString(timeString)

--     return timeInt
-- end

-- function TimeUtils.getDateString(seconds,dataformat)
--     -- body
--     local seconds = tonumber(seconds)

--     dataformat = dataformat or "%Y-%m-%d %H:%M:%S"

--     return os.date(dataformat,seconds);
-- end



function TimeUtils.getDaysOfMonth(seconds)
	local year = TimeUtils.getDateString(seconds, "%Y")
	local month = TimeUtils.getDateString(seconds, "%m")
	return os.date("%d",os.time({year= year,month= month+1,day=0}))
end

function TimeUtils:getTimeDisByFormat(timeDis)
	if not timeDis then
        return
    end
   
   	local timeDes = ""
    if timeDis > 86400 then
        timeDes = math.floor(timeDis/86400) .. "天"
    elseif timeDis > 3600 then
        timeDes = math.floor(timeDis/3600) .. "小时"
    elseif timeDis > 60 then
        timeDes = math.floor(timeDis/60) .. "分钟"
    else
        timeDes = math.max(timeDis, 0) .. "秒"  
    end
    return timeDes
end

--判断两个时间戳是否跨周，界点5点
--@intTime1 是较早时间戳
function TimeUtils.checkIsAnotherWeek(intTime1,inTime2)
    local t = TimeUtils.date("*t",intTime1)
    if t.hour < 5 then
        t = TimeUtils.date("*t",intTime1-86400)
    end
    local yday_ = t.wday == 1 and 1 or 9 - t.wday
    local nowWeekTime = os.time({year = t.year, month = t.month, day = t.day, hour = 5, min = 0, sec = 0})
    local newWeekTime = nowWeekTime + 24*3600*yday_

    -- local t2 = os.date("*t",newWeekTime)
    -- dump(t2)
    -- if inTime2 >= newWeekTime then
    --     print("跨周")
    -- else
    --     print("不跨周")
    -- end
    return inTime2 >= newWeekTime
end

--将时间转化成20170615 类似格式
function TimeUtils.formatTime_1(intTime)
    local t = os.date("*t",intTime)
    local str = string.format("%d%02d%02d",t.year,t.month,t.day)
    return str
end

--将时间转换成当天五点
--@param 时间戳
function TimeUtils.formatTimeToFiveOclock(inTime)
    local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(inTime,"%Y-%m-%d 05:00:00"))
    if inTime < sec_time then   --过零点判断
        sec_time = sec_time - 86400
    end

    return sec_time
end

--[[
    判断两个时间戳是否跨天,true 跨天
]]
function TimeUtils.checkIsOtherDay(time1,time2)
    time1 = TimeUtils.formatTimeToFiveOclock(time1)
    time2 = TimeUtils.formatTimeToFiveOclock(time2)
    return math.abs(time1-time2) >= 86400
end

--[[
    计算出给定时间戳 周的起始点，终止点，时间点为5:00:00
    例如 给定的时间戳为当前年份的第3周，则返回第三周的起始点，和结束点
]]
function TimeUtils.getWeekBeginAndEnd(inTime)
    local hour = TimeUtils.date("%H",inTime)
    if tonumber(hour) < 5 then
        inTime = inTime - 86400
    end
    local weekEnd 
    local weekBegin
    local cur_Week = tonumber(TimeUtils.date("%w",inTime)) --0周日 1~6 周一~周六
    if cur_Week == 0 then
        weekEnd = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(inTime + 86400,"%Y-%m-%d 5:00:00"))
    else
        local time = inTime + (8 - cur_Week)*86400
        weekEnd = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(time,"%Y-%m-%d 5:00:00"))
    end
    weekBegin = weekEnd - 604800 --7 *86400
    return weekBegin,weekEnd
end

-- 18年春节时间
local NEWYEAR_BEGIN = "2018-2-15 05:00:00"
local NEWYEAR_END = "2018-3-3 05:00:00"
local VALENTINE_BEGIN = "2018-2-14 05:00:00"
local VALENTINE_END = "2018-2-15 05:00:00"
-- 白色情人节
local WHITE_VALENTINE_BEGIN = "2018-3-14 05:00:00"
local WHITE_VALENTINE_END = "2018-3-15 05:00:00"

-- 计算主城的时间
function TimeUtils.reCalculateMainViewTimeType()
    if GameStatic.mainViewSpecialVer ~= nil then
        TimeUtils.mainViewVer = GameStatic.mainViewSpecialVer
        -- 过年特效
        local time = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
        print(time,"time....",os.date("%x",time))
        if (TimeUtils.getIntervalByTimeString(VALENTINE_BEGIN) < time and
                    TimeUtils.getIntervalByTimeString(VALENTINE_END) > time)
            or (TimeUtils.getIntervalByTimeString(WHITE_VALENTINE_BEGIN) < time and
                    TimeUtils.getIntervalByTimeString(WHITE_VALENTINE_END) > time)
        then
            TimeUtils.mainViewVer = 6
            return
        elseif TimeUtils.getIntervalByTimeString(NEWYEAR_BEGIN) < time and
            TimeUtils.getIntervalByTimeString(NEWYEAR_END) > time
        then
            TimeUtils.mainViewVer = 5
            return
        elseif TimeUtils.getIntervalByTimeString(NEWYEAR_END) < time then
            -- 过了正月十五继续早中晚切换
            print("tesss")
        else
            return 
        end
    end

    local mainViewVer
    local hour = tonumber(os.date("%H"))
    if OS_IS_WINDOWS then
        if hour >= 10 and hour < 12 then
            mainViewVer = 1
        elseif hour >= 12 and hour < 18 then
            mainViewVer = 2
        else
            mainViewVer = 3
        end
    else
        if hour >= 5 and hour < 17 then
            mainViewVer = 1
        elseif hour >= 17 and hour < 20 then
            mainViewVer = 2
        else
            mainViewVer = 3
        end
    end
    TimeUtils.mainViewVer = mainViewVer
end

--[[
    计算两个时间戳的相隔天数  界限为每日5点
]]--
function TimeUtils.getDiffDays(time1, time2)
    return math.abs(TimeUtils.formatTimeToFiveOclock(time2) - TimeUtils.formatTimeToFiveOclock(time1)) / 86400
end

return TimeUtils