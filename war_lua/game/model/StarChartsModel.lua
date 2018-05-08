--[[
    @FileName   StarChartsModel.lua
    @Authors    zhangtao
    @Date       2018-03-07 10:56:35
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local StarChartsModel = class("StarChartsModel", BaseModel)
require "game.view.starCharts.StarChartConst"
local StarChartsBodyState = {}    

function StarChartsModel:ctor()
    StarChartsModel.super.ctor(self)
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._data = {}
    -- self.starInfo = nil    --英雄的星图信息
    self.includeBodyTable = {}
    self.selectHeroId = nil
end

function StarChartsModel:setData(data)
    self._data = data
    self:reflashData()
end

function StarChartsModel:getData()
    return self._data
end

--[[
--! @function getBodyIdTable
--! @desc 获取星图包含的星体id
--! @return 
--]]
function StarChartsModel:getBodyIdTable(id)
    self.includeBodyTable = {}
    local catena_id = tab.starCharts[id]["catena_id"]   --包含的分支
    if catena_id == nil or #catena_id == 0 then return end
    for _,id in pairs(catena_id) do
        local starsTable = tab.starChartsCatena[tonumber(id)]["stars"]
        for _,starId in pairs(starsTable) do
            table.insert(self.includeBodyTable,starId)
        end
    end
    return self.includeBodyTable
end

function StarChartsModel:setStarInfoByHeroId(heroId)
    if heroId == nil then return nil end
    self.selectHeroId = heroId
    self.starInfo = self._heroModel:getStarInfo(heroId)
end
function StarChartsModel:getStarInfo()
    if self.starInfo ~= nil then
        return self.starInfo
    end
    return nil
end

function StarChartsModel:updateStarInfo(heroData,upTypeName)
    --heroData 只包含当前英雄星体信息
    -- print("========updateStarInfo=======")
    -- dump(heroData)
    if self.selectHeroId then
        self:setStarInfoByHeroId(self.selectHeroId)
    end
    self:reflashData(upTypeName)
end

--所有星体激活消耗星魂数量
function StarChartsModel:getAllBodyActivityCost()
    local starChartBodyTab = tab.starChartsStars
    local totalCost = 0
    for _ , v in  pairs(self.includeBodyTable) do
        local cost = starChartBodyTab[v]["cost1"]
        totalCost = totalCost + cost
    end
    return totalCost
end

--已激活星体消耗的星魂数量
function StarChartsModel:getActivitedBodyCost()
    local starChartBodyTab = tab.starChartsStars
    local totalCost = 0
    if not self:checkStarListOrNull() then return 0 end
    for k , v in  pairs(self.starInfo["ssIds"]) do
        local cost = starChartBodyTab[tonumber(k)]["cost1"] or 0
        totalCost = totalCost + cost
    end
    return totalCost
end
--所有星体技能等级
function StarChartsModel:getAllBodySkillLevelValue()
    local skillTable = {}
    local starChartBodyTab = tab.starChartsStars
    for _ , v in  pairs(self.includeBodyTable) do
        local ability_magic = starChartBodyTab[v]["ability_magic"]
        if ability_magic ~= nil and ability_magic ~= 0 then
            local magicId = ability_magic[1]
            local magicNum = ability_magic[2]
            if skillTable[magicId] == nil then
                skillTable[magicId] = {}
                skillTable[magicId].num = magicNum
            else
                skillTable[magicId].num = skillTable[magicId].num + magicNum
            end
        end
    end
    print("=========skillTable========")
    dump(skillTable)
    return skillTable
end
--已激活星体技能等级
function StarChartsModel:getActivitedBodySkillLevelValue()
    local skillTable = {}
    local starChartBodyTab = tab.starChartsStars
    if not self:checkStarListOrNull() then return nil end
    for id , v in  pairs(self.starInfo["ssIds"]) do
        local ability_magic = starChartBodyTab[tonumber(id)]["ability_magic"]
        if ability_magic ~= nil and ability_magic ~= 0 then
            local magicId = ability_magic[1]
            local magicNum = ability_magic[2]
            if skillTable[magicId] == nil then
                skillTable[magicId] = {}
                skillTable[magicId].num = magicNum
            else
                skillTable[magicId].num = skillTable[magicId].num + magicNum
            end            
        end
    end
    return skillTable
end

--所有星体英雄属性加成
function StarChartsModel:getAllBodyQualitValue()
    local  qualityTable = {}
    local starChartBodyTab = tab.starChartsStars
    for _ , v in  pairs(self.includeBodyTable) do
        local quality_type = starChartBodyTab[v]["quality_type"]
        if quality_type ~= nil then
            local quality_value = starChartBodyTab[v]["quality"]
            if qualityTable[quality_type] == nil then
                qualityTable[quality_type] = {}
                qualityTable[quality_type].value = quality_value
            else
                qualityTable[quality_type].value = qualityTable[quality_type].value + quality_value
            end
        end

        local abilitySort = starChartBodyTab[tonumber(v)]["ability_sort"]
        local abilityShowtype = starChartBodyTab[tonumber(v)]["ability_showtype"]
        if (abilitySort and abilitySort == 2) and (abilityShowtype and abilityShowtype == 1) then
            local aid = tonumber(starChartBodyTab[tonumber(v)]["ability_hero_type"])
            if aid then
                local pro = 1
                if tab.attClient[aid] == 1 then
                    pro = 0.01
                end
                local value = starChartBodyTab[tonumber(v)]["ability_hero"]
                if qualityTable[aid] == nil then
                    qualityTable[aid] = {}
                    qualityTable[aid].value = value*pro
                else
                    qualityTable[aid].value = qualityTable[aid].value + value*pro
                end
            end
        end

    end
    dump(qualityTable)
    return qualityTable
end
--已激活星体属性
function StarChartsModel:getActivitedBodyQualitValue()
    local  qualityTable = {}
    local starChartBodyTab = tab.starChartsStars
    if not self:checkStarListOrNull() then return nil end
    for id , v in  pairs(self.starInfo["ssIds"]) do
        local quality_type = starChartBodyTab[tonumber(id)]["quality_type"]
        if quality_type ~= nil then
            local quality_value = starChartBodyTab[tonumber(id)]["quality"]
            if qualityTable[quality_type] == nil then
                qualityTable[quality_type] = {}
                qualityTable[quality_type].value = quality_value
            else
                qualityTable[quality_type].value = qualityTable[quality_type].value + quality_value
            end
        end
        local abilitySort = starChartBodyTab[tonumber(v)]["ability_sort"]
        local abilityShowtype = starChartBodyTab[tonumber(v)]["ability_showtype"]
        if (abilitySort and abilitySort == 2) and (abilityShowtype and abilityShowtype == 1) then
            local aid = tonumber(starChartBodyTab[tonumber(v)]["ability_hero_type"])
            if aid then
                local pro = 1
                if tab.attClient[aid] == 1 then
                    pro = 0.01
                end
                local value = starChartBodyTab[tonumber(v)]["ability_hero"]
                if qualityTable[aid] == nil then
                    qualityTable[aid] = {}
                    qualityTable[aid].value = value*pro
                else
                    qualityTable[aid].value = qualityTable[aid].value + value*pro
                end
            end
        end
    end
    return qualityTable
end


--判断星体是否解锁
function StarChartsModel:checkOrLock(bodyId)
    local starInfo = self.starInfo 
    local bodyType = tab.starChartsStars[bodyId]["sort"]
    if StarChartConst.CenterType == bodyType then    --如果选择的星体是中心星体
        -- return self:getTableLength(starInfo["ssIds"])  == #self.includeBodyTable
        return true
    end
    if not self:checkStarListOrNull() then return false end
    for k , v in pairs(starInfo.ssIds) do
       if tonumber(k) == tonumber(bodyId) then
            return true
        end
   end
   return false
end

--检测星体是否可以激活
function StarChartsModel:checkActiveState(bodyId)
    local starChartBodyTab = tab.starChartsStars
    local unlock = starChartBodyTab[bodyId]["unlock"]
    if unlock == nil then
        return true,0
    end
    local tempTable = {}
    local unlock_num = starChartBodyTab[bodyId]["unlock_num"]
    for _ , id in pairs(unlock) do
        local orLock = self:checkOrLock(id)
        if orLock == true then
            table.insert(tempTable,orLock)
        end
    end
    if #tempTable >= tonumber(unlock_num) then
        return true,#tempTable
    end
    return false,#tempTable
end

--检测星体是否相邻
function StarChartsModel:checkBodyAdjacent(bodyId1,bodyId2)
    if bodyId1 == nil or bodyId2 == nil then return false end
    local containIds = tab.starChartsStars[bodyId2]["unlock"]
    for k , v in pairs(containIds) do
        if tonumber(bodyId1) == tonumber(v) then
            return true
        end
    end
    return false
end

--[[
    返回参数：
        catenaId：分支id
        activityNum：当前分支星体中激活的数量
        totalCatenaNum:当前分支中包含星体的数量
    描述:获取星图分支中星体数量
-- ]]
function StarChartsModel:getCatenaNum(starId,bodyId)
    local catenaId,catenaList = self:getCatenaByBodyId(starId,bodyId)
    if catenaList == nil then return nil end
    local totalCatenaNum = #catenaList
    local activityNum = 0    --激活数量
    for _ , v in pairs(catenaList) do
        if self:checkOrLock(v) then
            activityNum = activityNum + 1
        end
    end
    return catenaId,activityNum,totalCatenaNum
end

--获取星体所在的分支列表
function StarChartsModel:getCatenaByBodyId(starId,bodyId)
    local catenaList = tab.starCharts[starId]["catena_id"]
    for _,id in pairs(catenaList) do
        local catenaStars = tab.starChartsCatena[id]["stars"]
        for _ ,k in pairs(catenaStars) do
            if bodyId == k then
                return id,catenaStars
            end
        end
    end
    return nil
end

--根据分支id获取分支中激活的星体数量
function StarChartsModel:getBodyIdsByCatenaId(catenaId)
    if catenaId == nil then return nil end
    local bodyIds = tab.starChartsCatena[catenaId]["stars"]
    local activityNum = 0
    local totalNum = #bodyIds
    for k , v in pairs(bodyIds) do
        if self:checkOrLock(v) then
            activityNum = activityNum + 1
        end
    end
    return activityNum,totalNum
end

--当前星体是否领取奖励
function StarChartsModel:orGetAward(bodyId)
    if self.starInfo == nil or self.starInfo["gIds"] == nil or next(self.starInfo["gIds"]) == nil  then 
        return false
    end
    for id , v in pairs(self.starInfo["gIds"]) do
        if tonumber(id) == tonumber(bodyId) then
            return true
        end
    end
    return false
end
--获取相同类型星体的激活个数及总个数
function StarChartsModel:getShowSortCount(showSort)
    local activityCount,totalCount = 0,0
    for k , v in pairs(self.includeBodyTable) do
        local bodyType = tab.starChartsStars[v]["sort"]
        if StarChartConst.CenterType == bodyType then    --如果选择的星体是中心星体
        else
            local bodyType = tab.starChartsStars[v]["show_sort"] or -1
                if tonumber(showSort) == tonumber(bodyType) then
                totalCount = totalCount + 1
                if self:checkOrLock(v) then
                    activityCount = activityCount + 1
                end
            end
        end
    end
    return activityCount,totalCount
end
--获取可激活的星图id
function StarChartsModel:getCanActivityBodyList(starId)
    local activityTable = {}
    local activityIds = {}
    local centerId = tab.starCharts[starId]["centrality"]
    local convertKey = function(data)
        local tempdata = {}
        for k , v in pairs(data) do
            tempdata[v] = v
        end
        return tempdata
    end
    if self:checkStarListOrNull() then
        for id,v in pairs(self.starInfo["ssIds"]) do
            local unlockTable = tab.starChartsStars[tonumber(id)]["unlock"]
            if unlockTable then
                local keyTable = convertKey(unlockTable)
                table.merge(activityTable,keyTable)
            end
        end
    else
        activityTable = tab.starChartsStars[centerId]["unlock"] or {}
        activityTable = convertKey(activityTable)
    end
    --去除已激活的数据
    if self:checkStarListOrNull() then
        for id,v in pairs(self.starInfo["ssIds"]) do
            if activityTable[tonumber(id)] then
                activityTable[tonumber(id)] = nil
            end
        end
    end
    --去除不可激活的星体
    for id ,v in pairs(activityTable) do
        if self:checkActiveState(id) then
            table.insert(activityIds,id)
        end
    end
    return activityIds
end

--获取Table长度
function StarChartsModel:getTableLength(curTable)
    local count = 0  
    for k,v in pairs(curTable) do  
        count = count + 1  
    end  
    return count
end

function StarChartsModel:checkStarListOrNull()
    if self.starInfo == nil or self.starInfo["ssIds"] == nil or next(self.starInfo["ssIds"]) == nil  then
        return false
    end
    return true
end

function StarChartsModel:getStarActivedNum()
    if not self:checkStarListOrNull() then
       return 0
    end
    return self:getTableLength(self.starInfo["ssIds"]) - 1
end

function StarChartsModel:getStarChartsScore( hStar )
    local starAddScore = 0
    if hStar then
        -- 星体
        for starId,actNum in pairs(hStar.ssmap or {}) do
            local starInfo = tab.starChartsStars[tonumber(starId)]
            if starInfo and actNum > 0 and starInfo.power2 then
                starAddScore = starAddScore+ starInfo.power2*actNum
            end
        end
        -- 星链
        for catenId,catenNum in pairs(hStar.scmap or {}) do
            local catenInfo = tab.starChartsCatena[tonumber(catenId)]
            if catenInfo and catenNum > 0 and catenInfo.power2 then
                starAddScore = starAddScore+ catenInfo.power2*catenNum
            end
        end
        -- 星图(构成)
        for chartsId,chartsNum in pairs(hStar.smap or {}) do
            local starChartsTab = tab.starCharts 
            for i,chartsD in ipairs(starChartsTab) do
                if tonumber(chartsD.hero) == tonumber(chartsId) then
                    starAddScore = starAddScore+ chartsD.power2*chartsNum
                end
            end
        end
    end
    return starAddScore
end

return StarChartsModel