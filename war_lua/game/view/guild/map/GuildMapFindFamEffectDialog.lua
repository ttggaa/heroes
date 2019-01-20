--[[
    Filename:    GuildMapFindFamEffectDialog.lua
    Author:      <lannan@playcrab.com>
    Datetime:    2016-04-27 21:29:47
    Description: File description
--]]

local GuildMapFindFamEffectDialog = class("GuildMapFindFamEffectDialog", BasePopView)

function GuildMapFindFamEffectDialog:ctor()
    GuildMapFindFamEffectDialog.super.ctor(self)
end

function GuildMapFindFamEffectDialog:onInit()
	local imgBgTop = cc.Sprite:createWithSpriteFrameName("guild_fam_findImage.png")
	imgBgTop:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT-imgBgTop:getContentSize().height*1.5)
	imgBgTop:setScale(2)
	self:addChild(imgBgTop)
	imgBgTop:setOpacity(0)
	local topAction = cc.Sequence:create(cc.DelayTime:create(0.5), cc.Spawn:create(cc.FadeIn:create(0.2), cc.ScaleTo:create(0.2, 1)))
	imgBgTop:runAction(topAction)
	
	local imgBgUnder = cc.Sprite:createWithSpriteFrameName("guild_fam_findImage.png")
	imgBgUnder:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT-imgBgUnder:getContentSize().height*1.5)
	imgBgUnder:setBrightness(50)
	self:addChild(imgBgUnder)
	imgBgUnder:setOpacity(0)
	
	local underAction = cc.Sequence:create(cc.DelayTime:create(0.6), cc.Spawn:create(cc.FadeTo:create(0.2, 150), cc.ScaleTo:create(0.2, 1.05)), cc.FadeOut:create(0.2))
	imgBgUnder:runAction(underAction)
	
	local mc = mcMgr:createViewMC("mijingrukou_mijingrukou", false, true, function()
		if OS_IS_WINDOWS then
			UIUtils:reloadLuaFile("guild.map.GuildMapFindFamEffectDialog")
		end
		self:close()
	end)
    mc:setPosition(self:getContentSize().width/2+35, self:getContentSize().height/2-10)
    mc:setName(name)
    self:addChild(mc,1000)
    
	local closePanel = self:getUI("closePanel")
	self:registerClickEvent(closePanel, function()
		self:close()
	end)
end

return GuildMapFindFamEffectDialog