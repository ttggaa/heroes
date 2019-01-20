--[[
    Filename:    AcWorldCupView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-05-8 16:57
    Description: 竞猜系统
--]]

local AcWorldCupView = class("AcWorldCupView", BasePopView)

local sysGuessTeam = tab.guessTeam
local sysGuessBet = tab.guessBet

function AcWorldCupView:ctor(param)
	AcWorldCupView.super.ctor(self)
    self._worldCupModel = self._modelMgr:getModel("WorldCupModel")
    self._userModel = self._modelMgr:getModel("UserModel")

	self._tabIndex = 0    --默认第一个页签
    self._raceIndex = 1   --32强默认第一页
    self._callback = param.callback
end

function AcWorldCupView:onInit()
    self._worldCupModel:setIsOpened(true)

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	UIUtils:reloadLuaFile("activity.worldCup.AcWorldCupView")
            UIUtils:reloadLuaFile("activity.worldCup.AcWorldCupBetView")
            UIUtils:reloadLuaFile("activity.worldCup.AcWorldCupRankView")
        elseif eventType == "enter" then
            local tab1 = self:getUI("bg.tab1")
            self:tabButtonClick(tab1)
        end
    end)

	local caidaiAnim = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
    caidaiAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 100)
    self:addChild(caidaiAnim)

	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
        if self._callback then
            self._callback()
        end
		self:close()
		end)

	local des = self:getUI("bg.des")
    des:setString(lang("jingcai_main"))
    self:getUI("bg.bg1"):loadTexture("asset/bg/ac_worldCupBg.png")
    self:getUI("bg.view5.roleImg"):loadTexture("asset/bg/ac_worldCup_role.png")
    self:getUI("bg.nothing"):setVisible(false)
    
    local ruleBtn = self:getUI("bg.ruleBtn")
    ruleBtn:setPositionX(des:getPositionX() + des:getContentSize().width + 20)
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("guess_Rule")},true)  
        end)

    local leftBtn = self:getUI("bg.view4.leftBtn")
    self:registerClickEvent(leftBtn, function()
        if self._raceIndex < 1 then
            self._raceIndex = 1
            return
        end
        self._raceIndex = self._raceIndex - 1
        self:refreshView4()
        end)

    local rightBtn = self:getUI("bg.view4.rightBtn")
    self:registerClickEvent(rightBtn, function()
        if self._raceIndex > 2 then
            self._raceIndex = 2
            return
        end
        self._raceIndex = self._raceIndex + 1
        self:refreshView4()
        end)

    self._cell1 = self:getUI("cell1")
    self._cell2 = self:getUI("cell2")
    self._cell3 = self:getUI("cell3")
    self._cell4 = self:getUI("cell4")
    self._cell1:setVisible(false)
    self._cell2:setVisible(false)
    self._cell3:setVisible(false)
    self._cell4:setVisible(false)

    self._tableBg = self:getUI("bg.tableBg")
    self._view4 = self:getUI("bg.view4")
    self._view5 = self:getUI("bg.view5")
    self._view6 = self:getUI("bg.view6")
    self._tableBg:setVisible(false)
    self._view4:setVisible(false)
    self._view5:setVisible(false)
    self._view5:setVisible(false)

    -- 当前
    local tab1 = self:getUI("bg.tab1")
    -- 已下注
    local tab2 = self:getUI("bg.tab2")
    -- 已结束
    local tab3 = self:getUI("bg.tab3")
    -- 竞赛
    local tab4 = self:getUI("bg.tab4")
    -- 竞赛记录
    local tab5 = self:getUI("bg.tab5")

    self:registerClickEvent(tab1, function(sender)self:tabButtonClick(sender) end)
    self:registerClickEvent(tab2, function(sender)self:tabButtonClick(sender) end)
    self:registerClickEvent(tab3, function(sender)self:tabButtonClick(sender) end)
    self:registerClickEvent(tab4, function(sender)self:tabButtonClick(sender) end)
    self:registerClickEvent(tab5, function(sender)self:tabButtonClick(sender) end)
    
    self._tabList = {}
    table.insert(self._tabList, tab1)
    table.insert(self._tabList, tab2)
    table.insert(self._tabList, tab3)
    table.insert(self._tabList, tab4)
    table.insert(self._tabList, tab5)

    self:setListenReflashWithParam(true)
    self:listenReflash("WorldCupModel", self.handelModelListen)
