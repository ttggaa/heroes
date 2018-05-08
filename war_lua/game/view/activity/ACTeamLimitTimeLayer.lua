--[[
    Filename:    ACTeamLimitTimeLayer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-04-08 17:38
    Description: 限时兵团活动
--]]

--功能开发备忘
--[[
---------【前端】
1.在ACTeamLimitTimeLayer 	--UI_INFO 配置新活动id对应的资源
2.DialogFlashLTResult 		--uiInfo  配置新活动id对应的资源
3.主界面icon / 界面图 / 技能演示动画 (注：资源名需要跟活动id匹配着命名)

---------【测试着重点】
1.跑马灯
	(1--抽到整卡描述 2--招募描述)
2.主界面红点
	(显示条件：1--免费次数 or 2--宝箱未领)
3.抽卡恭喜获得界面：
	(1--碎片显示 2--整卡显示)
4.兵团界面
	(1--需要招募 2--直接发兵团)

---------【运营/策划】
1.limitTeamConfig
2.limitTeamBox：配置宝箱奖励
3.lang表：跑马灯描述(2个) + ac1003tips1/ac1003tips2/ac1003tips3/ac1003rule + 技能演示描述
]]


local ACTeamLimitTimeLayer = class("ACTeamLimitTimeLayer", BasePopView)

--新活动修改处
local UI_INFO = {
	[1001] = {  --大天使
		teamId = 107, 
		priviewBtn = {510, 382},
		titlePos = {713, 424},
		frame = {fType = 1, fSize = {153, 333}, fAnchor = {76, 105}},   --fType类型 / fSize宽高 / fAnchor九宫格分割点 / fPos位置
		role = {scale = 0.68, pos = {300, 260}},
		skill = {
			mcName = "tianshiyanshi_tianshiyanshi"}
	},
	[1002] = { 	--娜迦
		teamId = 606, 
		priviewBtn = {83, 400},
		titlePos = {714, 387},
		frame = {fType = 1, fSize = {175, 333}, fAnchor = {87, 140}},
		role = {scale = 1, pos = {274, 310}},
		skill = {
			mcName = "najiajinengyanshi_najiajinengyanshi"}
	},
	[1003] = {	--比蒙
		teamId = 407, 
		priviewBtn = {73, 412},
		titlePos = {715, 390},
		frame = {fType = 2, fSize = {349, 368}, fAnchor = {174, 132}, fPos = {714, 298}},
		role = {scale = 0.72, pos = {337, 240}},
		skill = {
			mcName = "bimengjinengyanshi_bimengjinengyanshi"}
	},
	[1004] = { 	--骨龙
		teamId = 307, 
		priviewBtn = {73, 412},
		titlePos = {715, 390},
		frame = {fType = 1, fSize = {176, 345}, fAnchor = {111, 100}},
		role = {scale = 0.65, pos = {315, 250}},
		skill = {
			mcName = "gulongjinengyanshi_gulongjinengyanshi"}
	},

	[1005] = { 	--大恶魔
		teamId = 507, 
		priviewBtn = {73, 412},
		titlePos = {714, 386},  
		frame = {fType = 1, fSize = {171, 350}, fAnchor = {111, 140}, fPos = {0, 8}},
		role = {scale = 0.55, pos = {300, 260}, isHideBg = true},
		skill = {
			mcName = "demojinengyanshi_daemojinengyanshi"}
	},

	[1006] = { 	--圣骑士
		teamId = 108, 
		priviewBtn = {73, 412},
		titlePos = {714, 396},  
		frame = {fType = 2, fSize = {347, 390}, fAnchor = {347, 145}, fPos = {714, 310}},
		role = {scale = 0.7, pos = {335, 235}},
		skill = {
			mcName = "shengtangwushiyanshi_shengtangwushiyanshi"}
	},

	[1007] = { 	--黑龙
		teamId = 707,
		priviewBtn = {73, 412},
		titlePos = {713, 391},  
		frame = {fType = 1, fSize = {179, 345}, fAnchor = {110, 120}, fPos = {0, 0}},
		role = {scale = 0.75, pos = {303, 235}},
		skill = {
			mcName = "heilongyanshi_heilongyanshi"}
	},

	[1008] = { 	--泰坦
		teamId = 607, 
		priviewBtn = {73, 412},
		titlePos = {713, 390},  
		frame = {fType = 2, fSize = {504, 400}, fAnchor = {250, 160}, fPos = {727, 317}},
		role = {scale = 0.8, pos = {223, 265}},
		skill = {
			mcName = "taitanyanshi_taitanyanshi"}
	},

	[1009] = { 	--绿龙
		teamId = 207, 
		priviewBtn = {73, 412},
		titlePos = {713, 394},  
		frame = {fType = 2, fSize = {372, 365}, fAnchor = {250, 118}, fPos = {717, 295}},
		role = {scale = 0.8, pos = {223, 265}},
		skill = {
			mcName = "lvlongjinengyanshi_lvlongjinengyanshi"}
	},

	[1010] = { 	--蛮牛
		teamId = 805, 
		priviewBtn = {73, 412},
		titlePos = {713, 394},  
		frame = {fType = 2, fSize = {373, 375}, fAnchor = {250, 125}, fPos = {702, 302}},
		role = {scale = 0.8, pos = {223, 145}},
		skill = {
			mcName = "manniujinengyanshi_manniujinengyanshi"}

	},
}

