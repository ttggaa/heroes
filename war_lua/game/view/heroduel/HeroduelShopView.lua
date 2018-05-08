--[[
    Filename:    HeroduelShopView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-02-03 21:04:58
    Description: File description
--]]


local HeroduelShopView = class("HeroduelShopView",BasePopView)

local shopTpList = {"heroDuel", "HDAvatar", "HDSkin"}

function HeroduelShopView:ctor()
    self.super.ctor(self)
    self._shopModel = self._modelMgr:getModel("ShopModel")
    self._timeLabs = {} -- timeLabel s 
    self._itemTable = {}
    self._itemSpecialTable = {}
end 


-- 初始化UI后会调用, 有需要请覆盖
function HeroduelShopView:onInit()
    self:registerClickEventByName("bg.mainBg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroduelShopView")
    end)
    self._mainBg = self:getUI("bg.mainBg")
    self._scrollView = self:getUI("bg.mainBg.scrollView")
    -- self._scrollView:setClippingType(1)
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height

    self._scrollView:addEventListener(function(sender, eventType)
        if self._scrollView:getInnerContainer():getPositionY() < -5 then
             self._downArrow:setVisible(true)
        else
             self._downArrow:setVisible(false)
        end
        local width = self._scrollView:getInnerContainerSize().width
        local minX = 712 - width
        if self._scrollView:getInnerContainer():getPositionX() > minX then
             self._rightArrow:setVisible(true)
        else
             self._rightArrow:setVisible(false)
        end
    end)

    self._item = self:getUI("bg.item")
    self._item:setVisible(false)
    local priceLab = self._item:getChildByFullName("itemBg.priceLab")
    -- priceLab:setFntFile(UIUtils.bmfName_shop)
    priceLab:setAnchorPoint(cc.p(0,0.5))

    self:listenReflash("ShopModel", self.reflashShopInfo)
    self:listenReflash("UserModel", function( )
        self:updateShopItem()
    end)

    self._costImg = self:getUI("bg.mainBg.backTexture.costImg")
    self._refreshTimeLab = self:getUI("bg.mainBg.backTexture.refreshTimeLab")
    self._backTexture = self:getUI("bg.mainBg.backTexture")

    local title = self:getUI("bg.mainBg.titleBg.title")
    UIUtils:setTitleFormat(title,1)

    self._downArrow = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    self._downArrow:setPosition(402,63)
    self._downArrow:setVisible(false)
    self._downArrow:setRotation(-90)
    self._mainBg:addChild(self._downArrow, 99)

    self._rightArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._rightArrow:setPosition(702,self._mainBg:getContentSize().height/2)
    self._rightArrow:setVisible(true)
    self._mainBg:addChild(self._rightArrow, 100)

    -- -- 每日五点
    -- self:registerTimer(5,0,1,function(  )
    --     self:sendGetShopInfoMsg("heroDuel")
    -- end)
    -- -- 周一四点 统一刷新
    -- self:registerTimer(4,0,1,function(  )
    --     self:sendGetShopInfoMsg("heroDuel")
    -- end)

    -- 
    self:updateTimeLab()
    self.timer = ScheduleMgr:regSchedule(1000, self, function( )
        self:updateTimeLab()
    end)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, self:getUI("bg.mainBg.tab_item"))
    table.insert(self._tabEventTarget, self:getUI("bg.mainBg.tab_head"))
    table.insert(self._tabEventTarget, self:getUI("bg.mainBg.tab_skin"))


    for i = 1, #self._tabEventTarget do
        local button = self._tabEventTarget[i]
        button:setTitleFontName(UIUtils.ttfName_Title)
        button:setTitleFontSize(20)
        button:setTitleColor(UIUtils.colorTable.ccUIBaseTextColor2)
        button:getTitleRenderer():disableEffect()
        button.index = i
        UIUtils:setTabChangeAnimEnable(button,-33,handler(self, self.tabButtonClick))
    end

    self._tabEventTarget[1]._appearSelect = true
    self:tabButtonClick(self._tabEventTarget[1],true)
end

