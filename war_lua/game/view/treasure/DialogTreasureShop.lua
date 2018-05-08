--[[
    Filename:    DialogTreasureShop.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-02-03 17:56:23
    Description: File description
--]]

local DialogTreasureShop = class("DialogTreasureShop",BasePopView)
function DialogTreasureShop:ctor()
    self.super.ctor(self)
    self._shopModel = self._modelMgr:getModel("ShopModel")
end
local posLimt = {}
for k,v in pairs(tab.shopTreasure) do
    if not posLimt[v.position] then
        posLimt[v.position] = {}
        posLimt[v.position].vipLevel = v.vipLevel
        posLimt[v.position].level = v.level
    end
end
-- 初始化UI后会调用, 有需要请覆盖
function DialogTreasureShop:onInit()
    self:registerClickEventByName("bg.mainBg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("treasure.DialogTreasureShop")
    end)
    self._mainBg = self:getUI("bg.mainBg")
    self._scrollView = self:getUI("bg.mainBg.scrollView")
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height

    self._title = self:getUI("bg.mainBg.innerBg.innerTitle.title")
    UIUtils:setTitleFormat(self._title,4)

    self._item = self:getUI("bg.item")
    self._item:setVisible(false)
    local priceLab = self._item:getChildByFullName("priceLab")
    -- priceLab:setFntFile(UIUtils.bmfName_shop)
    priceLab:setAnchorPoint(cc.p(0,0.5))

    self._modelMgr:getModel("TeamModel"):refreshDataOrder()
    -- self._modelMgr:getModel("TeamModel"):refreshDataOrder()
    self._needItems = self._modelMgr:getModel("TeamModel"):getEquipItems()
    local teamModelData = self._modelMgr:getModel("TeamModel"):getData()
    local countMax = self._modelMgr:getModel("FormationModel"):getCommonFormationCount() or 8
    for i,v in ipairs(teamModelData) do
        if i<= countMax then
            local teamId = v.teamId
            local itemId = 3000+tonumber(teamId)
            if self._needItems[itemId] then
                self._needItems[itemId] = self._needItems[itemId]+1
            else
                self._needItems[itemId] = -1
            end
        end
    end
    self:listenReflash("ShopModel", self.reflashShopInfo)
    self:listenReflash("VipModel", function( )
        self._refreshAnim = nil
        self:sendGetShopInfoMsg("treasure")
    end)
    self:listenReflash("UserModel", function( )
        self:updateShopItem()
    end)
    -- 计时器
    self._timeLab = self:getUI("bg.mainBg.timeLab")
    local timeSL = ccui.Text:create()
    timeSL:setFontSize(20)
    timeSL:setPosition(50,-10)
    timeSL:setColor(cc.c3b(128, 255, 0))
    self._timeLab:addChild(timeSL)

    local time = self._shopModel:getShopRefreshTime("treasure") or 0
    self._nextRefreshTime = time
    self._timeLab:setString("00:00:00") --(string.format("%02d:%02d:%02d",math.floor(time/3600),math.floor((time%3600)/60),time%60) or 
    local tmpIdx = self._idx
    local timerFunc = function( )
        if not self._shopModel.getShopRefreshTime then
            self._timeLab:setVisible(false)
            return 
        end
        -- timeSL:setString(TimeUtils.date("%d-%H:%M:%S",self._modelMgr:getModel("UserModel"):getCurServerTime())  .. "----" .. TimeUtils.date("%d-%H:%M:%S",self._nextRefreshTime))--self._modelMgr:getModel("UserModel"):getCurServerTime()))
        self._timeLab:setVisible(true)
        local restTime = self._nextRefreshTime - self._modelMgr:getModel("UserModel"):getCurServerTime()+2

        -- local nowDate = TimeUtils.date("*t",self._modelMgr:getModel("UserModel"):getCurServerTime())
        local reflashDate = TimeUtils.date("*t",self._nextRefreshTime) 
        -- local dayTxt = "当日"
        -- if reflashDate.day > nowDate.day then
        --     dayTxt = "次日"
        -- end

        if restTime > -10 then
            if restTime <= 0 then
                self._shopModel:setData({})
                if restTime == 0 then
                    self._refreshAnim = true
                    ScheduleMgr:delayCall(800, self, function( )
                        self._refreshAnim = nil
                    end)
                end
                self:sendGetShopInfoMsg("treasure")
                -- self._timeLab:setString("等待刷新..")
            else
                if tmpIdx ~= self._idx then
                    self._nextRefreshTime = self._shopModel:getShopRefreshTime("treasure")
                    tmpIdx = self._idx
                    restTime = self._nextRefreshTime - self._modelMgr:getModel("UserModel"):getCurServerTime()
                end
                -- self._timeLab:setString(":"..string.format("%02d:%02d:%02d",math.floor(restTime/3600),math.floor((restTime%3600)/60),restTime%60) or 0)
                self._timeLab:setString("为"..reflashDate.hour..":00")
            end
        end
    end
    timerFunc()
    self._timerFunc = timerFunc
    self.timer = ScheduleMgr:regSchedule(1000,self,function( )
        self._timerFunc()
    end)

    self._costImg = self:getUI("bg.mainBg.backTexture.costImg")
    self._refreshTimeLab = self:getUI("bg.mainBg.backTexture.refreshTimeLab")
    self._backTexture = self:getUI("bg.mainBg.backTexture")
    self._refreshBtn = self:getUI("bg.mainBg.backTexture.refreshBtn")
    self._refreshBtn:setScale(0.9)
    -- self._refreshBtn:setTitleFontSize(20)
    -- self._refreshBtn:setTitleFontName(UIUtils.ttfName) 
    self:registerClickEvent(self._refreshBtn, function( )
        self:sendReFreshShopMsg("treasure")
    end)
    -- 宝物兑换按钮
    self._showBtn = self:getUI("bg.mainBg.backTexture.showBtn")
    self._showBtn:setScale(0.9)
    self:registerClickEvent(self._showBtn, function( )
        self:sendReFreshShopMsg("treasure")
    end)

    self:registerClickEvent(self._refreshBtn, function( )
        self:sendReFreshShopMsg("treasure")
    end)

    self._previewBtn = self:getUI("bg.mainBg.backTexture.previewBtn")
    self._previewBtn:setScale(0.9)
    self._previewBtn:setTitleFontSize(20)
    self._previewBtn:setTitleFontName(UIUtils.ttfName) 
    self:registerClickEvent(self._previewBtn, function( )
        self._viewMgr:showDialog("treasure.TreasureExchangePreview", {})
    end)

    self:registerTimer(5,0,3,function(  )
        self:sendGetShopInfoMsg("treasure")
    end)
