--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-04-11 17:29:31
--

local nameColorTab = {
	[2] = {color = cc.c3b(194, 255, 174),color2 = cc.c4b(2,188,24,255),outColor = cc.c3b(4, 73, 0)},
	[3] = {color = cc.c3b(195, 244, 255),color2 = cc.c4b(36,156,255,255),outColor = cc.c3b(13, 45, 133)},
	[4] = {color = cc.c3b(238, 185, 255),color2 = cc.c4b(222,86,255,255),outColor = cc.c3b(96, 0, 166)},
	[5] = {color = cc.c3b(255, 220, 203),color2 = cc.c4b(254,162,76,255),outColor = cc.c3b(93, 54, 1)},
}

local TreasureUpStarLayer = class("TreasureUpStarLayer",BaseLayer)
function TreasureUpStarLayer:ctor(param)
    self.super.ctor(self)
    self._tModel = self._modelMgr:getModel("TreasureModel")
    self._parent = param and param.parent
    -- dump(param)
    self._preStarNum = {}
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureUpStarLayer:onInit()
	self._bg = self:getUI("bg")
	self._bg:setSwallowTouches(false)
	self._layer = self:getUI("bg.layer")

	self._starfragPanel = self:getUI("bg.layer.starfragPanel")
	self._starfragTenPanel = self:getUI("bg.layer.starfragTenPanel")
	self._treasureName = self:getUI("bg.layer.treasureNode.treasureName")
	self._stage = self:getUI("bg.layer.treasureNode.stage")
	self._stage:setVisible(false)

	self._star = self:getUI("bg.layer.star")
	
	-- attrDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	
	-- 属性
	self._attPanel = self:getUI("bg.layer.attPanel")

	self._nowAttr = self:getUI("bg.layer.attPanel.nowAttr")
	self._nowAttr:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._nowAttr:setPositionX(90+self._nowAttr:getContentSize().width/2)
	self._nowAttr._attMap = {}
	self._nextAttr = self:getUI("bg.layer.attPanel.nextAttr")
	-- self._nextAttr:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	local children = self._attPanel:getChildren()
	for k,v in pairs(children) do
		if v:getDescription() == "Label" then
			v:setFontName(UIUtils.ttfName_Title)
		end
	end
	-- 度量
	self._lyW = self._layer:getContentSize().width
	self._lyH = self._layer:getContentSize().height
	local proStep = 5
	local proBegin = 0
	self._upOnceBtn = self:getUI("bg.layer.upOnceBtn")
	self:registerClickEventByName("bg.layer.upOnceBtn",function() 
		if not self:checkCondition(1) then
			return
		end
		-- self:reflashTreasureStar(true)
		-- self:reflashCircleDiamond(nil,false)
		self._upOnceBtn:setEnabled(false)
		self:reflashScaleMc(true)
		self:sendUpStarMsg(1)
		self._upOnceBtn:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.2),
			cc.CallFunc:create(function( )
				self._upOnceBtn:setEnabled(true)
			end)
		))
	end)
	self._upOnceBtn:setTitleFontName(UIUtils.ttfName_Title)

	self:registerClickEventByName("bg.layer.upTenceBtn",function() 
		if not self:checkCondition(10) then
			return 
		end
		self:reflashScaleMc(true)
		self:sendUpStarMsg(10)
	end)
	self:getUI("bg.layer.upTenceBtn"):setTitleFontName(UIUtils.ttfName_Title)

	local rateLab = cc.LabelBMFont:create("45%", UIUtils.bmfName_treasure_rate)
    rateLab:setAnchorPoint(cc.p(0.5,0.5))
    rateLab:setPosition(self._lyW-100, self._lyH-80)
    rateLab:setName("rateLab")
    self._layer:addChild(rateLab, 1)
    self._rateLab = rateLab

    self._iconMaxStar = self:getUI("bg.layer.iconMaxStar")

    -- 战斗力
    local fightDes = cc.LabelBMFont:create("a", UIUtils.bmfName_zhandouli_little)
    fightDes:setName("fightDes")
    fightDes:setScale(0.5)
    fightDes:setAnchorPoint(cc.p(0, 0.5))
    fightDes:setPosition(cc.p(188, 430))
    self._layer:addChild(fightDes, 1)
    local fightLab = cc.LabelBMFont:create("0", UIUtils.bmfName_zhandouli_little)
    fightLab:setName("fightLab")
    fightLab:setScale(0.5)
    fightLab:setAnchorPoint(cc.p(0, 0.5))
    fightLab:setPosition(cc.p(250, 430))
    self._fightLab = fightLab
    self._layer:addChild(fightLab, 1)

    -- 底衬星星
    local darkStar = self:getUI("bg.layer.darkStar")
    darkStar:setSaturation(-100)
    local darkBg = self:getUI("bg.layer.darkBg")
    -- darkBg:setSaturation(-100)
    -- darkBg:setHue(90)

    -- 初始化星星
    self:resetDiamondStatus()

    -- 初始化属性展板
    self:initAttPanel()
    self:initResultPanel()
