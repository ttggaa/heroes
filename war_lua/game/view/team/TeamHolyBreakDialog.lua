--[[
    Filename:    TeamHolyBreakDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-02 15:29:48
    Description: File description
--]]

-- 分解
local TeamHolyBreakDialog = class("TeamHolyBreakDialog", BasePopView)
local classType = {
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 4,
    [6] = 5,
}


local sortFunc = function(a, b)
	if a.lv < b.lv then
		return true
	elseif a.lv == b.lv then
		if a.quality < b.quality then
			return true
		elseif a.quality == b.quality then
			if a.make<b.make then
				return true
			elseif a.make==b.make then
				return a.id>b.id
			end
		end
	end
end

function TeamHolyBreakDialog:ctor()
    TeamHolyBreakDialog.super.ctor(self)
    self._breakData = {}
	self._selectBreakData = {}
    self._selectQuality = {}
end

function TeamHolyBreakDialog:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")

    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamHolyBreakDialog")
        end
        self:close()
    end)

    local breakBtn = self:getUI("bg.breakBtn")
    self:registerClickEvent(breakBtn, function()
        self:resolveRunes()
    end)
	
	local tipLab = self:getUI("bg.rightBg.tipLab")
	tipLab:setString(lang("RUNE_10004"))

    local autoSelect = self:getUI("bg.autoSelect")
    self:registerClickEvent(autoSelect, function()
        local callback = function(selectQuality)
            self._selectQuality = selectQuality
            self:autoSelect()
            self:calculationAward()
			self:updateBreakBtnState()
        end
        local param = {callback = callback}
        UIUtils:reloadLuaFile("team.TeamHolyAutoSelectDialog")
        self._viewMgr:showDialog("team.TeamHolyAutoSelectDialog", param)
    end)

    local lab1 = self:getUI("bg.awardBg.lab1")
    lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local breakNum = self:getUI("bg.awardBg.breakNum")
    breakNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._breakNum = breakNum
    self._breakLab = self:getUI("bg.rightBg.breakLab")
    self._awardBg = self:getUI("bg.awardBg")
    self._nothing = self:getUI("bg.nothing")
    self._nothing:setVisible(false)

    self._tabEventTarget = {}
    for i=1,6 do
        local tab = self:getUI("bg.tab" .. i)
        table.insert(self._tabEventTarget, tab)
        self:registerClickEvent(tab, function(sender)self:tabButtonClick(sender, 1) end)
    end

    self._itemCell = self:getUI("itemCell")
    self._itemCell:setVisible(false)
    self:addTableView()

    local tab1 = self:getUI("bg.tab1")
    self:tabButtonClick(tab1, 1)

    self:calculationAward()
	
	self:updateBreakBtnState()

    -- self._tableData = self._teamModel:getHolyBreakData()
    -- self._holyId = self._tableData[1]
end

function TeamHolyBreakDialog:reflashUI(data)
    self._tableView:reloadData()
end

function TeamHolyBreakDialog:updateBreakBtnState()
    local breakBtn = self:getUI("bg.breakBtn")
	if table.nums(self._breakData)>0 then
		breakBtn:setSaturation(0)
		breakBtn:setEnabled(true)
	else
		breakBtn:setSaturation(-100)
		breakBtn:setEnabled(false)
	end
end


function TeamHolyBreakDialog:autoSelect()
    local selectQuality = self._selectQuality
	self._selectBreakData = {}
    for k,v in pairs(self._tableData) do
        local propsKey = v.key
        if selectQuality[v.quality] then
            self._breakData[propsKey] = propsKey
			if self._selectBreakData[v.id] then
				if self._selectBreakData[v.id][v.lv] then
					table.insert(self._selectBreakData[v.id][v.lv], v)
				else
					self._selectBreakData[v.id][v.lv] = {v}
				end
			else
				self._selectBreakData[v.id] = {[v.lv] = {v}}
			end
        else
            self._breakData[propsKey] = nil
			
			--[[local index
			for i,v in ipairs(self._selectBreakData[v.id][v.lv]) do
				if v.key == key then
					index = i
					break
				end
			end
			table.remove(self._selectBreakData[v.id][v.lv], index)--]]
        end
		
    end
	local breakData = clone(self._selectBreakData)
	self:updateBreakRightData(breakData)
    self._tableView:reloadData()
