--[[
    Filename:    TestSpriteCMView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-15 21:01:24
    Description: File description
--]]

local TestSpriteCMView = class("TestSpriteCMView", BaseView)

function TestSpriteCMView:ctor()
    TestSpriteCMView.super.ctor(self)

end


function TestSpriteCMView:onInit()
    local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn, 999999)

    local bg = cc.Sprite:create("asset/map/yaosai1/yaosai1_land.jpg")
    bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bg:setScale(1.3)
    self:addChild(bg, -1)

    local codeLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 16)
    codeLabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 150)
    self:addChild(codeLabel)
    self._codeLabel = codeLabel

    self._image2 = mcMgr:createMovieClip("atk_duyanjuren")
    self._image2:setPosition(MAX_SCREEN_WIDTH * 0.5 + 260, MAX_SCREEN_HEIGHT * 0.5)
    self._image2:setScale(-0.7, 0.7)
    self:addChild(self._image2)
    self._image2:setCascadeColorEnabled(true, true)
    self._image2:setCascadeOpacityEnabled(true, true)
    
    SpriteFrameAnim.new(self, "qishi", function (_sp)
        _sp:setPosition(MAX_SCREEN_WIDTH * 0.5 - 260, MAX_SCREEN_HEIGHT * 0.5)
        _sp:changeMotion(2)
        _sp:play()
        self._image1 = _sp
        self:imageLoadDone()
    end)

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 100, 130)
    btn1:setTitleText("纯色")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        local values = {0, 0, 0, 1, 255, 0, 0, 0, 255, 255, 255, 255}
        for i = 1, #self._slider do
            local data = self._sliderDatas[i]
            self["_v"..i] = values[i]
            self._slider[i]:setPercent(self["_v"..i] / data[2] - data[1])
            self._slider[i].label:setString(self["_v"..i])
        end
        self:onValueChange()
    end)
    self:addChild(btn1, 999999)

    local btn2 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn2:setPosition(MAX_SCREEN_WIDTH - 100, 50)
    btn2:setTitleText("正常")
    btn2:setTitleFontSize(22)
    btn2:setTitleFontName(UIUtils.ttfName)
    btn2:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn2, function ()
        local values = {1, 1, 1, 1, 0, 0, 0, 0, 255, 255, 255, 255}
        for i = 1, #self._slider do
            local data = self._sliderDatas[i]
            self["_v"..i] = values[i]
            self._slider[i]:setPercent(self["_v"..i] / data[2] - data[1])
            self._slider[i].label:setString(self["_v"..i])
        end
        self:onValueChange()
    end)
    self:addChild(btn2, 999999)
    
end

function TestSpriteCMView:imageLoadDone()
    self._sliderDatas = 
    {
        {0, 0.05, 0, ""},
        {0, 0.05, 0, ""},
        {0, 0.05, 0, ""},
        {0, 0.05, 1, ""},
        {-50, 5.1, 255, ""},
        {-50, 5.1, 0, ""},
        {-50, 5.1, 0, ""},
        {-50, 5.1, 0, ""},
        {0, 2.55, 255, "红"},
        {0, 2.55, 255, "绿"},
        {0, 2.55, 255, "蓝"},
        {0, 2.55, 255, "透明度"},
    }
    self:initSlider()
end

function TestSpriteCMView:initSlider()
    local x, y = 50, 140
    local inx = 60

    self._slider = {}
    for i = 1, #self._sliderDatas do
        local data = self._sliderDatas[i]
        local slider = ccui.Slider:create()   
        slider:loadBarTexture("allianceScicene_expBar.png", 1)
        slider:loadSlidBallTextures("globalPanelUI5_tipBg2.png", "globalPanelUI5_tipBg2.png", "globalPanelUI5_tipBg2.png", 1)
        slider:setRotation(270)
        slider:setPosition(x, y)  
        slider:addEventListener(function(sender, eventType)
            -- 0 - 100
            local value = slider:getPercent()
            self["_v"..i] = (value + data[1]) * data[2]
            self:onValueChange()
            slider.label:setString(self["_v"..i])
        end)
        slider.label = cc.Label:createWithTTF(1, UIUtils.ttfName, 16)
        slider.label:setPosition(-20, 8)
        slider.label:setAnchorPoint(0.5, 0.5)
        slider.label:setRotation(90)
        slider.label:enableOutline(cc.c4b(0,0,0,255), 1)
        slider:addChild(slider.label)
        self:addChild(slider)
        x = x + inx
        self._slider[i] = slider

        self["_v"..i] = data[3]
        slider:setPercent(self["_v"..i] / data[2] - data[1])
        slider.label:setString(self["_v"..i])

        local label = cc.Label:createWithTTF(data[4], UIUtils.ttfName, 20)
        label:setPosition(x - 60, y + 130)
        self:addChild(label)
    end
    self:onValueChange()
end

function TestSpriteCMView:onValueChange()
    self._image1:setCM(self._v1, self._v2, self._v3, self._v4, self._v5, self._v6, self._v7, self._v8)
    self._image2:setCM(self._v1, self._v2, self._v3, self._v4, self._v5, self._v6, self._v7, self._v8)
    self._image1:setColor(cc.c3b(self._v9, self._v10, self._v11))
    self._image2:setColor(cc.c3b(self._v9, self._v10, self._v11))
    self._image1:setOpacity(self._v12)
    self._image2:setOpacity(self._v12)
    self._codeLabel:setString("sprite:setCM("..self._v1..", "..self._v2..", "..self._v3..", "..self._v4..", "..self._v5..", "..self._v6..", "..self._v7..", "..self._v8..")"
        .."\nsprite:setColor(cc.c3b("..self._v9..", "..self._v10..", "..self._v11.."))"
        .."\nsprite:setOpacity("..self._v12..")")
end

return TestSpriteCMView