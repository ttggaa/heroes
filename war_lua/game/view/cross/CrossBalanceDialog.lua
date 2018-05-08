--[[
    Filename:    CrossBalanceDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-13 16:26:35
    Description: File description
--]]

-- 积分对比

local CrossBalanceDialog = class("CrossBalanceDialog", BaseView)

function CrossBalanceDialog:ctor(data)
    CrossBalanceDialog.super.ctor(self)
    self._tableList = data
    self._arenaType = data.arenaType
end

function CrossBalanceDialog:getAsyncRes()
    return 
    {
    }
end

function CrossBalanceDialog:getBgName()
    return "bg_013.jpg"
end

function CrossBalanceDialog:onShow()
    self._viewMgr:enableScreenWidthBar()
end

function CrossBalanceDialog:onTop()
    self._viewMgr:enableScreenWidthBar()
end

function CrossBalanceDialog:onHide()
    self._viewMgr:disableScreenWidthBar()
end

function CrossBalanceDialog:onDestroy()
    self._viewMgr:disableScreenWidthBar()
    CrossBalanceDialog.super.onDestroy(self)
end


function CrossBalanceDialog:onInit()
    local closeBtn = self:getUI("bg.panel.bar2.closeBtn")
    self:registerClickEvent(closeBtn, function() 
        UIUtils:reloadLuaFile("cross.CrossBalanceDialog")
        self:close() 
    end)

    self._crossModel = self._modelMgr:getModel("CrossModel")

    self._panel = self:getUI("bg.panel")
    self._bar = self:getUI("bg.panel.bar")
    self._bar2 = self:getUI("bg.panel.bar2")

    local bgScale = self.__viewBg:getScale()
    self._bar:setPosition((MAX_SCREEN_WIDTH - 960) * 0.5, MAX_SCREEN_HEIGHT - 78 * bgScale)
    self._bar2:setPosition((MAX_SCREEN_WIDTH - 960) * 0.5, 0)

    self._playCell = self:getUI("playCell")
    self._playCell:setVisible(false)

    print("bgScale================",bgScale)
    local tableView = cc.TableView:create(cc.size(1136, 360 * bgScale))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition((MAX_SCREEN_WIDTH - 1136) * 0.5, 100 * bgScale)
    tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._panel:addChild(tableView)
    self._tableView = tableView

    -- self:onFilter(1)
    -- self:onPage(1)
    -- self:onUpdate()

    self:refreshUI()
    self:updateTitle()
end

function CrossBalanceDialog:updateTitle()
    local arenaData = self._crossModel:getData()
    local setStr1 = arenaData["sec1"]
    local setStr2 = arenaData["sec2"]
    local sec = arenaData[setStr] 
    local sNameStr1 = self._crossModel:getServerName(setStr1)
    local sNameStr2 = self._crossModel:getServerName(setStr2)

    local title = self:getUI("bg.panel.bar.titleBg.title")
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local sname1 = self:getUI("bg.panel.bar.titleBg.sname1")
    local sname2 = self:getUI("bg.panel.bar.titleBg.sname2")
    sname1:setString(sNameStr1)
    sname2:setString(sNameStr2)

    local biliLab1 = self:getUI("bg.panel.bar2.biliLab1")
    local biliLab2 = self:getUI("bg.panel.bar2.biliLab2")
    local scoreLab1 = self:getUI("bg.panel.bar2.scoreLab1")
    local scoreLab2 = self:getUI("bg.panel.bar2.scoreLab2")

    local arenaData = self._crossModel:getData()
    local sec1score = arenaData["sec1region" .. self._arenaType .. "score"] or 0 
    local sec2score = arenaData["sec2region" .. self._arenaType .. "score"] or 0
    scoreLab1:setString(sec1score)
    scoreLab2:setString(sec2score)
    if sec1score == 0 then
        sec1score = 1
    end
    if sec2score == 0 then
        sec2score = 1
    end

    local sScore1 = 0
    local sScore2 = 0
    local tableData1 = self._tableData[1]
    local tableData2 = self._tableData[2]
    for i=1,10 do
        if tableData1[i] then
            sScore1 = sScore1 + tableData1[i].scoreA
        end
        if tableData2[i] then
            sScore2 = sScore2 + tableData2[i].scoreA
        end
    end
    local bValue = sScore1/sec1score
    bValue = math.ceil(bValue*100)/100
    biliLab1:setString(bValue .. "%")
    local bValue = sScore2/sec2score
    bValue = math.ceil(bValue*100)/100
    biliLab2:setString(bValue .. "%")
end

