--
-- Author: huangguofang
-- Date: 2018-05-02 17:47:13
--
-- 
local StakeRankDialog = class("StakeRankDialog",BasePopView)
function StakeRankDialog:ctor(params) 
    self.super.ctor(self)
	self._rankModel = self._modelMgr:getModel("RankModel")
	self._callBack = params.callback
	self._rankType = self._rankModel.kRankTypeStakeDamage
	self._stakeNum = params.stakeNum
end
-- 初始化UI后会调用, 有需要请覆盖
function StakeRankDialog:onInit()

	self:registerClickEventByName("bg.closeBtn", function ()
		if self._callBack then
			self._callBack()
		end
        self:close()
        UIUtils:reloadLuaFile("training.StakeRankDialog")
    end)
    self._noRankFlag = self:getUI("bg.noRankFlag")
	self._noRankFlag:setVisible(false)
	self._titleBg = self:getUI("bg.titleBg") 
    
	self._leftBoard = self:getUI("bg.leftBoard")
	self._leftBoard:setZOrder(5)
    self._rankItem = self:getUI("bg.rankItem")
    self._rankItem:setSwallowTouches(false)
    self._rankItem:setVisible(false)

    self._selfItem = self:getUI("bg.selfItem")
    self._selfAward = self:getUI("bg.selfAward")
    self._selfAward:setVisible(true)
	self:registerClickEventByName("bg.selfAward.ruleBtn", function ()
        self._viewMgr:showDialog("training.StakeRuleDialog", {stakeNum = self._stakeNum}, true)
    end)

    self._tableNode = self:getUI("bg.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem:getContentSize().width-18,self._rankItem:getContentSize().height

	-- 递进刷新控制
	local settingD = tab:Setting("STAKE_HERO_RANK")
	local flashData = settingD and settingD.value or {}
	self.beginIdx = tonumber(flashData[1]) or 20
    self.addStep = tonumber(flashData[1]) or 20
    self.endIdx = tonumber(flashData[2]) or 500

	self._tableData = {} 
	self:reflashNo1()
	self:addTableView()	
end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function StakeRankDialog:reflashUserInfo()
	local item  = self._selfItem
	-- local arenaD = self._arenaModel:getArena()
    local rankData = self._rankModel:getSelfRankInfo(self._rankType)
	local rank = 0 
    if rankData then
        rank = rankData.rank or 0
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
	if rank then  
		if rankImgs[tonumber(rank)] then
			rankLab:setVisible(false)
			local rankImg = item:getChildByFullName(rankImgs[tonumber(rank)])
			rankImg:setVisible(true)
		else
			rankLab:setVisible(true)
		end
	end
	local txt = item._rankTxt
	if txt then
		txt:setVisible(false)
		txt:removeFromParent()
	end
	if not rank or rank > 9999 or rank == 0 or rank == "" then
		rankLab:setVisible(false)		
		local txt = ccui.Text:create()
		item._rankTxt = txt
		txt:setString("暂未上榜")
		txt:setFontSize(24)
		txt:setPosition(60, 38)
		txt:setFontName(UIUtils.ttfName)
		txt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		item:addChild(txt)			
	end
	local nameLab = item:getChildByFullName("nameLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")
	nameLab:setVisible(false)
	UIscoreLab:setVisible(false)

	local totalScore = 0
	if rankData then
		totalScore = rankData.score or 0
	end

	local scoreNum = self:getUI("bg.selfAward.destxt")
    scoreNum:setFontName(UIUtils.ttfName)
	scoreNum:setString("最高伤害: " .. totalScore)

	local desTxt = self:getUI("bg.selfAward.destxt1")
    desTxt:setFontName(UIUtils.ttfName)
	local stakeTb = clone(tab.stakeReward)
	if rank == 0 or not rank then
		local iconNode = self:getUI("bg.selfAward.iconNode")
		iconNode:setScale(0.7)
		local rewards = stakeTb[#stakeTb].reward
		if rewards then
			reward = rewards[1]
		end
		local itemId = reward[2]
		if reward[1] ~= "tool" then
			itemId = tonumber(IconUtils.iconIdMap[reward[1]])
		end
    	local toolD = tab:Tool(itemId)
    	num = tonumber(reward[3])
		local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,eventStyle = 0})
	    -- icon:setContentSize(cc.size(100, 100))
	    icon:setPosition(5, 4)
	    iconNode:addChild(icon)
	    desTxt:setString("排名进入" .. stakeTb[#stakeTb].pos[2] .. "名可获得：")
    else
		for k,v in pairs(stakeTb) do
			local pos = v.pos
			if tonumber(rank) >= tonumber(pos[1]) and tonumber(rank) <= tonumber(pos[2]) then
				local iconNode = self:getUI("bg.selfAward.iconNode")
				iconNode:setScale(0.7)
				local rewards = v.reward
				if rewards then
					reward = rewards[1]
				end
				local itemId = reward[2]
				if reward[1] ~= "tool" then
					itemId = tonumber(IconUtils.iconIdMap[reward[1]])
				end
		    	local toolD = tab:Tool(itemId)
		    	num = tonumber(reward[3])
				local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,eventStyle = 0})
			    icon:setPosition(5, 4)
			    iconNode:addChild(icon)
		        break
		    end
		end
	end
