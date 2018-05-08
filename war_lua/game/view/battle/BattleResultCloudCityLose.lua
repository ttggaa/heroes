--
-- Author: <ligen@playcrab.com>
-- Date: 2016-09-15 16:15:31
--
local BattleResultCloudCityLose = class("BattleResultCloudCityLose", BasePopView)

function BattleResultCloudCityLose:ctor(data)
    BattleResultCloudCityLose.super.ctor(self, data)

    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.data
end

function BattleResultCloudCityLose:onInit()
    self._bg = self:getUI("bg")
    self._bg:setEnabled(true)
    self._bg:setSwallowTouches(false)

    self._countBtn = self:getUI("bg.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("Label_128"))

    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setEnabled(true)
    self._bg1:setScaleY(0.1)
    self._bg1:setSwallowTouches(false)
    self._bg1:setOpacity(0)
    self._bg1:setCascadeOpacityEnabled(true,true)

    self._teamNode = self:getUI("bg.teamNode")
    self._teamNode:setVisible(false)
    self._des1 = self._teamNode:getChildByFullName("des1")
    self._des1:setOpacity(0)
    self._des1:setColor(cc.c3b(255, 252, 226))
    self._des1:enable2Color(1, cc.c4b(255, 232, 125, 255))
    self._des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    self._des1:setFontName(UIUtils.ttfName)
    self._des1:setString(lang(tab.towerFight[tonumber(self._result.fightId)].failtip))

    self._touchPanel = self:getUI("touchPanel")
    self._touchPanel:setEnabled(false)

    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    
    -- 人物
	local team
	self._teams = {}
	local invH = 110
	local invW = 100
	local count = #self._battleInfo.leftData
	local colume = 4
	local rowNum = math.ceil(count/colume)
	local beginX = 32 + invW * 0.5
	local beginY = 220 - invH * 0.5
	local teamModel = self._modelMgr:getModel("TeamModel")
	--最佳输出
	local outputID = self._battleInfo.leftData[1].D["id"]
	self._lihuiId = self._battleInfo.leftData[1].D["id"]
	local outputValue = self._battleInfo.leftData[1].damage or 0
	local outputLihuiV = self._battleInfo.leftData[1].damage or 0
	for i = 1,#self._battleInfo.leftData do
		if self._battleInfo.leftData[i].damage then
	        if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputValue) then
	            outputValue = self._battleInfo.leftData[i].damage
	            outputID = self._battleInfo.leftData[i].D["id"]
	        end
	        if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputLihuiV) and self._battleInfo.leftData[i].original then
	            outputLihuiV = self._battleInfo.leftData[i].damage
	            self._lihuiId = self._battleInfo.leftData[i].D["id"]
	        end
	    end
	end

	local curHeroId = self._battleInfo.hero1["id"]
	local initTeamIconFunc = function(id,i)
		local teamD = tab:Team(id)
		local teamData = teamModel:getTeamAndIndexById(id)
		if teamData then
			local quality = teamModel:getTeamQualityByStage(teamData.stage)
	    	team = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2],eventStyle = 0})
	    	team:setAnchorPoint(0.5, 0.5)
	    	-- team:setScale(0.8)
	    	-- 如果有专精变身替换icon
	    	if curHeroId then
	    		local isAwaking, _ = TeamUtils:getTeamAwaking(teamData)
		    	local art,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
		    	if changeId and art then
		    		-- 觉醒优先
		    		if isAwaking then
		    			local tData = tab:Team(changeId)
		    			art = tData.jxart1
		    		end
		    		local teamIcon = team:getChildByFullName("teamIcon")
		    		teamIcon:loadTexture(art .. ".jpg",1)
		    	end
		    end
	    	if i % 4 == 0 then		  
	    		team:setPosition(beginX, beginY)		    		  		
	    		beginX = 32 + invW * 0.5
	    		beginY = beginY - invH
	    	else		    		
	    		team:setPosition(beginX, beginY)
	    		beginX = beginX + invW
	    	end
	    	self._teamNode:addChild(team)
	    	if self._battleInfo.isTimeUp or self._battleInfo.leftData[i].die ~= -1 then
	    		local dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
	    		dieIcon:setPosition(team:getContentSize().width/2,team:getContentSize().height/2)
	    		-- team:setSaturation(-100)
	    		dieIcon:setName("dieImg")
	    		local child = team:getChildren()
	    		for i=1,#child do
	    			if child[i]:getName() ~= "dieImg" then
	    				child[i]:setSaturation(-100)
	    			end
	    		end
	    		team:addChild(dieIcon,100)
	    	end
	    	self._teams[i] = team

	    	if outputID == id and self._battleInfo.leftData[i].die == -1 then
	    		team.isBestOutput = true
	    		self._bestOutID = outputID
	    		local _,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
	    		self._bestOutID = changeId or outputID
	    	end

	    end
	end
	for i = 1, count do
		if self._battleInfo.leftData[i] and not self._battleInfo.leftData[i].copy then
			local id = self._battleInfo.leftData[i].D["id"]
			-- print("=============================",id)
			initTeamIconFunc(id,i)
		end
	end

    self._time = self._battleInfo.time

