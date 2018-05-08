--[[
    Filename:    IntanceMapLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-08-15 11:20:22
    Description: File description
--]]
local cc = cc
local IntanceMapLayer = class("IntanceMapLayer" ,BaseMvcs ,cc.Layer)

require "game.view.intance.IntanceConst"

--[[
 @desc  创建
 @param inParent 上层界面
 @return 
--]]
function IntanceMapLayer:ctor(inParent, inLayerNode)
    IntanceMapLayer.super.ctor(self)
    self:setClassName("IntanceMapLayer")
    self._parentView = inParent
    self._layerNode = inLayerNode
    self._lockCount = 0
    self._touchMoveX = 0
    self._touchMoveY = 0
    self._touchDown = false
    self._curOffsetMinX = 0
    self._curOffsetMinY = 0
    self._curOffsetMaxX = 0
    self._curOffsetMaxY = 0
    self._showOffsetX = 0
    self._showOffsetY = 0
    self._curSelectedNode = nil
    self._backStageNode = nil
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            ScheduleMgr:cleanMyselfDelayCall(self)
            if self._depleteSchedule ~= nil then 
                ScheduleMgr:unregSchedule(self._depleteSchedule)
                self._depleteSchedule = nil
                UIUtils:reloadLuaFile("intance.IntanceMapLayer")
                UIUtils:reloadLuaFile("intance.IntanceStageInfoNode")
            end
            mcMgr:clear()
        elseif eventType == "enter" then 
        end
    end)


    self._sceneLayer = cc.Sprite:create()
    self._sceneLayer:setPosition(IntanceConst.MAX_SCREEN_WIDTH * 0.5, IntanceConst.MAX_SCREEN_HEIGHT * 0.5)
    self._sceneLayer:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(self._sceneLayer)
    self._sceneLayer:setContentSize(cc.size(IntanceConst.MAX_VIEW_WIDTH_PIXEL, IntanceConst.MAX_VIEW_HEIGHT_PIXEL))

    self:initEvent()


    self:screenToPos(100,748, false)

    --  监测touch
    self._depleteSchedule = ScheduleMgr:regSchedule(1, self, function()
        self:update()
    end)

    -- 为了提速延迟创建
    -- ScheduleMgr:delayCall(0, self, function()
    self._intanceStageInfoNode = self._parentView:createLayer("intance.IntanceStageInfoNode")
    -- self._intanceStageInfoNode:setName("IntanceStageInfoNode")
    self._layerNode:addChild(self._intanceStageInfoNode, 2)
    
    self._intanceStageInfoNode:setVisible(false)
    self._intanceStageInfoNode:setHideCallback(function(isClose) self:hideStageInfo(isClose) end)
    self._intanceStageInfoNode:setBattleFinishCallback(
        function(inStageId, inWinType, inFinishType)
            self:completeStageActoin(inStageId, inWinType, inFinishType)  
        end)
    -- end)

    -- -- 异步加载图片
    -- self:exitBattle()

end


function IntanceMapLayer:enterWorld()
    self._curSelectedNode:releaseAminLayer(true)
end

function IntanceMapLayer:enterBattle()
    self._curSelectedNode:releaseAminLayer(true)
    self._curSelectedNode:setBgTexture(true)
    -- self._bgLayer:setTexture(UIUtils.noPic)
    self._viewMgr:removeTexture(self._parentView:getClassName(), "asset/uiother/map/chaodaditu.jpg")
    self._viewMgr:removeTexture(self._parentView:getClassName(), self._curSelectedNode:getBgName())
    if self._bgLayer ~= nil then 
        self._bgLayer:removeFromParent()
        self._bgLayer = nil
    end
end


function IntanceMapLayer:exitBattle()
    if BattleUtils.loseReturnMainind then return end
    self._curSelectedNode:setBgTexture()
    if self._intanceStageInfoNode:getUserUpdateState() then 
        return
    end
    self._curSelectedNode:runAminLayer()
end

function IntanceMapLayer:reflashUI(data)
    self._curSectionId = data.curSectionId
    self._quickStageId = data.quickStageId
    self:loadSection(data.quickStageId)
end

-- function IntanceMapLayer:quickGoNextSection(inCurSectionId)
--     IntanceConst.GO_STAR_POINT = inCurSectionId
--     self._parentView:updateSectionInfo(inCurSectionId)
--     self:goNextSection(inCurSectionId, false, false)
-- end


function IntanceMapLayer:setSwitchSectionBegin()
    self._curSelectedNode:setSwitchSectionBegin(true)
end

function IntanceMapLayer:setSwitchSectionFinish()
    self._curSelectedNode:setSwitchSectionFinish(true)
end



function IntanceMapLayer:showSimpleStoryPlot(inCurSectionId, inTouchBtn)
    local sysMainSectionMap = tab:MainSectionMap(self._curSectionId)
    if sysMainSectionMap.plotEnd ~= nil then
        self._viewMgr:showView("intance.IntanceMcPlotView", {plotId = sysMainSectionMap.plotEnd, callback = function()
            self._viewMgr:popView()
        end})
        return
    end
end

