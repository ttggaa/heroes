--[[
    Filename:    GlobalBuyResDialog.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-11-24 19:52:16
    Description: File description
--]]

local GlobalBuyResDialog = class("GlobalBuyResDialog",BasePopView)
function GlobalBuyResDialog:ctor()
    self.super.ctor(self)
    self._actModel = self._modelMgr:getModel("ActivityModel")
 --    local sfc = cc.SpriteFrameCache:getInstance()
	-- sfc:addSpriteFrames("asset/ui/vip.plist", "asset/ui/vip.png")
end

function GlobalBuyResDialog:getAsyncRes()
    return 
    {

    }
end
function GlobalBuyResDialog:getMaskOpacity()
	return 230
end

local count = 1
local showTip = nil
function GlobalBuyResDialog:onInit()

	local spriteSp = self:getUI("bg.layer.sprite")
	spriteSp:loadTexture("asset/bg/global_reward_img.png")
	local isClose = false
	self:registerClickEventByName("bg.layer.closeBtn", function( )
		if isClose == false then
			isClose = true
			if self._closeCallback then
				self._closeCallback(self._success, true)
			end
			self:close()
			UIUtils:reloadLuaFile("global.GlobalBuyResDialog")
		end
	end)
	self._buyBtn = self:getUI("bg.layer.buyBtn")
	self:registerClickEventByName("bg.layer.buyBtn", function( )
		-- if isClose == false then
		-- 	isClose = true
		    local canbuy = self:detectCanBuy()
			if canbuy  and self._callback then
				self._callback()
				self:lock()
				ScheduleMgr:delayCall(200, self, function( )
					self:unlock()
				end)
			else
				if self._closeCallback then
					self._closeCallback()
				end
		    	-- self:close()
		    	-- self._hadClose = true
		    	-- if not self._hadClose then
		    	local vip = self._modelMgr:getModel("VipModel"):getData().level
		    	-- 射箭跟vip没关系
		    	if self._goalType == "arrowNum" then
		    		local hadBuyNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day33 or 0
		    		local canBuyNum = tonumber(tab:Vip(vip).buyArrow)
					if hadBuyNum >= canBuyNum and vip >= 11 then
						self._viewMgr:showTip(lang("TIP_GLOBAL_MAX_VIP"))
						return 
					end
		    		if ((self._modelMgr:getModel("UserModel"):getData().arrowNum + 1)/111 or 0) >= tab.setting["G_ARROW_LIMIT"].value then
						self._viewMgr:showTip(lang("ARROW_TIP_4"))
						return
					end
				elseif self._goalType == "dice" then
					local hadBuyNum = self._modelMgr:getModel("AdventureModel"):getData().buyTime or 0
		    		local canBuyNum = #tab.activity907dice
					if hadBuyNum >= canBuyNum then
						self._viewMgr:showTip("购买次数已达上限")
						return 
					end
		    	end
		    	count = count+1
		    	if vip < #tab.vip then
		    		if self._goalType == "guildPower" then
			    		local canBuyNum = tab.vip[#tab.vip-1]["buyGuildPower"]
				        local buyGuildPowerSum = self._modelMgr:getModel("PlayerTodayModel"):getData().day23 or 0
				        if canBuyNum <= buyGuildPowerSum then
				            self._viewMgr:showTip("今日购买次数已达上限")
				            return 
				        end
				    end
			    	self._viewMgr:showDialog("global.GlobalResTipDialog",self._buyTipDesTable or {},true)
			    else
			    	self._viewMgr:showTip(lang("TIP_GLOBAL_MAX_VIP"))
			    end
				
			end
			-- if self._closeCallback then
			-- 	self._closeCallback()
			-- end
			-- self:reflashUI()
			-- local viewMgr = ViewManager:getInstance()
			-- viewMgr:showView("vip.VipView", {viewType = 0})
		-- 	self:close(true,self._callback)
		-- end
	end)

	self._title = self:getUI("bg.layer.title")
	UIUtils:setTitleFormat(self._title,1)
	-- self._title:setColor(cc.c3b(255, 252, 226))
 --    self._title:enable2Color(1, cc.c4b(255, 232, 125, 255))
 --    self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
 --    self._title:setFontName(UIUtils.ttfName_Title)
 --    self._title:setFontSize(28)

	self._des1 = self:getUI("bg.layer.des1")
	self._critLab = self:getUI("bg.layer.critLab")
	self._costIcon = self:getUI("bg.layer.costIcon")
	self._costLab = self:getUI("bg.layer.costLab")
	-- self._costLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._goalIcon = self:getUI("bg.layer.goalIcon")
	self._goalLab = self:getUI("bg.layer.goalLab")
	-- self._goalLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._canBuyNum = self:getUI("bg.layer.canBuyNum")
	self._canBuyNum:setFontSize(20)
	-- self._canBuyNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	-- self._canBuyNum:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
	self._costIconBg = self:getUI("bg.layer.costIconBg")
	self._costIconBg:setHue(150)
	self._costIconBg:setOpacity(178)
	self._goalIconBg = self:getUI("bg.layer.goalIconBg")
	-- self._goalIconBg:setHue(150)
	self._goalIconBg:setOpacity(178)
	-- self._costIconBg:setSaturation(80)


	self._canBuyValue = self:getUI("bg.layer.canBuyValue")
	self._canBuyValue:setFontSize(20)
	-- self._canBuyValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	-- self._canBuyValue:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

	self._fangzhenMc =  mcMgr:createViewMC("diguangfazhen_jinbibaoji", false, false, function (_, sender)
    -- sender:stop()
    end)
    self._fangzhenMc:setPosition(142,255)
    self._fangzhenMc:gotoAndStop(7)
    self._layer = self:getUI("bg.layer")
    self._layer:addChild(self._fangzhenMc)
    self._layer:setPositionPercent(cc.p(0.5,0.5))

    self._usePanel = self:getUI("bg.layer.usePanel")
    self._usePanel:setVisible(false)

	self:listenReflash("UserModel", function( )
		self:reflashUI()
	end)

end

-- 接收自定义消息
function GlobalBuyResDialog:reflashUI(data)
	-- dump(data)
	data = data or {}
	self._closeCallback = data.closeCallback or self._closeCallback
	-- local goalType = data.goalType or self._goalType or "gold"
	self._goalType = data.goalType or self._goalType
	local goalType = self._goalType
	-- [[ vip 为0 且 vip为0时没有次数的处理 by guojun 2016.10.27
	
	--]]
	-- 2017.4.18新需求，检查是否有可用物品
	self:detectCanUseItem(goalType)

	local genFunc = GlobalBuyResDialog["gen" .. string.upper(string.sub(goalType,1,1)) .. string.sub(goalType,2,string.len(goalType)) .. "Info"]
    local buyInfo 
    self._genFunc = genFunc
    local canBuy
    if genFunc then
        buyInfo,canBuy = genFunc(self)-- 加上self参数
    else
    	return 
    end
    local des = buyInfo.des
	local costType = buyInfo.costType
	local costNum = buyInfo.costNum
	local goalNum = buyInfo.goalNum
	local buySum = buyInfo.buySum
	local buyNum = buyInfo.buyNum
	local freeTime = buyInfo.freeTime
	-- local des = buyInfo.des
	self._critLab:setVisible(false)
	self._goalIconBg:setHue(0)
	if goalType == "gold" then
		self._title:setString("购买黄金")
		-- self._goalIcon:loadTexture("globalImageUI_gold1.png",1)
		self._buyTipDesTable = {des1 = "今日购买黄金次数已用完，提升VIP可增加购买次数"}
	elseif goalType == "physcal" then
		self._title:setString("购买体力")
		self._buyTipDesTable = {des1 = "今日购买体力次数已用完，提升VIP可增加购买次数"}
		-- self._goalIcon:loadTexture("globalImageUI4_power.png",1)
	elseif goalType == "texp" then
		self._goalIconBg:setHue(55)
		self._title:setString("兵团经验")
		self._buyTipDesTable = {des1 = "今日购买兵团经验次数已用完，提升VIP可增加购买次数"}
		-- self._goalIcon:loadTexture("globalImageUI4_power.png",1)
	elseif goalType == "guildPower" then
		self._title:setString("购买行动力")
		self._buyTipDesTable = {des1 = "今日购买行动力次数已用完，提升VIP可增加购买次数"}
		-- self._goalIcon:loadTexture("globalImageUI4_power.png",1)
	elseif goalType == "arrowNum" then
		self._title:setString("购买箭矢")
		self._buyTipDesTable = {des1 = "今日购买箭矢次数已用完，提升VIP可增加购买次数"}
	elseif goalType == "dice" then
		self._title:setString("购买骰子")
		self._buyTipDesTable = {des1 = "今日购买骰子次数已用完"}
	end
	local art = tab:Tool(IconUtils.iconIdMap[goalType]).art
	if art then
		-- self._goalIcon:setScale(0.8)
		self._goalIcon:loadTexture(art .. ".png",1)
	else
		self._goalIcon:loadTexture(IconUtils.resImgMap[goalType],1)
	end
	
	-- self._costIcon:loadTexture(,1)
	self._des1:setString(des)
	self._costLab:setString(math.ceil(costNum))
	if costNum == 0 then
		self._costLab:setString("    免费（".. freeTime .."）")
		self._costLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
		-- self._costIcon:setVisible(false)
		-- self._costLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		self._costIcon:loadTexture(IconUtils.resImgMap["gem"],1)
	else
		self._costLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		-- self._costLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		-- self._costIcon:setVisible(true)
		-- self._costIcon:loadTexture(IconUtils.resImgMap[costType],1)
		local art = tab:Tool(IconUtils.iconIdMap["gem"]).art
		if art then
			self._costIcon:loadTexture(art .. ".png",1)
		else
			self._costIcon:loadTexture(IconUtils.resImgMap["gem"],1)
		end
	end
	self._goalLab:setString(math.ceil(goalNum))
	local privilegAdd = (goalType == "texp" and self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_5) > 0 )
						or (goalType == "gold" and self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_14) > 0) 
	if privilegAdd then
		self._goalLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
	else
		self._goalLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	end
	self._canBuyNum:setString("今日剩余购买次数: ")
	self._canBuyValue:setString((buyNum - buySum) .."/".. buyNum)
	if (buyNum - buySum) <= 0 then
		self._canBuyValue:setColor(UIUtils.colorTable.ccUIBaseColor6)
		-- self._canBuyValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	else
		-- self._canBuyValue:disableEffect()
		self._canBuyValue:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	end
	-- [[判断vip没开的时候 提示vip 几 可购买 rd#8436
	local vip = self._modelMgr:getModel("VipModel"):getData().level or 0
	local tabKey -- vip 表 对应的key值
	if goalType == "arrowNum" then
		tabKey = "buyArrow"
	else
		tabKey = "buy".. string.upper(string.sub(goalType,1,1)) .. string.sub(goalType,2,string.len(goalType))
	end
	local tabValue = tab.vip[vip][tabKey]
	local limitVipLvl
	print(tabValue,"tabValue",vip,tabKey)
	if tabValue == 0 then
		-- for i=0,table.nums(tab.vip) do
		-- 	local tabRow = tab.vip[i]
		-- 	if tabRow[tabValue] ~= 0 then
		-- end
		for i,v in ipairs(tab.vip) do
			print(i,v[tabKey])
			if v[tabKey] ~= 0 then
				limitVipLvl = v.id 
				break
			end
		end
	end
	print("limitViplvl",limitVipLvl)
	if limitVipLvl then
		self._canBuyNum:setString("VIP" .. limitVipLvl)
		self._canBuyValue:setString("可购买")
		self._canBuyValue:setColor(UIUtils.colorTable.ccUIBaseColor1)
		self._buyTipDesTable = {des1 = "提升VIP可增加购买次数"}
	-- else
	-- 	self._canBuyValue:setColor(UIUtils.colorTable.ccUIBaseColor6)
	end
	--]]
	local posX = (507 - (self._canBuyNum:getContentSize().width + self._canBuyValue:getContentSize().width))/2
	self._canBuyNum:setPositionX(posX + self._canBuyNum:getContentSize().width)
	self._canBuyValue:setPositionX(posX + self._canBuyNum:getContentSize().width)
	
	self._callback = buyInfo.callback