function CrossBalanceDialog:progressData()
    local tableData = {}
    local tableList = self._tableList.ften
    dump(tableList)
    local serverId = 1
    local arenaData = self._crossModel:getData()
    local sec1 = tostring(arenaData.sec1)
    local sec2 = tostring(arenaData.sec2)

    local sec1score = arenaData["sec1region" .. self._arenaType .. "score"] or 0 
    local sec2score = arenaData["sec2region" .. self._arenaType .. "score"] or 0
    if sec1score == 0 then
        sec1score = 1
    end
    if sec2score == 0 then
        sec2score = 1
    end
    for k,v in pairs(tableList) do
        local tListData = {}
        local secScore = 1
        if k == sec1 then
            secScore = sec1score
        else
            secScore = sec2score
        end
        for i=1,10 do
            local indexId = tostring(i)
            if v[indexId] then
                local bValue = v[indexId].scoreA/secScore
                v[indexId].bValue = math.ceil(bValue*100)/100
            end
            tListData[i] = v[indexId]
        end
        if k == sec1 then
            tableData[1] = tListData
        else
            tableData[2] = tListData
        end
    end
    self._tableData = tableData
    dump(self._tableData)
end 

function CrossBalanceDialog:refreshUI()
    self:progressData()
    local count1 = table.nums(self._tableData[1])
    local count2 = table.nums(self._tableData[2])

    self._allCount = count1 > count2 and count1 or count2
    self._tableView:reloadData()
end


function CrossBalanceDialog:cellSizeForTable(table,index)
    return 50, 1136
end

function CrossBalanceDialog:tableCellWillRecycle(table,cell)
    cell:removeAllChildren()
end

function CrossBalanceDialog:numberOfCellsInTableView(table)
    return self._allCount
end

-- 创建在某个位置的cell
function CrossBalanceDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local playCell = self._playCell:clone() 
        playCell:setVisible(true)
        playCell:setAnchorPoint(0,0)
        playCell:setPosition(88,0)
        playCell:setName("playCell")
        cell:addChild(playCell)
        cell.playCell = playCell

        self:updateCell(playCell, indexId)
        playCell:setSwallowTouches(false)
    else
        local playCell = cell.playCell
        -- local playCell = cell:getChildByName("playCell")
        if playCell then
            self:updateCell(playCell, indexId)
            playCell:setSwallowTouches(false)
        end
    end

    return cell
end

function CrossBalanceDialog:updateCell(playCell, indexId)
    local sBg1 = playCell:getChildByFullName("sBg1")
    local tableData1 = self._tableData[1]
    local data = tableData1[indexId]
    self:updatePlayCell(sBg1, data, indexId)

    local sBg2 = playCell:getChildByFullName("sBg2")
    local tableData2 = self._tableData[2]
    local data = tableData2[indexId]
    self:updatePlayCell(sBg2, data, indexId)
end

function CrossBalanceDialog:updatePlayCell(inView, data, indexId)
    print("indexId=================", indexId)
    dump(data)
    if not data then
        inView:setVisible(false)
        return
    end
    inView:setVisible(true)

    local pname = inView:getChildByFullName("pname")
    local scoreLab = inView:getChildByFullName("scoreLab")
    local biliLab = inView:getChildByFullName("biliLab")
    local rankLab = inView:getChildByFullName("rankLab")

    if pname then
        pname:setString(data.name)
    end
    if scoreLab then
        local scoreLabStr = data.scoreA
        scoreLab:setString(scoreLabStr)
    end
    if rankLab then
        local rankLabStr = data.rank
        rankLab:setString(rankLabStr)
    end
    if biliLab then
        local biliLabStr = data.bValue
        biliLab:setString(biliLabStr .. "%")
    end
end

function CrossBalanceDialog:onWinSizeChange()
    CrossBalanceDialog.super.onWinSizeChange(self)
    local bgScale = self.__viewBg:getScale()

    self._bar:setPosition((MAX_SCREEN_WIDTH - 960) * 0.5, MAX_SCREEN_HEIGHT - 78 * bgScale)
    self._bar2:setPosition((MAX_SCREEN_WIDTH - 960) * 0.5, 0)
    self._tableView:setPosition((MAX_SCREEN_WIDTH - 1136) * 0.5, 75 * bgScale)
    self._tableView:setViewSize(cc.size(1136, 384 * bgScale))
    self._tableView:reloadData()
end

function CrossBalanceDialog:adjustBg()
    if self.__viewBg == nil then return end
    local xscale = math.min(1136, MAX_SCREEN_WIDTH) / self.__viewBg:getContentSize().width
    local yscale = MAX_SCREEN_HEIGHT / self.__viewBg:getContentSize().height
    if xscale > yscale then
        self.__viewBg:setScale(xscale)
    else
        self.__viewBg:setScale(yscale)
    end
    self.__viewBg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
end

function CrossBalanceDialog.dtor()

end

return CrossBalanceDialog