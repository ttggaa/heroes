--[[
    Filename:    ParagonTalentView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-26 16:13
    Description: 荣耀天赋系统
--]]

local ParagonTalentView = class("ParagonTalentView", BaseView)

function ParagonTalentView:ctor(param)
	self.super.ctor(self)
	self._pTalentModel = self._modelMgr:getModel("ParagonModel")
	self._userModel = self._modelMgr:getModel("UserModel")

	self._data = {}
end

function ParagonTalentView:onInit()
	self._cell = self:getUI("cell1")
	self._cell:setVisible(false)
	self._icon = self:getUI("icon1")
	self._icon:setVisible(false)

	local Label_21 = self:getUI("tipBg.Label_21")
	Label_21:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	local resetBtn = self:getUI("tipBg.resetBtn")
	self:registerClickEvent(resetBtn, function()
		self:resetBtnFunc()
		end)

	local ruleBtn = self:getUI("tipBg.ruleBtn")
	self:registerClickEvent(ruleBtn, function()
		local ruleDes = lang("TIP_talent_rule_basic")
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = ruleDes},true)
		end)

	self:initTabBtnFunc()
end

function ParagonTalentView:onShow()
	local openIndex = 1
	self._data = self._pTalentModel:getData()
	for i = 1, 4 do
		local isOpen = self:checkTabIsOpenById(100+i)
		if not isOpen then
			break
		end
		openIndex = i
	end
	local btn = self:getUI("listBtn.tab" .. (self._index or openIndex))
	self:tabButtonClick(btn)
end

function ParagonTalentView:tabButtonClick(sender, isForce)
	if sender == nil then 
        return 
    end

    if self._index == sender._index and not isForce then  
        return
    end

    local isOpen = self:checkTabIsOpenById(sender._index + 100)
    if not isOpen then
    	local tipDes = lang("TIP_ParagonTalent_tree")
    	local sysTree1 = tab.paragonTalentTree[sender._index - 1 + 100]
    	local sysTree2 = tab.paragonTalentTree[sender._index + 100]
    	tipDes = string.gsub(tipDes, "{$talenttree}", lang(sysTree1["name"]))
    	tipDes = string.gsub(tipDes, "{$talentpoint}", sysTree2["prePoints"][2])
    	self._viewMgr:showTip(tipDes)
		return
    end

	self._data = self._pTalentModel:getData()
    self._index = sender._index
    self:setBtnState(sender)

    for i=1,4 do
		local layer = self:getUI("bg.layer" .. i)
		layer:setVisible(self._index == i and true or false)
	end

	if self._index == 4 then
		self:createTabView4()
	else
		self:createTabView1()
	end
end

function ParagonTalentView:createTabView1()
	local temp1 = {9, 11, 11}
	local temp2 = {
		{"1_2", "2_6", "2_3", "3_4", "4_5", "2_7", "4_9", "4_8"},
		{"4_6", "6_5", "1_4", "1_8", "8_10", "6_7", "10_11", "10_9", "1_2", "1_3"},
		{"2_3", "6_7", "1_2", "1_4", "4_5", "9_10", "1_9", "1_6", "9_11", "6_8"},
	}

	--icon
	for i=1, temp1[self._index] do
		local iconNode = self:getUI("bg.layer" .. self._index ..".icon" .. i)
		local icon = iconNode._icon
		if not icon then
			icon = self._icon:clone()
			icon:setPosition(0, 0)
			icon:setVisible(true)
			icon:setScaleAnim(true)
			icon._id = self._index * 1000 + i

			iconNode._icon = icon
			iconNode:addChild(icon)

			self:registerClickEvent(icon, function()
				self._viewMgr:showDialog("paragon.ParagonTalentUpDialog", {talentId = icon._id, callback = function()
					local btn = self:getUI("listBtn.tab" .. self._index)
					self:tabButtonClick(btn, true)
					end}, true)
				end)
		end

		self:updateTalentIcon(icon)
	end

	--arrow
	for i,v in ipairs(temp2[self._index]) do
		local arrow = self:getUI("bg.layer" .. self._index .. ".arrow" .. v)
		local ids = string.split(v, "_")
		arrow._id = {self._index * 1000 + tonumber(ids[1]), self._index * 1000 + tonumber(ids[2])}
		
		self:updateArrowState(arrow)
	end

	--costNum
	local costNum = self:getUI("tipBg.costNum")
	local curNum = self:caculateTalentCostNum()
	costNum:setString(curNum)

	--ruleBtn
	local ruleBtn = self:getUI("tipBg.ruleBtn")
	ruleBtn:setPositionX(costNum:getPositionX() + costNum:getContentSize().width + 35)
end

