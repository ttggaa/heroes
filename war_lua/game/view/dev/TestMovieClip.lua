--[[
    Filename:    TestMovieClip.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-05-16 14:58:36
    Description: File description
--]]

local TestMovieClip = class("TestMovieClip", BaseView)

function TestMovieClip:ctor()
    TestMovieClip.super.ctor(self)

    local f = io.open("asset/anim/animxml.index.json", 'r')
    local str = f:read("*all")
    local list = json.decode(str)

    self._mcList = {}
    local data, arr, name, len
    for k, v in pairs(list.indices) do
        data = {}
    	arr = {}
        name = string.sub(k, 12, string.find(k, "animxml") - 2)
        len = string.len(name)
        for kk, vv in pairs(v.libItems) do
            if not string.find(vv, "wy_") and not string.find(vv, "liyupingli_") then
                arr[#arr + 1] = string.sub(vv, 1, string.len(vv) - len - 1)
            end
        end
        table.sort(arr, function (a, b)
            return a < b
        end)
        data.arr = arr
    	data.name = name
    	self._mcList[#self._mcList + 1] = data
    end
    table.sort(self._mcList, function (a, b)
    	return a.name < b.name
    end)
    self._actionIndex = 1
    self._mcIndex = 1
    self._actionName = self._mcList[1].arr
end

function TestMovieClip:onDestroy()
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:removeEventListenersForTarget(self._roleNode, true)

	TestMovieClip.super.onDestroy(self)
end

function TestMovieClip:onInit()
    self._showImage = false

    local debugColor = ccui.Layout:create()
    debugColor:setBackGroundColorOpacity(255)
    debugColor:setBackGroundColorType(1)
    debugColor:setBackGroundColor(cc.c3b(181,181,181))
    debugColor:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    debugColor:setPosition(0, 0)
    self:addChild(debugColor)

    local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn)

    local debugColor = ccui.Layout:create()
    debugColor:setBackGroundColorOpacity(255)
    debugColor:setBackGroundColorType(1)
    debugColor:setBackGroundColor(cc.c3b(0,255,0))
    debugColor:setContentSize(400, 1)
    debugColor:setPosition(MAX_SCREEN_WIDTH * 0.5 - 200, MAX_SCREEN_HEIGHT * 0.5 - 50)
    self:addChild(debugColor)

    local debugColor = ccui.Layout:create()
    debugColor:setBackGroundColorOpacity(255)
    debugColor:setBackGroundColorType(1)
    debugColor:setBackGroundColor(cc.c3b(0,255,0))
    debugColor:setContentSize(1, 400)
    debugColor:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 50 - 200)
    self:addChild(debugColor)

    self._roleNode = cc.Node:create()
    self._roleNode:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 50)
    self._roleNode:setScale(2)
    self:addChild(self._roleNode)

    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function (event)
        self:onMouseScroll(event)
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._roleNode)

    self._sizeLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 30)
    self._sizeLabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 35)
    self._sizeLabel:setAnchorPoint(0.5, 0)
    self._sizeLabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._sizeLabel)

    self._namelabel = cc.Label:createWithTTF("x2.0", UIUtils.ttfName, 40)
    self._namelabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 50)
    self._namelabel:setAnchorPoint(0.5, 0.5)
    self._namelabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._namelabel)

    self._scalelabel = cc.Label:createWithTTF("x2.0", UIUtils.ttfName, 40)
    self._scalelabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 100)
    self._scalelabel:setAnchorPoint(0.5, 0.5)
    self._scalelabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._scalelabel)

    self._motionlabel = cc.Label:createWithTTF("stop", UIUtils.ttfName, 26)
    self._motionlabel:setPosition(MAX_SCREEN_WIDTH * 0.5, 200)
    self._motionlabel:setAnchorPoint(0.5, 0.5)
    self._motionlabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._motionlabel)

    self._motionlabel1 = cc.Label:createWithTTF("born", UIUtils.ttfName, 18)
    self._motionlabel1:setPosition(MAX_SCREEN_WIDTH * 0.5 - 200, 180)
    self._motionlabel1:setAnchorPoint(0.5, 0.5)
    self._motionlabel1:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._motionlabel1)

    self._motionlabel2 = cc.Label:createWithTTF("run", UIUtils.ttfName, 18)
    self._motionlabel2:setPosition(MAX_SCREEN_WIDTH * 0.5 + 200, 180)
    self._motionlabel2:setAnchorPoint(0.5, 0.5)
    self._motionlabel2:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._motionlabel2)

    self._rolelabel = cc.Label:createWithTTF(self._mcList[1].name, UIUtils.ttfName, 34)
    self._rolelabel:setPosition(MAX_SCREEN_WIDTH * 0.5, 90)
    self._rolelabel:setAnchorPoint(0.5, 0.5)
    self._rolelabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel)

    self._rolelabel1 = cc.Label:createWithTTF(self._mcList[1].name, UIUtils.ttfName, 18)
    self._rolelabel1:setPosition(MAX_SCREEN_WIDTH * 0.5 - 300, 20)
    self._rolelabel1:setAnchorPoint(0.5, 0.5)
    self._rolelabel1:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel1)

    self._rolelabel2 = cc.Label:createWithTTF(self._mcList[1].name, UIUtils.ttfName, 18)
    self._rolelabel2:setPosition(MAX_SCREEN_WIDTH * 0.5 + 300, 20)
    self._rolelabel2:setAnchorPoint(0.5, 0.5)
    self._rolelabel2:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel2)

    self._rolelabel3 = cc.Label:createWithTTF(self._mcList[1].name, UIUtils.ttfName, 24)
    self._rolelabel3:setPosition(MAX_SCREEN_WIDTH * 0.5 - 150, 50)
    self._rolelabel3:setAnchorPoint(0.5, 0.5)
    self._rolelabel3:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel3)

    self._rolelabel4 = cc.Label:createWithTTF(self._mcList[1].name, UIUtils.ttfName, 24)
    self._rolelabel4:setPosition(MAX_SCREEN_WIDTH * 0.5 + 150, 50)
    self._rolelabel4:setAnchorPoint(0.5, 0.5)
    self._rolelabel4:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._rolelabel4)

    self._countLabel = cc.Label:createWithTTF("1/1", UIUtils.ttfName, 30)
    self._countLabel:setPosition(MAX_SCREEN_WIDTH -10, 5)
    self._countLabel:setAnchorPoint(1, 0)
    self._countLabel:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._countLabel)

    self._countLabel2 = cc.Label:createWithTTF("1/1", UIUtils.ttfName, 24)
    self._countLabel2:setPosition(MAX_SCREEN_WIDTH * 0.5, 160)
    self._countLabel2:setAnchorPoint(0.5, 0.5)
    self._countLabel2:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._countLabel2)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(160, 200)
    btn1:setTitleText("<-")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self._actionIndex = self._actionIndex - 1
    	if self._actionIndex < 1 then
    		self._actionIndex = #self._actionName
    	end
        self:onUpdate()
    end)
    self:addChild(btn1)
    self._btn1 = btn1
    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 160, 200)
    btn1:setTitleText("->")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self._actionIndex = self._actionIndex + 1
    	if self._actionIndex > #self._actionName then
    		self._actionIndex = 1
    	end
        self:onUpdate()
    end)
    self:addChild(btn1)
    self._btn2 = btn1
    local btn1 = ccui.Button:create("globalButtonUI13_3_3.png", "globalButtonUI13_3_3.png", "globalButtonUI13_3_3.png", 1)
    btn1:setPosition(100, 100)
    btn1:setTitleText("<|-")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        local now = string.sub(self._mcList[self._mcIndex].name, 1, 1)
        while true do
            self._mcIndex = self._mcIndex - 1
            if self._mcIndex < 1 then
                self._mcIndex = #self._mcList
            end
            if string.sub(self._mcList[self._mcIndex].name, 1, 1) ~= now then
                break
            end
        end
        self._actionIndex = 1
        self:onUpdate()
    end)
    self:addChild(btn1)
    local btn1 = ccui.Button:create("globalButtonUI13_3_3.png", "globalButtonUI13_3_3.png", "globalButtonUI13_3_3.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 100, 100)
    btn1:setTitleText("-|>")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        local now = string.sub(self._mcList[self._mcIndex].name, 1, 1)
        while true do
            self._mcIndex = self._mcIndex + 1
        if self._mcIndex > #self._mcList then
            self._mcIndex = 1
        end
            if string.sub(self._mcList[self._mcIndex].name, 1, 1) ~= now then
                break
            end
        end
        self._actionIndex = 1
        self:onUpdate()
    end)
    self:addChild(btn1)

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(240, 100)
    btn1:setTitleText("<-mc")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self._mcIndex = self._mcIndex - 1
    	if self._mcIndex < 1 then
    		self._mcIndex = #self._mcList
    	end
        self._actionIndex = 1
        self:onUpdate()
    end)
    self:addChild(btn1)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 240, 100)
    btn1:setTitleText("mc->")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
    	self._mcIndex = self._mcIndex + 1
    	if self._mcIndex > #self._mcList then
    		self._mcIndex = 1
    	end
        self._actionIndex = 1
        self:onUpdate()
    end)
    self:addChild(btn1)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(100, MAX_SCREEN_HEIGHT - 50)
    btn1:setTitleText("总览")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        self:showAll()
    end)
    self:addChild(btn1)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(100, MAX_SCREEN_HEIGHT - 120)
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

