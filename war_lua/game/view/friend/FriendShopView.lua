--[[
    Filename:    FriendShopView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-9-14 18:53:39
    Description: 友情商店
--]]

local shopIdx = "friend"
local FriendShopView = class("FriendShopView", BasePopView)

function FriendShopView:ctor(param)
    self.super.ctor(self)
    self._shopModel = self._modelMgr:getModel("ShopModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._recallModel = self._modelMgr:getModel("FriendRecallModel")

    self._isFirst = true    --第一次请求数据
    self._items = {}        --缓存节点
    self._grids = {}        --格子
    self._itemTable = {}    --商品列表
    self._recallModel:clearShopData()

    self._recallModel:setEnterShopTime()
end

function FriendShopView:getAsyncRes()
    return 
        {
            {"asset/ui/friend1.plist", "asset/ui/friend1.png"},
            {"asset/ui/shop.plist", "asset/ui/shop.png"},
            {"asset/anim/shoprefreshanimimage.plist", "asset/anim/shoprefreshanimimage.png"}
        }
end

-- 初始化UI后会调用, 有需要请覆盖
function FriendShopView:onInit()
    audioMgr:playSound("bar")
    self._scrollView = self:getUI("bg.bg1.scrollView")
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height

    local title = self:getUI("bg.bg1.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._item = self:getUI("item")

    local scoreNum = self:getUI("bg.bg1.scoreNum")
    scoreNum:setString("")
    local curScore = self:getUI("bg.bg1.curScoreBg.num")
    curScore:setString("")
    
    --closeBtn
	local closeBtn = self:getUI("bg.bg1.closeBtn")
	self:registerClickEvent(closeBtn, function()
 		self:close()
 		UIUtils:reloadLuaFile("friend.FriendShopView")
		end)

	--ruleBtn
	local ruleBtn = self:getUI("bg.bg1.titleBg.ruleBtn")
	self:registerClickEvent(ruleBtn, function()
		local ruleDes = lang("FRIENDBACK_SHOPRULES")
 		self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = ruleDes},true)
		end)

	--领取积分
	local getBtn = self:getUI("bg.bg1.getBtn")
	getBtn:setTitleFontSize(18)
	self:registerClickEvent(getBtn, function()
        local score = self._recallModel:getShopData().friendScore or 0

        self._serverMgr:sendMsg("RecallServer", "getCurrentFriendScore", {}, true, {}, function (result)
            local realScore = result.friendScore or score
            if realScore <= 0 then
                self._viewMgr:showTip(lang("FRIEND_TEXT_TIPS_2"))
                return
            end

            local function getScore()
                self._serverMgr:sendMsg("RecallServer", "oneKeyGetFriendActReward", {}, true, {}, function (result) 
                    self:refreshUI()
                    DialogUtils.showGiftGet( {
                        gifts = result["reward"], 
                        callback = function() end
                    ,notPop = true})
                    end)
            end

            if realScore ~= score then
                local des = string.gsub(lang("FRIEND_TEXT_TIPS_9"), "{$num}", realScore)
                self._viewMgr:showDialog("global.GlobalSelectDialog",
                {   desc = des,
                    button1 = "确定",
                    button2 = "取消", 
                    callback1 = function ()
                        getScore()
                    end,
                    callback2 = function()
                    end})
            else
                getScore()
            end
        end)
    end)

	--积分日志
	local logBtn = self:getUI("bg.bg1.logBtn")
	logBtn:setTitleFontSize(18)
	self:registerClickEvent(logBtn, function()
 		self._serverMgr:sendMsg("RecallServer", "getFriendScoreChangeLog", {}, true, {}, function (result) 
            self._viewMgr:showDialog("friend.FriendRecallLogView", {info = result}, true)
            end)
		end)

	--召回好友
	local recallBtn = self:getUI("bg.bg1.recallBtn")
	recallBtn:setTitleFontSize(25)
	self:registerClickEvent(recallBtn, function()
 		self._serverMgr:sendMsg("RecallServer", "getRecallInfo", {}, true, {}, function (result) 
            self._viewMgr:showDialog("friend.FriendRecallInfoView", {callback = function()
                self:refreshUI()
                end}, true)
            end)
		end)

    --召回气泡
    local popImg = self:getUI("bg.bg1.popImg")
    popImg:setVisible(false)
    
	self:listenReflash("UserModel", function()
        self:updateShopItem()
    end)
    self:listenReflash("ShopModel", function()
        self:reflashShopInfo()
    end)
    self:listenReflash("ItemModel", function()
        self:reflashShopInfo()
    end)
    self:listenReflash("VipModel", function()
        self:reflashShopInfo()
    end)

    self:setListenReflashWithParam(true)
    self:listenReflash("FriendRecallModel", function()
        self:reflashShopInfo()
    end)

    -- 计时器
    self._timeLab = self:getUI("bg.bg1.refreshTip")
    local time = self._shopModel:getShopRefreshTime(shopIdx) or 0
    self._nextRefreshTime = time
    self._timeLab:setString("00:00:00")

    self:setCountDown()
    self.timer = ScheduleMgr:regSchedule(1000,self,function( )
        self:setCountDown()
    end)

    self:updateNeedItems()
