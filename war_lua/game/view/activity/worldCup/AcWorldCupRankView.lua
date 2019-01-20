--[[
    Filename:    AcWorldCupRankView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-05-11 17:12
    Description: 竞猜排行界面
--]]

local AcWorldCupRankView = class("AcWorldCupRankView", BasePopView)

local sysGuessTeam = tab.guessTeam
local sysGuessBet = tab.guessBet
local titleTable = {
	[35] = {[1]="排名", [2]="角色名", [3]="竞猜胜场数", [4]="竞猜胜率", [5]="平均赔率"},   --个人
}
local payerShow = {50, 50}
local showTable = {
	[35] = {payerShow[1],payerShow[2]},    	--个人
}

-- 页签与item的对应关系
local itemIdx = {
	[35] = "1",    	--个人
}

local ids = {
	[1] = 35,
}

local rankImgs = {
	[1] = "firstImg",
	[2] = "secondImg",
	[3] = "thirdImg",
}

local rankImgName = {
	[1] = "arenaRank_first",
	[2] = "arenaRank_second",
	[3] = "arenaRank_third",
}

function AcWorldCupRankView:ctor(param)
	AcWorldCupRankView.super.ctor(self)
	self._rankModel = self._modelMgr:getModel("RankModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._worldCupModel = self._modelMgr:getModel("WorldCupModel")
	self._hPopModel = self._modelMgr:getModel("HappyPopModel")

	self._tabType = ""    --页签类型
	self._rankType = 35   --排行榜类型
end

function AcWorldCupRankView:onInit()
	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("activity.worldCup.AcWorldCupRankView")
        elseif eventType == "enter" then
            local rankTab = self:getUI("bg.rankTab")
            self:tabButtonClick(rankTab)
        end
    end)

	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		end)

	self:getUI("bg.bg1"):loadTexture("asset/bg/ac_worldCup_rankBg.png")

	
    local rankTab = self:getUI("bg.rankTab") -- 排行
    local rwdTab = self:getUI("bg.rwdTab")  -- 排行奖励
    self:registerClickEvent(rankTab, function(sender)self:tabButtonClick(sender) end)
    self:registerClickEvent(rwdTab, function(sender)self:tabButtonClick(sender) end)
    self._tabList = {}
    table.insert(self._tabList, rankTab)
    table.insert(self._tabList, rwdTab)

    ----------------------------排行榜
    self:getUI("bg.rankView.noMine"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:getUI("bg.rankView.leftBoard.name"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    for i=1,3 do
    	self:getUI("bg.rankView.leftBoard.num"..i):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    for i=1, 5 do
    	self:getUI("bg.rankView.mineBg.title"..i):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    self:initOriginView()

    self._itemData = nil
	self._bgPanel = self:getUI("bg.rankView")
	self._leftBoard = self:getUI("bg.rankView.leftBoard")

	self._mineItem = self:getUI("bg.rankView.mineBg")
	self._mineItem:setVisible(false)

	self._noRankBg = self:getUI("bg.rankView.noRankBg")
	self._noRankBg:setVisible(false)

	self._rankItem1 = self:getUI("bg.rankView.rankBg")
	self._rankItem1:setVisible(false)

    self._tableNode = self:getUI("bg.rankView.tableBg")
    self._tableCellW, self._tableCellH = self._rankItem1:getContentSize().width, self._rankItem1:getContentSize().height  

	-- 递进刷新控制
	self.beginIdx = { [35] = showTable[35][1]}
	self.addStep = { [35] = showTable[35][1]}
	self.endIdx = { [35] = showTable[35][2]}

	self._tableData = {}
    self._allRankData = self._rankModel:getRankList(self._rankType or 1)

end

function AcWorldCupRankView:tabButtonClick(sender)
	if not sender then
		return 
	end

	local tabName = sender:getName()
	local tabType = string.sub(tabName, 1, string.len(tabName) - 3)
	if tabType == self._tabType then
		return
	end
	self._tabType = tabType
	self:setBtnState(sender)

	local rankView = self:getUI("bg.rankView")
	local rwdView = self:getUI("bg.rwdView")
	rankView:setVisible(false)
	rwdView:setVisible(false)

	self[self._tabType .. "RefreshView"](self)
end

function AcWorldCupRankView:rwdRefreshView()
	local sysGuessReward = tab.guessReward
	local rwdView = self:getUI("bg.rwdView")
	rwdView:setVisible(true)

	self:getUI("bg.rwdView.des"):setString(lang(""))
	local cellTemp = self:getUI("bg.rwdView.rankBg")

	local scrollView = self:getUI("bg.rwdView.scrollv")
	scrollView:setBounceEnabled(true)
	scrollView:removeAllChildren()

	local maxWid, maxHei = 650, 297
	local innerHei = cellTemp:getContentSize().height * #sysGuessReward
	scrollView:setContentSize(cc.size(maxWid, maxHei))
	scrollView:setInnerContainerSize(cc.size(maxWid, innerHei))

	for i,v in ipairs(sysGuessReward) do
		local cell = self:getUI("bg.rwdView.rankBg"):clone()
		local hei = innerHei - cell:getContentSize().height * 0.5 - cell:getContentSize().height * (i - 1)
		cell:setPosition(0, hei)
		scrollView:addChild(cell)

		local rwdNode = cell:getChildByName("rwdNode")
		rwdNode:setPositionX(490)

		local a, b = math.modf(i / 2)
		if b ~= 0 then
			cell:loadTexture("globalImageUI6_meiyoutu.png", 1)
		end

		local rankNum = cell:getChildByFullName("rankNum")
		if v["rank"][1] == v["rank"][2] then
			rankNum:setString("第" .. v["rank"][1] .. "名")
		else
			rankNum:setString("第" .. v["rank"][1] .. "-" .. v["rank"][2] .. "名")
		end
		rankNum:setFontSize(18)
		rankNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

		local offsetX = 50
		for p,q in ipairs(v["reward"]) do
	        local costType = q[1]
	        local costNum = q[3]
	        local costId = IconUtils.iconIdMap[costType] or q[2]

	        local rwdData, rwdIcon
	        if costType == "tool" then
	        	rwdData = tab:Tool(tonumber(costId))
	        	local param = {itemId = costId, itemData = rwdData, num = costNum}
	        	rwdIcon = IconUtils:createItemIconById(param)
	        	rwdIcon:setScale(0.5)
	        	rwdIcon:setPosition(50 * (p-1), 2)

	        elseif costType == "avatarFrame" then
	        	rwdData = tab:AvatarFrame(costId)
	        	local param = {itemId = costId, itemData = rwdData}
	        	rwdIcon = IconUtils:createHeadFrameIconById(param)
	        	rwdIcon:setScale(0.4)
	        	rwdIcon:setPosition(50 * (p-1), 5)
	        end

            rwdNode:addChild(rwdIcon)
		end
	end
end

function AcWorldCupRankView:rankRefreshView()
	local rankView = self:getUI("bg.rankView")
	rankView:setVisible(true)

	self._tableNode:removeAllChildren()
	local tableBg = self:getUI("bg.rankView.tableBg")
	self._tableW, self._tableViewH = self._tableNode:getContentSize().width, self._tableNode:getContentSize().height
    self._tableView = cc.TableView:create(cc.size(self._tableW, self._tableViewH))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(0,0))
    self._tableView:setDelegate()
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableNode:addChild(self._tableView, 999)

    -- 如果正在发送请求(服务器还没有返回)，不能切换页签
	--self._loadingMc:isVisible() 说明正在滑动tableView，此时切换页签最上面会有留白
	if self._isSending or (self._loadingMc and self._loadingMc:isVisible()) then
		return
	end

	--切页停止滚动
	if self._tableView then
		self._tableView:stopScroll()
	end
	if self._loadingMc and self._loadingMc:isVisible() then
		self._loadingMc:setVisible(false)
	end

	self._allRankData = self._rankModel:getRankList(self._rankType)
	self._tableData = {}
	if #self._allRankData < 1 then
		--请求数据点击tab 回调reflashUI里刷新有无排行榜的显示以及数据的刷新
		self:sendGetRankMsg(self._rankType, 1)
		self._firstIn = true
	else
		self._firstIn = false
		self._tableData = self:updateTableData(self._allRankData) 
		self._tableView:reloadData()   --jumpToTop
		
		if self._tableData[1] then
			self:reflashNo1(self._tableData[1])
		end
		--不请求数据点击tab 刷新有无排行榜的显示
		self:reflashNoRankUI()		
	end

	if #self._tableData > 0 then
		self:reflashUserInfo()
	end

	self:reflashTitleName()		
end

-- 接收自定义消息
function AcWorldCupRankView:refreshUI(data)
	local offsetX = nil
	local offsetY = nil
	if self._offsetX and self._offsetY then
		offsetX = self._offsetX
		offsetY = self._offsetY
	end

    self._allRankData = self._rankModel:getRankList(self._rankType)
    self._tableData = self:updateTableData(self._allRankData)
    if self._tableData and self._tableView then    	
	    self._tableView:reloadData()
	    if offsetX and offsetY and not self._firstIn then
	    	self._tableView:setContentOffset(cc.p(offsetX,offsetY))
			self._canRequest = false
	    end	    
	    self._firstIn = false
	end
	--如果有数据则刷新自己信息
	if #self._tableData > 0 then
		self:reflashUserInfo()
	end
	if self._tableData then
		self:reflashNo1(self._tableData[1])
	end
end

function AcWorldCupRankView:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()

    local offsetY = view:getContentOffset().y   	
	if offsetY >= 60 and #self._tableData > 5 and #self._tableData < self.endIdx[self._rankType] and not self._canRequest then
		self._canRequest = true
		self:createLoadingMc()
		if not self._loadingMc:isVisible() then
			self._loadingMc:setVisible(true)
		end
	end	
		
    local condY = 0
    if self._tableData and #self._tableData < 4 then
    	-- tableView height 330
    	condY = self._tableViewH - #self._tableData*self._tableCellH
    end
	if self._inScrolling then
	    if offsetY >= condY+60 and not self._canRequest then
            self._canRequest = true
            self:createLoadingMc()
            if not self._loadingMc:isVisible() then
				self._loadingMc:setVisible(true)
			end
        end
        if offsetY < condY+20 and self._canRequest then
            self._canRequest = false
            self:createLoadingMc()
            if self._loadingMc:isVisible() then
				self._loadingMc:setVisible(false)
			end	
        end
	else
		-- 满足请求更多数据条件
		if self._canRequest and offsetY == condY then		
			self._viewMgr:lock(1)
			self:sendMessageAgain()
			self:createLoadingMc()
			if self._loadingMc:isVisible() then
				self._loadingMc:setVisible(false)
			end		
		end
	end
end

function AcWorldCupRankView:tableCellTouched(table,cell)

end

function AcWorldCupRankView:cellSizeForTable(table,idx)
	return self._tableCellH, self._tableCellW
end

function AcWorldCupRankView:tableCellAtIndex(table,idx)
	local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local cellData = self._tableData[idx+1]
	if not cell._item then
		local item = self._rankItem1:clone()
		item = self:createItem(item, cellData, idx)
		item:setPosition(0, 0)
		item:setAnchorPoint(cc.p(0,0))
		cell._item = item
		cell:addChild(item)
	else
		self:createItem(cell._item, cellData, idx)
	end

    return cell
end

function AcWorldCupRankView:numberOfCellsInTableView(table)
	return #self._tableData
end

function AcWorldCupRankView:createItem(item, cellData, idx)
	item:setVisible(true)
	local a, b = math.modf((idx+1) / 2)
	if b ~= 0 then
		item:loadTexture("globalImageUI6_meiyoutu.png", 1)
	else
		item:loadTexture("worldCup_rankBg2.png", 1)
	end

	local title1 = item:getChildByName("title1")
	title1:setString(str)

	local rankImg = item:getChildByName("rankImg")
	rankImg:setVisible(false)
	local title1 = item:getChildByName("title1")
	title1:setVisible(false)
	
	local rank = cellData["rank"] or 0
	if rank <= 3 then
		rankImg:setVisible(true)
		rankImg:loadTexture(rankImgName[rank] .. ".png", 1)
	else
		title1:setVisible(true)
		title1:setString(rank)
	end

	local title2 = item:getChildByName("title2")
	title2:setString(cellData["name"] or "玩家名字七个字")
	local title3 = item:getChildByName("title3")
	title3:setString(cellData["snum"] or 0)
	local title4 = item:getChildByName("title4")
	title4:setString((cellData["srate"] or "0") .. "%")
	local title5 = item:getChildByName("title5")
	title5:setString(cellData["odds"] or 0)

	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			self:itemClicked(cellData)			
        else
            self._inScrolling = false
        end
	end)
	item:setSwallowTouches(false)

	return item
