--[[
    Filename:    TestPicHSBCView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-15 21:01:24
    Description: File description
--]]

local TestPicHSBCView = class("TestPicHSBCView", BaseView)

function TestPicHSBCView:ctor()
    TestPicHSBCView.super.ctor(self)

end


function TestPicHSBCView:onInit()
    local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn, 999999)

    self._bgIndex = 1
    local bg = cc.Sprite:create("test/test.png")
    bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bg:setScale(0.7)
    self:addChild(bg, -1)
    self._bg = bg

    local codeLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 16)
    codeLabel:setPosition(MAX_SCREEN_WIDTH * 0.5 - 150, MAX_SCREEN_HEIGHT - 150)
    codeLabel:setAnchorPoint(0, 0.5)
    codeLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:addChild(codeLabel)
    self._codeLabel = codeLabel


    self:imageLoadDone()
    
    local btn1 = ccui.Button:create("globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 180, MAX_SCREEN_HEIGHT - 50)
    btn1:setTitleText("更新图片")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        cc.Director:getInstance():getTextureCache():removeTextureForKey("test/test.png")
        self._bg:setTexture("test/test.png")
    end)
    self:addChild(btn1, 999999)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(180, MAX_SCREEN_HEIGHT - 120)
    btn1:setTitleText("缩小")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        local scale = self._bg:getScale()
        scale = scale - 0.1
        if scale < 0.1 then
            scale = 0.1
        end
        self._bg:setScale(scale)
    end)
    self:addChild(btn1, 999999)

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 180, MAX_SCREEN_HEIGHT - 120)
    btn1:setTitleText("放大")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        local scale = self._bg:getScale()
        scale = scale + 0.1
        self._bg:setScale(scale)
    end)
    self:addChild(btn1, 999999)

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 100, 50)
    btn1:setTitleText("重置")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        local values = {0, 0, 0, 0, 255, 255, 255, 255}
        for i = 1, #self._slider do
            local data = self._sliderDatas[i]
            self["_v"..i] = values[i]
            self._slider[i]:setPercent(self["_v"..i] / data[2] - data[1])
            self._slider[i].label:setString(self["_v"..i])
        end
        self:onValueChange()
    end)
    self:addChild(btn1, 999999)
    
end

function TestPicHSBCView:imageLoadDone()
    self._sliderDatas = 
    {
        {-50, 3.6, 0, "色相"},
        {-50, 2, 0, "饱和度"},
        {-50, 2, 0, "亮度"},
        {-50, 2, 0, "对比度"},
        {0, 2.55, 255, "红"},
        {0, 2.55, 255, "绿"},
        {0, 2.55, 255, "蓝"},
        {0, 2.55, 255, "透明度"},
    }
    self:initSlider()
end

function TestPicHSBCView:initSlider()
    local x, y = 50, 140
    local inx = 80

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
        label:setPosition(x - 80, y + 130)
        self:addChild(label)
    end
    self:onValueChange()
end

function TestPicHSBCView:onValueChange()
    self._bg:setHue(self._v1)
    self._bg:setSaturation(self._v2)
    self._bg:setBrightness(self._v3)
    self._bg:setContrast(self._v4)

    self._bg:setColor(cc.c3b(self._v5, self._v6, self._v7))
    self._bg:setOpacity(self._v8)

    self._codeLabel:setString(
        "sprite:setHue("..self._v1..")"
        .."\nsprite:setSaturation("..self._v2..")"
        .."\nsprite:setBrightness("..self._v3..")"
        .."\nsprite:setContrast("..self._v4..")"
        .."\nsprite:setColor(cc.c3b("..self._v5..", "..self._v6..", "..self._v7.."))"
        .."\nsprite:setOpacity("..self._v8..")")
end

return TestPicHSBCView