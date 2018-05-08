--
-- Author: huangguofang
-- Date: 2016-09-02 14:39:22
--
local ACGreenDragonView = class("ACGreenDragonView",BasePopView)
function ACGreenDragonView:ctor()
    self.super.ctor(self)
    self._rankData = {}
    self._myRankData = {}
    self._rankModel = self._modelMgr:getModel("RankModel")
end

function ACGreenDragonView:getAsyncRes()
    return 
    {
        {"asset/ui/activityDragon.plist", "asset/ui/activityDragon.png"},
        "asset/bg/greenDragon_bgImg.png",
    }
end
function ACGreenDragonView:onDestroy()
	-- body
	cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/bg/greenDragon_bgImg.png")
	ACGreenDragonView.super.onDestroy(self)
end

-- 初始化UI后会调用, 有需要请覆盖
function ACGreenDragonView:onInit()	
	--获取战力排行榜数据
	self:sendGetRankMsg(1,1)

	--关闭按钮
	self:registerClickEventByName("bg.closeBtn", function() 
		self._rankModel:clearRankList()
		self:close() 
		UIUtils:reloadLuaFile("activity.acdragon.ACGreenDragonView" )
	end)

	--设置背景
	local dragonPanel = self:getUI("bg.dragonPanel")
	local bgImg = self:getUI("bg.dragonPanel.bgImg")
	bgImg:setBackGroundImage("asset/bg/activity_bg_paper.png")
	self:getUI("bg.dragonPanel.skillPlayBtn"):setVisible(true)
	-- dragonPanel:setBackGroundImage("asset/bg/greenDragon_bgImg.png")
	--技能展示按钮
	self:registerClickEventByName("bg.dragonPanel.skillPlayBtn", function() 		
		-- self._viewMgr:showDialog("global.GlobalSkillPreviewDialog", {teamId = 107, skillId = tonumber(50023)},true)
		self._viewMgr:showDialog("global.GlobalPlaySkillDialog", {teamId = 107, teamName = "大天使",mcName = "tianshiyanshi_tianshiyanshi", bgImg = "skillPreviewBg.png"},true)
		-- self._viewMgr:showDialog("global.GlobalPlaySkillDialog", {teamId = 207, teamName = "绿龙",mcName = "lvlongjinengyanshi_lvlongjinengyanshi", bgImg = "skillPreviewBg.png"},true)
	end)
	-- title
	local titleText = self:getUI("bg.dragonPanel.dragonTitleBg.titleTxt")
	titleText:setString("提升战力送天使")
	UIUtils:setTitleFormat(titleText, 5)
	--初始化layer
	self._listLayer = self:getUI("bg.dragonPanel.listLayer")
	self._panelLayer = self:getUI("bg.dragonPanel.panelLayer")
	self._listLayer:setVisible(true)
	self._panelLayer:setVisible(false)

	self._titleBg = self:getUI("bg.dragonPanel.titleBg")

	--倒计时label
	local cdtxt = self:getUI("bg.dragonPanel.CDbg.Label_100")
	cdtxt:setFontName(UIUtils.ttfName_Title)
	cdtxt:setColor(cc.c3b(255,230,65))
	cdtxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._timeLabel = self:getUI("bg.dragonPanel.timeTxt")
	self._timeLabel:setColor(cc.c3b(255,247,213))
	self._timeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	-- self._timeLabel:setVisible(false)
	--暂时不加倒计时，规则不确定
	self:startCountdown()

	
	--初始化数据
	--showType 1 >> 列表 ;2 >> layer面板 
	local rankAward = clone(tab.combatRankAward)
	local stageAward = clone(tab.combatStageAward)	
	table.sort(rankAward,function ( a,b )
	    return a.id < b.id
	end)
	table.sort(stageAward,function ( a,b )
	    return a.stage > b.stage
	end)
	self._showData = {
		[1] = {showType=1,showData=rankAward}, 	-- 奖励数据
		[2] = {showType=1,showData=stageAward},
		-- [3] = {showType=1,showData=self._rankData},

		[4] = {showType=2,showlayer="activity.acdragon.ACGreenDragonTeamLayer"},
		[5] = {showType=2,showlayer="activity.acdragon.ACGreenDragonRuleLayer"},
	}
	self._tableView = nil
	self._currBtn = 0
	self._tableData = {}--self._showData[1].showData

	-- 上拉刷新数据
	self.beginIdx = 20
	self.addStep = 20
	self.endIdx = 100
	-- cell height and width
	self._tableCellH = 112
	self._tableCellW = 646
	-- self:addTableView()

	--按钮Table
	self._btnTable = {}
	local btnName = {
		[1] = "排名奖励",
		[2] = "战力奖励",
		[3] = "排名奖励",
		[4] = "天使介绍",
		[5] = "活动规则",
	}
	for i=2,5 do
		local btn = self:getUI("bg.dragonPanel.btnPanel.btn" .. i)
		btn:getTitleRenderer():disableEffect()
        btn:setTitleFontSize(24) 
        btn:setTitleFontName(UIUtils.ttfName)
        btn:setTitleText(btnName[i])
		self._btnTable[i] = btn
		registerClickEvent(btn,function(sender) 	
		    self:updateBtnState(i)		    
	    end)
	end
	-- 切换页签，重新创建tableView
	self:updateBtnState(3)
