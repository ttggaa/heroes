--[[
    Filename:    TestRoleMovieClip.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-05-16 14:58:36
    Description: File description
--]]

local TestRoleMovieClip = class("TestRoleMovieClip", BaseView)
local AnimAP = require "base.anim.AnimAP"
package.loaded["base.anim.AnimAP"] = nil

function TestRoleMovieClip:ctor()
    TestRoleMovieClip.super.ctor(self)

    self._roleList = {}
    local data
    for k, v in pairs(AnimAP.mcList) do
    	data = clone(v)
    	data.name = k
    	self._roleList[#self._roleList + 1] = data
    end
    table.sort(self._roleList, function (a, b)
    	return a.name < b.name
    end)
    self._motionIndex = 1
    self._roleIndex = 1
    self._ex = ""
end

function TestRoleMovieClip:onDestroy()
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:removeEventListenersForTarget(self._roleNode, true)

	TestRoleMovieClip.super.onDestroy(self)
end

local motionName = {"stop", "run", "atk", "die", "atk2", "atk3", "atk4", "born", "win", "standby", "walk", "stop", "skill", "stop2", "atk5", "atk6", "born1", "atk1"}
function TestRoleMovieClip:onInit()
    local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn)

    local x, y = MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 150

    self._roleNode = cc.Node:create()
    self._roleNode:setPosition(x, y)
    self._roleNode:setScale(1)
    self:addChild(self._roleNode)

    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function (event)
        self:onMouseScroll(event)
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._roleNode)

    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:registerScriptHandler(function(touch, event)
        local location = touch:getLocation()
        local __x = (location.x - x) / self._roleNode:getScale()
        local __y = (location.y - y) / self._roleNode:getScale()
        self._posLabel:setString(math.floor(__x) .. " " .. math.floor(__y))
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    touchListener:registerScriptHandler(function(touch, event)
        local location = touch:getLocation()
        local __x = (location.x - x) / self._roleNode:getScale()
        local __y = (location.y - y) / self._roleNode:getScale()
        self._posLabel:setString(math.floor(__x) .. " " .. math.floor(__y))
    end, cc.Handler.EVENT_TOUCH_MOVED)
    dispatcher:addEventListenerWithSceneGraphPriority(touchListener, self._roleNode)

    self._posLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 40)
    self._posLabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 50)
    self._posLabel:setAnchorPoint(0.5, 0.5)
    self._posLabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._posLabel)

    self._scalelabel = cc.Label:createWithTTF("x1.0", UIUtils.ttfName, 40)
    self._scalelabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 100)
    self._scalelabel:setAnchorPoint(0.5, 0.5)
    self._scalelabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._scalelabel)

    self._motionlabel = cc.Label:createWithTTF("stop", UIUtils.ttfName, 26)
    self._motionlabel:setPosition(MAX_SCREEN_WIDTH * 0.5, 150)
    self._motionlabel:setAnchorPoint(0.5, 0.5)
    self._motionlabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._motionlabel)

    self._motionlabel1 = cc.Label:createWithTTF("born", UIUtils.ttfName, 18)
    self._motionlabel1:setPosition(MAX_SCREEN_WIDTH * 0.5 - 100, 150)
    self._motionlabel1:setAnchorPoint(0.5, 0.5)
    self._motionlabel1:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._motionlabel1)

    self._motionlabel2 = cc.Label:createWithTTF("run", UIUtils.ttfName, 18)
    self._motionlabel2:setPosition(MAX_SCREEN_WIDTH * 0.5 + 100, 150)
    self._motionlabel2:setAnchorPoint(0.5, 0.5)
    self._motionlabel2:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._motionlabel2)

    self._rolelabel = cc.Label:createWithTTF(self._roleList[1].name, UIUtils.ttfName, 34)
    self._rolelabel:setPosition(MAX_SCREEN_WIDTH * 0.5, 90)
    self._rolelabel:setAnchorPoint(0.5, 0.5)
    self._rolelabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel)

    self._rolelabel1 = cc.Label:createWithTTF(self._roleList[1].name, UIUtils.ttfName, 18)
    self._rolelabel1:setPosition(MAX_SCREEN_WIDTH * 0.5 - 300, 20)
    self._rolelabel1:setAnchorPoint(0.5, 0.5)
    self._rolelabel1:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel1)

    self._rolelabel2 = cc.Label:createWithTTF(self._roleList[1].name, UIUtils.ttfName, 18)
    self._rolelabel2:setPosition(MAX_SCREEN_WIDTH * 0.5 + 300, 20)
    self._rolelabel2:setAnchorPoint(0.5, 0.5)
    self._rolelabel2:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel2)

    self._rolelabel3 = cc.Label:createWithTTF(self._roleList[1].name, UIUtils.ttfName, 24)
    self._rolelabel3:setPosition(MAX_SCREEN_WIDTH * 0.5 - 150, 50)
    self._rolelabel3:setAnchorPoint(0.5, 0.5)
    self._rolelabel3:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel3)

    self._rolelabel4 = cc.Label:createWithTTF(self._roleList[1].name, UIUtils.ttfName, 24)
    self._rolelabel4:setPosition(MAX_SCREEN_WIDTH * 0.5 + 150, 50)
    self._rolelabel4:setAnchorPoint(0.5, 0.5)
    self._rolelabel4:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel4)

    self._countLabel = cc.Label:createWithTTF("1/1", UIUtils.ttfName, 30)
    self._countLabel:setPosition(MAX_SCREEN_WIDTH -10, 5)
    self._countLabel:setAnchorPoint(1, 0)
    self._countLabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._countLabel)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(160, 300)
    btn1:setTitleText("<-动作")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self._motionIndex = self._motionIndex - 1
    	if self._motionIndex < 1 then
    		self._motionIndex = #motionName
    	end
        self:onUpdate()
        
    end)
    self:addChild(btn1)
    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 160, 300)
    btn1:setTitleText("动作->")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self._motionIndex = self._motionIndex + 1
    	if self._motionIndex > #motionName then
    		self._motionIndex = 1
    	end
        self:onUpdate()
    end)
    self:addChild(btn1)

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(160, 100)
    btn1:setTitleText("<-模型")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self._roleIndex = self._roleIndex - 1
    	if self._roleIndex < 1 then
    		self._roleIndex = #self._roleList
    	end
        self:onUpdate()
        
    end)
    self:addChild(btn1)
    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 160, 100)
    btn1:setTitleText("模型->")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self._roleIndex = self._roleIndex + 1
    	if self._roleIndex > #self._roleList then
    		self._roleIndex = 1
    	end
        self:onUpdate()
    end)
    self:addChild(btn1)
    local btn1 = ccui.Button:create("globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", 1)
    btn1:setPosition(160, 500)
    btn1:setTitleText("更新AnimAP")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self:updateAnimAP()
        self:onUpdate()
    end)
    self:addChild(btn1)

    local btn1 = ccui.Button:create("globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 160, 500)
    btn1:setTitleText("切换红蓝")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	if self._ex == "" then
            self._ex = "r"
        else
            self._ex = ""
        end
        self:onUpdate()
    end)
    self:addChild(btn1)

    self._sizeLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 30)
    self._sizeLabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 35)
    self._sizeLabel:setAnchorPoint(0.5, 0)
    self._sizeLabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._sizeLabel)
    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(160, MAX_SCREEN_HEIGHT - 60)
    btn1:setTitleText("显示原图")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        self._showImage = not self._showImage
        if self._showImage then
            btn1:setTitleText("隐藏原图")
        else
            btn1:setTitleText("显示原图")
        end
        self:onUpdate()
    end)
    self:addChild(btn1)

    self:onUpdate()
