--
-- Author: huangguofang
-- Date: 2017-05-17 21:42:02
--

-- title4  奖励 评价

local TrainingRankDialog = class("TrainingRankDialog",BasePopView)
function TrainingRankDialog:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
	param = param or {}
	self._rankType = 9
	self._stageId = param.stageId or 23
	self._tabIdx = 1
	self._callBack = param.callback
	-- self._trainData = param.trainData or {}
	self._isActivityOpen = param.isAcOpen or false 
	self._endTime = param.endTime
	self._liveEndTime = param.liveEndTime
	self._Hscore = param.Hscore
	-- self._rankInitType = param.rankType or 1
	self._userModel = self._modelMgr:getModel("UserModel")
    self._trainModel = self._modelMgr:getModel("TrainingModel")
    self._rankModel = self._modelMgr:getModel("RankModel")

end

-- 初始化UI后会调用, 有需要请覆盖
function TrainingRankDialog:onInit()
	-- 通用动态背景
    -- self:addAnimBg()
	self:registerClickEventByName("bg.bgPanel.closeBtn", function()
		if self._timer then
			ScheduleMgr:unregSchedule(self._timer)
	        self._timer = nil
	    end
        self:close()
        if self._callBack then
        	self._callBack()
        end
        self._rankModel:clearRankList()
        UIUtils:reloadLuaFile("training.TrainingRankDialog")
    end)

    --排行榜信息数据
    self._trainingRank = tab.trainingRank
    -- 奖励
    self._trainingAward = tab.trainingAward

    self._seniorEvaluateImg = {
        [1] = "globalImgUI_pingjia4.png",
        [2] = "globalImgUI_pingjia3.png",
        [3] = "globalImgUI_pingjia2.png",
        [4] = "globalImgUI_pingjia1.png",
        [5] = "globalImgUI_pingjia1.png",
    }

    -- 黄执中 通关时间
    self._HPassTime = {}
    self._HPassTime[self._stageId] = self._Hscore
    local title3 = self:getUI("bg.bgPanel.titleBg.title3")
    title3:setString("时间")
    local title4 = self:getUI("bg.bgPanel.titleBg.title4")
    title4:setString(self._isActivityOpen and "奖励" or "评级")

    self._tabIdx = self:getTabIdxByStageId(self._stageId)
	self._itemData = nil
	self._bgPanel = self:getUI("bg.bgPanel")
	self._leftBoard = self:getUI("bg.bgPanel.leftBoard")
	self._noRankBg = self:getUI("bg.bgPanel.noRankBg")
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
	local rankShow = clone(tab:Setting("G_RANK_TRAINING").value)
	self.beginIdx = rankShow[1]
	self.addStep = rankShow[1]
	self.endIdx = rankShow[2]
    
    self._allRankData = self._rankModel:getRankList(self._rankType)[self._stageId] or {}

    self._offsetX = nil
    self._offsetY = nil
    self._tableView = nil
	self:addTableView()

	-- 初始化页签
	local tab1 = self:getUI("bg.bgPanel.tab1")
	tab1:setVisible(false)
	self._tabs = {}
	local posY = tab1:getPositionY()
	for i=1,#self._trainingRank do
		local trainRank = self._trainingRank[i] or {}
		--    TeamBtnUI_tab_p
		local tab = ccui.Button:create("TeamBtnUI_tab_n.png","TeamBtnUI_tab_n.png","TeamBtnUI_tab_p.png",1)	
		tab.__idx = i
		tab.__stageId = trainRank.training or 23
		tab:setPosition(0,posY )
		tab:setTitleFontName(UIUtils.ttfName)
		tab:setTitleFontSize(24)
		tab:setTitleText(" "..lang(trainRank.label))
		posY = posY - 76
		self._bgPanel:addChild(tab,10)
		table.insert(self._tabs,tab)
		
		UIUtils:setTabChangeAnimEnable(tab,678,function( )
			--切页签音效
			audioMgr:playSound("Tab")
			self:touchTab(i)
		end,nil,true)
	end

	-- 初始化界面显示，防止界面闪一下的情况
	self._tableData = self:updateTableData(self._allRankData,self.beginIdx) 
	self._tableView:reloadData()   --jumpToTop	
	
	--不请求数据点击tab 刷新有无排行榜的显示
	self:reflashNoRankUI()	
	--如果有数据则刷新自己信息
	if #self._tableData > 0 then
		self:reflashUserInfo()
	end

	self:touchTab(self._tabIdx or 1)

	self:reflashNo1()


    --结算倒计时文本
    self._cdTxt = self:getUI("bg.bgPanel.cdTxt")
	self._cdTxt:setVisible(false)
    local currTime = self._userModel:getCurServerTime()
    if self._endTime and self._endTime > currTime then    
    	self._cdTxt:setVisible(true)
	    self._cdTxt:setAnchorPoint(0,0.5)
	    self._cdTxt:setFontSize(16)
	    self._cdTxt:setPositionX(220)
	    self._cdTxt:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
        local currTime = self._userModel:getCurServerTime()
        local subTime = self._endTime - currTime
        local timeStr = TimeUtils.getTimeStringFont1(subTime)
        self._cdTxt:setString("结算倒计时：" .. timeStr)
    	if not self._timer then
	    	self._timer = ScheduleMgr:regSchedule(1000,self,function( )
	    		local currTime = self._userModel:getCurServerTime()
		        local subTime = self._endTime - currTime
		        local timeStr = TimeUtils.getTimeStringFont1(subTime)
		        self._cdTxt:setString("结算倒计时：" .. timeStr)
	            if subTime == 0 then
	                self._cdTxt:setString("结算倒计时：0天00:00:00")
	                ScheduleMgr:unregSchedule(self._timer)
	                self._timer = nil
	                -- self._cdTxt:setVisible(false)
	                self._cdTxt:setPositionX(278)
	                self._cdTxt:setString("活动已结束")
	            end
	        end)
	    end
	else
		self._cdTxt:setVisible(self._isActivityOpen)
		self._cdTxt:setString("活动已结束")
   	end

