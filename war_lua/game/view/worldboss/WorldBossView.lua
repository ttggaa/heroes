--[[
    @FileName   WorldBossView.lua
    @Authors    zhangtao
    @Date       2018-07-27 17:29:13
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local WorldBossView = class("WorldBossView",BaseView)
WorldBossView.personType = 1
WorldBossView.unionType = 2
local tc = cc.Director:getInstance():getTextureCache()
local orderImagePath = {"arenaRank_first.png","arenaRank_second.png","arenaRank_third.png"}
local getStringTimeForInt = TimeUtils.getStringTimeForInt
local getDateString = TimeUtils.getDateString
local tabSetting = tab.setting
local progressBarImage = {[1] = "globalImageUI12_progress3.png",[2] = "globalImageUI12_progress2.png", [3] = "globalImageUI12_progress4.png", [4] = "globalImageUI12_progress4.png"}
function WorldBossView:ctor()
    self.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._worldBossModel = self._modelMgr:getModel("WorldBossModel")
    self._selectType = WorldBossView.personType   ---1 个人   2 联盟
    self._bossInfoTab = {}
    self._rankListTable = {}
    self._audoRefresh = true
    self._bossId = 1
    self._intervalTime = 0    --战斗间隔时间
    self._disTime = 0          
    self._refreshDisTime = 5  --刷新间隔时间
    self._bossStageType = 1        --当前boss所处阶段
    self._hasTime = 0
    self._oldStatus = 0
    self._hasAtkTimes = 0
    self._durationTime = tabSetting["WORLDBOSS_DURATION"].value
    self._hotHeroBuff = tabSetting["WORLDBOSS_HOTHERO_BUFF"].value
    self._step2 = tabSetting["WORLDBOSS_STEP2"].value
    self._step3 = tabSetting["WORLDBOSS_STEP3"].value
    self._maxTimes = tabSetting["WORLDBOSS_ATK_TIME"].value
    self._openTimeTab = string.split(tabSetting["WORLDBOSS_TIME"].value,":")
    self._spinAniNode = {}
end

-- 初始化UI后会调用, 有需要请覆盖
function WorldBossView:onInit()
    self:registerClickEventByName("btn_return",function()
        self:close()
        UIUtils:reloadLuaFile("worldboss.WorldBossView")
    end)

    self._ruleBtn = self:getUI("btn_rule")
    self._bossInfoBtn = self:getUI("btn_bossInfo")
    self._btnRewardBtn = self:getUI("btn_reward")
    self._hotHeroCell = self:getUI("leftPanel.hotBg.hotHeroCell")
    self._bossCell = self:getUI("leftPanel.hotBg.bossCell")
    self._fightBtn = self:getUI("bottomPanel.fightBtn")
    self._canFightTime = self:getUI("bottomPanel.canFightTime")
    self._canFightTime:enableOutline(cc.c4b(0,0,0,0), 1)
    self._progressBar = self:getUI("progressPanel.progressBar")
    self._proTime = self:getUI("progressPanel.proTime")
    self._proTime:enableOutline(cc.c4b(0,0,0,0), 1)
    self._endDes = self:getUI("endDes")
    self._bottomPanel = self:getUI("bottomPanel")
    self._noRankDes = self:getUI("rightPanel.rankBg.listBg.noRankDes")
    self._ownRankDes = self:getUI("rightPanel.rankBg.ownRankDes")
    self._bossBg = self:getUI("bossBg")
    self._endDes:setString(lang("worldBoss_Tips4"))
    self._bossName = self:getUI("titleBg.bossName")
    self._bossLevel = self:getUI("titleBg.bossLevel")
    self._redPoint = self:getUI("btn_reward.redPoint")
    self._hasTimesDes = self:getUI("bottomPanel.hasTimesDes")
    self._hasTimes = self:getUI("bottomPanel.hasTimes")
    self._noTimes = self:getUI("bottomPanel.noTimes")

    -- self._mountainBg = self:getUI("bossBg.mountainBg1")
    self._titleUserName = self:getUI("rightPanel.rankBg.titleUserName")
    self._orderTitle = self:getUI("rightPanel.rankBg.rankTitleBg.orderTitle")
    local hotHeroText = self:getUI("leftPanel.hotBg.hotHeroText")
    hotHeroText:setString(lang("worldBoss_Tips3"))

    self._canFightTime:setVisible(false)
    UIUtils:addFuncBtnName(self._ruleBtn, "规则",cc.p(self._ruleBtn:getContentSize().width/2,0),true,18)
    UIUtils:addFuncBtnName(self._bossInfoBtn, "怪物信息",cc.p(self._bossInfoBtn:getContentSize().width/2,0),true,18)
    UIUtils:addFuncBtnName(self._btnRewardBtn, "累计奖励",cc.p(self._btnRewardBtn:getContentSize().width/2,0),true,18)

    self:registerClickEvent(self._ruleBtn,function()
        self._viewMgr:showDialog("worldboss.WorldBossRuleView")
    end)

    self:registerClickEvent(self._bossInfoBtn,function()
        self._viewMgr:showDialog("worldboss.WorldBossInfoView",{bossId = self._bossId})
    end)

    self:registerClickEvent(self._btnRewardBtn,function()
        self._viewMgr:showDialog("worldboss.WorldBossRewardView")
    end)
    --战斗
    local maxResetTimes = #tab.worldBossColdDown or 0
    --重置花费对话框
    -- local resetDialog = function(needCost)
    --     print("=========resetDialog========"..needCost)
    --     local img = "globalImageUI_littleDiamond.png"
    --     local desc1 = "是否花费"
    --     local desc2 = "立即进入战斗"
    --     local desc = "[color=3d1f00,fontsize=24]".. desc1 .."[-][-][pic=".. img .. "][-][color=3d1f00,fontsize=24]".. needCost .."[color=3d1f00,fontsize=24]".. desc2 .."[-]"
    --     self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = desc,callback1 = function()            
    --         local has = self._userModel:getData().gem or 0
    --         if has < needCost then
    --             local title = lang("CRUSADE_TIPS_13")
    --             DialogUtils.showNeedCharge({button1 = "前往",title = title,callback1 = function ( ... )
    --                 self._viewMgr:showView("vip.VipView", {viewType = 0})
    --             end})
    --         else
    --             self:resetFightTime()
    --         end
    --     end,},true) 
    -- end
    -- local maxDialog = function()
    --     self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = "今日重置次数已达上限", button1 = "确定", callback1 = function( )

    --     end})
    -- end
    self:registerClickEvent(self._fightBtn,function()
        -- if self._intervalTime > 0 then
        --     local resetTimes = 0
        --     if self._bossInfoTab and self._bossInfoTab.worldBoss and self._bossInfoTab.worldBoss.buyTimes then
        --         resetTimes = self._bossInfoTab.worldBoss.buyTimes
        --     end
        --     if resetTimes >= maxResetTimes then
        --         maxDialog()
        --     else
        --         -- print("=====resetTimes======"..resetTimes)
        --         local needCost = tab.worldBossColdDown[resetTimes + 1]["cost"] or 0
        --         resetDialog(needCost)
        --     end
        -- else
        --     self:enterFormation()
        -- end
        if tonumber(self._hasAtkTimes) > 0 then
            self:enterFormation()
        else
            self._viewMgr:showTip("今日挑战次数已用尽")
        end
    end)

    self._personBtn = self:getUI("rightPanel.personBtn")
    self._unionBtn = self:getUI("rightPanel.unionBtn")
    --个人按钮
    self:registerClickEvent(self._personBtn,function()
        if self._selectType == WorldBossView.personType then
            return
        end
        -- self:test()
        self._titleUserName:setString("玩家")
        self:setSelectType(WorldBossView.personType)
        self:updateRankList()

    end)
    --联盟按钮
    self:registerClickEvent(self._unionBtn,function()
        if self._selectType == WorldBossView.unionType then
            return
        end
        -- self:test()
        self._titleUserName:setString("联盟")
        self:setSelectType(WorldBossView.unionType)
        self:updateRankList()
    end)

    self._listBg = self:getUI("rightPanel.rankBg.listBg")
    self._orderCell = self:getUI("rightPanel.rankBg.orderCell")
    self._orderCell:setVisible(false)
    -- self:createTableView()
    self:setSelectType(WorldBossView.personType)
    self._updateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
        self:update(dt)
    end)
    --boss开启时间
    self:checkBossOpenTime()
    --spin动画
    self:createSpinAnim()
    --掉落奖励
    self:dropAward()
    self:updateUI()

