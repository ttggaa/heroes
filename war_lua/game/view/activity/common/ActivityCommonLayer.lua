--[[
    Filename:    ActivityCommonLayer.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-03-31 15:26:43
    Description: File description
--]]

-- 活动通用Layer 宽高 676 474
-- 需要自己处理资源载入和卸载
local AC_WIDTH = 676
local AC_HEIGHT = 474
local ActivityCommonLayer = class("ActivityCommonLayer", BaseLayer)

function ActivityCommonLayer:ctor()
    ActivityCommonLayer.super.ctor(self)

end

function ActivityCommonLayer:getBgName()
	return nil
end

local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache()

function ActivityCommonLayer:destroy()
	local resList = self:getAsyncRes()
	for i = 1, #resList do
		if type(resList[i]) == "string" then
			tc:removeTextureForKey(resList[i])
		else
	        sfc:removeSpriteFramesFromFile(resList[i][1])
	        tc:removeTextureForKey(resList[i][2])
		end
	end
end

function ActivityCommonLayer:onInit()
    self._widget:setContentSize(AC_WIDTH, AC_HEIGHT)
    self:setContentSize(AC_WIDTH, AC_HEIGHT)

    local bgName = self:getBgName()
    if bgName then
    	local bg = cc.Sprite:create("asset/bg/"..bgName)
    	bg:setAnchorPoint(0, 0)
    	self:addChild(bg, -1)
    end
end

function ActivityCommonLayer:isActivityCanGet()
    return false
end

return ActivityCommonLayer