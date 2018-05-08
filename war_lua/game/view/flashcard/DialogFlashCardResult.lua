--[[
    Filename:    DialogFlashCardResult.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-07-30 14:39:47
    Description: File description
--]]
local isLuckyCoin = false
local rightCostType = isLuckyCoin and "luckyCoin" or "gem"
local costImgName = isLuckyCoin and "globalImageUI_luckyCoin.png" or "globalImageUI_diamond.png"
local iconIdMap = IconUtils.iconIdMap

local discountSingle= tab:Setting("G_DISCOUNT_FIRST_SINGLE_DRAW").value
local discountTen   = tab:Setting("G_DISCOUNT_TENTIMES_DRAW").value

local toolSingle    = tab:Setting("G_DRAWCOST_TOOL_SINGLE").value[3]
local toolTen       = tab:Setting("G_DRAWCOST_TOOL_TENTIMES").value[3]
local gemSingle     = tab:Setting("G_DRAWCOST_GEM_SINGLE").value[3]
local gemTen        = tab:Setting("G_DRAWCOST_GEM_TENTIMES").value[3]
local gemFreeCD     = tab:Setting("G_FREECD_DRAW_GEM_SINGLE").value -- 转换成秒数
local toolFreeCD    = tab:Setting("G_FREECD_DRAW_TOOL_SINGLE").value -- 转换成秒数
local toolFreeNum   = tab:Setting("G_FREENUM_DRAW_TOOL_SINGLE").value

local DialogFlashCardResult = class("DialogFlashCardResult",BasePopView)
function DialogFlashCardResult:ctor(data)
    self.super.ctor(self)
    self.callback = data.callback or nil
    self._showType = data.showType or nil
    self._genNum10 = data.costNum or 2700   --十连消耗数量
    self.viewType = data.viewType
    self.canGet = data.canGet  
    self.buyNum = data.buyNum  
    self._costType = data.costType
    self._playerDayModel = self._modelMgr:getModel("PlayerTodayModel")
    isLuckyCoin = self._modelMgr:getModel("UserModel"):drawUseLuckyCoin()
    rightCostType = isLuckyCoin and "luckyCoin" or "gem"
    costImgName = isLuckyCoin and "globalImageUI_luckyCoin.png" or "globalImageUI_diamond.png"
end

function DialogFlashCardResult:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogFlashCardResult:onInit()
    -- self._scrollView = self:getUI("bg.scrollView")
    self._bg = self:getUI("bg")
    self._bg1 = self:getUI("bg.bg1")
    -- self._scrollView:setClippingType(1)
    self.bgWidth,self.bgHeight = self._bg:getContentSize().width,self._bg:getContentSize().height
    self._okBtn = self:getUI("bg.closeBtn")
    self._closePanel = self:getUI("closePanel")
    self._closePanel:setSwallowTouches(false)

    -- 动画相关
    self._itemNames = {}
    self._touchLab = self:getUI("bg.touchLab")
    self._touchLab:setOpacity(0)

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
    self._isChangeMc = {}

    -- 再来！！！！
    self._backBtn = self:getUI("bg.backBtn")
    self._onceAginBtn = self:getUI("bg.onceAginBtn")
    -- 再来十次panel
    self._tenAginBtn = self:getUI("bg.tenAginBtn")
    self._tenBtn = self:getUI("bg.tenAginBtn.tenAginBtn")

    -- self._timeLabel = self:getUI("bg.onceAginBtn.timeLabel")
    --更新倒计时
    -- self:reflashTimeLabel()
    -- self:refreshTime()


    -- self._onceAginBtn:setOpacity(0)
    -- self._onceAginBtn:setCascadeOpacityEnabled(true)
    self._tenAginBtn:setOpacity(0)
    self._tenAginBtn:setCascadeOpacityEnabled(true)
    self._backBtn:setOpacity(0)
    self._backBtn:setCascadeOpacityEnabled(true)

    self._hadClose = false
    self:registerClickEvent(self._backBtn, function()
        if  self._hadClose == false then
            self._hadClose = true
            if self.callback and type(self.callback) == "function" then
                self.callback(self._callbackAwards)
            end
            self:close(true)
            UIUtils:reloadLuaFile("flashcard.DialogFlashCardResult")
        end
    end)
    --[[
    self:registerClickEvent(self._onceAginBtn, function()
        -- self._onceAginBtn:setTouchEnabled(false)
        -- self._tenAginBtn:setTouchEnabled(false)
        self:buyOnceAginFunc()
        
    end)
    --]]
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

    self._gbtnDraw = cc.DrawNode:create()
    self._onceAginBtn:addChild(self._gbtnDraw,999)

    --注释再来一次功能  hgf - 16.09.07
    -- self:initOnceAginBtn()
    self:initTenAginBtn()

