--[[
 	@FileName 	BattleArrayView.lua
	@Authors 	yuxiaojing
	@Date    	2018-07-13 14:36:42
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BattleArrayView = class("BattleArrayView", BaseView)

BattleArrayView.bTeamRaceLogo = {1, 2, 3, 4, 5, 6, 7, 8, 9, 12}
BattleArrayView.bTeamRaceType = {101, 102, 103, 104, 105, 106, 107, 108, 109, 112}
BattleArrayView.bTeamRaceText = {"城堡", "壁垒", "据点", "墓园", "地狱", "塔楼", "地下城", "要塞", "元素", "港口"}
BattleArrayView.bTeamRaceColor = {
    cc.c4b(132, 200, 255, 255), 
    cc.c4b(133, 255, 150, 255),
    cc.c4b(255, 180, 69, 255),
    cc.c4b(103, 203, 188, 255),
    cc.c4b(255, 80, 80, 255), 
    cc.c4b(157, 206, 246, 255),
    cc.c4b(158, 111, 217, 255),
    cc.c4b(168, 206, 101, 255), 
    cc.c4b(224, 115, 159, 255),
    cc.c4b(104, 122, 211, 255),
}

function BattleArrayView:ctor( params )
	BattleArrayView.super.ctor(self)
	params = params or {}
	self._filterType = params.raceType or 101
	self._mapLayer = nil
end

function BattleArrayView:setNavigation( )
	self._viewMgr:showNavigation("global.UserInfoView", {types = {"battleSoul", "Gold", "Gem"}, titleTxt = "战阵", baType = self._filterType})
end

function BattleArrayView:getAsyncRes(  )
	return {
		{"asset/ui/battleArray.plist", "asset/ui/battleArray.png"}
	}
end

function BattleArrayView:getBgName(  )
	return "battleArrayBg.jpg"
end

function BattleArrayView:onTop()
    self._baData = self._baModel:getDataByRace(self._filterType)
	self._activeList = self._baData.aIds or {}
	self._canActiveList = self._baModel:getCanActiveArray(self._filterType, self._activeList, true)
	self._activeLineList = self._baModel:getActiveLine(self._filterType, self._activeList, self._canActiveList)

	self:updateBottomInfo(self._curSelectMid, true)
end

function BattleArrayView:onInit(  )
	self._baModel = self._modelMgr:getModel("BattleArrayModel")
	self._itemModel = self._modelMgr:getModel("ItemModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	if self._mapLayer == nil then
        self._mapLayer = require("game.view.battleArray.BattleArrayLayer").new(function()
        end,self)
        self:addChild(self._mapLayer, -1)
    else
        self._mapLayer:onTop()
    end

    local bgMC = mcMgr:createViewMC("beijing_yangchengjiemian-HD", true, false)
    bgMC:setPosition((MAX_SCREEN_WIDTH - 370) / 2 + 200, MAX_SCREEN_HEIGHT / 2)
    self:addChild(bgMC, -2)

    self._mapView = self._mapLayer._map
    self._bottomInfo = self:getUI("bottomInfo")
    self._infoBg = self:getUI("infoBg")
    self._scrollView = self._infoBg:getChildByFullName("scrollView")
    self._autoList = self._infoBg:getChildByFullName("scrollView.autolist")

    self:initViewUI()

    self._curSelectMid = nil

    local btn_filter = self._bottomInfo:getChildByFullName("btn_filter")
    self:registerClickEvent(btn_filter, function (  )
		self:onFilterButtonClicked()
	end)
	self._btnFilterType = {}
	self._teamRaceType = {101, 102, 103, 104, 105, 106, 107, 108, 109, 112}
	self._layerFilter = self._bottomInfo:getChildByFullName("layer_filter_bg")
	self._layerFilter:setScale(0.6)
	local openRace = tab.setting["BATTLEARRAY_TEAMOPEN"].value
    for i = 1, 10 do
        self._btnFilterType[i] = self._layerFilter:getChildByFullName("raceBtn" .. i)
        self._btnFilterType[i]:setSwallowTouches(true)
        self:registerClickEvent(self._btnFilterType[i], function ()
        	local raceType = BattleArrayView.bTeamRaceType[i]
            self:onFilterTypeButtonClicked(raceType)
        end)
        local raceType = BattleArrayView.bTeamRaceType[i]
        if table.indexof(openRace, raceType) then
        	self._btnFilterType[i]:setVisible(true)
        else
        	self._btnFilterType[i]:setVisible(false)
        end
    end

    local btn_ungrade = self._bottom_btnInfo:getChildByFullName("btn_ungrade")
    self:registerClickEvent(btn_ungrade, function (  )
    	self:onUpgrade()
    end)

    local btn_active = self._bottom_btnInfo:getChildByFullName("btn_active")
    self:registerClickEvent(btn_active, function (  )
    	self:onActive()
    end)

    local btn_reset = self._autoList:getChildByFullName("activeNode.btn_reset")
    self:registerClickEvent(btn_reset, function (  )
    	self:onReset()
    end)

    local btn_info = self._bottomInfo:getChildByFullName("btn_info")
    self:registerClickEvent(btn_info, function (  )
    	self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = lang("BattleArray_Rule")}, true)
    end)

    self:refreshViewInfo()
end

function BattleArrayView:updateConsumeInfo( obj, consume )
	local width = 0
	for i = 1, 2 do
		local item = obj:getChildByFullName("item" .. i)
		local data = consume[i]
		if data then
			item:setVisible(true)
			item:getChildByFullName("icon"):removeAllChildren()
			local itemNum = item:getChildByFullName("num")
			local itemId = data[2]
        	local itemType = data[1]
			if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            local eventStyle = 1
            if itemType == "battleSoul" or itemType == "gold" then
            	eventStyle = 0
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, eventStyle = eventStyle, battleSoulType = self._filterType})
            local dis = 5
            if itemType == "battleSoul" or itemType == "gold" then
            	dis = -3
            	itemIcon:getChildByFullName('iconColor'):setVisible(false)
            	itemIcon:getChildByFullName('boxIcon'):setVisible(false)
            	itemNum:setString(data[3])
            	local curNum = 0
            	if itemType == "gold" then
            		curNum = self._userModel:getData().gold
            	elseif itemType == "battleSoul" then
            		curNum = self._baData.soul or 0
            	end
            	if curNum >= data[3] then
            		itemNum:setColor(cc.c4b(255, 255, 255, 255))
            	else
            		itemNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
            	end
            else
            	local _, curNum = self._itemModel:getItemsById(itemId)
            	if curNum >= data[3] then
            		curNum = data[3]
            		itemNum:setColor(cc.c4b(255, 255, 255, 255))
            	else
            		itemNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
            	end
            	itemNum:setString(curNum .. "/" .. data[3])
            end
            item:getChildByFullName("icon"):addChild(itemIcon)
            local inc = 0
            if i == 2 then
            	inc = 10
            end
            item:setPositionX(width + inc)
            local scale = 33 / itemIcon:getContentSize().width
            itemIcon:setScale(scale)
            itemIcon:setPosition(-(itemIcon:getContentSize().width * scale) / 2, -(itemIcon:getContentSize().height * scale) / 2)
            itemNum:setPositionX(item:getChildByFullName("icon"):getPositionX() + itemIcon:getContentSize().width * scale / 2 + dis)
            item:setContentSize(cc.size(itemNum:getPositionX() + itemNum:getContentSize().width + 3, item:getContentSize().height))
            width = width + item:getContentSize().width + inc
		else
			item:setVisible(false)
		end
	end
	obj:setContentSize(cc.size(width, obj:getContentSize().height))
	obj:setPosition(-obj:getContentSize().width / 2, 2)
