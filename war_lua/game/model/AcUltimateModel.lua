--
-- Author: huangguofang
-- Date: 2018-05-05 16:37:02
--

local AcUltimateModel = class("AcUltimateModel", BaseModel)

local tonumber = tonumber
local tostring = tostring
local string_sub = string.sub
local activityType = 39
AcUltimateModel.activityType = activityType
function AcUltimateModel:ctor()
    AcUltimateModel.super.ctor(self)
    self._data = {}
    self._serverData = {}
    self._canGetNum1 = 0 -- 1联盟
    self._canGetNum2 = 0 -- 2个人
    self._comNum1 = 0 -- 1联盟
    self._comNum2 = 0 -- 2个人
    self._day = 0

    -- self._data = tab.activity901
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._acModel = self._modelMgr:getModel("ActivityModel")


    --活动开启表里面是否有终极降临的活动
    self._isAcOpen = false
end

-- 'taskListPerson'=> 'AutoFieldsNum', //个人任务列表
-- 'taskListGuild' => 'AutoFieldsNum', //工会任务列表
-- 'processReward'=> 'AutoFieldsNum', //进度奖励
-- 'exp' => core_Schema::NUM,

function AcUltimateModel:setData(data)
    if data then
        self._serverData = clone(data)
    end
    if self._data and self._data.taskListPerson then
        for k,v in pairs(self._data.taskListPerson) do
            v.status = 0
        end
    end
    self._comNum2 = 0
    self._canGetNum2 = 0
    self:updateUltimateData(data)
    self:reflashData()
end
function AcUltimateModel:initData()
    self._startTime = 0
    self._endTime = 0
    local currTime = self._userModel:getCurServerTime() 
    local activityId = 5001 
    local showList = self._acModel:getActivityShowList() or {}

    for k,v in pairs(showList) do
        if 39 == v.ac_type then
            if next(v) and v.start_time <= currTime and v.end_time > currTime then
                activityId = tonumber(v.activity_id)
                self._startTime = v.start_time  -- - 86400*2
                self._endTime = v.end_time
                self._limitLvl = v.level_limit or 0
                -- 活动开启表有终极降临的活动 需要初始化
                self._isAcOpen = true
                break
            end
        end        
    end
    -- print("==========self._isAcOpen=====",self._isAcOpen,activityId)
    if not self._isAcOpen then return end
    --如果 活动变化重新初始化数据
    if not self._ultimateId or self._ultimateId ~= activityId then
        self._ultimateId = activityId
        -- print("==================self._ultimateId ==activityId=",self._ultimateId ,activityId)
        self._data = {}
        self._data.taskListPerson = clone(tab["personalTask" .. self._ultimateId])
        if not self._data.taskListPerson then
            self._data.taskListPerson = {}
        end

        self._data.taskListGuild = clone(tab["guildTask" .. self._ultimateId])
        if not self._data.taskListGuild then
            self._data.taskListGuild = {}
        end
        self._data.processReward = {}
        self._data.exp = 0
        self._data.totalExp = 0
    end

end

function AcUltimateModel:doUpdate()
    if self._needUpdate then
        self._needUpdate = false
        self:updateUltimateData()
    end
end

function AcUltimateModel:setNeedUpdate(need)
    -- print("========终极降临=setNeedUpdate===========",need)
    self._needUpdate = need
end

function AcUltimateModel:getNeedUpdate()
    return self._needUpdate 
end

function AcUltimateModel:updateUltimateData(data) 
    self:initData()
    if not self._isAcOpen then return end
    -- dump(data,"data===./",5)
    -- print("===================updateUltimateData===========================")
    self._comNum1 = 0
    self._comNum2 = 0
    if data and data[tostring(self._ultimateId)] then
        -- dump(data,"serverData==>")
        local sData = data[tostring(self._ultimateId)]
        if sData.taskListPerson then
            for k,v in pairs(sData.taskListPerson) do
                if not self._data.taskListPerson[tonumber(k)] then
                    self._data.taskListPerson[tonumber(k)] = {}
                end
                self._data.taskListPerson[tonumber(k)].status = -1
            end
            sData.taskListPerson = nil
        end

        if sData.taskListGuild then
            for k,v in pairs(sData.taskListGuild) do
                if not self._data.taskListGuild[tonumber(k)] then
                    self._data.taskListGuild[tonumber(k)] = {}
                end
                self._data.taskListGuild[tonumber(k)].status = -1
            end
            sData.taskListGuild = nil
        end

        if sData.processReward then
            for k,v in pairs(sData.processReward) do
                self._data.processReward[tonumber(k)] = v
            end
            sData.processReward = nil
        end
        
        for k,v in pairs(sData) do
            self._data[k] = v
        end
    end
    -- 清零
    self._canGetNum1 = 0
    self._canGetNum2 = 0

    -- self._day,_ = self:getCurrDay()
    local userInfo = self._userModel:getData()
    self._userInfo = userInfo
    local statis = userInfo.statis
    if not statis then
        statis = {}
    end
    local lvl = userInfo.lvl

    local activityStatic = self._userModel:getActivityStatis() or {}
    local guildStatis = self._userModel:getAcGuildStatis() or {}

    local self_getCondition = self.getCondition1
    for k,v in pairs(self._data.taskListGuild) do
        if not v.status then 
            v.status = 0
        end
        if v.status == -1  then
            self._comNum1 = self._comNum1 + 1
        end
        self_getCondition(self,guildStatis,v)
    end
    
    self_getCondition = self.getCondition2
    for i,value in pairs(self._data.taskListPerson) do
        if not value.status then 
            value.status = 0
        end
        if value.status == -1  then
            self._comNum2 = self._comNum2 + 1
        end
        self_getCondition(self,activityStatic,value)
    end 

    -- dump(self._data,"self._data==>",5)
    self:reflashData()
