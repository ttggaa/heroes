--[[
    Filename:    IntanceStagePlotView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-01-31 14:30:06
    Description: File description
--]]


local IntanceStagePlotView = class("IntanceStagePlotView", BasePopView)


function IntanceStagePlotView:ctor()
    IntanceStagePlotView.super.ctor(self)

end

function IntanceStagePlotView:reflashUI(inData)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceStagePlotView")
        elseif eventType == "enter" then 

        end
    end) 


    local sysStageId = inData.stageId
    local sysMainStageMap = tab:MainStageMap(sysStageId)

    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(0)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    bgLayer.noSound = true
    bgLayer:setOpacity(0)
    self:addChild(bgLayer, 1)

    registerClickEvent(bgLayer, function ()
        if inData.callback ~= nil then 
            inData.callback()
        end
        self:close()
    end)


    local clipLayer = ccui.Layout:create()
    clipLayer:setBackGroundColorOpacity(0)
    clipLayer:setBackGroundColorType(1)
    clipLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    clipLayer:setContentSize(1136, 469)
    clipLayer:setPosition(MAX_SCREEN_WIDTH * 0.5 , MAX_SCREEN_HEIGHT * 0.5)
    self:addChild(clipLayer, 1)
    clipLayer:setAnchorPoint(0.5, 0.5)

    clipLayer:setClippingEnabled(true)

    local scalWidth = MAX_SCREEN_WIDTH / 1136  
    clipLayer:setScale(scalWidth)

    local templeAnim = mcMgr:createViewMC(sysMainStageMap.showPic, false, false)
    templeAnim:setPosition(cc.p(568, 234.5))   
    clipLayer:addChild(templeAnim)
    templeAnim:addCallbackAtFrame(52, function()
        templeAnim:stop()
    end)

end


return IntanceStagePlotView