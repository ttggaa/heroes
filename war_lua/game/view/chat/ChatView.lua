--[[
    Filename:    ChatView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-30 18:08:29
    Description: File description
--]]

local ChatView = class("ChatView", BasePopView)

function ChatView:ctor(data)
    ChatView.super.ctor(self)
    self._chatModel = self._modelMgr:getModel("ChatModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._enterType = data.enterType
    self._closeCallback = data.closeCallback
    require("game.view.chat.ChatConst")
end

function ChatView:getMaskOpacity( ... )
    return 130
end

function ChatView:onInit()
    if ADOPT_IPHONEX then
        if self._enterType == "guild" then
            self._widget:setPositionX(125)
        else
            self._widget:setPositionX(50)
        end
    end
    self._chatModel:setIsChatViewOpen(true)

    self._cacheRich = {}
    self._woldLastTime = 0
    self._curChannelSize = 0
    self._unreadCount = 0

    self._isShowDataFin = false

    local bg2 = self:getUI("bg1.bg2")
    bg2.noSound = true
    self:registerClickEvent(bg2, function()
            self:hideEmojiView()
        end) 


    self._lockScrollBtn = self:getUI("bg1.bg2.bg_1.Image_13.lockScrollBtn")

    self._unreadBg = self:getUI("bg1.bg2.bg_1.unreadImg")
    self._unreadBg:setPositionY(self._unreadBg:getPositionY()-4)
    self._unreadBg:setVisible(false)
    self:registerClickEvent(self._unreadBg, function(sender) 
        self:unreadBgClickFunc()
        end)
    self._unreadLab = self:getUI("bg1.bg2.bg_1.unreadImg.unreadLab")

    --频道状态提示
    self._channelTip = self:getUI("bg1.bg2.bg_1.channelTip")
    self._channelTip:setString(lang("CHAT_SYSTEM_BAN"))

    --输入框  文本初始化
    self._chatBoxBg = self:getUI("bg1.bg2.bg_1.chatBg")
    self._contextTextField = self:getUI("bg1.bg2.bg_1.chatBg.chagBg1.contextTextField")
    self._contextTextField:setTouchEnabled(false)
    self._contextTextField.rectifyPos = true
    self._contextTextField.openCustom = true
    self._contextTextField.maxLengTip = lang("CHAT_SYSTEM_LENTH_TIP")
    self._contextTextField:setPlaceHolder(lang("CHAT_SYSTEM_LENTH"))
    self._contextTextField:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._contextTextField:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)

    self._contextTextField.handleLen = function(sender, param)
        local temp = string.gsub(param,"(<[^>]+>)$", "")
        if temp ~= param then 
            param = temp
            sender:setString(param)
        else
            sender:setString(utf8.sub(param, 1 , (sender:getMaxLength() - 1)))
        end
        return true
    end
    self:registerClickEvent(self._chatBoxBg, function ()
        self._contextTextField:attachWithIME()
    end)

    --语音voiceBtn
    local panelBg = self:getUI("bg1.bg2.bg_1")
    self._voiceBtn = require("game.view.chat.ChatVoiceNode").new()
    self._voiceBtn:setPosition(130, 52)
    panelBg:addChild(self._voiceBtn)

    local posT = self._voiceBtn:convertToWorldSpace(cc.p(0, 0))
    self._voiceBtn:onInit({pos = posT})

    -- 表情
    self._emojiBtn = self:getUI("bg1.bg2.bg_1.emojiBtn")
    self:registerClickEvent(self._emojiBtn, function ()
        if self._emojiNode == nil then 
            local panelBg = self:getUI("bg1.bg2.bg_1")
            self._emojiNode = self:createLayer("chat.ChatEmojiNode", {callback = function(value)
                self._contextTextField:setString(self._contextTextField:getString() .. value)
            end})
            self._emojiNode:setPosition(12 + 125, 110 - 20)
            panelBg:addChild(self._emojiNode, 10)
            self._emojiNode:showView(true)
            return
        end
        if self._emojiNode:isVisible() then
            self._emojiNode:hideView()
        else
            self._emojiNode:showView(true)
        end
    end)
    
    --发送按钮
    self._sendBtn = self:getUI("bg1.bg2.bg_1.sendBtn")
    self:registerClickEvent(self._sendBtn, function()
        self:sendMessage()
    end)

    --私聊
    self._priBtn = self:getUI("bg1.bg2.bg_1.priBtn") 
    self._priBtn:getChildByFullName("redPoint"):setVisible(false)
    local priTabLab = self._priBtn:getChildByFullName("labTitle")
    priTabLab:setFontName(UIUtils.ttfName)
    priTabLab:setColor(cc.c3b(255,255,255))
    priTabLab:enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
    priTabLab:setFontSize(22)
    self:registerClickEvent(self._priBtn, function()
            if self._viewMgr ~= nil then
                local isPriOpen, tipDes = self._chatModel:isPirChatOpen()
                if isPriOpen == false then
                    self._viewMgr:showTip(tipDes)
                    return
                end
                self._viewMgr:showDialog("chat.ChatPrivateView", {oldUI = self, viewtType = "pri", isHasLoadAsy = true}, true) 
            end
        end) 

    --callBtn
    self._callBtn = self:getUI("bg1.bg2.bg_1.callBtn") 
    self._callBtn:getChildByFullName("redPoint"):setVisible(false)
    local priTabLab = self._callBtn:getChildByFullName("labTitle")
    priTabLab:setFontName(UIUtils.ttfName)
    priTabLab:setColor(cc.c3b(255,255,255))
    priTabLab:enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
    priTabLab:setFontSize(22)
    self:registerClickEvent(self._callBtn, function()
        self:callBtnFunc()
        end)

    local callNode = self:getUI("bg1.bg2.callNode", {}, true)  
    callNode:setVisible(false)
    self:getUI("bg1.bg2.callNode.name"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self:createScreenListenLayer()
    
    --页签按钮
    self:addBtnFunc()

    --model监听
    self:setListenReflashWithParam(true)
    self:listenReflash("ChatModel", self.updateCurChannel)
    self:refreshBtnRedPoint() 

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            if self._cacheRich ~= nil then 
                for k,v in pairs(self._cacheRich) do
                    v:release()
                end
            end
        elseif eventType == "enter" then 
            self:onEnter(self._enterType)
        end
    end)
    registerClickEvent(self._widget, function()
        self._chatModel:setIsChatViewOpen(false)
        self:closeView()
    end)
