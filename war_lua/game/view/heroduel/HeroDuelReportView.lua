--
-- Author: <huachangmiao@playcrab.com>
-- Date: 2017-02-08 15:32:53
--
local HeroDuelReportView = class("HeroDuelReportView", BasePopView)

function HeroDuelReportView:ctor(data)
    HeroDuelReportView.super.ctor(self)

    self._data = data.data
    self._reportData = {}

    self._initTab = 1
    self._curTab = nil

    self._hModel = self._modelMgr:getModel("HeroDuelModel")
end

function HeroDuelReportView:onInit()
    table.insert(self._reportData, self._data.user or {})
    table.insert(self._reportData, self._data.season or {})

    self._tabTitles = {"我的战报", "精彩对局"}

    self._title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(self._title, 1)

    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("heroduel.HeroDuelReportView")
    end)

--    self._myBtn = self:getUI("bg.bg.tab_mine")
--    self._wonderfulBtn = self:getUI("bg.bg.tab_wonderful")

--    local myLabel = self._myBtn:getChildByFullName("label")
--    myLabel:setFontName(UIUtils.ttfName_Title)
--    myLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
--    local wonderfulLabel = self._wonderfulBtn:getChildByFullName("label")
--    wonderfulLabel:setFontName(UIUtils.ttfName_Title)
--    wonderfulLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    -- self:registerClickEventByName("bg.bg.tab_mine", function(sender)self:tabButtonClick(sender) end)
    -- self:registerClickEventByName("bg.bg.tab_wonderful", function(sender)self:tabButtonClick(sender) end)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, self:getUI("bg.bg.tab_mine"))
    table.insert(self._tabEventTarget, self:getUI("bg.bg.tab_wonderful"))


    self._maxData = {}
    self._sortData = {}
    for i = 1, #self._tabEventTarget do
        local button = self._tabEventTarget[i]
        button:setTitleFontName(UIUtils.ttfName_Title)
        button:setTitleFontSize(20)
        button:setTitleColor(UIUtils.colorTable.ccUIBaseTextColor2)
        button:getTitleRenderer():disableEffect()
        button.index = i
        UIUtils:setTabChangeAnimEnable(button,-33,handler(self, self.tabButtonClick))
    end

    self._tableData = self._reportData[self._initTab]
    self:addTableView()
    self._tabEventTarget[self._initTab]._appearSelect = true
    self:tabButtonClick(self._tabEventTarget[self._initTab],true)
end

--[[
--! @function tabButtonClick
--! @desc 选项卡按钮点击事件处理
--! @param sender table 操作对象
--! @return 
--]]
function HeroDuelReportView:tabButtonClick(sender,noAudio)
    if sender == nil or sender.index == self._curTab then 
        return 
    end
    if not noAudio then 
        audioMgr:playSound("Tab")
    end

    self._curTab = sender.index

    for k,v in pairs(self._tabEventTarget) do
--        local text = v:getTitleRenderer()
--        v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
--        text:disableEffect()
--        text:setPositionX(65)
        if v ~= sender then
            self:tabButtonState(v, false)
        end
    end
    
--    local text = sender:getTitleRenderer()
--    text:disableEffect()
--    text:setPositionX(85)
--    sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender
    UIUtils:tabChangeAnim(self._preBtn,function( )
        self:tabButtonState(sender, true)
        self:touchTabEvent(sender)
    end)
end

function HeroDuelReportView:touchTabEvent(sender)
    local index = sender.index
    self._title:setString(self._tabTitles[index])
    self._tableData = self._reportData[index]
    dump(self._tableData,"66666666")
    self._tableView:reloadData()
    UIUtils:ccScrollViewUpdateScrollBar(self._tableView)
end

--[[
--! @function tabButtonState
--! @desc 按钮状态切换
--! @param sender table 操作对象
--! @param isSelected bool 是否选中状态
--! @return 
--]]
function HeroDuelReportView:tabButtonState(sender, isSelected, isDisabled)
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
end

