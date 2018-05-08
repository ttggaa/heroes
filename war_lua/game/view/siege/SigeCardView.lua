--[[
    Filename:    SigeCardView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-09-7 14:39:47
    Description: File description
--]]

local MAX_SCREEN_WIDTH = MAX_SCREEN_WIDTH
local destX
local destPoint
local cpeed = 1
local repeatX = MAX_SCREEN_WIDTH - 3072 + 4
local Sprite = cc.Sprite
local _spriteList = {}
local _beiginPos = {}
local onceTime1 = 8
local ccRepeatForever = cc.RepeatForever
local ccSequence = cc.Sequence
local ccMoveTo = cc.MoveTo
local ccCallFunc = cc.CallFunc
local ccEaseOut = cc.EaseOut
local ccSpawn = cc.Spawn
local ccScaleTo = cc.ScaleTo
local ccMoveBy = cc.MoveBy
local ccRotateBy = cc.RotateBy
local ccFadeIn = cc.FadeIn
local ccFadeOut = cc.FadeOut
local ccDelay = cc.DelayTime
local ccpoint = cc.p
local colorTable = UIUtils.colorTable
local delayTime = {0,0.1,0.2,0.3,0.4}


local SigeCardView = class("SigeCardView",BaseView)


function SigeCardView:ctor(param)
    SigeCardView.super.ctor(self)
	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("siege.SigeCardView")
        elseif eventType == "enter" then 
        end
    end)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._weaponModel = self._modelMgr:getModel("WeaponsModel")
    self._playerModel = self._modelMgr:getModel("PlayerTodayModel")
    self._bagLimitCount = tab:Setting("WEAPON_LIMIT").value
    self._quality = {1, 1, 1, 1, 1}
    self._takeLimitCount = tab:Setting("DRAW_SW_LIMIT").value
    self._preCostType = nil
end

function SigeCardView:getAsyncRes()
    return 
    {
        {"asset/ui/sigeCard.plist", "asset/ui/sigeCard.png"}
    }
end

function SigeCardView:cacheCardSprite()

	local pos1 = self._bottomPanel2:convertToWorldSpace(cc.p(self._longImage:getPositionX(),self._longImage:getPositionY()))
	local pos2 = self:convertToNodeSpace(pos1)

	local height = pos2.y+75
	local gap = 40
	local cardW = 144
	local posX = (MAX_SCREEN_WIDTH*0.5 - cardW * 2 - gap * 2) - MAX_SCREEN_WIDTH
	local bg = self._bg
	local tabData = tab.siegeEquip
	for i=1,5 do 
		local sprite = Sprite:createWithSpriteFrameName("sigeCardQuality_2.png")
		sprite:setAnchorPoint(0.5,0.5)
		_spriteList[i] = sprite

		local panel = ccui.Layout:create()
		panel:setContentSize(sprite:getContentSize())
		sprite:addChild(panel,-20)
		sprite.panel = panel 

		local boxNode = ccui.Layout:create()
		boxNode:setContentSize(80,80)
		sprite:addChild(boxNode,-20)
		boxNode:setPosition(0,50)

		local spriteTop = Sprite:createWithSpriteFrameName("sigeCard_image1.png")
		spriteTop:setAnchorPoint(0.5,0.5)
		spriteTop:setPosition(75.6,85.5)
		sprite:addChild(spriteTop,2)
		sprite.top = spriteTop
		spriteTop:setCascadeOpacityEnabled(true,true)

		local yingzi = Sprite:createWithSpriteFrameName("sigeCard_yingzi.png")
		yingzi:setAnchorPoint(0.5,0.5)
		yingzi:setPosition(75.6,10)
		sprite:addChild(yingzi,-2)

		local spriteTop2 = Sprite:createWithSpriteFrameName("sigeCard_samllBar1.png")
		spriteTop2:setAnchorPoint(0.5,0.5)
		spriteTop2:setPosition(80,100)
		spriteTop:addChild(spriteTop2,1)
		spriteTop.top2 = spriteTop2

		local spriteTop3 = Sprite:createWithSpriteFrameName("sigeCard_samllBar2.png")
		spriteTop3:setAnchorPoint(0.5,0.5)
		spriteTop3:setPosition(80,100)
		spriteTop:addChild(spriteTop3,1)
		spriteTop.top3 = spriteTop3

		local name = cc.Label:createWithTTF("装备名称", UIUtils.ttfName, 20)
		name:setAnchorPoint(0.5,0.5)
		name:setPosition(75.6, 23)
	    sprite.name = name
	    sprite:addChild(name,1)

	    local equip = Sprite:createWithSpriteFrameName("ps_shixueqishu.png")
		equip:setAnchorPoint(0.5,0.5)
		equip:setPosition(75.6,90)
		sprite:addChild(equip,1)
		sprite.equip = equip

		registerTouchEvent(panel,nil,nil,function ()
			if self._result then
				local sData = self._result[i]
				local data = tabData[sData.typeId]
				local viewMgr = self._viewMgr or ViewManager:getInstance()
				viewMgr:showHintView("global.GlobalTipView",{tipType = 23, node = boxNode, id = tonumber(sData.typeId),forceColor = color,notAutoClose=true, level = 1})
			end
		end)

		_beiginPos[i] = {}
		local data = _beiginPos[i]
		data[1] = posX+(i-1)*(gap+cardW)
		data[2] = height
		self:addChild(sprite,i)
		sprite:setPosition(cc.p(data[1],data[2]))
	end
