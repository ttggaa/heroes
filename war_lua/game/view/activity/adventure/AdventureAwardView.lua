--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-10-24 21:34:31
--
local AdventureAwardView = class("AdventureAwardView",BasePopView)
function AdventureAwardView:ctor(param)
    self.super.ctor(self)
    self._tableData = param.awards or {}
    if #self._tableData > 0 then
        table.sort(self._tableData,function( t1,t2 )
            local tool1D
            local tool2D 
            local itemId1 
            if t1[1] == "tool" then
                itemId1 = t1[2]
            else
                local iconType = t1[1]
                itemId1 = IconUtils.iconIdMap[iconType]
            end

            local itemId2 
            if t2[1] == "tool" then
                itemId2 = t2[2]
            else
                local iconType = t2[1]
                itemId2 = IconUtils.iconIdMap[iconType]
            end
            local color1 = ItemUtils.findResIconColor(itemId1,t1[3])
            local color2 = ItemUtils.findResIconColor(itemId2,t2[3])
            if color1 ~= color2 then
                return color1 > color2
            else
                return itemId1 > itemId2 
            end
        end)
    end
    dump(self._tableData,"table.....====================================")
end

-- 初始化UI后会调用, 有需要请覆盖
function AdventureAwardView:onInit()
	self:registerClickEventByName("bg.closeBtn",function( )
        self:close()
        UIUtils:reloadLuaFile("activity.adventure.AdventureAwardView")
    end)
    self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    self._tableBg = self:getUI("bg.tableBg")
    self:addTableView()
    local noneImg = self:getUI("bg.noneImg")
    noneImg:setVisible(#self._tableData == 0)
end

function AdventureAwardView:addTableView( )
    local tableView = cc.TableView:create(cc.size(440, 319))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0,10))
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

function AdventureAwardView:scrollViewDidScroll(view)
end

function AdventureAwardView:scrollViewDidZoom(view)
end

function AdventureAwardView:tableCellTouched(table,cell)
end

function AdventureAwardView:cellSizeForTable(table,idx) 
    return 100,440
end

function AdventureAwardView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren()
    for i=1,4 do
    	local itemData = self._tableData[idx*4+i]
    	if itemData then
    		local itemId = IconUtils.iconIdMap[itemData[1]] or itemData[2]
    		local itemNum = itemData[3]
    		local icon = IconUtils:createItemIconById({itemId=itemId,num=itemNum})
    		icon:setScale(0.9)
            icon:setScaleAnim(true)
            icon:setAnchorPoint(0.5,0.5)
            icon:setName("cell_" .. idx .. "_" .. i)
    		icon:setPosition((i-1)*100+20+50,0+50)
    		cell:addChild(icon,1)
    	end
    end

    return cell
end

function AdventureAwardView:numberOfCellsInTableView(table)
   return math.ceil(#self._tableData/4)
end

-- 接收自定义消息
function AdventureAwardView:reflashUI(data)

end

return AdventureAwardView