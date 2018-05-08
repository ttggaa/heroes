--[[
    Filename:    ACShareGetGiftLayer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-4-22 18:04:21
    Description: 分享通用按钮
--]]

local ACShareGetGiftLayer = class("ACShareGetGiftLayer", require("game.view.activity.common.ActivityCommonLayer"))

function ACShareGetGiftLayer:ctor(params)
    ACShareGetGiftLayer.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._shareGetModel = self._modelMgr:getModel("ACShareGetGiftModel")
    -- self._container = params.container
end

function ACShareGetGiftLayer:onInit()
    local bg = self:getUI("bg")
    bg:setBackGroundImage("asset/bg/ac_bg_shareGet.jpg")

    local Label_31 = self:getUI("bg.Label_31")
    Label_31:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    Label_31:setString(lang("FENXIANGmiaoshu_001"))

    self._item = self:getUI("item")
    self._item:setVisible(false)
    self:getUI("item.tip1.curTip"):setString("")
    self:getUI("item.rateStr"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    

    self._shareGetModel:setData() --获取最新数据
    self._modelMgr:getModel("ACShareGetGiftModel"):recordHasShowRedPoint() --记录当前的可分享状态，之后不再红点提示
    self:reflashUI()
    --倒计时
    self:setCountTime()
end

function ACShareGetGiftLayer:reflashUI()
    self._data = self._shareGetModel:getData()
    -- dump(self._data)

    if  self._tableView == nil then
        local tableBg = self:getUI("bg.tableBg")
        self._tableView = cc.TableView:create(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height))
        self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._tableView:setPosition(cc.p(0, 0))
        self._tableView:setDelegate()
        self._tableView:setBounceable(true) 
        self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
        self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
        self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
        self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
        tableBg:addChild(self._tableView)
        if self._tableView.setDragSlideable ~= nil then 
            self._tableView:setDragSlideable(true)
        end
        UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), 2, 6)
    end

    self._tableView:reloadData()
end

function ACShareGetGiftLayer:scrollViewDidScroll(view)
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function ACShareGetGiftLayer:cellSizeForTable(table,idx)
    local size = self._item:getContentSize()
    return size.height, size.width
end

function ACShareGetGiftLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local curData = self._data[idx + 1]
    local sysData = tab.shareActivity[tonumber(curData["id"])]
    local cell = self:createCell(cell, curData, sysData)    
    return cell
end

function ACShareGetGiftLayer:numberOfCellsInTableView(table)
    return #self._data
end

function ACShareGetGiftLayer:tableCellWillRecycle(table,cell)

end

function ACShareGetGiftLayer:createCell(cell, curData, sysData)
    if cell._item == nil then
        item = self._item:clone()
        item:setPosition(0, 0)
        cell:addChild(item)
        cell._item = item
    end
    local item = cell._item
    item:setVisible(true)

    --触发条件tip
    local curTip = item:getChildByFullName("tip1.curTip")
    curTip:setString(lang("FENXIANG_" .. sysData["id"] .. "01"))

    --reward
    local rwds = item:getChildByFullName("rwds")
    rwds:removeAllChildren()
    for i = 1, #sysData["reward"] do
        local rwdData = sysData["reward"][i]
        local num = rwdData[3]
        local itemId
        if IconUtils.iconIdMap[rwdData[1]] then
            itemId = IconUtils.iconIdMap[rwdData[1]]
        else
            itemId = rwdData[2]
        end

        if rwds._rwd1 == nil then
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = num})
            itemIcon:setName("itemIcon")
            itemIcon:setScale(0.7)
            itemIcon:setPosition(85 * (i - 1), 0)
            itemIcon:setSwallowTouches(false)
            rwds:addChild(itemIcon)
        else
            IconUtils:updateItemIconByView(rwds._rwd1, {itemId = itemId, num = num})
        end
    end

    --shareBtn
    local lvTip = item:getChildByFullName("lvTip")
    lvTip:setVisible(false)

    local rateStr = item:getChildByFullName("rateStr")
    rateStr:setString("")
    rateStr:setVisible(false)

    local shareBtn = item:getChildByFullName("shareBtn")
    shareBtn:setVisible(false)
    shareBtn:setSaturation(0)
    
    --effect
    if shareBtn.effect == nil then
        local effect = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
        effect:setPosition(cc.p(shareBtn:getContentSize().width*0.5, shareBtn:getContentSize().height*0.5))
        shareBtn.effect = effect
        shareBtn:addChild(effect)
    end
    shareBtn.effect:setVisible(false)
    
    if curData["state"] == 2 then   --等级限制
        lvTip:setVisible(true)
        local Label_34 = lvTip:getChildByFullName("Label_34")
        Label_34:setString(curData["tipInfo"] or "")
        local Label_35 = lvTip:getChildByFullName("Label_35")
        Label_35:setPositionX(Label_34:getPosition() + Label_34:getContentSize().width * 0.5)

    elseif curData["state"] == 3 then  --去达成
        shareBtn:setVisible(true)
        shareBtn:setTitleText("去达成")

        rateStr:setVisible(true)
        rateStr:setColor(UIUtils.colorTable.ccUIBaseColor1)
        local des = self:showProgessStr(curData, sysData)
        rateStr:setString(des)

        self:registerClickEvent(shareBtn, function()
            self:addBtnGotoEvent(curData["id"])
            end)

    elseif curData["state"] == 4 then  --去分享
        shareBtn:setVisible(true)
        shareBtn:setTitleText("去分享")

        shareBtn.effect:setVisible(true)

        rateStr:setVisible(true)
        rateStr:setColor(UIUtils.colorTable.ccUIBaseColor2)
        local des = self:showProgessStr(curData, sysData)
        rateStr:setString(des)

        self:registerClickEvent(shareBtn, function()
            self._curShareId = curData["id"]
            self:addBtnShareEvent(curData, sysData)
            end)

    elseif curData["state"] == 1 then   --已分享
        shareBtn:setVisible(true)
        shareBtn:setSaturation(-100)
        shareBtn:setTitleText("已分享")
        self:registerClickEvent(shareBtn, function()
            self._viewMgr:showTip("已分享")
            end)
    end

    return cell
