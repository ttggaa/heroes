--[[
 	@FileName 	ElementalRankView.lua
	@Authors 	zhangtao
	@Date    	2017-08-14 16:36:32
	@Email    	<zhangtao@playcrad.com>
	@Description   层排行
--]]
local ElementalRankView = class("ElementalRankView",BasePopView)
local rankImgs = {"firstImg","secondImg","thirdImg"}

local titleTxt = {
	[1] = "最速",    	
	[2] = "最低"	
}

local titleTable = {
	[1] = {[1]="排名",[2]="角色名",[3]="通关时间",[4]="录像"},    		--最速通关
	[2] = {[1]="排名",[2]="角色名",[3]="总战斗力",[4]="录像"},		--最低战斗力
}

local rankTypeTable = {
    [1] = 22,
    [2] = 23
}
local rankTable = {
	[22] = tab:Setting("G_RANK_ELEMENTAL_SHOW_1").value,
	[23] = tab:Setting("G_RANK_ELEMENTAL_SHOW_2").value,
}
function ElementalRankView:ctor(data)
    self.super.ctor(self)

    self._rankModel = self._modelMgr:getModel("RankModel")

    self._stageId = data.stageId
	self._rankType = data.rankType or 22
	self._rankInitType = data.rankType or 23
	self._modelType = 1     --1 最速 2最低 

end

-- 初始化UI后会调用, 有需要请覆盖
function ElementalRankView:onInit()
    self:registerClickEventByName("bg.layer.closeBtn", function()
    	self._rankModel:clearRankList()
        self:close()
        UIUtils:reloadLuaFile("elemental.ElementalRankView")
    end )

    self._bgPanel = self:getUI("bg.layer")

    self._leftBoard = self:getUI("bg.layer.leftBoard")
    self._leftBoard:setZOrder(5)

    self._rankItem = self:getUI("bg.layer.rankItem")

    self._rankItemCell = self:getUI("bg.layer.rankItemCell")

    self._noRankBg = self:getUI("bg.layer.noRankBg")
    self._noRankBg:setVisible(false)

    self._titleBg = self:getUI("bg.layer.titleBg")    

    self._tableNode = self:getUI("bg.layer.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem:getContentSize().width-15,self._rankItem:getContentSize().height

    local shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareCloudModule"})
    shareNode:setPosition(553, 43)
    shareNode:setScale(0.7)
    shareNode:setName("shareBtn")
    shareNode:setCascadeOpacityEnabled(true, true)
    self._rankItem:addChild(shareNode)

    local shareNode2 = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareCloudModule"})
    shareNode2:setPosition(553, 43)
    shareNode2:setScale(0.7)
    shareNode2:setName("shareBtn")
    shareNode2:setCascadeOpacityEnabled(true, true)
    self._rankItemCell:addChild(shareNode2)

    local rankTab = rankTable[self._rankType]
    -- 递进刷新控制
	self.beginIdx = rankTab[1]
	self.addStep = rankTab[1]
	self.endIdx = rankTab[2]

    self._tableData = self._rankModel:getRankList(self._rankType)[self._stageId] or {}

	self:addTableView()
	-- self:reflashNo1(self._tableData[1])

    self._tabs = {}
	for i=1, #titleTxt do
		local tab = self:getUI("bg.layer.tab" .. i)		
		table.insert(self._tabs,tab)
		local tabtxt = self:getUI("bg.layer.tab" .. i .. ".tabtxt")
		tabtxt:setFontName(UIUtils.ttfName)
		tabtxt:setFontSize(22)
		-- self:registerClickEvent(tab,function( )
			
		-- end)
		UIUtils:setTabChangeAnimEnable(tab,690,function(  )
			--切页签音效
			audioMgr:playSound("Tab")
			self:touchTab(i)
		end,nil,true)
	end

    for rI = 1, #rankTypeTable do
        if rankTypeTable[rI] == self._rankType then
        	self._tabs[rI]._appearSelect = true
	        self:touchTab(rI)
        end
    end
end

function ElementalRankView:touchTab( idx )
	-- 如果正在发送请求(服务器还没有返回)，不能切换页签
	--self._loadingMc:isVisible() 说明正在滑动tableView，此时切换页签最上面会有留白
	if self._isSending or (self._loadingMc and self._loadingMc:isVisible()) then
		return
	end
	self._modelType = idx
	--切页停止滚动
	if self._tableView then
		self._tableView:stopScroll()
	end
	if self._loadingMc and self._loadingMc:isVisible() then
		self._loadingMc:setVisible(false)
	end

	self._rankType = rankTypeTable[idx]
	print("==================",self._rankType)
	local tabBtn = self._tabs[idx]
	for k,v in pairs(self._tabs) do
		if k ~= idx then
			local tabTxt = v:getChildByFullName("tabtxt")
			tabTxt:setColor(UIUtils.colorTable.ccUITabColor1)
			tabTxt:disableEffect()
			-- tabTxt:setString(titleTxt[tonumber(k)])
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
		local tabTxt = tabBtn:getChildByFullName("tabtxt")
		tabTxt:setColor(UIUtils.colorTable.ccUITabColor2)


		self._allRankData = self._rankModel:getRankList(self._rankType)[self._stageId] or {}
		self._tableData = {}
		if #self._allRankData < 1 then
			self:sendGetRankMsg(self._rankType,1)
			self._firstIn = true
		else
			self._firstIn = false
			self._tableData = self:updateTableData(self._allRankData,self.beginIdx) 
			self._tableView:reloadData()   --jumpToTop
			
			if self._tableData[1] then
				self:reflashNo1(self._tableData[1])
			end
			--不请求数据点击tab 刷新有无排行榜的显示
			self:reflashNoRankUI()		
		end
		--不单独请求自己排行榜数据
		--如果没有个人信息向服务器发请求
		-- local selfInfo = self._rankModel:getSelfRankInfo(self._rankType)
		-- if not selfInfo then
			-- self:sendGetSelfRankMsg(self._rankType)
		-- else
			--如果有数据则刷新自己信息
			if #self._tableData > 0 then
				self:reflashUserInfo()
			end
		-- end
		self:reflashTitleName(idx)	
	end,nil,true)
