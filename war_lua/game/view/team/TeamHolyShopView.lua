--[[
    Filename:    TeamHolyShopView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-24 14:58:15
    Description: File description
--]]

-- 圣辉主界面
local TeamHolyShopView = class("TeamHolyShopView", BaseView)
local boxImg = {
    [1] = {"box_1_n.png", "box_1_p.png"},
    [2] = {"box_2_n.png", "box_2_p.png"},
    [3] = {"box_2_n.png", "box_2_p.png"},
    [4] = {"box_3_n.png", "box_3_p.png"},
    [5] = {"box_3_n.png", "box_3_p.png"},
}

local l_boxEffect = {
	[1] = {[1] = "baoxiang1_baoxiang", [2] = "baoxiangguang1_baoxiang"},
    [2] = {[1] = "baoxiang2_baoxiang", [2] = "baoxiangguang2_baoxiang"},
    [3] = {[1] = "baoxiang2_baoxiang", [2] = "baoxiangguang2_baoxiang"},
    [4] = {[1] = "baoxiang3_baoxiang", [2] = "baoxiangguang3_baoxiang"},
    [5] = {[1] = "baoxiang3_baoxiang", [2] = "baoxiangguang3_baoxiang"}
}

function TeamHolyShopView:ctor(data)
    TeamHolyShopView.super.ctor(self)
    -- self._pageIndex = data.index
    if not data then
        data = {}
    end
	self._isChange = false
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil
	self._closeCallback = data.callback
    self._teamId = data.teamId or 101
end

function TeamHolyShopView:onInit()
    self._teamShopModel = self._modelMgr:getModel("TeamShopModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._vipModel = self._modelMgr:getModel("VipModel")
    -- local userData = self._userModel:getData()
    self:setBtn()


    -- self:listenReflash("TeamModel", self.updateData)

    -- self._tableData = {}
    -- for i=1,10 do
    --     self._tableData[i] = i
    -- end
    self._teamShopModel:setJoinShopView(true)
    self._tableData = self._teamShopModel:getGoods()

    self._itemCell = self:getUI("itemCell")
    self._itemCell:setVisible(false)
    self:addTableView()
    self._tableView:reloadData()


    local shopBg = self:getUI("shopBg")
    shopBg:loadTexture("asset/bg/bg_015.jpg", 0)


    self:updateBtnData()
    self:updateBoxData()
    self:updateTimeLab()
	
	self:listenReflash("UserModel", function()
		self._tableView:reloadData()
		self:reflashUserData()
	end)

    -- 定时器
    --每日五点刷新剩余次数和宝箱数据
    self:registerTimer(5,0,2,function(  )
		self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type="rune"}, true, {}, function(result)     
			self:updateBtnData()
			self:updateBoxData()
		end)
    end)
--	self:listenReflash("UserModel", self.reflashShopUserData)
end

function TeamHolyShopView:setBtn()
    --[[local breakBtn = self:getUI("bg.breakBtn")
    breakBtn:setVisible(true)
    self:registerClickEvent(breakBtn, function()
        -- self:updateBtnData()
        -- self:updateBoxData()
        self:updateTimeLab()

    end)--]]

    local reflashBtn = self:getUI("bg.reflashBtn")
    self:registerClickEvent(reflashBtn, function()
        self:reflashShop()
    end)
end

