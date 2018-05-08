--[[
    Filename:    IntancePlotReviewView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-07-06 18:58:04
    Description: File description
--]]


local IntancePlotReviewView = class("IntancePlotReviewView", BasePopView)
require "game.view.intance.IntanceConst"
function IntancePlotReviewView:ctor()
    IntancePlotReviewView.super.ctor(self)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/intancePlot.plist", "asset/ui/intancePlot.png")
    self._intanceModel = self._modelMgr:getModel("IntanceModel")
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntancePlotReviewView")
        elseif eventType == "enter" then 
        end
    end)

end


function IntancePlotReviewView:reflashUI(inData)
    self._model = 1

    local closeBtgn = self:getUI("bg.closeBtn")
    registerClickEvent(closeBtgn, function ()
        self:close()
    end)

    self._maskLayer = ccui.Layout:create()
    -- self._maskLayer:setBackGroundColorOpacity(0)
    self._maskLayer:setBackGroundColorType(1)
    self._maskLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    self._maskLayer:setTouchEnabled(true)
    self._maskLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:addChild(self._maskLayer, 100)
    self._maskLayer:setVisible(false)
    -- 
    
    local titleBgNode = ccui.Widget:create()
    titleBgNode:setContentSize(300, 150)
    titleBgNode:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 20)

    local title = cc.Label:createWithTTF("女王归来", UIUtils.ttfName, 108)
    title:setAnchorPoint(0.5, 0.5)
    title:setColor(cc.c4b(255, 253, 226,255))
    title:enable2Color(1,cc.c4b(255, 236, 125,255))
    title:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    title:setScaleY(0.9)
    title:setPosition(titleBgNode:getContentSize().width * 0.5, titleBgNode:getContentSize().height * 0.5 )
    titleBgNode:addChild(title)

    self._maskLayer.title = title
    self._maskLayer:addChild(titleBgNode)
    
    self._maskLayer.titleBgNode = titleBgNode


    local tmpTitle = cc.Sprite:createWithSpriteFrameName("intanceImage_plotReviewTitle.png")
    tmpTitle:setAnchorPoint(0.5, 1)
    tmpTitle:setPosition(titleBgNode:getContentSize().width * 0.5, titleBgNode:getContentSize().height + 10)
    titleBgNode:addChild(tmpTitle)
    
    -- 坐标1
    local tmpTitle = cc.Sprite:createWithSpriteFrameName("intanceImage_plotReviewUpLight.png")
    tmpTitle:setAnchorPoint(0, 0)
    tmpTitle:setPosition(100, 100)
    titleBgNode:addChild(tmpTitle)
    self._maskLayer.tmpTitle1 = tmpTitle

    -- 坐标2
    local tmpTitle = cc.Sprite:createWithSpriteFrameName("intanceImage_plotReviewUpLight.png")
    tmpTitle:setAnchorPoint(0, 0)
    tmpTitle:setPosition(-25, 2)
    titleBgNode:addChild(tmpTitle)
    self._maskLayer.tmpTitle2 = tmpTitle


    titleBgNode:setCascadeOpacityEnabled(true, true)
    if self._model == 1 then
        titleBgNode:setOpacity(0)
        self._maskLayer:setOpacity(0)
        self._maskLayer:setVisible(false)

    else
        registerClickEvent(self._maskLayer, function ()
            self:close()
        end)        
    end


    local titleLab = self:getUI("bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 3)

    self._pageBg = self:getUI("bg.pageBg")

    local leftArrow = self:getUI("bg.leftArrow")
    local rightArrow = self:getUI("bg.rightArrow")

    registerClickEvent(leftArrow, function ()
        self:goPrePage()
    end)

    
    registerClickEvent(rightArrow, function ()
        self:goNextPage()
    end)  

    local count = #tab.mainPlotReview

    self._maxPage = math.ceil(count / 6)
    self._copyItem = self:getUI("item")

    self._curPage = 1

    local bg = self:getUI("bg")

    local xOffset = 10
    local x = bg:getContentSize().width * 0.5 - (self._maxPage / 2 ) * 20 + xOffset

    for i=1, self._maxPage do
        local graySp = ccui.ImageView:create()
        graySp:loadTexture("globaImageUI_pagePointGray.png", 1)
        graySp:setPosition(x, 40)

        graySp:setName("gray_" .. i)
        bg:addChild(graySp)
        x = x + 20
    end

    local mainsData = self._modelMgr:getModel("IntanceModel"):getData().mainsData
    self._curStageId = mainsData.curStageId

    self._curPageLayer = self:createPageLayer(self._curPage)
    self._curPageLayer:setAnchorPoint(0, 0)
    self._curPageLayer:setPosition(0, 0)
    self._pageBg:addChild(self._curPageLayer)
    self._pageBg.pageNum = self._curPage
    self:updatePageTip(self._curPage)



    
end

function IntancePlotReviewView:jumpToPage(inSelPage)
    if inSelPage > self._maxPage or inSelPage < 0 then return end

    self._curPage = inSelPage
    self:updatePageTip(self._curPage)
end

function IntancePlotReviewView:goPrePage()
    if self._curPage - 1 == 0 then 
        self._curPage = self._maxPage
    else
        self._curPage = self._curPage - 1
    end
    self:updatePageTip(self._curPage)
end

function IntancePlotReviewView:goNextPage()
    if self._curPage + 1 > self._maxPage then 
        self._curPage = 1
    else
        self._curPage = self._curPage + 1
    end
    self:updatePageTip(self._curPage)
end

function IntancePlotReviewView:updatePageTip(inSelPageNum)
    local bg = self:getUI("bg")
    if self._selectPointTip == nil then 
        self._selectPointTip = cc.Sprite:createWithSpriteFrameName("globaImageUI_pagePointRed.png")
        bg:addChild(self._selectPointTip)
        self._selectPointTip:setPosition(0, 40)
    end
    local graySp = bg:getChildByName("gray_" .. inSelPageNum)
    if graySp == nil then 
        self._selectPointTip:setVisible(false)
        return 
    end

    self._selectPointTip:setVisible(true)
    self._selectPointTip:setPositionX(graySp:getPositionX())
    if self._pageBg.pageNum  ~= inSelPageNum then
        local nextPageLayer = self._pageBg:getChildByName("page_" .. inSelPageNum)
        if nextPageLayer == nil then 
            nextPageLayer = self:createPageLayer(inSelPageNum)
            nextPageLayer:setAnchorPoint(0, 0)
            self._pageBg:addChild(nextPageLayer)
        end

        if self._pageBg.pageNum > inSelPageNum then
            nextPageLayer:setPosition(-nextPageLayer:getContentSize().width, 0)
            self._curPageLayer:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(0.5, cc.p(nextPageLayer:getContentSize().width, 0)),
                    cc.RemoveSelf:create()
                ))
        else
            nextPageLayer:setPosition(nextPageLayer:getContentSize().width, 0)
            self._curPageLayer:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(0.5, cc.p(-nextPageLayer:getContentSize().width, 0)),
                    cc.RemoveSelf:create()
                ))
        end
        nextPageLayer:runAction(
            cc.Sequence:create(
                cc.MoveTo:create(0.5, cc.p(0, 0))
            ))

        self._curPageLayer = nextPageLayer
    end
    self._pageBg.pageNum = inSelPageNum

    local leftArrow = self:getUI("bg.leftArrow")
    local rightArrow = self:getUI("bg.rightArrow")
    if self._curPage == 1 then 
        leftArrow:setVisible(false)
    else
        leftArrow:setVisible(true)
    end
    if self._curPage == self._maxPage then
        rightArrow:setVisible(false)
    else
        rightArrow:setVisible(true)
    end