end

--打开UI
function ChatView:reflashUI(data)
    local bg2 = self:getUI("bg1.bg2")
    bg2:setPosition(bg2:getPositionX() - bg2:getContentSize().width + 105, bg2:getPositionY())
    bg2:runAction(
        cc.Sequence:create(
        cc.MoveTo:create(0.1, cc.p(bg2:getPositionX() + bg2:getContentSize().width - 105, bg2:getPositionY())),
        cc.CallFunc:create(function() 
            local btn
            local isOpen = self._modelMgr:getModel("CrossGodWarModel"):matchIsOpen()
            if self._enterType and self._enterType == "guild" then
                btn = self:getUI("bg1.bg2.bg_1.guildBtn")
            elseif self._enterType and self._enterType == "godWar" and isOpen and isOpen == 0 then
                btn = self:getUI("bg1.bg2.bg_1.cgodwarBtn")
            else
                btn = self:getUI("bg1.bg2.bg_1.allBtn")
            end
            -- ScheduleMgr:delayCall(0, self, function ()
                self:tabButtonClick(btn)
            -- end)
        end)))

    local closeBtn = self:getUI("bg1.bg2.closeBtn")
    registerClickEvent(closeBtn, function()
        self._chatModel:setIsChatViewOpen(false)
        self:closeView()
    end)
end

--关闭UI
function ChatView:closeView()
    UIUtils:reloadLuaFile("chat.ChatView")
    UIUtils:reloadLuaFile("chat.ChatCommonCell")
    UIUtils:reloadLuaFile("chat.ChatGuildCell")
    UIUtils:reloadLuaFile("chat.ChatPrivateView")
    UIUtils:reloadLuaFile("chat.ChatPrivateChatCell")
    UIUtils:reloadLuaFile("chat.ChatPrivateUserCell")
    UIUtils:reloadLuaFile("chat.ChatGodWarCell")
    UIUtils:reloadLuaFile("chat.ChatReportInfoNode")
    UIUtils:reloadLuaFile("chat.ChatFullServerCell")

    if self._closeCallback then
        self._closeCallback()
    end
    self._modelMgr:getModel("ChatModel"):setApplyRecord()   --清空需审批的联盟申请记录
    self._chatModel:setCurrChannel()
	
    self._viewMgr:lock(-1)
    local bg2 = self:getUI("bg1.bg2")
    if self._emojiNode ~= nil then 
        self._emojiNode:removeFromParent()
    end
    bg2:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(0.1, cc.p(bg2:getPositionX() - bg2:getContentSize().width - 150, bg2:getPositionY())),
                    cc.CallFunc:create(function()
                        ScheduleMgr:delayCall(0, self, function ()
                            if self._viewMgr ~= nil then
                                self._viewMgr:unlock()
                                self:close(false)
                            end
                        end)
                        
                    end)
                ))