end

function WorldBossView:test()
    local currTime = self._userModel:getCurServerTime()
    local tempTime = TimeUtils.formatTimeToFiveOclock(currTime)
    local h = getDateString(tempTime,"%H")
    local m = getDateString(tempTime,"%M")
    local s = getDateString(tempTime,"%S")

    print("======h======"..h)
    print("======m======"..m)
    print("======s======"..s)
end

--重置
function WorldBossView:resetFightTime()
    -- self._serverMgr:sendMsg("WorldBossServer", "rmCD", {}, true, {}, function(result, errorCode)
    --     self._viewMgr:unlock(51)
    --     self._intervalTime = 0
    --     self:setFightTimeNotice()
    -- end)
end

function WorldBossView:update(dt)
    self:checkBossOpenTime()
    if self._hasTime == 0 then
        return
    end
    if self._audoRefresh then
        self._disTime = self._disTime + dt
        if self._disTime >= self._refreshDisTime then
            self._disTime = 0
            self:getBossInfo(false)
        end
    end
    -- if self._intervalTime > 0 then
    --     self._intervalTime = self._intervalTime - 1
    -- end
    if self._hasTime > 0 then
        self._hasTime = self._hasTime - 1
        self:updateUI()
    end
    -- self:setFightTimeNotice()
