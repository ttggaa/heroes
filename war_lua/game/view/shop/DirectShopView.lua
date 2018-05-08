


local DirectShopView = class("DirectShopView",BaseView)


DirectShopView.limitType = {
	"每天限购",
	"每周限购",
	"限购",
	"限购"
}
local locationIndex = 0
local needCount

local discountToCn = {
    "一折","二折","三折",
    "四折","五折","六折",
    "七折","八折","九折",
}

local titleTxt = {
    "爆款热卖",
    "每日福利",
    "优选福利",
    "至尊专享",
    "直购特惠",
}
local table_insert = table.insert
local table_nums = table.nums

function DirectShopView:ctor(param)
	local param = param or {}
	DirectShopView.super.ctor(self)
    self.initAnimType = 4
    self._idx = param.idx or 1 --默认进来显示新品商店
    self.firstIn = nil
    self._isHideOutItem = true
    self._curentBuyData = nil
    

    self.tabCount = 5
    self._driectModel = self._modelMgr:getModel("DirectShopModel")
    self._isInBackGround = false
    self._aniItemList = nil
    
    needCount = tab:Setting("G_SPECIALSHOP_CONVENIENT").value
end

function DirectShopView:getRegisterNames()
    return {
        {"leftBar","bg.leftBar"},
}
end

function DirectShopView:onInit()

	self:addAnimBg()

	self.leftStatusBar = {}
    self.redNode = {}
    self._totalData = self._modelMgr:getModel("DirectShopModel"):getData()
    dump(self._totalData,"self._totalData===》",10)
    local keys = {}
    for key,data in pairs (self._totalData) do 
        if table_nums(data) > 0 then
            table_insert(keys,key)
        end
    end
    self._typeKeys = keys
    local redInfo = self._driectModel:getDirectShopRedInfo()
    dump(redInfo,"================",10)
	for i=1,self.tabCount do 
		local btnFlag = self:getUI("bg.leftBar.chooseImage"..i)
		table_insert(self.leftStatusBar, btnFlag)
        local redNode = self:getUI("bg.leftBar.red"..i)
        if i == self._idx then
            btnFlag:setVisible(true)
            self._driectModel:cickTab(self._typeKeys[self._idx])
            redNode:setVisible(false)
        else
            if self._typeKeys[i] and redInfo[self._typeKeys[i]] == true then
                redNode:setVisible(true)
            else
                redNode:setVisible(false)
            end
        end
        table_insert(self.redNode,redNode)

		local btn = self:getUI("bg.leftBar.btn"..i)
		self:registerClickEvent(btn, function(sender) self:tabButtonClick(sender,i) end)

        local barName = self:getUI("bg.leftBar.lable"..i)
        barName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	end

    self._tabTeHui = self:getUI("bg.leftBar.btn3")
    self._line4 = self:getUI("bg.leftBar.line4")
    self._labelTehui = self:getUI("bg.leftBar.lable3")

	self.cellListItem = self:getUI("listItem")
    self._dropWithNavigation = self:getUI("bg.leftBar")
    self._dropWithNavigation:setPositionX(self._dropWithNavigation:getPositionX()+(960-MAX_SCREEN_WIDTH)/2)
    self._dropWithNavigationOffY = 40
    --middleBG 适配
    local middleBg = self:getUI("bg.middel_bg")
    if middleBg then
        middleBg:setVisible(false)
        -- middleBg:setContentSize(MAX_SCREEN_WIDTH,middleBg:getContentSize().height)
        -- middleBg:setPositionY(middleBg:getPositionY()-20)
    end
    


	self:addTableView()

    

    self.tipsPanel = self:getUI("bg.tipPanel")
    local mc = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc:setPosition(cc.p(self.tipsPanel:getContentSize().width / 2, self.tipsPanel:getContentSize().height / 2))
    self.tipsPanel:addChild(mc)
    self.tipsPanel:setPositionX(self.tipsPanel:getPositionX()+(MAX_SCREEN_WIDTH-960)/2)
    self.tipsPanel:setVisible(false)

    --窗口动画参数
    self._playAnimBg = self:getUI("bg.table_panel")
    self._playAnimBgOffX = 700
    

    


    self._mask = self:getUI("mask")
    if self._mask then
        self._mask:setVisible(false)
    end
    
    --五点刷新
    self:registerTimer(5,0,1,function(  )
        self:regetServerData()
    end)

 end

 function DirectShopView:regetServerData()
    self.firstIn = false
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "zhigou"}, true, {}, function(result)
        local directModel = self._modelMgr:getModel("DirectShopModel")
        local openDay = math.floor(self._modelMgr:getModel("UserModel"):getOpenServerTime()/86400)
        local open_day = directModel:getOpenDay()
        if not open_day then
            open_day = openDay
            directModel:setOpenDay(openDay)
        end
        print("cleanRedStatus 1111111111111111111111111222")
        print(open_day)
        print(openDay)
        if open_day and openDay then
            if open_day ~= openDay then
                print("cleanRedStatus 1111111111111111111111111")
                directModel:cleanRedStatus()
                directModel:setOpenDay(openDay)
                directModel:checkRedInfo()
            end
        end
    end)
 end

 function DirectShopView:getCurData()
    if self._idx == 1 then
        local data = {}
        if not self._totalData[1] then self._totalData[1] = {} end
        for k, v in pairs (self._totalData[1]) do 
            table_insert(data,v)
            if k >= 4 then
                break
            end
        end
        self._curData = data
    else
        self._curData = self._totalData[self._typeKeys[self._idx]] or {}
    end

 end