--[[
--! @function tabButtonClick
--! @desc 选项卡按钮点击事件处理
--! @param sender table 操作对象
--! @return 
--]]
function HeroduelShopView:tabButtonClick(sender,noAudio)
    if sender == nil or sender.index == self._curTab then 
        return 
    end
    if not noAudio then 
        audioMgr:playSound("Tab")
    end

    self._curTab = sender.index

    for k,v in pairs(self._tabEventTarget) do
--        local text = v:getTitleRenderer()
--        v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
--        text:disableEffect()
--        text:setPositionX(65)
        if v ~= sender then
            self:tabButtonState(v, false)
        end
    end
    
--    local text = sender:getTitleRenderer()
--    text:disableEffect()
--    text:setPositionX(85)
--    sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender
    UIUtils:tabChangeAnim(self._preBtn,function( )
        self:tabButtonState(sender, true)
        self:touchTabEvent(sender, noAudio)
    end)
end

function HeroduelShopView:touchTabEvent(sender, isInit)
    if isInit then return end
    local index = sender.index

    self:sendGetShopInfoMsg(shopTpList[index], function()
        self:reflashItmesInfo()
    end)
end

--[[
--! @function tabButtonState
--! @desc 按钮状态切换
--! @param sender table 操作对象
--! @param isSelected bool 是否选中状态
--! @return 
--]]
function HeroduelShopView:tabButtonState(sender, isSelected, isDisabled)
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
end


-- 接收自定义消息
function HeroduelShopView:reflashUI(data)
    self:reflashShopInfo()
end

function HeroduelShopView:reflashShopInfo()
    local hDuelCoin = self._modelMgr:getModel("UserModel"):getData().hDuelCoin or 0
    self._refreshTimeLab:setString(hDuelCoin)

    self:reflashItmesInfo()
end

