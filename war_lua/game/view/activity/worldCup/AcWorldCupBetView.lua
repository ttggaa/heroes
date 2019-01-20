--[[
    Filename:    AcWorldCupBetView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-05-9 21:20
    Description: 竞猜投注界面
--]]

local AcWorldCupBetView = class("AcWorldCupBetView", BasePopView)

local selectDes = {
	[1] = {{2, "红胜"}, {1, "红大胜"}}, 
	[2] = {{4, "蓝胜"}, {5, "蓝大胜"}},
	[3] = {{3, "平局"}}
}

local winDes = {"红大胜", "红胜", "平局", "蓝胜", "蓝大胜"}

function AcWorldCupBetView:ctor(param)
	AcWorldCupBetView.super.ctor(self)
	self._worldCupModel = self._modelMgr:getModel("WorldCupModel")
	self._userModel = self._modelMgr:getModel("UserModel")
	self._itemModel = self._modelMgr:getModel("ItemModel")

	self._data = param.data
	self._uiType = param.uiType
	self._callback = param.callback

	self._rwdId = 1   --奖励选择下标
	self._oddsIndex = selectDes[self._uiType][1][1]   --赔率下标
end

function AcWorldCupBetView:hideUI()
	local numLab = self:getUI("bg.infoBg.numLab")
	numLab:setVisible(false)

	local Label_36 = self:getUI("bg.infoBg.Label_36")
	Label_36:setPositionY(35)
	Label_36:setFontSize(18)
	local num1 = self:getUI("bg.infoBg.num1")
	num1:setPositionY(35)
	num1:setFontSize(18)
end

function AcWorldCupBetView:onInit()
	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("activity.worldCup.AcWorldCupBetView")
        end
    end)

	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		end)

	local selectBtn1 = self:getUI("bg.selectBtn1")
	self:registerClickEvent(selectBtn1, function()
		self:showSelectList1()
		end)

	local selectBtn2 = self:getUI("bg.selectBtn2")
	self:registerClickEvent(selectBtn2, function()
		self:showSelectList2()
		end)

	local enterBtn = self:getUI("bg.enterBtn")
	self:registerClickEvent(enterBtn, function()
		self:startBet()
		end)
end

function AcWorldCupBetView:reflashUI()
	local sysGuessTeam = tab.guessTeam
	local sysGuessBet = tab.guessBet

	self:hideUI()

	--flag/name
	for i=1, 2 do
        local flagId = self._data["team_" .. i]
        local flag = self:getUI("bg.infoBg.flag" .. i)
        local resImg = sysGuessTeam[flagId]["art"] or "globalImageUI6_meiyoutu"
        flag:loadTexture(resImg .. ".png", 1)
        local flagName = self:getUI("bg.infoBg.flag" .. i .. ".name")
        flagName:setString(lang(sysGuessTeam[flagId]["teamID"]))
        if i == 1 then
        	local vsImg = self:getUI("bg.infoBg.vsImg")
        	local wei = flagName:getContentSize().width * flag:getScale()
        	flag:setPositionX(vsImg:getPositionX() - wei - 50)
        end
    end

    --几人竞猜
	local numLab = self:getUI("bg.infoBg.numLab")
	numLab:setString((self._data["jnum"] or 0) .. "人竞猜")

	--赔率
	local odds = self:getUI("bg.infoBg.num1")
	odds:setString(self._data["odds"][self._oddsIndex])

	--选择1
	local selectBtn1 = self:getUI("bg.selectBtn1")
	selectBtn1:setTouchEnabled(true)
	if self._uiType == 3 then
		self:getUI("bg.selectBtn1.arrow"):setVisible(false)
		selectBtn1:setTouchEnabled(false)
	end

	local des = self:getUI("bg.selectBtn1.des")
	des:setString(winDes[self._oddsIndex])

	--选择2
	self:createSelectCost()

	local clip = self:getUI("bg.clip")
	clip:setVisible(false)
	self:registerClickEvent(clip, function()
		clip:setVisible(false)
	end)
	self:getUI("bg.clip.list1"):setVisible(false)
	self:getUI("bg.clip.list2"):setVisible(false)
end

