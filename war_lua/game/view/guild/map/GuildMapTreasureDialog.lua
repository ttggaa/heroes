
--author lannan

local GuildMapTreasureDialog = class("GuildMapTreasureDialog", BasePopView)

function GuildMapTreasureDialog:ctor()
    GuildMapTreasureDialog.super.ctor(self)
	self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
	self._selectTreasureId = nil
end

function GuildMapTreasureDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("guild.map.GuildMapTreasureDialog")
		end
		self:close()
	end)
	
	local title = self:getUI("bg.titleBg.titleLab")
	UIUtils:setTitleFormat(title, 1)
	local infoBtn = self:getUI("bg.titleBg.infoBtn")
	self:registerClickEvent(infoBtn, function()
		self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = lang("guildMap_leagueTreasure_rules")}, true)
	end)
	
	self._tableData = self._modelMgr:getModel("ItemModel"):getItemsByType(ItemUtils.ITEM_TYPE_GUILD_MAP_TREASURE)
	self:addTreasureBagTable()
	
	self:loadLeftPanel()
	self:loadRightPanel()
end

function GuildMapTreasureDialog:loadLeftPanel()
	local leftPanel = self:getUI("bg.itemInfo.leftBg")
	local title = leftPanel:getChildByFullName("titleLab")
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	
	local iconPanel = leftPanel:getChildByFullName("iconNode")
	local nameLab = leftPanel:getChildByFullName("nameLab")
	local desLab = leftPanel:getChildByFullName("itemDesc")
	local giveupBtn = leftPanel:getChildByFullName("giveupBtn")
	local emptyLab = leftPanel:getChildByFullName("emptyLab")
	local item = iconPanel:getChildByName("treasureIcon")
	local emptyItem = iconPanel:getChildByFullName("emptyItem")
	
	local curMapData = self._guildMapModel:getTreasureData()
	if curMapData and curMapData.useId then
		emptyLab:setVisible(false)
		local toolD = tab:Tool(curMapData.useId)
		if item then
			IconUtils:updateItemIconByView(item, {itemId = curMapData.useId, itemData = toolD})
		else
			item = IconUtils:createItemIconById({itemId = curMapData.useId, itemData = toolD})
			item:setName("treasureIcon")
			item:setPosition(cc.p(2, 4))
			iconPanel:addChild(item)
		end
		item:setVisible(true)
		if emptyItem then
			emptyItem:setVisible(false)
		end
		nameLab:setString(lang(toolD.name))
		desLab:setString(lang(toolD.des))
		giveupBtn:setEnabled(true)
		giveupBtn:setSaturation(0)
		self:registerClickEvent(giveupBtn, function()
			DialogUtils.showShowSelect({desc = lang("guildMap_Tips3"), callback1 = function (  )
				self._serverMgr:sendMsg("GuildMapServer", "quitTMap", {}, true, {}, function(result)
					self:reloadView()
				end)
			end})
		end)
	else
		if item then
			item:setVisible(false)
		end
		if emptyItem then
			emptyItem:setVisible(true)
		else
			local bagGrid = ccui.Widget:create()
		    bagGrid:setContentSize(cc.size(107, 107))
		    bagGrid:setAnchorPoint(cc.p(0, 0))
		    bagGrid:setPosition(2, 4)

		    local bagGridFrame = ccui.ImageView:create()
		    bagGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
		    bagGridFrame:setName("bagGridFrame")
		    bagGridFrame:setContentSize(cc.size(107, 107))
		    bagGridFrame:ignoreContentAdaptWithSize(false)
		    bagGridFrame:setAnchorPoint(cc.p(0, 0))
		    bagGrid:addChild(bagGridFrame, 1)

		    local bagGridBg = ccui.ImageView:create()
		    bagGridBg:loadTexture("globalImageUI4_itemBg3.png", 1)
		    bagGridBg:setName("bagGridBg")
		    bagGridBg:setContentSize(cc.size(107, 107))
		    bagGridBg:ignoreContentAdaptWithSize(false)
		    bagGridBg:setAnchorPoint(cc.p(0.5 ,0.5))
		    bagGridBg:setPosition(cc.p(bagGrid:getContentSize().width / 2, bagGrid:getContentSize().height / 2))
		    bagGrid:addChild(bagGridBg, -1)

		    bagGrid:setScale(0.85)
		    bagGrid:setName("emptyItem")
		    iconPanel:addChild(bagGrid)
		end
		nameLab:setString("")
		desLab:setString("")
		giveupBtn:setEnabled(false)
		giveupBtn:setSaturation(-100)
		emptyLab:setVisible(true)
	end
end

function GuildMapTreasureDialog:addTreasureBagTable()
	if not self._tableView then
		local tableBg = self:getUI("bg.itemInfo.rightBg.tableNode")
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


function GuildMapTreasureDialog:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
end

function GuildMapTreasureDialog:cellSizeForTable(view, idx)
	return 100, 400
end

function GuildMapTreasureDialog:tableCellAtIndex(view, idx)
	local cell = view:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
	cell:removeAllChildren()
	local row = idx*4
	for i=1,4 do
		local item 
		if i+row<=#self._tableData then
			item = self:createItem(self._tableData[i+row])
			local posX = 13+i*3+(i-1)*item:getContentSize().width
			item:setPosition(cc.p(posX, 0))
			item:setName("cellItem"..i)
			cell:addChild(item)
		end
	end
	return cell