end

function WorldBossView:setFightTimeNotice()
    -- if self._intervalTime > 0 then
    --     self._canFightTime:setVisible(true)
    --     local timeStr = getStringTimeForInt(self._intervalTime)
    --     self._canFightTime:setString(timeStr .."可继续战斗")
    -- else
    --     self._canFightTime:setVisible(false)
    -- end
end

function WorldBossView:setSelectType(selectType)

    if selectType == WorldBossView.personType then
        self._personBtn:setBright(false)
        self._unionBtn:setTouchEnabled(true)
        self._personBtn:setTouchEnabled(false)
    else
        self._personBtn:setBright(true)
    end 
    if selectType == WorldBossView.unionType then
        self._unionBtn:setBright(false)
        self._unionBtn:setTouchEnabled(false)
        self._personBtn:setTouchEnabled(true)
    else
        self._unionBtn:setBright(true)
    end
    self._selectType = selectType
end

function WorldBossView:createTableView()
    if self._listTableView then
        self._listTableView:reloadData()
        return
    end
    self._listTableView = cc.TableView:create(cc.size(360,290))
    self._listTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listTableView:setAnchorPoint(0,0)
    self._listTableView:setPosition(0,0)
    self._listTableView:setDelegate()
    self._listTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listTableView:setBounceable(true)
    self._listBg:addChild(self._listTableView)
    self._listTableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._listTableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._listTableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._listTableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._listTableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listTableView:reloadData()
    -- self._listTableView:setTouchEnabled(false)
end

function WorldBossView:scrollViewDidScroll(view)
    -- body
end

function WorldBossView:tableCellTouched(table,cell)

end


function WorldBossView:cellSizeForTable(table,idx)
    return 35,340
end

function WorldBossView:tableCellAtIndex(table,idx)
    local index = idx + 1
    local cell = table:dequeueCell()
    if cell == nil then
        cell = cc.TableViewCell:new()
        local listCell = self._orderCell:clone()
        listCell:setVisible(true)
        listCell:setAnchorPoint(0,0)
        listCell:setTouchEnabled(false)
        listCell:setPosition(0, 0)
        listCell:setTag(9999)
        cell:addChild(listCell)
        self:updateCellInfo(listCell,index)
    else
        local listCell = cell:getChildByTag(9999)
        if not listCell then return end
        self:updateCellInfo(listCell,index)
    end
    return cell
end

function WorldBossView:numberOfCellsInTableView(table)
    if self._rankListTable[self._selectType]["rankList"] then
        return #self._rankListTable[self._selectType]["rankList"]
    end
    return 0
end

function WorldBossView:upDateTableView()
    if self._listTableView then
        self._listTableView:reloadData()
    else
        self:createTableView()
    end
end

function WorldBossView:updateCellInfo(cell,index)
    local order = cell:getChildByFullName("order")
    local name = cell:getChildByFullName("name")
    local score = cell:getChildByFullName("score")
    local cellBg = cell:getChildByFullName("cellBg")
    local listData = self._rankListTable[self._selectType]["rankList"][index]
    order:setString(listData["rank"])
    name:setString(listData["name"])
    local scoreFormat = self:damageFormat(listData["score"])
    score:setString(scoreFormat)
    local r1,r2 = math.modf(index/2)
    -- print("====r1==r2======",r1 .."     "..r2)
    cellBg:setVisible(r2 == 0 and true or false)
    self:setOrderImage(cell,listData["rank"])
