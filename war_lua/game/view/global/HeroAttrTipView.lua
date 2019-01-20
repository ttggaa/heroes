--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-01-24 10:50:52
--
local HeroAttrTipView = class("HeroAttrTipView", BaseLayer)
function HeroAttrTipView:ctor(params)
    HeroAttrTipView.super.ctor(self)
end
local heroDesMap = {"ATK","DEF","INT","ACK"}
function HeroAttrTipView:onInit()
	local desLab = self:getUI("bg.basicInfo.desLab")
	desLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	for i=1,4 do
		local lab = self:getUI("bg.basicInfo.desLab_" .. i)
		if lab then
			lab:setString(lang("HERO_ATTRIBUTE_" .. heroDesMap[i]))
		end
	end
	self._bg = self:getUI("bg")
end

function HeroAttrTipView:setAttrs( totalAttrs )
	if not totalAttrs or not next(totalAttrs) then return end
	dump(totalAttrs)
	-- totalAttrs[1],totalAttrs[3] = totalAttrs[3],totalAttrs[1]
	for i,attrs in ipairs(totalAttrs) do
		local cell = self:getUI("bg.attrCell" .. i)
		for k=1,11 do
			local attrLab = self:getUI("bg.attrCell" .. k .. ".attr" .. i)
			local attrNum = attrs["attr" .. k]
			if attrNum < 0.01 then attrNum = 0 end
			attrLab:setString(attrNum)
		end
	end

	-- 隐藏英雄刻印
	-- 如果英雄值为0 隐藏一条
	-- local rand = GRandom(1)
	-- print("rand....",rand)
	self._initPosY = {}
	-- if true then
	-- 	local children = self:getUI("bg"):getChildren()
	-- 	for k,v in pairs(children) do
	-- 		if not self._initPosY[v:getName()] then
	-- 			self._initPosY[v:getName()] = v:getPositionY()
	-- 		end
	-- 		if v:getName() ~= "attrCell6" then
	-- 			v:setPositionY(v:getPositionY()-34)
	-- 		end
	-- 	end
	-- 	self:getUI("bg.attrCell8"):setVisible(false)
	-- 	self._bg:setContentSize(cc.size(824,458-34))
	-- 	local roundBounder = self:getUI("bg.roundBounder")
	-- 	roundBounder:setContentSize(cc.size(780,408-34))
	-- 	roundBounder:setPositionY(26)
	-- end
end
return HeroAttrTipView