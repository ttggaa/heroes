--[[
    Filename:    GuildRedHistoryLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-06 19:55:32
    Description: File description
--]]

-- 红包历史
local GuildRedHistoryLayer = class("GuildRedHistoryLayer", BaseLayer)

function GuildRedHistoryLayer:ctor()
    GuildRedHistoryLayer.super.ctor(self)
    self._tableData = {}
    self._robData = {}
    self._sendData = {}
    self._logType = 1
end

function GuildRedHistoryLayer:onInit()
    self._redCell = self:getUI("redCell")
    self._goldLab = self:getUI("bg.tishi1")
    self._gemLab = self:getUI("bg.tishi2")
    self._baowuLab = self:getUI("bg.tishi3")
    self._redNum = self:getUI("bg.tishi5")

    self._image2 = self:getUI("bg.img2")
    self._img3 = self:getUI("bg.img3")
    self._tishi4 = self:getUI("bg.tishi4")
    self._tishi5 = self:getUI("bg.tishi5")

    self:getUI("bg.nothing"):setVisible(false)
    self._noneLabel = self:getUI("bg.nothing.noneLabel")
    self:lableVisible(false)
    self._allRejectBtn = self:getUI("bg.allRejectBtn")
    self:registerClickEvent(self._allRejectBtn, function()
        if self._logType == 1 then
            self._logType = 2
        elseif self._logType == 2 then
            self._logType = 1
        end
        self:qiehuanLog()
    end)
    self:qiehuanLog()
    self:addTableView()
end

function GuildRedHistoryLayer:lableVisible(visible)
    local tishi = self:getUI("bg.tishi")
    if tishi then
        tishi:setVisible(visible)
    end
    for i=1,5 do 
        local widget = self:getUI("bg.tishi"..i)
        if widget then
            widget:setVisible(visible)
        end
    end
    for i=1,3 do
        local widget = self:getUI("bg.img"..i)
        if widget then
            widget:setVisible(visible)
        end
    end
end

function GuildRedHistoryLayer:qiehuanLog()

    if self._logType == 1 then
        print ("=================", self._logType)
        local tishi = self:getUI("bg.tishi")
        tishi:setString("抢到红包:")
        local tishi4 = self:getUI("bg.tishi4")
        tishi4:setString("抢红包:")
        local allRejectBtn = self:getUI("bg.allRejectBtn")
        allRejectBtn:setTitleText("发出红包")
        self._noneLabel:setString("您还没有抢过红包哟")

        local updateRob = self._modelMgr:getModel("GuildRedModel"):getRedRob()
        if self._robLogData ~= nil and updateRob == true then
            self._tableData = nil
            self._tableData = clone(self._robLogData)
            -- self._tableView:reloadData()
            self:reflashDataUI()
        else
            self:getRobLog()
        end
    elseif self._logType == 2 then
        print ("=================", self._logType)
        local tishi = self:getUI("bg.tishi")
        tishi:setString("发出红包:")
        local tishi4 = self:getUI("bg.tishi4")
        tishi4:setString("发红包:")
        local allRejectBtn = self:getUI("bg.allRejectBtn")
        allRejectBtn:setTitleText("抢到红包")
        self._noneLabel:setString("您还没有发过红包哟")

        local updateSend = self._modelMgr:getModel("GuildRedModel"):getRedSend()
        if self._sendLogData ~= nil and updateSend == true then
            self._tableData = nil
            self._tableData = clone(self._sendLogData)
            -- self._tableView:reloadData()
            self:reflashDataUI()
        else
            self:getSendLog()
        end
    end
end

function GuildRedHistoryLayer:reflashUI()
    -- self._tableView:reloadData()
    self:qiehuanLog()

end

function GuildRedHistoryLayer:reflashDataUI()
    -- dump(self._robData,"reflashDataUI",10)
    if self._logType == 1 then
        self._goldLab:setString(self._robData["gold_0"] or 0)
        self._gemLab:setString(self._robData["gem_0"] or 0)
        self._baowuLab:setString(self._robData["tool_41001"] or 0)
        self._redNum:setString(self._robData["count"] or 0)
    elseif self._logType == 2 then
        self._goldLab:setString(self._sendData["gold_0"] or 0)
        self._gemLab:setString(self._sendData["gem_0"] or 0)
        self._baowuLab:setString(self._sendData["tool_41001"] or 0)
        self._redNum:setString(self._sendData["count"] or 0)
    end

    self._image2:setPositionX(self._goldLab:getPositionX()+self._goldLab:getContentSize().width+10)
    self._gemLab:setPositionX(self._image2:getPositionX()+self._image2:getContentSize().width-15)
    self._img3:setPositionX(self._gemLab:getPositionX()+self._gemLab:getContentSize().width+10)
    self._baowuLab:setPositionX(self._img3:getPositionX()+self._img3:getContentSize().width-15)
    self._tishi4:setPositionX(self._baowuLab:getPositionX()+self._baowuLab:getContentSize().width+10)
    self._tishi5:setPositionX(self._tishi4:getPositionX()+self._tishi4:getContentSize().width)

    if table.nums(self._tableData) ~= 0 then
        self._tableView:reloadData()
        self:getUI("bg.nothing"):setVisible(false)
    else
        self._tableView:reloadData()
        self:getUI("bg.nothing"):setVisible(true)
    end
    self:lableVisible(true)
