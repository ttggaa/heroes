--
-- Author: zhaoyang
-- Date: 2016-06-16 12:21:18
--

local DialogAiRenRank = class("DialogAiRenRank",BasePopView)
function DialogAiRenRank:ctor(params) 
    self.super.ctor(self)
    self._bossModel = self._modelMgr:getModel("BossModel")
    self._callBack = params.callback

end
local bossId = 4
-- 初始化UI后会调用, 有需要请覆盖
function DialogAiRenRank:onInit()
	-- self._bossModel:reSetPVEScoreRank()
	self:registerClickEventByName("bg.closeBtn", function ()
		if self._callBack then
			self._callBack()
		end
        self:close()
        UIUtils:reloadLuaFile("pve.DialogAiRenRank")
    end)
    -- local randData = self._bossModel:getPVEScoreRank(bossId)	
	self._noRankFlag = self:getUI("bg.noRankFlag")
	self._noRankFlag:setVisible(false)
	self._titleBg = self:getUI("bg.titleBg")
    for k, v in pairs(self._titleBg:getChildren()) do
        if tolua.type(v) == "ccui.Text" then
            v:setFontName(UIUtils.ttfName)
        end
    end
	local noTxt = self:getUI("bg.noRankFlag.noTxt")
	noTxt:setFontName(UIUtils.ttfName)
	self._leftBoard = self:getUI("bg.leftBoard")
	self._leftBoard:setZOrder(5)
	
    self._rankItem = self:getUI("bg.rankItem")
    self._rankItem:setVisible(false)
    self._selfItem = self:getUI("bg.selfItem")
    self._selfAward = self:getUI("bg.selfAward")
    self._selfAward:setVisible(true)
	self:registerClickEventByName("bg.selfAward.ruleBtn", function ()
        self._viewMgr:showDialog("pve.PveRuleView", {viewType = 1}, true, true)
    end)

    self._tableNode = self:getUI("bg.tableNode")
    self._tableCellW,self._tableCellH = self._rankItem:getContentSize().width-18,self._rankItem:getContentSize().height
	
	-- 暂时不做监听刷新
	-- self:listenReflash("BossModel", self.reflashUI)

	-- 递进刷新控制
	self.beginIdx = 1
	self.endIdx = 30
	self.addStep = 30

	-- self._rankSchedule = ScheduleMgr:regSchedule(50, self, function(self, dt)		
 --        local rankData = self._bossModel:getPVEScoreRank(bossId)
 --        if rankData and  #rankData > 0  then
	-- 		self._tableData = self._bossModel:getPVEScoreRank(bossId)			
	-- 		self:reflashNo1(self._tableData[1])
	-- 	else
	-- 		self:reflashNo1(nil)
	-- 	end		
	-- 	ScheduleMgr:unregSchedule(self._rankSchedule)
	-- end)
	self._tableData = {} 
	self:reflashNo1()
	self:addTableView()
	
end

local rankImgs = {"firstImg","secondImg","thirdImg"}
function DialogAiRenRank:reflashUserInfo()
	local item  = self._selfItem:clone()
	-- local arenaD = self._arenaModel:getArena()

    local bossData = self._bossModel:getDataByPveId(bossId)
	local rank = 0
    if bossData then
        rank = bossData.rank or 0
    end
	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("0", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(70, 45)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
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
	if txt then
		txt:setVisible(false)
		txt:removeFromParent()
	end
	if not rank or rank > 9999 or rank == 0 or rank == "" then
		rankLab:setVisible(false)
		local txt = ccui.Text:create()
		txt:setName("rankTxt")
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
    local bossData = self._bossModel:getData()[tostring(bossId)]
	if bossData then
		totalScore = bossData.totalScore or 0
	end

	local scoreNum = self:getUI("bg.selfAward.destxt")
    scoreNum:setFontName(UIUtils.ttfName)
	scoreNum:setString("累计击杀 " .. totalScore)

	local desTxt = self:getUI("bg.selfAward.destxt1")
    desTxt:setFontName(UIUtils.ttfName)
	local dwarfWeeklyReward = clone(tab["dwarfWeeklyReward"])
	if rank == 0 or not rank then
		local iconNode = self:getUI("bg.selfAward.iconNode")
		iconNode:setScale(0.7)
		local award = dwarfWeeklyReward[1].award[1]
		local itemId = tonumber(IconUtils.iconIdMap[award[1]])
    	local toolD = tab:Tool(itemId)
    	num = tonumber(award[3])
		local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,eventStyle = 0})
	    -- icon:setContentSize(cc.size(100, 100))
	    icon:setPosition(5, 4)
	    iconNode:addChild(icon)
	    desTxt:setString("排名进入" .. dwarfWeeklyReward[1].pos[2] .. "可获得：")
    else
		for k,v in pairs(dwarfWeeklyReward) do
			local pos = v.pos
			if tonumber(rank) >= tonumber(pos[1]) and tonumber(rank) <= tonumber(pos[2]) then
				-- dump(v,"data===>>")
				local iconNode = self:getUI("bg.selfAward.iconNode")
				iconNode:setScale(0.7)
				local award = v.award[1]
				local itemId = tonumber(IconUtils.iconIdMap[award[1]])
				-- print("==================award[1]======",award[1])
		    	local toolD = tab:Tool(itemId)
		    	num = tonumber(award[3])
				local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = num,eventStyle = 0})
			    -- icon:setContentSize(cc.size(100, 100))
			    icon:setPosition(5, 4)
			    iconNode:addChild(icon)
		        break
		    end
		end
	end


    self._selfItem:getParent():addChild(item)
