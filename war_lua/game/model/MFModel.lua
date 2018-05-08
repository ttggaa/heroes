--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-04-22 18:48:55
--

local MFModel = class("MFModel", BaseModel)

function MFModel:ctor()
    MFModel.super.ctor(self)
    self._data = {} -- {monsters = {},oMonsters = {}}
    self._tasks = {} -- 存 处理过的任务信息
    self._mffriendList = {} -- 存 处理过的任务信息
    self._mfguildList = {}
    -- self._heros = {}
    -- self._teams = {}
    -- self._mfHelpLog = {}
end

function MFModel:setData(data)
    if data["tasks"] then
        self:setTasks(data["tasks"])
        data["tasks"] = nil
    end
    if data["mflist"] then
        self:setMFFriendData(data["mflist"])
        data["mflist"] = nil
    end
    if data["guildlist"] then
        self:setMFGuildData(data["guildlist"])
        data["guildlist"] = nil
    end
    self:setFTask(data)
    self._data = data
end

function MFModel:getData()
    return self._data
end

function MFModel:getFTask()
    return self._fTask
end

function MFModel:setFTask(data)
    if data["fTask"] then
        self._fTask = data["fTask"]
    end
end

function MFModel:setMFFriendData(data)
    self._mffriendList = data
end

function MFModel:setMFGuildData(data)
    self._mfguildList = data
end

function MFModel:updateGuildData(data)
    for k,v in pairs(data) do
        if v.mf then
            self._mfguildList[k] = v.mf
        end
    end
end

function MFModel:updateMFGuildData(dataId)
    if self._mfguildList and self._mfguildList[dataId] then
        self._mfguildList[dataId] = 0
    end
end

function MFModel:updateMFFriendData(dataId)
    if self._mffriendList and self._mffriendList[dataId] then
        self._mffriendList[dataId].mf = 0
    end
end

function MFModel:isHelpFriend()
    local flag = false
    for k,v in pairs(self._mffriendList) do
        if v and v.mf == 1 then
            flag = true
        end
    end

    if flag == false then
        local userModel = self._modelMgr:getModel("UserModel")
        local userid = userModel:getData()._id
        for k,v in pairs(self._mfguildList) do
            if v == 1 and userid ~= k then
                flag = true
            end
        end
    end
    return flag
end

function MFModel:getMFFriendData()
    return self._mffriendList
end

function MFModel:getMFGuildData()
    return self._mfguildList
end

function MFModel:setTasks(data)
    self._tasks = data
    self:reflashData()
end

function MFModel:getTasks()
    return self._tasks or {}
end

--[[
   清空帮助，抢夺信息 
]]

function MFModel:clearHelpInfo()
    for k,v in pairs (self._tasks) do 
        v.robbed = nil
        v.helper = nil
    end
    self:reflashData()
end

function MFModel:setCloudShow(data)
    self._cloudShow = data
end

function MFModel:getCloudShow()
    return self._cloudShow or false
end

function MFModel:updateTasks(data)
    for k,v in pairs(data["tasks"]) do
        for k1,v1 in pairs(v) do
            self._tasks[k][k1] = v1
        end
    end
    self:reflashData()
end

function MFModel:cancleTasks(data)
    for k,v in pairs(data["tasks"]) do
        self._tasks[k] = v 
    end
    self:setFTask(data)
    self:reflashData()
end

function MFModel:startTasks(data)
    for k,v in pairs(data["tasks"]) do
        for kk,vv in pairs(v) do
            self._tasks[k][kk] = vv
        end
    end
    self:setFTask(data)
    
    self:reflashData()
end

function MFModel:getTasksById(index)
	return self._tasks[tostring(index)]
end

function MFModel:getTaskFinish(index, conData)
    local mfData = self:getTasksById(index)
    local selectData = {}
    local heroData = clone(self._modelMgr:getModel("HeroModel"):getData())
    -- local tempHeroData = {}
    for k,v in pairs(heroData) do
        if tonumber(k) == mfData["heroId"] then
            v.heroId = tonumber(k)
            selectData.heroData = clone(v)
        end
    end

    local teamModel = self._modelMgr:getModel("TeamModel")
    if mfData["teams"] then
        local tempTeam = string.split(mfData["teams"], ",")
        -- dump(tempTeam)
        selectData.teamData = {}
        for k,v in pairs(tempTeam) do
            selectData.teamData[tonumber(k)] = clone(teamModel:getTeamAndIndexById(tonumber(v)))
        end
    end
    -- dump(selectData)
    return self:getMFConditionsByNum(selectData, conData, tab:MfTask(mfData["taskId"])["num"])
