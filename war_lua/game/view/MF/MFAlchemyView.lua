--
-- Author: <lannan@playcrab.com>
-- Date: 2018-07-30 17:03:31
--
local MFAlchemyView = class("MFAlchemyView",BaseView)

local l_profuctSlotPos = {
	[1] = cc.p(203, 35),
	[2] = cc.p(294, 35),
	[3] = cc.p(386, 35),
	[4] = cc.p(477, 35),
	[5] = cc.p(569, 35),
	[6] = cc.p(660, 35),
	[7] = cc.p(752, 35),
	[8] = cc.p(844, 35),
}

function MFAlchemyView:ctor(params)
    MFAlchemyView.super.ctor(self)
    params = params or {}
--	self.initAnimType = 3
	self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil 
	self._alchemyModel = self._modelMgr:getModel("AlchemyModel")
--	self._formulaType = nil
	self._nowProduceNum = 0
	self._isNowProduce = false
	self._tabState = 1
	self._refreshBag = false
	self._callback = params.callback
end

function MFAlchemyView:onInit()
	self._bg = self:getUI("bg")
	
	UIUtils:setTabChangeAnimEnable(self:getUI("bg.bgImg.tab_warehouse"),790,handler(self, self.tabButtonClick))
	UIUtils:setTabChangeAnimEnable(self:getUI("bg.bgImg.tab_formula"),790,handler(self, self.tabButtonClick))
	
	self._tabEventTarget = {}
	table.insert(self._tabEventTarget, self:getUI("bg.bgImg.tab_warehouse"))
	table.insert(self._tabEventTarget, self:getUI("bg.bgImg.tab_formula"))
	self._playAnimBgOffX = 46
	self._playAnimBgOffY = -28
	self._tabPosX = 790
	for k,button in pairs(self._tabEventTarget) do
		button:setTitleFontName(UIUtils.ttfName)
		button:setPositionX(self._tabPosX)
		button:setZOrder(-10)
		button:setAnchorPoint(0,0.5)
	end
	self:reorderTabs()
	
	--初始化配方layer
	--筛选
	local formulaLayer = self:getUI("bg.formulaLayer")
	--刷新
	local refreshBtn = formulaLayer:getChildByFullName("rightBg.refreshBtn")
	self:registerClickEvent(refreshBtn, function()
		self:refreshFormulaData()
	end)
	local refreshTitle = formulaLayer:getChildByFullName("rightBg.refreshTitle")
	refreshTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	--配方库
	local libraryBtn = formulaLayer:getChildByFullName("rightBg.libraryBtn")
	self:registerClickEvent(libraryBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("MF.MFAlchemyFormulaDialog")
		end
		self._viewMgr:showDialog("MF.MFAlchemyFormulaDialog")
	end)
	--页码
	local reloadFormulaPageData = function()
		self._formulaTabData, self._formulaMaxPage = self._alchemyModel:getFormulaTableData(self._formulaPage)
		self:loadFormulaBagData()
	end
	local prePageBtn = formulaLayer:getChildByFullName("rightBg.prePageBtn")
	prePageBtn:setScaleAnim(false)
	self:registerClickEvent(prePageBtn, function()
		if self._formulaPage~=1 then
			self._formulaPage = self._formulaPage - 1
			reloadFormulaPageData()
		end
	end)
	local nextPageBtn = formulaLayer:getChildByFullName("rightBg.nextPageBtn")
	nextPageBtn:setScaleAnim(false)
	self:registerClickEvent(nextPageBtn, function()
		if self._formulaPage~=self._formulaMaxPage then
			self._formulaPage = self._formulaPage + 1
			reloadFormulaPageData()
		end
	end)
	--左侧信息
	local formulaNameLab = formulaLayer:getChildByFullName("leftBg.formulaNameLab")
	formulaNameLab:enable2Color(1, cc.c3b(14, 55, 76))
	self._titlePanel = self:getUI("titlePanel")
	self._titlePanel:setVisible(false)
	self._infoPanel = self:getUI("infoPanel")
	self._infoPanel:setVisible(false)
	
	--初始化仓库layer
	local warehouseLayer = self:getUI("bg.warehouseLayer")
	local artificeBtn = warehouseLayer:getChildByName("artificeBtn")
	self:registerClickEvent(artificeBtn, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("MF.MFAlchemyMaterialDialog")
		end
		self._viewMgr:showDialog("MF.MFAlchemyMaterialDialog", {callback = function()
			local haveCoinNumLab = self:getUI("bg.warehouseLayer.leftNum")
			haveCoinNumLab:setString(self._modelMgr:getModel("UserModel"):getResNumByType("alchemy"))
		end})
	end)
	local reportBtn = self:getUI("bg.warehouseLayer.reportBtn")
	UIUtils:addFuncBtnName(reportBtn, "炼金记录", nil, true, 16)
	local ruleBtn = warehouseLayer:getChildByName("infoBtn")
	self:registerClickEvent(ruleBtn, function()
		self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = lang("alchemy_Rules")}, true)
	end)
	
	self:initEffect()
	
	--生产栏位
	self:initProductSlot()
	
	--选中特效
	self._formulaSelectMC = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
	self._formulaSelectMC:setName("anim")
	self._formulaSelectMC:setVisible(false)
	self._formulaSelectMC:setScale(0.7)
	self._formulaSelectMC.inSlot = false
	self:addChild(self._formulaSelectMC, 10)
	
	
	self:registerTimer(5,0,1,function(  )
		self._serverMgr:sendMsg("AlchemyServer", "getInfo", {}, true, {}, function()
			self:loadWarehouseData()
			self._formulaTabData, self._formulaMaxPage = self._alchemyModel:getFormulaTableData(1)
			self:loadFormulaBagData()
		end)
    end)
	self:listenReflash("UserModel", self.refreshGemCount)
end

