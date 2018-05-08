--[[
    Filename:    ArrowView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-09-27 21:00
    Description: 射箭小游戏
--]]

local ArrowView = class("ArrowView", BaseView)

function ArrowView:ctor()
	ArrowView.super.ctor(self)
	self._arrowModel = self._modelMgr:getModel("ArrowModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	require("game.view.activity.arrow.ArrowConst")
	-- if OS_IS_64 then
 --        package.loaded["game.view.activity.arrow.ArrowConst64"] = nil
 --    else
 --        package.loaded["game.view.activity.arrow.ArrowConst"] = nil
 --    end

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --随机种子
	self._arrowList = {}	--箭列表
	self._monsterList = {} 	--怪物列表

	self._mul = 111 					--防改内存参数[选择箭数,]  箭数/血量/能量值
	self._monsterIndex = 0  			--随机怪物生成的id
	self._arrowIndex = 0 				--随机生成的箭id
	self._chooseNum = 1 * self._mul -1  --默认选择的箭数为1
	self._isFreeze = false  			--是否冻结界面【出激光箭时用】
	self._superStartT = 0 				--大招开始时间(用于后端激光箭失效验证)
	self._superShootT = 0 				--大招最后一次射中怪的时间(用于后端激光箭失效验证)
	self._enterBackTime = 0 			--切后台时间
	self._enterForeTime = 0 			--切后台对应进前台的时间
	self._doubleHitNum = 0 				--连击数(有箭出屏没射中怪连击置为0)
	self._constTargetSpeed = MAX_SCREEN_WIDTH  * GameStatic.normalAnimInterval / 14   	--怪物速度 		--420 7s
	self._constArrowSpeed = MAX_SCREEN_HEIGHT * GameStatic.normalAnimInterval 			--箭速度2 		--60  0.5s
	self._constSArrowSpeed = MAX_SCREEN_HEIGHT * 3 * GameStatic.normalAnimInterval 		--激光箭速度 	--120 0.12s
end

-- function ArrowView:getBgName()
--     return "arrow_bg.jpg"
-- end

function ArrowView:onInit()
	self._musicLast = audioMgr:getMusicFileName()
	audioMgr:playMusic("HappyGame", true)
	--联盟科技增益
	local guildModel = self._modelMgr:getModel("GuildModel")
	self._hurtNum, self._energyNum = guildModel:getArrowGainLv()

	-- gameBg
	self._gameBg = cc.Node:create()
	self._gameBg:setPosition(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5)
	self:addChild(self._gameBg, -2)

	local bgImg = cc.Sprite:create("asset/bg/arrow_bg.png")
    bgImg:setAnchorPoint(cc.p(0.5, 0.5))  --1022/576
    local scaleW = MAX_SCREEN_WIDTH / 1022
    local scaleH = MAX_SCREEN_HEIGHT / 576
    local needScale = scaleW > scaleH and scaleW or scaleH
    bgImg:setScale(needScale)
    bgImg:setPosition(0, 0)
    self._gameBg:addChild(bgImg)

	--场景动画
	local aimLayer = mcMgr:createViewMC("fengwei_shejianjinglingfengwei", true, false)
	aimLayer:setScale(needScale)
	aimLayer:setPosition(0, 0)
	self._gameBg:addChild(aimLayer)

	--游戏层
	self._stage = ccui.Layout:create()
	self._stage:setAnchorPoint(cc.p(0.5, 0.5))
    self._stage:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._stage:setPosition(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5)
    self:addChild(self._stage, -1)

	self._supplyBox = self:getUI("bg.buy.supplyBox")
	self._supplyBox:getChildByName("Label_33"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	self:registerClickEvent(self._supplyBox, function()
		self:getSupplyRewards()
		end)

	self._closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEventByName("bg.closeBtn", function()
		self:syncArrowData(function()
			self:close()
			end)
		end)

	self._timeCount = self:getUI("bg.buy.timeCount")
	self._timeCount:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	self._arrowNum = self:getUI("bg.buy.num")
	self._arrowNum:setColor(UIUtils.colorTable.ccUIBaseColor1) 
	self._arrowNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)
	
	self._buyBtn = self:getUI("bg.buy.buyBtn")
	self:registerClickEvent(self._buyBtn, function(sender)
		if ((self._userModel:getData().arrowNum + 1)/self._mul or 0) >= tab.setting["G_ARROW_LIMIT"].value then
			self._viewMgr:showTip(lang("ARROW_TIP_4"))
		else
			self:syncArrowData(function()
				self._isScheduleStop = true
				DialogUtils.showBuyRes({
					goalType="arrow", 
					callback = function(param1, param2)
						if param2 ~= nil then
							self._isScheduleStop = false
						end						
					end})
				end)
		end
		end)

	self._rankBtn = self:getUI("bg.buy.rankBtn")  	--排行
	local rankDes = self._rankBtn:getChildByName("timeCount_0")
	rankDes:setString("统计")
	rankDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	self:registerClickEvent(self._rankBtn, function(sender)
		self:syncArrowData(function()
			self._isScheduleStop = true
			self:showDialog("activity.arrow.ArrowRankView", {
				callback = function()
					self._isScheduleStop = false
				end,
				callback2 = function()
					self:redPointHandle()
				end}, true)
			end)
		end)

	self._sendBtn = self:getUI("bg.buy.sendBtn") 	--送箭
	local sendDes = self._sendBtn:getChildByName("timeCount_0_1")
	sendDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	self:registerClickEvent(self._sendBtn, function(sender)
		self:syncArrowData(function()
			self._isScheduleStop = true
			self._serverMgr:sendMsg("ArrowServer", "getSendArrowInfo", {rType = 1}, true, {}, function (result)
				-- dump(result, "send")
				self:showDialog("activity.arrow.ArrowSendArwView", {
					callback = function()
						self._isScheduleStop = false
					end,
					callback2 = function()
						self:redPointHandle()
					end}, true)

				self:refreshUI()
				if result["reward"] and next(result["reward"]) ~= nil then
					DialogUtils.showGiftGet( {
			            gifts = result["reward"], 
			            callback = function() end
			        ,notPop = true})
				end
				end)
			end)
		end)

	self._rewards = {}
	local _reward1 = self:getUI("bg.rewards.box1")
	local _reward2 = self:getUI("bg.rewards.box2")
	local _reward3 = self:getUI("bg.rewards.box3")
	table.insert(self._rewards, _reward1)
	table.insert(self._rewards, _reward2)
	table.insert(self._rewards, _reward3)
	for i=1,3 do
		local rNum = self:getUI("bg.rewards.num"..i)
		rNum:setColor(UIUtils.colorTable.ccUIBaseColor1) 
		rNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor)

		if self._rewards[i]._clickNode == nil then
			local clickNode = ccui.Layout:create()
			clickNode:setAnchorPoint(cc.p(0.5, 0.5))
		    clickNode:setBackGroundColorOpacity(0)
		    clickNode:setBackGroundColorType(1)
		    clickNode:setBackGroundColor(cc.c3b(100, 100, 0))
		    clickNode:setContentSize(self._rewards[i]:getContentSize())
		    clickNode:setPosition(self._rewards[i]:getPosition())
		    self:getUI("bg.rewards"):addChild(clickNode)
		    self._rewards[i]._clickNode = clickNode
		end

		self:registerClickEvent(self._rewards[i]._clickNode, function(sender)
			self._viewMgr:showDialog("activity.arrow.ArrowRewardView", {data = self._data, callback = function()
				self:getRewards()
				end}, true)
		end)
	end

	-- 箭底座
	self:createArrowSelect()

	self:setListenReflashWithParam(true)
	self:listenReflash("UserModel", function()  --购买箭数更新
		if self._userModel and self._arrowNum then
			local arrowNum = (self._userModel:getData().arrowNum + 1)/self._mul or 0
			self._arrowNum:setString(arrowNum)
		end
		end) 

	self:listenReflash("ArrowModel", function()  --按钮红点
		self._data = self._arrowModel:getData()
		self:redPointHandle()
		end)   

	self:registerScriptHandler(function(eventType)
        if eventType == "enter" then 

        elseif eventType == "exit" then 
        	if self._scheduler then
        		if self._scheduler1 then
        			self._scheduler:unscheduleScriptEntry(self._scheduler1)
        		end
        		self._scheduler = nil
        	end
        	if self._musicLast then
        		audioMgr:playMusic(self._musicLast, true)
        	end

        	UIUtils:reloadLuaFile("activity.arrow.ArrowView")
			UIUtils:reloadLuaFile("activity.arrow.ArrowConst")
        end
    end)
    self._frameTime = 1 / GameStatic.normalAnimInterval
end

function ArrowView:redPointHandle()
	--送箭按钮红点
	local redPoint1 = self:getUI("bg.buy.sendBtn.redPoint1")
	redPoint1:setVisible(false)
	local rNum = self._data["arrow"]["rNum"]
	local redPoint = self:getUI("bg.buy.sendBtn.redPoint")
	redPoint:setVisible(false)
	if rNum > 0 then
		redPoint:setVisible(true)
		local redNum = self:getUI("bg.buy.sendBtn.redPoint.num")
    	redNum:setString(self._data["arrow"]["rNum"])
	else
		local day40 = self._modelMgr:getModel("PlayerTodayModel"):getData().day40
		if tab.setting["ARROW_GIVE"].value - day40 > 0 then
			redPoint1:setVisible(true)
		end
	end

