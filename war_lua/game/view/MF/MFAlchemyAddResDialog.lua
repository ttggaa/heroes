--[[
    Filename:    MFAlchemyAddResDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2017-05-12 21:40:51
    Description: File description
--]]

local MFAlchemyAddResDialog = class("MFAlchemyAddResDialog",BasePopView)
	
function MFAlchemyAddResDialog:ctor(data)
	MFAlchemyAddResDialog.super.ctor(self)
	self._closeFunc = data.closeCallback
	self._callback = data.addCallback
	self._alchemyModel = self._modelMgr:getModel("AlchemyModel")
	self._formulaId = data.formulaId
end

function MFAlchemyAddResDialog:onInit()
	self._bg = self:getUI("bg")

	self._iconNode = self:getUI("bg.iconNode")
	self._iconNode:setVisible(true)
	
	local title = self:getUI("bg.titleBg.title")
	title:setString("材料添加")
	UIUtils:setTitleFormat(title, 7)
	
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("MF.MFAlchemyAddResDialog")
		end
		if self._closeFunc then
			self._closeFunc()
		end
		self:close()
	end)
	self._needMaterialCount = tab.alchemyPlan[self._formulaId].costRandomMaterial[2]
	self._tableData = self._alchemyModel:getCanUseToolDataByFormulaId(self._formulaId)
	
	self._breakPool = {}
	self:addTableView()
	self:calculateBreaks()
	
	local addBtn = self:getUI("bg.addBtn")
	self:registerClickEvent(addBtn, function()
		self:addMaterial()
	end)
	self:initFireAnim()
end

function MFAlchemyAddResDialog:addMaterial()
	local selectCount = 0
	for i,v in pairs(self._breakPool) do
		selectCount = selectCount + v
	end
	if selectCount<self._needMaterialCount then
		self._viewMgr:showTip("所添加材料不足，请继续添加")
	else
		self:clearCardPool(function()
			if self._callback then
				self._callback(self._breakPool)
			end
			self:close()
		end)
	end
end