end

function GuildMapTreasureDialog:numberOfCellsInTableView(view)
	local itemCount = table.nums(self._tableData)
	return math.ceil(itemCount/4)
end

function GuildMapTreasureDialog:loadRightPanel()
	local rightPanel = self:getUI("bg.itemInfo.rightBg")
	local useBtn = rightPanel:getChildByFullName("useBtn")
	local tipLab = rightPanel:getChildByFullName("tipLab")
	local tableNode = rightPanel:getChildByFullName("tableNode")
	local desBg = rightPanel:getChildByFullName("desBg")
	local noneBg = rightPanel:getChildByFullName("noneDes")
	
	if not self._tableData or table.nums(self._tableData)==0 then--没有藏宝图
		useBtn:setVisible(false)
		tipLab:setVisible(false)
		tableNode:setVisible(false)
		desBg:setVisible(false)
		noneBg:setVisible(true)
		self._selectTreasureId = nil
	else--有藏宝图可以使用
		if self._selectTreasureId == nil then
			local itemData = tab:Tool(self._tableData[1].goodsId)
			local item = self._tableView:cellAtIndex(0):getChildByFullName("cellItem1")
			self:onBagTreasureClick(itemData, item)
		end
		local curMapData = self._guildMapModel:getTreasureData()
		useBtn:setVisible(true)
		UIUtils:setGray(useBtn, (curMapData and curMapData.useId))
		tipLab:setVisible(true)
		tableNode:setVisible(true)
		desBg:setVisible(true)
		noneBg:setVisible(false)
		self:registerClickEvent(useBtn, function()
			local curMapData = self._guildMapModel:getTreasureData()
			if curMapData and curMapData.useId then
				self._viewMgr:showTip(lang("guildMap_Tips2"))
				return
			end
			self._serverMgr:sendMsg("GuildMapServer", "useTMap", {itemId = self._selectTreasureId}, true, {}, function(result)
				self._viewMgr:showTip(lang("guildMap_Tips1"))
				self:reloadView()
			end)
		end)
	end
end

function GuildMapTreasureDialog:createItem(data)
	local item
	local toolD = tab:Tool(data.goodsId)
	local function itemCallback( )
		if not item or tolua.isnull(item) then return end
		if not self._inScrolling then
			--点击回调
			self:onBagTreasureClick(toolD, item)
		else
			self._inScrolling = false
		end
	end
	item = IconUtils:createItemIconById({itemId = data.goodsId,num = data.num,itemData = toolD,eventStyle = 0})
	item:setScale(0.9)
	self:registerClickEvent(item, function()
		itemCallback()
	end)
	item:setSwallowTouches(false)
	return item
end

function GuildMapTreasureDialog:onBagTreasureClick(itemData, inView)
	local rightPanel = self:getUI("bg.itemInfo.rightBg")
	local iconPanel = rightPanel:getChildByFullName("desBg.iconPanel")
	local nameLab = rightPanel:getChildByFullName("desBg.nameLab")
	local desLab = rightPanel:getChildByFullName("desBg.desLab")
	nameLab:setString(lang(itemData.name))
	desLab:setString(lang(itemData.des))
	local item = iconPanel:getChildByName("bagTreasureIcon")
	if item then
		IconUtils:updateItemIconByView(item, {itemId = itemData.id, itemData = toolD})
	else
		item = IconUtils:createItemIconById({itemId = itemData.id, itemData = toolD})
		item:setPosition(cc.p(4, 4))
		item:setName("bagTreasureIcon")
		iconPanel:addChild(item)
	end
	if not tolua.isnull(self._curSelectItem) then
		local oldMc = self._curSelectItem:getChildByFullName("selectMC")
		if oldMc then
			oldMc:setVisible(false)
		end
	end
	local mc = inView:getChildByFullName("selectMC")
	if mc then
		mc:setVisible(true)
	else
		mc = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
		mc:setName("selectMC")
		mc:setPosition(inView:getContentSize().width/2, inView:getContentSize().height/2)
		inView:addChild(mc, 1)
	end
	self._curSelectItem = inView
	self._selectTreasureId = itemData.id
end

function GuildMapTreasureDialog:reloadView()
	local oldDataNum = #self._tableData
	self._tableData = self._modelMgr:getModel("ItemModel"):getItemsByType(ItemUtils.ITEM_TYPE_GUILD_MAP_TREASURE)
	self:loadLeftPanel()
	
	if oldDataNum ~= #self._tableData then
		self._tableView:reloadData()
		self._selectTreasureId = nil
		self:loadRightPanel()
		return
	end
	self:loadRightPanel()
	if self._curSelectItem then
		local goodData = nil
		for k, v in pairs(self._tableData) do
			if v.goodsId == self._selectTreasureId then
				goodData = v
				break
			end
		end
		if goodData then
			local toolD = tab:Tool(goodData.goodsId)
			IconUtils:updateItemIconByView(self._curSelectItem, {itemId = goodData.goodsId, num = goodData.num, itemData = toolD,eventStyle = 0})
		end
	end
end

return GuildMapTreasureDialog