end

function DialogTreasureShop:onDestroy( )
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
    self._modelMgr:clearSelfTimer(self)
    self.super.onDestroy(self)
end

-- 接收自定义消息
function DialogTreasureShop:reflashUI(data)
    self:reflashShopInfo()
end

-- 按类型返回商店数据
function DialogTreasureShop:getGoodsData( tp )
    -- if true then return end
    local goodsData
    local shopData = self._shopModel:getShopGoods("treasure")
    if shopData ~= nil then
        goodsData = {}
        local shopTableName = "shopTreasure"
        for pos,data in pairs(shopData) do
            -- for pos,itemInfo in pairs(data) do
                -- local shopD = clone(tab[shopTableName][tonumber(id)])
                -- if shopD == nil then
                --     self._viewMgr:showTip("不存在的商品, "..shopTableName.." ID="..id)
                -- end
                -- if data.buyTimes ~= 0 then
                --     shopD.buyTimes = buyTimes
                -- else
                --     shopD.buyTimes = 0
                -- end
                -- -- if shopD.num == 0 then
                -- --     shopD.buyTimes = 1
                -- -- else
                -- --     shopD.buyTimes = 0
                -- -- end
                -- shopD.itemId = itemid --or shopD.itemId[1]
                -- shopD.id = tonumber(id)-- 勘正表错误代码
                -- -- shopD.costType = "currency"
                -- shopD.shopBuyType = "treasure"
                -- table.insert(goodsData,shopD)
                local shopD = clone(tab[shopTableName][tonumber(data.id)])
                if shopD == nil then
                    self._viewMgr:showTip("不存在的商品, "..shopTableName.." ID="..id)
                end
                -- if shopD.num == 0 then
                --     shopD.buyTimes = 1
                -- else
                --     shopD.buyTimes = 0
                -- end
                local buyTimes = data.buy
                shopD.itemId = data.item
                -- dump(itemInfo,"itemInfo..",2)
                -- for k1,v1 in pairs(itemInfo) do
                --     shopD.itemId = k1--or shopD.itemId[1]
                --     buyTimes = v1
                -- end
                if buyTimes >= tab[shopTableName][tonumber(data.id)].buyTimes then
                    shopD.buyTimes = 1 -- 1表示已买
                else
                    shopD.buyTimes = 0 -- 0表示未买
                end
                shopD.id = tonumber(data.id)-- 勘正表错误代码
                -- shopD.costType = "currency"
                shopD.shopBuyType = "treasure"
                shopD.pos = pos
                goodsData[tonumber(pos)] = shopD
            -- end
        end
        -- table.sort(goodsData,function( a,b )
        --     local aS = a.sort or a.position or 0
        --     local bS = b.sort or b.position or 0
        --     if not tonumber(aS) or not tonumber(bS) or tonumber(aS) == tonumber(bS) then
        --         return tonumber(a.itemId) < tonumber(b.itemId) 
        --     end
        --     return tonumber(aS or 0) < tonumber(bS or 0)
        -- end)
        -- dump(goodsData)
    end
    
    return goodsData
