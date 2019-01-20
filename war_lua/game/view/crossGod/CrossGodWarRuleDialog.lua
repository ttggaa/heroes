--[[
	Filename:    CrossGodWarRuleDialog.lua
	Author:      <qiaohuan@playcrab.com>
	Datetime:    2017-05-04 21:41:27
	Description: File description
--]]

-- 规则
local CrossGodWarRuleDialog = class("CrossGodWarRuleDialog",BasePopView)
function CrossGodWarRuleDialog:ctor()
	CrossGodWarRuleDialog.super.ctor(self)
end

-- 初始化UI后会调用, 有需要请覆盖
function CrossGodWarRuleDialog:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
		self:close()
	end)

	self._scrollView = self:getUI("bg.scrollView")
	self._scrollView:setBounceEnabled(true)

	local title = self:getUI("bg.headBg.title")
	title:setFontName(UIUtils.ttfName)
	UIUtils:setTitleFormat(title,6)

	local roleNode = self:getUI("bg.roleNode")
	roleNode:setVisible(true)

	local dialogLabel = cc.Label:createWithTTF("领主大人，还有什么不明白吗？", UIUtils.ttfName_Title, 20)
	dialogLabel:setMaxLineWidth(145)
	dialogLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
	dialogLabel:setLineHeight(30)
	dialogLabel:setPosition(279, 117)
	roleNode:addChild(dialogLabel)

	local detailBtn = roleNode:getChildByFullName("detailBtn")
	detailBtn:setTitleFontSize(22)
	self:registerClickEvent(detailBtn, function ()
--		self._viewMgr:showTip("界面等美术")
		self._viewMgr:showDialog("crossGod.CrossGodWarShowTuDialog", {}, true)
	end)

	self._rankCell = self:getUI("bg.rankCell")

	self._rankCell:setVisible(false)
	-- 文字原型
	self._textPro = ccui.Text:create()
	self._textPro:setString("")
	self._textPro:setAnchorPoint(0,1)
	self._textPro:setPosition(0,0)
	self._textPro:setFontSize(22)
	self._textPro:setFontName(UIUtils.ttfName)
	self._textPro:setTextColor(cc.c4b(255,110,59,255))

	local maxHeight = 0

	local scrollBgH = self:generateRanks()
	maxHeight = maxHeight+scrollBgH

	local scrollW = self._scrollView:getInnerContainerSize().width

	-- 增加富文本
	local rtxStr = lang("CROSSFIGHT_RULE")
	rtxStr = string.gsub(rtxStr,"ffffff","462800")
	local rtx = RichTextFactory:create(rtxStr,418,0)
	rtx:setPixelNewline(true)
	rtx:formatText()
	rtx:setVerticalSpace(3)
	rtx:setAnchorPoint(cc.p(0,0))
	local w = rtx:getInnerSize().width
	local h = rtx:getVirtualRendererSize().height
	rtx:setName("rtx")
	rtx:setPosition(-w* 0.5+10,maxHeight + 30)
	self._scrollView:addChild(rtx)
	maxHeight = maxHeight+h +30

	roleNode:removeFromParent()
	roleNode:setPosition(0, maxHeight + 10)
	self._scrollView:addChild(roleNode)
	maxHeight = maxHeight + roleNode:getContentSize().height + 10

	self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
end

function CrossGodWarRuleDialog:generateRanks()
	local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
	local tabRewardData = tab.crossFightRank
	local bgHeight = #tabRewardData * itemH
	
	local infoStartPos = 160
	local rewardSpace = 100
	for k,v in ipairs(tabRewardData) do
		local item = self._rankCell:clone()
		item:setVisible(true)
		item:setOpacity(155)
		item:setPosition(cc.p(-25, bgHeight - itemH*k-3))
		if k%2 == 0 then
			item:getVirtualRenderer():setVisible(false)
		end
		local titleLab = item:getChildByName("rankRange")
		local rankStr = ""
		if v.rank[1] == v.rank[2] then
			rankStr = string.format("第%d名", v.rank[1])
		else
			rankStr = string.format("第%d~%d名", v.rank[1], v.rank[2])
		end
		titleLab:setString(rankStr)
		local rewardData = v.reward
		for i = 1, #rewardData do
			local cData = rewardData[i]

			local icon = nil
			local iconWidth = 30
			if cData[1] == "tool" then
				local iconPath = tab:Tool(cData[2]).art
				icon = cc.Sprite:createWithSpriteFrameName(iconPath .. ".png")
			elseif cData[1] == "avatarFrame" then
				local itemId = cData[2]
				local itemData = tab:AvatarFrame(tonumber(itemId))
				if not itemData then
					print("=====AvatarFrame have no id==",itemId)
					itemData = tab.tool[itemId]
				end
				local param = {itemId = cData[2], num = cData[3], itemData = itemData}
				icon = IconUtils:createHeadFrameIconById(param)
				icon:setAnchorPoint(0.5, 0.5)
			elseif cData[1] == "heroShadow" then
				icon = IconUtils:createShadowIcon({itemData = tab.heroShadow[cData[2]]})
				local nameLab = icon:getChildByFullName("iconColor.nameLab")
				icon:setAnchorPoint(0.5, 0.5)
				nameLab:setVisible(false)
			else
				local iconPath = IconUtils.resImgMap[cData[1]]

				if iconPath == nil then
					local itemId = tonumber(IconUtils.iconIdMap[cData[1]])
					local toolD = tab:Tool(itemId)
					iconPath = IconUtils.iconPath .. toolD.art .. ".png"
					icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
				end
				icon = cc.Sprite:createWithSpriteFrameName(iconPath)
			end
			icon:setScale(iconWidth / icon:getContentSize().width)
			icon:setPosition(infoStartPos + (i - 1)*rewardSpace, 17)
			item:addChild(icon)

			local countTxt = tostring(cData[3])
			local rewardCount = cc.Label:createWithTTF("x" .. countTxt, UIUtils.ttfName, 20) 
			rewardCount:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
			rewardCount:setPosition(infoStartPos + (i - 1)*rewardSpace + rewardCount:getContentSize().width*0.5 + 22, 17)
			item:addChild(rewardCount)
		end
		
		self._scrollView:addChild(item)
	end
	
	bgHeight = bgHeight - 20
	return bgHeight
end

return CrossGodWarRuleDialog