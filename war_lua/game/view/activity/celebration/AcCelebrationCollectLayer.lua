--
-- Author: huangguofang
-- Date: 2017-06-29 17:51:29
--
local AcCelebrationCollectLayer = class("AcCelebrationCollectLayer", require("game.view.activity.common.ActivityCommonLayer"))

function AcCelebrationCollectLayer:ctor(param)
    self.super.ctor(self)
    self._collectData = param.data or {}
    self._celebrationModel = self._modelMgr:getModel("CelebrationModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function AcCelebrationCollectLayer:onInit()
    self.super.onInit(self)
    
    self._bg = self:getUI("bg")
    self._bg:setBackGroundImage("asset/bg/ac_celebration_collectBg.png")

    -- 活动时间
    local starTime ,endTime = self._celebrationModel:getCelebrationTime()
    -- local startTb = TimeUtils.getDateString(starTime,"*t")
    -- local endTb = TimeUtils.getDateString(endTime,"*t")
    -- local dateString = string.format("%d月%d日--%d月%d日",startTb.month,startTb.day,startTb.hour,endTb.month,endTb.day,endTb.hour)  
    local currTime = self._userModel:getCurServerTime()
    local time = tonumber(endTime) - tonumber(currTime)
    local timeStr = TimeUtils.getTimeStringFont1(time)

    local activity_date = self:getUI("bg.activity_date")
    activity_date:setString(timeStr)
    if currTime >= endTime then
		activity_date:setString("0天00:00:00")
	else
		local repeatAction = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
	    	local currTime = self._userModel:getCurServerTime()
	    	local time = tonumber(endTime) - tonumber(currTime)
    		local timeStr = TimeUtils.getTimeStringFont1(time)
	    	activity_date:setString(timeStr)
	    	if currTime >= endTime then
	    		activity_date:setString("0天00:00:00")
	    		activity_date:stopAllActions()
	    	end
	    end)))
		activity_date:runAction(repeatAction)
	end

    -- 跳转
    self._goBtn = self:getUI("bg.goBtn")
    self._goBtn:setVisible(false)
    registerClickEvent(self._goBtn,function(sender)
    	local isOpen = self._celebrationModel:isCelebrationEnd()
		if not isOpen then
			self._viewMgr:showTip("活动已结束")
			return 
		end
    	-- 跳转到副本
    	self._viewMgr:showView("intance.IntanceView")
    end)

    self._giftBtn = self:getUI("bg.giftBtn")
    local mc = mcMgr:createViewMC("lingzhushouce_lianmengjihuo", true, false) 
    mc:setScale(0.9)
    mc:setPosition(self._giftBtn:getContentSize().width*0.5, self._giftBtn:getContentSize().height*0.5)
    mc:setName("diguang")
    self._giftBtn:addChild(mc,-1)
    local title1 = self:getUI("bg.giftBtn.title")
    title1:setFontSize(20)
    title1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    registerClickEvent(self._giftBtn,function(sender)
    	print("=================领取礼物======")
    	self:friendGiftBtnClicked()
    end)

	self._exchangeBtn = self:getUI("bg.exchangeBtn")
    self._exchangeBtn:setVisible(false)
    local title2 = self:getUI("bg.exchangeBtn.title")
    title2:setFontSize(20)
    title2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    registerClickEvent(self._exchangeBtn,function(sender)
    	print("=================兑换道具======")
    	self:exchangeBtnClicked()
    end)

    self._sendBtn = self:getUI("bg.sendBtn")
    self._sendBtn:setVisible(false)
    local title3 = self:getUI("bg.sendBtn.title")
    title3:setFontSize(20)
    title3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    registerClickEvent(self._sendBtn,function(sender)
    	print("=================赠送礼物======")
    	self:sendBtnClicked()
    end)

    self._getBtn = self:getUI("bg.getBtn")
    registerClickEvent(self._getBtn,function(sender)
    	print("=================领取礼包======")    	
    	self:getGiftBtnClicked()
    end)
    self._btnPosX, self._btnPosY= self._getBtn:getPosition()


    self._desImg2 = self:getUI("bg.desImg2")
    self._desImg3 = self:getUI("bg.desImg3")

    self._toolPanel = self:getUI("bg.toolPanel")
    self._toolId = {
    	[1] = "31038",
		[2] = "31039",
		[3] = "31040",
		[4] = "31041",
		[5] = "31042",
		[6] = "31043",
		[7] = "31044",
		[8] = "31045",
	}
    self._haveArr 	= {}
    self._noArr		= {}
    self._numArr	= {}
    for i=1,8 do
    	local tool = self._toolPanel:getChildByFullName("tool" .. i)
    	local tool0 = self._toolPanel:getChildByFullName("tool0_" .. i)
    	local num = self._toolPanel:getChildByFullName("num" .. i)
    	self._haveArr[i] = tool
		self._noArr[i] = tool0
		self._numArr[i] = num
    end
    -- 获取集字活动数据
    self:getCelebrationData()
    self:updateUI()
