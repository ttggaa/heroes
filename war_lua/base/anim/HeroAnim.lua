--[[
    Filename:    HeroAnim.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-12-06 20:59:18
    Description: File description
--]]

local HeroAnim = class("HeroAnim")
local mcMgr = MovieClipManager:getInstance()
local cc = cc
local AnimAP = require "base.anim.AnimAP"
local mcScale = 2

-- 新英雄MC
--[[ 动作大全
	stop 	待机
	run 	移动
	run2	举剑移动
	atk1	攻击1
	atk2	攻击2
	atk3	攻击3
	die1    死亡(落马)
	die2 	死亡(旋转)
	dizzy   晕眩
	hit1  	受击
	hit2	招架
	suck	嘲讽
	win     胜利
	zuoji   马跑了(落马)
]]--

-- 是否创建的时候创建所有动作
-- motions为动作集合
function HeroAnim:ctor(parentNode, filename, motions, callback)
    self._set = nil
    if parentNode then
        -- 站位节点, 用于解决还没添加到parentNode时, parentNode被释放, 变成野指针的问题
        self._set = cc.Node:create()
        self._set:registerScriptHandler(function (state)
            if state == "exit" then
                self._quit = true
            end
        end)
        parentNode:addChild(self._set)
    end
    self._parentNode = parentNode
    self._filename = filename
    if motions then
    	self._motions = motions
    else
    	self._motions = {"stop"}
    end
    self._motion = "stop"
    self._cache = {}
    self._width = 100
    self._height = 100
    self._callback = callback
    if mcMgr:isResLoaded(filename) then
    	self:initMovieClip()
    else
    	mcMgr:loadRes(filename, function ()
    		self:initMovieClip()
    	end)
    end
    self.visible = true
    self._motionLoopCount = 0
end

function HeroAnim:initMovieClip()
    self._invTick = 0.05
	self._node = cc.Node:create()
    self._node:setCascadeColorEnabled(true)
    self._node:setCascadeOpacityEnabled(true)
    self._node:registerScriptHandler(function (state)
        if state == "exit" then
            self:clear()
        end
    end)
    self._motionFrame = {}
    local motions = self._motions
	for i = 1, #self._motions do
		local cacheMotion = mcMgr:createMovieClip(motions[i] .. "_" .. self._filename, nil, true)
		if cacheMotion then
            self._motionFrame[motions[i]] = cacheMotion:getTotalFrames()
			cacheMotion:stop()
			cacheMotion:retain()
            cacheMotion:setCascadeColorEnabled(true, true)
            cacheMotion:setCascadeOpacityEnabled(true, true)
            self._cache[motions[i]] = cacheMotion
		end
	end
    local ap = AnimAP["mcList"][self._filename]
    if ap == nil then
        ap = AnimAP["mcList"]["shuyao"]
    end
    self._ap = ap
    self._width = ap[0][1]
    self._height = ap[0][2]
	self._mc = nil
	  self:changeMotion(self._motion)
    if self:addTo(self._parentNode) then
        if self._callback then
            self._callback(self)
            self._callback = nil
        end
    end
end

function HeroAnim:getMotionFrame()
    return self._motionFrame
end

function HeroAnim:addTo(parentNode)
    if self._quit then
        return false
    end
    if parentNode then
        parentNode:addChild(self._node)
        if self._set then
            self._set:removeFromParent()
        end
        self._parentNode = parentNode
    end
    return true
end

function HeroAnim:getSize()
    return self._width, self._height
end

local defa = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}}
function HeroAnim:getAp(index)
    if self._ap then
        return self._ap[index]
    else
        return defa[index]
    end   
end

function HeroAnim:clear()
    self._parentNode = nil
    if self._cache then
    	for k, v in pairs(self._cache) do
    		v:release()
    	end
    end
    -- if self._node then
    --     self._node:removeFromParent(true)
    --     self._node = nil
    -- end
    self._apNone = nil
    self:stop()
    delete(self)
end

function HeroAnim:play()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    self._updateId = ScheduleMgr:regSchedule(50, self, function(self, dt)
        self:autoUpdate()
    end)
end

function HeroAnim:autoUpdate()
    self:update(socket.gettime(), 2)
end

function HeroAnim:isPlaying()
    if self._mc then
        return self._mc:isPlaying()
    end
