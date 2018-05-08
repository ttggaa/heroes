--[[
    Filename:    BattleDelayCall.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-06-25 14:59:32
    Description: File description
--]]

-- 跟随战斗加速的变化的delaycall
local BattleDelayCall = class("BattleDelayCall")

local _rid = 1
local _count = 0
local _tick = 0
local _delayPool = 1
function BattleDelayCall:ctor()
    _delayPool = {}
    _count = 0
    _rid = 1

    _tick = 0
end

function BattleDelayCall:clear()
    _delayPool = {}
    _count = 0
    _rid = 1
    _tick = 0
end
--   dt   0.02500001
local e = 0.000001
function BattleDelayCall:update(dt)
    if _count == 0 then return end
    _tick = _tick + dt
    if true then --_count < 15 then
        local procCount = 0
        for k, v in pairs(_delayPool) do 
            if _tick > v._runTime - e then
                v._callBack() 
                _delayPool[k] = nil
                procCount = procCount + 1
            end
        end
        _count = _count - procCount
    else
        local procCount = 0
        for k, v in pairs(_delayPool) do 
            if _tick > v._runTime - e then
                v._callBack()  
                _delayPool[k] = nil
                procCount = procCount + 1
                if procCount > 15 then
                    break
                end
            end
        end
        _count = _count - procCount
    end
end

function BattleDelayCall.dc(s,target,hander,force)
    if s == 0 or force then
        hander()
        return
    end
    _delayPool[_rid] = 
    {
        _callBack = hander,
        _runTime = _tick + s,
    }
    _rid = _rid + 1
    _count = _count + 1
end

function BattleDelayCall.dtor()
    BattleDelayCall = nil
    _rid = nil
    _count = nil
    _tick = nil
    _delayPool = nil
    e = 0
end

return BattleDelayCall

-- local _rid = 1
-- local _count = 0
-- local _tick = 0
-- local _delayPool = 1

-- local _poolHead = nil
-- local _poolTail = nil
-- function BattleDelayCall:ctor()
--     _delayPool = {}
--     _count = 0
--     _rid = 1

--     _tick = 0

--     _poolHead = nil
--     _poolTail = nil
-- end

-- function BattleDelayCall:clear()
--     _delayPool = {}
--     _count = 0
--     _rid = 1
--     _tick = 0

--     _poolHead = nil
--     _poolTail = nil
-- end

-- local e = 0.000001
-- function BattleDelayCall:update(dt)
--     local p = _poolHead
--     local lastP = nil
--     if p == nil then return end
--     _tick = _tick + dt
--     local cc = 0
--     while true do
--         if _tick > p._runTime - e then
--             _count = _count - 1
--             p._callBack()
--             if lastP then
--                 lastP._next = p._next
--                 p = lastP._next
--             else
--                 _poolHead = p._next
--                 p = _poolHead
--             end
--         else
--             lastP = p
--             p = p._next
--         end
--         if p == nil then
--             _poolTail = lastP
--             break
--         end
--     end
-- end

-- function BattleDelayCall.dc(s,target,hander,force)
--     if s == 0 or force then
--         hander()
--         return
--     end
--     local data = 
--     {
--         _callBack = hander,
--         _runTime = _tick + s,
--         _next = nil,
--     }
--     if _poolHead == nil then
--         _poolHead = data
--         _poolTail = data
--     else
--         _poolTail._next = data
--         _poolTail = data
--     end
--     _count = _count + 1
-- end

-- function BattleDelayCall.dtor()
--     BattleDelayCall = nil
--     _rid = nil
--     _count = nil
--     _tick = nil
--     _delayPool = nil
--     e = 0

--     _poolHead = nil
--     _poolTail = nil
-- end