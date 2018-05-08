--[[
    Filename:    IntanceMcAnimNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-11 18:46:38
    Description: File description
--]]

local IntanceMcAnimNode = class("IntanceMcAnimNode",BaseMvcs, function ()
        return  cc.Node:create() 
    end)
local mcMgr = MovieClipManager:getInstance()
local KEY_MOTION_FIRST_NAME = "Move_Clip_"

function IntanceMcAnimNode:ctor(motionList , filename, callback, width, height, inQueue, inRatio, cacheAllMotion)
    IntanceMcAnimNode.super.ctor(self)
    self._filename = filename
    self._motion = 1
    self._cache = {}
    self._standByQue = {}
    for k,v in pairs(inQueue) do
        for k1,v1 in pairs(motionList) do
            if v1 == v then 
                table.insert(self._standByQue, k)
            end
        end
    end
    self._standByRatio = inRatio
    self._standByIndex = 1
    self._width = width
    self._height = height
    self._motionList = motionList
    self._motionFrame = {}

    if cacheAllMotion == nil then 
        self._cacheAllMotion = true
    else
        self._cacheAllMotion = cacheAllMotion
    end
    if mcMgr:isResLoaded(filename) then
        print("test loadRes111",filename,os.clock())
        self:initMovieClip(callback)
    else
        print("test loadRes",os.clock())
        mcMgr:loadRes(filename, function ()
            if self.initMovieClip then
                self:initMovieClip(callback)
            end
        end)
    end
    self.visible = true

    local setHoldUpLocalZOrder = self.setLocalZOrder
    self.setHoldUpLocalZOrder = setHoldUpLocalZOrder
    self.setLocalZOrder = self.setAdjustLocalZOrder
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

function IntanceMcAnimNode:initMovieClip(callback)
    print("test initMovieClip",os.clock())
    self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)
    if self._cacheAllMotion then
        for i = 1, #self._motionList do
            self._cache[i] = mcMgr:createMovieClip(self._motionList[i] .. "_" .. self._filename)
            if self._cache[i] then
                self._motionFrame[i] = self._cache[i]:getTotalFrames()
                self._cache[i]:stop()
                -- self._cache[i]:retain()
                self:addChild(self._cache[i])
                self._cache[i]:setCascadeColorEnabled(true)
                self._cache[i]:setCascadeOpacityEnabled(true)
                self._cache[i]:setName(KEY_MOTION_FIRST_NAME .. self._motionList[i])
                self._cache[i]:setTag(i)
                for k = 1, #self._cache[i]:getChildren() do
                    self._cache[i]:getChildren()[k]:setCascadeColorEnabled(true)
                    self._cache[i]:getChildren()[k]:setCascadeOpacityEnabled(true)
                end
                self._cache[i]:setVisible(false)
            end
        end
    end
    self._mc = nil
    -- self:changeMotion(self._motion)
    if self._cacheAllMotion then
        self:runStandBy()
    end
    if callback then
        callback(self)
    end
end

function IntanceMcAnimNode:getMotionFrame()
    return self._motionFrame
end


function IntanceMcAnimNode:clear()
    self._mc = nil
    -- if self._cache then
    --     for k, v in pairs(self._cache) do
    --         v:release()
    --     end
    -- end
    if self then
        self:removeFromParent(true)
        self = nil
    end
end



function IntanceMcAnimNode:gotoAndPlay(inFrame)
    if self._mc then
        self._mc:gotoAndPlay(inFrame)
    end
end

function IntanceMcAnimNode:play()
    if self._mc then
        self._mc:play()
    end
end

function IntanceMcAnimNode:isPlaying()
    if self._mc then
        return self._mc:isPlaying()
    end
end

function IntanceMcAnimNode:pause()
    if self._mc then
        self._mc:stop()
    end
end

function IntanceMcAnimNode:stop()
    if self._mc then
        self._mc:stop()
    end
end


function IntanceMcAnimNode:getCurrentFrame()
    if self._mc then
        return self._mc:getCurrentFrame()
    end
    return 0
end

function IntanceMcAnimNode:getTotalFrames()
    if self._mc then
        return self._mc:getTotalFrames()
    end
    return 0
end

function IntanceMcAnimNode:setPlaySpeed(speed)
    if self._mc then
        self._mc:setPlaySpeed(0.05 * speed)
    end
end



function IntanceMcAnimNode:clearCallbacks()
    if self._mc then
        self._mc:clearCallbacks()
    end
end

function IntanceMcAnimNode:resume()
    if self._mc then
        self._mc:play()
    end
end

