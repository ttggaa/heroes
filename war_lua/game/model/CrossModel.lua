--[[
    Filename:    CrossModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-15 10:53:18
    Description: File description
--]]

--[[
    "batchId"          = "20171115"     -- 赛季编号
    "group"            = 1              -- 分组索引
    "regiontype1"      = 2              -- 区域类型1
    "regiontype2"      = 5              -- 区域类型2
    "regiontype3"      = 4              -- 区域类型3
    "rt"               = 0              -- 上次刷新时间戳  这个指的是挑战镜像的刷新时间 获得奖励的
    "cdiff"            = 0              -- 每个区域已领奖的最大难度  挑战镜像的奖励  空就是没拿过
    'sec1add'; // 区服1加分
    'sec2add'; // 区服2加分

    const BATCHID = 'batchId'; //赛季编号
    const GROUPIDX = 'group'; //分组索引
    const SEC1 = 'sec1';  // 区服1
    const SEC2 = 'sec2';  // 区服2
    const SEC1SCORE = 'sec1score'; //区服1积分
    const SEC2SCORE = 'sec2score'; //区服2积分
    const SEC1REGION1SCORE = 'sec1region1score'; // 区服1区域1积分
    const SEC1REGION2SCORE = 'sec1region2score'; // 区服1区域2积分
    const SEC1REGION3SCORE = 'sec1region3score'; // 区服1区域3积分
    const SEC2REGION1SCORE = 'sec2region1score'; // 区服2区域1积分
    const SEC2REGION2SCORE = 'sec2region2score'; // 区服2区域2积分
    const SEC2REGION3SCORE = 'sec2region3score'; // 区服2区域3积分
    const SEC1ADD = 'sec1add'; // 区服1加分
    const SEC2ADD = 'sec2add'; // 区服2加分
    const SEC1REGION1ADD = 'sec1region1add'; // 区服1区域1加的分
    const SEC1REGION2ADD = 'sec1region2add'; // 区服1区域2加的分
    const SEC1REGION3ADD = 'sec1region3add'; // 区服1区域3加的分
    const SEC2REGION1ADD = 'sec2region1add'; // 区服2区域1加的分
    const SEC2REGION2ADD = 'sec2region2add'; // 区服2区域2加的分
    const SEC2REGION3ADD = 'sec2region3add'; // 区服2区域3加的分
    const REGIONTYPE1 = 'regiontype1'; // 区域类型1
    const REGIONTYPE2 = 'regiontype2'; // 区域类型2
    const REGIONTYPE3 = 'regiontype3'; // 区域类型3
    const LEAD1 = 'lead1'; // 区域1领先服务器
    const LEAD2 = 'lead2'; // 区域2领先服务器
    const LEAD3 = 'lead3'; // 区域3领先服务器
    const LEVEL1 = 'level1'; // 服务器1buff等级
    const LEVEL2 = 'level2'; // 服务器2buff等级
    const SCORE1 = 'score1'; // 服务器1历史积分
    const SCORE2 = 'score2'; // 服务器2历史积分
    const WIN1 = 'win1'; // 服务器1历史胜负
    const WIN2 = 'win2'; // 服务器2历史胜负
    const SEASONSPOT = 'seasonSpot'; // 热点竞技场类型
    const PLAYERNUM1 = 'playerNum1'; // 区服1参与玩法人数
    const PLAYERNUM2 = 'playerNum2'; // 区服2参与玩法人数
    const EXTRA1 = 'extra1'; // 区域助阵1
    const EXTRA2 = 'extra2'; // 区域助阵2
    const EXTRA3 = 'extra3'; // 区域助阵3
    const WINNER = 'winner'; // 获胜服务器
        'rt' => core_Schema::NUM, //上次刷新时间戳
        'group' => core_Schema::NUM, // 属于哪个组
        'batchId' => core_Schema::NUM, // 赛季编号
        'atkTime' => core_Schema::NUM, // 上次挑战时间
        'atkDiff' => core_Schema::NUM, // 上次挑战难度
        'atkRegion' => core_Schema::NUM, // 上次挑战区域
        'defR1' => core_Schema::NUM, // 上次被打弹版时间
        'defR2' => core_Schema::NUM, // 上次被打弹版时间
        'defR3' => core_Schema::NUM, // 上次被打弹版时间
        'cdiff' => 'AutoFieldsNum', // 每个区域已领奖的最大难度
    cha  每个竞技场第一名信息
    serTh1 区服1 前三
    serTh2 区服2 前三  
--]]


