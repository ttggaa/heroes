--[[
    Filename:    CollegeView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-09-7 14:39:47
    Description: File description
--]]

local CollegeView = class("CollegeView",BaseView)
function CollegeView:ctor(param)
    CollegeView.super.ctor(self)
    self.initAnimType = 2
    self._userModel = self._modelMgr:getModel("UserModel")
    self._talentModel = self._modelMgr:getModel("TalentModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._spellBooksModel = self._modelMgr:getModel("SpellBooksModel")
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
    -- self._trainingModel = self._modelMgr:getModel("TrainingModel")
    -- -- 是否从活动界面跳转
    -- self._isFromAc = param and param.isFromAc or false

    self:registerTimer(5,0,5,function()
        self:updateButtonRed()
    end)
end

function CollegeView:getAsyncRes()
    return 
    {
        {"asset/ui/skillCard.plist", "asset/ui/skillCard.png"}
    }
end

function CollegeView:getRegisterNames()
	return{
		{"trainingNode1","bg.trainingNode1"},
		{"trainingNode2","bg.trainingNode2"},
		{"trainingNode3","bg.trainingNode3"},
		{"bg","bg"},
		{"pointIcon1","bg.trainingNode1.pointIcon"},
		{"pointIcon2","bg.trainingNode2.pointIcon"},
		{"pointIcon3","bg.trainingNode3.pointIcon"},
	}
end

function CollegeView:getBgName()
    return "bg_001.jpg"
end

function CollegeView:setNavigation()
	self._viewMgr:showNavigation("global.UserInfoView",{title = "CollegeView_title.png",titleTxt = "学院"})
end

-- function CollegeView:onBeforeAdd( callback )  

-- 	local needRequest = self._trainingModel:getIsNeedRequest()
-- 	if needRequest then
-- 		-- print("===================CollegeView==needRequest====",needRequest)
-- 	    self._serverMgr:sendMsg("TrainingServer", "init", {}, true, {}, function(data)	       
-- 	        if callback then 
-- 		        callback()
-- 		    end
-- 	    	-- self:reflashUI()        
-- 	    end) 
-- 	else
-- 		if callback then 
-- 	        callback()
-- 	    end
--     	-- self:reflashUI() 
-- 	end
-- end

--更新解锁数据
function CollegeView:updateLockView()

	local LockImg2 = self._trainingNode2:getChildByFullName("lockPanel")
	local LockImg3 = self._trainingNode3:getChildByFullName("lockPanel")
	
	local tabData = tab:SystemOpen("SkillBook")
	dump(tabData,"aaaa",10)
	local openLevel = tabData[1]
	local playerLevel = self._userModel:getData().lvl

	local isOpen = false
	if openLevel <= playerLevel then
		isOpen = true
	end
	-- isOpen = false  --need 1
	LockImg2:setVisible(not isOpen)
	LockImg3:setVisible(not isOpen)
	if not isOpen then
		for i=2,3 do 
			local tipsLabel = self["_trainingNode"..i]:getChildByFullName("lockPanel.tips")
			tipsLabel:setString("玩家达到"..openLevel.."级开启")
			UIUtils:setGray(self["_trainingNode"..i],true)
		end
		--need 2
		-- for i=2,3 do 
		-- 	local tipsLabel = self["_trainingNode"..i]:getChildByFullName("lockPanel.tips")
		-- 	tipsLabel:setString("敬请期待")
		-- 	UIUtils:setGray(self["_trainingNode"..i],true)
		-- end
	end
	self._isOpen = isOpen
	self._openTips = tabData[3]  ----need 3
	-- self._openTips = "SKILLBOOK_TIPS116"
end

-- 初始化UI后会调用, 有需要请覆盖
function CollegeView:onInit()
	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	UIUtils:reloadLuaFile("talent.CollegeView")
        	UIUtils:reloadLuaFile("talent.TalentView")
        	UIUtils:reloadLuaFile("skillCard.SkillCardTakeView")
        	UIUtils:reloadLuaFile("spellbook.SkillTalentDialog")
        end
    end)

	self:registerClickEvent(self._trainingNode1,function() 		
		self._viewMgr:showView("talent.TalentView",{},true)
	end)

	self:registerClickEvent(self._trainingNode2,function()
		if not self._isOpen then
			self._viewMgr:showTip(lang(self._openTips))
			return
		end 		
		print("法术书柜")
		self._viewMgr:showView("spellbook.SpellBookCaseView",{},true)
	end)

	self:registerClickEvent(self._trainingNode3,function()
		if not self._isOpen then
			self._viewMgr:showTip(lang(self._openTips))
			return
		end 		
		print("法术祈愿")
		self._viewMgr:showView("skillCard.SkillCardTakeView")
	end)

	self._trainingNode1:getChildByFullName("des"):setString(lang("SKILLBOOK_RUKOU1"))
	self._trainingNode2:getChildByFullName("des"):setString(lang("SKILLBOOK_RUKOU2"))
	self._trainingNode3:getChildByFullName("des"):setString(lang("SKILLBOOK_RUKOU3"))

	self:updateLockView()
	self:updateButtonRed()
