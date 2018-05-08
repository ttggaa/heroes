--[[
    Filename:    DialogCodeExchangeView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-08-24 22:00:17
    Description: File description
--]]

local DialogCodeExchangeView = class("DialogCodeExchangeView",BasePopView)

function DialogCodeExchangeView:ctor()
    self.super.ctor(self)
end

function DialogCodeExchangeView:onInit()
	self:registerClickEventByName("bg.enterBtn", function ()
		local codeStr = self._contextTextField:getString()

		if codeStr == nil or codeStr == "" then
			self._viewMgr:showTip(lang("DUIHUAN_TIP1"))
            return
        end

        self._viewMgr:showTip("请求未接通")

     --    self._serverMgr:sendMsg("UserServer","setName", param, true, {}, function(result) 
        	-- self._viewMgr:showTip(lang("DUIHUAN_TIP3"))
     --    	self:close()
	    -- end)
    end)

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("main.DialogCodeExchangeView")
    end)

    self._title = self:getUI("bg.title")
    UIUtils:setTitleFormat(self._title, 6)

    --输入框  文本初始化
    self._codeBg = self:getUI("bg.codeBg")
    self._contextTextField = self:getUI("bg.codeBg.codeBg1.contextTextField")
    self._contextTextField:setTouchEnabled(false)
    self._contextTextField.rectifyPos = true
    self._contextTextField.openCustom = true
    self._contextTextField:setPlaceHolder(lang("DUIHUAN_TIP1"))
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
    self:registerClickEvent(self._codeBg, function ()
        self._contextTextField:attachWithIME()
    end)
end

return DialogCodeExchangeView	