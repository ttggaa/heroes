--[[
    Filename:    CrossGodWarView.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2018-04-23 17:39:22
    Description: File description
--]]

local CrossGodWarView = class("CrossGodWarView", BaseView)

local tc = cc.Director:getInstance():getTextureCache()

local stateCode = {
	[1] = 1,--当前赛季已经结束,未到下一赛季报名时间。-------------
	[2] = 2,--当前赛季报名时间。-------------
	[3] = 3,--选拔赛准备阶段。可选择参赛阵容，不能修改布阵。-------------
	[4] = 4,--选拔赛战斗，可以看录像。-------------
	[5] = 5,--选拔赛准备阶段，无法操作。-------------
	[6] = 6,--64强赛准备阶段，可以调整布阵。-------------
	[7] = 7,--64强淘汰赛准备阶段，选择阵容。-------------
	[8] = 8,--64强淘汰赛，所有人可以看录像。-------------
	[9] = 9,--8强淘汰赛准备阶段，可以调整布阵。-------------
	[10] = 10,--8强淘汰赛准备阶段，可以竞猜+选择阵容。-------------
	[11] = 11,--8强淘汰赛正赛。
	[12] = 12,--未报名，显示赛程信息
}

function CrossGodWarView:ctor(data)
	CrossGodWarView.super.ctor(self)
	self._crossGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	
--	self._testIndex = 10
end

function CrossGodWarView:getViewShowState()
	local tbFightState = {
		[stateCode[1]] = { 0 },--当前赛季已经结束,未到下一赛季报名时间。
		[stateCode[2]] = { 1 },--当前赛季报名时间。
		[stateCode[3]] = { 2, 4, 6, 8, 10, 12, 14, 16, 18, 21, 23, 25, 27, 29, 31, 33, 35, 37 },--选拔赛准备阶段。可选择参赛阵容，不能修改布阵。
		[stateCode[4]] = { 3, 5, 7, 9, 11, 13, 15, 17, 19, 22, 24, 26, 28, 30, 32, 34, 36, 38 },--选拔赛战斗，可以看录像。
		[stateCode[5]] = { 20 },--选拔赛准备阶段，无法操作。
		[stateCode[6]] = { 39 },--64强赛准备阶段，可以调整布阵。
		[stateCode[7]] = { 40, 42, 44 },--64强淘汰赛准备阶段，选择阵容。
		[stateCode[8]] = { 41, 43, 45 },--64强淘汰赛，所有人可以看录像。
		[stateCode[9]] = { 46 },--8强淘汰赛准备阶段，可以调整布阵。
		[stateCode[10]] = { 47, 49, 51, 53, 55, 57, 59, 61 },--8强淘汰赛准备阶段，可以竞猜+选择阵容。
		[stateCode[11]] = { 48, 50, 52, 54, 56, 58, 60, 62 },--8强淘汰赛正赛。
		[stateCode[12]] = { -1 },--未报名显示赛程信息
	}
	local nowTime = self._userModel:getCurServerTime()
	local curOpenTime = self._crossGodWarModel:getCurOpenTime()
	local tabIndex = 0
	local stateStopTime
	for i,v in ipairs(tab.crossFightTime) do
		local beginTime = TimeUtils.getTimeStampWithWeekTime(curOpenTime, v.time1, v.week[1])
		local endTime = TimeUtils.getTimeStampWithWeekTime(curOpenTime, v.time2, v.week[2])
		if nowTime>=beginTime and nowTime<=endTime then
			stateStopTime = endTime
			tabIndex = i
			break
		end
	end
	local state
	for i,v in ipairs(tbFightState) do
		for warIndex,timeIndex in ipairs(v) do
			if timeIndex == tabIndex then
				state = i
				if state==3 or state==4 or (state>=6 and state<=11) then
					self._warIndex = warIndex
				end
				if i==1 then
					stateStopTime = self._crossGodWarModel:getNextOpenTime()
				end
				break
			end
		end
	end
	self._realState = state
	local myRank = self._crossGodWarModel:getMyRank()
	if myRank==-1 and (state>2 and state<6) then
		state = stateCode[12]
		stateStopTime = self._crossGodWarModel:getNextOpenTime()
	end
	
	
--	self._warIndex = 3
	return state,stateStopTime,tabIndex
end

function CrossGodWarView:onInit()
	--标题信息。
	local titleLab = self:getUI("titleBg.title")
	self._season = self._crossGodWarModel:getNowSeason() or 1
	titleLab:setString(string.format("第%s届 神主之战", self._season))
	self._titleLab = titleLab
    UIUtils:setTitleFormat(titleLab, 1)
	
	self:onInitBtn()
	self:onInitBulletData()
	
	self._rankNode = self:getUI("rankNode")
	self._rankNode:setVisible(false)
	
	self._timeTitleLab = self:getUI("titleBg.timeBg.fuTitle")
	self._countDownTimeLab = self:getUI("titleBg.timeLab")
	self:setLayerShowState()
	
	self._signUp = self._crossGodWarModel:getMyRank()~=-1
	
	self._nowState, self._stateEndTime = self:getViewShowState()
	self._countDownTimeLab:setVisible(self._nowState>=stateCode[6] and self._nowState<=stateCode[11])
	if self._nowState and self["onInitState"..self._nowState] then
		if self._nowState==stateCode[3] or self._nowState==stateCode[4] then
			self._serverMgr:sendMsg("CrossGodWarServer", "getGroupRival", {}, true, {}, function(result)
				self._needMatchAnim = false
				self["onInitState"..self._nowState](self)
			end)
		else
			self["onInitState"..self._nowState](self)
			self:update()
		end
	end
	
	self._updateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
		self:update(dt)
	end)
end

function CrossGodWarView:setLayerShowState(index)
	for i=1, 5 do
		local layer = self:getUI("bg.layer"..i)
		layer:setVisible(index and i==index)
	end
end

function CrossGodWarView:onInitBtn()--初始化功能button
	local ruleBtn = self:getUI("leftMenuNode.ruleBtn")
	local shopBtn = self:getUI("leftMenuNode.shopBtn")
	local yazhuBtn = self:getUI("leftMenuNode.yazhuBtn")
	local saichengBtn = self:getUI("leftMenuNode.saichengBtn")
	local mingdanBtn = self:getUI("leftMenuNode.mingdanBtn")
	local chatBtn = self:getUI("leftMenuNode.chatBtn")
	local liveBtn = self:getUI("btnbg.liveBtn")
	saichengBtn:setVisible(false)
	UIUtils:addFuncBtnName(ruleBtn, "规则", cc.p(ruleBtn:getContentSize().width/2,4))
	UIUtils:addFuncBtnName(shopBtn, "商店", cc.p(shopBtn:getContentSize().width/2,4))
	UIUtils:addFuncBtnName(yazhuBtn, "下注", cc.p(yazhuBtn:getContentSize().width/2,4))
	UIUtils:addFuncBtnName(saichengBtn, "赛程", cc.p(saichengBtn:getContentSize().width/2,4))
	UIUtils:addFuncBtnName(mingdanBtn, "名单", cc.p(mingdanBtn:getContentSize().width/2,4))
	UIUtils:addFuncBtnName(chatBtn, "聊天", cc.p(chatBtn:getContentSize().width/2,4))
--	UIUtils:addFuncBtnName(liveBtn, "直播", cc.p(chatBtn:getContentSize().width/2-3,4))
	liveBtn:setVisible(false)
	
	self:registerClickEvent(ruleBtn, function()
		UIUtils:reloadLuaFile("crossGod.CrossGodWarRuleDialog")
		self._viewMgr:showDialog("crossGod.CrossGodWarRuleDialog")
	end)
	
	self:registerClickEvent(shopBtn, function()
		self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "crossFight"}, true, {}, function(result)
            self._viewMgr:showView("shop.ShopView", {idx = 10})
        end)
	end)
	
	self:registerClickEvent(chatBtn, function()
		self._viewMgr:showDialog("chat.ChatView", {enterType = "godWar"}, true)
	end)

	self:setListenReflashWithParam(true)	
	self:listenReflash("ChatModel", self.listenChatUnread)
	self:listenReflash("CrossGodWarModel", self.listenCrossGodWarReflash)
end

function CrossGodWarView:listenChatUnread(inData)
	if inData == nil then
		return
	end

	local inData = string.split(inData, "_")
	if inData[1] ~= "priUnread" then
		return
	end
    local godWarUnread = self._modelMgr:getModel("ChatModel"):getUnread(ChatConst.CHAT_CHANNEL.GODWAR)
	local chatBtn = self:getUI("leftMenuNode.chatBtn")
	local redPoint = chatBtn:getChildByName("redPoint")
	if not redPoint then 
		redPoint = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
		redPoint:setPosition(chatBtn:getContentSize().width - 10, chatBtn:getContentSize().height - 10)
		redPoint:setName("redPoint")
		chatBtn:addChild(redPoint)
	end
	redPoint:setVisible(godWarUnread>0)
end

function CrossGodWarView:listenCrossGodWarReflash(inType)
	if self["reflash"..inType] then
		self["reflash" .. inType](self)
	end
end

function CrossGodWarView:reflashPushSignUp()
	self:onInitRankLayer()
end

function CrossGodWarView:onInitBulletData()--弹幕
	self:updateBulletBtnState()
	self:showBullet()
end

function CrossGodWarView:onInitWarTagState()
	local nowState = self._nowState
	local timeBg = self:getUI("titleBg.timeBg")
	local rightMenuNode = self:getUI("rightMenuNode")
	local tagBtn1 = self:getUI("rightMenuNode.xiaozuBtn")
	local tagBtn2 = self:getUI("rightMenuNode.zhengbaBtn")
	local tagBtn3 = self:getUI("rightMenuNode.guanjunBtn")
	local selectAnim = rightMenuNode:getChildByName("selectAnim")
	if not selectAnim then
		selectAnim = mcMgr:createViewMC("zhengbasaixuanzhong_zhandoukaiqi", true, false)
		selectAnim:setPosition(tagBtn1:getContentSize().width*0.5, tagBtn1:getContentSize().height*0.5-10)
		rightMenuNode:addChild(selectAnim, 5)
		selectAnim:setName("selectAnim")
		selectAnim:setVisible(false)
		rightMenuNode.selectAnim = selectAnim
	end
	
	self:registerClickEvent(tagBtn1, function()
		self:onInitState12()
		selectAnim:setPosition(tagBtn1:getPositionX(), tagBtn1:getPositionY()-10)
		local historyLayer = self:getUI("historyLayer")
		if historyLayer:isVisible() then
			local historyBtn = self:getUI("myWarPanel.historyBtn")
			historyBtn:setTitleText("对战历史")
			self._historyState = false
			historyLayer:setVisible(false)
		end
		tagBtn1:setTouchEnabled(false)
		tagBtn2:setTouchEnabled(true)
		tagBtn3:setTouchEnabled(true)
	end)
	self:registerClickEvent(tagBtn2, function()
		if self._nowState==stateCode[2] then
			if self._signUp then
				timeBg:setVisible(true)
				self:changeBgImage()
				self:onInitState2()
				selectAnim:setPosition(tagBtn2:getPositionX(), tagBtn2:getPositionY()-10)
			else
				self._viewMgr:showTip(lang("crossFight_tips_2"))
			end
		elseif self._nowState<stateCode[3] then
			self._viewMgr:showTip(lang("crossFight_tips_2"))
		elseif self._nowState==stateCode[6] then
			self._viewMgr:showTip(lang("crossFight_tips_20"))
		elseif (self._nowState>stateCode[6] and self._nowState<stateCode[12]) then
			self._viewMgr:showTip(lang("crossFight_tips_2"))
		else
			if self._signUp then
				timeBg:setVisible(true)
				self:changeBgImage()
				self["onInitState"..self._nowState](self)
				selectAnim:setPosition(tagBtn2:getPositionX(), tagBtn2:getPositionY()-10)
			else
				self._viewMgr:showTip(lang("crossFight_tips_10"))
			end
		end
		tagBtn1:setTouchEnabled(true)
		tagBtn2:setTouchEnabled(false)
		tagBtn3:setTouchEnabled(true)
	end)
	self:registerClickEvent(tagBtn3, function()
		if (self._nowState>stateCode[1] and self._nowState<stateCode[6]) or self._nowState==stateCode[12] then
			self._viewMgr:showTip(lang("crossFight_tips_3"))
		elseif self._nowState==stateCode[1] then
			self._warIndex = 8
			self:onInitLayer2_1()
			selectAnim:setPosition(tagBtn3:getPositionX(), tagBtn3:getPositionY()-10)
		else
			timeBg:setVisible(true)
			self:changeBgImage()
			self["onInitState"..self._nowState](self)
			selectAnim:setPosition(tagBtn3:getPositionX(), tagBtn3:getPositionY()-10)
		end
		tagBtn1:setTouchEnabled(true)
		tagBtn2:setTouchEnabled(true)
		tagBtn3:setTouchEnabled(false)
	end)
	
	if nowState==stateCode[1] then
		tagBtn1:getChildByName("titleLab"):setString("神主")
		self:registerClickEvent(tagBtn1, function()
			self:onInitState1()
			tagBtn1:setTouchEnabled(false)
			tagBtn2:setTouchEnabled(true)
			tagBtn3:setTouchEnabled(true)
		end)
		selectAnim:setPosition(tagBtn1:getPositionX(), tagBtn1:getPositionY()-10)
	elseif nowState==stateCode[2] then
		if self._signUp then
			tagBtn1:getChildByName("titleLab"):setString("赛程")
			selectAnim:setPosition(tagBtn2:getPositionX(), tagBtn2:getPositionY()-10)
		else
			tagBtn1:getChildByName("titleLab"):setString("神主")
			tagBtn1:setTouchEnabled(false)
			selectAnim:setPosition(tagBtn1:getPositionX(), tagBtn1:getPositionY()-10)
		end
	elseif nowState<=stateCode[5] then
		tagBtn1:getChildByName("titleLab"):setString("赛程")
		if self._signUp then
			selectAnim:setPosition(tagBtn2:getPositionX(), tagBtn2:getPositionY()-10)
		else
			selectAnim:setPosition(tagBtn1:getPositionX(), tagBtn1:getPositionY()-10)
		end
	elseif nowState<=stateCode[11] then
		tagBtn1:getChildByName("titleLab"):setString("赛程")
		selectAnim:setPosition(tagBtn3:getPositionX(), tagBtn3:getPositionY()-10)
	elseif nowState==stateCode[12] then
		tagBtn1:getChildByName("titleLab"):setString("赛程")
		selectAnim:setPosition(tagBtn1:getPositionX(), tagBtn1:getPositionY()-10)
	end
	selectAnim:setVisible(true)
