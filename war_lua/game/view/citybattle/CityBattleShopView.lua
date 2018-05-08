--[[
    Filename:    CityBattleShopView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-02-03 21:04:58
    Description: File description
--]]

local CityBattleShopView = class("CityBattleShopView",BaseLayer)
local resKey = "cbCoin"
local requestKey = "citybattle"
local playerData
local maxRefreshTimes = 3

function CityBattleShopView:ctor(param)
    CityBattleShopView.super.ctor(self)
    self._shopModel = self._modelMgr:getModel("ShopModel")
    self._timeLabs = {} 
    self._itemTable = {}
    playerData = self._modelMgr:getModel("UserModel"):getData()
    self._callBack = param and param.callBack
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    maxRefreshTimes = tonumber(tab:Vip(vip).refreshCityBattle)
end

function CityBattleShopView:onInit()
    self:registerClickEventByName("bg.mainBg.closeBtn", function ()
        self:close()
        if self._callBack then
            self._callBack()
        end
        UIUtils:reloadLuaFile("citybattle.CityBattleShopView")
    end)
    self._mainBg = self:getUI("bg.mainBg")
    self._scrollView = self:getUI("bg.mainBg.scrollView")
    self._scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height

    self._scrollView:addEventListener(function(sender, eventType)
        if self._scrollView:getInnerContainer():getPositionY() < -5 then
             self._downArrow:setVisible(true)
        else
             self._downArrow:setVisible(false)
        end
    end)

    self._item = self:getUI("bg.item")
    self._item:setVisible(false)
    local priceLab = self._item:getChildByFullName("priceLab")
    priceLab:setAnchorPoint(cc.p(0,0.5))

    -- self:listenReflash("ShopModel", self.reflashShopInfo)
    -- self:listenReflash("UserModel", function( )
    --     self:updateShopItem()
    -- end)

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

    -- 每日五点刷新
    -- self:registerTimer(5,0,1,function(  )
    --     self:sendGetShopInfoMsg(requestKey)
    -- end)


    self._costLable = self:getUI("bg.mainBg.cost")
    self._costLable:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._refreshCostImage = self:getUI("bg.mainBg.costIma")
    self._refreshBtn = self:getUI("bg.mainBg.refresh")
    self._refreshCostbg = self:getUI("bg.mainBg.refreshCostbg")
    -- self._timeOutLabel = self:getUI("bg.mainBg.timeOut")

    self:registerClickEvent(self._refreshBtn, function( )
        self:sendReFreshShopMsg()
    end)

end


function CityBattleShopView:sendReFreshShopMsg( shopName )
    shopName = "citybattle"
    self._refreshAnim = true
    local cost,costType = self._shopModel:getRefreshCost("citybattle")
    local haveNum = playerData[costType] or 0
    local times = self._shopModel:getShopByType(shopName).reflashTimes or 0

    if times >= maxRefreshTimes then
        self._viewMgr:showTip("刷新次数已用完")
        return
    end

    times = times+1
    if cost > haveNum then
        if costType == "gem" then
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_" .. string.upper(costType)),callback1=function( )
                self._viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        else
            if costType == "guildCoin" then
                self._viewMgr:showTip("联盟币不足")
            else
                self._viewMgr:showTip(lang("TIP_GLOBAL_LACK_" .. string.upper(costType)) or "缺少资源")
            end
        end
        self._refreshAnim = nil
        return
    else

        DialogUtils.showBuyDialog({costNum = cost,costType = costType,goods = "刷新一次",
            callback1 = function( )      
                audioMgr:playSound("Reflash")
                self._serverMgr:sendMsg("ShopServer", "reflashShop", {type = "citybattle", true, {}, function(result)

                end})
                if not self._isBuyBack then
                    self._offsetY = nil
                else
                    self._isBuyBack = false
                end
            end})
    end
end

function CityBattleShopView:onDestroy( )
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
    self._modelMgr:clearSelfTimer(self)
    CityBattleShopView.super.onDestroy(self)
end

-- 接收自定义消息
function CityBattleShopView:reflashUI(data)
    self:reflashShopInfo()
end

