--
-- Author: huangguofang
-- Date: 2017-03-27 15:00:04
--

local payerShow = clone(tab:Setting("G_RANK_PLAYERS_SHOW").value)

local showTable = {
	[1] = {payerShow[1],payerShow[2]},    	--毒龙
	[2] = {payerShow[1],payerShow[2]},		--仙女龙
	[3] = {payerShow[1],payerShow[2]},		--水晶龙
}

local titleTxt = {
	[1] = "毒龙",    	--毒龙
	[2] = "仙女龙",		--仙女龙
	[3] = "水晶龙",		--水晶龙
}

local DragonRankDialog = class("DragonRankDialog",BasePopView)
function DragonRankDialog:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
	param = param or {}
	self._rankType = 12
	self._bossId = param.bossId or 1
	self._callBack = param.callback
	-- self._rankInitType = param.rankType or 1
    self._bossModel = self._modelMgr:getModel("BossModel")
    self._rankModel = self._modelMgr:getModel("RankModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function DragonRankDialog:onInit()
	-- 通用动态背景
    -- self:addAnimBg()
	self._rankModel = self._modelMgr:getModel("RankModel")
	self:registerClickEventByName("bg.bgPanel.closeBtn", function()
        self:close()
        if self._callBack then
        	self._callBack()
        end
        self._rankModel:clearRankList()
        UIUtils:reloadLuaFile("pve.DragonRankDialog")
    end)

	self._itemData = nil
	self._bgPanel = self:getUI("bg.bgPanel")
	self._leftBoard = self:getUI("bg.bgPanel.leftBoard")
	self._leftBoard:setZOrder(5)
	self._noRankBg = self:getUI("bg.bgPanel.noRankBg")
	self._noRankBg:setTouchEnabled(true)
	self._noRankBg:setSwallowTouches(false)
	self._noRankBg:setVisible(false)
	self._titleBg = self:getUI("bg.bgPanel.titleBg")

    self._rankItem = self:getUI("bg.bgPanel.rankItem")
    self._rankItem:setSwallowTouches(false)
    self._rankItem:setVisible(false)
    self._rankSelfItem = self:getUI("bg.bgPanel.selfItem")

    self._tableNode = self:getUI("bg.bgPanel.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem:getContentSize().width-14,self._rankItem:getContentSize().height  
   

	self._tableData = {}
	-- 递进刷新控制
	self.beginIdx = {showTable[1][1],showTable[2][1],showTable[3][1]}
	self.addStep = {showTable[1][1],showTable[2][1],showTable[3][1]}
	self.endIdx = {showTable[1][2],showTable[2][2],showTable[3][2]}

	self._clickItemData = nil
    
    self._allRankData = self._rankModel:getRankList(self._rankType)[self._bossId] or {}

    self._offsetX = nil
    self._offsetY = nil
    self._tableView = nil
	self:addTableView()

	self._tabs = {}
	for i=1,3 do
		local tab = self:getUI("bg.bgPanel.tab" .. i)		
		table.insert(self._tabs,tab)
		local tabtxt = self:getUI("bg.bgPanel.tab" .. i .. ".tabtxt")
		tabtxt:setFontName(UIUtils.ttfName)
		-- tabtxt:setFontSize(28)
		-- self:registerClickEvent(tab,function( )
		-- 	--切页签音效
		-- 	audioMgr:playSound("Tab")
		-- 	self:touchTab(i)
		-- end)
		UIUtils:setTabChangeAnimEnable(tab,688,function( )
			--切页签音效
			audioMgr:playSound("Tab")
			self:touchTab(i)
		end,nil,true)
	end

	-- 初始化界面显示，防止界面闪一下的情况
	self._tableData = self:updateTableData(self._allRankData,self.beginIdx[self._bossId]) 
	self._tableView:reloadData()   --jumpToTop
	
	local name = self._leftBoard:getChildByFullName("name")
	local level = self._leftBoard:getChildByFullName("level")
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildDes = self._leftBoard:getChildByFullName("guildDes")
	guildDes:setVisible(false)
	name:setString("暂无榜首")
	level:setString("")	
	guild:setString("")
	if self._tableData[1] then
		self:reflashNo1(self._tableData[1])
	end
	--不请求数据点击tab 刷新有无排行榜的显示
	self:reflashNoRankUI()	
	--如果有数据则刷新自己信息
	if #self._tableData > 0 then
		self:reflashUserInfo()
	end

	self:touchTab(self._bossId or 1)

end

function DragonRankDialog:touchTab( idx )
	-- 如果正在发送请求(服务器还没有返回)，不能切换页签
	--self._loadingMc:isVisible() 说明正在滑动tableView，此时切换页签最上面会有留白
	if self._isSending or (self._loadingMc and self._loadingMc:isVisible()) then
		return
	end

	self._bossId = idx
	--切页停止滚动
	if self._tableView then
		self._tableView:stopScroll()
	end
	if self._loadingMc and self._loadingMc:isVisible() then
		self._loadingMc:setVisible(false)
	end

	-- print("==================",self._rankType)
	local tabBtn = self._tabs[idx]
	for k,v in pairs(self._tabs) do
		if k ~= idx then
			local tabTxt = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
			tabTxt:disableEffect()
			v:setEnabled(true)
			v:setBright(true)
		end
	end
	if self._preBtn then
		UIUtils:tabChangeAnim(self._preBtn,nil,true,true)
	end
	self._preBtn = tabBtn 
	UIUtils:tabChangeAnim(tabBtn,function( )
		
		tabBtn:setEnabled(false)
		tabBtn:setBright(false)
		
		local text = tabBtn:getTitleRenderer()
        text:disableEffect()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor2)		

		-- self:addTableView()
		self._allRankData = self._rankModel:getRankList(self._rankType)[self._bossId] or {}
		self._tableData = {}
		if #self._allRankData < 1 then
			--请求数据点击tab 回调reflashUI里刷新有无排行榜的显示以及数据的刷新		
			self:sendGetRankMsg(self._rankType,1,function()
				-- 刷新
				self._allRankData = self._rankModel:getRankList(self._rankType)[self._bossId] or {}
				self._tableData = self:updateTableData(self._allRankData,self.beginIdx[self._bossId]) 
				self._tableView:reloadData()
				if self._tableData[1] then
					self:reflashNo1(self._tableData[1])
				end

				--如果有数据则刷新自己信息
				if #self._tableData > 0 then
					self:reflashUserInfo()
				end
			end)
			self._firstIn = true
		else
			self._firstIn = false
			self._tableData = self:updateTableData(self._allRankData,self.beginIdx[self._bossId]) 
			self._tableView:reloadData()   --jumpToTop
			
			if self._tableData[1] then
				self:reflashNo1(self._tableData[1])
			end
			--不请求数据点击tab 刷新有无排行榜的显示
			self:reflashNoRankUI()		
		end
		
		--如果有数据则刷新自己信息
		if #self._tableData > 0 then
			self:reflashUserInfo()
		end
	end,nil,true)

end

function DragonRankDialog:updateTableData(rankList,index)
	-- print("*************************",index)
	-- dump(rankList,"rankList",4)
	if not rankList then return {} end 
	local data = {}
	for k,v in pairs(rankList) do
		if tonumber(v.rank) <= tonumber(index) then
			data[k] = v
		end
	end
	return data
end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function DragonRankDialog:reflashUserInfo()
	local item  = self._rankSelfItem
	local nameLab = item:getChildByFullName("nameLab")
	local levelLab = item:getChildByFullName("levelLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")

	local rankData = self._rankModel:getSelfRankInfoById(self._rankType,self._bossId)
	-- dump(rankData,"rankData==>",5)
	if not rankData then print("no rankInfo....",self._rankType) return end
	local rank = rankData.rank

	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("0", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(60, 45)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end
	for i=1,3 do
		local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
		rankImg:setVisible(false)
	end
	if rank then  
		rankLab:setString(rank)		
		if rankImgs[tonumber(rank)] then
			rankLab:setVisible(false)
			local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
			rankImg:setVisible(true)
		else
			rankLab:setVisible(true)
		end
	end
	local txt  = item:getChildByFullName("rankTxt")
	if not txt then
		txt = ccui.Text:create()
		txt:setName("rankTxt")
		txt:setString("暂未上榜")
		txt:setFontSize(24)
		txt:setPosition(60, 45)
		txt:setFontName(UIUtils.ttfName)
		txt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		item:addChild(txt)	
	end
	
	txt:setVisible(false)
	-- 没有排名或者大于一万 显示暂未上榜
	if not rank or rank > 9999 or rank == 0 or rank == "" then
		rankLab:setVisible(false)
		txt:setVisible(true)
		self:registerClickEvent(item,function( )
			-- print("===================================")
		end)
	else		
		self:registerClickEvent(item,function( )
			-- print("==========*********************")
			self:selfItemClicked(rankData)			
	       
		end)
	end		

	local userData = self._modelMgr:getModel("UserModel"):getData()
	nameLab:setString(userData.name)
	local scoreStr = rankData.score or 0
	local level,score = self:getStageAndTimeByScore(scoreStr)
	levelLab:setString(level)
	UIscoreLab:setString(score)

	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createRoleHead(userData,headNode,0.7)

    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(258, item:getContentSize().height*0.5 - 27))
	item:addChild(tequanIcon)

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
--    data["qqVip"] = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)

