--[[
    Filename:    GuildModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-20 16:14:38
    Description: File description
--]]

local GuildModel = class("GuildModel", BaseModel)

function GuildModel:ctor()
    GuildModel.super.ctor(self)
    -- self._data = {}
    self._membersList = {} -- 联盟成员列表
    self._guildDetail = {} -- 联盟详细数据
    -- self._guildBourse = {}    -- 联盟交易所数据
    self._guildScience = {} -- 联盟科技数据
    self._guildScienceBase = {}
    self._guildMercenary = {} -- 联盟佣兵数据 （zhangtao添加）
    self._guildMercenaryList = {} -- 可雇佣的联盟佣兵列表数据 （zhangtao添加）
    self._guildMercenaryAllList = {}  --所有联盟佣兵列表数据 （zhangtao添加）
    self._guildMaxLevel = 1
    self._gemStatus = false
    self._checkRed = false
    -- self._logData = {}
    -- self._modelMgr = ModelManager:getInstance()
    -- self._userModel = self._modelMgr:getModel("UserModel")
    -- self._vipModel = self._modelMgr:getModel("VipModel")
    -- self._itemModel = self._modelMgr:getModel("ItemModel")

        --添加全局监听 随机红包
    -- self:listenGlobalResponseAfter(specialize(self.onGetRandRed, self))
    self._userModel = self._modelMgr:getModel("UserModel")
    self:registerTimer(5, 0, 4, function ()
        self:clearModelDataAfterFive()
    end)

end

--[[
    是否可以正常加入，申请进联盟，退出联盟 
    GUILD_EXIT_TIME 惩罚时间 G_GUILD_EXIT_LEVEL 惩罚等级
]]
function GuildModel:canJoin()
    local leave_time = self:getPlayerLastLeaveTime()
    if not leave_time then
        return true
    end
    local limit_level = tab:Setting("G_GUILD_EXIT_LEVEL").value or 0
    local user_level = self._userModel:getData().lvl
    if user_level < limit_level then
        return true
    end

    local need_hour = tab:Setting("GUILD_EXIT_TIME").value or 24
    local cur_servertime = self._userModel:getCurServerTime()
    if cur_servertime >= need_hour * 3600 + leave_time then
        return true
    end
end

--[[
    获取再次加入联盟冷却时间
    return 24:00:00 str
]]
function GuildModel:getJoinLeftTime()
    local leave_time = self._userModel:getData().guildLeave
    if not leave_time then
        return 0
    end
    local cur_servertime = self._userModel:getCurServerTime()
    local need_hour = tab:Setting("GUILD_EXIT_TIME").value or 24
    local str = TimeUtils.getTimeString(need_hour *3600 + leave_time - cur_servertime)
    return " ("..str..")"
end

--[[
    获取玩家上次离开联盟的时间戳，可能为nil
]]
function GuildModel:getPlayerLastLeaveTime()
    local leave_time = self._userModel:getData().guildLeave
    if not leave_time then return end
    local roleGuild = self._userModel:getData().roleGuild
    local limit_level = tab:Setting("G_GUILD_EXIT_LEVEL").value or 0
    if not roleGuild or type(roleGuild) ~= "table" 
        or not roleGuild.leaveLvl or tonumber(roleGuild.leaveLvl) < tonumber(limit_level) then
        return
    end
    return leave_time
end




function GuildModel:clearModelDataAfterFive()
    self._guildScienceBase["todayExp"] = 0
    local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    for i=1,3 do 
        dayinfo["day" .. (17+i)] = 0
    end
    local roleGuild = self._modelMgr:getModel("UserModel"):getData().roleGuild
    if roleGuild then
        roleGuild.d1 = 0
        roleGuild.d2 = 0
        roleGuild.d3 = 0
    end
    self:reflashData("DayChanged")
end

-- 更新红包 carry数据
function GuildModel:onGetRandRed(data)
    if not data._carry_ then return end
    -- dump(data._carry_,"carry==>",5)
    local carry = data._carry_
    local redModel = self._modelMgr:getModel("GuildRedModel")
    if carry.randomRed and carry.randomRed.red then
        redModel:setRandRedData(carry.randomRed.red)
    end
end

function GuildModel:setData(data)
    self._data = data
    -- self:processData()  
    self:reflashData()
end

function GuildModel:setAllianceList(data)
    
    local members = data.members
    -- dump(self._membersList, 'self._membersList')
    self:processMembers(members)
    self._membersList = members
    data.members = nil
    self._guildDetail = data
    self:reflashData()
end

function GuildModel:setCheckRedStatus(status)
    self._checkRed = status
end

function GuildModel:getCheckRedStatus()
    return self._checkRed
end


function GuildModel:setGemQipao(status)
    self._gemStatus = status
end

function GuildModel:getGemQipao( ... )
    return self._gemStatus
end

function GuildModel:getData()
    return self._data
end


-- 联盟气泡
function GuildModel:setBubbleData(data)
    self._bubble = data
    -- self:reflashData()
end

function GuildModel:getMercenaryScienceAdd()
    local guildScience = self:getGuildScience()
    local level
    if not guildScience["14"] then
        level = 0
    else
        level = guildScience["14"].lvl
    end
    if level == 0 then
        return 0
    end
    local tabData = tab.technologyChild[14]["effectNum"][1]
    local result = tabData[level] and tabData[level]*100 or tabData[1]*100
    return result
end

