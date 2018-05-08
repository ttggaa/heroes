--[[
    Filename:    HeroSelectView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-08-04 10:08:03
    Description: File description
--]]

local HeroCardView = require("game.view.hero.HeroCardView")
local HeroSelectView = class("HeroSelectView", function()
    return cc.Layer:create()
end)

HeroSelectView.kTouchEventBegan = 1
HeroSelectView.kTouchEventMoved = 2
HeroSelectView.kTouchEventEnded = 3
HeroSelectView.kTouchEventCancelled = 4

local PI = 3.1415926535897932385

local AngleToRadian = function(angle)
    return angle * PI / 180.0
end

local RadianToAngle = function(radian)
    return radian * 180.0 / PI
end

local Distance = function(aPosition, bPosition)
    local dx = aPosition.x - bPosition.x
    local dy = aPosition.y - bPosition.y
    return math.sqrt(dx * dx + dy * dy)
end

local SectorRadian = AngleToRadian(180.0)
local MovedThresholdRadianValue = AngleToRadian(3.0)
local MovedThresholdTimeValue = 0.2

function HeroSelectView:ctor(params)
    self._container = params.container
    self._notifyTouchEvent = params.notifyTouchEvent
    self._centerX = -230.0
    self._centerY = 0
    self._radius = 260.0
    self._cardSpace = AngleToRadian(params.angleSpace or 15.0)
    self._scheduler = cc.Director:getInstance():getScheduler()
    self._selectedElapsedTime = 0
    self._selectedDurationTime = 0.25
    self._turnRadian = 0.0
    self._turnReverse = false
    self._turnRadianFactor = 1.0
    self._turnElapsedRadian = 0.0
    self._turn_a1 = 0.0
    self._turn_a2 = 0.0
    self._turnElapsedTime = 0.0
    self._turn_t = 0.8
    self._cardStatusDirty = false
    self._isMidCardClicked = false
    self._turnTableViewStable = true
    self._touchEnable = true
    self._touchListener = nil
    self._layerTouch = nil
    self._layerTouchListener = nil
    self._APosition = cc.p(0, 0)
    self._BPosition = cc.p(0, 0)
    self._sPosition = cc.p(0, 0)
    self._ePosition = cc.p(0, 0)
    self._movedTurnSpeed = 0.0
    self._movedTurnRadian = 0.0
    self._movedTurnElapsedRadian = 0.0
    self._movedTurn_a = 0.0
    self._movedTurnElapsedTime = 0.0
    self._movedTurn_t = 1.0
    self._movedTurnTouchTime = 0

    self._continousTimeContext = {
        reset = function(self)
            self._scheduler = cc.Director:getInstance():getScheduler()
            self._durationTime = 0.5
            self._elapsedTime = 0.0
            self._callback = nil
        end,

        setTimer = function(self, callback)
            self:reset()
            self._callback = callback
            if not self._isTimerSet then
                self._timerId = self._scheduler:scheduleScriptFunc(handler(self, self.updateTimer), 0, false)
                self._isTimerSet = true
                self._trigger = false
            end
        end,

        unsetTimer = function(self)
            if self._isTimerSet then
                self._scheduler:unscheduleScriptEntry(self._timerId)
                self._isTimerSet = false
            end
            self:reset()
        end,

        updateTimer = function(self, dt)
            if self._elapsedTime >= self._durationTime then
                if self._callback and "function" == type(self._callback) then
                    self._callback()
                    self._trigger = true
                end
                self:unsetTimer()
            end
            self._elapsedTime = self._elapsedTime + dt
        end,

        isTrigger = function(self)
            return self._trigger
        end
    }

    self._size = 0
    self._stardardCardRadians = {}
    self._stardardSelectedCardRadians = {}
    self._currentCardRadians = {}
    self._deltaCardRadians = {}
    self._cards = {}

    self._isSelectedScheduleSet = false
    self._selectedScheduleId = 0
    self._isDeselectedScheduleSet = false
    self._deselectedScheduleId = 0
    self._isTurnScheduleSet = false
    self._turnScheduleId = 0
    self._isMoveTurnScheduleSet = false
    self._moveTurnScheduleId = 0

    self:initHeroData(params.heroData)

    self:onInit()

    self:registerScriptHandler(function(state)
        if state == "exit" then
            self:unregisterHeroSelectViewTouchEvent()
            self:unregisterLayerTouchEvent()
            self:onClear()
            for i = 0, self._size - 1 do
                local card = self._cards[i]
                if card then
                    card:release()
                end 
            end
        end 
    end)
