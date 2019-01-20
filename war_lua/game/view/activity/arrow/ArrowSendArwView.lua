--[[
    Filename:    ArrowSendArwView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-1-09 22:19:00
    Description: 射箭送箭界面
--]]

local ArrowSendArwView = class("ArrowSendArwView", BasePopView)

function ArrowSendArwView:ctor(param)
	ArrowSendArwView.super.ctor(self)
    self._arrowModel = self._modelMgr:getModel("ArrowModel")
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --随机种子

    self._callback = param.callback
    self._callback2 = param.callback2
end

function ArrowSendArwView:onInit()
	local title = self:getUI("bg.title")
	UIUtils:setTitleFormat(title, 1)

    local Label_64 = self:getUI("bg.Image_55.Image_550.Label_64")
    Label_64:setString(lang("ARROW1"))

    self._cellItem = self:getUI("itemCell")
    self._cellItem:setVisible(false)

    self:refreshUI()
    self:createSendedView()
    self:createSendView()

    self:registerClickEventByName("bg.closeBtn", function()
        if self._callback then
            self._callback()
        end
        self:close()
        -- UIUtils:reloadLuaFile("activity.arrow.ArrowSendArwView")
        end)

    self:registerClickEventByName("bg.ranSendBtn", function()
        --无可赠送玩家
        if #self._sendData == 0 then
            self._viewMgr:showTip(lang("ARROW6"))
            return
        end

        --玩家都已被赠送
        local isCanSend = false
        for i,v in ipairs(self._sendData) do
            if tab.setting["ARROW_ADD"].value - v["gNum"] > 0 then
                isCanSend = true
                break
            end
        end
        if isCanSend == false then
            self._viewMgr:showTip(lang("ARROW9"))
            return
        end

        --赠送次数上限
        local curSend = self._modelMgr:getModel("PlayerTodayModel"):getData().day40
        if tab.setting["ARROW_GIVE"].value - curSend <= 0 then
            self._viewMgr:showTip("今日赠送次数已达上限")
            return
        end

        local randomNum = math.random(1, #self._sendData)
        self._serverMgr:sendMsg("ArrowServer", "sendArrow", {sType = 1, targetId = self._sendData[randomNum]["memberId"]}, true, {}, function (result)
            -- dump(result, "sed")
            self:refreshUI()
            self._viewMgr:showTip(string.gsub(lang("ARROW5"), "{$name}", " "..self._sendData[randomNum]["name"].." "))
            if self._callback2 then
                self._callback2()
            end
            end)
        end)
    
end

function ArrowSendArwView:refreshUI()
    self._data = self._arrowModel:getData()
    self._sendedData = self._data["eventList"]
    self._sendData = self._data["memberList"]
    -- dump(self._sendData, "send")

    local nothing = self:getUI("bg.nothing")
    if #self._sendedData ~= 0 then
        nothing:setVisible(false)
    else
        nothing:setVisible(true)
    end

    local nothing1 = self:getUI("bg.nothing1")
    if #self._sendData ~= 0 then
        nothing1:setVisible(false)
    else
        nothing1:setVisible(true)
    end

    local sendedNum = self:getUI("bg.sendedNum")
    sendedNum:setString("剩余领取次数：" .. tab.setting["ARROW_ADD"].value - #self._sendedData)

    local sendNum = self:getUI("bg.sendNum")
    local curSend = self._modelMgr:getModel("PlayerTodayModel"):getData().day40
    sendNum:setString("剩余赠送次数：" .. tab.setting["ARROW_GIVE"].value - curSend)

end

function ArrowSendArwView:createSendedView()
    self._viewMgr:lock(-1)

    local sendedBg = self:getUI("bg.sendedBg") 
    local tableView = cc.TableView:create(cc.size(sendedBg:getContentSize().width - 20, sendedBg:getContentSize().height - 26))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(13, 13))
    tableView:setDelegate()
    tableView:setBounceable(true) 
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable_sended(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex_sended(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView_sended(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    sendedBg:addChild(tableView)
    if tableView.setDragSlideable ~= nil then 
        tableView:setDragSlideable(true)
    end

    tableView:reloadData()
    self._viewMgr:unlock()
end

function ArrowSendArwView:cellSizeForTable_sended(table,idx)
    local sendedBg = self:getUI("bg.sendedBg") 
    return 35, 260 
end

function ArrowSendArwView:tableCellAtIndex_sended(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
        cell = cc.TableViewCell:create()
    end

    local name = cell:getChildByFullName("name")
    if name == nil then
        name = ccui.Text:create()
        name:setFontName(UIUtils.ttfName)
        name:setColor(UIUtils.colorTable.ccUIBaseColor1)
        name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        name:setAnchorPoint(cc.p(0, 0.5))
        name:setPosition(0, 17)
        name:setFontSize(20)
        name:setName("name")
        cell:addChild(name)
    end
    name:setString(self._sendedData[idx + 1])

    local lab = cell:getChildByFullName("lab")
    if lab == nil then
        lab = ccui.Text:create()
        lab:setFontName(UIUtils.ttfName)
        lab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        lab:setAnchorPoint(cc.p(0, 0.5))
        lab:setFontSize(20)
        lab:setString("送你1支箭")
        lab:setName("lab")
        cell:addChild(lab)
    end
    lab:setPosition(name:getPositionX()+name:getContentSize().width+5, 17)
    
    return cell
end

function ArrowSendArwView:numberOfCellsInTableView_sended(table)
    return math.min(#self._sendedData, 6)
end

function ArrowSendArwView:createSendView()
    self._viewMgr:lock(-1)

    local sendBg = self:getUI("bg.sendBg") 
    local tableView = cc.TableView:create(cc.size(sendBg:getContentSize().width - 18, sendBg:getContentSize().height - 18))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(9, 9))
    tableView:setDelegate()
    tableView:setBounceable(true) 
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll_send(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable_send(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex_send(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView_send(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    sendBg:addChild(tableView)
    if tableView.setDragSlideable ~= nil then 
        tableView:setDragSlideable(true)
    end
    UIUtils:ccScrollViewAddScrollBar(tableView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), 0, 6)
    
    ScheduleMgr:delayCall(200, self, function ()
        tableView:reloadData()
        self._viewMgr:unlock()
        end)
end

function ArrowSendArwView:scrollViewDidScroll_send(view)
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function ArrowSendArwView:cellSizeForTable_send(table,idx)
    return 102, 432
end

function ArrowSendArwView:tableCellAtIndex_send(table, idx)
    local curData = self._sendData[idx + 1]
    local cell = table:dequeueCell()
    if cell == nil then
        cell = cc.TableViewCell:create()
    end

    --item
    local item = cell:getChildByFullName("item")
    if item == nil then
        item = self._cellItem:clone()
        item:setVisible(true)
        item:setTouchEnabled(true)
        item:setSwallowTouches(false)
        item:setPosition(cc.p(-3,0))
        item:setAnchorPoint(cc.p(0,0))
        item:setName("item")
        cell:addChild(item)
    end

    --avatar
    local headIcon = item:getChildByName("avatar")
    local headP = {avatar = curData["avatar"], level = curData["lvl"] or "0", tp = 4,avatarFrame=curData["avatarFrame"], tencetTp = curData["qqVip"], plvl = curData["plvl"]}
    if headIcon == nil then
        headIcon = IconUtils:createHeadIconById(headP) 
        headIcon:setAnchorPoint(0, 0.5)
        headIcon:setPosition(19, item:getContentSize().height*0.5)
        headIcon:setScale(0.7)
        headIcon:setName("avatar")
        item:addChild(headIcon, 2)
    else
        IconUtils:updateHeadIconByView(headIcon,headP) 
    end

    --name
    local name = item:getChildByFullName("name")
    name:setPositionY(67)
    name:setString(curData["name"])

    --tequan
    local tequan = item:getChildByFullName("tequan")
    local tequanImg = IconUtils.tencentIcon[curData["tequan"]] or "globalImageUI6_meiyoutu.png"
    if tequan == nil then
        local tequanIcon = ccui.ImageView:create(tequanImg, 1)
        tequanIcon:setScale(0.8)
        tequanIcon:setPosition(cc.p(145, 37))
        item:addChild(tequanIcon)
    else
        tequanIcon:loadTexture(tequanImg, 1)
    end

    --star
    local star = item:getChildByFullName("star")
    if curData["follow"] == 0 then --未关注
        star:loadTexture("arrow_starOff.png", 1)
        registerClickEvent(star, function()
            self._serverMgr:sendMsg("ArrowServer", "arrowFollow", {targetId = curData["memberId"]}, true, {}, function (result) 
                self._arrowModel:followFriend(curData["memberId"], 1)
                self:refreshUI()
                table:reloadData()
                end)
            end)
    else
        star:loadTexture("arrow_starOn.png", 1)
        registerClickEvent(star, function()
            self._serverMgr:sendMsg("ArrowServer", "arrowCancleFollow", {targetId = curData["memberId"]}, true, {}, function (result) 
                self._arrowModel:followFriend(curData["memberId"], 0)
                self:refreshUI()
                table:reloadData()
                end)
            end)
    end

    --lab
    local labDes = item:getChildByFullName("sendArw.lab")
    labDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    --sendBtn
    local sendBtn = item:getChildByFullName("sendArw")
    sendBtn:setVisible(false)
    registerClickEvent(sendBtn, function()
        local curSend = self._modelMgr:getModel("PlayerTodayModel"):getData().day40
        if tab.setting["ARROW_GIVE"].value - curSend <= 0 then
            self._viewMgr:showTip(lang("ARROW8"))  --自己上限
            return
        end

        if tab.setting["ARROW_ADD"].value - curData["gNum"] <= 0 then
            self._viewMgr:showTip(lang("ARROW4"))  --对方上限
            return
        end
        self._serverMgr:sendMsg("ArrowServer", "sendArrow", {sType = 2, targetId = curData["memberId"]}, true, {}, 
            function (result)
                -- dump(result, "sed")
                self._arrowModel:sendArrow(curData["memberId"])
                self._viewMgr:showTip(lang("ARROW3"))
                table:updateCellAtIndex(idx)
                self:refreshUI()
                if self._callback2 then
                    self._callback2()
                end
            end,
            function(errorId)
                if tonumber(errorId) == 3824 then
                    self._viewMgr:showTip("赠送失败，"..lang("ARROW4"))
                    self._arrowModel:sendArrow(curData["memberId"], tab.setting["ARROW_ADD"].value)
                    table:updateCellAtIndex(idx)
                end
            end)
        end)

    --upperImg
    local upperImg = item:getChildByFullName("upperImg")
    upperImg:setVisible(false)

    if tab.setting["ARROW_ADD"].value - curData["gNum"] <= 0 then  --对方上限
        upperImg:setVisible(true)
    else
        sendBtn:setVisible(true)
    end

    return cell
end

function ArrowSendArwView:numberOfCellsInTableView_send(table)
    return #self._sendData
end


return ArrowSendArwView