end


function SigeCardView:getRegisterNames()
	return{
		{"commonBtn","bottomPanel.commonBtn"},
		{"highBtn","bottomPanel.highBtn"},
		{"bg", "bg"},
		{"sureBtn", "bottomPanel2.sureBtn"},
		{"buy5Btn", "bottomPanel2.buy5Btn"},
		{"bottomPanel", "bottomPanel"},
		{"bagBtn", "topLeft.bagBtn"},
		{"topLeft", "topLeft"},
		{"imageBar", "bottomPanel2.imageBar"},
		{"longImage", "bottomPanel2.longImage"},
		{"bottomPanel2", "bottomPanel2"},
		{"preLook", "leftBottom.preSee"},
		{"hCostImage", "bottomPanel.hCostImage"},
		{"hCostLabel", "bottomPanel.hCostLabel"},
		{"dCostImage", "bottomPanel2.costAgainNode.dCostImage"},
		{"dCostLabel", "bottomPanel2.costAgainNode.dCostLabel"},
		{"coCostImage", "bottomPanel.coCostImage"},
		{"coCostLabel", "bottomPanel.coCostLabel"},
		{"text", "topLeft.bagBtn.text"},
		{"leftTimes", "centerBottom.leftTimes"},
		{"touchPanel", "touchPanel"},
		{"firstFree", "bottomPanel.firstFree"},
		{"Tips", "bottomPanel.Tips"}
	}
end

function SigeCardView:getBgName()
    return "sigeCardBg.jpg"
end

function SigeCardView:setNavigation()
	local isUserLuck = self._userModel:drawUseLuckyCoin()
	if isUserLuck then
		self._viewMgr:showNavigation("global.UserInfoView",{types = {"LuckyCoin", "Gem", "siegePropCoin"},titleTxt = "配件制造", longBg="sigeCard_topImage.png"})
	else
		self._viewMgr:showNavigation("global.UserInfoView",{types = {"Gold", "Gem", "siegePropCoin"},titleTxt = "配件制造", longBg="sigeCard_topImage.png"})
	end
end


