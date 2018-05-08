--[[
    Filename:    AcIntegralPointRuleView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2017-07-18 16:29:12
    Description: File description
--]]

local AcIntegralPointRuleView = class("AcIntegralPointRuleView", BasePopView)

function AcIntegralPointRuleView:ctor()
    AcIntegralPointRuleView.super.ctor(self)
end


function AcIntegralPointRuleView:onInit()

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 6)

    self._scrollView = self:getUI("bg.ScrollView")

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)
end

function AcIntegralPointRuleView:reflashUI(data)
    local desStr = lang("qingdianrule")
    if data.des then
        desStr = data.des
    end
    local richText = RichTextFactory:create(desStr, self._scrollView:getContentSize().width, 0)
    richText:formatText()
    local height  = self._scrollView:getContentSize().height
    if height < richText:getRealSize().height then
        height = richText:getRealSize().height
    end
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, height))
    richText:setPosition(self._scrollView:getContentSize().width / 2, self._scrollView:getInnerContainerSize().height - richText:getRealSize().height / 2)
    self._scrollView:addChild(richText)
end

return AcIntegralPointRuleView