end

function TreasureUpStarLayer:initAttPanel( )
	local nowDes = self:getUI("bg.layer.attPanel.nowDes")
	nowDes:setColor(cc.c3b(255,252,179))
	nowDes:enable2Color(1,cc.c4b(246,182,32,255))
	nowDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
end

function TreasureUpStarLayer:initResultPanel( )
	self._resultPanel = self:getUI("bg.layer.resultPanel")
	self._resultPanel:setVisible(false)
	local starAddPanel = self._resultPanel:getChildByName("starAddPanel")
	starAddPanel.hadInit = true
	starAddPanel:setCascadeOpacityEnabled(true)

	local colorFormat = function( lab,color )
		lab:setColor(color)
		lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	end
	local color1 = cc.c3b(255,238,160) 
	local color2 = cc.c3b(48,255,0)
	local names  = {
		upDes 	 = color1,
		upStage  = color2,
		attDes 	 = color1,
		preAtt 	 = color2,
		aftAtt 	 = color2,
	}
	for name,color in pairs(names) do
		colorFormat(starAddPanel:getChildByName(name),color)
	end
	-- starAddPanel:setPositionY(247)
	-- local attrDes = starAddPanel:getChildByName("attrDes")
	-- attrDes:setColor(cc.c3b(255, 252, 226))
	-- attrDes:enable2Color(1, cc.c4b(255, 232, 125, 255))

	if self._parent then
		self._resultPanel:retain()
		self._resultPanel:removeFromParent()
		self._parent:addChild(self._resultPanel,1009)
		self._resultPanel:release()
	end
end

function TreasureUpStarLayer:onTop( )
	print("TreasureUpStarLayer:onTop.....")
end

function TreasureUpStarLayer:onHide( )
	print("TreasureUpStarLayer:onTop.....")
end

-- 接收自定义消息
function TreasureUpStarLayer:reflashUI(data)
	-- dump(data,"data===")
	-- 刷新资源显示 不受刷新限制
	local id = data and data.id 
	local changeDisId = self._disId and id and self._disId ~= id
	self._disId = id or self._disId 
	self:reflashResPanel()
	if self._stopScaleMcAnim then return end -- 禁止刷新
	-- 是否立马刷新 针对于升星之类
	local isReflashRightly = not self._preDisInfo or changeDisId
	-- 处理切散件的问题

	self:resetUIStatus(cahngeDisId)
	self._curDisInfo = self._tModel:getTreasureById(self._disId)
	-- 刷新宝物对象
	self:reflashTreasureIcon()
	-- 刷新星级
	print("here))))))))))))))))-==============",isReflashRightly)
	self:reflashTreasureStar(isReflashRightly)
	-- 刷新属性
	self:reflashTreasureAttr()
	

	-- 刷新刻度动画
	self:reflashScaleMc(isReflashRightly)

	-- -- 刷新结果界面
	-- self:reflashResultPanel()

	-- 统一处理满星的显示
	self:detectIsFullStar()

	-- 刷新战斗力
	self:reflashFightLab(isReflashRightly)
end