function MFAlchemyView:reorderTabs( )
	if not self._tabPoses then
		self._tabPoses = {}
		for k,tab in pairs(self._tabEventTarget) do
			local pos = cc.p(tab:getPosition())
			table.insert(self._tabPoses,pos)
		end
		table.sort(self._tabPoses,function ( a,b )
			return a.y > b.y
		end)
	end
	for i,v in ipairs(self._tabEventTarget) do
		self._tabEventTarget[i]:setVisible(true)
		self._tabEventTarget[i]:setTitleColor(UIUtils.colorTable.ccUITabColor1)
		self:tabButtonState(self._tabEventTarget[i], false,true)
		UIUtils:setGray(self._tabEventTarget[i],false)
		UIUtils:setTabChangeAnimEnable(self._tabEventTarget[i],790,handler(self, self.tabButtonClick))
	end
	local isChangeSelect = true
	if isChangeSelect then
		self:tabButtonClick(self._tabEventTarget[1],true)
	end
end

function MFAlchemyView:tabButtonClick(sender, noAudio)
	if sender == nil then 
		return 
	end
	local callback = function()
		if not noAudio then
			audioMgr:playSound("Tab")
		end
		for k,v in pairs(self._tabEventTarget) do
			if v ~= sender then 
				local text = v:getTitleRenderer()
				v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
				text:disableEffect()
				-- text:setPositionX(85)
				v:setScaleAnim(false)
				v:stopAllActions()
				v:setScale(1)
				if v:getChildByName("changeBtnStatusAnim") then 
					v:getChildByName("changeBtnStatusAnim"):removeFromParent()
				end
				v:setZOrder(-10)
				self:tabButtonState(v, false)
			end
		end
		if self._preBtn then
			UIUtils:tabChangeAnim(self._preBtn,nil,true)
		end

		self._preBtn = sender
		sender:stopAllActions()
		sender:setZOrder(99)
		UIUtils:tabChangeAnim(sender,function( )
			local text = sender:getTitleRenderer()
			text:disableEffect()
			sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
			self:tabButtonState(sender, true)
		end)
		self:reloadViewData(sender)
	end
	if sender:getName()=="tab_warehouse" then
		self._tabState = 1
		callback()
	else
		self._tabState = 2
		callback()
	end
end

function MFAlchemyView:tabButtonState(sender, isSelected,isDisabled)
	sender:setBright(not isSelected)
	sender:setEnabled(not isSelected)
end

function MFAlchemyView:reloadViewData(sender)
	local tabName = sender:getName()
	local wareLayer = self:getUI("bg.warehouseLayer")
	local formulaLayer = self:getUI("bg.formulaLayer")
	wareLayer:setVisible(false)
	formulaLayer:setVisible(false)
	if tabName == "tab_warehouse" then
		if self._formulaSelectMC then
			self._formulaSelectMC:setVisible(false)
		end
		wareLayer:setVisible(true)
		self:loadWarehouseData()
	elseif tabName == "tab_formula" then
		formulaLayer:setVisible(true)
--		self._formulaType = nil
		self._formulaPage = 1
		self._formulaTabData, self._formulaMaxPage = self._alchemyModel:getFormulaTableData(1)
		self:loadFormulaBagData()
	end
end

function MFAlchemyView:loadFormulaBagData()
	local bagPanel = self:getUI("bg.formulaLayer.rightBg.tableBg")
	
	local tabNum = table.nums(tab.alchemyPlan)
	tabNum = math.ceil(tabNum/5)
	for rol=1, 4 do
		local posY = bagPanel:getContentSize().height - (rol*2-1)/2*74
		for i=1, 5 do
			local index = (rol-1)*5+i
			local formulaData = self._formulaTabData[index]
			local node = bagPanel:getChildByName("alchemyNode"..rol..i)
			if not node then
				node = IconUtils:createAlchemyIcon(formulaData)
				local posX = 2+i*8+(i*2-1)/2*node:getContentSize().width
				node:setPosition(cc.p(posX, posY))
				node:setName("alchemyNode"..rol..i)
				bagPanel:addChild(node)
				
				local refreshEffect = mcMgr:createViewMC("yingxiongzhuanjingshuaxin1_heromasteryrefresh", false, false)
				refreshEffect:setVisible(false)
				refreshEffect:setName("refreshEffect")
				refreshEffect:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
				node:addChild(refreshEffect, 100)
			else
				IconUtils:updateAlchemyIcon(node, formulaData)
			end
			node:setVisible(true)
			node:setTouchEnabled(false)
			if formulaData~=nil then
				if self._refreshBag then
					local refreshEffect = node:getChildByName("refreshEffect")
					if not refreshEffect then return end
					refreshEffect:setVisible(true)
					refreshEffect:addEndCallback(function()
						refreshEffect:stop()
						refreshEffect:setVisible(false)
						self._refreshBag = false
					end)
					refreshEffect:gotoAndPlay(0)
				end
				self:registerNodeEvent(node, formulaData)
			end
		end
	end
	local firstNode = bagPanel:getChildByName("alchemyNode11")
	if firstNode and firstNode:isVisible() and self._formulaTabData[1]~=nil and self._tabState==2 then
		local pos = cc.p(bagPanel:convertToWorldSpace(cc.p(firstNode:getPosition())))
		if self._formulaSelectMC then
			self._formulaSelectMC.inSlot = false
			self._formulaSelectMC:setPosition(pos)
			self._formulaSelectMC:setScale(0.7)
			self._formulaSelectMC:setVisible(true)
		end
		self:loadFormulaInfo(self._formulaTabData[1])
	else
		if self._formulaSelectMC then
			self._formulaSelectMC:setVisible(false)
			self:loadFormulaInfo()
		end
	end
	
	
	local prePageBtn = self:getUI("bg.formulaLayer.rightBg.prePageBtn")
	local nextPageBtn = self:getUI("bg.formulaLayer.rightBg.nextPageBtn")
	prePageBtn:stopAllActions()
	prePageBtn:setOpacity(255)
	prePageBtn:setScale(1)
	nextPageBtn:stopAllActions()
	nextPageBtn:setOpacity(255)
	nextPageBtn:setScale(1)
	UIUtils:setGray(prePageBtn, false)
	prePageBtn:setTouchEnabled(true)
	UIUtils:setGray(nextPageBtn, false)
	nextPageBtn:setTouchEnabled(true)
	
	local scaleBy = cc.ScaleBy:create(0.7, 0.7)
	local anim = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(scaleBy, cc.FadeTo:create(0.7, 155)), cc.Spawn:create(scaleBy:reverse(), cc.FadeTo:create(0.7, 255))))
	if self._formulaMaxPage~=1 then
		if self._formulaPage==1 then
			UIUtils:setGray(prePageBtn, true)
			prePageBtn:setTouchEnabled(false)
			nextPageBtn:runAction(anim)
		elseif self._formulaPage==self._formulaMaxPage then
			UIUtils:setGray(nextPageBtn, true)
			nextPageBtn:setTouchEnabled(false)
			prePageBtn:runAction(anim)
		else
			prePageBtn:runAction(anim)
			nextPageBtn:runAction(anim:clone())
		end
	else
		UIUtils:setGray(prePageBtn, true)
		prePageBtn:setTouchEnabled(false)
		UIUtils:setGray(nextPageBtn, true)
		nextPageBtn:setTouchEnabled(false)
	end
	
	local pageLab = self:getUI("bg.formulaLayer.rightBg.pageLab")
	pageLab:setString(self._formulaPage .. "/" .. self._formulaMaxPage)
	
	local dragLab = self:getUI("bg.formulaLayer.rightBg.dragLab")
	dragLab:setVisible(true)
	
	local refreshTimes = self._alchemyModel:getRefreshTimes()
	local freeTimes = tab:Setting("G_ALCHEMYROOM_WEEKREFRESH_FREENUM").value
	local refreshTimesLab = self:getUI("bg.formulaLayer.rightBg.refreshTimesLab")
	local gemImg = self:getUI("bg.formulaLayer.rightBg.refreshGemImg")
	local gemLab = self:getUI("bg.formulaLayer.rightBg.refreshGemLab")
	if refreshTimes<freeTimes then
		gemImg:setVisible(false)
		gemLab:setVisible(false)
		refreshTimesLab:setString(string.format("剩余%d次", freeTimes-refreshTimes))
		refreshTimesLab:setVisible(true)
	else
		refreshTimesLab:setVisible(false)
		self:refreshGemCount()
		gemImg:setVisible(true)
		gemLab:setVisible(true)
	end