function DirectShopView:reflashShopInfo()
    

    self._totalData = self._modelMgr:getModel("DirectShopModel"):getData()
    local keys = {}
    for key,data in pairs (self._totalData) do 
        if table_nums(data) > 0 then
            table_insert(keys,key)
        end
    end
    -- dump(self._totalData,"self._totalData",10)
    dump(keys,"=============key",10)
    self._typeKeys = keys
    local tabCount = table.nums(keys)

    for i=1,self.tabCount do 
        local lable = self._leftBar:getChildByFullName("lable"..i)
        local line = self._leftBar:getChildByFullName("line"..(i+1))
        local btn = self._leftBar:getChildByFullName("btn"..i)
        if i > tabCount then
            lable:setVisible(false)
            line:setVisible(false)
            btn:setVisible(false)
        else
            lable:setVisible(true)
            line:setVisible(true)
            btn:setVisible(true)
            lable:setString(titleTxt[keys[i]])
        end
    end

    --隐藏多余的组件
    -- if tabCount < self.tabCount then
    --     for i=tabCount+1,self.tabCount do 
    --         local lable = self._leftBar:getChildByFullName("lable"..i)
    --         lable:setVisible(false)
    --         local line = self._leftBar:getChildByFullName("line"..(i+1))
    --         line:setVisible(false)
    --         local btn = self._leftBar:getChildByFullName("btn"..i)
    --         btn:setVisible(false)
    --         local red = self._leftBar:getChildByFullName("red"..i)
    --         red:setVisible(false)
    --     end
    -- end
    

    self:getCurData()
    -- 如何第三个页签没有商品，则隐藏标签

    -- local data_tehui = self._totalData[3]
    -- -- dump(data_tehui)
    -- if not data_tehui or table.nums(data_tehui) <= 0 then
    --     if self._tabTeHui then
    --         self._tabTeHui:setVisible(false)
    --     end
    --     if self._line4 then
    --         self._line4:setVisible(false)
    --     end
    --     if self._labelTehui then
    --         self._labelTehui:setVisible(false)
    --     end
    -- else
    --     if self._tabTeHui then
    --         self._tabTeHui:setVisible(true)
    --     end
    --     if self._line4 then
    --         self._line4:setVisible(true)
    --     end
    --     if self._labelTehui then
    --         self._labelTehui:setVisible(true)
    --     end
    -- end
    self:refreshButNotReload()
    local index = math.min(locationIndex,math.max(#self._curData-4,0))

   if not self._aniItemList then
        self._aniItemList = {}
        local count = math.min(4,#self._curData)
        for i=0,count-1 do
            local item 
            if self._tableView:cellAtIndex(i+index) then
                item = self._tableView:cellAtIndex(i+index):getChildByName("CellItem")
            end
            
            if item then
                -------------------隐藏特效----------------------
                local listItem = item:getChildByFullName("listItem")
                local iconBg = listItem:getChildByFullName("iconBg")
                if iconBg:getChildByName("awardIcon1") then
                    local iconColor = iconBg:getChildByName("awardIcon1"):getChildByName("iconColor")
                    if iconColor and iconColor:getChildByName("bgMc") then
                        iconColor:getChildByName("bgMc"):setVisible(false)
                    end
                end
                ----------------------隐藏富文本-------------------------
                -- local richBg = listItem:getChildByFullName("richBg")
                -- if richBg then
                --     -- richBg:setVisible(false)
                --     -- richBg:setCascadeOpacityEnabled(true,true)
                -- end
                table_insert(self._aniItemList,item)
            end
        end
        self._animCellOff = -270
    end

    self:onGetGift()
    self:refreshRedInfo()
end


function DirectShopView:refreshRedInfo()

    print("DirectShopView:refreshRedInfo 1")
    local redInfo = self._driectModel:getDirectShopRedInfo()
    for i=1,self.tabCount do 
        local redNode = self:getUI("bg.leftBar.red"..i)
        if i == self._idx then
            self._driectModel:cickTab(self._typeKeys[self._idx])
            redNode:setVisible(false)
        else
            if self._typeKeys[i] and redInfo[self._typeKeys[i]] == true then
                redNode:setVisible(true)
            else
                redNode:setVisible(false)
            end
        end
    end
end




function DirectShopView:beforePopAnim()

end

function DirectShopView:checkTableOffSet()
    self._isHideOutItem = nil
    local outIndex = 0
    for index,data in pairs (self._curData) do 
        if data.buyTimes <= 0 then
            local _type = tab:CashGoodsLib(data.goodsid).type
            if _type and _type ~= 2 then
                outIndex = index
            else
                break
            end
        else
            break
        end
    end

    local minX = self._tableView:minContainerOffset().x
    local offX = -236*outIndex
    local finalOffX = math.max(offX,minX)
    self._tableView:setContentOffset(cc.p(finalOffX,0))
    locationIndex = outIndex
end


function DirectShopView:refreshButNotReload()
    if self.firstIn then
        local contentOff = self._tableView:getContentOffset()
        self._tableView:reloadData()
        self._tableView:setContentOffset(contentOff)
    else
        self.firstIn = true
        self._tableView:reloadData()
    end
    if self._isHideOutItem then
        self:checkTableOffSet()
    end
    
    -- print("---------------------------------"..self._tableView:getContentOffset().x)
    -- print("...."..self._tableView:minContainerOffset().x)
end

function DirectShopView:tabButtonClick(sender,btnIndex,isFirst)
	printf("senderName = %s , btnIndex = %d",sender:getName(),btnIndex)
	local function showChooseImage(index)
		if not self.leftStatusBar then return end
		for imageIndex,imageNode in pairs (self.leftStatusBar) do 
			if index == imageIndex then
				imageNode:setVisible(true)
			else
				imageNode:setVisible(false)
			end
		end
	end
	if (self._totalData and self._idx ~= btnIndex and self._tableView) or isFirst then
		showChooseImage(btnIndex)
        self._isHideOutItem = true
		self._idx = btnIndex
		-- self._curData = self._totalData[self._idx] or {}
        self:getCurData()
		self._tableView:reloadData()
        self:checkTableOffSet()
        self._driectModel:cickTab(self._typeKeys[self._idx])
        self.redNode[btnIndex]:setVisible(false)
	end

end


--[[
用tableview实现
--]]
function DirectShopView:addTableView()
    local tableViewBg = self:getUI("bg.table_panel")
    local bg = self:getUI("bg")


    local gap = (MAX_SCREEN_WIDTH-960)/2
    local adjust = 25
    local width_,height_ = bg:getContentSize().width,bg:getContentSize().height
    local width = width_ - (self._dropWithNavigation:getPositionX()+self._dropWithNavigation:getContentSize().width)+gap+adjust
    
    -- printf("width_ == %f , height_ == %f",width_,height_)
    -- printf("width == %f , MAX_SCREEN_WIDTH == %f",width,MAX_SCREEN_WIDTH)
    tableViewBg:setPositionX(self._dropWithNavigation:getPositionX()+self._dropWithNavigation:getContentSize().width-adjust)
    -- tableViewBg:setPositionX((960-MAX_SCREEN_WIDTH)/2)
    self._tableView = cc.TableView:create(cc.size(width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    
    tableViewBg:addChild(self._tableView)

end


function DirectShopView:scrollViewDidScroll(view)

    local maxX = view:minContainerOffset().x
    local curX = view:getContentOffset().x
    if math.abs(maxX) <= math.abs(curX)+20 then
        self.tipsPanel:setVisible(false)
    else
        self.tipsPanel:setVisible(true)
    end
end


function DirectShopView:scrollViewDidZoom(view)
end

function DirectShopView:tableCellTouched(table,cell)
end

function DirectShopView:numberOfCellsInTableView(view)
	return #self._curData
end

function DirectShopView:cellSizeForTable(table,idx)
	return 418,236
end

function DirectShopView:tableCellAtIndex(table,idx)
	-- print("DirectShopView:tableCellAtIndex")
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local item = cell:getChildByName("CellItem")
    if item == nil then
        item = self:cloneItem()
        item:setPosition(cc.p(0,0))
        cell:addChild(item)
        item:setName("CellItem")
    else
        self:clearItem(item)
    end

    self:updateItem(item,idx+1)
    return cell
end

function DirectShopView:clearItem(item)

end

function DirectShopView:cloneItem()
    local clone = self.cellListItem:clone()
    clone:setVisible(true)
    clone:setAnchorPoint(cc.p(0,0))
    return clone
end

function DirectShopView:setCountTime(node,Label,leftTime)
    -- printf("DirectShopView:setCountTime == %d",leftTime)
    local tempTime = leftTime
    node:stopAllActions()
    node:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempTime = tempTime - 1
            local timeDes = self:getSingleTimeByFormath(tempTime)
            Label:setString(timeDes)
        end),cc.DelayTime:create(1))
    ))
end

function DirectShopView:getSingleTimeByFormath(timeNum)
    if not timeNum then
        return
    end
    timeNum = math.max(0,timeNum)
    local timeDes = ""
    if timeNum > 82800 then
        timeDes = math.ceil(timeNum/86400) .. "天"
    elseif timeNum > 3540 then
        timeDes = math.ceil(timeNum/3600) .. "小时"
    else
        timeDes = math.ceil(timeNum/60) .. "分钟"
    end
    return timeDes
end


function DirectShopView:getLeftTime(endTime)
    local time_ = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local leftTime = math.max(0,endTime - time_)
    return leftTime
end

function DirectShopView:showAnim()
    
end



function DirectShopView:updateItem(clone,index)
	local data = self._curData[index]
    if not data then return end
    local item = clone:getChildByFullName("listItem")
    local bgImage = item:getChildByFullName("bgImage")
    local limitTimeBg = item:getChildByFullName("limit_time")
    local leftTime = limitTimeBg:getChildByFullName("time")
    local iconBg = item:getChildByFullName("iconBg")
    local name = item:getChildByFullName("name")
    local sell_out = clone:getChildByFullName("sell_out")
    local have_buy = clone:getChildByFullName("have_buy")
    local richBg = item:getChildByFullName("richBg")
    local mask = clone:getChildByFullName("mask")
    local active = item:getChildByFullName("active")
    local leftTimeLabel = item:getChildByFullName("leftTime")
    local weekLeft = item:getChildByFullName("weekLeft")
    local week_day = weekLeft:getChildByFullName("day")
    local Label_33 = weekLeft:getChildByFullName("Label_33")
    Label_33:setColor(cc.c3b(255,255,255))
    sell_out:setVisible(false)
    have_buy:setVisible(false)
    active:setVisible(false)
    mask:setVisible(false)
    leftTimeLabel:setVisible(false)
    weekLeft:setVisible(false)
    week_day:setVisible(false)
    local week_day_copy
    if not item:getChildByName("week_day_copy") then
        week_day_copy =  week_day:clone()
        item:addChild(week_day_copy)
        week_day_copy:setPosition(weekLeft:getPositionX()+50,weekLeft:getPositionY())
        week_day_copy:setName("week_day_copy")
    else
        week_day_copy = item:getChildByName("week_day_copy")
    end
    week_day_copy:setVisible(false)

    local left_ = self:getLeftTime(data.leftTime)
    if left_ and left_ <=  31536000 then
    	limitTimeBg:setVisible(true)
        bgImage:loadTexture("shop_listBgLimite.png",1)
        local time = self:getSingleTimeByFormath(left_)
    	leftTime:setString(time)
        self:setCountTime(item,leftTime,left_)
    else
        bgImage:loadTexture("shop_listBg.png",1)
    	limitTimeBg:setVisible(false)
    end

    local _paramData = {}
    local goodsID = data.goodsid
    local goodsLibData = tab:CashGoodsLib(goodsID)
    local goodsLibReward = goodsLibData.reward
    local rmbPrice = goodsLibData.cash
    local itemId = goodsLibReward[2]
    local rewardType = goodsLibReward[1]
    local ios_pid = goodsLibData.payment_ios

    print("itemId"..itemId)
    local toolD
    if rewardType == "hero" then
        toolD = tab:Hero(itemId)
    elseif rewardType == "team" then
        toolD = tab:Team(itemId)
    else
        if rewardType == "tool" then
            toolD = tab:Tool(itemId)
        else
            itemId = IconUtils.iconIdMap[goodsLibReward[1]]
            toolD = tab:Tool(itemId)
        end
    end
    _paramData.toolD = toolD
    _paramData.rewardType = rewardType
    _paramData.itemId = itemId 
    local des = lang(goodsLibData.des) 
    local itemName = lang(toolD.name)
    -- print("itemName",itemName,"name",toolD.name)
    if itemName == "" then
        itemName = lang(toolD.heroname) 
    end
    if GameStatic.appleExamine == true then
        itemName = lang(goodsLibData.des)
    end
    _paramData.name      = itemName
    _paramData.price     = data.gemprice
    _paramData.leftTimes = data.buyTimes
    -- _paramData.needCount = data.needCount
    _paramData.id        = data.id

    local num = goodsLibReward[3]
    local tipsType = data.tipstype
    local eventType = 4
    if tipsType == 2 then --特殊tip道具，不显示数量
        if num <= 1 then
            num = nil
        end
        eventType = 3
    end
    _paramData.num = num
    local goodsType = goodsLibData.type

    local icon
    local function itemCallback()
        printf("点击 == %d",tipsType)
        if tipsType == 1 then
            -- local color = ItemUtils.findResIconColor(itemId,num)
            -- local mask 
            -- if self._mask then
            --     mask = self._mask:clone()
            --     mask:setVisible(true)
            -- end
            -- local view = self._viewMgr:showHintView("global.GlobalTipView",{tipType = 1, node = icon,forceColor = color, id = itemId,posCenter = true})
            -- if mask then
            --     view:addChild(mask,-1)
            -- end
        else
            local param = {}
            param.giftID = goodsLibReward[2]
            param.currency = data.currency
            param.gemPrice = data.gemprice
            param.rmbPrice = rmbPrice
            param.confirm  = data.confirm
            param.id = data.id
            param.leftTimes = data.buyTimes
            param.confirm = data.confirm
            param.num = num or 1
            param.name = itemName
            param.des = des
            param.endTime = data.leftTime
            param.ios_pid = ios_pid
            param.batchData = _paramData
            param.discount1 = data.discount1
            param.discount2 = data.discount2
            self._Dialog = self._viewMgr:showDialog("shop.DirectShopDialog",param,true)
        end
        
    end

    local awardIcon = iconBg:getChildByName("awardIcon") --hero
    local awardIcon1 = iconBg:getChildByName("awardIcon1") -- tool
    local awardIcon2 = iconBg:getChildByName("awardIcon2") --team
    if awardIcon then
        awardIcon:setVisible(false)
    end
    if awardIcon1 then
        awardIcon1:setVisible(false)
    end
    if awardIcon2 then
        awardIcon2:setVisible(false)
    end

    if rewardType == "hero" then
        local param = {sysHeroData = toolD, effect = false}
        if awardIcon then
            awardIcon:setVisible(true)
            IconUtils:updateHeroIconByView(awardIcon, param)
        else
            icon = IconUtils:createHeroIconById(param)
            icon:setName("awardIcon")
            icon:setAnchorPoint(0.5,0.5)
            icon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2)
            icon:setScale(92/icon:getContentSize().width)
            iconBg:addChild(icon)
        end
        iconBg:setTouchEnabled(true)
        registerClickEvent(iconBg, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
        end)
        iconBg:setSwallowTouches(false)
    elseif rewardType == "team" then
        -- dump(toolD,"aaa",10)
        -- local sysTeam = clone(toolD)
        iconBg:setTouchEnabled(false)
        if awardIcon2 then
            awardIcon2:setVisible(true)
            IconUtils:updateSysTeamIconByView(awardIcon2,{sysTeamData = toolD,isGray = false,isJin = true})
        else
            icon = IconUtils:createSysTeamIconById({sysTeamData = toolD,isGray = false,isJin = true})
            icon:setAnchorPoint(cc.p(0.5,0.5))
            icon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2)
            icon:setScale(92/icon:getContentSize().width)
            icon:setSwallowTouches(false)
            icon:setName("awardIcon2")
            iconBg:addChild(icon)
        end
    else
        iconBg:setTouchEnabled(false)
        if awardIcon1 then
            awardIcon1:setVisible(true)
            IconUtils:updateItemIconByView(awardIcon1,{itemId = itemId,itemData = toolD,num = num,effect = false,eventStyle = eventType,clickCallback = itemCallback})
        else
            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,effect = false,eventStyle = eventType,clickCallback = itemCallback})
            icon:setAnchorPoint(0.5,0.5)
            icon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2)
            iconBg:addChild(icon)
            icon:setName("awardIcon1")
        end
    end
    
    name:setString(itemName)
    if GameStatic.appleExamine == true then
        name:setFontSize(22)
    end
    local leftBuyTimes = data.buyTimes
    local leftDes = "/" .. data.numlimit

    
    

    -- if richBg:getChildByName("richLable") then
    --    richBg:removeChildByName("richLable")
    -- end
    --是否需要显示周卡已激活
    local isShowZhouKa = nil
    if goodsType == 2 and data.expireTime >0 then
        isShowZhouKa = true
        local time_ = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local day = math.max(0,math.floor((data.expireTime-time_)/86400))
        active:setVisible(true)
        -- local richStr = "[color=865c30]剩余时间:".."[color=1ca216]"..day .."[color=865c30]天[-]"

        

        -- local label1 = RichTextFactory:create(richStr, richBg:getContentSize().width, richBg:getContentSize().height,true)
        -- label1:formatText()
        -- label1:setPositionY(richBg:getContentSize().height/2)
        -- label1:setPositionX(richBg:getContentSize().width/2)
        -- richBg:addChild(label1,11)
        -- label1:setName("richLable")
        weekLeft:setVisible(true)
        -- weekLeft:setString("剩余时间:")
        week_day_copy:setVisible(true)
        week_day_copy:setString(day)
    else
        active:setVisible(false)
    end


    local resetType = data.reset
    -- local richStr = "[color=865c30]"..self.limitType[resetType]
    if leftBuyTimes <= 0 and not isShowZhouKa then
        -- richStr = nil
        if resetType == 1 or resetType == 2 then
            sell_out:setVisible(true)
        else
            have_buy:setVisible(true)
        end
        mask:setVisible(true)
    elseif not isShowZhouKa then
        local alreadyBuy = data.numlimit - leftBuyTimes
        -- richStr = richStr .. "[color=865c30]"..alreadyBuy
        sell_out:setVisible(false)
        have_buy:setVisible(false)
        -- richStr = richStr .. "[color=865c30]"..leftDes .."[-]"
        mask:setVisible(false)
        leftTimeLabel:setVisible(true)
        leftTimeLabel:setString(self.limitType[resetType] .. alreadyBuy .. leftDes)
    end
    

    -- if not isShowZhouKa and richStr then
        -- if richBg:getChildByName("richLable") then
        --     richBg:removeChildByName("richLable")
        -- end
        -- local label1 = RichTextFactory:create(richStr, richBg:getContentSize().width, richBg:getContentSize().height,true)
        -- label1:formatText()
        -- label1:setPositionY(richBg:getContentSize().height/2)
        -- label1:setPositionX(richBg:getContentSize().width/2)
        -- richBg:addChild(label1,11)
        -- label1:setName("richLable")
    -- end
    
    -- local gemPrice,rmbPrice
    -- gemPrice = 
    local zuanshiBtn = item:getChildByFullName("zuanshi")
    zuanshiBtn:setVisible(false)
    local zuanshiBtn_dis = zuanshiBtn:getChildByFullName("price_gem")
    zuanshiBtn_dis:setVisible(false)
    local rmbBtn = item:getChildByFullName("rmb")
    rmbBtn:setVisible(false)
    local rmbBtn_dis = rmbBtn:getChildByFullName("price_rmb")
    rmbBtn_dis:setVisible(false)
    local bothBtn = item:getChildByFullName("both")
    bothBtn:setVisible(false)
    bothBtn_rmb_dis = bothBtn:getChildByFullName("rmb.price_rmb")
    bothBtn_gem_dis = bothBtn:getChildByFullName("zuanshi.price_gem")
    bothBtn_rmb_dis:setVisible(false)
    bothBtn_gem_dis:setVisible(false)


    local currency = data.currency
    if currency == 1 or currency == 4 then --钻石消耗 or 幸运币消耗
        if leftBuyTimes > 0 and not isShowZhouKa then
            zuanshiBtn:setVisible(true)
            if data.discount1 and data.discount1 ~= -1 then
                zuanshiBtn_dis:setVisible(true)
                zuanshiBtn_dis:getChildByFullName("discount"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
                if discountToCn[data.discount1/100] then
                    zuanshiBtn_dis:getChildByFullName("discount"):setString(discountToCn[data.discount1/100])
                else
                    zuanshiBtn_dis:getChildByFullName("discount"):setString(data.discount1/100 .. "折")
                end
                
            end
        end
        self:btnTitle(zuanshiBtn,currency)
        zuanshiBtn:setTitleText("   "..data.gemprice)
        -- zuanshiBtn:setFontName(UIUtils.ttfName)
        self:registerClickEvent(zuanshiBtn, function( )
            print("1钻石购买,4幸运币购买",currency)
            local param = {}
            param.buyType = currency
            param.price = data.gemprice
            param.id = data.id
            param.left = leftBuyTimes
            param.confirm = data.confirm
            param.name = itemName
            param.des = des or ""
            param.num = num or 1
            param.endTime = data.leftTime
            param.ios_pid = ios_pid
            self._curentBuyData = _paramData
            -- self:onBuyItem(1,data.gemprice,data.id,leftBuyTimes,data.confirm)
            self:onBuyItem(param)
        end)
        zuanshiBtn:setSwallowTouches(false)
    elseif currency == 2 then --rmb消耗
        if leftBuyTimes > 0 and not isShowZhouKa then
            rmbBtn:setVisible(true)
            if data.discount2 and data.discount2 ~= -1 then
                rmbBtn_dis:setVisible(true)
                rmbBtn_dis:getChildByFullName("discount"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
                -- rmbBtn_dis:getChildByFullName("discount"):setString(discountToCn[data.discount2/100])
                if discountToCn[data.discount2/100] then
                    rmbBtn_dis:getChildByFullName("discount"):setString(discountToCn[data.discount2/100])
                else
                    rmbBtn_dis:getChildByFullName("discount"):setString(data.discount2/100 .. "折")
                end
            end
        end
        self:btnTitle(rmbBtn)
        rmbBtn:setTitleText("¥ "..rmbPrice)
        self:registerClickEvent(rmbBtn, function( )
            printf("RMB 购买")
            local param = {}
            param.buyType = 2
            param.price = rmbPrice
            param.id = data.id
            param.left = leftBuyTimes
            param.confirm = data.confirm
            param.name = itemName
            param.des = des or ""
            param.num = num or 1
            param.endTime = data.leftTime
            param.ios_pid = ios_pid
            self:onBuyItem(param)
            -- self:onBuyItem(2,rmbPrice,data.id,leftBuyTimes,data.confirm)
        end)
        rmbBtn:setSwallowTouches(false)
    else --两种消耗
        if leftBuyTimes > 0 and not isShowZhouKa then
            bothBtn:setVisible(true)
            if data.discount1 and data.discount1 ~= -1 then
                bothBtn_gem_dis:setVisible(true)
                if discountToCn[data.discount1/100] then
                    bothBtn_gem_dis:getChildByFullName("discount"):setString(discountToCn[data.discount1/100])
                else
                    bothBtn_gem_dis:getChildByFullName("discount"):setString(data.discount1/100 .. "折")
                end
                bothBtn_gem_dis:getChildByFullName("discount"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
            end
            if data.discount2 and data.discount2 ~= -1 then
                bothBtn_rmb_dis:setVisible(true)
                if discountToCn[data.discount2/100] then
                    bothBtn_rmb_dis:getChildByFullName("discount"):setString(discountToCn[data.discount2/100])
                else
                    bothBtn_rmb_dis:getChildByFullName("discount"):setString(data.discount2/100 .. "折")
                end
                bothBtn_rmb_dis:getChildByFullName("discount"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
            end
        end
        local zuanshi_ = bothBtn:getChildByFullName("zuanshi")
        local rmb_ = bothBtn:getChildByFullName("rmb")
        -- zuanshi_:setFontName(UIUtils.ttfName)
        self:btnTitle(zuanshi_)
        self:btnTitle(rmb_)
        zuanshi_:setTitleText("    "..data.gemprice)

        if rmbPrice then   --by wangyan
            rmb_:setTitleText("¥ "..rmbPrice)
        end

        
        self:registerClickEvent(zuanshi_, function( )
            printf("钻石购买")
            local param = {}
            param.buyType = 1
            param.price = data.gemprice
            param.id = data.id
            param.left = leftBuyTimes
            param.confirm = data.confirm
            param.name = itemName
            param.des = des or ""
            param.num = num or 1
            param.endTime = data.leftTime
            param.ios_pid = ios_pid
            self._curentBuyData = _paramData
            self:onBuyItem(param)
            -- self:onBuyItem(1,data.gemprice,data.id,leftBuyTimes,data.confirm)
        end)
        zuanshi_:setSwallowTouches(false)
        self:registerClickEvent(rmb_, function( )
            printf("RMB 购买")
            local param = {}
            param.buyType = 2
            param.price = rmbPrice
            param.id = data.id
            param.left = leftBuyTimes
            param.confirm = data.confirm
            param.name = itemName
            param.des = des or ""
            param.num = num or 1
            param.endTime = data.leftTime
            param.ios_pid = ios_pid
            self:onBuyItem(param)
            -- self:onBuyItem(2,rmbPrice,data.id,leftBuyTimes,data.confirm)

        end)
        rmb_:setSwallowTouches(false)
    end
end
-- 灰态
function DirectShopView:setNodeColor( node,color,bright)
    if node and not tolua.isnull(node) and node:getName() ~= "lock" then 
        if node:getDescription() ~= "Label" then
            node:setColor(color)
        else
            node:setBrightness(bright)
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

local costImg = {
    [1] = "globalImageUI_diamond.png",
    [4] = "globalImageUI_luckyCoin.png",
}
function DirectShopView:btnTitle(button,currency)
    button:setTitleFontName(UIUtils.ttfName_Number) 
    button:setColor(UIUtils.colorTable.ccUICommonBtnColor1)
    button:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
    if currency then
        local Image_39 = button:getChildByFullName("Image_39")
        if Image_39 and costImg[currency] then
            Image_39:loadTexture(costImg[currency],1)
        end
    end
end

function DirectShopView:buySuccess(result)
    dump(result)
    local buyID = result.buyId
    local cashId
    if GameStatic.appleExamine == true then
        cashId = tab:Specialshopauditing(buyID).goodsid
    else
        cashId = tab:Specialshop(buyID).goodsid
    end
    local cashData = tab:CashGoodsLib(cashId)
    local rewardData = cashData.reward
    -- local giftId = rewardData[2]
    local giftType = cashData.type
    local reward = {}
    if result.reward then
        for _,data in pairs (result.reward) do 
            if data[4] and data[4] == 1 then
                table_insert(reward,{type = data[1],typeId = data[2],num = data[3],isChange = 1})
            else
                table_insert(reward,{type = data[1],typeId = data[2],num = data[3]})
            end
        end
    end
    -- if result._rewards then
    --     if rewardData[1] == "hero" then
    --         for id,data in pairs (result._rewards) do 
    --             local type_ = "tool"
    --             if tab:Hero(tonumber(id)) then
    --                 type_ = "hero"
    --             end
    --             table.insert(reward,{type = type_,typeId = id,num = data.num})
    --         end
    --     else
    --         table.insert(reward,{type = rewardData[1],typeId = rewardData[2],num = rewardData[3]})
    --     end
    -- else
    --     table.insert(reward,{type = rewardData[1],typeId = rewardData[2],num = rewardData[3]})
    -- end
    if giftType ~= 2 then --非周卡类型
        DialogUtils.showGiftGet( {
            hide = self,
            gifts = reward,
            title = "恭喜获得",
            notPop=true,
            callback = function()
        end})
    else --周卡类型获得面板
        self._viewMgr:showDialog("shop.WeekRewardDialog",{id = rewardData[2]},true)
    end
    reward = nil
    result.reward = nil
end

--支付完成后，获得展示
function DirectShopView:applicationWillEnterForeground()
    local rmbResult = self._modelMgr:getModel("DirectShopModel"):getRmbResult()
    if rmbResult then
        self:buySuccess(rmbResult)
        self._modelMgr:getModel("DirectShopModel"):clearRmbResult()
        if self._Dialog then
            self._viewMgr:closeDialog(self._Dialog)
            self._Dialog = nil
        end
    end
    self._isInBackGround = false
end

function DirectShopView:onGetGift()
    if self._isInBackGround == false then
        local rmbResult = self._modelMgr:getModel("DirectShopModel"):getRmbResult()
        if rmbResult then
            self:buySuccess(rmbResult)
            self._modelMgr:getModel("DirectShopModel"):clearRmbResult()
            if self._Dialog then
                self._viewMgr:closeDialog(self._Dialog)
                self._Dialog = nil
            end
        end
    end
end

function DirectShopView:applicationDidEnterBackground()
    self._isInBackGround = true
end

function DirectShopView:isTimeOut(endTime)
    local time_ = self._modelMgr:getModel("UserModel"):getCurServerTime()
    return time_ >= endTime
end

--@ costType 1钻石购买 2 RMB购买 
function DirectShopView:onBuyItem(param)
    local costType = param.buyType
    local price = param.price
    local itemID = param.id
    local leftBuyTimes = param.left
    local confirmNum = param.confirm
    local name = param.name
    local des = param.des
    local num = param.num or 1
    local endTime = param.endTime 
    local ios_pid = param.ios_pid

    --剩余次数判定
    if leftBuyTimes <= 0 then
        self._viewMgr:showTip("购买次数不足！")
        return
    end

    if self:isTimeOut(endTime) then
        self._viewMgr:showTip("商品已过期")
        return
    end

    local function goBuy()
        if costType == 1 then
            printf("price == %d",price)
            local player = self._modelMgr:getModel("UserModel"):getData()
            local gemHaveCount = player.gem
            if price > gemHaveCount then
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                    local viewMgr = ViewManager:getInstance()
                    viewMgr:showView("vip.VipView", {viewType = 0})
                end})                
                return
            end

            --批量购买判断
            if leftBuyTimes > needCount then
                --满足批量购买
                self._viewMgr:showDialog("shop.DirectBatchBuyDialog",{data = self._curentBuyData,callBack = function (result)
                    self:buySuccess(result)
                end},true)
                return
            end
            self._serverMgr:sendMsg("ShopServer", "buyShopItem", {id = itemID,["type"] = "zhigou"}, true, {}, function(result)
                audioMgr:playSound("consume")
                self:buySuccess(result)
            end)
        elseif costType == 4 then
            printf("price == %d",price)
            local player = self._modelMgr:getModel("UserModel"):getData()
            local haveCount = player.luckyCoin
            if price > haveCount then
                -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                --     local viewMgr = ViewManager:getInstance()
                --     viewMgr:showView("vip.VipView", {viewType = 0})
                -- end})
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
                    DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = price - haveCount })
                end})
                return
            end

            --批量购买判断
            if leftBuyTimes > needCount then
                --满足批量购买
                self._viewMgr:showDialog("shop.DirectBatchBuyDialog",{data = self._curentBuyData,callBack = function (result)
                    self:buySuccess(result)
                end},true)
                return
            end
            self._serverMgr:sendMsg("ShopServer", "buyShopItem", {id = itemID,["type"] = "zhigou"}, true, {}, function(result)
                audioMgr:playSound("consume")
                self:buySuccess(result)
            end)
        else 
            local param1 = {}
            param1.ftype = 2
            param1.gname = des
            param1.gdes = des
            if OS_IS_IOS then
                param1.product_id = "com.tencent.yxwdzzjy."..ios_pid
            end
            param1.ext = json.encode({id = itemID, num = 1})
            price = tonumber(price)*10
            local param2 = "com.tencent.yxwdzzjy.".. ios_pid .."*".. price .."*".. 1
            self:rmbReCharge(param1,param2)
            -- self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
        end
    end

    if confirmNum >= 1 and costType == 1 then --有二次确认
        local costType_
        if costType == 1 then
            costType_ = "gem"
        elseif costType == 2 then
            costType_ = "rmb"
        elseif costType == 4 then
            costType_ = "luckyCoin"
        end
        DialogUtils.showBuyDialog({
            costNum = price,
            costType = costType_,
            goods = "购买此道具？",
            callback1 = function()
                goBuy()
            end
        })
        return
    end
    goBuy()

