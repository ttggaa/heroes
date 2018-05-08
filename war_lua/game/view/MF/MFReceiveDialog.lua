--[[
    Filename:    MFReceiveDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local MFReceiveDialog = class("MFReceiveDialog", BasePopView)

function MFReceiveDialog:ctor(data)
    MFReceiveDialog.super.ctor(self)
	self._gifts = data.gifts
	self._callback = data.callback
	self._titleDesc = data.desc
	self._times = {}
	self._finishTaskIds = {}
--	self._rewards = data.rewards
	for i,v in ipairs(data.gifts) do
		self._finishTaskIds[v.index] = true
	end
	self.dontRemoveRes = true
end

function MFReceiveDialog:getAsyncRes()
    return 
    {
        {"asset/ui/mf1.plist", "asset/ui/mf1.png"},
    }
end



function MFReceiveDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFReceiveDialog")
        end
        closeBtn:setTouchEnabled(false)
		self:finishMFTasks()
	end)
	
	self._tableItem = self:getUI("item")
	self._tableItem:setVisible(false)
	self:onInitTableView()
	
	--领主管家使用 add By haotaian
	if self._titleDesc then
		local desc = self:getUI("bg.tipLabel")
		desc:setString(self._titleDesc)
	end
	
	local mc = mcMgr:createViewMC("renwuwancheng_renwuwancheng")
	mc:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
	self:addChild(mc, 10)
	
end

function MFReceiveDialog:onPopEnd()
--	DialogUtils.showGiftGet({gifts = self._rewards})
end

function MFReceiveDialog:onInitTableView()
	local tableNode = self:getUI("bg.tableBg")
    local tableView = cc.TableView:create(cc.size(678, 390))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(5 ,5)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableNode:addChild(tableView, 5)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), 0, 6)
    self._tableView = tableView
    tableView:setBounceable(#self._gifts>3)
    self._inScrolling = false
end

function MFReceiveDialog:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
	self._tableOffset = view:getContentOffset()
	UIUtils:ccScrollViewUpdateScrollBar(view)
end

function MFReceiveDialog:cellSizeForTable(tabView, index)
	return 127, 688
end

function MFReceiveDialog:tableCellAtIndex(tabView, index)
	local cell = tabView:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local item = self:createItem(self._gifts[index+1], index)
    if item then
        item:setAnchorPoint(cc.p(0,0))
        item:setPosition(cc.p(0,0))
		item:setName("cellItem")
        cell:addChild(item)
    end
    return cell
end

function MFReceiveDialog:createItem(itemData, index)
	if not itemData then return end
	local item = self._tableItem:clone()
	item:setVisible(true)
	item:setSwallowTouches(false)

	local icon = item:getChildByFullName("icon")
	icon:loadTexture("mf_before" .. itemData.index .. ".png", 1)
	local getBtn = item:getChildByFullName("btn_get")
	local againGetBtn = item:getChildByFullName("btn_get_again")
	local giftPanel = item:getChildByFullName("giftPanel")

	for i,v in ipairs(itemData.gifts) do
		local itemType = v.type or v[1]
		local itemId = v.typeId or v[2]
		local itemNum = v.num or v[3]
		if itemType ~= "tool" and itemType ~= "hero" and itemType ~= "team" then
			itemId = IconUtils.iconIdMap[itemType]
		end
		local itemConfig = tab:Tool(itemId)
		if itemConfig == nil then
			itemConfig = tab:Team(itemId)
		end
		
		local itemNode = IconUtils:createItemIconById({itemId = itemId, num = itemNum, itemData = itemConfig, effect = false })
		itemNode:setSwallowTouches(false)
		itemNode:setScale(0.85)
		itemNode:setScaleAnim(true)
		itemNode:setAnchorPoint(0, 0.5)
		local x = (i-1)*itemNode:getContentSize().width - (i-1)*8
		itemNode:setPosition(x, giftPanel:getContentSize().height/2)
		itemNode:setVisible(true)
		giftPanel:addChild(itemNode)
	end

	--	local mfData = self._modelMgr:getModel("MFModel"):getTasksById(itemData.index)
	local resImage = item:getChildByFullName("resImage")
	local resCountLab = item:getChildByFullName("resCount")
	if not self._times[itemData.index] then
		self._times[itemData.index]=2
	end
	local times = self._times[itemData.index]
	if times==1 then
		resImage:setVisible(false)
		resCountLab:setVisible(false)
		self:registerClickEvent(getBtn, function()
			self:getMFRewards(itemData.index, index)
		end)
	else
		local viplvl = self._modelMgr:getModel("VipModel"):getData().level
		local mfTimes = tab:Vip(viplvl).mfDouble
		local mfData = self._modelMgr:getModel("MFModel"):getTasksById(itemData.index)
		local taskTab = tab:MfTask(mfData["taskId"])
		local costMf = 0
		if times > 3 then
			costMf = taskTab["cost"][4][3]
		else
			costMf = taskTab["cost"][times][3]
		end

		local activityModel = self._modelMgr:getModel("ActivityModel")
		local openActivity = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_20)
		costMf = costMf * (1 + openActivity)
		resCountLab:setString(costMf)
		local userData = self._modelMgr:getModel("UserModel"):getData()
		if times>mfTimes then
			--次数用尽
			againGetBtn:setTitleText("次数用尽")
			againGetBtn:setSaturation(-100)
			
			resImage:setVisible(false)
			resCountLab:setVisible(false)
			self:registerClickEvent(againGetBtn, function()
				if mfTimes < 4 then
					self._buyTipDesTable = {des1 = lang("MF_VIP1")}
					self._viewMgr:showDialog("global.GlobalResTipDialog",self._buyTipDesTable or {},true)
				elseif mfTimes == 4 then
					self._viewMgr:showTip(lang("MF_VIP2"))
				else
					self._viewMgr:showTip(lang("MF_VIP2"))
				end
			end)
		else
			resImage:setVisible(true)
			resCountLab:setVisible(true)
			againGetBtn:setSaturation(0)
			if userData.gem < costMf then
				resCountLab:setColor(cc.c3b(255,23,23))
				self:registerClickEvent(againGetBtn, function()
					DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
						local viewMgr = ViewManager:getInstance()
						viewMgr:showView("vip.VipView", {viewType = 0})
					end}) 
				end)
			else
				resCountLab:setColor(cc.c3b(60,42,30))
				self:registerClickEvent(againGetBtn, function()
					self:getMFRewards(itemData.index, index)
				end)
			end
		end
	end
	getBtn:setVisible(times==1)
	againGetBtn:setVisible(times>1)
	
	return item
