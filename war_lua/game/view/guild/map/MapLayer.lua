--[[
    Filename:    MapLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-13 11:14:27
    Description: File description
--]]


local GlobalScrollLayer = require "game.view.global.GlobalScrollLayer"
local MapLayer = class("MapLayer", GlobalScrollLayer, require("game.view.guild.GuildBaseView"))

function MapLayer:ctor()
    MapLayer.super.ctor(self)
    self:onInit()
end

--Grid
function MapLayer:g(_a,_b)
    if nil == _b then
         return { x = _a.a, b = _a.b } 
    else
         return { a = _a, b = _b }
    end
end



function MapLayer:onEnter()
    MapLayer.super.onEnter(self)
    setMultipleTouchDisabled()
end

function MapLayer:onInit()

    self._nearTipGrow = {}
    self._nearTipPic = {}

    self._nearGrow = {}
    self._nearPic = {}
    -- self._nearLockPic = {}
    self._curGrid = nil
    self._gridFogs = {}

    -- x1 = x1 + (x2 - x1) * 0.2
    -- y2 = y2 + (y2 - x1) * 0.2
    cc.Texture2D:setDefaultAlphaPixelFormat(RGB565)
    self._bgLayer = cc.Sprite:create()
    self._bgLayer:setName("bgLayer")
    self._sceneLayer:addChild(self._bgLayer)
    -- self._bgLayer:setTexture(self:getMapBg())
    self._bgLayer:setAnchorPoint(0.5,0.5)
    self._bgLayer:setScale(self:getInitScale())
    if MAX_SCREEN_HEIGHT > self:getMaxScrollHeightPixel() then
        self._sceneLayer:setScale(MAX_SCREEN_HEIGHT / self:getMaxScrollHeightPixel())
    end
    self._bgLayer:setContentSize(self:getMaxScrollWidthPixel(), self:getMaxScrollHeightPixel())
    self._bgLayer:setPosition(self._bgLayer:getContentSize().width/2, self._bgLayer:getContentSize().height/2)
    -- local tempSprite = cc.Sprite:create(self:getMapBg())
    -- tempSprite:setPosition(self:getMaxScrollWidthPixel()/2, self:getMaxScrollHeightPixel()/2)
    -- self._bgLayer:addChild(tempSprite)
    -- tempSprite:setScale(1.39)


    -- local bgLayer = ccui.Layout:create()
    -- bgLayer:setBackGroundColorOpacity(180)
    -- bgLayer:setBackGroundColorType(1)
    -- bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    -- -- bgLayer:setTouchEnabled(true)
    -- bgLayer:setContentSize(self:getMaxScrollWidthPixel(), self:getMaxScrollHeightPixel())
    -- self._bgLayer:addChild(bgLayer)
    if type(self:getMapBg()) == "string" then
        self._bgSprite = cc.Sprite:createWithSpriteFrameName(self:getMapBg() .. ".jpg")
        self._bgSprite:setPosition(self:getMaxScrollWidthPixel()/2, self:getMaxScrollHeightPixel()/2)
        self._bgLayer:addChild(self._bgSprite, 1)
        self._bgSprite:setName("mapBg")
    else
        self._bgSprite = cc.Sprite:create()
        self._bgSprite:setContentSize(self:getMaxScrollWidthPixel(), self:getMaxScrollHeightPixel())
        self._bgSprite:setPosition(self:getMaxScrollWidthPixel()/2, self:getMaxScrollHeightPixel()/2)
        self._bgLayer:addChild(self._bgSprite, 1)
        self._bgSprite:setName("mapBg")
        for k,v in pairs(self:getMapBg()) do
            local chipSp = cc.Sprite:create(v)
            if k == 1 then 
                chipSp:setAnchorPoint(0, 1)
                chipSp:setPosition(0, self:getMaxScrollHeightPixel())
            elseif k == 2 then 
                chipSp:setAnchorPoint(1, 1)
                chipSp:setPosition(self:getMaxScrollWidthPixel(), self:getMaxScrollHeightPixel())
            elseif k == 4 then 
                chipSp:setAnchorPoint(0, 0)
                chipSp:setPosition(0, 0)
            elseif k == 3 then 
                chipSp:setAnchorPoint(1, 0)
                chipSp:setPosition(self:getMaxScrollWidthPixel(), 0)
            end
            chipSp:setScale(1.3515625)
            self._bgSprite:addChild(chipSp)
        end
    end
	if self._settingData and self._settingData.isCenter and ADOPT_IPHONEX then
		self._bgSprite:setPositionX(MAX_SCREEN_WIDTH/2)
	end
    cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)

    -- if self:getMapMask() ~= "" then
    --     local tempSprite = cc.Sprite:create(self:getMapMask())
    --     tempSprite:setPosition(self._bgSprite:getContentSize().width/2, self._bgSprite:getContentSize().height/2)
    --     self._bgSprite:addChild(tempSprite, 299)
    -- end


    -- for i=1,6 do
    --     self._nearTipGrow[i] = mcMgr:createViewMC("xuanzhongjiantou" .. i .. "_guildmapselected", true)
    --     self._nearTipGrow[i]:setVisible(false)
    --     self._bgSprite:addChild(self._nearTipGrow[i], 9)
    -- end

    -- self._curTipMc = mcMgr:createViewMC("xuanzhonggezi_guildmapselected", true)   --蓝尖 当前关
    -- self._bgSprite:addChild(self._curTipMc, 9)
    -- self._curTipMc:setVisible(false)



    for i=1,6 do
        self._nearGrow[i] = mcMgr:createViewMC("jiantou" .. i .. "_dangqian", true)
        self._nearGrow[i]:setVisible(false)
        self._bgSprite:addChild(self._nearGrow[i], 9)

        self._nearPic[i] = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp9.png")
        self._nearPic[i]:setVisible(false)
        self._bgSprite:addChild(self._nearPic[i], 8)
    end

    self._curPlayerMc = mcMgr:createViewMC("dangqianweizhi_dangqian", true)   --绿色尖 当前关
    self._bgSprite:addChild(self._curPlayerMc, 9)
    self._curPlayerMc:setVisible(false)

    self._guideArrow = ccui.Widget:create()
    self._guideArrow:setAnchorPoint(0.5, 1)
    self._guideArrow:setVisible(false)
    self:addChild(self._guideArrow)

    registerClickEvent(self._guideArrow, function (sender)
        if self["touchGuideArrow"] ~= nil then 
            self["touchGuideArrow"](self, sender)
        end
    end)
