--[[
    Filename:    TeamHolyRuleDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2018-04-02 17:45:13
    Description: File description
--]]

local TeamHolyRuleDialog = class("TeamHolyRuleDialog", BasePopView)

local l_typeNameStr = {
	[1] = "守序",
	[2] = "善良",
	[3] = "中立",
	[4] = "混乱",
	[5] = "邪恶"
}

function TeamHolyRuleDialog:ctor(data)
    TeamHolyRuleDialog.super.ctor(self)
end

function TeamHolyRuleDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
	end)
	
	local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)
	
	local scroll = self:getUI("bg.ScrollView")
	local typeNode = self:getUI("typeNode")
	
	local descStr1 = lang("rune_rule")
	local descStr2 = lang("rune_rule_1")
	
	local totalHeight = 0
	
	local richText = RichTextFactory:create(descStr1, scroll:getContentSize().width-6, 0)
	richText:setPixelNewline(true)
	richText:formatText()
	richText:setVerticalSpace(3)
	richText:enablePrinter(true)
	scroll:addChild(richText)
	totalHeight = totalHeight + richText:getInnerSize().height
	
	local tbTypeNode = {}
	for i=1, 5 do
		local node = typeNode:clone()
		local typeImg = node:getChildByName("typeImg")
		typeImg:loadTexture("teamHoly_typeImg"..i..".png", 1)
		local typeLab = node:getChildByName("typeLab")
		typeLab:setString(l_typeNameStr[i])
		scroll:addChild(node)
		table.insert(tbTypeNode, node)
		totalHeight = totalHeight + node:getContentSize().height
	end
	
	local richText2 = RichTextFactory:create(descStr2, scroll:getContentSize().width-6, 0)
	richText2:setPixelNewline(true)
	richText2:formatText()
	richText2:setVerticalSpace(3)
	richText2:enablePrinter(true)
	scroll:addChild(richText2)
	
	totalHeight = totalHeight + richText2:getInnerSize().height
	
	if scroll:getInnerContainerSize().height<totalHeight then
		scroll:setInnerContainerSize(cc.size(scroll:getContentSize().width, totalHeight))
	end
	local containerHeight = scroll:getInnerContainerSize().height
	richText:setPosition(cc.p(scroll:getContentSize().width/2, containerHeight - richText:getInnerSize().height/2))
	local posY = containerHeight - richText:getInnerSize().height
	for i,v in ipairs(tbTypeNode) do
		v:setPosition(cc.p(0, posY - v:getContentSize().height))
		posY = posY - v:getContentSize().height
	end
	richText2:setPosition(cc.p(scroll:getContentSize().width/2, posY - richText2:getInnerSize().height/2))
end

return TeamHolyRuleDialog