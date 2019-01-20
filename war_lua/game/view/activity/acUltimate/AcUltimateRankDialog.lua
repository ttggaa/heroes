--
-- Author: huangguofang
-- Date: 2018-05-09 17:02:19
--

local AcUltimateRankDialog = class("AcUltimateRankDialog",BasePopView)
function AcUltimateRankDialog:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
	param = param or {}
	self._rankType = param.rankType
	self._userModel = self._modelMgr:getModel("UserModel")
    self._rankModel = self._modelMgr:getModel("RankModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
end

function AcUltimateRankDialog:getAsyncRes()
    return 
    {
        {"asset/ui/alliance2.plist", "asset/ui/alliance2.png"},        
    }
end
local rankTypeNum = {
	[1] = 36,
	[2] = 37
}
-- 初始化UI后会调用, 有需要请覆盖
function AcUltimateRankDialog:onInit()	
	self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        self._rankModel:clearRankList() 
        UIUtils:reloadLuaFile("activity.acUltimate.AcUltimateRankDialog")
    end)
    local userData = self._userModel:getData()
    local isNotJion = false
    if not userData.guildId or userData.guildId == 0 then
    	self._rankType = 2
    	isNotJion = true
    end
	self._itemData = nil	
	self._bgPanel = self:getUI("bg.bgPanel")
	self._leftBoard = self:getUI("bg.bgPanel.leftBoard")
	self._leftBoard:setZOrder(5)
	self._noRankBg = self:getUI("bg.bgPanel.noRankBg")
	self._noRankBg:setTouchEnabled(true)
	self._noRankBg:setSwallowTouches(false)
	self._noRankBg:setVisible(false)
	self._titleBg1 = self:getUI("bg.bgPanel.titleBg1")
	self._titleBg2 = self:getUI("bg.bgPanel.titleBg2")
	self._titleBg1:setVisible(false)
	self._titleBg2:setVisible(false)

	self._selfItem1 = self:getUI("bg.bgPanel.selfItem1")
    self._selfItem2 = self:getUI("bg.bgPanel.selfItem2")
    self._selfItem1:setVisible(false)
	self._selfItem2:setVisible(false)

    self._rankItem1 = self:getUI("bg.bgPanel.rankItem1")
    self._rankItem2 = self:getUI("bg.bgPanel.rankItem2")   
	self._rankItem1:setVisible(false)
	self._rankItem2:setVisible(false)

    self._tableNode = self:getUI("bg.bgPanel.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem1:getContentSize().width,self._rankItem1:getContentSize().height  

	self._tableData = {}
	-- 递进刷新控制
	self.beginIdx = {
		[1] = 20,
		[2] = 50,
	}
	self.addStep = {
		[1] = 20,
		[2] = 50,
	}
	self.endIdx = {
		[1] = 20,
		[2] = 500,
	}

	self._clickItemData = nil    
    self._allRankData = self._rankModel:getRankList(rankTypeNum[self._rankType])
    self._offsetX = nil
    self._offsetY = nil
    self._tableView = nil
	self:addTableView()

	self._tabs = {}
	local tab1 = self:getUI("bg.bgPanel.tab1")	
	local tab2 = self:getUI("bg.bgPanel.tab2")	
	self._tabs[1] = tab1
	self._tabs[2] = tab2
	if isNotJion then
		tab1:setEnabled(false)
		tab1:setSaturation(-100)
	end
	self:registerClickEvent(tab1, function()
        self:touchTab(1)
    end)
    self:registerClickEvent(tab2, function()
        self:touchTab(2)
    end)
	
	self._tabs[self._rankType or 1]._appearSelect = true
	self:touchTab(self._rankType or 1)
end

function AcUltimateRankDialog:touchTab( idx )
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
	self._rankType = idx 
	-- print("==================",self._rankType)
	local tabBtn = self._tabs[idx]
	for k,v in pairs(self._tabs) do
		if k ~= idx then
			 local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
			v:setEnabled(true)
			v:setBright(true)
			v:loadTextureNormal("TeamBtnUI_tab_n.png",1)
		end
	end
	tabBtn:setEnabled(false)
	tabBtn:setBright(false)
	
	local text = tabBtn:getTitleRenderer()
    text:disableEffect()
    tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor2)	
	tabBtn:loadTextureNormal("TeamBtnUI_tab_p.png",1)
	self._allRankData = self._rankModel:getRankList(rankTypeNum[self._rankType]) or {}
	self._tableData = {}
	if #self._allRankData < 1 then
		--请求数据点击tab 回调reflashUI里刷新有无排行榜的显示以及数据的刷新
		if self._rankType ~= self._rankInitType then
		    self:sendGetRankMsg(self._rankType,1)
		end
		self._firstIn = true
	else
		self._firstIn = false
		self._tableData = self:updateTableData(self._allRankData,self.beginIdx[self._rankType]) 
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
	self:reflashTitleName(idx)		
