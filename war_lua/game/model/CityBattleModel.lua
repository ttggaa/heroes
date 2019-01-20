--[[
    Filename:    CityBattleModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-12-08 14:51:09
    Description: File description
--]]
--[[
    citybattle结构：
    m   主区id
    b   "b" = {
            "e1" = "4"  e1对应id 1的总经验，根据经验计算等级
            "e2" = "32"
        }
    c   城池结构
        1到30    城池id
            m   是否是主城
            l   等级
            bl  血量
            b   属于哪一方
            le  领袖
            let 领袖类型
            len 领袖排名
            an和dn是攻方和守方的人数
            as和ds是攻方和守方的战力
        co 1 红 2 蓝 3 绿

    f
      编组id
        3:{
            cd  cd时间
            cid 所在城池id
            i   当前位置   i = -1时代表死亡，cd时间启用
            w   最大连胜数
            p   积分
        }

      "u" = {
                 "box" = {  已领取宝箱id >1 为已领取
                     "1" = 1
                     "2" = 1
                     "3" = 1
                     "4" = 1
                 }
                 "cnt" = 1855        已建造次数
                 "r"   = 9999814599   --/100 可建造次数
             }
        }
    "san": {
        "8001": 1
    },
    "sdn": {
        "npc": 132,
        "8002": 24,
        "8001": 24
    }

    days  --最短的开始时间

    


进入房间
current  当前播放的战报
c    当前城的数据
atk 所有攻方玩家
def 所有防方玩家
bf  当前战场内每个区的buff

]]
local TimeUtils = TimeUtils
local os = os
local __curStatus
local __curWeek
local __curTimeDes 
local __overTime
local tonumber = tonumber
local tostring = tostring
local socketTimeFun = socket.gettime


local battleName = {
    "赤焰",
    "碧蓝",
    "苍星"
}

local CityBattleModel = class("CityBattleModel", BaseModel)

require "game.view.citybattle.CityBattleConst"

function CityBattleModel:ctor()
    CityBattleModel.super.ctor(self)
    self._data = {}  -- 服务器数据
    self._readlyData = {} -- 备战数据
    
    self._gvgServerNum = 2 -- 服务器数量
    self._userModel = self._modelMgr:getModel("UserModel")
    local map = self._userModel:getServerIDMap()
    local minID = map[tostring(GameStatic.sec)]
    local sec = minID and tonumber(minID) or tonumber(GameStatic.sec)
    self._sec = tostring(sec)
    -- self:initReadlyData()
    -- self:initUserData()
    self._leftBuildTimes = 0  --剩余建造次数
    self._haveBuildTimes = 0  -- 已建造次数
    self._getedBoxList = {} -- 已领取的宝箱id
    self._isReceiveLoginResult = false --标记是否已收到10001

    self._events = {}
    self._sendCallback = {}
    self._readyReward = {} -- 已领取的宝箱id 对应self._data["u"]["box"]
    self._gvgUserData = {} -- 玩家身上的数据 对应self._data["u"]["cb"]

    self._battleCityStates = {}
    
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")

    self._formationWithIndex = {}

    self._watchLeaveList = {} --观战中撤离的编组数据

    for i=1,4 do
        local fid = self._formationModel["kFormationTypeCityBattle" .. i]
        self._formationWithIndex[fid] = i
    end

    self._pushId = 0 -- 服务端push顺序ID

    self._stopReadyBuild = false

    self:registerTimer(0, 0, 0, function ()
        self:initTimeStatus()
    end)
    self:registerTimer(5, 0, 0, function ()
        self:initTimeStatus()
    end)
    self:registerTimer(20, 45, 0, function ()
        self:initTimeStatus()
    end)
    self:registerTimer(20, 0, 0, function ()
        self:initTimeStatus()
    end)
    self:registerTimer(19, 45, 0, function ()
        self:initTimeStatus()
    end)

    -- self:registerTimer(21, 35, 5, function ()
    --     self:reflashData("CheckResult")
    -- end)

    self:initTimeStatus()
end


--[[
    时间状态初始化一次，定点更新最新状态
]]
function CityBattleModel:initTimeStatus()
    self:initOverTime()
    local state = 0
    local timeDes = "s1"
    local currTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", currTime))
    if weekday == 0 then
        weekday = 7
    end
    local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime,s7OverTime = self:getOverTime()
    print("initTimeStatus",s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime,s7OverTime)
    if currTime >= s5OverTime and currTime < s6OverTime     then
        state = 1
        timeDes = "s6"
    elseif currTime >= s1OverTime and currTime < s2OverTime then
        state = 0 
        timeDes = "s2"
    elseif currTime >= s2OverTime and currTime < s3OverTime then
        state = 1
        timeDes = "s3"
    elseif currTime >= s3OverTime and currTime < s4OverTime then
        state = 1
        timeDes = "s4"
    elseif currTime >= s4OverTime and currTime < s5OverTime then
        state = 1
        timeDes = "s5"
    elseif currTime >= s7OverTime and currTime < s1OverTime then
        state = 0
        timeDes = "s1"
    elseif currTime >= s6OverTime or currTime < s7OverTime then
        state = 2
        timeDes = "s7"
    else
        print("CityBattleModel:getState worng status")
    end
    __curStatus = state
    __curWeek = weekday
    __curTimeDes = timeDes
end
--[[
    更新时间结束点
]]


function CityBattleModel:initOverTime()
    __overTime = {}

    local currTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", currTime))
    local add = weekday == 0 and 0 or (7-weekday)*86400
    local timeOver = currTime + add
    -- local t1 = TimeUtils.date("*t", timeOver)
    local s6OverTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeOver,"%Y-%m-%d 24:00:00"))
    -- local s6OverTime = os.time({year = t1.year, month = t1.month, day = t1.day, hour = 24, min = 00, sec = 00})
    local s5OverTime = s6OverTime - 11700
    local s4OverTime = s5OverTime - 2700
    local s3OverTime = s4OverTime - 83700
    local s2OverTime = s3OverTime - 2700
    local s1OverTime = s2OverTime - 900
    local s7OverTime = s1OverTime - 139500
    print(s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime,s7OverTime)
    __overTime.s1OverTime = s1OverTime
    __overTime.s2OverTime = s2OverTime
    __overTime.s3OverTime = s3OverTime
    __overTime.s4OverTime = s4OverTime
    __overTime.s5OverTime = s5OverTime
    __overTime.s6OverTime = s6OverTime
    __overTime.s7OverTime = s7OverTime
end

function CityBattleModel:dtor()
    TimeUtils = nil
    os = nil
    __curStatus = nil
    __curWeek = nil
    __curTimeDes = nil 
    __overTime = nil
    tonumber = nil
    tostring = nil
end


-- 初始化备战数据
function CityBattleModel:initReadlyData(serverList)
    local data = {}
    for i=1,6 do
        local k = "e" .. i
        data[k] = 0
    end
    for server,_ in pairs (serverList) do 
        self._readlyData[server] = data
    end
end

--[[{
    e1 = 1,
    e2 = 1,
}--]]
function CityBattleModel:resetReadlyData(data)
    if not data then
        return
    end
    for k,value in pairs (data) do 
        self._readlyData[self._sec][k] = value
    end
end

function CityBattleModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function CityBattleModel:setData(data)
    -- dump(data,"CityBattleModel:setData",10)

    self:initReadlyData(data["c"]["co"])

    if data["c"] and data["c"]["b"] ~= nil then
        self:updateReadlyData(data["c"]["b"])
        data["c"]["b"] = nil
    end    
    self._data = data

    -- 优先根据人数判断好是否在战斗中，方便后续更新
    for k,v in pairs(self._data["c"]["c"]) do

        self:handleCityBattleStatus(k, v)
    end

    if data["u"] ~= nil then
        self._gvgUserData = data["u"]
        if data["u"]["box"] ~= nil then
            self._readyReward = data["u"]["box"]
        end
        self:reflashData("ReadyDataChange")
    end
    -- dump(data['f'], "test", 10)
    if self._data["f"] == nil then 
        self._data["f"] = {}
    end

    -- dump(self._data,"aaaaaaaaaa",10)
    --编组数量整合
    if not self._data["san"] then
        self._data["san"] = {} 
    end
    if not self._data["sdn"] then
        self._data["sdn"] = {}
    end
    if not self._data["tn"] then
        self._data["tn"] = {}
    end
    for sec,data in pairs (self._data["c"]["co"]) do 
        local taNum = self._data["san"][sec] or 0
        local tdNum = self._data["sdn"][sec] or 0
        self._data["tn"][sec] = taNum + tdNum
    end

end

function CityBattleModel:updateData(data)
    local function updateSubData(inSubData, inUpData)
        local backData
        if type(inSubData) == "table" and next(inSubData) ~= nil then
            for k,v in pairs(inUpData) do
                if type(v) == "table" and next(v) ~= nil then 
                    backData = updateSubData(inSubData[k], v)
                else
                    backData = v
                end
                inSubData[k] = backData
            end

            return inSubData
        else 
            return inUpData
        end
    end

    local backData 
    for k,v in pairs(data) do
        backData = updateSubData(self._data[k], v)
        self._data[k] = backData
    end
    -- dump(self._data["c"], "updateData", 10)
    return backData
end