end

function CrossGodWarView:onInitState1()--当前赛季结束，未到下一赛季报名时间
	local curTime = self._userModel:getCurServerTime()
	local nextTime = self._stateEndTime--下一届开启时间
	local str = string.format("下届开启:")
	if curTime<nextTime then
		str = str..TimeUtils.getTimeStringFont1(nextTime - curTime)
		self._timeTitleLab:setString(str)
	end
	local promotionBg = self:getUI("bg"):getChildByName("promotionBg")
	if promotionBg then
		promotionBg:removeFromParent()
	end
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(false)
	local yazhuBtn = self:getUI("leftMenuNode.yazhuBtn")
	local curTime = self._userModel:getCurServerTime()
	local weekday = tonumber(TimeUtils.date("%w", curTime))
	local ctime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
	local isOpen = self._crossGodWarModel:matchIsOpen()
	local isVisible = false
	if isOpen and isOpen == 1 then
	else
		if weekday == 5 and curTime >= ctime then
		else
			isVisible = true
		end
	end
	yazhuBtn:setVisible(isVisible)
	self:registerClickEvent(yazhuBtn, function()
		self._viewMgr:showDialog("crossGod.CrossGodWarSupportDialog",{callback = handler(self,self.getViewShowState)})
	end)
	self:onInitLayer4()
	self:onInitWarTagState()
	
	self._countDownTimeLab:setVisible(false)
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	buzhenPanel:setVisible(false)
end

function CrossGodWarView:onInitState2()--当前赛季报名时间。分已报名和未报名两种状态
	local weekStr = {
		[1] = "周一",
		[2] = "周二",
		[3] = "周三",
		[4] = "周四",
		[5] = "周五",
	}
	self._rankTableData = nil
	
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
	local groupLab = self:getUI("btnbg.groupLab")
	local sRank = self._crossGodWarModel:getMyRank()
	if sRank==-1 then
		self._signUp = false
		local rankLayer = self:getUI("rankPanel")
		rankLayer:setVisible(false)
		local myWarPanel = self:getUI("myWarPanel")
		myWarPanel:setVisible(false)
		
		self:changeBgImage("asset/bg/bg_crossGodWarSignUp.jpg")
		local startTime = string.sub(tab.crossFightTime[1].time1, 1, 5)
		local startWeek = tab.crossFightTime[1].week[1]
		startTime = weekStr[startWeek] .. startTime
		local endTime = string.sub(tab.crossFightTime[1].time2, 1, 5)
		local endWeek = tab.crossFightTime[1].week[2]
		endTime = weekStr[endWeek] .. tab:Setting("CROSS_FIGHT_GROUP_TIME").value
		local str = string.format("报名时间:%s~%s", startTime, endTime)
		self._timeTitleLab:setString(str)
		buzhenBtn:setTitleText("报 名")
		self:registerClickEvent(buzhenBtn, function()
			local openData = tab.systemOpen["CrossGodWar"]
			local userLevel = self._userModel:getPlayerLevel()
			local heroCount = self._modelMgr:getModel("HeroModel"):getHeroCount()
			local teamData = self._modelMgr:getModel("TeamModel"):getData()
			local teamCount = table.nums(teamData)
			if userLevel<tonumber(openData[1]) then
				self._viewMgr:showTip(lang(openData[3]))
			elseif teamCount<3 or heroCount<3 then
				self._viewMgr:showTip(lang("crossFight_tips_7"))
			else
				self._serverMgr:sendMsg("CrossGodWarServer", "signUp", {}, true, {}, function(res)
					self._serverMgr:sendMsg("CrossGodWarServer", "enter", {}, true, {}, function(res)
						self:onInitState2()
					end)
				end)
			end
		end)
		self:onInitLayer5()
		buzhenPanel:setVisible(true)
	else
		self:onInitRankLayer()
		self:onInitMyWarLayer()
		self:changeBgImage()
		self._signUp = true
		buzhenBtn:setTitleText("布 阵")
		self:registerClickEvent(buzhenBtn, function()
			local formationModel = self._modelMgr:getModel("FormationModel")
			self._viewMgr:showView("formation.NewFormationView", {
				formationType = formationModel.kFormationTypeCrossGodWar1,
				extend = {
					crossGodWarInfo = {endTime = self._stateEndTime}
				},
		        closeCallback = function (  )
		        	self["onInitState" .. self._nowState](self)
		        end})
		end)
		self:onInitLayer1()
		local curTime = self._userModel:getCurServerTime()
		local groupTime = TimeUtils.getTimeStampWithWeekTime(curTime, tab:Setting("CROSS_FIGHT_GROUP_TIME").value, 2)
		buzhenPanel:setVisible(curTime<=groupTime)
		groupLab:setVisible(curTime>groupTime)
	end
	self:onInitWarTagState()
end

function CrossGodWarView:onInitState3()--选拔赛准备阶段。可选择参赛阵容，不能修改布阵。
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
	local groupLab = self:getUI("btnbg.groupLab")
	groupLab:setVisible(false)
	self:onInitRankLayer()
	self:onInitMyWarLayer()
	self._signUp = true
	buzhenBtn:setTitleText("选择阵容")
	local prepareLab = buzhenPanel:getChildByName("prepareLab")
	prepareLab:setVisible(true)
	local timeLab = buzhenPanel:getChildByName("timeLab")
	timeLab:setVisible(true)
	timeLab:setPositionX(buzhenPanel:getChildByName("buzhenBtn"):getPositionX())
	self:registerClickEvent(buzhenBtn, function()
		self:showSelectFormationDialog()
	end)
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(false)
	if not buzhenPanel:isVisible() then
		buzhenPanel:setVisible(true)
	end
	self:onInitLayer1()
	self:onInitWarTagState()
end

function CrossGodWarView:onInitState4()--选拔赛战斗，可以看录像。
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
--	self._rankTableData = self._crossGodWarModel:getPlayerRankData()
	self:onInitRankLayer()
	self:onInitMyWarLayer()
	
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(true)
	
--	buzhenBtn:setTitleText("观 战")
	self:registerClickEvent(liveBtn, function()
		self._serverMgr:sendMsg("CrossGodWarServer", "getGroupBattleInfo", {round = self._warIndex<=9 and self._warIndex or self._warIndex-9}, true, {}, function(result)
			if result.reportKey then
				self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = result.reportKey}, true, {},  function(res)
					self:reviewTheBattle(res, 0)
				end)
			else
				self:reviewTheBattle(result, 0)
			end
		end)
	end)
	
--	local prepareLab = buzhenPanel:getChildByName("prepareLab")
--	prepareLab:setVisible(false)
--	local timeLab = buzhenPanel:getChildByName("timeLab")
--	timeLab:setString("进行中")
--	timeLab:setPositionX(buzhenBtn:getPositionX()-timeLab:getContentSize().width/2)
	buzhenPanel:setVisible(false)
	self:onInitLayer1()
	self:onInitWarTagState()
end

function CrossGodWarView:onInitState5()--选拔赛准备阶段，无法操作。
--	self:onInitState2()
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	buzhenPanel:setVisible(false)
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(false)
--	self._rankTableData = self._crossGodWarModel:getPlayerRankData()
	self:onInitRankLayer()
	self:onInitMyWarLayer()
	self:onInitLayer1()
	self:onInitWarTagState()
	
end

function CrossGodWarView:onInitState6()--64强赛准备阶段，可以调整布阵。
	local sRank = self._crossGodWarModel:getMyRank()
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
	buzhenBtn:setTitleText("布 阵")
	
	
	local historyLayer = self:getUI("historyLayer")
	historyLayer:setVisible(false)
	self._countDownTimeLab:setVisible(true)
	local prepareLab = buzhenPanel:getChildByName("prepareLab")
	prepareLab:setVisible(true)
	local timeLab = buzhenPanel:getChildByName("timeLab")
	timeLab:setPositionX(buzhenPanel:getChildByName("buzhenBtn"):getPositionX())
	
	self._timeTitleLab:setString(string.format("64强淘汰赛准备阶段"))
	
	self:registerClickEvent(buzhenBtn, function()
		local formationModel = self._modelMgr:getModel("FormationModel")
		self._viewMgr:showView("formation.NewFormationView", {
			formationType = formationModel.kFormationTypeCrossGodWar1,
			extend = {
				crossGodWarInfo = {endTime = self._stateEndTime}
			}})
	end)
	local rankPanel = self:getUI("rankPanel")
	local myWarPanel = self:getUI("myWarPanel")
	rankPanel:setVisible(false)
	myWarPanel:setVisible(false)
	self:onInitLayer2()
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(false)
	
	local myStateData = self._crossGodWarModel:getIsInMatchData()
	buzhenPanel:setVisible(myStateData.isPromoted==1)
	self:onInitWarTagState()
end

function CrossGodWarView:onInitState7()--64强淘汰赛准备阶段，选择阵容。
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	local prepareLab = buzhenPanel:getChildByName("prepareLab")
	prepareLab:setString("倒计时:")
	local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
	local liveBtn = buzhenPanel:getChildByName("buzhenBtn")
	buzhenBtn:setTitleText("选择阵容")
	self._timeTitleLab:setString(string.format("64强赛第%d轮准备阶段", self._warIndex))
	self:registerClickEvent(buzhenBtn, function()
		self:showSelectFormationDialog()
	end)
	self:onInitLayer2()
	local myStateData = self._crossGodWarModel:getIsInMatchData()
	buzhenPanel:setVisible(myStateData.isPromoted==1)

--- 检测玩家是否在当前比赛中
	local isVisible = self._crossGodWarModel:checkIsMyMatch(self._warIndex)
	buzhenPanel:setVisible(isVisible)
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(not isVisible)
	self:registerClickEvent(liveBtn, function()
		self._viewMgr:showTip(lang("crossFight_tips_12"))
	end)

	self:onInitWarTagState()
	self._countDownTimeLab:setVisible(true)
end

function CrossGodWarView:onInitState8()--64强淘汰赛，所有人可以看录像。
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	buzhenPanel:setVisible(false)
	self._timeTitleLab:setString(string.format("64强赛第%d轮激战中", self._warIndex))
	self:onInitLayer2()
	self:onInitWarTagState()

	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(true)
	-- 随机播放一场 or 播放自己比赛场次
	local isVisible,groupId,round,sort = self._crossGodWarModel:checkIsMyMatch(self._warIndex)
	
	self._countDownTimeLab:setVisible(true)
	-- 64to8 观战随机观看当前分组的一场比赛
	self:registerClickEvent(liveBtn, function()
		local g,r,s = 1,1,1
		local sortMax = {4,2,1}
		if isVisible then
			g = groupId
			r = round
			s = sort
		else
			g = self._64to8GroupId
			r = self._warIndex
			local max = sortMax[self._warIndex]
			s = math.random(1,max)
		end
		self._serverMgr:sendMsg("CrossGodWarServer", "getElisBattleInfo", {group = g, round = r, sort = s}, true, {}, function(result)
			if result.reportKey then
				self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = result.reportKey}, true, {},  function(result)
					self:reviewTheBattle(result, 0)
				end)
			else
				self:reviewTheBattle(result, 0)
			end
		end)
	end)
end

function CrossGodWarView:onInitState9()--8强淘汰赛准备阶段，可以调整布阵。
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
	buzhenBtn:setTitleText("布 阵")
	self._countDownTimeLab:setVisible(true)
	local warIndex = self._warIndex
	local titleText = string.format("8强第%d场赛准备阶段", self._warIndex)
	if warIndex>4 and warIndex<=6 then
		titleText = string.format("4强赛第%d场准备阶段", self._warIndex-4)
	elseif warIndex==7 then
		titleText = string.format("季军争夺赛准备阶段")
	else
		titleText = string.format("神主争夺赛准备阶段")
	end
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(false)
	self._timeTitleLab:setString(titleText)
	self:registerClickEvent(buzhenBtn, function()
		local formationModel = self._modelMgr:getModel("FormationModel")
		self._viewMgr:showView("formation.NewFormationView", {
			formationType = formationModel.kFormationTypeCrossGodWar1,
			extend = {
				crossGodWarInfo = {endTime = self._stateEndTime}
			}})
	end)
	self:onInitLayer2_1()
	local myStateData = self._crossGodWarModel:getIsInMatchData()
	buzhenPanel:setVisible(myStateData.isPromoted==2)
	self:onInitWarTagState()
end