function TeamHolyShopView:updateTimeLab()
    local value = tab:Setting("G_RUNESHOP_REFRESH").value
    local curServerTime = self._userModel:getCurServerTime()

    local timeTab = {}
    for i=1,7 do
        local hour = value[i]
        local date = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d " .. hour .. ":00:01"))
        table.insert(timeTab, date)
    end

    local times = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime + 86400 ,"%Y-%m-%d " .. value[1] .. ":00:01"))
    table.insert(timeTab, times)

    local indexId = 1
    for i=1,7 do
        local begTime = timeTab[i]
        local endTime = timeTab[i+1]
        if curServerTime >= begTime and curServerTime < endTime then
            indexId = i + 1
            break
        end
    end
    local curServerTime1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(timeTab[indexId],"%Y-%m-%d %H:%M:%S"))
    local timeValue = self:getUI("bg.timeBg.timeValue")
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local tTime = curServerTime1 - curServerTime
        local hour = math.floor(tTime/3600)
        local _ttime = tTime - hour*3600
        local min = math.floor(_ttime/60)
        local sec = math.fmod(_ttime, 60)

        local str = string.format("%.2d:%.2d:%.2d", hour, min, sec)
        timeValue:setString(str)
        if tTime < 0 then
            timeValue:setString("00:00:00")
            timeValue:stopAllActions()
            self:getShopInfo()
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    local rep = cc.RepeatForever:create(seq)
    timeValue:runAction(rep)
end

function TeamHolyShopView:updateBtnData()
    local viplvl = self._vipModel:getData().level
    local buyMaxNum = tab:Vip(viplvl).refreshRuneShop
    local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    local shopData = self._teamShopModel:getData()
	shopData.cnt = shopData.cnt or 0
    local buyTimes = shopData.reflashTimes or 0
    local timesTxt = self:getUI("bg.awardBg.timesTxt")
    timesTxt:setString(shopData.cnt .. "次")

    local txt1 = self:getUI("bg.reflashBtn.txt1")
    local txt1Str = "(今日剩" .. (buyMaxNum - buyTimes) .. "次)"
    txt1:setString(txt1Str)

    if buyTimes >= 50 then
        buyTimes = 50
    else
        buyTimes = buyTimes + 1
    end
	
	local userData = self._userModel:getData()
	
	local costData = tab:ReflashCost(buyTimes).shopRune
	local cost, costType = costData[3], costData[1]
	local haveNum = userData[costType] or 0
    local txt = self:getUI("bg.reflashBtn.txt")
	
	if haveNum>=cost then
		txt:setColor(UIUtils.colorTable.ccUIBaseColor2)
	else
		txt:setColor(UIUtils.colorTable.ccUIBaseColor6)
	end
    txt:setString(cost)
	local costImg = self:getUI("bg.reflashBtn.costImg")
	costImg:loadTexture(IconUtils.resImgMap[costType], 1)
end

function TeamHolyShopView:updateBoxData()
    local shopData = self._teamShopModel:getData()
    local awardsData = self._teamShopModel:getAwards()

    local cnt = shopData.cnt or 0
    local shopRewardTab = tab:ShopRuneReward(5)
    local maxTimes = shopRewardTab.refresh
    local progExp = cnt/maxTimes
    if progExp < 0 then
        progExp = 0
    end
    if progExp > 1 then
        progExp = 1
    end

    local blueExpProg = self:getUI("bg.awardBg.blueExpProg")
    blueExpProg:setScaleX(progExp)
	
	local percentLeftX = blueExpProg:getPositionX()
	local percentWidth = blueExpProg:getContentSize().width

    for i=1,5 do
        local box = self:getUI("bg.awardBg.box" .. i)
        local boxLab = box:getChildByFullName("boxLab")
        local shopRewardTab = tab:ShopRuneReward(i)
        boxLab:setString(shopRewardTab.refresh .. "次")
		box:setPositionX(percentLeftX + shopRewardTab.refresh/maxTimes*percentWidth)
		local boxEffect = box:getParent():getChildByName("boxEffect"..i)
		if not boxEffect then
			boxEffect = mcMgr:createViewMC(l_boxEffect[i][1], true, false)
			local posX, posY = box:getPositionX(), box:getPositionY()
			boxEffect:setPosition(posX, posY*1.75)
			boxEffect:setName("boxEffect"..i)
			
			local lightEffect = mcMgr:createViewMC(l_boxEffect[i][2], true, false)
			lightEffect:setPosition(0, 0)
			boxEffect:addChild(lightEffect)
			
			box:getParent():addChild(boxEffect, 10)
		end
        local tbImg = boxImg[i]
        local indexId = tostring(i)
        if awardsData[indexId] and awardsData[indexId]~=0 then
            box:loadTexture(tbImg[2], 1)
			box:setOpacity(255)
			boxEffect:setVisible(false)
            self:registerClickEvent(box, function()
                self._viewMgr:showTip("您已经领取过此奖励")
            end)
        else
            if cnt >= shopRewardTab.refresh then
				boxEffect:setVisible(true)
				box:setOpacity(0)
                self:registerClickEvent(box, function()
                    self:getReflashAward(i)
                end)
                box:loadTexture(tbImg[1], 1)
            else
				boxEffect:setVisible(false)
				box:setOpacity(255)
                self:registerClickEvent(box, function()
					local rewards = {tab.shopRuneReward[i].reward}
					local desc = lang(tab.shopRuneReward[i].rewardDec)
					DialogUtils.showGiftGet( {gifts = rewards, viewType = 1, canGet = false, des = desc, isFam = true} )
                end)
                box:loadTexture(tbImg[1], 1)
            end
        end
    end
