--[[
    Filename:    GodWarModel.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-31 16:40:29
    Description: File description
--]]

--[[
-- s 种子选手标签
-- r 最好成绩
--]]
local GodWarModel = class("GodWarModel", BaseModel)
local GodWarUtil = GodWarUtil
local jiange = GodWarUtil.fightTime -- 每场间隔
local readlyTime = GodWarUtil.readlyTime -- 准备间隔
local fightTime = GodWarUtil.fightTime -- 战斗间隔
function GodWarModel:ctor()
    GodWarModel.super.ctor(self)
    self._data = {}
    self._player = {}
    self._groupBattle = {}
    self._warBattle = {}
    self._stakeList = {}
    self._godwarClose = false
    self._userModel = self._modelMgr:getModel("UserModel")

    self:registerTimer(0, 0, 3, function ()
        self:updateGodWarConstData()
    end)

    self:registerTimer(20, 0, 0, function ()
        self:updateLayer()
    end)

    -- 赛前通知
    self:registerTimer(19, 55, 0, function ()
        local isOpen = SystemUtils["enableGodWar"]()
        if isOpen == true then
            self:showGodWarTip(1)
            self:showGodWarTip(2)
        end
    end)

    self:registerTimer(19, 30, 0, function ()
        self:updateLayer()
    end)
end


-------------------------------------------------------------
-- 更新玩家数据
function GodWarModel:updatePlayerData(data)
    if table.nums(data) == 0 then
        self._godwarClose = true
    end
    if data["jn"] then
        self:setPlayer(data["jn"])
        data["jn"] = nil
    end
    self:updateDispersedData(data)
    self:reflashData()
end

-- 更新零散数据
function GodWarModel:updateDispersedData(data)
    if not self._dispersedData then
        self._dispersedData = {}
    end
    for k,v in pairs(data) do
        self._dispersedData[k] = v
    end
end

function GodWarModel:getDispersedData()
    return self._dispersedData
end
--------------------------------------------------------


function GodWarModel:setData(data)
    -- dump(data, "data======", 5)
    if data["jn"] then
        self:setPlayer(data["jn"])
        data["jn"] = nil
    end
    if data["gp"] then
        self:setGroupBattle(data["gp"])
        data["gp"] = nil
    end
    if data["war"] then
        self:setWarBattle(data["war"])
        data["war"] = nil
    end
    if data["stakeList"] then
        self:setWarStakeList(data["stakeList"])
        data["stakeList"] = nil
    end
    self:updateDispersedData(data)
    self:reflashData()
end

    function GodWarModel:setWarStakeList(data)
        self._stakeList = data.list
        self:reflashData()
    end

    function GodWarModel:setReceiveStakeList(indexId)
        self._stakeList[indexId].receive = 1
        self:reflashData()
    end

    function GodWarModel:getWarStakeTip()
        local flag = false
        for k,v in pairs(self._stakeList) do
            if v.receive == 0 then
                if v.win == 1 then
                    flag = true
                    break
                end
            end
        end
        return flag
    end


-- 小组赛数据
    function GodWarModel:setGroupBattle(data)
        self:updateGroupData(data)
        self._groupBattle = data
        self._groupPlayer = nil
    end

    function GodWarModel:updateGroupIdData(baseData, gp)
        local groupData = {}
        for round=1,3 do
            local roundData = baseData[tostring(round)]
            if not groupData[round] then
                groupData[round] = {}
            end
            if not roundData then
                roundData = {}
            end
            for per=1,2 do
                local indexId = per*2
                local perData = roundData[tostring(per)]
                if not perData then
                    perData = {}
                end
                perData.gp = gp
                perData.round = round
                perData.per = per
                perData.pow = 32
                if per == 1 then
                    perData.title = round
                    indexId = per*2-1
                else
                    perData.title = 0
                    indexId = indexId
                end
                -- if not groupData[round][per] then
                --     groupData[round][per] = {}
                -- end
                groupData[round][per] = perData
            end
        end
        return groupData
    end

    function GodWarModel:updateGroupData(data)
        if not self._groupAllData then
            self._groupAllData = {}
        end
        for gp=1,8 do
            local groupData = data[tostring(gp)]
            if groupData then
                self._groupAllData[gp] = self:updateGroupIdData(groupData, gp)
            end
        end
    end

    -- 处理小组赛数据
    function GodWarModel:progressGroupData()
        local player = self:getPlayer()
        local tgroupData = {}
        for i=1,8 do
            tgroupData[i] = {}
        end
        -- 取小组赛里面的数据
        -- local test = self:getGroupAllproData()
        -- for gp=1,8 do
        --     local group = test[gp][1]
        --     local groupUser = {}
        --     for i=1,2 do
        --         local groupBattle = group[i]
        --         local indexId = i*2-1
        --         groupUser[indexId] = self:getPlayerById(groupBattle.atk)
        --         indexId = i*2
        --         groupUser[indexId] = self:getPlayerById(groupBattle.def)
        --     end
        --     tgroupData[gp] = groupUser
        -- end

        for k,v in pairs(player) do
            tgroupData[v.gp][v.s] = v 
        end
        local groupData = {}
        for i=1,8 do
            groupData[i] = {}
            local ttgroupData = tgroupData[i]
            local sortFunc = function(a, b)
                local an = a.n
                local bn = b.n
                local amn = a.mn
                local bmn = b.mn
                local as = a.s
                local bs = b.s
                if an ~= bn then
                    return an > bn
                elseif amn ~= bmn then
                    return amn > bmn
                elseif as ~= bs then
                    return as < bs
                end
            end
            table.sort(ttgroupData, sortFunc)
            for j=1,4 do
                if not ttgroupData[j] then
                    ttgroupData[j] = {}
                end
                groupData[i][j] = ttgroupData[j]["rid"]
            end
        end
        self._groupPlayer = groupData
        -- return groupData
    end

    -- 获取小组数据
    function GodWarModel:getGroupPlayer()
        if not self._groupPlayer then
            self:progressGroupData()
        end
        return self._groupPlayer
    end

    function GodWarModel:getGroupPlayerById(groupId)
        if not self._groupPlayer then
            self:progressGroupData()
        end

        return self._groupPlayer[groupId]
    end

    function GodWarModel:getGroupAllproData()
        return self._groupAllData
    end

    -- 获取小组赛数据
    function GodWarModel:getGroupData()
        return self._groupBattle
    end

    function GodWarModel:updateGroupBattleData(data)
        if not data then
            return
        end
        dump(data)
        self:updateGroupData(data)
        -- self:updateGroupIdData(baseData)
        for k1,v1 in pairs(data) do --[12]
            if not self._groupBattle[k1] then
                self._groupBattle[k1] = {}
            end
            for k2,v2 in pairs(v1) do --[21]
                self._groupBattle[k1][k2] = v2
            end
        end
        self:progressGroupData()
        self:reflashData()
    end