function CityBattleModel:setMapId(mapId)
--    print("=====================" .. mapId)
    self._mapId = mapId
end

function CityBattleModel:getMapId()
    return self._mapId
end 

-- function CityBattleModel:setBuildUserData(result)
--     --可建造次数
--     if result["r"] then
--         self._leftBuildTimes = tonumber(result["r"])/100
--     end
--     --已建造次数
--     if result["cnt"] then
--         self._haveBuildTimes = tonumber(result["cnt"])
--     end

--     --已领取宝箱id 
--     self._readyReward = {}
--     if result["box"] then
--        for boxId,value in pairs (result["box"]) do 
--            if tonumber(value) >= 1 then
--             table.insert(self._readyReward,tonumber(boxId))
--            end
--        end
--     end

-- end

function CityBattleModel:updateReadyBoxDataAfterGet(id) 
    self._readyReward[tostring(id)] = 1
end

function CityBattleModel:getLeftBuildTimes()
    return self._gvgUserData.r and math.floor(self._gvgUserData.r/100) or 0
end

function CityBattleModel:getHaveBuildTimes()
    return self._gvgUserData.cnt or 0
    -- return self._haveBuildTimes or 0
end

function CityBattleModel:getReadyRewardsData()
    return {}
end

function CityBattleModel:checkIsGetById(id)
    if self._readyReward[tostring(id)] == nil then return false else return true end
end

-- 获取城池数据
function CityBattleModel:getCityAllData()
    return self._data["c"]["c"]
end

-- 获取服务器城市数据
function CityBattleModel:getServerCityData()
    local serverNum = self:getCityServerList()
    local serverData = {}
    for i=1,table.nums(serverNum) do
        serverData[i] = self:progressCityData(serverNum[i].sec)
    end
    -- dump(serverData,"serverData",10)
    return serverData
end

-- 获取服务器有几个城
function CityBattleModel:progressCityData(serverNum)
    local cityData = {}
    local cityNum = 0
    local atkNum = 0
    local defNum = 0
    for k,v in pairs(self._data["c"]["c"]) do
        if v.b == serverNum then
            cityNum = cityNum + 1
            atkNum = atkNum + v.an
            defNum = defNum + v.dn
        end
    end
    cityData.cityNum = cityNum
    cityData.atkAllNum = tonumber(self:getServerAtkNum(serverNum))
    cityData.atkNum = atkNum
    cityData.defNum = defNum
    -- cityData.allTeamNum = atkNum + defNum

    -- if not self._data["san"] then self._data["san"] = {} end
    -- local teamNum = 0
    -- for sec,num in pairs (self._data["san"]) do 
    --     if sec == serverNum then
    --         teamNum = teamNum + num
    --     end
    -- end
    -- if not self._data["sdn"] then self._data["sdn"] = {} end
    -- for sec,num in pairs (self._data["sdn"]) do 
    --     if sec == serverNum then
    --         teamNum = teamNum +num
    --     end
    -- end

    -- dump(self._data["san"],"san",10)
    -- dump(self._data["sdn"],"sdn",10)
    local tNum = self._data["tn"][serverNum] or 0
    cityData.allTeamNum = tNum
    return cityData
end

-- 获取服务器派遣人数
function CityBattleModel:getServerAtkNum(serverNum)
    local atkAllNum = 0
    if self._data["c"] and self._data["c"]["sendNum"] then
        atkAllNum = self._data["c"]["sendNum"][tostring(serverNum)] or 0
    end
    return atkAllNum
end

-- 根据id获取城池数据
function CityBattleModel:getCityDataById(cityId)
    local cityData = {}
    if self._data["c"] and self._data["c"]["c"] then
        cityData = self._data["c"]["c"][tostring(cityId)]
    end
    return cityData
end

function CityBattleModel:setReadyBuild(status)
    self._stopReadyBuild = status
end

function CityBattleModel:getReadBuildStatus()
    return self._stopReadyBuild
end

-- 判断城池是否属于自己
function CityBattleModel:isCitySelf(cityId)
    local flag = false
    local cityData = self:getCityDataById(cityId)
    local userServer = self._modelMgr:getModel("UserModel"):getData().sec
    if userServer == cityData["b"] then
        flag = true
    end
    return flag
end

-- 根据id判断城池是否可派遣
function CityBattleModel:getCityDispatchDataById(cityId)
    local userServer = self._modelMgr:getModel("UserModel"):getData().sec
    local flag = self:isCitySelf(cityId)
    if flag == false then
        local cityTab = tab:CityBattle(cityId)
        if cityTab and cityTab.nearby then
            for k,v in pairs(cityTab.nearby) do
                flag = self:isCitySelf(v)
                if flag == true then
                    break
                end
            end
        end
    end
    return flag
end

-- 获取匹配到的服务器
function CityBattleModel:getCityServerList()
    local cityData = {}
    local myIndex
    local blueIndex

    local temp = {}
    if self._data["c"] and self._data["c"]["co"] then
        for k,v in pairs(self._data["c"]["co"]) do
            local data = {}
            data.color = v
            data.sec = k
            if k == self._sec then
                data.rank = 5
            elseif v == 2 then
                data.rank = 4
            elseif v == 1 then
                data.rank = 3 
            elseif v == 3 then
                data.rank = 2
            else
                data.rank = 1
            end
            table.insert(temp,data)
        end
    end
    table.sort(temp,function(a,b)
        return a.rank > b.rank
    end)

    for k,data in pairs (temp) do 
        cityData[k] = data
    end

    -- dump(temp)
    -- if  myIndex then
    --     local temp = cityData[1]
    --     cityData[1] = cityData[myIndex]
    --     cityData[myIndex] = tempData[1]
    -- end
    return cityData
end


-- 更新gvg 玩家数据
function CityBattleModel:updateGVGUserData(data)
    if data["a"] then
        for k1,v1 in pairs(data["a"]) do
            self._gvgUserData["a"][tonumber(k1)] = v1
        end
        data["a"] = nil
    end

    for k,v in pairs(data) do
        self._gvgUserData[k] = v
    end
end


