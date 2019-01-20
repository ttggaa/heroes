--[[
    Filename:    MailBoxView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-03 10:15:26
    Description: File description
--]]

local MailBoxView = class("MailBoxView", BaseView)

function MailBoxView:ctor()
    MailBoxView.super.ctor(self)
    self.initAnimType = 3
end

function MailBoxView:onInit()
    self:addAnimBg()
    -- [[ 板子动画
    self._playAnimBg = self:getUI("bg.panelBg")
    self._playAnimBgOffX = 3
    self._playAnimBgOffY = -13
    --]]
    self:registerClickEventByName("bg.backBtn", function()
        self:close()
    end)

    self._mailModel = self._modelMgr:getModel("MailBoxModel")
    self._model = self._modelMgr:getModel("MailBoxModel"):getData() 

    self._listView = self:getUI("bg.listView")

    self._mailNode = self:getUI("bg.cell")
    self._mailNode:setVisible(false)
    self._none = self:getUI("bg.noneIcon") 
    self._mailNumLab = self:getUI("bg.mailNumBg.lab")

    local onekeyaward = self:getUI("bg.onekeyaward")
    self._onekeyaward = onekeyaward
    self:registerClickEvent(onekeyaward, function()
        local userLvl = self._modelMgr:getModel("UserModel"):getPlayerLevel()
        local limit = tab:Setting("MERU").value
        if userLvl < limit then
            self._viewMgr:showTip("一键领取邮件功能在35级开放")
            return
        end
        self:attachMent()
    end)

    local onekeyDel = self:getUI("bg.onekeyDel")
    self._onekeyDel = onekeyDel
    self:registerClickEvent(onekeyDel, function()
        self:deleteAllReadedMail()
    end)

    self:addTableView()

    self:reflashUI()
    self:listenReflash("MailBoxModel", self.reflashUI)
end

--[[
用tableview实现
--]]
function MailBoxView:addTableView()
    local tableViewBg = self:getUI("bg.listView")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView, 1)
    UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -4, 6)

    self._tableViewHeight = tableViewBg:getContentSize().height
end


function MailBoxView:readMail(idx)
    local tId = self._model[idx].tId
    if table.nums(self._model[idx].att) == 0 and self._model[idx].rea == 0 then
        self._serverMgr:sendMsg("MailServer", "readMail", {mailId=self._model[idx].mId}, true, {}, function(result)
            if tId == 31 then
                self._viewMgr:showDialog("godwar.GodWarInvitationDialog", self._model[idx], true)
            else
                self._viewMgr:showDialog("mailbox.MailBoxDialog", self._model[idx], true)
            end
            local model = self._modelMgr:getModel("MailBoxModel")
            if self._model[idx].type == 1 then   
                -- print("类型1无附件邮件")         
                local removeMailList = {}
                table.insert(removeMailList, self._model[idx])
                model:removeMailList(removeMailList)
            elseif self._model[idx].type == 2 then
                -- print("类型2无附件邮件")
                self._model[idx].rea = 1
                local saveMailList = {}
                table.insert(saveMailList, self._model[idx])
                model:setDataByMailList(saveMailList)
            end
        end)
    else
        -- print("不请求数据")
        self._viewMgr:showDialog("mailbox.MailBoxDialog", self._model[idx], true)
    end
end 

-- 触摸时调用
function MailBoxView:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function MailBoxView:cellSizeForTable(table,idx) 
    local width = 778 
    local height = 120
    return height, width
end