end

--进入界面默认世界模块
function ChatView:onEnter(enterType)
    self._enterType = enterType
end

function ChatView:tabButtonClick(sender)
    self._isShowDataFin = false
    self:hideEmojiView()

    if sender == nil then 
        return 
    end
      
    if self._curChannel == sender._type then  
        return
    end

    -- lock 
    self._viewMgr:lock(-1)

    --获取频道名
    self._curChannel = sender._type
    self._chatModel:setCurrChannel(self._curChannel)
    if self._voiceBtn then
        self._voiceBtn._curType = self._curChannel
    end

    self:setBtnState(sender)
    self:channelLimitCheck()
    self:refreshCurUI(sender)

    --获取频道model数据
    self._showData = clone(self._chatModel:getDataByType(self._curChannel))
    -- dump(self._showData, "showdata")
    -- 释放cache的富文本    
    for k,v in pairs(self._cacheRich) do
        v:release()
    end
    self._cacheRich = {}

    --初始化tableview 创建cell
    local tableBg = self:getUI("bg1.bg2.bg_1.scrollBg")
    if self._tableView ~= nil then 
        self._tableView:removeFromParent()
        self._tableView = nil
    end
    
    local tableW, tableH = tableBg:getContentSize().width, tableBg:getContentSize().height
    self._listBgHeight = tableH
    self._tableView = cc.TableView:create(cc.size(tableW, tableH))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:setDelegate()
    self._tableView:setBounceable(true) 
    self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    tableBg:addChild(self._tableView)
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end

    --请求数据
    ScheduleMgr:delayCall(0, self, function ()
        -- 如果数据数量不满足最大要求，请求服务器看是否有未读取数据
        if not self._chatModel:getIsLoadDataByChannel(self._curChannel) then
            self._viewMgr:unlock()
            self:getMessage(self._curChannel)
            return
        end

        self._curChannelSize = #self._showData
        self._tableView:reloadData()

        if self._tableView:getContentSize().height >  self._listBgHeight then 
            self._tableView:setContentOffset(cc.p(0, 0))
        end
        self._isShowDataFin = true
        self._viewMgr:unlock()
    end)
end

--刷新当前频道cell  移除多余
function ChatView:updateCurChannel(data)
    self._unlockRecord = self._lockScrollBtn:isSelected()  --用于记录推送之前聊天锁屏状态
    if self["listenModelBy" .. (data or "")] then
        self["listenModelBy" .. (data or "")](self)
        return
    end

    if data ~= self._curChannel or data == "priUnread" then 
        self:refreshBtnRedPoint()
        return
    end

    self:updateCommonTableData()
    local tableBg = self:getUI("bg1.bg2.bg_1.scrollBg")
    local listBgHeight = tableBg:getContentSize().height
    -- 移除多余条数
    local tableOffset = self._tableView:getContentOffset()
    if tableOffset.y >= 0 then 
        if #self._showData > ChatConst.CHAT_MSG_MAX_LEN then 
            for i = #self._showData, ChatConst.CHAT_MSG_MAX_LEN + 1, -1 do
                local removeId = self._showData[i].id
                table.remove(self._showData)
                self._chatModel:removeDataByChannel(self._curChannel, i)
                self._tableView:removeCellAtIndex(i-1)
                if self._cacheRich[removeId] ~= nil then 
                    self._cacheRich[removeId]:release()
                    self._cacheRich[removeId] = nil
                end
            end

            if self._tableView:getContentSize().height <=  listBgHeight then 
                self._tableView:reloadData()
            end
        end
        self._curChannelSize = #self._showData
    end
end

