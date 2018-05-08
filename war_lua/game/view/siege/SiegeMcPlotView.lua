--
-- Author: <ligen@playcrab.com>
-- Date: 2017-10-11 15:36:29
--

local SiegeMcPlotView = class("SiegeMcPlotView", BaseView)
function SiegeMcPlotView:ctor(inData)
    SiegeMcPlotView.super.ctor(self)
    self.noSound = true
    self._plotId = inData.plotId
    self._callback = inData.callback
    self._sysPlot = tab:SiegeMainPlot(self._plotId)
    self._skipReward = inData.skipReward
end

function SiegeMcPlotView:onInit()
    audioMgr:playMusic("campaign", true)
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(0)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    bgLayer:setOpacity(0)
    bgLayer.noSound = true
    self:addChild(bgLayer)


    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("siege.SiegeMcPlotView")
        elseif eventType == "enter" then 

        end
    end)

    self._scenceBg = ccui.Widget:create()
    self._scenceBg:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._scenceBg:setPosition(0, 0)
    self._scenceBg:setAnchorPoint(0, 0)
    self:addChild(self._scenceBg)
    if self["initPlot" .. self._plotId] ~= nil then 
        self["initPlot" .. self._plotId](self, self._sysPlot)
    else
        self:initPlot(self._sysPlot)
    end

    -- self._curtainLayer = require("game.view.intance.IntanceGuideCurtainLayer").new()
    -- self:addChild(self._curtainLayer, 3)
    -- self._curtainLayer:play()
    -- ScheduleMgr:delayCall(0, self, function()
    --     self._curtainLayer:doPlay()
    -- end)
    -- self._scenceBg:setScale(0.5)

    self._maskLayer = ccui.Layout:create()
    -- bgLayer:setBackGroundColorOpacity(180)
    self._maskLayer:setBackGroundColorType(1)
    self._maskLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    self._maskLayer:setTouchEnabled(false)
    self._maskLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:addChild(self._maskLayer, 100)
    self._maskLayer:runAction(cc.FadeOut:create(2))

end

--[[
--! @function initPlot
--! @desc 初始化剧情
--! @param  inPlotInfo 剧情信息
--! @return
--]]
function SiegeMcPlotView:initPlot(inPlotInfo)
    local plotBg = cc.Sprite:create("asset/bg/siegePlot/" .. inPlotInfo.bg .. ".jpg")
    plotBg:setPosition(self._scenceBg:getContentSize().width * 0.5, self._scenceBg:getContentSize().height * 0.5)
    plotBg:setAnchorPoint(0.5, 0.5)
    self._scenceBg:addChild(plotBg)

    local xscale = MAX_SCREEN_WIDTH / plotBg:getContentSize().width
    local yscale = MAX_SCREEN_HEIGHT / plotBg:getContentSize().height
    if xscale > yscale then
        plotBg:setScale(xscale)
    else
        plotBg:setScale(yscale)
    end

    self._closeViewFun = function()
        if self._callback ~= nil then 
            self._callback()
        end
    end
    
    local mc1 = mcMgr:createViewMC(inPlotInfo.mc, false, true, function()
        if self._callback ~= nil then 
            self._callback()
        end
    end)
    mc1:setScale(plotBg:getScale())
    mc1:setPosition(0, plotBg:getContentSize().height * plotBg:getScale() - (ADOPT_IPHONEX and 70 or 0))
    self._scenceBg:addChild(mc1, 100)

    self:listenerFrame(mc1, inPlotInfo.event)
end

--[[
--! @function initPlot1
--! @desc 剧情1特殊处理
--! @param  inPlotInfo 剧情信息
--! @return
--]]
function SiegeMcPlotView:initPlot12(inPlotInfo)
    local plotBg = cc.Sprite:create("asset/uiother/map/_0000_pve_daditu1.jpg")
    plotBg:setPosition(-400, -100)
    plotBg:setScale(1.5)
    plotBg:setAnchorPoint(0, 0)
    self._scenceBg:addChild(plotBg)

    self._closeViewFun = function()
        if self._skipReward == 1 then
            if self._callback ~= nil then 
                self._callback()
            end
        else
            local heroView = self._viewMgr:createLayer("hero.HeroUnlockView", {heroId = 60102, callBack = function() 
                ApiUtils.playcrab_device_monitor_action("kaiselin")
                if self._callback ~= nil then 
                    self._callback()
                end
            end})
            self:addChild(heroView, 2000)
        end
    end
    local mc1 = mcMgr:createViewMC(inPlotInfo.mc, false, true, function()
        self:_closeViewFun()
    end)
    mc1:setPosition(0, 0)
    self._scenceBg:addChild(mc1, 100)
    mc1:setScale(0.95)

    self:listenerFrame(mc1, inPlotInfo.event)
