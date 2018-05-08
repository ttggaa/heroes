--
-- Author: huangguofang
-- Date: 2016-09-27 23:37:07
-- Description:训练所入口
local TrainingView = class("TrainingView",BaseView)
function TrainingView:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 2
    self._trainingModel = self._modelMgr:getModel("TrainingModel")
    -- 是否从活动界面跳转
    self._isFromAc = param and param.isFromAc or false
end

function TrainingView:getAsyncRes()
    return 
    {
        {"asset/ui/training.plist", "asset/ui/training.png"},
    }
end

function TrainingView:getBgName()
    return "bg_001.jpg"
end

function TrainingView:setNavigation()
    -- self._viewMgr:showNavigation("global.UserInfoView",{types = {"Gold","Gem","Physcal"},title = "globalTitleUI_rank.png",callback = function()
    -- 		-- self._rankModel:clearRankList()
    -- 	end})
	
	self._viewMgr:showNavigation("global.UserInfoView",{title = "trainingView_title.png",titleTxt = "训练所"})
end
-- function TrainingView:setNoticeBar()
--     self._viewMgr:hideNotice(false)
-- end

-- 第一次被加到父节点时候调用
function TrainingView:onAdd()

end

function TrainingView:onBeforeAdd( callback )  

	local needRequest = self._trainingModel:getIsNeedRequest()
	if needRequest then
		-- print("===================TrainingView==needRequest====",needRequest)
	    self._serverMgr:sendMsg("TrainingServer", "init", {}, true, {}, function(data)	       
	        if callback then 
		        callback()
		    end
	    	-- self:reflashUI()        
	    end) 
	else
		if callback then 
	        callback()
	    end
    	-- self:reflashUI() 
	end
    
end
function TrainingView:onShow()
	-- 如果是从活动界面跳转，打开黄执中关卡
	if self._isFromAc then
		self._taskView = self._viewMgr:showDialog("training.TrainingTaskView", {parent = self,trainType = 3,goStageIdx=23,isFromAc = true}, true)
	end