end

function MFAlchemyView:refreshGemCount()
	local refreshTimes = self._alchemyModel:getRefreshTimes()
	local freeTimes = tab:Setting("G_ALCHEMYROOM_WEEKREFRESH_FREENUM").value
	if refreshTimes>=freeTimes then
		local payIndex = refreshTimes-freeTimes+1
		local tbNeed = tab:Setting("G_ALCHEMYROOM_WEEKREFRESH_COST").value
		if payIndex>table.nums(tbNeed) then
			payIndex = table.nums(tbNeed)
		end
		local needCount = tbNeed[payIndex]
		local haveCount = self._modelMgr:getModel("UserModel"):getResNumByType("gem")
		local gemLab = self:getUI("bg.formulaLayer.rightBg.refreshGemLab")
		gemLab:setString(needCount)
		if haveCount<needCount then
			gemLab:setColor(cc.c3b(205, 32, 30))
		else
			gemLab:setColor(cc.c3b(28, 162, 22))
		end
	end
	
	local haveCoinNumLab = self:getUI("bg.warehouseLayer.leftNum")
	haveCoinNumLab:setString(self._modelMgr:getModel("UserModel"):getResNumByType("alchemy"))
end

--背包物品点击拖动
function MFAlchemyView:registerNodeEvent(item, formulaData)
	local touchX, touchY
	local tempNode
	self:registerTouchEvent(item,
		function( _,x,y )
			touchX,touchY = x,y
			tempNode = item:clone()
			local posStart = item:getParent():convertToWorldSpace(cc.p(item:getPosition()))
			tempNode:setPosition(posStart)
			self:addChild(tempNode, 99)
			self:loadFormulaInfo(formulaData)
			IconUtils:updateAlchemyIcon(item)
			if self._formulaSelectMC then
				self._formulaSelectMC:setScale(0.7)
				self._formulaSelectMC.inSlot = false
				self._formulaSelectMC:setPosition(posStart)
			end
		end,
		function( _,x,y )--touchMove
			local touchPoint = item:convertToNodeSpace(cc.p(x, y))
			touchX = x
			touchY = y
			tempNode:setPosition(cc.p(x, y))
		end,
		function( )--touchEnd
			tempNode:removeFromParent(true)
			tempNode = nil
			IconUtils:updateAlchemyIcon(item, formulaData)
		end,
		function(  )--touchCancel
			if self._nowProduceNum<self._nowUnlock+1 then
				local isReaffirm = false
				for i=1, self._nowUnlock do
					local node = self:getUI("bg.downBg.downPanel.itemBg"..i)
					local pos = node:getParent():convertToWorldSpace(cc.p(node:getPosition()))
					local nodeSize = node:getContentSize()
					local dis = MathUtils.pointDistance(cc.p(pos.x+nodeSize.width/2, pos.y+nodeSize.height/2), cc.p(touchX, touchY))
					if dis<=node:getContentSize().width/2 then
						local preProData = self._alchemyModel:getPreProData()
						if table.nums(preProData)>=self._nowUnlock then
							self._viewMgr:showTip("当前生产队列已满，无法继续生产")
							break
						end
						--判断所需材料
						local isCostFull
						local isRandomCost = table.nums(formulaData.costRandomMaterial)~=0
						--固定材料
						local haveCount = 0
						isCostFull = true
						for i,v in ipairs(formulaData.costMaterial) do
							if v[1]~="tool" then
								haveCount = self._modelMgr:getModel("UserModel"):getResNumByType( v[1] )
							else
								local _, toolCount = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
								haveCount = toolCount
							end
							if haveCount<v[3] then
								isCostFull = false
								break
							end
						end
						if isRandomCost and isCostFull then--随机材料
							local haveCount = 0
							for i,v in ipairs(formulaData.costRandomMaterial[1]) do
								if v[1]~="tool" then
									haveCount = haveCount + self._modelMgr:getModel("UserModel"):getResNumByType( v[1] )
								else
									local _, toolCount = self._modelMgr:getModel("ItemModel"):getItemsById(v[2])
									haveCount = haveCount + toolCount
								end
							end
							if haveCount<formulaData.costRandomMaterial[2] then
								isCostFull = false
							end
						end
						if isCostFull then
							local proTimes = self._alchemyModel:getFormulaProductTimes(formulaData.id)
							local lifeUseTimes = self._alchemyModel:getFormulaLifeUseTimes(formulaData.id)
							if formulaData.lifeMakeLimit>0 and lifeUseTimes>=formulaData.lifeMakeLimit then
								self._viewMgr:showTip("该配方生产次数已超过生涯上线，何不尝试一下其他配方呢")
							elseif proTimes<formulaData.dayMakeLimt then
								isReaffirm = true
								local produceCallback = function()
									self:produceFormula(formulaData, tempNode)
								end
								local cancelCallback = function()
									tempNode:removeFromParent(true)
									tempNode = nil
									IconUtils:updateAlchemyIcon(item, formulaData)
								end
								if isRandomCost then
									if OS_IS_WINDOWS then
										UIUtils:reloadLuaFile("MF.MFAlchemyAddResDialog")
									end
									self._viewMgr:showDialog("MF.MFAlchemyAddResDialog", {formulaId = formulaData.id, addCallback = function(materialData)
										local tempData = {}
										for i,v in pairs(materialData) do
											tempData[tostring(i)] = v
										end
										self._serverMgr:sendMsg("AlchemyServer", "produce", {aid = formulaData.id, gid = formulaData.gridId, tids = tempData}, true, {}, function(result)
											produceCallback()
										end, function()
											self._viewMgr:showTip("状态错误，无法生产")
											cancelCallback()
										end)
									end, closeCallback = function()
										cancelCallback()
									end})
								else
									self._serverMgr:sendMsg("AlchemyServer", "produce", {aid = formulaData.id, gid = formulaData.gridId}, true, {}, function(result)
										produceCallback()
									end,function()
										cancelCallback()
									end)
									isReaffirm = true
								end
							else
								self._viewMgr:showTip("已达到今日最大生产次数，无法再次生产")
							end
						else
							self._viewMgr:showTip("材料不足，无法生产")
						end
						break
					end
				end
				if not isReaffirm then
					tempNode:removeFromParent(true)
					tempNode = nil
					IconUtils:updateAlchemyIcon(item, formulaData)
				end
			else
				self._viewMgr:showTip("当前生产队列已满，无法继续生产")
				tempNode:removeFromParent(true)
				tempNode = nil
				IconUtils:updateAlchemyIcon(item, formulaData)
			end
		end,
		function( )
--			长按
		end
	)
