--[[
    Filename:    BattleResultCommonWin.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-09 16:29:51
    Description: File description
--]]

local BattleResultCommonWin = class("BattleResultCommonWin", BasePopView)

function BattleResultCommonWin:ctor(data)
	-- dump(data,"aaaaaaaaaaaaaa",10)
    BattleResultCommonWin.super.ctor(self)
    self._result = data.result
    self._isBranch = data.isBranch
    -- self._battleType = data.battleType  	-- 战斗类型
    self._callback = data.callback
    self._battleInfo = data.data
    self._friendBattleCallback = self._battleInfo and self._battleInfo.friendBattleCallback -- 好友切磋
    self._rewards = data.reward or data.rewards
    self._firstReward = self._result.firstReward   --首次奖励
    self._star = self._result.star
    if self._star == nil then
    	self._star = 3
    end
    if self._star == 3 then 
    	self._starInfo = {true,true,true}
    elseif self._star == 1 then
    	self._starInfo = {true,false,false}
    else
    	if self._battleInfo.dieCount >= 3 then
    		self._starInfo = {true,true,false}
    	else
    		self._starInfo = {true,false,true}
    	end
    end
end

function BattleResultCommonWin:getBgName()
    return "battleResult_bg.jpg"
end

function BattleResultCommonWin:onInit()
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
	self._lihuiId = nil

	self._bg = self:getUI("bg")
	self._rolePanel = self:getUI("bg.role_panel")
	
	self._roleImg = self:getUI("bg.role_panel.role_img")	
	self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")

	self._bgImg = self:getUI("bg.bg_img")
	self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")
	-- self._bgImg:setHue(173)
    
    local bg_click = self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    self._countBtn:setCascadeOpacityEnabled(true)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    self._bg1 = self:getUI("bg.bg1")
    self._bg2 = self:getUI("bg_click.bg2")
    self._bg2:setSwallowTouches(true)
    self._exp = self:getUI("bg.exp") 
    self._expLabel = self:getUI("bg.expLabel") 
    self._expLabel:setFontSize(24)
    self._expLabel:enableOutline(cc.c4b(56,24,27, 255), 2)
    self._gold = self:getUI("bg.gold")           
    local scaleNum1 = math.floor((36/self._gold:getContentSize().width)*100)
    self._gold:setScale(scaleNum1/100)
    self._goldLabel = self:getUI("bg.goldLabel")
    self._goldLabel:setFontSize(24) 
    self._goldLabel:enableOutline(cc.c4b(56,24,27, 255), 2)

    self._title = self:getUI("bg.title")
    self._title:setScale(2)
    -- self._title:setPositionY(self._title:getPositionY()+15)
    -- self._title:setFontName(UIUtils.ttfName)
    
    --通关星级面板
    self._starPanel = self:getUI("bg.starDesPanel")
    -- self._starPanel:setSaturation(-100)
    self._starPanel:setOpacity(0)
    self._starPanel:setCascadeOpacityEnabled(true)
    self._starPanel:setVisible(false)
    self._star1 = self:getUI("bg.starDesPanel.star1")
    self._star1:setSaturation(-100)
    self._star2 = self:getUI("bg.starDesPanel.star2")
    self._star2:setSaturation(-100)
    self._star3 = self:getUI("bg.starDesPanel.star3")
    self._star3:setSaturation(-100)


    self._exp:setOpacity(0)
    self._expLabel:setOpacity(0)
    self._gold:setOpacity(0)
    self._goldLabel:setOpacity(0)
    self._title:setOpacity(0)
    self._countBtn:setOpacity(0)

    self._expLabel:setString("")
    self._goldLabel:setString("")


    self._bg1:setVisible(false)
    self._bg2:setVisible(false)
    if self._result.reward or self._result.rewards or self._rewards  then
        -- dump(self._battleInfo.leftData,"self._battleInfo.leftData1")
    	-- 人物
	    local team
	    self._teams = {}
	    local invH = 100
	    local invW = 86
	    local count = #self._battleInfo.leftData
	    local colume = 4
	    local rowNum = math.ceil(count/colume)
	    local teamModel = self._modelMgr:getModel("TeamModel")
	    local outputID = self._battleInfo.leftData[1].D["id"]
	    self._lihuiId = self._battleInfo.leftData[1].D["id"]
	    local outputValue = self._battleInfo.leftData[1].damage or 0
	    local outputLihuiV = self._battleInfo.leftData[1].damage or 0
		-- dump(self._battleInfo.leftData,"self._battleInfo.leftData==>")
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
	    -- print(self._lihuiId,"=====================",outputLihuiV)
	    if not self._isBranch then
	    	self:getUI("bg.starPanel"):setVisible(true)
	    else
	    	self:getUI("bg.starPanel"):setVisible(false)
	    end

	    local beginX = invW * 0.5
	    local beginY = 220 - invH * 0.5
	    local curHeroId = self._battleInfo.hero1["id"]
	    local initTeamIconFunc = function(id,i)
	    	if teamModel:getTeamAndIndexById(id) then
		    	local teamD = tab:Team(id)
		    	-- dump(self._battleInfo.leftData[i].D,"self._battleInfo.leftData[i].D...")
				local teamData = teamModel:getTeamAndIndexById(id)
				local quality = teamModel:getTeamQualityByStage(teamData.stage)
		    	team = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2],eventStyle = 0})
		    	team:setAnchorPoint(0.5, 0.5)
		    	-- team:setScale(0.5)
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
		    	local expBar = cc.Sprite:createWithSpriteFrameName("exp_bg_battle.png") 
		    	expBar:setPosition(team:getContentSize().width * 0.5, -7)
		    	team.expBar = expBar
		    	team:addChild(expBar)

		    	local exp = cc.Sprite:createWithSpriteFrameName("exp_bar_battle.png") 
		    	exp:setAnchorPoint(0, 0)
		    	exp:setScaleX(0)
		    	team.exp = exp
		    	expBar:addChild(exp)
		    	if outputID == id then
		    		team.isBestOutput = true
		    		-- local _,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
		    		-- self._bestOutID = changeId or outputID
		    	end
		    	
		    	self._teams[i] = team
		    	if self._result.d ~= nil and self._result.d.teams ~= nil then
		    		local teamInfo = self._result.d.teams[""..id]
			    	if teamInfo and teamInfo.exp and teamInfo.totalExp then
				    	team.expPro = tonumber(teamInfo["exp"]) / tonumber(teamInfo["totalExp"])
				    	team.isLevelUp = teamInfo["level"] ~= nil
				    end
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
	    local rewards = {}
	    local tempRewards = self._result.reward or self._rewards 
	    if self._result.rewards then 
	    	-- 支持副本与普通战斗返回奖励格式 edit by vv
			if self._result.rewards[1] ~= nil then
				local _rewards = self._result.rewards[1] 
			    for k, v in pairs(_rewards) do
			    	rewards[#rewards + 1] = v
			    end
			else
				local _rewards = self._result.rewards
				local i = 1
				for k, v in pairs(_rewards) do
			    	rewards[i] = v
			    	i = i + 1
			    end
			end
		end
		-- table.insert(rewards,{num = 1,type = 1,typeId = 3907})
	    local itemCount = table.nums(rewards)
	    if itemCount == 0 and tempRewards then  itemCount = table.nums(tempRewards) end
	    self._items = {}
	    local inv = 90
	    --计算初始位置
	    local posX = (self._bg2:getContentSize().width - itemCount*inv)/2 + inv/2
		local beginX = posX
		--首次奖励reward数据
		local firstId = -1
		if self._firstReward then
			firstId = self._firstReward[2] or self.__firstReward["typeId"] or -1
			if 0 == firstId then
    			firstId = IconUtils.iconIdMap[self._firstReward[1] or self._firstReward["type"]] 
    		end			
		end

	    for i = 1, itemCount do
	    	local item
	    	local itemId
	    	local isFirstAward = false
    		local isEffect = true

	    	if rewards[i] and type(rewards[i]) == "table" then
	    		itemId = rewards[i]["typeId"] or rewards[i][2]
	    		if itemId == 0 then	    			
	    			itemId = IconUtils.iconIdMap[rewards[i]["type"] or rewards[i][1]] 
	    		end
	    		if tonumber(itemId) >= 3100 and tonumber(itemId) <= 4000 then
    				isEffect = false
    			end
    			-- 副本结算 首次奖励标志
    			if tonumber(itemId) == tonumber(firstId) then
    				isFirstAward = true
    			end
	        	item = IconUtils:createItemIconById({itemId = itemId, num = rewards[i]["num"] or rewards[i][3], itemData = tab:Tool(rewards[i]["typeId"] or rewards[i][2]),effect = isEffect,isBranchDrop = true})
	        elseif tempRewards then
	        	itemId = tempRewards[i][2] or tempRewards[i]["typeId"]
	    		if itemId == 0 then
	    			itemId = IconUtils.iconIdMap[tempRewards[i][1] or tempRewards[i]["type"]] 
	    		end
	    		if tonumber(itemId) >= 3100 and tonumber(itemId) <= 4000 then
	    			isEffect = false
	    		end
    			-- 副本结算 首次奖励标志
    			if tonumber(itemId) == tonumber(firstId) then
    				isFirstAward = true
    			end
	        	item = IconUtils:createItemIconById({itemId = itemId, num = tempRewards[i][3] or tempRewards[i]["num"], itemData = tab:Tool( tempRewards[i][2]),effect = isEffect,isBranchDrop = true})
	        end
	        --添加首次通关标志
	        if isFirstAward then
		        local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
		        mc1:setPosition(item:getContentSize().width/2 ,item:getContentSize().height/2)

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
		        item:addChild(mc1,9)
        	        	        	
		        local firstIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")
		        firstIcon:setAnchorPoint(cc.p(1, 0.5))
		        firstIcon:setPosition(item:getContentSize().width, firstIcon:getContentSize().height + 5)
		        item:addChild(firstIcon, 8)

		        local firstTxt = cc.Label:createWithTTF("首次", UIUtils.ttfName, 22)
		        firstTxt:setRotation(41)
		        firstTxt:setPosition(cc.p(45, 37))
		        firstTxt:enableOutline(cc.c4b(146, 19, 5, 255),3)
		        firstIcon:addChild(firstTxt)
		    end

	        item:setScale(2)
	        item:setOpacity(0)
	        item:setAnchorPoint(0.5, 0.5)
	        item:setPosition(beginX + (i - 1) * inv, inv/2)
	        self._bg2:addChild(item)
	        item:setVisible(false)
	        self._items[i] = item
	    end
	    local count = 1
	    if self._result.extend then
		    self._expValue = self._result.extend.userExp or 0
		    self._goldValue = self._result.extend.gold or 0
		    self._expCoinValue = self._result.extend.expCoin or 0
            self._txPlus = self._result.extend.txPlus

            -- self._txPlus = { sq_gamecenter = 1 ,is_qq_vip = 1}
            if self._expValue and self._expValue > 0 then
            	count = count +1
            end
            if self._expCoinValue and self._expCoinValue > 0 then
            	count = count + 1
            end 
            if self._txPlus and tonumber(self._txPlus.sq_gamecenter) and tonumber(self._txPlus.sq_gamecenter) >= 0 then
            	count = count + 1
            end
            if self._txPlus and tonumber(self._txPlus.is_qq_vip) and tonumber(self._txPlus.is_qq_vip) >= 0 then
            	count = count + 1
            end
            if self._txPlus and tonumber(self._txPlus.wx_gamecenter) and tonumber(self._txPlus.wx_gamecenter) >= 0 then
            	count = count + 1
            end
            if self._txPlus and tonumber(self._txPlus.is_qq_svip) and tonumber(self._txPlus.is_qq_svip) >= 0 then
            	count = count + 1
            end
            self:initResIconPos(count)
            if self._txPlus and next(self._txPlus) ~= nil then
                self:initTxPlus()
            end
            --经验货币icon
            if self._expValue > 0 and self._expCoinValue > 0 then
            	self:initExpCoin()
            end
		end
	end

	self._time = self._battleInfo.time

	local mcMgr = MovieClipManager:getInstance()
    -- mcMgr:loadRes("commonwin", function ()
        self:animBegin()
    -- end)
end

--[[
	根据获得资源数量调整资源icon位置
]]
function BattleResultCommonWin:initResIconPos(count)
	if count == 5 then
		self._gold:setPositionX(self._gold:getPositionX() - 47)
		self._goldLabel:setPositionX(self._goldLabel:getPositionX() - 47)
	elseif count == 4 then
		self._gold:setPositionX(self._gold:getPositionX() - 25)
		self._goldLabel:setPositionX(self._goldLabel:getPositionX() - 25)
	end
end

function BattleResultCommonWin:initTxPlus()
    self._gold:setPositionX(self._gold:getPositionX() - 15)
    self._goldLabel:setPositionX(self._goldLabel:getPositionX() - 15)

    local tModel = self._modelMgr:getModel("TencentPrivilegeModel")
    local tTab = tab.qqVIP
    local plusNum = 0
    self._tencentIconList = {}

    local iconValue = {}
    iconValue[tModel.QQ_GAME_CENTER] = {fileName = "tencentIcon_qq.png", scale = 1, plusV = tTab[3].up}
    iconValue[tModel.IS_QQ_VIP] = {fileName = "tencentIcon_qqVip.png", scale = 1, plusV = tTab[5].up}
    iconValue[tModel.IS_QQ_SVIP] = {fileName = "tencentIcon_qqSVip.png", scale = 1, plusV = tTab[6].up}
    iconValue[tModel.WX_GAME_CENTER] = {fileName = "tencentIcon_wxHead.png", scale = 1, plusV = tTab[1].up}


    for k, v in pairs(self._txPlus) do
        local iconParam = iconValue[k]
        if iconParam then
            local icon = cc.Sprite:createWithSpriteFrameName(iconParam.fileName)
            table.insert(self._tencentIconList, icon)

            plusNum = plusNum + iconParam.plusV
        else
            print("txPlus 参数有误")
        end
    end

    self._bg = self:getUI("bg")
    local posX = self._gold:getPositionX() + 95
    local iconW = 0
    for i = 1, #self._tencentIconList do
        local icon = self._tencentIconList[i]
        icon:setPosition(posX + icon:getContentSize().width*0.5 + 2, 415)
        icon:setOpacity(0)
        self._bg:addChild(icon, 99)

        posX = posX + icon:getContentSize().width + 2
        iconW = iconW + icon:getContentSize().width
    end

    self._plusLabel = cc.Label:createWithTTF("+" .. plusNum .. "%)", UIUtils.ttfName, 22)
    self._plusLabel:setPosition(posX + 3, 409)
    self._plusLabel:setColor(cc.c3b(255, 223, 0))
    self._plusLabel:setOpacity(0)
    self._plusLabel:setAnchorPoint(0, 0.5)
    self._plusLabel:enableOutline(cc.c4b(56,24,27, 255), 2)
    self._bg:addChild(self._plusLabel, 99)

    --括号
    self._plusLabel1 = cc.Label:createWithTTF("(", UIUtils.ttfName, 22)
    self._plusLabel1:setPosition(posX - iconW - 2, 409)
    self._plusLabel1:setColor(cc.c3b(255, 223, 0))
    self._plusLabel1:setOpacity(0)
    self._plusLabel1:setAnchorPoint(1, 0.5)
    self._plusLabel1:enableOutline(cc.c4b(56,24,27, 255), 2)
    self._bg:addChild(self._plusLabel1, 99)


    posX = posX + self._plusLabel:getContentSize().width
    self._exp:setPositionX(posX + 45)
    self._expLabel:setPositionX(posX + 85)
end

function BattleResultCommonWin:initExpCoin()
	print("BattleResultCommonWin:initExpCoin")
	local posX = self._expLabel:getPositionX() + self._expLabel:getContentSize().width + 30
	self._expCoinIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI_exp3.png")
	self._expCoinIcon:setPosition(posX + self._expCoinIcon:getContentSize().width*0.5 + 2, 415)
	self._expCoinIcon:setScale(0.9)
    self._expCoinIcon:setOpacity(0)
    self._bg:addChild(self._expCoinIcon, 99)

    posX = self._expCoinIcon:getPositionX() + self._expCoinIcon:getContentSize().width/2

    self._expCoinLabel = cc.Label:createWithTTF("0", UIUtils.ttfName, 22)
    self._expCoinLabel:setPosition(posX, 409)
    self._expCoinLabel:setColor(cc.c3b(255, 223, 0))
    self._expCoinLabel:setOpacity(0)
    self._expCoinLabel:setAnchorPoint(0, 0.5)
    self._expCoinLabel:enableOutline(cc.c4b(56,24,27, 255), 2)
    self._bg:addChild(self._expCoinLabel, 99)
end

function BattleResultCommonWin:onQuit()
	if self._viewMgr then
		self._viewMgr:closeHintView()
	end
	local friendBattleCallback = self._friendBattleCallback
	if self._callback then
		self._callback()
        UIUtils:reloadLuaFile("battle.BattleResultCommonWin")
	end
	-- 对好友切磋特做
	if friendBattleCallback then
		friendBattleCallback()
	end
end

function BattleResultCommonWin:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

function BattleResultCommonWin:animBegin()	
	audioMgr:stopMusic()
	audioMgr:playSoundForce("WinBattle")

	local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false)	
	liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
	self:getUI("bg_click"):addChild(liziAnim, 1000)
	
	-- 右侧旗子
	self._posBgX = self._bgImg:getPositionX()
	self._posBgY = self._bgImg:getPositionY()
	self._bgImg:setPositionY(self._posBgY+615)

	local starP = self:getUI("bg.starPanel")
	starP:setOpacity(0)
	starP:setCascadeOpacityEnabled(true)

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
        local teamModel = self._modelMgr:getModel("TeamModel")
        local tdata,_idx = teamModel:getTeamAndIndexById(lihuiId)
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
	local moveDis = 436
	local posRoleX,posRoleY = self._rolePanel:getPosition()
	
	-- if not self._rolePanelLow then 
	-- 	self._rolePanelLow = self._rolePanel:clone()
	-- 	self._rolePanelLow:setOpacity(150)
	-- 	-- self._rolePanelLow:setVisible(false)
	-- 	self._rolePanelLow:setCascadeOpacityEnabled(true)
	-- 	self._rolePanelLow:setPosition(self._rolePanel:getPosition())
	-- 	self._rolePanel:getParent():addChild(self._rolePanelLow, self._rolePanel:getZOrder()-1)
	-- end
	-- self._rolePanelLow:setPositionX(-moveDis)
	self._rolePanel:setPositionY(-moveDis)
	local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posRoleX,posRoleY+20)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)),cc.CallFunc:create(function ( ... )
		self:starPanelAction()
	end))
	self._rolePanel:runAction(moveRole)

	starP:setOpacity(0)
	starP:setCascadeOpacityEnabled(true)
	local starP = self:getUI("bg.starPanel")
	starP:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.FadeIn:create(0.1)))
	-- local moveRoleLow = cc.Sequence:create(cc.DelayTime:create(0.06), cc.MoveTo:create(0.1,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
	-- self._rolePanelLow:runAction(moveRoleLow)

	local starTime = 0
	if not self._isBranch then
		starTime = 400
	end
	self._bgImg:setOpacity(0)
	local animPos = self:getUI("bg.animPos")
	ScheduleMgr:delayCall(400+starTime, self, function(sender)
		local posBgX,posBgY = self._posBgX,self._posBgY
		local mc2
		local moveBg = cc.Sequence:create(
			cc.Spawn:create(cc.FadeIn:create(0.1),
			cc.MoveTo:create(0.1,cc.p(posBgX,posBgY-40))),
			cc.MoveTo:create(0.15,cc.p(posBgX,posBgY)),
			cc.DelayTime:create(0.07),
			cc.CallFunc:create(function()
				--胜利动画
			    mc2 = mcMgr:createViewMC("shengli_commonwin", false)
			    mc2:setPosition(animPos:getPositionX(), animPos:getPositionY())
			    mc2:setPlaySpeed(1.5)
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

function BattleResultCommonWin:starPanelAction()	
	local starP = self:getUI("bg.starPanel")
	self._delayT = 0
	local scaleStar = {0.8, 0.9, 1.1}
	if not self._isBranch then
		for i=1,3 do
			local star = self:getUI("bg.starPanel.star"..i)
			star:setScale(scaleStar[i]*0.85)
			if i <= self._star then
				ScheduleMgr:delayCall(50+i*100, self, function()
					if starP then
						star:setOpacity(0)
						local mcStar = mcMgr:createViewMC("xing_commonwin", false)
					    mcStar:setScale(scaleStar[i])			    	
				    	mcStar:addCallbackAtFrame(6, function()
						    audioMgr:playSound("WinStar_"..i) 
						end)
					    mcStar:setPosition(star:getPosition())
					    starP:addChild(mcStar, 5)

					    -- 震屏
					    UIUtils:shakeWindowRightAndLeft(self._bg)
					end
		        end)
			end
		end	
		self._delayT = 1200
	end
end

-- local soundDelaytick = {400, 700, 1000}
-- local delaytick = {410, 440, 380}
function BattleResultCommonWin:animNext(mc2)
	if mc2 == nil then
		return
	end

	--倒计时
    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName, 28)
    self._timeLabel:setColor(cc.c3b(255, 150, 97))
    self._timeLabel:enableOutline(cc.c4b(60, 30, 0,255), 1)
    self._timeLabel:setPosition(212, -30)  -- -35/-16
    mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
    if self._time then
    	self:labelAnimTo(self._timeLabel, 0, self._time, true)
    	if self._time <= 60 then
    		self._timeLabel:setColor(cc.c3b(20, 255, 34))
    	end
    end

	local animPos = self:getUI("bg.animPos")
	local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)

	local starP = self:getUI("bg.starPanel")
	local delayT = self._delayT or 0
	if not self._isBranch then
		--星级条件初始化
		self._starPanel:setVisible(true)
		self._starPanel:runAction(cc.FadeIn:create(0.1))

		for i = 1,#self._starInfo do
			if self._starInfo[i] then
				
	            local panelStar = self:getUI("bg.starDesPanel.star"..i)
	            panelStar:setSaturation(0)
	            -- panelStar:setVisible(false)
	            local child = panelStar:getChildren()
				child[1]:setOpacity(0)
				child[2]:setOpacity(0)
	            panelStar:setPositionX(panelStar:getPositionX()+panelStar:getContentSize().width)
	            local conTxt = self:getUI("bg.starDesPanel.star"..i..".conTxt")
	            conTxt:setFontName(UIUtils.ttfName)
	            conTxt:setFontSize(32)
		    	conTxt:setColor(cc.c4b(230, 198, 0, 255))
		    	conTxt:enable2Color(1, cc.c4b(246, 234, 50, 255))
	            conTxt:enableOutline(cc.c4b(60, 30, 0,255), 2)
	        else
	            local panelStar = self:getUI("bg.starDesPanel.star"..i)
	            -- panelStar:setVisible(false)
	            local child = panelStar:getChildren()
				child[1]:setOpacity(0)
				child[2]:setOpacity(0)
	            panelStar:setPositionX(panelStar:getPositionX()+panelStar:getContentSize().width)
	            local conTxt = self:getUI("bg.starDesPanel.star"..i..".conTxt")
	            conTxt:setFontName(UIUtils.ttfName)
	            conTxt:enableOutline(cc.c4b(0,0,0,255), 1)
	        end
		end

		-- 星级条件动画
		for i = 1,3 do
			local panelStar = self:getUI("bg.starDesPanel.star"..i)
			-- mc2:addCallbackAtFrame(34, function()
			-- ScheduleMgr:delayCall(i*100, self, function( )  --2000
				if panelStar then
					local child = panelStar:getChildren()
					child[1]:runAction(cc.FadeIn:create(0.05))
					child[2]:runAction(cc.FadeIn:create(0.05))
					-- panelStar:setVisible(true)
					if true == self._starInfo[i] then
						--添加刷光特效
						local mc = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", false, true,nil,RGBA8888)
						mc:setPosition(panelStar:getContentSize().width/2-80, panelStar:getContentSize().height/2)
						panelStar:addChild(mc)
					end
		            local seqAction = cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(panelStar:getPositionX()-panelStar:getContentSize().width-5,panelStar:getPositionY())),
		            									 cc.MoveTo:create(0.2,cc.p(panelStar:getPositionX()-panelStar:getContentSize().width+5,panelStar:getPositionY())))
					panelStar:runAction(seqAction)
				end
	        -- end)		
		end
	
		ScheduleMgr:delayCall(1000,self,function() -- 1800
			--星级条件面板移动
		    local moveAction = cc.Spawn:create(cc.MoveBy:create(0.3,cc.p(-80,0)),cc.FadeOut:create(0.1),cc.CallFunc:create(function()
		    	if not self._starPanel then return end 
		    	local obj = self._starPanel:getChildren()
		    	for i=1,#obj do
		    		local objChild = obj[i]:getChildren()
		    		objChild[1]:runAction(cc.FadeOut:create(0.1))
		    		objChild[2]:runAction(cc.FadeOut:create(0.1))
		    	end
		    	-- self._starPanel:setVisible(false)
		    end))
			
			self._starPanel:runAction(moveAction)
		end)
	end

	local anima = function(isFirst,callback)
		if not callback then
			callback = function()
			end
		end
		if isFirst then
			return cc.Sequence:create(
				cc.DelayTime:create(delayT/1000),
				cc.Spawn:create(
					cc.FadeIn:create(0.1),
					cc.ScaleTo:create(0.1,1.05),
					cc.Sequence:create(
						cc.DelayTime:create(0.1),
						cc.CallFunc:create(callback)
					)
				),
				cc.ScaleTo:create(0.1,1)
			)
		else
			return cc.Sequence:create(
				cc.Spawn:create(
					cc.FadeIn:create(0.1),
					cc.ScaleTo:create(0.1,1.05),
					cc.Sequence:create(
						cc.DelayTime:create(0.1),
						cc.CallFunc:create(callback)
					)
				),
				cc.ScaleTo:create(0.1,1)
			)
		end
	end

	-- 1300 星级条件面板动画总时间
    -- self._exp:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(-15,0)),cc.MoveBy:create(0.1,cc.p(15,0))))--cc.DelayTime:create(1-(delayT/1000)),
    -- self._expLabel:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(-15,0)),cc.MoveBy:create(0.1,cc.p(15,0))))--cc.DelayTime:create(1-(delayT/1000)),
    --
    if self._plusLabel then
    	self._plusLabel:setScale(0.1)
    	self._plusLabel:runAction(anima(true))
        -- self._plusLabel:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))--cc.DelayTime:create(1-(delayT/1000)),
    end
    if self._plusLabel1 then
    	self._plusLabel1:setScale(0.1)
    	self._plusLabel1:runAction(anima(true))
 		-- self._plusLabel1:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))--cc.DelayTime:create(1-(delayT/1000)),
    end
	--
    if self._tencentIconList then
        for i = 1, #self._tencentIconList do
            -- self._tencentIconList[i]:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))--cc.DelayTime:create(1-(delayT/1000)),
        	self._tencentIconList[i]:setScale(0.1)
        	self._tencentIconList[i]:runAction(anima(true))
        end
    end
    --
    -- self._gold:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))--cc.DelayTime:create(1-(delayT/1000)),
    -- self._goldLabel:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))--cc.DelayTime:create(1-(delayT/1000)),
    self._gold:setScale(0.1)
    self._gold:runAction(anima(true,function()
    	self._exp:setScale(0.1)
    	self._exp:runAction(anima())
    	self._expLabel:setScale(0.1)
    	self._expLabel:runAction(anima(false,function()
    		if self._expCoinLabel then
    			self._expCoinLabel:setScale(0.1)
    			self._expCoinLabel:runAction(anima())
    		end

    		if self._expCoinIcon then
    			self._expCoinIcon:setScale(0.1)
    			self._expCoinIcon:runAction(anima())
    		end
    	end))
    end))
    self._goldLabel:setScale(0.1)
    self._goldLabel:runAction(anima(true))

    -- if self._expCoinIcon then
    -- 	self._expCoinIcon:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))
    -- end

    -- if self._expCoinLabel then
    -- 	self._expCoinLabel:runAction(cc.Sequence:create(cc.DelayTime:create(delayT/1000), cc.FadeIn:create(0.1),cc.MoveBy:create(0.2,cc.p(15,0)),cc.MoveBy:create(0.1,cc.p(-15,0))))
    -- end
    
    if self._expValue then
	    -- ScheduleMgr:delayCall(0, self, function()
    	if self.labelAnimTo == nil then return end
    	self._exp:setScale(1)
    	if self._expCoinValue and self._expCoinValue > 0 and self._expValue <= 0 then
    		self._exp:loadTexture("globalImageUI_exp3.png",1)
    		self._exp:setScale(0.9)
    		self:labelAnimTo(self._expLabel, 0, self._expCoinValue)
    	elseif self._expCoinValue and self._expCoinValue <= 0 and self._expValue > 0 then
    		self:labelAnimTo(self._expLabel, 0, self._expValue)
    	else
    		self:labelAnimTo(self._expLabel, 0, self._expValue)
    		if self._expCoinLabel then
    			self:labelAnimTo(self._expCoinLabel, 0, self._expCoinValue)
    		end
    	end
    	self:labelAnimTo(self._goldLabel, 0, self._goldValue)
	    -- end)
	else
		self._exp:setVisible(false)
		self._gold:setVisible(false)
	end
    
    if self._teams then
	    ScheduleMgr:delayCall(delayT, self, function()
	    	-- 显示人物经验
	    	self._bg1:setVisible(true)
	    	for i = 1, #self._teams do
	    		local team = self._teams[i]	    		
	    		if team then 
	    			team:setScale(0.5)
	    			team:setVisible(false)
	    			-- ScheduleMgr:delayCall(i*50, self, function()
	    				team:setVisible(true)
	    				local action = cc.Sequence:create(cc.ScaleTo:create(0.1,1),cc.ScaleTo:create(0.1,0.75))
	    				team:runAction(action)
	    				if team.expPro then
    						team.exp:runAction(cc.ScaleTo:create(0.5, team.expPro or 1, 1))
    					else
    						team.expBar:setVisible(false)
    						team.exp:setVisible(false)
    					end
				    	if team.isLevelUp then
					    	local levelUp = mcMgr:createViewMC("shengji_commonwin", false, true,function()
					    		if levelUp then
					    			levelUp:setVisible(false)
					    		end
					    	end)
						    levelUp:setPosition(team:getContentSize().width * 0.5, team:getContentSize().height * 0.5+7)	
						   --  ScheduleMgr:delayCall(1000, self, 
						   --  	function()
						   --  		if levelUp and team then
									--     local moveAction = cc.MoveBy:create(0.4, cc.p(0, team:getContentSize().height * 0.5))		
									-- 		    --cc.FadeOut:create(0.1)	    
									--     local seqAction = cc.Sequence:create(moveAction,cc.CallFunc:create(function (sender)
									--     	levelUp:setVisible(false)
									--     end))
									--     levelUp:runAction(seqAction)
									-- end
							  --   end)
						    team:addChild(levelUp, 100)
						end

						if team.isBestOutput and true == team.isBestOutput then
			    			ScheduleMgr:delayCall(300, self, function()
			    				if team then
			    					local bestOutImg = ccui.ImageView:create()
			    					bestOutImg:loadTexture("battleCount_bestOut.png",1)
			    					bestOutImg:setScale(3)
			    					bestOutImg:setRotation(40)
			    					bestOutImg:setPosition(team:getContentSize().width - 15 , team:getContentSize().height - bestOutImg:getContentSize().height/2 - 5)
			    					bestOutImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.8),cc.ScaleTo:create(0.1,1)))
			    					team:addChild(bestOutImg,10)
					    			team:setZOrder(10)
						      --   	local mc = mcMgr:createViewMC("zuijiashuchu_commonresultbest", false,false)
							     --    mc:setPosition(team:getContentSize().width - 15, team:getContentSize().height - mc:getContentSize().height/2-18)
					    			-- team:addChild(mc,10)
					    			-- team:setZOrder(10)
					    		end
			    			end)
						end	    	
					-- end)
				end
	    	end
	    end)
	end

	--获得道具title
    if self._items and #self._items > 0 then
    	self._title:runAction(cc.Sequence:create(
    		cc.DelayTime:create(delayT/1000),
    		-- cc.DelayTime:create(0.5),
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
   
   	--统计btn
    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.6+delayT/1000), cc.FadeIn:create(0.2),cc.CallFunc:create(function ()
    	self._countBtn:setEnabled(true)
    end)))

    --touchPanel
    self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.8+delayT/1000), cc.CallFunc:create(function()
    	self._touchPanel:setEnabled(true)
    end)))

    --奖励icon
    if self._items then
	    ScheduleMgr:delayCall(delayT, self, function() --3100
	    	-- 显示获得道具
	    	if self._bg2 and self._title then 
		    	self._bg2:setVisible(true)
		    	-- self._title:runAction(cc.MoveBy:create(0.05,cc.p(0,-15)))
		    	for i = 1, #self._items do
		    		local item = self._items[i]
		    		item:setScaleAnim(false)
		    		item:runAction(cc.Sequence:create(
		    			-- cc.DelayTime:create(i * 0.05+0.1), 
		    			cc.CallFunc:create(function() 
		    				item:setVisible(true) 
		    				local rwdAnim = mcMgr:createViewMC("daojuguang_commonwin", false)
			    			rwdAnim:setPosition(item:getPosition())
			    			item:getParent():addChild(rwdAnim, 7)
		    				end), 
		    			-- cc.ScaleTo:create(0.15, 0.6), 
		    			-- cc.ScaleTo:create(0.08, 0.78), 
		    			cc.Spawn:create(cc.FadeIn:create(0.2), cc.ScaleTo:create(0.2, 0.78)),
		    			cc.CallFunc:create(function() item:setScaleAnim(true) end)))
		    	end
		    end
	    end)
	end
end

function BattleResultCommonWin:labelAnimTo(label, src, dest, isTime)
	self._countSound = audioMgr:playSound("TimeCount")
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
				audioMgr:stopSound(self._countSound)
			end
			if label.isTime then
				label:setString(formatTime(label.now))
			else
	        	label:setString(label.now)
	        end
	    end
    end)
end

function BattleResultCommonWin.dtor()
	BattleResultCommonWin = nil
	-- delaytick = nil
	-- soundDelaytick = nil
end


return BattleResultCommonWin