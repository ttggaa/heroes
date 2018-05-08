--
-- Author: <ligen@playcrab.com>
-- Date: 2016-09-08 20:05:08
--

local CloudCityRuleView = class("CloudCityRuleView", BasePopView)

function CloudCityRuleView:ctor()
    CloudCityRuleView.super.ctor(self)
end


function CloudCityRuleView:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)
end

function CloudCityRuleView:reflashUI()
    self._showDesc = lang("towerfloor_rule")

    self._scrollView = self:getUI("bg.ScrollView")
    self._scrollView:setBounceEnabled(true)
    local richText = RichTextFactory:create(self._showDesc, self._scrollView:getContentSize().width, 0)
    richText:formatText()
    local height  = self._scrollView:getContentSize().height
    if height < richText:getRealSize().height then
        height = richText:getRealSize().height
    end
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, height))
    richText:setPosition(self._scrollView:getContentSize().width/2, self._scrollView:getInnerContainerSize().height - richText:getRealSize().height/2)
    self._scrollView:addChild(richText)
end

return CloudCityRuleView