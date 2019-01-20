--[[
    FileName:       GloryArenaRankDialog
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-13 17:01:52
    Description:
]]

local GloryArenaRankDialog = class("GloryArenaRankDialog", BasePopView)

function GloryArenaRankDialog:ctor()   
    self.super.ctor(self)  
end


local childName = {
    --按钮
    {name = "bg", childName = "bg"},
    {name = "closeBtn", childName = "bg.bg.closeBtn", isBtn = true},

    {name = "leftBoard", childName = "bg.bg.leftBoard"},
    {name = "name", childName = "bg.bg.leftBoard.name", isText = true},
    {name = "level", childName = "bg.bg.leftBoard.level", isText = true},
    {name = "guild", childName = "bg.bg.leftBoard.guild", isText = true},
    {name = "guildDes", childName = "bg.bg.leftBoard.guildDes", isText = true},
    {name = "touch_lay", childName = "bg.bg.leftBoard.touch_lay"},
    {name = "rankItem", childName = "bg.bg.rankItem"},
    {name = "tableNode", childName = "bg.bg.tableNode"},
    {name = "noRankBg", childName = "bg.bg.noRankBg"},
    {name = "selfAward", childName = "bg.bg.selfAward"},

    {name = "awardTxt1", childName = "bg.bg.selfAward.awardTxt1", isText = true},
    {name = "awardTxt2", childName = "bg.bg.selfAward.awardTxt2", isText = true},
    {name = "awardTxt3", childName = "bg.bg.selfAward.awardTxt3", isText = true},

    {name = "awardImg1", childName = "bg.bg.selfAward.awardImg1"},
    {name = "awardImg2", childName = "bg.bg.selfAward.awardImg2"},
    {name = "awardImg3", childName = "bg.bg.selfAward.awardImg3"},

    {name = "ruleBtn", childName = "bg.bg.selfAward.ruleBtn", isBtn = true},
}

function GloryArenaRankDialog:onRewardCallback(_, _x, _y, sender)
    if sender == nil or self._childNodeTable == nil then
        return 
    end
    if sender:getName() == "closeBtn" then
        self:close()
        UIUtils:reloadLuaFile("gloryArena.GloryArenaRankDialog")
    elseif sender:getName() == "ruleBtn" then
        self._viewMgr:showDialog("gloryArena.GloryArenaRuleDialog")
    end
end



-- 初始化UI后会调用, 有需要请覆盖
function GloryArenaRankDialog:onInit()
    self._childNodeTable = self:lGetChildrens(self._widget, childName)
    if self._childNodeTable == nil then
        return
    end
--	local rankInfo = self._arenaModel:getArenaRank()
--	if not rankInfo or #rankInfo == 0 then
--		self._rankSchedule = ScheduleMgr:regSchedule(50, self, function(self, dt)
--  	        local rankInfo = self._arenaModel:getArenaRank()
--			if rankInfo and #rankInfo > 0 then
--				ScheduleMgr:unregSchedule(self._rankSchedule)
--				self:reflashUI()
--			end
--  	    end)
--	end
    -- self:disableTextEffect()
	self:addTableView()
    self._gloryArenaModel = self._modelMgr:getModel("GloryArenaModel")
    self._childNodeTable.awardImg3:ignoreContentAdaptWithSize(false)
    self._childNodeTable.awardImg3:loadTexture("globalImageUI_gloryArenaIcon_min.png", ccui.TextureResType.plistType)
    self._rankData = {}

end