end

-- 
function MFModel:getMFConditionsByNum(selectData, conData, teamNum)
    local conIndex = conData["conId"]
    local needNum = 0
    if conIndex == 101 then -- 英雄星级
        if selectData["heroData"] then
            needNum = (selectData["heroData"]["star"] or 0)
        else
            needNum = 0
        end
    elseif conIndex == 102 then -- 英雄评分
        if selectData["heroData"] then
            needNum = self._modelMgr:getModel("HeroModel"):getHeroGrade(selectData["heroData"]["heroId"])
        else
            needNum = 0
        end
    elseif conIndex == 201 then -- 兵团
        local sysTeam
        local num = 0
        for i,v in ipairs(selectData["teamData"]) do
            sysTeam = tab:Team(v.teamId)
            print("volume==========", sysTeam.race[1], conData["param1"] )
            if sysTeam.race[1] == conData["param1"] then 
                num = num + 1
            end
        end
        needNum = num
    elseif conIndex == 202 then -- 
        local sysTeam
        local num = 0
        for i,v in ipairs(selectData["teamData"]) do
            sysTeam = tab:Team(v.teamId)
            if sysTeam.class == conData["param1"] then 
                num = num + 1
            end
        end
        needNum = num
    elseif conIndex == 203 then --0
        local num = 0
        local lvlSum = 0
        for i,v in ipairs(selectData["teamData"]) do
            lvlSum = lvlSum + v.level
            num = num + 1
        end
        if num ~= 0 then
            needNum = math.floor(lvlSum/teamNum)
        else
            needNum = num
        end
        
    elseif conIndex == 204 then --0
        local num = 0
        local starSum = 0
        for i,v in ipairs(selectData["teamData"]) do
            starSum = starSum + v.star
            num = num + 1
        end
        if num ~= 0 then
            needNum = math.floor(starSum/teamNum)
        else
            needNum = num
        end
        
    elseif conIndex == 205 then
        local sysTeam
        local num = 0
        for i,v in ipairs(selectData["teamData"]) do
            sysTeam = tab:Team(v.teamId)
            print("volume==========", sysTeam.volume, conData["param1"] )
            if sysTeam.volume == conData["param1"] then 
                num = num + 1
            end
        end
        needNum = num
    elseif conIndex == 206 then
        local num = 0
        for i,v in ipairs(selectData["teamData"]) do
            if v.stage >= conData["param1"] then 
                num = num + 1
            end
        end
        needNum = num
    elseif conIndex == 207 then -- 兵团总评分
        local num = 0
        for i,v in ipairs(selectData["teamData"]) do
            num = num + self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(v)
        end
        needNum = num
    elseif conIndex == 301 then
        local num = 0
        local starSum = 0
        for i,v in ipairs(selectData["teamData"]) do
            starSum = starSum + v.star
            num = num + 1
        end
        needNum = (selectData["heroData"]["star"] or 0) + starSum
    elseif conIndex == 302 then -- 队伍总评分
        local num = 0
        for i,v in ipairs(selectData["teamData"]) do
            num = num + self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(v)
        end
        if selectData["heroData"] then
            needNum = num + self._modelMgr:getModel("HeroModel"):getHeroGrade(selectData["heroData"]["heroId"])
        else
            needNum = num
        end
    end
    print("========", needNum, conIndex)
    return needNum
end 

-- 获取team选择
function MFModel:getMFChoosePerson(index)   
    print("===========", index)
    local mfData = self:getTasksById(index)
    local taskTab = tab:MfTask(mfData["taskId"])
    -- local conIndex = mfData["conId"]

    local tempData = {}
    for k,v in pairs(mfData["condition"]) do
        local tempData1, tempData2
        tempData1, tempData2 = self:getMFByConditions(v)
        tempData[k] = {heroData = clone(tempData1), teamData = clone(tempData2)}
    end
    local selectHero, selectTeam = self:progressMFData(tempData, mfData)
    -- dump(tempData, "tempData =================", 20)
    -- local teamData = clone(self._modelMgr:getModel("TeamModel"):getData())
    -- local heroData = clone(self._modelMgr:getModel("HeroModel"):getData())
    return selectHero, selectTeam
