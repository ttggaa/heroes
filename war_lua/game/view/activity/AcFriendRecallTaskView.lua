--[[
    Filename:    AcFriendRecallTaskView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-09-09 12:13
    Description: 好友召回任务
--]]

local AcFriendRecallTaskView = class("AcFriendRecallTaskView", BasePopView)

function AcFriendRecallTaskView:ctor(param)
	AcFriendRecallTaskView.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._recallModel = self._modelMgr:getModel("FriendRecallModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")

    self._data = {}
    self._callback = param.callback
end

function AcFriendRecallTaskView:getAsyncRes()
    return 
    {
        {"asset/ui/friend1.plist", "asset/ui/friend1.png"},
    }
end

function AcFriendRecallTaskView:onInit()
    local unbind = self:getUI("bg.bg1.rightPanel.unBind")
    local binded = self:getUI("bg.bg1.rightPanel.binded")
    unbind:setVisible(false)
    binded:setVisible(false)

    self._item = self:getUI("item")

    local des = self:getUI("bg.bg1.rightPanel.unBind.des")
    des:setString(lang("FRIENDTASK_EMPTY"))
    des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local name = self:getUI("bg.bg1.rightPanel.binded.name")
    name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local bindDes = self:getUI("bg.bg1.rightPanel.binded.des")
    bindDes:setString("")
    local des1 = self:getUI("bg.bg1.rightPanel.des_1")
    des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local tipLab = self:getUI("bg.bg1.rightPanel.timer.tipLab")
    tipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local timeLab = self:getUI("bg.bg1.rightPanel.timer.timeLab")
    timeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    --ruleBtn
    local ruleBtn = self:getUI("bg.bg1.rightPanel.ruleBtn")
    self:registerClickEvent(ruleBtn, function(sender)
        local ruleDes = lang("FRIENDBACK_RULES")
        self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = ruleDes},true)
        end)

    --bindBtn
    local bindBtn = self:getUI("bg.bg1.rightPanel.unBind.bindBtn")
    self:registerClickEvent(bindBtn, function(sender)
        if self._countTime and self._countTime <= 0 then
            self._viewMgr:showTip("活动已结束")
            return
        end
        self._serverMgr:sendMsg("RecallServer", "getRecalledList", {}, true, {}, function (result)
            local param = {callback = function()
                self:reflashUI()
            end} 
            self._viewMgr:showDialog("friend.FriendBindInfoView", param, true)
            end)
        end)

    --closeBtn
    local closeBtn = self:getUI("bg.bg1.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        end)

    --shopBtn
    local shopBtn = self:getUI("bg.bg1.leftPanel.shopBtn")
    shopBtn:setScaleAnim(true)
    self:registerClickEvent(shopBtn, function(sender)
        local isOpen = tab.systemOpen["FriendShop"]
        local curLv = self._userModel:getData().lvl or 0
        if curLv < isOpen[1] then
            self._viewMgr:showTip(lang("TIP_FriendShop"))
            return
        end

        self._viewMgr:showDialog("friend.FriendShopView", {}, true)
        end)

    --tabBtn
    for i=1, 3 do
        local tab = self:getUI("bg.bg1.leftPanel.tab" .. i)
        tab:setPositionX(72)
        tab:setScaleAnim(false)
        self:registerClickEvent(tab, function(sender)
            self:tabButtonClick(sender) 
            end)
    end

    self:setBtnState()

    --model监听
    self:setListenReflashWithParam(true)
    self:listenReflash("FriendRecallModel", self.updateCurChannel)
    
    --场景监听
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            if self._callback then
                self._callback()
            end
            UIUtils:reloadLuaFile("activity.AcFriendRecallTaskView")

        elseif eventType == "enter" then 
            self:setCountTime()
            local tab1 = self:getUI("bg.bg1.leftPanel.tab1")
            self:tabButtonClick(tab1)
        end
    end)
end

function AcFriendRecallTaskView:updateCurChannel(inData)
    if inData == nil then
        return
    end 
       
    local data = string.split(inData, "_")
    if data[1] ~= "friendAct" then
        return
    end

    if self._channel == nil or self._tableView == nil then
        return
    end

    self:reflashUI()

    if not data[2] or data[2] ~= "bind" then
        self._taskData = self._recallModel:getAcTaskByType(self._channel)
        self._tableView:reloadData()
    end
