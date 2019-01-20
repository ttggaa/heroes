--
-- Author: huangguofang
-- Date: 2018-08-08 17:56:27
--

-- 商店layer
local AcLimitPrayShopLayer = class("AcLimitPrayShopLayer",BaseLayer)
function AcLimitPrayShopLayer:ctor(params)
    self.super.ctor(self)
    -- parent=self,UIInfo = self._info,openId=self._openId
    self._parent = params.parent
    self._UIInfo = params.UIInfo or {}
    self._openId = params.openId
    self._selfRank = params.selfRank or 0

    self._userModel = self._modelMgr:getModel("UserModel")
    self._limitPrayModel = self._modelMgr:getModel("LimitPrayModel")
    self._shopModel = self._modelMgr:getModel("ShopModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")

    self._shopType = "pray"
end

-- 初始化UI后会调用, 有需要请覆盖
function AcLimitPrayShopLayer:onInit()
	self._acData 	 = self._limitPrayModel:getDataById(self._openId)
	self._prayConfig = tab.prayConfig
	self._prayShop 	 = tab.prayShop

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)

    self._item = self:getUI("bg.item")
    self._item:setVisible(false)

    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = self._shopType}, true, {}, function(result) 
		self:reflashUI()
    end)
    
end

function AcLimitPrayShopLayer:updateCostColor()
    if not self._scrollView then return end
    self._userData = self._modelMgr:getModel("UserModel"):getData()
    local allChildren = self._scrollView:getChildren()
    if allChildren then
        local exchange_num
        local haveNum
        local item 
        local costNum
        for k,v in pairs(allChildren) do
            item = v
            costNum = v._costNum
            exchange_num = item._exchange_num
            haveNum = self._userData[exchange_num[1]] or 0
            if exchange_num[1] == "tool" then
                local items,_itemNum = self._itemModel:getItemsById(exchange_num[2])
                haveNum = _itemNum
            end
            if haveNum < exchange_num[3] then
                costNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
            else
                costNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
            end
        end
    end
 end 

-- 接收自定义消息
function AcLimitPrayShopLayer:reflashUI(data)
	-- print("===================reflashUI=================")
	self._userData = self._modelMgr:getModel("UserModel"):getData()
	local shopData = self._limitPrayModel:getShopData() or {}
	table.sort(self._prayShop, function (a, b)
		return a.order < b.order
	end)
	for i=1,#self._prayShop do
		if shopData[tostring(i)] then
			self._prayShop[i]["buyTimes"] = shopData[tostring(i)]["buyTimes"]
			self._prayShop[i]["lastBuyTime"] = shopData[tostring(i)]["lastBuyTime"]
		else
			self._prayShop[i]["buyTimes"]  = 0
			self._prayShop[i]["lastBuyTime"] = 0
		end
	end
	self._scrollView:removeAllChildren()
	
	local itemNum = #self._prayShop
	local itemW = 200
	local itemH = 240
	local col = itemNum/3
	local scrollH = self._scrollView:getContentSize().height
	local height = col * itemH
	if height <= scrollH then
		height = scrollH
	end
	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, height))
	local posX = 20
	local posY = height - itemH
	for i=1,itemNum do
		local item = self:createItem(self._prayShop[i],i)
		item:setPosition(posX, posY)
		if i % col == 1 then
			posX = 10
			posY = posY - itemH
		else
			posX = posX + itemW
		end
		self._scrollView:addChild(item)
	end

end

