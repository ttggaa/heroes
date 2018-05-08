--[[
    Filename:    WeaponsToolsBagView.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2017-09-11 10:56:50
    Description: File description
--]]

local WeaponsToolsBagView = class("WeaponsToolsBagView", BaseView)

function WeaponsToolsBagView:ctor(data)
	WeaponsToolsBagView.super.ctor(self)
    self.initAnimType = 3
end

function WeaponsToolsBagView:getAsyncRes()
    return 
    {
        {"asset/ui/treasure1.plist", "asset/ui/treasure1.png"},
        {"asset/ui/bag.plist", "asset/ui/bag.png"},
--		{"asset/ui/weapons.plist", "asset/ui/weapons.png"}
    }
end

function WeaponsToolsBagView:getBgName()
    return "bg_007.jpg"
end

local sortFunc = function(a, b)
	local akey = a.key 
	local bkey = b.key 
	--[[local aquality = a.quality
	local bquality = b.quality--]]
	local aorder = a.order
	local border = b.order
	--[[local ascore = a.score
	local bscore = b.score--]]
	local aonEquit = a.onEquit
	local bonEquit = b.onEquit
	if aonEquit ~= bonEquit then
		return aonEquit > bonEquit
	--[[elseif aquality ~= bquality then
		return aquality > bquality
	elseif ascore and bscore and ascore ~= bscore then
		return ascore > bscore--]]
	elseif aorder and border and aorder ~= border then
		return aorder < border
	elseif akey ~= bkey then
		return akey < bkey
	end
end