function TestMovieClip:showAll()
    if self._layer then
        self._layer:setVisible(true)
        return
    end
    local layer = ccui.Layout:create()
    layer:setBackGroundColorOpacity(220)
    layer:setBackGroundColorType(1)
    layer:setBackGroundColor(cc.c3b(0,0,0))
    layer:setTouchEnabled(true)
    layer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    layer:setPosition(0, 0)
    self:addChild(layer)
    self._layer = layer

    local count = #self._mcList

    self._scrollView = cc.ScrollView:create() 
    self._scrollView:setViewSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
    self._scrollView:setPosition(0, 0)
    local lines = math.modf(count / 3) + 1
    self._scrollView:setContentSize(cc.size(MAX_SCREEN_WIDTH, lines * 20))
    
    local x, y = 1, 1
    local now = string.sub(self._mcList[1].name, 1, 1)
    local color = 1
    for i = 1, count do
        local data = self._mcList[i]
        if now ~= string.sub(data.name, 1, 1) then
            now = string.sub(data.name, 1, 1)
            if color == 1 then
                color = 2
            else
                color = 1
            end
        end
        local label = ccui.Text:create()
        label:setString(data.name)
        label:setFontSize(18)
        if color == 1 then
            label:setColor(cc.c3b(128, 255, 128))
        else
            label:setColor(cc.c3b(128, 255, 255))
        end
        label:setAnchorPoint(0.5, 0)
        label:setFontName(UIUtils.ttfName)
        label:setPosition(MAX_SCREEN_WIDTH * 0.5 + (x - 2) * 350, lines * 20 - (y * 20))
        registerClickEvent(label, function ()
            self._mcIndex = i
            self._actionIndex = 1
            self:onUpdate()
            self._layer:setVisible(false)
        end)
        x = x + 1
        if x > 3 then
            x = 1
            y = y + 1
        end
        self._scrollView:addChild(label)
    end
    self._scrollView:setContentOffset(cc.p(0, MAX_SCREEN_HEIGHT - lines * 20))
    self._scrollView:setDirection(1) 
    self._layer:addChild(self._scrollView)

