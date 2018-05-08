--
-- Author: huangguofang
-- Date: 2016-10-12 14:33:03
-- Description: 马厩领取体力界面
local ACSupplyPhysicalPower = class("ACSupplyPhysicalPower",require("game.view.activity.common.ActivityCommonLayer"))
function ACSupplyPhysicalPower:ctor()
    self.super.ctor(self)

    self._physicalModel = self._modelMgr:getModel("PhysicalPowerModel")
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function ACSupplyPhysicalPower:onInit()

	self._tableData = self._physicalModel:getData() or {}

	self._stablePanel = {}  --马厩容器数组
	self._stableBtn = {}	--马厩按钮容器
	self._stableBNumBg = {}

	self._canGetMc = nil
	self._bg = self:getUI("bg")

	self._currBtnIdx = 1 	--当前点击的按钮索引

	self._growBypri = {
		[1] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_19),
		[2] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_17),
		[3] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_18),
	}

	self._posYarr = {}
	self._posXarr = {}
	for i=1,3 do
		local stableData = self._tableData[i]

		local stablePanel = self:getUI("bg.stablePanel" .. i)
		self._stablePanel[i] = stablePanel

		local stableBtnBg = stablePanel:getChildByFullName("stableBtnBg")   --用于执行动画 runAction
		local stableBtn = stableBtnBg:getChildByFullName("stableBtn")
		self._stableBtn[i] = stableBtn

		self._posXarr[i] = stableBtnBg:getPositionX()
		self._posYarr[i] = stableBtnBg:getPositionY()
		--点击事件
		self:registerClickEvent(stableBtn, function ()
			-- print("==============================按钮点击点击点击=======",self._currBtnIdx)
			--点击马厩按钮
			self._currBtnIdx = i
	        self:clickStableBtn(i)
	        -- self:playGetAnim()    --动画调试用
	    end)

		-- 补领花费
		local costGetPanel = stableBtnBg:getChildByFullName("costGetPanel")
		local tipsTxt = costGetPanel:getChildByFullName("tipsTxt")
		local costTxt = costGetPanel:getChildByFullName("costTxt")
		costTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
		local reduce = stableData.reduce or {}
		costTxt:setString(reduce[3] or "")

		-- 体力数
		local physicalBg = stablePanel:getChildByFullName("physicalBg")
		local width = 45  -- 体力图片宽度 + 2像素
		local height = physicalBg:getContentSize().height

		local physicalImg = physicalBg:getChildByFullName("physicalImg")
		physicalImg:setAnchorPoint(cc.p(0,0.5)) 
		self._stableBNumBg[i] = physicalBg
		physicalBg:setVisible(false)
		local physicalNum = physicalBg:getChildByFullName("numTxt")

		width = width + physicalNum:getContentSize().width

		local reward = stableData.reward or {}
		physicalNum:setString(reward[3] or "") 
		physicalNum:setAnchorPoint(cc.p(0.5,0.5))
		local growNum = physicalBg:getChildByFullName("growNum")
		local resetGrowPos = false
		if self._growBypri[i] and self._growBypri[i] > 0 then
			growNum:setVisible(true)
			growNum:setString("+" .. self._growBypri[i])
			width = width + growNum:getContentSize().width + 4
			resetGrowPos = true
		else
			growNum:setVisible(false)
		end
		width = math.max(width, 85)

		if 1 == i then
			width = width + 2
		end
		--体力数居中显示
		physicalBg:setContentSize(width,height)
		physicalImg:setPosition(0, height*0.5)
		physicalNum:setPosition(physicalImg:getContentSize().width - 10 + physicalNum:getContentSize().width*0.5 , height*0.5)
		if resetGrowPos then
			growNum:setPosition(physicalNum:getPositionX()+physicalNum:getContentSize().width*0.5, height*0.5)
		end

	end

	self._timeTips = self:getUI("bg.timeBg.timeTips")
	-- 屋顶光
	local lightMc = mcMgr:createViewMC("wudingguangxian_lingqutili", true, false, function (_, sender)  end)
	lightMc:setPosition(50, 400)
	self._bg:addChild(lightMc,10)

	local houseMc = mcMgr:createViewMC("cao_lingqutili", true, false, function (_, sender)  end)
	houseMc:setPosition(315, 232)
	houseMc:setScale(0.95)
	self._bg:addChild(houseMc,10)

	self:reflashUI()
	--监听事件
	-- self:listenReflash("PhysicalPowerModel", self.reflashUI)

