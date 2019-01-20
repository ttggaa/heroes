--[[
    Filename:    GuildMapAQView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-7-01 18:15:10
    Description: 斯芬克斯谜题
--]]

local GuildMapAQView = class("GuildMapAQView", BasePopView)

function GuildMapAQView:ctor(param)
    GuildMapAQView.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")

    self._data = param
    self._aqInfo = param.gridInfo
    self._callback = param.callback
end

function GuildMapAQView:onInit()
	local title = self:getUI("bg.title")
	title:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		UIUtils:reloadLuaFile("guild.map.GuildMapAQView")
		end)

	local resultImg = self:getUI("bg.resultImg")
	resultImg:setVisible(false)
end

function GuildMapAQView:reflashUI()
	-- ScheduleMgr:delayCall(0, self, function( )
	self:timeCountDown()

	if self._aqInfo == nil or self._aqInfo["qid"] == nil then
		return
	end

	--版本取表
	local mapId = self._guildMapModel:getData().version
    if mapId == nil then
        return
    end

    local sysMapSetting = tab:GuildMapSetting(mapId)
    if sysMapSetting == nil or sysMapSetting.sphinxQuestion == nil or tab[sysMapSetting.sphinxQuestion] == nil then
        return
    end

	local tabName = sysMapSetting.sphinxQuestion
	local aqQuestion = tab[tabName][self._aqInfo["qid"]]
	if aqQuestion == nil then
		return
	end

	self:refreshUI()

	--问题
	local str = aqQuestion["question"]
	if string.find(str, "color=") == nil then
        str = "[color=d9caab]"..str.."[-]"
    end
	local QDes = self:getUI("bg.QDes")
	local richText = RichTextFactory:create(str, 560, 0)
    richText:setPixelNewline(true)
    richText:formatText()
    richText:setPosition(richText:getContentSize().width * 0.5, QDes:getContentSize().height * 0.5)
    QDes:addChild(richText)

    --选项
	for i=1, 4 do
		local btn = self:getUI("bg.btn" .. i)
		btn.index = i

		local des = btn:getChildByName("des")
		des:setString(aqQuestion["option" .. i])

		--click 答题
		self:registerClickEvent(btn, function()
			local curShowTime = self._guildMapModel:getAQAcTime()
			local curTime = self._userModel:getCurServerTime()
			if curShowTime == nil or #curShowTime < 3 or curTime >= curShowTime[2] or curTime < curShowTime[1] then
				self._viewMgr:showTip("活动已结束")
				return
			end

			self:stopAllActions()
			local selectRes = "guildMap2Img_selectBox.png"
			btn:loadTextures(selectRes, selectRes, selectRes, 1)
			self._serverMgr:sendMsg("GuildMapServer", "sphinxAfter", {tagGid = self._data["targetId"], cid = btn.index}, true, {}, function (result)
                self:checkAnswer(result)
                end)
			end)
	end
	-- end)
end

function GuildMapAQView:refreshUI()
	--score
	local score = self:getUI("bg.score")
	local mapData = self._guildMapModel:getData()
	local sphinx = mapData["sphinx"] or {}
	score:setString(sphinx["score"] or 0)
end

function GuildMapAQView:timeCountDown()
	local curTime = self._userModel:getCurServerTime()
	local firstTime = curTime
	if self._aqInfo["acTime"] then
		firstTime = self._aqInfo["acTime"]
	end

	local upperTime = tab.setting["SPHINXTIMEMAX"].value
	local tempTime = curTime - firstTime

	local countNum = self:getUI("bg.timeBg.time")
	if tempTime >= upperTime then
		local timeStr = TimeUtils.getTimeString(upperTime)
        countNum:setString(timeStr)
        countNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
		return
	end

    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
        cc.CallFunc:create(function()
            if tempTime >= upperTime then
            	local timeStr = TimeUtils.getTimeString(upperTime)
        		countNum:setString(timeStr)
        		countNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
				self:stopAllActions()
			else
				local timeStr = TimeUtils.getTimeString(tempTime)
        		countNum:setString(timeStr)
			end
        end),
        cc.DelayTime:create(1),
        cc.CallFunc:create(function()
        	tempTime = tempTime + 1
        	end))
    ))
end

function GuildMapAQView:checkAnswer(result)
	if result == nil then
		return
	end

	self._viewMgr:lock(-1)
	self:stopAllActions()

	local time = 0
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			local resultImg = self:getUI("bg.resultImg")
			resultImg:setVisible(true)

			local sphinx = result["sphinx"] or {}

			--score
			local score = self:getUI("bg.score")
			local lastScore = tonumber(score:getString()) 
			score:setString(sphinx["score"] or 0)

			if result["quet"] == 1 then  --是否正确
				local disScore = math.max((sphinx["score"] or 0) - lastScore, 0)
				self._viewMgr:showTip("回答正确，获得".. disScore .."认可度")
				resultImg:loadTexture("guildMap2Img_right.png", 1)
			else
				self._viewMgr:showTip("回答错误，没有获得认可度")
				resultImg:loadTexture("guildMap2Img_wrong.png", 1)
			end
			end),
		cc.DelayTime:create(1.5),
		cc.CallFunc:create(function()
			self._viewMgr:unlock()
			DialogUtils.showGiftGet( {
                    gifts = result["reward"],
                    callback = function()
                    	if self._callback then
                    		self._callback()
                    	end

                    	if self.close then
                    		self:close()
                    	end
                    end})
			end)
		))
end

return GuildMapAQView