function TreasureUpStarLayer:reflashFightLab( noFightAnim )
	if self._curScore then
		self._preScore = self._curScore 
	end
	local score = self._tModel:getCorrectDisScore(self._disId)
	if not self._preScore or noFightAnim then
		self._preScore = score 
		self._fightLab:setString(score)
	end
	self._curScore = score
	if self._preScore ~= self._curScore then
		local preScale = 0.5 --self._fightLab:getScale()
		local function runFightAnim(inTable)
		    local fightLabel = self._fightLab
		    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
		        audioMgr:playSound("PowerCount")
		    end)))
		    fightLabel:stopAllActions()
		    local tempGunlun, tempFight 
		    tempGunlun = inTable.newFight - inTable.oldFight
		    tempFight = inTable.oldFight
		    local fightNum = tempGunlun / 20
		    local numsch = 1
		    local sequence = cc.Sequence:create(
		    	cc.DelayTime:create(1),
		        cc.ScaleTo:create(0.05, 1.1*preScale),
		        cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.05),cc.CallFunc:create(function()
		            fightLabel:setString((tempFight + math.ceil(fightNum * numsch)))
		            numsch = numsch + 1
		        end)), 20),
		        cc.CallFunc:create(function()
		            fightLabel:setString(inTable.newFight)
		        end),
		        cc.ScaleTo:create(0.05, 1*preScale)
		        )
		    fightLabel:runAction(sequence)
		end
		runFightAnim({newFight = self._curScore,oldFight = self._preScore})
		-- self._fightLab:stopAllActions()
		-- self._fightLab:runAction(cc.Sequence:create(
		-- 	cc.DelayTime:create(2),
		-- 	cc.CallFunc:create(function(  )
		-- 	end)
		-- ))
	-- else
	-- 	self._fightLab:setString(self._curScore)
	end
	print(noFightAnim,"self._preScore",self._preScore,self._curScore)
	if self._preScore ~= self._curScore and not noFightAnim then
		self.parentView:fightValueCallBack(self._preScore , self._curScore)
	end
end

function TreasureUpStarLayer:detectIsFullStar( )
	local isFull = self._tModel:isFullStar(self._disId)
	if not self._fullHideSet then
		self._fullHideSet = {
			"rateTitle",
			"rateLab",
			"upOnceBtn",
			"upTenceBtn",
			"starfragPanel",
			"starfragTenPanel",
			"attPanel.nextAttr",
		}
	end	
	for i,tailName in ipairs(self._fullHideSet) do
		self:getUI("bg.layer." .. tailName):setVisible(not isFull)
	end
	self._iconMaxStar:setVisible(isFull)
	-- self._rateLab:setVisible(not isFull)
	if isFull and self._progress then
		self._progress:stopAllActions()
		self:detectCircleDiamondStatus(false)
		self._progress:setPercentage(0)
		for i=1,8 do
			local diamond = self:getUI("bg.layer.treasureNodeBg.diamond_" .. i)
			diamond:setVisible(true)
		end
		-- self:reflashTreasureStar(true)
	end
	return isFull
end

function TreasureUpStarLayer:resetUIStatus( isChaned )
	if not isChanged then return end
	self:resetDiamondStatus()
	self._preScore = nil
	self._curScore = nil
	if self._progress then
		self._progress:stopAllActions()
	end
	if self._curDisInfo then
		self._preDisInfo = clone(self._curDisInfo)
		local bigStar = self._curDisInfo.bs or 0
		local smallStar = self._curDisInfo.ss or 0
		local smallPro = self._curDisInfo.b or 0
		local curIdx = smallStar 
		-- 用进度条做的遮罩 进度与光条进度相反
		local curScale = 100 - (curIdx*12.5+smallPro*0.125)
		self._preScale = curScale
	end
end

function TreasureUpStarLayer:resetDiamondStatus( )
	if self:detectIsFullStar() then return end
	for i=1,8 do
		local diamond = self:getUI("bg.layer.treasureNodeBg.diamond_" .. i)
		diamond._actived = false
		diamond:setVisible(false)
		diamond._percent = 100 - i*12.5
	end
end

function TreasureUpStarLayer:reflashTreasureIcon( )
	local toolD = tab.tool[tonumber(self._disId)] 
	if not toolD then return end
	local filename = IconUtils.iconPath .. toolD.art  .. ".png"
	local sfc = cc.SpriteFrameCache:getInstance()
	if not sfc:getSpriteFrameByName(filename) then
		filename = IconUtils.iconPath .. toolD.art .. ".jpg"
	end
	if not self._icon then 
		local icon = ccui.ImageView:create()
		icon:loadTexture(filename,1)
		icon:setPosition(self._lyW/2+50,self._lyH/2-20)
		icon:setScale(1.5)
		print(self._lyW/2,self._lyH/2,".......")
		self._layer:addChild(icon,99)
		self._icon = icon 
	else
		self._icon:loadTexture(filename,1)
	end
	local disTreasureD = tab.disTreasure[self._disId]
	local color = toolD.color
	
	local stage = self._curDisInfo and self._curDisInfo.s or 0
	local tail = ""
	if stage > 0 then
		tail = "+" .. stage 
	end
	self._treasureName:setString(lang(toolD.name) .. tail)
	self._treasureName:setFontSize(36)
	self._treasureName:setFontName(UIUtils.ttfName_Title)
	UIUtils:createTreasureNameLab(self._disId,stage,36,self._treasureName)
	-- self._treasureName:setColor(nameColorTab[color].color)
	-- self._treasureName:enable2Color(1,nameColorTab[color].color2)
	-- self._treasureName:enableOutline(nameColorTab[color].outColor,1)

	-- self._stage:setFontSize(50)
	-- self._stage:setString("+" .. stage)
	-- self._stage:setFontName(UIUtils.ttfName_Title)
	-- self._stage:setColor(nameColorTab[color].color)
	-- self._stage:enable2Color(1,nameColorTab[color].color2)
	-- self._stage:enableOutline(nameColorTab[color].outColor,1)
