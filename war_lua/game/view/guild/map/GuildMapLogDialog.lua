--[[
    Filename:    GuildMapLogDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local GuildMapLogDialog = class("GuildMapLogDialog", BasePopView)

function GuildMapLogDialog:ctor()
    GuildMapLogDialog.super.ctor(self)
end

function GuildMapLogDialog:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapLogDialog")
        elseif eventType == "enter" then 
        end
    end)      
    self._title = self:getUI("bg.titleBg.title")
    self._title:setString("联盟战报")
    UIUtils:setTitleFormat(self._title,6)
    -- self._title:setFontName(UIUtils.ttfName)
    -- self._title:setColor(cc.c3b(255, 255, 255))
    -- self._title:setFontSize(30)

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        -- UIUtils:reloadLuaFile("guild.map.GuildMapLogDialog")
        -- UIUtils:reloadLuaFile("guild.map.GuildMapLogCell")
    end)

    local nothing = self:getUI("bg.nothing")
    nothing:setVisible(false)

    self._cacheRich = {}
    -- self._modelMgr:getModel("GuildModel"):clearLogData()
    self:getGuildEvent()
    self:addTableView()
end


function GuildMapLogDialog:reflashUI()
    -- self._logData = self._modelMgr:getModel("GuildModel"):getLogData()
    -- if self._logData == nil then
    --     self:getGuildEvent()
    -- else
    -- self._tableView:reloadData()
    -- end
    -- self:addTableView()
end



--[[
用tableview实现
--]]

function GuildMapLogDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setDelegate()
    -- self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    -- tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._tableView:registerScriptHandler(function(table, cell) self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    -- self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableViewBg:addChild(self._tableView)
    
end

function GuildMapLogDialog:tableCellTouched(table,cell)

end

-- GuildMapLogDialog
function GuildMapLogDialog:cellSizeForTable(table,idx)
    local data, height = self:getChatContentRich(self._logData[idx + 1], idx, 1, 300)
    return 5 + height, 300
end

function GuildMapLogDialog:getChatContentRich(data, idx, type, width)
    if width == nil then 
        width = 300
    end

    local backRich = self._cacheRich[data.id]
    if backRich ~= nil then 
        if type == 2 and backRich:getParent() ~= nil then
            if backRich:getParent().showId ~= data.id then
                backRich:retain()
                backRich:removeFromParent()
            end
        elseif type == 2  then 
            backRich:retain()
        end
        if data.timeType == 2 then
            -- dump(data)
            return backRich, backRich:getRealSize().height + 44
        end
        return backRich, backRich:getRealSize().height
    end
    local str = self:getRichTextString(data)
    if str == nil then 
        str = "[color=3d1f00] [-]"
    end

    local richText = RichTextFactory:create(str, width, 0)
    richText:formatText()
    self._cacheRich[data.id] = richText
    richText:retain()
    richText:setName("text")
    richText:setPixelNewline(true)
    richText.showId = data.id
    if data.timeType == 2 then
        return richText, richText:getRealSize().height + 44
    end
    return richText, richText:getRealSize().height
end

-- 创建在某个位置的cell
function GuildMapLogDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()

    local logData = self._logData[idx + 1]
    local richText , height = self:getChatContentRich(logData, idx, 2, 180)

    if nil == cell then
        cell = require("game.view.guild.map.GuildMapLogCell"):new()
    end
    cell:reflashUI(logData, richText, 320, height + 10)
    richText:release()
    return cell
end

-- 返回cell的数量
function GuildMapLogDialog:numberOfCellsInTableView(table)
    return #self._logData
end

function GuildMapLogDialog:tableCellWillRecycle(table, cell)
    if cell.richText ~= nil then 
        cell.richText:removeFromParent()
        cell.richText = nil
    end
end

function GuildMapLogDialog:getRichTextString(data)
    if data == nil then
        return 
    end
    local str = lang(tab:GuildMapReport(data.type)["report"])
    for k,v in pairs(data.params) do
        str = self:split(str,k,v)
    end
    if string.find(str, "color=") == nil then
        str = "[color=3d1f00]"..str.."[-]"
    end   
    return str
end 

-- string.gsub(s, pattern, repl[,n])

function GuildMapLogDialog:split(str,param,reps)
    if str == "" then
        return str
    end
    local des = string.gsub(str, "{$" .. param .. "}", reps)
 
    return des 
end

function GuildMapLogDialog:getGuildEvent()
    local param = {defId = 0, type = 2}
    self._serverMgr:sendMsg("GuildMapServer", "getMapEvent", param, true, {}, function (result)
        if self.setLogData == nil then return end
        self:setLogData(result)
        local nothing = self:getUI("bg.nothing")
        if table.nums(result) == 0 then
            nothing:setVisible(true)
        else
            nothing:setVisible(false)
            self._tableView:reloadData()
        end
        
    end)
end 

-- 日志数据处理
function GuildMapLogDialog:setLogData(data)
    self._logData = {}
    for k,v in pairs(data) do
        table.insert(self._logData, v)
    end
    self:logProgessData()
    self:setLogId()
end

function GuildMapLogDialog:getLogData()
    if self._logData == nil then
        return
    end
    return self._logData
end

function GuildMapLogDialog:logProgessData()
    if table.nums(self._logData) <= 1 then
        return 
    end
    local sortFunc = function(a,b)
        local acheck = a.eventTime
        local bcheck = b.eventTime
        if acheck > bcheck then
            return true
        end
    end
    table.sort(self._logData, sortFunc)
end

function GuildMapLogDialog:setLogId()
    local day1,day2,day
    for i,v in ipairs(self._logData) do
        if i > 1 and self._logData[i-1] then
            day1 = tonumber(TimeUtils.getDateString(self._logData[i-1].eventTime,"%Y%m%d"))
        end
        if self._logData[i] then
            day2 = tonumber(TimeUtils.getDateString(self._logData[i].eventTime,"%Y%m%d"))
        end
        v.timeType = 1
        if day1 and day2 and day1 ~= day2 then
            v.timeType = 2
        elseif not day1 then
            v.timeType = 2
        end
        local month = TimeUtils.getDateString(self._logData[i].eventTime,"%m")
        local day = TimeUtils.getDateString(self._logData[i].eventTime,"%d")
        v.day = month .. "月" .. day .. "日"
        v.time = TimeUtils.getDateString(self._logData[i].eventTime,"%H:%M")
        v.id = i 
    end
end

return GuildMapLogDialog
