--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-09-08 16:38:32
--
local LeagueAwardView = class("LeagueAwardView",BasePopView)
function LeagueAwardView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueAwardView:onInit()
    self._stagePanel = self:getUI("bg.mainBg.stagePanel")
    self._activePanel = self:getUI("bg.mainBg.activePanel")
    self._seasonPanel = self:getUI("bg.mainBg.seasonPanel")

    self._panels = {}
    table.insert(self._panels,self._activePanel)
    table.insert(self._panels,self._stagePanel)
    table.insert(self._panels,self._seasonPanel)

    
    
    -- stipDes:setColor(cc.c3b(240, 200, 79))
    -- stipDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._title = self:getUI("bg.headBg.title")
    UIUtils:setTitleFormat(self._title,1)
    
    self._tabs = {}
    self._activeTab = self:getUI("bg.activeTab")
    table.insert(self._tabs,self._activeTab)
    self._stageTab = self:getUI("bg.stageTab")
    table.insert(self._tabs,self._stageTab)
    self._seasonTab = self:getUI("bg.seasonTab")
    table.insert(self._tabs,self._seasonTab)
    for i=1,3 do
        UIUtils:setTabChangeAnimEnable(self._tabs[i],182,function( )
            self:touchTab(i)
        end)
    end
    self._cell1 = self:getUI("cell1")
    self._cell2 = self:getUI("cell2")
    self._cell3 = self:getUI("cell3")
    self._cell3:setVisible(false)
    self:registerClickEventByName("bg.mainBg.closeBtn",function( )
        self:close()
        UIUtils:reloadLuaFile("league.LeagueAwardView")
    end)
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._hadGetInfo = clone(self._leagueModel:getLeague().dailyReward or {})
    self._curZone = self._modelMgr:getModel("LeagueModel"):getLeague().currentZone or 1

    -- 段位奖励列表
    self:initStagePanel()

    -- 活跃度奖励列表
    self:initActivePanel()

    -- 上赛季奖励列表
    self:initSeasonPanel()
    
    -- 首选页签
    self._tabs[1]._appearSelect = true
    self:touchTab(1)
    -- 五点刷新，自己控制数据，早一秒刷新
    self:registerTimer(5,0,0,function( )
        print("regisetTimer.............")
        self._activeNum = 0
        local anum = self._activePanel:getChildByName("num")
        anum:setString("0")
        self._modelMgr:getModel("PlayerTodayModel"):setDayInfo(31,0)
        self:sortDialyTable()
        self._ActiveTableView:reloadData()
        self._tableView:reloadData()
    end)
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:00"))
    if nowTime < tempTodayTime then
        local resetInFiveClock = true
        self._fiveSche = ScheduleMgr:regSchedule(1000, self, function( )
            nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
            tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:00"))
            if nowTime >= tempTodayTime and nowTime < tempTodayTime+10 and resetInFiveClock then
                resetInFiveClock = false
                self._activeNum = 0
                local anum = self._activePanel:getChildByName("num")
                anum:setString("0")
                self._modelMgr:getModel("PlayerTodayModel"):setDayInfo(31,0)
                self._hadGetInfo = {}
                self:sortDialyTable()
                self._ActiveTableView:reloadData()
                self._tableView:reloadData()
            end
        end)
    end

    self:listenReflash("LeagueModel", self.reflashUI)
    -- dump(self._leagueModel:getData(),"ifget=============")
end

-- 初始化 活跃度页签
function LeagueAwardView:initActivePanel( )
    local stipDes = self._activePanel:getChildByName("tipDes")
    stipDes:setFontName(UIUtils.ttfName)
    stipDes:setString("进行冠军对决对战，领取活跃奖励！")
    local anumDes = self._activePanel:getChildByName("numDes")
    anumDes:setFontName(UIUtils.ttfName)
    local anum = self._activePanel:getChildByName("num")
    anum:setFontName(UIUtils.ttfName)
    local aNum = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(31) -- dayinfo 里记录的当天挑战次数
    anum:setString(aNum)
    self._activeNum = aNum
    -- 活跃奖励列表
    self._activeTableData = {}
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local day = tonumber(TimeUtils.date("%d",nowTime))
    local nowHour = tonumber(TimeUtils.date("%H",nowTime))
    for k,v in ipairs(tab.leagueReward) do
        if self._hadGetInfo[tostring(v.id)] then
            local getDay,getHour = tonumber(TimeUtils.date("%d",self._hadGetInfo[tostring(v.id)])),tonumber(TimeUtils.date("%H",self._hadGetInfo[tostring(v.id)]))
            if ( (day > getDay and (getHour<5 or nowHour >=5)) or (day == getDay and getHour < 5 and nowHour >= 5)) then
                self._hadGetInfo[tostring(v.id)] = nil 
            end
        end
        table.insert(self._activeTableData,clone(v))
    end 
    self:sortDialyTable()
    
    self:addActiveTableView()