end

function BattleArrayView:updateBottomInfo( bid, isForce )
	bid = bid or 1
	if self._curSelectMid == bid and not isForce then return end
	self._curSelectMid = bid
	self._mapView:switchSelectState(self._curSelectMid)
	self:initBottomInfoState()
	if bid ~= 1 then
		if OS_IS_WINDOWS then
			self._bottom_debug:setVisible(true)
			self._bottom_debug:setString("[id:" .. bid .. "," .. self._filterType .. "]")
		end
		local sysData = self._DBData[tonumber(bid)]
		if sysData == nil then
			print("============please call lihuayu===========" .. bid)
			return
		end
		local battleUpDB = self._battleUpDBData[self._baData.lv or 1] or {}

		self._bottom_icon:setVisible(true)
		self._bottom_icon:loadTexture(sysData.activationIcon .. ".png", 1)
		local scale = 23 / self._bottom_icon:getContentSize().width
		self._bottom_icon:setScale(scale)
		self._bottom_name:setString(lang(sysData.diagramName))

		if self._activeList[bid] then
			self._bottom_activeLab:setVisible(true)
		elseif self._canActiveList[bid] then
			local coe1 = battleUpDB.coefficientAtt1 or 1
			local coe2 = battleUpDB.coefficientAtt4 or 1
			self._bottom_btnInfo:setVisible(true)
			self._bottom_btnInfo:getChildByFullName("btn_active"):setVisible(true)
			self._bottom_btnInfo:getChildByFullName("btn_active"):setTouchEnabled(true)
			self._bottom_btnInfo:getChildByFullName("consume"):setVisible(true)
			local item = self._bottom_btnInfo:getChildByFullName("consume.item")
			local consume1 = clone(self._DBData[bid].ecpend or {})
			local consume2 = clone(self._DBData[bid].ecpend2 or {})
			for k, v in pairs(consume1) do
				if v and v[3] then
					v[3] = self._baModel:formatConsumeNumber(math.ceil(v[3] * coe1))
				end
			end
			for k, v in pairs(consume2) do
				if v and v[3] then
					v[3] = math.ceil(v[3] * coe2)
				end
				table.insert(consume1, v)
			end
			self:updateConsumeInfo(item, consume1)
		else
			self._bottom_lockLab:setVisible(true)
		end

		local attr = sysData.diagramAtt or {}
		local attrNode = nil
		if #attr == 1 then
			attrNode = self._bottom_info1
		elseif #attr == 2 then
			attrNode = self._bottom_info2
		end
		if attrNode then
			attrNode:setVisible(true)
			local coe = battleUpDB.coefficientAtt2 or 1
			for i = 1, #attr do
				local name = attrNode:getChildByFullName("name" .. i)
				local num = attrNode:getChildByFullName("num" .. i)
				if name and num then
					name:setString(lang("ATTR_" .. attr[i][1]))
					local numValue = attr[i][2] * coe
					local numValue = self._baModel:formatnumberDecimal(numValue, 2)
					local dd = tab.attClient[attr[i][1]]
					if dd and dd.attType == 1 then
						num:setString("+" .. numValue .. "%")
					else
						num:setString("+" .. numValue)
					end
					num:setPositionX(name:getPositionX() + name:getContentSize().width + 5)
				end
			end
		end
		
		--reward
		local reward = sysData.diagramReward
		if reward and #reward >= 1 and not self._baData["aAIds"][bid] then
			self._bottom_rewardBg:setVisible(true)
			local itemIcon = self._bottom_rewardBg:getChildByTag(9982)
        	if itemIcon then itemIcon:removeFromParent() end

			local itemId = reward[1][2]
        	local itemType = reward[1][1]
			if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = reward[1][3], eventStyle = 1})
            itemIcon:getChildByFullName('iconColor'):getChildByFullName('numLab'):setVisible(false)
            local scale = 28 / itemIcon:getContentSize().width
            itemIcon:setScale(scale)
            self._bottom_rewardBg:addChild(itemIcon)
            local icon = self._bottom_rewardBg:getChildByFullName("icon")
            itemIcon:setPosition(icon:getPositionX() - itemIcon:getContentSize().width * scale / 2, icon:getPositionY() - itemIcon:getContentSize().height * scale / 2)
            icon:setVisible(false)
            self._bottom_rewardBg:getChildByFullName("num"):setString(reward[1][3])
		end
	else
		self._bottom_name:setString("战阵突破")
		if table.nums(self._battleUpDBData) <= self._baData.lv then
			self._bottom_info4:setVisible(true)
			return
		end
		self._bottom_info3:setVisible(true)
		self._bottom_info3:getChildByFullName("levelInfo"):setString("Lv." .. (self._baData.lv + 1) .. "解锁")
		local des = lang(self._battleUpDBData[self._baData.lv + 1].effectDes)
		if des == nil or des == "" then
			des = "please call lihuayu"
		end
		local oldDesLab = self._bottom_info3:getChildByFullName("desc")
		oldDesLab:setVisible(false)
		if self._bottom_info3:getChildByFullName("newDesc") then
			self._bottom_info3:getChildByFullName("newDesc"):removeFromParent()
		end
		local tLabel = {text = des, fontsize = 16, color = cc.c4b(230, 216, 190, 255), width = oldDesLab:getContentSize().width, anchorPoint = ccp(0, 0.5)}
        local text = UIUtils:createMultiLineLabel(tLabel)
        text:setPosition(oldDesLab:getPosition())
        text:setName("newDesc")
        self._bottom_info3:addChild(text)
		self._bottom_btnInfo:setVisible(true)
		self._bottom_btnInfo:getChildByFullName("btn_ungrade"):setVisible(true)
		local maxNum = self._baModel:getLevelupPointsNum(self._filterType)
		local isCanActive = (maxNum <= table.nums(self._activeList))
		UIUtils:setGray(self._bottom_btnInfo:getChildByFullName("btn_ungrade"), not isCanActive)
		self._bottom_btnInfo:getChildByFullName("btn_ungrade"):setTouchEnabled(isCanActive)
		self._bottom_btnInfo:getChildByFullName("lockLab"):setVisible(not isCanActive)
		self._bottom_btnInfo:getChildByFullName("consume"):setVisible(isCanActive)
		if isCanActive then
			local  item = self._bottom_btnInfo:getChildByFullName("consume.item")
			local consume = self._battleUpDBData[self._baData.lv].ecpend or {}
			self:updateConsumeInfo(item, consume)
		end
	end