end

function DirectShopView:rmbReCharge(param1,param2)
    local tag = SystemUtils.loadAccountLocalData("DIRECT_NO_WARING")
    if tag and tag == 1 then
        print("rmbReCharge 1")
        self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
    else
        self._viewMgr:showDialog("shop.DirectChargeSureDialog",{callback = function ()
            print("rmbReCharge 2")
            self._modelMgr:getModel("PaymentModel"):chargeDirect(param1,param2)
        end})
    end
end

function DirectShopView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    self:getServerData()
end

function DirectShopView:getServerData()
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "zhigou"}, true, {}, function(result)
        self:getNeedBackupListFinish(result)
    end)
end

function DirectShopView:getNeedBackupListFinish(result)
    -- if result == nil then
    --     self._onBeforeAddCallback(2)
    --     return 
    -- end
    self:reflashShopInfo()
    self._onBeforeAddCallback(1)
end

function DirectShopView:setNavigation()
	self._viewMgr:showNavigation("global.UserInfoView", {types={"LuckyCoin","Gold","Gem"},forceTitleImage = "title_image.png",titleTxt = "商店"}) 
end

function DirectShopView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end


function DirectShopView:getAsyncRes()
    return 
        {
            {"asset/ui/shop.plist", "asset/ui/shop.png"},
        }
end

function DirectShopView:onAnimEnd()
    if self._aniItemList and table.nums(self._aniItemList) > 0 then
        for _,item in pairs (self._aniItemList) do
            local listItem = item:getChildByFullName("listItem")
            local iconBg = listItem:getChildByFullName("iconBg")
            if iconBg:getChildByName("awardIcon1") then
                local iconColor = iconBg:getChildByName("awardIcon1"):getChildByName("iconColor")
                if iconColor and iconColor:getChildByName("bgMc") then
                    iconColor:getChildByName("bgMc"):setVisible(true)
                end
            end
        end
    end

    -- self:listenReflash("DirectShopModel", self.reflashShopInfo)
    self:setListenReflashWithParam(true)
    self:listenReflash("DirectShopModel", self.onModelEvent)
end
function DirectShopView:onModelEvent(eventName)
    if eventName == "TeamChanged" then
        self:regetServerData()
    else
        self:reflashShopInfo()
    end
end

function DirectShopView:getBgName()
    return "bg_007.jpg"
end

function DirectShopView:dtor()
    locationIndex = nil
    needCount = nil
    discountToCn = nil
end

return DirectShopView