end

function AcUltimateRankDialog:updateTableData(rankList,index)
	-- print("*************************",index)
	local data = {}
	for k,v in pairs(rankList) do
		if tonumber(v.rank) <= tonumber(index) then
			data[k] = v
		end
	end
	return data
end

function AcUltimateRankDialog:reflashTitleName(index)
	self._titleBg1:setVisible(false)
	self._titleBg2:setVisible(false)
	self["_titleBg" .. index]:setVisible(true)
end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function AcUltimateRankDialog:reflashUserInfo()
	local item  = self["_selfItem" .. self._rankType]
	for i=1,2 do
		self["_selfItem" .. i]:setVisible(false)
	end
	item:setVisible(true)

	local nameLab = item:getChildByFullName("nameLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")
	nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	UIscoreLab:setColor(UIUtils.colorTable.ccUIBaseColor5)

	local rankData = self._rankModel:getSelfRankInfo(rankTypeNum[self._rankType])
	if not rankData then print("no rankInfo....",self._rankType) return end
	local rank = rankData.rank

	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(68, 45)
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
	-- 没有排名或者大于一万 显示暂未上榜
	if not rank or rank > 9999 or rank == 0 or rank == "" then
		rankLab:setString("暂未上榜")	
	end

	local userData = self._userModel:getData()
	nameLab:setString(userData.name)
	-- levelLab:setString(userData.lvl)
	UIscoreLab:setString(rankData.score or "")

	self._selfRankData = rankData
	self._selfRankData.lvl = userData.lvl
	self:registerClickEvent(item,function( )
		self:selfItemClicked(rankData)			
	end)
	if self["updateSelfItem" .. self._rankType] then
		self["updateSelfItem" .. self._rankType](self)
	end

end

function AcUltimateRankDialog:updateSelfItem1()
	local data = self._guildModel:getAllianceDetail()
	local levelLab = self._selfItem1:getChildByFullName("levelLab")
	-- dump(data,"data===>",5)
	levelLab:setString("联盟等级：" .. (data.level or data.lvl or ""))

	local headNode = self._selfItem1:getChildByFullName("headNode")
	headNode:removeAllChildren()
	local param = {flags = data.avatar1 or 101, logo = data.avatar2 or 201}
    avatarIcon = IconUtils:createGuildLogoIconById(param)
    avatarIcon:setName("avatarIcon")
    avatarIcon:setScale(0.7)
    avatarIcon:setAnchorPoint(cc.p(0.5,1))
	avatarIcon:setPosition(headNode:getContentSize().width*0.5-5,headNode:getContentSize().height+5)
	headNode:addChild(avatarIcon)

    local nameLab = self._selfItem1:getChildByFullName("nameLab")
    nameLab:setString(data.name or "")
    if self._selfItem1.tequanIcon then
        self._selfItem1.tequanIcon:removeFromParent(true)
        self._selfItem1.tequanIcon = nil
    end

    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
	--	tequan = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.7)
    tequanIcon:setPosition(cc.p(282, self._selfItem1:getContentSize().height*0.5 - 27))
    self._selfItem1.tequanIcon = tequanIcon
	self._selfItem1:addChild(tequanIcon)

    if self._selfItem1.qqVipIcon then
        self._selfItem1.qqVipIcon:removeFromParent(true)
        self._selfItem1.qqVipIcon = nil
    end

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
	--    qqVipTp = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, self._selfItem1:getContentSize().height*0.5 + 5))
	self._selfItem1:addChild(qqVipIcon)
