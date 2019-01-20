--
-- Author: huangguofang
-- Date: 2018-10-11 16:57:55
--

local iconIdMap = IconUtils.iconIdMap

local discountSingle= tab:Setting("G_DISCOUNT_FIRST_SINGLE_DRAW").value
local gemSingle     = tab:Setting("G_DRAWCOST_GEM_SINGLE").value[3]
local gemTen        = tab:Setting("G_DRAWCOST_GEM_TENTIMES").value[3]

local raceSingle = tab:RaceDrawConfig("cost_one").content
local raceTen = tab:RaceDrawConfig("cost_ten").content
local drawNumMax = tab:Setting("RACE_DRAWTIME").value

local DialogRaceFlashCardResult = class("DialogRaceFlashCardResult",BasePopView)
function DialogRaceFlashCardResult:ctor(data)
    self.super.ctor(self)
    self.callback = data.callback or nil
    self.buyNum = data.buyNum  
    self._costType = data.costType
    self._raceId = data.raceId
    self._playerDayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._isLuckyCoin = self._modelMgr:getModel("UserModel"):drawUseLuckyCoin()
    rightCostType = self._isLuckyCoin and "luckyCoin" or "gem"
    costImgName = self._isLuckyCoin and "globalImageUI_luckyCoin.png" or "globalImageUI_diamond.png"

    self._rightCostType = self._isLuckyCoin and "luckyCoin" or "gem"
    self._userModel = self._modelMgr:getModel("UserModel")
    self._raceDrawModel = self._modelMgr:getModel("RaceDrawModel")


end

function DialogRaceFlashCardResult:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogRaceFlashCardResult:onInit()
    -- self._scrollView = self:getUI("bg.scrollView")
    self._bg = self:getUI("bg")
    self._bg1 = self:getUI("bg.bg1")
    self._scrollView = self:getUI("bg.scrollView")
    self._bg1:setTouchEnabled(true)
    self._scrollView:setTouchEnabled(true)
    self._bg:setTouchEnabled(true)
    self._bg1:setSwallowTouches(false)
    self._scrollView:setSwallowTouches(false)

    -- self._scrollView:setClippingType(1)
    self.bgWidth,self.bgHeight = self._bg:getContentSize().width,self._bg:getContentSize().height
    self._okBtn = self:getUI("bg.closeBtn")
    self._closePanel = self:getUI("closePanel")
    self._closePanel:setSwallowTouches(false)

    -- 动画相关
    self._itemNames = {}
    self._touchLab = self:getUI("bg.touchLab")
    self._touchLab:setVisible(false)    

    self._bg1:setOpacity(0)
    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    local mcMgr = MovieClipManager:getInstance()
    -- mcMgr:loadRes("intancenopen", function ()
        
    audioMgr:playSound("ItemGain_1")
    -- end,RGBA8888)
    -- item 容器
    self._itemTable = {}
    -- -- 兵团转换的兵团背景光效
    self._showChange = true
    self._isChangeMc = {}

    -- 再来！！！！
    self._backBtn = self:getUI("bg.backBtn")
    self._onceAginBtn = self:getUI("bg.onceAginBtn")
    self._onceBtn = self:getUI("bg.onceAginBtn.onceAginBtn")
    self._timeLabel = self:getUI("bg.onceAginBtn.timeLabel")
    -- 再来十次panel
    self._tenAginBtn = self:getUI("bg.tenAginBtn")
    self._tenBtn = self:getUI("bg.tenAginBtn.tenAginBtn")
    -- self._tenBtn:setTitleText("再来" .. self.buyNum .. "次")

    self._onceAginBtn:setOpacity(0)
    self._onceAginBtn:setCascadeOpacityEnabled(true)
    self._tenAginBtn:setOpacity(0)
    self._tenAginBtn:setCascadeOpacityEnabled(true)
    self._backBtn:setOpacity(0)
    self._backBtn:setCascadeOpacityEnabled(true)

    self._hadClose = false
    self:registerClickEvent(self._backBtn, function()
        if  self._hadClose == false then
            self._hadClose = true
            if self.callback and type(self.callback) == "function" then
                print("==================resultCallback=================")
                self.callback(self._callbackAwards)
            end
            self:close(true)
            UIUtils:reloadLuaFile("flashcard.DialogRaceFlashCardResult")
        end
    end)
    self:registerClickEvent(self._onceBtn, function()
        -- self._onceAginBtn:setTouchEnabled(false)
        -- self._tenAginBtn:setTouchEnabled(false)
        self:buyOnceAginFunc()
        
    end)
    self:registerClickEvent(self._tenBtn, function()
        -- self._onceAginBtn:setTouchEnabled(false)
        -- self._tenAginBtn:setTouchEnabled(false)
        self:buyTenAginFunc()
    end)
    
    self._onceAginBtn:setVisible(false)
    self._onceAginBtn:setTouchEnabled(false)
    self._tenAginBtn:setVisible(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._backBtn:setVisible(false)
    self._backBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)
    self._onceBtn:setTouchEnabled(false)

    self._gbtnDraw = cc.DrawNode:create()
    self._onceAginBtn:addChild(self._gbtnDraw,999)

    --阵营抽卡 再来一次
    self:initOnceAginBtn()
    self:initTenAginBtn()

    self:listenReflash("UserModel", function( )
        if self.buyNum > 1 then 
            self:initTenAginBtn()
        else
            self:initOnceAginBtn()
        end
    end)

