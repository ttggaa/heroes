--[[
    Filename:    SpriteFrameAnim.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-02-02 14:36:44
    Description: File description
--]]
-- 序列帧动画
local SpriteFrameAnim = class("SpriteFrameAnim")
local sfResMgr = SpriteFrameResManager:getInstance()
local cc = cc
local AnimAP = require "base.anim.AnimAP"

-- 只需要不带后缀的文件名, 会从asset/role/路径下找plist和png文件
-- cacheColor 是否采用换色 true / false
function SpriteFrameAnim:ctor(parentNode, filename, callback, cacheColor, maxW, maxH)
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
    self._callback = callback
    self._parentNode = parentNode
    self._filename = filename
    self._cacheColor = cacheColor
    self._maxW = maxW
    self._maxH = maxH

    self:setCache(sfResMgr:getCache(filename))
    if self._cache == nil then
        sfResMgr:loadRes(filename, cacheColor, function (cache)
            self:setCache(cache)
            self:initSprite()
        end)   
    else
        self:initSprite()
    end

    self._anim = true
    self.visible = true
end

function SpriteFrameAnim:changeRes(resname, cacheColor)
    self:setCache(sfResMgr:getCache(resname), cacheColor)
end

function SpriteFrameAnim:setCache(cache, cacheColor)
    self._cache = cache
    if self._cache ~= nil then
        if cacheColor then
            self._cacheColor = cacheColor
        end
        if self._cacheColor then
            self._cacheColor = self._cache.cacheColor
        end
        self._motion = 1
        self._maxFrame = #self._cache[self._motion]
        self._curFrame = 1
        self._invTick = 0.05
        self._loop = true
        self._width = self._cache.width
        self._height = self._cache.height
        local ap = AnimAP[self._filename]
        if ap then
            self._ap = ap
            if self._ap[3] == nil then
                self._ap[3] = self._ap[1]
            end
        else
            self._ap = {[1] = {0, self._height * 0.5}, [2] = {0, self._height}, [3] = {0, self._height * 0.5}}
        end
        self.shadowFrame = self._cache.shadow

        self._motionFrame = {}
        for i = 1, 7 do
            if self._cache[i] then
                self._motionFrame[i] = #self._cache[i]
            end
        end
    end
end

function SpriteFrameAnim:getMotionFrame()
    return self._motionFrame
end

function SpriteFrameAnim:initSprite()
    if self._cache == nil then return end
    local sf = self:getCurSpriteFrame()
    self._sp = cc.Sprite:createWithSpriteFrame(sf)
    
    self._sp:registerScriptHandler(function (state)
        if state == "enter" then
            sfResMgr:referenceAdd(self._filename)
        elseif state == "exit" then
            self:stop()
            sfResMgr:referenceDec(self._filename)
        end
    end)
    if self._maxW and self._maxH then
        local w, h = self:getSize()
        local wscale = self._maxW / w
        local hscale = self._maxH / h
        if wscale > 1 then wscale = 1 end
        if hscale > 1 then hscale = 1 end
        if wscale < 1 or hscale < 1 then
            if wscale > hscale then
                self._sp:setScale(wscale)
            else
                self._sp:setScale(hscale)
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

function SpriteFrameAnim:setPosition(x, y)
    if self._sp then
        self._sp:setPosition(x, y)
    end
end

function SpriteFrameAnim:getSize()
    return self._width, self._height
end

function SpriteFrameAnim:getAp(index)
    return self._ap[index]
end

function SpriteFrameAnim:addTo(parentNode)
    if self._quit then
        sfResMgr:referenceDec(self._filename)
        return false
    end
    if parentNode then
        parentNode:addChild(self._sp)
        if self._set then
            self._set:removeFromParent()
        end
        self._parentNode = parentNode
    end
    return true
end

function SpriteFrameAnim:getCurSpriteFrame()
    self._CurSpriteFrame = self._cache[self._motion][self._curFrame]
    if self._cacheColor then
        return self._CurSpriteFrame.sf1
    else
        return self._CurSpriteFrame.sf
    end
end
-- 提供两种方式播放
-- update, logic每帧调用
-- play, 会自行update
function SpriteFrameAnim:play()
    self._updateId = ScheduleMgr:regSchedule(50, self, function(self, dt)
        self:autoUpdate()
    end)
end

function SpriteFrameAnim:stop()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
end

function SpriteFrameAnim:autoUpdate()
    self:update(socket.gettime())
end

function SpriteFrameAnim:pause()
    self._anim = false
end

function SpriteFrameAnim:resume()
    self._anim = true
end

