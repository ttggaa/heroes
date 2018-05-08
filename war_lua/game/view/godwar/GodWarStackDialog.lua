--[[
    Filename:    GodWarStackDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-18 20:48:30
    Description: File description
--]]

-- 我的支持
local GodWarStackDialog = class("GodWarStackDialog", BasePopView)
local readlyTime = GodWarUtil.readlyTime -- 准备间隔
local fightTime = GodWarUtil.fightTime -- 战斗间隔

function GodWarStackDialog:ctor()
    GodWarStackDialog.super.ctor(self)
end

function GodWarStackDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarStackDialog")
        end
        self:close()
    end)  

    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if weekday == 0 then
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 22:00:00"))
        local callFunc = cc.CallFunc:create(function()
            local curServerTime = self._userModel:getCurServerTime()
            if tempTime < curServerTime then
                if self.close then
                    self:close()
                end
                title:stopAllActions()
            end
        end)
        local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
        title:runAction(cc.RepeatForever:create(seq))
    end

    local keyawardbtn = self:getUI("bg.keyawardbtn")
    keyawardbtn:setVisible(false)
    self:registerClickEvent(keyawardbtn, function()
        self:onekeyReceiveStakeRewards()
    end)

    self._inFirst = false

    self._logCell = self:getUI("cell")

    self:addTableView()
    self:reciprocalTime()
end

function GodWarStackDialog:getReceiveStakeList()
    self._serverMgr:sendMsg("GodWarServer", "getReceiveStakeList", {}, true, {}, function (result)
        self:reflashUI(result)
    end)
end

function GodWarStackDialog:updateAllAward()
    local awardvalue = self:getUI("bg.awardvalue")
    awardvalue:setString(self._sum)
end

function GodWarStackDialog:progressListData(data)
    local listData = {}
    -- dump(data)
    local curServerTime = self._userModel:getCurServerTime()

    for i,v in ipairs(data) do
        local onAward = false
        local onEnd = false
        local minTime = self:getGodWarTime(v.pow, v.round)
        -- local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 15*(data.round-1) .. ":00"))
        print("minTime==========",minTime, v.round)
        local tmpTime = curServerTime - minTime
        local maxTime = 180
        local endTime = readlyTime + fightTime*3
        local tmaxTime = readlyTime + fightTime*3
        if v.round == 1 then
            if v.pow == 2 then
                maxTime = maxTime + 300
                tmaxTime = 300 + fightTime*3
                endTime = 300 + fightTime*3
            else
                maxTime = maxTime + 1800
                tmaxTime = tmaxTime + 1800
                endTime = endTime + 1800
            end
        end
        if tmpTime > endTime then
            onEnd = true
        end
        if tmpTime > tmaxTime then
            onAward = true
        end
        if tmpTime > maxTime then
            tmpTime = maxTime
        end
        v.onEnd = onEnd
        local playerData = self._godWarModel:getPlayerById(v.rid)
        local zhichiValue
        if v.rid == v.aid then
            local enemyData = self._godWarModel:getPlayerById(v.did)
            zhichiValue = self:getZhichiNum(nil, tmpTime, playerData, enemyData)
            v.rWin = v.win
        else
            local enemyData = self._godWarModel:getPlayerById(v.aid)
            zhichiValue = self:getZhichiNum(nil, tmpTime, playerData, enemyData)
            v.rWin = v.win
        end
        zhichiValue = zhichiValue .. "人支持他"
        v.zhichiValue = zhichiValue
        v.onAward = onAward
        table.insert(listData, v)
    end
    return listData
end



function GodWarStackDialog:reciprocalTime()
    local title = self:getUI("bg.titleBg.title")
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if weekday == 3 or weekday == 4 then
        local minTime = 0
        if weekday == 3 then
            local ttempTime1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:09:05"))
            local ttempTime2 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:05"))
            local ttempTime3 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:27:05"))
            local ttempTime4 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 21:36:05"))
            if curServerTime < ttempTime1 then
                minTime = ttempTime1
            elseif curServerTime < ttempTime2 then
                minTime = ttempTime2
            elseif curServerTime < ttempTime3 then
                minTime = ttempTime3
            elseif curServerTime < ttempTime4 then
                minTime = ttempTime4
            end
        elseif weekday == 4 then
            local ttempTime1 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:09:05"))
            local ttempTime2 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:05"))
            local ttempTime3 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:05"))
            if curServerTime < ttempTime1 then
                minTime = ttempTime1
            elseif curServerTime < ttempTime2 then
                minTime = ttempTime2
            elseif curServerTime < ttempTime3 then
                minTime = ttempTime3
            end
        end
 
        local callFunc = cc.CallFunc:create(function()
            local curServerTime = self._userModel:getCurServerTime()
            -- print("tempTime < curServerTime=======", minTime, curServerTime)
            if minTime == curServerTime then
                print("刷新=========++++++++++++++++")
                self:getReceiveStakeList()
            end
        end)
        local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
        title:stopAllActions()
        title:runAction(cc.RepeatForever:create(seq))
    end
