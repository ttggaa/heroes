--[[
    Filename:    TeamHolyView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-02 15:29:22
    Description: File description
--]]

local qualityMC = TeamUtils.qualityMC


local sortFunc = function(a, b)
	if a.lv > b.lv then
		return true
	elseif a.lv == b.lv then
		if a.quality > b.quality then
			return true
		elseif a.quality == b.quality then
			if a.make<b.make then
				return true
			elseif a.make==b.make then
				return a.id>b.id
			end
		end
	end
end

local function deleteSameValue(fixdeTtpe)
	for i=table.nums(fixdeTtpe), 1, -1 do
		local value = fixdeTtpe[i]
		for index,indexValue in ipairs(fixdeTtpe) do
			if index<i and indexValue==value then
				table.remove(fixdeTtpe, i)
				break
			end
		end
	end
end

-- 圣辉主界面
local TeamHolyView = class("TeamHolyView", BaseView)

function TeamHolyView:ctor(data)
    TeamHolyView.super.ctor(self)
    -- self._pageIndex = data.index
    if not data then
        data = {}
    end
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil 
	
--	FormationModel:getFormationDataByType(formationType)
    self._teamId = data.teamId
	self._tableState = 1
    self.initAnimType = 1
	self._selectIndex = 1
	self._rightTabState = 1
	self._selectStoneType = nil
	self._curSelectHolyNode = nil
	self._curSelectHolyKey = nil
	self._tablePercent = nil
end

function TeamHolyView:onInit()
	self._bgImg = self:getUI("bg.bgImg")
	self._bgImg:loadTexture("asset/bg/bg_014.jpg")--如此设置背景图是为了分辨率适配，因为圣徽槽的位置标注在背景图上
	
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._weaponModel = self._modelMgr:getModel("WeaponsModel")
    self._userModel = self._modelMgr:getModel("UserModel")
	
	self._propPanel = self:getUI("bg.rightSubBg.propPanel")
	self._bagPanel = self:getUI("bg.rightSubBg.bagPanel")
	
	self._propScroll = self:getUI("bg.rightSubBg.propPanel.scroll")
	self._propLine = self:getUI("bg.rightSubBg.propPanel.lineImg")
	
	
	local title = self:getUI("bg.rightSubBg.propPanel.titleBg1")
    UIUtils:adjustTitle(title, 10)
    local title = self:getUI("bg.rightSubBg.propPanel.titleBg2")
    UIUtils:adjustTitle(title, 10)
	
	self._suitCell = self:getUI("suitCell")
	self._suitCell:setVisible(false)
	self._recommendBtn = self:getUI("bg.rightSubBg.recommendBtn")     
    
    self:updateTeamAnim()--读取兵团形象
    self._curSelectTeam = self._teamModel:getTeamAndIndexById(self._teamId)
	self:updateLeftStone()--圣徽镶嵌状态
	self:reorderTabs()--设置界面tab标签动画
	
    self:setBtn()--初始化底部button

	
	
	local fixdeTtpe = self._teamModel:getStoneType(self._teamId, self._selectIndex)
	deleteSameValue(fixdeTtpe)
	self._tableData = {}
	for i,v in ipairs(fixdeTtpe) do
		local bagData = self._teamModel:getHolyDataAllByType(v, true)
		for _, holy in ipairs(bagData) do
			table.insert(self._tableData, holy)
		end
	end
	table.sort(self._tableData, sortFunc)
	self:setFilterState(fixdeTtpe)
	self:addBagTableView()--添加背包tableView
	
	self:initBagFilter()

    self:listenReflash("TeamModel", self.updateData)
end



--初始化tab
function TeamHolyView:reorderTabs( )
	UIUtils:setTabChangeAnimEnable(self:getUI("bg.rightSubBg.tab_prop"),0,handler(self, self.tabButtonClick))
	UIUtils:setTabChangeAnimEnable(self:getUI("bg.rightSubBg.tab_bag"),0,handler(self, self.tabButtonClick))

	self._tabEventTarget = {}
	table.insert(self._tabEventTarget, self:getUI("bg.rightSubBg.tab_prop"))
	table.insert(self._tabEventTarget, self:getUI("bg.rightSubBg.tab_bag"))
	self._animBtns = self._tabEventTarget
	
    self._playAnimBg = self:getUI("bg.rightSubBg.frame")
    self._playAnimBgOffX = 268
    self._playAnimBgOffY = -17
	
	for k,button in pairs(self._tabEventTarget) do
		button:setTitleFontName(UIUtils.ttfName)
		button:setPositionX(-5)
		button:setZOrder(-10)
		button:setAnchorPoint(1,0.5)
	end
	self._tabEventTarget[1]._appearSelect = true
	
    if not self._tabPoses then
        self._tabPoses = {}
        for k,tab in pairs(self._tabEventTarget) do
            local pos = cc.p(tab:getPosition())
            table.insert(self._tabPoses,pos)
        end
        table.sort(self._tabPoses,function ( a,b )
            return a.y > b.y
        end)
    end
    self._enabledTabs = {}
    table.insert(self._enabledTabs,self._tabEventTarget[1])
	local isChangeSelect = true
	if isChangeSelect then
		self:tabButtonClick(self._tabEventTarget[1],true)
	end
end

function TeamHolyView:tabButtonClick(sender,noAudio)
	if sender == nil then 
		return 
	end
	if not noAudio then 
		audioMgr:playSound("Tab")
	end
	for k,v in pairs(self._tabEventTarget) do
		if v ~= sender then 
			local text = v:getTitleRenderer()
			v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
			text:disableEffect()
			-- text:setPositionX(85)
			v:setScaleAnim(false)
			v:stopAllActions()
			v:setScale(0.9)
			if v:getChildByName("changeBtnStatusAnim") then 
				v:getChildByName("changeBtnStatusAnim"):removeFromParent()
			end
			v:setZOrder(-10)
			self:tabButtonState(v, false)
		end
	end
	if self._preBtn then
		UIUtils:tabChangeAnim(self._preBtn,nil,true)
	end

	self._preBtn = sender
	sender:stopAllActions()
	sender:setZOrder(99)
	UIUtils:tabChangeAnim(sender,function( )
		local text = sender:getTitleRenderer()
		text:disableEffect()
		sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
		self:tabButtonState(sender, true)
	end)
	
	self:refreshTabData(sender:getName())
end

function TeamHolyView:tabButtonState(sender, isSelected,isDisabled)
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
end

function TeamHolyView:refreshTabData(typeName)
	self._propPanel:setVisible(typeName=="tab_prop")
	self._bagPanel:setVisible(typeName=="tab_bag")
	if typeName == "tab_prop" then
		self:updateRightAttr()
		self:updateShowNature()
		self._rightTabState = 1
--		self._viewMgr:showTip("tab_prop")
	elseif typeName == "tab_bag" then
--		self._viewMgr:showTip("tab_bag")
		self._rightTabState = 2
	end
end


