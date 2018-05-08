--
-- Author: huangguofang
-- Date: 2017-12-18 16:26:32
--

local HeroBiographyTipView = class("HeroBiographyTipView", BaseView)

function HeroBiographyTipView:ctor()
    HeroBiographyTipView.super.ctor(self)
    self._heroModel = self._modelMgr:getModel("HeroModel")
end

function HeroBiographyTipView:onInit()
    self._imageBg = self:getUI("bg.imageBg")
    self._contentSizeWidth = self._imageBg:getContentSize().width / 2.0
    local labelDes = self:getUI("bg.imageBg.labelDes")
    local labelValue = self:getUI("bg.imageBg.labelValue")
    local heroName = self:getUI("bg.imageBg.heroName")
    self:refreshUI()
    self._imageBg:setPositionX(-self._contentSizeWidth)
    self._imageBg:setVisible(false)
    -- self._imageBgArr = {}
end

function HeroBiographyTipView:refreshUI()
    local bioData = self._heroModel:getCurrBioTipsData()
    -- self:setVisible(true)
    if not bioData then return end 
    -- dump(bioData,"bioData==>",5)   
    local time = 0
    for k,v in pairs(bioData) do
    	-- dump(v,"vvv",5)
    	local heroData = tab:Hero(tonumber(k))
    	for kk,vv in pairs(v) do
	    	local imageBg = self._imageBg:clone()
	    	imageBg:setVisible(true)
	    	imageBg:setPositionX(-self._contentSizeWidth)
	    	self:addChild(imageBg)
	    	local labelDes = imageBg:getChildByFullName("labelDes")
			local labelValue = imageBg:getChildByFullName("labelValue")			
	    	labelDes:setString("")
			labelValue:setString("")
	    	local heroName = imageBg:getChildByFullName("heroName")
	    	heroName:setColor(cc.c4b(255,252,217,255))
	    	heroName:enable2Color(1,cc.c4b(253,204,87,255))
			heroName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)			

	    	local bioTbData = tab:HeroBio(tonumber(kk))
	    	local bioCondtips = (bioTbData and bioTbData.bioCondtips) and bioTbData.bioCondtips[1] or ""

	    	local bioCount = bioTbData and bioTbData.bioCount or {}
	    	local sumNum = bioCount[2] or 0
	    	local comNum = 0
	    	local isFinished = (vv.conds and vv.conds["2"]) and vv.conds["2"]["finish"] or 0
	    	if 1 == tonumber(isFinished) then
	    		comNum = sumNum
	    	else
		    	local valueStr = (vv.conds and vv.conds["2"]) and vv.conds["2"]["value"] or ""
		    	-- print("===========valueStr====",valueStr)
		    	if bioCount[1] and 1 == bioCount[1] then
					comNum = tonumber(valueStr) or 0
		    	elseif bioCount[1] and 2 == bioCount[1] then
		    		local numArr = string.split(valueStr, ",")
		    		-- dump(numArr,"numArr==>",4)
	                comNum = table.nums(numArr)
		    	end
		    	comNum = comNum <= sumNum and comNum or sumNum
	    	end

			heroName:setString(lang(heroData.heroname))

			labelValue:setPositionX(labelDes:getPositionX() + labelDes:getContentSize().width +5)
			local str = lang(bioCondtips) --"[color=ffffff,fontsize=18,outlinecolor=3c1e0aff,outlinesize=1]通关5次第15关，僧侣、神灯[-][][-][color=ffffff,fontsize=18,outlinecolor=3c1e0aff,outlinesize=1]和天使上阵且不死[-][color={$color},fontsize=18,outlinecolor=3c1e0aff,outlinesize=1]　{$cond}[-][]"
			local condColor = comNum >= sumNum and "27f73a" or "fb2f2c"			
	    	comNum = self:getStringByNum(comNum)
	    	sumNum = self:getStringByNum(sumNum)
			str = string.gsub(str,"{$color}",condColor)
			str = string.gsub(str,"{$cond}",comNum .. "/" .. sumNum)
			if not string.find(str,"[-]") then
				str = "[color=ffffff,fontsize=20]" .. str .. "[-]"
			end
			local label1 = RichTextFactory:create(str, 400, 40)
		    label1:formatText()
		    -- label1:setName("labelTxt")
		    label1:setPosition(220,40)
		    imageBg:addChild(label1,11)

			imageBg:runAction(cc.Sequence:create(
				cc.DelayTime:create(time),
		        cc.MoveTo:create(0.3, cc.p(self._contentSizeWidth, self._imageBg:getPositionY())),
		        cc.DelayTime:create(1.0), 
		        cc.MoveTo:create(0.3, cc.p(-self._contentSizeWidth, self._imageBg:getPositionY())),
		        cc.CallFunc:create(function()
		            imageBg:removeFromParent()
		            imageBg = nil
		    end)))
		    time = time + 1.6
		    -- break
    	end
    	
    end

    -- self._imageBg:runAction(cc.Sequence:create(
    --     cc.DelayTime:create(time), 
    --     cc.CallFunc:create(function()
    --         -- self._imageBg:setVisible(false)
    -- end)))

end

-- 过万显示
function HeroBiographyTipView:getStringByNum( num)
    if not num then return "" end
    local numStr = ""
    if num > 9999 then
        local num1 = math.floor(num/1000)
        numStr = num1/10 .. "万"        
    else
        numStr = num
    end
    return numStr
end

return HeroBiographyTipView