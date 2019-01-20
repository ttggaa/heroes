--[[
32
    Filename:    ACAwakenLimitTimeLayer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-06 19:44
    Description: 限时魂石活动
--]]

--功能开发备忘
--[[
---------【前端】
1.ACAwakenLimitTimeLayer 	--UI_INFO 配置新活动id对应的资源
2.DialogFlashLTAResult 		--uiInfo  配置新活动id对应的资源
3.主界面icon / 界面图

---------【测试着重点】
1.主界面红点
	(显示条件：1--免费次数 or 2--宝箱未领)
2.抽卡恭喜获得界面：
	(1--碎片显示 2--整卡显示)
3.觉醒对应功能

---------【运营/策划】
1.limitItemsConfig
2.limitItemsBox：配置宝箱奖励
3.lang表：ac1051tips1_awake/ac1051rule_awake/ac1051title_awake
]]

local ACAwakenLimitTimeLayer = class("ACAwakenLimitTimeLayer", BasePopView)

--新活动修改处
local UI_INFO = {
	[1051] = {	--比蒙
		teamId = 407,
		priviewBtn = {73, 412},
		titlePos = {723, 383},
		frame = {fType = 2, fPos = {724, 288}},
		bdListPos = {590, 205},
		role = {scale = 0.72, pos = {337, 240}},
	},

	[1052] = {	--娜迦
		teamId = 606,
		priviewBtn = {73, 412},
		titlePos = {723, 383},
		frame = {fType = 2, fPos = {724, 288}},
		bdListPos = {584, 205},
		role = {scale = 0.75, pos = {260, 217}},
	},

	[1053] = {	--大天使
		teamId = 107,
		priviewBtn = {73, 412},
		titlePos = {724, 382},
		frame = {fType = 2, fPos = {724, 288}},
		bdListPos = {589, 205},
		role = {scale = 0.7, pos = {277, 237}},
	},
	[1054] = {	--鬼龙
		teamId = 307,
		priviewBtn = {73, 412},
		titlePos = {724, 382},
		frame = {fType = 2, fPos = {711, 288}},
		bdListPos = {589, 205},
		role = {scale = 0.8, pos = {285, 237}},
		bgImg = "ac_awakenTL_bg1",
	},
	[1055] = {	--绿龙
		teamId = 207,
		priviewBtn = {73, 412},
		titlePos = {724, 382},
		frame = {fType = 2, fPos = {707, 285}},
		bdListPos = {589, 205},
		role = {scale = 0.8, pos = {305, 212}},
	},
	[1056] = {	--大恶魔
		teamId = 507,
		priviewBtn = {73, 412},
		titlePos = {724, 382},
		frame = {fType = 2, fPos = {726, 286}},
		bdListPos = {589, 205},
		role = {scale = 0.7, pos = {265, 212}},
	},
	[1057] = {	--黑龙
		teamId = 707,
		priviewBtn = {73, 412},
		titlePos = {724, 382},
		frame = {fType = 2, fPos = {708, 287}},
		bdListPos = {589, 205},
		role = {scale = 0.7, pos = {335, 200}},
	},
	[1058] = {	--蛮牛
		teamId = 805,
		priviewBtn = {73, 412},
		titlePos = {730, 382},
		frame = {fType = 2, fPos = {723, 284}},
		bdListPos = {589, 205},
		role = {scale = 0.7, pos = {240, 213}},
	},
	[1059] = {	--圣坛
		teamId = 108,
		priviewBtn = {73, 412},
		titlePos = {730, 382},
		frame = {fType = 2, fPos = {723, 289}},
		bdListPos = {589, 205},
		role = {scale = 0.7, pos = {240, 233}},
	},
	[1060] = {	--狂战士
		teamId = 408,
		priviewBtn = {73, 412},
		titlePos = {730, 382},
		frame = {fType = 2, fPos = {723, 289}},
		bdListPos = {589, 205},
		role = {scale = 0.7, pos = {240, 233}},
	},
	[1061] = {	--泰坦
		teamId = 607,
		priviewBtn = {73, 412},
		titlePos = {730, 382},
		frame = {fType = 2, fPos = {723, 289}},
		bdListPos = {589, 205},
		role = {scale = 0.7, pos = {240, 233}},
	},
}

