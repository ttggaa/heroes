--[[
    Filename:    FriendRecallLogView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local FriendRecallLogView = class("FriendRecallLogView", BasePopView)

function FriendRecallLogView:ctor()
    FriendRecallLogView.super.ctor(self)
    self._cacheRich = {}
end

function FriendRecallLogView:onInit()
    self._title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(self._title, 6)

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("friend.FriendRecallLogView")
    end)

    local nothing = self:getUI("bg.nothing")
    nothing:setVisible(false)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            if self._cacheRich ~= nil then 
                for k,v in pairs(self._cacheRich) do
                    v:release()
                end
            end
        elseif eventType == "enter" then 
        end
    end)
end

function FriendRecallLogView:reflashUI(inData)
    if not inData["info"] or type(inData["info"]) ~= "table" then
        return
    end

    self._logData = inData["info"]
    for i,v in ipairs(self._logData) do
        v["id"] = i
    end

    local nothing = self:getUI("bg.nothing")
    if #self._logData == 0 then
        nothing:setVisible(true)
        return
    end

    table.sort(self._logData, function(a, b) 
        return a.logTime > b.logTime 
        end)

    local tableBg = self:getUI("bg.tableBg")
    local wid, hei = tableBg:getContentSize().width, tableBg:getContentSize().height
    self._tableView = cc.TableView:create(cc.size(wid, hei))
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setDelegate()
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    self._tableView:setBounceable(true)
    tableBg:addChild(self._tableView)

    UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), 6, 6)

    self._tableView:reloadData()
end

function FriendRecallLogView:scrollViewDidScroll(view) 
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function FriendRecallLogView:cellSizeForTable(table,idx)
    local _, width, height = self:getChatContentRich(self._logData[idx + 1])
    return height + 5, width
end

function FriendRecallLogView:numberOfCellsInTableView(table)
    return #self._logData
end

function FriendRecallLogView:tableCellWillRecycle(table, cell)
    if cell.richText ~= nil then 
        cell.richText:removeFromParent()
        cell.richText = nil
    end
end

-- 创建在某个位置的cell
function FriendRecallLogView:tableCellAtIndex(table, idx)
    local logData = self._logData[idx + 1]
    local richText, _, height = self:getChatContentRich(logData)

    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    self:createCell(cell, logData, richText)
    return cell
end

function FriendRecallLogView:createCell(cell, cellData, richText)
    if cellData == nil then
        return
    end

    -- local height = 50 
    -- if richText:getRealSize().height > height then 
        height = richText:getRealSize().height
    -- end
    
    --time
    local timeStr = cell:getChildByName("timeStr")
    if timeStr == nil then
        timeStr = ccui.Text:create()
        timeStr:setFontName(UIUtils.ttfName)
        timeStr:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        timeStr:setFontSize(20)
        timeStr:setAnchorPoint(cc.p(0, 1))
        timeStr:setName("timeStr") 
        cell:addChild(timeStr)
    end

    timeStr:setPosition(0, height)
    local timeNum = cellData["logTime"] or 0 
    local temp = TimeUtils.date("%m", timeNum) .. "月" .. TimeUtils.date("%d", timeNum) .. "日"
    timeStr:setString(temp)

    --richText
    local x = richText:getRealSize().width / 2
    if richText:getRealSize().width < richText:getContentSize().width then 
        x = richText:getContentSize().width / 2
    end
    x = x + 90

    richText:setPosition(x, height/2)
    cell.richText = richText
    cell:addChild(richText)
end

function FriendRecallLogView:getRichTextString(data)
    if data == nil then
        return 
    end

    local str = "[color=3d1f00]空[-]"
    if data.action == 1 then        --绑定
        str = lang("FRIENDBACK_LOG_3")
    elseif data.action == 2 then    --被绑定
        str = lang("FRIENDBACK_LOG_2")
    elseif data.action == 3 then    --对方完成任务
        str = lang("FRIENDBACK_LOG_4")
    elseif data.action == 4 then    --自己完成任务
        str = lang("FRIENDBACK_LOG_1")
    elseif data.action == 5 then    --好友邀请日志
        str = lang("FRIENDBACK_LOG_5")
    end

    for k,v in pairs(data.params) do
        str = string.gsub(str, "{$" .. k .. "}", v)
    end
   
    return str
end 

function FriendRecallLogView:getChatContentRich(data, width)
    if width == nil then 
        width = 310
    end

    local backRich = self._cacheRich[data.id]
    if backRich ~= nil then 
        return backRich, width, backRich:getRealSize().height
    end

    local str = self:getRichTextString(data)
    local richText = RichTextFactory:create(str, width, 0)
    richText:formatText()
    richText:retain()
    self._cacheRich[data.id] = richText
    richText:setPixelNewline(true)
  
    return richText, width, richText:getRealSize().height
end

return FriendRecallLogView
