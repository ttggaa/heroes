--[[
    Filename:    GuildMapCalendarTipView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-7-01 18:15:10
    Description: 活动周历界面
--]]

local GuildMapCalendarTipView = class("GuildMapCalendarTipView", BasePopView)

function GuildMapCalendarTipView:ctor(param)
    GuildMapCalendarTipView.super.ctor(self)
    self._data = param.data
    self._index = param.index
    self._month = param.month
end

function GuildMapCalendarTipView:onInit()
	local weeekData = self._data["week" .. self._index]
	if weeekData then
		local img = self:getUI("bg.img")
		img:loadTexture("asset/bg/guildMap/" .. weeekData[2] .. ".jpg")

		local title = self:getUI("bg.titleBg.title")
		title:setString(lang(weeekData[3]))
		title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	end

	local weekList = self._data["week"]
	if weekList[self._index] then
		local time = self:getUI("bg.titleBg.time")
		local startT = weekList[self._index][1]
		local endT = weekList[self._index][2]
		time:setString(self._month .. "月" .. startT .. "日-" .. self._month .. "月" .. endT .. "日")
		time:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	end

	local bg = self:getUI("bg")
	self:registerClickEvent(bg, function()
		self:close()
		UIUtils:reloadLuaFile("guild.map.GuildMapCalendarTipView")
		end)
end

return GuildMapCalendarTipView