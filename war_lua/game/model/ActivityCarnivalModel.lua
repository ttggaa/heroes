--
-- Author: huangguofang
-- Date: 2016-04-01 15:28:26
--
local ActivityCarnivalModel = class("ActivityCarnivalModel", BaseModel)

local tonumber = tonumber
local tostring = tostring
local string_sub = string.sub
function ActivityCarnivalModel:ctor()
    ActivityCarnivalModel.super.ctor(self)
    self._data = {}
    self._serverData = {}
    self._canGetNum = 0
    self._day = 0
    self._totalComNum = 0
    -- self._data = tab.activity901
    self._userModel = self._modelMgr:getModel("UserModel")
    self._instanceModel = self._modelMgr:getModel("IntanceModel")
    self._intanceEliteModel = self._modelMgr:getModel("IntanceEliteModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._acModel = self._modelMgr:getModel("ActivityModel")

    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._cloudCityModel = self._modelMgr:getModel("CloudCityModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._treasureModel = self._modelMgr:getModel("TreasureModel")

    self._trainingModel = self._modelMgr:getModel("TrainingModel")
    self._elementModel = self._modelMgr:getModel("ElementModel")
    self._spellBooksModel = self._modelMgr:getModel("SpellBooksModel")
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
    self._pokedexModel = self._modelMgr:getModel("PokedexModel")
    self._purModel = self._modelMgr:getModel("PurgatoryModel")
    self._battleArrayModel = self._modelMgr:getModel("BattleArrayModel")
    self._backupModel = self._modelMgr:getModel("BackupModel")
    -- self:initData(clone(tab.activity901))

    --活动开启表里面是否有嘉年华的活动
    self._isAcOpen = false
end

function ActivityCarnivalModel:setData(data)
    if data then
        self._serverData = data       
    end
    self:updateCarnivalData(data)
end
function ActivityCarnivalModel:initData()

    self._startTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._userModel:getData()._it,"%Y-%m-%d 05:00:00"))
    self._endTime = self._userModel:getData()._it + 7 * 86400
    local currTime = self._userModel:getCurServerTime() 
    -- self._carnivalId = 901
    local activityId = 901 
    local showList = self._acModel:getActivityShowList() or {}

    for k,v in pairs(showList) do
        if 9 == v.ac_type then
            if next(v) and v.start_time <= currTime and v.end_time > currTime then
                activityId = tonumber(v.activity_id)
                self._startTime = v.start_time  -- - 86400*2
                self._endTime = v.end_time

                -- 活动开启表有嘉年华的活动 需要初始化
                self._isAcOpen = true

                break
            end
        end        
    end
    -- self._isAcOpen = true
    -- activityId = 911
    if not self._isAcOpen then return end
    --如果 活动变化重新初始化数据
    if not self._carnivalId or self._carnivalId ~= activityId then
        self._carnivalId = activityId
        -- print("==================self._carnivalId ==activityId=",self._carnivalId ,activityId)
        self._data = clone(tab["activity" .. self._carnivalId])
        if self._data then
            if self._data["total"] == nil then
                self._data["total"] = {} 
                self._data["total"].status = 0  
            end 
        else
            self._data = {}
        end
    end
end

function ActivityCarnivalModel:doUpdate()
    if self._needUpdate then
        self._needUpdate = false
        self:updateCarnivalData()
    end
end

function ActivityCarnivalModel:setNeedUpdate(need)
    -- print("========嘉年华=setNeedUpdate===========",need)
    self._needUpdate = need
end
function ActivityCarnivalModel:getNeedUpdate()
    return self._needUpdate 