end

function AcFriendRecallTaskView:reflashUI(inData)
    --获取频道model数据
    self._data = self._recallModel:getAcData()
    -- dump(self._data, "reflashUI", 10)

    --redpoint
    self:refreshRedPoint()

    --bind
    local unbind = self:getUI("bg.bg1.rightPanel.unBind")
    local unbindRed = self:getUI("bg.bg1.rightPanel.unBind.redPoint")
    local binded = self:getUI("bg.bg1.rightPanel.binded")
    unbind:setVisible(false)
    unbindRed:setVisible(false)
    binded:setVisible(false)
    if self._data["bindInfo"] and next(self._data["bindInfo"]) ~= nil then
        binded:setVisible(true)
        local bindInfo = self._data["bindInfo"]

        local name = self:getUI("bg.bg1.rightPanel.binded.name")
        name:setString(bindInfo["nickName"] or "")

        local bindDes = self:getUI("bg.bg1.rightPanel.binded.des")
        if sdkMgr:isQQ() == true then
            bindDes:setString("已绑定QQ好友")
        elseif sdkMgr:isWX() == true then
            bindDes:setString("已绑定微信好友")
        end

        local avatar = IconUtils:createUrlHeadIconById({name = bindInfo["nickName"], url = bindInfo["picUrl"], openid = bindInfo["pId"], tencetTp = bindInfo["qqVip"], tp = 4})
        avatar:setAnchorPoint(0.5, 0.5)
        avatar:setPosition(name:getPositionX(), 68)
        avatar:setScale(0.8)
        binded:addChild(avatar)

        registerClickEvent(avatar, function() 
            local fid = (bindInfo["lvl"] and bindInfo["lvl"] >= 15) and 101 or 1
            self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = bindInfo["rid"], fid = fid, fsec = bindInfo["sec"]}, true, {}, function(result) 
                if not result then
                    self._viewMgr:showTip("请求数据失败")
                    return
                end

                if result["tequan"] == nil then
                    result["tequan"] = bindInfo["tequan"]
                end

                if result["qqVip"] == nil then
                    result["qqVip"] = bindInfo["qqVip"]
                end

                local viewType = FriendConst.FRIEND_TYPE.PLATFORM
                self._viewMgr:showDialog("friend.FriendUserInfoView", {data = result, viewType = viewType}, true)
            end)
        end)

    else
        unbind:setVisible(true)
        local bindList = self._recallModel:getBindData()
        if next(bindList) ~= nil then
            unbindRed:setVisible(true)
        end
    end
end

function AcFriendRecallTaskView:refreshRedPoint()
    for i=1, 3 do
        local redPoint = self:getUI("bg.bg1.leftPanel.tab" .. i .. ".redPoint")
        local isShow = self._recallModel:getAcRedPoint(i)
        redPoint:setVisible(isShow)
    end
end

function AcFriendRecallTaskView:tabButtonClick(sender)
    if self._tabName == sender:getName() then  
        return
    end

    self:setBtnState(sender)
    
    self._tabName = sender:getName()
    self._channel = tonumber(string.sub(self._tabName, 4, string.len(self._tabName)))

    --获取频道model数据
    self._taskData = self._recallModel:getAcTaskByType(self._channel)
    dump(self._taskData, "task", 10)

    --初始化tableview 创建cell
    local tableBg = self:getUI("bg.bg1.rightPanel.tableBg")
    if self._tableView ~= nil then 
        self._tableView:removeFromParent()
        self._tableView = nil
    end

    local wid, hei = tableBg:getContentSize().width - 12, tableBg:getContentSize().height - 16
    self._tableView = cc.TableView:create(cc.size(wid, hei))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(4, 8))
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
    
    self._tableView:reloadData()
end

function AcFriendRecallTaskView:scrollViewDidScroll(view)
end

function AcFriendRecallTaskView:cellSizeForTable(table,idx)
    return 130, 638
end

function AcFriendRecallTaskView:numberOfCellsInTableView(table)
    return #self._taskData
end

function AcFriendRecallTaskView:tableCellWillRecycle(table,cell)
end