end 

function TeamHolyShopView:getReflashAward(indexId)
    local param = {type="rune", id = indexId}
    self._serverMgr:sendMsg("ShopServer", "getReflashAward", param, true, {}, function(result)
        self:updateBoxData()
        DialogUtils.showGiftGet({gifts = result.reward,notPop = true})
    end)
end

function TeamHolyShopView:reflashShop()
	local userData = self._userModel:getData()
	local shopData = self._teamShopModel:getData()
	
	local buyTimes = shopData.reflashTimes or 0
	local rightRefreshTimes = buyTimes
	if buyTimes >= 50 then
		buyTimes = 50
	else
		buyTimes = buyTimes + 1
	end
	local costData = tab:ReflashCost(buyTimes).shopRune
	local cost, costType = costData[3], costData[1]
	local haveNum = userData[costType] or 0
	
	local vipLv = self._modelMgr:getModel("VipModel"):getData().level or 0
	local maxRefreshTimes = tab.vip[vipLv].refreshRuneShop
	if rightRefreshTimes >= maxRefreshTimes then
		self._viewMgr:showTip(lang("REFRESH_TREASURE_SHOP_MAX"))
		return
	end

	if cost > haveNum then
		DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
			local viewMgr = ViewManager:getInstance()
			viewMgr:showView("vip.VipView", {viewType = 0})
		end})
	else
		DialogUtils.showBuyDialog({costNum = cost,costType = costType,goods = "刷新一次",callback1 = function( )      
			audioMgr:playSound("Reflash")
			self._serverMgr:sendMsg("ShopServer", "reflashShop", {type="rune"}, true, {}, function(result)
				self._tableData = self._teamShopModel:getGoods()
				self._tableView:reloadData()
				self:updateBtnData()
				self:updateBoxData()
			end)
		end})
	end
    
end

function TeamHolyShopView:getShopInfo()
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type="rune"}, true, {}, function(result)
        self._tableData = self._teamShopModel:getGoods()
        self._tableView:reloadData()
        self:updateTimeLab()
    end)
end

function TeamHolyShopView:buyShopItem(indexId)
    local param = {id = indexId, type="rune"}
    self._serverMgr:sendMsg("ShopServer", "buyShopItem", param, true, {}, function(result)
        self._tableData = self._teamShopModel:getGoods()
        self._tableView:reloadData()
    end)
	--[[local itemData = self._tableData[indexId]
	itemData.itemId = itemData.item
	self._viewMgr:showDialog("shop.DialogShopBuy",itemData,true)--]]
end

function TeamHolyShopView:reflashUI()
    self._tableView:reloadData()
end

