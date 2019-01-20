--
-- Author: huangguofang
-- Date: 2018-08-01 15:06:56
--

-- 祈愿layer
local AcLimitPrayBuyLayer = class("AcLimitPrayBuyLayer",BaseLayer)
function AcLimitPrayBuyLayer:ctor(params)
    self.super.ctor(self)
    -- parent=self,UIInfo = self._info,openId=self._openId
    self._parent = params.parent
    self._UIInfo = params.UIInfo or {}
    self._openId = params.openId
    self._acID = params.acId
    self._userModel = self._modelMgr:getModel("UserModel")
    self._limitPrayModel = self._modelMgr:getModel("LimitPrayModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function AcLimitPrayBuyLayer:onInit()
	self._acData 	 = self._limitPrayModel:getDataById(self._openId)
	self._prayConfig = tab.prayConfig
 	local teamId = self._UIInfo.teamId or 109
 	-- print("=============teamId======",teamId)
    self._staticTeamData = tab:Team(teamId)

    local raceFlag 		= self:getUI("bg.teamInfo.raceFlag")
    local teamName 		= self:getUI("bg.teamInfo.teamName")
    local teamDes 		= self:getUI("bg.teamInfo.teamDes")
    local zizhiTxt		= self:getUI("bg.teamInfo.zizhiTxt")
    local zhenyingTxt 	= self:getUI("bg.teamInfo.zhenyingTxt")
    local skillPlayBtn  = self:getUI("bg.teamInfo.skillPlayBtn")

    -- 兵模
    local teamBgImg  	= self:getUI("bg.teamBgImg")
    local art = self._staticTeamData["art"]
    self._actionList = {"stop","run","atk", "atk3"}
    if art then
    	HeroAnim.new(teamBgImg, art, self._actionList , function (mc)
	       	mc:play()
	       	mc:setScale(0.3)
	       	mc:setScaleX(-0.3)
	        mc:changeMotion("stop")
	        mc:setLocalZOrder(2)
	        mc:setPosition(180,0)
	        self._teamMc = mc
	    end, false, nil, nil, true)
    end
    
    self._scheduler = cc.Director:getInstance():getScheduler()
	self._scheduler1 = self._scheduler:scheduleScriptFunc(handler(self, self.actionUpdate), 5, false)
	--场景监听
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	if self._scheduler then
        		if self._scheduler1 then
        			self._scheduler:unscheduleScriptEntry(self._scheduler1)
        		end
        		self._scheduler = nil        		
        	end
        end
    end)

    -- 兵团例会
    local teamImg 		= self:getUI("bg.teamPanel.teamImg")
    local imgName = string.sub(self._staticTeamData["art1"], 4, string.len(self._staticTeamData["art1"]))
    teamImg:loadTexture("asset/uiother/team/t_"..imgName..".png")
    teamImg:setPosition(self._UIInfo.teamPos[1],self._UIInfo.teamPos[2])
    if self._UIInfo.scaleNum then
    	teamImg:setScale(self._UIInfo.scaleNum)
    end
    if self._UIInfo.isFlip then
    	teamImg:setFlippedX(true)
    end    
	local titleMc = mcMgr:createViewMC("lihuiguangxiao_xianshihuodong", true, false)
    titleMc:setPosition(190, 160)
    self:getUI("bg.teamPanel"):addChild(titleMc,3)

    -- 兵团信息
	local className = TeamUtils:getClassIconNameByTeamD(nil, "classlabel", self._staticTeamData)
	raceFlag:loadTexture(IconUtils.iconPath .. className .. ".png", 1)
	raceFlag:setScale(0.8)
	teamName:setString(lang(self._staticTeamData.name))
	teamDes:setString(lang("specialdes1_" .. teamId))
	local raceData = tab:Race(self._staticTeamData.race[1]) or {}
	zhenyingTxt:setString(lang(raceData.name))
    local zizhiStr = (tonumber(self._staticTeamData.zizhi)+12 == 16) and "指挥官" or tonumber(self._staticTeamData.zizhi)+12
    zizhiTxt:setString(zizhiStr)
    self:registerClickEvent(skillPlayBtn, function()  
		self._viewMgr:showDialog("global.GlobalPlaySkillDialog", self._UIInfo["skill"],true)
	end)

    -- 招募info
    self._freeTimeLable = self:getUI("bg.onceFreeTime")
    self._onceBtn 		= self:getUI("bg.onceBtn")
    self._fiveBtn 		= self:getUI("bg.fiveBtn")
    local txt 			= self:getUI("bg.fiveBtn.txt")
    local onceCost		= self:getUI("bg.onceCost")
    local fiveCost		= self:getUI("bg.fiveCost")
    self._onceCost = onceCost
    self._fiveCost = fiveCost
    onceCost:setString(self._prayConfig["cost1"]["value"])
	fiveCost:setString(self._prayConfig["cost5"]["value"])
    txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._onceBtn:enableOutline(cc.c4b(1, 67, 128, 255), 1) 
    self._onceBtn:setTitleFontSize(24)
    self._fiveBtn:enableOutline(cc.c4b(1, 67, 128, 255), 1) 
    self._fiveBtn:setTitleFontSize(24)
    registerClickEvent(self._onceBtn,function(sender)	    
    	self:sendPrayLotteryMsg(1)
    end)
    registerClickEvent(self._fiveBtn,function(sender)
	    self:sendPrayLotteryMsg(5) 
    end)
    self:updateCostColor()
	
	self:updateCountdown()
	self:initBoxPanel()

