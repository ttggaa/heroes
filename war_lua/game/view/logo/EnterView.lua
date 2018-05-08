--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-11-04 12:29:51
--
local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
local EnterView = class("EnterView", BaseView)

function EnterView:ctor(data)
    EnterView.super.ctor(self)
    self._callback = data.callback
    self._freeRes = data.freeRes
    sfc:addSpriteFrames("asset/ui/login.plist", "asset/ui/login.png")
    self.noSound = true
end

function EnterView:getBgName()
    return "bg_071.jpg"
end

function EnterView:onInit()
    audioMgr:playMusic("signin", true)
    
	self._logo = cc.Sprite:create("asset/bg/logo.png")
    self._logo:setPosition(self._logo:getContentSize().width * 0.5 * 0.75 - 10, MAX_SCREEN_HEIGHT - self._logo:getContentSize().height * 0.5 * 0.75 + 5)
    self._logo:setScale(0.75)
    self:addChild(self._logo, -1)
	self:initEff()

	self._mask = ccui.Layout:create()
    self._mask:setBackGroundColorOpacity(255)
    self._mask:setBackGroundColorType(1)
    self._mask:setBackGroundColor(cc.c3b(255,0,0))
    self._mask:setContentSize(MAX_SCREEN_WIDTH + 200, MAX_SCREEN_HEIGHT)
    self._mask:setTouchEnabled(true)
    self._mask:setOpacity(0)
    self:addChild(self._mask, 999)   

    self:registerClickEvent(self._mask, function ()
    	local freeRes = self._freeRes
    	if self._callback then
    		self._callback()
    	end
    	if freeRes then
			sfc:removeSpriteFramesFromFile("asset/ui/login.plist")
			tc:removeTextureForKey("asset/ui/login.png")
		end
    end)

	local mask = ccui.Layout:create()
    mask:setBackGroundColorOpacity(255)
    mask:setBackGroundColorType(1)
    mask:setBackGroundColor(cc.c3b(0,0,0))
    mask:setContentSize(MAX_SCREEN_WIDTH, 40)
    mask:setOpacity(140)
    mask:setAnchorPoint(0.5, 0.5)
    mask:setPosition(MAX_SCREEN_WIDTH * 0.5, 170)
    self:addChild(mask, 5555)   

    local label = cc.Label:createWithTTF("点击任意位置开始", UIUtils.ttfName, 24)
    -- label:enableOutline(cc.c4b(0,0,0,255), 1)
    label:setPosition(MAX_SCREEN_WIDTH * 0.5, 170)
    self:addChild(label, 9999)
    label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1.2), cc.FadeIn:create(1.2))))
end

function EnterView:onDestroy()

    EnterView.super.onDestroy(self)
end


function EnterView:initEff()
    local w, h = self._logo:getContentSize().width * 0.5, self._logo:getContentSize().height * 0.5
    local x, y

    x = w - 1
    y = h - 1
    local mc1 = mcMgr:createViewMC("logo3_logo", true, false, function (_, mc)
        mc:stop()
    end)
    mc1:setPosition(0, 20)
    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(x, y)
    local mask = cc.Sprite:createWithSpriteFrameName("login_mask1.png")
    mask:setScale(0.72)
    -- mask:setOpacity(200)
    -- mask:setPosition(x, y)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.5)
    clipNode:addChild(mc1)
    self._logo:addChild(clipNode)

    x = w
    y = h
    local mc2 = mcMgr:createViewMC("logo2_logo", true, false)
    mc2:setPosition(x, y)
    mc2:setScale(0.9)
    self._logo:addChild(mc2)

    x = w - 2
    y = h
    local mc3 = mcMgr:createViewMC("logo1_logo", true, false)
    mc3:setPosition(0, 20)
    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(x + 1, y + 1)
    local mask = cc.Sprite:createWithSpriteFrameName("login_mask3.png")
    mask:setScale(0.98)
    -- mask:setOpacity(200)
    -- mask:setPosition(x, y)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.5)
    clipNode:addChild(mc3)
    -- clipNode:setScale(1.1)
    self._logo:addChild(clipNode)

    self._effUpdateId = ScheduleMgr:regSchedule(5000, self, function(self, dt)
        mc1:gotoAndPlay(1)
    end)
end


return EnterView