-- 初始化UI后会调用, 有需要请覆盖
function SigeCardView:onInit()

	destX = (960-MAX_SCREEN_WIDTH)*0.5 - 1024

	self._longImage:setPositionX(destX)

	self:runLongImage()

	self:registerClickEvent(self._commonBtn,function()
		self:onCommonMake(1)
		self._preCostType = 4
	end)

	self:registerClickEvent(self._highBtn, function()
		self:onHighMake(1)
		self._preCostType = 2
	end)

	self:registerClickEvent(self._preLook, function()
		self:onPreLook()
	end)

	self:registerClickEvent(self._sureBtn, function()
		self._preCostType = nil
		self:onSure()
	end)

	self:registerClickEvent(self._buy5Btn,handler(self,self.onBuyAgain))

	self:registerClickEvent(self._bagBtn, function()
		self:onWeaponBag()
	end)

	ScheduleMgr:delayCall(200, self, function()
		self:cacheCardSprite()
	end)

	self:registerClickEvent(self._touchPanel, function()
		self:onQuick()
	end)

	self._touchPanel:setContentSize(MAX_SCREEN_WIDTH,MAX_SCREEN_HEIGHT)
	self._touchPanel:setVisible(false)
	self._sureBtn:setVisible(false)
	self._buy5Btn:setVisible(false)
	self._bottomPanel:setCascadeOpacityEnabled(true,true)

	self._imageBar:ignoreContentAdaptWithSize(false)
	self._imageBar:setContentSize(MAX_SCREEN_WIDTH,self._imageBar:getContentSize().height)

	--消耗
	local isUserLuck = self._userModel:drawUseLuckyCoin() 
	local hCostData = tab:Setting("DRAW_SW_COST2").value[1]
	self._hCostType = hCostData[1]
	if isUserLuck then
		self._hCostType = "luckyCoin"
	end
	self._hCostCount = hCostData[3]
	local costImage = IconUtils.resImgMap[self._hCostType]
	self._hCostImage:loadTexture(costImage, 1)
	self._hCostLabel:setString(self._hCostCount)

	--TODO 再次购买 icon 数量显示
	self._dCostImage:loadTexture(costImage, 1)
	self._dCostLabel:setString(self._hCostCount)

	self._costAgainNode = self:getUI("bottomPanel2.costAgainNode")
	self._costAgainNode:setVisible(false)

	local cCostData = tab:Setting("DRAW_SW_COST4").value[1]
	self._cCostType = cCostData[1]
	self._cCostCount = cCostData[3]
	costImage = IconUtils.resImgMap[self._cCostType]
	self._coCostImage:loadTexture(costImage, 1)
	self._coCostLabel:setString(self._cCostCount)

    self._text:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)

    self._firstFree:setVisible(false)
    self._coCostLabel:setVisible(false)
    self._coCostImage:setVisible(false)

    -- [[展示剩余次数by guojun
    local topCenterNode = ccui.Widget:create()
    topCenterNode:setPosition(MAX_SCREEN_WIDTH*0.5,50)
    self._topLeft:addChild(topCenterNode,99)
    local leftNumBg = ccui.ImageView:create()
    leftNumBg:loadTexture("globalImageUI_commonGetBg2.png",1)
    leftNumBg:setScale(1,0.5)
    topCenterNode:addChild(leftNumBg)
    -- 创建描述label
    self._topLabs = {}
    local labDes = {"今日剩余","高级制造","次数：","","次",}
    for i=1,5 do
    	local label = ccui.Text:create()
	    label:setFontName(UIUtils.ttfName)
	    label:setFontSize(20)
	    label:setString(labDes[i])
	    topCenterNode:addChild(label)
	    table.insert(self._topLabs,label)
    end
    self._topLabs[2]:setColor(cc.c3b(250,255,222))
    self._topLabs[2]:enable2Color(1,cc.c4b(248,220,126,255))
    self._topLabs[2]:enableOutline(cc.c4b(130,70,10,255),1)
    self._leftNumLab = self._topLabs[4]
    self._leftNumLab:setString("10")
    UIUtils:alignNodesToPos(self._topLabs)
    --]]
    self:updateLefttimesDes()
end

--还有多少次获得传说配件
function SigeCardView:updateLefttimesDes()
	local weaponNum = self._playerModel:getDrawAward().weaponNum or 0
	
	local leftCount = (25 - weaponNum % 25)/5
	self._leftTimes:setString(leftCount)
	if leftCount == 1 then
		-- self._Tips:setVisible(true)
		self._Tips:setString("必得传说配件")
		self._Tips:setColor(cc.c3b(255,116,33))
	else
		self._Tips:setString("必得史诗配件")
		self._Tips:setColor(cc.c3b(255,120,255))
	end

	-- 剩余高级制造次数
	local day71 = self._playerModel:getData().day71 or 0
	print("今日已经抽取次数",day71)
	local leftNum = (self._takeLimitCount - day71)*0.2
	self._leftNumLab:setString(leftNum)
    UIUtils:alignNodesToPos(self._topLabs)
    if leftNum and leftNum > 0 then
    	self._topLabs[4]:setColor(cc.c3b(240,240,0))
    else
    	self._topLabs[4]:setColor(cc.c3b(205,32,30))
    end
    

	--首次抽，免费
	local freeWeaponFirst = self._playerModel:getDrawAward().freeWeaponFirst or 0
	if freeWeaponFirst ~= 0 then
		self._coCostLabel:setVisible(true)
    	self._coCostImage:setVisible(true)
    	self._firstFree:setVisible(false)
	else
		self._firstFree:setVisible(true)
	end
	self._freeWeaponFirst = freeWeaponFirst

	local have = self._userModel:getData()[self._cCostType] or 0
	if have < self._cCostCount then
		self._coCostLabel:setColor(cc.c4b(205,32,30,255))
	else
		self._coCostLabel:setColor(cc.c4b(255,255,255,255))
	end

	local have = self._userModel:getData()[self._hCostType] or 0
	if have < self._hCostCount then
		self._hCostLabel:setColor(cc.c4b(205,32,30,255))
	else
		self._hCostLabel:setColor(cc.c4b(255,255,255,255))
	end