local CrossModel = class("CrossModel", BaseModel)

function CrossModel:ctor()
    CrossModel.super.ctor(self)
    self._data = {}
    self._openArena = {}
    self._enemyData = {}
    self._soloData = {}
    self._weakNpcData = {}
    self._myInfo = {}
    self._rankList = {}
    self._serverMap = {}
    self._rankTabCount = 0
    self._seasonSpot = 0
    self._activeIds = {}

    self:registerTimer(22, 2, 00, specialize(self.pushData, self))
    self:registerTimer(9, 0, 0, specialize(self.pushData, self))
    self._userModel = self._modelMgr:getModel("UserModel")
end

function CrossModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function CrossModel:setData(data)
    self._openArena = {}
    self._data = {}
    self._data = data
    self._seasonSpot = 0

    if data.myInfo then
        self._myInfo = data.myInfo
        data.myInfo = nil
    end
    if data.cha then
        self:setSoloArenaData(data)
        data.cha = nil
    end
    if data.serTh1 then
        self._serTh1 = data.serTh1
        data.serTh1 = nil
    end
    if data.serTh2 then
        self._serTh2 = data.serTh2
        data.serTh2 = nil
    end
    if data.enemy then
        local backData = self:progressData(data.enemy)
        self._enemyData = backData
        data.enemy = nil 
    end

    if data.seasonSpot then
        self._seasonSpot = data.seasonSpot
        data.seasonSpot = nil
    end

    if data.activeIds then
        self._activeIds = data.activeIds
        data.activeIds = nil
    else
        self._activeIds = {}
    end
    
    self:setHistoryData(data)

    self:updateCdiff(data)

    self:setOpenArenaData() 
    self:reflashData()

    -- -- 监听布阵数据变化更改排序
    -- self:listenReflash("FormationModel", self.refreshDataOrder)
    -- -- 监听物品数据变化更改提示状态
    -- self:listenReflash("ItemModel", self.updateTeamTips)
end

function CrossModel:setActiveData( value )
    self._activeIds = value
    self:reflashData()
end

function CrossModel:getActiveIds(  )
    return self._activeIds
end

function CrossModel:updateCdiff(data) 
    if not self._cdiff then
        self._cdiff = {}
        for i=1,3 do
            self._cdiff[i] = 0
        end
    end 
    if data.cdiff then
        for k,v in pairs(data.cdiff) do
            local indexId = tonumber(k)
            self._cdiff[indexId] = v
        end
        data.cdiff = nil
    end
end

function CrossModel:pushData()
    local crossConst = self._userModel:getCrossPKConstData()
    if crossConst.open == 0 then
        return
    end
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if weekday == 3 or weekday == 4 or weekday == 5 then
        if not SystemUtils:enableCrossPK() then   --by wangyan
            return
        end
        self._serverMgr:sendMsg("CrossPKServer", "getCrossPKInfo", {}, true, {}, function (result)
        end)
    end
end

function CrossModel:updateCrossPKInfo(data) 
    if data.myInfo then
        self:updateMyInfo(data.myInfo) 
        data.myInfo = nil
    end

    if data.enemy then
        local backData = self:progressData(data.enemy)
        self._enemyData = backData
        data.enemy = nil 
    end

    self:updateCdiff(data) 

    for k,v in pairs(data) do
        self._data[k] = v
    end
    self:reflashData()
end

function CrossModel:updateMyInfo(data) 
    local myInfo = self._myInfo
    for k,v in pairs(data) do
        myInfo[k] = v
    end
end