end

function WorldBossView:initMyRank()
    local order = self._orderCell:getChildByFullName("order")
    local name = self._orderCell:getChildByFullName("name")
    local score = self._orderCell:getChildByFullName("score")
    local cellBg = self._orderCell:getChildByFullName("cellBg")
    local orderImage = self._orderCell:getChildByFullName("orderImage")
    if tonumber(self._selectType) == WorldBossView.personType then
        self._orderTitle:setString("我的排行")
    elseif tonumber(self._selectType) == WorldBossView.unionType then
        self._orderTitle:setString("我的联盟")
    end
    if self._rankListTable[self._selectType]["owner"] and next(self._rankListTable[self._selectType]["owner"]) then
        local ownData = self._rankListTable[self._selectType]["owner"]
        if tonumber(ownData["rank"]) == 0 then
            self._orderCell:setVisible(false)
            self._ownRankDes:setVisible(true)
        else
            order:setString(ownData["rank"])
            name:setString(ownData["name"])
            local scoreFormat = self:damageFormat(ownData["score"])
            score:setString(scoreFormat)
            self:setOrderImage(self._orderCell,ownData["rank"])
            self._orderCell:setVisible(true)
            self._ownRankDes:setVisible(false)

        end
    else
        self._orderCell:setVisible(false)
        self._ownRankDes:setVisible(true)
    end
end

function WorldBossView:setOrderImage(listNode,rank)
    local orderDes = listNode:getChildByFullName("order")
    local orderImage = listNode:getChildByFullName("orderImage")
    -- print("=======rank======="..rank)
    if tonumber(rank) > 3 then
        orderDes:setVisible(true)
        orderImage:setVisible(false)
    else
        orderDes:setVisible(false)
        orderImage:setVisible(true)
        orderImage:loadTexture(orderImagePath[rank],1)
    end
    -- orderDes:setVisible(tonumber(rank) > 3 and true or false)
    -- orderImage:setVisible(tonumber(rank) > 3 and false or true)
    -- if orderImage:isVisible() then
    --     orderImage:loadTexture(orderImagePath[rank],1)
    -- end
end

function WorldBossView:updateRankList()
    if self._selectType == WorldBossView.personType then
        if next(self._bossInfoTab) and self._bossInfoTab["pRank"] then
            self._rankListTable[WorldBossView.personType] = {}
            self._rankListTable[WorldBossView.personType] = self._bossInfoTab["pRank"] or {}
            if next(self._rankListTable[WorldBossView.personType]) then
                table.sort(self._rankListTable[WorldBossView.personType]["rankList"], function (a, b)
                    return tonumber(a.rank) < tonumber(b.rank)
                end)
                self._noRankDes:setVisible(false)
            else
                self._noRankDes:setVisible(true)
            end
        end
    elseif self._selectType == WorldBossView.unionType then
        if next(self._bossInfoTab) and self._bossInfoTab["lRank"] then
            self._rankListTable[WorldBossView.unionType] = {}
            self._rankListTable[WorldBossView.unionType] = self._bossInfoTab["lRank"] or {}
            if next(self._rankListTable[WorldBossView.unionType]) then
                table.sort(self._rankListTable[WorldBossView.unionType]["rankList"], function (a, b)
                    return tonumber(a.rank) < tonumber(b.rank)
                end)
                self._noRankDes:setVisible(false)
            else
                self._noRankDes:setVisible(true)
            end
        end
    end
    self:upDateTableView()
    self:initMyRank()
end

function WorldBossView:setBossName()
    local bossName = tab.worldBossMain[self._bossId]["bossName"]
    self._bossName:setString(lang(bossName))
    local bossLevel = tab.worldBossMain[self._bossId]["bossLevel"]
    self._bossLevel:setString("Lv."..bossLevel)
end

function WorldBossView:setFightTimes()
    print("========self._hasAtkTimes========"..self._hasAtkTimes)
    self._hasAtkTimes = tonumber(self._hasAtkTimes) < 0 and 0 or self._hasAtkTimes
    if tonumber(self._hasAtkTimes) <= 0 then
        self._hasTimes:setVisible(false)
        self._hasTimesDes:setVisible(false)
        self._noTimes:setVisible(true)
        self._fightBtn:setTouchEnabled(false)
        UIUtils:setGray(self._fightBtn,true)
    else
        self._hasTimes:setVisible(true)
        self._hasTimesDes:setVisible(true)
        self._noTimes:setVisible(false)
        self._hasTimes:setString(self._hasAtkTimes)
        self._fightBtn:setTouchEnabled(true)
        UIUtils:setGray(self._fightBtn,false)
    end
