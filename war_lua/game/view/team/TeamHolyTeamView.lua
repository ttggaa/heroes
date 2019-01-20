--[[
    Filename:    TeamHolyTeamView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-20 17:21:57
    Description: File description
--]]

local qualityMC = TeamUtils.qualityMC

-- 选择宝石
local TeamHolyTeamView = class("TeamHolyTeamView", BasePopView)

function TeamHolyTeamView:ctor(param)
	TeamHolyTeamView.super.ctor(self)
	self._callback = param and param.callback
	self._curSelectTeamID = param.curSelectTeamID
	self._viewMgr:disableScreenWidthBar()
end

function TeamHolyTeamView:onInit()
	self._teamModel = self._modelMgr:getModel("TeamModel")
	self._tableData = self._teamModel:getData()

	self._left = self:getUI('bg.btn_leftArrow')
	self._right = self:getUI('bg.btn_rightArrow')

	local btn_back = self:getUI('btn_back')
	self:registerClickEvent(btn_back, function()
		if self._isShowHint then
			self._isShowHint = false
			self._viewMgr:closeHintView()
		else
			if self._callback then
				self._callback(self._curTeamData)
			end
	        if self.close then
	        	self:close()
	        end
	    end
    end)
    local btn_back2 = self:getUI('btn_back2')
    btn_back2:setScale(2)
	self:registerClickEvent(btn_back2, function()
		if self._isShowHint then
			self._isShowHint = false
			self._viewMgr:closeHintView()
		else
			if self._callback then
				self._callback(self._curTeamData)
			end
	        if self.close then
	        	self:close()
	        end
	    end
    end)

    self._curSelectIdx = 1
	for k, v in pairs(self._tableData) do
		if self._curSelectTeamID == v.teamId then
			self._curSelectIdx = k
			break
		end
	end

    self:updateHolyView()
	
	self:addTableView()
end

-- function TeamHolyTeamView:reloadData()
-- 	self._tableData = self._teamModel:getData()
-- 	self._tableView:reloadData()
-- 	self._nothing:setVisible(table.nums(self._tableData) == 0)
-- end

