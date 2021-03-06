--
-- Author: huangguofang
-- Date: 2017-11-01 21:21:15
-- description: 幸运领主(图灵)

local ACLuckTulingDialog = class("ACLuckTulingDialog",BasePopView)
function ACLuckTulingDialog:ctor(param)
    self.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._acModel = self._modelMgr:getModel("ActivityModel")

    self._luckData = param.data or {}
    self._closeCallBack = param.closeCallBack
end
function ACLuckTulingDialog:getAsyncRes()
    return 
    {
    	{"asset/ui/acLuckStar.plist", "asset/ui/acLuckStar.png"},
    }
end

function ACLuckTulingDialog:onDestroy()
	ACLuckTulingDialog.super.onDestroy(self)
	if self._isUseImg then
		cc.Director:getInstance():getTextureCache():removeTextureForKey(self._isUseImg)
	end
end

-- 第一次被加到父节点时候调用
function ACLuckTulingDialog:onAdd()

end

function ACLuckTulingDialog:onInit()
	print("=========幸运星玩家=============")
	dump(self._luckData,"self._luckData==>",5)
	self._closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(self._closeBtn, function ()
        self:close()
        if self._closeCallBack then
        	self._closeCallBack()
        end
        UIUtils:reloadLuaFile("activity.ACLuckTulingDialog")
    end)

	self._isUseImg = "asset/bg/ac_bg_luckStar.png"	  
	self._bg = self:getUI("bg")
	local bgImg = self:getUI("bg.bgImg")
	bgImg:loadTexture(self._isUseImg)

	self._startTime = self._luckData.start_time or currTime
    self._endTime = self._luckData.end_time or currTime
	self._currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    
	--rmbNum
	self._rmbNum_img = self:getUI("bg.rmbNum_img")
	self._rmbNum_img:setVisible(false)
	self._rmbTxt = ccui.Text:create()
    self._rmbTxt:setFontSize(tonumber(self._luckData.recharge) > 99 and 50 or 75)
    self._rmbTxt:setFontName(UIUtils.ttfName)
    self._rmbTxt:setString(self._luckData.recharge or 6)
    self._rmbTxt:setColor(cc.c4b(253,255,199,255))
    self._rmbTxt:enable2Color(1, cc.c4b(244, 193, 53, 255))
    self._rmbTxt:enableOutline(cc.c4b(113, 46, 19, 255), 2)
    self._rmbTxt:setAnchorPoint(0,0.5)
    self._rmbTxt:setPosition(self._rmbNum_img:getPosition())
    self._bg:addChild(self._rmbTxt,5)

	--元
	local yuanImg = ccui.ImageView:create()
	yuanImg:loadTexture("luckStar_rmb_yuan.png", 1)
	yuanImg:setAnchorPoint(0,0.5)
	local posX,posY = self._rmbTxt:getPosition()
	yuanImg:setPosition(posX + self._rmbTxt:getContentSize().width + 5,posY)
	self._bg:addChild(yuanImg)

	-- 领奖
	self._getBtn = self:getUI("bg.getBtn")
	local mcAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true,false)
    mcAnim:setName("anniuAnim")
    mcAnim:setScaleX(1.1)
    mcAnim:setPosition(self._getBtn:getContentSize().width/2-2, self._getBtn:getContentSize().height/2)
    self._getBtn:addChild(mcAnim)
	self._getBtn:setVisible(self._luckData.status and self._luckData.status ~= 1)
	if self._luckData.status == 3 then
		mcAnim:setVisible(false)
		self._getBtn:setTitleText("已领取")
		self._getBtn:setEnabled(false)
	end
	self:registerClickEvent(self._getBtn, function ()
        -- print("=============getBtn=========")  
        self._currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if self._startTime > self._currTime or self._endTime <= self._currTime then
        	self._viewMgr:showTip("活动已结束") 
        	-- self._getBtn:setEnabled(false)
        	-- self._getBtn:setSaturation(-180)
        	return 
        end
        -- if true then return end 
        self._serverMgr:sendMsg("AwardServer", "getTuringLuckStar", {}, true, {}, function(data)
			if self._rewardData and next(self._rewardData) then 
	        	DialogUtils.showGiftGet({ gifts = self._rewardData,callback = function()	        		
	        		self._getBtn:setTitleText("已领取")
	        		self._getBtn:setEnabled(false)
	        		self:close()
					if self._closeCallBack then
			        	self._closeCallBack()
			        end
	        	end})
	        end	       
    	end)
    end)

	-- 充值
	self._chargeBtn = self:getUI("bg.chargeBtn")
	self._chargeBtn:setVisible(self._luckData.status and self._luckData.status == 1)
	self:registerClickEvent(self._chargeBtn, function ()
        -- print("=============chargeBtn=========")
        self._currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if self._startTime > self._currTime or self._endTime <= self._currTime then
        	self._viewMgr:showTip("活动已结束") 
        	-- self._chargeBtn:setEnabled(false)
        	-- self._chargeBtn:setSaturation(-180)
        	return 
        end
        local vipLevel = self._modelMgr:getModel("VipModel"):getData().level or 0
    	self._viewMgr:showView("vip.VipView", {viewType = 0,index = vipLevel})
    end)
	
	-- spine动画
	-- local animPanel = self:getUI("bg.animPanel")
	-- local animMc = mcMgr:createViewMC("jinglingbaoxiang_jinglingbaoxiang", true, false)
	-- animMc:setPosition(-50, 100)
	-- animMc:setScale(1.3)
	-- animPanel:setScaleX(-1)
    -- animPanel:addChild(animMc)

    -- self._itemArr = {}
    self:initAwardPanel()
	self:listenReflash("UserModel", self.updateStarData)