end

--更新按钮状态
function ACGreenDragonView:updateBtnState(idx)
	-- body
	if self._currBtn == idx then return end
			
	self._currBtn = idx
	-- 重新添加tableView
	self:addTableView()
	--切页停止滚动
	if self._tableView then
		self._tableView:stopScroll()
	end

	if self._loadingMc and self._loadingMc:isVisible() then
		self._loadingMc:setVisible(false)
	end	
	for i=2,5 do
		local btn = self._btnTable[i]
		btn:loadTextures("globalPanelUI_activity_normalBtn.png","globalPanelUI_activity_normalBtn.png","",1)		
        btn:setTitleColor(cc.c4b(78,50,13,255))  
		-- btn:enableOutline(cc.c4b(35,108,32,255),2)
	end
	local currBtn = self._btnTable[self._currBtn]
	currBtn:loadTextures("globalPanelUI_activity_selectBtn.png","globalPanelUI_activity_selectBtn.png","",1)
	currBtn:setTitleColor(cc.c4b(198,79,37,255))  
	-- currBtn:enableOutline(cc.c4b(43,87,183,255),2)
	self:updateContentPanel()

end
--更新主面板展示
function ACGreenDragonView:updateContentPanel()
	-- 第三个页签但是没有数据
	-- if 3 == self._currBtn and not self._showData[3] then
	-- 	--获取战力排行榜数据
	-- 	self:sendGetRankMsg(1,1)
	-- end
	-- 顶部描述
	local titleTxt1 = self:getUI("bg.dragonPanel.desTxt1")
	titleTxt1:setVisible(false)
	local titleTxt2 = self:getUI("bg.dragonPanel.desTxt2")
	titleTxt2:setVisible(false)
	-- <=3 显示tableView 
	if self._currBtn <= 3 then		
	    self._listLayer:setVisible(true)	    
	    self._panelLayer:setVisible(false)	   
		-- 顶部描述
		if self._currBtn == 3 then
			self._titleBg:setVisible(true)
			titleTxt1:setVisible(true)
			titleTxt1:setString(lang("ranktips1"))
		else
			self._titleBg:setVisible(false)
			titleTxt2:setVisible(true)
			titleTxt2:setString(lang("ranktips" .. self._currBtn))
		end
		-- tableView数据更新
	    if self._showData[self._currBtn] and self._showData[self._currBtn].showData then
			self._tableData = self._showData[self._currBtn].showData
		    if self._tableData and self._tableView then
		    	self._tableView:reloadData()
		    end
		end
	else		
		self._listLayer:setVisible(false)
		self._titleBg:setVisible(false)
		self._panelLayer:setVisible(true)
		self._panelLayer:removeAllChildren()
		if self._showData[self._currBtn] and self._showData[self._currBtn].showlayer then
			local layerName = self._showData[self._currBtn].showlayer
			self:createLayer(layerName, {}, true, function (_layer)		       
		        _layer:setPosition(0, 0)
		        _layer:setName("dragonLayer")
		        self._panelLayer:addChild(_layer)
		    end)
		end
	end

end

