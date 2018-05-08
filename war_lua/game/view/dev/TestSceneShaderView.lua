--[[
    Filename:    TestSceneShaderView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-15 21:01:24
    Description: File description
--]]

local TestSceneShaderView = class("TestSceneShaderView", BaseView)

function TestSceneShaderView:ctor()
    TestSceneShaderView.super.ctor(self)

end


function TestSceneShaderView:onInit()
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
    
    self._shaderIndex = 1

    local btn2 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn2:setPosition(MAX_SCREEN_WIDTH - 100, 50)
    btn2:setTitleText("2")
    btn2:setTitleFontSize(22)
    btn2:setTitleFontName(UIUtils.ttfName)
    btn2:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn2, function ()
        self._shaderIndex = self._shaderIndex + 1
        if self._shaderIndex > #Shader.shaderTab then
            self._shaderIndex = 1
        end
        btn2:setTitleText(Shader.shaderTab[self._shaderIndex])
        self:shader(self._shaderIndex)
    end)
    btn2:setTitleText(Shader.shaderTab[self._shaderIndex])
    self:addChild(btn2, 999999)

    local btn2 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn2:setPosition(MAX_SCREEN_WIDTH - 100, 120)
    btn2:setTitleText("刷新")
    btn2:setTitleFontSize(22)
    btn2:setTitleFontName(UIUtils.ttfName)
    btn2:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn2, function ()
        self:shader(self._shaderIndex)
    end)
    self:addChild(btn2, 999999)

    self:shader(1)
end

function TestSceneShaderView:changeBg(index)
    self._bg:setTexture("asset/uiother/map/_0000_pve_daditu"..index..".jpg")
end

function TestSceneShaderView:shader(index)
    package.loaded["utils.shader.shader_"..index] = nil
    local shader = require ("utils.shader.shader_"..index)

    self._bg:setGLProgramState(shader)
    self._bg:setUseCustomShader(true)
end

return TestSceneShaderView