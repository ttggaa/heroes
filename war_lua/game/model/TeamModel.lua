--[[
    Filename:    TeamModel.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-20 16:17:36
    Description: File description
--]]

--[[
    ********数据瘦身记录********
    equipStage      => es
    equipLevel      => el
    skillLevel      => sl
    skillLevelExp   => se
    teamBoost       => tb
]]--
local TeamModel = class("TeamModel", BaseModel)
require "game.view.team.TeamConst"
-- 

-- 1 = 白色
-- 2 = 绿色
-- 3 = 蓝色 
-- 4 = 紫色
-- 5 = 橙色
-- local TeamQuality = {
--     [1] = {1, 0},
--     [2] = {2, 0},
--     [3] = {3, 0},
--     [4] = {3, 1},
--     [5] = {4, 0},
--     [6] = {4, 1},
--     [7] = {4, 2},
--     [8] = {5, 1},
--     [9] = {5, 2},
--     [10] = {5, 3},
-- }


TeamModel.kMaxBgStar = 6

TeamModel.kSmallBgStar = 10



function TeamModel:ctor()
    TeamModel.super.ctor(self)
    self._bigStar = false
    self._teamMap = {}
    self._teamBaseData = {}
    self._holyData = {} -- 宝石
    self._useHoly = {} -- 使用的宝石
    self._suitData = {} -- 套装
    self._tabHolyData = {} -- 
    self._userModel = self._modelMgr:getModel("UserModel")
end

function TeamModel:getData()
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function TeamModel:setData(data)
    --初始化特技数据  by wangyan
    for k,v in pairs(data) do
        if not v["sl5"] then v["sl5"] = -1 end
        if not v["sl6"] then v["sl6"] = -1 end
        if not v["sl7"] then v["sl7"] = -1 end
        if not v["se5"] then v["se5"] = 0 end
        if not v["se6"] then v["se6"] = 0 end
        if not v["se7"] then v["se7"] = 0 end
    end

    self._checkTipData = {}
	-- 匹配数据
	local backData = self:processData(data)

    self._data = backData
    -- index反差表
    self._indexMap = {}
    -- 对数据进行排序
    self:refreshDataOrder()
    self:initGetSysTeams()

    self:progressTeamUseHolyData()
    self:reflashData()

    -- 监听布阵数据变化更改排序
    self:listenReflash("FormationModel", self.refreshDataOrder)
    -- 监听物品数据变化更改提示状态
    self:listenReflash("ItemModel", self.updateTeamTips)

    self:listenReflash("UserModel", self.updateTeamTips)
end

-- 初始化宝物数据
function TeamModel:setTeamTreasure()
    -- self._teamTreasure = {{},{},{},{}}
    local treasureData = self._modelMgr:getModel("TreasureModel"):getData()
    self._teamTreasure = BattleUtils.getTeamBaseAttr_treasure(treasureData)
    local monsterAttr, monsterAttr1 = self:getTreasureAttrData(treasureData)
    self._monsterAttr = monsterAttr
    self._monsterAttr1 = monsterAttr1

    local heroData = self._modelMgr:getModel("HeroModel"):getData()
    local monsterAttr, monsterAttr1 = self:getHeroAttrData(heroData)
    self._heroAttr = monsterAttr
    self._heroAttr1 = monsterAttr1

    local cradskSkill = self:getTeamHeroSkill(heroData)
    self._cradskSkill = cradskSkill
end

function TeamModel:getTeamTreasureAttrData(teamId)
    if not teamId then
        teamId = 101
    end
    local teamD = tab:Team(teamId)
    local movetype = teamD.movetype
    local class = teamD.class
    local volume = teamD.volume - 1
    if volume > 4 then
        volume = 4
    end
    if volume < 1 then
        volume = 1
    end
    local label1 = teamD.label1

    local monsterAttr = self._monsterAttr
    local monsterAttr1 = self._monsterAttr1
    local attr = monsterAttr[movetype][class][volume]
    -- print(movetype, class, volume, label1)

    local tattr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        tattr[n] = attr[n]
    end

    if monsterAttr1[label1] then
        local labelAttr = monsterAttr1[label1]
        for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
            tattr[n] = tattr[n] + labelAttr[n]
        end
    end
    -- dump(tattr)
    return tattr
end

