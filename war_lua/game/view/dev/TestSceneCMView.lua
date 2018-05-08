--[[
    Filename:    TestSceneCMView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-15 21:01:24
    Description: File description
--]]

local TestSceneCMView = class("TestSceneCMView", BaseView)

function TestSceneCMView:ctor()
    TestSceneCMView.super.ctor(self)

end


function TestSceneCMView:onInit()
    local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn, 999999)

    self._bgIndex = 1
    local bg = cc.Sprite:create("asset/uiother/map/_0000_pve_daditu1.jpg")
    bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bg:setScale(0.7)
    self:addChild(bg, -1)
    self._bg = bg

    local codeLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 16)
    codeLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    codeLabel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 150)
    self:addChild(codeLabel)
    self._codeLabel = codeLabel

    self:imageLoadDone()

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(180, MAX_SCREEN_HEIGHT - 50)
    btn1:setTitleText("<-切换场景")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        self._bgIndex = self._bgIndex - 1
        if self._bgIndex < 1 then
            self._bgIndex = 15
        end
        self:changeBg(self._bgIndex)
    end)
    self:addChild(btn1, 999999)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 180, MAX_SCREEN_HEIGHT - 50)
    btn1:setTitleText("切换场景->")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        self._bgIndex = self._bgIndex + 1
        if self._bgIndex > 15 then
            self._bgIndex = 1
        end
        self:changeBg(self._bgIndex)
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

function TestSceneCMView:changeBg(index)
    self._bg:setTexture("asset/uiother/map/_0000_pve_daditu"..index..".jpg")
end

function TestSceneCMView:imageLoadDone()
    self._sliderDatas = 
    {
        {0, 0.05, 1, ""},
        {0, 0.05, 1, ""},
        {0, 0.05, 1, ""},
        {0, 0.05, 1, ""},
        {-50, 5.1, 0, ""},
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

function TestSceneCMView:initSlider()
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

function TestSceneCMView:onValueChange()
    self._bg:setCM(self._v1, self._v2, self._v3, self._v4, self._v5, self._v6, self._v7, self._v8)
    self._bg:setColor(cc.c3b(self._v9, self._v10, self._v11))
    self._bg:setOpacity(self._v12)
    self._codeLabel:setString("sprite:setCM("..self._v1..", "..self._v2..", "..self._v3..", "..self._v4..", "..self._v5..", "..self._v6..", "..self._v7..", "..self._v8..")"
        .."\nsprite:setColor(cc.c3b("..self._v9..", "..self._v10..", "..self._v11.."))"
        .."\nsprite:setOpacity("..self._v12..")")
end

return TestSceneCMView