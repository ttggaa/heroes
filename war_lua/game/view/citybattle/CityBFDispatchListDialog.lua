--[[
    Filename:    CityBFDispatchListDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-03 17:47:40
    Description: File description
--]]

-- GVG 部队派遣列表
local CityBFDispatchListDialog = class("CityBFDispatchListDialog", BasePopView)

function CityBFDispatchListDialog:ctor(param)
    CityBFDispatchListDialog.super.ctor(self)
    self._tableData = param.atkList or {}
    self._cityId = param.cityId or 1
    self._ltype = param.ltype or 1
    self._index = 1

    -- self._tableData = {}
    -- self._callback = param.callback
    -- self._checkTipCallback = param.checkTipCallback
end

-- 初始化UI后会调用, 有需要请覆盖
function CityBFDispatchListDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 4)

    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBFDispatchListDialog")
        end
        self:closeSelfDialog()
    end)

    self._nothinglab = self:getUI("bg.nothing.lab")

    self._logCell = self:getUI("logCell")
    self._logCell:setVisible(false)

    self._tabEventTarget = {}
    for i=1,2 do
        local tab = self:getUI("bg.tab" .. i)
        tab:setScaleAnim(false)
        self:registerClickEvent(tab, function(sender) self:tabButtonClick(sender, i) end)
        table.insert(self._tabEventTarget, tab)
    end

    local nothing = self:getUI("bg.nothing")
    nothing:setVisible(false)
    self:addTableView()
    self:tabButtonClick(self:getUI("bg.tab1"), 1, false)

    -- local isGuildOpen = self._modelMgr:getModel("UserModel"):getIdGuildOpen()
    -- if isGuildOpen == false then
    --     for i=1,2 do
    --         local tab = self:getUI("bg.tab" .. i)
    --         tab:setVisible(false)
    --     end
    -- end
end

-- 选项卡状态切换
function CityBFDispatchListDialog:tabButtonState(sender, isSelected, key)
    local titleNames = {
        "  进攻方   ",
        "  防守方   ",
    }
    local shortTitleNames = {
        "进攻方    ",
        "防守方    ",
    }

    local tabtxt = sender:getChildByFullName("tabtxt")
    tabtxt:setString("")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()
    sender:setTitleFontSize(30)
    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    end
end

function CityBFDispatchListDialog:tabButtonClick(sender, key, infirst)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        self:tabButtonState(v, false, k)
    end
    self:tabButtonState(sender, true, key)

    if sender:getName() == "tab1" then
        self._index = 1 
        self._nothinglab:setString("你还没有好友，快去添加吧！")
        if not self._atkList then
            self:getAtkList()
        else
            self._tableData = clone(self._atkList)
            self:reflashTableView()
        end

    elseif sender:getName() == "tab2" then 
        print("升级")
        self._index = 2
        if not self._defList then
            self:getDefList()
        else
            self._tableData = self._defList
            self:reflashTableView()
        end
    end
end

function CityBFDispatchListDialog:getAtkList()
    local param = {cid = self._cityId}
    self._serverMgr:sendMsg("CityBattleServer", "getAtkQueue", param, true, {}, function(result) 
        dump(result, "result=====", 10)
        self._atkList = self:progressFriend(result)
        self._tableData = self._atkList
        -- dump(self._tableData)
        self:reflashTableView()
    end)
end

function CityBFDispatchListDialog:getDefList()
    local param = {cid = self._cityId}
    self._serverMgr:sendMsg("CityBattleServer", "getDefQueue", param, true, {}, function(result) 
        dump(result, "result=====", 10)
        self._defList = self:progressDef(result)
        self._tableData = self._defList
        -- dump(self._tableData)
        self:reflashTableView()
    end)
end

-- 处理联盟列表
function CityBFDispatchListDialog:progressDef(allianceData)
    -- local myuserid = self._modelMgr:getModel("UserModel"):getData().usid
    -- local tempData = {}
    -- for k,v in pairs(allianceData) do
    --     v.mfHelp = v.mf
    --     if v.usid ~= myuserid and v.lvl >= 39 then
    --         table.insert(tempData, v)
    --     end
    -- end
    -- local sortFunc = function(a, b)
    --     amfHelp = a.mfHelp
    --     bmfHelp = b.mfHelp
    --     ausid = a.usid
    --     busid = b.usid 
    --     if amfHelp ~= bmfHelp then
    --         return amfHelp > bmfHelp
    --     else
    --         return ausid < busid
    --     end
    -- end
    -- table.sort(tempData, sortFunc)
    return allianceData