end


--生产栏物品点击拖动
function MFAlchemyView:registerSlotNodeEvent(item, formulaData, location)
	local touchX, touchY
	local tempNode
	self:registerTouchEvent(item,
		function( _,x,y )
			touchX,touchY = x,y
			tempNode = item:clone()
			
			local posStart = item:getParent():convertToWorldSpace(cc.p(item:getPosition()))
			posStart.x = posStart.x + tempNode:getContentSize().width/2*tempNode:getScale()
			posStart.y = posStart.y + tempNode:getContentSize().height/2*tempNode:getScale()
			tempNode:setAnchorPoint(0.5, 0.5)
			tempNode:setPosition(posStart)
			self:addChild(tempNode, 99)
			self:loadFormulaInfo(formulaData)
			if self._formulaSelectMC then
				self._formulaSelectMC.inSlot = true
				self._formulaSelectMC:setScale(0.8)
				self._formulaSelectMC:setVisible(true)
				self._formulaSelectMC:setPosition(posStart)
			end
		end,
		function( _,x,y )--touchMove
			local touchPoint = item:convertToNodeSpace(cc.p(x, y))
			touchX = x
			touchY = y
			tempNode:setPosition(cc.p(x, y))
		end,
		function( )--touchEnd
			tempNode:removeFromParent(true)
			tempNode = nil
		end,
		function(  )--touchCancel
			local preProNum = self._alchemyModel:getNowPreProCount()
			for i=1, preProNum do
				local node = self:getUI("bg.downBg.downPanel.itemBg"..i)
				local pos = node:getParent():convertToWorldSpace(cc.p(node:getPosition()))
				local nodeSize = node:getContentSize()
				nodeSize.width = nodeSize.width * node:getScale()
				nodeSize.height = nodeSize.height * node:getScale()
				local dis = MathUtils.pointDistance(cc.p(pos.x+nodeSize.width/2, pos.y+nodeSize.height/2), cc.p(touchX, touchY))
				if dis<=node:getContentSize().width/2*node:getScale() and i~=location then
					self._serverMgr:sendMsg("AlchemyServer", "change", {cidx = i, tidx = location}, true, {}, function(result)
						self:changeLocationAnim(i, location)
					end)
					break
				end
			end
			tempNode:removeFromParent(true)
			tempNode = nil
		end,
		function( )
--			长按
		end
	)
end