function ChatView:listenModelByCallChat()
    local callNode = self:getUI("bg1.bg2.callNode")
    callNode:stopAllActions()

    local callData = self._chatModel:getCallChatData()
    local message = callData.message
    local udata = callData.message.udata

    local sendT = callData.t
    local curT = self._userModel:getCurServerTime()
    local dalayT = tonumber(tab.setting["CHAT_SHOWTIME"].value)
    local disT = math.max(0 , dalayT - (curT - sendT))
    if disT <= 0 then
       callNode:setVisible(false)
       return
    end

    callNode:setVisible(true)
    callNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(disT), 
        cc.CallFunc:create(function()
            callNode:stopAllActions()
            callNode:setVisible(false)
            end)
        ))

    local name = callNode:getChildByName("name")
    name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    name:setString(udata.name or "")

    local vip = callNode:getChildByName("vipImg")
    if udata.vipLvl > 0  then
        vip:loadTexture("chatPri_vipLv" .. udata.vipLvl ..".png", 1)
        vip:setPositionX(name:getPositionX() + name:getContentSize().width + 22)
    else
        vip:setVisible(false)
    end

    local serverName = self._modelMgr:getModel("LeagueModel"):getServerName(udata.sec)
    local sec = callNode:getChildByName("sec")
    sec:setString(serverName or "")
    sec:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    if vip:isVisible() then
        sec:setPositionX(vip:getPositionX() + vip:getContentSize().width * 0.5 + 5)
    else
        sec:setPositionX(name:getPositionX() + name:getContentSize().width + 5)
    end
    

    local txt = callNode:getChildByName("txt")
    txt:setString(message.text or "")
end

function ChatView:listenModelByBlackRemove()
    local btn
    local isOpen = self._modelMgr:getModel("CrossGodWarModel"):matchIsOpen()
    if self._enterType and self._enterType == "guild" then
        btn = self:getUI("bg1.bg2.bg_1.guildBtn")
    elseif self._enterType and self._enterType == "godWar" and isOpen and isOpen == 0 then
        btn = self:getUI("bg1.bg2.bg_1.cgodwarBtn")
    else
        btn = self:getUI("bg1.bg2.bg_1.allBtn")
    end
    self._curChannel = ""
    self:tabButtonClick(btn)
end
 
--获取最新的频道model数据
function ChatView:updateCommonTableData()
    local unlock = false
    local tempY = self._tableView:getContentOffset().y - 85
    local tempData = self._chatModel:getDataByType(self._curChannel)

    if self._curChannelSize < #tempData then 
        for i=#tempData - self._curChannelSize - 1, 0, -1 do
            local tempData1 = tempData[i+1]
            local currID = tempData1.message.udata.rid
            if not (self._curChannel == ChatConst.CHAT_CHANNEL.SYS or
                (self._curChannel == ChatConst.CHAT_CHANNEL.GUILD and tempData1.typeCell == ChatConst.CELL_TYPE.GUILD2)) then
                -- 如果我本人发送消息则解除锁屏
                if self._userModel:getData()._id == currID then 
                    unlock = true
                end
            end
            table.insert(self._showData, 1, clone(tempData1))
            self._tableView:insertCellAtIndex(0)

            local cellMsg = tempData1.message
            if not unlock and cellMsg.typeCell == ChatConst.CELL_TYPE.FSERVER3 and cellMsg.callId == self._userModel:getData()._id then
                self._chatModel:setConnectUserList(tempData1)
            end
        end
    end

    self._unreadCount = self._unreadCount + #self._showData - self._curChannelSize
    self._curChannelSize = #self._showData

    if not self._lockScrollBtn:isSelected() or unlock == true or not self._unlockRecord then    --未解锁/自己/push消息之前是未解锁
        self._unreadBg:setVisible(false)
        if self._tableView:getContentSize().height >  self._listBgHeight then 
            self._tableView:setContentOffset(cc.p(0, 0))
        end

        if self._infoNode then
            self._infoNode:removeFromParent(true)
            self._infoNode = nil
        end
    else
        local connectList = self._chatModel:getConnectUserList()
        dump(connectList, "connectList")
        if self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER and next(connectList) ~= nil then
            self._unreadLab:setString("有人@你")
        else
            self._unreadLab:setString("未读消息（" .. self._unreadCount .. "条）")
        end
        self._unreadBg:setVisible(true)
    end
end

