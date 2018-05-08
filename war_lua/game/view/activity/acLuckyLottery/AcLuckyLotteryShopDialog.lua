--
-- Author: huangguofang
-- Date: 2018-03-19 15:35:38
--

local AcLuckyLotteryShopDialog = class("AcLuckyLotteryShopDialog",BasePopView)

local _costType = "soulRime"

function AcLuckyLotteryShopDialog:ctor(param)
    AcLuckyLotteryShopDialog.super.ctor(self)
	self._goodsNode = {}
	self._shopModel = self._modelMgr:getModel("ShopModel")
	self._runeLotteryModel = self._modelMgr:getModel("RuneLotteryModel")
	self._userModel = self._modelMgr:getModel("UserModel")
    self._grids = {}
    self._items = {}
end

function AcLuckyLotteryShopDialog:onInit()
	local closeBtn = self:getUI("bg.mainBg.closeBtn")
	self:registerClickEvent( closeBtn, function()
		self:close()
	end)

    self._serverData = self._runeLotteryModel:getLotteryData() or {}
	self._shopTbData = self._runeLotteryModel:getShopData()
	
	self._scroll = self:getUI("bg.mainBg.scrollView")
	self._scrollItem = self:getUI("bg.item")
	self._scrollItem:setVisible(false)
	
	
	local mainBg = self:getUI("bg.mainBg")
	self._downArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._downArrow:setPosition(mainBg:getContentSize().width*0.5,58)
    self._downArrow:setRotation(90)
    self._downArrow:setVisible(false)
    mainBg:addChild(self._downArrow, 1)
    self._scroll:addEventListener(function(sender, eventType)
        if eventType == 6 or eventType == 1 then
            self._downArrow:setVisible(false)
        else
			local innerContainerHeight = self._scroll:getInnerContainerSize().height
			local contentHeight = self._scroll:getContentSize().height
            self._downArrow:setVisible(innerContainerHeight>contentHeight)
        end
    end)
	
	self._userData = self._userModel:getData()
	self._haveNum = self:getUI("bg.mainBg.backTexture.haveNum")
	self._haveNum:setString(self._userData[_costType] or 0)
	
	local resImg = self:getUI("bg.mainBg.backTexture.costImg")--设置图片icon
	resImg:loadTexture(IconUtils.resImgMap[_costType], 1)
	
	self:createShopItem()

	self:listenReflash("UserModel", function()
        self:updateShopItem()
    end)
end


