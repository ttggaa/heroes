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
    self:registerClickEvent(self._unreadBg, 
        function(sender) 
            if self._tableView ~= nil and self._tableView:getContentSize().height >  self._listBgHeight then
                self._tableView:setContentOffset(cc.p(0, 0))
            end
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
    -- self._sendBtn:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)
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

    -- 系统
    local tab1 = self:getUI("bg1.bg2.bg_1.sysBtn")
    tab1:setPositionX(64)
    tab1:setScaleAnim(false)
    -- 世界
    local tab2 = self:getUI("bg1.bg2.bg_1.allBtn")
    tab2:setPositionX(64)
    tab2:setScaleAnim(false)
    --联盟
    local tab3 = self:getUI("bg1.bg2.bg_1.guildBtn")
    tab3:setPositionX(64)
    tab3:setScaleAnim(false)
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId 
    if guildId == nil or guildId <= 0 then  
        tab3:setVisible(false)
    end

    self:registerClickEvent(tab1, function(sender)self:tabButtonClick(sender) end)
    self:registerClickEvent(tab2, function(sender)self:tabButtonClick(sender) end)
    self:registerClickEvent(tab3, function(sender)self:tabButtonClick(sender) end)
    
    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    table.insert(self._tabEventTarget, tab3)
    self:setBtnState()

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
            if self._enterType and self._enterType == "guild" then
                btn = self:getUI("bg1.bg2.bg_1.guildBtn")
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
    UIUtils:reloadLuaFile("chat.ChatVoiceNode")

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
    UIUtils:reloadLuaFile("chat.ChatView")

end

--进入界面默认世界模块
function ChatView:onEnter(enterType)
    self._enterType = enterType

end

--[[
--! @function tabButtonClick
--! @desc 选项卡按钮点击事件处理
--! @param sender table 操作对象
--! @return 
--]]
function ChatView:tabButtonClick(sender)
    self._isShowDataFin = false
    if sender == nil then 
        return 
    end
    self:hideEmojiView()  
    if self._tabName == sender:getName() then  
        return
    end

    -- lock 
    self._viewMgr:lock(-1)

    --红点状态刷新
    local redPoint = sender:getChildByName("redPoint")
    if redPoint then
        redPoint:setVisible(false)
    end

    self:setBtnState(sender)
    --频道按钮状态更新
    -- for k,v in pairs(self._tabEventTarget) do
    --     v:setBright(true)
    --     v:setEnabled(true)
    --     if v.title ~= nil then
    --         v.title:removeFromParent(true)
    --         v.title = nil
    --     end
    --     v.title:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    --     sender.title:enableOutline(UIUtils.colorTable.ccUIBaseColor1, 1)
    -- end
    -- sender:setBright(false)
    -- sender:setEnabled(false)
    -- sender.title:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- sender.title:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)

    --获取频道名
    self._tabName = sender:getName()
    self._curChannel = string.sub(self._tabName, 1, string.len(self._tabName) - 3)
    self._chatModel:setCurrChannel(self._curChannel)
    if self._voiceBtn then
        self._voiceBtn._curType = self._curChannel
    end
    
    --频道开启等级判断   UI初始化
    self:channelLimitCheck()

    --获取频道model数据
    self._showData = clone(self._chatModel:getDataByType(self._curChannel))

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
    -- self._tableView:registerScriptHandler(function(table, cell) self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
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
        -- dump(self._showData, "chat"..self._curChannel, 10)

        if self._tableView:getContentSize().height >  self._listBgHeight then 
            self._tableView:setContentOffset(cc.p(0, 0))
        end
        self._isShowDataFin = true
        self._viewMgr:unlock()
    end)
end

function ChatView:setBtnState(inBtn)
    if self._tabEventTarget == nil or next(self._tabEventTarget) == nil then
        return
    end

    local btnName = {sysBtn = "系统", allBtn = "世界", guildBtn = "联盟"}
    for k,v in pairs(self._tabEventTarget) do
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
        btnTitle:setString(btnName[v:getName()])
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

--频道开启等级判断  UI初始化
function ChatView:channelLimitCheck()
    local limitLevel = tonumber(tab.systemOpen["Chat"][1])
    if self._userModel:getData().lvl < limitLevel or self._curChannel == ChatConst.CHAT_CHANNEL.SYS then 
        self._channelTip:setVisible(true)
        if self._curChannel == ChatConst.CHAT_CHANNEL.SYS then   --系统
            self._channelTip:setString(lang("CHAT_SYSTEM_BAN"))
        else
            self._channelTip:setString(lang("CHAT_SYSTEM_OPEN"))
        end
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

--刷新当前频道cell  移除多余
function ChatView:updateCurChannel(data)
    self._unlockRecord = self._lockScrollBtn:isSelected()  --用于记录推送之前聊天锁屏状态
    if data == "blackRemove" then
        local btn
        if self._enterType and self._enterType == "guild" then
            btn = self:getUI("bg1.bg2.bg_1.guildBtn")
        else
            btn = self:getUI("bg1.bg2.bg_1.allBtn")
        end
        self._tabName = ""
        self:tabButtonClick(btn)
        return
    end

    if data ~= self._curChannel then 
        self:refreshBtnRedPoint()
        return
    end
    self:updateCommonTableData(data)
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
 
