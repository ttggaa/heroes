--[[
	hintType1 --圣徽界面点击左侧已镶嵌的宝石槽中的宝石弹出的tip，
	hintType2 --圣徽界面点击右侧背包中的宝石弹出的tip，
	hintType3 --圣徽界面左右对比时的tip，
	hintType4 --圣徽更换兵团界面点击宝石槽中的宝石弹出的tip，
	hintType5 --主要是在商店或者其他发放物品时点击弹出的预览tip，
	hintType6 --兵团圣徽详情界面tips
--]]


local TeamHolyTipView = class("TeamHolyTipView",BaseLayer)

local l_typeNameStr = {
	[1] = "守序",
	[2] = "善良",
	[3] = "中立",
	[4] = "混乱",
	[5] = "邪恶"
}

function TeamHolyTipView:ctor(data)
	self.super.ctor(self)
	UIUtils.autoCloseTip = false
	self._hintType = data.hintType
	self._holyData = data.holyData
	self._stoneKey = data.key
	self._teamId = data.teamId
	self._selectStone = data.selectStone
	self._rightHolyData = data.bagData
	self._rightKey = data.rightKey
	self._gradeCallback = data.gradeCallback
	self._callback = data.callback
	self._targetNode = data.node --当作为物品提示时的磁吸目标控件
	self._runes = data.runes 					-- 查看他人Tips hgf
	self._isHideBtn = not not data.isHideBtn 	-- 按钮显隐控制 hgf
	self._teamData = data.teamData 					-- 兵团信息 查看他人Tips hgf
	self._runesData = data.runesData 				-- 圣徽信息（获取套装）查看他人Tips hgf
end

function TeamHolyTipView:onInit()
	self._teamModel = self._modelMgr:getModel("TeamModel")
	self._leftPanel = self:getUI("bg.leftPanel")
	self:registerClickEvent(self._leftPanel, function()

	end)
	self._rightPanel = self:getUI("bg.rightPanel")
	self:registerClickEvent(self._rightPanel, function()

	end)
	if self._hintType~=3 then
		self._leftPanel:setPositionX(self._leftPanel:getPositionX()+self._leftPanel:getContentSize().width/2)
	end
	self._rightPanel:setVisible(self._hintType==3)
	self._baseNode = self:getUI("basePanel")
	self._suitNode = self:getUI("suitNode")
	self._additionNode = self:getUI("additionPanel")
	self._lineImg = self:getUI("lineImg")
	
	self._leftScroll = self._leftPanel:getChildByFullName("scroll")
	self._rightScroll = self._rightPanel:getChildByFullName("scroll")
	
	self:registerScriptHandler(function (state)
		if state == "exit" then
			UIUtils:reloadLuaFile("team.TeamHolyTipView")
		end
	end)
	
	self._bg = self:getUI("bg")
	self:registerClickEvent(self._bg, function()
		self._viewMgr:closeHintView()
	end)
	self._bg:setSwallowTouches(false)
	if self["onInitHintType"..self._hintType] then
		self["onInitHintType"..self._hintType](self)
	end

end

