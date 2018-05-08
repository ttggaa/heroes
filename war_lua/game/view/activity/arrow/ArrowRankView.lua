--[[
    Filename:    ArrowRankView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-1-09 22:19:00
    Description: 射箭送箭界面
--]]

local ArrowRankView = class("ArrowRankView", BasePopView)

function ArrowRankView:ctor(param)
	ArrowRankView.super.ctor(self)
	self._arrowModel = self._modelMgr:getModel("ArrowModel")
	self._userModelData = self._modelMgr:getModel("UserModel"):getData()
	self._callback = param.callback

	self._curChannel = ""
	self._isLoadData = {}
end

function ArrowRankView:onInit()
	self:registerClickEventByName("bg.closeBtn", function()
		if self._callback then
			self._callback()
		end
		self:close()
		-- UIUtils:reloadLuaFile("activity.arrow.ArrowRankView")
		end)

	local title = self:getUI("bg.title")
	title:setString("数据统计")
	title:setPositionY(title:getPositionY() - 3)
	UIUtils:setTitleFormat(title, 1)

	local title2 = self:getUI("bg.scoreBg.title.Label_106")
	title2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	local Label_64 = self:getUI("bg.Image_55.Image_550.Label_64")
	Label_64:setString(lang("ARROW2"))

	local name = self:getUI("itemCell.name")
	UIUtils:setTitleFormat(name, 2)

	local nothing = self:getUI("bg.nothing")
	nothing:setVisible(false)

	--cell
	self._cellItem = self:getUI("itemCell")
	self._cellItem:setVisible(false)
	local cellName = self:getUI("itemCell.name")
	UIUtils:setTitleFormat(cellName, 2)

	self:refreshUI()

	--btn
	self._btnList = {}
	local gameFriBtn = self:getUI("bg.gameFriBtn")
	local guildFriBtn = self:getUI("bg.guildFriBtn")
	gameFriBtn._name = "friend"
	guildFriBtn._name = "guildMember"
	table.insert(self._btnList, gameFriBtn)
	table.insert(self._btnList, guildFriBtn)
	self:refreshBtnState(guildFriBtn)

	self:registerClickEvent(gameFriBtn, function(sender) self:tabButtonClick(sender) end)
	self:registerClickEvent(guildFriBtn, function(sender) self:tabButtonClick(sender) end)

	--场景监听
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            self._arrowModel:setIsRankView(false)
        elseif eventType == "enter" then
        	self._arrowModel:setIsRankView(true) 
        	-- self._viewMgr:lock(-1)
         --   	ScheduleMgr:delayCall(10, self, function ()
         --        self._viewMgr:unlock()
         --        self:tabButtonClick(guildFriBtn)
         --        end)
        end
    end)
end

function ArrowRankView:onPopEnd(sender)
	local guildFriBtn = self:getUI("bg.guildFriBtn")
	self:tabButtonClick(guildFriBtn)
end

function ArrowRankView:refreshUI(inType)
	self._data = self._arrowModel:getData()
	-- dump(self._data, "123")

	local hitPer, hitHPer, myScore = self._arrowModel:getArrowRankData()
	--命中率
	local hitLab = self:getUI("bg.scoreBg.shoot0_1")
	hitLab:setString(hitPer*100 .. "%")

	--爆头率
	local hitHLab = self:getUI("bg.scoreBg.shoot0_2")
	hitHLab:setString(hitHPer*100 .. "%")

	--我的评分
	local Label_106 = self:getUI("bg.scoreBg.title.Label_106")
	Label_106:setString("我的评分: " .. myScore)

	--我的排名
	if inType ~= nil then
		local num = 1
		for i,v in ipairs(self._data[inType]) do
			if v.rid == self._userModelData._id then
				num = i
				break
			end
		end
		local myRank = self:getUI("bg.myRank")
		myRank:setString("我的排名："..num)
	end


	--射死数
	for i=1,6 do
		local shoot = self:getUI("bg.scoreBg.shoot"..i)
		shoot:setString(self._data["arrow"]["mStatis"][tostring(i)])
	end
