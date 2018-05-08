--[[
    Filename:    GuildMapFamBattleNode.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2015-11-30 18:56:58
    Description: File description
--]]


local GuildMapFamBattleNode = class("GuildMapFamBattleNode", BasePopView)

function GuildMapFamBattleNode:ctor(data)
    GuildMapFamBattleNode.super.ctor(self)
	self._data = data.npcData
	self._id = data.index
	self._targetId = data.targetId
	self._famType = data.famType
end

function GuildMapFamBattleNode:onInit()
	self._nameLabel = self:getUI("bg.nameLabel")
	self._ruleLabel = self:getUI("bg.famRuleLabel")
	
	self._powerLabel = self:getUI("bg.powerLabel")
	self._powerLabel:enable2Color(1, cc.c4b(249, 227, 159, 255))
	self._powerLabel:setVisible(self._famType==1)
	
	self._huanxiangLabel = self:getUI("bg.huanxiangLabel")
	self._huanxiangLabel:setVisible(self._famType==1)
	
	self._descBg = self:getUI("bg.descBg")
	
	self._rewardLabel = self:getUI("bg.rewardLabel")
	self._rewardLabel:enable2Color(1, cc.c4b(249, 227, 159, 255))
	
	self._rewardPanel = self:getUI("bg.rewardPanel")
	self._rewardPanel:setVisible(true)--self._famType==1)
	
	self._arrow = self:getUI("bg.arrow")
	self._arrow:setVisible(self._famType==2)
	
	self:setData()
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
	end)
	
	local fightBtn = self:getUI("bg.fightBtn")
	if self._famType==2 then
		fightBtn:setTitleText("兑换")
	end
	self:registerClickEvent(fightBtn, function()
		if self._famType==1 then
			self:onBeforeFight(clone(self._data))
		else
			self:onChangeItem()
		end
	end)
	

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
        	UIUtils:reloadLuaFile("guild.map.GuildMapFamBattleNode")
		end
	end)
end

function GuildMapFamBattleNode:setData()
	local sysSkin = tab:HeroSkin(self._famType==1 and self._data.hero.skin or self._data.skin)
	if sysSkin == nil then
		local heroData = tab.hero[self._data.formation.heroId]
		sysSkin = tab:HeroSkin(heroData.heroSkinID[1])
	end
	if sysSkin then
		local panelBg = self:getUI("bg.Panel_105")
		local heroSp = cc.Sprite:create("asset/uiother/hero/" .. sysSkin.wholecut .. ".png")
		heroSp:setAnchorPoint(0.5,0)
		panelBg:addChild(heroSp)
		if sysSkin.crusadePosi == nil then
			heroSp:setVisible(false)
		else
			heroSp:setPosition(sysSkin.crusadePosi[1]-100, sysSkin.crusadePosi[2])
			if sysSkin.crusadePosi[3] then
				heroSp:setScale(sysSkin.crusadePosi[3])
			end
		end
	end
	local sfc = cc.SpriteFrameCache:getInstance()
	local itemEffect = {
		[1] = "wupinguang_itemeffectcollection",                -- 转光
		[2] = "wupinkuangxingxing_itemeffectcollection",        -- 星星
		[3] = "tongyongdibansaoguang_itemeffectcollection",     -- 扫光
		[4] = "diguang_itemeffectcollection",                   -- 底光
	}
	if self._famType==1 then
		local configData = tab.famFight[self._id]
		self._nameLabel:setString(self._data.name)
		self._powerLabel:setString("战斗力:"..self._data.formation.score)
		self._huanxiangLabel:setPositionX(self._nameLabel:getPositionX() + self._nameLabel:getContentSize().width)
		self._powerLabel:setPositionX(self._huanxiangLabel:getPositionX() + self._huanxiangLabel:getContentSize().width + 20)
		local richText = RichTextFactory:create(lang(configData.des), self._descBg:getContentSize().width, 0)
		richText:formatText()
		richText:setPosition(self._descBg:getContentSize().width/2, self._descBg:getContentSize().height - richText:getRealSize().height/2)
		self._descBg:addChild(richText)
--		self._richText:setText(lang(configData.des))
		self._ruleLabel:setString(lang("GUILD_FAM_TIPS_4"))
		self._rewardLabel:setString("击败奖励：")
		
		local tbReward = configData.award
		self:createItem(tbReward)
	else
		local configData = tab.famWitch[self._id]
		self._nameLabel:setString(lang(configData.name))
		local richText = RichTextFactory:create(lang(configData.des), self._descBg:getContentSize().width, 0)
		richText:formatText()
		richText:setPosition(self._descBg:getContentSize().width/2, self._descBg:getContentSize().height - richText:getRealSize().height/2)
		self._descBg:addChild(richText)