function CityBattleShopView:reflashShopInfo()
    self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
    local cbCoin = self._modelMgr:getModel("UserModel"):getData().cbCoin or 0
    self._refreshTimeLab:setString(cbCoin)

    local goodsData = self:getGoodsData()
    -- dump(goodsData,"商店详情",10)
    if not goodsData then 
        return 
    end
    -- table.sort(goodsData,function( a,b )
    --     local aS = a.sort or a.position or 0
    --     local bS = b.sort or b.position or 0
    --     if not tonumber(aS) or not tonumber(bS) or tonumber(aS) == tonumber(bS) then
    --         return tonumber(a.itemId) < tonumber(b.itemId) 
    --     end
    --     return tonumber(aS or 0) < tonumber(bS or 0)
    -- end)
    local itemSizeX,itemSizeY = 186,192
    local offsetX,offsetY = 17.5,10.5
    local line = 4
    local col = math.ceil(#goodsData/line)

    local boardHeight = col*itemSizeY
    if boardHeight > self.scrollViewH and col > 2 then
        self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,boardHeight))
        
        self._downArrow:setVisible(true)
    else
        self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
        boardHeight = self.scrollViewH
    end

    -- if col > 8 then
    --     self._scrollView:setBounceEnabled(true)
    --     self._scrollView:setInnerContainerSize(cc.size(boardWidth-10,self.scrollViewH))
    -- else
    --     self._scrollView:setBounceEnabled(false)
    --     self._scrollView:setInnerContainerSize(cc.size(boardWidth-20,self.scrollViewH))
    -- end

    -- local boardHeight = math.ceil(#goodsData/4)*itemSizeY
    -- local boardHeight = math.ceil(#goodsData/4)*itemSizeY
    -- local scrollHeight = self._scrollView:getContentSize().height
    -- if boardHeight < scrollHeight then
    --     boardHeight = scrollHeight 
    -- else
    --     self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
    -- end
    -- local boardWidth = math.ceil(#goodsData/2)*itemSizeX
    -- if boardWidth > self.scrollViewW then
    --     self._scrollView:setInnerContainerSize(cc.size(boardWidth+20,self.scrollViewH))
    --     self:showArrow("right")
    -- end
    local x,y = 0,0
    local goodsCount = math.max(8, line * col)
    -- self:lock()

    -- dump(goodsData)
    -- local curRank = self._modelMgr:getModel("LeagueModel"):getCurZone()
    for i=1, goodsCount do
        x = (i-1)%line*itemSizeX + offsetX
        y = boardHeight - (math.floor((i-1)/line) + 1) * itemSizeY + offsetY
        if not self._nextOpenIdx then
            self._nextOpenIdx = i
        end

        if goodsData[i] then           
            self:createItem(i, goodsData[i], x, y)
        else
            self:createGrid(x, y, i)
        end
    end
    if self._offsetY then
        local offsetY = self._offsetY
        local subHeight = self._scrollView:getContentSize().height - boardHeight
        if subHeight < offsetY then
            self._scrollView:getInnerContainer():setPositionY(offsetY)            
        else
            self._scrollView:getInnerContainer():setPositionY(subHeight)
        end
        -- self._offsetY = nil
    end
    -- self:unlock()
    self:refreshRefresBtnCost()
end

-- 按类型返回商店数据
function CityBattleShopView:getGoodsData(tp)
    -- local goodsData = {}
    local shopData = self._shopModel:getShopGoods("citybattle") or {}
    -- dump(shopData,"CityBattleShopView:getGoodsData",10)
    -- local shopTableName = "shopCityBattle"
    local shopD = clone(tab["shopCityBattle"])
    for k,gridD in pairs(shopD) do
        gridD.buy = shopData[tostring(gridD.grid[1])] and shopData[tostring(gridD.grid[1])].buy or 0
        gridD.itemId = gridD.itemId[1]
        gridD.shopBuyType = "citybattle"
        gridD.pos = gridD.grid[1]
    end

    local sortFunc = function(a, b)
        return a.grid[1] < b.grid[1]
    end
    table.sort(shopD, sortFunc)

    return shopD
end

local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function CityBattleShopView:createItem(index, data,x,y)
    local item
    if self._itemTable[index] then
        item = self._itemTable[index]
    else
        item = self._item:clone()
        self._itemTable[index] = item
        self._scrollView:addChild(item)
        item:setSwallowTouches(false)
        item:setName("item"..index)
        item:setVisible(true)
        item:setAnchorPoint(0.5,0.5)
        item:setPosition(x+item:getContentSize().width*0.5,y+item:getContentSize().width*0.5 + 2)
    end
    local itemBg = item:getChildByFullName("itemBg")
    local bottomDecorate = item:getChildByFullName("bottomDecorate")
    local splitDec = item:getChildByFullName("splitDec")
    local itemBgNb = item:getChildByFullName("itemBgNb")

    if data.gridType == 1 then
        itemBg:setVisible(false)
        itemBgNb:setVisible(true)
        bottomDecorate:setVisible(false)
        splitDec:setVisible(false)
    else
        itemBg:setVisible(true)
        itemBgNb:setVisible(false)
        bottomDecorate:setVisible(true)
        splitDec:setVisible(true)
    end

    local itemId = data.itemId
    itemId = tonumber(itemId)
    
    local toolData = tab:Tool(itemId)
    local canTouch = data.canBuyTimes ~= 0
    --加图标
    local itemIcon = item:getChildByFullName("itemIcon")
    itemIcon:setSwallowTouches(false)
    itemIcon:removeAllChildren()
    local num = data.num 
    if num == 1 then 
        num = nil
    end

    local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolData,effect=false,num = num,eventStyle = 0})
    icon:setContentSize(cc.size(100, 100))
    icon:setScale(0.9)
    icon:setPosition(cc.p(0,0))
    itemIcon:addChild(icon,2)

    -- local award = data.award
    -- if award[1] == "tool" then
    --     local itemId = award[2]
    --     local toolData = tab:Tool(itemId)
    --     local num = award[3]

    --     local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolData,effect=false,num = num,eventStyle = 0})
    --     icon:setContentSize(cc.size(100, 100))
    --     icon:setScale(0.9)
    --     icon:setPosition(cc.p(0,0))
    --     itemIcon:addChild(icon,2)
    -- elseif award[1] == "avatarFrame" then
    --     local frameData = tab:AvatarFrame(award[2])
    --     param = {itemId = award[2], itemData = frameData,eventStyle = 0}
    --     local icon = IconUtils:createHeadFrameIconById(param)
    --     icon:setContentSize(cc.size(100, 100))
    --     icon:setPosition(0,0)
    --     icon:setScale(0.8)
    --     itemIcon:addChild(icon)
    -- else
    --     local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolData,effect=false,num = num,eventStyle = 0})
    --     icon:setContentSize(cc.size(100, 100))
    --     icon:setPosition(0,0)
    --     icon:setScale(0.9)
    --     itemIcon:addChild(icon)
    -- end

    -- 设置名称
    local itemName = item:getChildByFullName("itemName")
    itemName:setString(lang(toolData.name) or "没有名字")
    itemName:setFontName(UIUtils.ttfName)
    local haveNum = 0
    local costNum = 0
    if type(data.costType) == "table" then
        haveNum = playerData[(data.costType[1] or data.costType["type"])] or 0
        costNum = data.costType[3] or data.costType["num"]
        data.costType = (data.costType[1] or data.costType["type"])
        data.costNum = costNum
    else
        haveNum = playerData[data.costType] or 0
        costNum = data.costNum
    end
    -- 花费
    local priceLab = item:getChildByFullName("priceLab")
    -- priceLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- priceStr = string.format("% 6d",costNum)
    priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
    if haveNum < costNum then
        priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
    -- priceBmpLab:setPositionX((item:getContentSize().width-priceBmpLab:getContentSize().width)/2)
    -- 购买类型
    local buyIcon = item:getChildByFullName("diamondImg")
    buyIcon:loadTexture(IconUtils.resImgMap[data.costType],1)
    local scaleNum = math.floor((32/buyIcon:getContentSize().width)*100)
    buyIcon:setScale(scaleNum/100)

    local iconW = buyIcon:getContentSize().width*scaleNum/100
    local labelW = priceLab:getContentSize().width
    local itemW = item:getContentSize().width - 5
    buyIcon:setPositionX(itemW/2-labelW/2-3)
    priceLab:setPositionX(itemW/2+iconW/2-labelW/2-3)

    item:getChildByFullName("bottomDecorate"):setOpacity(80)

    -- data.discount = 3
    local discountBg = item:getChildByFullName("discountBg")

    if data.discount and data.discount > 0 then
        local prix = "red"
        if data.discount > 5 then 
            prix = "blue"
        end
        discountBg:loadTexture(prix .. "_discountbg_shop.png",1)
        local discountLab = discountBg:getChildByFullName("discountLab")
        discountLab:setString(discountToCn[data.discount])
        discountBg:setVisible(true)
    else
        discountBg:setVisible(false)
    end
    
    
    if self._refreshAnim then
        local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", false, true,function( )
        end)
        -- mc:setPosition(cc.p(x,y))
        mc:setScaleY(1.1)
        mc:setPosition(x+80,y+90)
        self._scrollView:addChild(mc,9999)
        -- item:addChild(mc,9999)
        
        -- local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", true, false,function( )
        -- mc:setPosition(cc.p(x,y))
        -- mc:setScaleY(1)
        -- mc:setPosition(x+30,y-5)
        -- self._scrollView:addChild(mc,9999)
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
    -- local canBuyCountLab = item:getChildByName("canBuyCount")
    -- local timeLab = item:getChildByName("timeLab")
    -- local canBuyLab = item:getChildByName("canBuyLab")
    -- if not self._timeLabs[index] then
    --     timeLab.preUpTime = data.lastBuyTime or 0
    --     timeLab.recover = data.recover
    --     timeLab.data = data
    --     self._timeLabs[index] = timeLab
    -- end
    item:setScaleAnim(false)
    self:registerClickEvent(item, function( )
        if data.canBuyTimes == 0 and data.sortHero == 1 then
            self._viewMgr:showTip("你已购买过该服务")
        elseif canTouch then
            self._refreshAnim = nil
            self._offsetY = self._scrollView:getInnerContainer():getPositionY() 
            local param = {shopData = data,closeCallBack=function ( ... )
                self._isBuyBack = true
            end}
            self._viewMgr:showDialog("shop.DialogShopBuy",param,true)
        else
            self._viewMgr:showTip("等待恢复")
        end
    end)

    local soldOut = item:getChildByFullName("soldOut")
    soldOut:setVisible(false)
    self:setNodeColor(item,cc.c4b(255, 255, 255,255),true)
    if data.buy == 1 then
        canTouch = false
        -- local soldOut = item:getChildByFullName("soldOut")
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
        -- UIUtils:setGray(item,true)
        -- item:setBrightness(-50)
        self:setNodeColor(item,cc.c4b(182, 182, 182,255))
        self:setNodeColor(soldOut,cc.c4b(255, 255, 255,255))
        -- self:setNodeColor(discountBg,cc.c4b(255, 255, 255,255))
        local iconColor = icon:getChildByName("iconColor")
        if iconColor then
            local mc = iconColor:getChildByName("bgMc")
            if mc then
                mc:setVisible(false)
            end
        end
    else
        item:setEnabled(true)
        canTouch = true
        local soldOut = item:getChildByFullName("soldOut")
        soldOut:setVisible(false)
        local mc = icon:getChildByFullName("bgMc")
        if mc then
            mc:setVisible(true)
        end
    end
