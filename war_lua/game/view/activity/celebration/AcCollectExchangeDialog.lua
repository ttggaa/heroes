--
-- Author: huangguofang
-- Date: 2017-07-04 17:01:47
--
local AcCollectExchangeDialog = class("AcCollectExchangeDialog",BasePopView)

function AcCollectExchangeDialog:ctor(param)
    AcCollectExchangeDialog.super.ctor(self)
  	self._exchangeInfo = param.exchangeInfo or {}
	self._textArr = param.textArr or {}

	self._celebrationModel = self._modelMgr:getModel("CelebrationModel")
	-- dump(self._exchangeInfo,"123",5)
	-- dump(self._textArr,"123",5)
end

-- 第一次被加到父节点时候调用
function AcCollectExchangeDialog:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function AcCollectExchangeDialog:onInit()
	local title = self:getUI("bg.bgImg.titleBg.titleLab")
	UIUtils:setTitleFormat(title, 1)

	-- 注册关闭按钮
	self:registerClickEventByName("bg.closeBtn", function()
		if self._callback then
			self._callback()
		end
		self:close()
		UIUtils:reloadLuaFile("activity.celebration.AcCollectExchangeDialog")
	end)
	self._cellW = 644		
	self._cellH = 120
	self._exchangeData = clone(tab.celebrationExchange)
	-- dump(self._exchangeData,"exchange",5)
	self:initData()

	self:addExchangeList()
	
end

function AcCollectExchangeDialog:addExchangeList()
	if not self._exchangeData then return end
	local exchangeBg = self:getUI("bg.exchangeBg")
	if self._exchangeList ~= nil then 
        self._exchangeList:removeFromParent()
        self._exchangeList = nil
    end
    self._exchangeList = cc.TableView:create(cc.size(exchangeBg:getContentSize().width, exchangeBg:getContentSize().height - 16))
    self._exchangeList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._exchangeList:setPosition(cc.p(9, 10))
    self._exchangeList:setDelegate()
    self._exchangeList:setBounceable(true)
    self._exchangeList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._exchangeList:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._exchangeList:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._exchangeList:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    self._exchangeList:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._exchangeList:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    self._exchangeList:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._exchangeList:reloadData()
    exchangeBg:addChild(self._exchangeList)
end

function AcCollectExchangeDialog:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()	
end

function AcCollectExchangeDialog:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AcCollectExchangeDialog:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function AcCollectExchangeDialog:cellSizeForTable(table,idx) 
    return self._cellH + 3,self._cellW
end

function AcCollectExchangeDialog:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
	local cellData = self._exchangeData[idx+1]

    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local item = self:createExchangeCell(cellData,idx+1)
    item:setPosition(0,0)
    item:setName("cellItem")
    item:setAnchorPoint(0,0)
    cell:addChild(item)

    return cell
end
function AcCollectExchangeDialog:numberOfCellsInTableView(table)
	return #self._exchangeData
end

