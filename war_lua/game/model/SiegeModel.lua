--
-- Author: <ligen@playcrab.com>
-- Date: 2017-09-06 18:06:52
--

--[[
    siegeInfo{
        status=>core_Schema::NUM 状态
        pnum=>core_Schema::NUM 到达等级人数
        stageId=>core_Schema::NUM 当前攻打关卡ID
        bl1=>core_Schema::NUM 关卡1血量
        bl2=>core_Schema::NUM 关卡2血量
        bl3=>core_Schema::NUM 关卡3血量
        bl4=>core_Schema::NUM 关卡4血量
        bl5=>core_Schema::NUM 关卡5血量
        nextTime=>core_Schema::NUM 下一状态时间戳
        wallLv=>core_Schema::NUM 当前城墙等级 
        wallExp=>core_Schema::NUM 当前城墙经验值
    }
]]


local tab = tab

local SiegeModel = class("SiegeModel", BaseModel)

SiegeModel.STATUS_PRE = 1 -- 准备 
SiegeModel.STATUS_PRESIEGE = 2 -- 攻城倒计时 
SiegeModel.STATUS_SIEGE = 3 -- 攻城
SiegeModel.STATUS_PREDEFEND = 4 -- 守城倒计时
SiegeModel.STATUS_DEFEND = 5 -- 守城
SiegeModel.STATUS_PREOVER = 6 -- 结束倒计时
SiegeModel.STATUS_OVER = 7 -- 结束 

SiegeModel.CITY_ATTACK_S = 1   --小城攻城
SiegeModel.CITY_ATTACK_B = 2   --大城攻城
SiegeModel.CITY_DEFEND_B = 3   --大城守城



--伤害奖励
local rewardKeyList = {
                        [1] =  {  
                                    [10001] = "sRewardIds1",
                                    [10002] = "sRewardIds2",
                                    [10003] = "sRewardIds3",
                                    [10004] = "sRewardIds4",
                                    [10005] = "sRewardIds5"
                                },
                        [2] = {[30001] = "dwRewardIds"},
                        [3] = {[30001] = "bRewardIds"}

                    }
--累计伤害key
local hurtValueKey = {
                        [1] =  {
                                    [10001] = "sbl1",
                                    [10002] = "sbl2",
                                    [10003] = "sbl3",
                                    [10004] = "sbl4",
                                    [10005] = "sbl5",
                                },
                        [2] = {[30001] = "defDamage"},
                        [3] = {[30001] = "dBuild"}
                    }
local damageKey = {
                    [10001] = "maxDamage1",
                    [10002] = "maxDamage2",
                    [10003] = "maxDamage3",
                    [10004] = "maxDamage4",
                    [10005] = "maxDamage5",
                    [30001] = "maxDamage6",
                  }
function SiegeModel:ctor()
    SiegeModel.super.ctor(self) 

    self._data = nil

    self._atkStageTemp = tab:SiegeMainSection(1).includeStage -- 攻城包括的关卡
    self._defStageTemp = tab:SiegeMainSection(2).includeStage -- 守城包括的关卡

    self._prepareData = nil    --攻城准备页面数据
    self._atkAwardList = {}   --攻城已领取奖励列表
    self._defAwardList = {}   --守城已领取奖励列表
    self._wallAwardList = {}  --城墙加固已领取奖励列表
    self._isMaxHurt = false   --是否是最高伤害
    self._maxMaves = 0    --是否是最大波数
    self._awardList = {
                            [1] = self._atkAwardList,
                            [2] = self._defAwardList,
                            [3] = self._wallAwardList,
                         }

    self._progressData = {}

    self._userModel = self._modelMgr:getModel("UserModel")

    self:registerTimer(5, 0, GRandom(0, 5), specialize(self.refleshUIEvent, self))
end

function SiegeModel:refleshUIEvent()
    self._serverMgr:sendMsg("ExtraServer", "getSiegeInfo", {}, true, {}, function (result, error)
        self:reflashData("refleshUIEvent")
        self:reflashData("refleshWallLVEvent")
    end)
