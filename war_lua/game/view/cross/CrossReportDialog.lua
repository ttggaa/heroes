--[[
    Filename:    CrossReportDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-23 11:27:47
    Description: File description
--]]


local CrossReportDialog = class("CrossReportDialog",BasePopView)
function CrossReportDialog:ctor(param)
    self.super.ctor(self)
    self._arenaType = param.arenaType
    self._reportList = param.crossPK
end

local jieguoImg = {
    [1] = "arenaReport_win.png",
    [2] = "arenaReport_lose.png",
}

-- 第一次被加到父节点时候调用
function CrossReportDialog:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function CrossReportDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("cross.CrossReportDialog")
    end)

    self._userModel = self._modelMgr:getModel("UserModel")
    self._crossModel = self._modelMgr:getModel("CrossModel")

    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
    -- self._scrollViewH = self._scrollView:getContentSize().height
    self._reportCell = self:getUI("reportCell")
    self._reportCell:setVisible(false)
    -- self._itemW,self._itemH = self._scrollItem:getContentSize().width,self._scrollItem:getContentSize().height

    self._tableData = {}
    self._noneNode = self:getUI("bg.noneNode")
    self._noneNode:setVisible(false)

    self:addTableView()
    self:refreshUI()
end



function CrossReportDialog:progressData()
    local tableData = {}
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local tableList = self._reportList.reports
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
    -- local sortFunc = function(a, b)
    --     atime = a.time
    --     btime = b.time
    --     if atime ~= btime then
    --         return atime > btime 
    --     end
    -- end

    -- table.sort(self._logData, sortFunc)
end

function CrossReportDialog:refreshUI(data)
    -- dump(self._reportList)
    self:progressData()
    -- dump(self._tableData)
    self._tableView:reloadData()
    local noneNode = self:getUI("bg.noneNode")
    if table.nums(self._tableData) ~= 0 then
        noneNode:setVisible(false)
    else
        noneNode:setVisible(true)
    end
end

--[[
用tableview实现
--]]
function CrossReportDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height-10))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(10, 5)
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
function CrossReportDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CrossReportDialog:cellSizeForTable(table,idx) 
    local width = 625 
    local height = 103
    return height, width
end

-- 创建在某个位置的cell
function CrossReportDialog:tableCellAtIndex(table, idx)
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

        local zhandouliLab = cc.LabelBMFont:create("a100", UIUtils.bmfName_zhandouli_little)
        zhandouliLab:setName("zhandouli")
        zhandouliLab:setScale(0.5)
        zhandouliLab:setAnchorPoint(0,0.5)
        zhandouliLab:setPosition(200, 50)
        rankCell:addChild(zhandouliLab, 1000)
        rankCell.zhandouliLab = zhandouliLab

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
function CrossReportDialog:numberOfCellsInTableView(table)
    return #self._tableData
end

function CrossReportDialog:updateCell(inView, indexId)
    local data = self._tableData[indexId]
    dump(data)
    local iconBg = inView:getChildByFullName("itemNode")
    if iconBg then
        local param1 = {avatar = data.avatar, tp = 4,avatarFrame = data["avatarFrame"], level = data.level, plvl = data.plvl}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setScale(0.9)
            icon:setName("icon")
            icon:setPosition(-5, -5)
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local pname = inView:getChildByFullName("itemName")
    if pname then
        local nameStr = data.name
        pname:setString(nameStr)
    end

    local level = inView:getChildByFullName("level")
    if level then
        level:setString("")
    end

    local zhandouliLab = inView.zhandouliLab
    if zhandouliLab then
        zhandouliLab:setString("a" .. data.score)
    end

    local drawImg = inView:getChildByFullName("drawImg")
    local downImg = inView:getChildByFullName("downImg")
    local upImg = inView:getChildByFullName("upImg")
    local resultImgBg = inView:getChildByFullName("resultImgBg")
    drawImg:setVisible(false)
    downImg:setVisible(false)
    upImg:setVisible(false)
    if data.trank == 0 then
        drawImg:setVisible(true)
        -- if data.type == 1 then
        --     resultImgBg:loadTexture("globalImageUI_flagBg_blue.png", 1)
        -- else
        --     resultImgBg:loadTexture("globalImageUI_flagBg_red.png", 1)
        -- end
    else
        if data.type == 1 then
            local diff = inView:getChildByFullName("upImg.diff")
            if diff then
                diff:setString(data.trank)
            end
            upImg:setVisible(true)
            -- resultImgBg:loadTexture("globalImageUI_flagBg_blue.png", 1)
        else
            local diff = inView:getChildByFullName("downImg.diff")
            if diff then
                diff:setString(data.trank)
            end
            downImg:setVisible(true)
            -- resultImgBg:loadTexture("globalImageUI_flagBg_red.png", 1)
        end
    end

    local winImg = inView:getChildByFullName("winImg")
    if data.win == 1 then
        if winImg then
            winImg:loadTexture(jieguoImg[1], 1)
        end
    else
        if winImg then
            winImg:loadTexture(jieguoImg[2], 1)
        end
    end

    local pname = inView:getChildByFullName("itemName")
    local reviewBtn = inView:getChildByFullName("reviewBtn")
    if reviewBtn then
        self:registerClickEvent(reviewBtn, function()
            dump(data)
            local param = {reportKey = data.reportKey}
            self:getBattleReport(param)
        end)
    end
end


function CrossReportDialog:getBattleReport(param)
    self._serverMgr:sendMsg("CrossPKServer", "getBattleReport", param, true, {}, function(result)
        self:reviewTheBattle(result, 1)
    end)  
end


-- 竞技场战斗
function CrossReportDialog:reviewTheBattle(result, replayType)
    if not result then
        return
    end
    local left = self:initBattleData(result.atk)
    local right = self:initBattleData(result.def)
    local rid = result.def.rid
    local reverse = false
    local userid = self._userModel:getData()._id
    if userid == rid then
        reverse = true
    end

    -- 同步名字
    local r1 = result.r1
    local r2 = result.r2
    local replayType = 1
    local fastRes

    BattleUtils.enterBattleView_ServerArena(left, right, r1, r2, replayType, reverse, 
    function(info, callback)
        print("啦啦啦啦11111111啦")
        local crossInfo   = {}
        local myData = self._crossModel:getMyInfo()
        local playRankStr = myData["rank" .. self._arenaType]
        crossInfo.award   = result.reward
        crossInfo.preRank = self._oldRank or playRankStr
        crossInfo.rank    = playRankStr
        info = info
        info.crossInfo = crossInfo

        callback(info, callback)
    end, function(info)
        self:exitBattle()
    end, fastRes)
end

-- 退出战斗
function CrossReportDialog:exitBattle(reportData)

end

function CrossReportDialog:initBattleData(reportData)
    return BattleUtils.jsonData2lua_battleData(reportData)
end

return CrossReportDialog