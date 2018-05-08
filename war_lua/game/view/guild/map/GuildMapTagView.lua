--[[
    Filename:    GuildMapTagView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-04 20:06:01
    Description: File description
--]]

local GuildMapTagView = class("GuildMapTagView", BasePopView)

function GuildMapTagView:ctor(param)
    GuildMapTagView.super.ctor(self)
    self._callback2 = param.callback2
    self._callback1 = param.callback1
    self._point = param.tagPoint
end

function GuildMapTagView:onInit()
    local closeBtn = self:getUI("bg.cancelBtn")
    self:registerClickEvent(closeBtn, function()
        if self._callback2 then
            self._callback2()
        end
        self:close()
        UIUtils:reloadLuaFile("guild.map.GuildMapTagView")
        end)

    local enterBtn = self:getUI("bg.enterBtn")
    self:registerClickEvent(enterBtn, function()
        local str = self._contextTextField:getString()
        local len = string.utf8len(str)
        if string.utf8len(str) < 10 then
            self._viewMgr:showTip("最少输入10个字")
            return
        end
        self._serverMgr:sendMsg("GuildMapServer", "mapMark", {tagPoint = self._point, des = str}, true, {}, function (result)
            self._modelMgr:getModel("GuildMapModel"):addTagsData(result)
            if self._callback1 then
                self._callback1()
            end
            self:close()
            end)
        end)

	--输入框  文本初始化
    self._inputBg = self:getUI("bg.txtBg")
    self._contextTextField = self:getUI("bg.txtBg.Panel_41.textField")
    self._contextTextField:setTouchEnabled(false)
    self._contextTextField.rectifyPos = true
    self._contextTextField.openCustom = true
    self._contextTextField.maxLengTip = lang("CHAT_SYSTEM_LENTH_TIP")
    self._contextTextField:setPlaceHolder("最多可输入25个字")
    self._contextTextField:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._contextTextField:setPlaceHolderColor(UIUtils.colorTable.ccUIBaseTextColor1)

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

    self:registerClickEvent(self._inputBg, function ()
        self._contextTextField:attachWithIME()
    end)
end

return GuildMapTagView