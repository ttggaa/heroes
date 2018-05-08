--[[
    Filename:    TestBattleScene.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-05-16 14:58:36
    Description: File description
--]]

local TestBattleScene = class("TestBattleScene", BaseView)

function TestBattleScene:ctor()
    TestBattleScene.super.ctor(self)
    setMultipleTouchEnabled()
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION3_D)
end

function TestBattleScene:onDestroy()
    setMultipleTouchDisabled()
    ScheduleMgr:unregSchedule(self._updateId)
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:removeEventListenersForTarget(self._sceneLayer, true)
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
	TestBattleScene.super.onDestroy(self)
end

function TestBattleScene:onInit()
    self._maps =
    {
        "airenbaowu1",
        "dixia1",
        "dixia2",
        "dixue1",
        "dulongxue1",
        "emowangzuo1",
        "fanchuan1",
        "gebi1",
        "gebi2",
        "jifenliansai1",
        "jingjichang1",
        "jinglingsenlin1",
        "kaichang",
        "migongbaozang1",
        "muyuan1",
        "muyuan2",
        "pingyuan1",
        "pingyuan2",
        "rongyan1",
        "rongyan2",
        "shamo1",
        "shamo2",
        "shandi1",
        "shatan1",
        "shuijinglongdong1",
        "xiaguyiji1",
        "xueyuan1",
        "xueyuan2",
        "xunlianchang1",
        "yaosai1",
        "yinsenmushi1",
        "yunzhongcheng1",
        "yunzhongcheng2",
        "yunzhongcheng3",
        "zhaoze1",
        "zhaoze2",
    }
    self._mapsIndex = 1


    local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn, 999)


    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(160, 100)
    btn1:setTitleText("<-场景")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        self._mapsIndex = self._mapsIndex - 1
        if self._mapsIndex < 1 then
            self._mapsIndex = #self._maps
        end
        self:onUpdate()
        
    end)
    self:addChild(btn1)
    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 160, 100)
    btn1:setTitleText("场景->")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        self._mapsIndex = self._mapsIndex + 1
        if self._mapsIndex > #self._maps then
            self._mapsIndex = 1
        end
        self:onUpdate()
    end)
    self:addChild(btn1)

    self._countLabel = cc.Label:createWithTTF("1/1", UIUtils.ttfName, 30)
    self._countLabel:setPosition(MAX_SCREEN_WIDTH -10, 5)
    self._countLabel:setAnchorPoint(1, 0)
    self._countLabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._countLabel)

    self._namelabel = cc.Label:createWithTTF("x2.0", UIUtils.ttfName, 30)
    self._namelabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 50)
    self._namelabel:setAnchorPoint(0.5, 0.5)
    self._namelabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._namelabel)


    self._sceneLayer = cc.Layer:create()
    self._sceneLayer:setAnchorPoint(0.5, 0.5)
    self:addChild(self._sceneLayer, -1)

    self._sceneLayer:setRotation3D(cc.Vertex3F(-25, 0, 0))
    self:initEvent()
    self:onUpdate()
end

function TestBattleScene:onUpdate()
    local mapId = self._maps[self._mapsIndex]
    self._namelabel:setString(mapId)
    self._countLabel:setString(self._mapsIndex .. "/" .. #self._maps)
    if self._mapLayer then self._sceneLayer:removeAllChildren() end
    self._mapLayer = require("game.view.battle.display.BattleMapLayer").new()
    self._sceneLayer:addChild(self._mapLayer:getView())
    self._mapLayer:initLayer(mapId, nil)
    self._mapFar = self._mapLayer:getFar()
    self._mapNear = self._mapLayer:getNear()
    self:screenToPos(1200, 320)
end

function TestBattleScene:initEvent()
    -- 注册多点触摸
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
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._sceneLayer)

    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function (event)
        self:onMouseScroll(event)
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._sceneLayer)

    self._touchScale = 1
    self._updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
        self:updateTouch()
    end)
end

