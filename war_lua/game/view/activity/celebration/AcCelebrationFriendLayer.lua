--
-- Author: huangguofang
-- Date: 2017-07-06 15:27:07
--

local AcCelebrationFriendLayer = class("AcCelebrationFriendLayer", require("game.view.activity.common.ActivityCommonLayer"))

function AcCelebrationFriendLayer:ctor(param)
    self.super.ctor(self)
    self._serverData = param.data or {}
    self._celebrationModel = self._modelMgr:getModel("CelebrationModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function AcCelebrationFriendLayer:onInit()
    self.super.onInit(self)
    
    self._friendNum = self._serverData.friendNum or 0
    self._isHaveGuild = self._serverData.friendNum and (self._serverData.joinGuild == 1) or false
    local receiveGift = self._serverData.receiveGift 
    if receiveGift then
    	self._receiveGift = json.decode(receiveGift)
    end
    if not self._receiveGift then
    	self._receiveGift = {}
    end
    self._bg = self:getUI("bg")
    
    -- 活动时间
    local starTime ,endTime = self._celebrationModel:getCelebrationTime()
    local currTime = self._userModel:getCurServerTime()
    local time = tonumber(endTime) - tonumber(currTime)
    local timeStr = TimeUtils.getTimeStringFont1(time)

    local activity_date = self:getUI("bg.activity_date")
    activity_date:setString(timeStr)
    if currTime >= endTime then
		activity_date:setString("0天00:00:00")
	else
		local repeatAction = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
	    	local currTime = self._userModel:getCurServerTime()
	    	local time = tonumber(endTime) - tonumber(currTime)
    		local timeStr = TimeUtils.getTimeStringFont1(time)
	    	activity_date:setString(timeStr)
	    	if currTime >= endTime then
	    		activity_date:setString("0天00:00:00")
	    		activity_date:stopAllActions()
	    	end
	    end)))
		activity_date:runAction(repeatAction)
	end

    self._friendData = clone(tab.celebrationFriend)
    self:initFriendData()
    self._cellW = 630
	self._cellH = 120
    self:addFriendTableView()

end

function AcCelebrationFriendLayer:initFriendData()
	if not self._friendData then return end
	local canGetData = {}
	local allGetData = {}
	local otherData = {}
	local data = {}
	-- dump(self._friendData,"friendData==>",5)
	-- dump(self._receiveGift,"self._receiveGift==>",5)
	for k,v in pairs(self._friendData) do
		if self._receiveGift[tostring(v.id)] then
			v.state = self._receiveGift[tostring(v.id)]
		else
			v.state = -1
		end

		if v.state == 0 then
			table.insert(canGetData, v)
		elseif v.state == 1 then
			table.insert(allGetData, v)
		else
			-- -1
			table.insert(otherData, v)
		end

	end

	if table.nums(canGetData) >= 2 then
		table.sort(canGetData,function ( a,b )
            return a.id < b.id
        end)
	end

	if table.nums(allGetData) >= 2 then
		table.sort(allGetData,function ( a,b )
            return a.id < b.id
        end)
	end

	if table.nums(otherData) >= 2 then
		table.sort(otherData,function ( a,b )
            return a.id < b.id
        end)
	end	

	for k,v in ipairs(canGetData) do
		table.insert(data, v)
	end

	for k,v in ipairs(otherData) do
		table.insert(data, v)
	end

	for k,v in ipairs(allGetData) do
		table.insert(data, v)
	end

	self._friendData = data
end

function AcCelebrationFriendLayer:addFriendTableView()
	if not self._friendData then return end
	local listBg = self:getUI("bg.listBg")
	if self._friendList ~= nil then 
        self._friendList:removeFromParent()
        self._friendList = nil
    end
    self._friendList = cc.TableView:create(cc.size(listBg:getContentSize().width, listBg:getContentSize().height - 16))
    self._friendList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._friendList:setPosition(cc.p(9, 10))
    self._friendList:setDelegate()
    self._friendList:setBounceable(true)
    self._friendList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._friendList:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._friendList:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._friendList:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    self._friendList:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._friendList:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    self._friendList:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._friendList:reloadData()
    listBg:addChild(self._friendList)
end

function AcCelebrationFriendLayer:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()	
end

function AcCelebrationFriendLayer:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AcCelebrationFriendLayer:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function AcCelebrationFriendLayer:cellSizeForTable(table,idx) 
    return self._cellH + 3,self._cellW
end

