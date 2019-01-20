--[[
    Filename:    CrossGodWarSupportDialog.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-05-18 17:52:30
    Description: File description
--]]

-- 我的支持
local CrossGodWarSupportDialog = class("CrossGodWarSupportDialog", BasePopView)
local readlyTime = GodWarUtil.readlyTime -- 准备间隔
local fightTime = GodWarUtil.fightTime -- 战斗间隔

function CrossGodWarSupportDialog:ctor(param)
    CrossGodWarSupportDialog.super.ctor(self)
    self._logData = {}
    self._getState = param.callback
end

function CrossGodWarSupportDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("crossGod.CrossGodWarSupportDialog")
        end
        self:close()
    end)  

    self._userModel = self._modelMgr:getModel("UserModel")
    self._cGodWarModel = self._modelMgr:getModel("CrossGodWarModel")

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    local keyawardbtn = self:getUI("bg.autoRewardBtn")
    -- keyawardbtn:setVisible(false)
    self:registerClickEvent(keyawardbtn, function()
        self:onekeyReceiveStakeRewards()
    end)

    self._inFirst = false

    self._logCell = self:getUI("cell")

    self:addTableView()
    self:reciprocalTime()
    -- test
    self:getReceiveStakeList()
end

function CrossGodWarSupportDialog:getReceiveStakeList()
    self._serverMgr:sendMsg("CrossGodWarServer", "getStakeList", {}, true, {}, function (result)
        self:updateUI(result)
    end)
end

function CrossGodWarSupportDialog:updateAllAward()
    local awardvalue = self:getUI("bg.rewardNum")
    awardvalue:setString(self._sum)
end

function CrossGodWarSupportDialog:progressListData(data)
    local listData = {}

    local curServerTime = self._userModel:getCurServerTime()

    local state,endTime,tabIndex = self._getState()
    if state == 0 then
        state = 11
    end
    local chang,powId,ju = self._cGodWarModel:getPowIdAndChang(tabIndex,state)
    for i,v in ipairs(data) do
        local onAward = false
        local onEnd = false
        if v.win ~= 0 then
            onEnd = true
        end
        if v.received and v.received == 0 then
            onAward = true
        end
        v.onEnd = onEnd
        local playerData = self._cGodWarModel:getPlayerById(v.rid)
        local zhichiValue
        local title 
        if v.pow == 8 then
            title = "8强赛"
        elseif v.pow == 4 then
            title = "4强赛"
        elseif v.pow == 3 then
            title = "季军赛"
        elseif v.pow == 2 then
            title = "决赛"
        end

        zhichiValue = v.count or 0
        zhichiValue = zhichiValue .. "人支持他"
        v.zhichiValue = zhichiValue
        v.title = title
        v.onAward = onAward
        print("powId",powId)
        print("ju",ju)
        print("pow",v.pow)
        print("round",v.round)
        if state == 11 then
            if powId == v.pow and v.round == ju then
                v.onEnd = false
            end
        end
        table.insert(listData, v)
    end
    return listData
end

function CrossGodWarSupportDialog:reciprocalTime()
    local title = self:getUI("bg.titleBg.title")
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local endIndexArray = {48,50,52,54,56,58,60,62}
    if weekday == 4  then
        local minTime = 0
        for i,tabIndex in ipairs(endIndexArray) do
            local timeData = tab.crossFightTime[tabIndex]
            local endTimeStr = timeData.time2
            local ttempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d "..endTimeStr))
            if curServerTime < ttempTime then
                minTime = ttempTime
                break
            end
        end
        local callFunc = cc.CallFunc:create(function()
            local curServerTime = self._userModel:getCurServerTime()
            if (minTime+1) == curServerTime then
                self:getReceiveStakeList()
            end
        end)
        local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
        title:stopAllActions()
        title:runAction(cc.RepeatForever:create(seq))
    end
end

function CrossGodWarSupportDialog:updateUI( data )
    if not data then
        return 
    end
    self._logData = {}
    if data.list then
        self._logData = self:progressListData(data.list)
    end

    self._sum = data.awardSum or 0
    self._tableView:reloadData()
    self:updateAllAward()
    if table.nums(self._logData) == 0 then
        local nothing = self:getUI("bg.nothing")
        nothing:setVisible(true)
        self._tableView:setVisible(false)
        return
    end
    
    if self._inFirst == false then
        local tCount = 0
        for i=1,table.nums(self._logData) do
            local tdata = self._logData[i]
            if tdata.rWin == 1 and tdata.receive == 0 then
                tCount = i
                break 
            end
        end
        -- print("tCount===========", tCount)
        self:scrollToNext(tCount)
        self._inFirst = true
    end