function GuildModel:updateBubbleData(data)
    if not self._bubble then
        self._bubble = {}
    end
    for k,v in pairs(data) do
        if self._bubble[k] then
            self._bubble[k] = v 
        else
            self._bubble[k] = v
        end
    end
end

function GuildModel:getBubbleData()
    return self._bubble
end


-- 
function GuildModel:processMembers(data)
    -- dump(data,"data=============",10)
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    --1小时内登陆的，处于在线状态
    for k,v in pairs(data) do
        local tempTime = curServerTime - v.lt
        if tempTime < 3600 then
            v.online = 1
        end
    end

    -- local function compareTime(time1,time2)
    --     if GuildUtils:getDisTodayTime(time1) == GuildUtils:getDisTodayTime(time2) then
    --         return true
    --     elseif time1 < 3600 and time2 < 3600 then
    --         return true
    --     else
    --         return time1 > time2
    --     end
    -- end

    local sortFunc = function(a,b)
        -- local adNum = a.leaveTime
        -- local bdNum = b.leaveTime
        local aonline = a.online
        local bonline = b.online
        local adNumd = a.dNum
        local bdNumd = b.dNum
        local aPos = a.pos or 3 
        local bPos = b.pos or 3
        local aLvl = a.lvl or 1 
        local bLvl = b.lvl or 1
        local a_vipLvl = a.vipLvl or 0
        local b_vipLvl = b.vipLvl or 0
        local aScore = a.score
        local bScore = b.score
        local alogin = a.lt
        local blogin = b.lt

        -- if aPos == nil or bPos == nil then
        --     return
        -- end
        -- if aLvl == nil or bLvl == nil then
        --     return
        -- end

        if aPos ~= bPos then
            return aPos < bPos
        elseif aonline ~= bonline then
            return aonline > bonline
        elseif alogin ~= blogin and aonline == 0 and bonline == 0 and 
            GuildUtils:getLoginTimeDes(alogin) ~= GuildUtils:getLoginTimeDes(blogin) then
            return alogin > blogin
        -- elseif GuildUtils:getDisTodayTime(adNum) == GuildUtils:getDisTodayTime(bdNum) and adNumd ~= bdNumd then
        --         return adNumd > bdNumd
        -- elseif GuildUtils:getDisTodayTime(adNum) == GuildUtils:getDisTodayTime(bdNum) and aLvl ~= bLvl then
        --         return aLvl > bLvl
        -- elseif GuildUtils:getDisTodayTime(adNum) == GuildUtils:getDisTodayTime(bdNum) and aScore ~= bScore then
        --     return aScore > bScore
        -- elseif adNumd ~= bdNumd and aonline == 1 and bonline == 1 then
        --     return adNumd > bdNumd
        elseif adNumd ~= bdNumd then
            return adNumd > bdNumd
        elseif aLvl ~= bLvl then
            return aLvl > bLvl
        elseif a_vipLvl ~= b_vipLvl then
            return a_vipLvl > b_vipLvl
        elseif aScore ~= bScore then
            return aScore > bScore
        end
    end
    table.sort(data, sortFunc)

end

-- 联盟成员列表
function GuildModel:getAllianceList()
    return self._membersList
end

--更新某一个玩家的pos
function GuildModel:updateMemberPos(data)
    if not data then
        return
    end
    for k,v in pairs (self._membersList) do 
        if v.memberId == data.memberId then
            if data.posId then
                v.pos = data.posId
            end
        end
    end
end

-- 瞎逼跑人列表
function GuildModel:getRunAllianceList()
    local runList = {}
    if table.nums(self._membersList) < 6 then
        return self._membersList
    end
    local userid = self._modelMgr:getModel("UserModel"):getData()._id 
    for k,v in pairs(self._membersList) do
        if v.online == 1 or userid == v.memberId then
            table.insert(runList, v)
        end
    end

    if table.nums(runList) < 6 then
        local roleNum = 8 - table.nums(runList)
        for i=1,roleNum do
            local randNum = GRandom(table.nums(self._membersList))
            local flag = false
            for k,v in pairs(runList) do
                if v.memberId == self._membersList[randNum].memberId then
                    flag = true
                    break
                end
            end
            if flag == false and self._membersList[randNum].name then
                table.insert(runList, self._membersList[randNum])
            end
        end
    end
    print("runList ===============", table.nums(runList))
    return runList
end


-- 联盟详细信息
function GuildModel:getAllianceDetail()
    return self._guildDetail
end

function GuildModel:updateMailData(data)
    if not data then
        return
    end
    if data.sMailNum then
        self._guildDetail["sMailNum"] = data.sMailNum
    end
    if data.upMailTime then
        self._guildDetail["upMailTime"] = data.upMailTime
    end
end


-- 是否重新设置排行榜宣言
function GuildModel:getRankReflashDeclare()
    return self._chongxinshezhi
end

-- function GuildModel:updateApplyGuildList()
--     return self._membersList
-- end

function GuildModel:setGuildTempData(data)
    self._updateDetail = data
    self:reflashData()
end

function GuildModel:getGuildTempData()
    return self._updateDetail
end

-- 日志数据处理
function GuildModel:setLogData(data)
    self._logData = {}
    for k,v in pairs(data) do
        table.insert(self._logData, v)
    end
    self:logProgessData()
    self:setLogId()
    self:reflashData()
end

function GuildModel:updateLogData(data)
    -- if self._logData == nil then
    --     self._logData = {}
    -- end
    -- for k,v in pairs(data) do
    --     table.insert(self._logData, v)
    -- end
    -- self:setLogId()
    -- self:reflashData()
