--[[
    Filename:    CrossAwardView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-23 11:29:57
    Description: File description
--]]

local CrossAwardView = class("CrossAwardView",BasePopView)
function CrossAwardView:ctor()
    self.super.ctor(self)
    self._tabSelect = 3
end

-- 初始化UI后会调用, 有需要请覆盖
function CrossAwardView:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")
    self._crossModel = self._modelMgr:getModel("CrossModel")

    self._title = self:getUI("bg.headBg.title")
    UIUtils:setTitleFormat(self._title, 1)

    self._activeCfg = clone(tab.cpActiveReward)

    self:registerClickEventByName("bg.closeBtn",function( )
        UIUtils:reloadLuaFile("cross.CrossAwardView")
        self:close()
    end)

    local ruleBtn = self:getUI("bg.rankPanel.ruleBtn")
    self:registerClickEvent(ruleBtn, function()
        UIUtils:reloadLuaFile("cross.CrossAwardRuleView")
        self._viewMgr:showDialog("cross.CrossAwardRuleView")
    end)

    self._rankPanel = self:getUI("bg.rankPanel")
    self._scorePanel = self:getUI("bg.scorePanel")
    self._activePanel = self:getUI("bg.activePanel")

    self._rankCell = self:getUI("rankCell")
    self._rankCell:setVisible(false)

    self._activeCell = self:getUI("activeCell")
    self._activeCell:setVisible(false)

    local tab1 = self:getUI("bg.tab1")
    local tab2 = self:getUI("bg.tab2")
    local tab3 = self:getUI("bg.tab3")

    self:registerClickEvent(tab1, function(sender)self:tabButtonClick(sender, 1) end)
    self:registerClickEvent(tab2, function(sender)self:tabButtonClick(sender, 2) end)
    self:registerClickEvent(tab3, function(sender)self:tabButtonClick(sender, 3) end)
    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    table.insert(self._tabEventTarget, tab3)

    local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    self._chanNum = dayinfo["day76"] or 0

    self:addTableView()
    self:addActiveTableView()
    self:initActiveInfo()

    self:tabButtonClick(self:getUI("bg.tab" .. (self._tabSelect or 3)), (self._tabSelect or 3))

end

function CrossAwardView:updateTitleBg()
    local arenaData = self._crossModel:getData()
    dump(arenaData)
    local setStr1 = arenaData["sec1"]
    local setStr2 = arenaData["sec2"]
    local sec = arenaData[setStr] 
    local sNameStr1 = self._crossModel:getServerName(setStr1)
    local sNameStr2 = self._crossModel:getServerName(setStr2)

    local bProgress = self:getUI("bg.scorePanel.barpanel.expBg.sProgress1")
    -- local sProgress2 = self:getUI("bg.scorePanel.barpanel.expBg.sProgress2")
    local sname1 = self:getUI("bg.scorePanel.barpanel.sname1")
    local sname2 = self:getUI("bg.scorePanel.barpanel.sname2")
    local sscore1 = self:getUI("bg.scorePanel.barpanel.sscore1")
    local sscore2 = self:getUI("bg.scorePanel.barpanel.sscore2")
    sname1:setString(sNameStr1)
    sname2:setString(sNameStr2)

    local sec1score = arenaData["sec1score"] or 0
    local sec2score = arenaData["sec2score"] or 0
    local scoreStr = "(" .. sec1score .. "分)"
    sscore1:setString(scoreStr)
    local scoreStr = "(" .. sec2score .. "分)"
    sscore2:setString(scoreStr)

    sscore1:setPositionX(sname1:getPositionX()+sname1:getContentSize().width)
    sscore2:setPositionX(sname2:getPositionX()-sname2:getContentSize().width)

    if sec1score == 0 then
        sec1score = 1
    end
    if sec2score == 0 then
        sec2score = 1
    end
    local percentStr = sec1score/(sec1score+sec2score)
    if percentStr < 0 then
        percentStr = 0
    end
    if percentStr > 1 then
        percentStr = 1
    end
    bProgress:setScaleX(percentStr)
end

function CrossAwardView:reflashUI()

end