end

function ArrowRankView:refreshBtnState(sender)
	for k,v in pairs(self._btnList) do
        v:setBright(true)
        v:setEnabled(true)
        v:setTitleColor(UIUtils.colorTable.ccUITabColor4)
        v:getTitleRenderer():disableEffect()
    end
    sender:setBright(false)
    sender:setEnabled(false)
    sender:setTitleColor(UIUtils.colorTable.ccUITabColor5)
end

function ArrowRankView:tabButtonClick(sender)
	-- lock 
    self._viewMgr:lock(-1)
	self._curChannel = sender._name
	--btn
	self:refreshBtnState(sender)
	
    if self._tableView ~= nil then 
    	if self._tableView.__scrollBg then self._tableView.__scrollBg:removeFromParent() end
    	if self._tableView.__scrollBar then self._tableView.__scrollBar:removeFromParent() end
        self._tableView:removeFromParent()
        self._tableView = nil
    end

    local nothing = self:getUI("bg.nothing")
    if self._data == nil or next(self._data) == nil then
    	nothing:setVisible(true)
		return
	else
		nothing:setVisible(false)
	end

    local tableBg = self:getUI("bg.rankBg")
    self._tableView = cc.TableView:create(cc.size(tableBg:getContentSize().width - 10, tableBg:getContentSize().height - 10))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(5, 5))
    self._tableView:setDelegate()
    self._tableView:setBounceable(true) 
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    tableBg:addChild(self._tableView)
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end

    UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), -2, 6)

    --请求数据
    ScheduleMgr:delayCall(0, self, function ()
        if not self._isLoadData[self._curChannel] or self._isLoadData[self._curChannel] ~= 1 then
            self._viewMgr:unlock()
            if self._curChannel == "friend" then
            	self._serverMgr:sendMsg("GameFriendServer", "getGameFriendList", {}, true, {}, function (result)
            		self._data = self._arrowModel:getData()
            		self._tableView:reloadData()
            		self:refreshUI(self._curChannel)
            		self._isLoadData[self._curChannel] = 1
            		end)
            elseif self._curChannel == "guildMember" then
            	self._serverMgr:sendMsg("ArrowServer", "getSendArrowInfo", {rType = 0}, true, {}, function (result)
            		self._data = self._arrowModel:getData()
            		self._tableView:reloadData()
            		self:refreshUI(self._curChannel)
            		self._isLoadData[self._curChannel] = 1
            		end)
            end
            return
        end

        self._data = self._arrowModel:getData()
        self._tableView:reloadData()
        self:refreshUI(self._curChannel)
        self._viewMgr:unlock()
        -- dump(self._data, "456")
    end)
end

function ArrowRankView:setMyRank(inType)	
end

function ArrowRankView:scrollViewDidScroll(view)
	UIUtils:ccScrollViewUpdateScrollBar(view)
end

function ArrowRankView:cellSizeForTable(table,idx)
	return 90, 418
end

function ArrowRankView:tableCellAtIndex(table, idx)
	local cellData = self._data[self._curChannel][idx+1]
	local cell = table:dequeueCell()
	if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local item = self:createCell(cellData, idx)
    item:setPosition(cc.p(0,1))
    item:setAnchorPoint(cc.p(0,0))
    cell:addChild(item)

    return cell
end

function ArrowRankView:numberOfCellsInTableView(table)
	return #self._data[self._curChannel]
end

function ArrowRankView:tableCellWillRecycle(table,cell)

end