function TestBattleScene:updateTouch()
    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        self:updateScenePos(self._touchMoveX, self._touchMoveY, 0.7)
    elseif self._touche1Down and self._touche2Down then
        local scale = self._touchScale--self._sceneLayer:getScale() + (self._touchScale - self._sceneLayer:getScale()) * 0.7
        self._sceneLayer:setScale(scale)
        self:onSceneScale(scale)
        self._touchesBeganPositionX = self._touchesBeganPositionX or 0
        self._touchesBeganPositionY = self._touchesBeganPositionY or 0
        local nx = self._touchesBeganPositionX * scale
        local ny = self._touchesBeganPositionY * scale
        self:updateScenePos(nx, ny)
    end
end

function TestBattleScene:onMouseScroll(event)
    self._touchesBeganScale = self._touchScale
    self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
    self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    local scale = self._touchesBeganScale + event:getScrollY() * 0.1
    if true then
        scale = math.min(5, math.max(1, scale)) 
        -- print(scale)
    end
    self._sceneLayer:setScale(scale)
    self._touchScale = scale
    local nx = self._touchesBeganPositionX * scale
    local ny = self._touchesBeganPositionY * scale
    self._sceneLayer:setPosition(nx, ny)
    self:updateScenePos(nx, ny)
end

function TestBattleScene:onTouchesBegan(touches)
    local count = #touches
    for i = 1, count do
        if touches[i]:getId() == 0 then
            self._touche1Down = true
            self._touche1DownEx = true
            self._touche1X = touches[i]:getLocation().x
            self._touche1Y = touches[i]:getLocation().y
        elseif touches[i]:getId() == 1 then
            self._touche2Down = true
            self._touche2DownEx = true
            self._touche2X = touches[i]:getLocation().x
            self._touche2Y = touches[i]:getLocation().y
        end
    end

    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        if self._touche1Down then
            self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
            self._touchBeganPositionX = self._touche1X
            self._touchBeganPositionY = self._touche1Y
            self:onTouchMoved(self._touche1X, self._touche1Y)
        elseif self._touche2Down then
            self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
            self._touchBeganPositionX = self._touche2X
            self._touchBeganPositionY = self._touche2Y
            self:onTouchMoved(self._touche2X, self._touche2Y)
        end
    elseif self._touche1Down and self._touche2Down then
        self._touchesBeganDistance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        self._touchesBeganScale = self._sceneLayer:getScale()
        self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
        self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    end
end

function TestBattleScene:onTouchesMoved(touches)
    local count = #touches

    for i = 1, count do
        if touches[i]:getId() == 0 then
            self._touche1X = touches[i]:getLocation().x
            self._touche1Y = touches[i]:getLocation().y
        elseif touches[i]:getId() == 1 then
            self._touche2X = touches[i]:getLocation().x
            self._touche2Y = touches[i]:getLocation().y
        end
    end

    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        if self._touche1Down then
            self:onTouchMoved(self._touche1X, self._touche1Y, event)
        elseif self._touche2Down then
            self:onTouchMoved(self._touche2X, self._touche2Y, event)
        end
    elseif self._touche1Down and self._touche2Down then
        local distance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        local scale = self._touchesBeganScale * (distance / self._touchesBeganDistance)
        scale = math.min(5, math.max(1, scale)) 
        self._touchScale = scale
    end
end

function TestBattleScene:onTouchMoved(x, y)   
    -- 地图移动
    local lastPtx = self._touchBeganPositionX
    local lastPty = self._touchBeganPositionY
    if lastPtx == nil or lastPty == nil then return end
    local nowPtx = x
    local nowPty = y
    local dx = nowPtx - lastPtx
    local dy = nowPty - lastPty
    local nx = self._touchBeganScenePositionX + dx
    local ny = self._touchBeganScenePositionY + dy
    self._touchMoveX = nx
    self._touchMoveY = ny
end