end

-- 处理好友列表
function CityBFDispatchListDialog:progressFriend(friendData)
    -- local tempFriend = clone(self._modelMgr:getModel("FriendModel"):getDataByType("friend"))
    -- local tempFriend1 = {}
    -- for k,v in pairs(tempFriend) do
    --     v.mfHelp = friendData[v._id]
    --     if v.lvl >= 39 then
    --         table.insert(tempFriend1, v)
    --     end
    -- end
    -- local sortFunc = function(a, b)
    --     amfHelp = a.mfHelp
    --     bmfHelp = b.mfHelp
    --     ausid = a.usid
    --     busid = b.usid 
    --     if amfHelp ~= bmfHelp then
    --         return amfHelp > bmfHelp
    --     else
    --         return ausid < busid
    --     end
    -- end
    -- table.sort(tempFriend1, sortFunc)
    return friendData
end

-- 接收自定义消息
function CityBFDispatchListDialog:reflashUI()
    local bg = self:getUI("bg")
    bg:setVisible(true)

    -- if self._selType == "team" then
    --     for i=1,2 do
    --         local tab = self:getUI("bg.tab" .. i)
    --         if tab then
    --             tab:setVisible(true)
    --         end
    --     end
    -- else
    --     -- 隐藏标签
    --     for i=1,2 do
    --         local tab = self:getUI("bg.tab" .. i)
    --         if tab then
    --             tab:setVisible(false)
    --         end
    --     end
    --     self._title:setString("选择英雄")
    --     local heroData = self._modelMgr:getModel("MFModel"):getMFHeroData()
    --     self._tableData = clone(heroData)
    --     for k,v in pairs(self._tableData) do
    --         if v.heroId == tonumber(self._heros) then
    --             v["selectMf"] = 1
    --         end
    --     end
    -- end
    -- -- dump(self._tableData)

    -- self._tableView:reloadData()
    -- self:updateConditionDes()
    
end


--[[
用tableview实现
--]]
function CityBFDispatchListDialog:addTableView()
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
function CityBFDispatchListDialog:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

-- cell的尺寸大小
function CityBFDispatchListDialog:cellSizeForTable(table,idx) 
    local width = 572
    local height = 138
    return height, width
end

-- 创建在某个位置的cell
function CityBFDispatchListDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._tableData[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local logCell = self._logCell:clone() 
        logCell:setVisible(true)
        logCell:setAnchorPoint(cc.p(0,0))
        logCell:setPosition(cc.p(5,0)) --0
        logCell:setName("logCell")
        cell:addChild(logCell)

        local name = logCell:getChildByFullName("name")
        UIUtils:setTitleFormat(name, 3)

        local level = logCell:getChildByFullName("level")
        level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local chetui = logCell:getChildByFullName("chetui")
        UIUtils:setButtonFormat(chetui, 4)

        local chakan = logCell:getChildByFullName("chakan")
        UIUtils:setButtonFormat(chakan, 3)

        local fightLab = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli_little)
        fightLab:setName("fightLab")
        fightLab:setAnchorPoint(0, 0.5)
        fightLab:setScale(0.8)
        fightLab:setPosition(120, 34)
        logCell:addChild(fightLab, 1)

        self:updateCell(logCell, param, indexId)
        -- logCell:setSwallowTouches(false)
    else
        print("wo shi shua xin")
        local logCell = cell:getChildByName("logCell")
        if logCell then
            self:updateCell(logCell, param, indexId)
            -- logCell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function CityBFDispatchListDialog:numberOfCellsInTableView(table)
    return self:cellLineNum() -- 
end

function CityBFDispatchListDialog:cellLineNum()
    return table.nums(self._tableData) 
end