-- 删除排除的编组
function CityBattleModel:handelUnsetCityBattle(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        if string.find(k, ".") ~= nil then
            local temp = string.split(k, "%.")
            tempData[temp[3]] = temp[4]
        end
    end
    return tempData
end

-- 删除编组
function CityBattleModel:retreatFormation(tempData)
    -- for kk,vv in pairs(tempData) do
    --     if self._gvgUserData["c"] and self._gvgUserData["c"][kk] and self._gvgUserData["c"][kk][vv] then
    --         self._gvgUserData["c"][kk][vv] = nil
    --     end
    -- end

    -- for kk,vv in pairs(tempData) do
    --     for k,v in pairs(self._gvgUserData["c"]) do
    --         if tonumber(kk) == tonumber(k) then
    --             for k1,v1 in pairs(v) do
    --                 if k1 == vv then
    --                     self._gvgUserData["c"][kk][vv] = nil
    --                     break
    --                 end
    --             end
    --         end
    --     end
    -- end
    -- self:updateGVGFmdFightData()
end

-- 更新服务器数据
function CityBattleModel:updateCityData(data)
    -- dump(data,"ityBattleModel:updateCityData",10)
    -- 更新城市数据
    if data["c"] ~= nil then
        for k,v in pairs(data["c"]) do
            for k1,v1 in pairs(v) do
                self._data["c"]["c"][k][k1] = v1
            end
        end
    end

    -- 更新服务器人数
    if data["sendNum"] ~= nil then
        for k,v in pairs(data["sendNum"]) do
            if self._data["c"]["sendNum"] == nil then
                self._data["c"]["sendNum"] = {}
            end
            self._data["c"]["sendNum"][k] = v
        end
    end
    -- self:reflashData("ServerNum") -- 更新CityBattleView:reflashServerNum()
    self:reflashData()
end


-- 更新备战数据
function CityBattleModel:updateReadlyData(data)
    if data == nil then
        return
    end
    -- dump(data)
    for serverId,buildData in pairs(data) do
        if not self._readlyData[tostring(serverId)] then
            self._readlyData[tostring(serverId)] = {}
        end
        self._readlyData[tostring(serverId)] = buildData
        -- if buildData and type(buildData) == "table" then
        --     for key,value in pairs (buildData) do 
        --         if not self._readlyData[tostring(serverId)] then
        --             self._readlyData[tostring(serverId)] = {}
        --         end
        --         self._readlyData[tostring(serverId)][key] = value
        --     end
        -- end
    end
    -- dump(self._readlyData)
end

function CityBattleModel:updateReadyDataAfterDone(result)
    if result["c"] then
        local data = self._readlyData[self._sec]
        for key,value in pairs (result["c"]) do 
            data[key] = value
        end
    end

    if result["u"] and result["u"]["cb"] then
        if result["u"]["cb"]["cnt"] then
            self._gvgUserData.cnt = result["u"]["cb"]["cnt"]
        end
        if result["u"]["cb"]["r"] then
            self._gvgUserData.r = result["u"]["cb"]["r"]
        end
    end
    self:reflashData("BuildDone")
end

-- --[[
-- --! @function updateGVGFmdFightData
-- --! @desc 转换c结构下城池对应编组为分组对应城市
-- --! @param inData table 追加数据集合
-- --! @return table
-- --]]
-- function CityBattleModel:updateGVGFmdFightData()
--     local gvgUD = self._gvgUserData -- self:getGVGUserData()
--     self._tform = {}
--     for k,v in pairs(gvgUD["c"]) do
--         for k1,v1 in pairs(v) do
--             self._tform[tonumber(k1)] = tonumber(k)
--         end
--     end
-- end

function CityBattleModel:getSendNum()
    return self._data["c"]["sendNum"]
end

-- -- 获取兵团派遣数据
-- function CityBattleModel:getGVGFmdFightData()
--     if not self._tform then
--         self:updateGVGFmdFightData()
--     end
--     return self._tform
-- end

-- 获取玩家数据
function CityBattleModel:getGVGUserData()
    return self._gvgUserData
end

-- 获取备战数据
function CityBattleModel:getReadlyData()
    return self._readlyData
end

-- 备战等级
function CityBattleModel:getReadlyLevel(sec)
    local leidaData = {
        [1] = 1, 
        [2] = 1, 
        [3] = 1, 
        [4] = 1, 
        [5] = 1, 
        [6] = 1, 
    }
    local sec_ = sec and tostring(sec)

    -- local function mathF(x)
    --     return 20*x/(x+10)
    -- end

    local curServerData 
    if sec_ then
        curServerData = self._readlyData[sec_] or {}
    else
        curServerData = {}
    end
    for i=1,6 do 
        if not curServerData["e"..i] then
            curServerData["e"..i] = 0
        end
    end
    -- dump(curServerData)
    for i=1,6 do
        local key = "e" .. i
        local exp = tonumber(curServerData[key])
        if exp then
            local tabData = tab:CityBattlePrepare(i)
            local tabExp = tabData.exp
            local lvlLimit = tabData.maxlv 
            local lvl = 1
            local n = 1
            local needExp = 0
            while true do 
                if lvl + 1 > lvlLimit then
                    break
                end
                needExp = needExp + tabExp[n]
                if exp >= needExp then
                    lvl = lvl + 1
                else
                    break
                end
                n = n + 1
            end
            -- leidaData[i] = mathF(lvl)
            leidaData[i] = lvl
        end
    end
    -- dump(leidaData)
    -- leidaData = {8,8,8,8,8,8}
    return leidaData
end

-- 缓存备战宝箱数据
function CityBattleModel:setReadyBoxData()

end

function CityBattleModel:getBoxData()

end
--[[
 周五 5:00   -  周六 19:45  备战              state: 0   timeDes:s1 php 城池重置状态
 周六 19:45  -  周六 20:00  战前准备          state: 0   timeDes:s2 php 城池重置状态
 周六 20:00  -  周六 20:45  开战              state: 1   timeDes:s3 java
 周六 20:45  -  周日 20:00  战后结算期        state: 1   timeDes:s4 java
 周日 20:00  -  周日 20:45  开战              state: 1   timeDes:s5 java
 周日 20:45  -  周一 00:00  战后结算期        state: 1   timeDes:s6 java
 周一 00:01  -  下周五 5:00 休战(赛季结算期)  state: 2   timeDes:s7 php 城池状态

     s7  |         s1         |       s2       |     s3     |      s4      |     s5      |     s6      |    s7
 --------|--------------------|----------------|------------|--------------|-------------|-------------|------------>
     周五5:00             周六19:45        周六20:00   周六20:45       周日20:00     周日20:45     周日00:00
]]

function CityBattleModel:getState() -- 0 备战状态1 开战状态 2 休战 
    return __curStatus, __curWeek, __curTimeDes
end

--判断进入进入大世界时，需要展示的动画类型

function CityBattleModel:getShowAnimationType()
    local state,weekday,timeDes  = self:getState()
    local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self:getOverTime()
    local currTime = self._userModel:getCurServerTime()
    local gvgNum = self:getGvgNum()
    print("gvgNum ",gvgNum)
    if timeDes == "s1" then --备战动画
        local timeReady = SystemUtils.loadAccountLocalData("CITYBATTLE_READY_TIME")
        if not timeReady then
            SystemUtils.saveAccountLocalData("CITYBATTLE_READY_TIME",s5OverTime)
            return "readyAnima"
        else
            if currTime > timeReady then
                SystemUtils.saveAccountLocalData("CITYBATTLE_READY_TIME",s5OverTime)
                return "readyAnima"
            end
        end
    elseif timeDes == "s2" or timeDes == "s3" or timeDes == "s5" then --匹配服务器动画
        
        local timeBattle = SystemUtils.loadAccountLocalData("CITYBATTLE_BATTLE_TIME")
        if not timeBattle then
            SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_TIME",s5OverTime)
            return "battleAnima"
        else
            if currTime > timeBattle then
                SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_TIME",s5OverTime)
                return "battleAnima"
            end
        end
    elseif timeDes == "s4" then --战中结算
        -- if currTime < s3OverTime + 3000 then
        --     return
        -- end
        local timeBattle = SystemUtils.loadAccountLocalData("CITYBATTLE_BATTLE_RESULT1")
        if not timeBattle then
            SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_RESULT1",s6OverTime)
            return "result1"
        else
            if currTime > timeBattle then
                SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_RESULT1",s6OverTime)
                return "result1"
            end
        end
    elseif timeDes == "s6" or timeDes == "s7" then
        -- if timeDes == "s6" and currTime < s5OverTime + 3000 then
        --     return
        -- end
        local timeBattle = SystemUtils.loadAccountLocalData("CITYBATTLE_BATTLE_RESULT2")
        if not timeBattle then
            SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_RESULT2",s6OverTime+450000)
            return "result2"
        else
            if currTime > timeBattle then
                SystemUtils.saveAccountLocalData("CITYBATTLE_BATTLE_RESULT2",s6OverTime+450000)
                return "result2"
            end
        end
    end
    return false
end

--获取本赛季 备战结束，开战结束,备战开始，开战开始 的时间戳
function CityBattleModel:getOverTime()
    -- local currTime = self._userModel:getCurServerTime()
    -- local weekday = tonumber(TimeUtils.date("%w", currTime))
    -- local add = weekday == 0 and 0 or (7-weekday)*86400
    -- local timeOver = currTime + add
    -- local t1 = TimeUtils.date("*t", timeOver)
    -- local s6OverTime = os.time({year = t1.year, month = t1.month, day = t1.day, hour = 24, min = 00, sec = 00})
    -- local s5OverTime = s6OverTime - 8100
    -- local s4OverTime = s5OverTime - 2700
    -- local s3OverTime = s4OverTime - 83700
    -- local s2OverTime = s3OverTime - 2700
    -- local s1OverTime = s2OverTime - 900
    -- local s7OverTime = s1OverTime - 143100
    -- print(s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime,s7OverTime)
    -- return s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime,s7OverTime
    return __overTime.s1OverTime,__overTime.s2OverTime,__overTime.s3OverTime,
            __overTime.s4OverTime,__overTime.s5OverTime,__overTime.s6OverTime,__overTime.s7OverTime
end

--获取赛季届数
function CityBattleModel:getGvgNum()
    if self._data["c"] and self._data["c"]["season"] then
        return tonumber(self._data["c"]["season"])
    end
    return  1
end


-- 是否九点开战状态
function CityBattleModel:getCheckState()
    local state, _ = self:getState()
    local flag = false
    if state == 1 then
        local currTime = self._userModel:getCurServerTime()
        local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 21:00:00"))
        local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 21:45:00"))
        if currTime > minTime and currTime < maxTime then
            flag = true
        end
    end
    flag = true
    return flag
end

function CityBattleModel:isFirstOpen()
    local funOpen = SystemUtils.loadAccountLocalData("CITYBATTLE_OPEN")
    if not funOpen then
        SystemUtils.saveAccountLocalData("CITYBATTLE_OPEN",1)
        return true
    end
end

-- function CityBattleModel:setSendNum(data)
--     -- self._data["c"]["sendNum"] = data
--     for k,v in pairs(data) do
--         if not self._data["c"]["sendNum"] then
--             self._data["c"]["sendNum"] = {}
--         end
--         self._data["c"]["sendNum"][k] = v
--     end
-- end

-- -- 判断兵团有没有派遣出去
-- function CityBattleModel:getFormationData()
--     -- self._gvgUserData["s"]
--     -- local tform = {}
--     -- for i=1,4 do
        
--     -- end
--     -- self._gvgUserData = data
--     -- return tform
-- end


-- -- 兵团复活数据
-- function CityBattleModel:getGVGFmDeadData()
--     -- self._gvgUserData["s"]
--     -- local tform = {}
--     -- for i=1,4 do
        
--     -- end
--     -- self._gvgUserData = data
--     -- return tform
--     -- return self._gvgUserData["c"]
-- end

-- function CityBattleModel:getFormationData()
--     self._playerModel = self._modelMgr:getModel("PlayerTodayModel")
--     local playerData = self._playerModel:getData()

-- end

-- function CityBattleModel:updateFightData()
--     self._playerModel = self._modelMgr:getModel("PlayerTodayModel")
--     local playerData = self._playerModel:getData()

-- end



-- 1创建 2未解锁 3已编组及空闲状态 4复活 5已派遣可撤回 6不可撤回
function CityBattleModel:getFormationState(inFid, inFormation)
    -- local gvgffd = self._citybattleModel:getGVGFmdFightData()
    local userLvl = self._userModel:getData().lvl
    local cityInfos = self._data["c"]["c"]
    local suoLv = tab:Setting("G_CITYBATTLE_FORMATION_LV").value
    local citFormation = self._data["f"][tostring(inFid)]
    -- local cutLine = tab:Setting("G_CITYBATTLE_PREPARE_QUEUE").value or 1
    local cutLine = 1

    if citFormation ~= nil and next(citFormation) ~= nil and citFormation.cid ~= nil then
        local cityTab = tab:CityBattle(tonumber(citFormation.cid))
        if cityTab ~= nil then 
            cutLine = cityTab.atknum
        end
    end
    local formationCount = self._formationModel:getFormationCountByType(inFid)
    local findex = self._formationWithIndex[inFid]
    local state = 0
    local cdTime = 0
    local beginTime = 0

    local limitLevel = 0
    
    local heroId = inFormation["heroId"]

    if userLvl < suoLv[findex] then
        state = CityBattleConst.FORMATION_STATE.LOCK
        limitLevel = suoLv[findex]
    elseif heroId == nil or heroId == 0 or formationCount <= 0 then

        state = CityBattleConst.FORMATION_STATE.CREATE
    elseif citFormation == nil or next(citFormation) ==  nil then

        state = CityBattleConst.FORMATION_STATE.FREE

    elseif citFormation["i"] == -1 then 
        local curTime = self._userModel:getCurServerTime() 
        if tonumber(citFormation["cd"]) > curTime then 
            state = CityBattleConst.FORMATION_STATE.DIE
            cdTime = tonumber(citFormation["cd"])
            beginTime = tonumber(citFormation["cds"])
        else
            self._data["f"][tostring(inFid)] = nil
            state = CityBattleConst.FORMATION_STATE.FREE
        end
    elseif citFormation["i"] > cutLine then

        state = CityBattleConst.FORMATION_STATE.READY
    else
        --[[ 回滚2017.9.14--]]
        local cityInfo = cityInfos[citFormation.cid]
        if cityInfo.an <= 0 and cityInfo.dn >0 then 
            local sysCityBattle = tab.cityBattle[tonumber(citFormation.cid)]
            local flag = 1
            for k1,v1 in pairs(sysCityBattle.nearby) do
                local newarCityInfo = cityInfos[tostring(v1)]
                if tostring(newarCityInfo.b) ~= self._sec then
                    flag = 0 
                    break
                end
            end
            if flag == 1 then
                state = CityBattleConst.FORMATION_STATE.READY
            else
                state = CityBattleConst.FORMATION_STATE.BATTLE
            end
        else
            state = CityBattleConst.FORMATION_STATE.BATTLE
        end
        -- ]]
        -- state = CityBattleConst.FORMATION_STATE.BATTLE
        
    end
    return state, beginTime, cdTime, limitLevel
