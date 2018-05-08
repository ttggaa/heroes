--[[
    Filename:    TestSpriteColorMatrixView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-15 21:01:24
    Description: File description
--]]

local TestSpriteColorMatrixView = class("TestSpriteColorMatrixView", BaseView)

function TestSpriteColorMatrixView:ctor()
    TestSpriteColorMatrixView.super.ctor(self)

end


function TestSpriteColorMatrixView:onInit()
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
    codeLabel:setPosition(MAX_SCREEN_WIDTH * 0.5 - 250, MAX_SCREEN_HEIGHT - 100)
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

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 100, 50)
    btn1:setTitleText("重置")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        local values = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 255, 255, 255, 255}
        for i = 1, #self._slider do
            local data = self._sliderDatas[i]
            self["_v"..i] = values[i]
            self._slider[i]:setPercent(self["_v"..i] / data[2] - data[1])
            self._slider[i].label:setString(self["_v"..i])
        end
        self:onValueChange()
    end)
    self:addChild(btn1, 999999)

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 100, 110)
    btn1:setTitleText("灰白")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        -- 0  4  8 12
        -- 1  5  9 13
        -- 2  6 10 14
        -- 3  7 11 15
        local values = {0.3086, 0.6094, 0.0820, 0, 
                        0.3086, 0.6094, 0.0820, 0, 
                        0.3086, 0.6094, 0.0820, 0,
                        0, 0, 0, 1,

                        0, 0, 0, 0, 
                        255, 255, 255, 255}
        for i = 1, #self._slider do
            local data = self._sliderDatas[i]
            self["_v"..i] = values[i]
            self._slider[i]:setPercent(self["_v"..i] / data[2] - data[1])
            self._slider[i].label:setString(self["_v"..i])
        end
        self:onValueChange()
    end)
    self:addChild(btn1, 999999)

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 100, 170)
    btn1:setTitleText("老照片")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        -- 0  4  8 12
        -- 1  5  9 13
        -- 2  6 10 14
        -- 3  7 11 15
        local values = {0.393, 0.769, 0.189, 0, 
                        0.349, 0.686, 0.168, 0, 
                        0.272, 0.534, 0.131, 0,
                        0, 0, 0, 1,

                        0, 0, 0, 0, 
                        255, 255, 255, 255}
        for i = 1, #self._slider do
            local data = self._sliderDatas[i]
            self["_v"..i] = values[i]
            self._slider[i]:setPercent(self["_v"..i] / data[2] - data[1])
            self._slider[i].label:setString(self["_v"..i])
        end
        self:onValueChange()
    end)
    self:addChild(btn1, 999999)
    
    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(MAX_SCREEN_WIDTH - 100, 230)
    btn1:setTitleText("反色")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        -- 0  4  8 12
        -- 1  5  9 13
        -- 2  6 10 14
        -- 3  7 11 15
        local values = {-1, 0, 0, 0, 
                        0, -1, 0, 0, 
                        0, 0, -1, 0,
                        0, 0, 0, 1,

                        255, 255, 255, 0, 
                        255, 255, 255, 255}
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

function TestSpriteColorMatrixView:imageLoadDone()
    self._sliderDatas = 
    {
        {-50, 0.04, 1, "11"},
        {-50, 0.04, 0, "12"},
        {-50, 0.04, 0, "13"},
        {-50, 0.04, 0, "14"},
        {-50, 0.04, 0, "21"},
        {-50, 0.04, 1, "22"},
        {-50, 0.04, 0, "23"},
        {-50, 0.04, 0, "24"},
        {-50, 0.04, 0, "31"},
        {-50, 0.04, 0, "32"},
        {-50, 0.04, 1, "33"},
        {-50, 0.04, 0, "34"},
        {-50, 0.04, 0, "41"},
        {-50, 0.04, 0, "42"},
        {-50, 0.04, 0, "43"},
        {-50, 0.04, 1, "44"},
        {-50, 5.1, 0, "or"},
        {-50, 5.1, 0, "og"},
        {-50, 5.1, 0, "ob"},
        {-50, 5.1, 0, "oa"},
        {0, 2.55, 255, "r"},
        {0, 2.55, 255, "g"},
        {0, 2.55, 255, "b"},
        {0, 2.55, 255, "a"},
    }
    self:initSlider()
end

function TestSpriteColorMatrixView:initSlider()
    local x, y = 50, 140
    local inx = 38

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
        label:setPosition(x - 40, y + 130)
        self:addChild(label)
    end
    self:onValueChange()
end

function TestSpriteColorMatrixView:onValueChange()
    self._image1:setCMex(self._v1, self._v2, self._v3, self._v4, self._v5, self._v6, self._v7, self._v8,
                        self._v9, self._v10, self._v11, self._v12, self._v13, self._v14, self._v15, self._v16,
                        self._v17, self._v18, self._v19, self._v20)
    self._image2:setCMex(self._v1, self._v2, self._v3, self._v4, self._v5, self._v6, self._v7, self._v8,
                        self._v9, self._v10, self._v11, self._v12, self._v13, self._v14, self._v15, self._v16,
                        self._v17, self._v18, self._v19, self._v20)


    self._image1:setColor(cc.c3b(self._v21, self._v22, self._v23))
    self._image2:setColor(cc.c3b(self._v21, self._v22, self._v23))
    self._image1:setOpacity(self._v24)
    self._image2:setOpacity(self._v24)

    self._codeLabel:setString(
        "sprite:setCMex(\n"..self._v1..", "..self._v2..", "..self._v3..", "..self._v4..",\n"..self._v5..", "..self._v6..", "..self._v7..", "..self._v8..",\n"
        ..self._v9..", "..self._v10..", "..self._v11..", "..self._v12..",\n"
        ..self._v13..", "..self._v14..", "..self._v15..", "..self._v16..",\n"
        ..self._v17..", "..self._v18..", "..self._v19..", "..self._v20..")"
        .."\nsprite:setColor(cc.c3b("..self._v21..", "..self._v22..", "..self._v23.."))"
        .."\nsprite:setOpacity("..self._v24..")")
end

return TestSpriteColorMatrixView