end

function AcUltimateRankDialog:updateSelfItem2()	
	local rankData = self._modelMgr:getModel("UserModel"):getData()
	local headNode = self._selfItem2:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createRoleHead(rankData,headNode)
    local nameLab = self._selfItem2:getChildByFullName("nameLab")
    if self._selfItem2.tequanIcon then
        self._selfItem2.tequanIcon:removeFromParent(true)
        self._selfItem2.tequanIcon = nil
    end
    local guildName = self._selfItem2:getChildByFullName("guildName")
    guildName:setString(rankData.guildName or "1")
    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
	--	tequan = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.7)
    tequanIcon:setPosition(cc.p(193, self._selfItem2:getContentSize().height*0.5 - 27))
    self._selfItem2.tequanIcon = tequanIcon
	self._selfItem2:addChild(tequanIcon)

    if self._selfItem2.qqVipIcon then
        self._selfItem2.qqVipIcon:removeFromParent(true)
        self._selfItem2.qqVipIcon = nil
    end

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
	--    qqVipTp = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, self._selfItem2:getContentSize().height*0.5 + 5))
    self._selfItem2.qqVipIcon = qqVipIcon
	self._selfItem2:addChild(qqVipIcon)
end

function AcUltimateRankDialog:createRoleHead(data,headNode,scaleNum)
	local avatarName = data.avatar
	local scale = scaleNum and scaleNum or 0.8
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"], plvl = data["plvl"]})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width*0.5+5,headNode:getContentSize().height*0.5 - 2)
	headNode:addChild(icon)
end

function AcUltimateRankDialog:reflashNo1( data )
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
		-- roleAnim:setVisible(false)
		self._leftBoard._roleAnim:removeFromParent()
		self._leftBoard._roleAnim = nil
	end
	if not data then 		
		self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
			-- self:itemClicked(data)
		end)
		return 
	end
	local name = self._leftBoard:getChildByFullName("name")
	name:setString(data.name)
	local level = self._leftBoard:getChildByFullName("level")
	local inParam = {lvlStr = "Lv." .. (data.level or data.lvl or 0), lvl = data.level or data.lvl, plvl = data.plvl}
	UIUtils:adjustLevelShow(level, inParam, 1)
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildName = data.guildName or data.name or ""

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
    -- sp:setScale(0.8)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._leftBoard:getContentSize().width*0.5, rolePanel:getPositionY())
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,1)

	local guildLeader = self._leftBoard:getChildByFullName("guildLeader")
	local guildImg = self._leftBoard:getChildByFullName("guildImg")
	
	if 1 == self._rankType then
		level:setString("联盟等级：" .. (data.level or data.lvl or 0))	
		guildImg:setVisible(true)
		local logoData = tab:GuildFlag(data.avatar2)
		if logoData and logoData.pic then
			guildImg:loadTexture(logoData.pic .. ".png",1)
		else
			guildImg:setVisible(false)
		end
		name:setString(guildName)
		guildDes:setVisible(false)
		guild:setVisible(false)
		guildLeader:setVisible(false)
		if data.mName then
			guildLeader:setString("" .. data.mName)
		end
	else
		guildDes:setVisible(true)
		guild:setVisible(true)
		guild:setString(guildName)
		guildImg:setVisible(false)
		guildLeader:setVisible(false)
	end
	self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
		self:itemClicked(data)
	end)
end

function AcUltimateRankDialog:addTableView( )
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

function AcUltimateRankDialog:createLoadingMc()
	if self._loadingMc then return end
	-- 添加加载中动画
	self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._bgPanel:getContentSize().width*0.5 - 30, self._tableNode:getPositionY() + 20))
    self._bgPanel:addChild(self._loadingMc, 20)
    self._loadingMc:setVisible(false)
end

function AcUltimateRankDialog:scrollViewDidScroll(view)
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
			self._canRequest = false
			self:sendMessageAgain()
			self:createLoadingMc()
			if self._loadingMc:isVisible() then
				self._loadingMc:setVisible(false)
			end		
		end
	end

end

function AcUltimateRankDialog:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AcUltimateRankDialog:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function AcUltimateRankDialog:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function AcUltimateRankDialog:tableCellAtIndex(table, idx)
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