-- 争霸赛数据
    function GodWarModel:setWarBattle(data)
        self:progressWarBattle(data)
        self._warBattle = data
        self._warTuData = nil
        self._xianData = nil
        self._winData = nil
    end

    function GodWarModel:getWarId(powId, round)
        local indexId = 1
        if powId == 8 then
            indexId = round
        elseif powId == 4 then
            indexId = round + 4
        elseif powId == 2 then
            indexId = 7
        end
        return indexId
    end

    function GodWarModel:progressWarBattle(data)
        if not self._powData then
            self._powData = {}
        end
        local powData = self._powData
        for k,v in pairs(data) do
            -- dump(v)
            if k == "8" then
                for index=1,4 do
                    local indexId = index
                    local roundData = v[tostring(indexId)]
                    if not roundData then
                        roundData = {}
                    end
                    if indexId == 1 then
                        roundData.title = 18
                    else
                        roundData.title = 0
                    end
                    roundData.round = indexId
                    roundData.pow = 8
                    powData[indexId] = roundData
                end
            elseif k == "4" then
                for index=5,6 do
                    local indexId = index - 4
                    local roundData = v[tostring(indexId)]
                    if not roundData then
                        roundData = {}
                    end
                    if indexId == 1 then
                        roundData.title = 14
                    else
                        roundData.title = 0
                    end
                    roundData.round = indexId
                    roundData.pow = 4
                    powData[index] = roundData
                end
            elseif k == "2" then
                for index=7,7 do
                    local indexId = index - 6
                    local roundData = v[tostring(indexId)]
                    if not roundData then
                        roundData = {}
                    end
                    if indexId == 1 then
                        roundData.title = 12
                    else
                        roundData.title = 0
                    end
                    roundData.round = indexId
                    roundData.pow = 2
                    powData[index] = roundData
                end
            elseif k == "3" then
                for index=8,8 do
                    local indexId = index - 7
                    local roundData = v[tostring(indexId)]
                    if not roundData then
                        roundData = {}
                    end
                    if indexId == 1 then
                        roundData.title = 13
                    else
                        roundData.title = 0
                    end
                    roundData.round = indexId
                    roundData.pow = 3
                    powData[index] = roundData
                end
            end
        end
        self._powData = powData
    end

    function GodWarModel:getPowData()
        return self._powData
    end

    function GodWarModel:updateWarBattleData(data)
        if not data then
            return
        end
        self._warTuData = nil
        self._xianData = nil
        self._winData = nil
        self:progressWarBattle(data)
        for k,v in pairs(data) do
            if not self._warBattle[k] then
                self._warBattle[k] = {}
            end
            for k1,v1 in pairs(v) do
                if not self._warBattle[k][k1] then
                    self._warBattle[k][k1] = {}
                end
                for k2,v2 in pairs(v1) do
                    self._warBattle[k][k1][k2] = v2
                end
            end
        end

        self:progressWarData()
        self:reflashData()
    end


    -- 争霸赛
    function GodWarModel:getWarTuData()
        if not self._warTuData then
            self:progressWarData()
        end
        return self._warTuData
    end

    function GodWarModel:getWarXianTuData()
        if not self._xianData then
            self:progressWarData()
        end
        return self._xianData
    end

    function GodWarModel:getWarWinData()
        if not self._winData then
            self:progressWarData()
        end
        return self._winData
    end

    function GodWarModel:replaceProgressWarData()
        self:progressWarData()
        -- self:reflashData()
    end

    -- 处理晋级赛图数据
    function GodWarModel:progressWarData()
        local tWarData = {}
        for i=1,17 do
            tWarData[i] = 0
        end

        local xianData = {}
        for i=1,17 do
            xianData[i] = {0, 0}
        end

        local winData = {}
        for i=1,17 do
            winData[i] = 1
        end

        local war = self:getWarDataById(8)
        self:updateWarData(war, 4, 8, tWarData, xianData, winData)

        local war = self:getWarDataById(4)
        local flag = self:getShowTuTime(8)
        if not flag then
            self:updateWarData(war, 2, 4, tWarData, xianData, winData)
        end

        local war = self:getWarDataById(2)
        local flag = self:getShowTuTime(3)
        if not flag then
            self:updateWarData(war, 1, 2, tWarData, xianData, winData)
        end

        local war = self:getWarDataById(3)
        local flag = self:getShowTuTime(4)
        if not flag then
            self:getFailData(war, 1, 3, tWarData, winData)
        end

        self._xianData = xianData
        self._warTuData = tWarData
        self._winData = winData
    end

    function GodWarModel:getShowTuTime(powId)
        local flag = false
        local godWarConstData = self._userModel:getGodWarConstData()
        local curServerTime = self._userModel:getCurServerTime()
        local begTime = godWarConstData["RACE_BEG"]
        if begTime ~= 0 then
            local weekday = tonumber(TimeUtils.date("%w", curServerTime))
            if weekday == 3 and powId == 8 then
                local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
                if curServerTime < endTime then
                    flag = true
                end
            elseif weekday == 4 then
                if powId == 4 then
                    local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
                    if curServerTime < endTime then
                        flag = true
                    end
                elseif powId == 3 then
                    local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
                    if curServerTime < endTime then
                        flag = true
                    end
                elseif powId == 2 then
                    local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
                    if curServerTime < endTime then
                        flag = true
                    end
                end
            end
        end
        return flag
    end 

    function GodWarModel:getGodWarPowState(powId, round)
        print("getGodWarPowS=+++++++++++++======", powId, round)
        local state = false
        local godWarConstData = self._userModel:getGodWarConstData()
        local curServerTime = self._userModel:getCurServerTime()
        local begTime = godWarConstData["RACE_BEG"]
        local endTime = godWarConstData["RACE_END"]
        -- if curServerTime >= begTime and curServerTime <= endTime then
        if begTime ~= 0 then
            local weekday = tonumber(TimeUtils.date("%w", curServerTime))
            if weekday == 3 then
                local middleTime = readlyTime + fightTime*3
                local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
                local tempTime1 = baseTime + (round-1)*middleTime
                -- local tempTime2 = baseTime + (round-1)*middleTime + readlyTime
                local tempTime2 = baseTime + (round)*middleTime - 5

                print("curServerTime=======", curServerTime, tempTime1, tempTime2)
                if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
                    state = true
                end
            elseif weekday == 4 then
                if powId == 4 then
                    local middleTime = readlyTime + fightTime*3
                    local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
                    local tempTime1 = baseTime + (round-1)*middleTime
                    -- local tempTime2 = baseTime + (round-1)*middleTime + readlyTime
                    local tempTime2 = baseTime + (round)*middleTime - 5
                    if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
                        state = true
                    end
                elseif powId == 2 then
                    local readlyTime = 300
                    local middleTime = readlyTime + fightTime*3
                    local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
                    local tempTime1 = baseTime
                    local tempTime2 = baseTime + middleTime - 5
                    if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
                        state = true
                    end
                end
            end
        end
        print("getGodWarPowS=======", state)

        return state
    end

    function GodWarModel:getFailData(war, count, jinji, tWarData, winData)
        local warWin = {
            [8] = {0, 8},
            [4] = {8, 12},
            [3] = {15, 17},
            [2] = {12, 14},
            [1] = {14, 15},
        }
        local xishu = warWin[jinji]
        if war then
            dump(war)
            for i=1, count do
                local warData = war[tostring(i)]
                local atkId = warData["atk"]
                local indexId = xishu[1] + i*2-1
                tWarData[indexId] = atkId

                local defId = warData["def"]
                tWarData[indexId+1] = defId

                print("indexId=======", i, indexId)
                local winId = 0
                if warData["win"] == 1 then
                    winId = atkId
                    winData[indexId+1] = 0
                elseif warData["win"] == 2 then
                    winId = defId
                    winData[indexId] = 0
                end
            end
        end
    end

    function GodWarModel:updateWarData(war, count, jinji, tWarData, xianData, winData)
        local warWin = {
            [8] = {0, 8},
            [4] = {8, 12, 15},
            [3] = {15, 17},
            [2] = {12, 14},
            [1] = {14, 15},
        }
        local xishu = warWin[jinji]
        if war then
            for i=1, count do
                local warData = war[tostring(i)]
                local atkId = warData["atk"]
                local indexId = xishu[1] + i*2-1
                tWarData[indexId] = atkId

                local defId = warData["def"]
                tWarData[indexId+1] = defId

                print("indexId=======", i, indexId)
                local winId = 0
                local failId = 0
                if warData["win"] == 1 then
                    winId = atkId
                    failId = defId
                    winData[indexId+1] = 0
                    xianData[indexId][1] = 1
                elseif warData["win"] == 2 then
                    failId = atkId
                    winId = defId
                    winData[indexId] = 0
                    xianData[indexId][1] = 2
                else
                    xianData[indexId][1] = 0
                end

                local flag = self:getGodWarPowState(warData.pow, warData.round)
                -- print("xishu[2]+i===============", indexId, xishu[2]+i, indexId+1, flag, indexId, warData["win"])
                if flag == true then

                else
                    if winId ~= 0 then
                        xianData[indexId][2] = 1
                    end
                    tWarData[xishu[2]+i] = winId
                    if xishu[3] then
                        tWarData[xishu[3]+i] = failId
                    end
                end
            end
        end
    end
    -- function GodWarModel:updateWarData(war, count, jinji, tWarData, xianData, winData)
    --     local warWin = {
    --         [8] = {0, 8},
    --         [4] = {8, 12},
    --         [2] = {12, 14},
    --         [1] = {14, 15},
    --     }
    --     local xishu = warWin[jinji]
    --     if war then
    --         for i=1, count do
    --             local warData = war[tostring(i)]
    --             local atkId = warData["atk"]
    --             local indexId = xishu[1] + i*2-1
    --             tWarData[indexId] = atkId

    --             local defId = warData["def"]
    --             tWarData[indexId+1] = defId

    --             print("indexId=======", indexId)
    --             local winId = 0
    --             if warData["win"] == 1 then
    --                 winId = atkId
    --                 winData[indexId+1] = 0
    --                 if jinji == 8 then
    --                     xianData[indexId][1] = 1
    --                     xianData[indexId][2] = 1
    --                     xianData[indexId+1][1] = 0
    --                     xianData[indexId+1][2] = 0
    --                     xianData[xishu[2]+i][1] = 1
    --                     xianData[xishu[2]+i][2] = 0
    --                 elseif jinji == 4 then
    --                     xianData[indexId][1] = 1
    --                     xianData[indexId][2] = 1
    --                     xianData[indexId+1][1] = 1
    --                     xianData[indexId+1][2] = 0
    --                     xianData[xishu[2]+i][1] = 1
    --                     xianData[xishu[2]+i][2] = 0
    --                 elseif jinji == 2 then
    --                     xianData[indexId][1] = 1
    --                     xianData[indexId][2] = 1
    --                     xianData[indexId+1][1] = 1
    --                     xianData[indexId+1][2] = 0
    --                     xianData[xishu[2]+i][1] = 1
    --                     xianData[xishu[2]+i][2] = 1
    --                 end
    --             elseif warData["win"] == 2 then
    --                 winId = defId
    --                 winData[indexId] = 0
    --                 if jinji == 8 then
    --                     xianData[indexId][1] = 0
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][1] = 1
    --                     xianData[indexId+1][2] = 1
    --                     xianData[xishu[2]+i][1] = 1
    --                 elseif jinji == 4 then
    --                     xianData[indexId][1] = 1
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][1] = 1
    --                     xianData[indexId+1][2] = 1
    --                     xianData[xishu[2]+i][1] = 1
    --                     xianData[xishu[2]+i][2] = 0
    --                 elseif jinji == 2 then
    --                     xianData[indexId][1] = 1
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][1] = 1
    --                     xianData[indexId+1][2] = 1
    --                     xianData[xishu[2]+i][1] = 1
    --                     xianData[xishu[2]+i][2] = 1
    --                 end
    --             else
    --                 if jinji == 8 then
    --                     xianData[indexId][1] = 0
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][1] = 0
    --                     xianData[indexId+1][2] = 0
    --                 elseif jinji == 4 then
    --                     if xianData[indexId][1] ~= 0 then
    --                         xianData[indexId][1] = 1
    --                     end
    --                     if xianData[indexId+1][1] ~= 0 then
    --                         xianData[indexId+1][1] = 1
    --                     end
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][2] = 0
    --                 elseif jinji == 2 then
    --                     if xianData[indexId][1] ~= 0 then
    --                         xianData[indexId][1] = 1
    --                     end
    --                     if xianData[indexId+1][1] ~= 0 then
    --                         xianData[indexId+1][1] = 1
    --                     end
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][2] = 0
    --                 end
    --             end

    --             local flag = self:getGodWarPowState(warData.pow, warData.round)
    --             -- print("xishu[2]+i===============", indexId, xishu[2]+i, indexId+1, flag, indexId, warData["win"])
    --             if flag == true then
    --                 if jinji == 8 then
    --                     xianData[indexId][1] = 0
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][1] = 0
    --                     xianData[indexId+1][2] = 0
    --                     xianData[xishu[2]+i][1] = 0
    --                     xianData[xishu[2]+i][2] = 0
    --                 elseif jinji == 4 then
    --                     xianData[indexId][1] = 1
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][1] = 1
    --                     xianData[indexId+1][2] = 0
    --                     xianData[xishu[2]+i][1] = 0
    --                     xianData[xishu[2]+i][2] = 0
    --                 elseif jinji == 2 then
    --                     xianData[indexId][1] = 1
    --                     xianData[indexId][2] = 0
    --                     xianData[indexId+1][1] = 1
    --                     xianData[indexId+1][2] = 0
    --                     xianData[xishu[2]+i][1] = 0
    --                     xianData[xishu[2]+i][2] = 0
    --                 end
    --             else
    --                 tWarData[xishu[2]+i] = winId
    --                 if jinji == 8 then
    --                     xianData[xishu[2]+i][1] = 1
    --                     xianData[xishu[2]+i][2] = 0
    --                 elseif jinji == 4 then
    --                     xianData[xishu[2]+i][1] = 1
    --                     xianData[xishu[2]+i][2] = 0
    --                 elseif jinji == 2 then
    --                     xianData[xishu[2]+i][1] = 0
    --                     xianData[xishu[2]+i][2] = 1
    --                 end
    --             end
    --         end
    --     end
    -- end

