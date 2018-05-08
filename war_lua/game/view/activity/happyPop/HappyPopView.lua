--[[
    Filename:    HappyPopView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-8 20:45
    Description: 法术特训小游戏 消消乐
--]]

local HappyPopView = class("HappyPopView", BasePopView)

function HappyPopView:ctor(param)
	HappyPopView.super.ctor(self)
	self._hPopModel = self._modelMgr:getModel("HappyPopModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	require("game.view.activity.happyPop.HappyPopConst")
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --随机种子

	self._data = {}
	self._cards = {}     	--牌列表
	self._lastCard = nil   	--上一张奇数牌
	self._curShowNum = 0    --当前显示的牌数(小于等于6张)
	self._clickTime = 0     --单副牌开始的时间（用来最小翻牌结束时间防作弊判断）
	self._callback = param.callback
	
	--[[
	self._isGameOver = false   	--游戏是否结束（防止与换牌请求冲突）
	self._tempTime    			--剩余秒数（倒计时显示用）
	self._isTimeStart   		--是否开始倒计时（用来判断当前是否在游戏中）
	]]
end

function HappyPopView:getAsyncRes()
    return {{"asset/ui/hPop.plist", "asset/ui/hPop.png"}}

end

function HappyPopView:onInit()
	--clipLayer
	self._guideLayer = self:getUI("bg.guideLayer")
	self._guideLayer:setSwallowTouches(true)
	self._guideLayer:setVisible(false)

	self._clipLayer = self:getUI("bg.clipLayer")
	self._clipLayer:setSwallowTouches(true)
	self._clipLayer:setVisible(false)

	--装饰点
	local cardBg = self:getUI("bg.cardBg")	
	for i=1, 14 do
		local dot = ccui.ImageView:create("ac_hPop_dot.png", 1)
		if i <= 7 then
			dot:setPosition(35, 402 - i * 30)
		else
			dot:setPosition(530, 402 - (i-7) * 30)
		end

		cardBg:addChild(dot)
	end

	--closebtn
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:pause()
		local function closeFunc1()
			if self._callback then
				self._callback()
			end
			self:close()
			UIUtils:reloadLuaFile("activity.happyPop.HappyPopView")
		end
		local function closeFunc2() 
			self:resume()
		end

		local isUseLocal = self._hPopModel:getIsUseLocalState()
		if (self._isTimeStart and not self._isGameOver) or isUseLocal then
			self._viewMgr:showDialog("activity.happyPop.HappyPopTipView", {callback1 = closeFunc1, callback2 = closeFunc2, type = 2}, true)
		else
			closeFunc1()
		end
		end)

	--活动时间
	local Label_74 = self:getUI("bg.cardBg.desBg.Label_74")
	local Label_75 = self:getUI("bg.cardBg.desBg.Label_74_0")
	local acData = self._hPopModel:getAcData()
	if acData and next(acData) then
		local startT = acData.start_time
		local endT = acData.end_time - 86400
		local startY = TimeUtils.getDateString(startT,"%m")
		local startM = TimeUtils.getDateString(startT,"%d")
		local endY = TimeUtils.getDateString(endT,"%m")
		local endM = TimeUtils.getDateString(endT,"%d")

		Label_74:setString("活动时间:".. startY .. "月" .. startM .. "日~" .. endY .. "月" .. endM .. "日")
		Label_75:setString("排行榜结算:".. endM.. "日21:00")
	end

	local Label_76 = self:getUI("bg.sp.Image_33.tip")
	Label_76:setColor(cc.c4b(255,244,228,255))
	Label_76:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	
	--rankBtn
	local rankTxt = self:getUI("bg.sp.scoreBg.des5")
	rankTxt:setScaleAnim(true)
	self:registerClickEvent(rankTxt, function()
		local rankOpen = tab.systemOpen["Rank"]
        local userData = self._userModel:getData()
        if userData.lvl < rankOpen[1] then
            self._viewMgr:showTip(lang(rankOpen[3]))
            return
        end

		self._viewMgr:showDialog("activity.happyPop.HappyPopRankView", {}, true)
		end)

	--title
	local title = self:getUI("bg.cardBg.title.titleStr")
	UIUtils:setTitleFormat(title, 1)

	--rule
	local ruleBtn = self:getUI("bg.cardBg.title.ruleBtn")
	self:registerClickEvent(ruleBtn, function()
		local endM = self._hPopModel:getEndDateStr()
        local ruleDes = string.gsub(lang("MAGICTRAINING_RULE"), "{$day}", endM)
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = ruleDes},true)

		end)

	--sp
	self._sp = self:getUI("bg.sp")

	local spBgAnim = mcMgr:createViewMC("changjing_fashutexun", true, false)
	spBgAnim:setPosition(128, 5)
	self._sp:addChild(spBgAnim)

    --timeBar
    local Image_83 = self:getUI("bg.sp.Image_83")
    self._bloodBar = cc.Sprite:createWithSpriteFrameName("ac_hPop_circle.png")
    self._progress = cc.ProgressTimer:create(self._bloodBar)
    self._progress:setCascadeOpacityEnabled(true, true)
    self._bloodBar:setCascadeOpacityEnabled(true, true)
    self._progress:setPosition(Image_83:getContentSize().width/2, Image_83:getContentSize().height / 2)
    self._progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self._progress:setReverseProgress(true) 
    self._progress:setPercentage(100)
    Image_83:addChild(self._progress)

    self:getUI("bg.sp.Image_83.timeStr"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    --奖励icon
    local rwd1 = self:getUI("bg.sp.scoreBg.rwdIcon1")
    local rwdId1 = tab.magicTrainingCfg["BASICREWARD"]["value"]
    local param = {itemId = rwdId1, eventStyle = 4, swallowTouches = true}
    local rwdIcon = IconUtils:createItemIconById(param)
    rwdIcon:setAnchorPoint(cc.p(0.5, 0.5))
    rwdIcon:setPosition(rwd1:getContentSize().width * 0.5, rwd1:getContentSize().height * 0.5)
    rwdIcon:setScale(0.28)
    rwd1:addChild(rwdIcon)

    local rwd2 = self:getUI("bg.sp.scoreBg.rwdIcon2")
    local rwdId2 = tab.magicTrainingCfg["HEROREWARD"]["value"]
    local param = {itemId = rwdId2, eventStyle = 4, swallowTouches = true}
    local rwdIcon = IconUtils:createItemIconById(param)
    rwdIcon:setAnchorPoint(cc.p(0.5, 0.5))
    rwdIcon:setPosition(rwd2:getContentSize().width * 0.5, rwd2:getContentSize().height * 0.5)
    rwdIcon:setScale(0.28)
    rwd2:addChild(rwdIcon)

    self:setListenReflashWithParam(true)
	self:listenReflash("HappyPopModel", self.listenModelHandle)

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	--保存数据到本地【类似弱网退出情况下，才会保存进度】
        	local isUseLocal = self._hPopModel:getIsUseLocalState()
        	print("===============================================保存")
        	if (self._isTimeStart and not self._isGameOver) or isUseLocal then
        		self._hPopModel:saveLocalData(self._tempTime)
        	else
        		self._hPopModel:clearAndRestart()
        	end

            UIUtils:reloadLuaFile("activity.happyPop.HappyPopView")
            UIUtils:reloadLuaFile("activity.happyPop.HappyPopTipView")
            UIUtils:reloadLuaFile("activity.happyPop.HappyPopRankView")
            UIUtils:reloadLuaFile("activity.happyPop.HappyPopRankRuleView")
            UIUtils:reloadLuaFile("activity.happyPop.HappyPopResultView")
            UIUtils:reloadLuaFile("activity.happyPop.HappyPopConst")

        elseif eventType == "enter" then
        	
        end
    end)
