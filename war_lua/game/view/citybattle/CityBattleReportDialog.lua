--[[
    Filename:    CityBattleReportDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-12-03 14:49:32
    Description: File description
--]]

-- GVG战报
local CityBattleUtils = CityBattleUtils
local cloneCell
local reportData
local serverList = {}
local CityColor = CityBattleUtils.cityStateColor

local CityBattleReportDialog = class("CityBattleReportDialog", BasePopView)

function CityBattleReportDialog:ctor(param)
    CityBattleReportDialog.super.ctor(self)
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    if param.result and param.result.list then
        serverList = param.result.list
        -- dump(serverList)
    end
    self._callBack = param.callBack
    self._initIndex = 1
    self._userModel = self._modelMgr:getModel("UserModel")
    self._uid = self._userModel:getData()._id
    self._cityColor = self._cityBattleModel:getData().c.co
    self._serverNum  = table.nums(self._cityColor)
    _,_,self._timeDes = self._cityBattleModel:getState()

end


function CityBattleReportDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBattleReportDialog")
        end
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBattleCityReportLayer")
        end
        if self._callBack then
            self._callBack()
        end
        self:close()
    end)

    cloneCell = self:getUI("personCell")
    cloneCell:setVisible(false)

    self._rootPanel = self:getUI("bg.RootPanel")
    self._perconPanel = self._rootPanel:getChildByFullName("personPanel")
    local tableViewBg = self._perconPanel:getChildByFullName("tableViewBg")
    self._tabelViewBgW,self._tabelViewBgH = tableViewBg:getContentSize().width,tableViewBg:getContentSize().height

    self:initData()

    -- 个人
    local tab1 = self:getUI("bg.RootPanel.btn_person")
    -- 城池
    local tab2 = self:getUI("bg.RootPanel.btn_city")

    tab1:setTitleFontName(UIUtils.ttfName)
    tab2:setTitleFontName(UIUtils.ttfName)

    local off = -65
    UIUtils:setTabChangeAnimEnable(tab1,off,function(sender)self:tabButtonClick(sender, 1)end)
    UIUtils:setTabChangeAnimEnable(tab2,off,function(sender)self:tabButtonClick(sender, 2)end)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    table.insert(self._tabEventTarget, tab3)
    table.insert(self._tabEventTarget, tab4)
    self:refreshTopBar()
    if self._initIndex == 1 then
        self:addTableView()
        self:tabButtonClick(tab1, 1)
    end
    local nothing = self._perconPanel:getChildByFullName("nothing")
    nothing:setVisible(false)
    local nothing1 = self._perconPanel:getChildByFullName("nothing1")
    nothing1:setVisible(false)
    local nothingPanle = nothing
    if self:isResultTime() then
        nothingPanle = nothing1
    end
    if table.nums(reportData) == 0 then
        nothingPanle:setVisible(true)
    end

    local title = self:getUI("bg.headBg.title")
    UIUtils:setTitleFormat(title,1)

    self:setListenReflashWithParam(true)
    self:listenReflash("CityBattleModel", self.modelListen)

    local topPanel = ccui.Layout:create()
    topPanel:setContentSize(570,30)
    self._perconPanel:addChild(topPanel,6)
    topPanel:setTouchEnabled(true)
    topPanel:setColor(cc.c3b(255,255,200))
    topPanel:setPosition(0,420)

    local bottomPanel = ccui.Layout:create()
    bottomPanel:setContentSize(570,60)
    self._perconPanel:addChild(bottomPanel,6)
    bottomPanel:setTouchEnabled(true)
    bottomPanel:setPosition(0,-60)

end

--[[
    是否赛季结算期
]]
function CityBattleReportDialog:isResultTime()
    local curServerTime = self._userModel:getCurServerTime()
    local s5OverTime = 0
    _,_,_,_,s5OverTime = self._cityBattleModel:getOverTime()
    if (self._timeDes == "s6" and curServerTime > s5OverTime) or self._timeDes == "s7" then
        return true
    end
end