end

-- 初始化 段位页签内容
function LeagueAwardView:initStagePanel( )
    local rtx = RichTextFactory:create( "[color = 3c2a1eff,fontsize=16]每赛季[color = c44904ff,fontsize=16]晋升奖励[-]仅可领取一次![-][color = 3c2a1eff,fontsize=16]段位奖励每天[color = c44904ff,fontsize=16]24:00[-]将发到邮箱[-]", 700, 20)
    rtx:formatText()
    rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(cc.p(w/2+30, 380))
    rtx:setSaturation(0)
    self._stagePanel:addChild(rtx, 999)
    self._stageTableData = {}
    for k,v in ipairs(tab.leagueRank) do
        table.insert(self._stageTableData,clone(v))
    end 
    self:addStageTableView()
end

-- 初始化 上赛季奖励页签
function LeagueAwardView:initSeasonPanel( )
    -- 如果当前排名无奖励可领
    local outRange = false
    local maxHonorD = tab.leagueHonor[#tab.leagueHonor]
    if maxHonorD and maxHonorD.pos then
        local maxRank = maxHonorD.pos[2]
        local rank = self._leagueModel:getData().rank or -1
        print("rank,maxRank",rank,maxRank)
        if rank > maxRank then
        -- 无奖励可领 放大tableView 隐藏展示
            outRange = true
        end
    end
    if not self._seasonTableData then
        self._seasonTableData = {}
        local leagueHonor = clone(tab["leagueHonor"])
        for i,rankD in ipairs(leagueHonor) do
            self._seasonTableData[i] = rankD
        end
        self:addSeasonTableView(outRange)
    end
    if outRange then 
        local hideMap = {
            "titleBg",
            "numDes",
            "getImg",
            "rank",
            "split",
            "timeLab",
            "tipDes",
            "awardBtn",
        }
        for k,v in pairs(hideMap) do
            local node = self._seasonPanel:getChildByName(v)
            if node then 
                node:setVisible(false)
            end
        end
        local backTexture = self._seasonPanel:getChildByName("backTexture")
        backTexture:setContentSize(cc.size(687,463))
        return
    end
    -- ui初始化
    local numDes = self:getUI("bg.mainBg.seasonPanel.numDes")
    numDes:setColor(cc.c3b(255, 252, 226))
    numDes:enable2Color(1,cc.c4b(255, 232, 125, 255))
    numDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local rank = self:getUI("bg.mainBg.seasonPanel.rank")
    rank:setColor(cc.c3b(255, 252, 226))
    rank:enable2Color(1,cc.c4b(255, 232, 125, 255))
    rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local rankNum = self._modelMgr:getModel("LeagueModel"):getData().preRank 
    local noPreRank = false
    local hadGetAward = self._leagueModel:getData().ifGet and self._leagueModel:getData().ifGet > 0
    print("rank num.... =================",rankNum,self._leagueModel:getData().ifGet)
    if rankNum == -1 or not rankNum or hadGetAward then
        rankNum = self._modelMgr:getModel("LeagueModel"):getData().rank 
        noPreRank = true
    end
    rank:setString(rankNum or "暂无排名")

    if noPreRank then
        numDes:setString("我的排名：")
    else
        numDes:setString("上赛季排名：")
    end

    print("rankNum======",rankNum)
    local titleBg = self:getUI("bg.mainBg.seasonPanel.titleBg")
    local honorD = self:getInRangeData( rankNum )
    local honerOffsetX = (hadGetAward or noPreRank) and 60 or 0
    if honorD then
        local awards = honorD.monthlyawards 
        for i,v in ipairs(awards) do
            local itemId
            if v[1] == "tool" then
                itemId = v[2]
            else
                itemId = IconUtils.iconIdMap[v[1]]
            end
            local icon = titleBg:getChildByName("icon" .. i)
            if not icon then
                icon = IconUtils:createItemIconById({itemId = itemId,num = v[3]})
                icon:setName("icon" .. i)
                icon:setScale(0.75)
                titleBg:addChild(icon,10)
            else
                IconUtils:updateItemIconByView(icon,{itemId = itemId,num = v[3]})
            end
            icon:setPosition((i-1)*80+300+honerOffsetX,3)
        end
    end
    -- 相互引用的两个方法
    local reflashAwardStatus
    -- 计算倒计时
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local curWeek = tonumber(TimeUtils.date("%w",nowTime))
    if curWeek == 0 then
        curWeek = 7 
    elseif curWeek == 1 then -- 周一五点前
        local nowHour = tonumber(TimeUtils.date("%H",nowTime))
        if nowHour < 5 then
            curWeek = 8
        end
    end
    local tipDes = self:getUI("bg.mainBg.seasonPanel.tipDes")
    local timeLab = self:getUI("bg.mainBg.seasonPanel.timeLab")
    local addDaySec = (8-curWeek)*86400
    print("curWeek ...",curWeek)
    local nextMondaySec = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime + addDaySec,"%Y-%m-%d " .. "05:00:00"))
    local leftFormatTime
    local deltTime
    local timeFunc = function( )
        local nowTime =  self._modelMgr:getModel("UserModel"):getCurServerTime()
        local deltTime = nextMondaySec - nowTime
        if deltTime > 0 then
            leftFormatTime = string.format("%01d天%02d小时",math.floor(deltTime/86400),math.floor(deltTime%86400/3600))
            timeLab:setString(leftFormatTime)
            tipDes:setString("后可再次领取:")
            if noPreRank then
                tipDes:setString("后可领取:")
            end
        end
        if reflashAwardStatus then
            reflashAwardStatus()
        end
    end
    timeFunc()
    if not self._timeSch then
        self._timeSch = ScheduleMgr:regSchedule(10000, self, function( )
            timeFunc()
        end)
    end

    -- 领取奖励逻辑
    local ifGet = self._leagueModel:getData().ifGet
    local preRank = self._leagueModel:getData().preRank
    local awardBtn = self._seasonPanel:getChildByName("awardBtn")
    local getImg = self._seasonPanel:getChildByName("getImg")
    reflashAwardStatus = function ()
        timeLab:setVisible(true)
        tipDes:setVisible(true)
        ifGet = self._leagueModel:getData().ifGet
        if ifGet == -1 then     -- 从未领过
            getImg:setVisible(false)
            awardBtn:setVisible(true)
            getImg:loadTexture("globalImageUI_weidacheng.png",1)
        elseif ifGet == 0 then  -- 可以领
            getImg:setVisible(false)
            awardBtn:setVisible(true)
            timeLab:setVisible(false)
            tipDes:setVisible(false)
        else                    -- 已领过
            print("ifGet...if 已领过",ifGet)
            -- getImg:setVisible(true)
            awardBtn:setVisible(false)
            getImg:loadTexture("globalImageUI5_yilingqu2.png",1)
            numDes:setString("我的排名：")
            rankNum = self._modelMgr:getModel("LeagueModel"):getData().rank 
            rank:setString(rankNum or "暂无排名")
            getImg:setVisible(false)
        end
        if noPreRank then
            getImg:setVisible(false)
            awardBtn:setVisible(false)
            timeLab:setVisible(true)
            -- timeLab:setString("")
            tipDes:setVisible(true)
        end
        UIUtils:center2Widget(numDes,rank,(numDes:getContentSize().width+rank:getContentSize().width)/2+30,0)
        UIUtils:center2Widget(timeLab,tipDes,(timeLab:getContentSize().width+tipDes:getContentSize().width)/2+30,0)
    end
    reflashAwardStatus()
    self:registerClickEvent(awardBtn,function() 
        local ifGet = self._leagueModel:getData().ifGet
        if ifGet == -1 then
            self._viewMgr:showTip(leftFormatTime .. "后可领取")
            return 
        elseif ifGet ~= 0 then
            self._viewMgr:showTip(leftFormatTime .. "后可再次领取")
            return 
        end
        self._serverMgr:sendMsg("LeagueServer", "getPreSeasonAward", {}, true, {}, function(result)
            dump(result)
            if result.reward then
                DialogUtils.showGiftGet({gifts = result.reward,notPop = true})
            end
            if reflashAwardStatus and awardBtn then
                self:initSeasonPanel()
                reflashAwardStatus()
                timeFunc()
            end
        end)
    end)  