function AcCelebrationFriendLayer:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
	local cellData = self._friendData[idx+1]

    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local item = self:createExchangeCell(cellData,idx+1)
    item:setPosition(0,0)
    item:setName("cellItem")
    item:setAnchorPoint(0,0)
    cell:addChild(item)

    return cell
end
function AcCelebrationFriendLayer:numberOfCellsInTableView(table)
	return #self._friendData
end

function AcCelebrationFriendLayer:createExchangeCell(cellData,idx)
	--名片区域
	local layout = ccui.Widget:create()  
	layout = ccui.Widget:create()  
	layout:setContentSize(cc.size(self._cellW, self._cellH)) --233/98
	layout:setAnchorPoint(cc.p(0.5, 0.5))

	--背景
	local bgImg = ccui.ImageView:create()
	bgImg:setScale9Enabled(true)
	bgImg:setCapInsets(cc.rect(25, 25, 1, 1))
	bgImg:setContentSize(cc.size(self._cellW, self._cellH))
	bgImg:ignoreContentAdaptWithSize(false)
	bgImg:setPosition(self._cellW*0.5, self._cellH*0.5)
	layout:addChild(bgImg)

	local bgImgName = "globalPanelUI_activity_cellBg.png"
	if cellData.state then
		if cellData.state == 0 then
			bgImgName = "globalPanelUI_activity_cellBg.png"
		elseif cellData.state == -1 then
			bgImgName = "globalPanelUI_activity_cellBg1.png"
		else
			bgImgName = "globalPanelUI_activity_cellBg2.png"
		end
	end
	bgImg:loadTexture(bgImgName,1)
	
	local itemW = 80
	local rewardData = cellData.rewards or {}
	for k,v in pairs(rewardData) do
		local toolData = v
		local itemId = toolData[2]
		if itemId then
			if toolData[1] ~= "tool" then
				itemId = IconUtils.iconIdMap[toolData[1]]
			end
			local toolD = tab:Tool(tonumber(itemId))
			if toolD then
				icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = toolData[3]})
				icon:setScale(0.75)
				icon:setPosition(10+(k-1)*itemW,9)
				layout:addChild(icon,1)
			end
		end
	end

	-- titleBg
	local titleBg = ccui.ImageView:create()
	titleBg:loadTexture("celebration_friend_cellTitleBg.png",1)
	titleBg:setScale9Enabled(true)
	titleBg:setCapInsets(cc.rect(1, 1, 1, 1))
	titleBg:setContentSize(cc.size(180, 37))
	titleBg:ignoreContentAdaptWithSize(false)
	titleBg:setAnchorPoint(0,0.5)
	titleBg:setPosition(0, 97)
	layout:addChild(titleBg)
	
	-- 名字
	local titleLab = ccui.Text:create()
	titleLab:setFontName(UIUtils.ttfName)
	titleLab:setString("加入一个联盟")
	-- titleLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	titleLab:setFontSize(20)
	titleLab:setAnchorPoint(cc.p(0,0.5))
	titleLab:setPosition(10, 97)
	layout:addChild(titleLab, 1)

	if cellData.condition == 1 then

		titleLab:setString("拥有" .. cellData.num .. "个好友")
		-- 条件bg
		local btnTitleBg = ccui.ImageView:create()
		btnTitleBg:loadTexture("globalPanelUI12_btnTitleBg.png", 1)
		-- btnTitleBg:setAnchorPoint(cc.p(0.5,0.5))
		btnTitleBg:setPosition(cc.p(self._cellW - 90, 75))
		layout:addChild(btnTitleBg,1)

		-- 条件
		local conditionTxt = ccui.Text:create()
		conditionTxt:setString(self._friendNum .. "/" .. (cellData.num or 0))
		conditionTxt:setFontName(UIUtils.ttfName)
		conditionTxt:setColor((cellData.state == 0) and UIUtils.colorTable.ccUIBaseColor9 or UIUtils.colorTable.ccUITabColor1)
		conditionTxt:setFontSize(20)
		conditionTxt:setAnchorPoint(cc.p(0.5,0))
		conditionTxt:setPosition(self._cellW - 90, 70)
		layout:addChild(conditionTxt, 2)
		btnTitleBg:setVisible(cellData.state ~= 1)
		conditionTxt:setVisible(cellData.state ~= 1)
	end

	local posy = (cellData.condition == 1) and 45 or 50
	-- 领取按钮
	local btn = ccui.Button:create("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", 1)
    btn:setTitleFontName(UIUtils.ttfName)
    btn:setTitleText("领取")
    btn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    btn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2,1)
    btn:setTitleFontSize(22) 
    btn:setScale(0.9)
    btn:setPosition(self._cellW - 90, 45)
    layout:addChild(btn,2)
    btn:setVisible(cellData.state == 0)
    -- btn:setSaturation((cellData.state == 0) and 0 or -100)
    btn.__data = cellData
	registerClickEvent(btn, function(sender)
		if cellData.state == -1 then
			self._viewMgr:showTip("未达到领取条件")	
		else
       		self:getBtnClicked(sender.__data)
       	end
    end)
	-- 领取特效
	local effect = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    effect:setPosition(cc.p(btn:getContentSize().width*0.5, btn:getContentSize().height*0.5))
    btn.effect = effect
    btn:addChild(effect)
    btn.effect:setVisible(cellData.state == 0)

    -- 已领
	local getImg = ccui.ImageView:create()
	getImg:loadTexture("globalImageUI_activity_getItBlue.png",1)
	getImg:setPosition(cc.p(self._cellW - 90, self._cellH*0.5))
	layout:addChild(getImg)
	getImg:setVisible(cellData.state == 1)

	-- 前往按钮
	local goBtn = ccui.Button:create("globalButtonUI13_2_2.png", "globalButtonUI13_2_2.png", "globalButtonUI13_2_2.png", 1)
    goBtn:setTitleFontName(UIUtils.ttfName)
    goBtn:setTitleText("前往")
    goBtn:setTitleColor(UIUtils.colorTable.ccUICommonBtnColor1)
    goBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine7,1)
    goBtn:setTitleFontSize(22) 
    goBtn:setScale(0.9)
    goBtn:setPosition(self._cellW - 90, 45)
    layout:addChild(goBtn,2)
    goBtn.__data = cellData
    goBtn:setVisible(cellData.state == -1)
	registerClickEvent(goBtn, function(sender)
		local isOpen = self._celebrationModel:isCelebrationEnd()
		if not isOpen then
			self._viewMgr:showTip("活动已结束")
			return 
		end
	
		local data = sender.__data
		local cond = cellData.condition or 1
		if self["jumpToView" .. cond] then
			self["jumpToView" .. cond](self,1)
		else
			print("==========跳转类型不存在===========")
		end
    end)

	return layout
	