end

function TrainingRankDialog:touchTab( idx )
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

	-- print("==================",self._rankType)
	-- print("===========idx===========",idx)
	local tabBtn = self._tabs[idx]
	self._tabIdx = tabBtn.__idx
	self._stageId = tabBtn.__stageId	
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

		self._allRankData = self._rankModel:getRankList(self._rankType)[self._stageId] or {}
		self._tableData = {}
		local currTime = self._userModel:getCurServerTime()
		if #self._allRankData < 1 then
			--请求数据点击tab 回调reflashUI里刷新有无排行榜的显示以及数据的刷新		
			self:sendGetRankMsg(self._rankType,1,function()
				-- 刷新
				self._allRankData = self._rankModel:getRankList(self._rankType)[self._stageId] or {}
				self._tableData = self:updateTableData(self._allRankData,self.beginIdx) 
				self._tableView:reloadData()

				--如果有数据则刷新自己信息
				if #self._tableData > 0 then
					self:reflashUserInfo()
				end
				-- 更新黄执中时间
				if self._liveEndTime and currTime < self._liveEndTime then
					self._HTimeTxt:setVisible(false)
					self._HTime:setVisible(false)
				else	
					self._HTimeTxt:setVisible(true)
					self._HTime:setVisible(true)				
					self._HTime:setString((self._HPassTime[self._stageId] or 0) .. "s")
					UIUtils:center2Widget( self._HTimeTxt,self._HTime,self._leftBoard:getContentSize().width*0.5,2 )
				end
			end)
			self._firstIn = true
		else
			self._firstIn = false
			self._tableData = self:updateTableData(self._allRankData,self.beginIdx) 
			self._tableView:reloadData()   --jumpToTop
			
			--不请求数据点击tab 刷新有无排行榜的显示
			self:reflashNoRankUI()

			-- 更新黄执中时间
			if self._liveEndTime and currTime < self._liveEndTime then
				self._HTimeTxt:setVisible(false)
				self._HTime:setVisible(false)
			else	
				self._HTimeTxt:setVisible(true)
				self._HTime:setVisible(true)				
				self._HTime:setString((self._HPassTime[self._stageId] or 0) .. "s")
				UIUtils:center2Widget( self._HTimeTxt,self._HTime,self._leftBoard:getContentSize().width*0.5,2 )
			end
		end
		
		--如果有数据则刷新自己信息
		if #self._tableData > 0 then
			self:reflashUserInfo()
		end


		
	end,nil,true)

