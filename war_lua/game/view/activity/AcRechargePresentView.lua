--
-- Author: huangguofang
-- Date: 2018-06-14 20:35:51
--
local AcRechargePresentView = class("AcRechargePresentView",BasePopView)
function AcRechargePresentView:ctor(data)
    self.super.ctor(self)
    self.initAnimType = 1
    self._closeCallBack = data.closeCallBack
end

function AcRechargePresentView:getAsyncRes()
    return 
    {
        "asset/bg/secondRecharge_panel.png",
    }
end

function AcRechargePresentView:getMaskOpacity( ... )
    return 130
end


-- function AcRechargePresentView:getBgName()
--     return "bg_001.jpg"
-- end

-- 第一次被加到父节点时候调用
function AcRechargePresentView:onAdd()

end


function AcRechargePresentView:onDestroy()
	cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/bg/secondRecharge_panel.png")
	AcRechargePresentView.super.onDestroy(self)
end

-- 初始化UI后会调用, 有需要请覆盖
function AcRechargePresentView:onInit()
	self._activityModel = self._modelMgr:getModel("ActivityModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	--关闭当前UI
	self:registerClickEventByName("bg.closeBtn", function() 
		if self._closeCallBack then
			self._closeCallBack()
		end
		self:close() 
		UIUtils:reloadLuaFile("activity.AcRechargePresentView")
	end)

	local acBg = self:getUI("bg.acBg")
	acBg:loadTexture("asset/bg/secondRecharge_panel.png")

	self._awardPanel = self:getUI("bg.rechargePanel.award_panel")

	self._getBtn = self:getUI("bg.rechargePanel.getBtn")
	self._rechargeBtn = self:getUI("bg.rechargePanel.rechargeBtn")
	self._getBtn:setTitleFontName(UIUtils.ttfName)
	self._getBtn:setTitleText(lang("ZHOUNIANHUIKUI_BUTTON_02"))
    self._getBtn:setColor(cc.c4b(255, 250, 220, 255))
    self._getBtn:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 2) --(cc.c4b(101, 33, 0, 255), 2)
    self._getBtn:setTitleFontSize(28)
    self._rechargeBtn:setTitleFontName(UIUtils.ttfName)
    self._rechargeBtn:setColor(cc.c4b(255, 250, 220, 255))
    self._rechargeBtn:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 2) --(cc.c4b(101, 33, 0, 255), 2)
    self._rechargeBtn:setTitleFontSize(28)
    self._rechargeBtn:setTitleText(lang("ZHOUNIANHUIKUI_BUTTON_01"))
    
    local desTxt = self:getUI("bg.rechargePanel.desTxt")
    desTxt:setColor(cc.c4b(190,232,243,255))
    desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    desTxt:setString(lang("ZHOUNIANHUIKUI_RULE_01"))

    --凤凰技能演示
    self:getUI("bg.rechargePanel.skillPlayBtn"):setVisible(false)
    --[[
	self:registerClickEventByName("bg.rechargePanel.skillPlayBtn", function() 
		-- self:getUI("bg.rechargePanel.skillPlayBtn"):setTouchEnabled(false)
		local teamId = 907
		local teamData = tab:Team(teamId)
		local playSkillId = 50134
		if teamData.showskill then
			playSkillId = teamData.showskill[1][3]
			-- print("====================[laySkill=========",playSkillId)
		end
		if playSkillId then
			self._viewMgr:showDialog("global.GlobalSkillPreviewDialog", {teamId = 907, skillId = tonumber(playSkillId)},true)
		else
			print("===========没有拿到需要展示的技能id======")
		end
	end)
	]]
	local mcMgr = MovieClipManager:getInstance()
    mcMgr:loadRes("itemeffectcollection", function ()
        self:addEffect()
	end)

	self:registerClickEvent(self._rechargeBtn, function ()
         self:turnToRecharge()
   	end)

	self:registerClickEvent(self._getBtn, function ()
         self:sendGetAwardMag()
   	end)

	self:updateBtnState()
	self:addReward()

	self:listenReflash("UserModel", self.updateBtnState)
end
function AcRechargePresentView:addEffect()
	local mc1 = mcMgr:createViewMC("lingqu_itemeffectcollection", true, false, function (_, sender)
	        sender:gotoAndPlay(0)	       
	    end)
    mc1:setPosition(cc.p(self._rechargeBtn:getContentSize().width/2,self._rechargeBtn:getContentSize().height/2))
    self._rechargeBtn:addChild(mc1,5)

    local mc2 = mcMgr:createViewMC("lingqu_itemeffectcollection", true, false, function (_, sender)
	        sender:gotoAndPlay(0)	       
	    end)
    mc2:setPosition(cc.p(self._getBtn:getContentSize().width/2,self._getBtn:getContentSize().height/2))
    self._getBtn:addChild(mc2,5)
