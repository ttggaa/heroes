--
-- Author: huangguofang
-- Date: 2018-04-11 17:12:55
--

local AcRuneCardLayer = class("AcRuneCardLayer", require("game.view.activity.common.ActivityCommonLayer"))

function AcRuneCardLayer:ctor()
    AcRuneCardLayer.super.ctor(self)
    self._acModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._runeCardModel = self._modelMgr:getModel("RuneCardModel")
    self._curIndex = 0
end

function AcRuneCardLayer:destroy()
	AcRuneCardLayer.super.destroy(self)
end

function AcRuneCardLayer:onInit()
    self._tableData = tab:Activity108(1) or {}

    local bg = self:getUI("bg")
    bg:setBackGroundImage("asset/bg/ac_runeCard_bg.jpg")

    local rechargeNum = self:getUI("bg.buyPanel.buyBtn.txt")
    rechargeNum:enableOutline(cc.c4b(60,30,10,255), 1)
    self._buyPanel = self:getUI("bg.buyPanel")
    self._buyPanel:setSwallowTouches(false)
    self._getPanel = self:getUI("bg.getPanel")
    self._getPanel:setSwallowTouches(false)

    self._highPrice = self:getUI("bg.buyPanel.highPrice")
    self._lowPrice = self:getUI("bg.buyPanel.lowPrice")

    local drawNode = cc.DrawNode:create()
    self._gbtnDraw = drawNode
    self._buyPanel:addChild(drawNode,10)

    local buyBtn = self:getUI("bg.buyPanel.buyBtn")
    self:registerClickEvent(buyBtn, function(sender)
        self:buyBtnClicked(sender)
    end)
    self._buyBtn = buyBtn

    local cardBtn = self:getUI("bg.getPanel.cardBtn")
    self:registerClickEvent(cardBtn, function(sender)
        self:getOneBtnClicked(sender)
    end)    
    self._cardBtn = cardBtn
    local dailyBtn = self:getUI("bg.getPanel.dailyBtn")
    self:registerClickEvent(dailyBtn, function(sender)
        self:getDailyBtnClicked(sender)
    end)
    self._dailyBtn = dailyBtn

    local btn = ccui.Button:create()
    btn:loadTextures("globalImage_info.png","globalImage_info.png","",1)
    btn:setPosition(30,424)
    bg:addChild(btn,10)
    self:registerClickEvent(btn, function () 
        print("============打开规则界面======")
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("runeCard_rule")},true)
    end)
    
    self:updateInfoPanel()
end

