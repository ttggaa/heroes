--[[
    Filename:    PurgatoryCareerDialog.lua
    Author:      <yuxiaojing@playcrab.com>
    Datetime:    2018-03-02 14:14:54
    Description: File description
--]]

local PurgatoryCareerDialog = class("PurgatoryCareerDialog", BasePopView)

function PurgatoryCareerDialog:ctor()
    self.super.ctor(self)
end

function PurgatoryCareerDialog:onInit()
	self._purModel = self._modelMgr:getModel("PurgatoryModel")
	self._careerStageId, self._careerList = self._purModel:getCareerInfo()

	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("purgatory.PurgatoryCareerDialog")
    end)
    UIUtils:setTitleFormat(self:getUI("bg.titleBg.title"), 1)
    self:getUI("bg"):setOpacity(255)
	self:getUI("bg"):setBackGroundImageOpacity(255)

	self._item = self:getUI("bg.item")
	self._scrollView = self:getUI("bg.bg2.awardScroll")
	self._tableNode = self:getUI("bg.tableNode")
	self._noAward_txt = self:getUI("bg.bg2.noAward_txt")
	self._rank = self:getUI("bg.bg2.rankNum")

	self._noAward_txt:setFontName(UIUtils.ttfName)
	self._rank:setString(self._careerStageId)

	self._item:setVisible(false)

	self._tableCellW, self._tableCellH = self._item:getContentSize().width,self._item:getContentSize().height+4

	self._careerCfg = clone(tab.purAccuReward)

	local canGetI = 9999
	local noCanGetI = 9999
	for k, v in pairs(self._careerCfg) do
		local isGetReward = self._careerList[tostring(v.id)]
		local floorNum = v.floor
		if floorNum > self._careerStageId then
			if noCanGetI > v.id then
				noCanGetI = v.id
			end
		else
			if not isGetReward then
				if canGetI > v.id then
					canGetI = v.id
				end
			end
		end
	end
	if canGetI == 9999 then
		canGetI = noCanGetI
	end

	self:addTableView()
	self:updateGetAwardView()

	local maxOffsetY = #self._careerCfg * self._tableCellH - self._tableNode:getContentSize().height + 20
	local offsetY = maxOffsetY - (canGetI - 1) * self._tableCellH + self._tableNode:getContentSize().height / 2 - self._tableCellH / 2
	print(offsetY)
	if offsetY > maxOffsetY then
		offsetY = maxOffsetY
	end

	if offsetY < 0 then
		offsetY = 0
	end

	self._tableView:setContentOffset(cc.p(0, -(offsetY)))
end

function PurgatoryCareerDialog:addTableView()
    local tableView = cc.TableView:create(cc.size(self._tableNode:getContentSize().width, self._tableNode:getContentSize().height - 20))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(5, 12))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    tableView:setName("tableView")
    self._tableNode:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)

    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)

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

function PurgatoryCareerDialog:scrollViewDidScroll(view)
end

function PurgatoryCareerDialog:scrollViewDidZoom(view)
end

function PurgatoryCareerDialog:tableCellTouched(table,cell)
end

function PurgatoryCareerDialog:cellSizeForTable(table,idx) 
    return self._tableCellH, self._tableCellW
end

function PurgatoryCareerDialog:numberOfCellsInTableView(table)
   return #self._careerCfg
end

function PurgatoryCareerDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local item = self:createItem(self._careerCfg[idx + 1])
    if item then
	    item:setPosition(cc.p(8, 0))
	    item:setAnchorPoint(cc.p(0, 0))
	    item:setName("cellItem")
	    cell:addChild(item)
	end
	if idx == 0 then 
        cell:setName("guidCell")
    else
        cell:setName("commonCell")
    end
    return cell
end