end
function DialogRaceFlashCardResult:animBegin(callback)
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height

    self._bgW,self._bgH = bgW,bgH
    self:addPopViewTitleAnim(self._bg, "gongxihuode_huodetitleanim", self._bg:getContentSize().width/2, 480)
    ScheduleMgr:delayCall(700, self, function( )
        if callback and self._bg then
            callback()
            self._bg1:runAction(cc.FadeIn:create(0.2))
            local children1 = self._bg1:getChildren()
            for k,v in pairs(children1) do
                if v:getName() ~= "touchLab" then
                    v:runAction(cc.FadeIn:create(0.2))
                end
            end
            if self.buyNum > 1 then
                local mcWupintexiao = mcMgr:createViewMC("wupintexiao_flashcardanim", true, false, function (_, sender)
                    -- sender:removeFromParent()
                end,RGBA8888)
                self._mcWupintexiao = mcWupintexiao
                -- mcWupintexiao:setPlaySpeed(0.8)
                mcWupintexiao:setPosition(cc.p(bgW/2,bgH/2+30))
                self._bg1:addChild(mcWupintexiao,99)
            end
        end
    end)
end
local expBottle = {
    [30201] = true,
    [30202] = true,
    [30203] = true,
}
-- 接收自定义消息
function DialogRaceFlashCardResult:reflashUI(data)
    local gifts = data.awards or data
    self._callbackAwards = gifts or self._callbackAwards
    -- dump(gifts)
    for k,v in pairs(gifts) do
        if v.type and ( v.type ~= "tool" or expBottle[v.typeId] ) then
            gifts[k] = nil
        end
    end
    self._gifts = gifts
    if gifts and #gifts == 0 then
        gifts = {}
        table.insert(gifts,data.awards or data)
    end

    local maxHeight = self._scrollView:getContentSize().height
    -- self._:removeAllChildren()
    local colMax = 5
    local itemHeight,itemWidth = 140,127
    local maxScrollHeight = itemHeight * math.ceil( #gifts / colMax) + 25
    if maxScrollHeight <= maxHeight then
        maxScrollHeight = maxHeight
    end
    self._scrollView:setInnerContainerSize(cc.size(1136,maxScrollHeight))

    local x = 0
    local y = itemHeight - 60

    -- print("gifts===",#gifts)
    local offsetX,offsetY = 0,0
    local row = math.ceil( #gifts / colMax)
    local col = #gifts
    if col > colMax then
        col = colMax
    end
    offsetX = (1136 - (col-1)*itemWidth)*0.5 -- (self.bgWidth-(col-1)*itemWidth)*0.5
    --    矫正 - (row - 2) * 15  2行 +15 2行不加
    offsetY = maxScrollHeight/2 + row*itemHeight/2 - itemHeight/2 + 30
    if row == 1 then
        offsetY = maxScrollHeight/2 + 30
    end

    x = x+offsetX-itemWidth
    y = y+offsetY-5

    -- 轮次添加物品特效
    local createItemDeque
    local xFactor = 1
    local createNextItemFunc = function( index,small )
        createItemDeque(index,small)
    end
    createItemDeque = function( index,small )
        local itemData = gifts[index]
        if not itemData then return end
        local itemId = itemData.typeId
        -- 如果是再次购买，不加动画，兵团转碎片不加展示卡片效果
        local callFunc = function()   end
        if not self._isAgain then
            callFunc = function( )                
                if itemData.isChange and self._showChange then
                    local mcSplash = mcMgr:createViewMC("shanguang_flashcardanim", true, false, function (_, sender)
                        sender:gotoAndPlay(80)
                    end)
                    mcSplash:setPosition(cc.p(self.bgWidth/2,self.bgHeight/2+30))
                    self._bg:addChild(mcSplash,2)

                    if itemData.isChange == 0 then
                        local teamId = tonumber(string.sub(tostring(itemId),2))
                        DialogUtils.showTeam({teamId = teamId,callback = function (  )
                            createNextItemFunc(index+1)
                        end})
                        
                    elseif itemData.isChange == 1 then
                        DialogUtils.showCard({itemId = itemId,changeNum = itemData.num,callback = function( )
                            createNextItemFunc(index+1)
                        end})
                    end
                else
                    audioMgr:playSound("ItemGain_2")
                    createNextItemFunc(index+1,0.8)
                end 
            end       
        end
        x = x + itemWidth
        if index % colMax == 1 then 
            x =  offsetX
            y = y - itemHeight
        end
        if not self._isAgain and index > 10 and index % colMax == 1 then -- 多一行就 滚屏
            local offsetY = -(maxScrollHeight - 5 - 2*itemHeight)+(math.ceil((index-10)/5))*itemHeight
            local container = self._scrollView:getInnerContainer()
            container:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(0,offsetY)),0.7),
                cc.CallFunc:create(function( )
                    self:createItem(itemData, x, y, index-1,callFunc,small)
                end)
            ))
        else
            self:createItem(itemData, x, y, index-1,callFunc,small)
        end
        if self._isAgain then
            createNextItemFunc(index+1,0.8)
        end
    end

    local bg1Height = 200
    local maxHeight = self._bg1:getContentSize().height + 12
    if not self._isAgain then
        self._bg1:setOpacity(0)
        self:animBegin(function( )
            self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,bg1Height))
            -- self._bg1:setAnchorPoint(0.5,1)
            -- self._bg1:setPositionY(MAX_SCREEN_HEIGHT-160)
            self._bg1:setOpacity(255)
            local sizeSchedule
            local step = 0.5
            local stepConst = 30
            -- self._bg:setPositionY(self._bg:getPositionY()+self._bg:)
            local sizeSchedule
            sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
                stepConst = stepConst-step
                if stepConst < 1 then 
                    stepConst = 1
                end
                bg1Height = bg1Height+stepConst
                if bg1Height < maxHeight then
                    self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,bg1Height))
                else
                    self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,maxHeight))
                    self._bg1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                    ScheduleMgr:unregSchedule(sizeSchedule)
                    self:addDecorateCorner()
                    
                end
            end)
            -- ScheduleMgr:delayCall(200, self, function( )
                -- showItems(1)
                createItemDeque(1,0.9)
            -- end)
        end)
    else
        createItemDeque(1,0.9)
    end