end

function BattleArrayView:updateRightActiveInfo(  )
	local activeNode = self._autoList:getChildByFullName("activeNode")
	activeNode:getChildByFullName("levelLab"):setString("突破等级：Lv" .. (self._baData.lv or 1))
	local maxNum = self._baModel:getLevelupPointsNum(self._filterType)
	activeNode:getChildByFullName("activeNum"):setString("当前等级激活数量：" .. table.nums(self._baData.aIds) .. "/" .. maxNum)
end

function BattleArrayView:sortAttr( baseAttr )
	local forceSort = {2, 5, 9, 11, 13, 12, 20, 21}
	local attrKeys = table.keys(baseAttr)
	table.sort(attrKeys, function ( v1, v2 )
		local index1 = table.indexof(forceSort, v1) or 999
		local index2 = table.indexof(forceSort, v2) or 999
		if index1 == index2 then
			return v1 < v2
		else
			return index1 < index2
		end
	end)
	return attrKeys
end

function BattleArrayView:createRightInfo(  )
	self:updateRightActiveInfo()
	
	local propNode = self._autoList:getChildByFullName("propNode")
	local baseProp = propNode:getChildByFullName("prop")
	baseProp:setVisible(false)
	local children = propNode:getChildren()
	local count = #children
	for i = 1, count do
		local child = children[i]
		local name = child:getName()
		if name ~= "title" and name ~= "prop" then
			child:removeFromParent()
		end
	end

	local baseAttr, allAttr = self._baModel:getpropDataByRace(self._filterType)
	local sortKeys = self:sortAttr(baseAttr)
	local index = 0
	for i = #sortKeys, 1, -1 do
		index = index + 1
		local k = sortKeys[i]
		local v = baseAttr[k]
		local node = baseProp:clone()
		node:setName("node" .. k)
		local icon = node:getChildByFullName("icon")
		local name = node:getChildByFullName("name")
		local num = node:getChildByFullName("num")
		icon:loadTexture("battleArray_attr_" .. k .. ".png", 1)
		name:setString(lang("ATTR_" .. k))
		local numStr = " " .. v .. "/" .. allAttr[k]
		local dd = tab.attClient[k]
		if dd and dd.attType == 1 then
			numStr = numStr .. "%"
		end
		num:setString(numStr)
		num:setPositionX(name:getPositionX() + name:getContentSize().width)
		num:setVisible(true)
		node:setPosition(0, (index - 1) * node:getContentSize().height + 7)
		node:setVisible(true)
		propNode:addChild(node)
	end
	propNode:getChildByFullName("title"):setPositionY(index * baseProp:getContentSize().height + 7)
	local allHeight = propNode:getChildByFullName("title"):getContentSize().height + index * baseProp:getContentSize().height + 7
	propNode:setContentSize(cc.size(propNode:getContentSize().width, allHeight))

	local effectNode = self._autoList:getChildByFullName("effectNode")
	local baseEffect = effectNode:getChildByFullName("prop")
	baseEffect:setVisible(false)
	local children = effectNode:getChildren()
	local count = #children
	for i = 1, count do
		local child = children[i]
		local name = child:getName()
		if name ~= "title" and name ~= "prop" then
			child:removeFromParent()
		end
	end
	local num = self._battleUpDBData[self._baData.lv].effectShow or table.nums(self._battleUpDBData)
	local nodePosY = 0
	for i = num, 2, -1 do
		local node = baseEffect:clone()
		node:setName("node" .. i)
		local icon = node:getChildByFullName("icon")
		local levelLab = node:getChildByFullName("level")
		local level = self._baData.lv or 1
		levelLab:setString("Lv." .. i .. ":")
		local color = cc.c4b(250, 230, 200, 255)
		if level >= i then
			icon:loadTexture("globalImageUI_propActive1.png", 1)
		else
			color = cc.c4b(122, 120, 123, 255)
			icon:loadTexture("globalImageUI_propActive2.png", 1)
		end
		levelLab:setColor(color)
		local des = lang(self._battleUpDBData[i].effectDes)
		if des == nil or des == "" then
			des = "please call lihuayu"
		end
		local w = node:getContentSize().width - levelLab:getPositionX() - levelLab:getContentSize().width - 6
        local tLabel = {text = des, fontsize = 20, color = color, width = w, anchorPoint = ccp(0, 0)}
        local text = UIUtils:createMultiLineLabel(tLabel)
        text:setPosition(levelLab:getPositionX() + levelLab:getContentSize().width + 3, 0)
        node:addChild(text)
        local nodeH = text:getContentSize().height
        if nodeH < 32 then
        	nodeH = 32
        else
        	icon:setPositionY(nodeH - 10)
        	levelLab:setPositionY(nodeH - 10)
        end
        nodeH = nodeH + 7
        node:setContentSize(cc.size(node:getContentSize().width, nodeH))
        node:setVisible(true)
        node:setPosition(0, nodePosY)
        effectNode:addChild(node)
        nodePosY = nodePosY + nodeH
	end
	effectNode:getChildByFullName("title"):setPositionY(nodePosY)
	effectNode:setContentSize(cc.size(effectNode:getContentSize().width, nodePosY + effectNode:getChildByFullName("title"):getContentSize().height))

	self:resetRightInfoPosition()