end

function SigeCardView:onQuick()
	cpeed = 10
	self._touchPanel:setVisible(false)
	self._quickStop = true
	self:lock(-1)
	for i=1,5 do 
		local sprite = _spriteList[i]
		local pos = _beiginPos[i]
		local top = sprite.top
		local cirle = top.top2

		if sprite.selMc then
			sprite.selMc:removeFromParent(true)
			sprite.selMc = nil
		end

		sprite:runAction(ccSequence:create(
			ccEaseOut:create(ccMoveTo:create(0.5,cc.p(pos[1]+MAX_SCREEN_WIDTH,pos[2])), 3),
			ccCallFunc:create(function()
				cirle:runAction(ccSequence:create(
					ccEaseOut:create(ccRotateBy:create(0.2,360), 2),
					ccDelay:create(delayTime[i]),
					ccCallFunc:create(function()
						local mc1 = mcMgr:createViewMC("gongchengchouka_gongchengchouka", false, true, function(_, sender)
			            end)
				        mc1:setPosition(cc.p(sprite:getContentSize().width*0.5, sprite:getContentSize().height*0.5))
				        sprite:addChild(mc1,4)

	     				if self._quality[i] >= 5 then
	     					local selMc = mcMgr:createViewMC("chengsediguang_gongchengchouka", true,false)
							selMc:setPosition(sprite:getContentSize().width/2,sprite:getContentSize().height/2)
		                	sprite:addChild(selMc,-1)
		                	selMc:setScale(1)
		                	sprite.selMc = selMc
	     				end
						top:runAction(ccSequence:create(
							ccFadeOut:create(0.2),
							ccDelay:create(0.8),
							ccCallFunc:create(function()
								self._sureBtn:setVisible(true)
								self._buy5Btn:setVisible(true)
								self._costAgainNode:setVisible(true)
								self:unlock()
							end)
						))
					end)
				))
			end)
		))
	end
end

--设置再抽一次的花费类型
function SigeCardView:setCostMoneyBtn( ... )
	local have = 0
	local need = 0
	if self._preCostType and self._preCostType == 2 then
		--高级抽卡   花费diamond
		local costImage = IconUtils.resImgMap[self._hCostType]
		have = self._userModel:getData()[self._hCostType] or 0
		self._dCostImage:loadTexture(costImage, 1)
		self._dCostLabel:setString(self._hCostCount)
		need = self._hCostCount
	else
		local costImage = IconUtils.resImgMap[self._cCostType]
		self._dCostImage:loadTexture(costImage, 1)
		self._dCostLabel:setString(self._cCostCount)
		have = self._userModel:getData()[self._cCostType] or 0
		need = self._cCostCount
	end
	if have < need then
		self._dCostLabel:setColor(cc.c4b(205,32,30,255))
	else
		self._dCostLabel:setColor(cc.c4b(255,255,255,255))
	end
end

function SigeCardView:onPreLook()
	self._viewMgr:showDialog("siege.SigeCardPreView",{},true)
end

function SigeCardView:runLongImage()
	local action3 = ccRepeatForever:create(
		ccSequence:create(
			ccMoveBy:create(onceTime1,ccpoint(1024,0)),
			ccCallFunc:create(function()
				self._longImage:setPositionX(destX)
			end)
		)
	)
	self._speed1 = cc.Speed:create(action3, cpeed)
	self._longImage:runAction(self._speed1)
end

--机械背包是否已满
function SigeCardView:checkIsBagFull()
	local data = self._weaponModel:getPropsData()
	if table.nums(data) + 5 > self._bagLimitCount then
		self._viewMgr:showDialog("global.GlobalPromptDialog", {indexId = 13})
		return true
	end
end

