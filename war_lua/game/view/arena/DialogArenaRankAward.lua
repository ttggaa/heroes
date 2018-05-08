--[[
    Filename:    DialogArenaRankAward.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-29 10:24:54
    Description: File description
--]]

local DialogArenaRankAward = class("DialogArenaRankAward",BasePopView)
function DialogArenaRankAward:ctor()
    self.super.ctor(self)
    self._arenaModel = self._modelMgr:getModel("ArenaModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogArenaRankAward:onInit()

	self:registerClickEventByName("bg.closeBtn", function ()
		if self._closeCallback then
			self._closeCallback()
		end
        self:close()
        UIUtils:reloadLuaFile("arena.DialogArenaRankAward")

    end)
    UIUtils:setTitleFormat(self:getUI("bg.titleBg.title"),1)
	self:getUI("bg"):setOpacity(255)
	self:getUI("bg"):setBackGroundImageOpacity(255)
    self._item = self:getUI("bg.item")
   	self._des1 = self:getUI("bg.bg2.desBg.des1")
   	self._des1:setFontName(UIUtils.ttfName)
   	self._des2 = self:getUI("bg.bg2.desBg.des2")
   	self._des2:setFontName(UIUtils.ttfName)

    self._item:setVisible(false)

    self._goldLab = self:getUI("bg.bg2.desBg.goldLab")
    self._goldLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- self._goldLab:setFntFile(UIUtils.bmfName_zhandouli)
    self._rank = self:getUI("bg.bg2.rankNum")
 
    self._tableNode = self:getUI("bg.tableNode")
	self._noAward_txt = self:getUI("bg.bg2.noAward_txt")
	self._noAward_txt:setFontName(UIUtils.ttfName)
	
    -- self:listenReflash("ArenaModel",self.reflashUI)
    -- self:listenReflash("UserModel",self.reflashUI)
    -- 递进刷新控制
	self._beginIdx = 1
	self._endIdx = 5
	self.addStep = 5

    local awardD = tab["arenaHighShop"]
	table.sort(awardD,function( a,b )
		return a.ranklim > b.ranklim
	end)
	self.rank = math.min(self._arenaModel:getData().rank or 1,10000)
	self._tableCellW,self._tableCellH = self._item:getContentSize().width,self._item:getContentSize().height+4
	self._tableData = awardD
	self._storeTbData = awardD

	self._awardGet = {}
	self._scrollView = self:getUI("bg.bg2.awardScroll")
	-- self:updateGetData(self._tableData)

	self._times = {}
	self:addTableView()	
	self._offsetX = 0
	self._offsetY = 0
    self:getInitPos()
    if self._modelMgr:getModel("ArenaModel"):haveAward() then
	    SystemUtils.saveAccountLocalData("arena_showAwardOnce", true)
	end
end

-- 换 tableView
function DialogArenaRankAward:addTableView()
    local tableView = cc.TableView:create(cc.size(self._tableNode:getContentSize().width, self._tableNode:getContentSize().height-20))
   	-- tableView:setColor(cc.c3b(255,255,255))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(5,12))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableNode:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)

    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)

    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)

    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)

    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    tableView:reloadData()
    self._tableView = tableView
end

function DialogArenaRankAward:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
	
	self._offsetX = view:getContentOffset().x
	self._offsetY = view:getContentOffset().y
	-- print("====================view:getContentOffset().y---------",view:getContentOffset().y)
end

function DialogArenaRankAward:scrollViewDidZoom(view)
end

function DialogArenaRankAward:tableCellTouched(table,cell)
end

function DialogArenaRankAward:cellSizeForTable(table,idx) 
    return self._tableCellH,self._tableCellW
end

function DialogArenaRankAward:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local item = self:createItem(self._tableData[idx+1])
    if item then
	    item:setPosition(cc.p(8,0))
	    item:setAnchorPoint(cc.p(0,0))
	    cell:addChild(item)
	end
	if type(self._timeFuc) == "function" then
		self._timeFuc()
	end
    return cell
end

function DialogArenaRankAward:numberOfCellsInTableView(table)
   return #self._tableData
end