end
function DialogFlashCardResult:animBegin(callback)
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
            if self.buyNum == 10 then
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
function DialogFlashCardResult:reflashUI(data)
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
    local blank = 25
    local colNum = 5
    local itemHeight,itemWidth = 110,96
    
    local maxHeight = (itemHeight+blank) * math.ceil( #gifts / colNum)
    local x = 3
    local y = 0--maxHeight - itemHeight

    local offsetX,offsetY = 0,0
    if #gifts <= colNum then
        offsetX = (self.bgWidth-#gifts*(itemWidth+blank))/2+itemWidth/2-10
        offsetY = self.bgHeight/2-30 -- itemHeight/2+30
        -- offsetY = self.bgHeight/2 - maxHeight/2 + itemHeight/2
    else
        offsetX = (self.bgWidth-colNum*(itemWidth+blank))/2+itemWidth/2
        -- offsetY = self.bgHeight/2-itemHeight+30
        offsetY = self.bgHeight/2 + maxHeight/2 -  itemHeight + 15
    end
    x = offsetX+20
    y = y+offsetY+3--itemHeight/2
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
                if itemData.isChange then
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
        self:createItem(itemData, x, y, index-1,callFunc,small)
         x = x + xFactor*(itemWidth + blank)
        if index % colNum == 0 then 
            x =  offsetX+20
            -- x = x - xFactor*(itemWidth + blank)
            -- xFactor = -1
            y = y - blank - itemHeight - 24 --name高度
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

function DialogFlashCardResult:createItem( data,x,y,index,callfunc,scale )
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
        self._bg:addChild(itemName,2)
        itemName:setVisible(false)
        table.insert(self._itemNames,itemName)
    end

    table.insert(self._itemTable,item)
    self._bg:addChild(item,2)

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
    
    ScheduleMgr:delayCall(100, self, function( )
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
                -- sender:gotoAndPlay(0)
            end)

            mc:setPosition(cc.p(x,y+50))
            mc:setPlaySpeed(0.5)
            -- mc:setScale(0.8)
            -- mc:setName("bgMc")
            self._bg:addChild(mc,9)
        end
        if data.isChange then    
            -- local sp = cc.Sprite:createWithSpriteFrameName("light_flashcard.png")
            -- local action = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360.0))
            -- sp:setPosition()
            -- sp:setScale(1.2)
            -- sp:setName("bgMc")
            -- sp:runAction(action)
            local mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
                sender:gotoAndPlay(0)
            end,RGBA8888) 
            mc:setPosition(x,y+50)      
            mc:setScale(1.1)
            self._bg:addChild(mc) 
            

            table.insert(self._isChangeMc,mc)
            if data.isChange == 0 then 
                local mc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection",
                                                  "tongyongdibansaoguang_itemeffectcollection",
                                                  "wupinkuangxingxing_itemeffectcollection"},iconColor)
                -- mc:setPosition(-5 ,  - 6) -- effectParent
                -- mc:setScale(1.1, 1.1)
                item:addChild(mc, 3)
            elseif data.isChange == 1 then -- 转化碎片也加扫光
                local mc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection"},item)
                -- mc:setPosition(item:getContentSize().width * 0.5 , item:getContentSize().height * 0.5 - 2)
                -- mc:setScale(1.16, 1.15)
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
                if tolua.isnull(self._touchLab) or tolua.isnull(self._tenAginBtn) then return end
                -- print("----delayCall800800800800800--------------------------")
                -- 按钮出现
                if 10 == self.buyNum then
                    self._tenAginBtn:setVisible(true)
                    self._tenAginBtn:runAction(cc.FadeIn:create(0.1)) 

                    self._backBtn:setVisible(true)
                    self._backBtn:runAction(cc.FadeIn:create(0.1))                     
                else
                    self._touchLab:setVisible(true) 
                    self._touchLab:runAction(cc.FadeIn:create(0.2))
                    -- self._onceAginBtn:setVisible(true)                    
                    -- self._onceAginBtn:runAction(cc.FadeIn:create(0.1))                   
                end                         
            end)
            ScheduleMgr:delayCall(1000, self, function( )
                if tolua.isnull(self._touchLab) or tolua.isnull(self._tenAginBtn) then return end
               
                -- 按钮可点击
                if 10 == self.buyNum then
                    self._tenBtn:setTouchEnabled(true)
                    self._tenAginBtn:setTouchEnabled(true)
                    self._backBtn:setTouchEnabled(true)
                else
                    -- self._onceAginBtn:setTouchEnabled(true)
                    self:registerClickEventByName("closePanel", function()                       
                        if  self._hadClose == false then
                            self._hadClose = true
                            if self.callback and type(self.callback) == "function" then
                                self.callback()
                            end
                            self:close(true)
                            UIUtils:reloadLuaFile("flashcard.DialogFlashCardResult")
                        end
                    end)

                    self:registerClickEventByName("bg.bg1", function()
                        if self._hadClose == false then
                            self._hadClose = true
                            if self.callback and type(self.callback) == "function" then
                                self.callback()
                            end
                            self:close(true)
                            UIUtils:reloadLuaFile("flashcard.DialogFlashCardResult")
                        end
                    end)

                    self:registerClickEventByName("bg", function()
                        if self._hadClose == false then
                            self._hadClose = true
                            if self.callback and type(self.callback) == "function" then
                                self.callback()
                            end
                            self:close(true)
                            UIUtils:reloadLuaFile("flashcard.DialogFlashCardResult")
                        end
                    end)
                end             
            end)
            if not tolua.isnull(self._mcWupintexiao) then
                self._mcWupintexiao:removeFromParent()
            end
        end
    end)

