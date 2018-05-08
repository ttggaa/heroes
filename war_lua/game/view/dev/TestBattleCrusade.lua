--[[
    Filename:    TestBattleCrusade.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2017-09-27 12:00:36
    Description: File description
--]]

local TestBattleCrusade = class("TestBattleCrusade", BaseView)

function TestBattleCrusade:ctor()
    TestBattleCrusade.super.ctor(self)
end

local HALF_SCREEN_WIDTH = MAX_SCREEN_WIDTH/2 

function TestBattleCrusade:onInit()
    local bg = cc.Sprite:create("asset/map/yaosai1/yaosai1_land.jpg")
    bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bg:setScale(1.3)
    self:addChild(bg, -1)
	
	local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn, 10)
	self._closeBtn = closeBtn
	
	self._playerInfo, self._enemyInfo = self:loadData()
	
	--fightLayer
	self._fightLayer = self:getUI("bg.fightLayer")
	self._myLvlBox = self._fightLayer:getChildByFullName("leftRoot.myHeroLvlPanel.myHeroLvlBox")
	self:registerClickEvent(self._myLvlBox:getParent(), function()
		self._myLvlBox:attachWithIME()
	end)
	self._enemyLvlBox = self._fightLayer:getChildByFullName("rightRoot.enemyHeroLvlPanel.enemyHeroLvlBox")
	self:registerClickEvent(self._enemyLvlBox:getParent(), function()
		self._enemyLvlBox:attachWithIME()
	end)
	self:loadLevelData()
	
	--heroLayer
	self._heroLayer = self:getUI("bg.setLayer.heroLayer")
	self._setViewHeroTitle = self._heroLayer:getChildByFullName("heroTitle")
	self._heroNameLabel = self._heroLayer:getChildByFullName("heroNameLabel")
	self._heroStarBox = self._heroLayer:getChildByFullName("starPanel.heroStarBox")
	self:registerClickEvent(self._heroStarBox:getParent(), function ()  
        self._heroStarBox:attachWithIME()
    end)
	self._heroSkillLevelBox = {}
	for i=1, 5 do
		local box = self._heroLayer:getChildByFullName(string.format("skillPanel%d.skillBox%d", i, i))
		table.insert(self._heroSkillLevelBox, box)
		self:registerClickEvent(box:getParent(), function()
			box:attachWithIME()
		end)
	end
	self._heroSkillKeYinLabel = self._heroLayer:getChildByFullName("skillKeYin")
	self._heroEngravingNode = {
		idBox = self._heroLayer:getChildByFullName("skillKeYinIdPanel.skillKeYinIdBox"),
		slotLevelBox = self._heroLayer:getChildByFullName("skillKeYinSlotLevelPanel.skillKeYinSlotLevelBox"),
		bookLevelBox = self._heroLayer:getChildByFullName("skillKeYinBookLevelPanel.skillKeYinBookLevelBox"),
	}
	for i,v in pairs(self._heroEngravingNode) do
		self:registerClickEvent(v:getParent(), function()
			v:attachWithIME()
		end)
	end
	
	--teamLayer
	self._teamLayer = self:getUI("bg.setLayer.teamLayer")
	self._teamInfoLayer = self._teamLayer:getChildByFullName("infoLayer")
	self._teamSetLayer = self._teamLayer:getChildByFullName("lineupLayer")
	self._teamViewTitle = {
		self._teamLayer:getChildByFullName("infoLayer.teamTitle"),
		self._teamLayer:getChildByFullName("lineupLayer.teamTitle")
	}
	local teamSetCancelBtn = self._teamSetLayer:getChildByFullName("cancelBtn")
	self:registerClickEvent(teamSetCancelBtn, function()
		self._tempPos = nil
		self._tempTeamId = nil
		self._teamSetLayer:setVisible(false)
		self._teamInfoLayer:setVisible(true)
	end)
	local teamSetSureBtn = self._teamSetLayer:getChildByFullName("sureBtn")
	self:registerClickEvent(teamSetSureBtn, function()
		self:onUpTeam()
	end)
	local teamSetDownBtn = self._teamSetLayer:getChildByFullName("downBtn")
	self:registerClickEvent(teamSetDownBtn, function()
		self:onDownTeam()
	end)
	self._teamNameLabel = self._teamSetLayer:getChildByFullName("teamNameLabel")
	self._teamStarBox = self._teamSetLayer:getChildByFullName("teamStarPanel.teamStarBox")
	self:registerClickEvent(self._teamStarBox:getParent(), function()
		self._teamStarBox:attachWithIME()
	end)
	self._teamLevelBox = self._teamSetLayer:getChildByFullName("teamLevelPanel.teamLevelBox")
	self:registerClickEvent(self._teamLevelBox:getParent(), function()
		self._teamLevelBox:attachWithIME()
	end)
	self._teamSkillLevelBox = {}
	for i=1,4 do
		local box = self._teamSetLayer:getChildByFullName(string.format("teamSkillPanel%d.teamSkillBox%d", i, i))
		table.insert(self._teamSkillLevelBox, box)
		self:registerClickEvent(box:getParent(), function()
			box:attachWithIME()
		end)
	end
	self._myTeamIcon = {}
	for i=1, 16 do
		local name = "head"..i..".icon"..i
		local headNode = self._teamInfoLayer:getChildByFullName("head"..i)
		table.insert(self._myTeamIcon, self._teamInfoLayer:getChildByFullName(name))
		self:registerClickEvent(headNode, function()
			self:changeTeamWithPos(i)
		end)
	end	
	--由于敌人兵团的显示方向为镜像翻转所以做如下处理
	self._enemyTeamIcon = {}
	for i=1, 16 do
		local row = math.ceil(i/4)
		table.insert(self._enemyTeamIcon, self._myTeamIcon[8*row-i-3])--8*row-i-3是简化公式，原逆向计算公式为4*row+1-(i-4(row-1))
	end
	
	self:onSetCancel()
	
	
	self:addTeamTableView()
	
	local tabHero = clone(tab.hero)
	self._heroTableData = {}
	for i,v in pairs(tabHero) do
		if i<80000 or i>90000 then
			table.insert(self._heroTableData, {id = i, icon = v.herohead})
		end
	end
	table.sort(self._heroTableData, function(a, b)
		return a.id<b.id
	end)
	self:addHeroTableView()
	
	--设置自己的英雄
	local myHeroBtn = self:getUI("bg.fightLayer.leftRoot.myHero")
	self:registerClickEvent(myHeroBtn, function()
--		self._viewMgr:showTip("myHeroBtn")
		self:setHeroData(true)
	end)
	--设置自己的兵团
	local myLineupBtn = self:getUI("bg.fightLayer.leftRoot.myLineup")
	self:registerClickEvent(myLineupBtn, function()
--		self._viewMgr:showTip("myLineupBtn")
		self:setTeamData(true)
	end)
	--设置敌方英雄
	local enemyHeroBtn = self:getUI("bg.fightLayer.rightRoot.enemyHero")
	self:registerClickEvent(enemyHeroBtn, function()
--		self._viewMgr:showTip("enemyHeroBtn")
		self:setHeroData()
	end)
	--设置敌方兵团
	local enemyLineupBtn = self:getUI("bg.fightLayer.rightRoot.enemyLineup")
	self:registerClickEvent(enemyLineupBtn, function()
--		self._viewMgr:showTip("enemyLineupBtn")
		self:setTeamData()
	end)
	
	--恢复默认数值
	local revertBtn = self:getUI("bg.fightLayer.revertBtn")
	self:registerClickEvent(revertBtn, function()
--		self:saveData(true)
		self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = "是否重置全部数值", button1 = "确定", callback1 = function( )
			self:saveData(true)
			self:loadLevelData()
		end})
	end)
	
	--进入战斗
	local fightBtn = self:getUI("bg.fightLayer.fightBtn")
	self:registerClickEvent(fightBtn, function()
		self:startFight()
	end)
	
	--英雄界面
	local heroSureBtn = self._heroLayer:getChildByFullName("sureBtn")
	self:registerClickEvent(heroSureBtn, function()
		self:onHeroSure()
	end)
	
	local heroCancelBtn = self._heroLayer:getChildByFullName("cancelBtn")
	self:registerClickEvent(heroCancelBtn, function()
		self:onSetCancel()
	end)
	
	--兵团界面
	local teamSureBtn = self._teamInfoLayer:getChildByFullName("sureBtn")
	self:registerClickEvent(teamSureBtn, function()
		self:onTeamSure()
	end)
	
	local teamCancelBtn = self._teamInfoLayer:getChildByFullName("cancelBtn")
	self:registerClickEvent(teamCancelBtn, function()
		self._tempTeamData = nil
		self:onSetCancel()
	end)
	