function ACAwakenLimitTimeLayer:ctor(param)
	ACAwakenLimitTimeLayer.super.ctor(self)
	self._ltAwkModel = self._modelMgr:getModel("LimitAwakenModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._teamModel = self._modelMgr:getModel("TeamModel")

	self._callback = param.callback
	self._callback2 = param.callback2
	self._id = param.id       --活动id
	self._acID = param.acId   --活动activity_id
	self._isLoadRes = param.isLoadRes or false
	self._uiInfo = UI_INFO[self._acID]
	self._freeCell = {}
    self._useCell = {}
    self._runDataIndex = 0
    self._refeshTimes = 0
end

function ACAwakenLimitTimeLayer:getAsyncRes()
    if self._isLoadRes then
		return {}
	else
		return 
	    {
	        {"asset/ui/acAwakenTL.plist", "asset/ui/acAwakenTL.png"},
	        {"asset/ui/acAwakenTL1.plist", "asset/ui/acAwakenTL1.png"},
	        {"asset/ui/acAwakenTL2.plist", "asset/ui/acAwakenTL2.png"},
	        {"asset/ui/activityTeamTL.plist", "asset/ui/activityTeamTL.png"},
	    }
	end
end

function ACAwakenLimitTimeLayer:onInit()
	self:registerTimer(5, 0, GRandom(0, 10), function ()
        self:refreshCostNum()
    end)

    --彩带
    local caidaiAnim = mcMgr:createViewMC("huodongpiaodai_vipmainview", false, true)
    caidaiAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self:addChild(caidaiAnim)

	local bg = self:getUI("bg.bg1")

	--bgImg
	local bgImg = self:getUI("bg.bg1.Image_66")
	bgImg:loadTexture("asset/bg/" .. (self._uiInfo["bgImg"] or "ac_awakenTL_bg") .. ".png")
	bgImg:setVisible(true)

	--priviewBtn
	local priviewBtn = self:getUI("bg.bg1.priviewBtn")
	priviewBtn:setPosition(self._uiInfo["priviewBtn"][1], self._uiInfo["priviewBtn"][2])
	local eyeAnim = mcMgr:createViewMC("juexing1_juexingtubiao", true, false)
    eyeAnim:setPosition(priviewBtn:getContentSize().width*0.5, priviewBtn:getContentSize().height*0.5 + 6)
    priviewBtn:addChild(eyeAnim)
    self:getUI("bg.bg1.priviewBtn.lab"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	self:registerClickEvent(priviewBtn, function()
		local teamId = self._uiInfo["teamId"]
		local param = {teamId = teamId, showtype = 2}
    	self._viewMgr:showDialog("team.TeamAwakenShowDialog", param)
		end)

	--roleImg
	local roleImg = self:getUI("bg.bg1.roleImg")
	local teamId  = self._uiInfo["teamId"]
    local teamD = tab:Team(teamId)
	local lihui = string.sub(teamD["art1"], 4, string.len(teamD["art1"]))
	local res = "asset/uiother/team/ta_" .. lihui .. ".png"
	roleImg:loadTexture(res)
	roleImg:setPosition(self._uiInfo["role"]["pos"][1], self._uiInfo["role"]["pos"][2])
	
	self:getUI("bg.bg1.Label_53"):setString("")
	local rcdTitle = self:getUI("bg.bg1.rcdTitle")
	rcdTitle:setString(lang("ac" .. self._acID .. "title_awake"))
	rcdTitle:setPosition(self._uiInfo["titlePos"][1], self._uiInfo["titlePos"][2])
	self:getUI("bg.bg1.recruit1.freeTip"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

	local countStr = self:getUI("bg.bg1.time.countStr")
	countStr:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local countNum = self:getUI("bg.bg1.time.countNum")
	countNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local Label_59 = self:getUI("bg.bg1.scoreBg.Label_59")
	Label_59:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local Label_60 = self:getUI("bg.bg1.scoreBg.Label_60")
	Label_60:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	--skill des
	self:getUI("bg.bg1.Image_55"):loadTexture("ac_awakenTL_desImg_" .. self._acID .. ".png", 1)
	self:getUI("bg.bg1.Image_100"):loadTexture("ac_awakenTL_tipImg_" .. self._acID .. ".png", 1)

	--frame
	local frame = self._uiInfo["frame"]
	if frame["fPos"] == nil then
		frame["fPos"] = {0, 0}
	end
	if frame["fType"] == 1 then  		--宽一半 高需要拉九宫
		for i=1, 2 do
			local frameImg = self:getUI("bg.bg1.frame" .. i)
			frameImg:loadTexture("ac_awakenTL_bdBg_" .. self._acID .. ".png", 1)
			if i == 1 then
				frameImg:setPosition(714 - frameImg:getContentSize().width * 0.5 + frame["fPos"][1], 283 + frame["fPos"][2])
			else
				frameImg:setPosition(714 + frameImg:getContentSize().width * 0.5 + frame["fPos"][1], 283 + frame["fPos"][2])
			end
		end

	elseif frame["fType"] == 2 then 	--宽全 高需要拉九宫
		local frameImg = self:getUI("bg.bg1.frame1")
		frameImg:loadTexture("ac_awakenTL_bdBg_" .. self._acID .. ".png", 1)
		frameImg:setPosition(frame["fPos"][1], frame["fPos"][2])

		local frameImg2 = self:getUI("bg.bg1.frame2")
		frameImg2:setVisible(false)
	end

	--bdList
	local tableBg = self:getUI("bg.bg1.rcdList")
	tableBg:setPosition(self._uiInfo["bdListPos"][1], self._uiInfo["bdListPos"][2])

	--ruleBtn
	local ruleBtn = self:getUI("bg.bg1.ruleBtn")
	self:registerClickEvent(ruleBtn, function()
		self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("ac" .. self._acID .. "rule_awake")},true)
		end)

	local closeBtn = self:getUI("bg.bg1.closeBtn")
	self:registerClickEvent(closeBtn, function() 
		if self._callback then
			self._callback()
		end
		if self._callback2 then
			self._callback2()
		end
		self:close()
		UIUtils:reloadLuaFile("activity.acLimit.ACAwakenLimitTimeLayer")
		UIUtils:reloadLuaFile("LimitAwakenModel", "game.model.")
		UIUtils:reloadLuaFile("activity.acLimit.DialogFlashLTAResult")
		end)

	--招募1次
	local btn1 = self:getUI("bg.bg1.recruit1.btn")
	local btn2 = self:getUI("bg.bg1.recruit2.btn")
	btn1:setTitleColor(cc.c4b(255, 255, 255, 255))
	btn1:getTitleRenderer():enableOutline(cc.c4b(112, 32, 30, 255), 1)
	btn1:setTitleFontSize(18)	
	btn2:setTitleColor(cc.c4b(255, 255, 255, 255))
	btn2:getTitleRenderer():enableOutline(cc.c4b(112, 32, 30, 255), 1)
	btn2:setTitleFontSize(18)	
	self:registerClickEventByName("bg.bg1.recruit1.btn", function()
		--魂石上限提示
	    local sysTeamD = tab.team[self._uiInfo["teamId"]]
	    local _, hasNum = self._modelMgr:getModel("ItemModel"):getItemsById(sysTeamD["awakingUp"])
	    local isFree = self._ltAwkModel:isTodayHasFreeNumById(self._id)
	    local isTiped = self._ltAwkModel:getIsTipedById(self._id)
	    if not isTiped and not isFree and hasNum >= 520 then  --不是免费 / 魂石上限
	    	self._ltAwkModel:setIsTipedById(true, self._id)
	    	self._viewMgr:showDialog("global.GlobalSelectDialog",
	        {   desc = lang("ac1051tips2_awake"),
	            button1 = "确定",
	            button2 = "取消", 
	            callback1 = function ()
	                self:recruitBtnClick(1)
	            end,
	            callback2 = function()
	            end})
	    else
	    	self:recruitBtnClick(1)
	    end
	end)

	--招募10次
	self:registerClickEventByName("bg.bg1.recruit2.btn", function() 
		--魂石上限提示
	    local sysTeamD = tab.team[self._uiInfo["teamId"]]
	    local _, hasNum = self._modelMgr:getModel("ItemModel"):getItemsById(sysTeamD["awakingUp"])
	    local isTiped = self._ltAwkModel:getIsTipedById(self._id)

	    local function tenRecruitTip()
	    	local tag = SystemUtils.loadAccountLocalData("LIMIT_AWAKE_NO_WARING")
		    if tag and tag == 1 then
	            self:recruitBtnClick(10)
		    else
		    	self._viewMgr:showDialog("shop.DirectChargeSureDialog",{
	                localTxt = "LIMIT_AWAKE_NO_WARING",
	                contentTxt = "awake_warning1",
	                callback = function ()
	                    self:recruitBtnClick(10)
	                end})
		    end
	    	
	    end

	    if not isTiped and hasNum >= 520 then  --不是免费 / 魂石上限
	    	self._ltAwkModel:setIsTipedById(true, self._id)
	    	self._viewMgr:showDialog("global.GlobalSelectDialog",
	        {   desc = lang("ac1051tips2_awake"),
	            button1 = "确定",
	            button2 = "取消", 
	            callback1 = function ()
	                tenRecruitTip()
	            end,
	            callback2 = function()
	            end})
	    else
	    	tenRecruitTip()
	    end
	end)

	-- 换luckyCoin icon
	self._isUseLuck = self._userModel:drawUseLuckyCoin()
	if self._isUseLuck then
		self:getUI("bg.bg1.recruit1.icon"):loadTexture("globalImageUI_luckyCoin.png",1)
		self:getUI("bg.bg1.recruit1.icon"):setScale(0.8)
		self:getUI("bg.bg1.recruit2.icon"):loadTexture("globalImageUI_luckyCoin.png",1)
		self:getUI("bg.bg1.recruit2.icon"):setScale(0.8)
	end

	--model监听
    self:setListenReflashWithParam(true)
    self:listenReflash("LimitAwakenModel", self.insertBroadcast)

    --获取宝箱奖励数据
    self._boxRewards = self._ltAwkModel:getRewardListById(self._id)

	--场景监听
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	if self._scheduler then
        		if self._scheduler1 then
        			self._scheduler:unscheduleScriptEntry(self._scheduler1)
        		end
        		self._scheduler = nil
        		for k,v in pairs(self._freeCell) do
        			v:release() 
        		end
        	end
            
        elseif eventType == "enter" then 
			self:createBroadcast()  --跑马灯
			--倒计时
			self:setCountTime()
        end
    end)