-- 接收自定义消息
function DialogArenaRankAward:reflashUI(data)
	if data then 
		self._closeCallback = data.closeCallback or self._closeCallback
	end
	local offsetX = self._offsetX
	local offsetY = self._offsetY
	local arenaD = self._arenaModel:getArena()
	self._currency = self._modelMgr:getModel("UserModel"):getData().currency
	self.rank = math.min(self._arenaModel:getData().rank or 1,10000)
	-- self._goldLab:setString(self._currency)
	self._rank:setString(self.rank)
	local arenaShopD = self._arenaModel:getArenaShop().shop1
    if not arenaShopD then
		self._shopSchedule = ScheduleMgr:regSchedule(50, self, function(self, dt)
  	        local arenaShopD = self._arenaModel:getArenaShop().shop1
			if arenaShopD then
				ScheduleMgr:unregSchedule(self._shopSchedule)
				self:reflashUI()
			end
  	    end) 
    end
	self._arenaShopD = arenaShopD
	if not self._arenaShopD then
		self._tableData = {} 
		self._tableView:reloadData()
		self._tableView:setContentOffset(cc.p(offsetX,offsetY))
		return 
	else
		self._tableData = self._storeTbData
	end
	self._curLimit = 0
	if #self._tableData > 0 then
		for k,v in pairs(self._tableData) do
			local lim = v.ranklim or 0
			if lim >= self.rank then 
				self._curLimit = lim
			end
		end
		--lang(toolD.name) or "无名字"
		self._tableView:reloadData()
		self._tableView:setContentOffset(cc.p(offsetX,offsetY))
	end
	-- dump(self._arenaShopD)
	self:initGetAwardData(self._arenaShopD)

end

