--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-03-28 11:52:16
--
local GlobalTradeDialog = class("GlobalTradeDialog",BasePopView)
function GlobalTradeDialog:ctor(param)
    self.super.ctor(self)
    self._actModel = self._modelMgr:getModel("ActivityModel")
    self._tabTypes = {"gold","texp","magicNum","treasureNum"}
    self._goalMapId = {magicNum=3004,treasureNum= 41001}
    self._initTabIdx = param and param.tabIdx or 1
    self._buyAnyNum = 5
end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalTradeDialog:onInit()
	self:registerClickEventByName("bg.closeBtn",function() 
		if self._closeCallback then
			self._closeCallback()
		end
		self:close()
		UIUtils:reloadLuaFile("global.GlobalTradeDialog")
	end)

	self._title = self:getUI("bg.title")
	UIUtils:setTitleFormat(self._title,1)
	self._tabTitle = self:getUI("bg.tabTitle")
	self._bg = self:getUI("bg")
	-- 初始化 UI对象
	self._goalLab = self:getUI("bg.goalLab")
	self._goalImg = self:getUI("bg.goalImg")
	self._costLab = self:getUI("bg.costLab")
	self._costImg = self:getUI("bg.costImg")
    self._costFiveLab = self:getUI("bg.costLabFive")
    self._costFiveImg = self:getUI("bg.costImgFive")
    

	self._canBuyDes = self:getUI("bg.canBuyDes")
	self._canBuyNum	= self:getUI("bg.canBuyNum")

	self._goalIcon = self:getUI("bg.goalIcon")

	self._buyBtn = self:getUI("bg.buyBtn")
	self:registerClickEventByName("bg.buyBtn", function( )
	    local canbuy = self:detectCanBuy()
		if canbuy  and self._callback then
			self._callback(1)
			self:lock()
			ScheduleMgr:delayCall(50, self, function( )
				self:unlock()
			end)
		else
			
	    	local vip = self._modelMgr:getModel("VipModel"):getData().level
	    	if vip < #tab.vip then
		    	self._viewMgr:showDialog("global.GlobalResTipDialog",self._buyTipDesTable or {},true)
		    else
		    	self._viewMgr:showTip(lang("TIP_GLOBAL_MAX_VIP"))
		    end
		end
	end)

	self._buyFiveBtn = self:getUI("bg.buyBtnFive")
	self:registerClickEventByName("bg.buyBtnFive", function( )

	    local canbuy = self:detectFiveCanBuy()
		if canbuy  and self._callback then
			self._callback(self._canMoreNum)
			self:lock()
			ScheduleMgr:delayCall(50, self, function( )
				self:unlock()
			end)
		else
			
	    	local vip = self._modelMgr:getModel("VipModel"):getData().level
	    	if vip < #tab.vip then
		    	self._viewMgr:showDialog("global.GlobalResTipDialog",self._buyTipDesTable or {},true)
		    else
		    	self._viewMgr:showTip(lang("TIP_GLOBAL_MAX_VIP"))
		    end
		end
	end)


	self._tabs = {}
	local tabConfig = {
		{itemId=IconUtils.iconIdMap["gold"],scale=0.5,goalType = "gold"},
		{itemId=IconUtils.iconIdMap["texp"],goalType = "texp"},
		{itemId=3004,goalType = "magicNum"},
		{itemId=41001,goalType = "treasureNum"},
	}
	self._tabConfig = tabConfig
	for i=1,4 do
		local tabBtn = self:getUI("bg.tab_" .. i)
		table.insert(self._tabs,tabBtn)
		-- tabBtn:setScaleAnimMin(1.05)
		self:registerClickEvent(tabBtn,function() 
			self:touchTab(i)
		end)
		local toolD = tab.tool[tabConfig[i].itemId] 
		if toolD then
			local text = tabBtn:getChildByName("text")
			text:setString(lang(toolD.name))
			text:disableEffect()
			local icon = tabBtn:getChildByName("icon")
			icon:loadTexture("mainView_tradeicon_" .. tabConfig[i].goalType .. ".png",1)
			text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		end
	end

	self:touchTab(self._initTabIdx,self._initTabIdx ~= 1)

	self:listenReflash("UserModel", function( )
		self:reflashUI()
	end)