--聊天发送按钮点击事件
--toID:私聊发送对象ID
function ChatView:sendMessage()
    self:hideEmojiView()
    
    local sendStr = self._contextTextField:getString()
    if string.len(sendStr) == 0 or string.gsub(sendStr, " ", "") == "" then 
        self._viewMgr:showTip("发送内容不能为空")
        local cacheY = self._tableView:getContentOffset().y
        self._tableView:reloadData()
        self._tableView:setContentOffset(cc.p(0, cacheY), false)
        return
    end

    local sendType, sendParam = self:handleSendStrByType(sendStr)
    local isTimeBanned, isInfoBanned, sendData = self._chatModel:paramHandle(sendType, sendParam)  --时间和消息刷屏禁言
    local isMsgBanned = self._chatModel:isChatMsgBanned() --是否服务器已禁言
    local isIdipBanned, banStr = self._chatModel:isChatIdipBanned()  --idip禁言
    -- dump(sendData,"123", 10)
    
    if isIdipBanned == true and self._curChannel == ChatConst.CHAT_CHANNEL.WORLD then
        self._viewMgr:showTip(banStr)
        return
    end

    if isTimeBanned == true then
        self._viewMgr:showTip(lang("CHAT_SYSTEM_LAG"))
        return
    end

    if isInfoBanned == true then
        if self._curChannel == ChatConst.CHAT_CHANNEL.WORLD then
            if isMsgBanned == false then
                self._serverMgr:sendMsg("ChatServer", "banUserChat", {}, true, {}, function (result) 
                    self._chatModel:pushData(sendData)
                    end)
            else
                self._chatModel:pushData(sendData)
            end
            self:sendMessageFinish()
        end
        return
    end

    self._serverMgr:sendMsg("ChatServer", "sendMessage", sendData, true, {}, function (result)
            self:sendMessageFinish()
        end,
        function(errorId, errorMsg)
            if errorId == 140 then   --人工禁言
                self._viewMgr:showTip(errorMsg)
            end
        end)
end

function ChatView:handleSendStrByType(sendStr)
    local sendType, sendParam = self._curChannel, {text = sendStr}

    if self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER then
        local tempName = nil
        if self._clickUser and self._clickUser["name"] then
            tempName = "【@" .. self._clickUser["name"] .. "】"
        end

        local isFind1 = string.find(sendStr, "[%【%】]")
        local isFind2 = tempName and string.find(sendStr, tempName)
        if isFind1 and isFind2 then  --匹配方法有漏洞
            sendType = ChatConst.CELL_TYPE.FSERVER3
            sendParam = {text = sendStr, callId = self._clickUser["rid"]}
        else
            self._clickUser = nil
        end
    end

    return sendType, sendParam
end

function ChatView:sendMessageFinish(result)
    if self._contextTextField then 
        self._contextTextField:setString("") 
    end
    self._clickUser = nil
end

--向服务器请求最新数据
function ChatView:getMessage(inType)
    local param = {type = inType}
    self._serverMgr:sendMsg("ChatServer", "getMessage", param, true, {}, function (result)
        if self.getMessageFinish ~= nil then
            self:getMessageFinish(result)
        end
    end)
end
function ChatView:getMessageFinish(result)
    local chatData = clone(self._chatModel:getDataByType(self._curChannel))
    self._viewMgr:lock(-1)
    self._chatModel:setLoadDataByChannel(self._curChannel)
    
    --插入获取数据之前已有的聊天记录
    if next(chatData) ~= nil then
        for k,v in pairs(chatData) do
            if v["isManual"] and v["isManual"] == true then
                table.insert(result, v)
            end
        end
    end
    self._chatModel:updatDataByType(self._curChannel, result)
    -- 更新展示数据
    self._showData = clone(self._chatModel:getDataByType(self._curChannel))
    self._curChannelSize = #self._showData
    -- dump(self._showData, "chatGet", 10)

    self._tableView:reloadData()
    if self._tableView:getContentSize().height >  self._listBgHeight then 
        self._tableView:setContentOffset(cc.p(0, 0))
    end
    self._isShowDataFin = true
    self._viewMgr:unlock()
end

--重置表情view
function ChatView:hideEmojiView( ... )
    if self._emojiNode ~= nil then
        self._emojiNode:hideView(false)
        self._emojiNode = nil
    end
end

--tableview监听 滚动条监听
function ChatView:scrollViewDidScroll(view)
    local tableOffset = view:getContentOffset()
    if tableOffset.y < 0 then 
        self._lockScrollBtn:setSelected(true)
    else
        self._unreadCount = 0
        if self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER then  --全服红点
            self._chatModel:clearConnectUserList()
        else
            self._chatModel:setUnread(0, self._curChannel)
        end
        self._unreadBg:setVisible(false)
        self._lockScrollBtn:setSelected(false)
    end
end

--tableview监听 ChatView
function ChatView:cellSizeForTable(table,idx)
    local chatData = self._showData[idx + 1]
    if self._curChannel == ChatConst.CHAT_CHANNEL.SYS or
        (chatData.type == ChatConst.CHAT_CHANNEL.GUILD and chatData.typeCell == ChatConst.CELL_TYPE.GUILD2) then
        local data, height = self:getChatContentRich(self._showData[idx + 1], 310) --400
        return 10 + height , 517
    else
        local data, height = self:getChatContentRich(self._showData[idx + 1], 213) --260

        local disHT = 0
        if self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER then
            local isAddT = self._chatModel:checkIsShowTime(self._showData[idx + 1])
            if isAddT then
                disHT = 15
            end
        end

        if height > 22 then 
            return 90 + disHT + height - 22, 517
        else
            return 90 + disHT, 517
        end
    end 