end
function ActivityCarnivalModel:updateCarnivalData(data)
    
    -- print("==============ActivityCarnivalModel嘉年华updateCarnivalData=======================")
    
    -- 如果没有数据先初始化数据
    -- if #self._data == 0 then
        self:initData()        
    -- end
    -- 如果开启表中没有嘉年华的活动 数据处理
    if not self._isAcOpen then return end

    if data and data[tostring(self._carnivalId)] then
        -- dump(data,"serverData==>")
        if data[tostring(self._carnivalId)]["ft"] then
            self._totalComNum = data[tostring(self._carnivalId)]["ft"] or 0
        end
        local serverD = data[tostring(self._carnivalId)]["tl"] or {}
        for k,v in pairs(serverD) do
            self._serverData[k] = v
            if k == "total" then
                self._data["total"].status = v
            else
                if self._data[tonumber(k)] then
                    -- self._totalComNum = self._totalComNum + 1
                    self._data[tonumber(k)].status = v  
                end
            end    
        end
    end
    -- 清零
    self._canGetNum = 0

    self._day,_ = self:getCurrDay()
    self._userInfo = self._userModel:getData()
    local userInfo = self._userInfo
    local statis = userInfo.statis
    if not statis then
        statis = {}
    end
    local lvl = userInfo.lvl

    local activityStatic = self._userModel:getActivityStatis() or {}

    local self_getCondition = self.getCondition
    for i,value in pairs(self._data) do
        if not value.status then 
            value.status = 0
        end
        if i ~= "total" then
            if self._day+1 >= value.day and value.status ~= 1 then            
                self_getCondition(self, activityStatic, value, lvl, statis)
            end
        end
    end 
    -- dump(self._serverData)
    self:reflashData()
end

--根据stsId获取条件
function ActivityCarnivalModel:getConByActivityStsId(activityStatic, data)
    if not data then return end
   
    local canGet = false
    local num = 0
    local targetNum = data.condition[1] or 0

    for k,v in pairs(activityStatic) do
        -- print("===================data.stsId=======",data.stsId)
        local timeStr = string_sub(tostring(k), 1, 4) .. "-" .. string_sub(tostring(k), 5, 6) .. "-" .. string_sub(tostring(k), -2)  .. " 05:00:00"
        local stsId = tonumber(data.stsId)
        local time = TimeUtils.getIntervalByTimeString(timeStr)
        if time >= self._startTime and time < self._endTime then
            if v["sts" .. stsId] then
                if 99 ~= stsId and 98 ~= stsId and 106 ~= stsId then
                    num = num + tonumber(v["sts" .. stsId])
                elseif 106 == stsId then
                    -- 累计X天达到活跃度Y 
                    local tNum = data.condition[2] or 0
                    if tonumber(v["sts" .. stsId]) >= tNum then
                        num = num + 1
                    end
                elseif 99 == stsId or 98 == stsId then
                    -- 某天最高
                    if tonumber(v["sts" .. stsId]) > num then
                        num = tonumber(v["sts" .. stsId])
                    end
                end
            end
        end
    end

    if num >= targetNum then 
        canGet = true
    end
    
    return canGet, num,targetNum
end

local getConByActivityStsId = ActivityCarnivalModel.getConByActivityStsId
function ActivityCarnivalModel:getCondition(activityStatic, data, lvl, statis)
    if not data  then return end
    local canGet= false
    local num = 0
    local targetNum = 0
    -- 根据功能类型判断条件
    local fcType = data.fcType
    if fcType then
        -- print("============================fcType===",fcType)
        if self["getConByType" .. fcType] then
            canGet,num,targetNum = self["getConByType" .. fcType](self,data,lvl, statis)           
        else
            if data.stsId then
                canGet,num,targetNum = getConByActivityStsId(self, activityStatic, data)
            else
                -- print("==========类型不存在===========")
            end
        end
    else
        -- dump(data,"data******")
    end

    -- 设置数据状态及条件
    if data.status ~= 1 then   --未领
        if canGet  then
            data.status = 2  
            if data.day <= self._day then                
                self._canGetNum = self._canGetNum + 1
            end
        else
            data.status = 0
        end 
    end
    data.currNum = num
    data.targetNum = targetNum
end

--等级 1
function ActivityCarnivalModel:getConByType1(data,lvl,statis)
    local canGet = false
    local num = lvl or 0
    local targetNum = data.condition[1] or 0

    if tonumber(num) >= tonumber(targetNum) then 
        canGet = true
    end
    return canGet, num,targetNum
end
--判断普通某关卡有没有通关2
function ActivityCarnivalModel:getConByType2(data,lvl,statis)
    local canGet = false
    local num = -1
    local targetNum = -1    
    local stageData = self._instanceModel:getStageInfo(data.condition[1])    
    if stageData.star and stageData.star > 0 then 
        canGet = true
    end
    return canGet, num,targetNum