end

function AcCelebrationCollectLayer:reflashUI(data)   
	self._collectData = self._celebrationModel:getCollectionCeleData()
	self:updateUI()
end

-- 刷新界面
function AcCelebrationCollectLayer:updateUI()
	-- 八个字集合
	self._textArr = {}
	if self._collectData.text then
		self._textArr = json.decode(self._collectData.text)
	end
	local hasReceived = self._collectData.hasReceived and self._collectData.hasReceived == 1

	for i=1,8 do
		local toolNum = self._textArr[self._toolId[i]] or 0
    	if self._haveArr[i] then
    		self._haveArr[i]:setVisible(toolNum > 0 or hasReceived)
    	end
		if self._noArr[i] then
			self._noArr[i]:setVisible(toolNum == 0 and not hasReceived)
		end
		if self._numArr[i] then
			self._numArr[i]:setString("x" .. toolNum)
		end
    end
    -- print("================================self._collectData.hasReceived===",self._collectData.hasReceived)
    self._giftBtn:setVisible(self._collectData.hasGift and self._collectData.hasGift == 1)
    self._goBtn:setVisible(self._collectData.hasReceived and self._collectData.hasReceived ~= 1 or false)
    self._sendBtn:setVisible(hasReceived or false)
	self._exchangeBtn:setVisible(hasReceived or false)
	self._desImg2:setVisible(self._collectData.hasReceived and self._collectData.hasReceived ~= 1 or false)
	self._desImg3:setVisible(hasReceived or false)
	
    -- 更新礼物按钮状态
    self._giftBtn:setOpacity(255)
    if self._giftBtn._getMc then
    	self._giftBtn._getMc:setVisible(false)
    end
    if self._collectData.hasGift and self._collectData.hasGift == 1 then
		-- 有礼物待领
		-- self._giftBtn:setOpacity(0)
		if self._giftBtn._getMc then
	    	self._giftBtn._getMc:setVisible(true)
	    else
	    	--todo sendMsg
	    end
	end

    -- 更新领取按钮状态
    -- self._getBtn
    self._getBtn:setOpacity(255)
    if self._getBtn._getMc then
    	self._getBtn._getMc:setVisible(false)
    end
    self._getBtn:setPosition(self._btnPosX,self._btnPosY)
	if self._collectData and self._collectData.hasReceived then
		if self._collectData.hasReceived == 0 then
			self._getBtn:setOpacity(0)
			-- 添加领取动画
			if self._getBtn._getMc then
		    	self._getBtn._getMc:setVisible(true)
		    else
		    	self._getBtn._getMc = mcMgr:createViewMC("jizibaoxiang1_jizibaoxiang", true, false)
			    self._getBtn._getMc:setPosition(90, 62)
			    self._getBtn:addChild(self._getBtn._getMc, 3)
		    end
		elseif self._collectData.hasReceived == 1 then
			-- 已领
			self._getBtn:setPosition(self._btnPosX+12,self._btnPosY+16)
			self._getBtn:loadTextures("celebration_collect_boxOpen.png","celebration_collect_boxOpen.png","celebration_collect_boxOpen.png",1)
		elseif self._collectData.hasReceived == -1 then
			-- 未达到条件
			self._getBtn:loadTextures("celebration_collect_boxClose.png","celebration_collect_boxClose.png","celebration_collect_boxClose.png",1)
		end
	end