function CrossGodWarView:onInitState10()--8强淘汰赛准备阶段，可以竞猜+选择阵容。
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	local prepareLab = buzhenPanel:getChildByName("prepareLab")
	prepareLab:setString("倒计时:")
	local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
	buzhenBtn:setTitleText("选择阵容")
	
	local titleText = string.format("8强赛第%d场准备阶段", self._warIndex)
	local warIndex = self._warIndex
	if warIndex>4 and warIndex<=6 then
		titleText = string.format("4强赛第%d场准备阶段", self._warIndex-4)
	elseif warIndex==7 then
		titleText = string.format("季军争夺赛准备阶段")
	else
		titleText = string.format("神主争夺赛准备阶段")
	end
	self._timeTitleLab:setString(titleText)
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(false)
	local yazhuBtn = self:getUI("leftMenuNode.yazhuBtn")
	yazhuBtn:setVisible(true)
	self:registerClickEvent(buzhenBtn, function()
		self:showSelectFormationDialog()
	end)

	self:registerClickEvent(yazhuBtn, function()
		self._viewMgr:showDialog("crossGod.CrossGodWarSupportDialog",{callback = handler(self,self.getViewShowState)})
	end)
	
	local _,_1,tabIndex = self:getViewShowState()
	local chang,powId,ju = self._crossGodWarModel:getPowIdAndChang(tabIndex)
	local callback2 =  function ()
		-- self._serverMgr:sendMsg("CrossGodWarServer", "getWarBattleInfo", {pow = powId , round = ju}, true, {}, function(result)
		-- 	if result.reportKey then
		-- 		self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = result.reportKey}, true, {},  function(res)
		-- 			self:reviewTheBattle(res, 0)
		-- 		end)
		-- 	else
		-- 		self:reviewTheBattle(result, 0)
		-- 	end
		-- end)
	end

	self:registerClickEvent(liveBtn, function()
		self._serverMgr:sendMsg("CrossGodWarServer", "getStakeInfo", {pow = powId,round = ju}, true, {},  function(result)
			self._viewMgr:showDialog("crossGod.CrossGodWarWatchBattleDialog",{callback1 = handler(self,self.getViewShowState),callback2 = callback2,stakeInfo = result,tabIndex = tabIndex})
		end)
	end)
	self:onInitLayer2_1()--复用layer2
	local myStateData = self._crossGodWarModel:getIsInMatchData()
	buzhenPanel:setVisible(myStateData.isPromoted==2)
	liveBtn:setVisible(not buzhenPanel:isVisible())
	self._countDownTimeLab:setVisible(true)
	self:onInitWarTagState()
	---------------  直播按钮 是否显示
	local data = self._crossGodWarModel:getEliminateFightData()
	local roundData = data[powId][ju]
	local isVisible = false
	if roundData then
		local p1 = roundData.player1.playerId
		local p2 = roundData.player2.playerId
		local p1Id = string.split(p1,"-")[2]
		local p2Id = string.split(p2,"-")[2]
		print("p1 ",p1Id)
		print("p2 ",p2Id)
		if (not p1Id) or (not p2Id) then
			print("玩家id未找到")
			return 
		end
		local id = self._modelMgr:getModel("UserModel"):getData()._id
		print("own ",id)
		if id == p1Id or id == p2Id then
			isVisible = true
		end	
	else
		print("8强对应数据没找到")	
	end
	buzhenPanel:setVisible(isVisible)
	liveBtn:setVisible(not isVisible)
end

function CrossGodWarView:onInitState11()--8强淘汰赛正赛。
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	buzhenPanel:setVisible(false)
	local yazhuBtn = self:getUI("leftMenuNode.yazhuBtn")
	yazhuBtn:setVisible(true)
	local warIndex = self._warIndex
	local titleText = string.format("8强赛第%d场激战中", self._warIndex)
	if warIndex>4 and warIndex<=6 then
		titleText = string.format("4强赛第%d场激战中", self._warIndex-4)
	elseif warIndex==7 then
		titleText = string.format("季军争夺赛激战中")
	else
		titleText = string.format("神主争夺赛激战中")
	end
	self._timeTitleLab:setString(titleText)
	self:registerClickEvent(yazhuBtn, function()
		self._viewMgr:showDialog("crossGod.CrossGodWarSupportDialog",{callback = handler(self,self.getViewShowState)})
	end)
	local liveBtn = self:getUI("btnbg.liveBtn")
	liveBtn:setVisible(true)
	self:registerClickEvent(liveBtn, function()
		local state,_2,tabIndex = self:getViewShowState()
		local chang,powId,ju = self._crossGodWarModel:getPowIdAndChang(tabIndex,state)
		self._serverMgr:sendMsg("CrossGodWarServer", "getWarBattleInfo", {pow = powId , round = ju}, true, {}, function(result1)
			if result1.reportKey then
				self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = result1.reportKey}, true, {},  function(result)
					self:reviewTheBattle(result, 0)
				end)
			else
				self:reviewTheBattle(result1, 0)
			end
			
		end)
	end)
	self._countDownTimeLab:setVisible(true)
	self:onInitLayer2_1()
	self:onInitWarTagState()
end

function CrossGodWarView:onInitState12()
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")
	buzhenPanel:setVisible(false)
	local timeBg = self:getUI("titleBg.timeBg")
	timeBg:setVisible(false)
	self:changeBgImage("asset/bg/bg_crossGodWarSchedule.jpg")
	self:onInitLayer3()
	self:setLayerShowState(3)
	local promotionBg = self:getUI("bg"):getChildByName("promotionBg")
	if promotionBg then
		promotionBg:setVisible(false)
	end
	local myWarPanel = self:getUI("myWarPanel")
	myWarPanel:setVisible(false)
	local rankPanel = self:getUI("rankPanel")
	rankPanel:setVisible(false)
	self._countDownTimeLab:setVisible(false)
	self:onInitWarTagState()
end

function CrossGodWarView:onInitLayer1()
	self._titleLab:setString(string.format("第%s届 神选之战", self._season))
	self._titleLab:setFontSize(28)
	local nowState = self._nowState
	local layer = self:getUI("bg.layer1")
	local leftPanel = layer:getChildByName("leftPanel")
	local warTimeLab = layer:getChildByName("warTimeLab")
	
	local useFormationId = self._crossGodWarModel:getUseFormationId()
	local formationData = self._modelMgr:getModel("FormationModel"):getFormationDataByType(useFormationId)
	local heroId = formationData.heroId
	local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
	local heroSkin
	if heroData.skin then
		heroSkin = tab.heroSkin[heroData.skin].heroart
	end
	if not heroSkin then
		heroSkin = tab.hero[heroId].heroart
	end
	local heroMc = leftPanel:getChildByName("heroMc")
	if heroMc then
		heroMc:removeFromParent()
	end
	local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
    heroMc = IntanceMcAnimNode.new({"stop", "win"}, heroSkin,
		function(sender) 
			sender:runStandBy()
		end
		,100,100,
		{"stop"},{{3,10},1})
--	heroMc:setOpacity(200)
	heroMc:setPosition(cc.p(leftPanel:getContentSize().width/2, 30))
	heroMc:setName("heroMc")
	leftPanel:addChild(heroMc)
	
	local leftNameLab = leftPanel:getChildByName("nameLab")
	local leftInfoLab = leftPanel:getChildByName("infoLab")
	
	leftNameLab:setString(self._userModel:getUserName())
	local userData = self._userModel:getData()
	local myServer = self._crossGodWarModel:getServerNameStr(self._userModel:getServerId())
	if userData.guildName then
		leftInfoLab:setString(string.format("%s %s", myServer, userData.guildName))
	else
		leftInfoLab:setString(string.format("%s", myServer))
	end
	local timeTitleLab = layer:getChildByName("timeTitleLab")
	local timeLab = layer:getChildByName("timeLab")
	local desLab = layer:getChildByName("desLab")
	local desImg = layer:getChildByName("desImg")
	local vsImage = layer:getChildByName("vsImage")
	vsImage:setVisible(true)
	if layer:getChildByName("fightAnim") then
    	layer:removeChildByName("fightAnim")
    end
	local curTime = self._userModel:getCurServerTime()
	local groupTime = TimeUtils.getTimeStampWithWeekTime(curTime, tab:Setting("CROSS_FIGHT_GROUP_TIME").value, 2)
	local endTime = self._stateEndTime
	
	local rightPanel = layer:getChildByName("rightPanel")
	local blackShadow = rightPanel:getChildByName("blackShadow")
	local rightNameLab = rightPanel:getChildByName("nameLab")
	local rightInfoLab = rightPanel:getChildByName("infoLab")
	warTimeLab:setVisible(nowState==stateCode[4])
	warTimeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
	if nowState==stateCode[2] or nowState == stateCode[5] then--判断状态
		rightNameLab:setString("??????????")
		rightInfoLab:setString("????????")
		blackShadow:setVisible(true)
		self:registerClickEvent(blackShadow, function()
			self._viewMgr:showTip(lang("crossFight_tips_4"))
		end)
		local enemyMc = rightPanel:getChildByName("enemyMc")
		if enemyMc then
			enemyMc:removeFromParent()
		end
		if nowState==stateCode[2] then
			desImg:loadTexture("crossGodWarImage_war1.png", 1)
		else
			desImg:loadTexture("crossGodWarImage_war10.png", 1)
		end
		rightPanel:setTouchEnabled(false)
		local titleText = string.format("跨服选拔赛第一场")
		if nowState==stateCode[5] then
			titleText = string.format("周三19:29开启选拔赛第十场")
		end
		self._timeTitleLab:setString(titleText)
		timeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		desLab:setVisible(false)
		timeTitleLab:setVisible(true)
		timeLab:setVisible(true)
		self:setLayerShowState(1)
	elseif nowState==stateCode[3] or nowState==stateCode[4] then
		local enemyData = self._crossGodWarModel:getGroupRivalDataByUseId(self._crossGodWarModel:getGroupRivalUseId())
		if not enemyData then
			self:close()
			self._viewMgr:showTip(lang("crossFight_tips_18"))
		end
		local enemyHeroId = enemyData.formation.heroId
		local enemyHeroSkin
		if enemyData.hero.skin then
			enemyHeroSkin = tab.heroSkin[enemyData.hero.skin].heroart
		end
		if not enemyHeroSkin then
			enemyHeroSkin = tab.hero[enemyHeroId].heroart
		end
		local enemyMc = rightPanel:getChildByName("enemyMc")
		if enemyMc then
			enemyMc:removeFromParent()
		end
		self:setLayerShowState(1)
		blackShadow:setVisible(false)
		if nowState == stateCode[4] then
			vsImage:setVisible(false)
			local fightAnim = mcMgr:createViewMC("shangfangjian_godwar", true, false)
	        fightAnim:setPosition(vsImage:getPositionX(), vsImage:getPositionY() + 10)
	        fightAnim:setScale(1.8)
	        fightAnim:setName("fightAnim")
	        layer:addChild(fightAnim, 10)
		end
		local animCallback = function()
			local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
			enemyMc = IntanceMcAnimNode.new({"stop", "win"}, enemyHeroSkin,
				function(sender) 
					sender:runStandBy()
				end
				,100,100,
				{"stop"},{{3,10},1})
			enemyMc:setPosition(cc.p(rightPanel:getContentSize().width/2, 30))
			enemyMc:setName("enemyMc")
			enemyMc:setScaleX(-1)
			rightPanel:addChild(enemyMc)
			self:registerClickEvent(rightPanel, function()
				self._viewMgr:showDialog("crossGod.CrossGodWarUserInfoView",{userInfo = enemyData , state = self._nowState })
			end)
			rightPanel:setTouchEnabled(true)
			rightNameLab:setString(enemyData.name)
			local enemyServerId = self._crossGodWarModel:getServerNameStr(self._crossGodWarModel:getGroupRivalServerId())
			if enemyData.guildName then
				rightInfoLab:setString(string.format("%s %s", enemyServerId, enemyData.guildName))
			else
				rightInfoLab:setString(string.format("%s", enemyServerId))
			end
			
			local ChineseSymbole = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八"}
			local warIndex = self._warIndex
			local backStr = ""
			if nowState==stateCode[3] then
				backStr = string.format("第%s战准备阶段，选手可以选择阵容", ChineseSymbole[warIndex])
			else
				backStr = string.format("第%s战进行中，选手可点击观战进入战斗", ChineseSymbole[warIndex])
			end
			desImg:loadTexture(string.format("crossGodWarImage_war%d.png", warIndex), 1)
			desLab:setString(backStr)
			desLab:setVisible(true)
			timeTitleLab:setVisible(false)
			timeLab:setVisible(false)
			self._timeTitleLab:setString(string.format("跨服选拔赛第%s场", ChineseSymbole[warIndex]))
		end
		if nowState==stateCode[3] and self._needMatchAnim then
			self._needMatchAnim = false
			local matchAnim = mcMgr:createViewMC("pipeiqiehuan_kuafupipeiduizhan", false, true, animCallback)
			local shadowPos = cc.p(blackShadow:getPosition())
			matchAnim:setScale(0.8)
			matchAnim:setPosition(shadowPos.x, shadowPos.y+60)
			rightPanel:addChild(matchAnim)
		else
			animCallback()
		end
	end
end

function CrossGodWarView:onInitLayer2()
	local bg = self:getUI("bg")
	local promotionBg = bg:getChildByName("promotionBg")
	if not promotionBg then
		promotionBg = cc.Sprite:create("asset/bg/bg_crossGodWar.jpg")
		promotionBg:setPosition(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5)
		promotionBg:setScale(1136/1022)
		promotionBg:setName("promotionBg")
		bg:addChild(promotionBg, -1)
	else
		promotionBg:setVisible(true)
	end
	local ribbonImg = bg:getChildByFullName("layer2.powtu.ribbonImg")
	ribbonImg:loadTexture("crossGodWarImage_ribbon2.png", 1)
	local myStateData = self._crossGodWarModel:getIsInMatchData()
	if myStateData.isPromoted==1 then
		self._64to8GroupId = tonumber(myStateData.group)
	else
		self._64to8GroupId = 1
	end
	local leftBtn = self:getUI("bg.layer2.leftBtn")
	leftBtn:setVisible(self._64to8GroupId>1)
	local rightBtn = self:getUI("bg.layer2.rightBtn")
	self:registerClickEvent(leftBtn, function()
		if self._64to8GroupId>1 then
			self._64to8GroupId = self._64to8GroupId - 1
			leftBtn:setVisible(self._64to8GroupId>1)
			rightBtn:setVisible(self._64to8GroupId<8)
			self:updateMatchData(self._crossGodWarModel:get64to8MatchDataByGroup(self._64to8GroupId))
		end
	end)
	self:registerClickEvent(rightBtn, function()
		if self._64to8GroupId<8 then
			self._64to8GroupId = self._64to8GroupId + 1
			leftBtn:setVisible(self._64to8GroupId>1)
			rightBtn:setVisible(self._64to8GroupId<8)
			self:updateMatchData(self._crossGodWarModel:get64to8MatchDataByGroup(self._64to8GroupId))
		end
	end)
	local matchData = self._crossGodWarModel:get64to8MatchDataByGroup(self._64to8GroupId)
	self:updateMatchData(matchData)
	self:setLayerShowState(2)