end
-- 初始化UI后会调用, 有需要请覆盖
function TrainingView:onInit()
	-- 通用动态背景
    self:addAnimBg()

    -- 主界面  气泡
    local userLvl = self._modelMgr:getModel("UserModel"):getPlayerLevel()
    if tonumber(userLvl) < 35 then
    	SystemUtils.saveAccountLocalData("trainView_clickLvl",userLvl)
    end
    -- SystemUtils.saveAccountLocalData("trainView_clickLvl",0)

    self._cupImg = {
    	[1] = "trainingView_inViewCopper.png",
    	[2] = "trainingView_inViewSliver.png",
    	[3] = "trainingView_inViewGolden.png",
    	[4] = "trainingView_inViewWG.png",
	}
    --scrollView
    self._bg = self:getUI("bg")
	-- self._scrollView:setBounceEnabled(true)

	-- 初级训练所
	self._trainingNode1 = self:getUI("bg.trainingNode1")
    self._trainingNode1.pointIcon = self._trainingNode1:getChildByFullName("pointIcon")
    self._trainingNode1.pointIcon:setVisible(false)
    
	local mc1 = self._trainingNode1:getChildByFullName("passAnim")
	if not mc1 then
		local clipNode = cc.ClippingNode:create()
	    clipNode:setPosition(140,227)
	    clipNode:setContentSize(cc.size(300, 476))
	    -- local mask = cc.Scale9Sprite:createWithSpriteFrameName("trainingView_anim_clipNodeJ.png")
		-- mask:setCapInsets(cc.rect(200, 136, 1, 1))
		-- mask:setContentSize(300, 476)
		local mask = cc.Sprite:createWithSpriteFrameName("trainingView_anim_clipNodeJ.png")
	    mask:setAnchorPoint(0.5,0.5)
	    clipNode:setStencil(mask)
	    clipNode:setAlphaThreshold(0.1)
	    clipNode:setName("passAnim")
	    clipNode:setVisible(false)

	    mc1 = mcMgr:createViewMC("tongguanchangtai_trainingrukou", true,false)
	    clipNode:addChild(mc1)
	    self._trainingNode1:addChild(clipNode,100)
	
	end
	-- mc1:setVisible(false)
	-- self:updateProgressByType(1)

	self:registerClickEvent(self._trainingNode1,function() 		
		-- print("======================初级训练所==============")
		self._taskView = self._viewMgr:showDialog("training.TrainingTaskView", {parent = self,trainType = 1}, true)
	end)		

	-- 中级训练所
	self._trainingNode2 = self:getUI("bg.trainingNode2")
    self._trainingNode2.pointIcon = self._trainingNode2:getChildByFullName("pointIcon")
    self._trainingNode2.pointIcon:setVisible(false)

	local mc2 = self._trainingNode2:getChildByFullName("passAnim")
	if not mc2 then		
		local clipNode = cc.ClippingNode:create()
	    clipNode:setPosition(140,227)
	    clipNode:setContentSize(cc.size(300, 476))
	    local mask = cc.Sprite:createWithSpriteFrameName("trainingView_anim_clipNodeJ.png")
	    mask:setAnchorPoint(0.5,0.5)
	    clipNode:setStencil(mask)
	    clipNode:setAlphaThreshold(0.1)
	    clipNode:setName("passAnim")
	    clipNode:setVisible(false)

	    mc2 = mcMgr:createViewMC("tongguanchangtai_trainingrukou", true,false)
	    clipNode:addChild(mc2)
	    self._trainingNode2:addChild(clipNode,100)
	end
	-- mc2:setVisible(false)
    -- self:updateProgressByType(2)
    
    -- 等级开启限制提示
    local juniorTb = tab:Setting("JUNIOR_TRAINING")
    local juniorLvl = juniorTb and juniorTb.value or 0
  	local txt2 = self:getUI("bg.trainingNode2.lockPanel.txt2")
  	txt2:setString(juniorLvl .. "级开启")

    -- 中级是否开启通关(等级限制)
    self._isUnlockjunior = self._trainingModel:isMiddleOpen()
	self:registerClickEvent(self._trainingNode2,function() 
		if self._isUnlockjunior then
			self._taskView = self._viewMgr:showDialog("training.TrainingTaskView", {parent = self,trainType = 2}, true)
		else
			self._viewMgr:showTip(juniorLvl .. "级开启")
		end
	end)

	-- 高级训练所
	self._trainingNode3 = self:getUI("bg.seniorBgPanel.trainingNode3")
    self._trainingNode3.pointIcon = self._trainingNode3:getChildByFullName("pointIcon")
    self._trainingNode3.pointIcon:setVisible(false)
    self._trainingNode3:setSwallowTouches(false)

    local mc3 = self._trainingNode3:getChildByFullName("passAnim")
	if not mc3 then
		local clipNode = cc.ClippingNode:create()
	    clipNode:setPosition(142,234)
	    clipNode:setContentSize(cc.size(300, 486))
	    local mask = cc.Sprite:createWithSpriteFrameName("trainingView_anim_clipNodeS.png")
	    mask:setAnchorPoint(0.5,0.5)
	    clipNode:setStencil(mask)
	    clipNode:setAlphaThreshold(0.1)
	    clipNode:setName("passAnim")
	    clipNode:setVisible(false)

	    mc3 = mcMgr:createViewMC("tongguanchangtai_trainingrukou", true,false)
	    clipNode:addChild(mc3)
	    self._trainingNode3:addChild(clipNode,5)
	end

    -- 等级开启限制提示
    local senTb = tab:Setting("SENIOR_TRAINING")
    local senLvl = senTb and senTb.value or 0
  	local txt2 = self:getUI("bg.seniorBgPanel.trainingNode3.lockPanel.txt2")
  	txt2:setString(senLvl .. "级开启")

    -- 高级是否开启通关(等级限制)
    self._isUnlockSen = self._trainingModel:isSeniorOpen()
    self._trainingSenior = self:getUI("bg.seniorBgPanel")
	self:registerClickEvent(self._trainingSenior,function() 
		-- print("======================高级训练所==============")
		if self._isUnlockSen then
			self._taskView = self._viewMgr:showDialog("training.TrainingTaskView", {parent = self,trainType = 3}, true)
		else
			self._viewMgr:showTip(senLvl .. "级开启")
		end
	end)

	local seniorLock = self:getUI("bg.seniorBgPanel.seniorLock")
	seniorLock:setVisible(false)

	-- 解锁动画需要
	self._trainingNode2:setSaturation(-100)
	self._trainingNode3:setSaturation(-100)

	-- 高级训练所开启动画
	local isSenAnim = SystemUtils.loadAccountLocalData("trainUnlockAnim") or false
    if self._isUnlockSen and not isSenAnim and not self._trainingModel:isHaveSenior() then
        SystemUtils.saveAccountLocalData("trainUnlockAnim",true) 
		-- 入口动画执行完之后开始解锁动画
		self._isSenNeedAnim = true
    else
		self:updateSeniorPanel()
    end
    -- 中级训练所开启动画
	local isMidAnim = SystemUtils.loadAccountLocalData("trainUnlockAnim_middle") or false
    if self._isUnlockjunior and not isMidAnim and not self._trainingModel:isHaveMiddle() then
        SystemUtils.saveAccountLocalData("trainUnlockAnim_middle",true)
		-- 入口动画执行完之后开始解锁动画
		self._isMidNeedAnim = true
        
    else
   		local juniorLockPanel = self:getUI("bg.trainingNode2.lockPanel")
		local juniorProgressBg = self:getUI("bg.trainingNode2.progressBg")
		-- 中级解锁 panel隐藏
		juniorLockPanel:setVisible(not self._isUnlockjunior)
		juniorProgressBg:setVisible(self._isUnlockjunior)    	
		self:updateProgressByType(2)
		self._trainingNode2:setSaturation(self._isUnlockjunior and 0 or -100)
    end

    -- 更新训练所进度
    self:updateProgressByType(1)

	self:listenReflash("TrainingModel", self.reflashUI)

	-- self:reflashUI()
