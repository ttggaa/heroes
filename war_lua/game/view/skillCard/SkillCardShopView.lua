--[[
    Filename:    SkillCardShopView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-02-03 21:04:58
    Description: File description
--]]


local SkillCardShopView = class("SkillCardShopView",BasePopView)
local resKey = "skillBookCoin"
local requestKey = "skillbook"
local playerData

function SkillCardShopView:ctor(param)
    SkillCardShopView.super.ctor(self)
    self._shopModel = self._modelMgr:getModel("ShopModel")
    self._spbModel = self._modelMgr:getModel("SpellBooksModel")
    self._timeLabs = {} 
    self._itemTable = {}
    playerData = self._modelMgr:getModel("UserModel"):getData()
    self._callBack = param and param.callBack
    self._vipModel = self._modelMgr:getModel("VipModel")
end

function SkillCardShopView:onInit()
    self:registerClickEventByName("bg.mainBg.closeBtn", function ()
        self:close()
        if self._callBack then
            self._callBack()
        end
        UIUtils:reloadLuaFile("skillCard.SkillCardShopView")
    end)
    self._mainBg = self:getUI("bg.mainBg")
    self._scrollView = self:getUI("bg.mainBg.scrollView")
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height

    self._item = self:getUI("bg.item")
    self._item:setVisible(false)
    local priceLab = self._item:getChildByFullName("priceLab")
    priceLab:setAnchorPoint(cc.p(0,0.5))

    self:listenReflash("ShopModel", self.reflashShopInfo)
    self:listenReflash("UserModel", function( )
        self:updateShopItem()
    end)

    self._costImg = self:getUI("bg.mainBg.backTexture.costImg")
    self._costImg:loadTexture("globalImageUI_keyin1.png",1)
    self._refreshTimeLab = self:getUI("bg.mainBg.backTexture.refreshTimeLab")
    self._backTexture = self:getUI("bg.mainBg.backTexture")

    local title = self:getUI("bg.mainBg.titleBg.title")
    UIUtils:setTitleFormat(title,1)

    -- 每日五点刷新
    self:registerTimer(5,0,1,function(  )
        self:sendGetShopInfoMsg(requestKey)
    end)


    self._costLable = self:getUI("bg.mainBg.cost")
    -- self._costLable:setColor(UIUtils.colorTable.ccUIBaseColor9)
    self._refreshCostImage = self:getUI("bg.mainBg.costIma")
    self._refreshBtn = self:getUI("bg.mainBg.refresh")
    self._refreshCostbg = self:getUI("bg.mainBg.refreshCostbg")

    self:registerClickEvent(self._refreshBtn, function( )
        self:sendReFreshShopMsg()
    end)

end


function SkillCardShopView:sendReFreshShopMsg( shopName )
    shopName = "skillbook"

    self._refreshAnim = true
    local cost,costType = self._shopModel:getRefreshCost("skillbook")
    local haveNum = playerData[costType] or 0
    local times = self._shopModel:getShopByType(shopName).reflashTimes or 0
    local vip = self._vipModel:getData().level or 0
    local vipLimt = tab.vip[vip].refleshSkillBook

    print("times",times,"vipLimt",vipLimt)
    if times >= vipLimt then
        if vip < #tab.vip then
            DialogUtils.showNeedCharge({desc = lang("REFRESH_TREASURE_SHOP"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 1})
            end})
        else
            self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP_MAX"))
        end
        return
    end
    if cost > haveNum then
        if costType == "gem" then
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_" .. string.upper(costType)),callback1=function( )
                self._viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        end
        self._refreshAnim = nil
        return
    else

        DialogUtils.showBuyDialog({costNum = cost,costType = costType,goods = "刷新一次",callback1 = function( )      
            audioMgr:playSound("Reflash")
            self._serverMgr:sendMsg("ShopServer", "reflashShop", {type = "skillbook", true, {}, function(result)

            end})
        end})
    end
end

function SkillCardShopView:onDestroy( )
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
    self._modelMgr:clearSelfTimer(self)
    SkillCardShopView.super.onDestroy(self)
end

-- 接收自定义消息
function SkillCardShopView:reflashUI(data)
    self:reflashShopInfo()
end