end

function LeagueAwardView:getInRangeData( rank )
    local leagueHonor = tab["leagueHonor"]
    for i,honorD in ipairs(leagueHonor) do
        local low,high = honorD.pos[1],honorD.pos[2]
        if rank >= low and rank <= high then
            return honorD
        end
    end
end

function LeagueAwardView:touchTab( idx )
    for i,v in ipairs(self._tabs) do
        if idx ~= i then
            v:loadTextureNormal("globalBtnUI4_page1_n.png",1)
            v:loadTexturePressed("globalBtnUI4_page1_n.png",1)
            local text = v:getTitleRenderer()
            v:setTitleFontName(UIUtils.ttfName)
            -- v:setTitleFontSize(30)
            text:disableEffect()
            -- text:setPositionX(70)
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            self._panels[i]:setVisible(false)
            v:setEnabled(true)
        end
        v:setZOrder(0)
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = self._tabs[idx]
    UIUtils:tabChangeAnim(self._tabs[idx],function( )
        self._tabs[idx]:loadTextureNormal("globalBtnUI4_page1_p.png",1)
        self._tabs[idx]:loadTexturePressed("globalBtnUI4_page1_p.png",1)
        self._tabs[idx]:setTitleFontName(UIUtils.ttfName)
        -- self._tabs[idx]:setTitleFontSize(30)
        self._tabs[idx]:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        -- self._tabs[idx]:setEnabled(true)
        local text = self._tabs[idx]:getTitleRenderer()
        -- text:setPositionX(80)
        -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        text:disableEffect()
    end)
    self._panels[idx]:setVisible(true)
    if idx == 2 then
        local cellHeight = 125
        -- 定位
        local curZone = self._modelMgr:getModel("LeagueModel"):getLeague().currentZone
        local curCellIdx = math.min(math.max(curZone-1,0),9)
        local maxOffset = 0
        local posY = (8-curCellIdx)*cellHeight
        local viewHeight = 300 - cellHeight -- self._tableView:getContentSize().height
        local offset = math.min(viewHeight-posY,maxOffset)
        self._tableView:setContentOffsetInDuration(cc.p(0,offset),0.05)
    end