end

function CrossGodWarView:onInitLayer2_1()--八强比赛,复用layer2
	local bg = self:getUI("bg")
	local promotionBg = bg:getChildByName("promotionBg")
	if not promotionBg then
		promotionBg = cc.Sprite:create("asset/bg/bg_crossGodWar.jpg")
		promotionBg:setPosition(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5)
		promotionBg:setScale(1136/1022)
		promotionBg:setName("promotionBg")
		bg:addChild(promotionBg, -1)
	else
		promotionBg:setVisible(true)
	end
	local rankLayer = self:getUI("rankPanel")
	if rankLayer:isVisible() then
		rankLayer:setVisible(false)
	end
	local ribbonImg = bg:getChildByFullName("layer2.powtu.ribbonImg")
	ribbonImg:loadTexture("crossGodWarImage_ribbon.png", 1)
	local leftBtn = self:getUI("bg.layer2.leftBtn")
	leftBtn:setVisible(false)
	local rightBtn = self:getUI("bg.layer2.rightBtn")
	rightBtn:setVisible(false)
	local matchData = self._crossGodWarModel:getEliminateFightData()
	self:updateMatchData(matchData, true)
	self:setLayerShowState(2)
end

function CrossGodWarView:createLineEffect()
	self._powLine = {}
	local powtu = self:getUI("bg.layer2.powtu")
	for i=1,7 do
		local str = "xian1_xiantexiao"
		if i <= 4 then
			str = "xian1_xiantexiao"
		elseif i <= 6 then
			str = "xian2_xiantexiao"
		else
			str = "xian3_xiantexiao"
		end
		local tline = mcMgr:createViewMC(str, true, false)
		tline:setName("tline")
		powtu:addChild(tline)
		self._powLine[i] = tline
		powtu:getChildByName("chakan"..i):setVisible(false)
		powtu:getChildByName("tipLabBg"..i):setVisible(false)
	end
	local tline = mcMgr:createViewMC("guanjun_xiantexiao", true, false)
	tline:setScale(0.96)
	tline:setPosition(481, 414)
	tline:setName("tline")
	tline:setVisible(false)
	powtu:addChild(tline)
	self._powLine[8] = tline
end

function CrossGodWarView:getIs64WarState()
	local nowState = self._nowState
	if nowState>=stateCode[6] and nowState<=stateCode[8] then
		return true
	end
end

function CrossGodWarView:update8MatchWinData(round, warIndex, playerData)
	local matchLayer = self:getUI("bg.layer2.powtu")
	if playerData then
		local headBg
		local scale
		if round==4 then
			scale = 0.8
			if warIndex==1 then
				headBg = matchLayer:getChildByName("headBg9")
			elseif warIndex==2 then
				headBg = matchLayer:getChildByName("headBg10")
			elseif warIndex==3 then
				headBg = matchLayer:getChildByName("headBg11")
			end
		elseif round==3 then
			scale = 0.9
			if warIndex==5 then
				headBg = matchLayer:getChildByFullName("thirdPanel.headBg16")
			elseif warIndex==6 then
				headBg = matchLayer:getChildByFullName("thirdPanel.headBg17")
			end
		elseif round==2 then
			scale = 0.95
			if warIndex==5 then
				headBg = matchLayer:getChildByName("headBg13")
			elseif warIndex==6 then
				headBg = matchLayer:getChildByName("headBg14")
			end
		end
		local param = {avatar = playerData.avatar, tp = 4, avatarFrame = playerData.avatarFrame}
		local icon = headBg:getChildByName("icon")
		if not icon then
			icon = IconUtils:createHeadIconById(param)
			icon:setName("icon")
			icon:setScale(scale)
			headBg:addChild(icon)
		else
			IconUtils:updateHeadIconByView(icon, param)
		end
		if icon:getChildByName("selfTagImg")~=nil then
			icon:getChildByName("selfTagImg"):setVisible(playerData.name == self._userModel:getUserName())
		elseif playerData.name == self._userModel:getUserName() then
			local selfTagImg = ccui.ImageView:create()
			selfTagImg:loadTexture("godwarImageUI_img129.png", 1)
			selfTagImg:setName("selfTagImg")
			selfTagImg:setPosition(cc.p(10, icon:getContentSize().height-selfTagImg:getContentSize().height/2))
			icon:addChild(selfTagImg, 10)
		end
		if round==3 then
			icon:setAnchorPoint(0.5, 0)
			icon:setPositionX(headBg:getContentSize().width/2)
		end
		local nameLab = headBg:getChildByName("name")
		local serverLab = headBg:getChildByName("serverLab")
		local resultImg = headBg:getChildByName("resultImg")
		nameLab:setString(playerData.name)
		nameLab:setColor(playerData.name==self._userModel:getUserName() and cc.c3b(252, 226, 108) or UIUtils.colorTable.ccWhite)
		serverLab:setString(string.format("%s", self._crossGodWarModel:getServerNameStr(playerData.serverId)))
		resultImg:setVisible(false)
		self:registerClickEvent(headBg, function()
			self._viewMgr:showDialog("crossGod.CrossGodWarUserInfoView",{userInfo = playerData , state = self._nowState })
		end)
	end
end

function CrossGodWarView:updateMatchData(matchData, eliminate)
	if eliminate then
		self._titleLab:setString(string.format("第%s届 神主之战·终战", self._season))
	else
		self._titleLab:setString(string.format("第%s届 神主之战·战场%d", self._season, self._64to8GroupId))
	end
	self._titleLab:setFontSize(24)
	local curTime = self._userModel:getCurServerTime()
	self._countDownTimeLab:setString(TimeUtils.getStringTimeForInt(self._stateEndTime - curTime))
	local matchLayer = self:getUI("bg.layer2.powtu")
	local nowState = self._nowState
	local warIndex = self._warIndex
	if not self._powLine then
		self:createLineEffect()
	else
		for i=1, 7 do
			self._powLine[i]:setVisible(false)
			local chakanBtn = matchLayer:getChildByName("chakan"..i)
			chakanBtn:setVisible(false)
			local tipLabBg = matchLayer:getChildByName("tipLabBg"..i)
			tipLabBg:setVisible(false)
		end
	end
	
	local thirdPanel = self:getUI("bg.layer2.powtu.thirdPanel")
	thirdPanel:setVisible(false)
	
	local tbStateCount64 = {
		[1] = 8,
		[2] = 12,
		[3] = 14,
	}
	local tbStateCount8 = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
		[5] = 5,
		[6] = 6,
		[7] = 8,
		[8] = 7,
	}
	
	local tbInitWinData = {
		[9] = false,
		[10] = false,
		[11] = false,
		[12] = false,
		[13] = false,
		[14] = false,
		[16] = false,
		[17] = false,
	}
	local function createHeadIcon(headBg, scale, param, isFail, index)
		if not param then
			param = {art = "globalImageUI_secretIcon", tp = 4,avatarFrame = 1000}
			local nameLab = headBg:getChildByName("name")
			local serverLab = headBg:getChildByName("serverLab")
			nameLab:setString("??????????")
			serverLab:setString("????????")
		end
		local icon = headBg:getChildByName("icon")
		if not icon then
			icon = IconUtils:createHeadIconById(param)
			icon:setName("icon")
			icon:setScale(scale)
--			icon:setPosition(tPosTab[1], tPosTab[2])
			headBg:addChild(icon)
		else
			IconUtils:updateHeadIconByView(icon, param)
			if icon:getChildByName("selfTagImg")~=nil then
				icon:getChildByName("selfTagImg"):removeFromParent()
			end
		end
		local resultImg = headBg:getChildByName("resultImg")
		if nowState==stateCode[8] and index then
			local count = warIndex-1 == 0 and 0 or tbStateCount64[warIndex-1]
			if index>count then
				isFail = false
			end
		elseif nowState==stateCode[11] and index then
			local count = warIndex-1 == 0 and 0 or tbStateCount8[warIndex-1]
			if warIndex==8 then
				count = 6
			end
			if index>count*2 then
				isFail = false
			end
		end
		if isFail then
			resultImg:setVisible(true)
			icon:setSaturation(-100)
			icon:setEnabled(false)
		else
			resultImg:setVisible(false)
			icon:setSaturation(0)
			icon:setEnabled(true)
		end
		return icon
	end
	
	local function initPlayerData(roundData, index, headBg, scale)
		local nameLab = headBg:getChildByName("name")
		local serverLab = headBg:getChildByName("serverLab")
		local relationIndex = math.ceil(index/2)
		
		local tempIndex = index
		if index<=8 then
			
		elseif index<=12 then
			index = index - 8
		elseif index<=14 then
			index = index - 12
		end
		local fightData = roundData[math.ceil(index/2)]
		if not fightData then
			return
		end
		local win = fightData.win
		local key = fightData.key
		local lineEffect = self._powLine[relationIndex]
		local function getLineEffectPosition(relationIndex, win)
			local posX, posY, scaleX, scaleY = 0, 0, 1, 1
			if win==1 then
				if relationIndex<=4 then
					posX = relationIndex<=2 and 176 or 788
					posY = relationIndex%2==1 and 448 or 238
					scaleX = relationIndex<=2 and 1 or -1
					scaleY = 1
				elseif relationIndex<=6 then
					posX = relationIndex==5 and 280 or 688
					scaleX = relationIndex==5 and 1 or -1
					scaleY = 0.9
					posY = 325
				else
					posX = 482
					posY = 324
					scaleX = -1
				end
			elseif win==2 then
				if relationIndex<=4 then
					posX = relationIndex<=2 and 176 or 788
					posY = relationIndex%2==1 and 408 or 195
					scaleX = relationIndex<=2 and 1 or -1
					scaleY = -1
				elseif relationIndex<=6 then
					posX = relationIndex==5 and 280 or 688
					scaleX = relationIndex==5 and 1 or -1
					scaleY = -0.9
					posY = 315
				else
					posX = 482
					posY =324
					scaleX = 1
				end
			end
			return posX, posY, scaleX, scaleY
		end
		local chakanBtn = matchLayer:getChildByName("chakan"..relationIndex)
		local tipLabBg = matchLayer:getChildByName("tipLabBg"..relationIndex)
		local tipLab = tipLabBg:getChildByName("tipLab")
		if nil~=win then
			chakanBtn:setVisible(true)
			tipLabBg:setVisible(false)
			self:registerClickEvent(chakanBtn, function()
				self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = key}, true, {},  function(result)
					self._isReviewReport = true
					self:reviewTheBattle(result, 2)
				end)
			end)
			if eliminate then
				local winData = win==1 and fightData.player1 or fightData.player2
				local loseData = win==1 and fightData.player2 or fightData.player1
				if tempIndex==2 and warIndex>1 then
					self:update8MatchWinData(4, 1, winData)
					tbInitWinData[9] = true
				elseif tempIndex==4 and warIndex>2 then
					self:update8MatchWinData(4, 2, winData)
					tbInitWinData[10] = true
				elseif tempIndex==6 and warIndex>3 then
					self:update8MatchWinData(4, 3, winData)
					tbInitWinData[11] = true
				elseif tempIndex==10 and warIndex>5 then
					self:update8MatchWinData(3, 5, loseData)
					tbInitWinData[16] = true
					self:update8MatchWinData(2, 5, winData)
					tbInitWinData[13] = true
				elseif tempIndex==12 and warIndex>6 then
					self:update8MatchWinData(2, 6, winData)
					tbInitWinData[14] = true
				end
			end
		end
		local posX, posY, scaleX, scaleY = getLineEffectPosition(relationIndex, win)
		lineEffect:setPosition(posX, posY)
		lineEffect:setScaleX(scaleX)
		lineEffect:setScaleY(scaleY)
		lineEffect:setVisible(true)
		index = index%2==1 and 1 or 2
		fightData = fightData["player"..index]
		local isFail = win and tonumber(index) ~= tonumber(win) or false
		local param = {avatar = fightData.avatar, tp = 4,avatarFrame = fightData.avatarFrame}
		local icon = createHeadIcon(headBg, scale, param, isFail, tempIndex)
		if fightData.name==self._userModel:getUserName() then
			local selfTagImg = ccui.ImageView:create()
			selfTagImg:loadTexture("godwarImageUI_img129.png", 1)
			selfTagImg:setName("selfTagImg")
			selfTagImg:setPosition(cc.p(10, icon:getContentSize().height-selfTagImg:getContentSize().height/2))
			icon:addChild(selfTagImg, 10)
		end
		nameLab:setString(fightData.name)
		nameLab:setColor(fightData.name==self._userModel:getUserName() and cc.c3b(252, 226, 108) or UIUtils.colorTable.ccWhite)
		serverLab:setString(string.format("%s", self._crossGodWarModel:getServerNameStr(fightData.serverId)))
		return fightData
	end
	
	local function showPlayerInfo(userInfo)
		self._viewMgr:showDialog("crossGod.CrossGodWarUserInfoView",{userInfo = userInfo , state = nowState })
	end
	
	local is64State = self:getIs64WarState()
	for i=1, 15 do
		local headBg = matchLayer:getChildByName("headBg"..i)
		local winImg = headBg:getChildByName("resultImg")
		winImg:setVisible(false)
		--[[nameLab:setString("??????????")
		serverLab:setString("????????")--]]
		local roundData
		local fightData
		if i<=8 then
			roundData = eliminate and matchData[8] or matchData[1]
			fightData = initPlayerData(roundData, i, headBg, 0.7)
			if fightData then
				self:registerClickEvent(headBg, function()
					showPlayerInfo(fightData)
				end)
			else
				local icon = createHeadIcon(headBg, 0.7)
			end
		elseif i<=12 then
			roundData = eliminate and matchData[4] or matchData[2]
			if roundData and ((is64State and warIndex>1) or (not is64State and warIndex>4)) then
				fightData = initPlayerData(roundData, i, headBg, 0.8)
				if fightData then
					self:registerClickEvent(headBg, function()
						showPlayerInfo(fightData)
					end)
				else
					local icon = createHeadIcon(headBg, 0.8)
				end
			elseif not tbInitWinData[i] then
				local icon = createHeadIcon(headBg, 0.8)
			end
		elseif i<=14 then
			roundData = eliminate and matchData[2] or matchData[3]
			if roundData and ((is64State and warIndex>2) or (not is64State and warIndex>7)) then
				fightData = initPlayerData(roundData, i, headBg, 0.95)
				if fightData then
					self:registerClickEvent(headBg, function()
						showPlayerInfo(fightData)
					end)
				else
					local icon = createHeadIcon(headBg, 0.95)
				end
			elseif not tbInitWinData[i] then
				local icon = createHeadIcon(headBg, 0.95)
			end
		else