end

function AcWorldCupView:reflashUI()
    local numDes = self:getUI("cell1.numDes")
    numDes:setVisible(false)

    local numDes = self:getUI("cell2.numDes")
    numDes:setVisible(false)

    for i=1, 2 do
        local flag = self:getUI("cell1.flag" .. i)
        flag:setPositionY(208)
    end

    local Image_23 = self:getUI("cell1.Image_23")
    Image_23:setPositionY(195)
end

function AcWorldCupView:setBtnState(inBtn)
	if self._tabList == nil or next(self._tabList) == nil then
        return
    end

    local btnName = {tab1 = "当前", tab2 = "已下注", tab3 = "已结束", tab4 = "赛程", tab5 = "历史竞猜",}
    for k,v in pairs(self._tabList) do
        v:setBright(true)
        v:setEnabled(true)
        v:setTitleText("")
        if v.title ~= nil then
            v.title:removeFromParent(true)
            v.title = nil
        end

        local btnTitle = ccui.Text:create()
        btnTitle:setFontName(UIUtils.ttfName)
        btnTitle:setFontSize(20)
        btnTitle:setColor(cc.c4b(79,127,172,255))
        btnTitle:setPosition(v:getContentSize().width * 0.5, v:getContentSize().height * 0.5)
        btnTitle:setString(btnName[v:getName()])
        v.title = btnTitle
        v:addChild(btnTitle)
    end
    
    if inBtn then
        inBtn:setBright(false)
        inBtn:setEnabled(false)
        inBtn.title:setFontSize(22)
        inBtn.title:setColor(cc.c4b(190,238,255,255))
    end
end

function AcWorldCupView:handelModelListen()
    self:refreshView()
end

function AcWorldCupView:tabButtonClick(sender)
	if sender == nil then 
        return 
    end

    local tabName = sender:getName()
    local tabIndex = tonumber(string.sub(tabName, 4, string.len(tabName)))
    local is32Over = self._worldCupModel:getIs32Over()
    if is32Over and tabIndex == 4 then
        tabIndex= 6
    end

    if self._tabIndex == tabIndex then  
        return
    end
    self._tabIndex = tabIndex
    self:setBtnState(sender)
    self._raceIndex = 1

    self._tableBg:setVisible(false)
    self._view4:setVisible(false)
    self._view5:setVisible(false)
    self._view6:setVisible(false)

    self:refreshView()
end

function AcWorldCupView:updateCell1(item, idx)
    item:setVisible(true)
    local cellData = self._data[idx + 1]

    --比赛名
    local name = item:getChildByName("title")
    name:setString(lang(cellData["game_id"]))
    if OS_IS_WINDOWS then
        name:setString(lang(cellData["game_id"]) .. "_" .. cellData["id"])
    end
    
    --开始时间
    local time = item:getChildByName("time")
    time:setString(cellData["game_time"])

    --竞猜人数
    local numDes = item:getChildByName("numDes")
    numDes:setString((cellData["jnum"] or 0) .. "人竞猜")

    --flag/name
    for i=1, 2 do
        local flagId = cellData["team_" .. i]
        local flag = item:getChildByName("flag" .. i)
        local resImg = sysGuessTeam[flagId]["art"] or "globalImageUI6_meiyoutu"
        flag:loadTexture(resImg .. ".png", 1)
        local flagName = item:getChildByFullName("flag" .. i .. ".name")
        if OS_IS_WINDOWS then
            flagName:setString(lang(sysGuessTeam[flagId]["teamID"]) .. "_" .. flagId)
        else
            flagName:setString(lang(sysGuessTeam[flagId]["teamID"]))
        end
        
    end

    --投注按钮
    local curTime = self._userModel:getCurServerTime()
    for i=1, 3 do
        local winBtn = item:getChildByName("win" .. i)
        local matchTime = TimeUtils.getIntervalByTimeString(cellData["game_time"])
        if curTime >= matchTime then    --投注截止
            winBtn:setSaturation(-180)
        else
            winBtn:setSaturation(0)
        end

        winBtn:stopAllActions()
        winBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create(function()
                local curTime = self._userModel:getCurServerTime()
                if curTime >= matchTime then
                    winBtn:setSaturation(-180)
                end
                end),
            cc.DelayTime:create(1)
            )))
        
        self:registerClickEvent(winBtn, function()
            local curTime = self._userModel:getCurServerTime()
            if curTime >= matchTime then
                self._viewMgr:showTip("投注已截止")
                return
            end

            self._viewMgr:showDialog("activity.worldCup.AcWorldCupBetView", {uiType = i, data = cellData, callback = function()
                self:refreshView()
                end}, true)
            end)
    end

    return item