end

function ArrowView:modelListenHandle(inType)
	if inType == 1 then  --"userModel"
		if self._userModel and self._arrowNum then
            local arrowNum = (self._userModel:getData().arrowNum + 1)/self._mul or 0
            self._arrowNum:setString(arrowNum)
        end

	elseif inType == 2 then   --"arrowModel"
		self._data = self._arrowModel:getData()
		local redPoint1 = self:getUI("bg.buy.sendBtn.redPoint1")
		redPoint1:setVisible(false)
		local rNum = self._data["arrow"]["rNum"]
		local redPoint = self:getUI("bg.buy.sendBtn.redPoint.num")
		if rNum > 0 then
	    	sendRedPoint:setString(self._data["arrow"]["rNum"])
		else
			sendRedPoint:setVisible(false)
		end
	end
end

--- 选择箭底座
function ArrowView:createArrowSelect()
	self._energyBar = ccui.ImageView:create("arrow_bottom.png", 1)
	self._energyBar:setPosition(MAX_SCREEN_WIDTH/2, -9)
	self._energyBar:setAnchorPoint(cc.p(0.5, 0))
	self._energyBar:setTouchEnabled(true)
	self._energyBar:setSwallowTouches(true)
	self._stage:addChild(self._energyBar, 14)

	local sizeBg = self._energyBar:getContentSize()

	self._addBtn = ccui.ImageView:create("arrow_add.png", 1)
	self._addBtn:setPosition(sizeBg.width/2+115, 37)
	self._energyBar:addChild(self._addBtn)

	self._subBtn = ccui.ImageView:create("arrow_sub.png", 1)
	self._subBtn:setPosition(sizeBg.width/2-115, 37)
	self._energyBar:addChild(self._subBtn)

	local energy4 = ccui.ImageView:create("arrow_energy4.png", 1)
	energy4:setPosition(sizeBg.width/2, 6)
	energy4:setAnchorPoint(cc.p(0.5, 0))
	self._energyBar:addChild(energy4)

	self._energyBar3 = ccui.ImageView:create("arrow_energy3.png", 1)
	self._energyBar3:setPosition(sizeBg.width/2 - 1, 7)
	self._energyBar3:setAnchorPoint(cc.p(0.5, 0))
	self._energyBar:addChild(self._energyBar3)

	self._energyBar2 = ccui.ImageView:create("arrow_energy2.png", 1)
	self._energyBar2:setPosition(sizeBg.width/2 - 1, 7)
	self._energyBar2:setAnchorPoint(cc.p(0.5, 0))
	self._energyBar:addChild(self._energyBar2)

	local energy1 = ccui.ImageView:create("arrow_energy1.png", 1)
	energy1:setPosition(sizeBg.width/2, 6)
	energy1:setAnchorPoint(cc.p(0.5, 0))
	self._energyBar:addChild(energy1, 3)

	local arrow1 = mcMgr:createViewMC("stop_nengliangtiao", true)
	arrow1:gotoAndStop(1)
	arrow1:setPosition(sizeBg.width/2, 29)
	self._energyBar:addChild(arrow1, 4)

	local arrow2 = mcMgr:createViewMC("stop_nengliangtiao", true)
	arrow2:gotoAndStop(1)
	arrow2:setPosition(sizeBg.width/2-25, 29)
	self._energyBar:addChild(arrow2, 4)

	local arrow3 = mcMgr:createViewMC("stop_nengliangtiao", true)
	arrow3:gotoAndStop(1)
	arrow3:setPosition(sizeBg.width/2+25, 29)
	self._energyBar:addChild(arrow3, 4)

	self._arwSel = {arrow1, arrow2, arrow3}

	self:registerClickEvent(self._addBtn, function(sender)
		self:chooseArrow("add")
		end)

	self:registerClickEvent(self._subBtn, function(sender)
		self:chooseArrow("sub")
		end)
end

function ArrowView:startPlay()
	--定时器
	self._scheduler = cc.Director:getInstance():getScheduler()
	self._scheduler1 = self._scheduler:scheduleScriptFunc(handler(self, self.scheduleUpdate), 0, false)
	
    self:refreshUI()
	self:timeCount()

	self:registerTouchEvent(self._stage, function(sender)
		if self._userModel:getAllowArrowUpdate() == false then   --模拟登录期间不可点击
			return
		end

		local arrowNumLimt
		if self._isFreeze == true then  --大招
			arrowNumLimt = 10
		else
			arrowNumLimt = 2
		end

		if #self._arrowList > arrowNumLimt then
			return
		end

		self._viewMgr:lock(-1)
		local _num, _arrowType
		if self._isFreeze == true then
			_num = 1 * self._mul -1
			_arrowType = ArrowConst.ARROW_TYPE.SPECIAL * self._mul
		else
			_num = self._chooseNum
			_arrowType = ArrowConst.ARROW_TYPE.COMMON * self._mul
		end

		--箭矢不足
		if _arrowType / self._mul == ArrowConst.ARROW_TYPE.COMMON and (self._userModel:getData().arrowNum or -1) < self._chooseNum then
			self._viewMgr:showTip(lang("ARROW_TIP_3"))
			self._viewMgr:unlock()
			return
		end

		if self._isFreeze == true and self._superNum and self._superNum > 0 then  --大招
			self._superNum = self._superNum + 1
			self:shootStart(sender, _arrowType, _num)
		else
			self._superNum = 0
			-- self._viewMgr:unlock()

			--同步+手动
			if _arrowType / self._mul == ArrowConst.ARROW_TYPE.SPECIAL then   --首次大招
				self._superStartT = self._modelMgr:getModel("UserModel"):getCurServerTime()
				self._enterBackTime = 0
				self._enterForeTime = 0
				self._arrowModel:setSyncStatis(1, -1)  	--记录本地能量值为0  只改本地model不改
				self._arrowModel:setSyncArrowList(2)   --同步数据
				self._superNum = 1 		--激光箭第一次请求服务器，之后倒计时期间不用
				self:energyCountDown()  -- 能量条倒计时
			else   --普通
				self._arrowModel:handleArrowShooting(1, _num)
				self._arrowModel:setSyncArrowList(1, _num)   --同步数据
			end
			self:shootStart(sender, _arrowType, _num)
			self:refreshUI()


			-- self._serverMgr:sendMsg("ArrowServer", "arrowShooting", {arrowType = _arrowType / self._mul, num = _num / self._mul}, true, {}, function (result)
			-- 	-- dump(result,"146")
			-- 	if _arrowType / self._mul == ArrowConst.ARROW_TYPE.SPECIAL then
			-- 		self._superNum = 1 		--激光箭第一次请求服务器，之后倒计时期间不用
			-- 		self:energyCountDown()  -- 能量条倒计时
			-- 	end
			-- 	-- self._viewMgr:lock(-1)

			-- 	self:shootStart(sender, _arrowType, _num)
			-- 	self:refreshUI()
	  --       end)
		end
		end)
	--创建射箭精灵
	self:createSprite()
end

---- 创建射箭精灵
function ArrowView:createSprite()
	-- 精灵射箭动画 13
	if self._angelWidget == nil then
		self._angelWidget = ccui.Widget:create()
		self._angelWidget:setPosition(MAX_SCREEN_WIDTH/2, 10)
		self._stage:addChild(self._angelWidget, 13)
	else
		self._angelWidget:removeAllChildren()
	end

	local angle = mcMgr:createViewMC("stop_shejianjingling", true, false)  --jingling
	angle:setPosition(0, 0)
	self._angelWidget:addChild(angle, 2)
	self._angelWidget._angle1 = angle

	local _arrowType = self._isFreeze == true and 3 * self._mul -1 or self._chooseNum
	local bow = mcMgr:createViewMC("gongstop" .. (_arrowType+1)/self._mul .. "_shejianjingling", true, false)  --bow
	bow:setPosition(0, 0)
	self._angelWidget:addChild(bow, 1)
end