function WeaponsToolsBagView:onInit()
    self._weaponsModel = self._modelMgr:getModel("WeaponsModel")

	UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_all"),135,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_material"),135,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_storm"),135,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_drive"),135,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_measure"),135,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(self:getUI("bg.layer.tab_magic"),135,handler(self, self.tabButtonClick))
	
	local itemName = self:getUI("bg.layer.itemInfo.itemName")
    if OS_IS_WINDOWS then
        itemName:setPositionY(itemName:getPositionY() + itemName:getContentSize().height * 0.5)
        itemName:setAnchorPoint(0.5, 1)
    end

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_all"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_material"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_storm"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_drive"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_measure"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_magic"))
    self._animBtns = self._tabEventTarget
    self._playAnimBg = self:getUI("bg.layer.bg1")
    self._playAnimBgOffX = 46
    self._playAnimBgOffY = -28
    self._tabPosX = 135
    for k,button in pairs(self._tabEventTarget) do
        button:setTitleFontName(UIUtils.ttfName)
        -- button:setTitleFontSize(32)
        button:setPositionX(self._tabPosX)
        button:setZOrder(-10)
        button:setAnchorPoint(1,0.5)
    end

	self._useProps = self._weaponsModel:getUsePropsIdData()
    self._tableData = self._weaponsModel:getNewPropsData()
	for k,v in pairs(self._tableData) do
		if self._useProps[v.key] then
			v.onEquit = self._useProps[v.key]
		else
			v.onEquit = 0
		end
	end
	table.sort(self._tableData, sortFunc)
    self:addTableView()
	
	self._attrScrollAnim = self:getUI("bg.layer.itemInfo.DesBg.bottom")
    local mc1 = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(self._attrScrollAnim:getContentSize().width*0.5, self._attrScrollAnim:getContentSize().height*0.5))
    self._attrScrollAnim:addChild(mc1)
	
	self._attrScrollView = self:getUI("bg.layer.itemInfo.DesBg.ScrollView")
    self._attrScrollView:addEventListener(function(sender, eventType)
        if eventType == 6 or eventType == 1 then
            self._attrScrollAnim:setVisible(false)
        else
			local innerContainerHeight = self._attrScrollView:getInnerContainerSize().height
			local contentHeight = self._attrScrollView:getContentSize().height
            self._attrScrollAnim:setVisible(innerContainerHeight>contentHeight)
        end
--		self._attrScrollAnim:setVisible(eventType~=1 and eventType~=6)
    end)
	
	self._breakBtn = self:getUI("bg.layer.breakBtn")
	self:registerClickEvent(self._breakBtn, function()
		self._viewMgr:showDialog("weapons.WeaponsBreakView")
	end)
	

    self._countLabel = self:getUI("bg.layer.itemInfo.countLabel")
    self._maxCount = tab:Setting("WEAPON_LIMIT").value
    self._countLabel:setString(string.format("%d/%d", #self._tableData, self._maxCount))
	local strColor = #self._tableData<self._maxCount and cc.c4b(138, 92, 29, 255) or cc.c4b(255, 0, 0, 255)
	self._countLabel:setTextColor(strColor)

    self._bagInfo = self:getUI("bg.layer.itemInfo")
    self._itemInfoBg = self:getUI("bg.layer.itemInfo.itemInfoBg")
	
    self._nameBg = self:getUI("bg.layer.itemInfo.nameBg")

    self._noItemRoot = self:getUI("bg.layer.noneDes")
    self._bg2 = self:getUI("bg.layer.itemInfo.bg2")

    self._selFrame = self:getUI("bg.layer.selFrame")
    self._selFrame:setPosition(-13,-11)
    self._selFrame:setContentSize(cc.size(90,90))
    self._selFrame:setAnchorPoint(0,0)
    self._selFrame:setVisible(false)
    self._selFrame:setOpacity(0)
    
	self._tabEventTarget[1]._appearSelect = true
	self:reorderTabs()
--	self:tabButtonClick(self._tabEventTarget[1],true)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("weapons.WeaponsToolsBagView")
        end
    end)
	
    self:listenReflash("WeaponsModel", self.reflashWeaponsBagView)
end

function WeaponsToolsBagView:tabButtonClick(sender,noAudio)
    if sender == nil then 
        return 
    end
    if not noAudio then 
        audioMgr:playSound("Tab")
    end
    self:setBagInfoNodesVisible(false)
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
    local data = self:refreshTabData(sender:getName())
    self:refreshBagInfo(data[1])
    local item = self._tableView:cellAtIndex(0):getChildByFullName("cellItem0")
    local iData  = data[1]
    self:touchItemEnd(iData,item)
end

function WeaponsToolsBagView:reorderTabs( )
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
    self._enabledTabs = {}
    table.insert(self._enabledTabs,self._tabEventTarget[1])
    local tabIds = {{1}, {2}, {3}, {4}, {5}}
	local isChangeSelect = true
    for i,v in ipairs(tabIds) do
        local items = self._weaponsModel:getPropsDataByType(v)
        local text = self._tabEventTarget[i+1]:getTitleRenderer()
        if #items > 0 then
			if self._tabEventTarget[i+1]:getName()==self._tabName then
				isChangeSelect = false
			end
            table.insert(self._enabledTabs,self._tabEventTarget[i+1])
            self._tabEventTarget[i+1]:setVisible(true)
            UIUtils:setGray(self._tabEventTarget[i+1],false)
            UIUtils:setTabChangeAnimEnable(self._tabEventTarget[i+1],135,handler(self, self.tabButtonClick))
        else
            UIUtils:setGray(self._tabEventTarget[i+1],true)
            self._tabEventTarget[i+1]:setEnabled(true)
            local text = self._tabEventTarget[i+1]:getTitleRenderer()
            text:disableEffect()
            self._tabEventTarget[i+1]:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            self:tabButtonState(self._tabEventTarget[i+1], false,true)
            self:registerClickEvent(self._tabEventTarget[i+1],function ( )
                self._viewMgr:showTip(lang("TIPS_BEIBAO_03"))
            end)
        end
    end
	if isChangeSelect then
		self:tabButtonClick(self._tabEventTarget[1],true)
	end
end

function WeaponsToolsBagView:touchItemEnd(info,item)
    if not info or not item or tolua.isnull(item) then
        return 
    end
    self._selectedItem = info
    local lastIcon 
    local scaleNum = (93/item:getContentSize().width)
    -- runAction
    if not tolua.isnull(self._selectedItemIcon) then
        lastIcon = self._selectedItemIcon:getParent()  
        -- scaleNum = lastIcon:getScale()      
        self._selectedItemIcon:removeFromParent()
    end
    self._selectedItemIcon = self._selFrame:clone()
    self._selectedItemIcon:setName("select")
    local mc1 = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
    if mc1 then
        mc1:setName("anim")
        mc1:setPosition(64, 61)
        mc1:setScale(0.95)
        self._selectedItemIcon:addChild(mc1, 1)
        self._selectedItemIcon:setOpacity(0)
    end
    self._selectedItemIcon:setVisible(true)
    -- item:setScale(5)
    -- item:setColor(cc.c4b(255, 0, 0, 255))
    item:addChild(self._selectedItemIcon,7)
    
    -- if item._itemName then
        self._selectedItem._itemName = item._itemName or self._selectedItem._itemName
    -- end    
    self._inScrolling = false
    -- 如果重复点击同一个图标 不刷新界面
    if self._itemIdx == item._indexNum then return end 
    self._itemIdx = item._indexNum or 1
    self:refreshBagInfo(info)
    -- 如果是可使用物品，设置model里是否通知过状态
    if item and item._isCanUse then 
        if not self._modelMgr:getModel("ItemModel"):isItemHadNoticed( info.goodsId ) then
            self._modelMgr:getModel("ItemModel"):setItemNoticed( info.goodsId )
        end
    end
    -- 如果上一个是可使用物品，重新设置红点
    if lastIcon and lastIcon._isCanUse then 
        local tip = lastIcon:getChildByFullName("iconColor") and lastIcon:getChildByFullName("iconColor"):getChildByFullName("tip")
        if tip then 
            tip:setVisible(false)
        end
    --     lastIcon:stopAllActions()
    --     lastIcon:setScale(scaleNum)
    --     local repeatAction = cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1,scaleNum - 0.05), cc.ScaleTo:create(1,scaleNum)))
    --     lastIcon:runAction(repeatAction)
    end