end

function HappyPopView:listenModelHandle(inParam)
	local tipDes
	if inParam == "acEnd" then   		--活动结束
		tipDes = lang("MAGICTRAINING_END_TIPS1")
	elseif inParam == "cheat" then   	--作弊活动关闭
		tipDes = lang("MAGICTRAINING_CHEAT_TIPS1")
	end

	if tipDes then
		self._viewMgr:showDialog("global.GlobalOkDialog", {
			desc = tipDes, 
			button = "确定", 
	    	callback = function()
	    		--关闭二级界面
				self._hPopModel:notifyChildViewClose() 
				self:close()
	    	end}, true)
	end
end

function HappyPopView:reflashUI()
	if self._isGameOver then
		return
	end
	
	self._data = self._hPopModel:getData()
	self:firstSpGuide()  --引导
	--生成牌
	self:createCard()
	--倒计时
	if self._data["info"] and self._data["info"]["lt"] then
    	self._tempTime = self._data["info"]["lt"]
    else
    	self._tempTime = tab.magicTrainingCfg["ROUNDTIME"].value or 0
    end
    self._maxTime = tab.magicTrainingCfg["ROUNDTIME"].value or 0

    local countNum = self:getUI("bg.sp.Image_83.timeStr")
	local showTime = self:getTimeStr(self._tempTime)
	countNum:setString(showTime)
    self._progress:setPercentage((self._tempTime / self._maxTime) * 100)
    self:refreshProgress()

    --刷新ui
	self:refreshUI()