end

function TestBattleCrusade:loadLevelData()
	self._myLvlBox:setString(self._playerInfo.lv)
	self._enemyLvlBox:setString(self._enemyInfo.lv)	
end

function TestBattleCrusade:setHeroData(isMine)
	self._heroLayer:setVisible(true)
	self._fightLayer:setVisible(false)
	self._teamLayer:setVisible(false)
	self._closeBtn:setVisible(false)
	self._isMine = isMine
	
	self._setViewHeroTitle:setString(isMine and "我方英雄" or "敌方英雄")
	
	self._tempHeroId =  isMine and self._playerInfo.hero.id or self._enemyInfo.hero.id	
	self._heroTableView:reloadData()
	local heroName = tab.hero[self._tempHeroId].heroname
	self._heroNameLabel:setString(lang(heroName))
	self._heroStarBox:setString(isMine and self._playerInfo.hero.star or self._enemyInfo.hero.star)
	for i,v in ipairs(self._heroSkillLevelBox) do
		v:setString(isMine and self._playerInfo.hero.slevel[i] or self._enemyInfo.hero.slevel[i])
	end
	self._heroSkillKeYinLabel:setVisible(isMine)
	for i,v in pairs(self._heroEngravingNode) do
		v:setVisible(isMine)
	end
	if isMine then
		self._heroEngravingNode.idBox:setString(self._playerInfo.hero.skillex[1])
		self._heroEngravingNode.slotLevelBox:setString(self._playerInfo.hero.skillex[2])
		self._heroEngravingNode.bookLevelBox:setString(self._playerInfo.hero.skillex[3])
	end