end

--[[
用tableview实现
--]]
function GuildRedHistoryLayer:addTableView()
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
    -- self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function GuildRedHistoryLayer:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

-- cell的尺寸大小
function GuildRedHistoryLayer:cellSizeForTable(table,idx) 
    local width = 770  --785  211
    local height = 290  --88  209
    return height, width
end

-- 创建在某个位置的cell
function GuildRedHistoryLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    -- local param = self._technology[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=1,4 do
            local redCell = self._redCell:clone() 
            redCell:setAnchorPoint(cc.p(0,0))
            redCell:setPosition(cc.p((i-1)*190+4,0))
            redCell:setName("redCell" .. i)
            cell:addChild(redCell)
        end

        self:updateCell(cell, indexId)
        -- detailCell:setSwallowTouches(false)
    else
        print("wo shi shua xin")
        self:updateCell(cell, indexId)
    end

    return cell
end

-- 返回cell的数量
function GuildRedHistoryLayer:numberOfCellsInTableView(table)
    return self:cellLineNum() -- #self._backupData -- #self._technology --table.nums(self._membersData)
end

function GuildRedHistoryLayer:cellLineNum()
    return math.ceil(table.nums(self._tableData)/4)
end

function GuildRedHistoryLayer:updateCell(cell, indexLine)    
    for i=1,4 do
        local redCell = cell:getChildByFullName("redCell" .. i)
        if redCell then
            local indexId = (indexLine-1)*4+i
            self:updateCellUI(redCell, self._tableData[table.nums(self._tableData)+1-indexId], indexId)  
            redCell:setSwallowTouches(false)
        end
    end
end

function GuildRedHistoryLayer:updateCellUI(redCell, redData, indexId)  
    if redData then
        -- dump(redData)
        local classType,image
        if redData["type"] == "gold" then
            classType = 1
            image = "guild_red_huangjin.png"
        elseif redData["type"] == "gem" then
            classType = 2
            -- className = "钻石红包"
            image = "guil_red_zuanshi.png"
        else 
            classType = 3
            -- className = "宝物红包"
            image = "guild_red_baowu.png"
        end

        local redtype = redCell:getChildByFullName("gu")
        if redtype and classType then
            redtype:loadTexture(image, 1)
        end

        local playName = redCell:getChildByFullName("playName")
        if playName then
            playName:setString(redData.name)
        end

        -- local priceValue = redCell:getChildByFullName("priceValue")
        -- if priceValue then
        --     priceValue:setString(redData["num"])
        -- end

        -- local sendRedLog = redCell:getChildByFullName("sendRedLog")
        -- local receiveRedLog = redCell:getChildByFullName("receiveRedLog")

        -- local redName
        -- if self._logType == 1 then   
        --     redName = redData["name"] or "玩家的名字很长"
        -- elseif self._logType == 2 then
        --     redName = className
        -- end
        -- redCell:getChildByFullName("sendLab"):setString(redName)
        redCell:setVisible(true)
    else
        redCell:setVisible(false)
    end
end

-- 获取玩家抢红包日志
function GuildRedHistoryLayer:getRobLog()
    self._serverMgr:sendMsg("GuildRedServer", "getRobLog", {}, true, {}, function (result)
        self:getRobLogFinish(result)
    end)
end 

function GuildRedHistoryLayer:getRobLogFinish(result)
    if result == nil then 
        return 
    end

    self._modelMgr:getModel("GuildRedModel"):setRedRob(true)
    -- dump(result)
    self._robLogData = result["list"]
    self._robData = result["totalList"]
    self:qiehuanLog()
end

-- 获取玩家发红包日志
function GuildRedHistoryLayer:getSendLog()
    self._serverMgr:sendMsg("GuildRedServer", "getSendLog", {}, true, {}, function (result)
        self:getSendLogFinish(result)
    end)
end 

function GuildRedHistoryLayer:getSendLogFinish(result)
    if result == nil then 
        return 
    end

    self._modelMgr:getModel("GuildRedModel"):setRedSend(true)
    self._sendLogData = result["list"]
    self._sendData = result["totalList"]
    self:qiehuanLog()
end

return GuildRedHistoryLayer