--			roundData = eliminate and matchData[2] or matchData[3]
			if eliminate then
				roundData = matchData[2]
			elseif nowState>=stateCode[6] and nowState<=stateCode[8] then
				roundData = matchData[3]
			end
			if roundData and roundData[1] and roundData[1].win and nowState~=stateCode[8] and nowState~=stateCode[11] then
				local resultData = roundData[1]
				fightData = resultData.player1
				if resultData.win==2 then
					fightData = resultData.player2
				end
				local param = {avatar = fightData.avatar, tp = 4,avatarFrame = fightData.avatarFrame}
				local icon = createHeadIcon(headBg, 1, param)
				if fightData.name==self._userModel:getUserName() then
					local selfTagImg = ccui.ImageView:create()
					selfTagImg:loadTexture("godwarImageUI_img129.png", 1)
					selfTagImg:setName("selfTagImg")
					selfTagImg:setPosition(cc.p(10, icon:getContentSize().height-selfTagImg:getContentSize().height/2))
					icon:addChild(selfTagImg, 10)
				end
				local nameLab = headBg:getChildByName("name")
				local serverLab = headBg:getChildByName("serverLab")
				nameLab:setString(fightData.name)
				nameLab:setColor(fightData.name==self._userModel:getUserName() and cc.c3b(252, 226, 108) or UIUtils.colorTable.ccWhite)
--				nameLab:setString(fightData.name)
				serverLab:setString(string.format("%s", self._crossGodWarModel:getServerNameStr(fightData.serverId)))
				self._powLine[8]:setVisible(true)
			else
				local icon = createHeadIcon(headBg, 1)
			end
		end
	end
	if eliminate then
		local roundData = matchData[3] and matchData[3][1]
		if roundData and warIndex>=7 then
			local node = {}
			for i=1, 2 do
				local idx = i+15
				local headBg = thirdPanel:getChildByName("headBg"..idx)
				local nameLab = headBg:getChildByName("name")
				local serverLab = headBg:getChildByName("serverLab")
				local resultImg = headBg:getChildByName("resultImg")
				local icon
				if roundData["player"..i] then
					local fightData = roundData["player"..i]
--					nameLab:setString(fightData.name)
					serverLab:setString(string.format("%s", self._crossGodWarModel:getServerNameStr(fightData.serverId)))
					local param = {avatar = fightData.avatar, tp = 4,avatarFrame = fightData.avatarFrame}
					icon = createHeadIcon(headBg, 0.9, param)
--					icon:setPositionX(icon:getPositionX()-10)
					if fightData.name==self._userModel:getUserName() then
						local selfTagImg = ccui.ImageView:create()
						selfTagImg:loadTexture("godwarImageUI_img129.png", 1)
						selfTagImg:setName("selfTagImg")
						selfTagImg:setPosition(cc.p(10, icon:getContentSize().height-selfTagImg:getContentSize().height/2))
						icon:addChild(selfTagImg, 10)
					end
					nameLab:setString(fightData.name)
					nameLab:setColor(fightData.name==self._userModel:getUserName() and cc.c3b(252, 226, 108) or UIUtils.colorTable.ccWhite)

					self:registerClickEvent(headBg, function()
						showPlayerInfo(fightData)
					end)
				end
				icon:setAnchorPoint(0.5, 0)
				icon:setPositionX(headBg:getContentSize().width/2)
				resultImg:setVisible( roundData.win~=nil and roundData.win~=i and warIndex~=7 )
				if resultImg:isVisible() then
					icon:setSaturation(-100)
					icon:setEnabled(false)
					local chakanBtn = matchLayer:getChildByFullName("thirdPanel.chakan8")
					self:registerClickEvent(chakanBtn, function()
						self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = roundData.key}, true, {},  function(result)
							self._isReviewReport = true
							self:reviewTheBattle(result, 0)
						end)
					end)
				end
				node[i] = {
					headBg = headBg,
					nameLab = nameLab,
					serverLab = serverLab,
					resultImg = resultImg,
				}
			end
			
		else
			for i=1, 2 do
				local idx = i+15
				if not tbInitWinData[idx] then
					local headBg = thirdPanel:getChildByName("headBg"..idx)
					local nameLab = headBg:getChildByName("name")
					local serverLab = headBg:getChildByName("serverLab")
					local resultImg = headBg:getChildByName("resultImg")
					local icon = createHeadIcon(headBg, 0.9)
					icon:setAnchorPoint(0.5, 0)
					icon:setPositionX(headBg:getContentSize().width/2)
					nameLab:setString("??????????")
					serverLab:setString("????????")
					resultImg:setVisible(false)
				end
			end
		end
		thirdPanel:setVisible(true)
	end
	self:updateMatchLayerWarState()
end

function CrossGodWarView:updateMatchLayerWarState()
	local nowState = self._nowState
	local matchLayer = self:getUI("bg.layer2.powtu")
	local detailNode = {}
	if nowState>stateCode[1] and nowState<=stateCode[8] then
		for i=1, 7 do
			local chakanBtn = matchLayer:getChildByName("chakan"..i)
			chakanBtn:setVisible(false)
			local tipLabBg = matchLayer:getChildByName("tipLabBg"..i)
			tipLabBg:setVisible(false)
			local tipLab = tipLabBg:getChildByName("tipLab")
			local prepareEffect = tipLabBg:getChildByName("prepareEffect")
			if not prepareEffect then
				prepareEffect = mcMgr:createViewMC("beizhan_godwar", true, false)
				prepareEffect:setPosition(cc.p(tipLabBg:getContentSize().width/2, tipLabBg:getContentSize().height/2))
				prepareEffect:setName("prepareEffect")
				prepareEffect:setScale(1.5)
				tipLabBg:addChild(prepareEffect)
			end
			prepareEffect:setVisible(false)
			local fightEffect = tipLabBg:getChildByName("fightEffect")
			if not fightEffect then
				fightEffect = mcMgr:createViewMC("shangfangjian_godwar", true, false)
				fightEffect:setPosition(cc.p(tipLabBg:getContentSize().width/2, tipLabBg:getContentSize().height/2))
				fightEffect:setName("fightEffect")
				tipLabBg:addChild(fightEffect)
			end
			fightEffect:setVisible(false)
			detailNode[i] = {
				chakanBtn = chakanBtn,
				tipLabBg = tipLabBg,
				tipLab = tipLab,
				prepareEffect = prepareEffect,
				fightEffect = fightEffect,
			}
		end
	else
		for i=1, 8 do
			local index = i
			if i==7 then
				index = 8
			elseif i==8 then
				index = 7
			end
			local chakanBtn
			local tipLabBg
			if index<8 then
				chakanBtn = matchLayer:getChildByName("chakan"..index)
				tipLabBg = matchLayer:getChildByName("tipLabBg"..index)
			else
				chakanBtn = matchLayer:getChildByFullName("thirdPanel.chakan8")
				tipLabBg = matchLayer:getChildByFullName("thirdPanel.tipLabBg8")
			end
			chakanBtn:setVisible(false)
			tipLabBg:setVisible(false)
			local tipLab = tipLabBg:getChildByName("tipLab")
			local prepareEffect = tipLabBg:getChildByName("prepareEffect")
			if not prepareEffect then
				prepareEffect = mcMgr:createViewMC("beizhan_godwar", true, false)
				prepareEffect:setPosition(cc.p(tipLabBg:getContentSize().width/2, tipLabBg:getContentSize().height/2))
				prepareEffect:setName("prepareEffect")
				prepareEffect:setScale(1.5)
				tipLabBg:addChild(prepareEffect)
			end
			prepareEffect:setVisible(false)
			local fightEffect = tipLabBg:getChildByName("fightEffect")
			if not fightEffect then
				fightEffect = mcMgr:createViewMC("shangfangjian_godwar", true, false)
				fightEffect:setPosition(cc.p(tipLabBg:getContentSize().width/2, tipLabBg:getContentSize().height/2))
				fightEffect:setName("fightEffect")
				tipLabBg:addChild(fightEffect)
			end
			fightEffect:setVisible(false)
			detailNode[index] = {
				chakanBtn = chakanBtn,
				tipLabBg = tipLabBg,
				tipLab = tipLab,
				prepareEffect = prepareEffect,
				fightEffect = fightEffect
			}
		end
	end
	local tbStateCount64 = {
		[1] = 4,
		[2] = 6,
		[3] = 7,
	}
	local tbStateCount8 = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 4,
		[5] = 5,
		[6] = 6,
		[7] = 8,
		[8] = 7,
	}
	local warIndex = self._warIndex
	
	local function reviewBattle(is64, group, round, sort)
		if is64 then
			self._serverMgr:sendMsg("CrossGodWarServer", "getElisBattleInfo", {group = group, round = round, sort = sort}, true, {}, function(result)
				if result.reportKey then
					self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = result.reportKey}, true, {},  function(result)
						self:reviewTheBattle(result, 0)
					end)
				else
					self:reviewTheBattle(result, 0)
				end
			end)
		else
			self._serverMgr:sendMsg("CrossGodWarServer", "getWarBattleInfo", {pow = group, round = round}, true, {}, function(result)
				if result.reportKey then
					self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = result.reportKey}, true, {},  function(result)
						self:reviewTheBattle(result, 0)
					end)
				else
					self:reviewTheBattle(result, 0)
				end
			end)
		end
	end
	
	local function setShowEffect(node, showState)--1:查看战斗记录。2:备战中。3:激战中。4:还没到，什么都不显示
		if showState==1 then--查看战斗记录
			node.chakanBtn:setVisible(true)
			node.tipLabBg:setVisible(false)
		elseif showState==2 then--备战中
			node.chakanBtn:setVisible(false)
			node.tipLabBg:setVisible(true)
			node.prepareEffect:setVisible(true)
			node.fightEffect:setVisible(false)
			node.tipLab:setColor(cc.c3b(252, 244, 197))
			node.tipLab:setString("备战中")
		elseif showState==3 then
			node.chakanBtn:setVisible(false)
			node.tipLabBg:setVisible(true)
			node.prepareEffect:setVisible(false)
			node.fightEffect:setVisible(true)
			node.tipLab:setColor(cc.c3b(205, 32, 30))
			node.tipLab:setString("激战中")
		else
			
		end
	end
	
	if nowState==stateCode[6] or nowState==stateCode[7] then--64强准备
		for i=1, tbStateCount64[warIndex] do
			if warIndex>1 then
				if i<=tbStateCount64[warIndex-1] then
					setShowEffect(detailNode[i], 1)
				else
					setShowEffect(detailNode[i], 2)
				end
			else
				setShowEffect(detailNode[i], 2)
			end
		end
	elseif nowState==stateCode[9] or nowState==stateCode[10] then--8强准备
		for i=1, tbStateCount8[warIndex] do
			if warIndex<=6 then
				if warIndex>1 then
					if i<=tbStateCount8[warIndex-1] then
						setShowEffect(detailNode[i], 1)
					else
						setShowEffect(detailNode[i], 2)
					end
				else
					setShowEffect(detailNode[i], 2)
				end
			elseif warIndex==7 then
				if i<=tbStateCount8[warIndex-1] then
					setShowEffect(detailNode[i], 1)
				elseif i==7 then
					setShowEffect(detailNode[i], 4)
				else
					setShowEffect(detailNode[8], 2)
				end
			else
				if i<=tbStateCount8[6] then
					setShowEffect(detailNode[i], 1)
				elseif i==7 then
					setShowEffect(detailNode[i], 2)
				end
				if not detailNode[8].chakanBtn:isVisible() then
					setShowEffect(detailNode[8], 1)
				end
			end
		end
	elseif nowState==stateCode[8] then--64强战斗中
		for i=1, tbStateCount64[warIndex] do
			if warIndex>1 then
				if i<=tbStateCount64[warIndex-1] then
					setShowEffect(detailNode[i], 1)
				else
					self._powLine[i]:setVisible(false)
					setShowEffect(detailNode[i], 3)
					self:registerClickEvent(detailNode[i].tipLabBg, function()
						local group = self._64to8GroupId
						local round = warIndex
						local sort
						if i<=4 then
							sort = i
						elseif i<=6 then
							sort = i-4
						else
							sort = i-6
						end
						reviewBattle(true, group, round, sort)
					end)
				end
			else
				self._powLine[i]:setVisible(false)
				setShowEffect(detailNode[i], 3)
				self:registerClickEvent(detailNode[i].tipLabBg, function()
					reviewBattle(true, self._64to8GroupId, 1, i)
				end)
			end
		end
	elseif nowState==stateCode[11] then--8强战斗中
		for i=1, tbStateCount8[warIndex] do
			if warIndex<=6 then
				if warIndex>1 then
					if i<=tbStateCount8[warIndex-1] then
						setShowEffect(detailNode[i], 1)
					else
						self._powLine[i]:setVisible(false)
						setShowEffect(detailNode[i], 3)
						self:registerClickEvent(detailNode[i].tipLabBg, function()
							local pow
							local round
							if i<=4 then
								pow = 8
								round = i
							else
								pow = 4
								round = i-4
							end
							
							reviewBattle(false, pow, round)
						end)
					end
				else
					self._powLine[i]:setVisible(false)
					setShowEffect(detailNode[i], 3)
					self:registerClickEvent(detailNode[i].tipLabBg, function()
						reviewBattle(false, 8, i)
					end)
				end
			elseif warIndex==7 then
				if i<=tbStateCount8[warIndex-1] then
					setShowEffect(detailNode[i], 1)
				elseif i==7 then
					setShowEffect(detailNode[i], 4)
				else
					setShowEffect(detailNode[8], 3)
					self:registerClickEvent(detailNode[i].tipLabBg, function()
						reviewBattle(false, 3, 1)
					end)
				end
			else
				if i<=tbStateCount8[6] then
					setShowEffect(detailNode[i], 1)
				elseif i==7 then
					self._powLine[i]:setVisible(false)
					setShowEffect(detailNode[i], 3)
					self:registerClickEvent(detailNode[i].tipLabBg, function()
						reviewBattle(false, 2, 1)
					end)
				end
				if not detailNode[8].chakanBtn:isVisible() then
					setShowEffect(detailNode[8], 1)
				end
			end
		end
	elseif nowState==stateCode[1] then
		for i=1, 8 do
			setShowEffect(detailNode[i], 1)
		end
	end