-- 创建在某个位置的cell
function MailBoxView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._model[idx+1]
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local mailNode = self._mailNode:clone() 
        
        mailNode:setAnchorPoint(cc.p(0,0))
        mailNode:setPosition(cc.p(1,5))
        mailNode:setName("mailNode1")
        cell:addChild(mailNode)

        local titleBg = mailNode:getChildByFullName("titleBg")
        titleBg:setOpacity(0)

        local titleLabel = mailNode:getChildByFullName("titleBg.title")
        -- UIUtils:setTitleFormat(titleLabel, 2, 1)
        -- -- titleLabel:setFontName(UIUtils.ttfName)
        -- titleLabel:setFontSize(28)
        -- titleLabel:setColor(cc.c3b(255,255,255))
        -- -- titleLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- titleLabel:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(2, -2))

        local lab = mailNode:getChildByFullName("append.lab")
        lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local dateLabel = mailNode:getChildByFullName("date")
        dateLabel:setFontName(UIUtils.ttfName)

        local addressLabel = mailNode:getChildByFullName("address")
        addressLabel:setFontName(UIUtils.ttfName)

        self:updateCell(mailNode, param, indexId)
        mailNode:setSwallowTouches(false)
    else
        local mailNode = cell:getChildByName("mailNode1")
        if mailNode then
            self:updateCell(mailNode, param, indexId)
            mailNode:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function MailBoxView:numberOfCellsInTableView(table)
    return #self._model 
end


function MailBoxView:createLoadingMc()
    if self._loadingMc then return end
    -- 添加加载中动画
    local tableViewBg = self:getUI("bg.listView")
    self._loadingMc = mcMgr:createViewMC("jiazaizhong_rankjiazaizhong", true, false, function (_, sender)      end)
    self._loadingMc:setPosition(cc.p(tableViewBg:getContentSize().width * 0.5 - 30, 330))
    tableViewBg:addChild(self._loadingMc, 0)
    self._loadingMc:setVisible(false)
end