function CityBFDispatchListDialog:updateCell(inView, data, indexId)
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
            -- icon:setScale(0.9)
            icon:setName("icon")
            icon:setPosition(cc.p(-3, -4))
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local name = inView:getChildByFullName("name")
    if name then
        name:setString(data.name)
    end

    local vipImg = inView:getChildByFullName("vipImg")
    if vipImg then
        if data.vipLvl == 0 then
            vipImg:setVisible(false)
        else
            vipImg:loadTexture("chatPri_vipLv" .. data.vipLvl .. ".png", 1)
            vipImg:setVisible(true)
        end
    end

    local secLab = inView:getChildByFullName("secLab")
    if secLab then
        if data.sec == "npc" then
            secLab:setString("城市守卫")
        else
            local serverLab = self._modelMgr:getModel("LeagueModel"):getServerName(data.sec)
            secLab:setString("服务器: " .. serverLab)
        end
    end

    local level = inView:getChildByFullName("level")
    if level then
        level:setString(data.lv)
    end

    local fightLab = inView:getChildByFullName("fightLab")
    if fightLab then
        fightLab:setString("a" .. data.score)
    end

    local chetui = inView:getChildByFullName("chetui")
    if chetui then
        self:registerClickEvent(chetui, function()
            print("+撤退+++++++++++++++++++++++++", indexId)
            local param = {fid = data.fid, cid = self._cityId}
            self:withDrawTeam(param, indexId)
        end)
    end

    local chakan = inView:getChildByFullName("chakan")
    if chakan then
        self:registerClickEvent(chakan, function()
            if data.sec == "npc" then
                local npcId = "npc-" .. data.id .. "-" .. (data.fid or 1)
                local param = {nid = npcId}
                self:getNpcData(param)
            else
                local param = {tagId = data.id, fid = data.fid, fsec = data.sec}
                self:getTargetUserBattleInfo(param, data)
            end
            print("查看玩家信息")
            -- self._viewMgr:showTip("该玩家未开启岛屿！")
        end)
    end

    local myuserid = self._modelMgr:getModel("UserModel"):getData()._id 
    local myself = inView:getChildByFullName("myself")
    if myuserid == data.id then
        myself:setVisible(true)
        chetui:setVisible(true)
        chakan:setVisible(false)
    else
        myself:setVisible(false)
        chetui:setVisible(false)
        chakan:setVisible(true)
    end
end

-- 撤退
function CityBFDispatchListDialog:withDrawTeam(param, indexId)
    if not param then
        return
    end
    self._serverMgr:sendMsg("CityBattleServer", "withDrawTeam", param, true, {}, function(result) 
        dump(result, "result===", 10)
        table.remove(self._tableData, indexId)
        self:reflashTableView()
    end)
end

function CityBFDispatchListDialog:reflashTableView()
    self._tableView:reloadData()
    local nothing = self:getUI("bg.nothing")
    if table.nums(self._tableData) ~= 0 then
        nothing:setVisible(false)
    else
        nothing:setVisible(true)
    end
end


-- 查看npc数据
function CityBFDispatchListDialog:getNpcData(param)
    if not param then
        return
    end
    local userData = self._modelMgr:getModel("UserModel"):getData()
    self._serverMgr:sendMsg("CityBattleServer", "getNpcData", param, true, {}, function(result) 
        local data1 = result
        -- data1.rank = data.rank
        data1.serverNum = "npc"
        data1.isNotShowBtn = true
        data1.isServerName = true
        self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
    end)
end

-- 查看玩家数据
function CityBFDispatchListDialog:getTargetUserBattleInfo(param, data)
    if not param then
        return
    end
    local userData = self._modelMgr:getModel("UserModel"):getData()
    -- local roleId = userData.sec .. "-" .. userData._id
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result) 
        dump(result, "result===", 10)
        local data1 = result
        -- data1.rank = data.rank
        data1.serverNum = userData.sec
        data1.isNotShowBtn = true
        data1.isServerName = true
        self._viewMgr:showDialog("arena.DialogArenaUserInfo",data1,true)
    end)
end

function CityBFDispatchListDialog:closeSelfDialog()
    if self.close then
        self:close()
    end 
end

return CityBFDispatchListDialog