end


function TreasureUpStarLayer:reflashTreasureStar( isRefreshRightly )
	if not isRefreshRightly then return end
	local starNum = self._tModel:getDisTreasureStar(self._disId)
	if not self._preStarNum[self._disId] then
		self._preStarNum[self._disId] = starNum 
	end
	if self._preStarNum[self._disId] ~= starNum then
		self._preStarNum[self._disId] = starNum
		local stage = self._curDisInfo and self._curDisInfo.s or 0
	
		self._viewMgr:showDialog("treasure.TreasureUpStarSuccessView",{id = self._disId,stage = stage,starNum =starNum})
	end
	
	if starNum > 0 then
		self._star:setVisible(true)
		self._star:loadTexture("globalImageUI6_iconStar".. starNum ..".png",1)
	else
		self._star:setVisible(false)
	end

end


function TreasureUpStarLayer:reflashTreasureAttr( )
	-- body
	local bigStar = self._curDisInfo.bs or 0
	local smallStar = self._curDisInfo.ss or 0
	local smallPercent = self._curDisInfo.b or 0
	local curAttr,nextAttr = self:getAttrs(bigStar,smallStar,smallPercent)
	local critIdx = bigStar*8+smallStar+1
	local critData = tab.comTreasureStar[critIdx]
	-- 暴击率
	local color = tab.tool[tonumber(self._disId)] and tab.tool[tonumber(self._disId)].color or 2
	if not critData then critData = tab.comTreasureStar[#tab.comTreasureStar] end
	local critRate = critData and critData["cirt" .. color] or 0
	self._rateLab:setString(critRate .. "%")

	local preAttr = self._nowAttr._attMap[self._disId]
	if not preAttr then
		preAttr = curAttr
		self._nowAttr._attMap[self._disId] = curAttr
	end
	if preAttr ~= curAttr then
		self._nowAttr:stopAllActions()
		self._nowAttr:runAction(cc.Sequence:create(
			cc.ScaleTo:create(0.1,1.1),
			cc.CallFunc:create(function( )
				self._nowAttr:setString("+" .. curAttr .. "%")
				self._nowAttr:setPositionX(90+self._nowAttr:getContentSize().width/2)
			end),
			cc.ScaleTo:create(0.3,1)
		))
	else
		self._nowAttr:setString("+" .. curAttr .. "%")
		self._nowAttr:setPositionX(90+self._nowAttr:getContentSize().width/2)
	end
	self._nowAttr._attMap[self._disId] = curAttr
	self._nextAttr:setString("(升星成长：" .. (nextAttr-curAttr) .."%)")
end

function TreasureUpStarLayer:reflashResPanel( )
	local starfragNum = self._modelMgr:getModel("UserModel"):getData().starfrag or 0
	local cost = self._tModel:getUpStarConsume(self._disId)
	if cost == -1 then
		self._starfragPanel:setVisible(false)
		self._starfragPanel:setVisible(false)
	else
		
	end
	local oneNumLab = self._starfragPanel:getChildByName("starNumLab")
	-- oneNumLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	oneNumLab:setString(starfragNum .. "/" .. cost)
	oneNumLab:setColor(starfragNum >= cost and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccColorQuality6)
	local tenNumLab = self._starfragTenPanel:getChildByName("starNumLab")
	
	local userInfo = self._modelMgr:getModel("UserModel"):getData()
    local isFree = userInfo.statis.snum29
                    
	if not isFree or isFree == 0 then
		tenNumLab:setString("免费")
	else
		tenNumLab:setString(starfragNum .. "/" .. cost*10)
		tenNumLab:setColor(starfragNum >= cost*10 and UIUtils.colorTable.ccUIBaseTextColor2 or UIUtils.colorTable.ccColorQuality6)
	end
	-- tenNumLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
end

function TreasureUpStarLayer:reflashScaleMc( rightly )
	-- 计算出现在的刻度
	local bigStar = self._curDisInfo.bs or 0
	local smallStar = self._curDisInfo.ss or 0
	local smallPro = self._curDisInfo.b or 0
	local curIdx = smallStar 
	-- 用进度条做的遮罩 进度与光条进度相反
	local scaleOffset = 0
	-- if bigStar > 0 and bigStar < 5 then
	-- 	scaleOffset = 12.5
	-- 	if curIdx == 0 then
	-- 		curIdx = 8 
	-- 	end
	-- end
	local curScale = 100 - (curIdx*12.5+smallPro*0.125) + scaleOffset -- curIdx/8 * 100
	if curScale == 0 then curScale = 100 end
	local proTime = 0
	local stepTime = 0.1
	if not self._preScale or rightly then 
		self._preScale = curScale
	end
	local deltScale = 0
	if self._preScale > curScale then
		deltScale = self._preScale - curScale
	else
		deltScale = 100-curScale+self._preScale
	end
	proTime = deltScale*stepTime
	proTime = math.max(0.3,proTime)
	if not self._scaleMc then
		local mc = mcMgr:createViewMC("baowushengxinjindutiao_treasureui",true,false)
		mc:setPosition(self._lyW/2+50,self._lyH/2-10)
		mc:setScale(-1,1)
		self._layer:addChild(mc)
		self._scaleMc = mc

		local sp = cc.Sprite:createWithSpriteFrameName("darkBg_treasure.png")
	    local progress = cc.ProgressTimer:create(sp)
	    progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    progress:setMidpoint(cc.p(0.5, 0.5))
	    progress:setBarChangeRate(cc.p(1, 1))    
	    progress:setAnchorPoint(0.5, 0.5)
	    progress:setPosition(self._lyW/2+50,self._lyH/2-10)
	    progress:setScale(6)
	    progress:setRotation(0)
	    self._layer:addChild(progress,1)
		self._progress = progress
		-- self._progress:setPercentage(curScale)
	end
	
	if self._progress then
		if rightly then
			self._progress:stopAllActions()
			self._progress:setPercentage(curScale)
			self:detectCircleDiamondStatus(false)
			self:reflashCircleDiamond(curScale,true)
		else
			if self._preScale ~= curScale then -- 切页签时不执行这里
				self:detectCircleDiamondStatus(true)
				audioMgr:playSound("TreasurePro")
			end
			if self._preScale < curScale then -- 光条 从 99 到 1
				self._progress:runAction(
					cc.Sequence:create(
						cc.ProgressTo:create(proTime*(100-curScale)/deltScale,0),
						cc.CallFunc:create(function( )
							-- 这里加动画
							self._progress:setPercentage(100)
							self:resetDiamondStatus()
							-- self:reflashCircleDiamond(100,true)
						end),
						cc.ProgressTo:create(math.max(0.2,proTime*self._preScale/deltScale),curScale),
						cc.CallFunc:create(function( )
							self._preScale = curScale
							self:detectCircleDiamondStatus(false)
							self:reflashCircleDiamond(curScale,false)
						end)
					)
				)
			else
				self._progress:runAction(
					cc.Sequence:create(
						cc.ProgressTo:create(proTime,curScale),
						cc.CallFunc:create(function( )
							self._preScale = curScale
							-- self:reflashCircleDiamond(proTime,rightly)
							self:detectCircleDiamondStatus(false)
							self:reflashCircleDiamond(curScale,false)
						end)
					)
				)
			end
		end
	end
end

function TreasureUpStarLayer:detectCircleDiamondStatus( isDetect )
	if isDetect then
		self._layer:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
				cc.DelayTime:create(0.2),
				cc.CallFunc:create(function( )
					if self._progress then
						local percent = self._progress:getPercentage()
						percent = math.floor(percent)
						print("percent....",percent)

						if self._preDisInfo.b ~= self._curDisInfo.b then
							self:reflashCircleDiamond(percent)
						end
					end
				end)
			)
		))
	else
		self._layer:stopAllActions()
	end