function HeroDuelReportView:addTableView()
    local bg = self:getUI("bg.bg.tableNode")

    local tableView = cc.TableView:create(cc.size(710, 437))
    tableView:setColor(cc.c3b(255,255,255))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(-10,7))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- tableView:setBounceEnabled(false)
    bg:addChild(tableView)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)

    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)

    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)

    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)

    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)

    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -14, 6)
    tableView:reloadData()
    self._tableView = tableView
end

function HeroDuelReportView:createCell(cellData, index)
--     dump(cellData, "a", 20)
    local bg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI7_cellBg21.png")
    bg:setCapInsets(cc.rect(25, 25, 1, 1))
    bg:setContentSize(cc.size(670, 220))

    local vs = cc.Sprite:createWithSpriteFrameName("report_vs_heroDuel.png")
    vs:setScale(0.88)
    vs:setPosition(335, 174)
    bg:addChild(vs)

    local line1 = cc.Sprite:createWithSpriteFrameName("report_line_heroDuel.png")
    line1:setPosition(146, 120)
    bg:addChild(line1)

    local line2 = cc.Sprite:createWithSpriteFrameName("report_line_heroDuel.png")
    line2:setPosition(524, 120)
    bg:addChild(line2)

    local playBtn = ccui.Button:create("report_btn_heroDuel.png", "report_btn_heroDuel.png", "report_btn_heroDuel.png", 1)
    playBtn:setScale(0.88)
    playBtn:setPosition(335, 117)
    playBtn:setSwallowTouches(false)
    bg:addChild(playBtn)

    playBtn.index = index

    self:registerClickEvent(playBtn, function()
        local data = self._tableData[playBtn.index + 1]

        local serverName = nil
        local msgName = nil
        if self._curTab == 1 then
            serverName = "BattleServer"
            msgName = "getBattleReport"
        else
            serverName = "HeroDuelServer"
            msgName = "hDuelGetReport"
        end
        self._serverMgr:sendMsg(serverName,msgName,{reportKey = data.key}, true, {},function( result )
            local left  = BattleUtils.jsonData2lua_battleData(result.atk)
            local right = BattleUtils.jsonData2lua_battleData(result.def)
            BattleUtils.disableSRData()
            BattleUtils.enterBattleView_HeroDuel(left, right, result.r1, result.r2, 1, data.def.rid == self._modelMgr:getModel("UserModel"):getRID(),
            function (info, callback)
                callback(info)

            end,
            function (info)

            end)
        end)
    end)
    bg.playBtn = playBtn

    local invalidIcon = cc.Sprite:createWithSpriteFrameName("img_off_heroDuel.png")
    invalidIcon:setPosition(335, 117)
    invalidIcon:setVisible(false)
    bg:addChild(invalidIcon)
    bg.invalidIcon = invalidIcon

    local shareBtn = ccui.Button:create("btn_share_heroDuel.png", "btn_share_heroDuel.png", "btn_share_heroDuel.png", 1)
    shareBtn:setPosition(335, 35)
    shareBtn:setSwallowTouches(false)
    bg:addChild(shareBtn)

    shareBtn.index = index

    self:registerClickEvent(shareBtn, function()
        local data = self._tableData[playBtn.index + 1]
        if cellData.atk.rid == self._modelMgr:getModel("UserModel"):getRID() then
            self._shareMyName = cellData.atk.name
            self._shareEnemyName = cellData.def.name
        else
            self._shareMyName = cellData.def.name
            self._shareEnemyName = cellData.atk.name
        end

        local param = {}
        param.message_ext = "t=1,k=".. data.key ..",s=".. GameStatic.sec ..",bt=2,l=".. self._shareMyName ..",r=".. self._shareEnemyName ..""
        param.scene = 2
        param.title = lang("REPORTSHARE_TITLE2")
        local desStr = lang("REPORTSHARE_DES2")
        desStr = string.gsub(desStr,"{$name1}", self._shareMyName)
        desStr = string.gsub(desStr,"{$name2}", self._shareEnemyName)
        param.desc  = desStr
        param.media_tag = sdkMgr.SHARE_TAG.MSG_INVITE
        sdkMgr:sendToPlatform(param, function(code, data)

        end)
    end)

    bg.shareBtn = shareBtn

    if cellData.key == "invalid" then
        playBtn:setVisible(false)
        invalidIcon:setVisible(true)
        shareBtn:setVisible(false)
    end

    shareBtn:setVisible(self._curTab == 1)

    local atk = cellData.atk
    local def = cellData.def

    local win1 = cc.Sprite:createWithSpriteFrameName("priviege_tipBg.png")
    win1:setPosition(34, 192)
    bg:addChild(win1)

    local label = cc.Label:createWithTTF("胜方", UIUtils.ttfName, 18)
    label:setPosition(24, 36)
    label:setRotation(-45)
    label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    win1:addChild(label)
    bg.win1 = win1

    local win2 = cc.Sprite:createWithSpriteFrameName("priviege_tipBg.png")
    win2:setPosition(636, 192)
    win2:setScaleX(-1)
    bg:addChild(win2)

    local label = cc.Label:createWithTTF("胜方", UIUtils.ttfName, 18)
    label:setPosition(24, 36)
    label:setScaleX(-1)
    label:setRotation(-45)
    label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    win2:addChild(label)
    bg.win2 = win2

    if tonumber(atk.win) == 1 then
        win1:setVisible(true)
        win2:setVisible(false)
    else
        win1:setVisible(false)
        win2:setVisible(true)
    end

    local color = cc.c3b(70, 40, 0)

    local label = cc.Label:createWithTTF(self._modelMgr:getModel("LeagueModel"):getServerName(atk.sec), UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(0, 0)
    label:setPosition(36, 166)
    bg:addChild(label)
    bg.sec1 = label

    local label = cc.Label:createWithTTF(atk.name, UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(0, 0)
    label:setPosition(36, 148)
    bg:addChild(label)
    bg.name1 = label

    local atkRank = atk.rank == 0 and "未上榜" or atk.rank
    local label = cc.Label:createWithTTF("世界排名:".. atkRank , UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(0, 0)
    label:setPosition(36, 130)
    bg:addChild(label)
    bg.rank1 = label

    local label = cc.Label:createWithTTF(self._modelMgr:getModel("LeagueModel"):getServerName(def.sec), UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(1, 0)
    label:setPosition(636, 166)
    bg:addChild(label)
    bg.sec2 = label

    local label = cc.Label:createWithTTF(def.name, UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(1, 0)
    label:setPosition(636, 148)
    bg:addChild(label)
    bg.name2 = label

    local defRank = def.rank == 0 and "未上榜" or def.rank
    local label = cc.Label:createWithTTF("世界排名:".. defRank, UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(1, 0)
    label:setPosition(636, 130)
    bg:addChild(label)
    bg.rank2 = label

    local str
    local sec = self._modelMgr:getModel("UserModel"):getCurServerTime() - cellData.time 
    if sec < 60 then
        str = sec .. "秒前"
    elseif sec < 3600 then
        str = math.floor(sec / 60) .. "分钟前"
    elseif sec < 86400 then
        str = math.floor(sec / 3600) .. "小时前"
    else
        str = math.floor(sec / 86400) .. "天前"
    end

    local label = cc.Label:createWithTTF(str, UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(0.5, 0.5)
    label:setPosition(335, 72)
    bg:addChild(label)
    bg.time = label

    local bg1 = cc.Scale9Sprite:createWithSpriteFrameName("report_bg_heroDuel.png")
    bg1:setCapInsets(cc.rect(7, 7, 1, 1))
    bg1:setContentSize(cc.size(104, 53))
    bg1:setPosition(224, 158)
    bg:addChild(bg1)

    local bg2 = cc.Scale9Sprite:createWithSpriteFrameName("report_bg_heroDuel.png")
    bg2:setCapInsets(cc.rect(7, 7, 1, 1))
    bg2:setContentSize(cc.size(104, 53))
    bg2:setPosition(446, 158)
    bg:addChild(bg2)

    local label = cc.Label:createWithTTF("禁选", UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(0.5, 0.5)
    label:setPosition(224, 194)
    bg:addChild(label)

    local label = cc.Label:createWithTTF("禁选", UIUtils.ttfName, 18)
    label:setColor(color)
    label:setAnchorPoint(0.5, 0.5)
    label:setPosition(446, 194)
    bg:addChild(label)


    function createTeamIcon(x, y, id, awake)
        local circle = cc.Sprite:createWithSpriteFrameName("globalImageUI4_squality5.png")
        circle:setPosition(x, y)
        circle:setScale(0.42)

        local teamD = tab.team[id]
        local pathName = nil
        if awake ~= nil then
            pathName = teamD.jxart1
        else
            pathName = teamD.art1
        end

        local icon = cc.Sprite:createWithSpriteFrameName(pathName..".jpg")
        icon:setPosition(48, 48)
        -- icon:setScale(1)
        circle:addChild(icon, -1)
        circle.icon = icon
        return circle
    end

    function createHeroIcon(x, y, id)
        local circle = cc.Sprite:createWithSpriteFrameName("globalImageUI4_heroBg1.png")
        circle:setPosition(x, y)
        circle:setScale(0.7)

        local heroD = tab.hero[id]
        local icon = cc.Sprite:createWithSpriteFrameName(heroD.herohead..".jpg")
        icon:setPosition(44, 44)
        circle:addChild(icon, -1)
        circle.icon = icon
        return circle
    end

    bg.aban1 = createTeamIcon(199, 158, atk.ban[1])
    bg.aban2 = createTeamIcon(249, 158, atk.ban[2])
    bg.dban1 = createTeamIcon(421, 158, def.ban[1])
    bg.dban2 = createTeamIcon(471, 158, def.ban[2])

    bg:addChild(bg.aban1)
    bg:addChild(bg.aban2)
    bg:addChild(bg.dban1)
    bg:addChild(bg.dban2)

    local list1 = clone(atk.form)
    local array1 = {}
    local hero1 = list1.heroId
    list1.heroId = nil
    for k, v in pairs(list1) do
        v.pos = tonumber(k)
        array1[#array1 + 1] = v
    end
    table.sort(array1, function(a, b)
        return a.pos < b.pos
    end)

    bg.teams1 = {}
    local data, a, b, x, y
    for i = 1, #array1 do
        data = array1[i]
        a, b = math.modf((i - 1) / 4) 
        x = 35 + b * 48 * 4
        y = 90 - a * 48
        bg.teams1[i] = createTeamIcon(x, y, data.id, data.awake)
        bg:addChild(bg.teams1[i])
    end

    local list2 = clone(def.form)
    local array2 = {}
    local hero2 = list2.heroId
    list2.heroId = nil
    for k, v in pairs(list2) do
        v.pos = tonumber(k)
        array2[#array2 + 1] = v
    end
    table.sort(array2, function(a, b)
        return a.pos < b.pos
    end)

    bg.teams2 = {}
    for i = 1, #array2 do
        data = array2[i]
        a, b = math.modf((i - 1) / 4) 
        x = 491 + b * 48 * 4
        y = 90 - a * 48
        bg.teams2[i] = createTeamIcon(x, y, data.id, data.awake)
        bg:addChild(bg.teams2[i])
    end

    bg.hero1 = createHeroIcon(242, 68, hero1)
    bg:addChild(bg.hero1)
    bg.hero2 = createHeroIcon(428, 68, hero2)
    bg:addChild(bg.hero2)

    return bg
end

function HeroDuelReportView:updateCell(bg, cellData, index)
    bg.playBtn.index = index
    bg.shareBtn.index = index

    bg.playBtn:setVisible(cellData.key ~= "invalid")
    bg.invalidIcon:setVisible(cellData.key == "invalid")
    bg.shareBtn:setVisible(cellData.key ~= "invalid" and  self._curTab == 1)

    local atk = cellData.atk
    local def = cellData.def

    if tonumber(atk.win) == 1 then
        bg.win1:setVisible(true)
        bg.win2:setVisible(false)
    else
        bg.win1:setVisible(false)
        bg.win2:setVisible(true)
    end
    bg.sec1:setString(self._modelMgr:getModel("LeagueModel"):getServerName(atk.sec))
    bg.name1:setString(atk.name)
    local atkRank = atk.rank == 0 and "未上榜" or atk.rank
    bg.rank1:setString("世界排名:".. atkRank)

    bg.sec2:setString(self._modelMgr:getModel("LeagueModel"):getServerName(def.sec))
    bg.name2:setString(def.name)

    local defRank = def.rank == 0 and "未上榜" or def.rank
    bg.rank2:setString("世界排名:".. defRank)

    local str
    local sec = self._modelMgr:getModel("UserModel"):getCurServerTime() - cellData.time 
    if sec < 60 then
        str = sec .. "秒前"
    elseif sec < 3600 then
        str = math.floor(sec / 60) .. "分钟前"
    elseif sec < 86400 then
        str = math.floor(sec / 3600) .. "小时前"
    else
        str = math.floor(sec / 86400) .. "天前"
    end
    bg.time:setString(str)

    function updateTeamIcon(circle, id, awake)
        local teamD = tab.team[id]
        local pathName = nil
        if awake ~= nil then
            pathName = teamD.jxart1
        else
            pathName = teamD.art1
        end
        circle.icon:setSpriteFrame(pathName..".jpg")
    end

    function updateHeroIcon(circle, id)
        local heroD = tab.hero[id]
        circle.icon:setSpriteFrame(heroD.herohead..".jpg")
    end

    for i=1,2 do
        local state = tab.heroDuejx[atk.ban[i]] ~= nil and 1 or nil
        updateTeamIcon(bg["aban"..i], atk.ban[i],state)
    end
    for i=1,2 do
        local state = tab.heroDuejx[def.ban[i]] ~= nil and 1 or nil
        updateTeamIcon(bg["dban"..i], def.ban[i],state)
    end

    local list1 = clone(atk.form)
    local array1 = {}
    local hero1 = list1.heroId
    list1.heroId = nil
    for k, v in pairs(list1) do
        v.pos = tonumber(k)
        array1[#array1 + 1] = v
    end
    table.sort(array1, function(a, b)
        return a.pos < b.pos
    end)

    for i = 1, #array1 do
        updateTeamIcon(bg.teams1[i], array1[i].id, array1[i].awake)
    end

    local list2 = clone(def.form)
    local array2 = {}
    local hero2 = list2.heroId
    list2.heroId = nil
    for k, v in pairs(list2) do
        v.pos = tonumber(k)
        array2[#array2 + 1] = v
    end
    table.sort(array2, function(a, b)
        return a.pos < b.pos
    end)

    for i = 1, #array2 do
        updateTeamIcon(bg.teams2[i], array2[i].id, array2[i].awake)
    end

    updateHeroIcon(bg.hero1, hero1)
    updateHeroIcon(bg.hero2, hero2)

    return bg
end

function HeroDuelReportView:scrollViewDidScroll(view)
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function HeroDuelReportView:scrollViewDidZoom(view)

end

function HeroDuelReportView:tableCellTouched(table,cell)

end

function HeroDuelReportView:cellSizeForTable(table,index)
    return 225, 710
end

function HeroDuelReportView:tableCellAtIndex(table,index)
    local cellData = self._tableData[index + 1]
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local item = self:createCell(cellData, index)
        item:setPosition(cc.p(20,0))
        item:setAnchorPoint(cc.p(0,0))
        cell:addChild(item)
        cell.item = item
    else
        self:updateCell(cell.item, cellData, index)
    end

    return cell
end

function HeroDuelReportView:numberOfCellsInTableView(table)
    return #self._tableData
end

return HeroDuelReportView