end

function ACAwakenLimitTimeLayer:recruitBtnClick(inType)
	local curTime = self._userModel:getCurServerTime()
    local endTime = self._data["endTime"] or 0
    if curTime >= endTime then
    	self._viewMgr:showTip("限时魂石活动已结束")
    	return
    end

    local isFree = self._ltAwkModel:isTodayHasFreeNumById(self._id)   --今日已领取次数
	local sysTLConfig = tab.limitItemsConfig
	local needGem
	if inType == 1 then
		needGem = sysTLConfig["cost1"]["num"]
	else
		needGem = sysTLConfig["cost10"]["num"]
	end
	
	local curCoin = 0
	if self._isUseLuck then
		curCoin = self._userModel:getData().luckyCoin or 0
	else
		curCoin = self._userModel:getData().gem or 0
	end
	if not (isFree and inType == 1 ) and curCoin < needGem then
		-- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
		--     local viewMgr = ViewManager:getInstance()
		--     viewMgr:showView("vip.VipView", {viewType = 0})
		-- end})
		DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = needGem - curCoin })
        end})

        return
	end

	self._serverMgr:sendMsg("LimitItemsServer", "limitItemsLottery", {num = inType, acId = self._id}, true, {}, function(result, errorCode)
		self:refreshCostNum()			
		self._viewMgr:showDialog("activity.acLimit.DialogFlashLTAResult",{ 
			awards = result.reward or {},
			showType = "awaken",   --限时兵团
			costType = "gem",
			costNum = needGem or 0,
			buyNum = inType,
			curData = self._data,
			acId = self._acID,
			id = self._id,
			callback = function() self:reflashUI() end},true)
		end)

    
