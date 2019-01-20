--[[
    Filename:    GlobalScrollLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-02-01 21:22:33
    Description: File description
--]]

local GlobalScrollLayer = class("GlobalScrollLayer",BaseMvcs, cc.Layer)

--[[
 @desc  创建
 @param inParent 上层界面
 @return 
--]]
function GlobalScrollLayer:ctor(inParent, inLayerNode)
    GlobalScrollLayer.super.ctor(self)
    self._touchMoveX = 0
    self._touchMoveY = 0
    self._touchDown = false

    self._lockTouch = false

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            self:onExit()
        elseif eventType == "enter" then 
            self:onEnter()
        end
    end)

    self._touchScale = self:getInitScale()
    self._nowScale = self:getInitScale()
    self._sceneLayer = cc.Layer:create()
    self._sceneLayer:setAnchorPoint(cc.p(0.5,0.5))
    self._sceneLayer:setName("sceneLayer")
    self:addChild(self._sceneLayer)
    self:initEvent()

end

function GlobalScrollLayer:onExit()
    if self.__depleteSchedule ~= nil then 
        ScheduleMgr:unregSchedule(self.__depleteSchedule)
        self.__depleteSchedule = nil
    end
    if self._animId ~= nil then 
        ScheduleMgr:unregSchedule(self._animId)
        self._animId = nil
    end    
    
    -- ScheduleMgr:cleanMyselfDelayCall(self)
    UIUtils:reloadLuaFile("global.GlobalScrollLayer")
end

function GlobalScrollLayer:onEnter()
    --  监测touch
    self.__depleteSchedule = ScheduleMgr:regSchedule(1, self, function()
        self:update()
    end)
end



