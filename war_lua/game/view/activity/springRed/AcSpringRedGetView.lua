--[[
    Filename:    AcSpringRedGetView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-1-23 16:45
    Description: 春节红包
--]]

local AcSpringRedGetView = class("AcSpringRedGetView", BasePopView)

function AcSpringRedGetView:ctor()
	self.super.ctor(self)
	self._sRedModel = self._modelMgr:getModel("SpringRedModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
end

function AcSpringRedGetView:onInit()
	self._box = self:getUI("box")

	local title = self:getUI("bg.bg1.titleBg.Label_41")
	UIUtils:setTitleFormat(title, 1)

	self:getUI("bg.bg1.nothing"):setVisible(false)

	self:registerClickEventByName("bg.bg1.closeBtn", function()
		if self._callback then
			self._callback()
		end
		self:close()
		UIUtils:reloadLuaFile("activity.springRed.AcSpringRedView")
		UIUtils:reloadLuaFile("activity.springRed.AcSpringRedSendView")
		UIUtils:reloadLuaFile("activity.springRed.AcSpringRedGetView")
		end)

	self:setListenReflashWithParam(true)
    self:listenReflash("SpringRedModel", self.refreshUI)
end

function AcSpringRedGetView:reflashUI(inData)
	self._data = self._sRedModel:getData()
	self._callback = inData["callback"]

	self:refreshUI()

	if next(self._data) == nil then
		self:getUI("bg.bg1.nothing"):setVisible(true)
		return
	end

	local tableBg = self:getUI("bg.bg1.tableBg")
    self._tableW, self._tableH = tableBg:getContentSize().width - 10, tableBg:getContentSize().height - 10
    self._tableView = cc.TableView:create(cc.size(self._tableW, self._tableH))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(5, 5))
    self._tableView:setDelegate()
    self._tableView:setBounceable(true) 
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    tableBg:addChild(self._tableView)
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), -3, 6)

    self._tableView:reloadData()
end

function AcSpringRedGetView:scrollViewDidScroll(view)
	UIUtils:ccScrollViewUpdateScrollBar(view)
	local offsetNew = self._tableView:getContentOffset()
end

function AcSpringRedGetView:cellSizeForTable(table,idx)
	self._cellH = self._box:getContentSize().height + 10
	return self._cellH, self._tableW
end

function AcSpringRedGetView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    self:updateCell(idx, cell)

    return cell
end