end
--判断地下城某关卡有没有通关3
function ActivityCarnivalModel:getConByType3(data,lvl,statis)
    local canGet = false
    local num = -1
    local targetNum = -1
    local stageData = self._intanceEliteModel:getStageInfo(data.condition[1])
    -- print(data.id,"====地下城某关卡=================",stageData.star)
    if stageData.star and stageData.star > 0 then 
        canGet = true
    end
    return canGet, num,targetNum
end
--遍历兵团，计算限定品质的兵团个数4
function ActivityCarnivalModel:getConByType4(data,lvl,statis)
    local canGet = false
    local num = 0
    local targetNum = data.condition[2] or 0
    -- data.condition[1] --品质数
    -- data.condition[2] --个数
    local stage = data.condition[1]
    local allTeamData = self._teamModel:getData()
    for k, v in pairs(allTeamData) do
        if v.stage and v.stage >= stage then
            num = num + 1
        end
    end
    canGet = num >= targetNum

    return canGet, num,targetNum
end
--遍历兵团，计算限定星级的兵团个数5
function ActivityCarnivalModel:getConByType5(data,lvl,statis)
    local canGet = false
    local num = 0
    local targetNum = data.condition[2] or 0
    -- data.condition[1] --等级
    -- data.condition[2] --数量  

    local star = data.condition[1]
    local allTeamData = self._teamModel:getData()
    for k, v in pairs(allTeamData) do
        if v.star and v.star >= star then
            num = num + 1
        end
    end
    canGet = num >= targetNum

    return canGet, num,targetNum
end
-- 英雄法术 6
function ActivityCarnivalModel:getConByType6(data,lvl,statis)

    local num = statis.snum14 or 0
    local targetNum = data.condition[1] or 0
    local canGet = num >= targetNum

    return canGet, num,targetNum
end
-- 英雄专精  刷新专精次数7
function ActivityCarnivalModel:getConByType7(data,lvl,statis)   
    local num = statis.snum10 or 0
    local targetNum = data.condition[1] or 0
    local canGet = num >= targetNum

    return canGet, num,targetNum
end
--遍历装备，装备品质达到某值的个数8
function ActivityCarnivalModel:getConByType8(data,lvl,statis)
    local canGet = false
    local num = 0
    local targetNum = data.condition[2] or 0  
    -- data.condition[1] --品质
    -- data.condition[2] --数量    
    local stage = data.condition[1]
    local allTeamData = self._teamModel:getData()
    for k, v in pairs(allTeamData) do
        for i = 1, 4 do
            if v["es" .. i] and v["es" .. i] >= stage then
                num = num + 1
            end
        end
    end
    canGet = num >= targetNum

    return canGet, num,targetNum
end
-- X级兵团装备有多少个9
function ActivityCarnivalModel:getConByType9(data,lvl,statis)
    local canGet = false
    local num = 0
    local targetNum = data.condition[2] or 0
    -- data.condition[1] --等级
    -- data.condition[2] --数量    
    local level = data.condition[1]
    local allTeamData = self._teamModel:getData()
    for k, v in pairs(allTeamData) do
        for i = 1, 4 do
            if v["el" .. i] and v["el" .. i] >= level then
                num = num + 1
            end
        end
    end
    canGet = num >= targetNum

    return canGet, num,targetNum
end
 --竞技场获得经济币10
function ActivityCarnivalModel:getConByType10(data,lvl,statis)
    
    local num = statis.snum11 or 0
    local targetNum = data.condition[1] or 0
    local canGet = num >= targetNum

    return canGet, num,targetNum
end
--竞技场排名11
function ActivityCarnivalModel:getConByType11(data,lvl,statis)
    local num = statis.snum7 or 0
    local targetNum = data.condition[1] or 0    
    canGet = (num > 0 and num <= targetNum)
    targetNum = -1

    return canGet, num,targetNum
end
--开启方尖碑个数12
function ActivityCarnivalModel:getConByType12(data,lvl,statis)
    local num = statis.snum12 or 0
    local targetNum = data.condition[1] or 0    
    local canGet = num >= targetNum

    return canGet, num,targetNum
end
--获得远征币总量13
function ActivityCarnivalModel:getConByType13(data,lvl,statis)
    local num = statis.snum13 or 0
    local targetNum = data.condition[1] or 0
    local canGet = num >= targetNum

    return canGet, num,targetNum
end