function AcLuckyLotteryShopDialog:createShopItem()
	local tbItem = self._shopTbData
	
	local itemSizeX,itemSizeY = 180,192
	local offsetX,offsetY = 0,0
	
	local row = math.ceil(#tbItem/4)
	local col = 4 

	local containerHeight = row*itemSizeY
	local scrollWidth = self._scroll:getContentSize().width
	self._scroll:setBounceEnabled(row>2)
	self._scroll:setInnerContainerSize(cc.size(scrollWidth, containerHeight))
	self._scroll:jumpToTop()
	if containerHeight>self._scroll:getContentSize().height then
		self._downArrow:setVisible(true)
	end
	for i,v in pairs(self._grids) do
		v:removeFromParent()
        v = nil
	end
	for i=1,8 do
		local itemData = tbItem[i]
		x = (i-1) % col * itemSizeX + offsetX + itemSizeX * 0.5
        y = containerHeight/2 - math.floor((i-1)/col) * itemSizeY + offsetY + itemSizeY * 0.5
		if itemData then
			self:createItem( i, itemData, x, y )
		else
			self:createGrid(x, y, i)
		end
	end
	
end

function AcLuckyLotteryShopDialog:updateShopItem()
    self._haveNum:setString(self._userData[_costType] or 0)
    local goodsData = self._shopTbData
    self._serverData = self._runeLotteryModel:getLotteryData() or {}
    if not goodsData or next(goodsData) == nil then 
        return 
    end
    if not self._items or table.nums(self._items) == 0 then 
        return
    end

    local goodsCount = table.getn(goodsData)
    local userData = self._userData
    local buyData = self._serverData.buy or {}
    for i=1, goodsCount do
        data = goodsData[i]
        local costType = data.costNum[1]
        local costNum = data.costNum[3]
        haveNum = userData[costType] or 0

        --soldout
        local item = self._items[i]
        
        -- 花费
        if not tolua.isnull(self._items[i]) then
            local buyCount = data.buyLottery
            local buyNum = buyData[tostring(data.id)] or 0
            local soldOut = item:getChildByFullName("soldOut")
            soldOut:setVisible(false)
            self:setNodeColor(item, cc.c4b(255, 255, 255,255), true)
            if not buyCount then
                local soldOut = item:getChildByFullName("soldOut")
                soldOut:setVisible(false)
            else
                -- 有次数兑换，根据次数判断是否可以兑换
                if buyNum >= tonumber(buyCount) then
                    soldOut:setVisible(true)
                    self:setNodeColor(item, cc.c4b(128, 128, 128,255),nil,true)
                    exchangeBtn = item:getChildByFullName("exchangeBtn")
                    if exchangeBtn then
                        self:registerClickEvent(exchangeBtn, function(sender)
                            self._viewMgr:showTip("兑换次数已用尽！")
                        end)
                    end
                end
            end 
            local priceLab = self._items[i]:getChildByFullName("costNum")
            if priceLab then 
                priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
                if haveNum < costNum then
                    priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
                else
                    priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
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
function AcLuckyLotteryShopDialog:createItem(index, data, x, y)
    local item = self._items[index]
    if not item then
        item = self._scrollItem:clone()  
        self._scroll:addChild(item)
    end  

    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end

    -- 商店格子不放大 
    item:setScaleAnim(false)    
    self._items[index] = item
    item:setSwallowTouches(false)
    item:setName("item"..index)
    item:setVisible(true)
    item:setPosition(x,y)

    local reward = data.itemId
    local rType = reward[1]
    local itemId = reward[2]
    local icon
    local itemData 

    if type(reward[2]) == "string" then
        local dataTemp = itemType[tonumber(acOpenId)]
        itemId = dataTemp[reward[2]][2]
        rType = dataTemp[reward[2]][1]
        -- print("===========reward[2]===",reward[2])
    end

    if rType == "tool"then
        local toolD = tab:Tool(tonumber(itemId))
        itemData = toolD
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = reward[3]})
    elseif rType == "rune" then
        -- print("==================itemId====",itemId)
        itemData = tab:Rune(itemId)
        icon =IconUtils:createHolyIconById({suitData = itemData,isTouch=true})

    else
        itemId = IconUtils.iconIdMap[rType]
        local toolD = tab:Tool(tonumber(itemId))
        itemData = toolD
        icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = reward[3]})
        
    end
    --icon
    local itemIcon = item:getChildByFullName("itemIcon")
    itemIcon:setSwallowTouches(false)
    itemIcon:removeAllChildren()
   	icon:setContentSize(80, 80)
    icon:setScale(0.8)
    itemIcon:addChild(icon)

    -- name
    local itemName = item:getChildByFullName("itemName")
    itemName:setString(lang(itemData.name) or "没有名字")
    itemName:setFontName(UIUtils.ttfName)
    itemName:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)

    --cost
    local userData = self._userData
    local costType = data.costNum[1]
    
    local haveNum = userData[costType] or 0
    local costNum = data.costNum[3]
   
    local priceLab = item:getChildByFullName("costNum")
    priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
    if haveNum < costNum then
        priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    end

    -- costIcon
    local buyIcon = item:getChildByFullName("costImg")
    buyIcon:loadTexture(IconUtils.resImgMap[costType], 1)

    local scaleNum = math.floor((28 / buyIcon:getContentSize().width) * 100)
    buyIcon:setScale(scaleNum / 100)

    local iconW = buyIcon:getContentSize().width * scaleNum / 100
    local labelW = priceLab:getContentSize().width
    local itemW = item:getContentSize().width - 5
    buyIcon:setPositionX(itemW / 2 - labelW / 2 - 3)
    priceLab:setPositionX(itemW / 2 + iconW / 2 - labelW / 2 - 3)

    UIUtils:center2Widget(buyIcon, priceLab, itemW/2, 5)

    --discount
    local discountBg = item:getChildByFullName("discountImg")
    if data.discount and data.discount > 0 then
        local color = "r"
        if data.discount > 5 then 
            color = "p"
        end
        discountBg:loadTexture("globalImageUI6_connerTag_" .. color ..".png",1)

        local discountLab = discountBg:getChildByFullName("discountLab")
        discountLab:setFontName(UIUtils.ttfName)
        discountLab:setRotation(41)
        discountLab:setFontSize(20)
        discountLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        discountLab:setString(discountToCn[data.discount])
        discountBg:setVisible(true)
    else
        discountBg:setVisible(false)
    end

    --click
    item._data = data
    local exchangeBtn = item:getChildByFullName("exchangeBtn")
    exchangeBtn._data = data
    self:registerClickEvent(exchangeBtn, function(sender)
        -- 
        print("================兑换商品================")
        self:exchangeItem(sender)
    end)

    --soldout
    local buyData = self._serverData.buy or {}
    local buyCount = data.buyLottery
    local buyNum = buyData[tostring(data.id)] or 0
    local soldOut = item:getChildByFullName("soldOut")
    soldOut:setVisible(false)
    self:setNodeColor(item, cc.c4b(255, 255, 255,255), true)
    if not buyCount then
        local soldOut = item:getChildByFullName("soldOut")
        soldOut:setVisible(false)
    else
        -- 有次数兑换，根据次数判断是否可以兑换
        if buyNum >= tonumber(buyCount) then
            soldOut:setVisible(true)
            self:setNodeColor(item, cc.c4b(128, 128, 128,255),nil,true)
            self:registerClickEvent(exchangeBtn, function(sender)
                self._viewMgr:showTip("兑换次数已用尽！")
            end)
        end
    end 
