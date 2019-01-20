
--author lannan

local MFAlchemyLogDialog = class("MFAlchemyLogDialog", BasePopView)

function MFAlchemyLogDialog:ctor()
    MFAlchemyLogDialog.super.ctor(self)
	self._alchemyModel = self._modelMgr:getModel("AlchemyModel")
end

function MFAlchemyLogDialog:onInit()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
	end)
	
	local title = self:getUI("bg.titleBg.title")
	title:setString("炼金记录")
	UIUtils:setTitleFormat(title,6)
	
	self:loadLogInfo()
end

function MFAlchemyLogDialog:loadLogInfo()
	local logData = self._alchemyModel:getAlchemyReport()
	local nothingUI = self:getUI("bg.nothing")
	local scroll = self:getUI("bg.scroll")
	scroll:removeAllChildren()
	if logData and table.nums(logData)>0 then
		local tbNode = {}
		local totalHeight = 0
		for i,v in ipairs(logData) do
--			local str = string.gsub(lang("MF_THX"), "{$num}", table.nums(thankList))
			local timeStr = TimeUtils.getDateString(v.endTime, "%m-%d %H:%M")
			local formulaData = tab.alchemyPlan[v.aid]
			local rtxStr = lang("alchemy_Record1")
			rtxStr = string.gsub(rtxStr, "{$time}", timeStr)
			rtxStr = string.gsub(rtxStr, "{$name1}", lang(formulaData.planName))
			local reward = json.decode(v.gain)
			local itemData
			if reward[1] == "tool" then
				itemData = tab.tool[reward[2]]
			else
				local id = IconUtils.iconIdMap[reward[1]]
				itemData = tab.tool[id]
			end
			rtxStr = string.gsub(rtxStr, "{$name2}", lang(itemData.name))
			rtxStr = string.gsub(rtxStr, "{$name3}", reward[3])
			local rtx = RichTextFactory:create(rtxStr,350,0)
			rtx:setPixelNewline(true)
			rtx:formatText()
			rtx:setVerticalSpace(3)
--			rtx:setAnchorPoint(cc.p(0,0))
			local w = rtx:getInnerSize().width
			local h = rtx:getVirtualRendererSize().height
			totalHeight = totalHeight + h + 6
			rtx:setName("rtx")
			scroll:addChild(rtx)
			table.insert(tbNode, rtx)
		end
		local innerHeight = scroll:getInnerContainerSize().height
		if totalHeight>innerHeight then
			scroll:setInnerContainerSize(cc.size(scroll:getContentSize().width, totalHeight))
			innerHeight = totalHeight
		end
		local posY = innerHeight
		for i,v in ipairs(tbNode) do
			posY = posY - v:getInnerSize().height/2 - 3
			v:setPosition(cc.p(scroll:getContentSize().width/2, posY))
			posY = posY - v:getInnerSize().height/2 - 3
		end
		scroll:setVisible(true)
		nothingUI:setVisible(false)
	else
		scroll:setVisible(false)
		nothingUI:setVisible(true)
	end
end

return MFAlchemyLogDialog