end

function AcWorldCupView:updateCell2(item, idx)
    item:setVisible(true)
    local cellData = self._data[idx + 1]
    local betList = self._worldCupModel:getBetList()
    local betData = betList[tostring(cellData["id"])]
    betData[3] = math.max(1, betData[3])


    local name = item:getChildByName("title")
    name:setString(lang(cellData["game_id"]))
    if OS_IS_WINDOWS then
        name:setString(lang(cellData["game_id"]) .. "_" .. cellData["id"])
    end

    local time = item:getChildByName("time")
    time:setString(cellData["game_time"])

    local numDes = item:getChildByName("numDes")
    numDes:setString((cellData["jnum"] or 0) .. "人竞猜")


    local winner = item:getChildByName("winner")
    winner:loadTexture("worldCup_Win" .. betData[3] .. ".png", 1)

    local matchTime = TimeUtils.getIntervalByTimeString(cellData["game_time"])
    local Label_54 = item:getChildByFullName("rwdNode.Label_54")
    self:setCountTime(Label_54, matchTime)

    for i=1, 2 do
        local flagId = cellData["team_" .. i]
        local flag = item:getChildByName("flag" .. i)
        local resImg = sysGuessTeam[flagId]["art"] or "globalImageUI6_meiyoutu"
        flag:loadTexture(resImg .. ".png", 1)
        local flagName = item:getChildByFullName("flag" .. i .. ".name")
        flagName:setString(lang(sysGuessTeam[flagId]["teamID"]))

        --奖励
        local sysBetData = sysGuessBet[betData[1]]
        local oddsNum = cellData["odds"][betData[3]]
        local costType = sysBetData["cost"][1]
        local costNum = sysBetData["cost"][3]
        local costId = IconUtils.iconIdMap[costType] or sysBetData["cost"][2]
        local toolD = tab:Tool(tonumber(costId))
        if not item["_rwdIcon" .. i] then
            local rwdIcon = IconUtils:createItemIconById({itemId = costId,itemData = toolD})
            rwdIcon:setScale(0.3)
            rwdIcon:setPosition(109, 31)
            item["_rwdIcon" .. i] = rwdIcon
            item:getChildByFullName("rwdNode"):addChild(rwdIcon)
        else
            IconUtils:updateItemIconByView(item["_rwdIcon" .. i], {itemId = costId,itemData = toolD})
        end

        --数量
        local countNum = 0
        if i == 1 then
            countNum = ItemUtils.formatItemCount(costNum)
            item["_rwdIcon" .. i]:setPosition(109, 65)
        else
            countNum = ItemUtils.formatItemCount(costNum * oddsNum)
            item["_rwdIcon" .. i]:setPosition(109, 32)
        end

        local rwdNum = item:getChildByFullName("rwdNode.rwdNum" .. i)
        rwdNum:setString(countNum .. "个")
        rwdNum:setPositionX(140)
        rwdNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    return item
end

