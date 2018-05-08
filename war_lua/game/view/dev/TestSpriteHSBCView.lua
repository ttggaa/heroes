--[[
    Filename:    TestSpriteHSBCView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-15 21:01:24
    Description: File description
--]]

local TestSpriteHSBCView = class("TestSpriteHSBCView", BaseView)

function TestSpriteHSBCView:ctor()
    TestSpriteHSBCView.super.ctor(self)

end


function TestSpriteHSBCView:onInit()
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
    codeLabel:setPosition(MAX_SCREEN_WIDTH * 0.5 - 150, MAX_SCREEN_HEIGHT - 150)
    codeLabel:setAnchorPoint(0, 0.5)
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

function TestSpriteHSBCView:imageLoadDone()
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

function TestSpriteHSBCView:initSlider()
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

function TestSpriteHSBCView:onValueChange()
    self._image1:setHue(self._v1)
    self._image1:setSaturation(self._v2)
    self._image1:setBrightness(self._v3)
    self._image1:setContrast(self._v4)


    self._image2:setHue(self._v1)
    self._image2:setSaturation(self._v2)
    self._image2:setBrightness(self._v3)
    self._image2:setContrast(self._v4)

    self._image1:setColor(cc.c3b(self._v5, self._v6, self._v7))
    self._image2:setColor(cc.c3b(self._v5, self._v6, self._v7))
    self._image1:setOpacity(self._v8)
    self._image2:setOpacity(self._v8)

    self._codeLabel:setString(
        "sprite:setHue("..self._v1..")"
        .."\nsprite:setSaturation("..self._v2..")"
        .."\nsprite:setBrightness("..self._v3..")"
        .."\nsprite:setContrast("..self._v4..")"
        .."\nsprite:setColor(cc.c3b("..self._v5..", "..self._v6..", "..self._v7.."))"
        .."\nsprite:setOpacity("..self._v8..")")
end

return TestSpriteHSBCView