function TeamHolyShopView:updateCell(inView, indexLine)    
    local cellBg = inView.cellBg
    if not cellBg then
        cellBg = ccui.ImageView:create()
        cellBg:setName("cellBg")
        cellBg:setAnchorPoint(0, 0)
        cellBg:setPosition(0, 0)
        cellBg:setScale(1.11)
        -- cellBg:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
        inView:addChild(cellBg, -1)
        inView.cellBg = cellBg
        cellBg:loadTexture("TeamHolyUI_img26.png", 1)
    end

    for i=1,4 do
        local listCell = inView["listCell" .. i]
        if listCell then
            local indexId = (indexLine-1)*4+i
            local holyId = self._tableData[indexId]
            if holyId then
                listCell:setVisible(true)
                self:updateItemCell(listCell, indexId, i)
            else
                listCell:setVisible(false)
            end
        end
    end
end

local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}

function TeamHolyShopView:updateItemCell(inView, indexId, verticalId)
    local itemData = self._tableData[indexId]
    local runeTab = tab:ShopRune(itemData.id)
	
	local userData = self._userModel:getData()
	local haveResNum = userData[runeTab.costType] or 0

    local itemName = inView:getChildByFullName("itemName")
    local itemDi = inView:getChildByFullName("itemDi")
    local costNum = inView:getChildByFullName("itemDi.costNum")
    local costImg = inView:getChildByFullName("itemDi.costImg")
    local itemBg = inView:getChildByFullName("itemBg")
    local itemIcon = itemBg.itemIcon
    local stoneIcon = itemBg.stoneIcon

    local itemId = tonumber(itemData.item)
    local nameStr = ""
	local discountBg = inView:getChildByFullName("discountBg")

    if runeTab.discount and runeTab.discount > 0 then
        local color = "r"
        if runeTab.discount > 5 then 
            color = "p"
        end
        discountBg:loadTexture("globalImageUI6_connerTag_" .. color ..".png",1)
        local discountLab = discountBg:getChildByFullName("discountLab")
        discountLab:setFontName(UIUtils.ttfName)
        discountLab:setRotation(41)
        discountLab:setFontSize(20)
        -- discountLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
        discountLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        discountLab:setString(discountToCn[runeTab.discount])
        discountBg:setVisible(true)
    else
        discountBg:setVisible(false)
    end
    if runeTab.itemType == "tool" then
        local toolD = tab:Tool(itemId)
        nameStr = lang(toolD.name)
        local itemNum = runeTab.num or 0
        local param = {itemId = itemId, effect = true, eventStyle = 0, num = itemNum}
		discountBg:setPosition(cc.p(92, 114))
        if itemIcon then
            IconUtils:updateItemIconByView(itemIcon, param)
        else
            itemIcon = IconUtils:createItemIconById(param)
            itemIcon:setName("itemIcon")
            -- itemIcon:setScale(0.9)
            itemIcon:setPosition(0, 0)
            itemBg:addChild(itemIcon)
            itemBg.itemIcon = itemIcon
        end

        self:registerClickEvent(itemBg, function()
--				self:buyShopItem(indexId)
				local truneTab = clone(runeTab)
				truneTab.itemId = itemId
				truneTab.shopBuyType = "rune"
				UIUtils:reloadLuaFile("team.TeamHolyShopBuyDialog")
				self._viewMgr:showDialog("team.TeamHolyShopBuyDialog", {data = truneTab, indexId = indexId, closeCallback = function()
					self._isChange = true
					self._tableData = self._teamShopModel:getGoods()
					self._tableView:reloadData()
				end})
				--[[UIUtils:reloadLuaFile("shop.DialogShopBuy")
				self._viewMgr:showDialog("shop.DialogShopBuy", runeTab)--]]
        end)
    else
        local stoneTab = tab:Rune(itemId) 
        nameStr = lang(stoneTab.name)
		discountBg:setPosition(cc.p(94, 116))
        local param = {suitData = stoneTab, isTouch = false}
        if not stoneIcon then
            stoneIcon = IconUtils:createHolyIconById(param)
            -- stoneIcon:setScale(0.88)
            stoneIcon:setPosition(-3, -3)
            itemBg:addChild(stoneIcon)
            itemBg["stoneIcon"] = stoneIcon
        else
            IconUtils:updateHolyIcon(stoneIcon, param)
        end

        self:registerClickEvent(itemBg, function()
			local truneTab = clone(runeTab)
			truneTab.itemId = itemId
			truneTab.shopBuyType = "rune"
			UIUtils:reloadLuaFile("team.TeamHolyShopBuyDialog")
			self._viewMgr:showDialog("team.TeamHolyShopBuyDialog", {data = truneTab, indexId = indexId, closeCallback = function()
				self._isChange = true
				self._tableData = self._teamShopModel:getGoods()
				self._tableView:reloadData()
			end})
--            self:buyShopItem(indexId)
        end)
    end
    if itemName then
        itemName:setString(nameStr)
    end
	
    costNum:setString(runeTab.costNum)
	
	if haveResNum>=runeTab.costNum then
		costNum:setColor(cc.c3b(60, 42, 30))
	else
		costNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
	end

    local failName = IconUtils.resImgMap[runeTab.costType]
    costImg:loadTexture(failName, 1)
    local posx = itemDi:getContentSize().width-costNum:getContentSize().width-costImg:getContentSize().width-10
    posx = posx * 0.5
    costImg:setPositionX(posx)
    posx = posx + costImg:getContentSize().width + 5
    costNum:setPositionX(posx)

    local shouqing = inView:getChildByFullName("shouqing")
    if itemData.buy >= runeTab.buyTimes then
        shouqing:setVisible(true)
        self:registerClickEvent(itemBg, function()
--            print("已购买")
        end)
    else
        shouqing:setVisible(false)
    end