function MFAlchemyView:changeLocationAnim(index1, index2)--index1是被交换的，index2是主动交换（被拖动的）
	local formulaId1 = self._alchemyModel:getProFormulaIdByIndex(index1)
	local formulaId2 = self._alchemyModel:getProFormulaIdByIndex(index2)
	local item1 = self:getUI("bg.downBg.downPanel.itemBg"..index1)
	local item2 = self:getUI("bg.downBg.downPanel.itemBg"..index2)
	local pos1 = cc.p(item1:getPosition())
	local pos2 = cc.p(item2:getPosition())
	self._viewMgr:lock(-1)
	self._formulaSelectMC:setVisible(false)
	item1:runAction(cc.MoveTo:create(0.5, pos2))
	item2:runAction(cc.Sequence:create(
		cc.MoveTo:create(0.5, pos1),
		cc.CallFunc:create(function()
			local needPos = item2:getParent():convertToWorldSpace(cc.p(item2:getPosition()))
			needPos.x = needPos.x + item2:getContentSize().width/2*item2:getScale()
			needPos.y = needPos.y + item2:getContentSize().height/2*item2:getScale()
			self._formulaSelectMC:setPosition(needPos)
			self._formulaSelectMC:setVisible(true)
			
			item2:setPosition(pos2)
			
			item1:setPosition(pos1)
			self:initProductSlot()
			
			self._viewMgr:unlock()
		end)
	))
end

function MFAlchemyView:produceFormula(formulaData, node)
	self._viewMgr:lock(-1)
	local index = 1
	local id = formulaData.id
	local targetNode = self:getUI("bg.downBg.downPanel.itemBg1")
	local targetPos
	local preProNum = self._alchemyModel:getNowPreProCount()
	if preProNum>0 then
		local itemIndex = preProNum
		targetNode = self:getUI("bg.downBg.downPanel.itemBg"..itemIndex)
	end
	targetPos = targetNode:getParent():convertToWorldSpace(cc.p(targetNode:getPosition()))
	targetPos.x = targetPos.x + targetNode:getContentSize().width/2*targetNode:getScaleX()
	targetPos.y = targetPos.y + targetNode:getContentSize().height/2*targetNode:getScaleY()
	local icon = targetNode:getChildByName("image_addition")
	local tagIcon = targetNode:getChildByName("tagIcon")
	local frameIcon = targetNode:getChildByName("formation_bg")
	local action = cc.Sequence:create(
		cc.MoveTo:create(0.1, targetPos),
		cc.CallFunc:create(function()
			node:setVisible(false)
			icon:loadTexture(formulaData.icon, 1)
			frameIcon:loadTexture("globalImageUI4_squality"..formulaData.planQuality..".png", 1)
			tagIcon:loadTexture("alchemy_quality"..formulaData.planQuality..".png", 1)
			tagIcon:setVisible(true)
			if self._isNowProduce or table.nums(self._alchemyModel:getLibData())>=tab:Setting("G_ALCHEMYROOM_MAXSTORAGE_NUM").value then
				node:removeFromParent()
				node = nil
				self._viewMgr:unlock()
				self:initProductSlot()
				self._formulaTabData, self._formulaMaxPage = self._alchemyModel:getFormulaTableData(1)
				self:loadFormulaBagData()
				self._formulaSelectMC:setPosition(targetPos)
				self._formulaSelectMC:setScale(0.8)
				self._formulaSelectMC.inSlot = true
				self._formulaSelectMC:setVisible(true)
				self:loadFormulaInfo(formulaData)
			end
		end)
	)
	if not self._isNowProduce and table.nums(self._alchemyModel:getLibData())<tab:Setting("G_ALCHEMYROOM_MAXSTORAGE_NUM").value then
		local produceBg = self:getUI("bg.downBg.downPanel.productBg")
		local producePos = produceBg:convertToWorldSpace(cc.p(produceBg:getChildByName("image_addition"):getPosition()))
		action = cc.Sequence:create(
			action,
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function()
				node:setVisible(true)
				icon:loadTexture("globalImageUI4_addition.png", 1)
				frameIcon:loadTexture("globalImageUI4_squality1.png", 1)
				tagIcon:setVisible(false)
			end),
			cc.ScaleTo:create(0.1, produceBg:getChildByName("formation_bg"):getContentSize().width/node:getContentSize().width),
			cc.MoveTo:create(0.1, producePos),
			cc.CallFunc:create(function()
				node:removeFromParent()
				node = nil
				self._viewMgr:unlock()
				self:initProductSlot()
				self._formulaTabData, self._formulaMaxPage = self._alchemyModel:getFormulaTableData(1)
				self:loadFormulaBagData()
				self._formulaSelectMC:setPosition(producePos)
				self._formulaSelectMC:setScale(0.85)
				self._formulaSelectMC.inSlot = true
				self._formulaSelectMC:setVisible(true)
				self:loadFormulaInfo(formulaData)
			end)
		)
	end
	node:runAction(action)
end

