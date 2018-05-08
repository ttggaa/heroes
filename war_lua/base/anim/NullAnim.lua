--[[
    Filename:    NullAnim.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-06-28 11:09:16
    Description: File description
--]]

-- 没有资源的人物用到的抽象类
local NullAnim = class("NullAnim")

function NullAnim:ctor(parentNode, filename, callback, changeColor, maxW, maxH)
	self._width = 100
    self._height = 100
    self._ap = {
    	{0, 50},
    	{0, 100},
    	{0, 50},
	}
	self.visible = true
    if parentNode then
    	self._sp = cc.Node:create()
    	parentNode:addChild(self._sp)
    	if callback then
    		callback(self)
    	end
    end
end

function NullAnim:changeRes(resname, changeColor)

end

function NullAnim:hasDie()
    return true
end


function NullAnim:getMotionFrame()
    return 0
end

function NullAnim:setPosition(x, y)
    if self._sp then
        self._sp:setPosition(x, y)
    end
end

function NullAnim:getSize()
    return self._width, self._height
end

function NullAnim:getAp(index)
    return self._ap[index]
end

function NullAnim:play()

end

function NullAnim:stop()

end

function NullAnim:autoUpdate()

end

function NullAnim:pause()

end

function NullAnim:resume()

end

function NullAnim:freeze()

end

function NullAnim:unfreeze()

end

function NullAnim:stopAnim()

end

function NullAnim:update(tick)

end

function NullAnim:changeMotion(motion, tick, callback, noloop, inv)

end

function NullAnim:getMotion()
    return 1
end

function NullAnim:changeFrame()

end

function NullAnim:clear()
    self._parentNode = nil
    if self._sp then
        self._sp:removeFromParent(true)
        self._sp = nil
    end
    self._apNone = nil
    delete(self)
end

function NullAnim:setVisible(visible)
    if self._sp then
        self.visible = visible
        self._sp:setVisible(visible)
    end
end

function NullAnim:setOpacity(o)
    if self._sp then
        self._sp:setOpacity(o)
    end
end

function NullAnim:setScale(scale)
    if self._sp then
        self._sp:setScale(scale)
    end
end

function NullAnim:getScale()
    if self._sp then
        return self._sp:getScaleX()
    else
        return 1.0
    end
end

function NullAnim:setScaleX(scale)
    if self._sp then
        self._sp:setScaleX(scale)
    end
end

function NullAnim:setColor(color)
    if self._sp then
        self._sp:setColor(color)
    end
end

function NullAnim:setBlendFunc(func)
    if self._sp then
        self._sp:setBlendFunc(func)
    end
end

function NullAnim:stopAllActions()
    if self._sp then
        self._sp:stopAllActions()
    end
end

function NullAnim:stopAllActions()
    if self._sp then
        self._sp:stopAllActions()
    end
end

function NullAnim:runAction(action)
    if self._sp then
        self._sp:runAction(action)
    end
end

function NullAnim:setBrightness(value)
    if self._sp then
        self._sp:setBrightness(value)
    end
end

function NullAnim:setHue(value)
    if self._sp then
        self._sp:setHue(value)
    end
end

function NullAnim:Saturation(value)
    if self._sp then
        self._sp:Saturation(value)
    end
end

function NullAnim:setContrast(value)
    if self._sp then
        self._sp:setContrast(value)
    end
end

function NullAnim:setLocalZOrder(value)
    if self._sp then
        self._sp:setLocalZOrder(value)
    end
end

function NullAnim:setName(name)
    if self._sp then
        self._sp:setName(name)
    end
end

function NullAnim:convertToWorldSpace(point)
    if self._sp then
        return self._sp:convertToWorldSpace(point)
    end
    return cc.p(0, 0)
end

function NullAnim:getContentSize()
    if self._sp then
        return self._sp:getContentSize()
    end
    return cc.size(0, 0)
end


function NullAnim:setAnchorPoint(x, y)
    if self._sp then
        self._sp:setAnchorPoint(x, y)
    end
end

function NullAnim:setFlipX(flipx)
    if self._sp then
        self._sp:setFlipX(flipx)
    end
end

function NullAnim:setCM(...)
    if self._sp then
        self._sp:setCM(...)
    end
end


return NullAnim