function AcRuneCardLayer:updateInfoPanel()    
    self._cardData = self._runeCardModel:getRuneCardData()
    local currTime = self._userModel:getCurServerTime()
    -- 已购买
    -- dump(self._cardData,"self._cardData==>",5)
    local haveBuy = self._cardData and self._cardData.expireTime and self._cardData.expireTime > currTime
    self._getPanel:setVisible(haveBuy)
    self._buyPanel:setVisible(not haveBuy)

    -- 周卡过期或者没购买需要本地读表
    local price1 = self._tableData.price1 or {}
    local price2 = self._tableData.price2 or {}
    local show = self._tableData.show or {}
    local dailyReward = self._tableData.dailyReward or {}
    local mainReward = self._tableData.mainReward or {}
    if haveBuy then
        -- dump(self._cardData,"self._cardData==>",5)
        price1 = self._cardData and self._cardData.price1 or 0
        price2 = self._cardData and self._cardData.price2 or 0
        local showStr = self._cardData and self._cardData.showItems or ""
        show = json.decode(showStr) 
        dailyRewardStr = self._cardData and self._cardData.dailyReward or ""
        dailyReward = json.decode(dailyRewardStr) 
        mainRewardStr = self._cardData and self._cardData.oneTimeReward or ""
        mainReward = json.decode(mainRewardStr) 
    end

    -- 按钮状态  
    if haveBuy and (not self._cardData.oneTimeStatus or self._cardData.oneTimeStatus == 0) then
        self._cardBtn:setTitleText("领取")
        self._cardBtn:setTouchEnabled(true)
        self._cardBtn:setSaturation(0)
    else
        self._cardBtn:setSaturation(-100)
        self._cardBtn:setTitleText("已领取")
        self._cardBtn:setTouchEnabled(false)
    end
    local dailyBtnState = self._runeCardModel:getRuneCardDailyStatus()
    -- print("===============dailyBtnState===,",dailyBtnState)
    if haveBuy and dailyBtnState == 0 then
        self._dailyBtn:setTitleText("领取")
        self._dailyBtn:setTouchEnabled(true)
        self._dailyBtn:setSaturation(0)
    else
        self._dailyBtn:setSaturation(-100)
        self._dailyBtn:setTitleText("已领取")
        self._dailyBtn:setTouchEnabled(false)
    end
       
    if self._gbtnDraw then
        self._gbtnDraw:clear()
    end
    self._highPrice:setString("原价 ¥" .. price1)
    self._lowPrice:setString("现价 ¥" .. price2)
    self._price = price2
    local posX,posY = self._highPrice:getPosition()
    local contextSize = self._highPrice:getContentSize()
    self._gbtnDraw:drawSegment(cc.p(posX-contextSize.width*0.5,posY),cc.p(posX+contextSize.width*0.5,posY),1,cc.c4f(1.0, 0.0, 0.0, 1.0))

    -- 热点panel
    local hotPanel = self:getUI("bg.hotPanel")
    -- dump(show,"show==>",5)
    local itemId
    local rType
    local icon
    local posX = 5
    for k,v in pairs(show) do
        itemId = v[2]
        rType = v[1]
        if rType == "tool"then
            local toolD = tab:Tool(tonumber(itemId))
            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
            icon:setScale(0.62)
        elseif rType == "rune" then                
            -- print("==================itemId====",itemId)
            local itemData = tab:Rune(itemId)
            icon =IconUtils:createHolyIconById({suitData = itemData})
            icon:setScale(0.62)
        else
            itemId = IconUtils.iconIdMap[rType]
            local toolD = tab:Tool(tonumber(itemId))
            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
            icon:setScale(0.62)
        end
        icon:setPosition(posX,5)
        posX = posX + 62
        hotPanel:addChild(icon)
    end

    -- 周卡奖励
    -- mainReward
    -- dump(mainReward,"mainReward==>",4)
    local itemBg1 = self:getUI("bg.itemBg1")
    itemId = mainReward[1][2]
    rType = mainReward[1][1]
    local num = mainReward[1][3]
    if rType == "tool"then
        local toolD = tab:Tool(tonumber(itemId))
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
    elseif rType == "rune" then                
        -- print("==================itemId====",itemId)
        local itemData = tab:Rune(itemId)
        icon =IconUtils:createHolyIconById({suitData = itemData})
    else
        itemId = IconUtils.iconIdMap[rType]
        local toolD = tab:Tool(tonumber(itemId))
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
    end
    local boxIcon = icon.boxIcon
    local iconColor = icon.iconColor
    if boxIcon then
        boxIcon:setVisible(false)
    end
    if iconColor then
        iconColor:setVisible(false)
    end 
    local numTxt = ccui.Text:create()
    numTxt:setFontName(UIUtils.ttfName)
    numTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    numTxt:setPosition(icon:getContentSize().width-15,15)
    numTxt:setFontSize(20)
    numTxt:setString("x" .. num)
    icon:addChild(numTxt,100)
    icon:setPosition(0,0)
    icon:setScale(1.2)
    itemBg1:addChild(icon)

    -- 每日奖励
    -- dailyReward
    local itemBg2 = self:getUI("bg.itemBg2")
    itemId = dailyReward[1][2]
    rType = dailyReward[1][1]
    num = dailyReward[1][3]
    if rType == "tool"then
        local toolD = tab:Tool(tonumber(itemId))
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
    elseif rType == "rune" then                
        -- print("==================itemId====",itemId)
        local itemData = tab:Rune(itemId)
        icon =IconUtils:createHolyIconById({suitData = itemData})
    else
        itemId = IconUtils.iconIdMap[rType]
        local toolD = tab:Tool(tonumber(itemId))
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
    end
    local boxIcon = icon.boxIcon
    local iconColor = icon.iconColor
    if boxIcon then
        boxIcon:setVisible(false)
    end
    if iconColor then
        iconColor:setVisible(false)
    end   
    numTxt = ccui.Text:create()
    numTxt:setFontName(UIUtils.ttfName)
    numTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    numTxt:setPosition(icon:getContentSize().width-15,15)
    numTxt:setString("x" .. num)
    numTxt:setFontSize(20)
    icon:addChild(numTxt,100) 
    icon:setPosition(-5,0)
    icon:setScale(1.2)
    itemBg2:addChild(icon)

    -- 倒计时时间
    self:setCountDown()
