--[[
    Filename:    IntanceModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-06-01 19:57:26
    Description: File description
--]]

local IntanceModel = class("IntanceModel", BaseModel)

function IntanceModel:ctor()
    IntanceModel.super.ctor(self)
    self:initSectionMaxStar()
end

function IntanceModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function IntanceModel:setData(data)

    local sysSections = self:getSysSectionDatas()
    -- 初始化数据
    self._data.mainsData = {}
    self._data.mainsData.acSectionId = sysSections[1].id
    self._data.mainsData.curSectionId = sysSections[1].id
    self._data.mainsData.curStageId = sysSections[1].includeStage[1]
    self._data.mainsData.curStageLevel = 0

    -- self._data.mainsData.lockSection = false
    -- self._data.mainsData.stageLevelInfo = {}
    self._data.mainsData.stageInfo = {}
    self._data.mainsData.sectionInfo = {}

    self._data.mainsData.spBranch = {}

    self._data.mainsData.MSReward = {}
    -- if data == nil then 
    --     self:initOpenNextSectionState()
    -- end
    self:updateMainsData(data)
end

--[[
--! @function updateSectionIdAndStageId
--! @desc 更新可攻打副本信息（包含等级限制，未确认进入逻辑处理）
--! @param 
--! @return 
--]]
function IntanceModel:updateSectionIdAndStageId()
    -- local newCurSectionId = self:getCurMainSectionId()
    local tempCurStageId = self._data.mainsData.curStageId
    local tempNextStageId = tempCurStageId

    local tempNextSectionId = self._data.mainsData.curSectionId
    local flag = 0
    if self._data.mainsData.curStageLevel > 0 then
        local sysSection = self:getSysSectionDatas()
        for k1,v1 in pairs(sysSection) do
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
    elseif self._data.mainsData.curStageLevel == 0 then
        tempNextSectionId = tonumber(string.sub(tempNextStageId, 1 , 5))
    end
    local sysSection = tab:MainSection(tempNextSectionId)
    if tempNextStageId >= tempCurStageId and sysSection ~= nil then 
        local userInfo = self._modelMgr:getModel("UserModel"):getData()
        -- 等级限制，默认将当前可打副本定位到等级满足的
        if tempNextSectionId ~= self._data.mainsData.curSectionId and 
            sysSection.level <= userInfo.lvl and 
             tempNextSectionId <= self._data.mainsData.acSectionId then
                self._data.mainsData.curSectionId = tempNextSectionId
        end
        if tempNextStageId > tempCurStageId then
            self._data.mainsData.curStageId = tempNextStageId
            self._data.mainsData.curStageLevel = 0
        end
    end
end


--[[
--! @function updateMainsData
--! @desc 用于战斗结束更新主线副本信息
--! @param 
--! @return 
--]]
function IntanceModel:updateMainsData(inMainData)
    if inMainData ~= nil then
        dump("inMainData", "test", 10)
        if inMainData["MSReward"] ~= nil then 
            for k,v in pairs(inMainData["MSReward"]) do
                self._data.mainsData.MSReward[k] = v
            end
        end

        if inMainData["spBranch"] ~= nil then 
            for k,v in pairs(inMainData["spBranch"]) do
                self._data.mainsData.spBranch[k] = v
            end
        end
        
        if inMainData.acSectionId ~= nil then 
            self._data.mainsData.acSectionId = inMainData.acSectionId
        end
        if inMainData["stages"] ~= nil then 
            for k,v in pairs(inMainData["stages"]) do
                if tonumber(k) ~= nil then 
                    if tonumber(k) >= self._data.mainsData.curStageId and v.star ~= nil then 
                        self._data.mainsData.curStageId = tonumber(k)
                        if v.star > self._data.mainsData.curStageLevel then 
                            self._data.mainsData.curStageLevel = v.star
                        end
                        -- self._data.mainsData.stageLevelInfo[k] = v.diff
                    end
                    local sourceStage = self._data.mainsData.stageInfo[k]
                    if sourceStage == nil then 
                        sourceStage = v
                    else
                        for k1,v1 in pairs(v) do
                            if type(v1) == "table" and 
                                sourceStage[k1] ~= nil then
                                for h,g in pairs(v1) do
                                    sourceStage[k1][h] = g
                                end
                            else
                                sourceStage[k1] = v1
                            end
                        end
                    end
                    self._data.mainsData.stageInfo[k] = sourceStage
                end
            end
        end
        if inMainData["stageColls"] ~= nil then
            for k,v in pairs(inMainData["stageColls"]) do
                if tonumber(k) ~= nil and 
                    tonumber(k) >= self._data.mainsData.curSectionId then 
                    self._data.mainsData.curSectionId = tonumber(k)
                end
                local sourceSection = self._data.mainsData.sectionInfo[k]
                
                if sourceSection == nil then 
                    sourceSection = v
                else
                    for k1,v1 in pairs(v) do
                        if type(v1) == "table" and 
                            sourceSection[k1] ~= nil then
                            for h,g in pairs(v1) do
                                sourceSection[k1][h] = g
                            end
                        else
                            sourceSection[k1] = v1
                        end
                    end
                end
                self._data.mainsData.sectionInfo[k] = sourceSection

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
-- function IntanceModel:updateMainsData(inSectionId, inStageId, inStageLevel)
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
--! @function getCurMainSectionId
--! @desc 获取当前主线章节id
--! @param 
--! @return 
--]]
function IntanceModel:getCurMainSectionId()

    return self._data.mainsData.curSectionId