end

function StakeRankDialog:reflashNo1( data )
	local name = self._leftBoard:getChildByFullName("name")
    name:setFontName(UIUtils.ttfName)
	local level = self._leftBoard:getChildByFullName("level")
    level:setFontName(UIUtils.ttfName)
	local guild = self._leftBoard:getChildByFullName("guild")
	local guildDes = self._leftBoard:getChildByFullName("guildDes")	
	guildDes:setVisible(false)
    guild:setFontName(UIUtils.ttfName)
	name:setString("暂无榜首")
	level:setString("")	
	guild:setString("")

	if not data then return end
	guildDes:setVisible(true)
	name:setString(data.name)
	local inParam = {lvlStr = "Lv." .. (data.level or data.lvl or 0), lvl = (data.level or data.lvl or 0), plvl = data.plvl}
    UIUtils:adjustLevelShow(level, inParam, 1)
    local guildName = data.guildName
	if  not guildName then
		guildName = "暂无联盟"
	end
	local nameLen = utf8.len(guildName)
	if nameLen > 6 then
		guildName = string.sub(guildName,1,15) .. "..."
	end
	if guildName and guildName ~= "" then
		guild:setString("" .. (guildName or ""))
	else		
		guildDes:setVisible(false)
		guild:setString("")
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
	
	self:registerClickEventByName("bg.leftBoard",function( )
		-- 获取上榜时的数据信息
		self._serverMgr:sendMsg("RankServer", "getDetailRank", {type=self._rankType ,roleId=data.rid or data._id,id=1}, true, {}, function(result) 
			local udata = result
			-- dump(udata,"udata==>",5)
			-- data.isNotShowBtn = true
			self._viewMgr:showDialog("arena.DialogArenaUserInfo",udata,true)
	    end)
	end)
end

function StakeRankDialog:addTableView( )
	self._tableViewH = 318
    local tableView = cc.TableView:create(cc.size(660, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(11,5))
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
    tableView:reloadData()
end

function StakeRankDialog:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
    -- self:setSlider()
end

function StakeRankDialog:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function StakeRankDialog:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function StakeRankDialog:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function StakeRankDialog:tableCellAtIndex(table, idx)
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
    item:setPosition(cc.p(0,4))
    item:setAnchorPoint(cc.p(0,0))
    cell:addChild(item)

    return cell
end

function StakeRankDialog:numberOfCellsInTableView(table)
	return #self._tableData
	
end
-- 接收自定义消息
function StakeRankDialog:reflashUI(data)
	
	self._tableData = self._rankModel:getRankList(self._rankType) 
	if not self._tableData or #self._tableData <= 0 then
		self._tableData = {}
		self._noRankFlag:setVisible(true)
		self._titleBg:setVisible(false)
	else
		self._noRankFlag:setVisible(false)
		self._titleBg:setVisible(true)
	end

	self:reflashUserInfo()	
    if self._tableData  and self._tableView then
	    self._tableView:reloadData()
	    self:reflashNo1(self._tableData[1])	    
	    -- dump(self._tableData, "self.tableData")
	end

end

function StakeRankDialog:createItem( data,index )
	if data == nil then return end
	local item = self._rankItem:clone()
	item:setVisible(true)
	item.data = data
	local rank = index 
	local score = data.score
	local name = data.name
	-- local unionLab = data.unionName or "没有工会"
	local nameLab = item:getChildByFullName("nameLab")
    nameLab:setFontName(UIUtils.ttfName)
	nameLab:setString(name)
	local UIscoreLab = item:getChildByFullName("scoreLab")
	UIscoreLab:setFontName(UIUtils.ttfName)
	UIscoreLab:setString(ItemUtils.formatItemCount(score))
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
	end

	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			-- dump(data)
			-- 获取上榜时的数据信息
			self._serverMgr:sendMsg("RankServer", "getDetailRank", {type=self._rankType ,roleId=data.rid or data._id,id=1}, true, {}, function(result) 
				local udata = result
				-- data.isNotShowBtn = true
				self._viewMgr:showDialog("arena.DialogArenaUserInfo",udata,true)
		    end)
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
    tequanIcon:setPosition(cc.p(266, item:getContentSize().height*0.5 - 22))
	item:addChild(tequanIcon)

	--    data["qqVip"] = "is_qq_svip"
    local qqVipImg = (data["qqVip"] and data["qqVip"] ~= "") and IconUtils.tencentIcon[data["qqVip"] .. "_head"] or "globalImageUI6_meiyoutu.png"
    local qqVipIcon = ccui.ImageView:create(qqVipImg, 1)
    qqVipIcon:setScale(24 / qqVipIcon:getContentSize().width)
    qqVipIcon:setPosition(cc.p(nameLab:getPositionX() + nameLab:getContentSize().width + 16, item:getContentSize().height*0.5 + 5))
	item:addChild(qqVipIcon)

	return item
end

-- 创建玩家头像
function StakeRankDialog:createRoleHead(data,headNode,scaleNum)
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

function StakeRankDialog.dtor()
	-- body
	rankImgs = nil
end
return StakeRankDialog