end

-- 第一次进入调用, 有需要请覆盖
function LeagueAwardView:onShow()

end

-- 接收自定义消息
function LeagueAwardView:reflashUI(data)
    self:addTabDot(self._tabs[1],not self._leagueModel:haveActiveAward())
    self:addTabDot(self._tabs[3],not self._leagueModel:canGetPreSeasonAward())
end

-- 页签加红点
function LeagueAwardView:addTabDot( tab,isRemove )
    if not tab then return end
    if not isRemove then
        if not tab:getChildByName("dot") then
            local dot = ccui.ImageView:create()
            dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            dot:setPosition(23,60)--node:getContentSize().width,node:getContentSize().height))
            dot:setName("dot")
            tab:addChild(dot,99)
        end
    else
        if tab:getChildByName("dot") then
            tab:getChildByName("dot"):removeFromParent()
        end
    end
end

function LeagueAwardView:addActiveTableView( )
    local tableView = cc.TableView:create(cc.size(665, 326))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(35,23))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._activePanel:addChild(tableView,2)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewActiveDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewActiveDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellActiveTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForActiveTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableActiveCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInActiveTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._ActiveTableView = tableView
end

function LeagueAwardView:scrollViewActiveDidScroll(view)
end

function LeagueAwardView:scrollViewActiveDidZoom(view)
end

function LeagueAwardView:tableCellActiveTouched(table,cell)
end

function LeagueAwardView:cellSizeForActiveTable(table,idx) 
    return 100,665
end

function LeagueAwardView:tableActiveCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local cellBoard = cell:getChildByName("cellBoard")
    if not cellBoard then
        cellBoard = self._cell1:clone()
        cellBoard:setSwallowTouches(false)
        cellBoard:setName("cellBoard")
        cellBoard:setPosition(0,3)
        cell:addChild(cellBoard)
    end
    self:updateActiveCell(cellBoard,self._activeTableData[idx+1])

    return cell