end

function WeaponsToolsBagView:CreatePropertyLabel(count)
    self._itemProperty = self._itemProperty or {}
    count = count - #self._itemProperty
    local fatherNode = self:getUI("bg.layer.itemInfo.DesBg")
    if count>0 then
        for i=1, count do
            local propertyLabel = {}
            nameLabel = ccui.Text:create()
            nameLabel:setTextHorizontalAlignment(3)
            nameLabel:setFontName(UIUtils.ttfName)
            nameLabel:setTextColor(cc.c4b(138, 92, 29, 255))
            nameLabel:setFontSize(18)
			nameLabel:setAnchorPoint(0, 0.5)
            nameLabel:setPosition(cc.p(10, fatherNode:getContentSize().height - (#self._itemProperty*20+10)-10))
            fatherNode:addChild(nameLabel)

            valueLabel = ccui.Text:create()
            valueLabel:setTextHorizontalAlignment(1)
            valueLabel:setFontName(UIUtils.ttfName)
            valueLabel:setFontSize(18)
            valueLabel:setTextColor(cc.c4b(138, 92, 29, 255))
            valueLabel:setAnchorPoint(0, 0.5)
            valueLabel:setPositionY( nameLabel:getPositionY())
            fatherNode:addChild(valueLabel)

			descLabel= ccui.Text:create()
			descLabel:setTextHorizontalAlignment(1)
			descLabel:setFontName(UIUtils.ttfName)
			descLabel:setFontSize(18)
			descLabel:setTextColor(cc.c4b(28, 162, 22, 255))
			descLabel:setAnchorPoint(0, 0.5)
			descLabel:setPositionY(nameLabel:getPositionY())
			fatherNode:addChild(descLabel)

            propertyLabel.nameLabel = nameLabel
            propertyLabel.valueLabel = valueLabel
			propertyLabel.descLabel = descLabel
            table.insert(self._itemProperty, propertyLabel)
        end
    end
	
	if not self._percentLabel then
		self._percentLabel = { }
		for i=1, 3 do
			local percentLabel = ccui.Text:create()
			percentLabel:setTextHorizontalAlignment(1)
			percentLabel:setFontName(UIUtils.ttfName)
			percentLabel:setFontSize(18)
			percentLabel:setTextColor(cc.c4b(120, 120, 120, 255))
			percentLabel:setAnchorPoint(0, 0.5)
			percentLabel:setPosition(cc.p(10, fatherNode:getContentSize().height/2 - (#self._percentLabel*20+8)-10))
			fatherNode:addChild(percentLabel)
			table.insert(self._percentLabel, percentLabel)
		end
	end
end

function WeaponsToolsBagView:refreshBagInfo(data)
    -- if self._bagInfo == nil then
    --     local info = self:creat("bag.BagItemInfoView")
    --     self._infoNode:addChild(info)
    --     self._bagInfo = info
    -- end
    
    if data == nil then 
        self:setBagInfoNodesVisible(false)
        if not tolua.isnull(self._selectedItemIcon) then
            self._selectedItemIcon:removeFromParent()
        end
        -- self._infoNode:setVisible(false)
        self._bg2:setVisible(false)
        self._noItemRoot:setVisible(true)
        self._none = true
        -- self:reorderTabs()
        local curData = self:refreshTabData(self._tabName)
        if next(curData) == nil and self._tabName ~= "tab_all" then
            self._tableView:reloadData()
            self:tabButtonClick(self._tabEventTarget[1],true)
            local curData = self:refreshTabData(self._tabName)
            local item = self._tableView:cellAtIndex(0):getChildByFullName("cellItem0")
            item._itemName = "cellItem0"
            local iData  = curData[1]
            self:touchItemEnd(iData,item)
        end
        return
    end

    self._bg2:setVisible(true)
    self._noItemRoot:setVisible(false)
    self._none = false
    self:setBagInfoNodesVisible(true)
    local tbItemData = tab.siegeEquip[data.id]
    tbItemData.lvl = data.lv
    tbItemData.score = data.score
	
	self:reloadScrollAttrData(tbItemData)

    --[[self:CreatePropertyLabel(#tbItemData.intproperty)
    for i,v in ipairs(self._itemProperty) do
        local configData = tbItemData.intproperty[i]
        if configData then
            v.nameLabel:setString(lang("SIEGEWEAPONT_"..configData[1]))
			v.valueLabel:setPositionX(v.nameLabel:getPositionX() + v.nameLabel:getContentSize().width + 10)
            v.valueLabel:setString(string.format( "+%s", configData[2] + (tbItemData.lvl-1)*configData[3]) )
			v.descLabel:setString(string.format("(成长:+%s)", configData[3]))
			v.descLabel:setPositionX(170)
        end
        v.nameLabel:setVisible(configData~=nil)
		v.valueLabel:setVisible(configData~=nil)
    end
	local limitLvl = {5, 10, 15}
	for i=1, 3 do
		local descText = lang("SIEGEWEAPONT_"..tbItemData["percent"..i][1])
		if tbItemData.lvl>=limitLvl[i] then
			self._percentLabel[i]:setTextColor(cc.c4b(138, 92, 29, 255))
			self._percentLabel[i]:setString(string.format("%s +%s%%", descText, tbItemData["percent"..i][2]))
		else
			self._percentLabel[i]:setTextColor(cc.c4b(120, 120, 120, 255))
			self._percentLabel[i]:setString(string.format("%s +%s%% (配件%d级激活)", descText, tbItemData["percent"..i][2], limitLvl[i]))
		end
	end--]]

    local bagInfo = self._bagInfo
    local itemNameLabel = bagInfo:getChildByFullName("itemName")
    itemNameLabel:setFontName(UIUtils.ttfName)
    if OS_IS_WINDOWS then
        itemNameLabel:setString(lang(tbItemData.name) .. "\n[" .. tbItemData.id .. "]")
    else
        itemNameLabel:setString(lang(tbItemData.name))
    end
--	local bgColor = ItemUtils.findResIconColor(tbItemData.id) --tab.tool[data.goodsId].color
    self._nameBg:loadTexture("globalImageUI12_tquality".. tbItemData.quality_show ..".png",1)
    local itemIcon = bagInfo:getChildByFullName("iconNode")
    itemIcon:removeAllChildren()
    local iconNode = IconUtils:createWeaponsBagItemIcon({itemId = tbItemData.id, tagShow = false, itemData = tbItemData, eventStyle = 0, effect = true})
    iconNode:setPosition(-2, 0)
    itemIcon:addChild(iconNode)

    if self._powerLabel then
        self._powerLabel:setString(string.format("%d", data.score))
    else
        local infoBg = self._itemInfoBg
        local zhandouli1 = cc.Label:createWithTTF("战斗力", UIUtils.ttfName, 20)
        zhandouli1:setAnchorPoint(1, 0.5)
        zhandouli1:setColor(cc.c3b(255, 238, 160))
        zhandouli1:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
        zhandouli1:setPosition(cc.p(infoBg:getContentSize().width/2-5, infoBg:getContentSize().height/2-20))
        zhandouli1:setName("zhandouli1")
        infoBg:addChild(zhandouli1)

        self._powerLabel = cc.LabelBMFont:create(string.format("%d", data.score), UIUtils.bmfName_zhandouli_little)
        self._powerLabel:setName("powerLabel")
        self._powerLabel:setScale(0.5)
        self._powerLabel:setAnchorPoint(0, 0.5)
        self._powerLabel:setPosition(cc.p(infoBg:getContentSize().width/2, infoBg:getContentSize().height/2-15))
        infoBg:addChild(self._powerLabel)
    end
end

function WeaponsToolsBagView:reloadScrollAttrData(tbItemData)
	local scroll = self._attrScrollView
	scroll:removeAllChildren(true)
	local tbAttr = tbItemData.intproperty
	local valueStr = ""
	for i,v in ipairs(tbItemData.intproperty) do
		local configData = tbItemData.intproperty[i]
		local attrName = lang("SIEGEWEAPONT_"..configData[1])
		local attrNum = configData[2] + (tbItemData.lvl-1)*configData[3]
		valueStr = valueStr .. "[color=3c2a1e,fontsize=20]" .. attrName .. "+" .. attrNum .."[-]"
			.. "[color=1ca216,fontsize=20](成长+".. (v[2] or 0) ..")[-]" .."[][-]"
	end
	local needLvls = tab.setting["SIEGE_EQUIP_LV"] and tab.setting["SIEGE_EQUIP_LV"].value
	local attrStr = ""
	for i=1,6 do
		local percent = tbItemData["percent" .. i]
		if percent then
			local attrName = lang("SIEGEWEAPONTS_"..percent[1])
			local attrNum = (percent[2] or 0) .. "%"
			local isOpen = tbItemData.lvl >= needLvls[i]
			local color = isOpen and "3c2a1e" or "646464"
			local tail = isOpen and "" or "[color=".. color ..",fontsize=16](配件" .. needLvls[i] .."级激活)[-]" 
			attrStr = attrStr .. "[color=".. color ..",fontsize=20]" .. attrName .. "+" .. attrNum.. "[-]" .. tail .."[][-]"
		end
	end
	
	local valueText = RichTextFactory:create(valueStr, scroll:getContentSize().width, scroll:getContentSize().height)
	valueText:formatText()
    local width = valueText:getInnerSize().width
    local height = valueText:getInnerSize().height
    valueText:setPosition(cc.p(width/2,-height/2))
    UIUtils:alignRichText(valueText,{vAlign = "bottom",hAlign = "left"})
    valueText:setName("valueText")
    scroll:addChild(valueText)
	
	local attrText = RichTextFactory:create(attrStr, scroll:getContentSize().width, scroll:getContentSize().height)
	attrText:formatText()
    local w = attrText:getInnerSize().width
    local h = attrText:getInnerSize().height
    attrText:setPosition(cc.p(w/2,-height/2-h/2))
    UIUtils:alignRichText(attrText,{vAlign = "bottom",hAlign = "left"})
    attrText:setName("attrText")
    scroll:addChild(attrText)
	
	
    scroll:setInnerContainerSize(cc.size(scroll:getContentSize().width,  height+h+8))
	valueText:setPosition(width/2, scroll:getInnerContainerSize().height-height/2)
    attrText:setPosition(w/2, scroll:getInnerContainerSize().height-height-8-h/2)
	
	scroll:jumpToTop()
	if scroll:getInnerContainerSize().height>scroll:getContentSize().height then
		self._attrScrollAnim:setVisible(true)
	end
end

-- 设置 bagInfo上的显示 用于替换setVisible方法
function WeaponsToolsBagView:setBagInfoNodesVisible( isClear )
    local children = self._bagInfo:getChildren()
    for i,v in ipairs(children) do
        v:setVisible(isClear)
    end
    -- 放在循环外单独设置，提高缓存命中率
    local decoratePanel = self._bagInfo:getChildByName("decoratePanel")
    if decoratePanel then 
        decoratePanel:setVisible(true)
    end
end

function WeaponsToolsBagView:refreshTabData(name)
    local data = {}
    if name == "tab_all" then
        data = self._weaponsModel:getNewPropsData()
    elseif name == "tab_material" then
        data = self._weaponsModel:getPropsDataByType({1})
    elseif name == "tab_storm" then
        data = self._weaponsModel:getPropsDataByType({2})
    elseif name == "tab_drive" then
        data = self._weaponsModel:getPropsDataByType({3})
	elseif name == "tab_measure" then
		data = self._weaponsModel:getPropsDataByType({4})
	elseif name == "tab_magic" then
		data = self._weaponsModel:getPropsDataByType({5})
    end
    self._tabName = name
	
	
	for k,v in pairs(data) do
		if self._useProps[v.key] then
			v.onEquit = self._useProps[v.key]
		else
			v.onEquit = 0
		end
	end
	table.sort(data, sortFunc)
    self:reflashUI(data)
    return data
end

function WeaponsToolsBagView:addTableView()
    self._tableNode = self:getUI("bg.layer.itemInfo.tableNode")
    local tableView = cc.TableView:create(cc.size(420, 415))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,8)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -12, 6)
    self._tableView = tableView
    self._inScrolling = false
end

function WeaponsToolsBagView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    -- if self._inScrolling then
        self._tableOffset = view:getContentOffset()
    -- end
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function WeaponsToolsBagView:scrollViewDidZoom(view)

end

function WeaponsToolsBagView:tableCellTouched(table,cell)

end

function WeaponsToolsBagView:cellSizeForTable(table,idx)
    return 102,428
end

function WeaponsToolsBagView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    -- cell:removeAllChildren()
    local row = idx*4
    for i=0,3 do
        local item = cell:getChildByName("cellItem".. i)
        local isNewCreateItem = true
		local itemData = self._tableData[i+row+1]
        if i+row+1>#self._tableData then
            if item then
                item:removeFromParent()
            end
            item = self:createGrid()
            item._isGrid = true
        else
            if item and item._isGrid then
                item:removeFromParent()
                item = nil
            end
            if not item then
                item = self:createItem(itemData)
                item._key = itemData.key--i+row+1
            else
                isNewCreateItem = false
                item = self:createItem(itemData, item)
                item._key = itemData.key--i+row+1
            end
            item._indexNum = i+row+1
            item._isGrid = false
        end
        -- item:setScale(0.95)
        if self._none then
            item:setVisible(false)
        end
        item:setPosition(i*100+55,52)
        item:setName("cellItem".. i)
        item._itemName = "cellItem".. i
        if isNewCreateItem then
            cell:addChild(item)
        end
        if self._selectedItem and itemData and self._selectedItem.key == itemData.key then
            if not item:getChildByFullName("select") then
                self._selectedItemIcon = self._selFrame:clone()
                self._selectedItemIcon:setName("select")
                local mc1 = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
                if mc1 then
                    mc1:setName("anim")
                    mc1:setPosition(64, 61)
                    mc1:setScale(0.95)
                    self._selectedItemIcon:addChild(mc1, 1)
                    self._selectedItemIcon:setOpacity(0)
                end
                self._selectedItemIcon:setVisible(true)
                item:addChild(self._selectedItemIcon,7)
            else
                item:getChildByFullName("select"):setVisible(true)
            end
        else
            if item:getChildByFullName("select") then
                item:getChildByFullName("select"):removeFromParent()
            end
        end
    end 
    return cell
end

function WeaponsToolsBagView:numberOfCellsInTableView(table)
   local itemRow = math.ceil(#self._tableData/4)
    if itemRow < 4 then
        itemRow = 4
    end
    return itemRow
end

function WeaponsToolsBagView:createGrid( )
    local bagGrid = ccui.Widget:create()
    bagGrid:setContentSize(cc.size(98,98))
    bagGrid:setAnchorPoint(0.5,0.5)
    local bagGridFrame = ccui.ImageView:create()
    bagGridFrame:loadTexture("globalImageUI4_squality1.png", 1)
    bagGridFrame:setName("bagGridFrame")
    bagGridFrame:setContentSize(cc.size(107, 107))
    bagGridFrame:setAnchorPoint(0,0)
    bagGridFrame:setPosition(3,3)
    bagGrid:addChild(bagGridFrame,1)
    local bagGridBg = ccui.ImageView:create()
    bagGridBg:loadTexture("globalImageUI4_itemBg1.png", 1)
    bagGridBg:setName("bagGridBg")
    bagGridBg:ignoreContentAdaptWithSize(false)
    bagGridBg:setContentSize(cc.size(85, 85))
    bagGridBg:setAnchorPoint(0.5,0.5)
    -- bagGridBg
    bagGridBg:setPosition(47,47)
    bagGrid:addChild(bagGridBg,-1)
    -- 缩放
    bagGrid:setScale(1.02)
    return bagGrid
end

function WeaponsToolsBagView:createItem(data,dirtItem)
    local itemData = tab.siegeEquip[data.id]
    itemData.lvl = data.lv
    itemData.score = data.score
    local item
    local function itemCallback( )
        if not self._inScrolling then
            self:touchItemEnd(data,item)
        else
            self._inScrolling = false
        end
    end
	local isInUse = self._useProps[data.key]
    if not dirtItem then
        item = IconUtils:createWeaponsBagItemIcon({itemId = itemData.id, isInUse = isInUse, tagShow = true, itemData = itemData, effect = true, eventStyle = 3, clickCallback = itemCallback})
    else
        item = dirtItem
        item:stopAllActions()
        IconUtils:updateWeaponsBagItemIcon(item, {itemId = itemData.id, isInUse = isInUse, tagShow = true, itemData = itemData, effect = true, eventStyle = 3, clickCallback = itemCallback})
    end
    item:setScale(93/item:getContentSize().width)   -- 暂时处理
    item:setVisible(true)
    item:setSwallowTouches(false)
    item:setAnchorPoint(0.5,0.5)
    return item
end

function WeaponsToolsBagView:tabButtonState(sender, isSelected,isDisabled)
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
end

function WeaponsToolsBagView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Physcal","Gold","SiegePropExp"}, title = "globalTitleUI_bag.png",titleTxt = "配件库"})
end

function WeaponsToolsBagView:reflashWeaponsBagView()
	self._useProps = self._weaponsModel:getUsePropsIdData()
	self:refreshTabData(self._tabName)
	self:reorderTabs()
end

function WeaponsToolsBagView:reflashUI(data)
    self._tableData = data
    self._tableView:reloadData()
    self._countLabel:setString(string.format("%d/%d", #self._tableData, self._maxCount))
	local strColor = #self._tableData<self._maxCount and cc.c4b(138, 92, 29, 255) or cc.c4b(255, 0, 0, 255)
	self._countLabel:setTextColor(strColor)
end

return WeaponsToolsBagView