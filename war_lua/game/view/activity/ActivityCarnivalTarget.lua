--
-- Author: huangguofang
-- Date: 2016-04-01 10:32:32
--
local ActivityCarnivalTarget = class("ActivityCarnivalTarget",BasePopView)
function ActivityCarnivalTarget:ctor(param)
    self.super.ctor(self)
    self._parentView = param.parentView
    self._targetBtn = param.targetBtn
end
-- 第一次被加到父节点时候调用
function ActivityCarnivalTarget:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function ActivityCarnivalTarget:onInit()

    local bg_img = self:getUI("bg.bg_img")
    -- bg_img:loadTexture("bg_activityCarnival2.png",1)

	self:registerClickEventByName("bg.closeBtn", function()
		if self._parentView.addBubbles then
			self._parentView:addBubbles(self._targetBtn)
		end
		self:close()
		-- UIUtils:reloadLuaFile("activity.ActivityCarnivalTarget")
	end)

	self.awardPanel = self:getUI("bg.scrollView.awardPanel")
	self.awardPanel:setVisible(false)	

    --倒计时
    self._carnivalModel = self._modelMgr:getModel("ActivityCarnivalModel")	
    self._acId = self._carnivalModel:getCarnivalId()
	self._activityDay = 7
	self._day,self._leftTime = self._carnivalModel:getCurrDay()
	self._leftDay = self._activityDay - self._day	
	self._showDay = self._activityDay - self._day - 1	

	
    self._getPanel = self:getUI("bg.scrollView.getPanel")
    self._getPanel:setVisible(false)
    self.scrollView = self:getUI("bg.scrollView")
    self:updateScrollView()
end

function ActivityCarnivalTarget:updateScrollView()
	local scrollH = self.awardPanel:getContentSize().height + self._getPanel:getContentSize().height
	-- 增加富文本
	local rtxStr = lang("jianianhua_rule_" .. self._acId)  --lang("RULE_ARENA")
    -- rtxStr = string.gsub(rtxStr,"ffffff","d49f66")
	local rtx = RichTextFactory:create(rtxStr,356,200)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    -- rtx:setAnchorPoint(cc.p(0,1))    
    rtx:setName("rtx")
    scrollH = scrollH + rtx:getVirtualRendererSize().height

    local awardP = self.awardPanel
	local iconPosX,iconPosY = self:getUI("bg.scrollView.awardPanel.itemIcon"):getPosition()
	local acData = tab:SevenAimConst(self._acId)
	local award = {}
	if acData then
		award = acData.reward or {}
	else
		acData = tab:SevenAimConst(901)
		award = acData.reward or {}
	end
	
	local data = self._carnivalModel:getData()
	local taskTxt = awardP:getChildByFullName("taskTxt")
	local progressNum = awardP:getChildByFullName("progressNum")
	local currGet = awardP:getChildByFullName("currGet")
	currGet:setString("可领奖励:")
    local progressTxt = awardP:getChildByFullName("taskValue")
   	self._completeNum = self._carnivalModel:getTotalStatus()
   	if data["total"] then 
   		self._totalNum = table.nums(data) - 1
   	else
   		self._totalNum = table.nums(data)
   	end
    progressTxt:setString(self._completeNum.."/"..self._totalNum)
    local currTxt = awardP:getChildByFullName("progressValue")
    local percentNum = math.ceil(self._completeNum/self._totalNum*1000)
    percentNum = percentNum / 10
    currTxt:setString(percentNum.."%")

	local toolD = tab:Tool(tonumber(award[2]))
	local toolNum = tonumber(award[3]) * tonumber(self._completeNum) / tonumber(self._totalNum)

	local canGetTxt = awardP:getChildByFullName("currGetValue")
	canGetTxt:setString(math.ceil(toolNum))

	local icon = IconUtils:createItemIconById({itemId = award[2],itemData = toolD,num = award[3]})
	icon:setScale(0.80)
	icon:setAnchorPoint(0.5,0.5)
	icon:setPosition(iconPosX,iconPosY)
    awardP:addChild(icon)

    awardP:setVisible(true)
	awardP:setPositionY(scrollH - self.awardPanel:getContentSize().height)
	-- self.scrollView:addChild(awardP)

	local getPanel = self._getPanel
