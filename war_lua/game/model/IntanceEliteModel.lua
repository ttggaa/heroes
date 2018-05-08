--[[
    Filename:    IntanceEliteModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-02 18:21:01
    Description: File description
--]]

local IntanceEliteModel = class("IntanceEliteModel", BaseModel)

function IntanceEliteModel:ctor()
    IntanceEliteModel.super.ctor(self)
end

function IntanceEliteModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function IntanceEliteModel:setData(data)
    
    local sysSections = self:getSysSectionDatas()

    -- 初始化数据
    self._data.ecSectionId = sysSections[1].id
    self._data.curSectionId = sysSections[1].id
    self._data.curStageId = sysSections[1].includeStage[1]
    self._data.curStageLevel = 0
    self._data.curSectionOpen = 1

    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local sysMainStage = tab:MainStage(self._data.curStageId)
    if intanceModel:getData().mainsData.curStageId <= sysMainStage.PreId then 
        self._data.curSectionOpen = 0
    end
    -- self._data.stageLevelInfo = {}
    self._data.stageInfo = {}
    self._data.sectionInfo = {} 
    self:updateData(data)
end

function IntanceEliteModel:getCheckCurSectionId()
    local sysSection = tab:MainSection(self._data.curSectionId)
    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local sysMainStage = tab:MainStage(sysSection.includeStage[1])

    local stageInfo = intanceModel:getStageInfo(sysMainStage.PreId)
    local userInfo = self._modelMgr:getModel("UserModel"):getData()
    if sysSection.level <= userInfo.lvl and stageInfo.star > 0 then
       return self._data.curSectionId
    end

    local curSelectedIndex = tonumber(string.sub(self._data.curSectionId, 3 , 5))

    local includeSection = self:getSysSectionDatas()

    local sysSection = includeSection[curSelectedIndex - 1]
    if sysSection == nil then 
        return self._data.curSectionId
    end
    return sysSection.id
end



function IntanceEliteModel:updateSectionIdAndStageId()
    local tempCurStageId = self._data.curStageId
    local tempNextStageId = tempCurStageId
    local tempNextSectionId = self._data.curSectionId
    local flag = 0
    if self._data.curStageLevel > 0 then 
        local sysSections = self:getSysSectionDatas()
        for k1,v1 in pairs(sysSections) do
            for k2,v2 in pairs(v1.includeStage) do
                if tonumber(v2) > tonumber(tempNextStageId) then 
                    tempNextStageId = v2
                    tempNextSectionId = v1.id
                    flag = 1
                    break
                end
            end
            if flag == 1 then 
                break
            end
        end
    elseif self._data.curStageLevel == 0 then
        tempNextSectionId = tonumber(string.sub(tempNextStageId, 1 , 5))
    end

    local sysSection = tab:MainSection(tempNextSectionId)
    if tempNextStageId >= tempCurStageId and sysSection ~= nil then 

        if tempNextSectionId ~= self._data.curSectionId and
             tempNextSectionId <= self._data.ecSectionId then
            self._data.curSectionId = tempNextSectionId
        end

        if tempNextStageId > tempCurStageId then
            self._data.curStageId = tempNextStageId
            self._data.curStageLevel = 0 
        end
    end
end



--[[
--! @function updateData
--! @desc 用于战斗结束更新主线副本信息
--! @param
--! @return 
--]]
function IntanceEliteModel:updateData(inMainData)
    if inMainData ~= nil then
        if inMainData.ecSectionId ~= nil then 
            print("updateMainsData=",inMainData.ecSectionId)
            self._data.ecSectionId = inMainData.ecSectionId
        end

        if inMainData["eliteStages"] ~= nil then 
            for k,v in pairs(inMainData["eliteStages"]) do
                if tonumber(k) ~= nil then 
                    if tonumber(k) >= self._data.curStageId and v.star ~= nil then 
                        self._data.curStageId = tonumber(k)
                        if v.star > self._data.curStageLevel then 
                            self._data.curStageLevel = v.star
                        end
                        -- self._data.stageLevelInfo[k] = v.diff
                    end
                    local sourceStage = self._data.stageInfo[k]
                    if sourceStage == nil then 
                        sourceStage = v
                    else
                        for k1,v1 in pairs(v) do
                            sourceStage[k1] = v1
                        end
                    end
                    self._data.stageInfo[k] = sourceStage
                end
            end
        end

        if inMainData["eliteStageColls"] ~= nil then
            for k,v in pairs(inMainData["eliteStageColls"]) do
                if tonumber(k) ~= nil and 
                    tonumber(k) >= self._data.curSectionId then 
                    self._data.curSectionId = tonumber(k)
                end
                local sourceSection = self._data.sectionInfo[k]
                
                if sourceSection == nil then 
                    sourceSection = v
                else
                    for k1,v1 in pairs(v) do
                        sourceSection[k1] = v1
                    end
                end
                self._data.sectionInfo[k] = sourceSection

            end
        end
    end
    self:updateSectionIdAndStageId()

    self:reflashData()
