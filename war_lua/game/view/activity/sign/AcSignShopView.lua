--[[
    Filename:    AcSignAcSignShopView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-8 20:45
    Description: 法术特训小游戏 消消乐
--]]

local shopIdx = "sign"
local tabSys = "SignShop"
local shopTableName = "shopSign"

local AcSignShopView = class("AcSignShopView", BasePopView)

function AcSignShopView:ctor(param)
	self.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")
	self._shopModel = self._modelMgr:getModel("ShopModel")

    param = param or {}
    self._items = {}   	-- 缓存节点，不移除商店格子
    self._grids = {}
    self._isReqed = false   --改为每次进界面都刷新数据
end

function AcSignShopView:getAsyncRes()
    return 
        {
            {"asset/ui/shop.plist", "asset/ui/shop.png"},
            {"asset/anim/shoprefreshanimimage.plist", "asset/anim/shoprefreshanimimage.png"}
        }
end

-- 初始化UI后会调用, 有需要请覆盖
function AcSignShopView:onInit()
    audioMgr:playSound("bar")
    -- 通用动态背景
    self:addAnimBg()
    self._mainBg = self:getUI("bg.mainBg")
    
    self._downArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._downArrow:setPosition(self._mainBg:getContentSize().width*0.5,90)
    self._downArrow:setRotation(90)
    self._downArrow:setVisible(false)
    self._mainBg:addChild(self._downArrow, 1)

    self._scrollView = self:getUI("bg.mainBg.scrollView")
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height
    self._scrollView:addEventListener(function(sender, eventType)
        if eventType == 1 then
            self._downArrow:setVisible(false)

        elseif eventType == 4 then
            if self._goodData and table.getn(self._goodData) > 8 then           
                self._downArrow:setVisible(true)
            end
        end
    end)

    local title = self:getUI("bg.mainBg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    local curScore = self:getUI("bg.mainBg.curScoreBg.num")
    curScore:setString("")

    --closeBtn
	local closeBtn = self:getUI("bg.mainBg.closeBtn")
	self:registerClickEvent(closeBtn, function()
 		self:close()
 		UIUtils:reloadLuaFile("activity.sign.AcSignShopView")
		end)

    self._item = self:getUI("item")
    self._item:setVisible(false)
    local priceLab = self._item:getChildByFullName("costNum")
    priceLab:setAnchorPoint(0,0.5)

    self:setListenReflashWithParam(true)
    self:listenReflash("UserModel", function( )
        self:updateShopItem()
    end)
    self:listenReflash("ShopModel", function( )
        self:reflashShopInfo()
    end)
    self:listenReflash("ItemModel", function( )
        self:reflashShopInfo()
    end)
    self:listenReflash("VipModel", function( )
        self:reflashShopInfo()
    end)

    self._costImg = self:getUI("bg.mainBg.backTexture.costImg")
    self._refreshTimeLab = self:getUI("bg.mainBg.backTexture.refreshTimeLab")
    local refreshBtn = self:getUI("bg.mainBg.backTexture.refreshBtn")
    self:registerClickEvent(refreshBtn, function( )
        self:sendReFreshShopMsg()
    end)

    -- 计时器
    self._timeLab = self:getUI("bg.mainBg.timeLab")
    local time = self._shopModel:getShopRefreshTime(shopIdx) or 0
    self._nextRefreshTime = time
    self._timeLab:setString("00:00:00") 

    self:setCountDown()
    self.timer = ScheduleMgr:regSchedule(1000,self,function( )
        self:setCountDown()
    end)
    self:updateNeedItems()
end

function AcSignShopView:setCountDown()
	if not self._shopModel.getShopRefreshTime then
        self._timeLab:setVisible(false)
        return 
    end
    local restTime = self._nextRefreshTime - self._userModel:getCurServerTime() + 2
    local reflashDate = TimeUtils.date("*t",self._nextRefreshTime) 
    if restTime > -10 then
        if restTime <= 0 then
            self._shopModel:setData({})
            self._refreshAnim = true
            ScheduleMgr:delayCall(800, self, function( )
                self._refreshAnim = nil
            end)
            self:sendGetShopInfoMsg()
        else   
            restTime = self._nextRefreshTime - self._userModel:getCurServerTime()
            if restTime < 0 then return end

            local hour = self._shopModel:getShopRefreshHour(shopIdx)
            if hour then
                self._timeLab:setString(" ".. hour ..":00")
            end
        end
    end
end

function AcSignShopView:updateNeedItems( )
    -- 取物品需求表
    self._modelMgr:getModel("TeamModel"):refreshDataOrder()
    local countMax = self._modelMgr:getModel("FormationModel"):getCommonFormationCount()+2 or 10
    self._needItems = self._modelMgr:getModel("TeamModel"):getEquipItems(countMax)
    local teamModelData = self._modelMgr:getModel("TeamModel"):getData()
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
end

function AcSignShopView:onHide()
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
end

function AcSignShopView:onTop( )
    if not self.timer then
        self.timer = ScheduleMgr:regSchedule(1000,self,function( )
            self:setCountDown()
        end)
    end
    self:updateNeedItems()
end

function AcSignShopView:touchTab()
    self._offsetY = nil
    audioMgr:playSound("Tab")

    --开启等级
    local isOpen = SystemUtils["enable"..tabSys]()
    if not isOpen then
        local systemOpenTip = tab.systemOpen[tabSys][3]
        if not systemOpenTip then
            self._viewMgr:showTip(tab.systemOpen[tabSys][1] .. "级开启")
        else
            self._viewMgr:showTip(lang(systemOpenTip))
        end
        return 
    end

    self._refreshAnim = nil

     -- 切页时判断是否需要发更新请求
    local shopData = self._shopModel:getShopByType(shopIdx)
    if shopData == nil or next(shopData) == nil then
        ScheduleMgr:delayCall(0, self, function( )
            if self.sendGetShopInfoMsg then
                self:sendGetShopInfoMsg()
            end
        end) 
    else
        local lastUpTime = shopData.lastUpTime 
        local nowTime = self._userModel:getCurServerTime()
        if not lastUpTime or lastUpTime == 0 then
            lastUpTime = nowTime
        end
        local nextRefrashTime = self._shopModel:getShopRefreshTime(shopIdx,lastUpTime)
        if nowTime >= nextRefrashTime or not self._isReqed then
            ScheduleMgr:delayCall(0, self, function( )
                if self.sendGetShopInfoMsg then
                    self:sendGetShopInfoMsg()
                end
            end)
        end
    end

    ScheduleMgr:delayCall(20, self, function( )
        self:reflashShopInfo()
    end) 
 
    self._nextRefreshTime = self._shopModel:getShopRefreshTime(shopIdx)
    self:setCountDown()
    self._timeLab:setVisible(true)
end

-- 接收自定义消息
function AcSignShopView:reflashUI(data)
    self:touchTab()
    self:refreshUI()
end

function AcSignShopView:refreshUI()
	local signCoin = self._userModel:getData().signCoin or 0
    local curScore = self:getUI("bg.mainBg.curScoreBg.num")
    curScore:setString(signCoin)
end

-- 按类型返回商店数据
function AcSignShopView:getGoodsData()
    local goodsData
    local shopData = self._shopModel:getShopGoods(shopIdx)
    if shopData ~= nil then
        goodsData = {}
        for pos,data in pairs(shopData) do
            local shopD = clone(tab[shopTableName][tonumber(data.id)])
            if shopD == nil then
                self._viewMgr:showTip("不存在的商品, ".. shopTableName .." ID=".. (data.id or ""))
                break
            end
          
            shopD.itemId = data.item
            shopD.buyTimes = data.buy or 0
            shopD.id = tonumber(data.id)-- 勘正表错误代码
            shopD.shopBuyType = shopIdx
            local serverIndex = self._shopModel:getServerIndex(pos, shopIdx)
            shopD.pos = serverIndex or pos
            goodsData[tonumber(pos)] = shopD
        end
    end
    
    return goodsData
end

function AcSignShopView:reflashShopInfo()
    for k,v in pairs(self._grids) do
        v:removeFromParent()
        v = nil
    end
    self._grids = {} -- 清空空格子

    for k,v in pairs(self._items) do
        v:setVisible(false)
    end

    self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))
    self:refreshRefresBtnCost() 

    self._goodData = self:getGoodsData()
    local goodsData = self._goodData
    if not goodsData or next(goodsData) == nil then 
        return 
    end

    local itemSizeX,itemSizeY = 186,192
    local offsetX,offsetY = 5,0
    local row = math.ceil(#goodsData/4)
    local col = 4 

    local boardHeight = row*itemSizeY
    local scrollHeight = self._scrollView:getContentSize().height
    if boardHeight < scrollHeight then
        boardHeight = scrollHeight 
        self._downArrow:setVisible(false)
    else
    	self._downArrow:setVisible(true)
        self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,boardHeight))
    end

    local x,y = 0,0
    local goodsCount = math.max(8,row*col)
    self:lock()

    -- dump(goodsData,"goodsData")
    
    self._itemTable = {}
    for i=1, goodsCount do
        x = (i-1) % col * itemSizeX + offsetX + itemSizeX * 0.5
        y = boardHeight - (math.floor((i-1)/col) + 1) * itemSizeY + offsetY + itemSizeY * 0.5 - 1
        
        if goodsData[i] then
            self:createItem(i, goodsData[i], x, y)
        else
            self:createGrid(x, y, i)
        end
    end
    
    self:refreshUI()
    self:unlock()

    if self._offsetY then
        local offsetY = self._offsetY
        local subHeight = self._scrollView:getContentSize().height - boardHeight
        if subHeight < offsetY then
            self._scrollView:getInnerContainer():setPositionY(offsetY)            
        else
            self._scrollView:getInnerContainer():setPositionY(subHeight)
        end
    end