end

function GodWarStackDialog:reflashUI(data)
    self._logData = {}
    if data.list then
        self._logData = self:progressListData(data.list)
    end
    if table.nums(self._logData) == 0 then
        local nothing = self:getUI("bg.nothing")
        nothing:setVisible(true)
        self._tableView:setVisible(false)
    end
    self._sum = data.sum or 0
    self._tableView:reloadData()
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
    self:updateAllAward()
end

function GodWarStackDialog:scrollToNext(selectedIndex)
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
function GodWarStackDialog:addTableView()
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
function GodWarStackDialog:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function GodWarStackDialog:cellSizeForTable(table,idx) 
    local width = 474 
    local height = 118
    return height, width
end

-- 创建在某个位置的cell
function GodWarStackDialog:tableCellAtIndex(table, idx)
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
function GodWarStackDialog:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function GodWarStackDialog:tableNum()
    return table.nums(self._logData)
end

function GodWarStackDialog:updateCell(inView, data, indexId)
    if data == nil then
        return
    end
    -- dump(data,indexId .. "======")

    local jilu = inView:getChildByFullName("jilu")
    if jilu then
        local str = data.pow .. "强赛"
        if data.pow == 2 then
            str = "决赛"
        end
        jilu:setString(str)
    end

    local userId = data.rid
    local playerData = self._godWarModel:getPlayerById(userId)
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


        if data.rWin == 1 then
            jieguo:loadTexture("godwarImageUI_img78.png", 1)
            yilingqu:loadTexture("globalImageUI_activity_getIt.png", 1)
            if data.receive ~= 0 then
                lingqu:setVisible(false)
                costBg:setVisible(false)
                yilingqu:setVisible(true)
            else
                lingqu:setVisible(true)
                costBg:setVisible(true)
                yilingqu:setVisible(false)
            end
        elseif data.rWin == 2 then
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
        zhuangtai:setString("结果计算中")
        zhuangtai:setColor(cc.c3b(28,162,22))
    end

    if lingqu then
        -- UIUtils:addFuncBtnName(lingqu, "领取", nil, true)
        self:registerClickEvent(lingqu, function()
            local param = {pow = data.pow, round = data.round}
            self:receiveStakeRewards(param, data, indexId)
        end)
    end

    -- 提前算奖励 放在最后 如果没有数据，就隐藏costBg
    local costLab = inView:getChildByFullName("costBg.costLab")
    local powId = data.pow or 8
    local rateBase = tab:Setting("G_GODWAR_STAGE" .. powId)["value"][1][1]
    local godWar = self._godWarModel:getWarDataById(powId)
    local warData
    local chang = tostring(data.round)
    if godWar and godWar[chang] then
        warData = godWar[chang]
    else
        print("=============================没有godWar数据========================")
    end
    if warData then
        if not warData.rate then
            warData.rate["1"] = 1
            warData.rate["2"] = 1
        end
        local rateValue = warData.rate["1"]
        if data.rid == data.did then
            rateValue = warData.rate["2"]
        end
        local rateNum = rateValue * rateBase
        print("warrate base,",rateBase,"rateValue",rateValue)
        costLab:setString(rateNum or 0)
        -- costBg:setVisible(true)
    else
        costBg:setVisible(false)
    end
end

-- function GodWarStackDialog:updateCell(inView, data, indexId)
--     if data == nil then
--         return
--     end
--     dump(data)

--     -- local fenge = inView:getChildByFullName("fenge")
--     -- local shou = inView:getChildByFullName("shou")
--     local jilu = inView:getChildByFullName("jilu")
--     if jilu then
--         local str = data.pow .. "强赛"
--         if data.pow == 2 then
--             str = "决赛"
--         end
--         jilu:setString(str)
--     end

--     local userId = data.rid
--     local playerData = self._godWarModel:getPlayerById(userId)
--     local param1 = {avatar = playerData.avatar, tp = 4, avatarFrame = playerData["avatarFrame"]}
--     local headBg = inView:getChildByFullName("headBg")
--     local icon = headBg:getChildByName("icon")
--     if not icon then
--         icon = IconUtils:createHeadIconById(param1)
--         icon:setName("icon")
--         -- icon:setPosition(40, 40)
--         headBg:addChild(icon)
--     else
--         IconUtils:updateHeadIconByView(icon, param1)
--     end

--     local tname = inView:getChildByFullName("tname")
--     if tname then
--         tname:setString(playerData.name)
--     end

--     local flag = false
--     local lingquType = false

--     local zhichi = inView:getChildByFullName("zhichi")
--     if zhichi then
--         zhichiValue = data.zhichiValue
--         zhichi:setString(zhichiValue)
--     end

--     local shalou = inView:getChildByFullName("shalou")
--     local lingqu = inView:getChildByFullName("lingqu")