end

--根据活动个人stsId获取条件
function AcUltimateModel:getConByActivityStsId(activityStatic, data)
    if not data then return end
   
    local canGet = false
    local num = 0
    local targetNum = data.condition[1] or -1
    -- print("===========getConByActivityStsId=data.condition[1]=========",data.condition[1])
    local currTime = self._userModel:getCurServerTime()
    local currStartT = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 05:00:00"))
    if currStartT > currTime then
        currStartT = currStartT - 86400
    end
    local currendT = currStartT + 86400
    -- 个人当天的统计
    for k,v in pairs(activityStatic) do
        -- print("===================data.stsId=======",data.stsId)
        local timeStr = string_sub(tostring(k), 1, 4) .. "-" .. string_sub(tostring(k), 5, 6) .. "-" .. string_sub(tostring(k), -2)  .. " 05:00:00"
        local stsId = tonumber(data.stsId)
        local time = TimeUtils.getIntervalByTimeString(timeStr)
        if time >= currStartT and time < currendT then
            if v["sts" .. stsId] then
                num = tonumber(v["sts" .. stsId])
                break
            end
        end
    end

    if num >= targetNum and (targetNum > 0) then 
        canGet = true
    end
    
    return canGet, num,targetNum
end
--根据联盟stsId获取条件
function AcUltimateModel:getConByGuildStsId(guildStatic, data)
    if not data then return end
   
    local canGet = false
    local num = 0
    local targetNum = data.condition[1] or -1
    for k,v in pairs(guildStatic) do
        -- print("===================data.stsId=======",data.stsId)
        local timeStr = string_sub(tostring(k), 1, 4) .. "-" .. string_sub(tostring(k), 5, 6) .. "-" .. string_sub(tostring(k), -2)  .. " 05:00:00"
        local stsId = tonumber(data.stsId)
        local time = TimeUtils.getIntervalByTimeString(timeStr)
        if time >= self._startTime and time < self._endTime then
            if v["sts" .. stsId] then
                num = num + tonumber(v["sts" .. stsId])
            end
        end
    end

    if num >= targetNum and targetNum > 0 then 
        canGet = true
    end
    
    -- print(stsId,"===========getConByGuildStsId=data.condition[1]=========",canGet,num,targetNum)
    return canGet, num,targetNum
end

local getConByActivityStsId = AcUltimateModel.getConByActivityStsId
local getConByGuildStsId = AcUltimateModel.getConByGuildStsId
-- 联盟
function AcUltimateModel:getCondition1(activityStatic, data)
   if not data  then return end
    local canGet= false
    local num = 0
    local targetNum = data.condition[1] or -1
    -- 根据功能类型判断条件
    local fcType = data.fcType
    local stsId = data.stsId
    if stsId then
        canGet,num,targetNum = getConByGuildStsId(self, activityStatic, data)
    elseif fcType then
        if self["getConByGuildType" .. fcType] then
            canGet,num,targetNum = self["getConByGuildType" .. fcType](self,data,lvl, statis)   
        end
    end    

    -- 设置数据状态及条件
    if data.status ~= -1 then   --未领
        if canGet then
            data.status = 1  
            self._canGetNum1 = self._canGetNum1 + 1
        else
            data.status = 0
        end 
    end
    data.currNum = num
    data.targetNum = targetNum
end