end

function TreasureUpStarLayer:reflashCircleDiamond(percent ,rightly)
	local preSmallStar = self._preDisInfo and self._preDisInfo.ss or 0
	local preBigStar = self._preDisInfo and self._preDisInfo.bs or 0
	local preIdx = preBigStar*8+preSmallStar 
	local curSmallStar = self._curDisInfo and self._curDisInfo.ss or 0
	local curBigStar = self._curDisInfo and self._curDisInfo.bs or 0
	local curPercent = self._curDisInfo and self._curDisInfo.b or 0
	local curIdx = curBigStar*8+curSmallStar 
	if curBigStar > 0 and curSmallStar == 0 then 
		curSmallStar = 8
	end
	local starNum = self._tModel:getDisTreasureStar(self._disId)
	for i=1,8 do
		local diamond = self:getUI("bg.layer.treasureNodeBg.diamond_" .. i)
		if ((curSmallStar >= i and percent <= diamond._percent) or curBigStar == 5) and percent ~= 0 then
			diamond:setVisible(true)
			if rightly then
				diamond._actived = true
			end
			if not diamond._actived and not diamond:getChildByName("fankui")  then
				diamond._actived = true
				local mc1 = mcMgr:createViewMC("fankui_lianmengjihuo", false, false, nil, RGBA8888) 
				mc1:setPosition(diamond:getContentSize().width/2,diamond:getContentSize().height/2) 
	            diamond:addChild(mc1) 
	            mc1:setName("fankui")
	            mc1:runAction(cc.Sequence:create(
	            	cc.DelayTime:create(3),
	            	cc.RemoveSelf:create()
	            ))
	            audioMgr:playSound("TreasureBlueStar")
			end
		elseif not self:detectIsFullStar() then
			diamond._actived = nil
			diamond:setVisible(false)
		end
		-- 最后一颗星动画
		local isFlyStar = false
		if i == 8 then
			isFlyStar = ((curIdx%8 == 0 or curIdx%8 == 1) and preIdx%8 == 7 and not rightly) or (preIdx%8 == 7 and curPercent >= 100)
			-- print("isFlyStar",curIdx,(curIdx%8 == 0 and preIdx%8 == 7 and not rightly))
			-- print("isFlyStar2222",preIdx,(preIdx%8 == 7 and curPercent >= 100),preIdx,curPercent)
		end
		if i == 8 and isFlyStar and not self._layer:getChildByName("guanghuanMc") then
			if rightly then
				diamond._actived = true
			end
			if not diamond._actived and not diamond:getChildByName("fankui") then
				diamond:setVisible(true)
				diamond._actived = true
				local mc1 = mcMgr:createViewMC("fankui_lianmengjihuo", false, false, function( )
					-- diamond:setVisible(false)
				end, RGBA8888) 
				mc1:setName("fankui")
				mc1:runAction(cc.Sequence:create(
	            	cc.DelayTime:create(3),
	            	cc.RemoveSelf:create()
	            ))
				mc1:setPosition(diamond:getContentSize().width/2,diamond:getContentSize().height/2) 
	            diamond:addChild(mc1) 
	        end
	        if not self._layer:getChildByName("guanghuanMc") then
	            local guanghuanMc = mcMgr:createViewMC("shengxingguanghuan_treasureui", false, false, function( )
				end, RGBA8888) 
				guanghuanMc:setPosition(self._lyW/2+51,self._lyH/2-7)
				guanghuanMc:runAction(cc.Sequence:create(
	            	cc.DelayTime:create(4),
	            	cc.RemoveSelf:create()
	            ))
				-- guanghuanMc:setPlaySpeed(2) 
	            guanghuanMc:setName("guanghuanMc")
	            self._layer:addChild(guanghuanMc,999)
	        end
   --          ScheduleMgr:delayCall(50, self, function( )
   --          	if guanghuanMc then 
   --          		guanghuanMc:removeFromParent()
   --          	end
			-- end) 
            -- 升星动画
            if not rightly then
            	-- self._upOnceBtn:setEnabled(false)
            	ScheduleMgr:delayCall(800, self, function( )
            		if self.showStarFlyAnim then
			            self:showStarFlyAnim(starNum)
            		end
            	end)
	        end
		end
	end
	-- self:showStarFlyAnim()