--获取最新的频道model数据
function ChatView:updateCommonTableData(type)
    local unlock = false
    local tempY = self._tableView:getContentOffset().y - 85
    local tempData = self._chatModel:getDataByType(self._curChannel)
    -- self._showData = clone(self._chatModel:getDataByType(self._curChannel))
    if self._curChannelSize < #tempData then 
        for i=#tempData - self._curChannelSize - 1, 0, -1 do
            local tempData1 = tempData[i+1]
            if not (self._curChannel == ChatConst.CHAT_CHANNEL.SYS or
                (self._curChannel == ChatConst.CHAT_CHANNEL.GUILD and tempData1.typeCell == ChatConst.CELL_TYPE.GUILD2)) then
                local currID = tempData1.message.udata.rid
                -- 如果我本人发送消息则解除锁屏
                if self._userModel:getData()._id == currID then 
                    unlock = true
                end
            end
            table.insert(self._showData, 1, clone(tempData1))
            self._tableView:insertCellAtIndex(0)
        end
    end

    self._unreadCount = self._unreadCount + #self._showData - self._curChannelSize
   
    self._curChannelSize = #self._showData
    if not self._lockScrollBtn:isSelected() or unlock == true or not self._unlockRecord then    --未解锁/自己/push消息之前是未解锁
        self._unreadBg:setVisible(false)
        if self._tableView:getContentSize().height >  self._listBgHeight then 
            self._tableView:setContentOffset(cc.p(0, 0))
        end
    else
        self._unreadLab:setString("未读消息（" .. self._unreadCount .. "条）")
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

    local limitLevel = tonumber(tab.systemOpen["Chat"][1])
    if self._userModel:getData().lvl < limitLevel then 
        self._viewMgr:showTip(lang("CHAT_SYSTEM_OPEN"))
        return
    end

    local isTimeBanned, isInfoBanned, sendData = self._chatModel:paramHandle(self._curChannel, {text = sendStr})
    local isMsgBanned = self._chatModel:isChatMsgBanned()
    local isIdipBanned, banStr = self._chatModel:isChatIdipBanned()
    -- dump(sendData,"123", 10)
    
    if isIdipBanned == true and self._curChannel == "all" then        --禁言 by idip
        self._viewMgr:showTip(banStr)
        return
    end

    if isTimeBanned == true then        -- 禁言 by time
        self._viewMgr:showTip(lang("CHAT_SYSTEM_LAG"))
        return
    end

    if isInfoBanned == true and self._curChannel == "all" then        -- 禁言 by info
        if isMsgBanned == false then
            self._serverMgr:sendMsg("ChatServer", "banUserChat", {}, true, {}, function (result) 
                self._chatModel:pushData(sendData)
                end)
        else
            self._chatModel:pushData(sendData)
        end
        self._contextTextField:setString("")
        return
    end

    self._serverMgr:sendMsg("ChatServer", "sendMessage", sendData, true, {}, function (result)
            self:sendMessageFinish(result)
        end,
        function(errorId, errorMsg)
            if errorId == 140 then   --人工禁言
                self._viewMgr:showTip(errorMsg)
            end
            
        end)
end

function ChatView:sendMessageFinish(result)
    if result ~= nil and result.message ~= nil then 
        self._contextTextField:setString("") 
    end
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
        self._chatModel:setUnread(0, self._curChannel)
        self._unreadBg:setVisible(false)
        self._lockScrollBtn:setSelected(false)
    end
end

--tableview监听 ChatView
function ChatView:cellSizeForTable(table,idx)
    local chatData = self._showData[idx + 1]
    if self._curChannel == ChatConst.CHAT_CHANNEL.SYS or
        (chatData.type == ChatConst.CHAT_CHANNEL.GUILD and chatData.typeCell == ChatConst.CELL_TYPE.GUILD2) then
        local data, height = self:getChatContentRich(self._showData[idx + 1], idx, 1, 310) --400
        return 10 + height , 517
    else
        local data, height = self:getChatContentRich(self._showData[idx + 1], idx, 1, 213) --260
        if height > 22 then 
            return 90 + height - 22, 517
        else
            return 90, 517
        end
    end 
end

--创建聊天信息富文本
function ChatView:getChatContentRich(data, idx, type, width)
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

    --guild
    local guildRedPoint = self:getUI("bg1.bg2.bg_1.guildBtn.redPoint")
    if self._chatModel:getUnread(ChatConst.CHAT_CHANNEL.GUILD) > 0 then
        guildRedPoint:setVisible(true)
    else
        guildRedPoint:setVisible(false)
    end 

    --all
    local worldRedPoint = self:getUI("bg1.bg2.bg_1.allBtn.redPoint")
    if self._chatModel:getUnread(ChatConst.CHAT_CHANNEL.WORLD) > 0 then
        worldRedPoint:setVisible(true)
    else
        worldRedPoint:setVisible(false)
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
    local richText , height = self:getChatContentRich(chatData, idx, 2, 300)
    if nil == cell then
        cell = require("game.view.chat.ChatSysCell"):new()
    end
    cell:reflashUI(chatData, richText, 517, height + 10)
    return cell
end

--创建世界频道列表
function ChatView:createWorldChannelList(cell, chatData, idx)  
    local richText , height = self:getChatContentRich(chatData, idx, 2, 213)
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
        local richText , height = self:getChatContentRich(chatData, idx, 2, 300)
        if nil == cell then
            cell = require("game.view.chat.ChatGuildCell"):new()
        end
        cell:reflashUI(chatData, richText, 517, height + 10)

    else
        local richText , height = self:getChatContentRich(chatData, idx, 2, 213)
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

return ChatView
