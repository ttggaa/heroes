--[[
    Filename:    BattleBuffer.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-10 19:21:13
    Description: File description
--]]

local BC = BC
local pc = pc
local cc = _G.cc
local os = _G.os
local math = math
local pairs = pairs
local next = next
local tab = tab
local tonumber = tonumber
local tostring = tostring
local table = table
local mcMgr = mcMgr


local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType

-- 可加buff的对象

local BattleBuffer = class("BattleBuffer")

function BattleBuffer:ctor()
    self.buff = {}
end

function BattleBuffer:clear()
    self.buff = nil

    delete(self)
end

local ETeamStateDIE = ETeamState.DIE
function BattleBuffer:updateBuff(tick)
    -- 这里只判断BUFF持续时间
    local change = false
    local buffD
    for k, buff in pairs(self.buff) do
        buffD = buff.buffD
        -- 首跳
        if buff.firstDot then
            buff.firstDot = false
            self:buffDot(buff)
        end
        -- 心跳
        local nextDot = buff.nextDot
        if nextDot ~= 0 and tick > nextDot - 0.00000001 then
            self:buffDot(buff)
            buff.nextDot = nextDot + buff.interval
        end
        local needReset = buff.needReset
        -- 到时间移除
        if buff.endTick ~= 0 and tick > buff.endTick - 0.00000001 then
            if needReset then
                change = true
            end
            self:delBuff(k)
        end
        -- 条件消除
        local disappear = buff.disappear
        if disappear == 3 then
            if buff.attacker.die then
                if needReset then
                    change = true
                end
                self:delBuff(k)
            end
        elseif disappear == 4 then
            if buff.attacker.team.state == ETeamStateDIE then
                if needReset then
                    change = true
                end
                self:delBuff(k)
            end          
        end
    end
    if change then
        self:resetAttr()
    end
end

-- buff生效
function BattleBuffer:buffDot(buff)

end

function BattleBuffer:clearBuff()
    -- 同一IDBUFF最多只会有一个, 所以用ID当作索引
    self.buff = {}
end
local modf = math.modf
function BattleBuffer:addBuff(buff)
    -- 只有同一ID的buff才存在叠加的情况
    -- 效果强的可以替代效果弱的
    -- 效果弱的不能替代以及叠加效果强的
    local buffD = buff.buffD
    local id = buffD["id"]
    local needReset = false
    -- print(os.clock(), self.ID, "add buff"..id)
    local res = nil
    local valid = nil
    if self.buff[id] ~= nil then
        local ex = self.buff[id]
        -- 只要确定第一个值即可
        if buff.value[1] >= ex.value[1] then
            buff.count = ex.count
            local superposition = buffD["superposition"]
            if superposition and (buff.count < superposition) then
                buff.count = buff.count + 1
                needReset = buff.needReset
            end
            buff.nextDot = ex.nextDot
            buff.eff = ex.eff
            self.buff[id] = buff
            valid = true
        end
        if buff.value[1] > ex.value[1] then
            needReset = buff.needReset
        end
    else
        self.buff[id] = buff
        needReset = buff.needReset
        res = id
        valid = true
    end
    if buffD["delete"] then
        local reset = false
        if type(buffD["delete"]) == "table" then
            for i,v in ipairs(buffD["delete"]) do
                if v then
                    local _reset = self:delBuffByLabel(v)
                    if _reset then
                        reset = true
                    end
                end
            end
        else
            reset = self:delBuffByLabel(buffD["delete"])
        end
        needReset = needReset or reset
    end
    if needReset then
        self:resetAttr()
    end
    return res, valid
end

function BattleBuffer:delBuff(id, reset)
    if self.buff[id] == nil then
        return
    end
    -- print(os.clock(), self.ID, "del buff"..id)
    local needReset = self.buff[id].needReset 
    self.buff[id] = nil
    if needReset then
        if reset then
            self:resetAttr()
        end    
    end
end

-- 获取某IDbuff的层数
function BattleBuffer:hasBuff(id)
    if self.buff[id] == nil then
        return 0
    else
        return self.buff[id].count
    end
end

