--[[
    Filename:    TeamHolyGradeDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-16 17:45:13
    Description: File description
--]]

-- 升级
local TeamHolyGradeDialog = class("TeamHolyGradeDialog", BasePopView)

function TeamHolyGradeDialog:ctor(data)
    TeamHolyGradeDialog.super.ctor(self)
--	self._holyKey = data.key
	self._teamModel = self._modelMgr:getModel("TeamModel") 
	self._holyData = self._teamModel:getHolyDataByKey(data.key)
	self._selectData = {}
	self._teamId = data.teamId
	self._gradeUseTool = nil
	self._hasGrade = false
	self._callback = data.callback
	self._isGradeToolEnough = false
	self._isMoreThanMaxExp = false--选择铸造材料时的是否超过最大经验值的字段，bool
	self:listenReflash("ItemModel", self.updateUseToolData)
end

function TeamHolyGradeDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		if self._callback and self._hasGrade then
			self._callback()
		end
		self:close()
	end)
	if self._teamId then
		self._curTeam = self._teamModel:getTeamAndIndexById(self._teamId)
	end
	
	local runeTab = tab.rune[self._holyData.id]
	local holyIcon = self:getUI("bg.leftPanel.iconBg.icon")
	holyIcon:loadTexture(runeTab.art..".png", 1)
	local nameLab = self:getUI("bg.leftPanel.nameBg.nameLab")
	nameLab:setString(lang(runeTab.name))
	
	local gradeCastRuneId = runeTab.castData[1]
	self._gradeUseTool = tab.rune[gradeCastRuneId].castTool
	
	local ruleBtn = self:getUI("bg.leftPanel.infoBtn")
	self:registerClickEvent(ruleBtn, function()
		self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("rune_casting_rule")},true)
	end)
	
	self._tableData = self._teamModel:getGradeBagData(self._holyData)
	local noSrcRoot = self:getUI("bg.noSrcRoot")
	if table.nums(self._tableData)>0 then
		self:addTableView()
		noSrcRoot:setVisible(false)
	else
		noSrcRoot:setVisible(true)
	end
	
	
	local attrBg = self:getUI("bg.leftPanel.attrBg.levelPanel")
	for _,v in pairs(attrBg:getChildren()) do
--		for __, node in pairs(v:getChildren()) do
			if v:getDescription() == "Label" then
				v:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
			end
--		end
	end
	
	self:setAttrData()
	local gradeBtn = self:getUI("bg.leftPanel.gradeBtn")
	self:registerClickEvent(gradeBtn, function()
		if self._isGradeToolEnough then
			self:onGradeStone()
		else
			--[[local param = {}
			self._viewMgr:showTip(lang("RUNE_10005"))--]]
			local param = {indexId = 19}
			self._viewMgr:showDialog("global.GlobalPromptDialog", param)
		end
	end)
	self:setAfterGradeAttr()
	self:updateUseToolData()
end

