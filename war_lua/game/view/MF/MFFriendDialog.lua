--[[
    Filename:    MFFriendDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-09-26 20:14:10
    Description: File description
--]]

-- 航海好友弹窗

local MFFriendDialog = class("MFFriendDialog", BasePopView)

function MFFriendDialog:ctor(param)
    MFFriendDialog.super.ctor(self)
    self._index = 1
    self._tableData = {}
    self._callback = param.callback
    self._checkTipCallback = param.checkTipCallback
end

-- 初始化UI后会调用, 有需要请覆盖
function MFFriendDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFFriendDialog")
        end
        self:closeSelfDialog()
    end)

    self._nothinglab = self:getUI("bg.nothing.lab")
    self._addFriend = self:getUI("bg.nothing.addFriend")
    self._addFriend:setVisible(false)
    self:registerClickEvent(self._addFriend, function()
        self:closeSelfDialog()
        ViewManager:getInstance():showView("friend.FriendView", {openType = "apply"})
    end)

    self._addAlliance = self:getUI("bg.nothing.addAlliance")
    self._addAlliance:setVisible(false)
    self:registerClickEvent(self._addAlliance, function()
        self:closeSelfDialog()
        ViewManager:getInstance():showView("guild.join.GuildInView", {})
    end)

    self._logCell = self:getUI("logCell")
    self._logCell:setVisible(false)

    -- self._tabEventTarget = {}
    -- for i=1,2 do
    --     local tab = self:getUI("bg.tab" .. i)
    --     tab:setScaleAnim(false)
    --     -- self:registerClickEvent(tab, function(sender) self:tabButtonClick(sender, i) end)
    --     UIUtils:setTabChangeAnimEnable(tab,140,function(sender) self:tabButtonClick(sender, i) end)
    --     table.insert(self._tabEventTarget, tab)
    -- end
    local tab1 = self:getUI("bg.tab1")
    local tab2 = self:getUI("bg.tab2")
    self._btnList = {}
    table.insert(self._btnList, tab1)
    table.insert(self._btnList, tab2) 
    for k,v in pairs(self._btnList) do
        v:setTitleFontName(UIUtils.ttfName)
        -- v:setTitleFontSize(32)
    end


    UIUtils:setTabChangeAnimEnable(tab1,140,handler(self, self.tabButtonClick))
    UIUtils:setTabChangeAnimEnable(tab2,140,handler(self, self.tabButtonClick))

    local nothing = self:getUI("bg.nothing")
    nothing:setVisible(false)
    self:addTableView()
    self:getUI("bg.tab1")._appearSelect = true
    self:tabButtonClick(self:getUI("bg.tab1"), 1, false)

    -- local isGuildOpen = self._modelMgr:getModel("UserModel"):getIdGuildOpen()
    -- if isGuildOpen == false then
    --     for i=1,2 do
    --         local tab = self:getUI("bg.tab" .. i)
    --         tab:setVisible(false)
    --     end
    -- end
end


function MFFriendDialog:tabButtonClick(sender, key, infirst)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
   for k,v in pairs(self._btnList) do
        if v ~= sender then 
            local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
            v:setScaleAnim(false)
            v:stopAllActions()
            v:setBright(true)
            v:setEnabled(true)
        end
    end
    if self._preBtn then 
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender 
    UIUtils:tabChangeAnim(sender,function( )
        local text = sender:getTitleRenderer()
        text:disableEffect()
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        sender:setBright(false)
        sender:setEnabled(false)
        if sender:getName() == "tab1" then
            self._index = 1 
            self._addAlliance:setVisible(false)
            self._addFriend:setVisible(true)
            self._nothinglab:setString("你还没有好友，快去添加吧！")
            if not self._friendList then
                self:getMFFriendList()
            else
                self._tableData = clone(self._friendList)
                self._tableView:reloadData()

                local nothing = self:getUI("bg.nothing")
                if table.nums(self._tableData) ~= 0 then
                    nothing:setVisible(false)
                else
                    nothing:setVisible(true)
                end
            end

        elseif sender:getName() == "tab2" then 
            print("升级")
            self._index = 2
            self._addAlliance:setVisible(false)
            self._addFriend:setVisible(false)
            local isGuildOpen = self._modelMgr:getModel("UserModel"):getIdGuildOpen()
            if isGuildOpen == false then
                self._addAlliance:setVisible(true)
                self._nothinglab:setString("你还未加入联盟，快去添加吧！")
                -- self:tabButtonClick(self:getUI("bg.tab1"), false)
                -- self._viewMgr:showTip("你还未加入联盟")
                self._tableData = {}
                self._tableView:reloadData()
                local nothing = self:getUI("bg.nothing")
                nothing:setVisible(true)
            else
                if not self._allianceList then
                    self:getMFAllianceList()
                else
                    self._tableData = self._allianceList
                    self._tableView:reloadData()

                    local nothing = self:getUI("bg.nothing")
                    if table.nums(self._tableData) ~= 0 then
                        nothing:setVisible(false)
                    else
                        nothing:setVisible(true)
                    end
                end
            end
        end
    end)