--		self._richText:setText(lang(configData.des))
		self._ruleLabel:setString(lang("GUILD_FAM_TIPS_5"))
		self._rewardLabel:setString("兑换奖励：")
		
		local tbReward = {[1]= self._data[2], [2] = self._data[3]}
		self:createItem(tbReward)
	end
end

function GuildMapFamBattleNode:createItem( gifts )
	local count = #gifts
	for i=1, count do
		local item = gifts[i]
		local itemId
		if item[1] == "tool" then
			itemId = item[2]
		else
			itemId = IconUtils.iconIdMap[item[1]]
		end
		local itemData = tab.tool[itemId]
		local itemNode = IconUtils:createItemIconById({itemId = itemId,num = item[3],itemData = itemData,effect = false })
        --获得界钻石icon加底光特效
        --gem = 39992, payGem = 39978,
        -- print("==========================itemId============",itemId,IconUtils.iconIdMap.gem,IconUtils.iconIdMap.payGem)
        if itemId == IconUtils.iconIdMap.gem or itemId == IconUtils.iconIdMap.payGem then
             local mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
                sender:gotoAndPlay(0)
            end,RGBA8888) 
            mc:setPosition(itemNode:getContentSize().width*0.5,itemNode:getContentSize().height*0.5)      
            mc:setScale(1.1)
            mc:setName("itemMc")
            mc:setVisible(false)
            itemNode:addChild(mc,-5) 
        end
		
		itemNode:setSwallowTouches(true)
		itemNode:setScale(0.85)
		itemNode:setScaleAnim(false)
		itemNode:setAnchorPoint(0.5,0.5)
		local posX = (i-1)*10 + (i*2-1)/2*itemNode:getContentSize().width
		if self._famType==2 and i==2 then
			posX = posX + self._arrow:getContentSize().width*0.78
		end
		itemNode:setPosition(posX, self._rewardPanel:getContentSize().height/2)
		itemNode:setVisible(true)
		self._rewardPanel:addChild(itemNode)
	end
end

function GuildMapFamBattleNode:onBeforeFight(enemyD)
	self._battleWin = 0

    -- 初始化敌方数据
--    local enemyInfo = BattleUtils.jsonData2lua_battleData(enemyD)
    local function callBattle(formationData)
        if self._serverMgr == nil then
            return
        end
        local battleParamTable = {
			tagPoint = self._targetId,
			id = tostring(self._id),
		}
        self._serverMgr:sendMsg("GuildMapServer", "beforeSecretLand",battleParamTable, true, {}, function(result, errorCode)
			if errorCode and errorCode~=0 then
				if errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SECRETLAND_IS_ATTAKED then
					self._viewMgr:showTip(lang("GUILD_FAM_TIPS_13"))
				elseif errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SECRETLAND_HAS_BEEN_KILLED then
					self._viewMgr:showTip(lang("GUILD_FAM_TIPS_16"))
				elseif errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SECRETLAND_NOT_EXIST then
					self._viewMgr:showTip(lang("GUILD_FAM_TIPS_15"))
				end
				return
			end
			self._mercenaryId = formationData[7]
			self._userId = formationData[8]
			self._token = result.token
			local inLeftData = BattleUtils.jsonData2lua_battleData(result["atk"])
			local _enemyInfo = BattleUtils.jsonData2lua_battleData(enemyD)
			self._viewMgr:popView()
			BattleUtils.enterBattleView_GuildFAM(inLeftData, _enemyInfo, function (info, callback)
				-- 战斗结束
				-- callback(info)
				self:afterFamBattle(info, callback)
			end,
			function (info)
				-- 退出战斗
				self:close(true)
			end)
		end)--[[, function (errorCode)
			if errorCode == 3120 or errorCode == 3121 or errorCode == 2703 or errorCode == 2742 then
				self:lock()
				ScheduleMgr:delayCall(400, self, function( )
					self:unlock()
					self._viewMgr:popView()
				end)
			end
		end)--]]
	end

    -- 给布阵传递怪兽数据
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:setEnemyTeamData(enemyD.teams)

    -- 给布阵传递英雄数据
    guildMapModel:setEnemyHeroData(enemyD.hero)

    local formationModel = self._modelMgr:getModel("FormationModel")

    local enterFormationFunc = function(hireInfo,isShowHireTeam)
        self._viewMgr:showView("formation.NewFormationView", {
			formationType = formationModel.kFormationTypeGuild,
			enemyFormationData = {[formationModel.kFormationTypeGuild] = clone(enemyD.formation)},
			extend = {
				hireTeams = hireInfo,
				isShowHireTeam = isShowHireTeam,
			},
			callback = function(...)
				local paramTable = {...}
				if paramTable[2] == 0 then 
					self._viewMgr:showTip("to lannan  "..lang("CRUSADE_TIPS_6"))
					return 
				end
				callBattle(paramTable)
			end,
			closeCallback = function()
				if self.parentView ~= nil then
					self.parentView:setMaskLayerOpacity(0)
				end
				if self.setVisible then
					self:setVisible(false)
				end
				if self.close then
					self:close(false)
				end
			end
		})
    end

    local hireInfo = {}
	local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
	local limitLevel = tab:SystemOpen("Lansquenet")[1]
	if tonumber(userLevel) < tonumber(limitLevel) then
		enterFormationFunc(hireInfo,2)
		return
	end
	self._serverMgr:sendMsg("GuildServer", "getMercenaryList", {}, true, {}, function(result, errorCode)
		if errorCode ~= 0 then 
			if errorCode == 2703 then
				--更新联盟id
				self._modelMgr:getModel("UserModel"):simulationGuildId()
			end
			self._viewMgr:unlock(51)
			return
		end
		hireInfo = self._modelMgr:getModel("GuildModel"):getAllEnemyId()
		enterFormationFunc(hireInfo,0)
	end)