end

--是否要刷新排行榜
function AcWorldCupRankView:sendMessageAgain()
	self._allRankData = self._rankModel:getRankList(self._rankType)
	local starNum = self._rankModel:getRankNextStart(self._rankType)
	local statCount = tonumber(self.beginIdx[self._rankType])
	local endCount = tonumber(self.endIdx[self._rankType])
	local addCount = tonumber(self.addStep[self._rankType])

	if #self._tableData == #self._allRankData and #self._allRankData%addCount == 0 and #self._allRankData < endCount then
		--如果本地没有更多数据则向服务器请求
		self._canRequest = false
		self:sendGetRankMsg(self._rankType,starNum,function()
			self._offsetX = 0
			self._offsetY = 0
			if #self._allRankData > statCount then
				self:searchForPosition(statCount,addCount,endCount)
			end
			self._viewMgr:unlock()
		end)
	else
		self._canRequest = false
		self._viewMgr:unlock()
	end
end

--刷新之后tableView 的定位
function AcWorldCupRankView:searchForPosition(statCount,addCount,endCount)
	self._offsetX = 0
	if statCount + addCount <= endCount then
		self.beginIdx[self._rankType] = statCount + addCount
		local subNum = #self._allRankData - statCount

		if subNum < addCount then
			self._offsetY = -1 * (tonumber(subNum) * self._tableCellH)			
		else
			self._offsetY = -1 * (tonumber(self.addStep[self._rankType]) * self._tableCellH)			
		end
	else
		self.beginIdx[self._rankType] = endCount
		self._offsetY = -1 * (endCount - statCount) * self._tableCellH
	end

	--一屏内 
	local tempH = #self._allRankData * self._tableCellH - self._tableViewH
	if tempH <= 0 or tempH < self._tableCellH * 0.5 then --差值小于1个cell高度
		self._offsetY = self._tableViewH - #self._allRankData * self._tableCellH
	end
