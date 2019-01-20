--[[
    Filename:    HappyPopRankView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-04 20:06:01
    Description: File description
--]]

local titleTable = {
	[32] = {[1]="排名",[2]="角色名",[3]="最高得分"},   --个人
}
local payerShow = clone(tab:Setting("G_RANK_SPHINX_SHOW_1").value)
local showTable = {
	[32] = {payerShow[1],payerShow[2]},    	--个人
}

local titleTxt = {
	[32] = "个人",    	--个人
}

-- 页签与item的对应关系
local itemIdx = {
	[32] = "1",    	--个人
}

local ids = {
	[1] = 32,
}

local rankImgs = {
	[1] = "firstImg",
	[2] = "secondImg",
	[3] = "thirdImg",
}

local HappyPopRankView = class("HappyPopRankView", BasePopView)

function HappyPopRankView:ctor(param)
	self.super.ctor(self)

    self._rankModel = self._modelMgr:getModel("RankModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._hPopModel = self._modelMgr:getModel("HappyPopModel")

	param = param or {}
	self._rankType = param.rankType 
	self._rankInitType = param.rankType or 1
end

function HappyPopRankView:onInit()
	self:initOriginView()

    local closeBtn = self:getUI("bg.bgPanel.closeBtn")
    self:registerClickEvent(closeBtn, function()
    	self._rankModel:clearRankList()
    	self:close()
    	UIUtils:reloadLuaFile("activity.happyPop.HappyPopRankView")
    	end)

    local ruleBtn = self:getUI("bg.bgPanel.selfAward.ruleBtn")
    self:registerClickEvent(ruleBtn, function ()
        self._viewMgr:showDialog("activity.happyPop.HappyPopRankRuleView",{curType = self._rankType},true)
    end)

	self._itemData = nil
	self._bgPanel = self:getUI("bg.bgPanel")
	self._leftBoard = self:getUI("bg.bgPanel.leftBoard")

	self._noRankBg = self:getUI("bg.bgPanel.noRankBg")
	self._noRankBg:setVisible(false)

	self._rankItem = self:getUI("bg.bgPanel.rankItem")
	self._selfAward = self:getUI("bg.bgPanel.selfAward")
    self._rankItem1 = self:getUI("bg.bgPanel.rankItem1")
	self._rankItem1:setVisible(false)

    self._tableNode = self:getUI("bg.bgPanel.tableNode")
    self._tableCellW, self._tableCellH = self._rankItem1:getContentSize().width, self._rankItem1:getContentSize().height  

	-- 递进刷新控制
	self.beginIdx = { [32] = showTable[32][1]}
	self.addStep = { [32] = showTable[32][1]}
	self.endIdx = { [32] = showTable[32][2]}

	self._tableData = {}
    self._allRankData = self._rankModel:getRankList(self._rankType or 1)
	self:addTableView()

	self:touchTab(self._rankType or 32)

	self:setListenReflashWithParam(true)
	self:listenReflash("HappyPopModel", self.listenModelHandle)
end

function HappyPopRankView:listenModelHandle(inData)
	if inData == "close" then
		self:close()
	end
end

function HappyPopRankView:initOriginView()
	self:getUI("bg.bgPanel.selfAward.destxt"):setString("")
	for i=1,3 do
		self:getUI("bg.bgPanel.selfAward.awardTxt" .. i):setString("")
	end
	self:getUI("bg.bgPanel.leftBoard.name"):setString("")
	self:getUI("bg.bgPanel.leftBoard.level"):setString("")
	self:getUI("bg.bgPanel.leftBoard.guild"):setString("")

	self:getUI("bg.bgPanel.rankItem1.nameLab"):setString("")
	self:getUI("bg.bgPanel.rankItem1.scoreLab"):setString("")
end

function HappyPopRankView:touchTab( idx )
	-- 如果正在发送请求(服务器还没有返回)，不能切换页签
	--self._loadingMc:isVisible() 说明正在滑动tableView，此时切换页签最上面会有留白
	if self._isSending or (self._loadingMc and self._loadingMc:isVisible()) then
		return
	end

	self._rankType = idx

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

function HappyPopRankView:updateTableData(rankList)
	local index = self.beginIdx[self._rankType]
	local data = {}
	for k,v in pairs(rankList) do
		if tonumber(v.rank) <= tonumber(index) then
			data[k] = v
		end
	end
	return data
end

function HappyPopRankView:reflashTitleName()
	local titleD = titleTable[self._rankType]
	for i=1, 3 do
		local title = self:getUI("bg.bgPanel.titleBg.title" ..  i)
		if titleD then
			title:setString(titleD[i] or "")
		end
	end
end

function HappyPopRankView:reflashUserInfo()
	local item  = self._rankItem
	local sysData = tab.magicTrainingRank
	local upperNum = sysData[#sysData]["rank"][2]

	--排名
	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
	    rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(70, 0)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end

	local rankData = self._rankModel:getSelfRankInfo(self._rankType)
	-- dump(rankData, "rankData")
	local rank = rankData.rank

	for i=1, 3 do
	 	local rankImg = item:getChildByFullName(rankImgs[i])
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
			rankLab:setPosition(70,45)
		end
	end

	--暂未上榜
	local txt  = item:getChildByFullName("rankTxt")
	if txt then
		txt:removeFromParent()
		txt = nil
	end
	
	if not rank or rank > upperNum or rank == 0 or rank == "" then
		rankLab:setVisible(false)	
		local txt = ccui.Text:create()
		txt:setName("rankTxt")
		txt:setString("暂未上榜")
		txt:setFontSize(30)
		txt:setPosition(rankLab:getPositionX()+8, rankLab:getPositionY()-10)
		txt:setFontName(UIUtils.ttfName)
		txt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		item:addChild(txt)
	end

	local function createRewards(inRank)
		if sysData[inRank] == nil then
			return
		end

		local rwds = sysData[inRank]["rewards"]
		for i = 1, 3 do
			local awardIcon = self._selfAward:getChildByFullName("awardImg" .. i)
			local awardNum = self._selfAward:getChildByFullName("awardTxt" .. i)
			awardIcon:setVisible(true)
			awardIcon:removeAllChildren()
			awardNum:setVisible(true)
			if rwds[i] == nil then
				for m=i,3 do
					local awardIcon1 = self._selfAward:getChildByFullName("awardImg" .. m)
					local awardNum1 = self._selfAward:getChildByFullName("awardTxt" .. m)
					awardIcon1:setVisible(false)
					awardNum1:setVisible(false)
				end
				break
			end

			awardNum:setString(rwds[i][3])

			local itemId
			if rwds[i][1] == "avatarFrame" then
				local itemId = rwds[i][2]
			    local itemNum = rwds[i][3]
				local itemData = tab:AvatarFrame(itemId)
				local rwdIcon = IconUtils:createHeadFrameIconById({itemId = itemId, itemData = itemData})
				rwdIcon:setAnchorPoint(cc.p(0.5, 0.5))
			    rwdIcon:setPosition(0, 0)
			    rwdIcon:setScale(0.45)
			    awardIcon:addChild(rwdIcon)
			else
				local itemId
				if rwds[i][1] == "tool" then
	                itemId = rwds[i][2]
	            else
	                itemId = IconUtils.iconIdMap[rwds[i][1]]
	            end

	            local param = {itemId = itemId, eventStyle = 4, swallowTouches = true}
	            local rwdIcon = IconUtils:createItemIconById(param)
	            rwdIcon:setAnchorPoint(cc.p(0.5, 0.5))
                rwdIcon:setPosition(0, 0)
                rwdIcon:setScale(0.5)
                awardIcon:addChild(rwdIcon)
			end	
		end
	end

	--排行奖励
	local destxt = self._selfAward:getChildByFullName("destxt") 
	if not rank or rank > upperNum or rank == 0 or rank == "" then
        destxt:setString("排名进入" .. upperNum .. "名可获得：")
        createRewards(#sysData)
    else
    	destxt:setString("保持排名可获得：")
		for k,v in pairs(sysData) do
			local pos = v.rank
			if tonumber(rank) >= tonumber(pos[1]) and tonumber(rank) <= tonumber(pos[2]) then
		        createRewards(k)
		        break
		    end
		end
	end
end

function HappyPopRankView:createRoleHead(data,headNode,scaleNum)
	local avatarName = data.avatar
	local scale = scaleNum and scaleNum or 0.8
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"], plvl = data["plvl"]})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5 - 2)
	headNode:addChild(icon)
end

function HappyPopRankView:reflashNo1( data )
	local name = self._leftBoard:getChildByFullName("name")
	local level = self._leftBoard:getChildByFullName("level")
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildDes = self._leftBoard:getChildByFullName("guildDes")
	guildDes:setVisible(false)	
	name:setString("暂无榜首")
	level:setString("")	
	guild:setString("")

	if not data then 
		return 
	end

	--name
	local name = self._leftBoard:getChildByFullName("name")
	name:setString(data.name)

	--level
	local level = self._leftBoard:getChildByFullName("level")
	local inParam = {lvlStr = "Lv." .. (data.level or data.lvl or 0), lvl = data.level or data.lvl, plvl = data.plvl}
	UIUtils:adjustLevelShow(level, inParam, 1)

	--guild
	guildDes:setVisible(true)
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

    --guildImg
	local guildLeader = self._leftBoard:getChildByFullName("guildLeader")
	local guildImg = self._leftBoard:getChildByFullName("guildImg")
	if 21 == self._rankType then
		level:setString("联盟等级：" .. (data.level or data.lvl or 0))	
		guildImg:setVisible(true)
		local logoData = tab:GuildFlag(data.avatar2)
		if logoData and logoData.pic then
			guildImg:loadTexture(logoData.pic .. ".png",1)
		else
			guildImg:setVisible(false)
		end
		guildDes:setVisible(false)
		guildLeader:setVisible(false)
		if data.mName then
			guildLeader:setString("" .. data.mName)
		end
	else
		guildImg:setVisible(false)
		guildLeader:setVisible(false)
	end

	--click
	self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
		self:itemClicked(data)
	end)
end

function HappyPopRankView:addTableView( )
	self._tableViewH = 318
    self._tableView = cc.TableView:create(cc.size(616, 318))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(9,5))
    self._tableView:setDelegate()
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- self._tableView:setBounceEnabled(false)
    self._tableNode:addChild(self._tableView, 999)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
   
    -- tableView:reloadData()
end

function HappyPopRankView:createLoadingMc()
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

function HappyPopRankView:scrollViewDidScroll(view)
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
			self:sendMessageAgain()
			self:createLoadingMc()
			if self._loadingMc:isVisible() then
				self._loadingMc:setVisible(false)
			end		
		end
	end

end

function HappyPopRankView:tableCellTouched(table,cell)
    
end

function HappyPopRankView:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function HappyPopRankView:tableCellAtIndex(table, idx)
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

function HappyPopRankView:numberOfCellsInTableView(table)
	return #self._tableData
end

-- 接收自定义消息
function HappyPopRankView:reflashUI(data)
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

function HappyPopRankView:reflashNoRankUI()
	if (not self._tableData or #self._tableData <= 0) then
		self._noRankBg:setVisible(true)
		
	else
		self._noRankBg:setVisible(false)
	end
end

function HappyPopRankView:createItem( data,index )
	if data == nil then return end

	local item = self["_rankItem" .. itemIdx[self._rankType]]:clone()
	item:setContentSize(self._tableCellW,self._tableCellH)

	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

	local scoreLab = item:getChildByFullName("scoreLab")
	scoreLab:setColor(UIUtils.colorTable.ccUIBaseColor5)

	self._itemData = data
	item:setVisible(true)
	self._currItem = item
	item:setVisible(true)
	item.data = data
	local rank = data.rank
	local score = data.score

	local UIscoreLab = item:getChildByFullName("scoreLab")
	UIscoreLab:setString(score)

	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("0", UIUtils.ttfName, 28)
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

function HappyPopRankView:updateItem32()
	local item = self._currItem
	local data = self._itemData
	local name = data.name or ""
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)
	
	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createRoleHead(data,headNode,0.65)

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

function HappyPopRankView:itemClicked(data)
	if not data then 
		return 
	end

	self._param = {}
	if 21 == self._rankType then
		self._param = {type=self._rankType, roleId=data.rid or data._id, id=data.teamId}
		self._clickId = data.teamId
	else
		self._param = {type=self._rankType, roleId=data.rid or data._id}
	end

	self._itemData = data
	if data._id and data._id ~= 0 then
		self._clickItemData = self._itemData
		self:goView32()
	else
		print("=======数据异常-================")
	end
end

function HappyPopRankView:goView32()
	if not self._clickItemData then return end
	local fId = (self._clickItemData.lvl and  self._clickItemData.lvl >= 15) and 101 or 1
	self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = self._clickItemData.rid or self._clickItemData._id,fid=fId}, true, {}, function(result) 
		local data = result
		data.rank = self._clickItemData.rank
		data.usid = self._clickItemData.usid
		self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
    end)
end

--是否要刷新排行榜
function HappyPopRankView:sendMessageAgain()
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
function HappyPopRankView:searchForPosition(statCount,addCount,endCount)
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
	if tempH <= 0 or tempH < (self._tableCellH + 5) * 0.5 then --差值小于1个cell高度
		self._offsetY = self._tableViewH - #self._allRankData * (self._tableCellH+5)
	end
end

--获取排行榜数据
function HappyPopRankView:sendGetRankMsg(tp,start,callback)
	self._isSending = true
	self._rankModel:setRankTypeAndStartNum(tp,start)
	local acId = self._hPopModel:getAcData()
	self._serverMgr:sendMsg("RankServer", "getRankList", {type = tp, startRank = start, id = acId._id}, true, {}, function(result) 
		-- dump(result, "result", 10)
		if callback then
			callback()
		end
		self:reflashUI()
		self:reflashNoRankUI()
		self._isSending = false
    end)
end

function HappyPopRankView.dtor()
    titleTable = nil
	rankImgs = nil
	payerShow = nil
	showTable = nil
	itemIdx = nil
end

return HappyPopRankView