end

function MFFriendDialog:getMFFriendList()
    self._serverMgr:sendMsg("GameFriendServer", "getMFList", {}, true, {}, function(result) 
        self._modelMgr:getModel("MFModel"):setMFFriendData(result)
        self._friendList = self:progressFriend(result)
        self._tableData = self._friendList
        -- dump(self._tableData)
        self._tableView:reloadData()

        local nothing = self:getUI("bg.nothing")
        if table.nums(self._tableData) ~= 0 then
            nothing:setVisible(false)
        else
            nothing:setVisible(true)
        end
    end)
end

function MFFriendDialog:getMFAllianceList()
    self._serverMgr:sendMsg("GuildServer", "getMFList", {}, true, {}, function(result) 
        self._modelMgr:getModel("MFModel"):updateGuildData(result)
        self._allianceList = self:progressAlliance(result)
        self._tableData = self._allianceList
        -- dump(self._tableData)
        self._tableView:reloadData()

        local nothing = self:getUI("bg.nothing")
        if table.nums(self._tableData) ~= 0 then
            nothing:setVisible(false)
        else
            nothing:setVisible(true)
        end
    end)
end

-- 处理联盟列表
function MFFriendDialog:progressAlliance(allianceData)
    local myuserid = self._modelMgr:getModel("UserModel"):getData().usid
    local tempData = {}
    for k,v in pairs(allianceData) do
        v.mfHelp = v.mf
        if v.usid ~= myuserid and v.lvl >= 39 then
            table.insert(tempData, v)
        end
    end
    local sortFunc = function(a, b)
        amfHelp = a.mfHelp
        bmfHelp = b.mfHelp
        ausid = a.usid
        busid = b.usid 
        if amfHelp ~= bmfHelp then
            return amfHelp > bmfHelp
        else
            return ausid < busid
        end
    end
    table.sort(tempData, sortFunc)
    return tempData
end

-- 处理好友列表
function MFFriendDialog:progressFriend(friendData)
    local tempFriend = clone(self._modelMgr:getModel("FriendModel"):getDataByType("friend"))
    local tempFriend1 = {}
    for k,v in pairs(tempFriend) do
        local tfData = friendData[v._id]
        if tfData then
            v.mfHelp = tfData["mf"]
            v.hideVip = tfData["hideVip"]
            v._lt = tfData["_lt"]
            v.leaveTime = tfData["leaveTime"]
            if v.lvl >= 39 then
                table.insert(tempFriend1, v)
            end
        end
    end

    local sortFunc = function(a, b)
        amfHelp = a.mfHelp
        bmfHelp = b.mfHelp
        ausid = a.usid
        busid = b.usid 
        if (not amfHelp) or (not bmfHelp) then
            return
        end
        if amfHelp ~= bmfHelp then
            return amfHelp > bmfHelp
        else
            return ausid < busid
        end
    end
    table.sort(tempFriend1, sortFunc)
    return tempFriend1
end

