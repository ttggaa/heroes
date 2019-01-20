--[[
    Filename:    PokedexModel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-09-28 14:51:57
    Description: File description
--]]

local PokedexModel = class("PokedexModel", BaseModel)

function PokedexModel:ctor()
    PokedexModel.super.ctor(self)
    self._data = {}
    self._score = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    self._level = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    self._checkScore = BattleUtils.checkPokedexScoreData(self._score)
    self:listenReflash("ItemModel", self.checkTips)
    -- self:listenReflash("TeamModel", self.processData)
end

function PokedexModel:setData(data)
    self._data = data
    
    self:processData()
    -- dump(self._data, "self._data ===============")  

    ModelManager:getInstance():getModel("ActivityModel"):pushUserEvent()
    
    self:reflashData()
end

function PokedexModel:getData()
    -- self:setPokedexSumScore()
    return self._data
end

function PokedexModel:setPFormation(data)
    if not self._pFormation then
        self._pFormation = {}
        self._pFormation["1"] = ""
    end
    for k,v in pairs(data) do
        self._pFormation[k] = v
    end
end

function PokedexModel:updatePFormation(data)
    for k,v in pairs(data) do
        self._pFormation[k] = v.name or ""
    end
end

function PokedexModel:getPFormation()
    if not self._pFormation then
        self._pFormation = {}
        self._pFormation["1"] = ""
    end
    return self._pFormation
end

function PokedexModel:checkData()
    if self._checkScore ~= BattleUtils.checkPokedexScoreData(self._score) then
        return self._score
    end
end

function PokedexModel:getScore()
    return self._score
end

function PokedexModel:getPokedexLevel()
    return self._level
end

function PokedexModel:getDataById(index)
    return self._data[tostring(index)]
end

-- function PokedexModel:getPokedexEffect(index)
--     local sumScore = 1
--     return 100
-- end

-- function PokedexModel:setPokedexSumScore(inData)
function PokedexModel:processData()
    -- dump(self._data, "self._data==============")
    local pingScore = 0
    local teamModel = self._modelMgr:getModel("TeamModel")
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local xishu =  tab:HeroPower(userlvl).tujian 
    for k,v in pairs(self._data) do
        if v.posList ~= nil then
            for k1,v1 in pairs(v.posList) do
                if v1 ~= 0 then
                    -- local teamdata = teamModel:getTeamAndIndexById(v1)
                    pingScore = pingScore + teamModel:getTeamPokedexScore(v1) -- teamModel:getTeamAddPingScore(teamdata)
                    -- pingScore = 0 -- pingScore + tab:Star(teamdata.star).score
                end
            end
            v.score = pingScore * (tab:Tujianshengji(v.level).effect * 0.01 + 1)
            pingScore = 0
            v.fight = xishu * v.score
        end
        local score = math.ceil(tonumber(string.format("%.2f", v.score)))
        self._score[tonumber(k)] = score
        self._level[tonumber(k)] = v.level
    end
    self._checkScore = BattleUtils.checkPokedexScoreData(self._score)
    self:checkTips()
end


function PokedexModel:getCheckScore()
    return self._checkScore
end

-- function PokedexModel:getTeamAddPingScore(teamD)
--     -- 评分=兵团星级*50+兵团小星总数*5+兵团等级*3+兵团阶*15+装备等级*1+装备阶*5+技能*8 
--     -- dump(teamD)
--     if not teamD.teamId then
--         return 0
--     end
--     local score = teamD.star*50 + teamD.smallStar*5 + teamD.level*3 + teamD.stage*15 + 200
--     for i=1,4 do
--         score = score + teamD["el" .. i]*1 + teamD["es" .. i]*5
--         if teamD["sl" .. i] > 0 then
--             score = score + teamD["sl" .. i]*8
--         end
--     end
--     return score
-- end

-- 判断怪兽是否在图鉴位上场
function PokedexModel:getPokedexShangzhen(index)
    local flag = false
    local key = 0 
    for k,v in pairs(self._data) do
        if v.posList ~= nil then
            for k1,v1 in pairs(v.posList) do
                if v1 ~= 0 and index == v1 then
                    flag = true
                    key = k
                    break
                end
            end
        end
    end
    return flag, key
end

-- function PokedexModel:getPokedexPos(index)
--     local flag = false
--     for k,v in pairs(self._data) do
--         if v.posList ~= nil then
--             for k1,v1 in pairs(v.posList) do
--                 if v1 ~= 0 and index == v1 then
--                     flag = true
--                     break
--                 end
--             end
--         end
--     end
--     return flag
-- end