function AcCollectExchangeDialog:createExchangeCell(cellData,idx)
	--名片区域
	local layout = ccui.Widget:create()  
	layout = ccui.Widget:create()  
	layout:setContentSize(cc.size(self._cellW, self._cellH)) --233/98
	layout:setAnchorPoint(cc.p(0.5, 0.5))

	--名片背景
	local bgImg = ccui.ImageView:create()
	bgImg:loadTexture("globalPanelUI7_cellBg21.png", 1)
	bgImg:setScale9Enabled(true)
	bgImg:setCapInsets(cc.rect(25, 25, 1, 1))
	bgImg:setContentSize(cc.size(self._cellW, self._cellH))
	bgImg:ignoreContentAdaptWithSize(false)
	bgImg:setPosition(cc.p(self._cellW*0.5, self._cellH*0.5))
	layout:addChild(bgImg)
	bgImg:loadTexture(cellData.state and "globalPanelUI7_cellBg20.png" or "globalPanelUI7_cellBg21.png",1)
	
	local toolData = cellData.tool or {}
	local itemId = toolData[2]
	if itemId then
		if toolData[1] ~= "tool" then
			itemId = IconUtils.iconIdMap[rewardData[1]]
		end
		local toolD = tab:Tool(tonumber(itemId))
		icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = toolData[3]})
		icon:setScale(0.75)
		icon:setPosition(20,12)
		layout:addChild(icon,1)

		-- 名字
		local nameLab = ccui.Text:create() 
		nameLab:setString(lang(toolD.name) .. "*" .. toolData[3]) --
		nameLab:setFontName(UIUtils.ttfName)
		nameLab:setColor(UIUtils.colorTable.ccUIBaseColor5)
		nameLab:setFontSize(20)
		nameLab:setAnchorPoint(cc.p(0,0.5))
		nameLab:setPosition(20, 95)
		layout:addChild(nameLab, 1)
	end

	-- 名字
	local exchangeLab = ccui.Text:create()
	exchangeLab:setString("兑换")
	exchangeLab:setFontName(UIUtils.ttfName)
	exchangeLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	exchangeLab:setFontSize(20)
	exchangeLab:setAnchorPoint(cc.p(0.5,0.5))
	exchangeLab:setPosition(220, 92)
	layout:addChild(exchangeLab, 1)

	local arrow = ccui.ImageView:create()
	arrow:loadTexture("celebration_collext_exchange.png", 1)
	arrow:setPosition(cc.p(220, 50))
	layout:addChild(arrow,1)

	local rewardData = cellData.reward or {}
	local rewardId = rewardData[2]
	if rewardId then
		if rewardData[1] ~= "tool" then
			rewardId = IconUtils.iconIdMap[rewardData[1]]
		end
		local toolD = tab:Tool(tonumber(rewardId))
		icon = IconUtils:createItemIconById({itemId = rewardId,itemData = toolD,num = rewardData[3]})
		icon:setScale(0.75)
		icon:setPosition(300,10)
		layout:addChild(icon,1)

		-- 名字
		local nameLab = ccui.Text:create()
		nameLab:setString(lang(toolD.name) .. "*" .. rewardData[3])
		nameLab:setFontName(UIUtils.ttfName)
		nameLab:setColor(UIUtils.colorTable.ccUIBaseColor5)
		nameLab:setFontSize(20)
		nameLab:setAnchorPoint(cc.p(0,0.5))
		nameLab:setPosition(300, 95)
		layout:addChild(nameLab, 1)
	end

	-- 条件bg
	local btnTitleBg = ccui.ImageView:create()
	btnTitleBg:loadTexture("globalPanelUI12_btnTitleBg.png", 1)
	-- btnTitleBg:setAnchorPoint(cc.p(0.5,0.5))
	btnTitleBg:setPosition(cc.p(560, 75))
	layout:addChild(btnTitleBg,1)
	btnTitleBg:setVisible(cellData.isHaveTimes)

	-- 条件
	local conditionTxt = ccui.Text:create()
	conditionTxt:setString((cellData.exchangeTimes or 0) .. "/" .. (cellData.limit or 0))
	conditionTxt:setFontName(UIUtils.ttfName)
	conditionTxt:setColor(cellData.state and UIUtils.colorTable.ccUIBaseColor9 or UIUtils.colorTable.ccUITabColor1)
	conditionTxt:setFontSize(20)
	conditionTxt:setAnchorPoint(cc.p(0.5,0))
	conditionTxt:setPosition(560, 70)
	layout:addChild(conditionTxt, 2)
	conditionTxt:setVisible(cellData.isHaveTimes)

	-- 兑换按钮
	local btn = ccui.Button:create("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", 1)
    btn:setTitleFontName(UIUtils.ttfName)
    btn:setTitleText("兑换")
    btn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    btn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2,1)
    btn:setTitleFontSize(22) 
    btn:setScale(0.9)
    btn:setPosition(560, 45)
    layout:addChild(btn,2)
    btn:setSaturation(cellData.state and 0 or -100)
    btn._exchangeData = cellData
    btn:setVisible(cellData.isHaveTimes)

    local soldOut = ccui.ImageView:create()
	soldOut:loadTexture("globalImageUI_SellOut.png", 1)
	soldOut:setPosition(560, self._cellH*0.5)
	layout:addChild(soldOut,1)
	soldOut:setVisible(not cellData.isHaveTimes)

	registerClickEvent(btn, function(sender)
       self:exchangeBtnClicked(sender._exchangeData)
    end)
	return layout
	
end

function AcCollectExchangeDialog:exchangeBtnClicked(data)
	local isOpen = self._celebrationModel:isCelebrationEnd()
	if not isOpen then
		self._viewMgr:showTip("活动已结束")
		return 
	end
	
	if data then
    	if data.isHaveTimes and data.isCanChange then
        	self._serverMgr:sendMsg("ActivityServer", "exchangeItem", {id=data.id,num=1}, true, {}, function(result,succ)
			    if result["reward"] then
		        	DialogUtils.showGiftGet({gifts = result["reward"]})
		        end
		        self:updateData()
		    end)
        elseif not data.isHaveTimes then
        	self._viewMgr:showTip("兑换次数已达上限")
        elseif not data.isCanChange then
        	self._viewMgr:showTip("道具数量不足")
        end
   	end
end

function AcCollectExchangeDialog:reflashUI()
	-- body
end

-- 初始化数据
function AcCollectExchangeDialog:initData()
	if not self._exchangeData then
		self._exchangeData = {}
	end

	for k,v in pairs(self._exchangeData) do
		if self._exchangeInfo[tostring(v.id)] then
			-- 已兑换次数
			self._exchangeData[tonumber(k)].exchangeTimes = self._exchangeInfo[tostring(v.id)]
		end
		v.isCanChange = false 	 --false 道具不足     true 道具充足
		local toolData = v.tool
		if toolData and toolData[2] and toolData[3] then
			local haveNums = self._textArr[tostring(toolData[2])] or 0
			if tonumber(haveNums) >= tonumber(toolData[3]) then
				v.isCanChange = true
			end
		end
		v.isHaveTimes = false 	--false 次数不足     true 有次数
		local times = v.exchangeTimes or 0
		if v.limit and tonumber(v.limit) > times then
			v.isHaveTimes = true
		end
		v.state = v.isCanChange and v.isHaveTimes
	end

	table.sort(self._exchangeData, function(a,b)
		if a.state == b.state then
			if a.isHaveTimes == b.isHaveTimes then
				return a.id < b.id
			else
				return a.isHaveTimes
			end
		else
			return a.state
		end
	end)

end

-- 更新数据
function AcCollectExchangeDialog:updateData()
	local collectData = self._celebrationModel:getCollectionCeleData()
	dump(collectData,"collectData==",6)
	self._textArr = {}
	if collectData.text then
		self._textArr = json.decode(collectData.text)
	end
	self._exchangeInfo = {}
	if collectData.exchangeInfo and collectData.exchangeInfo ~= "" then
		self._exchangeInfo = json.decode(collectData.exchangeInfo)
	end
	self:initData()

	if self._exchangeList and self._exchangeData then
		self._exchangeList:reloadData()
	end
end

return AcCollectExchangeDialog