--[[
    Filename:    ChatCallView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-09-10 17:19
    Description: 私聊进入玩家详细界面
--]]

local ChatCallView = class("ChatCallView",BasePopView)

function ChatCallView:ctor(data)
	self.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")
    self._chatModel = self._modelMgr:getModel("ChatModel")
end

function ChatCallView:onInit()
	local title = self:getUI("bg.titlebg.Label_35")
    title:setString("喇叭")
	UIUtils:setTitleFormat(title, 1)

	local num1 = self:getUI("bg.num1")
	num1:setString(tab.setting["CHAT_SHOWCOST"].value .. "个")
	local num2 = self:getUI("bg.num2")
	num2:setString(tab.setting["CHAT_SHOWTIME"].value .. "秒")

	local sendBtn = self:getUI("bg.sendBtn")
	self:registerClickEvent(sendBtn, function()
		self:sendBtnFunc()
		end)

	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		end)

	self:initInputBox()	 
end

function ChatCallView:reflashUI()
	local curCost = self._userModel:getData().gem
    local needCost = tab.setting["CHAT_SHOWCOST"].value
    local num1 = self:getUI("bg.num1")
    if curCost < needCost then
    	num1:setColor(UIUtils.colorTable.ccUIBaseColor6) 
    else
    	num1:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 
    end
end

function ChatCallView:initInputBox()
	--输入框  文本初始化
    self._chatBoxBg = self:getUI("bg.inputBg")
    self._textField = self:getUI("bg.inputBg.inputBg1.textField")
    self._textField:setTouchEnabled(false)
    self._textField.rectifyPos = true
    self._textField.openCustom = true
    self._textField.maxLengTip = lang("CHAT_SYSTEM_LENTH_TIP")
    self._textField:setPlaceHolder(lang("CHAT_SYSTEM_LENTH"))
    self._textField:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._textField:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    self._textField.handleLen = function(sender, param)
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
        self._textField:attachWithIME()
    end)
end

function ChatCallView:detachKeyBoard()
	if self._textField then
		self._textField:detachWithIME()
	end
end

function ChatCallView:sendBtnFunc()
    local curCost = self._userModel:getData().gem
    local needCost = tab.setting["CHAT_SHOWCOST"].value
	if curCost < needCost then
		DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
		    self._viewMgr:showView("vip.VipView", {viewType = 0, callback = function()
		    	self:reflashUI()
		    	end})
		end})
        return
	end

	local sendStr = self._textField:getString()
    if string.len(sendStr) == 0 or string.gsub(sendStr, " ", "") == "" then 
        self._viewMgr:showTip("发送内容不能为空")
        return
    end

    local isTimeBanned, isInfoBanned, sendData = self._chatModel:paramHandle("crosschat2", {text = sendStr})  --时间和消息刷屏禁言
    self._serverMgr:sendMsg("ChatServer", "sendMessage", sendData, true, {}, function (result)
    		self._viewMgr:showTip(lang("CHAT_SHOWSUC"))
            self:close()
        end)
    -- self._chatModel:pushData(sendData)
    -- self:close()
end



return ChatCallView