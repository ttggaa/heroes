--[[
    Filename:    CrossDefDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-13 16:20:47
    Description: File description
--]]

-- 防守信息
local CrossDefDialog = class("CrossDefDialog", BasePopView)

local jieguoImg = {
    [1] = "arenaReport_win.png",
    [2] = "arenaReport_lose.png",
}

function CrossDefDialog:ctor(param)
    CrossDefDialog.super.ctor(self)
    self._arenaType = param.arenaType
end

function CrossDefDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("cross.CrossDefDialog")
        end
        self:close()
    end)

    self._crossModel = self._modelMgr:getModel("CrossModel")


    local bg = self:getUI("bg.bg")
    bg:loadTexture("asset/bg/crossbg3.png", 0)

    self._reportCell = self:getUI("bg.reportCell")
    self._reportCell:setVisible(false)

    local cancelBtn = self:getUI("bg.cancelBtn")
    self:registerClickEvent(cancelBtn, function()
        self:close()
    end)

    local reportBtn = self:getUI("bg.reportBtn")
    self:registerClickEvent(reportBtn, function()
        local param = {region = self._arenaType}
        self._serverMgr:sendMsg("CrossPKServer", "getReports", param, true, {}, function(result) 
            UIUtils:reloadLuaFile("cross.CrossReportDialog")
            self._viewMgr:showDialog("cross.CrossReportDialog", {crossPK = result["d"]["crossPK"], arenaType = self._arenaType})
            self:close()
        end)
    end)

    self._richtextBg = self:getUI("bg.richtextBg")

    self:addTableView()

    self:refreshUI()
end

function CrossDefDialog:progressData()
    local tableData = {}
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local tableList = self._crossModel:getDefReport()
    local arenaData = self._crossModel:getData()
    local arenaId = arenaData["regiontype" .. self._arenaType]
    local npcName = lang("cp_npcName" .. arenaId)
    for k,v in pairs(tableList) do
        local tListData = {}
        if userData._id == v.atkId then
            tListData.avatar = v.defAvatar
            tListData.avatarFrame = v.defAvatarFrame
            tListData.rid = v.defId
            tListData.level = v.defLvl or 0
            tListData.name = v.defName
            tListData.rank = v.defRank
            tListData.score = v.defScore
            tListData.secName = v.defSec
            tListData.vipLvl = v.defVip or 0
            tListData.type = 1
            tListData.win = 0
            tListData.trank = 0
            if v.win == true then
                local rank1 = v.atkRank
                local rank2 = v.defRank
                if rank1 > rank2 then
                    tListData.trank = rank1 - rank2
                else
                    tListData.trank = 0
                end
                tListData.win = 1
            end
        elseif userData._id == v.defId then
            tListData.avatar = v.atkAvatar
            tListData.avatarFrame = v.atkAvatarFrame
            tListData.rid = v.atkId
            tListData.level = v.atkLvl or 0
            tListData.name = v.atkName
            tListData.rank = v.atkRank
            tListData.score = v.atkScore
            tListData.secName = v.atkSec
            tListData.vipLvl = v.atkVip or 0
            tListData.type = 2
            tListData.trank = 0 
            if v.win == true then
                tListData.win = 0
                local rank1 = v.atkRank
                local rank2 = v.defRank
                if rank1 > rank2 then
                    tListData.trank = rank2 - rank1
                else
                    tListData.trank = 0 
                end
            else
                tListData.win = 1
            end
        end
        if tListData.name == "" then
            tListData.name = npcName
        end
        tListData.time = v.time
        tListData.region = v.region
        tListData.reportKey = v.reportKey
        tableData[k] = tListData
    end
    self._tableData = tableData
end

function CrossDefDialog:getRankNum()
    local playNum = 0
    local dropNum = 0
    for k,v in pairs(self._tableData) do
        if v.type == 2 then
            playNum = playNum + 1
            dropNum = dropNum + v.trank
        end
    end
    local playRank = playNum - dropNum
    return playNum, dropNum, playRank
end

function CrossDefDialog:refreshUI()
    self:progressData()
    dump(self._tableData)
    self._tableView:reloadData()

    local myData = self._crossModel:getMyInfo()
    local rankNum = myData["rank" .. self._arenaType]
    local playNum, dropNum, playRank = self:getRankNum()
    print("playNum, dropNum==========", playNum, dropNum, playRank)

    local richtextBg = self._richtextBg
    local desc = lang("cp_windef")
    if dropNum ~= 0 then
        desc = lang("cp_losedef")
        desc = string.gsub(desc, "{$rank}", rankNum)
        desc = string.gsub(desc, "{$loserank}", dropNum)
    end
    desc = string.gsub(desc, "{$number}", playNum)
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height + 5)
    richText:setName("richText")
    richtextBg:addChild(richText)
-- CrossDefDialog
end


--[[
用tableview实现
--]]
function CrossDefDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    print("MAX_SCREEN_HEIGHT=============", MAX_SCREEN_HEIGHT)
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    -- self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView, 1)
end


-- 触摸时调用
function CrossDefDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CrossDefDialog:cellSizeForTable(table,idx) 
    local width = 760 
    local height = 50
    return height, width
end

-- 创建在某个位置的cell
function CrossDefDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local rankCell = self._reportCell:clone() 
        rankCell:setVisible(true)
        rankCell:setAnchorPoint(0,0)
        rankCell:setPosition(0,0)
        rankCell:setName("rankCell")
        cell:addChild(rankCell)
        cell.rankCell = rankCell

        self:updateCell(rankCell, indexId)
        rankCell:setSwallowTouches(false)
    else
        local rankCell = cell.rankCell
        -- local rankCell = cell:getChildByName("rankCell")
        if rankCell then
            self:updateCell(rankCell, indexId)
            rankCell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function CrossDefDialog:numberOfCellsInTableView(table)
    return #self._tableData
end

function CrossDefDialog:updateCell(inView, indexId)
    local data = self._tableData[indexId]
    local pname = inView:getChildByFullName("pname")
    if pname then
        local nameStr = data.name
        pname:setString(nameStr)
    end

    local secName = inView:getChildByFullName("secName")
    if secName then
        local sec = data.secName
        local nameStr = self._crossModel:getServerName(sec)
        secName:setString(nameStr)
    end

    local drawImg = inView:getChildByFullName("drawImg")
    local downImg = inView:getChildByFullName("downImg")
    local upImg = inView:getChildByFullName("upImg")
    drawImg:setVisible(false)
    downImg:setVisible(false)
    upImg:setVisible(false)
    if data.trank == 0 then
        drawImg:setVisible(true)
    else
        if data.type == 1 then
            local diff = inView:getChildByFullName("upImg.diff")
            if diff then
                diff:setString(data.trank)
            end
            upImg:setVisible(true)
        else
            local diff = inView:getChildByFullName("downImg.diff")
            if diff then
                diff:setString(data.trank)
            end
            downImg:setVisible(true)
        end
    end

    local jieguo = inView:getChildByFullName("jieguo")
    if data.win == 1 then
        if jieguo then
            jieguo:loadTexture(jieguoImg[1], 1)
        end
    else
        if jieguo then
            jieguo:loadTexture(jieguoImg[2], 1)
        end
    end
end


return CrossDefDialog