--更新玩家面板的显示
function ACGreenDragonView:initUserInfo()
	--我的战斗力
	local scoreTxt = self:getUI("bg.dragonPanel.myScore")
	scoreTxt:setVisible(false)
	self._score = cc.Label:createWithBMFont(UIUtils.bmfName_zhandouli, "00")
	self._score:setString(self._myRankData.score or 0)
	self._score:setScale(0.5)
	self._score:setAnchorPoint(cc.p(0,0.5))  
    self._score:setPosition(scoreTxt:getPositionX()+4,scoreTxt:getPositionY()+4)
    scoreTxt:getParent():addChild(self._score, 2)

    self._rank = self:getUI("bg.dragonPanel.myRank")
    if self._myRankData.rank and 0 == self._myRankData.rank then
    	self._myRankData.rank = "暂无排名"
    end
    self._rank:setString(self._myRankData.rank or "暂无排名")
end
function ACGreenDragonView:addTableView()
	if self._tableView then
		self._tableView:removeFromParent()
		self._tableView = nil
	end
	local width = self._listLayer:getContentSize().width
	self._tableViewH = self._listLayer:getContentSize().height
	self._tableViewH = self._currBtn == 3 and self._tableViewH or self._tableViewH + 34
	local tableView = cc.TableView:create(cc.size(width, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(5,2))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(false)
    self._listLayer:addChild(tableView,999)
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

--[[
function ACGreenDragonView:createLoadingMc()
	if self._loadingMc then return end
	-- 添加加载中动画
	self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._listLayer:getContentSize().width*0.5 - 30, 20))
    self._listLayer:addChild(self._loadingMc, 1000)
    self._loadingMc:setVisible(false)
end
]]
function ACGreenDragonView:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
	--[[
	if 3 == self._currBtn then
		local offsetY = view:getContentOffset().y
		local condY = 0
		if self._tableData and #self._tableData < 4 then
			-- tableView height 
			condY = self._tableViewH - #self._tableData*(self._tableCellH)
		end
		if offsetY >= 100 and #self._tableData > 5 and #self._tableData < 100 and not self._canRequest then
			self._canRequest = true
			self:createLoadingMc()
			if not self._loadingMc:isVisible() then
				self._loadingMc:setVisible(true)
			end
		end				
	   
		if self._inScrolling then
		    if offsetY >= condY+100 and not self._canRequest then
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
				if self._loadingMc:isVisible() then
					self._loadingMc:setVisible(false)
				end		
			end
		end
	end
	]]
end

function ACGreenDragonView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function ACGreenDragonView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function ACGreenDragonView:cellSizeForTable(table,idx) 
    return self._tableCellH,self._tableCellW
end

function ACGreenDragonView:tableCellAtIndex(table, idx)
	-- print("============tableCellAtIndex table =====================")
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local cellData = self._tableData[idx+1]

    --三种不同的item
    local item
    -- if self._currBtn == 1 then
    -- 	item = self:createItem1(cellData,idx+1)
   	-- else
   	if self._currBtn == 2 then
   		item = self:createItem2(cellData,idx+1)
   	elseif self._currBtn == 3 then
   		local awardData = self._showData[1] and self._showData[1].showData or {}
   		if not awardData then
   			awardData = {}
   		end
   		item = self:createItem3(cellData,awardData[idx+1],idx+1)   	
   	end
   	if item then
   		item:setPosition(0, 2)
   		cell:addChild(item)
   	end
    return cell
end