end
local starNumTest = 0
function TreasureUpStarLayer:showStarFlyAnim( starNum )
	print("starNum))))))))))))))))))))-----------===",starNum)
	if starNum == 0 then
		self:reflashTreasureStar(true) 
		return  
	end
	starNum = starNum or starNumTest
	local starNum = self._tModel:getDisTreasureStar(self._disId)
	if starNum > 1 then
		self._star:loadTexture("globalImageUI6_iconStar".. (starNum -1) ..".png",1)
	end
	-- starNumTest = (starNumTest+1)%6
	-- print(starNumTest,"-------------test star")
	local starMc = self._layer:getChildByName("starMc")
	if not starMc then
		audioMgr:playSound("TreasureStarUp")
		local pos1 = {x=self._lyW/2+40,y=self._lyH/2}
		local pos2 = {x=self._star:getPositionX()+(starNum-1)*18+14,y=self._star:getPositionY()-3}
		local starMc = mcMgr:createViewMC("xingxingtou_qianghua", true, false)
		starMc:setPosition(pos1.x,pos1.y)
		starMc:setName("starMc")
	    starMc:setCascadeOpacityEnabled(true)
	    starMc:setScale(0.5)
	    local dir = -1
	    local rotaOffset = 0
	   	if starNum > 2 then
	   		rotaOffset = -180
	   	end
	    local angle = dir*math.deg(math.atan((pos1.y-pos2.y)/(pos1.x-pos2.x)))+rotaOffset
	    self._layer:addChild(starMc, 999)
	    print("atan .,..==============",angle,math.atan(1),math.deg(math.atan(1)),math.deg(math.pi))

	    local yiba = mcMgr:createViewMC("xingxingwei_qianghua", true, false)
	    yiba:setAnchorPoint(cc.p(0.5, 0))
	    -- yiba:setPosition(pos1.x,pos1.y)
	    yiba:setRotation(angle)
	    yiba:setCascadeOpacityEnabled(true)
	    -- yiba:setScaleX(0)
	    starMc:addChild(yiba, -1)

	    starMc:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,pos2),cc.ScaleTo:create(0.1,0.6),cc.CallFunc:create(function(  )
	    	-- starMc:setVisible(false)
	    	-- self._upOnceBtn:setEnabled(true)
	    end),
	    cc.DelayTime:create(0.8),
	    cc.CallFunc:create(function( )
	    	-- starMc:removeFromParent()
	    	starMc:setVisible(false)
	    	self:reflashTreasureStar(true)
	    end),
	    cc.DelayTime:create(3),
	    cc.CallFunc:create(function( )
	    	starMc:removeFromParent()
	    	-- self:reflashTreasureStar(true)
	    end)
	    )) --,cc.FadeOut:create(0.05)))
	    local yibaSeq = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.15, 1, 1), cc.FadeOut:create(0.3))
	    yiba:runAction(yibaSeq)
	    if not self:detectIsFullStar() then
		    self:resetDiamondStatus()
		end
	else 
		print("重复飞星动画请求！！！！")
	end

