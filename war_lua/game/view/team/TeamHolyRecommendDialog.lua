--
-- Author: huangguofang
-- Date: 2018-03-07 17:55:11
--
local qualityName = {
    [1] = "白色",
    [2] = "绿色",
    [3] = "蓝色",
    [4] = "紫色",
    [5] = "橙色",
    [6] = "红色",
}

-- 推荐
local TeamHolyRecommendDialog = class("TeamHolyRecommendDialog", BasePopView)

function TeamHolyRecommendDialog:ctor(data)
    TeamHolyRecommendDialog.super.ctor(self)
    self._recommendHoly = data.recommendHoly or {101}
end


function TeamHolyRecommendDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamHolyRecommendDialog")
        end
        self:close()
    end)

    self._sName1 = self:getUI("bg.scrollViewBg.sname1")
    self._sName2 = self:getUI("bg.scrollViewBg.sname2")
    self._sName3 = self:getUI("bg.scrollViewBg.sname3")

    self._fenge1 = self:getUI("bg.scrollViewBg.fenge1")
    self._fenge2 = self:getUI("bg.scrollViewBg.fenge2")
    self._fenge3 = self:getUI("bg.scrollViewBg.fenge3")

    self._richTextBg1 = self:getUI("bg.scrollViewBg.richTextBg1")
    self._richTextBg2 = self:getUI("bg.scrollViewBg.richTextBg2")
    self._richTextBg3 = self:getUI("bg.scrollViewBg.richTextBg3")


    local leftPanel = self:getUI("bg.leftPanel")
    self:registerClickEvent(leftPanel, function()
        -- table.sort(suitData)
        -- local suitData = self:getHolySuitData()
        -- local suitTab = tab.runeClient[suitData[1]]
        -- local param = {suitData = suitTab}
        -- local suitIcon = IconUtils:createHolyIconById(param)
        -- leftPanel:addChild(suitIcon, 20)
        self:updateRightPanel()
    end)

    self._itemCell = self:getUI("itemCell")
    self._itemCell:setVisible(false)

    self._tableData = self:getHolySuitData()
    self._holyId = self._tableData[1].id

    self._tabEventTarget = {}
    for i=1,6 do
        local tab = self:getUI("bg.tab" .. i)
        table.insert(self._tabEventTarget, tab)
    end
    self:updateRightTab(self._tableData[1])

    self._tab1 = self:getUI("bg.tab1")
    self:tabButtonClick(self._tab1, 1)

    -- 类型标志
    local leftPanel = self:getUI("bg.leftPanel")
    local typeImg = ccui.ImageView:create()
    typeImg:loadTexture("TeamHolyUI_typeTxt1.png",1)
    typeImg:setPosition(leftPanel:getContentSize().width * 0.5,55)
    leftPanel:addChild(typeImg)
    self._typeImg = typeImg
    self:updateLeftPanel()

    self:addTableView()
end

function TeamHolyRecommendDialog:getHolySuitData()
    local suitData = {}
    local suitTab = tab.runeClient
    local count = 1
    for k,v in pairs(self._recommendHoly) do
    	if suitTab[v] then
    		table.insert(suitData, suitTab[v])
    	end
    end
    local sortFunc = function(a, b)
        if a.id ~= b.id then
            return a.id < b.id
        else
            return true
        end
    end
    table.sort(suitData, sortFunc)
    return suitData
end

function TeamHolyRecommendDialog:reflashUI(data)
    self._tableView:reloadData()

end

function TeamHolyRecommendDialog:updateLeftPanel()
    local holyId = self._holyId or 101
    local suitTab = tab.runeClient[holyId]
    local suitLab = self:getUI("bg.leftPanel.suitLab")
    local suitIcon = self:getUI("bg.leftPanel.suitIcon")
    local str = lang(suitTab.name)
    suitLab:setString(str)

    local failName = suitTab.icon .. ".png"
    suitIcon:loadTexture(failName, 1)
    self._typeImg:loadTexture("TeamHolyUI_typeTxt" .. (suitTab.type or 1) .. ".png",1)
end

