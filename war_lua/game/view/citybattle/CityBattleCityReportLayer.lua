--[[
    Filename:    CityBattleCityReportLayer.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-06-30 11:04:24
    Description: File description
--]]

local cloneCell
local rankData
local tabData
local serverNum

local CityBattleCityReportLayer = class("CityBattleCityReportLayer", BaseLayer)

function CityBattleCityReportLayer:ctor(param)
    CityBattleCityReportLayer.super.ctor(self)
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    if param and param.list then
        rankData = param.list
    end
    self:initData()
end

function CityBattleCityReportLayer:initData()
    tabData = clone(tab.cityBattle)
    -- rankData = {
    --     {cid = 1,owner = 9992,old = 998,time = 1498806836},
    --     {cid = 2,owner = 9994,old = 998,time = 1498806836},
    --     {cid = 3,owner = 9998,old = 998,time = 1498806836},
    --     {cid = 4,owner = 9992,old = 998,time = 1498806836},
    --     {cid = 5,owner = 9992,old = 998,time = 1498806836},
    --     {cid = 6,owner = 9992,old = 998,time = 1498806836}
    -- }
    self._cityColor = self._cityBattleModel:getData().c.co
    serverNum  = table.nums(self._cityColor)

end

function CityBattleCityReportLayer:onInit()
    cloneCell = self:getUI("cityCell")
    cloneCell:setVisible(false)    
    -- self:updateTopData()
    local nothing = self:getUI("cityPanel.nothing")
    if #rankData <= 0 then
        nothing:setVisible(true)
    else
        nothing:setVisible(false)
    end

    self:addTableView()
end

--[[
用tableview实现
--]]
function CityBattleCityReportLayer:addTableView()
    local tableViewBg = self:getUI("cityPanel.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) 
        return self:tableCellTouched(table,cell) 
        end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) 
        return self:cellSizeForTable(table,idx) 
        end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) 
        return self:tableCellAtIndex(table, idx) 
        end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) 
        return self:numberOfCellsInTableView(table) 
        end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    self._tableView:reloadData()
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function CityBattleCityReportLayer:tableCellTouched(table,cell)
end


-- cell的尺寸大小
function CityBattleCityReportLayer:cellSizeForTable(table,idx) 
    local width = 550 
    local height = 110  --232
    return height, width
end

-- 创建在某个位置的cell
function CityBattleCityReportLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = rankData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local detailCell = cloneCell:clone() 
        detailCell:setVisible(true)
        detailCell:setPosition(cc.p(-3,0))
        detailCell:setName("detailCell")
        cell:addChild(detailCell)
    end

    local detailCell = cell:getChildByName("detailCell")
    if detailCell then
        self:updateCell(detailCell, param, indexId)
        detailCell:setSwallowTouches(false)
    end
    return cell
end

function CityBattleCityReportLayer:numberOfCellsInTableView(table)
    return self:cellLineNum() 
end

function CityBattleCityReportLayer:cellLineNum()
    return table.nums(rankData)
end

function CityBattleCityReportLayer:updateCell(cell, data, index)

    local cityImg = cell:getChildByFullName("cityImg")
    local cityName = cell:getChildByFullName("cityNameBg.cityName")
    local serverDes = cell:getChildByFullName("serverDes")
    local oldServer = cell:getChildByFullName("oldServer")
    local curImage = cell:getChildByFullName("curImage")
    local time = cell:getChildByFullName("time")

    local tab = tabData[tonumber(data.cid)]
    local imageName = "citybattle_map_0" .. tab["type"] .. tab["citylv" .. serverNum] .. ".png"
    cityImg:loadTexture(imageName,1)
    cityName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
    cityName:setString(lang(tab.name))

    local des = self._cityBattleModel:getServerName(data.owner)
    serverDes:setString(des .. "占领")
    -- serverDes:setFontSize(16)
    -- oldServer:setPositionX(286)
    -- oldServer:setFontSize(14)
    if not data.old or data.old == "" or data.old == "npc" then
        oldServer:setString("中立")
    else
        local oldDes = self._cityBattleModel:getServerName(data.old)
        oldServer:setString(oldDes)
    end
    
    local colorImage = self:getColorImage(data.owner)
    if colorImage then
        curImage:loadTexture(colorImage,1)
    end
    time:setString(self:getTimeString(data.time))

end

function CityBattleCityReportLayer:getTimeString(time)
    local t = TimeUtils.date("*t",time)
    local des = string.format("%.2d/%.2d/%.2d %.2d:%.2d",t.year,t.month,t.day,t.hour,t.min)
    return des
end

function CityBattleCityReportLayer:getColorImage(serverNum)
    local image = {"citybattle_view_temp6.png",
        "citybattle_view_temp8.png",
        "citybattle_view_temp7.png"
    }
    -- dump(self._cityColor)
    local num = self._cityColor[tostring(serverNum)]
    return image[num]
end


function CityBattleCityReportLayer:reflashUI()

end

function CityBattleCityReportLayer:dtor( ... )
    cloneCell = nil
    rankData = nil
    tabData = nil
    serverNum = nil
end



return CityBattleCityReportLayer
