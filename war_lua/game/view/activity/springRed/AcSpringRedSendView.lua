--[[
    Filename:    AcSpringRedSendView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-1-23 16:45
    Description: 春节红包
--]]

local AcSpringRedSendView = class("AcSpringRedSendView", BasePopView)

function AcSpringRedSendView:ctor()
	AcSpringRedSendView.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")
	self._sRedModel = self._modelMgr:getModel("SpringRedModel")
	self._lastTime = 0    --上次发送时间
end

function AcSpringRedSendView:onInit()
	local title = self:getUI("bg.bg1.titleBg.titleLab")
	UIUtils:setTitleFormat(title, 1)

	local clip = self:getUI("bg.clip")
	clip:setVisible(false)
	self:registerClickEvent(clip, function()
		clip:setVisible(false)
		end)

	self:registerClickEvent(self._widget, function()
		clip:setVisible(false)
		end)

	self:registerClickEventByName("bg.bg1.closeBtn", function()
		if self._callback then
			self._callback()
		end
		self:close()
		UIUtils:reloadLuaFile("activity.springRed.AcSpringRedView")
		UIUtils:reloadLuaFile("activity.springRed.AcSpringRedSendView")
		UIUtils:reloadLuaFile("activity.springRed.AcSpringRedGetView")
		end)
end

function AcSpringRedSendView:reflashUI(inData)
	local index = inData["index"]
	self._callback = inData["callback"]
	local sysData = tab.actRedPacket[index]

	local title = self:getUI("bg.bg1.titleBg.titleLab")
	title:setString(lang("RedPacketName_" .. index))
	
	local desBg = self:getUI("bg.bg1.desBg")
	local num = desBg:getChildByName("num")
	num:setString(sysData["amount"])

	local rwd1 = self:getUI("bg.bg1.desBg.rwd1")
	local posX = 0
	for s,v in ipairs(sysData["reward_sent"]) do
		local rwdNode, wei = ItemUtils.createRewardNode(v, {scale = 0.33, noOutLine = true})
		rwdNode:setPosition(posX, 0)
		rwd1:addChild(rwdNode)
		posX = posX + wei
	end

	local rwd2 = self:getUI("bg.bg1.desBg.rwd2")
	local posX = 0
	for i,v in ipairs(sysData["reward_get"]) do
		local costNode,wei = ItemUtils.createRewardNode(v, {scale = 0.33, noOutLine = true})
		costNode:setPosition(posX, 0)
		rwd2:addChild(costNode)
		posX = posX + wei
	end

	local costImg = self:getUI("bg.bg1.cost")
	local temp = sysData["exchange"][1][1]
	local img = IconUtils.resImgMap[temp]
	costImg:loadTexture(img, 1)

	local cosNum = self:getUI("bg.bg1.cosNum")
	cosNum:setString(sysData["exchange"][1][3])

	local listClip = self:getUI("bg.bg1.desBg.inputBg.clip")
	self:registerClickEvent(listClip, function()
		self:showWordsList(sysData["wish"])
		end)

	local listBtn = self:getUI("bg.bg1.desBg.inputBg.listBtn")
	self:registerClickEvent(listBtn, function()
		self:showWordsList(sysData["wish"])
		end)

	local str = self:getUI("bg.bg1.desBg.inputBg.clip.str")
	str:setString(lang(sysData["wish"][1]))
	self._wishId = sysData["wish"][1]

	local sendBtn = self:getUI("bg.bg1.sendBtn")
	self:registerClickEvent(sendBtn, function()
		--开启时间
		local isOpen, openT = self._sRedModel:checkRobRedTime()
		if not isOpen then
			local tipDes
			if openT then
				tipDes = string.gsub(lang("RedPacket_Tips1"), "{$num}", openT) 
			else
				tipDes = lang("OVERDUETIPS_1")
			end
			self._viewMgr:showTip(tipDes)
			return
		end

		--钻石不足
		local curGem = self._userModel:getData().gem or 0
		local needGem = sysData["exchange"][1][3] or 0
		if curGem < needGem then
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
			    local viewMgr = ViewManager:getInstance()
			    viewMgr:showView("vip.VipView", {viewType = 0})
			end})
			return
		end

		--时间间隔
		local curTime = self._userModel:getCurServerTime()
		local lastTime = self._sRedModel:getLastSentTime()
		if curTime - lastTime <= tab.setting["G_REDPACKET_CD"].value then
			self._viewMgr:showTip(lang("RedPacket_Tips5"))
			return
		end
	
		self._serverMgr:sendMsg("RedPacketServer", "sendRedPacket", {id = index, wishId = self._wishId}, true, {}, function (result)
			self._lastTime = self._sRedModel:setLastSentTime(curTime)
			if result["reward"] then
				DialogUtils.showGiftGet( {
                    gifts = result["reward"], 
                    notPop = true})
				if self._callback then
					self._callback()
				end
                self:close()
			end
			end)
		end)
end

function AcSpringRedSendView:showWordsList(inData)
	local num = #inData
	local clip = self:getUI("bg.clip")
	clip:setVisible(true)

	local listW, listH, nodeH = 330, 0, 30

	local list = self:getUI("bg.clip.list")
	list:removeAllChildren()
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(listW, nodeH))
	list:addChild(node)


	for i,v in ipairs(inData) do
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
		local txt = cc.Label:createWithTTF(lang(v), UIUtils.ttfName, 20)
		txt:setAnchorPoint(cc.p(0, 0.5))
		txt:setLineBreakWithoutSpace(true)
		txt:setDimensions(listW, 0)
		txt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
		txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		cell._wishId = v
		cell:addChild(txt)

		local txtH = txt:getContentSize().height + 10
		listH = listH + txtH

		cell:setContentSize(cc.size(listW, txtH))
		cell:setPosition(0, nodeH - listH)
		if img then
			img:setContentSize(cc.size(listW, txtH))
			img:setPosition(cell:getContentSize().width * 0.5, cell:getContentSize().height * 0.5)
		end
		txt:setPosition(10, cell:getContentSize().height * 0.5)

		self:registerClickEvent(cell, function()
			self._wishId = cell._wishId
			local str = self:getUI("bg.bg1.desBg.inputBg.clip.str")
			str:setString(lang(cell._wishId))
			clip:setVisible(false)
			end)
	end

	list:setInnerContainerSize(cc.size(listW, listH))

	local tempH = math.max(listH, list:getContentSize().height) - nodeH 
	node:setPosition(0, tempH)
end

return AcSpringRedSendView