end


-- 再来一 & 十次
--[[
function DialogFlashCardResult:initOnceAginBtn()    

    self._costImg = self:getUI("bg.onceAginBtn.costImg")
    self._costValue = self:getUI("bg.onceAginBtn.costValue")

    local disCountLab = self._onceAginBtn:getChildByFullName("gemDiscountLab")
    if disCountLab then
        disCountLab:removeFromParent()
        disCountLab = nil
    end

    self._costValue:setColor(cc.c4b(255,255,255,255))
    if "gem" == self._costType then
        --   免费购买次数 价钱 半折 折扣(几折)
        local isFree,cost,disCount,disCountNum = self:isGemFree()
        self._isGemFree = isFree
        if isFree then
            self._costImg:loadTexture(IconUtils.resImgMap["privilege"],1)
            self._costImg:setScale(0.75)
            self._costValue:setColor(cc.c4b(0,255,30,255))
            --时间label 不可见
            self._timeLabel:setString("")
        else
            self._costImg:loadTexture("globalImageUI_littleDiamond.png",1)
            self._costImg:setScale(1)
            self._costValue:setColor(cc.c4b(255,255,255,255))
            self._costValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

            -- 如果是打折，没有倒计时
            if disCount then
                  self._timeLabel:setString("")               
            else            
                self._timeLabel:setString((self._gTime or "00:00:00") .. "后免费")            
            end
        end

        self._costValue:setString(cost)
        -- 如果是打折，原价加绿色横线
        if disCount then
            self._costValue:setString(gemSingle)
        end

        if self._gbtnDraw then
            self._gbtnDraw:clear()
        end

        local gemHaveNum = self._modelMgr:getModel("UserModel"):getData().gem
        if disCountNum < 1 then
            --折后价
            local gemDiscountLab = ccui.Text:create()
            gemDiscountLab:setFontName(UIUtils.ttfName)
            gemDiscountLab:setName("gemDiscountLab")
            gemDiscountLab:setFontSize(self._costValue:getFontSize())
            self._onceAginBtn:addChild(gemDiscountLab)

            local costW,costH = self._costValue:getContentSize().width,self._costValue:getContentSize().height
            local costX,costY = self._costValue:getPositionX(),self._costValue:getPositionY()
            --画线段
            self._gbtnDraw:drawSegment(cc.p(costX,costY),cc.p(costX+costW,costY),1,cc.c4f(1.0, 0.0, 0.0, 1.0))
            gemDiscountLab:setPosition(cc.p(costX + costW*1.5,costY))
            gemDiscountLab:setVisible(true)
            self._costValue:setColor(cc.c4b(255,255,255,255))
            gemDiscountLab:setString(cost)
            if (gemHaveNum < gemSingle*disCountNum) and not isFree then
                gemDiscountLab:setColor(cc.c4b(255, 23, 23, 255))
            else
                gemDiscountLab:setColor(cc.c4b(0, 255, 0, 255))
            end
          
        else
            if (gemHaveNum < gemSingle*disCountNum) and not isFree then
                 self._costValue:setColor(cc.c4b(255, 23, 23, 255))
            end
        end 
     
    else
        -- 免费购买 价格  可免费次数 已免费次数购买
        local isFree,cost,tFreeNum,toolNum  = self:isToolFree()
        self._isToolFree = isFree
        -- print(self._tTime,"============initOnceAginBtn=isFree=toolNum=tFreeNum===",isFree,toolNum,tFreeNum)
        if isFree then
            self._costImg:loadTexture(IconUtils.resImgMap["privilege"],1)
            self._costImg:setScale(0.75)
            -- self._costImg:setAnchorPoint(cc.p(1,0.5))
            self._costValue:setColor(cc.c4b(0,255,30,255))
            --时间label 不可见
            self._timeLabel:setString("")
        else
            self._costImg:loadTexture("globalImageUI5_choukadaoju.png",1)
            self._costImg:setScale(0.75)
            self._costValue:setColor(cc.c4b(255,255,255,255))
           
            if toolNum < tFreeNum then                
                self._timeLabel:setColor(cc.c4b(255,255,255,255))
                self._timeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
                self._timeLabel:setString((self._tTime or "00:00:00") .. "后免费")
            else
                --时间label 不可见
                self._timeLabel:setString("")
            end
        end

        local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(3001)
        if toolHaveNum < toolSingle and not self._isToolFree then
            self._costValue:setColor(cc.c4b(255, 23, 23, 255))
        end

        if isFree then
            self._costValue:setString(cost)
        else
            self._costValue:setString(toolHaveNum .. "/" .. cost)
        end
    end
end
--]]
function DialogFlashCardResult:initTenAginBtn()
    self._costImg = self:getUI("bg.tenAginBtn.costImg")
    self._costValue = self:getUI("bg.tenAginBtn.costValue")

    self._costImg:setScale(0.64)
    if rightCostType == self._costType then   
         -- 限时兵团十连
        if self._showType and self._showType == "limitTeam" then
            self._costImg:loadTexture(costImgName,1)
            local num = self._genNum10 or -1
            local gem = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0
            self._costValue:setString(num)
            if gem < num then
                self._costValue:setColor(cc.c4b(255, 23, 23, 255))
            else
                self._costValue:setColor(cc.c4b(0, 255, 0, 255))
            end
        else
            --
            -- 玩家拥有的金钥匙道具  hgf
            local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(3041)
            if toolHaveNum < 10 then
                self._costImg:loadTexture(costImgName,1)
                local gemHaveNum = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0
                if gemHaveNum < math.ceil(gemTen*discountTen) then
                    self._costValue:setColor(cc.c4b(255, 23, 23, 255))
                else
                    self._costValue:setColor(cc.c4b(0, 255, 0, 255))
                end
                self._costValue:setString(math.ceil(gemTen*discountTen))
            else
                self._costImg:loadTexture("flashcard_choukaGoldKey.png",1)
                self._costValue:setString(toolHaveNum .. "/10")
            end
        end
    else
        self._costImg:loadTexture("flashcard_choukaSilverKey.png",1)
        local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(3001)
        if toolHaveNum < toolTen then

            self._costValue:setColor(cc.c4b(255, 23, 23, 255))
        else
            self._costValue:setColor(cc.c4b(255, 255, 255, 255))
        end
        self._costValue:setString(toolHaveNum .. "/" .. toolTen)
    end
