--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-09-14 20:45:45
--
local SpellBookRuleView = class("SpellBookRuleView",BasePopView)
function SpellBookRuleView:ctor(param)
    self.super.ctor(self)
    self._titleDes = param and param.title
    self._des = param and param.des
end

-- 初始化UI后会调用, 有需要请覆盖
function SpellBookRuleView:onInit()
	self:registerClickEventByName("bg.closeBtn",function( )
		self:close()
		UIUtils:reloadLuaFile("spellbook.SpellBookRuleView")
	end)
	self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    self._title:setString(self._titleDes or "")
    UIUtils:setTitleFormat(self._title,6)

    local scrollView = self:getUI("bg.scrollView")
    scrollView:setBounceEnabled(true)
    local scrollHeight = scrollView:getInnerContainerSize().height
    local rtxStr = self._des or lang("SHOPSKILLBOOK_TIPS2")
    -- rtxStr = string.gsub(rtxStr,"6d98d8","462800")   --
	local rtx = RichTextFactory:create(rtxStr,430,340)
    -- rtx:enablePrinter(true)
	rtx:formatText()

    -- rtx:setPrintInterval(10)
    -- rtx:setVerticalSpace(5)
    -- rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    local offsetY = 0
    if h > scrollHeight then
        scrollView:setInnerContainerSize(cc.size(440,h))
    else
        offsetY = scrollHeight - h
    end
    rtx:setPosition(cc.p(w/2+10,h/2+offsetY))
    UIUtils:alignRichText(rtx,{hAlign = "left"})
    rtx:setName("rtx")
    scrollView:addChild(rtx)
end

-- 接收自定义消息
function SpellBookRuleView:reflashUI(data)

end

return SpellBookRuleView