end

function TrainingView:updateProgressByType(trainType)
	local comNum,percent = self._trainingModel:getTrainingProgress(trainType)
	local progressBar = self["_trainingNode" .. trainType]:getChildByFullName("progressBg.progressBar")
	local proTxt = self["_trainingNode" .. trainType]:getChildByFullName("progressBg.proTxt")
	progressBar:setPercent(percent)
	proTxt:setString(percent .. "%")

	local passImg = self["_trainingNode" .. trainType]:getChildByFullName("passImg")
	passImg:setVisible(100 == percent)

	local mc = self["_trainingNode" .. trainType]:getChildByFullName("passAnim")
	mc:setVisible(100 == percent)

	local pointIcon = self["_trainingNode" .. trainType]:getChildByFullName("pointIcon")
	pointIcon:setVisible(self._trainingModel:isCanGetReward(trainType))

	local titleTxt = self["_trainingNode" .. trainType]:getChildByFullName("titleTxt")
	titleTxt:setPositionX(100 == percent and 153 or 140)
	-- local proBG = self["_trainingNode" .. trainType]:getChildByFullName("progressBg")
	-- for i=1,6 do
	-- 	local proImg = proBG:getChildByFullName("progress" .. i)
	-- 	if i <= comNum then
	-- 		proImg:setVisible(true)
	-- 	else
	-- 		proImg:setVisible(false)
	-- 	end
	-- end
end

