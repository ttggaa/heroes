--
-- Author: huangguofang
-- Date: 2018-07-31 16:31:20
--

local AcLimitPrayView = class("AcLimitPrayView", BaseView)
-- 奖励
local colorArr = {
	[1] = cc.c4b(255, 241, 120, 255),
    [2] = cc.c4b(255, 120, 255, 255),
    [3] = cc.c4b(120, 187, 255, 255),
}
local rankImg = {
	[1] = "arenaRank_first.png",
	[2] = "arenaRank_second.png",
	[3] = "arenaRank_third.png"
}
local UI_SHOW_INFO = {
	[978] = {					-- 审判官
		teamId = 109,
		teamPos = {250,120},	--位置
		teamPos2 = {250,120},	--位置
		isFlip = true,			-- 是否需要翻转
		scaleNum = 0.9,         -- 兵团例会的缩放
		skill = {
			mcName   = "shenpanguanyanshi_shenpanguanyanshi",
            bgImg    = "skillPreviewBg.png",
            teamId   = 109,
            teamName = "审判官",
            effectType = 1,         -- 是否需要切换场景 effectParam 切换参数特效
            effectParam = {"shenpanguanyanshibeijing1_shenpanguanyanshibeijing", "shenpanguanyanshibeijing2_shenpanguanyanshibeijing"},
			}
	},
    [1041] = {                   -- 傀儡龙
        teamId = 609,
        teamPos = {250,200},    --位置
        teamPos2 = {250,120},   --位置
        isFlip = true,          -- 是否需要翻转
        scaleNum = 0.9,           -- 兵团例会的缩放
        skill = {
            mcName   = "kuileilongyanshi_kuileilongyanshi",
            bgImg    = "skillPreviewBg.png",
            teamId   = 609,
            teamName = "傀儡龙",
            -- effectType = 1,
            -- effectParam = {"shenpanguanyanshibeijing1_shenpanguanyanshibeijing", "shenpanguanyanshibeijing2_shenpanguanyanshibeijing"},
            }
    },
    [1094] = {                   -- 海后
        teamId = 9907,
        teamPos = {260,100},    --位置
        teamPos2 = {250,120},   --位置
        isFlip = true,          -- 是否需要翻转
        scaleNum = 0.9,           -- 兵团例会的缩放
        skill = {
            mcName   = "haihouyanshi_haihouyanshi",
            bgImg    = "skillPreviewBg.png",
            teamId   = 9907,
            teamName = "海后",
            -- effectType = 1,
            -- effectParam = {"shenpanguanyanshibeijing1_shenpanguanyanshibeijing", "shenpanguanyanshibeijing2_shenpanguanyanshibeijing"},
            }
    },
    [1187] = {                   -- 暗黑领主
        teamId = 309,
        teamPos = {260,100},    --位置
        teamPos2 = {250,120},   --位置
        isFlip = true,          -- 是否需要翻转
        scaleNum = 0.9,           -- 兵团例会的缩放
        skill = {
            mcName   = "sishenjinengyanshi_sishenjinengyanshi",
            bgImg    = "skillPreviewBg.png",
            teamId   = 309,
            teamName = "暗黑领主",
            -- effectType = 1,
            -- effectParam = {"shenpanguanyanshibeijing1_shenpanguanyanshibeijing", "shenpanguanyanshibeijing2_shenpanguanyanshibeijing"},
            }
    },
    [1250] = {                   -- 邪魔女
        teamId = 709,
        teamPos = {260,140},    --位置
        teamPos2 = {250,120},   --位置
        isFlip = true,          -- 是否需要翻转
        scaleNum = 0.9,           -- 兵团例会的缩放
        skill = {
            mcName   = "xieshennvjinengyanshi_xieshennvjinengyanshi",
            bgImg    = "skillPreviewBg.png",
            teamId   = 709,
            teamName = "邪魔女",
            -- effectType = 1,
            -- effectParam = {"shenpanguanyanshibeijing1_shenpanguanyanshibeijing", "shenpanguanyanshibeijing2_shenpanguanyanshibeijing"},
            }
    },
    [1333] = {                   -- 螳螂
        teamId = 209,
        teamPos = {260,140},    --位置
        teamPos2 = {250,120},   --位置
        isFlip = true,          -- 是否需要翻转
        scaleNum = 0.9,           -- 兵团例会的缩放
        skill = {
            mcName   = "tanglangjinengyanshi_tanglangjinengyanshi",
            bgImg    = "skillPreviewBg.png",
            teamId   = 209,
            teamName = "螳螂",
            -- effectType = 1,
            -- effectParam = {"shenpanguanyanshibeijing1_shenpanguanyanshibeijing", "shenpanguanyanshibeijing2_shenpanguanyanshibeijing"},
            }
    },
}
function AcLimitPrayView:ctor(params)
    AcLimitPrayView.super.ctor(self)
    self.initAnimType = 3

	self._userModel = self._modelMgr:getModel("UserModel")
    self._limitPrayModel = self._modelMgr:getModel("LimitPrayModel")

   	self._openId = params.openId or 903
   	self._acId = params.acId or 60001
