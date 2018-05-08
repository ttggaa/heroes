--[[
    Filename:    TeamHolyAutoSelectDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-15 14:40:05
    Description: File description
--]]


-- 自动选择
local TeamHolyAutoSelectDialog = class("TeamHolyAutoSelectDialog", BasePopView)
local qualityName = {
    [1] = "白色圣徽",
    [2] = "绿色圣徽",
    [3] = "蓝色圣徽",
    [4] = "紫色圣徽",
    [5] = "橙色圣徽",
}

function TeamHolyAutoSelectDialog:ctor(param)
    TeamHolyAutoSelectDialog.super.ctor(self)
    self._callback = param.callback
    self._selectItem = {}
end

function TeamHolyAutoSelectDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._gift = {2,3,4,5}

    self:registerClickEventByName("bg.closeBtn", function ()
        UIUtils:reloadLuaFile("team.TeamHolyAutoSelectDialog")
        self:close()
    end)

    local determineBtn = self:getUI("bg.determineBtn")
    self:registerClickEvent(determineBtn, function()
        if self._callback then
            self._callback(self._selectItem)
        end
        self:close()
    end)

    dump(self._gift, "data ===", 10)
    self._itemCell = self:getUI("itemCell")
    self._itemCell:setVisible(false)

    self:addTableView()
end

function TeamHolyAutoSelectDialog:reflashUI(data)
    if not self._gift then
        return
    end

    self._tableView:reloadData()
end



--[[
用tableview实现
--]]
function TeamHolyAutoSelectDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function TeamHolyAutoSelectDialog:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function TeamHolyAutoSelectDialog:cellSizeForTable(table,idx) 
    local width = 380 
    local height = 80
    return height, width
end

-- 创建在某个位置的cell
function TeamHolyAutoSelectDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._gift[idx + 1] -- {typeId = 3, id = 1}
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local itemCell = self._itemCell:clone()
        itemCell:setAnchorPoint(cc.p(0,0))
        itemCell:setPosition(cc.p(0,0))
        itemCell:setVisible(true)
        itemCell:setName("itemCell")
        cell:addChild(itemCell)

        self:updateCell(itemCell, param, indexId)
        itemCell:setSwallowTouches(false)
    else
        local itemCell = cell:getChildByName("itemCell")
        if itemCell then
            self:updateCell(itemCell, param, indexId)
            itemCell:setSwallowTouches(false)
        end
    end
    return cell
end

-- 返回cell的数量
function TeamHolyAutoSelectDialog:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function TeamHolyAutoSelectDialog:tableNum()
    return table.nums(self._gift)
end

function TeamHolyAutoSelectDialog:updateCell(inView, data, indexId)
    if data == nil then
        return
    end

    -- 名字
    local tname = inView:getChildByFullName("tname")
    if tname then
        tname:setString(qualityName[data])
        tname:setColor(UIUtils.colorTable["ccColorQuality" .. data])
        tname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        tname:setLineBreakWithoutSpace(true)
    end

    local selectBg = inView:getChildByFullName("selectBg")
    local pitch = inView:getChildByFullName("selectBg.pitch")
    if pitch then
        if self._selectItem[data] and self._selectItem[data] == 1 then
            pitch:setVisible(true)
        else
            pitch:setVisible(false)
        end
    end
    if selectBg then
        self:registerClickEvent(selectBg, function()
            if self._selectItem[data] == 1 then
                self._selectItem[data] = nil
            else
                self._selectItem[data] = 1
            end
            self:reloadData()
        end)
    end
end

function TeamHolyAutoSelectDialog:reloadData()
    local offset = self._tableView:getContentOffset()
    self._tableView:reloadData()
    self._tableView:setContentOffset(offset, false)
end

function TeamHolyAutoSelectDialog.dtor()
    qualityName = nil
end


return TeamHolyAutoSelectDialog