--[[
--! @function showStoryPlot
--! @desc 展示剧情，如果没有剧情展示则直接走goNextSectionAction
--! @param  inCurSectionId 副本章id
--! @param  inTouchBtn 是否点击特殊判断 
--! @return 
--]]
function IntanceMapLayer:showStoryPlot(inCurSectionId, inTouchBtn)
    local sysMainSectionMap = tab:MainSectionMap(self._curSectionId)
    if sysMainSectionMap.plotEnd ~= nil then
        self._viewMgr:showView("intance.IntanceMcPlotView", {plotId = sysMainSectionMap.plotEnd, callback = function()
            self._viewMgr:popView()
            SystemUtils.saveAccountLocalData("GO_STAR_POINT", inCurSectionId)
            -- IntanceConst.GO_STAR_POINT = inCurSectionId
            if IntanceConst.FIRST_SECTION_ID + 1 < inCurSectionId and inTouchBtn == true then
                self._parentView:switchWorldLayer(true, inCurSectionId)
            else
                self._parentView:forceGoToSection(inCurSectionId)
            end
        end})
        return
    end
    self:goNextSectionAction(inCurSectionId, inTouchBtn)
end

--[[
--! @function goNextSectionAction
--! @desc 前往下一章动画
--! @param  inCurSectionId 副本章id
--! @param  inTouchBtn 是否点击特殊判断 
--! @return 
--]]
function IntanceMapLayer:goNextSectionAction(inCurSectionId, inTouchBtn)
    self._curSelectedNode:setCompleteCallback(function()
        self:setLockMap(true)
        self._curSelectedNode:setHeroRunningCallback(function()
            -- IntanceConst.GO_STAR_POINT = inCurSectionId
            SystemUtils.saveAccountLocalData("GO_STAR_POINT", inCurSectionId)
            if IntanceConst.FIRST_SECTION_ID + 1 < inCurSectionId and inTouchBtn == true then
                self._parentView:switchWorldLayer(true, inCurSectionId)
            else
                self._parentView:forceGoToSection(inCurSectionId)
            end
        end)
        self._curSelectedNode:heroRunningAmin(1)
    end)
    self._curSelectedNode:activeStageBuilding()
end


function IntanceMapLayer:confirmEnterNextStection(inNewSectionId) 
    print("confirmEnterNextStection==============================================")
    -- local bgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 120))
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(120)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(IntanceConst.MAX_SCREEN_WIDTH, IntanceConst.MAX_SCREEN_HEIGHT)
    self._parentView:addChild(bgLayer, 1000)
    self:setLockMap(true)
    local amin1 = mcMgr:createViewMC("run_nextsection", false, true, function(_, sender)
        
        local userInfo = self._modelMgr:getModel("UserModel"):getData()
        local sysSection = tab:MainSection(inNewSectionId)
        local callbackCode, otherParam = IntanceUtils:checkPreSection(self._curSectionId, sysSection)
        print("callbackCode=====================", callbackCode)
        if callbackCode ~= 0 then 
            self:setLockMap(false)
            bgLayer:removeFromParent()    
            self:showSimpleStoryPlot(inNewSectionId, true)      
            return    
        end
        
        local param = {sectionId = inNewSectionId, type = 1}
        self._serverMgr:sendMsg("StageServer", "setSectionId", param, true, {}, function (result)
            self:setLockMap(false)
            bgLayer:removeFromParent()
            if result == nil or result["d"] == nil then 
                return 
            end
            self:showStoryPlot(inNewSectionId, true)
        end)

    end, nil, false)
    amin1:addCallbackAtFrame(37, function()
        audioMgr:playSound("NewChapter_2")
    end)
    amin1:setPosition(IntanceConst.MAX_SCREEN_WIDTH/2, IntanceConst.MAX_SCREEN_HEIGHT/2 + 100)
    bgLayer:addChild(amin1)
    audioMgr:playSound("NewChapter_1")
end