---- 创建怪物
function ArrowView:createTarget()
	-- if #self._monsterList > 4 then return end
	local disTime = self._isFreeze == true and 1.8 or 3   --出怪速度
	self._curTime = self._curTime and self._curTime + 1 or 0
	
	if self._curTime > 0 and self._curTime < disTime * self._frameTime then
		return
	else
		self._curTime = 0
	end
	
	self._monsterIndex = self._monsterIndex + 1
	local monsterID = math.random(1, #tab.arrow)  
	local monsterData = tab.arrow[monsterID]
	local outType = math.random(1, #monsterData["speed"])
	local outData = monsterData["speed"][outType]
	local heiOut = math.random(outData[1], outData[2])
	local speed = self._constTargetSpeed * math.random(outData[3] * 10, outData[4] * 10) * 0.1
	local posX, posY, appearType
	if math.random(1, 10) <= 5 then 	--左侧出
		posX, posY = ArrowConst.APPEAR_LEFT_POS, heiOut
		appearType = "left"
	else   								--右侧出
		posX, posY = ArrowConst.APPEAR_RIGHT_POS, heiOut
		appearType = "right"
	end

	local widget = ccui.Layout:create()
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setBackGroundColorOpacity(0)
    widget:setBackGroundColorType(1)
    widget:setBackGroundColor(cc.c3b(100, 100, 0))
    widget:setContentSize(130, 50)
    widget:setPosition(posX, posY)

    widget._appearType = appearType   	--出现类型
	widget._id = monsterID        		--表类型id
	widget._index = self._monsterIndex	--本地随机id
	widget._blood = monsterData["hp"] + self._mul 	--血量
	widget._specialArrNum = {}         	--被激光箭射中列表{{区域，箭数}，{区域，箭数}，{}}
	widget._commonArrNum = {}         	--被普通箭射中列表{{箭数，区域}，{箭数，区域}，{}}
	widget._speed = speed
	widget._cWidget = {}
	widget._shootArw = {}  				--怪物身上挂的箭，用于限制箭和怪的碰撞检测次数
    self._stage:addChild(widget)

    local wMoster = ccui.Layout:create()
	wMoster:setAnchorPoint(cc.p(0.5, 0.5))
    wMoster:setBackGroundColorOpacity(0)
    wMoster:setBackGroundColorType(1)
    wMoster:setBackGroundColor(cc.c3b(0, 100, 0))
    wMoster:setContentSize(130, 50)
    wMoster:setPosition(widget:getContentSize().width * 0.5, widget:getContentSize().height*0.5)
    widget:addChild(wMoster)
    if appearType == "left" then
    	wMoster:setScaleX(-1)
    end
    local monster = mcMgr:createViewMC(monsterData["art"], true, false)
	monster:setPosition(wMoster:getContentSize().width /2, wMoster:getContentSize().height)
	wMoster:addChild(monster)

	widget.monsterAnim = monster
	table.insert(self._monsterList, widget)

	self:refreshMonsterBlood(widget)  --血条
    
    --创建碰撞检测区域
    local cAreas = monsterData["arrow"]
    for i=1, #cAreas do
	    local cWidget = ccui.Layout:create()
	    cWidget:setAnchorPoint(cc.p(0.5, 0.5))
	    cWidget:setBackGroundColorOpacity(0)
	    cWidget:setBackGroundColorType(1)
	    cWidget:setBackGroundColor(cc.c3b(200, 100, 0))
	    cWidget:setContentSize(cAreas[i][1], cAreas[i][2])
	    cWidget:setPosition(monster:getPositionX() + cAreas[i][3], monster:getPositionY() + cAreas[i][4])
	    cWidget._hurt = cAreas[i][5]
	    table.insert(widget._cWidget, cWidget)
	    wMoster:addChild(cWidget)
    end

    -- 针对小恶魔晃动问题 同步晃动碰撞区域
    -- local animName = string.split(monsterData["art"], "_")
    -- if animName[2] == "shejianxiaoemo" then
    -- 	for i=1, #widget._cWidget do
    -- 		local cPosX, cPosY = widget._cWidget[i]:getPositionX(), widget._cWidget[i]:getPositionY()
    -- 		local movePos = {{22, -12}, {47, 1}}
    -- 		widget._cWidget[i]:runAction(cc.RepeatForever:create(
		  --   	cc.Sequence:create(
			 --    	cc.MoveTo:create(0.4, cc.p(cPosX + movePos[1][1], cPosY + movePos[1][2]) ), 
			 --    	cc.MoveTo:create(0.4, cc.p(cPosX + movePos[2][1], cPosY + movePos[2][2]) ),
			 --    	cc.MoveTo:create(0.3, cc.p(cPosX + movePos[1][1], cPosY + movePos[1][2]) ),
			 --    	cc.MoveTo:create(0.4, cc.p(cPosX, cPosY))
		  --   	)))
	   --  end
    -- end
end

---- 血量
function ArrowView:refreshMonsterBlood(sp)
	if sp == nil then
		return
	end

	local percent = ((sp._blood - self._mul) / tab.arrow[sp._id]["hp"]) * 100 + self._mul
	local bloodBar = sp:getChildByName("bloodBar")
	if bloodBar ~= nil then
		bloodBar:setVisible(true)
		bloodBar:getChildByName("bar"):setPercentage(percent - self._mul)
		return
	end

	local widget = ccui.Layout:create()
    widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(sp:getContentSize().width/2, sp:getContentSize().height + 40)
    widget:setName("bloodBar")
    sp:addChild(widget)

	local bg = cc.Sprite:createWithSpriteFrameName("guildMapImg_progressBg.png")
	widget:setContentSize(bg:getContentSize().width, bg:getContentSize().height)
    bg:setPosition(widget:getContentSize().width/2, widget:getContentSize().height + 20)
    widget:addChild(bg)

    local bloodBar = cc.Sprite:createWithSpriteFrameName("guildMapImg_progress.png")
    local progress = cc.ProgressTimer:create(bloodBar)
    progress:setPosition(widget:getContentSize().width/2, widget:getContentSize().height + 20)
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setMidpoint(cc.p(0, 0.5))
    progress:setBarChangeRate(cc.p(1, 0))    
    progress:setPercentage(percent - self._mul)
    progress:setName("bar")
    widget:addChild(progress)

    if percent >= 100 then
    	widget:setVisible(false)
    end
end

---- 开始射箭
function ArrowView:shootStart(sender, _arrowType, _num)
	self._clickPosX, self._clickPosY = sender:getTouchBeganPosition().x, sender:getTouchBeganPosition().y
	local rad = math.atan2(self._clickPosX - MAX_SCREEN_WIDTH/2, self._clickPosY)
	local angle = 180*rad/math.pi

	--clear
	self._angelWidget:removeAllChildren()
	if self._stage._bow2 ~= nil then
		self._stage._bow2:removeFromParent(true)
		self._stage._bow2 = nil
	end

	-- 精灵射箭动画 2
	local _angelNode = ccui.Widget:create()
	_angelNode:setPosition(0, 0)
	self._angelWidget:addChild(_angelNode, 2)

	local angelName
	if angle > 30 or angle < -30 then
		if self._isFreeze == true then
			angelName = "atk2d_shejianjingling"
		else
			angelName = "atk2_shejianjingling"
		end

		if angle > 30 then
			_angelNode:setScaleX(-1)
		end
	else
		if self._isFreeze == true then
			angelName = "atkd_shejianjingling"
		else
			angelName = "atk_shejianjingling"
		end
	end
	local shootSp = mcMgr:createViewMC(angelName, false, true, function()  
		self:createSprite()
		end)
	shootSp:setPlaySpeed(2)
	_angelNode:addChild(shootSp)

	--弓箭动画 1  
	local bowName
	if self._isFreeze == true then
		bowName = "atk2gong3_shejianjingling"
	else
		bowName = "atkgong" .. (self._chooseNum+1)/self._mul .. "_shejianjingling"
	end
	local bow = mcMgr:createViewMC(bowName, false, true, function()
		self._stage._bow2 = nil
		end)
	bow:setPlaySpeed(2)
	bow:setPosition(MAX_SCREEN_WIDTH/2, 10)
	bow:setRotation(angle)
	self._stage:addChild(bow, 11)
	self._stage._bow2 = bow

	bow:addCallbackAtFrame(12*0.5, function()   --25
		local arrowData = {angle, rad, _arrowType, _num} 
		self:createArrow(arrowData)
		end)

	bow:addCallbackAtFrame(5*0.5, function()   --lagong
		audioMgr:playSound("Arrow_lagong")
		end)

	bow:addCallbackAtFrame(20*0.5, function()   --fashe
		if self._isFreeze == true then
			audioMgr:playSound("Arrow_wuxian_fashe")
		else
			audioMgr:playSound("Arrow_fashe")
		end
		end)

	--激光箭蓄力动画
	if self._isFreeze == true and self._superNum == 1 then
		local bow = mcMgr:createViewMC("xuli_jiguangjian", false, true)
		bow:setPlaySpeed(1.2)
		bow:setPosition(MAX_SCREEN_WIDTH/2, 10)
		bow:setRotation(angle)
		self._stage:addChild(bow, 10)
	end
end

---- 生成箭 12
function ArrowView:createArrow(data)
	self._arrowIndex = self._arrowIndex + 1
	local widget = ccui.Layout:create()
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(MAX_SCREEN_WIDTH/2, 10)   
	widget:setRotation(data[1])

	widget._angle = data[1]
	widget._index = self._arrowIndex
	widget._rad = data[2]
	widget._type = data[3]
	widget._num = data[4]
	widget._shootMonsters = {}  --箭身上带的怪,用于判断是否连击

	self._stage:addChild(widget, 12)
	table.insert(self._arrowList, widget)

	if widget._type/self._mul == ArrowConst.ARROW_TYPE.SPECIAL then   --speed
		widget._speed = self._constSArrowSpeed
	else
		widget._speed = self._constArrowSpeed
	end

	if widget._type/self._mul == ArrowConst.ARROW_TYPE.SPECIAL then
		widget._speed = self._constSArrowSpeed
		widget:setContentSize(cc.size(67, 424))   --67/424    67/252

		local arrowImg = ccui.ImageView:create("arrow_arrow0.png", 1)
		arrowImg:setPosition(widget:getContentSize().width/2, widget:getContentSize().height/2)   
		widget:addChild(arrowImg)

		local arrowAnim = mcMgr:createViewMC("jian_jiguangjian", false, false)
		widget._superAnim = arrowAnim
		arrowAnim:setPosition(33, 424)   
		widget:addChild(arrowAnim)
	else
		local arrow = ccui.ImageView:create("arrow_arrow" .. (self._chooseNum+1)/self._mul .. ".png", 1)
		arrow:setAnchorPoint(cc.p(0, 0))
		arrow:setPosition(0, 0)   
		widget:addChild(arrow)

		widget:setContentSize(arrow:getContentSize())
		widget._speed = self._constArrowSpeed
	end

	--创建碰撞检测区域  --25/29
	local cWidth, cHeight, cPosX, cPosY
	local arrowSize = widget:getContentSize()
	if self._isFreeze == true then   --激光箭
		cWidth, cHeight = arrowSize.width, arrowSize.height
		cPosX, cPosY = 0, 0
	else 
		cWidth, cHeight = 25, 19
		cPosX, cPosY = (arrowSize.width - cWidth)*0.5, arrowSize.height - 20 - cHeight
	end
    local cWidget = ccui.Layout:create()
    cWidget:setAnchorPoint(cc.p(0, 0))  
    cWidget:setBackGroundColorOpacity(0)
    cWidget:setBackGroundColorType(1)
    cWidget:setBackGroundColor(cc.c3b(200, 100, 0))
    cWidget:setContentSize(cWidth, cHeight)
    cWidget:setPosition(cPosX, cPosY)
    widget._cWidget = cWidget
    widget:addChild(cWidget)

    self._viewMgr:unlock()
end

function ArrowView:scheduleUpdate()
	--购买箭时暂停界面
	if self._isScheduleStop == true then
		for i,v in ipairs(self._monsterList) do
			v.monsterAnim:stop()
		end
		return
	else
		for i,v in ipairs(self._monsterList) do
			if not v.monsterAnim:isPlaying() then
				v.monsterAnim:play()
			end
		end
	end
	self:createTarget()
	self:conllisionCheck()
	self:scheduleCheck()
end

--[[ function  定时器每帧处理
--! @desc 能量条更新【每1小时减少20】 
--! @desc 匀速移动对象 
--! @desc 移除出屏幕对象
--! @desc 移除出屏幕箭
--]]
function ArrowView:scheduleCheck()
	-- 能量条更新
	-- local _, clock = math.modf(self._userModel:getCurServerTime() / 3600)
	-- if clock == 0 and not self._clockMark and self._isFreeze == false then  --整点且非激光箭状态
	-- 	self._clockMark = true
	-- 	local _arrowPower = self._data["arrow"]["arrowPower"]
	-- 	_arrowPower = math.max(_arrowPower - 20, 0)
	-- 	self:refreshEnergyBar()
	-- else
	-- 	self._clockMark = false
	-- end

	--对象移动 & 移除出屏幕对象
		--monster
	for k= #self._monsterList, 1, -1 do
		local sp = self._monsterList[k]
		if sp._appearType == "left" then
			sp:setPositionX(sp:getPositionX() + sp._speed)
			if sp:getPositionX() >= ArrowConst.REMOVE_RIGHT_POS then
				sp:removeFromParent()
				table.remove(self._monsterList, k)
			end

		elseif sp._appearType == "right" then
			sp:setPositionX(sp:getPositionX() - sp._speed)
			if sp:getPositionX() <= ArrowConst.REMOVE_LEFT_POS then
				sp:removeFromParent()
				table.remove(self._monsterList, k)
			end
		end
	end

		--arrow
	for i= #self._arrowList, 1, -1 do 
		local arw = self._arrowList[i]
		local angle = tonumber(arw:getName())

		if not arw.isRemove then
			arw:setPositionX(arw:getPositionX() + arw._speed * math.sin(arw._rad))
			arw:setPositionY(arw:getPositionY() + arw._speed * math.cos(arw._rad))
		end
		
		local disNum = 0
		if arw._type/self._mul == ArrowConst.ARROW_TYPE.SPECIAL then
			disNum = 230
		end

		if arw:getPositionX() <= -50 - disNum or 
			arw:getPositionX() >= MAX_SCREEN_WIDTH + 50 + disNum or
			  arw:getPositionY() >= MAX_SCREEN_HEIGHT + 50 + disNum then

			--连击判断,出屏且没射中怪
			if next(arw._shootMonsters) == nil then
				self:refreshDoubleHit(false)
			end
			--大招的对象需要在特效结束后再释放
			if arw._type/self._mul ~= ArrowConst.ARROW_TYPE.SPECIAL then
				arw:removeFromParent()
				table.remove(self._arrowList, i)
			else
				if arw._superAnim then
					local frame1 = arw._superAnim:getCurrentFrame()
					local frame2 = arw._superAnim:getTotalFrames()
					if frame1 == frame2 then
						table.remove(self._arrowList, i)
						arw:removeFromParent()
					else
						arw.isRemove = true
					end
				end
			end
		end
	end
end

--[[ function  定时器碰撞检测
--! @desc 检查射击目标与箭是否碰撞
--]]
function ArrowView:conllisionCheck()
	-- 碰撞检测
	for _arr=#self._arrowList, 1, -1 do
		local arrowC = self._arrowList[_arr]
		local isShoot = false
		local shootList = {}  --死列表

		for _tar=#self._monsterList, 1, -1 do
			local monsterC = self._monsterList[_tar] 
			--射中
			local isCollion, hurtIndex, hurtFactor = self:checkIsCollision(monsterC, arrowC)
			if isCollion == true and monsterC._shootArw[tostring(arrowC._index)] == nil then
				monsterC._shootArw[tostring(arrowC._index)] = 1
				arrowC._shootMonsters[monsterC._index] = 1
				self:refreshDoubleHit(true)   --连击数+1
				isShoot = true

				--射中特效名 / 射中箭数记录 / 血量 / 射中时间
				local shootAnimName
				if arrowC._type/self._mul == ArrowConst.ARROW_TYPE.SPECIAL then
					audioMgr:playSound("Arrow_wuxian_minghzong")
					shootAnimName = "shouji2_nengliangtiao"
					if monsterC._specialArrNum[hurtIndex] == nil then
						monsterC._specialArrNum[hurtIndex] = 1 * self._mul
					else
						monsterC._specialArrNum[hurtIndex] = monsterC._specialArrNum[hurtIndex] + 1 * self._mul
					end
					monsterC._blood = monsterC._blood - (tab:Setting("G_ARROW_HURT_2").value * hurtFactor) * (1 + self._hurtNum)
					self._superShootT = self._userModel:getCurServerTime()
				else
					audioMgr:playSound("Arrow_mingzhong")
					self._arrowModel:setSyncStatis(2, arrowC._num)  	--同步数据
					if hurtIndex == self._mul then
						self._arrowModel:setSyncStatis(3, arrowC._num)  --爆头同步数据
					end
					
					if hurtIndex == self._mul then
						shootAnimName = "shouji2_nengliangtiao"
					else
						shootAnimName = "shouji_nengliangtiao"
					end
					table.insert(monsterC._commonArrNum, {arrowC._num + 1, hurtIndex})
					local hurtTb = tab:Setting("G_ARROW_HURT").value
					for i=1,#hurtTb do
						if hurtTb[i][1] == (arrowC._num + 1) / self._mul then
							monsterC._blood = monsterC._blood - (hurtTb[i][2] * hurtFactor) * (1 + self._hurtNum)
							break
						end
					end
				end

				UIUtils:shakeWindow(nil, self._closeBtn)  --震屏

				--射中特效
				local point1 = monsterC._cWidget[hurtIndex/self._mul]:convertToWorldSpace(cc.p(0, 0))
    			pointM1 = self._stage:convertToNodeSpace(point1)
				local shootAnim = mcMgr:createViewMC(shootAnimName, false, true)
				shootAnim:setPosition(pointM1)
				self._stage:addChild(shootAnim)

				--爆头特效
				if hurtIndex == self._mul then
					local baotouAnim = mcMgr:createViewMC("hit_shejianui", false, true)
					baotouAnim:setPosition(pointM1.x, pointM1.y + 50)
					self._stage:addChild(baotouAnim)
				end
				
				if monsterC._blood > self._mul then
					--血量
					self:refreshMonsterBlood(monsterC)
				else
					--射死
					--激光箭数据结构处理
					local superList = {}
					for _k,_v in pairs(monsterC._specialArrNum) do
						table.insert(superList, {_v, _k})
					end

					self._data["arrow"]["mStatis"][tostring(monsterC._id)] = self._data["arrow"]["mStatis"][tostring(monsterC._id)] + 1

					local exchangeTime = self._enterForeTime - self._enterBackTime
					table.insert(shootList, {monsterC._id, monsterC._commonArrNum, superList, self._superShootT, self._superStartT, exchangeTime})
					local dieAnim = mcMgr:createViewMC(tab.arrow[monsterC._id]["dieart"], false, true)
					dieAnim:setPosition(monsterC:getPosition())
					self._stage:addChild(dieAnim)
					if monsterC._appearType == "left" then
				    	dieAnim:setScaleX(-1)
				    end

					monsterC:removeFromParentAndCleanup()
					table.remove(self._monsterList, _tar)
				end
			end
		end

		if isShoot == true then  --一箭可能中多个，所以在遍历完之后再处理射中列表
			--箭移除
			if arrowC._type/self._mul ~= ArrowConst.ARROW_TYPE.SPECIAL then   
				arrowC:removeFromParentAndCleanup()
				table.remove(self._arrowList, _arr)
			end

			if next(shootList) ~= nil then
				for i=1,#shootList do
					self._arrowModel:setSyncDieList(shootList[i])
					local awardId = tab.arrow[shootList[i][1]].award
					self._arrowModel:handleShootDieMonsters(awardId, shootList[i][1])
					self:refreshUI()
				end
				
				-- self._serverMgr:sendMsg("ArrowServer", "arrowShootingMonsters", {monsters = json.encode(shootList)}, true, {}, function (result)
				-- 	-- dump(result, "arrow")
				-- 	self:refreshUI()  --奖励
				-- end)
			end
		end
	end
end

---- 碰撞区域检测 方法3（线段相交）
---- A————B
---- |    |
---- D————C
---- arrow: cWidget锚点在cc.p(0, 0)
function ArrowView:checkIsCollision(monster, arrow)
	if arrow.isRemove == true or monster._cWidget == nil or arrow._cWidget == nil then
		return false
	end	

    --arrow
    local point2 = arrow._cWidget:convertToWorldSpace(cc.p(0, 0))
    pointA = self._stage:convertToNodeSpace(point2)
    local aWidth = arrow._cWidget:getContentSize().width
    local aHeight = arrow._cWidget:getContentSize().height
    local aSin = math.sin(arrow._rad)
    local aCos = math.cos(arrow._rad)
    local aa = {_x = pointA.x + aHeight * aSin,  				_y = pointA.y + aHeight * aCos}
    local ac = {_x = pointA.x + aWidth * aCos, 					_y = pointA.y - aWidth * aSin}
    local ab = {_x = pointA.x + aWidth * aCos + aHeight * aSin, _y = pointA.y - aWidth * aSin + aHeight * aCos}
    local ad = {_x = pointA.x, 									_y = pointA.y}
    local segATb = {{aa, ab}, {ab, ac}, {ac, ad}, {ad, aa}}

    --直线方程
   	local function getEquation(p1, p2)  --两端点  
   		local k = (p1._y - p2._y) / (p1._x - p2._x)
   		local b = p1._y - k * p1._x
   		return k, b
   	end

   	--lin2两端点是否在lin1所在线段两边
   	local function isIntersect(lin1, lin2)  --两条线  lin1[端点A, 端点B]
   		local _k, _b = getEquation(lin1[1], lin1[2])
   		local mark1 = _k * lin2[1]._x + _b - lin2[1]._y
   		local mark2 = _k * lin2[2]._x + _b - lin2[2]._y
   		if mark1 * mark2 < 0 then
   			return true
   		end
   		return false
   	end

    --monster
    for i=1, #monster._cWidget do
    	local point1 = monster._cWidget[i]:convertToWorldSpaceAR(cc.p(0, 0))
	    pointM = self._stage:convertToNodeSpace(point1)
	    local mSize = monster._cWidget[i]:getContentSize()
	    local ma = {_x = pointM.x - mSize.width/2, 	_y = pointM.y + mSize.height/2}
	    local mb = {_x = pointM.x + mSize.width/2,  _y = pointM.y + mSize.height/2}
	    local mc = {_x = pointM.x + mSize.width/2,  _y = pointM.y - mSize.height/2}
	    local md = {_x = pointM.x - mSize.width/2, 	_y = pointM.y - mSize.height/2}
	    local segMTb = {{ma, mb}, {mb, mc}, {mc, md}, {md, ma}}

	   	--判断两线段是否相交
	   	for p,aTb in ipairs(segATb) do
			for k,mTb in ipairs(segMTb) do
				if isIntersect(segATb[p], segMTb[k]) and isIntersect(segMTb[k], segATb[p]) then
					return true, i * self._mul, monster._cWidget[i]._hurt   --true/false, 射中区域, 本次伤害值
		   		end
			end
		end
    end

    return false
end

---- 碰撞区域检测 方法2（矩形与矩形区域重合）
--[[
function ArrowView:checkIsCollision2(_monster, _arrow)
    local mm = _monster._cWidget:getBoundingBox()
    local aa = _arrow._cWidget:getBoundingBox()

    local point1 = _monster._cWidget:convertToWorldSpace(cc.p(0, 0))
    pointM = self._stage:convertToNodeSpace(point1)
    local point2 = _arrow._cWidget:convertToWorldSpace(cc.p(0, 0))
    pointA = self._stage:convertToNodeSpace(point2)

    local mC = {height = mm.height, width = mm.width, x = pointM.x, y = pointM.y}
    local aC = {height = aa.height, width = aa.width, x = pointA.x, y = pointA.y}

    return cc.rectIntersectsRect(mC,aC)  
end
]]
---- 碰撞区域检测 方法1（点是否在某区域内）
--[[
function ArrowView:checkIsCollision1(monster, arrow)
	if not monster or not arrow then
		return false
	end

	local point1 = monster:convertToWorldSpace(cc.p(0, 0))
    pointM = self._stage:convertToNodeSpace(point1)
	local areaSizeW, areaSizeH = monster:getContentSize().width/2, monster:getContentSize().height/2 
	local tSize = {
		xMin = pointM.x - areaSizeW, 
		xMax = pointM.x + areaSizeW, 
		yMin = pointM.y - areaSizeH, 
		yMax = pointM.y + areaSizeH
	}

	local aHeight = arrow:getContentSize().height
	local arrowPosX = arrow:getPositionX() + (math.sin(arrow._rad) * aHeight/2) 
 local arrowPosY = arrow:getPositionY() + (math.cos(arrow._rad) * aHeight/2)
	
	--判断点是否在区域内
	local function checkPoint(posX, posY)
		if posX > tSize.xMin and posX < tSize.xMax and
		    posY > tSize.yMin and posY < tSize.yMax then
			return true
		end
		return false
	end
	return checkPoint(arrowPosX, arrowPosY)
end
]]

function ArrowView:refreshUI()
	self._data = self._arrowModel:getData()
	-- dump(self._data, "refresh")

	--铜/银/金宝箱
	for i=1,3 do
		local rewardNum = self._data["arrow"]["rewards"][tostring(i)]
		self:getUI("bg.rewards.num"..i):setString("x"..rewardNum)

		local rewardBox = self._rewards[i]
		local isPlay = self._data["arrow"]["rewards"][tostring(i)] > 0 and true or false
		self:addBoxEffect(rewardBox, isPlay, true)
	end

	--按钮红点
	self:redPointHandle()
	
	--箭总数
	local arrowNum = 0
	if self._userModel:getData().arrowNum then
		arrowNum = (self._userModel:getData().arrowNum + 1)/self._mul
	end
	self._arrowNum:setString(arrowNum)

	--选择箭数
	self:chooseArrow()
    
	--能量槽
	if self._isFreeze == false then
		self:refreshEnergyBar()
	end
end

function ArrowView:refreshEnergyBar()
	local _powerMax = tab.setting["G_ARROW_ENERGY_LIMIT"].value * self._mul - 1
	local _curPower
	if self._isFreeze == true then
		_curPower = self._superPower or clone(_powerMax)
	else
		_curPower = self._data["arrow"]["arrowPower"] or -1
	end
	local _arrowPower = math.min(_curPower, _powerMax)
	local angle = (_arrowPower + 1) * 180 / (_powerMax + 1)
	local posX, posY = self._energyBar:getContentSize().width/2, 7

	-- self._powerLab:setString(_curPower)
	--满能量动画 3
	if _arrowPower < _powerMax then
		if self._energyBar._maxAnim ~= nil then
			self._energyBar._maxAnim:removeFromParent(true)
			self._energyBar._maxAnim = nil
		end
		
	else
		if self._energyBar._maxAnim == nil then
			local maxAim = mcMgr:createViewMC("nengliangman_nengliangtiao", true, false)
			maxAim:setPosition(posX, posY)
			self._energyBar:addChild(maxAim, 2)
			self._energyBar._maxAnim = maxAim

			self:startSuperState()  --大招状态
		end 
	end

	--能量动画 1
	if self._energyBar._liuAnim == nil then
		local liudong = mcMgr:createViewMC("nengliangliudong_nengliangtiao", true, false)
		liudong:setPosition(0, 0)
		self._energyBar._liuAnim = liudong
	end

	--能量条遮罩
	if self._energyBar._clip == nil then
		local clipNode = cc.ClippingNode:create()   
	    clipNode:setInverted(false)   --false显示抠掉部分

	    local mask = cc.Sprite:createWithSpriteFrameName("arrow_energy3.png")  --遮罩
	    mask:setPosition(cc.p(0, 0))
	    mask:setAnchorPoint(0.5, 0)
	    mask:setRotation(-180+angle)
	    
	    clipNode:setStencil(mask)  --遮罩和地图对齐
	    clipNode:setAlphaThreshold(0.01)
	    clipNode:addChild(self._energyBar._liuAnim)  --添加裁剪对象
	    clipNode:setPosition(posX, posY)
	    clipNode:setCascadeOpacityEnabled(true, true)
	    clipNode:setOpacity(0)
	    self._energyBar:addChild(clipNode, 2)
	    self._energyBar._clip = mask
	    clipNode:runAction(cc.FadeIn:create(0.5))
	else
		self._energyBar._clip:setRotation(-180+angle)
	end
    
	--圆头 2
	if self._energyBar._head == nil then
		local head = ccui.ImageView:create("arrow_energyLight.png", 1)
		head:setAnchorPoint(cc.p(0.5, 0))
		head:setPosition(posX, posY)
		head:setRotation(angle - 45)
		self._energyBar:addChild(head, 1)
		self._energyBar._head = head
	else
		self._energyBar._head:setRotation(angle - 45)
	end

	self._energyBar2:setRotation(-180+angle)
	self._energyBar3:setRotation(-180+angle)
end

function ArrowView:startSuperState()
	--按钮缩放动画
	--创建箭雨按钮动画
	if self._superBtn == nil then
		self._superBtn = ccui.Layout:create()
		self._superBtn:setAnchorPoint(cc.p(0.5, 0.5))
		self._superBtn:setContentSize(cc.size(80, 80))
		self._superBtn:setPosition(MAX_SCREEN_WIDTH/2 + 210, 105)
		self._superBtn:setSwallowTouches(true)
		self._superBtn:setTouchEnabled(true)
		self._stage:addChild(self._superBtn, 21)

		local superAnim1 = mcMgr:createViewMC("atk_shejianui", true, false)
		superAnim1:setPosition(self._superBtn:getContentSize().width/2, self._superBtn:getContentSize().height/2)
		self._superBtn._anim1 = superAnim1
		self._superBtn:addChild(superAnim1)
	end

	--点击事件
	self:registerClickEvent(self._superBtn, function() 
		self._superBtn:setTouchEnabled(false)
		audioMgr:playSound("Arrow_wuxian_kaishi")
		if self._superBtn._anim1 then
			self._superBtn._anim1:removeFromParent()
			self._superBtn._anim1 = nil
		end

		if self._superBtn._anim2 == nil then
			local superAnim2 = mcMgr:createViewMC("stop_shejianui", true, false)
			superAnim2:gotoAndStop(1)
			superAnim2:setPosition(self._superBtn:getContentSize().width/2, self._superBtn:getContentSize().height/2)
			self._superBtn._anim2 = superAnim2
			self._superBtn:addChild(superAnim2)
		end
		
		self._isFreeze = true
		self:chooseArrow()   --刷新底座状态
		self:createSprite()  --刷新精灵动画

		--层级
		self._stage:setLocalZOrder(100)
		-- self._energyBar:setLocalZOrder(-1)

		--压黑层
		if self._superLayer == nil then
			self._superLayer = ccui.Layout:create()
		    self._superLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT + 10)
		    self._superLayer:setPosition(0, 0)
		    self._superLayer:setBackGroundColorOpacity(200)
		    self._superLayer:setBackGroundColorType(1)
		    self._superLayer:setBackGroundColor(cc.c3b(0, 0, 0))
		    self._stage:addChild(self._superLayer, -1)
		end

    	--无限能量动画
		if self._wuxianAnim == nil then
			self._wuxianAnim = mcMgr:createViewMC("wuxian_shejianjianyu", true)
			self._wuxianAnim:setPosition(MAX_SCREEN_WIDTH/2, 20)
			self._stage:addChild(self._wuxianAnim, 20)
		end

    	--文字提示动画
		if self._wordAim == nil then
			self._wordAim = mcMgr:createViewMC("tixing_shejianjianyu", true)
			self._wordAim:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT - 65)
			self._stage:addChild(self._wordAim, 20)
		end
	end)
