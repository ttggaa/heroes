--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-04-21 11:22:39
--


local MFTaskView = class("MFTaskView",BaseView)
-- local MFTaskView = class("MFTaskView",BasePopView)
function MFTaskView:ctor(data)
    self.super.ctor(self)
    self._mfData = self._modelMgr:getModel("MFModel"):getTasks()
    self._selectIndex = data.index
    self._callback = data.callback
    self._callbackTime = data.callbackTime
end

function MFTaskView:getAsyncRes()
    return 
    {
        -- {"asset/ui/mf1.plist", "asset/ui/mf1.png"},
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function MFTaskView:onInit()
    self._mfModel = self._modelMgr:getModel("MFModel")
	local title = self:getUI("bg.rightBg.panel.titleLab1")
    title:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

	local title = self:getUI("bg.rightBg.panel.titleLab2")
    title:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local title = self:getUI("bg.titleBg.title")
    title:setFontName(UIUtils.ttfName)
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	self._nextUpdateTime = self:getUI("bg.rightBg.panel.nextUpdateTime")
    self._nextUpdateTime:setColor(UIUtils.colorTable.ccUIBaseColor9)
    
	self._startTime = self:getUI("bg.downBg.timeBg.timeLab")
	self._startTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._timeBar = self:getUI("bg.downBg.timeBg.timeBar")

    self._timeBg = self:getUI("bg.downBg.timeBg")
    self._shalou = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
    self._shalou:setName("shalou")
    self._shalou:setScale(1.5)
    self._shalou:setVisible(false)
    self._shalou:setPosition(0, 13)
    self._timeBg:addChild(self._shalou, 10)

    self._jiasu = self:getUI("bg.downBg.jiasu")
    self:registerClickEvent(self._jiasu, function()
        -- local temp = self._modelMgr:getModel("MFModel"):getData()
        -- dump(temp)
        -- self:jiasuAnim()
        self:applyTool()
        -- self._viewMgr:showTip("lalalalalalala")
    end)


	local daoyuIcon = self:getUI("bg.daoyuBg.daoyuIcon")
	local cityTab = tab:MfOpen(self._selectIndex)
	if cityTab.cityimage then
		daoyuIcon:loadTexture(cityTab.cityimage .. ".png", 1)
        daoyuIcon:setAnchorPoint(cc.p(0.5, 0.5))
		daoyuIcon:setPosition(cc.p(daoyuIcon:getContentSize().width*0.5, daoyuIcon:getContentSize().height*0.5))
		daoyuIcon:setScale(cityTab["city"][3])
	end

    -- local daoyuBg = self:getUI("bg.daoyuBg")
    self._taskdetail = self:getUI("bg.daoyuBg.taskdetail")
    self._taskdetail:setPosition(cc.p(cityTab["task"][1], cityTab["task"][2]))
    self._taskdetail:setScale(cityTab["task"][3])
    if self._selectIndex < 6 then
        local dibiao = cc.Sprite:create()
        dibiao:setAnchorPoint(cc.p(0.5, 0))
        dibiao:setName("dibiao")
        dibiao:setSpriteFrame("mftask_dibiao" .. self._selectIndex .. ".png")
        dibiao:setPosition(cc.p(self._taskdetail:getContentSize().width*0.5, self._taskdetail:getContentSize().height*0 + 8))
        -- dibiao:setScale(1.2)
        self._taskdetail:addChild(dibiao,1)

        local mc2 = mcMgr:createViewMC("dibiaobg_mfdibiao", true, false)
        mc2:setPosition(cc.p(self._taskdetail:getContentSize().width*0.5, self._taskdetail:getContentSize().height*0 + 15))
        self._taskdetail:addChild(mc2, -1)
    else
        self._taskdetail:setVisible(false)
    end


	self._taskDes = self:getUI("bg.rightBg.panel.taskDes")
	self._rewardDes1 = self:getUI("bg.rightBg.panel.rewardDes1")
	-- self._rewardDes1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	self._rewardDes2 = self:getUI("bg.rightBg.panel.rewardDes2")
	-- self._rewardDes2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	self._rewardValue1 = self:getUI("bg.rightBg.panel.rewardValue1")
	self._rewardValue2 = self:getUI("bg.rightBg.panel.rewardValue2")

    self:listenReflash("MFModel", self.reflashUI)

	self:registerClickEventByName("bg.rightBg.closeBtn",function( )
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFTaskView")
        end
		self:close()
	end)

    local lab60 = self:getUI("bg.downBg.downPanel.Label_60")
    lab60:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- lab60:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._quickAdd = self:getUI("bg.downBg.downPanel.quickAdd")
    self._quickAdd:setVisible(true)
    -- local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl
    -- if userlvl < 45 then
    --     self._quickAdd:setVisible(false)
    -- end
    -- local tempFtask = self._mfModel:getFTask()
    -- if not tempFtask then
    --     self._quickAdd:setVisible(true)
    -- end
    self:registerClickEvent(self._quickAdd, function()
    	self:setpeople()
    	print("一键选人")
    end)

    local bar = self:getUI("bar")
    local jiasuTip = self:getUI("bar.jiasuTip")
    self:registerTouchEvent(bar, nil, nil, function()
        jiasuTip:setVisible(false)
    end, function()
        jiasuTip:setVisible(false)
    end, function()
        jiasuTip:setVisible(true)
    end)

    self._xuanrenAnim = true

	self:setTeamAndHeroData()
	self:reflashUI()
    self:setHanghaiBg()

    self:updateTool()
    self:listenReflash("UserModel", self.updateTool)
end

function MFTaskView:setTeamAndHeroData()
	self._heros = {}
    self._teams = {}
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    local teamModel = self._modelMgr:getModel("TeamModel")
	if mfData["teams"] then
    	local teamsData = string.split(mfData["teams"], ",")
    	for i=1,table.nums(teamsData) do
    		local tempTeamData, _ = teamModel:getTeamAndIndexById(tonumber(teamsData[i]))
    		self._teams[i] = tempTeamData
    	end
	end
	if mfData["heroId"] then
		local heroData = self._modelMgr:getModel("HeroModel"):getData()
		for k,v in pairs(heroData) do
			if tonumber(k) == mfData["heroId"] then
				v.heroId = k
				self._heros = clone(v)
			end
		end
	end
	self:updateSelectPeople()
end

-- 接收自定义消息
function MFTaskView:reflashUI(data)
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)

    -- 任务描述
    self:registerClickEvent(self._taskdetail, function()
        local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
        self._selectHeroTeamView = self._viewMgr:showDialog("MF.MFTaskDetailDialog", {taskId = mfData["taskId"]})
    end)
    dump(mfData)
    print("self._selectIndex ============", self._selectIndex)
    -- self._lastTime = tonumber(TimeUtils.getDateString(curServerTime,"%Y%m%d") .. "0500")
    -- self._nextUpdateTime:setString()

    local taskTab = tab:MfTask(mfData.taskId)
    local starBg = self:getUI("bg.titleBg.starBg")
    local x = (starBg:getContentSize().width - taskTab.star*48)*0.5
    for i=1,5 do
        local iconStar = starBg:getChildByName("star" .. i)
        if i <= taskTab.star then
            if iconStar == nil then
                iconStar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star1.png")
                iconStar:setScale(1)
                iconStar:setAnchorPoint(cc.p(0, 1))
                starBg:addChild(iconStar,3) 
                iconStar:setName("star" .. i)
            else
                iconStar:setVisible(true)
            end
            iconStar:setPosition(x, starBg:getContentSize().height+1)
            x = x + iconStar:getContentSize().width*iconStar:getScaleX()
        else
            if iconStar then
                iconStar:setVisible(false)
            end
        end
    end
    local title = self:getUI("bg.titleBg.title")
    title:setString(lang(taskTab.name))

    local chanliang = self:getUI("bg.rightBg.chanliang")
    if taskTab.starShow then
        local chimg = self:getUI("bg.rightBg.chanliang.chimg")
        chimg:loadTexture("mfimg_schanchuqipao" .. taskTab.starShow .. ".png", 1)
        chanliang:setVisible(true)
    else
        chanliang:setVisible(false)
    end

    self:setNextUpdateTime()
	self:updateTask()
	self:setTaskDes()
	self:setAward()
    self:updateSelectPeople()