end

function WorldBossView:getBossInfo(isFirst)
    self._viewMgr:lock(isFirst and 1 or -1)
    self._serverMgr:sendMsg("WorldBossServer", "getInfo", {}, true, {}, function(result, errorCode)
        self._viewMgr:unlock(51)
        self._audoRefresh = true
        if errorCode ~= 0 then 
            -- errorCallback()
            return
        end
        -- dump(result)
        self._bossInfoTab = result
        self._bossId = result.bossId
        if result.worldBoss and result.worldBoss.atkTimes then
            local atkTimes = result.worldBoss.atkTimes
            print("======atkTimes========"..atkTimes)
            self._hasAtkTimes = self._maxTimes - atkTimes
        end
        -- self:setIntervalTime()
        self:updateRankList()
        self:checkAwardRed()
        self:setFightTimes()
        if isFirst then
            self:setHotHero()
            self:setBossName()
        end
    end)
end



--热点英雄
function WorldBossView:setHotHero()
    if self._bossInfoTab["hotHeros"] then
        self:creatHotHeroTableView()
    else

    end
end

function WorldBossView:creatHotHeroTableView()
    if self._hotHeroTableView then
        self._hotHeroTableView:reloadData()
        return 
    end
    local tableView = cc.TableView:create(cc.size(220,100))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(3 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._hotHeroCell:addChild(tableView,999)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTableByHot(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndexByHot(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableViewByHot(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._hotHeroTableView = tableView
end

function WorldBossView:cellSizeForTableByHot(table,idx) 
    return 75,71
end

function WorldBossView:tableCellAtIndexByHot(table,idx)
    local index = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local hotHeros = self._bossInfoTab["hotHeros"]
    if hotHeros[index] == nil then
        return
    end
    local heroData = clone(tab:Hero(hotHeros[index]))
    heroData.hideFlag = true
    local heroIcon = IconUtils:createHeroIconById({sysHeroData = heroData})

    heroIcon:setAnchorPoint(cc.p(0.5,0.5))
    heroIcon:setScale(0.55)
    heroIcon:setPosition(40,50)
    heroIcon:setVisible(true)
    cell:addChild(heroIcon,2)

    local mcAni = mcMgr:createViewMC("saijirediankuang_leaguerediantexiao", true,false)
    mcAni:setScale(0.7)
    mcAni:setPosition(40,53)
    cell:addChild(mcAni, 3)

    self:registerClickEvent(heroIcon, function()
        local NewFormationIconView = require "game.view.formation.NewFormationIconView"
        local param = {
            isCustom = true, 
            iconType = NewFormationIconView.kIconTypeLocalHero, 
            iconId = hotHeros[index],
            }
        self._viewMgr:showDialog("formation.NewFormationDescriptionView", param, true)
    end)
    heroIcon:setSwallowTouches(false)
    return cell
end

function WorldBossView:numberOfCellsInTableViewByHot(table)
    return #self._bossInfoTab["hotHeros"] or 0
end

--Boss 掉落
function WorldBossView:dropAward()
    if tab.worldBossMain[self._bossId]["dropItem"] then
        self:creatDropTableView()
    end
end

function WorldBossView:creatDropTableView()
    if self._dropTableView then
        self._dropTableView:reloadData()
        return 
    end
    local tableView = cc.TableView:create(cc.size(220,70))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(3 ,0)
    tableView:setColor(cc.c3b(80, 80, 80))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._bossCell:addChild(tableView,999)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTableByDrop(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndexByDrop(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableViewByDrop(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._dropTableView = tableView
end

function WorldBossView:cellSizeForTableByDrop(table,idx) 
    return 70,70
end

function WorldBossView:tableCellAtIndexByDrop(table,idx)
    local index = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local awardTab = tabSetting["WORLDBOSS_ITEM_SHOW"].value[index] or {}
    local itemIcon = self:createAwardItem(awardTab)
    itemIcon:setAnchorPoint(cc.p(0.5,0.5))
    itemIcon:setScale(0.68)
    itemIcon:setPosition(36,34)
    cell:addChild(itemIcon)
    return cell
end

function WorldBossView:numberOfCellsInTableViewByDrop(table)
    return #tabSetting["WORLDBOSS_ITEM_SHOW"].value or 0
end

function WorldBossView:createAwardItem(itemAward)
    local itemIcon = nil
    local itemType = itemAward[1]
    local itemId = itemAward[2]
    local itemNum = itemAward[3]
    local eventStyle = 1
    if itemType == "hero" then
        local heroData = clone(tab:Hero(itemId))
        itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
        for i=1,6 do
            if itemIcon:getChildByName("star" .. i) then
                itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
            end
        end
        registerClickEvent(itemIcon, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
        end)
    elseif itemType == "team" then
        local teamTeam = clone(tab:Team(itemId))
        itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam,isJin=true})
       
    elseif itemType == "avatarFrame" then
        local frameData = tab:AvatarFrame(itemId)
        param = {itemId = itemId, itemData = frameData}
        itemIcon = IconUtils:createHeadFrameIconById(param)
    elseif itemType == "siegeProp" then
        local propsTab = tab:SiegeEquip(itemId)
        local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
        itemIcon = IconUtils:createWeaponsBagItemIcon(param)
    else
        if itemType ~= "tool" then
            itemId = IconUtils.iconIdMap[itemType]
        end
        itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum,eventStyle = eventStyle})
        if itemIcon.iconColor.numLab then
            itemIcon.iconColor.numLab:setVisible(false)
        end
    end
    return itemIcon
end
--设置战斗间隔时间
function WorldBossView:setIntervalTime()
    -- local currTime = self._userModel:getCurServerTime()
    -- local lastAtkTime = 0
    -- if self._bossInfoTab and self._bossInfoTab.worldBoss and self._bossInfoTab.worldBoss.lastAtkTime then
    --     lastAtkTime = self._bossInfoTab.worldBoss.lastAtkTime
    -- end
    -- local disTime = tabSetting["WORLDBOSS_COLDDOWN"].value*60 - (currTime - lastAtkTime)
    -- -- local disTime = (currTime - lastUpTime) - 180
    -- self._intervalTime = disTime < 0 and 0 or disTime
end

function WorldBossView:damageFormat(damageValue)
    local damage = damageValue
    if tonumber(damageValue) > 99999 then
        if tonumber(damageValue) > 99999999 then
            damage = tonumber(string.format("%0.2f",damageValue/100000000)).."亿"
        else
            damage = tonumber(string.format("%0.2f",damageValue/10000)).."万"
        end
    end
    return damage
end

function WorldBossView:checkBossOpenTime()
    local currTime = self._userModel:getCurServerTime()
    local h = getDateString(currTime,"%H")
    local m = getDateString(currTime,"%M")
    local s = getDateString(currTime,"%S")
    local curSecNum = h*3600 + m*60 + s
    local openSecNum = self._openTimeTab[1]*3600 + self._openTimeTab[2]*60 + self._openTimeTab[3]
    if tonumber(curSecNum - openSecNum) < 0 then
        self._hasTime = 0
    else
        local hasTime = self._durationTime*60 - (curSecNum - openSecNum)
        self._hasTime = hasTime < 0 and 0 or hasTime
    end
    if self._worldBossModel.isDebug then
        self._hasTime = 1000
    end
    print("======hasTime=======",self._hasTime)
    if self._hasTime == 0 then
        self._bossStageType = 4
    end
end

function WorldBossView:updateUI()
    self:setProgress()
    self:setBossStage()
end

function WorldBossView:setProgress()
    local proValue = tonumber(string.format("%0.4f",self._hasTime/(self._durationTime*60)))*100
    local value1 = self._hasTime/(self._durationTime*60)
    self._progressBar:setPercent(value1*100)
    self._proTime:setString(proValue .."%")
end
--设置当前boss所处的阶段
function WorldBossView:setBossStage()
    local imagePath = "globalImageUI12_progress4.png"
    if tonumber(self._hasTime) == 0 then
        self._bossStageType = 4    --已结束
    elseif tonumber(self._hasTime) < tonumber(self._step3*60) then
        self._bossStageType = 3
        imagePath = "globalImageUI12_progress4.png"
    elseif tonumber(self._hasTime) < tonumber(self._step2*60) then
        self._bossStageType = 2
        imagePath = "globalImageUI12_progress2.png"
    else
        self._bossStageType = 1
        imagePath = "globalImageUI12_progress3.png"
    end
    -- print("========self._oldStatus=========="..self._oldStatus)
    -- print("========self._bossStageType=========="..self._bossStageType)
    if self._oldStatus ~= self._bossStageType then
        self._oldStatus = self._bossStageType
        if self._bossStageType == 4 then
            self._endDes:setVisible(true)
            self._bottomPanel:setVisible(false)
        else
            self._endDes:setVisible(false)
            self._bottomPanel:setVisible(true)
        end
        self._progressBar:loadTexture(imagePath,1)
        self:upDateBossAnim()
    end
end

function WorldBossView:upDateBossAnim()
    local spin1 = self._bossBg:getChildByTag(100001)
    local spin11 = self._bossBg:getChildByTag(1000011)
    local spin2 = self._bossBg:getChildByTag(100002)
    local spin3 = self._bossBg:getChildByTag(100003)
    -- self._bossStageType = 3
    spin1:setVisible(false)
    spin11:setVisible(false)
    spin2:setVisible(false)
    spin3:setVisible(false)
    if self._bossStageType == 1 then
        spin1:setVisible(true)
        spin11:setVisible(true)
    elseif self._bossStageType == 2 then
        spin2:setVisible(true)
    elseif self._bossStageType == 3 then
        spin3:setVisible(true)
    else
        spin3:setVisible(true)
    end
end

--进入布阵
function WorldBossView:enterFormation()
    local formationType = self._modelMgr:getModel("FormationModel").kFormationTypeWorldBoss
    self._viewMgr:showView("formation.NewFormationView", {
        recommend = self._bossInfoTab["hotHeros"] or {},
        formationType = formationType,
        extend = {pveData = {formationinf = "worldBoss_Tips1"}},
        callback = 
            function(...)
                local paramTable = {...}
                self:enterFight(paramTable)
            end,
        closeCallback = 
            function(inIsNpcHero)
            end}
        )
end

--进入战斗
function WorldBossView:enterFight(inLeftData)
    local hhScore = 0
    if self._bossInfoTab["worldBoss"]["hhScore"] then
        if next(self._bossInfoTab["worldBoss"]["hhScore"]) then
            hhScore = self._bossInfoTab["worldBoss"]["hhScore"]["1"]
        end
    end 
    local param = {}
    self._serverMgr:sendMsg("WorldBossServer", "atkBefore", param, true, {}, function (result,errorCode)
        local bossStateId = self._worldBossModel:getBossStateId(self._bossId)
        self._battleToken = result["token"]
        self._viewMgr:popView()
        if self._lockCallBack ~= nil then 
            self._lockCallBack(true)
        end
        BattleUtils.enterBattleView_BOSS_WordBoss(BattleUtils.jsonData2lua_battleData(result["atk"]), function (info,callBack)
            local infoAdd = clone(info)
            infoAdd.bossStateId = bossStateId or 0
            self:battleCallBack(infoAdd,callBack)
        end,
        function (info)
            if self._lockCallBack ~= nil then 
                self._lockCallBack(false)
            end
        end,result["r1"],result["r2"],bossStateId,hhScore,tab.worldBossMain[self._bossId]["bossLevel"],tab.worldBossMain[self._bossId]["heros"])
    end,
    function (errorCode)
        if errorCode == 9806 then
            self:lock()
            ScheduleMgr:delayCall(300, self, function( )
                self:unlock()
                self._viewMgr:popView()
                self:close()  
            end)
        end
    end)
end
--战斗返回
function WorldBossView:battleCallBack(inResult,inCallBack)
    self._battleWin = 0
    if inResult == nil then 
        if self._lockCallBack ~= nil then 
            self._lockCallBack(false)
        end
        -- if inCallBack ~= nil then
        --     inCallBack(inResult)
        -- end
        return 
    end
    if inResult.win ~= nil and inResult.win == true then 
       self._battleWin = 1
    end
    local isInclude = self:isIncludeHotHero(clone(inResult))
    -- local heroDamage = inResult.heroDamage1 or 0
    -- local damageValue = inResult.totalRealDamage1 or 0
    local damageValue = inResult.curTotalHurt or 0--damageValue + heroDamage
    local realDamage = damageValue
    if isInclude then
        realDamage = math.floor(realDamage*self._hotHeroBuff)
    end
    print("======bossId========="..inResult.bossStateId)
    print("======originalDamage========="..damageValue)
    print("======realDamage========="..realDamage)
    local param = { 
                bossId = inResult.bossStateId or 0,
                args = json.encode({
                    skillList = inResult.skillList,
                    zzid = GameStatic.zzid8,
                    damage = realDamage,
                    originalDamage = damageValue,
                    }),
                token = self._battleToken}  
    self._serverMgr:sendMsg("WorldBossServer", "atkAfter", param, true, {}, function (result)
        if result == nil then 
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 5, extract = result["extract"]})
            end
            return 
        end
        if inCallBack ~= nil then
            local inResultData = clone(inResult)
            inResultData.win = true
            inResultData.hotHeroBuff = self._hotHeroBuff
            inResultData.beforeRank = result["beforeRank"] or 0
            inResultData.afterRank = result["afterRank"] or 0
            inResultData.hotHeros = self._bossInfoTab["hotHeros"] or {}
            inResultData.totalHurtValue = self:userTotalHurtValue()
            inResultData.damageValue = result["damage"] or realDamage   --result["damage"]是后端返回的加成后的伤害
            inCallBack(inResultData,result.reward)
        end
        self._hasAtkTimes = self._hasAtkTimes - 1
        self:setFightTimes()
    end, function (error)
        if error then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 8, __error = error})
            end
        end
    end)