function CrossModel:setOpenArenaData() 
    local crossData = self._data
    local arenaData = self._openArena
    for i=1,3 do
        local regiontype = crossData["regiontype" .. i]
        if regiontype then
            arenaData[regiontype] = i
        end
    end

    local sec1 = crossData.sec1 or 1
    local sec2 = crossData.sec2 or 2
    self._serverMap[tostring(sec1)] = 1
    self._serverMap[tostring(sec2)] = 2
end

function CrossModel:setArenaData(data)
    if data.enemy then
        local backData = self:progressData(data.enemy)
        self._enemyData = backData
        data.enemy = nil 
    end
    if data.defReports then
        self._defReports = data.defReports
        data.defReports = nil
    end
    if data.myInfo then
        self:updateMyInfo(data.myInfo) 
        data.myInfo = nil
    end
end

function CrossModel:progressData(enemyData)
    local backData = enemyData
    local sortFunc = function(a, b)
        local arank = a.rank 
        local brank = b.rank 
        if arank ~= brank then
            return arank < brank
        end
    end
    table.sort(backData, sortFunc)
    return backData
end

function CrossModel:setSoloArenaData(data)
    if data.cha then
        for k,v in pairs(data.cha) do
            local key = tonumber(k)
            self._soloData[key] = v
        end
    end
end

function CrossModel:setWeakNpcData( data )
    if data.weaknpc then
        for k, v in pairs(data.weaknpc) do
            local key = tonumber(k)
            self._weakNpcData[key] = v
        end
    end
end

function CrossModel:getSeasonSpot(  )
    return self._seasonSpot or 0
end

    -- local needUpdate = self:getScoreUpdate()
function CrossModel:setJoinMainView(flag)
    self._joinMainView = flag
end

function CrossModel:getJoinMainView()
    return self._joinMainView
end

function CrossModel:setScoreUpdate()
    if self._joinMainView == true then
        if not SystemUtils:enableCrossPK() then   --by wangyan
            return
        end
        self._serverMgr:sendMsg("CrossPKServer", "getCrossPKInfo", {}, true, {}, function (result)
        end)
    end
end

function CrossModel:setPkUpdate(flag)
    self._pkUpdate = flag
    if flag == true then
        self:reflashData()
    end
end

function CrossModel:getPkUpdate()
    return self._pkUpdate or false
end


function CrossModel:getServerMap() 
    return self._serverMap
end

function CrossModel:getCdiff() 
    return self._cdiff
end

function CrossModel:setDefReport() 
    self._defReports = nil
end

function CrossModel:getDefReport() 
    return self._defReports
end

function CrossModel:getOpenArenaData() 
    return self._openArena
end

function CrossModel:getMyServerTh(serverType) 
    local serTh = self._serTh1
    if serverType == 2 then
        serTh = self._serTh2
    end
    return serTh
end

function CrossModel:getServerArenaWin() 
    local scoreMap = {}
    local sec1,sec2
    local arenaData = self:getData()
    for i=1,3 do
        sec1 = arenaData["sec1region" .. i .. "score"]
        sec2 = arenaData["sec2region" .. i .. "score"]
        scoreMap[i] = 0
        if sec1 > sec2 then
            scoreMap[i] = 1
        elseif sec1 < sec2 then
            scoreMap[i] = 2
        end
    end
    return scoreMap or {}
end

function CrossModel:getSoloArenaData(key)
    return self._soloData[key]
end

function CrossModel:getWeakNpcData( key )
    return self._weakNpcData[key]
end

function CrossModel:getEnemyData()
    return self._enemyData or {}
end

function CrossModel:getMyInfo()
    return self._myInfo or {}
end

-- 服务器id处理
-- 战区名字展示
function CrossModel:getServerName(serverId)
    serverId = tostring(serverId)
    local mergeList = self._userModel:getServerIDMap()
    local fserverId = mergeList[serverId] or serverId
    -- local serverName = self._modelMgr:getModel("LeagueModel"):getServerName(fserverId)
    local serverType = self._serverMap[fserverId] or 1
    local serverName = lang("cp_severname" .. serverType)
    return serverName, serverType, fserverId
end