end

function CrossGodWarSupportDialog:scrollToNext(selectedIndex)
    local selectedIndex = (selectedIndex) or 0
    local tableNum = table.nums(self._logData)
    local _hight = 120
    local begHeight = selectedIndex*_hight
    local maxHeight = tableNum*_hight

    local scrollAnim = false
    local tempheight = self._tableView:getContainer():getContentSize().height
    local tableViewBg = self:getUI("bg.tableViewBg")
    local tabHeight = tempheight - tableViewBg:getContentSize().height
    -- print("containHeight==========", tabHeight, begHeight)
    local tNum = begHeight - maxHeight
    -- print("tNum========", tNum, tabHeight)
    if tempheight < tableViewBg:getContentSize().height then
        self._tableView:setContentOffset(cc.p(0, self._tableView:getContentOffset().y), scrollAnim)
    else
        if (maxHeight - begHeight) > tabHeight then
            -- print("===111=====+++")
            self._tableView:setContentOffset(cc.p(0, -1*tabHeight), scrollAnim)
        else
            -- print("===222=====+++")
            self._tableView:setContentOffset(cc.p(0, begHeight - maxHeight), scrollAnim)
        end
    end
end

--[[
用tableview实现
--]]
function CrossGodWarSupportDialog:addTableView()
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
    
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function CrossGodWarSupportDialog:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function CrossGodWarSupportDialog:cellSizeForTable(table,idx) 
    local width = 474 
    local height = 118
    return height, width
end

-- 创建在某个位置的cell
function CrossGodWarSupportDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._logData[idx + 1] -- {typeId = 3, id = 1}
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local logCell = self._logCell:clone()
        logCell:setAnchorPoint(cc.p(0,0))
        logCell:setPosition(cc.p(0,0))
        logCell:setVisible(true)
        logCell:setName("logCell")
        cell:addChild(logCell)

        local shalou = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
        shalou:setName("shalou")
        shalou:setScale(2)
        shalou:setPosition(390, 65)
        logCell:addChild(shalou, 10)
        
        local lingqu = logCell:getChildByFullName("lingqu")
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
function CrossGodWarSupportDialog:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function CrossGodWarSupportDialog:tableNum()
    return table.nums(self._logData)
end

function CrossGodWarSupportDialog:updateCell(inView, data, indexId)
    if data == nil then
        return
    end
    local jilu = inView:getChildByFullName("jilu")
    if jilu then
        local str = data.title
        jilu:setString(str)
    end

    local userId = data.rid
    local playerData = self._cGodWarModel:getPlayerById(userId)
    local param1 = {avatar = playerData.avatar, tp = 4, avatarFrame = playerData["avatarFrame"]}
    local headBg = inView:getChildByFullName("headBg")
    local icon = headBg:getChildByName("icon")
    if not icon then
        icon = IconUtils:createHeadIconById(param1)
        icon:setName("icon")
        -- icon:setPosition(40, 40)
        headBg:addChild(icon)
    else
        IconUtils:updateHeadIconByView(icon, param1)
    end

    local tname = inView:getChildByFullName("tname")
    if tname then
        tname:setString(playerData.name)
    end

    local zhichi = inView:getChildByFullName("zhichi")
    if zhichi then
        zhichiValue = data.zhichiValue
        zhichi:setString(zhichiValue)
    end

    local shalou = inView:getChildByFullName("shalou")
    local jieguo = inView:getChildByFullName("jieguo")
    local yilingqu = inView:getChildByFullName("yilingqu")
    local lingqu = inView:getChildByFullName("lingqu")
    local costBg = inView:getChildByFullName("costBg")
    local zhuangtai = inView:getChildByFullName("zhuangtai")

    if data.onEnd == true then
        if shalou then
            shalou:setVisible(false)
        end
        zhuangtai:setString("已结束")
        zhuangtai:setColor(cc.c3b(120,120,120))


        if data.win == 1 then
            jieguo:loadTexture("godwarImageUI_img78.png", 1)
            yilingqu:loadTexture("globalImageUI_activity_getIt.png", 1)
            if data.received ~= 0 then
                lingqu:setVisible(false)
                costBg:setVisible(false)
                yilingqu:setVisible(true)
            else
                lingqu:setVisible(true)
                costBg:setVisible(true)
                yilingqu:setVisible(false)
            end
        elseif data.win == 2 then
            jieguo:loadTexture("godwarImageUI_img79.png", 1)
            yilingqu:loadTexture("godwarImageUI_img136.png", 1)
            yilingqu:setVisible(true)
            lingqu:setVisible(false)
            costBg:setVisible(false)
        end
        jieguo:setVisible(true)
    else
        if shalou then
            shalou:setVisible(true)
        end
        jieguo:setVisible(false)
        yilingqu:setVisible(false)
        lingqu:setVisible(false)
        costBg:setVisible(false)
        zhuangtai:setString("等待中")
        zhuangtai:setColor(cc.c3b(28,162,22))
    end

    if lingqu then
        -- UIUtils:addFuncBtnName(lingqu, "领取", nil, true)
        self:registerClickEvent(lingqu, function()
            local param = {pow = data.pow, round = data.round}
            self:receiveStakeRewards(param, data, indexId)
        end)
    end

    local costLab = inView:getChildByFullName("costBg.costLab")
    costBg:setVisible(false)
    -- local powId = data.pow or 8
    -- local rateBase = tab:Setting("G_GODWAR_STAGE" .. powId)["value"][1][1]
    -- local godWar 
    -- local tempData = self._cGodWarModel:getEliminateFightData()
    -- dump(tempData,"sas32erfe")
    -- godWar = tempData[pow]
    -- local warData
    -- local chang = data.round
    -- if godWar and godWar[chang] then
    --     warData = godWar[chang]
    -- else
    --     print("=============================没有godWar数据========================")
    -- end
    -- if warData then
    --     if not warData.rate then
    --         warData.rate["1"] = 1
    --         warData.rate["2"] = 1
    --     end
    --     local rateValue = warData.rate["1"]
    --     if data.rid == data.did then
    --         rateValue = warData.rate["2"]
    --     end
    --     local rateNum = rateValue * rateBase
    --     print("warrate base,",rateBase,"rateValue",rateValue)
    --     costLab:setString(rateNum or 0)
    --     -- costBg:setVisible(true)
    -- else
    --     costBg:setVisible(false)
    -- end
