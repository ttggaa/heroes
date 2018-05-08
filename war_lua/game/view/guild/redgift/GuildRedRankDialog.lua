--[[
    Filename:    GuildRedRankDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-15 15:57:09
    Description: File description
--]]

local GuildRedRankDialog = class("GuildRedRankDialog", BasePopView)

function GuildRedRankDialog:ctor(param)
    GuildRedRankDialog.super.ctor(self)
    self._redSendRank = {}
    self._redRobRank = {}
    self._redType = param.redType
end


function GuildRedRankDialog:onInit()
    -- local Image_26 = self:getUI("bg.Image_26")
    -- Image_26:setColor(cc.c4b(66, 64, 66, 255))
    if self._redType == 1 then
        self:getGuildUserSendRedRank()
    else
        self:getHistroyUserRobRank()
    end
    
    local title = self:getUI("bg.titleBg.title")
    -- UIUtils:setTitleFormat(title, 4)
    -- title:setFontName(UIUtils.ttfName)
    -- title:setFontSize(30)
    -- title:setColor(cc.c3b(250, 242, 192))
    -- title:enable2Color(1, cc.c4b(255, 195, 17, 255))
    -- title:enableOutline(cc.c4b(90, 44, 0, 255), 2)

    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.redgift.GuildRedRankDialog")
        end
        self:close()
    end)

    self._rankCell = self:getUI("rankItem")
    self._rankCell:setVisible(false)

    self:addTableView()

end

function GuildRedRankDialog:reflashUI(data)
    local title = self:getUI("bg.titleBg.title")
    local des3 = self:getUI("bg.titleBg.des3")
    local nothing = self:getUI("bg.nothing.noneLabel")
    if self._redType == 1 then
        nothing:setString("暂无发放的红包")
        title:setString("发红包排行")
        des3:setString("总值")
    else
        nothing:setString("暂无可抢夺的红包")
        title:setString("抢红包排行")
        des3:setString("数量")
    end


end


--[[
用tableview实现
--]]
function GuildRedRankDialog:addTableView()
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
function GuildRedRankDialog:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildDetailDialog")
end

-- cell的尺寸大小
function GuildRedRankDialog:cellSizeForTable(table,idx) 
    local width = 537 
    local height = 93
    return height, width
end

-- 创建在某个位置的cell
function GuildRedRankDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    local param

    if self._redType == 1 then
        param = {rankData = self._redSendRank[indexId], indexId = indexId}
    else
        param = {rankData = self._redRobRank[indexId], indexId = indexId}
    end
    if nil == cell then
        cell = cc.TableViewCell:new()
        local rankCell = self._rankCell:clone() -- self._viewMgr:createLayer("guild.GuildInCell")
        rankCell:setVisible(true)
        rankCell:setAnchorPoint(cc.p(0, 0))
        rankCell:setPosition(cc.p(8, 0))
        rankCell:setName("rankCell")
        cell:addChild(rankCell)


        -- local UIscoreLab = rankCell:getChildByFullName("scoreLab")
        -- UIscoreLab:setVisible(false)
        -- local scoreLab = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
        -- scoreLab:setAnchorPoint(cc.p(0.1, 0.5))
        -- scoreLab:setName("scoreLab1")
        -- scoreLab:setScale(0.8)
        -- scoreLab:setPosition(UIscoreLab:getPosition())
        -- UIscoreLab:getParent():addChild(scoreLab,1)

        -- local nameLab = rankCell:getChildByFullName("nameLab")
        -- nameLab:setFontName(UIUtils.ttfName)
        -- nameLab:enableOutline(cc.c4b(11, 48, 71, 255), 2) 

        -- local levelLab = rankCell:getChildByFullName("levelLab")
        -- levelLab:setFontName(UIUtils.ttfName)
        -- levelLab:enableOutline(cc.c4b(61, 37, 17, 255), 2) 

        local rankLab = rankCell:getChildByFullName("rankLab")
        -- rankLab:setPosition(60, 52)
        -- rankLab:setFntFile(UIUtils.bmfName_rank)
        -- rankLab:enableOutline(cc.c4b(3, 2, 0, 255), 2) 
        -- rankLab:setColor(cc.c3b(250, 250, 58))
        -- rankLab:enable2Color(1, cc.c4b(239, 149, 52, 255))
        -- rankLab:setFontSize(48)

        self:updateCell(rankCell, param)
        -- rankCell:setSwallowTouches(false)
    else
        local rankCell = cell:getChildByName("rankCell")
        if rankCell then
            self:updateCell(rankCell, param)
            -- rankCell:setSwallowTouches(false)
        end
    end
    return cell
end

-- 返回cell的数量
function GuildRedRankDialog:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function GuildRedRankDialog:tableNum()
    local rankNum = 0
    if self._redType == 1 then
        rankNum = table.nums(self._redSendRank)
    else
        rankNum = table.nums(self._redRobRank)
    end
    return rankNum
end

