-- Author lannan

local tbElementName = {"周一","周二","周三","周四","周五"}
local tbTypeText = {"攻", "防", "突", "射", "魔"}

local ProfessionBattleDialog = class("ProfessionBattleView", BasePopView)

function ProfessionBattleDialog:ctor()
	ProfessionBattleDialog.super.ctor(self)
	self._elemItemCount = 7
	self._itemList = {}
	self._professionBattleModel = self._modelMgr:getModel("ProfessionBattleModel")
	self._curWeek = self._professionBattleModel:getCurWeekDay()
	self._canIndex = 1
end

function ProfessionBattleDialog:getAsyncRes()
    return 
        {
            {"asset/ui/professionBattle.plist", "asset/ui/professionBattle.png"},
        }
end

function ProfessionBattleDialog:onInit()
	local closeBtn = self:getUI("bg.layer.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		UIUtils:reloadLuaFile("pve.ProfessionBattleDialog")
	end)

	local title = self:getUI("bg.layer.titleBg.titleLabel")
	UIUtils:setTitleFormat(title, 1)

	self._itemView = self:getUI("bg.layer.itemView")
	self._elemItem = self:getUI("bg.layer.elemItem")
	self._elemItem:setVisible(false)
	self._levelItem = self:getUI("bg.layer.levelItem")
	self._levelItem:setVisible(false)
	--剩余次数
	self._timesLabel = self:getUI("bg.layer.timesLabel")
	self._timesLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)

	--创建周一~周五左侧列表
	local itemHeight = self._itemView:getContentSize().height
	self._elementTable = {}
	for index = 1 , self._elemItemCount do
		local weekData = self._professionBattleModel:getWeekList(index)
		if weekData then
			self._elementTable[index] = weekData
			local elemItem = self:createElemItem(index)
			elemItem:setAnchorPoint(0,0)
			local elemItemHeight = elemItem:getContentSize().height
			elemItem:setPosition(0,itemHeight - elemItemHeight*index)
			self._itemView:addChild(elemItem)
			table.insert(self._itemList, elemItem)
		end
	end
	
	--层列表
	self._layerNode = self:getUI("bg.layer.layerPanel")
	self:createTableView()
	ScheduleMgr:nextFrameCall(self, function()
		self:scrollToCurPos()
	end)
	
	local week = self._professionBattleModel:getCurWeekDay()
	self:switchBtn(week)
	--剩余次数
	self:setHasTimes()
	
    self:listenReflash("ProfessionBattleModel", self.updateUI)
	
	local hasFinishTrigger = self._modelMgr:getModel("UserModel"):hasTrigger(57)
	if not hasFinishTrigger then
		self._viewMgr:doTriggerByName(57)
	end
	
	self:registerTimer(5,0,1,function(  )
		local week = self._professionBattleModel:getCurWeekDay()
		if not self._elementTable[week] then
			self:close()
		else
			self:switchBtn(week)
			self:updateUI()
		end
	end)
end