end

function SiegeModel:setData(data)
    if data and data.siege then
        self._data = data.siege
    end
end

function SiegeModel:updateData(data)
    local curId = self._data["curStageId"]
    if data == nil then return end
    for k,v in pairs(data) do
        if type(v) == "table" then
            if self._data[k] == nil then
                self._data[k] = {}
            end 
            for k1,v1 in pairs(v) do
                self._data[k][k1] = v1
            end
        else
            if k == damageKey[curId] then    --历史伤害最高处理
                if self._data[k] then
                    if tonumber(self._data[k]) <= tonumber(v) then
                        self._isMaxHurt = true
                    else
                        self._isMaxHurt = false
                    end
                else
                     self._isMaxHurt = true
                end
            end
            if k == "maxWaves" then       --最大波数
                if self._data[k] then
                    self._maxMaves = self._data[k]
                else
                    self._maxMaves = 0
                end
            elseif k == "dBuild" then
                self._data.preBuildExp = self._data[k] 
            end
            self._data[k] = v
        end 
    end
    self:reflashData("stateUpdate")
end

function SiegeModel:updatePushData(data)
    self:updateData(data)
    self:reflashData("statePushUpdate")
end


function SiegeModel:getData()
    return self._data or {}
end
--攻城准备页面数据
function SiegeModel:setPrepareData(data)
    if data  then
        self._progressData[data.stageId] = data["progress"]
        self._prepareData = data
        self:updateData(data["siege"])   
    end
end

function SiegeModel:getPrepareData()
    return self._prepareData or {}
end

-- 获取当前关卡ID
function SiegeModel:getCurStageId()
    local curId = self:getData().curStageId
    if self._data.status  == SiegeModel.STATUS_PREDEFEND then
        curId = 10005
    end
    return curId
end

-- 获取章节
function SiegeModel:getCurSectionId()
    if self._data.status  then
        local sectionId
        if self._data.status  >= SiegeModel.STATUS_SIEGE and self._data.status  <= SiegeModel.STATUS_PREDEFEND then
            return 1
        elseif self._data.status  >= SiegeModel.STATUS_DEFEND and self._data.status  <= SiegeModel.STATUS_OVER then
            return 2
        end
    else
        return nil
    end
end

-- 大世界入口显示状态
function SiegeModel:getEntranceState()
    local isOpen = false
    local stateData = {}
    local data = self:getData()