local itemSizes = {{181,199},{181,199},{231,381}}
local offsetList = {{-2,-6},{-2,-6},{10,0}}
function HeroduelShopView:reflashItmesInfo()
    local goodsData = self:getGoodsData(self._curTab)
    -- dump(goodsData,"商店详情",10)
    if not goodsData then 
        return 
    end

    local itemSizeX,itemSizeY = itemSizes[self._curTab][1], itemSizes[self._curTab][2]
    local offsetX,offsetY = offsetList[self._curTab][1], offsetList[self._curTab][2]


    for _, v in pairs(self._itemTable) do
        v:removeFromParent()
    end

    for _, vS in pairs(self._itemSpecialTable) do
        vS:removeFromParent()
    end

    if self._curTab ~= 3 then
        local line = 4
        local col = math.ceil(#goodsData/line)
        local boardHeight = col * itemSizeY + (col - 1) * offsetY
        if boardHeight > self.scrollViewH and col > 2 then
            self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,boardHeight))
    --        self:showArrow("right")
        else
            self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
            boardHeight = self.scrollViewH
        end

        local x,y = 0,0
        local goodsCount = math.max(8, #goodsData)
        -- dump(goodsData)

        for i=1, goodsCount do
--             x = math.floor((i-1)/row) * (itemSizeX + offsetX)
--             y = i % row * (itemSizeY + offsetY)
            x = (i-1)%line*(itemSizeX + offsetX)
            y = boardHeight - (math.floor((i-1)/line) + 1) * (itemSizeY + offsetY)
            if not self._nextOpenIdx then
                self._nextOpenIdx = i
            end

            if goodsData[i] then           
                self:createItem( i,goodsData[i],x,y)
            end
        end
    else
        local goodsCount = math.max(3, #goodsData)
        local boardWidth = goodsCount * itemSizeX + (goodsCount - 1) * offsetX
        if boardWidth > self.scrollViewW and goodsCount > 3 then
            self._scrollView:setInnerContainerSize(cc.size(boardWidth,self.scrollViewH))
    --        self:showArrow("right")
        else
            self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
        end

        local x,y = 0,0
        for i = 1, goodsCount do
            x = (i-1)*(itemSizeX + offsetX)
            y = 0
            self:createItemSpecial(i, goodsData[i], x, y)
        end
    end
end

-- 按类型返回商店数据
function HeroduelShopView:getGoodsData( tp )
    -- if true then return end

    local tempDatas = {}
    local shopData = self._shopModel:getShopGoods(shopTpList[tp]) or {}

    local shopD = clone(tab["shopHeroDuel"])

--    dump(shopData,"shopData....")
--    dump(shopD,"shopD....")

    for k,gridD in pairs(shopD) do
        if gridD.sort == self._curTab then
            gridD.shopBuyType = shopTpList[tp]
            gridD.canBuyTimes = gridD.buyTimes
            gridD.sortHero = 1 
            gridD.num = 1 
            if gridD.recover then
                gridD.sortHero = 2
            end
            tempDatas[tonumber(k)] = gridD
        end
    end

    -- dump(shopData,"shopD)))))")
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    for pos,data in pairs(shopData) do
        pos = tonumber(pos)
        if tempDatas[pos] then
            tempDatas[pos].canBuyTimes = data.buyTimes or 0
            tempDatas[pos].lastBuyTime = data.lastBuyTime 
            if tempDatas[pos].recover then
                local recover = tempDatas[pos].recover
                local add = math.floor((nowTime-data.lastBuyTime)/recover)
                tempDatas[pos].canBuyTimes = math.min(data.buyTimes + add,tempDatas[pos].buyTimes)
            end
            -- dump(goodsData[pos],"pos..." .. pos)
        end
    end
    -- local shopDDD = self._shopModel:getData()
    -- dump(shopDDD,"shopD)))))")

    local goodsData = {}
    for k, v in pairs(tempDatas) do
        table.insert(goodsData, v)
    end

    local sortFunc = function(a, b)
        return a.grid < b.grid
    end
    table.sort(goodsData, sortFunc)

    return goodsData
end

local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function HeroduelShopView:createItem(index, data,x,y)
    local item
    if self._itemTable[index] then
        item = self._itemTable[index]
    else
        item = self._item:clone()
        item:retain()
        self._itemTable[index] = item
        item:setSwallowTouches(false)
        item:setName("item"..index)
        item:setVisible(true)
        item:setAnchorPoint(0.5,0.5)
    end
    item:setPosition(x+item:getContentSize().width/2,y+item:getContentSize().height/2)
    self._scrollView:addChild(item)

    local itemId = data.itemId
    itemId = tonumber(itemId)
    
    local toolD = tab:Tool(itemId)
    local canTouch = data.canBuyTimes ~= 0
    --加图标
    local itemIcon = item:getChildByFullName("itemBg.itemIcon")
    itemIcon:setSwallowTouches(false)
    itemIcon:removeAllChildren()
    local num = data.num 
    if num == 1 then 
        num = nil
    end

    local award = data.award
    if award[1] == "tool" then
        local itemId = award[2]
        local toolD = tab:Tool(itemId)
        local num = award[3]

        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,effect=false,num = num,eventStyle = 0})
        icon:setContentSize(cc.size(100, 100))
        icon:setScale(0.72)
        icon:setPosition(cc.p(10,20))
        itemIcon:addChild(icon,2)
    elseif award[1] == "avatarFrame" then
        -- param = {frame = 1, awardIcon = toolD["art"]}
        local frameData = tab:AvatarFrame(award[2])
        param = {itemId = award[2], itemData = frameData,eventStyle = 0}
        local icon = IconUtils:createHeadFrameIconById(param)
        icon:setContentSize(cc.size(100, 100))
        icon:setPosition(10,20)
        icon:setScale(0.65)
        itemIcon:addChild(icon)
    else
        -- param = {avatar = award[2], tp = 4}
        -- local icon = IconUtils:createHeadIconById(param)
        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,effect=false,num = num,eventStyle = 0})
        icon:setContentSize(cc.size(100, 100))
        icon:setPosition(10,20)
        icon:setScale(0.72)
        itemIcon:addChild(icon)
    end

    -- 设置名称
    local itemName = item:getChildByFullName("itemBg.itemName")
    itemName:setString(lang(toolD.name) or "没有名字")
    itemName:setFontName(UIUtils.ttfName)
    -- itemName:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
    -- itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local haveNum = 0
    local costNum = 0
    local player = self._modelMgr:getModel("UserModel"):getData()
    if type(data.costType) == "table" then
        haveNum = player[(data.costType[1] or data.costType["type"])] or 0
        costNum = data.costType[3] or data.costType["num"]
        data.costType = (data.costType[1] or data.costType["type"])
        data.costNum = costNum
    else
        haveNum = player[data.costType] or 0
        costNum = data.costNum
    end
    -- 花费
    local priceLab = item:getChildByFullName("itemBg.priceLab")
    -- priceLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- priceStr = string.format("% 6d",costNum)
    priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
    if haveNum < costNum then
        priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
    priceLab:setVisible(true)
    -- priceBmpLab:setPositionX((item:getContentSize().width-priceBmpLab:getContentSize().width)/2)
    -- 购买类型
    local buyIcon = item:getChildByFullName("itemBg.diamondImg")
    buyIcon:loadTexture(IconUtils.resImgMap[data.costType],1)
    local scaleNum = math.floor((32/buyIcon:getContentSize().width)*100)
    buyIcon:setScale(scaleNum/100)
    buyIcon:setVisible(true)

    local iconW = buyIcon:getContentSize().width*scaleNum/100
    local labelW = priceLab:getContentSize().width
    local itemW = item:getContentSize().width - 5
    buyIcon:setPositionX(itemW/2-labelW/2-3)
    priceLab:setPositionX(itemW/2+iconW/2-labelW/2-3)

    local bottomDecorate = item:getChildByFullName("itemBg.bottomDecorate")
    bottomDecorate:setOpacity(80)
    bottomDecorate:setContentSize(150, 32)

    -- data.discount = 3
    local discountBg = item:getChildByFullName("itemBg.discountBg")

    if data.discount and data.discount > 0 then
        local prix = "red"
        if data.discount > 5 then 
            prix = "blue"
        end
        discountBg:loadTexture(prix .. "_discountbg_shop.png",1)
        local discountLab = discountBg:getChildByFullName("itemBg.discountLab")
        discountLab:setString(discountToCn[data.discount])
        discountBg:setVisible(true)
    else
        discountBg:setVisible(false)
    end
    
    
    if self._refreshAnim then
        local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", false, true,function( )
        end)
        -- mc:setPosition(cc.p(x,y))
        mc:setPosition(cc.p(x+item:getContentSize().width/2+30,y+item:getContentSize().height/2-50))
        self._scrollView:addChild(mc,9999)
        -- item:addChild(mc,9999)
    end

    -- 修正信息
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    -- local shopInfo = self._shopModel:getShopGoods("heroDuel")[tostring(data.id)]
    -- if shopInfo then
    --     local add = math.floor((nowTime- shopInfo.lastBuyTime)/data.recover)
    --     local canBuyTimes = shopInfo.buyTimes
    --     data.buyTimes = tab:ShopHeroduel(data.id).buyTimes 
    --     data.canBuyTimes = math.min(canBuyTimes + add,data.buyTimes)
    --     data.lastBuyTime = shopInfo.lastBuyTime
    -- end
    
    -- 数量控制
    local canBuyCountLab = item:getChildByFullName("itemBg.canBuyCount")
    local timeLab = item:getChildByFullName("itemBg.timeLab")
    local canBuyLab = item:getChildByFullName("itemBg.canBuyLab")
    canBuyLab:setVisible(true)
    local soldOut = item:getChildByFullName("soldOut")
    soldOut:setVisible(false)
    local lockIcon = item:getChildByFullName("lockImg")
    lockIcon:setVisible(false)
    item:getChildByFullName("itemBg"):setBrightness(0)

    if not self._timeLabs[index] then
        timeLab.preUpTime = data.lastBuyTime or 0
        timeLab.recover = data.recover
        timeLab.data = data
        self._timeLabs[index] = timeLab
    end

    local lockDesLab1 = item:getChildByFullName("itemBg.lockDesLab1")
    lockDesLab1:setColor(cc.c3b(120,120,120))
    local lockDesLab2 = item:getChildByFullName("itemBg.lockDesLab2")
    lockDesLab2:setColor(cc.c3b(196,73,4))
    local lockDesLab3 = item:getChildByFullName("itemBg.lockDesLab3")
    lockDesLab3:setColor(cc.c3b(120,120,120))
    lockDesLab1:setVisible(false)
    lockDesLab2:setVisible(false)
    lockDesLab3:setVisible(false)
    item:setEnabled(true)

    local isLock = false
    if data.unlock ~= nil then
        if not self:isUnlock(data.unlock) then
            item:getChildByFullName("itemBg"):setBrightness(-50)
            lockIcon:setVisible(true)
            isLock = true

            lockDesLab1:setVisible(true)
            lockDesLab2:setVisible(true)
            lockDesLab3:setVisible(true)

            buyIcon:setVisible(false)
            priceLab:setVisible(false)
            canBuyLab:setVisible(false)

            bottomDecorate:setContentSize(150, 47)

            if data.unlock[1] == 1 then
                lockDesLab1:setString("获得皮肤")
                local skinData = tab:HeroSkin(data.unlock[2])
                local nameStr = ""
                if skinData and skinData.skinName then 
                    nameStr = lang(skinData.skinName)
                end
                lockDesLab2:setString(nameStr)
            elseif data.unlock[1] == 2 then
                lockDesLab1:setString("获得英雄")
                lockDesLab2:setString(lang(tab:Hero(data.unlock[2]).heroname))
            end

            local labWidth2 = lockDesLab2:getContentSize().width
            local labWidth3 = lockDesLab3:getContentSize().width

            lockDesLab2:setPositionX(-(labWidth2+labWidth3)*0.5 + 90)