-- 服务器名字获取
function CrossModel:getFightServerName(serverId)
    serverId = tostring(serverId)
    local mergeList = self._userModel:getServerIDMap()
    local fserverId = mergeList[serverId] or serverId
    local serverName = self._modelMgr:getModel("LeagueModel"):getServerName(fserverId)
    return serverName
end

function CrossModel:getServerId()
    local serverId = self._userModel:getData().sec
    serverId = tostring(serverId)
    local mergeList = self._userModel:getServerIDMap()
    local fserverId = mergeList[serverId] or serverId
    return serverId, fserverId
end

function CrossModel:isMyServer(serverId)
    local flag = false
    local sId, fserverId = self:getServerId()
    local _, _, esId = self:getServerName(serverId)
    if fserverId == esId then
        flag = true
    end
    return flag
end

-- function CrossModel:getMyServer(sec)
--     local crossData = self._data
--     local userId, mainId = self:getServerId()
--     local userSec = tostring(mainId)
--     local serverFlag = 1
--     local enemyFlag = 2
--     sec = tostring(sec)
--     local sec2 = crossData.sec2
--     -- print("sec2 == userSec =========", sec, userSec, type(sec), type(userSec) )
--     -- if sec == userSec then
--     if sec == sec2 then
--         serverFlag = 2
--         enemyFlag = 1
--     end
--     return serverFlag, enemyFlag
-- end

function CrossModel:getServerNameStr(serverId)
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

function CrossModel:getWarZoneName(isBreakServerName)
    local arenaData = self._data
    local secNum1 = arenaData["sec1"]
    local secNum2 = arenaData["sec2"]
    local secTab1 = {}
    local secTab2 = {}
    table.insert(secTab1, secNum1)
    table.insert(secTab2, secNum2)
    if isBreakServerName then
        local mergeList = self._userModel:getServerIDMap()
        for k,v in pairs(mergeList) do
            if tostring(k) ~= tostring(secNum1) and tostring(v) == tostring(secNum1) then
                table.insert(secTab1, k)
            elseif tostring(k) ~= tostring(secNum2) and tostring(v) == tostring(secNum2) then
                table.insert(secTab2, k)
            end
        end
    end

    local leagueModel = self._modelMgr:getModel("LeagueModel")
    local sNameStr1 = ""
    for i=1,#secTab1 do
        local fserverId = secTab1[i]
        local serverName = self:getServerNameStr(fserverId) or ""
        if i == table.nums(secTab1) then
            sNameStr1 = sNameStr1 .. serverName
        else
            sNameStr1 = sNameStr1 .. serverName .. " 、"
        end
    end

    local sNameStr2 = ""
    for i=1,#secTab2 do
        local fserverId = secTab2[i]
        local serverName = self:getServerNameStr(fserverId) or ""
        if i == table.nums(secTab2) then
            sNameStr2 = sNameStr2 .. serverName
        else
            sNameStr2 = sNameStr2 .. serverName .. " 、"
        end
    end

    return sNameStr1, sNameStr2
end


function CrossModel:getArenaWinner()
    local winner = self._data.winner
    return winner or 0
end

function CrossModel:isSelfWinner()
    local winner = tonumber(self:getArenaWinner())
    local userId, mainId = self:getServerId()
    local usId = tonumber(mainId)
    return usId == winner
end

