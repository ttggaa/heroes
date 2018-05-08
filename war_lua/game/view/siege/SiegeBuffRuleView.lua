--[[
 	@FileName 	SiegeBuffRuleView.lua
	@Authors 	zhangtao
	@Date    	2017-11-20 10:42:08
	@Email    	<zhangtao@playcrad.com>
	@Description   描述
--]]
local addBuffValueKey = {
	[10001] = "damage1",
	[10002] = "damage2",
	[10003] = "damage3",
	[10004] = "damage4",
	[10005] = "damage5",
	[30001] = "damage6"
}
local SiegeBuffRuleView = class("SiegeBuffRuleView",BasePopView)
function SiegeBuffRuleView:ctor(params)
    self.super.ctor(self)
    self._stageId = params.stageId
end

-- 初始化UI后会调用, 有需要请覆盖
function SiegeBuffRuleView:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn,function()
		self:close()
        UIUtils:reloadLuaFile("siege.SiegeBuffRuleView")
	end)

	self._title = self:getUI("bg.titleBg.title_imgBg.title_name")
	self._title:setString(lang("SIEGE_EVENT_QUEEN_TITLE"))
    UIUtils:setTitleFormat(self._title,1)

    self._layerNode = self:getUI("bg.bg2.infoBg.tableViewBg")
    self._cellItem = self:getUI("bg.cellBg")
    self:createTableView()
    
    local ruleTitle = self:getUI("bg.bg2.ruleTitle")
    ruleTitle:setString(lang("SIEGE_EVENT_QUEEN_RULE_1"))
    local progressTitle = self:getUI("bg.bg2.progressTitle")
    progressTitle:setString(lang("SIEGE_EVENT_QUEEN_RULE_2"))
end

-- 第一次进入调用, 有需要请覆盖
function SiegeBuffRuleView:onShow()

end

function SiegeBuffRuleView:createTableView()
    if self._listTableView then
        self._listTableView:reloadData()
        return 
    end
    local tableView = cc.TableView:create(cc.size(430,210))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._layerNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._listTableView = tableView
end

function SiegeBuffRuleView:scrollViewDidScroll(view)

end

function SiegeBuffRuleView:tableCellTouched(table,cell)
end

function SiegeBuffRuleView:cellSizeForTable(table,idx) 
    return 30,430
end

function SiegeBuffRuleView:tableCellAtIndex(table,idx)
    local index = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local itemView = self._cellItem:clone()
        itemView:setVisible(true)
        itemView:setAnchorPoint(0,0)
        itemView:setTouchEnabled(false)
        itemView:setPosition(0, 0)
        itemView:setTag(9999)

        cell:addChild(itemView)
        self:createLevelItem(itemView,index)
    else
        local itemView = cell:getChildByTag(9999)
        if not itemView then return end
        self:createLevelItem(itemView,index)
    end
    return cell
end


function SiegeBuffRuleView:numberOfCellsInTableView(table)
    return #tab.siegeDailyAtkBuff
end

function SiegeBuffRuleView:createLevelItem(itemView,index)
	print("=====index========"..index)
    local value1,value2 = math.modf(index/2)
    local itemImage = itemView:getChildByFullName("cellList")
    if tonumber(value2) == 0 then
    	itemImage:loadTexture("globalImageUI6_meiyoutu.png",1)
    	itemImage:setOpacity(255)
    else
    	itemImage:loadTexture("globalImageUI12_ruletextBg.png",1)
    	itemImage:setOpacity(153)
    end

    local listDay = itemView:getChildByFullName("cellList.listDay")
    local dayTxt = lang("SIEGE_EVENT_QUEEN_RULE_3")
    dayTxt = string.gsub(dayTxt,"{$num}",index)     
    listDay:setString(dayTxt)

    local listDesc = itemView:getChildByFullName("cellList.listDesc")
    local desTxt = lang("SIEGE_EVENT_QUEEN_EFFECT")
    desTxt = string.gsub(desTxt,"{$num}",tab.siegeDailyAtkBuff[index][addBuffValueKey[self._stageId]])                
    listDesc:setString(desTxt)

end

-- 接收自定义消息
function SiegeBuffRuleView:reflashUI(data)

end

return SiegeBuffRuleView