end

function TeamHolyBreakDialog:calculationAward()
	local toolAllNum = 0
	for k,v in pairs(self._breakData) do
		local stoneData = self._teamModel:getHolyDataByKey(k)
		local toolValue = self:getHolyUpgradeCost(stoneData) or 0
		toolAllNum = toolAllNum + toolValue
	end
	self._breakNum:setString("x" .. toolAllNum)
	self._breakLab:setString("已选择：" .. table.nums(self._breakData))
end

function TeamHolyBreakDialog:getHolyUpgradeCost(stoneData)
    local toolNum = 0
    local quality = stoneData.quality
    local lv = stoneData.lv-1


    local runeDisint = tab:RuneDisintegration(quality)
	
	local castExp = tab.rune[stoneData.id].castExp
	
	local levelExp = 0
	if lv~=0 then
		for i, v in ipairs(runeDisint.castingExp) do
			if i<=lv then
				levelExp = levelExp + v
			else
				break
			end
		end
	end
	local stoneExp = stoneData.e + levelExp
	
	local breakNum = (stoneExp+castExp)/castExp*runeDisint.disintegration
	
    toolNum = toolNum + breakNum
    return toolNum or 0
end


-- 分解配件
function TeamHolyBreakDialog:resolveRunes()
    local proidTab = {}
	local isHaveOrange = false
    for k,v in pairs(self._breakData) do
		local stoneData = self._teamModel:getHolyDataByKey(k)
		if stoneData.quality==5 then
			isHaveOrange = true
		end
        table.insert(proidTab, k)
    end
	local function breakStone()
		local param = {ids = proidTab}
		local num = self:calculationAward()
		self._serverMgr:sendMsg("RunesServer", "resolveRunes", param, true, {}, function (result)
			local breakScroll = self:getUI("bg.rightBg.breakScroll")
			local mc = mcMgr:createViewMC("baowufenjie_treasureui", false, true)
			mc:addCallbackAtFrame(14,function( )
				self._breakData = {}
				self._selectBreakData = {}
				self:reloadData()
				self:updateBreakBtnState()
				self:updateBreakRightData()
				DialogUtils.showGiftGet({gifts = result.reward})
			end)
			local posY = self._breakLab:getPositionY()+self._breakLab:getContentSize().height/2 + breakScroll:getContentSize().height/2+5
			mc:setPosition(cc.p(self._breakLab:getPositionX(), posY))
			breakScroll:getParent():addChild(mc, 10)
		end)
	end
	if isHaveOrange then
		self._viewMgr:showSelectDialog( lang("RUNE_TIPS_1"), "", function( )
				breakStone()
			end,
		"")
	else
		breakStone()
	end
end

function TeamHolyBreakDialog:reloadData()
    local _type = classType[self._tabSelect]
    self._tableData = self._teamModel:getHolyBreakData(_type)
	table.sort(self._tableData, sortFunc)
    self._tableView:reloadData()
    if table.nums(self._tableData) == 0 then
        self._nothing:setVisible(true)
    else
        self._nothing:setVisible(false)
    end
	self:calculationAward()
end


-- function TeamHolyBreakDialog:updateRightPanel()
--     local holyId = self._holyId or 101
--     local suitTab = tab.runeClient[holyId]
--     local suitLab = self:getUI("bg.leftPanel.suitLab")
--     local suitIcon = self:getUI("bg.leftPanel.suitIcon")
--     local str = lang(suitTab.name)
--     suitLab:setString(str)

--     local failName = suitTab.icon .. ".png"
--     suitIcon:loadTexture(failName, 1)
-- end

function TeamHolyBreakDialog:refreshTabData(sender, key)
    if sender:getName() == "tab1" then
        self._tabSelect = 1
        print("sender")
        
    elseif sender:getName() == "tab2" then 
        self._tabSelect = 2

    elseif sender:getName() == "tab3" then 
        self._tabSelect = 3

    elseif sender:getName() == "tab4" then 
        self._tabSelect = 4

    elseif sender:getName() == "tab5" then 
        self._tabSelect = 5

    elseif sender:getName() == "tab6" then 
        self._tabSelect = 6
    end
    self:reloadData()