--    data = {status = 1, playerNum = 15}
--    data = {status = 6, nextTime = 1506243367}
--    data.status = 3
--    data = {status = 5, waves = 8888}
    if data.status then
        stateData.status = data.status
        if data.status == SiegeModel.STATUS_PRE then
            stateData.playerNum = data.playerNum

            if data.startTime then
                stateData.perScore = self:getPerScoreRate(TimeUtils.getDiffDays(data.startTime, self._userModel:getCurServerTime())) * data.playerNum
                stateData.score = data.score
                stateData.maxScore = 1000
            end

        elseif data.status == SiegeModel.STATUS_PRESIEGE then
            stateData.nextTime = data.nextTime

        elseif data.status == SiegeModel.STATUS_SIEGE then
            local curStageId = self:getCurStageId()
            stateData.isLastStage = curStageId == self._atkStageTemp[#self._atkStageTemp]
            if stateData.isLastStage then
                local hpPercent = data["blood" .. #self._atkStageTemp] / tab:SiegeMainStage(curStageId).hp
                stateData.hpPercent = math.floor(hpPercent * 10000) / 10000 * 100
            end
            isOpen = true
        elseif data.status == SiegeModel.STATUS_PREDEFEND then
            stateData.nextTime = data.nextTime

            isOpen = true
        elseif data.status == SiegeModel.STATUS_DEFEND then
            stateData.waves = data.waves

            isOpen = true
        elseif data.status == SiegeModel.STATUS_PREOVER then
            stateData.nextTime = data.nextTime
            isOpen = true

        elseif data.status == SiegeModel.STATUS_OVER then
            isOpen = true
        end
    end

    if not SystemUtils:enableSiege() then
        isOpen = false
        stateData.notEnable = true
    end

    return isOpen, stateData
end

-- 大世界是否定位
function SiegeModel:isWorldLocation()
    local isLocation = false
    local stateData = {}
    local data = self:getData()
    local isLvEnough = SystemUtils:enableSiege()

    local loactionId = SystemUtils.loadAccountLocalData("SiegeWorldLocation") 
    if data.status == SiegeModel.STATUS_PRE and 
        data.playerNum ~= nil and
        data.playerNum > 0 and
        (loactionId == nil or loactionId < 1)
    then

        isLocation = true
        SystemUtils.saveAccountLocalData("SiegeWorldLocation", 1)

    elseif data.status == SiegeModel.STATUS_SIEGE and
            (loactionId == nil or loactionId < 2)
        then

        isLocation = true
        stateData.changeAni = 1
        stateData.dialog = 1
        stateData.flagAni = 1
        SystemUtils.saveAccountLocalData("SiegeWorldLocation", 2)

    elseif data.status == SiegeModel.STATUS_PREDEFEND and
            (loactionId == nil or loactionId < 3)
        then
        isLocation = true
        stateData.dialog = 2
        SystemUtils.saveAccountLocalData("SiegeWorldLocation", 3)

    elseif data.status == SiegeModel.STATUS_DEFEND and
            (loactionId == nil or loactionId < 4) 
        then
        isLocation = true
        stateData.dialog = 3
        stateData.flagAni = 2
        SystemUtils.saveAccountLocalData("SiegeWorldLocation", 4)

    elseif data.status == SiegeModel.STATUS_PREOVER and
            (loactionId == nil or loactionId < 5)
        then

        isLocation = true
        stateData.changeAni = 2
        stateData.dialog = 4
        SystemUtils.saveAccountLocalData("SiegeWorldLocation", 5)
    end

    if not isLvEnough then
        isLocation = false
    end

    return isLocation, stateData
end

-- 获取每天积分增长速度
function SiegeModel:getPerScoreRate(day)
    day = day + 1
    if day <= 0 then return 0 end
    if day >= 7 then
        return tab:SiegeOpenPoints(7).value
    else
        return tab:SiegeOpenPoints(day).value
    end
end

-- 判断关卡是否已通关
function SiegeModel:isStagePass(stageId)
    print("stageId",stageId)
    print("getCurStageId",self:getCurStageId())
    if stageId < self:getCurStageId() then
        return true

    elseif stageId == self:getCurStageId() then
        if stageId == 10005 and self._data.status  >= SiegeModel.STATUS_PREDEFEND then
            return true
        elseif  stageId == 30001 and self._data.status  >= SiegeModel.STATUS_PREOVER then
            return true
        else
            return false
        end
    end
    return false
end

-- 获取斥候密信进度
function SiegeModel:getSectionBranchRate()
    return self:getData().branchNum or 0
end


function SiegeModel:getBranchRealId(branchId)
    local id = branchId
    if tonumber(id) > 90000 then
        id = tonumber(id) - 10000
    end
    return id
end


-- 是否领取斥候密信进度奖励
function SiegeModel:hasGetMainAward(num)
    local data = self:getData().branchReward
    if data and data[tostring(num)] ~= nil then
        return true
    end
    return false
end

function SiegeModel:getBranchInfo()
    return self:getData().branchInfo or {}
end

function SiegeModel:getSysBranchWithStageDatas()
    if self._sysBranchWithStage ~= nil then 
        return self._sysBranchWithStage
    end

    self._sysBranchWithStage = {}
    for k,v in pairs(tab.siegeMainStage) do
        if v.branchId ~= nil then
            for k1,v1 in pairs(v.branchId) do
                self._sysBranchWithStage[v1] = v.id
            end
        end
    end
    return self._sysBranchWithStage
end

-- 斯坦德维克活动是否结束
function SiegeModel:isSiegeOver()
    return self:getData().status == SiegeModel.STATUS_OVER
end

function SiegeModel:dtor()
    tab = nil
end


-- 城墙配置表
function SiegeModel:getSiegeWallCfg(level)
    if level == nil then return {} end
    local cfgDatas = tab.siegeWallBuild
    local count = 0
    local t = {}
    for k,v in pairs(cfgDatas) do
        if level == k then
            t = v
        end 
    end
    return t
end

function SiegeModel:getWallCurLevel()
    if self._buildMaxLv == nil then
        self._buildMaxLv = #tab.siegeWallBuild
    end
    if self._data then
        local level = self._data.wallLv
        level = math.min(level,self._buildMaxLv)
        return math.max(level,1)
    end 
    return 1
end

--城墙昨日累加经验值
function SiegeModel:getAccumulationYesterday()
    if self._data then
        return self._data.wallExp or 0
    end 
    return 0
end

-- 城墙属性开启等级
function SiegeModel:getSiegeWallOpenLevel()
    local cfgDatas = tab.siegeWallBuild
    local baseOpenLevel     = 10000  -- 箭塔解锁等级
    local defenceOpenLevel  = 10000  -- 护城河解锁等级
    local result = {}
    for k,v in pairs(cfgDatas) do

        if v.baseIsOpen == 1 then
            if v.level < baseOpenLevel then
                baseOpenLevel = v.level
            end 
        end 

        if v.defenceIsOpen == 1 then
            if v.level < defenceOpenLevel then
                defenceOpenLevel = v.level
            end 
        end 
    end
    return baseOpenLevel, defenceOpenLevel
end

function SiegeModel:getWallBuildMaterial()
    local cfg = tab.siegeSetting
    for k,v in pairs(cfg) do
        if v.name == "buildMaterial" then
            return v.value
        end
    end
    return {}
end

function SiegeModel:getWallAttrrDatas()
    local siegeMainStage = tab.siegeMainStage
    local siegeBattleG = tab.siegeBattleGroup

    local siege = tab.siege
    local npc   = tab.npc
    local battleId = siegeMainStage[30001].battleId
    local id = siegeBattleG[battleId].siegeDefendId

    local wallIds  = siege[id].pylonid
    local arrowIds = siege[id].arrowid
    local hchValue = siege[id].moatattrObject

    local npcId1   = wallIds[1]
    local npcId2   = arrowIds[1]
    local objectId = hchValue[1]
   
    local wallNpcData = npc[npcId1]["a4"]
    local wallBase, wallAdd = wallNpcData[1], wallNpcData[2]

    local arrowNpcData = npc[npcId2]["a1"]
    local arrowBase, arrowAdd = arrowNpcData[1], arrowNpcData[2]

    
    local objectCfg = tab.object
    local buffId = objectCfg[objectId].buffid1
    local skillBuffCfg = tab.skillBuff
    local hcvBase = math.abs(skillBuffCfg[buffId].addattr[1][2])
    local hcvAdd = math.abs(skillBuffCfg[buffId].addattr[1][3])

    local result = {}
    local siegeWallCfg = tab.siegeWallBuild
    for k,v in pairs(siegeWallCfg) do
        local t = {}
        --城墙属性
        t.wallValue = v.wallIsOpen == 1 and wallBase + wallAdd * (v.wall-1) or 0 
        t.wallValue = t.wallValue * 4
        -- 箭塔属性
        t.arrowValue = v.baseIsOpen == 1 and arrowBase + arrowAdd * (v.wall-1) or 0 

        -- 护城河属性
        t.hchValue = v.defenceIsOpen == 1 and hcvBase + hcvAdd * (v.wall -1 ) or 0 
        -- t.hchValue = t.hchValue .. "%"
        result[k] = t
    end
    return result
end

function SiegeModel:getWallFunctionInfo()
    local cfgDatas = tab.siegeWallBuild
    local result = {}
    local level1 = 1
    local level2,level3 = SiegeModel:getSiegeWallOpenLevel()
    local icons  = {"siege_wall", "siege_arrow", "siege_defence"}
    local levels = {level1, level2, level3}
    local desT   = {"SIEGE_DAILY_SIEGEWALL_DES", "SIEGE_DAILY_SIEGEARROW_DES", "SIEGE_DAILY_SIEGEDEFENCE_DES"}
    local names  = {"SIEGE_DAILY_SIEGEWALL_NAME", "SIEGE_DAILY_SIEGEARROW_NAME", "SIEGE_DAILY_SIEGEDEFENCE_NAME"}
    for i=1,3 do
        local t = {}
        t.icon = icons[i]..".png"
        t.openLevel = levels[i]
        t.des = lang(desT[i])
        t.name = lang(names[i])
        t.tags = icons[i]
        table.insert(result, t)
    end
    return result
end

-- 返回今日全服累积
function SiegeModel:getTodayTotalAccumulation()
    if self._data then
        return self._data.wallDExp or 0
    end 
    return 0
end

-- 返回今日玩家自己累积
function SiegeModel:getTodayAccumulation()
    if self._data then
        return self._data.dBuild or 0
    end 
    return 0
end

-- 返回修固城墙超过全服玩家百分比
function SiegeModel:getPercentBeyondOthers()
    if self._data then
        return self._data.per or 0
    end 
    return 0
end

-- 是否开启日常篇
function SiegeModel:isSiegeDailyOpen()
    if self:getData().status == SiegeModel.STATUS_OVER and SystemUtils:enableDailySiege() then 
        return true
    end
    return false
end

--初始化已领取的奖励数据
function SiegeModel:initAwardList(siegeid,type)
    local key = rewardKeyList[type][siegeid]
    if key then
        self._awardList[type] = {}
        if self:getData()[key] then
            self._awardList[type] = self:getData()[key]
        end
    end
end

function SiegeModel:getAwardList(type)
    return self._awardList[type]
end


function SiegeModel:updateAwardList(type,siegeid,data)
    -- for k , v in pairs(self._atkAwardList) do
    --     if tonumber(k) == tonumber(rewardId) then
        
    --     end
    -- end
end
--获取累计伤害
function SiegeModel:getHurtValue(type,siegeid)
    local key = hurtValueKey[type][siegeid]
    return self:getData()[key]
end
--获取当前排名奖励
function SiegeModel:getInRangeData(rank,siegeid)
    if rank > 10000 then
        rank = 10000
    end
    local siegeRank = tab["siegeRank"]
    for i,siegeData in ipairs(siegeRank) do
        if siegeData["sectionID"] == siegeid then
            local low,high = siegeData.rank[1],siegeData.rank[2]
            if rank >= low and rank <= high then
                return siegeData
            end
        end
    end
    return nil
end

--获取挑战次数
function SiegeModel:getChannelTimes()
    local data = self:getData()
    local curStatus = data.status
    local maxTimes = 0
    if curStatus == SiegeModel.STATUS_SIEGE or curStatus == SiegeModel.STATUS_PREDEFEND then
        maxTimes = tab.siegeSetting[6].value or 0
    elseif curStatus == SiegeModel.STATUS_DEFEND or curStatus == SiegeModel.STATUS_PREOVER then
        maxTimes = tab.siegeSetting[7].value or 0
    end
    local useTimes = data.times or 0
    local hasTimes = maxTimes - useTimes
    return maxTimes , hasTimes
end

--更新宝箱状态
function SiegeModel:changeBoxState(key,boxId)
    if self._data[key] ~= nil then
        self._data[key][tostring(boxId)] = 1
    else
        self._data[key] = {} 
        self._data[key][tostring(boxId)] = 1
    end
end

-- 是否可以进攻
function SiegeModel:canBattle()
    if self:getData() == nil then return false end
    local status = self:getData().status
    local _, times = self:getChannelTimes()
    if (status == SiegeModel.STATUS_SIEGE or status == SiegeModel.STATUS_DEFEND)
        and times > 0
    then
        return true
    end
    return false
end

-- 是否在大世界播放旗子动画
function SiegeModel:isShowFlag()
    if not SystemUtils:enableSiege() then
        return false
    end

    if self:getData().status == SiegeModel.STATUS_SIEGE and SystemUtils.loadAccountLocalData("SiegeFlagAni") == nil then
        return true, 1

    elseif self:getData().status == SiegeModel.STATUS_SIEGE and SystemUtils.loadAccountLocalData("SiegeFlagAni") ~= 2 then

        return true, 2
    end
    return false
end

-- 是否播放大世界动画
function SiegeModel:isShowMainViewFly()
    local data = self:getData()
    if data.status == SiegeModel.STATUS_PRE and 
        data.playerNum ~= nil and
        data.playerNum > 0 and 
        SystemUtils.loadAccountLocalData("SiegeFlyStatusPre") == nil and
        self._modelMgr:getModel("UserModel"):getData().lvl >= 78
    then
        return true, "OnSiegePrepare"
    end

    if not SystemUtils:enableSiege() then
        return false
    end

    if data.status == SiegeModel.STATUS_OVER and SystemUtils.loadAccountLocalData("SiegeFlyStatusOver") == nil then
        return true, "DailySiegeOpen"

    elseif data.status == SiegeModel.STATUS_SIEGE and SystemUtils.loadAccountLocalData("SiegeFlyStatusSiege") == nil then
        return true, "OnSiege"
    end
    return false
end

-- 城墙是否达到最大等级
function SiegeModel:isWallReachMaxLevel(level)
    local cfgDatas = tab.siegeWallBuild
    local isReach = false
    if not cfgDatas[level+1] then
        isReach = true
    end 
    return isReach
end

-- 返回每次加固的增加经验
function SiegeModel:getAddExpSingle()
    if self._data then
        local preExp = self._data.preBuildExp or 0
        local nowExp = self:getTodayAccumulation()
        return nowExp - preExp
    end 
    return 0
end

--阶段及宝箱奖励
function SiegeModel:checkNoticeAward(stageId)
    local siegeType = tab.siegeMainStage[stageId]["type"]    --城市类型
    local attackAward,defendAward,wallAward = false,false,false
    local boxAward = false
    if siegeType == SiegeModel.CITY_DEFEND_B then            --大城守城
        defendAward = self:checkHurtAward(stageId,2)
        wallAward = self:checkHurtAward(stageId,3)
        boxAward = self:checkBoxAward(stageId)
    else
        attackAward = self:checkHurtAward(stageId,1)
        if siegeType == SiegeModel.CITY_ATTACK_B then       --大城攻城
            boxAward = self:checkBoxAward(stageId)
        end
    end
    return boxAward or attackAward or defendAward or wallAward
end

-- 判断守城奖励按钮的红点
function SiegeModel:checkDefNoticeAward()
    local defendAward,wallAward = false,false
    defendAward = self:checkHurtAward(30001,2)
    wallAward = self:checkHurtAward(30001,3)
    return defendAward or wallAward
end

--伤害或加固阶段奖励
function SiegeModel:checkHurtAward(stageId, awardTp)
    self:initAwardList(stageId,awardTp) 
    local rewardList = self:getAwardList(awardTp) or {}   --奖励列表
    local canGetIdData = {}
    local tableDataStatic = {}
    for i = 1 , #tab.siegeAward do
        if stageId == tab.siegeAward[i]["sectionID"] and awardTp == tab.siegeAward[i]["type"]  then
            table.insert(tableDataStatic,tab.siegeAward[i])
        end
    end
    local myHurt = self:getHurtValue(awardTp,stageId) or 0
    for k,v in pairs(tableDataStatic) do
        v.isGetted = false
        for id,vv in pairs(rewardList) do
            if v.id == tonumber(id) then
                v.isGetted = true
                break
            end
        end
    end   
    for k,v in pairs(tableDataStatic) do
        if not v.isGetted and myHurt >= v.condition then
            table.insert(canGetIdData,v.id)
        end
    end
    return #canGetIdData > 0
end
--检查宝箱奖励
function SiegeModel:checkBoxAward(stageId)
    -- self._serverMgr:sendMsg("SiegeServer", "getStageInfo", {stageId = stageId}, true, {},function (result,errorCode)
    --     if errorCode ~= 0 then
    --         self._viewMgr:unlock(51)
    --         local rewardIdsTable = {}   --领奖id
    --         local progress = result["progress"]
    --         local progressTable = {}
    --         for k , v in pairs(tab.siegePeriodAward) do
    --             if stageId == v["sectionID"] then
    --                 rewardIdsTable[v["id"]] = 0
    --                 progressTable[v["id"]] = v["condition"]
    --             end
    --         end
    --         if self._siegeType == SiegeModel.CITY_ATTACK_B then
    --             if self._data["atkRewardIds"] ~= nil then
    --                 for k , v in pairs(self._data["atkRewardIds"]) do
    --                     rewardIdsTable[tonumber(k)] = v
    --                 end
    --             end
    --         elseif self._siegeType == SiegeModel.CITY_DEFEND_B then
    --             if self._data["defRewardIds"] ~= nil then
    --                 for k , v in pairs(self._data["defRewardIds"]) do
    --                     rewardIdsTable[tonumber(k)] = v
    --                 end
    --             end
    --         end
    --         for k , v in pairs(rewardIdsTable) do
    --             if tonumber(progress) >= tonumber(progressTable[k]) and tonumber(v) == 0 then
    --                 return true
    --             end
    --         end 
    --     end
    -- end)

    -- [[by guojun
    local siegeType = tab.siegeMainStage[stageId]["type"]
    local rewardIdsTable = {}   --领奖id
    local progress = self._progressData[stageId] or 0
    local progressTable = {}
    for k , v in pairs(tab.siegePeriodAward) do
        if stageId == v["sectionID"] then
            rewardIdsTable[v["id"]] = 0
            progressTable[v["id"]] = v["condition"]
        end
    end
    if siegeType == SiegeModel.CITY_ATTACK_B then
        if self._data["atkRewardIds"] ~= nil then
            for k , v in pairs(self._data["atkRewardIds"]) do
                rewardIdsTable[tonumber(k)] = v
            end
        end
    elseif siegeType == SiegeModel.CITY_DEFEND_B then
        if self._data["defRewardIds"] ~= nil then
            for k , v in pairs(self._data["defRewardIds"]) do
                rewardIdsTable[tonumber(k)] = v
            end
        end
    end
    for k , v in pairs(rewardIdsTable) do
        if tonumber(progress) >= tonumber(progressTable[k]) and tonumber(v) == 0 then
            return true
        end
    end 
    --]]
    return false
end
--城墙加固材料
function SiegeModel:checkWallBuildMaterial()
    local buildMaterals = self:getWallBuildMaterial() or {}
    for k , id in pairs(buildMaterals) do
        local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(id)
        if tonumber(count) > 0 then
            return true
        end
    end
    return false
end

-- 检查所有关卡是否有宝箱可领取
function SiegeModel:checkAllStageAward()
    if not self:getEntranceState() then return false end

    local sectionId = self:getCurSectionId()
    local sysMainSection = tab:SiegeMainSection(sectionId)
    for k,v in pairs(sysMainSection.includeStage) do
        if self:checkNoticeAward(v) then
            return true
        end
    end
    return false
end

-- 获取弹幕类型
function SiegeModel:getBulletType()
    if self:getCurStageId() < 10005 then
        return 1
    elseif self:getCurStageId() == 10005 then
        return 2
    else
        return 3
    end
end
return SiegeModel