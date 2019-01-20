--
-- Author: huangguofang
-- Date: 2018-10-08 18:21:36
--
local FlashCardView = require("game.view.flashcard.FlashCardView")

local raceLayerPosX = {1143,1602}
local raceSingle = tab:RaceDrawConfig("cost_one").content
local raceTen = tab:RaceDrawConfig("cost_ten").content
local drawNumMax = tab:Setting("RACE_DRAWTIME").value

function FlashCardView:initFlashCardUI()
    -- body
    -- print("=============race FlashCardView==============",raceSingle,raceTen)
    self._boxMc = {}         -- 常态动画
    self._boxOpenMc = nil    -- 开箱动画

    self._raceDrawModel = self._modelMgr:getModel("RaceDrawModel")
    
    local tOneBtn = self:getUI("bg.raceBtnLayer.buyOneBtn")
    self._raceOneBtn = tOneBtn
    local tTenBtn = self:getUI("bg.raceBtnLayer.buyTenBtn")
    self._raceTenBtn = tTenBtn
    self:addAnimation2Node("anniuguangxiao_tongyonganniu",self:getUI("bg.raceBtnLayer.buyTenBtn.animImg"),{zOrder = 10,offsetx = 0,offsety = 0})

    self:registerClickEvent(tOneBtn,function( )
        self._buyNum = 1
        self:raceFlashDraw(1)
    end)
    self:registerClickEvent(tTenBtn,function( )
        self._buyNum = 10
        self:raceFlashDraw(10)
    end)

    local costImageName = self._isLuckyCoin and "globalImageUI_luckyCoin.png" or "globalImageUI_diamond.png"
    self._rCostImage = self:getUI("bg.raceLayer.quan_img")
    self._rOneCostImage = self:getUI("bg.raceBtnLayer.buyOneCostLayer.Image_29")
    self._rTenCostImage = self:getUI("bg.raceBtnLayer.buyTenCostLayer.Image_30")
    self._rOneCost = self:getUI("bg.raceBtnLayer.buyOneCostLayer.cost")
    self._rOneCost:setFontName(UIUtils.ttfName)
    self._rOneCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local raceDiscountLab = ccui.Text:create()
    raceDiscountLab:setFontName(UIUtils.ttfName)
    raceDiscountLab:setName("raceDiscountLab")
    raceDiscountLab:setFontSize(self._gOneCost:getFontSize())
    self._rOneCost:addChild(raceDiscountLab)

    self._rTenCost = self:getUI("bg.raceBtnLayer.buyTenCostLayer.cost")
    self._rTenCost:setFontName(UIUtils.ttfName)
    self._rTenCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._rBtnTimeLab = self:getUI("bg.raceBtnLayer.buyOneCostLayer.timeLab")
    self._rBtnTimeLab:setVisible(true)
    self._rBtnTimeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._rCostImage:loadTexture(costImageName,1)
    self._rOneCostImage:loadTexture(costImageName,1)
    self._rTenCostImage:loadTexture(costImageName,1)

    local leftTimesDes1 = self:getUI("bg.raceBtnLayer.leftTimesDes1")
    self._leftTimes = self:getUI("bg.raceBtnLayer.leftTimes")
    self._leftTimesDes2 = self:getUI("bg.raceBtnLayer.leftTimesDes2")
    leftTimesDes1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._leftTimes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._leftTimesDes2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._raceDrawData = self._raceDrawModel:getData() or {}
    self._raceNum = table.nums(self._raceDrawData)
    self._teamDrawBtn = self:getUI("bg.teamDrawBtn")
    self._raceDrawBtn = self:getUI("bg.raceDrawBtn")
    self._teamDrawBtn:setCascadeOpacityEnabled(true,true)
    self._raceDrawBtn:setCascadeOpacityEnabled(true,true)
    self._teamDrawBtn:setOpacity(255)
    self._raceDrawBtn:setOpacity(255)    
    self._teamDrawBtn:setVisible(false)
    print(self._raceNum,SystemUtils["enableRaceDraw"]() ,"======123123123123============",self._raceNum > 0 and SystemUtils["enableRaceDraw"]())
    self._raceDrawBtn:setVisible(self._raceNum > 0 and SystemUtils["enableRaceDraw"]())
    self._raceDrawBtn:setEnabled(self._raceNum > 0 and SystemUtils["enableRaceDraw"]())
    self:registerClickEvent(self._teamDrawBtn,function(sender)
        -- 切换到抽卡
        self:changeToTeamLayer()
    end)

    self:registerClickEvent(self._raceDrawBtn,function(sender)
        -- 切换到阵营抽卡
        self:changeToRaceLayer()
    end)
    self._raceLayerArr = {}
    local i = 1
    for k,v in pairs(self._raceDrawData) do
        local layer = self._raceLayer:clone()
        layer:setCascadeOpacityEnabled(true,true)
        layer:setVisible(false)
        layer:loadTexture("flashCard_race" .. k .. ".png",1)
        layer:setPosition(raceLayerPosX[i], 288)
        self._bg:addChild(layer,6)
        self._raceLayerArr[i] = layer
        layer._raceId = k
        -- self:addAnimation2Node("zitiguangxiao_flashcarduianim",layer,{zOrder = 2,offsetx = -30,offsety = -100,scale =0.95,delayTime=7})
        i = i + 1
        self:updateLayerUI(k,layer)
        self:registerClickEvent(layer,function(sender)
            if sender:isVisible() then
                self._gemBtnLayer:setVisible(false)
                self._toolBtnLayer:setVisible(false)
                self._isBounceLock = true
                self:lock(-1)
                self._costType = "race"
                sender:setBrightness(40)
                self._raceId = tonumber(k)
                self._currRaceLayer = sender

                self:updateRaceBtnLayer(k)
                ScheduleMgr:delayCall(150, self, function( )
                    if not self._raceBtnLayer then return end
                    self._raceBtnLayer:setOpacity(0)
                    local children = self._raceBtnLayer:getChildren()
                    sender:setBrightness(0)
                    self:bgBounceUpRace()
                    -- self:addAnimation2Node("shanguang_flashcardanim",self._bg,{zOrder = 99,endCallback = function( sender )
                    --     sender:removeFromParent()
                    -- end})   
                end)
            end
        end)
    end
    if i == 2 then
        self._raceLayerArr[1]:setPositionX(1375)
    end

    local drawNode = cc.DrawNode:create()
    self._rbtnDraw = drawNode
    self:getUI("bg.raceBtnLayer.buyOneCostLayer"):addChild(drawNode,999)
