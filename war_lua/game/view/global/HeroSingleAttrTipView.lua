--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-02-13 14:26:57
--
-- 英雄属性 回魔 魔法 回蓝 魔法cd
local HeroSingleAttrTipView = class("HeroSingleAttrTipView", BaseLayer)
function HeroSingleAttrTipView:ctor(params)
    HeroSingleAttrTipView.super.ctor(self)
end

function HeroSingleAttrTipView:onInit()
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
	self._initPos["attrCell7"] = self._initPos["attrCell6"]+34
end

function HeroSingleAttrTipView:setAttrs( totalAttrs )
	-- dump(totalAttrs,"单个板子")
	if not totalAttrs or not next(totalAttrs) then return end
	-- dump(totalAttrs)
	-- totalAttrs[1],totalAttrs[3] = totalAttrs[3],totalAttrs[1]
	self._name:setString(totalAttrs.kind or totalAttrs.name or "")
	self._desLab:setString(totalAttrs.des or "")
	self:getUI("bg.attrCell1.des"):setString("基础" .. (totalAttrs.kind or totalAttrs.name or ""))
	self:getUI("bg.attrCell6.des"):setString(totalAttrs.subDes or "")
	if totalAttrs.art then
		self._attImg:loadTexture(totalAttrs.art,1)
	end
	local attrs = {}
	for i=1,5 do
		attrs["attr" .. i] = totalAttrs["attr" .. i]
	end
	attrs["attr6"] = totalAttrs["attr"] or totalAttrs["attr6"]
	local magicTalent = totalAttrs["attr7"]
	local magicCell = self:getUI("bg.attrCell7")
	print("魔法天赋-------------",magicTalent)
	if magicTalent then -- 增加魔法天赋
		attrs["attr7"] = magicTalent
		if not magicCell then 
			magicCell = self:getUI("bg.attrCell4"):clone() 
			magicCell:setName("attrCell7")
			self:getUI("bg"):addChild(magicCell)
		end
		local attrDes = self:getUI("bg.attrCell7.des")
		attrDes:setString("魔法天赋")
		
		magicCell:setVisible(true)
		magicCell:setBackGroundImageOpacity(0)
	else 
		if magicCell then 
			magicCell:setVisible(false)
		end
		local col_1 = self:getUI("bg.basicInfo.col_1")
		local roundBounder = self:getUI("bg.roundBounder")
		col_1:setContentSize(cc.size(2,307))
		roundBounder:setContentSize(cc.size(240,307))
		roundBounder:setPositionY(26)
	end
	local cellNum = magicTalent and 7 or 6
	local bgAddHeight = magicTalent and 34 or 0
	for k=1,cellNum do
		local attrLab = self:getUI("bg.attrCell" .. k .. ".attr1")
		local attrNum = tonumber(attrs["attr" .. k]) or 0
		if attrNum and attrNum < 0.01 then attrNum = 0 end
		attrNum = tonumber(string.format("%.2f",attrNum))

		-- attrNum = attrNum*10
		if k ~= 1 and k ~= 6 and attrNum and attrNum > 0 then
			attrLab:setString((totalAttrs.negative or "") .. (attrNum or "0") .. (totalAttrs.unit or ""))
		else
			attrLab:setString((attrNum or "0") .. (totalAttrs.unit or ""))
		end
	end
	-- 额外描述
	local newDes = self._bg:getChildByName("newDes")
	local averageMCDLab = self._bg:getChildByName("averageMCDLab")
	local newSLotDes = self._bg:getChildByName("newSLotDes")
	local averageSlotMCDLab = self._bg:getChildByName("averageSlotMCDLab")
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
			self._bg:addChild(averageMCDLab)
		else
			averageMCDLab:setVisible(true)
		end
		averageMCDLab:setString(totalAttrs.averageMCD .. (totalAttrs.unit or "/秒") )
		UIUtils:center2Widget(newDes,averageMCDLab,140,0)
		self._bg:setContentSize(cc.size(290,380+bgAddHeight))
		for k,v in pairs(self._children) do
			v:setPositionY(self._initPos[v:getName()]+20+bgAddHeight)
		end

		-- 法术刻印
		if totalAttrs.slotMCD then
			if not newSLotDes then
				newSLotDes = ccui.Text:create()
				newSLotDes:setFontSize(20)
				newSLotDes:setFontName(UIUtils.ttfName)
				newSLotDes:setPositionY(25)
				newSLotDes:setString("法术消耗(刻印)：")
				newSLotDes:setName("newSLotDes")
				self._bg:addChild(newSLotDes)
			else
				newSLotDes:setVisible(true)
			end
			if not averageSlotMCDLab then
				averageSlotMCDLab = ccui.Text:create()
				averageSlotMCDLab:setFontSize(20)
				averageSlotMCDLab:setFontName(UIUtils.ttfName)
				averageSlotMCDLab:setPositionY(25)
				averageSlotMCDLab:setName("averageSlotMCDLab")
				self._bg:addChild(averageSlotMCDLab)
			else
				averageSlotMCDLab:setVisible(true)
			end
			averageSlotMCDLab:setString((totalAttrs.averageMCD+totalAttrs.slotMCD) .. (totalAttrs.unit or "/秒") )
			UIUtils:center2Widget(newSLotDes,averageSlotMCDLab,140,0)
			self._bg:setContentSize(cc.size(290,400+bgAddHeight))
			for k,v in pairs(self._children) do
				v:setPositionY(self._initPos[v:getName()]+40+bgAddHeight)
			end
			averageMCDLab:setPositionY(50)
			newDes:setPositionY(50)

		else
			if newSLotDes then
				newSLotDes:setVisible(false)
			end
			if averageSlotMCDLab then
				averageSlotMCDLab:setVisible(false)
			end
			averageMCDLab:setPositionY(25)
			newDes:setPositionY(25)
		end
	else
		if newDes then
			newDes:setVisible(false)
		end
		if averageMCDLab then
			averageMCDLab:setVisible(false)
		end
		if newSLotDes then
			newSLotDes:setVisible(false)
		end
		if averageSlotMCDLab then
			averageSlotMCDLab:setVisible(false)
		end
		self._bg:setContentSize(cc.size(290,360+bgAddHeight))
		for k,v in pairs(self._children) do
			v:setPositionY(self._initPos[v:getName()]+bgAddHeight)
		end
		if magicTalent then
			self:getUI("bg.attrCell6"):setPositionY(self._initPos["attrCell6"])
			self:getUI("bg.attrCell7"):setPositionY(self._initPos["attrCell7"])
		end
		local col_1 = self:getUI("bg.basicInfo.col_1")
		local roundBounder = self:getUI("bg.roundBounder")
		col_1:setContentSize(cc.size(2,307+bgAddHeight))
		roundBounder:setContentSize(cc.size(240,307+bgAddHeight))
		roundBounder:setPositionY(26)
	end
end
return HeroSingleAttrTipView