end

function TestBattleCrusade:onHeroSure()
	local star = tonumber(self._heroStarBox:getString())
	local slevel = { }
	for i,v in ipairs(self._heroSkillLevelBox) do
		local oldLevel = self._isMine and self._playerInfo.hero.slevel or self._enemyInfo.hero.slevel
		table.insert(slevel, tonumber(v:getString()) or oldLevel[i])
	end
	if self._isMine then
		self._playerInfo.hero.id = self._tempHeroId
		self._playerInfo.hero.slevel = slevel
		self._playerInfo.hero.star = star
		self._playerInfo.hero.skillex[1] = tonumber(self._heroEngravingNode.idBox:getString()) or self._playerInfo.hero.skillex[1]
		self._playerInfo.hero.skillex[2] = tonumber(self._heroEngravingNode.slotLevelBox:getString()) or self._playerInfo.hero.skillex[2]
		self._playerInfo.hero.skillex[3] = tonumber(self._heroEngravingNode.bookLevelBox:getString()) or self._playerInfo.hero.skillex[3]
	else
		self._enemyInfo.hero.id = self._tempHeroId
		self._enemyInfo.hero.slevel = slevel
		self._enemyInfo.hero.star = star
	end
	self:saveData()
	self:onSetCancel()
end

function TestBattleCrusade:onSetCancel()
	self._heroLayer:setVisible(false)
	self._fightLayer:setVisible(true)
	self._teamLayer:setVisible(false)
	self._closeBtn:setVisible(true)
	self._tempHeroId = nil
end

function TestBattleCrusade:startFight()
	local myBoxLvl = tonumber(self._myLvlBox:getString())
	local enemyBoxLvl = tonumber(self._enemyLvlBox:getString())
	if myBoxLvl~=self._playerInfo.lv or enemyBoxLvl~=self._enemyInfo.lv then
		self._playerInfo.lv = tonumber(self._myLvlBox:getString()) or self._playerInfo.lv
		self._enemyInfo.lv = tonumber(self._enemyLvlBox:getString()) or self._enemyInfo.lv
		self:saveLvlData()
	end
	BattleUtils.battleDemo_Crusade({playerInfo = self._playerInfo, enemyInfo = self._enemyInfo})
end

