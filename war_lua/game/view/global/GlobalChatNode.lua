--[[
    Filename:    GlobalChatNode.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-10-28 16:24:21
    Description: 聊天通用按钮
--]]

local GlobalChatNode = class("GlobalChatNode", BaseMvcs, ccui.Widget)

function GlobalChatNode:ctor(inType, closeCallback)
	GlobalChatNode.super.ctor(self)
	self._openType = inType or "pri"
    self._closeCallback = closeCallback

	self:onInit()
end

function GlobalChatNode:onInit()
	-- chatBtn
	self._chatBtn = ccui.Button:create()
	self._chatBtn:loadTextures("globalBtnUI_chatBtn.png", "globalBtnUI_chatBtn.png", "globalBtnUI_chatBtn.png", 1)
	self._chatBtn:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self._chatBtn:getContentSize().width, self._chatBtn:getContentSize().height)
    self._chatBtn:setPosition(self._chatBtn:getContentSize().width * 0.5, self._chatBtn:getContentSize().height * 0.5)
	self:addChild(self._chatBtn)
	registerClickEvent(self._chatBtn, function ()
        self._viewMgr:showDialog("chat.ChatView", {enterType = self._openType, closeCallback = self._closeCallback}, true)
    end)

	-- redpoint
	self._redPoint = ccui.ImageView:create("globalImageUI_bag_keyihecheng.png", 1)
	self._redPoint:setPosition(50, self._chatBtn:getContentSize().height - 20)
	self._chatBtn:addChild(self._redPoint)
	self._redPoint:setVisible(false)

	-- unread
	self._chatUnread = ccui.ImageView:create("globalImageUI6_tipBg.png", 1)
	self._chatUnread:setPosition(50, self._chatBtn:getContentSize().height - 20)
	self._chatBtn:addChild(self._chatUnread)
	self._chatUnread:setVisible(false)

	self._unreadNum = ccui.Text:create(0, UIUtils.ttfName, 20)
	self._unreadNum:setPosition(self._chatUnread:getContentSize().width/2, self._chatUnread:getContentSize().height/2 + 1)
	self._unreadNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
	self._chatUnread:addChild(self._unreadNum)

    self:showChatUnread("priUnread")   --显示未读


    -- local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 182))
    -- layer:setContentSize(self:getContentSize().width , self:getContentSize().height)
    -- layer:setPosition(0, 0)
    -- self:addChild(layer)
end

function GlobalChatNode:showChatUnread(inData)
	if inData == nil then
        return
    end

    local inData = string.split(inData, "_")
    if inData[1] ~= "priUnread" then
        return
    end

    if not self._modelMgr then
        return
    end

    local chatModel = self._modelMgr:getModel("ChatModel")
    local guildUnread = chatModel:getUnread(ChatConst.CHAT_CHANNEL.GUILD)
    local worldUnread = chatModel:getUnread(ChatConst.CHAT_CHANNEL.WORLD)
    local priUnread = chatModel:getPriUnread()

    self._chatUnread:setVisible(false)
    self._redPoint:setVisible(false)

    if guildUnread > 0 or next(priUnread) ~= nil then   --未读数显示
        self._chatUnread:setVisible(true)
        local num1 = guildUnread + #table.keys(priUnread)
        local num = num1 > 99 and "99+" or num1
        self._unreadNum:setString(num)
    else
        if worldUnread > 0 then
            self._redPoint:setVisible(true)
        end
    end
end

return GlobalChatNode
