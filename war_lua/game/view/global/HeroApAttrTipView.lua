--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-08-10 18:27:08
--

local HeroApAttrTipView = class("HeroApAttrTipView", BaseLayer)

function HeroApAttrTipView:ctor(params)
    HeroApAttrTipView.super.ctor(self)
end

function HeroApAttrTipView:onInit()
	self._name 	 = self:getUI("bg.basicInfo.name")
	self._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._desLab = self:getUI("bg.basicInfo.desLab")
	self._desLab:getVirtualRenderer():setMaxLineWidth(100)
	self._attImg = self:getUI("bg.basicInfo.attImg")

	self._bg = self:getUI("bg")
	self._children = self._bg:getChildren()
	self._initPos = {}
	for k,v in pairs(self._children) do
		self._initPos[v:getName()] = v:getPositionY()
	end
end

function HeroApAttrTipView:setAttrs( totalAttrs )
	-- dump(totalAttrs,"单个板子")
	if not totalAttrs or not next(totalAttrs) then return end
	-- dump(totalAttrs)
	-- totalAttrs[1],totalAttrs[3] = totalAttrs[3],totalAttrs[1]
	self._name:setString(totalAttrs.kind or totalAttrs.name or "")
	self._desLab:setString(totalAttrs.des or "")
	self:getUI("bg.attrCell1.des"):setString("基础" .. (totalAttrs.kind or totalAttrs.name or ""))
	self:getUI("bg.attrCell5.des"):setString(totalAttrs.subDes or "")
	if totalAttrs.art then
		self._attImg:loadTexture(totalAttrs.art,1)
	end
	local attrs = {}
	for i=1,6 do
		attrs["attr" .. i] = totalAttrs["attr" .. i]
	end
	-- attrs["attr5"] = totalAttrs["attr"]
	for k=1,6 do
		local attrLab = self:getUI("bg.attrCell" .. k .. ".attr1")
		local attrNum = tonumber(attrs["attr" .. k]) or 0
		if attrNum and attrNum < 0.01 then attrNum = 0 end
		attrNum = string.format("%.2f",attrNum*0.1)
		attrNum = attrNum*10
		if k ~= 1 and attrNum and attrNum > 0 then
			attrLab:setString((totalAttrs.negative or "") .. (attrNum or "0") .. (totalAttrs.unit or ""))
		else
			attrLab:setString((attrNum or "0") .. (totalAttrs.unit or ""))
		end
	end
	-- 额外描述
	local newDes = self._bg:getChildByName("newDes")
	local averageMCDLab = self._bg:getChildByName("averageMCDLab")
	if totalAttrs.averageMCD then
		print("mcd average is ",totalAttrs.averageMCD)
		if not newDes then
			newDes = ccui.Text:create()
			newDes:setFontSize(20)
			newDes:setFontName(UIUtils.ttfName)
			newDes:setPositionY(25)
			newDes:setString("法术消耗：")
			newDes:setName("newDes")
			self._bg:addChild(newDes)
		else
			newDes:setVisible(true)
		end
		if not averageMCDLab then
			averageMCDLab = ccui.Text:create()
			averageMCDLab:setFontSize(20)
			averageMCDLab:setFontName(UIUtils.ttfName)
			averageMCDLab:setPositionY(25)
			averageMCDLab:setName("averageMCDLab")
			averageMCDLab:setString(totalAttrs.averageMCD .. (totalAttrs.unit or "/秒") )
			self._bg:addChild(averageMCDLab)
		else
			averageMCDLab:setVisible(true)
		end
		UIUtils:center2Widget(newDes,averageMCDLab,140,0)
		self._bg:setContentSize(cc.size(290,320))
		for k,v in pairs(self._children) do
			v:setPositionY(self._initPos[v:getName()]+20)
		end
	else
		if newDes then
			newDes:setVisible(false)
		end
		if averageMCDLab then
			averageMCDLab:setVisible(false)
		end
		self._bg:setContentSize(cc.size(290,320))
		for k,v in pairs(self._children) do
			v:setPositionY(self._initPos[v:getName()])
		end
	end

	-- 如果英雄值为0 隐藏一条
	-- local rand = GRandom(1)
	-- print("rand....",rand)
	self._initPosY = {}
	if tonumber(attrs["attr3"]) == 0 then
		local children = self:getUI("bg"):getChildren()
		for k,v in pairs(children) do
			if not self._initPosY[v:getName()] then
				self._initPosY[v:getName()] = v:getPositionY()
			end
			v:setPositionY(v:getPositionY()-34)
		end
		self:getUI("bg.attrCell3"):setVisible(false)
		local cell4 = self:getUI("bg.attrCell4")
		cell4:setPositionY(cell4:getPositionY()+32)
		cell4:setBackGroundImageOpacity(255)

		local cell5 = self:getUI("bg.attrCell5")
		cell5:setPositionY(cell5:getPositionY()+33)

		local cell6 = self:getUI("bg.attrCell6")
		cell6:setPositionY(cell6:getPositionY()+32)
		cell6:setBackGroundImageOpacity(0)

		local col_1 = self:getUI("bg.basicInfo.col_1")
		col_1:setContentSize(cc.size(2,268))
		self._bg:setContentSize(cc.size(290,302))
		local roundBounder = self:getUI("bg.roundBounder")
		roundBounder:setContentSize(cc.size(240,273))
		roundBounder:setPositionY(19)
	else
		local children = self:getUI("bg"):getChildren()
		for k,v in pairs(children) do
			if self._initPosY[v:getName()] then
				v:setPositionY(self._initPosY[v:getName()] or v:getPositionY())
			end
		end
		self:getUI("bg.attrCell3"):setVisible(true)
		local cell4 = self:getUI("bg.attrCell4")
		-- cell4:setPositionY(cell4:getPositionY()+32)
		cell4:setBackGroundImageOpacity(0)

		local roundBounder = self:getUI("bg.roundBounder")
		roundBounder:setContentSize(cc.size(240,305))
		roundBounder:setPositionY(19)

		local col_1 = self:getUI("bg.basicInfo.col_1")
		col_1:setContentSize(cc.size(2,302))
	end
end
return HeroApAttrTipView