--[[
--! @function completeStageActoin
--! @desc 异步加载资源
--! @param  inStageId 副本id
--! @param  inWinType 战斗结果类型 
--! @return 
--]]
function IntanceMapLayer:completeStageActoin(inStageId, inWinType, inFinishType)
    -- self._curSelectedNode:setTexture(self._curSelectedNode:getBgName())
    -- self._touchDispatcher:resumeEventListenersForTarget(self,false)

    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local mainsData = intanceModel:getData().mainsData
    local stageInfo = intanceModel:getStageInfo(inStageId)
    local curSectionId = tonumber(string.sub(inStageId, 1 , 5))
    local newSectionId = tonumber(string.sub(mainsData.curStageId, 1 , 5))
    if inWinType ~= 2 then 
        -- self._intanceMcAnimNode:runStandBy()
        self:setLockMap(false)
        return
    end
    self:setLockMap(true)
    

    -- 通关后播放动画
    local lastSectionId = tab:Setting("G_FINISH_SECTION_STORY").value

    local lastSysSection = tab:MainSection(lastSectionId)

    local lastStageId = lastSysSection.includeStage[#lastSysSection.includeStage]

    if (newSectionId ~= curSectionId and 
        inFinishType == IntanceConst.FINISH_WAR_TYPE.FIRST_WAR and 
        mainsData.acSectionId < newSectionId) or 
        (   -- 最后一关时要特殊判断
            lastSectionId == curSectionId and 
            inFinishType == IntanceConst.FINISH_WAR_TYPE.FIRST_WAR and 
            lastStageId == inStageId) then

        self:updateSectionInfo(curSectionId)

        local offset = self._curSelectedNode:getNextBuildOffset(inStageId)
        local stageView = self._curSelectedNode:getStageBuildingById(inStageId)
        self:screenToObject(stageView, offset, true)
        self._curSelectedNode:setCompleteCallback(function()
            if (mainsData.acSectionId < newSectionId) or (lastSectionId == curSectionId) then
                --  为了新手引导特殊处理
                if mainsData.acSectionId > IntanceConst.FIRST_SECTION_ID then 
                    self:confirmEnterNextStection(newSectionId)
                end
            end
        end)
        self._curSelectedNode:completeStage(inStageId, true)
    -- 未通关，只是通过某一章节
    elseif newSectionId == curSectionId and 
        inFinishType == IntanceConst.FINISH_WAR_TYPE.FIRST_WAR then
        self:updateSectionInfo(curSectionId)
        local stageView = self._curSelectedNode:getStageBuildingById(inStageId)
        local offset = self._curSelectedNode:getNextBuildOffset(inStageId)

        self:screenToObject(stageView, offset, true, function()
            self:setLockMap(false)
            self._curSelectedNode:setLockCallback(
                function(inUnLock, test)
                    self:setLockMap(inUnLock)
                end)
            -- 活动特殊判断
            if inStageId == IntanceConst.FIRST_RECHARGE_LIMIT_STAGE_ID  then
                ScheduleMgr:delayCall(0, self, function()
                    local userInfo = self._modelMgr:getModel("UserModel"):getData()
                    local payGemNum = 0
                    if userInfo.statis then
                        payGemNum = userInfo.statis.snum18 or 0
                    else
                        payGemNum = 0
                    end
                    if tonumber(payGemNum) <= 0 then 
                        self._viewMgr:showDialog("activity.FirstRechargeView")
                    end
                end)
            --[[   
            elseif inStageId == IntanceConst.LOGIN_ACTIVITY_LIMIT_STAGE_ID then
                --2-4 判断第三天是否未领
                -- local days = self._modelMgr:getModel("UserModel"):getData().statis.snum6
                local sevenDaysData = self._modelMgr:getModel("ActivitySevenDaysModel"):getData()
                if sevenDaysData["3"] == nil then
                    self._viewMgr:showDialog("activity.ACPublicityView", {panelType=0}, true)
                end
            ]]
            end
            self._curSelectedNode:completeStage(inStageId)
        end, 1)
    else            
        self:setLockMap(false)
        self._curSelectedNode:completeStage(inStageId)
        self:updateSectionInfo(curSectionId)
    end
end



--[[
--! @function goNextSection
--! @desc 过度到下一章
--! @param  inSectionId 章id
--! @return 
--]]
function IntanceMapLayer:goNextSection(inSectionId, anim, callback)
    if anim == nil then 
        anim = true 
    end
    self._sceneLayer:stopAllActions()
    
    self:setLockMap(true)
    -- 切章时载入大地图
    self:loadBigMap()
    self._bgLayer:setVisible(true)
    ScheduleMgr:delayCall(0, self, function()
        if inSectionId < self._curSectionId then 
            self._curSelectedNode:getParent():reorderChild(self._curSelectedNode, 2)
        else
            self._curSelectedNode:getParent():reorderChild(self._curSelectedNode, 0)
        end
        self._curSectionId = inSectionId
        local sysSection = tab:MainSection(inSectionId)
        
        if self._curNextSectionNode == nil then
            self._curNextSectionNode = require("game.view.intance.IntanceSectionNode"):new()
            self._sceneLayer:addChild(self._curNextSectionNode,1)

            self._curNextSectionNode:setParentView(self)
            -- 展示大圖callback
            self._curNextSectionNode:setShowCallback(function(inView, inStageId, inAnim, callback) 
                   self:showStageInfo(inView, inStageId, inAnim, callback)
                end)
            -- 锁定副本主界面callback
            self._curNextSectionNode:setLockCallback(
            function(inUnLock)
                self:setLockMap(inUnLock)
            end)
        end

        self._curSelectedNode:setSwitchSectionBegin(false)

        self._curNextSectionNode:setVisible(true)

        self._curNextSectionNode:setMoveCallback(function(inObject, offset)
                self._curNextSectionNode:setSwitchSectionBegin(true)
                local tempNode = self._curSelectedNode
                self._curSelectedNode = self._curNextSectionNode
                self._curNextSectionNode = tempNode
                -- 如果第一次打通副本，则播放魔眼效果
                self:updateCurNodeOffset()
                -- if inIsFinish then
                --     self._curSelectedNode:setCompleteCallback(function()
                --         -- self:runMagicEyeAction()
                --     end)
                -- end
                self:setLockMap(true)
                self:screenToObject(inObject, offset, anim, function()
                    if self._curNextSectionNode == nil then return end
                    self._viewMgr:removeTexture(self._parentView:getClassName(), self._curNextSectionNode:getBgName())
                    self._curNextSectionNode:removeFromParent()
                    self._curNextSectionNode = nil
                    if self._bgLayer ~= nil then 
                        self._bgLayer:setVisible(false)
                    end
                    self:setLockMap(false)
                    if callback ~= nil then 
                        callback()
                    end
                    GuideUtils.checkTriggerByType("section", inSectionId)
                end)
        end)
        -- ScheduleMgr:delayCall(0, self, function()
            print("curNextSectionNode:reflashUI===============")
        self:setLockMap(false)
        self._curNextSectionNode:reflashUI({sysSection = sysSection})

        -- end)
    end)

end


--[[
--! @function loadSection
--! @desc 加载当前章节
--! @return 
--]]
function IntanceMapLayer:loadSection(inQuickStageId)
    local sysSection = tab:MainSection(self._curSectionId)

    if self._curSelectedNode == nil then
        self._curSelectedNode = require("game.view.intance.IntanceSectionNode"):new()
        self._sceneLayer:addChild(self._curSelectedNode,1)

        self._curSelectedNode:setParentView(self)
        self._curSelectedNode:setShowCallback(function(inView, inStageId, inAnim, callback)
                self:showStageInfo(inView, inStageId, inAnim, callback)
            end)

        self._curSelectedNode:setMoveCallback(function(inObject,offset)
                self:updateCurNodeOffset()
                self:screenToObject(inObject, offset, false) 
                -- self._curSelectedNode:setSwitchSectionFinish(true)
        end)
        self._curSelectedNode:setLockCallback(
                function(inUnLock)
                    self:setLockMap(inUnLock)
                end)

    end
    self._curSelectedNode:reflashUI({sysSection = sysSection, quickStageId = inQuickStageId})
end

function IntanceMapLayer:update(dt)
    if self._touchDown then 
        self:updateTouch()
    end
end


function IntanceMapLayer:initEvent()
    -- 注册多点触摸
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function (touch, event)
        return self:onTouchBegan(touch, event)
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function (touch, event)
        self:onTouchMoved(touch, event)
    end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function (touch, event)
        self:onTouchEnded(touch, event)
    end, cc.Handler.EVENT_TOUCH_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self._touchDispatcher = dispatcher

    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function (event)
        self:onMouseScroll(event)
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end



--[[
--! @function updateCurNodeOffset
--! @desc 更新章地图偏移坐标
--! @return 
--]]
function IntanceMapLayer:updateCurNodeOffset()
    local x, y = self._curSelectedNode:getPosition()
    local size = self._curSelectedNode:getCacheContentSize()
    self._curOffsetMinX, self._curOffsetMinY = x - size.width/2, y - size.height/2
    self._curOffsetMaxX = IntanceConst.MAX_VIEW_WIDTH_PIXEL - (x + size.width/2)
    self._curOffsetMaxY = IntanceConst.MAX_VIEW_HEIGHT_PIXEL - (y + size.height/2)
end


--[[
--! @function updateScenePos
--! @desc 更新场景坐标
--! @param  x
--! @param  y
--! @param  anim 是否动画
--! @return 
--]]
function IntanceMapLayer:updateScenePos(x, y, anim)
    self._sceneLayer:stopAllActions()
    if anim then
        local _x = self._sceneLayer:getPositionX()
        local _y = self._sceneLayer:getPositionY()
        local nx 
        local ny
        nx = _x + (x - _x) * 0.7
        ny = _y + (y - _y) * 0.7
        self._sceneLayer:setPosition(self:adjustPos(nx, ny))
    else
        self._sceneLayer:setPosition(self:adjustPos(x, y))
    end
end

function IntanceMapLayer:loadBigMap()
    if GameStatic.openDebugLog then 
        local traceback = string.split(debug.traceback("", 2), "\n")
        local tracde = traceback[5]
        if not tracde then 
            tracde = traceback[3]
        end
        if tracde then 
            print("loadBigMap  from: " .. string.trim(tracde) .. "Debug关闭则关闭，请忽略") 
        end  
    end
    print("loadBigMap==========================================")
    if self._bgLayer == nil then 
        print("test=====================================================")
        cc.Texture2D:setDefaultAlphaPixelFormat(RGB565)
        self._bgLayer = cc.Sprite:create()
        self._sceneLayer:addChild(self._bgLayer)
        self._bgLayer:setTexture("asset/uiother/map/chaodaditu.jpg")
        self._bgLayer:setPosition(IntanceConst.MAX_VIEW_WIDTH_PIXEL/2, IntanceConst.MAX_VIEW_HEIGHT_PIXEL/2)
        self._bgLayer:setAnchorPoint(0.5,0.5)
        self._bgLayer:setScale(10)
        cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)
    end