end


function FlashCardView:updateRaceBtnLayer(raceID)
    -- print("======updateRaceBtnLayer========",raceId)
    local raceId = raceID or self._raceId
    if not raceId then return end
    self._raceDrawData = self._raceDrawModel:getData() or {}
    local stateNum = self._raceDrawModel:getStateNum(raceId) or 1
    local isFree = stateNum == 0
    local isHalf = stateNum == 0.5

    local cost = raceSingle
    local disCount = raceSingle*stateNum

    -- local boardOffsetX = self._gBoardW/2
    local diaImg1 = self:getUI("bg.raceBtnLayer.buyOneCostLayer.Image_29")
    local raceDiscountLab = self._rOneCost:getChildByFullName("raceDiscountLab")
    if raceDiscountLab then
        raceDiscountLab:setVisible(false)
    end
    if self._rbtnDraw then
        self._rbtnDraw:clear()
    end

    local gemHaveNum = self._userModel:getData()[self._rightCostType] or 0
    if isFree then
        cost = "本次免费"
        diaImg1:setVisible(false)
        self._rOneCost:setColor(cc.c4b(0,255,30,255))
        self._rBtnTimeLab:setString("")
    else
        self._rOneCost:setColor(cc.c4b(255,255,255,255))
        self._rOneCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        diaImg1:setVisible(true)
        if isHalf then
            -- boardOffsetX = boardOffsetX-(lw-dw)/2
            -- 固定字儿设固定改位置
            self._rBtnTimeLab:setString("")
        else            
            self._rBtnTimeLab:setString("次日5点半价")
            -- boardOffsetX = self._gBoardW/2+(lw-dw)/2
        end
    end 
    -- print("============cost=====",cost)
    self._rOneCost:setString(cost)
   
    if isHalf then
        local costW,costH = self._rOneCost:getContentSize().width,self._rOneCost:getContentSize().height
        local costX,costY = self._rOneCost:getPositionX(),self._rOneCost:getPositionY()
        self._rbtnDraw:drawSegment(cc.p(costX-costW/2,costY),cc.p(costX+costW/2,costY),1,cc.c4f(1.0, 0.0, 0.0, 1.0))
        raceDiscountLab:setPosition(cc.p(costW*1.5,costH/2))
        raceDiscountLab:setVisible(true)
        self._rOneCost:setColor(cc.c4b(255,255,255,255))
        raceDiscountLab:setString(disCount)
        self:textColorRed(raceDiscountLab,gemHaveNum < disCount and not isFree,cc.c4b(0, 255, 0, 255))
    else
        self:textColorRed(self._rOneCost,gemHaveNum < disCount and not isFree)
    end 

    self._rTenCost:setString(raceTen)       
    self:textColorRed(self._rTenCost,(gemHaveNum < raceTen), cc.c4b(0, 255, 0, 255))

    --按钮特效层 不满足条件，不加特效
    local btnAnim = self._gTenBtn:getChildByFullName("animImg")
    if btnAnim then
        btnAnim:setVisible(gemHaveNum >= raceTen)
    end
    -- dump(self._raceDrawData,"self._raceDrawData===>",5)
    local data = self._raceDrawData[tostring(raceId)] or {}
    local drawCount = data.drawCount or 0
    self._leftTimes:setString(drawNumMax - drawCount)
    self:textColorRed(self._leftTimes,(drawNumMax <= drawCount),cc.c4b(255,255,255,255))
    -- self._leftTimesDes2:setPositionX(self._leftTimes:getPositionX()+self._leftTimes:getContentSize().width+2)
    self:updateLayerUI(raceId)