end

local sentMsgCount = 2
-- 创建空格子
function CityBattleShopView:createGrid(x, y, index)
    if self._itemTable[index] and not tolua.isnull(self._itemTable[index]) then
        self._itemTable[index]:removeFromParent()
    end
    local item 
    item = self._item:clone()
    item:setVisible(true)
    item:setTouchEnabled(false)
    self._itemTable[index] = item
    local name = item:getChildByFullName("itemName")
    local diamondImg = item:getChildByFullName("diamondImg")
    local discountBg = item:getChildByFullName("discountBg")
    local priceLab = item:getChildByFullName("priceLab")
    local bottomDecorate = item:getChildByFullName("bottomDecorate")
    local itemBgNb = item:getChildByFullName("itemBgNb")
    local itemBg = item:getChildByFullName("itemBg")
    local soldOut = item:getChildByFullName("soldOut")
    soldOut:setVisible(false)
    itemBg:setVisible(true)
    itemBgNb:setVisible(false)
    -- name:setVisible(false)
    diamondImg:setVisible(false)
    discountBg:setVisible(false)
    priceLab:setVisible(false)
    bottomDecorate:setOpacity(0)
    
    name:setString("暂未开启")
    name:setPositionY(155)
    name:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local posx = item:getContentSize().width*0.5
    local posy = item:getContentSize().height*0.5+2
    local shopGridFrame = ccui.ImageView:create()
    shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    shopGridFrame:setName("shopGridFrame")
    shopGridFrame:setContentSize(98, 98)
    shopGridFrame:setAnchorPoint(0.5,0.5)
    shopGridFrame:setPosition(posx+3,posy+5)
    shopGridFrame:setScale(85/shopGridFrame:getContentSize().width)
    item:addChild(shopGridFrame,2)
    local shopGridBg = ccui.ImageView:create()
    shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    shopGridBg:setName("shopGridBg")
    shopGridBg:setContentSize(100, 100)
    shopGridBg:setAnchorPoint(0.5,0.5)
    shopGridBg:setPosition(posx+3,posy+5)
    shopGridBg:setScale(80/shopGridBg:getContentSize().width)
    item:addChild(shopGridBg,1)

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setName("lock")
    lock:setPosition(posx,posy)
    -- lock:setScale(0.85)
    item:addChild(lock,3)
    self._scrollView:addChild(item)
    item:setPosition(x+item:getContentSize().width/2,y+item:getContentSize().height/2)

    -- 置灰显示
    self:setNodeColor(item,cc.c4b(182, 182, 182,255))