end

function HeroSelectView:initHeroData(heroData)
    self._heroData = {}
    self._heroData._data = heroData.data
    --dump(self._heroData._data, "HeroSelectView:initHeroData")
    local getDataSize =  function()
        local count = 0
        for _, _ in pairs(self._heroData._data) do
            count = count + 1
        end
        return count
    end
    self._heroData._size = getDataSize()

    self._heroData.findHeroIndexById = function(self, id)
        --print("findHeroIndexById", id)
        for i = 0, self._size - 1 do
            if self._data[i].id == id then
                return i
            end
        end
        print("invalid hero id")
        return 0
    end

    self._heroData.findHeroById = function(self, id)
        --print("findHeroById", id)
        return self._data[self:findHeroIndexById(id)]
    end

    self._heroData.getNextHero = function(self, id)
        --print("getNextHero", id)
        local size = self._size
        local index = self:findHeroIndexById(id)
        return self._data[(index + 1 + size) % size]
    end

    self._heroData.getPreHero = function(self, id)
        --print("getPreHero", id)
        local size = self._size
        local index = self:findHeroIndexById(id)
        return self._data[(index - 1 + size) % size]
    end

    self._heroData.findCurrentMiddleHeroId = function(self)
        --[[for i = 0, self._size - 1 do
            if self._data[i].unlock then
                return self._data[i].id
            end
        end
        return self._data[math.floor(self._size / 2)].id
        ]]
        return self._data[0].id
    end

    self._heroData._currentMiddleHeroId = self._heroData:findCurrentMiddleHeroId()
end

function HeroSelectView:onInit()
    local size = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
    if ADOPT_IPHONEX then
        size = {width = 1136, height = MAX_SCREEN_HEIGHT}
    end
    self:setAnchorPoint(cc.p(0, 0))
    self:setContentSize(cc.size(360, size.height))
    self:setPosition(0, size.height / 2)
    self:registerHeroSelectViewTouchEvent()
    self:registerLayerTouchEvent()
    self:initAnglesSpace()
    self:initCards()
    self:onSelected()
end

function HeroSelectView:initAnglesSpace()
    self._size = math.ceil(SectorRadian / self._cardSpace) + 3

    for i = 0, self._size - 1 do
        self._stardardCardRadians[i] = 0
        self._stardardSelectedCardRadians[i] = 0
    end
    
    local mid = math.floor(self._size / 2)

    for i = mid - 1, 0, -1 do
        self._stardardCardRadians[i] = self._stardardCardRadians[mid] - (mid - i) * self._cardSpace
        self._stardardSelectedCardRadians[i] = self._stardardCardRadians[i] - (mid - i) * AngleToRadian(2.0)
    end

    for i = mid + 1, self._size - 1 do
        self._stardardCardRadians[i] = self._stardardCardRadians[mid] + (i - mid) * self._cardSpace
        self._stardardSelectedCardRadians[i] = self._stardardCardRadians[i] + (i - mid) * AngleToRadian(2.0)
    end

    self._currentCardRadians = clone(self._stardardCardRadians)
    self._deltaCardRadians = clone(self._stardardCardRadians)
end

function HeroSelectView:getCirclePosition(radian)
    return cc.p(self._centerX + self._radius * math.cos(radian), self._centerY + self._radius * math.sin(radian))
end

function HeroSelectView:initCards()
    local size = self._size
    local mid = math.floor(size / 2)
    local heroesData = {}
    heroesData[mid] = self._heroData:findHeroById(self._heroData._currentMiddleHeroId)
    for i = mid + 1, size - 1 do
        heroesData[i] = self._heroData:getNextHero(heroesData[i-1].id)
    end

    for i = mid - 1, 0, -1 do
        heroesData[i] = self._heroData:getPreHero(heroesData[i+1].id)
    end

    --dump(heroesData, "initCards.heroesData")

    for i = 0, size - 1 do
        local card = HeroCardView.new(self, heroesData[i])
        card:setScale(1.0)
        card:setRadian(self._stardardCardRadians[i])
        card:setOldZorder(100 + size - i)
        card:setPosition(self:getCirclePosition(self._stardardCardRadians[i]))
        card:setRotation(-RadianToAngle(self._stardardCardRadians[i]))
        self._cards[i] = card
        self._cards[i]:retain()
        self:addChild(card, 100 + size - i)
    end