function SkillCardShopView:reflashShopInfo()
    self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
    local skillBookCoin = self._modelMgr:getModel("UserModel"):getData().skillBookCoin or 0
    self._refreshTimeLab:setString(skillBookCoin)

    --法术数据
    self._spbInfo = self._spbModel:getData()

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
    local itemSizeX,itemSizeY = 181,193
    local offsetX,offsetY = -20,-11
    local row =2 --2--
    local col = math.ceil(#goodsData/2)

    local boardWidth = math.ceil(#goodsData/2)*itemSizeX
    -- if boardWidth > self.scrollViewW then
    --     self._scrollView:setInnerContainerSize(cc.size(boardWidth-20,self.scrollViewH))
        
    --     -- self:showArrow("right")
    -- else

    -- end

    if col > 8 then
        self._scrollView:setBounceEnabled(true)
        self._scrollView:setInnerContainerSize(cc.size(boardWidth-10,self.scrollViewH))
    else
        self._scrollView:setBounceEnabled(false)
        self._scrollView:setInnerContainerSize(cc.size(boardWidth-20,self.scrollViewH))
    end

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
    local goodsCount = row*col
    -- self:lock()
    local goodsIdx = 1
    -- dump(goodsData)
    -- local curRank = self._modelMgr:getModel("LeagueModel"):getCurZone()
    for i=1,goodsCount do
        x = (i-1)%col*itemSizeX+offsetX + 15
        y = self.scrollViewH/2 - math.floor((i-1)/col)*itemSizeY+offsetY + 15
        if not self._nextOpenIdx then
            self._nextOpenIdx = i
        end

        if goodsData[i] then           
            self:createItem( i,goodsData[i],x,y)
        else
            -- self:createGrid(x,y,i,goodsData[i])
        end
    end
    -- self:unlock()
    self:refreshRefresBtnCost()
end

-- 按类型返回商店数据
function SkillCardShopView:getGoodsData(tp)
    -- local goodsData = {}
    local shopData = self._shopModel:getShopGoods("skillbook") or {}
    dump(shopData,"SkillCardShopView:getGoodsData",10)
    local shopD = clone(tab.shopSkillBook)
    local result = {}
    -- local index = 1
    for index,data in pairs (shopData) do 
    	local id = data.id
    	local _data = shopD[tonumber(id)]
    	_data.buy = data.buy
    	_data.shopBuyType = "skillbook"
    	_data.itemId = tonumber(data.item) or 3403
        _data.id = tonumber(index)
    	result[tonumber(index)] = _data
    end


    return result
end

local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function SkillCardShopView:createItem(index, data,x,y)
    -- dump(data,"aaaaaaaaaaaaa",10)
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
        item:setPosition(x+item:getContentSize().width/2,y+item:getContentSize().height/2)
    end
    local itemBg = item:getChildByFullName("itemBg")
    local bottomDecorate = item:getChildByFullName("bottomDecorate")
    local splitDec = item:getChildByFullName("splitDec")
    -- local itemBgNb = item:getChildByFullName("itemBgNb")

    -- if data.gridType == 1 then
    --     itemBg:setVisible(true)
    --     -- itemBgNb:setVisible(true)
    --     bottomDecorate:setVisible(false)
    --     splitDec:setVisible(false)
    -- else
    --     itemBg:setVisible(true)
    --     -- itemBgNb:setVisible(false)
    --     bottomDecorate:setVisible(true)
    --     splitDec:setVisible(true)
    -- end
    itemBg:setVisible(true)
    bottomDecorate:setVisible(true)
    splitDec:setVisible(true)

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

    -- item:getChildByFullName("bottomDecorate"):setOpacity(80)

    -- data.discount = 3
    local discountBg = item:getChildByFullName("discountBg")
    local discountLab = discountBg:getChildByFullName("discountLab")
    discountLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    if data.image == 1 then --显示超值页签
        discountBg:setVisible(true)
        discountBg:loadTexture("globalImageUI6_connerTag_p.png",1)
        discountLab:setString("超值")
    else
        discountBg:setVisible(true)
        local realSpellId = string.sub(tostring(data.itemId), 4, 20)
        local spInfo = self._spbInfo[realSpellId]
        if spInfo and next(spInfo) then
            if tonumber(spInfo.l) == 0 then
                discountBg:loadTexture("globalImageUI6_connerTag_r.png",1)
                discountLab:setString("未获得")
            elseif tonumber(spInfo.l) < 5 then
                discountBg:loadTexture("globalImageUI6_connerTag_p.png",1)
                discountLab:setString("未满级")
            else
                discountBg:setVisible(false)
            end
        else
            discountBg:loadTexture("globalImageUI6_connerTag_r.png",1)
            discountLab:setString("未获得")
        end
    end

    --[[
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
    --]]
    
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

    self:registerClickEvent(item, function( )
        if data.canBuyTimes == 0 and data.sortHero == 1 then
            self._viewMgr:showTip("你已购买过该服务")
        elseif canTouch then
            self._refreshAnim = nil
            -- dump(data,"datadatadatadatadata",10)
            self._viewMgr:showDialog("shop.DialogShopBuy",data,true)
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
function SkillCardShopView:createGrid(x,y,pos,data )
    local item = ccui.ImageView:create()
    -- if data.gridType == 1 then
    --     item:loadTexture("citybattle_nbGirl.png",1)
    -- else
        item:loadTexture("globalPanelUI7_cellBg1.png",1)
    -- end
    -- item:setScale9Enabled(true)
    -- item:setCapInsets(cc.rect(60,50,10,10))
    -- item:setContentSize(cc.size(211,209))
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
    shopGridBg:setContentSize(cc.size(98, 98))
    shopGridBg:setAnchorPoint(cc.p(0.5,0.5))
    shopGridBg:setScale(0.7)
    shopGridBg:setPosition(cc.p(100,115))
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
        icon:setScale(0.9)
        icon:setPosition(cc.p(item:getContentSize().width/2-37,item:getContentSize().height/2-20))
        item:addChild(icon,2)
    end
    

    local lock = ccui.ImageView:create()
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:setName("lock")
    lock:setPosition(cc.p(item:getContentSize().width/2,item:getContentSize().height/2+15))
    item:addChild(lock,3)
    
    item:setAnchorPoint(cc.p(0,0))
    item:setPosition(cc.p(x,y))
    self._scrollView:addChild(item)
    item:setAnchorPoint(cc.p(0,0))
    item:setPosition(cc.p(x,y))
    local low,high
    
    local vipLevel
    
    local title = ccui.Text:create()
    title:setFontName(UIUtils.ttfName)
    title:setAnchorPoint(cc.p(0.5,0.5))
    title:setFontSize(22)
    title:setName("stage")
    -- title:setColor(cc.c3b(255, 255, 255))
    title:setPosition(cc.p(item:getContentSize().width/2,item:getContentSize().height-35))
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
    local limitRank = tab.shopHeroDuel[pos or 1].openrank
    local rtxStr = "[color = 3c3c3c,fontSize = 20][-][color = 3c3c3c,fontSize = 20]" .. lang(tab.heroDuelRank[limitRank] and tab.heroDuelRank[limitRank].name or "新手")  .. "段位开启[-][color = 3c3c3c,fontSize = 20][-]"
    local rtx = RichTextFactory:create(rtxStr,200,40)
    rtx:formatText()
    -- rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(cc.p(item:getContentSize().width/2,27+h/2))
    -- rtx:setScale(0.8)
    item:addChild(rtx)
    UIUtils:alignRichText(rtx)
    self:setNodeColor(item,cc.c4b(128, 128, 128,255))
end
-- 灰态
function SkillCardShopView:setNodeColor( node,color,notDark )
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

function SkillCardShopView:sendGetShopInfoMsg( shopName )
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = shopName}, true, {}, function(result)

    end)
end

--[[
    刷新消耗
]]
function SkillCardShopView:refreshRefresBtnCost()
    local cost = 0
    local costType = "gem"
    cost,costType = self._shopModel:getRefreshCost("skillbook")
    self._costLable:setString(cost)
    self._costLable:setVisible(true)
    local costRes = IconUtils.resImgMap[costType]
    if costRes and costRes ~= "" then
        self._refreshCostImage:loadTexture(costRes,1)
        self._refreshCostImage:setScale(0.8)
    end

    local times = self._shopModel:getShopByType("skillbook").reflashTimes or 0
    -- if times >= maxRefreshTimes then
    --     UIUtils:setGray(self._refreshBtn,true)
    --     self._refreshCostImage:setVisible(false)
    --     self._costLable:setVisible(false)
    --     self._refreshCostbg:setVisible(false)
    --     self._refreshBtn:setTitleText("次数用尽")
    -- else
    --     UIUtils:setGray(self._refreshBtn,false)
    --     self._refreshCostImage:setVisible(true)
    --     self._costLable:setVisible(true)
    --     self._refreshCostbg:setVisible(true)
    --     self._refreshBtn:setTitleText("刷新")
    -- end
    self._refreshCostImage:setVisible(true)
    self._costLable:setVisible(true)
    self._refreshCostbg:setVisible(true)
    self._refreshBtn:setTitleText("刷新")

    


end

-- 更新商店数据
function SkillCardShopView:updateShopItem()
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


return SkillCardShopView