end

function ACAwakenLimitTimeLayer:reflashUI()
	local roleImg = self:getUI("bg.bg1.roleImg")
	if self._uiInfo["role"]["scale"] then
		roleImg:setScale(self._uiInfo["role"]["scale"])
	end

	if self._refeshTimes < 2 then
		self._refeshTimes = self._refeshTimes + 1
	end
	
	self._data = self._ltAwkModel:getDataById(self._id)
	-- dump(self._data, "reflashUI()")

	--钻石
	self:refreshCostNum()

	--积分
	local curScore = self._data["boxPt"] or 0
	local scoreNum = self:getUI("bg.bg1.scoreBg.Label_60")
	scoreNum:setString(curScore)
	if self._refeshTimes > 1 then
		local preColor = scoreNum:getColor()
	    scoreNum:setColor(cc.c3b(0, 255, 0))
	    scoreNum:runAction(cc.Sequence:create(
	    	cc.ScaleTo:create(0.1,1.2),
	    	cc.ScaleTo:create(0.3,1),
	    	cc.CallFunc:create(function()
		        scoreNum:setColor(preColor)
		    end)))
	end
	
	--进度条
	self:setPercentBar()
	--reward
	self:setRewards()
end

function ACAwakenLimitTimeLayer:refreshCostNum()
	local sysTLConfig = tab.limitItemsConfig
	--免费次数
	local isFree = self._ltAwkModel:isTodayHasFreeNumById(self._id)   --今日已领取次数
	if isFree then
		self:getUI("bg.bg1.recruit1.freeTip"):setVisible(true)
		self:getUI("bg.bg1.recruit1.num"):setVisible(false)
		self:getUI("bg.bg1.recruit1.icon"):setVisible(false)
	else
		self:getUI("bg.bg1.recruit1.freeTip"):setVisible(false)
		self:getUI("bg.bg1.recruit1.num"):setVisible(true)
		self:getUI("bg.bg1.recruit1.icon"):setVisible(true)
	end

	--抽卡钻石
	self:getUI("bg.bg1.recruit1.num"):setString(sysTLConfig["cost1"]["num"])
	self:getUI("bg.bg1.recruit2.num"):setString(sysTLConfig["cost10"]["num"])