--            print(-(labWidth2+labWidth3)*0.5)
            lockDesLab3:setPositionX(lockDesLab2:getPositionX() + labWidth2)
        end
    end

    self:registerClickEvent(item, function( )
        if isLock then
            self._viewMgr:showTip("该物品未解锁")
            return
        end
        if data.canBuyTimes == 0 and data.sortHero == 1 then
            self._viewMgr:showTip("你已购买过该服务")
        elseif canTouch then
            self._refreshAnim = nil
            self._viewMgr:showDialog("shop.DialogShopBuy",data,true)
        else
            self._viewMgr:showTip("等待恢复")
        end
    end)

    if data.canBuyTimes == 0 then
        if data.sortHero == 1 then
            canBuyLab:setVisible(true)
            timeLab:setVisible(false)
            canBuyCountLab:setVisible(false)

            canBuyLab:setVisible(true)

            canBuyLab:setString("兑换次数:0/" .. data.buyTimes)

            item:getChildByFullName("itemBg"):setBrightness(-50)

            soldOut:setVisible(true)
            if item.hadSold == false then
                soldOut:setOpacity(0)
                soldOut:setScale(1.2)
                soldOut:runAction(cc.Sequence:create(
                        cc.DelayTime:create(5),
                        cc.Spawn:create(cc.FadeIn:create(0.5),cc.ScaleTo:create(0.2,0.9),cc.ScaleTo:create(0.3,1)),
                        cc.CallFunc:create(function( )
                            item.hadSold = true
                        end)
                        )
                    )
            end
            item:setEnabled(false)

        elseif data.sortHero == 2 then
            canBuyLab:setVisible(false)
            timeLab:setVisible(true)
            timeLab.preUpTime = data.lastBuyTime or 0
            timeLab.updating = true
            canBuyCountLab:setVisible(true)

            canBuyCountLab:setColor(cc.c3b(255, 23, 23))
            canBuyCountLab:setString("0/" .. data.buyTimes)
            self:updateTimeLab()
        end

    else
        if data.canBuyTimes == data.buyTimes then
            canBuyLab:setString("兑换次数:".. data.buyTimes .. "/" .. data.buyTimes)

            timeLab:setVisible(false)
            timeLab.updating = false -- 状态是否更新
            canBuyCountLab:setVisible(false)
        elseif data.sortHero == 2 then
            canBuyLab:setVisible(false)
            timeLab:setVisible(true)
            timeLab.preUpTime = data.lastBuyTime or 0
            timeLab.updating = true
            canBuyCountLab:setVisible(true)

            canBuyCountLab:setString(data.canBuyTimes .. "/" .. data.buyTimes)
            canBuyCountLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
            self:updateTimeLab()
        end
    end