end

function LeagueAwardView:numberOfCellsInActiveTableView(table)
   return #self._activeTableData
end

function LeagueAwardView:updateActiveCell( cell,data )
    local num = cell:getChildByName("num")
    num:setFontName(UIUtils.ttfName)
    num:setString(data.condition)
    if data.condition == 3 or data.condition == 6 then 
        num:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        num:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
    end

    local des = cell:getChildByName("des")
    
    local awards = data.award 
    for i,v in ipairs(awards) do
        local itemId
        if v[1] == "tool" then
            itemId = v[2]
        else
            itemId = IconUtils.iconIdMap[v[1]]
        end
        local icon = cell:getChildByName("icon" .. i)
        if not icon then
            icon = IconUtils:createItemIconById({itemId = itemId,num = v[3]})
            icon:setName("icon" .. i)
            icon:setPosition((i-1)*79+147,10)
            icon:setScale(0.75)
            cell:addChild(icon)
        else
            IconUtils:updateItemIconByView(icon,{itemId = itemId,num = v[3]})
        end
    end
    local awardBtn = cell:getChildByName("awardBtn")
    local getTime = tonumber(self._hadGetInfo[tostring(data.id)])
    local getDes = cell:getChildByName("getDes")
    local getImg = cell:getChildByName("getImg")
    local canGet = false
    -- cell:setBackGroundImage("globalPanelUI7_cellBg3.png",1)
    -- cell:setBackGroundImageCapInsets(cc.rect(40,60,1,1))
    -- cell:setColor(cc.c3b(255, 255, 255))
    cell:setBrightness(0)
    if not getTime then -- 没有记录可领取
        if tonumber(data.condition) <= self._activeNum then
            awardBtn:setVisible(true)
            getImg:setVisible(false)
            getDes:setVisible(false)
        end
    else
        local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:00"))
        -- local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(getTime,"%Y-%m-%d 05:00:00"))

        local tempPreTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime - 86400,"%Y-%m-%d 05:00:00"))

        if ((getTime < tempTodayTime and nowTime >= tempTodayTime) or 
            (tempTodayTime > nowTime and getTime < tempPreTime)) and 
            tonumber(data.condition) <= self._activeNum then
            awardBtn:setVisible(true)
            getImg:setVisible(false)
            getDes:setVisible(false)
        else
            awardBtn:setVisible(false)
            getImg:loadTexture("globalImageUI5_yilingqu2.png",1)
            getImg:setVisible(true)
            getDes:setVisible(false)
            if tonumber(data.condition) <= self._activeNum then
            end
            -- cell:setColor(cc.c3b(182, 182, 182))
            cell:setBrightness(-50)
        end
    end

    -- 未达成状态
    if tonumber(data.condition) > self._activeNum then
        awardBtn:setVisible(false)
        getImg:setVisible(false)
        getDes:setVisible(true)
        -- getImg:loadTexture("globalImageUI_weidacheng.png",1)
        cell:setBrightness(0)
    end
    awardBtn:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255),1)
    self:registerClickEvent(awardBtn,function( )
        self._serverMgr:sendMsg("LeagueServer", "getDailyAward", {id=data.id}, true, {}, function(result)
            self._hadGetInfo = self._leagueModel:getLeague().dailyReward or {}
            self._activeTableData = {}
            for k,v in ipairs(tab.leagueReward) do
                table.insert(self._activeTableData,clone(v))
            end
            self:sortDialyTable()
            self._ActiveTableView:reloadData()
            DialogUtils.showGiftGet({gifts = data.award,notPop = true})
        end)
    end)
end

-- 
function LeagueAwardView:addStageTableView( )
    local tableView = cc.TableView:create(cc.size(665, 295))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(35,18))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._stagePanel:addChild(tableView,2)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewStageDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewStageDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellStageTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForStageTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableStageCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInStageTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._tableView = tableView
end

function LeagueAwardView:scrollViewStageDidScroll(view)
end

function LeagueAwardView:scrollViewStageDidZoom(view)
end

function LeagueAwardView:tableCellStageTouched(table,cell)
end