function ACGreenDragonView:numberOfCellsInTableView(table)
	-- print("#self._tableData*************",#self._tableData)
	return #self._tableData
	
end

local rankImgData = {"arenaRank_first.png","arenaRank_second.png","arenaRank_third.png"}
-- local itemColor = {cc.c4b(72,38,0,255),cc.c4b(72,38,0,255),cc.c4b(72,38,0,255)}
--[[
function ACGreenDragonView:createItem1( data,index )
	if not data then return end
	local rank = data.id
	local layer = ccui.Layout:create()
	layer:setAnchorPoint(cc.p(0,0))
	layer:setContentSize(cc.size(646, 108))
	layer:setBackGroundImage("globalPanelUI_activity_cellBg.png",1)
	layer:setBackGroundImageScale9Enabled(true)
	layer:setBackGroundImageCapInsets(cc.rect(55,55,1,1))

	local rankBgImg = ccui.ImageView:create()
	rankBgImg:setName("rankBgImg")
	rankBgImg:setScale(0.75)
	rankBgImg:loadTexture("globalImageUI_awardNothing.png",1)		
    rankBgImg:setPosition(cc.p(0,52))
    rankBgImg:setAnchorPoint(cc.p(0,0.5))	
	layer:addChild(rankBgImg)

	--排名
	if rank <= 3 then
		bgImg:loadTexture("globalPanelUI_activity_cellBg" .. rank .. ".png",1)
		rankImg = ccui.ImageView:create()
		rankImg:setName("rankImg")
		rankImg:loadTexture(rankImgData[rank],1)		
	    rankImg:setPosition(cc.p(58,52))
	    rankImg:setAnchorPoint(cc.p(0.5,0.5))	
		layer:addChild(rankImg,1)
	else
		--我的战斗力
		local rankTxt = cc.Label:createWithBMFont(UIUtils.bmfName_rank, "00")
		rankTxt:setName("rankTxt")
		rankTxt:setString(rank)
		rankTxt:setAnchorPoint(cc.p(0.5,0))  
	    rankTxt:setPosition(cc.p(58,47))
	    layer:addChild(rankTxt, 2)
	end	

    --奖励容器
	local rewardLayer = ccui.Layout:create()
	rewardLayer:setAnchorPoint(cc.p(0,0))
	rewardLayer:setPosition(160, 2)
	rewardLayer:setContentSize(cc.size(320, 60))
	layer:addChild(rewardLayer,3)

	--[1]={award={'gold',0,400000},limit=220000,id=1},

	local showType = data.type or 1
	local iconW = 88 
	if 0 == showType then
		iconW = 120
	end
	local rewardNum = #data.awardshow
	for k,v in pairs(data.awardshow) do
		local itemId 

		local icon 
		if v[1] == "team" then
			local teamD = tab:Team(v[2])		
			icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,isGray = false ,eventStyle = 1,isJin=true})
			local diguang = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888) 
			diguang:setPosition(icon:getContentSize().width/2-12, icon:getContentSize().height/2-6)
			-- diguang:setScale(1.1)
			local diguangParent = icon:getChildByName("teamIcon") or icon
			diguangParent:addChild(diguang,-1)

			local saoguang = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"})
			local effectParent = icon:getChildByName("iconColor") or icon
			effectParent:addChild(saoguang,5)  
		else
			if v[1] == "tool" then
				itemId = v[2]
			else
				itemId = IconUtils.iconIdMap[v[1] ]
			end
			local toolD = tab:Tool(tonumber(itemId))
			
			local toolData = tab:Tool(itemId)
			-- tabId == 1 兵团碎片
			-- print("=========兵团碎片============",v[1],itemId)
			if toolData then
		        if toolData.tabId == 1 then
		            local teamId = string.sub(itemId, 2, string.len(itemId))
		            local hadTeam = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(teamId))
		            local eventStyle = 3
		            --如果拥有弹tips，没拥有则弹详情
		            if hadTeam then
		                eventStyle = 1 
		            end
		            icon = IconUtils:createItemIconById({itemId = itemId,num = v[3],eventStyle = eventStyle,effect = false,clickCallback= function( )
		                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = 15, iconId = tonumber(teamId)}, true) -- 15 本地数据兵团
		            end})
		        else
		            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})       
		        end
		    end
		end

		-- N选1  
		-- 1 全部获得  0 N选1
		if 0 == showType and k < rewardNum then
			local txt = ccui.Text:create()
			txt:setFontSize(24)
			txt:setColor(cc.c4b(72,38,0,255))
			txt:setFontName(UIUtils.ttfName)
			txt:setString("或")
			txt:setName("selectTip" .. k)
			txt:setPosition(k*iconW-5,50)
		    rewardLayer:addChild(txt)
		end

		icon:setScale(0.8)
		icon:setSwallowTouches(false)
		icon:setAnchorPoint(cc.p(0,0))
		icon:setPosition(cc.p(14+(k-1)*iconW,8))
		rewardLayer:addChild(icon)
	end

	layer:setSwallowTouches(false)	
	-- local children = layer:getChildren()
	-- for k,v in pairs(children) do
	-- 	v:setSwallowTouches(false)
	-- end
	-- 添加特效
	
	if rank <= 3 then
		for i=1,3 do
			local rankImg = layer:getChildByFullName("rankImg")
			local rankMc = rankImg:getChildByFullName("rankmc" .. i)
			if 1 == i then
				if not rankMc then				
					rankMc = mcMgr:createViewMC("diyiming_paimingeffect", true, false, function (_, sender)
			        end)
			        rankMc:setName("rankmc1")
			        rankMc:setScale(0.8)
			        rankMc:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5 - 2))
			        rankImg:addChild(rankMc, -1)
			    end
	       else
	       		if not rankMc then
			       	rankMc = mcMgr:createViewMC("ersanming_paimingeffect", true, false, function (_, sender)
		            end)
		            rankMc:setName("rankmc" .. i)
		            rankMc:setScale(0.8)
		            rankMc:setPosition(cc.p(rankImg:getContentSize().width*0.5, rankImg:getContentSize().height*0.5))
		            rankImg:addChild(rankMc, -1)
		        end
	        end
		end	
	end	

	return layer