end

-- 更新任务状态
function MFTaskView:updateTask()
    local startTask = self:getUI("bg.downBg.downPanel.startTask")
	local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local taskTab = tab:MfTask(mfData["taskId"])
	if mfData["finishTime"] then
        -- self._quickAdd:setVisible(false)
        if (mfData["finishTime"] - curServerTime) <= 0 then
            -- if not self._jindutiao then
            --     self._jindutiao = mcMgr:createViewMC("jindutiao2_mfdibiao", true, false)
            --     self._jindutiao:setPosition(cc.p(self._timeBg:getContentSize().width*0.5, self._timeBg:getContentSize().height*0.5))
            --     self._timeBg:addChild(self._jindutiao)
            -- else
            --     self._jindutiao:setVisible(true)
            -- end

            if self._renwuStart then
                self._renwuStart:removeFromParent()
                self._renwuStart = nil
            end

            if self._baoxiang then
                self._baoxiang:removeFromParent()
                self._baoxiang = nil
            end

            local daoyuIcon = self:getUI("bg.daoyuBg.daoyuIcon")
            if taskTab["icon"] then
                if not self._animTeamIcon then
                    self._animTeamIcon = ccui.ImageView:create()
                    self._animTeamIcon:loadTexture("mfImg_qipao.png", 1)
                    self._animTeamIcon:setAnchorPoint(cc.p(0.1, 0))
                    self._animTeamIcon:setPosition(cc.p(daoyuIcon:getContentSize().width*0.5, daoyuIcon:getContentSize().height*0.5))
                    daoyuIcon:addChild(self._animTeamIcon, 1000)

                    local move1 = cc.MoveBy:create(0.5, cc.p(0, 5))
                    local move3 = cc.MoveBy:create(0.5, cc.p(0, 5))
                    local move2 = cc.MoveBy:create(0.5, cc.p(0, -5))
                    local move4 = cc.MoveBy:create(0.5, cc.p(0, -5))
                    local seq = cc.Sequence:create(cc.ScaleTo:create(0.3, 1), move1, move2, cc.ScaleTo:create(0.2, 0), cc.DelayTime:create(2))
                    self._animTeamIcon:runAction(cc.RepeatForever:create(seq))
                end

                local param = {itemId = taskTab["icon"], effect = true, eventStyle = 1, num = -1}
                if self._animTeamqipao then
                    IconUtils:updateItemIconByView(self._animTeamqipao, param)
                else
                    local animTeamqipao = IconUtils:createItemIconById(param)
                    animTeamqipao:setName("animTeamqipao")
                    animTeamqipao:setAnchorPoint(cc.p(0.5, 0.5))
                    animTeamqipao:setCascadeOpacityEnabled(true)
                    animTeamqipao:setPosition(cc.p(self._animTeamIcon:getContentSize().width*0.5, self._animTeamIcon:getContentSize().height*0.5+3))
                    self._animTeamIcon:addChild(animTeamqipao, 99)
                    animTeamqipao:setScale(0.43)
                    self._animTeamqipao = animTeamqipao
                end
                self._animTeamIcon:setVisible(true)

                self._baoxiang = mcMgr:createViewMC("stop_bangzhucaihong", true, false)
                self._baoxiang:setName("stop")
                self._baoxiang:setScale(0.8)
                self._baoxiang:setPosition(cc.p(daoyuIcon:getContentSize().width*0.5, daoyuIcon:getContentSize().height*0.5-20))
                daoyuIcon:addChild(self._baoxiang, 99)
            else
                self._baoxiang = mcMgr:createViewMC("stop2_bangzhucaihong", true, false)
                self._baoxiang:setName("stop")
                self._baoxiang:setScale(0.8)
                self._baoxiang:setPosition(cc.p(daoyuIcon:getContentSize().width*0.5, daoyuIcon:getContentSize().height*0.5-20))
                daoyuIcon:addChild(self._baoxiang, 99)
            end
        
            if self._timeBg then
                self._timeBg:setVisible(false)
            end
            startTask:setTitleText("领取奖励")
            self._quickAdd:setSaturation(-100)
            self._jiasu:setVisible(false)
            -- self._timeBg:setVisible(false)
            self:registerClickEvent(startTask, function()
                local tempFtask = self._mfModel:getFTask()
                if tempFtask == 1 then
                    self:getfinishMFReward()
                else
                    local gifts = self:getGift(self._selectIndex)
                    self._viewMgr:showDialog("MF.MFAwardDialog", {gifts = gifts, index = self._selectIndex, callback = function()
                        self._timeBg:setVisible(true)
                        self._timeBar:setScaleX(0)
                        self._shalou:setVisible(false)
                        self._baoxiang:setVisible(false)
                        -- self._quickAdd:setVisible(true)
                        self._jiasu:setVisible(false)
                        self._xuanrenAnim = false
                        self._heros = {}
                        self._teams = {}
                        self:updateSelectPeople()
                    end}) 
                end
            end)
        else
            -- if not self._jindutiao then
            --     self._jindutiao = mcMgr:createViewMC("jindutiao2_mfdibiao", true, false)
            --     self._jindutiao:setPosition(cc.p(self._timeBg:getContentSize().width*0.5, self._timeBg:getContentSize().height*0.5))
            --     self._timeBg:addChild(self._jindutiao)
            -- else
            --     self._jindutiao:setVisible(true)
            -- end

            if self._renwuStart then
                self._renwuStart:removeFromParent()
                self._renwuStart = nil
            end
            -- dump(taskTab, "taskTab===")
            local cityTab = tab:MfOpen(self._selectIndex)
            local pos = cityTab["cameracature"]
            -- dump(pos, "pos===")
            local daoyuPos = taskTab["cameracatureCo"]
            self._renwuStart = mcMgr:createViewMC(taskTab["cameracature"], true, false)
            -- self._renwuStart:setPosition(cc.p(0,0))
            local daoyuIcon = self:getUI("bg.daoyuBg.daoyuIcon")
            local sca = pos[daoyuPos][3]*cityTab["city"][3]
            print("sca =====", pos[daoyuPos][3], cityTab["city"][3])
            self._renwuStart:setPosition(cc.p(pos[daoyuPos][1]*sca, pos[daoyuPos][2]*sca))
            self._renwuStart:setScale(pos[daoyuPos][3])
            daoyuIcon:addChild(self._renwuStart)

            self._quickAdd:setTouchEnabled(false)
            self._quickAdd:setSaturation(-100)
            self._jiasu:setVisible(true)
            startTask:setTitleText("取消任务")
            self:registerClickEvent(startTask, function()
                self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = "你确定要取消任务？现在取消任务无法获得任何奖励", button1 = "", callback1 = function( )
                    self:cancleMF()
                end, 
                button2 = "", callback2 = nil,titileTip=true},true)
            end)
        end
	else
        -- self._quickAdd:setVisible(true)
        self._quickAdd:setTouchEnabled(true)
        self._quickAdd:setSaturation(0)
        self._jiasu:setVisible(false)
		startTask:setTitleText("开始任务")
        if self._jindutiao then
            self._jindutiao:setVisible(false)
        end
        if self._renwuStart then
            self._renwuStart:setVisible(false)
            -- self._renwuStart = nil
        end
        self:registerClickEvent(startTask, function()
            if (not self._heros) or (not self._heros.heroId)  then
                self._viewMgr:showTip("没有派遣执行任务的英雄")
            elseif table.nums(self._teams) < taskTab.num then
                self._viewMgr:showTip("没有足够的兵团")
            else
                self:startMF()
            end
        end)    
	end

	self:setTaskDes()