end

function GlobalBuyResDialog:genGoldInfo()
    -- if not self.addBase1 then
    -- [[ 活动加成
    local actCostLess = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_5)
    local actAdd = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_7)
    --]]
    local goldAdd = tab:Setting("G_GOLD_BUY_ADD").value
    local addBase1 = goldAdd[1]
    local addBase2 = goldAdd[2]
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local freeNum = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_13)
    local buyGoldNum = tonumber(tab:Vip(vip).buyGold)+freeNum--tab:Setting("G_INITIAL_BUY_GOLD_NUM").value
    -- end
    local buyGoldSum = self._modelMgr:getModel("PlayerTodayModel"):getData().day3 or 0
    local hadFree = self._modelMgr:getModel("PlayerTodayModel"):getData().day13 or 0
    local buySum = buyGoldSum+1
    buyGoldSum = buyGoldSum+hadFree
    local goldCostGem = (tab:ReflashCost(math.min(math.max(buySum,1),#tab.reflashCost)).buyGold or 0)*(1+actCostLess)
    if hadFree < freeNum then
    	goldCostGem = 0
    end


    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local privilegAdd = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_14)
    local canBuyNum = (lvl*addBase1+addBase2)*(1+privilegAdd*0.01+actAdd)--百分率
    -- local desString = "花费".. goldCostGem .."钻石购买".. canBuyNum .. "金子,是否继续？今日已购买".. buyGoldSum .."/".. buyGoldNum .."次(提高vip可增加购买金子次数）"
    --costType --costNum --goalNum --buySum --buyNum
    local buyInfo = {
    	des = lang("BUY_GOLD_WORDSTIPS") or "花费少量钻石可获得大量黄金",
	    costType = "gem",
		costNum = goldCostGem,
		goalNum = canBuyNum,
		buySum = buyGoldSum,
		buyNum = buyGoldNum,
		freeTime = freeNum - hadFree,
		callback=function( )
            self._serverMgr:sendMsg("UserServer", "buyGold", {}, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	audioMgr:playSound("GoldenFinger")
            	self._success = true 
				local critScore = result.crit or 0 
				-- self._viewMgr:showTip("购买黄金成功！")

				local bgW,bgH = self._goalLab:getContentSize().width,self._goalLab:getContentSize().height
			    local mc1 = mcMgr:createViewMC("goumaiguangxiao_jinbibaoji", true, false, function (_, sender)
			        sender:removeFromParent()
	                -- self._viewMgr:showTip("购买金币成功！")
	                self:detectCanBuy()
			    end)
			    self._fangzhenMc:gotoAndPlay(0)
			    self._fangzhenMc:addEndCallback(function( )
			    	self._fangzhenMc:gotoAndPlay(7)
			    end)
			    if mc1 then
			    	mc1:setPosition(cc.p(145,self._layer:getContentSize().height/2+60))
				    mc1:setScale(1)
				    self._layer:addChild(mc1,99)
					
					local effid = 2
					if critScore < 5 then
						effid = 2
					elseif critScore < 10 then
						effid = 5
					else
						effid = 10
					end
					ScheduleMgr:delayCall(500, self, function()
						if self._goalLab == nil then return end
						local mc2 = mcMgr:createViewMC(10 .. "beibaoji_jinbibaoji", true, true)
						mc2:setPosition(cc.p(self._goalLab:getContentSize().width/2,self._goalLab:getContentSize().height/2+130))
						self._goalLab:addChild(mc2)
						if critScore > 1 then 
						    local critLab = ccui.Text:create()
						    critLab:setFontName(UIUtils.ttfName)
						    critLab:setFontSize(42)
						    critLab:setColor(cc.c4b(255, 255, 204, 255))
						    critLab:enable2Color(1, cc.c4b(255, 153, 0, 255))
						    critLab:enableOutline(cc.c4b(0,0,0,255),2)
						    -- critLab:setString("+" .. math.abs(result.d.texp-preTexp))
						    critLab:setString(critScore .. "倍暴击")
						    critLab:setScale(0.5)
						    -- critLab:setOpacity(0)
						   	self._goalLab:getParent():addChild(critLab,2)
					   		critLab:setPosition(cc.p(self._goalLab:getPositionX(),self._goalLab:getPositionY()+160))
					    -- critLab:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,20)),cc.ScaleTo:create(0.5,1)),cc.Spawn:create(cc.MoveBy:create(0.6,cc.p(0,30)),cc.FadeTo:create(0.6,200)),cc.CallFunc:create(function ( )
						    -- 	if not tolua.isnull(critLab) then
						    -- 		critLab:removeFromParent()
						    -- 	end
						    -- end) ) ) 
							critLab:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.5),cc.ScaleTo:create(0.05,1),cc.DelayTime:create(0.15), cc.FadeOut:create(0.2),cc.CallFunc:create(function ( )
						    	if not tolua.isnull(critLab) then
						    		critLab:removeFromParent()
						    	end
						    end) ) )
						end
					end)
				end
            end)
        end
	}
	local cost = self._modelMgr:getModel("UserModel"):getData()[buyInfo.costType]
	if tonumber(buyInfo.costNum) and buyInfo.costNum > cost then
		buyInfo.callback = function( )
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
				self._buyBtn:setBright(true)
				self._buyBtn:setEnabled(true)
			end})
		end
	end
    if buyGoldSum >= buyGoldNum then
        return buyInfo,false
    end
    return buyInfo,true