end

function AcSignShopView:updateShopItem()
    self._goodData = self:getGoodsData(self._idx)
    local goodsData = self._goodData
    if not goodsData then 
        return 
    end
    if not self._itemTable or table.nums(self._itemTable) == 0 then 
        return
    end
    local goodsCount = table.getn(goodsData)
    local userData = self._userModel:getData()   
    for i=1, goodsCount do
        data = goodsData[i]
        if type(data.costType) == "table" then
            data.costType = (data.costType[1] or data.costType["type"])
            data.costNum = data.costType[3] or data.costType["num"]
            haveNum = userData[data.costType] or 0
            costNum = data.costNum
        else
            haveNum = userData[data.costType] or 0
            costNum = data.costNum
        end
        -- 花费
        if not tolua.isnull(self._itemTable[i]) then
            local priceLab = self._itemTable[i]:getChildByFullName("costNum")
            if priceLab then 
                priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
                if haveNum < costNum and data.buyTimes ~= 1 then
                    priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
                else
                    priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
                end
            end
        end
    end
    self._downArrow:setVisible(goodsCount > 8)
    self:refreshUI()
end

local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function AcSignShopView:createItem(index, data,x,y)
    local item = self._items[index]
    if not item then
        item = self._item:clone() 
        self._items[index] = item 
        self._scrollView:addChild(item)
    end   
    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end
    -- 商店格子不放大 
    item:setScaleAnim(false)
    self._itemTable[index] = item
    item:setSwallowTouches(false)
    item:setName("item"..index)
    item:setVisible(true)
    item:setPosition(x,y)

    local itemId = tonumber(data.itemId)
    if not itemId then
        itemId = IconUtils.iconIdMap[data.itemId]
    end
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
    icon:setContentSize(100, 100)
    icon:setScale(0.9)
    itemIcon:addChild(icon)

    --name
    local itemName = item:getChildByFullName("itemName")
    itemName:setString(lang(toolD.name) or "没有名字")
    itemName:setFontName(UIUtils.ttfName)
 
 	--cost
    local haveNum = 0
    local costNum = 0
    local userData = self._userModel:getData()
    if type(data.costType) == "table" then
    	data.costType = (data.costType[1] or data.costType["type"])
        data.costNum = data.costType[3] or data.costType["num"]
        haveNum = userData[data.costType] or 0
        costNum = data.costNum
        
    else
        haveNum = userData[data.costType] or 0
        costNum = data.costNum
    end

    local priceLab = item:getChildByFullName("costNum")
    priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
    if haveNum < costNum and data.buyTimes ~= 1 then
        priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    end

    -- costIcon
    local buyIcon = item:getChildByFullName("costImg")
    buyIcon:loadTexture(IconUtils.resImgMap[data.costType],1)
    local scaleNum = math.floor((32/buyIcon:getContentSize().width)*100)
    buyIcon:setScale(scaleNum/100)

    local iconW = buyIcon:getContentSize().width*scaleNum/100
    local labelW = priceLab:getContentSize().width
    local itemW = item:getContentSize().width - 5
    buyIcon:setPositionX(itemW/2-labelW/2-3)
    priceLab:setPositionX(itemW/2+iconW/2-labelW/2-3)

    UIUtils:center2Widget(buyIcon,priceLab,itemW/2,5)

    --click
    self:registerClickEvent(item, function( )
        if canTouch then
            self._refreshAnim = nil            
            self._offsetY = self._scrollView:getInnerContainer():getPositionY()
            local param = {shopData = data}
            self._viewMgr:showDialog("shop.DialogShopBuy",param,true)
        end
    end)

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

    --sold out
    local soldOut = item:getChildByFullName("soldOut")
    soldOut:setVisible(false)
    self:setNodeColor(item,cc.c4b(255, 255, 255,255),true)
	
	local mc
	local iconColor = icon:getChildByName("iconColor")
	if iconColor then
		mc = iconColor:getChildByName("bgMc")
	end
    if data.buyTimes == 1 then
        canTouch = false
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
        self:setNodeColor(item,cc.c4b(182, 182, 182,255))
        self:setNodeColor(soldOut,cc.c4b(255, 255, 255,255))
		
		if mc then
			mc:setVisible(false)
		end
    else
        item:setEnabled(true)
        canTouch = true
        local soldOut = item:getChildByFullName("soldOut")
        soldOut:setVisible(false)
        if mc then
            mc:setVisible(true)
        end
    end

    -- 添加红点
    local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
    local needCount = self._needItems[itemId] or 0
    local dot = item:getChildByFullName("noticeTip")
    if not tolua.isnull(dot) then 
        dot:removeFromParent()
    end
    if (count < needCount or needCount == -1) and canTouch  then
        local dot = ccui.ImageView:create()
        local teamId = string.sub(tostring(itemId),2,string.len(tostring(itemId)))
        if teamId and string.len(itemId) == 4 then
            local isInFormation = self._modelMgr:getModel("FormationModel"):isTeamLoaded(tonumber(teamId))
            if isInFormation then
                dot:loadTexture("globalIamgeUI6_addTeam.png", 1)
                dot:setContentSize(69,51)
                dot:setPosition(item:getContentSize().width/2-icon:getContentSize().width/2+15,item:getContentSize().height/2-icon:getContentSize().height/2+70)
            end
        else
            dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            dot:setContentSize(32,32)
            dot:setPosition(item:getContentSize().width/2+icon:getContentSize().width/2-10,item:getContentSize().height/2+icon:getContentSize().height/2-10)
        end
        dot:setName("noticeTip")
        item:addChild(dot,99)
    end
    if self._refreshAnim then
        local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", false, true,function( )
        end)
        mc:setScaleY(1)
        mc:setPosition(x-4,y-5)
        self._scrollView:addChild(mc,9999)
    end

    -- 加特殊标签
    local subTitleImg = item:getChildByFullName("subTitleImg")
    if not tolua.isnull(subTitleImg) then 
        subTitleImg:removeFromParent()
    end
    if toolD.subtitle then
        local subTitleImg = ccui.ImageView:create()
        subTitleImg:loadTexture("globalImageUI_" .. toolD.subtitle .. ".png",1)
        subTitleImg:setPosition(60,60)
        subTitleImg:setRotation(20)
        subTitleImg:setName("subTitleImg")
        item:addChild(subTitleImg,999)
    end