function MFAlchemyAddResDialog:addTableView()
	if not self._tableView then
		local tableBg = self:getUI("bg.tableViewBg")
		self._tableView = cc.TableView:create(tableBg:getContentSize())
		self._tableView:setDelegate()
		self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
		self._tableView:registerScriptHandler(function(table) return self:scrollViewDidScroll(table) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
		self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
		self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
		self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
		self._tableView:setBounceable(true)
		self._tableView:reloadData()
		if self._tableView.setDragSlideable ~= nil then 
			self._tableView:setDragSlideable(true)
		end
		tableBg:addChild(self._tableView)
	end
end

function MFAlchemyAddResDialog:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
end

function MFAlchemyAddResDialog:cellSizeForTable(view, idx)
	return 100, 670
end

function MFAlchemyAddResDialog:tableCellAtIndex(view, idx)
	local cell = view:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
	cell:removeAllChildren()
	local row = idx*7
	for i=1,7 do
		local item 
		if i+row<=#self._tableData then
			item = self:createItem(self._tableData[i+row])
			local posX = 2+i*3+(i-1)*item:getContentSize().width
			item:setPosition(cc.p(posX, 0))
			cell:addChild(item)
		end
	end
	return cell
end

function MFAlchemyAddResDialog:numberOfCellsInTableView(view)
	local itemCount = table.nums(self._tableData)
	return math.ceil(itemCount/7)
end

function MFAlchemyAddResDialog:createItem( data )
	local item
	local function itemCallback( )
		if self._resultPanel and self._resultPanel:isVisible() then return end
		if not item or tolua.isnull(item) then return end
		if not self._inScrolling then
			local selectCount = 0
			for i,v in pairs(self._breakPool) do
				selectCount = selectCount + v
			end
			if selectCount<self._needMaterialCount then
				local pos1 = item:getParent():convertToWorldSpace(cc.p(item:getPositionX()+10,item:getPositionY()+10))
				local pos2 = self._bg:convertToNodeSpace(pos1)
				self._flyBeginPos = pos2
				local num = self:addToPool(data.goodsId,1,data.num)
				local numLab = item:getChildByName("iconColor"):getChildByName("numLab")
				local items = {}
				for k,v in pairs(self._breakPool) do
					table.insert(items,{k,v})
				end
				if num <= 0 then 
					item._subBtn:setVisible(false)
					numLab:setString(ItemUtils.formatItemCount(data.num)) 
				else
					item._subBtn:setVisible(true)
					numLab:setString(ItemUtils.formatItemCount(num) .. "/" .. ItemUtils.formatItemCount(data.num)) 
				end
				self:calculateBreaks()
			end
		else
			self._inScrolling = false
		end
	end

	local toolD = tab:Tool(data.goodsId)
	item = IconUtils:createItemIconById({itemId = data.goodsId,num = data.num,itemData = toolD,eventStyle = 0,effect=true})-- self._scrollItem:clone()
	local touchBeginX,touchBeginY
	local touchW = item:getContentSize().width*item:getScale()
	local touchH = item:getContentSize().height*item:getScale()
	local scheduled
	self:registerTouchEvent(item, function( _,x,y )
		touchBeginX,touchBeginY = x,y
	end, function( _,x,y )
		local touchPoint = item:convertToNodeSpace(cc.p(x, y))
		if math.abs(touchBeginX-x)>= touchW*0.2  
			or math.abs(touchBeginY-y)>= touchH*0.2 
			or touchPoint.x < 0 or touchPoint.x > touchW 
			or touchPoint.y < 0 or touchPoint.y > touchH
		then
			if item._clockOn then
				ScheduleMgr:unregSchedule(item._clockOn)
				item._clockOn = nil
			end
		end
	end, function( )
		if item._clockOn then
			ScheduleMgr:unregSchedule(item._clockOn)
			item._clockOn = nil
			scheduled = nil
		elseif not scheduled then
			itemCallback()
		end
	end, function(  )
		if item._clockOn then
			ScheduleMgr:unregSchedule(item._clockOn)
			item._clockOn = nil
			scheduled = nil
		end
	end,function( )
		self._createTime = 1
		itemCallback()
		item._clockOn = ScheduleMgr:regSchedule(100,self,function( )
			self._createTime = self._createTime + 0.1
			itemCallback()
			scheduled = true
			if self._createTime >= 5 and self._createTime < 10 then
				if item._clockOn then
					ScheduleMgr:unregSchedule(item._clockOn)
					item._clockOn = nil
					scheduled = nil
				end
				item._clockOn = ScheduleMgr:regSchedule(20,self,function( )
					self._createTime = self._createTime + 0.02
					itemCallback()
					scheduled = true
					if self._createTime >= 10 then
						if item._clockOn then
							ScheduleMgr:unregSchedule(item._clockOn)
							item._clockOn = nil
							scheduled = nil
						end
						item._clockOn = ScheduleMgr:regSchedule(10,self,function( )
							self._createTime = self._createTime + 0.01
							itemCallback()
							scheduled = true
						end)
					end
				end)
			end
				

		end)
	end)
	item:setVisible(true)
	item:setSwallowTouches(false)
	local numLab = item:getChildByName("iconColor"):getChildByName("numLab")
	numLab:setString(ItemUtils.formatItemCount(data.num))

	item._added = false
	local subBtn = ccui.ImageView:create("globalBtnUI_bigSubBtn_n.png", 1)
	subBtn:setAnchorPoint(cc.p(1,1))
	subBtn:setPosition(cc.p(item:getContentSize().width,item:getContentSize().height))
	subBtn:setVisible(false)
	item._subBtn = subBtn
	item:addChild(subBtn,99)
	local num = self._breakPool[data.goodsId]

	if num and num > 0 then 
		numLab:setString(ItemUtils.formatItemCount(num) .. "/" .. ItemUtils.formatItemCount(data.num)) 
		subBtn:setVisible(true)
	else
		item._subBtn:setVisible(false)
		numLab:setString(ItemUtils.formatItemCount(data.num))
		subBtn:setVisible(false) 
	end

	local btnCallBack = function(  )
		if not tolua.isnull(subBtn) and subBtn:isVisible() then
			if self._resultPanel and self._resultPanel:isVisible() then return end
			local num = self:removeFromPool(data.goodsId)
			local numLab = item:getChildByName("iconColor"):getChildByName("numLab")
			if num <= 0 then 
				item._subBtn:setVisible(false)
				numLab:setString(ItemUtils.formatItemCount(data.num)) 
				if subBtn._clockOn then
					ScheduleMgr:unregSchedule(subBtn._clockOn)
					subBtn._clockOn = nil
				end
			else
				numLab:setString(ItemUtils.formatItemCount(num) .. "/" .. ItemUtils.formatItemCount(data.num)) 
			end
			self:calculateBreaks()
		end
	end
	local touchBeginX1,touchBeginY1
	local touchW1 = subBtn:getContentSize().width*subBtn:getScale()
	local touchH1 = subBtn:getContentSize().height*subBtn:getScale() 
	self:registerTouchEvent(subBtn, function( _,x,y )
		touchBeginX1,touchBeginY1 = x,y
		subBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( )
			subBtn._clockOn = ScheduleMgr:regSchedule(100,self,function( )
				if not tolua.isnull(subBtn) and subBtn:isVisible() then
					btnCallBack()
				elseif subBtn._clockOn then
					ScheduleMgr:unregSchedule(subBtn._clockOn)
					subBtn._clockOn = nil
				end
			end)
		end)))
	end, function( _,x,y )
		local touchPoint = subBtn:convertToNodeSpace(cc.p(x, y))
		if math.abs(touchBeginX1-x)>= touchW1  
			or math.abs(touchBeginY1-y)>= touchH1 
			or touchPoint.x < 0 or touchPoint.x > touchW1 
			or touchPoint.y < 0 or touchPoint.y > touchH1
		then
			subBtn:stopAllActions()
			if subBtn._clockOn then
				ScheduleMgr:unregSchedule(subBtn._clockOn)
				subBtn._clockOn = nil
			end
		end
	end, function( )
		subBtn:stopAllActions()
		if subBtn._clockOn then
			ScheduleMgr:unregSchedule(subBtn._clockOn)
			subBtn._clockOn = nil
		else
			if subBtn and subBtn:isVisible() then
				btnCallBack()
			end
		end
	end, function(  )
		subBtn:stopAllActions()
		if subBtn._clockOn then
			ScheduleMgr:unregSchedule(item._clockOn)
			subBtn._clockOn = nil
		end
	end)
	
	return item
