--[[
    Filename:    BattleRandom.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-02-25 20:48:06
    Description: File description
--]]

local Random = class("Random")

local q1 = 8039
local a1 = 113
local K = 4*q1 + 1
local C = 2*a1 + 1
local M = 2^16

function Random:ctor(seed)
    self:setSeed(seed)
end

--[[
    @desc 设置随机种子。
]]
function Random:setSeed(seed)
    if seed==nil then
        -- seed = os.time()
        seed = tonumber(tostring(os.time()):reverse():sub(1, 6))
    end
    self._seed = seed
end

function Random:getRandomseed()
    return self._seed
end

function Random:rand()
    local seed = ((self._seed % M) * K + C) % M
    self._seed = seed
    return seed / M
end

--[[
    @desc 产生一个特定范围内的按平均分布随机数。
    @param n, m 指定随机数范围。
        如果n,m都为nil，则返回0~1的浮点随机数；
        如果仅m为nil，则返回1~n的随机整数；
        如果n,m都不为nil，则返回n~m的随机整数。
]]
local floor = math.floor
function Random:ran(n, m)
    if m == nil then
        local seed = ((self._seed % M) * K + C) % M
        self._seed = seed
        return floor(seed / M * n) + 1
    elseif n ~= nil then
        return floor(self:rand()*(m+1-n)) + n
    else
        return self:rand()
    end
end

--[[
    @desc 根据特定分布产生一个离散随机变量
    @param distribution 离散概率分布函数，用数组表示，其第i个元素的值
        P[i] = P(X in {X1,X2,...Xi})
        返回Xi的概率
        P(X=Xi) = P[i]-P[i-1]
    @return 产生的随机变量的下标
]]
function Random:discreteRandom(distribution)
    assert(distribution~=nil)
    local r = self:rand()
    local i = 1
    local n = #distribution
    while i<=n do
        local prob = distribution[i]
        if prob==nil or r<=prob then
            return i
        end
        i = i+1
    end
    return i
end

function Random.dtor()
    a1 = nil -- 113
    C = nil -- 2*a1 + 1
    random = nil
    K = nil -- 4*q1 + 1
    M = nil -- 2^16
    q1 = nil -- 8039
    floor = nil
end

return Random
