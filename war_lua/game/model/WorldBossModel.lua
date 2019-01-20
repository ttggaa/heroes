--[[
    @FileName   WorldBossModel.lua
    @Authors    zhangtao
    @Date       2018-10-26 14:39:01
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local WorldBossModel = class("WorldBossModel", BaseModel)
WorldBossModel.notOpen = 1     -- 未达到开启时间 凌晨5点 - 中午12点
WorldBossModel.isOpen = 2      -- 已开启 中午12点 - 中午12:20
WorldBossModel.isEnd = 3       -- 已结束 中午12：20点 - 第二天凌晨
WorldBossModel.levelLimite = 1
WorldBossModel.timeLimite = 2

local debugTime = 24*3600
WorldBossModel.isDebug = false
local getDateString = TimeUtils.getDateString
function WorldBossModel:ctor()
    WorldBossModel.super.ctor(self)
    self._data = {}
    self._worldBossInfo = {}
    self._openTimeTab = string.split(tab.setting["WORLDBOSS_TIME"].value,":") or {}
    self._durationTime = tab.setting["WORLDBOSS_DURATION"].value
    self._step2 = tab.setting["WORLDBOSS_STEP2"].value
    self._step3 = tab.setting["WORLDBOSS_STEP3"].value
    self._openDayTab = tab.setting["WORLDBOSS_OPEN_DAY"].value
    -- self._durationTime = 24*60
    self._openState = 0
    self._userModel = self._modelMgr:getModel("UserModel")
    self._levelAndTimeOpen = false
end

function WorldBossModel:setData(data)
    self._data = data
    self:reflashData()
end

function WorldBossModel:getData()
    return self._data
end

function WorldBossModel:upWorldBossInfoData(data)
    if data then
        self._worldBossInfo = data
    end
end

function WorldBossModel:getBossInfo()
    return self._worldBossInfo
end

function WorldBossModel:getRawardList()
    local rewardList = {}
    if self._worldBossInfo and self._worldBossInfo["worldBoss"] then
        rewardList = self._worldBossInfo["worldBoss"]["rewardList"] or {}
    end
    return rewardList
end

function WorldBossModel:upDateRankList(rewardList)
    if next(rewardList) then
        local oldRewardList = self:getRawardList()
        if next(oldRewardList) == nil then
            self._worldBossInfo["worldBoss"]["rewardList"] = rewardList
        else
            for k,v in pairs(rewardList) do
                self._worldBossInfo["worldBoss"]["rewardList"][k] = v
            end
        end
    end
end


function WorldBossModel:checkServerOpenTime()
    local tabId = 107    
    local serverBeginTime = self._userModel:getData().sec_open_time
    if serverBeginTime then
        local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime,"%Y-%m-%d 05:00:00"))
        if serverBeginTime < sec_time then   --过零点判断
            serverBeginTime = sec_time - 86400
        end
    end
    local serverHour = tonumber(TimeUtils.date("%H",serverBeginTime)) or 0
    local nowTime = self._userModel:getCurServerTime()
    local openDay = tab:STimeOpen(tabId).opentime-1
    local openTimeNotice = tab:STimeOpen(tabId).openhour
    local openHour = string.format("%02d:00:00",openTimeNotice)
    local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHour))
    local leftTime = openTime - nowTime
    local isOpen = leftTime <= 0
    local tipsDes = ""
    if not isOpen then
        local tipsStr = lang(tab:STimeOpen(tabId).systemTimeOpenTip) or ""
        tipsStr = string.gsub(tipsStr,"{","")  
        tipsStr = string.gsub(tipsStr,"}","")
        tipsDes = string.gsub(tipsStr,"$serveropen", openDay+1)
    end
    return isOpen,tipsDes
end

function WorldBossModel:checkUserLevel()
    local level = self._userModel:getPlayerLevel()
    if level == nil then return false end
    -- dump(tab:SystemOpen(106))
    local openLevel = tab.systemOpen["WorldBoss"][1] or 0
    return level >= openLevel , lang(tab.systemOpen["WorldBoss"][3]) or ""
