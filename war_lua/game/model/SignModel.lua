--[[
    Filename:    SignModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-03-22 18:49:51
    Description: File description
--]]

local SignModel = class("SignModel", BaseModel)

function SignModel:ctor()
    SignModel.super.ctor(self)
    self._data = {}
    self:initSignData()
    self:registerTimer(5, 0, 1, function ()
        self:reflashData()
    end)
end

function SignModel:setData(data)
    self:initSignData()
    self:updateData(data)
end

function SignModel:initSignData()
    self._data = {}
    self._data["day"] = 0
    self._data["resetTime"] = 0
    self._data["totalSign"] = 0
    self._data["signTime"] = 0
    self._data["rNum"] = 0
    self._data["monRec"] = 0
    self._data["cList"] = {}
    self._data["vipReward"] = {}
    self._data["totalSignGot"] = {}
end

function SignModel:getData()
    return self._data
end

function SignModel:updateData(data)
    if data == nil then
        return
    end
    for k,v in pairs(data) do
        if k == "signTime" then
            self._data.signTime = v
        elseif k == "day" then
            self._data.day = v
        elseif k == "totalSign" then
            self._data.totalSign = v
        elseif k == "resetTime" then 
            self._data.resetTime = v
        elseif k == "rNum" then 
            self._data.rNum = v
        elseif k == "monRec" then 
            self._data.monRec = v
        end
    end
    if data.cList then
        for kk,vv in pairs(data.cList) do
            self._data.cList[kk] = vv
        end
    end
    if data.vipReward then
        for kk,vv in pairs(data.vipReward) do
            self._data.vipReward[kk] = vv
        end
    end
    if data.totalSignGot then
        for kk,vv in pairs(data.totalSignGot) do
            self._data.totalSignGot[kk] = vv
        end
    end


    -- if data.vipReward == nil then
    --     if self._data.vipReward == nil then
    --         self._data.vipReward = {}
    --     end
    -- else
    --     if self._data.vipReward == nil then
    --         self._data.vipReward = data.vipReward
    --     else
 
    --     end
    -- end 
    self:reflashData()
end

function SignModel:updateSignData()
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local todayDate = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))
    local todayTime = tonumber(TimeUtils.getDateString(curServerTime,"%H"))
    local lastData = tonumber(TimeUtils.getDateString(self._data.signTime,"%Y%m"))
    if lastData ~= todayDate then
        if todayTime >= 5 then
            self._data.day = 0
        end
    end
    self:reflashData()
end

function SignModel:isSignInTip()
    local flag = false
    local userLvl = self._modelMgr:getModel("UserModel"):getData().lvl
    if userLvl < 6 then
        return false
    end
    flag = self:isSign()
    if flag == false then
        local playerData = self._modelMgr:getModel("PlayerTodayModel"):getData()
        local day, lackNum = self:getLackDayNum()
        if playerData["day44"] == 1 then
            flag = self:isSign(true)
        elseif lackNum > 0 then
            local signData = self:getData()
            local kebuqian = signData.rNum
            if kebuqian > 0 then
                flag = true
            else
                local list1 = tab:Setting("G_RESIGN_ACTIVE").value[2]
                local list2 = table.nums(tab:Setting("G_RESIGN_RECHARGE").value)
                local buqianflag = false
                if signData["cList"] then
                    local cList1 = signData["cList"]["1"]
                    local cList2 = signData["cList"]["2"]
                    if (not cList1) or cList1 < list1 then
                        buqianflag = true
                    elseif (not cList2) or cList2 < list2 then
                        buqianflag = true
                    end
                else
                    buqianflag = true
                end
                if self:getSignDateTip() == true and buqianflag == true then
                    flag = buqianflag
                end
            end
        end
    end
    if flag == false then
        flag = self:getSignAward()
    end
    return flag
end

function SignModel:getSignDateTip()  
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("ACTIVITY_Sign")
    if tempdate ~= timeDate then
        return true
    end
    return false
end

function SignModel:setSignDateTip()  
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("ACTIVITY_Sign")
    if tempdate ~= timeDate then
        print("ACTIVITY_Sign", timeDate)
        SystemUtils.saveAccountLocalData("ACTIVITY_Sign", timeDate)
    end
end

function SignModel:getSignAward()
    local signData = self:getData()
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))
    local day, lackNum = self:getLackDayNum()
    local flag = false
    for i=1,5 do
        local indexId = tMonth .. "0" .. i
        local signCountTab = tab:SignCount(tonumber(indexId))
        if not signData.totalSignGot[tostring(i)] then
            if (day-lackNum) >= signCountTab.count then
                flag = true
            end
        elseif signData.totalSignGot[tostring(i)] and signData.totalSignGot[tostring(i)] == 1 then

        end
    end
    return flag