end
--[[
function DialogFlashCardResult:buyOnceAginFunc( ... )
    -- body
    -- print("===========购买一次==================")
    if self._gbtnDraw then
        self._gbtnDraw:clear()
    end
    local gemDiscountLab = self._onceAginBtn:getChildByFullName("gemDiscountLab") 
    if gemDiscountLab then
        gemDiscountLab:removeFromParent()
    end
    if "gem" == self._costType then
        local cost = gemSingle
        local num = self._modelMgr:getModel("PlayerTodayModel"):getData().day1
        self._isGemFree = self:isGemFree()
        if self._isGemFree then
            cost = 0
        elseif num < 1 then
            cost = cost*discountSingle
        end
        -- self._buyNum = 1
        self:buyItemByGem(cost,1)
    else        
        local cost = toolSingle
        self._isToolFree = self:isToolFree()
        if self._isToolFree then
            cost = 0
        end
        self:buyItemByTool(cost,1)
    end

end
--]]
function DialogFlashCardResult:buyTenAginFunc( ... )
    -- body
    -- print("===========购买十次==================")

    if rightCostType == self._costType then
        -- 再来十次回调 限时兵团用
        if self._showType and self._showType == "limitTeam" then
            self:buyItemByOther(self._genNum10,10)
        else
            local cost = gemTen*discountTen
            -- self._buyNum = 10
            self:buyItemByGem(cost,10)
        end
    else
        local cost = toolTen        
        self:buyItemByTool(cost,10)
    end