end

function MFReceiveDialog:updateBtnState(cityIndex, cellIndex)
	local cell = self._tableView:cellAtIndex(cellIndex)
	if cell and cell:getChildByName("cellItem") then
		local item = cell:getChildByName("cellItem")
		
	end
end

function MFReceiveDialog:numberOfCellsInTableView(tabView)
	return #self._gifts
end

function MFReceiveDialog:getMFRewards(cityIndex, cellIndex)
	self._serverMgr:sendMsg("MFServer", "getfinishMFReward", {id = cityIndex}, true, {}, function (result)
--		self:updateGemBtn()
		local viplvl = self._modelMgr:getModel("VipModel"):getData().level
		local mfTimes = tab:Vip(viplvl).mfDouble
		local mfData = self._modelMgr:getModel("MFModel"):getTasksById(cityIndex)
		if self._times[cityIndex] == mfTimes then
			DialogUtils.showGiftGet({
				gifts = result.reward,
				callback = function()
				-- self:finishMF(index)
			end,notPop = true})
		else
			DialogUtils.showGiftGet({gifts = result.reward,notPop = true})
		end
		self._times[cityIndex] = mfData.times + 1
		for i=1, #self._gifts do
			self._tableView:updateCellAtIndex(i-1)
		end
	end)--[[, function(errorId)
		if errorId ~= nil and self.close then
			self:close()
		end
	end--]]
end

function MFReceiveDialog:finishMFTasks()
	if table.nums(self._finishTaskIds)>0 then
		local tbIds = {}
		for i,v in pairs(self._finishTaskIds) do
			table.insert(tbIds, i)
		end
		self._serverMgr:sendMsg("MFServer", "finishMF", { id = tbIds }, true, {}, function (result)
			if self._callback then
				ScheduleMgr:delayCall(0,self,function ( ... )
					self._callback()
				end)
			end
			self:close()
		end)
	else
		self:close()
	end
end

return MFReceiveDialog