------------------------------------------rank table view------------------------------
--[[
用tableview实现
--]]
function CrossAwardView:addTableView()
    local tableViewBg = self:getUI("bg.rankPanel.backTexture")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width-20, tableViewBg:getContentSize().height-10))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(10, 5)
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    
    self._tableView:setBounceable(false)
    tableViewBg:addChild(self._tableView, 1)
end

-- 触摸时调用
function CrossAwardView:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function CrossAwardView:cellSizeForTable(table,idx) 
    local width = 778 
    local height = 93
    return height, width
end

-- 创建在某个位置的cell
function CrossAwardView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local bgcell = self._rankCell:clone() 
        bgcell:setVisible(true)
        bgcell:setAnchorPoint(0,0)
        bgcell:setPosition(0,0)
        bgcell:setName("bgcell")
        cell:addChild(bgcell)
        cell.bgcell = bgcell

        self:updateCell(bgcell, indexId)
        bgcell:setSwallowTouches(false)
    else
        local bgcell = cell.bgcell
        -- local bgcell = cell:getChildByName("bgcell")
        if bgcell then
            self:updateCell(bgcell, indexId)
            bgcell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function CrossAwardView:numberOfCellsInTableView(table)
    return 3
end

function CrossAwardView:updateCell(inView, tindexId)
    local award = {}
    local tsRank = 0
    if tindexId == 0 then
        local myAwardNum, myScore = self:getAwardNum()
        tsRank = myScore
        local taward = {
            [1] = "cpCoin",
            [2] = 0,
            [3] = myAwardNum,
        }
        table.insert(award, taward)

        local cellBg = inView:getChildByFullName("cellBg")
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg20.png", 1)
        end

        local des1 = inView:getChildByFullName("des1")
        if des1 then
            des1:setString("荣耀积分")
            des1:setColor(cc.c3b(205,32,30))
        end

        local des2 = inView:getChildByFullName("des2")
        if des2 then
            des2:setString("")
        end

        local des3 = inView:getChildByFullName("des3")
        if des3 then
            local str = "积分:" .. myScore
            des3:setString(str)
            des3:setPositionX(des2:getPositionX()+des2:getContentSize().width+3)
        end
    else
        local indexId = tindexId
        local tData = self._tableData[indexId]
        local taward, tRank, quyu = self:getAward(indexId)
        award = taward
        tsRank = tRank

        local cellBg = inView:getChildByFullName("cellBg")
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg21.png", 1)
        end

        local des1 = inView:getChildByFullName("des1")
        if des1 then
            local str = lang("cp_nameRegion" .. tData)
            des1:setString(str)
            des1:setColor(cc.c3b(61,31,0))
        end

        local des2 = inView:getChildByFullName("des2")
        if des2 then
            local str = "排名:" .. tRank
            des2:setString(str)
        end

        local des3 = inView:getChildByFullName("des3")
        if des3 then
            local str = quyu
            des3:setString(str)
            des3:setPositionX(des2:getPositionX()+des2:getContentSize().width+3)
        end
    end

    local des4 = inView:getChildByFullName("des4")
    if des4 then
        des4:setVisible(false)
    end

    local awardBg = inView:getChildByFullName("awardBg")
    local des5 = inView:getChildByFullName("des5")
    if tsRank == 0 then
        des5:setString("暂无奖励")
        awardBg:setVisible(false)
    else
        des5:setString("奖励:")
        awardBg:setVisible(true)
    end
    if awardBg then
        for i=1,3 do
            local itemData = award[i]
            local animTeamqipao = awardBg["itemIcon" .. i]
            if itemData then
                local itemType = itemData[1]
                local itemId = itemData[2]
                if IconUtils.iconIdMap[itemType] then
                    itemId = IconUtils.iconIdMap[itemType]
                end
                local itemNum = itemData[3]
                local param = {itemId = itemId, effect = true, eventStyle = 1, num = itemNum}
                if animTeamqipao then
                    IconUtils:updateItemIconByView(animTeamqipao, param)
                else
                    local animTeamqipao = IconUtils:createItemIconById(param)
                    animTeamqipao:setName("item" .. i)
                    animTeamqipao:setAnchorPoint(cc.p(0.5, 0.5))
                    animTeamqipao:setScale(0.65)
                    animTeamqipao:setPosition(90*(i-1)+45, awardBg:getContentSize().height*0.5)
                    awardBg:addChild(animTeamqipao, 99)
                    awardBg["itemIcon" .. i] = animTeamqipao
                end
            else
                if animTeamqipao then
                    animTeamqipao:setVisible(false)
                end
            end
        end
    end
    
    local doubleImg = inView:getChildByFullName('double')
    if tindexId == 3 and self._crossModel:getSeasonSpot() == 2 then
        doubleImg:setVisible(true)
    else
        doubleImg:setVisible(false)
    end