end

function FriendShopView:setCountDown()
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
            -- self._nextRefreshTime = self._shopModel:getShopRefreshTime(shopIdx)
            restTime = self._nextRefreshTime - self._userModel:getCurServerTime()
            if restTime < 0 then 
                return 
            end

            local hour = self._shopModel:getShopRefreshHour(shopIdx)
            if hour then
                self._timeLab:setString(" ".. hour ..":00")
            end
        end
    end
end

function FriendShopView:updateNeedItems( )
    -- 取物品需求表
    self._modelMgr:getModel("TeamModel"):refreshDataOrder()
    local countMax = self._modelMgr:getModel("FormationModel"):getCommonFormationCount() + 2 or 10
    self._needItems = self._modelMgr:getModel("TeamModel"):getEquipItems(countMax)
    local teamModelData = self._modelMgr:getModel("TeamModel"):getData()
    for i,v in ipairs(teamModelData) do
        if i <= countMax then
            local teamId = v.teamId
            local itemId = 3000 + tonumber(teamId)
            if self._needItems[itemId] then
                self._needItems[itemId] = self._needItems[itemId]+1
            else
                self._needItems[itemId] = -1
            end
        end
    end
end

function FriendShopView:onHide()
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
end

function FriendShopView:onTop( )
    if not self.timer then
        self.timer = ScheduleMgr:regSchedule(1000,self,function( )
            self:setCountDown()
        end)
    end
    self:updateNeedItems()
end

function FriendShopView:touchTab(notRefresh)  
    self._refreshAnim = nil

    -- 切页时判断是否需要发更新请求
    local shopData = self._recallModel:getShopData()

    if self._isFirst == true or shopData == nil or next(shopData) == nil then
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
        local nextRefrashTime = self._shopModel:getShopRefreshTime("friend", lastUpTime)
        if nowTime >= nextRefrashTime and idx ~= 6 then
            ScheduleMgr:delayCall(0, self, function( )
                if self.sendGetShopInfoMsg then
                    self:sendGetShopInfoMsg()
                end
            end)
        end
    end
    if not notRefresh then
        ScheduleMgr:delayCall(20, self, function( )
            self:reflashShopInfo()
        end) 
    end

    self._nextRefreshTime = self._shopModel:getShopRefreshTime(shopIdx)
    self:setCountDown()
    self._timeLab:setVisible(true)
end

-- 接收自定义消息
function FriendShopView:reflashUI(data)
    self:touchTab()
    self:refreshUI()
end

