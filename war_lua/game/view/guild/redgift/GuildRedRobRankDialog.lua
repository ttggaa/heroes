--[[
    Filename:    GuildRedRobRankDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-15 15:57:51
    Description: File description
--]]


local GuildRedRobRankDialog = class("GuildRedRobRankDialog", BasePopView)

function GuildRedRobRankDialog:ctor(param)
    GuildRedRobRankDialog.super.ctor(self)
    self._redRank = {}
    self._param = param
end


function GuildRedRobRankDialog:onInit()
    -- local Image_26 = self:getUI("bg.Image_26")
    -- Image_26:setColor(cc.c4b(66, 64, 66, 255))

    
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    -- title:setFontName(UIUtils.ttfName)
    local headTitle = self:getUI("bg.headBg.title")
    UIUtils:setTitleFormat(headTitle, 2)
    -- headTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local num = self:getUI("bg.headBg.num")
    num:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    -- title:setColor(cc.c3b(250, 242, 192))
    -- title:enable2Color(1, cc.c4b(255, 195, 17, 255))
    -- title:enableOutline(cc.c4b(60, 30, 10, 255), 2)

    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.redgift.GuildRedRobRankDialog")
        end
        self:close()
    end)

    self._rankCell = self:getUI("rankCell")
    self._rankCell:setVisible(false)

    self:addTableView()

    -- dump(self._param,"self._param",10)
    if self._param and self._param.redData and self._param.redData.robRed == 2 then
        self._viewMgr:showTip("该红包已被抢光")
    end

end

function GuildRedRobRankDialog:reflashUI(data)
    -- dump(data, "RobRank", 10)
    self._redRank = data.redRank
    self._redData = data.redData
    self._redType = data.redType
    self._tableView:reloadData()

    local nameValue, numValue, robNumValue, timesValue, donateValue, redIconValue,typeImage

    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    -- local dayHour = TimeUtils.getDateString(curServerTime,"%Y-%m-%d")
    -- self._todayDate = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m%d%H"))
    -- self._yearMonth = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m"))

    local numTotal = 1
    if self._redType == 1 then
        nameValue = "联盟管理员"
        local redTab = tab:GuildRed(self._redData["id"])
        numValue = (redTab["people"] - self._redData.rob) .. "/" .. redTab["people"]
        numTotal = tonumber(redTab["people"])
        if redTab["type"] == "gold" then
            redIconValue = 1
            typeImage = "red_huangjin.png"
        elseif redTab["type"] == "gem" then
            redIconValue = 2
            typeImage = "red_zuanshi.png"
        elseif redTab["type"] == "treasureCoin" then
            redIconValue = 3
            typeImage = "red_baowu.png"
        end
        robNumValue = redTab["reward"][3]
        if self._redData.rob < redTab["people"] then
            timesValue = 0
        else
            local timeSub = self._redData.eTime - self._redData.cTime
            local hour = math.floor(timeSub/3600)
            local minute = math.floor((timeSub - hour*3600)/60)
            local second = timeSub - hour*3600 - minute*60
            if hour ~= 0 then
                timesValue = hour .. "时" .. minute .. "分" .. second .. "秒"
            elseif hour == 0 and minute ~= 0 then
                timesValue = minute .. "分" .. second .. "秒"
            else
                timesValue = second .. "秒"
            end
        end

        donateValue = TimeUtils.getDateString(self._redData.cTime,"%Y-%m-%d")
    else
        local redTab = tab:GuildUserRed(self._redData["id"])
        nameValue = self._redData["name"]
        numValue = (redTab["people"] - self._redData.rob) .. "/" .. redTab["people"]
        numTotal = tonumber(redTab["people"])
        if redTab["type"] == "gold" then
            redIconValue = 1
            typeImage = "red_huangjin.png"
        elseif redTab["type"] == "gem" then
            redIconValue = 2
            typeImage = "red_zuanshi.png"
        elseif redTab["type"] == "treasureCoin" then
            redIconValue = 3
            typeImage = "red_baowu.png"
        end
        robNumValue = redTab["give"][3]
        if self._redData.rob < redTab["people"] then
            timesValue = 0
        else
            local timeSub = self._redData.eTime - self._redData.cTime
            local hour = math.floor(timeSub/3600)
            local minute = math.floor((timeSub - hour*3600)/60)
            local second = timeSub - hour*3600 - minute*60
            if hour ~= 0 then
                timesValue = hour .. "时" .. minute .. "分" .. second .. "秒"
            elseif hour == 0 and minute ~= 0 then
                timesValue = minute .. "分" .. second .. "秒"
            else
                timesValue = second .. "秒"
            end
        end
        donateValue = TimeUtils.getDateString(self._redData.cTime,"%Y-%m-%d")
    end

    local name = self:getUI("bg.headBg.name")
    local num = self:getUI("bg.headBg.num")

    local redIconType = self:getUI("bg.headBg.redType")
    local robNum = self:getUI("bg.headBg.robNum")
    local times = self:getUI("bg.headBg.times")
    local date = self:getUI("bg.headBg.date")

    name:setString("来自:" .. nameValue)
    -- local numTotal = tonumber(redTab["people"])
    numValue = (numTotal - self:tableNum()) .. "/" .. numTotal
    num:setString(numValue)
    redIconType:loadTexture("allicance_redziyuan" .. redIconValue .. ".png", 1)
    robNum:setString(robNumValue)
    if tonumber(timesValue) == 0 then
        times:setVisible(false)
    else
        times:setVisible(true)
        times:setString(timesValue .. "被抢光")
    end
    if date then
        date:setVisible(false)
        date:setString(donateValue)
    end
    

    --by wangyan 
    local titleName = {
        [1] = "黄金",
        [2] = "高级黄金",
        [3] = "钻石",
        [4] = "高级钻石",
        [5] = "宝物",
        [6] = "高级宝物",
    }
    local titleSysName = {
        [1] = "黄金",
        [2] = "钻石",
        [3] = "宝物",
    }
    local headTitle = self:getUI("bg.headBg.title")
    if tonumber(self._redData.id) > 6 then
        headTitle:setString(titleSysName[redIconValue] .. "红包")
    else
        headTitle:setString(titleName[self._redData.id] .. "红包")
    end
    
    local nameIcon = self:getUI("bg.headBg.redGift.name")
    nameIcon:loadTexture(typeImage, 1)
    -- local giftIcon = self:getUI("bg.headBg.redGift.gift")
    -- giftIcon:loadTexture(typeImage, 1)
