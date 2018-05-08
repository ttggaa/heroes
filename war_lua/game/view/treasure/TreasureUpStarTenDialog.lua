--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-04-14 10:12:05
--
local TreasureUpStarTenDialog = class("TreasureUpStarTenDialog",BasePopView)
function TreasureUpStarTenDialog:ctor(param)
    self.super.ctor(self)
    self._tModel = self._modelMgr:getModel("TreasureModel")
    self._upTenFunc = param and param.upTenFunc
    self._preDisInfo = param and param.preDisInfo
    -- dump(self._preDisInfo)
    self._disId = param and param.disId
    self._callback = param and param.callback
    self._speed = 1 -- 加速用 
end

function TreasureUpStarTenDialog:getAsyncRes()
    return
    {
        -- { "asset/ui/treasure3.plist", "asset/ui/treasure3.png" },
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureUpStarTenDialog:onInit()
	self:registerClickEventByName("bg.closeBtn",function() 
		if self._callback then
			self._callback()
		end
		self:close()
		UIUtils:reloadLuaFile("treasure.TreasureUpStarTenDialog")
	end)
	self:registerClickEventByName("bg.speedLayer",function() 
		self._speed = 0.1
		print("touching  ing ing ing nig ingingn igngngingingingignig ")
	end)
	local speedLayer = self:getUI("bg.speedLayer")
	if speedLayer then
		speedLayer:setSwallowTouches(false)
	end
	self._title = self:getUI("bg.headBg.title")
	UIUtils:setTitleFormat(self._title,1)

	self._addAttr = self:getUI("bg.addAttr")
	self._addAttr:setColor(UIUtils.colorTable.ccUIBaseColor2)
	-- self._addAttr:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._attrDes = self:getUI("bg.attrDes")
	self._attrDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)


	self._scrollItem = self:getUI("bg.scrollItem")
	self._scrollItem:setVisible(false)
	self._scrollView = self:getUI("bg.scrollView")
	self._initScrollHeight = self._scrollView:getContentSize().height

	self._upStarTenBtn = self:getUI("bg.upStarTenBtn")
	self._upStarTenBtn:setVisible(false)
	self:registerClickEventByName("bg.upStarTenBtn",function() 
		local canUp,isFull,isResEnough = self._tModel:isCanUpStar(self._disId,10)
		if not canUp then 
			if isFull then
				self._viewMgr:showTip("升星已满")
			elseif not isResEnough then
				-- self._viewMgr:showTip("资源不足")
				local param = {indexId = 11}
		        self._viewMgr:showDialog("global.GlobalPromptDialog", param)
			end
			return 
		end
		self._preDisInfo = clone(self._tModel:getTreasureById(self._disId))
		self._upStarTenBtn:setVisible(false)
		self._upTenFunc(function( result )
			self:reflashUI(result)
		end)
	end)
end

-- 接收自定义消息
function TreasureUpStarTenDialog:reflashUI(data)
	local crits = data and data.crits 
	if not crits then return end

	local upInfos = self:processData(crits)
	local itemNum = #crits
	local itemH = self._scrollItem:getContentSize().height
	local itemW = self._scrollItem:getContentSize().width
	local maxHeight = itemNum*itemH
	maxHeight = math.max(self._initScrollHeight,maxHeight)
	self._scrollView:setInnerContainerSize(cc.size(itemW+10,maxHeight))
	self._scrollView:removeAllChildren()
	self._scrollView:getInnerContainer():setPositionY(self._initScrollHeight-maxHeight)
	local x,y = 0,0
	local showItem 
	showItem = function( idx )
		local data = upInfos[idx]
		if not data then
			local canUp,isFull,isResEnough = self._tModel:isCanUpStar(self._disId,10)
			self._upStarTenBtn:setVisible(not isFull)
			self._speed = 1
			self:showRealCost(crits)
			return 
		end
		y = maxHeight - itemH*(idx)

		if idx == 6 and itemNum > 7 then 
			local offsetY = 0
	        local container = self._scrollView:getInnerContainer()
	        container:runAction(cc.Sequence:create(
	            cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(0,offsetY)),0.7),
	            cc.CallFunc:create(function( )
	                self:createItem(data,idx,x,y,function( )
						showItem(idx+1)
					end)
	            end)
	        ))
	    else
			self:createItem(data,idx,x,y,function( )
				showItem(idx+1)
			end)
		end
	end

	showItem(1)

	-- 刷新增加属性
	self:reflashAttr()