--生产栏位
function MFAlchemyView:initProductSlot()
	local userModel = self._modelMgr:getModel("UserModel")
	local slotBg = self:getUI("bg.downBg.downPanel")
	local proClickBg = slotBg:getChildByFullName("productBg.formation_bg")
	proClickBg:setTouchEnabled(false)
	--正在生产的
	slotBg:getChildByFullName("productBg.tagIcon"):setVisible(false)
	slotBg:getChildByFullName("productBg.speedBtn"):setVisible(false)
	slotBg:getChildByFullName("productBg.speedLab"):setVisible(false)
	local nowProFormulaId, startProTime = self._alchemyModel:getNowProFormulaId()
	if nowProFormulaId and nowProFormulaId~=0 then
		self._slotEffect:setVisible(true)
		local nowTime = userModel:getCurServerTime()
		local formulaData = tab.alchemyPlan[nowProFormulaId]
		local nowProBg = slotBg:getChildByName("productBg")
		local icon = nowProBg:getChildByName("image_addition")
		icon:loadTexture(formulaData.icon, 1)
		icon:setVisible(true)
		local frameIcon = nowProBg:getChildByName("formation_bg")
		frameIcon:loadTexture("globalImageUI4_squality"..formulaData.planQuality..".png", 1)
		local speedBtn = nowProBg:getChildByName("speedBtn")
		speedBtn:setVisible(formulaData.planFastMakeFactor>0)
		nowProBg:getChildByName("speedLab"):setVisible(formulaData.planFastMakeFactor>0)
		self:registerClickEvent(speedBtn, function()
			local speedTimes = self._alchemyModel:getFormulaSpeedUpTimes(formulaData.id)
			if speedTimes>=formulaData.dayFastMakeLimt then
				self._viewMgr:showTip("该配方加速次数已超过限制，不可加速")
				return
			end
			local tempNowTime = userModel:getCurServerTime()
			local tempSurplusMin = startProTime+formulaData.costTime - nowTime
			tempSurplusMin = tempSurplusMin/60
			local needCost = math.ceil(tempSurplusMin*formulaData.planFastMakeFactor)
			
			DialogUtils.showBuyDialog({costNum = needCost,costType = "gem",goods = "加速生产",callback1 = function( )
				local haveGem = userModel:getResNumByType("gem")
				if needCost>haveGem then
					local costName = lang("TOOL_" .. IconUtils.iconIdMap.gem)
					DialogUtils.showNeedCharge({desc = costName .. "不足，请前往充值",callback1=function( )
						local viewMgr = ViewManager:getInstance()
						viewMgr:showView("vip.VipView", {viewType = 0})
					end})
				else
					self._serverMgr:sendMsg("AlchemyServer", "speedup", {}, true, {}, function(result)
						self._nowProduceNum = self._nowProduceNum - 1
						self:changeSlotPosAnim()
						nowProBg:getChildByFullName("countDownLabBg.countDownLab"):stopAllActions()
						if self._tabState==1 then
							self:loadWarehouseData()
						end
					end)
				end
			end})
		end)
		local tagIcon = nowProBg:getChildByName("tagIcon")
		tagIcon:loadTexture("alchemy_quality"..formulaData.planQuality..".png", 1)
		tagIcon:setVisible(true)
		nowProBg:getChildByName("countDownLabBg"):setVisible(true)
		local countDownLab = nowProBg:getChildByFullName("countDownLabBg.countDownLab")
		countDownLab:stopAllActions()
		countDownLab:setString("剩余:"..TimeUtils.getTimeStringFont(startProTime+formulaData.costTime - nowTime))
		countDownLab:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
				cc.DelayTime:create(1),
				cc.CallFunc:create(function()
					nowTime = userModel:getCurServerTime()
					local surplusTime = startProTime+formulaData.costTime - nowTime
					if surplusTime>=-1 then
						countDownLab:setString("剩余:"..TimeUtils.getTimeStringFont(surplusTime>=0 and surplusTime or 0))
					else
						self._serverMgr:sendMsg("AlchemyServer", "getInfo", {}, true, {}, function(result)
							self._nowProduceNum = self._nowProduceNum - 1
							self:changeSlotPosAnim()
							if self._tabState==1 then
								self:loadWarehouseData()
							end
							countDownLab:stopAllActions()
						end)
					end
				end)
		)))
		self._nowProduceNum = 1 + table.nums(self._alchemyModel:getPreProData())
		self:registerClickEvent(proClickBg, function()
			if self._formulaSelectMC then
				self._formulaSelectMC.inSlot = true
				self._formulaSelectMC:setScale(0.85)
				self._formulaSelectMC:setPosition(cc.p(nowProBg:convertToWorldSpace(cc.p(frameIcon:getPosition()))))
				self._formulaSelectMC:setVisible(true)
			end
			self:loadFormulaInfo(formulaData)
		end)
		self._isNowProduce = true
	else
		self._slotEffect:setVisible(false)
		self._isNowProduce = false
		slotBg:getChildByFullName("productBg.image_addition"):setVisible(false)
		slotBg:getChildByFullName("productBg.formation_bg"):loadTexture("globalImageUI4_squality1.png", 1)
		slotBg:getChildByFullName("productBg.countDownLabBg"):setVisible(false)
	end
	
	--待产
	local defaultUnlockSlot = tab:Setting("G_ALCHEMYROOM_PREPARE_NUM").value
	self._nowUnlock = defaultUnlockSlot + self._alchemyModel:getUnlockNum()
	for i=1, 8 do
		local item = slotBg:getChildByName("itemBg"..i)
		item:setPosition(l_profuctSlotPos[i])
		local frameIcon = item:getChildByName("formation_bg")
		local bgIcon = item:getChildByName("none")
		local icon = item:getChildByName("image_addition")
		local tagIcon = item:getChildByName("tagIcon")
		if i>self._nowUnlock then
			frameIcon:loadTexture("globalImageUI4_squality1.png", 1)
			frameIcon:setBrightness(-50)
			bgIcon:setVisible(false)
			icon:loadTexture("globalImageUI5_treasureLock.png", 1)
			tagIcon:setVisible(false)
			self:registerClickEvent(frameIcon, function()
				if i==self._nowUnlock+1 then
					DialogUtils.showBuyDialog({costNum = tab:Setting("G_ALCHEMYROOM_PREPARE_UNLOCKNUM").value,costType = "alchemy",goods = "解锁当前栏位",callback1 = function( )
						local num = userModel:getResNumByType("alchemy")
						if num>=tab:Setting("G_ALCHEMYROOM_PREPARE_UNLOCKNUM").value then
							self._serverMgr:sendMsg("AlchemyServer", "unlock", {}, true, {}, function(result)
								self:initProductSlot()
							end)
						else
							self._viewMgr:showTip(lang("alchemy_tips_1"))
						end
					end})
				else
					self._viewMgr:showTip("请先解锁前一栏位")
				end
			end)
		else
			local preProData = self._alchemyModel:getPreProData()
			local locationId = preProData[tostring(i)]
			if locationId then
				local formulaData = tab.alchemyPlan[locationId]
				frameIcon:loadTexture("globalImageUI4_squality"..formulaData.planQuality..".png", 1)
				icon:loadTexture(formulaData.icon, 1)
				tagIcon:loadTexture("alchemy_quality"..formulaData.planQuality..".png", 1)
				tagIcon:setVisible(true)
				self:registerSlotNodeEvent(item, formulaData, i)
			else
				frameIcon:loadTexture("globalImageUI4_squality1.png", 1)
				icon:loadTexture("globalImageUI4_addition.png", 1)
				tagIcon:setVisible(false)
				frameIcon:setTouchEnabled(false)
				item:setTouchEnabled(false)
				--[[self:registerClickEvent(item, function()
					if OS_IS_WINDOWS then
						UIUtils:reloadLuaFile("MF.MFAlchemyQuickAddDialog")
					end
					self._viewMgr:showDialog("MF.MFAlchemyQuickAddDialog", {index = i, unlockSlot = self._nowUnlock})
				end)--]]
			end
			bgIcon:setVisible(true)
			frameIcon:setBrightness(0)
		end
	end