end

function IntanceModel:getSysBranchWithStageDatas()
    if self._sysBranchWithStage ~= nil then 
        return self._sysBranchWithStage
    end

    self._sysBranchWithStage = {}
    for k,v in pairs(tab.mainStage) do
        if v.branchId ~= nil then
            for k1,v1 in pairs(v.branchId) do
                self._sysBranchWithStage[v1] = v.id
            end
        end
    end
    return self._sysBranchWithStage
end

--[[
--! @function getSysMainSectionDatas
--! @desc 获得并初始化主线副本系统数据，避免多次刷新数据
--! @param 
--! @return 
--]]
function IntanceModel:getSysSectionDatas()
    if self._sysSectionDatas ~= nil then 
        return self._sysSectionDatas
    end
    self._sysSectionDatas = {}
    local sysSectionDatas = tab.mainSection

    for k,v in pairs(sysSectionDatas) do
        if math.mod(math.floor(v.id/1000), 10) == 1 then 
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



function IntanceModel:getSectionInfo(inSectionId)
    local section = self:getData().mainsData.sectionInfo[tostring(inSectionId)]
    if section == nil then 
        section = {}
        section.num = 0

    end
    if section.num == nil then 
        section.num = 0
    end
    -- if section.sr == nil then 
    --     section.sr = {}
    -- end
    -- 支线初始化
    if section.sb == nil then 
        section.sb = {}
    end
    
    if section.b == nil then 
        section.b = {}
    end
    if section.b.num == nil then 
        section.b.num = 0
    end
    local flag = 0
    local sysMainSection = tab:MainSection(inSectionId)
    for k,v in pairs(sysMainSection.starNum) do
        -- 判断是否领取够
        if section[tostring(v)] == nil then
            flag = 1
        end
    end    
    -- hasUnRecStarBox 是否存在未领取的箱子，不管星星数量是否够
    if flag == 1 then 
        section.hasUnRecStarBox = true
    else
        section.hasUnRecStarBox = false
    end
    return section
end

function IntanceModel:getStageInfo(inStageId)
    local stage = self:getData().mainsData.stageInfo[tostring(inStageId)]
    if stage == nil then 
        stage = {}
        stage.star = 0

        -- stage.diff = 0
        -- stage.num = 0
        -- stage.lastTime = socket.gettime()
        -- stage.rNum = 0
        -- stage.restTime = socket.gettime()
        self._data.mainsData.stageInfo[tostring(inStageId)] = stage
    end
    if stage.branchInfo == nil then 
        stage.branchInfo = {}
    end
    -- stage.branchInfo = {}
    -- stage.branchInfo[1] = 2
    local sectionId = tonumber(string.sub(inStageId, 1 , 5))
    if self._data.mainsData.curStageId and  
        self._data.mainsData.curSectionId then 
        local newSectionId = tonumber(string.sub(inStageId, 1 , 5))
        if self._data.mainsData.curStageId >= inStageId  and 
            self._data.mainsData.curSectionId >= newSectionId then 
            stage.isOpen = true 
        end
    else
        stage.isOpen = false 
    end

    return stage
end

function IntanceModel:getSectionWithStory(inStageId)
    if self._sysSectionWithStory ~= nil then 
        return self._sysSectionWithStory
    end
    self._sysSectionWithStory = {}
    for k,v in pairs(tab.mainStory) do
        for k1,v1 in pairs(v.include) do
            self._sysSectionWithStory[v1] = v.id
        end
    end
    return self._sysSectionWithStory
end
--[[
--! @function haveNumberOfStarsBySectionId
--! @desc 获得并初始化主线副本系统数据，避免多次刷新数据
--! @param inSectionId int 根据章节id获得本节星星数量
--! @return tempStarNum int 总数量
--]]