--再次抽奖不显示动画
function SigeCardView:onCommonMake(isShow)
	local have = self._userModel:getData()[self._cCostType] or 0
	if have < self._cCostCount and self._freeWeaponFirst > 0 then
		if self._cCostType ~= "gem" then
			self._viewMgr:showDialog("global.GlobalPromptDialog", {indexId = 15})
		else
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function()
				if not self._viewMgr then 
					self._viewMgr = ViewManager:getInstance()
				end
	            self._viewMgr:showView("vip.VipView", {viewType = 0})
	        end})
		end
		return
	end
	if self:checkIsBagFull() then
		return
	end
	self._serverMgr:sendMsg("WeaponServer", "drawSiegeWeapon", {type = 4}, true, {}, function (result)
        -- dump(result, "result=======", 10)
        dump(result,"sige server data")
        self:updateLefttimesDes()
        self._result = result.reward
        self:setReslut(result.reward)
        self._bottomPanel:setVisible(false)
        if isShow then
        	self:onQuick()
	        self:accSpeed(0.5,function()
	        	self:slowDown(1)
	        end)
	    else
	    	self:showCardAgain()
        end
        self:setCostMoneyBtn()
    end)
end

function SigeCardView:showCardAgain( )
	for i=1,5 do
		local sprite = _spriteList[i]
		sprite:setOpacity(0)
		sprite.equip:setOpacity(0)
		sprite.name:setOpacity(0)

		if sprite.selMc then
			sprite.selMc:removeFromParent(true)
			sprite.selMc = nil
		end

		sprite:runAction(ccSequence:create({ccDelay:create(0.5),ccCallFunc:create(function ( ... )
			sprite:setOpacity(255)
			sprite.equip:setOpacity(255)
			sprite.name:setOpacity(255)
		end)}))
	end
end

function SigeCardView:onHighMake(isShow)
	--次数检查
	local day71 = self._playerModel:getData().day71 or 0
	if self._takeLimitCount and day71 >= self._takeLimitCount then
		-- self._viewMgr:showTip("次数用完")
		self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = lang("SIEGECON_TIPS28"),des2 = "提升vip可增加购买次数"},true)
		return
	end
	local have = self._userModel:getData()[self._hCostType] or 0
	if have < self._hCostCount then
        local isLuckyCoin = self._userModel:drawUseLuckyCoin()
        if isLuckyCoin then
        	local needNum = self._hCostCount - have
	        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
	            DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = needNum,callback = function()
	            	self:resetColor()
	            end })
	        end})
	    else
	        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function()
				if not self._viewMgr then 
					self._viewMgr = ViewManager:getInstance()
				end
	            self._viewMgr:showView("vip.VipView", {viewType = 0})
	        end})
	    end
		return
	end
	--背包判满
	if self:checkIsBagFull() then
		return
	end
	self._serverMgr:sendMsg("WeaponServer", "drawSiegeWeapon", {type = 2}, true, {}, function (result)
        -- self._touchPanel:setVisible(true)
        self:updateLefttimesDes()
        self._result = result.reward
        self:setReslut(result.reward)
        self._bottomPanel:setVisible(false)
        if isShow then
        	self:onQuick()
	        self:accSpeed(0.5,function()
	        	self:slowDown(1)
	        end)
	    else
	    	self:showCardAgain()
        end
        self:setCostMoneyBtn()
    end)
end

function SigeCardView:onBuyAgain()
	-- type 2 高级购买  
	-- type 4 普通购买
	if self._preCostType ~= nil then
		if self._preCostType == 2 then
			self:onHighMake()
		else
			self:onCommonMake()
		end
	end
end


function SigeCardView:setReslut(result)
	local tabData = tab.siegeEquip
	for i=1,5 do 
		local sprite = _spriteList[i]
		local name = sprite.name
		local equip = sprite.equip
		local sData = result[i]
		local data = tabData[sData.typeId]
		equip:setSpriteFrame(data.art .. ".png")
		name:setString(lang(data.name))
		print("=================================================id_quality:", sData.typeId, data.quality)
		local quality = data.quality_show    --by wangyan 改用quality_show显示
		name:setColor(colorTable["ccUIBaseColor"..quality])
		sprite:setSpriteFrame("sigeCardQuality_"..quality..".png")
		self._quality[i] = quality
	end
end

function SigeCardView:onSure()
	self._sureBtn:setTouchEnabled(false)
	self:flyAnima()
end

function SigeCardView:onWeaponBag()
	self._viewMgr:showView("weapons.WeaponsToolsBagView")