function ACTeamLimitTimeLayer:ctor(param)
	ACTeamLimitTimeLayer.super.ctor(self)
	self._teamTLModel = self._modelMgr:getModel("LimitTeamModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._teamModel = self._modelMgr:getModel("TeamModel")

	self._callback = param.callback
	self._acID = param.acId
	self._freeCell = {}
    self._useCell = {}
    self._runDataIndex = 0
    self._refeshTimes = 0

    self._uiInfo = UI_INFO[self._acID]
    self._uiInfo["skill"]["teamId"] = self._uiInfo["teamId"]
    self._uiInfo["skill"]["teamName"] = lang("TEAM_" .. self._uiInfo["teamId"])
    self._uiInfo["skill"]["bgImg"] = "skillPreviewBg.png"
end

function ACTeamLimitTimeLayer:getAsyncRes()
    return 
    {
        {"asset/ui/activityTeamTL.plist", "asset/ui/activityTeamTL.png"},
        {"asset/ui/activityTeamTL1.plist", "asset/ui/activityTeamTL1.png"},
        {"asset/ui/activityTeamTL2.plist", "asset/ui/activityTeamTL2.png"},
    }
end

function ACTeamLimitTimeLayer:onInit()
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
	bgImg:loadTexture("asset/bg/ac_teamTL_bg.png")
	bgImg:setVisible(true)

	--priviewBtn
	local priviewBtn = self:getUI("bg.bg1.priviewBtn")
	priviewBtn:setPosition(self._uiInfo["priviewBtn"][1], self._uiInfo["priviewBtn"][2])
	self:registerClickEvent(priviewBtn, function()
		local teamData = self._teamModel:getTeamAndIndexById(self._uiInfo["teamId"])
		local viewConst = require "game.view.formation.NewFormationIconView"
		if teamData == nil then  --未招募
			self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = viewConst.kIconTypeLocalTeam, iconId = self._uiInfo["teamId"]}, true)
		else
			self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = viewConst.kIconTypeTeam, iconId = self._uiInfo["teamId"]}, true)
		end
		end)

	--roleImg
    local teamD = tab:Team(self._uiInfo["teamId"])
	local lihui = string.sub(teamD["art1"], 4, string.len(teamD["art1"]))
	local res = "asset/uiother/team/t_" .. lihui .. ".png"
	local roleImg = self:getUI("bg.bg1.roleImg")
	roleImg:loadTexture(res)
	roleImg:setPosition(self._uiInfo["role"]["pos"][1], self._uiInfo["role"]["pos"][2])
	
	self:getUI("bg.bg1.Label_53"):setString("")
	local rcdTitle = self:getUI("bg.bg1.rcdTitle")
	rcdTitle:setString(lang("ac" .. self._acID .. "title"))
	rcdTitle:setPosition(self._uiInfo["titlePos"][1], self._uiInfo["titlePos"][2])
	self:getUI("bg.bg1.recruit1.freeTip"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

	local countStr = self:getUI("bg.bg1.countStr")
	countStr:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local countNum = self:getUI("bg.bg1.countNum")
	countNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local Label_59 = self:getUI("bg.bg1.scoreBg.Label_59")
	Label_59:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	local Label_60 = self:getUI("bg.bg1.scoreBg.Label_60")
	Label_60:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	--skill des
	self:getUI("bg.bg1.Image_55"):loadTexture("ac_teamTL1_img2_" .. self._acID .. ".png", 1)
	self:getUI("bg.bg1.Image_100"):loadTexture("ac_teamTL1_img1_" .. self._acID .. ".png", 1)

	--roleBg
	for i=1, 2 do
		local roleBg = self:getUI("bg.bg1.roleBg" .. i)
		if self._uiInfo["role"]["isHideBg"] then
			roleBg:setVisible(false)
		else
			if self._uiInfo["role"]["bgImg"] then
				roleBg:loadTexture(self._uiInfo["role"]["bgImg"] .. ".png", 1)
			else
			    local sfc = cc.SpriteFrameCache:getInstance()
			    local resName = "ac_teamTL1_roleBg" .. self._acID .. ".png"
			    if not sfc:getSpriteFrameByName(resName) then
			        resName = "ac_teamTL1_roleBg1003.png"			        
			    end
			    roleBg:loadTexture(resName, 1)				
			end
			
			if i == 1 then
				roleBg:setPosition(321 - roleBg:getContentSize().width * 0.5, 272)
			else
				roleBg:setPosition(321 + roleBg:getContentSize().width * 0.5, 272)
			end
		end
	end

	--frame
	local frame = self._uiInfo["frame"]
	if frame["fPos"] == nil then
		frame["fPos"] = {0, 0}
	end
	if frame["fType"] == 1 then  		--宽一半 高需要拉九宫
		for i=1, 2 do
			local frameImg = self:getUI("bg.bg1.frame" .. i)
			frameImg:loadTexture("ac_teamTL1_bg" .. self._acID .. ".png", 1)
			frameImg:setScale9Enabled(true)
			frameImg:setCapInsets(cc.rect(frame["fAnchor"][1], frame["fAnchor"][2], 1, 1))
			frameImg:ignoreContentAdaptWithSize(false)
			frameImg:setContentSize(cc.size(frame["fSize"][1], frame["fSize"][2]))
			
			if i == 1 then
				frameImg:setPosition(714 - frameImg:getContentSize().width * 0.5 + frame["fPos"][1], 283 + frame["fPos"][2])
			else
				frameImg:setPosition(714 + frameImg:getContentSize().width * 0.5 + frame["fPos"][1], 283 + frame["fPos"][2])
			end
		end

	elseif frame["fType"] == 2 then 	--宽全 高需要拉九宫
		local frameImg = self:getUI("bg.bg1.frame1")
		frameImg:loadTexture("ac_teamTL1_bg" .. self._acID .. ".png", 1)
		frameImg:setScale9Enabled(true)
		frameImg:setCapInsets(cc.rect(frame["fAnchor"][1], frame["fAnchor"][2], 1, 1))
		frameImg:ignoreContentAdaptWithSize(false)
		frameImg:setPosition(frame["fPos"][1], frame["fPos"][2])
		frameImg:setContentSize(cc.size(frame["fSize"][1], frame["fSize"][2]))

		local frameImg2 = self:getUI("bg.bg1.frame2")
		frameImg2:setVisible(false)
	end

	--ruleBtn
	local ruleBtn = self:getUI("bg.bg1.ruleBtn")
	self:registerClickEvent(ruleBtn, function()
		self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("ac" .. self._acID .. "rule")},true)
		end)

	--技能演示
	local playBtn = self:getUI("bg.bg1.playBtn")
	self:registerClickEvent(playBtn, function()  
		self._viewMgr:showDialog("global.GlobalPlaySkillDialog", self._uiInfo["skill"],true)
	end)

	-- 换luckyCoin icon
	self._isUseLuck = self._userModel:drawUseLuckyCoin()
	if self._isUseLuck then
		self:getUI("bg.bg1.recruit1.icon"):loadTexture("globalImageUI_luckyCoin.png",1)
		self:getUI("bg.bg1.recruit1.icon"):setScale(0.8)
		self:getUI("bg.bg1.recruit2.icon"):loadTexture("globalImageUI_luckyCoin.png",1)
		self:getUI("bg.bg1.recruit2.icon"):setScale(0.8)
	end
	

	local closeBtn = self:getUI("bg.bg1.closeBtn")
	self:registerClickEvent(closeBtn, function() 
		if self._callback then
			self._callback()
		end
		self:close()
		UIUtils:reloadLuaFile("activity.ACTeamLimitTimeLayer")
		UIUtils:reloadLuaFile("LimitTeamModel", "game.model.")
		UIUtils:reloadLuaFile("flashcard.DialogFlashLTResult")
		end)

	--招募1次
	self:registerClickEventByName("bg.bg1.recruit1.btn", function()
		self:recruitBtnClick(1)
		end)

	--招募10次
	self:registerClickEventByName("bg.bg1.recruit2.btn", function() 
		self:recruitBtnClick(10)
	end)

	--model监听
    self:setListenReflashWithParam(true)
    self:listenReflash("LimitTeamModel", self.insertBroadcast)

    --获取宝箱奖励数据
    self._boxRewards = self._teamTLModel:getRewardListByIntIndex()

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