end

function HeroSelectView:getAOBRadian(aPosition, bPosition)
    local a = Distance(aPosition, cc.p(self._centerX, self._centerY))
    local b = Distance(bPosition, cc.p(self._centerX, self._centerY))
    local c = Distance(aPosition, bPosition)
    local radian = 0
    if a + b > c and a + c > b and b + c > a then
        radian = math.acos((a * a + b * b - c * c) / (2.0 * a * b))
    end

    return radian
end

function HeroSelectView:getSelectedIndex(position)
    if math.abs(position.y) <= self:getCurrentSelectedCard():getContentSize().height / 2 then
        return math.floor(self._size / 2)
    end
    local randian = math.atan(position.y / (position.x + math.abs(self._centerX)))
    local size = self._size
    local index = -1
    for i = 0, size - 1 do
        if (randian >= (self._stardardSelectedCardRadians[i] - self._cardSpace / 2.6)) and (randian < (self._stardardSelectedCardRadians[i] + self._cardSpace / 1.2)) then
            index = i
            break
        end
    end
    return index
end

function HeroSelectView:resetMovedElapsedTime()
    self._movedTurnTouchTime = os.clock()
end

function HeroSelectView:getMovedElapsedTime()
    local deltaTime = os.clock() - self._movedTurnTouchTime
    return deltaTime
end

function HeroSelectView:getAllCards()
    return self._cards
end

function HeroSelectView:getCurrentSelectedCard()
    local mid = math.floor(self._size / 2)
    return self._cards[mid]
end

function HeroSelectView:getCardById(id)
    for i = 0, self._size - 1 do
        local card = self._cards[i]
        if card:getId() == id then
            return card
        end
    end
    return nil
end

function HeroSelectView:doTurn(isAnticlockwise, radian)
    if math.abs(radian) <= 0 then
        return
    end

    local anticlockwise = isAnticlockwise and 1 or -1
    local size = self._size
    for i = 0, size - 1 do
        self._currentCardRadians[i] = self._currentCardRadians[i] + anticlockwise * radian
    end

    if math.abs(self._currentCardRadians[math.floor(size / 2)]) >= self._cardSpace / 2 then
        if 1 == anticlockwise then
            for i = size - 1, 1, -1 do
                self._currentCardRadians[i] = self._currentCardRadians[i-1]
            end

            self._currentCardRadians[0] = self._stardardCardRadians[0] + self._currentCardRadians[math.floor(size / 2)]

            local oldCard = self._cards[size-1]
            if oldCard then
                oldCard:removeFromParent()
            end
            local card = HeroCardView.new(self, self._heroData:getPreHero(self._cards[0]:getId()))
            card:setOldZorder(self._cards[0]:getLocalZOrder() + 1)
            self:addChild(card, self._cards[0]:getLocalZOrder() + 1)

            self._cards[size-1]:release()
            for i = size - 1, 1, -1 do
                self._cards[i] = self._cards[i-1]
            end
            self._cards[0] = card
            self._cards[0]:retain()
        else
            for i = 0, size - 2 do
                self._currentCardRadians[i] = self._currentCardRadians[i+1]
            end

            self._currentCardRadians[size-1] = self._stardardCardRadians[size-1] + self._currentCardRadians[math.floor(size / 2)]

            local oldCard = self._cards[0]
            if oldCard then
                oldCard:removeFromParent()
            end
            local card = HeroCardView.new(self, self._heroData:getNextHero(self._cards[size-1]:getId()))
            card:setOldZorder(self._cards[size-1]:getLocalZOrder() - 1)
            self:addChild(card, self._cards[size-1]:getLocalZOrder() - 1)

            self._cards[0]:release()
            for i = 0, size - 2 do
                self._cards[i] = self._cards[i+1]
            end
            self._cards[size-1] = card
            self._cards[size-1]:retain()
        end
    end

    for i = 0, size - 1 do
        local card = self._cards[i]
        card:setRadian(self._currentCardRadians[i])
        card:setPosition(self:getCirclePosition(self._currentCardRadians[i]))
        card:setRotation(-RadianToAngle(self._currentCardRadians[i]))
    end
end

