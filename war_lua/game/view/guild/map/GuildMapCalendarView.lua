--[[
    Filename:    GuildMapCalendarView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-7-01 15:10:10
    Description: 活动周历界面
--]]

local GuildMapCalendarView = class("GuildMapCalendarView", BasePopView)

function GuildMapCalendarView:ctor(param)
    GuildMapCalendarView.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
end

function GuildMapCalendarView:onInit()
	local title = self:getUI("bg.layer.titleBg.Label_12")
	title:setColor(UIUtils.colorTable.ccTitleColor)
	title:enable2Color(1, UIUtils.colorTable.ccTitleEnable2Color)
	title:enableOutline(UIUtils.colorTable.ccTitleOutlineColor, 1)

	for i=1, 6 do
		print(i)
	end

	local ac = self:getUI("bg.layer.ac")
	ac:setVisible(false)
	local light = self:getUI("bg.layer.light")
	light:setVisible(false)

	local closeBtn = self:getUI("bg.layer.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		UIUtils:reloadLuaFile("guild.map.GuildMapCalendarView")
		end)
end

function GuildMapCalendarView:reflashUI()
	local curTime = self._userModel:getCurServerTime()
	local curYear = TimeUtils.date("%Y", curTime)  --string
	local curMonth = TimeUtils.date("%m", curTime) --string
	local curDay = tonumber(TimeUtils.date("%d", curTime))	--num

	local curData = tab.guildMapActiv[tonumber(curYear .. curMonth)]
	dump(curData, "curData")

	if not curData or curData["week"] == nil then
		return
	end

	local posList = {{188, 303}, {460, 303}, {732, 303}, {188, 121}, {460, 121}, {732, 121}}
	local layer = self:getUI("bg.layer")
	for i=1, 6 do
		local ac = self:getUI("bg.layer.ac"):clone()
		ac:setPosition(posList[i][1], posList[i][2])
		ac:setVisible(true)
		layer:addChild(ac)
		local light = self:getUI("bg.layer.light"):clone()
		light:setPosition(posList[i][1], posList[i][2] + 2)
		light:setVisible(true)
		layer:addChild(light)
		local spTip = self:getUI("bg.layer.spTip")

		local title = ac:getChildByName("title")
		local name = ac:getChildByFullName("nameBg.name")
		local tipBg = ac:getChildByName("tipBg")
		local tipDes = ac:getChildByFullName("tipBg.des")
		local acImg = ac:getChildByName("acImg")
		local ruleBtn = ac:getChildByName("ruleBtn")
		local flag = ac:getChildByName("flag")
		local flagDes = ac:getChildByFullName("flag.flagDes")

		name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		title:setColor(cc.c4b(255,252,217,255))
		title:enable2Color(1, cc.c4b(253,204,87,255))
		tipDes:setColor(cc.c4b(255,253,235,255))
		tipDes:enable2Color(1, cc.c4b(253,229,175,255))
		flagDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

		local weeks = curData["week"][i]
		local weekData = curData["week" .. i]

		--spTip / ac
		local isShow = i <= #curData["week"]
		local spTip = self:getUI("bg.layer.spTip")
		ac:setVisible(isShow)
		if i == 6 then
			spTip:setVisible(not isShow)
		end

		--title
		local titleNum = {"一", "二", "三", "四", "五", "六"}
		title:setString("第" .. titleNum[i] .. "周")

		--light
		if curDay >= weeks[1] and curDay <= weeks[2] then
			light:setVisible(true)
			flag:setVisible(true)
		else
			light:setVisible(false)
			flag:setVisible(false)
		end

		--ruleBtn
		ruleBtn:setVisible(false)

		if not weekData then
			acImg:setVisible(false)
			name:setVisible(false)
			tipBg:setVisible(false)
			ac:setSaturation(-180)
			self:registerClickEvent(ac, function() 
				self._viewMgr:showTip(lang("GUILDMAPTIPS_15"))
				end)
		else
			--name
			name:setString(lang(weekData[3]))

			--acImg
			acImg:loadTexture(weekData[1] .. ".jpg", 1)

			--tipBg
			if curDay > weeks[2] then
				tipBg:setVisible(true)
				ac:setSaturation(-180)
			else
				tipBg:setVisible(false)
			end

			self:registerClickEvent(ac, function() 
				self._viewMgr:showDialog("guild.map.GuildMapCalendarTipView", {month = tonumber(curMonth), data = curData, index = i}, true)
				end)
		end
	end
end

function GuildMapCalendarView:getAsyncRes()
    return {{"asset/ui/guildMapAc.plist", "asset/ui/guildMapAc.png"}}
end

return GuildMapCalendarView