function MailBoxView:scrollViewDidScroll(view)
    local offsetY = view:getContentOffset().y
    local minY = 0 - #self._model * 120 + self._tableViewHeight 
    local isDragging = view:isDragging()
    if isDragging then
        if offsetY < minY - 60 and not self._reRequest then
            self._reRequest = true
            self:createLoadingMc()
            self._loadingMc:setVisible(true)
        end
        if offsetY > minY - 30 and self._reRequest then
            self._reRequest = false
            self:createLoadingMc()
            self._loadingMc:setVisible(false)
        end
    else
        if self._reRequest and minY == offsetY then
            self._reRequest = false
            -- 请求
            self:createLoadingMc()
            self._loadingMc:setVisible(false)
            if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
                self:attain()
                self._updateMailTick = socket.gettime()
            end
            
        end
    end
    
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function MailBoxView:updateCell(mailNode, param, indexId)
        if not mailNode then
            return
        end
        local tId = 0

        -- if param.tId > table.nums(tab.mail) then
        if param.tId ~= 0 and (not tab.mail[param.tId]) then
            print("邮件配表错误， id= " .. param.tId, table.nums(tab.mail))
            param.tId = 0
            param.att = {}
            return
        end
        if param.tId ~= 0 then
            tId = tab:Mail(param.tId)
            param.til = lang(tId.title)
            param.ser = lang(tId.sender)
            -- print(param.til, param.ser)
        end
        mailNode:setVisible(true)
        local str = param.til or ""

        -- 限定标题字数
        str = utf8.limitLen(str, 20) -- self:limitLen(str, 20)
        local titleLabel = mailNode:getChildByFullName("titleBg.title")
        if titleLabel then
            titleLabel:setString(str)
        end
        
        str = TimeUtils.getDateString(param.st,"%Y-%m-%d")
        local dateLabel = mailNode:getChildByFullName("date")
        if dateLabel then
            dateLabel:setString(str)
        end

        str = "发件人:" .. param.ser
        local addressLabel = mailNode:getChildByFullName("address")
        if addressLabel then
            addressLabel:setString(str)
        end

        local noRead = mailNode:getChildByFullName("noRead")
        local read = mailNode:getChildByFullName("read")
        local append = mailNode:getChildByFullName("append")
        local cellBg = mailNode:getChildByFullName("cellBg")
        if table.nums(param.att) ~= 0 then
            if param.rec == 1 then
                noRead:setVisible(false)
                read:setVisible(true)
                cellBg:loadTexture("globalPanelUI7_cellBg2.png", 1)
                -- cellBg:setBrightness(-40)
                -- cellBg:setSaturation(-40)
                append:setVisible(false)
            else
                noRead:setVisible(true)
                read:setVisible(false)
                cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
                -- cellBg:setBrightness(0)
                append:setVisible(true)
            end
        else
            if param.rea == 1 then
                noRead:setVisible(false)
                read:setVisible(true)
                -- cellBg:setBrightness(-40)
                cellBg:loadTexture("globalPanelUI7_cellBg2.png", 1)
                append:setVisible(false)
            else
                noRead:setVisible(true)
                read:setVisible(false)
                -- cellBg:setBrightness(0)
                cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
                append:setVisible(false)
            end
        end

        local iconBg = mailNode:getChildByFullName("iconBg")
        
        local icon = mailNode:getChildByFullName("iconBg.icon")
        if param.tId ~= 0 then
            str = tId.icon .. ".png"
            if icon then
                icon:loadTexture(str, 1)
            end
            local level = tId.level or 1
            if level >= 1 and level <= 3 then
                level = tId.level or 1
            else
                level = 1
            end
            level = "youjian_bg" .. level .. ".png"
            if iconBg then
                iconBg:loadTexture(level, 1) 
            end
            local content = lang(tId.content)
            local have = string.find(content, "%b{}")
            if have then
                if string.find(param.con, "color=") == nil and param.con ~= "" then
                    local tempData = json.decode(param.con)
                    -- 处理模板数据
                    local ttid = tonumber(param.tId)
                    if ttid == 11 then
                        for k,v in pairs(tempData) do
                            if k == "$name1" then
                                content = self:split(content, k, v)
                            elseif k == "$name2" then
                                content = self:split(content, k, lang(v))
                            end
                        end
                    elseif ttid == 15 then
                        -- dump(tempData)
                        for k,v in pairs(tempData) do
                            local leagueRankDes = lang(tab:LeagueRank(v).name)
                            content = self:split(content, k, leagueRankDes)
                        end
                    elseif ttid == 17 then
                        content = self:split(content, "$sec", GameStatic.serverName .. "区")
                        for k,v in pairs(tempData) do
                            content = self:split(content, "$list", self:getSurpriseListName(v))
                        end
                    elseif ttid == 37 or ttid == 43 then
                        for k,v in pairs(tempData) do
                            if k == "$trainId" then
                                content = self:split(content, k, v-22)
                            else
                                content = self:split(content, k, v)
                            end
                        end
                    elseif ttid == 60 or ttid == 61 or ttid == 62 then
                        for k,v in pairs(tempData) do
                            if k == "$rank" then
                                content = self:split(content, k, v)
                            else
                                local cityName = lang(v)
                                content = self:split(content, k, cityName)
                            end
                        end
                    elseif ttid == 79 then
                        for k,v in pairs(tempData) do
                            if k == "$openRegion" then
                                local arenaName = lang("cp_nameRegion" .. v)
                                content = self:split(content, k, arenaName)
                            else
                                content = self:split(content, k, v)
                            end
                        end
                    elseif ttid == 93 then
                        for k,v in pairs(tempData) do
                            if k == "$team1" then
                                local name = lang(tab.guessTeam[v]["teamID"])
                                content = self:split(content, k, name)
                            elseif k == "$team2" then
                                local name = lang(tab.guessTeam[v]["teamID"])
                                content = self:split(content, k, name)
                            else
                                content = self:split(content, k, v)
                            end
                        end
                    else
                        for k,v in pairs(tempData) do
                            content = self:split(content, k, v)
                        end
                    end
                    param.con = content
                end 
            else
                param.con = content
            end

        else
            str = "youjian_1.png"
            if icon then
                icon:loadTexture(str, 1)   
            end
            local level = "youjian_bg1.png"
            if iconBg then
                iconBg:loadTexture(level, 1) 
            end
        end

        local downY, clickFlag
        registerTouchEvent(
            mailNode,
            function (_, _, y)
                downY = y
                clickFlag = false
                
            end, 
            function (_, _, y)
                if downY and math.abs(downY - y) > 5 then
                    clickFlag = true
                end
            end, 
            function ()
                if clickFlag == false then 
                    self:readMail(indexId)
                end
            end,
            function ()
        end)