function TeamHolyRecommendDialog:updateRightTab(holyData)
    local qualityNum = (holyData and holyData.showQuality) and holyData.showQuality or {}
    local i = 1
    local isHaveQuality = false
    local tabBtn = self._tab1
    for k,tab in pairs(self._tabEventTarget) do         
        if qualityNum and qualityNum[i] then
            tab:setVisible(true)
            tab.__qualityNum = qualityNum[i]
            tab:setTitleText(qualityName[tab.__qualityNum])
            self:registerClickEvent(tab, function(sender)self:tabButtonClick(sender, tab.__qualityNum) end)
            if not isHaveQuality and self._tabSelect == qualityNum[i] then
                isHaveQuality = true
                tabBtn = tab
            end
        else
            tab:setVisible(false)
        end
        i = i + 1
    end
    if not isHaveQuality then
        self._tabSelect = qualityNum[1]
    end
    return tabBtn
end

function TeamHolyRecommendDialog:updateRightPanel()
    local maxHeight = 0
    local sname1 = self._sName1
    local sname2 = self._sName2
    local sname3 = self._sName3

    sname1:setString("[2件套效果]")
    sname2:setString("[4件套效果]")
    sname3:setString("[6件套效果]")

    local fenge1 = self._fenge1
    local fenge2 = self._fenge2
    local fenge3 = self._fenge3

    local richTextBg1 = self._richTextBg1
    local richTextBg2 = self._richTextBg2
    local richTextBg3 = self._richTextBg3
    -- maxHeight = maxHeight + sname1:getContentSize().height
    -- maxHeight = maxHeight + sname2:getContentSize().height
    -- maxHeight = maxHeight + sname3:getContentSize().height

    -- maxHeight = maxHeight + fenge1:getContentSize().height
    -- maxHeight = maxHeight + fenge2:getContentSize().height
    -- maxHeight = maxHeight + fenge3:getContentSize().height

    local scrollViewBg = self:getUI("bg.scrollViewBg")
    local sheight = scrollViewBg:getContentSize().height
    local rHeight = 10

    local holyId = self._holyId or 101
    local suitId = tonumber(holyId .. "0" .. self._tabSelect)
    local suitTab = tab:Rune(suitId)

    local richtextBg = richTextBg1
    local richText = richtextBg.richText
    if richText then
        richText:removeFromParent()
    end
    local desc = lang(suitTab["des2"])
    if string.find(desc, "color=") == nil then
        desc = "[color=462800]"..desc.."[-]"
    end   
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)
    richtextBg.richText = richText

    local posY = sheight - rHeight
    sname1:setPositionY(posY)
    rHeight = rHeight + sname1:getContentSize().height
    posY = sheight - rHeight
    richTextBg1:setPositionY(posY)
    rHeight = rHeight + richText:getInnerSize().height
    posY = sheight - rHeight
    fenge1:setPositionY(posY)
    rHeight = rHeight + fenge1:getContentSize().height+20

    local richtextBg = richTextBg2
    local richText = richtextBg.richText
    if richText then
        richText:removeFromParent()
    end
    local desc = lang(suitTab["des4"])
    if string.find(desc, "color=") == nil then
        desc = "[color=462800]"..desc.."[-]"
    end   
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)
    richtextBg.richText = richText

    local posY = sheight - rHeight
    sname2:setPositionY(posY)
    rHeight = rHeight + sname2:getContentSize().height
    posY = sheight - rHeight
    richTextBg2:setPositionY(posY)
    rHeight = rHeight + richText:getInnerSize().height
    posY = sheight - rHeight
    fenge2:setPositionY(posY)
    rHeight = rHeight + fenge2:getContentSize().height+20


    local richtextBg = richTextBg3
    local richText = richtextBg.richText
    if richText then
        richText:removeFromParent()
    end
    local desc = lang(suitTab["des6"])
    if string.find(desc, "color=") == nil then
        desc = "[color=462800]"..desc.."[-]"
    end   
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)
    richtextBg.richText = richText

    local posY = sheight - rHeight
    sname3:setPositionY(posY)
    rHeight = rHeight + sname3:getContentSize().height
    posY = sheight - rHeight
    richTextBg3:setPositionY(posY)
    rHeight = rHeight + richText:getInnerSize().height
    posY = sheight - rHeight
    fenge3:setPositionY(posY)
    rHeight = rHeight + fenge3:getContentSize().height

