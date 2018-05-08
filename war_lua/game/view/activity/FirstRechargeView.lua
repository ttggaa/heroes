--
-- Author: huangguofang
-- Date: 2016-03-11 11:06:24
--
local FirstRechargeView = class("FirstRechargeView",BasePopView)
function FirstRechargeView:ctor()
    self.super.ctor(self)
    self.initAnimType = 1
end

function FirstRechargeView:getAsyncRes()
    return 
    {
        {"asset/ui/first.plist", "asset/ui/first.png"},
        "asset/uiother/team/t_fenghuang.png",
        "asset/bg/firstRecharge_panel.png",
    }
end

function FirstRechargeView:getMaskOpacity( ... )
    return 130
end


-- function FirstRechargeView:getBgName()
--     return "bg_001.jpg"
-- end

-- 第一次被加到父节点时候调用
function FirstRechargeView:onAdd()

end


function FirstRechargeView:onDestroy()
	cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/uiother/team/t_fenghuang.png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/bg/firstRecharge_panel.png")
	FirstRechargeView.super.onDestroy(self)
end

-- 初始化UI后会调用, 有需要请覆盖
function FirstRechargeView:onInit()
	--关闭当前UI
	self:registerClickEventByName("bg.closeBtn", function() 
		self:close() 
		UIUtils:reloadLuaFile("activity.FirstRechargeView")
	end)
	-- local rechargePanel = self:getUI("bg.rechargePanel")
	-- rechargePanel:setBackGroundImage("asset/bg/firstRecharge_panel.png")

	local acBg = self:getUI("bg.acBg")
	acBg:loadTexture("asset/bg/firstRecharge_panel.png")

	local fenghuangImg = self:getUI("bg.rechargePanel.fenghuang_img")
	-- fenghuangImg:setScale(0.9)
	-- fenghuangImg:setPosition(98, 295)
	fenghuangImg:loadTexture("asset/uiother/team/t_fenghuang.png")

	-- local awardTxt = self:getUI("bg.rechargePanel.awardDes_img.reward_txt1")
	-- awardTxt:enableOutline(cc.c4b(65,65,65,255), 2)
	local Label_49 = self:getUI("bg.rechargePanel.awardDes_img.Label_49")
	Label_49:enableOutline(cc.c4b(149,64,42,255), 2)
	local Label_49 = self:getUI("bg.rechargePanel.awardDes_img.Label_49")
	Label_49:enableOutline(cc.c4b(149,64,42,255), 2)
	local Label_47 = self:getUI("bg.rechargePanel.diamondDouble.Label_47")
	Label_47:enableOutline(cc.c4b(149,64,42,255), 2)
	local doubleTxt = self:getUI("bg.rechargePanel.diamondDouble.doubleTxt")
	doubleTxt:enableOutline(cc.c4b(149,64,42,255), 2)
	local value = self:getUI("bg.rechargePanel.diamondDouble.value")
	value:enableOutline(cc.c4b(139,20,0,255), 2)

	local firstDes_txt = self:getUI("bg.rechargePanel.firstDes_txt")
	firstDes_txt:enableOutline(cc.c4b(149,64,42,255), 2)
	self:getUI("bg.rechargePanel.firstDes_txt1"):enableOutline(cc.c4b(149,64,42,255), 2)
	local firstDes_value = self:getUI("bg.rechargePanel.firstDes_value")
	firstDes_value:enableOutline(cc.c4b(139,20,0,255), 2)

	local desTxt1 = self:getUI("bg.rechargePanel.des_txt1")
	local desTxt2 = self:getUI("bg.rechargePanel.des_txt2")
	local desTxt3 = self:getUI("bg.rechargePanel.desTxt3")
	local desTxt4 = self:getUI("bg.rechargePanel.desTxt4")
	desTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
	desTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
	desTxt3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
	desTxt4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
	-- desTxt1:setString("首充30元")
	-- desTxt1:setPositionX(desTxt1:getPositionX()+34)


	local desTxt = self:getUI("bg.rechargePanel.des_txt")
	desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
	-- desTxt:setString("推荐         ，领取")
	-- desTxt:setPositionX(desTxt:getPositionX()+36)
	-- desTxt2:setPositionX(desTxt:getPositionX()+desTxt:getContentSize().width + 2)
	-- desTxt3:setPositionX(desTxt2:getPositionX()+desTxt2:getContentSize().width+10)

	self._awardPanel = self:getUI("bg.rechargePanel.award_panel")

	self._getBtn = self:getUI("bg.rechargePanel.getBtn")
	self._rechargeBtn = self:getUI("bg.rechargePanel.rechargeBtn")
	self._getBtn:setTitleFontName(UIUtils.ttfName)
	self._getBtn:setTitleText("领取")
    self._getBtn:setColor(cc.c4b(255, 250, 220, 255))
    self._getBtn:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    self._getBtn:setTitleFontSize(36)
    self._rechargeBtn:setTitleFontName(UIUtils.ttfName)
    self._rechargeBtn:setColor(cc.c4b(255, 250, 220, 255))
    self._rechargeBtn:getTitleRenderer():enableOutline(cc.c4b(178, 103, 3, 255), 3) --(cc.c4b(101, 33, 0, 255), 2)
    self._rechargeBtn:setTitleFontSize(36)

    --凤凰技能演示
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
function FirstRechargeView:addEffect()
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
function FirstRechargeView:updateBtnState()	
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local payGemNum = 0
    if userData.statis then
        payGemNum = userData.statis.snum18 or 0
    else
        payGemNum = 0
    end
	if tonumber(payGemNum) <= 0 then   --判断是否是首次充值
		self._rechargeBtn:setVisible(true)
		self._getBtn:setVisible(false)		
	else
		self._rechargeBtn:setVisible(false)
		self._getBtn:setVisible(true)
		--如果已经领取，领取按钮隐藏
		if tonumber(userData.award.first_recharge) == 1 then
			self._getBtn:setVisible(false)
		end
	end