--拥有配置的特定兵团 17
function ActivityCarnivalModel:getConByType17(data,lvl,statis)
    local canGet = false
    local num = 0
    local targetNum = 0
    if data.condition then
        targetNum = #data.condition
    end
    --兵团id
    -- data.condition = {102,103,104,105}
    local indexMap = self._teamModel:getIndexMap()
    for k, v in pairs(data.condition) do
        if indexMap[v] then
            num = num + 1
        end
    end
    canGet = num >= targetNum

    return canGet, num,targetNum
end
-- 积分联赛段位达到X 29
function ActivityCarnivalModel:getConByType29(data,lvl,statis)
    --
    local canGet = false
    local num = self._leagueModel:getCurZone()
    local targetNum = data.condition[1]   
    -- print("==========积分联赛段位达到X===================",num,targetNum)
    canGet = num >= targetNum
    num = -1
    targetNum = -1
    return canGet, num,targetNum

end
-- 通关云中城的某关 25
function ActivityCarnivalModel:getConByType25(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    if data.condition then 
        canGet = self._cloudCityModel:getStageHadPass(data.condition[1])
    end  

    return canGet, num,targetNum
    
end
--拥有X个紫色专精  35
function ActivityCarnivalModel:getConByType35(data,lvl,statis)    
    local num = 0
    local targetNum = data.condition[1] or 0
    local canGet = false

    local allHeroData = self._heroModel:getData()
    for k, v in pairs(allHeroData) do
        for i = 1, 4 do
            if v["m" .. i] then --v["sl" .. i] and 
                local masteryData = tab.heroMastery[tonumber(v["m" .. i])]
                if masteryData and 3 == masteryData.masterylv then
                    num = num + 1
                end
            end
        end
    end

    canGet = num >= targetNum   

    return canGet, num,targetNum
end

--拥有X个X阶法术  36
function ActivityCarnivalModel:getConByType36(data,lvl,statis)
    local num = 0
    local targetNum = data.condition[1] or 0
    local canGet = false

    local level = data.condition[2]

    local allHeroData = self._heroModel:getData()
    for k, v in pairs(allHeroData) do
        for i = 1, 4 do
            if v["sl" .. i] >= level then --v["sl" .. i] and 
                num = num + 1
            end
        end
    end
    canGet = num >= targetNum   
     
    return canGet, num,targetNum
end

--拥有XX宝物   40
function ActivityCarnivalModel:getConByType40(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    if data.condition then 
        canGet = self._treasureModel:isTreasureActived(data.condition[1])
    end  
    
    return canGet, num,targetNum
end

-- 通关某类训练营   42
-- 1 新兵 2 精英
function ActivityCarnivalModel:getConByType42(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    if data.condition then 
        print("========data.condition[1]===",data.condition[1])
        canGet = self._trainingModel["isTrainPassByType" .. data.condition[1]](self._trainingModel) --self._treasureModel:isTreasureActived(data.condition[1])
    end  
    
    return canGet, num,targetNum
end
-- 在皇家训练场取得X个S 43
function ActivityCarnivalModel:getConByType43(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    if data.condition then 
        targetNum = data.condition[1]
        num = self._trainingModel:getNumByScore(data.condition[2])
    end  
    canGet = num >= targetNum 
    
    return canGet, num,targetNum
end

-- 觉醒某个兵团 44
function ActivityCarnivalModel:getConByType44(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then 
        local teamdata = self._teamModel:getTeamAndIndexById(cond[1])
        if teamdata then 
            canGet,_ = TeamUtils:getTeamAwaking(teamdata)
        end
    end  
    
    return canGet, num,targetNum
end

-- 将X兵团觉醒至Y星  45
function ActivityCarnivalModel:getConByType45(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then 
        local teamdata = self._teamModel:getTeamAndIndexById(cond[1])
        num = 0
        if teamdata then 
            _,num = TeamUtils:getTeamAwaking(teamdata)
        end
        targetNum = cond[2]
    end  
    canGet = num >= targetNum 
    
    return canGet, num,targetNum
end

-- 拥有X阶Y宝物 48
function ActivityCarnivalModel:getConByType48(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then
        local stage = cond[2] or 1000
        canGet,num = self._treasureModel:isHaveTreasure(cond[1],cond[2])
        targetNum = cond[2] or -1
    end  
    
    return canGet, num,targetNum
end

-- 通过X元素位面第Y层 49
function ActivityCarnivalModel:getConByType49(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        num = self._elementModel:getElementData()["stageId"..cond[1]] or -1
        targetNum = cond[2]
    end  
    canGet = num >= targetNum 
    
    return canGet, num,targetNum
end

-- 击败某难度的龙之国
function ActivityCarnivalModel:getConByType50(data,lvl,statis)
    local num = statis.snum30 or 0
    local targetNum = data.condition[1]
    local canGet = num >= targetNum  
    num = -1
    targetNum = -1
    return canGet, num,targetNum
end

-- 激活X个Y品质M等级的法术
function ActivityCarnivalModel:getConByType53(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false 
    local cond = data.condition
    if cond then  
        canGet,num = self._spellBooksModel:isActivedBooks(cond[2],cond[3],cond[1])
        targetNum = cond[1]
    end 
    
    return canGet, num,targetNum
end
--解锁X个法术刻印孔
function ActivityCarnivalModel:getConByType54(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        canGet,num = self._heroModel:isHaveUnlockSlot(cond[1])
        targetNum = cond[1] or 0
    end 

    return canGet, num,targetNum
end

--副本完成某些章节全部支线任务 55
function ActivityCarnivalModel:getConByType55(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        canGet,_ = self._instanceModel:isBranchComplete(cond)
        targetNum = -1
    end 
    return canGet, num,targetNum
end
-- mapStatis 结构里
-- 激活联盟地图内的X座方尖塔  57 
function ActivityCarnivalModel:getConByType57(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then
        if self._userInfo.mapStatis then
             -- 5代表字段激活方尖塔
            num = self._userInfo.mapStatis["5"] or 0
        end
        targetNum = cond[1]
    end 
    canGet = (num > 0) and (num >= targetNum) or false
    return canGet, num,targetNum
end

-- 击杀联盟地图内的X个boss  58 
function ActivityCarnivalModel:getConByType58(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then
        if self._userInfo.mapStatis then
            --  10击杀boss 
            num = self._userInfo.mapStatis["10"] or 0
        end
        targetNum = cond[1]
    end 
    canGet = (num > 0) and (num >= targetNum) or false
    return canGet, num,targetNum
end

--地下城 获得总星数 60
function ActivityCarnivalModel:getConByType60(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        num = self._intanceEliteModel:getEliteStarNum() 
        targetNum = cond[1] or 0
    end 
    canGet = num >= targetNum
    return canGet, num,targetNum
end


--X个Y阵营兵团大招等级达到M级 63
function ActivityCarnivalModel:getConByType63(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        num = self._teamModel:getTeamSkillMaxLevel(cond[2],cond[3])
        targetNum = cond[1] or 0
    end 
    canGet = num >= targetNum
    return canGet, num,targetNum
end

--X个兵团Y天赋达到M级 66
function ActivityCarnivalModel:getConByType66(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        num = self._teamModel:getTeamTalentNum(cond[2],cond[3])
        targetNum = cond[1] or 0
    end 
    canGet = num >= targetNum
    return canGet, num,targetNum
end

--某个器械 等级达到Y级 67
function ActivityCarnivalModel:getConByType67(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        num = self._weaponsModel:getWeaponTypeLevel(cond[1])
        targetNum = cond[2] or 0
    end 
    canGet = num >= targetNum
    return canGet, num,targetNum
end

--装备X个Y品质器械配件 68
function ActivityCarnivalModel:getConByType68(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        num = self._weaponsModel:getPropNumByStage(cond[2])
        targetNum = cond[1] or 0
    end 
    canGet = num >= targetNum
    return canGet, num,targetNum
end

--激活X个Y系M品质法术 69
function ActivityCarnivalModel:getConByType69(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false 
    local cond = data.condition
    if cond then  
        canGet,num = self._spellBooksModel:isActivedBooks(cond[3],0,cond[1],cond[2])
        targetNum = cond[1]
    end 
    
    return canGet, num,targetNum
end

--激活X个Y系刻印孔 70
function ActivityCarnivalModel:getConByType70(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        canGet,num = self._heroModel:isHaveUnlockSlot(cond[1],cond[2])
        targetNum = cond[1] or 0
    end 

    return canGet, num,targetNum
end

--解锁X名英雄 72
function ActivityCarnivalModel:getConByType72(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then  
        num = self._heroModel:getHeroCount()
        targetNum = cond[1] or 0
    end 
    canGet = num >= targetNum
    return canGet, num,targetNum
end

--拥有某英雄 73
function ActivityCarnivalModel:getConByType73(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
     
    if cond and cond[1] then  
        canGet = self._heroModel:checkHero(cond[1])
        -- targetNum = cond[1] or 0
    end
    return canGet, num,targetNum
end

--  联盟总计获得X点联盟经验
function ActivityCarnivalModel:getConByType77(data,lvl,statis)
    local num = -1
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond then
        if self._userInfo.mapStatis then
            --  12 联盟经验一周累计值
            num = self._userInfo.mapStatis["12"] or 0
        end
        targetNum = cond[1]
    end 
    canGet = (num > 0) and (num >= targetNum) or false
    return canGet, num,targetNum
end

-- 在X图鉴中获得Y个M级评价 79
function ActivityCarnivalModel:getConByType79(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
     
    if cond then  
        num = self._pokedexModel:getPokedexPingByNum(cond[2],cond[3])
        targetNum = cond[1]
        canGet = num >= targetNum
    end
    return canGet, num,targetNum
end
--魔法天赋 技能天赋是否解锁  80
function ActivityCarnivalModel:getConByType80(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
     
    if cond and cond[1] then  
        canGet = self._skillTalentModel:isSkillTalentActive(cond[1])
    end
    return canGet, num,targetNum
end
-- 解锁某攻城器械 81
function ActivityCarnivalModel:getConByType81(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
     
    if cond and cond[1] then  
        canGet = self._weaponsModel:getWeaponLockById(cond[1])
    end
    return canGet, num,targetNum
end

-- 拥有X个Y级M品质圣徽
function ActivityCarnivalModel:getConByType83(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
     
    if cond and cond[1] then  
        local lvl = cond[2] and (tonumber(cond[2]) + 1) or nil
        local q = cond[3]
        num = self._teamModel:getHolyNumByLvlQuality(lvl, q) or 0
        targetNum = cond[1]
        canGet = num >= targetNum
    end
    return canGet, num,targetNum
end
--通关无尽炼狱第X层
function ActivityCarnivalModel:getConByType84(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
     
    if cond and cond[1] then  
        num,_ = self._purModel:getHistoryMaxStageId()
        targetNum = cond[1]
        canGet = num >= targetNum
    end
    return canGet, num,targetNum
end

-- X个阵营战阵战力达到Y
function ActivityCarnivalModel:getConByType86(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond and cond[1] then  
        num = self._battleArrayModel:getRateFightReachNum(cond[2])
        targetNum = cond[1]
        canGet = num >= targetNum
    end
    return canGet, num,targetNum
end

--拥有X个Y级后援阵型
function ActivityCarnivalModel:getConByType87(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition    
    if cond and cond[1] then  
        num = self._backupModel:getBackupLevelReachNum(cond[2])
        targetNum = cond[1]
        canGet = num >= targetNum
    end
    
    return canGet, num,targetNum
end

--拥有X个Y级后援战场技能
function ActivityCarnivalModel:getConByType88(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition  
    if cond and cond[1] then  
        num = self._backupModel:getSkillLevelReachNum1(cond[2])
        targetNum = cond[1]
        canGet = num >= targetNum
    end
    
    return canGet, num,targetNum
end
--拥有X个Y级后援全局特效技能
function ActivityCarnivalModel:getConByType89(data,lvl,statis)
    local num = -2
    local targetNum = -1
    local canGet = false

    local cond = data.condition
    if cond and cond[1] then  
        num = self._backupModel:getSkillLevelReachNum2(cond[2])
        targetNum = cond[1]
        canGet = num >= targetNum
    end
    
    return canGet, num,targetNum
end

function ActivityCarnivalModel:isNoticeaAtDay(dayNum,currDay)
    if dayNum == nil then return end
    local num = 0
    local day,_ = self:getCurrDay()
    if not currDay then 
        currDay = day
    end
    -- print("*********************************",day,dayNum)
    if currDay >= 8 then 
        return false
    end
    for k,v in pairs(self._data) do
        if v.day == dayNum and v.status == 2 then
            num = num + 1
            break
        end
    end

    -- print(num,"*********************************",currDay,dayNum)
    if num > 0 and currDay >= dayNum then
        return true
    else
        return false
    end
    return false
end
function ActivityCarnivalModel:getData()
    return self._data
end

function ActivityCarnivalModel:getTotalStatus()
    return self._totalComNum or 0 --self._userModel:getData()["award"]["sevenAimCount"] or 0
end

function ActivityCarnivalModel:setTotalcanGet(num)
    self._canGetNum = self._canGetNum - num
end

function ActivityCarnivalModel:getTotalcanGet()
    return self._canGetNum or 0
end

---获取嘉年华活动id
function ActivityCarnivalModel:getCarnivalId()
   return self._carnivalId
end

function ActivityCarnivalModel:showNoticeMap( )
    local day,_ = self:getCurrDay()
    -- 活动结束
    if day > 7 then 
        return false
    end
    --有可领奖励
    if self._canGetNum and self._canGetNum > 0 then
        return true
    end

    local completeNum = self:getTotalStatus()
    local totalNum = 0
    if self._data["total"] then 
        totalNum = table.nums(self._data) - 1
    else
        totalNum = table.nums(self._data)
    end
    -- 第七天或者全部完成可以领取
    if (day == 7 or completeNum == totalNum) and self._data["total"] and self._data["total"].status == 0 and completeNum > 0 then
        return true
    end

    return false
   
end

function ActivityCarnivalModel:getCurrDay()
    -- local firstReshTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._userModel:getData()._it,"%Y-%m-%d 05:00:00"))
    -- local createTime = self._userModel:getData()._it
    -- local subTime = createTime - firstReshTime
    -- if subTime < 0 then
    --     firstReshTime = firstReshTime - 86400
    -- end
    -- -- print(TimeUtils.getDateString(self._userModel:getData()._it,"%Y-%m-%d 05:00:00"))
    -- -- local refreshTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(self._userModel:getCurServerTime(),"%Y-%m-%d 05:00:00")) 
    -- local time = self._userModel:getCurServerTime() - firstReshTime 
    -- local leftTime = 86400 - time%86400
    -- self._carnivalDay = math.floor(time/86400)+1

    -- print(TimeUtils.getDateString(self._userModel:getCurServerTime(),"%Y-%m-%d %H:%M:%S"))

    local currTime = self._userModel:getCurServerTime()
    local subTime = currTime - self._startTime
    local leftTime = 86400 - subTime%86400
    local carnivalDay = math.ceil(subTime/86400)   --第几天

    return carnivalDay , leftTime
end

function ActivityCarnivalModel:carnivalIsOpen()
    local isCarnivalOpen = false
    local isOpen,_ = SystemUtils["enablesevenDayAim"]() 
    local showList = self._acModel:getActivityShowList() or {}
    local currTime = self._userModel:getCurServerTime() 
    local acId = 901
    for k,v in pairs(showList) do
        if 9 == v.ac_type then
            if next(v) and v.start_time <= currTime and v.end_time > currTime and isOpen then
                acId = v.activity_id
                isCarnivalOpen = true  
                break              
            end
        end
    end
    local day,_ = self:getCurrDay()
    if day > 7 then
        isCarnivalOpen = false
    end
    return isCarnivalOpen , acId
end

--全目标奖励是否可领
function ActivityCarnivalModel:isTargetCanGet()
    if not self._data then return false end
    local isCanGet = false
    local curDay,_ = self:getCurrDay()
    local totalNum = table.nums(self._data)
    if self._data["total"] then 
        totalNum = totalNum - 1    
    end
    
    if 7 == curDay or self._totalComNum == totalNum then
        if not self._data["total"] then
            isCanGet = true
        elseif self._data["total"].status ~= 1 then
            isCanGet = true
        end
    end

    return isCanGet
end

function ActivityCarnivalModel:setClickState(state)
    -- 全目标奖励是否点击 ，用于判断全目标奖可领时气泡的显示
    self._isTotalBtnClick = state
end
function ActivityCarnivalModel:getClickState()
    return self._isTotalBtnClick or false
end

function ActivityCarnivalModel.dtor()
    tonumber = nil
    tostring = nil
    string_sub = nil
    getConByActivityStsId = nil
end
-- function ActivityCarnivalModel:resetCarnivalData()
--     self._data = {}
--     self._serverData = {}
--     self._canGetNum = 0
--     self._day = 0
-- end



return ActivityCarnivalModel