end

function AcLimitPrayBuyLayer:actionUpdate( )
	local index = math.random(1, 4)
	print("============index====",index)
	local actionStr = self._actionList[tonumber(index)]
	if self._teamMc then
	    self._teamMc:changeMotion(actionStr)
	end
end

function AcLimitPrayBuyLayer:updateCostColor( )
	local uData = self._userModel:getData()
	local luckyCoin = uData["luckyCoin"]
	if luckyCoin < self._prayConfig["cost1"]["value"] then
		self._onceCost:setColor(UIUtils.colorTable.ccUIBaseColor6)
	else		
		self._onceCost:setColor(UIUtils.colorTable.ccUIBaseColor1)
	end
	if luckyCoin < self._prayConfig["cost5"]["value"] then
		self._fiveCost:setColor(UIUtils.colorTable.ccUIBaseColor6)
	else
		self._fiveCost:setColor(UIUtils.colorTable.ccUIBaseColor1)
	end	
end

function AcLimitPrayBuyLayer:updateCountdown()
	if self._isAction then return end 
	local upFreeTime = self._acData["upFreeTime"] or 0
	local curTime = self._userModel:getCurServerTime()
	local time2 = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
	local time1 = time2
	if curTime < time2 then   --过零点判断
		time1 = time2 - 86400
	end
	if upFreeTime < time1 then
		self._freeTimeLable:setString("本次免费")
		self._freeTimeLable:setColor(UIUtils.colorTable.ccUIBaseColor2)
	else
		if curTime > time2 then   --过零点判断
			time1 = time2 + 86400 --下次免费时间
        else
            time1 = time2
		end
		self._freeTimeLable:setColor(UIUtils.colorTable.ccUIBaseColor1)

        --添加倒计时
        local currTime = self._userModel:getCurServerTime()
        local tempTime = time1 - currTime 
		if tempTime > 0 then
			self._isAction = true
		    local hour, min, sec, tempValue
		    tempTime = tempTime + 1
		    self._freeTimeLable:runAction(cc.RepeatForever:create(cc.Sequence:create(
		        cc.CallFunc:create(function()
		            tempTime = tempTime - 1
		            tempValue = tempTime

		            hour = math.floor(tempValue/3600)
		            tempValue = tempValue - hour*3600

		            min = math.floor(tempValue/60)
		            tempValue = tempValue - min*60

		            sec = math.fmod(tempValue, 60)
		            local showTime
		            if tempTime <= 0 then
		                self._isAction = false
						self._freeTimeLable:stopAllActions()
						self._freeTimeLable:setString("本次免费")
						self._freeTimeLable:setColor(UIUtils.colorTable.ccUIBaseColor2)
		            else
		               	showTime = string.format("%.2d:%.2d:%.2d", hour, min, sec)
		                self._freeTimeLable:setString(showTime)
                    end
		        end),cc.DelayTime:create(1))
		    ))
		else
            self._freeTimeLable:setString("")
		end
	end

