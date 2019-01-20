--[[
    Filename:    PurgatoryRankView.lua
    Author:      <yuxiaojing@playcrab.com>
    Datetime:    2018-02-08 20:02:00
    Description: 爬塔排行榜
--]]

local PurgatoryRankView = class("PurgatoryRankView", BasePopView)

function PurgatoryRankView:ctor()
    self.super.ctor(self)
    self.initAnimType = 1
	self._rankType = 33
    self._rankModel = self._modelMgr:getModel("RankModel")
end

function PurgatoryRankView:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
		self._rankModel:clearRankList()
        self:close()
        UIUtils:reloadLuaFile("purgatory.PurgatoryRankView")
    end)
	self._itemData = nil
	self._leftBoard = self:getUI("bg.leftBoard")
	self._leftBoard:setZOrder(5)
	self._noRankBg = self:getUI("bg.noRankBg")
	self._noRankBg:setVisible(false)
	self._titleBg = self:getUI("bg.titleBg")

    self._rankItem = self:getUI("bg.rankItem")
    self._selfItem = self._rankItem

    self._tableNode = self:getUI("bg.tableNode")
    self._tableCellW, self._tableCellH = self._rankItem:getContentSize().width - 18, self._rankItem:getContentSize().height

	self._tableData = {}
	self._allRankData = {}
	-- 递进刷新控制
	-- local flashData = tab:Setting("").value
	self.beginIdx = 20
	self.addStep = 20
	self.endIdx = 500

    self._offsetX = nil
    self._offsetY = nil
    self._tableView = nil

	self:addTableView()
end

local rankImgs = {"firstImg", "secondImg", "thirdImg"}
function PurgatoryRankView:reflashUserInfo()
	local item  = self._selfItem
	local rankData = self._rankModel:getSelfRankInfo(self._rankType)
	if not rankData then print("====================no rankInfo....", self._rankType) return end
	
	local nameLab = item:getChildByFullName("nameLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")

	local rank = rankData.rank
	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
		rankLab = cc.Label:createWithTTF("0", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5, 0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(60, 38)
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end
	rankLab:setScale(0.9)
	--玩家名称
	local userData = self._modelMgr:getModel("UserModel"):getData()
	nameLab:setString(userData.name)

	--得分label
	UIscoreLab:setString(rankData.score or "")

	for i = 1, 3 do
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
	local txt = item:getChildByFullName("rankTxt")
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
		txt:setPosition(80, 38)
		txt:setFontName(UIUtils.ttfName)
		txt:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		item:addChild(txt)		
	end

	self:registerClickEvent(item, function( )
		self:selfItemClicked(rankData)
	end)

	local headNode = item:getChildByFullName("headNode")
	headNode:removeAllChildren()
	headNode:setVisible(true)
	self:createRoleHead(userData, headNode, 0.7)
end

function PurgatoryRankView:reflashNo1( data )

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

	if not data then return end
	guildDes:setVisible(true)
	local name = self._leftBoard:getChildByFullName("name")
	name:setString(data.name)
	local level = self._leftBoard:getChildByFullName("level")
	local inParam = {lvlStr = "Lv." .. (data.level or data.lvl or 0), lvl = (data.level or data.lvl or 0), plvl = data.plvl}
    UIUtils:adjustLevelShow(level, inParam, 1)
	--联盟label
	local guildName = data.guildName
	if guildName and guildName ~= "" then 
		guild:setVisible(true)
		local nameLen = utf8.len(guildName)
		if nameLen > 6 then
			guildName = string.sub(guildName, 1, 15) .. "..."
		end
		guild:setString("" .. (guildName or ""))
	else
		guildDes:setVisible(false)
		guild:setVisible(false)
	end
	-- 左侧人物形象
	local heroId = data.fHeroId
	if not heroId or heroId == 0 then
		heroId = 60102
	end
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    if data.heroSkin then
        local heroSkinD = tab.heroSkin[data.heroSkin]
        heroArt = (heroSkinD and heroSkinD["heroart"]) and heroSkinD["heroart"] or heroD["heroart"]
    end
    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
    sp:setScale(0.8)
    sp:setAnchorPoint(0.5,0)
    sp:setPosition(self._leftBoard:getContentSize().width*0.5, self._leftBoard:getContentSize().height*0.5 - 30)
    self._leftBoard._roleAnim = sp
    self._leftBoard:addChild(sp,1)
	
	self:registerClickEventByName("bg.bgPanel.leftBoard",function( )
		self:itemClicked(data)
	end)
end

function PurgatoryRankView:addTableView( )
	self._tableViewH = 350
    local tableView = cc.TableView:create(cc.size(660, self._tableViewH))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(5, 6))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableNode:addChild(tableView, 999)

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