end

function MailBoxView:reflashUI()
    self._model = self._modelMgr:getModel("MailBoxModel"):getData()
    -- dump(self._model,"modeldata")
    local mailBg = self:getUI("bg.panelBg.Image_22")
    if #self._model == 0 then
        self._listView:setVisible(false)
        self._none:setVisible(true)
        local userLvl = self._modelMgr:getModel("UserModel"):getPlayerLevel()
        local limit = 32
        if userLvl < limit then
            self._onekeyaward:setVisible(false)
            self._onekeyDel:setVisible(false)
        else
            self._onekeyaward:setVisible(true)
            self._onekeyDel:setVisible(true)
        end
        -- print("邮件为空")
    else
        self._none:setVisible(false)
        self._listView:setVisible(true)
        local userLvl = self._modelMgr:getModel("UserModel"):getPlayerLevel()
        local limit = 32
        if userLvl < limit then
            self._onekeyaward:setVisible(false)
            self._onekeyDel:setVisible(false)
        else
            self._onekeyaward:setVisible(true)
            self._onekeyDel:setVisible(true)
        end
    end
    local count = self:getNoReadMail()
    self._mailNumLab:setString(count .. "/" .. table.nums(self._model))
    if self._mailModel:getNewMail() ~= 0 then
        self:attain()
    end

    self._tableView:reloadData()
end

-- function MailBoxView:setNavigation()
--     self._viewMgr:showNavigation("global.UserInfoView", {hideBtn = false})
-- end

-- 每日小惊喜
function MailBoxView:getSurpriseListName(surprise)
    if not surprise then
        return
    end
    local name = {"火", "水", "气", "土"}
    -- surprise = 1433
    local a = tostring(surprise)
    local str = ""
    for i = 1, #a do
        str = str .. name[tonumber(string.sub(a, i, i))]
    end
    return str 
end


function MailBoxView:split(str,param,reps)
    if str == "" then
        return str
    end
    local des = string.gsub(str,"{" .. param .. "}",reps)
    return des 
end

function MailBoxView:getParam(str)
    if str == "" then
        return str
    end
    local i,j = string.find(str, "%b{}")
    if i == nil or j == nil then
        return str
    end
    local des = string.sub(str, i, j)
    return string.gsub(string.gsub(des,"%$", ""),"[{}]","") 
end

function MailBoxView:getRank(str)
    if str == "" then
        return ""
    end
    local i = string.find(str, ":")
    local des
    if i then
        des = string.sub(str, i+1)
    else
        des = str
    end
    return des
end

function MailBoxView:getAsyncRes()
    return 
    {
        {"asset/ui/mailBoxView.plist", "asset/ui/mailBoxView.png"},
        {"asset/ui/mailBoxView1.plist", "asset/ui/mailBoxView1.png"}
    }
end

function MailBoxView:getBgName()
    return "bg_007.jpg"
end

--取邮件
function MailBoxView:attain()
    self._serverMgr:sendMsg("MailServer", "getMails", {lastUpTime=0}, true, {}, function(result)
        self._mailModel:setNewMail()
        self:reflashUI()
    end)
end

function MailBoxView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    if self._mailModel:getNewMail() ~= 0 then
        self:getMails()
    else
        self._onBeforeAddCallback(1)
    end
end

function MailBoxView:getMails()
    self._serverMgr:sendMsg("MailServer", "getMails", {lastUpTime=0}, true, {}, function(result)
        self._mailModel:setNewMail()
        self:getMailsFinish(result)
    end)