end

function FlashCardView:updateLayerUI(raceId,layer)
    local raceLayer = layer
    if not raceLayer then
        raceLayer = self._currRaceLayer
    end
    if not raceLayer then return end
    local stateNum = self._raceDrawModel:getStateNum(raceId) or 1
    -- print("==============updateLayerUI===============",raceId,stateNum)
    local isFree = stateNum == 0
    local isHalf = stateNum == 0.5

    local cost = raceSingle
    local disCount = raceSingle*stateNum

    local gemHaveNum = self._userModel:getData()[self._rightCostType] or 0
    local rLayerCost = raceLayer:getChildByFullName("cost")
    local rLayerTimelab = raceLayer:getChildByFullName("timeLab")
    local rLayerDot = raceLayer:getChildByFullName("dot")
    rLayerCost:setVisible(true)
    rLayerTimelab:setVisible(true)
    rLayerDot:setVisible(false)

    rLayerCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    rLayerTimelab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- print("==============isFree======",isFree,isHalf)
    if isFree then
        -- layer显示
        rLayerCost:setColor(cc.c4b(0,255,30,255))
        rLayerCost:setString("本次免费")
        rLayerTimelab:setColor(cc.c4b(0,255,30,255))
        rLayerTimelab:setString("开启后首次免费")
        rLayerDot:setVisible(true)
    else
        rLayerCost:setColor(cc.c4b(255,255,255,255))
        rLayerCost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        if isHalf then           
            -- layer显示
            rLayerCost:setString("半价")
            self:textColorRed(rLayerCost,gemHaveNum < disCount and not isFree,cc.c4b(0,255,30,255))
            rLayerTimelab:setString("每日首次")
            rLayerTimelab:setColor(cc.c4b(0,255,30,255))
            rLayerDot:setVisible(true)
        else
            -- layer显示
            rLayerCost:setString(cost)
            self:textColorRed(rLayerCost,gemHaveNum < disCount and not isFree,cc.c4b(0,255,30,255))
            rLayerTimelab:setColor(cc.c4b(255,255,255,255))
            rLayerTimelab:setString("次日5点半价")
            rLayerDot:setVisible(false)
        end
    end 
    