end 

-- 根据条件获取兵团
function MFModel:getMFByConditions(conData)
    local selectHero, selectTeam
    local conIndex = conData["conId"]
    local teamModel = self._modelMgr:getModel("TeamModel")
    -- local heroModel = self._modelMgr:getModel("HeroModel")
    if conIndex == 101 then -- 英雄星级
        selectHero = self:getHeroDataByStar()
    elseif conIndex == 102 then
        selectHero = self:getHeroDataPokedexByScore()
    elseif conIndex == 201 then -- 兵团
        selectTeam = teamModel:getTeamDataByZhenying(conData["param1"])
    elseif conIndex == 202 then -- 
        selectTeam = teamModel:getTeamDataByClass(conData["param1"])
    elseif conIndex == 203 then --0
        selectTeam = teamModel:getTeamDataByLevel()
    elseif conIndex == 204 then --0
        selectTeam = teamModel:getTeamDataByStar()
    elseif conIndex == 205 then
        selectTeam = teamModel:getTeamDataByPeopleNum(conData["param1"])
    elseif conIndex == 206 then
        selectTeam = teamModel:getTeamDataByStage()
    elseif conIndex == 207 then
        selectTeam = teamModel:getTeamDataPokedexByScore(conIndex)
    elseif conIndex == 301 then
        selectHero = self:getHeroDataByStar()
        selectTeam = teamModel:getTeamDataByStar()
    elseif conIndex == 302 then
        selectHero = self:getHeroDataPokedexByScore()
        selectTeam = teamModel:getTeamDataPokedexByScore(conIndex)
    end
    return selectHero, selectTeam
end 

-- 处理获取的兵团
function MFModel:progressMFData(tempData, mfData)
    local selectHero = {}
    local selectTeam = {}

    if tempData["1"]["teamData"] and tempData["2"]["teamData"] then
        for k1,v1 in ipairs(tempData["1"]["teamData"]) do
            for k2,v2 in ipairs(tempData["2"]["teamData"]) do
                if v1.teamId == v2.teamId then
                        v1["tsort" .. mfData["condition"]["2"]["conId"]] = v2["tsort" .. mfData["condition"]["2"]["conId"]]
                        table.insert(selectTeam, v1)

                    -- if self:isTeamChoose(v1.teamId) then
                    --     v1["tsort" .. mfData["condition"]["2"]["conId"]] = v2["tsort" .. mfData["condition"]["2"]["conId"]]
                    --     table.insert(selectTeam, v1)
                    -- else
                    --     v1["tsort" .. mfData["condition"]["2"]["conId"]] = 0
                    --     table.insert(selectTeam, v1)
                    -- end
                    -- if self:isTeamChoose(v1.teamId) then
                    --     v1["tsort" .. mfData["condition"]["2"]["conId"]] = v2["tsort" .. mfData["condition"]["2"]["conId"]]
                    --     table.insert(selectTeam, v1)
                    -- else
                    --     v1["tsort" .. mfData["condition"]["2"]["conId"]] = 0
                    --     table.insert(selectTeam, v1)
                    -- end
                end
            end
        end
    elseif tempData["1"]["teamData"] then
        for k,v in ipairs(tempData["1"]["teamData"]) do
            -- if self:isTeamChoose(v.teamId) then
                table.insert(selectTeam, v)
            -- else
                -- table.insert(selectTeam, v)
            -- end
        end
    elseif tempData["2"]["teamData"] then
        for k,v in ipairs(tempData["2"]["teamData"]) do
            -- if self:isTeamChoose(v.teamId) then
                table.insert(selectTeam, v)
            -- else
                -- table.insert(selectTeam, v)
            -- end
        end
    end

    -- dump(selectTeam)
    -- if tempData["1"]["heroData"] and tempData["2"]["heroData"] then
    --     for k1,v1 in pairs(tempData["1"]["heroData"]) do
    --         for k2,v2 in pairs(tempData["2"]["heroData"]) do
    --             if v1.heroId == v2.heroId then
    --                 table.insert(selectHero, v1)
    --             end
    --         end
    --     end
    -- else
    local heroData
    if tempData["1"]["heroData"] then
        heroData = tempData["1"]["heroData"]
    elseif tempData["2"]["heroData"] then
        heroData = tempData["2"]["heroData"]
    else
        heroData = self:getHeroDataPokedexByScore()
    end

    for i,v in ipairs(heroData) do
        if self:isHeroChoose(v.heroId) then
            table.insert(selectHero, v)
        end
    end

    return selectHero, selectTeam
