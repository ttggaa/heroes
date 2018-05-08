--[[
    Filename:    AcSpringRedView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-1-23 16:45
    Description: 春节红包
--]]

local AcSpringRedView = class("AcSpringRedView", BasePopView)

function AcSpringRedView:ctor(param)
	AcSpringRedView.super.ctor(self)

	self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
	self._sRedModel = self._modelMgr:getModel("SpringRedModel")

end

function AcSpringRedView:getAsyncRes()
    return {
	    {"asset/ui/acSpringRed.plist", "asset/ui/acSpringRed.png"},
	    {"asset/ui/activityCarnival.plist", "asset/ui/activityCarnival.png"},
	}
end

function AcSpringRedView:onInit()
	local bg = self:getUI("bg.bg1")
	bg:loadTexture("asset/bg/activity_bg_paper.png")

	local redPoint = self:getUI("bg.logBtn.redPoint")
	redPoint:setVisible(false)

	--closeBtn
	self:registerClickEventByName("bg.closeBtn", function()
		if self._callback then
			self._callback()
		end
		self:close()
		end)

	--ruleBtn
	self:registerClickEventByName("bg.ruleBtn", function()
		self._viewMgr:showDialog("global.GlobalRuleDescView", {desc = lang("RedPacket_Rule")}, true)
		end)

	--logBtn
	self:registerClickEventByName("bg.logBtn", function()
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

		self._serverMgr:sendMsg("RedPacketServer", "getRedPacketInfo", {}, true, {}, function (result)
			self._sRedModel:clearPushRobData()
			self._viewMgr:showDialog("activity.springRed.AcSpringRedGetView", {
				data = result,
				callback = function()
					self:refreshUI()
				end}, true)
		end)
	end)

	self:setListenReflashWithParam(true)
    self:listenReflash("SpringRedModel", self.refreshUI)

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
			UIUtils:reloadLuaFile("activity.springRed.AcSpringRedView")
			UIUtils:reloadLuaFile("activity.springRed.AcSpringRedSendView")
			UIUtils:reloadLuaFile("activity.springRed.AcSpringRedGetView")
			UIUtils:reloadLuaFile("activity.springRed.AcSpringRedNoticeView")

        elseif eventType == "enter" then
	        
        end
    end)

    self:refreshUI()
end

function AcSpringRedView:reflashUI(inData)
	self._callback = inData.callback

	local sysRedPacket = tab.actRedPacket
	for i=1, 3 do
		--标题
		local title = self:getUI("bg.box" .. i .. ".titleDes")
		title:setString(lang("RedPacketName_" .. i))
		if i == 1 then
			title:setColor(cc.c4b(250, 244, 228, 255))
			title:enable2Color(1, cc.c4b(221, 203, 167, 255))
			title:enableOutline(cc.c4b(66, 66, 66, 255), 1)
		else
			title:setColor(cc.c4b(255, 250, 239, 255))
			title:enable2Color(1, cc.c4b(250, 198, 92, 255))
			title:enableOutline(cc.c4b(108, 49, 25, 255), 1)
		end

		--box
		local boxData = sysRedPacket[i]
		local box = self:getUI("bg.box" .. i)
		self:registerClickEvent(box, function()
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

			local isCan = self._sRedModel:checkGetDayInfo(1, i)
			if not isCan then
				self._viewMgr:showTip(lang("RedPacket_Tips3"))
				return
			end

			self._viewMgr:showDialog("activity.springRed.AcSpringRedSendView", {
				index = i,
				callback = function() 
					self:refreshUI() 
				end}, true)
			end)

		--reward
		local rwdNode = self:getUI("bg.box" .. i ..".rwdNode")
		local posX = 10
		for i,v in ipairs(boxData["reward_get"]) do
			local rwd, rwdW = ItemUtils.createRewardNode(v, {scale = 0.33})
			rwd:setPosition(posX, 2)
			posX = posX + rwdW
			rwdNode:addChild(rwd)
		end
	end

	local acData = self._sRedModel:getAcData()
	if next(acData) then
		local startT = acData.start_time
		local endT = acData.end_time - 86400
		local startY = TimeUtils.getDateString(startT,"%m")
		local startM = TimeUtils.getDateString(startT,"%d")
		local endY = TimeUtils.getDateString(endT,"%m")
		local endM = TimeUtils.getDateString(endT,"%d")
		local acTime = self:getUI("bg.tipDes2")
		acTime:setString(startY .. "月" .. startM .. "日-" .. endY .. "月" .. endM .. "日")
	end
end

function AcSpringRedView:refreshUI()
	self._data = self._sRedModel:getData()
	local redPoint = self:getUI("bg.logBtn.redPoint")
	local isShowRp = self._sRedModel:isShowRedPoint()
	redPoint:setVisible(isShowRp)
	
	local dayinfo = {80, 81, 82}
	local sysRedPacket = tab.actRedPacket
	for i=1, 3 do
		local boxData = sysRedPacket[i]
		local curNum = self._playerTodayModel:getDayInfo(dayinfo[i])
		local maxNum = boxData["limit_sent"] 
		local num = self:getUI("bg.box" .. i .. ".num")
		num:setString(math.max(maxNum - curNum, 0))
	end
end

return AcSpringRedView