end

--创建聊天信息富文本  id不能重复且必须为数组类型，id还要用来排序
function ChatView:getChatContentRich(data, width)
    if width == nil then 
        width = 230
    end
    local backRich = self._cacheRich[data.id]
    if backRich ~= nil then 
        return backRich, backRich:getRealSize().height
    end
    if data.message == nil then 
        data.message = {}
    end
    if data.message.text == nil then 
        data.message.text = ""
    end
    
    local richText = RichTextFactory:create(data.message.text, width, 0)
    richText:setPixelNewline(true)
    richText:formatText()
    self._cacheRich[data.id] = richText
    richText:retain()
    richText:setName("text")
    richText.showId = data.id
    return richText, richText:getRealSize().height
end

--tableview监听 创建在某个位置的cell
function ChatView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local chatData = self._showData[idx + 1]

    if self._curChannel == ChatConst.CHAT_CHANNEL.SYS then     --系統
        return self:createSysChannelList(cell, chatData, idx)

    elseif self._curChannel == ChatConst.CHAT_CHANNEL.WORLD then   --世界
        return self:createWorldChannelList(cell, chatData, idx)
        
    elseif self._curChannel == ChatConst.CHAT_CHANNEL.GUILD then    --联盟
        return self:createGuildChannelList(cell, chatData, idx)

    elseif self._curChannel == ChatConst.CHAT_CHANNEL.GODWAR then    --诸神跨服
        return self:createGodWarChannelList(cell, chatData, idx)

    elseif self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER then    --诸神跨服
        return self:createFServerChannelList(cell, chatData, idx)
    end
end

--tableview监听 返回cell的数量
function ChatView:numberOfCellsInTableView(table)
    return #self._showData
end

--tableview监听
function ChatView:tableCellWillRecycle(table, cell)
    if cell.richText ~= nil then 
        cell.richText:removeFromParent()
        cell.richText = nil
    end
end

--创建系统频道列表
function ChatView:createSysChannelList(cell, chatData, idx)
    local richText , height = self:getChatContentRich(chatData, 300)
    if nil == cell then
        cell = require("game.view.chat.ChatSysCell"):new()
    end
    cell:reflashUI(chatData, richText, 517, height + 10)
    return cell
end

--创建世界频道列表
function ChatView:createWorldChannelList(cell, chatData, idx)  
    local richText , height = self:getChatContentRich(chatData, 213)
    local cellHeight = 90
    if height > 22 then 
        cellHeight = 90 + height - 22
    end
    if nil == cell then
        cell = require("game.view.chat.ChatCommonCell"):new()
    end
    local isMyself = false
    if self._userModel:getData()._id == chatData.message.udata.rid then 
        isMyself = true
    end
    cell:reflashUI(chatData, richText, 517, cellHeight, isMyself, self)
    return cell

end

--创建联盟频道列表
function ChatView:createGuildChannelList(cell, chatData, idx)
    if chatData.typeCell and chatData.typeCell == ChatConst.CELL_TYPE.GUILD2 then   --系统消息
        local richText , height = self:getChatContentRich(chatData, 300)
        if nil == cell then
            cell = require("game.view.chat.ChatGuildCell"):new()
        end
        cell:reflashUI(chatData, richText, 517, height + 10)

    else
        local richText , height = self:getChatContentRich(chatData, 213)
        local cellHeight = 90
        if height > 22 then 
            cellHeight = 90 + height - 22
        end
        if nil == cell then
            cell = require("game.view.chat.ChatGuildCell"):new()
        end

        local isMyself = false
        if self._userModel:getData()._id == chatData.message.udata.rid then 
            isMyself = true
        end
        cell:reflashUI(chatData, richText, 517, cellHeight, isMyself, self)
    end

    return cell
end

function ChatView:createGodWarChannelList(cell, chatData, idx)
    local richText , height = self:getChatContentRich(chatData, 213)
    local cellHeight = 90
    if height > 22 then 
        cellHeight = 90 + height - 22
    end
    if nil == cell then
        cell = require("game.view.chat.ChatGodWarCell"):new()
    end
    local isMyself = false
    if self._userModel:getData()._id == chatData.message.udata.rid then 
        isMyself = true
    end
    cell:reflashUI(chatData, richText, 517, cellHeight, isMyself, self)
    return cell
end