function TestBattleCrusade:addHeroTableView()
	local heroTableNode = self:getUI("bg.setLayer.heroLayer.tableNode")
    local tableView = cc.TableView:create(cc.size(420, 290))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,4)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    heroTableNode:addChild(tableView)
	
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScrollHero(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForHeroTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndexHero(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInHeroTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycleHero(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -12, 6)
    self._heroTableView = tableView
    self._inHeroTableScrolling = false
end

function TestBattleCrusade:scrollViewDidScrollHero(view)
    self._inHeroTableScrolling = view:isDragging()
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function TestBattleCrusade:cellSizeForHeroTable(table,idx)
    return 102,428
end

function TestBattleCrusade:tableCellAtIndexHero(table, index)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
	cell.itemIds = {}
	local row = index*4
	for i=0,3 do
        local item = cell:getChildByName("cellItem".. i)
		local itemData = self._heroTableData[i+row+1]
        if i+row+1<=#self._heroTableData then
			if not item then
				item = self:createHeroIcon(itemData)
				cell.itemIds[itemData.id] = 1
				cell:addChild(item)
			else
				item = self:createHeroIcon(itemData, item)
			end
			item:setPosition(i*100+55,52)
			item:setName("cellItem".. i)
		else
			if item then
				if self._oldHeroSelectItem and self._oldHeroSelectItem.id == item.id then
					self._oldHeroSelectItem = nil
				end
				item:removeFromParent()
			end
		end
	end
	return cell
end

function TestBattleCrusade:numberOfCellsInHeroTableView(table)
	return math.ceil(#self._heroTableData/4)
end

function TestBattleCrusade:tableCellWillRecycleHero(table, cell)
	for i=0,3 do
		local item = cell:getChildByName("cellItem".. i)
		if item and item:getChildByName("anim") then
			local animItem = item:getChildByName("anim")
			animItem:removeFromParent()
		end
	end
	if self._oldHeroSelectItem ~= nil and cell.itemIds[self._oldHeroSelectItem.id] ~= nil then
		local animItem = self._oldHeroSelectItem:getChildByName("anim")
		if animItem then
			animItem:removeFromParent()
		end
		self._oldHeroSelectItem = nil
	end
end

function TestBattleCrusade:createHeroIcon(data, oldItem)
	local item
	if not oldItem then
		item = ccui.Widget:create()
		item.id = data.id
		item:setAnchorPoint(0,0)
		item:setContentSize(100, 100)
		local icon = ccui.ImageView:create()
		icon:loadTexture(IconUtils.iconPath..data.icon..".jpg", 1)
		icon:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
		icon:setName("icon")
		item:addChild(icon)
	else
		item = oldItem
		item.id = data.id
		local oldAnimItem = item:getChildByName("anim")
		if oldAnimItem and data.id~=self._tempHeroId then
			oldAnimItem:removeFromParent()
		end
		local icon = item:getChildByName("icon")
		icon:loadTexture(IconUtils.iconPath..data.icon..".jpg", 1)
	end
	if self._tempHeroId==item.id and not item:getChildByName("anim") then
		local animItem = ccui.Widget:create()
		animItem:setAnchorPoint(0, 0)
		animItem:setPosition(0, 0)
		animItem:setContentSize(100, 100)
		local mc = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
		if mc then
			animItem:setName("anim")
			mc:setPosition(50, 50)
			mc:setScale(0.9)
			animItem:addChild(mc)
		end
		animItem:setVisible(true)
		item:addChild(animItem, 5)
		self._oldHeroSelectItem = item
	end
	item:setTouchEnabled(true)
	self:registerClickEvent(item, function()
		if not self._inHeroTableScrolling then
            self:touchHeroItemEnd(data,item)
        else
            self._inHeroTableScrolling = false
        end
	end)
    item:setScale(93/item:getContentSize().width)   -- 暂时处理
    item:setVisible(true)
    item:setSwallowTouches(false)
    item:setAnchorPoint(0.5,0.5)
    return item
end

function TestBattleCrusade:touchHeroItemEnd(data, item)
	local heroName = tab.hero[data.id].heroname
	self._heroNameLabel:setString(lang(heroName))
	self._tempHeroId = data.id
	
	if self._oldHeroSelectItem then
		local oldAnim = self._oldHeroSelectItem:getChildByName("anim")
		if oldAnim then
			oldAnim:removeFromParent()
		end
	end
	local animItem = ccui.Widget:create()
	animItem:setAnchorPoint(0,0)
	animItem:setPosition(0, 0)
	animItem:setContentSize(100, 100)
	local mc = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
	if mc then
		animItem:setName("anim")
		mc:setPosition(50, 50)
		mc:setScale(0.9)
		animItem:addChild(mc)
	end
	item:addChild(animItem, 5)
	self._oldHeroSelectItem = item
end
--以上设置英雄

















--以下设置兵团
function TestBattleCrusade:setTeamData(isMine)
	if not self._teamTableData then
		local tabTeam = clone(tab.team)
		self._teamTableData = {}
		for i,v in pairs(tabTeam) do
			if i<1000 then
				table.insert(self._teamTableData, {id = i, icon = v.art1})
			end
		end
		table.sort(self._teamTableData, function(a, b)
			return a.id<b.id
		end)
	end
	
	self._tempTeamData = isMine and clone(self._playerInfo.team) or clone(self._enemyInfo.team)
	
	self._heroLayer:setVisible(false)
	self._fightLayer:setVisible(false)
	self._teamLayer:setVisible(true)
	self._closeBtn:setVisible(false)
	self._teamInfoLayer:setVisible(true)
	self._teamSetLayer:setVisible(false)
	self._isMine = isMine
	
	for i,v in ipairs(self._teamViewTitle) do
		v:setString(isMine and "我方兵团" or "敌方兵团")
	end
	
	for i,v in ipairs(self._myTeamIcon) do
		v:loadTexture("globalImageUI4_addition.png", 1)
	end
	self:loadTeamInfoData()
end

function TestBattleCrusade:loadTeamInfoData()
	for i,v in ipairs(self._tempTeamData) do
		local iconNode = self._isMine and self._myTeamIcon[v.pos] or self._enemyTeamIcon[v.pos]
		local teamIcon = tab.team[v.id].art1
		iconNode:loadTexture(teamIcon..".jpg", 1)
	end
end

function TestBattleCrusade:changeTeamWithPos(pos)
	pos = self._isMine and pos or 8*math.ceil(pos/4)-pos-3
	self._tempPos = pos
	local teamDataInPos
	for i,v in ipairs(self._tempTeamData) do
		if v.pos==pos then
			teamDataInPos = v
			break
		end
	end
	self._tempTeamId = teamDataInPos and teamDataInPos.id
	self:setTeamWithPos(pos, teamDataInPos)
	self._teamTableView:reloadData()
	self._teamInfoLayer:setVisible(false)
	self._teamSetLayer:setVisible(true)
end

function TestBattleCrusade:setTeamWithPos(pos, data)
	if data then
		self._isChange = true
		local teamConfig = tab.team[data.id]
		self._teamNameLabel:setString(lang(teamConfig.name))
		self._teamLevelBox:setString(data.level)
		self._teamStarBox:setString(data.star)
		for i,v in ipairs(self._teamSkillLevelBox) do
			v:setString(data.skill[i])
		end
	else
		self._isChange = false
		self._teamNameLabel:setString("")
		self._teamLevelBox:setString("")
		self._teamStarBox:setString("")
		for i,v in ipairs(self._teamSkillLevelBox) do
			v:setString("")
		end
	end
end

function TestBattleCrusade:onUpTeam()
	--上阵
	if self._isChange then
		
	end
	local count = self._isChange and table.nums(self._tempTeamData) or table.nums(self._tempTeamData)+1
	
	local levelArray = self._isMine and BattleUtils.LEFT_LEVEL or BattleUtils.RIGHT_LEVEL
	local starArray = self._isMine and BattleUtils.LEFT_STAR or BattleUtils.RIGHT_STAR
	local skillArray = self._isMine and BattleUtils.LEFT_SKILL_LEVEL or BattleUtils.RIGHT_SKILL_LEVEL
	if self._tempTeamId then
		local team = {
			id = self._tempTeamId,
			level = tonumber(self._teamLevelBox:getString()) or levelArray[count],
			star = tonumber(self._teamStarBox:getString()) or starArray[count],
			pos = self._tempPos,
			skill = {}
		}
		for i,v in ipairs(self._teamSkillLevelBox) do
			local skillLevel = tonumber(v:getString()) or skillArray[count][i]
			table.insert(team.skill, skillLevel)
		end
		local isNewTeam = true
		for i,v in ipairs(self._tempTeamData) do
			if v.pos==self._tempPos then
				isNewTeam = false
				self._tempTeamData[i] = team
				break
			end
		end
		if isNewTeam then
			table.insert(self._tempTeamData, team)
		end
	end
	
	self._teamSetLayer:setVisible(false)
	self._teamInfoLayer:setVisible(true)
	self._tempPos = nil
	self._tempTeamId = nil
	self:loadTeamInfoData()
end

function TestBattleCrusade:onDownTeam()
	--下阵
	for i,v in ipairs(self._tempTeamData) do
		if v.pos==self._tempPos then
			local iconNode = self._isMine and self._myTeamIcon[v.pos] or self._enemyTeamIcon[v.pos]
			iconNode:loadTexture("globalImageUI4_addition.png", 1)
			table.remove(self._tempTeamData, i)
			break
		end
	end
	self._teamSetLayer:setVisible(false)
	self._teamInfoLayer:setVisible(true)
	self._tempPos = nil
	self._tempTeamId = nil
	self:loadTeamInfoData()
end

function TestBattleCrusade:onTeamSure()
	if self._isMine then
		self._playerInfo.team = self._tempTeamData
		self._playerInfo.teamCount = table.nums(self._tempTeamData)
	else
		self._enemyInfo.team = self._tempTeamData
		self._enemyInfo.teamCount = table.nums(self._tempTeamData)
	end
	self._tempTeamData = nil
	self:saveData()
	self:onSetCancel()
end

function TestBattleCrusade:addTeamTableView()
	local teamTableNode = self:getUI("bg.setLayer.teamLayer.lineupLayer.teamTableNode")
    local tableView = cc.TableView:create(cc.size(420, 290))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,4)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    teamTableNode:addChild(tableView)
	
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScrollTeam(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( table, index ) return self:cellSizeForTeamTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table, index ) return self:tableCellAtIndexTeam(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTeamTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycleTeam(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -12, 6)
    self._teamTableView = tableView
    self._inTeamTableScrolling = false
end

function TestBattleCrusade:scrollViewDidScrollTeam(view)
    self._inTeamTableScrolling = view:isDragging()
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function TestBattleCrusade:cellSizeForTeamTable(table,idx)
    return 102,428
end

function TestBattleCrusade:tableCellAtIndexTeam(table, index)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
	cell.itemIds = {}
	local row = index*4
	for i=0,3 do
        local item = cell:getChildByName("cellItem".. i)
		local itemData = self._teamTableData[i+row+1]
        if i+row+1<=#self._teamTableData then
			if not item then
				item = self:createTeamIcon(itemData)
				cell.itemIds[itemData.id] = 1
				cell:addChild(item)
			else
				item = self:createTeamIcon(itemData, item)
			end
			item:setPosition(i*100+55,52)
			item:setName("cellItem".. i)
		else
			if item then
				if self._oldTeamSelectItem and self._oldTeamSelectItem.id == item.id then
					self._oldTeamSelectItem = nil
				end
				item:removeFromParent()
			end
		end
	end
	return cell
end

function TestBattleCrusade:numberOfCellsInTeamTableView(table)
	return math.ceil(#self._teamTableData/4)
end

function TestBattleCrusade:tableCellWillRecycleTeam(table, cell)
	for i=0,3 do
		local item = cell:getChildByName("cellItem".. i)
		if item and item:getChildByName("anim") then
			local animItem = item:getChildByName("anim")
			animItem:removeFromParent()
		end
	end
	if self._oldTeamSelectItem ~= nil and cell.itemIds[self._oldTeamSelectItem.id] ~= nil then
		local animItem = self._oldTeamSelectItem:getChildByName("anim")
		if animItem then
			animItem:removeFromParent()
		end
		self._oldTeamSelectItem = nil
	end
end

function TestBattleCrusade:createTeamIcon(data, oldItem)
	local item
	if not oldItem then
		item = ccui.Widget:create()
		item.id = data.id
		item:setAnchorPoint(0,0)
		item:setContentSize(100, 100)
		local icon = ccui.ImageView:create()
		icon:loadTexture(IconUtils.iconPath..data.icon..".jpg", 1)
		icon:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
		icon:setName("icon")
		item:addChild(icon)
	else
		item = oldItem
		item.id = data.id
		local oldAnimItem = item:getChildByName("anim")
		if oldAnimItem and data.id~=self._tempTeamId then
			oldAnimItem:removeFromParent()
		end
		local icon = item:getChildByName("icon")
		icon:loadTexture(IconUtils.iconPath..data.icon..".jpg", 1)
	end
	if self._tempTeamId==item.id and not item:getChildByName("anim") then
		local animItem = ccui.Widget:create()
		animItem:setAnchorPoint(0, 0)
		animItem:setPosition(0, 0)
		animItem:setContentSize(100, 100)
		local mc = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
		if mc then
			animItem:setName("anim")
			mc:setPosition(50, 50)
			mc:setScale(0.9)
			animItem:addChild(mc)
		end
		animItem:setVisible(true)
		item:addChild(animItem, 5)
		self._oldTeamSelectItem = item
	end
	item:setTouchEnabled(true)
	self:registerClickEvent(item, function()
		if not self._inTeamTableScrolling then
            self:touchTeamItemEnd(data,item)
        else
            self._inTeamTableScrolling = false
        end
	end)
    item:setScale(93/item:getContentSize().width)   -- 暂时处理
    item:setVisible(true)
    item:setSwallowTouches(false)
    item:setAnchorPoint(0.5,0.5)
    return item
end

function TestBattleCrusade:touchTeamItemEnd(data, item)
	local teamName = tab.team[data.id].name
	self._teamNameLabel:setString(lang(teamName))
	self._tempTeamId = data.id
	
	if self._oldTeamSelectItem then
		local oldAnim = self._oldTeamSelectItem:getChildByName("anim")
		if oldAnim then
			oldAnim:removeFromParent()
		end
	end
	local animItem = ccui.Widget:create()
	animItem:setAnchorPoint(0,0)
	animItem:setPosition(0, 0)
	animItem:setContentSize(100, 100)
	local mc = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
	if mc then
		animItem:setName("anim")
		mc:setPosition(50, 50)
		mc:setScale(0.9)
		animItem:addChild(mc)
	end
	item:addChild(animItem, 5)
	self._oldTeamSelectItem = item
end















local TEMP_SELF_TEAM_COUNT = 1

--保存数据和恢复初始设置
function TestBattleCrusade:saveData(isRecover)
	if isRecover then
		--myHeroDat
		SystemUtils.saveAccountLocalData("TestCrusadeMyLv", 50)
		SystemUtils.saveAccountLocalData("TestCrusadeMyHeroId", BattleUtils.LEFT_HERO_ID)
		SystemUtils.saveAccountLocalData("TestCrusadeMyHeroStar", BattleUtils.LEFT_HERO_STAR)
		if self._playerInfo.hero.slevel then
			for i,v in ipairs(self._playerInfo.hero.slevel) do
				SystemUtils.saveAccountLocalData("TestCrusadeMyHeroSkillLevel"..i, 1)
			end
		end
		SystemUtils.saveAccountLocalData("TestCrusadeMyHeroKeYinId", 514)
		SystemUtils.saveAccountLocalData("TestCrusadeMyHeroKeYinSlotLevel", 1)
		SystemUtils.saveAccountLocalData("TestCrusadeMyHeroKeYinBookLevel", 1)
		
		--myTeamData
		SystemUtils.saveAccountLocalData("TestCrusadeMyTeamCount", TEMP_SELF_TEAM_COUNT)
		local myTeamKey = "TestCrusadeMyTeam"
		for i=1, TEMP_SELF_TEAM_COUNT do
			SystemUtils.saveAccountLocalData(myTeamKey.."Id"..i, BattleUtils.LEFT_ID[i])
			SystemUtils.saveAccountLocalData(myTeamKey.."Pos"..i, BattleUtils.LEFT_FORMATION[i])
			SystemUtils.saveAccountLocalData(myTeamKey.."Level"..i, BattleUtils.LEFT_LEVEL[i])
			SystemUtils.saveAccountLocalData(myTeamKey.."Star"..i, BattleUtils.LEFT_STAR[i])
			
			for k=1,4 do
				SystemUtils.saveAccountLocalData(myTeamKey..i.."Skill"..k, BattleUtils.LEFT_SKILL_LEVEL[i][k])
			end
		end
		
		--enemyInfo
		SystemUtils.saveAccountLocalData("TestCrusadeEnemyLv", 50)
		SystemUtils.saveAccountLocalData("TestCrusadeEnemyHeroId", BattleUtils.RIGHT_HERO_ID)
		SystemUtils.saveAccountLocalData("TestCrusadeEnemyHeroStar", BattleUtils.RIGHT_HERO_STAR)
		if self._enemyInfo.hero.slevel then
			for i,v in ipairs(self._enemyInfo.hero.slevel) do
				SystemUtils.saveAccountLocalData("TestCrusadeEnemyHeroSkillLevel"..i, 1)
			end
		end
		
		--enemyTeamData
		SystemUtils.saveAccountLocalData("TestCrusadeEnemyTeamCount", BattleUtils.RIGHT_TEAM_COUNT)
		local enemyTeamKey = "TestCrusadeEnemyTeam"
		for i=1, BattleUtils.RIGHT_TEAM_COUNT do
			SystemUtils.saveAccountLocalData(enemyTeamKey.."Id"..i, BattleUtils.RIGHT_ID[i])
			SystemUtils.saveAccountLocalData(enemyTeamKey.."Pos"..i, BattleUtils.RIGHT_FORMATION[i])
			SystemUtils.saveAccountLocalData(enemyTeamKey.."Level"..i, BattleUtils.RIGHT_LEVEL[i])
			SystemUtils.saveAccountLocalData(enemyTeamKey.."Star"..i, BattleUtils.RIGHT_STAR[i])
			for k=1,4 do
				SystemUtils.saveAccountLocalData(enemyTeamKey..i.."Skill"..k, BattleUtils.RIGHT_SKILL_LEVEL[i][k])
			end
		end
		
		self._playerInfo, self._enemyInfo = self:loadData()
	else
		local key = self._isMine and "TestCrusadeMyHero" or "TestCrusadeEnemyHero"
		if self._isMine then
			--heroData
			SystemUtils.saveAccountLocalData(key.."Id", self._playerInfo.hero.id)
			SystemUtils.saveAccountLocalData(key.."Star", self._playerInfo.hero.star)
			if self._playerInfo.hero.slevel then
				for i,v in ipairs(self._playerInfo.hero.slevel) do
					SystemUtils.saveAccountLocalData(key.."SkillLevel"..i, v)
				end
			end
			SystemUtils.saveAccountLocalData("TestCrusadeMyHeroKeYinId", self._playerInfo.hero.skillex[1])
			SystemUtils.saveAccountLocalData("TestCrusadeMyHeroKeYinSlotLevel", self._playerInfo.hero.skillex[2])
			SystemUtils.saveAccountLocalData("TestCrusadeMyHeroKeYinBookLevel", self._playerInfo.hero.skillex[3])
			
			--teamData
			SystemUtils.saveAccountLocalData("TestCrusadeMyTeamCount", self._playerInfo.teamCount)
			local myTeamKey = "TestCrusadeMyTeam"
			for i=1, self._playerInfo.teamCount do
				local teamData = self._playerInfo.team[i]
				SystemUtils.saveAccountLocalData(myTeamKey.."Id"..i, teamData.id)
				SystemUtils.saveAccountLocalData(myTeamKey.."Pos"..i, teamData.pos)
				SystemUtils.saveAccountLocalData(myTeamKey.."Level"..i, teamData.level)
				SystemUtils.saveAccountLocalData(myTeamKey.."Star"..i, teamData.star)
				
				for k=1,4 do
					SystemUtils.saveAccountLocalData(myTeamKey..i.."Skill"..k, teamData.skill[k])
				end
			end
			
		else
			--heroData
			SystemUtils.saveAccountLocalData(key.."Id", self._enemyInfo.hero.id)
			SystemUtils.saveAccountLocalData(key.."Star", self._enemyInfo.hero.star)
			if self._enemyInfo.hero.slevel then
				for i,v in ipairs(self._enemyInfo.hero.slevel) do
					SystemUtils.saveAccountLocalData(key.."SkillLevel"..i, v)
				end
			end
			
			--teamData
			SystemUtils.saveAccountLocalData("TestCrusadeEnemyTeamCount", self._enemyInfo.teamCount)
			local enemyTeamKey = "TestCrusadeEnemyTeam"
			for i=1, self._enemyInfo.teamCount do
				local teamData = self._enemyInfo.team[i]
				SystemUtils.saveAccountLocalData(enemyTeamKey.."Id"..i, teamData.id)
				SystemUtils.saveAccountLocalData(enemyTeamKey.."Pos"..i, teamData.pos)
				SystemUtils.saveAccountLocalData(enemyTeamKey.."Level"..i, teamData.level)
				SystemUtils.saveAccountLocalData(enemyTeamKey.."Star"..i, teamData.star)
				
				for k=1,4 do
					SystemUtils.saveAccountLocalData(enemyTeamKey..i.."Skill"..k, teamData.skill[k])
				end
			end
		end
	end
end

function TestBattleCrusade:saveLvlData()
	SystemUtils.saveAccountLocalData("TestCrusadeMyLv", self._playerInfo.lv)
	SystemUtils.saveAccountLocalData("TestCrusadeEnemyLv", self._enemyInfo.lv)
end

function TestBattleCrusade:loadData()
	local playerInfo = {hero = {}, team = {}}
	local enemyInfo = {hero = {}, team = {}}
	
	playerInfo.lv = SystemUtils.loadAccountLocalData("TestCrusadeMyLv") or 50
	--playerHeroData
	playerInfo.hero.id = SystemUtils.loadAccountLocalData("TestCrusadeMyHeroId") or BattleUtils.LEFT_HERO_ID
	playerInfo.hero.star = SystemUtils.loadAccountLocalData("TestCrusadeMyHeroStar") or BattleUtils.LEFT_HERO_STAR
	local slevel = { }
	for i=1,5 do
		table.insert(slevel, SystemUtils.loadAccountLocalData("TestCrusadeMyHeroSkillLevel"..i) or 1 )
	end
	playerInfo.hero.slevel = slevel
	local skillex = {
		SystemUtils.loadAccountLocalData("TestCrusadeMyHeroKeYinId") or 514,
		SystemUtils.loadAccountLocalData("TestCrusadeMyHeroKeYinSlotLevel") or 1, 
		SystemUtils.loadAccountLocalData("TestCrusadeMyHeroKeYinBookLevel") or 1,
	}
	playerInfo.hero.skillex = skillex
	
	--playerTeamData
	playerInfo.teamCount = SystemUtils.loadAccountLocalData("TestCrusadeMyTeamCount") or TEMP_SELF_TEAM_COUNT--count
	local myTeamKey = "TestCrusadeMyTeam"
	for i=1, playerInfo.teamCount do
		local team = {
			id = SystemUtils.loadAccountLocalData(myTeamKey.."Id"..i) or BattleUtils.LEFT_ID[i],
			pos = SystemUtils.loadAccountLocalData(myTeamKey.."Pos"..i) or BattleUtils.LEFT_FORMATION[i],
			level = SystemUtils.loadAccountLocalData(myTeamKey.."Level"..i) or BattleUtils.LEFT_LEVEL[i],
			star = SystemUtils.loadAccountLocalData(myTeamKey.."Star"..i) or BattleUtils.LEFT_STAR[i],
		}
		team.skill = {}
		for k=1,4 do
			table.insert(team.skill, SystemUtils.loadAccountLocalData(myTeamKey..i.."Skill"..k) or BattleUtils.LEFT_SKILL_LEVEL[i][k])
		end
		table.insert(playerInfo.team, team)
	end
	
	
	
	
	
	enemyInfo.lv = SystemUtils.loadAccountLocalData("TestCrusadeEnemyLv") or 50
	--enemyHeroData
	enemyInfo.hero.id = SystemUtils.loadAccountLocalData("TestCrusadeEnemyHeroId") or BattleUtils.RIGHT_HERO_ID
	enemyInfo.hero.star = SystemUtils.loadAccountLocalData("TestCrusadeEnemyHeroStar") or BattleUtils.RIGHT_HERO_STAR
	local enemySlevel = { }
	for i=1,5 do
		table.insert(enemySlevel, SystemUtils.loadAccountLocalData("TestCrusadeEnemyHeroSkillLevel"..i) or 1 )
	end
	enemyInfo.hero.slevel = enemySlevel
	
	--enemyTeamData
	enemyInfo.teamCount = SystemUtils.loadAccountLocalData("TestCrusadeEnemyTeamCount") or BattleUtils.RIGHT_TEAM_COUNT--count
	local enemyTeamKey = "TestCrusadeEnemyTeam"
	for i=1, enemyInfo.teamCount do
		local team = {
			id = SystemUtils.loadAccountLocalData(enemyTeamKey.."Id"..i) or BattleUtils.RIGHT_ID[i],
			pos = SystemUtils.loadAccountLocalData(enemyTeamKey.."Pos"..i) or BattleUtils.RIGHT_FORMATION[i],
			level = SystemUtils.loadAccountLocalData(enemyTeamKey.."Level"..i) or BattleUtils.RIGHT_LEVEL[i],
			star = SystemUtils.loadAccountLocalData(enemyTeamKey.."Star"..i) or BattleUtils.RIGHT_STAR[i],
		}
		team.skill = {}
		for k=1,4 do
			table.insert(team.skill, SystemUtils.loadAccountLocalData(enemyTeamKey..i.."Skill"..k) or BattleUtils.RIGHT_SKILL_LEVEL[i][k])
		end
		table.insert(enemyInfo.team, team)
	end
	
	return playerInfo, enemyInfo
end

return TestBattleCrusade