end

local bounceTime = 0.5
local easeOutRate = 1--6
local zAngle = 30
function FlashCardView:bgBounceUpRace( notShowApearAnim ) 
    self._rbtnDraw:setVisible(true)   
    self._teamDrawBtn:setOpacity(255)
    self._raceDrawBtn:setOpacity(255)
    self._teamDrawBtn:setEnabled(false)
    self._raceDrawBtn:setEnabled(false)
    self._teamDrawBtn:runAction(cc.FadeOut:create(0.1))
    self._raceDrawBtn:runAction(cc.FadeOut:create(0.1))
    self:loadSceneBg("yin")
    self:showAltarAnim()
    self._returnBtn:setVisible(true)
    self._inBounce = true
    -- self._gemBtnLayer:setEnabled(false)
    -- self._toolBtnLayer:setEnabled(false)
    self._raceBtnLayer:setEnabled(false)

    self._bg0:runAction(cc.EaseOut:create(cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255, 255, 255)),cc.ScaleTo:create(bounceTime,self._bounceUpScales[1])),easeOutRate))
    -- self._bg2:runAction(cc.EaseOut:create(cc.Spawn:create(cc.ScaleTo:create(bounceTime,self._bounceUpScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2)),easeOutRate))
    self._bg2:runAction(cc.EaseOut:create(
            cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255, 255, 255)),cc.RotateBy:create(bounceTime,0,0),cc.ScaleTo:create(bounceTime,self._bounceUpScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,0--[[self._bg:getContentSize().height*0.55--]])))
        ,easeOutRate))
    self._bg1:runAction(cc.EaseOut:create(cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255, 255, 255)),cc.ScaleTo:create(bounceTime,self._bounceUpScales[2]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height*0.63))),easeOutRate))
    
    self._bg3:runAction(cc.EaseOut:create(
            cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255, 255, 255)),cc.RotateBy:create(bounceTime,0,0),cc.ScaleTo:create(bounceTime,self._bounceUpScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,80)))
        ,easeOutRate))    
    
    self:runAction(cc.Sequence:create(cc.DelayTime:create(bounceTime),cc.CallFunc:create(function( )
        self._inBuyScene = true
    end))) 
    self._showCangetBtn:setVisible(true)
    self._showCangetBtn:setOpacity(0)
    self:fadeInWithChildrenRace(self._showCangetBtn)
    -- self._lockView:setSwallowTouches(true)
   
    for k,v in pairs(self._raceLayerArr) do
        self:fadeOutWithChildrenRace(v)       
    end
    self:fadeInWithChildrenRace(self._gemBar)    
    self._keyImg:setVisible(false)
    self._keyBg:setVisible(false)
    self._goldKeyNum:setVisible(false)    
    self:fadeInWithChildrenRace(self._raceBtnLayer)

    if not self._raceId then
        self._raceId = 101
    end
    -- 添加常态动画
    self:addRaceFlashCardMc()        
    self._inBounce = false
    if self._isBounceLock then
        self._isBounceLock = false
        self:unlock()
    end
    self._raceBtnLayer:setEnabled(true)
    
    self._viewMgr:showNavigation("global.UserInfoView",{types= self._navigationRes,hideBtn = true,hideInfo=true})