end
]]
function ACGreenDragonView:createItem2( data,index )
	if not data then return end
	-- local limit = data.stage
	local layer = ccui.Layout:create()
	layer:setAnchorPoint(cc.p(0,0))
	layer:setContentSize(cc.size(646, 108))
	
	local bgImg = ccui.ImageView:create()
	bgImg:setName("bgImg")
	bgImg:loadTexture("globalPanelUI_activity_cellBg.png",1)
	bgImg:setScale9Enabled(true)
	bgImg:setCapInsets(cc.rect(40, 40, 1, 1))
	bgImg:setContentSize(646,108)
    bgImg:setPosition(cc.p(0,0))
    bgImg:setAnchorPoint(cc.p(0,0))	
	layer:addChild(bgImg)

	local rankBgImg = ccui.ImageView:create()
	rankBgImg:setName("rankBgImg")
	rankBgImg:setScale(0.75)
	rankBgImg:loadTexture("globalImageUI_awardNothing.png",1)		
    rankBgImg:setPosition(cc.p(0,52))
    rankBgImg:setAnchorPoint(cc.p(0,0.5))	
	layer:addChild(rankBgImg)

	-- 前三
	if index <= 3 then
		bgImg:loadTexture("globalPanelUI_activity_cellBg" .. index .. ".png",1)
	end
	--条件
	local conditionTxt = ccui.Text:create()
    conditionTxt:setString("战力达到")
    conditionTxt:setFontSize(20)
    conditionTxt:setPosition(58, 52)
    conditionTxt:setFontName(UIUtils.ttfName)
    conditionTxt:setAnchorPoint(cc.p(0.5,0))
    conditionTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    layer:addChild(conditionTxt,2)

    --条件限制
	local conditionValue = ccui.Text:create()
    conditionValue:setString(data.stage)
    conditionValue:setFontSize(26)
    conditionValue:setPosition(58, 58)
    conditionValue:setFontName(UIUtils.ttfName)
    conditionValue:setAnchorPoint(cc.p(0.5,1))
    conditionValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    layer:addChild(conditionValue,2)

    --奖励容器
	local rewardLayer = ccui.Layout:create()
	rewardLayer:setAnchorPoint(cc.p(0,0))
	rewardLayer:setPosition(160, 2)
	rewardLayer:setContentSize(cc.size(320, 100))
	layer:addChild(rewardLayer,3)

	--[1]={award={'gold',0,400000},limit=220000,id=1},
	for k,v in pairs(data.award) do
		local itemId 
		local icon 
		if v[1] == "team" then
			local teamD = tab:Team(v[2])		
			icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,isGray = false ,eventStyle = 1,isJin=true})
			local diguang = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888) 
			diguang:setPosition(icon:getContentSize().width/2-5, icon:getContentSize().height/2-5)
			-- diguang:setScale(1.1)
			local diguangParent = icon:getChildByName("teamIcon") or icon
			diguangParent:addChild(diguang,-1)

			local effectParent = icon:getChildByName("iconColor") or icon
			local saoguang = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"},effectParent)
			-- saoguang:setScale(effectParent:getContentSize().width/90)
			saoguang:setPosition(0,0)
			effectParent:addChild(saoguang,5)  
			icon:setScale(0.7)
			icon:setPosition(14+(k-1)*88,15)
		elseif v[1] == "avatarFrame" then
			itemId = v[2]
			local frameData = tab:AvatarFrame(itemId)
	        param = {itemId = itemId, itemData = frameData}
	        icon = IconUtils:createHeadFrameIconById(param)
	        icon:setPosition(16+(k-1)*88,15)
	        icon:setScale(0.7)
		else
			if v[1] == "tool" then
				itemId = v[2]
			else
				itemId = IconUtils.iconIdMap[v[1]]
			end
			local toolD = tab:Tool(tonumber(itemId))
			
			local toolData = tab:Tool(itemId)
			-- tabId == 1 兵团碎片
			-- print("=========兵团碎片============",v[1],itemId)
			if toolData then
		        if toolData.tabId == 1 then
		            local teamId = string.sub(itemId, 2, string.len(itemId))
		            local hadTeam = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(teamId))
		            local eventStyle = 3
		            --如果拥有弹tips，没拥有则弹详情
		            if hadTeam then
		                eventStyle = 1 
		            end
		            icon = IconUtils:createItemIconById({itemId = itemId,num = v[3],eventStyle = eventStyle,effect = false,clickCallback= function( )
		                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = 15, iconId = tonumber(teamId)}, true) -- 15 本地数据兵团
		            end})
		        else
		            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})       
		        end
		    end
			icon:setScale(0.8)
			icon:setPosition(14+(k-1)*88,15)
		end

		icon:setSwallowTouches(false)
		icon:setAnchorPoint(0,0)
		
		rewardLayer:addChild(icon)
	end

	layer:setSwallowTouches(false)	
	-- local children = layer:getChildren()
	-- for k,v in pairs(children) do
	-- 	v:setSwallowTouches(false)
	-- end
	
	return layer