end

function BattleArrayView:updateRightInfo(  )
	self:updateRightActiveInfo()

	local propNode = self._autoList:getChildByFullName("propNode")
	local baseAttr, allAttr = self._baModel:getpropDataByRace(self._filterType)
	local index = 0
	local sortKeys = self:sortAttr(baseAttr)
	local index = 0
	for i = #sortKeys, 1, -1 do
		index = index + 1
		local k = sortKeys[i]
		local v = baseAttr[k]
		local node = propNode:getChildByFullName("node" .. k)
		if node then
			local icon = node:getChildByFullName("icon")
			local num = node:getChildByFullName("num")
			local numStr = " " .. v .. "/" .. allAttr[k]
			local dd = tab.attClient[k]
			if dd and dd.attType == 1 then
				numStr = numStr .. "%"
			end
			num:setString(numStr)
		end
	end
end

function BattleArrayView:updateRedPrompt(  )
	local redPrompt = self._baModel:getRedPrompt()
	local btn_filter = self._bottomInfo:getChildByFullName("btn_filter")
	local isShowRed = false
	if table.indexof(redPrompt, self._filterType) then
		if #redPrompt > 1 then
			isShowRed = true
		end
	elseif #redPrompt > 0 then
		isShowRed = true
	end
	UIUtils.addRedPoint(btn_filter, isShowRed, cc.p(btn_filter:getContentSize().width - 5, btn_filter:getContentSize().height - 5))
	for k, v in pairs(self._btnFilterType) do
		local raceType = self._teamRaceType[k]
		local isShowRed = false
		if table.indexof(redPrompt, raceType) and self._filterType ~= raceType then
			isShowRed = true
		end
		UIUtils.addRedPoint(v, isShowRed, cc.p(v:getContentSize().width - 7, v:getContentSize().height - 7))
	end