end

function DialogFlashCardResult:buyItemByTool(cost,num)
    -- body
    local ToolSingle = tab:Setting("G_DRAWCOST_TOOL_SINGLE")
    local toolId = tonumber(ToolSingle["value"][2])
    local item = self._modelMgr:getModel("ItemModel")
    local idata,icount = item:getItemsById(toolId)

    self._backBtn:setTouchEnabled(false)
    self._onceAginBtn:setTouchEnabled(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)

    if icount >= cost or (cost == 1 and self._isToolFree) then
        -- print("======================展示再次购买的icon=========")

        self._backBtn:runAction(cc.FadeOut:create(0.1))
        self._tenAginBtn:runAction(cc.FadeOut:create(0.1))
        self._onceAginBtn:runAction(cc.FadeOut:create(0.1))

        self._serverMgr:sendMsg("TeamServer", "drawAward", {typeId = 1, num = num}, true, {}, function(result) 
            audioMgr:playSound("Draw")
            -- self:lock()

            --清楚之前的item显示
            for k,v in pairs(self._itemTable) do
                v:removeFromParent()
                -- v = nil
            end
            for k,v in pairs(self._itemNames) do
                v:removeFromParent()
                -- v = nil
            end
            -- local bgMc = self._bg:getChildByFullName("bgMc")
            -- bgMc:setVisible(false)
            -- bgMc:removeFromParent()
            for k,v in pairs(self._isChangeMc) do
                -- print("====================self._isChangeMc======")
                v:removeFromParent()
                -- v = nil
            end
            self._itemTable = {}
            self._itemNames = {}
            self._isChangeMc = {}

            ScheduleMgr:delayCall(800, self, function( )
                -- self:unlock()
                -- 展示再次购买的icon
                -- function
                -- print("======================展示再次购买的icon=========")
                self:showItemAgin(result)
                -- self:initOnceAginBtn()
                self:initTenAginBtn()
            end)
        end)
        -- ScheduleMgr:delayCall(10000, self, function( )
        --     if self and self._backBtn then
        --         self._backBtn:setTouchEnabled(true)
        --         self._onceAginBtn:setTouchEnabled(true)
        --         self._tenAginBtn:setTouchEnabled(true)

        --     end
        -- end)
    else
        self._viewMgr:showTip("道具不足!")
        self._backBtn:setTouchEnabled(true)
        self._onceAginBtn:setTouchEnabled(true)
        self._tenAginBtn:setTouchEnabled(true)
        self._tenBtn:setTouchEnabled(true)
    end
end