-- 获取晋级赛所有数据
function GodWarModel:getWarDataAll()
    return self._warBattle
end

-- 获取X强数据
function GodWarModel:getWarDataById(indexId)
    local indexId = tostring(indexId)
    return self._warBattle[indexId]
end


-- 处理数据
function GodWarModel:setPlayer(data)
    for k,v in pairs(data) do
        v.rid = k
    end
    self._player = data
    self._showPlayer = nil
end

-- 更新玩家皮肤
function GodWarModel:updatePlayer(data)
    for k,v in pairs(data) do
        if not self._player[v.rid] then
            self._player[v.rid] = {}
        end
        self._player[v.rid]["skin"] = v.skin
        self._player[v.rid]["score"] = v.score
    end
end

function GodWarModel:getData()
    return self._data
end

function GodWarModel:getPlayerById(userId)
    if self._player[userId] then
        return self._player[userId]
    end
end


-- 获取参赛数据
function GodWarModel:getPlayer()
    return self._player
end

-- 获取参赛人名单
function GodWarModel:getShowPlayer()
    if not self._showPlayer then
        self:progerssData()
    end
    return self._showPlayer
end

-- 处理参赛人名单数据
function GodWarModel:progerssData()
    local player = self:getPlayer()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userId = userData._id
    local flag = false

    local playerData = {}
    for k,v in pairs(player) do
        if userId ~= k then
            table.insert(playerData, k)
        else
            flag = true
        end
    end
    if flag == true then
        local godwarConst = self._userModel:getGodWarConstData()
        -- local season = godwarConst.SEASON or 0
        -- local curServerTime = self._userModel:getCurServerTime()
        -- local weekday = TimeUtils.date("%w", curServerTime)
        local rand = 1
        table.insert(playerData, rand, userId)
    end
    self._showPlayer = playerData