function CityBattleReportDialog:modelListen(eventName)
    print("CityBattleReportDialog:modelListen",eventName)
    -- if eventName == "CheckResult" then
    if eventName == "IntoS1" or eventName == "IntoS6" then
        --备战开启，战报会清
        if eventName == "IntoS1" then
            reportData = {}
        end
        _,_,self._timeDes = self._cityBattleModel:getState()
        print("self._timeDes",self._timeDes)
        if self._tableView then
            self._tableView:removeFromParent()
            self._tableView = nil
        end
        self:refreshTopBar()
        self:addTableView()
        local nothing = self._perconPanel:getChildByFullName("nothing")
        nothing:setVisible(false)
        local nothing1 = self._perconPanel:getChildByFullName("nothing1")
        nothing1:setVisible(false)
        local nothingPanle = nothing
        if self:isResultTime() then
            nothingPanle = nothing1
        end
        if table.nums(reportData) == 0 then
            nothingPanle:setVisible(true)
        end
    end
end

function CityBattleReportDialog:refreshTopBar()
    local reultBar = self._perconPanel:getChildByFullName("result_bar")
    if self:isResultTime() then
        reultBar:setVisible(true)
        reultBar:setTouchEnabled(true)
        reultBar:setZOrder(10)
        local tableViewBg = self._perconPanel:getChildByFullName("tableViewBg")
        tableViewBg:setContentSize(self._tabelViewBgW,self._tabelViewBgH-reultBar:getContentSize().height-10)
        local tableBg = self._perconPanel:getChildByFullName("tableBg")
        tableBg:setContentSize(556,302)
        local seeBtn = reultBar:getChildByFullName("see")
        self:registerClickEvent(seeBtn,function()
            self._viewMgr:showView("citybattle.CityBattleResultView",{showType = 2},true)
        end)
    else
        reultBar:setVisible(false)
        local tableBg = self._perconPanel:getChildByFullName("tableBg")
        tableBg:setContentSize(556,422)
        local tableViewBg = self._perconPanel:getChildByFullName("tableViewBg")
        tableViewBg:setContentSize(self._tabelViewBgW,self._tabelViewBgH)
    end
end

function CityBattleReportDialog:tabButtonState(sender, isSelected, key)
    local titleNames = {
        " 个人 ",
        " 城池 ",
    }
    local shortTitleNames = {
        "个人",
        "城池",
    }

    -- local tabtxt = sender:getChildByFullName("tabtxt")
    -- tabtxt:setString("")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()

    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    end
end

function CityBattleReportDialog:tabButtonClick(sender, key)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then
            self:tabButtonState(v, false, k)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender
    UIUtils:tabChangeAnim(sender,function()
        self:tabButtonState(sender, true, key)
        audioMgr:playSound("Tab")
        local tempBaseInfoNode = self._rootPanel
        if sender:getName() == "btn_person" then
            self._perconPanel:setVisible(true)
            if not self._tableView then
                self:addTableView()
            end
            if self._cityLayer then
                self._cityLayer:setVisible(false)
            end
        elseif sender:getName() == "btn_city" then
            self._serverMgr:sendMsg("CityBattleServer", "getCityReportList", {}, true, {}, function (result, error)
                if result then
                    if self._cityLayer == nil then
                        self._cityLayer = self:createLayer("citybattle.CityBattleCityReportLayer",result)
                        tempBaseInfoNode:addChild(self._cityLayer,2)
                    else
                        self._cityLayer:reflashUI(result)
                    end
                    self._cityLayer:setVisible(true)
                    self._perconPanel:setVisible(false)
                    if result.list and table.nums(result.list) >0 then
                        local time = self._cityBattleModel:getMaxTime(result.list[1].time,"cityReport")
                        SystemUtils.saveAccountLocalData("CITYBATTLE_CITY_RED",time)
                    end
                end
            end)
        end
    end)
end