end

-- 能量条倒计时
function ArrowView:energyCountDown()
	local _powerMax = tab.setting["G_ARROW_ENERGY_LIMIT"].value * self._mul - 1
	self._superPower = self._superPower or clone(_powerMax)
	local times = 0
	self._energyBar:runAction(cc.RepeatForever:create(
		cc.Sequence:create(
			cc.DelayTime:create(0.05), --取0.02会造成时间不准
			cc.CallFunc:create(function()
				self._superPower = (self._superPower - (tab.setting["G_ARROW_ENERGY_REDUCE_USE"].value - self._energyNum) * 0.05 * self._mul )
				if self._superPower <= -1 then
					self._superPower = -1
					self._stage:setTouchEnabled(false)
					ScheduleMgr:delayCall(1000, self, function()
						if self._arrowList and #self._arrowList == 0 then
							times = times + 1   --repeat防走多次
							if times == 1 then
								self._energyBar:stopAllActions()
								self._superPower = nil
								self._arrowModel:handleArrowShooting(2)
								self._isFreeze = false  --激光箭状态恢复
								self._superNum = 0      --激光箭开始倒计时状态恢复

								self:stopSuperState()  --恢复普通状态
								self:chooseArrow()
								return
							end
						end
					end)
				end
				self:refreshEnergyBar()  --能量条
				end)
			)))