end

-- 接收自定义消息
function ACSupplyPhysicalPower:reflashUI(data)

	self._tableData = self._physicalModel:getData() or {}

	self:updateStableState()
end

function ACSupplyPhysicalPower:updateStableState()

	local currStableData = self._tableData[1]
	local isHaveGet = false
	for i=1,3 do
		local stableData = self._tableData[i]
		local stablePanel = self._stablePanel[i]
		local stableBtnBg = stablePanel:getChildByFullName("stableBtnBg") --动画panel 
		local stableBtn = self._stableBtn[i]
		stableBtnBg:stopAllActions()

		-- 移除特效
		local houseMc = stableBtn:getChildByFullName("houseMc")
		if houseMc then
			houseMc:removeFromParent()
		end
		-- 是否领取的状态
		local state = stableData.state or 0
		local imgName = 0 == state and "activity_physical_comStable.png" or "activity_physical_getStable.png"
		-- imgName = "activity_physical_getStable.png" 
		stableBtn:loadTextures(imgName,imgName,"",1)
		
		local tipsCom = stableBtnBg:getChildByFullName("canGetPanel")
		local tipsCost = stableBtnBg:getChildByFullName("costGetPanel")
		self._stableBNumBg[i]:setVisible(false)
		if 0 == state then 							-- state == 0：时间未到不可领取
			tipsCom:setVisible(false)
			tipsCost:setVisible(false)

		elseif 1 == state then 						--1：已可领
			stablePanel:setVisible(false)
		elseif 2 == state then  					--2：可领
			self._stableBNumBg[i]:setVisible(true)
			--背景光效
			houseMc = mcMgr:createViewMC("maanguang_lingqutili", true, false, function (_, sender)  end)
			houseMc:setName("houseMc")
			houseMc:setPosition(40, 40)
			-- houseMc:setScale(1.5)
			stableBtn:addChild(houseMc,-1)

			-- action
			local actionX = self._posXarr[i] or 0
			local actionY = self._posYarr[i] or 0
			local actionForever = cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(actionX, actionY+5)),cc.MoveTo:create(0.5, cc.p(actionX, actionY-5))))
			stableBtnBg:runAction(actionForever)

			tipsCom:setVisible(true)
			tipsCost:setVisible(false)

			isHaveGet = true
			currStableData = stableData

		elseif 3 == state then 						--3：补领
			self._stableBNumBg[i]:setVisible(true)
			-- action
			local actionX = self._posXarr[i] or 0
			local actionY = self._posYarr[i] or 0
			local actionForever = cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(actionX, actionY+5)),cc.MoveTo:create(0.5, cc.p(actionX, actionY-5))))
			stableBtnBg:runAction(actionForever)

			tipsCom:setVisible(false)
			tipsCost:setVisible(true)
		else
			print("==========physical power state is wrong==============")
		end

		-- tipsCom:setVisible(true)
		-- tipsCost:setVisible(true)
	end

	--领取时间提示
	if not isHaveGet then	
		for i=1,3 do
			local stableData = self._tableData[i]
			if stableData and 0 == stableData.state then
				currStableData = stableData
				break
			end
		end
	end
	--
	local timelimit = currStableData.timeLimit or {}
	self._timeTips:setString(timelimit[1] .. "-" .. timelimit[2])

end