end

--[[
--! @function showStageInfo
--! @desc 展示章节信息
--! @param  inView 展示icon
--! @param  inStageId 副本id
--! @param  callback 回调
--! @param  anim 是否动画
--! @return 
--]]
function IntanceMapLayer:showStageInfo(inView, inStageId, inAmin, callback)
    if self._intanceStageInfoNode == nil then return end
    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local mainsData = intanceModel:getData().mainsData
    if mainsData.curStageId <= inStageId and IntanceConst.QUICK_BATTLE_STAGE_ID >= inStageId then
        self._showPointBeginX = self._sceneLayer:getPositionX() 
        self._showPointBeginY = self._sceneLayer:getPositionY() 
        self._curStageId = inStageId
        self._sectionNodeCallback = callback
        self:setLockMap(true)
        self._intanceStageInfoNode:reflashUI({stageBaseId = self._curStageId})
        self._intanceStageInfoNode:clickEnterBtn()
        return
    end

    local pt = inView:convertToWorldSpaceAR(cc.p(0, 0))
    pt.y = pt.y + (inView:getContentSize().height * inView:getScale() * 0.5)


    if self._bgLayer == nil then 
        local nodeX, nodeY = self._curSelectedNode:getPosition()
        local nodeSize = self._curSelectedNode:getCacheContentSize()

        local viewX = nodeSize.width - inView:getPositionX()
        local viewY = nodeSize.height - inView:getPositionX() + inView:getContentSize().height * inView:getScale() * 0.5
        local layerPt = self._sceneLayer:convertToWorldSpace(cc.p(nodeX + nodeSize.width * 0.5, nodeY + nodeSize.height * 0.5))
        local screenPt = self:convertToNodeSpace(layerPt)
        local subDis1, subDis2 = (pt.x - IntanceConst.SHOW_POINT_X) * 0.5, (pt.y - IntanceConst.SHOW_POINT_Y) * 0.5
        if (screenPt.x - viewX) <= MAX_SCREEN_WIDTH or (screenPt.y - viewY) <= MAX_SCREEN_HEIGHT then 
            print("tst===============================================")
            self:loadBigMap()
        end
    end

    if self._bgLayer ~= nil then 
        self._bgLayer:setVisible(true)
    end
 
    self:setLockMap(true)
    ScheduleMgr:delayCall(0, self, function()
        self._parentView._widget:setVisible(false)
        -- 多次设定setLockMap 因为self 在addChild 后会恢复锁定事件
        self:setLockMap(false)
        self:setLockMap(true)
        self._curStageId = inStageId
        self._sectionNodeCallback = callback

        self:showPoint(pt.x, pt.y, 
            function()
                self._intanceStageInfoNode:reflashUI({stageBaseId = self._curStageId})
                self._intanceStageInfoNode:setVisible(true)
            end, inAmin)
    end)
