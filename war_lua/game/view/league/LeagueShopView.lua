--[[
    Filename:    LeagueShopView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-07-06 16:49:24
    Description: File description
--]]

local LeagueShopView = class("LeagueShopView",BaseLayer)
function LeagueShopView:ctor()
    self.super.ctor(self)
    self._shopModel = self._modelMgr:getModel("ShopModel")
    self._timeLabs = {} -- timeLabel s 
    self._itemTable = {}
end
-- 初始化UI后会调用, 有需要请覆盖
function LeagueShopView:onInit()
	-- self:registerClickEventByName("bg.mainBg.closeBtn", function ()
 --        self:close()
 --        UIUtils:reloadLuaFile("league.LeagueShopView")
 --    end)
    self._mainBg = self:getUI("bg.mainBg")
    self._scrollView = self:getUI("bg.mainBg.scrollView")
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height
    self._downArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._downArrow:setPosition(self._mainBg:getContentSize().width*0.5,90)
    self._downArrow:setRotation(90)
    self._downArrow:setVisible(false)
    self._mainBg:addChild(self._downArrow, 1)
    self._scrollView:addEventListener(function(sender, eventType)
        if eventType == 1 then
            -- 底部
            self._downArrow:setVisible(false)
        elseif eventType == 4 then
            -- 滑动中
            if self._goodData and table.getn(self._goodData) > 8 then           
                self._downArrow:setVisible(true)
            end
        end
    end)

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
    -- self:listenReflash("ShopModel", self.reflashShopInfo)
    -- self:listenReflash("VipModel", function( )
    --     self._refreshAnim = nil
    --     self:sendGetShopInfoMsg("league")
    -- end)
    -- self:listenReflash("UserModel", function( )
    --     self:updateShopItem()
    -- end)

    self._costImg = self:getUI("bg.mainBg.backTexture.costImg")
    self._refreshTimeLab = self:getUI("bg.mainBg.backTexture.refreshTimeLab")
    self._backTexture = self:getUI("bg.mainBg.backTexture")
    -- self._refreshBtn = self:getUI("bg.mainBg.backTexture.refreshBtn")
    -- self._refreshBtn:setScale(0.9)
    -- self._refreshBtn:setTitleFontSize(22)
    -- self._refreshBtn:setTitleFontName(UIUtils.ttfName) 
    -- self:registerClickEvent(self._refreshBtn, function( )
    --     self:sendReFreshShopMsg("league")
    -- end)
    local title = self:getUI("bg.mainBg.titleBg.title")
    -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- title:setFontName(UIUtils.ttfName)
    -- title:setColor(cc.c3b(255, 255, 255))
    UIUtils:setTitleFormat(title,4)
    -- title:setColor(cc.c3b(250, 242, 192))
    -- title:enable2Color(1,cc.c4b(255, 195, 20,255))
    -- 每日五点
    -- self:registerTimer(5,0,1,function(  )
    --     self:sendGetShopInfoMsg("league")
    -- end)
    -- -- 周一四点 统一刷新
    -- self:registerTimer(4,0,1,function(  )
    --     self:sendGetShopInfoMsg("league")
    -- end)

    -- 
    self:updateTimeLab()
    -- if not self._resumetimer then
    --     self._resumetimer = ScheduleMgr:regSchedule(1000, self, function( )
    --         self:updateTimeLab()
    --     end)
    -- end
end

function LeagueShopView:onDestroy( )
    if self._resumetimer then
        ScheduleMgr:unregSchedule(self._resumetimer)
        self._resumetimer = nil
    end
    -- self._modelMgr:clearSelfTimer(self)
    -- self.super.onDestroy(self)
end

-- 接收自定义消息
function LeagueShopView:reflashUI(data)
	self:reflashShopInfo()
end