end

function DragonRankDialog:reflashNo1( data )
	-- print("======================reflashNo1()")
	-- dump(data,"data")

	local name = self._leftBoard:getChildByFullName("name")
	local level = self._leftBoard:getChildByFullName("level")
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildDes = self._leftBoard:getChildByFullName("guildDes")
	guildDes:setVisible(false)
	name:setString("暂无榜首")
	level:setString("")	
	guild:setString("")

	if self._leftBoard._roleAnim then
		self._leftBoard._roleAnim:removeFromParent()
		self._leftBoard._roleAnim = nil
	end
	if not data then 
		self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
			-- self:itemClicked(data)
		end)
		return 
	end
	guildDes:setVisible(true)
	local name = self._leftBoard:getChildByFullName("name")
	name:setString(data.name)
	local level = self._leftBoard:getChildByFullName("level")
	local inParam = {lvlStr = "Lv." .. (data.level or data.lvl or 0), lvl = (data.level or data.lvl or 0), plvl = data.plvl}
    UIUtils:adjustLevelShow(level, inParam, 1)
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildName = data.guildName 
	if guildName and guildName ~= "" then 
		guild:setVisible(true)
		local nameLen = utf8.len(guildName)
		if nameLen > 6 then
			guildName = string.sub(guildName,1,15) .. "..."
		end
		guild:setString("" .. (guildName or ""))
	else
		guildDes:setVisible(false)
		guild:setVisible(false)
	end

	-- 左侧人物形象
	local rolePanel = self._leftBoard:getChildByFullName("rolePanel")
	local heroId = data.fHeroId  or 60001
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    if data.heroSkin then
        local heroSkinD = tab.heroSkin[data.heroSkin]
        heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or heroD["heroart"]
    end
    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
    sp:setScale(0.8)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._leftBoard:getContentSize().width*0.5, rolePanel:getPositionY())
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,1)
	
	self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
		self:itemClicked(data)
	end)