end

function GlobalBuyResDialog:genGemInfo()
    -- body
end

function GlobalBuyResDialog:genPhyscalInfo()
    -- if not self.energyAdd then
    -- [[ 活动加成
    local actCostLess = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_4)
    --]]
    local energyAdd = tab:Setting("G_PHYSCAL_BUY_ADD").value or 0
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local buyEnergyNum = tonumber(tab:Vip(vip).buyPhyscal) -- tab:Setting("G_INITIAL_BUY_PHYSCAL_NUM").value
    -- end
    local buyEnergySum = self._modelMgr:getModel("PlayerTodayModel"):getData().day2 or 0
    local buySum = math.min(buyEnergySum+1,#tab.reflashCost)
    local reflashCostT = tab["reflashCost"]
    local energyCostGem = (tab:ReflashCost(buySum).buyPhysical or 0)*(1+actCostLess)
    local buyInfo = {
    	des = "花费少量钻石可获得大量体力",
	    costType = "gem",
		costNum = energyCostGem,
		goalNum = energyAdd,
		buySum = buyEnergySum,
		buyNum = buyEnergyNum,
		callback=function( )
			-- [[体力超3000不让买体力 by guojun 2016.8.23 
	        local physcal = self._modelMgr:getModel("UserModel"):getData().physcal 
	        if physcal >= 3000 then
	            self._viewMgr:showTip("体力接近上限，请去扫荡副本")
	            return 
	        end
		    --]]
            self._serverMgr:sendMsg("UserServer", "buyPhyscal", {}, true, {}, function(result) 
            	if self._successCallback then
            		self._successCallback()
            	end
            	self._success = true
                self._viewMgr:showTip("购买体力成功！")
                local bgW,bgH = self._goalLab:getContentSize().width,self._goalLab:getContentSize().height
			    local mc1 = mcMgr:createViewMC("goumaiguangxiao_jinbibaoji", true, false, function (_, sender)
			        sender:removeFromParent()
	                -- self._viewMgr:showTip("购买金币成功！")
	                self:detectCanBuy()
			    end)
			    self._fangzhenMc:gotoAndPlay(0)
			    self._fangzhenMc:addEndCallback(function( )
			    	self._fangzhenMc:gotoAndPlay(7)
			    end)
			    if mc1 then
			    	mc1:setPosition(cc.p(145,self._layer:getContentSize().height/2+60))
				    mc1:setScale(1)
				    self._layer:addChild(mc1,99)
				end
            end)
        end
	}
	local cost = self._modelMgr:getModel("UserModel"):getData()[buyInfo.costType]
	if buyInfo.costNum > cost then
		buyInfo.callback = function( )
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
				self._buyBtn:setBright(true)
				self._buyBtn:setEnabled(true)
			end})
		end
	end
    if buyEnergySum >= buyEnergyNum then
        return buyInfo,false
    end
    return buyInfo,true