end
-- 灰态
function CityBattleShopView:setNodeColor( node,color,notDark )
    -- if true then return end
    if node and not tolua.isnull(node) and node:getName() ~= "lock" then 
        if node:getDescription() ~= "Label" then
            node:setColor(color)
        else
            if not notDark then
                node:setBrightness(-50)
            else
                node:setBrightness(0)
            end
        end
    end
    local children = node:getChildren()
    if children == nil or #children == 0 then
        return 
    end
    for k,v in pairs(children) do
        self:setNodeColor(v,color,notDark)
    end
end

function CityBattleShopView:sendGetShopInfoMsg( shopName )
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = shopName}, true, {}, function(result)
        -- if result.shop["heroDuel"] and  
        --     result.shop["heroDuel"].lastUpTime and 
        --     result.shop["heroDuel"].lastUpTime > self._nextRefreshTime then 
        --     self._nextRefreshTime = self._shopModel:getShopRefreshTime("heroDuel")
        -- end
    end)
end

--[[
    刷新消耗
]]
function CityBattleShopView:refreshRefresBtnCost()
    local cost = 0
    local costType = "gem"
    cost,costType = self._shopModel:getRefreshCost("citybattle")
    local haveNum = playerData[costType]
    self._costLable:setString(cost)
    self._costLable:setVisible(true)
    self._costLable:setColor(haveNum>=cost and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor6)

    local costRes = IconUtils.resImgMap[costType]
    if costRes and costRes ~= "" then
        self._refreshCostImage:loadTexture(costRes,1)
        self._refreshCostImage:setScale(0.8)
    end

    local times = self._shopModel:getShopByType("citybattle").reflashTimes or 0
    if times >= maxRefreshTimes then
        UIUtils:setGray(self._refreshBtn,true)
        self._refreshCostImage:setVisible(false)
        self._costLable:setVisible(false)
        self._refreshCostbg:setVisible(false)
        self._refreshBtn:setTitleText("次数用尽")
    else
        UIUtils:setGray(self._refreshBtn,false)
        self._refreshCostImage:setVisible(true)
        self._costLable:setVisible(true)
        self._refreshCostbg:setVisible(true)
        self._refreshBtn:setTitleText("刷新")
    end