end

function AcLimitPrayBuyLayer:initBoxPanel()
	local mcName = {
        [1] = "baoxiang1_baoxiang",
        [2] = "baoxiang2_baoxiang",
        [3] = "baoxiang2_baoxiang",
        [4] = "baoxiang3_baoxiang",
        [5] = "baoxiang3_baoxiang",
        [6] = "baoxiang3_baoxiang",
        [7] = "baoxiang3_baoxiang",
    }
    local normalImg = {
        [1] = "box_1_n",
        [2] = "box_2_n",
        [3] = "box_2_n",
        [4] = "box_3_n",
        [5] = "box_3_n",
        [6] = "box_3_n",
        [7] = "box_3_n",
    }
    local getImg = {
        [1] = "box_1_p",
        [2] = "box_2_p",
        [3] = "box_2_p",
        [4] = "box_3_p",
        [5] = "box_3_p",
        [6] = "box_3_p",
        [7] = "box_3_p",
    }

	local boxData = clone(tab.prayBox)
	local boxPt = self._acData.boxPt or 0
	local serverBox = self._acData.rewardList or {}

	local boxPanel = self:getUI("bg.boxPanel")
	-- boxPanel:removeAllChildren()
	self._proBar = self:getUI("bg.boxPanel.proBar")
	self._boxArr = {}

	local maxLen = 570
	self._maxScore = boxData[#boxData]["score"] or 100
	local posX = 0
	local boxD
	local itemId
	local imgName
	local score = 0
	local box
	local boxTxtBg
	local scoreTxt
	local getMc
	local lastPosX = 0
	for i=1,#boxData do
		boxD = boxData[i]
		score = boxD.score
		lastPosX = posX
        posX = score/self._maxScore*maxLen + 20
        print(i,"===========lastPosX,posX===",lastPosX,posX)
        if i > 1 and posX - lastPosX < 50 then
        	posX = lastPosX + 50
        end
		imgName = serverBox[tostring(boxD.id)] and getImg[i] or normalImg[i]
       	box = ccui.Button:create()
        box:loadTextures(imgName..".png",imgName..".png","",1)
        box:setScale(0.9)
        box:setPosition(posX,60)
        boxPanel:addChild(box,10)
        box.__id = boxD.id
        box.__normalImg = normalImg[i]
		box.__getImg =  getImg[i]     
        box.__reward = boxD.reward
        box.__needNum = score
        box.__isCanGet = (not serverBox[tostring(boxD.id)] and boxPt >= score)
        box.__showReward = not serverBox[tostring(boxD.id)]

        for k,v in pairs(box.__reward) do
        	if type(v[2]) == "string" then
        		v[2] = self._prayConfig[v[2]]["value"]
        	end
        end

        box:setOpacity(box.__isCanGet and 0 or 255)
        getMc = mcMgr:createViewMC(mcName[i], true,false)
        getMc:setPosition(38,32)
        getMc:setVisible(box.__isCanGet)
        box:addChild(getMc)
        local lightMc = mcMgr:createViewMC("baoxiangguang1_baoxiang", true,false)
        lightMc:setPosition(0,0)
        getMc:addChild(lightMc,100)
        box.__getMc = getMc

        boxTxtBg = ccui.ImageView:create()
        boxTxtBg:loadTexture("acLimitPray_box_txtBg.png",1)
        boxTxtBg:setPosition(posX,22)
        boxTxtBg:setScaleX(0.8)
        boxPanel:addChild(boxTxtBg,11)

        scoreTxt = ccui.Text:create()
        scoreTxt:setFontSize(16)
        scoreTxt:setFontName(UIUtils.ttfName)
        scoreTxt:setString(score)
        scoreTxt:setColor(cc.c4b(255,255,255,255))
        scoreTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        scoreTxt:setPosition(posX,20)
        boxPanel:addChild(scoreTxt,12)
        self._boxArr[i] = box

        registerClickEvent(box, function(sender)
            self:sendGetBoxMsg(sender)
        end)
	end
	
	self._proBar:setPercent(boxPt/self._maxScore * 100)

end

function AcLimitPrayBuyLayer:updateBoxPanel()
	local boxPt = self._acData.boxPt or 0
	self._proBar:setPercent(boxPt/self._maxScore * 100)
	local serverBox = self._acData.rewardList or {}
	for k,v in pairs(self._boxArr) do
		local box = v
		local id = box.__id
        local normalImg = box.__normalImg
		local getImg = box.__getImg
        local reward = box.__reward
        local needNum = box.__needNum
        local getMc = box.__getMc
		local imgName = serverBox[tostring(id)] and getImg or normalImg
        box:loadTextures(imgName..".png",imgName..".png","",1)

        box.__isCanGet = (not serverBox[tostring(id)] and boxPt >= needNum)
        box.__showReward = not serverBox[tostring(id)]
        box:setOpacity(box.__isCanGet and 0 or 255)
		getMc:setVisible(box.__isCanGet)
	end
end
-- 发送抽卡协议
function AcLimitPrayBuyLayer:sendPrayLotteryMsg(prayNum)
	
	local uData = self._userModel:getData()
	local luckyCoin = uData["luckyCoin"]
	local costNum = self._prayConfig["cost" .. prayNum]["value"]
	-- print("=================self._limitPrayModel:isOnceFreeById(self._openId)=====",self._limitPrayModel:isOnceFreeById(self._openId))

    if luckyCoin < costNum and not (prayNum == 1 and self._limitPrayModel:isOnceFreeById(self._openId)) then
		DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin",
            	inputNum = costNum - luckyCoin,
            	callback=function()
            		self:updateCostColor()
            	end})
        end})
		return
	end

	self._serverMgr:sendMsg("LimitPrayServer", "limitPrayLottery", {acId = self._openId,num=prayNum}, true, {}, function(result) 
		if not result.reward or table.nums(result.reward) == 0 then
			self:reflashUI()
			return 
		end
		self._viewMgr:showDialog("activity.acLimitPray.AcLimitPrayResultDialog",{ 
			awards = result.reward or {},
			costNum = costNum or 0,
			buyNum = prayNum,
			acId = self._acID,
			id = self._openId,
			callback = function() 
				print("================抽卡回调=========================")
				self:reflashUI()
			end},true)		
    end)