end


--[[
--! @function hideStageInfo
--! @desc 关闭章节信息
--! @param  isClose 是否释放事件
--! @return 
--]]
function IntanceMapLayer:hideStageInfo(isClose)
    if self._curStageId ~= nil then 
        if self._sectionNodeCallback ~= nil then 
            self._sectionNodeCallback(1)
        end
        -- if self._bgLayer ~= nil then 
        --     if self._bgLayer.blackMask ~= nil then 
        --         self._bgLayer.blackMask:runAction(cc.FadeOut:create(0.4))
        --     end
        -- end
        self._parentView._widget:setVisible(true)
        local action1 = cc.MoveTo:create(0.4, cc.p(self._showPointBeginX, self._showPointBeginY))
        local action2 = cc.ScaleTo:create(0.4, 1, 1)
        self._sceneLayer:runAction(cc.Sequence:create(cc.Spawn:create(action1,action2),
            cc.CallFunc:create(function()
                if self._bgLayer ~= nil then 
                    self._bgLayer:setVisible(false)
                    -- if self._bgLayer.blackMask ~= nil  then 
                    --     self._bgLayer.blackMask:removeFromParent()
                    --     self._bgLayer.blackMask = nil
                    -- end
                end

                self._showPointAction1 = nil 
                self._showPointAction2 = nil
                
                if self._sectionNodeCallback ~= nil then 
                    self._sectionNodeCallback(2)
                end
                -- 如果不是点击close按钮则不放开点击事件，给下一动作释放
                if isClose == true then 
                    self:setLockMap(false)
                end
                self:updateCurNodeOffset()
                -- if isClose == true then 
                    -- self._touchDispatcher:resumeEventListenersForTarget(self,false)
                -- end
                end)))
    end
end

--[[
--! @function switchWorldMapAction
--! @desc 配合世界地图动画
--! @param  callback
--! @param  amin
--! @return 
--]]
function IntanceMapLayer:switchWorldMapAction(callback, amin, inTimeOffset)
    local x = IntanceConst.MAX_VIEW_WIDTH_PIXEL * 0.5 - self._sceneLayer:getPositionX()
    local y = IntanceConst.MAX_VIEW_HEIGHT_PIXEL * 0.5 - self._sceneLayer:getPositionY()
    self._bgLayer:setVisible(true)
    self._curOffsetMinX = 0
    self._curOffsetMinY = 0
    self._curOffsetMaxX = 0
    self._curOffsetMaxY = 0

    local scale = 0.07

    local nx = IntanceConst.MAX_SCREEN_WIDTH * 0.5 - x * scale  + IntanceConst.MAX_VIEW_WIDTH_PIXEL * 0.5 * scale 
    local ny = IntanceConst.MAX_SCREEN_HEIGHT * 0.5 - y * scale  + IntanceConst.MAX_VIEW_HEIGHT_PIXEL * 0.5 * scale

    self._showPointBeginX = self._sceneLayer:getPositionX() 
    self._showPointBeginY = self._sceneLayer:getPositionY() 

    -- local nx = self._sceneLayer:getPositionX() * scale - ((scale - 1) * x) + (IntanceConst.SHOW_POINT_X - x )
    -- local ny = self._sceneLayer:getPositionY()  * scale - ((scale - 1) * y) + (IntanceConst.SHOW_POINT_Y - y )
    nx, ny = self:adjustPos(nx, ny, scale)
    if inTimeOffset == nil then 
        inTimeOffset = 1 
    end
    local runTime = 1.3  * inTimeOffset
    if amin == false then 
        runTime = 0
    end

    local action1 = cc.MoveTo:create(runTime, cc.p(nx, ny))
    local action2 = cc.ScaleTo:create(runTime, scale, scale)
    local action3 = cc.FadeOut:create(runTime)
    self._curSelectedNode:fadeOutStageFog(true, 0.3)

    self._curSelectedNode:setCascadeOpacityEnabled(true, true)
    self._curSelectedNode:runAction(action3)
    self._sceneLayer:runAction(cc.Sequence:create(cc.Spawn:create(action1, action2),
        -- cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()                

            if callback ~= nil then
                callback()
            end
            end)))
    return nx, ny
end

function IntanceMapLayer:resumeMapState()
    self._bgLayer:setVisible(false)
    self._curSelectedNode:setOpacity(255)
    self:updateCurNodeOffset()
    self._sceneLayer:setScale(1)
    self._sceneLayer:setPosition(self._showPointBeginX, self._showPointBeginY)
end