-- guildMapBtn_iconMask.png


-- guildMapBtn_heroIconCircle.png


    self._intScale = self:getGridScale()

    local x1, y1 = self:getFirstGridPoint()
    local x, y = 0, 0
    self._shapes = {}



    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    self._guildMapModel:initShapes(self:g(self:getMaxHorizontalGrid(), self:getMaxVerticalGrid()), cc.p(self:getFirstGridPoint()), self._intScale, function(a, b) return self:g(a, b) end )
    self._shapes = self._guildMapModel:getShapes()
end


function MapLayer:screenToGrid(inA, inB, inAnim, inCallback, useEase, timePer, makeTime)
    local anim = false
    if inAnim ~= nil then 
        anim = inAnim
    end
    local gridPos = self._shapes[inA .. "," .. inB].pos
    local pt1 = self._bgSprite:convertToWorldSpace(cc.p(gridPos.x, gridPos.y))
    local pt2 = self._bgLayer:convertToNodeSpace(pt1)

    self:screenToPos(pt2.x, pt2.y, anim, inCallback, useEase, timePer, makeTime)
end

function MapLayer:moveToGrid(inMc, inA, inB, inAnim, isFollowScreen, inCallback)
    local gridPos = self._shapes[inA .. "," .. inB].pos
    self:moveToGridPoint(inMc, gridPos.x, gridPos.y, inAnim, isFollowScreen, inCallback)
end