end

-- 第一次进入调用, 有需要请覆盖
function GlobalTradeDialog:onShow()

end

-- 接收自定义消息
function GlobalTradeDialog:reflashUI(data)
	data = data or {}
	self._closeCallback = data.closeCallback or self._closeCallback
	-- local goalType = data.goalType or self._goalType or "gold"
	self._goalType = data.goalType or self._goalType
	local goalType = self._goalType
	local genFunc = self["gen" .. string.upper(string.sub(goalType,1,1)) .. string.sub(goalType,2,string.len(goalType)) .. "Info"]
    self._genFunc = genFunc
	self:detectDot()
    local buyInfo 
	local canBuy
    if genFunc then
        buyInfo,canBuy = genFunc(self)-- 加上self参数
    else
    	return 
    end

    local des = buyInfo.des
	local costType = buyInfo.costType
	local costNum = buyInfo.costNum
	local costFiveNum = buyInfo.costFiveNum
	local goalNum = buyInfo.goalNum
	local buySum = buyInfo.buySum
	local buyNum = buyInfo.buyNum
	local freeTime = buyInfo.freeTime
	local acAddNum = buyInfo.acAddNum or 0
	local scaleMap = {1,1}
	local goalImgArt = nil 
	if goalType == "gold" then
		scaleMap = {0.45,0.45}
		self._tabTitle:setString("购买".. lang(tab.tool[IconUtils.iconIdMap["gold"]].name))
		self._buyTipDesTable = {des1 = "今日购买".. lang(tab.tool[IconUtils.iconIdMap["gold"]].name) .. "次数已用完，提升VIP可增加购买次数"}
	elseif goalType == "texp" then
		scaleMap = {.5,.45}
		self._tabTitle:setString("购买" .. lang(tab.tool[IconUtils.iconIdMap["texp"]].name))
		self._buyTipDesTable = {des1 = "今日购买" .. lang(tab.tool[IconUtils.iconIdMap["texp"]].name) .."次数已用完，提升VIP可增加购买次数"}
	elseif goalType == "treasureNum" then
		scaleMap = {.35,.45}
		self._tabTitle:setString("购买" .. lang(tab.tool[41001].name))
		self._buyTipDesTable = {des1 = lang("BUY_MAX_TIPS"),btnTitle = "确定"}
		goalImgArt = "mainView_tradeicon_treasureNum"
	elseif goalType == "magicNum" then
		scaleMap = {.5,.45}
		self._tabTitle:setString("购买" .. lang(tab.tool[3004].name))
		self._buyTipDesTable = {des1 = lang("BUY_MAX_TIPS"),btnTitle = "确定"}
	end

	self._goalIcon:loadTexture("mainView_tradeicon_" .. goalType .. ".png",1)

	local art = goalImgArt or tab:Tool(IconUtils.iconIdMap[goalType] or self._goalMapId[goalType]).art
	if art then
		self._goalImg:loadTexture(art .. ".png",1)
	else
		self._goalImg:loadTexture(IconUtils.resImgMap[goalType],1)
	end
	-- self._goalImg:setScale(scaleMap[1])
	self._costLab:setString(math.ceil(costNum))
	self._costFiveLab:setString(math.ceil(costFiveNum))
	self._costFiveLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
	self._costFiveLab:disableEffect()
	
	if costNum == 0 then
		self._costLab:setString("免费(".. freeTime ..")")
		self._costLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
		-- self._costLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		self._costImg:loadTexture(IconUtils.resImgMap["privilege"],1)
		-- self._costImg:setScale(0.8)
	else
		self._costLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		self._costLab:disableEffect()
		-- self._costLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		local art = tab:Tool(IconUtils.iconIdMap["gem"]).art
		if art then
			self._costImg:loadTexture(art .. ".png",1)
			self._costFiveImg:loadTexture(art .. ".png",1)
		else
			self._costImg:loadTexture(IconUtils.resImgMap["gem"],1)
			self._costFiveImg:loadTexture(IconUtils.resImgMap["gem"],1)
		end
		-- self._costImg:setScale(scaleMap[2])
	end
	self._goalLab:setString(string.format("%d",string.format("%f",goalNum)))
	self._goalLab:setColor(acAddNum >= 1 and UIUtils.colorTable.ccUIBaseColor2 or UIUtils.colorTable.ccUIBaseColor1)
	--UIUtils:center2Widget(self._costImg,self._costLab,303,4)
	--UIUtils:center2Widget(self._goalImg,self._goalLab,303,4)
	
	-- local privilegAdd = (goalType == "texp" and self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_5) > 0 )
	-- 					or (goalType == "gold" and self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_14) > 0) 
	-- if privilegAdd then
	-- 	self._goalLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
	-- else
	-- 	self._goalLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
	-- end
	-- self._goalLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
	self._goalLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._canBuyDes:setString("今日剩余购买次数: ")
	self._canBuyNum:setString((buyNum - buySum) .."/".. buyNum)
   
    local difNum = buyNum - buySum
    if difNum >= self._buyAnyNum then
        self._buyFiveBtn:setTitleText("购买".. self._buyAnyNum .."次")
        self._canMoreNum = self._buyAnyNum
    else
        if difNum == 0 then 
        	difNum = 1 
        	self._costFiveLab:setString(math.ceil(costNum))
        end
        self._buyFiveBtn:setTitleText("购买".. difNum .."次")
        self._canMoreNum = difNum
    end
    
	if (buyNum - buySum) <= 0 then
		self._canBuyNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
		-- self._canBuyNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	else
		self._canBuyNum:disableEffect()
		self._canBuyNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
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
		for i,v in ipairs(tab.vip) do
			print(i,v[tabKey])
			if v[tabKey] ~= 0 then
				limitVipLvl = v.id 
				break
			end
		end
	end
	if limitVipLvl then
		self._canBuyDes:setString("VIP" .. limitVipLvl)
		self._canBuyNum:setString("可购买")
		self._canBuyNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		self._buyTipDesTable = {des1 = "提升VIP可增加购买次数"}
	end
	--]]
	--UIUtils:center2Widget(self._canBuyDes,self._canBuyNum,303)
	self._callback = buyInfo.callback