end

--获取进度 3/4
function ACShareGetGiftLayer:showProgessStr(curData, sysData)
    local inType = curData["id"]
    local str = ""

    if inType == 6001 then
        str = curData["tipInfo"] .. "/" .. sysData["task_para"][2]

    elseif inType == 6002 or inType == 6004 or inType == 6005 then
        if curData["state"] == 3 then
            str = "0/1"
        else
            str = "1/1"
        end
        
    elseif inType == 6003 or inType == 6006 then
        str = curData["tipInfo"] .. "/" .. sysData["task_para"][1]
    end

    return str
end

--去达成
function ACShareGetGiftLayer:addBtnGotoEvent(inType)
    local curTime = self._userModel:getCurServerTime()
    self._startTime, self._endTime = self._shareGetModel:getAcTime()
    if self._startTime > curTime then
        self._viewMgr:showTip("活动未开始")
        return
    end

    if self._endTime <= curTime then
        self._viewMgr:showTip("活动已结束")
        return
    end

    if inType == 6001 then
        self._viewMgr:showView("team.TeamListView")
    elseif inType == 6002 then
        self._viewMgr:showView("treasure.TreasureView")
    elseif inType == 6003 then
        self._viewMgr:showView("arena.ArenaView")
    elseif inType == 6004 then
        self._viewMgr:showView("shop.ShopView", {idx = 3})
    elseif inType == 6005 then
        self._viewMgr:showDialog("activity.ActivitySevenDaysView", {})
    elseif inType == 6006 then
        self._viewMgr:showView("heroduel.HeroDuelMainView")
    end
end

--去分享
function ACShareGetGiftLayer:addBtnShareEvent(curData, sysData)
    local curTime = self._userModel:getCurServerTime()
    self._startTime, self._endTime = self._shareGetModel:getAcTime()
    if self._startTime > curTime then
        self._viewMgr:showTip("活动未开始")
        return
    end

    if self._endTime <= curTime then
        self._viewMgr:showTip("活动已结束")
        return
    end

    if not(sdkMgr:isWX() or sdkMgr:isQQ() or OS_IS_WINDOWS) then
        self._viewMgr:showTip(lang("SHARE_BAN"))
        return
    end
    
    if curData == nil or sysData == nil then
        return
    end

    local inType = curData["id"]
    local param = {}
    if inType == 6001 then
        param = {moduleName = "ShareTeamRaceModule", race = sysData["task_para"][1]}

    elseif inType == 6002 then
        param = {moduleName = "ShareTreasureModule", treasureid = curData["tipInfo"], isAsyncRes = true}

    elseif inType == 6003 then
        self:getArenaShareInfo()
        return
        
    elseif inType == 6004 then
        param = {moduleName = "ShareTeamModule", teamId = curData["tipInfo"]}

    elseif inType == 6005 then
        param = {moduleName = "ShareHeroModule", heroId = curData["tipInfo"]}

    elseif inType == 6006 then
        local heroDuelModel = self._modelMgr:getModel("HeroDuelModel")
        local winNums = curData["tipInfo"]
        local stage = heroDuelModel:getAniTypeByWins(winNums)
        param = {moduleName = "ShareHeroDuelModel", stage = stage, winNum = winNums, isAsyncRes = true}
    end

    if param == nil or next(param) == nil then
        return
    end

    param["canGetReward"] = 0
    param["callback1"] = function(inType)
        if self.getShareReward then
            self:getShareReward(inType)
        end
    end

    self._viewMgr:showDialog("share.ShareBaseView", param)
