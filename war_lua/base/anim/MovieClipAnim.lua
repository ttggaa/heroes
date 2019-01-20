--[[
    Filename:    MovieClipAnim.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-11-02 15:52:44
    Description: File description
--]]

local MovieClipAnim = class("MovieClipAnim")
local mcMgr = MovieClipManager:getInstance()
local cc = cc
local AnimAP = require "base.anim.AnimAP"
local mcScale = 2

-- 是否创建的时候创建所有动作
function MovieClipAnim:ctor(parentNode, filename, callback, changeColor, maxW, maxH, cacheAllMotion)
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
    self._motion = 1
    self._cache = {}
    self._width = 100
    self._height = 100
    self._maxW = maxW
    self._maxH = maxH
    self._cacheAllMotion = cacheAllMotion
    self._callback = callback
    self._changeColor = changeColor
    self._opaction =  255
    if mcMgr:isResLoaded(filename) then
    	self:initMovieClip()
    else
    	mcMgr:loadRes(filename, function ()
    		self:initMovieClip()
    	end)
    end
    self.visible = true
    self._freeze = false
    self._stop = false
    self._motionLoopCount = 0
end

function MovieClipAnim:hasDie()
    return true
end

-- EMotion = {
--     IDLE = 1,
--     MOVE = 2,
--     ATTACK = 3,
--     DIE = 4,
--     CAST1 = 5,
--     CAST2 = 6,
--     CAST3 = 7,
-- }

local motionName = {"stop", "run", "atk", "die", "atk2", "atk3", "atk4", "born", "win", "standby", "walk", "stop", "skill", "stop2", "atk5", "atk6", "born1", "atk1"}
--                     1      2      3      4       5       6       7       8      9       10        11      12       13      14       15      16       17      18  
function MovieClipAnim:initMovieClip()
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
    local ex = ""
    if self._changeColor then
        ex = "r"
    end
    if self._cacheAllMotion then
    	for i = 1, #motionName do
    		self._cache[i] = mcMgr:createMovieClip(motionName[i] .. ex .. "_" .. self._filename, nil, true)
            if self._cache[i] == nil then
                self._cache[i] = mcMgr:createMovieClip(motionName[i] .. "_" .. self._filename, nil, true)
            end
    		if self._cache[i] then
                self._motionFrame[i] = self._cache[i]:getTotalFrames()
    			self._cache[i]:stop()
    			self._cache[i]:retain()
                self._cache[i]:setCascadeColorEnabled(true, true)
                self._cache[i]:setCascadeOpacityEnabled(true, true)
    		end
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
    if self._cacheAllMotion then
	   self:changeMotion(self._motion)
    end
    if self._maxW and self._maxH then
        local w, h = self:getSize()
        local wscale = self._maxW / w
        local hscale = self._maxH / h
        if wscale > 1 then wscale = 1 end
        if hscale > 1 then hscale = 1 end
        if wscale < 1 or hscale < 1 then
            if wscale > hscale then
                self._node:setScale(wscale)
            else
                self._node:setScale(hscale)
            end
        end
    end
    if self:addTo(self._parentNode) then
        if self._callback then
            self._callback(self)
            self._callback = nil
        end
    end
end

function MovieClipAnim:getMotionFrame()
    return self._motionFrame
end

function MovieClipAnim:addTo(parentNode)
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

function MovieClipAnim:getSize()
    return self._width, self._height
end

local defa = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}}
function MovieClipAnim:getAp(index)
    if self._ap then
        return self._ap[index]
    else
        return defa[index]
    end   
end

function MovieClipAnim:clear()
    self._parentNode = nil
    if self._cache then
        pcall(function () 
            for k, v in pairs(self._cache) do
                v:release()
            end
        end)
    end
    -- if self._node then
    --     self._node:removeFromParent(true)
    --     self._node = nil
    -- end
    self._apNone = nil
    self:stop()
    delete(self)
end

function MovieClipAnim:play()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    self._updateId = ScheduleMgr:regSchedule(50, self, function(self, dt)
        self:autoUpdate()
    end)
end

function MovieClipAnim:autoUpdate()
    self:update(socket.gettime(), 2)
end

function MovieClipAnim:isPlaying()
    if self._mc then
        return self._mc:isPlaying()
    end
end

function MovieClipAnim:pause()
	self._anim = false
    if self._mc then
        self._mc:stop(true)
    end
end

function MovieClipAnim:stop()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
end

function MovieClipAnim:resume()
    if not self._loopEnd then
    	self._anim = true
        if not self._stop and not self._freeze then
            if self._mc then
                self._mc:play(true)
            end
        end
    end
end

function MovieClipAnim:freeze()
    self._freeze = true
end

function MovieClipAnim:unfreeze()
    self._freeze = false
end