end
-- local easeInRate = 3
function FlashCardView:bgBounceDownRace( )
    self._rbtnDraw:setVisible(false) 
    self._teamDrawBtn:setOpacity(0)
    self._raceDrawBtn:setOpacity(0)
    self._teamDrawBtn:setEnabled(true)
    self._raceDrawBtn:setEnabled(true)
    self._teamDrawBtn:runAction(cc.FadeIn:create(0.1))
    self._raceDrawBtn:runAction(cc.FadeIn:create(0.1))
    self:hideAltarAnim()
    self._returnBtn:setVisible(false)
    self._inBounce = true
    self._bg0:runAction(cc.EaseOut:create(cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255*0.46, 255*0.46, 255*0.46)),cc.ScaleTo:create(bounceTime,self._initBgScales[1])),easeOutRate))
    self._bg1:runAction(cc.EaseOut:create(cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255*0.46, 255*0.46, 255*0.46)),cc.ScaleTo:create(bounceTime,self._initBgScales[2]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height*0.5))),easeOutRate))
    self._bg2:runAction(cc.EaseOut:create(
                cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255*0.52, 255*0.52, 255*0.52)),cc.RotateBy:create(bounceTime,-0,-0),cc.ScaleTo:create(bounceTime,self._initBgScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,0--[[self._bg:getContentSize().height*0.5]])))
            ,easeOutRate))
    self._bg3:runAction(cc.EaseOut:create(
                cc.Spawn:create(cc.TintTo:create(bounceTime,cc.c3b(255*0.52, 255*0.52, 255*0.52)),cc.RotateBy:create(bounceTime,-0,-0),cc.ScaleTo:create(bounceTime,self._initBgScales[3]),cc.MoveTo:create(bounceTime,cc.p(self._bg:getContentSize().width/2,80)))
            ,easeOutRate))

    self:runAction(cc.Sequence:create(cc.DelayTime:create(bounceTime),cc.CallFunc:create(function( )
        self._inBuyScene = false
        self._inBounce = false
        if self._isBounceLock then
            self._isBounceLock = false
            self:unlock()
        end
        for k,v in pairs(self._raceLayerArr) do
            v:setVisible(true)
            v:setOpacity(255)   
        end
     
        self._costType = nil
    end)))

    for k,v in pairs(self._raceLayerArr) do
        self:fadeInWithChildrenRace(v)   
        self:updateLayerUI(v._raceId,v)
    end
    self:fadeOutWithChildrenRace(self._gemBar,function( )
        self._viewMgr:showNavigation("global.UserInfoView",{types= self._navigationRes,hideHead = true}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
    end)

    -- self._showCangetBtn:setVisible(false)
    self:fadeOutWithChildrenRace(self._showCangetBtn,function( )
        self._showCangetBtn:setOpacity(255)
        self._showCangetBtn:setVisible(false)
    end)
    -- print('========111111111=======================',self._boxMc,table.nums(self._boxMc))
    self:fadeOutWithChildrenRace(self._raceBtnLayer)
    for k,v in pairs(self._boxMc) do
        -- print("============2222222222=======================")
        v:setVisible(false)
    end
end

local moveDis = 894
function FlashCardView:changeToTeamLayer()
    self._drawType = "team"
    -- print("==================changeToTeamLayer=====")
    self._teamDrawBtn:setVisible(false)
    self._raceDrawBtn:setVisible(true)
    self._raceDrawBtn:setOpacity(0)
    self._teamDrawBtn:setEnabled(false)
    self._raceDrawBtn:setEnabled(false)

    -- runAction
    local rightMove1 = cc.MoveBy:create(0.25,cc.p(moveDis,0))
    self._gemLayer:setVisible(true)
    self._gemLayer:setOpacity(0)
    self._gemLayer:runAction(cc.Spawn:create(rightMove1,cc.FadeIn:create(0.25) ))
    self._toolLayer:setVisible(true)
    self._toolLayer:setOpacity(0)
    self._toolLayer:runAction(cc.Spawn:create(rightMove1:clone(),cc.FadeIn:create(0.25) ))

    self._gemLayer:setEnabled(false)
    self._toolLayer:setEnabled(false)
    for k,v in pairs(self._raceLayerArr) do
        v:setVisible(true)
        v:setOpacity(255)
        v:setEnabled(false)
        local moveAction = cc.Sequence:create(
                cc.Spawn:create(rightMove1:clone(),                                             
                    cc.FadeOut:create(0.1)) )
        v:runAction(moveAction)
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.25),cc.CallFunc:create(function( )
        if self._gemLayer then 
            self._gemLayer:setEnabled(true)
            self._gemLayer:setVisible(true)
        end
        if self._toolLayer then 
            self._toolLayer:setEnabled(true)
            self._toolLayer:setVisible(true)
        end
        if not self._raceLayerArr then return end
        for k,v in pairs(self._raceLayerArr) do
            -- v:setVisible(true)
            if v then 
                v:setVisible(false)
                v:setEnabled(false)
            end
        end
    end)))

    self._raceDrawBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.FadeIn:create(0.2),
        cc.CallFunc:create(function ()
            if self._raceDrawBtn then
                self._raceDrawBtn:setEnabled(true)
            end
        end)
        ))