end

function ACAwakenLimitTimeLayer:setPercentBar()
	local sysTLConfig = tab.limitItemsConfig
	local sysLimitItemsBox = self._boxRewards
	local curScore = self._data["boxPt"] or 0

	local needPercent = {0, 14, 28, 42, 56, 70, 84, 100}
	local needScore = {
		[1] = 0, 
		[2] = sysLimitItemsBox[1]["score"],
		[3] = sysLimitItemsBox[2]["score"],
		[4] = sysLimitItemsBox[3]["score"],
		[5] = sysLimitItemsBox[4]["score"],
		[6] = sysLimitItemsBox[5]["score"],
		[7] = sysLimitItemsBox[6]["score"],
		[8] = sysLimitItemsBox[7]["score"],
	}
	local disPer = {14, 14, 14, 14, 14, 14, 16}
	local disScore = {
		[1] = sysLimitItemsBox[1]["score"],
		[2] = sysLimitItemsBox[2]["score"] - sysLimitItemsBox[1]["score"],
		[3] = sysLimitItemsBox[3]["score"] - sysLimitItemsBox[2]["score"],
		[4] = sysLimitItemsBox[4]["score"] - sysLimitItemsBox[3]["score"],
		[5] = sysLimitItemsBox[5]["score"] - sysLimitItemsBox[4]["score"],
		[6] = sysLimitItemsBox[6]["score"] - sysLimitItemsBox[5]["score"],
		[7] = sysLimitItemsBox[7]["score"] - sysLimitItemsBox[6]["score"],
	}

	local maxId = 8
	for i=1, 7 do
		local needScore = sysLimitItemsBox[i]["score"]
		if curScore < needScore then      
			maxId = i
			break
		end
	end
	local percent = 0
	if maxId >= 8 then
		percent = 100
	else
		percent = needPercent[maxId] + disPer[maxId] * (curScore - needScore[maxId]) / disScore[maxId]
	end
	local proBg = self:getUI("bg.bg1.proBg")
	local proBar = self:getUI("bg.bg1.proBg.proBar")
	proBar:setVisible(false)

	local clipNode = self:getUI("bg.bg1.proBg.clipNode")
	local perFrom = clipNode.percent or 0
	local perTo = math.max(0, math.min(100, percent))
	local disMove = (perTo - perFrom) / 20

	if self._refeshTimes > 1 then
		clipNode:runAction(cc.RepeatForever:create(cc.Sequence:create(
			cc.CallFunc:create(function()
				if (clipNode.percent or 0) >= perTo then
					clipNode:stopAllActions()
					return
				end
				local curPercent = (clipNode.percent or 0) + disMove
				clipNode:setContentSize(cc.size(curPercent * 0.01 * proBar:getContentSize().width, proBar:getContentSize().height))
				clipNode.percent = curPercent
				end),
			cc.DelayTime:create(0.01)
			)))
	else
		clipNode:setContentSize(cc.size(perTo * 0.01 * proBar:getContentSize().width, proBar:getContentSize().height))
		clipNode.percent = perTo
	end