end

function CrossGodWarView:onInitLayer3()
	local nowState,stateEndTime, nowTabIdx = self:getViewShowState()
	local realState = self._realState
	local layer = self:getUI("bg.layer3")
	local curTime = self._userModel:getCurServerTime()
	local groupTime = TimeUtils.getTimeStampWithWeekTime(curTime, tab:Setting("CROSS_FIGHT_GROUP_TIME").value, 2)
	local judgeCondition = {
		[1] = realState==stateCode[2] and curTime<=groupTime,
		[2] = (realState==stateCode[3] or realState==stateCode[4]) and self._warIndex<=stateCode[9],
		[3] = (realState==stateCode[3] or realState==stateCode[4]) and self._warIndex>stateCode[9],
		[4] = realState==stateCode[7] or realState==stateCode[8],
		[5] = (realState==stateCode[10] or realState==stateCode[11]) and self._warIndex<=4,
		[6] = (realState==stateCode[10] or realState==stateCode[11]) and (self._warIndex>=5 and self._warIndex<=6),
		[7] = (realState==stateCode[10] or realState==stateCode[11]) and self._warIndex==7,
		[8] = (realState==stateCode[10] or realState==stateCode[11]) and self._warIndex==8,
	}
	for i=1, 8 do
		local jinxingLab = layer:getChildByFullName("anpai"..i..".jinxing")
		jinxingLab:setVisible(judgeCondition[i])
	end
end

function CrossGodWarView:onInitLayer4()
	local rankListData = self._crossGodWarModel:getPlayerRankData()
	local bg = self:getUI("bg.layer4")
	self:setLayerShowState(4)
	for i=1, 3 do
		local rankData = rankListData[i]
		local heroBg = self:getUI("bg.layer4.rank" .. i)
		if heroBg.heroArt then
			heroBg.heroArt:removeFromParent()
		end
		local heroD = tab:Hero(rankData.hId)
		local heroArt = heroD["heroart"]
		if rankData.skin and rankData.skin ~= 0  then
			local heroSkinD = tab.heroSkin[rankData.skin]
			heroArt = heroSkinD["heroart"] or heroD["heroart"]
		end
		heroBg.heroArt = mcMgr:createViewMC("stop_" .. heroArt, true, false)
		if i==1 then
			heroBg.heroArt:setPosition(150, 135)
		elseif i==2 then
			heroBg.heroArt:setPosition(140, 125)
		else
			heroBg.heroArt:setPosition(140, 125)
		end
		heroBg.heroArt:setScale(0.8)
		heroBg.heroArt:setName("heroArt")
		heroBg:addChild(heroBg.heroArt, 20)
		
		local nameLab = bg:getChildByFullName("rank"..i..".name")
		local serverLab = bg:getChildByFullName("rank"..i..".tishi")
		local mobaiBtn = bg:getChildByFullName("rank"..i..".mobai")
		nameLab:setString(rankData.name)
		local infoStr = rankData.guildName and string.format("%s %s", self._crossGodWarModel:getServerNameStr(rankData.serverId), rankData.guildName) or string.format("%s", self._crossGodWarModel:getServerNameStr(rankData.serverId))
		serverLab:setString(infoStr)
	end
	self:onInitRankLayer()
end

function CrossGodWarView:onInitLayer5()
	if not self._signUpSpine then
		local layer = self:getUI("bg.layer5")
		tc:addImage("asset/spine/zhushentianshi.png")
		spineMgr:createSpine("zhushentianshi", function (spine)
			spine:setSkin("default")
			spine:setAnimation(0, "zhushentianshi", true)
			spine:setPosition(MAX_SCREEN_WIDTH/2, 80)
			layer:addChild(spine, 1)
			self._signUpSpine = spine
			spine:initUpdate()
		end)
		
		
		local mcTop = mcMgr:createViewMC("zhushentianshitexiao2_zhushentianshitexiao", true, false)
		mcTop:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2-30)
		layer:addChild(mcTop)

		local mcUnder = mcMgr:createViewMC("zhushentianshitexiao1_zhushentianshitexiao", true, false)
		mcUnder:setPosition(MAX_SCREEN_WIDTH/2-40, MAX_SCREEN_HEIGHT/2+30)
		layer:addChild(mcUnder, 2)
	end
	
	self:setLayerShowState(5)
end