end

-- 该物品是否已解锁
function HeroduelShopView:isUnlock(data)
    if data[1] == 1 then
        return self._modelMgr:getModel("HeroModel"):isHaveSkinBySkinId(data[2])
    elseif data[1] == 2 then
        return self._modelMgr:getModel("HeroModel"):checkHero(data[2])
    end
end

function HeroduelShopView:createItemSpecial(index, data,x,y)
    local item
    if self._itemSpecialTable[index] then
        item = self._itemSpecialTable[index]
    else
        item = cc.Node:create()
        item:retain()
        item:setContentSize(itemSizes[3][1], itemSizes[3][2])
        self._itemSpecialTable[index] = item
        item:setName("item"..index)
        item:setVisible(true)

        local lockBg = cc.Sprite:createWithSpriteFrameName("shopFutrure_heroDuel.png")
        lockBg:setVisible(false)
        item:addChild(lockBg)
        item.lockBg = lockBg

        local normalBg = cc.Sprite:createWithSpriteFrameName("shopFutrure_heroDuel.png")
        item:addChild(normalBg)
        item.normalBg = normalBg

        local normalW, normalH = normalBg:getContentSize().width, normalBg:getContentSize().height

        local heroAniBg = cc.Sprite:createWithSpriteFrameName("shopHeroBg_heroDuel.png")
        heroAniBg:setPosition(normalW*0.5, normalH*0.5 - 28)
        normalBg:addChild(heroAniBg)
        item.heroAniBg = heroAniBg

        local changeBtnName = "allianceBtn_lianmengqizi.png"
        local changeBtn = ccui.Button:create(changeBtnName, changeBtnName, changeBtnName, 1)
        changeBtn:setPosition(normalW*0.5 + 85, normalH*0.5 + 160)
        normalBg:addChild(changeBtn)
        item.changeBtn = changeBtn

        self:registerClickEvent(changeBtn, function()
            item.heroAniBg:setVisible(not item.heroAniBg:isVisible())
            item.normalBg:setSpriteFrame(item.heroAniBg:isVisible() and data.image1 .. ".png" or data.image2 .. ".png")
        end)

        local buyBtnName = "globalButtonUI13_1_2.png"
        local buyBtn = ccui.Button:create(buyBtnName, buyBtnName, buyBtnName, 1)
        buyBtn.name = "buyBtn"
        buyBtn:setPosition(normalW*0.5, normalH*0.5-155)
        normalBg:addChild(buyBtn)
        item.buyBtn = buyBtn

        self:registerClickEvent(buyBtn, function( )
            self._viewMgr:showDialog("shop.DialogShopBuy",data,true)
        end)


        local coinIcon = cc.Sprite:createWithSpriteFrameName(IconUtils.resImgMap.hDuelCoin)
        coinIcon:setScale(0.7)
        coinIcon:setPosition(37, 30)
        buyBtn:addChild(coinIcon)

        local costLab = cc.Label:createWithTTF("10000", UIUtils.ttfName, 18)
        costLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        costLab:setAnchorPoint(0, 0.5)
        costLab:setPosition(57, 28)
        buyBtn:addChild(costLab)
        item.costLab = costLab

        local lockDesLab = cc.Label:createWithTTF("获得英雄\n凯瑟琳后可兑换", UIUtils.ttfName, 20, cc.size(218, 58), 1)
        lockDesLab:setColor(cc.c3b(191, 191, 191))
        lockDesLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        lockDesLab:setPosition(0, -157)
        lockDesLab:setVisible(false)
        item:addChild(lockDesLab)
        item.lockDesLab = lockDesLab

        local lockIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI5_had.png")
        lockIcon:setPosition(0, 0)
        item:addChild(lockIcon)
        item.lockIcon = lockIcon

    end

    item:setPosition(x+item:getContentSize().width/2,y+item:getContentSize().height/2)
    self._scrollView:addChild(item)

    item.changeBtn:setVisible(true)
    item.buyBtn:setVisible(true)
    item.lockIcon:setVisible(false)
    item.normalBg:setBrightness(0)

    if data == nil then
        item.lockBg:setVisible(true)
        item.normalBg:setVisible(false)
    else
        item.lockBg:setVisible(false)
        item.normalBg:setVisible(true)
        item.normalBg:setSpriteFrame(data.image2 .. ".png")

        item.costLab:setString(tostring(data.costNum))

        item.heroAniBg:removeAllChildren()
        local skinData = tab:HeroSkin(data.award[2])
        mcMgr:loadRes("stop_" .. skinData.heroart, function()
            local heroAni = mcMgr:createViewMC("stop_" .. skinData.heroart, true)
            heroAni:setScale(0.8)
            heroAni:setPosition(92, 47)
            item.heroAniBg:addChild(heroAni)
            item.heroAniBg:setVisible(false)
        end)

        local isLock = false
        if data.unlock ~= nil then
            if not self:isUnlock(data.unlock) then
                item.buyBtn:setVisible(false)
                item.lockDesLab:setVisible(true)

                if data.unlock[1] == 1 then
                    local skinData = tab:HeroSkin(data.unlock[2])
                    local nameStr = ""
                    if skinData and skinData.skinName then 
                        nameStr = lang(skinData.skinName)
                    end
                    item.lockDesLab:setString("获得皮肤\n" ..  nameStr .. "后可兑换" )
                elseif data.unlock[1] == 2 then
                    item.lockDesLab:setString("获得英雄\n" ..  lang(tab:Hero(data.unlock[2]).heroname) .. "后可兑换" )
                end
            end
        end

        if  self._modelMgr:getModel("HeroModel"):isHaveSkinBySkinId(data.award[2]) or data.canBuyTimes == 0 then
            item.changeBtn:setVisible(false)
            item.buyBtn:setVisible(false)

            item.lockIcon:setVisible(true)
            item.normalBg:setBrightness(-50)
        end
    end