end

function TreasureUpStarTenDialog:reflashAttr( )
	local curDisInfo = self._tModel:getTreasureById(self._disId)
	-- dump(self._preDisInfo)
	local curBigStar = curDisInfo.bs or 0
	local curSmallStar  = curDisInfo.ss or 0
	local curScale = curDisInfo.b or 0
	local curIdx = curBigStar*8+curSmallStar+math.floor(curScale/100)
	local comStarD = tab.comTreasureStar[curIdx]
	local attrProSum = comStarD and comStarD.attrprosum or 0
	-- dump(curDisInfo,curIdx .. attrProSum)
	local preBigStar = self._preDisInfo.bs or 0
	local preSmallStar  = self._preDisInfo.ss or 0
	local preIdx = preBigStar*8+preSmallStar
	print("curidx...=============",curIdx,preIdx)
	local preComStarD = tab.comTreasureStar[preIdx]
	local preAttrProSum = preComStarD and preComStarD.attrprosum or 0
	self._attrDes:setString("宝物属性+" .. preAttrProSum .. "%")
	-- dump(self._preDisInfo,preIdx,preAttrPro)
	self._addAttr:setString("(+".. (attrProSum - preAttrProSum) .. "%)")
	UIUtils:center2Widget(self._attrDes,self._addAttr,240,5)
end

function TreasureUpStarTenDialog:createItem( data,idx,x,y,nextFunc )
	local item = self._scrollItem:clone()
	item:setVisible(true)
	item:setPosition(x,y-40)
	self._scrollView:addChild(item)

	local numLab = item:getChildByName("numLab")
	numLab:setString("第" .. idx .. "次")

	local crit = data.crit

	local upNumLab = item:getChildByName("upNumLab")
	upNumLab:setString("+" .. crit)
	-- upNumLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	local resultLab = item:getChildByName("resultLab")

	local stepImg = item:getChildByName("stepImg")
	local critImg = item:getChildByName("critImg")
	local delayTime = 0.10
	if crit > 1 then
		stepImg:loadTexture("new_upStar_+".. crit .."_treasure.png",1)
		critImg:loadTexture("new_upStar_x".. crit .."_s_treasure.png",1)
		critImg:setVisible(true)
		critImg:setOpacity(0)
		critImg:setScale(3)
		delayTime = 0.8
		upNumLab:setVisible(false)
		resultLab:setVisible(false)
		
	else
		stepImg:setVisible(false)
		critImg:setVisible(false)
	end
	local diamondImg = item:getChildByName("diamondImg")
	diamondImg:setVisible(false)
	if data.upBigStar then
		diamondImg:loadTexture("upTo".. data.star .."Star_treasure.png",1)
		diamondImg:setVisible(true)
		delayTime = 0.8
		numLab:setString("")
		item:setBackGroundImage("new_upStar_cellBg2_treasure.png", 1)
	elseif data.upSmallStar then
		delayTime = 0.8
		numLab:setColor(cc.c3b(252,252,32))
		numLab:setString("升至".. (data.sStar+1) .. "阶")
		numLab:setFontSize(22)
		numLab:enableOutline(cc.c3b(0,0,32),1)
		item:setBackGroundImage("new_upStar_cellBg3_treasure.png", 1)
	else
	end
	audioMgr:playSound("adTag")
	-- 动画
	item:runAction(cc.Sequence:create(
		cc.MoveTo:create(0.1*self._speed,cc.p(x,y)),
		cc.CallFunc:create(function( )
			-- 扫光
			if crit > 1 then
				critImg:setScale(20)
				critImg:runAction(
					cc.Sequence:create(
						cc.Spawn:create(
							cc.ScaleTo:create(0.1*self._speed,1.2),
							cc.FadeIn:create(0.1*self._speed)
						),
						cc.ScaleTo:create(0.2*self._speed,1)
					)
				)
				audioMgr:playSound("TreasureCrit2")
			end
			if data.upBigStar or data.upSmallStar then
				local mc = mcMgr:createViewMC("shengxingsaoguang_treasureui",false,true)
				mc:setPosition(item:getContentSize().width/2,item:getContentSize().height/2)
				-- mc:setPlaySpeed(1/self._speed)
				item:addChild(mc)
				audioMgr:playSound("TreasureBlueStar")
				-- diamondImg:setScale(20)
				-- diamondImg:setVisible(false)
				-- diamondImg:runAction(
				-- 	cc.Sequence:create(
				-- 		cc.DelayTime:create(0.4),
				-- 		cc.CallFunc:create(function( )
				-- 			-- diamondImg:setVisible(true)
				-- 		end),
				-- 		cc.Spawn:create(
				-- 			cc.ScaleTo:create(0.1,1.2),
				-- 			cc.FadeIn:create(0.1)
				-- 		),
				-- 		cc.ScaleTo:create(0.2,1),
				-- 		cc.CallFunc:create(function( )
				-- 			audioMgr:playSound("TreasureBlueStar")
				-- 		end)
				-- 	)
				-- )
			end
		end),
		cc.DelayTime:create(delayTime*self._speed),
		cc.CallFunc:create(function( )
			if nextFunc then nextFunc() end
		end)
	))
	return item