end 

function MFModel:isHeroChoose(heroId)
    local flag = true
    for k,v in pairs(self._tasks) do
        if v.heroId then
            if v.heroId == tonumber(heroId) then
                flag = false
                break
            end
        end
    end
    return flag
end

-- 已上阵为false
function MFModel:isTeamChoose(teamId)
    local flag = true
    -- dump(self._tasks)
    for k,v in pairs(self._tasks) do
        if v.teams then
            local tempTeam = string.split(v.teams, ",")
            for kk,vv in pairs(tempTeam) do
                if tonumber(vv) == tonumber(teamId) then
                    flag = false
                    break
                end
            end

        end
    end
    return flag
end

function MFModel:getHeroDataByStar()
    local heroData = self._modelMgr:getModel("HeroModel"):getData()
    local tempHeroData = {}
    for k,v in pairs(heroData) do
        v.heroId = k
        table.insert(tempHeroData, v)
    end
    if table.nums(tempHeroData) <= 1 then
        return tempHeroData
    end
    local sortFunc = function(a, b)
        local aStar = a.star
        local bStar = b.star 
        if aStar ~= bStar then
            return aStar > bStar
        end
        return false
    end
    table.sort(tempHeroData, sortFunc)
    return tempHeroData
end

function MFModel:getHeroDataPokedexByScore()
    local heroModel = self._modelMgr:getModel("HeroModel")
    local heroData = heroModel:getData()
    local tempHeroData = {}
    for k,v in pairs(heroData) do
        v.heroId = k
        v.taxScore = heroModel:getHeroGrade(k)
        table.insert(tempHeroData, v)
    end
    if table.nums(tempHeroData) <= 1 then
        return tempHeroData
    end
    local sortFunc = function(a, b)
        local aTaxScore = a.taxScore
        local bTaxScore = b.taxScore 
        if aTaxScore ~= bTaxScore then
            return aTaxScore > bTaxScore
        end
        return false
    end
    table.sort(tempHeroData, sortFunc)
    return tempHeroData
end

-- 获取航海英雄数据
function MFModel:getMFHeroData()
    local heroData = self._modelMgr:getModel("HeroModel"):getData()
    local tempHeroData = {}
    for k,v in pairs(heroData) do
        v.heroId = tonumber(k)
        v.pokeScore = self._modelMgr:getModel("HeroModel"):getHeroGrade(k)
        v.selectMf = 2
        if not self:isHeroChoose(tonumber(k)) then
            v.selectMf = 3
        end
        table.insert(tempHeroData, v)
    end
    local sortFunc = function(a, b)
        local aStar = a.star
        local bStar = b.star 
        local apokeScore = a.pokeScore
        local bpokeScore = b.pokeScore 
        local aSel = a.selectMf
        local bSel = b.selectMf 
        local aHid = tonumber(a.heroId)
        local bHid = tonumber(b.heroId)
        -- print("sel",aSel,bSel,"star",aStar,bStar,"hid",aHid,bHid)
        if aSel ~= bSel then 
            return aSel < bSel 
        elseif apokeScore ~= bpokeScore then
            return apokeScore > bpokeScore 
        elseif aStar ~= bStar then
            return aStar > bStar 
        else
            return aHid < bHid
        end
        return false
    end
    table.sort(tempHeroData, sortFunc)
    return tempHeroData
end