end

-- 灰态
function HeroduelShopView:setNodeColor( node,color )
    if node and not tolua.isnull(node) then 
        if node:getDescription() ~= "Label" then 
            if node:getName() ~= "lock" then
                node:setColor(color)
            end
        else
            node:setBrightness(-50)
        end
    end
    local children = node:getChildren()
    if children == nil or #children == 0 then
        return 
    end
    for k,v in pairs(children) do
        self:setNodeColor(v,color)
    end
end

function HeroduelShopView:sendGetShopInfoMsg( shopName, callBack )
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = shopName}, true, {}, function(result)
--        if result.shop["heroDuel"] and  
--            result.shop["heroDuel"].lastUpTime and 
--            result.shop["heroDuel"].lastUpTime > self._nextRefreshTime then 
--            self._nextRefreshTime = self._shopModel:getShopRefreshTime("heroDuel")
--        end

        callBack()
    end)
end


function HeroduelShopView:updateTimeLab( )
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    for index,timeLab in pairs(self._timeLabs) do
        if timeLab.updating and timeLab.recover then
            local deltTime = timeLab.recover - (nowTime - timeLab.preUpTime)%timeLab.recover
            if deltTime <= 1 then
                -- self:reflashUI()
                if timeLab.data then
                    dump(timeLab.data)
                    local add = math.floor((nowTime- timeLab.data.lastBuyTime)/timeLab.recover)
                    local buyTimes = self._shopModel:getShopGoods("heroDuel")[tostring(timeLab.data.id)].buyTimes
                    timeLab.data.canBuyTimes = buyTimes + add
