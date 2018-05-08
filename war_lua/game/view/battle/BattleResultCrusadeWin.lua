--[[
    Filename:    BattleResultCrusadeWin.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-14 17:03:07
    Description: File description
--]]

local BattleResultCrusadeWin = class("BattleResultCrusadeWin", BasePopView)

function BattleResultCrusadeWin:ctor(data)
    BattleResultCrusadeWin.super.ctor(self)

    self._result = data.result
    self._callback = data.callback
	self._battleType = data.battleType
    self._battleInfo = data.data
    self._star = self._result.star
    if self._star == nil then
    	self._star = 3
    end
    
end

function BattleResultCrusadeWin:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultCrusadeWin:onInit()
	self._touchPanel = self:getUI("touchPanel")
	self._touchPanel:setSwallowTouches(false)
	self._touchPanel:setEnabled(false)
	self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
	-- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)

	self._bestOutID = nil
	
	self._bg = self:getUI("bg")
    self._rolePanel = self:getUI("bg.role_panel")
    self._rolePanelX , self._rolePanelY = self._rolePanel:getPosition()
    self._roleImg = self:getUI("bg.role_panel.role_img")    
    self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")

    self._bgImg = self:getUI("bg.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._quitBtn = self:getUI("bg_click.quitBtn")
    self._quitBtn:setSwallowTouches(true)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")
    self._bg2 = self:getUI("bg_click.bg2")
    self._bg2:setSwallowTouches(true)
    self._title = self:getUI("bg.title")
    self._title:setScale(2)

    self._gold = self:getUI("bg.gold") 
    local scaleNum1 = math.floor((36/self._gold:getContentSize().width)*100)
    self._gold:setScale(scaleNum1/100)  
    self._goldLabel = self:getUI("bg.goldLabel") 
    self._goldLabel:setFontSize(24) 
    self._goldLabel:enableOutline(cc.c4b(56,24,27, 255), 2)

    self:registerClickEvent(self._quitBtn, specialize(self.onQuit, self))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    self._gold:setOpacity(0)
    self._goldLabel:setOpacity(0)
    self._title:setOpacity(0)
    self._quitBtn:setOpacity(0)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)

    self._goldLabel:setString("")

    local vipImg = self:getUI("bg.addPanel.vipImg")
    local acImg = self:getUI("bg.addPanel.activityImg")
    vipImg:setVisible(false)
    acImg:setVisible(false)

    self._bg1:setVisible(false)
    self._bg2:setVisible(false)
    if self._result.reward then
    	-- 人物
	    local team
	    self._teams = {}
	    local invH = 96
	    local invW = 86
	    local count = #self._battleInfo.leftData
		local colume = 4
		local rowNum = math.ceil(count/colume)
	    local beginX = invW * 0.5
	    local beginY = 200 - invH * 0.5
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
	    local initTeamIconFunc = function(id, i)
	    	local mercenaryId = self._result["mercenaryId"] or 0
	    	local isMercenary = false
	    	if tonumber(id) == tonumber(mercenaryId) then isMercenary = true end
	    	local teamD = tab:Team(id)
	    	local teamData = {}
	    	if isMercenary then
	    		teamData = self._modelMgr:getModel("GuildModel"):getEnemyDataById(id,self._result["userId"])
    		else
    			teamData = teamModel:getTeamAndIndexById(id)
    		end
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
		    		beginX = invW * 0.5
		    		beginY = beginY - invH
		    	else		    		
		    		team:setPosition(beginX, beginY)
		    		beginX = beginX + invW
		    	end
		    	self._bg1:addChild(team)
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

		    	if outputID == id then
		    		team.isBestOutput = true
		    		self._bestOutID = outputID
		    		local _,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
		    		self._bestOutID = changeId or outputID
		    	end

				--佣兵标志
				if isMercenary then
			    	local hireIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI_hireIcon.png") 
			    	hireIcon:setScale(1.4)
			    	hireIcon:setPosition(team:getContentSize().width * 0.5 - 45, 100)
		    		team:addChild(hireIcon,100)	
		    	end	

		    end
	    end
	    for i = 1, count do
	    	if self._battleInfo.leftData[i] and not self._battleInfo.leftData[i].copy then 
		    	local id = self._battleInfo.leftData[i].D["id"]
		    	initTeamIconFunc(id,i)
		    end	    	
	    end

	    -- 物品
	    self._goldValue = 0
	    local reward = {}
	    local _reward = self._result.reward
	    for k,v in pairs(_reward) do
	    	if v.type == "tool" then
	    		reward[#reward + 1] = v

	    	elseif v.type == "crusading" then
	    		reward[#reward + 1] = v
	    		reward[#reward]["typeId"] = IconUtils.iconIdMap["crusading"]
	    		reward[#reward]["num"] = v.num

	    	elseif v.type == "gold" then
	    		self._goldValue = v.num

	    	elseif v.type == "gem" then
    			reward[#reward + 1] = v
    			reward[#reward]["typeId"] = IconUtils.iconIdMap["gem"]

    		elseif v.type == "treasureCoin" then
    			reward[#reward + 1] = v
	    		reward[#reward]["typeId"] = IconUtils.iconIdMap["treasureCoin"]
	    		reward[#reward]["num"] = v.num
	    	end
	    end

	    local itemCount = #reward
	    self._items = {}
	    local inv = 90
	    local posX = (self._bg2:getContentSize().width - itemCount*inv)/2 + inv/2
		local beginX = posX
	    for i = 1, itemCount do
	    	local sysItem = tab:Tool(reward[i].typeId)
	        local item = IconUtils:createItemIconById({itemId = reward[i].typeId, num = reward[i].num, itemData = sysItem})
	        item:setScale(2)
	        item:setAnchorPoint(0.5, 0.5)
	        item:setPosition(beginX + (i - 1) * inv, inv/2)
	        self._bg2:addChild(item)
	        item:setVisible(false)
	        self._items[i] = item
	        if sysItem.typeId == ItemUtils.ITEM_TYPE_TREASURE then
                local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
                mc1:setPosition(item:getContentSize().width/2 ,item:getContentSize().height/2)
                -- mc1:setScale(1.3)
                -- local clipNode = cc.ClippingNode:create()
                -- clipNode:setInverted(false)

                -- local mask = cc.Sprite:createWithSpriteFrameName("golbalIamgeUI5_tmp1.png")
                -- mask:setScale(1.25)
                -- mc1:setPosition(35,35)
                -- mask:setAnchorPoint(0, 0)
                -- clipNode:setStencil(mask)
                -- clipNode:setAlphaThreshold(0.05)
                -- clipNode:addChild(mc1)
                -- clipNode:setPosition(cc.p(5, 5))
                item:addChild(mc1, 10)
	        end
	    end
	end
	self._time = self._battleInfo.time

	local mcMgr = MovieClipManager:getInstance()
    -- mcMgr:loadRes("commonwin", function ()
        self:animBegin()
    -- end)
end

function BattleResultCrusadeWin:onQuit()
	if self._callback then
		self._callback()
		-- UIUtils:reloadLuaFile("battle.BattleResultCrusadeWin")
	end
end

function BattleResultCrusadeWin:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

local delaytick = {360, 380, 380}
function BattleResultCrusadeWin:animBegin()
	audioMgr:stopMusic()
	audioMgr:playSoundForce("WinBattle")

	local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false)	
	liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
	self:getUI("bg_click"):addChild(liziAnim, 1000)

	-- 如果兵团有变身技能，这里改变立汇
    local curHeroId = self._battleInfo.hero1["id"]
    local isChange = false
    local lihuiId = self._lihuiId
    if curHeroId then 
        local _,newId = TeamUtils.changeArtForHeroMastery(curHeroId,self._lihuiId)
        if newId then
            self._lihuiId = newId
            isChange = true
        end
    end

    local teamData = tab:Team(self._lihuiId) 
    if teamData then
        local imgName = string.sub(teamData["art1"], 4, string.len(teamData["art1"]))
        local artUrl = "asset/uiother/team/t_"..imgName..".png"
        -- 觉醒优先
    	local mercenaryId = self._result["mercenaryId"] or 0
    	local isMercenary = false
    	if tonumber(lihuiId) == tonumber(mercenaryId) then isMercenary = true end
    	local tdata = {}
    	-- 雇佣兵
    	if isMercenary then
    		tdata = self._modelMgr:getModel("GuildModel"):getEnemyDataById(lihuiId,self._result["userId"])
		else
			tdata,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(lihuiId)
		end

        local isAwaking,_ = TeamUtils:getTeamAwaking(tdata)
        local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(tdata, tdata.id)
        if isAwaking then 
            -- 结算例会单独处理 读配置
            imgName = teamData.jxart2
            artUrl = "asset/uiother/team/"..imgName..".png"
        end

        if  teamData["jisuan"] then
            local teamX ,teamY = teamData["jisuan"][1], teamData["jisuan"][2]
            local scale = teamData["jisuan"][3] 
            self._roleImg:setPosition(teamX ,teamY)     
            self._roleImgShadow:setPosition(teamX+2,teamY-2)
            self._roleImg:setScale(scale)
            self._roleImgShadow:setScale(scale)
        end
        self._roleImg:loadTexture(artUrl)
        self._roleImgShadow:loadTexture(artUrl) 
	end
		
	local moveDis = 450
	local posRoleX,posRoleY = self._rolePanel:getPosition()
	local posBgX,posBgY = self._bgImg:getPosition()
	-- if not self._rolePanelLow then 
	-- 	self._rolePanelLow = self._rolePanel:clone()
	-- 	self._rolePanelLow:setOpacity(150)
	-- 	self._rolePanelLow:setCascadeOpacityEnabled(true)
	-- 	self._rolePanelLow:setPosition(self._rolePanel:getPosition())
	-- 	self._rolePanel:getParent():addChild(self._rolePanelLow, self._rolePanel:getZOrder()-1)
	-- end
	-- self._rolePanelLow:setPositionX(-moveDis)

	self._rolePanel:setPositionY(-moveDis)
	-- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

	local moveRole = cc.Sequence:create(cc.MoveTo:create(0.05,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
	self._rolePanel:runAction(moveRole)
	-- local moveRoleLow = cc.Sequence:create(cc.DelayTime:create(0.06), cc.MoveTo:create(0.1,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
	-- self._rolePanelLow:runAction(moveRoleLow)
	
	local moveBg = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posBgX,posBgY+20)),cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)))
	self._bgImg:runAction(moveBg)

	local animPos = self:getUI("bg.animPos")
	ScheduleMgr:delayCall(100, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local mc2
        local moveBg = cc.Sequence:create(
        	cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),
        	cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)),
        	cc.CallFunc:create(function()
				--胜利动画
			    mc2 = mcMgr:createViewMC("shengli_commonwin", false)
			    mc2:setPlaySpeed(1.5)
			    mc2:setPosition(animPos:getPositionX(), animPos:getPositionY())
			    self._bg:addChild(mc2, 5)
			end),
			cc.DelayTime:create(0.15),
			cc.CallFunc:create(function()
				-- 底光动画
			   	local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
			    	sender:gotoAndPlay(80)	       
			    end,RGBA8888)
			    mc1:setPosition(animPos:getPosition())

			    local clipNode2 = cc.ClippingNode:create()
			    clipNode2:setInverted(false)

		        local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskHalfCircle.png")
		        mask:setScale(2.5)
		        mask:setPosition(animPos:getPositionX(), animPos:getPositionY() + 140)
		        clipNode2:setStencil(mask)
		        clipNode2:setAlphaThreshold(0.01)
		        clipNode2:addChild(mc1)
		        clipNode2:setAnchorPoint(cc.p(0, 0))
            	clipNode2:setPosition(0, 0)
		        self._bg:addChild(clipNode2,4)
			end),
			cc.DelayTime:create(0.3),
			cc.CallFunc:create(function()
				--震屏
    			UIUtils:shakeWindowRightAndLeft2(self._bg)
				end),
			cc.DelayTime:create(0.15),
			cc.CallFunc:create(function()
				self:animNext(mc2)
				end)
        	)
        self._bgImg:runAction(moveBg)
	end)
end

function BattleResultCrusadeWin:animNext(mc2)	
	-- 动画
    local animPos = self:getUI("bg.animPos")

    local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)

    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName,  26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    self._timeLabel:setPosition(213, -28)
    -- self._timeLabel:setPosition(33, 13)
    mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
    if self._time then
    	self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end

    self._gold:runAction(cc.Sequence:create(cc.FadeIn:create(0.3),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))
    self._goldLabel:runAction(cc.Sequence:create(cc.FadeIn:create(0.3),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))
    -- if self._items and #self._items > 0 then
    -- 	self._title:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(0.3)))
    -- end

    --获得道具title
    local delayT = self._delayT or 0
    if self._items and #self._items > 0 then
    	self._title:runAction(cc.Sequence:create(
    		cc.DelayTime:create(0.5), 
    		cc.FadeIn:create(0.01),
    		-- cc.ScaleTo:create(0.1, 2),
    		cc.CallFunc:create(function()
    			local getAnim = mcMgr:createViewMC("huodedaojuguang_commonwin", false)
    			getAnim:setPosition(self._title:getPositionX(),  self._title:getPositionY() + 4)
    			self._title:getParent():addChild(getAnim, 3)
    			end),
    		cc.EaseOut:create(cc.ScaleTo:create(0.3, 1), 1.5)
    		))
    end


    self._quitBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.3), cc.FadeIn:create(0.3)))
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.3), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
    	self._countBtn:setEnabled(true)
    end)))
	self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
    	self._touchPanel:setEnabled(true)
    end)))

    -- ScheduleMgr:delayCall(100, self, function()
    self:labelAnimTo(self._goldLabel, 0, self._goldValue)
    -- end)

    if self._teams then
	    -- ScheduleMgr:delayCall(100, self, function()
	    	self._bg1:setVisible(true)
	    	for i = 1, #self._teams do
	    		local team = self._teams[i]
	   			if team then
	   			 	team:setScale(0.5)
	    			team:setVisible(false)
	    			ScheduleMgr:delayCall(i*50, self, function()
	    				team:setVisible(true)
	    				local action = cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.1,0.75))
	    				team:runAction(action)
				    	if team.isBestOutput and true == team.isBestOutput then
					    	-- mcMgr:loadRes("commonresultbest", function ()
				    			ScheduleMgr:delayCall(1000, self, function()
				    				local bestOutImg = ccui.ImageView:create()
			    					bestOutImg:loadTexture("battleCount_bestOut.png",1)
			    					bestOutImg:setScale(3)
			    					bestOutImg:setRotation(40)
			    					bestOutImg:setPosition(team:getContentSize().width - 15, team:getContentSize().height - bestOutImg:getContentSize().height/2-5)
			    					bestOutImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.8),cc.ScaleTo:create(0.1,1)))
			    					team:addChild(bestOutImg,10)
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
	    -- end)
	end

    if self._items then
	    ScheduleMgr:delayCall(700, self, function()
	    	-- 显示获得道具
	    	if self._bg2 and self._title then 
		    	self._bg2:setVisible(true)
		    	for i = 1, #self._items do
		    		local item = self._items[i]
		    		item:setScaleAnim(false)
		    		item:runAction(cc.Sequence:create(
		    			cc.DelayTime:create(i * 0.1+0.1), 
		    			cc.CallFunc:create(function()
		    				item:setVisible(true)
			    			local rwdAnim = mcMgr:createViewMC("daojuguang_commonwin", false)
			    			rwdAnim:setPosition(item:getPosition())
			    			item:getParent():addChild(rwdAnim, 7)
			    			end),
		    			cc.Spawn:create(cc.FadeIn:create(0.3), cc.ScaleTo:create(0.3, 0.78)),
		    			cc.CallFunc:create(function() 
		    				item:setScaleAnim(true)
		    				if i == #self._items then
		    				 	self:initAbilityEffect()
		    				end 
		    				end)
		    			))
		    	end
		    end
	    end)
	end