-- 判断是否有某系buff
function BattleBuffer:hasBuffKind(kind)
    for k, buff in pairs(self.buff) do
        if buff.buffD["label"] == kind then
            return true
        end
    end
    return false
end

-- 驱散BUFF
-- dispelBuff驱散有利
-- dispelDebuff驱散不利
-- strength buff强度
function BattleBuffer:dispelBuff(dispelBuff, dispelDebuff, strength)
    local change = false
    local buffD, kind
    if next(self.buff) ~= nil then
        for k, buff in pairs(self.buff) do
            buffD = buff.buffD
            if strength >= buffD["strength"] then
                -- buff/hot/灵魂链接
                kind = buffD["kind"]
                if kind == 0 or kind == 3 or kind == 4 then
                    if dispelBuff then
                        -- if BattleUtils.XBW_SKILL_DEBUG then print(os.clock(), "驱散"..k) end
                        self:delBuff(k)
                        change = true
                    end
                else
                    if dispelDebuff then
                        -- if BattleUtils.XBW_SKILL_DEBUG then print(os.clock(), "驱散"..k) end
                        self:delBuff(k)
                        change = true
                    end
                end
            end
        end
    end
    if change then
        self:resetAttr()
    end
end

-- 拥有debuff的个数
function BattleBuffer:getDebuffCount()
    local count = 0
    local bufft = {}
    local buffs = self.buff
    for _, buff in pairs(buffs) do
        local buffKind = buff.buffD["kind"]
        local label = buff.buffD["label"]
        if (buffKind == 1 or buffKind == 2) and label ~= 0 then
            count = count + 1
            bufft[buff.buffD.id] = label 
        end 
    end
    return count, bufft
end

-- 拥有buff的个数
function BattleBuffer:getBuffCount()
    local count = 0
    local bufft = {}
    local buffs = self.buff
    for _, buff in pairs(buffs) do
        local buffKind = buff.buffD["kind"]
        local label = buff.buffD["label"]
        if buffKind == 0 and label ~= 0 then
            count = count + 1
            bufft[buff.buffD.id] = label 
        end 
    end
    return count, bufft
end

-- 拥有debuff的个数剔除了同类型的debuff
-- 多个同类型的debuff算一个
function BattleBuffer:getDebuffLabelCount()
        local count = 0
        local bufft = {}
        local buffs = self.buff
        for _, buff in pairs(buffs) do
            if buff.buffD and type(buff.buffD) == "table" and buff.buffD.id then
                local buffKind = buff.buffD["kind"]
                local label = buff.buffD["label"]
                if (buffKind == 1 or buffKind == 2) and label ~= 0 and label then
                    if not bufft[label] then
                        count = count + 1
                        bufft[label] = {buff.buffD.id} 
                    else
                        table.insert(bufft[label], buff.buffD.id)
                    end 
                end
                if not label then
                    print("buff.buffD.id",buff.buffD.id,"label..",label,"buffKind",buffKind)
                end
            else
                print("buff.buffD kong") 
            end
        end
        return count, bufft
    end

-- buff消除
--1. 
function BattleBuffer:disappearBuff(kind)
    local change = false
    local buffD
    if next(self.buff) ~= nil then
        for k, buff in pairs(self.buff) do
            buffD = buff.buffD  
            if kind == buffD["disappear"] then
                self:delBuff(k)
                if buffD["kind"] <= 1 then
                    change = true
                end
            end
        end
    end
    if change then
        self:resetAttr()
    end
end

function BattleBuffer:delBuffByLabel(label)
    local change = false
    local buffD
    if next(self.buff) ~= nil then
        for k, buff in pairs(self.buff) do
            buffD = buff.buffD  
            if label == buffD["label"] then
                self:delBuff(k)
                if buffD["kind"] <= 1 then
                    change = true
                end
            end
        end
    end
    return change
end

function BattleBuffer:resetAttr()
end

function BattleBuffer.dtor()
    BattleBuffer = nil
    BC = nil
    cc = nil
    ECamp = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil
    EState = nil
    ETeamState = nil
    math = nil
    mcMgr = nil
    modf = nil
    next = nil
    os = nil
    pairs = nil
    pc = nil
    tab = nil
    table = nil
    tonumber = nil
    tostring = nil
end

return BattleBuffer