end

function DialogTreasureShop:reflashShopInfo()
    self._scrollView:removeAllChildren()
    self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
    if self._shopModel.getRefreshCost then
        local refreshTimes = self._shopModel:getRefreshCost("treasure")
        self._refreshTimeLab:setString(refreshTimes)
        self._refreshTimeLab:setVisible(true)
        local costRes = IconUtils.resImgMap["gem"]--tab[shopTableIdx[self._idx]][1]["costType"]]
        if costRes and costRes ~= "" then
            self._costImg:loadTexture(costRes,1)
            self._costImg:setScale(0.8)
        end
        self._refreshTimeLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)       
        if refreshTimes and refreshTimes > self._modelMgr:getModel("UserModel"):getData().gem then
            self._refreshTimeLab:setColor(UIUtils.colorTable.ccUIBaseColor6) 
        end
    else
        self._refreshTimeLab:setVisible(false)
    end

    local goodsData = self:getGoodsData()
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
    local itemSizeX,itemSizeY = 196,196
    local offsetX,offsetY = -4,-2
    local row =math.ceil(#goodsData/4) --2--
    local col = 4-- math.ceil(#goodsData/2)

    local boardHeight = math.ceil(#goodsData/4)*itemSizeY
    local scrollHeight = self._scrollView:getContentSize().height
    if boardHeight < scrollHeight then
        boardHeight = scrollHeight 
    else
        self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,boardHeight))
    end
    -- local boardWidth = math.ceil(#goodsData/2)*itemSizeX
    -- if boardWidth > self.scrollViewW then
    --     self._scrollView:setInnerContainerSize(cc.size(boardWidth+20,self.scrollViewH))
    --     self:showArrow("right")
    -- end
    local x,y = 0,0
    local goodsCount = math.max(8,row*col)
    self:lock()
    local goodsIdx = 1
    -- dump(goodsData)
    for i=1,goodsCount do
        if not self:detectOpenPos(i) then
            self._nextOpenIdx = i
            break
        end
    end
    self._itemTable = {}
    for i=1,goodsCount do
        -- x = math.floor((i-1)/row)*itemSizeX+offsetX
        -- y = self.scrollViewH/2 - (i-1)%row*itemSizeY+offsetY
        x = (i-1)%col*itemSizeX+offsetX-8+itemSizeX*0.5
        y = self.scrollViewH/2 - math.floor((i-1)/col)*itemSizeY+offsetY+itemSizeY*0.5 

        local isOpen = self:detectOpenPos(i)
        if isOpen then           
            self:createItem( i,goodsData[i],x,y)
        else
            self:createGrid(x,y,i,goodsData[i])-- i记录pos值跟shopView不通用
        end
    end
    self:unlock()
end
function DialogTreasureShop:updateShopItem()
    local goodsData = self:getGoodsData("treasure")
    if not goodsData then 
        return 
    end
    if not self._itemTable or table.nums(self._itemTable) == 0 then 
        return
    end
    local goodsCount = table.getn(goodsData)
    local player = self._modelMgr:getModel("UserModel"):getData()   
    for i=1,goodsCount do
        data = goodsData[i]
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
                -- priceStr = string.format("% 6d",costNum)
                priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
                if haveNum <costNum and data.buyTimes ~= 1 then
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
local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function DialogTreasureShop:createItem(index, data,x,y)
    local item
    item = self._item:clone()
    self._itemTable[index] = item
    item:setSwallowTouches(false)
    item:setName("item"..index)
    item:setVisible(true)
    self._scrollView:addChild(item)
    item:setPosition(cc.p(x,y))

    local itemId = tonumber(data.itemId)
    local toolD = tab:Tool(itemId)
    local canTouch = true
    --加图标
    local itemIcon = item:getChildByFullName("itemIcon")
    itemIcon:setSwallowTouches(false)
    itemIcon:removeAllChildren()
    local num = data.num 
    if num == 1 then 
        num = nil
    end
    local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,eventStyle = 0})
    icon:setContentSize(cc.size(100, 100))
    icon:setScale(0.85)
    itemIcon:addChild(icon)
    -- 设置名称
    local itemName = item:getChildByFullName("itemName")
    itemName:setString(lang(toolD.name) or "没有名字")
    itemName:setFontName(UIUtils.ttfName)
    itemName:setColor(UIUtils.colorTable["ccUIBaseTextColor2"])
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
        haveNum = player[data.costType]
        costNum = data.costNum
    end
    -- 花费
    local priceLab = item:getChildByFullName("priceLab")
    -- priceStr = string.format("% 6d",costNum)
    priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
    if haveNum <costNum and data.buyTimes ~= 1 then
        priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
        -- priceLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    else
        priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- priceLab:disableEffect()
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

    self:registerClickEvent(item, function( )
        if canTouch then
            self._refreshAnim = nil
            self._viewMgr:showDialog("shop.DialogShopBuy",data,true)
        end
    end)
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
    
    if data.buyTimes == 1 then
        canTouch = false
        local soldOut = item:getChildByFullName("soldOut")
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
        
        self:setNodeColor(item,cc.c4b(128, 128, 128,255))
        self:setNodeColor(soldOut,cc.c4b(255, 255, 255,255))
        local mc = icon:getChildByName("bgMc")
        if mc then
            mc:setVisible(false)
        end
    else
        canTouch = true
        local soldOut = item:getChildByFullName("soldOut")
        soldOut:setVisible(false)
    end

    -- 添加红点
    local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(data.itemId)
    local needCount = self._needItems[data.itemId] or 0
    
    if (count < needCount or needCount == -1) and canTouch  then
        local dot = ccui.ImageView:create()
        local teamId = string.sub(tostring(itemId),2,string.len(tostring(itemId)))
        if teamId and string.len(itemId) == 4 then
            local isInFormation = self._modelMgr:getModel("FormationModel"):isTeamLoaded(teamId)
            if isInFormation then
                dot:loadTexture("globalIamgeUI6_addTeam.png", 1)
                dot:setPosition(cc.p(item:getContentSize().width/2-icon:getContentSize().width/2+10,item:getContentSize().height/2-icon:getContentSize().height/2+60))
            -- else -- 没上阵的去掉推荐
            --     dot:loadTexture("recommand_shop.png", 1)
            --     dot:setPosition(cc.p(10,item:getContentSize().height-dot:getContentSize().height/2+10))
            end
        else
            dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            dot:setPosition(cc.p(item:getContentSize().width/2+icon:getContentSize().width/2-10,item:getContentSize().height/2+icon:getContentSize().height/2-10))
        end
        dot:setName("noticeTip")
        item:addChild(dot,99)
    end
    
    if self._refreshAnim then
        local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", false, true,function( )
        end)
        -- mc:setPosition(cc.p(x,y))
        mc:setPosition(cc.p(x+item:getContentSize().width/2+30,y+item:getContentSize().height/2-50))
        self._scrollView:addChild(mc,9999)
        -- item:addChild(mc,9999)
    end