end

function TreasureUpStarLayer:reflashResultPanel(crits)
	if not crits then return end
	if #crits == 1 then
		self._resultPanel:stopAllActions()
		-- if self._soundId then
		-- 	audioMgr:stopSound(self._soundId)
		-- end
		local crit = crits[1]

		local actionInternal = 0.1
		local delayTime 	 = 1

		local curAttr = self:getAttrs(self._curDisInfo.bs or 0,self._curDisInfo.ss or 0)
		local preAttr = self:getAttrs(self._preDisInfo.bs or 0,self._preDisInfo.ss or 0)
		local stepPanel 	 = self._resultPanel:getChildByName("stepPanel")
		stepPanel:setCascadeOpacityEnabled(true)
		stepPanel:setCascadeOpacityEnabled(true)
		local starAddPanel 	 = self._resultPanel:getChildByName("starAddPanel")
		starAddPanel:setCascadeOpacityEnabled(true)
		local isAttAdd = curAttr-preAttr > 0
		stepPanel:setVisible(not isAttAdd)
		starAddPanel:setVisible(isAttAdd)
		if not isAttAdd then
			local upImg = stepPanel:getChildByName("upImg")
			upImg:loadTexture("crit+".. crit .."Title_treasure.png",1)
		else
			local preAtt = starAddPanel:getChildByName("preAtt")
			local aftAtt = starAddPanel:getChildByName("aftAtt")
			local attDes = starAddPanel:getChildByName("attDes")
			local arrow = starAddPanel:getChildByName("arrow")
			preAtt:setString("+" .. preAttr .. "%")
			aftAtt:setString("+" .. curAttr .. "%")
			UIUtils:alignNodesToPos({attDes,preAtt,arrow,aftAtt},100,5)
			local stage = (self._curDisInfo.ss or 1)
			if stage == 0 then stage = 8 end
			local upStage = starAddPanel:getChildByName("upStage")
			upStage:setString(stage)
		end
		self._resultPanel:setCascadeOpacityEnabled(true)
		self._resultPanel:setVisible(true)
		self._resultPanel:setOpacity(0)

		local guanghuanMc = mcMgr:createViewMC("baowushengxing_treasureui", false, true, nil, RGBA8888) 
		guanghuanMc:setPosition(self._lyW/2+51,self._lyH/2-17) 
        self._layer:addChild(guanghuanMc,999)

        guanghuanMc:addCallbackAtFrame(5,function( )
			stepPanel:runAction(cc.ScaleTo:create(actionInternal,1))
			starAddPanel:runAction(cc.ScaleTo:create(actionInternal,1))
			-- starAddPanel:runAction(cc.MoveTo:create(actionInternal*2,cc.p(648,257)))
			self._resultPanel:runAction(cc.Sequence:create(
				cc.FadeIn:create(actionInternal),
				cc.CallFunc:create(function( )
				end),
				cc.DelayTime:create(delayTime),
				cc.FadeOut:create(actionInternal),
				cc.CallFunc:create(function( )
					if self._resultPanel then
						self._resultPanel:setVisible(false)
					end
				end)
			))
        end)
        if crit > 1 then
	        self._soundId = audioMgr:playSound("Forge")
	    end
	else
		self._viewMgr:showDialog("treasure.TreasureUpStarTenDialog",{crits = crits,disId = self._disId, preDisInfo = self._preDisInfo, upTenFunc = function( callback )
			self._stopScaleMcAnim = false
			self._preDisInfo = nil
			self:reflashUI()
			self:sendUpStarMsg(10,callback)
			self._stopScaleMcAnim = true
		end,callback = function( )
			self:reflashTreasureStar(true)
			self._stopScaleMcAnim = false
			self:reflashUI()
		end})
	end