end

function MailBoxView:getMailsFinish(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:reflashUI()
end

function MailBoxView:limitLen(str, maxNum)
    local lenInByte = #str
    local lenNum = 0
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            lenNum = lenNum + 1
        elseif curByte>=192 and curByte<=247 then
            lenNum = lenNum + 3
            maxNum = maxNum + 1
        end
        if lenNum >= maxNum then
            break
        end
    end
    str = string.sub(str, 1, lenNum)
    return str
end

function MailBoxView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function MailBoxView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Physcal","Gold","Gem"},title = "globalTitleUI_shopEmail.png",titleTxt = "邮件"})
end


--取附件
function MailBoxView:attachMent()
    local mailList = {}
    self._removeMailList = {}
    self._saveMailList = {}
    local count = 0
    for k,v in pairs(self._model) do
        if table.nums(v.att) ~= 0 and v.rec == 0 then
            if v.type == 1 then 
                table.insert(self._removeMailList, v)
            elseif v.type == 2 then
                table.insert(self._saveMailList, v)
            end
            table.insert(mailList, v.mId)
            count = count + 1
            if count >= 50 then
                break
            end
        end
    end
    if count < 1 then
        self._viewMgr:showTip("暂无可领取的邮件")
        return
    end
    -- dump(mailList, "count=======" .. count, 2)
    self._serverMgr:sendMsg("MailServer", "getAttachment", {mailId=mailList}, true, {}, function(result)
        self:attachMentFinish(result)
    end, function(errorId)
        local errorId = tonumber(errorId)
        if errorId == 702 then
            for k,v in pairs(self._saveMailList) do
                v.rec = 1
            end
            self._mailModel:setDataByMailList(self._saveMailList)
        elseif errorId == 704 then
            self._viewMgr:showTip("该邮件不可领取")
        end
    end)
end

function MailBoxView:getNoReadMail()
    local count = 0
    for k,v in pairs(self._model) do
        if v.att and table.nums(v.att) ~= 0 and v.rec == 0 then
            count = count + 1
        elseif v.att and table.nums(v.att) == 0 and v.rea == 0 then
            count = count + 1
        elseif (not v.att) and v.rea == 0 then
            count = count + 1
        end
    end
    return count
end

function MailBoxView:attachMentFinish(result)
    if not result then
        return
    end
    -- dump(result, "rstu==========", 5)
    for k,v in pairs(self._saveMailList) do
        v.rec = 1
    end
    self._mailModel:removeMailList(self._removeMailList)
    self._mailModel:setDataByMailList(self._saveMailList)
    -- 奖励展示
    local reward = result.reward
    local notChange = false
    for k,v in pairs(reward) do
        if v[1] == "avatarFrame" or v["type"] == "avatarFrame" 
            or v[1] == "avatar" or v["type"] == "avatar" then
            notChange = true
        end
    end
    -- 只有一个头像或者头像框需要特殊展示 hgf
    if notChange and table.nums(reward) == 1 then
        DialogUtils.showAvatarFrameGet( {gifts = reward}) 
    else
        DialogUtils.showGiftGet( {gifts = reward})
    end
    self._removeMailList = nil
    self._saveMailList = nil
end

function MailBoxView:deleteAllReadedMail()
    local readNum = self._mailModel:deleteReadedMail()
    if readNum <= 0 then
        self._viewMgr:showTip(lang("MAILBOX_TIPS1"))
        return
    end

    local function reqDeleteMail()
        self._serverMgr:sendMsg("MailServer", "delUsedMail", {}, true, {}, function(result)
            self._mailModel:setNewMail()
            self:reflashUI()
            end)
    end
  
    self._viewMgr:showDialog("global.GlobalSelectDialog",
        {   desc = lang("MAILBOX_TIPS2"),
            button1 = "确定",
            button2 = "取消", 
            callback1 = function ()
                reqDeleteMail()
            end,
            callback2 = function()
            end})
end

return MailBoxView