function DialogFlashCardResult:buyItemByGem(cost,num)

    local playerData = self._modelMgr:getModel("UserModel"):getData()
    local gem = playerData[rightCostType]

    local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(3041)

    self._backBtn:setTouchEnabled(false)
    self._onceAginBtn:setTouchEnabled(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)
    local conditions = false   
    -- local disCountNum ,free = self:isGemFree()  --半价,免费免费
    if num == 11 then
    --     conditions = ((haveKeyNum > 0 and not disCountNum) or gem >= price or (price == gemSingle and free))
    -- else
        conditions = (toolHaveNum >= 10 or gem >= cost) 
    end
    if (toolHaveNum >= 10) or gem >= cost or (cost == gemSingle and self:isGemFree()) then       
        self._backBtn:runAction(cc.FadeOut:create(0.1))
        self._tenAginBtn:runAction(cc.FadeOut:create(0.1))
        self._onceAginBtn:runAction(cc.FadeOut:create(0.1))
        self._serverMgr:sendMsg("TeamServer", "drawAward", {typeId = 2, num = num}, true, {}, function(result) 
            audioMgr:playSound("Draw")
            
            for k,v in pairs(self._itemTable) do
                v:removeFromParent()
                -- v = nil
            end
            for k,v in pairs(self._itemNames) do
                v:removeFromParent()
                -- v = nil
            end
            for k,v in pairs(self._isChangeMc) do
                -- print("====================self._isChangeMc======")
                v:removeFromParent()
                -- v = nil
            end
            self._itemTable = {}
            self._itemNames = {}
            self._isChangeMc = {}
            ScheduleMgr:delayCall(800, self, function( )
                -- self:unlock()
                -- 展示再次购买的icon
                -- function
                -- print("======================展示再次购买的icon=========")
                self:showItemAgin(result)
                -- self:initOnceAginBtn()
                self:initTenAginBtn()
            end)

        end)
        -- ScheduleMgr:delayCall(10000, self, function( )
        --     if self and self._backBtn then
        --         self._backBtn:setTouchEnabled(true)
        --         self._onceAginBtn:setTouchEnabled(true)
        --         self._tenAginBtn:setTouchEnabled(true)
        --     end
        -- end)
    else
        -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
        --     local viewMgr = ViewManager:getInstance()
        --     viewMgr:showView("vip.VipView", {viewType = 0})
        -- end})


        -- local des = isLuckyCoin and "幸运币不足!" or "钻石不足！"
        -- self._viewMgr:showTip(des)
        local needNum = cost - gem
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = needNum,callback = function()
                self:initTenAginBtn()
            end })
        end})
        self._backBtn:setTouchEnabled(true)
        self._onceAginBtn:setTouchEnabled(true)
        self._tenAginBtn:setTouchEnabled(true)
        self._tenBtn:setTouchEnabled(true)
    end
end

--限时兵团十连抽
function DialogFlashCardResult:buyItemByOther(cost,num)
   local sysTLConfig = tab.limitTeamConfig
    local curGem = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0
    if curGem < sysTLConfig["cost10"]["num"] then
        self._viewMgr:showTip("钻石不足")
        self._backBtn:setTouchEnabled(true)
        self._onceAginBtn:setTouchEnabled(true)
        self._tenAginBtn:setTouchEnabled(true)
        self._tenBtn:setTouchEnabled(true) 
    else
        self._backBtn:runAction(cc.FadeOut:create(0.1))
        self._tenAginBtn:runAction(cc.FadeOut:create(0.1))
        self._serverMgr:sendMsg("LimitTeamsServer", "limitTeamLottery", {num = 10}, true, {}, function(result, errorCode)
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
                self._isAgain = true
                self:reflashUI(result.reward)
                self:initTenAginBtn()
            end)
        end)
    end
end

--[[
-- 更新倒计时
function DialogFlashCardResult:reflashTimeLabel()
    self._isToolFree = self:isToolFree()
    self._isGemFree = self:isGemFree()

    if self._isToolFree and self._isGemFree then
        if self._updateTime then
            ScheduleMgr:unregSchedule(self._updateTime)
        end
        -- print("====================reflashTimeLabel========================")
        self:initOnceAginBtn()
        self._updateTime = nil
    else
        if not self._updateTime then
            self._updateTime = ScheduleMgr:regSchedule(1000,self,function()
                self:refreshTime()
            end)
        end
    end
end
--]]