end

function HappyPopView:createCard()
	local listBg = self:getUI("bg.cardBg.cardList")
	local offsetX, offsetY = 5, 5
	local size1, size2 = listBg:getContentSize().width, 72
	local sysMagicTraining = tab.magicTraining

	for i=1, 36 do
		repeat
			local a, c = math.modf(i / 6)  	--行
		    local b = math.fmod(i, 6)   	--列

			--位置
		    local posx, posY, index
		    if c == 0 then
		    	posX = (72 + offsetX) * 5
		    	posY = size1 - (72 + offsetY) * (a - 1)
		    	index = a .. "_" .. 6
		    else
		    	posX = (72 + offsetX) * (b - 1)
		    	posY = size1 - (72 + offsetY) * a
		    	index = (a + 1) .. "_" .. b
		    end

			--读取进度状态
		    local matchList = self._data["match"]
		    if matchList and next(matchList) then
		    	local isSame = false
		    	for p,q in ipairs(matchList) do
			    	for m,n in ipairs(q) do
			    		if index == n then
			    			isSame = true
			    		end
			    	end
			    end
			    if isSame then
		    		break
		    	end
		    end
		    
		    local node = ccui.Layout:create()
		    node:setAnchorPoint(cc.p(0.5, 0.5))  --0, 1
	    	node:setContentSize(size2, size2)
	    	node:setCascadeOpacityEnabled(true, true)
	    	node:setOpacity(0)
	    	node:setScale(0)
		    listBg:addChild(node)
		    table.insert(self._cards, node)
		    
		    node.revertType = 1
		    node:setPosition(posX + 2 + node:getContentSize().width * 0.5, posY - node:getContentSize().height * 0.5)

		    node.id = index
		    node.sysId = self._data["card"][index]
		    node.type = sysMagicTraining[node.sysId].type
		    node.value = sysMagicTraining[node.sysId].value
		    node.relative = sysMagicTraining[node.sysId].relative

		    --正反面
		    for k=1,2 do
		    	if k == 1 then
		    		local card = ccui.ImageView:create("ac_hPop_card4.png", 1) 
			    	card:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5)
			    	card:ignoreContentAdaptWithSize(false)
			    	node["card1"] = card
			    	card.type = 1
					node:addChild(card)
		    	else
		    		local card = ccui.ImageView:create("ac_hPop_card1.png", 1) 
			    	card:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5)
			    	card:ignoreContentAdaptWithSize(false)
			    	node["card2"] = card
			    	card.type = 2
					node:addChild(card)

					card:setVisible(false)
		    		self:createCardSp(card, node)
		    	end

		    	if HappyPopConst.isShow then
		    		local curValue = cc.Label:createWithTTF(self._data["card"][node.id], UIUtils.ttfName, 24)
					curValue:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5 + 20)
					curValue:setColor(UIUtils.colorTable.ccUIBaseColor4)
					curValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
					node:addChild(curValue)

					local curid = cc.Label:createWithTTF(node.id, UIUtils.ttfName, 18)
					curid:setPosition(node:getContentSize().width * 0.5, node:getContentSize().height * 0.5 - 20)
					curid:setColor(UIUtils.colorTable.ccUIBaseColor2)
					curid:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
					node:addChild(curid)
		    	end
		    end

		    --开场动画
		    local time = math.random(1, 30) / 100
		    node:runAction(cc.Sequence:create(
		     	cc.DelayTime:create(time),
		     	cc.Spawn:create(
		     		cc.FadeIn:create(0.2),
		     		cc.ScaleTo:create(0.2, 1)
		     		)
		     	))

		    self:registerClickEvent(node, function()
		    	if self._curShowNum >= 6 then
		    		return
		    	end
		    	if node.revertType == 1 then    --1背面 2正面
		    		self._curShowNum = self._curShowNum + 1
		    	end

		    	node:setTouchEnabled(false)
		    	self:resume()
		    	--开始倒计时
		    	if not self._isTimeStart then 
		    		self:timeCountDown()
		    	end

		    	--检查匹配牌
		    	self:checkDoubleCards(node)
		    	
		    	--翻牌
		    	self:revertCard(node)
		    	end)
		until true
	end