function TrainingView:updateSeniorPanel()
    -- print("updateSeniorPanel====================")    
	self:getUI("bg.seniorBgPanel"):setSaturation(self._isUnlockSen and 0 or -100)
	-- 总评分
	local scoreSum = self._trainingModel:getSeniorSumScore()
	local trainData = self._trainingModel:getDataByType(3)
	local per = 0
	--   (总评分^0.5)/24.5
	if scoreSum ~= 0 then
		-- per = math.sqrt(scoreSum) / 24.5 * 1000
		-- (总评分/9)^0.5 * 10  by hgf 17.03.13
		 per = math.sqrt(scoreSum/(table.nums(trainData) - 1)) * 100
	end
	per = math.ceil(per) / 10.0 
	per = per > 100 and 100 or per
	local unLockPanel = self._trainingNode3:getChildByFullName("unLockPanel")
	local challengeTxt = self._trainingNode3:getChildByFullName("unLockPanel.challengeTxt")
	local proTxt = self._trainingNode3:getChildByFullName("unLockPanel.proTxt")
	local desTxt = self._trainingNode3:getChildByFullName("unLockPanel.desTxt")
	local desTxt1 = self._trainingNode3:getChildByFullName("unLockPanel.desTxt1")

	if 0 == per then
		challengeTxt:setVisible(true)
		desTxt:setVisible(false)
		desTxt1:setVisible(false)
		proTxt:setVisible(false)
	else
		challengeTxt:setVisible(false)
		desTxt:setVisible(true)
		desTxt1:setVisible(true)
		proTxt:setVisible(true)
		proTxt:setString("" .. per .. "%")	
        desTxt:setPositionX(proTxt:getPositionX() - proTxt:getContentSize().width * 0.5)
        desTxt1:setPositionX(proTxt:getPositionX() + proTxt:getContentSize().width * 0.5)
	end

	local pointIcon = self._trainingNode3:getChildByFullName("pointIcon")
	pointIcon:setVisible(self._trainingModel:isCanGetReward(3))

	local comNum,percent = self._trainingModel:getTrainingProgress(3)
	local passImg = self._trainingNode3:getChildByFullName("passImg")
	passImg:setVisible(100 == percent) 
	local titleTxt = self._trainingNode3:getChildByFullName("titleTxt")
	titleTxt:setPositionX(100 == percent and 153 or 140)

	local mc = self._trainingNode3:getChildByFullName("passAnim")
	mc:setVisible(100 == percent)

    local lockPanel = self._trainingNode3:getChildByFullName("lockPanel") 
    local cupPanel = self._trainingNode3:getChildByFullName("cupPanel")
    local cupImg = cupPanel:getChildByFullName("cupImg")

    -- 获取高级训练所的奖杯数据    
    local sNum = self._trainingModel:getScoreSNum(3)
    local starNum = sNum % 3

    for i=1,3 do
    	-- 零星的时候不显示星星
    	-- local starBg = cupImg:getChildByFullName("starBg" .. i)
    	-- starBg:setVisible(not (starNum == 0))

    	local star = cupImg:getChildByFullName("star" .. i)
    	if i <= starNum then
    		star:setVisible(true)
    	else
    		star:setVisible(false)
    	end
    end

    if self._isUnlockSen then
    	unLockPanel:setVisible(true)
		lockPanel:setVisible(false)
		UIUtils:setGray(self._trainingNode3,false)
		if sNum == 0 then
			cupPanel:setVisible(false)
		else
			cupPanel:setVisible(true)			
		    local cupData = self._trainingModel:getCupDataBuySNum()    
		    cupImg:loadTexture(self._cupImg[cupData.id],1)
		end		
	else
		unLockPanel:setVisible(false)
		lockPanel:setVisible(true)
		UIUtils:setGray(self._trainingNode3,true)
		cupPanel:setVisible(false)
	end

end
function TrainingView:beforePopAnim()
	-- print("===============beforePopAnim================")
	TrainingView.super.beforePopAnim(self)
	-- 如果是活动跳转 不播动画
	if self._isFromAc then return end
	for i=1,3 do
		local hole = 3 ~= i and self["_trainingNode" .. i] or self._trainingSenior
		hole:setCascadeOpacityEnabled(true, true)
		hole:setOpacity(0)
		hole:setScaleAnim(true)

		-- if 3 == i then 
		-- 	local seniorLock = self:getUI("bg.seniorBgPanel.seniorLock")
		-- 	seniorLock:setCascadeOpacityEnabled(true)
		-- 	seniorLock:setOpacity(0)
		-- end

		-- local lockbg = self["_trainingNode" .. i]:getChildByName("lockbg")
		-- if lockbg then
		-- 	lockbg:setCascadeOpacityEnabled(true)
		-- 	lockbg:setOpacity(0)
		-- end
	end
end