end

--[[
--! @function listenerFrame
--! @desc 監聽動畫幀
--! @param  inMc 動畫原件
--! @param  inFrameEvent 幀相關信息
--! @return
--]]
function SiegeMcPlotView:listenerFrame(inMc, inFrameEvent)
    local finishFrame = inMc:getTotalFrames() - 36

    if inFrameEvent then
        for k,v in pairs(inFrameEvent) do
            local frame = v[1]
            local event = v[2]
            if finishFrame == frame then 
                finishFrame = finishFrame + 1
            end
            inMc:addCallbackAtFrame(frame, function()
                inMc:stop(false)
                if event[1] == 1 then
                    -- event 说明 1=对话类型，2=故事情节，3=插图图片名称
                    local storyView = ViewManager:getInstance():enableTalking(event[2], "", function(inCloseType)
                        if inCloseType == 1 then 
                            self:_closeViewFun()
                            return
                        end
                        if event[3] ~= nil then
                            self:initPlotPic(event[3], function()
                                inMc:gotoAndPlay(frame+1)
                            end)
                        else
                            inMc:gotoAndPlay(frame+1)
                        end
                    end)
                    return
                end 
                if event[1] == 2 then
                    -- event 说明 1=类型2移动地图类型，2=x坐标，3=y坐标
                    self:showPoint(event[2], event[3], function()
                        inMc:gotoAndPlay(frame+1)
                    end)
                end    
            end)
        end
    end
    inMc:addCallbackAtFrame(finishFrame, function()
        self._maskLayer:runAction(cc.FadeIn:create(1.5))
    end)
end

--[[
--! @function initPlotPic
--! @desc 劇情插畫
--! @param  inPic 圖片名稱
--! @param  callback
--! @return
--]]
function SiegeMcPlotView:initPlotPic(inPic, callback)
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(0)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    bgLayer:setOpacity(50)
    bgLayer.noSound = true
    self:addChild(bgLayer, 1000)

    local plotPic = cc.Sprite:createWithSpriteFrameName(inPic .. ".jpg")
    plotPic:setAnchorPoint(0.5, 0.5)
    plotPic:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgLayer:addChild(plotPic)
    bgLayer:runAction(cc.Sequence:create(
            cc.DelayTime:create(2),
            cc.CallFunc:create(function()
                bgLayer:removeFromParent()
                if callback ~= nil then 
                    callback()
                end
            end)
        ))
    local mc1 = mcMgr:createViewMC("chatudonghua_chatudonghua", false)
    mc1:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgLayer:addChild(mc1)
    
end

--[[
--! @function showPoint
--! @desc 放大展示某一点
--! @param  x 
--! @param  y
--! @param  callback
--! @return
--]]
function SiegeMcPlotView:showPoint(x, y, callback, notAmin, inScale)
    local scale = self._scenceBg:getScale()
    if inScale ~= nil then 
        scale = inScale
    end
    local runTime = 0.5
    local action1 = cc.MoveTo:create(runTime, cc.p(x, y))
    self._scenceBg:runAction(cc.Sequence:create(action1,
        cc.CallFunc:create(function()
                if callback ~= nil then
                    callback()
                end
            end)))
end



--function SiegeMcPlotView:getAsyncRes()
--    if self._plotId == 1 then
--        return {
--                {"asset/ui/hero1.plist", "asset/ui/hero1.png"},
--                {"asset/ui/hero.plist", "asset/ui/hero.png"},
--                {"asset/bg/plot/plot_1.plist", "asset/bg/plot/plot_1.png"},
--               }
--    else
--        return {}
--    end
--end

function SiegeMcPlotView:onDestroy()
    -- audioMgr:playMusic("mainmenu", true)
    SiegeMcPlotView.super.onDestroy(self)
end


function SiegeMcPlotView:destroy(removeRes)
    SiegeMcPlotView.super.destroy(self, removeRes)
end

function SiegeMcPlotView:isAsyncRes()
    return false
end

function SiegeMcPlotView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

return SiegeMcPlotView