end

function HappyPopView:createCardSp(inCard, inNode)
	if self._data["card"] == nil then
		return
	end

	local value = inNode.value or 202
	local resImg, framImg, scale = "", "", 1
	if inNode.type == HappyPopConst.cardType.skill or 
	 inNode.type == HappyPopConst.cardType.master then   		--小技能 / 大招
		resImg = tab.playerSkillEffect[value]["art"] .. ".png"
		framImg = "ac_hPop_card3.png"
		scale = 0.85

	elseif inNode.type == HappyPopConst.cardType.hero then   	--英雄
		resImg = tab.hero[value]["herohead"] .. ".jpg"
		framImg = "ac_hPop_card2.png"
		scale = 0.8

	elseif inNode.type == HappyPopConst.cardType.clock then   	--时钟
		resImg = "ac_hPop_shalou.png"
		framImg = "ac_hPop_card2.png"
	end

	if resImg ~= "" then
		local sp = ccui.ImageView:create(resImg, 1)
		sp:setPosition(inCard:getContentSize().width * 0.5, inCard:getContentSize().height * 0.5)
		sp:setScale(scale)
		inCard:addChild(sp)

		local fram = ccui.ImageView:create(framImg, 1)
		fram:setPosition(inCard:getContentSize().width * 0.5, inCard:getContentSize().height * 0.5)
		inCard:addChild(fram, 1)
	end
end

function HappyPopView:createLeftSpAnim(anim1, anim2)
	local bg = self:getUI("bg")
	if self._spAnim then
		self._spAnim:removeFromParent(true)
		self._spAnim = nil
	end
	spineMgr:createSpine("xinshouyindao", function (spine)
        spine.endCallback = function ()
            spine:setAnimation(0, anim2, true)
        end 
        local anim = anim1
        spine:setAnimation(0, anim, true)
        spine:setPosition(200, 370)
        spine:setScale(0.8)
        self._spAnim = spine
        bg:addChild(spine, 100)
    end)
end

--检查匹配做标记
function HappyPopView:checkDoubleCards(inCard)
	if self._lastCard == nil then
		self._lastCard = inCard   	--记录上一个匹配牌

		if inCard.type == HappyPopConst.cardType.hero or inCard.type == HappyPopConst.cardType.clock then
			self:createLeftSpAnim("jingya", "pingdan")
		end

	else
		if self._lastCard["id"] ~= inCard.id then   --匹配对【非同一张牌】
			local matchCard = self._lastCard
			matchCard:setTouchEnabled(false)

			inCard["match2"] = matchCard   --match2 匹配
			matchCard["match1"] = inCard   --match1 被匹配
			inCard["matchType"] = 1   --1不匹配 2匹配

			--是否匹配
			local cards = self._data["card"]
			if cards then
				if inCard["sysId"] == matchCard["sysId"] then   --匹配成功
					inCard["matchType"] = 2

					local param = {match = {{inCard.id, matchCard.id}}, matchValue = inCard["type"]}
					self._hPopModel:matchSuccess(param)

					if inCard.type == HappyPopConst.cardType.hero then  		--英雄
						self:heroCardMatch(matchCard, inCard, true)
						self:createLeftSpAnim("xingfen", "pingdan")

					elseif inCard.type == HappyPopConst.cardType.clock then   	--时钟
						local sysTraining = tab.magicTraining 
						self._tempTime = self._tempTime + sysTraining[3001]["value"]
						self._maxTime = self._maxTime + sysTraining[3001]["value"]
						self:createLeftSpAnim("xingfen", "pingdan")
					end
				end
			end

			--匹配牌清空
			self._lastCard = nil
		else
			self._lastCard = nil 	
		end
	end