-- 重载出现动画
function TrainingView:popAnim(callback)
	-- print("===============popAnim=======================")
	-- 执行父节点动画
	TrainingView.super.popAnim(self, nil)
	if self._isFromAc then
		if callback then
			callback()
		end
	end
	-- 如果是活动跳转 不播动画
	if self._isFromAc then return end

	-- 定义自己动画
	local delayTime = 0.1
	local moveTime = 0.1
	local springTime = 0.2
	local fadeInTime = 0.1
	local moveDis = 200
	local springDis = 10
	for i=1,3 do
		local hole = 3 ~= i and self["_trainingNode" .. i] or self._trainingSenior
		local holeInitPos = cc.p(hole:getPositionX(),hole:getPositionY())
		local holeSpringPos = cc.p(hole:getPositionX()-springDis,hole:getPositionY())
		local holebeginPos = cc.p(hole:getPositionX()+moveDis,hole:getPositionY())
		hole:setPosition(holebeginPos)
		hole._idx = i
		local holeDelayTime = delayTime*(i-1) + 0.1
		local delayAct = cc.DelayTime:create(holeDelayTime)
		local spawn = cc.Spawn:create(cc.MoveTo:create(moveTime,holeSpringPos),cc.FadeIn:create(fadeInTime))
		local seq = cc.Sequence:create(delayAct,spawn,cc.MoveTo:create(springTime,holeInitPos),cc.CallFunc:create(function(obj)
			
			hole:setScaleAnimMin(0.9)
			hole:setAnchorPoint(cc.p(0.5,0.5))
			hole:setPosition(cc.pAdd(holeInitPos,cc.p(142,221)))
			-- 执行完动画再执行解锁动画
			if obj._idx == 3 then	
				-- 活动界面进来不需要播动画
				if self._isMidNeedAnim then
			        self:unlockSeniorAnim(self._trainingNode2,"trainingView_anim_clipNodeJ1.png",function()			
						self:updateProgressByType(2)	
						-- 更新中级训练场的显示				
						local juniorLockPanel = self:getUI("bg.trainingNode2.lockPanel")
						local juniorProgressBg = self:getUI("bg.trainingNode2.progressBg")
						-- 中级解锁 panel隐藏
						juniorLockPanel:setVisible(not self._isUnlockjunior)
						juniorProgressBg:setVisible(self._isUnlockjunior)	
						self._trainingNode2:setSaturation(self._isUnlockjunior and 0 or -100)				
					end,-2,-241)
				end
				if self._isSenNeedAnim then
					self:unlockSeniorAnim(self._trainingNode3,"trainingView_anim_clipNodeS1.png",function()
						self:updateSeniorPanel()
					end,140,-20)
				end	
				if callback then
					callback()
				end
			end
		end))
		hole:runAction(seq)

		-- if 3 == i then 
		-- 	local seniorLock = self:getUI("bg.seniorBgPanel.seniorLock")
		-- 	seniorLock:setOpacity(255)
		-- 	local spawn = cc.Spawn:create(cc.MoveTo:create(moveTime,holeSpringPos),cc.FadeIn:create(fadeInTime))
		-- 	local seqFrame = cc.Sequence:create(delayAct,spawn,cc.MoveTo:create(springTime,holeInitPos))
		-- 	seniorLock:runAction(seqFrame)
		-- 	seniorLock:setPosition(holebeginPos)
		-- end

		-- local lockbg = self["_hole" .. i]:getChildByName("lockbg")
		-- if lockbg then
		-- 	lockbg:runAction(cc.FadeIn:create(fadeInTime))
		-- end
	end
end

function TrainingView:onDestroy( )
	-- if self._leagueOpenSch then
		-- ScheduleMgr:unregSchedule(self._leagueOpenSch)
		-- self._leagueOpenSch = nil 
	-- end
	TrainingView.super.onDestroy(self)
end

function TrainingView:isLocked()
	-- body
end

-- 接收自定义消息
function TrainingView:reflashUI(data)
	-- print("=============TrainingView==reflashUI()==========")
	self:updateProgressByType(1)
	self:updateProgressByType(2)

	self:updateSeniorPanel()

  --   local isSenAnim = false --SystemUtils.loadAccountLocalData("trainUnlockAnim") or false
  --   if self._isUnlockSen and not isSenAnim then
  --       SystemUtils.saveAccountLocalData("trainUnlockAnim",true)
  --       self:unlockSeniorAnim()
  --   else
		-- self:updateSeniorPanel()
  --   end
