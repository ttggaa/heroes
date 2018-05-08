--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-05-23 20:04:29
--
local GlobalScoreStatisticsView = class("GlobalScoreStatisticsView",BasePopView)
function GlobalScoreStatisticsView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalScoreStatisticsView:onInit()
	self:registerClickEventByName("bg.btn_close",function( )
		self:close()
	end)
	self._allScore = self:getUI("bg.allScore")
	self._allScore:setColor(cc.c3b(249, 250, 60))
	self._allScore:enable2Color(1, cc.c4b(239, 156, 50, 255))
	self._allScore:enableOutline(cc.c4b(0,0,0,255),1)

    self._title = self:getUI("bg.titleBg.title")
    self._title:setColor(UIUtils.colorTable.ccUIBaseColor1)
    self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    
	self._tableData = {}
	self._tableBg = self:getUI("bg.tableBg")
	self:addTableView()

    self:listenReflash("UserModel", self.reflashUI)
    self:listenReflash("TreasureModel", self.reflashUI)
    self:listenReflash("TeamModel", self.reflashUI)
    self:listenReflash("PokedexModel", self.reflashUI)

end

function GlobalScoreStatisticsView:addTableView( )
    local tableView = cc.TableView:create(cc.size(540, 400))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(5,5))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._tableBg:addChild(tableView)
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
    tableView:reloadData()
    self._tableView = tableView
end

function GlobalScoreStatisticsView:scrollViewDidScroll(view)
    print("scrollViewDidScroll")
end

function GlobalScoreStatisticsView:scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

function GlobalScoreStatisticsView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function GlobalScoreStatisticsView:cellSizeForTable(table,idx) 
    return 125,550
end

function GlobalScoreStatisticsView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    local item = self:createItem(idx+1)
    item:setPosition(3, 0)
    cell:addChild(item)
    return cell
end

function GlobalScoreStatisticsView:numberOfCellsInTableView(table)
   return #self._tableData
end

function GlobalScoreStatisticsView:createItem( idx )
	local data = self._tableData[idx]
	if not data then return end
	local bgNode = ccui.Widget:create()
    bgNode:setContentSize(cc.size(540,120))
    bgNode:setAnchorPoint(cc.p(0,0))
    -- bgNode:addChild(rtx,99)

	local bg = ccui.ImageView:create()
    bg:loadTexture("globalPanelUI7_cellBg3.png",1)
    bg:setScale9Enabled(true)
    -- bg:ignoreContentAdaptWithSize(false)
    bg:setContentSize(cc.size(530,120))
    bg:setCapInsets(cc.rect(25,25,1,1))
    bg:setAnchorPoint(cc.p(0,0))
    bg:setPosition(0,0)
    bgNode:addChild(bg,-1)

    local x,y = 0,bgNode:getContentSize().height/2
    local img = ccui.ImageView:create()
    img:loadTexture(data.img or "globalPanelUI_bugcellbg.png",1) --
    bgNode:addChild(img)

    x = img:getContentSize().width/2+20
    img:setPosition(x,y)

    x = x+img:getContentSize().width/2+10

    local title = ccui.Text:create()
    title:setFontSize(22)
    title:setFontName(UIUtils.ttfName)
    title:setColor(UIUtils.colorTable.ccUIBaseColor1)
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    title:setAnchorPoint(cc.p(0,0.5))
    title:setPosition(x,y+15)
    bgNode:addChild(title)
    title:setString(data.title or "兵团")

    local score = ccui.Text:create()
    score:setFontSize(22)
    score:setFontName(UIUtils.ttfName)
    score:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- score:enableOutline(cc.c4b(0,0,0,255),2)
    score:setAnchorPoint(cc.p(0,0.5))
    score:setPosition(x,y-15)
    bgNode:addChild(score)
    score:setString("当前战斗力:" .. data.score or "当前战斗力:32000")

    local btn = ccui.Button:create("globalButtonUI13_1_1.png","globalButtonUI13_1_1.png","",1)
    bgNode:addChild(btn)
    x = bgNode:getContentSize().width-btn:getContentSize().width/2-20
    btn:setPosition(x,y)
    btn:setTitleFontSize(28)

    btn:setTitleFontName(UIUtils.ttfName)
    btn:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 255), 2)
	btn:setTitleColor(cc.c4b(255, 255, 255, 255))

    btn:setTitleText("加强")
    self:registerClickEvent(btn,function( )
    	if data.goto then
    		if data.openTag then --and sysName ~= "" then
		        local isOpen,toBeOpen = SystemUtils["enable".. data.openTag]()
		        if not isOpen then
		    		-- local systemOpenTip = tab.systemOpen[data.openTag][3]
		      --       if not systemOpenTip then
		                self._viewMgr:showTip(tab.systemOpen[data.openTag][1] .. "级开启")
		            -- else
		            --     self._viewMgr:showTip(lang(systemOpenTip))
		            -- end
		            return
		        end
		    end
    		self._viewMgr:showView(data.goto)
    	end
    	-- if type(data.gotoFunc) == "function" then
    	-- 	data.gotoFunc()
    	-- end
    end)
    return bgNode