function IntanceMapLayer:switchWorldMapActionOut(callback, amin, inTimeOffset)
    local x = IntanceConst.MAX_VIEW_WIDTH_PIXEL * 0.5 - self._sceneLayer:getPositionX()
    local y = IntanceConst.MAX_VIEW_HEIGHT_PIXEL * 0.5 - self._sceneLayer:getPositionY()
    self._bgLayer:setVisible(true)
    self._curOffsetMinX = 0
    self._curOffsetMinY = 0
    self._curOffsetMaxX = 0
    self._curOffsetMaxY = 0

    local scale = 0.1

    local nx = IntanceConst.MAX_SCREEN_WIDTH * 0.5 - x * scale  + IntanceConst.MAX_VIEW_WIDTH_PIXEL * 0.5 * scale 
    local ny = IntanceConst.MAX_SCREEN_HEIGHT * 0.5 - y * scale  + IntanceConst.MAX_VIEW_HEIGHT_PIXEL * 0.5 * scale

    self._showPointBeginX = self._sceneLayer:getPositionX() 
    self._showPointBeginY = self._sceneLayer:getPositionY() 

    -- local nx = self._sceneLayer:getPositionX() * scale - ((scale - 1) * x) + (IntanceConst.SHOW_POINT_X - x )
    -- local ny = self._sceneLayer:getPositionY()  * scale - ((scale - 1) * y) + (IntanceConst.SHOW_POINT_Y - y )
    local nx1, ny1 = self:adjustPos(nx, ny, scale)
    self._sceneLayer:setScale(scale)
    self._sceneLayer:setPosition(nx1, ny1)
    if inTimeOffset == nil then 
        inTimeOffset = 1
    end
    local runTime = 1.5 * inTimeOffset
    if amin == false then 
        runTime = 0
    end
    -- local nx = IntanceConst.MAX_SCREEN_WIDTH * 0.5 - x * 1  + IntanceConst.MAX_VIEW_WIDTH_PIXEL * 0.5 * 1 
    -- local ny = IntanceConst.MAX_SCREEN_HEIGHT * 0.5 - y * 1  + IntanceConst.MAX_VIEW_HEIGHT_PIXEL * 0.5 * 1
    -- local nx1, ny1 = self:adjustPos(nx, ny, 1)

    local action1 = cc.MoveTo:create(runTime, cc.p(self._showPointBeginX , self._showPointBeginY))
    local action2 = cc.ScaleTo:create(runTime, 1, 1)
    local action3 = cc.FadeIn:create(runTime)
    
    self._curSelectedNode:fadeOutStageFog(false)
    self._curSelectedNode:setCascadeOpacityEnabled(true, true)
    self._curSelectedNode:setOpacity(0)
    self._curSelectedNode:runAction(action3)
    
    self._sceneLayer:runAction(cc.Sequence:create(cc.Spawn:create(action1, action2),
        -- cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()  
            self:updateCurNodeOffset()  
            self._bgLayer:setVisible(false)
            self._curSelectedNode:fadeInStageFog(true, 0.5)            
            if callback ~= nil then
                callback()
            end
            -- self._curSelectedNode:runAminLayer()
            -- self._bgLayer:setVisible(false)
            -- self._curSelectedNode:setOpacity(255)
            -- self:updateCurNodeOffset()
            -- self._sceneLayer:setScale(1)
            -- self._sceneLayer:setPosition(self._showPointBeginX, self._showPointBeginY)
            end)))
end

--[[
--! @function showPoint
--! @desc 放大展示某一点
--! @param  x 
--! @param  y
--! @param  callback
--! @return 
--]]
function IntanceMapLayer:showPoint(x, y, callback, amin)
    self._curOffsetMinX = 0
    self._curOffsetMinY = 0
    self._curOffsetMaxX = 0
    self._curOffsetMaxY = 0

    local scale = 2
    self._showPointBeginX = self._sceneLayer:getPositionX() 
    self._showPointBeginY = self._sceneLayer:getPositionY() 

    local nx = self._sceneLayer:getPositionX() * scale - ((scale - 1) * x) + (IntanceConst.SHOW_POINT_X - x )
    local ny = self._sceneLayer:getPositionY()  * scale - ((scale - 1) * y) + (IntanceConst.SHOW_POINT_Y - y )
    local runTime = 0.4
    if amin == false then 
        runTime = 0
    end
    print("nx, ny==================", nx, ny)
    local action1 = cc.MoveTo:create(runTime, cc.p(nx, ny))
    local action2 = cc.ScaleTo:create(runTime, scale, scale)

    self._sceneLayer:runAction(cc.Sequence:create(cc.Spawn:create(action1,action2),
        cc.CallFunc:create(function()
                if callback ~= nil then
                    callback()
                end
            end)))
end

function IntanceMapLayer:updateTouch()
    self:updateScenePos(self._touchMoveX, self._touchMoveY, true)
end


function IntanceMapLayer:onMouseScroll(event)
    self._touchesBeganScale = self._sceneLayer:getScale()
    -- self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
    -- self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    -- local scale = self._touchesBeganScale + event:getScrollY() * 0.2
    -- scale = math.min(IntanceConst.MAX_VIEW_SCALE, math.max(IntanceConst.MIN_VIEW_SCALE, scale)) 
    -- self._sceneLayer:setScale(scale)
    -- local nx = self._touchesBeganPositionX * scale
    -- local ny = self._touchesBeganPositionY * scale
    -- self:updateScenePos(nx, ny)

    -- local nx = self._touchesBeganPositionX * self._touchesBeganScale
    -- local ny = self._touchesBeganPositionY * self._touchesBeganScale
    -- self:updateScenePos(nx, ny)
end