end

function ArrowView:stopSuperState()
	if self._superLayer then
		self._superLayer:removeFromParent(true)
		self._superLayer = nil
	end

	if self._wordAim then
		self._wordAim:removeFromParent(true)   
		self._wordAim = nil
	end

	if self._wuxianAnim then
		self._wuxianAnim:removeFromParent(true)
		self._wuxianAnim = nil
	end

	if self._superBtn then
		self._superBtn:removeFromParent()
		self._superBtn = nil
	end
	
	self._stage:setLocalZOrder(-1)
	-- self._energyBar:setLocalZOrder(14)
	ScheduleMgr:delayCall(1000, self, function ()
		if self._stage then
			self._stage:setTouchEnabled(true)
		end
    end)

    self:createSprite()  --刷新精灵动画
end

--领取宝箱奖励【一次领取全部】
function ArrowView:getRewards()
	local rNums = 0
	for i=1,3 do
		rNums = rNums + self._data["arrow"]["rewards"][tostring(i)]
	end
	if rNums == 0 then
		self._viewMgr:showTip(lang("ARROW_TIP_2"))
		return
	end

 	self:syncArrowData(function()
 		self._serverMgr:sendMsg("ArrowServer", "getArrowShootingReward", {}, true, {}, function (result)
			DialogUtils.showGiftGet( {
	            gifts = result["reward"], 
	            callback = function() end
	        })
			local rewards = self:getUI("bg.rewards")
			for i=1,3 do
				rewards:getChildByName("num"..i):setString(0)
			end
			self:refreshUI()
		end)
 		end)