function TeamHolyTipView:onInitViewTemplet(holyData, key, panel, scroll, isInlay)
	local iconPanel = panel:getChildByFullName("iconPanel.iconNode")

	local stoneData = self._runes and self._runes[key] or self._teamModel:getHolyDataByKey(key)
	local icon = IconUtils:createHolyBagIcon({suitData = holyData, stoneData = stoneData})
	iconPanel:addChild(icon)
	local nameLab = panel:getChildByFullName("iconPanel.name")
	local nameStr = lang(holyData.name)
	if OS_IS_WINDOWS then
		nameStr = nameStr .. "\n["..holyData.id.."]"
	end
	nameLab:setString(nameStr)
	nameLab:setColor(UIUtils.colorTable["ccColorQuality"..holyData.quality or 1])
	local typeLab = panel:getChildByFullName("iconPanel.typeImg.typeLab")
	typeLab:setString(l_typeNameStr[holyData.type])
	
	local attrData = stoneData.p
	local totalHeight = 0
	self._attrNode = {}
	
	local baseLine = self._lineImg:clone()
	scroll:addChild(baseLine)
	totalHeight = totalHeight + baseLine:getContentSize().height + 10
	
	local addLine
	
	local baseNum = tab:Setting("GEM_BASISATT_NUM").value
	for i,v in ipairs(attrData) do
		if i==baseNum+1 then
			addLine = self._lineImg:clone()
			scroll:addChild(addLine)
			totalHeight = totalHeight + addLine:getContentSize().height + 10
		end
		local attrNode = i<=baseNum and self._baseNode:clone() or self._additionNode:clone()
		local nameLab = attrNode:getChildByFullName("nameLab")
		nameLab:setString(lang("ATTR_"..attrData[i][1]))
		local propLab = attrNode:getChildByFullName("propLab")
		local propStr = UIUtils:getAttrValueStr(attrData[i][1], attrData[i][2])
		propLab:setString(propStr)
		if i>baseNum then
			local dot = attrNode:getChildByFullName("attrDot")
			dot:setVisible(i==6)
			if i==6 then
				nameLab:setColor(cc.c4b(229, 228, 0, 255))
				propLab:setColor(cc.c4b(229, 228, 0, 255))
			end
		end
		totalHeight = totalHeight + attrNode:getContentSize().height
		table.insert(self._attrNode, attrNode)
		attrNode:setVisible(true)
		scroll:addChild(attrNode)
	end
	
	
	local suitLine = self._lineImg:clone()
	scroll:addChild(suitLine)
	totalHeight = totalHeight + suitLine:getContentSize().height
	
	local tbAcSuit = {}
	if self._teamId then
		local curTeam = self._teamModel:getTeamAndIndexById(self._teamId)
		local suitData = self._teamModel:getTeamSuitById(curTeam)
		for i,v in pairs(suitData) do
			if table.nums(v)>0 then
				tbAcSuit[i] = {}
				for _,actData in pairs(v) do
					local quality = tab.rune[actData.stoneId].quality
					tbAcSuit[i][actData.suitNum] = quality
				end
			end
		end
	end
	local effectTab = tab:Setting("GEM_EFFECT_NUM").value
	local stoneId = stoneData.id
	local stoneTab = tab:Rune(stoneId)
	self._suitDescNode = {}
	totalHeight = totalHeight + 20
	for i=1,table.nums(effectTab) do
		local suitNode = self._suitNode:clone()
		local richtextBg = suitNode:getChildByFullName("descPanel")
		local indexId = effectTab[i]
		local desc = lang(stoneTab["des" .. indexId])
		
		if string.find(desc, "color=") == nil then
			desc = "[color=462800]"..desc.."[-]"
		end
		desc = string.gsub(desc, "fontsize=20", "fontsize=16")
		if isInlay and tbAcSuit and tbAcSuit[stoneData.make] and tbAcSuit[stoneData.make][indexId] then
			local quality = tbAcSuit[stoneData.make][indexId]
			if quality==stoneData.quality then
				desc = string.gsub(desc, "645252", "fae6c8")
			end
		end
		local richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
		richText:setPixelNewline(true)
		richText:formatText()
		richText:setVerticalSpace(3)
		richText:enablePrinter(true)
		richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
		richText:setName("richText" .. i)
		richtextBg:addChild(richText)
		suitNode:setContentSize(suitNode:getContentSize().width, richText:getInnerSize().height+6)
		richtextBg:setContentSize(richtextBg:getContentSize().width, richText:getInnerSize().height)
		richtextBg:setPositionY(suitNode:getContentSize().height-3)
		richText:setPositionY(richtextBg:getContentSize().height/2)
		
		totalHeight = totalHeight + suitNode:getContentSize().height
		scroll:addChild(suitNode)
		suitNode:setVisible(true)
		table.insert(self._suitDescNode, suitNode)
	end
	if totalHeight>scroll:getInnerContainerSize().height then
		scroll:setInnerContainerSize(cc.size(scroll:getInnerContainerSize().width, totalHeight))
	end
	local containerHeight = scroll:getInnerContainerSize().height
	local posY = containerHeight
	baseLine:setPosition(cc.p(0, posY-baseLine:getContentSize().height))
	posY = posY - baseLine:getContentSize().height - 10
	for i,v in ipairs(self._attrNode) do
		if i==baseNum+1 then
			addLine:setPosition(cc.p(0, posY-addLine:getContentSize().height))
			posY = posY-addLine:getContentSize().height-10
		end
		v:setPosition(cc.p(0, posY-v:getContentSize().height))
		posY = v:getPositionY()
	end
	posY = posY - 10
	suitLine:setPosition(cc.p(0, posY - suitLine:getContentSize().height))
	posY = posY - suitLine:getContentSize().height - 10
	for i,v in ipairs(self._suitDescNode) do
		v:setPosition(cc.p(0, posY-v:getContentSize().height))
		posY = v:getPositionY()
	end