function CityBattleReportDialog:initData()
   
    -- reportData = {
    --     {win = 1,name = "假名字",time = 1498806836,avatar = 1101,avatarFrame = 1000, attack = 1,cid = 1,sec = 1001},
    --     {win = 0,name = "假名字",time = 1498806836,avatar = 1101,avatarFrame = 1000, attack = 0,cid = 2,sec = 1001},
    --     {win = 1,name = "假名字",time = 1498806836,avatar = 1101,avatarFrame = 1000, attack = 0,cid = 3,sec = 1002},
    --     {win = 0,name = "假名字",time = 1498806836,avatar = 1101,avatarFrame = 1000, attack = 1,cid = 4,sec = 1002},
    --     {win = 1,name = "假名字",time = 1498806836,avatar = 1101,avatarFrame = 1000, attack = 1,cid = 5,sec = 1003},
    --     {win = 1,name = "假名字",time = 1498806836,avatar = 1101,avatarFrame = 1000, attack = 1,cid = 1,sec = 1003},
    -- }
    local userID = self._modelMgr:getModel("UserModel"):getData()._id
    -- local serverData = {
    --     {atkId = userID,defId = 10, atkName = "假名字", defName = "假名字", win = 0,time = 1498806836,cid = 1,reportKey = "aaa",atkHeroId = 26010201,avatarFrame = 1000,atkSec =9998},
    --     {atkId = 10,defId = userID, atkName = "假名字",defName = "假名字", win = 1,time = 1498806836,cid = 1,reportKey = "aaa",defHeroId = 26010201,avatarFrame = 1000,defSec =9994},
    --     {atkId = userID,defId = 10, atkName = "假名字",defName = "假名字", win = 1,time = 1498806836,cid = 1,reportKey = "aaa",atkHeroId = 26010201,avatarFrame = 1000,atkSec =9992},
    --     {atkId = 10,defId = userID, atkName = "假名字",defName = "假名字", win = 0,time = 1498806836,cid = 1,reportKey = "aaa",defHeroId = 26010201,avatarFrame = 1000,defSec =9998}
    -- }

    self:progressData(serverList)
end

function CityBattleReportDialog:progressData(tempData)
    reportData = {}
    local uid = self._modelMgr:getModel("UserModel"):getData()._id
    for k,v in pairs(tempData) do
        local templog = {}
        if uid == v.atkId then
            templog.name = v.atkName
            -- templog.vipLvl = v.defVipLvl or 0
            -- templog.level = v.defLvl or 0
            templog.avatar = v.atkHeroSkin
            templog.avatarFrame = 1001
            templog.attack = 1
            templog.sec = v.atkSec or 0
            templog.win = v.win
        elseif uid == v.defId then
            templog.name = v.defName
            -- templog.vipLvl = v.atkVipLvl or 0
            -- templog.level = v.atkLvl or 0
            templog.avatar = v.defHeroSkin
            templog.avatarFrame = v.atkAvatarFrame
            templog.attack = 0
            templog.sec = v.defSec or 0
            templog.win = v.win ~= 1 and 1 or 0
        end
        templog.time = v.time
        templog.cid = tonumber(v.cid)
        templog.reportKey = v.reportKey
        table.insert(reportData, templog)
    end

    local sortFunc = function(a, b)
        local atime = a.time
        local btime = b.time
        if atime ~= btime then
            return atime > btime 
        end
    end

    table.sort(reportData, sortFunc)
    -- dump(reportData)
end

--[[
用tableview实现
--]]
function CityBattleReportDialog:addTableView()
    local tableViewBg = self._perconPanel:getChildByFullName("tableViewBg")
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
    self._tableView:reloadData()
    tableViewBg:addChild(self._tableView)
end

-- 触摸时调用
function CityBattleReportDialog:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CityBattleReportDialog:cellSizeForTable(table,idx) 
    local width = 556 
    local height = 110
    return height, width
end

-- 创建在某个位置的cell
function CityBattleReportDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = reportData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local detailCell = cloneCell:clone() 
        detailCell:setVisible(true)
        -- detailCell:setAnchorPoint(cc.p(0,0))
        detailCell:setPosition(cc.p(-1,0))
        detailCell:setName("detailCell")
        cell:addChild(detailCell)

        -- local awardBtn = detailCell:getChildByFullName("awardBtn")
        -- UIUtils:setButtonFormat(awardBtn, 3, 0)

        -- local level = detailCell:getChildByFullName("level")
        -- level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        -- local tipBg = detailCell:getChildByFullName("tipBg.tipBg")
        -- tipBg:setFlippedX(true)

        -- local tipLab = detailCell:getChildByFullName("tipBg.tipLab")
        -- tipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    local detailCell = cell:getChildByName("detailCell")
    if detailCell then
        self:updateCell(detailCell, param, indexId)
        detailCell:setSwallowTouches(false)
    end

    return cell
end

-- 返回cell的数量
function CityBattleReportDialog:numberOfCellsInTableView(table)
    return #reportData 
end