end

-- 处理奖品
function MFTaskView:getGift(index)
    local mfModel = self._modelMgr:getModel("MFModel")
    local mfData = mfModel:getTasksById(index)

    local tempCon1 = mfModel:getTaskFinish(index, mfData["condition"]["1"])
    local tempCon2 = mfModel:getTaskFinish(index, mfData["condition"]["2"])

    local taskTab = tab:MfTask(mfData["taskId"])
    local gifts = {}

    for k,v in pairs(taskTab["awardBase"]) do
        gifts[v[1] .. v[2]] = clone(v)
    end

    -- if true then
    if tempCon1 >= mfData["condition"]["1"]["param2"] then
        for k,v in pairs(taskTab["awardOne"]) do
            local str = v[1] .. v[2]
            if not gifts[str] then
                gifts[str] = clone(v)
            else
                gifts[str][3] = gifts[str][3] + v[3]
            end
        end
    end
    
    if tempCon2 >= mfData["condition"]["2"]["param2"] then
        for k,v in pairs(taskTab["awardTwo"]) do
            local str = v[1] .. v[2]
            if not gifts[str] then
                gifts[str] = clone(v)
            else
                gifts[str][3] = gifts[str][3] + v[3]
            end
        end
    end

    local tempGifts = {}
    for k,v in pairs(gifts) do
        table.insert(tempGifts, v)
    end

    local sortFunc = function(a, b)
        local atsort = a[2]
        local btsort = b[2]
        if atsort == nil or btsort == nil then
            return 
        end
        if atsort ~= btsort then
            return atsort < btsort
        else
            if IconUtils.iconIdMap[a[1]] > IconUtils.iconIdMap[b[1]] then
                return true
            end
        end
    end
    table.sort(tempGifts, sortFunc)

    tempGifts[1][3] = tempGifts[1][3] + mfModel:getMFGoldNum(index)
    
    return tempGifts
end