end

-- 创建空格子
function AcSignShopView:createGrid(x,y,index )
    if self._grids[index] and not tolua.isnull(self._grids[index]) then
        self._grids[index]:removeFromParent()
    end
    local item 
    item = self._item:clone()
    item:setVisible(true)
    item:setTouchEnabled(false)
    self._grids[index] = item
    local name = item:getChildByFullName("itemName")
    local diamondImg = item:getChildByFullName("costImg")
    local discountBg = item:getChildByFullName("discountImg")
    local priceLab = item:getChildByFullName("costNum")
    local bottomDecorate = item:getChildByFullName("decorate")
    diamondImg:setVisible(false)
    discountBg:setVisible(false)
    priceLab:setVisible(false)
    bottomDecorate:setOpacity(0)
    
    name:setString("暂未开启")
    name:setPositionY(158)
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
    item:addChild(lock,3)
    self._scrollView:addChild(item)
    item:setPosition(x,y)

    -- 置灰显示
    self:setNodeColor(item,cc.c4b(182, 182, 182,255))
end

function AcSignShopView:sendGetShopInfoMsg( shopName )
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = shopIdx}, true, {}, function(result)
        self._isReqed = true
        if result.shop[shopIdx] and  
            result.shop[shopIdx].lastUpTime and 
            	result.shop[shopIdx].lastUpTime > self._nextRefreshTime then 
            self._nextRefreshTime = self._shopModel:getShopRefreshTime(shopIdx)
        end
    end)