function ArrowRankView:createCell(cellData, idx)
	if cellData == nil then
		return
	end

	--bg
    if idx + 1 <= 3 then
    	self._cellItem:loadTexture("arrow_rankBg".. idx+1 ..".png", 1)
    else
    	self._cellItem:loadTexture("arrow_rankBg4.png", 1)
    end

    --item clone
	local item = self._cellItem:clone()
    item:setVisible(true)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)

    --rankNum
	local rankImgData = {"arenaRank_first.png","arenaRank_second.png","arenaRank_third.png"}
	local rankNum = item:getChildByFullName("rankNum")
	if rankNum ~= nil then
		rankNum:removeFromParent(true)
		rankNum = nil
	end
	if idx + 1 <= 3 then
		rankNum = ccui.ImageView:create(rankImgData[idx + 1],1)
	    rankNum:setPosition(cc.p(52,item:getContentSize().height*0.5)) --58
	    rankNum:setAnchorPoint(cc.p(0.5,0.5))	
		item:addChild(rankNum)
	else
		rankNum = cc.Label:createWithBMFont(UIUtils.bmfName_rank, "00")
		rankNum:setString(idx + 1)
		rankNum:setAnchorPoint(cc.p(0.5,0))  
	    rankNum:setPosition(cc.p(54,item:getContentSize().height*0.5 - 7))  --47
	    item:addChild(rankNum)
	end

	--本人标签
	local selfMark = item:getChildByFullName("selfMark")
	if selfMark == nil then
		selfMark = ccui.ImageView:create("arenaRankUI_selfTag.png",1)
	    selfMark:setPosition(cc.p(0,item:getContentSize().height)) --58
	    selfMark:setAnchorPoint(cc.p(0,1))	
		item:addChild(selfMark)
	end
	selfMark:setVisible(cellData.rid == self._userModelData._id)
   
    --avatar
	local headIcon = item:getChildByFullName("avatar")
	if not headIcon then
		headIcon = IconUtils:createHeadIconById({avatar = cellData["avatar"], tp = 4,avatarFrame=cellData["avatarFrame"], tencetTp = cellData["qqVip"] })
	    headIcon:setAnchorPoint(0, 0.5)
	    headIcon:setPosition(125, item:getContentSize().height/2)
        headIcon:setScale(0.73)
	    headIcon:setName("avatar")
	    item:addChild(headIcon, 2)
	else
		IconUtils:updateHeadIconByView(self._avatar,{avatar = cellData["avatar"], tp = 4,avatarFrame=cellData["avatarFrame"], tencetTp = cellData["qqVip"]})
	end

	--name
	local nameLab = item:getChildByFullName("name")
	UIUtils:setTitleFormat(nameLab, 2)
	nameLab:setPosition(203, 57)
    nameLab:setString(cellData["name"])
    
    --vip
    local vipLab = item:getChildByFullName("vipLab")
    if vipLab == nil then
		vipLab = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "v"..(cellData["vipLvl"] or 0))
		vipLab:setAnchorPoint(cc.p(0,0.5))
		vipLab:setName("vipLab")
		vipLab:setScale(0.8)
		item:addChild(vipLab, 2)
	else
		vipLab:setString("v"..(cellData["vipLvl"] or 0))
	end
	vipLab:setPosition(nameLab:getPositionX() + nameLab:getContentSize().width * nameLab:getScale() + 10, nameLab:getPositionY() - 3)

	if not cellData["vipLvl"] or cellData["vipLvl"] == 0 then
		vipLab:setVisible(false)
	else
		vipLab:setVisible(true)
	end

	--score
	local score = item:getChildByFullName("score")
    score:setString("评分："..cellData["arrowScore"])

    --tequan
    -- cellData["tequan"] = "sq_gamecenter"
	-- cellData["qqVip"] = "is_qq_svip"
    local tequan = item:getChildByFullName("tequan")
    local tequanImg = IconUtils.tencentIcon[cellData["tequan"]] or "globalImageUI6_meiyoutu.png"
    if tequan == nil then
		local tequanIcon = ccui.ImageView:create(tequanImg, 1)
	    tequanIcon:setScale(0.7)
	    tequanIcon:setPosition(cc.p(370, score:getPositionY()))
		item:addChild(tequanIcon)
	else
		tequanIcon:loadTexture(tequanImg, 1)
    end
    
    return item
end

return ArrowRankView