-- 设置上阵英雄和兵团
function MFTaskView:updateSelectPeople()
	-- self._heros = {}
 --    self._teams = {}
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    -- dump(mfData)
    local taskTab = tab:MfTask(mfData["taskId"])
    local teamModel = self._modelMgr:getModel("TeamModel")

    -- local selectData = {teamData = clone(self._teams), heroData = clone(self._heros)}
    if table.nums(self._teams) > 0 then
    	for i=1,4 do
    		local teamBg = self:getUI("bg.downBg.downPanel.teamBg" .. i)
    		local none = self:getUI("bg.downBg.downPanel.teamBg" .. i .. ".none")
            none:setVisible(true)
    		if i <= taskTab.num then
    			teamBg:setVisible(true)
	    		if self._teams[i] then
	    			none:setVisible(false)
	    			-- local tempTeamData, _ = teamModel:getTeamAndIndexById(tonumber(teamsData[i]))
	    			local tempTeamData = self._teams[i]
	    			local sysTeam = tab:Team(tempTeamData.teamId)
				    local backQuality = teamModel:getTeamQualityByStage(tempTeamData.stage)
				    local teamIcon = teamBg:getChildByName("teamIcon")
				    if teamIcon == nil then 
				        teamIcon = IconUtils:createTeamIconById({teamData = tempTeamData, sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
				        teamIcon:setName("teamIcon")
				        teamIcon:setPosition(cc.p(116/2 - 18,116/2 - 15))
				        teamIcon:setAnchorPoint(cc.p(0.5, 0.5))
				        -- icon:setRotation(-90)
				        teamIcon:setScale(0.8)
				        teamBg:addChild(teamIcon)
				    else
				        IconUtils:updateTeamIconByView(teamIcon, {teamData = tempTeamData, sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
				    end
                    teamIcon:setVisible(true)
                    if self._xuanrenAnim == false then
                        local mc2 = mcMgr:createViewMC("hanghaiyijianxuanren_mfhanghaiyijianxuanren", false, true)
                        mc2:setPosition(cc.p(teamBg:getContentSize().width*0.5-2, teamBg:getContentSize().height*0.5))
                        teamBg:addChild(mc2, 10)
                    end
	    		else
	    			none:setVisible(true)
                    local teamIcon = teamBg:getChildByName("teamIcon")
                    if teamIcon then
                        teamIcon:setVisible(false)
                    end
	    		end
    		else
    			teamBg:setVisible(false)
                none:setVisible(true)
    		end
    	end
    else
    	for i=1,4 do
    		local teamBg = self:getUI("bg.downBg.downPanel.teamBg" .. i)
    		local none = self:getUI("bg.downBg.downPanel.teamBg" .. i .. ".none")
    		local teamIcon = teamBg:getChildByName("teamIcon")
    		if teamIcon then
    			teamIcon:setVisible(false)
    		end
            
            print("====+++++++++++======", i ,taskTab.num)
    		if i <= taskTab.num then
    			teamBg:setVisible(true)
    			none:setVisible(true)
    		else
    			teamBg:setVisible(false)
    			none:setVisible(true)
    		end
    	end
    end

    for i=1,4 do
        local teamBg = self:getUI("bg.downBg.downPanel.teamBg" .. i)
        self:registerClickEvent(teamBg, function()
            local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
            if mfData["finishTime"] then
                self._viewMgr:showTip("任务正在进行中")
            else
                local teamIds = {}
                for i=1,table.nums(self._teams) do
                    table.insert(teamIds, self._teams[i])
                end
                local selectData = {heroData = self._heros, teamData = self._teams}
                -- self._viewMgr:showDialog("MF.MFSelectHeroTeamView", {selType = "team", selectIndex = self._selectIndex, selectData = selectData, teamId = self._heros["heroId"], callback = function(heroData)
                self._selectHeroTeamView = self._viewMgr:showDialog("MF.MFSelectHeroTeamView", {selType = "team", selectIndex = self._selectIndex, selectData = selectData, callback = function(heroData)
                    self:updateTeamAndHeroData(heroData, "team")
                end})
            end 
        end)
    end

    local heroBg = self:getUI("bg.downBg.downPanel.heroBg")
    local none = self:getUI("bg.downBg.downPanel.heroBg.none")
    if table.nums(self._heros) > 0 then
        -- dump(self._heros)
    	none:setVisible(false)
        local heroIcon = heroBg:getChildByName("heroIcon")
        local sysHeroData = clone(tab:Hero(tonumber(self._heros["heroId"])))
        sysHeroData.star = self._heros["star"]
        if heroIcon then
            IconUtils:updateHeroIconByView(heroIcon, {sysHeroData = sysHeroData})
        else
            heroIcon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
            heroIcon:setName("heroIcon")
            heroIcon:setAnchorPoint(cc.p(0,0))
            heroIcon:setScale(0.83)
            heroIcon:setPosition(cc.p(-2,-3))
            heroBg:addChild(heroIcon)
        end
        if heroIcon then
            heroIcon:setVisible(true)
            heroIcon:getChildByName("starBg"):setVisible(false)
        end
        if self._xuanrenAnim == false then
            local mc2 = mcMgr:createViewMC("hanghaiyijianxuanren_mfhanghaiyijianxuanren", false, true)
            mc2:setPosition(cc.p(heroBg:getContentSize().width*0.5, heroBg:getContentSize().height*0.5))
            heroBg:addChild(mc2, 10)
            self._xuanrenAnim = true
        end
    else
    	none:setVisible(true)
        local heroIcon = heroBg:getChildByName("heroIcon")
        if heroIcon then
            heroIcon:setVisible(false)
        end
    end
    self:registerClickEvent(heroBg, function()
        local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
        if mfData["finishTime"] then
            self._viewMgr:showTip("任务正在进行中")
        else
        	local selectData = {heroData = self._heros, teamData = self._teams}
        	-- self._viewMgr:showDialog("MF.MFSelectHeroTeamView", {selType = "hero", heroId = self._heros["heroId"], selectIndex = self._selectIndex, callback = function(heroData)
        	self._selectHeroTeamView = self._viewMgr:showDialog("MF.MFSelectHeroTeamView", {selType = "hero", selectData = selectData, selectIndex = self._selectIndex, callback = function(heroData)
                -- dump(heroData)
        		self:updateTeamAndHeroData(heroData, "hero")
        	end})
        end 
    end)
	self:updateRightDes()
    self:updateAwardBaseGold()
end

-- 一键选人
function MFTaskView:setpeople()
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    local taskTab = tab:MfTask(mfData["taskId"])
	local selectHero = self._modelMgr:getModel("MFModel"):getMFHeroData()
	local selectTeam = self._modelMgr:getModel("MFModel"):getMFTeamData(self._selectIndex)

    -- dump(selectHero, "selectHero ==========")
    -- dump(selectTeam, "selectTeam ==========")

    for i=1,table.nums(selectHero) do
        if selectHero[i].selectMf ~= 3 then
            self._heros = selectHero[i]
            break 
        end
    end
	
    self._teams = {}
    for i=1,table.nums(selectTeam) do
        if table.nums(self._teams) < taskTab.num then
            if selectTeam[i].selectMf ~= 5 then
                table.insert(self._teams, selectTeam[i])
            end
        else
            break
        end
    end
    
    dump(self._heros, "self._heros============66666666====")
    if (not self._heros) or (not self._heros.heroId) then
        self._viewMgr:showTip("没有足够的英雄派遣执行任务")
    elseif table.nums(self._teams) < taskTab.num then
        self._viewMgr:showTip("没有足够的兵团派遣执行任务")
    end
    -- for i=1,taskTab.num do
    -- 	self._teams[i] = selectTeam[i]
    -- end
	if not self._heros then
		self._heros = {}
	end
	if not self._teams then
		self._teams = {}
	end
	-- dump(self._heros, "self._heros")
	-- print("=====_heros_heros_heros=========", self._heros,table.nums(self._heros))
    self._xuanrenAnim = false
    self:updateSelectPeople()
end

-- 更新兵团和英雄数据
function MFTaskView:updateTeamAndHeroData(data, AddType)
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    local teamModel = self._modelMgr:getModel("TeamModel")
	if AddType == "team" then
		self._teams = data["teamData"]
	else
		self._heros = data["heroData"]
		-- local heroData = self._modelMgr:getModel("HeroModel"):getData()
		-- for k,v in pairs(heroData) do
		-- 	if tonumber(k) == data["heroId"] then
		-- 		v.heroId = k
		-- 		self._heros = clone(v)
		-- 	end
		-- end
	end
	if not self._heros then
		self._heros = {}
	end
	if not self._teams then
		self._teams = {}
	end
	self:updateSelectPeople()
end

function MFTaskView:getTaxScore()
    local teamModel = self._modelMgr:getModel("TeamModel")
    local heroModel = self._modelMgr:getModel("HeroModel")

    local taxHeroScore = heroModel:getHeroGrade(self._heros["heroId"])

    local taxTeamScore = 0
    for i=1,table.nums(self._teams) do
        taxTeamScore = taxTeamScore + teamModel:getTeamAddPingScore(self._teams[i])
        print("taxTeamId====", self._teams[i], taxTeamScore)
    end
    print("taxTeamScore ===", taxTeamScore, "taxHeroScore ===", taxHeroScore)
    return taxTeamScore + taxHeroScore
end

function MFTaskView:getMFGoldNum()
    local mfModel = self._modelMgr:getModel("MFModel")
    local mfData = mfModel:getTasksById(self._selectIndex)

    local taxScore = self:getTaxScore()

    local taskTab = tab:MfTask(mfData["taskId"])
    local goldNum = taskTab["coefficientA"] * taxScore + taskTab["coefficientB"]
    return math.ceil(goldNum*0.1)*10
end

function MFTaskView:updateAwardBaseGold()
    local mfModel = self._modelMgr:getModel("MFModel")
    local mfData = mfModel:getTasksById(self._selectIndex)

    -- local teamModel = self._modelMgr:getModel("TeamModel")
    -- local heroModel = self._modelMgr:getModel("HeroModel")

    -- local taxHeroScore = heroModel:getHeroGrade(self._heros["heroId"])

    -- local taxTeamScore = 0
    -- for i=1,table.nums(self._teams) do
    --     taxTeamScore = taxTeamScore + teamModel:getTeamAddPingScore(self._teams[i])
    -- end
    -- print("taxHeroScore ===", taxTeamScore, "taxHeroScore ===", taxHeroScore)
    local goldNum = self:getMFGoldNum()
    if goldNum <= 500 then
        goldNum = "???"
    end
    local taskTab = tab:MfTask(mfData["taskId"])
    local itemBg = self:getUI("bg.rightBg.panel.awardBg1" .. table.nums(taskTab["awardBase"]))
    local itemIcon = itemBg:getChildByName("itemIcon")
    if itemIcon then
        IconUtils:setItemIconByNum(itemIcon, goldNum)
    end
end

function MFTaskView:updateRightDes(selectData)
	local mfModel = self._modelMgr:getModel("MFModel")
    local mfData = mfModel:getTasksById(self._selectIndex)

    local selectData = {heroData = self._heros, teamData = self._teams}
 	local num = mfModel:getMFConditionsByNum(selectData, mfData["condition"]["1"], tab:MfTask(mfData["taskId"])["num"])
    local str = num .. "/" .. mfData["condition"]["1"]["param2"]
    self._rewardValue1:setString(str)
    if num >= mfData["condition"]["1"]["param2"] then
        self._rewardValue1:setColor(UIUtils.colorTable.ccUIBaseColor9)
        -- self._rewardDes1:setColor(cc.c3b(0,255,30))
    else
        self._rewardValue1:setColor(UIUtils.colorTable.ccUIBaseColor6)
        -- self._rewardDes1:setColor(cc.c3b(255,255,255))
    end

    local num = mfModel:getMFConditionsByNum(selectData, mfData["condition"]["2"], tab:MfTask(mfData["taskId"])["num"])
    local str = num .. "/" .. mfData["condition"]["2"]["param2"]
    self._rewardValue2:setString(str)
    if num >= mfData["condition"]["2"]["param2"] then
        self._rewardValue2:setColor(UIUtils.colorTable.ccUIBaseColor9)
        -- self._rewardDes2:setColor(cc.c3b(0,255,30))
    else
        self._rewardValue2:setColor(UIUtils.colorTable.ccUIBaseColor6)
        -- self._rewardDes2:setColor(cc.c3b(255,255,255))
    end
end

-- 描述
function MFTaskView:setTaskDes()
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    local taskTab = tab:MfTask(mfData["taskId"])
    self._taskDes:setString("派遣1名英雄和" .. taskTab["num"] .. "个兵团")
    local str = self:getConditionDes(mfData["condition"]["1"])
    self._rewardDes1:setString(str)
    local str = self:getConditionDes(mfData["condition"]["2"])
    self._rewardDes2:setString(str)
end

-- 获取描述
function MFTaskView:getConditionDes(data)
	local str
    if data["param1"] == 0 then
    	str = self:split(lang("MFDES_" .. data["conId"]), "$des", data["param2"])
    else
        str = self:split(lang("MFDES_" .. data["conId"]), "$des", lang("MFDES_" .. data["conId"] .. "_" .. data["param1"]))
    	str = self:split(str, "$num", data["param2"])
    end
    return str
end

function MFTaskView:split(str,param,reps)
    -- print("str,param,reps ================", str,param,reps)
    if str == "" then
        return str
    end
    local des = string.gsub(str, "{" .. param .. "}", reps)
    -- local des = string.gsub(str,"%b{}",function( lvStr )
    --     return string.gsub(string.gsub(lvStr,param,reps),"[{}]","")
    -- end, 1)
    -- print(des)
    return des 
end

-- 设置奖励
function MFTaskView:setAward()
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    local taskTab = tab:MfTask(mfData["taskId"])
	for i=1,3 do
		local itemBg = self:getUI("bg.rightBg.panel.awardBg1" .. i)
		if i <= table.nums(taskTab["awardBase"]) then
			local itemIcon = itemBg:getChildByName("itemIcon")
			local itemId = taskTab["awardBase"][i][2]
            local num
            if taskTab["awardBase"][i][1] == "tool" then
                num = taskTab["awardBase"][i][3]
            elseif taskTab["awardBase"][i][1] == "gold" then
                itemId = IconUtils.iconIdMap.gold
                num = "???"
            else
                itemId = IconUtils.iconIdMap[taskTab["awardBase"][i][1]]
                num = taskTab["awardBase"][i][3]
            end
			local param = {itemId = itemId, effect = true, eventStyle = 1, num = num}
	        
	        if itemIcon then
	            IconUtils:updateItemIconByView(itemIcon, param)
	        else
	            itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setName("itemIcon")
                local itemNormalScale = itemBg:getContentSize().width/itemIcon:getContentSize().width
	            itemIcon:setScale(itemNormalScale)
	            itemIcon:setPosition(0,0)
	            itemBg:addChild(itemIcon)
	        end
	        itemBg:setVisible(true)
	    else
	    	itemBg:setVisible(false)
		end
	end
    -- local itemGoldBg = self:getUI("bg.rightBg.panel.awardBg1" .. (table.nums(taskTab["awardBase"])+1))
    -- local itemGoldIcon = itemGoldBg:getChildByName("itemGoldIcon")
    -- local itemGoldId = IconUtils.iconIdMap.gold
    -- local numGold = "???"
    -- local param = {itemId = itemGoldId, effect = true, eventStyle = 1, num = numGold}
    
    -- if itemGoldIcon then
    --     IconUtils:updateItemIconByView(itemGoldIcon, param)
    -- else
    --     itemGoldIcon = IconUtils:createItemIconById(param)
    --     itemGoldIcon:setName("itemGoldIcon")
    --     itemGoldIcon:setScale(0.7)
    --     itemGoldIcon:setPosition(cc.p(0,0))
    --     itemGoldBg:addChild(itemGoldIcon)
    -- end
    -- itemGoldBg:setVisible(true)

	for i=1,3 do
		local itemBg = self:getUI("bg.rightBg.panel.awardBg2" .. i)
		if i <= table.nums(taskTab["awardOne"]) then
			local itemIcon = itemBg:getChildByName("itemIcon")
			local itemId = taskTab["awardOne"][i][2]
            if taskTab["awardOne"][i][1] ~= "tool" then
                itemId = IconUtils.iconIdMap[taskTab["awardOne"][i][1]]
            end
			local param = {itemId = itemId, effect = true, eventStyle = 1, num = taskTab["awardOne"][i][3]}
	        if itemIcon then
	            IconUtils:updateItemIconByView(itemIcon, param)
	        else
	            itemIcon = IconUtils:createItemIconById(param)
	            itemIcon:setName("itemIcon")
                local itemNormalScale = itemBg:getContentSize().width/itemIcon:getContentSize().width
                itemIcon:setScale(itemNormalScale)
	            itemIcon:setPosition(cc.p(0,0))
	            itemBg:addChild(itemIcon)
	        end
	        itemBg:setVisible(true)
	    else
	    	itemBg:setVisible(false)
		end
	end

	for i=1,3 do
		local itemBg = self:getUI("bg.rightBg.panel.awardBg3" .. i)
		if i <= table.nums(taskTab["awardTwo"]) then
			local itemIcon = itemBg:getChildByName("itemIcon")
			local itemId = taskTab["awardTwo"][i][2]
            if taskTab["awardTwo"][i][1] ~= "tool" then
                itemId = IconUtils.iconIdMap[taskTab["awardTwo"][i][1]]
            end
			local param = {itemId = itemId, effect = true, eventStyle = 1, num = taskTab["awardTwo"][i][3]}
	        if itemIcon then
	            IconUtils:updateItemIconByView(itemIcon, param)
	        else
	            itemIcon = IconUtils:createItemIconById(param)
	            itemIcon:setName("itemIcon")
                local itemNormalScale = itemBg:getContentSize().width/itemIcon:getContentSize().width
                itemIcon:setScale(itemNormalScale)
	            itemIcon:setPosition(cc.p(0,0))
	            itemBg:addChild(itemIcon)
	        end
	        itemBg:setVisible(true)
	    else
	    	itemBg:setVisible(false)
		end
	end
end

-- 设置时间
function MFTaskView:setNextUpdateTime()
	self._startTime:stopAllActions()
	self._nextUpdateTime:stopAllActions()
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    local taskTab = tab:MfTask(mfData["taskId"])
    -- dump(mfData, "mfData ======")
    local lab1 = self:getUI("bg.rightBg.panel.lab1")
    -- local tempValue
    if mfData["finishTime"] then
        lab1:setString("任务正在进行中...")
        -- lab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        lab1:setColor(UIUtils.colorTable.ccUIBaseColor9)
    	-- lab1:setVisible(false)
    	self._nextUpdateTime:setVisible(false)
        self._shalou:setVisible(true)
    	print ("任务已完成")

	    local tempTime = mfData["finishTime"]
	    tempTime = tempTime - self._modelMgr:getModel("UserModel"):getCurServerTime() + 1
        -- 任务开始定时器
	    self._startTime:runAction(cc.RepeatForever:create(
	        cc.Sequence:create(cc.CallFunc:create(function()
	            tempTime = tempTime - 1
	            local tempValue = tempTime
                local hour, minute, second
	            hour = math.floor(tempValue/3600)
	            tempValue = tempValue - hour*3600
	            minute = math.floor(tempValue/60)
	            tempValue = tempValue - minute*60
	            second = math.fmod(tempValue, 60)
	            local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
                local dianStr = ""
                for i=1,(3-math.fmod(tempTime, 4)) do
                    dianStr = dianStr .. "."
                end
	            if tempTime <= 0 then
	            	showTime = "00:00:00"
	            	self._startTime:stopAllActions()
                    self:updateTask()
                    self._startTime:setString(showTime)
                    lab1:setString("任务正在进行中...")
                    self._timeBar:setScaleX(1)
	                print("=========时间到，领取奖励")
                    return
	            end
                if self._startTime then
                    self._startTime:setString(showTime)
                end
                if lab1 then
                    lab1:setString("任务正在进行中" .. dianStr)
                end
	            if self._timeBar then
                    local str = math.ceil(((3600*taskTab.time-tempTime)/(3600*taskTab.time))*100)/100
                    -- local str = math.ceil(((180-tempTime)/(180))*100)
                    if str < 0 then
                        str = 0
                    end
                    self._timeBar:setScaleX(str)
                end
	        end), cc.DelayTime:create(1))
	    ))
    else
        lab1:disableEffect()
        lab1:setString("任务刷新时间:")
        lab1:setColor(cc.c3b(138,92,29))
    	-- lab1:setVisible(true)
        self._timeBar:setScaleX(0)
    	self._nextUpdateTime:setVisible(true)
    	self._startTime:setString("任务所需时间: " .. taskTab.time .. "小时")
        print("任务所需时间")
	    local tempTime = mfData.createTime + tab:Setting("G_MF_TIME").value * 60
        -- print("===", tab:Setting("G_MF_TIME").value * 60)
	    tempTime = tempTime - self._modelMgr:getModel("UserModel"):getCurServerTime() + 1
        -- 任务刷新定时器
	    self._nextUpdateTime:runAction(cc.RepeatForever:create(
	        cc.Sequence:create(cc.CallFunc:create(function()
                -- print("tempTime===", tempTime)
	            tempTime = tempTime - 1
	            local tempValue = tempTime
                local day, hour, minute, second
	            day = math.floor(tempValue/86400) 
	            tempValue = tempValue - day*86400
	            hour = math.floor(tempValue/3600)
	            tempValue = tempValue - hour*3600
	            minute = math.floor(tempValue/60)
	            tempValue = tempValue - minute*60
	            second = math.fmod(tempValue, 60)
	            local showTime = string.format("%d天%.2d:%.2d:%.2d", day, hour, minute, second)
	            if day == 0 then
	                showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
	            end
                -- print("-------============", tempTime)
	            if tempTime <= 0 then 
                    -- print("showTime===", showTime, tempTime)
                    -- dump(mfData, "mfData ======")
	            	showTime = "00:00:00"
	            	self._nextUpdateTime:stopAllActions()
                    -- self:reflashMFTask()
                    self._heros = {}
                    self._teams = {}
                    self:updateSelectPeople()
                    self._nextUpdateTime:setString(showTime)
	                print("=========时间到，请求数据+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

                    if self._selectHeroTeamView and self._selectHeroTeamView.close then
                        self._selectHeroTeamView:close()
                        self._selectHeroTeamView = nil 
                        -- self._viewMgr:closeDialog(self._selectHeroTeamView)
                    end
                    
                    return
	            end
                if self._nextUpdateTime then
                    self._nextUpdateTime:setString(showTime)
                end
	        end), cc.DelayTime:create(1))
	    ))
    end
end

-- function MFTaskView:setTask()
-- 	local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
-- 	if mfData["finishTime"] then
-- 		self:cancleMF()
-- 	else
-- 		self:startMF()
-- 	end
-- end

-- 刷新任务
function MFTaskView:reflashMFTask()
    print("刷新任务")
    local param = {id = self._selectIndex}
    self._serverMgr:sendMsg("MFServer", "reflashMFTask", param, true, {}, function(result) 
        dump(result, "result ===========")
        self._timeBar:setScaleX(0)
        -- self._quickAdd:setVisible(true)
        self:reflashUI()
        self._heros = {}
        self._teams = {}
        self:updateSelectPeople()
        
    end)
end

-- 开始任务
function MFTaskView:startMF()
	local teams = {}
	for i=1,table.nums(self._teams) do
		table.insert(teams, self._teams[i]["teamId"])
	end
	local heros = self._heros.heroId

	local param = {id = self._selectIndex,heroId = heros,teams = teams, rate = 1}
	self._serverMgr:sendMsg("MFServer", "startMF", param, true, {}, function(result) 
		-- dump(result, "result ==========", 20)
        if self._quickAdd then
            -- self._quickAdd:setVisible(false)
            self._shalou:setVisible(true)
        end

        if self.close then
            if self._callback then
                self._callback()
            end
            local tempFtask = self._mfModel:getFTask()
            if tempFtask ~= 1 then
                self:close()
            end
        end
	end)
end

-- 取消任务
function MFTaskView:cancleMF()
	-- local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
	local param = {id = self._selectIndex}
	self._serverMgr:sendMsg("MFServer", "cancleMF", param, true, {}, function(result) 
		dump(result, "result ==========", 20)
        if self._callbackTime then
            self._callbackTime(self._selectIndex)
        end
        self._timeBar:setScaleX(0)
        self._shalou:setVisible(false)
        -- self._quickAdd:setVisible(true)
        self._xuanrenAnim = false
        self._heros = {}
        self._teams = {}
        self:updateSelectPeople()
	end, function(errorId)
        if tonumber(errorId) == 2604 then
            self._viewMgr:showTip("该挂机任务已完成")
        end
    end)
end

function MFTaskView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function MFTaskView:setHanghaiBg()
    local bg = self:getUI("bg")
    -- 背景
    local mc3 = mcMgr:createViewMC("haimian_mfhanghaifengweitexiao", true, false)
    mc3:setName("haimian")
    mc3:setScale(1.5)
    mc3:setPosition(480, 320)
    bg:addChild(mc3, -1)
end

-- 道具使用
function MFTaskView:applyTool()
    local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
    local taskTab = tab:MfTask(mfData.taskId)

    local itemModel = self._modelMgr:getModel("ItemModel")
    local _, tempItemCount = itemModel:getItemsById(400001)
    if tempItemCount >= 1 then
        local mfData = self._modelMgr:getModel("MFModel"):getTasksById(self._selectIndex)
        local curServerTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if mfData["finishTime"] and (mfData["finishTime"] - curServerTime) > 0 then
            local param = {goodsId = 400001, goodsNum = 1, extraParams = json.encode({pos = self._selectIndex})}
            self._serverMgr:sendMsg("ItemServer", "useItem", param, true, {}, function(result) 
                -- dump(result, "result ===", 10)
                -- 进度条缓慢增长
                -- local staPer = self._timeBar:getPercent()
                -- local maxPer = ((tab:Setting("G_MF_TOOL").value*60)/(3600*taskTab.time))*100
                -- local addExp = math.ceil(maxPer)
                -- local tempExp = 1
                -- self._viewMgr:lock(-1)
                -- self._timeBar:stopAllActions()
                -- self._startTime:stopAllActions()
                -- self._timeBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
                --     addExp = addExp - 1
                --     self._timeBar:setPercent(staPer)
                --     if addExp <= 1 or staPer >= 99 then
                --         self._timeBar:setPercent(staPer)
                --         self._timeBar:stopAllActions()
                --         self._viewMgr:unlock()
                --     end
                --     staPer = staPer + tempExp
                -- end), cc.DelayTime:create(0.001))))

                self._modelMgr:getModel("MFModel"):updateTasks(result["d"]["mf"])

                self:jiasuAnim()
            end)
        else
            self._viewMgr:showTip("您的任务未开始或任务已完成")
        end 
    else
        print("400001==========", 400001)
        self._viewMgr:showTip("加速令不足，帮助好友或被好友答谢可获得加速令")
    end
end

function MFTaskView:jiasuAnim()
    local toolLab = self:getUI("bar.toolLab")
    local seq = cc.Sequence:create(
        cc.CallFunc:create(function()
            toolLab:setColor(cc.c3b(0,255,30))
        end),
        cc.ScaleTo:create(0.1,1.2),
        cc.DelayTime:create(0.5),
        cc.ScaleTo:create(0.2,1),
        cc.CallFunc:create(function()
            toolLab:setColor(cc.c3b(255,255,255))
        end)
        )
    toolLab:runAction(seq)

    -- self._jindutiao = mcMgr:createViewMC("jiasu2_bangzhucaihong", false, true)
    -- -- self._jindutiao:setScaleX(0.82)
    -- self._jindutiao:setPosition(cc.p(self._timeBg:getContentSize().width*0.5, self._timeBg:getContentSize().height*0.5))
    -- self._timeBg:addChild(self._jindutiao)

    self:touchPiaoExp()
    self:touchPiaoBtn()

    local titleBg = self:getUI("bg.titleBg.title")
    local mc2 = mcMgr:createViewMC("yanhua_mfhanghaifengweitexiao", false, true)
    mc2:setPosition(titleBg:getContentSize().width*0.5, -40)
    titleBg:addChild(mc2,100)
end

-- 更新道具
function MFTaskView:updateTool()
    local toolLab = self:getUI("bar.toolLab")
    local itemModel = self._modelMgr:getModel("ItemModel")
    local _, tempItemCount = itemModel:getItemsById(400001)
    toolLab:setString(tempItemCount)
end

function MFTaskView:touchPiaoExp()
    local expBar = self:getUI("bg.downBg.timeBg")
    local str = "-" .. tab:Setting("G_MF_TOOL").value .. "分钟"
    local expLab = cc.Label:createWithTTF(str, UIUtils.ttfName, 22)
    expLab:setName("expLabLab")
    expLab:setColor(cc.c3b(0,255,30))
    expLab:enableOutline(cc.c4b(60,30,10,255), 2)
    expLab:setPosition(cc.p(expBar:getContentSize().width/2+10,0))
    expBar:addChild(expLab,10)
    expLab:setOpacity(0)
    local moveExp = cc.MoveBy:create(0.2, cc.p(0,5))
    local fadeExp = cc.FadeOut:create(0.2)
    local spawnExp = cc.Spawn:create(moveExp,fadeExp)
    local spawnExp0 = cc.Spawn:create(cc.MoveBy:create(0.1, cc.p(0,40)),cc.FadeIn:create(0.1))
    local callFunc = cc.CallFunc:create(function()
        expLab:removeFromParent()
    end)
    local seqExp = cc.Sequence:create(spawnExp0, cc.MoveBy:create(0.4, cc.p(0,20)), spawnExp,callFunc)
    expLab:runAction(seqExp)
end

function MFTaskView:touchPiaoBtn()
    local expBar = self:getUI("bg.downBg.jiasu")
    local tempWidget = ccui.Widget:create()
    tempWidget:setContentSize(cc.size(10,10))
    tempWidget:setPosition(cc.p(35, 10))
    expBar:addChild(tempWidget)


    local tipbg = cc.Sprite:createWithSpriteFrameName("mfImg_jiasuTool.png")
    tipbg:setScale(0.5)
    tempWidget:addChild(tipbg)

    local str = "-1"
    local expLab = cc.Label:createWithTTF(str, UIUtils.ttfName, 22)
    expLab:setName("expLabLab")
    expLab:setColor(cc.c3b(255,23,23))
    expLab:enableOutline(cc.c4b(60,30,10,255), 2)
    expLab:setPosition(cc.p(39,0))
    tempWidget:addChild(expLab,10)

    tempWidget:setCascadeOpacityEnabled(true)
    tempWidget:setOpacity(0)

    local moveExp = cc.MoveBy:create(0.2, cc.p(0,5))
    local fadeExp = cc.FadeOut:create(0.2)
    local spawnExp = cc.Spawn:create(moveExp,fadeExp)
    local spawnExp0 = cc.Spawn:create(cc.MoveBy:create(0.1, cc.p(0,60)),cc.FadeIn:create(0.1))
    local callFunc = cc.CallFunc:create(function()
        tempWidget:removeFromParent()
    end)
    local seqExp = cc.Sequence:create(spawnExp0, cc.MoveBy:create(0.4, cc.p(0,20)), spawnExp,callFunc)
    tempWidget:runAction(seqExp)
end

-- 进入动画
function MFTaskView:beforePopAnim()
    local rightBg = self:getUI("bg.rightBg")
    if rightBg then
        -- rightBg:setVisible(false)
        local x, y = rightBg:getPositionX() + 170, rightBg:getPositionY()
        rightBg:setPosition(x, y)
    end

    local downBg = self:getUI("bg.downBg")
    if downBg then
        local x, y = downBg:getPositionX(), downBg:getPositionY()-80
        downBg:setPosition(x, y)
    end

    local titleBg = self:getUI("bg.titleBg")
    if titleBg then
        local x, y = titleBg:getPositionX()+80, titleBg:getPositionY()
        titleBg:setPosition(x, y)
    end
end

 
function MFTaskView:popAnim(callback)
    local daoyuBg = self:getUI("bg.daoyuBg")
    if daoyuBg then
        daoyuBg:setVisible(false)
        ScheduleMgr:nextFrameCall(self, function()
            if tolua.isnull(daoyuBg) then
                self.__popAnimOver = true
                if callback then callback() end
                return 
            end
            daoyuBg:setVisible(true)
            daoyuBg:stopAllActions()
            daoyuBg:setScale(0.7)
            daoyuBg:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.15, 1.05), 3), 
                cc.ScaleTo:create(0.10, 1.0),
                cc.CallFunc:create(function ()
                    self.__popAnimOver = true
                    if callback then callback() end
                end)
            ))
        end)
    end

    local rightBg = self:getUI("bg.rightBg")
    if rightBg then
        rightBg:setVisible(false)
        ScheduleMgr:nextFrameCall(self, function()
            if tolua.isnull(rightBg) then return end
            rightBg:stopAllActions()
            rightBg:setVisible(true)
            local x, y = rightBg:getPositionX()-170, rightBg:getPositionY()
            rightBg:setPosition(x+170, y)
            rightBg:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(x - 8, y)), 3),
                cc.MoveTo:create(0.07, cc.p(x, y))
            ))
        end)
    end

    local titleBg = self:getUI("bg.titleBg")
    if titleBg then
        titleBg:setVisible(false)
        ScheduleMgr:nextFrameCall(self, function()
            if tolua.isnull(titleBg) then return end
            titleBg:stopAllActions()
            titleBg:setVisible(true)
            local x, y = titleBg:getPositionX()-80, titleBg:getPositionY()
            titleBg:setPosition(x, y+80)
            titleBg:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(x, y-5)), 3),
                cc.MoveTo:create(0.07, cc.p(x, y))
            ))
        end)
    end

    local downBg = self:getUI("bg.downBg")
    if downBg then
        downBg:setVisible(false)
        ScheduleMgr:nextFrameCall(self, function()
            if tolua.isnull(downBg) then return end
            downBg:stopAllActions()
            downBg:setVisible(true)
            local x, y = downBg:getPositionX(), downBg:getPositionY()+80
            downBg:setPosition(x, y - 80)
            downBg:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(x, y + 5)), 3),
                cc.MoveTo:create(0.07, cc.p(x, y))
            ))
        end)
    end
end

-- 引导期间领取奖励
function MFTaskView:getfinishMFReward()
    self._serverMgr:sendMsg("MFServer", "getfinishMFReward", {id = self._selectIndex}, true, {}, function (result)
        DialogUtils.showGiftGet({gifts = result.reward, callback = function()
            self:finishMF()
        end})
    end)
end

function MFTaskView:finishMF()
    self._serverMgr:sendMsg("MFServer", "finishMF", { id = {self._selectIndex} }, true, {}, function (result)
        -- self._mfModel:setFTask({fTask = 2})
    end)
end

return MFTaskView