end

function DialogRaceFlashCardResult:createItem( data,x,y,index,callfunc,scale )
    -- if not data then return end
    -- dump(data)
    local itemData
    local itemType = data[1] or data.type
    local itemId = data[2] or data.typeId 
    local itemNum = data[3] or data.num
    if itemType ~= "tool" then
        itemId = iconIdMap[itemType]
    end

    local scaleOffset = 0
    if data.isChange == 0 then
        scale = 1
        scaleOffset = 6
    else
        scale = 0.9
    end
    -- if data.isItem then
    itemData = tab:Tool(itemId)
    if itemData == nil then
        itemData = tab:Team(itemId)
    end
    local item 
    -- print("============================isChange",data.isChange)
    if data.isChange == 0 then
        local teamId  = itemId-3000
        local teamD = tab:Team(teamId)
        itemData = teamD
        item = IconUtils:createSysTeamIconById({sysTeamData = teamD })
        local iconColor = item:getChildByName("iconColor")
        iconColor:loadTexture("globalImageUI_squality_jin.png",1)
        -- iconColor:setSpriteFrame("globalImageUI_squality_jin.png")
        -- iconColor:setContentSize(cc.size(107, 107))
    else
        item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,fromChouka=true,effect = false })
    end
    -- item:setContentSize(cc.size(80, 80))\
    item:setScaleAnim(false)
    item:setSwallowTouches(true)
    item:setAnchorPoint(cc.p(0.5,0.5))
    item:setPosition(cc.p(x,y+50+scaleOffset))
    item:setVisible(true)
    if itemData and itemData.name then
        local itemName = ccui.Text:create()
        itemName:setFontName(UIUtils.ttfName)
        itemName:setTextAreaSize(cc.size(100,65))
        itemName:setTextHorizontalAlignment(1)
        itemName:setTextVerticalAlignment(0)
        itemName:setFontSize(20)
        -- itemName:getVirtualRenderer():setLineHeight(20)
        itemName:setString(lang(tostring(itemData.name)))

        if data.isChange == 0 then
            itemName:setColor(cc.c3b(240, 240, 0))
        else
            itemName:setColor(UIUtils.colorTable["ccColorQuality" .. (itemData.color or 1)])
        end
        itemName:enableOutline(cc.c4b(0,0,0,255),1)
        itemName:setAnchorPoint(cc.p(0.5,1))
        itemName:setPosition(cc.p(x,y)) --cc.pAdd(cc.p(x,y),cc.p(item:getContentSize().width/2,-4)))
        self._scrollView:addChild(itemName,2)
        itemName:setVisible(false)
        table.insert(self._itemNames,itemName)
    end

    table.insert(self._itemTable,item)
    self._scrollView:addChild(item,2)

    item:setOpacity(0)
    local children = item:getChildren()
    for k,v in pairs(children) do
        if v:getName() == "numLab" then
            v:setVisible(false)
        else
            v:setOpacity(0)
        end
        if v.setSwallowTouches then
            v:setSwallowTouches(true)
        end
    end
    local bgMc = item:getChildByName("bgMc")
    if bgMc then
        bgMc:setVisible(false)
    end
    local delayT = 100
    if self._isAgain then 
        delayT = 0
    end
    ScheduleMgr:delayCall(delayT, self, function( )
        if not itemData or not data or not item then return end
        -- 加背景光效
        local bgMcName 
        if itemData.color == 5 then
            bgMcName = "chengguangquan_flashcardanim"
        elseif itemData.color == 4 then
            bgMcName = "ziguangquan_flashcardanim"
        end
        if bgMcName then
            local mc = mcMgr:createViewMC(bgMcName, false, true, function (_, sender)
                sender:removeFromParent()
            end)

            mc:setPosition(cc.p(x,y+50))
            mc:setPlaySpeed(0.5)
            self._scrollView:addChild(mc,9)
        end
        if data.isChange then    
            local mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
                sender:gotoAndPlay(0)
            end,RGBA8888) 
            mc:setPosition(x,y+50)      
            mc:setScale(1.1)
            self._scrollView:addChild(mc) 
            

            table.insert(self._isChangeMc,mc)
            if data.isChange == 0 then 
                local mc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection",
                                                  "tongyongdibansaoguang_itemeffectcollection",
                                                  "wupinkuangxingxing_itemeffectcollection"},iconColor)
                item:addChild(mc, 3)
            elseif data.isChange == 1 then -- 转化碎片也加扫光
                local mc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection"},item)
                item:addChild(mc, 20)
            end
                      
        end
        if bgMc then
            bgMc:setVisible(true)
        end
        if not self._isAgain then
            item:setScale(2)
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,(scale or 1)*0.9)),cc.ScaleTo:create(0.3,scale),cc.CallFunc:create(function( )
                item:setScaleAnim(true)
            end)))
        else
            item:setScale(scale)
            item:setScaleAnim(true)
            item:setOpacity(255)
        end
        -- ScheduleMgr:delayCall(400, self, function( )
        if callfunc then
            callfunc()
        end
        -- end)
        local children = item:getChildren()
        for k,v in pairs(children) do
                -- print("v:getName",v:getName() ~= "bgMc",v:getName())
            if v:getName() == "numLab" then
                v:setVisible(true)
            end
            if v:getName() ~= "bgMc" then
                v:runAction(cc.FadeIn:create(0.2))
            end
        end
        if index == #self._gifts-1 or #self._gifts == 1 then
            for k,v in pairs(self._itemNames) do
                v:setVisible(true)
            end
            ScheduleMgr:delayCall(800, self, function( )
                if tolua.isnull(self._tenAginBtn) or tolua.isnull(self._onceAginBtn) then return end
                -- print("----delayCall800800800800800--------------------------")
                -- 按钮出现
                if 1 < self.buyNum then
                    self._tenAginBtn:setVisible(true)
                    self._tenAginBtn:runAction(cc.FadeIn:create(0.1))
                else
                    self._onceAginBtn:setVisible(true)                    
                    self._onceAginBtn:runAction(cc.FadeIn:create(0.1))
                end  

                self._backBtn:setVisible(true)
                self._backBtn:runAction(cc.FadeIn:create(0.1))                       
            end)
            ScheduleMgr:delayCall(1000, self, function( )
                if tolua.isnull(self._tenAginBtn) or tolua.isnull(self._onceAginBtn) then return end
               
                -- 按钮可点击
                if 1 < self.buyNum then
                    self._tenBtn:setTouchEnabled(true)
                    self._tenAginBtn:setTouchEnabled(true)
                    self._backBtn:setTouchEnabled(true)

                else
                    -- self._onceAginBtn:setTouchEnabled(true)
                    self._onceBtn:setTouchEnabled(true)
                    self._onceAginBtn:setTouchEnabled(true)
                    self._backBtn:setTouchEnabled(true)
                end             
            end)
            if not tolua.isnull(self._mcWupintexiao) then
                self._mcWupintexiao:removeFromParent()
            end
        end
    end)