end

function GuildModel:clearLogData()
    -- if self._logData == nil then
        self._logData = nil
    -- end
    -- for k,v in pairs(data) do
    --     table.insert(self._logData, v)
    -- end
    -- self:setLogId()
    -- self:reflashData()
end

function GuildModel:getLogData()
    if self._logData == nil then
        return
    end
    return self._logData
end

function GuildModel:logProgessData()
    if table.nums(self._logData) <= 1 then
        return 
    end
    local sortFunc = function(a,b)
        local acheck = a.eventTime
        local bcheck = b.eventTime
        if acheck > bcheck then
            return true
        end
    end
    table.sort(self._logData, sortFunc)
end

function GuildModel:setLogId()
    -- local tempLog = {}
    local day1,day2,day
    -- day1 = self._logData[1].
    for i,v in ipairs(self._logData) do
        if i > 1 and self._logData[i-1] then
            day1 = tonumber(TimeUtils.getDateString(self._logData[i-1].eventTime,"%Y%m%d"))
        end
        if self._logData[i] then
            day2 = tonumber(TimeUtils.getDateString(self._logData[i].eventTime,"%Y%m%d"))
        end
        v.timeType = 1
        -- print("day1 ~= day2=====", day1, day2)
        if day1 and day2 and day1 ~= day2 then
            v.timeType = 2
        elseif not day1 then
            v.timeType = 2
        end
        local month = TimeUtils.getDateString(self._logData[i].eventTime,"%m")
        local date = TimeUtils.getDateString(self._logData[i].eventTime,"%d")
        v.day = month .. "月" .. date .. "日"  -- TimeUtils.getDateString(self._logData[i].eventTime,"%m月%d日")
        -- v.day = TimeUtils.getDateString(self._logData[i].eventTime,"%mY%dD")
        -- v.day = os.date("%m月%d日", self._logData[i].eventTime)
        -- print("v.day=========", v.day)
        v.time = TimeUtils.getDateString(self._logData[i].eventTime,"%H:%M")
        v.id = i 
    end
    -- self._logData = tempLog 
end

-- 科技
function GuildModel:setGuildScience(data)
    if data.techs then
        self._guildScience = data.techs
        data.techs = nil
    end
    -- dump(self._guildScienceBase,"self._guildScienceBase =====================")
    self._guildScienceBase = data
end

function GuildModel:updateScience(data)
    -- print("updateScienceupdateScienceupdateScience ===============")
    -- dump(data,"data =====================")

    -- dump(self._guildScience)
    if not data["gameGuild"] then
        return
    end
    for kk,vv in pairs(data["gameGuild"]) do
        if kk == "exp" then
            self._guildScienceBase["exp"] = vv
        elseif kk == "level" then
            self._guildScienceBase["level"] = vv
        elseif kk == "todayExp" then
            self._guildScienceBase["todayExp"] = vv
        elseif kk == "techs" then
            for i,v1 in pairs(vv) do
                -- dump(vv,"vv =======================")
                if not self._guildScience[i] then self._guildScience[i] = {} end
                for key,data in pairs (v1) do 
                    self._guildScience[i][key] = data
                end
            end
        end
    end
    if data["crit"] then
        self._guildScienceBase["crit"] = data["crit"]
    end
    -- elseif conditions then
        --todo
    self:reflashData()
    -- dump(self._guildScienceBase,"self._guildScienceBase =====================")
    -- dump(self._guildScience,"self._guildScience =====================")
    -- if data[] then
    --     self._guildScience = data.techs
    --     data.techs = nil
    -- end
    -- self._guildScienceBase = data
end

-- function GuildModel:updateGuildScience(data)
--     -- self._guildScience = data
--     if not self._guildScience then
--         self._guildScience = {}
--     end
--     for k,v in pairs(data) do
--         self._guildScience[k] = v
--     end
-- end

-- 获取联盟科技捐献次数
function GuildModel:getDonateTimes()
    local times = tab:Setting("G_GUILD_CONTRIBUTE_NUM").value
    if self._guildScience and self._guildScience["3"] then
        if self._guildScience["3"]["lvl"] ~= 0 then -- and tab:TechnologyChild(3)["effectNum"][self._guildScience["3"]["lvl"]] ~= 0 then
            -- print("================",times,self._guildScience["3"]["lvl"], tab:TechnologyChild(3)["effectNum"][self._guildScience["3"]["lvl"]])
            -- dump(tab:TechnologyChild(3)["effectNum"])
            times = times + tab:TechnologyChild(3)["effectNum"][1][self._guildScience["3"]["lvl"]]
        end
    end
    return times
end

-- 获取联盟增援捐献次数
function GuildModel:getHelpTimes()
    local times = tab:Setting("G_GUILD_HELP_NUM_CD").value
    if self._guildScience and self._guildScience["5"] then
        if self._guildScience["5"]["lvl"] ~= 0 then -- and tab:TechnologyChild(3)["effectNum"][self._guildScience["3"]["lvl"]] ~= 0 then
            -- print("================",times,self._guildScience["3"]["lvl"], tab:TechnologyChild(3)["effectNum"][self._guildScience["3"]["lvl"]])
            times = times + tab:TechnologyChild(5)["effectNum"][1][self._guildScience["5"]["lvl"]]
        end
    end
    return times
end