-- 布阵数据处理
function CrossModel:setEnemyData(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        v.teamId = tonumber(k)
        tempData[tonumber(k)] = v
    end
    self._enemyFormationData = tempData
end

function CrossModel:getEnemyDataById(inTeamId)
    if self._enemyFormationData == nil then 
        return nil
    end
    return self._enemyFormationData[tonumber(inTeamId)]
end

function CrossModel:setEnemyHeroData(inData)
    self._enemyHeroData = inData
end

function CrossModel:getEnemyHeroData()
    if self._enemyHeroData == nil then 
        return nil
    end
    return self._enemyHeroData
end


function CrossModel:getFormationFightData(arenaType) 
    local arenaType = arenaType or 1
    local arenaData = self:getData()
    local arenaId = arenaData["regiontype" .. arenaType]
    local extra = arenaData["extra" .. arenaType]
    local textra = {}
    textra[arenaId] = 1
    for k,v in pairs(extra) do
        textra[v] = 1
    end

    local heroRace = {}
    local teamRace = {}

    for k,v in pairs(textra) do
        local cpRegionTab = tab.cpRegionSwitch[k]
        local idHero = cpRegionTab.idHero
        local idTeam = cpRegionTab.idTeam
        heroRace[idHero] = 1
        teamRace[idTeam] = 1
    end

    local lineUp = {}
    -- local heroFightId = {}
    -- local teamFightId = {}
    local heroD = tab.hero
    for k,v in pairs(heroD) do
        local hRace = v.masterytype
        if heroRace[hRace] == 1 then
            -- table.insert(heroFightId, k)
            table.insert(lineUp, k)
        end
    end

    local teamModel = self._modelMgr:getModel("TeamModel")
    for k,v in pairs(teamRace) do
        local teamData = teamModel:getTeamWithRace(k)
        for k1,v1 in pairs(teamData) do
            -- table.insert(teamFightId, v1.teamId)
            table.insert(lineUp, v1.teamId)
        end
    end
    return lineUp
end


-- 时间处理
function CrossModel:getOpenTime() 
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 0:00:00"))
    local lastTime = tTime - (weekday-1)*86400

    local speedTime = {}
    speedTime[0] = lastTime           -- 赛季开始
    speedTime[1] = lastTime + 3600*5            -- 赛季开始
    speedTime[2] = lastTime + 86400*2 + 3600*9  -- 战斗开始
    speedTime[3] = lastTime + 86400*4 + 3600*22 + 120 -- 战斗结束
    speedTime[4] = lastTime + 86400*7           -- 赛季结束
    speedTime[5] = lastTime + 86400*7 + 3600*5  -- 维护试卷
    return speedTime
end

-- 1 赛季开始前
-- 2 战斗中
-- 3 赛季结束
-- 4 维护中
function CrossModel:getOpenState() 
    local curServerTime = self._userModel:getCurServerTime()
    local speedTime = self:getOpenTime() 
    local state = 0
    if (curServerTime > speedTime[0]) and (curServerTime < speedTime[1]) then
        state = 4
    elseif (curServerTime > speedTime[1]) and (curServerTime < speedTime[2]) then
        state = 1
    elseif (curServerTime > speedTime[2]) and (curServerTime < speedTime[3]) then
        state = 2
    elseif (curServerTime > speedTime[3]) and (curServerTime < speedTime[4]) then
        state = 3
    elseif (curServerTime > speedTime[4]) and (curServerTime < speedTime[5]) then
        state = 4
    end
    return state
end

function CrossModel:getCloseCrossPK() 
    return true
end

-- 0 功能关闭
-- 1 等级满足   时间不满足
-- 2 等级不满足 时间满足
-- 3 等级不满足 时间不满足
-- 4 等级满足   时间满足
-- 5 维护中
-- 6 未匹配成功
function CrossModel:getOpenActionState() 
    local state = 0
    if self:getCloseCrossPK() == false then
        return state
    end

    local tstate = self:getOpenState()
    local userData = self._userModel:getData()
    local level = self._userModel:getPlayerLevel()
    local serverBeginTime = userData.sec_open_time or 0
    local nowTime = self._userModel:getCurServerTime()
    local crossTab = tab:STimeOpen(105)

    if serverBeginTime then
        local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime,"%Y-%m-%d 05:00:00"))
        if serverBeginTime < sec_time then   --过零点判断
            serverBeginTime = sec_time - 86400
        end
    end

    local openLevel = crossTab.level
    local openTime = crossTab.opentime
    local openHour = crossTab.openhour

    local openDay = openTime-1
    local openHourStr = string.format("%02d:00:00",openHour)
    local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverBeginTime + openDay*86400,"%Y-%m-%d " .. openHourStr))

    local lOpen = 0
    local sOpen = 0
    if level >= openLevel then
        lOpen = 1
    end
    if nowTime >= openTime then
        sOpen = 1
    end

    if lOpen == 1 and sOpen == 0 then
        state = 1
    elseif lOpen == 0 and sOpen == 1 then
        state = 2
    elseif lOpen == 0 and sOpen == 0 then
        state = 3
    elseif lOpen == 1 and sOpen == 1 then
        state = 4
    end
    if state == 4 and tstate == 4 then
        state = 5
    end
    local crossConst = self._userModel:getCrossPKConstData()
    if crossConst.open == 0 and state == 0 then
        return 6
    end
    return state 