end

function TestMovieClip:onMouseScroll(event)
	local scale = math.floor(self._roleNode:getScale() * 10)
	-- print(scale, event:getScrollY())
	scale = scale + event:getScrollY() * 2
	if scale < 5 then scale = 5 end
	if scale > 50 then scale = 50 end
	self._scalelabel:setString("x"..scale*0.1)
	self._roleNode:setScale(scale*0.1)
end

function TestMovieClip:onUpdate()
	self._roleNode:removeAllChildren()
	local data = self._mcList[self._mcIndex]
    self._actionName = data.arr
    -- dump(data.arr)
    if #self._actionName == 1 then
    	self._motionlabel:setString(self._actionName[self._actionIndex])
    	self._motionlabel1:setString("")
    	self._motionlabel2:setString("")
    elseif #self._actionName == 2 then
        self._motionlabel:setString(self._actionName[self._actionIndex])
        self._motionlabel1:setString("")
        self._motionlabel2:setString(self._actionName[(self._actionIndex + 1) > #self._actionName and 1 or self._actionIndex + 1])
    else
        self._motionlabel:setString(self._actionName[self._actionIndex])
        self._motionlabel1:setString(self._actionName[(self._actionIndex - 1) < 1 and #self._actionName or self._actionIndex - 1])
        self._motionlabel2:setString(self._actionName[(self._actionIndex + 1) > #self._actionName and 1 or self._actionIndex + 1])
    end
    self._btn1:setVisible(#self._actionName > 1)
    self._btn2:setVisible(#self._actionName > 1)
	self._rolelabel:setString(self._mcList[self._mcIndex].name)
	self._rolelabel1:setString(self._mcList[(self._mcIndex - 2) < 1 and self._mcIndex - 2 + #self._mcList or self._mcIndex - 2].name)
	self._rolelabel2:setString(self._mcList[(self._mcIndex + 2) > #self._mcList and self._mcIndex + 2 - #self._mcList or self._mcIndex + 2].name)
	self._rolelabel3:setString(self._mcList[(self._mcIndex - 1) < 1 and self._mcIndex - 1 + #self._mcList or self._mcIndex - 1].name)
	self._rolelabel4:setString(self._mcList[(self._mcIndex + 1) > #self._mcList and self._mcIndex + 1 - #self._mcList or self._mcIndex + 1].name)
	   
    self._countLabel:setString(self._mcIndex .. "/" .. #self._mcList)
    self._countLabel2:setString(self._actionIndex .. "/" .. #self._actionName)

    self._namelabel:setString(self._actionName[self._actionIndex].."_"..data.name)
    local sp = mcMgr:createMovieClip(self._actionName[self._actionIndex].."_"..data.name)
    self._roleNode:addChild(sp)

    local image = cc.Sprite:create("asset/anim/"..data.name.."image.png")
    image:setScale(0.5)
    self._roleNode:addChild(image)

    local rect = cc.Sprite:create("asset/other/cell2.png")
    rect:setColor(cc.c3b(0, 255, 255))
    rect:setAnchorPoint(0, 0)
    rect:setOpacity(128)
    rect:setScale(image:getContentSize().width / 78, image:getContentSize().height / 78)
    image:addChild(rect)

    self._sizeLabel:setString(image:getContentSize().width .. "x" .. image:getContentSize().height)


    image:setVisible(self._showImage)
    sp:setVisible(not self._showImage)

    sp:play()

end

return TestMovieClip