end

function BattleArrayView:refreshViewInfo(  )
	self._baData = self._baModel:getDataByRace(self._filterType)
	self._activeList = self._baData.aIds or {}
	self._canActiveList = self._baModel:getCanActiveArray(self._filterType, self._activeList, true)
	self._activeLineList = self._baModel:getActiveLine(self._filterType, self._activeList, self._canActiveList)
	self._DBData = self._baModel:getDBDataByRace(self._filterType)
	self._battleUpDBData = self._baModel:getBattleUpDBDataByRace(self._filterType)

	self:updateArrayInfo()
	self:setNavigation()
	self._mapView:reflashView()
	self:createRightInfo()
	self:updateFightNum()
	self:updateBottomInfo(self._curSelectMid, true)
	self:updateRedPrompt()
end

function BattleArrayView:onFilterButtonClicked(  )
	local isShow = not self._layerFilter:isVisible()
    local sequenceAction
    if isShow then
        local scale = cc.ScaleTo:create(0.1, 1)
        local move = cc.MoveTo:create(0.1, cc.p(22, 124))
        local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 255))
        sequenceAction = cc.Sequence:create(cc.CallFunc:create(function()
            self._layerFilter:setVisible(isShow)
        end), spawn)
        self._layerFilter:runAction(sequenceAction)
    else
        local scale = cc.ScaleTo:create(0.1, 0.6)
        local move = cc.MoveTo:create(0.1, cc.p(22, 124))
        local spawn = cc.Spawn:create(scale, move, cc.FadeTo:create(0.1, 0))
        sequenceAction = cc.Sequence:create(spawn, cc.CallFunc:create(function()
            self._layerFilter:setVisible(isShow)
        end))
        self._layerFilter:runAction(sequenceAction)
    end