end

function CrossAwardView:getAward(arenaType)
    local myData = self._crossModel:getMyInfo()
    local playRankStr = myData["rank" .. arenaType]
    local playScoreStr = myData["score" .. arenaType] or 0

    local tRank = playRankStr
    local hourId = 1
    local rankMin = 3001
    local rankMax = 100000
    local cpServerScoreTab = tab.cpRankReward
    for i,v in ipairs(cpServerScoreTab) do
        local rankTab = v.pos
        if tRank >= rankTab[1] and tRank <= rankTab[2] then
            rankMin = rankTab[1]
            rankMax = rankTab[2]
            hourId = i
            break
        end
    end

    local quyu = "(" .. rankMin .. "-" .. rankMax .. ")"
    if tRank == 0 then
        quyu = "(暂无排名)"
    end

    local rankAwardTab = tab.cpRankReward[hourId]
    local award = rankAwardTab["reward" .. arenaType]

    return award, tRank, quyu
end

----------------------------------------active table view start--------------------------------

function CrossAwardView:addActiveTableView()
    local tableViewBg = self:getUI("bg.activePanel.backTexture")
    self._activeTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width-20, tableViewBg:getContentSize().height-10))
    self._activeTableView:setDelegate()
    self._activeTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._activeTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._activeTableView:setPosition(10, 5)
    self._activeTableView:registerScriptHandler(function(table, cell) return self:tableCellTouched1(table,cell) end,cc.TABLECELL_TOUCHED)
    self._activeTableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable1(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._activeTableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex1(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._activeTableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView1(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    
    self._activeTableView:setBounceable(false)
    tableViewBg:addChild(self._activeTableView, 1)
end

function CrossAwardView:tableCellTouched1(table,cell)
end

-- cell的尺寸大小
function CrossAwardView:cellSizeForTable1(table,idx) 
    local width = 778 
    local height = 100
    return height, width
end

-- 创建在某个位置的cell
function CrossAwardView:tableCellAtIndex1(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local bgcell = self._activeCell:clone() 
        bgcell:setVisible(true)
        bgcell:setAnchorPoint(0,0)
        bgcell:setPosition(0,0)
        bgcell:setName("bgcell")
        cell:addChild(bgcell)
        cell.bgcell = bgcell

        self:updateActiveCell(bgcell, indexId)
        bgcell:setSwallowTouches(false)
    else
        local bgcell = cell.bgcell
        if bgcell then
            self:updateActiveCell(bgcell, indexId)
            bgcell:setSwallowTouches(false)
        end
    end

    return cell
end

function CrossAwardView:numberOfCellsInTableView1(table)
    return #self._activeTableData
end

function CrossAwardView:updateActiveCell( cell, idx )
    local data = self._activeTableData[idx] or {}
    local num = cell:getChildByName("num")
    num:setFontName(UIUtils.ttfName)
    num:setString(data.condition)

    local awards = data.award
    for i, v in ipairs(awards) do
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
            icon:setPosition((i-1)*79+115,10)
            icon:setScale(0.75)
            cell:addChild(icon)
        else
            IconUtils:updateItemIconByView(icon,{itemId = itemId,num = v[3]})
        end
    end

    cell:setBrightness(0)

    local getDes = cell:getChildByFullName('getDes')
    local getImg = cell:getChildByFullName('getImg')
    local awardBtn = cell:getChildByFullName('awardBtn')
    getDes:setVisible(false)
    getImg:setVisible(false)
    awardBtn:setVisible(false)

    if data.status == 1 then
        awardBtn:setVisible(true)
        self:registerClickEvent(awardBtn, function( )
            self._serverMgr:sendMsg("CrossPKServer", "getActiveReward", {rewardId = data.id}, true, {}, function(result)
                self:updateActivePanel()
                self:updateActivePrompt()
                DialogUtils.showGiftGet({gifts = result.reward, notPop = true})
            end)
        end)
    elseif data.status == 2 then
        getImg:setVisible(true)
        getImg:loadTexture("globalImageUI_weidacheng.png", 1)
    elseif data.status == 3 then
        getImg:setVisible(true)
        getImg:loadTexture("globalImageUI5_yilingqu2.png", 1)
        cell:setBrightness(-50)
    end

end

function CrossAwardView:updateActivePrompt(  )
    local tab = self:getUI('bg.tab3')
    if self._crossModel:isActiveAward() then
        UIUtils.addRedPoint(tab, true, ccp(20, tab:getContentSize().height - 10))
    else
        UIUtils.addRedPoint(tab, false)
    end
end

-----------------------------------------------------active table view end----------------------------

function CrossAwardView:initActiveInfo(  )
    local tipDes = self:getUI('bg.activePanel.tipDes')
    local num = self:getUI('bg.activePanel.num')
    num:setString(tostring(self._chanNum))

    tipDes:setString(lang("CP_ACTIVEREWARD_TIPS"))
    self:updateActivePrompt()
end

function CrossAwardView:tabButtonClick(sender, key)
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
    self:tabButtonState(sender, true, key)
    self:switchPanel(sender, key)
end

-- 选项卡状态切换
function CrossAwardView:tabButtonState(sender, isSelected, key)
    local titleNames = {
        " 排名 ",
        " 积分 ",
        " 活跃 "
    }
    local shortTitleNames = {
        " 排名 ",
        " 积分 ",
        " 活跃 "
    }

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()
    sender:setTitleFontSize(24)
    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    end
end

function CrossAwardView:switchPanel(sender, key)
    if sender:getName() == "tab1" then
        self._tabSelect = 1
        self._rankPanel:setVisible(true)
        self._scorePanel:setVisible(false)
        self._activePanel:setVisible(false)
        self:updateRankPanel()
    elseif sender:getName() == "tab2" then 
        self._tabSelect = 2
        self._rankPanel:setVisible(false)
        self._scorePanel:setVisible(true)
        self._activePanel:setVisible(false)
        self:updateScorePanel()
    elseif sender:getName() == "tab3" then
        self._tabSelect = 3
        self._rankPanel:setVisible(false)
        self._scorePanel:setVisible(false)
        self._activePanel:setVisible(true)
        self:updateActivePanel()
    end
    print("self._tabSelect============tab1=", self._tabSelect)
end

function CrossAwardView:processActiveData(  )
    local activeIds = self._crossModel:getActiveIds()
    self._activeTableData = clone(self._activeCfg)
    --1 可领取
    --2 未达成
    --3 已领取
    for k, v in pairs(self._activeTableData) do
        local condition = v.condition
        if tonumber(self._chanNum) >= tonumber(condition) then
            if activeIds[tostring(v.id)] then
                v.status = 3
            else
                v.status = 1
            end
        else
            v.status = 2
        end
    end
    table.sort(self._activeTableData, function ( data1, data2 )
        local status1 = data1.status
        local status2 = data2.status
        if status1 == status2 then
            return data1.id < data2.id
        else
            return status1 < status2
        end
    end)
end

function CrossAwardView:updateActivePanel(  )
    self:processActiveData()
    self._activeTableView:reloadData()
end

function CrossAwardView:progressData()
    local arenaData = self._crossModel:getData()
    self._tableData = {}
    for i=1,3 do
        local arenaId = arenaData["regiontype" .. i]
        self._tableData[i] = arenaId
    end
end 

function CrossAwardView:updateRankPanel()
    self:progressData()
    self._tableView:reloadData()
end

function CrossAwardView:updateScorePanel()
    self:updateTitleBg()
    self:updateServerAward()
end

function CrossAwardView:updateServerAward()
    -- 描述
    local richtextBg = self:getUI("bg.scorePanel.richtextBg")
    local richText = richtextBg:getChildByName("richText")
    if richText ~= nil then
        richText:removeFromParent()
    end

    local desc = lang("cp_award_tips")
    if string.find(desc, "color=") == nil then
        desc = "[color=462800]"..desc.."[-]"
    end
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    local myAwardNum, myScore = self:getAwardNum()
    local serverAwardNum = myAwardNum
    local itemId = IconUtils.iconIdMap["cpCoin"]
    local awardBg1 = self:getUI("bg.scorePanel.rewardBg.awardBg1")
    local param = {itemId = itemId, effect = true, eventStyle = 1}
    local animTeamqipao = awardBg1["itemIcon"]
    if animTeamqipao then
        IconUtils:updateItemIconByView(animTeamqipao, param)
    else
        animTeamqipao = IconUtils:createItemIconById(param)
        animTeamqipao:setName("item")
        animTeamqipao:setAnchorPoint(cc.p(0.5, 0.5))
        animTeamqipao:setScale(0.65)
        animTeamqipao:setPosition(45, awardBg1:getContentSize().height*0.5)
        awardBg1:addChild(animTeamqipao, 99)
        awardBg1["itemIcon"] = animTeamqipao
    end

    local awardBg2 = self:getUI("bg.scorePanel.rewardBg.awardBg2")
    local param = {itemId = itemId, effect = true, eventStyle = 1}
    local animTeamqipao = awardBg2["itemIcon"]
    if animTeamqipao then
        IconUtils:updateItemIconByView(animTeamqipao, param)
    else
        animTeamqipao = IconUtils:createItemIconById(param)
        animTeamqipao:setName("item")
        animTeamqipao:setAnchorPoint(cc.p(0.5, 0.5))
        animTeamqipao:setScale(0.65)
        animTeamqipao:setPosition(45, awardBg2:getContentSize().height*0.5)
        awardBg2:addChild(animTeamqipao, 99)
        awardBg2["itemIcon"] = animTeamqipao
    end

    local serAwardLab = self:getUI("bg.scorePanel.rewardBg.serAwardLab")
    local selfAwardLab = self:getUI("bg.scorePanel.rewardBg.selfAwardLab")
    local scoreLab = self:getUI("bg.scorePanel.rewardBg.scoreLab")
    serverAwardNum = math.floor(serverAwardNum)
    serAwardLab:setString("×" .. serverAwardNum)
    myAwardNum = math.floor(myAwardNum)
    selfAwardLab:setString("×" .. myAwardNum)
    scoreLab:setString(myScore)
end


function CrossAwardView:getAwardNum()
    local arenaData = self._crossModel:getData()
    local myData = self._crossModel:getMyInfo()
    dump(myData)

    local usId = self._crossModel:getServerId()
    local sName, stype = self._crossModel:getServerName(tonumber(usId))
    local playAllNum = arenaData["playerNum1"] + arenaData["playerNum2"]
    local playNum = arenaData["playerNum" .. stype]

    local scoreAll = arenaData["sec1score"] + arenaData["sec2score"]
    local score = arenaData["sec" .. stype .. "score"]

    local myScore = 0
    for i=1,3 do
        local tScore = myData["score" .. i] or 0
        myScore = myScore + tScore
    end
    local playBase = tab:Setting("CROSSPK_REWARDS_PERRATIO").value
    local perBaseA = tab:Setting("CROSSPK_REWARDS_PERBASE").value
    local perBase = perBaseA[3]
    local scoreBase = tab:Setting("CROSSPK_REFERSH_SCORE").value
    local myAwardNum = perBase*(0.5+0.2*math.atan((100*score/scoreAll-50)/10))*(playBase+(1-playBase)*(0.635*math.atan((math.log((myScore+0.0001)/810/scoreBase,1.01))*0.01)+1)^2)
    myAwardNum = math.ceil(myAwardNum)
    if myScore == 0 then
        myAwardNum = 0
    end
    return myAwardNum, myScore
end

return CrossAwardView