end

function CrossModel:getOpenConditionsStr(state) 
    local tstate = self:getOpenState()
    local userData = self._userModel:getData()
    local level = self._userModel:getPlayerLevel()
    local serverBeginTime = userData.sec_open_time or 0
    local nowTime = self._userModel:getCurServerTime()
    local crossTab = tab:STimeOpen(105)

    local lOpen = 0
    local sOpen = 0
    if level >= crossTab.level then
        lOpen = 1
    end
    if nowTime >= serverBeginTime then
        sOpen = 1
    end

    return state 
end

-- 该弹窗弹窗
-- 0 无弹窗
-- 1 挑战弹窗
-- 2 开始弹窗
-- 3 结算弹窗
function CrossModel:getDialogState() 
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 0:00:00"))
    local lastTime = tTime - (weekday-1)*86400

    local speedTime = {}
    speedTime[1] = lastTime + 3600*5            -- 赛季开始
    speedTime[2] = lastTime + 86400*2 + 3600*22 + 300     -- 战斗开始 周三
    speedTime[3] = lastTime + 86400*3 + 3600*5      -- 战斗开始     
    speedTime[4] = lastTime + 86400*3 + 3600*22 + 300    -- 战斗结束
    speedTime[5] = lastTime + 86400*4 + 3600*5      -- 战斗结束
    speedTime[6] = lastTime + 86400*4 + 3600*22      -- 赛季战斗结束  结算界面弹出世间额外增加2分钟，防止结算数据不准确
    speedTime[7] = lastTime + 86400*7            -- 赛季结束

    local state = 0
    if (curServerTime > speedTime[1]) and (curServerTime < speedTime[6]) then
        state = 2
    elseif (curServerTime > speedTime[6]) and (curServerTime < speedTime[7]) then
        state = 3
    end

    local fightState = 0
    if (curServerTime > speedTime[2]) and (curServerTime < speedTime[3]) then
        fightState = 1
    elseif (curServerTime > speedTime[4]) and (curServerTime < speedTime[5]) then
        fightState = 1
    end
    return fightState, state
end

function CrossModel:getSoloEnemyData() 
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 0:00:00"))
    local lastTime = tTime - (weekday-1)*86400

    local speedTime = {}
    speedTime[1] = lastTime + 86400*2 + 3600*22 + 300     -- 战斗开始
    speedTime[2] = lastTime + 86400*3 + 3600*22      -- 战斗开始
    speedTime[3] = lastTime + 86400*3 + 3600*22 + 300    -- 战斗结束
    speedTime[4] = lastTime + 86400*4 + 3600*22      -- 战斗结束

    local state = 0
    if (curServerTime > speedTime[1]) and (curServerTime < speedTime[2]) then
        state = 1
    elseif (curServerTime > speedTime[3]) and (curServerTime < speedTime[4]) then
        state = 1
    end
    return state
end

function CrossModel:getIsOtherDay(  )
    local curTime = self._userModel:getCurServerTime()
    local showTime = SystemUtils.loadAccountLocalData("CROSS_PRI_TIME")
    if showTime then
        if TimeUtils.checkIsOtherDay(showTime, curTime) then
            SystemUtils.saveAccountLocalData("CROSS_PRI_TIME", curTime)
            return true
        end
    else
        SystemUtils.saveAccountLocalData("CROSS_PRI_TIME", curTime)
        return true
    end
    return false
end