function MapLayer:moveToGridPoint(inMc, inX, inY, inAnim, isFollowScreen, inCallback)
    local anim = false
    if inAnim ~= nil then 
        anim = inAnim
    end

    if inX > inMc:getPositionX() then 
        inMc:setFlipX(false)
        if inMc.nameBg ~= nil then 
            inMc.nameBg:setScaleX(1 * math.abs(inMc.nameBg:getScaleX()))
        end

        if inMc.progress ~= nil then 
            inMc.progress:setScaleX(1 * math.abs(inMc.progress:getScaleX()))
        end
    else
        inMc:setFlipX(true)
        if inMc.nameBg ~= nil then 
            inMc.nameBg:setScaleX(-1 * math.abs(inMc.nameBg:getScaleX()))
        end

        if inMc.progress ~= nil then 
            inMc.progress:setScaleX(-1 * math.abs(inMc.nameBg:getScaleX()))
        end
    end
    inMc:stopAllActions()

    local pt1 = self._bgSprite:convertToWorldSpace(cc.p(inX, inY))
    local pt2 = self._bgLayer:convertToNodeSpace(pt1)
    if isFollowScreen ==  true then
        self:screenToPos(pt2.x, pt2.y, anim, nil)
    end
    if anim == true then
        local action1 = cc.MoveTo:create(0.5, cc.p(inX, inY))
        local callFunc = cc.CallFunc:create(function()
            if inCallback ~= nil then 
                inCallback(inX, inY)
            end
        end)
        
        inMc:runAction(cc.Sequence:create(action1, callFunc))
    else
        inMc:setPosition(inX, inY)
        if inCallback ~= nil then 
            inCallback(inX, inY)
        end
    end
end

--[[
--! @function updateNearLocation
--! @desc 更新当前位置状态
--! @return 
--]]
function MapLayer:updateNearLocation()
    -- self._nearGrids = self:getNearGrids(tonumber(self._curGrid.a), tonumber(self._curGrid.b))
    local nearGrids = self:getNearGrids(tonumber(self._curGrid.a), tonumber(self._curGrid.b))
    for i=1,6 do
        local tempGrid = nearGrids[i]
        if tempGrid.isLockState == 1 then
            self._nearGrow[i]:setVisible(true)
            self._nearGrow[i]:setPosition(self._shapes[tempGrid.grid.a .. "," .. tempGrid.grid.b].pos)
            self._nearGrow[i].gridKey = tempGrid.grid.a .. "," .. tempGrid.grid.b

            self._nearPic[i]:setVisible(true)
            self._nearPic[i]:setPosition(self._shapes[tempGrid.grid.a .. "," .. tempGrid.grid.b].pos)      
        else
            self._nearGrow[i].gridKey = nil
            self._nearGrow[i]:setVisible(false)
            self._nearPic[i]:setVisible(false)
         end
    end
end


function MapLayer:getCircleGrids(inA, inB, inNum)
    local tempCircleGrids = {}
    local tempNum = 0
    local function circleGrid(inSubA, inSubB, inTempNum)
        if inTempNum > inNum then 
            return 
        end
        local tempGrids = self:getNearGrids(inSubA, inSubB)
        for k,v in pairs(tempGrids) do
            if tempCircleGrids[v.grid.a .. "," .. v.grid.b] == nil then 
                v.grid.dis = inTempNum
                tempCircleGrids[v.grid.a .. "," .. v.grid.b] = v.grid
            end
        end
        for k,v in pairs(tempGrids) do
            circleGrid(v.grid.a, v.grid.b, inTempNum + 1)
        end        
    end
    circleGrid(inA, inB, tempNum + 1)
    return tempCircleGrids
end