function LeagueAwardView:cellSizeForStageTable(table,idx) 
    return 125,665
end

function LeagueAwardView:tableStageCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local cellBoard = cell:getChildByName("cellBoard")
    if not cellBoard then
        cellBoard = self._cell2:clone()
        cellBoard:setSwallowTouches(false)
        cellBoard:setName("cellBoard")
        cellBoard:setPosition(0,0)
        cell:addChild(cellBoard)
    end
    self:updateStageCell(cellBoard,self._stageTableData[idx+1])
    return cell
end

function LeagueAwardView:numberOfCellsInStageTableView(table)
   return #self._stageTableData
end

function LeagueAwardView:updateStageCell( cell,data )
    local stageImg = cell:getChildByName("stageImg")
    stageImg:loadTexture(data.icon .. ".png",1)
    local stageName = cell:getChildByName("stageName")
    stageName:setColor(cc.c3b(250, 242, 192))
    stageName:enable2Color(2,cc.c4b(255, 195, 17, 255))
    stageName:setFontName(UIUtils.ttfName)
    -- stageName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    stageName:setString(lang(data.name))

    local des = cell:getChildByName("des")
    des:setFontName(UIUtils.ttfName)
    local awards = data.onceaward
    if not next(awards) then
        for i=1,3 do
            local icon = cell:getChildByName("icon" .. i)
            if icon then
                icon:removeFromParent()
            end
        end
        des:setVisible(true)
    else
        des:setVisible(false)
    end
    for i,v in ipairs(awards) do
        local itemId
        if v[1] == "tool" then
            itemId = v[2]
            itemId = self._modelMgr:getModel("LeagueModel"):changeLeagueHero2ItemId(itemId)
        else
            itemId = IconUtils.iconIdMap[v[1]]
        end
        local icon = cell:getChildByName("icon" .. i)
        if not icon then
            icon = IconUtils:createItemIconById({itemId = itemId,num = v[3]})
            icon:setName("icon" .. i)
            icon:setPosition((i-1)*78+148,20)
            icon:setScale(0.75)
            cell:addChild(icon)
        else
            IconUtils:updateItemIconByView(icon,{itemId = itemId,num = v[3]})
        end
    end
    local awards = data.weeklyawards
    for i,v in ipairs(awards) do
        local itemId
        if v[1] == "tool" then
            itemId = v[2]
            -- 转化 leaguehero 为当前的赛季物品
            itemId = self._modelMgr:getModel("LeagueModel"):changeLeagueHero2ItemId(itemId)
        else
            itemId = IconUtils.iconIdMap[v[1]]
        end
        local icon = cell:getChildByName("weekly" .. i)
        if not icon then
            icon = IconUtils:createItemIconById({itemId = itemId,num = v[3]})
            icon:setName("weekly" .. i)
            icon:setPosition((i-1)*78+412,20)
            icon:setScale(0.75)
            cell:addChild(icon)
        else
            IconUtils:updateItemIconByView(icon,{itemId = itemId,num = v[3]})
        end
    end
    local selfTag = cell:getChildByName("selfTag")
    if selfTag then
        selfTag:setVisible(false)
    end
    if self._curZone == data.id then
        if not selfTag then
            selfTag = ccui.ImageView:create()
            selfTag:loadTexture("globalImageUI6_connerTag_r.png",1)
            selfTag:setName("selfTag")
            selfTag:setAnchorPoint(cc.p(1,1))
            selfTag:setPosition(70,120)
            selfTag:setCascadeOpacityEnabled(true)
            selfTag:getVirtualRenderer():getSprite():setFlipX(true)
            -- selfTag:setOpacity(0)

            local selfName = ccui.Text:create()
            selfName:setString("当前")
            selfName:setFontSize(22)
            selfName:setFontName(UIUtils.ttfName)
            selfName:setColor(cc.c3b(255, 255, 255))
            selfName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            selfName:setRotation(-41)
            selfName:setPosition(25,36)
            selfTag:addChild(selfName)
            -- selfTag:setScale(0.9)
            cell:addChild(selfTag,999)
        end
        selfTag:setVisible(true)
    end
end

function LeagueAwardView:addSeasonTableView( higher )
    local tableView = cc.TableView:create(cc.size(665, higher and 450 or 360))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(35,10))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._seasonPanel:addChild(tableView,2)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewSeasonDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewSeasonDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellSeasonTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForSeasonTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableSeasonCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInSeasonTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._seasonTableView = tableView
