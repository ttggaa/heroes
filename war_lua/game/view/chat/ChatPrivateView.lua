--[[
    Filename:    ChatPrivateView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-05-24 15:37
    Description: 私聊界面
--]]

local ChatPrivateView = class("ChatPrivateView", BasePopView)

function ChatPrivateView:ctor(data)
    -- local sfc = cc.SpriteFrameCache:getInstance()
    -- sfc:addSpriteFrames("asset/ui/chat.plist", "asset/ui/chat.png")
	ChatPrivateView.super.ctor(self)
	self._chatModel = self._modelMgr:getModel("ChatModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    require("game.view.chat.ChatConst")

    self._cacheRich = {}    --富文本信息
    self._chatData = {}     --当前右侧聊天信息

    self._openInfo = data
    self._oldUI = data.oldUI 
    self._isHasLoadAsy = data.isHasLoadAsy

    self._currChatNum = 0      --当前右侧cell条数
    self._isLoadFin = false    --是否数据正在加载  防止push消息时冲突
end

function ChatPrivateView:setOldUI(isShow, isfresh)
    self._chatModel:setIsOpenPrivateView(not isShow)

    if not self._oldUI then
        return
    end
    if isShow then
        self._oldUI:setVisible(true)
        if self._oldUI.refreshPriRedPoint then
            self._oldUI:refreshPriRedPoint()
        end
    else
        self._oldUI:setVisible(false)
    end
end

function ChatPrivateView:onInit()
    self:setOldUI(false)

    self._bg = self:getUI("bg")
    self._bg.noSound = true
    self:registerClickEvent(self._bg, function()
            self:hideEmojiView() 
        end)

    self._tipBug = self:getUI("bg.bg2.chat.chatList.tipBug")
    self._tipBug:setVisible(false)

    self._titleLab = self:getUI("bg.bg2.titleBg.titleLab")
    self._titleLab:setString("")
    -- self._titleLab:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._titleLab, 1)
    if ChatConst.IS_DEBUG_OPEN == false then
        self._titleLab:setString("私聊")
    else
        self._titleLab:setString("")
    end
    
	self._userList = self:getUI("bg.bg2.userList")
	self_chatList = self:getUI("bg.bg2.chat.chatList")
	--发送按钮
	self._sendBtn = self:getUI("bg.bg2.chat.sendBtn")
    self._sendBtn:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)
    self:registerClickEvent(self._sendBtn, function()
        self:sendMessage()
    end)

    --删除按钮
    self._deleteBtn = self:getUI("bg.bg2.chat.deleteBtn")
    self:registerClickEvent(self._deleteBtn, function()
        self:hideEmojiView()
        self._contextTextField:setString("")
        self._serverMgr:sendMsg("ChatServer", "delPriMessage", {to = self._currPriID}, true, {}, 
            function(result)
                self:deleteChat()
            end)
        end)

	--输入框
	self._chatBoxBg = self:getUI("bg.bg2.chat.chatBg")
    self._contextTextField = self:getUI("bg.bg2.chat.chatBg.chagBg1.contextTextField")
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

    --关闭按钮
	self._closeBtn = self:getUI("bg.bg2.closeBtn")
	self:registerClickEvent(self._closeBtn, function() 
            self:setOldUI(true)
            self._chatModel:clearCacheUser()
            self._chatModel:setPriApplyRecord() --清空需审批的联盟申请记录
            self:close()
            UIUtils:reloadLuaFile("chat.ChatPrivateView")
            UIUtils:reloadLuaFile("chat.ChatPrivateChatCell")
            UIUtils:reloadLuaFile("chat.ChatPrivateUserCell")
        end)

	--表情
	self._emojiBtn = self:getUI("bg.bg2.chat.emojiBtn")
	self:registerClickEvent(self._emojiBtn, function ()
        if self._emojiNode == nil then 
            local panelBg = self:getUI("bg.bg2.chat")
            self._emojiNode = self:createLayer("chat.ChatEmojiNode", {callback = function(value)
                self._contextTextField:setString(self._contextTextField:getString() .. value)
            end, type = "pri"})
            self._emojiNode:setPosition(12 + 27, 110 - 44)
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

	--model监听
    self:setListenReflashWithParam(true)
    self:listenReflash("ChatModel", self.modelReflash_chat) 

    --场景监听
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            if self._cacheRich ~= nil then 
                for k,v in pairs(self._cacheRich) do
                    v:release()
                end
            end
        elseif eventType == "enter" then 
            -- self:onEnter()
        end
    end)