end

-- 处理参赛人名单数据
function GodWarModel:progerssGroupData()
    local player = self:getPlayer()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userId = userData._id
    local flag = false
    local sortFunc = function(a, b)
        local asortId = a.gp
        local bsortId = b.gp
        local aScore = a.score
        local bScore = b.score
        -- local aisInFormation = a.isInFormation
        -- local bisInFormation = b.isInFormation
        if asortId ~= bsortId then
            return asortId < bsortId
        elseif aScore ~= bScore then
            return aScore > bScore
        end
    end

    table.sort(player, sortFunc)
    dump(player)
    -- local playerData = {}
    -- for k,v in pairs(player) do
    --     if userId ~= k then
    --         table.insert(playerData, k)
    --     else
    --         flag = true
    --     end
    -- end
    -- if flag == true then
    --     local godwarConst = self._userModel:getGodWarConstData()
    --     -- local season = godwarConst.SEASON or 0
    --     -- local curServerTime = self._userModel:getCurServerTime()
    --     -- local weekday = TimeUtils.date("%w", curServerTime)
    --     local rand = 1
    --     table.insert(playerData, rand, userId)
    -- end
    -- self._showPlayer = playerData
end



function GodWarModel:getGroupById(indexId)
    local indexId = tostring(indexId)
    return self._groupBattle[indexId]
end



-- 自己是否参加本届争霸赛
function GodWarModel:isMyJoin()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userId = userData._id
    local playerData = self:getPlayerById(userId)
    local flag = false
    if playerData then
        flag = true
    end
    return flag
end

function GodWarModel:getMyPow(pow, _type)
    local state = false
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userId = userData._id
    local playerData = self:getPlayerById(userId)
    if playerData and playerData.r <= pow then
        state = true
    end
    if _type == 1 then
        state = state
    else
        state = not state
    end
    print("stat=========", _type, state)
    return state    
end



-- 更新争霸赛常量数据
function GodWarModel:updateGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if weekday == 1 then
        local godwarConst = self._userModel:getGodWarConstData()
        local oldSeason = godwarConst.SEASON
        self._serverMgr:sendMsg("GodWarServer","updateSeason",{},true,{},function(result)
            if result["godWar"] then
                self._userModel:setGodWarConstData(result["godWar"])
            end
            local godwarConst = self._userModel:getGodWarConstData()
            local newSeason = godwarConst.SEASON
            print("oldSeason ~= newSeason=======", oldSeason, newSeason)
            if oldSeason ~= newSeason then
                self:reflashData()
            end
        end)
    end
end

-- 争霸赛开关
function GodWarModel:getCloseGodWar()
    return GodWarUtil.godwarSwitch
end