end

function ElementalRankView:updateTableData(rankList,index)
	-- print("*************************",index)
	local data = {}
	for k,v in pairs(rankList) do
		if tonumber(v.rank) <= tonumber(index) then
			data[k] = v
		end
	end
	return data
end

function ElementalRankView:reflashUI(data) 
	self:reloadRankUI()
end

function ElementalRankView:reloadRankUI()
    self._tableData = self._rankModel:getRankList(self._rankType)[self._stageId] or {}
	if not self._tableData or #self._tableData <= 0 then
		self._noRankBg:setVisible(true)
		self._rankItem:setVisible(false)
		self._titleBg:setVisible(false)
        self._tableNode:setVisible(false)
	else
		self._noRankBg:setVisible(false)
		self._rankItem:setVisible(true)
		self._titleBg:setVisible(true)
        self._tableNode:setVisible(true)
	end

    local offsetX = nil
	local offsetY = nil
	if self._offsetX and self._offsetY then
		offsetX = self._offsetX
		offsetY = self._offsetY
	end
    if self._tableData  and self._tableView then
        self._tableView:reloadData()
	    if offsetX and offsetY and not self._firstIn then
	    	self._tableView:setContentOffset(cc.p(offsetX,offsetY))
			self._canRequest = false
	    end	    
	    self._firstIn = false
	    self:reflashUserInfo()
	    self:reflashNo1(self._tableData[1])
	end
end

function ElementalRankView:reflashNoRankUI()
	if not self._tableData or #self._tableData <= 0 then
		self._noRankBg:setVisible(true)
		self._rankItem:setVisible(false)
		self._titleBg:setVisible(false)
        self._tableNode:setVisible(false)
	else

		self._noRankBg:setVisible(false)
		self._rankItem:setVisible(true)
		self._titleBg:setVisible(true)
        self._tableNode:setVisible(true)
	end
end

function ElementalRankView:reflashTitleName(index)
	local titleD = titleTable[index]
	for i = 1 , 4  do
		local title = self:getUI("bg.layer.titleBg.title"..i)
		if titleD then
			title:setString(titleD[i] or "")
		end
	end
end

