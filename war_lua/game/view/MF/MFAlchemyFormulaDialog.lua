
--author lannan

local MFAlchemyFormulaDialog = class("MFAlchemyFormulaDialog",BasePopView)
	
function MFAlchemyFormulaDialog:ctor(data)
	MFAlchemyFormulaDialog.super.ctor(self)
	self._formulaType = nil
	self._alchemyModel = self._modelMgr:getModel("AlchemyModel")
end

local l_formulaType = {
	[1] = "全部",
	[2] = "兵团",
	[3] = "英雄",
	[4] = "材料",
	[5] = "消耗",
	[6] = "宝物",
	[7] = "活动",
}

function MFAlchemyFormulaDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
	end)
	
	local title = self:getUI("bg.bgImg.titleBg.title")
	title:setString("炼金配方库")
	UIUtils:setTitleFormat(title, 7)
	
	local screenBtn = self:getUI("bg.rightBg.screenBtn")
	screenBtn:setScaleAnim(false)
	local screenTitle = screenBtn:getChildByName("btnTitle")
	screenTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	screenTitle:setString(l_formulaType[1])
	local tabLayer = self:getUI("bg.rightBg.tabLayer")
	self:registerClickEvent(tabLayer, function()
		tabLayer:setVisible(false)
	end)
	tabLayer:setSwallowTouches(false)--全屏取消筛选窗口
	tabLayer:setVisible(false)
	self:registerClickEvent(screenBtn, function()
		tabLayer:setVisible(not tabLayer:isVisible())
	end)
	
	for i=1, 7 do
		local btn = self:getUI("bg.rightBg.tabLayer.typeBtn"..i)
		local title = btn:getChildByName("btnTitle")
		title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		self:registerClickEvent(btn, function()
			local isSameType = false
			if i==1 and not self._formulaType then
				isSameType = true
			elseif i>1 and self._formulaType==i-1 then
				isSameType = true
			end
			if not isSameType then
				local tempType
				if i==1 then
					tempType = nil
				else
					tempType = i-1
				end
				local tempData = self._alchemyModel:getFormulaLibraryData(tempType)
				if tempData and table.nums(tempData)>0 then
					self._formulaType = tempType
					self._tableData = tempData
					screenTitle:setString(l_formulaType[i])
					self._tableView:reloadData()
					local item = self._tableView:cellAtIndex(0):getChildByName("cellNode1")
					self:touchItem(self._tableData[1], item)
				else
					self._viewMgr:showTip("该分类下暂无配方")
				end
			end
			tabLayer:setVisible(false)
		end)
	end
	self._titlePanel = self:getUI("titlePanel")
	self._infoPanel = self:getUI("infoPanel")
	self._tableData = self._alchemyModel:getFormulaLibraryData(self._formulaType)
	self:addTableView()
end