end

function ACLuckTulingDialog:initAwardPanel()

    local awardPanel = self:getUI("bg.awardPanel.awardPanel")
	awardPanel:removeAllChildren()

	self._rewardData = self._luckData.reward or {}
	 -- 更新奖励panel 
    local itemW = 100  	
	for k,v in pairs(self._rewardData) do
		local icon 
		local itemType = v[1]
		local itemId = v[2]
		
		if itemType == "hero" then
            local sysHeroData = tab:Hero(itemId)
            icon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
            icon:setScale(0.88)
            icon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if icon:getChildByName("star" .. i) then
                    icon:getChildByName("star" .. i):setPositionY(icon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end

            registerClickEvent(icon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
   
            icon:setSwallowTouches(false)

        elseif itemType == "team" then
            local sysTeam = tab:Team(itemId)
            icon = IconUtils:createSysTeamIconById({sysTeamData = sysTeam})
            icon:setScale(0.88)
            icon:setSwallowTouches(false)

        else
        	if itemType ~= "tool" then
				itemId = IconUtils.iconIdMap[itemType]
			end
			local toolD = tab:Tool(tonumber(itemId))
			icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = v[3]})
			-- icon:setScale(0.85)
			-- icon:settouch				
		end
		icon:setName("icon" .. k)
		icon:setAnchorPoint(0.5,0.5)
		icon:setPosition((k-1)*itemW+50,60)
		-- table.insert(self._itemArr, icon)
	    awardPanel:addChild(icon)		
	end
end

function ACLuckTulingDialog:updateStarData()	
	self._luckData = self._acModel:getLuckTulingData()
	-- self:initAwardPanel()
	-- self._rmbNum_img:loadTexture("luckStar_rmb_" .. (self._luckData.recharge or 6 ) .. ".png" ,1)

	self._currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
 	local starTime = self._luckData.start_time
 	-- 开着界面跨五点，活动数据不刷新
 	-- 当前幸运星活动，根据开始时间判断是否是新的幸运星活动
 	if starTime and starTime == self._startTime then
 		-- print("=============status=======",self._luckData.status)
		self._getBtn:setVisible(self._luckData.status and self._luckData.status ~= 1)
		self._chargeBtn:setVisible(self._luckData.status and self._luckData.status == 1)
	end
end

function ACLuckTulingDialog:reflashUI(data)
end
function ACLuckTulingDialog:onTop()
	print("==================ACLuckTulingDialog:onTop()===============")
end

return ACLuckTulingDialog