end

-- 检查是否满足升星条件
function TreasureUpStarLayer:checkCondition( num )
	local canUp,isFull,isResEnough = self._tModel:isCanUpStar(self._disId,num)
	if isFull then
		self._viewMgr:showTip("升星已满")
	elseif not isResEnough then
		local userInfo = self._modelMgr:getModel("UserModel"):getData()
		local isFree = userInfo.statis.snum29
		if num == 10 and (not isFree or isFree == 0) then
			canUp = true
		else
			local param = {indexId = 11}
	        self._viewMgr:showDialog("global.GlobalPromptDialog", param)
	    end
		-- self._viewMgr:showTip("资源不足")
	end
	return canUp
end

-- 查 当前和 下级 属性
function TreasureUpStarLayer:getAttrs( bigStar,smallStar,percent )
	percent = percent or 0
	local curIdx = bigStar*8+smallStar+math.floor(percent/100) 
	local nowData = tab.comTreasureStar[curIdx]
	local nextData = tab.comTreasureStar[curIdx+1]
	local curAttr ,nextAttr = 0,0
	if nowData then
		curAttr = nowData.attrprosum
	end
	if nextData then
		nextAttr = nextData.attrprosum
	else
		-- 升星已满
		nextAttr = curAttr
	end
	
	return curAttr,nextAttr,nowData
end

-- 发送升星消息
function TreasureUpStarLayer:sendUpStarMsg( num,callback )
	if not self._comId then 
		self._comId = self._tModel:getComIdByDisId(self._disId)
	end
	self._preDisInfo = clone(self._curDisInfo)
	if num == 10 then
		self._stopScaleMcAnim = true
	end
	self._serverMgr:sendMsg("TreasureServer", "upStar", { comId = self._comId, disId = self._disId,num = num or 1 }, true, { }, function(result)
    	-- dump(result)
    	if self.reflashUI then 
    		if num ~= 10 then
		    	self:reflashUI()
			end
	    	-- 刷新结果界面
		    if callback then 
		    	callback(result)
		    else
				self:reflashResultPanel(result.crits)
		    end
		    local isFull = self._tModel:isFullStar(self._disId)
		    if isFull then
		    	self:reflashCircleDiamond(100)
		    end
	    end
    end )
end

return TreasureUpStarLayer