function IntanceMapLayer:onTouchBegan(touch)

    if self._curSelectedNode == nil then 
        return false
    end
    if GuideUtils.isGuideRunning then
        return false
    end
    self._sceneLayer:stopAllActions()
    self._touchDown = true
    self._touchBeganPositionX = touch:getLocation().x
    self._touchBeganPositionY = touch:getLocation().y

    self._touchBeganScenePositionX = self._sceneLayer:getPositionX()
    self._touchBeganScenePositionY = self._sceneLayer:getPositionY()

    self:touchMoved(self._touchBeganPositionX, self._touchBeganPositionY)
    return true
end

function IntanceMapLayer:onTouchMoved(touch)
    local x, y = touch:getLocation().x, touch:getLocation().y
    self:touchMoved(x, y)
end

function IntanceMapLayer:touchMoved(x, y)
    -- 地图移动
    local lastPtx = self._touchBeganPositionX
    local lastPty = self._touchBeganPositionY
    local dx = x - lastPtx
    local dy = y - lastPty
    local nx = self._touchBeganScenePositionX + dx
    local ny = self._touchBeganScenePositionY + dy
    self._touchMoveX = nx
    self._touchMoveY = ny
end

function IntanceMapLayer:onTouchEnded(touch)
    self._touchBeganScenePositionX = self._sceneLayer:getPositionX()
    self._touchBeganScenePositionY = self._sceneLayer:getPositionY()
    self._touchDown = false
    if math.abs(self._touchBeganPositionX - touch:getLocation().x) <= 10
        or math.abs(self._touchBeganPositionY- touch:getLocation().y) <= 10 then 
        local backR = self._curSelectedNode:touchIcon(self._touchBeganPositionX, self._touchBeganPositionY)
        if backR == true then 
            return 
        end
    end
    self._touchBeganPositionX = touch:getLocation().x
    self._touchBeganPositionY = touch:getLocation().y
    self:touchMoved(touch:getLocation().x, touch:getLocation().y)

end

function IntanceMapLayer:distance(pt1x, pt1y, pt2x, pt2y)
    local dx = math.abs(pt2x - pt1x)
    local dy = math.abs(pt2y - pt1y)
    return math.sqrt(dx * dx + dy * dy)
end


-- 矫正坐标
function IntanceMapLayer:adjustPos(x, y, inScale)
    local nx = x
    local ny = y
    if inScale == nil then 
        inScale  = self._sceneLayer:getScaleX()
    end
    local minX = 0- (IntanceConst.MAX_VIEW_WIDTH_PIXEL * inScale /2 - IntanceConst.MAX_SCREEN_WIDTH) +  (self._curOffsetMaxX * self._sceneLayer:getScaleX()) --* self._sceneLayer:getScaleX() - dx +  self._curOffsetMaxX * self._sceneLayer:getScaleX()
    local maxX = IntanceConst.MAX_VIEW_WIDTH_PIXEL * inScale/2 - (self._curOffsetMinX * self._sceneLayer:getScaleX())
    local minY = 0- (IntanceConst.MAX_VIEW_HEIGHT_PIXEL * inScale/2 - IntanceConst.MAX_SCREEN_HEIGHT) +  (self._curOffsetMaxY * self._sceneLayer:getScaleY())--* self._sceneLayer:getScaleY() - dy + self._curOffsetMaxY * self._sceneLayer:getScaleY()
    local maxY = IntanceConst.MAX_VIEW_HEIGHT_PIXEL * inScale/2  - (self._curOffsetMinY * self._sceneLayer:getScaleY())

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

    return math.floor(nx), math.floor(ny)
end


-- 以某点为屏幕中心
function IntanceMapLayer:screenToObject(inTempIcon, offset, anim, inCallback, inTime)
    local pt1 = inTempIcon:convertToWorldSpaceAR(cc.p(0, 0))
    local pt =  self._sceneLayer:convertToNodeSpace(cc.p(pt1.x,pt1.y))
    if offset ~= nil then 
        pt.x = pt.x + offset.x 
        pt.y = pt.y + offset.y 
    end
    self:screenToPos(pt.x, pt.y, anim, inCallback, inTime)
end

function IntanceMapLayer:moveBuildingInScreen(inTempIcon, inCallback)
    self:setLockMap(true)
    local pt = inTempIcon:convertToWorldSpace(cc.p(0, 0))
    local offsetX = 0
    local offsetY = 0
    local flag = 0
    if pt.x < 0 then 
        offsetX = pt.x
    end 
    if (pt.y - 100) < 0 then 
        offsetY = pt.y - 100
    end
    if pt.x + inTempIcon:getContentSize().width > IntanceConst.MAX_SCREEN_WIDTH then 
        offsetX = (pt.x + inTempIcon:getContentSize().width - IntanceConst.MAX_SCREEN_WIDTH)
    end
    if pt.y + inTempIcon:getContentSize().height > IntanceConst.MAX_SCREEN_HEIGHT then 
        offsetY = (pt.y + inTempIcon:getContentSize().height - IntanceConst.MAX_SCREEN_HEIGHT)
    end

    if offsetX ~= 0 or offsetY ~= 0  then 
        local nx = self._sceneLayer:getPositionX() - offsetX 
        local ny = self._sceneLayer:getPositionY() - offsetY
        nx ,ny = self:adjustPos(nx, ny)
        local action1 = cc.MoveTo:create(0.5, cc.p(nx, ny))
        self._sceneLayer:runAction(cc.Sequence:create(action1,
            cc.CallFunc:create(function()
                    
                    if inCallback ~= nil then 
                        inCallback()
                    end
                end)))
        return
    end 
    if inCallback ~= nil then 
        inCallback()
    end
end