end

-- 再来一 & 十次
function DialogRaceFlashCardResult:initOnceAginBtn()    
    self._onceCostImg = self:getUI("bg.onceAginBtn.costImg")
    self._costValue = self:getUI("bg.onceAginBtn.costValue")
    self._onceCostImg:setScale(0.64)
    self._onceCostImg:loadTexture(costImgName,1)
    local disCountLab = self._onceAginBtn:getChildByFullName("gemDiscountLab")
    if disCountLab then
        disCountLab:removeFromParent()
        disCountLab = nil
    end

    self._costValue:setColor(cc.c4b(255,255,255,255))

    local stateNum = self._raceDrawModel:getStateNum(self._raceId) or 1
    local isFree = stateNum == 0
    local isHalf = stateNum == 0.5

    local cost = raceSingle
    local disCount = raceSingle*stateNum

    -- local boardOffsetX = self._gBoardW/2
    local raceDiscountLab = self._costValue:getChildByFullName("raceDiscountLab")
    if raceDiscountLab then
        raceDiscountLab:setVisible(false)
    else
        raceDiscountLab = ccui.Text:create()
        raceDiscountLab:setFontName(UIUtils.ttfName)
        raceDiscountLab:setName("raceDiscountLab")
        raceDiscountLab:setFontSize(self._costValue:getFontSize())
        self._costValue:addChild(raceDiscountLab)
    end
    if not self._rbtnDraw then 
        local drawNode = cc.DrawNode:create()
        self._rbtnDraw = drawNode
        self._onceAginBtn:addChild(drawNode,99)
    end
    if self._rbtnDraw then
        self._rbtnDraw:clear()
    end

    local gemHaveNum = self._userModel:getData()[self._rightCostType] or 0
    if isFree then
        cost = "本次免费"
        self._costValue:setColor(cc.c4b(0,255,30,255))
        self._timeLabel:setString("")
    else
        self._costValue:setColor(cc.c4b(255,255,255,255))
        self._costValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        if isHalf then
            -- boardOffsetX = boardOffsetX-(lw-dw)/2
            -- 固定字儿设固定改位置
            self._timeLabel:setString("")
        else            
            self._timeLabel:setString("次日5点半价")
            -- boardOffsetX = self._gBoardW/2+(lw-dw)/2
        end
    end 
    -- print("============cost=====",cost)
    self._costValue:setString(cost)
   
    if isHalf then
        local costW,costH = self._costValue:getContentSize().width,self._costValue:getContentSize().height
        local costX,costY = self._costValue:getPositionX(),self._costValue:getPositionY()
        self._rbtnDraw:drawSegment(cc.p(costX,costY),cc.p(costX+costW,costY),1,cc.c4f(1.0, 0.0, 0.0, 1.0))
        raceDiscountLab:setPosition(cc.p(costW*1.5,costH/2))
        raceDiscountLab:setVisible(true)
        self._costValue:setColor(cc.c4b(255,255,255,255))
        raceDiscountLab:setString(disCount)
        self:textColorRed(raceDiscountLab,gemHaveNum < disCount and not isFree,cc.c4b(0, 255, 0, 255))
    else
        self:textColorRed(self._costValue,gemHaveNum < disCount and not isFree)
    end 