end

function TeamHolyTipView:onInitHintType1()--点击左侧槽位时显示的状态
	self:onInitViewTemplet(self._holyData, self._stoneKey, self._leftPanel, self._leftScroll, true)
	
	local leftFunBtn = self._leftPanel:getChildByFullName("btnPanel.funBtn")
	leftFunBtn:setTitleText("卸下")
	local rightFunBtn = self._leftPanel:getChildByFullName("btnPanel.gradeBtn")

	self:registerClickEvent(leftFunBtn, function()
		local param = {teamId = self._teamId, sids = self._selectStone}
		self._serverMgr:sendMsg("TeamServer", "takeRune", param, true, {}, function (result)
			if self._callback then
				self._callback()
			end
			self._viewMgr:closeHintView()
		end)
	end)
	
	self:registerClickEvent(rightFunBtn, function()
		local stoneData = self._teamModel:getHolyDataByKey(self._stoneKey)
		local tabGrade = tab.runeDisintegration[stoneData.quality]
		if stoneData.lv>tabGrade.castingCap then
			self._viewMgr:showTip(lang("RUNE_TIPS_3"))
		else
			UIUtils:reloadLuaFile("team.TeamHolyGradeDialog")
			self._viewMgr:showDialog("team.TeamHolyGradeDialog", {key = self._stoneKey, teamId = self._teamId, callback = self._gradeCallback})
		end
	end)
end

function TeamHolyTipView:onInitHintType2()--点击背包中的宝石弹出的提示
	self:onInitViewTemplet(self._holyData, self._stoneKey, self._leftPanel, self._leftScroll)
	
	local leftFunBtn = self._leftPanel:getChildByFullName("btnPanel.funBtn")
	local rightFunBtn = self._leftPanel:getChildByFullName("btnPanel.gradeBtn")
	self:registerClickEvent(leftFunBtn, function()
		local param = {teamId = self._teamId, sid = self._selectStone, id = self._stoneKey}
		self._serverMgr:sendMsg("TeamServer", "equipRune", param, true, {}, function (result)
			if self._callback then
				self._callback()
			end
			self._viewMgr:closeHintView()
		end)
	end)
	if not self._selectStone then
		leftFunBtn:setSaturation(-100)
		leftFunBtn:setEnabled(false)
	end
	
	self:registerClickEvent(rightFunBtn, function()
		local stoneData = self._teamModel:getHolyDataByKey(self._stoneKey)
		local tabGrade = tab.runeDisintegration[stoneData.quality]
		if stoneData.lv>tabGrade.castingCap then
			self._viewMgr:showTip(lang("RUNE_TIPS_3"))
		else
			UIUtils:reloadLuaFile("team.TeamHolyGradeDialog")
			self._viewMgr:showDialog("team.TeamHolyGradeDialog", {key = self._stoneKey})
		end
	end)
end