function GloryArenaRankDialog:addTableView( )
	self._tableViewH = 350
    local tableView = cc.TableView:create(cc.size(660, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(5,6))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._childNodeTable.tableNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( view,cell )
        return self:tableCellTouched(view,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( view,index )
        return self:cellSizeForTable(view,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( view,index )
        return self:tableCellAtIndex(view,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( view )
        return self:numberOfCellsInTableView(view)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView = tableView
end

function GloryArenaRankDialog:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
end

function GloryArenaRankDialog:scrollViewDidZoom(view)
end

function GloryArenaRankDialog:tableCellTouched(view,cell)
end

function GloryArenaRankDialog:cellSizeForTable(view,idx) 
    return 93, 0
end

function GloryArenaRankDialog:tableCellAtIndex(view, idx)
    local strValue = string.format("%d",idx)
    local cell = view:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local item = cell:getChildByName("item")
    if not item then
        item = self._childNodeTable.rankItem:clone()
        item:setVisible(true)
        item:setAnchorPoint(cc.p(0, 0))
        item:setPosition(cc.p(-6, 0))
        item:setName("item")
        cell:addChild(item)
    end
    self:updateItem(item, idx + 1)
    return cell
end

function GloryArenaRankDialog:numberOfCellsInTableView(tableView)
	return #self._rankData or 0
end

local itemConfigName = {
    {name = "firstImg", childName = "firstImg"},
    {name = "secondImg", childName = "secondImg"},
    {name = "thirdImg", childName = "thirdImg"},
    {name = "nameLab", childName = "nameLab", isText = true},
    -- {name = "itemName", childName = "itemName"},
    {name = "headNode", childName = "headNode"},
    {name = "scoreLab", childName = "scoreLab", isText = true},
    {name = "levelLab", childName = "levelLab", isText = true},
    {name = "selfTag", childName = "selfTag"},
}

function GloryArenaRankDialog:setSelfRank()
    if self._childNodeTable == nil then
        return
    end
    local item = self._childNodeTable.rankItem
    local childNodeTable = self:lGetChildrens(self._childNodeTable.rankItem, itemConfigName)

    if childNodeTable == nil then
        return
    end

    for key, var in pairs(childNodeTable) do
        if var then
            var:setVisible(false)
        end
    end
    local selfRank = self._gloryArenaModel:lGetSelfRank()
    local rewArd = self._gloryArenaModel:lGetRankReward()

    

    local itemId = rewArd.diamond[2] or 301303
    local itemCount = rewArd.diamond[3] or 301303
    if rewArd.diamond[1] ~= "tool" then
        print("找策划，奖励配置错了")
        itemId = 301303
        itemCount = 0
    end

    local rankLab = item:getChildByName("rankLab")
    if rankLab then
        rankLab:setVisible(false)
    end
    if selfRank == 1 then
        childNodeTable.firstImg:setVisible(true)
    elseif selfRank == 2 then
        childNodeTable.secondImg:setVisible(true)
    elseif selfRank == 3 then
        childNodeTable.thirdImg:setVisible(true)
    else
	    if not rankLab then
	        rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28)
	        rankLab:setAnchorPoint(cc.p(0.5,0.5))
	        rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	        rankLab:setPosition(cc.p(childNodeTable.thirdImg:getPosition()))
	        rankLab:setName("rankLab")
	        item:addChild(rankLab, 1)
	    end
        rankLab:setVisible(true)
	    rankLab:setString(selfRank or 0)
    end

    childNodeTable.selfTag:setVisible(true)

    self._childNodeTable.awardImg1:setVisible(false)
    
    self._childNodeTable.awardImg2:loadTexture("globalImageUI_texp.png", ccui.TextureResType.plistType)

    self._childNodeTable.awardTxt1:setString(itemCount)

    self._childNodeTable.awardTxt2:setString(rewArd.texp or 0)
    
    self._childNodeTable.awardTxt3:setString(rewArd.honorCertificate or 0)
    
    local sysItem = tab:Tool(itemId)
    if self._sysItem == nil then
        self._sysItem = IconUtils:createItemIconById({itemId = itemId, itemData = sysItem})
        self._sysItem:setAnchorPoint(cc.p(0.8, 0.5))
        self._sysItem:setPosition(cc.p(self._childNodeTable.awardImg1:getPosition()))
--        self._sysItem:setContentSize(cc.size(42, 42))
        self._sysItem:setScale(0.5)
        self._childNodeTable.awardImg1:getParent():addChild(self._sysItem)
    else
        IconUtils:updateItemIconByView(self._sysItem, {itemId = itemId, itemData = sysItem})
    end

end

function GloryArenaRankDialog:showPlayerInfo(data)
    if  data == nil then
        return
    end
    self._serverMgr:sendMsg("CrossArenaServer", "getDetailInfo", {id = data.id},true ,{}, function(resule)
        self._viewMgr:showDialog("gloryArena.GloryArenaUserInfoDialog", resule.info)
    end)
end

function GloryArenaRankDialog:updateItem(item, nindex)
    local data = self._rankData[nindex]
    if item == nil or data == nil then
        return
    end
    local childNodeTable = self:lGetChildrens(item, itemConfigName)
    if childNodeTable then
        for key, var in pairs(childNodeTable) do
            if var then
                var:setVisible(false)
            end
        end

        self:registerClickEvent(item,
        function()
            if not self._inScrolling then
                self:showPlayerInfo(data)
            else
                self._inScrolling = false
            end
        end)
        item:setSwallowTouches(false)
        local rankLab = item:getChildByName("rankLab")
        if rankLab then
            rankLab:setVisible(false)
        end
        if data.rank == 1 then
            childNodeTable.firstImg:setVisible(true)
        elseif data.rank == 2 then
            childNodeTable.secondImg:setVisible(true)
        elseif data.rank == 3 then
            childNodeTable.thirdImg:setVisible(true)
        else
	        if not rankLab then
	            rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28)
	            rankLab:setAnchorPoint(cc.p(0.5,0.5))
	            rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	            rankLab:setPosition(cc.p(childNodeTable.thirdImg:getPosition()))
	            rankLab:setName("rankLab")
	            item:addChild(rankLab, 1)
	        end
            rankLab:setVisible(true)
	        rankLab:setString(data.rank or 0)
        end
        local userId = self._modelMgr:getModel("UserModel"):getUID()
        if data.rid == userId then
            childNodeTable.selfTag:setVisible(true)
        end

        childNodeTable.nameLab:setVisible(true)
        childNodeTable.nameLab:setString(data.name or "神勇妖皇")

        childNodeTable.scoreLab:setVisible(true)
--        childNodeTable.scoreLab:setAnchorPoint(cc.p(0.5, 0.5))
        childNodeTable.scoreLab:setString(self._gloryArenaModel:lGetServerNameStr(data.sec or 0))
        childNodeTable.scoreLab:setPositionX(620)
        childNodeTable.scoreLab:setFontSize(20)
        childNodeTable.levelLab:setVisible(true)

        local guildName = data.guildName
	    if guildName and guildName ~= "" then 
		    local nameLen = utf8.len(guildName)
		    if nameLen > 6 then
			    guildName = string.sub(guildName,1,15) .. ""
		    end
		    childNodeTable.levelLab:setString(guildName or "")
	    else
		    childNodeTable.levelLab:setString("尚未加入")
	    end
        childNodeTable.levelLab:setPositionX(445)
        local avatarName = data.avatar
	    if avatarName == 0 or not avatarName then avatarName = 1203 end	
	    local lvl = data.lvl
        local tencetTp = data["qqVip"]
        childNodeTable.headNode:setVisible(true)
        local icon = childNodeTable.headNode:getChildByName("icon")
        local headP = {avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"], tencetTp = tencetTp, plvl = data["plvl"]}
        if not icon then
            icon = IconUtils:createHeadIconById(headP) 
	        icon:setAnchorPoint(cc.p(0.5,0.5))
            icon:setPosition(cc.p(childNodeTable.headNode:getContentSize().width * 0.5, childNodeTable.headNode:getContentSize().height * 0.5 - 2))
            icon:setName("icon")
            icon:setScale(0.6)
	        childNodeTable.headNode:addChild(icon)
            childNodeTable.headNode:setSwallowTouches(false)
        else    
            IconUtils:updateHeadIconByView(icon, headP) 
        end

    end
end


--设置最强的人
function GloryArenaRankDialog:lSetFirstData()
    local data = self._rankData[1]
    if data == nil and self._childNodeTable == nil then
        return
    end
	self._childNodeTable.name:setString(data.name)
    local inParam = {lvlStr = "Lv." .. (data.lvl or 0), lvl = data.lvl, plvl = data.plvl}
    UIUtils:adjustLevelShow(self._childNodeTable.level, inParam, 1)

	local guildName = data.guildName
	if guildName and guildName ~= "" then 
		self._childNodeTable.guild:setVisible(true)
		local nameLen = utf8.len(guildName)
		if nameLen > 6 then
			guildName = string.sub(guildName,1,15) .. "..."
		end
		self._childNodeTable.guild:setString("" .. (guildName or ""))
		self._childNodeTable.guildDes:setVisible(true)
	else
		self._childNodeTable.guild:setVisible(false)
		self._childNodeTable.guildDes:setVisible(false)
	end
	--左侧人物形象
	local heroId = data.fHeroId  or 60001
    local heroD = clone(tab:Hero(heroId))
    local heroArt = heroD["heroart"]
    if data.heroSkin then
        local heroSkinD = tab.heroSkin[data.heroSkin]
        heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or heroD["heroart"]
    end
    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
    sp:setScale(0.8)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._childNodeTable.leftBoard:getContentSize().width*0.5, self._childNodeTable.leftBoard:getContentSize().height*0.5 - 30)
    self._childNodeTable.leftBoard:addChild(sp,0)

	self._childNodeTable.touch_lay:addTouchEventListener(function(sender, _type)
        if _type == ccui.TouchEventType.ended then
            --查看玩家信息
            self:showPlayerInfo(data)
        end
    end)

end

--刷新UI
function GloryArenaRankDialog:updateUI(data)
    self._rankData = self._gloryArenaModel:lGetGloryArenaRank()
    if self._tableView then
        self._tableView:reloadData()
    end
    self:setSelfRank()
    self:lSetFirstData()

    if self._rankData == nil or #self._rankData == 0 then
        self._childNodeTable.noRankBg:setVisible(true)
    else
        self._childNodeTable.noRankBg:setVisible(false)
    end
end


-- 接收自定义消息
function GloryArenaRankDialog:reflashUI(data)
    self._rankData = self._gloryArenaModel:lGetGloryArenaRank()
    local selfRank = self._gloryArenaModel:lGetSelfRank()
    local serverRank = selfRank
    if self._rankData ~= nil and #self._rankData > 0 then 
        local userId = self._modelMgr:getModel("UserModel"):getUID()
        for key, var in ipairs(self._rankData) do
            if var and var.rid == userId then
                serverRank = tonumber(var.rank)
                break
            end
        end
    end
    print("selfRank ", selfRank, serverRank)
    if selfRank ~= serverRank then
        self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
            self:updateUI(data)
        end)
    end
    self:updateUI(data)
end

function GloryArenaRankDialog:dtor(args)
    childName = nil
    itemConfigName = nil
end


return GloryArenaRankDialog