end

-- 生成购买兵团经验相关信息
function GlobalBuyResDialog:genTexpInfo()
    -- if not self.energyAdd then
    -- [[ 活动加成
    local actCostLess = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_6)
    local actAdd = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_8)
    --]]
    local texpAdd = tab:Setting("G_TEXP_BUY_ADD").value
    local addBase1 = texpAdd[1]
    local addBase2 = texpAdd[2]
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local freeNum = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_6) or 0
    local buytexpNum = tonumber(tab:Vip(vip).buyTexp)+freeNum -- tab:Setting("G_INITIAL_BUY_PHYSCAL_NUM").value
    local buytexpSum = self._modelMgr:getModel("PlayerTodayModel"):getData().day9 or 0
	local privilegAdd = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_5) or 0
	local canBuyNum = (lvl*addBase1+addBase2)*(1+privilegAdd*0.01+actAdd)
    -- end
    local buySum = math.min(buytexpSum+1,#tab.reflashCost)
    local reflashCostT = tab["reflashCost"]
    local texpCostGem = (tab:ReflashCost(math.max(buySum,1)).buyTexp or 0)*(1+actCostLess)
    local hadFree = self._modelMgr:getModel("PlayerTodayModel"):getData().day14 or 0
	if hadFree < freeNum then
    	texpCostGem = 0
    end
    buytexpSum = buytexpSum+hadFree
    local buyInfo = {
    	des = lang("BUY_TEXP_WORDSTIPS") or "花费少量钻石可获得大量兵团经验",
	    costType = "gem",
		costNum = texpCostGem,
		goalNum = canBuyNum,
		buySum = buytexpSum,
		buyNum = buytexpNum,
		freeTime = freeNum - hadFree,
		callback=function( )
        	local preTexp = self._modelMgr:getModel("UserModel"):getData().texp
            self._serverMgr:sendMsg("UserServer", "buyTexp", {}, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	self._success = true
                -- self._viewMgr:showTip("购买兵团经验成功！")
            	local critScore = result.crit or 0 
            	local bgW,bgH = self._goalLab:getContentSize().width,self._goalLab:getContentSize().height
			    local mc1 = mcMgr:createViewMC("goumaiguangxiao_jinbibaoji", true, false, function (_, sender)
			        sender:removeFromParent()
	                -- self._viewMgr:showTip("购买金币成功！")
	                self:detectCanBuy()
			    end)
			    self._fangzhenMc:gotoAndPlay(0)
			    self._fangzhenMc:addEndCallback(function( )
			    	self._fangzhenMc:gotoAndPlay(7)
			    end)
			    if mc1 then
			    	mc1:setPosition(cc.p(145,self._layer:getContentSize().height/2+60))
				    mc1:setScale(1)
				    self._layer:addChild(mc1,99)
					ScheduleMgr:delayCall(500, self, function()
						if self._goalLab == nil then return end
						local effid = 2
						if critScore < 5 then
							effid = 2
						elseif critScore < 10 then
							effid = 5
						else
							effid = 10
						end
						local mc2 = mcMgr:createViewMC(10 .. "beibaojijingyan_jinbibaoji", true, true)
						mc2:setPosition(cc.p(self._goalLab:getContentSize().width/2,self._goalLab:getContentSize().height/2+120))
						self._goalLab:addChild(mc2)

						if critScore > 1 then 
						    local critLab = ccui.Text:create()
						    critLab:setFontName(UIUtils.ttfName)
						    critLab:setFontSize(42)
						    critLab:setColor(cc.c4b(255, 255, 204, 255))
						    critLab:enable2Color(1, cc.c4b(255, 153, 0, 255))
						    critLab:enableOutline(cc.c4b(0,0,0,255),2)
						    -- critLab:setString("+" .. math.abs(result.d.texp-preTexp))
						    critLab:setString(critScore .. "倍暴击")
						    critLab:setScale(0.5)
						    -- critLab:setOpacity(0)
						   	self._goalLab:getParent():addChild(critLab,2)
						   	critLab:setPosition(cc.p(self._goalLab:getPositionX(),self._goalLab:getPositionY()+160))
						    -- critLab:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,20)),cc.ScaleTo:create(0.5,1)),cc.Spawn:create(cc.MoveBy:create(0.6,cc.p(0,30)),cc.FadeTo:create(0.6,200)),cc.CallFunc:create(function ( )
						    -- 	if not tolua.isnull(critLab) then
						    -- 		critLab:removeFromParent()
						    -- 	end
						    -- end) ) ) 
							critLab:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.5),cc.ScaleTo:create(0.05,1),cc.DelayTime:create(0.15),cc.FadeOut:create(0.2),cc.CallFunc:create(function ( )
						    	if not tolua.isnull(critLab) then
						    		critLab:removeFromParent()
						    	end
						    end) ) )
						end
					end)
				end
            end)
        end
	}
	local cost = self._modelMgr:getModel("UserModel"):getData()[buyInfo.costType]
	if buyInfo.costNum > cost then
		buyInfo.callback = function( )
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
				self._buyBtn:setBright(true)
				self._buyBtn:setEnabled(true)
			end})
		end
	end
    if buytexpSum >= buytexpNum then
        return buyInfo,false
    end
    return buyInfo,true