--                    print(index,timeLab.data)
                    self:createItem(index,timeLab.data)
                end
            else
                -- print(index,"idx,updating?",deltTime,timeLab.updating,"timeLab.preUpTime",timeLab.preUpTime)
                timeLab:setString(string.format("%02d:%02d:%02d",math.floor(deltTime/3600),math.floor(deltTime%3600/60),deltTime%60))
            end
        end
    end
end


-- 更新商店数据
function HeroduelShopView:updateShopItem()
    local goodsData = self:getGoodsData("heroDuel")
    if not goodsData then 
        return 
    end
    if not self._itemTable or table.nums(self._itemTable) == 0 then 
        return
    end
    local goodsCount = table.getn(goodsData)
    local player = self._modelMgr:getModel("UserModel"):getData()   
    for i=1,goodsCount do
        local data = goodsData[i]
        -- dump(data)
        if type(data.costType) == "table" then
            haveNum = player[(data.costType[1] or data.costType["type"])]
            costNum = data.costType[3] or data.costType["num"]
            data.costType = (data.costType[1] or data.costType["type"])
            data.costNum = costNum
        else
            haveNum = player[data.costType]
            costNum = data.costNum
        end
        -- 花费
        if self._itemTable[i] then
            local priceLab = self._itemTable[i]:getChildByFullName("priceLab")
            if priceLab then 
                priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
                if haveNum <costNum then --or data.buyTimes ~= 1 -- buyTimes ~= 1 的逻辑移除
                    -- priceLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                    priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
                else
                    priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
                    -- priceLab:disableEffect()
                end
            end
        end
    end