--[[
--! @function refreshTime
--! @desc 倒计时刷新时间
--! @param 
--! @return 
--]]
--[[
function DialogFlashCardResult:refreshTime()
    if "tool" == self._costType then
        if not self._isToolFree and self._modelMgr:getModel("PlayerTodayModel"):getDrawAward() then
            local lastToolTime = self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().drawToolLastTime or 0
            if (self._modelMgr:getModel("UserModel"):getCurServerTime() >= lastToolTime)  then
                self._tTime = "00:00:00"
                print("==============self._tTime = 00:00:00== refreshTime=====================")
                self:reflashTimeLabel()
            else 
                local toolNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day7 or 0
                if toolNum < toolFreeNum then
                    local timeInt = lastToolTime - self._modelMgr:getModel("UserModel"):getCurServerTime()
                    local timeStr = string.format("%02d:%02d:%02d",math.floor(timeInt/3600),math.floor(timeInt/60)%60,timeInt%60).. ""
                    self._tTime = timeStr                
                    self._timeLabel:setString(timeStr .. "后免费")
                end
            end
        end
    elseif "gem" == self._costType then       
        if not self._isGemFree and self._modelMgr:getModel("PlayerTodayModel"):getDrawAward() then
            local lastTeamTime = self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().drawTeamLastTime-self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_9)
            if self._modelMgr:getModel("UserModel"):getCurServerTime() >= lastTeamTime then
                self._gTimeLab:setString("00:00:00")
                self:reflashTimeLabel()
            else
                local teamNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day1
                local havePrivilege = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.ZuanShiChouKa)
                if not (havePrivilege ~= 0 and teamNum ==0) then               
                    local timeInt = lastTeamTime - self._modelMgr:getModel("UserModel"):getCurServerTime()
                    local timeStr = string.format("%02d:%02d:%02d",math.floor(timeInt/3600),math.floor(timeInt/60)%60,timeInt%60).. ""
                    --os.date("%H:%M:%S",lastTeamTime-self._modelMgr:getModel("UserModel"):getCurServerTime()) .. "后免费"
                    self._gTime = timeStr
                    self._timeLabel:setString(timeStr .. "后免费")
                end
            end
        end
    end
end

function DialogFlashCardResult:isToolFree( )
    local isFree = false
    local toolLastTime = self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().drawToolLastTime or 0
    local toolNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day7 or 0
    local cost = toolSingle
    -- self._tOneCost:setColor(cc.c4b(255,255,255,255))
    toolFreeNum = tab:Setting("G_FREENUM_DRAW_TOOL_SINGLE").value+self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_8)
    local quanImg = self:getUI("bg.toolBtnLayer.buyOneBtn.Image_28")
    local quanIcon = self:getUI("bg.toolLayer.quan_img")
    if (self._modelMgr:getModel("UserModel"):getCurServerTime() - toolLastTime > 0 and toolNum < toolFreeNum) then
        isFree = true
        -- cost = "本次免费"
        cost = "免费（" .. (toolFreeNum-toolNum) .. "）"        
    end 

    return isFree ,cost ,toolFreeNum,toolNum
end

function DialogFlashCardResult:isGemFree()    
    local havePrivilege = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.ZuanShiChouKa)
    local isFree = false
    local isHalf = false
    local cost = gemSingle
    local disCount
    local disCountNum = 1
    local teamLastTime = (self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().drawTeamLastTime or 0)-self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_9)
   
    
    if (self._modelMgr:getModel("UserModel"):getCurServerTime()-teamLastTime > 0) then
        isFree = true
        cost = "本次免费"
        self._timeLabel:setString("")
     
        -- self._gDot:setVisible(true)
    else        
        
        local teamNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day1
        if teamNum == 0 and havePrivilege ~= 0 then
            cost = cost*discountSingle
            disCount = "半价"
            disCountNum = discountSingle           
        end
    end 

    
    return isFree,cost,disCount,disCountNum
    -- return true
end
--]]
function DialogFlashCardResult:showItemAgin(data)
    --更新用户钻石
    if data.d and data.d.drawAward then
        self._playerDayModel:updateDrawAward(data.d.drawAward)
    end
   
    if data.d and data.d.dayInfo then
        self._playerDayModel:updateDayInfo(data.d.dayInfo)
    end

    if data.d and data.d.items then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(data.d.items)
        data.d.items = nil
    end

    if data.d and data.d.teams then
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(data.d.items)
        data.d.teams = nil
    end
    if data.d then
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(data.d)
    end

    -- self:reflashTimeLabel()

    self._isAgain = true
    self:reflashUI(data)

end

return DialogFlashCardResult