function AcWorldCupBetView:showSelectList1(inType)
	local clip = self:getUI("bg.clip")
	clip:setVisible(true)
	local list = self:getUI("bg.clip.list1")
	if list:isVisible() then
		return
	end
	self:getUI("bg.clip.list2"):setVisible(false)

	local listW, listH, nodeH = 90, 0, 20
	list:setVisible(true)
	list:removeAllChildren()
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(listW, nodeH))
	list:addChild(node)

	for i=1, 2 do
		local cell = ccui.Layout:create()
		node:addChild(cell)

		--img
		local a, b = math.modf(i * 0.5)
		local img
		if b ~= 0 then
			img = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_frame2.png")
			cell:addChild(img)
		end

		--txt
		local txt = cc.Label:createWithTTF(selectDes[self._uiType][i][2], UIUtils.ttfName, 18)
		txt:setAnchorPoint(cc.p(0, 0.5))
		txt:setLineBreakWithoutSpace(true)
		txt:setDimensions(listW, 0)
		txt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
		txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		cell._id = selectDes[self._uiType][i][1]
		cell._txt = selectDes[self._uiType][i][2]
		cell:addChild(txt)

		local txtH = txt:getContentSize().height + 7
		listH = listH + txtH

		cell:setContentSize(cc.size(listW, txtH))
		cell:setPosition(0, nodeH - listH)

		if img then
			img:setContentSize(cc.size(listW, txtH))
			img:setPosition(cell:getContentSize().width * 0.5, cell:getContentSize().height * 0.5)
		end
		txt:setPosition(10, cell:getContentSize().height * 0.5) 

		self:registerClickEvent(cell, function()
			self._oddsIndex = cell._id
			self:reflashUI()
			end)
	end

	list:setInnerContainerSize(cc.size(listW, listH))

	local tempH = math.max(listH, list:getContentSize().height) - nodeH 
	node:setPosition(0, tempH)
end

function AcWorldCupBetView:showSelectList2(inType)
	local clip = self:getUI("bg.clip")
	clip:setVisible(true)
	local list = self:getUI("bg.clip.list2")
	if list:isVisible() then
		return
	end
	self:getUI("bg.clip.list1"):setVisible(false)

	local listW, listH, nodeH = 150, 0, 30
	list:setContentSize(cc.size(150, 150))
	list:setVisible(true)
	list:removeAllChildren()
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(listW, nodeH))
	list:addChild(node)

	local sysGuessBet = tab.guessBet
	for i,v in ipairs(sysGuessBet) do
		
		local cell = ccui.Layout:create()
		node:addChild(cell)

		--img
		local a, b = math.modf(i * 0.5)
		local img
		if b ~= 0 then
			img = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_frame2.png")
			cell:addChild(img)
		end

		--txt
		local txt = cc.Label:createWithTTF("投", UIUtils.ttfName, 18)
		txt:setAnchorPoint(cc.p(0, 0.5))
		txt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
		txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		cell._id = i
		cell:addChild(txt)

		--icon
		local costType = v["cost"][1]
		local costNum = v["cost"][3]
		local costId = IconUtils.iconIdMap[costType] or v["cost"][2]
		local toolD = tab:Tool(tonumber(costId))
	    local icon = IconUtils:createItemIconById({itemId = costId,itemData = toolD})
	    icon:setSwallowTouches(true)
	    icon:setScale(0.3)
	    cell:addChild(icon)

	    --txt
	    local countNum = ItemUtils.formatItemCount(costNum)
		local txt1 = cc.Label:createWithTTF(countNum .. "个", UIUtils.ttfName, 18)
		txt1:setAnchorPoint(cc.p(0, 0.5))
		txt1:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
		txt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		cell:addChild(txt1)

		--宽/高/位置
		local txtH = txt:getContentSize().height + 10
		listH = listH + txtH

		cell:setContentSize(cc.size(listW, txtH))
		cell:setPosition(0, nodeH - listH)

		if img then
			img:setContentSize(cc.size(listW, txtH))
			img:setPosition(cell:getContentSize().width * 0.5, cell:getContentSize().height * 0.5)
		end
		txt:setPosition(10, cell:getContentSize().height * 0.5)
		icon:setPosition(txt:getPositionX() + txt:getContentSize().width + 7, cell:getContentSize().height * 0.5 - icon:getContentSize().height*0.5*icon:getScale())
		txt1:setPosition(icon:getPositionX() + icon:getContentSize().width * icon:getScale() + 7, txt:getPositionY())

		self:registerClickEvent(cell, function()
			self._rwdId = i
			self:reflashUI()
			end)
	end

	list:setInnerContainerSize(cc.size(listW, listH))

	local tempH = math.max(listH, list:getContentSize().height) - nodeH 
	node:setPosition(0, tempH)
