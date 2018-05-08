--[[
    Filename:    TestSpriteShaderView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-15 21:01:24
    Description: File description
--]]

local TestSpriteShaderView = class("TestSpriteShaderView", BaseView)

function TestSpriteShaderView:ctor()
    TestSpriteShaderView.super.ctor(self)

end


function TestSpriteShaderView:onInit()
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
    
    SpriteFrameAnim.new(self, "qishi", function (_sp)
        _sp:setPosition(MAX_SCREEN_WIDTH * 0.5 - 260, MAX_SCREEN_HEIGHT * 0.5)
        _sp:changeMotion(2)
        _sp:play()
        self._image1 = _sp
        self:shader(1)
    end)
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
end


function TestSpriteShaderView:shader(index)
    local shader = require ("utils.shader.shader_"..index)
    self._image1:setGLProgramState(shader)
    self._image1:setUseCustomShader(true)
end

return TestSpriteShaderView