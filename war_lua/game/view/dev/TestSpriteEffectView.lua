--[[
    Filename:    TestSpriteEffectView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-03-15 21:01:24
    Description: File description
--]]

local TestSpriteEffectView = class("TestSpriteEffectView", BaseView)

function TestSpriteEffectView:ctor()
    TestSpriteEffectView.super.ctor(self)

end


function TestSpriteEffectView:onInit()
    local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn)

    local bg = cc.Sprite:create("asset/map/yaosai1/yaosai1_land.jpg")
    bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bg:setScale(1.3)
    self:addChild(bg, -1)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(160, 500)
    btn1:setTitleText("人物纯色")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        package.loaded["game.view.dev.TestSpriteCMView"] = nil
        self._viewMgr:showView("dev.TestSpriteCMView")
    end)
    self:addChild(btn1)

    local btn2 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn2:setPosition(320, 500)
    btn2:setTitleText("人物色相")
    btn2:setTitleFontSize(22)
    btn2:setTitleFontName(UIUtils.ttfName)
    btn2:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn2, function ()
        package.loaded["game.view.dev.TestSpriteHSBCView"] = nil
        self._viewMgr:showView("dev.TestSpriteHSBCView")
    end)
    self:addChild(btn2)
    
    local btn3 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn3:setPosition(480, 500)
    btn3:setTitleText("人物ＣＭ")
    btn3:setTitleFontSize(22)
    btn3:setTitleFontName(UIUtils.ttfName)
    btn3:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn3, function ()
        package.loaded["game.view.dev.TestSpriteColorMatrixView"] = nil
        self._viewMgr:showView("dev.TestSpriteColorMatrixView")
    end)
    self:addChild(btn3)

    local btn4 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn4:setPosition(640, 500)
    btn4:setTitleText("人物Shader")
    btn4:setTitleFontSize(22)
    btn4:setTitleFontName(UIUtils.ttfName)
    btn4:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn4, function ()
        package.loaded["game.view.dev.TestSpriteShaderView"] = nil
        self._viewMgr:showView("dev.TestSpriteShaderView")
    end)
    self:addChild(btn4)

    local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn1:setPosition(160, 420)
    btn1:setTitleText("场景纯色")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        package.loaded["game.view.dev.TestSceneCMView"] = nil
        self._viewMgr:showView("dev.TestSceneCMView")
    end)
    self:addChild(btn1)

    local btn2 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn2:setPosition(320, 420)
    btn2:setTitleText("场景色相")
    btn2:setTitleFontSize(22)
    btn2:setTitleFontName(UIUtils.ttfName)
    btn2:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn2, function ()
        package.loaded["game.view.dev.TestSceneHSBCView"] = nil
        self._viewMgr:showView("dev.TestSceneHSBCView")
    end)
    self:addChild(btn2)
    
    local btn3 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn3:setPosition(480, 420)
    btn3:setTitleText("场景ＣＭ")
    btn3:setTitleFontSize(22)
    btn3:setTitleFontName(UIUtils.ttfName)
    btn3:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn3, function ()
        package.loaded["game.view.dev.TestSceneColorMatrixView"] = nil
        self._viewMgr:showView("dev.TestSceneColorMatrixView")
    end)
    self:addChild(btn3)

    local btn4 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
    btn4:setPosition(640, 420)
    btn4:setTitleText("场景Shader")
    btn4:setTitleFontSize(22)
    btn4:setTitleFontName(UIUtils.ttfName)
    btn4:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn4, function ()
        package.loaded["game.view.dev.TestSceneShaderView"] = nil
        self._viewMgr:showView("dev.TestSceneShaderView")
    end)
    self:addChild(btn4)

    local btn2 = ccui.Button:create("globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", 1)
    btn2:setPosition(320, 340)
    btn2:setTitleText("图片色相")
    btn2:setTitleFontSize(22)
    btn2:setTitleFontName(UIUtils.ttfName)
    btn2:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn2, function ()
        package.loaded["game.view.dev.TestPicHSBCView"] = nil
        self._viewMgr:showView("dev.TestPicHSBCView")
    end)
    self:addChild(btn2)
    
end


return TestSpriteEffectView