function AcWorldCupView:updateCell3(item, idx)
    item:setVisible(true)
    local cellData = self._data[idx + 1]
    local betList = self._worldCupModel:getBetList()
    local betData = betList[tostring(cellData["id"])]

    local name = item:getChildByName("title")
    name:setString(lang(cellData["game_id"]))
    if OS_IS_WINDOWS then
        name:setString(lang(cellData["game_id"]) .. "_" .. cellData["id"])
    end

    local time = item:getChildByName("time")
    time:setString(cellData["game_time"])

    for i=1, 2 do
        local flagId = cellData["team_" .. i]
        local flag = item:getChildByName("flag" .. i)
        local resImg = sysGuessTeam[flagId]["art"] or "globalImageUI6_meiyoutu"
        flag:loadTexture(resImg .. ".png", 1)
        local flagName = item:getChildByFullName("flag" .. i .. ".name")
        flagName:setString(lang(sysGuessTeam[flagId]["teamID"]))
    end

    local numDes = item:getChildByName("numDes")
    numDes:setString((cellData["jsNum"] or 0) .. "人竞猜成功!")

    local winner = item:getChildByName("winner")
    local team1 = cellData["team_1"]
    local team2 = cellData["team_2"]
    local disTeam = math.abs(cellData["gamescore"][1] - cellData["gamescore"][2])
    local tempOdds = nil
    if cellData["gamesesult"] == team1 then
        if disTeam >= 3 then
            winner:setString("红大胜")
            tempOdds = 1
        else
            winner:setString("红胜")
            tempOdds = 2
        end
        winner:setColor(cc.c4b(255,62,62,255))
    elseif cellData["gamesesult"] == team2 then
        if disTeam >= 3 then
            tempOdds = 5
            winner:setString("蓝大胜")
        else
            tempOdds = 4
            winner:setString("蓝胜")
        end
        winner:setColor(cc.c4b(125,246,255,255))
    else
        tempOdds = 3
        winner:setString("平局")
        winner:setColor(cc.c4b(89,211,252,255))
    end

    local reviewBtn = item:getChildByName("reviewBtn")
    self:registerClickEvent(reviewBtn, function()
        self._viewMgr:showDialog("activity.worldCup.AcWorldCupDetailView", {data = cellData}, true)
        end)

    local win = item:getChildByName("win")
    local fail = item:getChildByName("fail")
    win:setVisible(false)
    fail:setVisible(false)

    local isMatch = false   --押注是否对
    if betData[3] == tempOdds then
        isMatch = true
    else
        if betData[3] == 2 and tempOdds == 1 then   --押胜结果是大胜也算
            isMatch = true
        elseif betData[3] == 4 and tempOdds == 5 then  --押胜结果是大胜也算
            isMatch = true
        end
    end
 
    if betData[2] == cellData["gamesesult"] and isMatch then
        win:setVisible(true)

        --奖励
        local sysBetData = tab.guessBet[betData[1]]
        local costType = sysBetData["cost"][1]
        local costNum = sysBetData["cost"][3]
        local costId = IconUtils.iconIdMap[costType] or sysBetData["cost"][2]
        local toolD = tab:Tool(tonumber(costId))
        if not item["rwdIcon"] then
            local rwdIcon = IconUtils:createItemIconById({itemId = costId,itemData = toolD})
            rwdIcon:setScale(0.28)
            rwdIcon:setPosition(105, 12)
            item["rwdIcon"] = rwdIcon
            win:addChild(rwdIcon)
        else
            IconUtils:updateItemIconByView(item["rwdIcon"], {itemId = costId,itemData = toolD})
        end

        --数量
        local countNum = ItemUtils.formatItemCount(costNum)
        local rwdNum = item:getChildByFullName("win.Label_205")
        rwdNum:setString(countNum .. "个")
        rwdNum:setPosition(138, 26)

    else
        fail:setVisible(true)
    end

    return item
end

function AcWorldCupView:updateCell4(item, idx)
    item:setVisible(true)

    local title = item:getChildByName("title")
    title:setString(lang("xiaozusai_" .. (idx + 1)))
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local node1 = item:getChildByName("node1")
    for i=1, 6 do
        local nodeData = self._data[idx + 1][i]
        local node = item:getChildByName("node" .. i)
        if not node then
            node = node1:clone()
            node:setPosition(0, (6-i) * node:getContentSize().height)
            node:setName("node" .. i)
            item:addChild(node)
        end

        node:setVisible(true)
        node:setSwallowTouches(false)

        --flag / name
        for m=1, 2 do
            local flag = node:getChildByName("flag" .. m)
            local flagName = node:getChildByFullName("flag" .. m .. ".name")
            local flagId = nodeData["team_" .. m]
            local resImg = sysGuessTeam[flagId]["art"] or "globalImageUI6_meiyoutu"
            flag:loadTexture(resImg .. ".png", 1)
            flagName:setString(lang(sysGuessTeam[flagId]["teamID"]))

            if OS_IS_WINDOWS then
                flagName:setString(lang(sysGuessTeam[flagId]["teamID"]) .. "_" .. nodeData["id"])
            end
        end

        local time = node:getChildByFullName("time")
        time:setString(nodeData["game_time"])
    end

    return item