function ChatView:createFServerChannelList(cell, chatData, idx)
    local richText , height = self:getChatContentRich(chatData, 213)
    local isAddT = self._chatModel:checkIsShowTime(chatData)
    local disHT = isAddT and 15 or 0
    local cellHeight = 90 + disHT
    if height > 22 then
        cellHeight = 90 + disHT + height - 22
    end
    if nil == cell then
        cell = require("game.view.chat.ChatFullServerCell"):new()
    end
    local isMyself = false
    if self._userModel:getData()._id == chatData.message.udata.rid then 
        isMyself = true
    end
    cell:reflashUI(chatData, richText, 517, cellHeight, isMyself, self, function(inData)
        self:cellAvatarClickFunc(inData)
        end)
    return cell
end

function ChatView:cellAvatarClickFunc(inData)
    local uData = inData.message.udata
    self._clickUser = uData
    self._contextTextField:setString("【@" .. (uData.name or "") .. "】")
end

function ChatView:addBtnFunc()
    self._tabBtns = {}
    local btnNames = {"sysBtn", "allBtn", "guildBtn", "fSerBtn", "cgodwarBtn"}
    local btnTypes = {"SYS", "WORLD", "GUILD", "FSERVER", "GODWAR"}

    for i,v in ipairs(btnNames) do
        local btn = self:getUI("bg1.bg2.bg_1." .. v)
        btn:setPositionX(64)
        btn:setScaleAnim(false)
        btn._type = ChatConst.CHAT_CHANNEL[btnTypes[i]]

        self:registerClickEvent(btn, function(sender) self:tabButtonClick(sender) end)
        table.insert(self._tabBtns, btn)
    end

    --联盟按钮位置调整
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId 
    if guildId == nil or guildId <= 0 then 
        local pos3 = self._tabBtns[3]:getPositionY()
        local pos4 = self._tabBtns[4]:getPositionY()
        self._tabBtns[3]:setVisible(false)
        self._tabBtns[4]:setPositionY(pos3)
        self._tabBtns[5]:setPositionY(pos4)
    end

    --全服按钮
    local isOpen = SystemUtils["enableWeChat"]()
    if not isOpen or not GameStatic.is_show_chatFSer then
        self._tabBtns[4]:setVisible(false)
        local pos4 = self._tabBtns[4]:getPositionY()
        self._tabBtns[5]:setPositionY(pos4)
    end

    --诸神按钮位置调整
    local isOpen = self._modelMgr:getModel("CrossGodWarModel"):matchIsOpen()
    if isOpen and isOpen ~= 0 then
        self._tabBtns[5]:setVisible(false)
    end

    self:setBtnState()
end

function ChatView:setBtnState(inBtn)
    if self._tabBtns == nil or next(self._tabBtns) == nil then
        return
    end

    for k,v in ipairs(self._tabBtns) do
        v:setBright(true)
        v:setEnabled(true)
        if v.title ~= nil then
            v.title:removeFromParent(true)
            v.title = nil
        end

        local btnTitles = {"系统", "世界", "联盟", "跨服", "诸神"}
        local btnTitle = ccui.Text:create()
        btnTitle:setFontName(UIUtils.ttfName)
        btnTitle:setFontSize(25)
        btnTitle:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        btnTitle:setPosition(v:getContentSize().width * 0.5 - 7, v:getContentSize().height * 0.5)
        btnTitle:setString(btnTitles[k])
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

function ChatView:refreshBtnRedPoint()
    --pri
    local unreadList = self._chatModel:getPriUnread()
    if next(unreadList) ~= nil then
        self._priBtn:getChildByFullName("redPoint"):setVisible(true)
    else
        self._priBtn:getChildByFullName("redPoint"):setVisible(false)
    end

    --chat
    local btnNames = {"allBtn", "guildBtn", "fSerBtn", "cgodwarBtn"}
    for i,v in ipairs(btnNames) do
        local btn = self:getUI("bg1.bg2.bg_1." .. v)
        local btnRed = self:getUI("bg1.bg2.bg_1." .. v .. ".redPoint")
        if self._chatModel:getUnread(btn._type) > 0 then
            btnRed:setVisible(true)
        else
            btnRed:setVisible(false)
        end
    end
end