end

function DragonRankDialog:addTableView( )
	if self._tableView then 
		self._tableView:removeFromParent()
		self._tableView = nil
	end
	self._tableViewW = 616
	self._tableViewH = 318
    local tableView = cc.TableView:create(cc.size(self._tableViewW, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(9,5))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(false)
    self._tableNode:addChild(tableView,999)
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
    self._tableView = tableView
    -- tableView:reloadData()
   
end

function DragonRankDialog:createLoadingMc()
	if self._loadingMc then return end
	-- 添加加载中动画
	self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._bgPanel:getContentSize().width*0.5 - 30, self._tableNode:getPositionY() + 20))
    self._bgPanel:addChild(self._loadingMc, 20)
    self._loadingMc:setVisible(false)
end

function DragonRankDialog:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()

    local offsetY = view:getContentOffset().y   
    -- print("========================offsetY===",offsetY)	
	-- if offsetY >= 60 and #self._tableData > 5 and #self._tableData < self.endIdx[self._bossId] and not self._canRequest then
	-- 	self._canRequest = true
	-- 	self:createLoadingMc()
	-- 	if not self._loadingMc:isVisible() then
	-- 		self._loadingMc:setVisible(true)
	-- 	end
	-- end	

    local condY = 0
    if self._tableData and #self._tableData < 4 then
    	-- tableView height 330
    	condY = self._tableViewH - #self._tableData*(self._tableCellH+5)
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