function TeamHolyGradeDialog:addTableView()
	local tableViewBg = self:getUI("bg.tableViewBg")
	local height = tableViewBg:getContentSize().height
	self._bagTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, height))
	self._bagTableView:setDelegate()
	self._bagTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self._bagTableView:setPosition(0, 0)
    self._bagTableView:registerScriptHandler(function(table) return self:scrollViewDidScroll(table) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
	self._bagTableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
	self._bagTableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
	self._bagTableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._bagTableView:setBounceable(true)
	self._bagTableView:reloadData()
	if self._bagTableView.setDragSlideable ~= nil then 
		self._bagTableView:setDragSlideable(true)
	end
	tableViewBg:addChild(self._bagTableView)
end

function TeamHolyGradeDialog:scrollViewDidScroll(inView)
    self._inScrolling = inView:isDragging()
end

function TeamHolyGradeDialog:numberOfCellsInTableView(inView)
	local num = math.ceil(table.nums(self._tableData)/4)<6 and 6 or math.ceil(table.nums(self._tableData)/4)
	return num
end

function TeamHolyGradeDialog:cellSizeForTable(inView, idx)
	return 83, 335
end

function TeamHolyGradeDialog:tableCellAtIndex(inView, idx)
	local cell = inView:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
	cell:removeAllChildren()
	for i=1, 4 do
		local function itemCallback( holyItemData, stoneData, itemNode)
			if not self._inScrolling then
				self:touchGradeItemEnd(holyItemData, stoneData, itemNode)
			else
				self._inScrolling = false
			end
		end
		local index = idx*4+i
		local stoneData = self._tableData[index]
		local param = stoneData and {suitData = tab.rune[stoneData.id], stoneData = stoneData, eventStyle = 3, callback = itemCallback} or nil
		local node = cell:getChildByName("cellNode"..i)
		if not node then
			node = IconUtils:createHolyBagIcon(param)
			node:setPosition(cc.p((i-1)*node:getContentSize().width + i*5, 1))
			node:setName("cellNode"..i)
			if stoneData then
				local selectImg = node:getChildByName("selectImg")
				if not selectImg then
					selectImg = ccui.ImageView:create()
					selectImg:setName("selectImg")
					selectImg:loadTexture("globalImageUI7_checkbox_p.png", 1)
					selectImg:setScale(0.8)
					selectImg:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
					node:addChild(selectImg)
				end
				selectImg:setVisible(self._selectData[stoneData.key]~=nil)
				
			end
			
			cell:addChild(node)
		else
			IconUtils:updateHolyBagIcon(node, param)
		end
		
	end
	return cell
end

function TeamHolyGradeDialog:setAttrData()
	--差满级的显示
	local holyData = self._holyData
	local tabGrade = tab.runeDisintegration[holyData.quality]
	
	local loadingBar = self:getUI("bg.leftPanel.attrBg.progressBg.loadingBar")
	local underBar = self:getUI("bg.leftPanel.attrBg.progressBg.underBar")
	underBar:setPercent(0)
	local percentLab = self:getUI("bg.leftPanel.attrBg.progressBg.percentLab")
	percentLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	if holyData.lv-1==table.nums(tabGrade.castingExp) then
		--满级时
		loadingBar:setPercent(100)
		percentLab:setString("MAX")
	end
		local attrBg = self:getUI("bg.leftPanel.attrBg")
		local curLevelLab = attrBg:getChildByFullName("levelPanel.curLevelLab")
		curLevelLab:setString(holyData.lv-1)
		--左侧数据
--		local holyBaseAttr, holyAddAttr = self._teamModel:getBagStoneAttr(holyData)

		local holyAttr = {}
--		local addAttr = {}
		
		local baseNum = tab:Setting("GEM_BASISATT_NUM").value
		for i,v in ipairs(holyData.p) do
			table.insert(holyAttr, {id = v[1], value = v[2]})
		end
		
		--[[for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
			if holyBaseAttr[n].value ~= 0 then
				table.insert(holyAttr, {id = n, index = holyBaseAttr[n].index, value = holyBaseAttr[n].value})--UIUtils:getAttrValueStr(n, holyBaseAttr[n])})
			end
			if holyAddAttr[n].value ~= 0 then
				table.insert(addAttr, {id = n, index = holyAddAttr[n].index, value = holyAddAttr[n].value})--UIUtils:getAttrValueStr(n, holyAddAttr[n])})
			end
		end
		
		for i,v in ipairs(addAttr) do
			table.insert(holyAttr, v)
		end
		table.sort(holyAttr, function(a, b)
			return a.index<b.index
		end)--]]
		for i=1, 6 do
			local panel = attrBg:getChildByName("attrPanel"..i)
			panel:setVisible(holyAttr[i]~=nil)
			if holyAttr[i] then
				local nameLab = panel:getChildByName("nameLab")
				local curValueLab = panel:getChildByName("curValueLab")
				nameLab:setString(lang("ATTR_"..holyAttr[i].id))
				curValueLab:setString(UIUtils:getAttrValueStr(holyAttr[i].id, holyAttr[i].value))
			end
		end
		self._holyAttr = holyAttr
--	end
end

function TeamHolyGradeDialog:touchGradeItemEnd(holyData, stoneData, node)--点击宝石弹提示
	if holyData then
		local selectImg = node:getChildByName("selectImg")
		if selectImg:isVisible() then
			selectImg:setVisible(false)
			self._selectData[stoneData.key] = nil
		elseif self:calcCanAdd() then
			selectImg:setVisible(true)
			self._selectData[stoneData.key] = stoneData
		end
		self._viewMgr:showHintView("team.TeamHolyTipView",{hintType = 5, key = stoneData.key, holyData = holyData, node = node})
		self:setAfterGradeAttr()
		self:updateUseToolData()
	end
end