function MFModel:getMFTeamData(index)
    local mfData = self:getTasksById(index)
    local _, selectTeam = self:getMFChoosePerson(index)
    for k,v in pairs(selectTeam) do
        v.selectMf = 5
        v.selectTeamMf = 3
        v.tuijian = 4
        v.pokeScore = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(v)
        if self:isTeamChoose(v.teamId) then
            v.selectMf = 4
            v.selectTeamMf = 2
            v.tuijian = 3
            local conId1 = mfData["condition"]["1"]["conId"]
            local conId2 = mfData["condition"]["2"]["conId"]

            if (conId1 == 201 or conId1 == 202 or conId1 == 205) 
                and (conId2 == 202 or conId2 == 203 or conId2 == 204 or conId2 == 206 or conId2 == 207 or conId2 == 301 or conId2 == 302) then
                if conId2 == 302 or conId2 == 207 then
                    if v["tsort" .. conId1] == 2 then
                        v.selectMf = 1
                        v.tuijian = 1
                        -- v.selectTeamMf = 1
                    else
                        v.selectMf = 3
                    end
                else
                    if v["tsort" .. conId1] == 2 then
                        v.selectMf = 1
                        v.tuijian = 2
                        if v["tsort" .. conId2] >= mfData["condition"]["2"]["param2"] then
                            v.selectMf = 1
                            v.tuijian = 1
                        end

                        -- v.selectTeamMf = 1
                    else
                        v.selectMf = 3
                    end
                end
            elseif conId1 == 201 or (conId2 == 101 or conId2 == 102) then
                if v["tsort" .. conId1] == 2 then
                    v.selectMf = 1
                    v.tuijian = 1
                    -- v.selectTeamMf = 1
                else
                    v.selectMf = 3
                end
            end
        

            -- if (conId1 ~= 101 or conId1 ~= 102) then
            --     if (conId1 == 201 or conId1 == 202 or conId1 == 205) 
            --         and (conId2 == 203 or conId2 == 204 or conId2 == 206 or conId2 == 207 or conId2 == 301 or conId2 == 302) then
            --         -- print ("====2222222========", v["tsort" .. conId1],"=2=====", v["tsort" .. conId2])
            --         if v["tsort" .. conId1] == 2 and v["tsort" .. conId2] >= mfData["condition"]["2"]["param2"] then
            --             v.selectMf = 1
            --             v.tuijian = 1
            --             -- v.selectTeamMf = 1
            --         else
            --             v.selectMf = 3
            --         end
            --     end
            -- elseif (conId1 == 101 or conId1 == 102) 
            --     and (conId2 == 203 or conId2 == 204 or conId2 == 206 or conId2 == 207 or conId2 == 301 or conId2 == 302) then
            --     if v["tsort" .. conId2] >= mfData["condition"]["2"]["param2"] then
            --         v.selectMf = 1
            --         v.tuijian = 1
            --     else
            --         v.selectMf = 3
            --     end
            -- end
        end
    end
    local tsort = "tsort" .. mfData["condition"]["2"]["conId"]
    local sortFunc = function(a, b)
        local aTsort = a[tsort]
        local bTsort = b[tsort] 
        local aSel = a.selectMf
        local bSel = b.selectMf 
        local apokeScore = a.pokeScore
        local bpokeScore = b.pokeScore 
        local aSco = a.score
        local bSco = b.score 
        local atId = a.teamId 
        local btId = b.teamId 
        local atuijian = a.tuijian 
        local btuijian = b.tuijian 
        -- print(aSel, bSel, aSco, bSco)
        if atuijian ~= btuijian then
            return atuijian < btuijian
        elseif aSel ~= bSel then
            return aSel < bSel
        elseif apokeScore ~= bpokeScore then
            return apokeScore > bpokeScore
        -- elseif aSco ~= bSco then
        --     return aSco > bSco
        else
            if atId ~= btId then
                return atId < btId
            end
            -- if aSco > bSco then
            --     return true
            -- end
        end
        return false
    end
    -- dump(selectTeam)
    table.sort(selectTeam, sortFunc)
    -- dump(selectTeam)
    return selectTeam
end