function ACTeamLimitTimeLayer:recruitBtnClick(inType)
	local curTime = self._userModel:getCurServerTime()
    local endTime = self._data["endTime"] or 0
    if curTime >= endTime then
    	self._viewMgr:showTip("限时招募活动已结束")
    	return
    end

	local sysTLConfig = tab.limitTeamConfig
	local needGem
	if inType == 1 then
		needGem = sysTLConfig["cost1"]["num"]
	else
		needGem = sysTLConfig["cost10"]["num"]
	end
	
	local isFree = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(51) or 0   --今日已领取次数
	local curCoin = 0
	if self._isUseLuck then
		curCoin = self._userModel:getData().luckyCoin or 0
	else
		curCoin = self._userModel:getData().gem or 0
	end
	if not (isFree == 0 and inType == 1 ) and curCoin < needGem then
		-- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
		--     local viewMgr = ViewManager:getInstance()
		--     viewMgr:showView("vip.VipView", {viewType = 0})
		-- end})
		DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = needGem - curCoin})
        end})
        return
	end

	self._serverMgr:sendMsg("LimitTeamsServer", "limitTeamLottery", {num = inType}, true, {}, function(result, errorCode)
		if inType == 1 then   --免费不消失，不必现bug，先手动修改
			self._modelMgr:getModel("PlayerTodayModel"):setDayInfo(51, 1)
		end
		
		self:refreshCostNum()			
		self._viewMgr:showDialog("flashcard.DialogFlashLTResult",{ 
			awards = result.reward or {},
			showType = "limitTeam",   --限时兵团
			costType = "gem",
			costNum = needGem or 0,
			buyNum = inType,
			curData = self._data,
			acId = self._acID,
			callback = function() self:reflashUI() end},true)
		end)
