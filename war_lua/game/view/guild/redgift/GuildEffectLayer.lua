--[[
    Filename:    GuildEffectLayer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-11-08 16:58
    Description: 红包特效界面
--]]
local GuildEffectLayer = class("GuildEffectLayer", BasePopView)

function GuildEffectLayer:ctor(param)
	GuildEffectLayer.super.ctor(self)
	self._data = param.data
	self._callback = param.callback
end

function GuildEffectLayer:onInit()
	local bg = self:getUI("bg")

	-- local blackBg = ccui.Layout:create()
	-- blackBg:setAnchorPoint(cc.p(0.5, 0.5))
 --    blackBg:setBackGroundColorOpacity(200)
 --    blackBg:setBackGroundColorType(1)
 --    blackBg:setBackGroundColor(cc.c3b(0, 0, 0))
 --    blackBg:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
 --    blackBg:setPosition(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5)
    -- bg:addChild(blackBg)

    local animName
    if self._data["reward"]["type"] == "gold" then
        animName = "hongbao3_alliancerobred"
    elseif self._data["reward"]["type"] == "gem" then
        animName = "hongbao2_alliancerobred"
    else
        animName = "hongbao1_alliancerobred"
    end

    local mc1 = mcMgr:createViewMC(animName, false, true, function (_, sender)
    	if self._callback then
    		self._callback()
    	end
    	self:removeFromParent(true)
    end)
    mc1:setAnchorPoint(cc.p(0.5,0.5))
    mc1:setPosition(cc.p(self:getContentSize().width*0.5, self:getContentSize().height*0.5))
    bg:addChild(mc1)
end

function GuildEffectLayer:getMaskOpacity()
    return 200
end

return GuildEffectLayer

