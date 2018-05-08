--[[
    Filename:    ActivitySignDescDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-02-08 18:51:50
    Description: File description
--]]

local ActivitySignDescDialog = class("ActivitySignDescDialog", BasePopView)

function ActivitySignDescDialog:ctor()
    ActivitySignDescDialog.super.ctor(self)
end


function ActivitySignDescDialog:onInit()
    
    -- local Image_26 = self:getUI("bg.Image_26")
    -- Image_26:setColor(cc.c4b(66, 64, 66, 255))

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 6)
    -- title:setFontName(UIUtils.ttfName)
    -- -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    -- title:setFontSize(30)

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)
end

function ActivitySignDescDialog:reflashUI(data)
    

    local str = lang("RULE_TECHINIQUE")
    print("str =======", str)
    if data.str then
        str = data.str
    end
    -- " \
    -- [color=ffffff]　　在大陆的东方出现了许多异族的身影，已经有三座城池被他们接连占领，将军，我们必须守卫自己的领土，而这一切需要你的力量。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]　[-][][-][color=ffffff]1、将军需要经历15场战斗，每次胜利可以获得金币，符文材料，以及帝国的奖赏。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]2、战斗中怪兽死亡将不能继续上阵，但是可以在编组外重新选择一个代替他。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]3、战斗出现超时，则算作双方同归于尽。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]4、将军需要特别小心脚下的土地，当您踏入禁魔大地时，您的魔法值将无法得到回复。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]5、征战途中，您会遇到各种建筑，拜访他们可以获得奖励。[-][][-] \
    -- "
    self._scrollView = self:getUI("bg.ScrollView")
    local richText = RichTextFactory:create(str, self._scrollView:getContentSize().width, 0)
    richText:formatText()
    local height  = self._scrollView:getContentSize().height
    if height < richText:getRealSize().height then
        height = richText:getRealSize().height
    end
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, height))
    richText:setPosition(self._scrollView:getContentSize().width/2, self._scrollView:getInnerContainerSize().height - richText:getRealSize().height/2)
    self._scrollView:addChild(richText)
end

return ActivitySignDescDialog