end


function MFAlchemyAddResDialog:addToPool(id, num, max)
	num = num or 1
	if not self._breakPool[id] then
		self._breakPool[id] = 0
	end
	if self._breakPool[id]+num > max then
		return max
	end
	self:addCardToPool(id, num)
	self._breakPool[id] = self._breakPool[id]+num
	return self._breakPool[id]
end


function MFAlchemyAddResDialog:addCardToPool( itemId,num, noAnim, order )
	local itemIcon = self._iconNode:getChildByName("card_" .. itemId)
	if not itemIcon then
		order = order or table.nums(self._breakPool)
		itemIcon = IconUtils:createItemIconById({itemId = itemId,num = num,itemData = tab.tool[itemId],eventStyle = 0,effect=true})
		itemIcon:setName("card_" .. itemId)
		itemIcon._order = order
		self._iconNode:addChild(itemIcon)
		itemIcon:setVisible(false)
	else
		IconUtils:updateItemIconByView(itemIcon,{itemId = itemId,num = num+(self._breakPool[itemId] or 0),itemData = tab.tool[itemId],eventStyle = 0,effect=true})
	end 
	itemIcon:setScale(0.8)
	local children = self._iconNode:getChildren()
	local count = #children
	local posx = self:getCardPosByOrder(count,itemIcon._order)
	itemIcon:setPositionX(posx)
	if noAnim then
		itemIcon:setVisible(true)
		self:sortCards()
		return
	end
	local pos1 = itemIcon:getParent():convertToWorldSpace(cc.p(itemIcon:getPositionX(),itemIcon:getPositionY()))
	local pos2 = self._bg:convertToNodeSpace(pos1)
	self._flyToPos = pos2
	self:showItemFlyAnim(itemId,pos2,function( )
		self:sortCards()
		if not tolua.isnull(itemIcon) then 
			itemIcon:setVisible(true)
			itemIcon:setBrightness(40)
			itemIcon:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.05),
				cc.CallFunc:create(function( )
					itemIcon:setBrightness(0)
				end)
			))
		end
	end)