end

function TrainingView:onTop()
	if self._taskView and self._taskView.checkAnimStart then
		self._taskView:checkAnimStart()
	end
end

function TrainingView:clearTaskNode( )
	self._taskView = nil
end

-- 解锁动画  "trainingView_anim_clipNodeS.png"   self:updateSeniorPanel()
function TrainingView:unlockSeniorAnim(acPlayer,clipImg,callBack,posX,posY)
	-- print("###########TrainingView:unlockSeniorAnim()###########")
	-- self._trainingNode1  添加动画
	self:lock(-1)
	local dt = 0
	-- UIUtils:setGray(acPlayer,true)
	acPlayer:setSaturation(0)

	-- 高级
	local unLockPanel = acPlayer:getChildByFullName("unLockPanel")
    local passImg = acPlayer:getChildByFullName("passImg")
    local cupPanel = acPlayer:getChildByFullName("cupPanel")
    -- 中级
    local progressBg = acPlayer:getChildByFullName("progressBg")
    if passImg then
    	passImg:setVisible(false)
    end
    if cupPanel then
    	cupPanel:setVisible(false)
    end
    if unLockPanel then
	    unLockPanel:setVisible(false)
	end
	if progressBg then 
		progressBg:setVisible(false)
	end

	-- 添加特效
	local clipNode1 = cc.ClippingNode:create()
    clipNode1:setContentSize(cc.size(288, 467))
    local mask = cc.Sprite:createWithSpriteFrameName(clipImg)
    mask:setAnchorPoint(0.5,0.5)
    clipNode1:setStencil(mask)
    clipNode1:setAlphaThreshold(0.1)
    -- clipNode1:setInverted(true)

    local passMc = mcMgr:createViewMC("huanjia_trainingrukou", false, true, function (_, sender)    	
	end) 
	passMc:setPositionY(-20)
    clipNode1:addChild(passMc)
    clipNode1:setPosition(acPlayer:getPositionX()+posX, acPlayer:getPositionY()+posY + 250)
    acPlayer:getParent():addChild(clipNode1,100)	 

	-- 灰色面板
    local grayPanel = acPlayer:clone()    
    grayPanel:setAnchorPoint(0,0)
    -- UIUtils:setGray(grayPanel,true)
    grayPanel:setSaturation(-100)

    local clipNodeGray = cc.ClippingNode:create()
    clipNodeGray:setPosition(acPlayer:getPositionX()+posX, acPlayer:getPositionY()+posY)
    clipNodeGray:setContentSize(cc.size(288, 467))

    local maskGray = cc.Sprite:createWithSpriteFrameName(clipImg)
    maskGray:setAnchorPoint(0.5,0)    
    clipNodeGray:setStencil(maskGray)
    clipNodeGray:setInverted(false)

    clipNodeGray:setAlphaThreshold(0.05)
    grayPanel:setPosition(-140, 20)
    clipNodeGray:addChild(grayPanel)

    acPlayer:getParent():addChild(clipNodeGray,2)

    local grayAction = cc.Sequence:create(cc.DelayTime:create(0.1),cc.ScaleTo:create(0.6,1,0),cc.CallFunc:create(function ()
    	clipNodeGray:removeFromParent()
    end))

    maskGray:runAction(grayAction)

    local frame = acPlayer:getChildByFullName("frame")
    local lightImg = ccui.ImageView:create()
    lightImg:setScale(1.02)
    lightImg:loadTexture(clipImg,1)
    lightImg:setPosition(frame:getPosition())
    lightImg:setPurityColor(255, 255, 255)
    lightImg:setVisible(false)
    lightImg:setOpacity(150)
    acPlayer:addChild(lightImg,10)

    lightImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.75), 
    	cc.CallFunc:create(function ()
    		lightImg:setVisible(true)
    		lightImg:setOpacity(255)
    	end),
    	CCSpawn:create(cc.Blink:create(0.6, 1),cc.FadeOut:create(0.6)),cc.CallFunc:create(function()
	    	lightImg:removeFromParent()
			self:unlock()
	    	if callBack then
				callBack()
			end
			-- UIUtils:setGray(acPlayer,false)	
    end)))

end

return TrainingView