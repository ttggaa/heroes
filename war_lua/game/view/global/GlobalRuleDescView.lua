--[[
    Filename:    GlobalRuleDescView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-4-18 17:50:10
    Description: 通用规则说明界面
--]]

local GlobalRuleDescView = class("GlobalRuleDescView", BasePopView)

function GlobalRuleDescView:ctor()
    GlobalRuleDescView.super.ctor(self)
end


function GlobalRuleDescView:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)

    self:registerClickEventByName("bg.closeBtn", function ()
        UIUtils:reloadLuaFile("global.GlobalRuleDescView")
        self:close()
    end)
end

function GlobalRuleDescView:reflashUI(data)
    local str = data.desc
    if string.find(str, "color=") == nil then
        str = "[color=000000]".. str .."[-]"
    end
  
    self._scrollView = self:getUI("bg.ScrollView")
    self._scrollView:setBounceEnabled(true)

    local listWid, listHgt = self._scrollView:getContentSize().width, self._scrollView:getContentSize().height
    local richText = RichTextFactory:create(str, listWid - 20, 0)
    richText:setPixelNewline(true)
    richText:formatText()

    local curHgt = listHgt
    if listHgt < richText:getRealSize().height then
        curHgt = richText:getRealSize().height
    end
    
    self._scrollView:setInnerContainerSize(cc.size(listWid, curHgt))
    richText:setPosition(listWid/2, self._scrollView:getInnerContainerSize().height - richText:getRealSize().height/2)
    self._scrollView:addChild(richText) 
end

return GlobalRuleDescView