end

function ACAwakenLimitTimeLayer:setCountTime()
    local countStr = self:getUI("bg.bg1.time.countStr")
    local countNum = self:getUI("bg.bg1.time.countNum")

    local curTime = self._userModel:getCurServerTime()
    local endTime = self._data["endTime"] or 0

    local tempTime = endTime - curTime -- 85600
    local day, hour, minute, second, tempValue    
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempTime = tempTime - 1
            tempValue = tempTime
            day = math.floor(tempValue/86400) 
            tempValue = tempValue - day*86400
            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600
            minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
            if day == 0 then
                showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
            end

            if tempTime <= 0 then
                showTime = "00天00:00:00"
            end
            countNum:setString(showTime)
            countNum:setPositionX(countStr:getPositionX() + 5)
        end),cc.DelayTime:create(1))
    ))
end

function ACAwakenLimitTimeLayer:setRewards()
	local sysLimitItemsBox = self._boxRewards
	local rwdList = self._data["rewardList"] or {}
	local rwdType = {1, 1 ,1, 2, 2, 3, 3}

	for i=1,7 do
		local rwd = self:getUI("bg.bg1.rwd"..i)
		local sysIndex = sysLimitItemsBox[i]["index"]

		--num
		local rwdNum = rwd:getChildByFullName("numBg.num")
		rwdNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		rwdNum:setString(sysLimitItemsBox[i].score)

	    local itemId = sysLimitItemsBox[i]["reward"][1][2]
	    local itemNum = sysLimitItemsBox[i]["reward"][1][3]
	    local itemData = tab:Tool(itemId)
        local param = {itemId = itemId, num = sysLimitItemsBox[i].score, itemData = itemData}

		--宝箱icon
		local icon = rwd:getChildByName("icon")
		icon:stopAllActions()
        if icon._boxLight ~= nil then 
            icon._boxLight:removeFromParent(true)
            icon._boxLight = nil
        end
        if icon._boxAnim ~= nil then 
            icon._boxAnim:removeFromParent(true)
            icon._boxAnim = nil
        end
		
		local function rewardBtnAnim()
			if icon._boxLight == nil then
				local boxLight = mcMgr:createViewMC("baoxiangguang1_baoxiang", true)
			    boxLight:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
			    icon._boxLight= boxLight
			    icon:addChild(boxLight, 2)
			end
			icon._boxLight:setVisible(true)

			if icon._boxAnim == nil then
				local boxAnim = mcMgr:createViewMC("hunshibaoxiang" .. rwdType[i] .. "_hunshibaoxiang", true)
			    boxAnim:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
			    icon._boxAnim = boxAnim
			    icon:addChild(boxAnim)
			end
			icon._boxAnim:setVisible(true)
		end
	
        --isGet  1积分不足 2未领取 3已领取
        local curScore = self._data["boxPt"]
    	local needScore = sysLimitItemsBox[i].score
		if rwdList[tostring(sysIndex)] and rwdList[tostring(sysIndex)] == 1 then   --3已领取
			local img = "boxa_"..rwdType[i].."_p.png"
			icon:loadTextures(img, img, img, 1)
			icon:setOpacity(255)
			icon:setScale(0.9)

			icon._lingqu = 3
			icon._isJuxing = true

		elseif curScore >= needScore and rwdList[tostring(sysIndex)] ~= 1 then  --2未领取
			local img = "boxa_"..rwdType[i].."_n.png"
			icon:loadTextures(img, img, img, 1)
			icon:setScale(1)

			if icon._isJuxing == false then   --没有聚过光，且前一个状态是积分不足
	            icon:runAction(cc.CallFunc:create(function()
	                local tmpStar = mcMgr:createViewMC("juxing_fubenbaoxiangkaiqijuxing", false, true)
	                tmpStar:addCallbackAtFrame(17, function()
	                	icon:setOpacity(0)
	                    rewardBtnAnim()
	                end)
	                tmpStar:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
	                icon:addChild(tmpStar,10)
	                icon._isJuxing = true

	            end))
	        else
	        	icon:setOpacity(0)
	            rewardBtnAnim()
	            icon._isJuxing = true
	        end
			icon._lingqu = 2
			
		else
			local img = "boxa_"..rwdType[i].."_n.png"
			icon:loadTextures(img, img, img, 1)
			icon:setOpacity(255)
			icon:setScale(1)

			icon._lingqu = 1
			icon._isJuxing = false
		end

        self:registerClickEvent(icon, function()
        	if icon._lingqu == 1 then
        		DialogUtils.showGiftGet( {
				    gifts = sysLimitItemsBox[i]["reward"],
				    viewType = 1,
				    canGet = false, 
				    des = "领取奖励需要"..sysLimitItemsBox[i]["score"].."积分，请继续加油哦~",
				    callback = function()  
				    end} )

        	elseif icon._lingqu == 3 then   --不能领取
        		DialogUtils.showGiftGet( {
				    gifts = sysLimitItemsBox[i]["reward"],
				    viewType = 1,
				    canGet = false, 
				    des = "领取奖励需要"..sysLimitItemsBox[i]["score"].."积分，请继续加油哦~",
				    btnTitle = "已领取", 
				    callback = function()  
				    end} )

        	else
				local curTime = self._userModel:getCurServerTime()
			    local endTime = self._data["endTime"] or 0
			    if curTime >= endTime then
			    	self._viewMgr:showTip("限时魂石活动已结束")
			    	return
			    end
        		self._serverMgr:sendMsg("LimitItemsServer", "getLimitItemsBox", {id = sysIndex, acId = self._id}, true, {}, function(result, errorCode)
					DialogUtils.showGiftGet({
		                gifts = result.reward,
		                callback = function()
		                	self:setRewards()
		            	end})
					end)
	        end
        end)
    end