function TeamHolyGradeDialog:setAfterGradeAttr()
	local attrBg = self:getUI("bg.leftPanel.attrBg")
	local nextLevelLab = attrBg:getChildByFullName("levelPanel.nextLevelLab")
	
	local holyData = self._holyData
	local tabGrade = tab.runeDisintegration[holyData.quality]
	local gradeBtn = self:getUI("bg.leftPanel.gradeBtn")
	if table.nums(tabGrade.castingExp)==holyData.lv-1 then--满级时
		attrBg:getChildByFullName("levelPanel.arrow"):setVisible(false)
		nextLevelLab:setVisible(false)
		for i,v in ipairs(self._holyAttr) do
			local panel = attrBg:getChildByName("attrPanel"..i)
			if v then
				panel:getChildByName("arrow"):setVisible(false)
				panel:getChildByName("nextValueLab"):setVisible(false)
			end
		end
		gradeBtn:setEnabled(false)
		gradeBtn:setSaturation(-100)
		return
	end
	
	local nowLevel = holyData.lv-1
	local haveExp = 0
	for i,v in ipairs(tabGrade.castingExp) do
		if i<=nowLevel then
			haveExp = haveExp + v
		else
			break
		end
	end
	
	haveExp = haveExp + holyData.e
	local allSelectExp = 0
	local loadingBar = self:getUI("bg.leftPanel.attrBg.progressBg.loadingBar")
	local underBar = self:getUI("bg.leftPanel.attrBg.progressBg.underBar")
	local percentLab = self:getUI("bg.leftPanel.attrBg.progressBg.percentLab")
	if table.nums(self._selectData)>0 then
		for i,v in pairs(self._selectData) do
			local tabRune = tab.rune[v.id]
			local tabTempGrade = tab.runeDisintegration[v.quality]
			local tempAddExp = v.e
			if v.lv~=1 then
				for lvl,exp in ipairs(tabTempGrade.castingExp) do
					if lvl<v.lv then
						tempAddExp = tempAddExp + exp
					else
						break
					end
				end
			end
			allSelectExp = allSelectExp + tabRune.castExp + tempAddExp
		end
		local nextData = self:getNextLevelAndAttr(nowLevel, haveExp, allSelectExp)
		local percent = nextData.percentData.nowExp/nextData.percentData.needExp*100
		loadingBar:setPercent(percent)
		if nextData.level==tabGrade.castingCap and percent==100 then
			percentLab:setString("Lv.MAX")
		else
			percentLab:setString(nextData.percentData.nowExp.."/"..nextData.percentData.needExp)
		end
		for i,v in ipairs(nextData.attrData) do
			local panel = attrBg:getChildByName("attrPanel"..i)
			if v then
				local nextValueLab = panel:getChildByName("nextValueLab")
				nextValueLab:setString(UIUtils:getAttrValueStr(v.id, v.value))
			end
		end
		nextLevelLab:setString(nextData.level)
		if nextData.level~=nowLevel then
			underBar:setPercent(100)
		end
		gradeBtn:setEnabled(true)
		gradeBtn:setSaturation(0)
	else
		local nextLvl = holyData.lv+1-1
		local nextLvlTab = tab.runeCasting[nextLvl]--需要做迭代计算nextLvl和加成
		local nextData = self:getNextLevelAndAttr(nowLevel, haveExp, allSelectExp)
		loadingBar:setPercent(nextData.percentData.nowExp/nextData.percentData.needExp*100)
		percentLab:setString(nextData.percentData.nowExp.."/"..nextData.percentData.needExp)
		local baseNum = tab:Setting("GEM_BASISATT_NUM").value
		for i,v in ipairs(self._holyAttr) do
			local panel = attrBg:getChildByName("attrPanel"..i)
			if v then
				local nextValueLab = panel:getChildByName("nextValueLab")
				local ratio
				if i>baseNum then
					ratio = nextLvlTab.CastingAtt2==0 and 0 or 1/nextLvlTab.CastingAtt2
				else
					ratio = nextLvlTab.CastingAtt==0 and 0 or 1/nextLvlTab.CastingAtt
				end
				local nextValue = v.value+v.value*ratio
				nextValue = tonumber(string.format("%.4f", nextValue))
				nextValueLab:setString(UIUtils:getAttrValueStr(v.id, nextValue))
			end
		end
		nextLevelLab:setString(nextLvl)
		underBar:setPercent(0)
		gradeBtn:setEnabled(false)
		gradeBtn:setSaturation(-100)
	end
end