function ElementalRankView:reflashUserInfo()
	local item  = self._rankItem
	local nameLab = item:getChildByFullName("nameLab")
	-- nameLab:setColor(cc.c4b(255,255,255,255))
	local levelLab = item:getChildByFullName("levelLab")
	-- levelLab:setColor(cc.c4b(255,255,255,255))
	local rankLab = item:getChildByFullName("rankLevel")

	local rankData = self._rankModel:getSelfRankInfo(self._rankType)[self._stageId]
    local rank = 0
    local rankDataScore = 0
	if rankData then 
	    rank = rankData.rank or 0
        rankDataScore = rankData.score or 0
    end

    --by wangyan 分享
    local shareNode = item:getChildByName("shareBtn")
    shareNode:setVisible(true)

	if rank then  

        rankLab:setString(rank)

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
	end

    local txt = item:getChildByFullName("rankTxt")
	if txt then
		txt:removeFromParent()
	end

	if not rank or rank > 9999 or rank == 0 or rank == "" then
		rankLab:setVisible(false)	

		local txt = ccui.Text:create()
		txt:setName("rankTxt")
		txt:setString("暂未上榜")
		txt:setFontSize(22)
		txt:setPosition(rankLab:getPositionX(), rankLab:getPositionY() - 8)
		txt:setFontName(UIUtils.ttfName)
		txt:setColor(cc.c4b(70,40, 0, 255))
		-- txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		item:addChild(txt)		
	end
	local userData = self._modelMgr:getModel("UserModel"):getData()
	nameLab:setString(userData.name)

	local score = self:getScoreByRankType(rankDataScore, self._rankType)
	levelLab:setString(score)
	--头像

	local rankData = self._modelMgr:getModel("UserModel"):getData()
	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren() 
	self:createRoleHead(rankData,headNode)

--	UIscoreLab:setString(bloodValue)

    --启动特权类型
    local tequan = self._modelMgr:getModel("TencentPrivilegeModel"):getTencentTeQuan() or ""
--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[tequan] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(270, item:getContentSize().height*0.5 - 27))
	item:addChild(tequanIcon)

    local qqVipTp = self._modelMgr:getModel("TencentPrivilegeModel"):getQQVip() or ""
--    data["qqVip"] = "is_qq_svip"
    local qqVipImg = (qqVipTp and qqVipTp ~= "") and IconUtils.tencentIcon[qqVipTp .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)

    if rank > 20 or rank == 0 then
        shareNode:setVisible(false)
    elseif rank > 0 then
        shareNode:registerClick(function()
        	return {moduleName = "ShareCloudModule",
			        rType = self._rankType, 
			        rank = rank, 
			        score = score, 
			        floor = math.floor(self._stageId/4)+1, 
			        stage = self._stageId%4}
        	end)

   --      self:registerClickEvent(item,function( )
			-- self._serverMgr:sendMsg("ElementServer", "getElementReport", {type = self._rankType, targetId = data._id,elementId = string.split(self._stageId,"_")[1],
			-- 	stageId = string.split(self._stageId,"_")[2],rankId = self._modelType}, true, {}, function(result) 
		 --        local data1 = clone(result)
		 --        self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1["atk"],true)
	  --       end)
   --      end)
    end
end