-- 获取联盟红包抢夺次数
function GuildModel:getRedRobTimes()
    local times = tab:Setting("G_GUILD_RED_GET").value
    if self._guildScience and self._guildScience["10"] then
        if self._guildScience["10"]["lvl"] ~= 0 then -- and tab:TechnologyChild(3)["effectNum"][self._guildScience["3"]["lvl"]] ~= 0 then
            -- print("================",times,self._guildScience["3"]["lvl"], tab:TechnologyChild(3)["effectNum"][self._guildScience["3"]["lvl"]])
            times = times + tab:TechnologyChild(10)["effectNum"][1][self._guildScience["10"]["lvl"]]
        end
    end
    return times
end

-- 获取联盟红包发放次数
function GuildModel:getRedSendTimes()
    local times = tab:Setting("G_GUILD_RED_GIVE").value
    if self._guildScience and self._guildScience["10"] then
        if self._guildScience["10"]["lvl"] ~= 0 then -- and tab:TechnologyChild(3)["effectNum"][self._guildScience["3"]["lvl"]] ~= 0 then
            -- print("================",times,self._guildScience["3"]["lvl"], tab:TechnologyChild(3)["effectNum"][self._guildScience["3"]["lvl"]])
            times = times + tab:TechnologyChild(10)["effectNum"][1][self._guildScience["10"]["lvl"]]
        end
    end
    return times
end

--获取射箭增益等级
function GuildModel:getArrowGainLv()
    local hurtNum, energyNum = 0, 0
    if self._guildScience and self._guildScience["12"] then
        local curLv = self._guildScience["12"]["lvl"]
        if curLv ~= 0 then
            hurtNum = hurtNum + tab:TechnologyChild(12)["effectNum"][1][curLv]
        end
    end

    if self._guildScience and self._guildScience["13"] then
        local curLv = self._guildScience["13"]["lvl"]
        if curLv ~= 0 then
            energyNum = energyNum + tab:TechnologyChild(13)["effectNum"][1][curLv]
        end
    end
    
    return hurtNum, energyNum
end

function GuildModel:getGuildScienceBase()
    return self._guildScienceBase
end

function GuildModel:getGuildScience()
    return self._guildScience or {}
end

--获取对应科技信息  add by haotaian
function GuildModel:getGuildScienceById(id)
    return self._guildScience[tostring(id)]
end

function GuildModel:getGuildScienceLvWithId(id)
	return self._guildScience[tostring(id)] and self._guildScience[tostring(id)].lvl or 0
end

-- -- 可加入联盟列表
-- function GuildModel:getGuildRank()
    
-- end

-- 联盟玩家列表
function GuildModel:getGuildUser()
    
end

-- 玩家位置
function GuildModel:setPlayPos(pos)
    self._playPos = pos
end

function GuildModel:getPlayPos() -- 玩家初始位置
    return self._playPos or 2
end

-- 退出联盟事件处理
function GuildModel:setQuitAlliance(flag)
    self._quitAlliance = flag
end

function GuildModel:getQuitAlliance()
    return self._quitAlliance or false
end

-- 退出联盟事件处理
function GuildModel:setQuitAllianceShow(flag)
    self._quitAllianceShow = flag
end

function GuildModel:getQuitAllianceShow()
    return self._quitAllianceShow or false
end

-- 更新公告
function GuildModel:updateNotice(data)
    -- dump(data)
    self._guildDetail["notice"] = data.content
    self:reflashData()
end

-- 更新宣言
function GuildModel:updateDeclare(data)
    -- dump(data)
    self._guildDetail["declare"] = data.content
end

-- 更新今日捐献经验
function GuildModel:updateAllianceTodayExp(todayExp)
    -- dump(data)
    self._guildDetail["todayExp"] = todayExp
end

-- 判断每日首次是否建群提示
function GuildModel:getGuildADJoinShow()
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("GUILD_JQ_time")
    local flag = 0
    if tempdate ~= timeDate then
        flag = 2
        if tempdate == nil then
            flag = 1
        end
        SystemUtils.saveAccountLocalData("GUILD_JQ_time", timeDate)
    end
    return flag
end

--是否弹出提示建群,加群
function GuildModel:checkJoinOrBindTips()
    local flag = self:getGuildADJoinShow()
    if flag == 0 then
        return false
    end
    return true
end

-- 判断每日首次是否显示公告
function GuildModel:getGuildADFristShow()
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("GUILD_AD_time")
    if tempdate ~= timeDate then
        self._laoda = true
        SystemUtils.saveAccountLocalData("GUILD_AD_time", timeDate)
        return true
    end
    self._laoda = false
    return false
end

function GuildModel:getGuildADFristShowLaoda()
    return self._laoda or false
end

function GuildModel:isGuildTip()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local flag = false
    if userData["guildApply"] then
        flag = true
    end
    return flag
end

-- 处理日志
function GuildModel:getRichTextString(data)
    if data == nil then
        return 
    end
    local str = lang("RIZHI_" .. data.type)
    if data.type == 8 then
        local tempData = {}
        tempData.name = lang(tab:TechnologyChild(data.params["tid"]).name)
        tempData.level = data.params["level"]
        
        for k,v in pairs(tempData) do
            str = self:split(str,k,v)
        end
    else
        for k,v in pairs(data.params) do
            str = self:split(str,k,v)
        end
    end

    return str
end 

function GuildModel:split(str,param,reps)
    if str == "" then
        return str
    end
    local des = string.gsub(str,"{$" .. param .. "}",reps)
    return des 
end