end

function AcCelebrationCollectLayer:getCelebrationData()
	local isOpen = self._celebrationModel:isCelebrationEnd()
	if not isOpen then
		return 
	end
	self._serverMgr:sendMsg("ActivityServer", "getCollectionTextInfo", {}, true, {}, function(result,succ)
	    
    end)
end

-- 领取礼包  领取集字狂欢奖励
function AcCelebrationCollectLayer:getGiftBtnClicked()
	local isOpen = self._celebrationModel:isCelebrationEnd()
	if not isOpen then
		self._viewMgr:showTip("活动已结束")
		return 
	end
	if not self._collectData then return end
	if self._collectData.hasReceived then
		if self._collectData.hasReceived == 0 then
			if self._getBtn._getMc then 
				self._getBtn._getMc:setVisible(false)
			end
			local openMc = mcMgr:createViewMC("jizibaoxiang2_jizibaoxiang", false, false,function(_,sender)
				-- 可领取未领取
				self._serverMgr:sendMsg("ActivityServer", "getCollectionReward", {}, true, {}, function(result,succ)
				    if result["reward"] then
			        	DialogUtils.showGiftGet({gifts = result["reward"]})
			        end
					sender:removeFromParent()
			    end)
			end)
		    openMc:setPosition(90, 62)
		    self._getBtn:addChild(openMc, 3)
			
		elseif self._collectData.hasReceived == 1 then
			-- 已领
			self._viewMgr:showTip("您已经领取过该礼包")	
		elseif self._collectData.hasReceived == -1 then
			-- 未达到条件
			self._viewMgr:showTip("祝福文字尚未集齐，继续加油吧~")	
		end
	else
		self._viewMgr:showTip("祝福文字尚未集齐，继续加油吧~")
	end
end

-- 打开赠送的文字面板 礼包
function AcCelebrationCollectLayer:friendGiftBtnClicked()
	local isOpen = self._celebrationModel:isCelebrationEnd()
	if not isOpen then
		self._viewMgr:showTip("活动已结束")
		return 
	end
	if not self._collectData then return end
	if self._collectData.hasGift then
		if self._collectData.hasGift == 1 then
			-- -- 有礼物待领
			self._serverMgr:sendMsg("ActivityServer", "getFriendSendTexts", {}, true, {}, function(result,succ)
			    print("===============打开好赠送的文字面板=======")
			    self._viewMgr:showDialog("activity.celebration.AcCelebrationGiftsDialog", {
			    	giftsData = result,
			    	callBack = function()
			    		self._giftBtn:setVisible(false)
			    	end})
		    end)
		else
			-- 0 没有
			self._viewMgr:showTip("暂时没有可领取的礼物")	
		end
	else
		self._viewMgr:showTip("暂时没有可领取的礼物")
	end
end

-- 兑换面板
function AcCelebrationCollectLayer:exchangeBtnClicked()	
	local isOpen = self._celebrationModel:isCelebrationEnd()
	if not isOpen then
		self._viewMgr:showTip("活动已结束")
		return 
	end
	local exchangeTb = {}
	if self._collectData.exchangeInfo and self._collectData.exchangeInfo ~= "" then
		exchangeTb = json.decode(self._collectData.exchangeInfo)
	end
	self._viewMgr:showDialog("activity.celebration.AcCollectExchangeDialog", {exchangeInfo = exchangeTb,textArr = self._textArr})
end

-- 打开赠送好友面板
function AcCelebrationCollectLayer:sendBtnClicked()
	local isOpen = self._celebrationModel:isCelebrationEnd()
	if not isOpen then
		self._viewMgr:showTip("活动已结束")
		return 
	end
	-- 获取好友列表
	self._serverMgr:sendMsg("ActivityServer", "getInsufficientTextFriends", {}, true, {}, function(result,succ)
		local friendList = result and result.d or {}
		self._viewMgr:showDialog("activity.celebration.AcCollectFriendDialog", {friendData = friendList,textArr = self._textArr})
	end)

end
    	
return AcCelebrationCollectLayer