--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-08-15 23:13:55
--
local LeagueStageView = class("LeagueStageView",BasePopView)
function LeagueStageView:ctor()
    self.super.ctor(self)

end

function LeagueStageView:reChangeElemet(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    local name = element:getName()
    if desc == "Label" then
        element:setFontName(UIUtils.ttfName)
		element:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    	if name == "name" then
    		element:setColor(cc.c3b(250, 242, 192))
    		element:enable2Color(1,cc.c4b(255, 195, 17, 255))
    		-- element:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    		element:setFontName(UIUtils.ttfName)
    	elseif (string.find(name,"num") and string.len(name) > 3) then
    	elseif name == "title" then
    		element:setFontName(UIUtils.ttfName)
    	else
	        element:disableEffect()
    	end
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:reChangeElemet(element:getChildren()[i])
    end
end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueStageView:onInit()
	self:reChangeElemet()
	self:registerClickEventByName("bg.close", function ()
        self:close(true)
        if self._callback then
            self._callback()
        end
        UIUtils:reloadLuaFile("league.LeagueStageView")
        -- self._viewMgr:popView()
    end)

    self._tableBg = self:getUI("bg.tableBg")
    self._stageCell = self:getUI("bg.stage")
    self._stageCell:setVisible(false)

    self._close = self:getUI("bg.close")
    self._leftArrow = self:getUI("bg.leftArrow")
	self._rightArrow = self:getUI("bg.rightArrow")

    self._tableData = clone(tab.leagueRank)
	
	self._tableData[1].num = 1000 .. "+"
	for i=2,9 do
		local leagueRank = tab:LeagueRank(i-1)
		self._tableData[i].num = leagueRank.gradeup .. "+"
	end

	self:addTableView()
	self:fitWinSize()
    -- 定位
    local curZone = self._modelMgr:getModel("LeagueModel"):getLeague().currentZone
    local cell = self._tableView:cellAtIndex(math.min(math.max(curZone-1,0),4))
    if cell then
        local posX = cell:getPositionX()
        self._tableView:setContentOffsetInDuration(cc.p(-posX,0),0.01)
    end
end

-- 接收自定义消息
function LeagueStageView:reflashUI(data)
	local leagueData = self._modelMgr:getModel("LeagueModel"):getLeague()
	-- 静态表内容
end

function LeagueStageView:addTableView( )
    local tableView = cc.TableView:create(cc.size(850, 460))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(-0,0))
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

function LeagueStageView:scrollViewDidScroll(view)
end

function LeagueStageView:scrollViewDidZoom(view)
end

function LeagueStageView:tableCellTouched(table,cell)
end

function LeagueStageView:cellSizeForTable(table,idx) 
    return 400,170
end

function LeagueStageView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    cell:setColor(cc.c3b(255, 0, 0))
    local stageCell = cell:getChildByName("stageCell")
    if not stageCell then
    	stageCell = self._stageCell:clone()
    	stageCell:setVisible(true)
    	stageCell:setName("stageCell")
    	stageCell:setPosition(10,0)
    	cell:addChild(stageCell)
    end
    self:updateStageCell(stageCell,self._tableData[idx+1])

    return cell
end

function LeagueStageView:numberOfCellsInTableView(table)
   return #self._tableData
end

function LeagueStageView:updateStageCell( cell,data )
	local img = cell:getChildByName("img")
	local name = cell:getChildByName("name")
	local num = cell:getChildByName("num")
	local bg = cell:getChildByName("stageBg")
	img:loadTexture(data.icon .. ".png",1)
    img:setScale(0.75)
	name:setString(lang(data.name))
	num:setString(data.num)
	bg:loadTexture("stage".. data.id .."cellbg_league.png",1)

	local selImg = cell:getChildByName("selImg")
    if selImg then
        selImg:setVisible(false)
    end
	if data.id == self._modelMgr:getModel("LeagueModel"):getLeague().currentZone then
		if not selImg then
			selImg = ccui.ImageView:create()
			selImg:loadTexture("globalImageUI_woziji.png",1)
			-- selImg:setScale(0.6)
            selImg:setName("selImg")
			selImg:setPosition(cc.p(67,30))
			cell:addChild(selImg,15)
		end
		selImg:setVisible(true)
	end
	local proLab = cell:getChildByName("proLab")
	-- if data.id == 9 then
	-- 	if not proLab then
	-- 		proLab = ccui.Text:create()
	-- 		proLab:setPosition(70,120)
	-- 		proLab:setFontName(UIUtils.ttfName)
	-- 		proLab:setFontSize(20)
	-- 		proLab:setName("proLab")
	-- 		cell:addChild(proLab)
	-- 	end
 --        proLab:setVisible(true)
	-- 	proLab:setString("前十名")
	-- else
    if proLab then 
		proLab:setVisible(false)
	end

	self:reChangeElemet(cell)
end

function LeagueStageView:fitWinSize( )
	local winW = MAX_SCREEN_WIDTH
	local winH = MAX_SCREEN_HEIGHT
	self._close:setPositionX(480+winW/2-28)
	self._leftArrow:setPositionX(28-(winW-960)/2)
	self._rightArrow:setPositionX(480+winW/2-28)
end

return LeagueStageView