end
function FlashCardView:changeToRaceLayer()
    self._drawType = "race"
    -- print("==================changeToRaceLayer=====")
    self._raceDrawBtn:setVisible(false)
    self._teamDrawBtn:setVisible(true)
    self._teamDrawBtn:setOpacity(0)

    local leftMove1 = cc.MoveBy:create(0.25,cc.p(-moveDis,0))
    self._gemLayer:runAction(cc.Spawn:create(leftMove1,cc.FadeOut:create(0.25) ))
    self._toolLayer:runAction(cc.Spawn:create(leftMove1:clone(),cc.FadeOut:create(0.25) ))
    self._gemLayer:setEnabled(false)
    self._toolLayer:setEnabled(false)
    for k,v in pairs(self._raceLayerArr) do
        v:setVisible(true)
        v:setOpacity(255)
        v:setEnabled(false)
        local moveAction = cc.Sequence:create(
                cc.Spawn:create(leftMove1:clone(),                                             
                    cc.FadeIn:create(0.1)) )
        v:runAction(moveAction)
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.25),cc.CallFunc:create(function( )
        if self._gemLayer then 
            self._gemLayer:setEnabled(false)
            self._gemLayer:setVisible(false)
        end
        if self._toolLayer then 
            self._toolLayer:setEnabled(false)
            self._toolLayer:setVisible(false)
        end
        if not self._raceLayerArr then return end
        for k,v in pairs(self._raceLayerArr) do
            if v then
                v:setEnabled(true)
            end
        end
    end)))
    self._teamDrawBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.FadeIn:create(0.2),
        cc.CallFunc:create(function ()
            if self._teamDrawBtn then
                self._teamDrawBtn:setEnabled(true)
            end
        end)
        ))

end
-- 抽卡动画
function FlashCardView:raceDrawAnim( )
    
end

local fadeOutTime = 0.3
local fadeInTime = 0.3
-- 隐藏
function FlashCardView:fadeOutWithChildrenRace( node,callback )
    node:setScale(1)    
    node:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeOut:create(fadeOutTime),cc.ScaleTo:create(0.2,1)),cc.CallFunc:create(function( )
        if callback then
            callback()
        end
        node:setVisible(false)
        node:setOpacity(0)
        node:setBrightness(0)
    end)))
    local children = node:getChildren()
    for k,v in pairs(children) do
        v:setCascadeOpacityEnabled(true)
        v:runAction(cc.Sequence:create(cc.FadeOut:create(fadeOutTime),cc.CallFunc:create(function( )
            v:setOpacity(0)
        end)))
    end