end




-- 获取缺勤天数
function SignModel:getLackDayNum()
    local lackNum = 0
    local dayNum = 0
    local signData = self:getData()
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-01 05:00:00"))
    local day = tonumber(TimeUtils.getDateString(curServerTime,"%d")) -- 天数

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local openTime = userData.sec_open_time
    -- 开服时间小于5点大于12点
    local tempsecOpenTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(openTime,"%Y-%m-%d 05:00:00"))
    print("openTime < tempsecOpenTime===", openTime, tempsecOpenTime)
    if openTime < tempsecOpenTime then
        openTime = openTime - 43200
    end
    local secOpenDay = tonumber(TimeUtils.getDateString(openTime,"%Y%m")) -- 开服时间月
    local tDay = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m")) -- 当前月

    local tCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    -- 当前时间小于1号凌晨5点
    if curServerTime < tCurDayTime then
        local curServerTime = curServerTime - 86400
        day = tonumber(TimeUtils.getDateString(curServerTime,"%d")) -- 天数
        tDay = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m")) -- 当前月
    end

    -- 当前时间小于1号凌晨5点
    if curServerTime < tempCurDayTime then
        local curServerTime = curServerTime - 86400
        day = tonumber(TimeUtils.getDateString(curServerTime,"%d")) -- 天数
        tDay = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m")) -- 当前月
    end

    if tDay == secOpenDay then -- 开服时间同月
        local secOpenDayt = tonumber(TimeUtils.getDateString(openTime,"%d")) -- 开服时间天 15 - 15
        day = day - secOpenDayt + 1
    end
    
    dayNum = day
    lackNum = day - signData.day
    local flag = self:isSign()
    if flag == true then
        dayNum = dayNum - 1
        lackNum = lackNum - 1
    end
    if lackNum <= 0 then
        lackNum = 0
    end

    return dayNum, lackNum
end


-- 今天是否已经签到
function SignModel:isSign(buqian)
    local state = 0
    local flag = false
    local signData = self:getData()
    local playerData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    local monthDays = 1
    local tabSign -- = tab:Sign(tonumber(todayDate))
    if signData.day and signData.day ~= 0 then
        monthDays = signData.day
    end

    -- 月份
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-01 05:00:00"))
    local todayMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))

    -- 当前时间小于1号凌晨5点
    if curServerTime < tempCurDayTime then
        todayMonth = tonumber(TimeUtils.getDateString(curServerTime - 86400,"%Y%m")) -- 当前月
    end

    if signData.signTime and signData.signTime ~= 0 then
        local lastSignIn = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime,"%Y-%m-%d %H:%M:%S"))
        -- 2016-04-05 05:03:00
        local tempSignDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime,"%Y-%m-%d 05:00:00"))
        -- 2016-04-05 00:00:00
        local tempRealSignDayTime = tempSignDayTime
        if tempSignDayTime < lastSignIn then
            tempRealSignDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(signData.signTime + 86400,"%Y-%m-%d 05:00:00"))
        end
        if curServerTime >= tempRealSignDayTime then
            monthDays = signData.day + 1
            -- tabSign = tab:Sign(tonumber(TimeUtils.getDateString((self._data.signTime + 86400),"%Y%m%d")))
        end
    end
    if playerData["day44"] == 1 and (not buqian) then
        monthDays = monthDays - 1
    end

    tabSign = tab:Sign(tonumber(string.format("%d%.2d", todayMonth, monthDays)))

    state = self:getSignState1(monthDays, tabSign, signData)
    if state == 1 or state == 2 then
        flag = true
    end
    print("flag======", flag)
    return flag 
end


-- 0 不可签到
-- 1 签到
-- 2 继续领取
-- 3 vip等级不足
-- 4 可补签
function SignModel:getSignState1(monthDays, tabSign, signData)
    if tabSign == nil then
        state = 0
        return state
    end
    local state = 0
    -- print("========", monthDays, signData.day)
    if monthDays > signData.day then
        state = 1 -- 可签到
    else
        local viplevel = self._modelMgr:getModel("VipModel"):getData().level
        if tabSign.vip then
            if signData.vipReward[tostring(monthDays)] then
                state = 0
            else
                if viplevel >= tabSign.vip then
                    state = 2  -- vip继续领取
                else
                    state = 3
                end
            end
        else
            state = 0
        end
    end
    return state
end

return SignModel