function AcUltimateRankDialog:numberOfCellsInTableView(table)
	-- print("#self._tableData",#self._tableData)
	return #self._tableData	
end

-- 接收自定义消息
function AcUltimateRankDialog:reflashUI(data)
	local offsetX = nil
	local offsetY = nil
	if self._offsetX and self._offsetY then
		offsetX = self._offsetX
		offsetY = self._offsetY
	end
    self._allRankData = self._rankModel:getRankList(rankTypeNum[self._rankType])
    self._tableData = self:updateTableData(self._allRankData,self.beginIdx[self._rankType])
   	-- print("************&&&&&&&&&&&&-----------",#self._tableData)
    if self._tableData and self._tableView then    	
	    self._tableView:reloadData()
	    if offsetX and offsetY and not self._firstIn then
	    	self._tableView:setContentOffset(cc.p(offsetX,offsetY))
			-- self._canRequest = false
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

function AcUltimateRankDialog:reflashNoRankUI()
	if (not self._tableData or #self._tableData <= 0) then
		self._noRankBg:setVisible(true)
		self._noRankBg:setSwallowTouches(true)
		self._tableNode:setVisible(false)
		self._titleBg1:setVisible(false)
		self._titleBg2:setVisible(false)		
	else
		self._noRankBg:setVisible(false)
		self._noRankBg:setSwallowTouches(false)
		self["_selfItem" .. self._rankType]:setVisible(true)
		self._tableNode:setVisible(true)
		self["_titleBg" .. self._rankType]:setVisible(true)
	end
end

local rankTextColor = {cc.c4b(254, 203, 34, 255),cc.c4b(183, 215, 215, 255),cc.c4b(253, 156, 87, 255)}
function AcUltimateRankDialog:createItem( data,index )
	if data == nil then return end
	local item = self["_rankItem" .. self._rankType]:clone()
	item:setContentSize(self._tableCellW,self._tableCellH)
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	local scoreLab = item:getChildByFullName("scoreLab")
	scoreLab:setColor(UIUtils.colorTable.ccUIBaseColor5)

	self._itemData = data
	item:setVisible(true)
	self._currItem = item
	item.data = data
	local rank = data.rank
	local score = data.score

	local UIscoreLab = item:getChildByFullName("scoreLab")
	UIscoreLab:setString(score)

	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("0", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(60, 38)
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
	item:setSwallowTouches(false)
	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			self:itemClicked(data)			
        else
            self._inScrolling = false
        end
	end)
	item:setSwallowTouches(false)

	if self["updateItem" .. self._rankType] then
		self["updateItem" .. self._rankType](self)
	end
	return item
end

function AcUltimateRankDialog:updateItem1()
	local item = self._currItem
	local data = self._itemData
	local name = data.name	or ""
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)
	local levelLab = item:getChildByFullName("levelLab")
	-- dump(data,"data===>",5)
	levelLab:setString("联盟等级：" .. (data.level or data.lvl or ""))

	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	local param = {flags = data.avatar1 or 101, logo = data.avatar2 or 201}
    avatarIcon = IconUtils:createGuildLogoIconById(param)
    avatarIcon:setName("avatarIcon")
    avatarIcon:setScale(0.6)
    avatarIcon:setAnchorPoint(cc.p(0.5,1))
	avatarIcon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height - 5)
	headNode:addChild(avatarIcon)
end
function AcUltimateRankDialog:updateItem2()
	local item = self._currItem
	local data = self._itemData
	local name = data.name or ""
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)
	
	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createRoleHead(data,headNode,0.65)
	-- dump(data,"data===>",5)
	local guildName = item:getChildByFullName("guildName")
    guildName:setString(data.guildName or "")

    --启动特权类型
	--	 data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(272, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

	--    data["qqvip"] = "is_qq_svip"
    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)
end