function TeamHolyGradeDialog:getNextLevelAndAttr(nowLevel, haveExp, addExp)
	local backAttr = clone(self._holyAttr)
	local tabGrade = tab.runeDisintegration[self._holyData.quality]
	local nextExp = haveExp+addExp
	
	local nextData = {}
	local totalExp = 0
	self._isMoreThanMaxExp = false
	for i,v in ipairs(tabGrade.castingExp) do
		local tempExp = totalExp
		totalExp = totalExp+v
		if nextExp<totalExp then
			nextData.level = i-1
			nextData.percentData = {
				nowExp = nextExp - tempExp,
				needExp = v,
			}
			break
		elseif nextExp==totalExp then
			if i==table.nums(tabGrade.castingExp) then
				nextData.percentData = {
					nowExp = v,
					needExp = v,
				}
			else
				nextData.percentData = {
					nowExp = 0,
					needExp = tabGrade.castingExp[i+1]
				}
			end
			nextData.level = i
			break
		end
		if i==table.nums(tabGrade.castingExp) and nextExp>totalExp then
			nextData.level = i
			self._isMoreThanMaxExp = true
			nextData.percentData = {
				nowExp = v,
				needExp = v
			}
		end
	end
	local baseNum = tab:Setting("GEM_BASISATT_NUM").value
	for i=nowLevel+1, nextData.level do--迭代计算属性最终值
		local tabLevelAdd = tab.runeCasting[i]
		for attrIndex,attrData in ipairs(backAttr) do
			local ratio
			if attrIndex>baseNum then
				ratio = tabLevelAdd.CastingAtt2==0 and 0 or 1/tabLevelAdd.CastingAtt2
			else
				ratio = tabLevelAdd.CastingAtt==0 and 0 or 1/tabLevelAdd.CastingAtt
			end
			attrData.value = attrData.value + attrData.value * ratio
			attrData.value = tonumber(string.format("%.4f", attrData.value))
		end
	end
	nextData.attrData = backAttr
	
	return nextData
end

function TeamHolyGradeDialog:calcCanAdd()
	local nowLevel = self._holyData.lv-1
	local tabGrade = tab.runeDisintegration[self._holyData.quality]
	
	local haveExp = 0
	for i,v in ipairs(tabGrade.castingExp) do
		if i<=nowLevel then
			haveExp = haveExp + v
		else
			break
		end
	end
	haveExp = haveExp + self._holyData.e
	
	local maxExp = 0
	for i,v in ipairs(tabGrade.castingExp) do
		maxExp = maxExp + v
	end
	if tabGrade.castingCap>nowLevel then
		local allSelectExp = 0
		for i,v in pairs(self._selectData) do
			local tabRune = tab.rune[v.id]
			local tabTempGrade = tab.runeDisintegration[v.quality]
			local tempAddExp = v.e
			if v.lv~=1 then
				for lvl,exp in ipairs(tabTempGrade.castingExp) do
					if lvl<v.lv then
						tempAddExp = tempAddExp + exp
					else
						break
					end
				end
			end
			allSelectExp = allSelectExp + tabRune.castExp + tempAddExp
		end
		
		if allSelectExp+haveExp>=maxExp then
			self._viewMgr:showTip("已达最大经验上限")
			return false
		else
			return true
		end
	else
		self._viewMgr:showTip("当前已经升到最高级了")
		return false
	end
end

function TeamHolyGradeDialog:onGradeStone()
	local tbConsume = {}
	for i,v in pairs(self._selectData) do
		table.insert(tbConsume, v.key)
	end
	local function gradeStone()
		local oldPower = self._curTeam and self._curTeam.score
		local oldlv = self._teamModel:getHolyMasterLevel(self._teamId)
		local oldAttr = self._teamModel:getHolyMasterAttr(self._teamId)
		self._serverMgr:sendMsg("RunesServer", "upLvlRunes", {id=self._holyData.key, useIds=tbConsume}, true, {}, function(result)
			self:updateView()
			self:playGradeEffect(oldPower)
			self:playMasterUp(oldlv, oldAttr)
			self._hasGrade = true
		end)
	end
	if self._isMoreThanMaxExp then
		self._viewMgr:showSelectDialog( lang("RUNE_TIPS_2"), "", function( )
				gradeStone()
			end,
		"")
	else
		gradeStone()
	end
end