end

--[[
--! @function updateMainsData
--! @desc 用于战斗结束更新主线副本信息
--! @param inSectionId int 完成的章节id
--! @param inStageId int 完成的副本id
--! @param inStageLevel int 完成的难度（1，2，3）
--! @return 
--]]
-- function IntanceEliteModel:updateMainsData(inSectionId, inStageId, inStageLevel)
--     if inStageLevel <= 0 then 
--         return
--     end

--     if self._data.mainsData.curSectionId < inSectionId then 
--         self._data.mainsData.curSectionId = inSectionId
--     end

--     if   self._data.mainsData.curStageId < inStageId then
--         self._data.mainsData.curStageId = inStageId
--     end

--     if self._data.mainsData.curStageLevel < inStageLevel  then 
--         self._data.mainsData.curStageLevel = inStageLevel
--     end

--     local tempStage = self._data.mainsData.stageInfo[tostring(inStageId)]
--     if tempStage ~= nil
--      and  tonumber(tempStage.diff) < inStageLevel then 
--         tempStage.diff = inStageLevel
--         self._data.mainsData.stageInfo[tostring(inStageId)] = tempStage
--     end
-- end

--[[
--! @function getCurSectionId
--! @desc 获取当前主线章节id
--! @param 
--! @return 
--]]
function IntanceEliteModel:getCurSectionId()
    return self._data.curSectionId
end


function IntanceEliteModel:checkSectionStarState()
    print("IntanceEliteModel:checkSectionStarState=====")
    local sysSectionDatas  = self:getSysSectionDatas()
    for k,v in pairs(sysSectionDatas) do
        local section = self:getSectionInfo(v.id)

        local sysMainSection = tab:MainSection(v.id)
        for k1,v1 in pairs(sysMainSection.starNum) do
            if tonumber(v1) <= section.num  and section[tostring(v1)] == nil then 
                print("return true")
                return true
            end
        end
    end
    print("return false")
    return false
end

--[[
--! @function getSysMainSectionDatas
--! @desc 获得并初始化主线副本系统数据，避免多次刷新数据
--! @param 
--! @return 
--]]
function IntanceEliteModel:getSysSectionDatas()
    if self._sysSectionDatas ~= nil then 
        return self._sysSectionDatas
    end
    self._sysSectionDatas = {}
    local sysSectionDatas = tab.mainSection

    for k,v in pairs(sysSectionDatas) do
        if math.mod(math.floor(v.id/1000), 10) == 2 then 
            table.insert(self._sysSectionDatas, v)
        end
    end
   local sortFunc = function(a, b) 
        if a.id < b.id then
            return true
        end
    end
    table.sort(self._sysSectionDatas, sortFunc)
    return self._sysSectionDatas
end




function IntanceEliteModel:getSectionInfo(inSectionId)
    local section = self:getData().sectionInfo[tostring(inSectionId)]
    if section == nil then 
        section = {}
        section.num = 0
    end
    local flag = 0
    local sysMainSection = tab:MainSection(inSectionId)
    for k,v in pairs(sysMainSection.starNum) do
        -- 判断是否领取够
        if section[tostring(v)] == nil then
            flag = 1
        end
    end    
    -- 增加经营副本章信息是否开启
    if self._data.ecSectionId >= inSectionId then 
        section.isOpen = true
    else
        section.isOpen = false
    end
    -- hasUnRecStarBox 是否存在未领取的箱子，不管星星数量是否够
    if flag == 1 then 
        section.hasUnRecStarBox = true
    else
        section.hasUnRecStarBox = false
    end
    return section
end