end

-- 设置时间
function AcRuneCardLayer:setCountDown()
    local endNum = self:getUI("bg.getPanel.endNum")
    local expireTime = self._cardData and self._cardData.expireTime or 0
    local currTime = self._userModel:getCurServerTime()
    if expireTime > 0 then
        local tempValue = expireTime - currTime
        day = math.floor(tempValue/86400) 
        endNum:setString(string.format("%.2d天", day))
    else
        endNum:setString("0天")
    end
end

-- 购买
function AcRuneCardLayer:buyBtnClicked(sender)    
    local function goBuy()
            local goodData = tab:CashGoodsLib(self._tableData.goodsID)
            -- payment_android
            -- payment_ios
            local param1 = {}
            param1.ftype = 4
            param1.gname = lang(goodData.des)
            param1.gdes = lang(goodData.des)
            if OS_IS_IOS then
                param1.product_id = "com.tencent.yxwdzzjy."..goodData.payment_ios
            end
            -- param1.ext = json.encode({id = self._tableData.goodsID, num = 1})
            local price = tonumber(self._price)*10
            local param2 = "com.tencent.yxwdzzjy.".. goodData.payment_ios .."*".. price .."*".. 1
            self:rmbReCharge(param1,param2)
            -- self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
    end
    goBuy()

    -- DialogUtils.showBuyDialog({
    --         costNum = self._price,
    --         costType = "rmb",
    --         goods = "购买圣徽周卡？",
    --         callback1 = function()
    --             goBuy()
    --         end
    --     })
end

function AcRuneCardLayer:rmbReCharge(param1,param2)
    local tag = SystemUtils.loadAccountLocalData("RUNECARD_NO_WARING")
    if tag and tag == 1 then
        print("rmbReCharge 1")
        self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
    else
        self._viewMgr:showDialog("shop.DirectChargeSureDialog",{
                                    localTxt = "RUNECARD_NO_WARING",
                                    contentTxt = "zhigouremind2",
                                    callback = function ()
                                        print("rmbReCharge 2")
                                        self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
                                    end})
    end
end


function AcRuneCardLayer:getDailyBtnClicked(sender)
    
    self._serverMgr:sendMsg("RuneCardServer", "getRuneCardDailyReward", {}, true, {}, function(success, result)
        -- 更新每日奖励按钮状态
        -- 按钮状态  
        if not success then return end
        if result["reward"] then
            DialogUtils.showGiftGet({gifts = result["reward"],callback = function() 
                if not self._dailyBtn then return end                
                self._dailyBtn:setSaturation(-100)
                self._dailyBtn:setTitleText("已领取")
                self._dailyBtn:setTouchEnabled(false)          
            end})
        end       
    end)
end

function AcRuneCardLayer:getOneBtnClicked(sender)
    self._serverMgr:sendMsg("RuneCardServer", "getRuneCardOneTimeReward", {}, true, {}, function(success, result)
        -- 更新只领一次按钮状态
        if not success then return end
        if result["reward"] then
            DialogUtils.showGiftGet({gifts = result["reward"],callback = function()
                if not self._cardBtn then return end 
                self._cardBtn:setSaturation(-100)
                self._cardBtn:setTitleText("已领取")
                self._cardBtn:setTouchEnabled(false)                
            end})
        end
    end)
end

return AcRuneCardLayer