end

function CityBattleModel:reviveFormation(success, data)
    print("CityBattleModel:reviveFormation")
end

-- 红点数据
function CityBattleModel:setRedData(key,data)
    if not self._redData then self._redData = {} end
    if not key then return end
    self._redData[key] = data

    if not self._curentReportRedSatus then
        self:reflashData("ReportRedChanged")
    end
end

function CityBattleModel:getMaxTime(time,key)
    if not self._redData or not self._redData[key] then return time end
    local time = math.max(time,self._redData[key].time)
    return time
end

function CityBattleModel:checkReprotRedData()
    -- print("CityBattleModel:checkReprotRedData")
    if not self._redData then
        return
    end

    --个人战报
    local isHaveNewPersonReport
    local personTime = SystemUtils.loadAccountLocalData("CITYBATTLE_PERSON_RED")
    local personReport = self._redData["personReport"]
    if personTime then
        -- print("personTime",personTime)
        -- print("personReport.time",personReport.time)
       if personReport and personReport.time and personTime < personReport.time then
          isHaveNewPersonReport = true 
       end
    else
        if personReport and personReport.time then
           isHaveNewPersonReport = true 
        end
    end

    local isHaveNewCityReport
    local cityTime = SystemUtils.loadAccountLocalData("CITYBATTLE_CITY_RED")
    local cityReport = self._redData["cityReport"]
    if cityTime then
       if cityReport and cityReport.time and cityTime < cityReport.time then
          isHaveNewCityReport = true 
       end
    else
        if cityReport and cityReport.time then
           isHaveNewCityReport = true 
        end
    end
    self._curentReportRedSatus = isHaveNewPersonReport or isHaveNewCityReport

    return isHaveNewPersonReport or isHaveNewCityReport    
end
--[[
    奖励红点
]]
function CityBattleModel:checkRewardRedData()
    if not self._rewardRedData then
        return
    end
    if not self:checkIsGvgOpen() then
        return
    end

    local userRewardHistory = {}
    if self._rewardRedData["a"] then
        for id,value in pairs (self._rewardRedData["a"]) do 
            userRewardHistory[id] = value
        end
    end

    local score = 0
    if self._rewardRedData["p"] then
        for id, num in pairs(self._rewardRedData["p"]) do 
            score = score + num
        end
    end
    -- dump(userRewardHistory,"userRewardHistory",10)
    local tabData = tab.cityBattleReward
    for id,data in pairs (tabData) do 
        if score >= data.condition and userRewardHistory[tostring(id)] ~= 1 then
            return true
        end
    end
end
--[[
    新的一届，奖励里面城池页签需要小红点
]]
function CityBattleModel:checkNewGvg()
    local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self:getOverTime()
    local currTime = self._userModel:getCurServerTime()
    local numTime = SystemUtils.loadAccountLocalData("CITYBATTLE_NUM_TIME")
    if not numTime then
        -- SystemUtils.saveAccountLocalData("CITYBATTLE_NUM_TIME",s6OverTime+450000)
        return true
    else
        if currTime > numTime then
            -- SystemUtils.saveAccountLocalData("CITYBATTLE_NUM_TIME",s6OverTime+450000)
            return true
        end
    end
end

--[[
    新的一届，备战时需要显示一次气泡
]]
function CityBattleModel:checkNewGvgReady()
    if not self:checkIsGvgOpen() then
        return 
    end
    print("CityBattleModel:checkNewGvgReady1")
    local state, weekday, timeType = self:getState()
    if state ~= 0 or timeType ~= "s1" then return false end
    print("state",state,"timeType",timeType)
    local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self:getOverTime()
    local currTime = self._userModel:getCurServerTime()
    local numTime = SystemUtils.loadAccountLocalData("CITYBATTLE_NUM_READY_TIME")
    if not numTime then
        print("numTimenil")
        return true
    else
        print("numTime",numTime)
        if currTime > numTime then
            return true
        end
    end
end

--[[
    更新已领取的宝箱的id
]]

function CityBattleModel:updateGetRewardIds(id)
    if not self._rewardRedData then
        return
    end
    if not self._rewardRedData["a"] then
        self._rewardRedData["a"] = {}
    end
    self._rewardRedData["a"][tostring(id)] = 1
end


--[[
    开服后第一个周五5点开始
    return 是否满足条件，tips
]]
function CityBattleModel:checkIsGvgOpen()
    local userModel = self._modelMgr:getModel("UserModel")
    local userData = userModel:getData()
    if userData.lvl < 50 then
        return false,lang("TIP_CITYBATTLE")
    end
    local serverNowTime = userModel:getCurServerTime()
    local t = TimeUtils.date("*t", serverNowTime)
    if tonumber(t.wday) == 6 then
        -- local time1 = os.time({year = t.year, month = t.month, day = t.day, hour = 4, min = 55, sec = 0})
        -- local time2 = os.time({year = t.year, month = t.month, day = t.day, hour = 5, min = 10, sec = 0})
        local time1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverNowTime,"%Y-%m-%d 4:55:00"))
        local time2 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(serverNowTime,"%Y-%m-%d 5:10:00"))
        if serverNowTime >= time1 and serverNowTime < time2 then
            return false,lang("CITYBATTLE_TIP_33")
        end
    end
    print("userData.sec_open_time",userData.sec_open_time)
    local t = TimeUtils.date("*t", userData.sec_open_time)
    local realTime = userData.sec_open_time
    if t.hour < 5 then
        local day = userData.sec_open_time - 86400
        -- t = TimeUtils.date("*t", day)
        realTime = day
    end
    local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(realTime,"%Y-%m-%d 5:00:00"))
    -- local openTime = os.time({year = t.year, month = t.month, day = t.day, hour = 5, min = 0, sec = 0})
    local time1 = openTime + 19*86400
    print("time1",time1)
    local week = tonumber(TimeUtils.date("%w",time1))
    local add = 0
    if week == 0 then
        add =  6 * 86400
    elseif week <= 5 then
        add = (5-week)*86400
    else
        add = 6 * 86400
    end
    local finalTime = time1 + add
    print("finalTime",finalTime)
    return serverNowTime >= finalTime,lang("TIP_CITYBATTLE2")
end

--[[
    检测是否需要播放主界面争夺开启动画
]]

function CityBattleModel:checkGvgOpenMc()
    if not self:checkIsGvgOpen() then
        return
    end
    local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime,s7OverTime = self:getOverTime()
    local curtime = self._userModel:getCurServerTime()
    if curtime >= s7OverTime + 600 and curtime <= s5OverTime then
        local openTime = SystemUtils.loadAccountLocalData("CITYBATTLE_OPEN_MC_TIME")
        if openTime and openTime >= s5OverTime then
            return 
        end
        SystemUtils.saveAccountLocalData("CITYBATTLE_OPEN_MC_TIME",s5OverTime)
        return true
    end