end

function ACTeamLimitTimeLayer:reflashUI()
	local roleImg = self:getUI("bg.bg1.roleImg")
	if self._uiInfo["role"]["scale"] then
		roleImg:setScale(self._uiInfo["role"]["scale"])
	end

	if self._refeshTimes < 2 then
		self._refeshTimes = self._refeshTimes + 1
	end
	
	self._data = self._teamTLModel:getData()
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

function ACTeamLimitTimeLayer:refreshCostNum()
	local sysTLConfig = tab.limitTeamConfig
	--免费次数
	local isFree = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(51) or 0   --今日已领取次数
	if isFree == 0 then
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

function ACTeamLimitTimeLayer:setPercentBar()
	local sysTLConfig = tab.limitTeamConfig
	local sysLimitTeamBox = self._boxRewards
	local curScore = self._data["boxPt"] or 0

	local needPercent = {0, 14, 28, 42, 56, 70, 84, 100}
	local needScore = {
		[1] = 0, 
		[2] = sysLimitTeamBox[1]["score"],
		[3] = sysLimitTeamBox[2]["score"],
		[4] = sysLimitTeamBox[3]["score"],
		[5] = sysLimitTeamBox[4]["score"],
		[6] = sysLimitTeamBox[5]["score"],
		[7] = sysLimitTeamBox[6]["score"],
		[8] = sysLimitTeamBox[7]["score"],
	}
	local disPer = {14, 14, 14, 14, 14, 14, 16}
	local disScore = {
		[1] = sysLimitTeamBox[1]["score"],
		[2] = sysLimitTeamBox[2]["score"] - sysLimitTeamBox[1]["score"],
		[3] = sysLimitTeamBox[3]["score"] - sysLimitTeamBox[2]["score"],
		[4] = sysLimitTeamBox[4]["score"] - sysLimitTeamBox[3]["score"],
		[5] = sysLimitTeamBox[5]["score"] - sysLimitTeamBox[4]["score"],
		[6] = sysLimitTeamBox[6]["score"] - sysLimitTeamBox[5]["score"],
		[7] = sysLimitTeamBox[7]["score"] - sysLimitTeamBox[6]["score"],
	}

	local maxId = 8
	for i=1, 7 do
		local needScore = sysLimitTeamBox[i]["score"]
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

	--进度条动画
	if clipNode._barAnim == nil then
		local mcNode = ccui.Layout:create()
		mcNode:setPosition(-15, 0)
		clipNode:addChild(mcNode, 10)

	    local mc1 = mcMgr:createViewMC("juntuanzhaomujindutiao_itemeffectcollection", true)
	    mc1:setPosition(374, 8)
	    mcNode:addChild(mc1, 10)

	    clipNode._barAnim = mc1
	end