--     local endType = 0
--     if data.onAward == true then
--         if data.win == 1 then
--             lingquType = true
--             endType = 1
--         elseif data.win == 2 then
--             endType = 2
--         end
--         if shalou then
--             shalou:setVisible(false)
--         end
--     else
--         endType = 3
--         if shalou then
--             shalou:setVisible(true)
--         end
--     end
--     if conditions then
--         --todo
--     end

--     local jieguo = inView:getChildByFullName("jieguo")
--     if jieguo then
--         if endType == 1 then
--             jieguo:loadTexture("godwarImageUI_img78.png", 1)
--             jieguo:setVisible(true)
--         elseif endType == 2 then
--             jieguo:loadTexture("godwarImageUI_img79.png", 1)
--             jieguo:setVisible(true)
--         else
--             jieguo:setVisible(false)
--         end
--     end


--     local yilingqu = inView:getChildByFullName("yilingqu")
--     local lingqu = inView:getChildByFullName("lingqu")
--     local zhuangtai = inView:getChildByFullName("zhuangtai")
--     if zhuangtai then
--         if endType ~= 3 then
--             zhuangtai:setString("已结束")
--             zhuangtai:setColor(cc.c3b(120,120,120))
--             if jieguo then
--                 jieguo:setVisible(true)
--             end
--         else
--             zhuangtai:setString("结果计算中")
--             zhuangtai:setColor(cc.c3b(28,162,22))
--             if jieguo then
--                 jieguo:setVisible(false)
--             end
--         end
--     end

--     if endType == 1 then
--         yilingqu:loadTexture("globalImageUI_activity_getIt.png", 1)
--     elseif endType == 2 then
--         yilingqu:loadTexture("godwarImageUI_img136.png", 1)
--     end


--     if yilingqu then
--         if data.receive ~= 0 then
--             yilingqu:setVisible(true)
--             lingqu:setVisible(false)
--         elseif data.receive == 0 and data.onAward ~= true then
--             yilingqu:setVisible(true)
--             lingqu:setVisible(false)
--         else
--             yilingqu:setVisible(false)
--             lingqu:setVisible(true)
--         end
--     end

--     if lingqu then
--         UIUtils:addFuncBtnName(lingqu, "领取", nil, true)
--         self:registerClickEvent(lingqu, function()
--             local param = {pow = data.pow, round = data.round}
--             self:receiveStakeRewards(param, data)
--         end)
--     end
-- end

function GodWarStackDialog:getGodWarTime(powId, roundId)
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


function GodWarStackDialog:getZhichiNum(opennum1, timer, data, enemyData)
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()
    local timer1 = curServerTime - userData.sec_open_time
    local opennum = math.floor(timer1/86400)
    print("opennum==========", opennum, timer, data.score, enemyData.score)
    local zhichiNum = 174*((2*data.score/(data.score+enemyData.score))^6)*1.5*timer/(156+timer)*math.max(148/opennum, 1)
    print("zhichiNum=======", zhichiNum)
    return math.floor(zhichiNum)
end

function GodWarStackDialog:receiveStakeRewards(param, data, indexId)
    self._serverMgr:sendMsg("GodWarServer", "receiveStakeRewards", param, true, {}, function (result)
        if result.reward then
            DialogUtils.showGiftGet({gifts = result.reward})
        end
        data.receive = 1
        self:reflashUI(result)

        self._godWarModel:setReceiveStakeList(indexId)
        -- self._tableView:reloadData()
    end)
end

function GodWarStackDialog:getKeyAward()
    local flag = false
    for k,v in pairs(self._logData) do
        if v.receive == 0 and v.onAward == true then
            flag = true
            break
            -- local curServerTime = self._userModel:getCurServerTime()
            -- local minTime = self:getGodWarTime(v.pow, v.round)
            -- -- local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. 15*(data.round-1) .. ":00"))
            -- local tmpTime = curServerTime - minTime
            -- local maxTime = 180
            -- if v.round == 1 then
            --     if v.pow == 2 then
            --         maxTime = maxTime + 600
            --     else
            --         maxTime = maxTime + 1800
            --     end
            -- end
            -- if tmpTime > maxTime then
            --     flag = true
            -- end
        end
    end
    return flag
end

function GodWarStackDialog:onekeyReceiveStakeRewards()
    local flag = self:getKeyAward()
    if flag == false then
        self._viewMgr:showTip("暂无可领取奖励")
        return
    end
    
    self._serverMgr:sendMsg("GodWarServer", "onekeyReceiveStakeRewards", {}, true, {}, function (result)
        if result.reward then
            DialogUtils.showGiftGet({gifts = result.reward})
            self:setReceive()
            self:reflashUI(result)
        else
            self._viewMgr:showTip("暂无可领取奖励")
        end
    end)
end

function GodWarStackDialog:setReceive()
    for k,v in pairs(self._logData) do
        if v.receive == 0 then
            v.receive = 1
        end
    end
    return flag
end

return GodWarStackDialog