function PurgatoryCareerDialog:createItem( data, idx )
	if data == nil then return end

	local item = self._item:clone()
	item:setVisible(true)
	item:setSwallowTouches(false)
	item.data = data

	local floorNum = data.floor

	--reward
	local itemIcon = item:getChildByFullName('itemIcon')
	local reward = data.reward or {}
	for i, v in ipairs(reward) do
		local scale = 1
		local itemType = v[1]
		local itemId = v[2]
		if itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            local param = {itemId = itemId, itemData = frameData}
            icon = IconUtils:createHeadFrameIconById(param)
            scale = 0.65
        elseif itemType == "rune" then
			local param = {suitData = tab.rune[itemId]}
			icon = IconUtils:createHolyIconById(param)
			local numLab =  ccui.Text:create()
			numLab:setString(v[3])
			numLab:setName("numLab")
			numLab:setFontSize(20)

			numLab:setFontName(UIUtils.ttfName)
			numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
			numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
			numLab:setAnchorPoint(1, 0)
			local iconColor = icon:getChildByName("iconColor")
			if iconColor then
				numLab:setPosition(iconColor:getContentSize().width - 10, 5)
				iconColor:addChild(numLab, 10)
			end
			scale = 0.75
		else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            scale = 0.75
            icon = IconUtils:createItemIconById({itemId = itemId, num = v[3],eventStyle = eventStyle})
        end
		icon:setScale(scale)
		itemIcon:setSwallowTouches(false)
		icon:setPosition(cc.p((i - 1) * 78 + 12, 0))
		if itemType=="rune" then
			icon:setPositionY(icon:getPositionY()-3)
		end
		itemIcon:addChild(icon)
	end

	local itemNameRank = item:getChildByFullName('itemNameRank')
	itemNameRank:setString(floorNum)
	local itemName1 = item:getChildByFullName('itemName1')
	itemName1:setPositionX(itemNameRank:getPositionX() + itemNameRank:getContentSize().width)
	itemName1:setString('层')

	--button status
	local getImg = item:getChildByFullName('getImg')
	local rewardBtn = item:getChildByFullName('exchangeBtn')
	local bgImage = item:getChildByFullName("bgImage")
	self:L10N_Text(rewardBtn)

	getImg:setVisible(false)
	rewardBtn:setVisible(false)

	local isGetReward = self._careerList[tostring(data.id)]
	local bgName
	if isGetReward then
		bgName = "globalPanelUI7_cellBg22.png"
	end
	if bgName then
		bgImage:loadTexture(bgName, 1)
	end

	if floorNum > self._careerStageId then
		rewardBtn:setVisible(true)
		UIUtils:setGray(rewardBtn, true)
	else
		if isGetReward then
			getImg:setVisible(true)
		else
			rewardBtn:setVisible(true)
			self:registerClickEvent(rewardBtn, function (  )
				self._serverMgr:sendMsg("PurgatoryServer", "getAccStageReward", {rewardId = data.id}, true, {}, function ( result )
			        DialogUtils.showGiftGet({gifts = result.reward})
			        rewardBtn:setVisible(false)
			        getImg:setVisible(true)
			        bgImage:loadTexture("globalPanelUI7_cellBg22.png", 1)
					self._careerStageId, self._careerList = self._purModel:getCareerInfo()
			        self:updateGetAwardView()
			    end, function ( errorId )
			        errorId = tonumber(errorId)
			        print("errorId:" .. errorId)
			    end)
			end)
		end
	end

	--friend
	local friendPanel = item:getChildByFullName("friendPanel")
	local noFriendsImg = item:getChildByFullName("friendPanel.nothing")
	local friendBg = item:getChildByFullName("friendPanel.friendBg")
	noFriendsImg:setVisible(false)
	friendBg:setVisible(false)

	friendPanel:setSwallowTouches(false)
	friendBg:setSwallowTouches(false)

	local friendList = self._purModel:getFriendDataByFloor(floorNum)
	if #friendList <= 0 then
		noFriendsImg:setVisible(true)
	else
		friendBg:setVisible(true)
		local rr = GRandom(1, #friendList)
		local friendData = friendList[rr]
		local headIcon = friendBg:getChildByFullName("headIcon")
		headIcon:setSwallowTouches(false)
	    if headIcon then
	        local param1 = {url = friendData.picUrl,openid = friendData.openid or 1,tp = 4}
	        local icon = headIcon:getChildByName("icon")
	        if not icon then
	            icon = IconUtils:createUrlHeadIconById(param1)
	            icon:setScale(0.5)
	            icon:setName("icon")
	            icon:setPosition(cc.p(4, 0))
	            headIcon:addChild(icon)
	        else
	            IconUtils:updateUrlHeadIconByView(icon, param1)
	        end
	    end

    	local nameTxt = friendBg:getChildByFullName("nameTxt")
    	nameTxt:setString(friendData.nickName)

		local friendNumLab = friendBg:getChildByFullName("dexTxt")
		friendNumLab:setTextHorizontalAlignment(1)

		friendNumLab:setString("您有" .. #friendList  .. "个好友在此")
	end

	return item
end

function PurgatoryCareerDialog:mergeGetData(getAward)
	if getAward == nil then return end
	if #self._awardGet == 0 then
		table.insert(self._awardGet, getAward)
	else
		for i,v in ipairs(self._awardGet) do
			if v[1] == getAward[1] and v[2] == getAward[2] then
				v[3] = tonumber(getAward[3]) + tonumber(v[3])
				break
			end				
			if i == #self._awardGet then
				table.insert(self._awardGet, getAward)
				break
			end
		end	
	end	
end

function PurgatoryCareerDialog:updateGetAwardView(  )
	self._awardGet = {}
	local purCfg = tab.purAccuReward
	for k, v in pairs(self._careerList) do
		if v then
			local rewardArr = purCfg[tonumber(k)].reward
			for k1, v1 in pairs(rewardArr) do
				local t = {v1[1], v1[2] ,v1[3]}
				self:mergeGetData(t)
			end
		end
	end
	--UI
	if not self._awardGet or #self._awardGet == 0 then
		self._noAward_txt:setVisible(true)
	else
		self._noAward_txt:setVisible(false)
	end
	self._scrollView:removeAllChildren()
	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, self._scrollView:getContentSize().height))
	for k, v in pairs(self._awardGet) do
		local itemType = v[1]
		local itemId = v[2]
		local scale = 1
		if itemType == "avatarFrame" then
            local frameData = tab:AvatarFrame(itemId)
            local param = {itemId = itemId, itemData = frameData}
            icon = IconUtils:createHeadFrameIconById(param)
            scale = 0.55
        elseif itemType == "rune" then
			local param = {suitData = tab.rune[itemId]}
			icon = IconUtils:createHolyIconById(param)
			
			local numLab =  ccui.Text:create()
			numLab:setString(v[3])
			numLab:setName("numLab")
			numLab:setFontSize(20)

			numLab:setFontName(UIUtils.ttfName)
			numLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
			numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
			numLab:setAnchorPoint(1, 0)
			local iconColor = icon:getChildByName("iconColor")
			if iconColor then
				numLab:setPosition(iconColor:getContentSize().width - 10, 5)
				iconColor:addChild(numLab, 10)
			end
			scale = 0.65
		else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            scale = 0.65
            icon = IconUtils:createItemIconById({itemId = itemId, num = v[3],eventStyle = eventStyle})
        end
		icon:setScale(scale)
		icon:setPosition(cc.p((k - 1) * 68, 0))
		if itemType=="rune" then
			icon:setPositionY(icon:getPositionY()-3)
		end
	    self._scrollView:addChild(icon)
	end
end

function PurgatoryCareerDialog:onDestroy()
	self.super.onDestroy(self)
end

function PurgatoryCareerDialog:getAsyncRes( )
    return {
        {"asset/ui/arena.plist", "asset/ui/arena.png"}
    }
end

return PurgatoryCareerDialog