-- 接收自定义消息
function MFFriendDialog:reflashUI()
    local bg = self:getUI("bg")
    bg:setVisible(true)

    -- local helpTimes1 = self:getUI("bg.helpTimes1")
    -- local helpTimes2 = self:getUI("bg.helpTimes2")
    -- local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    -- helpTimes2:setString(tab:Setting("G_MF_HELP_NUM").value-playerTimesData["day26"])
    -- helpTimes2:enableOutline(cc.c4b(60,30,10,255), 1)
    -- helpTimes2:setPositionX(helpTimes1:getPositionX()+helpTimes1:getContentSize().width+3)

    local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    for i=1,5 do
        local helptime = self:getUI("bg.helptimeBg.helptime" .. i)
        if helptime then
            if i <= (tab:Setting("G_MF_HELP_NUM").value-playerTimesData["day26"]) then
                helptime:loadTexture("mf_helpTimes1.png", 1)
            else
                helptime:loadTexture("mf_helpTimes2.png", 1)
            end
        end
    end

    -- helpTimes2:setString("帮助" .. playerTimesData["day26"] .. "被抢夺" .. playerTimesData["day27"] .. "抢夺" .. playerTimesData["day28"] .. "匹配" .. playerTimesData["day29"])

    -- if self._selType == "team" then
    --     for i=1,2 do
    --         local tab = self:getUI("bg.tab" .. i)
    --         if tab then
    --             tab:setVisible(true)
    --         end
    --     end
    -- else
    --     -- 隐藏标签
    --     for i=1,2 do
    --         local tab = self:getUI("bg.tab" .. i)
    --         if tab then
    --             tab:setVisible(false)
    --         end
    --     end
    --     self._title:setString("选择英雄")
    --     local heroData = self._modelMgr:getModel("MFModel"):getMFHeroData()
    --     self._tableData = clone(heroData)
    --     for k,v in pairs(self._tableData) do
    --         if v.heroId == tonumber(self._heros) then
    --             v["selectMf"] = 1
    --         end
    --     end
    -- end
    -- -- dump(self._tableData)

    -- self._tableView:reloadData()
    -- self:updateConditionDes()
    
end


--[[
用tableview实现
--]]
function MFFriendDialog:addTableView()
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
    -- self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function MFFriendDialog:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

-- cell的尺寸大小
function MFFriendDialog:cellSizeForTable(table,idx) 
    local width = 572
    local height = 115
    return height, width
end