-- 
function GodWarModel:showGodWarTip(_type)
    local godwarConst = self._userModel:getGodWarConstData()
    local begTime = godwarConst.RACE_BEG
    if begTime ~= 0 then
        local curServerTime = self._userModel:getCurServerTime()
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        local minTime, maxTime = 0, 0
        if weekday == 2 then
            local isSelf = self:isMyJoin()
            if self:getShowRed() ~= true and isSelf == true then
                if _type == 1 then
                    self._viewMgr:showGlobalDialog("godwar.GodWarTishiDialog", {showType = 1})
                end
            end
        elseif weekday == 3 then
            local flag = self:getMyPow(8, _type)
            if flag == true and _type == 1 then
                if self:getShowRed() ~= true then
                    self._viewMgr:showGlobalDialog("godwar.GodWarTishiDialog", {showType = 1})
                end
            elseif flag == true and _type == 2 then
                if self:getShowRed() ~= true then
                    self._viewMgr:showGlobalDialog("godwar.GodWarTishiDialog", {showType = 2})
                end
            end
        elseif weekday == 4 then
            local flag = self:getMyPow(4, _type)
            if flag == true and _type == 1 then
                if self:getShowRed() ~= true then
                    self._viewMgr:showGlobalDialog("godwar.GodWarTishiDialog", {showType = 1})
                end
            elseif flag == true and _type == 2 then
                if self:getShowRed() ~= true then
                    self._viewMgr:showGlobalDialog("godwar.GodWarTishiDialog", {showType = 2})
                end
            end
        end
    end
end

function GodWarModel:updateLayer()
    self:reflashData()
end

-- 是否开启引导
function GodWarModel:getShowGuide()
    local ttype = SystemUtils.loadAccountLocalData("GODWAR_DIALOGTYPE_guide")
    if 1 ~= ttype then
        return true
    end
    return false
end

function GodWarModel:setShowGuide()
    local ttype = SystemUtils.loadAccountLocalData("GODWAR_DIALOGTYPE_guide")
    if 1 ~= ttype then
        SystemUtils.saveAccountLocalData("GODWAR_DIALOGTYPE_guide", 1)
    end
end

-- 商店使用获取排名
function GodWarModel:getCurZone()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userId = userData._id
    local playerData = self:getPlayerById(userId)
    local rank = 64
    if playerData then
        rank = playerData.r
    end
    return rank
end


-- 是否展示红包
function GodWarModel:setShowRed(flag)
    self._showRed = flag
end

function GodWarModel:getShowRed()
    return self._showRed or false
end

-- 反转显示数据
function GodWarModel:reversalData(data)
    local tempData = clone(data)
    local backData = {}
    backData.def = tempData.atk
    backData.atk = tempData.def
    if tempData.win == 1 then
        backData.win = 2
    elseif tempData.win == 2 then
        backData.win = 1
    else
        backData.win = tempData.win
    end
    if tempData.stake == 1 then
        backData.stake = 2
    elseif tempData.stake == 2 then
        backData.stake = 1
    else
        backData.stake = tempData.stake
    end
    backData.gp = tempData.gp
    backData.per = tempData.per
    backData.pow = tempData.pow
    backData.round = tempData.round
    backData.title = tempData.title
    backData.reps = tempData.reps
    backData.onReverse = true
    backData.rate = tempData.rate
    if backData.rate then
        local trate = tempData.rate["2"]
        backData.rate["2"] = tempData.rate["1"]
        backData.rate["1"] = trate
    end
    if backData.reps then
        for k,v in pairs(backData.reps) do
            if v.w == 1 then
                v.w = 2
            elseif v.w == 2 then
                v.w = 1
            end
        end
    end
    return backData
end

-- 传入id 是否当前玩家
function GodWarModel:isReverse(defId)
    local flag = false
    local userid = self._modelMgr:getModel("UserModel"):getData()._id
    if defId == userid then
        flag = true
    end
    return flag
end

-- 争霸赛功能是否开打 guojun
function GodWarModel:isGodWarOpenFightWeek()
    local closeState = self:getCloseGodWar()
    if closeState == false then
        return false
    end
    local openState = false
    local godwarConst = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))

    local godWarOpenTime = godwarConst.FIRST_RACE_BEG + 43200
    if godWarOpenTime < curServerTime then
        openState = true
    end

    local flag = false
    local godWarRaceTime = godwarConst.RACE_BEG
    -- godWarRaceTime == 0 表示不是比赛周
    local begTime = godWarOpenTime-86400*7-7*3600
    local endTime = godWarOpenTime - 7*3600
    print("begTime======", begTime, endTime)
    if godWarRaceTime == 0 and openState == true then
        flag = true
        if weekday == 1 and curServerTime < tempTime then
            flag = false
        end
    elseif endTime > curServerTime and begTime < curServerTime then
    -- 预备周特殊处理  开打前一周
        flag = true
    end

    return flag
end


-- 争霸赛里弹窗展示类型
function GodWarModel:getGodWarShowDialogType()
    local showType = 0
    local state, indexId = self:getStatus()
    local timerTab = tab:GodWarTimer(indexId)
    if timerTab.balance then
        showType = timerTab.balance
    end
    local flag = self:getGodWarShowType(showType)
    if flag == false then
        showType = 0
    end
    print("showType==========", showType, indexId)
    return showType
end

function GodWarModel:getGodWarShowType(showType)
    local ttype = SystemUtils.loadAccountLocalData("GODWAR_DIALOGTYPE1_showtype")
    if showType ~= ttype then
        return true
    end
    return false
end

function GodWarModel:setGodWarShowType(showType)
    local ttype = SystemUtils.loadAccountLocalData("GODWAR_DIALOGTYPE1_showtype")
    if showType ~= ttype then
        SystemUtils.saveAccountLocalData("GODWAR_DIALOGTYPE1_showtype", showType)
    end
end



-- 主界面弹窗
function GodWarModel:getShowDialogType()
    local showType = self:getFristTrailerType()
    local openState = self:isGetInfoGodWar()
    if openState == false then
        local flag = self:getShowType(showType)
        if flag == false then
            showType = 0
        end
        return showType or 0
    end

    local state, indexId = self:getStatus()
    if indexId == 0 then
        indexId = 1
    end
    local timerTab = tab:GodWarTimer(indexId)
    if timerTab.showType then
        showType = timerTab.showType
    end
    if timerTab.time then
        local tflag = self:isShowDialog(showType)
        if tflag ~= true then
            showType = 0
            print("stflag666666=========", showType, indexId)
            return showType
        end
    end
    local flag = self:getShowType(showType)
    if flag == false then
        showType = 0
    end
    print("showType==========", showType, indexId)
    return showType
end

function GodWarModel:isShowDialog(showType)
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local flag = false
    if showType == 3 then
        flag = true
        if weekday == 1 then
            local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 00:00:00"))
            local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
            if curServerTime >= minTime and curServerTime <= maxTime then
                flag = false
            end
        end
    elseif showType == 4 then
        local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 12:00:00"))
        local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        if curServerTime >= minTime and curServerTime <= maxTime then
            flag = true
        end
    elseif showType == 5 then
        local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
        local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        if curServerTime >= minTime and curServerTime <= maxTime then
            flag = true
        end
    elseif showType == 6 then
        local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
        local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        if curServerTime >= minTime and curServerTime <= maxTime then
            flag = true
        end
    end
    return flag