--[[
--! @function getNearGrids
--! @desc 获得附近格子
--! @param  a 纵列
--! @param  b 横列
--! @return 
--]]
function MapLayer:getNearGrids(a, b)
    if self._shapes[a .. "," .. b] == nil then return {} end
    local tmpGrids = self._shapes[a .. "," .. b].nearGrids
    if tmpGrids ~= nil then 
        return tmpGrids
    else
        tmpGrids = {}
    end
   local touchGridStage = self:getGridState(a, b)
    for i=1,6 do
        local tempA
        local tempB
        if math.mod(b, 2) == 0 then
            if i == 1 then 
                tempA = a - 1
                tempB = b   
            elseif i == 2 then 
                tempA = a
                tempB = b - 1
            elseif i == 3 then 
                tempA = a + 1
                tempB = b - 1
            elseif i == 4 then 
                tempA = a + 1
                tempB = b     
            elseif i == 5 then 
                tempA = a + 1
                tempB = b + 1
            elseif i == 6 then 
                tempA = a 
                tempB = b + 1 
            end
        else
           if i == 1 then 
                tempA = a - 1
                tempB = b       
            elseif i == 2 then 
                tempA = a - 1
                tempB = b - 1
            elseif i == 3 then 
                tempA = a
                tempB = b - 1
            elseif i == 4 then
                tempA = a + 1
                tempB = b  
            elseif i == 5 then 
                tempA = a 
                tempB = b + 1
            elseif i == 6 then 
                tempA = a - 1
                tempB = b + 1                    
            end
        end
        tmpGrids[i] = {}
        tmpGrids[i].grid = self:g(tempA, tempB)
        -- if self:getGridThroughState(i, a, b ,tempA , tempB) ~= 0 then 
        if touchGridStage == 1 then
            tmpGrids[i].isLockState = self:getGridThroughState(a, b ,tempA , tempB)
        else
            tmpGrids[i].isLockState = 0
        end
        -- else
        --     tmpGrids[i].isLockState = true
        -- end
    end
    self._shapes[a .. "," .. b].nearGrids = tmpGrids
    return tmpGrids
end

function MapLayer:getGridThroughState(a, b)
    return 1
end

function MapLayer:getGridState(a, b)
    return 1
end

function MapLayer:evaluatePointToLine(x, y, x1, y1, x2, y2)
    local a = y2 - y1
    local b = x1 - x2
    local c = x2 * y1 - x1 * y2
    return a * x + b * y + c
end

function MapLayer:isPointInTriangle(x, y, x1, y1, x2, y2, x3, y3)
    local d1 = self:evaluatePointToLine(x, y, x1, y1, x2, y2)
    local d2 = self:evaluatePointToLine(x, y, x2, y2, x3, y3)
    if (d1 * d2 < 0) then
        return false
    end
    local d3 = self:evaluatePointToLine(x, y, x3, y3, x1, y1)
    if (d2 * d3 < 0) then
        return false
    end
    return true
end

function MapLayer:isPointIn6bianxing(centerx, centery, clickx, clicky, scale)
    local pt = 
    {
        {75, 36}, {103, -15}, {28, -52}, {-76, -36}, {-103, 15}, {-28, 52}
    }
    if scale == nil then
        scale = 1
    end

    local x1 = centerx + pt[1][1] * scale
    local y1 = centery + pt[1][2] * scale
    local x2 = centerx + pt[2][1] * scale
    local y2 = centery + pt[2][2] * scale
    if self:isPointInTriangle(clickx, clicky, centerx, centery, x1, y1, x2, y2) then 
        return true
    end

    local x1 = centerx + pt[2][1] * scale
    local y1 = centery + pt[2][2] * scale
    local x2 = centerx + pt[3][1] * scale
    local y2 = centery + pt[3][2] * scale
    if self:isPointInTriangle(clickx, clicky, centerx, centery, x1, y1, x2, y2) then 
        return true
    end

    local x1 = centerx + pt[3][1] * scale
    local y1 = centery + pt[3][2] * scale
    local x2 = centerx + pt[4][1] * scale
    local y2 = centery + pt[4][2] * scale
    if self:isPointInTriangle(clickx, clicky, centerx, centery, x1, y1, x2, y2) then 
        return true
    end

    local x1 = centerx + pt[4][1] * scale
    local y1 = centery + pt[4][2] * scale
    local x2 = centerx + pt[5][1] * scale
    local y2 = centery + pt[5][2] * scale
    if self:isPointInTriangle(clickx, clicky, centerx, centery, x1, y1, x2, y2) then 
        return true
    end

    local x1 = centerx + pt[5][1] * scale
    local y1 = centery + pt[5][2] * scale
    local x2 = centerx + pt[6][1] * scale
    local y2 = centery + pt[6][2] * scale
    if self:isPointInTriangle(clickx, clicky, centerx, centery, x1, y1, x2, y2) then 
        return true
    end

    local x1 = centerx + pt[6][1] * scale
    local y1 = centery + pt[6][2] * scale
    local x2 = centerx + pt[1][1] * scale
    local y2 = centery + pt[1][2] * scale
    if self:isPointInTriangle(clickx, clicky, centerx, centery, x1, y1, x2, y2) then 
        return true
    end
