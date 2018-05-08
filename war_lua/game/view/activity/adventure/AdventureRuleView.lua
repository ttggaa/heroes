--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-10-24 21:34:46
--
local AdventureRuleView = class("AdventureRuleView",BasePopView)
function AdventureRuleView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function AdventureRuleView:onInit()
	self:registerClickEventByName("bg.closeBtn",function( )
		self:close()
		UIUtils:reloadLuaFile("activity.adventure.AdventureRuleView")
	end)
	self._title = self:getUI("bg.headBg.title")
    -- self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)

	local desLab = self:getUI("bg.desLab")
	desLab:setString("")
    local scrollView = self:getUI("bg.scrollView")
    scrollView:setBounceEnabled(true)
    local scrollHeight = scrollView:getInnerContainerSize().height
    local rtxStr = lang("dafuweng_rule")
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
function AdventureRuleView:reflashUI(data)

end

return AdventureRuleView