end

function HappyPopView:revertCard(card)
	function copy1Action(inObj)    --先 隐藏
        inObj:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.15, 0.1, 1),
            cc.CallFunc:create(function()
                inObj:setVisible(false)
                end)
            ))
    end

    function copy2Action(inObj)   	--后 显示
        inObj:runAction(cc.Sequence:create(
            cc.CallFunc:create(function()
                inObj:setVisible(true)
                inObj:setScaleX(0)
                end),
            cc.DelayTime:create(0.15),
            cc.ScaleTo:create(0.15, 1, 1),
            cc.CallFunc:create(function()
            	if card.isHero == 1 then    --英雄牌连带的大招牌消除
            		for i,v in ipairs(self._heroCards) do
            			v:runAction(cc.Sequence:create(
            				cc.DelayTime:create(0.25),
            				cc.CallFunc:create(function()
            					if i == #self._heroCards then
		            				self:createXiaoChuAnim(v, true)
		            				self._heroCards = {}
		            			else
		            				self:createXiaoChuAnim(v)
		            			end

            					v:setVisible(false)
            					end)
            				))
            		end

            	elseif card.match1 == nil and card.match2 == nil then  --是否正在被匹配
            		card:setTouchEnabled(true)
            		if card.revertType == 1 then
            			self._curShowNum = self._curShowNum - 1
            		end
                end
                end),
            cc.DelayTime:create(0.3),    --是否匹配
            cc.CallFunc:create(function()
            	if card.match2 ~= nil then
            		if card.matchType == 1 then  	--不匹配
            			local matchCard = card.match2
	            		card.match2 = nil
	            		matchCard.match1 = nil
	            		self:revertCard(matchCard)
	            		self:revertCard(card)
            		else  							--匹配成功
            			local matchCard = card.match2
            			card.match2 = nil
						matchCard.match1 = nil

            			self._curShowNum = self._curShowNum - 2

						--匹配动画
						if card.type == 3 then   --英雄牌
							self:heroCardMatch(matchCard, card)
						else
							self:createXiaoChuAnim(matchCard)
							self:createXiaoChuAnim(card, true)
							matchCard:setVisible(false)
							card:setVisible(false)
						end

						--当局结束，请求后端换牌或领奖
						local matches = self._data["match"] or {}
						if #matches >= 18 then
							if card.type == 4 then   --最后一副是时钟牌,更新时间
								self:gameOver(matchCard, card)
							else
								self:gameOver()
							end
						end
            		end
            	end
                end)
            ))
    end

    local card1 = card["card1"]  --正面
    local card2 = card["card2"]  --反面 图案面
    if not card1 or not card2 then
    	return
    end

    card:setTouchEnabled(false)    
    local lastRevert = card["revertType"]
    if lastRevert == 1 then
    	card["revertType"] = 2
    	card1:stopAllActions()
    	card1:setVisible(true)

    	card2:stopAllActions()
    	card2:setVisible(false)

        copy1Action(card1)
        copy2Action(card2)
    else
    	card["revertType"] = 1
    	card2:stopAllActions()
    	card2:setVisible(true)

    	card1:stopAllActions()
    	card1:setVisible(false)

        copy1Action(card2)
        copy2Action(card1)
    end
end

