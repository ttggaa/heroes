--[[
 	@FileName 	BattleArrayResetDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-07-23 16:15:09
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BattleArrayResetDialog = class("BattleArrayResetDialog", BasePopView)

function BattleArrayResetDialog:ctor( params )
	self.super.ctor(self)

	params = params or {}
	self._returnRes = params.returnRes or {}
	self._resetCallback = params.resetCallback
    self._raceType = params.raceType or 101
end

function BattleArrayResetDialog:onInit(  )

	local title = self:getUI("bg.title_img.title_txt")
    UIUtils:setTitleFormat(title, 1)

    self._consumeNum = tab.setting["BATTLEARRAY_RESET"].value[1][3]
    self:getUI("bg.num"):setString(self._consumeNum)

    local iconBg = self:getUI("bg.iconBg")
    local itemBg = self:getUI("bg.iconBg.item")
    self._iconBg = iconBg

    local btn_close = self:getUI("bg.btn_close")
    self:registerClickEvent(btn_close, function (  )
    	self:close()
    end)

    local btn_cancel = self:getUI("bg.btn_cancel")
    self:registerClickEvent(btn_cancel, function (  )
    	self:close()
    end)

    local btn_reset = self:getUI("bg.btn_reset")
    self:registerClickEvent(btn_reset, function (  )
    	local gem = self._modelMgr:getModel("UserModel"):getData().gem
    	if gem < self._consumeNum then
    		DialogUtils.showNeedCharge({desc = "钻石不足，是否前去充值",callback1=function( )
	            local viewMgr = ViewManager:getInstance()
	            viewMgr:showView("vip.VipView", {viewType = 0})
	        end})
	        return
	    end
    	self:close()
    	if self._resetCallback then
    		self._resetCallback()
    	end
    end)

    if #self._returnRes <= 4 then
        itemBg:setVisible(true)
        itemBg:removeAllChildren()
        local allW = 0
        for k, data in pairs(self._returnRes) do
            local itemId = data[2]
            local itemType = data[1]
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, eventStyle = 1, num = data[3], battleSoulType = self._raceType})
            local centerX = iconBg:getContentSize().width / 2 - itemIcon:getContentSize().width * 0.8 / 2
            local itemW = itemIcon:getContentSize().width * 0.8
            itemIcon:setPosition((itemW + 20) * (k - 1), (iconBg:getContentSize().height - itemIcon:getContentSize().height * 0.8) / 2)
            itemIcon:setScale(0.8)
            itemBg:addChild(itemIcon)
            allW = itemIcon:getPositionX() + itemIcon:getContentSize().width * 0.8
        end
        itemBg:setContentSize(allW, itemBg:getContentSize().height)

        itemBg:setPositionX((iconBg:getContentSize().width - itemBg:getContentSize().width) / 2)
    else
        itemBg:setVisible(false)
        self:addTableView()
    end
end

function BattleArrayResetDialog:addTableView()
    local tableView = cc.TableView:create(cc.size(self._iconBg:getContentSize().width, self._iconBg:getContentSize().height))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    tableView:setName("tableView")
    self._iconBg:addChild(tableView)

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

function BattleArrayResetDialog:cellSizeForTable(table,idx) 
    return self._iconBg:getContentSize().height, 94
end

function BattleArrayResetDialog:numberOfCellsInTableView(table)
   return #self._returnRes
end

function BattleArrayResetDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local item = self:createItem(self._returnRes[idx + 1])
    if item then
        item:setPosition(cc.p(0, 0))
        item:setAnchorPoint(cc.p(0, 0))
        item:setName("cellItem")
        cell:addChild(item)
    end
    return cell
end

function BattleArrayResetDialog:createItem( data )
    if data == nil then return end

    local node = cc.Node:create()
    node:setContentSize(94, self._iconBg:getContentSize().height)
    local itemId = data[2]
    local itemType = data[1]
    if itemType ~= "tool" then
        itemId = IconUtils.iconIdMap[itemType]
    end
    itemIcon = IconUtils:createItemIconById({itemId = itemId, eventStyle = 1, num = data[3], battleSoulType = self._raceType})
    itemIcon:setPosition((node:getContentSize().width - itemIcon:getContentSize().width * 0.8) / 2, (node:getContentSize().height - itemIcon:getContentSize().height * 0.8) / 2)
    itemIcon:setScale(0.8)
    node:addChild(itemIcon)

    return node
end

return BattleArrayResetDialog