end

function AcLimitPrayView:getAsyncRes()
    return 
    {
        {"asset/ui/acLimitPray.plist", "asset/ui/acLimitPray.png"},
        {"asset/ui/acLimitPray1.plist", "asset/ui/acLimitPray1.png"}
    }
end

function AcLimitPrayView:getBgName()
    return "bg_007.jpg"
end

function AcLimitPrayView:onInit()
	SystemUtils.saveAccountLocalData("AC_LIMITPRAY_IN", true)
    -- 通用动态背景
    self:addAnimBg()
    -- 活动配置表
    self._prayConfig = tab.prayConfig
   	self._acData = self._limitPrayModel:getDataById(self._openId)
   	self._info = UI_SHOW_INFO[self._openId]
   	-- dump(self._acData ,"self._acData ==>",5)
   	-- dump(self._prayConfig,"config==>",5)
   	-- 便于调整也签顺序
   	self._btnInfo ={
   		[1] = {btnIndex = 1,layerInfo = "activity.acLimitPray.AcLimitPrayBuyLayer",isShowNoticeImg=true},
   		[2] = {btnIndex = 2,layerInfo = "activity.acLimitPray.AcLimitPrayAwardLayer"},
   		[3] = {btnIndex = 3,layerInfo = "activity.acLimitPray.AcLimitPrayTeamLayer"},
   		[4] = {btnIndex = 4,layerInfo = "activity.acLimitPray.AcLimitPrayRuleLayer"},
   		[5] = {btnIndex = 5,layerInfo = "activity.acLimitPray.AcLimitPrayShopLayer",isHide = self._prayConfig["teamshop"]["value"] ~= 1},
	}
	self._layerArr = {}
	self._btnArr = {}
	
    self._bg            = self:getUI("bg")
	self._timeLabel 	= self:getUI("bg.prayPanel.timeTxt")
	self._panelLayer 	= self:getUI("bg.prayPanel.panelLayer")
	self._noticeImg		= self:getUI("bg.noticeImg")
	self._myScore 		= self:getUI("buttomPanel.myScore")
	self._myRank 		= self:getUI("buttomPanel.myRank")
	self._rankTime 		= self:getUI("buttomPanel.rankTime")

	local timeDes 		= self:getUI("bg.prayPanel.timeDes")
	local rankDes 		= self:getUI("buttomPanel.rankDes")
	local myScoreTxt	= self:getUI("buttomPanel.myScoreTxt")
	local myRankTxt 	= self:getUI("buttomPanel.myRankTxt")
	timeDes:enable2Color(1, cc.c3b(253,232,137))
	rankDes:enable2Color(1, cc.c3b(253,232,137))
	myScoreTxt:enable2Color(1, cc.c3b(253,232,137))
	myRankTxt:enable2Color(1, cc.c3b(253,232,137))
	self._timeLabel:enable2Color(1, cc.c3b(253,232,137))

	timeDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	rankDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	myScoreTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	myRankTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	self._timeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	self._noticeImg:loadTexture("acLimitPray_noticeImg_1094.png", 1)
	self._myScore:setString(self._acData.boxPt or 0)

	local posX = 60
	for i=1,#self._btnInfo do
		local v = self._btnInfo[i]
		local btn = self:getUI("bg.prayPanel.btnPanel.btn" .. v.btnIndex) 
		if btn then
			self._btnArr[i] = btn
			btn:setVisible(not v.isHide)
			btn:setPositionX(posX)
			posX = posX + 114
			registerClickEvent(btn,function(sender)
			    self:updateBtnState(i)
			    self:changeLayerByIdx(i) 
		    end)
		end
	end
	self:updateBtnState(1)
	self:changeLayerByIdx(1)

	self:initAwardPanel()
	-- 排行榜
	self:sendGetRankMsg()
	self:initRankListPanel()
	self:startCountdown()

	local titleImg = self:getUI("bg.prayPanel.titleImg") 
	local titleMc = mcMgr:createViewMC("xianshihuodongguangxiao_xianshihuodong", true, false)
    titleMc:setPosition(200, 40)
    titleImg:addChild(titleMc)

    self:registerClickEventByName("bg.prayPanel.luckyBtn", function ()
        DialogUtils.showBuyRes({goalType = "luckyCoin"})
    end)
    self:registerClickEventByName("bg.prayPanel.gemBtn", function ()
        DialogUtils.showBuyRes({goalType = "gem"})
    end)

    -- 奖励界面兵模panel
    local awardTeamPanel = ccui.Layout:create()
    awardTeamPanel:setAnchorPoint(0,0)
    -- awardTeamPanel:setBackGroundColorOpacity(100)
    -- awardTeamPanel:setBackGroundColorType(1)
    awardTeamPanel:setContentSize(200,200)
    awardTeamPanel:setTouchEnabled(true)
    awardTeamPanel:setSwallowTouches(false)
    awardTeamPanel:setPosition(330, 320)
    self._bg:addChild(awardTeamPanel,20)
    self._awardTeamPanel = awardTeamPanel

    self._luckyNum = self:getUI("bg.prayPanel.luckyNum")
    self._diamondNum = self:getUI("bg.prayPanel.diamondNum")
    self:updateUserRes()
    self:listenReflash("UserModel", self.updateUserRes)