end

function ACAwakenLimitTimeLayer:createBroadcast()
    --定时器
    self._scheduler = cc.Director:getInstance():getScheduler()
    self._scheduler1 = self._scheduler:scheduleScriptFunc(handler(self, self.scheduleUpdate), 0, false)

    if not (self._data["notice"] and next(self._data["notice"]) ~= nil) then
        self:getUI("bg.bg1.Label_53"):setString("当前没有领主触发神迹")
        return
    end

    local tableBg = self:getUI("bg.bg1.rcdList")
    local bgH = tableBg:getContentSize().height
    local tempIndex = 0
    for i=1, 4 do
        local cell = self:cellAtIndex(i)
        if cell ~= nil then
            cell:setPosition(3, bgH - cell:getContentSize().height * i)
            cell.index = i
            tableBg:addChild(cell)
            tempIndex = i
	        if cell.isRetain == 1 then 
	        	cell.isRetain = 0
	        	cell:release()
	        end  
        end
    end

    self._runDataIndex = tempIndex
end

function ACAwakenLimitTimeLayer:insertBroadcast(inParam)
    local tableBg = self:getUI("bg.bg1.rcdList")
    local bgH = tableBg:getContentSize().height

    self:getUI("bg.bg1.Label_53"):setVisible(false)

    if #self._data["notice"] < 4 then
        --插入 / 替换 / 当前显示移出替换
        local maxNum = #self._useCell
        local replaceId = tonumber(inParam)

        local cell = self:cellAtIndex(replaceId)

        cell:setPosition(3, bgH - cell:getContentSize().height * (maxNum + 1))
        cell.index = maxNum
        tableBg:addChild(cell)
        if cell.isRetain == 1 then 
        	cell.isRetain = 0
        	cell:release()
        end       
        self._runDataIndex = #self._useCell 
    end
end