end

-- 生成购买行动力相关信息
function GlobalBuyResDialog:genGuildPowerInfo()
    -- if not self.energyAdd then
    local texpAdd = tab:Setting("G_GUILDPOWER_BUY_ADD").value
    -- local addBase1 = texpAdd[1]
    -- local addBase2 = texpAdd[2]
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local freeNum = 0--self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_6) or 0
    local buyGuildPowerNum = tonumber(tab:Vip(vip).buyGuildPower)+freeNum -- tab:Setting("G_INITIAL_BUY_PHYSCAL_NUM").value
    local buyGuildPowerSum = self._modelMgr:getModel("PlayerTodayModel"):getData().day23 or 0
	local privilegAdd = 0--self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_5) or 0
	local canBuyNum = texpAdd --(lvl*addBase1+addBase2)*(1+privilegAdd*0.01)
    -- end
    local buySum = math.min(buyGuildPowerSum+1,#tab.reflashCost)
    local reflashCostT = tab["reflashCost"]
    local GuildPowerCostGem = tab:ReflashCost(math.max(buySum,1)).buyGuildPower or 0
    local hadFree = 0
	if hadFree < freeNum then
    	GuildPowerCostGem = 0
    end
    buyGuildPowerSum = buyGuildPowerSum+hadFree
    local buyInfo = {
    	des = lang("BUY_GUILDPOWER_WORDSTIPS") or "花费少量钻石可获得大量行动力",
	    costType = "gem",
		costNum = GuildPowerCostGem,
		goalNum = canBuyNum,
		buySum = buyGuildPowerSum,
		buyNum = buyGuildPowerNum,
		freeTime = freeNum - hadFree,
		callback=function( )
        	local preGuildPower = self._modelMgr:getModel("UserModel"):getData().GuildPower
            self._serverMgr:sendMsg("UserServer", "buyGuildPower", {}, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	self._success = true
                self._viewMgr:showTip("购买行动力成功！")
            	local critScore = result.crit or 0 
	            self:detectCanBuy()
	            local bgW,bgH = self._goalLab:getContentSize().width,self._goalLab:getContentSize().height
			    local mc1 = mcMgr:createViewMC("goumaiguangxiao_jinbibaoji", true, false, function (_, sender)
			        sender:removeFromParent()
	                -- self._viewMgr:showTip("购买金币成功！")
	                self:detectCanBuy()
			    end)
			    self._fangzhenMc:gotoAndPlay(0)
			    self._fangzhenMc:addEndCallback(function( )
			    	self._fangzhenMc:gotoAndPlay(7)
			    end)
			    if mc1 then
			    	mc1:setPosition(cc.p(145,self._layer:getContentSize().height/2+60))
				    mc1:setScale(1)
				    self._layer:addChild(mc1,99)
				end
            end)
        end
	}
	local cost = self._modelMgr:getModel("UserModel"):getData()[buyInfo.costType]
	if buyInfo.costNum > cost then
		buyInfo.callback = function( )
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
				self._buyBtn:setBright(true)
				self._buyBtn:setEnabled(true)
			end})
		end
	end
	local vipMaxBuyNum = tab.vip[#tab.vip-1]["buyGuildPower"]
    if buyGuildPowerSum >= buyGuildPowerNum or vipMaxBuyNum <= buyGuildPowerSum then
        return buyInfo,false
    end
    return buyInfo,true
end

-- 生成购买行动力相关信息
function GlobalBuyResDialog:genArrowNumInfo()
    -- if not self.energyAdd then
    local arrowAdd = tab:Setting("G_ARROW_BUY_NUM").value
    -- local addBase1 = texpAdd[1]
    -- local addBase2 = texpAdd[2]
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local freeNum = 0--self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_6) or 0
    local buyArrowNum = tonumber(tab:Vip(vip).buyArrow)+freeNum -- tab:Setting("G_INITIAL_BUY_PHYSCAL_NUM").value
    local buyArrowSum = self._modelMgr:getModel("PlayerTodayModel"):getData().day33 or 0
	local privilegAdd = 0--self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_5) or 0
	local canBuyNum = arrowAdd --(lvl*addBase1+addBase2)*(1+privilegAdd*0.01)
    -- end
    local buySum = math.min(buyArrowSum+1,#tab.reflashCost)
    local reflashCostT = tab["reflashCost"]
    local arrowCostGem = tab:ReflashCost(math.max(buySum,1)).buyArrow or 0
    local hadFree = 0
	if hadFree < freeNum then
    	arrowCostGem = 0
    end
    buyArrowSum = buyArrowSum+hadFree
    local buyInfo = {
    	des = lang("BUY_GUILDPOWER_WORDSTIPS") or "花费少量钻石可获得大量行动力",
	    costType = "gem",
		costNum = arrowCostGem,
		goalNum = canBuyNum,
		buySum = buyArrowSum,
		buyNum = buyArrowNum,
		freeTime = freeNum - hadFree,
		callback=function( )
			if ((self._modelMgr:getModel("UserModel"):getData().arrowNum + 1)/111 or 0) >= tab.setting["G_ARROW_LIMIT"].value then
					self._viewMgr:showTip(lang("ARROW_TIP_4"))
				return
			end
        	local preArrow = self._modelMgr:getModel("UserModel"):getData().arrow
            self._serverMgr:sendMsg("UserServer", "buyArrow", {}, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	self._success = true
                self._viewMgr:showTip("购买箭矢成功！")
            	local critScore = result.crit or 0 
            	local bgW,bgH = self._goalLab:getContentSize().width,self._goalLab:getContentSize().height
			    self._fangzhenMc:gotoAndPlay(0)
			    self._fangzhenMc:addEndCallback(function( )
			    	self._fangzhenMc:gotoAndPlay(7)
			    end)
			    local mc1 = mcMgr:createViewMC("goumaiguangxiao_jinbibaoji", true, false, function (_, sender)
			        sender:removeFromParent()
	                -- self._viewMgr:showTip("购买金币成功！")
	                -- self:detectCanBuy()
			    end)
			    mc1:setPosition(cc.p(145,self._layer:getContentSize().height/2+60))
			    mc1:setScale(1)
			    self._layer:addChild(mc1,99)
			    -- local mc1 = mcMgr:createViewMC("goumaijingyanguangxiao_buyGuildPower", true, false, function (_, sender)
			    --     sender:removeFromParent()
	                -- self._viewMgr:showTip("购买金币成功！")
	                self:detectCanBuy()
			    -- end)
            end)
        end
	}
	local cost = self._modelMgr:getModel("UserModel"):getData()[buyInfo.costType]
	if buyInfo.costNum > cost then
		buyInfo.callback = function( )
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
				self._buyBtn:setBright(true)
				self._buyBtn:setEnabled(true)
			end})
		end
	end
    if buyArrowSum >= buyArrowNum then
        return buyInfo,false
    end
    return buyInfo,true