function CrossModel:getCrossMainOpenDialog()
    local _, state = self:getDialogState() 
    if state == 0 then
        return false
    end

    local function check(  )
        local batchId = self._data.batchId or ""
        batchId = batchId .. state

        local tempdate = SystemUtils.loadAccountLocalData("CROSSPK_BegDialog")
        if tempdate ~= batchId then
            print("CROSSPK_BegDialog", batchId)
            return true
        end
        return false
    end

    local batchId = self._data.batchId or ""
    if batchId == "" or self:getIsOtherDay() then
        if not SystemUtils:enableCrossPK() then   --by wangyan
            return false
        end
        self._serverMgr:sendMsg("CrossPKServer", "getCrossPKInfo", {}, true, {}, function (result)
            return check()
        end)
    else
        return check()
    end
    
end

function CrossModel:setCrossMainOpenDialog()  
    local _, state = self:getDialogState() 
    local tempdate = SystemUtils.loadAccountLocalData("CROSSPK_BegDialog")
    local batchId = self._data.batchId or ""
    batchId = batchId .. state
    print("batchId============", tempdate, batchId)
    if tempdate ~= batchId then
        print("CROSSPK_BegDialog", batchId)
        SystemUtils.saveAccountLocalData("CROSSPK_BegDialog", batchId)
    end
end


function CrossModel:getCrossMainDialog()
    local state = self:getDialogState() 
    if state ~= 1 then
        return false
    end
    local userModel = self._userModel
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("CROSSPK_DeclareDialog")
    if tempdate ~= timeDate then
        print("CROSSPK_DeclareDialog", timeDate)
        return true
    end
    return false
end

function CrossModel:setCrossMainDialog()  
    local userModel = self._userModel
    local curServerTime = userModel:getCurServerTime()
    local timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    local tempdate = SystemUtils.loadAccountLocalData("CROSSPK_DeclareDialog")
    print("tempdate============", type(tempdate), type(timeDate))
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    if tempdate ~= timeDate then
        print("CROSSPK_DeclareDialog", timeDate)
        SystemUtils.saveAccountLocalData("CROSSPK_DeclareDialog", timeDate)
    end
end




function CrossModel:getShowStr() 
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 0:00:00"))
    local lastTime = tTime - (weekday-1)*86400

    local speedTime = self:getOpenTime() 

    local begTime = speedTime[2]
    local endTime = speedTime[3]
    local month = TimeUtils.getDateString(begTime,"%m")
    local day = TimeUtils.getDateString(begTime,"%d")
    local begStr = month .. "月" .. day .. "日"
    local month = TimeUtils.getDateString(endTime,"%m")
    local day = TimeUtils.getDateString(endTime,"%d")
    local endStr = month .. "月" .. day .. "日"
    local showStr = begStr .. "-" .. endStr
    return showStr 
end

-- 排行榜处理
function CrossModel:getRankNextStart()
    return #self._rankList+1
end

function CrossModel:getRankList()
    return self._rankList
end

function CrossModel:setRankList(inData)
    if not inData then return end
    -- dump(inData,"======")
    if inData.rankList then
        for k,v in pairs(inData.rankList) do
            if v and type(v) == "table" and v.rank then
                self._rankList[tonumber(v.rank)] = v
            end
        end
    end
    --自己的排行榜
    if (self._curStart == 1) or (inData.owner and next(inData.owner) ~= nil) then
        self._selfRankInfo = inData.owner
    end
end

function CrossModel:getSelfRankInfo()
    return self._selfRankInfo or {}
end

function CrossModel:clearRankList()
    self._rankList = {}
    self._rankTabCount = 0
end

-- 设置默认的排行类型和起始位
function CrossModel:setRankTypeAndStartNum( tp,start )
    self._curType,self._curStart = tp or 1,start or 1
end


-- 镜像红点
function CrossModel:getSoloTip(arenaType)
    local tflag = false
    local cdiff = self:getCdiff()
    local diffNum = cdiff[arenaType]
    if diffNum ~= 0 then
        tflag = true
    end
    return tflag
end