function ACAwakenLimitTimeLayer:scheduleUpdate(time)
    if #self._data["notice"] < 4 then return end

    local tableBg = self:getUI("bg.bg1.rcdList")
    local bgH = tableBg:getContentSize().height
    local test  = 0

    local moveY = 40 * time

    local firstCell = self._useCell[1]
    if firstCell ~= nil then 
        if firstCell:getPositionY() >= bgH then 
            firstCell:retain()
            firstCell:removeFromParent()
            table.remove(self._useCell, 1)
            table.insert(self._freeCell, firstCell)
        end
    end
    local lastCell = self._useCell[#self._useCell]
    if lastCell ~= nil and lastCell:getPositionY() + moveY >= 0  then 
        if self._runDataIndex + 1 > #self._data["notice"] then 
            self._runDataIndex = 0
        end
        self._runDataIndex = self._runDataIndex + 1
        local cell = self:cellAtIndex(self._runDataIndex)
        cell.index = self._runDataIndex
        cell:setPositionY(lastCell:getPositionY() - cell:getContentSize().height)
        tableBg:addChild(cell)
	    if cell.isRetain == 1 then 
        	cell.isRetain = 0
        	cell:release()
        end  
    end

    for k,v in pairs(self._useCell) do
        v:setPositionY(v:getPositionY() + moveY)
    end
end


function ACAwakenLimitTimeLayer:cellAtIndex(inIndex)
    local cellData = self._data["notice"][inIndex]
    if cellData == nil then return nil end

    local cell
    if #self._freeCell > 0 then 
        cell = self._freeCell[#self._freeCell]
        self:updateCell(cell, cellData)
        table.remove(self._freeCell, #self._freeCell)
        table.insert(self._useCell, cell)
        cell.isRetain = 1
    else
        cell = self:createCell(cellData)
        table.insert(self._useCell, cell)
    end
    -- local _, modf = math.modf(inIndex/2)
    -- if modf == 0 then
    --     cell:setBackGroundColor(cc.c3b(0, 100, 0))
    -- end
    return cell
end

function ACAwakenLimitTimeLayer:createCell(cellData)
	if cellData == nil then
		return
	end
	local item
	if self._item == nil then
		self._item = ccui.Layout:create()
		self._item:setAnchorPoint(cc.p(0, 0))
		self._item:setContentSize(264, 46)
		self._item:setBackGroundColorOpacity(0)
	    self._item:setBackGroundColorType(1)
	    self._item:setBackGroundColor(cc.c3b(100, 100, 0))
		item = self._item
	else
		item = self._item:clone()
	end

	--bg
	local cellBg = item:getChildByName("cellBg")
	if cellBg == nil then
		cellBg = ccui.ImageView:create("ac_awakenTL_cellBg.png",1)
	    cellBg:setPosition(cc.p(item:getContentSize().width * 0.5, item:getContentSize().height * 0.5)) --58
	    cellBg:setName("cellBg")	
		item:addChild(cellBg)
	end

	--richtext
	if item.richText ~= nil then 
        item.richText:removeFromParent()
        item.richText = nil
    end

	local showStr = lang("ac" .. self._acID .. "tips1_awake")
	showStr = string.gsub(showStr, "{$name}", cellData["name"] or "")
	showStr = string.gsub(showStr, "{$num}", cellData["num"] or 0)

	local richTxt = item:getChildByName("richTxt")
	richTxt = RichTextFactory:create(showStr, 220, 0)
    richTxt:setPixelNewline(true)
    richTxt:formatText()
    richTxt:setPosition(27 +richTxt:getContentSize().width/2, item:getContentSize().height * 0.5)
    richTxt:setName("richTxt")
    item.richText = richTxt
    item:addChild(richTxt)

	return item
end

function ACAwakenLimitTimeLayer:updateCell(item, cellData)
	if cellData == nil then
		return
	end

	--richText
	if item.richText ~= nil then 
        item.richText:removeFromParent()
        item.richText = nil
    end

    local showStr = lang("ac" .. self._acID .. "tips1_awake")
	showStr = string.gsub(showStr, "{$name}", cellData["name"] or "")
	showStr = string.gsub(showStr, "{$num}", cellData["num"] or 0)

	local richTxt = item:getChildByName("richTxt")
	richTxt = RichTextFactory:create(showStr, 220, 0)
    richTxt:setPixelNewline(true)
    richTxt:formatText()
    richTxt:setPosition(27 +richTxt:getContentSize().width/2, item:getContentSize().height * 0.5)
    richTxt:setName("richTxt")
    item.richText = richTxt
    item:addChild(richTxt)
end

return ACAwakenLimitTimeLayer