end

--领取补给
function ArrowView:getSupplyRewards()
	local lastT, nextT, lastGetTime = self._arrowModel:getSupplyGetTime()
	if lastGetTime >= lastT then
		self._viewMgr:showTip(lang("ARROW_TIP_1"))
		return
	end

	if ((self._userModel:getData().arrowNum + 1)/self._mul or 0) >= tab.setting["G_ARROW_LIMIT"].value then
		self._viewMgr:showTip(lang("ARROW_TIP_4"))
		return
	end

	self:syncArrowData(function()
		self._serverMgr:sendMsg("ArrowServer", "supplyArrow", {}, true, {}, function (result)
			-- dump(result, "supplyArrow")
			DialogUtils.showGiftGet( {
	            gifts = result["reward"], 
	            callback = function() end
	        ,notPop = true})
	        self:refreshUI()
	        self:timeCount()
			end)
		end)
end

--倒计时
function ArrowView:timeCount()
	local currTime = self._userModel:getCurServerTime()
	local lastT, nextT, lastGetTime = self._arrowModel:getSupplyGetTime()

	if lastGetTime >= lastT then   --不可领
		self:addBoxEffect(self._supplyBox, false)
		local tempTime = nextT - currTime
		self._timeCount:runAction(cc.RepeatForever:create(cc.Sequence:create(
	        cc.CallFunc:create(function()
	            tempTime = tempTime - 1
	            if tempTime > 0 then
	            	self._timeCount:setPosition(195, -9)
	            	self._timeCount:setString(TimeUtils.getTimeString(tempTime))
	            else
	            	self._timeCount:stopAllActions()
	            	self:addBoxEffect(self._supplyBox, true)
	            	self._timeCount:setPosition(208, -9)
	            	self._timeCount:setString("可领取")
	            end
	        end), cc.DelayTime:create(1))
	    ))
	else
		self:addBoxEffect(self._supplyBox, true)
		self._timeCount:setPosition(208, -9)
		self._timeCount:setString("可领取")
	end