function FriendShopView:refreshUI()
	local score = self._recallModel:getShopData().friendScore or 0
	local scoreNum = self:getUI("bg.bg1.scoreNum")
	scoreNum:setString(score)

    local friendCoin = self._userModel:getData().friendCoin or 0
    local curScore = self:getUI("bg.bg1.curScoreBg.num")
    curScore:setString(friendCoin)

    local popImg = self:getUI("bg.bg1.popImg")
    popImg:setVisible(false)
    popImg:stopAllActions()
    popImg:setScale(0.8)
    local dayNum = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(79) or 0
    local dayMax = tab.setting["FRIEND_RETURN_INVITECOINS_LIMIT"].value
    local isHasRecall = self._recallModel:checkIsHasRecall()
    if isHasRecall and dayNum < dayMax then
        popImg:setVisible(true)
    end

    popImg:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.ScaleTo:create(0.4, 0.9),
            cc.ScaleTo:create(0.4, 0.8)
            )))
end

-- 按类型返回商店数据
function FriendShopView:getGoodsData()
    local goodsData
    local shopData = self._recallModel:getShopGoodData()
    if shopData ~= nil then
        goodsData = {}
        for pos, data in pairs(shopData) do
            local shopD = clone(tab.friendShop[tonumber(data.id)])
            if shopD == nil then
                self._viewMgr:showTip("不存在的商品, ".. tab.friendShop .." ID=".. (data.id or ""))
                break
            end
       
            shopD.itemId = data.item
            shopD.buyTimes = data.buy or 0
            shopD.id = tonumber(data.id)-- 勘正表错误代码
            shopD.pos = pos
            shopD.shopBuyType = "friend"
            goodsData[tonumber(pos)] = shopD
        end
    end

    return goodsData
end

function FriendShopView:reflashShopInfo()
    -- 宝物商店免费时加红点
    self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))

    local goodsData = self:getGoodsData()
    if not goodsData or next(goodsData) == nil then 
        return 
    end

    local itemSizeX,itemSizeY = 186,193
    local offsetX,offsetY = 5,0
    local row = math.ceil(#goodsData/4)
    local col = 4 

    local boardHeight = math.ceil(#goodsData/4)*itemSizeY
    local scrollHeight = self._scrollView:getContentSize().height
    if boardHeight < scrollHeight then
        boardHeight = scrollHeight 
    else
        self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,boardHeight))
    end
   
    local x,y = 0,0
    local goodsCount = math.max(8, row*col)
    self:lock()

    -- dump(goodsData,"goodsData")
    -- 处理联盟商店数据
    for i=1, goodsCount do
        x = (i-1) % col * itemSizeX + offsetX + itemSizeX * 0.5
        y = self.scrollViewH/2 - math.floor((i-1)/col) * itemSizeY + offsetY + itemSizeY * 0.5 
        if goodsData[i] then     
            self:createItem(i, goodsData[i], x, y)
        else
            self:createGrid(x, y, i)
        end
    end

    self:refreshUI()
    self:unlock()
end

function FriendShopView:updateShopItem()
    local goodsData = self:getGoodsData()
    if not goodsData or next(goodsData) == nil then 
        return 
    end
    if not self._itemTable or table.nums(self._itemTable) == 0 then 
        return
    end

    local goodsCount = table.getn(goodsData)
    local userData = self._userModel:getData()   
    for i=1, goodsCount do
        data = goodsData[i]
        data.costType = data.cost[1]
        data.costNum = data.cost[3]
        haveNum = userData[data.costType] or 0
        costNum = data.costNum

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
end