end
local sentMsgCount = 2
-- 创建空格子
function DialogTreasureShop:createGrid(x,y,pos,data )
    local item = ccui.ImageView:create()
    -- item:setCapInsets(cc.rect(60,50,10,10))
    item:loadTexture("globalPanelUI7_cellBg1.png",1)
    -- item:setContentSize(196,196)
    -- item:setScale9Enabled(true)
    -- item:setCapInsets(cc.rect(60,50,10,10))

    local shopGridFrame = ccui.ImageView:create()
    shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    shopGridFrame:setName("shopGridFrame")
    shopGridFrame:setContentSize(cc.size(98, 98))
    shopGridFrame:setAnchorPoint(cc.p(0.5,0.5))
    shopGridFrame:setPosition(cc.p(93,99))
    shopGridFrame:setScale(0.85)
    item:addChild(shopGridFrame,2)
    local shopGridBg = ccui.ImageView:create()
    shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    shopGridBg:setName("shopGridBg")
    shopGridBg:setContentSize(cc.size(98, 98))
    shopGridBg:setAnchorPoint(cc.p(0.5,0.5))
    shopGridBg:setPosition(cc.p(100,106))
    shopGridBg:setScale(0.85)
    item:addChild(shopGridBg,1)

    -- 加装饰条
    local decorateImg = self._item:getChildByFullName("bottomDecorate")
    if decorateImg then
        local decImg = decorateImg:clone()
        item:addChild(decImg,0)
    end

    local itemId = tonumber(data.itemId)
    local toolD = tab:Tool(itemId)
    if self._nextOpenIdx == pos then
        local num = data.num 
            if num == 1 then 
                num = nil
            end
        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,effect=true,num = num,eventStyle = 0})
        icon:setContentSize(cc.size(100, 100))
        icon:setScale(0.85)
        icon:setPosition(cc.p(item:getContentSize().width/2-48,item:getContentSize().height/2-40))
        item:addChild(icon,2)
    end
    

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setPosition(cc.p(item:getContentSize().width/2-2,item:getContentSize().height/2+6))
    item:addChild(lock,3)
    
    item:setAnchorPoint(cc.p(0.5,0.5))
    item:setPosition(x,y)
    self._scrollView:addChild(item)
    local low,high
    if posLimt[pos] and posLimt[pos].level then
        low,high = posLimt[pos].level[1],posLimt[pos].level[2]
    end
    
    local vipLevel
    if posLimt[pos] and  posLimt[pos].vipLevel then
        vipLevel = posLimt[pos].vipLevel
    end
    local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl or 0

    local condtion1 = low and vipLevel and (vip >= vipLevel or lvl >= low)
    local condtion2 = low and not vipLevel and (lvl >= low)
    local condtion3 = not low and vipLevel and (vip >= vipLevel)
    if condtion1 or condtion2 or condtion3 then
        self:sendGetShopInfoMsg("treasure")
    end

    local title = ccui.Text:create()
    title:setFontName(UIUtils.ttfName)
    title:setAnchorPoint(cc.p(0.5,0.5))
    title:setFontSize(24)
    title:setName("stage")
    -- title:setColor(cc.c3b(255, 255, 255))
    title:setPosition(cc.p(item:getContentSize().width/2,item:getContentSize().height-33))
    title:setFontName(UIUtils.ttfName)
    -- title:setString("未开启")
    if self._nextOpenIdx == pos then
        title:setString(lang(toolD.name) or "没有名字")
        -- title:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
    else
        title:setString("暂未开启")
    end
    title:setColor(UIUtils.colorTable["ccUIBaseTextColor2"])
    -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    item:addChild(title,99)

    -- local openCodition = ccui.Text:create()
    -- openCodition:setFontName(UIUtils.ttfName)
    -- openCodition:setAnchorPoint(cc.p(0.5,0.5))
    -- openCodition:setFontSize(18)
    -- openCodition:enableOutline(cc.c4b(0, 0, 0, 255),1)
    -- openCodition:setName("stage")
    -- openCodition:setPosition(cc.p(item:getContentSize().width/2,20))
    -- item:addChild(openCodition,99)

    -- local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    -- local vip = self._modelMgr:getModel("VipModel"):getData().level
    -- if lvl < low then
    --      openCodition:setString("等级不足")
    -- elseif vip < vipLevel then
    --     openCodition:setString("vip等级不足")  
    -- end
    local rtxStr = "[color = 696969] [-]"
    if low and vipLevel then
        rtxStr = "[color = 3c3c3c,fontSize = 20]" .. low .. "级[-][color = 3c3c3c,fontSize = 20]或[-][color = 3c3c3c,fontSize = 20]VIP" .. vipLevel .. "开启[-][color = 3c3c3c,fontSize = 20][-]"
    elseif low then
        rtxStr = "[color = 3c3c3c,fontSize = 20]" .. low .. "级[-][color = 3c3c3c,fontSize = 20]开启[-]"
    elseif vipLevel then
        rtxStr = "[color = 3c3c3c,fontSize = 20]VIP" .. vipLevel .. "[-][color = 3c3c3c,fontSize = 20]开启[-]"
    end
    local rtx = RichTextFactory:create(rtxStr,200,40)
    rtx:formatText()
    -- rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(cc.p(item:getContentSize().width/2,25+h/2))
    -- rtx:setScale(0.8)
    item:addChild(rtx)
    UIUtils:alignRichText(rtx)

    item:setScaleAnim(true)
    self:registerClickEvent(item,function( )
        if not posLimt[pos] then return end
        local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
        local lvl = self._modelMgr:getModel("UserModel"):getData().lvl or 0
        if (low and lvl < low ) and not (vip and vip < vipLevel) then
            self._viewMgr:showTip("等级" .. low .. "开启" )
            return
        end
        if (vip and vip < vipLevel) then
            self._viewMgr:showView("vip.VipView", {viewType = 0})
        end
    end)
    self:setNodeColor(item,cc.c4b(128, 128, 128,255))