function GuildRedRankDialog:updateCell(inView, data)
    if data["rankData"] == nil then
        return
    end

    -- dump (data, "data ================")
    local rankData = data["rankData"]

    local userId = self._modelMgr:getModel("UserModel"):getData()["_id"]
    -- dump (userId, "data ================")
    local selfTag = inView:getChildByFullName("selfTag")
    if selfTag then
        if userId == rankData["rid"] then
            selfTag:setVisible(true)
        else
            selfTag:setVisible(false)
        end
    end

    -- if inView then
    --     if userId == rankData["_id"] then
    --         inView:loadTexture("allianceScicene_img7.png", 1)
    --     else
    --         inView:loadTexture("globalPanelUI5_cellBg.png", 1)
    --     end
    -- end
    -- -- 头像
    -- -- local iconBg = self:getUI("bg.iconBg")
    -- local headNode = inView:getChildByName("headNode")
    -- local avatarIcon = headNode:getChildByName("avatarIcon")
    -- local param = {flags = rankData.avatar1 or 101, logo = rankData.avatar2 or 201}
    -- if not avatarIcon then
    --     avatarIcon = IconUtils:createGuildLogoIconById(param)
    --     avatarIcon:setName("avatarIcon")
    --     avatarIcon:setScale(0.6)
    --     avatarIcon:setPosition(cc.p(5, 5))
    --     headNode:addChild(avatarIcon)
    -- else
    --     IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    -- end

    local nameLab = inView:getChildByFullName("nameLab")
    if nameLab then
        nameLab:setString(rankData.name)
    end

    local scoreLab = inView:getChildByFullName("scoreLab")
    if scoreLab then
        scoreLab:setString(rankData.gemValue)
    end

    local rankLab = inView:getChildByFullName("rankLab")
    if rankLab then
        rankLab:setString(rankData.rank)
        rankLab:setVisible(false)
    end

    for i=1,3 do
        local rankImg = inView:getChildByFullName("rankImg" .. i)
        if rankImg then
            rankImg:setVisible(false)
        end
    end

    local rankItemBg = inView:getChildByFullName("rankItemBg")
    -- rankItemBg:loadTexture("arenaRankUI_cellBg4.png", 1)
    

    if rankData.rank == 1 then
        -- rankItemBg:loadTexture("arenaRankUI_cellBg1.png", 1)
        local rankImg = inView:getChildByFullName("rankImg1")
        if rankImg then
            rankImg:setVisible(true)
        end
    elseif rankData.rank == 2 then
        -- rankItemBg:loadTexture("arenaRankUI_cellBg2.png", 1)
        local rankImg = inView:getChildByFullName("rankImg2")
        if rankImg then
            rankImg:setVisible(true)
        end
    elseif rankData.rank == 3 then
        -- rankItemBg:loadTexture("arenaRankUI_cellBg3.png", 1)
        local rankImg = inView:getChildByFullName("rankImg3")
        if rankImg then
            rankImg:setVisible(true)
        end
    else
        if rankLab then
            rankLab:setVisible(true)
        end
    end
    -- rankItemBg:setCapInsets(cc.rect(165, 0, 1, 1))


end

-- 获取工会玩家发红包额度排行
function GuildRedRankDialog:getGuildUserSendRedRank()
    self._serverMgr:sendMsg("GuildRedServer", "getGuildUserSendRedRank", {}, true, {}, function (result)
        self:getGuildUserSendRedRankFinish(result)
    end)
end 

function GuildRedRankDialog:getGuildUserSendRedRankFinish(result)
    if result == nil then 
        return 
    end
    -- dump(result, "senderProcessData==============")

    self._redSendRank = result
    self:senderProcessData(self._redSendRank)
    if table.nums(self._redSendRank) == 0 then
        local nothing = self:getUI("bg.nothing")
        nothing:setVisible(true)
    else
        local nothing = self:getUI("bg.nothing")
        nothing:setVisible(false)
    end
    self._tableView:reloadData()
end

-- 获取玩家抢红包历史排行
function GuildRedRankDialog:getHistroyUserRobRank()
    self._serverMgr:sendMsg("GuildRedServer", "getHistroyUserRobRank", {}, true, {}, function (result)
        self:getHistroyUserRobRankFinish(result)
    end)
end 

function GuildRedRankDialog:getHistroyUserRobRankFinish(result)
    if result == nil then 
        return 
    end
    -- dump(result, "robProcessData==============")

    self._redRobRank = result
    self:robProcessData(self._redRobRank)
    for i,v in ipairs(self._redRobRank) do
        v.rank = i 
    end
    if table.nums(self._redRobRank) == 0 then
        local nothing = self:getUI("bg.nothing")
        nothing:setVisible(true)
    else
        local nothing = self:getUI("bg.nothing")
        nothing:setVisible(false)
    end
    self._tableView:reloadData()
end

function GuildRedRankDialog:senderProcessData(data)
    for i,v in ipairs(data) do
        v.rank = i 

        v.gemValue = math.floor(v.score*0.000000000000001)
        -- v.gemValue = math.floor(v.score*0.000000000000001)
    end
    
    if table.nums(data) <= 1 then
        return
    end
    local sortFunc = function(a, b) 
        local acheck = a.rank
        local bcheck = b.rank
        if acheck == nil then
            return
        end
        if bcheck == nil then
            return
        end
        if acheck < bcheck then
            return true
        end
    end

    table.sort(data, sortFunc)
    -- return tempData
end

function GuildRedRankDialog:robProcessData(data)
    -- dump(data)
    for i,v in ipairs(data) do
        -- v.rank = i 
        v.gemValue = math.floor(v.score*0.0000000001)
        print("test ========", tostring(v.score), v.gemValue)
    end
    -- 2.9385195521469*10^019
    if table.nums(data) <= 1 then
        return
    end
    local sortFunc = function(a, b) 
        local acheck = a.gemValue
        local bcheck = b.gemValue
        local atime = a.score
        local btime = b.score
        if acheck == nil then
            return
        end
        if bcheck == nil then
            return
        end
        if acheck == bcheck then
            if atime ~= btime then
                return atime < btime
            end
        else
            return acheck > bcheck
        end
    end

    table.sort(data, sortFunc)
    -- return tempData
end

return GuildRedRankDialog