end

local flyTime = {0.1,0.2,0.3,0.4,0.5}
function SigeCardView:flyAnima()
	local pos1 = self._topLeft:convertToWorldSpace(cc.p(self._bagBtn:getPositionX(),self._bagBtn:getPositionY()))
	local pos2 = self:convertToNodeSpace(pos1)

	for i=1,5 do 
		local sprite = _spriteList[i]
		if sprite.selMc then
			sprite.selMc:removeFromParent()
			sprite.selMc = nil
		end
		sprite:runAction(ccSequence:create(
			ccSpawn:create(
				ccEaseOut:create(ccMoveTo:create(flyTime[i], pos2), 3),
				ccScaleTo:create(flyTime[i], 0.1)
			),
			ccCallFunc:create(function()
				sprite:setVisible(false)
				sprite:setScale(1)
				sprite:setPosition(cc.p(_beiginPos[i][1],_beiginPos[i][2]))
				sprite:setVisible(true)
				local top = sprite.top
				top:setOpacity(255)
				if i == 5 then
					self._sureBtn:setVisible(false)
					self._buy5Btn:setVisible(false)
					self._costAgainNode:setVisible(false)
					self._sureBtn:setTouchEnabled(true)
					self._bottomPanel:setVisible(true)
					self._speed1:setSpeed(1)
					-- self:runLongImage()
				end
			end)
		))
	end
end

--[[
	加速
	@ time 时间
]]
function SigeCardView:accSpeed(time,callBack)
	cpeed = 20
	self._speed1:setSpeed(cpeed)
	ScheduleMgr:delayCall(time*1000, self, function()
        if callBack then
        	callBack()
        end
    end)
end

--减速
function SigeCardView:slowDown(costTime)
	if self._schedule then
        ScheduleMgr:unregSchedule(self._schedule)
        self._schedule = nil
    end

    local reduce = cpeed / costTime
    local time = costTime
    local timeUnit = 10
	self._schedule = ScheduleMgr:regSchedule(timeUnit,self,function()
		print("time",time,"cpeed",cpeed)
		if time <= 0 or cpeed <= 2 then
			if self._schedule then
	            ScheduleMgr:unregSchedule(self._schedule)
	            self._schedule = nil
	        end
	        self._longImage:pause()
	        self._speed1:setSpeed(0)
	        self._longImage:resume()
			self._bottomPanel:setVisible(false)
		else
			cpeed = cpeed - 4
			if cpeed <= 2 then
				self._last = true
			end
			self._speed1:setSpeed(cpeed)
		end
		time = time - 0.3
    end)
end

--恢复平稳1倍速
function SigeCardView:resumeSpeed()
	self._speed1:setSpeed(1)
end

function SigeCardView:resetColor()
	print("SigeCardView:resetColor")
	local have = self._userModel:getData()[self._cCostType] or 0
	if have < self._cCostCount then
		self._coCostLabel:setColor(cc.c4b(205,32,30,255))
	else
		self._coCostLabel:setColor(cc.c4b(255,255,255,255))
	end

	local have = self._userModel:getData()[self._hCostType] or 0
	print(self._hCostType)
	print("have",have)
	print("self._hCostCount",self._hCostCount)
	if have < self._hCostCount then
		self._hCostLabel:setColor(cc.c4b(205,32,30,255))
	else
		self._hCostLabel:setColor(cc.c4b(255,255,255,255))
	end

	self:setCostMoneyBtn()
end

function SigeCardView:onTop()
	self:resetColor()
end

function SigeCardView:onDestroy( )
	SigeCardView.super.onDestroy(self)
	ScheduleMgr:cleanMyselfDelayCall(self)
	if self._schedule then
        ScheduleMgr:unregSchedule(self._schedule)
        self._schedule = nil
    end
end

function SigeCardView:dtor()
	onceTime1 = nil
	ccRepeatForever = nil
	ccSequence = nil
	ccMoveTo = nil
	ccCallFunc = nil
	MAX_SCREEN_WIDTH = nil
	destX = nil
	destPoint = nil
	cpeed = nil
	repeatX = nil
	Sprite = nil
	_spriteList = nil
	_beiginPos = nil
	ccSequence = nil
	ccCallFunc = nil
	ccSpawn = nil
	ccRotateBy = nil
	ccEaseOut = nil
	ccDelay = nil
	colorTable = nil
	ccpoint = nil
end

return SigeCardView