--英雄牌对应的大招翻牌
function HappyPopView:heroCardMatch(card1, card2, isModel)
	local needId = card1["relative"]
	if not self._heroCards then
		self._heroCards = {}
	end
	
	if isModel then   --model处理 记录匹配牌
		table.insert(self._heroCards, card1)
		table.insert(self._heroCards, card2)

		local num = 0
		local tempTable = {}
		for i,v in ipairs(self._cards) do
			if v:isVisible() and v["sysId"] == needId then
				v:setTouchEnabled(false)
				table.insert(self._heroCards, v)
				
				num = num + 1
				local index, temp = math.modf(num / 2)
				if temp == 0 then
					index = index
				else
					index = index + 1
				end
				if not tempTable[index] then
					tempTable[index] = {}
				end
				table.insert(tempTable[index], v.id)
			end
		end
		if #tempTable > 0 then
			local param = {match = tempTable, matchValue = 2}
			self._hPopModel:matchSuccess(param)
		end
		
	else
		if #self._heroCards == 2 then
			self:createXiaoChuAnim(card1)
			self:createXiaoChuAnim(card2, true)
			card1:setVisible(false)
			card2:setVisible(false)
			self._heroCards = {}
		else
			for i,v in ipairs(self._heroCards) do
				if i == #self._heroCards then
					v.isHero = 1
				end

				if v.type ~= HappyPopConst.cardType.hero then
					self:revertCard(v)
				end
			end
		end
	end
end

--匹配后消除动画
function HappyPopView:createXiaoChuAnim(inCard, isEnd)
	local xiaochu = mcMgr:createViewMC("xiaochu_fashutexun", false, true)
	local realPosX = inCard:getPositionX() 
	local realPosY = inCard:getPositionY()
	xiaochu:setPosition(realPosX, realPosY)
	inCard:getParent():addChild(xiaochu)

	if inCard["type"] == 4 then  --时钟牌
		xiaochu:addCallbackAtFrame(7, function()
			self:createFeiXingAnim(inCard, isEnd)
			end)
	else
		self:createTxtAnim(inCard.type)
	end
end

--匹配后时钟牌飞翔点动画
function HappyPopView:createFeiXingAnim(inCard, isEnd, inType)
	local cardBg = self:getUI("bg.cardBg")
	--point1  timeBar
	local timeBar = self:getUI("bg.sp.Image_83")
	local point1 = timeBar:convertToWorldSpace(cc.p(0, 0)) 
    point1 = cardBg:convertToNodeSpace(point1)
    point1.x = point1.x + timeBar:getContentSize().width/2
    point1.y = point1.y + timeBar:getContentSize().height/2 

    local point2 = inCard:convertToWorldSpace(cc.p(0, 0)) 
    point2 = cardBg:convertToNodeSpace(point2)
    point2.x = point2.x + inCard:getContentSize().width/2
    point2.y = point2.y + inCard:getContentSize().height/2 

	local dis = {45, 40, 30, 20, 10, 0}
	local timeDis = {0.5, 0.55, 0.6, 0.65, 0.7}
	for i=1, 5 do
		local disX, disY = point2.x - point1.x, point2.y - point1.y
		local temp = math.random(dis[i], dis[i + 1])
		local posX = point2.x - temp
		local posY = point2.y - temp * disY / disX + math.random(-10, 10)
		local feixing = mcMgr:createViewMC("feixing_fashutexun", false)
		feixing:setPosition(posX, posY)
		cardBg:addChild(feixing, 10)

		feixing:runAction(cc.Sequence:create(
            cc.EaseIn:create(cc.MoveTo:create(timeDis[i], cc.p(point1.x, point1.y)), 1.1),
            cc.CallFunc:create(function()
            	feixing:removeFromParent(true)

            	--文字特效
            	if i == 5 and isEnd then
            		if inType then
            			self:createTxtAnim(inType)
            		else
            			self:createTxtAnim(inCard.type)
            		end
	                
            	end
                end)
            ))
	end
end