end
-- 展示
function FlashCardView:fadeInWithChildrenRace( node,callback )
    node:setScale(1)
    node:setVisible(true)
    node:setOpacity(0)
    node:runAction(cc.Sequence:create(cc.FadeIn:create(fadeInTime),cc.CallFunc:create(function( )
        if callback then
            callback()
        end
        node:setVisible(true)
    
    end)))
    local children = node:getChildren()
    for k,v in pairs(children) do
        v:setVisible(true)
        v:setOpacity(0)
        v:runAction(cc.FadeIn:create(fadeInTime))
    end
end

function FlashCardView:raceFlashDraw(drawNum)
    -- print("===================drawNum====",drawNum)
    local player = self._modelMgr:getModel("UserModel"):getData()
    local gem = player[self._rightCostType] or 0

    local data = self._raceDrawData[tostring(self._raceId)] or {}
    local drawCount = data.drawCount or 0

    local stateNum = self._raceDrawModel:getStateNum(self._raceId) or 1
    local isFree = stateNum == 0
    local isHalf = stateNum == 0.5
    if drawNumMax - drawCount < drawNum and not (drawNum == 1 and (isFree or isHalf)) then
        self._viewMgr:showTip(lang("TIP_raceDrawtimes"))
        return
    end

    local disCount = raceSingle*stateNum
    if drawNum == 10 then
        disCount = raceTen
    end
    if gem < disCount and not (drawNum == 1 and isFree) then
        self:showNeedCharge(disCount-gem)
        return 
    end

    self._raceOneBtn:setTouchEnabled(false)
    self._raceTenBtn:setTouchEnabled(false)
    self._returnBtn:setTouchEnabled(false)
    self._showCangetBtn:setTouchEnabled(false)
    self._buyGemBtn:setTouchEnabled(false)

    self._serverMgr:sendMsg("RaceDrawServer", "drawCard", {raceId = self._raceId, num = drawNum}, true, {}, function(result,error) 
        dump(result,"---抽卡结果--->")
        if not self.lock then return end
        self:lock(-1)
        audioMgr:playSound("Draw")
        self._yunSpeed = 1-- 去掉云加速 2017.5.17 

        self:showRaceBoxMc()
        self:playStatueMc()
        ScheduleMgr:delayCall(1800, self, function( )
            if not self.reflashUI then return end
            -- notUnLock = false
            if self.unlock then 
                self:unlock()
            end
            self:resultAwardShow(result)
            self._yunSpeed = 1
            self:stopStatueMc()

        end)
    end,
    function( )
        if self.unlock then 
            self:unlock()
        end
        if not self._raceOneBtn then return end
        self._raceOneBtn:setTouchEnabled(true)
        self._raceTenBtn:setTouchEnabled(true)
        self._returnBtn:setTouchEnabled(true)
        self._showCangetBtn:setTouchEnabled(true)
        self._buyGemBtn:setTouchEnabled(true)
    end)
end

