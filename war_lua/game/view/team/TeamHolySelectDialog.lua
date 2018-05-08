--[[
    Filename:    TeamHolySelectDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-16 10:44:51
    Description: File description
--]]

-- 选择宝石
local TeamHolySelectDialog = class("TeamHolySelectDialog", BasePopView)
local classType = {
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 4,
    [6] = 5,
}

function TeamHolySelectDialog:ctor(param)
    TeamHolySelectDialog.super.ctor(self)
    self._breakData = {}
    self._selectQuality = {}
    self._callback = param.callback
    self._selType = param.selType or 1 
    self._stoneKey = param.stoneKey or 10101
end

function TeamHolySelectDialog:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")

    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamHolySelectDialog")
        end
        self:close()
    end)

    local breakBtn = self:getUI("bg.breakBtn")
    self:registerClickEvent(breakBtn, function()
        -- self._callback()
        -- local stoneData = self._teamModel:getHolyDataByKey(self._stoneKey)
        -- local holyId = stoneData.id
        -- local data = self._teamModel:getStuffDataNoUse(holyId)
        -- local param = {id = self._stoneKey, useIds = data[2]}

        -- local x = 1
    end)

    self._breakLab = self:getUI("bg.rightBg.breakLab")
    self._nothing = self:getUI("bg.nothing")
    self._nothing:setVisible(false)

    self._tabEventTarget = {}
    for i=1,6 do
        local tab = self:getUI("bg.tab" .. i)
        table.insert(self._tabEventTarget, tab)
        self:registerClickEvent(tab, function(sender)self:tabButtonClick(sender, 1) end)
    end

    self._stoneId = 10101

    self._itemCell = self:getUI("itemCell")
    self._itemCell:setVisible(false)
    self:addTableView()

    local tab1 = self:getUI("bg.tab1")
    self:tabButtonClick(tab1, 1)

    -- self._tableData = self._teamModel:getHolyBreakData()
    -- self._holyId = self._tableData[1]

end

function TeamHolySelectDialog:reflashUI(data)
    -- self._tableView:reloadData()

end

function TeamHolySelectDialog:reloadData()
    print("sender=====6666666666====")
    local _type = classType[self._tabSelect]
    dump(_type, "_type===========", 10)
    print("_type==================", _type)

    self._useStone = self._teamModel:getTeamUseHolyData()
    
    if self._selType == 1 then -- 选择宝石
        self._tableData = self._teamModel:getHolyDataAllByType(_type)
    elseif self._selType == 2 then -- 选择材料
        self._tableData = self._teamModel:getStuffData(self._stoneKey, _type)
    elseif self._selType == 3 then -- 觉醒选择
        self._tableData = self._teamModel:getAwakingData(_type)
    end
    self._tableView:reloadData()
    if table.nums(self._tableData) == 0 then
        self._nothing:setVisible(true)
    else
        self._nothing:setVisible(false)
    end
end


-- function TeamHolySelectDialog:updateRightPanel()
--     local holyId = self._holyId or 101
--     local suitTab = tab.runeClient[holyId]
--     local suitLab = self:getUI("bg.leftPanel.suitLab")
--     local suitIcon = self:getUI("bg.leftPanel.suitIcon")
--     local str = lang(suitTab.name)
--     suitLab:setString(str)

--     local failName = suitTab.icon .. ".png"
--     suitIcon:loadTexture(failName, 1)
-- end

function TeamHolySelectDialog:refreshTabData(sender, key)
    if sender:getName() == "tab1" then
        self._tabSelect = 1
        
    elseif sender:getName() == "tab2" then 
        self._tabSelect = 2

    elseif sender:getName() == "tab3" then 
        self._tabSelect = 3

    elseif sender:getName() == "tab4" then 
        self._tabSelect = 4

    elseif sender:getName() == "tab5" then 
        self._tabSelect = 5

    elseif sender:getName() == "tab6" then 
        self._tabSelect = 6
    end
    self:reloadData()
end

function TeamHolySelectDialog:updateCell(inView, indexLine)    
    for i=1,2 do
        local listCell = inView["listCell" .. i]
        if listCell then
            local indexId = (indexLine-1)*2+i
            local holyId = self._tableData[indexId]
            if holyId then
                listCell:setVisible(true)
                self:updateStoneCell(listCell, indexId, i)
            else
                listCell:setVisible(false)
            end
        end
    end
end