end

function AcSignShopView:sendReFreshShopMsg()
    local curTime = self._userModel:getCurServerTime()
    local lastUpTime = self._shopModel:getShopByType(shopIdx).lastUpTime
    self._refreshAnim = true
    
    local userData = self._userModel:getData()
    local cost,costType = self._shopModel:getRefreshCost(shopIdx)
    local haveNum = userData[costType] or 0
    
    if cost > haveNum then
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
    end

    DialogUtils.showBuyDialog({costNum = cost, costType = costType, goods = "刷新一次", callback1 = function( )      
        audioMgr:playSound("Reflash")
        self._serverMgr:sendMsg("ShopServer", "reflashShop", {type = shopIdx}, true, {}, function(result)
           
        end)
    end})

    self._offsetY = nil
end

-- 单独抽出来
function AcSignShopView:refreshRefresBtnCost()
    local needCost = 50
    if self._shopModel.getRefreshCost then
        local costType = "gem"
        needCost, costType = self._shopModel:getRefreshCost(shopIdx)
        self._refreshTimeLab:setString(needCost)

        local _, costType = self._shopModel:getRefreshCost(shopIdx)
        local costRes = IconUtils.resImgMap[costType]
        if costRes and costRes ~= "" then
            self._costImg:loadTexture(costRes, 1)
            self._costImg:setScale(0.7)
        end
    else
        self._refreshTimeLab:setString("")
    end

    local privilgeNum = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_10) or 0
    local hadUse = self._modelMgr:getModel("PlayerTodayModel"):getData().day11 or 0
    local _, rCostType = self._shopModel:getRefreshCost(shopIdx)
    local haveNum = self._modelMgr:getModel("UserModel"):getData()[rCostType] or 0

    self._costImg:loadTexture(IconUtils.resImgMap[rCostType],1)
    self._refreshTimeLab:disableEffect()
    self._refreshTimeLab:setString(needCost)
    self._refreshTimeLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    if needCost and needCost > haveNum then
        self._refreshTimeLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    end
end

-- 灰态
function AcSignShopView:setNodeColor( node,color,notDark )
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

-- 处理切入后台
function AcSignShopView:applicationDidEnterBackground()

end

function AcSignShopView:applicationWillEnterForeground(second)
    if self._shopModel then 
        self._shopModel:setData({})
        self:sendGetShopInfoMsg(shopIdx)
        self:touchTab()
    end
end

function AcSignShopView:dtor()
	shopIdx = nil
 	tabSys = nil
 	shopTableName = nil
end

return AcSignShopView