--
	self._getBtn = getPanel:getChildByFullName("getBtn")
	self._getBtn:setTitleFontName(UIUtils.ttfName)
    self._getBtn:setColor(cc.c4b(255, 255, 255, 255))
    self._getBtn:setTitleFontSize(28)
    if data["total"] and data["total"].status == 1 then 
    	self._getBtn:setTitleText("已领取")
    	self._getBtn:setSaturation(-100)
    	self._getBtn:setEnabled(false)
    end
	if self._leftDay < 0 then 
    	self._getBtn:setSaturation(-100)
    	self._getBtn:setEnabled(false)
    	self._viewMgr:showTip("活动结束")
    end

    if self._leftDay < 0 then 
    	self._getBtn:setSaturation(-100)
    	self._getBtn:setEnabled(false)
    end

	registerClickEvent(self._getBtn,function(sender) 
		--点击领取按钮
	   	self:getTargetAward()
    end)
	getPanel:setVisible(true)
	getPanel:setPositionY(rtx:getVirtualRendererSize().height)
	-- self.scrollView:addChild(getPanel)

	local ruleTxt =  getPanel:getChildByFullName("ruleTxt")
	--计算倒计时
	local timeTxt = getPanel:getChildByFullName("timeTxt")	
	timeTxt:setString("领取倒计时:")
	timeTxt:setAnchorPoint(1,0.5)
	local timeCount = getPanel:getChildByFullName("timeCount")
	timeCount:setPositionX(self._getBtn:getPositionX())
	timeTxt:setPosition(timeCount:getPosition())
	local timerFunc = function()
		local day 
		day,self._leftTime = self._carnivalModel:getCurrDay()

		if self._showDay < 0 then
			timeTxt:setVisible(false)
			timeCount:setVisible(false)
			return
		end
        if self._showDay >= 0 and self._leftTime > 1 then
       		self._leftTime = self._leftTime - 1
       		timeCount:setString(string.format("%d天 %02d:%02d:%02d",self._showDay,math.floor(self._leftTime/3600),math.floor((self._leftTime%3600)/60),self._leftTime%60) or 0)
        elseif self._showDay >= 0 and self._leftTime <= 1 then
        	self._leftDay = self._leftDay - 1
        	self._showDay = self._leftDay - 1
        	-- print("================",self._showDay,self._leftDay)
        	if self._showDay < 0 then
	       		self._leftTime = 0       		
	       		timeCount:setString("0天 00:00:00")
	       		-- self._getBtn:setSaturation(-100)
		    	-- self._getBtn:setEnabled(false)
		    	-- self._viewMgr:showTip("活动结束")		    	
	       	else
	       		self._leftTime = 86400
	       		-- self._leftDay = self._leftDay - 1	 
	       		if self._showDay < 0 then
					timeTxt:setVisible(false)
					timeCount:setVisible(false)					     		
					-- if self._carnivalModel:getTotalStatus() <= 0 then 
				 --    	self._getBtn:setSaturation(-100)
				 --    	self._getBtn:setEnabled(false)
				 --    end
				    if self.timer then
				        ScheduleMgr:unregSchedule(self.timer)
				        self.timer = nil
				    end
				end 
	       		timeCount:setString(string.format("%d天 %02d:%02d:%02d",self._showDay,math.floor(self._leftTime/3600),math.floor((self._leftTime%3600)/60),self._leftTime%60) or 0)
        	end
        end       
    end

	if self._showDay >= 0 then 
	    timerFunc()
		self._timerFunc = timerFunc
		self.timer = ScheduleMgr:regSchedule(1000,self,function( )
	        self._timerFunc()
	    end)
	else
		timeTxt:setVisible(false)
		timeCount:setVisible(false)	
	end


	rtx:setPosition(self.scrollView:getContentSize().width/2 + 4,rtx:getContentSize().height/2 + 20)
	self.scrollView:addChild(rtx)

	self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,scrollH))
end

function ActivityCarnivalTarget:getTargetAward()
	if self._leftDay <= 0 or self._completeNum == self._totalNum then
			if self._completeNum <= 0 then		    	
			    self._viewMgr:showTip("没有可以领取的奖励")
			    return
			end
	   		self._viewMgr:showDialog("global.GlobalSelectDialog",
	            {desc = "您确定要现在领取全目标奖励吗？    （奖励只能领取一次哦）",
	            alignNum = 1,
	            -- button1 = "确定",
	            -- button2 = "取消", 
	            callback1 = function ()
	            -- if true then
	            -- 	self._viewMgr:showTip("领取领取领取")
	            -- 	return
	            -- end
	            	-- 发送领取协议
	                self._serverMgr:sendMsg("AwardServer", "getSevenAimReward", {acId = self._acId,taskId = "total"}, true, {}, function(data)
				        -- dump(data["reward"])
				        if data["reward"] then 
				        	DialogUtils.showGiftGet({ gifts = data["reward"]})
				        	self._getBtn:setTitleText("已领取")
				        	self._getBtn:setSaturation(-100)
				        	self._getBtn:setEnabled(false)
				        end
			    	end)
	            end,
	            callback2 = function()

	        	end},true)
	    else
	    	self._viewMgr:showTip(lang("jianianhua_lingqu"))
	    end
end

-- 被其他View盖住会调用, 有需要请覆盖
function ActivityCarnivalTarget:onDestroy()
	self.super.onDestroy(self)
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
end
-- 接收自定义消息
function ActivityCarnivalTarget:reflashUI(data)

end

return ActivityCarnivalTarget