end

function BattleArrayView:onFilterTypeButtonClicked( fType )
	if self._filterType == fType then return end
	self._filterType = fType
	self._layerFilter:setVisible(false)
	self:refreshViewInfo()
end

function BattleArrayView:updateFightNum( isAnim )
	local parentNode = self._infoBg:getChildByFullName("arrayInfo")
	local fightLab = parentNode:getChildByFullName('fightLab')
	if fightLab == nil then
		fightLab = ccui.TextBMFont:create("a+", UIUtils.bmfName_zhandouli_little)
	    fightLab:setAnchorPoint(cc.p(0, 0.5))
	    fightLab:setScale(0.47)
	    fightLab:setName("fightLab")
	    parentNode:addChild(fightLab)
	end
	local raceLab = self._infoBg:getChildByFullName("arrayInfo.logoLab")
	fightLab:setPosition(raceLab:getPositionX() + raceLab:getContentSize().width + 5, 85)

	local fightNum = parentNode:getChildByFullName("fightNum")
	if not fightNum then
		fightNum = cc.LabelBMFont:create("0", UIUtils.bmfName_zhandouli_little)
		fightNum:setAnchorPoint(0, 0.5)
		fightNum:setScale(0.47)
		fightNum:setName("fightNum")
		parentNode:addChild(fightNum)
	end
	fightNum:setPosition(fightLab:getPositionX() + fightLab:getContentSize().width * fightLab:getScale(), 85)
	
	if not isAnim then
		fightNum:setString(self._baData.score)
		return
	end
	local oldPropFight = tonumber(fightNum:getString())
	TeamUtils:setFightAnim(self, {oldFight = oldPropFight, newFight = self._baData.score, x = self:getContentSize().width*0.5-100, y = self:getContentSize().height - 200})
	fightNum:setString(self._baData.score)
end

function BattleArrayView:updateArrayInfo(  )
	local fType = table.indexof(BattleArrayView.bTeamRaceType, self._filterType)
	local raceIndex = BattleArrayView.bTeamRaceLogo[fType] or 1
	self._infoBg:getChildByFullName("arrayInfo.logoImg"):loadTexture("globalImgUI_class" .. raceIndex .. ".png", 1)
	self._infoBg:getChildByFullName("arrayInfo.logoLab"):setString(BattleArrayView.bTeamRaceText[fType])
	self._infoBg:getChildByFullName("arrayInfo.logoLab"):setColor(BattleArrayView.bTeamRaceColor[fType])
	self._infoBg:getChildByFullName("arrayInfo.logoLab"):enableOutline(cc.c4b(0,0,0,255), 1)
	self._infoBg:getChildByFullName("arrayInfo.desc"):setString(lang("battleArray_race_" .. self._filterType))
end

function BattleArrayView:upgradeSuccess(  )
	self._baData = self._baModel:getDataByRace(self._filterType)
	self._activeList = self._baData.aIds or {}
	self._canActiveList = self._baModel:getCanActiveArray(self._filterType, self._activeList, true)
	self._activeLineList = self._baModel:getActiveLine(self._filterType, self._activeList, self._canActiveList)

	self._mapView:reflashView()
	self:updateBottomInfo(self._curSelectMid, true)
	self:createRightInfo()
	self:updateRedPrompt()

	self._viewMgr:showDialog("battleArray.BattleArrayUpgradeSuccessDialog", {level = self._baData.lv, raceType = self._filterType, callback = function (  )
		self:updateFightNum(true)
	end})
end

function BattleArrayView:activeSuccess( result )
	self._baData = self._baModel:getDataByRace(self._filterType)
	self._activeList = self._baData.aIds or {}
	local activeList = {}
	activeList[self._curSelectMid] = 1

	self._canActiveList = self._baModel:getCanActiveArray(self._filterType, self._activeList, true)

	local allActiveLine = self._baModel:getActiveLine(self._filterType, self._activeList, self._canActiveList)
	local activeLine = {}
	for k, v in pairs(allActiveLine) do
		if not self._activeLineList[k] then
			activeLine[k] = v
		end
	end
	self._activeLineList = allActiveLine
	self._mapView:updatePartView(activeList, activeLine)
	self:updateBottomInfo(self._curSelectMid, true)
	self:updateRightInfo()
	self:updateFightNum(true)
	self:updateRedPrompt()
	self._mapView:showPointMC(self._curSelectMid, "active")
	local maxNum = self._baModel:getLevelupPointsNum(self._filterType)
	local isAllLight = (maxNum <= table.nums(self._activeList))
	if isAllLight then
		self._mapView:showAllLightMC()
	end
	if result and result["reward"] then
		DialogUtils.showGiftGet({
	        gifts = result["reward"],
	        notPop = true
	    })
	end