--初始化底部功能button
function TeamHolyView:setBtn()
    local animBg = self:getUI("bg.leftPanel.animBg")
	self:registerClickEvent(animBg, function()
        local callback = function(teamData)
            self._teamId = teamData.teamId
            self._curSelectTeam = teamData
            self:updateTeamAnim()
            self:updateData()
        end
        local param = {callback = callback, curSelectTeamID = self._teamId}
        UIUtils:reloadLuaFile("team.TeamHolyTeamView")
        self._viewMgr:showDialog("team.TeamHolyTeamView", param)
    end)
	
    local replaceTeam = self:getUI("bg.leftPanel.replaceTeam")
    self:registerClickEvent(replaceTeam, function()
        local callback = function(teamData)
            self._teamId = teamData.teamId
            self._curSelectTeam = teamData
            self:updateTeamAnim()
            self:updateData()
        end
        local param = {callback = callback, curSelectTeamID = self._teamId}
        UIUtils:reloadLuaFile("team.TeamHolyTeamView")
        self._viewMgr:showDialog("team.TeamHolyTeamView", param)
    end)

    local showBtn = self:getUI("bg.rightSubBg.showBtn")
    self:registerClickEvent(showBtn, function()
        UIUtils:reloadLuaFile("team.TeamHolySeeDialog")
        self._viewMgr:showDialog("team.TeamHolySeeDialog")
    end)
	
    local takeBtn = self:getUI("bg.leftPanel.takeBtn")
	local canTake = false
	if self._curSelectTeam.rune then
		takeBtn:setSaturation(-100)
		takeBtn:setEnabled(false)
		for i=1, 6 do
			if self._curSelectTeam.rune[tostring(i)] and self._curSelectTeam.rune[tostring(i)]~=0 then
				canTake = true
				takeBtn:setSaturation(0)
				takeBtn:setEnabled(true)
				break
			end
		end
	end
	
	if canTake then
		self:registerClickEvent(takeBtn, function()
			local tabRune = {}
			if self._curSelectTeam.rune then
				for i=1, 6 do
					if self._curSelectTeam.rune[tostring(i)] and self._curSelectTeam.rune[tostring(i)]~=0 then
						table.insert(tabRune, i)
					end
				end
				local param = {teamId = self._teamId, sids = tabRune}
				self._serverMgr:sendMsg("TeamServer", "takeRune", param, true, {}, function (result)
					self:updateData()
					self:updateTeamPower({oldPower = self._curSelectTeam.score, newPower = self._curSelectTeam.score})
				end)
			end
		end)
	end
	UIUtils:addFuncBtnName(self:getUI("bg.shopBtn"), "商店", nil, true)
	UIUtils:addFuncBtnName(self:getUI("bg.breakBtn"), "分解", nil, true)
    UIUtils:addFuncBtnName(self:getUI("bg.ruleBtn"), "规则", nil, true)

    local breakBtn = self:getUI("bg.breakBtn")
    self:registerClickEvent(breakBtn, function()
        UIUtils:reloadLuaFile("team.TeamHolyBreakDialog")
        self._viewMgr:showDialog("team.TeamHolyBreakDialog")
    end)

    local shopBtn = self:getUI("bg.shopBtn")
    self:registerClickEvent(shopBtn, function()
        self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type="rune"}, true, {}, function(result)
            UIUtils:reloadLuaFile("team.TeamHolyShopView")
            self._viewMgr:showView("team.TeamHolyShopView", {callback = function(isChange)
				if isChange then
					self:updateBagData()
				end
			end})
        end)
    end)
	
	local ruleBtn = self:getUI("bg.ruleBtn")
	self:registerClickEvent(ruleBtn, function()
--		self._viewMgr:showDialog("team.TeamHolyRuleDialog",{desc = lang("rune_rule")},true)
		UIUtils:reloadLuaFile("team.TeamHolyRuleDialog")
		self._viewMgr:showDialog("team.TeamHolyRuleDialog")
	end)
	
	local masterBtn = self:getUI("bg.rightSubBg.masterBtn")
	self:registerClickEvent(masterBtn, function()
		local lv = 0
		if self._curSelectTeam.rune then
			local runeData = self._curSelectTeam.rune
			for i=1, 6 do
				local key = runeData[tostring(i)]
				if key and key~=0 then
					local stoneData = self._teamModel:getHolyDataByKey(key)
					lv = lv + stoneData.lv-1
				end
			end
		end
		self._viewMgr:showHintView("global.GlobalTipView",
        {
            tipType = 26,
            node = masterBtn,
            lv = lv,
			desc = lang("RUNE_TIPS_6"),
            posCenter = true,
        })
	end)

    --[[local gradeBtn = self:getUI("bg.gradeBtn")
    self:registerClickEvent(gradeBtn, function()
        UIUtils:reloadLuaFile("team.TeamHolyGradeDialog")
        self._viewMgr:showView("team.TeamHolyGradeDialog")
    end)--]]

    local awakingBtn = self:getUI("bg.awakingBtn")
	awakingBtn:setVisible(false)--暂不开启觉醒功能
    --[[self:registerClickEvent(awakingBtn, function()
        UIUtils:reloadLuaFile("team.TeamHolyAwakingDialog")
        self._viewMgr:showView("team.TeamHolyAwakingDialog")
    end)--]]

end




--更新数据
function TeamHolyView:updateData()
	self:updateLeftStone()
	self:updateShowNature()
	self:updateRightAttr()
	self:updateBagData()
	self:setBtn()
end




--设置兵团
function TeamHolyView:updateTeamAnim()
	if not self._teamId then
--		self._teamModel = self._modelMgr:getModel("TeamModel")
		self._tableData = self._teamModel:getData()
		self._teamId = self._tableData[1].teamId
	end
    local systeam = tab:Team(self._teamId)
    local animBg = self:getUI("bg.leftPanel.animBg")
    local backBgNode = animBg:getChildByName("backBgNode")
    local pos = systeam.xiaoren
	local teamData = self._teamModel:getTeamAndIndexById(self._teamId)
	
	local teamName, art1, art2, steam = TeamUtils:getTeamAwakingTab(teamData, self._teamId)
    if backBgNode then
        backBgNode:setTexture("asset/uiother/steam/"..steam..".png")
    else
        backBgNode = cc.Sprite:create("asset/uiother/steam/"..steam..".png")
        backBgNode:setAnchorPoint(cc.p(0.5, 0))
        backBgNode:setName("backBgNode")
        animBg:addChild(backBgNode)
    end
	if systeam.scaleHoly then
		backBgNode:setScale(systeam.scaleHoly)
	else
		backBgNode:setScale(1)
		self._viewMgr:showTip("team表 id:"..self._teamId.." 没有配置scaleHoly字段！！@吴茂炯")
	end
    backBgNode:setPosition(cc.p(animBg:getContentSize().width/2+pos[1], pos[2]-10))
	
	local effectPanel = self:getUI("bg.effectPanel")
	if not effectPanel:getChildByName("circleMc") then
		local circleMc = mcMgr:createViewMC("dongtaidi_shenghuitubiao", true, false)
		circleMc:setPosition(effectPanel:getContentSize().width/2, effectPanel:getContentSize().height/2)
		circleMc:setName("circleMc")
		effectPanel:addChild(circleMc)
	end
	
	local leftPanel = self:getUI("bg.leftPanel")
	local replaceTeamBtn = self:getUI("bg.leftPanel.replaceTeam")
	
	self._powerLabel = leftPanel:getChildByName("powerLabel")
	if not self._powerLabel then
		local powerText = "战斗力: "..teamData.score
		self._powerLabel = cc.Label:createWithTTF(powerText, UIUtils.ttfName, 18)
		self._powerLabel:setTextColor(cc.c4b(255, 238, 160, 255))
		self._powerLabel:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
		self._powerLabel:setPosition(replaceTeamBtn:getPositionX(), replaceTeamBtn:getPositionY()-self._powerLabel:getContentSize().height*1.5)
		self._powerLabel:setName("powerLabel")
		leftPanel:addChild(self._powerLabel)
	end
	self._powerLabel:setString("战斗力: "..teamData.score)

    self._recommendBtn:setVisible(not not systeam.recommendHoly)
    self:registerClickEvent(self._recommendBtn, function()
        UIUtils:reloadLuaFile("team.TeamHolyRecommendDialog")
        self._viewMgr:showDialog("team.TeamHolyRecommendDialog",{recommendHoly = systeam.recommendHoly})
    end)