--匹配后文字缩放动画
function HappyPopView:createTxtAnim(inType)
	if not inType then
		return
	end

	local des4 = self:getUI("bg.sp.scoreBg.des4")
	local des1 = self:getUI("bg.sp.scoreBg.des1")
	local des2 = self:getUI("bg.sp.scoreBg.des2")
	des1.lastStr = des1:getString()
	des2.lastStr = des2:getString()
	des4.lastStr = des4:getString()
	self:refreshUI()

    local sysTraining = tab.magicTraining

    local function textAnim(inText, inColor)
    	local nowStr = inText:getString()
    	if inText.lastStr and nowStr == inText.lastStr then
    		return
    	end

    	inText:setColor(UIUtils.colorTable.ccUIBaseColor2)
    	inText:runAction(cc.Sequence:create(
			cc.ScaleTo:create(0.2, 1.3),
			cc.ScaleTo:create(0.2, 1),
			cc.CallFunc:create(function()
				inText:setColor(inColor)
				end)
			))
    end
    
    textAnim(des4, cc.c4b(250, 238, 160, 255))
	if inType == 1 or inType == 2 then   --普通牌
		textAnim(des1, cc.c4b(250, 230, 200, 255))
	
	elseif inType == 3 then 	--英雄牌
		textAnim(des2, cc.c4b(250, 230, 200, 255))
		
	elseif inType == 4 then  	--时间牌
		local timeAdd = sysTraining[3001]["value"]
		local tipNum = cc.Label:createWithTTF("+".. timeAdd .. "秒", UIUtils.ttfName, 24)
		tipNum:setPosition(self._progress:getContentSize().width * 0.5, self._progress:getContentSize().height * 0.5 + 60)
		tipNum:setColor(UIUtils.colorTable.ccUIBaseColor2)
		tipNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		self._progress:addChild(tipNum, 1)
		tipNum:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.5, cc.p(0, 25)),
			cc.CallFunc:create(function()
				tipNum:removeFromParent(true)
				end)
			))

		local fankui = mcMgr:createViewMC("fankui_fashutexun", false)
		fankui:setPosition(self._progress:getContentSize().width * 0.5, self._progress:getContentSize().height * 0.5)
		self._progress:addChild(fankui, 10)
	end
end

function HappyPopView:refreshUI()
	local info = self._data["info"]
	local sysConfig = tab.magicTrainingCfg

	local score1 = self:getUI("bg.sp.scoreBg.des1")  --卷轴
	local score2 = self:getUI("bg.sp.scoreBg.des2")  --碎片
	local score3 = self:getUI("bg.sp.scoreBg.des4")

	score1:setString((info["s"] or 0) .. "/" .. sysConfig["LIMIT_SCROLL_NUM"].value)
	score2:setString((info["n"] or 0) .. "/" .. sysConfig["LIMIT_HERO_NUM"].value)
	score3:setString(self._data["source"] or 0)
end

function HappyPopView:refreshProgress()
	local countNum = self:getUI("bg.sp.Image_83.timeStr")
	if self._tempTime <= 10 then
    	self._progress:setColor(cc.c4b(196,31,31,255))
        self._progress:setSaturation(95) 		--饱和度
        self._progress:setHue(-20)   			--色度
        countNum:setColor(cc.c4b(205,32,30,255))
    else
    	self._progress:setColor(cc.c4b(28,162,22,255))
        self._progress:setSaturation(50) 		--饱和度
        self._progress:setHue(0)   				--色度
        self._progress:setBrightness(0)
        countNum:setColor(cc.c4b(39,247,58,255))
    end
end

function HappyPopView:timeCountDown()
	self._isTimeStart = true
	self._clickTime = self._userModel:getCurServerTime()

	local Image_83 = self:getUI("bg.sp.Image_83")
    local countNum = self:getUI("bg.sp.Image_83.timeStr")

    local minute, second, tempValue    
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempValue = self._tempTime

            local showTime = self:getTimeStr(tempValue)
            countNum:setString(showTime)
            local perNum = (self._tempTime / self._maxTime) * 100
            self._progress:setPercentage(perNum)
            self:refreshProgress()  --颜色
          
            if self._tempTime <= 0 then
                self._tempTime = 0
                self:gameOver()   --游戏结束
                self._isGameOver = true
            end

            self._tempTime = self._tempTime - 1
        end),cc.DelayTime:create(1))
    ))
end

function HappyPopView:getTimeStr(inTime)
	local showTime = ""
	local minute = math.floor(inTime/60)
    inTime = inTime - minute*60
    local second = math.fmod(inTime, 60)
    local showTime = string.format("%.2d:%.2d", minute, second)
    if self._tempTime <= 0 then
        showTime = "00:00"
    end

    return showTime
end