end

function ACGreenDragonView:createItem3( data,awardData,index )
	if data == nil then return end
	-- self._itemData = data
	if not data then return end
	local rank = tonumber(data.rank) or 0
	local score = tonumber(data.score) or 0
	local name = data.name	or ""
	local level = data.level or data.lvl or 0
	local score = data.score or 0

	local layer = ccui.Layout:create()
	layer:setAnchorPoint(cc.p(0,0))
	layer:setContentSize(cc.size(646, 108))
	-- layer:setBackGroundImage("globalPanelUI_activity_cellBg.png",1)
	-- layer:setBackGroundImageCapInsets(cc.rect(50,50,1,1))
	-- layer:setBackGroundImageScale9Enabled(true)

	local bgImg = ccui.ImageView:create()
	bgImg:setName("bgImg")
	bgImg:loadTexture("globalPanelUI_activity_cellBg.png",1)
	bgImg:setScale9Enabled(true)
	bgImg:setCapInsets(cc.rect(40, 40, 1, 1))
	bgImg:setContentSize(646,108)
    bgImg:setPosition(cc.p(0,0))
    bgImg:setAnchorPoint(cc.p(0,0))	
	layer:addChild(bgImg)

	local rankBgImg = ccui.ImageView:create()
	rankBgImg:setName("rankBgImg")
	rankBgImg:setScale(0.7)
	rankBgImg:loadTexture("globalImageUI_awardNothing.png",1)		
    rankBgImg:setPosition(cc.p(0,52))
    rankBgImg:setAnchorPoint(cc.p(0,0.5))	
	layer:addChild(rankBgImg)
	--排名
	if rank <= 3 then
		bgImg:loadTexture("globalPanelUI_activity_cellBg" .. rank .. ".png",1)
		rankImg = ccui.ImageView:create()
		rankImg:setName("rankImg")
		rankImg:setScale(0.8)
		rankImg:loadTexture(rankImgData[rank],1)		
	    rankImg:setPosition(cc.p(58,52))
	    rankImg:setAnchorPoint(cc.p(0.5,0.5))	
		layer:addChild(rankImg,1)
	else
		--排名
		local rankTxt = cc.Label:createWithBMFont(UIUtils.bmfName_rank, "00")
		rankTxt:setName("rankTxt")
		rankTxt:setString(rank)
		rankTxt:setAnchorPoint(cc.p(0.5,0))  
	    rankTxt:setPosition(cc.p(58,47))
	    layer:addChild(rankTxt, 2)
	end

	local icon = IconUtils:createHeadIconById({avatar = data.avatar,level = data.lvl,tp = 4, eventStyle=1, tencetTp = tencetTp})   --,tp = 2
    icon:setPosition(140, 15)
    icon:setScale(0.8)
    layer:addChild(icon)
	--名称
	local nameTxt = ccui.Text:create()
    nameTxt:setString(name)
    nameTxt:setFontSize(20)
    nameTxt:setPosition(220, 70)
    nameTxt:setFontName(UIUtils.ttfName)
    nameTxt:setAnchorPoint(cc.p(0,0.5))
    layer:addChild(nameTxt,2)

    --战力
	local scoreTxt = ccui.Text:create()
    scoreTxt:setString("战力")
    scoreTxt:setFontSize(18)
    scoreTxt:setPosition(220, 32)
    scoreTxt:setFontName(UIUtils.ttfName)
    scoreTxt:setAnchorPoint(cc.p(0,0.5))
    layer:addChild(scoreTxt,2)    
	nameTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	scoreTxt:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

	local scoreNum = cc.Label:createWithBMFont(UIUtils.bmfName_zhandouli, "00")
	scoreNum:setString(score or 0)
	scoreNum:setScale(0.5)
	scoreNum:setAnchorPoint(cc.p(0,0.5))  
    scoreNum:setPosition(257,36)
    layer:addChild(scoreNum, 2)

    -- 奖励
	local rewardLayer = ccui.Layout:create()
	rewardLayer:setAnchorPoint(cc.p(0,0))
	rewardLayer:setPosition(375, 10)
	rewardLayer:setContentSize(cc.size(320, 60))
	layer:addChild(rewardLayer,3)
	if not awardData then
		awardData = {}
	end
	local showType = awardData.type or 1
	local iconW = 60 
	if 0 == showType then
		iconW = 90
	end
	local awardShowData = awardData.awardshow or {}
	local rewardNum = #awardShowData
	for k,v in pairs(awardShowData) do
		local itemId 

		local icon 
		if v[1] == "team" then
			local teamD = tab:Team(v[2])		
			icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,isGray = false ,eventStyle = 1,isJin=true})
			local diguang = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888) 
			diguang:setPosition(icon:getContentSize().width/2-5, icon:getContentSize().height/2-5)
			-- diguang:setScale(1.1)
			local diguangParent = icon:getChildByName("teamIcon") or icon
			diguangParent:addChild(diguang,-1)

			local saoguang = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"})
			local effectParent = icon:getChildByName("iconColor") or icon
			effectParent:addChild(saoguang,5) 
			icon:setScale(0.5)
			icon:setAnchorPoint(cc.p(0,0))
			icon:setPosition(14+(k-1)*iconW,15)
		elseif v[1] == "avatarFrame" then
			itemId = v[2]
			local frameData = tab:AvatarFrame(itemId)
	        param = {itemId = itemId, itemData = frameData}
	        icon = IconUtils:createHeadFrameIconById(param)
	        icon:setPosition(14+(k-1)*iconW,15)
	        icon:setScale(0.5)
		else
			if v[1] == "tool" then
				itemId = v[2]
			else
				itemId = IconUtils.iconIdMap[v[1] ]
			end
			local toolD = tab:Tool(tonumber(itemId))
			
			local toolData = tab:Tool(itemId)
			-- tabId == 1 兵团碎片
			-- print("=========兵团碎片============",v[1],itemId)
			if toolData then
		        if toolData.tabId == 1 then
		            local teamId = string.sub(itemId, 2, string.len(itemId))
		            local hadTeam = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(teamId))
		            local eventStyle = 3
		            --如果拥有弹tips，没拥有则弹详情
		            if hadTeam then
		                eventStyle = 1 
		            end
		            icon = IconUtils:createItemIconById({itemId = itemId,num = v[3],eventStyle = eventStyle,effect = false,clickCallback= function( )
		                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = 15, iconId = tonumber(teamId)}, true) -- 15 本地数据兵团
		            end})
		        else
		            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})       
		        end
		    end
		    icon:setScale(0.58)		    
			icon:setAnchorPoint(0,0)
			icon:setPosition(14+(k-1)*iconW,15)
		end

		-- N选1  
		-- 1 全部获得  0 N选1
		if 0 == showType and k < rewardNum then
			local txt = ccui.Text:create()
			txt:setFontSize(20)
			txt:setColor(cc.c4b(72,38,0,255))
			txt:setFontName(UIUtils.ttfName)
			txt:setString("或")
			txt:setName("selectTip" .. k)
			txt:setPosition(k*iconW-5,40)
		    rewardLayer:addChild(txt)
		end

		icon:setSwallowTouches(false)
		rewardLayer:addChild(icon)
	end

	layer:setSwallowTouches(false)	
	-- local children = layer:getChildren()
	-- for k,v in pairs(children) do
	-- 	v:setSwallowTouches(false)
	-- end
	
	return layer