end


--设置兵团圣徽镶嵌状态
function TeamHolyView:updateLeftStone()
	local l_tbEffect = {
		[2] = "lv_shenghuitubiao",
		[3] = "lan_shenghuitubiao",
		[4] = "zi_shenghuitubiao",
		[5] = "cheng_shenghuitubiao",
		[6] = "hong_shenghuitubiao",
	}
    local rune = self._curSelectTeam.rune or {}
    local holyData = self._teamModel:getHolyData()
    for i=1,6 do
        local stoneBg = self:getUI("bg.leftPanel.stoneImg" .. i)
		if stoneBg:getChildByName("selectMc")==nil then
			local selectMc = mcMgr:createViewMC("shenghuixuanzhong_shenghuitubiao", true, false)
			selectMc:setName("selectMc")
			if i>2 then
				selectMc:setScale(1.05)
				selectMc:setPosition(stoneBg:getContentSize().width/2, stoneBg:getContentSize().height/2+4)
			else
				selectMc:setScale(1.53)
				selectMc:setPosition(stoneBg:getContentSize().width/2+1, stoneBg:getContentSize().height/2+5)
			end
			selectMc:setVisible(i==self._selectIndex)
			stoneBg:addChild(selectMc)
		end
		
        local stoneIcon = self:getUI("bg.leftPanel.stoneImg" .. i .. ".holyBg")
		local stageLabBg = self:getUI("bg.leftPanel.stoneImg" .. i .. ".stageLabBg")
        local stageLab = self:getUI("bg.leftPanel.stoneImg" .. i .. ".stageLabBg.stageLab")

        local qualityAnim = stoneBg and stoneBg.qualityAnim
        local indexId = tostring(i)
        if rune and rune[indexId] and rune[indexId] ~= 0 then
            local key = rune[indexId]
            local holyId = holyData[key].id
            local make = holyData[key].make
            local quality = holyData[key].quality
            local level = holyData[key].lv
            local runeTab = tab.runeClient[make]
			
			stageLabBg:setVisible(true)
            if stageLab then
                stageLab:setString("+" .. level-1)
            end
            if not tolua.isnull(qualityAnim) then
                qualityAnim:removeFromParent()
                qualityAnim = nil
            end
            local quslityStr = qualityMC[quality]
            if quslityStr then
                qualityAnim = mcMgr:createViewMC(quslityStr, true, false)
                qualityAnim:setName("qualityAnim")
				if i>2 then
					qualityAnim:setScale(1)
				else
					qualityAnim:setScale(1.4)
				end
				qualityAnim:setPosition(cc.p(stoneBg:getPosition()))
                stoneBg:getParent():addChild(qualityAnim)
                stoneBg.qualityAnim = qualityAnim
            end
			if i<3 and stoneBg:getChildByName("stoneIcon2") then
				stoneBg:getChildByName("stoneIcon2"):removeFromParent()
			end
            if stoneIcon then
				stoneIcon:stopAllActions()
				stoneIcon:setOpacity(255)
                stoneIcon:loadTexture(runeTab.icon .. ".png", 1)
				if i>2 then
					stoneIcon:setScale(0.7)
				else
					stoneIcon:setScale(1)
				end
            end
        else
            if stoneIcon then
				if i>2 then
					stoneIcon:loadTexture("TeamHolyUI_img17.png", 1)
				else
					local stoneIcon2 = stoneBg:getChildByName("stoneIcon2")
					if not stoneIcon2 then
						stoneIcon2 = stoneIcon:clone()
						stoneIcon2:setPosition(cc.p(stoneIcon:getPosition()))
						stoneIcon2:setName("stoneIcon2")
						stoneBg:addChild(stoneIcon2)
					end
					stoneIcon:stopAllActions()
					stoneIcon2:stopAllActions()
					
					local fixdeTtpe = self._teamModel:getStoneType(self._teamId, i)
					if i==1 then
						stoneIcon:loadTexture("teamHoly_typeImg"..fixdeTtpe[1]..".png", 1)
						stoneIcon2:loadTexture("teamHoly_typeImg"..fixdeTtpe[2]..".png", 1)
					else
						stoneIcon:loadTexture("teamHoly_typeImg"..fixdeTtpe[2]..".png", 1)
						stoneIcon2:loadTexture("teamHoly_typeImg"..fixdeTtpe[1]..".png", 1)
					end
					stoneIcon:setOpacity(255)
					stoneIcon2:setOpacity(0)
					local seq1 = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeOut:create(1), cc.DelayTime:create(1.5), cc.FadeIn:create(1)))
					local seq2 = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeIn:create(1), cc.DelayTime:create(1.5), cc.FadeOut:create(1)))
					stoneIcon:runAction(seq1)
					stoneIcon2:runAction(seq2)
				end
            end
            if not tolua.isnull(qualityAnim) then
                qualityAnim:removeFromParent()
                qualityAnim = nil
            end
			stageLabBg:setVisible(false)
            if stageLab then
                stageLab:setString("")
            end
        end

        self:registerClickEvent(stoneBg, function()
            local key = rune[tostring(i)]
			if key and key~=0 then
				local holyId = holyData[key].id
				local tabData = tab.rune[holyId]
				local score = self._curSelectTeam.score
				local param = {teamId = self._teamId, selectStone = i, key = key, holyData = tabData, hintType = 1, gradeCallback = function()
					self._curSelectTeam = self._teamModel:getTeamAndIndexById(self._teamId)
					self._powerLabel:setString("战斗力: "..self._curSelectTeam.score)
				end, callback = function()
					self:updateData()
					self:updateTeamPower({oldPower = score, newPower = self._curSelectTeam.score})
				end}
				UIUtils:reloadLuaFile("team.TeamHolyTipView")
				self._viewMgr:showHintView("team.TeamHolyTipView", param)
			else
				if self._rightTabState==1 then
					self._rightTabState = 2
					self:tabButtonClick(self._tabEventTarget[2],true)
				end
			end
			if self._selectIndex==i then
				return
			end
			self:onSelectStoneAtIndex(i)
            --[[local param = {teamId = self._teamId, selectStone = i}
			UIUtils:reloadLuaFile("team.TeamHolyReplaceDialog")
			self._viewMgr:showView("team.TeamHolyReplaceDialog", param)--]]
        end)
    end