-- 创建在某个位置的cell
function AcFriendRecallTaskView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local cellData = self._taskData[idx + 1]
    if cell.item == nil then
        local item = self._item:clone()
        item = self:updateCell(item, cellData, idx)
        item:setPosition(cc.p(3,0))
        item:setAnchorPoint(cc.p(0,0))
        cell.item = item
        cell:addChild(item)
    else
        self:updateCell(cell.item, cellData, idx)
    end

    return cell
end

function AcFriendRecallTaskView:updateCell(item, cellData, idx)
    if cellData == nil or cellData["taskId"] == nil then
        return
    end

    local sysFriendQuest = tab.friendQuest
    local taskData = sysFriendQuest[cellData["taskId"]]

    --reward
    for i=1, 3 do
        local rwd = item:getChildByName("item" .. i)
        rwd:setVisible(false)

        local rwdData = taskData["award"][i]
        if rwdData then
            rwd:setVisible(true)

            local num = rwdData[3]
            local itemId
            if IconUtils.iconIdMap[rwdData[1]] then
                itemId = IconUtils.iconIdMap[rwdData[1]]
            else
                itemId = rwdData[2]
            end

            if rwd._rwd1 == nil then
                itemIcon = IconUtils:createItemIconById({itemId = itemId, num = num})
                itemIcon:setScale(0.7)
                itemIcon:setPosition(0, 0)
                itemIcon:setSwallowTouches(false)
                rwd._rwd1 = itemIcon
                rwd:addChild(itemIcon)
            else
                IconUtils:updateItemIconByView(rwd._rwd1, {itemId = itemId, num = num})
            end
        end
    end

    --richText
    if item.richText ~= nil then
        item.richText:removeFromParent(true)
        item.richText = nil
    end
    
    local taskDes = string.gsub(lang(taskData["des"]), "{$times}", taskData["condition"][1])
    local richText = RichTextFactory:create(taskDes, 600, 0)
    richText:formatText()
    richText:setPixelNewline(true)
    richText:setAnchorPoint(cc.p(0, 0.5))
    richText:setPosition(-271, item:getContentSize().height * 0.5 + 30)
    item.richText = richText
    item:addChild(richText)

    --btn
    local getBtn = item:getChildByName("getBtn")
    local getNum = item:getChildByName("getNum")
    local hasGet = item:getChildByName("hasGet")
    local goBtn = item:getChildByName("goBtn")
    getBtn:setVisible(false)
    getNum:setVisible(false)
    hasGet:setVisible(false)
    goBtn:setVisible(false)
    if cellData["status"] and cellData["status"] > 0 then
        hasGet:setVisible(true)
        
    elseif cellData["value"] >= taskData["condition"][1] then
        getBtn:setVisible(true)
        getNum:setVisible(true)

    else
        getNum:setVisible(true)
        goBtn:setVisible(true)
    end

    --进度
    local num = getNum:getChildByName("num")
    local num1 = ItemUtils.formatItemCount(tonumber(cellData["value"]))
    local num2 = ItemUtils.formatItemCount(tonumber(taskData["condition"][1]))
    num:setString(num1 .. "/" .. num2)
    if cellData["value"] >= taskData["condition"][1] then
        num:setColor(UIUtils.colorTable.ccUIBaseColor9)
    else 
        num:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
    end

    --getBtn
    self:registerClickEvent(getBtn, function()
        if self._countTime and self._countTime <= 0 then
            self._viewMgr:showTip("活动已结束")
            return
        end
        
        local curNum = self._recallModel:getAcData().dailyFriendScore or 0
        local limit = tab.setting["FRIEND_RETURN_MAXPOINTS_PERDAY"].value
        local function getReward()
            self._serverMgr:sendMsg("RecallServer", "getFriendActTaskReward", {taskId = cellData["taskId"]}, true, {}, function(result)
                self._recallModel:getAcReward(cellData["taskId"])
                DialogUtils.showGiftGet( {
                    gifts = result["reward"], 
                    callback = function() end
                ,notPop = true})
                end)
        end

        if curNum >= limit then  --超上限
            self._viewMgr:showDialog("global.GlobalSelectDialog",
            {   desc = lang("FRIEND_TEXT_TIPS_10"),
                button1 = "确定",
                button2 = "取消", 
                callback1 = function ()
                    getReward()
                end,
                callback2 = function()
                end})
        else
            getReward()
        end
        end)

    --goBtn
    self:registerClickEvent(goBtn, function()
        self:gotoBtnEvent(taskData["button"])
        end)

    return item