function CrossGodWarView:onInitRankLayer()
	local rankPanel = self:getUI("rankPanel")
	self._rankTableData = self._crossGodWarModel:getPlayerRankData()
	local tableViewBg = rankPanel:getChildByName("tableBg")
	tableViewBg:removeAllChildren()
	
	local myRankNode = rankPanel:getChildByName("myRankNode")
	local noDataLab = rankPanel:getChildByName("noDataLab")
	
	local historyLayer = self:getUI("historyLayer")
	rankPanel:setVisible(not historyLayer:isVisible())
	
	if not self._rankTableData or table.nums(self._rankTableData)==0 then
		myRankNode:setVisible(false)
		tableViewBg:setVisible(false)
		noDataLab:setVisible(true)
		return
	end
	
	noDataLab:setVisible(false)
	--添加排名tableView
	tableViewBg:setVisible(true)
	self._rankTableView = cc.TableView:create(tableViewBg:getContentSize())
	self._rankTableView:setDelegate()
	self._rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self._rankTableView:setPosition(0, 0)
    self._rankTableView:registerScriptHandler(function(table) return self:scrollViewDidScroll(table) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
	self._rankTableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
	self._rankTableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
	self._rankTableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._rankTableView:setBounceable(true)
	self._rankTableView:reloadData()
	if self._rankTableView.setDragSlideable ~= nil then 
		self._rankTableView:setDragSlideable(true)
	end
	tableViewBg:addChild(self._rankTableView)
	
	--设置自己排名
	myRankNode:setVisible(true)
	local detailLab = myRankNode:getChildByName("detailLab")
	local rank = self._crossGodWarModel:getMyRank()
	local str
	if rank==-1 then
		str = "未上榜"
	else
		local myName = self._userModel:getUserName()
		str = string.format("%d.%s", rank, myName)
	end
	detailLab:setString(str)
	
end

function CrossGodWarView:scrollViewDidScroll(inView)
    self._inScrolling = inView:isDragging()
end

function CrossGodWarView:cellSizeForTable(inView, idx)
	return 37, 175
end

function CrossGodWarView:numberOfCellsInTableView(inView)
	return table.nums(self._rankTableData)
end

function CrossGodWarView:tableCellAtIndex(inView, idx)
	local cell = inView:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
	cell:removeAllChildren()
	local rankData = self._rankTableData[idx+1]
	local node = self._rankNode:clone()
	local rankLab = node:getChildByName("rankLab")
	local nameLab = node:getChildByName("nameLab")
	local serverLab = node:getChildByName("serverLab")
	rankLab:setString(string.format("%d.", idx+1))
	nameLab:setPositionX(rankLab:getPositionX()+rankLab:getContentSize().width)
	nameLab:setString(rankData.name)
	serverLab:setString(string.format("%s", self._crossGodWarModel:getServerNameStr(rankData.serverId)))
	serverLab:setPositionX(node:getContentSize().width-serverLab:getContentSize().width-2)
	
	node:setPosition(cc.p(0, 0))
	node:setVisible(true)
	cell:addChild(node)
	return cell
end

function CrossGodWarView:onInitMyWarLayer()
	local myWarLayer = self:getUI("myWarPanel")
	local myWarData = self._crossGodWarModel:getMyWarData()
	local rankLab = myWarLayer:getChildByName("rankLab")
	rankLab:setString(myWarData.rank)
	local intergalLab = myWarLayer:getChildByName("intergalLab")
	intergalLab:setString(myWarData.score)
	local winRateLab = myWarLayer:getChildByName("winPropLab")
	winRateLab:setString(myWarData.winRante)
	
	local curTime = self._userModel:getCurServerTime()
	local mailTime = tab:Setting("CROSS_FIGHT_TIME_RE").value
	mailTime = TimeUtils.getTimeStampWithWeekTime(curTime, mailTime, 2)
	local ignore2 = false
	if curTime>=mailTime then
		self._reloadGroupMailReward = true
		ignore2 = true
	else
		self._reloadGroupMailReward = false
	end
	
	--todo lannan
	--[[if table.nums(myWarData.winRecord)>9 then
		for i=table.nums(myWarData.winRecord), 10, -1 do
			table.remove(myWarData.winRecord, i)
		end
	else
		self._viewMgr:showTip("这里有测试代码没删……@lannan")
	end--]]
	
	local rewardPanel = myWarLayer:getChildByName("rewardPanel")
	local rewardId
	local rewardCount = 0
	local limitNum = 0-- ignore2 and table.nums(myWarData.winRecord)-9 or table.nums(myWarData.winRecord)
	if ignore2 then
		limitNum = table.nums(myWarData.winRecord) - 9
	else
		limitNum = table.nums(myWarData.winRecord)>9 and 9 or table.nums(myWarData.winRecord)
	end
	if limitNum>0 then
		for i=1, limitNum do
			local winKey = ignore2 and myWarData.winRecord[i+9] or myWarData.winRecord[i]
			local rewardIdStr = "1"
			if not ignore2 then
				rewardIdStr = rewardIdStr.."2"..i..winKey
			else
				rewardIdStr = rewardIdStr.."3"..i..winKey
			end
			local rewardData = tab.crossFightReward[tonumber(rewardIdStr)]
			if rewardData.Reward[1][1]=="tool" then
				rewardId = rewardData.Reward[1][2]
			elseif rewardData.Reward[1][1]=="crossGodWarCoin" then
				rewardId = IconUtils.iconIdMap.crossGodWarCoin
			end
			rewardCount = rewardCount + rewardData.Reward[1][3]
		end
	end
	if rewardCount>0 then
		if rewardPanel:getChildByName("noRewardIcon")~=nil then
			rewardPanel:getChildByName("noRewardIcon"):removeFromParent()
		end
		local icon = rewardPanel:getChildByName("rewardIcon")
		if not icon then
			icon = IconUtils:createItemIconById({itemId = rewardId, itemData = tab.tool[rewardId], num = rewardCount})
			icon:setName("rewardIcon")
			icon:setAnchorPoint(0.5, 0.5)
			icon:setScale(0.8)
			icon:setPosition(rewardPanel:getContentSize().width/2, rewardPanel:getContentSize().height/2)
			rewardPanel:addChild(icon)
		else
			IconUtils:updateItemIconByView(icon, {itemId = rewardId, itemData = tab.tool[rewardId], num = rewardCount})
		end
	else
		local icon = rewardPanel:getChildByName("noRewardIcon")
		if not icon then
			icon = IconUtils:createHeadIconById({art = "globalImageUI_secretIcon", tp = 4,avatarFrame = 1000})
			icon:setName("noRewardIcon")
			icon:setAnchorPoint(0.5, 0.5)
			icon:setScale(0.8)
			icon:setPosition(rewardPanel:getContentSize().width/2, rewardPanel:getContentSize().height/2)
			rewardPanel:addChild(icon)
		end
	end
	
	self._historyNode = self:getUI("historyNode")
	self._historyNode:setVisible(false)
	local historyBtn = myWarLayer:getChildByName("historyBtn")
	self:registerClickEvent(historyBtn, function()
		local historyLayer = self:getUI("historyLayer")
		local rankPanel = self:getUI("rankPanel")
		if not self._historyState then
			self._historyState = true
			self._serverMgr:sendMsg("CrossGodWarServer", "getGroupReportList", {}, true, {}, function(result)
				self:onInitHistoryLayer()
				rankPanel:setVisible(false)
				historyLayer:setVisible(true)
			end)
			historyBtn:setTitleText("当前战斗")
		else
			self._historyState = false
			historyLayer:setVisible(false)
			rankPanel:setVisible(true)
			historyBtn:setTitleText("对战历史")
		end
	end)
	myWarLayer:setVisible(true)
end

function CrossGodWarView:onInitHistoryLayer()
	local historyLayer = self:getUI("historyLayer")
	self._historyData = self._crossGodWarModel:getGroupReportData()
	historyLayer:getChildByName("noneNode"):setVisible(table.nums(self._historyData)==0)
	if not self._historyTableView then
		local tableBg = historyLayer:getChildByName("tableBg")
		self._historyTableView = cc.TableView:create(tableBg:getContentSize())
		self._historyTableView:setDelegate()
		self._historyTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
		self._historyTableView:setPosition(3, 0)
--		self._historyTableView:registerScriptHandler(function(table) return self:historyScrollViewDidScroll(table) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
		self._historyTableView:registerScriptHandler(function(table, idx) return self:historyCellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
		self._historyTableView:registerScriptHandler(function(table, idx) return self:historyTableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
		self._historyTableView:registerScriptHandler(function(table) return self:historyNumberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
		self._historyTableView:setBounceable(true)
		self._historyTableView:reloadData()
		if self._historyTableView.setDragSlideable ~= nil then 
			self._historyTableView:setDragSlideable(true)
		end
		tableBg:addChild(self._historyTableView)
	else
		self._historyTableView:reloadData()
	end
end

--[[function CrossGodWarView:historyScrollViewDidScroll(view)
	
end--]]

function CrossGodWarView:historyCellSizeForTable(view, idx)
	return 190, 668
end

function CrossGodWarView:historyTableCellAtIndex(view, idx)
	local cell = view:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
	local historyData = self._historyData[idx+1]
	local curWarIndex = self._warIndex
	local curNowState = self._nowState
	local isInBattle = false
	if curNowState == stateCode[4] and curWarIndex == historyData.warIndex then
		isInBattle = true
	end
	local win = historyData.win
	local node = cell:getChildByName("cellNode")
	if not node then
		node = self._historyNode:clone()
		node:setVisible(true)
		node:setName("cellNode")
		node:setPosition(cc.p(0, 0))
		cell:addChild(node)
	end
	local reviewBtn = node:getChildByName("reviewBtn")
	local flagImg = node:getChildByFullName("flagImg")
	flagImg:removeAllChildren()
	if isInBattle then
		reviewBtn:setVisible(false)
		flagImg:loadTexture("godwarImageUI_img139.png", 1)
		local fightAnim = mcMgr:createViewMC("shangfangjian_godwar", true, false)
        fightAnim:setPosition(flagImg:getContentSize().width / 2, flagImg:getContentSize().height / 2)
        flagImg:addChild(fightAnim, 10)
	else
		reviewBtn:setVisible(win ~= nil)
		flagImg:loadTexture("godwarImageUI_img140.png", 1)
	end
	self:registerClickEvent(reviewBtn, function()
		self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = historyData.key}, true, {},  function(result)
			self._isReviewReport = true
			self:reviewTheBattle(result, 0)
		end)
	end)
	local indexImg = node:getChildByName("indexImg")
	indexImg:loadTexture(string.format("crossGodWarImage_war%d.png", historyData.warIndex), 1)
	local isReverse = false
	local myName = self._userModel:getUserName()
	for i=1, 2 do
		local playerData
		if i==1 then
			if historyData.atkData.name==myName then
				playerData = historyData.atkData
			else
				isReverse = true
				playerData = historyData.defData
			end
		else
			playerData = isReverse and historyData.atkData or historyData.defData
		end
--		local playerData = i==1 and historyData.atkData or historyData.defData
		local serverLab = node:getChildByName("serverLab"..i)
		local nameLab = node:getChildByName("nameLab"..i)
		serverLab:setString(string.format("%s", self._crossGodWarModel:getServerNameStr(playerData.serverId)))
		nameLab:setString(playerData.name)
		local scoreTitleLab = node:getChildByName("scoreTitle"..i)
		local scoreLab = node:getChildByName("scoreLab"..i)
		local scoreChangeLab = node:getChildByName("scoreChangeLab"..i)
		if isInBattle then
			scoreTitleLab:setVisible(false)
			scoreLab:setVisible(false)
			scoreChangeLab:setVisible(false)
		else
			scoreTitleLab:setVisible(true)
			scoreLab:setVisible(true)
			scoreChangeLab:setVisible(true)
		end
		if playerData.score then
			scoreLab:setString(playerData.score)
			if playerData.scoreChange>=0 then
				scoreChangeLab:setString("(+"..playerData.scoreChange..")")
				scoreChangeLab:setColor(cc.c3b(28, 162, 22))
			else
				scoreChangeLab:setString("("..playerData.scoreChange..")")
				scoreChangeLab:setColor(cc.c3b(205, 32, 30))
			end
			
			if i==2 then
				scoreChangeLab:setPositionX(node:getContentSize().width-8)
				scoreLab:setPositionX(scoreChangeLab:getPositionX()-scoreChangeLab:getContentSize().width)
				scoreTitleLab:setPositionX(scoreLab:getPositionX()-scoreLab:getContentSize().width)
			else
				scoreChangeLab:setPositionX(scoreLab:getPositionX()+scoreLab:getContentSize().width)
			end
		else
			scoreTitleLab:setString("????")
			scoreLab:setString("?????")
			scoreChangeLab:setString("(???)")
		end
		local flagImg = node:getChildByName("flagImg")
		local resultImg = node:getChildByName("resultImg"..i)
		local headBg = node:getChildByName("headBg"..i)
		local icon = headBg:getChildByName("icon")
		if not icon then
			icon = IconUtils:createHeadIconById({avatar = playerData.avatar, level = playerData.level, tp = 4,avatarFrame = playerData.avatarFrame, plvl = playerData.plvl})
			icon:setName("icon")
			icon:setScale(0.8)
			headBg:addChild(icon)
		else
			IconUtils:updateHeadIconByView(icon, {avatar = playerData.avatar, level = playerData.level, tp = 4,avatarFrame = playerData.avatarFrame, plvl = playerData.plvl})
		end
--		icon:setTouchEnabled(false)
		local teamPanel = node:getChildByName("teamPanel"..i)
		for i = 1, 8 do
			local teamIcon = teamPanel:getChildByName("teamIcon" .. i)
			if teamIcon then
				teamIcon:setVisible(false)
			end
		end
		local teamCount = 1
		local posX = 3
		local posY = 53
		for i,v in pairs(playerData.teams) do
			local teamD = tab:Team(tonumber(i))
			local row = math.ceil(teamCount/4)
			local posY = row==1 and 53 or 3
			if row==1 then
				posX = (teamCount-1)*46
			else
				posX = (teamCount-5)*46
			end
			local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(v.stage)
			local teamIcon = teamPanel:getChildByName("teamIcon"..teamCount)
			if not teamIcon then
				teamIcon = IconUtils:createTeamIconById({teamData = v,sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2], eventStyle=3})
				teamIcon:setScale(45/teamIcon:getContentSize().height)
				teamIcon:setPosition(posX, posY)
				teamIcon:setName("teamIcon"..teamCount)
				teamPanel:addChild(teamIcon, 5)
			else
				teamIcon:setVisible(true)
				IconUtils:updateTeamIconByView(teamIcon, {teamData = v,sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2], eventStyle=3})
			end
			teamCount = teamCount + 1
		end
		if nil~=win then
			resultImg:setVisible(not isInBattle)
			flagImg:setSaturation(isInBattle and 0 or -100)
			if win == 3 then
				resultImg:loadTexture("crossGodWar_peace.png", 1)
				headBg:setSaturation(0)
				teamPanel:setSaturation(0)
			else
				if not isReverse then
					local res = (i == win or isInBattle)
					resultImg:loadTexture(res and "godwarImageUI_img78.png" or "godwarImageUI_img79.png", 1)
					headBg:setSaturation(res and 0 or -100)
					teamPanel:setSaturation(res and 0 or -100)
				else
					local res = (i ~= win or isInBattle)
					resultImg:loadTexture(res and "godwarImageUI_img78.png" or "godwarImageUI_img79.png", 1)
					headBg:setSaturation(res and 0 or -100)
					teamPanel:setSaturation(res and 0 or -100)
				end
			end
		else
			resultImg:setVisible(false)
		end
	end
	return cell
end

function CrossGodWarView:historyNumberOfCellsInTableView(view)
	return table.nums(self._historyData)
end

function CrossGodWarView:updateNewData(callback)
	self._changeStateReq = true
	self._serverMgr:sendMsg("CrossGodWarServer", "enter", {}, true, {}, function(result)
		if callback then
			callback()
			self:updateBulletBtnState()
    		self:showBullet()
		end
	end)
end

function CrossGodWarView:update(dTime)--界面刷新，判断状态
	local nowState = self._nowState
	local titleLab = self._timeTitleLab
	local curTime = self._userModel:getCurServerTime()
	local buzhenPanel = self:getUI("btnbg.buzhenPanel")

	if nowState==stateCode[1] then--当前赛季已经结束,未到下一赛季报名时间。
		local nextTime = self._stateEndTime--下一届开启时间
		local str = string.format("下届开启:")
		if curTime<nextTime then
			str = str..TimeUtils.getTimeStringFont1(nextTime - curTime)
			self._timeTitleLab:setString(str)
		elseif curTime-nextTime>=1 and not self._changeStateReq then
			self:updateNewData(function()
				self._nowState,self._stateEndTime = self:getViewShowState()
				self._changeStateReq = false
				self["onInitState"..self._nowState](self)
			end)
		end
	elseif nowState==stateCode[2] then--报名时间
		local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
		local prepareLab = buzhenPanel:getChildByName("prepareLab")
		local timeLab = buzhenPanel:getChildByName("timeLab")
		local groupLab = self:getUI("btnbg.groupLab")
		if timeLab:isVisible() then
			timeLab:setVisible(false)
		end
		if prepareLab:isVisible() then
			prepareLab:setVisible(false)
		end
		local endTime = self._stateEndTime--TimeUtils.getTimeStampWithWeekTime(curTime, tab.crossFightTime[1].time2, tab.crossFightTime[1].week[2])
		local groupTime = TimeUtils.getTimeStampWithWeekTime(curTime, tab:Setting("CROSS_FIGHT_GROUP_TIME").value, 2)
		if self._signUp then
			local countDownLab = self:getUI("bg.layer1.timeLab")
			if curTime<groupTime then
				countDownLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
			elseif curTime<endTime then
				if buzhenPanel:isVisible() then
					buzhenPanel:setVisible(false)
				end
				if not groupLab:isVisible() then
					groupLab:setVisible(true)
				end
				countDownLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
			elseif curTime-endTime>=1 and not self._changeStateReq then
				self:updateNewData(function()
					self._serverMgr:sendMsg("CrossGodWarServer", "getGroupRival", {}, true, {}, function(result)
						self._changeStateReq = false
						self._needMatchAnim = true
						self._nowState, self._stateEndTime = self:getViewShowState()
						self["onInitState"..self._nowState](self)
					end)
				end)
			end
		else
			if curTime-endTime>=1 then 
				self._nowState, self._stateEndTime = self:getViewShowState()
				self["onInitState"..self._nowState](self)
			end
		end
	elseif nowState==stateCode[3] then--选拔赛准备阶段。可选择参赛阵容，不能修改布阵。
		local timeLab = buzhenPanel:getChildByName("timeLab")
		local endTime = self._stateEndTime
		if curTime<=endTime then
			timeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		elseif curTime-endTime>=1 then
			self._nowState, self._stateEndTime = self:getViewShowState()
			self["onInitState"..self._nowState](self)
		end
	elseif nowState==stateCode[4] then--选拔赛战斗，可以看录像。
		local timeLab = buzhenPanel:getChildByName("timeLab")
		local endTime = self._stateEndTime
		local historyLayer = self:getUI("historyLayer")
		local warTimeLab = self:getUI("bg.layer1.warTimeLab")
		if curTime-endTime>=1 then
			self._nowState, self._stateEndTime = self:getViewShowState()
			if self._nowState==stateCode[3] and not self._changeStateReq then
				self:updateNewData(function()
					self._serverMgr:sendMsg("CrossGodWarServer", "getGroupRival", {}, true, {}, function(result)
						self._needMatchAnim = true
						self._changeStateReq = false
						self["onInitState"..self._nowState](self)
					end)
				end)
			elseif self._nowState~=stateCode[3] and not self._changeStateReq then
				local callback = function ( ... )
			    	self:updateNewData(function()
						self["onInitState"..self._nowState](self)--to state 5 or 6
						self._changeStateReq = false
					end)
			    end
				if self._nowState ~= nowState and self._nowState == stateCode[6] then
					self._serverMgr:sendMsg("CrossGodWarServer", "enter", {}, true, {}, function(result)
			            self._viewMgr:showDialog("crossGod.CrossGodWarAudienceDialog",{callback = callback})
			        end)
				else
					callback()
				end
			end
			if (historyLayer:isVisible()) then
				self._historyTableView:reloadData()
			end
		else
			warTimeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		end

		-- 李志远要加的刷新历史界面数据
		if self._nowState == stateCode[4] and historyLayer:isVisible() and self._warIndex > table.nums(self._historyData) then
			self._serverMgr:sendMsg("CrossGodWarServer", "getGroupReportList", {}, true, {}, function(result)
				self:onInitHistoryLayer()
			end)
		end
	elseif nowState==stateCode[5] then--选拔赛准备阶段，无法操作。
		local endTime = self._stateEndTime--TimeUtils.getTimeStampWithWeekTime(curTime, tab.crossFightTime[1].time2, tab.crossFightTime[1].week[2])
		if self._signUp then
			local countDownLab = self:getUI("bg.layer1.timeLab")
			if curTime<=endTime then
				local mailTime = tab:Setting("CROSS_FIGHT_TIME_RE").value
				mailTime = TimeUtils.getTimeStampWithWeekTime(curTime, mailTime, 2)
				if curTime>=mailTime and not self._reloadGroupMailReward then
					self:onInitMyWarLayer()
					self._reloadGroupMailReward = true
				end
				
				countDownLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
			else
				self._nowState, self._stateEndTime = self:getViewShowState()
				if self._nowState==stateCode[3] and not self._changeStateReq then
					self:updateNewData(function()
						self._serverMgr:sendMsg("CrossGodWarServer", "getGroupRival", {}, true, {}, function(result)
							self._needMatchAnim = true
							self._changeStateReq = false
							self["onInitState"..self._nowState](self)
						end)
					end)
				elseif self._nowState==stateCode[6] and not self._changeStateReq then
					self:updateNewData(function()
						self._changeStateReq = false
						self["onInitState"..self._nowState](self)
					end)
				end
			end
		else
			--显示赛程界面
		end
	elseif nowState==stateCode[6] then--64强赛准备阶段，可以调整布阵。
		local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
		local prepareLab = buzhenPanel:getChildByName("prepareLab")
		local timeLab = buzhenPanel:getChildByName("timeLab")
		if not timeLab:isVisible() then
			timeLab:setVisible(true)
		end
		if not prepareLab:isVisible() then
			prepareLab:setVisible(true)
		end
		local endTime = self._stateEndTime
		if curTime<=endTime then
			timeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
			self._countDownTimeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		elseif curTime-endTime>=1 and not self._changeStateReq then
			self._nowState, self._stateEndTime = self:getViewShowState()
			self:updateNewData(function()
				self["onInitState"..self._nowState](self)
				self._changeStateReq = false
			end)
		end
	elseif nowState==stateCode[7] then--64强淘汰赛准备阶段，选择阵容。
		local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
		local prepareLab = buzhenPanel:getChildByName("prepareLab")
		local timeLab = buzhenPanel:getChildByName("timeLab")
		if not timeLab:isVisible() then
			timeLab:setVisible(true)
		end
		if not prepareLab:isVisible() then
			prepareLab:setVisible(true)
		end
		local endTime = self._stateEndTime
		if curTime<=endTime then
			timeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
			self._countDownTimeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		elseif curTime-endTime>=1 then--and not self._changeStateReq then
			self._nowState, self._stateEndTime = self:getViewShowState()
--			self:updateNewData(function()
				self["onInitState"..self._nowState](self)
--				self._changeStateReq = false
--			end)
			
		end
	elseif nowState==stateCode[8] then--64强淘汰赛，所有人可以看录像。
		local endTime = self._stateEndTime
		self._countDownTimeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		if curTime-endTime>=1 and not self._changeStateReq then
			self._nowState, self._stateEndTime = self:getViewShowState()
			local callback = function ( ... )
				self["onInitState"..self._nowState](self)
				self._changeStateReq = false
			end
			self:updateNewData(function()
				if self._nowState == stateCode[9] then
					local param = {powId = 8, callback = callback}
	        		self._viewMgr:showDialog("crossGod.CrossGodWarResultDialog", param)
	        	else
	        		callback()
				end
			end)

		end
	elseif nowState==stateCode[9] then--8强淘汰赛准备阶段，可以调整布阵。
		local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
		local prepareLab = buzhenPanel:getChildByName("prepareLab")
		local timeLab = buzhenPanel:getChildByName("timeLab")
		if not timeLab:isVisible() then
			timeLab:setVisible(true)
		end
		if not prepareLab:isVisible() then
			prepareLab:setVisible(true)
		end
		local endTime = self._stateEndTime
		if curTime<=endTime then
			timeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
			self._countDownTimeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		elseif curTime-endTime>=1 and not self._changeStateReq then
			self._nowState, self._stateEndTime = self:getViewShowState()
			self:updateNewData(function()
				self["onInitState"..self._nowState](self)
				self._changeStateReq = false
			end)
		end
	elseif nowState==stateCode[10] then--8强淘汰赛准备阶段，可以竞猜+选择阵容。
		local buzhenBtn = buzhenPanel:getChildByName("buzhenBtn")
		local prepareLab = buzhenPanel:getChildByName("prepareLab")
		local prepareLab = buzhenPanel:getChildByName("prepareLab")
		local timeLab = buzhenPanel:getChildByName("timeLab")
		if not timeLab:isVisible() then
			timeLab:setVisible(true)
		end
		if not prepareLab:isVisible() then
			prepareLab:setVisible(true)
		end
		local endTime = self._stateEndTime
		if curTime<=endTime then
			timeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
			self._countDownTimeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		elseif curTime-endTime>=1 and not self._changeStateReq then
			self._nowState, self._stateEndTime,tabIndex = self:getViewShowState()
			self:updateNewData(function()
				self["onInitState"..self._nowState](self)
				self._changeStateReq = false

				if self._nowState == stateCode[11] then
					local chang,powId,ju = self._crossGodWarModel:getPowIdAndChang(tabIndex,self._nowState)
					
					self._serverMgr:sendMsg("CrossGodWarServer", "getWarBattleInfo", {pow = powId , round = ju}, true, {}, function(result1)
						if result1.reportKey then
							self._serverMgr:sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = result1.reportKey}, true, {},  function(result)
								self:reviewTheBattle(result, 0)
							end)
						else
							self:reviewTheBattle(result1, 0)
						end
						
					end)
				end

			end)
		end
	elseif nowState==stateCode[11] then
		local liveBtn = self:getUI("btnbg.liveBtn")
		if not liveBtn:isVisible() then
			liveBtn:setVisible(true)
		end
		local endTime = self._stateEndTime
		self._countDownTimeLab:setString(TimeUtils.getStringTimeForInt(endTime-curTime))
		if curTime-endTime>=1 and not self._changeStateReq then
			local callback = function ( ... )
				self._nowState,self._stateEndTime = self:getViewShowState()
				self["onInitState"..self._nowState](self)
				self._changeStateReq = false
			end
			self:updateNewData(function()
				if self._warIndex == 4 then
					local param = {powId = 4, callback = callback}
	        		self._viewMgr:showDialog("crossGod.CrossGodWarResultDialog", param)
				elseif self._warIndex == 6 then
					local param = {powId = 2, callback = callback}
	        		self._viewMgr:showDialog("crossGod.CrossGodWarResultDialog", param)
				elseif self._warIndex == 8 then
					local param = {callback = callback}
					self._viewMgr:showDialog("crossGod.CrossGodWarBirthChampionDialog", param)
				else
					callback()
				end
			end)
			-- 4强 决赛  冠军产生 展示界面
		end
	elseif nowState==stateCode[12] then
		local endTime = self._stateEndTime
		if curTime-endTime>=1 and not self._changeStateReq then
			self:updateNewData(function()
				self._nowState, self._stateEndTime = self:getViewShowState()
				self["onInitState"..self._nowState](self)
				self._changeStateReq = false
			end)
		end
	end
	