function SpriteFrameAnim:update(tick)
    if self._cache ~= nil then
        if self._nextTick == nil then
            self._nextTick = tick + self._invTick
        end 
        if self._anim and tick > self._nextTick then
            local frame = math.modf((tick - self._nextTick) / self._invTick)
            self._nextTick = self._nextTick + self._invTick * (frame + 1)
            self._curFrame = self._curFrame + frame + 1
            if self._curFrame > self._maxFrame then
                if self._endCallback then
                    self._endCallback()
                    self._endCallback = nil
                end
                if self._loop then
                    self._curFrame = math.fmod(self._curFrame, self._maxFrame)
                    if self._curFrame == 0 then
                        self._curFrame = 1
                    end
                else
                    self._anim = false
                    self._curFrame = self._maxFrame
                    self:changeFrame()
                    return
                end
            end
            self:changeFrame()
        end
    end
end

function SpriteFrameAnim:changeMotion(motion, tick, callback, noloop, inv)
    self._endCallback = callback
    if self._cache == nil then
        return
    end
    if self._cache[motion] == nil then
        return
    end
    if tick == nil then
        self._nextTick = socket.gettime() + self._invTick
    else
        self._nextTick = tick + self._invTick
    end
    self._motion = motion
    self._maxFrame = #self._cache[self._motion]
    self._curFrame = 1
    if motion == 4 then
        self._anim = true
    end
    self._loop = not noloop

    if inv then
        self._invTick = inv
    else
        self._invTick = 0.05
    end
    self:changeFrame()
end

function SpriteFrameAnim:getMotion()
    return self._motion
end


function SpriteFrameAnim:changeFrame()
    local sf = self:getCurSpriteFrame()
    if sf then
        self._sp:setSpriteFrame(sf)
    end
end

function SpriteFrameAnim:clear()
    self._parentNode = nil
    self._cache = nil
    if self._sp then
        self._sp:removeFromParent(true)
        self._sp = nil
    end
    self._endCallback = nil
    self._motionFrame = nil
    self._CurSpriteFrame = nil
    self._apNone = nil
    self._callback = nil
    delete(self)
end

function SpriteFrameAnim:setVisible(visible)
    if self._sp then
        self.visible = visible
        self._sp:setVisible(visible)
    end
end

function SpriteFrameAnim:setOpacity(o)
    if self._sp then
        self._sp:setOpacity(o)
    end
end

function SpriteFrameAnim:setScale(scale)
    if self._sp then
        self._sp:setScale(scale)
    end
end

function SpriteFrameAnim:getScale()
    return self._sp:getScaleX()
end

function SpriteFrameAnim:setScaleX(scale)
    if self._sp then
        self._sp:setScaleX(scale)
    end
end

function SpriteFrameAnim:setColor(color)
    if self._sp then
        self._sp:setColor(color)
    end
end

function SpriteFrameAnim:setBlendFunc(func)
    if self._sp then
        self._sp:setBlendFunc(func)
    end
end

function SpriteFrameAnim:stopAllActions()
    if self._sp then
        self._sp:stopAllActions()
    end
end

function SpriteFrameAnim:stopAllActions()
    if self._sp then
        self._sp:stopAllActions()
    end
end

function SpriteFrameAnim:runAction(action)
    if self._sp then
        self._sp:runAction(action)
    end
end

function SpriteFrameAnim:setBrightness(value)
    if self._sp then
        self._sp:setBrightness(value)
    end
end

function SpriteFrameAnim:setHue(value)
    if self._sp then
        self._sp:setHue(value)
    end
end

function SpriteFrameAnim:Saturation(value)
    if self._sp then
        self._sp:Saturation(value)
    end
end

function SpriteFrameAnim:setContrast(value)
    if self._sp then
        self._sp:setContrast(value)
    end
end

function SpriteFrameAnim:setLocalZOrder(value)
    if self._sp then
        self._sp:setLocalZOrder(value)
    end
end

function SpriteFrameAnim:setName(name)
    if self._sp then
        self._sp:setName(name)
    end
end

function SpriteFrameAnim:convertToWorldSpace(point)
    if self._sp then
        return self._sp:convertToWorldSpace(point)
    end
    return cc.p(0, 0)
end

function SpriteFrameAnim:getContentSize()
    if self._sp then
        return self._sp:getContentSize()
    end
    return cc.size(0, 0)
end


function SpriteFrameAnim:setAnchorPoint(x, y)
    if self._sp then
        self._sp:setAnchorPoint(x, y)
    end
end

function SpriteFrameAnim:setFlipX(flipx)
    if self._sp then
        self._sp:setFlipX(flipx)
    end
end

return SpriteFrameAnim