end
function ACGreenDragonView:startCountdown()
	--添加倒计时
	-- self._timeLabel
	local dragonShowList = self._modelMgr:getModel("ActivityModel"):getACFiveTypeShowList(906)
	-- dragonShowList.end_time = 1473195600
	local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
	local tempTime = (dragonShowList.end_time or currTime) - currTime 
	
	 -- getDragonOpenData
	if tempTime > 0 then
	    local day, hour, min, sec, tempValue
	    tempTime = tempTime + 1
	    self:runAction(cc.RepeatForever:create(cc.Sequence:create(
	        cc.CallFunc:create(function()
	            tempTime = tempTime - 1
	            tempValue = tempTime
	            day = math.floor(tempValue/86400) 
	            tempValue = tempValue - day*86400

	            hour = math.floor(tempValue/3600)
	            tempValue = tempValue - hour*3600

	            min = math.floor(tempValue/60)
	            tempValue = tempValue - min*60

	            sec = math.fmod(tempValue, 60)
	            local showTime
	            if tempTime <= 0 then
	                showTime = "00天00:00:00"
	            else
	               	showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, min, sec)
	            end
	            self._timeLabel:setString(showTime)
	        end),cc.DelayTime:create(1))
	    ))
	else
		self._timeLabel:setString("00天00:00:00")
	end