function PurgatoryRankView:createLoadingMc()
	if self._loadingMc then return end
	-- 添加加载中动画
	self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setName("loadingMc")
    self._loadingMc:setPosition(cc.p(self._tableNode:getContentSize().width * 0.5 - 30, self._tableView:getPositionY() + 20))
    self._tableNode:addChild(self._loadingMc, 1000)
    self._loadingMc:setVisible(false)
end

function PurgatoryRankView:scrollViewDidScroll(view)
	self._inScrolling = view:isDragging()

    local offsetY = view:getContentOffset().y   	
	if offsetY >= 100 and #self._tableData > 5 and #self._tableData < self.endIdx and not self._canRequest then
		self._canRequest = true
		self:createLoadingMc()
		if not self._loadingMc:isVisible() then
			self._loadingMc:setVisible(true)
		end
	end	
		
    local condY = 0
    if self._tableData and #self._tableData < 4 then
    	condY = self._tableViewH - #self._tableData*(self._tableCellH + 5)
    end
	if self._inScrolling then
	    if offsetY >= condY + 100 and not self._canRequest then
            self._canRequest = true			
			self:createLoadingMc()            
            if not self._loadingMc:isVisible() then
				self._loadingMc:setVisible(true)
			end
        end
        if offsetY < condY + 20 and self._canRequest then
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

function PurgatoryRankView:scrollViewDidZoom(view)
end

function PurgatoryRankView:tableCellTouched(table, cell)
end

function PurgatoryRankView:cellSizeForTable(table, idx) 
    return self._tableCellH + 5, self._tableCellW
end

function PurgatoryRankView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
    local cellData = self._tableData[idx + 1]
    local item = self:createItem(cellData, idx + 1)
    item:setPosition(cc.p(5, 4))
    item:setAnchorPoint(cc.p(0, 0))
    cell:addChild(item)

    return cell
end

function PurgatoryRankView:numberOfCellsInTableView(table)
	return #self._tableData	
end

function PurgatoryRankView:createItem( data, index )
	if data == nil then return end
	self._itemData = data

	local item = self._rankItem:clone()
	local nameLab = item:getChildByFullName("nameLab")
	local UIscoreLab = item:getChildByFullName("scoreLab")
	local selfTag = item:getChildByFullName("selfTag")

	item:loadTexture("globalPanelUI7_cellBg21.png", 1)
	item:setContentSize(self._tableCellW, self._tableCellH)
	item:setCapInsets(cc.rect(20, 20, 1, 1))
	item:setSwallowTouches(false)
	selfTag:setVisible(false)

	item:setVisible(true)
	self._currItem = item
	item.data = data
	local rank = data.rank
	local score = data.score

	--初始化名称
	local name = data.name or ""
	nameLab:setString(name)

	UIscoreLab:setString(score)
	local txt  = item:getChildByFullName("rankTxt")
	if txt then
		txt:setVisible(false)
		txt:removeFromParent()
	end
	local rankLab = item:getChildByName("rankLab")
	if not rankLab then
	    rankLab = cc.Label:createWithTTF("", UIUtils.ttfName, 28) --cc.LabelBMFont:create("4", UIUtils.bmfName_rank)
	    rankLab:setAnchorPoint(cc.p(0.5,0.5))
	    rankLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    rankLab:setPosition(item:getChildByFullName('firstImg'):getPosition())
	    rankLab:setName("rankLab")
	    item:addChild(rankLab, 1)
	end
	rankLab:setString(rank or 0)
	for i = 1, 3 do
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
	headNode:setVisible(true)
	headNode:removeAllChildren()
	self:createRoleHead(data,headNode, 0.65)
	return item
end

function PurgatoryRankView:createRoleHead(data,headNode,scaleNum)
	local avatarName = data.avatar
	local scale = scaleNum and scaleNum or 0.8
	if avatarName == 0 or not avatarName then avatarName = 1203 end	
	local lvl = data.lvl

    local tencetTp = data["qqVip"]
	local icon = IconUtils:createHeadIconById({avatar = avatarName, tp = 3, level = lvl, 
												avatarFrame = data["avatarFrame"], tencetTp = tencetTp, plvl = data["plvl"]})
	icon:setName("avatarIcon")
	icon:setAnchorPoint(cc.p(0.5, 0.5))
	icon:setScale(scale)
	icon:setPosition(headNode:getContentSize().width * 0.5,headNode:getContentSize().height * 0.5 - 2)
	headNode:addChild(icon)