end
function FirstRechargeView:addReward()
	self._awardData = clone(tab:Setting("G_FIRST_RECHARGE").value)
	for k,v in pairs(self._awardData) do
		local icon 
		if v[1] == "tool" then
			local toolData = tab:Tool(v[2])			
			icon = IconUtils:createItemIconById({itemId = v[2],num = v[3],eventStyle = 1,effect = true})-- self._scrollItem:clone()
			icon:setScale(0.8)
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
			icon:setScale(0.69)
			icon:setPosition((k-1)*icon:getContentSize().width * icon:getScale() + 15 * (k-1), 15) 
		else
			dataId = IconUtils.iconIdMap[v[1]]
			icon = IconUtils:createItemIconById({itemId = dataId,num = v[3],eventStyle = 1,effect = true})-- self._scrollItem:clone()
	 		icon:setScale(0.8)
    		icon:setPosition((k-1)*icon:getContentSize().width * icon:getScale() + 15 * (k-1), 15)
		end
		
    	self._awardPanel:addChild(icon,1)
	end
end
-- 跳转到充值界面
function FirstRechargeView:turnToRecharge()
	local vipLevel = self._modelMgr:getModel("VipModel"):getData().level or 0
    self._viewMgr:showView("vip.VipView", {viewType = 0,index = vipLevel})			
end

-- 发送领取协议
function FirstRechargeView:sendGetAwardMag()           
	self._serverMgr:sendMsg("AwardServer", "getFirstRecharge", {}, true, {}, function(success)
         	if not success then return end
            -- self:showRewardDialog({})
            DialogUtils.showGiftGet({gifts = self._awardData,callback = function()
            	self:close()
            end})
    end)
end

-- 成为topView会调用, 有需要请覆盖
function FirstRechargeView:onTop()
	print("接收自定义消息    成为topView会调用, 有需要请覆盖")
	self:updateBtnState()
end

-- 接收自定义消息
function FirstRechargeView:reflashUI(data)
	self:updateBtnState()
end

return FirstRechargeView