function GlobalScrollLayer:initEvent()
    -- 注册多点触摸
    -- local dispatcher = cc.Director:getInstance():getEventDispatcher()
    -- local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:registerScriptHandler(function (touch, event)
    --     return self:onTouchBegan(touch, event)
    -- end, cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener:registerScriptHandler(function (touch, event)
    --     self:onTouchMoved(touch, event)
    -- end, cc.Handler.EVENT_TOUCH_MOVED)
    -- listener:registerScriptHandler(function (touch, event)
    --     self:onTouchEnded(touch, event)
    -- end, cc.Handler.EVENT_TOUCH_ENDED)
    -- dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    -- self._touchDispatcher = dispatcher

    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function (touches, event)
        self:onTouchesBegan(touches, event)
    end, cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(function (touches, event)
        self:onTouchesMoved(touches, event)
    end, cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(function (touches, event)
        self:onTouchesEnded(touches, event)
    end, cc.Handler.EVENT_TOUCHES_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    -- dispatcher:setSwallowTouches(false)
    self._touchDispatcher = dispatcher

    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function (event)
        return self:onMouseScroll(event)
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    -- listener:setSwallowTouches(false)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end


function GlobalScrollLayer:unLockTouch()
    if self._parentView ~= nil and self._parentView.visible == false then 
        -- local traceback = string.split(debug.traceback("", 2), "\n")
        -- local tracde = traceback[5]
        -- if not tracde then 
        --     tracde = traceback[3]
        -- end
        -- if tracde then 
        --     print("tracde=", string.trim(tracde))
        --     print(abc.abc.abc)
        --     ApiUtils.playcrab_lua_error("GlobalScrollLayer unLockTouch=====", string.trim(tracde))
        -- end
        return
    end
    self._lockTouch = false
    self._touchDispatcher:resumeEventListenersForTarget(self,false)
end

function GlobalScrollLayer:lockTouch()
    self._lockTouch = true
    self._touchDispatcher:pauseEventListenersForTarget(self,false)
end

function GlobalScrollLayer:getLockTouch()
    return self._lockTouch
end
function GlobalScrollLayer:updateTouch()
    -- print("self._touche1Down==",self._touche1Down,self._touche2Down)
    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        self:updateScenePos(self._touchMoveX, self._touchMoveY, true)
    elseif self._touche1Down and self._touche2Down then
        local scale = self._touchScale--self._sceneLayer:getScale() + (self._touchScale - self._sceneLayer:getScale()) * 0.7
        self._sceneLayer:setScale(scale)
        self:onSceneScale(scale)
        self._touchesBeganPositionX = self._touchesBeganPositionX or 0
        self._touchesBeganPositionY = self._touchesBeganPositionY or 0
        local nx = self._touchesBeganPositionX * scale
        local ny = self._touchesBeganPositionY * scale
        self:updateScenePos(nx, ny)
        self:listenScale(scale)
    end
end



function GlobalScrollLayer:update(dt)
    -- if self._touchDown then 
     self:updateTouch()
    -- end
end

function GlobalScrollLayer:onMouseScroll(event)
    if self._lockTouch then return end
    if not self:onMouseScrollEx() then return end 
    self._touchesBeganScale = self._touchScale
    self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
    self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    local scale = self._touchesBeganScale + event:getScrollY() * 0.05
    if self:getAdjustMapScale() then
        scale = math.min(self:getMaxScale(), math.max(self:getMinScale(), scale)) 
    end
    self._sceneLayer:setScale(scale)
    self:onSceneScale(scale)
    self._touchScale = scale
    local nx = self._touchesBeganPositionX * scale
    local ny = self._touchesBeganPositionY * scale
    self:updateScenePos(nx, ny)
    self:listenScale(scale)
    return true
end


function GlobalScrollLayer:onTouchesBegan(touches)
    if self._lockTouch then return false end
    self._touchesBeganDistance = 0
    self._touchesMuliDown = false
    local count = #touches
    for i = 1, count do
        if touches[i]:getId() == 0 then
            self._touche1Down = true
            self._touche1X = touches[i]:getLocation().x
            self._touche1Y = touches[i]:getLocation().y
        elseif touches[i]:getId() == 1 then
            self._touche2Down = true
            self._touche2X = touches[i]:getLocation().x
            self._touche2Y = touches[i]:getLocation().y
        end
    end
    

    if not self:onTouchesBeganEx() then return end 

    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        local touchX ,touchY = 0, 0
        if self._touche1Down then
            self._touchBeganScenePositionX = self._sceneLayer:getPositionX()
            self._touchBeganScenePositionY = self._sceneLayer:getPositionY()
            self._touchBeganPositionX = self._touche1X
            self._touchBeganPositionY = self._touche1Y

            -- self:onTouchMoved(self._touche1X, self._touche1Y)
            touchX, touchY= self._touche1X, self._touche1Y
        elseif self._touche2Down then
            self._touchBeganScenePositionX = self._sceneLayer:getPositionX()
            self._touchBeganScenePositionY = self._sceneLayer:getPositionY()
            self._touchBeganPositionX = self._touche2X
            self._touchBeganPositionY = self._touche2Y
            touchX, touchY= self._touche2X, self._touche2Y
        end
        if self:checkTouchBegan(touchX, touchY) then return end 
        self:onTouchMoved(touchX, touchY)
        self._touchesMuliDown = false
    elseif self._touche1Down and self._touche2Down then
        self._touchesBeganDistance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        self._touchesBeganScale = self._sceneLayer:getScale()
        self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
        self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
        self._touchesMuliDown = true
    end 
end

function GlobalScrollLayer:distance(pt1x, pt1y, pt2x, pt2y)
    local dx = math.abs(pt2x - pt1x)
    local dy = math.abs(pt2y - pt1y)
    return math.sqrt(dx * dx + dy * dy)
end

function GlobalScrollLayer:onTouchesMoved(touches)
    local count = #touches
    if self._touche1X == nil then 
        return
    end

    for i = 1, count do
        if touches[i]:getId() == 0 then
            if math.abs(touches[i]:getLocation().x - self._touche1X) > 5 or math.abs(touches[i]:getLocation().y - self._touche1Y) > 5 then
                self._toucheRole = false
            end
            self._touche1X = touches[i]:getLocation().x
            self._touche1Y = touches[i]:getLocation().y
        elseif touches[i]:getId() == 1 then
            self._toucheRole = false
            self._touche2X = touches[i]:getLocation().x
            self._touche2Y = touches[i]:getLocation().y
        end
    end

    if not self:onTouchesMovedEx() then return end 

    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        if self._touche1Down then
            self:onTouchMoved(self._touche1X, self._touche1Y, event)
        elseif self._touche2Down then
            self:onTouchMoved(self._touche2X, self._touche2Y, event)
        end
    elseif self._touche1Down and self._touche2Down then
        if not self:onMouseScrollEx() then return end 
        local distance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        local scale = self._touchesBeganScale * (distance / self._touchesBeganDistance)
        scale = math.min(self:getMaxScale(), math.max(self:getMinScale(), scale)) 
        self._touchScale = scale
    end
end

function GlobalScrollLayer:onTouchMoved(x, y)   
    -- 地图移动
    local lastPtx = self._touchBeganPositionX
    local lastPty = self._touchBeganPositionY
    local nowPtx = x
    local nowPty = y
    local dx = nowPtx - lastPtx
    local dy = nowPty - lastPty
    local nx = self._touchBeganScenePositionX + dx
    local ny = self._touchBeganScenePositionY + dy
    self._touchMoveX = nx
    self._touchMoveY = ny
end

function GlobalScrollLayer:onTouchesEnded(touches)
    local count = #touches

    for i = 1, count do
        if touches[i]:getId() == 0 then
            self._touche1Down = false
        elseif touches[i]:getId() == 1 then
            self._touche2Down = false
        end
    end

    if self._touchesMuliDown == false then
        local touchX ,touchY = touches[1]:getLocation().x, touches[1]:getLocation().y
        if self:checkTouchEnd(touchX, touchY) then return end
    end

    -- 下面暂时无用？
    if not self:onTouchesEndedEx() then return end 
    
    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        local touchX ,touchY = 0, 0
        if self._touche1Down then
            touchX ,touchY = self._touche1X ,self._touche1Y
        elseif self._touche2Down then
            touchX ,touchY = self._touche2X ,self._touche2Y
        end        

        if self._touche1Down then
            self._touchBeganScenePositionX = self._sceneLayer:getPositionX()
            self._touchBeganScenePositionY = self._sceneLayer:getPositionY()
            self._touchBeganPositionX = self._touche1X
            self._touchBeganPositionY = self._touche1Y
            touchX ,touchY = self._touche1X ,self._touche1Y
        elseif self._touche2Down then
            self._touchBeganScenePositionX = self._sceneLayer:getPositionX()
            self._touchBeganScenePositionY = self._sceneLayer:getPositionY()
            self._touchBeganPositionX = self._touche2X
            self._touchBeganPositionY = self._touche2Y
            touchX ,touchY = self._touche2X ,self._touche2Y
        end
        self:onTouchMoved(touchX ,touchY)
    elseif self._touche1Down and self._touche2Down then
        self._touchesBeganDistance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        self._touchesBeganScale = self._sceneLayer:getScale()
        self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
        self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    end
end

-- function GlobalScrollLayer:onTouchBegan(touch)
--     if self:checkTouchBegan() == true then 
--         return false
--     end
--     self._touchDown = true
--     self._touchBeganPositionX = touch:getLocation().x
--     self._touchBeganPositionY = touch:getLocation().y

--     self._touchBeganScenePositionX = self._sceneLayer:getPositionX()
--     self._touchBeganScenePositionY = self._sceneLayer:getPositionY()

--     self:touchMoved(self._touchBeganPositionX, self._touchBeganPositionY)
--     return true
-- end

-- function GlobalScrollLayer:onTouchMoved(touch)
--     local x, y = touch:getLocation().x, touch:getLocation().y
--     self:touchMoved(x, y)
-- end

-- function GlobalScrollLayer:touchMoved(x, y)
--     -- 地图移动
--     local lastPtx = self._touchBeganPositionX
--     local lastPty = self._touchBeganPositionY
--     local dx = x - lastPtx
--     local dy = y - lastPty
--     local nx = self._touchBeganScenePositionX + dx
--     local ny = self._touchBeganScenePositionY + dy
--     self._touchMoveX = nx
--     self._touchMoveY = ny
-- end

-- function GlobalScrollLayer:onTouchEnded(touch)
--     self._touchBeganScenePositionX = self._sceneLayer:getPositionX()
--     self._touchBeganScenePositionY = self._sceneLayer:getPositionY()
--     self._touchDown = false
--     if math.abs(self._touchBeganPositionX - touch:getLocation().x) <= 10
--         or math.abs(self._touchBeganPositionY- touch:getLocation().y) <= 10 then 
--         if self:checkTouch() == true then
--             return true
--         end
--     end
--     self._touchBeganPositionX = touch:getLocation().x
--     self._touchBeganPositionY = touch:getLocation().y
--     self:touchMoved(touch:getLocation().x, touch:getLocation().y)
-- end

-- function GlobalScrollLayer:distance(pt1x, pt1y, pt2x, pt2y)
--     local dx = math.abs(pt2x - pt1x)
--     local dy = math.abs(pt2y - pt1y)
--     return math.sqrt(dx * dx + dy * dy)
-- end

function GlobalScrollLayer:onSceneScale(scale)
    local s = scale / self:getMinScale()
    if s ~= self._nowScale then
        self._nowScale = s
        -- logic:onSceneScale()
    end
end

function GlobalScrollLayer:adjustPos(x, y)
    local nx = x
    local ny = y


    -- local ddx
    -- local kw = MAX_SCREEN_WIDTH / 960
    -- local kh = (1 + (self:getMinScale() - 1) * 3)
    
    local minX = (MAX_SCREEN_WIDTH - self:getMaxScrollWidthPixel()) * self._sceneLayer:getScaleX() 
    local maxX = 0
    local minY = (MAX_SCREEN_HEIGHT - self:getMaxScrollHeightPixel()) * self._sceneLayer:getScaleY()
    local maxY = 0

    local dx = (self._sceneLayer:getScaleX() - 1.0) * 0.5 * MAX_SCREEN_WIDTH 
    local dy = (self._sceneLayer:getScaleY() - 1.0) * 0.5 * MAX_SCREEN_HEIGHT


    minX = minX - dx + (SCREEN_X_OFFSET * (self._sceneLayer:getScaleX() - 1.0))
    minY = minY - dy
        
    maxX = maxX + dx + (SCREEN_X_OFFSET * (self._sceneLayer:getScaleX() - 1.0))
    maxY = maxY + dy
    if nx > maxX then
      nx = maxX
    end
    if nx < minX then
       nx = minX 
    end
    if ny > maxY then
        ny = maxY
    end
    if ny < minY then
       ny = minY
    end
	if self._settingData and self._settingData.isCenter and ADOPT_IPHONEX then
		nx = 0
		ny = 0
	end
    return math.floor(nx), math.floor(ny)
end



-- 以某点为屏幕中心
function GlobalScrollLayer:screenToPos(x, y, anim, callback, useEase, timePer, makeTime)
    self._sceneLayer:stopAllActions()
    local scale = self._sceneLayer:getScale()
    if timePer == nil then timePer = 1 end
    local nx = nil
    if x ~= nil then
        nx = (MAX_SCREEN_WIDTH * 0.5 - x) * scale
    end
    local ny = nil
    if y ~= nil then
        ny = (MAX_SCREEN_HEIGHT * 0.5 - y) * scale
    end
    nx ,ny = self:adjustPos(nx, ny)
    if anim == true then 
        if makeTime == nil then makeTime = 1 end
        local action1
        if useEase == true then 
            makeTime = 2
            action1 = cc.EaseOut:create(cc.MoveTo:create(makeTime, cc.p(nx, ny)), 4)
        else
            action1 = cc.MoveTo:create(makeTime, cc.p(nx, ny))
        end
        self._sceneLayer:runAction(cc.Spawn:create(
                action1, 
                cc.Sequence:create(
                    cc.DelayTime:create(makeTime * timePer), 
                        cc.CallFunc:create(function()
                            if callback ~= nil then 
                                callback()
                            end
                        end)
                    )))
        return
    end
    self:updateScenePos(nx, ny)
    if callback ~= nil then 
        callback()
    end
end


function GlobalScrollLayer:screenToSize(scale)
    local x = self._sceneLayer:getPositionX() / self._sceneLayer:getScale()
    local y = self._sceneLayer:getPositionY() / self._sceneLayer:getScale()
    self._sceneLayer:setScale(scale)
    self:onSceneScale(scale)
    local nx = x * scale
    local ny = y * scale
    self:updateScenePos(nx, ny)
    self:listenScale(scale)
end

function GlobalScrollLayer:showPoint(scale, x, y, amin, callback)
    self._curOffsetMinX = 0
    self._curOffsetMinY = 0
    self._curOffsetMaxX = 0
    self._curOffsetMaxY = 0

    local nx = nil
    if x ~= nil then
        nx = (MAX_SCREEN_WIDTH * 0.5 - x) * scale
    end
    local ny = nil
    if y ~= nil then
        ny = (MAX_SCREEN_HEIGHT * 0.5 - y) * scale
    end
    nx ,ny = self:adjustPos(nx, ny)
        
    local runTime = 0.4
    if amin == false then 
        runTime = 0
    end
    self._animId = ScheduleMgr:regSchedule(1, self, function(self)
        local tempScale = self._sceneLayer:getScaleX()
        self:onSceneScale(tempScale)
        self:listenScale(tempScale)
    end)
    self._touchScale = scale
    local action1 = cc.MoveTo:create(runTime, cc.p(nx, ny))
    local action2 = cc.ScaleTo:create(runTime, scale, scale)
    self._sceneLayer:runAction(cc.Sequence:create(cc.Spawn:create(action1, action2),
        cc.CallFunc:create(function()
                if self._animId ~= nil then 
                    ScheduleMgr:unregSchedule(self._animId)
                    self._animId = nil
                end 
                if callback ~= nil then
                    callback()
                end
            end)))
end

--[[
--! @function updateScenePos
--! @desc 更新场景坐标
--! @param  x
--! @param  y
--! @param  anim 是否动画
--! @return 
--]]
function GlobalScrollLayer:updateScenePos(x, y)
    self._sceneLayer:stopAllActions()
    self._sceneLayer:setPosition(self:adjustPos(x, y))
end


-- 震动
function GlobalScrollLayer:shake(type, strong)
    self["shake"..type](self, strong)
end

-- 震动小
function GlobalScrollLayer:shake1(strong)
    local scale = self._sceneLayer:getScale() * 0.5 * strong
    self:stopAllActions()
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0))
    ))