end

function BattleArrayView:resetSuccess(  )
	local resetP = clone(self._activeList)
	self._baData = self._baModel:getDataByRace(self._filterType)
	self._activeList = self._baData.aIds or {}
	self._canActiveList = self._baModel:getCanActiveArray(self._filterType, self._activeList, true)
	self._activeLineList = self._baModel:getActiveLine(self._filterType, self._activeList, self._canActiveList)
	self._mapView:reflashView("reset", resetP)
	self:updateRightInfo()
	self:updateFightNum()
	self:updateRedPrompt()
end

function BattleArrayView:onUpgrade(  )
	local consume = self._battleUpDBData[self._baData.lv].ecpend or {}
	if consume[1] then
		local itemId = consume[1][2]
		local itemType = consume[1][1]
		if itemType and itemType ~= "tool" then
			itemId = IconUtils.iconIdMap[itemType]
		end
		if itemId then
			local haveNum, needNum = 0, consume[1][3]
        	if "tool" == itemType then
        		local _, num = self._itemModel:getItemsById(itemId)
        		haveNum = num
        	elseif "gold" == itemType then
        		haveNum = self._userModel:getData().gold
        	elseif "gem" == itemType then
        		haveNum = self._userModel:getData().freeGem + self._userModel:getData().payGem
        	end
        	if haveNum < needNum then
        		if itemType == "gold" then
        			DialogUtils.showLackRes( {goalType = "gold"})
        		elseif itemType == "tool" then
        			DialogUtils.showItemApproach(itemId)
        		end
        		return
        	end
		end
	end
	local soul = self._baData.soul or 0
	local consume = self._needConsume or 0
	if soul < consume then
		self._viewMgr:showDialog("global.GlobalPromptDialog", {indexId = 22})
		return
	end
	self._serverMgr:sendMsg("BattleArrayServer", "upgrade", {bid = self._filterType}, true, {}, function(data)
		self:upgradeSuccess()
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        self._viewMgr:unlock()
    end)
end

function BattleArrayView:onActive(  )
	local battleUpDB = self._battleUpDBData[self._baData.lv or 1] or {}
	local coe1 = battleUpDB.coefficientAtt1 or 1
	local coe2 = battleUpDB.coefficientAtt4 or 1

	local consume1 = self._DBData[self._curSelectMid].ecpend or {}
	local soul = self._baData.soul or 0
	local needNum = 0
	if consume1[1] and consume1[1][3] then
		needNum = self._baModel:formatConsumeNumber(math.ceil(consume1[1][3] * coe1))
	end

	if needNum > 0 and soul < needNum then
		self._viewMgr:showDialog("global.GlobalPromptDialog", {indexId = 22})
		return
	end
	local consume2 = self._DBData[self._curSelectMid].ecpend2 or {}
	if consume2[1] then
		local itemType = consume2[1][1]
		local itemId = consume2[1][2]
		if itemType and itemType ~= "tool" then
            itemId = IconUtils.iconIdMap[itemType]
        end
        if itemId then
        	local haveNum, needNum = 0, math.ceil(consume2[1][3] * coe2)
        	if "tool" == itemType then
        		local _, num = self._itemModel:getItemsById(itemId)
        		haveNum = num
        	elseif "gold" == itemType then
        		haveNum = self._userModel:getData().gold
        	end
        	if haveNum < needNum then
        		DialogUtils.showItemApproach(itemId)
        		return
        	end
        end
	end
	self._serverMgr:sendMsg("BattleArrayServer", "active", {bid = self._filterType, mid = self._curSelectMid}, true, {}, function(data)
		self:activeSuccess(data)
    end, function ( errorId )
        errorId = tonumber(errorId)
        print("errorId:" .. errorId)
        self._viewMgr:unlock()
    end)
end

function BattleArrayView:onReset(  )
	local returnRes = self._baModel:getResetReturnRes(self._filterType)
	if #returnRes <= 0 then
		self._viewMgr:showTip(lang("TIP_BattleArray_Reset"))
		return
	end
	self._viewMgr:showDialog("battleArray.BattleArrayResetDialog", {
		returnRes = returnRes,
		raceType = self._filterType,
		resetCallback = function (  )
			self._serverMgr:sendMsg("BattleArrayServer", "reset", {bid = self._filterType}, true, {}, function(data)
				self:resetSuccess()
		    end, function ( errorId )
		        errorId = tonumber(errorId)
		        print("errorId:" .. errorId)
		        self._viewMgr:unlock()
		    end)
		end
		})