function TeamHolyTipView:onInitHintType3()--左右对比的状态
	self:onInitViewTemplet(self._holyData, self._stoneKey, self._leftPanel, self._leftScroll, true)
	self:onInitViewTemplet(self._rightHolyData, self._rightKey, self._rightPanel, self._rightScroll)
	
	local leftFunBtn = self._rightPanel:getChildByFullName("btnPanel.funBtn")
	leftFunBtn:setTitleText("替换")
	local rightFunBtn = self._rightPanel:getChildByFullName("btnPanel.gradeBtn")
	self:registerClickEvent(leftFunBtn, function()
		--[[local param = {teamId = self._teamId, sids = self._selectStone}
		self._serverMgr:sendMsg("TeamServer", "takeRune", param, true, {}, function (result)
			if self._callback then
				self._callback()
			end
			self._viewMgr:closeHintView()
		end)--]]
		
		local param = {teamId = self._teamId, sid = self._selectStone, id = self._rightKey}
		self._serverMgr:sendMsg("TeamServer", "equipRune", param, true, {}, function (result)
			if self._callback then
				self._callback()
			end
			self._viewMgr:closeHintView()
		end)
	end)
	
	self:registerClickEvent(rightFunBtn, function()
		local stoneData = self._teamModel:getHolyDataByKey(self._rightKey)
		local tabGrade = tab.runeDisintegration[stoneData.quality]
		if stoneData.lv>tabGrade.castingCap then
			self._viewMgr:showTip(lang("RUNE_TIPS_3"))
		else
			UIUtils:reloadLuaFile("team.TeamHolyGradeDialog")
			self._viewMgr:showDialog("team.TeamHolyGradeDialog", {key = self._rightKey})
		end
	end)
	self:stateToCompare()
end

function TeamHolyTipView:onInitHintType4()
	self:onInitViewTemplet(self._holyData, self._stoneKey, self._leftPanel, self._leftScroll, true)
	self:stateToCompare()
end

function TeamHolyTipView:stateToCompare()
	self._leftPanel:setContentSize(self._leftPanel:getContentSize().width, self._leftPanel:getContentSize().height-50)
	self._leftPanel:getChildByFullName("btnPanel"):setVisible(false)
	self._leftPanel:getChildByFullName("iconPanel"):setPositionY(self._leftPanel:getChildByFullName("iconPanel"):getPositionY()-50)
	self._leftPanel:getChildByFullName("scroll"):setPositionY(self._leftScroll:getPositionY()-50)
end