-- 以某点为屏幕中心
function IntanceMapLayer:screenToPos(x, y, anim, callback, inTime)
    if inTime == nil then 
        inTime = 0.5
    end
    local scale = self._sceneLayer:getScale()
    local nx = IntanceConst.MAX_SCREEN_WIDTH * 0.5 - x + IntanceConst.MAX_VIEW_WIDTH_PIXEL * 0.5
    local ny = IntanceConst.MAX_SCREEN_HEIGHT * 0.5 - y + IntanceConst.MAX_VIEW_HEIGHT_PIXEL * 0.5
    if anim == true then 
        nx ,ny = self:adjustPos(nx, ny)
        local action1 = cc.MoveTo:create(inTime, cc.p(nx, ny))
        self._sceneLayer:runAction(cc.Sequence:create(action1,
            cc.CallFunc:create(function()
                    if callback ~= nil then 
                        callback()
                    end
                end)))
        return
    end
    self:updateScenePos(nx * scale, ny * scale)
    if callback ~= nil then 
        callback()
    end
end

function IntanceMapLayer:screenToSize(scale)
    local x = self._sceneLayer:getPositionX() / self._sceneLayer:getScale()
    local y = self._sceneLayer:getPositionY() / self._sceneLayer:getScale()
    self._sceneLayer:setScale(scale)
    local nx = x * scale
    local ny = y * scale
    self:updateScenePos(nx, ny)
end



function IntanceMapLayer:setLockCallback(inLockCallback)
    self._lockCallback = inLockCallback
end


function IntanceMapLayer:closeLayer( ... )
    self._sceneLayer = nil
end


function IntanceMapLayer:setLockMap(inLock, notNoticeParent)
    if inLock then
        self._lockCount = self._lockCount + 1
        self:lockTouch()
        print("lock map lockCount========", self._lockCount)
    else
        self._lockCount = self._lockCount - 1
        self:unLockTouch()
        print("unlock map lockCount========", self._lockCount)
    end
    -- if self._lockCount > 1 or self._lockCount < -1 then
        -- if GameStatic.openDebugLog then 
        --     local traceback = string.split(debug.traceback("", 2), "\n")
        --     local tracde = traceback[5]
        --     if not tracde then 
        --         tracde = traceback[3]
        --     end
        --     if tracde then 
        --         print("setLockMap " .. tostring(inIsLock) .. " from: " .. string.trim(tracde) .. "Debug关闭则关闭，请忽略") 
        --     end  
        -- end
    -- end
    if notNoticeParent ~= true then 
        self._lockCallback(inLock)
    end
end

function IntanceMapLayer:getParentView()
    return self._parentView
end

function IntanceMapLayer:convertToMapSpace(pt1)
    return self._sceneLayer:convertToNodeSpace(pt1)
end

function IntanceMapLayer:runMagicEyeAction(inStageId, inBranchId)
    return self._curSelectedNode:runMagicEyeAction(inStageId, inBranchId)
end

--[[
--! @function moveToUndoneStage
--! @desc 移动未满星关卡
--! @return 
--]]
function IntanceMapLayer:moveToUndoneStage()
    -- IntanceSectionNode
    local undoneBuild = self._curSelectedNode:getNextUndoneBuild()
    if undoneBuild == nil then 
        self._viewMgr:showTip(lang("TIP_STAGESTAR"))
    else
        self:setLockMap(true)
        self:screenToObject(undoneBuild, cc.p(0,0), false, function()
            self:setLockMap(false)
        end)
    end
end

--[[
--! @function moveToBranchBuilding
--! @desc 移动到支线建筑位置
--! @return 
--]]
function IntanceMapLayer:moveToBranchBuilding(inBranchId)
    -- IntanceSectionNode
    local branchBuild = self._curSelectedNode:getBranchBuildingById(inBranchId)
    if branchBuild == nil then 
        return
    end
    self:setLockMap(true)
    self:screenToObject(branchBuild, cc.p(0,0), true, function()
        self:setLockMap(false)
    end, 0.5)
    
end


function IntanceMapLayer:refreshSectionHero()
    if self._curSelectedNode ~= nil then
        self._curSelectedNode:refreshHeroAnim()
    end
end


--[[
--! @function updateSectionInfo
--! @desc 更新主界面infobtn状态
--! @return 
--]]
function IntanceMapLayer:updateSectionInfo(inCurSectionId)
    self._parentView:updateSectionInfo(inCurSectionId)
    self._parentView:showIntanceBullet()
end

--[[
--! @function updateSectionInfoBtnState
--! @desc 更新主界面infobtn状态
--! @return 
--]]
function IntanceMapLayer:updateSectionInfoBtnState()
    self._parentView:updateSectionInfoBtnState()
end

--[[
--! @function updateTaskState
--! @desc 更新任务状态
--! @return 
--]]
function IntanceMapLayer:updateTaskState(inForced)
    self._parentView:updateTaskState(inForced)
end

--[[
--! @function getStageInfoNode
--! @desc 后去章节信息node
--! @return 
--]]
function IntanceMapLayer:getStageInfoNode(inForced)
    return self._intanceStageInfoNode
end


--[[
--! @function showIntanceBullet
--! @desc 更新弹幕状态
--! @return 
--]]
function IntanceMapLayer:showIntanceBullet()
    self._parentView:showIntanceBullet()
end

function IntanceMapLayer:unLockTouch()
    -- self._isLouck = false
    self._touchDispatcher:resumeEventListenersForTarget(self,false)
end

function IntanceMapLayer:lockTouch()
    -- self._isLouck = true
    self._touchDispatcher:pauseEventListenersForTarget(self,false)
end

function IntanceMapLayer.dtor()
    cc = nil
end

return IntanceMapLayer