function TeamModel:getTreasureAttrData(treasureData)
    local treData = treasureData
    -- 怪兽属性追加 -- [飞行][兵种][体型][属性]
    local monsterAttr = {{{{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}}, {{{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}}}
    local monsterAttrikn
    for i = 1, #monsterAttr do
        for k = 1, #monsterAttr[i] do
            for n = 1, #monsterAttr[i][k] do
                monsterAttrikn = monsterAttr[i][k][n]
                for m = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
                    monsterAttrikn[m] = 0
                end
            end
        end
    end

    local monsterAttr1 = {}

    local comTreasureD = tab.comTreasure
    local count = 1
    for id,com in pairs(treData) do
        local comTreasureT = comTreasureD[tonumber(id)]
        local _unlockaddattr = comTreasureT["unlockaddattr"]
        local _addattrs = comTreasureT["addattr"]
        local stage = com.stage
        local _lv = stage
        if stage > 0 then
            for i = 1, #_unlockaddattr do
                if stage >= _unlockaddattr[i] then
                    local _addattr = _addattrs[i]
                    local _addattr1 = _addattr[1]
                    local _addattr2 = _addattr[2]
                    local masteryD = tab.heroMastery[_addattr2]
                    if masteryD then
                        local addattrs = masteryD["addattr"]
                        local tagaddsk = masteryD["tagaddsk"]
                        local apprange0 = masteryD["apprange0"]
                        local apprange1 = masteryD["apprange1"]
                        local apprange2 = masteryD["apprange2"]
                        local apprange3 = masteryD["apprange3"]
                        if not addattrs then
                            addattrs = {}
                        end
                        if tagaddsk then
                            for k = 1, #tagaddsk do
                                local sysSkill = SkillUtils:getTeamSkillByType(tagaddsk[k][2], tagaddsk[k][1])
                                if sysSkill.attr then
                                    for k,v in pairs(sysSkill.attr) do
                                        table.insert(addattrs, v)
                                    end
                                end
                            end
                        end
                        if apprange0 and apprange1 and apprange2 then
                            if addattrs then
                                for k = 1, #addattrs do
                                    local addattr = addattrs[k]
                                    local attrid = addattr[1]
                                    local value = (addattr[2] + addattr[3] * (_lv - 1)) * count
                                    for m = 1, 5 do
                                        if apprange1[m] == 1 then
                                            for n = 1, 2 do
                                                if apprange2[n] == 1 then
                                                    for l = 1, 4 do
                                                        if apprange0[l] == 1 then
                                                            monsterAttr[n][m][l][attrid] = monsterAttr[n][m][l][attrid] + value
                                                        end
                                                    end
                                                end
                                            end 
                                        end
                                    end
                                end
                            end
                        elseif apprange3 then
                            -- 针对于特殊标签 team表 label1列的属性加成
                            if addattrs then
                                for k = 1, #addattrs do
                                    local addattr = addattrs[k]
                                    local attrid = addattr[1]
                                    local value = addattr[2] + addattr[3] * (_lv - 1)
                                    for m = 1, #apprange3 do
                                        local label1 = apprange3[m]
                                        if monsterAttr1[label1] == nil then
                                            monsterAttr1[label1] = {}
                                            for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
                                                monsterAttr1[label1][n] = 0
                                            end
                                        end
                                        monsterAttr1[label1][attrid] = monsterAttr1[label1][attrid] + value
                                    end
                                end
                            end
                        end
                    end
                end
            end 
        end
    end
    -- dump(monsterAttr, "monsterAttr", 4)
    return monsterAttr, monsterAttr1
    -- return monsterAttr, monsterAttr1
end

function TeamModel:getTeamHeroAttrByTeamId(teamId)
    local heroAttr = self:getTeamHeroSkillAttrByTeamId(teamId)
    local heroAttr1 = self:getTeamHeroAttrData(teamId)
    local tAttr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        tAttr[n] = heroAttr[n] + heroAttr1[n]
    end
    return tAttr
end

-- 获取英雄对单独的兵团加成的属性
function TeamModel:getTeamHeroSkillAttrByTeamId(teamId)
    if not teamId then
        teamId = 101
    end
    local skillAttr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        skillAttr[n] = 0
    end

    local cradskSkill = self._cradskSkill
    for i=1,#cradskSkill do
        local cradsk = cradskSkill[i]
        local _cradsk1 = cradsk[1]
        local _cradsk2 = cradsk[2]
        local _cradsk3 = cradsk[3]
        if teamId == _cradsk1 then
            local passive = tab.skillPassive[_cradsk3]
            local attr = passive.attr 
            for i=1,#attr do
                local _attr = attr[i]
                local _addattr1 = _attr[1]
                local _addattr2 = _attr[2]
                local _addattr3 = _attr[3]
                skillAttr[_addattr1] = skillAttr[_addattr1] + _addattr2
            end
        end
    end
    return skillAttr
end

function TeamModel:getTeamHeroSkill(heroData)
    if not heroData then
        return
    end
    local heroData = heroData
    local cradskSkill = {}
    for id,com in pairs(heroData) do
        local heroT = tab.hero[tonumber(id)]
        local _special = heroT["special"]
        local _global = heroT["global"]
        local masteryId = _special*10+_global
        local heroStar = com.star
        -- print("heroStar======", heroStar, _global)
        if heroStar >= _global then
            local masteryD = tab.heroMastery[masteryId]
            local cradsk = masteryD["cradsk"]
            if cradsk then
                for k = 1, #cradsk do
                    local addattr = cradsk[k]
                    local _addattr1 = addattr[1]
                    local _addattr2 = addattr[2]
                    local _addattr3 = addattr[3]
                    if _addattr2 == 2 then
                        table.insert(cradskSkill, addattr)
                    end
                end
            end
        end
    end
    -- dump(cradskSkill)
    -- self._cradskSkill = cradskSkill
    return cradskSkill
end

function TeamModel:getTeamHeroAttrData(teamId)
    if not teamId then
        teamId = 101
    end
    local teamD = tab:Team(teamId)
    local movetype = teamD.movetype
    local class = teamD.class
    local volume = teamD.volume - 1
    if volume > 4 then
        volume = 4
    end
    if volume < 1 then
        volume = 1
    end
    local label1 = teamD.label1

    local monsterAttr = self._heroAttr
    local monsterAttr1 = self._heroAttr1
    local attr = monsterAttr[movetype][class][volume]
    -- print(movetype, class, volume, label1)

    local tattr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        tattr[n] = attr[n]
    end

    if monsterAttr1[label1] then
        local labelAttr = monsterAttr1[label1]
        for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
            tattr[n] = tattr[n] + labelAttr[n]
        end
    end
    -- dump(tattr)
    return tattr
end

-- 获取英雄全局属性加成
function TeamModel:getHeroAttrData(heroData)
    if not heroData then
        return
    end
    local heroData = heroData
    -- 怪兽属性追加 -- [飞行][兵种][体型][属性]
    local monsterAttr = {{{{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}}, {{{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}, {{}, {}, {}, {}}}}
    local monsterAttrikn
    for i = 1, #monsterAttr do
        for k = 1, #monsterAttr[i] do
            for n = 1, #monsterAttr[i][k] do
                monsterAttrikn = monsterAttr[i][k][n]
                for m = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
                    monsterAttrikn[m] = 0
                end
            end
        end
    end

    local monsterAttr1 = {}

    local count = 1
    for id,com in pairs(heroData) do
        local heroT = tab.hero[tonumber(id)]
        local _special = heroT["special"]
        local _global = heroT["global"]
        local masteryId = _special*10+_global
        local heroStar = com.star
        -- print("heroStar=========", id, heroStar, _global)
        if heroStar >= _global then
            local masteryD = tab.heroMastery[masteryId]
            local addattrs = masteryD["addattr"]
            local tagaddsk = masteryD["tagaddsk"]
            local apprange0 = masteryD["apprange0"]
            local apprange1 = masteryD["apprange1"]
            local apprange2 = masteryD["apprange2"]
            local apprange3 = masteryD["apprange3"]
            if not addattrs then
                addattrs = {}
            end
            if tagaddsk then
                for k = 1, #tagaddsk do
                    local sysSkill = SkillUtils:getTeamSkillByType(tagaddsk[k][2], tagaddsk[k][1])
                    if sysSkill.attr then
                        for k,v in pairs(sysSkill.attr) do
                            table.insert(addattrs, v)
                        end
                    end
                end
            end
            if apprange0 and apprange1 and apprange2 then
                if addattrs then
                    for k = 1, #addattrs do
                        local addattr = addattrs[k]
                        local attrid = addattr[1]
                        local value = (addattr[2] + addattr[3]) * count
                        for m = 1, 5 do
                            if apprange1[m] == 1 then
                                for n = 1, 2 do
                                    if apprange2[n] == 1 then
                                        for l = 1, 4 do
                                            if apprange0[l] == 1 then
                                                monsterAttr[n][m][l][attrid] = monsterAttr[n][m][l][attrid] + value
                                            end
                                        end
                                    end
                                end 
                            end
                        end
                    end
                end
            elseif apprange3 then
                -- 针对于特殊标签 team表 label1列的属性加成
                if addattrs then
                    for k = 1, #addattrs do
                        local addattr = addattrs[k]
                        local attrid = addattr[1]
                        local value = addattr[2] + addattr[3]
                        for m = 1, #apprange3 do
                            local label1 = apprange3[m]
                            if monsterAttr1[label1] == nil then
                                monsterAttr1[label1] = {}
                                for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
                                    monsterAttr1[label1][n] = 0
                                end
                            end
                            monsterAttr1[label1][attrid] = monsterAttr1[label1][attrid] + value
                        end
                    end
                end
            end
        end
    end

    return monsterAttr, monsterAttr1
    -- self._heroAttr = monsterAttr
    -- self._heroAttr1 = monsterAttr1
    -- return monsterAttr, monsterAttr1
end

function TeamModel:getTeamTreasure(volume)
    if not self._teamTreasure then
        self:setTeamTreasure()
    end
    local treasureData = {}
    -- tab.team(teamId)
    if volume == 16 then
        treasureData = self._teamTreasure[1]
    elseif volume == 9 then
        treasureData = self._teamTreasure[2]
    elseif volume == 4 then
        treasureData = self._teamTreasure[3]
    elseif volume == 1 then
        treasureData = self._teamTreasure[4]
    else
        treasureData= self._teamTreasure[1]
    end
    return treasureData
end

function TeamModel:setTeamBaseData()
    self._teamBaseData = {}
    for k,v in ipairs(self._data) do
        self._teamBaseData[v.teamId] = v
    end
end


function TeamModel:getTeamBaseData()
    return self._teamBaseData
end

function TeamModel:setTeamMap(data)
    self._teamMap = {}
    for k,v in ipairs(data) do
        self._teamMap[k] = v.teamId
    end
end

function TeamModel:getTeamMap()
    return self._teamMap
end


function TeamModel:getCloneData()
    local tempTeams = clone(self._data)
    return tempTeams
end

function TeamModel:getRaceCloneData(teamType)
    local tempTeams = clone(self:getClassTeam(teamType))
    return tempTeams
end

function TeamModel:getIndexMap()
    return self._indexMap
end
--[[
--! @function refreshDataOrder
--! @desc 对数据进行排序
--! @param 
--! @return 
--]]
function TeamModel:refreshDataOrder()
    if next(self._data) == nil then return end
    local formationModel = self._modelMgr:getModel("FormationModel")
    local loadedMap, backupLoadMap = formationModel:getTeamLoadedMap()
    local data1 = {}
    local data2 = {}
    local data3 = {}
    local tempData = self._data
    for k,v in pairs(tempData) do
        v.isInFormation = loadedMap[v.teamId]
        v.isInBackup = backupLoadMap[v.teamId]
        if v.isInFormation then
            table.insert(data1, v)
        elseif v.isInBackup then
            table.insert(data2, v)
        else
            table.insert(data3, v)
        end
    end
    local sortFunc = function(a, b)
        if a.score > b.score then
            return true
        end
        if a.score == b.score then 
            if a.stage > b.stage then 
                return true
            end
             if a.stage == b.stage then 
                if a.star > b.star then 
                    return true
                end
                if a.star == b.star then 
                    if a.teamId > b.teamId then 
                        return true
                    end
                end
             end
        end
    end 
    table.sort(data1, sortFunc)
    table.sort(data2, sortFunc)
    table.sort(data3, sortFunc)

    self._data = {}
    for k, v in pairs(data1) do
        table.insert(self._data, v)
    end
    for k, v in pairs(data2) do
        table.insert(self._data, v)
    end
    for k, v in pairs(data3) do
        table.insert(self._data, v)
    end

    self._indexMap = {}
    for k, v in pairs(self._data) do
        self._indexMap[v.teamId] = k
    end
end

--[[
--! @function processData
--! @desc 处理数据
--! @param inData table 追加数据集合
--! @return table
--]]
function TeamModel:processData(inData)

	local backData = {}
	for k1,v1 in pairs(inData) do
        -- 计算怪兽评分 怪兽星+怪兽阶+技能等级（4个单独计算）+装备阶（4个单独计算）
        v1.teamId = tonumber(k1)
        v1.newFlag = 0
        if v1.score == nil then 
            v1.score = 0
        end
        --觉醒初始化
        v1.ast = v1.ast or 0
        v1.aLvl = v1.aLvl or 0
        if not v1.tree then
            v1.tree = {}
            v1.tree.b1 = 0
            v1.tree.b2 = 0
            v1.tree.b3 = 0
        else
            v1.tree.b1 = v1.tree.b1 or 0
            v1.tree.b2 = v1.tree.b2 or 0
            v1.tree.b3 = v1.tree.b3 or 0
        end
        v1.skillTab = TeamUtils:getTeamAwakingSkill(v1)
        -- v1.score = self:handleTeamScore(v1)
        local onTeam, onStage, onStar, onSkill, onGrade, onBoost, onTree, onExclusive = self:checkTips(v1)
        v1.onTeam = onTeam
        v1.onStage = onStage
        v1.onStar = onStar
        v1.onSkill = onSkill
        v1.onGrade = onGrade
        v1.onBoost = onBoost
        v1.onTree = onTree
        v1.onExclusive = onExclusive
        
        v1.volume  = self:getTeamVolume(v1)

        -- 伪装数据
        v1.onCheck = BattleUtils.checkTeamData(v1, false)
        -- dump(v1, "test", 10)
		table.insert(backData,v1)
	end
    self:noticeMainTip()
	return backData
end

-- 检查数据是否被修改
function TeamModel:checkData()
    for k, v in pairs(self._data) do
        if v.onCheck ~= BattleUtils.checkTeamData(v, false) then
            return v
        end
    end
end

function TeamModel:getTeamVolume(inData)
    local volume
    local sysTeam = tab:Team(inData.teamId)
    if sysTeam.volume == 1 then
        volume = 5
    elseif sysTeam.volume == 2 then
        volume = 4
    elseif sysTeam.volume == 3 then
        volume = 3
    elseif sysTeam.volume == 4 then
        volume = 2
    elseif sysTeam.volume == 5 then
        volume = 1
    end
    return volume * volume
end

function TeamModel:getEquipItems(teamNum)
    self:updateEquipItems(teamNum)
    -- for k,v in pairs(self._equipItems) do
    --     print(k,v,lang(tab:Tool(k).name))
    -- end
    return self._equipItems
end

-- 根据参数对材料进行统计
function TeamModel:updateEquipItems(teamNum)
    teamNum = teamNum or (self._modelMgr:getModel("FormationModel"):getCommonFormationCount() + 2) or 10
    self._equipItems = {}
    for k,v in pairs(self._data) do
        if tonumber(k) <= teamNum then
            self:InfoEquipItems(v)
        end
    end
end

function TeamModel:InfoEquipItems(inTeam)
    local sysTeamData = tab:Team(inTeam.teamId)
    -- 怪兽符文进阶材料统计
    local equipStage
    local sysEquipment
    local equipStage, equipLevel
    local sysMater
    for index,v in pairs(sysTeamData.equip) do
        sysEquipment = tab:Equipment(v)
        equipStage = tonumber(inTeam["es" .. index])
        equipLevel = tonumber(inTeam["el" .. index])
        sysMater = sysEquipment["mater" .. equipStage] or {}
        if equipStage <= tab.setting["G_MAX_TEAMSTAGE"].value then 
            -- 所需材料
            for k1,mater in pairs(sysMater) do
                self._equipItems[mater[1]] = (self._equipItems[mater[1]] or 0) + mater[2]
                -- self:addEquipItems(mater)
            end
        end
    end
end

-- function TeamModel:addEquipItems(mater)
--     if self._equipItems == nil then
--         self._equipItems = {}
--     end
--     self._equipItems[mater[1]] = (self._equipItems[mater[1]] or 0) + mater[2]
-- end

function TeamModel:getAwakingOpen(teamId)
    local flag = false
    local teamTab = tab.team[teamId]
    local curServerTime = self._userModel:getCurServerTime()
    local awakingTime = teamTab.awakingTime
    if teamTab.awakingIs then
        if (not awakingTime) or (awakingTime and awakingTime < curServerTime) then
            flag = true 
        end
    end
    return flag
end 

-- 检查红点
function TeamModel:checkTips(inTeam)
    if self._checkTipData == nil then 
        self._checkTipData = {}
    end
    local sysTeamData = tab:Team(inTeam.teamId)
    
    local onStage = self:checkUpStage(inTeam, sysTeamData)
    
    local onStar = self:checkUpStar(inTeam, sysTeamData)

    local onSkill = self:checkOpenSkill(inTeam, sysTeamData)

    local onGrade = self:checkUpGrade(inTeam, sysTeamData)

    local onBoost = self:checkBoost(inTeam, sysTeamData)

    local onTree = self:checkTree(inTeam, sysTeamData)

    local onExclusive = self:checkExclusive(inTeam, sysTeamData)

    local onTeam = false 

    if onStage == true or onStar == true or onSkill == true or onExclusive == true 
        or onGrade == true or onTree == 2 then 
        onTeam = true 
        self._checkTipData[tostring(inTeam.teamId)] = true
    else 
        self._checkTipData[tostring(inTeam.teamId)] = nil
    end
    return onTeam, onStage, onStar, onSkill, onGrade, onBoost, onTree, onExclusive
end

function TeamModel:checkExclusive( inTeam, sysTeamData )
    local flag = false
    local tabData = tab:SystemOpen("Exclusive")
    local exclusiveShowLevel = tabData[2]
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userLevel = userData.lvl

    local exclusiveData = tab.exclusive[inTeam.teamId]
    if exclusiveData and exclusiveData.isOpen and exclusiveData.isOpen == 1 and userLevel >= exclusiveShowLevel then
        local curExLevel = inTeam.zLv or 0
        local curExExp = inTeam.zExp or 0
        local curExStarLevel = (inTeam.zStar or 0) - 1

        local teamLv = inTeam.level
        local maxLv = tab.setting["G_EXCLUSIVE_MAXLEVEL"].value
        if curExLevel < teamLv and curExLevel < maxLv then
            local levelupData = tab.exclusiveLevel[curExLevel]
            local allExpNum = levelupData.exp
            local consumeData = levelupData.cost[1]
            local xishu = exclusiveData.xishu or 1
            local needNum = (math.ceil(consumeData[3] * xishu)) * (allExpNum - curExExp)
            local itemId = consumeData[2]
            local itemType = consumeData[1]
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            local _, haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
            if haveNum >= needNum then
                flag = true
            end
        end

        local consumeList = exclusiveData.costs
        local maxLevel = #consumeList - 1
        if curExStarLevel < maxLevel then
            local consumeData = consumeList[curExStarLevel + 2]
            local itemId = consumeData[2]
            local itemType = consumeData[1]
            local needNum = consumeData[3]
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            local _, haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
            if haveNum >= needNum then
                flag = true
            end
        end
    end
    return flag
end

-- 觉醒红点
function TeamModel:checkTree(inTeam, sysTeamData)
    local flag = 0
    -- 是否可觉醒
    local state = self:getTeamAwakingState(inTeam)
    local awakOpen = self:getAwakingOpen(inTeam.teamId)
    if (state == 4 or state == 2) and awakOpen == true then
        flag = 1
        return flag
    end
    -- dump(inTeam)
    -- 是否可选择
    if state == 5 then
        if flag == 0 then
            local awakingLimit = tab:Setting("AWAKINGLIMIT").value
            local branchData = inTeam.tree
            local teamStage = inTeam.stage
            local tskill = sysTeamData.skill 
            for tree=1,3 do
                local talentTree = sysTeamData["talentTree" .. tree]
                local _tskill = tskill[talentTree[1]]
                if teamStage >= awakingLimit[tree] then
                    if branchData["b" .. tree] == 0 then
                        flag = 1
                        break
                    end
                end
            end
        end
        if flag == 0 then
            local purpleStar = inTeam.aLvl
            local yellowStar = inTeam.star 
            local itemId = sysTeamData.awakingUp
            local awakingUpTab = sysTeamData.awakingUpNum
            local costNum = awakingUpTab[purpleStar]
            local _, tempItemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
            if costNum and tempItemCount >= costNum then
                if purpleStar < yellowStar then
                    flag = 2
                end
            end
        end
    end
    return flag
end



-- 技巧红点
function TeamModel:checkBoost(inTeam, sysTeamData)
    local flag = false
    -- if inTeam.level < 30 then
    --     return false
    -- end
    -- -- dump(inTeam)

    -- local sTeamId = tostring(inTeam.teamId)
    -- local itemModel = self._modelMgr:getModel("ItemModel")
    -- local boostD = inTeam.tb or {}

    -- -- 是否满级
    -- local maxLvl = tab:TeamQuality(inTeam.stage).techniqueLevel or 0

    -- -- 是否有材料
    -- local boostTab = sysTeamData.technique 
    -- for i=1,4 do
    --     -- print("team=====", sTeamId, maxLvl, boostD[tostring(boostTab[i])])
    --     if boostD[tostring(boostTab[i])] and boostD[tostring(boostTab[i])] < maxLvl then
    --         local itemId = tab:Technique(boostTab[i]).itemId
    --         local tempItems, tempItemCount = itemModel:getItemsById(itemId)
    --         if tempItemCount > 0 then
    --             flag = true
    --             break
    --         end
    --     elseif (not boostD[tostring(boostTab[i])]) and inTeam.stage >= 6 then
    --         local itemId = tab:Technique(boostTab[i]).itemId
    --         local tempItems, tempItemCount = itemModel:getItemsById(itemId)
    --         if tempItemCount > 0 then
    --             flag = true
    --             break
    --         end
    --     end
    -- end

    return flag
end

-- 进阶红点
function TeamModel:checkUpStage(inTeam, sysTeamData)
    local sTeamId = tostring(inTeam.teamId)

    local itemModel = self._modelMgr:getModel("ItemModel")
    -- 进阶
    local flag = 1
    for k,v in pairs(sysTeamData.equip) do
        if inTeam["es" .. k] == nil then
            return false
        end
        if inTeam.stage == nil then
            return false
        end
        if tonumber(inTeam["es" .. k]) <= inTeam.stage then
            flag = 0
        end
    end
    if flag == 1 then  
        return true
    end

    -- 怪兽符文进阶
    flag = 0
    local equipStage
    local sysEquipment
    local systemItem
    local tempItems, tempItemCount
    local equipStage, equipLevel
    local sysMater
    for index,v in pairs(sysTeamData.equip) do
        sysEquipment = tab:Equipment(v)

        if not sysEquipment then
            local userInfo = self._modelMgr:getModel("UserModel"):getData()
            self._viewMgr:onLuaError(serialize({userid = userInfo._id, teamId = inTeam.teamId}))
            return false
        end
        equipStage = tonumber(inTeam["es" .. index])
        equipLevel = tonumber(inTeam["el" .. index])
        sysMater = sysEquipment["mater" .. equipStage]

        local _level = sysEquipment.level[equipStage] or 100
        if equipLevel >= _level
            and equipStage <= tab.setting["G_MAX_TEAMSTAGE"].value then 
            local tempFlag = 1
            -- 所需材料
            if sysMater then
                for k1,mater in pairs(sysMater) do
                    systemItem = tab:Tool(mater[1])
                    tempItems, tempItemCount = itemModel:getItemsById(mater[1])
                    if tempItemCount < mater[2] then
                        tempFlag = 0
                    end
                end
            else
                tempFlag = 0
            end

            -- 所需材料有满足的就表示可提示
            if tempFlag == 1 then 
                flag = 1
            end
        end
    end

    if flag == 1 then 
        return true
    end
    return false
end

-- 升级红点
function TeamModel:checkUpGrade(inTeam, sysTeamData)
    local sTeamId = tostring(inTeam.teamId)
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local flag = false
    if tonumber(userData.lvl) > tonumber(inTeam.level) then
        local nextExp = tab:TeamLevel(inTeam.level).exp 
        if tonumber(userData.texp) >= (nextExp - inTeam.exp) then
            flag = true
        end
    end
    return flag
end

-- 升星红点
function TeamModel:checkUpStar(inTeam, sysTeamData)
    local sTeamId = tostring(inTeam.teamId)
    local itemModel = self._modelMgr:getModel("ItemModel")
    -- 同名魂

    if inTeam.star ~= self.kMaxBgStar then
        local sameSouls, sameSoulCount = itemModel:getItemsById(sysTeamData.goods)
        local smallStar = self:getSmallStar(inTeam)

        if smallStar <= self.kSmallBgStar then 
            local teamSmallStar = tab.star[inTeam.star]
            if sameSoulCount >= teamSmallStar.cost then 
                return true
            end
        else
            return true
        end
    elseif inTeam.avn ~= 1 and inTeam.star == self.kMaxBgStar then
        return true
    elseif inTeam.avn == 1 then
        local sameSouls, sameSoulCount = itemModel:getItemsById(sysTeamData.goods)
        local starLevel = 0
        local starMinLevel = 100
        for i=1,3 do
            if inTeam.pl and inTeam.pl[tostring(i)] then
                if inTeam.pl[tostring(i)] < starMinLevel then
                    starMinLevel = inTeam.pl[tostring(i)]
                end
            else
                starMinLevel = 0
            end
        end
        starMinLevel = starMinLevel + 1
        if starMinLevel >= TeamUtils.hPotentialStar then
            return false
        end

        local potentialTab = tab:Potential(starMinLevel)
        if potentialTab and sameSoulCount >= potentialTab.goodsNum then
            return true
        end
    end
    -- if self._checkTipData[sTeamId] == true then 
    --     return true
    -- end
    return false
end

-- 升星红点
function TeamModel:checkUpHighStar(inTeam, sysTeamData)
    local sTeamId = tostring(inTeam.teamId)
    local itemModel = self._modelMgr:getModel("ItemModel")
    -- 同名魂
    -- avn
    if inTeam.star ~= self.kMaxBgStar then
        local sameSouls, sameSoulCount = itemModel:getItemsById(sysTeamData.goods)
        local smallStar = self:getSmallStar(inTeam)

        if smallStar <= self.kSmallBgStar then 
            local teamSmallStar = tab.star[inTeam.star]
            if sameSoulCount >= teamSmallStar.cost then 
                return true
            end
        else
            return true
        end
    elseif inTeam.avn ~= 1 then
        return true
    elseif inTeam.avn == 1 then
        local sameSouls, sameSoulCount = itemModel:getItemsById(sysTeamData.goods)
        if inTeam.pl then
            local starLevel = 0
            for i=1,3 do
                if inTeam.pl[tostring(i)] and inTeam.pl[tostring(i)] > starLevel then
                    starLevel = inTeam.pl[tostring(i)]
                end
            end
            local potentialTab = tab:Potential(starLevel)
            if potentialTab and sameSoulCount >= potentialTab.goodsNum then
                return true
            end
        end
    end
    -- if self._checkTipData[sTeamId] == true then 
    --     return true
    -- end
    return false
end

-- 技能红点
function TeamModel:checkOpenSkill(inTeam)
    for i=1,4 do
        if inTeam["sl" .. i] == 0 then
            return true
        end
    end
    for i = 5, 6 do
        local isShow = self:checkTeamRedSKillRedPoint(inTeam)
        if isShow then
            return true
        end
    end
    return false
end



function TeamModel:getSmallStar(data)
    return 1 + data.smallStar - (data.star - 1) * 10
end



function TeamModel:noticeMainTip()
    -- -- 
    -- {iconName = "bottomLayer.monsterBtn",detectFuc = function( )
    --     return self._modelMgr:getModel("MainViewModel"):getNoticeMap()["TeamListView"]
    -- end},
    -- if next(self._checkTipData) ~= nil then
    --     self._modelMgr:getModel("MainViewModel"):setNotice("TeamListView",true)
    -- else
        -- self:initGetSysTeams()
        -- if next(self._getSysTeam) ~= nil then 
        --     self._modelMgr:getModel("MainViewModel"):setNotice("TeamListView",true)
        -- else
        --     self._modelMgr:getModel("MainViewModel"):setNotice("TeamListView",false)
        -- end
    -- end
end

function TeamModel:isNoticeMainTip()
    local flag = false
    self:initGetSysTeams()
    if next(self._getSysTeam) ~= nil then 
        flag = true
    end
    local formationModel = self._modelMgr:getModel("FormationModel")
    local formationTeamData = formationModel:getFormationTeamDataByType(1)

    if flag == false then
        for i,v in ipairs(formationTeamData) do
            if self._checkTipData[tostring(v)] == true then
                flag = true
                break
            end
        end
    end
    if flag == false then
        for i,v in ipairs(self._data) do
            if v.onTree == 1 then
                flag = true
                break
            end
        end
    end
    return flag
end


--[[
--! @function updateTeamTips
--! @desc 更新怪兽红点提示数据
--! @param inData object 单一数据
--! @return table
--]]
function TeamModel:updateTeamTips()
    if self._data == nil then 
        return 
    end
    for k1,v1 in ipairs(self._data) do
        self._checkTipData[tostring(v1.teamId)] = nil
        --觉醒初始化
        v1.ast = v1.ast or 0
        v1.aLvl = v1.aLvl or 0
        if not v1.tree then
            v1.tree = {}
            v1.tree.b1 = 0
            v1.tree.b2 = 0
            v1.tree.b3 = 0
        else
            v1.tree.b1 = v1.tree.b1 or 0
            v1.tree.b2 = v1.tree.b2 or 0
            v1.tree.b3 = v1.tree.b3 or 0
        end

        v1.skillTab = TeamUtils:getTeamAwakingSkill(v1)

        local onTeam, onStage, onStar, onSkill, onGrade, onBoost, onTree, onExclusive = self:checkTips(v1)
        v1.onTeam = onTeam
        v1.onStage = onStage
        v1.onStar = onStar
        v1.onSkill = onSkill
        v1.onGrade = onGrade
        v1.onBoost = onBoost
        v1.onTree = onTree
        v1.onExclusive = onExclusive
    end
    self:noticeMainTip()
end

--[[
--! @function updateTeamData
--! @desc 更新一条team 数据
--! @param inData object 单一数据
--! @return table
--]]
function TeamModel:updateTeamData(inData,isNotReflash)
    local tempIndex = 0
    for k2,v2 in pairs(inData) do
        tempIndex = 0
        v2.teamId = tonumber(k2)
        for k1,v1 in ipairs(self._data) do
            if v1.teamId == v2.teamId then 
                for k3,v3 in pairs (v2) do 
                    if k3 == "tb" or k3 == "pl" then
                        if not v1[k3] then
                            v1[k3] = {}
                        end
                        for k4,v4 in pairs(v2[k3]) do
                            v1[k3][k4] = v2[k3][k4]
                        end
                    elseif k3 == "tree" then
                        if not v1[k3] then
                            v1[k3] = {}
                            v1[k3].b1 = 0
                            v1[k3].b2 = 0
                            v1[k3].b3 = 0
                        end

                        for k4,v4 in pairs(v2[k3]) do
                            v1[k3][k4] = v2[k3][k4]
                        end
                    elseif k3 == "rune" then
                        if not v1[k3] then
                            v1[k3] = {}
                        end
                        -- 有可能不返回suit字段(卸下有没有套装效果)
                        local isHaveSuit = false
                        for k4,v4 in pairs(v2[k3]) do
                            if k4 == "suit" then
                                isHaveSuit = true
                                if not v1[k3][k4] then
                                    v1[k3][k4] = {}
                                end
                                -- 套装没有全部卸下的时候，兵团界面还会有影响
                                local array = {"2","4","6"}
                                for _,key in ipairs(array) do
                                    if v4[key] then
                                        v1[k3][k4][key] = v4[key]
                                    else
                                        v1[k3][k4][key] = nil
                                    end
                                end
                            else
                                v1[k3][k4] = v2[k3][k4]
                            end
                        end
                        if not isHaveSuit then
                            v1[k3]["suit"] = {}
                        end
                    elseif v2[k3] ~= nil then 
                        v1[k3] = v2[k3]
                    end
                end

                --觉醒初始化
                v1.ast = v1.ast or 0
                v1.aLvl = v1.aLvl or 0

                v1.skillTab = TeamUtils:getTeamAwakingSkill(v1)

                self._checkTipData[tostring(v1.teamId)] = nil
                local onTeam, onStage, onStar, onSkill, onGrade, onBoost, onTree, onExclusive = self:checkTips(v1)
                v1.onTeam = onTeam
                v1.onStage = onStage
                v1.onStar = onStar
                v1.onSkill = onSkill
                v1.onGrade = onGrade
                v1.onBoost = onBoost
                v1.onTree = onTree
                v1.onExclusive = onExclusive

                -- 伪装数据
                v1.onCheck = BattleUtils.checkTeamData(v1, false)
                tempIndex = k1
                break 
            end
        end
        -- 如果是新数据
        if tempIndex == 0 then 
            if v2.score == nil then 
                v2.score = 0
            end
            v2.newFlag = 1
            self._checkTipData[tostring(v2.teamId)] = nil
            --觉醒初始化
            v2.ast = v2.ast or 0
            v2.aLvl = v2.aLvl or 0
            if not v2.tree then
                v2.tree = {}
                v2.tree.b1 = 0
                v2.tree.b2 = 0
                v2.tree.b3 = 0
            else
                v2.tree.b1 = v2.tree.b1 or 0
                v2.tree.b2 = v2.tree.b2 or 0
                v2.tree.b3 = v2.tree.b3 or 0
            end
            v2.skillTab = TeamUtils:getTeamAwakingSkill(v2)

            local onTeam, onStage, onStar, onSkill, onGrade, onBoost, onTree, onExclusive = self:checkTips(v2)
            v2.onTeam = onTeam
            v2.onStage = onStage
            v2.onStar = onStar
            v2.onSkill = onSkill
            v2.onGrade = onGrade
            v2.onBoost = onBoost
            v2.onTree = onTree
            v2.onExclusive = onExclusive

            -- 伪装数据
            v2.onCheck = BattleUtils.checkTeamData(v2, false)
            table.insert(self._data, v2)

            --初始化特技数据
            if not v2["sl5"] then v2["sl5"] = -1 end
            if not v2["sl6"] then v2["sl6"] = -1 end
            if not v2["sl7"] then v2["sl7"] = -1 end
            if not v2["se5"] then v2["se5"] = 0 end
            if not v2["se6"] then v2["se6"] = 0 end
            if not v2["se7"] then v2["se7"] = 0 end
        end
    end
    self:noticeMainTip()
    self:refreshDataOrder()
    if isNotReflash == nil or 
        isNotReflash == false then 
        self:reflashData()
    end
    local pokedexModel = self._modelMgr:getModel("PokedexModel")
    pokedexModel:processData()
    self:progressTeamUseHolyData()
end

--[[
--! @function getTeamAndIndexById
--! @desc 根据id获取当前team数据和所在位置
--! @param tempTeamData object 单一数据
--! @param tempIndex int 
--! @return table
--]]
function TeamModel:getTeamAndIndexById(inTeamId)
    local tempIndex = 0
    local tempTeamData = nil
    for k1,v1 in pairs(self._data) do
        if v1.teamId == inTeamId then 
            tempIndex = k1
            tempTeamData = v1
            break
        end
    end
    return tempTeamData, tempIndex
end

--[[
--! @function getTeamWithDef
--! @desc 根据兵种获取小型怪兽
--! @return 
--]]
function TeamModel:getTeamWithSmall()
    return self:getTeamWithVolume(2)
end

--[[
--! @function getTeamWithMiddle
--! @desc 根据兵种获取中型怪兽
--! @return 
--]]
function TeamModel:getTeamWithMiddle()
    return self:getTeamWithVolume(3)
end

--[[
--! @function getTeamWithBig
--! @desc 根据兵种获取大型怪兽
--! @return 
--]]
function TeamModel:getTeamWithBig()
    return self:getTeamWithVolume(4)
end

--[[
--! @function getTeamWithHuge
--! @desc 根据兵种获取巨型怪兽
--! @return 
--]]
function TeamModel:getTeamWithHuge()
    return self:getTeamWithVolume(5)
end

--[[
--! @function getTeamWithVolume
--! @desc 根据人数获取怪兽
--！@param inClass 兵种大小
--! @return table
--]]
function TeamModel:getTeamWithVolume(inClass)
    local classTeam = {}
    local sysTeam
    for k,v in pairs(self:getData()) do
        sysTeam = tab:Team(v.teamId)
        if sysTeam.volume == inClass then 
            table.insert(classTeam, v)
        end
    end
    return classTeam
end


--[[

    根据class获取兵团

]]
function TeamModel:getHaveTeamWithClass( classType )
    local classTeam = {}
    local sysTeam
    for k,v in pairs(self:getData()) do
        sysTeam = tab:Team(v.teamId)
        if sysTeam.class == classType then 
            table.insert(classTeam, v)
        end
    end
    return classTeam
end

-- 平原
function TeamModel:getTeamWithPingyuan()
    return self:getTeamWithRace(101)
end

-- 森林
function TeamModel:getTeamWithSenlin()
    return self:getTeamWithRace(102)
end

-- 据点
function TeamModel:getTeamWithJudian()
    return self:getTeamWithRace(103)
end

-- 墓园
function TeamModel:getTeamWithMuyuan()
    return self:getTeamWithRace(104)
end

-- 地狱
function TeamModel:getTeamWithDiyu()
    return self:getTeamWithRace(105)
end

-- 塔楼
function TeamModel:getTeamWithTalou()
    return self:getTeamWithRace(106)
end

-- 地下城
function TeamModel:getTeamWithDixiacheng()
    return self:getTeamWithRace(107)
end

-- 元素
function TeamModel:getTeamWithYuansu()
    return self:getTeamWithRace(109)
end

-- 要塞
function TeamModel:getTeamWithYaosai()
    return self:getTeamWithRace(108)
end

-- 海盗
function TeamModel:getTeamWithHaidao()
    return self:getTeamWithRace(112)
end

-- 根据兵种标签划分
function TeamModel:getTeamWithRace(inClass)
    local classTeam = {}
    local sysTeam

    local formationModel = self._modelMgr:getModel("FormationModel")
    local tempTeamLoadMap, backupLoadMap = formationModel:getTeamLoadedMap()
    for k,v in pairs(self:getAllTeamData()) do
        sysTeam = tab:Team(v.teamId)
        v.isInFormation = tempTeamLoadMap[v.teamId]
        v.isInBackup = backupLoadMap[v.teamId]
        if sysTeam.race[1] == inClass then 
            table.insert(classTeam, v)
        end
    end
    return classTeam
end


--[[
--! @function getTeamQualityByStage
--! @desc 根据阶获取怪兽品质
--! @param inStage int 怪兽阶
--! @return table
--]]
function TeamModel:getTeamQualityByStage(inStage)
    return BattleUtils.TEAM_QUALITY[inStage]
end

--[[
--! @function getTeamWithDef
--! @desc 根据兵种获取防御型怪兽
--! @return 
--]]
function TeamModel:getTeamWithDef()
    return self:getTeamWithClass(2)
end

--[[
--! @function getTeamWithClass
--! @desc 根据兵种获取近战型怪兽
--! @return table
--]]
function TeamModel:getTeamWithMelee()
    return self:getTeamWithClass(1)
end

--[[
--! @function getTeamWithRemote
--! @desc 根据兵种获取远程型怪兽
--! @return table 
--]]
function TeamModel:getTeamWithRemote()
    return self:getTeamWithClass(4)
end

--[[
--! @function getTeamWithRemote
--! @desc 根据兵种获取魔法型怪兽
--! @return table
--]]
function TeamModel:getTeamWithMagic()
    return self:getTeamWithClass(5)
end


--[[
--! @function getTeamWithSally
--! @desc 根据兵种获取魔法型怪兽
--! @return table
--]]
function TeamModel:getTeamWithSally()
    return self:getTeamWithClass(3)
end

--[[
--! @function getTeamWithClass
--! @desc 根据兵种获取怪兽
--！@param inClass 兵种标签
--! @return table
--]]
function TeamModel:getTeamWithClass(inClass)
    local classTeam = {}
    local sysTeam
    
    for k,v in pairs(self:getAllTeamData()) do
        sysTeam = tab:Team(v.teamId)
        if sysTeam.class == inClass then 
            table.insert(classTeam, v)
        end
    end
    return classTeam
end

--[[
--! @function initAllSysTeams
--! @desc 初始化怪兽系统数据
--]]
function TeamModel:getAllTeamData()
    local tempTeam = {}
    local sysTeam
    local formationModel = self._modelMgr:getModel("FormationModel")
    local tempTeamLoadMap, backupTeamLoadMap = formationModel:getTeamLoadedMap()
    for k,v in pairs(self:getData()) do
        v.isInFormation = tempTeamLoadMap[v.teamId]
        v.isInBackup = backupTeamLoadMap[v.teamId]
        v.showType = 1
        table.insert(tempTeam, v)
    end
    local tempGetTeam = self:getCanGatTeams()
    for i=#tempGetTeam, 1 ,-1 do
        local team = tempGetTeam[i]
        table.insert(tempTeam, 1, team)
    end
    
    return tempTeam
end

--[[
--! @function initAllSysTeams
--! @desc 初始化怪兽系统数据
--]]
function TeamModel:initGetSysTeams()
    local tempTeamData = {}
    for k,v in pairs(self._data) do
        v.volume = self:getTeamVolume(v)        
        tempTeamData[tostring(v.teamId)] = true
    end
    local itemModel = self._modelMgr:getModel("ItemModel")

    self._getSysTeam = {}
    for k, v in pairs(tab.team) do
        if tempTeamData[tostring(v.id)] == nil and 
            v.show == 1 then
            local sameSouls, sameSoulCount = itemModel:getItemsById(v.goods)
            local teamStar = tab:Star(v.starlevel)
            if sameSoulCount >=  teamStar.sum then
                local tempTeam = {}
                tempTeam.teamId = v.id
                tempTeam.soulCount = sameSoulCount
                tempTeam.starlevel = v.starlevel
                tempTeam.sum = teamStar.sum
                tempTeam.class = v.class
                tempTeam.goods = v.goods
                tempTeam.showType = 2
                table.insert(self._getSysTeam, tempTeam)
            end
        end
    end
    local sortFunc = function(a, b) 
        if a.soulCount > b.soulCount then 
            return true
        end
        if a.soulCount == b.soulCount then 
            if a.starlevel > b.starlevel then 
                return true
            end
            if a.starlevel == b.starlevel then 
                if a.teamId > b.teamId then 
                    return true
                end
            end
        end
    end
    -- dump(self._getSysTeam)
    table.sort(self._getSysTeam, sortFunc)
end 

--[[
--! @function initAllSysTeams
--! @desc 初始化怪兽系统数据
--]]
function TeamModel:getCanGatTeams()
    if not self._getSysTeam then
        self:initGetSysTeams()
    end
    return self._getSysTeam
end

function TeamModel:isCanGatTeams(teamId)
    local flag = false
    for k,v in ipairs(self._getSysTeam) do
        if v.teamId == teamId then
            flag = true
        end
    end
    return flag
end


--[[
--! @function initAllSysTeams
--! @desc 初始化怪兽系统数据
--]]
function TeamModel:initAllSysTeams()
    local tempTeamData = {}
    for k,v in pairs(self._data) do
        tempTeamData[tostring(v.teamId)] = true
    end
    local itemModel = self._modelMgr:getModel("ItemModel")

    self._sysTeam = {}
    for k, v in pairs(tab.team) do
        if tempTeamData[tostring(v.id)] == nil and 
            v.show == 1 then
            local sameSouls, sameSoulCount = itemModel:getItemsById(v.goods)
            local teamStar = tab:Star(v.starlevel)

            if sameSoulCount < teamStar.sum then
                local tempTeam = {}
                tempTeam.teamId = v.id
                
                tempTeam.soulCount = sameSoulCount
                tempTeam.starlevel = v.starlevel
                tempTeam.sum = teamStar.sum
                tempTeam.class = v.class
                tempTeam.goods = v.goods
                tempTeam.showType = 2
                table.insert(self._sysTeam, tempTeam)
            end
        end
    end
    local sortFunc = function(a, b) 
        if (a.soulCount >= a.sum) == true and  
            (b.soulCount >= b.sum) == false then
            return true
        end
        if (a.soulCount >= a.sum) == (b.soulCount >= b.sum) then 

            if a.soulCount > b.soulCount then 
                return true
            end
            if a.soulCount == b.soulCount then 
                if a.starlevel > b.starlevel then 
                    return true
                end
                if a.starlevel == b.starlevel then 
                    if a.teamId < b.teamId then 
                        return true
                    end
                end
            end
        end
    end
    table.sort(self._sysTeam, sortFunc)    
end

--[[
--! @function getAllSysTeams
--! @desc 获取初始化后的怪兽系统数据
--! @return table
--]]
function TeamModel:getAllSysTeams()
    return self._sysTeam
end

--[[
--! @function getSysTeamWithDef
--! @desc 根据兵种获取防御型系统怪兽
--! @return table
--]]
function TeamModel:getSysTeamWithDef()
    return self:getSysTeamWithClass(2)
end

--[[
--! @function getSysTeamWithMelee
--! @desc 根据兵种获取近战型系统怪兽
--! @return table
--]]
function TeamModel:getSysTeamWithMelee()
    return self:getSysTeamWithClass(1)
end

--[[
--! @function getSysTeamWithRemote
--! @desc 根据兵种获取远程型系统怪兽
--! @return table
--]]
function TeamModel:getSysTeamWithRemote()
    return self:getSysTeamWithClass(4)
end

--[[
--! @function getSysTeamWithMagic
--! @desc 根据兵种获取魔法型系统怪兽
--! @return table
--]]
function TeamModel:getSysTeamWithMagic()
    return self:getSysTeamWithClass(5)
end

--[[
--! @function getSysTeamWithSally
--! @desc 根据兵种获取突击型系统怪兽
--! @return table
--]]
function TeamModel:getSysTeamWithSally()
    return self:getSysTeamWithClass(3)
end

--[[
--! @function getSysTeamWithSally
--! @desc 根据兵种获取系统怪兽
--！@param inClass 兵种标签
--! @return table
--]]
function TeamModel:getSysTeamWithClass(inClass)
    local classTeam = {}
    local tempTeam 
    local sameSouls, sameSoulCount
    for k, v in pairs(self._sysTeam) do
        if v.class == inClass then
            table.insert(classTeam, v)
        end
    end
    return classTeam
end

-- 根据品阶判断当前是否有该品阶兵团
function TeamModel:isTeamStageHave(stage, num)
    num = num or 1
    local teamStageNum = 0
    for k,v in pairs(self._data) do
        if v.stage >= stage then
            teamStageNum = teamStageNum + 1
            if teamStageNum >= num then
                return true
            end
        end
    end
    return false
end

-- 根据兵团获取相应图鉴类型
function TeamModel:getPokedexIdByTeamId(teamId)
    local teamD = tab:Team(teamId)
    local pokedexId = teamD["tujian"] 
    return pokedexId -- pokedexId1, pokedexId2
end

-- 根据类型获取相应军团
function TeamModel:getClassTeam(teamType)
    local teamData = {} 
    local tempTeamData = {}

    if teamType == 1 then -- 输出
        teamData = self:getTeamWithMelee()
    elseif teamType == 2 then -- 防御
        teamData = self:getTeamWithDef()
    elseif teamType == 3 then -- 突击
        teamData = self:getTeamWithSally()
    elseif teamType == 4 then -- 射手
        teamData = self:getTeamWithRemote()
    elseif teamType == 5 then -- 魔法
        teamData = self:getTeamWithMagic()
    elseif teamType == 6 then -- 平原
        teamData = self:getTeamWithPingyuan()
    elseif teamType == 7 then -- 森林
        teamData = self:getTeamWithSenlin()
    elseif teamType == 8 then -- 据点
        teamData = self:getTeamWithJudian()
    elseif teamType == 9 then -- 墓园
        teamData = self:getTeamWithMuyuan()
    elseif teamType == 10 then -- 地狱
        teamData = self:getTeamWithDiyu()
    elseif teamType == 11 then -- 塔楼
        teamData = self:getTeamWithTalou()
    elseif teamType == 12 then -- 元素
        teamData = self:getTeamWithYuansu()
    elseif teamType == 13 then -- 地下城
        teamData = self:getTeamWithDixiacheng()
    elseif teamType == 14 then -- 要塞
        teamData = self:getTeamWithYaosai()
    elseif teamType == 15 then -- 海盗
        teamData = self:getTeamWithHaidao()
    elseif teamType == 0 then -- 全部
        teamData = self._data
    end

    for k,v in pairs(teamData) do
        if v.showType == 1 then
            table.insert(tempTeamData, v)
        end
    end
    return tempTeamData
end

-- 获取已有的13,14资质兵团列表
function TeamModel:getTeamDataByZizhi()
    local classTeam = {}
    local sysTeam
    for k,v in pairs(self:getAllTeamData()) do
        sysTeam = tab:Team(v.teamId)
        if sysTeam.zizhi < 3 and v.smallStar ~= nil then 
            table.insert(classTeam, v)
        end
    end
    
    local sortFunc = function(a, b)
        local astar = a.smallStar
        local bstar = b.smallStar
        local ateamId = a.teamId
        local bteamId = b.teamId
        -- print("astar =============", astar, bstar)
        if astar == nil or bstar == nil then
            return 
        end
        if astar ~= bstar then
            return astar > bstar
        elseif ateamId ~= bteamId then
            return ateamId > bteamId
        end
    end

    table.sort(classTeam, sortFunc)
    return classTeam
end

function TeamModel:getTeamMaxFightScore()
    local teamId
    local score = 0
    for k,v in pairs(self:getData()) do
        if v.score > score then
            score = v.score
            teamId = v.teamId
        end
    end
    return teamId
end

function TeamModel:getTeamPokedexScore(inTeamId)
    local teamD = self:getTeamAndIndexById(inTeamId)
    return self:getTeamAddPingScore(teamD)
end

-- 兵团评分
function TeamModel:getTeamAddPingScore(teamD)
    -- 评分=兵团星级*50+兵团小星总数*5+兵团等级*3+兵团阶*15+装备等级*1+装备阶*5+技能*8 
    -- dump(teamD)
    if not teamD.teamId then
        return 0
    end
    local _, talentScore = self:getSkillLevelAndScore(teamD)
    local awakingScore = self:getAwakingTeamScore(teamD)
    local score = awakingScore + teamD.star*50 + teamD.smallStar*5 + teamD.level*3 + teamD.stage*15 + 200 + talentScore
    for i=1,4 do
        score = score + teamD["el" .. i]*1 + teamD["es" .. i]*5
        if teamD["sl" .. i] > 0 then
            score = score + teamD["sl" .. i]*8
        end
    end
    local specialSkill = teamD["ss"]
    if specialSkill then
         score = score + teamD["sl" .. specialSkill] * 8
    end

    return score
end

function TeamModel:getAwakingTeamScore(teamD)
    if not teamD.teamId then
        return 0
    end
    if (not teamD.aLvl) or (teamD.aLvl == 0) then
        return 0
    end
    local awakingScore = tab:Setting("AWAKINGGRADE").value
    local score = awakingScore[teamD.aLvl]
    return score or 0
end

-- 兵团评价
function TeamModel:getTeamPingjia(pScore)
    if not pScore then
        return 1
    end
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userLvl = userData.lvl 
    local pNum = 1
    for k,v in pairs(tab.tujianpingjia) do
        local pLevel = v.level
        if userLvl > pLevel[1] and userLvl <= pLevel[2] then
            for i=4,1,-1 do
                if pScore > v.pingjia[i] then
                    pNum = i
                    break
                end
            end
        end
    end
    return pNum
end

------------------------------------------
-- MF专用
-------------------------------------------
function TeamModel:getUserTeamData()
    local userTeam = {}
    for k,v in pairs(self:getAllTeamData()) do
        if v.smallStar ~= nil then 
            table.insert(userTeam, v)
        end
    end
    return userTeam
end 

-- 201 阵营
function TeamModel:getTeamDataByZhenying(zhenying)
    local classTeam = {}
    local sysTeam
    local teamData = clone(self._data)
    for k,v in pairs(teamData) do
        sysTeam = tab:Team(v.teamId)
        if sysTeam.race[1] == zhenying and v.smallStar ~= nil then 
            v.tsort201 = 2
        else
            v.tsort201 = 1
        end
        table.insert(classTeam, v)
    end

    local sortFunc = function(a, b)
        local atsort = a.tsort201
        local btsort = b.tsort201
        if atsort == nil or btsort == nil then
            return 
        end
        if atsort ~= btsort then
            return atsort > btsort
        end
    end
    table.sort(classTeam, sortFunc)

    return classTeam
end

-- 202 类型
function TeamModel:getTeamDataByClass(classId)
    local classTeam = {}
    local sysTeam
    local teamData = clone(self._data)
    for k,v in pairs(teamData) do
        sysTeam = tab:Team(v.teamId)
        if sysTeam.class == classId and v.smallStar ~= nil then 
            v.tsort202 = 2
        else
            v.tsort202 = 1
        end
        table.insert(classTeam, v)
    end

    local sortFunc = function(a, b)
        local atsort = a.tsort202
        local btsort = b.tsort202
        if atsort == nil or btsort == nil then
            return 
        end
        if atsort ~= btsort then
            return atsort > btsort
        end
    end
    table.sort(classTeam, sortFunc)

    return classTeam
end

-- 203 按等级排序
function TeamModel:getTeamDataByLevel()
    local classTeam = {}
    local teamData = clone(self._data)
    for k,v in pairs(teamData) do
        if v.smallStar ~= nil then 
            v.tsort203 = v.level
            table.insert(classTeam, v)
        end
    end
    if table.nums(classTeam) <= 1 then
        return classTeam
    end
    local sortFunc = function(a, b)
        local alevel = a.tsort203
        local blevel = b.tsort203
        if alevel == nil or blevel == nil then
            return 
        end
        if alevel ~= blevel then
            return alevel > blevel
        end
        return false
    end
    table.sort(classTeam, sortFunc)
    return classTeam
end

-- 204 按星级排序
function TeamModel:getTeamDataByStar()
    local classTeam = {}
    local teamData = clone(self._data)
    for k,v in pairs(teamData) do
        if v.smallStar ~= nil then 
            v.tsort204 = v.star
            table.insert(classTeam, v)
        end
    end
    if table.nums(classTeam) <= 1 then
        return classTeam
    end
    local sortFunc = function(a, b)
        local astar = a.tsort204
        local bstar = b.tsort204
        if astar == nil or bstar == nil then
            return 
        end
        if astar ~= bstar then
            return astar > bstar
        end
        return false
    end
    table.sort(classTeam, sortFunc)
    return classTeam
end


-- 205 人数
function TeamModel:getTeamDataByPeopleNum(peopleNum)
    local classTeam = {}
    local sysTeam
    local teamData = clone(self._data)
    for k,v in pairs(teamData) do
        sysTeam = tab:Team(v.teamId)
        if sysTeam.volume == peopleNum and v.smallStar ~= nil then 
            v.tsort205 = 2
        else
            v.tsort205 = 1
        end
        table.insert(classTeam, v)
    end


    local sortFunc = function(a, b)
        local atsort = a.tsort205
        local btsort = b.tsort205
        if atsort == nil or btsort == nil then
            return 
        end
        if atsort ~= btsort then
            return atsort > btsort
        end
        return false
    end
    table.sort(classTeam, sortFunc)

    return classTeam
end

-- 206 按品阶排序
function TeamModel:getTeamDataByStage()
    local classTeam = {}
    local sysTeam
    local teamData = clone(self._data)
    for k,v in pairs(teamData) do
        if v.smallStar ~= nil then 
            v.tsort206 = v.stage
            table.insert(classTeam, v)
        end
    end
    if table.nums(classTeam) <= 1 then
        return classTeam
    end
    
    local sortFunc = function(a, b)
        local astage = a.tsort206
        local bstage = b.tsort206
        if astage == nil or bstage == nil then
            return 
        end
        if astage ~= bstage then
            return astage > bstage
        end
    end

    table.sort(classTeam, sortFunc)
    -- dump(classTeam, "classTeam =========")
    return classTeam
end

-- 207 按兵团评分
function TeamModel:getTeamDataPokedexByScore(conIndex)
    local classTeam = {}
    local sysTeam
    local teamData = clone(self._data)
    for k,v in pairs(teamData) do
        if v.smallStar ~= nil then 
            v["tsort" .. conIndex] = self:getTeamAddPingScore(v)
            table.insert(classTeam, v)
        end
    end
    if table.nums(classTeam) <= 1 then
        return classTeam
    end
    
    local sortFunc = function(a, b)
        local ascore = a["tsort" .. conIndex]
        local bscore = b["tsort" .. conIndex]
        if ascore == nil or bscore == nil then
            return 
        end
        if ascore ~= bscore then
            return ascore > bscore
        end
    end

    table.sort(classTeam, sortFunc)
    return classTeam
end


------------------------------------------
-- 抽卡
-- bool free
-------------------------------------------
function TeamModel:getFlashCardTimes(free)
    local isHavePrivilege = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.ZuanShiChouKa)
    local playerDayModel = self._modelMgr:getModel("PlayerTodayModel")
    local dayData = playerDayModel:getData()
    local drawData = playerDayModel:getDrawAward()
    local flag = false
    local isFree = false
    local isHalf = false
    local isFirstHalf = false
    if not drawData then
        drawData = {}
    end
    local teamLastTime = drawData.drawTeamLastTime or 0
    local toolFreeNum = tab:Setting("G_FREENUM_DRAW_TOOL_SINGLE").value + self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_8)
    local toolLastTime = drawData.drawToolLastTime or 0
    local toolNum = dayData.day7 or 0
-- 使用接口 function PrivilegesModel:getAbilityEffect(id) 
    print("toolFreeNum,toolNum============",toolFreeNum,toolNum)
    if (dayData.day1 == 0) 
        or (toolNum < toolFreeNum) 
        and free ~= 1 then
        isFree = true
    else
        if dayData.day1 == 1 then -- and isHavePrivilege ~= 0 then
            isHalf = true
        end
    end 

    if drawData.first == 0 and isHalf == true then
        isFirstHalf = true
    end

    if free == -1 then
        flag = isFree
    elseif free == 0 then 
        flag = isHalf
    elseif free == 1 then
        flag = isFirstHalf
    end
    return flag
end

function TeamModel:isCardFree()
    return self:getFlashCardTimes(-1)
end

function TeamModel:isCardHalf()
    return self:getFlashCardTimes(0)
end

function TeamModel:isFirstCardHalf()
    return self:getFlashCardTimes(1)
end

function TeamModel:getBigStar()
    return self._bigStar
end

function TeamModel:setBigStar(isBigStar)
    self._bigStar = isBigStar
end

------------------------------------------------------------------
-- 兵团天赋处理
function TeamModel:getSkillLevelAndScore(teamData)
    local tScore = tonumber(teamData.tScore) or 0
    local tmScore = tonumber(teamData.tmScore) or 0
    local level = 1
    local maxlevel = 1
    local tpScore = 0
    if not tScore then
        return level, tpScore
    end
    local talentSkill = tab:Setting("G_TEAM_TALENTSKILL").value
    local talentScore = tab:Setting("G_TEAM_TALENTSKILL_TUJIAN_SCORE").value
    for k,v in ipairs(talentSkill) do
        if tScore >= v then
            level = k
        else
            break
        end
    end
    for k,v in ipairs(talentSkill) do
        if tmScore >= v then
            maxlevel = k
        else
            break
        end
    end
    if talentScore[maxlevel] then
        tpScore = talentScore[maxlevel]
    end
    return level, tpScore, maxlevel
end

-----------------------------------------------------------------------------------
-- TeamBoost 兵团技巧数据处理

function TeamModel:getBoostTeamData(teamId)
    local tempTeam = {}
    for k,v in pairs(clone(self:getAllTeamData())) do
        v.sortId = 2
        if teamId == v.teamId then
            v.sortId = 1
        end
        if v.isInFormation == true then
            v.isInFormation = 1
        else
            v.isInFormation = 2
        end
        if v.stage and v.stage >= 6 then
            table.insert(tempTeam, v)
        end
    end

    local sortFunc = function(a, b)
        local asortId = a.sortId
        local bsortId = b.sortId
        local aScore = a.score
        local bScore = b.score
        local aisInFormation = a.isInFormation
        local bisInFormation = b.isInFormation
        if asortId ~= bsortId then
            return asortId < bsortId
        elseif aisInFormation ~= bisInFormation then
            return aisInFormation < bisInFormation
        elseif aScore ~= bScore then
            return aScore > bScore
        end
    end

    table.sort(tempTeam, sortFunc)

    return tempTeam
end

function TeamModel:getBoostAllTeamData()
    local tempTeam = {}
    local sysTeam
    local formationModel = self._modelMgr:getModel("FormationModel")
    local tempTeamLoad, backupLoadMap = formationModel:getTeamLoadedMap()
    for k,v in pairs(self:getData()) do
        v.isInFormation = tempTeamLoad[v.teamId]
        v.isInBackup = backupLoadMap[v.teamId]
        v.showType = 1
        table.insert(tempTeam, v)
    end
    local tempGetTeam = self:getCanGatTeams()
    for i=#tempGetTeam, 1 ,-1 do
        local team = tempGetTeam[i]
        table.insert(tempTeam, 1, team)
    end
    
    return tempTeam
end

-- 获取兵团养成Id
function TeamModel:getBoostTeamId()
    local teamId = SystemUtils.loadAccountLocalData("TEAMBOOST_teamId")
    if not teamId then
        teamId = self:getData()[1].teamId 
    end
    return teamId
end

function TeamModel:setBoostTeamId(teamId)
    local tempTeamId = SystemUtils.loadAccountLocalData("TEAMBOOST_teamId")
    if tempTeamId ~= teamId then
        SystemUtils.saveAccountLocalData("TEAMBOOST_teamId", teamId)
    end
end

-- 技巧红点提示
function TeamModel:isTeamBoostTip()
    local userModel = self._modelMgr:getModel("UserModel")
    local userdata = userModel:getData()
    local flag = false
    local userlvl = userdata.lvl
    if userlvl < tab.systemOpen["TeamBoost"][1] then
        return false
    end
    for k,v in pairs(self:getBoostTeamData()) do
        if v.isInFormation == 1 then
            if v.onBoost == true then
                flag = true
                break
            end
        end
    end

    if flag == true then
        local tempTimesNum, nextTimes = self:getBoostTimes()
        if (userdata["tbNum"]+tempTimesNum) <= 0 then
            flag = false
        end
    end
    return flag
end

-- 技巧次数
function TeamModel:getBoostTimes()
    local userModel = self._modelMgr:getModel("UserModel")
    local userdata = userModel:getData()
    local currentTime = userModel:getCurServerTime()

    local maxTimes = tab:Setting("G_TECHNIQUE_NUM_MAX").value
    local timeAdd = tab:Setting("G_TECHNIQUE_NUM_ADD").value

    local tempTime = timeAdd*60
    if not userdata["upTbTime"] then
        userdata["upTbTime"] = currentTime
        userdata["tbNum"] = maxTimes
    end
    local times = currentTime - userdata["upTbTime"]
    local tempTimesNum = math.floor(times/tempTime)
    local nextTimes = userdata["upTbTime"] + tempTime*(tempTimesNum+1)

    return tempTimesNum, nextTimes
end

-- 技巧次数
function TeamModel:getBoostTimesNum()
    local timesNum = 0
    local userModel = self._modelMgr:getModel("UserModel")
    local userdata = userModel:getData()
    local tempTimesNum, nextTimes = self:getBoostTimes()
    timesNum = userdata["tbNum"]+tempTimesNum
    return timesNum
end


-- 计算技巧属性
function TeamModel:getTeamBoostData(teamData)
    local boostD = teamData.tb
    local highAttrLock = tab:Setting("G_TECHNIQUE_UNLOCK").value
    local minLvStage = 9
    if boostD and table.nums(boostD) > 0 then
        local techniqueD, lvStage
        for k, v in pairs(boostD) do
            lvStage = 0
            for i=9,1,-1 do
                if v >= highAttrLock[i] then
                    lvStage = i
                    break
                end
            end
            if lvStage < minLvStage then
                minLvStage = lvStage
            end
        end
        if table.nums(boostD) < 4 then
            minLvStage = 0
        end
    else
        minLvStage = 0
    end
    if teamData.stage < 6 then
        minLvStage = 0
    end
    return minLvStage + 1
end

-- 兵团评论弹出弹板
function TeamModel:getTeamCommentFristShow(teamId)
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local timeDate = timeDate
    local tempdate = SystemUtils.loadAccountLocalData("TEAM_COMMENT_time")
    if tempdate ~= timeDate then
        return true
    end
    return false
end

function TeamModel:saveTeamCommentFristShow(teamId)
    local userModel = self._modelMgr:getModel("UserModel")
    local curServerTime = userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("TEAM_COMMENT_time")
    if tempdate ~= timeDate then
        SystemUtils.saveAccountLocalData("TEAM_COMMENT_time", timeDate)
    end
end

-- 给排行榜获取属性
function TeamModel:getOtherTeamTreasureAttrData(teamId, treasureData)
    if not teamId then
        teamId = 101
    end
    local teamD = tab:Team(teamId)
    local movetype = teamD.movetype
    local class = teamD.class
    local volume = teamD.volume - 1
    if volume > 4 then
        volume = 4
    end
    if volume < 1 then
        volume = 1
    end
    local label1 = teamD.label1

    local monsterAttr, monsterAttr1 = self:getTreasureAttrData(treasureData)

    local attr = monsterAttr[movetype][class][volume]
    -- print(movetype, class, volume, label1)

    local tattr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        tattr[n] = attr[n]
    end

    if monsterAttr1[label1] then
        local labelAttr = monsterAttr1[label1]
        for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
            tattr[n] = tattr[n] + labelAttr[n]
        end
    end
    -- dump(tattr)
    return tattr
end


function TeamModel:getOtherTeamHeroAttrByTeamId(teamId, heroData)
    local heroAttr = self:getOtherTeamHeroSkillAttrByTeamId(teamId, heroData)
    local heroAttr1 = self:getOtherTeamHeroAttrData(teamId, heroData)
    local tAttr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        tAttr[n] = heroAttr[n] + heroAttr1[n]
    end
    return tAttr
end

-- 获取英雄对单独的兵团加成的属性
function TeamModel:getOtherTeamHeroSkillAttrByTeamId(teamId, heroData)
    if not teamId then
        teamId = 101
    end
    local skillAttr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        skillAttr[n] = 0
    end

    local cradskSkill = self:getTeamHeroSkill(heroData)
    for i=1,#cradskSkill do
        local cradsk = cradskSkill[i]
        local _cradsk1 = cradsk[1]
        local _cradsk2 = cradsk[2]
        local _cradsk3 = cradsk[3]
        if teamId == _cradsk1 then
            local passive = tab.skillPassive[_cradsk3]
            local attr = passive.attr 
            for i=1,#attr do
                local _attr = attr[i]
                local _addattr1 = _attr[1]
                local _addattr2 = _attr[2]
                local _addattr3 = _attr[3]
                skillAttr[_addattr1] = skillAttr[_addattr1] + _addattr2
            end
        end
    end
    return skillAttr
end


function TeamModel:getOtherTeamHeroAttrData(teamId, heroData)
    if not teamId then
        teamId = 101
    end
    local teamD = tab:Team(teamId)
    local movetype = teamD.movetype
    local class = teamD.class
    local volume = teamD.volume - 1
    if volume > 4 then
        volume = 4
    end
    if volume < 1 then
        volume = 1
    end
    local label1 = teamD.label1

    local monsterAttr, monsterAttr1 = self:getHeroAttrData(heroData)
    local attr = monsterAttr[movetype][class][volume]
    -- print(movetype, class, volume, label1)

    local tattr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        tattr[n] = attr[n]
    end

    if monsterAttr1[label1] then
        local labelAttr = monsterAttr1[label1]
        for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
            tattr[n] = tattr[n] + labelAttr[n]
        end
    end
    -- dump(tattr)
    return tattr
end

function TeamModel:getOtherTeamTreasure(volume, treasureData)
    if not volume then
        volume = 3
    end
    local teamTreasure = BattleUtils.getTeamBaseAttr_treasure(treasureData)
    local treasureData = {}
    -- tab.team(teamId)
    if volume == 16 then
        treasureData = teamTreasure[1]
    elseif volume == 9 then
        treasureData = teamTreasure[2]
    elseif volume == 4 then
        treasureData = teamTreasure[3]
    elseif volume == 1 then
        treasureData = teamTreasure[4]
    else
        treasureData= teamTreasure[1]
    end
    return treasureData
end

-- state
function TeamModel:getTeamAwakingState(teamData)
    if not teamData then
        return 1
    end
    local state = 1 -- 无动画
    -- local teamData = self:getTeamAndIndexById(teamId)
    local ast = teamData.ast
    local awakingTeamId = self._modelMgr:getModel("AwakingModel"):getCurrentAwakingTeamId()
    local stage = teamData.stage 
    local awakingOpen = tab:Setting("AWAKINGOPEN").value or 0
    if (not ast) or ast == 0 then -- 开启觉醒 动画1
        if (awakingTeamId == 0) and (stage >= awakingOpen) then
            state = 2
        end
    elseif ast and ast == 1 then -- 跳转到任务  动画2
        state = 3
    elseif ast and ast == 2 then -- 可觉醒动画  动画3
        state = 4
    elseif ast and ast == 3 then
        state = 5
    end
    return state
end

-- 获取觉醒兵团
function TeamModel:getAllAwakingTeam()
    local teamsData = {}
    for k,v in pairs(self._data) do
        if v.ast and v.ast == 3 then
            table.insert(teamsData, v)
        end
    end
    return teamsData
end 

-- 
function TeamModel:isTeamLockWeapons(data)
    local flag = 0
    local teamId = data[1]
    local teamStar = data[2]
    local teamStage = data[3]
    local teamData = self:getTeamAndIndexById(teamId)

    if teamData then
        flag = 1
        local _teamStar = teamData.star
        local _teamStage = teamData.stage
        if _teamStar >= teamStar and _teamStage >= teamStage then
            flag = 2
        end
    end
    return flag
end


-- guofang 12.13 嘉年华用
-- 统计兵团天赋等级
function TeamModel:getTeamTalentNum(teamClass, talentLv)
    local teamNum = 0
    if not talentLv then
        talentLv = 1
    end
    local teamData = {}
    if teamClass then
        teamData = self:getClassTeam(teamClass)
    end
    for k,v in pairs(teamData) do
        local _, _, maxLvl = self:getSkillLevelAndScore(v)
        if maxLvl >= talentLv then
            teamNum = teamNum + 1
        end
    end
    
    return teamNum
end

function TeamModel:getTeamSkillMaxLevel(teamRace, skillLv)
    local teamNum = 0
    local teamData = {}
    if not teamRace then
        teamRace = 101
    end
    if not skillLv then
        skillLv = 1
    end
    if teamRace then
        teamData = self:getTeamWithRace(teamRace)
    end
    for k,v in pairs(teamData) do
        local skLv = v.sl1
        if skLv and skLv >= skillLv then
            teamNum = teamNum + 1
        end
    end
    return teamNum
end

--------------------------------------------------------------------------------
-- "runes" : {    符文背包
--         "1" : {    格子id
--             "id" : 10101,   符文id
--             "p" : "[[2,10],[4,1000],[4,1000],[1,100]]",  增加的属性
--             "b" : 106   被哪个兵团装备
--         }
--     }
--   "106" : {
--             "level" : 90,
--             "tmScore" : 14129,
--             "ast" : 1,
--             "rune" : {   符文
--                 "1" : 3,  第一个槽装备背包中的第3个符文  
--                 "2" : 7,  第二个槽装备背包中的第7个符文  
--                 "s" : 0   符文战力
--             }
--         },

-- 符文宝石接口
---------------
function TeamModel:setHolyData(data)
    local backData, holyData = self:processHolyData(data)
    self._holyData = backData
    self._tabHolyData = holyData or {}
    self:processSuitData()
    -- self:progressTeamUseHolyData()
end

function TeamModel:processHolyData(data)
    local backData = {}
    local holyData = {}
    local suitData = {}
    for k,v in pairs(data) do
        local indexId = tonumber(k)
        local runeId = v.id 
        local runeTab = tab:Rune(runeId)
        v.quality = runeTab.quality 
        v.jackType = runeTab.type  
        v.make = runeTab.make
        v.p = json.decode(v.p)
        v.key = indexId
        backData[indexId] = v
    end
    for k,v in pairs(data) do
        local indexId = tonumber(k)
        if backData[indexId] then
            table.insert(holyData, backData[indexId])
        end
        local make = v.make
        if suitData[make] then
            table.insert(suitData[make], v.key)
        else
            suitData[make] = {}
            table.insert(suitData[make], v.key)
        end
    end

    self._suitData = suitData
    return backData, holyData
end


function TeamModel:processSuitData()
    local suitData = self._suitData
    local tabSuitData = {}
    for k,v in pairs(suitData) do
        for k1,v1 in pairs(v) do
            if not self._holyData[v1] then
                table.remove(v, k1)
            end
        end
        table.insert(tabSuitData, k)
    end
    local sortFunc = function(a, b)
        if a ~= b then
            return a < b
        end
    end
    table.sort(tabSuitData, sortFunc)
    self._tabSuitData = tabSuitData
end

-- 更新宝石数据
function TeamModel:updateHolyData(data)
    local backData = self._holyData
    local holyData = self._tabHolyData or {}
    local suitData = self._suitData or {}
    for k,v in pairs(data) do
        local indexId = tonumber(k)
        local _holyData = backData[indexId]
        if _holyData then
            for pkey,pvalue in pairs(v) do
                if pkey == "p" then
                    _holyData[pkey] = json.decode(pvalue)
                else
                    _holyData[pkey] = pvalue
                end
            end
        else
            local runeId = v.id 
            local runeTab = tab:Rune(runeId)
            v.quality = runeTab.quality 
            v.jackType = runeTab.type  
            v.make = runeTab.make
            v.p = json.decode(v.p)
            v.key = indexId 
            backData[indexId] = v
            table.insert(holyData, v)

            local make = v.make
            if suitData[make] then
                table.insert(suitData[make], v.key)
            else
                suitData[make] = {}
                table.insert(suitData[make], v.key)
            end
        end
    end

    self:processSuitData()
end


-- 分解配件
function TeamModel:removeHoly(inHoly)
    if not inHoly then
        return
    end

    local backData = self._holyData
    local tabHolyData = self._tabHolyData or {}
    for k,v in pairs(inHoly) do
        backData[v] = nil
        local tempIndex = 0
        for k1,v1 in pairs(tabHolyData) do
            if v1.key == tonumber(v) then 
                tempIndex = k1
                break
            end
        end
        if tempIndex > 0 then
            table.remove(tabHolyData, tempIndex)
        end
    end
    self:processSuitData()
    self:reflashData()
end

function TeamModel:handelUnsetHoly(inData)
    local tempData = {}
    for k,v in pairs(inData) do
        if string.find(k, ".") ~= nil then
            local temp = string.split(k, "%.")
            if #temp >= 2 then
                table.insert(tempData,tonumber(temp[2]))
            end
        end
    end
    return tempData
end

function TeamModel:progressTeamUseHolyData()
    local useHoly = {}
    for k,v in pairs(self._data) do
        local rune = v.rune
        if rune then
            for i=1,6 do
                local indexId = tostring(i)
                local runeKey = rune[indexId]
                if runeKey and runeKey ~= 0 then
                    useHoly[runeKey] = v.teamId
                end
            end
        end
    end
    self._useHoly = useHoly
end

function TeamModel:proprsssAllSuitData()
    local suitData = {}
    local suitTab = tab.runeClient

    for k,v in pairs(suitTab) do
        suitData[k] = {}
        -- suitData[k].list = {}
        -- suitData[k].num = 0
        suitData[k].key = k
        suitData[k].jackType = v.type 
    end
    local sortFunc = function(a, b)
        if a ~= b then
            return a < b
        end
    end
    table.sort(suitData, sortFunc)
    self._allSuitData = suitData
end


-- 对外接口
function TeamModel:getHolyData()
    return self._holyData or {}
end

function TeamModel:getHolyDataByKey(holyId)
    return self._holyData[holyId] or {}
end

function TeamModel:getTabHolyData()
    return self._tabHolyData or {}
end

function TeamModel:getSuitData()
    return self._suitData or {}
end

function TeamModel:getSuitDataById(suitId)
    return self._suitData[suitId] or {}
end

function TeamModel:getShowHolyData(suitId)
    local backData = {}
    local suitData = self:getSuitDataById(suitId)
    local useHoly = self._useHoly
    for k,v in pairs(suitData) do
        if not useHoly[v] then
            table.insert(backData, self:getHolyDataByKey(v))
        end
    end
    return backData or {}
end

function TeamModel:getTabSuitData()
    return self._tabSuitData or {}
end

function TeamModel:getAllSuitData()
    if not self._allSuitData then
        self:proprsssAllSuitData()
    end
    return self._allSuitData or {}
end

-- function TeamModel:progressAllSuitData()
--     local allSuitData = self:getAllSuitData()
--     local noUseSuit = {}
--     local noUseSuitNum = {}
--     for k,v in pairs(allSuitData) do
--         noUseSuit[v] = {}
--         noUseSuitNum[v] = 0
--     end

--     local holyData = self:getHolyData()-- 宝石
--     local useHoly = self:getTeamUseHolyData()-- 使用的宝石
--     for k,v in pairs(holyData) do
--         if not useHoly[v.key] then
--             table.insert(noUseSuit[v.make], v)
--         end
--     end

--     for k,v in pairs(noUseSuitNum) do
--         local suitData = noUseSuit[k]
--         noUseSuitNum[k] = table.nums(suitData)
--     end
--     self._noUseSuit = noUseSuit
--     self._noUseSuitNum = noUseSuitNum
-- end

function TeamModel:getTeamUseHolyData()
    return self._useHoly or {}
end

function TeamModel:getHolyBreakData(_type)
    local _type = _type
    local holyData = self:getHolyData()
    local useHolyData = self:getTeamUseHolyData()
    local backData = {}
    for k,v in pairs(holyData) do
        local key = v.key
        if _type and _type == v.jackType then
            if not useHolyData[key] then
                table.insert(backData, v)
            end
        elseif not _type then
            if not useHolyData[key] then
                table.insert(backData, v)
            end
        end
    end
    local sortFunc = function(a, b)
        local aquality = a.quality
        local bquality = b.quality
        local aid = a.id
        local bid = b.id
        local akey = a.key
        local bkey = b.key
        if aquality ~= bquality then
            return aquality < bquality
        elseif aid ~= bid then
            return aid < bid
        elseif akey ~= bkey then
            return akey < bkey
        end
    end

    table.sort(backData, sortFunc)
    return backData
end

function TeamModel:getStoneType(teamId, stonePos)
    local teamTab = tab:Team(teamId)
    local _race = teamTab["race"][1]
    local raceTab = tab:Race(_race)
    local fixdeTtpe = clone(raceTab.fixdeTtpe)
    if stonePos > 2 then
        fixdeTtpe = clone(raceTab.freeTtpe)
    end
    return fixdeTtpe
end 

-- 根据类型获取显示套装
function TeamModel:getShowSuitData(fixdeTtpe)
    local backData1 = {}
	local backData2 = {}
    local suitData = self:getAllSuitData()
    for k,v in pairs(suitData) do
        if table.indexof(fixdeTtpe, v.jackType) then
            local holyData = self:getShowHolyData(k)
            v.num = table.nums(holyData)
			if v.num>0 then
				table.insert(backData1, v)
			else
				table.insert(backData2, v)
			end
        end
    end
	
    return backData1, backData2
end 


function TeamModel:getTeamSuitById(teamData)
    if not teamData then
        return 
    end
    local suitData = self:getSuitDataByTeam(teamData)
    local backData = {}
    local effectTab = tab:Setting("GEM_EFFECT_NUM").value
    for k,v in pairs(suitData) do
        local sortFunc = function(a, b)
            local aquality = a.quality
            local bquality = b.quality
            local aid = a.id
            local bid = b.id
            local akey = a.key
            local bkey = b.key
            if aquality ~= bquality then
                return aquality > bquality
            elseif aid ~= bid then
                return aid < bid
            elseif akey ~= bkey then
                return akey < bkey
            end
        end
        table.sort(v, sortFunc)

        local _suitData = {}
        local strNum = table.nums(v)
        if table.nums(v) >= effectTab[3] then
			_suitData = {
				[1] = {suitNum = 2, stoneId = v[2].id},
				[2] = {suitNum = 4, stoneId = v[4].id},
				[3] = {suitNum = 6, stoneId = v[6].id}
			}
        elseif table.nums(v) >= effectTab[2] then
			_suitData = {
				[1] = {suitNum = 2, stoneId = v[2].id},
				[2] = {suitNum = 4, stoneId = v[4].id},
			}
        elseif table.nums(v) >= effectTab[1] then
			_suitData = {
				[1] = {suitNum = 2, stoneId = v[2].id},
			}
        end
        backData[k] = _suitData
    end
    return backData
end 

function TeamModel:getSuitDataByTeam(teamData)
    if not teamData then
        return
    end
    local rune = teamData.rune or {}
    local suitData = {}
    for i=1,6 do
        local indexId = tostring(i)
        if rune and rune[indexId] and rune[indexId] ~= 0 then
            local stoneKey = rune[indexId]
            local stoneData = self:getHolyDataByKey(stoneKey)
            local stoneId = stoneData.id
            local make = stoneData.make
            if not suitData[make] then
                suitData[make] = {}
            end
            table.insert(suitData[make], stoneData)
        end
    end
    return suitData
end


-- 获取他人套装信息
--[[
--! @function getTeamSuitByDataAndParam
--! @desc 获取兵团套装
--! @param  teamData 兵团信息（装备圣徽）  runes 处理后的数据
--! @return 
--]]
function TeamModel:getTeamSuitByDataAndParam(teamData,holyData)
    if not teamData then
        return 
    end
    local suitData = self:getSuitDataByTeamAndParam(teamData,holyData)
    local backData = {}
    local effectTab = tab:Setting("GEM_EFFECT_NUM").value
    for k,v in pairs(suitData) do
        local sortFunc = function(a, b)
            local aquality = a.quality
            local bquality = b.quality
            local aid = a.id
            local bid = b.id
            local akey = a.key
            local bkey = b.key
            if aquality ~= bquality then
                return aquality > bquality
            elseif aid ~= bid then
                return aid < bid
            elseif akey ~= bkey then
                return akey < bkey
            end
        end
        table.sort(v, sortFunc)

        local _suitData = {}
        local strNum = table.nums(v)
        if table.nums(v) >= effectTab[3] then
            _suitData = {
                [1] = {suitNum = 2, stoneId = v[2].id},
                [2] = {suitNum = 4, stoneId = v[4].id},
                [3] = {suitNum = 6, stoneId = v[6].id}
            }
        elseif table.nums(v) >= effectTab[2] then
            _suitData = {
                [1] = {suitNum = 2, stoneId = v[2].id},
                [2] = {suitNum = 4, stoneId = v[4].id},
            }
        elseif table.nums(v) >= effectTab[1] then
            _suitData = {
                [1] = {suitNum = 2, stoneId = v[2].id},
            }
        end
        backData[k] = _suitData
    end
    return backData
end 

function TeamModel:getSuitDataByTeamAndParam(teamData,holyData)
    if not teamData then
        return
    end
    local rune = teamData.rune or {}
    local suitData = {}
    -- dump(holyData,"holyData==>",5)
    -- dump(rune,"rune====>",5)
    for i=1,6 do
        local indexId = tostring(i)
        -- print("==========indexId===",indexId)
        if rune and rune[indexId] and rune[indexId] ~= 0 then
            local stoneKey = rune[indexId]
            local stoneData = holyData[tonumber(stoneKey)]
            local stoneId = stoneData.id
            local make = stoneData.make
            if not suitData[make] then
                suitData[make] = {}
            end
            table.insert(suitData[make], stoneData)
        end
    end
    return suitData
end

function TeamModel:getStoneAttr(rune)
    local baseAttr = {}
	local addAttr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        baseAttr[n] = 0
		addAttr[n] = 0
    end
    if not rune then
        return baseAttr, addAttr
    end
	local baseNum = tab:Setting("GEM_BASISATT_NUM").value
    if rune then
        for i=1,6 do
            local indexId = tostring(i)
            local stoneId = rune[indexId]
            if stoneId and stoneId ~= 0 then
                local stoneData = self:getHolyDataByKey(stoneId)
                for k,v in ipairs(stoneData.p) do
                    local attrId = v[1]
                    local attrValue = v[2]
					if k<=baseNum then
						baseAttr[attrId] = baseAttr[attrId] + attrValue
					else
						addAttr[attrId] = addAttr[attrId] + attrValue
					end
                end
            end
        end
    end 

    return baseAttr, addAttr
end

function TeamModel:getBagStoneAttr(stoneData)
	local baseAttr = {}
	local addAttr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        baseAttr[n] = {value = 0}
		addAttr[n] = {value = 0}
    end
	if not stoneData then
		return baseAttr, addAttr
	end
	local baseNum = tab:Setting("GEM_BASISATT_NUM").value
	for k,v in ipairs(stoneData.p) do
		local attrId = v[1]
		local attrValue = v[2]
		if k<=baseNum then
			baseAttr[attrId] = {index = k, value = baseAttr[attrId].value + attrValue}
		else
			addAttr[attrId] = {index = k, value = addAttr[attrId].value + attrValue}
		end
	end
	return baseAttr, addAttr
end

-- -- 根据类型获取显示套装
-- function TeamModel:getHolyDataByType(fixdeTtpe)
--     local backData = {}
--     local holyData = self:getHolyData()
--     for k,v in pairs(holyData) do
--         if table.indexof(fixdeTtpe, v.jackType) then
--             local holyData = self:getShowHolyData(k)
--             v.num = table.nums(holyData)
--             table.insert(backData, v)
--         end
--     end
--     local sortFunc = function(a, b)
--         local akey = a.key
--         local bkey = b.key
--         local anum = a.num
--         local bnum = b.num
--         if anum ~= bnum then
--             return anum > bnum
--         elseif akey ~= bkey then
--             return akey < bkey
--         end
--     end
--     table.sort(backData, sortFunc)
--     return backData
-- end 

-- --- 铸造和觉醒
-- -- 没有已装备的所有宝石
-- function TeamModel:getHolyDataNoUse()
--     local backData = {}
--     local holyData = self:getHolyData()
--     local useHolyData = self:getTeamUseHolyData()
--     for k,v in pairs(holyData) do
--         if not useHolyData[v.key] then
--             table.insert(backData, v)
--         end
--     end
--     local sortFunc = function(a, b)
--         local akey = a.key
--         local bkey = b.key
--         if akey ~= bkey then
--             return akey < bkey
--         end
--     end
--     table.sort(backData, sortFunc)
--     return backData
-- end 

-- 获取消耗的材料
function TeamModel:getStuffData(holyKey, fixdeTtpe)
    if not holyKey then
        return {}
    end
    local tholyData = self:getHolyDataByKey(holyKey)
    local holyTab = tab:Rune(tholyData.id)
    local castData = holyTab.castData

    local backData = {}
    local holyData = self:getHolyData()
    local useHolyData = self:getTeamUseHolyData()
    for k,v in pairs(holyData) do
        if holyKey ~= v.key and (not useHolyData[v.key]) then
            if table.indexof(castData, v.id) then
                table.insert(backData, v)
            end
        end
    end
    local sortFunc = function(a, b)
        local akey = a.key
        local bkey = b.key
        if akey ~= bkey then
            return akey < bkey
        end
    end
    table.sort(backData, sortFunc)
    return backData
end 


-- -- 没有已装备的宝石
-- function TeamModel:getHolyDataByType(fixdeTtpe)
--     local backData = {}
--     local holyData = self:getHolyData()
--     local useHolyData = self:getTeamUseHolyData()
--     for k,v in pairs(holyData) do
--         if v.jackType == fixdeTtpe then
--             if not useHolyData[v.key] then
--                 table.insert(backData, v)
--             end
--         elseif not fixdeTtpe then
--             if not useHolyData[v.key] then
--                 table.insert(backData, v)
--             end
--         end
--     end
--     local sortFunc = function(a, b)
--         local akey = a.key
--         local bkey = b.key
--         if akey ~= bkey then
--             return akey < bkey
--         end
--     end
--     table.sort(backData, sortFunc)
--     return backData
-- end 

-- 所有宝石
function TeamModel:getHolyDataAllByType(fixdeTtpe, noUse)
    local backData = {}
    local holyData = self:getHolyData()
    local useHolyData = self:getTeamUseHolyData()
    for k,v in pairs(holyData) do
        if v.jackType == fixdeTtpe then
            if useHolyData[v.key] then
                v.use = 1
            else
                v.use = 0
            end
			if not noUse then
				table.insert(backData, v)
			elseif v.use==0 then
				table.insert(backData, v)
			end
        elseif not fixdeTtpe then
            if useHolyData[v.key] then
                v.use = 1
            else
                v.use = 0
            end
			if not noUse then
				table.insert(backData, v)
			elseif v.use==0 then
				table.insert(backData, v)
			end
        end
    end
    local sortFunc = function(a, b)
        local akey = a.key
        local bkey = b.key
        local ause = a.use
        local buse = b.use
        local aquality = a.quality
        local bquality = b.quality
        if ause ~= buse then
            return ause > buse
        elseif aquality ~= bquality then
            return aquality > bquality
        elseif akey ~= bkey then
            return akey < bkey
        end
    end
    table.sort(backData, sortFunc)
    return backData
end 

-- 可觉醒宝石
function TeamModel:getAwakingData(fixdeTtpe)
    local backData = {}
    local holyData = self:getHolyData()
    local useHolyData = self:getTeamUseHolyData()
    for k,v in pairs(holyData) do
        local holyTab = tab:Rune(v.id)
        if holyTab.awakeId then
            if v.jackType == fixdeTtpe then
                if useHolyData[v.key] then
                    v.use = 1
                else
                    v.use = 0
                end
                table.insert(backData, v)
            elseif not fixdeTtpe then
                if useHolyData[v.key] then
                    v.use = 1
                else
                    v.use = 0
                end
                table.insert(backData, v)
            end
        end
    end
    local sortFunc = function(a, b)
        local akey = a.key
        local bkey = b.key
        local ause = a.use
        local buse = b.use
        if ause ~= buse then
            return ause > buse
        elseif akey ~= bkey then
            return akey < bkey
        end
    end
    table.sort(backData, sortFunc)
    return backData
end

function TeamModel:getGradeBagData(holyData)
	local castHolyIds = tab.rune[holyData.id].castData
	local selectHolyIds = {}
	for i,v in ipairs(castHolyIds) do
		selectHolyIds[v] = true
	end
	local backData = {}
	local bagData = self:getHolyData()
	for i,v in pairs(bagData) do
		if selectHolyIds[v.id] and v.key~=holyData.key and v.use==0 then
			table.insert(backData, v)
		end
	end
	table.sort(backData, function(a, b)
		if a.quality>b.quality then
			return true
		else
			return a.lv>b.lv
		end
	end)
	return backData
end

function TeamModel:getRunesById(holyId)--获取同id的圣徽及数量
	local backData = {}
	for i,v in pairs(self._holyData) do
		if v.id==holyId then
			table.insert(backData, v)
		end
	end
	return backData, table.nums(backData)
end

function TeamModel:getHolyMasterLevel(teamId)
	local teamData = self:getTeamAndIndexById(teamId)
	local lv = 0
	if teamData and teamData.rune then
		local runeData = teamData.rune
		for i=1, 6 do
			local key = runeData[tostring(i)]
			if key and key~=0 then
				local stoneData = self:getHolyDataByKey(key)
				lv = lv + stoneData.lv-1
			end
		end
	end
	return lv
end

function TeamModel:getHolyMasterAttr(teamId)
	local masterAttr = {}
	local lv = self:getHolyMasterLevel(teamId)
	for i,v in ipairs(tab.runeCastingMastery) do
		if lv<v.level then
			if i~=1 then
				masterAttr = tab.runeCastingMastery[i-1].castingMastery
				break
			else
				break
			end
		elseif lv==v.level then
			masterAttr = tab.runeCastingMastery[i].castingMastery
			break
		elseif lv>v.level and i==table.nums(tab.runeCastingMastery) then
			masterAttr = tab.runeCastingMastery[i].castingMastery
			break
		end
	end
	return masterAttr
end

-- 
--[[
--! @function getStoneAttrByParam
--! @desc 查看详情 , 计算圣徽属性  by hgf
--! @param  rune 装备圣徽  runes 仓库里已有圣徽
--! @return 
--]]
function TeamModel:getStoneAttrByParam(rune,runes)
    local baseAttr = {}
    local addAttr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        baseAttr[n] = 0
        addAttr[n] = 0
    end
    if not rune then
        return baseAttr, addAttr
    end

    local baseNum = tab:Setting("GEM_BASISATT_NUM").value
    if rune then
        for i=1,6 do
            local indexId = tostring(i)
            local stoneId = rune[indexId]
            if stoneId and stoneId ~= 0 then
                local stoneData = runes[tostring(stoneId)] or runes[stoneId]
                local propertyData = stoneData.p or {}
                if stoneData.p and type(stoneData.p) == "string" then
                    propertyData = json.decode(stoneData.p)
                end
                for k,v in ipairs(propertyData) do
                    local attrId = v[1]
                    local attrValue = v[2]
                    if k<=baseNum then
                        baseAttr[attrId] = baseAttr[attrId] + attrValue
                    else
                        addAttr[attrId] = addAttr[attrId] + attrValue
                    end
                end
            end
        end
    end 

    return baseAttr, addAttr
end


function TeamModel:getHolyTabBySuitIdAndQuality(suitId, quality)
	local tabData = nil
	for i,v in pairs(tab.rune) do
		if v.make==suitId and v.quality==quality then
			tabData = v
			break
		end
	end
	return tabData
end

function TeamModel:isShowHolyRedPoint()
	local data = self:getData()
	local isShow = false
	
	local function getFixBagData(fixdeTtpe)
		local fixBagData = {}
		for i,v in ipairs(fixdeTtpe) do
			local bagData = self:getHolyDataAllByType(v, true)
			for _, holy in ipairs(bagData) do
				table.insert(fixBagData, holy)
			end
		end
		return fixBagData
	end
	
	for i,v in ipairs(data) do
		if v.isInFormation then
			if not v.rune then
				v.rune = {}
			end
			for stoneIndex=1,6 do
				if v.rune[tostring(stoneIndex)]==nil or v.rune[tostring(stoneIndex)]==0 then
					local fixdeTtpe = self:getStoneType(v.teamId, stoneIndex)
					local fixBagData = getFixBagData(fixdeTtpe)
					if table.nums(fixBagData)>0 then
						isShow = true
						break
					end
				end
			end
			if isShow then
				break
			end
		end
	end
	return isShow
end

function TeamModel:getTeamHolyInlayCountBySuitId(teamId, suitId)
	local teamData = self:getTeamAndIndexById(teamId)
	local count = 0
	if teamData.rune then
		local tbRune = teamData.rune
		for i=1, 6 do
			if teamData.rune[tostring(i)] and teamData.rune[tostring(i)]~=0 then
				local tempData = self._holyData[tbRune[tostring(i)]]
				if tempData.make==suitId then
					count = count + 1
				end
			end
		end
	end
	return count
end

function TeamModel:getHolyNumByLvlQuality(lvl, quality)
	if not lvl or not quality then
		return nil
	end
	local count = 0
	for i, v in pairs(self._holyData) do
		if v.lv >= lvl and v.quality == quality then
			count = count + 1
		end
	end
	return count
end

function TeamModel:updateTeamSkinId(teamId,id)
    if teamId == nil or id == nil then return end
    for k,v in pairs(self._data) do
        if tonumber(k) == tonumber(teamId) then
            v.sId = id
        end
    end
end
--检查兵团皮肤是否存在
function TeamModel:checkTeamSkin(teamId)
    if teamId == nil then return end
    local teamSkinTab = tab.teamSkin
    for i,v in pairs(teamSkinTab) do
        if v.teamid == teamId then
            return true
        end
    end
    
    return false
end

function TeamModel:getTeamDataById(teamId)
    for i,v in ipairs(self._data) do
        if v.teamId == teamId then
            return v
        end
    end
    return nil
end

function TeamModel:checkTeamRedSKillRedPoint(inData)
    if not inData or not inData["stage"] then
        return false
    end

    local quality = self:getTeamQualityByStage(inData["stage"])   --红色品质
    if quality[1] == 6 and not inData["ss"] then   --可解锁且没有选择特技
        return true
    end

    return false
end

-- 招募兵团后 手动初始化红色品质的特技数据
function TeamModel:initSKillRedDataById(inId)
    if not inId then
        return
    end

    local teamData = self:getTeamDataById(inId)
    if not teamData then
        return
    end

    if not teamData["sl5"] then teamData["sl5"] = -1 end
    if not teamData["sl6"] then teamData["sl6"] = -1 end
    if not teamData["sl7"] then teamData["sl7"] = -1 end
    if not teamData["se5"] then teamData["se5"] = 0 end
    if not teamData["se6"] then teamData["se6"] = 0 end
    if not teamData["se7"] then teamData["se7"] = 0 end
end

function TeamModel:getTeamSkillShowSort( teamData, isDetail )
    local res = {1, 2, 3, 4}
    if teamData == nil or teamData.teamId == nil then
        return res
    end
    local sysTeamData = tab:Team(teamData.teamId)

    -- 16资质兵团添加一个常规技能
    local skill = sysTeamData.skill or {}
    if sysTeamData.zizhi == 4 and #skill >= 7 then
        table.insert(res, 7)
    end
    if not isDetail then
        -- 红色兵团特技
        local specialSkillId = 5
        if teamData.ss then
            specialSkillId = teamData.ss
        end
        table.insert(res, specialSkillId)
    end

    return res
end


function TeamModel:getTeamZiZhiText( zizhi )
    zizhi = zizhi or 1
    if zizhi ~= 4 then
        return TeamConst.TEAM_ZIZHI_TYPE["ZIZHI_" .. zizhi]
    else
        return  "指挥官"
    end
end

-- 获取英雄皮肤属性
function TeamModel:getTeamSkinAttr(teamId)
    local attrs = {atk=0,hp=0}
    local changeMap = {[1] = "atk",[2] = "hp"}
    local skinData = tSkin or self._userModel:getTeamSkinData()
    local skinTb = tab.teamSkin
    local teamSkinData = skinData and skinData[tostring(teamId)] or nil
    if teamSkinData then
        for kk , vv in pairs(teamSkinData) do
            local tempData = skinTb[tonumber(kk)]
            if tempData and tempData.addteamAttr then
                for key,value in pairs(tempData.addteamAttr) do                    
                    local changeType = changeMap[tonumber(value[1])]
                    if changeType then
                        attrs[changeType] = attrs[changeType]+tonumber(value[2])
                    end
                end
            end
        end
    end
    -- for k,v in pairs(skinData) do
    --     for kk,vv in pairs(v) do
    --         local tempData = skinTb[tonumber(kk)]
    --         if tempData and tempData.addteamAttr then
    --             for key,value in pairs(tempData.addteamAttr) do                    
    --                 local changeType = changeMap[tonumber(value[1])]
    --                 if changeType then
    --                     attrs[changeType] = attrs[changeType]+tonumber(value[2])
    --                 end
    --             end
    --         end
    --     end
    -- end
    return attrs
end

return TeamModel