end

function MFAlchemyView:changeSlotPosAnim()
	self._viewMgr:lock(-1)
	if self._nowProduceNum>0 then
		for i=1, self._nowProduceNum do
			local item = self:getUI("bg.downBg.downPanel.itemBg"..i)
			local action
			if i==1 then
				local produceBg = self:getUI("bg.downBg.downPanel.productBg")
				local producePos = produceBg:convertToWorldSpace(cc.p(produceBg:getChildByName("image_addition"):getPosition()))
				producePos = item:getParent():convertToNodeSpace(producePos)
				producePos.x = producePos.x - item:getContentSize().width/2*item:getScale()
				producePos.y = producePos.y - item:getContentSize().height/2*item:getScale()
				local frameIcon = produceBg:getChildByName("formation_bg")
				action = cc.MoveTo:create(0.1, producePos)
			else
				local nextIndex = i-1
				local targetNode = self:getUI("bg.downBg.downPanel.itemBg"..nextIndex)
				local targetPos = cc.p(targetNode:getPosition())
				action = cc.MoveTo:create(0.1, targetPos)
			end
			if i==self._nowProduceNum then
				action = cc.Sequence:create(action,
					cc.CallFunc:create(function()
						self._serverMgr:sendMsg("AlchemyServer", "getInfo", {}, true, {}, function()
							self:initProductSlot()
							if self._formulaSelectMC.inSlot then
								local bagPanel = self:getUI("bg.formulaLayer.rightBg.tableBg")
								local firstNode = bagPanel:getChildByName("alchemyNode11")
								if firstNode and firstNode:isVisible() and self._formulaTabData[1]~=nil and self._tabState==2 then
									local pos = cc.p(bagPanel:convertToWorldSpace(cc.p(firstNode:getPosition())))
									if self._formulaSelectMC then
										self._formulaSelectMC.inSlot = false
										self._formulaSelectMC:setPosition(pos)
										self._formulaSelectMC:setScale(0.7)
										self._formulaSelectMC:setVisible(true)
									end
									self:loadFormulaInfo(self._formulaTabData[1])
								else
									if self._formulaSelectMC then
										self:getUI("bg.formulaLayer.leftBg.scroll"):removeAllChildren()
										self:getUI("bg.formulaLayer.leftBg.formulaNameLab"):setString("")
										self._formulaSelectMC:setVisible(false)
									end
								end
							end
							self._viewMgr:unlock()
						end)
					end)
				)
			end
			item:runAction(action)
		end
	else
		self._serverMgr:sendMsg("AlchemyServer", "getInfo", {}, true, {}, function()
			self:initProductSlot()
			if self._formulaSelectMC.inSlot then
				local bagPanel = self:getUI("bg.formulaLayer.rightBg.tableBg")
				local firstNode = bagPanel:getChildByName("alchemyNode11")
				if firstNode and firstNode:isVisible() and self._formulaTabData[1]~=nil and self._tabState==2 then
					local pos = cc.p(bagPanel:convertToWorldSpace(cc.p(firstNode:getPosition())))
					if self._formulaSelectMC then
						self._formulaSelectMC.inSlot = false
						self._formulaSelectMC:setPosition(pos)
						self._formulaSelectMC:setScale(0.7)
						self._formulaSelectMC:setVisible(true)
					end
					self:loadFormulaInfo(self._formulaTabData[1])
				else
					if self._formulaSelectMC then
						self:getUI("bg.formulaLayer.leftBg.scroll"):removeAllChildren()
						self:getUI("bg.formulaLayer.leftBg.formulaNameLab"):setString("")
						self._formulaSelectMC:setVisible(false)
					end
				end
			end
			self._viewMgr:unlock()
		end)
	end
end

function MFAlchemyView:loadFormulaInfo(formulaData)
	local nameLab = self:getUI("bg.formulaLayer.leftBg.formulaNameLab")
	local scroll = self:getUI("bg.formulaLayer.leftBg.scroll")
	scroll:removeAllChildren()
	local nothing = self:getUI("bg.formulaLayer.leftBg.nothing")
	if not formulaData then
		nothing:setVisible(true)
		nameLab:setString("")
		return
	end
	nothing:setVisible(false)
	local nameStr = lang(formulaData.planName)
	if OS_IS_WINDOWS then
		nameStr = nameStr.."["..formulaData.id.."]"
	end
	nameLab:setString(nameStr)
	
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

function MFAlchemyView:refreshFormulaData()
	local refreshTimes = self._alchemyModel:getRefreshTimes()
	if refreshTimes>=tab:Setting("G_ALCHEMYROOM_MAXREFRESH_NUM").value then
		self._viewMgr:showTip("今日刷新次数已用尽")
		return
	end
	
	local freeTimes = tab:Setting("G_ALCHEMYROOM_WEEKREFRESH_FREENUM").value
	local refreshCallback = function()
		self._serverMgr:sendMsg("AlchemyServer", "refresh", {}, true, {}, function(result)
			self._formulaTabData, self._formulaMaxPage = self._alchemyModel:getFormulaTableData(1)
			self._refreshBag = true
			self:loadFormulaBagData()
		end)
	end
	if refreshTimes<freeTimes then
		self._viewMgr:showDialog("global.GlobalSelectDialog",
		{   desc = "是否免费刷新本日配方",
			button1 = "确定",
			button2 = "取消",
			callback1 = function ()
				refreshCallback()
			end,
		}, true)
	else
		local payIndex = refreshTimes-freeTimes+1
		local tbNeed = tab:Setting("G_ALCHEMYROOM_WEEKREFRESH_COST").value
		if payIndex>table.nums(tbNeed) then
			payIndex = table.nums(tbNeed)
		end
		local needCount = tbNeed[payIndex]
		local haveCount = self._modelMgr:getModel("UserModel"):getResNumByType("gem")
		if haveCount>=needCount then
			DialogUtils.showBuyDialog({costNum = needCount,costType = "gem",goods = "刷新一次",callback1 = function( )      
				refreshCallback()
			end})
		else
			local costName = lang("TOOL_" .. IconUtils.iconIdMap.gem)
			DialogUtils.showNeedCharge({desc = costName .. "不足，请前往充值",callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
			end})
		end
	end