end



function MapLayer:checkTouchBegan(x, y)
    print("checkTouchBegan=================")
    self._touchDown = true
end

--[[
--! @function touchIcon
--! @desc 点击事件
--！@param x x坐标
--！@param y y坐标
--! @return 
--]]
function MapLayer:checkTouchEnd(x, y)
    print("checkTouchEnd=================================")
    if GuildConst.TAKE_PHOTO == true then 
        local render = cc.RenderTexture:create(self._bgLayer:getContentSize().width , self._bgLayer:getContentSize().height, RGBA8888, gl.DEPTH24_STENCIL8_OES)
        render:begin()
        self._bgLayer:visit()
        render:endToLua()
        render:saveToFile("test.png", cc.IMAGE_FORMAT_PNG)     
        cc.Director:getInstance():flushScene()

        local pImagePix = render:newImage(true)

        render:clear(0, 0, 0, 0)
        pImagePix:release()
    end
    -- self:update()
    self._cacheMoveX = nil 
    self._cacheMoveY = nil    
    if x == nil or y == nil then   
        return false
    end
    print("self._touchDown================", self._touchDown)
    if self._touchDown == false then return end
    self._touchDown = false
    if self._touchBeganPositionX == nil then return false end
    if math.abs(self._touchBeganPositionX - x) > 10
        or math.abs(self._touchBeganPositionY- y) > 10 then
        return false
    end
    
    local touchShape = {}
    local minLen = 3000
    local touchGridKey = 0
    local tempSpaces = {}
    local pt1 = self._bgSprite:convertToNodeSpace(cc.p(x, y))
    for i,v in pairs(self._shapes) do
        local dx = pt1.x - v.pos.x
        local dy = pt1.y - v.pos.y
        local dis = dx * dx + dy * dy
        if minLen > dis then   
            tempSpaces[i] = v.pos
            minLen = dis
        end
    end
    for i,v in pairs(tempSpaces) do
        if self:isPointIn6bianxing(v.x, v.y, pt1.x, pt1.y , self._intScale) then 
            touchGridKey = i
            break
        end
    end
    if touchGridKey ~= ""  then 
        local touchGrid = self._shapes[touchGridKey]
        if touchGrid == nil  then 
            return true
        end
        local isTag = self:getTagTouchState()
        if isTag == true then 
            self:touchTagEvent(touchGrid.grid.a, touchGrid.grid.b, touchGrid.pos.x, touchGrid.pos.y)
            return
        end
		local isYearTrans = self:getYearTransTouchState()
		if isYearTrans then
			self:touchYearTransEvent(touchGrid.grid.a, touchGrid.grid.b, touchGrid.pos.x, touchGrid.pos.y)
			return
		end
        local isTouchOk = false
        if self._curGrid then
            local nearGrids = self:getNearGrids(self._curGrid.a, self._curGrid.b)
            for k,v in pairs(nearGrids) do
                if v.grid.a == touchGrid.grid.a and 
                    v.grid.b == touchGrid.grid.b and
                    v.isLockState == 1 then
                    isTouchOk = true
                end
            end
            if (self._curGrid.a .. "," .. self._curGrid.b) == touchGridKey then 
                isTouchOk = true
            end
        end
        if not isTouchOk then
            self:touchRemoteGridEvent(touchGrid.grid.a, touchGrid.grid.b, touchGrid.pos.x, touchGrid.pos.y)
            return
        end
        
        self:touchGridEvent(touchGrid.grid.a, touchGrid.grid.b, touchGrid.pos.x, touchGrid.pos.y)
    end
    return true
