
--[[
    Filename:    TalentModel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-04-20 16:24:42
    Description: File description
--]]

--[[
    ********数据瘦身记录********
    childList   => cl
    consumeStar => cs
    status      => s
    level       => l
]]--

local TalentModel = class("TalentModel", BaseModel)

function TalentModel:ctor()
    TalentModel.super.ctor(self)
    self._data = {}
    self._modelMgr = ModelManager:getInstance()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
end

function TalentModel:setData(data)
    -- dump(data, "TalentModel:setData", 10)
    self._data = data
    self._cached = true
    self:reflashData("TalentModel")
end

function TalentModel:getData()
    return self._data
end

function TalentModel:updateData(data)
    if self._data and next(self._data) ~= nil then
        local function updateSubData(inSubData, inUpData)
            if type(inSubData) == "table" then
                for k,v in pairs(inUpData) do
                    local backData = updateSubData(inSubData[k], v)
                    inSubData[k] = backData
                end
                return inSubData
            else 
                return inUpData
            end
        end

        for k,v in pairs(data) do
            local backData = updateSubData(self._data[k], v)
            self._data[k] = backData
        end
    end
end

function TalentModel:isNeedRequest()
    if not self._cached then
        self._cached = true
        return true
    end
    return false
end

function TalentModel:setOutOfDate()
    self._cached = false
    self:reflashData()
end

function TalentModel:getBattleNum()
    return self._data["score"] or 0,self._lastBattle or self._data["score"] or 0
end

function TalentModel:updateTalentData(data)
    -- dump(data, "a", 10)
    if not (data and data["d"]) then return end
    if data["d"].talent then
        for k, v in pairs(data["d"].talent) do
            if k == "score" then
                self._lastBattle = v
                self._data[k] = v
            else
                if v.cl then
                    for k0, v0 in pairs(v.cl) do
                        table.merge(self._data[tostring(k)]["cl"][tostring(k0)], v0)
                    end
                end
                v.cl = nil
                table.merge(self._data[tostring(k)], v)
            end
        end
    end
    data["d"].talent = nil
    self._userModel:updateUserData(data["d"])
end

function TalentModel:checkTalentPopTip()
    if not self._data or next(self._data) == nil then
        return false
    end

    for k,parent in pairs(self._data) do
        if type(parent) == "table" and parent.s == 1 then
            for i,child in pairs(parent.cl) do
                local sysMagicTalent = tab.magicTalent[tonumber(i)]
                if child.s == 1 and child.l < sysMagicTalent.maxLevel then
                    local have, cost = self._modelMgr:getModel("UserModel"):getData().starNum, sysMagicTalent["cost"][child.l + 1]
                    if have >= cost then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function TalentModel:setShowChannel(inType)
    self._channel = inType

    local localD = SystemUtils.loadAccountLocalData("talentChannel") or {}
    localD["lastT"] = inType
    if not localD[inType] then
        localD[inType] = true
    end
    SystemUtils.saveAccountLocalData("talentChannel", localD)
end

function TalentModel:getShowChannel()
    local showT = 1
    --当前最大标签
    local curlvl = self._userModel:getData().lvl or 0
    local sysMagic = clone(tab.magicSeries)

    local sysMagic1 = {}
    for k,v in pairs(sysMagic) do
        table.insert(sysMagic1, v)
    end
    table.sort(sysMagic1, function(a, b) return a.show < b.show end)

    local lastData
    for i = 1, #sysMagic1 do
        local info = sysMagic1[i]
        if lastData == nil then
            lastData = info
        else
            local needLv = info["lvlimit"]
            if curlvl >= needLv then
                local dis1 = curlvl - lastData["lvlimit"]
                local dis2 = curlvl - needLv
                if dis1 >=0 and dis2 >=0 and dis2 <= dis1 then
                    lastData = info
                end
            end            
        end
    end

    local maxMark = lastData["show"]
    local localD = SystemUtils.loadAccountLocalData("talentChannel")
    if localD then  
        if not localD[maxMark] then
            showT = maxMark
        else
            showT = localD["lastT"]
        end
    else
        showT = maxMark
    end

    return showT
end

return TalentModel