end

function CrossGodWarView:initBattleData( reportData )
    return BattleUtils.jsonData2lua_battleData(reportData)
end

function CrossGodWarView:reviewTheBattle(result, replayType, showDraw)
    if not result then
        return
    end
    -- dump(result, "-----", 2)
    local nowState = self._nowState
    self._battleFight = true
	local userid = self._userModel:getData()._id
    replayType = 2
    local left = self:initBattleData(result.atk)
    local right = self:initBattleData(result.def)
    local reverse = false
    local showSkill = false
    local isReverse = (nowState == stateCode[4] or nowState == stateCode[3] or nowState == stateCode[5])
    if userid == result.def.rid then
    	if isReverse then
        	reverse = true
        end
        replayType = 0
        showSkill = true
        right.isShowInc = isReverse
        right.isReviewReport = self._isReviewReport
        right.isMySelf = true
        right.highestFightScore = self._crossGodWarModel:getHighestFightScore()
        if not self._isReviewReport then
        	right.crossGodWarRewardId = self:getBattleScoreAndRewardId()
        end
    end
    if userid == result.atk.rid then
        replayType = 0
        showSkill = true
        left.isShowInc = isReverse
        left.isReviewReport = self._isReviewReport
        left.isMySelf = true
        left.highestFightScore = self._crossGodWarModel:getHighestFightScore()
        if not self._isReviewReport then
        	left.crossGodWarRewardId = self:getBattleScoreAndRewardId()
        end
    end

    if self._isReviewReport then
    	self._isReviewReport = nil
    end
    if not showDraw then
        showDraw = false
    end
    
    BattleUtils.disableSRData()
    BattleUtils.enterBattleView_CrossGodWar(left, right, result.r1, result.r2, replayType, reverse, showDraw, showSkill,
    function (info, callback)
        callback(info)
    end,
    function (info)
        -- 退出战斗
        self:exitBattle()
    end)
end

function CrossGodWarView:showSelectFormationDialog()
	local _1,_2,tabIndex = self:getViewShowState()
	local type = 1
	if tabIndex <= 19 then
		type = 1
	elseif tabIndex <= 38 then
		type = 2
	elseif tabIndex <= 45 then
		type = 3
	elseif tabIndex <= 61 then
		type = 4
	end
	local param = {
        type  = type
    }
	self._serverMgr:sendMsg("CrossGodWarServer","getFormationUseInfo",param,true,{},function ( result )
	    UIUtils:reloadLuaFile("crossGod.CrossGodWarSelectFormationView")
		local callback = function(state)
			if self._nowState == state then
				--只刷新英雄形象
				self:reflashHeroMc()
				-- self["onInitState"..state](self)
			end
		end
		self._viewMgr:showDialog("crossGod.CrossGodWarSelectFormationView",{state = self._nowState, callback = callback, useInfo = result or {} },true,true)
	end)
end

function CrossGodWarView:progressGodWarBullet(notCleanBullet)
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 00:00:00"))
    local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime >= begTime and curServerTime <= endTime then
        curServerTime = curServerTime - 86400
        weekday = tonumber(TimeUtils.date("%w", curServerTime))
    end
    self._sysBullet = tab:Bullet("CrossFight")
    -- local godWarConstData = self._userModel:getGodWarConstData()
    -- local begTime = godWarConstData["RACE_BEG"]
    if begTime == 1 then
        self._sysBullet = nil
    end
    local bulletBtn = self:getUI("rightMenuNode.barrage")
    local bulletLab = self:getUI("rightMenuNode.bulletLab")
    if self._sysBullet == nil then 
        bulletBtn:setVisible(false)
        bulletLab:setVisible(false)
        if not notCleanBullet then
            BulletScreensUtils.clear()
        end
        return
    else
        bulletBtn:setVisible(true)
        bulletLab:setVisible(true)
    end
end

function CrossGodWarView:showBullet(notCleanBullet)
    self:progressGodWarBullet(notCleanBullet)
    if self._sysBullet == nil then 
        return
    end
    local bulletBtn = self:getUI("rightMenuNode.barrage")
    local open = BulletScreensUtils.getBulletChannelEnabled(self._sysBullet)
    local fileName = open and "godwarImageUI_img145.png" or "godwarImageUI_img144.png"
    bulletBtn:loadTextures(fileName, fileName, fileName, 1)    
    if open and not notCleanBullet then
        BulletScreensUtils.initBullet(self._sysBullet)
        BulletScreensUtils.show()
    end    
end

function CrossGodWarView:updateBulletBtnState()
    BulletScreensUtils.clear()

    local bulletBtn = self:getUI("rightMenuNode.barrage")
    local bulletLab = self:getUI("rightMenuNode.bulletLab")
    self._sysBullet = tab:Bullet("CrossFight")
    if self._sysBullet == nil then 
        bulletBtn:setVisible(false)
        bulletLab:setVisible(false)
        return
    else
        bulletBtn:setVisible(true)
        bulletLab:setVisible(true)
    end
    bulletLab:enable2Color(1, cc.c4b(255, 195, 17, 255))
    bulletLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self:registerClickEvent(bulletBtn, function ()
        self._viewMgr:showDialog("global.BulletSettingView", {bulletD = self._sysBullet, 
            callback = function (open) 
                local fileName = open and "godwarImageUI_img145.png" or "godwarImageUI_img144.png"
                bulletBtn:loadTextures(fileName, fileName, fileName, 1)       
            end})
    end)    
end

function CrossGodWarView:reflashHeroMc( ... )
	local layer = self:getUI("bg.layer1")
	local leftPanel = layer:getChildByName("leftPanel")

	local useFormationId = self._crossGodWarModel:getUseFormationId()
	local formationData = self._modelMgr:getModel("FormationModel"):getFormationDataByType(useFormationId)
	local heroId = formationData.heroId
	local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId)
	local heroSkin
	if heroData.skin then
		heroSkin = tab.heroSkin[heroData.skin].heroart
	end
	if not heroSkin then
		heroSkin = tab.hero[heroId].heroart
	end
	local heroMc = leftPanel:getChildByName("heroMc")
	if heroMc then
		heroMc:removeFromParent()
	end

	local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
    heroMc = IntanceMcAnimNode.new({"stop", "win"}, heroSkin,
		function(sender) 
			sender:runStandBy()
		end
		,100,100,
		{"stop"},{{3,10},1})
--	heroMc:setOpacity(200)
	heroMc:setPosition(cc.p(leftPanel:getContentSize().width/2, 30))
	heroMc:setName("heroMc")
	leftPanel:addChild(heroMc)
end

function CrossGodWarView:exitBattle()
    self._battleFight = false
end

function CrossGodWarView:getBattleScoreAndRewardId()
	local nowState = self._nowState
	local warIndex = self._warIndex
	local backStr = ""
	if nowState<stateCode[3] then
	elseif nowState<=stateCode[5] then
		local week = warIndex<=9 and "2" or "3"
		local warIndex = warIndex<=9 and warIndex or warIndex-9
		backStr = string.format("1%s%s", week, warIndex)
	elseif nowState<=stateCode[8] then
		backStr = string.format("2%s", warIndex)
	elseif nowState<=stateCode[11] then
		local round
		if warIndex<=4 then
			round = "8"
		elseif warIndex<=6 then
			round = "4"
		elseif warIndex==7 then
			round = "3"
		elseif warIndex==8 then
			round = "2"
		end
		backStr = string.format("3%s", round)
	end
	return backStr
end

--界面显示切换响应状态
function CrossGodWarView:onTop()
	if self._updateId then
		ScheduleMgr:unregSchedule(self._updateId)
		self._updateId = nil
	end
	self._updateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
		self:update(dt)
	end)
end

function CrossGodWarView:onHide()
	if self._updateId then
		ScheduleMgr:unregSchedule(self._updateId)
		self._updateId = nil
	end
end

function CrossGodWarView:destroy()
	if self._updateId then
		ScheduleMgr:unregSchedule(self._updateId)
		self._updateId = nil
		self._serverMgr:sendMsg("CrossGodWarServer", "exitRoom", {}, true, {}, function()
			
		end)
		BulletScreensUtils.clear()
	end
end

function CrossGodWarView:setNavigation()
    local callback = function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("crossGod.CrossGodWarView")
        end
    end
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true, callback = callback})
end

function CrossGodWarView:getBgName()
    return "bg_009.jpg"
end

function CrossGodWarView:changeBgImage(img)
	if self.__viewBg then
		if img then
			self.__viewBg:setTexture(img)
		else
			self.__viewBg:setTexture("asset/bg/"..self:getBgName())
		end
	end
end

function CrossGodWarView:getAsyncRes()
    return {
        {"asset/ui/godwar2.plist", "asset/ui/godwar2.png"},
        {"asset/ui/godwar1.plist", "asset/ui/godwar1.png"},
        {"asset/ui/godwar.plist", "asset/ui/godwar.png"},
        {"asset/ui/crossGodWar.plist", "asset/ui/crossGodWar.png"},
        {"asset/ui/crossGodWar1.plist", "asset/ui/crossGodWar1.png"},
    }
end

return CrossGodWarView