end

function BattleResultCrusadeWin:labelAnimTo(label, src, dest, isTime)
	audioMgr:playSound("TimeCount")
	if dest == nil then return end
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

-- 显示VIP、活动加成
function BattleResultCrusadeWin:initAbilityEffect()
    local vipImg = self:getUI("bg.addPanel.vipImg")
    local vipAddNum = self:getUI("bg.addPanel.vipImg.addNum")
    local acImg = self:getUI("bg.addPanel.activityImg")
    local acAddNum = self:getUI("bg.addPanel.activityImg.addNum")
    vipImg:setVisible(false)
    acImg:setVisible(false)

    local vipAddValue = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).crusadeAdd
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local acAddValue = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_12)
	if self._battleType==BattleUtils.BATTLE_TYPE_GuildFAM then--由于联盟秘境复用结算界面，所以判断当类型为秘境时，不显示远征加成数据
		vipAddValue = 0
		acAddValue = 0
	end

    if tonumber(vipAddValue) > 0 then
        vipImg:setVisible(true)

        vipAddNum:setColor(cc.c3b(255, 252, 226))
        vipAddNum:enable2Color(1, cc.c4b(255, 232, 125, 255))
        vipAddNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        vipAddNum:setString("+" .. vipAddValue .. "%")

        if acAddValue <= 0 then
            vipImg:setPositionX(113)
        end
    end

    if acAddValue > 0 then
        acImg:setVisible(true)

        acAddNum:setColor(cc.c3b(255, 252, 226))
        acAddNum:enable2Color(1, cc.c4b(255, 232, 125, 255))
        acAddNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        acAddNum:setString("+" .. (acAddValue * 100) .. "%")

        if vipAddValue <= 0 then
            acImg:setPositionX(113)
        end
    end
end

function BattleResultCrusadeWin.dtor()
	BattleResultCrusadeWin = nil
end

return BattleResultCrusadeWin