-- -- 联盟玩家排序处理
-- function GuildModel:processData()
--     local pingScore = 0
--     local teamModel = self._modelMgr:getModel("TeamModel")
--     local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
--     local xishu =  tab:HeroPower(userlvl).tujian 
--     for k,v in pairs(self._data) do
--         if v.posList ~= nil then
--             for k1,v1 in pairs(v.posList) do
--                 if v1 ~= 0 then
--                     local teamdata = teamModel:getTeamAndIndexById(v1)
--                     pingScore = pingScore + tab:Star(teamdata.star).score
--                 end
--             end
--             v.score = pingScore * (tab:Tujianshengji(v.level).effect * 0.01 + 1)
--             pingScore = 0
--             v.fight = xishu * v.score
--         end
--         self._score[tonumber(k)] = v.score
--     end
--     self:checkTips()
-- end

-- 玩家世界招募冷却时间
function GuildModel:getGuildJoinCDTime()
    local flag = false
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local lastSendTime = SystemUtils.loadAccountLocalData("GUILD_JOINCD_time") or 0
    local tempTimeCD = curServerTime - lastSendTime
    local timeCD = tab:Setting("GUILD_RECRUIT_CD").value - tempTimeCD
    local timeStr = ""

    if timeCD <= 0 then
        flag = true
    end

    if flag == true then
        SystemUtils.saveAccountLocalData("GUILD_JOINCD_time", curServerTime)
    else
        local minute = math.floor(timeCD/60)
        timeCD = timeCD - minute*60
        local second = math.fmod(timeCD, 60)
        timeStr = string.format("%.2d:%.2d", minute, second)
    end
    return flag, timeStr
end

-- 联盟科技距离升级经验最少的
function GuildModel:getScienceMinEXP()
    local guildScience = self:getGuildScience()
    -- dump(guildScience)
    local minExpId = 1
    local minExp = 100000
    for k,v in ipairs(tab.technologyChild) do
        if not guildScience[tostring(k)] then
            guildScience[tostring(k)] = {}
            guildScience[tostring(k)].exp = 0
            guildScience[tostring(k)].lvl = 0
        end
        local tempExp = guildScience[tostring(k)].exp
        local templvl = guildScience[tostring(k)].lvl
        templvl = templvl + 1
        if templvl > table.nums(v["levelexp"]) then
            templvl = table.nums(v["levelexp"])
        end
        if (v["levelexp"][tonumber(templvl)] - tempExp) < minExp and guildScience[tostring(k)].lvl < v.levelmax then
            minExp = (v["levelexp"][templvl] - tempExp)
            minExpId = k
        end
    end
    return minExpId
end



-------------------------------------------
-- 更新联盟等级
function GuildModel:updateAllianceLevel(level)
    print("====================更新联盟等级========================")
    self._guildDetail["level"] = level
    local userModel = self._modelMgr:getModel("UserModel")
    userModel:updateGuildLevel(level)

    print("====================更新联盟等级========================")
    local bubble = self._modelMgr:getModel("PlayerTodayModel"):getBubble()
    local guildMaxLevel = bubble["b3"] or 1
    if level and level > 1 and level > guildMaxLevel then
        self._guildMaxLevel = guildMaxLevel
        -- local param = {num = 3, val = level}
        print("=准备播放动画=============", level)
        -- if tab:GuildLevel(level).open == 1 then
        --     self:saveAllianceOpenAction(level)
        -- end
        self:saveAllianceOpenAction(level)
        self:resetBubbleData()
        -- self:saveBubbleModify(1)
        -- local param = {num = 3, val = level}
        -- ServerManager:getInstance():sendMsg("UserServer", "bubbleModify", param, true, {}, function (result)
        --     print("开启动画======")
        --     -- self._viewMgr:showTip("开启动画======")
        -- end)
    end
end

-- 保存需要播放动画的联盟等级
function GuildModel:saveAllianceOpenAction(level)
    print("==保存需要播放动画的联盟等级====",level)
    SystemUtils.saveAccountLocalData("GUILD_LEVELANIM", level)
end

-- 获取播放动画的联盟等级
function GuildModel:getAllianceOpenActionLevel()
    local guildMaxLevel = SystemUtils.loadAccountLocalData("GUILD_LEVELANIM") or 1
    print("==获取播放动画的联盟等级==guildMaxLevel==",guildMaxLevel)
    return guildMaxLevel
end

-- 清空播放动画的联盟等级
function GuildModel:clearAllianceOpenAction()
    print("==清空播放动画的联盟等级====")
    self:saveAllianceOpenAction(1)
end

-- 在后端保存气泡数据
function GuildModel:saveBubbleModify(_type)
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local guildLvl = userData.guildLevel

    local bubble = self._modelMgr:getModel("PlayerTodayModel"):getBubble()
    print("========在后端保存联盟最高等级==========")
    local guildMaxLevel = bubble["b3"] or 1
    if guildLvl > guildMaxLevel then
        local param = {num = 3, val = guildLvl}
        ServerManager:getInstance():sendMsg("UserServer", "bubbleModify", param, true, {}, function (result)
            local guildMaxLevel = SystemUtils.loadAccountLocalData("GUILD_LEVELANIM") or 1
            print("开启动画======", guildMaxLevel)
            -- self._viewMgr:showTip("开启动画======")
            self:reflashData()
        end)
    end
end

function GuildModel:forceCleanBubble()
    local param = {num = 3, val = 0}
    local bubble = self._modelMgr:getModel("PlayerTodayModel"):getBubble()
    if bubble["b3"] and bubble["b3"] ~= 0 then
        ServerManager:getInstance():sendMsg("UserServer", "bubbleModify", param, true, {}, function (result)
        end)
    end