-- function IntanceModel:haveNumberOfStarsBySectionId(inSectionId)
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

-- 算出最大星星数
function IntanceModel:initSectionMaxStar()
    if tab.setting == nil then return end
    if tab.mainSection == nil then return end
    local maxLevel = tab.setting["G_MAX_TEAMLEVEL"].value
    local mainSectionTab = tab.mainSection
    local levelArr = {}
    for i = 1, maxLevel do
        levelArr[i] = 0
    end

    local min1 = 71001
    local max1 = 0
    local section = min1
    while mainSectionTab[section] do
        section = section + 1
    end
    max1 = section - 1

    local min2 = 72001
    section = min2
    while mainSectionTab[section] do
        section = section + 1
    end
    max2 = section - 1

    -- print(maxLevel, min1, max1, min2, max2)

    local star = 0
    local levelArr1 = {}
    local sD, l
    local curLv = 0
    for i = min1, max1 do
        sD = mainSectionTab[i]
        l = sD["level"]
        if l > curLv then
            if curLv > 0 then
                levelArr1[#levelArr1 + 1] = {curLv, star}
            end
            curLv = l
            if i == max1 then
                star = star + #sD["includeStage"] * 3
                levelArr1[#levelArr1 + 1] = {curLv, star}
            end
        end
        star = star + #sD["includeStage"] * 3
    end
    for i = 1, #levelArr1 do
        if i < #levelArr1 then
            levelArr1[i][3] = levelArr1[i + 1][1] - 1
        else
            levelArr1[i][3] = levelArr1[i][1]
        end
    end
    local d
    for i = 1, #levelArr1 do
        d = levelArr1[i]
        for k = d[1], d[3] do
            levelArr[k] = d[2] 
        end
    end
    levelArr1[#levelArr1][3] = math.max(levelArr1[#levelArr1][3], maxLevel)
    -- dump(levelArr)
    local star = 0
    local levelArr2 = {}
    local sD, l
    local curLv = 0
    for i = min2, max2 do
        sD = mainSectionTab[i]
        l = sD["level"]
        if l > curLv then
            if curLv > 0 then
                levelArr2[#levelArr2 + 1] = {curLv, star}
            end
            curLv = l
            if i == max2 then
                star = star + #sD["includeStage"] * 3
                levelArr2[#levelArr2 + 1] = {curLv, star}
            end
        end
        star = star + #sD["includeStage"] * 3
    end
    for i = 1, #levelArr2 do
        if i < #levelArr2 then
            levelArr2[i][3] = levelArr2[i + 1][1] - 1
        else
            levelArr2[i][3] = levelArr2[i][1]
        end
    end
    levelArr2[#levelArr2][3] = math.max(levelArr2[#levelArr2][3], maxLevel)
    local d
    for i = 1, #levelArr2 do
        d = levelArr2[i]
        for k = d[1], d[3] do
            if levelArr[k] ~= nil then
                levelArr[k] = levelArr[k] + d[2] 
            end
        end
    end

    -- dump(levelArr2)
    -- dump(levelArr)
    self._maxLevelStarArr = levelArr
end

function IntanceModel:getSectionMaxStar()
    if self._maxLevelStarArr == nil then
        self:initSectionMaxStar()
        return self._maxLevelStarArr
    else
        return self._maxLevelStarArr
    end
end

function IntanceModel:noticeView(inData)
    self:reflashData(inData)
end


-- 嘉年华 某些章节的支线任务是否完成
function IntanceModel:isBranchComplete(sectionIds)
    
    if not self._SectionInfoTb then
        self._SectionInfoTb = tab.sectionInfo
    end 
    local includeSection = sectionIds or {}
    
    local isComplete = false
    local minNum = 0
    local maxNum = 0
    local comNum = 0
    local totalNum = 0
    if includeSection then
        for k,v in pairs(includeSection) do
            local sectionId = v
            local sectionData =self:getSectionInfo(sectionId)
            local sectionDataTb = self._SectionInfoTb[tonumber(sectionId)]
            if sectionDataTb and sectionDataTb.branchId and sectionDataTb.finishReward then
                maxNum = sectionDataTb.finishReward[1][1]
                totalNum = totalNum + 1
            end
            minNum = sectionData.b.num
            if minNum > 0 and maxNum > 0 and minNum >= maxNum then
                comNum = comNum + 1
            end
        end
        if comNum == totalNum then
            isComplete = true
        end
    end
    
    return isComplete
end


return IntanceModel