end
function DialogRaceFlashCardResult:initTenAginBtn()
    self._tenCostImg = self:getUI("bg.tenAginBtn.costImg")
    self._costValue = self:getUI("bg.tenAginBtn.costValue")

    self._tenCostImg:setScale(0.64)
    self._tenCostImg:loadTexture(costImgName,1)
    local gemHaveNum = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0

    if gemHaveNum < raceTen then
        self._costValue:setColor(cc.c4b(255, 23, 23, 255))
    else
        self._costValue:setColor(cc.c4b(0, 255, 0, 255))
    end
    self._costValue:setString(raceTen)
end

function DialogRaceFlashCardResult:buyOnceAginFunc( )
    -- body
    -- print("===========购买一次==================")
    if self._gbtnDraw then
        self._gbtnDraw:clear()
    end
    local gemDiscountLab = self._onceAginBtn:getChildByFullName("gemDiscountLab") 
    if gemDiscountLab then
        gemDiscountLab:removeFromParent()
    end
    local cost = gemSingle
    local num = self._modelMgr:getModel("PlayerTodayModel"):getData().day1
    self._isGemFree = false
    if self._isGemFree then
        cost = 0
    elseif num < 1 then
        cost = cost*discountSingle
    end
    -- self._buyNum = 1
    self:buyItemByGem(cost,1)