end

function TrainingRankDialog:updateTableData(rankList,index)
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
function TrainingRankDialog:reflashUserInfo()
	local item  = self._rankSelfItem
	local nameLab = item:getChildByFullName("nameLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")
	local secName = item:getChildByFullName("secName")

	local rankData = self._rankModel:getSelfRankInfoById(self._rankType,self._stageId)
	
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
	local txt2  = item:getChildByFullName("rankTxt1")
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

	if not txt2 then
		txt2 = ccui.Text:create()
		txt2:setName("rankTxt1")
		txt2:setString("未通过挑战")
		txt2:setFontSize(24)
		txt2:setPosition(460, 45)
		txt2:setFontName(UIUtils.ttfName)
		txt2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		item:addChild(txt2)	
	end
	
	txt:setVisible(false)
	txt2:setVisible(false)
	-- 没有排名 显示暂未上榜
	if not rank or rank == 0 or rank == "" then
		rankLab:setVisible(false)
		txt:setVisible(true)
		self:registerClickEvent(item,function( )

		end)
	else		
		self:registerClickEvent(item,function( )
			self:selfItemClicked(rankData)	       
		end)
	end		

	local userData = self._modelMgr:getModel("UserModel"):getData()
	nameLab:setString(userData.name)
	local scoreStr = self._trainModel:getPassTimeById(self._stageId) or 0   --显示时间
	if tonumber(scoreStr) == 0 then
		scoreStr = ""
		txt2:setVisible(true)
	else
		scoreStr = scoreStr .. "s"
	end
	UIscoreLab:setString(scoreStr)

	local platformStr ,idStr = self._userModel:getPlatformInfoById(userData.sec or 0)
    secName:setString(platformStr .. " " .. idStr)

	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	self:createRoleHead(userData,headNode,0.7)

	-- 初始化奖励面板	
	self:initawardPane(item,rankData.score,rankData.rank)

end

function TrainingRankDialog:reflashNo1( data )
	-- print("======================reflashNo1()")
	-- dump(data,"data")
	self._leftBoard = self:getUI("bg.bgPanel.leftBoard")
	local titleTxt = self:getUI("bg.bgPanel.leftBoard.titleTxt")
	self._HTimeTxt = self:getUI("bg.bgPanel.leftBoard.scoreTxt")
	self._HTime = self:getUI("bg.bgPanel.leftBoard.score")
	titleTxt:setFontSize(30)
	titleTxt:setColor(UIUtils.colorTable.ccUITxtColor1)
	titleTxt:enable2Color(1,UIUtils.colorTable.ccUITxtColor2)
	titleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	titleTxt:setString("黄执中成绩")
	self._HTimeTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._HTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

	self._HTimeTxt:setString("时间")
	-- 更新黄执中时间
	local currTime = self._userModel:getCurServerTime()
	if self._liveEndTime and currTime < self._liveEndTime then
		self._HTimeTxt:setVisible(false)
		self._HTime:setVisible(false)
	else	
		self._HTimeTxt:setVisible(true)
		self._HTime:setVisible(true)				
		self._HTime:setString((self._HPassTime[self._stageId] or 0) .. "s")
		UIUtils:center2Widget( self._HTimeTxt,self._HTime,self._leftBoard:getContentSize().width*0.5,2 )
	end
	
end

function TrainingRankDialog:addTableView( )
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