function CityBattleReportDialog:updateCell(cell, data, indexId)
    if data == nil then
        return
    end
    local iconBg = cell:getChildByFullName("icon")
    if iconBg then
        local avatar_ = self:getAvatarIdByHeroid(data.avatar)
        local param1 = {avatar = avatar_, tp = 4,avatarFrame = data.avatarFrame}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setScale(0.8)
            icon:setName("icon")
            icon:setPosition(cc.p(-5, -5))
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local name = cell:getChildByFullName("playerName")
    if name then
        name:setString(data.name)
    end

    local cityName = cell:getChildByFullName("cityName")
    local cityTab = tab:CityBattle(data.cid)
    if cityName then
        cityName:setString(lang(cityTab.name))
    end
    -- citybattle_map_city1
    local cityImg = cell:getChildByFullName("cityImage")
    if cityImg then
        cityImg:setColor(self:getColor(data.sec))
        local imageNum = cityTab["citylv"..self._serverNum]
        if imageNum then
           imageNum = imageNum == 4 and 3 or imageNum
           cityImg:loadTexture("citybattle_map_city"..imageNum..".png",1)
        end
    end


    local resultImage = cell:getChildByFullName("resultImage")
    if data.win and data.win == 1 then
        resultImage:loadTexture("arenaReport_win.png", 1)
    else
        resultImage:loadTexture("arenaReport_lose.png", 1)
    end

    local flagBg = cell:getChildByFullName("flagBg")
    local tipsLable = cell:getChildByFullName("flagTxt")
    tipsLable:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
    if data.attack and data.attack == 1 then
        flagBg:loadTexture("priviege_tipBg.png",1)
        tipsLable:setString("进攻")
        flagBg:setFlippedX(false)
    else
        flagBg:loadTexture("globalImageUI6_connerTag_b.png",1)
        flagBg:setFlippedX(true)
        tipsLable:setString("防守")
    end

    local reviewBtn = cell:getChildByFullName("review")
    self:registerClickEvent(reviewBtn,function()
        print("aaa")
        local param = {reportKey = data.reportKey,jsonFormat = 1}
        self._serverMgr:sendMsg("CityBattleServer", "getBattleReport", param, true, {}, function (result, error)
            if result then
                self:reviewGvgBattle(result)
            end
        end)
    end)

    local time = cell:getChildByFullName("time")
    time:setString(self:getTimeString(data.time))

end

function CityBattleReportDialog:getAvatarIdByHeroid(id)
    return tab.heroSkin[tonumber(id)]["roleAvatarID"]
end

function CityBattleReportDialog:initBattleData(playerData, enemyData)
    local playerInfo = BattleUtils.jsonData2lua_battleData(playerData)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(enemyData)
    return playerInfo, enemyInfo
end

--回放
function CityBattleReportDialog:reviewGvgBattle(result)
    
    local left,right  = self:initBattleData(result.atk,result.def)
    -- right = self:initBattleData(result.def)
    BattleUtils.disableSRData()
    BattleUtils.enterBattleView_GVG(left, right, result.r1, result.r2,
    function (info, callback)
        -- 战斗结束
        -- arenaInfo.award = reportData.award
        -- arenaInfo.rank = reportData.rank
        -- arenaInfo.preRank = defrank
        -- if isMeAtk and isWin then
        --     local arenaInfo = {}
        --     arenaInfo.rank,arenaInfo.preRank,arenaInfo.preHRank = reportData.defRank,reportData.atkRank,reportData.atkRank
        --     info.arenaInfo = arenaInfo
        -- end
        -- if true then return end
        callback(info)
    end,
    function (info)
        -- 退出战斗
    end)
end

function CityBattleReportDialog:getTimeString(time)
    local t = TimeUtils.date("*t",time)
    local des = string.format("%.2d/%.2d/%.2d %.2d:%.2d",t.year,t.month,t.day,t.hour,t.min)
    return des
end

function CityBattleReportDialog:getColor(sec)
    -- local colorData = self._cityBattleModel:getData().c.co
    local num = self._cityColor[tostring(sec)]
    return CityColor[num]
end


function CityBattleReportDialog:reflashUI()

    -- self._tableView:reloadData()

end

function CityBattleReportDialog:dtor ()
    CityBattleUtils = nil
    cloneCell = nil
    reportData = nil
    CityColor = nil
end

return CityBattleReportDialog