function TeamHolySelectDialog:updateStoneCell(inView, indexId, verticalId)
    local stoneData = self._tableData[indexId]
    local stoneId = stoneData.id
    local key = stoneData.key

    local suitIcon = inView["suitIcon"]
    local stoneTab = tab.rune[stoneId]
    local param = {suitData = stoneTab}
    if not suitIcon then
        suitIcon = IconUtils:createHolyIconById(param)
        suitIcon:setScale(0.7)
        suitIcon:setPosition(5, 5)
        inView:addChild(suitIcon, 20)
        inView["suitIcon"] = suitIcon
    else
        IconUtils:updateHolyIcon(suitIcon, param)
    end

    local useStone = self._useStone
    local teamId = self._useStone[key]
    local teamIcon = inView["teamIcon"]
    if teamId then
        local inTeamData = self._teamModel:getTeamAndIndexById(teamId)
        local backQuality = self._teamModel:getTeamQualityByStage(inTeamData.stage)
        local teamTab = tab:Team(teamId)
        local param = {teamData = inTeamData, sysTeamData = teamTab,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0}
        if not teamIcon then 
            teamIcon = IconUtils:createTeamIconById(param)
            teamIcon:setName("teamIcon")
            teamIcon:setPosition(213,10)
            teamIcon:setAnchorPoint(0, 0)
            teamIcon:setScale(0.35)
            inView:addChild(teamIcon)
            inView["teamIcon"] = teamIcon
        else
            IconUtils:updateTeamIconByView(teamIcon, param)
        end
        teamIcon:setVisible(true)
    else
        if teamIcon then
            teamIcon:setVisible(false)
        end
    end

    local sName = inView:getChildByName("sName")
    if sName then
        local str = lang(stoneTab.name)
        sName:setString(str)
    end

    local cellBg = inView:getChildByName("cellBg")
    local selBtn = inView:getChildByName("selBtn")
    if selBtn then
        if self._breakData[key] then
            selBtn:setVisible(true)
            cellBg:loadTexture("globalPanelUI7_cellBg20.png", 1)
        else
            selBtn:setVisible(false)
            cellBg:loadTexture("globalPanelUI7_cellBg21.png", 1)
        end
    end

    self:registerClickEvent(suitIcon, function()
        print("调用tips")
    end)

    local clickFlag = false
    local downX, downY
    local posX, posY
    registerTouchEvent(
        inView,
        function(_, x, y)
            downY = y
            clickFlag = false
            -- inView:setBrightness(40)
        end, 
        function(_, x, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function(_, x, y)
            -- inView:setBrightness(0)
            if clickFlag == false then 
                -- dump(stoneData)
                self._callback(stoneData.key)
                self:close()
                -- print("self._useStone[key]=======", self._useStone[key])
                -- if not self._breakData[key] then
                --     self._breakData[key] = 1
                --     self:updateStoneCell(inView, indexId, verticalId)                    
                -- else
                --     self._breakData[key] = nil
                --     self:updateStoneCell(inView, indexId, verticalId)
                -- end
            end
        end,
        function(_, x, y)
            -- inView:setBrightness(0)
        end)
    inView:setSwallowTouches(false)
end

--[[
用tableview实现
--]]
function TeamHolySelectDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    local theight = tableViewBg:getContentSize().height
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, theight))
    self._tableView:setDelegate()
    self._tableView:setDirection(1)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, 0)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    tableViewBg:addChild(self._tableView)
end

-- 返回cell的数量
function TeamHolySelectDialog:numberOfCellsInTableView(table)
   return self:getTableNum()
end

function TeamHolySelectDialog:getTableNum()
    local tabNum = math.ceil(table.nums(self._tableData)/2)
    return tabNum -- 
end

-- cell的尺寸大小
function TeamHolySelectDialog:cellSizeForTable(table,idx) 
    local width = 520 
    local height = 85
    return height, width
end

-- 创建在某个位置的cell
function TeamHolySelectDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        for i=1,2 do
            local listCell = self._itemCell:clone()
            listCell:setName("listCell" .. i)
            listCell:setVisible(true)
            listCell:setAnchorPoint(0, 0)
            if i == 2 then
                listCell:setPosition(265, 3)
            else
                listCell:setPosition(0, 3)
            end
            cell:addChild(listCell)
            cell["listCell" .. i] = listCell
        end
    end

    self:updateCell(cell, indexId)
    return cell
end


function TeamHolySelectDialog:tabButtonClick(sender, key)
   if sender == nil then 
        print("==sender is nil============")
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        self:tabButtonState(v, false)
    end
    self:tabButtonState(sender, true)
    self:refreshTabData(sender, key)
    audioMgr:playSound("Tab")
end


-- 选项卡状态切换
function TeamHolySelectDialog:tabButtonState(sender, isSelected)
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    if isSelected then
        sender:setTitleColor(cc.c3b(255,238,160))
        sender:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    else
        sender:setTitleColor(cc.c3b(163,117,86))
        sender:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- sender:getTitleRenderer():enableOutline(cc.c4b(30, 75, 172, 178), 2)
    end
end

return TeamHolySelectDialog