end

-- 生成购买行动力相关信息
function GlobalBuyResDialog:genDiceInfo()
    -- if not self.energyAdd then
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local freeNum = 0--self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_6) or 0
    local buyDiceSum = self._modelMgr:getModel("AdventureModel"):getData().buyTime or 0
	local privilegAdd = 0--self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_5) or 0
	local canBuyNum = 1 --(lvl*addBase1+addBase2)*(1+privilegAdd*0.01)
    -- end
    local buySum = math.min(buyDiceSum+1,#tab.activity907dice)
    local reflashCostT = tab["reflashCost"]
    local DiceCostGem = tab:Activity907dice(math.max(buySum,1)).cost or 0
    local buyDiceNum = #tab.activity907dice -- tab:Setting("G_INITIAL_BUY_PHYSCAL_NUM").value
    buyDiceSum = buyDiceSum
    local buyInfo = {
    	des = lang("BUY_GUILDPOWER_WORDSTIPS") or "花费少量钻石可获得大量行动力",
	    costType = "gem",
		costNum = DiceCostGem,
		goalNum = canBuyNum,
		buySum = buyDiceSum,
		buyNum = buyDiceNum,
		freeTime = freeNum,
		callback=function( )
        	local preDice = self._modelMgr:getModel("UserModel"):getData().Dice
            self._serverMgr:sendMsg("AdventureServer", "buyDice", {}, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	self._success = true
                self._viewMgr:showTip("购买骰子成功！")
            	local critScore = result.crit or 0 
            	local bgW,bgH = self._goalLab:getContentSize().width,self._goalLab:getContentSize().height
			    self._fangzhenMc:gotoAndPlay(0)
			    self._fangzhenMc:addEndCallback(function( )
			    	self._fangzhenMc:gotoAndPlay(7)
			    end)
			    local mc1 = mcMgr:createViewMC("goumaiguangxiao_jinbibaoji", true, false, function (_, sender)
			        sender:removeFromParent()
	                -- self._viewMgr:showTip("购买金币成功！")
	                -- self:detectCanBuy()
			    end)
			    mc1:setPosition(cc.p(145,self._layer:getContentSize().height/2+60))
			    mc1:setScale(1)
			    self._layer:addChild(mc1,99)
			    -- local mc1 = mcMgr:createViewMC("goumaijingyanguangxiao_buyGuildPower", true, false, function (_, sender)
			    --     sender:removeFromParent()
	                -- self._viewMgr:showTip("购买金币成功！")
	                self:detectCanBuy()
			    -- end)
				-- 骰子特殊刷新
				self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},titleTxt = "神秘宝藏",title = "globalTitleUI_yijitanxian.png"}, nil, ADOPT_IPHONEX and 1136 or nil)
				self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},title = "globalTitleUI_yijitanxian.png",titleTxt = "神秘宝藏",delayReflash = true}, nil, ADOPT_IPHONEX and 1136 or nil)
            end)
        end
	}
	local cost = self._modelMgr:getModel("UserModel"):getData()[buyInfo.costType]
	if buyInfo.costNum > cost then
		buyInfo.callback = function( )
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
				self._buyBtn:setBright(true)
				self._buyBtn:setEnabled(true)
			end})
		end
	end
    if buyDiceSum >= buyDiceNum then
        return buyInfo,false
    end
    return buyInfo,true