local costImg = {
	gem = "allicance_redziyuan2.png",
	luckyCoin = "globalImageUI_luckyCoin.png"
}
function AcLimitPrayShopLayer:createItem(data,index)
	local item = ccui.Layout:create()
	item:setAnchorPoint(cc.p(0,0))
	item:setContentSize(cc.size(180, 229))
	item:setBackGroundImage("acLimitPray_shopItem_bg.png",1)
	if not data then
		return item 
	end
	
	local itemName = ccui.Text:create()
    itemName:setFontSize(20)
    itemName:setAnchorPoint(0.5,0.5)
    itemName:setPosition(90, 207)
    itemName:setFontName(UIUtils.ttfName)
    itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	item:addChild(itemName)

	local discount = ccui.ImageView:create()
	discount:loadTexture("priviege_tipBg.png",1)		
    discount:setPosition(112,150)
    discount:setScale(0.9)
    discount:setFlippedX(true)
    discount:setAnchorPoint(0.5,0.5)
	item:addChild(discount,1)

	local discountTxt = ccui.Text:create()
    discountTxt:setFontSize(20)
    discountTxt:setAnchorPoint(0.5,0.5)
    discountTxt:setPosition(120, 159)
    discountTxt:setRotation(45)
	discountTxt:setScale(0.9)
    discountTxt:setFontName(UIUtils.ttfName)
    discountTxt:setColor(cc.c4b(253,211,10,255) )
    discountTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	item:addChild(discountTxt,2)

	local limitTxt = ccui.Text:create()
    limitTxt:setFontSize(20)
    limitTxt:setAnchorPoint(0.5,0.5)
    limitTxt:setPosition(90, 64)
    limitTxt:setFontName(UIUtils.ttfName)
    limitTxt:setColor(cc.c4b(253,211,10,255) )
    limitTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	item:addChild(limitTxt)

	local priceImg = ccui.ImageView:create()
	priceImg:loadTexture("acLimitPray_shopItem_price.png",1)		
    priceImg:setPosition(90,28)
    priceImg:setAnchorPoint(0.5,0.5)
	item:addChild(priceImg)

	local costType = ccui.ImageView:create()
	costType:loadTexture(costImg[1],1)		
    costType:setPosition(88,28)
    costType:setAnchorPoint(1,0.5)
    costType:setScale(0.6)

	local costNum = ccui.Text:create()
    costNum:setFontSize(20)
    costNum:setAnchorPoint(0,0.5)
    costNum:setPosition(92, 28)
    costNum:setFontName(UIUtils.ttfName)
    costNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	item:addChild(costNum)
    item._costNum = costNum
	

	local lockPanel = ccui.ImageView:create()
	lockPanel:loadTexture("acLimitPray_shopItem_price.png",1)		
    lockPanel:setPosition(0,0)
    lockPanel:setAnchorPoint(0,0)
    lockPanel:setContentSize(180,229)
  	lockPanel:setScale9Enabled(true)
  	lockPanel:setCapInsets(cc.rect(50,15,1,1))
    local lockImg = ccui.ImageView:create()
    lockImg:loadTexture("acLimitPray_shopItem_price.png",1)       
    lockImg:setPosition(0,0)
    lockImg:setAnchorPoint(0,0)
    lockImg:setContentSize(180,229)
    lockImg:setScale9Enabled(true)
    lockImg:setCapInsets(cc.rect(50,15,1,1))
    lockPanel:addChild(lockImg)    
	item:addChild(lockPanel,2)
	local lockImg = ccui.ImageView:create()
	lockImg:loadTexture("globalImageUI5_treasureLock.png",1)		
    lockImg:setPosition(97,133)
    lockImg:setAnchorPoint(0.5,0.5)
	lockPanel:addChild(lockImg,2)

	local limitCon = ccui.Text:create()
    limitCon:setFontSize(18)
    limitCon:setAnchorPoint(0.5,0.5)
    limitCon:setPosition(90, 28)
    limitCon:setFontName(UIUtils.ttfName)
    limitCon:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	item:addChild(limitCon)

	local itemId = tonumber(data.reward[2])
	local itemType = data.reward[1]
    if itemType ~= "tool" then
        itemId = IconUtils.iconIdMap[itemType]
    end
    local toolD = tab:Tool(itemId)    
    local num = data.reward[3]
    if num == 1 then 
        num = nil
    end
    local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,eventStyle = 0})
    icon:setContentSize(100, 100)
    icon:setPosition(50, 84)
    item:addChild(icon)

    -- 设置名称
    itemName:setString(lang(toolD.name) or "没有名字")
    itemName:setFontName(UIUtils.ttfName)

    if data.numlimit then
    	limitTxt:setString("限购 "..data.buyTimes.."/"..data.numlimit)
    else
    	limitTxt:setVisible(false)
    end

    if data.discount then
    	discountTxt:setString(data.discount/100 .. "折")
    else
    	discountTxt:setVisible(false)
    	discount:setVisible(false)
    end

    local exchange_num = data.exchange_num
    local haveNum = self._userData[exchange_num[1]] or 0
    if exchange_num[1] == "tool" then
        local toolD = tab:Tool(exchange_num[2])    
        costType = IconUtils:createItemIconById({itemId = exchange_num[2],itemData = toolD,eventStyle = 1})
        costType:setContentSize(100, 100)
        costType:setPosition(58, 28)
        costType:setScale(0.35)
        costType:setSwallowTouches(true)
        local items,_itemNum = self._itemModel:getItemsById(exchange_num[2])
        haveNum = _itemNum
    else
        costType:loadTexture(costImg[exchange_num[1]],1)
    end
    print(exchange_num[2],"===============haveNum====================",haveNum)
    costNum:setString(exchange_num[3])
    if haveNum < exchange_num[3] then
        costNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        costNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
    end
    item._exchange_num = data.exchange_num

    item:addChild(costType,1)
    UIUtils:center2Widget(costType,costNum,90,5)

    if data.team then
    	if self._teamModel:getTeamDataById(data.team) then
	    	lockPanel:setVisible(false)
			limitCon:setVisible(false)
		else
			costType:setVisible(false)
			costNum:setVisible(false)
            item._isLock = true
			local teamD = tab:Team(data.team)
			lockPanel:setVisible(true)
			limitCon:setString("获得" .. lang(teamD.name) .. "解锁")
		end
    else
    	lockPanel:setVisible(false)
		limitCon:setVisible(false)
	end

	item._data = data
    self:registerClickEvent(item, function(sender)
        local _paramData = {}
        _paramData.toolD = toolD
        _paramData.rewardType = itemType
        _paramData.itemId = itemId
        _paramData.name      = lang(toolD.name) or ""
        _paramData.price     = exchange_num[3]
        _paramData.costType  = exchange_num[1]
        _paramData.costId    = exchange_num[2]
        _paramData.leftTimes = math.floor(haveNum / exchange_num[3])
        if data.numlimit and data.numlimit > 0 then
            _paramData.leftTimes = math.min(data.numlimit - data.buyTimes, _paramData.leftTimes)
        end
        if _paramData.leftTimes <= 0 then
            _paramData.leftTimes = 1
        end
        _paramData.id        = data.order       
        _paramData.shopType = self._shopType
        self:buyItem(sender,_paramData)
    end)

	return item 