end


--[[
用tableview实现
--]]
function GuildRedRobRankDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height - 30))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 15))
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
function GuildRedRobRankDialog:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildDetailDialog")
end

-- cell的尺寸大小
function GuildRedRobRankDialog:cellSizeForTable(table,idx) 
    local width = 340 
    local height = 34
    return height, width
end

-- 创建在某个位置的cell
function GuildRedRobRankDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    local param

    param = {rankData = self._redRank[indexId], indexId = indexId}
    if nil == cell then
        cell = cc.TableViewCell:new()
        local rankCell = self._rankCell:clone() -- self._viewMgr:createLayer("guild.GuildInCell")
        rankCell:setAnchorPoint(cc.p(0, 0))
        rankCell:setPosition(cc.p(0, 0))
        rankCell:setName("rankCell")
        rankCell:setVisible(true)
        cell:addChild(rankCell)

        self:updateCell(rankCell, param)
        -- rankCell:setSwallowTouches(false)
    else
        local rankCell = cell:getChildByName("rankCell")
        rankCell:setVisible(true)
        if rankCell then
            self:updateCell(rankCell, param)
            -- rankCell:setSwallowTouches(false)
        end
    end
    
    local _cellBgImg = cell:getChildByFullName("rankCell.cellBgImg")
    _cellBgImg:setVisible(math.fmod(idx, 2) == 0)

    return cell
end

-- 返回cell的数量
function GuildRedRobRankDialog:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function GuildRedRobRankDialog:tableNum()
    return table.nums(self._redRank)
end

function GuildRedRobRankDialog:updateCell(inView, data)
    if data["rankData"] == nil then
        return
    end

    local good = inView:getChildByFullName("good")
    if data.indexId == 1 then
        good:setVisible(true)
    else
        good:setVisible(false)
    end

    local rankData = data["rankData"]

    -- local userId = self._modelMgr:getModel("UserModel"):getData()["_id"]
    -- -- dump (userId, "data ================")
    -- local selfTag = inView:getChildByFullName("selfTag")
    -- if selfTag then
    --     if userId == rankData["rid"] then
    --         selfTag:setVisible(true)
    --     else
    --         selfTag:setVisible(false)
    --     end
    -- end

    local redTab, redIconValue
    if self._redType == 1 then
        redTab = tab:GuildRed(self._redData["id"])
    else
        redTab = tab:GuildUserRed(self._redData["id"])
    end

    if redTab["type"] == "gold" then
        redIconValue = 1
    elseif redTab["type"] == "gem" then
        redIconValue = 2
    elseif redTab["type"] == "treasureCoin" then
        redIconValue = 3
    end
    local redType = inView:getChildByFullName("redType")
    if redType then
        redType:loadTexture("allicance_redziyuan" .. redIconValue .. ".png", 1)
    end

    local nameLab = inView:getChildByFullName("nameLab")
    if nameLab then
        nameLab:setString(rankData.name)
    end

    local redRobNum = inView:getChildByFullName("redRobNum")
    if redRobNum then
        redRobNum:setString(rankData.score)
    end

    for i=1,3 do
        local rankImg = inView:getChildByFullName("rankImg" .. i)
        if rankImg then
            rankImg:setVisible(false)
        end
    end
end


return GuildRedRobRankDialog