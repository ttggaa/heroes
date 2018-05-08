--
-- Author: <ligen@playcrab.com>
-- Date: 2016-10-28 15:23:29
--
local NewFormationExplainView = class("NewFormationExplainView", BasePopView)

function NewFormationExplainView:ctor(data)
    NewFormationExplainView.super.ctor(self)
end

function NewFormationExplainView:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
    end )

    self._bg = self:getUI("bg")

    self._title = self:getUI("bg.titlebg.title")
    UIUtils:setTitleFormat(self._title, 1)


    self._desName = self:getUI("bg.desName")
    self._desName:setFontName(UIUtils.ttfName)

    self._desLabel = RichTextFactory:create(lang("towertip_10"), 400, 40)
    self._desLabel:formatText()
    self._desLabel:setVerticalSpace(7)
    self._desLabel:setPosition(497, 200)
    self._bg:addChild(self._desLabel)

    local explainMc = mcMgr:createViewMC("kengdong_yindao", true, false)
    explainMc:setPosition(489, 350)
    self._bg:addChild(explainMc)
end


return NewFormationExplainView