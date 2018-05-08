--[[
    Filename:    GodWarPailianDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-04 19:45:35
    Description: File description
--]]

-- 拍脸图
local GodWarPailianDialog = class("GodWarPailianDialog", BasePopView)

function GodWarPailianDialog:ctor(param)
    GodWarPailianDialog.super.ctor(self)
    self._callback = param.callback
    self._gtype = param.gtype or 1
end

function GodWarPailianDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarPailianDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)  

    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._godWarModel:setShowType(self._gtype)

    local layerBg = self:getUI("bg.Image_61")
    layerBg:loadTexture("asset/bg/bg_godwar_001.png", 0)

    local wenzi = self:getUI("bg.wenzi")
    wenzi:setScale(1.3)
    wenzi:loadTexture("asset/other/ad/ad_text_godwar.png", 0)
end

function GodWarPailianDialog:reflashUI()
    local time = self:getUI("bg.time")
    local month = self._godWarModel:getShowTime()
    time:setString(month)

    local langStr = lang("GODWAR_TIP_02")
    langStr = "[color=8a5c1d,fontsize=20]" .. langStr .. "[-]"
    local richtextBg = self:getUI("bg.richtextBg")
    local richText = RichTextFactory:create(langStr, richtextBg:getContentSize().width, 0)
    richText:formatText()
    richText:setPosition(richtextBg:getContentSize().width/2+60, richtextBg:getContentSize().height - richText:getRealSize().height/2)
    richtextBg:addChild(richText)
end

return GodWarPailianDialog