function ElementalRankView:reflashNo1( data )
	local name = self._leftBoard:getChildByFullName("name")
	local level = self._leftBoard:getChildByFullName("level")
	local guild = self._leftBoard:getChildByFullName("guild")
	local detailBtn = self._leftBoard:getChildByFullName("showDetail")	
	local guildDes = self._leftBoard:getChildByFullName("guildDes")
	-- local guildBg = self._leftBoard:getChildByFullName("guildBg")	
	-- local levelBg = self._leftBoard:getChildByFullName("levelBg")	

	-- guildBg:setVisible(false)
	-- levelBg:setVisible(false)
	guildDes:setVisible(false)
	detailBtn:setVisible(false)
	name:setString("暂无榜首")
	level:setString("")	
	guild:setString("")

	local roleAnim = self._leftBoard._roleAnim
	if roleAnim then
		roleAnim:removeFromParent()
		self._leftBoard._roleAnim = nil
	end

	if not data then return end
	guildDes:setVisible(true)
	-- levelBg:setVisible(true)
	-- detailBtn:setVisible(true)
	name:setString(data.name)

	local level = self._leftBoard:getChildByFullName("level")
	level:setString("等级:" .. (data.lvl or ""))
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildName = data.guildName

	if guildName and guildName ~= "" then 
		guild:setVisible(true)
		-- guildBg:setVisible(true)
		local nameLen = utf8.len(guildName)
		if nameLen > 6 then
			guildName = string.sub(guildName,1,15) .. "..."
		end
		guild:setString(guildName or "")
	else
		guild:setVisible(false)
		-- guildBg:setVisible(false)
	end

	--左侧人物形象
	local heroId = data.heroId  or 60001
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    if data.heroSkin then
        local heroSkinD = tab.heroSkin[data.heroSkin]
        heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or heroD["heroart"]
    end
    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
    sp:setScale(0.8)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._leftBoard:getContentSize().width*0.5, self._leftBoard:getContentSize().height*0.5 - 10)
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,0)


	-- self:registerClickEventByName("bg.layer.leftBoard",function( )
	-- 		self._serverMgr:sendMsg("ElementServer", "getElementReport", {type = self._rankType, targetId = data._id,elementId = string.split(self._stageId,"_")[1],
	-- 			stageId = string.split(self._stageId,"_")[2],rankId = self._modelType}, true, {}, function(result) 
	-- 	    local data1 = clone(result)
	-- 	    self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1["atk"],true)
	--     end)
	-- end)
end

function ElementalRankView:addTableView( )
	self._tableViewH = 320
    local tableView = cc.TableView:create(cc.size(570, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(4, 5))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
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
end

function ElementalRankView:createLoadingMc()
	if self._loadingMc then return end
	-- 添加加载中动画
	self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._bgPanel:getContentSize().width*0.5 - 30, self._tableNode:getPositionY() + 20))
    self._bgPanel:addChild(self._loadingMc, 20)
    self._loadingMc:setVisible(false)
end

function ElementalRankView:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()

    local offsetY = view:getContentOffset().y
   	if not self._canRequest then
	    self._offsetX = view:getContentOffset().x
		self._offsetY = view:getContentOffset().y		
--		    print("=============scrollViewDidScroll===================",self._offsetY)
	end
	if offsetY >= 100 and #self._tableData > 5 and #self._tableData < self.endIdx and not self._canRequest then
		self._canRequest = true
--		self:createLoadingMc()
--		if not self._loadingMc:isVisible() then
--			self._loadingMc:setVisible(true)
--		end
	end	
		
    local condY = 0
    if self._tableData and #self._tableData <= 4 then
    	condY = self._tableViewH - #self._tableData*(self._tableCellH+5)
    end
	if self._inScrolling then
	    if offsetY >= condY+100 and not self._canRequest and #self._tableData < self.endIdx then
            self._canRequest = true
--            self:createLoadingMc()

--            if not self._loadingMc:isVisible() then
--				self._loadingMc:setVisible(true)
--			end
        end
        if offsetY < condY+20 and self._canRequest then
            self._canRequest = false
--            self:createLoadingMc()

--            if self._loadingMc:isVisible() then
--				self._loadingMc:setVisible(false)
--			end	
        end
	else
		-- 满足请求更多数据条件
		if self._canRequest and offsetY == condY then		
			self._viewMgr:lock(1)
			self:sendMessageAgain()
--			self:createLoadingMc()

--			if self._loadingMc:isVisible() then
--				self._loadingMc:setVisible(false)
--			end		
		end
	end
end

--是否要刷新排行榜
function ElementalRankView:sendMessageAgain()
	self._allRankData = self._rankModel:getRankList(self._rankType)[self._stageId] or {}
    local rankData = self._rankModel:getRankList(self._rankType)
	local starNum = rankData[self._stageId] and #rankData[self._stageId] + 1 or 1
	local statCount = self.beginIdx
	local endCount = self.endIdx
	local addCount = self.addStep
	if #self._tableData == #self._allRankData and #self._allRankData%addCount == 0 and #self._allRankData < endCount then
		self:sendGetRankMsg(self._rankType,starNum,function()
			if #self._allRankData > statCount then
				self:searchForPosition(statCount,addCount,endCount)
            else
                self._offsetY = 0
			end
			self._viewMgr:unlock()
		end)
    else
    	self._canRequest = false
		self._viewMgr:unlock()
	end