end

-- 加奖励特效
function ArrowView:addBoxEffect(rewardBox, isPlay, isMove)
	--特效
	rewardBox:stopAllActions()
	rewardBox:setRotation(0)
	local effect = rewardBox:getChildByName("shanguang")
	if effect ~= nil then
		effect:removeFromParent(true)
		effect = nil
	end

	if isPlay then
		effect = mcMgr:createViewMC("baoxiangguang1_baoxiang", true)
	    effect:setPosition(rewardBox:getContentSize().width/2, rewardBox:getContentSize().height/2)
	    effect:setName("shanguang")
	    rewardBox:addChild(effect, 100)

	    if isMove then  
	    	local action1 = cc.RotateTo:create(0.15, 20)
		    local action2 = cc.RotateTo:create(0.15, -10)
		    local action3 = cc.RotateTo:create(0.15, 20)
	        local action4 = cc.RotateTo:create(0.15, 0)
	        rewardBox:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2, action3, action4, cc.DelayTime:create(0.5))))
	    end
	end
end

--选择箭数
function ArrowView:chooseArrow(inType)
	-- 出激光箭时不能选择箭矢数
	if self._isFreeze == true then
		self._subBtn:setSaturation(-180)
		self._subBtn:setTouchEnabled(false)
		self._addBtn:setSaturation(-180)
		self._addBtn:setTouchEnabled(false)
		return
	end
	
	if inType ~= nil then
		if inType == "add" then
			self._chooseNum = math.min((self._chooseNum +1)/self._mul + 1, 3) * self._mul - 1
			--加动画
			local arrowObj = self._arwSel[(self._chooseNum + 1)/self._mul]
			local addAnim = mcMgr:createViewMC("borm_nengliangtiao", false, true)
			addAnim:setPosition(arrowObj:getPositionX(), arrowObj:getPositionY() + arrowObj:getContentSize().height/2)
			self._energyBar:addChild(addAnim, 5)

			addAnim:addCallbackAtFrame(5, function()
				self._energyBar:stopAllActions()
				self._energyBar:setScale(1)
				self._energyBar:setPosition(MAX_SCREEN_WIDTH/2, -9)
				self._energyBar:runAction(cc.Spawn:create(
					cc.Sequence:create(
						cc.ScaleTo:create(0.02, 0.95),
						cc.ScaleTo:create(0.02, 1)
					),
					cc.Sequence:create(
						cc.MoveBy:create(0.02, cc.p(0, 5)),
						cc.MoveBy:create(0.02, cc.p(0, -5))
					)))
				end)
			

		elseif inType == "sub" then
			--减动画
			local arrowObj = self._arwSel[(self._chooseNum + 1)/self._mul]
			local subAnim = mcMgr:createViewMC("die_nengliangtiao", false, true)
			subAnim:setPosition(arrowObj:getPositionX() - 1, arrowObj:getPositionY() + arrowObj:getContentSize().height/2)
			self._energyBar:addChild(subAnim, 5)

			self._chooseNum = math.max((self._chooseNum +1)/self._mul - 1, 1) * self._mul - 1

			subAnim:addCallbackAtFrame(3, function()
				self._energyBar:stopAllActions()
				self._energyBar:setScale(1)
				self._energyBar:setPosition(MAX_SCREEN_WIDTH/2, -9)
				self._energyBar:runAction(cc.Spawn:create(
					cc.Sequence:create(
						cc.ScaleTo:create(0.02, 0.95),
						cc.ScaleTo:create(0.02, 1)
					),
					cc.Sequence:create(
						cc.MoveBy:create(0.02, cc.p(0, 5)),
						cc.MoveBy:create(0.02, cc.p(0, -5))
					)))
				end)
		end
		self:createSprite()
	end

	self._subBtn:setSaturation(0)
	self._subBtn:setTouchEnabled(true)
	self._addBtn:setSaturation(0)
	self._addBtn:setTouchEnabled(true)
	if (self._chooseNum + 1) / self._mul == 1 then
		self._subBtn:setSaturation(-180)
		self._subBtn:setTouchEnabled(false)
	elseif (self._chooseNum + 1) / self._mul == 3 then
		self._addBtn:setSaturation(-180)
		self._addBtn:setTouchEnabled(false)
	end

	for i=1,3 do
		if i <= (self._chooseNum + 1) / self._mul then
			self._arwSel[i]:setVisible(true)
		else
			self._arwSel[i]:setVisible(false)
		end
	end
end

function ArrowView:onBeforeAdd(callback, errorCallback)
	self:syncArrowData(function()
 		self._serverMgr:sendMsg("ArrowServer", "getArrowInfo", {}, true, {}, function (result)
	        if result == nil then 
	            errorCallback()
	            self._viewMgr:unlock(51)
	            return
	        end
	        callback()
	        self:runEnterAnim()
	    end)
 		end, function()
	 		errorCallback()
	 		self._viewMgr:unlock(51)
 		end)
end

function ArrowView:runEnterAnim()
	self._viewMgr:lock(-1)
	local wordNode = cc.Node:create()
	wordNode:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
	self:addChild(wordNode, 1002)

	self._gameBg:setLocalZOrder(1000)
	self._gameBg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT*0.5-160)
	self._gameBg:setScale(2)
	self._gameBg:runAction(cc.Sequence:create(
    	cc.MoveTo:create(1.6, cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT*0.5)),  
    	cc.Spawn:create(															
    		cc.EaseIn:create(cc.MoveTo:create(0.4, cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)), 2),
    		cc.EaseIn:create(cc.ScaleTo:create(0.4, 1), 2)),
    	cc.DelayTime:create(0.5),
    	cc.CallFunc:create(function()
    		self._gameBg:setLocalZOrder(-2)
    		self._stage:setLocalZOrder(-1)
    		self:startPlay()
    		end)
    	))

	local word1 = ccui.ImageView:create("arrow_word1.png", 1)
	word1:setOpacity(0)
	word1:setScale(5)
	word1:setPosition(0, 0)
	word1:setVisible(false)
	wordNode:addChild(word1)

	local word2 = ccui.ImageView:create("arrow_word2.png", 1)
	word2:setScale(5)
	word2:setOpacity(0)
	word2:setPosition(0, 100)
	word2:setVisible(false)
	wordNode:addChild(word2)

	wordNode._11 = word1
	wordNode._22 = word2

	local function wordAim(inObj, disTime, index, scale)  --1.5
		inObj:setVisible(true)
		inObj:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.2),
	 		cc.Spawn:create(
	 			cc.EaseIn:create(cc.ScaleTo:create(0.2, scale[1]), 2), 
	 			cc.EaseIn:create(cc.FadeIn:create(0.2), 2)),
	 		cc.CallFunc:create(function()
	 			if index == 2 then
	 				local goAnim = mcMgr:createViewMC("xingxing_shejianui", false, true)
					goAnim:setPosition(wordNode:getPositionX()+2, wordNode:getPositionY() + 100)
					self:addChild(goAnim, 1001)
	 			end
	 			end),
	 		cc.EaseIn:create(cc.ScaleTo:create(0.1, scale[2]), 2),							
	 		cc.DelayTime:create(disTime),
	 		cc.EaseIn:create(cc.ScaleTo:create(0.2, 0.2),2),										
	 		cc.CallFunc:create(function()
	 			inObj:removeFromParent(true)
	 			if index == 2 and wordNode then
	 				wordNode:stopAllActions()
	    			wordNode:removeFromParent(true)
	    			wordNode = nil

	    			self:popBoxRewards()
	    			self._viewMgr:unlock()
	 			end
	 			end)
	 		))
	end
	wordNode:runAction(cc.Sequence:create(
		cc.CallFunc:create(function() wordAim(word1, 0.8, 1, {1.8, 2})  end),
		cc.DelayTime:create(1.6),
		cc.CallFunc:create(function() wordAim(word2, 0.65, 2, {1.4, 1.5})  end)
	))
end

function ArrowView:popBoxRewards()
	local rwds = self._arrowModel:getPopBoxRewards()
	if rwds and next(rwds) then
		self._isScheduleStop = true
		DialogUtils.showGiftGet( {
            gifts = rwds, 
            callback = function() 
            	self._isScheduleStop = false
            	self._arrowModel:clearPopBoxRewards()
        	end})
	end
end