end
function AcRechargePresentView:updateBtnState()
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local status = userData.award and userData.award.second_recharge or 0
	if not status then 
		status = 0
	end
	print(userData.award.second_recharge,"=============status====",status)
	-- 0 -->未充值  1 --> 未领取  2 --> 已领取
	if 0 == status then   
		self._rechargeBtn:setVisible(true)
		self._getBtn:setVisible(false)
	elseif 1 == status then
		self._rechargeBtn:setVisible(false)
		self._getBtn:setVisible(true)
	elseif 2 == status then   
		--如果已经领取，领取按钮隐藏
		self._getBtn:setVisible(false)
	end
	print("==============self._getBtn=====",self._getBtn:isVisible())
end
function AcRechargePresentView:addReward()
	self._awardData = clone(tab:Setting("YEAR_RC_REWARD").value)
	for k,v in pairs(self._awardData) do
		local icon 
		if v[1] == "tool" then
			local toolData = tab:Tool(v[2])			
			icon = IconUtils:createItemIconById({itemId = v[2],num = v[3],eventStyle = 1,effect = true})-- self._scrollItem:clone()
			icon:setPosition((k-1)*icon:getContentSize().width * icon:getScale() + 15 * (k-1), 15)
		elseif v[1] == "team" then 
			local teamD = tab:Team(v[2])		
			icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,isGray = false ,eventStyle = 1, isJin = true})
			local diguang = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888) 
			diguang:setPosition(icon:getContentSize().width/2 - 2, icon:getContentSize().height/2 - 2)
			diguang:setScale(1.2)
			local diguangParent = icon:getChildByName("teamIcon") or icon
			diguangParent:addChild(diguang,-1)
			local saoguang = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"})
			-- saoguang:setPosition(-10,-10)
			-- saoguang:setScale(1.15)
			local effectParent = icon:getChildByName("iconColor") or icon
			effectParent:addChild(saoguang,5)  
			icon:setPosition((k-1)*icon:getContentSize().width * icon:getScale() + 15 * (k-1), 15) 
		else
			dataId = IconUtils.iconIdMap[v[1]]
			icon = IconUtils:createItemIconById({itemId = dataId,num = v[3],eventStyle = 1,effect = true})-- self._scrollItem:clone()
    		icon:setPosition((k-1)*icon:getContentSize().width * icon:getScale() + 15 * (k-1), 15)
		end
		
    	self._awardPanel:addChild(icon,1)
	end
end
-- 跳转到充值界面
function AcRechargePresentView:turnToRecharge()
	local acData = self._activityModel:getAcShowDataByType(42) or {}
    local startTime = acData.start_time or 0
    local endTime = acData.end_time or 0
    local currTime = self._userModel:getCurServerTime()
	if not (startTime <= currTime and endTime > currTime) then
		self._viewMgr:showTip(lang("ZHOUNIANHUIKUI_RULE_02"))
		return
	end
	local vipLevel = self._modelMgr:getModel("VipModel"):getData().level or 0
    self._viewMgr:showView("vip.VipView", {viewType = 0,index = vipLevel})			
end

-- 发送领取协议
function AcRechargePresentView:sendGetAwardMag()
	local acData = self._activityModel:getAcShowDataByType(42) or {}
    local startTime = acData.start_time or 0
    local endTime = acData.end_time or 0
    local currTime = self._userModel:getCurServerTime()
	if not (startTime <= currTime and endTime > currTime) then
		self._viewMgr:showTip(lang("ZHOUNIANHUIKUI_RULE_02"))
		return
	end
	self._serverMgr:sendMsg("AwardServer", "getSecondRecharge", {}, true, {}, function(success)
         	if not success then return end
            -- self:showRewardDialog({})
            DialogUtils.showGiftGet({gifts = self._awardData,callback = function()
            	self:close()
            end})
    end)
end

-- 成为topView会调用, 有需要请覆盖
function AcRechargePresentView:onTop()
	print("接收自定义消息    成为topView会调用, 有需要请覆盖")
	self:updateBtnState()
end

-- 接收自定义消息
function AcRechargePresentView:reflashUI(data)
	self:updateBtnState()
end

return AcRechargePresentView