end
function WorldBossView:userTotalHurtValue()
    local personOwner = self._rankListTable[WorldBossView.personType]["owner"]
    if personOwner and next(personOwner) then
        return personOwner["score"]
    end
    return 0
end

function WorldBossView:onBeforeAdd(callback, errorCallback)
    self._audoRefresh = false
    self:getBossInfo(true)
    callback()
end

function WorldBossView:isIncludeHotHero(result)
    local hotHeros = self._bossInfoTab["hotHeros"] or {}
    local formHeroId = result.hero1["id"]
    if next(hotHeros) then
        for k ,id in pairs(hotHeros) do
            if tonumber(id) == tonumber(formHeroId) then
                return true
            end
        end
    end
    return false
end

-- 第一次进入调用, 有需要请覆盖
function WorldBossView:onShow()

end

-- 被其他View盖住会调用, 有需要请覆盖
function WorldBossView:onHide()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
end
function WorldBossView:destroy()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    spineMgr:clear()
end

function WorldBossView:onTop()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
    self._updateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
        self:update(dt)
    end)
    self._oldStatus = 0
    self:checkBossOpenTime()
    self:updateUI()
    self._audoRefresh = false
    self:getBossInfo(false)
end

function WorldBossView:createSpinAnim()
    tc:addImage("asset/spine/shenglong.png")
    tc:addImage("asset/spine/shenglong1.png")
    tc:addImage("asset/spine/binglong2.png")
    tc:addImage("asset/spine/binglong3.png")
    --身体
    spineMgr:createSpine("shenglong", function (spine)
        -- spine:setScale(1)
        spine:setAnimation(0, "shenglong", true)
        spine:setPosition(290,40)
        
        self._bossBg:addChild(spine,3,100001)
    end)
    --尾巴
    spineMgr:createSpine("shenglong1", function (spine)
        -- spine:setScale(1)
        spine:setAnimation(0, "shenglong1", true)
        spine:setPosition(290,40)
        
        self._bossBg:addChild(spine,1,1000011)
    end)

    spineMgr:createSpine("binglong2", function (spine)
        spine:setScale(0.9)
        spine:setAnimation(0, "binglong2", true)
        spine:setPosition(260,-95)
        
        self._bossBg:addChild(spine,3,100002)
    end)

    spineMgr:createSpine("binglong3", function (spine)
        -- spine:setScale(0.9)
        spine:setAnimation(0, "binglong3", true)
        spine:setPosition(286,-50)
  
        self._bossBg:addChild(spine,3,100003)
    end)
end

function WorldBossView:checkAwardRed()
    local redState = self._worldBossModel:checkAwardRed()
    self._redPoint:setVisible(redState)
-- self._redPoint
end

-- 接收自定义消息
function WorldBossView:reflashUI(data)

end

function WorldBossView:getAsyncRes()
    return 
    {
        {"asset/ui/worldBoss.plist", "asset/ui/worldBoss.png"}
    }
end

function WorldBossView:getBgName()
    return "worldBoss.jpg"
end

return WorldBossView