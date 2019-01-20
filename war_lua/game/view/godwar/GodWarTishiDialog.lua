--[[
    Filename:    GodWarTishiDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-04 22:13:43
    Description: File description
--]]

-- 提示
local GodWarTishiDialog = class("GodWarTishiDialog", BasePopView)

function GodWarTishiDialog:ctor()
    GodWarTishiDialog.super.ctor(self)
end

function GodWarTishiDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarTishiDialog")
        end
        self:close()
    end)  

    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
end

function GodWarTishiDialog:reflashUI(data)
    local showType = data.showType
    local showStr = lang("GODWAR_TIP_04")
    local xiaoren = self:getUI("bg.xiaoren")
    if showType == 2 then
        showStr = lang("GODWAR_TIP_03")
        xiaoren:setVisible(false)
    end
    showStr = "[color=645252,fontsize=24]　　" .. showStr .. "[-]"
    local richTextBg = self:getUI("bg.richTextBg")
    local richText = RichTextFactory:create(showStr, richTextBg:getContentSize().width, 0)
    richText:formatText()
    richText:setPosition(richTextBg:getContentSize().width/2, richTextBg:getContentSize().height - richText:getRealSize().height/2)
    richTextBg:addChild(richText)

    local gotoBtn = self:getUI("bg.gotoBtn")
    self:registerClickEvent(gotoBtn, function()
        self._serverMgr:sendMsg("GodWarServer", "getJoinList", {}, true, {}, function (result)
            self:close()
            ViewManager:getInstance():showView("godwar.GodWarView")
        end)
    end)
end


return GodWarTishiDialog
