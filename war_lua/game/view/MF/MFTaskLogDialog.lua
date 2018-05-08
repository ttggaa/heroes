--[[
    Filename:    MFTaskLogDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-09-26 21:02:07
    Description: File description
--]]

-- 航海战报
local MFTaskLogDialog = class("MFTaskLogDialog", BasePopView)

function MFTaskLogDialog:ctor(param)
    MFTaskLogDialog.super.ctor(self)
    self._tempData = param.list
end

function MFTaskLogDialog:onInit()
    self._title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(self._title, 1)

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFTaskLogDialog")
        end
        self:close()
    end)

    self._logCell = self:getUI("bg.logCell")

    self:addTableView()
    self:progressData(self._tempData)
end

function MFTaskLogDialog:progressData(tempData)
    self._logData = {}
    local userData = self._modelMgr:getModel("UserModel"):getData()
    -- dump(tempData[1], "desciption========", 10)
    for k,v in pairs(tempData) do
        local templog = {}
        local x = 1
        if userData._id == v.atkId then
            templog.name = v.defName
            templog.vipLvl = v.defVip or 0
            templog.level = v.defLvl or 0
            templog.avatar = v.defAvatar
            templog.avatarFrame = v.defAvatarFrame
            templog.time = v.time
            templog.type = 1
            templog.npc = 0
            templog.win = v.win or 0
            if v.win == -1 then
                templog.npc = 1
            end
        elseif userData._id == v.defId then
            templog.name = v.atkName
            templog.vipLvl = v.atkVip or 0
            templog.level = v.atkLvl or 0
            templog.avatar = v.atkAvatar
            templog.avatarFrame = v.atkAvatarFrame
            templog.time = v.time
            templog.type = 2
            templog.npc = v.npc 
            if v.win == 1 then
                templog.win = 0
            else
                templog.win = v.win
            end
        end
        if templog.npc == 0 then
            table.insert(self._logData, templog)
        end
    end

    local sortFunc = function(a, b)
        atime = a.time
        btime = b.time
        if atime ~= btime then
            return atime > btime 
        end
    end

    table.sort(self._logData, sortFunc)

    -- dump(self._logData[1], "desciption===")
    self._tableView:reloadData()
    local nothing = self:getUI("bg.nothing")
    if table.nums(self._logData) ~= 0 then
        nothing:setVisible(false)
    else
        nothing:setVisible(true)
    end
end


function MFTaskLogDialog:reflashUI()
    -- dump(self._logData)
    -- 设置审批
    -- local allianceD = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
    -- -- dump(allianceD)
    -- local value = self:getUI("bg.leftLayer.shenpiBg.levelBg.value")
    -- local lastBtn = self:getUI("bg.leftLayer.shenpiBg.levelBg.lastBtn")
    -- local nextBtn = self:getUI("bg.leftLayer.shenpiBg.levelBg.nextBtn")
    -- self._tempLevel = allianceD.lvlimit
    -- value:setString(allianceD.lvlimit)
    -- if allianceD.lvlimit == 0 then
    --     lastBtn:setSaturation(-100)
    -- elseif allianceD.lvlimit == 80 then
    --     nextBtn:setSaturation(-100)
    -- end
    -- local value = self:getUI("bg.leftLayer.shenpiBg.needBg.value")
    -- if allianceD.status == 1 then
    --     value:setString("需要")
    --     self._tempValue = 1
    -- else
    --     value:setString("无需")
    --     self._tempValue = 0
    -- end

end

function MFTaskLogDialog:updateCell(inView, data, indexId)
    if data == nil then
        return
    end
    -- dump(data,"data ====================")
    local iconBg = inView:getChildByFullName("iconBg")
    if iconBg then
        local param1 = {avatar = data.avatar, tp = 4,avatarFrame = data["avatarFrame"]}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setScale(0.9)
            icon:setName("icon")
            icon:setPosition(cc.p(-5, -5))
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local name = inView:getChildByFullName("name")
    if name then
        name:setString(data.name)
    end



    local vipIcon = inView:getChildByFullName("vipIcon")
    vipIcon:setVisible(true)
    if data.vipLvl > 0 then
        vipIcon:setVisible(true)  
        vipIcon:loadTexture(("chatPri_vipLv"..math.max(1, data.vipLvl)..".png"), 1)
        if name then
            vipIcon:setPositionX(name:getPositionX()+name:getContentSize().width+30)
        end
    else
        -- 增加 vip0标签 by guojun 2017.3.23
        vipIcon:setVisible(false)
        -- vipIcon:loadTexture(("chatPri_vipLv0.png"), 1)
    end

    local level = inView:getChildByFullName("level")
    if level then
        level:setString(data.level)
    end

    local time = inView:getChildByFullName("time")
    if time then
        time:setString(GuildUtils:getDisNowTime(data.time))
    end

    local logType = inView:getChildByFullName("logType")
    local tipBg = inView:getChildByFullName("tipBg")
    if logType then
        if data.win == -1 then
            logType:loadTexture("mf_helpIcon.png", 1)
            if tipBg then
                tipBg:setVisible(false)
            end
        elseif data.win == 0 then
            logType:loadTexture("arenaReport_lose.png", 1)
            if tipBg then
                tipBg:setVisible(true)
            end
        elseif data.win == 1 then
            logType:loadTexture("arenaReport_win.png", 1)
            if tipBg then
                tipBg:setVisible(true)
            end
        end
    end
    local tipBar = inView:getChildByFullName("tipBg.tipBg")
    if tipBar then
        if data.type == 1 then
            tipBar:loadTexture("globalImageUI6_connerTag_r.png", 1)
        elseif data.type == 2 then
            tipBar:loadTexture("globalImageUI6_connerTag_b.png", 1)
        end
    end

    local tipLab = inView:getChildByFullName("tipBg.tipLab")
    tipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    if tipLab then
        if data.type == 1 then
            tipLab:setString("进攻")
        elseif data.type == 2 then
            tipLab:setString("防守")
        end
    end
end


--[[
用tableview实现
--]]
function MFTaskLogDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height-14))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(5, 6))
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
function MFTaskLogDialog:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function MFTaskLogDialog:cellSizeForTable(table,idx) 
    local width = 636 
    local height = 105
    return height, width
end

-- 创建在某个位置的cell
function MFTaskLogDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._logData[idx + 1] -- {typeId = 3, id = 1}
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local logCell = self._logCell:clone() -- self._viewMgr:createLayer("guild.GuildInCell")
        logCell:setAnchorPoint(cc.p(0,0))
        logCell:setPosition(cc.p(0,5))
        logCell:setVisible(true)
        logCell:setName("logCell")
        cell:addChild(logCell)
        
        local name = logCell:getChildByFullName("name")
        name:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

        local level = logCell:getChildByFullName("level")
        level:setColor(cc.c3b(255,255,255))
        level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)


        local time = logCell:getChildByFullName("time")
        time:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- time:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local tipBg = logCell:getChildByFullName("tipBg.tipBg")
        tipBg:setFlippedX(true)

        local tipLab = logCell:getChildByFullName("tipBg.tipLab")
        -- tipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        tipLab:setFontName(UIUtils.ttfName)

        self:updateCell(logCell, param, indexId)
        logCell:setSwallowTouches(false)
    else
        local logCell = cell:getChildByName("logCell")
        if logCell then
            self:updateCell(logCell, param, indexId)
            logCell:setSwallowTouches(false)
        end
    end
    return cell
end

-- 返回cell的数量
function MFTaskLogDialog:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function MFTaskLogDialog:tableNum()
    return table.nums(self._logData)
end


return MFTaskLogDialog