function AcUltimateRankDialog:selfItemClicked(data)
	if not data then return end
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local roleId = userData._id
	self._param = {type=rankTypeNum[self._rankType],roleId=roleId}
	self._itemData = {}
	self._itemData.rid = roleId
	self._itemData.rank = data.rank
	self._itemData.name = userData.name
	self._itemData.lvl = userData.lvl
	self._itemData.avatarFrame = userData.avatarFrame
	self._itemData.avatar = userData.avatar
	self._itemData.score = data.score
	self._itemData.qqVip = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
	self._itemData.tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""

	if self._rankType == 2 and roleId and roleId ~= 0 then
		self._clickItemData = self._itemData
		self:goView2()   
	elseif 1 == self._rankType then
		if userData.guildId and userData.guildId ~= ""  then
			local param = {guildId = guildId}
		    self._serverMgr:sendMsg("GuildServer", "getGameGuildBaseInfo", {guildId = userData.guildId}, true, {}, function (result)
		        self._clickItemData = result
		        self:goView1()
		    end)
		end
	else
		print("=======数据异常-================")
	end
end

function AcUltimateRankDialog:itemClicked(data)
	-- body
	if not data then return end
	self._param = {type=rankTypeNum[self._rankType],roleId=data.rid or data._id}
	self._itemData = data
	self._clickItemData = data
	if self["goView" .. self._rankType] then
		self["goView" .. self._rankType](self)
	end	
end

function AcUltimateRankDialog:goView1()
	 self._viewMgr:showDialog("guild.dialog.GuildDetailDialog", {allianceD = self._clickItemData})
end

function AcUltimateRankDialog:goView2()
	if not self._clickItemData then return end
	local fId = (self._clickItemData.lvl and  self._clickItemData.lvl >= 15) and 101 or 1
	self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = self._clickItemData.rid or self._clickItemData._id,fid=fId}, true, {}, function(result) 
		local data = result
		data.rank = self._clickItemData.rank
		data.usid = self._clickItemData.usid
		-- data.isNotShowBtn = true
		self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
    end)
end

--是否要刷新排行榜
function AcUltimateRankDialog:sendMessageAgain()
	-- self.beginIdx -- self.endIdx -- self.addStep
	self._allRankData = self._rankModel:getRankList(rankTypeNum[self._rankType])
	local starNum = self._rankModel:getRankNextStart(rankTypeNum[self._rankType])
	local statCount = tonumber(self.beginIdx[self._rankType])
	local endCount = tonumber(self.endIdx[self._rankType])
	local addCount = tonumber(self.addStep[self._rankType])

	if #self._tableData == #self._allRankData and #self._allRankData%addCount == 0 and #self._allRankData < endCount then
		--如果本地没有更多数据则向服务器请求
		self:sendGetRankMsg(self._rankType,starNum,function()
			self._offsetX = 0
			self._offsetY = 0
			if #self._allRankData > statCount then
				self:searchForPosition(statCount,addCount,endCount)
			end
			self._viewMgr:unlock()
		end)
	else
		self._viewMgr:unlock()
	end
end
--刷新之后tableView 的定位
function AcUltimateRankDialog:searchForPosition(statCount,addCount,endCount)
	self._offsetX = 0
	if statCount + addCount <= endCount then
		self.beginIdx[self._rankType] = statCount + addCount
		local subNum = #self._allRankData - statCount

		if subNum < addCount then
			self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))			
		else
			self._offsetY = -1 * (tonumber(self.addStep[self._rankType]) * (self._tableCellH+5))			
		end
		
	else
		self.beginIdx[self._rankType] = endCount
		self._offsetY = -1 * (endCount - statCount) * (self._tableCellH+5)
	end

	--一屏内 
	local tempH = #self._allRankData * (self._tableCellH+5) - self._tableViewH
	if tempH <= 0 or tempH < (self._tableCellH + 5) * 0.5 then --差值小于0.5个cell高度
		self._offsetY = self._tableViewH - #self._allRankData * (self._tableCellH+5)
	end
end
--获取排行榜数据
function AcUltimateRankDialog:sendGetRankMsg(tp,start,callback)
	self._isSending = true
	self._rankModel:setRankTypeAndStartNum(rankTypeNum[tp],start)
	self._serverMgr:sendMsg("RankServer", "getRankList", {type=rankTypeNum[tp],startRank = start}, true, {}, function(result) 
		if callback then
			callback()
		end
		self:reflashUI()
		self:reflashNoRankUI()
		self._isSending = false
    end)
end

return AcUltimateRankDialog