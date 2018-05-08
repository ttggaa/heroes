--[[
    Filename:    CGView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-03-16 20:43:31
    Description: File description
--]]

local CGView = class("CGView", BaseView)

function CGView:ctor(data)
    CGView.super.ctor(self)
end

function CGView:onInit()
    audioMgr:stopMusic()
	self:videoBegin()
    self.noSound = true
    ApiUtils.playcrab_device_monitor_action("cgbegin")

    local label = cc.Label:createWithTTF("我是CG动画", UIUtils.ttfName, 60)
    -- label:enableOutline(cc.c4b(0,0,0,255), 1)
    label:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self:addChild(label, 9999)
end

function CGView:onDestroy()
    CGView.super.onDestroy(self)
end

function CGView:videoBegin()
    ScheduleMgr:delayCall(500, self, function()
    	self:videoEnd()
    end)
end

function CGView:videoEnd()
    ApiUtils.playcrab_device_monitor_action("cgend")
    ScheduleMgr:delayCall(0, self, function()
        GuideUtils.unloginGuide()
    end)
end

return CGView