end

function GlobalBuyResDialog:detectCanBuy( )
	local buyInfo
	local canBuy 
    if self._genFunc then
        buyInfo,canBuy = self._genFunc(self)-- 加上self参数
        self._callback = buyInfo.callback
    else
    	return false
    end
    if not canBuy then
    	return false
    end
    return true
end

-- function GlobalBuyResDialog:onDestroy( )
-- 	local sfc = cc.SpriteFrameCache:getInstance()
-- 	sfc:addSpriteFrames(res[1], res[2])
-- end

-- 新功能模块
-- 判断有没有可使用的道具
function GlobalBuyResDialog:detectCanUseItem( goalType )
	print("goalType.........",goalType)
	local bottleIds
	if goalType == "physcal" then
		bottleIds = {30213,30212,30211}
	elseif goalType == "texp" then
		bottleIds = {30203,30202,30201}
	end
	self:reflashUsePanel(bottleIds)
end


function GlobalBuyResDialog:reflashUsePanel(bottleIds)
	if not bottleIds then return end
	local itemId 
	local useData 
	for i,bottleId in ipairs(bottleIds) do
		local itemInfo,num = self._modelMgr:getModel("ItemModel"):getItemsById(bottleId) 
		if num > 0 then
			useData = clone(itemInfo)
			useData.goodsId = bottleId
			useData.num = num
			itemId = bottleId
			break
		end
	end
	-- itemId = 30213
	if not itemId then
		self._usePanel:setVisible(false) 
		return 
	end
	self._usePanel:setVisible(true)
	local useBtn = self._usePanel:getChildByName("useBtn")
	local itemName = self._usePanel:getChildByName("itemName")
	local icon = self._usePanel:getChildByName("icon")
	if not icon then
		icon = IconUtils:createItemIconById({itemId = itemId,num = useData.num})
		icon:setScale(0.6)
		icon:setPosition(65,110)
		icon:setName("icon")
		self._usePanel:addChild(icon)
	else
		IconUtils:updateItemIconByView(icon,{itemId = itemId,num = useData.num})
	end
	local toolD = tab.tool[itemId]
	if toolD then
		itemName:setString(lang(toolD.name))
	end

	self:registerClickEvent(useBtn,function() 
		self:useOneItem(useData)
	end)