end

function LeagueAwardView:scrollViewSeasonDidScroll(view)
end

function LeagueAwardView:scrollViewSeasonDidZoom(view)
end

function LeagueAwardView:tableCellSeasonTouched(table,cell)
end

function LeagueAwardView:cellSizeForSeasonTable(table,idx) 
    return 125,665
end

function LeagueAwardView:tableSeasonCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local cellBoard = cell:getChildByName("cellBoard")
    if not cellBoard then
        cellBoard = self._cell3:clone()
        cellBoard:setSwallowTouches(false)
        cellBoard:setVisible(true)
        cellBoard:setName("cellBoard")
        cellBoard:setPosition(0,0)
        cell:addChild(cellBoard)
    end
    self:updateSeasonCell(cellBoard,self._seasonTableData[idx+1])
    return cell
end

function LeagueAwardView:numberOfCellsInSeasonTableView(table)
   return #self._seasonTableData
end

local function getRange( num1,num2 )
    if num1 == num2 then
        return num1
    elseif num1 > num2 then
        return num2 .. "~" .. num1
    elseif num1 < num2 then
        return num1 .. "~" .. num2
    end
end

function LeagueAwardView:updateSeasonCell( cell,data )
    -- dump(data,"...data...season.....",10)
    ---[[ 用数据初始化cell
    local range = cell:getChildByFullName("range")
    local pos = data.pos
    local rangeStr = "第" .. getRange(pos[1],pos[2]) .. "名"
    range:setColor(cc.c3b(255, 252, 226))
    range:enable2Color(1,cc.c4b(255, 232, 125, 255))
    range:setString(rangeStr)

    local range2 = cell:getChildByFullName("range2")
    range2:setString("第" .. getRange(pos[1],pos[2]) .. "名")

    local awards = data.monthlyawards 
    for i,v in ipairs(awards) do
        local itemId
        if v[1] == "tool" then
            itemId = v[2]
        else
            itemId = IconUtils.iconIdMap[v[1]]
        end
        local icon = cell:getChildByName("icon" .. i)
        if not icon then
            icon = IconUtils:createItemIconById({itemId = itemId,num = v[3]})
            icon:setName("icon" .. i)
            icon:setPosition((i-1)*80+350,20)
            icon:setScale(0.75)
            cell:addChild(icon)
        else
            IconUtils:updateItemIconByView(icon,{itemId = itemId,num = v[3]})
        end
    end
end

function LeagueAwardView:checkAwardStatus( id )
    if not self._hadGetInfo or not self._hadGetInfo[tostring(id)] then return tonumber(id) <= self._activeNum,false end
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local getTime = tonumber(self._hadGetInfo[tostring(id)])
    local tempTodayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:00"))
    -- local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(getTime,"%Y-%m-%d 05:00:00"))

    local tempPreTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime - 86400,"%Y-%m-%d 05:00:00"))
    local tempTomorrowTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime + 86400,"%Y-%m-%d 05:00:00"))

    if ((getTime < tempTodayTime and nowTime >= tempTodayTime) or 
        (tempTodayTime > nowTime and getTime < tempPreTime)) and 
        tonumber(id) <= self._activeNum then
        return true
    end
    return false
end

-- 活跃页签内容排序
function LeagueAwardView:sortDialyTable( )
    table.sort(self._activeTableData,function( a,b )
        local ac = self:checkAwardStatus(a.id)
        local bc = self:checkAwardStatus(b.id)
        if ac ~= bc then
            return ac
        else
            if ac then 
                return a.id < b.id 
            else
                local aact = tonumber(a.id) <= self._activeNum
                local bact = tonumber(b.id) <= self._activeNum
                if aact ~= bact then
                    return bact
                else
                    return a.id < b.id
                end
            end
        end
    end)
end

function LeagueAwardView:onDestroy( )
    if self._fiveSche then
        ScheduleMgr:unregSchedule(self._fiveSche)
        self._fiveSche = nil
    end
     if self._timeSch then
        ScheduleMgr:unregSchedule(self._timeSch)
        self._timeSch = nil
    end
    self.super.onDestroy(self)
end

return LeagueAwardView