end

function TeamHolyView:onSelectStoneAtIndex(index)
	self._selectIndex = index
	self._selectStoneType = nil
	for i=1, 6 do
		local stoneBg = self:getUI("bg.leftPanel.stoneImg" .. i)
		local selectMc = stoneBg:getChildByName("selectMc")
		if selectMc then
			selectMc:setVisible(i==index)
		end
	end
	if self._tableState==2 then--套装
		local fixdeTtpe = self._teamModel:getStoneType(self._teamId, self._selectIndex)
		local tableData1, tableData2 = self._teamModel:getShowSuitData(fixdeTtpe)
		local sortSuit = function(a, b)
			local inlayCountA = self._teamModel:getTeamHolyInlayCountBySuitId(self._teamId, a.key)
			local inlayCountB = self._teamModel:getTeamHolyInlayCountBySuitId(self._teamId, b.key)
			local suitNumDataA = self._teamModel:getShowHolyData(a.key)
			local numA = table.nums(suitNumDataA)
			local suitNumDataB = self._teamModel:getShowHolyData(b.key)
			local numB = table.nums(suitNumDataB)
			if inlayCountA>inlayCountB then
				return true
			elseif inlayCountA==inlayCountB then
				if numA>numB then
					return true
				elseif numA==numB then
					return a.key<b.key
				end
			end
		end
		table.sort(tableData1, sortSuit)
		table.sort(tableData2, sortSuit)
		self._tableData = tableData1
		for i,v in ipairs(tableData2) do
			table.insert(self._tableData, v)
		end
		self._bagTableView:reloadData()
	else--背包
		local fixdeTtpe = self._teamModel:getStoneType(self._teamId, self._selectIndex)
		self._tableData = {}
		local reAdd = false
		if self._tableState==3 then
			self._tableState = 1
			reAdd = true
			--[[self:getUI("bg.rightSubBg.bagPanel.bagBtn"):setVisible(true)--右侧背包上部的“类型”button
			self:getUI("bg.rightSubBg.bagPanel.filterBtn"):setVisible(true)--右侧背包上部的“套装”button
			self:getUI("bg.rightSubBg.bagPanel.returnBtn"):setVisible(false)--右侧背包上部的“返回”按钮
			self:getUI("bg.rightSubBg.bagPanel.suitNameBg"):setVisible(false)--右侧背包上部的“套装名称”image
			local filterBg = self:getUI("bg.rightSubBg.bagPanel.filterBg")
			filterBg:setVisible(true)
			self._bagTableView:setContentSize(self._bagTableView:getContentSize().width, self._bagTableView:getContentSize().height-50)--]]
		end
		deleteSameValue(fixdeTtpe)
		for i,v in ipairs(fixdeTtpe) do
			local isHaveSame
			for tempIndex=1, i-1 do
				if v==fixdeTtpe[i] then
					
				end
			end
			local bagData = self._teamModel:getHolyDataAllByType(v, true)
			for _, holy in ipairs(bagData) do
				table.insert(self._tableData, holy)
			end
		end
		table.sort(self._tableData, sortFunc)
		self:setFilterState(fixdeTtpe)
		if reAdd then
			self:addBagTableView()
		else
			self._bagTableView:reloadData()
		end
		
		local filterBtn = self:getUI("bg.rightSubBg.bagPanel.filterBtn")
		local bagBtn = self:getUI("bg.rightSubBg.bagPanel.bagBtn")
		self:setTitleBtnState(bagBtn, false)
		self:setTitleBtnState(filterBtn, true)
	end
	
end






--设置属性数据
function TeamHolyView:updateRightAttr()
	self._propScroll:removeAllChildren()
	self._propScroll:setInnerContainerSize(self._propScroll:getContentSize())
    local holyBaseAttr, holyAddAttr = self._teamModel:getStoneAttr(self._curSelectTeam.rune)

    local baseAttr = {}
	local addAttr = {}
    for n = BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        if holyBaseAttr[n] ~= 0 then
            table.insert(baseAttr, UIUtils:getAttrStrWithAttrName(n, holyBaseAttr[n], true))
        end
		if holyAddAttr[n] ~= 0 then
            table.insert(addAttr, UIUtils:getAttrStrWithAttrName(n, holyAddAttr[n], true))
        end
    end
	
	local baseTitle = cc.Label:createWithTTF("基础属性", UIUtils.ttfName, 24)
	baseTitle:setAnchorPoint(0.5, 0)
	local totalHeight = baseTitle:getContentSize().height + 10
	baseTitle:setColor(cc.c3b(138, 92, 29))
	self._propScroll:addChild(baseTitle)
	
	local baseLineImg = self._propLine:clone()
--	baseLineImg:setVisible(true)
	baseLineImg:setAnchorPoint(0.5, 0)
	totalHeight = totalHeight + baseLineImg:getContentSize().height+5
	self._propScroll:addChild(baseLineImg)
	local containerSize = self._propScroll:getInnerContainerSize()
	
	local baseAttrLab = {}
	local tipLab
	if table.nums(baseAttr)>0 then
		for i,v in ipairs(baseAttr) do
			local baseLabel = cc.Label:createWithTTF(v, UIUtils.ttfName, 18)
			baseLabel:setAnchorPoint(0, 0)
			baseLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
			local height = baseLabel:getContentSize().height
			if i%2==1 then
				totalHeight = totalHeight + height + 5
			end
			self._propScroll:addChild(baseLabel)
			table.insert(baseAttrLab, baseLabel)
		end
	else
		tipLab = cc.Label:createWithTTF("可在背包中镶嵌圣徽", UIUtils.ttfName, 18)
		tipLab:setAnchorPoint(0.5, 0)
		tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		local height = tipLab:getContentSize().height
		totalHeight = totalHeight + height + 15
		self._propScroll:addChild(tipLab)
	end
	
	local plusTitle = cc.Label:createWithTTF("附加属性", UIUtils.ttfName, 24)
	plusTitle:setAnchorPoint(0.5, 0)
	totalHeight = totalHeight + plusTitle:getContentSize().height + 20
	plusTitle:setColor(cc.c3b(138, 92, 29))
	self._propScroll:addChild(plusTitle)
	
	local plusLineImg = self._propLine:clone()