end


-- 首届预告
function GodWarModel:getFristTrailerType()
    local godwarConst = self._userModel:getGodWarConstData()
    local firstTime = godwarConst.FIRST_RACE_BEG
    if (not firstTime) or firstTime == 0 then
        firstTime = 1559029200
    end
    local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(firstTime-86400*7,"%Y-%m-%d 05:00:00"))
    local curServerTime = self._userModel:getCurServerTime()
    local showType = 0
    if curServerTime >= begTime and curServerTime <= firstTime then
        showType = 1
    end

    local openGodwar = SystemUtils["enableGodWar"]()
    if openGodwar == false then
        showType = 0
    end
    return showType
end

-- 争霸赛是否开启
function GodWarModel:isGetInfoGodWar()
    local closeState = self:getCloseGodWar()
    if closeState == false then
        return false
    end
    local openState = false
    local godwarConst = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local userLvl = self._userModel:getData().lvl
    if godwarConst.RACE_BEG ~= 0 then
        local openTime = godwarConst.RACE_BEG
        if curServerTime >= openTime then
            openState = true
        end
    else
        local openTime = godwarConst.FIRST_RACE_BEG
        if curServerTime >= openTime then
            openState = true
        end
    end
    if openState == true then
        openState = SystemUtils["enableGodWar"]()
    end
    -- print("openState======", openState)
    return openState
end


-- 争霸赛功能是否开启
function GodWarModel:isOpenSysGodWar()
    local closeState = self:getCloseGodWar()
    if closeState == false then
        return false
    end
    local openState = false
    local godwarConst = self._userModel:getGodWarConstData()
    -- dump(godwarConst)
    local curServerTime = self._userModel:getCurServerTime()
    local godWarOpenTime = godwarConst.FIRST_RACE_BEG + 43200
    if godWarOpenTime < curServerTime then
        openState = true
    end
    return openState
end


function GodWarModel:getShowType(showType)
    local ttype = SystemUtils.loadAccountLocalData("GODWAR_DIALOGTYPE_showtype")
    if showType ~= ttype then
        return true
    end
    return false
end

function GodWarModel:setShowType(showType)
    local ttype = SystemUtils.loadAccountLocalData("GODWAR_DIALOGTYPE_showtype")
    if showType ~= ttype then
        SystemUtils.saveAccountLocalData("GODWAR_DIALOGTYPE_showtype", showType)
    end
end

-- 功能是否开启
-- 1 未开启 2 预告 3 开启
function GodWarModel:isOpenGodWar()
    local curServerTime = self._userModel:getCurServerTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    local flag = 1
    local fSeaTime = godWarConstData.FIRST_RACE_BEG or 0
    local yugaoTime = fSeaTime - 86400
    if yugaoTime <= curServerTime and fSeaTime >= curServerTime then
        flag = 2
    elseif fSeaTime > curServerTime then
        flag = 1
    elseif fSeaTime < curServerTime then
        flag = 3
    end
    print("isOpenGodWar=======", flag)
    return flag
end

-- 抬头状态
function GodWarModel:getTitleState()
    local isOpen = false
    local curServerTime = self._userModel:getCurServerTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    local raceBegTime = godWarConstData.RACE_BEG or 0
    if raceBegTime == 0 then
        isOpen = true
    elseif raceBegTime and raceBegTime > curServerTime then
        isOpen = true
    end
    return isOpen
end


-- 主界面按钮状态
-- state 0 未开启  
-- 1 预告中
-- 2 开启 
function GodWarModel:getMainBtnState()
    local state = 0
    local flag = self:isOpenGodWar()
    if flag == 1 then
        state = 0
    else
        state = flag - 1
    end
    return state
end

-- 赛季中是否预告
function GodWarModel:isNormalGodWarYugao()
    local isOpen = false
    local curServerTime = self._userModel:getCurServerTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    local raceBegTime = godWarConstData.RACE_BEG or 0
    if raceBegTime == 0 then
        isOpen = true
    elseif raceBegTime and raceBegTime > curServerTime then
        isOpen = true
    end
    return isOpen
end

-- 预告
function GodWarModel:isOpenYuGao()
    local flag = self:isOpenGodWar()
    local isOpen = false
    if flag == 2 then
        isOpen = true
    elseif flag == 3 then
        local curServerTime = self._userModel:getCurServerTime()
        local godWarConstData = self._userModel:getGodWarConstData()
        local raceBegTime = godWarConstData.RACE_BEG or 0
        if raceBegTime == 0 then
            isOpen = true
        elseif raceBegTime and raceBegTime > curServerTime then
            isOpen = true
        end
    end
    print("isOpenYuGao=======", isOpen)
    return isOpen
end

-- 获取主界面副标题
function GodWarModel:getMainTitle()
    local state, indexId = self:getStatus()
    -- print("self._godWarModel=====", state, indexId)
    local data = tab:GodWarTimer(indexId)
    if not data then
        data = {}
    end
    local str = lang(data.content) or ""
    return str
end

-- 是否可以进入争霸赛
function GodWarModel:isJoinGodWar()
    local closeState = self:getCloseGodWar()
    if closeState == false then
        return false
    end
    local openState = false
    local godwarConst = self._userModel:getGodWarConstData()
    dump(godwarConst)
    local curServerTime = self._userModel:getCurServerTime()
    if godwarConst.RACE_BEG ~= 0 then
        local openTime = godwarConst.RACE_BEG
        if curServerTime >= openTime then
            openState = true
        end
    else
        openState = true
    end
    -- print("openState======", openState)
    return openState
end

-- GodWarFightDialog 获取时间
function GodWarModel:getGroupRoundTimer(titleId)
    local curServerTime = self._userModel:getCurServerTime()
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
    TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00")

    return flag
end

-- 获取自己的组
function GodWarModel:getMyGroup()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userId = userData._id
    local playerData = self:getPlayerById(userId)
    local groupId = 1
    if playerData then
        groupId = playerData.gp
    end
    return groupId
end



-- 主界面
-- 点击争霸赛按钮
-- 0 可以进功能
-- 1 功能前
-- 2 功能维护
-- 3 合服期间
function GodWarModel:getClickGodwarBtn()
    local btnType = 0
    if self._godwarClose == true then
        btnType = 3
    end

    local openState = self:isOpenSysGodWar()
    if openState == false then
        btnType = 1 
    end
    -- print("=openState====isOpeniew=======", btnType)
    if btnType == 0 then
        openState = self:isMaintainGodWar()
        if openState == false then
            btnType = 2
        end
    end
    -- print("=openState====isMaintaiew=======", btnType)
    return btnType