end

function ChatPrivateView:onEnter()
    -- self._viewMgr:lock(-1)
    -- ScheduleMgr:delayCall(100, self, function ()
    --     self._viewMgr:unlock()
    --     self:createLeftUserList()
    --     end)
end

function ChatPrivateView:onPopEnd()
    self._viewMgr:lock(-1)   
    ScheduleMgr:delayCall(100, self, function ()   --delayCall(100) 让背景压黑层先渲染完
        self._viewMgr:unlock()
        --语音voiceBtn
        local panelBg = self:getUI("bg.bg2.chat")
        self._voiceBtn = require("game.view.chat.ChatVoiceNode").new()
        self._voiceBtn:setPosition(70, 37)
        self._voiceBtn:setVisible(false)
        panelBg:addChild(self._voiceBtn)

        local posT = self._voiceBtn:convertToWorldSpace(cc.p(0, 0))
        self._voiceBtn._curType = ChatConst.CHAT_CHANNEL.PRIVATE
        self._voiceBtn:onInit({pos = posT})
        
        --left
        self:createLeftUserList()
        end)
end

--监听model处理函数 
function ChatPrivateView:modelReflash_chat(data)
	local dataTb = string.split(data, "/")
    if dataTb[1] ~= ChatConst.CHAT_CHANNEL.PRIVATE then 
        return
    end

   	if dataTb[2] == self._currPriID then 
   		self:updateRightChatList()   --右侧列表插入新聊天信息
   	else
        if self._userTableView ~= nil then
            local index = self:getCellIndexByID(dataTb[2])
            local tempCell = self._userTableView:cellAtIndex(index)
            if tempCell ~= nil then   
                tempCell._unreadMark:setVisible(true)
                self._chatModel:setPriUnread(dataTb[2])
            end
        end
   	end
end