end
--刷新之后tableView 的定位
function ElementalRankView:searchForPosition(statCount,addCount,endCount)
	-- print("===========searchForPosition=========",statCount,addCount,endCount)	
	if statCount + addCount <= endCount then
		self.beginIdx = statCount + addCount
		-- print("=======self._allRankData,self.beginIdx[self._rankType]==================",#self._allRankData,self.beginIdx[self._rankType])
		local subNum = #self._allRankData - statCount
		if subNum < addCount then
			self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))			
		else
			self._offsetY = -1 * (self.addStep * (self._tableCellH+5))			
		end
		-- print("=================searchForPosition=========",self._offsetY)
	else
		self.beginIdx = endCount
		self._offsetY = -1 * (endCount - statCount) * (self._tableCellH+5)
	end
end

--获取排行榜数据
function ElementalRankView:sendGetRankMsg(tp,start,callback)
	self._rankModel:setRankTypeAndStartNum(tp,start)
	self._serverMgr:sendMsg("RankServer", "getRankList", {type=tp,startRank = start, id = self._stageId}, true, {}, function(result) 
		if callback then
			callback()
		end
		self:reloadRankUI()
    end)
end

function ElementalRankView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function ElementalRankView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function ElementalRankView:cellSizeForTable(table,idx) 
    return 80,546
end

function ElementalRankView:tableCellAtIndex(table, idx)
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
    item:setPosition(cc.p(8,0))
    item:setAnchorPoint(cc.p(0,0))
    cell:addChild(item)

    return cell
end

function ElementalRankView:numberOfCellsInTableView(table)
	return #self._tableData
end

function ElementalRankView:createItem( data,index )
	if data == nil then return end	
	local item = self._rankItemCell:clone()
	item:setContentSize(546,76)
	item:setVisible(true)
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setColor(cc.c4b(70,40,0,255))
	local levelLab = item:getChildByFullName("levelLab")
	levelLab:setColor(cc.c4b(70,40,0,255))
	levelLab:setPositionX(levelLab:getPositionX()-5)
    local shareBtn = item:getChildByFullName("shareBtn")
    shareBtn:setVisible(false)
    -- local watchBtn = item:getChildByFullName("watchBtn")
    -- watchBtn:setVisible(true)
    -- local watchLabel = item:getChildByFullName("watchLabel")
    -- watchLabel:setVisible(false)
 --    watchLabel:setColor(cc.c3b(255,241,180))
 --    watchLabel:enable2Color(1, cc.c4b(235,192,19,255))
	-- watchLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
 --    watchLabel:setString("观看")
    local headNode = item:getChildByFullName("headNode")
    headNode:setVisible(true)
    local rankLab = item:getChildByFullName("rankLevel")
    rankLab:setVisible(false)

--	local UIscoreLab = item:getChildByFullName("scoreLab")
--	UIscoreLab:setColor(cc.c4b(70,40,0,255))


	item:setVisible(true)
	item.data = data
	local rank = data.rank
	local score = self:getScoreByRankType(data.score, self._rankType)

	local name = data.name
	
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setVisible(true)
	nameLab:setString(name)

	local selfTag = item:getChildByFullName("selfTag")
	selfTag:setVisible(false)

	rankLab:setString(rank)
	self:createRoleHead(data,headNode)

	local levelLab = item:getChildByFullName("levelLab")
	levelLab:setString(score)
	local txt  = item:getChildByFullName("rankTxt")
	if txt then
		txt:setVisible(false)
		txt:removeFromParent()
	end
	for i=1,3 do
		-- print("=============",rankImgs[tonumber(rank)])
		local rankImg = item:getChildByFullName(rankImgs[tonumber(i)])
		rankImg:setVisible(false)
	end
	if rankImgs[tonumber(rank)] then
		rankLab:setVisible(false)
		local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
		-- rankImg:setScale(2)
		rankImg:setVisible(true)
		-- item:loadTexture("arenaRankUI_cellBg".. rank ..".png",1)
	else
		rankLab:setVisible(true)
		-- item:loadTexture("arenaRankUI_cellBg4.png",1)
		-- rankLab:setPosition(60,50)
	end
	-- item:setCapInsets(cc.rect(160,40,1,1))
	item:setSwallowTouches(false)

 --    self:registerClickEvent(watchBtn,function()
 --        self:showCommentView(data)
	-- end)

	-- self:registerClickEvent(item,function( )
	-- 	if not self._inScrolling then
	-- 		self._serverMgr:sendMsg("ElementServer", "getElementReport", {type = self._rankType, targetId = data._id,elementId = string.split(self._stageId,"_")[1],
	-- 			stageId = string.split(self._stageId,"_")[2],rankId = self._modelType}, true, {}, function(result) 
	-- 			local data1 = clone(result)
	-- 			self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1["atk"],true)
	-- 	    end)
 --        else
 --            self._inScrolling = false
 --        end
	-- end)
	-- item:setSwallowTouches(false)

    --启动特权类型