end

-- 震动中
function GlobalScrollLayer:shake2(strong)
    local scale = self._sceneLayer:getScale() * 0.5 * strong
    self:stopAllActions()
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-12)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-6)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-4)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-6)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-3)), cc.DelayTime:create(0.05),        
        cc.MoveTo:create(0, cc.p(0, 0))
    ))
end

-- 震动大
function GlobalScrollLayer:shake3(strong)
    local scale = self._sceneLayer:getScale() * 0.5 * strong
    self:stopAllActions()
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-20)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-15)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-15)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-5)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-7)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-5)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-3)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0))
    ))
end

-- 连续震动
function GlobalScrollLayer:shake4(strong)
    local scale = self._sceneLayer:getScale() * 0.2 * strong
    self:stopAllActions()
    self:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0))
    ))
end


function GlobalScrollLayer:registerTouchEventWithLight(btn, clickCallback) 
    local touchX, touchY = 0, 0   
    registerTouchEvent(btn,
        function ()
            if self._lockTouch == true then return end
            self._oldBrightness = btn:getBrightness() or 0
            touchX, touchY = self._sceneLayer:getPosition()
            btn.flashes = 50
            local tempFlashes = 0
            if not self._btnSchedule then
                self._btnSchedule = ScheduleMgr:regSchedule(0.1, self,function( )
                    if btn.flashes >= 100 then 
                        tempFlashes = -5
                    end
                    if btn.flashes <= 50 then
                        tempFlashes = 5
                    end
                    btn.flashes = btn.flashes + tempFlashes
                    btn:setBrightness(btn.flashes)
                end)
            end
            btn.downSp = btn:getVirtualRenderer()
        end,
        function ()
            if self._lockTouch == true then return end
            if btn.downSp ~= btn:getVirtualRenderer() then
                btn:setBrightness(self._oldBrightness)
            end
        end,
        function ()
            if self._lockTouch == true then return end
            if self._btnSchedule then
                ScheduleMgr:unregSchedule(self._btnSchedule)
                self._btnSchedule = nil
            end
            btn:setBrightness(self._oldBrightness)
            local x, y = self._sceneLayer:getPosition()
            if math.abs(touchX - x) > 10
                or math.abs(touchY- y) > 10 then 
                return false
            end            
            if clickCallback ~= nil then 
                clickCallback()
            end
        end,
        function()
            if self._lockTouch == true then return end
            if self._btnSchedule then
                ScheduleMgr:unregSchedule(self._btnSchedule)
                self._btnSchedule = nil
            end
            btn:setBrightness(self._oldBrightness)
        end)
    btn:setSwallowTouches(false)