end

--获取竞技场分享数据
function ACShareGetGiftLayer:getArenaShareInfo()
    local param = {}
    --算战斗结果
    local function reviewTheBattle(result,reportData,isMeAtk,isWin)
        local left = BattleUtils.jsonData2lua_battleData(result.atk)
        local right = BattleUtils.jsonData2lua_battleData(result.def)
        local res, res1, res2 = BattleUtils.enterBattleView_Arena(left, right, result.r1, result.r2, 2, false,
            function (info, callback)
                if isMeAtk and isWin then
                    local arenaInfo = {}
                    arenaInfo.rank,arenaInfo.preRank,arenaInfo.preHRank = reportData.defRank,reportData.atkRank,reportData.atkRank
                    info.arenaInfo = arenaInfo
                end
                callback(info)
            end,
            function (info)
                -- 退出战斗
            end, true)

        return res, res1, res2
    end

    self._serverMgr:sendMsg("ArenaServer", "getReportList", {time = 0}, true, {}, function(result) 
        local reportInfo = result.list and result.list[1]
        if reportInfo and reportInfo.reportKey then
            self._serverMgr:sendMsg("BattleServer","getBattleReport", {reportKey = reportInfo.reportKey}, true, {}, function(result)
                local selfRoleId = self._modelMgr:getModel("UserModel"):getUID()
                local enemyName = result.def and result.def.name or ""
                if selfRoleId == result.def.rid then
                    enemyName = result.atk and result.atk.name or ""
                end
                self._modelMgr:getModel("ArenaModel"):setLastEnemyName(enemyName)
                local reportData = reportInfo.reportData
                local res, res1, res2 = reviewTheBattle(result, reportData, isMeAtk, isWin)
                if res2["hero1"] and res2["hero2"] and res2["leftData"] and res2["rightData"] then
                    local arenaModel = self._modelMgr:getModel("ArenaModel")
                    local battleData = arenaModel:getBestTeamData(res2["leftData"], res2["rightData"])
                    param = {
                        moduleName = "ShareArenaWinModule",
                        left = {
                            user = {art = res2["hero1"]["herohead"]},
                            team1 = {sysTeamData = tab.team[battleData["left"]["bestDamage"]],teamData = battleData["left"].teamDataDamage},
                            team2 = {sysTeamData = tab.team[battleData["left"]["bestHurt"]],teamData = battleData["left"].teamDataHurt}
                            },
                        right = {
                            user = {art = res2["hero2"]["herohead"]},
                            team1 = {sysTeamData = tab.team[battleData["right"]["bestDamage"]],teamData = battleData["right"].teamDataDamage},
                            team2 = {sysTeamData = tab.team[battleData["right"]["bestHurt"]],teamData = battleData["right"].teamDataHurt}
                            },
                        canGetReward = 0,
                        callback1 = function(inType)
                            if self.getShareReward then
                                self:getShareReward(inType)
                            end
                        end
                    }
                    self._viewMgr:showDialog("share.ShareBaseView", param)
                end
            end)
        else
            self._viewMgr:showDialog("global.GlobalSelectDialog",
                {desc = lang("FENXIANG_610100"),
                button1 = "确定", 
                button2 = "取消" ,
                callback1 = function ()
                   self._viewMgr:showView("arena.ArenaView")
                end,
                callback2 = function()
                end})
        end
        end)    
end

function ACShareGetGiftLayer:setCountTime()
    local countStr = self:getUI("bg.timeDes")
    countStr:setFontSize(18)
    local countNum = self:getUI("bg.timeNum")
    countNum:setFontSize(18)

    local curTime = self._userModel:getCurServerTime()
    self._startTime, self._endTime = self._shareGetModel:getAcTime()

    local tempTime = self._endTime - curTime -- 85600
    local day, hour, minute, second, tempValue
    self:runAction(cc.RepeatForever:create(
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
            countNum:setString(showTime)
            countNum:setPositionX(countStr:getPositionX() + 5)
        end),cc.DelayTime:create(1))
    ))
end

function ACShareGetGiftLayer:getShareReward(inType)
    if self._curShareId == nil then
        return
    end

    self._serverMgr:sendMsg("UserServer", "shareActivity", {id = self._curShareId, shareType = inType}, true, {}, function (result)
        DialogUtils.showGiftGet({
            gifts = result["reward"], 
            callback = function()
                if self.reflashUI and self._shareGetModel then
                    self._shareGetModel:refreshShareState(self._curShareId)
                    self._curShareId = nil
                    self:reflashUI()
                end
            end
            })
        end)
end

return ACShareGetGiftLayer