end

-- 更新商店数据
function CityBattleShopView:updateShopItem()
    local goodsData = self:getGoodsData()
    if not goodsData then 
        return
    end
    if not self._itemTable or table.nums(self._itemTable) == 0 then 
        return
    end
    local goodsCount = table.getn(goodsData)
     
    for i=1,goodsCount do
        local data = goodsData[i]
        -- dump(data)
        local haveNum = 0
        local costNum = 0
        if type(data.costType) == "table" then
            haveNum = playerData[(data.costType[1] or data.costType["type"])]
            costNum = data.costType[3] or data.costType["num"]
            data.costType = (data.costType[1] or data.costType["type"])
            data.costNum = costNum
        else
            haveNum = playerData[data.costType] or 0
            costNum = data.costNum
        end
        print("costT")

        print("haveNum",haveNum)
        print("costNum",costNum)

        -- 花费
        if self._itemTable[i] then
            local priceLab = self._itemTable[i]:getChildByFullName("priceLab")
            if priceLab then 
                priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
                if haveNum < costNum then --or data.buyTimes ~= 1 -- buyTimes ~= 1 的逻辑移除
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

-- 切换页签 更新offsetY & reflashAnim
function CityBattleShopView:resetOffsetY()
    self._offsetY = nil
    self._isBuyBack = false
    self._refreshAnim = false
end

return CityBattleShopView