--频道开启等级判断  UI初始化
function ChatView:channelLimitCheck()
    local limitType = "Chat"
    if self._curChannel == ChatConst.CHAT_CHANNEL.GODWAR then
        limitType = "CrossGodWar"
    elseif self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER then
        limitType = "WeChat"
    end
    local limitLevel = tonumber(tab.systemOpen[limitType][1])

    if self._userModel:getData().lvl < limitLevel or self._curChannel == ChatConst.CHAT_CHANNEL.SYS then 
        local tipDes = ""
        if self._curChannel == ChatConst.CHAT_CHANNEL.SYS then   --系统
            tipDes = lang("CHAT_SYSTEM_BAN")
        else
            tipDes = string.gsub(lang("CHAT_SYSTEM_OPEN2"), "{$num}", limitLevel)
        end
        self._channelTip:setString(tipDes)
        self._channelTip:setVisible(true)

        self._sendBtn:setVisible(false)
        self._emojiBtn:setVisible(false)
        self._chatBoxBg:setVisible(false)
        self._voiceBtn:setVisible(false)
    else
        self._channelTip:setVisible(false)
        self._sendBtn:setVisible(true)
        self._emojiBtn:setVisible(true)
        self._chatBoxBg:setVisible(true)
        self._voiceBtn:setVisible(true)
    end   
end

function ChatView:refreshCurUI(sender)
    local redPoint = sender:getChildByName("redPoint")
    if redPoint then
        redPoint:setVisible(false)
    end

    local callNode = self:getUI("bg1.bg2.callNode")
    callNode:setVisible(false)
    local callData = self._chatModel:getCallChatData()
    if self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER then
        if next(callData) ~= nil then
            local sendT = callData.t
            local curT = self._userModel:getCurServerTime()
            local dalayT = tonumber(tab.setting["CHAT_SHOWCOST"].value)

            if curT - sendT > dalayT then
                self._chatModel:clearCallChatData()
            else
                callNode:setVisible(true)
                self:listenModelByCallChat()
            end
        end        
    end

    local callBtn = self:getUI("bg1.bg2.bg_1.callBtn")
    callBtn:setVisible(false)
    if self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER then
        callBtn:setVisible(true)
    end
end

function ChatView:unreadBgClickFunc()
    if not (self._tableView ~= nil and self._tableView:getContentSize().height >  self._listBgHeight) then
        return
    end

    if self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER and self._unreadLab:getString() == "有人@你" then
        local callData = self._chatModel:getConnectUserList()[1]
        local maxY = 0
        local isHas = false
        for i,v in ipairs(self._showData) do
            local richText, height = self:getChatContentRich(v, 213)
            local isAddT = self._chatModel:checkIsShowTime(v)
            local disHT = isAddT and 15 or 0
            local cellHeight = 90 + disHT
            if height > 22 then 
                cellHeight = 90 + disHT + height - 22
            end
            maxY = maxY + cellHeight

            if callData.id == v.id then
                isHas = true
                break
            end
        end

        if not isHas then
            self._viewMgr:showTip("消息已失效")
            self._tableView:setContentOffset(cc.p(0, 0))
            return
        end

        local disY = maxY - self._listBgHeight
        if disY > 0 then
            self._tableView:setContentOffset(cc.p(0, -disY))
        else
            self._tableView:setContentOffset(cc.p(0, 0))
        end
    else
        self._tableView:setContentOffset(cc.p(0, 0))
    end
end

function ChatView:callBtnFunc()
    local curLv = self._userModel:getData().lvl
    local curVip = self._modelMgr:getModel("VipModel"):getLevel()
    local limit = tab.setting["CHAT_SHOWPMS"].value
    if curLv < limit[1] or curVip < limit[2]  then
        self._viewMgr:showTip(lang("CHAT_SHOWBAN"))
        return
    end

    self._viewMgr:showDialog("chat.ChatCallView", {})
end

function ChatView:detachKeyBoard()
	if self._contextTextField then
		self._contextTextField:detachWithIME()
	end
end

function ChatView:createScreenListenLayer()
    if not self._clipLayer then
        self._clipLayer = ccui.Layout:create()
        self._clipLayer:setBackGroundColorOpacity(0)
        self._clipLayer:setBackGroundColorType(1)
        self._clipLayer:setBackGroundColor(cc.c3b(100, 100, 0))
        self._clipLayer:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
        self._clipLayer:setPosition(0, 0)
        self._clipLayer:setSwallowTouches(false)
        self:addChild(self._clipLayer, 100000)
    end

    self:registerTouchEvent(self._clipLayer, function()
        if self._curChannel ~= ChatConst.CHAT_CHANNEL.WORLD then
            return
        end

        if self._infoNode then
            self._infoNode:removeFromParent(true)
            self._infoNode = nil
        end
        end)

    self._clipLayer:setSwallowTouches(false)
end

return ChatView