end

function AcCelebrationFriendLayer:getBtnClicked(data)
	local isOpen = self._celebrationModel:isCelebrationEnd()
	if not isOpen then
		self._viewMgr:showTip("活动已结束")
		return 
	end

	local dataId = data and data.id
	if not dataId then return end
	self._serverMgr:sendMsg("ActivityServer", "receiveFriendCeleGift", {id=dataId}, true, {}, function(result,succ)
	    if result["reward"] then
        	DialogUtils.showGiftGet({gifts = result["reward"]})
        end
    end)

end

-- 好友
function AcCelebrationFriendLayer:jumpToView1()
	-- -- 
	local isOpen,_ = SystemUtils["enableGameFriend"]()
	if isOpen then
    	self._viewMgr:showView("friend.FriendView", {openType = "apply"})
    else
    	self._viewMgr:showTip("好友系统未开放")	
    end
end
-- 联盟
function AcCelebrationFriendLayer:jumpToView2()
	--
	local isOpen,_ = SystemUtils["enableGuild"]()
	if not isOpen then
    	self._viewMgr:showTip("联盟系统未开放")	
    	return
    end
	local userData = self._modelMgr:getModel("UserModel"):getData()
    if not userData.guildId or userData.guildId == 0 then
        self._viewMgr:showView("guild.join.GuildInView")
    else
        self._viewMgr:showView("guild.GuildView")
    end
end
function AcCelebrationFriendLayer:reflashUI()

	self._serverData = self._celebrationModel:getFriendCeleData()
	self._friendNum = self._serverData.friendNum or 0
    self._isHaveGuild = self._serverData.friendNum and (self._serverData.joinGuild == 1) or false
	local receiveGift = self._serverData.receiveGift 
    if receiveGift then
    	self._receiveGift = json.decode(receiveGift)
    end
    if not self._receiveGift then
    	self._receiveGift = {}
    end
	
	self:initFriendData()

	if self._friendList and self._friendData then
		self._friendList:reloadData()
	end
end
return AcCelebrationFriendLayer