end

function TreasureUpStarTenDialog:processData( crits )
	local preBigStar = self._preDisInfo.bs or 0
	local preSmallStar  = self._preDisInfo.ss or 0
	local preScale = self._preDisInfo.b or 0
	print("preScale",preScale)
	-- dump(self._preDisInfo,"preInfo...")
	local star = preBigStar 
	local sStar = preSmallStar
	local scale = preScale
	local curIdx = preBigStar*8+preSmallStar+1
	local comStarD = tab.comTreasureStar[math.min(#tab.comTreasureStar,curIdx)]

	local color = tab.tool[self._disId].color
	local upBase = comStarD["base" .. color]
	local result = {} 
	for i,crit in ipairs(crits) do
		local data = {}
		data.crit = crit 
		scale = scale+upBase*crit
		data.scale = scale
		print("scale,",scale,"upBase",upBase,"curIdx",curIdx)
		if scale >= 100 then
			curIdx = curIdx + 1
			print("curIdx.......",curIdx)
			comStarD = tab.comTreasureStar[math.min(#tab.comTreasureStar,curIdx)]
			star = comStarD.star 
			data.upSmallStar = true
			data.upBigStar = (star > preBigStar) or sStar == 7
			data.sStar = sStar
			if star == 4 and not tab.comTreasureStar[curIdx] then
				star = 5 
			end
			data.star = star
			preBigStar = star
			sStar = comStarD.littlestar
			print("star,pre,sStar pre",star,preBigStar,"---",sStar,preSmallStar)
			upBase = comStarD["base" .. color]
			scale = scale - 100
		end
		result[i] = data
	end
	return result
end

--[[若玩家即将达到满星，点击升星10次后，以玩家宝物达到满星时使用的次数为止，扣除对应资源
--  同时在三级弹窗下方显示“本次共消耗道具XX个，返还未使用道具XX个”
--]]
function TreasureUpStarTenDialog:showRealCost( crits )
	local bg = self:getUI("bg")
	local critNum = #crits
	if critNum >= 10 then return end
	local cost = self._tModel:getUpStarConsume(self._disId)
	local consume = critNum*cost 
	local left = 10*cost-consume
	local promptLab = ccui.Text:create()
    promptLab:setString("本次共消耗道具".. consume .."个，返还未使用道具".. left .."个")    
    promptLab:setFontName(UIUtils.ttfName)
    promptLab:setName("promptLab")
    promptLab:setFontSize(20)
    promptLab:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
    promptLab:setPosition(bg:getContentSize().width/2, 60)
    bg:addChild(promptLab,11)
end
return TreasureUpStarTenDialog