local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}
function FriendShopView:createItem(index, data, x, y)
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

    --icon
    local itemIcon = item:getChildByFullName("itemIcon")
    itemIcon:setSwallowTouches(false)
    itemIcon:removeAllChildren()
    local num = data.num 
    if num == 1 then 
        num = nil
    end
    local icon = IconUtils:createItemIconById({itemId = itemId, itemData = toolD, num = num, eventStyle = 0})
    icon:setContentSize(100, 100)
    icon:setScale(0.9)
    itemIcon:addChild(icon)

    -- name
    local itemName = item:getChildByFullName("itemName")
    itemName:setString(lang(toolD.name) or "没有名字")
    itemName:setFontName(UIUtils.ttfName)

    --cost
    local userData = self._userModel:getData()
    data.costType = data.cost[1]
    data.costNum = data.cost[3]
    local haveNum = userData[data.costType] or 0
    local costNum = data.cost[3]
   
    local priceLab = item:getChildByFullName("costNum")
    priceLab:setString(ItemUtils.formatItemCount(costNum) or "")
    if haveNum < costNum and data.buyTimes ~= 1 then
        priceLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        priceLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    end

    -- costIcon
    local buyIcon = item:getChildByFullName("costImg")
    buyIcon:loadTexture(IconUtils.resImgMap[data.costType], 1)

    local scaleNum = math.floor((32 / buyIcon:getContentSize().width) * 100)
    buyIcon:setScale(scaleNum / 100)

    local iconW = buyIcon:getContentSize().width * scaleNum / 100
    local labelW = priceLab:getContentSize().width
    local itemW = item:getContentSize().width - 5
    buyIcon:setPositionX(itemW / 2 - labelW / 2 - 3)
    priceLab:setPositionX(itemW / 2 + iconW / 2 - labelW / 2 - 3)

    UIUtils:center2Widget(buyIcon, priceLab, itemW/2, 5)

    --click
    self:registerClickEvent(item, function( )
        if canTouch then
            self._refreshAnim = nil
            self._viewMgr:showDialog("shop.DialogShopBuy", data, true)
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

    --soldout
    local soldOut = item:getChildByFullName("soldOut")
    soldOut:setVisible(false)
    self:setNodeColor(item, cc.c4b(255, 255, 255,255), true)
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
        self:setNodeColor(item, cc.c4b(182, 182, 182,255))
        self:setNodeColor(soldOut, cc.c4b(255, 255, 255,255))
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

    -- 添加红点
    local _, count = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
    local needCount = self._needItems[itemId] or 0
    local dot = item:getChildByFullName("noticeTip")
    if not tolua.isnull(dot) then 
        dot:removeFromParent()
    end
    if (count < needCount or needCount == -1) and canTouch  then
        local dot = ccui.ImageView:create()
        local teamId = string.sub(tostring(itemId), 2, string.len(tostring(itemId)))
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
function FriendShopView:createGrid(x,y,index )
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
    name:setVisible(false)
    diamondImg:setVisible(false)
    discountBg:setVisible(false)
    priceLab:setVisible(false)

    self._scrollView:addChild(item)
    item:setAnchorPoint(0,0)
    item:setPosition(x, y)
end

-- 宝物未开启的格子
local posLimt = {}
for k,v in pairs(tab.shopTreasure) do
    if not posLimt[v.position] then
        posLimt[v.position] = {}
        posLimt[v.position].vipLevel = v.vipLevel
        posLimt[v.position].level = v.level
    end
end

function FriendShopView:sendGetShopInfoMsg()
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "friend"}, true, {}, function(result)
        if result.shop[shopIdx] and
            result.shop[shopIdx].lastUpTime and 
            result.shop[shopIdx].lastUpTime > self._nextRefreshTime then 

            self._isFirst = false  
            self._nextRefreshTime = self._shopModel:getShopRefreshTime(shopIdx)
        end
    end)
end

-- 灰态
function FriendShopView:setNodeColor(node, color, notDark)
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
        self:setNodeColor(v, color, notDark)
    end
end

function FriendShopView:applicationWillEnterForeground(second)
    if self._shopModel then 
        self._shopModel:setData({})
        self:sendGetShopInfoMsg()
        self:touchTab()
    end
end

function FriendShopView:onDestroy()
    if self._leagueShopLayer then
        if self._leagueShopLayer._resumetimer then
            ScheduleMgr:unregSchedule(self._leagueShopLayer._resumetimer)
            self._leagueShopLayer._resumetimer = nil
        end
    end
    self.super.onDestroy(self)
end

return FriendShopView