function MFAlchemyFormulaDialog:addTableView()
	local tableViewBg = self:getUI("bg.rightBg.tableBg")
	tableViewBg:removeAllChildren()
	self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
	self._tableView:setDelegate()
	self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self._tableView:setPosition(0, 0)
	self._tableView:registerScriptHandler(function(table) return self:scrollViewDidScroll(table) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
	self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
	self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
	self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._tableView:setBounceable(true)
	self._tableView:reloadData()
	if self._tableView.setDragSlideable ~= nil then 
		self._tableView:setDragSlideable(true)
	end
	tableViewBg:addChild(self._tableView)
	local item = self._tableView:cellAtIndex(0):getChildByName("cellNode1")
	self:touchItem(self._tableData[1], item)
end

function MFAlchemyFormulaDialog:scrollViewDidScroll(inView)
    self._inScrolling = inView:isDragging()
end

function MFAlchemyFormulaDialog:cellSizeForTable(inView, idx)
	if idx==0 or idx==math.ceil(table.nums(self._tableData)/5) then
		return 80, 392
	else
		return 74, 392
	end
end

function MFAlchemyFormulaDialog:tableCellAtIndex(inView, idx)
	local cell = inView:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
--	cell:removeAllChildren()
	for i=1, 5 do
		local data = self._tableData[idx*5+i]
		local node = cell:getChildByName("cellNode"..i)
		if data then
			if not node then
				node = IconUtils:createAlchemyIcon(data)
				local posX = 2+i*8+(i*2-1)/2*node:getContentSize().width
				local posY = 37
				if idx==math.ceil(table.nums(self._tableData)/5) then
					posY = 40
				end
				node:setPosition(cc.p(posX, 37))
				node:setName("cellNode"..i)
				cell:addChild(node)
			else
				IconUtils:updateAlchemyIcon(node, data)
			end
			node:setVisible(true)
			local mc = node:getChildByName("anim")
			if not mc then
				mc = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
				mc:setName("anim")
				mc:setVisible(false)
				mc:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
				mc:setScale(0.7)
				node:addChild(mc, 10)
			end
			if self._selectData then
				if data.id==self._selectData.id then
					mc:setVisible(true)
					self._selectMc = mc
				else
					mc:setVisible(false)
				end
			end
		else
			if node then node:setVisible(false) end
		end
		if node then
			self:registerClickEvent(node, function()
				if not self._inScrolling then
					self:touchItem(data, node)
				else
					self._inScrolling = false
				end
			end)
			node:setSwallowTouches(false)
		end
	end
	return cell
end

function MFAlchemyFormulaDialog:touchItem(data, item)
	if not data or not item or tolua.isnull(item) then
		return
	end
	if self._selectMc then
		self._selectMc:setVisible(false)
	end
	self._selectMc = item:getChildByName("anim")
	self._selectMc:setVisible(true)
	
	self._selectData = data
	
	self:loadFormulaInfo(data)
end

function MFAlchemyFormulaDialog:loadFormulaInfo(formulaData)
	local nameLab = self:getUI("bg.leftBg.formulaNameLab")
	local nameStr = lang(formulaData.planName)
	if OS_IS_WINDOWS then
		nameStr = nameStr.."["..formulaData.id.."]"
	end
	nameLab:setString(nameStr)
	local scroll = self:getUI("bg.leftBg.scroll")
	scroll:removeAllChildren()
	
	local tbNode = {}
	local totalHeight = 0
	
	local timeTitlePanel = self._titlePanel:clone()
	timeTitlePanel:getChildByName("titleLab"):setString("耗时")
	scroll:addChild(timeTitlePanel)
	totalHeight = totalHeight + timeTitlePanel:getContentSize().height
	table.insert(tbNode, timeTitlePanel)
	local timeInfoPanel = self._infoPanel:clone()
	timeInfoPanel:getChildByName("infoLab"):setString(TimeUtils:getTimeDisByFormat(formulaData.costTime))
	scroll:addChild(timeInfoPanel)
	totalHeight = totalHeight + timeInfoPanel:getContentSize().height
	table.insert(tbNode, timeInfoPanel)
	
	local proTitlePanel = self._titlePanel:clone()
	proTitlePanel:getChildByName("titleLab"):setString("产出")
	scroll:addChild(proTitlePanel)
	totalHeight = totalHeight + proTitlePanel:getContentSize().height
	table.insert(tbNode, proTitlePanel)
	local proInfoPanel = self._infoPanel:clone()
	proInfoPanel:getChildByName("infoLab"):setString(lang(formulaData.getMaterialDes))
	scroll:addChild(proInfoPanel)
	totalHeight = totalHeight + proInfoPanel:getContentSize().height
	table.insert(tbNode, proInfoPanel)
	
	local needTitlePanel = self._titlePanel:clone()
	needTitlePanel:getChildByName("titleLab"):setString("需要材料")
	scroll:addChild(needTitlePanel)
	totalHeight = totalHeight + needTitlePanel:getContentSize().height
	table.insert(tbNode, needTitlePanel)
	for i,v in ipairs(formulaData.costMaterial) do
		local needFixedInfoPanel = self._infoPanel:clone()
		local itemData
		local haveCount
		if v[1]=="tool" then
			itemData = tab.tool[v[2]]
			local _, count = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
			haveCount = count
		else
			itemData = tab.tool[IconUtils.iconIdMap[v[1]]]
			haveCount = self._modelMgr:getModel("UserModel"):getResNumByType(v[1])
		end
		local needStr = lang(itemData.name).." "..ItemUtils.formatItemCount(haveCount).."/"..v[3]
		local lab = needFixedInfoPanel:getChildByName("infoLab")
		lab:setString(needStr)
		if haveCount>=v[3] then
			lab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
		else
			lab:setColor(UIUtils.colorTable.ccColorQuality6)
		end
		scroll:addChild(needFixedInfoPanel)
		totalHeight = totalHeight + needFixedInfoPanel:getContentSize().height
		table.insert(tbNode, needFixedInfoPanel)
	end
	if table.nums(formulaData.costRandomMaterial)~=0 then
		local haveCount = 0
		for i,v in ipairs(formulaData.costRandomMaterial[1]) do
			if v[1]~="tool" then
				haveCount = haveCount + self._modelMgr:getModel("UserModel"):getResNumByType( v[1] )
			else
				local _, toolCount = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
				haveCount = haveCount + toolCount
			end
		end
		
		local needInfoPanel = self._infoPanel:clone()
		local needCount = formulaData.costRandomMaterial[2]
		local str = lang(formulaData.costRandomMaterialDes).." "..haveCount.."/"..needCount
		local lab = needInfoPanel:getChildByName("infoLab")
		lab:setString(str)
		scroll:addChild(needInfoPanel)
		totalHeight = totalHeight + needInfoPanel:getContentSize().height
		table.insert(tbNode, needInfoPanel)
		if haveCount>=needCount then
			lab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
		else
			lab:setColor(UIUtils.colorTable.ccColorQuality6)
		end
	end
	if totalHeight>scroll:getInnerContainerSize().height then
		scroll:setInnerContainerSize(cc.size(scroll:getContentSize().width, totalHeight))
	end
	local posX = 0
	local posY = scroll:getInnerContainerSize().height
	for i,v in ipairs(tbNode) do
		local sizeH = v:getContentSize().height
		v:setPosition(cc.p(posX, posY-sizeH))
		posY = posY-sizeH
		v:setVisible(true)
	end
	scroll:jumpToPercentVertical(0)
end

function MFAlchemyFormulaDialog:numberOfCellsInTableView(inView)
	return math.ceil(table.nums(self._tableData)/5)
end

return MFAlchemyFormulaDialog