function ArrowView:refreshDoubleHit(isDouble)
	if isDouble == true then
		self._doubleHitNum = math.min(self._doubleHitNum + 1, 99)
		if self._doubleHitNum < 2 then
			return
		end
	else
		self._doubleHitNum = 0
		if self._doubleHit ~= nil then
			self._doubleHit:removeFromParent(true)
			self._doubleHit = nil
		end
		return
	end

	local width1, height1 = 0, 0 
	local width2, height2 = 70, 10
	local t1,t2 = math.modf(self._doubleHitNum/10)
	t2 = t2 * 10

	local scaleF = 1
	if t1 > 0 then
		scaleF = 1.3
	end

	if self._doubleHitNum < 100 then
		if self._doubleHit == nil then    --生成动画  从右滑出
			self._doubleHit = ccui.Layout:create()
			self._doubleHit:setPosition(MAX_SCREEN_WIDTH - 255, MAX_SCREEN_HEIGHT*0.5 + 120)
			self._stage:addChild(self._doubleHit, 50)

			local hitBg = cc.Sprite:createWithSpriteFrameName("arrow_hitBg.png")
			hitBg:setAnchorPoint(cc.p(0, 0.5))
			hitBg:setPosition(width1 + 250, height1)
			self._doubleHit.hitBg = hitBg
			self._doubleHit:addChild(hitBg)

			local hitNum2 = cc.Sprite:createWithSpriteFrameName("arrow_hitNum_".. t2 ..".png") 	--个位
			hitNum2:setPosition(width2 + 200, height2)
			self._doubleHit.hitNum2 = hitNum2
			self._doubleHit:addChild(hitNum2)
			hitNum2:setScale(scaleF)

			local hitNum1 = cc.Sprite:createWithSpriteFrameName("arrow_hitNum_".. t1 ..".png")	--十位
			hitNum1:setPosition(width2 + 200, height2)
			hitNum1:setScale(scaleF)
			self._doubleHit.hitNum1 = hitNum1
			self._doubleHit:addChild(hitNum1)

			hitBg:runAction(cc.Sequence:create(
				cc.MoveTo:create(0.1, cc.p(width1 - 10, height1)),
				cc.MoveTo:create(0.1, cc.p(width1 + 10, height1))
				))

			if t1 > 0 then  -- >10
				hitNum1:runAction(cc.Sequence:create(
					cc.MoveTo:create(0.1, cc.p(width2 - 45, height2)),
					cc.MoveTo:create(0.15, cc.p(width2 - 35, height2)))
				)

				hitNum2:runAction(cc.Sequence:create(
				cc.MoveTo:create(0.1, cc.p(width2 + 15, height2)),
				cc.MoveTo:create(0.15, cc.p(width2 + 25, height2)),
				cc.DelayTime:create(3),
				cc.CallFunc:create(function()
					if self._doubleHit ~= nil then
						self._doubleHit:removeFromParent(true)
						self._doubleHit = nil
					end
					end)
				))
			else     		-- <10
				hitNum1:setVisible(false)
				hitNum2:runAction(cc.Sequence:create(
				cc.MoveTo:create(0.1, cc.p(width2 - 10, height2)),
				cc.MoveTo:create(0.2, cc.p(width2 + 10, height2)),
				cc.DelayTime:create(3),
				cc.CallFunc:create(function()
					if self._doubleHit ~= nil then
						self._doubleHit:removeFromParent(true)
						self._doubleHit = nil
					end
					end)
				))
			end

		else  --变化动画，个位数变化
			self._doubleHit.hitNum1:setScale(scaleF)
			self._doubleHit.hitNum2:setScale(scaleF)
			if t1 > 0 and not self._doubleHit.hitNum1:isVisible() then  -- 9-10
				self._doubleHit.hitNum1:setSpriteFrame("arrow_hitNum_".. t1 ..".png")
				self._doubleHit.hitNum1:setVisible(true)
				self._doubleHit.hitNum1:runAction(cc.MoveTo:create(0.05, cc.p(width2 - 35, height2)))

				self._doubleHit.hitNum2:setSpriteFrame("arrow_hitNum_".. t2 ..".png")
				self._doubleHit.hitNum2:runAction(cc.Sequence:create(
					cc.MoveTo:create(0.05, cc.p(width2 + 25, height2)),
					cc.DelayTime:create(3),
					cc.CallFunc:create(function()
						if self._doubleHit ~= nil then
							self._doubleHit:removeFromParent(true)
							self._doubleHit = nil
						end
						end))
					)

			else
				self._doubleHit.hitBg:runAction(cc.Sequence:create(
					cc.MoveTo:create(0.03, cc.p(width1, height1 - 10)),
					cc.EaseIn:create(cc.MoveTo:create(0.07, cc.p(width1, height1)), 0.5) 
					))
				
				self._doubleHit.hitNum2:runAction(cc.Sequence:create(
					cc.Spawn:create(
						cc.ScaleTo:create(0.03, scaleF + 0.3),
						cc.RotateTo:create(0.03, -13)
						),
					cc.Spawn:create(
						cc.ScaleTo:create(0.03, scaleF),
						cc.RotateTo:create(0.03, 0)
						),
					cc.CallFunc:create(function()
						self._doubleHit.hitNum2:setSpriteFrame("arrow_hitNum_".. t2 ..".png")
						end),
					cc.ScaleTo:create(0.04, scaleF - 0.2),
					cc.ScaleTo:create(0.05, scaleF - 0.1),
					cc.ScaleTo:create(0.05, scaleF),
					cc.DelayTime:create(3),
					cc.CallFunc:create(function()
						if self._doubleHit ~= nil then
							self._doubleHit:removeFromParent(true)
							self._doubleHit = nil
						end
						end)
					))

				self._doubleHit.hitNum1:setSpriteFrame("arrow_hitNum_".. t1 ..".png")
				self._doubleHit.hitNum1:runAction(cc.Sequence:create(
					cc.MoveTo:create(0.03, cc.p(width2 - 35, height2 - 10)),
					cc.EaseIn:create(cc.MoveTo:create(0.07, cc.p(width2 - 35, height2)), 0.5) 
					))
			end
		end

		if t2 == 0 and t1 > 0 then
			local animName, posX
			if t1 == 1 then
				animName = "great_shejianlianji"
				posX = 10
			elseif t1 == 2 then
				animName = "perfect_shejianlianji"
				posX = 20
			else
				animName = "unbelievable_shejianlianji"
				posX = 50
			end

			-- animName = "unbelievable_shejianlianji"
			-- posX = 50

			if self._doubleHit._aimNode ~= nil then
				self._doubleHit._aimNode:removeFromParent(true)
				self._doubleHit._aimNode = nil
			end

			local animNode = cc.Node:create()
			animNode:setPosition(posX, 60)
			self._doubleHit._aimNode = animNode
			self._doubleHit:addChild(animNode)

            local showImg = mcMgr:createViewMC(animName, false, true)
            showImg:setPosition(80, -100)
            animNode:addChild(showImg)
        end
	end
end

-- 退界面/进界面/buyBtn/领宝箱/领补给/领送箭/rankBtn
function ArrowView:syncArrowData(inFunc, errorCallback)
	local syncData = SystemUtils.loadAccountLocalData("syncArrowData")
	-- dump(syncData, "sync", 10)
	if syncData ~= nil and type(syncData) == "table" and syncData["arrowList"] and next(syncData["arrowList"]) ~= nil then
		syncData["mStatis"][1] = syncData["mStatis"][1] + 1
		syncData["syncReqId"] = SystemUtils.loadAccountLocalData("SYNC_ARROW_REQUEST_ID") or 1  --上次同步id
		ServerManager:getInstance():sendMsg("ArrowServer", "syncArrowData", syncData, true, {}, function(result)
			if result["errorCode"] == nil then   
				inFunc()
			else
				ApiUtils.playcrab_lua_error("ArrowView syncArrowData====="..result["errorCode"], serialize(syncData))
				if result["errorCode"] == 3833 then  --弱网同步
					inFunc()
					return
				end

				if errorCallback ~= nil then
					errorCallback()
				else
					self:close()
				end
				ViewManager:getInstance():showTip("数据异常")
			end
		end)
	else
		inFunc()
	end
end

function ArrowView:applicationDidEnterBackground()
	if self._energyBar2 ~= nil then
		if self._isFreeze == true and self._superNum > 0 then  --是否是大招状态下切后台
			self._enterBackTime = self._userModel:getCurServerTime()
		end
		self._isEnterBack = true
	end
end

function ArrowView:applicationWillEnterForeground()
	if self._isEnterBack == true then
		self._isEnterBack = false
		self._enterForeTime = self._userModel:getCurServerTime()
	end
end

function ArrowView:getAsyncRes()
    return {{"asset/ui/arrow.plist", "asset/ui/arrow.png"}}
end


return ArrowView


-- self._viewMgr:showView("activity.arrow.ArrowView")
--[[ 层级

选择箭数  *-
箭类型    *
血量 	  +

射中列表  *

self._gameBg----  -2/1000
self._stageBg---  -1/1000
ui--------------  0


--------------self------------
1 self._stage -1/100
2 奖励层 0
3 关闭按钮 0 
4 购买箭矢 0 

--------------self._stage-----
怪物
射中特效
射死特效

[精灵 弓箭不能合并为一个widget，因为箭在stage上，且需在精灵和弓箭之间]
蓄力动画 10
弓箭 11
箭 12
精灵-- 13
    --射箭精灵  2
    --精灵  3
箭底座 14 / -1

压黑层-- -1
箭雨按钮--21
箭雨按钮点击动画--20
箭雨按钮释放动画--20
无限符号动画--20
文字动画 -- 20

连击数	--50
]]

--防改内存
--[[
箭数: self._chooseNum / _num / arrowType
血量: blood
]]