end

function AcWorldCupView:refreshView()
    if self._tabIndex == 1 then
        self._worldCupModel:refreshGuessInfo()   --刷新比赛状态
    end
    if self._tabIndex == 3 then
        self._worldCupModel:refreshHasEndInfo()   --刷新比赛状态
    end

    self._data = self._worldCupModel:getDataByType(self._tabIndex)

    self:getUI("bg.nothing"):setVisible(false)
    if next(self._data) == nil and self._tabIndex <= 3 then
        self:getUI("bg.nothing"):setVisible(true)
    end

    self._tableBg:setVisible(false)
    if self._tabIndex > 4 then
        self["refreshView" .. self._tabIndex](self)
    else
        if self._tableView ~= nil then 
            self._tableView:removeFromParent()
            self._tableView = nil
        end

        self._tableBg:setVisible(true)
        local tableW, tableH = self._tableBg:getContentSize().width, self._tableBg:getContentSize().height
        self._listBgHeight = tableH
        self._tableView = cc.TableView:create(cc.size(tableW, tableH))
        self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self._tableView:setPosition(cc.p(0, 0))
        self._tableView:setDelegate()
        self._tableView:setBounceable(true) 
        self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_LEFTRIGHT)
        self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
        self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
        self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
        self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
        self._tableBg:addChild(self._tableView)
        if self._tableView.setDragSlideable ~= nil then 
            self._tableView:setDragSlideable(true)
        end

        self._tableView:reloadData()      
    end
end

function AcWorldCupView:scrollViewDidScroll(view)

end

function AcWorldCupView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end 

    local curIndex = self._tabIndex
    if cell.item == nil then
        local item = self["_cell" .. curIndex]:clone()
        item = self["updateCell" .. curIndex](self, item, idx)
        item:setPosition(cc.p(0,0))
        item:setAnchorPoint(cc.p(0,0))
        cell.item = item
        cell:addChild(item)
    else
        self["updateCell" .. curIndex](self, cell.item, idx)
    end

    return cell
end

function AcWorldCupView:cellSizeForTable(table,idx)
    local size = self["_cell" .. self._tabIndex]:getContentSize()
    return size.height, size.width
end

function AcWorldCupView:numberOfCellsInTableView(table)
    return #self._data
end

function AcWorldCupView:tableCellWillRecycle(table,cell)

end

function AcWorldCupView:refreshView5()
    self._view5:setVisible(true)
    for i=1, 6 do
        self:getUI("bg.view5.Image_50.num" .. i):setString("")
    end
    for i=1, 7 do
        self:getUI("bg.view5.Image_50_0.name" .. i):setString("")
        self:getUI("bg.view5.Image_50_0.num" .. i):setString("")
    end
    self:getUI("bg.view5.noTxt"):setVisible(false)

    local data = self._worldCupModel:getCathecticInfo()
    --左侧
    local fInfo = data["rInfo"] or {}
    local temp = {"sum", "successNum", "ratio", "rank", "beyond", "comment"}
    local level = tab.setting["GUESS_SHARE_SHOW"].value
    for i=1, 6 do
        local numLab = self:getUI("bg.view5.Image_50.num" .. i)
        local score = fInfo[temp[i]] or 0
        if i <= 5 then
            numLab:setString(score)
            if i == 5 then
                numLab:setString(math.max(0, math.min(100, score)) .. "%")
                local Label_55_5 = self:getUI("bg.view5.Image_50.Label_55_5")
                Label_55_5:setPositionX(numLab:getContentSize().width + numLab:getPositionX() + 5)
            elseif i == 3 then
                numLab:setString(score .. "%")
            end
        else
            if score == 0 then  --暂无信息隐藏
                numLab:setString("")
                self:getUI("bg.view5.Image_50.Label_55_3"):setString("")
            else
                numLab:setString(level[score + 1] or "")
                numLab:enable2Color(1, cc.c4b(230, 186, 66, 255))
            end
            
        end
    end

    
    --右侧
    local tempGInfo = {}    --奖励列表重组
    local tempNum = 0
    local gInfo = data["gInfo"] or {}
    for k,v in pairs(gInfo) do
        if tonumber(k) >= 7 then
            tempNum = tempNum + v
        else
            table.insert(tempGInfo, {tonumber(k), v})
        end
    end

    if tempNum > 0 then
        table.insert(tempGInfo, {tonumber(100), tempNum})   --15资质碎片
    end

    
    if #tempGInfo == 0 then
        self:getUI("bg.view5.noTxt"):setVisible(true)
    else
        for i=1, 7 do
            local nameLab = self:getUI("bg.view5.Image_50_0.name" .. i)
            local numLab = self:getUI("bg.view5.Image_50_0.num" .. i)
            local costData = tempGInfo[i]

            if costData then
                if costData[1] == 100 then
                    nameLab:setString("15资质兵团碎片:")
                    numLab:setString(costData[2])
                else
                    local cost = sysGuessBet[costData[1]]["cost"]
                    dump(cost, "cost")
                    iconId = IconUtils.iconIdMap[cost[1]] or cost[2]
                    local name = tab.tool[iconId]["name"] or ""
                    nameLab:setString(lang(name) .. ":")
                    numLab:setString(costData[2])
                end
                
            else
                nameLab:setVisible(false)
                numLab:setVisible(false)
            end

            numLab:setPositionX(nameLab:getPositionX() + nameLab:getContentSize().width + 10)
        end
    end 

    local shareBtn = self:getUI("bg.view5.shareBtn")
    self:registerClickEvent(shareBtn, function()
        self._viewMgr:showDialog("share.ShareBaseView", {moduleName = "ShareWorldCupModule", sData = data})
        end)

    local rankBtn = self:getUI("bg.view5.rankBtn")
    self:registerClickEvent(rankBtn, function()
        self._viewMgr:showDialog("activity.worldCup.AcWorldCupRankView", {}, true)
        end)