function DragonRankDialog:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function DragonRankDialog:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function DragonRankDialog:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function DragonRankDialog:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local cellData = self._tableData[idx+1]
    local item = self:createItem(cellData,idx+1)
    if item then
	    item:setPosition(cc.p(2,4))
	    item:setAnchorPoint(cc.p(0,0))
	    cell:addChild(item)
	end

    return cell
end

function DragonRankDialog:numberOfCellsInTableView(table)
	-- print("#self._tableData",#self._tableData)
	return #self._tableData
	
end

-- 接收自定义消息
function DragonRankDialog:reflashUI(data)

end

function DragonRankDialog:reflashRankUI()
	local offsetX = nil
	local offsetY = nil
	if self._offsetX and self._offsetY then
		offsetX = self._offsetX
		offsetY = self._offsetY
	end
    self._allRankData = self._rankModel:getRankList(self._rankType)[self._bossId]
    self._tableData = self:updateTableData(self._allRankData,self.beginIdx[self._bossId])
   	
    if self._tableData and self._tableView then    	
	    self._tableView:reloadData()
	    if offsetX and offsetY and not self._firstIn  then
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

function DragonRankDialog:reflashNoRankUI()
	if (not self._tableData or #self._tableData <= 0) then
		-- print("==================reflashNoRankUI============")
		-- print("=====================self._rankType=",self._rankType)
		self._noRankBg:setVisible(true)
		self._noRankBg:setSwallowTouches(true)
		self._tableNode:setVisible(false)
		self._titleBg:setVisible(false)
	else
		
		self._noRankBg:setVisible(false)
		self._noRankBg:setSwallowTouches(true)
		self._tableNode:setVisible(true)
		self._titleBg:setVisible(true)
	end
end

local rankTextColor = {cc.c4b(254, 203, 34, 255),cc.c4b(183, 215, 215, 255),cc.c4b(253, 156, 87, 255)}
function DragonRankDialog:createItem( data,index )
	if data == nil then return end

	local item = self._rankItem:clone()

	self._itemData = data
	item:setVisible(true)
	item.data = data
	local rank = data.rank
	local name = data.name or ""
	local scoreStr = data.score or 0
	local level,score = self:getStageAndTimeByScore(scoreStr)
	
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)
	local levelLab = item:getChildByFullName("levelLab")
	levelLab:setString(level or "")
	local UIscoreLab = item:getChildByFullName("scoreLab")
	UIscoreLab:setString(score or "")

	local txt  = item:getChildByFullName("rankTxt")
	if txt then
		txt:setVisible(false)
		txt:removeFromParent()
	end
	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("0", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(60, 38)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end
	rankLab:setString(rank or 0)

	for i=1,3 do
		local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
		rankImg:setVisible(false)
	end
	if rankImgs[tonumber(rank)] then
		rankLab:setVisible(false)
		local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
		rankImg:setVisible(true)
	else
		rankLab:setVisible(true)
	end
	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			self:itemClicked(data)			
        else
            self._inScrolling = false
        end
	end)
	item:setSwallowTouches(false)
	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createRoleHead(data,headNode,0.65)

    --启动特权类型
--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(248, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

--    data["qqVip"] = "is_qq_svip"
    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)

	return item
end

function DragonRankDialog:createRoleHead(data,headNode,scaleNum)
	local avatarName = data.avatar
	local scale = scaleNum and scaleNum or 0.8
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"], plvl = data.plvl})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5 - 2)
	headNode:addChild(icon)
end

function DragonRankDialog:selfItemClicked(data)
	
	if not data then return end
	local param = {}
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local uData = {}
	uData.rank = data.rank
	uData._id = userData._id
	self:showDetailPanel(uData)
end

function DragonRankDialog:itemClicked(data)
	-- body
	if not data then return end
	local param = {}
	self:showDetailPanel(data)	
end

function DragonRankDialog:showDetailPanel(data)
	if not data then return end
	local rid = data._id
	-- 获取上榜时的数据信息
	self._serverMgr:sendMsg("RankServer", "getDetailRank", {type=self._rankType ,roleId=rid,id=self._bossId}, true, {}, function(result) 
		local udata = result
		-- data.isNotShowBtn = true
		self._viewMgr:showDialog("arena.DialogArenaUserInfo",udata,true)
    end)

end

--是否要刷新排行榜
function DragonRankDialog:sendMessageAgain()
	-- self.beginIdx -- self.endIdx -- self.addStep
	self._allRankData = self._rankModel:getRankList(self._rankType)[self._bossId]
	local rankData = self._rankModel:getRankList(self._rankType)
	local startNum = rankData[self._bossId] and #rankData[self._bossId] + 1 or 1
	local startCount = tonumber(self.beginIdx[self._bossId])
	local endCount = tonumber(self.endIdx[self._bossId])
	local addCount = tonumber(self.addStep[self._bossId])

	if #self._tableData == #self._allRankData and #self._allRankData%addCount == 0 and #self._allRankData < endCount then
		--如果本地没有更多数据则向服务器请求
		self:sendGetRankMsg(self._rankType,startNum,function()
			self._offsetX = 0
			self._offsetY = 0
			if #self._allRankData > startCount then
				self:searchForPosition(startCount,addCount,endCount)
			end
			self._viewMgr:unlock()
		end)
	else	
		self._canRequest = false
		self._viewMgr:unlock()
	end
end
--刷新之后tableView 的定位
function DragonRankDialog:searchForPosition(startCount,addCount,endCount)	
	if startCount + addCount <= endCount then
		self.beginIdx[self._bossId] = startCount + addCount
		local subNum = #self._allRankData - startCount		
		if subNum < addCount then
			self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))			
		else
			self._offsetY = -1 * (tonumber(self.addStep[self._bossId]) * (self._tableCellH+5))			
		end
		
	else
		self.beginIdx[self._bossId] = endCount
		self._offsetY = -1 * (endCount - startCount) * (self._tableCellH+5)
	end
	-- if #self._allRankData <= 4 then
	-- 	self._offsetY = self._tableViewH - #self._allRankData * (self._tableCellH+5)
	-- 	self._offsetY = self._offsetY > 0 and self._offsetY or 0
	-- end