function TestBattleScene:onTouchesEnded(touches)
    local count = #touches

    for i = 1, count do
        if touches[i]:getId() == 0 then
            self._touche1Down = false
            self._touche1DownEx = false
        elseif touches[i]:getId() == 1 then
            self._touche2Down = false
            self._touche2DownEx = false
        end
    end

    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        if self._touche1Down then
            self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
            self._touchBeganPositionX = self._touche1X
            self._touchBeganPositionY = self._touche1Y
            self:onTouchMoved(self._touche1X, self._touche1Y)
        elseif self._touche2Down then
            self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
            self._touchBeganPositionX = self._touche2X
            self._touchBeganPositionY = self._touche2Y
            self:onTouchMoved(self._touche2X, self._touche2Y)
        end
    elseif self._touche1Down and self._touche2Down then
        self._touchesBeganDistance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        self._touchesBeganScale = self._sceneLayer:getScale()
        self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
        self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    end
end

-- 更新场景坐标
function TestBattleScene:updateScenePos(x, y, anim)
    self._sceneLayer:stopAllActions()
    if anim then
        local _x, _y = self._sceneLayer:getPosition()
        if x == nil then
            x = _x
        end
        local dx = (x - _x) * anim
        local nx = _x + dx
        if y == nil then
            y = _y
        end
        local dy = (y - _y) * anim
        local ny = _y + dy
        self._sceneLayer:setPosition(self:adjustPos(nx, ny))
    else
        self._sceneLayer:setPosition(self:adjustPos(x, y))
    end
    self._mapLayer:update()
end

function TestBattleScene:getScenePosition()
    return self._sceneLayer:getPosition()
end

-- 矫正坐标
function TestBattleScene:adjustPos(x, y)
    local nx = x
    local ny = y
    if true then
        local width = 2400
        local x, y = self._sceneLayer:getPosition()
        local x1 = self:convertToScreenPt(0, 640)
        local x2 = self:convertToScreenPt(width, 640)
        local k = (width * self._sceneLayer:getScale()) / (x2 - x1)
        local maxX = x - x1 * k
        local minX = x - x2 * k + MAX_SCREEN_WIDTH * k
        local _, y1 = self._mapFar:nodeConvertToScreenSpace(0, 0)
        local _, y2 = self._mapFar:nodeConvertToScreenSpace(0, 256)
        local k = (256 * self._sceneLayer:getScale()) / (y2 - y1)
        local minY = y - (y2 - MAX_SCREEN_HEIGHT) * k + 2

        local _, y3 = self._mapNear:nodeConvertToScreenSpace(0, 0)
        local _, y4 = self._mapNear:nodeConvertToScreenSpace(0, 512)
        local k = (512 * self._sceneLayer:getScale()) / (y4 - y3)
        local maxY = y - y3 * k 

        -- if BC.BATTLE_TYPE == BattleUtils.BATTLE_TYPE_Zombie then
        --     maxX = maxX - 100
        -- end
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
    end
    return math.floor(nx), math.floor(ny)
end

function TestBattleScene:screenToPos(x, y, anim)
    self._touche1Down = false
    self._touche2Down = false
    local scale = self._sceneLayer:getScale()
    local nx = nil
    if x ~= nil then
        nx = (MAX_SCREEN_WIDTH * 0.5 - x) * scale
    end
    local ny = nil
    if y ~= nil then
        ny = (MAX_SCREEN_HEIGHT * 0.5 - y) * scale
    end
    self:updateScenePos(nx, ny, anim)
end

function TestBattleScene:getSceneLayerPt(touch)
    return self._sceneLayer:screenConvertToNodeSpace(touch:getLocation().x, touch:getLocation().y)
end

function TestBattleScene:getSceneLayerPt_xy(x, y)
    return self._sceneLayer:screenConvertToNodeSpace(x, y)
end

function TestBattleScene:getSceneLayerPoint(touch)
    return self._sceneLayer:screenConvertToNodeSpace(touch.x, touch.y)
end

function TestBattleScene:convertToScreenPt(x, y)
    return self._sceneLayer:nodeConvertToScreenSpace(x, y)
end

function TestBattleScene:convertToNodePt(x, y)
    return self._sceneLayer:screenConvertToNodeSpace(x, y)
end

return TestBattleScene