end

function GuildModel:resetBubbleData()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local guildLvl = userData.guildLevel or 0
    local bubble = self._modelMgr:getModel("PlayerTodayModel"):getBubble()
    local guildMaxLevel = bubble["b3"] or 0

    printf("resetBubbleData guildMaxLevel = %d , guildLvl = %d",guildMaxLevel,guildLvl)
    if guildMaxLevel and guildMaxLevel == 0 and guildLvl >= 1 then
        self._modelMgr:getModel("PlayerTodayModel"):getBubble()["b3"] = guildLvl
        local param = {num = 3, val = guildLvl}
        ServerManager:getInstance():sendMsg("UserServer", "bubbleModify", param, true, {}, function (result)
        end)
    end
end

-- 主界面联盟新功能开启气泡
function GuildModel:getMaxGuildLevel()
    local flag = false
    local guildMaxLevel = self:getAllianceOpenActionLevel()
    if guildMaxLevel and guildMaxLevel > 1 then
        flag = true
    end
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local guildLvl = userData.guildLevel
    if guildLvl == 0 then
        flag = false
    end
    return flag
end

function GuildModel:checkIsLevelUp()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local guildLvl = userData.guildLevel or 0
    local bubble = self._modelMgr:getModel("PlayerTodayModel"):getBubble()
    local guildMaxLevel = bubble["b3"] or 1
    local openFunLevel = guildLvl
    if guildLvl and guildLvl > guildMaxLevel and guildLvl > 1  then 
        for i = guildLvl,guildMaxLevel+1,-1 do 
            local guildLvTab = tab:GuildLevel(i)
            if guildLvTab.open then
                openFunLevel = i
                break
            end
        end
        return true,openFunLevel
    end
end


--检测是否有新开启的联盟功能
function GuildModel:checkNewGuildFunction()
    local flag = false
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local guildLvl = userData.guildLevel or 0

    local bubble = self._modelMgr:getModel("PlayerTodayModel"):getBubble()
    local guildMaxLevel = bubble["b3"] or 1
    -- if guildLvl and guildLvl > 1 and guildLvl > guildMaxLevel then
    --     self._guildMaxLevel = guildMaxLevel
    --     self:saveAllianceOpenAction(level)
    -- end

    if guildLvl and guildLvl > guildMaxLevel and guildLvl > 1  then
        for i = guildMaxLevel+1,guildLvl do 
            local guildLvTab = tab:GuildLevel(i)
            if guildLvTab.open then
                flag = true
                break
            end
        end
    end


    -- local guildMaxLevel = self:getAllianceOpenActionLevel()
    -- if guildMaxLevel and guildMaxLevel > 1 then
    --     flag = true
    -- end

    -- local guildLvTab = tab:GuildLevel(level)
    -- if not guildLvTab.open then
    --     return
    -- end

    if guildLvl == 0 then
        flag = false
    end

    return flag
end

-- 获取邮件发送次数
function GuildModel:getSenderTimes()
    local maxNum = tab:Setting("G_GUILD_EMAIL").value
    local allianceD = self:getAllianceDetail()
    local sMailNum = allianceD.sMailNum
    local upMailTime = allianceD.upMailTime or 0
    
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if upMailTime > tempCurDayTime then
        sMailNum = allianceD.sMailNum
    else
        if curServerTime < tempCurDayTime then
            sMailNum = allianceD.sMailNum
        else
            sMailNum = 0
        end
    end
    local timesNum = maxNum - sMailNum
    return timesNum
end

--进联盟首次弹广告  wangyan
function GuildModel:checkIsAdShow()
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local showList = activityModel:getActivityShowList()
    local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local userData = self._modelMgr:getModel("UserModel"):getData()

    -- dump(showList, "showList", 10)

    if not showList then
        return
    end

    local adList = {}
    -- adList = {"guildAd_guaishouxiaowu"}
    for k,v in pairs(showList) do
        if 20 == tonumber(v.ac_type) then
            local level_limit = v.level_limit or 0
            local userLvl = userData.lvl or 0
            -- 等级限制
            if level_limit <= userLvl and v.start_time <= currTime and v.end_time > currTime then
                local revertTime = TimeUtils.formatTimeToFiveOclock(currTime)
                local lastTime = SystemUtils.loadAccountLocalData("GUILD_IS_SHOWED_AD") or 0 
                local acData = tab.activityopen[v._id]
                if revertTime - lastTime >= 86400 and acData.guildAd then
                    table.insert(adList, acData.guildAd)
                end
            end
        end
    end

    return adList
end

-- 设置联盟佣兵数据
function GuildModel:setGuildMercenary(data)
    self._guildMercenary = {}
    if data or data ~= {} then
        self._guildMercenary = data
    end
    self:refreshAllListMercenaryInfo()
end