function IntanceEliteModel:getStageInfo(inStageId)
    local sysStage = tab:MainStage(tonumber(inStageId))
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local stage = self:getData().stageInfo[tostring(inStageId)]
    if stage == nil then 
        stage = {}
        stage.star = 0
        -- stage.diff = 0
        stage.num = 0
        stage.atkTime = curServerTime
        stage.rNum = 0
        stage.rTime = curServerTime
        self._data.stageInfo[tostring(inStageId)] = stage
    else 
        -- local tempAtkTime = 0 
        -- if stage.atkTime > 0 then
        --     tempAtkTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(stage.atkTime,"%Y-%m-%d 05:00:00"))
        -- end
        -- local tempRestTime = 0
        -- if stage.rTime > 0 then
        --     tempRestTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(stage.rTime,"%Y-%m-%d 05:00:00"))
        -- end
        -- local todayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userTime,"%Y-%m-%d 05:00:00"))
        -- local yesdayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(userTime-86400,"%Y-%m-%d 05:00:00"))
        local todayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
        local yesdayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime - 86400,"%Y-%m-%d 05:00:00"))

        local restTime = 0
        if curServerTime >= todayTime then
            restTime = todayTime
        else
            restTime = yesdayTime
        end

        if stage.atkTime < restTime  then 
            stage.num = 0
            stage.atkTime = restTime
        end
        
        if stage.rTime < restTime then 
            stage.rNum = 0
            stage.rTime = curServerTime
        end
   
        -- local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
        -- if curServerTime >= todayTime then
        --     if todayTime >= stage.atkTime then 
        --         stage.num = 0
        --         stage.atkTime = todayTime
        --     end
        --     if todayTime >= stage.rTime then 
        --         stage.rNum = 0
        --         stage.rTime = curServerTime
        --     end
        -- else
        --     if stage.atkTime <= yesdayTime  then 
        --         stage.num = 0
        --         stage.atkTime = yesdayTime
        --     end
        --     if stage.rTime <= yesdayTime then 
        --         stage.rNum = 0
        --         stage.rTime = curServerTime
        --     end           
        --     -- if inStageId == 7200204 then 
        --     --     dump(stage)
        --     -- end
        -- end
    end

    local activityModel = self._modelMgr:getModel("ActivityModel") 
    -- 活动折扣
    local discount = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_2) or 0

    local privileges = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.JingYingCiShu) or 0
    stage.maxNum = sysStage.num + privileges
    stage.lNum = (sysStage.num + privileges + discount) - stage.num
    
    if stage.branchInfo == nil then 
        stage.branchInfo = {}
    end
    local curSectionId = self:getCheckCurSectionId()
    if self._data.curStageId and curSectionId then 
        local newSectionId = tonumber(string.sub(inStageId, 1 , 5))
        local sysSection = tab:MainSection(newSectionId)
        local userInfo = self._modelMgr:getModel("UserModel"):getData()
        if self._data.curStageId >= inStageId  and 
            curSectionId >= newSectionId and 
            sysSection.level <= userInfo.lvl then 
            stage.isOpen = true 
        else
            stage.isOpen = false 
        end
    else
        stage.isOpen = false 
    end

    return stage
end

--[[
--! @function haveNumberOfStarsBySectionId
--! @desc 获得并初始化主线副本系统数据，避免多次刷新数据
--! @param inSectionId int 根据章节id获得本节星星数量
--! @return tempStarNum int 总数量
--]]

-- function IntanceEliteModel:haveNumberOfStarsBySectionId(inSectionId)
--     print("inSectionId===",inSectionId)
--     local tempStarNum = 0
--     local sysMainSection = tab:MainSection(inSectionId)
--     for k,v in pairs(sysMainSection.includeStage) do
--         if self._data.mainsData.stageInfo[tostring(v)] ~= nil then 
--             tempStarNum = tempStarNum + self._data.mainsData.stageInfo[tostring(v)].diff
--         end
--     end
--     return tempStarNum
-- end

-- 嘉年华  地下城获得星星数
function IntanceEliteModel:getEliteStarNum()
    print("IntanceEliteModel:getEliteStarNum=====")
    local sysSectionDatas  = self:getSysSectionDatas()
    
    local starNum = 0
    for k,v in pairs(sysSectionDatas) do
        local section = self:getSectionInfo(v.id)
        if section.num then
            starNum = starNum + tonumber(section.num)
        end
    end
    return starNum
end

return IntanceEliteModel