end

function DialogTreasureShop:detectOpenPos( pos )
    local low,high
    if posLimt[pos] and posLimt[pos].level then
        low,high = posLimt[pos].level[1],posLimt[pos].level[2]
    end
    
    local vipLevel
    if posLimt[pos] and  posLimt[pos].vipLevel then
        vipLevel = posLimt[pos].vipLevel
    end
    local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl or 0

    local condtion1 = low and vipLevel and (vip >= vipLevel or lvl >= low)
    local condtion2 = low and not vipLevel and (lvl >= low)
    local condtion3 = not low and vipLevel and (vip >= vipLevel)
    if condtion1 or condtion2 or condtion3 then
        return true
    end

    return false
end
-- 灰态
function DialogTreasureShop:setNodeColor( node,color )
    if node and not tolua.isnull(node) then 
        if node:getDescription() ~= "Label" then
            node:setColor(color)
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

function DialogTreasureShop:sendGetShopInfoMsg( shopName )
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = shopName}, true, {}, function(result)
        if result.shop["treasure"] and  
            result.shop["treasure"].lastUpTime and 
            result.shop["treasure"].lastUpTime > self._nextRefreshTime then 
            self._nextRefreshTime = self._shopModel:getShopRefreshTime("treasure")
        end
    end)
end