end

function AcLimitPrayShopLayer:buyItem(sender,_paramData)
	if not self._limitPrayModel:isActicityOpen() then
        self._viewMgr:showTip("活动已结束")
        return
    end
    local data = sender._data
     if data.numlimit and data.buyTimes and data.buyTimes >= data.numlimit then
        self._viewMgr:showTip("达到购买上限")
        return
    end
    if sender._isLock then
        self._viewMgr:showTip("未达到购买条件")
        return
    end
    local exchange_num = data.exchange_num
    local costType = exchange_num[1]    
    -- print("===========costType===",costType)
    local haveNum = self._userData[costType] or 0
    local isTool = false
    if exchange_num[1] == "tool" then
        local items = self._itemModel:getItemsById(exchange_num[2])
        haveNum = table.nums(items)
        isTool = true
    end
    local costNum = exchange_num[3]
    -- print(costType,haveNum,"====================",costNum,self._userData[_costType])
    if haveNum < costNum then
        if isTool then
            self._viewMgr:showTip("道具不足！")
        else
            self._viewMgr:showTip("钻石不足！")
        end
    else
        print("================购买商品================")
        self._viewMgr:showDialog("shop.DirectBatchBuyDialog",{data = _paramData,callBack = function (result)
            self:reflashUI()
            if result.reward then
                DialogUtils.showGiftGet({ gifts = result["reward"], hide = self, callback = function()                    
                    
                end,notPop = false})
            end
        end},true)         
    end
end

return AcLimitPrayShopLayer