function MovieClipAnim:stopAnim()
    self._stop = true
end

function MovieClipAnim:update(tick, _type)
    if self._mc ~= nil then
        if not self._freeze and not self._stop and self._anim then
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

function MovieClipAnim:changeMotion(motion, tick, callback, noloop, inv, startFrame, returnNull)
    if returnNull == nil then
        returnNull = true
    end
    if self._motionFrame == nil then return end
    if self._cacheAllMotion then
        if self._cache[motion] == nil then return end
    else 
        if self._cache[motion] == nil then 
            local ex = ""
            if self._changeColor then
                ex = "r"
            end
            self._cache[motion] = mcMgr:createMovieClip(motionName[motion] .. ex .. "_" .. self._filename, nil, returnNull)
            if self._cache[motion] == nil then
                ex = ""
                self._cache[motion] = mcMgr:createMovieClip(motionName[motion] .. ex .. "_" .. self._filename, nil, returnNull)
            end
            if self._cache[motion] then
                self._motionFrame[motion] = self._cache[motion]:getTotalFrames()
                self._cache[motion]:stop()
                self._cache[motion]:retain()
                self._cache[motion]:setCascadeColorEnabled(true, true)
                self._cache[motion]:setCascadeOpacityEnabled(true, true)
            elseif motion ~= 1 then
                self:changeMotion(1, tick, callback, noloop, inv, startFrame, returnNull)
                self._motionLoopCount = 0
                return
            end
        end
    end

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
            self._stop = false
            if motion == 4 then
                self._freeze = false
            end
            self._loop = not noloop

            if inv then
                self._invTick = inv
            else
                self._invTick = 0.05
            end

			self._node:addChild(self._mc)
            self._mc:play()
            self._mc:gotoAndStop(1)
            self._mc:setOpacity(self._opaction)
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

function MovieClipAnim:getMotion()
    return self._motion
end

function MovieClipAnim:setLocalZOrder(inOrder)
    if self._node then
        self._node:setLocalZOrder(inOrder)
    end
end

function MovieClipAnim:setPosition(x, y)
    if self._node then
        self._node:setPosition(x, y)
    end
end

function MovieClipAnim:setVisible(visible)
    if self._node then
        self.visible = visible
        self._node:setVisible(visible)
    end
end

function MovieClipAnim:setOpacity(o)
    if self._node then
--        self._opaction = o
        self._node:setOpacity(o)
    end
end

--作为buff的隐藏效果的添加，和上面的区分开
function MovieClipAnim:lSetOpacity(o)
    if self._mc then
        self._opaction = o
        self._mc:setOpacity(o)
    end
end

function MovieClipAnim:setScale(scale)
    if self._node then
        self._node:setScale(scale * mcScale)
    end
end


function MovieClipAnim:setScaleX(scale)
    if self._node then
        self._node:setScaleX(scale * mcScale)
    end
end

function MovieClipAnim:getScale()
    if self._node then
        return self._node:getScaleX() / mcScale
    else
        return 1.0
    end
end

function MovieClipAnim:setColor(color)
    if self._node then
        self._node:setColor(color)
    end
end

function MovieClipAnim:setBlendFunc(func)
    if self._node then
        self._node:setBlendFunc(func)
    end
end

function MovieClipAnim:stopAllActions()
    if self._node then
        self._node:stopAllActions()
    end
end

function MovieClipAnim:stopAllActions()
    if self._node then
        self._node:stopAllActions()
    end
end

function MovieClipAnim:runAction(action)
    if self._node then
        self._node:runAction(action)
    end
end

function MovieClipAnim:setBrightness(value)
    if self._node then
        self._node:setBrightness(value)
    end
end

function MovieClipAnim:setHue(value)
    if self._node then
        self._node:setHue(value)
    end
end

function MovieClipAnim:setSaturation(value)
    if self._node then
        self._node:setSaturation(value)
    end
end

function MovieClipAnim:setContrast(value)
    if self._node then
        self._node:setContrast(value)
    end
end

function MovieClipAnim:setLocalZOrder(value)
    if self._node then
        self._node:setLocalZOrder(value)
    end
end

function MovieClipAnim:setCM(...)
    if self._node then
        self._node:setCM(...)
    end 
end

function MovieClipAnim:setCMex(...)
    if self._node then
        self._node:setCMex(...)
    end 
end

function MovieClipAnim:setGLProgramState(...)
    if self._node then
        self._node:setGLProgramState(...)
    end 
end

function MovieClipAnim:setUseCustomShader(...)
    if self._node then
        self._node:setUseCustomShader(...)
    end 
end

function MovieClipAnim.dtor()
    AnimAP = nil
    cc = nil
    mcMgr = nil
    mcScale = nil
    motionName = nil
    MovieClipAnim = nil
    defa = nil
end

return MovieClipAnim