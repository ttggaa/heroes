--[[
    Filename:    CrossShopView.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2017-11-24 15:29:51
    Description: File description
--]]


local CrossShopView = class("CrossShopView",BaseLayer)

local l_shopType = "cp"

function CrossShopView:ctor(param)
    CrossShopView.super.ctor(self)
	self._goodsNode = {}
	self._shopModel = self._modelMgr:getModel("ShopModel")
    self._grids = {}
end

function CrossShopView:onInit()
	local closeBtn = self:getUI("bg.mainBg.closeBtn")
	self:registerClickEvent( closeBtn, function()
		self:close()
	end)
	
	self._scroll = self:getUI("bg.mainBg.scrollView")
	self._scrollItem = self:getUI("bg.item")
	self._scrollItem:setVisible(false)
	
	local refreshBtn = self:getUI("bg.mainBg.refresh")
	self:registerClickEvent(refreshBtn, function()
		self:refreshShop()
	end)
	
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
	
	self._refreshCostLabel = self:getUI("bg.mainBg.costNumLabel")
    self._refreshCostLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	self._refreshCostImg = self:getUI("bg.mainBg.costIma")
	
	self._resCountLabel = self:getUI("bg.mainBg.backTexture.refreshTimeLab")
	
	local resImg = self:getUI("bg.mainBg.backTexture.costImg")--设置图片icon
	resImg:loadTexture(IconUtils.resImgMap.cpCoin, 1)
	self:reflashShopGoodsData()
	
	self:reflashShopUserData()
	
 --    self:listenReflash("ShopModel", self.reflashShopGoodsData)
	-- self:listenReflash("UserModel", self.reflashShopUserData)
end
function CrossShopView:reflashUI(data)
	self:reflashShopGoodsData()
end
function CrossShopView:getGoodsData()
	local goods = self._shopModel:getShopGoods(l_shopType)
	local goodsData = clone(tab.cpShop)
	
	local tbItem = {}
	for i,v in ipairs(goodsData) do
--		local isAdd = false
		for _,data in pairs(goods) do
			if data.id==v.id then
				v.itemId = tonumber(data.item)
				v.buy = data.buy
				v.shopBuyType = "cp"
				table.insert(tbItem, v)
--				isAdd = true
				break
			end
		end
		--[[if not isAdd then
			table.insert(tbItem, v)
		end--]]
	end
	table.sort(tbItem, function(a, b)
		return a.grid[1]<b.grid[1]
	end)
	
	return tbItem
end

function CrossShopView:reflashShopGoodsData()
	local tbItem = self:getGoodsData()
	
	local itemSizeX,itemSizeY = 186,192
	local offsetX,offsetY = 17.5,13.5
	
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
	local k = 1
	local x
	local y
	for i,v in ipairs(clone(tab.cpShop)) do
		local itemData = tbItem[i]
		-- local col = i%4 == 0 and 4 or i%4
		-- x = (col-1)*itemSizeX+offsetX + 15
        -- y = containerHeight -  math.ceil(i/4)*itemSizeY +offsetY + 15

		x = (i-1)%col*itemSizeX+offsetX
		y = containerHeight - (math.floor((i-1)/col) + 1)*itemSizeY+offsetY - 1
--		if itemData.open==1 then
		self:createItem( i, itemData, x, y )
		--[[else
			self:createGrid(x, y, i)
		end--]]
	end
	self._refreshAnim = false
	if self._offsetY then
        local offsetY = self._offsetY
        local subHeight = self._scroll:getContentSize().height - containerHeight
        if subHeight < offsetY then
            self._scroll:getInnerContainer():setPositionY(offsetY)            
        else
            self._scroll:getInnerContainer():setPositionY(subHeight)
        end
        -- self._offsetY = nil
    end
	
	local cost,costType = self._shopModel:getRefreshCost(l_shopType)
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local haveNum = userData[costType] or 0
	self._refreshCostLabel:setColor(haveNum>=cost and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor6)
	self._refreshCostLabel:setString(cost)
	self._refreshCostImg:loadTexture(IconUtils.resImgMap[costType], 1)
end