function IntanceMcAnimNode:changeMotion(motion, callback, noloop)
    if self._cacheAllMotion and  self._cache[motion] == nil then return end
    if self._cache[motion] == nil then 
        self._cache[motion] = mcMgr:createMovieClip(self._motionList[motion] .. "_" .. self._filename)
        self._motionFrame[motion] = self._cache[motion]:getTotalFrames()
        self._cache[motion]:stop()
        -- self._cache[i]:retain()
        self:addChild(self._cache[motion])
        self._cache[motion]:setCascadeColorEnabled(true)
        self._cache[motion]:setCascadeOpacityEnabled(true)
        self._cache[motion]:setName(KEY_MOTION_FIRST_NAME .. self._motionList[motion])
        self._cache[motion]:setTag(motion)
        for k = 1, #self._cache[motion]:getChildren() do
            self._cache[motion]:getChildren()[k]:setCascadeColorEnabled(true)
            self._cache[motion]:getChildren()[k]:setCascadeOpacityEnabled(true)
        end
        self._cache[motion]:setVisible(false)
    end
    if self._mc then
        self._mc:stop()
        self._mc:clearCallbacks()
        -- self._mc:removeFromParent()
        self._mc:setVisible(false)
        self._mc = nil
    end
    self._motion = motion
    if self._cache then
        self._mc = self._cache[self._motion]
        if self._mc then
            -- self:addChild(self._mc)
            self._mc:setVisible(true)
            self._mc:gotoAndPlay(1)
            self._mc:clearCallbacks()
            self._mc:addEndCallback(function (_, sender)
                if noloop then
                    sender:clearCallbacks()
                    sender:stop()
                end
                if callback then
                    callback(sender)
                end
            end)
        end
    end
end

function IntanceMcAnimNode:runByName(inName, callback, noloop)
    if not self._motionList then
        return
    end
    self._standByIndex = 1
    local tempMcIndex = 0
    for k, v in pairs(self._motionList) do
        if v == inName then 
            tempMcIndex = k
        end
    end
    if tempMcIndex > 0 then
        self:changeMotion(tempMcIndex, callback, noloop)
    end
end

function IntanceMcAnimNode:runStandBy()
    if self._mc ~= nil then 
        self._mc:stop()
        self._mc:clearCallbacks()
        -- self._mc:removeFromParent()
        self._mc:setVisible(false)
        self._mc = nil
    end

    local queName = self._standByQue[self._standByIndex]
    if self._cache[queName] == nil then
        self:changeMotion(self._motion)
        return
    end
    self._mc = self._cache[queName] 
    local tempRatio = self._standByRatio[self._standByIndex]
    self._mc.runTime = 0
    if type(tempRatio) == "number" then 
        self._mc.maxTime = tempRatio
    elseif type(tempRatio) == "table" then 
        self._mc.maxTime = GRandom(tempRatio[1], tempRatio[2])
    else
        self._mc.maxTime = 1
    end


    self._motion = self._standByQue[self._standByIndex]
    self._mc = self._cache[self._motion]
    self._mc:gotoAndPlay(1)
    -- self:addChild(self._mc)
    self._mc:setVisible(true)
    self._mc:addEndCallback(function (_, sender)
        sender.runTime = sender.runTime + 1
        if sender.runTime == sender.maxTime then
            if self._standByIndex + 1 > #self._standByQue then 
                self._standByIndex = 1
            else
                self._standByIndex = self._standByIndex + 1
            end
            self:runStandBy()
        end
    end)
end



function IntanceMcAnimNode:getMotion()
    return self._motion
end

-- function IntanceMcAnimNode:setPosition(x, y)
--     if self then
--         self:setPosition(x, y)
--     end
-- end

-- function IntanceMcAnimNode:setVisible(visible)
--     if self then
--         self.visible = visible
--         self:setVisible(visible)
--     end
-- end

-- function IntanceMcAnimNode:setOpacity(o)
--     if self then
--         self:setOpacity(o)
--     end
-- end

-- function IntanceMcAnimNode:setScale(scale)
--     if self then
--         self:setScale(scale * 2)
--     end
-- end

-- function IntanceMcAnimNode:getScale()
--     return self:getScaleX() * 0.5
-- end

function IntanceMcAnimNode:setFlipX(inFlip)
    if inFlip == false  then 
        self:setScaleX(math.abs(self:getScaleX()))
    else
        if self:getScaleX() > 0 then 
            self:setScaleX(self:getScaleX() * -1)
        end
    end
end


-- function IntanceMcAnimNode:setColor(color)
--     if self then
--         self:setColor(color)
--     end
-- end

-- function IntanceMcAnimNode:setBlendFunc(func)
--     if self then
--         self:setBlendFunc(func)
--     end
-- end

-- function IntanceMcAnimNode:stopAllActions()
--     if self then
--         self:stopAllActions()
--     end
-- end

-- function IntanceMcAnimNode:stopAllActions()
--     if self then
--         self:stopAllActions()
--     end
-- end

-- function IntanceMcAnimNode:runAction(action)
--     if self then
--         self:runAction(action)
--     end
-- end

-- function IntanceMcAnimNode:setBrightness(value)
--     if self then
--         self:setBrightness(value)
--     end
-- end

-- function IntanceMcAnimNode:setHue(value)
--     if self then
--         self:setHue(value)
--     end
-- end

-- function IntanceMcAnimNode:Saturation(value)
--     if self then
--         self:Saturation(value)
--     end
-- end

-- function IntanceMcAnimNode:setContrast(value)
--     if self then
--         self:setContrast(value)
--     end
-- end

function IntanceMcAnimNode:setAdjustLocalZOrder(value)
    local zorder = self:getLocalZOrder()
    if zorder == value then 
        zorder = zorder + 1
        self:setHoldUpLocalZOrder(zorder)
        self:setHoldUpLocalZOrder(value)
    else
        self:setHoldUpLocalZOrder(value)
    end
end

return IntanceMcAnimNode