--是否有可领的活跃奖励
function CrossModel:isActiveAward(  )

    local function check(  )
        local result = false
        local activeCfg = clone(tab.cpActiveReward)
        local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
        local chanNum = dayinfo["day76"] or 0
        local activeIds = self:getActiveIds()
        for k, v in pairs(activeCfg) do
            local condition = v.condition
            if tonumber(chanNum) >= tonumber(condition) then
                if not activeIds[tostring(v.id)] then
                    return true
                end
            end
        end
        return false
    end

    local batchId = self._data.batchId or ""
    if batchId == "" or self:getIsOtherDay() then
        if not SystemUtils:enableCrossPK() then   --by wangyan
            return false
        end
        self._serverMgr:sendMsg("CrossPKServer", "getCrossPKInfo", {}, true, {}, function (result)
            return check()
        end)
    else
        return check()
    end

    
end

-- 主界面气泡
function CrossModel:getMainViewTip()
    local tflag = false
    local crossConst = self._userModel:getCrossPKConstData()
    if crossConst.open == 0 then
        return tflag
    end
    tflag = self:getCrossMainDialog() 
    if tflag == false then
        local _, state = self:getDialogState() 
        -- 结算
        if state == 3 then
            tflag = self:getCrossMainOpenDialog()
        end
    end

    --判断活跃奖励
    if tflag == false then
        if self:isActiveAward() then
            tflag = true
        end
    end
    return tflag
end


-- 红点
function CrossModel:getCrossMainTip()
    -- local tflag = false
    -- local _, state = self:getDialogState() 
    -- if state == 2 then
    --     local flag = self:getCrossMainOpenDialog()
    --     if flag == true then
    --         tflag = true
    --     end
    -- elseif state == 3 then
    --     local flag = self:getCrossMainOpenDialog()
    --     if flag == true then
    --         tflag = true
    --     end
    -- end
    -- local tflag = self:getCrossMainDialog() 
    local tflag = self:getMainViewTip() 
    return tflag
end

-- 气泡
function CrossModel:getCrossMainQipao()
    local flag = false
    local fightState = self:getOpenState() 
    if fightState == 2 then
        local freeTimes = tab:Setting("CROSSPK_FIGHTCOUNT_FREE").value
        local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
        local day76 = dayinfo["day76"] or 0
        local day77 = dayinfo["day77"] or 0
        local haveTimes = freeTimes - day76 + day77
        if haveTimes ~= 0 then
            flag = true
        end
    end
    return flag
end

-- 0 没有
-- 1 红点
-- 2 气泡
function CrossModel:getCrossMainState()
    local state = 0
    if self:getCloseCrossPK() == false then
        return state
    end
    local crossConst = self._userModel:getCrossPKConstData()
    if crossConst.open == 0 then
        return state
    end

    local qipao = self:getCrossMainQipao()
    if qipao == true then
        state = 2
    else
        local tip = self:getCrossMainTip()
        if tip == true then
            state = 1
        end
    end
    return state
end

function CrossModel:setHistoryData(data)
    self._historyData = {
        [1] = { level = data.level1, score = data.score1, win = data.win1 },
        [2] = { level = data.level2, score = data.score2, win = data.win2 },
    }
end

function CrossModel:getHistoryData()
    return self._historyData
end

function CrossModel:updateRegionPrompt( region )
    local batchId = self._data.batchId or ""
    if batchId == "" then
        return
    end
    SystemUtils.saveAccountLocalData("CROSSPK_REGION_PROMPT_" .. region, batchId)
end

function CrossModel:getRegionPrompt( region )
    local batchId = SystemUtils.loadAccountLocalData("CROSSPK_REGION_PROMPT_" .. region)
    local currBatchId = self._data.batchId or ""
    local state = self:getOpenState()
    if batchId == currBatchId and state == 2 then
        return true
    end
    return false
end

function CrossModel:removeRegionPrompt( region )
    SystemUtils.saveAccountLocalData("CROSSPK_REGION_PROMPT_" .. region, "1")
end

--王国联赛是否可以扫荡  by:haotaian
function CrossModel:canSweepBattle()
    local can = false
    if self._myinfo then
        for i=1,3 do
            if self._myinfo["rank"..i] ~= 0 then
                can = true
                break
            end
        end
    end
    return can
end

return CrossModel