end

function AcWorldCupView:refreshView6()
    self._view6:setVisible(true)
    
    local function createFlagInfo(inItem, teamData)
        local time = inItem:getChildByName("time")
        if time then
            if teamData then
                time:setString(teamData["game_time"])
            else
                time:setString("时间待定")
            end
        end
        

        for i=1, 2 do
            local flag = inItem:getChildByName("flag" .. i)   --51height
            local flagName = inItem:getChildByFullName("flag" .. i .. ".name")
            local none = inItem:getChildByFullName("none" .. i)
            flag:setVisible(false)
            flagName:setVisible(false)
            none:setVisible(false)

            if teamData and teamData["team_" .. i] ~= "" then
                flag:setVisible(true)
                flagName:setVisible(true)
                local flagId = teamData["team_" .. i]
                local resImg = sysGuessTeam[flagId]["art"] or "globalImageUI6_meiyoutu"
                flag:loadTexture(resImg .. ".png", 1)
                flagName:setString(lang(sysGuessTeam[flagId]["teamID"]))
            else
                none:setVisible(true)
            end
        end
    end

    --16强
    for i= 1, 8 do
        local match = self:getUI("bg.view6.match1" .. i)
        local cellData = self._data[16][i]
        createFlagInfo(match, cellData)
    end

    --8强
    for i= 1, 4 do
        local match = self:getUI("bg.view6.match2" .. i)
        local cellData = self._data[8][i]
        createFlagInfo(match, cellData)
    end

    --4强
    for i= 1, 2 do
        local match = self:getUI("bg.view6.match3" .. i)
        local cellData = self._data[4][i]
        createFlagInfo(match, cellData)
    end

    --2强
    local match = self:getUI("bg.view6.match41")
    local cellData = self._data[2][1]
    createFlagInfo(match, cellData)

end

function AcWorldCupView:setCountTime(inObj, endTime)
    local curTime = self._userModel:getCurServerTime()
    local endTime = endTime or 0

    local tempTime = endTime - curTime  --86400
    local day, hour, minute, second, tempValue  
    inObj:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempTime = tempTime - 1
            tempValue = tempTime
            day = math.floor(tempValue/86400) 
            tempValue = tempValue - day*86400
            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600
            minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
            if day == 0 then
                showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
            end

            if tempTime <= 0 then
                showTime = "00天00:00:00"
            end
            inObj:setString(showTime)
        end),cc.DelayTime:create(1))
    ))
end

function AcWorldCupView:getAsyncRes()
    return {{"asset/ui/acWorldCup.plist", "asset/ui/acWorldCup.png"}}
end

function AcWorldCupView:dtor()

end


return AcWorldCupView   