function ProfessionBattleDialog:createElemItem(week)
	local elemItem = self:getUI("bg.layer.elemItem"):clone()
	elemItem:setVisible(true)
	elemItem.floorLabel = elemItem:getChildByFullName("floorLabel")
	-- elemItem.floorLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	elemItem.floorLabel:setString(tbElementName[week])

	local curLayerNum = self._professionBattleModel:getFinishiNumByWeek(week)
	
	elemItem.curFloorLab = elemItem:getChildByFullName("curFloor")
	local curText = tbTypeText[self._professionBattleModel:getCurWeekType(week)]
	curText = curText .. "("..curLayerNum.."/"..#self._elementTable[week]..")"
	elemItem.curFloorLab:setString(curText)

	elemItem.lockBg = elemItem:getChildByFullName("lockBg")
	elemItem.lockIcon = elemItem:getChildByFullName("lockIcon")
	elemItem.normalBg = elemItem:getChildByFullName("normalBg")
	--当前
	elemItem.curIcon = elemItem:getChildByFullName("curIcon")
	elemItem.curIcon:getChildByFullName("Label_53"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	elemItem.curIcon:getChildByFullName("Label_53"):setFontName(UIUtils.ttfName)
	
	--是否开启
	local isOpen = week == self._professionBattleModel:getCurWeekDay()
	elemItem.lockBg:setVisible(not isOpen)
	elemItem.lockIcon:setVisible(not isOpen)
	elemItem.normalBg:setVisible(isOpen)
	elemItem.floorLabel:setColor(isOpen and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor8)
	elemItem.curFloorLab:setColor(isOpen and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor8)

	elemItem.lockIcon:setSaturation(-80)
	self:registerClickEvent(elemItem, function()
		if week~=self._professionBattleModel:getCurWeekDay() then
			local tipDesc = string.format("%s开启", tbElementName[week])
			self._viewMgr:showTip(tipDesc)
			return
		end
		self:switchBtn(week)
	end)
	return elemItem
end

function ProfessionBattleDialog:createTableView()
    if self._layerNodeTableView then
        self._layerNodeTableView:reloadData()
        return 
    end
    local tableView = cc.TableView:create(cc.size(578,404))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._layerNode:addChild(tableView,999)
--    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
--    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._layerNodeTableView = tableView
end

--[[function ProfessionBattleDialog:scrollViewDidScroll(view)

end

function ProfessionBattleDialog:tableCellTouched(table,cell)

end--]]

function ProfessionBattleDialog:cellSizeForTable(table,idx) 
	return 102,568
end

function ProfessionBattleDialog:tableCellAtIndex(table,idx)
	local index = idx + 1
	local cell = table:dequeueCell()

	if nil == cell then
		cell = cc.TableViewCell:new()
		local itemView = self._levelItem:clone()
		itemView:setVisible(true)
		itemView:setAnchorPoint(0,0)
		itemView:setTouchEnabled(false)
		itemView:setPosition(10, 0)
		itemView:setTag(9999)
		cell:addChild(itemView)
		self:createLevelItem(itemView,index)
	else
		local itemView = cell:getChildByTag(9999)
		if not itemView then return end
		self:createLevelItem(itemView,index)
	end
	return cell
end

function ProfessionBattleDialog:numberOfCellsInTableView(table)
	return #self._elementTable[self._curWeek]
end

function ProfessionBattleDialog:createLevelItem(layerCell,idx)
	
	layerCell.itemBg = layerCell:getChildByFullName("itemBg")
	layerCell.unOpenIcon = layerCell:getChildByFullName("unOpenIcon")

	layerCell.advanceBtn = layerCell:getChildByFullName("advanceBtn")
	layerCell.sweepBtn = layerCell:getChildByFullName("sweepBtn")
	layerCell.typeLab = layerCell:getChildByFullName("typeLab")
	layerCell.levelLab = layerCell:getChildByFullName("levelLab")
	layerCell.icon = layerCell:getChildByFullName("icon")
	--设置关卡奖励
	self:updateLayerItem(layerCell,idx)

	self:L10N_Text(layerCell.advanceBtn)
	self:registerClickEvent(layerCell.advanceBtn, function()
		local openLv = self._elementTable[self._curWeek][tonumber(idx)]["level"]

		local curLv = self._modelMgr:getModel("UserModel"):getPlayerLevel()
		if curLv < openLv then
			self._viewMgr:showTip("等级达到"..openLv.."开启")
			return
		end
		local stageID = self._elementTable[self._curWeek][tonumber(idx)]["id"]
		self._viewMgr:showView("pve.LegionsStageInfoView", {index = idx, week = self._curWeek, stageId = stageID or 101})

		--[[if self._enterType == ProfessionBattleDialog.kEnterType2 then
			self._serverMgr:sendMsg("ElementServer", "getElementFirstData", {elementId = self._curWeek,stageId = idx}, true, {}, function(result, errorCode)
				if errorCode ~= 0 then 
					errorCallback()
					self._viewMgr:unlock(51)
					return
				end
				self._parent:reLoadUI({item = self._curWeek,layerNum = idx,serverData = result})
				self:close()
			end)
		else
			self._viewMgr:showView("elemental.ElementalLayerView",{planeId = self._curWeek,layerNum = idx})
			self:close()
		end--]]
	end)
	--扫荡
	self:L10N_Text(layerCell.sweepBtn)
	self:registerClickEvent(layerCell.sweepBtn, function()
		-- 判断次数限制
		local maxTimes = self._professionBattleModel:getMaxTimes()
		local hasTimes = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(96)
		if maxTimes - hasTimes <= 0 then
			self._viewMgr:showTip(lang("TIPS_PVE_01"))
			return
		end
		-- 时间过期
		local weekDay = self._professionBattleModel:getCurWeekDay()
		if weekDay ~= self._curWeek then
			self._viewMgr:showTip("挑战时间已过期")
			return
		end
		self._serverMgr:sendMsg("ProfessionBattleServer", "sweep", {barrierId = self._elementTable[self._curWeek][tonumber(idx)]["id"]}, true, {}, function(success, result)
			if not success then
				self._viewMgr:showTip("扫荡失败。")
				return
			end
			local params = {gifts = result.reward}
			DialogUtils.showGiftGet(params)
		end)
	end)
	layerCell:setSwallowTouches(false)
	return layerCell
end

function ProfessionBattleDialog:updateLayerItem(layerCell, idx)
	local itemData = self._elementTable[self._curWeek][tonumber(idx)]
	local recordData = self._professionBattleModel:getDataById(itemData.id)
	local curLv = self._modelMgr:getModel("UserModel"):getPlayerLevel()
	
	layerCell.levelLab:setString(itemData.level.."级")
	layerCell.typeLab:setString(tbTypeText[itemData.subid])
	layerCell.icon:loadTexture(string.format("battle_type_img_%s.png", itemData.subid), 1)
	
	local isBeforeOpen = true
	if idx~=1 then
		local beforeData = self._elementTable[self._curWeek][tonumber(idx)-1]
		local beforeRecordData = self._professionBattleModel:getDataById(beforeData.id)
		isBeforeOpen = beforeRecordData and beforeRecordData.win==1
	end
	
	local isOpen = idx==1 or (idx~=1 and isBeforeOpen)
	isOpen = isOpen and curLv >=itemData.level
	if isOpen then
		self._canIndex = idx
		layerCell.advanceBtn:setVisible(true)
		layerCell.sweepBtn:setVisible(recordData and recordData.win==1)
		layerCell.unOpenIcon:setVisible(false)
	else
		layerCell.advanceBtn:setVisible(false)
		layerCell.sweepBtn:setVisible(false)
		layerCell.unOpenIcon:setVisible(true)
	end
end

function ProfessionBattleDialog:switchBtn(index)
	if index > #self._itemList then return end
	for i, itemNode in ipairs(self._itemList) do
		local isOpen = i==index
		itemNode.lockBg:setVisible(not isOpen)
		itemNode.lockIcon:setVisible(not isOpen)
		itemNode.normalBg:setVisible(isOpen)
		itemNode.floorLabel:setColor(isOpen and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor8)
		itemNode.curFloorLab:setColor(isOpen and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccUIBaseColor8)
		itemNode:getChildByFullName("selectBg"):setVisible(isOpen)
		itemNode.curIcon:setVisible(isOpen)
	end
	self._curWeek = index
	if self._layerNodeTableView then
		self._layerNodeTableView:reloadData()
		self:setHasTimes()
		return
	end
end

function ProfessionBattleDialog:scrollToCurPos()
    local offsetNum = 0
    if self._canIndex < 2 then
        offsetNum = 0
    elseif  self._canIndex > (#self._elementTable[self._curWeek] - 4) then
        offsetNum = #self._elementTable[self._curWeek] - 4
    else
        offsetNum = self._canIndex - 1
    end

    local off = self._layerNodeTableView:getContentOffset()
    self._layerNodeTableView:setContentOffset(cc.p(0, off.y + offsetNum* 102), false)
end

function ProfessionBattleDialog:updateUI()
	if self._layerNodeTableView then
		local offSetY = self._layerNodeTableView:getContentOffset().y
		self._layerNodeTableView:reloadData()
		self._layerNodeTableView:setContentOffset(cc.p(0, offSetY))
	end
	
	local elemItem = self._itemList[self._curWeek]
	if elemItem and elemItem.curFloorLab then
		local curLayerNum = self._professionBattleModel:getFinishiNumByWeek(self._curWeek)
		local curText = tbTypeText[self._professionBattleModel:getCurWeekType(self._curWeek)]
		curText = curText .. "("..curLayerNum.."/"..#self._elementTable[self._curWeek]..")"
		elemItem.curFloorLab:setString(curText)
	end
	self:setHasTimes()
end

function ProfessionBattleDialog:setHasTimes()
	local maxTimes = self._professionBattleModel:getMaxTimes()
	local hasTimes = maxTimes - self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(96)
	self._timesLabel:setString(hasTimes.."/"..maxTimes)
	self._timesLabel:setColor(hasTimes == 0 and cc.c3b(255, 0, 0) or cc.c3b(0, 255, 0))
end

return ProfessionBattleDialog