function ACSupplyPhysicalPower:clickStableBtn(idx)
	-- print("====================sendMessage====",idx)
	if not self._modelMgr or not self._serverMgr then return end

	local clickData = self._tableData[idx] or {}

	local state = clickData.state or -1
	if 0 == state then 								-- 0：时间未到不可领取		
		self._viewMgr:showTip("未到领取时间")
	-- elseif 1 == state then 						--1：已可领
		
	elseif 2 == state then  						--2：可领	
		local physcal = self._modelMgr:getModel("UserModel"):getData().physcal 
        if physcal >= 3000 then
            self._viewMgr:showTip("体力接近上限，请去扫荡副本")
            return 
        end
        audioMgr:playSound("HorsePhysical")
		self._serverMgr:sendMsg("AwardServer", "getDailyPy", {id = clickData.id}, true, {}, function (success,result)
	        if not success then return end
	        self._tableData[idx].state = 1
	        self:playGetAnim(result)
	    end)

	elseif 3 == state then 	
		local physcal = self._modelMgr:getModel("UserModel"):getData().physcal 
        if physcal >= 3000 then
            self._viewMgr:showTip("体力接近上限，请去扫荡副本")
            return 
        end					--3：补领

		-- 体力数量
		local reward = clickData.reward or {}
		local phyNum = 0
		phyNum = phyNum + tonumber(reward[3])
		if self._growBypri[idx] and self._growBypri[idx] > 0 then
			phyNum = phyNum + tonumber(self._growBypri[idx])
		end
		--花费
		local reduce = clickData.reduce or {}	
		DialogUtils.showBuyDialog({costNum = reduce[3],costType = "gem",goods = "补领" .. phyNum .. "点体力",callback1 = function( )      
                if self._serverMgr and self._modelMgr then
                	local gem = self._modelMgr:getModel("UserModel"):getData().gem or 0
                	local costN = reduce[3] or 0
                	if gem < tonumber(costN) then
                		self._viewMgr:showTip("钻石不足")
                	else                	
	                	audioMgr:playSound("HorsePhysical")
		                self._serverMgr:sendMsg("AwardServer", "getOverducDailyPy", {id = clickData.id}, true, {}, function (success,result)
					        if not success then return end
					        self._tableData[idx].state = 1
					        self:playGetAnim(result)
					    end)
					end
				end
        end})			
	end
	
end