end

--获取排行榜数据
function AcWorldCupRankView:sendGetRankMsg(tp,start,callback)
	self._isSending = true
	self._rankModel:setRankTypeAndStartNum(tp,start)
	local acId = self._worldCupModel:getAcData()
	self._serverMgr:sendMsg("RankServer", "getGuessRankList", {type = tp, startRank = start, id = acId._id}, true, {}, function(result) 
		if callback then
			callback()
		end
		self:refreshUI()
		self:reflashNoRankUI()
		self._isSending = false
    end)
end

function AcWorldCupRankView:updateTableData(rankList)
	local index = self.beginIdx[self._rankType]
	local data = {}
	for k,v in pairs(rankList) do
		if tonumber(v.rank) <= tonumber(index) then
			data[k] = v
		end
	end
	return data
end

function AcWorldCupRankView:initOriginView()
	self:getUI("bg.rankView.leftBoard.name"):setString("")
	self:getUI("bg.rankView.leftBoard.level"):setString("")
	self:getUI("bg.rankView.leftBoard.num1"):setString("")
	self:getUI("bg.rankView.leftBoard.num2"):setString("")
	self:getUI("bg.rankView.leftBoard.num3"):setString("")
end

function AcWorldCupRankView:createLoadingMc()
	if self._loadingMc then 
		return 
	end

	-- 添加加载中动画
	self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._bgPanel:getContentSize().width*0.5 - 30, self._tableNode:getPositionY() + 20))
    self._bgPanel:addChild(self._loadingMc, 20)
    self._loadingMc:setVisible(false)