function MFModel:getMFTeamRaceData(index)
    local mfData = self:getTasksById(index)
    local _, tempRaceTeamData = self:getMFChoosePerson(index)
    local selectTeam = {}
    for k,v in pairs(tempRaceTeamData) do
        local conId1 = mfData["condition"]["1"]["conId"]
        if v["tsort" .. conId1] == 2 then
            table.insert(selectTeam, v)
        end
    end

    for k,v in pairs(selectTeam) do
        v.selectMf = 5
        v.selectTeamMf = 3
        v.tuijian = 3
        v.pokeScore = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(v)
        if self:isTeamChoose(v.teamId) then
            v.selectMf = 4
            v.selectTeamMf = 2
            v.tuijian = 2
            local conId1 = mfData["condition"]["1"]["conId"]
            local conId2 = mfData["condition"]["2"]["conId"]

            if conId1 == 201 then
                -- and (conId2 == 202 or conId2 == 203 or conId2 == 204 or conId2 == 206 or conId2 == 207 or conId2 == 301 or conId2 == 302) then
                -- print ("====2222222========", v["tsort" .. conId1],"=2=====", v["tsort" .. conId2])
                if v["tsort" .. conId1] == 2 then
                    v.selectMf = 1
                    v.tuijian = 1
                    -- v.selectTeamMf = 1
                else
                    v.selectMf = 3
                end
            end


            -- if (conId1 ~= 101 or conId1 ~= 102) then
            --     if (conId1 == 201 or conId1 == 202 or conId1 == 205) 
            --         and (conId2 == 203 or conId2 == 204 or conId2 == 206 or conId2 == 207 or conId2 == 301 or conId2 == 302) then
            --         -- print ("====2222222========", v["tsort" .. conId1],"=2=====", v["tsort" .. conId2])
            --         if v["tsort" .. conId1] == 2 and v["tsort" .. conId2] >= mfData["condition"]["2"]["param2"] then
            --             v.selectMf = 1
            --             v.tuijian = 1
            --             -- v.selectTeamMf = 1
            --         else
            --             v.selectMf = 3
            --         end
            --     end
            -- elseif (conId1 == 101 or conId1 == 102) 
            --     and (conId2 == 203 or conId2 == 204 or conId2 == 206 or conId2 == 207 or conId2 == 301 or conId2 == 302) then
            --     if v["tsort" .. conId2] >= mfData["condition"]["2"]["param2"] then
            --         v.selectMf = 1
            --         v.tuijian = 1
            --     else
            --         v.selectMf = 3
            --     end
            -- end
        end
    end
    local tsort = "tsort" .. mfData["condition"]["2"]["conId"]
    local sortFunc = function(a, b)
        local aTsort = a[tsort]
        local bTsort = b[tsort] 
        local aSel = a.selectMf
        local bSel = b.selectMf 
        local aSco = a.pokeScore
        local bSco = b.pokeScore 
        local atId = a.teamId 
        local btId = b.teamId 
        local atuijian = a.tuijian 
        local btuijian = b.tuijian 
        -- print(aSel, bSel, aSco, bSco)
        if atuijian ~= btuijian then
            return atuijian < btuijian
        elseif aSel ~= bSel then
            return aSel < bSel
        elseif aSco ~= bSco then
                return aSco > bSco
        else
            if atId ~= btId then
                return atId < btId
            end
            -- if aSco > bSco then
            --     return true
            -- end
        end
        return false
    end
    -- dump(selectTeam)
    table.sort(selectTeam, sortFunc)
    
    return selectTeam
end

function MFModel:getOpenCity(index)  
    local userModel = self._modelMgr:getModel("UserModel")
    local lvl = userModel:getData().lvl
    local openLv = tab:MfOpen(index).lv 
    
    -- if lvl > openLv then
    --     if not tempOpenCity or index > tempOpenCity then
    --         SystemUtils.saveAccountLocalData("MF_OpenCity", index)
    --     end
    -- else
    local flag = false
    local tempOpenCity = SystemUtils.loadAccountLocalData("MF_OpenCityAnim")
    if lvl == openLv then
        print("======", index, tempOpenCity)
        if not tempOpenCity or index > tonumber(tempOpenCity) then
            SystemUtils.saveAccountLocalData("MF_OpenCityAnim", index)
            flag = true
        end
    end
    -- flag = true
    return flag
    -- -- local curServerTime = userModel:getCurServerTime()
    -- -- local timeDate
    -- -- local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    -- -- if curServerTime > tempCurDayTime then
    -- --     timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    -- -- else
    -- --     timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    -- -- end
    -- local openCity = index
    
    -- -- if tempOpenCity ~= nil and openCity > tempOpenCity then
    -- --     print("MF_OpenCity =====", timeDate)
    -- --     SystemUtils.saveAccountLocalData("MF_OpenCity", openCity)
    -- -- end
    -- return tempOpenCity or 0
end