end

-- tab 事件处理
function GlobalTradeDialog:touchTab( idx ,notRefresh )
	-- 加开启判断
	if idx == 1 then
		if not SystemUtils:enableUser_buyGold() then
	        local systemOpenTip = tab.systemOpen["User_buyGold"][3]
	        if not systemOpenTip then
	            self._viewMgr:showTip(tab.systemOpen["User_buyGold"][1] .. "级开启")
	        else
	            self._viewMgr:showTip(lang(systemOpenTip))
	        end
	        return 
	    end
	end
	for i,v in ipairs(self._tabs) do
		if i ~= idx then
			local tabBtn = self._tabs[i]
			self:tabBtnStatus(tabBtn,false)
		end
	end
	local tabBtn = self._tabs[idx]
	self:tabBtnStatus(tabBtn,true)
	-- tab:setZOrder(99)
	if not notRefresh then
		self._goalType = self._tabTypes[idx]
		self:reflashUI()
	end
end

function GlobalTradeDialog:tabBtnStatus( tabBtn,isSelect )
	local text = tabBtn:getChildByName("text")
	local icon = tabBtn:getChildByName("icon")
	if isSelect then
		tabBtn:loadTextureNormal("globalImageUI12_tab_d.png",1)
		tabBtn:setTouchEnabled(false)
		-- icon:setColor(UIUtils.colorTable.ccUITabColor2)
		-- text:setColor(UIUtils.colorTable.ccUITabColor2)
	else
		tabBtn:loadTextureNormal("globalImageUI12_tab_n.png",1)
		tabBtn:setTouchEnabled(true)
		-- icon:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
		-- text:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
	end
end