end


function IntancePlotReviewView:createPageLayer(inPageNum)
    local pageLayer = ccui.Widget:create()
    pageLayer:setContentSize(self._pageBg:getContentSize().width, self._pageBg:getContentSize().height)
    local x = 0
    local y = pageLayer:getContentSize().height


    for i=(inPageNum - 1) * 6 + 1 ,inPageNum * 6  do
        local item = self._copyItem:clone()
        item:setAnchorPoint(0, 1)
        item:setPosition(x, y)
        local sysMainPlotReview = tab.mainPlotReview[i]
        local title = item:getChildByName("titleLab")
        local leftAdorn = item:getChildByName("leftAdorn")
        local rightAdorn = item:getChildByName("rightAdorn")
        local playBtn = item:getChildByName("playBtn")
        local lockImg = item:getChildByName("lockImg")
        local nameBg = item:getChildByName("nameBg")
        
        if sysMainPlotReview == nil then 
            title:setVisible(false)
            leftAdorn:setVisible(false)
            rightAdorn:setVisible(false)
            item:loadTexture("intanceImage_plotReview9999.jpg", 1)
            lockImg:setVisible(false)
            playBtn:setVisible(false)
            nameBg:setVisible(false)
            registerClickEvent(item, function ()
                self._viewMgr:showTip(lang("CUTTIPS9999"))
            end)   
        else
            nameBg:setVisible(true)
            item:loadTexture(sysMainPlotReview.art .. ".jpg", 1)

            title:setColor(cc.c4b(255, 255, 255, 255))
            title:enable2Color(1, cc.c4b(255, 221, 63, 255))
            title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            title:setString(lang(sysMainPlotReview.name))
            local stateInfo  = self._intanceModel:getStageInfo(sysMainPlotReview.mainStageId)
            if stateInfo.star <= 0 then 
                item:setSaturation(-100)
                -- item:set
                lockImg:setVisible(true)
                playBtn:setVisible(false)
                item:setTouchEnabled(false)
                registerClickEvent(lockImg, function ()
                    self._viewMgr:showTip(lang(sysMainPlotReview.desc))
                end)  
                registerClickEvent(item, function ()
                    self._viewMgr:showTip(lang(sysMainPlotReview.desc))
                end)                  
            else
                playBtn:setVisible(true)
                lockImg:setVisible(false)
                -- registerClickEvent(item, function ()
                --     self:showPlot(sysMainPlotReview.mainPlotId, 1)
                -- end) 
                registerClickEvent(playBtn, function ()
                    self:showPlot(sysMainPlotReview.mainPlotId, 1)
                end)    
                registerClickEvent(item, function ()
                    self:showPlot(sysMainPlotReview.mainPlotId, 1)
                end)                                         
            end
        end
        pageLayer:addChild(item)
        UIUtils:adjustTitle(item, 15)
        x = x + item:getContentSize().width + 10
        if i % 3 == 0 then 
            y = y - item:getContentSize().height - 10
            x = 0
        end
    end
    pageLayer:setName("page_" .. inPageNum)
    return pageLayer