function HeroSelectView:doReset()
    local size = self._size
    for i = 0, size - 1 do
        local card = self._cards[i]
        card:setScale(1.0)
        --card:markGray(true) -- remain the gray info when turning
        card:setRadian(self._stardardCardRadians[i])
        card:setLocalZOrder(card:getOldZorder())
        card:setPosition(self:getCirclePosition(self._stardardCardRadians[i]))
        card:setRotation(-RadianToAngle(self._stardardCardRadians[i]))
    end

    self._currentCardRadians = clone(self._stardardCardRadians)
end

function HeroSelectView:registerHeroSelectViewTouchEvent()
    self._touchListener = cc.EventListenerTouchOneByOne:create()
    self._touchListener:registerScriptHandler(function(touch, event)
        if not self:onHeroSelectViewTouchBegan(touch:getLocation().x, touch:getLocation().y) then
            return false
        end
        self:notifyTouchEvent(HeroSelectView.kTouchEventBegan)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    self._touchListener:registerScriptHandler(function(touch, event)
        self:notifyTouchEvent(HeroSelectView.kTouchEventMoved)
        self:onHeroSelectViewTouchMoved(touch:getLocation().x, touch:getLocation().y)
    end, cc.Handler.EVENT_TOUCH_MOVED)
    self._touchListener:registerScriptHandler(function(touch, event)
        self:notifyTouchEvent(HeroSelectView.kTouchEventEnded)
        self:onHeroSelectViewTouchEnded(touch:getLocation().x, touch:getLocation().y)
    end, cc.Handler.EVENT_TOUCH_ENDED)
    self._touchListener:registerScriptHandler(function(touch, event)
        self:notifyTouchEvent(HeroSelectView.kTouchEventCancelled)
        self:onHeroSelectViewTouchCancelled(touch:getLocation().x, touch:getLocation().y)
    end, cc.Handler.EVENT_TOUCH_CANCELLED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._touchListener, self)
end

function HeroSelectView:unregisterHeroSelectViewTouchEvent()
    if self._touchListener then
        self:getEventDispatcher():removeEventListener(self._touchListener)
        self._touchListener = nil
    end

end

function HeroSelectView:registerLayerTouchEvent()
    self._layerTouch = cc.Layer:create()
    self._layerTouch:setContentSize(cc.Director:getInstance():getOpenGLView():getFrameSize())
    self._layerTouch:setPosition(self:convertToNodeSpace(cc.p(0, 0)))
    self:addChild(self._layerTouch, 10000)
    self._layerTouchListener = cc.EventListenerTouchOneByOne:create()
    self._layerTouchListener:retain()
    self._layerTouchListener:setSwallowTouches(true)
    self._layerTouchListener:registerScriptHandler(function(touch, event)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    self._layerTouchListener:registerScriptHandler(function(touch, event)
    end, cc.Handler.EVENT_TOUCH_MOVED)
    self._layerTouchListener:registerScriptHandler(function(touch, event)
    end, cc.Handler.EVENT_TOUCH_ENDED)
    self._layerTouchListener:registerScriptHandler(function(touch, event)
    end, cc.Handler.EVENT_TOUCH_CANCELLED)
end

function HeroSelectView:unregisterLayerTouchEvent()
    self._layerTouchListener:release()
    self._layerTouchListener = nil
end

function HeroSelectView:setHeroSelectViewTouchEnabled(enable)
    if enable == self._touchEnable then return end
    self._touchEnable = enable
    if enable then
        self:getEventDispatcher():removeEventListener(self._layerTouchListener)
    else
        self._layerTouch:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._layerTouchListener, self._layerTouch)
    end
end

function HeroSelectView:notifyTouchEvent(event)
    if self._notifyTouchEvent and type(self._notifyTouchEvent) == "function" then
        self._notifyTouchEvent(event)
    end
end

function HeroSelectView:isMidCardClicked()
    return self._isMidCardClicked
end

function HeroSelectView:onHeroSelectViewTouchBegan(x, y)
    local location = self:convertToNodeSpace(cc.p(x, y))
    --print("began", location.x, location.y)
    local size = self:getContentSize()
    local rect = cc.rect(0, -size.height / 2.0, size.width, size.height)
    local distance = Distance(location, cc.p(self._centerX, self._centerY))
    if cc.rectContainsPoint(rect, location) and distance >= self._radius / 3.0 and distance <= self._radius * 1.8 then
    --if cc.rectContainsPoint(rect, location) --[[and distance >= self._radius / 3.0 and distance <= self._radius * 1.8]] then
        self._sPosition = location
        self._APosition = location
        self:resetMovedElapsedTime()
        if self:getSelectedIndex(self._sPosition) == math.floor(self._size / 2) then
            self._isMidCardClicked = true
            return true
        end
        self:onDeselected()
        return true
    end

    return false
end

function HeroSelectView:onHeroSelectViewTouchMoved(x, y)
    local location = self:convertToNodeSpace(cc.p(x, y))
    --print("moved", location.x, location.y)
    if self._cardStatusDirty then
        self:onSelectedFinished()
        self:onDeselectedFinished()
    end

    self._BPosition = location

    local isAnticlockwise = (self._BPosition.y - self._APosition.y) > 0
    local radian = self:getAOBRadian(self._APosition, self._BPosition)

    if (radian < MovedThresholdRadianValue) and self._turnTableViewStable then
        return
    end

    if radian >= MovedThresholdRadianValue then
        self._APosition = self._BPosition
        self._turnTableViewStable = false
    end

    if self._isMidCardClicked then
        self:onDeselected()
    end

    self:doTurn(isAnticlockwise, radian)

    self._APosition = self._BPosition
    self._isMidCardClicked = false
end

function HeroSelectView:onHeroSelectViewTouchEnded(x, y)
    --print("ended", location.x, location.y)
    if self._cardStatusDirty then
        self:onSelectedFinished()
        self:onDeselectedFinished()
    end

    local location = self:convertToNodeSpace(cc.p(x, y))
    self._ePosition = location

    local isMoved = false
    local isLongAndFastMoved = false
    local radian = self:getAOBRadian(self._sPosition, self._ePosition)
    local movedElapseTime = self:getMovedElapsedTime()
    --print("move elapse time", movedElapseTime)
    if radian >= 12 * MovedThresholdRadianValue and movedElapseTime <= MovedThresholdTimeValue then
        isLongAndFastMoved = true
    elseif radian >= MovedThresholdRadianValue then
        isMoved = true
    end

    if isLongAndFastMoved then
        self:doReset()
        self:onMovedTurn(radian / movedElapseTime)
    elseif isMoved then
        self:doReset()
        self:onSelected()
    elseif not self._isMidCardClicked then
        self:onTurn()
    end

    self._isMidCardClicked = false
    self._turnTableViewStable = true
end

function HeroSelectView:onHeroSelectViewTouchCancelled(x, y)
    local location = self:convertToNodeSpace(cc.p(x, y))
    --print("cancelled", location.x, location.y)
    self._isMidCardClicked = false
    self._turnTableViewStable = true
end

function HeroSelectView:selectedCommonUpdate(dt, finishCallBack)
    local size = self._size
    local currentCardRadians = clone(self._currentCardRadians)
    local percent = math.max(0, math.min(1, self._selectedElapsedTime / self._selectedDurationTime))
    for i = 0, size - 1 do
        local radian = self._deltaCardRadians[i] * percent
        currentCardRadians[i] = self._currentCardRadians[i] + radian
    end

    for i = 0, size - 1 do
        repeat
            if i == math.floor(size / 2) then break end
            local card = self._cards[i]
            card:setRadian(currentCardRadians[i])
            card:setScale(1 - percent * 0.05)
            card:setPosition(self:getCirclePosition(currentCardRadians[i]))
            card:setRotation(-RadianToAngle(currentCardRadians[i]))
        until true
    end

    self._selectedElapsedTime = self._selectedElapsedTime + dt
    if self._selectedElapsedTime >= self._selectedDurationTime then
        if finishCallBack and type(finishCallBack) == "function" then
            finishCallBack()
        end
    end
end

function HeroSelectView:selectedUpdate(dt)
    self:selectedCommonUpdate(dt, function()
        self:onSelectedFinished()
    end)
end

function HeroSelectView:deselectedUpdate(dt)
    self:selectedCommonUpdate(dt, function()
        self:onDeselectedFinished()
    end)
end

function HeroSelectView:turnUpdate(dt)
    self._turnElapsedTime = self._turnElapsedTime + dt
    local turnRadian = 0
    turnRadian = not self._turnReverse and math.abs((self._turn_a1 * self._turnElapsedTime * dt) - (dt * dt) / 2) or
                    math.abs(self._turn_a1 * (self._turnRadianFactor / (self._turnRadianFactor + 1) * self._turn_t) * dt + self._turn_a2 * (self._turnElapsedTime - (self._turnRadianFactor / (self._turnRadianFactor + 1) * self._turn_t)) * dt - self._turn_a2 * dt * dt / 2)
    self:doTurn(self._turnRadian < 0, turnRadian)
    self._turnElapsedRadian = self._turnElapsedRadian + turnRadian
    if not self._turnReverse and self._turnElapsedRadian >= (self._turnRadianFactor * math.abs(self._turnRadian) / (self._turnRadianFactor + 1)) then
        self._turnReverse = true
    end

    if self._turnElapsedRadian >= math.abs(self._turnRadian) then
        self:onTurnFinished()
    end
end

function HeroSelectView:movedTurnUpdate(dt)
    self._movedTurnElapsedTime = self._movedTurnElapsedTime + dt
    local movedTurnRadian = math.abs(self._movedTurnSpeed * dt + self._movedTurna * self._movedTurnElapsedTime * dt - (self._movedTurna * dt * dt) / 2)
    self:doTurn(self._movedTurnRadian < 0, movedTurnRadian)
    self._movedTurnElapsedRadian = self._movedTurnElapsedRadian + movedTurnRadian
    if self._movedTurnElapsedRadian >= math.abs(self._movedTurnRadian) then
        self:onMovedTurnFinished()
    end
end

function HeroSelectView:onSelected()
    local size = self._size
    self._deltaCardRadians = {}
    for i = 0, size -1 do
        self._deltaCardRadians[i] = 0
    end
    self._currentCardRadians = clone(self._stardardCardRadians)
    for i = 0, size - 1 do
        self._deltaCardRadians[i] = self._stardardSelectedCardRadians[i] - self._currentCardRadians[i]
    end

    local mid = math.floor(self._size / 2)
    local card = self._cards[mid]
    if card and not card:getSelected() then
        local heroData = self._heroData:findHeroById(card:getId())
        if self._container and self._container.onSelected then
            self._container:onSelected(heroData)
        end
        card:setSelected(true,nil,heroData.slot)
    end

    for i = 0, size - 1 do
        local card = self._cards[i]
        card:markGray(false)
    end

    if self._cardStatusDirty then self:onDeselectedFinished() end
    self._selectedElapsedTime = 0

    if not self._isSelectedScheduleSet then
        self._selectedScheduleId = self._scheduler:scheduleScriptFunc(handler(self, self.selectedUpdate), 0, false)
        self._isSelectedScheduleSet = true
    end

    self._cardStatusDirty = true
end

function HeroSelectView:onSelectedFinished()
    if self._isSelectedScheduleSet then
        self._scheduler:unscheduleScriptEntry(self._selectedScheduleId)
        self._isSelectedScheduleSet = false
    end

    self._selectedElapsedTime = 0
    self._currentCardRadians = clone(self._stardardSelectedCardRadians)
    
    local mid = math.floor(self._size / 2)
    local card = self._cards[mid]
    if card then
        card:stopAllActions()
    end
    
    self._cardStatusDirty = false
end

function HeroSelectView:onDeselected()
    local size = self._size
    self._currentCardRadians = clone(self._stardardSelectedCardRadians)
    for i = 0, size - 1 do
        self._deltaCardRadians[i] = self._stardardCardRadians[i] - self._currentCardRadians[i]
    end

    if self._isMidCardClicked then
        local mid = math.floor(size / 2)
        local card = self._cards[mid]
        if card and card:getSelected() then
            card:setSelected(false, true)
        end

        if self._cardStatusDirty then self:onSelectedFinished() end
        self._selectedElapsedTime = 0
    else
        local mid = math.floor(size / 2)
        local card = self._cards[mid]
        if card and card:getSelected() then
            card:setSelected(false)
        end

        if self._cardStatusDirty then self:onSelectedFinished() end
        self._selectedElapsedTime = 0

        if not self._isDeselectedScheduleSet then
            self._deselectedScheduleId = self._scheduler:scheduleScriptFunc(handler(self, self.deselectedUpdate), 0, false)
            self._isDeselectedScheduleSet = true
        end
    end

    self._cardStatusDirty = true
end

function HeroSelectView:onDeselectedFinished()
    if self._isDeselectedScheduleSet then
        self._scheduler:unscheduleScriptEntry(self._deselectedScheduleId)
        self._isDeselectedScheduleSet = false
    end

    self._selectedElapsedTime = 0
    self._currentCardRadians = clone(self._stardardCardRadians)
    
    local mid = math.floor(self._size / 2)
    local card = self._cards[mid]
    if card then
        card:stopAllActions()
    end

    if not self._isMidCardClicked then
        self:doReset()
    end
    
    self._cardStatusDirty = false
end

function HeroSelectView:onTurn()
    local size = self._size
    local index = self:getSelectedIndex(self._ePosition)
    if -1 == index then return end

    self._turnReverse = false
    self._turnRadian = self._stardardCardRadians[index] - self._stardardCardRadians[math.floor(size / 2)]
    self._turnElapsedRadian = 0
    self._turn_t = 0.2 + math.abs(index - math.floor(self._size / 2)) * 0.2
    self._turn_a1 = (2 * math.abs(self._turnRadian) * (self._turnRadianFactor + 1)) / (self._turnRadianFactor * self._turn_t * self._turn_t)
    self._turn_a2 = -(2 * math.abs(self._turnRadian) * (self._turnRadianFactor + 1)) / (self._turn_t * self._turn_t)
    self._turnElapsedTime = 0

    if not self._isTurnScheduleSet then
        self._turnScheduleId = self._scheduler:scheduleScriptFunc(handler(self, self.turnUpdate), 0, false)
        self._isTurnScheduleSet = true
    end

    self:setHeroSelectViewTouchEnabled(false)
end

function HeroSelectView:onTurnFinished()
    if self._isTurnScheduleSet then
        self._scheduler:unscheduleScriptEntry(self._turnScheduleId)
        self._isTurnScheduleSet = false
    end

    self._turnReverse = false
    self._turnRadian = 0
    self._turnElapsedRadian = 0
    self._turn_a1 = 0
    self._turn_a2 = 0
    self._turnElapsedTime = 0
    self:doReset()
    self:onSelected()

    self:setHeroSelectViewTouchEnabled(true)
end

function HeroSelectView:onMovedTurn(speed)
    local isAnticlockwise = (self._ePosition.y - self._sPosition.y > 0) and -1 or 1
    self._movedTurnSpeed = math.min(speed, 12)
    self._movedTurnRadian = isAnticlockwise * math.floor(self._movedTurnSpeed) * self._cardSpace
    self._movedTurnt = 5 * math.abs(self._movedTurnRadian) / self._movedTurnSpeed
    self._movedTurnElapsedRadian = 0
    self._movedTurna = -self._movedTurnSpeed / self._movedTurnt
    self._movedTurnElapsedTime = 0

    if not self._isMoveTurnScheduleSet then
        self._moveTurnScheduleId = self._scheduler:scheduleScriptFunc(handler(self, self.movedTurnUpdate), 0, false)
        self._isMoveTurnScheduleSet = true
    end

    self:setHeroSelectViewTouchEnabled(false)
end

function HeroSelectView:onMovedTurnFinished()
    if self._isMoveTurnScheduleSet then
        self._scheduler:unscheduleScriptEntry(self._moveTurnScheduleId)
        self._isMoveTurnScheduleSet = false
    end

    self._movedTurnSpeed = 0
    self._movedTurnRadian = 0
    self._movedTurnElapsedRadian = 0
    self._movedTurna = 0
    self._movedTurnElapsedTime = 0
    self:doReset()
    self:onSelected()

    self:setHeroSelectViewTouchEnabled(true)
end

function HeroSelectView:onClear()
    if self._isSelectedScheduleSet then
        self._scheduler:unscheduleScriptEntry(self._selectedScheduleId)
        self._isSelectedScheduleSet = false
    end

    if self._isDeselectedScheduleSet then
        self._scheduler:unscheduleScriptEntry(self._deselectedScheduleId)
        self._isDeselectedScheduleSet = false
    end

    if self._isTurnScheduleSet then
        self._scheduler:unscheduleScriptEntry(self._turnScheduleId)
        self._isTurnScheduleSet = false
    end

    if self._isMoveTurnScheduleSet then
        self._scheduler:unscheduleScriptEntry(self._moveTurnScheduleId)
        self._isMoveTurnScheduleSet = false
    end
end

return HeroSelectView