function TeamHolyTipView:onInitHintType5()
	local isHaveAttr = false
	if self._stoneKey then
		isHaveAttr = true
		self:onInitViewTemplet(self._holyData, self._stoneKey, self._leftPanel, self._leftScroll)
	else
		local holyData = self._holyData
		local iconPanel = self._leftPanel:getChildByFullName("iconPanel.iconNode")
		local icon = IconUtils:createHolyBagIcon({suitData = self._holyData})
		iconPanel:addChild(icon)
		local nameLab = self._leftPanel:getChildByFullName("iconPanel.name")
		local nameStr = lang(holyData.name)
		if OS_IS_WINDOWS then
			nameStr = nameStr .. "\n["..holyData.id.."]"
		end
		nameLab:setString(nameStr)
		nameLab:setColor(UIUtils.colorTable["ccColorQuality"..holyData.quality or 1])
		local typeLab = self._leftPanel:getChildByFullName("iconPanel.typeImg.typeLab")
		typeLab:setString(l_typeNameStr[holyData.type])
		
		local attrData = ""
		if holyData.fixBasisAtt and table.nums(holyData.fixBasisAtt)>0 then
			for i,v in ipairs(holyData.fixBasisAtt) do
				attrData = attrData .. "["..v[1]..","..v[2].."],"
			end
		end
		if holyData.fixAddAtt and table.nums(holyData.fixAddAtt)>0 then
			for i,v in ipairs(holyData.fixAddAtt) do
				attrData = attrData .. "["..v[1]..","..v[2].."]"
				if i~=table.nums(holyData.fixAddAtt) then
					attrData = attrData .. ","
				end
			end
		end
		attrData = json.decode("["..attrData.."]")
		
	--	local attrData = stoneData.p
		local totalHeight = 0
		self._attrNode = {}
		
		local baseLine = self._lineImg:clone()
		self._leftScroll:addChild(baseLine)
		totalHeight = totalHeight + baseLine:getContentSize().height + 10
		local addLine
		local baseNum = tab:Setting("GEM_BASISATT_NUM").value
		if table.nums(attrData)>0 then
			isHaveAttr = true
			for i,v in ipairs(attrData) do
				if i==baseNum+1 then
					addLine = self._lineImg:clone()
					self._leftScroll:addChild(addLine)
					totalHeight = totalHeight + addLine:getContentSize().height + 10
				end
				local attrNode = i<=baseNum and self._baseNode:clone() or self._additionNode:clone()
				local nameLab = attrNode:getChildByFullName("nameLab")
				nameLab:setString(lang("ATTR_"..attrData[i][1]))
				local propLab = attrNode:getChildByFullName("propLab")
				local propStr = UIUtils:getAttrValueStr(attrData[i][1], attrData[i][2])
				propLab:setString(propStr)
				if i>baseNum then
					local dot = attrNode:getChildByFullName("attrDot")
					dot:setVisible(i==6)
					if i==6 then
						nameLab:setColor(cc.c4b(229, 228, 0, 255))
						propLab:setColor(cc.c4b(229, 228, 0, 255))
					end
				end
				totalHeight = totalHeight + attrNode:getContentSize().height
				table.insert(self._attrNode, attrNode)
				attrNode:setVisible(true)
				self._leftScroll:addChild(attrNode)
			end
		else
			self._leftScroll:setContentSize(self._leftScroll:getContentSize().width, self._leftScroll:getContentSize().height-150)
			self._leftScroll:setInnerContainerSize(self._leftScroll:getContentSize())
			isHaveAttr = false
			local attrNode = self._suitNode:clone()
			local attrLab = ccui.Text:create()
			attrLab:setString(string.format("获得后，获取随机属性"))
			attrLab:setName("attrLab")
			attrLab:setFontName(UIUtils.ttfName)
			attrLab:setFontSize(18)
			attrLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)
			attrLab:setPosition(attrNode:getContentSize().width/2, attrNode:getContentSize().height/2)
			attrNode:addChild(attrLab)
			table.insert(self._attrNode, attrNode)
			self._leftScroll:addChild(attrNode)
			totalHeight = totalHeight + attrNode:getContentSize().height
		end
		
		local suitLine = self._lineImg:clone()
		self._leftScroll:addChild(suitLine)
		totalHeight = totalHeight + suitLine:getContentSize().height + 10
		
		local effectTab = tab:Setting("GEM_EFFECT_NUM").value
		local stoneId = holyData.id
	--	local stoneTab = tab:Rune(stoneId)
		self._suitDescNode = {}
		for i=1,table.nums(effectTab) do
			local suitNode = self._suitNode:clone()
			local richtextBg = suitNode:getChildByFullName("descPanel")
			local indexId = effectTab[i]
			local desc = lang(holyData["des" .. indexId])
			
			if string.find(desc, "color=") == nil then
				desc = "[color=462800]"..desc.."[-]"
			end
			desc = string.gsub(desc, "fontsize=20", "fontsize=16")
			local richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
			richText:setPixelNewline(true)
			richText:formatText()
			richText:setVerticalSpace(3)
			richText:enablePrinter(true)
			richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
			richText:setName("richText" .. i)
			richtextBg:addChild(richText)
			suitNode:setContentSize(suitNode:getContentSize().width, richText:getInnerSize().height+6)
			richtextBg:setContentSize(richtextBg:getContentSize().width, richText:getInnerSize().height)
			richtextBg:setPositionY(suitNode:getContentSize().height-3)
			richText:setPositionY(richtextBg:getContentSize().height/2)
			
			totalHeight = totalHeight + suitNode:getContentSize().height
			self._leftScroll:addChild(suitNode)
			suitNode:setVisible(true)
			table.insert(self._suitDescNode, suitNode)
		end
		if totalHeight>self._leftScroll:getInnerContainerSize().height then
			self._leftScroll:setInnerContainerSize(cc.size(self._leftScroll:getInnerContainerSize().width, totalHeight))
		end
		local containerHeight = self._leftScroll:getInnerContainerSize().height
		local posY = containerHeight
		baseLine:setPosition(cc.p(0, posY-baseLine:getContentSize().height))
		posY = baseLine:getPositionY()-10
		for i,v in ipairs(self._attrNode) do
			if addLine and i==baseNum + 1 then
				addLine:setPosition(cc.p(0, posY - addLine:getContentSize().height))
				posY = addLine:getPositionY()-10
			end
			v:setPosition(cc.p(0, posY-v:getContentSize().height))
			posY = v:getPositionY()
		end
		suitLine:setPosition(cc.p(0, posY - suitLine:getContentSize().height))
		posY = suitLine:getPositionY()-10
		for i,v in ipairs(self._suitDescNode) do
			v:setPosition(cc.p(0, posY-v:getContentSize().height))
			posY = v:getPositionY()
		end
	end
	if isHaveAttr then
		self:stateToCompare()
	else
		self._leftPanel:setContentSize(self._leftPanel:getContentSize().width, self._leftPanel:getContentSize().height-200)
		self._leftPanel:getChildByFullName("btnPanel"):setVisible(false)
		self._leftPanel:getChildByFullName("iconPanel"):setPositionY(self._leftPanel:getChildByFullName("iconPanel"):getPositionY()-200)
		self._leftPanel:getChildByFullName("scroll"):setPositionY(self._leftScroll:getPositionY()-50)
	end
	
	local worldPos = self._targetNode:getParent():convertToWorldSpace(cc.p(self._targetNode:getPosition()))
	local targetPosX = worldPos.x - self._leftPanel:getContentSize().width
	if targetPosX<=0 then
		targetPosX = worldPos.x + self._targetNode:getContentSize().width
	end
	local targetPosY = worldPos.y + self._leftPanel:getContentSize().height
	if targetPosY>MAX_SCREEN_HEIGHT then
		targetPosY = MAX_SCREEN_HEIGHT-50
	end
	self._leftPanel:setPosition(targetPosX,targetPosY)