-- 按类型返回商店数据
function LeagueShopView:getGoodsData( tp )
    -- if true then return end
    local goodsData
    local shopData = self._shopModel:getShopGoods("league") or {}
    goodsData = {}
    local shopTableName = "shopLeague"
    local shopD = clone(tab[shopTableName])
    -- dump(shopD,"shopD....")
    for k,gridD in pairs(shopD) do
        local itemId = gridD.itemId[1]
        gridD.itemId = itemId
        gridD.shopBuyType = "league"
        gridD.canBuyTimes = gridD.buyTimes
        goodsData[tonumber(gridD.grid[1])] = gridD
    end
    -- dump(shopData,"shopD)))))")
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    for pos,data in pairs(shopData) do
        pos = tonumber(pos)
        if goodsData[pos] then
            goodsData[pos].canBuyTimes = data.buyTimes or 0
            goodsData[pos].lastBuyTime = data.lastBuyTime 
            local recover = goodsData[pos].recover
            local add = math.floor((nowTime-data.lastBuyTime)/recover)
            goodsData[pos].canBuyTimes = math.min(data.buyTimes + add,goodsData[pos].buyTimes)
            -- dump(goodsData[pos],"pos..." .. pos)
        end
    end

    return goodsData
end

function LeagueShopView:reflashShopInfo()
    local shopInfo = self._shopModel:getShopGoods("league")
    if not shopInfo then return end
    -- self._scrollView:removeAllChildren()
    self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
    local leagueCoin = self._modelMgr:getModel("UserModel"):getData().leagueCoin or 0
    self._refreshTimeLab:setString(leagueCoin)


    self._goodData = self:getGoodsData()
    local goodsData = self._goodData
    -- dump(goodsData,"商店详情",10)
    if not goodsData then 
        return 
    end
    local goodsNum = #goodsData
    local itemSizeX,itemSizeY = 186,192
    local offsetX,offsetY = 5,-4
    local row =math.ceil(#goodsData/4) --2--
    local col = 4-- math.ceil(#goodsData/2)

    local boardHeight = math.ceil(#goodsData/4)*itemSizeY
    local scrollHeight = self._scrollView:getContentSize().height
    if boardHeight < scrollHeight then
        boardHeight = scrollHeight 
        self._downArrow:setVisible(false)
    else
        self._downArrow:setVisible(true)
        self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,boardHeight))
    end
    -- local boardWidth = math.ceil(#goodsData/2)*itemSizeX
    -- if boardWidth > self.scrollViewW then
    --     self._scrollView:setInnerContainerSize(cc.size(boardWidth+20,self.scrollViewH))
    --     self:showArrow("right")
    -- end
    local x,y = 0,0
    local goodsCount = math.max(8,row*col)
    -- self:lock()
    local goodsIdx = 1
    -- dump(goodsData)
    local curRank = self._modelMgr:getModel("LeagueModel"):getCurZone()

    for i=1,goodsCount do
        -- x = math.floor((i-1)/row)*itemSizeX+offsetX
        -- y = self.scrollViewH/2 - (i-1)%row*itemSizeY+offsetY
        x = (i-1)%col*itemSizeX+offsetX
        y = boardHeight - (math.floor((i-1)/col) + 1)*itemSizeY+offsetY - 1
        if i <= goodsNum then 
            local limitRank = tab.shopLeague[i].openrank
            if not self._nextOpenIdx and curRank < limitRank then
                self._nextOpenIdx = i
            end

            if goodsData[i] and curRank >= limitRank then           
                self:createItem( i,goodsData[i],x,y)
            else
                self:createGrid(x,y,i,goodsData[i])-- i记录pos值跟shopView不通用
            end
        else
            self:createEmptyGrid(x,y,i)-- 补位格子
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
end

function LeagueShopView:updateShopItem()
    self._goodData = self:getGoodsData("league")
    local goodsData = self._goodData
    if not goodsData then 
        return 
    end
    if not self._itemTable or table.nums(self._itemTable) == 0 then 
        return
    end
    local goodsCount = table.getn(goodsData)
    local haveNum = 0
    local costNum = 0
    local player = self._modelMgr:getModel("UserModel"):getData()   
    for i=1,goodsCount do
        local data = goodsData[i]
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
    self._downArrow:setVisible(goodsCount > 8)
end

local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function LeagueShopView:createItem(index, data,x,y)
    -- dump(data)
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
        item:setPosition(x+190/2,y+200/2)
    end
    item:setScaleAnim(false)
    local itemId = self._modelMgr:getModel("LeagueModel"):changeLeagueHero2ItemId(data.itemId)
    itemId = tonumber(itemId)
    if not itemId then
        itemId = IconUtils.iconIdMap[data.itemId]
    end
    local toolD = tab:Tool(itemId)
    local canTouch = data.canBuyTimes ~= 0
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
    icon:setPosition(10,20)
    icon:setScale(0.65)
    itemIcon:addChild(icon)
    -- 设置名称
    local itemName = item:getChildByFullName("itemName")
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
    local priceLab = item:getChildByFullName("priceLab")
    -- priceLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- priceStr = string.format("% 6d",costNum)
    priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
    if haveNum <costNum then
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

    UIUtils:center2Widget(buyIcon,priceLab,itemW/2,5)
    
    self:registerClickEvent(item, function( )
        local canTouch = data.canBuyTimes ~= 0
        if canTouch then
            self._refreshAnim = nil
            self._offsetY = self._scrollView:getInnerContainer():getPositionY()
            local param = {shopData = data,closeCallBack=function ( ... )
                -- self._isBuyBack = true
            end}
            self._viewMgr:showDialog("shop.DialogShopBuy",param,true)
        else
            self._viewMgr:showTip(lang("GODWARSHOPTIPS_3"))
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
    
    

    -- 添加红点
    local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(data.itemId)
    local needCount = self._needItems[itemId] or 0
    
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

    -- 修正信息
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    -- dump(data,"leagueshop data....")
    local shopInfo = self._shopModel:getShopGoods("league")[tostring(data.id)]
    if shopInfo then
        local add = math.floor((nowTime- shopInfo.lastBuyTime)/data.recover)
        local canBuyTimes = shopInfo.buyTimes
        data.buyTimes = tab:ShopLeague(data.id).buyTimes 
        data.canBuyTimes = math.min(canBuyTimes + add,data.buyTimes)
        data.lastBuyTime = shopInfo.lastBuyTime
    end
    
    -- 数量控制
    local canBuyCountLab = item:getChildByName("canBuyCount")
    local timeLab = item:getChildByName("timeLab")
    local canBuyLab = item:getChildByName("canBuyLab")
    if not self._timeLabs[index] then
        timeLab.preUpTime = data.lastBuyTime or 0
        timeLab.recover = data.recover
        timeLab.data = data
        self._timeLabs[index] = timeLab
    end

    if data.canBuyTimes >= data.buyTimes then 
        canBuyLab:setVisible(true)
        canBuyLab:setString("兑换次数:".. data.buyTimes .. "/" .. data.buyTimes)
        -- canBuyLab:setColor(cc.c3b(240, 240, 0))
        -- canBuyLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

        timeLab:setVisible(false)
        timeLab.updating = false -- 状态是否更新
        canBuyCountLab:setVisible(false)
    else
        canBuyLab:setVisible(false)
        timeLab:setVisible(true)
        timeLab.preUpTime = data.lastBuyTime or 0
        timeLab.updating = true
        -- timeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        canBuyCountLab:setVisible(true)
        -- canBuyCountLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        if data.canBuyTimes == 0 then
            canBuyCountLab:setColor(cc.c3b(255, 23, 23))
            canBuyCountLab:setString("0/" .. data.buyTimes)
        else
            canBuyCountLab:setString(data.canBuyTimes .. "/" .. data.buyTimes)
            canBuyCountLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        end
        self:updateTimeLab()
    end
end

function LeagueShopView:updateTimeLab( )
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    for index,timeLab in pairs(self._timeLabs) do
        if timeLab.updating then
            local deltTime = timeLab.recover - (nowTime - timeLab.preUpTime)%timeLab.recover
            if deltTime <= 1 then
                -- self:reflashUI()
                if timeLab.data then
                    dump(timeLab.data)
                    local add = math.floor((nowTime- timeLab.data.lastBuyTime)/timeLab.recover)
                    local buyTimes = self._shopModel:getShopGoods("league")[tostring(timeLab.data.id)].buyTimes
                    timeLab.data.canBuyTimes = buyTimes + add
                    self:createItem(index,timeLab.data)
                end
            else
                -- print(index,"idx,updating?",deltTime,timeLab.updating,"timeLab.preUpTime",timeLab.preUpTime)
                timeLab:setString(string.format("%02d:%02d:%02d",math.floor(deltTime/3600),math.floor(deltTime%3600/60),deltTime%60))
            end
        end
    end
end

local sentMsgCount = 2
-- 创建空格子
function LeagueShopView:createGrid(x,y,pos,data )
    local item = ccui.ImageView:create()
    item:loadTexture("globalPanelUI7_cellBg1.png",1)
    item:setScale9Enabled(true)
    -- item:setCapInsets(cc.rect(41,40,0,0))
    item:setContentSize(cc.size(190,200))
    local shopGridFrame = ccui.ImageView:create()
    shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    shopGridFrame:setName("shopGridFrame")
    shopGridFrame:setContentSize(cc.size(98, 98))
    shopGridFrame:setAnchorPoint(cc.p(0.5,0.5))
    shopGridFrame:setPosition(cc.p(95,110))
    shopGridFrame:setScale(0.65)
    item:addChild(shopGridFrame,2)
    local shopGridBg = ccui.ImageView:create()
    shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    shopGridBg:setName("shopGridBg")
    shopGridBg:setContentSize(cc.size(95, 97))
    shopGridBg:setAnchorPoint(cc.p(0.5,0.5))
    shopGridBg:setScale(0.62)
    shopGridBg:setPosition(cc.p(93,108))
    item:addChild(shopGridBg,1)

    -- 加装饰条
    local decorateImg = self._item:getChildByFullName("bottomDecorate")
    if decorateImg then
        local decImg = decorateImg:clone()
        item:addChild(decImg,0)
        decImg:setPosition(95,33)
    end

    local itemId = tonumber(data.itemId)
    if not itemId then
        itemId = IconUtils.iconIdMap[data.itemId]
    end
    local toolD = tab:Tool(itemId)
    if self._nextOpenIdx == pos then
        local num = data.num 
            if num == 1 then 
                num = nil
            end
        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,effect=true,num = num,eventStyle = 0})
        icon:setContentSize(cc.size(100, 100))
        icon:setScale(0.65)
        icon:setPosition(cc.p(item:getContentSize().width/2-32,item:getContentSize().height/2-22))
        item:addChild(icon,2)
    end    

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setName("lock")
    lock:setPosition(cc.p(item:getContentSize().width/2-2,item:getContentSize().height/2+10))
    item:addChild(lock,3)
    
    item:setAnchorPoint(0,0)
    item:setPosition(x,y)
    self._scrollView:addChild(item)
    local low,high
    
    local vipLevel
    
    local title = ccui.Text:create()
    title:setFontName(UIUtils.ttfName)
    title:setAnchorPoint(cc.p(0.5,0.5))
    title:setFontSize(20)
    title:setName("stage")
    -- title:setColor(cc.c3b(255, 255, 255))
    title:setPosition(item:getContentSize().width/2,item:getContentSize().height-25)
    title:setFontName(UIUtils.ttfName)
    -- title:setString("未开启")
    if self._nextOpenIdx == pos then
        title:setString( toolD and lang(toolD.name) or "没有名字")
        -- title:setColor(UIUtils.colorTable["ccUIBaseColor" .. toolD.color])
    else
        title:setString("暂未开启")
    end
    title:setColor(UIUtils.colorTable["ccUIBaseTextColor2"])
    -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    item:addChild(title,99)

    local canBuyTimesLab = ccui.Text:create()
    canBuyTimesLab:setFontName(UIUtils.ttfName)
    canBuyTimesLab:setAnchorPoint(cc.p(0.5,0.5))
    canBuyTimesLab:setFontSize(24)
    canBuyTimesLab:setName("stage")
    -- canBuyTimesLab:setColor(cc.c3b(255, 255, 255))
    canBuyTimesLab:setPosition(cc.p(item:getContentSize().width/2,item:getContentSize().height-40))
    canBuyTimesLab:setFontName(UIUtils.ttfName)
    title:setColor(UIUtils.colorTable["ccUIBaseTextColor2"])
    item:addChild(canBuyTimesLab,99)
    local limitRank = tab.shopLeague[pos or 1].openrank
    local rtxStr = "[color = 3c3c3c,fontSize = 20][-][color = 3c3c3c,fontSize = 20]" .. lang(tab.leagueRank[limitRank] and tab.leagueRank[limitRank].name or "新手")  .. "段位开启[-][color = 3c3c3c,fontSize = 20][-]"
    local rtx = RichTextFactory:create(rtxStr,200,40)
    rtx:formatText()
    -- rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(cc.p(item:getContentSize().width/2+1,20+h/2))
    -- rtx:setScale(0.8)
    item:addChild(rtx)
    UIUtils:alignRichText(rtx)
    self:setNodeColor(item,cc.c4b(182, 182, 182,255))
end

-- 创建未开启补位格子
function LeagueShopView:createEmptyGrid(x,y,index)

    local item = ccui.ImageView:create()
    item:loadTexture("globalPanelUI7_cellBg1.png",1)
    item:setScale9Enabled(true)
    -- item:setCapInsets(cc.rect(41,40,0,0))
    item:setContentSize(cc.size(190,200))
    item:setAnchorPoint(0,0)

    local name = ccui.Text:create()
    name:setFontName(UIUtils.ttfName)
    name:setAnchorPoint(cc.p(0.5,0.5))
    name:setFontSize(20)    
    name:setString("暂未开启")
    name:setPosition(100,172)
    name:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    item:addChild(name,10)

    local posx = item:getContentSize().width*0.5
    local posy = item:getContentSize().height*0.5+2
    local lineImg = ccui.ImageView:create()
    lineImg:loadTexture("globalImageUI12_cutline3.png", 1)
    lineImg:setPosition(posx+3,posy+54)
    item:addChild(lineImg,1)
    local shopGridFrame = ccui.ImageView:create()
    shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    shopGridFrame:setName("shopGridFrame")
    shopGridFrame:setContentSize(cc.size(95, 97))
    shopGridFrame:setAnchorPoint(0.5,0.5)
    shopGridFrame:setScale(0.65)
    shopGridFrame:setPosition(posx+3,posy+7)
    item:addChild(shopGridFrame,2)
    local shopGridBg = ccui.ImageView:create()
    shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    shopGridBg:setName("shopGridBg")
    shopGridBg:setContentSize(cc.size(95, 97))
    shopGridBg:setAnchorPoint(0.5,0.5)
    shopGridBg:setScale(0.62)
    shopGridBg:setPosition(posx+3,posy+7)
    item:addChild(shopGridBg,1)

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setName("lock")
    lock:setPosition(posx,posy+7)
    -- lock:setScale(0.85)
    item:addChild(lock,3)
    self._scrollView:addChild(item)
    item:setPosition(x,y)

    -- 置灰显示
    self:setNodeColor(item,cc.c4b(182, 182, 182,255))
end

-- 灰态
function LeagueShopView:setNodeColor( node,color )
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

function LeagueShopView:sendGetShopInfoMsg( shopName )
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = shopName}, true, {}, function(result)
        if result.shop["league"] and  
            result.shop["league"].lastUpTime and 
            result.shop["league"].lastUpTime > self._nextRefreshTime then 
            self._nextRefreshTime = self._shopModel:getShopRefreshTime("league")
        end
    end)
end

function LeagueShopView:sendReFreshShopMsg( shopName )
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local lastUpTime = self._shopModel:getShopByType("league").lastUpTime
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
    local times = self._shopModel:getShopByType("league").reflashTimes or 0
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

    local cost = tab:ReflashCost(times)["shopLeague"]
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
            self._serverMgr:sendMsg("ShopServer", "reflashShop", {type = "league"}, true, {}, function(result) 
            end)
        end})
    end
    
end

function LeagueShopView:resetOffsetY()
    self._offsetY = nil
end
return LeagueShopView