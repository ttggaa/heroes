--[[
    Filename:    GuildInSeekLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-20 20:10:39
    Description: File description
--]]

-- 联盟查找
local GuildInSeekLayer = class("GuildInSeekLayer", BasePopView)

function GuildInSeekLayer:ctor()
    GuildInSeekLayer.super.ctor(self)
    self._allianceListData = {}
end

function GuildInSeekLayer:onInit()
    self._title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(self._title, 4)

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
    end)

    local tishi = self:getUI("bg.bg1.tishi")
    -- tishi:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    local findText = self:getUI("bg.bg1.findTextBg.findText")
    findText:setColor(cc.c3b(255, 255, 255))
    findText:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    -- findText:setPlaceHolder("点击这里输入")
    findText:addEventListener(function(sender, eventType)
        findText:setColor(cc.c3b(70, 40, 0))
        if findText:getString() == "" then
            findText:setColor(cc.c3b(255, 255, 255))
            findText:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
            findText:setPlaceHolder("点击这里输入")
        end
    end)
    -- findText:setPlaceHolderColor(UIUtils.colorTable.ccUIBaseOutlineColor)

    self._nothing = self:getUI("bg.bg1.nothing")
    self._nothingLab = self:getUI("bg.bg1.nothing.lab")
    self._nothingLab:setString("请输入联盟名称或ID~")

    local seek = self:getUI("bg.bg1.seek")
    self:registerClickEvent(seek, function()
        local findText = self:getUI("bg.bg1.findTextBg.findText")
        self:selectGuild(findText:getString())
    end)
    self:addTableView()  
end



--[[
用tableview实现
--]]

function GuildInSeekLayer:addTableView()
    local tableViewBg = self:getUI("bg.bg1.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(-4, 0))
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
function GuildInSeekLayer:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildDetailDialog")
    -- print("==========================")
end

-- cell的尺寸大小
function GuildInSeekLayer:cellSizeForTable(table,idx) 
    local width = 840 
    local height = 106
    return height, width
end

-- 创建在某个位置的cell
function GuildInSeekLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()

    local indexId = idx+1
    local param = {allianceD = self._allianceListData[indexId], id = indexId}
    if nil == cell then
        cell = cc.TableViewCell:new()
        -- local aiCell = self._viewMgr:createLayer("guild.GuildInCell")
        local aiCell = self._viewMgr:createLayer("guild.join.GuildInCell",{applyJoinBack = function(tempId)
            print ("加入数据", tempId)
            self._allianceListData[tempId].hadApply = 1
            -- aiCell:reflashUI({allianceD = self._allianceListData[tempId], id = tempId})
        end, applyJoinBack = function(tempId)
            print ("数据", tempId)
            self._allianceListData[tempId].hadApply = 0
            -- aiCell:reflashUI({allianceD = self._allianceListData[tempId], id = tempId})
        end})
        aiCell:setName("aiCell")
        cell:addChild(aiCell)
        aiCell:reflashUI(param)
        aiCell:setSwallowTouches(false)
        aiCell:setPosition(2,0)
    else
        local aiCell = cell:getChildByName("aiCell")
        if aiCell then
            aiCell:reflashUI(param)
            aiCell:setSwallowTouches(false)
        end
    end
    return cell
end

-- 返回cell的数量
function GuildInSeekLayer:numberOfCellsInTableView(table)
    return #self._allianceListData --table.nums(self._allianceListData)
end


function GuildInSeekLayer:reflashUI(data)
     
end


function GuildInSeekLayer:selectGuild(str)
    if str == "" then
        print("查找内容为空")
        return
    end
    local param = {content = str}
    self._serverMgr:sendMsg("GuildServer", "selectGuild", param, true, {}, function (result)
        self:selectGuildFinish(result)
    end)
end 

function GuildInSeekLayer:selectGuildFinish(result)
    if result == nil then 
        return 
    end
    dump(result, "result")
    if next(result) == nil then
        self._viewMgr:showTip("没有找到符合条件的联盟")
        self._nothingLab:setString("没有您要找的联盟~")
        self._nothing:setVisible(true)
    else
        self._nothing:setVisible(false)
    end
    self._allianceListData = result
    result = nil 
    self._tableView:reloadData()
    -- self._allianceListData = result["guildList"]
    -- self._page = result["nowPage"]
end

return GuildInSeekLayer