end

function BattleArrayView:resetRightInfoPosition(  )
	local activeNode = self._autoList:getChildByFullName("activeNode")
	local propNode = self._autoList:getChildByFullName("propNode")
	local effectNode = self._autoList:getChildByFullName("effectNode")

	local totalHeight = 0
	effectNode:setPositionY(0)
	totalHeight = totalHeight + effectNode:getContentSize().height
	propNode:setPositionY(totalHeight)
	totalHeight = totalHeight + propNode:getContentSize().height
	activeNode:setPositionY(totalHeight)
	totalHeight = totalHeight + activeNode:getContentSize().height

	self._autoList:setContentSize(cc.size(self._autoList:getContentSize().width, totalHeight))
	self._autoList:setPositionY(0)
	local minH = self._scrollView:getContentSize().height
	if totalHeight < minH then
		self._autoList:setPositionY(minH - totalHeight)
		totalHeight = minH
	end
	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, totalHeight))
end

function BattleArrayView:initBottomInfoState(  )
	self._bottom_icon:setVisible(false)
	self._bottom_info1:setVisible(false)
	self._bottom_info2:setVisible(false)
	self._bottom_info3:setVisible(false)
	self._bottom_info4:setVisible(false)
	self._bottom_rewardBg:setVisible(false)
	self._bottom_activeLab:setVisible(false)
	self._bottom_lockLab:setVisible(false)
	self._bottom_btnInfo:setVisible(false)
	self._bottom_debug:setVisible(false)
	self._bottom_btnInfo:getChildByFullName("btn_ungrade"):setVisible(false)
	self._bottom_btnInfo:getChildByFullName("btn_active"):setVisible(false)
	self._bottom_btnInfo:getChildByFullName("lockLab"):setVisible(false)
	self._bottom_btnInfo:getChildByFullName("consume"):setVisible(false)
end

function BattleArrayView:getRegisterNames(  )
	return {
		{"bottom_icon", "bottomInfo.infoBg.icon"},
		{"bottom_name", "bottomInfo.infoBg.name"},
		{"bottom_rewardBg", "bottomInfo.infoBg.rewardBg"},
		{"bottom_info1", "bottomInfo.infoBg.info1"},
		{"bottom_info2", "bottomInfo.infoBg.info2"},
		{"bottom_info3", "bottomInfo.infoBg.info3"},
		{"bottom_info4", "bottomInfo.infoBg.info4"},
		{"bottom_activeLab", "bottomInfo.infoBg.activeLab"},
		{"bottom_lockLab", "bottomInfo.infoBg.lockLab"},
		{"bottom_btnInfo", "bottomInfo.infoBg.btnInfo"},
		{"bottom_debug", "bottomInfo.infoBg.debug"},
	}
end

function BattleArrayView:initViewUI(  )
	self._bottomInfo:getChildByFullName("infoBg"):setPositionX((MAX_SCREEN_WIDTH - self._infoBg:getContentSize().width) / 2)
	self._bottomInfo:getChildByFullName("infoBg.rewardBg.label"):setColor(cc.c3b(188, 146, 95))
	self._bottomInfo:getChildByFullName("infoBg.rewardBg.label"):enable2Color(1, cc.c3b(239, 229, 173))
	self._autoList:getChildByFullName("activeNode.title.title"):setColor(cc.c3b(168, 218, 245))
	self._autoList:getChildByFullName("activeNode.title.title"):enable2Color(1, cc.c3b(209, 244, 248))
	self._autoList:getChildByFullName("propNode.title.title"):setColor(cc.c3b(168, 218, 245))
	self._autoList:getChildByFullName("propNode.title.title"):enable2Color(1, cc.c3b(209, 244, 248))
	self._autoList:getChildByFullName("effectNode.title.title"):setColor(cc.c3b(168, 218, 245))
	self._autoList:getChildByFullName("effectNode.title.title"):enable2Color(1, cc.c3b(209, 244, 248))
	self._bottomInfo:getChildByFullName("infoBg.btnInfo.btn_active"):setTitleFontSize(26)
	self._bottomInfo:getChildByFullName("infoBg.btnInfo.btn_ungrade"):setTitleFontSize(26)
	self._autoList:getChildByFullName("activeNode.btn_reset"):setTitleFontSize(26)
end

return BattleArrayView