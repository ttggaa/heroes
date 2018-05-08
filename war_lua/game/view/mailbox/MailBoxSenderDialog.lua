--[[
    Filename:    MailBoxSenderDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-24 21:54:42
    Description: File description
--]]

local MailBoxSenderDialog = class("MailBoxSenderDialog", BasePopView)

function MailBoxSenderDialog:ctor()
    MailBoxSenderDialog.super.ctor(self)
end

function MailBoxSenderDialog:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("mailbox.MailBoxSenderDialog")
        end
        self:close()
    end)

    local title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(title, 6)

    self._mailTitle = self:getUI("bg.mailTitle")
    self._mailTitle:setLineBreakWithoutSpace(true)
    self._senderLab = self:getUI("bg.senderLab")
    self._contentStr = self:getUI("bg.contentStr")
    self._contentStr:setLineBreakWithoutSpace(true)

    self._titleLen = self:getUI("bg.titleBg.labLen")
    self._contentLen = self:getUI("bg.contentBg.labLen")

    self._senderTimes = self:getUI("bg.senderTimes")
    local senderBtn = self:getUI("bg.senderBtn")
    self:registerClickEvent(senderBtn, function()
        self:senderData()
    end)

    self:listenReflash("MailBoxModel", self.reflashUI)
end

function MailBoxSenderDialog:senderData()
    local sendStr = self._senderLab:getString()
    local tLabel = self._mailTitle:getString()
    local num = utf8.len(tLabel)
    if tLabel == nil or tLabel == "" or num < 6 then
        self._viewMgr:showTip("大人，标题最少也要输入6个字")
        return
    elseif num > 10 then
        self._viewMgr:showTip("大人，标题最多只能输入10个字")
        return
    end

    local conLabel = self._contentStr:getString()
    local num = utf8.len(conLabel)
    if conLabel == nil or conLabel == "" or num < 20 then
        self._viewMgr:showTip("大人，最少也要输入20个字")
        return
    elseif num > 100 then
        self._viewMgr:showTip("大人，最多只能输入100个字")
        return
    end
    param = {sender = sendStr, title = tLabel, content = conLabel}
    self:sendGuildMails(param)
end

function MailBoxSenderDialog:reflashUI(data)
    if data and data.ftype == 1 then
        local str1 = string.gsub(lang("GUIlDEMAILTITLE_WORD"), "%b[]", "")
        self._mailTitle:setString(str1)
        str1 = string.gsub(lang("GUIlDEMAILCONTENT_WORD"), "%b[]", "")
        self._contentStr:setString(str1)
        -- self._mailTitle:setColor(cc.c3b(255,255,255))
        -- self._contentStr:setColor(cc.c3b(255,255,255))
    else
        self._mailTitle:setString("")
        self._contentStr:setString("")
        self._mailTitle:setColor(cc.c3b(255,255,255))
        self._contentStr:setColor(cc.c3b(255,255,255))
    end
    local userD = self._userModel:getData()
    
    local senderStr = "联盟长-" .. userD.name
    self._senderLab:setString(senderStr)

    self._mailTitle:setPlaceHolderColor(cc.c4b(120,120,120,255))
    self._mailTitle:addEventListener(function(sender, eventType)
        if eventType == 0 then
        elseif eventType == 1 then
        elseif eventType == 2 then
            self._mailTitle:setColor(cc.c3b(61,31,0))
            self:updateTitleLen()
        elseif eventType == 3 then
            if sender:getString() == nil or sender:getString() == "" then
                self._mailTitle:setColor(cc.c3b(255,255,255))
            else
                self._mailTitle:setColor(cc.c3b(61,31,0))
            end
            self:updateTitleLen()
        end
    end)

    self._contentStr:setPlaceHolderColor(cc.c4b(120,120,120,255))
    self._contentStr:addEventListener(function(sender, eventType)
        if eventType == 0 then
        elseif eventType == 1 then
        elseif eventType == 2 then
            self._contentStr:setColor(cc.c3b(61,31,0))
            self:updateContentLen()
        elseif eventType == 3 then
            if sender:getString() == nil or sender:getString() == "" then
                self._contentStr:setColor(cc.c3b(255,255,255))
            else
                self._contentStr:setColor(cc.c3b(61,31,0))
            end
            self:updateContentLen()
        end
    end)

    local timesNum = self._modelMgr:getModel("GuildModel"):getSenderTimes()
    local senderTimesStr = "今日还可发送" .. timesNum .. "封"
    self._senderTimes:setString(senderTimesStr)

    self:updateTitleLen()
    self:updateContentLen()
end

function MailBoxSenderDialog:updateContentLen()
    local num = utf8.len(self._contentStr:getString())
    local str = "(" .. num .. "/100)"
    self._contentLen:setString(str)
end

function MailBoxSenderDialog:updateTitleLen()
    local num = utf8.len(self._mailTitle:getString())
    local str = "(" .. num .. "/10)"
    self._titleLen:setString(str)
end

function MailBoxSenderDialog:sendGuildMails(param)
    dump(param, "param=========")
    if param == nil then
        param = {sender = "aaa", title = "title", content = "content"}
        return
    end
    self._serverMgr:sendMsg("GuildServer", "sendGuildMails", param, true, {}, function (result)
        if result == nil then 
            return
        end
        dump(result, "test", 10)
        if self.close then
            self._viewMgr:showTip("邮件发送成功。")
            self:close()
        end
        -- self:reflashUI()
    end, function(errorId)
        if tonumber(errorId) == 125 then
            self._viewMgr:showTip("只能为中文、英文、数字")
        elseif tonumber(errorId) == 126 then
            self._viewMgr:showTip("字符串长度不足")
        elseif tonumber(errorId) == 127 then
            self._viewMgr:showTip("字符串长度超出限制")
        elseif tonumber(errorId) == 117 then
            self._viewMgr:showTip("输入内容含有非法字符")
        end
    end)
end

return MailBoxSenderDialog