function MFModel:isMFTip()  
    -- 任务完成
    local flag = false
    local minTime = 100000
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    if not self._tasks or table.nums(self._tasks) == 0 then
        return false
    end
    for k,v in pairs(self._tasks) do
        if v["finishTime"] then
            if (v["finishTime"] - curServerTime) < minTime then
                minTime = (v["finishTime"] - curServerTime)
            end
        elseif not v["finishTime"] then
            flag = true
            break
        end
    end
    if minTime <= 0 then
        flag = true
    end

    -- 有料了
    if flag == false then
        flag = self._tipData or false
    end

    -- -- 没开始任务
    -- if flag == false then
    --     for k,v in pairs(self._tasks) do
    --         if not v.finishTime then
    --             flag = true
    --             break
    --         end
    --     end
    -- end

    -- -- 新岛屿
    -- if flag == false then
    --     local tempOpenCity = SystemUtils.loadAccountLocalData("MF_OpenCityAnim")
    --     if tempOpenCity and tonumber(table.nums(self._tasks)) > tonumber(tempOpenCity) then
    --         print("==新岛屿新岛屿===", tempOpenCity, table.nums(self._tasks))
    --         flag = true 
    --     end
    -- end
    -- print ("===MFModelMFModel======", minTime, flag)
    return flag
end


function MFModel:acMFTip()  
    local flag = self:isMFTip()
    local acModel = self._modelMgr:getModel("ActivityModel")
    if flag == true then
        flag = acModel:getAbilityEffect(acModel.PrivilegIDs.PrivilegID_16) ~= 0
    end
    return flag
end


function MFModel:getMFGoldNum(index)
    local teamModel = self._modelMgr:getModel("TeamModel")
    local heroModel = self._modelMgr:getModel("HeroModel")

    local mfData = self:getTasksById(index)

    if not mfData["teams"] then
        print("兵团出错，请联系管理员")
        self._viewMgr:showTip("兵团出错，请联系管理员")
        return 0
    end
    local teamsData = string.split(mfData["teams"], ",")
    local taxTeamScore = 0
    for i=1,table.nums(teamsData) do
        taxTeamScore = taxTeamScore + teamModel:getTeamPokedexScore(tonumber(teamsData[i]))
    end

    local taxHeroScore = heroModel:getHeroGrade(mfData["heroId"])

    print("taxTeamScore ===", taxTeamScore, "taxHeroScore ===", taxHeroScore)

    local taxScore = taxTeamScore + taxHeroScore

    local taskTab = tab:MfTask(mfData["taskId"])
    local goldNum = taskTab["coefficientA"] * taxScore + taskTab["coefficientB"]
    
    return math.ceil(goldNum*0.1)*10 
end


-- function MFModel:getMFTeamData(conIndex1, conIndex2)
--     local teamData1 = self:getMFTeamData(conIndex1)
--     local teamData2 = self:getMFTeamData(conIndex2)
--     local teamData = {}
--     for k1,v1 in pairs(teamData1) do
--         for k2,v2 in pairs(teamData2) do
--             if v1.teamId == v2.teamId then
--                 table.insert(teamData, v1)
--             end
--         end
--     end

--     local tempTeamData = {}
--     for k,v in pairs(teamData1) do
--         table.insert(teamData, v)
--     end
--     for k,v in pairs(teamData2) do
--         table.insert(teamData, v)
--     end

--     local mfTeamData = {}
--     for k1,v1 in pairs(tempTeamData) do
--         for k2,v2 in pairs(teamData) do
--             if tempTeamData.teamId == teamData.teamId then
                
--             end
--         end
--     end
--     return teamData
-- end 



