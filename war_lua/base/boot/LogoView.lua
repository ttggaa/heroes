--[[
    Filename:    LogoView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-04-20 16:09:13
    Description: File description
--]]

local LogoView = class("LogoView")

local MAX_SCREEN_WIDTH = cc.Director:getInstance():getWinSizeInPixels().width
local MAX_SCREEN_HEIGHT = cc.Director:getInstance():getWinSizeInPixels().height
local MAX_SCREEN_REAL_WIDTH, MAX_SCREEN_REAL_HEIGHT = MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT
if MAX_SCREEN_WIDTH > 1600 then
    MAX_SCREEN_WIDTH = 1600
end
local SCREEN_X_OFFSET = (MAX_SCREEN_REAL_WIDTH - MAX_SCREEN_WIDTH) * 0.5
local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
local fu = cc.FileUtils:getInstance()

function LogoView:ctor(scene)
    scene:setPositionX(SCREEN_X_OFFSET)
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)

    self._rootLayer = scene
    self._logoList = 
    {
    	{"asset/bg/logo1.jpg", 250, 800, 250, cc.c3b(0, 0, 0)},
    	{"asset/bg/logo2.jpg", 250, 800, 250, cc.c3b(0, 0, 0)},
    	{"asset/bg/logo3.jpg", 250, 800, 250, cc.c3b(0, 0, 0)}, 
        {"asset/bg/logo4.jpg", 250, 800, 250, cc.c3b(0, 0, 0)}, 
	}
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
		for i = 1, #self._logoList do
			self._logoList[i][2] = self._logoList[i][2] * 0.01
			self._logoList[i][3] = self._logoList[i][3] * 0.01
			self._logoList[i][4] = self._logoList[i][4] * 0.01
		end
	end
end

function LogoView:show()
    self._bg = ccui.Layout:create()
    self._bg:setBackGroundColorOpacity(255)
    self._bg:setBackGroundColorType(1)
    self._bg:setLocalZOrder(-1)
    self._bg:setBackGroundColor(cc.c3b(255,255,255))
    self._bg:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._rootLayer:addChild(self._bg)
    self._bg:setOpacity(0)

    self._fileTable = require("game.GamePreLoadRes")

    self:_showLogo(1)
end

function LogoView:_showLogo(index)
	if index > #self._logoList then
		self:showOver()
		return
	end
	local logoInfo = self._logoList[index]

	self._bg:setOpacity(255)
	self._bg:setBackGroundColor(logoInfo[5])

	if self._logo then
		self._logo:removeFromParent()
		self._logo = nil
	end

	self._logo = cc.Sprite:create(logoInfo[1])
    if self._logo == nil then return end
    -- local xscale = MAX_SCREEN_WIDTH / self._logo:getContentSize().width
    -- local yscale = MAX_SCREEN_HEIGHT / self._logo:getContentSize().height
    -- if xscale > yscale then
    --     self._logo:setScale(xscale)
    -- else
    --     self._logo:setScale(yscale)
    -- end
    self._logo:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self._rootLayer:addChild(self._logo)
    self._logo:setOpacity(0)
    self._logo:runAction(cc.Sequence:create(cc.FadeIn:create(logoInfo[2] * 0.001), 
    		cc.DelayTime:create(0.05),
    		cc.CallFunc:create(function ()
                local tick = socket.gettime()
                local splitIndex = 14
    			if index == 1 then
                    local tick = socket.gettime()
                    pc.DisplayNodeFactory:getInstance():loadIndices("asset/anim/animxml.index.json")
                    print("animxml.index.json", socket.gettime() - tick)	
    			elseif index == 2 then
                    for i = 1, splitIndex do
                        if fu:isFileExist(self._fileTable[i][2]) then
                            sfc:addSpriteFrames(self._fileTable[i][1], self._fileTable[i][2])
                        end
                    end
    			elseif index == 3 then
                    local tick = socket.gettime()
                    pc.DisplayNodeFactory:getInstance():loadIndices("asset/anim/plist.index.json")
                    print("plist.index.json", socket.gettime() - tick)
    			elseif index == 4 then
                    for i = splitIndex + 1, #self._fileTable do
                        if fu:isFileExist(self._fileTable[i][2]) then
                            sfc:addSpriteFrames(self._fileTable[i][1], self._fileTable[i][2])
                        end
                    end
                end
                local delay = logoInfo[3] * 0.001 - (socket.gettime() - tick)
                if delay < 0 then
                    delay = 0.05
                end
                self._logo:stopAllActions()
                self._logo:runAction(cc.Sequence:create(         
                    cc.DelayTime:create(delay), cc.FadeOut:create(logoInfo[4] * 0.001), 
                    cc.DelayTime:create(0.05),
                    cc.CallFunc:create(function ()
                        self:_showLogo(index + 1)
                    end)))
    		end)))

end

function LogoView:showOver()
	-- 释放logo图
    self._logo:removeFromParent()
    self._bg:removeFromParent()
	for i = 1, #self._logoList do
		tc:removeTextureForKey(self._logoList[i][1])
	end

    ApiUtils.playcrab_device_monitor_action("logo")
	require("base.boot.UpdateView").new(self._rootLayer):show()
	self._rootLayer = nil
end

function LogoView.dtor()
    LogoView = nil
    MAX_SCREEN_HEIGHT = nil
    MAX_SCREEN_WIDTH = nil
    sfc = nil
    tc = nil
    fu = nil
end


return LogoView