end






function MFAlchemyView:loadWarehouseData()
	local haveCoinNumLab = self:getUI("bg.warehouseLayer.leftNum")
	haveCoinNumLab:setString(self._modelMgr:getModel("UserModel"):getResNumByType("alchemy"))
	
	local itemSizeWidth, nullNodeSizeWidth = 92, 68--IconUtils的createIcon里设置的size。
	local spaceWidth = 4
	local reportBtn = self:getUI("bg.warehouseLayer.reportBtn")
	self:registerClickEvent(reportBtn, function()
		self._serverMgr:sendMsg("AlchemyServer", "getReport", {}, true, {},  function(result)
			UIUtils:reloadLuaFile("MF.MFAlchemyLogDialog")
			self._viewMgr:showDialog("MF.MFAlchemyLogDialog")
		end)
	end)
	
	local tableData = self._alchemyModel:getLibData()
	
	local nodePanel = self:getUI("bg.warehouseLayer.nodePanel")
	local maxCount = tab:Setting("G_ALCHEMYROOM_MAXSTORAGE_NUM").value
	local posX = 0
	local posY = nodePanel:getContentSize().height
	for i=1, maxCount do
		local data = tableData[i]
		if i%3==1 then
			posY = posY - spaceWidth - itemSizeWidth
			posX = spaceWidth
		end
		local nullNode = nodePanel:getChildByName("nullNode"..i)
		if not nullNode then
			nullNode = IconUtils:createAlchemyIcon()
			nullNode:setScale(itemSizeWidth/nullNodeSizeWidth)--格子要相同大小
			nullNode:setAnchorPoint(0, 0)
			nullNode:setName("nullNode"..i)
			nullNode:setPosition(cc.p(posX, posY))
			nodePanel:addChild(nullNode)
		end
		
		local itemNode = nodePanel:getChildByName("itemNode"..i)
		if data~=nil then
			local param = {}
			if data[1] == "tool" then
				local itemData = tab.tool[data[2]]
				param = {itemId = itemData.id, itemData = itemData, num = data[3], eventStyle = 0, scale = 0.5}
			else
				local id = IconUtils.iconIdMap[data[1]]
				itemData = tab.tool[id]
				param = {itemId = id, eventStyle = 0, num = data[3], battleSoulType = data[2]}
			end
			
			if not itemNode then
				itemNode = IconUtils:createItemIconById(param)
				itemNode:setName("itemNode"..i)
				itemNode:setPosition(cc.p(posX, posY))
				nodePanel:addChild(itemNode)
			else
				IconUtils:updateItemIconByView(itemNode, param)
			end
			self:registerClickEvent(itemNode, function()
				self._serverMgr:sendMsg("AlchemyServer", "getTool", {gid = data.gridId}, true, {}, function(result)
					local reward = result.reward
					DialogUtils.showGiftGet({gifts = reward})
					self._serverMgr:sendMsg("AlchemyServer", "getInfo", {}, true, {}, function(result)
						self:loadWarehouseData()
						self:initProductSlot()
					end)
					
				end)
			end)
			itemNode:setVisible(true)
			nullNode:setVisible(false)
		else
			nullNode:setVisible(true)
			if itemNode then itemNode:setVisible(false) end
		end
		posX = posX + spaceWidth + itemSizeWidth + spaceWidth
	end
end

function MFAlchemyView:initEffect()
	--仓库layer
	--瓶子特效
	local bottleEffectLayer = self:getUI("bg.warehouseLayer.effectPanel")
	local bottleEffect = mcMgr:createViewMC("lianjinping_lianjingongfang2", true, false)
	bottleEffect:setName("bottleEffect")
	bottleEffectLayer:addChild(bottleEffect, 10)
	
	--生产槽位特效
	local produceSlotEffectPanel = self:getUI("bg.downBg.downPanel.productBg.effectPanel")
	local slotEffect = mcMgr:createViewMC("jiasu_lianjingongfang", true, false)
	slotEffect:setName("slotEffect")
	produceSlotEffectPanel:addChild(slotEffect, 10)
	produceSlotEffectPanel:setVisible(false)
	self._slotEffect = produceSlotEffectPanel
end

function MFAlchemyView:setNavigation()
	local callback = function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("MF.MFAlchemyView")
		end
		if self._callback then
			self._callback()
		end
	end
	self._viewMgr:showNavigation("global.UserInfoView",{types = {"", "", "alchemy",},titleTxt = "炼金工坊", callback = callback}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
end

function MFAlchemyView:getAsyncRes()
	return 
		{
			{"asset/ui/alchemy.plist", "asset/ui/alchemy.png"},
			{"asset/ui/alchemy1.plist", "asset/ui/alchemy1.png"},
		}
end

function MFAlchemyView:getBgName()
	return "bg_alchemy.jpg"
end

function MFAlchemyView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end

function MFAlchemyView:onTop()
    self._viewMgr:enableScreenWidthBar()
end

function MFAlchemyView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end

function MFAlchemyView:onDestroy( )
    self._viewMgr:disableScreenWidthBar()
    MFAlchemyView.super.onDestroy(self)
end

return MFAlchemyView