end

-- 领取积分宝箱
function AcLimitPrayBuyLayer:sendGetBoxMsg(sender)
	-- print("===============sender===",sender.__id)
	if sender.__isCanGet then
		self._serverMgr:sendMsg("LimitPrayServer", "getLimitPrayBox", {acId = self._openId,id=sender.__id}, true, {}, function(result) 
			self._acData 	 = self._limitPrayModel:getDataById(self._openId)
			self:updateBoxPanel()
			if result.reward then
	            DialogUtils.showGiftGet( {gifts = sender.__reward,notPop = false})
	        end
	    end)
	elseif sender.__showReward then
		if sender.__reward then
            DialogUtils.showGiftGet( 
            	{gifts = sender.__reward,
            	viewType = 1,
           		des = "积分达到" .. sender.__needNum .. "可获得"})
        end
    else
    	self._viewMgr:showTip("奖励已领取")
	end
end
-- 接收自定义消息
function AcLimitPrayBuyLayer:reflashUI(data)
	print("===================reflashUI=================")
	self._acData 	 = self._limitPrayModel:getDataById(self._openId)
	self:updateCountdown()
	self:updateBoxPanel()
	self:updateCostColor()
	if self._parent and self._parent.updatePrayInfo then
		print("==============updatePrayInfo====")
		self._parent:updatePrayInfo()
	end
end

return AcLimitPrayBuyLayer