function TrainingRankDialog:createLoadingMc()
	if self._loadingMc then return end
	-- 添加加载中动画
	self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._bgPanel:getContentSize().width*0.5 - 30, self._tableNode:getPositionY() + 20))
    self._bgPanel:addChild(self._loadingMc, 20)
    self._loadingMc:setVisible(false)
end

function TrainingRankDialog:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()

    local offsetY = view:getContentOffset().y   
    -- print("========================offsetY===",offsetY)	
	-- if offsetY >= 60 and #self._tableData > 5 and #self._tableData < self.endIdx[self._stageId] and not self._canRequest then
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

function TrainingRankDialog:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function TrainingRankDialog:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function TrainingRankDialog:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function TrainingRankDialog:tableCellAtIndex(table, idx)
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

function TrainingRankDialog:numberOfCellsInTableView(table)
	-- print("#self._tableData",#self._tableData)
	return #self._tableData
	
end

-- 接收自定义消息
function TrainingRankDialog:reflashUI(data)

end

function TrainingRankDialog:reflashRankUI()
	local offsetX = nil
	local offsetY = nil
	if self._offsetX and self._offsetY then
		offsetX = self._offsetX
		offsetY = self._offsetY
	end
    self._allRankData = self._rankModel:getRankList(self._rankType)[self._stageId]
    self._tableData = self:updateTableData(self._allRankData,self.beginIdx)
   	
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
end

function TrainingRankDialog:reflashNoRankUI()
	if (not self._tableData or #self._tableData <= 0) then
		-- print("==================reflashNoRankUI============")
		-- print("=====================self._rankType=",self._rankType)
		self._noRankBg:setVisible(true)
		self._tableNode:setVisible(false)
		self._titleBg:setVisible(false)
	else
		
		self._noRankBg:setVisible(false)
		self._tableNode:setVisible(true)
		self._titleBg:setVisible(true)
	end
end

function TrainingRankDialog:createItem( data,index )
	if data == nil then return end

	local item = self._rankItem:clone()

	self._itemData = data
	item:setVisible(true)
	item.data = data
	local rank = data.rank
	local name = data.name or ""
	local scoreStr = data.time or 0   -- 显示时间
	
	local nameLab = item:getChildByFullName("nameLab")
	nameLab:setString(name)
	local UIscoreLab = item:getChildByFullName("scoreLab")
	UIscoreLab:setString(scoreStr .. "s")
	local secName = item:getChildByFullName("secName")
	local platformStr ,idStr = self._userModel:getPlatformInfoById(data.secId or 0)
    secName:setString(platformStr .. " " .. idStr)

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

	-- 初始化奖励面板	
	self:initawardPane(item,data.score,data.rank)

	return item
end

function TrainingRankDialog:initawardPane(item,score,rankNum)
	-- if true then return end 
	local awardPanel = item:getChildByFullName("awardPanel")
	if awardPanel then
		awardPanel:removeAllChildren()
	end

    if not rankNum or  rankNum <= 0 then return end
    if self._isActivityOpen then
    	local awardData = self:getAwardByStageId(rankNum) or {}
    	local award = awardData["award" .. self._stageId]
    	if award then
	    	for k,v in pairs(award) do
		        local itemId 
	            if v[1] == "tool" then
	                itemId = v[2]
	            else
	                itemId = IconUtils.iconIdMap[v[1]]
	            end
	            local toolD = tab:Tool(tonumber(itemId))
	            local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
	            icon:setScale(0.55)
	            icon:setPosition(cc.p((tonumber(k)-1)*53,8)) 
	            awardPanel:addChild(icon)
	    	end
	    end
    else
    	--已通标志
	    local evaluateData = self._trainModel:getEvaluateDataByScore(score or 0)
	    local passImg = ccui.ImageView:create()
	    passImg:loadTexture(self._seniorEvaluateImg[tonumber(evaluateData.evaluate)],1)
	    passImg:setAnchorPoint(cc.p(0.5,0.5))
	    passImg:setName("passImg")
	    passImg:setScale(0.8)
	    passImg:setPosition(awardPanel:getContentSize().width*0.5,awardPanel:getContentSize().height*0.5)
	    awardPanel:addChild(passImg,2) 
    end

end

function TrainingRankDialog:createRoleHead(data,headNode,scaleNum)
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

function TrainingRankDialog:selfItemClicked(data)
	
	if not data then return end
	local param = {}
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local uData = {}
	uData.usid = userData.usid
	uData.rank = data.rank
	uData._id = userData._id
	uData.lvl = userData.level
	self:showDetailPanel(uData)
end

function TrainingRankDialog:itemClicked(data)
	-- body
	if not data then return end
	local param = {}
	self:showDetailPanel(data)	
end

function TrainingRankDialog:showDetailPanel(data)
	if not data then return end
	local rid = data._id

	-- 获取上榜时的数据信息
	local fId = (data.lvl and  data.lvl >= 15) and 101 or 1
	self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = data.rid or data._id,fid=fId,fsec=data.secId}, true, {}, function(result) 
		local data = result
		data.rank = data.rank
		data.isNotShowBtn = true
		self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
    end)