function CrossShopView:createItem(index, itemData, posX, posY)
	local crossModel = self._modelMgr:getModel("CrossModel")
	
	local node
	if self._goodsNode[index] then
		node = self._goodsNode[index]
	else
		node = self._scrollItem:clone()
		node.nameLabel		= node:getChildByFullName("itemName")
		node.coinImg		= node:getChildByFullName("coinImg")
		node.iconBg		= node:getChildByFullName("itemIcon")
		node.soldOutImg	= node:getChildByFullName("soldOutImg")
		node.priceLabel	= node:getChildByFullName("priceLab")
		node.winBg		= node:getChildByFullName("itemBgNb")
		node.itemBg		= node:getChildByFullName("itemBg")
		node.underShadow	= node:getChildByFullName("bottomDecorate")
		node.lockImg		= node:getChildByFullName("lock")
		
        node:setPosition(posX+node:getContentSize().width/2, posY+node:getContentSize().height/2)
		node:setVisible(true)
		self._scroll:addChild(node)
		self._goodsNode[index] = node
	end
	if not itemData then
		node:setVisible(false)
		return
	else
		node:setVisible(true)
	end
	--设置属性
	node.winBg:setVisible(itemData.winopen==1)
	node.itemBg:setVisible(itemData.winopen==0)
	node.underShadow:setVisible(itemData.winopen==0)
	node.underShadow:setOpacity(80)
	
	node.coinImg:loadTexture(IconUtils.resImgMap[itemData.costType], 1)
	node.priceLabel:setString(itemData.costNum)
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local haveNum = userData[itemData.costType] or 0
	if haveNum < itemData.costNum then
		node.priceLabel:setColor(UIUtils.colorTable.ccUIBaseColor6)
	else
		node.priceLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	end
	
	local itemConfig = tab.tool[itemData.itemId]
	node.nameLabel:setString(lang(itemConfig.name))
	
	
	node.iconBg:setVisible(true)
	node.iconBg:setSwallowTouches(false)
	node.iconBg:removeAllChildren()
	local num = itemData.num
	if num == 1 then
		num = nil
	end
	local icon = IconUtils:createItemIconById({itemId = itemData.itemId, itemData = itemConfig, effect = false, num = num, eventStyle = 0})
	icon:setContentSize(cc.size(100, 100))
	icon:setScale(0.9)
	icon:setPosition(cc.p(0,0))
	node.iconBg:addChild(icon,2)
	
	local mc
	local iconColor = icon:getChildByName("iconColor")
	if iconColor then
		mc = iconColor:getChildByName("bgMc")
	end
	node:setEnabled(true)
	if itemData.buy==1 then--0为测试显示数据，1为正式数据
		node.soldOutImg:setVisible(true)
		node:setEnabled(false)
		self:setNodeColor(node, cc.c4b(182, 182, 182,255))
		self:setNodeColor(node.soldOutImg, cc.c4b(255, 255, 255,255))
		if mc then
			mc:setVisible(false)
		end
	else
		self:setNodeColor(node, cc.c4b(255, 255, 255,255), true)
		node.soldOutImg:setVisible(false)
		if mc then
			mc:setVisible(true)
		end
	end
	
	local matchState = crossModel:getOpenState()
	if itemData.winopen==1 then
		local _, mainServerId = crossModel:getServerId()
		local winnerServerId = self._shopModel:getShopByType(l_shopType).winner
		if tonumber(winnerServerId)==tonumber(mainServerId) then
			node.lockImg:setVisible(false)
			node.coinImg:setVisible(true)
			node.priceLabel:setVisible(true)
			if node.openWord then node.openWord:setVisible(false) end
		else
			local openWord = node:getChildByFullName("openWord")
			if not openWord then
				local rtxStr = "[color = 3c3c3c,fontSize = 18]获胜开启[-]"
				openWord= RichTextFactory:create(rtxStr,200,40)
				openWord:formatText()
				openWord:setName("openWord")
				local w = openWord:getInnerSize().width
				local h = openWord:getInnerSize().height
				openWord:setPosition(node:getContentSize().width/2+1,5+h/2)
				node:addChild(openWord)
				UIUtils:alignRichText(openWord)
			end
			node.openWord = openWord
			openWord:setVisible(true)
			
			node.coinImg:setVisible(false)
			node.priceLabel:setVisible(false)
			node:setEnabled(false)
			node.lockImg:setVisible(true)
			self:setNodeColor(node, cc.c4b(182, 182, 182,255))
		end
	else
		node.lockImg:setVisible(itemData.open~=1)
	end
	
--	node.iconBg:setVisible(itemData.buy==0)
	node:setScaleAnim(false)
	self:registerClickEvent(node, function()
		self:onShopItemClick(itemData)
		self._offsetY = self._scroll:getInnerContainer():getPositionY()
	end)
	
	if self._refreshAnim then
        local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", false, true,function( )
        end)
        mc:setScaleY(1.1)
        mc:setPosition(posX+80,posY+90)
        self._scroll:addChild(mc,9999)
    end
end