end

function TeamHolyTipView:onInitHintType6() --他人圣徽tips
	self:onInitViewTemplet6(self._holyData, self._stoneKey, self._leftPanel, self._leftScroll, true)
	
	local leftFunBtn = self._leftPanel:getChildByFullName("btnPanel.funBtn")
	local rightFunBtn = self._leftPanel:getChildByFullName("btnPanel.gradeBtn")
	leftFunBtn:setVisible(not self._isHideBtn)
	rightFunBtn:setVisible(not self._isHideBtn)

end

function TeamHolyTipView:onInitViewTemplet6(holyData, key, panel, scroll, isInlay)
	local iconPanel = panel:getChildByFullName("iconPanel.iconNode")

	local stoneData = self._runes and self._runes[key] or self._teamModel:getHolyDataByKey(key)
	local icon = IconUtils:createHolyBagIcon({suitData = holyData, stoneData = stoneData})
	iconPanel:addChild(icon)
	local nameLab = panel:getChildByFullName("iconPanel.name")
	local nameStr = lang(holyData.name)
	if OS_IS_WINDOWS then
		nameStr = nameStr .. "\n["..holyData.id.."]"
	end
	nameLab:setString(nameStr)
	local typeLab = panel:getChildByFullName("iconPanel.typeImg.typeLab")
	typeLab:setString(l_typeNameStr[holyData.type])
	
	local attrData = stoneData.p
	local totalHeight = 0
	self._attrNode = {}
	
	local baseLine = self._lineImg:clone()
	scroll:addChild(baseLine)
	totalHeight = totalHeight + baseLine:getContentSize().height + 10
	
	local addLine
	
	local baseNum = tab:Setting("GEM_BASISATT_NUM").value
	for i,v in ipairs(attrData) do
		if i==baseNum+1 then
			addLine = self._lineImg:clone()
			scroll:addChild(addLine)
			totalHeight = totalHeight + addLine:getContentSize().height + 10
		end
		local attrNode = i<=baseNum and self._baseNode:clone() or self._additionNode:clone()
		local nameLab = attrNode:getChildByFullName("nameLab")
		nameLab:setString(lang("ATTR_"..attrData[i][1]))
		local propLab = attrNode:getChildByFullName("propLab")
		local propStr = UIUtils:getAttrValueStr(attrData[i][1], attrData[i][2])
		propLab:setString(propStr)
		if i>baseNum then
			local dot = attrNode:getChildByFullName("attrDot")
			dot:setVisible(i==6)
			if i==6 then
				nameLab:setColor(cc.c4b(196, 73, 4, 255))
				propLab:setColor(cc.c4b(196, 73, 4, 255))
			end
		end
		totalHeight = totalHeight + attrNode:getContentSize().height
		table.insert(self._attrNode, attrNode)
		attrNode:setVisible(true)
		scroll:addChild(attrNode)
	end	
	
	local suitLine = self._lineImg:clone()
	scroll:addChild(suitLine)
	totalHeight = totalHeight + suitLine:getContentSize().height
	
	local tbAcSuit = {}
	if self._teamData then
		local curTeam = self._teamData or {}
		local suitData = self._teamModel:getTeamSuitByDataAndParam(curTeam,self._runesData)
		-- dump(suitData,"suitData===>",6)
		for i,v in pairs(suitData) do
			if table.nums(v)>0 then
				tbAcSuit[i] = {}
				for _,actData in pairs(v) do
					local quality = tab.rune[actData.stoneId].quality
					-- print("===============suitData====",quality,actData.suitNum)
					tbAcSuit[i][actData.suitNum] = quality
				end
			end
		end
	end
	-- dump(tbAcSuit,"tbAcSuit==>",5)
	local effectTab = tab:Setting("GEM_EFFECT_NUM").value
	local stoneId = stoneData.id
	local stoneTab = tab:Rune(stoneId)
	self._suitDescNode = {}
	totalHeight = totalHeight + 20
	for i=1,table.nums(effectTab) do
		local suitNode = self._suitNode:clone()
		local richtextBg = suitNode:getChildByFullName("descPanel")
		local indexId = effectTab[i]
		local desc = lang(stoneTab["des" .. indexId])
		
		if string.find(desc, "color=") == nil then
			desc = "[color=462800]"..desc.."[-]"
		end
		desc = string.gsub(desc, "fontsize=20", "fontsize=16")
		if isInlay and tbAcSuit and tbAcSuit[stoneData.make] and tbAcSuit[stoneData.make][indexId] then
			local quality = tbAcSuit[stoneData.make][indexId]
			if quality == stoneData.quality then
				desc = string.gsub(desc, "645252", "fae6c8")
			end
		end
		local richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
		richText:setPixelNewline(true)
		richText:formatText()
		richText:setVerticalSpace(3)
		richText:enablePrinter(true)
		richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
		richText:setName("richText" .. i)
		richtextBg:addChild(richText)
		suitNode:setContentSize(suitNode:getContentSize().width, richText:getInnerSize().height+6)
		richtextBg:setContentSize(richtextBg:getContentSize().width, richText:getInnerSize().height)
		richtextBg:setPositionY(suitNode:getContentSize().height-3)
		richText:setPositionY(richtextBg:getContentSize().height/2)
		
		totalHeight = totalHeight + suitNode:getContentSize().height
		scroll:addChild(suitNode)
		suitNode:setVisible(true)
		table.insert(self._suitDescNode, suitNode)
	end
	if totalHeight>scroll:getInnerContainerSize().height then
		scroll:setInnerContainerSize(cc.size(scroll:getInnerContainerSize().width, totalHeight))
	end
	local containerHeight = scroll:getInnerContainerSize().height
	local posY = containerHeight
	baseLine:setPosition(cc.p(0, posY-baseLine:getContentSize().height))
	posY = posY - baseLine:getContentSize().height - 10
	for i,v in ipairs(self._attrNode) do
		if i==baseNum+1 then
			addLine:setPosition(cc.p(0, posY-addLine:getContentSize().height))
			posY = posY-addLine:getContentSize().height-10
		end
		v:setPosition(cc.p(0, posY-v:getContentSize().height))
		posY = v:getPositionY()
	end
	posY = posY - 10
	suitLine:setPosition(cc.p(0, posY - suitLine:getContentSize().height))
	posY = posY - suitLine:getContentSize().height - 10
	for i,v in ipairs(self._suitDescNode) do
		v:setPosition(cc.p(0, posY-v:getContentSize().height))
		posY = v:getPositionY()
	end
end

function TeamHolyTipView:onShow()
	
end

return TeamHolyTipView