end

--是否要刷新排行榜
function TrainingRankDialog:sendMessageAgain()
	-- self.beginIdx -- self.endIdx -- self.addStep
	self._allRankData = self._rankModel:getRankList(self._rankType)[self._stageId]
	local rankData = self._rankModel:getRankList(self._rankType)
	local startNum = rankData[self._stageId] and #rankData[self._stageId] + 1 or 1
	local startCount = tonumber(self.beginIdx)
	local endCount = tonumber(self.endIdx)
	local addCount = tonumber(self.addStep)

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
function TrainingRankDialog:searchForPosition(startCount,addCount,endCount)	
	if startCount + addCount <= endCount then
		self.beginIdx = startCount + addCount
		local subNum = #self._allRankData - startCount		
		if subNum < addCount then
			self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))			
		else
			self._offsetY = -1 * (tonumber(self.addStep) * (self._tableCellH+5))			
		end
		
	else
		self.beginIdx = endCount
		self._offsetY = -1 * (endCount - startCount) * (self._tableCellH+5)
	end
	-- if #self._allRankData <= 4 then
	-- 	self._offsetY = self._tableViewH - #self._allRankData * (self._tableCellH+5)
	-- 	self._offsetY = self._offsetY > 0 and self._offsetY or 0
	-- end
end
--获取排行榜数据
function TrainingRankDialog:sendGetRankMsg(tp,start,callback)
	self._isSending = true
	self._rankModel:setRankTypeAndStartNum(tp,start)
	self._serverMgr:sendMsg("TrainingServer", "getTrainingRankByTrainId", {id=self._stageId,startRank = start}, true, {}, function(result) 
		if result and result.targetScore then
			self._HPassTime[self._stageId] = result.targetScore
		end
		if callback then
			callback()
		end
		self:reflashRankUI()
		self:reflashNoRankUI()
		self._isSending = false
    end)
end

-- 根据 stageId 找到对应页签
function TrainingRankDialog:getTabIdxByStageId(stageId)
	local index = 1
	for i,v in ipairs(self._trainingRank) do
		if tonumber(v.training) == tonumber(stageId) then
			index = i
		end
	end

	return index
end

-- 根据名次获得奖励
function TrainingRankDialog:getAwardByStageId(rankNum)
	if not rankNum then return self._trainingAward[#self._trainingAward] end
	local awardData 
	for i,v in ipairs(self._trainingAward) do
		if v.rank and v.rank[1] and v.rank[2] then
			if tonumber(rankNum) >= tonumber(v.rank[1]) and rankNum <= v.rank[2] then
				awardData = v 
				break
			end
		end
	end
	if not awardData then
		awardData = self._trainingAward[#self._trainingAward]
	end
	return awardData
end


function TrainingRankDialog.dtor()
    
end

return TrainingRankDialog