function ParagonTalentView:createTabView4()
	if not self._tableView then
		local tableBg = self:getUI("bg.layer4") --786/345  747/128
		local wid, hei = tableBg:getContentSize().width - 20, tableBg:getContentSize().height - 20
	    self._tableView = cc.TableView:create(cc.size(wid, hei))
	    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	    self._tableView:setPosition(cc.p(10, 10))
	    self._tableView:setDelegate()
	    self._tableView:setBounceable(true) 
	    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
	    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
	    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
	    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	    tableBg:addChild(self._tableView)
	    if self._tableView.setDragSlideable ~= nil then 
	        self._tableView:setDragSlideable(true)
	    end
	    UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), 27, 6)
	end

	self._tableView:reloadData()

	--costNum
	local costNum = self:getUI("tipBg.costNum")
	local curNum = self:caculateTalentCostNum()
	costNum:setString(curNum)
end

function ParagonTalentView:scrollViewDidScroll(view)
	UIUtils:ccScrollViewUpdateScrollBar(view)
end

function ParagonTalentView:cellSizeForTable(table,idx)
	local hei, wid = self._cell:getContentSize().height + 2, self._cell:getContentSize().width
	return hei, wid
end

function ParagonTalentView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
        cell = cc.TableViewCell:new()
    end

    if cell.item == nil then
        local item = self._cell:clone()
        item = self:updateCell(item, idx)
        item:setPosition(cc.p(1,0))
        item:setAnchorPoint(cc.p(0,0))
        cell.item = item
        cell:addChild(item)
    else
        self:updateCell(cell.item, idx)
    end
    
    return cell
end

function ParagonTalentView:numberOfCellsInTableView(table)
	return #tab.paragonTalentTree[104]["talent"]
end

function ParagonTalentView:updateCell(item, idx)
	item:setVisible(true)
	item:setTouchEnabled(false)

	local sysTree = tab.paragonTalentTree[104]
	local curData = sysTree["talent"][idx + 1]

	for i=1, 3 do
		--icon
		local icon = item:getChildByName("icon" .. i)
		icon._id = curData[i]
		self:updateTalentIcon(icon)

		self:registerClickEvent(icon, function()
			self._viewMgr:showDialog("paragon.ParagonTalentUpDialog", {talentId = icon._id, callback = function()
					local btn = self:getUI("listBtn.tab" .. self._index)
					self:tabButtonClick(btn, true)
					end}, true)
			end)
		--arrow
		if i > 1 then
			local arrow = item:getChildByName("arrow" .. (i-1))
			arrow._id = {curData[i-1], curData[i]}

			self:updateArrowState(arrow)
		end
	end

	--title
	local title = item:getChildByFullName("name.img")
	title:loadTexture("paragonImg_titleImg" .. idx + 1 .. ".png", 1)

	return item
end