--inType: 1换牌  2时间到
function HappyPopView:gameOver(card1, card2)
	self._clipLayer:setVisible(true)
	if self._isGameOver then   --游戏结束 防止跟换牌请求冲突
		return
	end

	self:pause()  --暂停计时

	--最小翻牌时间检查
	local curTime = self._userModel:getCurServerTime()
	if curTime - self._clickTime <= tab.magicTrainingCfg["FAST_CLEAN_TIME"]["value"] then
		ApiUtils.playcrab_lua_error("happyPop openCard=====", curTime, self._clickTime, curTime - self._clickTime)
		self._hPopModel:notifyCheatClose()
		return
	end

	--重新开始
	local function callback1()   
		local listBg = self:getUI("bg.cardBg.cardList")
		listBg:removeAllChildren()
		self._lastCard = nil
		self._isGameOver = false
		self._isTimeStart = false
		self._curShowNum = 0
		self:stopAllActions()  --计时器删除

		if self._timeAction and self._timeAction["stop"] then
			self._timeAction:stop()
		end

		--关闭二级界面
		self._hPopModel:notifyChildViewClose()
		self._clipLayer:setVisible(false)

		self._serverMgr:sendMsg("MagicTrainingServer", "enter", {isLoad = 1}, true, {}, function(result, errorCode)
            self:reflashUI()
        end)
	end

	--关闭游戏
	local function callback2() 
		--关闭二级界面
		self._hPopModel:notifyChildViewClose() 
		self:close()
	end

	--换牌重新开始
	local function callback3()
		local listBg = self:getUI("bg.cardBg.cardList")
		listBg:removeAllChildren()
		self._lastCard = nil
		self._isGameOver = false
		self._curShowNum = 0

		self._clipLayer:setVisible(false)

		self:resume()
		--生成牌
		self:createCard()
	end

	--游戏结算界面
	local function callback4(inData)
		self._viewMgr:showDialog("activity.happyPop.HappyPopResultView", {
			callback1 = callback1, 
			callback2 = callback2,
			data = inData.data,
			lastInfo = inData.lastInfo
			}, true)
	end

	local lastInfo = self._data["info"]
	local inParam = {positions = json.encode(self._data["match"]), countDown = self._tempTime}
	self._serverMgr:sendMsg("MagicTrainingServer", "openCard", inParam, true, {}, function(result, errorCode)
		--报错日志打点
		if result["error"] and result["error"] ~= 0 then
			ApiUtils.playcrab_lua_error("happyPop openCard====="..result["error"], serialize(inParam))
			return
		end

		self._cards = {}
		if result["rewards"] then  --领奖
			callback4({data = result, lastInfo = lastInfo})
		else
			if card1 and card2 then   --最后一张是时间牌
				self:createFeiXingAnim(card1)
				self:createFeiXingAnim(card2, true, card2.type)
			end
			callback3()
		end
		end)
end

function HappyPopView:firstSpGuide()
	local isFrist = self._data["isFirst"] or 0   --1第一次 0不是第一次
	if isFrist ~= 1 then  --不是第一次
		self:createLeftSpAnim("pingdan", "pingdan")
	else
		--改本地状态
        self._hPopModel:setFirstGuideState()

		self._data["isFirst"] = 0
		self._guideLayer:setVisible(true)

		local click = self:getUI("bg.guideLayer.click")
		local quan = mcMgr:createViewMC("c1_guidecircle-HD", true)
		local posX, posY = click:getContentSize().width * 0.5, click:getContentSize().height * 0.5
        quan:setPosition(posX, posY)
        click:addChild(quan)

        local shouzhi = mcMgr:createViewMC("shou_guidexiaoshou", true)
        shouzhi:setPosition(posX, posY)
        shouzhi:setRotation(180)
        click:addChild(shouzhi)

        self._guideNum = 1
        self:createLeftSpAnim("zhiyin", "pingdan")
        local des = self:getUI("bg.guideLayer.des")
        des:setString(lang("MAGICTRAINING_GUILD_TIPS" .. self._guideNum))

        self:registerClickEvent(click, function()
        	self._guideNum = self._guideNum + 1
        	if self._guideNum > 2 then
        		self._guideLayer:setVisible(false)
        		self:createLeftSpAnim("pingdan", "pingdan")
        		return
        	end
        	self:createLeftSpAnim("zhiyin", "pingdan")
        	des:setString(lang("MAGICTRAINING_GUILD_TIPS" .. self._guideNum))
        	end)
	end
end

return HappyPopView