--    self._iconTable = {}
--    self._fightData = clone(tab.standardopen)
--    self:initFightData()

    self:animBegin()   
end

function BattleResultCloudCityLose:_quit(type, callback)
    if self._callback then
        self._callback(type, callback)
    end
end

function BattleResultCloudCityLose:onQuit()
    self:_quit()
end

function BattleResultCloudCityLose:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

function BattleResultCloudCityLose:animBegin()
    audioMgr:stopMusic()
	audioMgr:playSoundForce("SurrenderBattle")

    local mc2 = mcMgr:createViewMC("shibai_commonlose", true, false, function (_, sender)
        sender:gotoAndPlay(100)
    end)
    local mcPosX,mcPosY = self:getUI("bg.animPos"):getPosition()
    mc2:setPosition(mcPosX, mcPosY)
    self._bg:addChild(mc2)

    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    self._timeLabel:setPosition(mcPosX - 5, mcPosY - 80)
    self._bg:addChild(self._timeLabel, 99)
    if self._time then
    	self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end

    self._bg1:runAction(cc.Spawn:create(cc.FadeIn:create(0.3),cc.ScaleTo:create(0.2,1)))
    
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.8), cc.CallFunc:create(function() 
        if self._touchPanel then
            self._touchPanel:setEnabled(true) 
        end
    end)))

    self._des1:runAction(cc.Sequence:create(cc.DelayTime:create(1.3), cc.FadeIn:create(0.3)))
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.3), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
        if self._countBtn then
            self._countBtn:setEnabled(true)
        end
    end)))

	ScheduleMgr:delayCall(100, self, function(sender)
		self:teamAnim()
	end)
end

function BattleResultCloudCityLose:teamAnim()
   if self._teams then
	    ScheduleMgr:delayCall(100, self, function()
	    	self._teamNode:setVisible(true)
	    	for i = 1, #self._teams do
	    		local team = self._teams[i]
	   			if team then
	   			 	team:setScale(0.5)
	    			team:setVisible(false)
	    			ScheduleMgr:delayCall(i*100, self, function()
	    				team:setVisible(true)
	    				local action = cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.1,0.75))
	    				team:runAction(action)
				    	if team.isBestOutput and true == team.isBestOutput then
					    	-- mcMgr:loadRes("commonresultbest", function ()
				    			ScheduleMgr:delayCall(1000, self, function()
				    				local bestOutImg = ccui.ImageView:create()
			    					bestOutImg:loadTexture("battleCount_bestOut.png",1)
			    					bestOutImg:setScale(3)
			    					bestOutImg:setRotation(30)
			    					bestOutImg:setPosition(team:getContentSize().width / 2, team:getContentSize().height /2)
			    					bestOutImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.8),cc.ScaleTo:create(0.1,1)))
--			    					team:addChild(bestOutImg,101)
					    			team:setZOrder(10)
						      --   	local mc = mcMgr:createViewMC("zuijiashuchu_commonresultbest", false,false)
							     --    mc:setPosition(team:getContentSize().width - 15, team:getContentSize().height - mc:getContentSize().height/2-18)
					    			-- team:addChild(mc,10)
					    			-- team:setZOrder(10)
				    			end)
						    -- end)
						end
					end)
				end
			end
	    end)
	end

end

function BattleResultCloudCityLose:labelAnimTo(label, src, dest, isTime)
	audioMgr:playSound("TimeCount")
	label.src = src
	label.now = src
	label.dest = dest
	label:setString(src)
	label.isTime = isTime
	label.step = 1
	label.updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
		if label:isVisible() then
			if label.isTime then
				local value = math.floor((label.dest - label.now) * 0.05)
				if value < 1 then
					value = 1
				end
				label.now = label.now + value
			else
				label.now = label.src + math.floor((label.dest - label.src) * (label.step / 50))
				label.step = label.step + 1
			end
			if math.abs(label.dest - label.now) < 5 then
				label.now = label.dest
				ScheduleMgr:unregSchedule(label.updateId)
			end
			if label.isTime then
				label:setString(formatTime(label.now))
			else
	        	label:setString(label.now)
	        end
	    end
    end)
end

function BattleResultCloudCityLose.dtor()
    BattleResultCloudCityLose = nil
    toIndexView = nil
end

return BattleResultCloudCityLose