-- 领取动画
function ACSupplyPhysicalPower:playGetAnim(data)
	if not self._currBtnIdx then return end
	ViewManager:getInstance():lock(-1)
	local stableData = self._tableData[self._currBtnIdx] or {}	
	local PhyNum = 0
	local reward = stableData.reward or {}
	PhyNum = PhyNum + tonumber(reward[3])
	if self._growBypri[self._currBtnIdx] and self._growBypri[self._currBtnIdx] > 0 then
		PhyNum = PhyNum + tonumber(self._growBypri[self._currBtnIdx])
	end

	-- anim
	local stableBtnBg = self._stableBtn[self._currBtnIdx]:getParent()
	stableBtnBg:stopAllActions()
	
	--按钮
	self._stableBtn[self._currBtnIdx]:setOpacity(255)
	self._stableBtn[self._currBtnIdx]:setCascadeOpacityEnabled(true)

	local houseMc = self._stableBtn[self._currBtnIdx]:getChildByFullName("houseMc")
	if houseMc then
		houseMc:setOpacity(255)
		houseMc:setCascadeOpacityEnabled(true)
		local mcAction = cc.FadeOut:create(0.4)
		houseMc:runAction(mcAction)
		-- houseMc:setVisible(false)
	end	

	local btnPos = stableBtnBg:convertToWorldSpace(cc.p(self._stableBtn[self._currBtnIdx]:getPositionX()+30,self._stableBtn[self._currBtnIdx]:getPositionY()+30))
	-- print("=========btnPos=========",btnPos.x,btnPos.y,self._stableBtn[self._currBtnIdx]:getPositionX(),self._stableBtn[self._currBtnIdx]:getPositionY())
	local navigationObj = self._viewMgr:getNavigation("global.UserInfoView")
	local phyObj = navigationObj:getIconsArr()[1]
	local phyPos = cc.p(0,0)
	if phyObj then
		phyPos = phyObj:getParent():convertToWorldSpace(cc.p(phyObj:getPositionX()+30,phyObj:getPositionY()+30))
	end
	-- 按钮相对于导航条的位置
	local navigationPos = navigationObj:convertToNodeSpace(cc.p(btnPos.x,btnPos.y))

	--按钮闪光
	local actionLight = cc.Sequence:create(
		cc.CallFunc:create(function ()		
			self._stableBtn[self._currBtnIdx]:setBrightness(40)
		end),
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function ()		
			self._stableBtn[self._currBtnIdx]:setBrightness(0)
		end),
		cc.FadeOut:create(0.4),
		cc.CallFunc:create(function ()				
			-- self._viewMgr:showNavigation("global.UserInfoView", { 
			-- 					title = "globalTitleUI_activity.png", 								
			-- 					actionData = {pos = btnPos,num = PhyNum} ,
			-- 					actionCallBack = function()
			-- 						print("==============updateUserData===========")
			-- 						self._modelMgr:getModel("PrivilegesModel"):updateUserData(data)
			-- 					end
			-- 				})
		end))	
	self._stableBtn[self._currBtnIdx]:runAction(actionLight)

	-- 提示tips
	local tipsCom = stableBtnBg:getChildByFullName("canGetPanel")
	local tipsCost = stableBtnBg:getChildByFullName("costGetPanel")
	local currTip = tipsCom
	if tipsCom:isVisible() then
		currTip = tipsCom
	end
	if tipsCost:isVisible() then
		currTip = tipsCost
	end
	currTip:setOpacity(255)
	currTip:setCascadeOpacityEnabled(true)
	-- tips向上渐隐
	local tipAction = cc.Spawn:create(cc.DelayTime:create(0.6),cc.MoveBy:create(0.4,cc.p(0,20)),cc.FadeOut:create(0.4))
	currTip:runAction(tipAction)

	--飞行的体力
	local imgBg = ccui.ImageView:create()
    imgBg:loadTexture("globalImageUI4_power.png", 1)
    imgBg:setName("imgBg")
    imgBg:setOpacity(0)
    imgBg:setAnchorPoint(cc.p(0.5,0.5))
    imgBg:setPosition(navigationPos)
    navigationObj:addChild(imgBg,1)

    local powerBg = ccui.ImageView:create()
    powerBg:loadTexture("globalImageUI4_power.png", 1)
    powerBg:setName("powerBg")
    powerBg:setAnchorPoint(cc.p(0.5,0.5))
    powerBg:setPosition(0,0)
    imgBg:addChild(powerBg,1)

    local txt = ccui.Text:create()
    txt:setName("txt")
    txt:setFontName(UIUtils.ttfName)
    txt:setFontSize(24)
    txt:setAnchorPoint(cc.p(0,0.5))
    txt:setPosition(20, 0)
    txt:setString(PhyNum)
    txt:setColor(UIUtils.colorTable.ccColorQuality2)
    imgBg:addChild(txt,1)

    imgBg:setScale(0.1)

	--体力飞到导航条
	local seqAction = cc.Sequence:create(
		cc.ScaleTo:create(0.2,1.5),
		cc.ScaleTo:create(0.2,1),
		cc.DelayTime:create(0.1),
		cc.MoveBy:create(0.4,cc.p(phyPos.x - btnPos.x , phyPos.y - btnPos.y)),
		cc.CallFunc:create(function ()
			ModelManager:getInstance():getModel("UserModel"):updateUserData(data)
			if self._stablePanel then							
				self._stablePanel[self._currBtnIdx]:setVisible(false)			
				imgBg:setVisible(false)
			end
		end),
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function ()	
			if phyObj then	
				phyObj:setBrightness(40)
			end
		end),
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function ()
			if phyObj then		
				phyObj:setBrightness(0)
			end
			if imgBg then
				imgBg:removeFromParent()
			end
			ViewManager:getInstance():unlock()
		end))

	imgBg:runAction(seqAction)

end

return ACSupplyPhysicalPower