--	plusLineImg:setVisible(true)
	plusLineImg:setAnchorPoint(0.5, 0)
	totalHeight = totalHeight + plusLineImg:getContentSize().height+5
	self._propScroll:addChild(plusLineImg)
	
	local plusTipLab
	local gotoBtn
	local addAttrLab = {}
	if table.nums(addAttr)==0 then
		plusTipLab = cc.Label:createWithTTF("暂未镶嵌任何圣徽，请前往获取", UIUtils.ttfName, 18)
		plusTipLab:setAnchorPoint(0.5, 0)
		plusTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
		local height = plusTipLab:getContentSize().height
		totalHeight = totalHeight + height + 15
		self._propScroll:addChild(plusTipLab)
		
		gotoBtn = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
		gotoBtn:setAnchorPoint(0.5, 0)
		gotoBtn:setScale(0.6)
		self:registerClickEvent(gotoBtn, function()
			self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type="rune"}, true, {}, function(result)
				UIUtils:reloadLuaFile("team.TeamHolyShopView")
				self._viewMgr:showView("team.TeamHolyShopView", {callback = function(isChange)
					if isChange then
						self:updateBagData()
					end
				end})            
			end)
		end)
		gotoBtn:setTitleText("前往")
		gotoBtn:setTitleFontName(UIUtils.ttfName)
		gotoBtn:setTitleFontSize(24)
		totalHeight = totalHeight + gotoBtn:getContentSize().height*0.6 + 15
		self._propScroll:addChild(gotoBtn)
	else
		for i,v in ipairs(addAttr) do
			local addLab = cc.Label:createWithTTF(v, UIUtils.ttfName, 18)
			addLab:setAnchorPoint(0, 0)
			addLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
			local height = addLab:getContentSize().height
			if i%2==1 then
				totalHeight = totalHeight + height + 5
			end
			self._propScroll:addChild(addLab)
			table.insert(addAttrLab, addLab)
		end
	end
	
	local masterAttr = self._teamModel:getHolyMasterAttr(self._teamId)
	local masterTitle
	local masterLineImg
	local masterAttrLab = {}
	if table.nums(masterAttr)>0 then
		masterTitle = cc.Label:createWithTTF("精通属性", UIUtils.ttfName, 24)
		masterTitle:setAnchorPoint(0.5, 0)
		totalHeight = totalHeight + masterTitle:getContentSize().height + 20
		masterTitle:setColor(cc.c3b(138, 92, 29))
		self._propScroll:addChild(masterTitle)
		
		masterLineImg = self._propLine:clone()
		masterLineImg:setAnchorPoint(0.5, 0)
		totalHeight = totalHeight + masterLineImg:getContentSize().height+5
		self._propScroll:addChild(masterLineImg)
		
		for i,v in ipairs(masterAttr) do
			local attStr = UIUtils:getAttrStrWithAttrName(v[1], v[2], true)
			local masterLabel = cc.Label:createWithTTF(attStr, UIUtils.ttfName, 18)
			masterLabel:setAnchorPoint(0, 0)
			masterLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
			local height = masterLabel:getContentSize().height
			if i%2==1 then
				totalHeight = totalHeight + height + 5
			end
			self._propScroll:addChild(masterLabel)
			table.insert(masterAttrLab, masterLabel)
		end
	end
	
	if totalHeight>containerSize.height then
		self._propScroll:setInnerContainerSize(cc.size(containerSize.width, totalHeight))
		containerSize.height = totalHeight
		self._propScroll:jumpToPercentVertical(0)
	end
	
	
	--计算好containerSize之后，设置坐标
	baseTitle:setPosition(cc.p(containerSize.width/2, containerSize.height-baseTitle:getContentSize().height-10))
	baseLineImg:setPosition(cc.p(containerSize.width/2, baseTitle:getPositionY()-baseLineImg:getContentSize().height-5))
	local countLine = 0
	local posY = baseLineImg:getPositionY()
	if table.nums(baseAttr)>0 then
		for i,v in ipairs(baseAttrLab) do
			local posX = containerSize.width/2+10
			if i%2==1 then
				posX = 5
				posY = posY-v:getContentSize().height-5
			end
			v:setPosition(cc.p(posX, posY))
		end
	else
		posY = posY - tipLab:getContentSize().height - 15
		tipLab:setPosition(cc.p(containerSize.width/2, posY))
	end
	plusTitle:setPosition(cc.p(containerSize.width/2, posY - plusTitle:getContentSize().height-20))
	plusLineImg:setPosition(cc.p(containerSize.width/2, plusTitle:getPositionY()-plusLineImg:getContentSize().height-5))
	if table.nums(addAttr)==0 then
		plusTipLab:setPosition(cc.p(containerSize.width/2, plusLineImg:getPositionY()-plusTipLab:getContentSize().height-15))
		gotoBtn:setPosition(cc.p(containerSize.width/2, plusTipLab:getPositionY()-gotoBtn:getContentSize().height*0.6-15))
	else
		posY = plusLineImg:getPositionY()
		for i,v in ipairs(addAttrLab) do
			local posX = containerSize.width/2+10
			if i%2==1 then
				posX = 5
				posY = posY-v:getContentSize().height-5
			end
			v:setPosition(cc.p(posX, posY))
		end
	end
	
	if table.nums(masterAttr)>0 then
		masterTitle:setPosition(cc.p(containerSize.width/2, posY - masterTitle:getContentSize().height-20))
		masterLineImg:setPosition(cc.p(containerSize.width/2, masterTitle:getPositionY()-masterLineImg:getContentSize().height-5))
		local posY = masterLineImg:getPositionY()
		for i,v in ipairs(masterAttrLab) do
			local posX = containerSize.width/2+10
			if i%2==1 then
				posX = 5
				posY = posY - v:getContentSize().height-5
			end
			v:setPosition(cc.p(posX, posY))
		end
	end
end

--设置套装
function TeamHolyView:updateShowNature()
	self._curSelectTeam = self._teamModel:getTeamAndIndexById(self._teamId)
	local suitData = self._teamModel:getTeamSuitById(self._curSelectTeam)
	--[[suitData[102] = {[2] = 10204}
	suitData[103] = {[2] = 10305}--]]
	local suitPanel = self:getUI("bg.rightSubBg.propPanel.suitPanel")
	local suitTipLab = self:getUI("bg.rightSubBg.propPanel.suitTipLab")
	
	for i=1,3 do
		local itemNode = suitPanel:getChildByName("itemNode"..i)
		if itemNode then
			itemNode:removeFromParent()
		end
	end
	
	local effectTab = tab:Setting("GEM_EFFECT_NUM").value
	local count = 0
	for k,v in pairs(suitData) do
		if table.nums(v)>0 then
			local suitTab = tab:RuneClient(k)
			for _, data in ipairs(v) do
				count = count + 1
				local stoneTab = tab:Rune(data.stoneId)
				local quality = stoneTab.quality
				local amountStr = data.suitNum.."/"..data.suitNum
				local param = {quality = quality, noAmountStr = true, amountStr = amountStr, tabConfig = suitTab}
				local itemNode = IconUtils:createTeamHolySuitIcon(param)
				itemNode:setName("itemNode"..count)
				itemNode:setPosition(cc.p(16*count + (count*2-1)/2*itemNode:getContentSize().width, suitPanel:getContentSize().height/2+10))
				suitPanel:addChild(itemNode)
			end
		end
	end
	
	suitPanel:setVisible(count>0)
	suitTipLab:setVisible(count==0)
end