end


function WorldBossModel:checkLevelAndServerTime()
    if not self._levelAndTimeOpen then
        local levelOpen , tipsValue = self:checkUserLevel()
        if not levelOpen then
            return false , WorldBossModel.levelLimite , tipsValue
        end
        local timeOpen , tipsValue = self:checkServerOpenTime()
        if not timeOpen then
            return false , WorldBossModel.timeLimite ,tipsValue
        end
    end
    self._levelAndTimeOpen = true
    return true
end

function WorldBossModel:checkOpenTime(addTime)
    local tDay = self:getCurWeekDay()
    local checkOpenDay = function()
        for k , v in pairs(self._openDayTab) do
            if tonumber(v) == tonumber(tDay) then
                return true
            end
        end
        return false
    end
    if not checkOpenDay() then
        self._openState = WorldBossModel.notOpen
        return self._openState , 0 ,isOpenDay
    end
    isOpenDay = true
    local addTimeSec = addTime or 0    --活动结束延长时间
    local currTime = self._userModel:getCurServerTime()
    local h = getDateString(currTime,"%H")
    local m = getDateString(currTime,"%M")
    local s = getDateString(currTime,"%S")
    local curSecPoint = h*3600 + m*60 + s    --当前时间
    local openSecPoint = self._openTimeTab[1]*3600 + self._openTimeTab[2]*60 + self._openTimeTab[3]  --开启时间
    local continuesTime = openSecPoint + self._durationTime*60 + addTimeSec     --开启到结束时间
    local defaultPoint = 5*3600     --凌晨5点默认时间                                

    if tonumber(curSecPoint) >= tonumber(defaultPoint) and tonumber(curSecPoint) < tonumber(openSecPoint) then
        self._openState = WorldBossModel.notOpen
    elseif tonumber(curSecPoint) >= tonumber(openSecPoint) and tonumber(curSecPoint) <= tonumber(continuesTime) then
        self._openState = WorldBossModel.isOpen
    else
        self._openState = WorldBossModel.isEnd
    end
    if WorldBossModel.isDebug then
        return WorldBossModel.isOpen,continuesTime - curSecPoint
    else
        return self._openState,continuesTime - curSecPoint,isOpenDay
    end
end

function WorldBossModel:getBossStateId(id)
    local openState,hasTime = self:checkOpenTime()
    local hasTime = hasTime < 0 and 0 or hasTime
    local id = id or 1
    local bossId1 = tab.worldBossMain[id]["bossId1"]
    local bossId2 = tab.worldBossMain[id]["bossId2"]
    local bossId3 = tab.worldBossMain[id]["bossId3"]
    local defaultBossId = bossId1
    if openState == WorldBossModel.isOpen then
        if tonumber(hasTime) == 0 then
            defaultBossId = bossId1 
        elseif tonumber(hasTime) < tonumber(self._step3*60) then
            defaultBossId = bossId3
        elseif tonumber(hasTime) < tonumber(self._step2*60) then
            defaultBossId = bossId2
        else
            defaultBossId = bossId1
        end
    end
    return defaultBossId
end

function WorldBossModel:checkAwardRed()
    self._canGetIdData = {}
    local atkTimes = self._worldBossInfo.worldBoss.atkTimes or 0
    local rewardList  = self:getRawardList()   
    local awardData = {}
    local rewardTab = tab.worldBossAtackReward
    for k,v in pairs(rewardTab) do
       v.isGetted = false
       for id,vv in pairs(rewardList) do
            if v.id == tonumber(id) then
                v.isGetted = true
                break
            end
        end
    end   
    for k,v in pairs(rewardTab) do
        if not v.isGetted and atkTimes >= v.condition then
            table.insert(awardData,v)
        end
    end
    if next(awardData) then
        return true
    end
    return false
end

--获取当前周几
function WorldBossModel:getCurWeekDay()
    local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime() - 5*60*60
    local weekday = tonumber(TimeUtils.date("%w", currTime))
    if weekday == 0 then
        weekday = 7
    end
    return weekday
end

return WorldBossModel