end

function ACTeamLimitTimeLayer:setCountTime()
    local countStr = self:getUI("bg.bg1.countStr")
    countStr:setFontSize(18)
    local countNum = self:getUI("bg.bg1.countNum")
    countNum:setFontSize(18)

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

function ACTeamLimitTimeLayer:setRewards()
	local sysLimitTeamBox = self._boxRewards
	local rwdList = self._data["rewardList"] or {}
	local rwdType = {1, 1 ,1, 2, 2, 3, 3}

	for i=1,7 do
		local rwd = self:getUI("bg.bg1.rwd"..i)
		local sysIndex = sysLimitTeamBox[i]["index"]

		--num
		local rwdNum = rwd:getChildByFullName("numBg.num")
		rwdNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		rwdNum:setString(sysLimitTeamBox[i].score)

	    local itemId = sysLimitTeamBox[i]["reward"][1][2]
	    local itemNum = sysLimitTeamBox[i]["reward"][1][3]
	    local itemData = tab:Tool(itemId)
        local param = {itemId = itemId, num = sysLimitTeamBox[i].score, itemData = itemData}

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
				local boxAnim = mcMgr:createViewMC("baoxiang" .. rwdType[i] .. "_baoxiang", true)
			    boxAnim:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2)
			    icon._boxAnim = boxAnim
			    icon:addChild(boxAnim)
			end
			icon._boxAnim:setVisible(true)
		end
	
        --isGet  1积分不足 2未领取 3已领取
        local curScore = self._data["boxPt"]
    	local needScore = sysLimitTeamBox[i].score
		if rwdList[tostring(sysIndex)] and rwdList[tostring(sysIndex)] == 1 then   --3已领取
			local img = "box_"..rwdType[i].."_p.png"
			icon:loadTextures(img, img, img, 1)
			icon:setOpacity(255)
			icon:setScale(0.9)

			icon._lingqu = 3
			icon._isJuxing = true

		elseif curScore >= needScore and rwdList[tostring(sysIndex)] ~= 1 then  --2未领取
			local img = "box_"..rwdType[i].."_n.png"
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
			local img = "box_"..rwdType[i].."_n.png"
			icon:loadTextures(img, img, img, 1)
			icon:setOpacity(255)
			icon:setScale(1)

			icon._lingqu = 1
			icon._isJuxing = false
		end

        self:registerClickEvent(icon, function()
        	if icon._lingqu == 1 then
        		DialogUtils.showGiftGet( {
				    gifts = sysLimitTeamBox[i]["reward"],
				    viewType = 1,
				    canGet = false, 
				    des = "领取奖励需要"..sysLimitTeamBox[i]["score"].."积分，请继续加油哦~",
				    callback = function()  
				    end} )

        	elseif icon._lingqu == 3 then   --不能领取
        		DialogUtils.showGiftGet( {
				    gifts = sysLimitTeamBox[i]["reward"],
				    viewType = 1,
				    canGet = false, 
				    des = "领取奖励需要"..sysLimitTeamBox[i]["score"].."积分，请继续加油哦~",
				    btnTitle = "已领取", 
				    callback = function()  
				    end} )

        	else
				local curTime = self._userModel:getCurServerTime()
			    local endTime = self._data["endTime"] or 0
			    if curTime >= endTime then
			    	self._viewMgr:showTip("限时招募活动已结束")
			    	return
			    end
        		self._serverMgr:sendMsg("LimitTeamsServer", "getLimitTeamBox", {id = sysIndex}, true, {}, function(result, errorCode)
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

function ACTeamLimitTimeLayer:createBroadcast()
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

function ACTeamLimitTimeLayer:insertBroadcast(inParam)
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

function ACTeamLimitTimeLayer:scheduleUpdate(time)
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


function ACTeamLimitTimeLayer:cellAtIndex(inIndex)
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

function ACTeamLimitTimeLayer:createCell(cellData)
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
		cellBg = ccui.ImageView:create("ac_teamTL_textBg.png",1)
	    cellBg:setPosition(cc.p(item:getContentSize().width * 0.5, item:getContentSize().height * 0.5)) --58
	    cellBg:setName("cellBg")	
		item:addChild(cellBg)
	end

	--特效
	local effect = item:getChildByName("effect")
	if effect == nil then
		effect = mcMgr:createViewMC("guangjunzhaomu_zhaomu", true, false)
		effect:setPosition(cc.p(item:getContentSize().width * 0.5, item:getContentSize().height * 0.5))
	    effect:setName("effect")	
		item:addChild(effect)
		
		if cellData["type"] == 1 then  --整卡
			effect:setVisible(true)
		else
			effect:setVisible(false)
		end
	end

	--richtext
	if item.richText ~= nil then 
        item.richText:removeFromParent()
        item.richText = nil
    end

	local showStr = "[color=fa921a,outlinecolor=3c1e0a,fontsize=16]空[-]"
	if cellData["type"] == 1 then   	--整卡
		showStr = lang("ac" .. self._acID .. "tips3")
	elseif cellData["type"] == 2 then  	--碎片
		showStr = lang("ac" .. self._acID .. "tips1")
	elseif cellData["type"] == 3 then  	--招募
		showStr = lang("ac" .. self._acID .. "tips2")
	end
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

function ACTeamLimitTimeLayer:updateCell(item, cellData)
	if cellData == nil then
		return
	end

	--effect
	local effect = item:getChildByName("effect")
	if cellData["type"] == 1 then  --整卡
		effect:setVisible(true)
	else
		effect:setVisible(false)
	end

	--richText
	if item.richText ~= nil then 
        item.richText:removeFromParent()
        item.richText = nil
    end

    local showStr = "[color=fa921a,outlinecolor=3c1e0a,fontsize=16]空{$name}{$num}[-]"
	if cellData["type"] == 1 then   	--整卡
		showStr = lang("ac" .. self._acID .. "tips3")
	elseif cellData["type"] == 2 then  	--碎片
		showStr = lang("ac" .. self._acID .. "tips1")
	elseif cellData["type"] == 3 then  	--招募
		showStr = lang("ac" .. self._acID .. "tips2")
	end
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

return ACTeamLimitTimeLayer