end

function HeroduelShopView:onDestroy( )
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end

    for _, v in pairs(self._itemTable) do
        v:release()
    end

    for _, vS in pairs(self._itemSpecialTable) do
        vS:release()
    end

    self._modelMgr:clearSelfTimer(self)
    self.super.onDestroy(self)
end

-- -- 刷新商店数据
-- function HeroduelShopView:sendReFreshShopMsg( shopName )
--     local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
--     local lastUpTime = self._shopModel:getShopByType("heroDuel").lastUpTime
--     if curTime - lastUpTime < 1 then
--         self._viewMgr:showTip("刷新太频繁，请稍后再试！")
--         return 
--     end

--     self._refreshAnim = true
--     -- ScheduleMgr:delayCall(1500, self, function( )
--     --     self._refreshAnim = nil
--     -- end)
--     local player = self._modelMgr:getModel("UserModel"):getData()
--     local costType = "gem"--tab[shopTableIdx[self._idx]][1]["costType"]
--     local haveNum = player[costType] or 0
--     local times = self._shopModel:getShopByType("heroDuel").reflashTimes or 0
--     times = times+1
--     if times > #tab.reflashCost then
--         times = #tab.reflashCost
--     end

--     -- 刷新限制
--     local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
--     local vipLimt = tab.vip[vip].refleshTreasure
--     if times > vipLimt then
--         if vip == #tab.vip then
--             self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP_MAX"))
--         else
--             local des = {}
--             if des then
--                 des = string.split(lang("REFRESH_TREASURE_SHOP"), "，")
--                 if #des < 2 then
--                     des = string.split(lang("REFRESH_TREASURE_SHOP"), ",")
--                 end
--             end
--             self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = des[1] or "今日抽取次数已用完" ,des2 = des[2] or "提升vip可增加抽取次数"},true)
--         end
--         return
--     end

--     local cost = tab:ReflashCost(times)["shopHeroDuel"]
--     if cost > haveNum then
--         local costName = lang("TOOL_" .. IconUtils.iconIdMap[costType])
--         if costType == "gem" then
--             DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_" .. string.upper(costType)),callback1=function( )
--                 local viewMgr = ViewManager:getInstance()
--                 viewMgr:showView("vip.VipView", {viewType = 0})
--             end})
--         else
--             self._viewMgr:showTip(lang("TIP_GLOBAL_LACK_" .. string.upper(costType)) or "缺少资源")
--         end
--         self._refreshAnim = nil
--         return 
--     else
--         DialogUtils.showBuyDialog({costNum = cost,costType = costType,goods = "刷新一次",callback1 = function( )  
--             audioMgr:playSound("Reflash")    
--             self._serverMgr:sendMsg("ShopServer", "reflashShop", {type = "heroDuel"}, true, {}, function(result) 
--             end)
--         end})
--     end
    
-- end

return HeroduelShopView