end

function CityBattleModel:setRewardRedData(result)
    self._rewardRedData = result
end


function CityBattleModel:addSendCallback(inStatus, inCallback)
    self._sendCallback[inStatus] = inCallback
end

function CityBattleModel:delFormationData(inFid)
    self:delFormationById(inFid)
    -- self._events["UFormation_CUR"] = {}
    -- self:reflashData("UFormation_CUR")
    self:reflashData("UFormation_CUR_data:temp")
end

function CityBattleModel:delFormationById(inFid)
    if self._data["f"] == nil then return end
    if inFid ~= nil then
        self._data["f"][tostring(inFid)] = nil
    end
end


-- 设置正在观看的城ID
function CityBattleModel:setWatchCity(id)
    self._watchCityid = id
end

-- 获取正在观看的城ID
function CityBattleModel:getWatchCity(id)
    return self._watchCityid
end

-- 保存观看的城市数据
function CityBattleModel:setCityData(data)
    if self._cityData == nil then
        self._cityData = {}
    end
    
    self._cityData["leftPerson"] = clone(data["ael"] or {})
    self._cityData["rightPerson"] = clone(data["del"] or {})
    self._cityData["reportList"] = clone(data["br"] or {})
    self._cityData["an"] = data["an"] or 0
    self._cityData["dn"] = data["dn"] or 0
    self._cityData["sec"] = data["b"]
end

-- 更新观看的城市数据
function CityBattleModel:_updateWatchCityData(data, updateTp)
    if updateTp == "newBattle" then
        local personList = nil
        if data.isWin == true then
            personList = self._cityData.rightPerson
        else
            personList = self._cityData.leftPerson
        end
        if personList then
            if #personList == 1 then
                if data.isWin == true then
                    self._cityData["finalDesStr"] = "恭喜 ".. self:getServerName(data.playerInfo[1].sec) .. " ".. data.playerInfo[1].n .. " 进攻成功"
                else
                    if self._cityData.sec == "npc" then
                        self._cityData["finalDesStr"] = "中立守卫 防守成功"
                    else
                        self._cityData["finalDesStr"] = self:getServerName(self._cityData.sec) .. " ".. data.playerInfo[2].n .. " 防守成功"
                    end
                end
            end
        end

        self._cityData.leftPerson = data.atkf
        self._cityData.rightPerson = data.deff

        local reportData = {}
        reportData["aname"] = data.playerInfo[1].n
        reportData["asec"] = data.playerInfo[1].sec
        reportData["dname"] = data.playerInfo[2].n
        reportData["dsec"] = data.playerInfo[2].sec
        reportData["win"] = data.isWin
        reportData["bk"] = data.reportKey
        table.insert(self._cityData["reportList"], 1, reportData)
        if #self._cityData["reportList"] > 10 then
            table.remove(self._cityData["reportList"], 11)
        end

--    elseif updateTp == "joinCity" then
--        for k, v in pairs(data.df) do
--            if tonumber(v) == tonumber(self:getWatchCity()) then
--                self:_removePersonData(data.rid, k)
--            end
--        end

--        -- 新加入成员排序
--        local newFormation = {}
--        for kF, vF in pairs(data["f"]) do
--            vF.fid = kF
--            table.insert(newFormation, vF)
--        end

--        table.sort(newFormation, function(a,b)
--            return tonumber(a["i"]) < tonumber(b["i"])
--        end)

--        for i = 1, #newFormation do
--            local v = newFormation[i]
--            if tostring(v.cid) == tostring(self:getWatchCity()) then
--                v.rid = data.rid
--                -- 不是本城所属区服则属于攻击方
--                if v.sec ~= self:getCityDataById(self:getWatchCity()).b then
--                    table.insert(self._cityData["leftPerson"], v)
--                else
--                    table.insert(self._cityData["rightPerson"], v)
--                end
--            end
--        end

    elseif updateTp == "leaveCity" then
        local rid = data.rid
        local fid = nil
        for k, _ in pairs(data.f) do
            fid = k
        end
        self:_removePersonData(rid, fid)
    end
end

function CityBattleModel:_removePersonData(rid, fid)
    local removeIndex = nil
    for i = 1, #self._cityData["leftPerson"] do
        if self._cityData["leftPerson"][i].rid == rid and self._cityData["leftPerson"][i].fid == fid then
            removeIndex = i
        end

        if removeIndex ~= nil and i > removeIndex then
            self._cityData["leftPerson"][i]["i"] = self._cityData["leftPerson"][i]["i"] - 1
        end
    end

    if removeIndex ~= nil then
        table.remove(self._cityData["leftPerson"], removeIndex)
        return
    end

    for i = 1, #self._cityData["rightPerson"] do
        if self._cityData["rightPerson"][i].rid == rid and self._cityData["rightPerson"][i].fid == fid then
            removeIndex = i
        end

        if removeIndex ~= nil and i > removeIndex then
            self._cityData["rightPerson"][i]["i"] = self._cityData["rightPerson"][i]["i"] - 1
        end
    end

    if removeIndex ~= nil then
        table.remove(self._cityData["rightPerson"], removeIndex)
        return
    end
end

-- 获取观看的城市数据
function CityBattleModel:getCityData()
    return self._cityData
end

-- 获取在观看城市内的自己编组的对应数据
function CityBattleModel:getMyCityFdata(watchCityID)
    local myFormation = {}
    for k, v in pairs(self._data["f"]) do
        if v.cid == tostring(watchCityID) then
            local data = clone(v)
            data.rid = self._userModel:getData()._id
            data.fid = tostring(k)
            local formationData = self._modelMgr:getModel("FormationModel"):getFormationDataByType(tonumber(k))
            data.hid = formationData["heroId"]
            data.bl = self._modelMgr:getModel("FormationModel"):getFormationCountByType(tonumber(k))
            
            local userHeroData = self._modelMgr:getModel("HeroModel"):getHeroData(data.hid)
            if userHeroData.skin ~= nil then 
                data.sk = userHeroData.skin
            end

            data.sec = GameStatic.sec
            table.insert(myFormation, data)
        end
    end

    table.sort(myFormation, function(a, b)
        return tonumber(a.i) < tonumber(b.i)
    end)
    return myFormation or {}
end

function CityBattleModel:resetCityData()
    self._cityData = nil
    self._watchCityid = nil
end

function CityBattleModel:setCityBattleData(data)
    self._cityBattleData = data

    self:_updateWatchCityData(data, "newBattle")
end


function CityBattleModel:getCityBattleData()
    return self._cityBattleData
end

function CityBattleModel:setCityPersonData(data)
    self._cityPersonData = data
end


function CityBattleModel:getCityPersonData()
    return self._cityPersonData
end

--function CityBattleModel:setJoinCityData(data)
--    self._joinCityData = data

--    self:_updateWatchCityData(data, "joinCity")
--end

--function CityBattleModel:getJoinCityData()
--    return self._joinCityData
--end

function CityBattleModel:setLeaveCityData(data)
    self._leaveCityData = data

    self:_updateWatchCityData(data, "leaveCity")
end

function CityBattleModel:getLeaveCityData()
    return self._leaveCityData
end