-- 生成购买黄金数据
function GlobalTradeDialog:genGoldInfo()
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

    local buyFiveSum = 0
    local tempBuynum = buyGoldNum - buyGoldSum

    if tempBuynum >= self._buyAnyNum then
        buyFiveSum = self._buyAnyNum
    else
        buyFiveSum = tempBuynum
    end

    if hadFree < freeNum then
    	goldCostGem = 0
        if hadFree == 0 then
            buyFiveSum = buyFiveSum - freeNum
        else
            buyFiveSum = buyFiveSum - hadFree
        end
    end

    local curbuyGoldSum = buyGoldSum + 1 - hadFree
    local afterNum = buyGoldSum + buyFiveSum - hadFree

    local goldCostFiveGem = 0
    for i = curbuyGoldSum, afterNum  do
        goldCostFiveGem = goldCostFiveGem + (tab:ReflashCost(math.min(math.max(i,1),#tab.reflashCost)).buyGold or 0)*(1+actCostLess)
    end
    
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    local privilegAdd = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_14)
    local canBuyNum = (lvl*addBase1+addBase2)*(1+privilegAdd*0.01)--百分率
    canBuyNum = math.floor(canBuyNum) * (1+actAdd)
    local buyInfo = {
    	des = lang("BUY_GOLD_WORDSTIPS") or "花费少量钻石可获得大量黄金",
	    costType = "gem",
		costNum = goldCostGem,
		costFiveNum = goldCostFiveGem,
		goalNum = canBuyNum,
		buySum = buyGoldSum,
		buyNum = buyGoldNum,
		freeTime = freeNum - hadFree,
		acAddNum = actAdd,
		callback=function( buyCount )
            self._serverMgr:sendMsg("UserServer", "buyGold", { num = buyCount }, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	audioMgr:playSound("GoldenFinger")
            	self._success = true 
				local critScore = result.crit or 0 
				-- self._viewMgr:showTip("购买黄金成功！")

				self:showBuyAnim(critScore,"jinbi")

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
    
    if tonumber(buyInfo.costFiveNum) and buyInfo.costFiveNum > cost then
		buyInfo.costfivecallback = function( )
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

-- 生成购买兵团经验相关信息
function GlobalTradeDialog:genTexpInfo()
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
	local canBuyNum = (lvl*addBase1+addBase2)*(1+privilegAdd*0.01)
	print("canBuyNum...",canBuyNum,(lvl*addBase1+addBase2),(1+privilegAdd*0.01),actAdd)
	canBuyNum = math.floor(canBuyNum) * (1+actAdd)
	-- canBuyNum
    -- end
    local buySum = math.min(buytexpSum+1,#tab.reflashCost)
    local reflashCostT = tab["reflashCost"]
    local texpCostGem = (tab:ReflashCost(math.max(buySum,1)).buyTexp or 0)*(1+actCostLess)
    local hadFree = self._modelMgr:getModel("PlayerTodayModel"):getData().day14 or 0
    buytexpSum = buytexpSum + hadFree

    local buyFiveSum = 0
    local tempBuynum = buytexpNum - buytexpSum
    if tempBuynum >= self._buyAnyNum then
        buyFiveSum = self._buyAnyNum
    else
        buyFiveSum = tempBuynum
    end


    if hadFree < freeNum then
    	texpCostGem = 0
        if hadFree == 0 then
            buyFiveSum = buyFiveSum - freeNum
        else
            buyFiveSum = buyFiveSum - hadFree
        end
    end

    local afterNum = buytexpSum + buyFiveSum - hadFree
    local curbuytexpSum = buytexpSum + 1 - hadFree

    local texpCostFiveGem = 0
    for i = curbuytexpSum, afterNum  do
        texpCostFiveGem = texpCostFiveGem + (tab:ReflashCost(math.max(i,1)).buyTexp or 0)*(1+actCostLess)
    end

   
    local buyInfo = {
    	des = lang("BUY_TEXP_WORDSTIPS") or "花费少量钻石可获得大量兵团经验",
	    costType = "gem",
		costNum = texpCostGem,
        costFiveNum = texpCostFiveGem,
		goalNum = canBuyNum,
		buySum = buytexpSum,
		buyNum = buytexpNum,
		freeTime = freeNum - hadFree,
		acAddNum = actAdd,
		callback=function( buyCount )
        	local preTexp = self._modelMgr:getModel("UserModel"):getData().texp
            self._serverMgr:sendMsg("UserServer", "buyTexp", { num = buyCount }, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	self._success = true
                -- self._viewMgr:showTip("购买兵团经验成功！")
            	local critScore = result.crit or 0 
	            self:showBuyAnim(critScore,"jingyan")
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

    if tonumber(buyInfo.costFiveNum) and buyInfo.costFiveNum > cost then
		buyInfo.costfivecallback = function( )
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

-- 生成购买法术卷轴数据
function GlobalTradeDialog:genMagicNumInfo()
    -- if not self.addBase1 then
    -- [[ 活动加成
    local actCostLess = 0 --self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_5)
    local actAdd = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_32)
    --]]
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local freeNum = 0 --self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_13)
    local buyMagicNum = tonumber(tab:Vip(vip).buyMagic)+freeNum--tab:Setting("G_INITIAL_BUY_GOLD_NUM").value
    -- end
    local buyMagicSum = self._modelMgr:getModel("PlayerTodayModel"):getData().day48 or 0
    local hadFree = 0 --self._modelMgr:getModel("PlayerTodayModel"):getData().day13 or 0
    local buySum = buyMagicSum+1
    buyMagicSum = buyMagicSum+hadFree
    local magicCostGem = (tab:ReflashCost(math.min(math.max(buySum,1),#tab.reflashCost)).buyMagicNum or 0)*(1+actCostLess)

    local buyFiveSum = 0
    local tempBuynum = buyMagicNum - buyMagicSum
    if tempBuynum >= self._buyAnyNum then
        buyFiveSum = self._buyAnyNum
    else
        buyFiveSum = tempBuynum
    end

    if hadFree < freeNum then
    	magicCostGem = 0
        if hadFree == 0 then
            buyFiveSum = buyFiveSum - freeNum
        else
            buyFiveSum = buyFiveSum - hadFree
        end
    end

    local afterNum = buyMagicSum + buyFiveSum - hadFree
    local magicCostFiveGem = 0
    local curbuytexpSum = buyMagicSum + 1 - hadFree
    for i = curbuytexpSum, afterNum  do
        magicCostFiveGem = magicCostFiveGem + (tab:ReflashCost(math.min(math.max(i,1),#tab.reflashCost)).buyMagicNum or 0)*(1+actCostLess)
    end

    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    -- local privilegAdd = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_14)
    local canBuyNum = tab:Setting("G_BUY_MAGIC").value --100 --(lvl*addBase1+addBase2)*(1+privilegAdd*0.01+actAdd)--百分率
    canBuyNum = math.floor(canBuyNum) * (1+actAdd)
    local buyInfo = {
    	des = "" , -- lang("BUY_GOLD_WORDSTIPS") or "花费少量钻石可获得大量黄金",
	    costType = "gem",
		costNum = magicCostGem,
        costFiveNum = magicCostFiveGem,
		goalNum = canBuyNum,
		buySum = buyMagicSum,
		buyNum = buyMagicNum,
		freeTime = freeNum - hadFree,
		acAddNum = actAdd,
		callback=function( buyCount )
            self._serverMgr:sendMsg("UserServer", "buyMagicNum", {num = buyCount}, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	audioMgr:playSound("GoldenFinger")
            	self._success = true 
				local critScore = result.crit or 0 
				-- self._viewMgr:showTip("购买法术卷轴成功！")
                self:showBuyAnim(critScore,"fashujuanzhou")
                self:reflashUI()
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

    if tonumber(buyInfo.costFiveNum) and buyInfo.costFiveNum > cost then
		buyInfo.costfivecallback = function( )
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
				self._buyBtn:setBright(true)
				self._buyBtn:setEnabled(true)
			end})
		end
	end

    if buyMagicSum >= buyMagicNum then
        return buyInfo,false
    end
    return buyInfo,true
end

-- 购买宝物进阶石
function GlobalTradeDialog:genTreasureNumInfo()
    -- if not self.addBase1 then
    -- [[ 活动加成
    local actCostLess = 0--self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_5)
    -- local actAdd = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_XX)
    --]]
    local vip = self._modelMgr:getModel("VipModel"):getData().level
    local freeNum = 0 --self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_13)
    local buyTreasureNum = tonumber(tab:Vip(vip).buyTreasureNum or 0)+freeNum--tab:Setting("G_INITIAL_BUY_GOLD_NUM").value
    -- end
    local buyTreasureSum = self._modelMgr:getModel("PlayerTodayModel"):getData().day49 or 0
    local hadFree = 0 --self._modelMgr:getModel("PlayerTodayModel"):getData().day13 or 0
    local buySum = buyTreasureSum+1
    buyTreasureSum = buyTreasureSum+hadFree
    local treasureCostGem = (tab:ReflashCost(math.min(math.max(buySum,1),#tab.reflashCost)).buyTreasureNum or 0)*(1+actCostLess)

    local buyFiveSum = 0
    local tempBuynum = buyTreasureNum - buyTreasureSum
    if tempBuynum >= self._buyAnyNum then
        buyFiveSum = self._buyAnyNum
    else
        buyFiveSum = tempBuynum
    end

 
    if hadFree < freeNum then
    	treasureCostGem = 0
        if hadFree == 0 then
            buyFiveSum = buyFiveSum - freeNum
        else
            buyFiveSum = buyFiveSum - hadFree
        end
    end
     
    local afterNum = buyTreasureSum + buyFiveSum - hadFree
    local treasureCostFiveGem = 0
    local curbuyTreasureSum = buyTreasureSum + 1 - hadFree
    for i = curbuyTreasureSum, afterNum  do
        treasureCostFiveGem = treasureCostFiveGem + (tab:ReflashCost(math.min(math.max(i,1),#tab.reflashCost)).buyTreasureNum or 0)*(1+actCostLess)
    end

    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    -- local privilegAdd = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_14)
    local canBuyNum = tab:Setting("G_BUY_TREASURE").value --100 --(lvl*addBase1+addBase2)*(1+privilegAdd*0.01+actAdd)--百分率
    local buyInfo = {
    	des = "" , -- lang("BUY_GOLD_WORDSTIPS") or "花费少量钻石可获得大量黄金",
	    costType = "gem",
		costNum = treasureCostGem,
        costFiveNum = treasureCostFiveGem,
		goalNum = canBuyNum,
		buySum = buyTreasureSum,
		buyNum = buyTreasureNum,
		freeTime = freeNum - hadFree,
		acAddNum = actAdd,
		callback=function( buyCount )
            self._serverMgr:sendMsg("UserServer", "buyTreasureNum", { num = buyCount }, true, {}, function(result)
            	if self._successCallback then
            		self._successCallback()
            	end
            	audioMgr:playSound("GoldenFinger")
            	self._success = true 
				local critScore = result.crit or 0 
				-- self._viewMgr:showTip("购买进阶石成功！")
                self:showBuyAnim(critScore,"jinjieshi")
                self:reflashUI()
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

    if tonumber(buyInfo.costFiveNum) and buyInfo.costFiveNum > cost then
		buyInfo.costfivecallback = function( )
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
				local viewMgr = ViewManager:getInstance()
				viewMgr:showView("vip.VipView", {viewType = 0})
				self._buyBtn:setBright(true)
				self._buyBtn:setEnabled(true)
			end})
		end
	end

    if buyTreasureSum >= buyTreasureNum then
        return buyInfo,false
    end
    return buyInfo,true
end

function GlobalTradeDialog:showBuyAnim( critScore,animName )
	print("critScore",critScore)
	local bgW,bgH = self._goalLab:getContentSize().width,self._goalLab:getContentSize().height
    local mc1 = mcMgr:createViewMC("goumaiguang_jiaoyisuouianim", true, false, function (_, sender)
        sender:removeFromParent()
        -- self._viewMgr:showTip("购买金币成功！")
        self:detectCanBuy()
    end)
    if mc1 then
    	mc1:setPosition(cc.p(self._bg:getContentSize().width/2+50,self._bg:getContentSize().height/2+60))
	    mc1:setScale(1)
	    self._bg:addChild(mc1,99)
		ScheduleMgr:delayCall(200, self, function()
			if self._bg == nil then return end
			local mc2 = mcMgr:createViewMC(animName .. "_jiaoyisuouianim", true, true)
			mc2:setPosition(cc.p(self._bg:getContentSize().width/2+50,self._bg:getContentSize().height/2+60))
			self._bg:addChild(mc2,99)
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
end

function GlobalTradeDialog:detectCanBuy( )
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
function GlobalTradeDialog:detectFiveCanBuy( )
	local buyInfo
	local canBuy 
    if self._genFunc then
        buyInfo,canBuy = self._genFunc(self)-- 加上self参数
        self._callback = buyInfo.callback

        if buyInfo.costfivecallback then
            self._callback = buyInfo.costfivecallback
        end
    else
    	return false
    end
    if not canBuy then
    	return false
    end
    return true
end

-- 红点逻辑
function GlobalTradeDialog:detectFree( goalType )
	local isFree = false
	if goalType == "texp" then
		local freeNum = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_6) or 0
		local hadFree = self._modelMgr:getModel("PlayerTodayModel"):getData().day14 or 0
		if hadFree < freeNum then
	    	return true
	    end
	elseif goalType == "gold" then
		local freeNum = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_13)
		local hadFree = self._modelMgr:getModel("PlayerTodayModel"):getData().day13 or 0
		if hadFree < freeNum then
	    	return true
	    end
	end
	return isFree 
end

-- 左上标签 双倍
function GlobalTradeDialog:detectDouble( goalType )
	local isDouble = false
	if goalType == "gold" then
		local actAdd = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_7)
		if actAdd >= 1 then 
			return true 
		end
	elseif goalType == "texp" then
		local actAdd = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_8)
		if actAdd >= 1 then 
			return true 
		end
	elseif goalType == "magicNum" then
		local actAdd = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_32)
		if actAdd >= 1 then 
			return true 
		end
	-- elseif goalType == "treasureNum" then
	-- 	local actAdd = self._actModel:getAbilityEffect(self._actModel.PrivilegIDs.PrivilegID_XX)
	end
	return isDouble 
end


function GlobalTradeDialog:addDot( tabBtn,isAdd )
	local dot = tabBtn:getChildByFullName("dot")
	if not dot then
		dot = ccui.ImageView:create()
        dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
        dot:setPosition(tabBtn:getContentSize().width-20,tabBtn:getContentSize().height-20)
        dot:setName("dot")
        tabBtn:addChild(dot,99)
	end
	dot:setVisible(isAdd)
end

-- 添加双倍标签
function GlobalTradeDialog:addDouble( tabBtn,isDouble )
	local doubleImg = tabBtn._doubleImg
	if not doubleImg then
		-- image
		doubleImg = ccui.ImageView:create()
        doubleImg:loadTexture("priviege_tipBg.png", 1)
        doubleImg:setScale(0.8)
        doubleImg:setPosition(25,tabBtn:getContentSize().height-25)
        tabBtn._doubleImg = doubleImg
        tabBtn:addChild(doubleImg,99)
  		-- text
  		local text = ccui.Text:create()
  		text:setFontSize(18)
  		text:setFontName(UIUtils.ttfName)
  		-- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
  		text:setRotation(-45)
  		text:setPosition(25,36)
  		text:setString("双倍")
  		doubleImg:addChild(text)
	end
	doubleImg:setVisible(isDouble)
end

function GlobalTradeDialog:detectDot( )
	for i,v in ipairs(self._tabConfig) do
		local isFree = self:detectFree(v.goalType)
		self:addDot(self._tabs[i],isFree)

		-- 双倍标签
		local isDouble = self:detectDouble(v.goalType)
		self:addDouble(self._tabs[i],isDouble)
	end
end

return GlobalTradeDialog