--刷新联盟佣兵列表数据中 派遣的佣兵数据
function GuildModel:refreshAllListMercenaryInfo()
    local userid = self._modelMgr:getModel("UserModel"):getData()._id 
    local userName = self._modelMgr:getModel("UserModel"):getData().name
    -- if next(self._guildMercenaryAllList) then
    --     for k , v in pairs(self._guildMercenaryAllList["mercenaryList"]) do
    --         if v["userId"] == userid then
    --             if next(self._guildMercenary) then
    --                 for k1,v1 in pairs(self._guildMercenary["mercenaryDetails"]) do
    --                     if v["teamId"] == v1["teamId"] then
    --                         v["team"] = v1["team"]
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end
    local isIncludeFunc = function(teamData)
        if next(self._guildMercenaryAllList) then
            for k , v in pairs(self._guildMercenaryAllList["mercenaryList"]) do
                if v["userId"] == userid then
                    if v["teamId"] == teamData["teamId"] then
                        v["team"] = teamData["team"]
                        v["runes"] = teamData["runes"] or {}
                        return true
                    end
                end
            end
        end
    end
    if next(self._guildMercenary) then
        for k1,v1 in pairs(self._guildMercenary["mercenaryDetails"]) do
            if not (isIncludeFunc(v1)) then
                local listCount = 0
                if next(self._guildMercenaryAllList) == nil  then
                    self._guildMercenaryAllList["mercenaryList"] = {}
                    self._guildMercenaryAllList["mercenaryList"][1] = v1
                else
                    listCount = #self._guildMercenaryAllList["mercenaryList"]
                    self._guildMercenaryAllList["mercenaryList"][listCount + 1] = v1
                end
                self._guildMercenaryAllList["mercenaryList"][listCount + 1]["runes"] = v1["runes"] or {}
                self._guildMercenaryAllList["mercenaryList"][listCount + 1]["userId"] = userid
                self._guildMercenaryAllList["mercenaryList"][listCount + 1]["userInfo"] = {}
                self._guildMercenaryAllList["mercenaryList"][listCount + 1]["userInfo"]["name"] = userName
            end
        end
    end
end

-- 获取联盟佣兵数据
function GuildModel:getGuildMercenary()
    return  self._guildMercenary
end

-- 佣兵奖励是否可领取
function GuildModel:canGetAward()
    local can = false
    local result = self:getGuildMercenary()
    if not next(result) then return false end
    local curServerTime = self._userModel:getCurServerTime()
    local delTime
    for k,detailData in pairs(result["mercenaryDetails"]) do
        local pos = tonumber(k)
        delTime = curServerTime - detailData["setTime"]      
        local awardValue1 = math.ceil(math.floor(delTime/tab.lansquenet[pos]["time"])*detailData["per"])
        local awardValue2 = 0
        local perUse = detailData["perUse"] or 0
        if tonumber(perUse) == 0 then
            awardValue2 = detailData["sumUse"] or 0
        else
            awardValue2 = perUse*detailData["sTimes"]
        end

        if awardValue1 + awardValue2 > 100000 then
            can = true
            return can
        end
    end
    return can
end

-- 通过位置更新佣兵被雇佣的次数
function GuildModel:needUpdateMercenaryInfo(pos,sTimes,sumUse,callback)
    if next(self._guildMercenary) then
        for k,v in pairs(self._guildMercenary["mercenaryDetails"]) do
            if tonumber(k) == tonumber(pos) and tonumber(sTimes) ~= tonumber(v["sTimes"]) then
                v["sTimes"] = sTimes
                v["sumUse"] = sumUse
            end
        end
    end
    if callback then callback() end   
end 

-- 设置可雇佣的联盟佣兵列表数据
function GuildModel:setGuildMercenaryList(data)
    self._guildMercenaryList = {}
    if data or data ~= {} then
        self._guildMercenaryList = data
    end
    -- dump(data,"=========data=========")
end
--获取可雇佣的联盟佣兵列表数据
function GuildModel:getGuildMercenaryList()
    return  self._guildMercenaryList
end

--获取联盟佣兵使用次数
function GuildModel:getUseTimes(teamId,userId)
    -- dump(self._guildMercenaryList)
    if not next(self._guildMercenaryList) then
        return 1
    end
    if self._guildMercenaryList["useList"] == nil then
        return 1
    end
    if not next(self._guildMercenaryList["useList"]) then
        return 1
    end
    local tempString = userId .."#"..teamId
    for k , v in pairs(self._guildMercenaryList["useList"]) do
        if tempString == v then
            return 0
        end
    end
    return 1
end


--通过兵团id获取兵团信息
function GuildModel:getEnemyDataById(teamId, userId)
    local allMergeData = self:getMergeGuildMercenaryData()
    local useTimes = self:getUseTimes(teamId,userId)
    if not next(allMergeData) then return nil end
    if teamId then
        -- dump(allMergeData,"===========allMergeData=======")
        for k , v in pairs(allMergeData["mercenaryList"]) do
            if tonumber(teamId) == tonumber(v.teamId) and userId == v.userId  then
                local tempData = clone(v)
                tempData["team"]["teamId"] = teamId
                tempData["team"]["userName"] = v["userInfo"]["name"]
                tempData["team"]["times"] = useTimes
                -- dump(tempData,"====tempData=========")
                local tempString = userId .."#"..teamId
                -- print("=====userId and teamId======="..tempString)
                -- print("===========times============="..useTimes)
                local runes = tempData.runes or nil
                return tempData["team"] , runes
            end
        end
    end

    return nil
end


function GuildModel:getCanUseEnemyDataById(teamId, userId)
    if not next(self._guildMercenaryList) then return nil end
    if teamId then
        -- dump(self._guildMercenaryList["mercenaryList"],"mercenaryList")
        for k , v in pairs(self._guildMercenaryList["mercenaryList"]) do
            if tonumber(teamId) == tonumber(v.teamId) and userId == v.userId  then
                return v["team"]
            end
        end
    end
    return nil
end