function MFModel:setEnemyData(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        v.teamId = tonumber(k)
        tempData[tonumber(k)] = v
    end
    self._enemyData = tempData
end


function MFModel:getEnemyDataById(inTeamId)
    if self._enemyData == nil then 
        return nil
    end
    return self._enemyData[tonumber(inTeamId)]
end

function MFModel:setEnemyHeroData(inData)
    self._enemyHeroData = inData
end

function MFModel:getEnemyHeroData()
    if self._enemyHeroData == nil then 
        return nil
    end
    return self._enemyHeroData
end

-- tip 数据
function MFModel:getTipData()
    return self._tipData
end

function MFModel:setTipData(flag)
    if flag and flag == true then
        self._tipData = true
    else
        self._tipData = false
    end
end

-- 航海弹板数据整理
function MFModel:getOneKeyEndData()
    local taskData = self._modelMgr:getModel("MFModel"):getTasks()
    local robbed = {}
    local helper = {}

    local filter1 = {}
    local filter2 = {}
    local countRob = 0
    local countHelp = 0
    for k,v in pairs(taskData) do
        if v.robbed and type(v.robbed) == "table" then
            for kk,rob in pairs(v.robbed) do
                countRob = countRob + 1
                if rob._id and not filter1[rob._id] then 
                    filter1[rob._id] = 1 
                    table.insert(robbed, rob)
                end
            end
        end
        if v.helper and type(v.helper) == "table" then
            for kk,help in pairs(v.helper) do
                countHelp = countHelp + 1
                if help._id and not filter2[help._id] then 
                    filter2[help._id] = 1 
                    table.insert(helper, help)
                end
            end
        end
    end
    return robbed, helper, countRob, countHelp
end

--领主管家 自动派驻     add by haotaian  --不足返回nil
function MFModel:getHeroAndTeamsByTaskId(id)
    local hero = nil
    local teams = {}
    local mfData = self:getTasksById(id)
    local taskTab = tab:MfTask(mfData["taskId"])
    local selectHero = self:getMFHeroData()
    local selectTeam = self:getMFTeamData(id)

    for i=1,table.nums(selectHero) do
        if selectHero[i].selectMf ~= 3 then
            hero = selectHero[i]
            break 
        end
    end

    for i=1,table.nums(selectTeam) do
        if table.nums(teams) < taskTab.num then
            if selectTeam[i].selectMf ~= 5 then
                table.insert(teams, selectTeam[i])
            end
        else
            break
        end
    end

    if table.nums(teams) < taskTab.num then
        teams = nil
    end

    return hero,teams
end

--领主管家获取所有奖励  add by haotaian
function MFModel:getAllGifts()
    local allGifts = {}
    for i=1,6 do
        local cityTab = tab:MfOpen(i)
        local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
        if userlvl >= cityTab["lv"] then
            local tasks = self:getTasks()
            local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            local tempTask = tasks[tostring(i)]
            if tempTask.finishTime and currentTime-tempTask.finishTime>=0 then
                local gifts = self:getGift(i)
                table.insert(allGifts, {index = i, gifts = gifts})
            end
        end
    end
    return allGifts
end

--领主管家汇总奖励  -- add by haotaian
function MFModel:getGift(index)
    local mfModel = self._modelMgr:getModel("MFModel")
    local mfData = self:getTasksById(index)

    local goldNum = self:getMFGoldNum(index)

    local tempCon1 = self:getTaskFinish(index, mfData["condition"]["1"])
    local tempCon2 = self:getTaskFinish(index, mfData["condition"]["2"])

    local taskTab = tab:MfTask(mfData["taskId"])
    local gifts = {}

    for k,v in pairs(taskTab["awardBase"]) do
        gifts[v[1] .. v[2]] = clone(v)
    end

    if tempCon1 >= mfData["condition"]["1"]["param2"] then
        for k,v in pairs(taskTab["awardOne"]) do
            local str = v[1] .. v[2]
            if not gifts[str] then
                gifts[str] = clone(v)
            else
                gifts[str][3] = gifts[str][3] + v[3]
            end
        end
    end
    
    if tempCon2 >= mfData["condition"]["2"]["param2"] then
        for k,v in pairs(taskTab["awardTwo"]) do
            local str = v[1] .. v[2]
            if not gifts[str] then
                gifts[str] = clone(v)
            else
                gifts[str][3] = gifts[str][3] + v[3]
            end
        end
    end

    local tempGifts = {}
    for k,v in pairs(gifts) do
        table.insert(tempGifts, v)
    end
    
    local sortFunc = function(a, b)
        local atsort = a[2]
        local btsort = b[2]
        if atsort == nil or btsort == nil then
            return 
        end
        if atsort ~= btsort then
            return atsort < btsort
        else
            if IconUtils.iconIdMap[a[1]] > IconUtils.iconIdMap[b[1]] then
                return true
            end
        end
    end
    table.sort(tempGifts, sortFunc)

    tempGifts[1][3] = tempGifts[1][3] + goldNum
    
    return tempGifts
end

return MFModel