end

--[[
--是否要刷新排行榜
function ACGreenDragonView:sendMessageAgain()
	-- self.beginIdx -- self.endIdx -- self.addStep
	self._allRankData = self._rankModel:getRankList(1)
	local starNum = self._rankModel:getRankNextStart(1)
	local startCount = self.beginIdx
	local addCount = self.addStep
	local endCount = self.endIdx 

	if #self._tableData%addCount == 0 and #self._allRankData < endCount then
		--如果本地没有更多数据则向服务器请求
		self:sendGetRankMsg(1,starNum,function()
			-- 获取到数据了，更新位置
			if #self._tableData > startCount then
				self:searchForPosition(startCount,addCount,endCount)
			end
			self._canRequest = false
			self._viewMgr:unlock()
		end)
	else
		self._canRequest = false		
		self._viewMgr:unlock()
	end
end
--刷新之后tableView 的定位
function ACGreenDragonView:searchForPosition(startCount,addCount,endCount)
	self._offsetX = 0
	if startCount + addCount <= endCount then
		self.beginIdx = startCount + addCount
		local subNum = #self._tableData - startCount
		if subNum < addCount then
			self._offsetY = -1 * (tonumber(subNum) * self._tableCellH)			
		else
			self._offsetY = -1 * (tonumber(addCount) * self._tableCellH)			
		end
		
	else
		self.beginIdx = endCount
		self._offsetY = -1 * (endCount - startCount) * self._tableCellH
	end
end
]]
--获取排行榜数据
function ACGreenDragonView:sendGetRankMsg(tp,start,callback,num)
	self._rankModel:setRankTypeAndStartNum(tp,start)
	self._serverMgr:sendMsg("RankServer", "getRankList", {type=tp,startRank = start,act = 1}, true, {}, function(result) 
		-- print("================currBtn==================")
		if callback then
			callback()
		end
		local rankData = self._rankModel:getRankList(tp)
		self._rankData = self:initrankData(rankData)
		if self._showData then
			self._showData[3] = {showType=1,showData=self._rankData}
		end
		if 3 == self._currBtn then
			self._tableData = self._rankData
			self._tableView:reloadData()			
			if self._offsetY then
				self._tableView:setContentOffset(cc.p(0,self._offsetY))				
			end
		end
		--自己的排行榜
		if result.owner and next(result.owner) ~= nil then
			self._myRankData = result.owner 
			if self.initUserInfo then
				self:initUserInfo()
			end
		end
    end)

end

-- 取前十
function ACGreenDragonView:initrankData(rankData)
	if not rankData then return {} end
	local tenData = {}
	for i=1,10 do
		if rankData[i] then
			table.insert(tenData, rankData[i])
		end
	end
	return tenData
end
-- 接收自定义消息
function ACGreenDragonView:reflashUI(data)

end


function ACGreenDragonView.dtor()
	rankImgData = nil
	-- itemColor = nil
end
return ACGreenDragonView