--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setScale(0.65)
    tequanIcon:setPosition(cc.p(258, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)
	return item
end

function ElementalRankView:createRoleHead(data,headNode,scaleNum)
	local avatarName = data.avatar
	local scale = scaleNum and scaleNum or 0.65
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl

    local tencetTp = data["qqVip"]
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"], tencetTp = tencetTp, plvl = data["plvl"]})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5 - 2)
	headNode:addChild(icon)
end

function ElementalRankView:showCommentView(rankData)
    -- local ext = cjson.encode({targetId = rankData._id})
    -- self._serverMgr:sendMsg("CommentServer", "getCommentData", {ctype = self:getCommentType(), id = self._stageId, ext = ext}, true, {}, function(result)
    --     self._viewMgr:showDialog("cloudcity.CloudCityCommentView", {data = rankData, stageId = self._stageId, cData = result, ctype = self:getCommentType(), rankType = self._rankType})
    -- end)
end


-- 根据排行类型获得分数数据
function ElementalRankView:getScoreByRankType(score, kType)
    score = score or 0
    if kType == self._rankModel.kRankTypeElemQuick then
        return self:getTimeAndBloodByScore(score)
    elseif kType == self._rankModel.kRankTypeElemMinFight then
        return score
    end
end

-- 将分数分解出通关时间和剩余血量
function ElementalRankView:getTimeAndBloodByScore(score)
    local timeData = string.sub(score, 1, -5)
    timeData = timeData == "" and 0 or timeData
    if timeData ~= 0 then 
        local time = tab["elementalPlane"..string.split(self._stageId,"_")[1]][tonumber(string.split(self._stageId,"_")[2])].time
        timeData = time - tonumber(timeData)
    end
    local bloodData = string.sub(score, -4, -1)
    bloodData = tonumber(bloodData)
    local bloodStr = nil
    if bloodData % 100 == 0 then
        bloodStr = tostring(bloodData / 100)
    elseif bloodData % 10 == 0 then
        bloodStr = string.format("%.1f", bloodData / 100)
    else
        bloodStr = string.format("%.2f", bloodData / 100)
    end
    bloodStr = bloodStr .. "%"
    return TimeUtils.getTimeString(tonumber(timeData)), bloodStr
end


function ElementalRankView:getBmpFromNum( num,node,offsetx )
	offsetx = offsetx or 0
	local width = 0
	local widget = node or ccui.Widget:create()
	local numStr = tostring(num)
	local numSps = {}
	local endPos = string.len(numStr)
	local pos = 1
	while pos <= endPos do
		local numC = string.sub(numStr,pos,pos)
		if numC then 
			local numSp = ccui.ImageView:create("arenaRankUI_" .. numC .. ".png",1)
			numSp:setAnchorPoint(cc.p(0,0.5))
			numSp:setPosition(width+offsetx,numSp:getContentSize().height/2)
			widget:addChild(numSp)
			width = width+numSp:getContentSize().width
			table.insert(numSps,numSp)
		end
		pos = pos+1
	end

	-- for i,sp in ipairs(numSps) do
	-- 	sp:setPositionX(sp:getPositionX()-width/2)
	-- 	widget:addChild(sp)
	-- end
	return widget
end

    -- local function sortFun(data1,data2)
    --     if data1.rank ~= data2.rank then
    --         return data1.rank < data2.rank
    --     end
    -- end
    -- -- table.sort(self._data["common_bubble"],sortFun)
    -- table.sort(self._data["bubble"],sortFun)

function ElementalRankView.dtor()
    rankImgs = nil
    titleTxt = nil
    titleTable = nil
    rankTypeTable = nil
end
return ElementalRankView