function ParagonTalentView:updateTalentIcon(inIcon)
	local iconId = inIcon._id
	local sysTalentTree = tab.paragonTalent[iconId]
	local talentData = self._data or {}

	local isUnlock = false 
	local need = sysTalentTree["unlock"]
	if not need or (talentData[tostring(need[1])] and talentData[tostring(need[1])].lv >= need[2]) then
		isUnlock = true
	end

	--img
	local iconImg = inIcon:getChildByName("iconImg")
	iconImg:loadTexture(sysTalentTree["icon"] .. ".png", 1)
	iconImg:setScale(1.2)
	
	--proNum
	local curNum = 0
	if talentData[tostring(iconId)] then
	 	curNum = talentData[tostring(iconId)].lv
	end 
	local proNum = inIcon:getChildByName("proNum")
	proNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	if OS_IS_WINDOWS then
		proNum:setString(curNum .. "/" .. #sysTalentTree["costTalentPoint"] .. "_" .. iconId)
	else
		proNum:setString(curNum .. "/" .. #sysTalentTree["costTalentPoint"])
	end

	--suo
	local suo = inIcon:getChildByName("suo")

	iconImg:setVisible(isUnlock)
	proNum:setVisible(isUnlock)
	suo:setVisible(not isUnlock)
end

function ParagonTalentView:updateArrowState(arrow)
	local talentData = self._data or {}
	local sysTalentTree = tab.paragonTalent

	local isShow = true
	for i=1, 2 do
		local curId = arrow._id[i]
		local isUnlock = false 
		local need = sysTalentTree[curId]["unlock"]
		if need and not (talentData[tostring(need[1])] and talentData[tostring(need[1])].lv >= need[2]) then
			isShow = false
			break
		end
	end

	arrow:getChildByName("Image_69"):setVisible(isShow)
end

function ParagonTalentView:caculateTalentCostNum(inId)
	local curType = inId or (self._index + 100)
	local sysTree = tab.paragonTalentTree[curType]
	local talentData = self._data or {}
	local talentCost, goldCost = 0, 0
	if curType < 104 then
		for i,v in ipairs(sysTree["talent"][1]) do
			local curTalent = talentData[tostring(v)]
			if curTalent and curTalent.lv > 0 then
				local sysTalent = tab.paragonTalent[v]["costTalentPoint"]
				local sysGold = tab.paragonTalent[v]["costGold"]
				for p=1, curTalent.lv do
					talentCost = talentCost + sysTalent[p]
					goldCost = goldCost + sysGold[p]
				end
			end
		end
	else
		for i,v in ipairs(sysTree["talent"]) do
			for m,n in ipairs(v) do
				local curTalent = talentData[tostring(n)]
				if curTalent and curTalent.lv > 0 then
					local sysTalent = tab.paragonTalent[n]["costTalentPoint"]
					local sysGold = tab.paragonTalent[n]["costGold"]
					for p=1, curTalent.lv do
						talentCost = talentCost + sysTalent[p]
						goldCost = goldCost + sysGold[p]
					end
				end
			end
		end
	end

	return talentCost, goldCost
end

function ParagonTalentView:checkTabIsOpenById(inId)
	local sysTree = tab.paragonTalentTree[inId]["prePoints"]
	if type(sysTree) == "table" then
		local curCost = self:caculateTalentCostNum(sysTree[1])
	    if curCost < sysTree[2] then
	    	return false
	    end
	end

    return true
end

function ParagonTalentView:initTabBtnFunc()
	self._btnList = {}
    for i=1, 4 do
    	local btn = self:getUI("listBtn.tab" .. i)
        btn._index = i

        self:registerClickEvent(btn, function(sender) self:tabButtonClick(sender) end)
        table.insert(self._btnList, btn)
    end
end

function ParagonTalentView:setBtnState(inBtn)
	inBtn = inBtn or self:getUI("listBtn.tab"..self._index)
	if self._btnList == nil or next(self._btnList) == nil then
        return
    end

    for k,v in ipairs(self._btnList) do
        v:setBright(true)
        v:setEnabled(true)
        if v._title ~= nil then
            v._title:removeFromParent(true)
            v._title = nil
        end

        v:setTitleFontSize(24)
        v:setTitleColor(cc.c4b(106, 120, 135, 255))
        v:getTitleRenderer():enableOutline(cc.c4b(38, 52, 67, 255), 1)

       	local sysTree = tab.paragonTalentTree[100+k]
        local btnTitle = v:getTitleRenderer()
        btnTitle:setString(lang(sysTree["name"]))
        local isOpen = self:checkTabIsOpenById(v._index + 100)
        UIUtils:setGray(v, not isOpen)
        v:getChildByFullName("suo"):setVisible(not isOpen)
    end

    if inBtn then
        inBtn:setBright(false)
        inBtn:setEnabled(false)
        inBtn:setTitleColor(UIUtils.colorTable.ccUIBaseColor1)
        inBtn:getTitleRenderer():enableOutline(cc.c4b(17, 43, 70, 255), 1)
    end
end

function ParagonTalentView:resetBtnFunc()
	local talentData = self._data or {}
	if next(talentData) == nil then
		self._viewMgr:showTip(lang("TIP_talent_reset_nop"))
		return
	end

	local sumCostTalent, sumCostGold = 0, 0
	for i=1, 4 do
		local costTalent, costGold = self:caculateTalentCostNum(100 + i)
		sumCostTalent = sumCostTalent + costTalent
		sumCostGold = sumCostGold + costGold
	end
	
	if sumCostTalent <= 0 or sumCostGold <= 0 then
		self._viewMgr:showTip(lang("TIP_talent_reset_nop"))
		return
	end

	local curCost = self._userModel:getData().gem
	local needCost = tab.setting["PARAGON_TALENT_RESET_COST_DIAMOND"].value
	if curCost < needCost then
		DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
		    local viewMgr = ViewManager:getInstance()
		    viewMgr:showView("vip.VipView", {viewType = 0})
		end})
        return
	end

	sumCostGold = sumCostGold * tab.setting["PARAGON_TALENT_RESET_GOLD_RETURN"].value
	local tipDes = lang("TIP_talent_reset")
	tipDes = string.gsub(tipDes, "{$diamond}", tab.setting["PARAGON_TALENT_RESET_COST_DIAMOND"].value)
	tipDes = string.gsub(tipDes, "{$talentpoint}", sumCostTalent)
	tipDes = string.gsub(tipDes, "{$goldpercent}", ItemUtils.formatItemCount(sumCostGold))
	self._viewMgr:showDialog("global.GlobalSelectDialog",
        {   title = "重置天赋",
        	desc = tipDes,
            button1 = "确定",
            button2 = "取消", 
            callback1 = function ()
            	self:reqResetTalent()
            end,
            callback2 = function()
            end})
end

function ParagonTalentView:reqResetTalent()
	self._serverMgr:sendMsg("ParagonTalentServer", "resetPTalents", {}, true, {}, function(result, error)
		if result["reward"] then
			DialogUtils.showGiftGet( {
			    gifts = result["reward"],
			    callback = function()
			    end} )
		end
		self._index = nil
	    local btn = self:getUI("listBtn.tab1")
		self:tabButtonClick(btn, true)
	end)
end

function ParagonTalentView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"pTalentPoint","Gold","Gem"},title = "globalTitleUI_team.png",titleTxt = "巅峰天赋"})
end

function ParagonTalentView:getAsyncRes()
    return {{"asset/ui/paragon.plist", "asset/ui/paragon.png"}}
end

function ParagonTalentView:getBgName()
    return "bg_012.jpg"
end

function ParagonTalentView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

return ParagonTalentView