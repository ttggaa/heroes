--[[
    Filename:    ArrowRewardView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-11-05 21:00
    Description: 射箭奖励领取
--]]

local ArrowRewardView = class("ArrowRewardView", BasePopView)

function ArrowRewardView:ctor(param)
	ArrowRewardView.super.ctor(self)
	self._callBack = param.callback
	self._callBack2 = param.callback2
	self._data = param.data
end

function ArrowRewardView:onInit()
	UIUtils:setTitleFormat(self:getUI("bg.title"), 1)

	self:registerClickEventByName("bg.closeBtn", function()
		if self._callBack2 then
			self._callBack2()
		end
		self:close()
		end)

	self:registerClickEventByName("bg.getBtn", function()
		local rNums = 0
		for i=1,3 do
			rNums = rNums + self._data["arrow"]["rewards"][tostring(i)]
		end
		if rNums == 0 then
			self._viewMgr:showTip(lang("ARROW_TIP_2"))
			return
		end

		if self._callBack then
			self._callBack()
			self:close()
		end
		end)

	self._reward = self:getUI("rewardCell")
	self._reward:setVisible(false)

	for i=1,3 do  --铜/银/金
		self:createRewardCell(i)
	end
end


function ArrowRewardView:createRewardCell(inType)
	local rewardCell = self._reward:clone()
	
	local bg = self:getUI("bg.tableBg")
	rewardCell:setPosition(6, rewardCell:getContentSize().height * (inType - 1) + 5)
	rewardCell:setVisible(true)
	bg:addChild(rewardCell)

	local box = rewardCell:getChildByFullName("Image_56.box")
	box:loadTexture("arrow_box"..inType..".png", 1)

	local boxName = {
		[1] = "铜宝箱x",
		[2] = "银宝箱x",
		[3] = "金宝箱x",
	}
	local num = rewardCell:getChildByFullName("Image_56.Label_59") 
	num:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	num:setString(boxName[inType] .. self._data["arrow"]["rewards"][tostring(inType)])

    local tableView = cc.TableView:create(cc.size(490, 80))  --511/67
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(134, 17))
    tableView:setDelegate()
    tableView:setBounceable(true) 
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx, inType) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table, inType) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    rewardCell:addChild(tableView)
    if tableView.setDragSlideable ~= nil then 
        tableView:setDragSlideable(true)
    end
    tableView:reloadData()
end

function ArrowRewardView:scrollViewDidScroll(view)

end

function ArrowRewardView:cellSizeForTable(table,idx)
	return  80, 80 
end

function ArrowRewardView:tableCellAtIndex(table, idx, inType)
	local cell = table:dequeueCell()
	local cellData = tab.arrowAward[inType]["award"][idx + 1]
	if nil == cell then
        cell = cc.TableViewCell:new()
    end

    self:createCell(cell, cellData)
    return cell
end

function ArrowRewardView:numberOfCellsInTableView(table,inType)
	return #tab.arrowAward[inType]["award"]
end

function ArrowRewardView:tableCellWillRecycle(table,cell)

end

function ArrowRewardView:createCell(cell, cellData)
	if cellData == nil then
		return
	end

	local itemType = cellData[1]
    local itemId = cellData[2]
    local itemNum = cellData[3]
    if itemType ~= "tool" then
        itemId = IconUtils.iconIdMap[itemType]
    end

	local itemData = tab:Tool(itemId)
	if cell._item == nil then
		local item = IconUtils:createItemIconById({
	    	itemId = itemId,
	    	num = itemNum,
	    	itemData = itemData,
	    	effect = true,
	    	})
	    item:setVisible(true)
	    item:setSwallowTouches(false)
	    item:setPosition(cc.p(1,0))
	    item:setAnchorPoint(cc.p(0,0))
	    item:setScale(0.7)
	    cell._item = item
	    cell:addChild(item)
	else
		IconUtils:updateItemIconByView(cell._item, {
			itemId = itemId,
	    	num = itemNum,
	    	itemData = itemData,
			})
	end
end

return ArrowRewardView