function PokedexModel:updatePokedexData(inData)
    for k,v in pairs(inData) do
        if v.posList ~= nil then
            for k1,v1 in pairs(v.posList) do
                if not self._data[k] then
                    self._data[k] = {}
                end
                if not self._data[k]["posList"]  then
                    self._data[k]["posList"] = {}
                end
                self._data[k]["posList"][k1] = v1
            end
        end
        if v.level ~= nil then
            self._data[k]["level"] = v.level
        end
    end
    self:processData()
    self:reflashData()
end

function PokedexModel:checkTips()
    local flag = false
    local teamModel = self._modelMgr:getModel("TeamModel")
    teamModel:refreshDataOrder()
    teamModel:initGetSysTeams()
    for k,v in pairs(self._data) do
        local tujianTab = tab:Tujian(tonumber(k))
        if tujianTab then
            local pokedexTeamData = teamModel:getClassTeam(tujianTab.art)
            for k2,v2 in pairs(pokedexTeamData) do
                local pokedexFlag = self:getPokedexShangzhen(v2.teamId)
                if pokedexFlag ~= true then
                    for k1,v1 in pairs(v.posList) do
                        if v1 == 0 then
                            flag = true
                        end
                    end
                end
            end
            -- if flag == false then
            --     flag = self:checkCailiaoTips(tonumber(k), v.level)
            -- end
            -- print("==========", flag)
            v.onPokedex = flag
            v.onUpgrade = self:checkCailiaoTips(tonumber(k), v.level)
            flag = false
        end
    end
    self:reflashData()
    return flag
end

function PokedexModel:checkCailiaoTips(index, level)
    local flag = false
    local tLevel = level
    local levelUpLimit = tab:Tujian(index).levelUpLimit
    local maxLvl = table.nums(levelUpLimit) - 1
    -- print("tLevel=====", index, tLevel, maxLvl)
    if tLevel >= maxLvl then
        tLevel = maxLvl
        return false
    end
    tLevel = tLevel + 1
    local itemModel = self._modelMgr:getModel("ItemModel")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local needItemNum = tab:Tujianshengji(tLevel).itemNum
    local itemId = tab:Tujian(index).itemId
    local tempItems, tempItemCount = itemModel:getItemsById(itemId)
    -- print("loginWalfare============", userData.lvl, levelUpLimit[tLevel], tempItemCount, needItemNum)
    if userData.lvl >= levelUpLimit[tLevel] and tempItemCount >= needItemNum then
        flag = true
    else 
        flag = false
    end
    
    return flag
end

-- 判断图鉴是否有空位且有空闲卡牌
function PokedexModel:getPokedexFangzhi()
    local flag = false
    for k,v in pairs(self._data) do
        if v.onPokedex then
            flag = true
            break
        end
    end
    return flag
end

-- 判断当前卡牌是否已上阵
function PokedexModel:getTeamShow(param)
    local flag = false
    if self._data[tostring(param.pokedexId)]["posList"][tostring(param["putList"][1][1])] == param["putList"][1][2] then
        flag = true
    end
    return flag
end

-- 获取当前位置卡牌
function PokedexModel:getTeamShow(param)
    local teamId
    if self._data[tostring(param.pokedexId)]["posList"][tostring(param["posId"])] then
        teamId = self._data[tostring(param.pokedexId)]["posList"][tostring(param["posId"])]
    end
    return teamId 
end

-- 获取当前图鉴上阵兵团总数
function PokedexModel:getPokedexOnTeamByNum()
    local pokeNum = 0
    for k,v in pairs(self._data) do
        for k1,v1 in pairs(v.posList) do
            if v1 ~= 0 then
                pokeNum = pokeNum + 1
            end
        end
    end
    return pokeNum
end

-- 获取当前图鉴上阵兵团数
function PokedexModel:getPokedexOnTeamByIdNum(index)
    local pokeNum = 0
    local pokedexData = self:getDataById(index)
    if not pokedexData then
        return pokeNum
    end
    local posList = pokedexData["posList"]

    for k1,v1 in pairs(posList) do
        if v1 ~= 0 then
            pokeNum = pokeNum + 1
        end
    end
    return pokeNum
end

-- guofang 1.29专用
function PokedexModel:getPokedexPingByNum(pokedexId, evaluate)
    local pokeNum = 0
    local pokedexData = self:getDataById(pokedexId)
    if not pokedexData then
        return pokeNum
    end
    if (not evaluate) then
        return pokeNum
    end
    local posList = pokedexData["posList"]

    local teamModel = self._modelMgr:getModel("TeamModel")
    for k1,v1 in pairs(posList) do
        if v1 ~= 0 then
            local pingfenScore = teamModel:getTeamPokedexScore(v1) 
            local pingjia = teamModel:getTeamPingjia(pingfenScore)
            -- print("pingfenScore==========", v1, pingfenScore, pingjia)
            if pingjia >= evaluate then
                pokeNum = pokeNum + 1
            end
        end
    end
    return pokeNum
end


return PokedexModel