end

function TestRoleMovieClip:onMouseScroll(event)
	local scale = math.floor(self._roleNode:getScale() * 10)
	-- print(scale, event:getScrollY())
	scale = scale + event:getScrollY() * 2
	if scale < 5 then scale = 5 end
	if scale > 50 then scale = 50 end
	self._scalelabel:setString("x"..scale*0.1)
	self._roleNode:setScale(scale*0.1)
end

function TestRoleMovieClip:onUpdate()
	self._roleNode:removeAllChildren()
	-- print(self._motionIndex)
	self._motionlabel:setString(motionName[self._motionIndex])
	self._motionlabel1:setString(motionName[(self._motionIndex - 1) < 1 and #motionName or self._motionIndex - 1])
	self._motionlabel2:setString(motionName[(self._motionIndex + 1) > #motionName and 1 or self._motionIndex + 1])
	self._rolelabel:setString(self._roleList[self._roleIndex].name)
	self._rolelabel1:setString(self._roleList[(self._roleIndex - 2) < 1 and self._roleIndex - 2 + #self._roleList or self._roleIndex - 2].name)
	self._rolelabel2:setString(self._roleList[(self._roleIndex + 2) > #self._roleList and self._roleIndex + 2 - #self._roleList or self._roleIndex + 2].name)
	self._rolelabel3:setString(self._roleList[(self._roleIndex - 1) < 1 and self._roleIndex - 1 + #self._roleList or self._roleIndex - 1].name)
	self._rolelabel4:setString(self._roleList[(self._roleIndex + 1) > #self._roleList and self._roleIndex + 1 - #self._roleList or self._roleIndex + 1].name)
	local data = self._roleList[self._roleIndex]

    self._countLabel:setString(self._roleIndex .. "/" .. #self._roleList)

    local sp = mcMgr:createMovieClip(motionName[self._motionIndex]..self._ex.."_"..data.name)
    self._roleNode:addChild(sp)
    sp:play()

    local sp1 = cc.Sprite:create("asset/other/circle.png")
    sp1:setColor(cc.c3b(0, 255, 0))
    sp1:setOpacity(150)
    sp1:setScale(0.2)
    sp1:setPosition(data[1][1]*0.5, data[1][2]*0.5)
    self._roleNode:addChild(sp1)
    local sp2 = cc.Sprite:create("asset/other/circle.png")
    sp2:setColor(cc.c3b(255, 0, 255))
    sp2:setOpacity(150)
    sp2:setScale(0.2)
    sp2:setPosition(data[2][1]*0.5, data[2][2]*0.5)
    self._roleNode:addChild(sp2)
    local sp3 = cc.Sprite:create("asset/other/circle.png")
    sp3:setColor(cc.c3b(0, 255, 255))
    sp3:setPosition(data[3][1]*0.5, data[3][2]*0.5)
    sp3:setOpacity(150)
    sp3:setScale(0.2)
    self._roleNode:addChild(sp3)
    local sp4 = cc.Sprite:create("asset/other/circle.png")
    sp4:setColor(cc.c3b(255, 255, 0))
    sp4:setOpacity(150)
    sp4:setScale(0.2)
    self._roleNode:addChild(sp4)
    local rect = cc.Sprite:create("asset/other/cell2.png")
    rect:setColor(cc.c3b(0, 255, 255))
    rect:setAnchorPoint(0.5, 0)
    rect:setOpacity(128)
    rect:setScale(data[0][1] / 80 / (data.scale / 0.5), data[0][2] / 80 / (data.scale / 0.5))
    self._roleNode:addChild(rect)

    sp1:setVisible(not self._showImage)
    sp2:setVisible(not self._showImage)
    sp3:setVisible(not self._showImage)
    sp:setVisible(not self._showImage)
    rect:setVisible(not self._showImage)

    local image = cc.Sprite:create("asset/anim/"..data.name.."image.png")
    image:setPosition(0, 70)
    image:setScale(0.5)
    self._roleNode:addChild(image, 999999)

    local rect = cc.Sprite:create("asset/other/cell2.png")
    rect:setColor(cc.c3b(0, 255, 255))
    rect:setAnchorPoint(0, 0)
    rect:setOpacity(128)
    rect:setScale(image:getContentSize().width / 78, image:getContentSize().height / 78)
    image:addChild(rect)

    self._sizeLabel:setString(image:getContentSize().width .. "x" .. image:getContentSize().height)
    image:setVisible(self._showImage)
end

function TestRoleMovieClip:updateAnimAP()
	AnimAP = require "base.anim.AnimAP"
	package.loaded["base.anim.AnimAP"] = nil
	self._roleList = {}
    local data
    for k, v in pairs(AnimAP.mcList) do
    	data = clone(v)
    	data.name = k
    	self._roleList[#self._roleList + 1] = data
    end
    table.sort(self._roleList, function (a, b)
    	return a.name < b.name
    end)
end

return TestRoleMovieClip