end

function AcFriendRecallTaskView:gotoBtnEvent(inType)
    if self._countTime and self._countTime <= 0 then
        self._viewMgr:showTip("活动已结束")
        return
    end

    local sysOpenName = {
        [1] = {"Stage", "intance.IntanceView"}, 
        [2] = {"Elite", "intance.IntanceEliteView"}, 
        [3] = {"Arena", "arena.ArenaView"},
        [4] = {"Crusade", "crusade.CrusadeView"},
        [5] = {"Guild", "guild.GuildView"},
        [6] = {"MF", "MF.MFView"},
        [7] = {"CloudCity", "cloudcity.CloudCityView"},
        [9] = {"Team", "team.TeamListView"},
        [10] = {"Hero", "hero.HeroView"},
        [11] = {"GuildMap", "guild.map.GuildMapView"},
        [12] = {"TeamSkill", "team.TeamListView"},
        }

    local function checkBySysOpen(inType)
        if sysOpenName[inType] then
            local temp = sysOpenName[inType]
            local sysOpen = tab.systemOpen[temp[1]]
            local curLvl = self._userModel:getData().lvl or 0
            if curLvl < sysOpen[1] then
                self._viewMgr:showTip(lang(sysOpen[3]))
                return
            end

            self._viewMgr:showView(temp[2])
        end
    end


    if inType == 8 then     --积分联赛
        local isOpen,openDes = LeagueUtils:isLeagueOpen()
         if isOpen then
            self._viewMgr:showView("league.LeagueView")
        else
            self._viewMgr:showTip(openDes)
        end

    elseif inType == 5 or inType == 11 then   --联盟
        local guildId = self._userModel:getData().guildId
        if guildId == nil or guildId == 0 then 
            self._viewMgr:showTip(lang("TIPS_RANK_02"))
            return
        end

        checkBySysOpen(inType)
    else
        checkBySysOpen(inType)
    end
end

function AcFriendRecallTaskView:setBtnState(inBtn)
    local btnName = {"经验福利", "战力提升", "联盟荣耀"}

    for i=1, 3 do
        local v = self:getUI("bg.bg1.leftPanel.tab" .. i)
        v:setBright(true)
        v:setEnabled(true)
        if v.title ~= nil then
            v.title:removeFromParent(true)
            v.title = nil
        end

        local btnTitle = ccui.Text:create()
        btnTitle:setFontName(UIUtils.ttfName)
        btnTitle:setFontSize(25)
        btnTitle:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        btnTitle:setPosition(v:getContentSize().width * 0.5 - 7, v:getContentSize().height * 0.5)
        btnTitle:setString(btnName[i])
        v.title = btnTitle
        v:addChild(btnTitle)
    end

    if inBtn then
        inBtn:setBright(false)
        inBtn:setEnabled(false)
        inBtn.title:setColor(UIUtils.colorTable.ccUIBaseColor1)
        inBtn.title:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
    end
end

function AcFriendRecallTaskView:setCountTime()
    if not self._data["friendAct"] or not self._data["friendAct"]["endTime"] then
        return
    end

    local countStr = self:getUI("bg.bg1.rightPanel.timer.tipLab")
    countStr:setFontSize(18)
    local countNum = self:getUI("bg.bg1.rightPanel.timer.timeLab")
    countNum:setFontSize(18)

    local curTime = self._userModel:getCurServerTime()
    local endTime = self._data["friendAct"]["endTime"] or 0

    local tempTime = endTime - curTime -- 85600
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

            self._countTime = tempTime
            if tempTime <= 0 then
                showTime = "00天00:00:00"
            end
            countNum:setString(showTime)
            countNum:setPositionX(countStr:getPositionX() + countStr:getContentSize().width + 3)
        end),cc.DelayTime:create(1))
    ))
end


return AcFriendRecallTaskView