function FlashCardView:resultAwardShow(result)
    -- print("==================DialogRaceFlashCardResult=======",DialogRaceFlashCardResult)
    local data = result or {}
    if not data then 
        data = {}
    end
    if not data.awards then
        data.awards = {{"tool",3104,3}}
    end
    local moveAction = cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(0,50)),cc.MoveBy:create(0.35,cc.p(0,-300)),cc.CallFunc:create(function()
        self._raceBtnLayer:setVisible(false)

        self._viewMgr:showDialog("flashcard.DialogRaceFlashCardResult",{ 
            awards = (data.awards or {}),
            costType = self._costType,
            buyNum = self._buyNum,
            raceId = self._raceId,
            callback = function( awards )
                -- self:removeMC("choukabeijing_choukaanim2")
                self:bgBounceUpRace(true)
                local moveBack = cc.Sequence:create(cc.MoveBy:create(0.25,cc.p(0,270)),cc.MoveBy:create(0.2,cc.p(0,-20)))
                self._raceBtnLayer:setVisible(true)
                self._raceBtnLayer:setOpacity(255)
                self._raceBtnLayer:runAction(moveBack)
                
                self._raceOneBtn:setTouchEnabled(true)
                self._raceTenBtn:setTouchEnabled(true)

                self._returnBtn:setTouchEnabled(true)
                self._showCangetBtn:setTouchEnabled(true)
                self._buyGemBtn:setTouchEnabled(true)
                
                self:showCommentView(awards or data.awards)
                self._modelMgr:getModel("GuildRedModel"):checkRandRed()
                if self._boxMc[self._raceId] then 
                    self._boxMc[self._raceId]:setVisible(true)
                end
                -- print("==================DialogRaceFlashCardResult=======",DialogRaceFlashCardResult)
                self:updateRaceBtnLayer()
            end},true)
    end))
    
    self._raceBtnLayer:runAction(moveAction)              
end

function FlashCardView:showRaceBoxMc( )
    if not self._boxOpenMc then
        local mc = self:addAnimation2Node("zhengyingchouka_zhenyingchouka",self._bg,{})
        mc:gotoAndStop(0)
        mc:setVisible(false)
        mc:setCascadeOpacityEnabled(true,true)
        self._boxOpenMc = mc
    end
    self._boxOpenMc:setVisible(true)
    self._boxOpenMc:gotoAndPlay(0)
    self._boxMc[self._raceId]:setVisible(false)
   
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(2),
        cc.CallFunc:create(function( )
            self._boxOpenMc:setVisible(false)
        end)
    ))
end

function FlashCardView:addRaceFlashCardMc( )
    if self._boxMc[self._raceId]  then
        self._boxMc[self._raceId]:setVisible(true)
        return
    end
    local layout = ccui.Layout:create()
    -- layout:setBackGroundColorOpacity(255)
    -- layout:setBackGroundColorType(1)
    -- layout:setBackGroundColor(cc.c3b(255,255,255))
    layout:setContentSize(100, 100)
    self._bg:addChild(layout)
    layout:setPosition(280,180)
    self._boxMc[self._raceId] = layout

    local cardSp = cc.Sprite:createWithSpriteFrameName("flashCard_" .. self._raceId .. "_mc1.png")
    cardSp:setName("cardSp")
    cardSp:setAnchorPoint(0,0)
    cardSp:setPosition(0,10)
    -- cardSp:setBlendFunc({src = 770, dst = 1})
    -- local pro1 = 69 * 0.01
    -- local pro2 = 1 - pro1
    -- cardSp:setCM(pro2, pro2, pro2, 1, 255 * pro1, 102 * pro1, 0 * pro1, 0)
    layout:addChild(cardSp)

    local mc = mcMgr:createViewMC("zhenyingchoukachangtai_zhenyingchouka", true)
    mc:setPosition(200, 180)
    layout:addChild(mc,10)

    self._mcIndex = 2
    local action = cc.RepeatForever:create(
        cc.Sequence:create(cc.DelayTime:create(4.0),cc.FadeOut:create(0.5),cc.CallFunc:create(function( )
            cardSp:setSpriteFrame("flashCard_" .. self._raceId .. "_mc".. self._mcIndex ..".png") 
            local index = math.random(1, 3)
            if self._mcIndex == index then
                self._mcIndex = index + 1
            else
                self._mcIndex = index
            end
            if  self._mcIndex > 3 then
                self._mcIndex = index - 1
            end
        end), cc.FadeIn:create(0.7))
        )

    cardSp:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveTo:create(1,cc.p(0,13)),
            cc.MoveTo:create(1,cc.p(0,7))
        )
    ))
    cardSp:runAction(action)

end