end


function GlobalScrollLayer:checkTouchBegan()
    -- print("GlobalScrollLayer checkTouchBegan=====")
    return false
end

function GlobalScrollLayer:checkTouchEnd()
    -- print("GlobalScrollLayer checkTouchEnd=====")
    return false
end

function GlobalScrollLayer:checkTouch()
    return true
end

function GlobalScrollLayer:onMouseScrollEx()
    -- print("GlobalScrollLayer onMouseScrollEx===============================")
    return true
end

function GlobalScrollLayer:onTouchesBeganEx()
    return true
end

function GlobalScrollLayer:onTouchesMovedEx()
    return true
end

function GlobalScrollLayer:onTouchesEndedEx()
    return true
end


function GlobalScrollLayer:onTouchesEndedEx()
    return true
end


function GlobalScrollLayer:listenScale(inScale)
    return true
end



function GlobalScrollLayer:getMaxScrollHeightPixel(inScale)
    return 1400
end

function GlobalScrollLayer:getMaxScrollWidthPixel(inScale)
    return 1400
end
-- function GlobalScrollLayer:adjustPos(x, y)

-- end

-- 是否限制缩放边界值(仅针对windows鼠标滚轮)
function GlobalScrollLayer:getAdjustMapScale()
    return true
end


function GlobalScrollLayer:getMinScale()
    return 1
end

function GlobalScrollLayer:getMaxScale()
    return 2
end

function GlobalScrollLayer:getInitScale()
    return 1
end


return GlobalScrollLayer