end


function IntancePlotReviewView:showPlot(inPlotIds, inIndex)
    if inIndex > #inPlotIds then
        return
    end
    local plotId = inPlotIds[inIndex]
    local sysMainPlot = tab.mainPlot[plotId]
    self._maskLayer:setVisible(true)
    self._maskLayer.title:setString(lang(sysMainPlot.title))
    self._maskLayer:setOpacity(255)
    self._maskLayer:runAction(
        cc.Sequence:create(
            cc.CallFunc:create(function()
                self._maskLayer.titleBgNode:runAction(
                    cc.Sequence:create(
                        cc.FadeIn:create(1),
                        cc.DelayTime:create(1),
                        cc.FadeOut:create(1)
                    ))
            end),
            cc.DelayTime:create(2),
            cc.CallFunc:create(function()
                self._viewMgr:showView("intance.IntanceMcPlotView", {plotId = plotId, skipReward = 1, callback = function()
                    self._viewMgr:popView()
                    self:showPlot(inPlotIds, inIndex + 1)
                end})                
            end),     
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
                self._maskLayer:setVisible(false)
            end)
        ))
end

function IntancePlotReviewView:onDestroy()
    IntancePlotReviewView.super.onDestroy(self)
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("asset/ui/intancePlot.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/ui/intancePlot.png")
end

function IntancePlotReviewView:onInit()


end

return IntancePlotReviewView