end

-- 使用物品协议
function GlobalBuyResDialog:useOneItem(data)
    if data["num"] <= 0 then 
        return 
    end
    local giftData = tab.toolGift[data.goodsId] or tab.equipmentBox[data.goodsId]
    if giftData then
        local needLvl = giftData.openLv or giftData.openLevel
        if needLvl then
            local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl 
            if needLvl > userLevel then
                self._viewMgr:showTip("等级" .. needLvl .."可使用")
                return 
            end
        end
    end
    -- [[体力超3000不让用体力药水 by guojun 2016.8.23 
    local physicalBottles = {
        [30211] = 30211,
        [30212] = 30212,
        [30213] = 30213,
    }
    if physicalBottles[data.goodsId] then
        local physcal = self._modelMgr:getModel("UserModel"):getData().physcal 
        if physcal >= 3000 then
            self._viewMgr:showTip(lang("TIPS_BEIBAO_04"))
            return 
        end
    end
    --]]
    local param = {goodsId = data.goodsId, goodsNum = 1,extraParams=nil}
    
    -- [[ 新增逻辑 N选一 
    local isNselectOne = giftData and giftData["type"] == 4
    if isNselectOne then
        self._viewMgr:showDialog("global.GlobalSelectAwardDialog", {gift = giftData.giftContain or {},callback = function(selectedIndex)
            param.extraParams = json.encode({cId = selectedIndex})
            self:sendUseItemMsg(param)
        end})
    else
        self:sendUseItemMsg(param)
    end
    --]]
end

-- 抽离出 发送使用物品接口
function GlobalBuyResDialog:sendUseItemMsg( param )
    local preHave = {}
    for k,v in pairs(self._modelMgr:getModel("UserModel"):getData()) do
        if type(v) == "number" then
            preHave[k] = v 
        end
    end
    self._serverMgr:sendMsg("ItemServer", "useItem", param or {}, true, {}, function(result) 
        -- self:upgradeBag(result)
        -- dump(result)
        if result.reward then
            local giftData = tab:ToolGift(param.goodsId) or {}
            local gifts = giftData.giftContain            
            -- 头像框 
            if giftData.type == 5 then
                DialogUtils.showAvatarFrameGet( {gifts = gifts})   
            else
                DialogUtils.showGiftGet( {gifts = result.reward})              
            end
            -- self._viewMgr:showTip("使用礼包成功")
        elseif tab.toolGift[param.goodsId] then
            local giftData = tab:ToolGift(param.goodsId) or {}
            local gifts = giftData.giftContain
            -- 头像框 
            if giftData.type == 5 then
                DialogUtils.showAvatarFrameGet( {gifts = gifts})   
            else
                DialogUtils.showGiftGet( {gifts = gifts})                
            end
            -- self._viewMgr:showTip("使用礼包成功")
        else
            -- self._viewMgr:showTip("使用成功")
            local items = {}
            for k,v in pairs(result.d) do
                if IconUtils.iconIdMap[k] then
                    local item = {"tool",IconUtils.iconIdMap[k]}
                    table.insert(item,v-preHave[k])
                    table.insert(items,item)
                elseif result.d["payGem"] or result.d["freeGem"] then
                    result.d["payGem"] = nil
                    result.d["freeGem"] = nil
                    local item = {"gem",0}
                    table.insert(item,self._modelMgr:getModel("UserModel"):getData().gem-preHave["gem"])
                    table.insert(items,item)
                end
            end
            if #items > 0 then
                DialogUtils.showGiftGet( {gifts = items})
            end
        end
    end)
end

return GlobalBuyResDialog