end

-- 创建空格子
function AcLuckyLotteryShopDialog:createGrid(posX, posY, index)
    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end
    print("========posX,posY====",posX,posY)
    local item 
    item = self._scrollItem:clone()
    item:setVisible(true)
    item:setTouchEnabled(false)
    self._grids[index] = item

    local name = item:getChildByFullName("itemName")
    local diamondImg = item:getChildByFullName("costImg")
    local discountBg = item:getChildByFullName("discountImg")
    local priceLab = item:getChildByFullName("costNum")
    name:setVisible(false)
    diamondImg:setVisible(false)
    discountBg:setVisible(false)
    priceLab:setVisible(false)

    self._scroll:addChild(item)
    -- item:setAnchorPoint(0,0)
    item:setPosition(posX,posY)
end

function AcLuckyLotteryShopDialog:exchangeItem(sender)
    if not self._runeLotteryModel:isLotteryOpen() then
        self._viewMgr:showTip("幸运夺宝活动已结束")
        return
    end
	local data = sender._data
    local costType = data.costNum[1]    
    local haveNum = self._userData[costType] or 0
    local costNum = data.costNum[3]
    -- print(costType,haveNum,"====================",costNum,self._userData[_costType])
    if haveNum < costNum then
    	self._viewMgr:showTip("灵魂结晶不足！")
    else
    	self._serverMgr:sendMsg("RuneLotteryServer", "buyRune", {id=data.id}, true, {}, function(data)
            if data["reward"] then 
                DialogUtils.showGiftGet({ gifts = data["reward"], hide = self, callback = function()                    
                    
                end,notPop = false})
            end 
        end) 
    end
end

-- 灰态
function AcLuckyLotteryShopDialog:setNodeColor( node,color,notDark,isGray)
    -- if true then return end
    if node and not tolua.isnull(node) and node:getName() ~= "lock" then 
        if isGray then
            node:setHue(10)
            node:setSaturation(-80)
        else
            node:setHue(0)
            node:setSaturation(0)
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
        
    end
    local children = node:getChildren()
    if children == nil or #children == 0 then
        return 
    end
    for k,v in pairs(children) do
        self:setNodeColor(v,color,notDark)
    end
end


return AcLuckyLotteryShopDialog