--设置背包数据
function TeamHolyView:initBagFilter()
	local filterBtn = self:getUI("bg.rightSubBg.bagPanel.filterBtn")
	local filterBg = self:getUI("bg.rightSubBg.bagPanel.filterBg")
	local bagBtn = self:getUI("bg.rightSubBg.bagPanel.bagBtn")
	
	self:setTitleBtnState(bagBtn, false)
	self:setTitleBtnState(filterBtn, true)
	
	local selectImg = filterBg:getChildByName("selectImg")
	for i=1, 5 do
		local holyTypeBtn = filterBg:getChildByFullName("filterBtn"..i)
		self:registerClickEvent(holyTypeBtn, function()
			self._selectStoneType = i
			self._tableData = self._teamModel:getHolyDataAllByType(i, true)
			selectImg:setPosition(cc.p(holyTypeBtn:getPosition()))
			selectImg:setVisible(true)
			table.sort(self._tableData, sortFunc)
			self._bagTableView:reloadData()
--			self:setTitleBtnState(bagBtn, true)
		end)
	end
	self:registerClickEvent(filterBtn, function()
		self._tableState = 2
		self._selectStoneType = nil
		local fixdeTtpe = self._teamModel:getStoneType(self._teamId, self._selectIndex)
		local tableData1, tableData2 = self._teamModel:getShowSuitData(fixdeTtpe)
		local sortSuit = function(a, b)
			local inlayCountA = self._teamModel:getTeamHolyInlayCountBySuitId(self._teamId, a.key)
			local inlayCountB = self._teamModel:getTeamHolyInlayCountBySuitId(self._teamId, b.key)
			local suitNumDataA = self._teamModel:getShowHolyData(a.key)
			local numA = table.nums(suitNumDataA)
			local suitNumDataB = self._teamModel:getShowHolyData(b.key)
			local numB = table.nums(suitNumDataB)
			if inlayCountA>inlayCountB then
				return true
			elseif inlayCountA==inlayCountB then
				if numA>numB then
					return true
				elseif numA==numB then
					return a.key<b.key
				end
			end
		end
		table.sort(tableData1, sortSuit)
		table.sort(tableData2, sortSuit)
		self._tableData = tableData1
		for i,v in ipairs(tableData2) do
			table.insert(self._tableData, v)
		end
        self:addBagTableView()
		self:setTitleBtnState(bagBtn, true)
		self:setTitleBtnState(filterBtn, false)
	end)
	self:registerClickEvent(bagBtn, function()
		self._selectStoneType = nil
		self:updateBagData()
		self:setTitleBtnState(bagBtn, false)
		self:setTitleBtnState(filterBtn, true)
		selectImg:setVisible(false)
	end)
	
	local returnSuitBtn = self:getUI("bg.rightSubBg.bagPanel.returnBtn")
	self:registerClickEvent(returnSuitBtn, function()
		self._tableState = 2
		local fixdeTtpe = self._teamModel:getStoneType(self._teamId, self._selectIndex)
		local tableData1, tableData2 = self._teamModel:getShowSuitData(fixdeTtpe)
		local sortSuit = function(a, b)
			local inlayCountA = self._teamModel:getTeamHolyInlayCountBySuitId(self._teamId, a.key)
			local inlayCountB = self._teamModel:getTeamHolyInlayCountBySuitId(self._teamId, b.key)
			local suitNumDataA = self._teamModel:getShowHolyData(a.key)
			local numA = table.nums(suitNumDataA)
			local suitNumDataB = self._teamModel:getShowHolyData(b.key)
			local numB = table.nums(suitNumDataB)
			if inlayCountA>inlayCountB then
				return true
			elseif inlayCountA==inlayCountB then
				if numA>numB then
					return true
				elseif numA==numB then
					return a.key<b.key
				end
			end
		end
		table.sort(tableData1, sortSuit)
		table.sort(tableData2, sortSuit)
		self._tableData = tableData1
		for i,v in ipairs(tableData2) do
			table.insert(self._tableData, v)
		end
        self:addBagTableView()
		self:setTitleBtnState(bagBtn, true)
		self:setTitleBtnState(filterBtn, false)
	end)
end

function TeamHolyView:setFilterState(enableType)
	local selectIndex = self._selectStoneType
	for i=1,5 do
		local filterBtn = self:getUI("bg.rightSubBg.bagPanel.filterBg.filterBtn"..i)
		filterBtn:setSaturation(-100)
		filterBtn:setEnabled(false)
	end
	for i,v in ipairs(enableType) do
		local filterBtn = self:getUI("bg.rightSubBg.bagPanel.filterBg.filterBtn"..v)
		filterBtn:setSaturation(0)
		filterBtn:setEnabled(true)
	end
	
	local selectImg = self:getUI("bg.rightSubBg.bagPanel.filterBg.selectImg")
	if not selectIndex then
		selectImg:setVisible(false)
	else
--		self._tableData = self._teamModel:getHolyDataAllByType(selectIndex, true)
		local filterBtn = self:getUI("bg.rightSubBg.bagPanel.filterBg.filterBtn"..selectIndex)
		selectImg:setPosition(cc.p(filterBtn:getPosition()))
		selectImg:setVisible(true)
--		table.sort(self._tableData, sortFun)
--		self._bagTableView:reloadData()
	end
end

function TeamHolyView:setTitleBtnState(sender, isEnable)
	local selectImg = sender:getChildByName("selectImg")
	local nameLabel = sender:getChildByName("nameLab")
	if isEnable then
		selectImg:loadTexture("TeamHolyUI_img38.png", 1)
		nameLabel:setColor(UIUtils.colorTable.ccUITabColor1)
	else
		selectImg:loadTexture("TeamHolyUI_img39.png", 1)
		nameLabel:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
	end
	sender:setEnabled(isEnable)
	sender:setBright(isEnable)
end

function TeamHolyView:updateBagData()
	local oldState = self._tableState
	self._tableState=1
	local fixdeTtpe = self._teamModel:getStoneType(self._teamId, self._selectIndex)
	deleteSameValue(fixdeTtpe)
	self._tableData = {}
	for i,v in ipairs(fixdeTtpe) do
		local bagData = self._teamModel:getHolyDataAllByType(v, true)
		if not self._selectStoneType then
			for _, holy in ipairs(bagData) do
				table.insert(self._tableData, holy)
			end
		elseif v==self._selectStoneType then
			self._tableData = bagData
			break
		end
	end
	table.sort(self._tableData, sortFunc)
	
	local filterBtn = self:getUI("bg.rightSubBg.bagPanel.filterBtn")
	local bagBtn = self:getUI("bg.rightSubBg.bagPanel.bagBtn")
	self:setTitleBtnState(bagBtn, false)
	self:setTitleBtnState(filterBtn, true)
	self:setFilterState(fixdeTtpe)
	if oldState~=self._tableState then
		self:addBagTableView()
	else
		self._bagTableView:reloadData()
		if self._tablePercent then
			local defaultOffset = self._bagTableView:getContentOffset()
			if self._tablePercent.y<defaultOffset.y then
				self._tablePercent.y = defaultOffset.y
			end
			self._bagTableView:setContentOffset(self._tablePercent)
			self._tablePercent = nil
		end
	end