--- 获取可雇佣的联盟佣兵
function GuildModel:getAllEnemyId()
    local enemyIdTable = {}
    if not next(self._guildMercenaryList) then return enemyIdTable end
    for k , v in  pairs(self._guildMercenaryList["mercenaryList"]) do
        local itemTable = {}
        table.insert(itemTable,v["teamId"])
        table.insert(itemTable,v["userId"])
        table.insert(enemyIdTable,itemTable)
        -- table.insert(enemyIdTable,v["teamId"])
    end
    return enemyIdTable
end

-- 设置可雇佣的联盟佣兵列表数据
function GuildModel:setGuildMercenaryAllList(data)
    self._guildMercenaryAllList = {}
    if data or data ~= {} then
        self._guildMercenaryAllList = data
    end
end

--合并佣兵数据
function GuildModel:getMergeGuildMercenaryData()
    local tempTable = self._guildMercenaryList
    -- dump(tempTable,"=======tempTable==========")
    if next(self._guildMercenaryAllList) then
        if not next(self._guildMercenaryList) then return self._guildMercenaryAllList end
        for k , v in pairs(self._guildMercenaryAllList["mercenaryList"]) do
            local hasTeam = self:getCanUseEnemyDataById(v["teamId"],v["userId"])
            if not hasTeam then
                table.insert(tempTable["mercenaryList"],v)
            end
        end
    end
    return tempTable
end

--雇佣兵是否有红点
function GuildModel:checkMercenaryRed()
    local needReturnFalse = false
    pcall(function ()
        local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
        local limitLevel = tab:SystemOpen("Lansquenet")[1]
        if tonumber(userLevel) < tonumber(limitLevel) then
            needReturnFalse = true
        end
    end)
    if needReturnFalse then return false end
    -- local hasPosNum = 3
    -- local guildMercenaryInfo = self._guildMercenary
    -- if not next(guildMercenaryInfo) then return hasPosNum > 0 end
    -- for k , v in pairs(guildMercenaryInfo["mercenaryDetails"]) do        
    --     if v["teamId"] ~= 0 then
    --         hasPosNum = hasPosNum - 1
    --     end
    -- end
    -- if hasPosNum > 0 then
    --     return true
    -- else
    --     for i = 1 , 3 do
    --         local isChange = self:checkChange(i)
    --         if isChange then return true end
    --     end
    -- end
    -- return false
    return self:isFitstShow()
end
--判断当前位置的雇佣兵是否需要替换
function GuildModel:checkChange(posIndex)
    -- print("=======posIndex======"..posIndex)
    if not next(self._guildMercenary)  then return false end
    if not next(self._guildMercenary["mercenaryDetails"]) then return false end
    local myTeamData = self._guildMercenary["mercenaryDetails"][tostring(posIndex)]
    if myTeamData == nil or myTeamData["teamId"] == 0 then return false end
    local teamId = myTeamData["teamId"]
    local myRealScore = myTeamData["team"]["score"] - myTeamData["team"]["pScore"]
    local teamData = self._modelMgr:getModel("TeamModel"):getData()
    local isHave = 0

    for k , v in pairs(teamData) do
        local teamScore = tonumber(v["score"]) - tonumber(v["pScore"])
        if teamId == v.teamId then    --首先判断自己战力
            if tonumber(myRealScore) < teamScore then
                return true    
            end
        else
            if tonumber(myRealScore) < teamScore then
                if not self:isHaveCurTeam(v["teamId"]) then
                    return true
                end
            end
        end
    end
    return false
end
--判断放置列表中是否有自己的佣兵
function GuildModel:isHaveCurTeam(teamId)
    if not next(self._guildMercenary) then return false end
    for k , v in pairs(self._guildMercenary["mercenaryDetails"]) do
        if teamId == v["teamId"] then
            return true
        end
    end
    return false
end


--判断当天是否是第一次显示
function GuildModel:isFitstShow()
    local curServerTime = self._userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("MERCENARY_IS_SHOWED_ITEM")
    if tempdate ~= timeDate then
        -- SystemUtils.saveAccountLocalData("MERCENARY_IS_SHOWED_ITEM", timeDate)
        return true
    end
    return false
end

-- 科技等级是否上限
function GuildModel:isMaxLevel(scienceId)
    local isMax = false
    local science = self:getGuildScienceById(scienceId)
    local level,exp
    if not science then
        level = 1
        exp = 0
    else
        level = science.lvl + 1
        exp = science.exp or 0
    end
    local techInfo = tab.technologyChild[scienceId]
    local guild_level = self:getAllianceDetail().level or 1
    local limit_guild_level = techInfo.limit[guild_level]
    if level > limit_guild_level then
        isMax = true
    end
    local needExp
    if isMax then
        needExp = 0
    else
        needExp = techInfo.levelexp[level] - exp
        if (level+1) < limit_guild_level then
            needExp = needExp + techInfo.levelexp[level+1]
        end
    end
    return isMax,needExp
end

--是否显示退盟评价按钮
function GuildModel:isShowQuitEvaluate()
	local isShow = false
	if self:canJoin() then
		isShow = false
	else
		--判断是否评价过
		local isEvaluate = self._userModel:isEvaluateLastGuild()
		if isEvaluate then
			isShow = false
		else
			local lastGuildName = self._modelMgr:getModel("UserModel"):getLastGuildName()
			if lastGuildName and lastGuildName~="" then
				isShow = true
			else
				isShow = false
			end
		end
	end
	return isShow
end

return GuildModel