end

--[[
用tableview实现
--]]
function TeamHolyShopView:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    local theight = tableViewBg:getContentSize().height
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, theight))
    self._tableView:setDelegate()
    self._tableView:setDirection(1)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, 0)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(false)
    -- self._tableView:reloadData()
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    tableViewBg:addChild(self._tableView)
end

-- 返回cell的数量
function TeamHolyShopView:numberOfCellsInTableView(table)
   return self:getTableNum()
end

function TeamHolyShopView:getTableNum()
    local tabNum = math.ceil(table.nums(self._tableData)/4)
--	self._tableView:setBounceable(tabNum>2)
    return tabNum -- 
end

-- cell的尺寸大小
function TeamHolyShopView:cellSizeForTable(table,idx) 
    local width = 780 
    local height = 200
    return height, width
end

-- 创建在某个位置的cell
function TeamHolyShopView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=1,4 do
            local listCell = self._itemCell:clone()
            listCell:setName("listCell" .. i)
            listCell:setVisible(true)
            listCell:setAnchorPoint(0, 0)
            listCell:setPosition((i-1)*200 + 100, 15)
            cell:addChild(listCell)
            cell["listCell" .. i] = listCell
        end
    end

    self:updateCell(cell, indexId)
    return cell
end


function TeamHolyShopView:reflashUserData()
	local userData = self._userModel:getData()
	local shopData = self._teamShopModel:getData()
	
	local buyTimes = shopData.reflashTimes or 0
	if buyTimes >= 50 then
		buyTimes = 50
	else
		buyTimes = buyTimes + 1
	end
	local costData = tab:ReflashCost(buyTimes).shopRune
	local cost, costType = costData[3], costData[1]
	local haveNum = userData[costType] or 0
	local txt = self:getUI("bg.reflashBtn.txt")
	if haveNum>=cost then
		txt:setColor(UIUtils.colorTable.ccUIBaseColor2)
	else
		txt:setColor(UIUtils.colorTable.ccUIBaseColor6)
	end
end


function TeamHolyShopView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"RuneCoin","Gold","Gem"},titleTxt = "圣徽"}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
end

function TeamHolyShopView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end
function TeamHolyShopView:onTop()
    self._viewMgr:enableScreenWidthBar()
end
function TeamHolyShopView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function TeamHolyShopView:onDestroy( )
    self._teamShopModel:setJoinShopView(false)
    self._viewMgr:disableScreenWidthBar()
	if self._closeCallback then
		self._closeCallback(self._isChange)
	end
    TeamHolyShopView.super.onDestroy(self)
end

return TeamHolyShopView