--[[
用tableview实现
--]]
function TeamHolyTeamView:addTableView()
	local tableViewBg = self:getUI("bg.tableViewBg")
	local height = tableViewBg:getContentSize().height
	self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, height))
	self._tableView:setDelegate()
	self._tableView:setDirection(0)
	self._tableView:setHorizontalFillOrder(cc.TABLEVIEW_FILL_LEFTRIGHT)
	self._tableView:setPosition(0, 0)
	self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
	self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
	self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function() return self:scrollViewDidScroll() end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
	self._tableView:setBounceable(true)
	self._tableView:reloadData()
	if self._tableView.setDragSlideable ~= nil then 
		self._tableView:setDragSlideable(true)
	end
	tableViewBg:addChild(self._tableView)

	if #self._tableData > 6 then
		local maxOffset = (#self._tableData - 6) * 127
		local offsetX = (self._curSelectIdx - 1) * 127
		if offsetX > maxOffset then
			offsetX = maxOffset
		end
		self._tableView:setContentOffset(cc.p(-offsetX, 0))
	end
end

function TeamHolyTeamView:scrollViewDidScroll()
	if #self._tableData <= 6 then
		self._right:setVisible(false)
		self._left:setVisible(false)
		return
	end
    local view = self._tableView
    local offsetX = math.abs(view:getContentOffset().x)
    local maxOffset = (#self._tableData - 7) * 127
    if offsetX <= 127 then
    	self._right:setVisible(true)
    	self._left:setVisible(false)
    elseif offsetX >= maxOffset then
    	self._right:setVisible(false)
    	self._left:setVisible(true)
    else
    	self._left:setVisible(true)
    	self._right:setVisible(true)
    end
end

-- 返回cell的数量
function TeamHolyTeamView:numberOfCellsInTableView(inView)
	return table.nums(self._tableData)
end

-- cell的尺寸大小
function TeamHolyTeamView:cellSizeForTable(inView,idx)
	local tableViewBg = self:getUI("bg.tableViewBg")
	return tableViewBg:getContentSize().height, 132
end

-- 创建在某个位置的cell
function TeamHolyTeamView:tableCellAtIndex(inView, idx)
	local cell = inView:dequeueCell()
	local indexId = idx + 1

	local teamData = self._tableData[indexId]
	local param = {systeam = tab:Team(teamData.teamId), teamD = self._tableData[indexId]}
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
	local listCell = cell:getChildByName("listCell")
	
	local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(self._tableData[indexId])
	if listCell then
		self:updateTeamCard(listCell, param, idx)
		local selectMc = cell:getChildByName("selectMc")
		selectMc:setVisible(self._curSelectIdx==idx+1)
	else
		local listCell = self:createTeamListCard(param, idx)
		listCell:setName("listCell")
		listCell:setVisible(true)
		listCell:setAnchorPoint(cc.p(0.5,0.5))
		listCell:setPosition(cc.p(listCell:getContentSize().width/2+8,listCell:getContentSize().height/2 + 25))
		cell:addChild(listCell, 1)
		
		local selectMc = cell:getChildByName("selectMc")
		if not selectMc then
			selectMc = mcMgr:createViewMC("kapaixuanzhong_shenghuixuanzhong", true, false)
			local pos = cc.p(listCell:getPosition())
			selectMc:setPosition(pos.x, pos.y)
			selectMc:setName("selectMc")
			selectMc:setScale(1.05)
			cell:addChild(selectMc)
		end
		selectMc:setVisible(self._curSelectIdx==idx+1)
	end

	return cell
end

function TeamHolyTeamView:updateHolyView(  )

	self._curTeamData = self._tableData[self._curSelectIdx]
	local teamId = self._curTeamData.teamId

	local systeam = tab:Team(teamId)
    local animBg = self:getUI("bg.holyPanel.animBg")
    local backBgNode = animBg:getChildByName("backBgNode")
    local pos = systeam.xiaoren

    local teamName, art1, art2, steam = TeamUtils:getTeamAwakingTab(self._curTeamData, self._curTeamData.teamId)
    if backBgNode then
        backBgNode:setTexture("asset/uiother/steam/" .. steam .. ".png")
    else
        backBgNode = cc.Sprite:create("asset/uiother/steam/" .. steam .. ".png")
        backBgNode:setAnchorPoint(cc.p(0.5, 0))
        backBgNode:setName("backBgNode")
        animBg:addChild(backBgNode)
    end
	if systeam.scaleHoly then
		backBgNode:setScale(systeam.scaleHoly)
	else
		backBgNode:setScale(1)
	end
    backBgNode:setPosition(cc.p(animBg:getContentSize().width/2+pos[1], pos[2]-10))

    local rune = self._curTeamData.rune or {}
    local holyData = self._teamModel:getHolyData()
    for i = 1, 6 do
        local stoneBg = self:getUI("bg.holyPanel.stoneImg" .. i)
        local stoneIcon = self:getUI("bg.holyPanel.stoneImg" .. i .. ".holyBg")
        local stageLabBg = self:getUI("bg.holyPanel.stoneImg" .. i .. ".stageLabBg")
        local stageLab = self:getUI("bg.holyPanel.stoneImg" .. i .. ".stageLabBg.stageLab")

        local qualityAnim = stoneBg and stoneBg.qualityAnim
        local indexId = tostring(i)
        if rune and rune[indexId] and rune[indexId] ~= 0 then
            local key = rune[indexId]
            local holyId = holyData[key].id
            local make = holyData[key].make
            local quality = holyData[key].quality
            local level = holyData[key].lv
            local suitTab = tab.runeClient[make]
--			local runeTab = tab.rune[holyId]
            if stageLab then
            	stageLabBg:setVisible(true)
                stageLab:setString("+" .. level - 1)
            end

            if not tolua.isnull(qualityAnim) then
                qualityAnim:removeFromParent()
                qualityAnim = nil
            end
            local quslityStr = qualityMC[quality]
            if quslityStr then
                qualityAnim = mcMgr:createViewMC(quslityStr, true, false)
                qualityAnim:setName("qualityAnim")
                if i>2 then
					qualityAnim:setScale(1)
				else
					qualityAnim:setScale(1.4)
				end
                qualityAnim:setPosition(cc.p(stoneBg:getPosition()))
                stoneBg:getParent():addChild(qualityAnim)
                stoneBg.qualityAnim = qualityAnim
            end

            if stoneIcon then
                stoneIcon:loadTexture(suitTab.icon .. ".png", 1)
                if i > 2 then
					stoneIcon:setScale(0.7)
				else
					stoneIcon:setScale(1)
				end
            end
        else
            if stoneIcon then
                stoneIcon:loadTexture("TeamHolyUI_img17.png", 1)
            end
            if not tolua.isnull(qualityAnim) then
                qualityAnim:removeFromParent()
                qualityAnim = nil
            end
            if stageLab then
            	stageLabBg:setVisible(false)
                stageLab:setString("")
            end
        end

        self:registerClickEvent(stoneBg, function()
        	self._selectStone = i
        	self:showHolyInfo()
        	local rune = self._curTeamData.rune or {}
            local key = rune[tostring(i)]
            if rune and key and key ~= 0 then
            	self._isShowHint = true
	            local holyId = holyData[key].id
	            local tabData = tab.rune[holyId]
	            local param = {teamId = teamId, selectStone = i, key = key, holyData = tabData, hintType = 4}
				self._viewMgr:closeHintView()
				self._viewMgr:showHintView("team.TeamHolyTipView", param)
			else
				self._isShowHint = false
				self._viewMgr:closeHintView()
			end
        end)
    end
end

function TeamHolyTeamView:showHolyInfo(  )
	for i = 1, 6 do
		local stoneBg = self:getUI("bg.holyPanel.stoneImg" .. i)
		local xuanzhong = stoneBg.xuanzhong
	    if not xuanzhong then
	        xuanzhong = mcMgr:createViewMC("shenghuixuanzhong_shenghuitubiao", true, false)
	        xuanzhong:setName("xuanzhong")
	        if i > 2 then
				xuanzhong:setScale(1.05)
				xuanzhong:setPosition(stoneBg:getContentSize().width/2, stoneBg:getContentSize().height/2+4)
			else
				xuanzhong:setScale(1.53)
				xuanzhong:setPosition(stoneBg:getContentSize().width/2+1, stoneBg:getContentSize().height/2+5)
			end
	        stoneBg:addChild(xuanzhong,50)
	        stoneBg.xuanzhong = xuanzhong
	    end
	    if self._selectStone == i then
	        xuanzhong:setVisible(true)
	    else
	        xuanzhong:setVisible(false)
	    end
	end
end


--新需求
local CARD_WIDTH = 122
local CARD_HEIGHT = 187
local CARD_COLOR_FRAME = {
    [1] = {brightness = 0, contrast = 0, color = cc.c3b(255, 255, 255)},
    [2] = {brightness = 12, contrast = 16, color = cc.c3b(66, 214, 8)},
    [3] = {brightness = 2, contrast = -22, color = cc.c3b(25, 120, 255)},
    [4] = {brightness = 16, contrast = 38, color = cc.c3b(217, 77, 242)},
    [5] = {brightness = 12, contrast = 30, color = cc.c3b(242, 161, 20)},
    [6] = {brightness = 12, contrast = 45, color = cc.c3b(174, 51, 43)},
}
function TeamHolyTeamView:createTeamListCard(inTable, idx)
	local cardbg = ccui.Layout:create()
	cardbg:setAnchorPoint(0.5, 0.5)
	cardbg:setBackGroundColorOpacity(0)
	cardbg:setBackGroundColorType(1)
	cardbg:setBackGroundColor(cc.c3b(255,255,255))
	cardbg:setContentSize(CARD_WIDTH, CARD_HEIGHT)
	cardbg:setName("cardbg")

	local centerx, centery = CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5

	-- 背景
	local mask = cc.Sprite:create("asset/uiother/cteam/cardt_framebg1-HD.png")
	mask:setPosition(centerx, centery+2)
	mask:setScale(0.75)
	mask:setName("mask")

	-- 裁剪框
	local cardClip = cc.ClippingNode:create()
	cardClip:setInverted(false)
	cardClip:setStencil(mask)
	cardClip:setAlphaThreshold(0.2)
	cardClip:setName("cardClip")
	cardClip:setAnchorPoint(cc.p(0.5,0.5))
	-- cardClip:setPosition(centerx*0.5, centery*0.5)
	cardbg:addChild(cardClip)

	local roleBg = cc.Sprite:create("asset/uiother/cteam/cardt_framebg1-HD.png")
	roleBg:setPosition(centerx, centery+2)
	roleBg:setName("roleBg")
	roleBg:setScale(0.75)
	cardbg:addChild(roleBg, -1)

	local roleSp = cc.Sprite:create()
	roleSp:setAnchorPoint(1, 0)
	roleSp:setPosition(CARD_WIDTH, 2) 
	roleSp:setName("roleSp")
	roleSp:setScale(0.75)
	cardClip:addChild(roleSp)     -- 1-2

	-- 遮黑框
	local cardClipBg = ccui.Layout:create()
	cardClipBg:setBackGroundColorOpacity(175)
	cardClipBg:setBackGroundColorType(1)
	cardClipBg:setBackGroundColor(cc.c3b(0,0,0))
	cardClipBg:setContentSize(CARD_WIDTH-2, CARD_HEIGHT-10)
	cardClipBg:setPosition(0, 10)
	cardClipBg:setName("cardClipBg")
	cardClip:addChild(cardClipBg, 20)     -- 1

	-- 前景
	local fg = cc.Sprite:create()
	fg:setPosition(centerx, centery - 25)
	fg:setName("fg")
	fg:setScale(0.75)
	cardClip:addChild(fg)          -- 1-3

	local classlabel = cc.Sprite:create()
	classlabel:setPosition(CARD_WIDTH-19, CARD_HEIGHT-19)
	classlabel:setScale(0.75*0.7)
	classlabel:setName("classlabel")
	cardClip:addChild(classlabel, 3) -- 3

	local name = cc.Label:createWithTTF("123", UIUtils.ttfName, 14)
	name:setAnchorPoint(1, 0.5)
    name:setPosition(CARD_WIDTH - 8, centery-42)
	name:setName("name")
	cardClip:addChild(name) -- 4

	local level = cc.Label:createWithTTF("123", UIUtils.ttfName, 14)
    level:setAnchorPoint(0, 0.5)
    level:setPosition(8, centery-42)
    level:setName("level")
    cardClip:addChild(level) -- 4

	-- 星星
	local teamstar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_cardteamStar1.png")
	teamstar:setAnchorPoint(1, 0)
	teamstar:setPosition(CARD_WIDTH-5, centery-32)
	teamstar:setName("teamstar")
	teamstar:setScale(0.53)
	cardClip:addChild(teamstar, 3) -- 3

	-- 框
	local zhaozi = cc.Sprite:create("asset/uiother/cteam/cardt_frame1.png")
	zhaozi:setPosition(centerx, centery)
	zhaozi:setName("zhaozi")
	zhaozi:setScale(0.75)
	cardbg:addChild(zhaozi) -- 2

	-- 品阶
	local ctquality = cc.Sprite:create()
	ctquality:setAnchorPoint(0, 1)
	ctquality:setPosition(0, CARD_HEIGHT)
	ctquality:setName("ctquality")
	ctquality:setScale(0.75)
	cardbg:addChild(ctquality, 20) -- 3

	--上阵
	local addTeam = cc.Sprite:createWithSpriteFrameName("globalIamgeUI6_addTeam.png")
    addTeam:setAnchorPoint(0, 1)
    addTeam:setPosition(0, CARD_HEIGHT - 45)
    addTeam:setName("addTeam")
    addTeam:setScale(0.9)
    cardbg:addChild(addTeam, 20) -- 3

	local qualityLab = cc.Label:createWithTTF("123", UIUtils.ttfName, 22)
	qualityLab:setPosition(22, 22)
	qualityLab:setName("qualityLab")
	ctquality:addChild(qualityLab) -- 4

	--套装

	local suitTips = cc.Label:createWithTTF("未激活", UIUtils.ttfName, 16)
    suitTips:setPosition(centerx, centery - 72)
	suitTips:setName("suitTips")
	cardClip:addChild(suitTips) -- 4
	suitTips:setVisible(false)

	self:updateTeamCard(cardbg, inTable, idx)
	return cardbg
end

function TeamHolyTeamView:updateTeamCard(inView, inTable, idx)
	local teamD = inTable.teamD
	if not teamD then
		return
	end
	local systeam = inTable.systeam
	local teamD = inTable.teamD
	if not systeam then
		return
	end

	local centerx, centery = CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5
	local teamId = teamD.teamId
	local backQuality = self._teamModel:getTeamQualityByStage(teamD["stage"])
	-- 觉醒数据
	local isAwaking, aLvl = TeamUtils:getTeamAwaking(teamD)
	local teamName, art1, art2, art3, art4, cteam = TeamUtils:getTeamAwakingTab(teamD)

	local cardClip = inView:getChildByFullName("cardClip")
	cardClip:setSaturation(0)

	local cardClipBg = cardClip:getChildByFullName("cardClipBg")
	if cardClipBg then
		cardClipBg:setVisible(false)
	end

	local roleSp = cardClip:getChildByFullName("roleSp")
	if roleSp then
		-- local fileName = "asset/uiother/cteam/ct_" .. teamId .. ".jpg"
		-- if isAwaking == true then
		-- 	fileName = "asset/uiother/cteam/cta_" .. teamId .. ".jpg"
		-- end
		UIUtils:asyncLoadTexture(roleSp, cteam)
	end

	local fg = cardClip:getChildByFullName("fg")
	if fg then
		UIUtils:asyncLoadTexture(fg, "asset/uiother/cteam/cardt_farebg.png")
	end

	local classlabel = cardClip:getChildByFullName("classlabel")
	if classlabel then
		local tclasslabel = TeamUtils:getClassIconNameByTeamD(teamD, "classlabel", systeam)
		classlabel:setSpriteFrame(tclasslabel .. ".png")
	end

	local ctquality = inView:getChildByFullName("ctquality")
	local qualityLab = ctquality:getChildByFullName("qualityLab")
	if ctquality and qualityLab then
		if backQuality[2] ~= 0 then
			ctquality:setSpriteFrame("globalImageUI_ctquality" .. backQuality[1] .. ".png")
			ctquality:setVisible(true)
			qualityLab:setString("+" .. backQuality[2])
		else
			ctquality:setVisible(false)
		end
	end

	-- 名字
	local name = cardClip:getChildByFullName("name")
	if name then
		local str = lang(teamName)
		name:setString(str)
		name:setColor(UIUtils.colorTable["ccColorQuality" .. backQuality[1]])
		name:enableOutline(UIUtils.colorTable["ccColorQualityOutLine" .. backQuality[1]], 1)
	end

	local level = cardClip:getChildByFullName("level")
    if level then
        level:setString("Lv." .. (teamD.level or 1))
    end

	local teamstar = cardClip:getChildByFullName("teamstar")
	if teamstar then
		teamstar:setSpriteFrame("globalImageUI6_cardteamStar" .. teamD.star .. ".png")
	end
	
	-- 外框
	local zhaozi = inView:getChildByFullName("zhaozi")
	if zhaozi then
		local colorframe = CARD_COLOR_FRAME[backQuality[1]]
		zhaozi:setBrightness(colorframe.brightness)
		zhaozi:setContrast(colorframe.contrast)
		zhaozi:setColor(colorframe.color)
		local fileName = "asset/uiother/cteam/cardt_frame1.png"
		if isAwaking == true then
			fileName = "asset/uiother/cteam/cardt_awakingframe1.png"
		end
		UIUtils:asyncLoadTexture(zhaozi, fileName)
		-- UIUtils:asyncLoadTexture(zhaozi, "asset/uiother/cteam/cardt_frame" .. backQuality[1] .. ".png")
	end

	local addTeam = inView:getChildByFullName("addTeam")
    if addTeam then
        if teamD.isInFormation == true then
            addTeam:setVisible(true)
        else
            addTeam:setVisible(false)
        end
    end

    --套装
    for i = 1, 3 do
		local itemNode = cardClip:getChildByFullName('suitNode' .. i)
		if itemNode then
			itemNode:removeFromParent()
		end
	end

    local suitTips = cardClip:getChildByFullName('suitTips')
    local team = self._teamModel:getTeamAndIndexById(teamId)
	local suitData = self._teamModel:getTeamSuitById(team)

	local count = 0
	local posX = 26
	for k,v in pairs(suitData) do
		if table.nums(v) > 0 then
			local suitTab = tab:RuneClient(k)
			for _, data in ipairs(v) do
				count = count + 1
				local stoneTab = tab:Rune(data.stoneId)
				local quality = stoneTab.quality
				local amountStr = data.suitNum.. "/" .. data.suitNum
				local param = {quality = quality, noAmountStr = true, amountStr = amountStr, tabConfig = suitTab}
				local itemNode = IconUtils:createTeamHolySuitIcon(param)
				itemNode:setName("suitNode" .. count)
				itemNode:setScale(0.35)
				itemNode:setPosition(cc.p(posX, 24))
				itemNode:getChildByFullName('nameLab'):setVisible(false)
				posX = posX + 35
				cardClip:addChild(itemNode)
			end
		end
	end
	suitTips:setVisible(count == 0)
	
	local clickFlag = false
	local downX, downY
	local posX, posY
	registerTouchEvent(
		inView,
		function(_, x, y)
			downX = x
			clickFlag = false
--			inView:setScale(0.95)
		end, 
		function(_, x, y)
			if downX and math.abs(downX - x) > 5 then
				clickFlag = true
			end
		end, 
		function(_, x, y)
--			inView:setScale(1)
			if clickFlag == false then
				self._selectStone = nil
				if self._curSelectIdx then
					local oldInView = self._tableView:cellAtIndex(self._curSelectIdx - 1)
					if oldInView then
						oldInView:getChildByFullName("selectMc"):setVisible(false)
					end
				end
				self:showHolyInfo()
				self._curSelectIdx = idx + 1
				self:updateHolyView()
				inView:getParent():getChildByFullName("selectMc"):setVisible(true)
			else
				if self._curTeamData.teamId == teamD.teamId then
					inView:getParent():getChildByFullName("selectMc"):setVisible(true)
				end
			end
		end,
		function(_, x, y)
			inView:setScale(1)
			if self._curTeamData.teamId == teamD.teamId then
				inView:getParent():getChildByFullName("selectMc"):setVisible(true)
			end
		end)
	inView:setSwallowTouches(false)
end

function TeamHolyTeamView:setNavigation()
	-- self._viewMgr:showNavigation("global.UserInfoView",{types = {"RuneCoin","Gold","Gem"},titleTxt = "圣徽"})
end

function TeamHolyTeamView:onDestroy( )
    self._viewMgr:enableScreenWidthBar()
    TeamHolyTeamView.super.onDestroy(self)
end

return TeamHolyTeamView