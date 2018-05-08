--[[
    Filename:    GuildAdView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-7-04 15:30:10
    Description: 联盟广告界面
--]]

local GuildAdView = class("GuildAdView", BasePopView)

function GuildAdView:ctor(param)
    GuildAdView.super.ctor(self)

	self._callback = param.callback
	self._adList = param.adList
	self._curType = param.inType  --1地图广告 2联盟大厅广告
	self._curIndex = 1     --当前展示的广告顺序
end

function GuildAdView:onInit()
	--右上角 切换按钮 
	local switchBtn = self:getUI("bg.switchBtn")
	if self._curType == 1 then
		switchBtn:setVisible(false)
	end
	self:registerClickEvent(switchBtn, function() 
		self:updateAdImg()
		end)

	--关闭按钮
	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function() 
		if self._callback then
        	self._callback()
        end
		UIUtils:reloadLuaFile("guild.GuildAdView")
		self:close()
		end)

	self:updateAdImg()
end

--切换广告页
function GuildAdView:updateAdImg()
	if #self._adList < self._curIndex then
        if self._callback then
        	self._callback()
        end
        UIUtils:reloadLuaFile("guild.GuildAdView")
		self:close(false)

	else
		--生成广告UI
		local adRes = self._adList[self._curIndex]
		local adImg = self:getUI("bg.img")
		adImg:removeAllChildren()
		adImg:loadTexture("asset/bg/guildMap/" .. adRes .. ".jpg")

		if adRes == "guildAd_guaishouxiaowu" then
			local richTxt = RichTextFactory:create(lang("AD_GUILD_1"), 800, 22)                 
		    richTxt:formatText()
		    richTxt:setAnchorPoint(cc.p(0.5,0.5))
		    richTxt:setPosition(80 + richTxt:getContentSize().width*0.5, 21)  --160, 21
		    adImg:addChild(richTxt)
		end

		self._curIndex = self._curIndex + 1
	end
end

return GuildAdView