end

local cardW = 75
local displayCount = 5
local cardsW = cardW*displayCount

function MFAlchemyAddResDialog:getCardPosByOrder( count,order )
	local posx = 0
	local blank = 0
	if count > displayCount then
		blank = cardsW/(count-1)
		posx = (order-1)*blank-cardsW*0.5
	else
		posx = (order-1)*cardW-count*cardW*0.5
	end
	return posx-5
end

-- -- 飞入效果及回调
function MFAlchemyAddResDialog:showItemFlyAnim( itemId,targetPos,callback )
	local flyIcon = IconUtils:createItemIconById({itemId = itemId,itemData = tab.tool[itemId],eventStyle = 0,effect=true})
	self._bg:addChild(flyIcon,99999)
	-- flyIcon:setOpacity(0.8)
	flyIcon:setScale(0.8)
	flyIcon:setPosition(self._flyBeginPos.x,self._flyBeginPos.y)
	self:showFlyAnim(flyIcon,targetPos,callback,true)
end

-- 飞动画 
function MFAlchemyAddResDialog:showFlyAnim( node,targetPos,callback,isRemove )
	node:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,targetPos),cc.CallFunc:create(function()
		if callback then
			callback()
		end
		if isRemove then
			node:removeFromParent()
		end
	end)))
end

function MFAlchemyAddResDialog:calculateBreaks(  )
	local selectNumLab = self:getUI("bg.selectNumLab")
	local needNumLab = self:getUI("bg.needNumLab")
	local selectCount = 0
	for i,v in pairs(self._breakPool) do
		selectCount = selectCount + v
	end
	selectNumLab:setString(selectCount)
	needNumLab:setString(self._needMaterialCount)
	
	local addBtn = self:getUI("bg.addBtn")
	if selectCount>0 then
		addBtn:setSaturation(0)
		addBtn:setTouchEnabled(true)
	else
		addBtn:setSaturation(-100)
		addBtn:setTouchEnabled(false)
	end
	--[[local leftCountLab = self:getUI("bg.des2")
	local selCountLab = self:getUI("bg.selNumLab")
	local rightCountLab = self:getUI("bg.rightDesLab")
	
	local canGetLab = self:getUI("bg.breakDesBg.getCountLab")
	
	local selectCount = 0
	local canGetPoint = 0
	for i,v in pairs(self._breakPool) do
		local tabPointData = tab.toolAlchemyPoint[i]
		selectCount = selectCount + v
		canGetPoint = canGetPoint + tabPointData.alchemypoint*v
	end
	canGetLab:setString("x"..canGetPoint)
	selCountLab:setString(selectCount)
	selCountLab:setPositionX(leftCountLab:getPositionX() + 4 + selCountLab:getContentSize().width/2)
	rightCountLab:setPositionX(selCountLab:getPositionX() + selCountLab:getContentSize().width/2 + 4)
	
	local artificeBtn = self:getUI("bg.artificeBtn")
	if table.nums(self._breakPool)>0 then
		artificeBtn:setSaturation(0)
		artificeBtn:setTouchEnabled(true)
	else
		artificeBtn:setSaturation(-100)
		artificeBtn:setTouchEnabled(false)
	end
	
	return canGetPoint--]]