end

function DialogAiRenRank:reflashNo1( data )
	local name = self._leftBoard:getChildByFullName("name")
    name:setFontName(UIUtils.ttfName)
	local level = self._leftBoard:getChildByFullName("level")
    level:setFontName(UIUtils.ttfName)
	local guild = self._leftBoard:getChildByFullName("guild")
    guild:setFontName(UIUtils.ttfName)
    local guildDes = self._leftBoard:getChildByFullName("guildDes")	
	guildDes:setVisible(false)
	name:setString("暂无榜首")
	level:setString("")	
	guild:setString("")
	if not data then return	end
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
	--[[
	local avatarName = data.avatar
	if avatarName == 0 then avatarName = 1203 end	
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3,avatarFrame = data["avatarFrame"]})
	icon:setAnchorPoint(cc.p(0.5,0.5))
	-- icon:setScale(1.21)
	icon:setPosition(100,410)
	self._leftBoard:addChild(icon)
	]]
	self:registerClickEventByName("bg.leftBoard",function( )
		self._serverMgr:sendMsg("BossServer", "getPVERankDetailInfo", {bossId = 4,roleId = data.rid}, true, {}, function(result) 
		-- self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = data.rid}, true, {}, function(result) 
			local data1 = clone(result)
			data1.rank = 1
			self._viewMgr:showDialog("pve.DialogPVEUserInfo",data1,true)
	    end)
	end)
end


function DialogAiRenRank:addTableView( )
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

function DialogAiRenRank:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()
    -- self:setSlider()
end

function DialogAiRenRank:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function DialogAiRenRank:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function DialogAiRenRank:cellSizeForTable(table,idx) 
    return self._tableCellH+5,self._tableCellW
end

function DialogAiRenRank:tableCellAtIndex(table, idx)
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

function DialogAiRenRank:numberOfCellsInTableView(table)
	-- print("#self._tableData",#self._tableData)
	return #self._tableData
	-- if #self._tableData > 0 then
	-- 	return 3
	-- else
	-- 	return 0
	-- end
end

--[[
function DialogAiRenRank:setSlider( )
	if not self._sliderBarScope then
		local sliderBgH = self._sliderBg:getContentSize().height
		local sliderBarH = self._sliderBar:getContentSize().height
	    self._sliderBarScope = sliderBgH - sliderBarH
	end

	local containerOffsetY = self._tableView:getContentOffset().y --self._listView:getInnerContainer():getPositionY()
	local totalHeight =  #self._tableData*self._tableCellH - 427 --self._listView:getInnerContainer():getContentSize().height-self._listView:getContentSize().height
	local offsetY = math.abs((containerOffsetY/totalHeight)*self._sliderBarScope)
	-- print("offsetY....",offsetY)
	if containerOffsetY > 0 then offsetY = 0 end
	if containerOffsetY <= -totalHeight then offsetY = self._sliderBarScope end
	self._sliderBar:setPositionY(offsetY)
end
]]
-- 接收自定义消息
function DialogAiRenRank:reflashUI(data)
	self._tableData = self._bossModel:getPVEScoreRank(bossId)
	-- dump(self._tableData,"self._tableData-==")
	if not self._tableData or #self._tableData <= 0 then
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
	    -- dump(self._tableData, "self.tableData[1]")
	end
end

local rankTextColor = {cc.c4b(254, 203, 34, 255),cc.c4b(183, 215, 215, 255),cc.c4b(253, 156, 87, 255)}
function DialogAiRenRank:createItem( data,index )
	if data == nil then return end
	local item = self._rankItem:clone()
	item:setVisible(true)
	item.data = data
	local rank = data.rank or index 
	local score = data.score
	local name = data.name
	-- local unionLab = data.unionName or "没有工会"
	
	local nameLab = item:getChildByFullName("nameLab")
    nameLab:setFontName(UIUtils.ttfName)
	nameLab:setString(name)
	local UIscoreLab = item:getChildByFullName("scoreLab")
	UIscoreLab:setFontName(UIUtils.ttfName)
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
	
	item:setSwallowTouches(false)
	self:registerClickEvent(item,function( )
		if not self._inScrolling then
			-- dump(data)
			self._serverMgr:sendMsg("BossServer", "getPVERankDetailInfo", {bossId = 4,roleId = data.rid}, true, {}, function(result) 
			-- self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = data.rid}, true, {}, function(result) 
				local data1 = clone(result)
				data1.rank = rank
				self._viewMgr:showDialog("pve.DialogPVEUserInfo",data1,true)
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

function DialogAiRenRank:createRoleHead(data,headNode,scaleNum)
	local avatarName = data.avatar
	local scale = scaleNum and scaleNum or 0.8
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl
	local icon = IconUtils:createHeadIconById({avatar = avatarName,tp = 3 ,level = lvl,avatarFrame = data["avatarFrame"]})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5,0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width*0.5,headNode:getContentSize().height*0.5 - 2)
	headNode:addChild(icon)
end
function DialogAiRenRank:getBmpFromNum( num,node,offsetx )
	offsetx = offsetx or 16
	local width = 0
	local widget = node or ccui.Widget:create()
	local numStr = tostring(num)
	local numSps = {}
	local endPos = string.len(numStr)
	local pos = 1
	while pos <= endPos do
		local numC = string.sub(numStr,pos,pos)
		if numC then 
			local numSp = ccui.ImageView:create("pveAiRenI_" .. numC .. ".png",1)
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

function DialogAiRenRank.dtor()
	-- body
	bossId = nil
	rankImgs = nil
	rankTextColor = nil
end

return DialogAiRenRank