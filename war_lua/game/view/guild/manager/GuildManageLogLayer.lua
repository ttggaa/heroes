--[[
    Filename:    GuildManageLogLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

-- 联盟日志
local GuildManageLogLayer = class("GuildManageLogLayer", BasePopView)

function GuildManageLogLayer:ctor()
    GuildManageLogLayer.super.ctor(self)
end

function GuildManageLogLayer:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
    end)

    self._cacheRich = {}
    -- self._modelMgr:getModel("GuildModel"):clearLogData()
    -- self:getGuildEvent()
    self:addTableView()
end


function GuildManageLogLayer:reflashUI()
    self._logData = self._modelMgr:getModel("GuildModel"):getLogData()
    self._tableView:reloadData()
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

function GuildManageLogLayer:addTableView()
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

function GuildManageLogLayer:tableCellTouched(table,cell)

end

-- GuildManageLogLayer
function GuildManageLogLayer:cellSizeForTable(table,idx)
    local data, height = self:getChatContentRich(self._logData[idx + 1], idx, 1, 290)
    return 10 + height, 370
end

function GuildManageLogLayer:getChatContentRich(data, idx, type, width)
    if width == nil then 
        width = 650
    end

    -- print("data.id====", data.id, type)
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
            return backRich, backRich:getRealSize().height + 24
        end
        return backRich, backRich:getRealSize().height
    end
    -- print("3data.id====", data.id)
    local str = self:getRichTextString(data)

    if str == nil then 
        str = "[color=632c0f] [-]"
    end

    local richText = RichTextFactory:create(str, width, 0)
    richText:formatText()
    self._cacheRich[data.id] = richText
    richText:retain()
    richText:setName("text")
    richText:setPixelNewline(true)
    richText.showId = data.id
    if data.timeType == 2 then
        -- dump(data)
        return richText, richText:getRealSize().height + 24
    end
    return richText, richText:getRealSize().height
end

-- 创建在某个位置的cell
function GuildManageLogLayer:tableCellAtIndex(table, idx)
    -- print("tableCellAtIndex============")
    local cell = table:dequeueCell()

    local logData = self._logData[idx + 1]
    local richText , height = self:getChatContentRich(logData, idx, 2, 290)

    if nil == cell then
        cell = require("game.view.guild.manager.GuildManageLogCell"):new()
    end
    cell:reflashUI(logData, richText, 350, height + 10)
    richText:release()
    return cell
end

-- 返回cell的数量
function GuildManageLogLayer:numberOfCellsInTableView(table)
    return #self._logData
end

function GuildManageLogLayer:tableCellWillRecycle(table, cell)
    if cell.richText ~= nil then 
        cell.richText:removeFromParent()
        cell.richText = nil
    end
end

-- function GuildManageLogLayer:getGuildEvent()
--     local param = {defId = 0, type = 2}
--     self._serverMgr:sendMsg("GuildServer", "getGuildEvent", param, true, {}, function (result)
--         -- dump(result)
--         -- self._logData = result
--         -- self._tableView:reloadData()

--         self._logData = self._modelMgr:getModel("GuildModel"):getLogData()
--         self._tableView:reloadData()
--         -- dump(self._logData)

--         -- for i,v in ipairs(result) do
--         --     self:getRichTextString(result[i])
--         -- end 
--     end)
-- end 

function GuildManageLogLayer:getRichTextString(data)
    if data == nil then
        return 
    end
    local str = lang("RIZHI_" .. data.type)
    if data.type == 8 then
        -- dump(data.params)
        local tempData = {}
        tempData.name = lang(tab:TechnologyChild(data.params["tid"]).name)
        tempData.level = data.params["level"]
        
        for k,v in pairs(tempData) do
            str = self:split(str,k,v)
        end
    else
        for k,v in pairs(data.params) do
            str = self:split(str,k,v)
        end
    end

    return str
end 

-- string.gsub(s, pattern, repl[,n])

function GuildManageLogLayer:split(str,param,reps)
    -- print("str,param,reps", str,param,reps)
    if str == "" then
        return str
    end
    -- local des = string.gsub(str,"%b{}",function( lvStr )
    --     return string.gsub(string.gsub(lvStr,"%$" .. param,reps),"[{}]","")
    -- end, 1)
    local des = string.gsub(str,"{$" .. param .. "}",reps)
    -- print(des)
    return des 
end

-- function GuildManageLogLayer:limitLen(str, maxNum)
--     local lenInByte = #str
--     local lenNum = 0
--     for i=1,lenInByte do
--         local curByte = string.byte(str, i)
--         if curByte>0 and curByte<=127 then
--             lenNum = lenNum + 1
--         elseif curByte>=192 and curByte<=247 then
--             lenNum = lenNum + 3
--             maxNum = maxNum + 1
--         end
--         if lenNum >= maxNum then
--             break
--         end
--     end
--     str = string.sub(str, 1, lenNum)
--     return str
-- end

return GuildManageLogLayer

















-- --[[
--     Filename:    GuildManageLogLayer.lua
--     Author:      <qiaohuan@playcrab.com>
--     Datetime:    2016-04-27 21:29:47
--     Description: File description
-- --]]

-- local GuildManageLogLayer = class("GuildManageLogLayer", BaseLayer)

-- function GuildManageLogLayer:ctor()
--     GuildManageLogLayer.super.ctor(self)
-- end

-- function GuildManageLogLayer:onInit()
--     self._cacheRich = {}
--     -- self._modelMgr:getModel("GuildModel"):clearLogData()
--     self:getGuildEvent()
--     self:addTableView()
-- end


-- function GuildManageLogLayer:reflashUI()
--     -- self._logData = self._modelMgr:getModel("GuildModel"):getLogData()
--     -- if self._logData == nil then
--     --     self:getGuildEvent()
--     -- else
--     -- self._tableView:reloadData()
--     -- end
--     -- self:addTableView()
-- end



-- --[[
-- 用tableview实现
-- --]]

-- function GuildManageLogLayer:addTableView()
--     local tableViewBg = self:getUI("bg.tableViewBg")
--     self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
--     self._tableView:setPosition(cc.p(0, 0))
--     self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
--     self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--     self._tableView:setDelegate()
--     -- self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
--     -- tableView:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
--     self._tableView:registerScriptHandler(function(table, cell) self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
--     self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
--     self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
--     self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
--     self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
--     self._tableView:setBounceable(true)
--     -- if self._tableView.setDragSlideable ~= nil then 
--     --     self._tableView:setDragSlideable(true)
--     -- end
--     -- self._tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
--     tableViewBg:addChild(self._tableView)
    
-- end

-- function GuildManageLogLayer:tableCellTouched(table,cell)

-- end

-- -- GuildManageLogLayer
-- function GuildManageLogLayer:cellSizeForTable(table,idx)
--     local data, height = self:getChatContentRich(self._logData[idx + 1], idx, 1, 650)
--     return 10 + height, 730
-- end

-- function GuildManageLogLayer:getChatContentRich(data, idx, type, width)
--     if width == nil then 
--         width = 650
--     end

--     -- print("data.id====", data.id, type)
--     local backRich = self._cacheRich[data.id]
--     if backRich ~= nil then 
--         if type == 2 and backRich:getParent() ~= nil then
--             if backRich:getParent().showId ~= data.id then
--                 backRich:retain()
--                 backRich:removeFromParent()
--             end
--         elseif type == 2  then 
--             backRich:retain()
--         end
--         if data.timeType == 2 then
--             -- dump(data)
--             return backRich, backRich:getRealSize().height + 24
--         end
--         return backRich, backRich:getRealSize().height
--     end
--     -- print("3data.id====", data.id)
--     local str = self:getRichTextString(data)

--     if str == nil then 
--         str = "[color=632c0f] [-]"
--     end

--     local richText = RichTextFactory:create(str, width, 0)
--     richText:formatText()
--     self._cacheRich[data.id] = richText
--     richText:retain()
--     richText:setName("text")
--     richText:setPixelNewline(true)
--     richText.showId = data.id
--     if data.timeType == 2 then
--         dump(data)
--         return richText, richText:getRealSize().height + 24
--     end
--     return richText, richText:getRealSize().height
-- end

-- -- 创建在某个位置的cell
-- function GuildManageLogLayer:tableCellAtIndex(table, idx)
--     -- print("tableCellAtIndex============")
--     local cell = table:dequeueCell()

--     local logData = self._logData[idx + 1]
--     local richText , height = self:getChatContentRich(logData, idx, 2, 650)

--     if nil == cell then
--         cell = require("game.view.guild.manager.GuildManageLogCell"):new()
--     end
--     cell:reflashUI(logData, richText, 374, height + 10)
--     richText:release()
--     return cell
-- end

-- -- 返回cell的数量
-- function GuildManageLogLayer:numberOfCellsInTableView(table)
--     return #self._logData
-- end

-- function GuildManageLogLayer:tableCellWillRecycle(table, cell)
--     if cell.richText ~= nil then 
--         cell.richText:removeFromParent()
--         cell.richText = nil
--     end
-- end

-- function GuildManageLogLayer:getGuildEvent()
--     local param = {defId = 0, type = 2}
--     self._serverMgr:sendMsg("GuildServer", "getGuildEvent", param, true, {}, function (result)
--         -- dump(result)
--         -- self._logData = result
--         -- self._tableView:reloadData()

--         self._logData = self._modelMgr:getModel("GuildModel"):getLogData()
--         self._tableView:reloadData()
--         -- dump(self._logData)

--         -- for i,v in ipairs(result) do
--         --     self:getRichTextString(result[i])
--         -- end 
--     end)
-- end 

-- function GuildManageLogLayer:getRichTextString(data)
--     if data == nil then
--         return 
--     end
--     local str = lang("RIZHI_" .. data.type)
--     if data.type == 8 then
--         dump(data.params)
--         local tempData = {}
--         tempData.name = lang(tab:TechnologyChild(data.params["tid"]).name)
--         tempData.level = data.params["level"]
        
--         for k,v in pairs(tempData) do
--             str = self:split(str,k,v)
--         end
--     else
--         for k,v in pairs(data.params) do
--             str = self:split(str,k,v)
--         end
--     end

--     return str
-- end 

-- -- string.gsub(s, pattern, repl[,n])

-- function GuildManageLogLayer:split(str,param,reps)
--     -- print("str,param,reps", str,param,reps)
--     if str == "" then
--         return str
--     end
--     local des = string.gsub(str,"%b{}",function( lvStr )
--         return string.gsub(string.gsub(lvStr,"%$" .. param,reps),"[{}]","")
--     end, 1)
--     -- print(des)
--     return des 
-- end

-- -- function GuildManageLogLayer:limitLen(str, maxNum)
-- --     local lenInByte = #str
-- --     local lenNum = 0
-- --     for i=1,lenInByte do
-- --         local curByte = string.byte(str, i)
-- --         if curByte>0 and curByte<=127 then
-- --             lenNum = lenNum + 1
-- --         elseif curByte>=192 and curByte<=247 then
-- --             lenNum = lenNum + 3
-- --             maxNum = maxNum + 1
-- --         end
-- --         if lenNum >= maxNum then
-- --             break
-- --         end
-- --     end
-- --     str = string.sub(str, 1, lenNum)
-- --     return str
-- -- end

-- return GuildManageLogLayer