function DialogArenaRankAward:createItem( data,idx )
	local arenaShopD = self._arenaShopD
	if data == nil or arenaShopD == nil then return end
	item = self._item:clone()
	item:setVisible(true)
	item:setSwallowTouches(false)
	
	item.data = data
	---[[todo : 创建物品
	local itemIcon = item:getChildByFullName("itemIcon")
	local reward = data.reward or {}
	local rewardColor = 0 
	for i,v in ipairs(reward) do
		local itemId 
		if v[1] == "tool" then
			itemId = v[2]
		else
			itemId = IconUtils.iconIdMap[v[1]]
		end
		local toolD = tab:Tool(tonumber(itemId))
		if rewardColor <( toolD.color or 0) then
			rewardColor = toolD.color or 0 
		end
		local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
		icon:setScale(0.75)
		itemIcon:setSwallowTouches(false)
		-- icon:setPosition(cc.p((i-1)%2*65-6,40-math.floor((i-1)/2)*65))
		icon:setPosition(cc.p((i-1)*78+12,0))
		itemIcon:addChild(icon)
	end
	
	-- bgImage:setScale9Enabled(true)
 --    bgImage:setCapInsets(cc.rect(50,80,1,1))

	local getImg = item:getChildByFullName("getImg")
	-- local zhezhao = item:getChildByFullName("zhezhao")
	
	local itemNameRank = item:getChildByFullName("itemNameRank")
	local lim = data.ranklim or 0 --lang(toolD.name) or "无名字"	
	itemNameRank:setString(lim)
	itemNameRank:setZOrder((self.rank <= lim) and 1 or 10)
	local itemName1 = item:getChildByFullName("itemName1")
	itemName1:setPositionX(itemNameRank:getPositionX()+itemNameRank:getContentSize().width)
	
	local cost = data.cost or 0
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local arenaShopD = self._arenaModel:getArenaShop().shop1 or {}
	local currency = userData["currency"]	
	local exchangeBtn = item:getChildByFullName("exchangeBtn")
	self:L10N_Text(exchangeBtn)

	local costImg = item:getChildByFullName("costImg")
	local costNum = item:getChildByFullName("costNum")
	local btntitleBg = item:getChildByFullName("btntitleBg")
	costNum:setString(cost)
	
	costImg:setVisible(arenaShopD[tostring(data.id)] == nil)
	costNum:setVisible(arenaShopD[tostring(data.id)] == nil)
	btntitleBg:setVisible(arenaShopD[tostring(data.id)] == nil)
	exchangeBtn:setVisible(arenaShopD[tostring(data.id)] == nil )

	local colorIndex = self:getBoardColorIndex(data.ranklim)
	local bgImage = item:getChildByFullName("bgImage")	
	local imageName
	if arenaShopD[tostring(data.id)] then
		imageName = "globalPanelUI7_cellBg22.png"
	-- elseif self.rank <= lim and cost <= currency then
	-- 	imageName = "globalPanelUI7_cellBg20.png"
	end
	if imageName then
		bgImage:loadTexture(imageName,1)
	end

	if self.rank > lim then
	    UIUtils:setGray(exchangeBtn,true)
	    -- costNum:setColor(cc.c4b(250,230,200,255))
	else
		costNum:setColor((cost <= currency) and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor6 )
	end

	self:registerClickEvent(exchangeBtn, function ()    
		if self.rank > lim then
			self._viewMgr:showTip(lang("TIPS_AWARDS_01"))
		elseif cost > currency then
			self._viewMgr:showTip(lang("TIPS_AWARDS_02"))
		else
			if arenaShopD[tostring(data.id)] == nil and self.rank <= lim then
				--弹出二级确认框
				local desc = "[color=3d1f00,fontsize=22]是否消耗[pic=globalImage_littleJingjibi.png][-]"  .. cost .. "进行奖励兑换？[-]"
				self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = desc, button1 = "", callback1 = function( )
			            self._serverMgr:sendMsg("ArenaServer", "exchangeShop", {id = tostring(data.id)}, true, {}, function(result) 
				           	if not self or tolua.isnull(exchangeBtn) then return end
				           	if  result.errorCode and 0 ~= result.errorCode then 
				                self._viewMgr:showTip(lang("TIPS_ARENA_05"))
				            else
				            	--隐藏按钮和条件
				            	exchangeBtn:setVisible(false)
				            	costNum:setVisible(false)
				            	costImg:setVisible(false)
				           		self:playGetAnim(data.id,result)  
				            end         
				        end)
			        end, 
			        button2 = "",titileTip=true},true)				
			end
		end		
    end)
	self._times[tostring(data.id)] = {}		
	self._times[tostring(data.id)].timeCount = timeCount
	self._times[tostring(data.id)].goldImg = goldImg
	self._times[tostring(data.id)].getImg = getImg
	-- self._times[tostring(data.id)].zhezhao = zhezhao
	

	if arenaShopD[tostring(data.id)] then
		getImg:setVisible(true)
		-- zhezhao:setVisible(true)
		
		self._times[tostring(data.id)].canExchange = false
		self._times[tostring(data.id)].hadExchanged = true		
	else 
		if self.rank <= lim then			
			-- zhezhao:setVisible(false)
			self._times[tostring(data.id)].canExchange = true	
		else			
			self._times[tostring(data.id)].canExchange = false			
		end
		getImg:setVisible(false)		
		self._times[tostring(data.id)].hadExchanged = false

	end	
	-- zhezhao:setVisible(false)
	-- [[ 平台好友功能 2017.1.9 by guojun

	local friends = self._modelMgr:getModel("ArenaModel"):getFriendInRank(data.ranklim) or {}
	local friendPanel = item:getChildByFullName("friendPanel")
	local noFriendsImg = item:getChildByFullName("friendPanel.nothing")
	local friendBg = item:getChildByFullName("friendPanel.friendBg")
	noFriendsImg:setVisible(false)
	friendBg:setVisible(false)

	friendPanel:setSwallowTouches(false)
	friendBg:setSwallowTouches(false)

	-- dump(friends,"friends",5)
	if friends and #friends > 0 then
		friendBg:setVisible(true)
		friendBg:setTouchEnabled(true)
		local friendData = friends[1]
		local headIcon = friendBg:getChildByFullName("headIcon")
		headIcon:setSwallowTouches(false)
	    if headIcon then
	    	-- dump(friendData,"friendData====")
	        local param1 = {url = friendData.picUrl,openid=friendData.openid or 1,tp=4}
	        local icon = headIcon:getChildByName("icon")
	        if not icon then
	            icon = IconUtils:createUrlHeadIconById(param1)
	            icon:setScale(0.5)
	            icon:setName("icon")
	            icon:setPosition(cc.p(4, 0))
	            headIcon:addChild(icon)
	        else
	            IconUtils:updateUrlHeadIconByView(icon, param1)
	        end
	    end

    	local nameTxt = friendBg:getChildByFullName("nameTxt")
    	-- nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    	nameTxt:setString(friends[1].nickName)

		local friendNumLab = friendBg:getChildByFullName("dexTxt")
		friendNumLab:setTextHorizontalAlignment(1)
		-- friendNumLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

		friendNumLab:setString("您有" .. #friends  .. "个好友在此")

		self:registerClickEvent(friendBg,function() 
			if #friends > 0 then
				self._viewMgr:showDialog("arena.DialogArenaFriendView",{friends=friends, rankTab = data.ranklim})
			end
		end)
	else
		noFriendsImg:setVisible(true)
	end
	--]]
	return item
end

function DialogArenaRankAward:playGetAnim(id,result)
	local getImg = self._times[tostring(id)].getImg
	-- local zhezhao = self._times[tostring(id)].zhezhao 
	getImg:setVisible(true)
	-- zhezhao:setVisible(true)
    getImg:setScale(3)
	local action = cc.Sequence:create(cc.ScaleTo:create(0.1,0.8),cc.ScaleTo:create(0.02,1),cc.DelayTime:create(0.02),
						cc.CallFunc:create(function()
						self._beginIdx = 1
						self._modelMgr:getModel("UserModel"):updateUserData(result.d or {})
						-- dump(result.rewards)
						if result.rewards then	
				            DialogUtils.showGiftGet(result.rewards or {})
			            end	
			            self:reflashUI() 
					end))
	getImg:runAction(action)
end

function DialogArenaRankAward:getInitPos()
	local arenaShopD = self._arenaModel:getArenaShop().shop1
	local height = self._tableCellH*(#self._tableData) - (self._tableNode:getContentSize().height-15)
	self._offsetY = (-1)*height
	if not arenaShopD  then return end
	for i=1,table.nums(arenaShopD) do
		if arenaShopD[tostring(i)] ~= nil then
			self._offsetY = (height - (tonumber(i) - 1)*self._tableCellH) *(-1)
			self._offsetY = self._offsetY < 0 and self._offsetY or 0
		else
			break
		end
	end	
end
-- 获得板子和名字的颜色索引号
function DialogArenaRankAward:getBoardColorIndex( rank )
    if not self._boardNameColorMap then
        -- self._boardNameColorMap = {1000000000,3000,300,60,10,1,0} -- 白绿蓝紫橙红
        self._boardNameColorMap = tab:Setting("G_ARENA_AWARDS_COLOR").value
    end
    -- local colorData = {cc.c4b(255,200,150,255),cc.c4b(0,255,40,255),cc.c4b(0,150,255,255),
    -- 					cc.c4b(250,40,250,255),cc.c4b(255,120,0,255),cc.c4b(255,50,50,255)}-- 白绿蓝紫橙红
    
    -- local saturationValue = {-40,-20,0,0,0,5}
    -- local hueValue = {-5,80,180,-100,0,-25}
    local index = 1
    for i,v in ipairs(self._boardNameColorMap) do
        if rank > v then
            break
        end
        index = i
    end
    return index
    -- return saturationValue[index] ,hueValue[index]

end

function DialogArenaRankAward:onDestroy()
	-- if self._timer then
	-- 	ScheduleMgr:unregSchedule(self._timer)
	-- 	self._timer = nil
	-- end
	self.super.onDestroy(self)
end
function DialogArenaRankAward:initGetData()
		-- body
end	

function DialogArenaRankAward:initGetAwardData(shopData)
	-- if not shopData then return end
	self._awardGet = {}		
	-- dump(shopData,"shopData")
	local getArr = {}
	local dataHighShop = tab["arenaHighShop"]
	for k,v in pairs(shopData) do
		if v then
			local rewardArr = dataHighShop[tonumber(k)].reward
			for k1,v1 in pairs(rewardArr) do
				local t = {v1[1],v1[2],v1[3]}
				self:mergeGetData(t)
			end				
		end				
	end		
	self:refreshScrollView(self._awardGet)
end

function DialogArenaRankAward:mergeGetData(getAward)
	if getAward == nil then return end
	if #self._awardGet == 0 then
		table.insert(self._awardGet, getAward)
	else
		for i,v in ipairs(self._awardGet) do
			if v[1] == getAward[1] and v[2] == getAward[2] then
				v[3] = tonumber(getAward[3])+tonumber(v[3])
				break
			end				
			if i == #self._awardGet then
				table.insert(self._awardGet, getAward)
				break
			end
		end	
	end	
	-- dump(self._awardGet)
end
--累计奖励显示
function DialogArenaRankAward:refreshScrollView(dataTable)
	if not dataTable then return end
	if #dataTable == 0 then
		self._noAward_txt:setVisible(true)
	else
		self._noAward_txt:setVisible(false)
	end
	self._scrollView:removeAllChildren()
	-- 设置scrollView大小
	-- self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width,self._scrollView:getContentSize().height))
	
	for k,v in pairs(dataTable) do
		local itemId 
		if v[1] == "tool" then
			itemId = v[2]
		else
			itemId = IconUtils.iconIdMap[v[1]]
		end
		local toolD = tab:Tool(tonumber(itemId))
		local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
		icon:setScale(0.65)
		icon:setPosition(cc.p((k-1)*68,0))
	    self._scrollView:addChild(icon)
	end
end

return DialogArenaRankAward