end


function MFAlchemyAddResDialog:removeFromPool( id,num )
	num = num or 1
	if not self._breakPool[id] or  self._breakPool[id] == 0 then
		return 0
	end
	self._breakPool[id] = self._breakPool[id]-num
	self:removeFromCardPool(id,self._breakPool[id])
	if self._breakPool[id] <= 0 then
		self._breakPool[id] = nil
		return 0
	end
	return self._breakPool[id]
end

function MFAlchemyAddResDialog:removeFromCardPool( itemId,num )
	local itemIcon = self._iconNode:getChildByName("card_" .. itemId)
	if itemIcon then
		if num > 0 then
			IconUtils:updateItemIconByView(itemIcon,{itemId = itemId,num = num,itemData = tab.tool[itemId],eventStyle = 0,effect=true})
		else
			local removedOrder = itemIcon._order
			self:sortCards(removedOrder)
			itemIcon:removeFromParent()
		end
	end
end


function MFAlchemyAddResDialog:sortCards( removeOrder )
	local children = self._iconNode:getChildren()
	local count = #children
	if removeOrder then
		count = count - 1
	end
	for k,icon in pairs(children) do
		local order = icon._order
		if removeOrder and (order > removeOrder) then
			order = order - 1
			icon._order = order 
		end
		local posx = self:getCardPosByOrder(count,order)
		icon:setPositionX(posx)
		icon:setZOrder(count-order+99)
	end
end


function MFAlchemyAddResDialog:clearCardPool( callback )
	if self._breakMc and self._breakMc._turnBreakAnim then
		self._breakMc._turnBreakAnim()
	end
	local targetPos = cc.p(70,-120)
	local children = self._iconNode:getChildren()
	for i,icon in ipairs(children) do
		if i == 1 then
			self:showFlyAnim(icon,targetPos,function( )
				self._iconNode:removeAllChildren()
				local mc = mcMgr:createViewMC("xiaoshitexiao_lianjingongfang", false, false)
				mc:addCallbackAtFrame(14,function( )
					callback()
				end)
				if self._breakClipNode then
					mc:setPosition(115,128)
					self._breakClipNode:addChild(mc,999)
				else
					mc:setPosition(-110,-110)
					self._iconNode:addChild(mc,999)
				end
			end)
		else
			self:showFlyAnim(icon,targetPos)
		end
	end
end

function MFAlchemyAddResDialog:initFireAnim( )
	local breakBg = self:getUI("bg.topImg")

	local clipNode = cc.ClippingNode:create()
	clipNode:setPosition(320,0)
	clipNode:setContentSize(cc.size(0, 0))
	local mask = cc.Sprite:createWithSpriteFrameName("alchemy_bgAppend.png")
	mask:setAnchorPoint(0.5,0)
	-- mask:setScale(0.95)
	clipNode:setStencil(mask)
	clipNode:setAlphaThreshold(0.05)
	-- clipNode:setInverted(true)
	clipNode:setCascadeOpacityEnabled(true)

	local mc = mcMgr:createViewMC("fangzhichangjingtexiao_lianjingongfang", true,false)
	mc:setPosition(21,145)
	clipNode:addChild(mc)
	mc:setCascadeOpacityEnabled(true)
	mc:play()
--	mc:gotoAndStop(5)
	self._breakMc = mc

	-- 绑定方法
	self._breakMc._turnNormalAnim = function( )
		if not self._breakMc then return end
		self._breakMc:gotoAndStop(0)
	end

	self._breakMc._turnBreakAnim = function( )
		if not self._breakMc then return end
		self._breakMc:gotoAndPlay(0)
	end
	-- self._breakMc:setPlaySpeed(0.2)
	self._breakMc:addCallbackAtFrame(30,function( )
		self._breakMc._turnNormalAnim()
	end)

	self._breakClipNode = clipNode

	breakBg:addChild(clipNode,999)
end

return MFAlchemyAddResDialog