end

function TeamHolyRecommendDialog:refreshTabData(sender, key)
   
    self._tabSelect = sender.__qualityNum or 1   
    self:updateRightPanel()
end

function TeamHolyRecommendDialog:updateCell(inView, indexId, holyData)
    local suitTab = holyData
    local param = {suitData = suitTab}
    local holyId = holyData.id

    local suitIcon = inView.suitIcon
    if not suitIcon then
        suitIcon = IconUtils:createHolyIconById(param)
        suitIcon:setScale(0.88)
        suitIcon:setPosition(0, 2)
        inView:addChild(suitIcon, 20)
        inView.suitIcon = suitIcon
    else
        IconUtils:updateHolyIcon(suitIcon, param)
    end

    local xuanzhong = inView.xuanzhong
    if not xuanzhong then
        xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
        xuanzhong:setName("xuanzhong")
        xuanzhong:setScale(0.85)
        xuanzhong:gotoAndStop(1)
        xuanzhong:setPosition(44, 46)
        inView:addChild(xuanzhong,50)
        inView.xuanzhong = xuanzhong
    end
    if self._holyId == holyId then
        xuanzhong:setVisible(true)
        self._xuanzhong = xuanzhong
    else
        xuanzhong:setVisible(false)
    end

    local clickFlag = false
    local downX
    local posX, posY
    registerTouchEvent(
        suitIcon,
        function(_, x, y)
            downX = x
            clickFlag = false
            -- suitIcon:setBrightness(40)
        end, 
        function(_, x, y)
            if downX and math.abs(downX - x) > 5 then
                clickFlag = true
            end
        end, 
        function(_, x, y)
            -- suitIcon:setBrightness(0)
            if clickFlag == false then 
                -- print("self._holyId===========", self._holyId)
                if self._xuanzhong then
                    self._xuanzhong:setVisible(false)
                end
                self._holyId = holyId
                self:updateCell(inView, indexId, holyData)
                -- self._tabSelect = 1
                local selectBtn = self:updateRightTab(holyData)
                self:tabButtonClick(selectBtn, self._tabSelect)
                self:updateLeftPanel()
            end
        end,
        function(_, x, y)
            -- suitIcon:setBrightness(0)
        end)
    suitIcon:setSwallowTouches(false)
end

function TeamHolyRecommendDialog:setButtonEvent(holyId)

end

--[[
用tableview实现
--]]
function TeamHolyRecommendDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    local theight = tableViewBg:getContentSize().height+100
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, theight))
    self._tableView:setDelegate()
    self._tableView:setDirection(0)
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
function TeamHolyRecommendDialog:numberOfCellsInTableView(table)
   return self:getTableNum()
end

function TeamHolyRecommendDialog:getTableNum()
   return table.nums(self._tableData)
end

-- cell的尺寸大小
function TeamHolyRecommendDialog:cellSizeForTable(table,idx) 
    local width = 95 
    local height = 86
    return height, width
end

-- 创建在某个位置的cell
function TeamHolyRecommendDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    local param = self._tableData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local listCell = self._itemCell:clone()
        listCell:setName("listCell")
        listCell:setVisible(true)
        listCell:setAnchorPoint(0, 0)
        listCell:setPosition(5, 0)
        cell:addChild(listCell)
    end

    local listCell = cell:getChildByName("listCell")
    self:updateCell(listCell, indexId, param)
    listCell:setSwallowTouches(false)

    return cell
end


function TeamHolyRecommendDialog:tabButtonClick(sender, key)
   if sender == nil then 
        print("==sender is nil============")
        return 
    end
    -- if self._tabName == sender:getName() then 
    --     return 
    -- end
    for k,v in pairs(self._tabEventTarget) do
        self:tabButtonState(v, false)
    end
    self:tabButtonState(sender, true)
    self:refreshTabData(sender, key)
    audioMgr:playSound("Tab")
end


-- 选项卡状态切换
function TeamHolyRecommendDialog:tabButtonState(sender, isSelected)
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

function TeamHolyRecommendDialog.dtor()
    qualityName = nil
end
return TeamHolyRecommendDialog