function DialogTreasureShop:sendReFreshShopMsg( shopName )
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local lastUpTime = self._shopModel:getShopByType("treasure").lastUpTime
    if curTime - lastUpTime < 1 then
        self._viewMgr:showTip("刷新太频繁，请稍后再试！")
        return 
    end

    self._refreshAnim = true
    -- ScheduleMgr:delayCall(1500, self, function( )
    --     self._refreshAnim = nil
    -- end)
    local player = self._modelMgr:getModel("UserModel"):getData()
    local costType = "gem"--tab[shopTableIdx[self._idx]][1]["costType"]
    local haveNum = player[costType] or 0
    local times = self._shopModel:getShopByType("treasure").reflashTimes or 0
    times = times+1
    if times > #tab.reflashCost then
        times = #tab.reflashCost
    end

    -- 刷新限制
    local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
    local vipLimt = tab.vip[vip].refleshTreasure
    if times > vipLimt then
        if vip == #tab.vip then
            self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP_MAX"))
        else
            local des = {}
            if des then
                des = string.split(lang("REFRESH_TREASURE_SHOP"), "，")
                if #des < 2 then
                    des = string.split(lang("REFRESH_TREASURE_SHOP"), ",")
                end
            end
            self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = des[1] or "今日抽取次数已用完" ,des2 = des[2] or "提升vip可增加抽取次数"},true)
        end
        return
    end

    local cost = tab:ReflashCost(times)["shopTreasure"]
    if cost > haveNum then
        local costName = lang("TOOL_" .. IconUtils.iconIdMap[costType])
        if costType == "gem" then
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_" .. string.upper(costType)),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        else
            self._viewMgr:showTip(lang("TIP_GLOBAL_LACK_" .. string.upper(costType)) or "缺少资源")
        end
        self._refreshAnim = nil
        return 
    else
        DialogUtils.showBuyDialog({costNum = cost,costType = costType,goods = "刷新一次",callback1 = function( )  
            audioMgr:playSound("Reflash")    
            self._serverMgr:sendMsg("ShopServer", "reflashShop", {type = "treasure"}, true, {}, function(result) 
            end)
        end})
    end
    
end

return DialogTreasureShop