function ChatPrivateView:updateRightChatList()
    if self._isLoadFin == false then
        return
    end

    local tempData = self._chatModel:getPrivateDataByUserID(self._currPriID)
    if self._currChatNum < #tempData then 
        for i=#tempData - self._currChatNum - 1, 0, -1 do
            local tempData1 = tempData[i+1]
            table.insert(self._chatData, 1, clone(tempData1))
            self._chatTableView:insertCellAtIndex(0)
        end
    end

    if self._chatTableView:getContentSize().height > self._listBgHeight then 
        self._chatTableView:setContentOffset(cc.p(0, 0))
    end

    -- 移除多余条数
    local tableOffset = self._chatTableView:getContentOffset()
    if tableOffset.y >= 0 then 
        if #self._chatData > ChatConst.CHAT_MSG_MAX_LEN then 
            for i = #self._chatData, ChatConst.CHAT_MSG_MAX_LEN + 1, -1 do
                local removeId = self._chatData[i].id
                table.remove(self._chatData)
                self._chatModel:removeDataByChannel("pri", i, self._currPriID)
                self._chatTableView:removeCellAtIndex(i-1)  --移除最后一个可以用removeCellAtIndex方法
                if self._cacheRich[removeId] ~= nil then 
                    self._cacheRich[removeId]:release()
                    self._cacheRich[removeId] = nil
                end
            end
        end
    end

    self._currChatNum = #self._chatData
    self:setTipInfo(#self._chatData)
end

--服务器请求发送聊天消息
function ChatPrivateView:sendMessage()
    self:hideEmojiView()
    if #self._showData == 0 then
        return
    end

    local sendStr = self._contextTextField:getString()
    if string.len(sendStr) == 0 or string.gsub(sendStr, " ", "") == ""  then
        self._viewMgr:showTip("发送内容不能为空")
        if self._chatTableView then
            local cacheY = self._chatTableView:getContentOffset().y
            self._chatTableView:reloadData()
            self._chatTableView:setContentOffset(cc.p(0, cacheY), false)
         end 
        return
    end
    
    -- if os.time() < self._userModel:getData().banChat then 
    --     self._viewMgr:showTip(lang("CHAT_SYSTEM_PUNISH"))
    --     return
    -- end

    local userData = self._userModel:getData()
    local VipData = self._modelMgr:getModel("VipModel"):getData()
    local idPrefix = string.split(self._currPriID, "_")

    if self._currPriID == "bug_op" then   --bug反馈
        local param1 = {text = sendStr}
        local _, _, param = self._chatModel:paramHandle(ChatConst.CELL_TYPE.PRI2, param1)
        self:sendBugReport(param, function(respData)
            for k,v in pairs(respData) do
                self._chatModel:pushData(v)
            end
        end)

    elseif idPrefix[1] == "arena" then     --排行榜NPC
        local param1 = {text = sendStr}
        local _, _, param = self._chatModel:paramHandle(ChatConst.CELL_TYPE.PRI3, param1)
        self._chatModel:pushData(param)

    else                                   
        local param1 = {
            text = sendStr,
            toID = self._currPriID
        }
        local _, _, param = self._chatModel:paramHandle(ChatConst.CHAT_CHANNEL.PRIVATE, param1)
        self._serverMgr:sendMsg("ChatServer", "sendPriMessage", param, true, {}, function (result)  end)
    end

    self._contextTextField:setString("")   --先获取再清空
end

function ChatPrivateView:sendBugReport( data,callback )
    local proData = {}
    table.insert(proData,data)
    local opReport = {
        id = 2400 .. tostring(os.time()),
        message = {
            text = "您好！您反馈的bug我们会尽快处理！",
            udata = {
                avatar = 2302,
                guildName = "",
                lvl = 0,
                name = "会跳舞的小妖精",
                rid = "bug_op",
                vipLvl = 0,
            }
        },
        t = data.t+1,
        type = "debug",
    }  
    table.insert(proData,opReport)

    local sendData = clone(data)  --by wangyan callback里面会对数据进行文本包装，提前复制一份
    if callback then 
        callback(proData)
    end
    ApiUtils.playcrab_commit_question( {content = sendData and sendData.message and sendData.message.text,callback = function( )
    end} )
end

--第一次登录获取服务器数据
function ChatPrivateView:getMessage()
    self._serverMgr:sendMsg("ChatServer", "getMessage", {type = "pri"}, true, {}, function (result)
        self:getMessageFinish(result)
    end)
end

function ChatPrivateView:getMessageFinish(result)  
    -- unlock
    self._viewMgr:unlock()
    self._chatModel:setLoadDataByChannel(ChatConst.CHAT_CHANNEL.PRIVATE)
    self._chatModel:updatDataByType(ChatConst.CHAT_CHANNEL.PRIVATE, result) 
    
    --当前信息设置
    if self._openInfo and self._openInfo["userData"] then
        self._currPriID = self._openInfo["userData"].rid    --当前聊天对象ID
        self._chatModel:setCacheUserData(self._openInfo["userData"])    --设置当前账号
        self._showData = clone(self._chatModel:getPrivateChatWithNum(1))
        self:setTipInfo(#self._showData)
        if #self._showData == 0 then
            return
        end
    else
        self._showData = clone(self._chatModel:getPrivateChatWithNum())
        self:setTipInfo(#self._showData)
        if #self._showData == 0 then
            return
        end
        if self._openInfo["viewtType"] == "debug" then
            self._currPriID = self._showData[#self._showData]["user"].rid
        else
            self._currPriID = self._showData[math.max(#self._showData-1, 1)]["user"].rid
        end
    end
    self._chatModel:setCacheUserID(self._currPriID)

    self._curLeftSize = #self._showData
    self._curSelectIndex = self:getCellIndexByID(self._currPriID)
    self._chatData = clone(self._chatModel:getPrivateDataByUserID(self._currPriID))
    self._currChatNum = #self._chatData
    self._userTableView:reloadData()
    -- dump(self._chatData, "123", 10)
    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(0, self, function () 
        self._viewMgr:unlock()
        self:createRightChatList(self._currPriID)   --初始化右侧列表
        end)
end

function ChatPrivateView:setTipInfo(inNum)
    if inNum == 0 then
        if self._currPriID == "bug_op" then
            self._tipBug:getChildByName("Label_32"):setString("请输入您的问题或意见，小精灵会为您解答")
            self._tipBug:setVisible(true)
        else
            self._tipBug:getChildByName("Label_32"):setString("暂时没有聊天信息呦")
            self._tipBug:setVisible(true)
        end
        return
    else
        self._tipBug:setVisible(false)
    end
end

function ChatPrivateView:createLeftUserList()
    -- self._viewMgr:lock(-1)
	self:hideEmojiView() 
	
    --初始化tableview
    local tableBg = self:getUI("bg.bg2.userList")
    if self._userTableView ~= nil then 
        self._userTableView:removeFromParent()
        self._userTableView = nil
    end
    self._userTableView = cc.TableView:create(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 16))
    self._userTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._userTableView:setPosition(cc.p(6, 8))
    self._userTableView:setDelegate()
    self._userTableView:setBounceable(true)
    self._userTableView:registerScriptHandler(function(table, cell) self:tableCellTouched_user(table,cell) 		  end,cc.TABLECELL_TOUCHED)
    self._userTableView:registerScriptHandler(function(table, idx) 	return self:cellSizeForTable_user(table,idx)  end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._userTableView:registerScriptHandler(function(table, idx) 	return self:tableCellAtIndex_user(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._userTableView:registerScriptHandler(function(table) 		return self:numberOfCellsInTableView_user(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableBg:addChild(self._userTableView)
    if self._userTableView.setDragSlideable ~= nil then 
        self._userTableView:setDragSlideable(true)
    end

    --请求数据
    -- ScheduleMgr:delayCall(0, self, function ()
        if not self._chatModel:getIsLoadDataByChannel(ChatConst.CHAT_CHANNEL.PRIVATE) then 
            self:getMessage()
            return
        end
        -- self._viewMgr:unlock()  
        
        --当前信息设置
        if self._openInfo and self._openInfo["userData"] then
            self._currPriID = self._openInfo["userData"].rid    --当前聊天对象ID
            self._chatModel:setCacheUserData(self._openInfo["userData"])    --设置当前账号
            self._showData = clone(self._chatModel:getPrivateChatWithNum(1))
            self:setTipInfo(#self._showData)
            if #self._showData == 0 then
                return
            end
        else
            self._showData = clone(self._chatModel:getPrivateChatWithNum())
            self:setTipInfo(#self._showData)
            if #self._showData == 0 then
                return
            end
            if self._openInfo["viewtType"] == "debug" then
                self._currPriID = self._showData[#self._showData]["user"].rid
            else
                self._currPriID = self._showData[math.max(#self._showData-1, 1)]["user"].rid
            end
        end
        self._chatModel:setCacheUserID(self._currPriID)
             
        self._curLeftSize = #self._showData  
        self._curSelectIndex = self:getCellIndexByID(self._currPriID)
        self._chatData = clone(self._chatModel:getPrivateDataByUserID(self._currPriID))
        self._currChatNum = #self._chatData
        self._userTableView:reloadData()
        self._viewMgr:lock(-1)
        ScheduleMgr:delayCall(0, self, function ()  --delayCall 先刷左边，否则数据多两边同时白板
            self._viewMgr:unlock()
            self:createRightChatList(self._currPriID)   --初始化右侧列表
        end)

        -- dump(self._showData, "showdata", 10)
    -- end)  
end

--tableview 点击监听
function ChatPrivateView:tableCellTouched_user(table,cell)
	local tempCell = table:cellAtIndex(self._curSelectIndex)
    if tempCell ~= nil then 
        tempCell:switchListItemState(false)
        -- --最上面的cell是否有未读
        -- local cellIndex = self:getCellIndexByID(tempCell:getName())
        -- local cellMaxIndex = math.min(#self._showData-1, ChatConst.CHAT_PRIVATE_USER_MAX_LEN-1)
        -- local isUnread = tempCell._unreadMark:isVisible() 
        -- if cellIndex == cellMaxIndex and isUnread then 
        --     tempCell._unreadMark:setVisible(false)
        --     self._chatModel:removePriUnread(tempCell:getName())
        -- end
    end
    cell:switchListItemState(true)
    self._curSelectIndex = cell:getIdx()

    self._currPriID = cell:getName()
    if self._voiceBtn then
        self._voiceBtn._currPriID = self._currPriID
    end
    
	self._chatModel:setCacheUserID(cell:getName())
    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(0, self, function ()   --delayCall 先切完标签再刷界面
        self._viewMgr:unlock()
        self:createRightChatList(cell:getName())  --创建右侧聊天列表
        end)
end

--tableview 
function ChatPrivateView:cellSizeForTable_user(table,idx)
	return 125, 255   
end

--tableview 
function ChatPrivateView:tableCellAtIndex_user(table1,idx)
	local cell = table1:dequeueCell()
    local userData = self._showData[idx + 1]

    cell = require("game.view.chat.ChatPrivateUserCell"):new()
    cell:setName(userData["user"].rid)

    --unread
    local isUnread = false 
    local unreadList = self._chatModel:getPriUnread()  --当前默认为已读
    if unreadList[userData["user"].rid] then
        if userData["user"].rid ~= self._currPriID then
            isUnread = true
        else
            isUnread = false
            self._chatModel:removePriUnread(userData["user"].rid)
        end
    end

    -- local cellMaxIndex = math.min(#self._showData, ChatConst.CHAT_PRIVATE_USER_MAX_LEN) - 1 --最上面一个默认为已读
    -- if idx == cellMaxIndex and isUnread then  
    --     isUnread = false
    --     self._chatModel:removePriUnread(userData["user"].rid)
    -- end
    
    --isCurClick
    local isCurrClick = false
    if userData["user"].rid == self._currPriID then
        isCurrClick = true
        self._curSelectIndex = self:getCellIndexByID(self._currPriID)
    end

    local callback = {}
    callback["shieldBtn"] = function()
        self:deleteChat()
    end

    cell:reflashUI(userData, isCurrClick, isUnread, callback)
    return cell
end

--tableview 
function ChatPrivateView:numberOfCellsInTableView_user(table)
	return #self._showData
end

--右侧tableview  【聊天列表】
function ChatPrivateView:createRightChatList(userID)
    self._isLoadFin = false
	self._chatData = clone(self._chatModel:getPrivateDataByUserID(userID))
    -- dump(self._chatData)

	self._currChatNum = #self._chatData
    if self._chatTableView ~= nil then 
	    self._chatTableView:removeFromParent()
        self._chatTableView = nil
    end

    -- 释放cache的富文本     
    for k,v in pairs(self._cacheRich) do
        v:release()
    end
    self._cacheRich = {}

    self:setTipInfo(#self._chatData) 

    if (#self._showData == 1 or self._currPriID == "bug_op") and ChatConst.IS_DEBUG_OPEN == true then
        self._titleLab:setString("bug反馈")
    else
        self._titleLab:setString("私聊")
    end

    --删除按钮
    local tableBg = self:getUI("bg.bg2.chat.chatList")
    local scrollWidth, scrollHeight = tableBg:getContentSize().width , tableBg:getContentSize().height - 47 - 28
    local posX, posY = 10, 47 + 14
    if self._currPriID == "bug_op" then
        self._deleteBtn:setVisible(false)
        self._voiceBtn:setVisible(false)
        scrollWidth, scrollHeight = tableBg:getContentSize().width , tableBg:getContentSize().height - 28
        posX, posY = 10, 0 + 14
    else
        self._deleteBtn:setVisible(true)
        self._voiceBtn:setVisible(true)
    end

    self._listBgHeight = scrollHeight
    self._chatTableView = cc.TableView:create(cc.size(scrollWidth, scrollHeight))
    self._chatTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._chatTableView:setPosition(cc.p(posX, posY))
    self._chatTableView:setDelegate()
    self._chatTableView:setBounceable(true)
    self._chatTableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable_chat(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._chatTableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex_chat(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._chatTableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView_chat(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._chatTableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle_chat(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)
    tableBg:addChild(self._chatTableView)
    if self._chatTableView.setDragSlideable ~= nil then 
        self._chatTableView:setDragSlideable(true)
    end
    self._chatTableView:reloadData()
    if self._chatTableView:getContentSize().height > self._listBgHeight then 
        self._chatTableView:setContentOffset(cc.p(0, 0))
    end
    self._isLoadFin = true
end

--tableview 
function ChatPrivateView:cellSizeForTable_chat(table,idx)
	local data, height = self:getChatContentRich(self._chatData[idx + 1], 330)
    if height > 22 then 
        return 90 + height - 22, 554
    else
        return 90, 540  --90,554
    end
end

--tableview 
function ChatPrivateView:tableCellAtIndex_chat(table, idx)
	local cell = table:dequeueCell()
    local chatData = self._chatData[idx + 1]
    if nil == cell then
        cell = require("game.view.chat.ChatPrivateChatCell"):new()
    end

    local richText , height = self:getChatContentRich(chatData, 330)
    local cellHeight = height>22 and 90 + height - 22 or 90    
    local isMyself = false
    if self._userModel:getData()._id == chatData.message.udata.rid then 
        isMyself = true
    end
    cell:reflashUI(chatData, richText, 540, cellHeight, isMyself) --554
    return cell
end

--tableview 
function ChatPrivateView:numberOfCellsInTableView_chat(table)
	return #self._chatData
end

--tableview 
function ChatPrivateView:tableCellWillRecycle_chat(table,cell)
	if cell.richText ~= nil then 
        cell.richText:removeFromParent()
        cell.richText = nil
    end
end

--重置表情view
function ChatPrivateView:hideEmojiView( ... )
    if self._emojiNode ~= nil then
        self._emojiNode:hideView(false)
        self._emojiNode = nil
    end
end

--创建聊天信息富文本
function ChatPrivateView:getChatContentRich(data, width)
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

--根据rid获取左侧cell下标
function ChatPrivateView:getCellIndexByID(userID)
    if self._showData == nil then
        return -1
    end

    for i,v in ipairs(self._showData) do
        if v["user"].rid == userID then
            return i-1
        end
    end
    return 0
end

--删除按钮点击回调
function ChatPrivateView:deleteChat()
    if #self._showData == 0 then
        return
    end

    local cellIndex = self:getCellIndexByID(self._currPriID)
    table.remove(self._showData, cellIndex+1)
    self._chatModel:removeDataByChannel(ChatConst.CHAT_CHANNEL.PRIVATE, cellIndex+1)   --删除用户

    if #self._showData ~= 0 then
        if cellIndex < #self._showData then
            self._currPriID = self._showData[cellIndex+1]["user"].rid
            self._chatModel:setCacheUserID(self._currPriID)
        else
            self._currPriID = self._showData[cellIndex]["user"].rid
            self._chatModel:setCacheUserID(self._currPriID)
        end
    end

    self._userTableView:reloadData()
    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(0, self, function ()    --delayCall 先换标签再刷数据
        self._viewMgr:unlock()
        self:createRightChatList(self._currPriID)
        end)    
end

function ChatPrivateView:refreshUI()
    --删除按钮
    if #self._showData == 0 then
        self._deleteBtn:setVisible(false)
    else
        self._deleteBtn:setVisible(true)
    end
end

return ChatPrivateView