end

function DialogRaceFlashCardResult:buyTenAginFunc()
    -- 再来十次    
    self:buyItemByGem(raceTen,10)
end

function DialogRaceFlashCardResult:buyItemByGem(cost,drawNum)

    local player = self._modelMgr:getModel("UserModel"):getData()
    local gem = player[self._rightCostType] or 0

    self._raceDrawData = self._raceDrawModel:getData() or {}
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
        self._backBtn:setTouchEnabled(true)
        self._onceAginBtn:setTouchEnabled(true)
        self._tenAginBtn:setTouchEnabled(true)
        self._tenBtn:setTouchEnabled(true)
        self._onceBtn:setTouchEnabled(true)
        self:showNeedCharge(disCount-gem)
        return 
    end

    self._backBtn:setTouchEnabled(false)
    self._onceAginBtn:setTouchEnabled(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)
    self._onceBtn:setTouchEnabled(false)
    
    self._backBtn:runAction(cc.FadeOut:create(0.1))
    self._tenAginBtn:runAction(cc.FadeOut:create(0.1))
    self._onceAginBtn:runAction(cc.FadeOut:create(0.1))
    self._serverMgr:sendMsg("RaceDrawServer", "drawCard", {raceId = self._raceId, num = drawNum}, true, {}, function(result,error) 
        
        audioMgr:playSound("Draw")
        for k,v in pairs(self._itemTable) do
            v:removeFromParent()
        end
        for k,v in pairs(self._itemNames) do
            v:removeFromParent()
        end
        for k,v in pairs(self._isChangeMc) do
            v:removeFromParent()
        end
        self._itemTable = {}
        self._itemNames = {}
        self._isChangeMc = {}
        ScheduleMgr:delayCall(800, self, function( )
            -- print("======================展示再次购买的icon=========")
            self:showItemAgin(result)
            self:initOnceAginBtn()
            self:initTenAginBtn()
        end)
    end,
    function( )   
        if tolua.isnull(self._tenAginBtn) or tolua.isnull(self._onceAginBtn) then return end
        -- 按钮出现
        if 1 < self.buyNum then
            self._tenBtn:setTouchEnabled(true)
            self._tenBtn:setVisible(true)
            self._tenAginBtn:setVisible(true)
            self._tenAginBtn:setTouchEnabled(true)
            self._tenAginBtn:runAction(cc.FadeIn:create(0.1))
        else
            self._onceBtn:setTouchEnabled(true)
            self._onceBtn:setVisible(true)
            self._onceAginBtn:setTouchEnabled(true)
            self._onceAginBtn:setVisible(true)                    
            self._onceAginBtn:runAction(cc.FadeIn:create(0.1))
        end  
        self._backBtn:setVisible(true)
        self._backBtn:setTouchEnabled(true)
        self._backBtn:runAction(cc.FadeIn:create(0.1)) 
    end)
end

function DialogRaceFlashCardResult:showItemAgin(data)
    dump(data,"data==>",5)
    self._isAgain = true
    self:reflashUI(data)
end

function DialogRaceFlashCardResult:textColorRed( node,red,color )
    if red then
        node:setColor(cc.c4b(255, 23, 23, 255))
    else
        node:setColor(color or node:getColor())
    end
end

-- 根据类型跳转
function DialogRaceFlashCardResult:showNeedCharge( needNum )
    if self._isLuckyCoin then
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = needNum })
        end})
    else
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
    end
end
return DialogRaceFlashCardResult