end

function AcLimitPrayView:startCountdown()
	--添加倒计时
	local currTime = self._userModel:getCurServerTime()
	local acEndTime = self._limitPrayModel:getAcEndTime() or currTime
	local tempTime = acEndTime - currTime 
	
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
	local rankEndTime = acEndTime - self._prayConfig["rank"]["value"] * 3600
	local ranktimeStr = TimeUtils.getDateString(rankEndTime,"%m-%d*%H:%M")
	ranktimeStr = string.gsub(ranktimeStr,"-","月")
	ranktimeStr = string.gsub(ranktimeStr,"*","日")
	self._rankTime:setString(ranktimeStr)


end

--[[
--! @function tabButtonState
--! @desc 按钮状态切换
--! @param selectedIndex int 选中按钮index
--! @return 
--]]
function AcLimitPrayView:updateBtnState(selectedIndex)
	 for k,v in pairs(self._btnArr) do
	 	v:setTitleColor(cc.c4b(179,164,136,255))
	 	v:setEnabled(true)
	 	v:setBright(true)
	 	v:getTitleRenderer():disableEffect()	
	 end
	 local btn = self._btnArr[selectedIndex]
	 btn:setTitleColor(cc.c4b(103,38,6,255))
	 btn:setEnabled(false)
	 btn:setBright(false)
end


--[[
--! @function tabButtonState
--! @desc 按钮状态切换
--! @param selectedIndex int 选中按钮index
--! @return 
--]]
function AcLimitPrayView:changeLayerByIdx(index)
    print("================changeLayerByIdx============",index)
	self._panelLayer:removeAllChildren()
	self._panelLayer:setVisible(true)
	local layerName = self._btnInfo[index].layerInfo	
	self._noticeImg:setVisible(not not self._btnInfo[index].isShowNoticeImg)
	if not layerName or layerName == "" then 
		return 
	end
    if self._awardTeamPanel then
        self._awardTeamPanel:removeAllChildren()
    end
	self._layer = self:createLayer(
		layerName, 
		{	parent=self,
            awardTeamPanel = self._awardTeamPanel,
			UIInfo = self._info,
			acId = self._acId,
			openId=self._openId,
			selfRank=self._selfRank
		}, 
		true, 
		function (_layer)		       
	        _layer:setPosition(0, 0)
	        _layer:setName("limitPrayLayer")
	        self._panelLayer:addChild(_layer)
	    end)
end

function AcLimitPrayView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideBtn = false,hideInfo=true})
end

--[[
	祈愿更新排行&底部信息
]]
function AcLimitPrayView:updatePrayInfo()
	-- 更新排行榜
	self._acData = self._limitPrayModel:getDataById(self._openId)
	-- dump(self._acData,"self._acData===>",5)
	self:sendGetRankMsg()
	self._myScore:setString(self._acData.boxPt or 0)

	self:updateUserRes()
end

