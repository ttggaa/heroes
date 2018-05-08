--[[
    @FileName   StarChartsViewMap.lua
    @Authors    zhangtao
    @Date       2018-03-08 10:42:16
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local cc = cc
local GlobalScrollLayer = require "game.view.global.GlobalScrollLayer"
local StarChartsViewMap = class("StarChartsViewMap", GlobalScrollLayer)

local starChartsTab = tab.starCharts
local starChartsStarsTab = tab.starChartsStars
local starPositionTab = tab.starPosition
local starChartsCatenaTab = tab.starChartsCatena

function StarChartsViewMap:ctor(switchCallback, parentView, starId)
    StarChartsViewMap.super.ctor(self)
    self._switchCallback = switchCallback
    self._parentView = parentView
    self._starId = starId
    self.starChartsModel = self._modelMgr:getModel("StarChartsModel")
    self._isTouchBegan = false

    self._bodyNodeTable = {}
    self._touchIsBody = false     ---点击区域是否是星体
    self.selectBodyId = nil       ---当前选中星体的id
    self.includeBodyTable = {}    ---当前星图包含的星体表
    self:initBodyTable()

end

--[[
--! @function initBodyTable
--! @desc 初始化星体表
--! @return 
--]]
function StarChartsViewMap:initBodyTable()
    -- self._starId = 1   --临时设置
    self.includeBodyTable = self.starChartsModel:getBodyIdTable(self._starId)
    local centerBody = starChartsTab[self._starId]["centrality"]
    table.insert(self.includeBodyTable,centerBody)
    self:loadBigMap()
    self:loadStarBody()
end

--[[
--! @function loadBigMap
--! @desc 加载大地图
--! @return 
--]]
function StarChartsViewMap:loadBigMap()
    -- self._usingIcon = {}
    -- self._sectionIcon = {}
    if self._bgLayer ~= nil then self._bgLayer:removeFromParent() self._bgLayer = nil end
    cc.Texture2D:setDefaultAlphaPixelFormat(RGB565)
    self._bgLayer = cc.Sprite:create()
    self._bgLayer:setName("bgLayer")
    self._sceneLayer:addChild(self._bgLayer)
    self._bgLayer:setTexture("asset/uiother/starCharts/starCharts_bg.jpg")
    self._bgLayer:setPosition(self._bgLayer:getContentSize().width/2, self._bgLayer:getContentSize().height/2)
    self._bgLayer:setAnchorPoint(0.5, 0.5)
    -- self._bgLayer:setScale(1)
    cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)

    self.selectNode = StarChartsBody:createSelectedNode()
    self._bgLayer:addChild(self.selectNode,20)
end

--[[
--! @function loadStarBody
--! @desc 初始化星体
--! @return 
--]]
function StarChartsViewMap:loadStarBody()
    if #self.includeBodyTable == 0 then return end
    for k , bodyId in pairs(self.includeBodyTable) do

        local body = StarChartsBody:createStarBody(bodyId)
        self._bodyNodeTable[bodyId] = body
        local postion = starPositionTab[starChartsStarsTab[bodyId]["position"]]["position"]
        -- print("====postion========"..postion[1],postion[2])
        body:setPosition(postion[1],postion[2])
        self._bgLayer:addChild(body,2)
        local touchCallback = function()
            if self.selectBodyId == bodyId then   --选中的是当前星体
            else
                self.selectBodyId = bodyId
                local sortType = starChartsStarsTab[bodyId]["sort"]
                print("====sortType========="..sortType)
                print("====bodyId========="..bodyId)
                self._parentView:switchUIByType(sortType,bodyId)
                --添加选中状态
                self.selectNode:setVisible(true)
                self.selectNode:setPosition(postion[1]+3,postion[2]-1)
            end
            self._touchIsBody = true
        end
        self:registerTouchEventWithAniLight(body,body.touchBtn1,touchCallback)
        self:registerTouchEventWithAniLight(body,body.touchBtn2,touchCallback)
        self:registerTouchEventWithAniLight(body,body.touchBtn3,touchCallback)
    end
end

function StarChartsViewMap:defaultSelect(bodyId)
    self.selectBodyId = bodyId
    local postion = starPositionTab[starChartsStarsTab[bodyId]["position"]]["position"]
    local sortType = starChartsStarsTab[bodyId]["sort"]
    self._parentView:switchUIByType(sortType,bodyId)
    self.selectNode:setVisible(true)
    self.selectNode:setPosition(postion[1]+3,postion[2]-1)
end


function StarChartsViewMap:registerTouchEventWithAniLight(aniBtn,touchBtn, clickCallback) 
    local touchX, touchY = 0, 0   
    registerTouchEvent(touchBtn,
        function ()
            if self._lockTouch == true then return end
            self._touchIsBody = false
            touchX, touchY = self._sceneLayer:getPosition()
            aniBtn.flashes = 50
            local tempFlashes = 0
            if not self._btnSchedule then
                self._btnSchedule = ScheduleMgr:regSchedule(0.1, self,function( )
                    if aniBtn.flashes >= 100 then 
                        tempFlashes = -5
                    end
                    if aniBtn.flashes <= 50 then
                        tempFlashes = 5
                    end
                    aniBtn.flashes = aniBtn.flashes + tempFlashes
                    aniBtn:setBrightness(aniBtn.flashes)
                end)
            end
            aniBtn.downSp = aniBtn:getVirtualRenderer()
        end,
        function ()
            if self._lockTouch == true then return end
            if aniBtn.downSp ~= aniBtn:getVirtualRenderer() then
                aniBtn:setBrightness(0)
            end
        end,
        function ()
            if self._lockTouch == true then return end
            if self._btnSchedule then
                ScheduleMgr:unregSchedule(self._btnSchedule)
                self._btnSchedule = nil
            end
            aniBtn:setBrightness(0)
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
            aniBtn:setBrightness(0)
        end)
    touchBtn:setSwallowTouches(false)
end
function StarChartsViewMap:checkTouchBegan(touchX, touchY)
    print("StarChartsViewMap checkTouchBegan=====")
    self._isTouchBegan = true
    return false
end

function StarChartsViewMap:checkTouchEnd(x,y)
    if (self._isTouchBegan == nil) or (self._isTouchBegan == false) then return true end
    self._isTouchBegan = false
    --是否移动
    print("======StarChartsViewMap checkTouchEnd============")
    local x, y = self._sceneLayer:getPosition()
    if math.abs(self._touchBeganScenePositionX - x) > 10
        or math.abs(self._touchBeganScenePositionY- y) > 10 then 
        return false
    end   
    -- 选中的是否是星体
    if self._touchIsBody == false then    
        --删除星体选中状态
        self.selectNode:setVisible(false)
        --将右侧面板重置为通用面板
        self._parentView:switchUIByType(0)

        self.selectBodyId = nil
    else
        self._touchIsBody = false
    end
    return false
end

function StarChartsViewMap:updateBodyNode(bodyId)
    local bodySortType = starChartsStarsTab[tonumber(bodyId)]["sort"]   --星体类型
    local updateUnKnowBody = function(id)
        for k , v in pairs(self._bodyNodeTable) do
            local bodySortType = starChartsStarsTab[tonumber(k)]["sort"]   --星体类型
            -- local locked = self.starChartsModel:checkOrLock(k)
            local showAni = false
            if tonumber(bodySortType) == 3 and tonumber(k) ~= tonumber(id) then
                local unlock_num = starChartsStarsTab[tonumber(k)]["unlock_num"]
                local canActive,activeNum = self.starChartsModel:checkActiveState(k)
                local isAdjacent = self.starChartsModel:checkBodyAdjacent(bodyId,k)    --是否相邻
                if tonumber(unlock_num) == tonumber(activeNum) and isAdjacent and canActive then
                    showAni = true
                end
            end
            if showAni then
                local updateBody = function()
                    StarChartsBody:updateStarBody(k,v)
                    self._parentView:addCanActivityAni(self._starId)
                end
                StarChartsBody:jieSuo1Ani(v,updateBody)
            else
                self._parentView:addCanActivityAni(self._starId)
            end
        end
    end

    local bodyNode = self._bodyNodeTable[bodyId]
    if bodyNode.completedAni ~= nil then
        bodyNode.completedAni:removeFromParentAndCleanup(true)
        bodyNode.completedAni = nil
    end
    local updateBody = function()
        StarChartsBody:updateStarBody(bodyId,bodyNode)
        if tonumber(bodySortType) == 3 then
            updateUnKnowBody(bodyId)
        else
            updateUnKnowBody(-1)
        end
    end
    StarChartsBody:jieSuo2Ani(bodyNode,updateBody)

    -- if tonumber(bodySortType) == 3 then
    --     local bodyNode = self._bodyNodeTable[bodyId]

    -- else
    --     local bodyNode = self._bodyNodeTable[bodyId]
    --     StarChartsBody:updateStarBody(bodyId,bodyNode)
    --     --判断未知星体是否可解锁
    --     updateUnKnowBody(-1)
    -- end

    
end
--重置星图
function StarChartsViewMap:resetAllBodyState()
    self.selectBodyId = nil
    self.selectNode:setVisible(false)
    for id , bodyNode in pairs(self._bodyNodeTable) do
        StarChartsBody:updateStarBody(id,bodyNode)
        if bodyNode.completedAni ~= nil then
            bodyNode.completedAni:removeFromParentAndCleanup(true)
            bodyNode.completedAni = nil
        end
    end
end

--星体添加分支选中动画
function StarChartsViewMap:bodyAddAni1(bodyId)
    local bodyNode = self._bodyNodeTable[bodyId]
    StarChartsBody:bodyAddAni1(bodyId,bodyNode)
end

function StarChartsViewMap:deleateBodyAni()
    for _,node in pairs(self._bodyNodeTable) do
        if node.ani1 ~= nil then
            node.ani1:removeFromParentAndCleanup(true)
            node.ani1 = nil
        end
    end
end

--添加中心星体动画
function StarChartsViewMap:addCenterBodyAni(bodyId,isComplete)
    local bodyNode = self._bodyNodeTable[bodyId]
    StarChartsBody:updateCenterBodyAni(bodyId,bodyNode,isComplete)
end

--可激活动画
function StarChartsViewMap:addCompletedAni(bodyId)
    local bodyNode = self._bodyNodeTable[bodyId]
    if bodyNode.completedAni == nil then
        StarChartsBody:addCompletedAni(bodyNode)
    end

end

function StarChartsViewMap:onExit()
    StarChartsViewMap.super.onExit(self)
    setMultipleTouchDisabled()
end


function StarChartsViewMap:onHide()
    setMultipleTouchDisabled()
    self:lockTouch() 
end

function StarChartsViewMap:onTop()
    setMultipleTouchEnabled()
    if self.__guideLock  ~= true then 
        self:unLockTouch()
    end
end

function StarChartsViewMap:onEnter()
    print("StarChartsViewMap:onEnter")
    StarChartsViewMap.super.onEnter(self)
    setMultipleTouchEnabled()
end


function StarChartsViewMap:getMaxScrollHeightPixel(inScale)
    return 960
end

function StarChartsViewMap:getMaxScrollWidthPixel(inScale)
    return 1664
end

function StarChartsViewMap:getMinScale()
    return 0.75
end

function StarChartsViewMap:getMaxScale()
    return 1.25
end

function StarChartsViewMap.dtor()
    cc = nil
end


return StarChartsViewMap