--[[
--! @function handleJavaCallback10011
--! @desc 战斗房间初始数据
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10011(result, error)
    self:setCityData(result)
end

--[[
--! @function handleJavaCallback10006
--! @desc 观战房间战斗数据
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10006(result, error)
    -- dump(result)
    -- 判断是否为观看城发生的战斗
    if result["c"] then
        local watchCityId = self:getWatchCity()
        for cId, v in pairs(result["c"]) do
            if cId == watchCityId then
                local battleData = {}
                battleData["cityData"] = v
                battleData["atkf"] = result["atkf"]
                battleData["deff"] = result["deff"]
                battleData["playerInfo"] = result["f"]
                battleData["reportKey"] = result["bk"]
                battleData["isWin"] = result["win"]
                battleData["csec"] = result["csec"]
                battleData["an"] = result["an"]
                battleData["dn"] = result["dn"]
                self:setCityBattleData(battleData)
                self:reflashData("NewBattle")
            end
        end
    end
end

--[[
--! @function handleJavaCallback10005
--! @desc 获取编组返回数据
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10005(result, error)
    -- dump(result, "test", 10)
    print("error===================", error)
    if error ~= 0 then 
        if self._sendCallback[10005] ~= nil then
            self._sendCallback[10005](result, error)
            self._sendCallback[10005] = nil
        end
    end

    local rid = self._userModel:getData()._id
    -- local tmpResult = {}
    -- tmpResult["f"] = {}
    local tmpDelFormation = {}
    local tmpUpFormation = {}
    tmpUpFormation["f"] = {}
    if result["f"] == nil then result["f"] = {} end
    for k,v in pairs(self._data["f"]) do
        -- tmpResult["f"][k] = v
        if result["f"][k] == nil or v.cid ~= result["f"][k].cid then
            tmpDelFormation[k] = self._data["f"][k].cid
            -- 踢出此城
            tmpUpFormation["f"][k] = {i = -1, cid = self._data["f"][k].cid}
        elseif result["f"][k] ~= nil then
            tmpUpFormation["f"][k] = result["f"][k]
        else
            tmpUpFormation["f"][k] = self._data["f"][k]
        end
    end
    -- 清除f数据
    for k,v in pairs(tmpDelFormation) do
        self:delFormationById(k)
    end
    local tmpResult = {}
    tmpResult["f"] = {}
    for k,v in pairs(result["f"]) do
        tmpResult["f"][k] = v
    end

    if next(tmpResult) ~= nil then
        self:updateData(tmpResult)
    end
    
    self:reflashData("UFormation_data:" .. serialize(tmpUpFormation))
    -- end
    
    if self._sendCallback[10005] ~= nil then
        self._sendCallback[10005](result, error)
        self._sendCallback[10005] = nil
    end

    dump(tmpDelFormation, "tmpDelFormation", 10)
    if next(tmpDelFormation) ~= nil then
        self:reflashData("DMiniIcon_CUR_data:" .. serialize(tmpDelFormation))
    end

end

--[[
--! @function handleJavaCallback10010
--! @desc 获取圆盘信息
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10013(result, error)
    if error ~= 0 then
        if self._sendCallback[10013] ~= nil then
            self._sendCallback[10013](result, error)
            self._sendCallback[10013] = nil
        end
    end

    if result["cid"] ~= nil then
        local tmpResult = {}
        local tempCityInfo = {}
        tempCityInfo[tostring(result["cid"])] = {}
        tempCityInfo[tostring(result["cid"])].an = result["an"]
        tempCityInfo[tostring(result["cid"])].dn = result["dn"]
        tempCityInfo[tostring(result["cid"])].as = result["as"]
        tempCityInfo[tostring(result["cid"])].ds = result["ds"]
        if result["an"] > 0 and result["dn"] > 0 then 
            tempCityInfo[tostring(result["cid"])].isBattle =  true
        else
            tempCityInfo[tostring(result["cid"])].isBattle =  false
        end
        tmpResult["c"] = {}
        tmpResult["c"]["c"] = tempCityInfo
        self:updateData(tmpResult)
    end

    if self._sendCallback[10013] ~= nil then
        self._sendCallback[10013](result, error)
        self._sendCallback[10013] = nil
    end
end


--[[
    bcl:{
        1,2,3  --发生战斗的id
    },
    chp:{ --城池血量
        1:100,
        2:200
    }
]]
function CityBattleModel:handleJavaCallback10012(result, error)
    -- dump(result, "全图每2s推送", 10)
    local cityInfos = self._data["c"]["c"]
    -- 处于战斗中的城池
    local battleCity = {}
    local tmpBattleCity = {}
    local freeCity = {}
    local collectCityData = {}
    if result["bcl"] ~= nil and next(result["bcl"]) ~= nil then 
        for k, v in pairs(result["bcl"]) do
            tmpBattleCity[v] = 1
            if cityInfos[v] ~= nil and cityInfos[v].isBattle == false then 
                battleCity[v] = 1
                cityInfos[v].isBattle = true
                print("k========================isBattle======================", k )
            end
        end
        for k,v in pairs(self._battleCityStates) do
            if tmpBattleCity[k] == nil then
                freeCity[k] = 1
                if cityInfos[k] ~= nil then 
                    cityInfos[k].isBattle = false
                end
            end
        end
        self._battleCityStates = tmpBattleCity
    else
        freeCity = self._battleCityStates
        self._battleCityStates =  {}
        if not GameStatic.revertGvg_rebuild then
            for cid,_ in pairs (freeCity) do 
                cityInfos[cid].isBattle = false
            end
        end
    end
    
    table.merge(collectCityData, battleCity)
    table.merge(collectCityData, freeCity)
    -- dump(collectCityData, "collectCityData", 10)

    ---增加城池血量 2017.10.11
    --每两秒的推送中，更新每个城池的血量
    if not GameStatic.revertGvg_rebuild then
        local chp = result["chp"]
        if chp then
            for cid,hp in pairs (chp) do 
                if cityInfos[cid] then
                    cityInfos[cid].bl = hp
                end
            end
        end
    end

    --检测编组的推送丢失 2017.10.12
    if not GameStatic.revertGvg_rebuild then
        local localFormation = self._data["f"] or {}
        local time = socketTimeFun()
        for _,data in pairs (localFormation) do 
            if data.newTime then
                if time - data.newTime >= 5 then
                    self:sendSocketMgs("getPlayerFormation",{_m = 1})
                    break
                end
            else
                data.newTime = time
            end
        end
    end

    self:reflashData("UCityInfo_data:" .. serialize(collectCityData))
end

-- 发送协议
function CityBattleModel:sendSocketMgs(name, params)
    params.mapId = self:getMapId()
    params.rid = self._userModel:getData()._id
    params.name = self._userModel:getData().name
    params.sec = GameStatic.sec
    ServerManager:getInstance():RS_sendMsg("PlayerProcessor", name, params or {})
end


--[[
--! @function handleJavaCallback10007
--! @desc 派遣分组信息与城池信息混合
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]

--2017.10.11 修改 f字段修改为带完整编组数据
function CityBattleModel:handleJavaCallback10007(result, error)
    -- dump(result,"战斗每1s返回一次======",10)
    local result_f = result["f"]
    if result_f ==  nil or next(result_f)  == nil then return end
    local operateCityKeys = table.keys(result_f)
    local operateFid = operateCityKeys[1]

    local local_formation_f = self._data["f"]
    local localFormation = local_formation_f[operateFid]
    if localFormation == nil or localFormation.cid == nil then return end
    local localCityId = tostring(localFormation.cid)
    local curTime = self._userModel:getCurServerTime() 
    local tmpResult = {}
    local cityInfos = self._data["c"]["c"]
    tmpResult["f"] = {}
    local isRevert = GameStatic.revertGvg_rebuild

    for k,v in pairs(result_f) do
        local localFormation = local_formation_f[k]
        localFormation.newTime = socketTimeFun()
        local pos = (isRevert and tonumber(v)) or v.i or -1
        if localFormation.cd <= curTime and localFormation.i ~= pos then 
            if isRevert then
                tmpResult["f"][k] = {}
                tmpResult["f"][k].i = pos
            else
                tmpResult["f"][k] = v
            end
            if localCityId == tostring(self:getWatchCity()) then
                local data = {}
                data.atkf = result.atkf
                data.deff = result.deff
                data.an = result.an
                data.dn = result.dn
                self:setCityPersonData(data)
                self:reflashData("PersonRefresh")
            end
        end
    end
    if result["an"] ~= nil and result["dn"] ~= nil then 
        local cityInfo = cityInfos[localCityId]
        -- 数据产生变化时再进行更新，防止无意义刷新
        if (cityInfo["t"] == nil or cityInfo["t"] <= curTime) and 
            (cityInfo["an"] ~= result["an"] or 
            cityInfo["dn"] ~= result["dn"] or 
            cityInfo["as"] ~= result["as"] or 
            cityInfo["ds"] ~= result["ds"])  then
            
            local tempCityInfo = {}
            tempCityInfo[localCityId] = {}
            tempCityInfo[localCityId].an = result["an"]
            tempCityInfo[localCityId].dn = result["dn"]
            tempCityInfo[localCityId].as = result["as"]
            tempCityInfo[localCityId].ds = result["ds"]
            -- 定时更新派遣信息提前整理派遣状态
            self:handleCityBattleStatus(localCityId, result)

            tmpResult["c"] = {}
            tmpResult["c"]["c"] = tempCityInfo
            self:reflashData("UCityInfo_data:" .. serialize(tempCityInfo))
        end
    end
    
    --只有编组的数据发生变化，才刷新编组
    local isChanged = false
    if not isRevert then
        for id,data in pairs(result_f) do 
            local local_data = local_formation_f[id]
            if local_data then
                if data.i ~= local_data.i or data.cid ~= local_data.cid or data.cds ~= local_data.cds then
                    isChanged = true
                    break
                end
            else
                isChanged = true
                break
            end
        end
    end
    self:updateData(tmpResult)

    print("isChanged ================== >>>>>>>>>>",isChanged)
    if isChanged then
        self:reflashData("UFormation_data:"  .. serialize(tmpResult) )
    end

    if isRevert and tmpResult.f ~= nil and next(tmpResult.f) ~= nil then
        self:reflashData("UFormation_data:"  .. serialize(tmpResult) )
    end
end

--[[
--! @function handleJavaCallback10013
--! @desc 右上角编组返回数据
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10014(result, error)
    if error ~= 0 then 
        return
    end
    -- dump(result,"handleJavaCallback10014",10)
    self:updateServerInfo(result)
end

--更新本地编组数据
function CityBattleModel:updateServerInfo(result)
    if not result then return end
    if not self._data then
        return
    end
    self._data.serverInfo = result
    self:reflashData("ServerInfo")
end

--[[
--! @function handleJavaCallback10004
--! @desc 战斗返回数据
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10004(result, error)
    -- dump(result,"战斗结果返回10004======",10)
    if error ~= 0 then 

    end
    local curTime = self._userModel:getCurServerTime() 
    local rid = self._userModel:getData()._id
    local operateCityKeys = table.keys(result["c"])

    local tmpResult = {}
    tmpResult["f"] = {}

    -- 防守方城市
    local dfSideSec = ""
    local cityInfos = self._data["c"]["c"]
    local oldCityInfo = cityInfos[operateCityKeys[1]]

    -- dump(result["sn"],"战斗返回====================",10)
    -- if result["csec"] == 1 then
    --     if result["sn"] and table.nums(result["sn"]) > 0 then
    --         for sec,cnum in pairs (result["sn"]) do 
    --             self:updateTeamNum(sec,cnum)
    --         end
    --     end
    -- else
    --     for _,data in pairs (result["f"]) do 
    --         if data.i and data.i < 0 then
    --             self:updateTeamNum(data.sec,-1)
    --         end
    --     end
    -- end

    local winSide = 0
    local isRevert = GameStatic.revertGvg_rebuild
    -- 地图数据处理
    if result["f"] ~= nil then 
        local isWarning = true
        for k,v in pairs(result["f"]) do
            if v.i ~= -1 then
                isWarning = false
            end 
            if tostring(v.rid) == tostring(rid) then
                tmpResult["f"][v.fid] = v
                self:setRedData("personReport", {time = curTime})
            end
            -- 我服务器人员战斗失败，则自动处理后续部队的排位  
            if k == 1 and result["win"] == true then
                winSide = 1
            elseif k == 2 and result["win"] == false then
                winSide = 2
            end
        end
        if isWarning then
            print("Warning handleJavaCallback10004 i = 1")
        end
    end



    if result["c"] ~= nil then
        tmpResult["c"] = {}
        -- 取消派遣时提前整理派遣状态
        for k,v in pairs(result["c"]) do
            self:handleCityBattleStatus(k, v)
        end
        tmpResult["c"]["c"] = result["c"]

        -- 提取城池异主
        for k,v in pairs(result["c"]) do
            local oldCityInfo = cityInfos[k]
            if (v.b ~= oldCityInfo.b and v.t ~= nil and v.t > curTime) and (v.b == self._sec or oldCityInfo.b == self._sec) then
                self:setRedData("cityReport", {time = curTime})
            end
        end    

        --发生战斗导致城池易主，战斗非自己，需要检测是否需要把自己踢出
        if not isRevert then
            if table.nums(tmpResult["f"]) <= 0 then
                local fdata = self._data["f"]
                for k,v in pairs(result["c"]) do
                    local b = v.b
                    local cid = v.cid
                    if b ~= self._sec then
                        for index,data in pairs (fdata) do 
                            if data.cid and tonumber(data.cid) == tonumber(cid) then
                                local fData = clone(data)
                                fData.i = -1
                                tmpResult["f"][index] = fData
                            end
                        end
                    else
                        for index,data in pairs (fdata) do 
                            if data.cid and tonumber(data.cid) == tonumber(cid) then
                                local fData = clone(data)
                                tmpResult["f"][index] = fData
                            end
                        end
                    end
                end
            end    
        end
    end
    self:updateData(tmpResult)
    tmpResult.cid = operateCityKeys[1]

    self:reflashData("UFormation_data:" .. serialize(tmpResult))


    -- self._events["UCityInfo"] = result["c"]
    self:reflashData("UCityInfo_data:" .. serialize({[operateCityKeys[1]] = 1}))
    -- self:reflashData("UCityInfo")

    -- if next(tempBattleQueue) ~= nil then 
    --     self:reflashData("ShowBattleTip_data:" .. serialize(tempBattleQueue))
    -- end


end



--[[
--! @function handleJavaCallback10003
--! @desc 取消派遣回调
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10003(result, error)
    print("error===================", error)
    -- dump(result, "取消派遣======",10)
    if error ~= 0 then 
        if self._sendCallback[10003] ~= nil then
            self._sendCallback[10003](result, error)
            self._sendCallback[10003] = nil
        end
        return
    end

    local tmpResult = {}
    if result["c"] ~= nil then
        tmpResult["c"] = {}

        -- 取消派遣时提前整理派遣状态
        for k,v in pairs(result["c"]) do
            self:handleCityBattleStatus(k, v)
        end

        tmpResult["c"]["c"] = result["c"]
    end

    -- if result["sec"] then
    --     self:updateTeamNum(result["sec"],-1)
    -- end

    local rid = self._userModel:getData()._id
    if tostring(result['rid']) == tostring(rid) then 
        tmpResult["f"] = {}
        for k,v in pairs(result["f"]) do
            if tonumber(v.id) == -1 or tonumber(v.i) == -1 then 
                self:delFormationById(v.fid)
            else
                tmpResult["f"][v.fid] = v
            end
        end
    end

    self:updateData(tmpResult)
    
    if self._sendCallback[10003] ~= nil then
        self._sendCallback[10003](result, error)
        self._sendCallback[10003] = nil
        -- self._events["UFormation_CUR"] = tmpResult
        -- self:reflashData("UFormation_CUR")
        self:reflashData("UFormation_CUR_data:temp")
    else
        self:reflashData("UCityInfo_data:" .. serialize(result["c"]))
    end

    
    -- 判断是否为观看城发生的玩家离开
    local watchCityId = self:getWatchCity()
    if result["cid"] == watchCityId then
        self:setLeaveCityData(result)
        self:reflashData("LeaveCity")
    end
end

function CityBattleModel:handleCityBattleStatus(inCityId, inCityInfo)
    if inCityInfo.an ~= nil and inCityInfo.dn ~= nil and  inCityInfo.an > 0 and inCityInfo.dn > 0 then 
        inCityInfo.isBattle =  true
        self._battleCityStates[inCityId] = 1
    else
        inCityInfo.isBattle =  false
        self._battleCityStates[inCityId] = nil
    end
end

--[[
--! @function handleJavaCallback10002
--! @desc 派遣回调
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10002(result, error)
    print("error===================", error)
    if error ~= 0 then
        if self._sendCallback[10002] ~= nil then
            self._sendCallback[10002](result, error)
            self._sendCallback[10002] = nil
        end
        return
    end
    -- dump(result,"handleJavaCallback10002",10)
    local rid = self._userModel:getData()._id
    local tmpResult = {}
    local tempBattleQueue = {}
    if  tostring(result['rid']) == tostring(rid) then 
        tmpResult["f"] = result["f"]
        local sysCityBattle = tab:CityBattle(tonumber(tmpResult["f"].cid))
        local cutLine = 1
        if sysCityBattle ~= nil then 
            cutLine = sysCityBattle.atknum
        end
        for k,v in pairs(tmpResult["f"]) do
            if cutLine >= v.i and v.i ~= -1 then 
                v.fid = k
                table.insert(tempBattleQueue, v)
            end
        end
    end
    tmpResult["c"] = {}

    -- 派遣时提前整理派遣状态
    for k,v in pairs(result["c"]) do
        self:handleCityBattleStatus(k, v)
    end

    tmpResult["c"]["c"] = result["c"]
    self:updateData(tmpResult)

    -- if result["sec"] then
    --     self:updateTeamNum(result["sec"],result["c"],1)
    -- end
    -- if result["sec"] then
    --     local add = result["f"] and table.nums(result["f"]) or 0
    --     local reduce = result["df"] and table.nums(result["df"]) or 0
    --     self:updateTeamNum(result["sec"],add - reduce)
    -- end

    if self._sendCallback[10002] ~= nil then
        self._sendCallback[10002](tmpResult, error)
        self._sendCallback[10002] = nil
        -- self._events["UFormation_CUR"] = tmpResult
        -- self:reflashData("UFormation_CUR")
        self:reflashData("UFormation_CUR_data:temp")

        -- 出现df说明编组由A迁到B
        if result["df"] ~= nil then
            self:reflashData("DMiniIcon_CUR_data:" .. serialize(result["df"]))
        end
    else
        self:reflashData("UCityInfo_data:" .. serialize(result["c"]))
    end

    if next(tempBattleQueue) ~= nil then 
        self:reflashData("ShowBattleTip_data:" .. serialize(tempBattleQueue))
    end

--    -- 判断是否有玩家加入正在观看的城池
--    if result["c"] then
--        local watchCityId = self:getWatchCity()
--        for cId, v in pairs(result["c"]) do
--            if cId == watchCityId then
--                self:setJoinCityData(result)
--                self:reflashData("JoinCity")
--            end
--        end
--    end
end

--更新城池的编组数量
function CityBattleModel:updateTeamNum(sec,changeNum)
    if not self._data["tn"][sec] then
        self._data["tn"][sec] = 0
    end
    self._data["tn"][sec] = self._data["tn"][sec] + changeNum
    -- if not self._data["san"] then self._data["san"] = {} end
    -- if not self._data["sdn"] then self._data["sdn"] = {} end
    -- local isAtk = false
    -- for k,v in pairs (data) do 
    --     if not tostring(sec) == v.b then
    --         isAtk = true
    --         break
    --     end
    -- end
    -- if isAtk then
    --     if not self._data["san"][sec] then
    --         self._data["san"][sec] = 0
    --     end
    --     self._data["san"][sec] = self._data["san"][sec] + changeNum
    -- else
    --     if not self._data["sdn"][sec] then
    --         self._data["sdn"][sec] = 0
    --     end
    --     self._data["sdn"][sec] = self._data["sdn"][sec] + changeNum
    -- end
end

--[[
--! @function handleJavaCallback1001
--! @desc 获取地图数据
--! @param result table 返回数据
--! @param error int 报错
--! @return table
--]]
function CityBattleModel:handleJavaCallback10001(result, error)
    print("error===================", error)
    if error ~= 0 then 

    end
    -- dump(result, "tst", 10)
    self:setData(result)
    if self._loginCallback ~= nil then
        self._loginCallback()
    end
    self._isReceiveLoginResult = true
    -- self:setData(result)
    -- self._events["LoginData"] = 1
    -- self:reflashData("Login")
end


-- 开始监听java服务器
function CityBattleModel:onListenRSResponse()
    self:listenRSResponse(specialize(self.onSocektResponse, self))
end


function CityBattleModel:setLoginCallback(inLoginCallback)
    self._loginCallback = inLoginCallback
end

CityBattleModel.GET_MAP_DATA = 10001 --获取地图数据opcode
CityBattleModel.ENTER_CITY = 10002   --编组进入城堡通知
CityBattleModel.LEAVE_CITY = 10003   --编组离开城堡通知
CityBattleModel.BATTLE_INFO = 10004  --战斗推送

CityBattleModel.INIT_CITY_FIGHT = 10011   --战斗房间初始数据

-- java服务器的response或者push接受
function CityBattleModel:onSocektResponse(data)
    if data.status ~= 10007 then
        -- dump(data, "onSocektResponse", 7)
    end
    print("data.result and data.status===", data.resul, data.status)
    if data.ecode ~= nil then 
        data.error = tonumber(data.ecode)
    end
    if data.error ~= nil then
        self:onSocektError(data)
        return
    end

    if data.pushId then
        if data.status and data.status == CityBattleModel.GET_MAP_DATA then
            self._pushId = tonumber(data.pushId)
        else
            if tonumber(data.pushId) == self._pushId + 1 then
                self._pushId = tonumber(data.pushId)
            else
                self:rsReinit()
            end
        end
    end

    
    if data.result and data.status then
        local status = data.status
        local result = json.decode(data.result)
        if self["handleJavaCallback" .. status] ~= nil then 
            --在未收到10001的情况下，不处理java推送
            if tonumber(status) ~= 10001 and not self._isReceiveLoginResult then
                return
            end
            self["handleJavaCallback" .. status](self, result, 0)
        end
    end
end


CityBattleModel.SERVER_ERROR_112 = 112 -- 无效的token
CityBattleModel.SERVER_ERROR_100 = 100 -- 参数错误
CityBattleModel.SERVER_ERROR_70006 = 70006 -- 房间加入失败

CityBattleModel.SERVER_ERROR_5001= 5001 -- 城堡在cd中，无法派遣
CityBattleModel.SERVER_ERROR_5002= 5002 -- 阵编组没有英雄或兵团

CityBattleModel.SERVER_ERROR_5004= 5004 -- 上阵编组CD时间还没过期
CityBattleModel.SERVER_ERROR_5005= 5005 -- 撤退时index小于规定index
CityBattleModel.SERVER_ERROR_5006= 5006 -- 撤退再该房间没有找到玩家
CityBattleModel.SERVER_ERROR_5007= 5007 -- 队列已满

function CityBattleModel:onSocektError(inData)
    print('errorId===============', errorId, inData.status)
    -- 放弃重连
    if inData.error == 111111 then
        self._viewMgr:returnMain()

    -- 服务器错误
    elseif inData.error == CityBattleModel.SERVER_ERROR_1 
        or inData.error == CityBattleModel.SERVER_ERROR_2
        or inData.error == CityBattleModel.SERVER_ERROR_3
    then


    else


    end

    if inData.error == CityBattleModel.SERVER_ERROR_5001 then
        ViewManager:getInstance():showTip("城池在cd中，无法派遣")
    elseif inData.error == CityBattleModel.SERVER_ERROR_5002 then
        ViewManager:getInstance():showTip("编组中没有英雄或兵团")
    elseif inData.error == CityBattleModel.SERVER_ERROR_5004 then
        ViewManager:getInstance():showTip("上阵编组处于复活中") 
    elseif inData.error == CityBattleModel.SERVER_ERROR_5005 then
        ViewManager:getInstance():showTip("撤离编组失败")
    elseif inData.error == CityBattleModel.SERVER_ERROR_5006 then
        ViewManager:getInstance():showTip("撤离编组失败")
    elseif inData.error == CityBattleModel.SERVER_ERROR_5007 then
        ViewManager:getInstance():showTip("该城池已无法派遣")           
    end
    if inData.status == nil then return end
    if self["handleJavaCallback" .. inData.status] ~= nil then 
        self["handleJavaCallback" .. inData.status](self, inData, inData.error)
    end
end

-- 保存java连接init数据
function CityBattleModel:setSocketData(data)
    self._socketData = data
end

--[[
    清除收到10001的状态
]]
function CityBattleModel:clearStatus10001()
    self._isReceiveLoginResult = false
end

-- java服务器重连
function CityBattleModel:rsReinit()
    self:clearStatus10001()
    ServerManager:getInstance():RS_initSocket(data,
    function (errorCode)
        if errorCode ~= 0 then 
            print("rs init failed" .. errorCode)
            return 
        end
        -- 连接成功回调
        print("rs init success")
        self._cityBattleModel:onListenRSResponse()
    end)
end

--[[
    获取区服名称
]]
function CityBattleModel:getServerName(sec, isShort)
    if not sec then return "" end
    local sec = tonumber(sec)
    local realSec = tostring(self:getRealServerId(sec))
    local des = ""
    local co = self._data["c"]["co"]
    local num = co[realSec]
    if not num then 
        realSec =  tostring(sec)
        num = co[realSec]
        if not num then return "" end
    end
    des = battleName[num]
    if not isShort then
        des = des .. "战区"
    end
    return des
    -- local num = 0
    -- if sec < 5001 then
    --     num = sec % 1000
    -- elseif (sec >= 5001 and sec < 5501) or (sec >= 6001 and sec < 6501) then
    --     num = (sec % 1000)*2 - 1
    -- elseif (sec >= 5501 and sec < 6000) or (sec >= 6501 and sec < 7000) then
    --     num = (sec % 100) * 2
    -- else
    --     num = sec % 1000
    -- end
    -- local sdkMgr = SdkManager:getInstance()
    -- local des = ""
    -- if sec and sec >= 5001 and sec < 7000 then
    --     des = "双线" .. num .. "区"
    -- elseif sdkMgr:isQQ() then
    --     des = "qq" .. num .. "区"
    -- elseif sdkMgr:isWX() then
    --     des = "微信" .. num .. "区"
    -- else
    --     des = "win" .. num .. "区"
    -- end

    -- return des
end

--获取最短的开始时间
function CityBattleModel:getMinOpenDayKey()
    local openDay = self._data["c"]["days"] or 10
    if openDay <= 30 then
        return 0
    elseif openDay > 30 and openDay <= 45 then 
        return  1
    elseif openDay > 45 and openDay <= 60 then
        return 2
    elseif openDay > 60 and openDay <= 75 then
        return 3
    else
        return 4
    end
end

function CityBattleModel:addLeaveData(cid,fid)
    self._watchLeaveList[tostring(fid)] = tostring(cid)
end

function CityBattleModel:getAnddeleteLeaveData()
    if not next(self._watchLeaveList) then return end
    local data = clone(self._watchLeaveList)
    self._watchLeaveList = {}
    return data
end


function CityBattleModel:getEvents()
    return self._events
end

--获取真实serverid
function CityBattleModel:getRealServerId(id)
    local map = self._userModel:getServerIDMap()
    if not map then return id end
    local finalID = map[tostring(id)]
    return finalID and tonumber(finalID) or id
end

--获取自己真实的sec
function CityBattleModel:getMineSec()
    local map = self._userModel:getServerIDMap()
    local minID = map[tostring(GameStatic.sec)]
    local sec = minID and tonumber(minID) or tonumber(GameStatic.sec)
    return sec
end

--[[
    历史战绩
]]
function CityBattleModel:setSecRecordData(result)
    local secData  = self:getCityServerList()
    for _,data in pairs (secData) do 
        local sec = tostring(data.sec)
        local recordData = result[sec]
        if recordData then
            data.r = recordData.r
            data.bl = recordData.bl
            data.s = recordData.s    -- 新加主城积分
        end
    end
    self._recordData = secData
end

function CityBattleModel:getRecordData()
    -- dump(self._recordData, "aaaaaaaaaaaa" ,10)
    return self._recordData
end

function CityBattleModel:getSecName(sec)
    local data = self:getData().c.co
    local battleName = {
        "赤焰战区:",
        "碧蓝战区:",
        "苍星战区:"
    }

    if data[sec] ~= nil then
        return battleName[data[sec]]
    else
        return nil
    end
end

function CityBattleModel:getPlatformName(sec)
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

function CityBattleModel:fiterServers(sec)
    local severList = self._userModel:getServerIDMap()
    local result = {}
    if not severList[tostring(sec)] then
        result[#result+1] = sec
    else
        for old,new in pairs (severList) do
            if tostring(sec) == new then
                result[#result+1] = tonumber(old)
            end
        end
        if #result == 0 then
            result[#result+1] = sec
        end
    end
    return result
end

function CityBattleModel:getRealNum(sec)
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

return CityBattleModel