function AcLimitPrayView:updateUserRes()	
	local userData = self._userModel:getData()
    self._luckyNum:setString(ItemUtils.formatItemCount(userData["luckyCoin"]))
    self._diamondNum:setString(ItemUtils.formatItemCount(userData["gem"]))
    if self._layer and self._layer.updateCostColor then
    	-- print("================updateUserRes==================")
    	self._layer:updateCostColor()
    end
end

function AcLimitPrayView:initAwardPanel()
	local rankData = clone(tab.prayRank)
	local scrollView = self:getUI("bg.prayPanel.awardPanel.scrollView")
	scrollView:setBounceEnabled(true)
	local itemH = 40
	local itemW = 270
	local itemNum = #rankData
	local height = itemH * itemNum
	if height < scrollView:getContentSize().height then
		height = scrollView:getContentSize().height + 2
	end
	local posY = height
	scrollView:setInnerContainerSize(cc.size(itemW, height))
	local function createItem(data,i)
		local item = ccui.Layout:create()
		item:setAnchorPoint(0,0)
		-- item:setBackGroundColorOpacity(255)
   		-- item:setBackGroundColorType(1)
		item:setContentSize(itemW, itemH)
	    item:setTouchEnabled(true)
	    item:setSwallowTouches(false)
		if not data then return  item end

		local subRank = data.rank[2] - data.rank[1]
		local rankStr = "第" ..data.rank[1].. "名"
		if subRank ~= 0 then
			rankStr = "第" .. data.rank[1] .. "~" .. data.rank[2] .. "名"
		end
	    --条件
	    local rankTxt = ccui.Text:create()
	    rankTxt:setFontSize(18)
	    rankTxt:setName("rankTxt")
	    rankTxt:setFontName(UIUtils.ttfName)
	    rankTxt:setAnchorPoint(0.5,0.5)
	    rankTxt:setPosition(50, 15)
	    rankTxt:setString(rankStr)
	    item:addChild(rankTxt)
	    if colorArr[i] then
	    	rankTxt:setColor(colorArr[i])
	    else
	    	rankTxt:setColor(cc.c4b(255,255,255,255))
	    end

	    for k,v in pairs(data.reward) do
	    	local itemId 
			local icon 
	    	if v[1] == "avatarFrame" then
				itemId = v[2]
				local frameData = tab:AvatarFrame(itemId)
		        param = {itemId = itemId, itemData = frameData}
		        icon = IconUtils:createHeadFrameIconById(param)
		        icon:setPosition(96+(k-1)*itemH,0)
		        icon:setScale(0.4)
		    elseif v[1] == "heroShadow" then
		    	itemId = v[2]
		    	local itemData = tab:HeroShadow(itemId)
	            icon = IconUtils:createShadowIcon({itemData = itemData,eventStyle=1})
	            icon.iconColor.nameLab:setVisible(false)
	            local quality = itemData.avaQuality and (itemData.avaQuality + 3) or 1
	            local color = UIUtils.colorTable["ccUIBaseColor"..quality]
	            icon.iconColor.nameLab:setColor(color)
	            icon:setScale(0.4)
	            icon:setPosition(96+(k-1)*itemH,0)
			else
				if v[1] == "tool" then
					itemId = v[2]
				else
					itemId = IconUtils.iconIdMap[v[1]]
				end
				local toolD = tab:Tool(tonumber(itemId))
				
				local toolData = tab:Tool(itemId)
				icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
				icon:setScale(0.4)
				icon:setPosition(96+(k-1)*itemH,0)
			end

			icon:setSwallowTouches(false)
			icon:setAnchorPoint(0,0)
			
			item:addChild(icon)
	    end

	    return item
	end
	for i=1,itemNum do
		local item = createItem(rankData[i],i)
		posY = posY - itemH
		item:setPosition(0, posY)
		scrollView:addChild(item)
	end
end