end

function PurgatoryRankView:reflashNoRankUI()
	if (not self._tableData or #self._tableData <= 0) then
		self._rankItem:setVisible(false)
		self._noRankBg:setVisible(true)
		self._tableNode:setVisible(false)
		self._titleBg:setVisible(false)
	else
		self._noRankBg:setVisible(false)
		self._tableNode:setVisible(true)
		self._titleBg:setVisible(true)
		self._rankItem:setVisible(true)
	end
end

function PurgatoryRankView:selfItemClicked(data)
	if not data then return end
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local roleId = userData._id
	if roleId and roleId ~= 0 then
		self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = roleId, fid = 36}, true, {}, function(result) 
			local data1 = result
			data1.rank = data.rank
			self._viewMgr:showDialog("arena.DialogArenaUserInfo", data1, true)
	    end)
	else
		print("=======数据异常=======")
	end
end

function PurgatoryRankView:itemClicked(data)	
	if not data then return end
	if data._id and data._id ~= 0 then
		self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = data._id, fid = 36}, true, {}, function(result) 
			local data1 = result
			data1.rank = data.rank
			self._viewMgr:showDialog("arena.DialogArenaUserInfo", data1, true)
	    end)
	else
		print("=======数据异常=======")
	end
end

--是否要刷新排行榜
function PurgatoryRankView:sendMessageAgain()
	-- self.beginIdx -- self.endIdx -- self.addStep
	self._allRankData = self._rankModel:getRankList(self._rankType)
	local starNum = self._rankModel:getRankNextStart(self._rankType)
	local statCount = tonumber(self.beginIdx)
	local endCount = tonumber(self.endIdx)
	local addCount = tonumber(self.addStep)

	if #self._tableData == #self._allRankData and #self._allRankData % addCount == 0 and #self._allRankData < endCount then
		--如果本地没有更多数据则向服务器请求
		self:sendGetRankMsg(self._rankType,starNum,function()
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
function PurgatoryRankView:searchForPosition(statCount, addCount, endCount)	
	self._offsetX = 0
	if statCount + addCount <= endCount then
		self.beginIdx = statCount + addCount
		local subNum = #self._allRankData - statCount

		if subNum < addCount then
			self._offsetY = -1 * (tonumber(subNum) * (self._tableCellH+5))			
		else
			self._offsetY = -1 * (tonumber(self.addStep) * (self._tableCellH+5))			
		end
		
	else
		self.beginIdx = endCount
		self._offsetY = -1 * (endCount - statCount) * (self._tableCellH+5)
	end
end

function PurgatoryRankView:sendGetRankMsg(tp, start, callback)
	self._rankModel:setRankTypeAndStartNum(tp,start)
	self._serverMgr:sendMsg("RankServer", "getRankList", {type = tp,startRank = start}, true, {}, function(result) 
		if callback then
			callback()
		end
		self:reflashUI()
    end)
end

function PurgatoryRankView:updateTableData(rankList, index)
	local data = {}
	for k,v in pairs(rankList) do
		if tonumber(v.rank) <= tonumber(index) then
			data[k] = v
		end
	end
	return data
end

function PurgatoryRankView:reflashUI(data)
	local offsetX = nil
	local offsetY = nil
	if self._offsetX and self._offsetY then
		offsetX = self._offsetX
		offsetY = self._offsetY
	end
    self._allRankData = self._rankModel:getRankList(self._rankType)
    self._tableData = self:updateTableData(self._allRankData,self.beginIdx)
    if self._tableData and self._tableView then    	
	    self._tableView:reloadData()
	    if offsetX and offsetY and not self._firstIn then
	    	self._tableView:setContentOffset(cc.p(offsetX,offsetY))
			self._canRequest = false
	    end	    
	    self._firstIn = false
	end

	if #self._tableData > 0 then
		self:reflashUserInfo()
	end
	
	if self._tableData then
		self:reflashNo1(self._tableData[1])
	end

	self:reflashNoRankUI()
end


function PurgatoryRankView.dtor()
	rankImgs = nil	
end

return PurgatoryRankView