end

function GuildMapFamBattleNode:afterFamBattle(data, inCallBack)
    if data.win then
        self._battleWin = 1
    end
    local allyDead = {}
    local enemyDead = {}
    if not data.isSurrender then
        for k,v in pairs(data.dieList[1]) do
            table.insert(allyDead, k)
        end
        for k,v in pairs(data.dieList[2]) do
            table.insert(enemyDead, k)
        end
    end

    if #enemyDead == 0 then 
        enemyDead = nil
    end
    if #allyDead == 0 then
        allyDead = nil
    end

    if self._serverMgr ~= nil then
		local invite = self._modelMgr:getModel("GuildMapFamModel"):getInviteKey()
		local param = {tagPoint = self._targetId, id = self._id, token=self._token,
			args = json.encode({win= self._battleWin, skillList = data.skillList, time = data.time, 
			serverInfoEx = data.serverInfoEx,
			allyDead=allyDead, enemyDead=enemyDead, invite = invite})}
		self._serverMgr:sendMsg("GuildMapServer", "afterSecretLand", param, true, {}, function(result, errorCode)
			if result == nil or result["d"] == nil then 
				return 
			end
			if invite then
				self._modelMgr:getModel("GuildMapFamModel"):clearInviteKey()
			end
			-- 像战斗层传送数据
			if inCallBack ~= nil then
				result["mercenaryId"] = self._mercenaryId   --佣兵Id
				result["userId"] = self._userId
				inCallBack(result)
			end
		end)
    end
end

function GuildMapFamBattleNode:onChangeItem()
	local needItem = self._data[2]
	local itemCount
	if needItem[1] == "tool" then
		local items, count = self._modelMgr:getModel("ItemModel"):getItemsById(needItem[2])
		itemCount = count
	else
		itemCount = self._modelMgr:getModel("UserModel"):getData()[needItem[1]]
	end
	if itemCount>=needItem[3] then
		--足够
		local invite = self._modelMgr:getModel("GuildMapFamModel"):getInviteKey()
		local param = {tagPoint = self._targetId, id = tostring(self._id), invite = invite}
		self._serverMgr:sendMsg("GuildMapServer", "completeSecretLand", param, true, {}, function(result, errorCode)
			if errorCode and errorCode~=0 then
				if errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SECRETLAND_HAS_BEEN_KILLED then
					self._viewMgr:showTip(lang("GUILD_FAM_TIPS_17"))
				elseif errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SECRETLAND_NOT_EXIST then
					self._viewMgr:showTip(lang("GUILD_FAM_TIPS_15"))
				end
				return
			end
			self._modelMgr:getModel("GuildMapFamModel"):clearInviteKey()
			DialogUtils.showGiftGet({gifts = {self._data[3]}, callback = function()
				self:close()
			end})
		end)
	else
		--不够
		self._viewMgr:showTip(lang("GUILD_FAM_TIPS_9"))
	end
end

return GuildMapFamBattleNode