end


--添加背包tableView
function TeamHolyView:addBagTableView()
--	self._viewMgr:showTip("addBagTableView")
	local tableViewBg = self:getUI("bg.rightSubBg.bagPanel.tableViewBg")
	tableViewBg:removeAllChildren()
	local height = tableViewBg:getContentSize().height
	if self._tableState==1 then
		height = height - 50
	end
	self:getUI("bg.rightSubBg.bagPanel.bagBtn"):setVisible(self._tableState~=3)--右侧背包上部的“类型”button
	self:getUI("bg.rightSubBg.bagPanel.filterBtn"):setVisible(self._tableState~=3)--右侧背包上部的“套装”button
	self:getUI("bg.rightSubBg.bagPanel.returnBtn"):setVisible(self._tableState==3)--右侧背包上部的“返回”按钮
	self:getUI("bg.rightSubBg.bagPanel.suitNameBg"):setVisible(self._tableState==3)--右侧背包上部的“套装名称”image
	local filterBg = self:getUI("bg.rightSubBg.bagPanel.filterBg")
	filterBg:setVisible(self._tableState == 1)
	self._bagTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, height))
	self._bagTableView:setDelegate()
	self._bagTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self._bagTableView:setPosition(0, 0)
    self._bagTableView:registerScriptHandler(function(table) return self:scrollViewDidScroll(table) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
	self._bagTableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
	self._bagTableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
	self._bagTableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self._bagTableView:setBounceable(true)
	self._bagTableView:reloadData()
	if self._bagTableView.setDragSlideable ~= nil then 
		self._bagTableView:setDragSlideable(true)
	end
	tableViewBg:addChild(self._bagTableView)
end

function TeamHolyView:scrollViewDidScroll(inView)
    self._inScrolling = inView:isDragging()
--    UIUtils:ccScrollViewUpdateScrollBar(inView)
end

function TeamHolyView:cellSizeForTable(inView, idx)
	return 83, 335
end

function TeamHolyView:tableCellAtIndex(inView, idx)
	local cell = inView:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
	cell:removeAllChildren()
	if self._tableState==1 or self._tableState==3 then--显示相应的宝石
		for i=1, 4 do
			local function itemCallback( holyItemData, stoneData, itemNode)
				if not self._inScrolling then
					self:touchHolyItemEnd(holyItemData, stoneData, itemNode)
				else
					self._inScrolling = false
				end
			end
			local index = idx*4+i
			local stoneData = self._tableData[index]
			--[[if self._tableState==3 and stoneData then
				stoneData = self._teamModel:getHolyDataByKey(stoneData)
			end--]]
			local param = stoneData and {suitData = tab.rune[stoneData.id], stoneData = stoneData, eventStyle = 3, callback = itemCallback} or nil
			local node = cell:getChildByName("cellNode"..i)
			if not node then
				node = IconUtils:createHolyBagIcon(param)
				node:setPosition(cc.p((i-1)*node:getContentSize().width + i*5, 1))
				node:setName("cellNode"..i)
				cell:addChild(node)
				if stoneData and stoneData.key==self._curSelectHolyKey then
					local mc = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
					mc:setName("mc")
					mc:setPosition(node:getContentSize().width/2, node:getContentSize().height/2)
					mc:setScale(0.8)
					node:addChild(mc, 1)
					self._curSelectHolyNode = node
				end
			else
				IconUtils:updateHolyBagIcon(node, param)
			end
		end
	else--显示套装信息
		local node = cell:getChildByName("suitCell")
		if not node then
			node = self._suitCell:clone()
			node:setPosition(cc.p(0, 0))--node:getContentSize().width/2, node:getContentSize().height/2))
			cell:addChild(node)
		end
		local suitData = self._tableData[idx+1]
		local suitId = suitData.key

		local suitIcon = node["suitIcon"]
		local suitTab = tab.runeClient[suitId]

		local tname = node:getChildByFullName("nameLab")
		if tname then
			local str = lang(suitTab.name)
			tname:setString(str)
		end
		local tnum = node:getChildByFullName("getNumImg.numLab")
		local suitNum = self._teamModel:getShowHolyData(suitId)
		if tnum then
			node:getChildByName("getNumImg"):setVisible(table.nums(suitNum)>0)
			tnum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
			tnum:setString(table.nums(suitNum))
		end
		
		local numLab = node:getChildByName("numLab")
		if self._curSelectTeam.rune then
			local count = self._teamModel:getTeamHolyInlayCountBySuitId(self._teamId, suitId)
			numLab:setString(string.format("已镶嵌:%d", count))
			numLab:setVisible(count>0)
		end
		
		local descLab = node:getChildByFullName("descLab")
		if descLab then
			descLab:setString(lang(suitTab.recommendDes))
		end

		local param = {suitData = suitTab, isTouch = false}
		if not suitIcon then
			suitIcon = IconUtils:createHolyIconById(param)
			suitIcon:setScale(0.6)
			suitIcon:setPosition(20, 12)
			node:addChild(suitIcon, 5)
			node.suitIcon = suitIcon
		else
			IconUtils:updateHolyIcon(suitIcon, param)
		end
		registerTouchEvent(suitIcon, function(_,x, y)
				self._viewMgr:closeHintView()
			end,
			function()
				
			end,
			function()
				if not self._inScrolling then
					local runeTab = self._teamModel:getHolyTabBySuitIdAndQuality(suitId, suitTab.makeTips)
					self._viewMgr:showHintView("global.GlobalTipView",
					{
						tipType = 25,
						node = suitIcon,
						id = suitId,
						runeData = {quality = suitTab.makeTips, tabConfig = suitTab},
						desc = lang(runeTab.des2),
						desc2 = lang(runeTab.des4),
						desc3 = lang(runeTab.des6),
						posCenter = true,
					})
				else
					self._inScrolling = false
				end
			end,
			function()
				
			end,
			function()
				
			end
		)
		suitIcon:setSwallowTouches(true)
		if table.nums(suitNum) ~= 0 then
			node:setSaturation(0)
			local clickFlag = false
			local downX, downY
			local posX, posY
			registerTouchEvent(
				node,
				function(_, x, y)
					downY = y
					clickFlag = false
					-- suitIcon:setBrightness(40)
				end, 
				function(_, x, y)
					if downY and math.abs(downY - y) > 5 then
						clickFlag = true
					end
				end, 
				function(_, x, y)
					-- suitIcon:setBrightness(0)
					if clickFlag == false then 
						self._tableState = 3
						self._tableData = self._teamModel:getShowHolyData(suitId)
						table.sort(self._tableData, sortFunc)
						local suitName = tab.runeClient[suitId].name
						self:getUI("bg.rightSubBg.bagPanel.suitNameBg.suitNameLab"):setString(lang(suitName))
						self:addBagTableView()
						local filterBtn = self:getUI("bg.rightSubBg.bagPanel.filterBtn")
						local bagBtn = self:getUI("bg.rightSubBg.bagPanel.bagBtn")
						self:setTitleBtnState(bagBtn, true)
						self:setTitleBtnState(filterBtn, false)
					end
				end,
				function(_, x, y)
					-- suitIcon:setBrightness(0)
				end)
			node:setSwallowTouches(false)
		else
			node:setSaturation(-100)
			local clickFlag = false
			local downX, downY
			local posX, posY
			registerTouchEvent(
				node,
				function(_, x, y)
					downY = y
					clickFlag = false
					-- suitIcon:setBrightness(40)
				end, 
				function(_, x, y)
					if downY and math.abs(downY - y) > 5 then
						clickFlag = true
					end
				end, 
				function(_, x, y)
					-- suitIcon:setBrightness(0)
					if clickFlag == false then 
						self._viewMgr:showTip("没有该装备")
					end
				end,
				function(_, x, y)
					-- suitIcon:setBrightness(0)
				end)
			node:setSwallowTouches(false)
		end
		node:setVisible(true)
	end
	
	return cell