end

function CrossGodWarSupportDialog:getGodWarTime(powId, roundId)
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local temptime = 1
    if powId == 8 and weekday == 3 then
        local roundTime = readlyTime + fightTime*3
        temptime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        temptime = temptime + roundTime*(roundId-1)
        if roundId == 1 then
            temptime = temptime - 1800
        end
    elseif weekday == 4 then
        if powId == 4 then
            local roundTime = readlyTime + fightTime*3
            temptime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
            temptime = temptime + roundTime*(roundId-1)
            if roundId == 1 then
                temptime = temptime - 1800
            end
        elseif powId == 2 then
            temptime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        end
    else
        temptime = 0
    end
    print("temptime=======", temptime, roundId)
    return temptime
end


function CrossGodWarSupportDialog:getZhichiNum(opennum1, timer, data, enemyData)
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()
    local timer1 = curServerTime - userData.sec_open_time
    local opennum = math.floor(timer1/86400)
    print("opennum==========", opennum, timer, data.score, enemyData.score)
    local zhichiNum = 174*((2*data.score/(data.score+enemyData.score))^6)*1.5*timer/(156+timer)*math.max(148/opennum, 1)
    print("zhichiNum=======", zhichiNum)
    return math.floor(zhichiNum)
end

function CrossGodWarSupportDialog:receiveStakeRewards(param, data, indexId)
    self._serverMgr:sendMsg("CrossGodWarServer", "receiveStakeRewards", param, true, {}, function (result)
        if result.reward then
            DialogUtils.showGiftGet({gifts = result.reward})
        end
        data.received = 1
        self._tableView:updateCellAtIndex(indexId-1)
        local num = result.reward.num or 0
        self._sum = self._sum + num
        self:updateAllAward()
    end)
end

function CrossGodWarSupportDialog:getKeyAward()
    local flag = false
    for k,v in pairs(self._logData) do
        if v.received == 0 and v.onAward == true then
            flag = true
            break
        end
    end
    return flag
end

function CrossGodWarSupportDialog:onekeyReceiveStakeRewards()
    local flag = self:getKeyAward()
    if flag == false then
        self._viewMgr:showTip("暂无可领取奖励")
        return
    end
    
    self._serverMgr:sendMsg("CrossGodWarServer", "onekeyReceiveStakeRewards", {}, true, {}, function (result)
        if result.reward then
            DialogUtils.showGiftGet({gifts = result.reward})
            self:updateUI(result)
        else
            self._viewMgr:showTip("暂无可领取奖励")
        end
    end)
end

function CrossGodWarSupportDialog:setReceive()
    for k,v in pairs(self._logData) do
        if v.received == 0 then
            v.received = 1
        end
    end
end

return CrossGodWarSupportDialog