end

-- 接收自定义消息
function GlobalScoreStatisticsView:reflashUI(data)
	local allScore = self:updateFightScores()
	self._allScore:setString("总战斗力:" .. (allScore or 0))
	self._tableView:reloadData()
end

function GlobalScoreStatisticsView:updateFightScores( )
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local heroData = self._modelMgr:getModel("HeroModel"):getData()
    local defaultFormation = self._modelMgr:getModel("FormationModel"):getDefaultFormationData()
    local heroId = defaultFormation.heroId 
    local heroScore = heroData[tostring(heroId)].score or 0
    -- 用户pve总战斗力，宝物战斗力，图鉴战斗力，学院战斗力
    local userScore,treasureScore,pScore,mScore = self:updateFightNum()
	local scores = {
		{title = "兵团",score = userScore-heroScore-treasureScore-pScore-mScore,img = "ta_putongfuben.png",goto = "team.TeamListView",openTag = "Team"},
		{title = "英雄",score = heroScore,img = "gn_yingxiong.png",goto = "hero.HeroView",openTag = "Hero"},
		{title = "宝物",score = treasureScore,img = "gn_tujian.png",goto = "treasure.TreasureView",openTag = "Treasure"},
		{title = "图鉴",score = pScore,img = "ta_fuwenqianghua.png",goto = "pokedex.PokedexView",openTag = "Pokedex"},
        {title = "学院",score = mScore,img = "ta_fuwenqianghua.png",goto = "talent.TalentView",openTag = "Talent"},
    }
	self._tableData = scores
	return userScore
end

function GlobalScoreStatisticsView:updateFightNum( )
    local formationModel = self._modelMgr:getModel("FormationModel")
    local data = formationModel:getFormationData()[formationModel.kFormationTypeCommon]
    if not data  then
        return 0
    end
    local fightCapacity = 0
    local pScoreCapcity = 0
    local teamModel = self._modelMgr:getModel("TeamModel")
    table.walk(data, function(v, k)
        if 0 == v then return end
        if string.find(tostring(k), "team") and not string.find(tostring(k), "g") then
            local teamData = teamModel:getTeamAndIndexById(v)
            fightCapacity = fightCapacity + teamData.score
            pScoreCapcity = pScoreCapcity + teamData.pScore
        end
    end)
    local heroData = self._modelMgr:getModel("HeroModel"):getData()[tostring(data.heroId)]
    local treasureCapacity = self._modelMgr:getModel("TreasureModel"):getTreasureScore()
    fightCapacity = fightCapacity + heroData.score+treasureCapacity
    local allScore = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeCommon)
    local talentScore = self._modelMgr:getModel("TalentModel"):getBattleNum()
    return allScore,treasureCapacity,pScoreCapcity,talentScore
end

return GlobalScoreStatisticsView