end

function HeroAnim:pause()
	self._anim = false
    if self._mc then
        self._mc:stop(true)
    end
end

function HeroAnim:stop()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
end

function HeroAnim:resume()
    if not self._loopEnd then
    	self._anim = true
        if self._mc then
            self._mc:play(true)
        end
    end
end

function HeroAnim:update(tick, _type)
    if self._mc ~= nil then
        if self._anim then
            if self._tickType ~= _type then
                -- 矫正时间
                self._beginTick = tick
                self._tickType = _type
            end 
            local loopCount = self._mc:updateAndStop(self._beginTick, tick, self._invTick, true)
            if loopCount > self._motionLoopCount then
                self._motionLoopCount = loopCount
                if self._endCallback then
                    self._endCallback()
                    self._endCallback = nil
                end
                if not self._loop then
                    self._anim = false
                    self._loopEnd = true
                    self._mc:gotoAndStop(self._maxFrame)
                end
            end
        end
    end
end

function HeroAnim:changeMotion(motion, tick, callback, noloop, inv, startFrame, returnNull)
    if returnNull == nil then
        returnNull = true
    end
    if self._cache[motion] == nil then return end

    self._endCallback = callback
	if self._mc then
        self._mc:stop()
		self._mc:removeFromParent()
	end
    if startFrame == nil then
        startFrame = 1
    end    
	self._motion = motion
    self._loopEnd = false
	if self._cache then
		self._mc = self._cache[self._motion]
		if self._mc then
            self._maxFrame = self._mc:getTotalFrames()
            self._anim = true
            self._loop = not noloop

            if inv then
                self._invTick = inv
            else
                self._invTick = 0.05
            end

			self._node:addChild(self._mc)
            self._mc:play()
            self._mc:gotoAndStop(1)
		end
	end
    if tick == nil then
        self._beginTick = socket.gettime()
        self._tickType = 2
    else
        self._beginTick = tick
        self._tickType = 1
    end
    self._motionLoopCount = 0
end

function HeroAnim:gotoAndStop(frame)
    if self._mc then
        self._mc:gotoAndStop(frame)
    end
end

function HeroAnim:getMotion()
    return self._motion
end

function HeroAnim:setPosition(x, y)
    if self._node then
        self._node:setPosition(x, y)
    end
end

function HeroAnim:setVisible(visible)
    if self._node then
        self.visible = visible
        self._node:setVisible(visible)
    end
end

function HeroAnim:setOpacity(o)
    if self._node then
        self._node:setOpacity(o)
    end
end

function HeroAnim:setScale(scale)
    if self._node then
        self._node:setScale(scale * mcScale)
    end
end

function HeroAnim:setScaleX(scale)
    if self._node then
        self._node:setScaleX(scale * mcScale)
    end
end

function HeroAnim:getScale()
    if self._node then
        return self._node:getScaleX() / mcScale
    else
        return 1.0
    end
end

function HeroAnim:setColor(color)
    if self._node then
        self._node:setColor(color)
    end
end

function HeroAnim:setBlendFunc(func)
    if self._node then
        self._node:setBlendFunc(func)
    end
end

function HeroAnim:stopAllActions()
    if self._node then
        self._node:stopAllActions()
    end
end

function HeroAnim:stopAllActions()
    if self._node then
        self._node:stopAllActions()
    end
end

function HeroAnim:runAction(action)
    if self._node then
        self._node:runAction(action)
    end
end

function HeroAnim:setBrightness(value)
    if self._node then
        self._node:setBrightness(value)
    end
end

function HeroAnim:setHue(value)
    if self._node then
        self._node:setHue(value)
    end
end

function HeroAnim:setSaturation(value)
    if self._node then
        self._node:setSaturation(value)
    end
end

function HeroAnim:setContrast(value)
    if self._node then
        self._node:setContrast(value)
    end
end

function HeroAnim:setLocalZOrder(value)
    if self._node then
        self._node:setLocalZOrder(value)
    end
end

function HeroAnim:setCM(...)
    if self._node then
        self._node:setCM(...)
    end 
end

function HeroAnim.dtor()
    AnimAP = nil
    cc = nil
    mcMgr = nil
    mcScale = nil
    motionName = nil
    HeroAnim = nil
    defa = nil
end

return HeroAnim