function TeamHolyGradeDialog:updateView()
	self._holyData = self._teamModel:getHolyDataByKey(self._holyData.key)
	self._selectData = {}
	self._tableData = self._teamModel:getGradeBagData(self._holyData)
	local noSrcRoot = self:getUI("bg.noSrcRoot")
	if table.nums(self._tableData)>0 then
		self._bagTableView:reloadData()
		noSrcRoot:setVisible(false)
	else
		self._bagTableView:removeFromParent()
		noSrcRoot:setVisible(true)
	end
	if self._teamId then
		self._curTeam = self._teamModel:getTeamAndIndexById(self._teamId)
	end
	
	self:setAttrData()
	self:setAfterGradeAttr()
	self:updateUseToolData()
end

function TeamHolyGradeDialog:updateUseToolData()
	local useCount = 0
	for i,v in pairs(self._selectData) do
		local runeData = tab.rune[v.id]
		if runeData.castTool~=self._gradeUseTool then
			error(string.format("config error!!!!self._holyId = %d!!!@lannan @wumaojiong", self._holyData.id))
		end
		useCount = useCount + runeData.castToolNum
	end
	local toolNodePanel = self:getUI("bg.leftPanel.toolNodeBg")
	local toolNode = toolNodePanel:getChildByName("toolNode")
	local itemData = tab:Tool(self._gradeUseTool)
	local _,haveCount = self._modelMgr:getModel("ItemModel"):getItemsById(self._gradeUseTool)
	if toolNode then
		IconUtils:updateItemIconByView(toolNode, {itemId = self._gradeUseTool, itemData = itemData})
	else
		toolNode = IconUtils:createItemIconById({itemId = self._gradeUseTool, itemData = itemData})
		toolNode:setScale(0.7)
		toolNode:setName("toolNode")
		toolNode:setAnchorPoint(0.5, 0.5)
		toolNode:setPosition(toolNodePanel:getContentSize().width/2, toolNodePanel:getContentSize().height/2)
		toolNodePanel:addChild(toolNode)
	end
	local numLab = self:getUI("bg.leftPanel.numLab")
	numLab:setString(string.format("%d/%d", haveCount, useCount))
	numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
--	numLab:setVisible(true)
	if haveCount>=useCount then
		numLab:setColor(UIUtils.colorTable.ccColorQuality1)
		self._isGradeToolEnough = true
	else
		numLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
		self._isGradeToolEnough = false
	end
end

function TeamHolyGradeDialog:playGradeEffect(oldPower)
	local holyIcon = self:getUI("bg.leftPanel.iconBg.icon")
	
	local effect = mcMgr:createViewMC("shenghuizhuzao_shenghuizhuzao", false, true)
	effect:setPosition(cc.p(holyIcon:getContentSize().width/2, holyIcon:getContentSize().height/2))
	holyIcon:addChild(effect)
	
	if self._curTeam then
		local nowPower = self._curTeam.score
		
		local fightBg = self:getUI("bg")
		TeamUtils:setFightAnim(self, {oldFight = oldPower, newFight = nowPower, x = MAX_SCREEN_WIDTH/2, y = MAX_SCREEN_HEIGHT - 150})
	end
end

function TeamHolyGradeDialog:playMasterUp(oldLv, oldAttr)
	local newLv = self._teamModel:getHolyMasterLevel(self._teamId)
	local newAttr = self._teamModel:getHolyMasterAttr(self._teamId)
	
	local function getMasterIndex(lv)
		local index = 0
		for i,v in ipairs(tab.runeCastingMastery) do
			if lv<v.level then
				if i~=1 then
					index = i-1
					break
				else
					break
				end
			elseif lv==v.level then
				index = i
				break
			elseif lv>v.level and i==table.nums(tab.runeCastingMastery) then
				index = i
				break
			end
		end
		return index
	end
	local oldIndex = getMasterIndex(oldLv)
	local newIndex = getMasterIndex(newLv)
	if oldIndex~=newIndex then
		local compareData = {}
		--[[if oldIndex==0 then
			for i,v in ipairs(newAttr) do
				compareData = {v[1], {0, v[2]}}
			end
		else--]]
		for i,v in ipairs(newAttr) do
			compareData[i] = {v[1], {0, v[2]}}
			if oldIndex~=0 then
				for _,oldData in ipairs(oldAttr) do
					local isHave = false
					if oldData[1] == v[1] then
						compareData[i] = {v[1], {oldData[2], v[2]}}
					end
				end
			end
		end
		self._viewMgr:showHintView("team.TeamHolyMasterUpEffectDialog", {autoCloseTip = false, compareData = compareData, nowLv = newLv})
	end
end

return TeamHolyGradeDialog