end

function AcWorldCupRankView:reflashNoRankUI()
	if (not self._tableData or #self._tableData <= 0) then
		self._noRankBg:setVisible(true)
	else
		self._noRankBg:setVisible(false)
	end
end

function AcWorldCupRankView:reflashTitleName()
	local titleD = titleTable[self._rankType]
	for i=1, 5 do
		local title = self:getUI("bg.rankView.titleBg.title" ..  i)
		if titleD then
			title:setString(titleD[i] or "")
		end
	end
end

function AcWorldCupRankView:reflashUserInfo()
	local item = self._mineItem
	local rankData = self._rankModel:getSelfRankInfo(self._rankType)

	local sysData = tab.guessReward
	local upperNum = sysData[#sysData]["rank"][2]

	
	local noMine = self:getUI("bg.rankView.noMine")
	noMine:setVisible(false)
	item:setVisible(false)

	local rank = rankData.rank
	if not rank or rank > upperNum or rank == 0 or rank == "" then
		noMine:setVisible(true)
		return
	else
		item:setVisible(true)
		local myData = self._tableData[rank]
		local rankImg = item:getChildByName("rankImg")
		rankImg:setVisible(false)
		local title1 = item:getChildByName("title1")
		title1:setVisible(false)
		
		if rank <= 3 then
			rankImg:setVisible(true)
			rankImg:loadTexture(rankImgName[rank] .. ".png", 1)
		else
			title1:setVisible(true)
			title1:setString(rank)
		end

		local userName = self._userModel:getData().name
		local title2 = item:getChildByName("title2")
		title2:setString(userName or "")
		local title3 = item:getChildByName("title3")
		title3:setString(rankData["snum"] or 0)
		local title4 = item:getChildByName("title4")
		title4:setString((rankData["srate"] or 0) .. "%")
		local title5 = item:getChildByName("title5")
		title5:setString(rankData["odds"] or 0)
	end
end

function AcWorldCupRankView:reflashNo1( data )
	local name = self._leftBoard:getChildByFullName("name")
	local level = self._leftBoard:getChildByFullName("level")
	local num1 = self._leftBoard:getChildByFullName("num1")
	local num2 = self._leftBoard:getChildByFullName("num2")
	local num3 = self._leftBoard:getChildByFullName("num3")
	name:setString("暂无榜首")
	level:setString("")	
	num1:setString("")
	num2:setString("")
	num3:setString("")

	if not data then 
		return 
	end

	name:setString(data.name)
	local inParam = {lvlStr = "Lv." .. (data.level or data.lvl or 0), lvl = data.level or data.lvl, plvl = data.plvl}
	UIUtils:adjustLevelShow(level, inParam, 1)
	num1:setString(data["snum"] or 0)
	num2:setString((data["srate"] or "0") .. "%")
	num3:setString(data["odds"] or 0)

	--roleAnim
	local roleAnim = self._leftBoard._roleAnim
	if roleAnim then
		roleAnim:setVisible(false)
		roleAnim:removeFromParent()
	end

	-- 左侧人物形象
	local rolePanel = self._leftBoard:getChildByFullName("rolePanel")
	local heroId = data.fHeroId  or 60001
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    -- heroSkin  编租皮肤id 只跟左侧No.1信息有关
    if data.heroSkin then
        local heroSkinD = tab.heroSkin[data.heroSkin]
        heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or heroD["heroart"]
    end
    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._leftBoard:getContentSize().width*0.5, rolePanel:getPositionY())
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,1)

    --click
	self:registerClickEventByName("bg.rankView.leftBoard",function( )
		self:itemClicked(data)
	end)