end

function TeamHolyView:numberOfCellsInTableView(inView)
	local num = 0
	if self._tableState == 1 then--正常情况，显示所有宝石
		num = math.ceil(table.nums(self._tableData)/4)<6 and 6 or math.ceil(table.nums(self._tableData)/4)
	elseif self._tableState == 2 then--显示圣徽套装。
		num = table.nums(self._tableData)
	elseif self._tableState == 3 then--圣徽对应的宝石
		num = math.ceil(table.nums(self._tableData)/4)<6 and 6 or math.ceil(table.nums(self._tableData)/4)
	end
	return num
end

function TeamHolyView:touchHolyItemEnd(holyData, stoneData, node)--点击宝石弹提示
	if holyData then
		local rune = self._curSelectTeam.rune or {}
        if rune and rune[tostring(self._selectIndex)] and rune[tostring(self._selectIndex)] ~= 0 then
            local key = rune[tostring(self._selectIndex)]
			local holyDataTemp = self._teamModel:getHolyData()
            local holyId = holyDataTemp[key].id
			local holyTabData = tab.rune[holyId]
			self._viewMgr:closeHintView()
			local score = self._curSelectTeam.score
			self._viewMgr:showHintView("team.TeamHolyTipView", {hintType=3, selectStone = self._selectIndex, teamId=self._teamId, key=key, rightKey=stoneData.key, holyData=holyTabData, bagData = holyData, callback = function()
				self._tablePercent = cc.p(self._bagTableView:getContentOffset())
--				self:updateData()
				self:updateTeamPower({oldPower = score, newPower = self._curSelectTeam.score})
			end})
		else
			self._viewMgr:closeHintView()
			local score = self._curSelectTeam.score
			self._viewMgr:showHintView("team.TeamHolyTipView", {hintType = 2, selectStone = self._selectIndex, teamId = self._teamId, key = stoneData.key, holyData = holyData, callback = function()
				self._tablePercent = cc.p(self._bagTableView:getContentOffset())
--				self:updateData()
				self:inlayEffectCallback(self._selectIndex)
				self:updateTeamPower({oldPower = score, newPower = self._curSelectTeam.score})
			end})
		end
		if not tolua.isnull(self._curSelectHolyNode) then
			local mcOld = self._curSelectHolyNode:getChildByName("mc")
			if mcOld then
				mcOld:setVisible(false)
			end
		end
		
		local mc = node:getChildByName("mc")
		if mc then
			mc:setVisible(true)
		else
			mc = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
			mc:setName("mc")
			mc:setPosition(node:getContentSize().width/2, node:getContentSize().height/2)
			mc:setScale(0.8)
			node:addChild(mc, 1)
		end
		self._curSelectHolyKey = stoneData.key
		self._curSelectHolyNode = node
	end
end

function TeamHolyView:inlayEffectCallback(index)
	local rune = self._curSelectTeam.rune or {}
    local holyData = self._teamModel:getHolyData()
	local tempData = holyData[rune[tostring(index)]]
	local suitId = tempData.make
	local tbSuitIndex = {}
    for i=1,6 do
        local stoneBg = self:getUI("bg.leftPanel.stoneImg" .. i)
        local stoneIcon = self:getUI("bg.leftPanel.stoneImg" .. i )
        local stageLab = self:getUI("bg.leftPanel.stoneImg" .. i .. ".stageLabBg.stageLab")
        local qualityAnim = stoneBg and stoneBg.qualityAnim
        local indexId = tostring(i)
        if rune and rune[indexId] and rune[indexId] ~= 0 then
			if i==index then
				local inlayEffect = mcMgr:createViewMC("fangzhitexiao_shenghuitubiao", false, true)
				if i<3 then
					inlayEffect:setPosition(cc.p(stoneIcon:getContentSize().width/2-5, stoneIcon:getContentSize().height/2+5))
					inlayEffect:setScale(1.4)
				else
					inlayEffect:setPosition(cc.p(stoneIcon:getContentSize().width/2-3, stoneIcon:getContentSize().height/2+3))
				end
				stoneIcon:addChild(inlayEffect, 10)
			end
			local key = rune[indexId]
			local make = holyData[key].make
			table.insert(tbSuitIndex, i)
		end
	end
	if table.nums(tbSuitIndex)>1 then
		for i,v in ipairs(tbSuitIndex) do
			local stoneBg = self:getUI("bg.leftPanel.stoneImg" .. v)
			local stoneIcon = self:getUI("bg.leftPanel.stoneImg" .. v )
			local suitEffect = mcMgr:createViewMC("tiaozhuangjihuo_shenghuitubiao", false, true)
			if v<3 then
				suitEffect:setPosition(cc.p(stoneIcon:getContentSize().width/2-5, stoneIcon:getContentSize().height/2+5))
				suitEffect:setScale(1.4)
			else
				suitEffect:setPosition(cc.p(stoneIcon:getContentSize().width/2-3, stoneIcon:getContentSize().height/2+3))
			end
			stoneIcon:addChild(suitEffect, 10)
		end
	end
end

function TeamHolyView:updateTeamPower(data)
	local fightBg = self:getUI("bg.animBg")
	TeamUtils:setFightAnim(self, {oldFight = data.oldPower, newFight = data.newPower, x = MAX_SCREEN_WIDTH/2, y = MAX_SCREEN_HEIGHT - 150})

	self._powerLabel:setString("战斗力: "..data.newPower)
end

function TeamHolyView:getAsyncRes()
    return 
        {
            {"asset/ui/team.plist", "asset/ui/team.png"},
            {"asset/ui/team1.plist", "asset/ui/team1.png"},
            {"asset/ui/team2.plist", "asset/ui/team2.png"},
        }
end




function TeamHolyView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"RuneCoin","Gold","Gem"},titleTxt = "圣徽"}, nil, ADOPT_IPHONEX and self.fixMaxWidth or nil)
end

function TeamHolyView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end
function TeamHolyView:onTop()
    self._viewMgr:enableScreenWidthBar()
end
function TeamHolyView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function TeamHolyView:onDestroy( )
    self._viewMgr:disableScreenWidthBar()
    TeamHolyView.super.onDestroy(self)
end

return TeamHolyView