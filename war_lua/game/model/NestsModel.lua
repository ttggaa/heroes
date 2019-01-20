--
-- Author: <ligen@playcrab.com>
-- Date: 2016-12-08 17:14:25
--
local NestsModel = class("NestsModel", BaseModel)

-- 巢穴货币类型
local nestsCurrencyIds = {"nests1","nests2","nests3","nests4"}
local nTab = tab.nests
function NestsModel:ctor()
    NestsModel.super.ctor(self)

    self._nestsData = {}

    self:registerTimer(5, 0, 0, specialize(self.requestData, self))
end

function NestsModel:requestData()
    self:reflashData("request")
end

function NestsModel:setData(data)
    if type(data.nests) == "table" then
        for k, v in pairs(data.nests) do
            self._nestsData[k] = v
        end
        self:reflashData("update")

    end
end

-- 更新墓穴信息
function NestsModel:setNestData(data)
    for cId, cData in pairs(data) do
        for nId, nData in pairs(cData) do
            if self._nestsData[cId] == nil then
                self._nestsData[cId] = {}
                self._nestsData[cId][nId] = nData 

            elseif self._nestsData[cId][nId] == nil then
                self._nestsData[cId][nId] = nData

            else
                for k, v in pairs(nData) do
                    self._nestsData[cId][nId][k] = v
                end
            end
        end
    end
    self:reflashData("update")
end

-- 碎片增加
function NestsModel:addShard(nId, num)
    for k, v in pairs(self._nestsData) do
        if v[nId] ~= nil then
            v[nId].frg = v[nId].frg or 0
            v[nId].frg = v[nId].frg + num
            v[nId].frg = math.min(v[nId].frg, 10)
        end
    end
end

-- 获取对应巢穴信息
-- @param nId:墓穴ID
function NestsModel:getNestDataById(nId)
    nId = tostring(nId)
    local nestData = {}
    for k, v in pairs(self._nestsData) do
        if type(v) == "table" and v[nId] then
            nestData = v[nId]
            nestData.id = nId
            return nestData
        end
    end
    return nil
end

-- 获取对应阵营信息
-- @param cId:阵营ID
function NestsModel:getCampDataById(cId)
    cId = tostring(cId)
    return self._nestsData[cId] or {}
end


-- 根据兵团id判断是否可建造
function NestsModel:getCanBuildById(tId)
    return self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tId) and true or false
end

-- 获取每个碎片时间
-- @param nId:巢穴ID
-- @param lv:巢穴等级
function NestsModel:getTimeById(nId, lv)
    lv = lv and lv or 1
    local rate = nTab[tonumber(nId)].born[lv]
    local time = tab:Setting("NESTS_PRODUCE").value / rate / 60
    if time == math.floor(time) then
        return time
    else
        return string.format("%.1f", time)
    end
end

-- 判断巢穴是否可以丰收
-- @param cId:阵营ID
function NestsModel:getNestCanHarvest(cId, nId)
    cId = tostring(cId)
    if self._nestsData[cId] == nil then
        return false
    end

    local nestData = self._nestsData[cId][tostring(nId)]
    if nestData == nil then
        return false
    else
        if nestData.frg and nestData.frg < nTab[tonumber(nId)].born_limit then
            return true
        end
    end
    return false
end

-- 判断阵营是否可以丰收
-- @param cId:阵营ID
function NestsModel:getCampCanHarvest(cId)
    cId = tostring(cId)
    if self._nestsData[cId] == nil then
        return false
    end

    for k, v in pairs(self._nestsData[cId]) do
        if v.frg and v.frg < nTab[tonumber(k)].born_limit then
            return true
        end
    end

    return false
end

-- 判断是否为巢穴货币
-- @cId 货币ID
function NestsModel:getIsNestsCurrency(cId)
    for i = 1, #nestsCurrencyIds do
        if nestsCurrencyIds[i] == cId then
            return true
        end
    end
    return false
end

-- 获取阵营
function NestsModel:getCampByTeamId(tId)
    for k, v in pairs(nTab) do
        if v.team == tId then
            return v.race
        end
    end
end

-- 获取对应阵营的兵团ID
function NestsModel:getTeamIdsByCampId(cId)
    local ids = {}
    for k, v in pairs(nTab) do
        if tostring(cId) == tostring(v.race) then
            table.insert(ids, v.team)
        end
    end
    return ids
end

function NestsModel:dtor()
    nestsCurrencyIds = nil
    nTab = nil
end
return NestsModel