end

function AcWorldCupRankView:itemClicked(data)
	if not data then 
		return 
	end

	self._param = {type=self._rankType, roleId=data.rid or data._id}
	self._itemData = data

	if data._id and data._id ~= 0 then
		self._clickItemData = self._itemData
		self:goView35()
	else
		print("=======数据异常-================")
	end
end

function AcWorldCupRankView:goView35()
	if not self._clickItemData then return end
	local fId = (self._clickItemData.lvl and  self._clickItemData.lvl >= 15) and 101 or 1
	self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = self._clickItemData.rid or self._clickItemData._id,fid=fId}, true, {}, function(result) 
		local data = result
		data.rank = self._clickItemData.rank
		data.usid = self._clickItemData.usid
		self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
    end)
end

function AcWorldCupRankView:setBtnState(inBtn)
	if self._tabList == nil or next(self._tabList) == nil then
        return
    end

    local btnName = {rankTab = "排行", rwdTab = "排行奖励"}
    for k,v in pairs(self._tabList) do
        v:setBright(true)
        v:setEnabled(true)
        v:setTitleText("")
        if v.title ~= nil then
            v.title:removeFromParent(true)
            v.title = nil
        end

        local btnTitle = ccui.Text:create()
        btnTitle:setFontName(UIUtils.ttfName)
        btnTitle:setFontSize(18)
        btnTitle:setColor(cc.c4b(79,127,172,255))
        btnTitle:setPosition(v:getContentSize().width * 0.5, v:getContentSize().height * 0.5)
        btnTitle:setString(btnName[v:getName()])
        v.title = btnTitle
        v:addChild(btnTitle)
    end
    
    if inBtn then
        inBtn:setBright(false)
        inBtn:setEnabled(false)
        inBtn.title:setFontSize(20)
        inBtn.title:setColor(cc.c4b(190,238,255,255))
    end
end



return AcWorldCupRankView