end



function MapLayer:update(dt)
    -- if self._touchDown then 
    self:updateTouch()
    if self._touchDown and self._intanceMcAnimNode then
        if self._cacheMoveX ~= self._touchMoveX or 
            self._cacheMoveY ~= self._touchMoveY then 
            local pt1 = self._bgSprite:convertToWorldSpace(cc.p(self._intanceMcAnimNode:getPositionX(), self._intanceMcAnimNode:getPositionY()))
            if cc.rectContainsPoint(self:getBoundingBox(), pt1) then 
                self._guideArrow:setVisible(false)
            else
                self._guideArrow:setVisible(true)
                -- local pt2 = cc.p(self:getContentSize().width/2, self:getContentSize().height/2)
                -- local pt2 = cc.p(self._touchBeganPositionX, self._touchBeganPositionY)
                local pt2 = cc.p(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)

                local angle = 360 -  MathUtils.angleAtan2(pt1, pt2)
                self._guideArrow:setRotation(angle)
                local pt3 = self:getTipArrowPosition(pt2, pt1)
                -- print("self:getTipArrowPosition(pt1, pt2)========",pt3.x, pt3.y, angle)
                -- pt3.y = pt3.y + self._guideArrow:getContentSize().height/2
                self._guideArrow:setPosition(pt3)
                self._guideArrow:getChildByName("headClip"):setRotation(-angle)
            end

            self._cacheMoveX = self._touchMoveX 
            self._cacheMoveY = self._touchMoveY
        end     
    end
    self:timeUpdate()
end

function MapLayer:getTipArrowPosition(pt1, pt2)
    local a1 = math.abs(math.atan2(math.abs(pt2.x- pt1.x ), math.abs(pt2.y - pt1.y)) * 180 / math.pi )
    local a2 = math.abs(math.atan2(MAX_SCREEN_WIDTH,  MAX_SCREEN_HEIGHT)* 180 / math.pi )
    local x, y = 0 , 0
    if a1 < a2 then 
        -- if pt2.y >= MAX_SCREEN_HEIGHT or pt2.y <= 0 then 
        x = pt1.x + (pt2.x - pt1.x) * math.abs((MAX_SCREEN_HEIGHT / 2) / (pt1.y - pt2.y))
        if pt2.y < pt1.y then
            y = 0
        else
            y = MAX_SCREEN_HEIGHT
        end
    else

        y = pt1.y + (pt2.y - pt1.y) * math.abs((MAX_SCREEN_WIDTH / 2)  / (pt1.x - pt2.x))
        if pt2.x < pt1.x then
            x = 0
        else
            x = MAX_SCREEN_WIDTH
        end
    end
    return cc.p(x, y)
end

function MapLayer:getTagTouchState()
    return false
end

function MapLayer:touchGridEvent(a, b)

end

function MapLayer:getMaxScrollHeightPixel(inScale)
    return 1457
end

function MapLayer:getMaxScrollWidthPixel(inScale)
    return 2848
end

function MapLayer:getMapBg()
    return "asset/uiother/guild/guild_map.jpg"
end


-- function MapLayer:getMapMask()
--     return "asset/uiother/guild/guild_mask_map.png"
-- end

function MapLayer:getGridScale()
    return 0.74
end

function MapLayer:getMaxVerticalGrid()
    return 14
end

function MapLayer:getMaxHorizontalGrid()
    return 16
end


function MapLayer:getFirstGridPoint()
    return 1070, 990
end

function MapLayer:onMouseScrollEx()
    return false
end

function MapLayer:timeUpdate()
    return
end


return MapLayer