-- 个人
function AcUltimateModel:getCondition2(activityStatic, data)
    if not data  then return end
    local canGet= false
    local num = 0
    local targetNum = data.condition[1] or -1
    -- 根据功能类型判断条件
    local fcType = data.fcType
    local stsId = data.stsId
    if stsId then
        canGet,num,targetNum = getConByActivityStsId(self, activityStatic, data)
    elseif fcType then
        if self["getConByPersonType" .. fcType] then
            canGet,num,targetNum = self["getConByPersonType" .. fcType](self,data,lvl, statis)   
        end
    end    

    -- 设置数据状态及条件
    if data.status ~= -1 then   --未领
        if canGet  then
            data.status = 1
            self._canGetNum2 = self._canGetNum2 + 1
        else
            data.status = 0
        end 
    end
    data.currNum = num
    data.targetNum = targetNum
end

function AcUltimateModel:getData()
    return self._data
end

function AcUltimateModel:setTotalcanGet(num)
    self._canGetNum = self._canGetNum - num
end

function AcUltimateModel:getTotalcanGet()
    return self._canGetNum or 0
end

-- 获取箱子数据
function AcUltimateModel:getBoxData()
    return self._data.processReward or {}
end

---获取终极降临活动id
function AcUltimateModel:getUltimateId()
   return self._ultimateId
end

function AcUltimateModel:isRedNotice( )
    -- 活动结束
    -- print("==========self:isActivityOpen()===",self:isActivityOpen())
    if not self:isActivityOpen() then 
        return false
    end
     --    -- 有信物可以捐赠
     -- print("==========self._ultimateId===",self._ultimateId)
    if not self._ultimateId then 
        return false
    end
    if not self._guildShowData then
        self._guildShowData = tab.guildShow
    end
    local showData = self._guildShowData[tonumber(self._ultimateId)]
    -- dump(showData,"showdata==>",5)
    local numD = showData.number or {}
    local xinwu = showData.xinwuID
    local itemId = xinwu[2]
    -- print(itemId,"===============num=========",num)
    local _,num = self._itemModel:getItemsById(itemId)
    -- print("============num====",num,self:isTaskRed1(),self:isTaskRed2())
    if num > 0 then
        return true
    end
    --个人有可领奖励
	if self:isTaskRed1() then
    	return true
    end
    -- 联盟有可领奖励
	if self:isTaskRed2() then
    	return true
    end
    -- 宝箱可领    
    local boxData = self._data.processReward or {}
    local userData = self._userModel:getData()
    local donateNum = userData.guildExp or 0
    -- dump(boxData,"boxData==>",5)
    for i=1,#numD do
        if donateNum >= numD[i] and not boxData[numD[i]] then
            return true
        end
    end

    return false
   
end

function AcUltimateModel:getComNum1()
    return self._comNum1
end

function AcUltimateModel:getComNum2()
    return self._comNum2
end

function AcUltimateModel:isTaskRed1()
    return self._canGetNum1 > 0
end

function AcUltimateModel:isTaskRed2()
    return self._canGetNum2 > 0
end

-- 获取活动结束时间
function AcUltimateModel:getAcEndTime()
    return self._endTime
end
-- 获取下次刷新时间
function AcUltimateModel:getNextReflashDay()
    local currTime = self._userModel:getCurServerTime()
    local endTime = self._endTime or currTime
	if currTime > endTime then
		return endTime
	end
    local startTime = self._startTime or currTime
    local subTime = currTime - startTime
    local currDay = math.ceil(subTime/86400)   --第几天

    local nextTime = startTime + currDay*86400
    if nextTime >= endTime then
    	nextTime = endTime
    end

    return nextTime
end

function AcUltimateModel:isActivityOpen()
	local currTime = self._userModel:getCurServerTime()
    local lvl = self._userModel:getPlayerLevel()
    local startTime = self._startTime or currTime
    local endTime = self._endTime or currTime
	if currTime >= startTime and currTime < endTime and lvl >= self._limitLvl then
		return true
	end
	return false
end

function AcUltimateModel:getGuildData()
    local taskListGuild = {}
    local userInfo = self._userModel:getData()
    local lvl = userInfo.lvl
    for k,v in pairs(self._data.taskListGuild) do
        if v.level <= lvl then
            table.insert(taskListGuild, v)
        end
    end
    return taskListGuild
end
function AcUltimateModel:getPersonalData()
    local taskListPerson = {}
    local userInfo = self._userModel:getData()
    local lvl = userInfo.lvl
    for k,v in pairs(self._data.taskListPerson) do
        if v.level <= lvl then
            table.insert(taskListPerson, v)
        end
    end
    return taskListPerson
end

function AcUltimateModel.dtor()
    tonumber = nil
    tostring = nil
    string_sub = nil
    getConByActivityStsId = nil
    activityType = nil
end



return AcUltimateModel