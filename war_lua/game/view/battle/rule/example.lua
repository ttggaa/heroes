--[[
    Filename:    BattleRule_Example.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-10-19 16:45:07
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
local floor = math.floor
local ceil = math.ceil
local mcMgr = mcMgr


local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType

local logic
local BattleScene = require("game.view.battle.display.BattleScene")

-- 根据玩法不同,界面也不同
function BattleScene:initBattleUIEx()

end

-- 显示HP
function BattleScene:countHPEx()

end

-- update
function BattleScene:updateEx(dt)

end

function BattleLogic:teamAttackOverEx(team)

end

function BattleScene:setOverTime(time)

end

-- 摄像机初始位置
function BattleScene:playEx()

end

-- 是否可以移动摄像机
function BattleScene:updateTouchEx()

end

function BattleScene:onMouseScrollEx()

end

function BattleScene:onTouchesBeganEx()

end

function BattleScene:onTouchesMovedEx()

end

function BattleScene:onTouchesEndedEx()

end

-- 战斗开始动画
function BattleScene:battleBeginAnimEx()
	self._touchMask:removeFromParent()
	self:initBattleSkill(function ()
        ScheduleMgr:delayCall(1000, self, function()
        	self:battleBeginMC()
        	ScheduleMgr:delayCall(1750, self, function()
    		    self:battleBegin()
    	    end)
        end)
    end)
end

-- 战斗开始动画
function BattleScene:battleBeginMCEx()

end

-- 跳过开场动画
function BattleScene:jumpBattleBeginAnimEx()

end

-- 中断开场动画
function BattleScene:battleBeginAnimCancelEx()

end

function BattleScene:onBattleEndEx(res)

end

local BattleLogic = require("game.view.battle.logic.BattleLogic")

function BattleLogic:initLogicEx()
    logic = BC.logic
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

function BattleLogic:BattleBeginEx()

end

function BattleLogic:updateEx()

end

function BattleLogic:onTeamDieEx(team)

end

function BattleLogic:onSoldierDieEx(soldier)

end

function BattleLogic:onHPChangeEx(soldier, change)

end

function BattleLogic:setCampBrightnessEx(camp, value)

end

-- 胜利条件
function BattleLogic:checkWinEx()
    if self._surrender then
        self:surrender(2)
        return true
    end
    -- 三分钟没结果,算左边输
    if self.battleTime > 180 then
        self:timeUp(2)
        return true
    end
    for i = 1, 2 do
        if self._HP[i] + self._summonHP[i] == 0 then
            self:Win(3 - i)
            return true
        end
    end
    return false
end