-- 排行榜
function AcLimitPrayView:initRankListPanel()
	self._rankData = {}
	local listBg = self:getUI("bg.prayPanel.rankPanel.listBg")
	local noRank = self:getUI("bg.prayPanel.rankPanel.noRank")
	noRank:setVisible(false)

    if self._rankList then  
        self._rankList:removeFromParent()
        self._rankList = nil
    end
    local tableView = cc.TableView:create(cc.size(270, 166))
    -- local tableView = cc.TableView:create(cc.size(573, 392))
    -- tableView:setClippingType(1)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(0,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(true)
    listBg:addChild(tableView,1)
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
    self._rankList = tableView
    tableView:reloadData()
end

function AcLimitPrayView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()   
end

function AcLimitPrayView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function AcLimitPrayView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function AcLimitPrayView:cellSizeForTable(table,idx) 
    return 32,269
    -- return 110,566
end

function AcLimitPrayView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    local cellData = self._rankData[idx+1]

    if nil == cell then
        cell = cc.TableViewCell:new()    
    else
        cell:removeAllChildren()
    end
    local item = self:creatItem(cellData,idx+1)
    item:setPosition(0,0)
    item:setAnchorPoint(0,0)
    cell:addChild(item)

    return cell
end
function AcLimitPrayView:numberOfCellsInTableView(table)
    return #self._rankData
end

function AcLimitPrayView:creatItem(data,index)
	local item = ccui.Layout:create()
	item:setAnchorPoint(0,0)
	-- item:setBackGroundColorOpacity(255)
		-- item:setBackGroundColorType(1)
	item:setContentSize(270, 32)
	item:setTouchEnabled(true)
	item:setSwallowTouches(false)
	if not data then return  item end

	if index <= 3 then
		local rankLabel = ccui.ImageView:create()
		rankLabel:setName("rankLabel")
		rankLabel:loadTexture(rankImg[index],1)		
	    rankLabel:setPosition(40,15)
	    rankLabel:setScale(0.45)
	    rankLabel:setAnchorPoint(0.5,0.5)
		item:addChild(rankLabel)
	else
		local rankLabel = ccui.Text:create()
		rankLabel:setFontSize(18)
		rankLabel:setName("rankLabel")
		rankLabel:setFontName(UIUtils.ttfName)
		rankLabel:setColor(cc.c4b(255,255,255,255))
		rankLabel:setAnchorPoint(0.5,0.5)
		rankLabel:setPosition(39, 15)
		rankLabel:setString(index)
		item:addChild(rankLabel)
	end

	local rankBgImg = ccui.ImageView:create()
	rankBgImg:setName("rankBgImg")
	rankBgImg:loadTexture("acLimitPray_itemBg.png",1)		
    rankBgImg:setAnchorPoint(0,0)
    rankBgImg:setPosition(0,0)
    rankBgImg:setVisible(index%2 ~= 1)
	item:addChild(rankBgImg,-1)

	--条件
	local rankName = ccui.Text:create()
	rankName:setFontSize(18)
	rankName:setName("rankName")
	rankName:setFontName(UIUtils.ttfName)
	rankName:setAnchorPoint(0,0.5)
	rankName:setPosition(80, 15)
	rankName:setString(data.name or "")
	item:addChild(rankName)
	if colorArr[index] then
		rankName:setColor(colorArr[index])
	else
		rankName:setColor(cc.c4b(255,255,255,255))
	end

	local scoreTxt = ccui.Text:create()
	scoreTxt:setFontSize(18)
	scoreTxt:setName("scoreTxt")
	scoreTxt:setFontName(UIUtils.ttfName)
	scoreTxt:setColor(cc.c4b(255,255,255,255))
	scoreTxt:setAnchorPoint(1,0.5)
	scoreTxt:setPosition(260, 15)
	scoreTxt:setString(data.score or 0)
	item:addChild(scoreTxt)

	return item 
end

function AcLimitPrayView:updateRankListPanel()
	self._myRank:setString((self._selfRank and self._selfRank > 0) and self._selfRank or "暂未上榜(需积分达到80)" )
	local noRank = self:getUI("bg.prayPanel.rankPanel.noRank")
	if self._rankData and self._rankList then
		print("================#self._rankData=====",#self._rankData)
		noRank:setVisible(#self._rankData <= 0)
		self._rankList:reloadData()
	end
end
function AcLimitPrayView:reflashUI(data)
    
end

-- 获取排行榜
function AcLimitPrayView:sendGetRankMsg()
	self._serverMgr:sendMsg("LimitPrayServer", "getRank", {acId = self._openId}, true, {}, function(result) 
		self._rankData = {}
		if result.list then
			for k,v in pairs(result.list) do				
				self._rankData[tonumber(k)] = v
			end
		end
		if result.srank then
			self._selfRank = result.srank
		end
		self:updateRankListPanel()
    end)
end

function AcLimitPrayView.dtor()
    UI_SHOW_INFO = nil
	colorArr = nil
	rankImg = nil
end
return AcLimitPrayView