end

function TeamHolyBreakDialog:updateCell(inView, indexLine)    
    for i=1,2 do
        local listCell = inView["listCell" .. i]
        if listCell then
            local indexId = (indexLine-1)*2+i
            local holyId = self._tableData[indexId]
            if holyId then
                listCell:setVisible(true)
                self:updateStoneCell(listCell, indexId, i)
            else
                listCell:setVisible(false)
            end
        end
    end
end

function TeamHolyBreakDialog:updateStoneCell(inView, indexId, verticalId)
    local stoneData = self._tableData[indexId]
    local stoneId = stoneData.id
    local key = stoneData.key

    local suitIcon = inView["suitIcon"]
    local stoneTab = tab.rune[stoneId]
	
	local function clickCallback(isNotClick)
		if not self._inScrolling then
			if isNotClick then
				self._inScrolling = false
			else
				if not self._breakData[key] then
					self._breakData[key] = 1
					if self._selectBreakData[stoneId] then
						if self._selectBreakData[stoneId][stoneData.lv] then
							table.insert(self._selectBreakData[stoneId][stoneData.lv], stoneData)
						else
							self._selectBreakData[stoneId][stoneData.lv] = {stoneData}
						end
					else
						self._selectBreakData[stoneId] = {[stoneData.lv] = {stoneData}}
					end
					self:updateStoneCell(inView, indexId, verticalId)                    
				else
					self._breakData[key] = nil
					local index
					for i,v in ipairs(self._selectBreakData[stoneId][stoneData.lv]) do
						if v.key == key then
							index = i
							break
						end
					end
					table.remove(self._selectBreakData[stoneId][stoneData.lv], index)
					self:updateStoneCell(inView, indexId, verticalId)
				end
				local breakData = clone(self._selectBreakData)
				self:calculationAward()
				self:updateBreakRightData(breakData)
				self:updateBreakBtnState()
			end
		else
			self._viewMgr:closeHintView()
			self._inScrolling = false
		end
	end
	
    local param = {suitData = stoneTab, stoneData = stoneData, notAnim = true}--, clickCallback = clickCallback }
    if not suitIcon then
        suitIcon = IconUtils:createHolyIconById(param)
        suitIcon:setScale(0.6)
        suitIcon:setPosition(3, 3)
        inView:addChild(suitIcon, 20)
        inView["suitIcon"] = suitIcon
    else
        IconUtils:updateHolyIcon(suitIcon, param)
    end

    local sName = inView:getChildByName("sName")
    if sName then
        local str = lang(stoneTab.name)
        sName:setString(str)
    end

    local cellBg = inView:getChildByName("cellBg")
    local selBtn = inView:getChildByName("selBtn")
    if selBtn then
        if self._breakData[key] then
            selBtn:setVisible(true)
            cellBg:loadTexture("globalPanelUI7_cellBg20.png", 1)
        else
            selBtn:setVisible(false)
            cellBg:loadTexture("globalPanelUI7_cellBg21.png", 1)
        end
    end

    --[[self:registerClickEvent(suitIcon, function()
        print("调用tips")
    end)--]]

    local clickFlag = false
    local downX, downY
    local posX, posY
    registerTouchEvent(
        inView,
        function(_, x, y)
            downY = y
            clickFlag = false
            -- inView:setBrightness(40)
        end, 
        function(_, x, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function(_, x, y)
            -- inView:setBrightness(0)
            if clickFlag == false then 
                -- dump(stoneData)
                clickCallback()
            end
        end,
        function(_, x, y)
            -- inView:setBrightness(0)
        end)
    inView:setSwallowTouches(false)
end

--[[
用tableview实现
--]]
function TeamHolyBreakDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    local theight = tableViewBg:getContentSize().height
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, theight))
    self._tableView:setDelegate()
    self._tableView:setDirection(1)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, 0)
    self._tableView:registerScriptHandler(function(table) return self:scrollViewDidScroll(table) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    tableViewBg:addChild(self._tableView)
end

function TeamHolyBreakDialog:scrollViewDidScroll(inView)
    self._inScrolling = inView:isDragging()
end

-- 返回cell的数量
function TeamHolyBreakDialog:numberOfCellsInTableView(table)
   return self:getTableNum()
end

function TeamHolyBreakDialog:getTableNum()
    local tabNum = math.ceil(table.nums(self._tableData)/2)
    return tabNum -- 
end

-- cell的尺寸大小
function TeamHolyBreakDialog:cellSizeForTable(table,idx) 
    local width = 95 
    local height = 75
    return height, width
end

-- 创建在某个位置的cell
function TeamHolyBreakDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=1,2 do
            local listCell = self._itemCell:clone()
            listCell:setName("listCell" .. i)
            listCell:setVisible(true)
            listCell:setAnchorPoint(0, 0)
            if i == 2 then
                listCell:setPosition(195, 0)
            else
                listCell:setPosition(0, 0)
            end
            cell:addChild(listCell)
            cell["listCell" .. i] = listCell
        end
    end

    self:updateCell(cell, indexId)

    return cell
end


function TeamHolyBreakDialog:tabButtonClick(sender, key)
   if sender == nil then 
        print("==sender is nil============")
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        self:tabButtonState(v, false)
    end
    self:tabButtonState(sender, true)
    self:refreshTabData(sender, key)
    audioMgr:playSound("Tab")
end


-- 选项卡状态切换
function TeamHolyBreakDialog:tabButtonState(sender, isSelected)
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    if isSelected then
        sender:setTitleColor(cc.c3b(255,238,160))
        sender:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    else
        sender:setTitleColor(cc.c3b(163,117,86))
        sender:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- sender:getTitleRenderer():enableOutline(cc.c4b(30, 75, 172, 178), 2)
    end
end

function TeamHolyBreakDialog:updateBreakRightData(breakData)
	local breakScroll = self:getUI("bg.rightBg.breakScroll")
	breakScroll:removeAllChildren()
	breakScroll:setInnerContainerSize(breakScroll:getContentSize())
	if not breakData then
		return
	end
	local data = {}
	for i,v in pairs(breakData) do
		for lv,stoneData in pairs(v) do
			local encodeData = {
				id = i
			}
			encodeData.lv = lv
			encodeData.tbStoneData = stoneData
			table.insert(data, encodeData)
		end
	end
	table.sort(data, function(a, b)
		if a.id<b.id then
			return true
		elseif a.id==b.id then
			return a.lv<b.lv
		end
	end)
	
	local totalHeight = 0
	local count = 0
	local selectNode = {}
	for i,v in ipairs(data) do
		if table.nums(v.tbStoneData)>0 then
			count = count + 1
			local param = {suitData = tab.rune[v.id], stoneData = v.tbStoneData[1], isTouch = false}
			local node = IconUtils:createHolyIconById(param)
			local numLab =  ccui.Text:create()
			numLab:setString(table.nums(v.tbStoneData))
			numLab:setName("numLab")
			numLab:setFontSize(20)

			numLab:setFontName(UIUtils.ttfName)
			numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
			numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
			numLab:setAnchorPoint(1, 0)
			local iconColor = node:getChildByName("iconColor")
			if iconColor then
				numLab:setPosition(iconColor:getContentSize().width - 10, 5)
				iconColor:addChild(numLab, 10)
			end
			node:setScale(0.6)
			node:setAnchorPoint(0.5, 0.5)
			breakScroll:addChild(node)
			table.insert(selectNode, node)
			if count%3==1 then
				totalHeight = totalHeight + node:getContentSize().height*0.6
			end
		end
	end
	local containerHeight = breakScroll:getInnerContainerSize().height
	if containerHeight < totalHeight then
		containerHeight = totalHeight
		breakScroll:setInnerContainerSize(cc.size(breakScroll:getContentSize().width, totalHeight))
	end
	for i,v in ipairs(selectNode) do
		local row = math.ceil(i/3)
		local nodeSize = v:getContentSize()
		nodeSize.width = nodeSize.width*0.6
		nodeSize.height = nodeSize.height*0.6
		local index = i%3==0 and 3 or i%3
		local posX = (index-0.5)*nodeSize.width
		local posY = containerHeight - ((row-0.5)*nodeSize.height)
		v:setPosition(cc.p(posX, posY))
	end
end

return TeamHolyBreakDialog