end
--获取排行榜数据
function DragonRankDialog:sendGetRankMsg(tp,start,callback)
	self._isSending = true
	self._rankModel:setRankTypeAndStartNum(tp,start)
	self._serverMgr:sendMsg("RankServer", "getRankList", {type=tp,id=self._bossId,startRank = start}, true, {}, function(result) 
		if callback then
			callback()
		end

		if #self._tableData == 0 then
			-- 更新bossModel里的前三数据
			self._bossModel:setrankListByPveId(self._bossId,result)
		end

		self:reflashRankUI()
		self:reflashNoRankUI()
		self._isSending = false
    end)
end

-- 根据积分拆取层数和通关时间
-- 难度类型(2位)+难度id(4位)+剩余战斗时间(3位) 最前面的难度类型是以后用于无尽模式的 99是无尽  
function DragonRankDialog:getStageAndTimeByScore(score)

	local totalTime = 120  --两分钟
	local leftTime = string.sub(score, -3, -1)
	local stageId = string.sub(score, -5, -4)
	local diffNum = string.sub(score, -7, -6)

	local passTime = totalTime - tonumber(leftTime)
	local diffStr = ""
	if not stageId or stageId == "" then
		stageId = 0
	end
	if score  == 0 then
		time = "0秒"
		diffStr = "无"
	else
		if not diffNum or diffNum == "" or tonumber(diffNum) ~= 99 then
			diffStr = lang("LONGZHIGUONANDU_" .. tonumber(stageId))
		else
			diffStr = lang("LONGZHIGUONANDU_11")
		end
	    time = totalTime-leftTime  --TimeUtils.getTimeString(totalTime-leftTime)
	    time = time .. "秒"
	end
    return diffStr,time
end

function DragonRankDialog.dtor()
    
end

return DragonRankDialog