end

function CollegeView:updateButtonRed()
	
	--魔法学院
	local red = self._talentModel:checkTalentPopTip()
	self._pointIcon1:setVisible(red)

	--魔法书柜
	red = (self._spellBooksModel:checkBookCaseRed() or self._skillTalentModel:checkIsCanActOrUp()) and SystemUtils:enableSkillBook()
	self._pointIcon2:setVisible(red)


	--法术祈愿
	red = self._spellBooksModel:checkSkillCardRed()
	self._pointIcon3:setVisible(red)
end

function CollegeView:beforePopAnim()
	CollegeView.super.beforePopAnim(self)
	for i=1,3 do
		local hole = self["_trainingNode" .. i]
		hole:setCascadeOpacityEnabled(true, true)
		hole:setOpacity(0)
		hole:setScaleAnim(true)
	end
end

-- 重载出现动画
function CollegeView:popAnim(callback)
	-- print("===============popAnim=======================")
	-- 执行父节点动画
	CollegeView.super.popAnim(self, nil)
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
		local hole = self["_trainingNode" .. i]
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
			-- if obj._idx == 3 then	
			-- 	-- 活动界面进来不需要播动画
			-- 	if self._isMidNeedAnim then
			--         self:unlockSeniorAnim(self._trainingNode2,"CollegeView_anim_clipNodeJ1.png",function()			
			-- 			self:updateProgressByType(2)	
			-- 			-- 更新中级训练场的显示				
			-- 			local juniorLockPanel = self:getUI("bg.trainingNode2.lockPanel")
			-- 			local juniorProgressBg = self:getUI("bg.trainingNode2.progressBg")
			-- 			-- 中级解锁 panel隐藏
			-- 			juniorLockPanel:setVisible(not self._isUnlockjunior)
			-- 			juniorProgressBg:setVisible(self._isUnlockjunior)	
			-- 			self._trainingNode2:setSaturation(self._isUnlockjunior and 0 or -100)				
			-- 		end,-2,-241)
			-- 	end
			-- 	if self._isSenNeedAnim then
			-- 		self:unlockSeniorAnim(self._trainingNode3,"CollegeView_anim_clipNodeS1.png",function()
			-- 			self:updateSeniorPanel()
			-- 		end,140,-20)
			-- 	end	
			-- 	if callback then
			-- 		callback()
			-- 	end
			-- end
			if callback then
				callback()
			end
		end))
		hole:runAction(seq)
	end
end

function CollegeView:onTop()
	self:updateButtonRed()
end

function CollegeView:onDestroy( )
	CollegeView.super.onDestroy(self)
end

return CollegeView