end

-- 争霸赛功能维护中
-- false 维护中
function GodWarModel:isMaintainGodWar()
    local godwarConst = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local tRaceBeg = godwarConst.RACE_BEG
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(tRaceBeg,"%Y-%m-%d 00:00:00"))
    local flag = true
    if godwarConst.RACE_BEG ~= 0 then
        if curServerTime >= tempTime and curServerTime <= tRaceBeg then
            flag = false
        end
    end
    return flag
end

-- 争霸赛开启时间
function GodWarModel:getOpenTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local godWarOpenTime = godWarConstData.FIRST_RACE_BEG + 43200
    local opentime = godWarOpenTime - curServerTime
    local timeStr = "距离功能开启还剩"
    local nextOpenDes = ""
    if opentime >= 86400 then
        local time = math.floor(opentime/86400)
        timeStr = timeStr .. time .. "天"
    elseif opentime >= 3600 then
        local time = math.floor(opentime/3600)
        timeStr = timeStr .. time .. "小时"
    elseif opentime < 3600 and opentime >= 1 then
        nextOpenDes = string.format("%02d:%02d:%02d后开启",math.floor(opentime/3600),math.floor(opentime/60),opentime%60)
        timeStr = "诸神之战即将开启" 
    elseif opentime >= 0 then
        timeStr = "诸神之战即将开启"
    end
    return timeStr,nextOpenDes,opentime
end

function GodWarModel:getOpenTime1()
    local godWarConstData = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local godWarOpenTime = godWarConstData.RACE_BEG
    local opentime = godWarOpenTime - curServerTime
    local timeStr = "距离开启还剩"
    local nextOpenDes = ""
    if opentime >= 86400 then
        local time = math.floor(opentime/86400)
        timeStr = timeStr .. time .. "天"
    elseif opentime >= 3600 then
        local time = math.floor(opentime/3600)
        timeStr = timeStr .. time .. "小时"
    elseif opentime < 3600 and opentime >= 1 then
        nextOpenDes = string.format("%02d:%02d:%02d后开启",math.floor(opentime/3600),math.floor(opentime/60),opentime%60)
        timeStr = "诸神之战即将开启" 
    elseif opentime >= 0 then
        timeStr = "诸神之战即将开启"
    end
    return timeStr,nextOpenDes,opentime
end


-- 拍脸图日期
function GodWarModel:getShowTime()
    local timeStr = "3.22"
    local godwarConst = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local tcurServerTime = 0
    if godwarConst.RACE_BEG == 0 then
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        if weekday == 0 then
            weekday = 7
        end
        tcurServerTime = curServerTime + 86400*(7-weekday+1)
        local month = TimeUtils.getDateString(tcurServerTime,"%m")
        local day = TimeUtils.getDateString(tcurServerTime,"%d")
        timeStr = string.format("%d.%.2d", month, day)
    else
        local openTime = godwarConst.RACE_BEG
        timeStr = TimeUtils.getDateString(openTime,"%m.%d")
    end
    local firstTime = godwarConst.FIRST_RACE_BEG
    if firstTime > curServerTime then
        local month = TimeUtils.getDateString(firstTime,"%m")
        local day = TimeUtils.getDateString(firstTime,"%d")
        timeStr = string.format("%d.%.2d", month, day)
    end
    print("tcurServerTime============", timeStr)
    return timeStr
end

------------------------------------------------------------------


-- 获取赛程总体时间
function GodWarModel:getGodWarMatchTime()
    if not self._warMatchTime then
        self._warMatchTime = self:setGodWarMatchTime()
    end
    return self._warMatchTime
end

-- 不可直接调用一个赛季
function GodWarModel:setGodWarMatchTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if weekday == 0 then
        weekday = 7
    end
    local tcurServerTime = curServerTime - (weekday-1)*86400
    if godWarConstData.RACE_BEG == 0 then
        tcurServerTime = tcurServerTime - 86400*7
    end
    local starTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(tcurServerTime,"%Y-%m-%d 00:00:00"))
    -- 周一0点
    local timeBeg = starTime
    if godWarConstData.RACE_BEG ~= 0 then
        timeBeg = godWarConstData.RACE_BEG
    end
    local timeStr = {}
    -- {周， 时间， 状态， 是否结束， 几强}
    local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg,"%Y-%m-%d 00:00:00"))
    timeStr[0] = {0, tempTime, 1, 2, 0}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg,"%Y-%m-%d 12:00:00"))
    timeStr[1] = {1, tempTime, 1, 2, 0} -- 名单出炉
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400,"%Y-%m-%d 12:00:00"))
    timeStr[2] = {2, tempTime, 2, 2, 0} -- 分组抽签
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400,"%Y-%m-%d 20:00:00"))
    timeStr[3] = {2, tempTime, 3, 1, 32}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400,"%Y-%m-%d 20:18:00"))
    timeStr[4] = {2, tempTime, 3, 0, 32}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*2,"%Y-%m-%d 20:00:00"))
    timeStr[5] = {3, tempTime, 4, 1, 8}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*2,"%Y-%m-%d 20:36:00"))
    timeStr[6] = {3, tempTime, 4, 0, 8}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*3,"%Y-%m-%d 20:00:00"))
    timeStr[7] = {4, tempTime, 5, 1, 4}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*3,"%Y-%m-%d 20:18:00"))
    timeStr[8] = {4, tempTime, 5, 0, 4}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*3,"%Y-%m-%d 20:18:00"))
    timeStr[9] = {4, tempTime, 6, 1, 2}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*3,"%Y-%m-%d 20:29:00"))
    timeStr[10] = {4, tempTime, 6, 0, 2}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*3,"%Y-%m-%d 20:30:00"))
    timeStr[11] = {4, tempTime, 6, 2, 1}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*7,"%Y-%m-%d 05:00:00"))
    timeStr[12] = {0, tempTime, 7, 2, 1}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*14,"%Y-%m-%d 00:00:00"))
    timeStr[13] = {0, tempTime, 8, 2, 1}
    tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeBeg+86400*14,"%Y-%m-%d 12:00:00"))
    timeStr[14] = {0, tempTime, 8, 2, 1}
    return timeStr
end