end

function AcWorldCupBetView:createSelectCost()
	local sysGuessBet = tab.guessBet
	local inData = sysGuessBet[self._rwdId]
	--icon
	local rwdIcon = self:getUI("bg.selectBtn2.rwdIcon")
	rwdIcon:removeAllChildren()
	local costType = inData["cost"][1]
	local costNum = inData["cost"][3]
	local costId = IconUtils.iconIdMap[costType] or inData["cost"][2]
	local toolD = tab:Tool(tonumber(costId))
    local icon = IconUtils:createItemIconById({itemId = costId,itemData = toolD})
    icon:setScale(0.35)
    icon:setPosition(-icon:getContentSize().width * icon:getScale() * 0.5 - 28, -icon:getContentSize().height * icon:getScale() * 0.5 + 1)
    rwdIcon:addChild(icon)

    --txt
    local Label_197 = self:getUI("bg.selectBtn2.Label_197")
    local countNum = ItemUtils.formatItemCount(costNum)
    Label_197:setPositionX(80)
    Label_197:setString(countNum .. "个")

    --icon
    local rwdIcon = self:getUI("bg.rwdIcon")
    rwdIcon:removeAllChildren()
	local costType = inData["cost"][1]
	local costNum = inData["cost"][3]
	local costId = IconUtils.iconIdMap[costType] or inData["cost"][2]
	local toolD = tab:Tool(tonumber(costId))
    local icon = IconUtils:createItemIconById({itemId = costId,itemData = toolD})
    icon:setScale(0.3)
    icon:setPosition(-icon:getContentSize().width * icon:getScale() * 0.5, -icon:getContentSize().height * icon:getScale() * 0.5 + 1)
    rwdIcon:addChild(icon)

    --txt
    local temp = tonumber(self:getUI("bg.infoBg.num1"):getString())
    local rwdNum = self:getUI("bg.rwdNum")
    local countNum = ItemUtils.formatItemCount(costNum * temp)
    rwdNum:setPositionX(292)
    rwdNum:setString(countNum .. "个")
end

function AcWorldCupBetView:startBet()
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local rwdData = tab.guessBet[self._rwdId]
	local costType = rwdData["cost"][1]
	local costId = IconUtils.iconIdMap[costType] or rwdData["cost"][2]
	local have, consume = 0, rwdData["cost"][3]
	local name, toolD = "", nil

	if "tool" == costType then
        _, have = self._itemModel:getItemsById(costId)

    elseif "gold" == costType then
        have = userData.gold

    elseif "gem" == costType then
        have = userData.gem
        
    elseif "hDuelCoin" == costType then
        have = userData.hDuelCoin

    elseif "siegePropExp" == costType then
        have = userData.siegePropExp

    elseif "runeCoin" == costType then
        have = userData.runeCoin
    end

    local toolD = tab:Tool(costId)
    local name = lang(toolD["name"])

    have = have or 0
    if have < consume then
    	self._viewMgr:showTip("资源不足")
    	return
    end

    local curTime = self._userModel:getCurServerTime()
    local matchTime = TimeUtils.getIntervalByTimeString(self._data["game_time"])
    if curTime >= matchTime then
        self._viewMgr:showTip("投注已截止")
        return
    end

    local param = {
		raceId = self._data["id"], 
		oddsIndex = self._oddsIndex, 
		value = self._data["team_" .. self._uiType] or 0, 
		betId = self._rwdId
	}
	self._serverMgr:sendMsg("GuessServer", "cathectic", param, true, {}, function(result, errorCode)
		self._viewMgr:showTip("下注成功")
		local betData = {self._rwdId, self._data["team_" .. self._uiType] or 0, self._oddsIndex}   --key队伍id/ 1赌注花费id / 2胜负队伍 / 3赔率
        self._worldCupModel:betSuccess(self._data["id"], betData)
        if self._callback then
        	self._callback()
        end
        self:close()
    end)
end

function AcWorldCupBetView:dtor()
	selectDes = nil
	winDes = nil
end

return AcWorldCupBetView