function AcSpringRedGetView:numberOfCellsInTableView(table)
	return math.ceil(#self._data/4)
end

function AcSpringRedGetView:tableCellWillRecycle(view)

end

function AcSpringRedGetView:updateCell(idx, cell)
	for i=1,4 do
		local index = idx * 4 + i
		local tempBox = cell["box" .. i]
		local boxData = self._data[index]
		if boxData then
			if tempBox == nil then
				tempBox = self._box:clone()
				local wid, hei = tempBox:getContentSize().width, tempBox:getContentSize().height
				tempBox:setPosition(12 + wid * 0.5 + (wid + 17) * (i - 1), hei * 0.5 + 5)
				cell["box" .. i] = tempBox
				cell:addChild(tempBox)
			end

			tempBox:setVisible(true)
			self:updateBox(boxData, tempBox)
		else
			if tempBox then
				tempBox:setVisible(false)
			end
		end
	end
end

function AcSpringRedGetView:updateBox(inData, inObj)
	local ttype = inData["type"]

	--inObj
	inObj:loadTexture("ac_sr_gbox" .. ttype .. ".png", 1)
	inObj:setSwallowTouches(false)
	local downY, clickFlag
	registerTouchEvent(inObj,
        function (_, _, y)
            downY = y
            clickFlag = false
            
        end, 
        function (_, _, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function ()
            if clickFlag == false then 
                self:robSpringRed(inData)
            end
        end,
        function ()
        end)

	--title
	local titleDes = inObj:getChildByName("titleDes")
	titleDes:setPosition(85, 194)
	titleDes:setString(lang("RedPacketName_" .. ttype))
	
	--words
	local words = inObj:getChildByName("word")
	words:setString(lang(inData["wishId"]))
	words:setColor(cc.c4b(248, 243, 230, 255))
	words:enable2Color(1, cc.c4b(245, 221, 156, 255))
	words:enableOutline(cc.c4b(66, 66, 66, 255), 1)
	words:setPosition(19, 140)

	--name
	local name = inObj:getChildByName("name")
	name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	name:setColor(cc.c4b(248, 243, 230, 255))
	name:enable2Color(1, cc.c4b(245, 221, 156, 255))
	name:setPosition(84, 40)

	if OS_IS_WINDOWS then
		name:setString((inData["name"] or "") .. "--" .. inData["id"])
	else
		name:setString(inData["name"] or "")
	end

	if ttype == 1 then
		titleDes:setColor(cc.c4b(250, 244, 228, 255))
		titleDes:enable2Color(1, cc.c4b(221, 203, 167, 255))
		titleDes:enableOutline(cc.c4b(66, 66, 66, 255), 1)

	else
		titleDes:setColor(cc.c4b(250, 244, 228, 255))
		titleDes:enable2Color(1, cc.c4b(221, 203, 167, 255))
		titleDes:enableOutline(cc.c4b(66, 66, 66, 255), 1)
	end
end

function AcSpringRedGetView:robSpringRed(inData)
	local ttype = inData["type"]

	--活动开启提示
	local isOpen, openT = self._sRedModel:checkRobRedTime()
	if not isOpen then
		local tipDes
		if openT then
			tipDes = string.gsub(lang("RedPacket_Tips1"), "{$num}", openT) 
		else
			tipDes = lang("OVERDUETIPS_1")
		end
		self._viewMgr:showTip(tipDes)
		return
	end

	--是否自己抢过
	local userId = self._userModel:getData()._id
	if inData["ids"] then
		for i,v in ipairs(inData["ids"]) do
			if v == userId then
				self._viewMgr:showTip(lang("RedPacket_Tips2"))
				return
			end
		end
	end

	--领取上限
	local isCanG = self._sRedModel:checkGetDayInfo(2, ttype)
	if not isCanG then
		self._viewMgr:showTip(lang("RedPacket_Tips4"))
		return
	end

	self._serverMgr:sendMsg("RedPacketServer", "robRedPacket", {id = inData["id"]}, true, {}, function (result, error)
		if result["errorCode"] == 8308 then
			self._viewMgr:showTip(lang("RedPacket_Tips6"))
		end

		DialogUtils.showGiftGet( {
            gifts = result["reward"], 
            notPop = true})

		--删除红包
		local lastNum = #self._data
		self._sRedModel:deleteRobedRed(inData["id"])
    	self._data = clone(self._sRedModel:getData())
    	local curNum = #self._data
    	self:refreshUI()

        local offsetLast = self._tableView:getContentOffset()
        self._tableView:reloadData()
        local offsetNew = self._tableView:getContentOffset()

        local tmp1 = math.fmod(lastNum, 4)
        local tmp2 = math.fmod(curNum, 4)
        local cellNum = math.ceil(#self._data/4)
        if offsetNew.y < 0 then   --多于一屏数据
            if tmp1 > 0 and tmp2 == 0 then
            	if cellNum >= 2 and offsetLast.y >= -self._cellH then     --底部少于一行 & 至少有两行
            		self._tableView:setContentOffset(cc.p(offsetLast.x, 0))  

            	else
            		self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y + self._cellH))  --上移（其实也是到原位）
            	end

            else
            	self._tableView:setContentOffset(cc.p(offsetLast.x, offsetLast.y))  --原位
            end
        end

        --刷新全局抢红包界面  wangyan
        if self._viewMgr._redBoxLayer.springRedLayer ~= nil then
            self._viewMgr._redBoxLayer.springRedLayer:removeSingleRed(inData["id"])
        end
	end)
end

function AcSpringRedGetView:refreshUI()
	local dayinfo = {83, 84, 85}
	for i=1, 3 do
		local curNum = self._playerTodayModel:getDayInfo(dayinfo[i])
		local maxNum = tab.actRedPacket[i]["limit_receive"]
		local num = self:getUI("bg.bg1.num" .. i)
		num:setString(math.max(maxNum - curNum, 0))
	end

	local nothing = self:getUI("bg.bg1.nothing")
	nothing:setVisible(false)
	if not self._data or next(self._data) == nil then
		nothing:setVisible(true)
	end
end

return AcSpringRedGetView