-- 1 赛前  2 比赛中  3 比赛后  4 本周未开启
-- 周状态
function GodWarModel:isOpenMatch()
    local curServerTime = self._userModel:getCurServerTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    local raceBeg = godWarConstData.RACE_BEG or 0
    local raceEnd = godWarConstData.RACE_END or 0
    local flag = 4
    if curServerTime >= raceBeg and curServerTime <= raceEnd then
        flag = 2
    elseif raceBeg == 0 then
        local tcurServerTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime, "%Y-%m-%d 05:00:00"))
        if curServerTime < tcurServerTime then
            local weekday = tonumber(TimeUtils.date("%w", curServerTime))
            if weekday == 1 then
                flag = 3
            end
        else
            flag = 4
        end
    elseif curServerTime < raceBeg then
        flag = 1
    elseif curServerTime > raceEnd then
        flag = 3
    end
    return flag
end


-- [[
-- 1 名单出炉   12:00 1  赛前
-- 2 分组抽签   12:00 2
-- 3 小组赛     20:00 2
-- 4 8强赛      20:00 3
-- 5 4强赛      20:00 4
-- 6 总决赛     20:40 4

-- 7 比赛后 到周一
-- 8 不开启周

-- 0 准备中    
-- -1 未开启    
--]] 
function GodWarModel:getStatus()
    local status = 8
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    
    local flag = self:isOpenMatch()
    print("flag=isOpenMatch==", flag)
    if flag == 3 then
        status = 7
        return status, 12
    elseif flag == 4 then
        status = 8
        return status, 13
    elseif flag == 1 then
        status = 1
        return status, 1
    end
    local warMatchTime = self:getGodWarMatchTime()
    local indexId = 0
    for i=1,13 do
        if curServerTime > warMatchTime[i][2] then
            indexId = i
        end
    end

    status = warMatchTime[indexId][3]
    if indexId < 13 then
        if warMatchTime[indexId][4] == 0 then
            indexId = indexId + 1
            status = warMatchTime[indexId][3]
        end
    end
    return status, indexId
end

-- 主界面红点逻辑
function GodWarModel:getGodwarMainTip()
    local flag = false
    local levelTip = SystemUtils["enableGodWar"]()
    local worshipTip = self:getGodwarWorshipTip()
    if levelTip == true and worshipTip == true then
        flag = true
    end
    return flag
end

-- 布阵红点
function GodWarModel:getGodwarFormationTip()
    local forteam = {}
    local formationModel = self._modelMgr:getModel("FormationModel")
    for i=1,3 do
        local formation = formationModel:getFormationDataByType(formationModel["kFormationTypeGodWar" .. i])
        for fi=1,8 do
            local tempforteam = formation["team" .. fi]
            if tempforteam ~= 0 then
                table.insert(forteam, tempforteam)
            end
        end
    end
    local teamModel = self._modelMgr:getModel("TeamModel")
    local teamData = teamModel:getData()
    local teamNum = table.nums(teamData)
    local forteamNum = table.nums(forteam)
    local flag = false
    if forteamNum < 18 then
        if teamNum > forteamNum then
            flag = true
        end
    end
    return flag
end

-- 膜拜红点
function GodWarModel:getGodwarWorshipTip()
    if self._godwarClose == true then
        return false
    end
    local curServerTime = self._userModel:getCurServerTime()
    local godWarConstData = self._userModel:getGodWarConstData()
    local firstBegTime = godWarConstData["FIRST_RACE_BEG"]
    if curServerTime < firstBegTime then
        return false
    end
    local state, indexId = self:getStatus()
    local flag = false
    if indexId == 11 or indexId == 12 then
        for i=1,3 do
            local dayinfo = self:getGodwarWorshipAloneTip(i)
            if dayinfo == true then
                flag = true
            end
        end
    elseif indexId == 13 then
        local dayinfo = self:getGodwarWorshipAloneTip(1)
        if dayinfo == true then
            flag = true
        end
    end
    print("=====indexId+++++++=========", indexId)
    return flag 
end

function GodWarModel:getGodwarWorshipAloneTip(indexId)
    local flag = false
    local playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    local dayinfo = playerTodayModel:getDayInfo(52+indexId)
    if dayinfo == 0 then
        flag = true
    end
    return flag 
end

-- 主界面左下角气泡展示
function GodWarModel:getTimeSystemOn()
    local flag = false
    local godWarConstData = self._userModel:getGodWarConstData()
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local begTime = godWarConstData["RACE_BEG"]
    local firstBegTime = godWarConstData["FIRST_RACE_BEG"]
    if begTime ~= 0 and curServerTime > firstBegTime then
        if weekday == 2 or weekday == 3 or weekday == 4 then
            flag = true
        end
    end
    return flag 
end

-- 膜拜人数展示
function GodWarModel:getWorShipType()
    local getWorShipDialog = function()
        local godWarConstData = self._userModel:getGodWarConstData()
        local curServerTime = self._userModel:getCurServerTime()
        local tempCurServerTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
        if curServerTime < tempCurServerTime then
            curServerTime = curServerTime - 86400
        end
        local weekday = tonumber(TimeUtils.date("%w", curServerTime))
        local begTime = godWarConstData["RACE_BEG"]
        local firstBegTime = godWarConstData["FIRST_RACE_BEG"]
        local flagType = 0
        if begTime ~= 0 then
            if weekday == 5 or weekday == 6 or weekday == 0 then
                flagType = 1
            end
        else
            flagType = 2
        end
        return flagType
    end
    local flag = getWorShipDialog()
    local data = self:getDispersedData()

    local userId = self._userModel:getRID()
    local worshipNum = 0
    for i=1,3 do
        local playData = data["r" .. i]
        if playData then
            local playId = playData.rid
            if userId == playId then
                worshipNum = i
                break
            end
        end
    end

    local worshipShow = 0
    if flag == 1 and worshipNum ~= 0 then
        worshipShow = 1
    elseif flag == 2 and worshipNum == 1 then
        worshipShow = 2
    end

    local worFlag = self:getWorShipDialog()
    if worFlag == true and worshipShow ~= 0 then
        return true
    end
    return false
end



function GodWarModel:getWorShipDialog()
    local userModel = self._userModel
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("GODWAR_worShipDialog")
    if tempdate ~= timeDate then
        print("GODWAR_worShipDialog", timeDate)
        return true
    end
    return false
end

function GodWarModel:setWorShipDialog()  
    local userModel = self._userModel
    local curServerTime = userModel:getCurServerTime()
    local timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    local tempdate = SystemUtils.loadAccountLocalData("GODWAR_worShipDialog")
    print("tempdate============", type(tempdate), type(timeDate))
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    if tempdate ~= timeDate then
        print("GODWAR_worShipDialog", timeDate)
        SystemUtils.saveAccountLocalData("GODWAR_worShipDialog", timeDate)
    end
end

function GodWarModel.dtor()
    GodWarUtil = nil 
    jiange = nil 
end 


return GodWarModel