-- 创建空格子
function CrossShopView:createGrid(posX, posY, index)
    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end
    local node = self._scrollItem:clone()
	node.nameLabel		= node:getChildByFullName("itemName")
	node.coinImg		= node:getChildByFullName("coinImg")
	node.iconBg		= node:getChildByFullName("itemIcon")
	node.soldOutImg	= node:getChildByFullName("soldOutImg")
	node.priceLabel	= node:getChildByFullName("priceLab")
	node.winBg		= node:getChildByFullName("itemBgNb")
	node.itemBg		= node:getChildByFullName("itemBg")
	node.underShadow	= node:getChildByFullName("bottomDecorate")
	node.lockImg		= node:getChildByFullName("lock")
    node:setVisible(true)
    node:setTouchEnabled(false)
	
    self._grids[index] = node
    node.coinImg:setVisible(false)
    node.priceLabel:setVisible(false)
    node.underShadow:setVisible(false)
	node.winBg:setVisible(false)
    
    node.nameLabel:setString("暂未开启")
    node.nameLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    local posx = node:getContentSize().width*0.5
    local posy = node:getContentSize().height*0.5+2
    local shopGridFrame = ccui.ImageView:create()
    shopGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    shopGridFrame:setName("shopGridFrame")
    shopGridFrame:setContentSize(98, 98)
    shopGridFrame:setAnchorPoint(0.5,0.5)
    shopGridFrame:setPosition(posx+3,posy+5)
    shopGridFrame:setScale(85/shopGridFrame:getContentSize().width)
    node:addChild(shopGridFrame,2)
	
    local shopGridBg = ccui.ImageView:create()
    shopGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    shopGridBg:setName("shopGridBg")
    shopGridBg:setContentSize(100, 100)
    shopGridBg:setAnchorPoint(0.5,0.5)
    shopGridBg:setPosition(posx+3,posy+5)
    shopGridBg:setScale(80/shopGridBg:getContentSize().width)
    node:addChild(shopGridBg,1)

    node.lockImg:setVisible(true)
    self._scroll:addChild(node)
	node:setPosition(posX+node:getContentSize().width/2, posY+node:getContentSize().height/2)

    self:setNodeColor(node,cc.c4b(182, 182, 182,255))
end

function CrossShopView:onShopItemClick(itemData)
--	self._viewMgr:showTip("itemData.itemId = "..itemData.itemId)
	local param = {shopData = itemData,closeCallBack=function ( ... )
        self._isBuyBack = true
    end}
    self._viewMgr:showDialog("shop.DialogShopBuy",param,true)
end

function CrossShopView:reflashShopUserData()
	local userData = self._modelMgr:getModel("UserModel"):getData()
	self._resCountLabel:setString(userData.cpCoin or 0)
	
	local cost,costType = self._shopModel:getRefreshCost(l_shopType)
	local haveNum = userData[costType] or 0
	self._refreshCostLabel:setColor(haveNum>=cost and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor6)
	
	local tbItem = self:getGoodsData()
	for i,v in ipairs(tbItem) do
		if v.open==1 then
			local node = self._goodsNode[i]
			local haveNum = userData[v.costType] or 0
			if haveNum < v.costNum then
				node.priceLabel:setColor(UIUtils.colorTable.ccUIBaseColor6)
			else
				node.priceLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
			end
		end
	end
end
	
function CrossShopView:refreshShop()
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local cost,costType = self._shopModel:getRefreshCost(l_shopType)
	local haveNum = userData[costType] or 0
	local times = self._shopModel:getShopByType(l_shopType).reflashTimes or 0

	local vipLv = self._modelMgr:getModel("VipModel"):getData().level or 0
	local maxRefreshTimes = tab.vip[vipLv].refreshCpShop
	if times >= maxRefreshTimes then
		self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP_MAX"))
		return
	end

	if cost > haveNum then
		self._viewMgr:showTip(lang("TIP_GLOBAL_LACKREFRESH_CPCOIN"))
		return
	else
		DialogUtils.showBuyDialog({costNum = cost,costType = costType,goods = "刷新一次",
			callback1 = function( )      
				audioMgr:playSound("Reflash")
				self._refreshAnim = true
				self._serverMgr:sendMsg("ShopServer", "reflashShop", {type = l_shopType}, true, {}, function(result)
					
				end)
				if not self._isBuyBack then
					self._offsetY = nil
				else
					self._isBuyBack = false
				end
			end})

	end
end

-- 灰态
function CrossShopView:setNodeColor( node,color,notDark )
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
-- 切换页签 更新offsetY & reflashAnim
function CrossShopView:resetOffsetY()
    self._offsetY = nil
    self._isBuyBack = false
    self._refreshAnim = false
end

function CrossShopView:getAsyncRes()
    return {            
		{"asset/ui/citybattle.plist", "asset/ui/citybattle.png"},
		{"asset/ui/citybattle1.plist", "asset/ui/citybattle1.png"},
		{"asset/ui/citybattle2.plist", "asset/ui/citybattle2.png"},
	}
end

return CrossShopView