-- 创建在某个位置的cell
function MFFriendDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._tableData[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local logCell = self._logCell:clone() 
        logCell:setVisible(true)
        logCell:setAnchorPoint(cc.p(0,0))
        logCell:setPosition(cc.p(0,0)) --0
        logCell:setName("logCell")
        cell:addChild(logCell)

        local name = logCell:getChildByFullName("name")
        name:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

        local level = logCell:getChildByFullName("level")

        local qihang = logCell:getChildByFullName("qihang")
        UIUtils:addFuncBtnName(qihang, "起航", nil, true)

        local lab = logCell:getChildByFullName("qihang.lab")
        lab:setVisible(false)
        -- name:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- lab:setFontName(UIUtils.ttfName)
        local des1 = logCell:getChildByFullName("des1")
        des1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local des2 = logCell:getChildByFullName("des2")
        des2:setColor(UIUtils.colorTable.ccUIBaseColor9)
        -- des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local des3 = logCell:getChildByFullName("des3")
        des3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- des3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        self:updateCell(logCell, param, indexId)
        -- logCell:setSwallowTouches(false)
    else
        print("wo shi shua xin")
        local logCell = cell:getChildByName("logCell")
        if logCell then
            self:updateCell(logCell, param, indexId)
            -- logCell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function MFFriendDialog:numberOfCellsInTableView(table)
    return self:cellLineNum() -- 
end

function MFFriendDialog:cellLineNum()
    return table.nums(self._tableData) 
end

function MFFriendDialog:updateCell(inView, data, indexId)
    if data == nil then
        return
    end
    -- dump(data,"data ====================")
    local iconBg = inView:getChildByFullName("iconBg")
    if iconBg then
        local param1 = {avatar = data.avatar, tp = 4,avatarFrame = data["avatarFrame"]}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setScale(0.9)
            icon:setName("icon")
            icon:setPosition(cc.p(-3, -4))
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local name = inView:getChildByFullName("name")
    if name then
        name:setString(data.name)
    end


    local level = inView:getChildByFullName("level")
    local tempLevl = level
    if level then
        local inParam = {lvlStr = "Lv." .. data.lvl, lvl = data.lvl, plvl = data.plvl}
        tempLevl = UIUtils:adjustLevelShow(level, inParam, 1)
    end

    local vipIcon = inView:getChildByFullName("vipIcon")
    vipIcon:setVisible(true)
    -- dump(data,"hidevip 隐藏vip=============")
    local isHideVip = UIUtils:isHideVip(data.hideVip,self._index == 1 and "friend" or "guild")
    if data.vipLvl > 0 and not isHideVip then
        vipIcon:setVisible(true)  
        vipIcon:loadTexture(("chatPri_vipLv"..math.max(1, data.vipLvl )..".png"), 1)
    else
        -- 增加 vip0标签 by guojun 2017.3.23
        vipIcon:setVisible(false)
        -- vipIcon:loadTexture(("chatPri_vipLv0.png"), 1)
    end
    vipIcon:setPositionX(tempLevl:getPositionX() + tempLevl:getContentSize().width + 25)

    local des1 = inView:getChildByFullName("des1")
    local des2 = inView:getChildByFullName("des2")
    local des3 = inView:getChildByFullName("des3")
    if data.mfHelp == 1 then
        if des1 then
            des1:setVisible(true)
            local str = GuildUtils:getDisTodayTime(data._lt)
            des1:setString(str)
            -- des1:setString(GuildUtils:getDisTodayTime(data.leaveTime))
        end
        if des2 then
            des2:setVisible(true)
            des2:setString("可帮助")
        end
        if des3 then
            des3:setVisible(false)
        end
    else
        if des1 then
            des1:setVisible(false)
        end
        if des2 then
            des2:setVisible(false)
        end
        if des3 then
            des3:setVisible(true)
            local str = GuildUtils:getDisTodayTime(data._lt)
            des3:setString(str)
        end
    end

    -- local applyTime = inView:getChildByFullName("applyTime")
    -- if applyTime then
    --     applyTime:setString(GuildUtils:getDisTodayTime(data.applyTime))
    -- end

    local qihang = inView:getChildByFullName("qihang")
    if qihang then
        if data.lvl < 39 then
            qihang:setSaturation(-100)
            self:registerClickEvent(qihang, function()
                self._viewMgr:showTip("该玩家未开启岛屿！")
            end)
        else
            qihang:setSaturation(0)
            self:registerClickEvent(qihang, function()
                print("+触发+++++++++++++++++++++++++", data._id)
                self:getGameFriendMFInfo(data)
            end)
        end
    end
end

function MFFriendDialog:tempText(data)
    for k,v in pairs(data:getChildren()) do
        print("tempFun1 ===", k, v, v:getName())
        self:tempText(v)
    end
end

function MFFriendDialog:getGameFriendMFInfo(data)
    self._serverMgr:sendMsg("MFServer", "getGameFriendMFInfo", {fid = data._id}, true, {}, function(result) 
        -- dump(result, "result===", 10)
        if self._index == 1 then
            self._modelMgr:getModel("MFModel"):updateMFFriendData(data._id)
        else
            self._modelMgr:getModel("MFModel"):updateMFGuildData(data._id)
        end
        local beijing = self.parentView:getChildByName("beijing")
        if beijing then
            beijing:removeFromParent()
        end

        local beijing = mcMgr:createViewMC("yunqiehuan_mfqiehuanyun", false, true)
        beijing:setName("beijing")
        beijing:setAnchorPoint(cc.p(0.5,0.5))
        beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5,MAX_SCREEN_HEIGHT*0.5))
        self.parentView:addChild(beijing)

        local bg = self:getUI("bg")
        bg:setVisible(false)
        if self.parentView.setMaskLayerOpacity then
            self.parentView:setMaskLayerOpacity(0)
        end
        if result then
            result.userid = data._id
            result.userdata = data
        end
        if self.parentView:getClassName() == "MF.MFFriendView" then
            beijing:addCallbackAtFrame(15, function(_, sender)
                -- if self.parentView.__maskLayer.setVisible then
                --     self.parentView.__maskLayer:setOpacity(0)
                --     self.parentView.__maskLayer:setVisible(true)
                -- end
                if self._callback then
                    self._callback(result)
                    self:closeSelfDialog()
                end
            end)
        else
            -- if self.parentView.__maskLayer.setVisible then
            --     self.parentView.__maskLayer:setOpacity(0)
            --     self.parentView.__maskLayer:setVisible(true)
            -- end
            beijing:addCallbackAtFrame(15, function(_, sender)
                ViewManager:getInstance():showView("MF.MFFriendView", result)
                self:closeSelfDialog()
            end)
        end
    end)
end

function MFFriendDialog:closeSelfDialog()
    if self.close then
        self:close()
    end
    if self._checkTipCallback then
        self._checkTipCallback()
    end
end

return MFFriendDialog