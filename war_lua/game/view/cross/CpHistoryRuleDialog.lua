--[[
    Filename:    CpHistoryRuleDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local CpHistoryRuleDialog = class("CpHistoryRuleDialog", BasePopView)

function CpHistoryRuleDialog:ctor()
    CpHistoryRuleDialog.super.ctor(self)
end

function CpHistoryRuleDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("cross.CpHistoryRuleDialog")
        end
		self:close()
	end)
	
	self._cellNode = self:getUI("bg.buffCell")
	self._cellNode:setVisible(false)
	self._scroll = self:getUI("bg.scrollView")
	
	local title1 = ccui.Text:create()
	title1:setString("助战加成规则")
	title1:setFontSize(24)
	title1:setFontName(UIUtils.ttfName)
	title1:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
--	title1:setPosition(200)
	title1:setAnchorPoint(cc.p(0,0))
	self._scroll:addChild(title1)

	local title2 = ccui.Text:create()
	title2:setString("助战加成属性")
	title2:setFontName(UIUtils.ttfName)
	title2:setAnchorPoint(cc.p(0,0))
	title2:setFontSize(24)
	title2:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
	self._scroll:addChild(title2)
	
	local titleHeight = title1:getContentSize().height + 10 + title2:getContentSize().height + 30
	
	
	local rtxRule = RichTextFactory:create(lang("CP_EXTRABUFF_TIPS"), 418 )
    rtxRule:setPixelNewline(true)
	rtxRule:formatText()
	rtxRule:setVerticalSpace(3)
	rtxRule:setAnchorPoint(cc.p(0, 0))
	rtxRule:setName("rtxRule")
	self._scroll:addChild(rtxRule)
	
	local totalHeight = rtxRule:getInnerSize().height + 10
--	self._cutLine = self:getUI("bg.scrollView.cutLine")
--	totalHeight = totalHeight + self._cutLine:getContentSize().height
	
	
	local tableHeight = self:createBuffList()
	
	totalHeight = totalHeight + tableHeight + titleHeight
	
	title1:setPosition(10, totalHeight-title1:getContentSize().height-10)
	
	rtxRule:setPosition(10-rtxRule:getInnerSize().width/2, title1:getPositionY()-rtxRule:getInnerSize().height-10)
	
	title2:setPosition(10, rtxRule:getPositionY()-title2:getContentSize().height-30)
	
--	self._cutLine:setPositionY(tableHeight-5)
	self._scroll:setInnerContainerSize(cc.size(429, totalHeight))
--	self._scroll:update(1)
end

function CpHistoryRuleDialog:createBuffList()
	local tabData = clone(tab["cpBuffDes"])
	local tbBuffAdd = tab["cpSeverBuff"]
	local height = (#tabData+1)*self._cellNode:getContentSize().height+20
	
	local titleNode = self._cellNode:clone()
	titleNode:getChildByFullName("buffIcon"):setVisible(false)
	titleNode:getChildByFullName("buffNameLab"):setVisible(false)
--	nameLab:setPositionX(nameLab:getPositionX()-20)
	titleNode:getVirtualRenderer():setVisible(false)
	titleNode:setPosition(0, height-10-titleNode:getContentSize().height)
	titleNode:setVisible(true)
	self._scroll:addChild(titleNode)
	
	for i,v in ipairs(tabData) do
		local cellNode = self._cellNode:clone()
		local buffIcon = cellNode:getChildByFullName("buffIcon")
		buffIcon:loadTexture(v.icon..".png", 1)
		local nameLab = cellNode:getChildByFullName("buffNameLab")
		nameLab:setString(lang(v.name))
		local tbAddLab = {}
		for index=1, 5 do
			local addLab = cellNode:getChildByFullName("buffAdd"..index)
			table.insert(tbAddLab, addLab)
			local addValue = tbBuffAdd[index]["buff"..i]
			if i==1 or i==2 then
				addLab:setString(string.format("+%s%%", addValue*100))
			else
				addLab:setString(string.format("+%s", addValue))
			end
		end
		cellNode:getVirtualRenderer():setVisible(i%2==1)
		cellNode:setPosition(0, titleNode:getPositionY()-i*cellNode:getContentSize().height)
		cellNode:setVisible(true)
		self._scroll:addChild(cellNode)
	end
	return height
end

return CpHistoryRuleDialog