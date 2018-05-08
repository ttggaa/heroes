--[[
    Filename:    BattleObject.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-29 17:30:11
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
-- 战斗场景元件基类

local BattleObject = class("BattleObject", require("game.view.battle.object.BattleBuffer"))

local super = BattleObject.super
function BattleObject:ctor()
    super.ctor(self)
    self.isMove = false

    self._lastCheckTick = -1000
 
    -- 坐标
    self.x = 0
    self.y = 0

    self._offsetPtx = 0
    self._offsetPty = 0
    self.ID = 0
end

function BattleObject:clear()
    self._moveEndCallback = nil
    super.clear(self)
end

function BattleObject:getPos()
    return self.x, self.y
end

function BattleObject:setPos(x, y)
    self.x, self.y = x, y
end

function BattleObject:setOffsetPos(x, y)
    self._offsetPtx = x
    self._offsetPty = y
end

function BattleObject:getOffsetPos()
    return self._offsetPtx, self._offsetPty
end

-- ccMoveTo 每次重新定向会卡, 因此移动需要自行处理
local sqrt = math.sqrt
local EDirectRIGHT = EDirect.RIGHT
local EDirectLEFT = EDirect.LEFT
function BattleObject:moveTo(x, y, speed, callback)
    self.isMove = true
    local sx, sy = self.x, self.y
    self._moveScrx = sx  -- 原始点
    self._moveScry = sy  
    self._moveDstx = x   -- 目标点
    self._moveDsty = y
    local dx, dy = x - sx, y - sy
    self._moveDeltax = dx  --目标点与原始点的水平距离
    self._moveDeltay = dy  --目标点与原始点的竖直距离
    self._moveSpeed = speed
    local dis = sqrt(dx * dx + dy * dy)
    self._moveBeginTick = BC.BATTLE_TICK
    self._moveDeltaTick = speed / dis
    self._moveEndTick = self._moveBeginTick + 1 / self._moveDeltaTick

    if x > sx + 0.00000001 then
        self:setDirect(EDirectRIGHT)
    else
        self:setDirect(EDirectLEFT)
    end
    self._moveEndCallback = callback
    self:onMove()
end

function BattleObject:updateMove(tick)
    if tick > self._moveEndTick + 0.00000001 then     
        self:setPos(self._moveDstx, self._moveDsty)
        self:stopMove()
        if self._moveEndCallback then
            self._moveEndCallback(self)
            self._moveEndCallback = nil
        end
    else
        local rate = (tick - self._moveBeginTick) * self._moveDeltaTick
        --[[
             BattleObject:moveTo后持续运动，直到运动到目标点
             判断运动到目标点的逻辑是根据移动结束帧来判断的，
             当到达了移动结束帧就设置到最终位置以及调用stopMove设置self.isMove = false
        ]]
        self:setPos(self._moveScrx + self._moveDeltax * rate, self._moveScry + self._moveDeltay * rate)
    end
end
function BattleObject:stopMove()
    self:onStop()
    self._moveDstx = 0
    self._moveDsty = 0
    self._moveSpeed = 0
    self.isMove = false
end

function BattleObject:setDirect(dir)

end

function BattleObject:onMove()

end

function BattleObject:onStop()
    
end

function BattleObject.dtor()
    
    BattleObject = nil
    BC = nil -- BC
    cc = nil -- _G.cc
    
    ECamp = nil -- BC.ECamp
    EDirect = nil -- BC.EDirect
    EDirectLEFT = nil -- EDirect.LEFT
    EDirectRIGHT = nil -- EDirect.RIGHT
    EEffFlyType = nil -- BC.EEffFlyType
    EMotion = nil -- BC.EMotion
    EState = nil -- BC.EState
    ETeamState = nil -- BC.ETeamState
    math = nil -- math
    mcMgr = nil -- mcMgr
    next = nil -- next
    os = nil -- _G.os
    pairs = nil -- pairs
    pc = nil -- pc
    sqrt = nil -- math.sqrt
    tab = nil -- tab
    table = nil -- table
    tonumber = nil -- tonumber
    tostring = nil -- tostring
    super = nil
end

return BattleObject

