--[[
    Filename:    LoginView.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-29 15:21:13
    Description: File description
--]]

local LoginView = class("LoginView", BaseView)

local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
local httpManager = HttpManager:getInstance()

local EFF_DEBUG = false

function AppExit()
    APP_EXIT = true
    local scene = cc.Director:getInstance():getRunningScene()
    if scene then scene:setPosition(-10000, -10000) end
    if OS_IS_IOS then
        cc.Director:getInstance():endToLua()
        os.exit()
    else
        cc.Director:getInstance():endToLua()
    end
end

for i = 1, 10 do
    _G["AppExit"..i] = function ()
        APP_EXIT = true
        local scene = cc.Director:getInstance():getRunningScene()
        if scene then scene:setPosition(-10000, -10000) end
        if OS_IS_IOS then
            cc.Director:getInstance():endToLua()
            os.exit()
        else
            cc.Director:getInstance():endToLua()
        end
    end
end

function LoginView:ctor()
    LoginView.super.ctor(self)
    self.noSound = true
    sfc:addSpriteFrames("asset/ui/login.plist", "asset/ui/login.png")

    self._appInformation = AppInformation:getInstance()
    self._configMgr = kakura.Config:getInstance()

    -- 防雪崩
    self._PLFailedInfo = {}
    self._LFailedInfo = {}
    self._canPlatformLoginTime = SystemUtils.loadGlobalLocalData("L_canPlatformLoginTime")
    if self._canPlatformLoginTime == nil then self._canPlatformLoginTime = 0 end
    self._canLoginTime = SystemUtils.loadGlobalLocalData("L_canLoginTime")
    if self._canLoginTime == nil then self._canLoginTime = 0 end

    self._platformLoginInv = SystemUtils.loadGlobalLocalData("L_platformLoginInv")
    if self._platformLoginInv == nil then self._platformLoginInv = 0 end
    self._loginInv = SystemUtils.loadGlobalLocalData("L_loginInv")
    if self._loginInv == nil then self._loginInv = 0 end

    self._updateId = ScheduleMgr:regSchedule(10, self, function(self, dt)
        self:update()
    end)

    local hour = tonumber(os.date("%H"))
    if OS_IS_WINDOWS then
        if hour >= 10 and hour < 12 then
            self._timeType = 1
        elseif hour >= 12 and hour < 18 then
            self._timeType = 2
        else
            self._timeType = 3
        end
    else
        if hour >= 5 and hour < 17 then
            self._timeType = 1
        elseif hour >= 17 and hour < 20 then
            self._timeType = 2
        else
            self._timeType = 3
        end
    end
    self._timeType = 1

    -- 判断是否是腾讯手游助手
    if not OS_IS_WINDOWS then
        if GameStatic.TxGameAssistant_login then
            if OS_IS_ANDROID then
                pcall(function ()
                    local deviceInfo = ApiUtils.getDeviceInfo()
                    local imei = deviceInfo.imei
                    if imei and type(imei) == "string" and string.len(imei) > 5 then
                        if string.sub(imei, 1, 5) == "66666" then
                            local luaBridge = require "cocos.cocos2d.luaj"
                            local result, channelID = luaBridge.callStaticMethod("com/utils/core/SDKUtils", "getChannelID", {})
                            -- 增加渠道号判断
                            if tostring(channelID) == "10028405" then
                                IS_TxGameAssistant = true
                            end
                        end
                    end
                end)
            end
        end
        -- 灰度测试机
        pcall(function ()
            local list = string.split(GameStatic.test_device, ":")
            local deviceID = ApiUtils.getDeviceID()
            for i = 1, #list do
                if deviceID == list[i] then
                    IS_TxGameAssistant = true
                    break
                end
            end
        end)
    end
end

function LoginView:getOutsideChannelList()
    local list = require "game.OutsideChannel"
    return list
end

function LoginView:getBgName()
    return "bg_09"..self._timeType..".jpg"
end

function LoginView:destroy()
    if OS_IS_WINDOWS then
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        dispatcher:removeEventListenersForTarget(self._accNode, true)
    end
    cc.Device:setAccelerometerEnabled(false)
    if self._acceleLayer then
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        dispatcher:removeEventListenersForTarget(self._acceleLayer, true)
    end
    if self._spineLayer then
        self._spineLayer:removeAllChildren()
    end
    spineMgr:clear()
    ScheduleMgr:unregSchedule(self._updateId)
    ScheduleMgr:unregSchedule(self._effUpdateId)
    ScheduleMgr:unregSchedule(self._acceleUpdateId)
    sfc:removeSpriteFramesFromFile("asset/ui/login.plist")
    tc:removeTextureForKey("asset/ui/login.png")

    -- 不释放资源
    LoginView.super.destroy(self, false)
end

function LoginView:onTop()
    audioMgr:playMusic("signin", true)
end

function LoginView:onInit()
    ApiUtils.playcrab_device_monitor_action("loginview")

    self._logo = cc.Sprite:create("asset/bg/logo.png")
    self._logo:setPosition(self._logo:getContentSize().width * 0.5 * 0.75 - 10, MAX_SCREEN_HEIGHT - self._logo:getContentSize().height * 0.5 * 0.75 + 5)
    self._logo:setScale(0.75)
    self._widget:addChild(self._logo, -1)

    audioMgr:playMusic("signin", true)
    self._bg = self:getUI("bg")
    self._acountLabel = self:getUI("bg.center.p.acountLabel")

    self._acountPanel = self:getUI("bg.center.p")

    self._panel1 = self:getUI("bg.panel1")
    self._okBtn1 = self:getUI("bg.panel1.okBtn1")
    
    self._panel2 = self:getUI("bg.panel2")
    self._login1 = self:getUI("bg.panel2.login1")
    self._login1:setPositionY(0)
    self._login2 = self:getUI("bg.panel2.login2")
    self._login3 = self:getUI("bg.panel2.login3")

    self._serverBtn = self:getUI("bg.center.serverBtn")
    self._serverTitle = self:getUI("bg.center.serverBtn.title")
    self._state = self:getUI("bg.center.serverBtn.state")
    self._label = self:getUI("bg.center.serverBtn.label")
    self._loginBtn = self:getUI("bg.loginBtn")
    self._logoutBtn = self:getUI("bg.logoutBtn")
    self._cgBtn = self:getUI("bg.cgBtn")
    self._kfBtn = self:getUI("bg.kfBtn")
    self._noticeBtn = self:getUI("bg.noticeBtn")

    if IS_APPLE_EXAMINE then
        self._kfBtn:setVisible(false)
    end

    local mc = mcMgr:createViewMC("kaishianniu_kaishi", true, false)
    mc:setPosition(self._loginBtn:getContentSize().width * 0.5, self._loginBtn:getContentSize().height * 0.5 + 5)
    self._loginBtn:addChild(mc)

    self._serverBtn:setVisible(false)
    self._loginBtn:setVisible(false)
    self._logoutBtn:setVisible(false)
    self._noticeBtn:setVisible(false)

    if GameStatic.enableSDK then
        self._panel1:setVisible(false)
        self._panel2:setVisible(false)
        self._acountPanel:setVisible(false)
        self._isShowAuthTips = true
        if OS_IS_ANDROID then
            self._login1:setVisible(false)
            self._login2:setPositionX(self._login2:getPositionX() + 150)
            self._login3:setPositionX(self._login3:getPositionX() - 450)    
        elseif OS_IS_IOS then
            if not sdkMgr:hasPlatform("WX") then
                self._login2:setVisible(false)
                self._login1:setPositionX(self._login1:getPositionX() + 150)
                self._login3:setPositionX(self._login3:getPositionX() - 150)
            end
        end
        if IS_TxGameAssistant then
            self._login1:setVisible(false)
            self._login2:setVisible(false)
            self._login3:setVisible(false)
            local parent = self._login1:getParent()
            local y = self._login1:getPositionY()
            local w
            if MAX_SCREEN_WIDTH <= 1024 then
                w = 1180
            else
                w = 1180 + (MAX_SCREEN_WIDTH - 1024)
            end
            if w > 1300 then
                w = 1300
            end
            self._login4 = ccui.Button:create("tencent_login_qq_1.png", "tencent_login_qq_1.png", "tencent_login_qq_1.png", 1)
            parent:addChild(self._login4)
            self._login5 = ccui.Button:create("tencent_login_qq_2.png", "tencent_login_qq_2.png", "tencent_login_qq_2.png", 1)
            parent:addChild(self._login5)
            self._login6 = ccui.Button:create("tencent_login_wx_1.png", "tencent_login_wx_1.png", "tencent_login_wx_1.png", 1)
            parent:addChild(self._login6)
            self._login7 = ccui.Button:create("tencent_login_wx_2.png", "tencent_login_wx_2.png", "tencent_login_wx_2.png", 1)
            parent:addChild(self._login7)

            self._login6:setPosition(-w * 0.3, y)
            self._login7:setPosition(-w * 0.1, y)
            self._login4:setPosition(w * 0.1, y)
            self._login5:setPosition(w * 0.3, y)
            
            self:registerClickEvent(self._login4, function ()
                self:disableLoginBtns()
                self:platformLogin3("i")
            end)
            self:registerClickEvent(self._login5, function ()
                self:disableLoginBtns()
                self:platformLogin3("a")
            end)
            self:registerClickEvent(self._login6, function ()
                self:disableLoginBtns()
                self:platformLogin2("i")
            end)
            self:registerClickEvent(self._login7, function ()
                self:disableLoginBtns()
                self:platformLogin2("a")
            end)
        end
        if _G.sdkAutoLoginPlatform then
            GLOBAL_VALUES.sdkAutoLoginPlatform = _G.sdkAutoLoginPlatform
            _G.sdkAutoLoginPlatform = nil
        end
        sdkMgr:loginWithLocalInfo({}, function(code, data)
            code = tonumber(code)
            if code == sdkMgr.SDK_STATE.SDK_LOGIN_SUCCESS then
                if self._logoutBtn and self._noticeBtn and self.platformLogin then
                    GLOBAL_VALUES.sdkAutoLoginPlatform = nil
                    self._logoutBtn:setVisible(true)
                    self._noticeBtn:setVisible(true)

                    local forcePlatform
                    if IS_TxGameAssistant then
                        forcePlatform = SystemUtils.loadGlobalLocalData("forcePlatform")
                        if forcePlatform == "" then
                            forcePlatform = nil
                        end
                    end
                    self._isShowAuthTips = false
                    self:platformLogin(json.decode(data), forcePlatform)
                end
            else
                if self._logoutBtn and self._noticeBtn and self._panel2 then
                    self._logoutBtn:setVisible(false)
                    self._noticeBtn:setVisible(false)
                    self._panel2:setVisible(true)

                    if GLOBAL_VALUES.sdkAutoLoginPlatform then
                        self:lock(-1)
                        ScheduleMgr:delayCall(200, self, function()
                            pcall(function ()
                                self:sdk_need_login(GLOBAL_VALUES.sdkAutoLoginPlatform)
                                GLOBAL_VALUES.sdkAutoLoginPlatform = nil
                                self:unlock()
                            end)
                        end)
                    end
                end
            end
        end)
    else
        self._panel1:setVisible(true)
        self._panel2:setVisible(false)
        self._acountPanel:setVisible(true)
    end

    self._version = self:getUI("bg.version")
    
    self._version:setString("v" .. GameStatic.version)
    self._version:enableOutline(cc.c4b(100, 30, 10, 255), 1)

    if not OS_IS_WINDOWS then
        GameStatic.walleVersion = self._configMgr:getValue("APP_BUILD_NUM")
        self._version:setString(self._version:getString() .. " (" .. GameStatic.walleVersion .. ")")
    end
    local _count = 0
    self:registerClickEvent(self._version, function () 
        _count = _count + 1
        if _count == 20 then
            _count = 0
            self._viewMgr:showTip(ApiUtils.getDeviceID())
        end
    end)
     -- self._version:setString("hello walle 129")
        
    self._copyRight = self:getUI("bg.copyRight")
    self._copyRight:setString("copyright 2017 Ubisoft Mobile Games. All Rights Reserved")
    self._copyRight:enableOutline(cc.c4b(100, 30, 10, 255), 1)
    if OS_IS_ANDROID then
        local _count2 = 0
        self:registerClickEvent(self._copyRight, function () 
            _count2 = _count2 + 1
            if _count2 == 20 then
                _count2 = 0
                local deviceInfo = ApiUtils.getDeviceInfo()
                local imei = deviceInfo.imei
                local luaBridge = require "cocos.cocos2d.luaj"
                local result, channelID = luaBridge.callStaticMethod("com/utils/core/SDKUtils", "getChannelID", {})
                self._viewMgr:showTip(imei .. " " .. channelID)
            end
        end)
    end

    self._bottom = self:getUI("bg.bottom")
    self._bottom:setVisible(false)

    self._xieyiBtn = self:getUI("bg.bottom.btn")
    self._xieyiSelect = self:getUI("bg.bottom.btn.select")
    self._xieyiLabel = self:getUI("bg.bottom.label2")
    if self._timeType == 1 then
        self._xieyiLabel:setColor(cc.c3b(202, 238, 255))
    elseif self._timeType == 2 then
        self._xieyiLabel:setColor(cc.c3b(166, 241, 255))
    end
    self:registerClickEvent(self._xieyiBtn, function () 
        self._xieyiSelect:setVisible(not self._xieyiSelect:isVisible())
    end)
    self:registerClickEvent(self._xieyiLabel, function () 
        sdkMgr:loadUrl({type = "1", url = GameStatic.contractUrl})
        print(GameStatic.contractUrl)
    end)

    -- local label = cc.Label:createWithSystemFont("© 2016 Ubisoft Mobile Games. All Rights Reserved", "Arial", self._copyRight:getFontSize())
    -- label:setAnchorPoint(1, 0.5)
    -- label:setColor(self._copyRight:getColor())
    -- label:setPosition(self._copyRight:getPosition())
    -- self._copyRight:getParent():addChild(label, 99999)

    local account = self:loadLocalData("account")
    if OS_IS_WINDOWS then 
        local supperAccount = self._configMgr:getValue("SPECIAL_AC", "")
        if supperAccount ~= "" then 
            account = supperAccount
        end
    end
    if account == nil then
        account = "U"..string.sub(tostring(os.time()), 3, string.len(tostring(os.time()) - 2))..GRandom(9)
    end
    self._acountLabel:setFontSize(32)
    self._acountLabel:getParent():setOpacity(150)
    self._acountLabel:setPlaceHolder("请输入帐号")
    self._acountLabel:setPlaceHolderColor(cc.c4b(180, 180, 180, 255))
    self._acountLabel:setColor(cc.c3b(255, 255, 255))
    self._acountLabel:setString(account)
    self._acountLabel:setTouchEnabled(false)

    self:registerClickEvent(self._acountLabel:getParent(), function ()  
        self._acountLabel:attachWithIME()
    end)

    self:registerClickEvent(self._okBtn1, function ()
        self:platformLogin()
    end)
    self:registerClickEvent(self._login1, function ()
        local desc = cc.Label:createWithTTF("　　敬爱的玩家，您正在使用游客模式进行游戏，\
游客模式下的游戏数据（包含付费数据）会在删除\
游戏、更换设备后清空。为了保障您的虚拟财产安\
全，以及让您获得更完善的游戏体验，我们建议您\
使用QQ/微信登录进行游戏！", 
            UIUtils.ttfName, 18)
        desc:setColor(cc.c3b(60, 30, 0))
        self._viewMgr:showSelectDialog(desc, "继续登录", function()
            self:disableLoginBtns()
            self:platformLogin1()
        end, "取消", function()

        end)
    end)
    self:registerClickEvent(self._login2, function ()
        self:disableLoginBtns()
        self:platformLogin2()
    end)
    self:registerClickEvent(self._login3, function ()
        self:disableLoginBtns()
        self:platformLogin3()
    end)

    self:registerClickEvent(self._logoutBtn, function ()
        self:logout()
    end)

    self:registerClickEvent(self._cgBtn, function ()
        self._viewMgr:showView("logo.VideoView", {runType = 4})
        sdkMgr:hideJGLauncher()
    end)

    self:registerClickEvent(self._kfBtn, function ()
        CustomServiceUtils.loginFailed()
    end)

    self:registerClickEvent(self._noticeBtn, function ()
        ApiUtils.getNotice(1)
    end)

    self:registerClickEvent(self._loginBtn, function () 
        self:login()
    end)

    self._selectServerView = self._viewMgr:createLayer("login.SelectServerView", {})
    self:addChild(self._selectServerView)
    self._selectServerView:setVisible(false)
    self:registerClickEvent(self._serverBtn, function () 
        -- self._bg:setVisible(false)
        if #self._serverArray > 0 then
            if self._selectServerView then
                self._selectServerView:reflash({array = self._serverArray, callback = self._selectServerCallback})
                self._selectServerView:openEx()     
            end
        end
        -- self._serverLayer:appear(self._serverList[self._lastServerId])
    end)

    -- local str = '[pic=globalImageUI_exp.png][-][color=ff0000]'..cc.FileUtils:getInstance():getWritablePath()..'[color=ff0000]说[-][pic=globalImageUI_Star.png][-]啊[color=ffff00]喔a[-]asdasd[][-][color=00ff00]a4sd56a4s6d5a4s6d54阿斯达斯[-][-]'
    -- local str = " \
    -- [color=ffffff]1、竞技场每天可免费参加[color=00ff00]10[-]次，并通过且仅通过消耗钻石获得额外的竞技场参加次数[-][][-] \
    -- [color=ffffff]2、每个自然日[color=00ff00]20:00[-]对竞技场排名奖励进行结算[-][][-] \
    -- [color=ffffff]3、竞技场免费参加次数、累计消耗钻石与单日获得荣誉在每个自然日[color=00ff00]5:00[-]刷新[-][][-] \
    -- [color=ffffff]4、若游戏中出现超时或平局，以主动挑战方失败结束[-][][-] \
    -- [color=ffffff]5、玩家在主动参与竞技场比拼即可获得单日荣誉奖励[-][][-] \
    -- [color=ffffff]6、单次获胜获得[color=00ff00]30[-]点荣誉，失败获得[color=00ff00]15[-]点荣誉[-] \
    -- "
    -- local richText = RichTextFactory:create(str, 300, 30)
    -- richText:formatText()
    -- local w = richText:getInnerSize().width
    -- local h = richText:getInnerSize().height
    -- richText:setAnchorPoint(cc.p(0, 0.5))
    -- richText:setPosition(568, 240)
    -- self:addChild(richText)

    -- self:registerClickEvent(self._version, function ()  
    --     -- GameStatic.showDEBUGInfo = not GameStatic.showDEBUGInfo
    --     -- cc.Director:getInstance():setDisplayStats(GameStatic.showDEBUGInfo)
    --     -- self._viewMgr:showDebugInfo(GameStatic.showDEBUGInfo)
    -- end)

    -- self:registerClickEvent(self._copyRight, function ()  
        
    -- end)
    
    trycall("initEff", self.initEff, self)

    -- 开发中功能
    local devBtn = self:getUI("bg.devBtn")
    if GameStatic.enableDevelop then
        self:registerClickEvent(devBtn, function ()
            self._viewMgr:showDialog("dev.DevelopDialog", {}, true)
        end)
    else
        devBtn:setVisible(false)
    end
end

function LoginView:disableLoginBtns()
    self._login1:setEnabled(false)
    self._login2:setEnabled(false)
    self._login3:setEnabled(false)
    if self._login4 then
        self._login4:setEnabled(false)
        self._login5:setEnabled(false)
        self._login6:setEnabled(false)
        self._login7:setEnabled(false)
    end
    ScheduleMgr:delayCall(1000, self, function()
        self._login1:setEnabled(true)
        self._login2:setEnabled(true)
        self._login3:setEnabled(true)
        if self._login4 then
            self._login4:setEnabled(true)
            self._login5:setEnabled(true)
            self._login6:setEnabled(true)
            self._login7:setEnabled(true)
        end
    end)
end

function LoginView:initEff()
    if OS_IS_WINDOWS then
        self._accNode = cc.Layer:create()
        self:addChild(self._accNode)
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(function(touch, event)
            return true
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        local maxXOffset = 50
        local maxYOffset = maxXOffset * (MAX_SCREEN_HEIGHT / MAX_SCREEN_WIDTH)
        listener:registerScriptHandler(function(touch, event)
            local x = (touch:getLocation().x - MAX_SCREEN_WIDTH * 0.5) / MAX_SCREEN_WIDTH * 1
            local y = (-touch:getLocation().y) / MAX_SCREEN_HEIGHT * 1
            local yy = y 
            if yy > -0.5 then
                yy = -0.5
            end
            yy = yy + 0.75
            local xx = x
            if xx > 0.6 then xx = 0.6 end
            if xx < -0.6 then xx = -0.6 end
            self._acceleDx1 = MAX_SCREEN_WIDTH * 0.5 - xx / 0.6 * maxXOffset
            self._acceleDy1 = MAX_SCREEN_HEIGHT * 0.5 - yy * maxYOffset * 2
            self._acceleDx2 = MAX_SCREEN_WIDTH * 0.5 - xx / 0.6 * maxXOffset * 0.3
            self._acceleDy2 = MAX_SCREEN_HEIGHT * 0.5 - yy * maxYOffset * 0.6
            self._acceleDx3 = MAX_SCREEN_WIDTH * 0.5 - xx / 0.6 * maxXOffset * 0.6
            self._acceleDy3 = MAX_SCREEN_HEIGHT * 0.5 - yy * maxYOffset * 1.2

        end, cc.Handler.EVENT_TOUCH_MOVED)
        dispatcher:addEventListenerWithSceneGraphPriority(listener, self._accNode)
    end

    self._widget:setVisible(false)

    local w, h = self._logo:getContentSize().width * 0.5, self._logo:getContentSize().height * 0.5
    local x, y

    x = w - 1
    y = h - 1
    local mc1 = mcMgr:createViewMC("logo3_logo", true, false, function (_, mc)
        mc:stop()
    end)
    mc1:setPosition(0, 20)
    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(x, y)
    local mask = cc.Sprite:createWithSpriteFrameName("login_mask1.png")
    mask:setScale(0.72)
    -- mask:setOpacity(200)
    -- mask:setPosition(x, y)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.5)
    clipNode:addChild(mc1)
    self._logo:addChild(clipNode)

    x = w
    y = h
    local mc2 = mcMgr:createViewMC("logo2_logo", true, false)
    mc2:setScale(0.9)
    mc2:setPosition(x, y)
    self._logo:addChild(mc2)

    x = w - 2
    y = h
    local mc3 = mcMgr:createViewMC("logo1_logo", true, false)
    mc3:setPosition(0, 20)
    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(x + 1, y + 1)
    local mask = cc.Sprite:createWithSpriteFrameName("login_mask3.png")
    mask:setScale(0.98)
    -- mask:setOpacity(200)
    -- mask:setPosition(x, y)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.5)
    clipNode:addChild(mc3)
    -- clipNode:setScale(0.72)
    self._logo:addChild(clipNode)

    self._effUpdateId = ScheduleMgr:regSchedule(5000, self, function(self, dt)
        mc1:gotoAndPlay(1)
    end)

    tc:addImage("asset/spine/dengluheilong.png")
    tc:addImage("asset/spine/dengluqishi.png")
    tc:addImage("asset/spine/denglusenglv.png")
    self._spineLayer = cc.Node:create()
    self:addChild(self._spineLayer, -9)
    self._spineLayer:setScale(self.__viewBg:getScaleX())
    self._spineLayer:setPosition(self.__viewBg:getPosition())

    self._spineLayer2 = cc.Node:create()
    self:addChild(self._spineLayer2, -9)
    self._spineLayer2:setScale(self.__viewBg:getScaleX())
    self._spineLayer2:setPosition(self.__viewBg:getPosition())

    self._spineLayer3 = cc.Node:create()
    self:addChild(self._spineLayer3, -8)
    self._spineLayer3:setScale(self.__viewBg:getScaleX())
    self._spineLayer3:setPosition(self.__viewBg:getPosition())

    -- 截静态图专用开关
    local pause = EFF_DEBUG

    -- 人物动画
    local xx, yy = 481, 288

    spineMgr:createSpine("dengluheilong", function (spine)
        if self._spineLayer == nil then return end
        spine:setScale(0.9)
        spine:setSkin("default")
        spine:setAnimation(0, "heilong", true)
        spine:setPosition(300 - xx, 0 - yy)
        spine:setLocalZOrder(3)
        self._spineLayer:addChild(spine)
        spine:initUpdate()
        if pause then spine:animPause() end
    end)

    spineMgr:createSpine("dengluqishi", function (spine)
        if self._spineLayer == nil then return end
        spine:setScale(0.9)
        spine:setSkin("default")
        spine:setAnimation(0, "qishi", true)
        spine:setPosition(750 - xx, 70 - yy)
        spine:setLocalZOrder(5)
        self._spineLayer:addChild(spine)
        spine:initUpdate()
        if pause then spine:animPause() end
    end)

    spineMgr:createSpine("denglusenglv", function (spine)
        if self._spineLayer == nil then return end
        spine:setScale(1)
        spine:setSkin("default")
        spine:setAnimation(0, "senglv", true)
        spine:setPosition(880 - xx, -40 - yy)
        spine:setLocalZOrder(7)
        self._spineLayer:addChild(spine)
        spine:initUpdate()
        if pause then spine:animPause() end
    end)

    local mc1 = mcMgr:createViewMC("huoyan_dixiachenglogin", true, false)
    if pause then mc1:stop() end
    mc1:setScale(1)
    mc1:setPosition(457 - xx, 300 - yy)
    self._spineLayer:addChild(mc1, 4)

    local mc1 = mcMgr:createViewMC("changjingqian_dixiachenglogin", true, false)
    if pause then mc1:stop() end
    mc1:setScale(1)
    mc1:setPosition(475 - xx, 285 - yy)
    self._spineLayer:addChild(mc1, 6)

    local mc1 = mcMgr:createViewMC("qiangbing_dixiachenglogin", true, false)
    if pause then mc1:stop() end
    mc1:setScale(1)
    mc1:setPosition(475 - xx, 285 - yy)
    self._spineLayer3:addChild(mc1, 1)

    local mc1 = mcMgr:createViewMC("huoxing_dixiachenglogin", true, false)
    if pause then mc1:stop() end
    mc1:setScale(1)
    mc1:setPosition(475 - xx, 285 - yy)
    self._spineLayer2:addChild(mc1, 2)
    -- local mc1 = mcMgr:createViewMC(nameTab[9], true, false)
    -- if pause then mc1:stop() end
    -- mc1:setScale(0.95)
    -- mc1:setPosition(494 - xx, 285 - yy)
    -- self._spineLayer2:addChild(mc1, 9)
    -- local mc2 = mcMgr:createViewMC(nameTab[10], true, false)
    -- if pause then mc2:stop() end
    -- mc2:setScale(0.95)
    -- mc2:setPosition(516 - xx, 285 - yy)
    -- self._spineLayer2:addChild(mc2, 9)

    -- 重力感应
    local x = 1022 * (1136 / 1022)
    local scale = ((x + 120) / x) * self.__viewBg:getScaleX()
    self.__viewBg:setScale(scale)

    local maxXOffset = 50
    local maxYOffset = maxXOffset * (MAX_SCREEN_HEIGHT / MAX_SCREEN_WIDTH)

    self.__viewBg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)

    local listerner  = cc.EventListenerAcceleration:create(function (event,x,y,z,timestamp)
        local yy = y 
        if yy > -0.5 then
            yy = -0.5
        end
        yy = yy + 0.75
        local xx = x
        if xx > 0.6 then xx = 0.6 end
        if xx < -0.6 then xx = -0.6 end
        self._acceleDx1 = MAX_SCREEN_WIDTH * 0.5 - xx / 0.6 * maxXOffset
        self._acceleDy1 = MAX_SCREEN_HEIGHT * 0.5 - yy * maxYOffset * 2
        self._acceleDx2 = MAX_SCREEN_WIDTH * 0.5 - xx / 0.6 * maxXOffset * 0.3
        self._acceleDy2 = MAX_SCREEN_HEIGHT * 0.5 - yy * maxYOffset * 0.6
        self._acceleDx3 = MAX_SCREEN_WIDTH * 0.5 - xx / 0.6 * maxXOffset * 0.6
        self._acceleDy3 = MAX_SCREEN_HEIGHT * 0.5 - yy * maxYOffset * 1.2
    end)
    local speed = 0.005
    local function ___updata()
        if self._acceleDx1 == nil then return end
        local x1 = self.__viewBg:getPositionX()
        local y1 = self.__viewBg:getPositionY()
        local x2 = self._spineLayer:getPositionX()
        local y2 = self._spineLayer:getPositionY()
        local x3 = self._spineLayer2:getPositionX()
        local y3 = self._spineLayer2:getPositionY()

        x1 = x1 + (self._acceleDx1 - x1) * speed
        y1 = y1 + (self._acceleDy1 - y1) * speed
        x2 = x2 + (self._acceleDx2 - x2) * speed
        y2 = y2 + (self._acceleDy2 - y2) * speed
        x3 = x3 + (self._acceleDx3 - x3) * speed
        y3 = y3 + (self._acceleDy3 - y3) * speed
        self.__viewBg:setPosition(x1, y1)
        self._spineLayer:setPosition(x2, y2)
        self._spineLayer2:setPosition(x3, y3)
        if speed < 0.25 then
            speed = speed + 0.005
        end
    end
    self._acceleUpdateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
        ___updata()
    end)
    if GameStatic.loginAccelerometer then
        cc.Device:setAccelerometerEnabled(true)
    end
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local layer = cc.Layer:create()
    layer:setAccelerometerEnabled(true)
    self:addChild(layer)
    dispatcher:addEventListenerWithSceneGraphPriority(listerner, layer)
    self._acceleLayer = layer

    self._logo:setCascadeOpacityEnabled(true, true)
    self._logo:setOpacity(0)
    self._logo:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function ()
        if not pause then
            self._widget:setVisible(true)
        end
    end), cc.FadeIn:create(0.3)))
end

-- 用于检查是否可以登录
function LoginView:update()
    local now = os.time()
    if now < self._canPlatformLoginTime then
        self:_disablePlatformLogin()
    else
        self:_enablePlatformLogin()
    end
    if now < self._canLoginTime or GameStatic.ipAddress == nil or GameStatic.ipAddress == "" then
        self:_disableLogin()
    else
        self:_enableLogin()
    end
end
function LoginView:_enablePlatformLogin()
    self._login1:setScaleAnim(true)
    self._login1:setSaturation(0)
    self._login2:setScaleAnim(true)
    self._login2:setSaturation(0)
    self._login3:setScaleAnim(true)
    self._login3:setSaturation(0)
    if self._login4 then
        self._login4:setScaleAnim(true)
        self._login4:setSaturation(0)
        self._login5:setScaleAnim(true)
        self._login5:setSaturation(0)
        self._login6:setScaleAnim(true)
        self._login6:setSaturation(0)       
        self._login7:setScaleAnim(true)
        self._login7:setSaturation(0)   
    end
end
function LoginView:_disablePlatformLogin()
    self._login1:setScaleAnim(false)
    self._login1:setSaturation(-100)
    self._login2:setScaleAnim(false)
    self._login2:setSaturation(-100)
    self._login3:setScaleAnim(false)
    self._login3:setSaturation(-100)
    if self._login4 then
        self._login4:setScaleAnim(false)
        self._login4:setSaturation(-100)
        self._login5:setScaleAnim(false)
        self._login5:setSaturation(-100)
        self._login6:setScaleAnim(false)
        self._login6:setSaturation(-100)      
        self._login7:setScaleAnim(false)
        self._login7:setSaturation(-100)    
    end
end
function LoginView:_enableLogin()
    self._loginBtn:setScaleAnim(true)
    self._loginBtn:setSaturation(0)
end
function LoginView:_disableLogin()
    self._loginBtn:setScaleAnim(false)
    self._loginBtn:setSaturation(-100)
end

function LoginView:showErrorMsg(msg, code, callback, ex, callback1, callback2, title0, title1, title2)
    if callback1 and callback2 then
        self._viewMgr:showDialog("global.NetWorkDialog", {msg = msg, errorCode = code,
         callback1 = callback1, callback2 = callback2, title0 = title0, title1 = title1, title2 = title2, btn2dontClose = true})   
    else
        self._viewMgr:showDialog("global.NetWorkDialog", {msg = msg, errorCode = code, callback = callback})
    end
    if code and GameStatic.uploadErrorCode then
        if ex == nil then
            ex = ""
        end
        ApiUtils.playcrab_lua_error("errorCode_"..tostring(code), ex, "code")
    end
end

-- 平台登录
function LoginView:platformLoginForbidTip(btn)
    -- 检查是否禁止登录中
    if not btn:isScaleAnim() then
        local sec = self._canPlatformLoginTime - os.time()
        if sec < 1 then
            sec = 1
        end
        self._viewMgr:showTip("登录过于频繁，请在"..sec.."秒后重新尝试登录")
        return false
    end
    -- 检查是否没有网络
    if not OS_IS_WINDOWS and AppInformation:getInstance():getNetworkType() == 1 then
        self:showErrorMsg("网络未连通，请稍后重试")
        return false
    end
    return true
end
-- 异常账号登陆相关
function LoginView:sdk_need_login(platform, flag)
    print("sdk_need_login", platform, flag)
    if flag == "0" or flag == "3004" then
        -- 重复账号拉起，wx会返回0 qq会返回3004
        return
    end
    if self._panel2:isVisible() then
        -- 如果处于登陆界面的未登陆平台状态，则自动拉起平台授权
        if platform == "1" then
            self:disableLoginBtns()
            self:platformLogin2()
        else
            self:disableLoginBtns()
            self:platformLogin3()
        end
    else
        -- 否则，重启游戏，并且下一次到登陆界面的时候，自动拉起平台授权
        GLOBAL_VALUES.sdkAutoLoginPlatform = platform
        self._viewMgr:restart()
    end
end
-- 游客
function LoginView:platformLogin1()
    if not self:platformLoginForbidTip(self._login1) then return end
    ApiUtils.gsdkSetEvent({tag = "3", status = "true", msg = "GUEST"})
    sdkMgr:login({["type"] = "Guest"}, function(code, data)
        self._viewMgr:unlock()
        if code == sdkMgr.SDK_STATE.SDK_LOGIN_FAIL then
            self:_platformLoginFailed()
            ApiUtils.gsdkSetEvent({tag = "4", status = "false", msg = tostring(code)})
            self:showErrorMsg("授权失败，请稍后重试", "6662003")
        elseif code == sdkMgr.SDK_STATE.SDK_LOGIN_SUCCESS then
            ApiUtils.gsdkSetEvent({tag = "4", status = "true", msg = "success"})
            if IS_TxGameAssistant then SystemUtils.saveGlobalLocalData("forcePlatform", "") end
            self:platformLogin(json.decode(data))
        end
    end)
end
-- 微信
function LoginView:platformLogin2(forcePlatform)
    if not self:platformLoginForbidTip(self._login2) then return end
    ApiUtils.gsdkSetEvent({tag = "3", status = "true", msg = "WX"})
    sdkMgr:login({["type"] = "WX"}, function(code, data)
        if code == sdkMgr.SDK_STATE.SDK_LOGIN_FAIL then
            self:_platformLoginFailed()
            ApiUtils.gsdkSetEvent({tag = "4", status = "false", msg = tostring(code)})
            self:showErrorMsg("授权失败，请稍后重试", "6662003")
        elseif code == sdkMgr.SDK_STATE.SDK_LOGIN_SUCCESS then
            ApiUtils.gsdkSetEvent({tag = "4", status = "true", msg = "success"})
            if IS_TxGameAssistant then SystemUtils.saveGlobalLocalData("forcePlatform", forcePlatform) end
            self:platformLogin(json.decode(data), forcePlatform)
        end
    end)
end
-- QQ
function LoginView:platformLogin3(forcePlatform)
    if not self:platformLoginForbidTip(self._login3) then return end
    ApiUtils.gsdkSetEvent({tag = "3", status = "true", msg = "QQ"})
    sdkMgr:login({["type"] = "QQ"}, function(code, data)
        self._viewMgr:unlock()
        if code == sdkMgr.SDK_STATE.SDK_LOGIN_FAIL then
            self:_platformLoginFailed()
            ApiUtils.gsdkSetEvent({tag = "4", status = "false", msg = tostring(code)})
            self:showErrorMsg("授权失败，请稍后重试", "6662003")
        elseif code == sdkMgr.SDK_STATE.SDK_LOGIN_SUCCESS then
            ApiUtils.gsdkSetEvent({tag = "4", status = "true", msg = "success"})
            if IS_TxGameAssistant then SystemUtils.saveGlobalLocalData("forcePlatform", forcePlatform) end
            self:platformLogin(json.decode(data), forcePlatform)
        end
    end)
end

function LoginView:checkCheat()
    if OS_IS_ANDROID then
        -- virtualapp
        if GameStatic.android_cheat == nil or GameStatic.android_cheat == "" then
            GameStatic.android_cheat = "io.virtualapp:va-native"
        end
        local list = string.split(GameStatic.android_cheat, ":")
        local f = io.open('/proc/self/maps', 'rb')
        if f then
            local cmdline = f:read('*all')
            f:close()
            for i = 1, #list do
                if string.find(cmdline, list[i]) then
                    do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                    self:setPosition(-10000, 0)
                    return false
                end
            end
        else
            do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
            self:setPosition(-10000, 0)
            return false    
        end
    end
    return true
end

function LoginView:checkForbidDevice()
    if not OS_IS_WINDOWS then
        local forbid_device = sdkMgr:getDataFromDevice("fdbbbbbbb")
        if forbid_device == "" then
            forbid_device = nil
        end
        if forbid_device then
            do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
            self:setPosition(-10000, 0)
            return false
        end
    end
    if GameStatic.forbid_device == nil or GameStatic.android_cheat == "" then
        return true
    end
    local list = string.split(GameStatic.forbid_device, ":")
    for i = 1, #list do
        if list[i] == ApiUtils.getDeviceID() then
            if not OS_IS_WINDOWS then
                sdkMgr:saveDataInDevice("fdbbbbbbb", "1")
            end
            do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
            self:setPosition(-10000, 0)
            return false
        end
    end
    return true
end

function LoginView:checkVersion()
    if GameStatic.checkVersion == nil then return true end
    local version = require "game.GameVersion"
    if version and GameStatic.checkVersion > version then
        local dialog = self:showDialog("global.GlobalOkDialog", {desc = "很抱歉，检测到您之前更新流程出错，需要重新更新，请谅解", button = "确定", 
        callback = function ()
            local gameData = cc.FileUtils:getInstance():getStringFromFile("game.conf")
            if gameData == "" then return end
            local jsonData = cjson.decode(gameData)
            local baseVersion = jsonData["APP_BUILD_NUM"]
            pcall(function ()
                ApiUtils.playcrab_lua_error("vms_error", UserDefault:getStringForKey("vms__Resp", ""))
                local lastVersion = UserDefault:getStringForKey("lastAppBuildNum", "")
                if lastVersion and lastVersion ~= "" then
                    baseVersion = lastVersion
                end
            end)
            if baseVersion ~= nil and type(baseVersion) == "number" then 
                local configMgr = kakura.Config:getInstance()
                configMgr:setValue("APP_BUILD_NUM", tonumber(baseVersion))
                configMgr:save()
                kakura.PCDBManager:getInstance():setCurrentVersion(tonumber(baseVersion))       
            end
            self._viewMgr:restart()
        end}, true)
        dialog:setLocalZOrder(9999999)
        return false
    end
    return true
end

function LoginView:platformLogin(accountInfo, forcePlatform)
    local exit = false
    pcall(function ()
        if not self:checkCheat() then exit = true end
    end)
    pcall(function ()
        if not self:checkForbidDevice() then exit = true end
    end)
    pcall(function ()
        if not self:checkVersion() then exit = true end
    end)
    if exit then return end
    self:_platformLoginSuccess()
    if self._isShowAuthTips then
        self._viewMgr:showTip("授权成功")
    end
    self._acountLabel:getParent():setVisible(false)
    self._panel1:setVisible(false)
    self._panel2:setVisible(false)

    ApiUtils.playcrab_device_monitor_action("platformLogin")
    if not OS_IS_WINDOWS and AppInformation:getInstance():getNetworkType() == 1 then
        self:showErrorMsg("网络未连通，按确定重试", nil, function ()
            self:platformLogin(accountInfo)
        end)
        return
    end
    print("platformLogin=" ,platformLogin)
    local account = self._acountLabel:getString()
    if account == "" then
        return
    end
    self._viewMgr:lock(2000)
    self._token = ""
    self:saveLocalData("account", account)
    -- self._viewMgr:lock(-1)

    local loginUrl = self._appInformation:getValue("global_server_url", GameStatic.httpAddress_global)
    if GameStatic.use_globalExPort and RestartMgr.globalUrl_planB then
        loginUrl = RestartMgr.globalUrl_planB
    end

    -- 利用game.conf设定方便快速登录特殊账号
    if OS_IS_WINDOWS then 
        local superUrl = self._configMgr:getValue("GLOBAL_URL", "")
        if superUrl ~= "" then 
            loginUrl = superUrl
        end
    end
    local version = self._configMgr:getValue("APP_BUILD_NUM")

    local param = {}
    if GameStatic.enableSDK then
        DIFF_PLATFORM = false
        param = 
        {
            rand = math.random(), 
            origin_data = accountInfo.origin_data, 
            ver = version, 
            mod = "global", 
            sdk_type=accountInfo.sdk_type, 
            channel_alias = accountInfo.channel_alias, 
            channel_id = accountInfo.channel_id, 
            device_id = accountInfo.device_id, 
            device = accountInfo.device, 
            push_token = accountInfo.push_token, 
            os_type = accountInfo.os_type, 
            method = "Account.login"
        }

        -- 判断是否为外发渠道
        if OS_IS_ANDROID then
            pcall(function ()
                -- 防止外发渠道覆盖安装官网的包以后渠道号改变
                -- 1.如果本地有渠道号则取本地的渠道号
                local channel_id = sdkMgr:getDataFromDevice("OUTSIDE_CHANNEL")
                if channel_id == "" then
                    channel_id = nil
                end
                if channel_id then
                    param.channel_id = channel_id
                    IS_ANDROID_OUTSIDE_CHANNEL = true
                else
                    -- 2.没有的话，如果是外发，则写到本地
                    local list = self:getOutsideChannelList()
                    if list and param.channel_id then
                        IS_ANDROID_OUTSIDE_CHANNEL = list[tonumber(param.channel_id)] ~= nil
                        if IS_ANDROID_OUTSIDE_CHANNEL then
                            sdkMgr:saveDataInDevice("OUTSIDE_CHANNEL", tostring(param.channel_id))
                        end
                    end
                end
            end)
        end
        
        local sChannel = ""
        if IS_TxGameAssistant and forcePlatform then
            sChannel = sChannel .. forcePlatform
            if string.lower(param.os_type) == "ios" then
                if forcePlatform ~= "i" then
                    DIFF_PLATFORM = true
                end
            else
                if forcePlatform ~= "a" then
                    DIFF_PLATFORM = true
                end
            end
        else
            if string.lower(param.os_type) == "ios" then 
                sChannel = sChannel .. "i"
            else
                sChannel = sChannel .. "a"
            end
        end

        if string.lower(param.channel_alias) == "qq" then 
            sChannel = sChannel .. "qq"
        elseif string.lower(param.channel_alias) == "wx" then 
            sChannel = sChannel .. "wx"
        else
            sChannel = sChannel .. "guest"
        end
        GameStatic.userSimpleChannel = sChannel
        
    elseif OS_IS_WINDOWS or GameStatic.lua_model == 1 then 
        param = {rand = math.random(), origin_data = "eyJpZCI6MTAwMn0=", account_name = account, ver = version, mod = "global", sdk_type="Dev", channel_alias = "", channel_id = "-1", device_id = ApiUtils.getDeviceID(), device = json.encode(ApiUtils.getDeviceInfo()), push_token = "", os_type = "PC", method = "Account.login"}    
        -- param = {method = "Account.login", accountName = account, ver = version, mod = "global", channel = "direct"}
    end
    -- 设置平台别名
    sdkMgr:setChannelAlias(string.lower(param.channel_alias))

    dump(accountInfo, "test", 10)
    -- 设置拉起信息
    if accountInfo ~= nil and accountInfo.ext_data ~= nil then 
        WakeUpUtils.setCacheExtInfo(accountInfo.ext_data)
    end
    -- 利用game.conf设定方便快速登录
    if OS_IS_WINDOWS then 
        local superChannel = self._configMgr:getValue("CHANNEL", "")
        if superChannel ~= "" then 
            GameStatic.userSimpleChannel = superChannel
        end
    end    
    -- 为小羊添加
    param.pGroup = GameStatic.userSimpleChannel
    self._getServerParam = {loginUrl, param}
    self:getServerList(accountInfo)
end

-- 获取服务器列表
function LoginView:getServerList(accountInfo)
    local loginUrl = self._getServerParam[1]
    local param = self._getServerParam[2]
    print("globalurl: ", loginUrl)
    self._loginUrl = httpManager:sendMsg(loginUrl, nil, param, 
    function(inData)
        dump(inData)
        if self._viewMgr then
            if inData ~= nil and inData.result ~= nil and inData.result.sec_info ~= nil then 
                self._is_white = inData.result.is_white

                if inData.result.realName ~= 1 and GameStatic.is_show_realName then
                    self._viewMgr:showDialog("global.GlobalOkDialog",{
                        desc = "您的实名信息已存在于腾讯平台的帐号实名库，目前可以正常登陆腾讯游戏进行体验，请确认",
                        button = "确定",
                        title = "提示"})
                end

                ApiUtils.playcrab_device_monitor_action("login")
                ApiUtils.gsdkSetEvent({tag = "5", status = "true", msg = "success"})
                self:handleServerData(inData.result)
                self._viewMgr:unlock()
                if _G.LOGIN_NOTICE ~= 1 then 
                    _G.LOGIN_NOTICE = 1
                    -- 获取公告
                    ApiUtils.getNotice(1)
                end
            else
                self._viewMgr:unlock() 
                local _state
                if inData == nil then
                    _state = 1
                elseif inData.result == nil then
                    _state = 2
                elseif inData.result.sec_info == nil then
                    _state = 3
                else
                    _state = 4
                end
                ApiUtils.gsdkSetEvent({tag = "5", status = "false", msg = tostring(_state)})
                self:showErrorMsg("服务器列表获取失败，按确定重试", "6662005.".._state, function ()
                    self._viewMgr:lock(1)
                    ScheduleMgr:delayCall(3000, self, function()
                        self._viewMgr:unlock()
                        self:platformLogin(accountInfo)
                    end)
                end, serialize({inData = inData}))
            end
        end 
    end,
    function(status, errorCode, response)
        if errorCode == 3 then
            -- 更换端口为8080, 再尝试
            if GameStatic.use_globalExPort then
                if RestartMgr.globalUrl_planB then
                    RestartMgr.globalUrl_planB = nil
                else   
                    RestartMgr.globalUrl_planB = ApiUtils.changeUrlPort(loginUrl, GameStatic.global_port)
                end
            end
        end
        ApiUtils.gsdkSetEvent({tag = "5", status = "false", msg = tostring(errorCode) .. "-" .. tostring(status)})
        if self._viewMgr then
            self._viewMgr:unlock()
            self:showErrorMsg("服务器列表获取失败，按确定重试", "6662006."..tostring(status), function ()
                self._viewMgr:lock(1)
                ScheduleMgr:delayCall(3000, self, function()
                    self._viewMgr:unlock()
                    self:platformLogin(accountInfo)
                end)
            end, serialize({url = loginUrl, httpdns = GameStatic.useHttpDns_Global, httpdnsUrl = self._loginUrl, response = response}))
            if GameStatic.useGetIP then
                GameStatic.useGetIP = false
                ApiUtils.getPublicIP(function (state, response)
                    if response and response ~= "" then
                        ApiUtils.playcrab_lua_error("errorCode_6662006."..tostring(status), response, "code")
                    end
                end)
            end
        end
    end,
    GameStatic.useHttpDns_Global)
end

-- 登录失败的时候用于更新服务器状态
function LoginView:updateServerState(callback)
    self:lock(-1)
    local loginUrl = self._getServerParam[1]
    local param = self._getServerParam[2]
    print("globalurl: ", loginUrl)
    self._loginUrl = httpManager:sendMsg(loginUrl, nil, param, 
    function(inData)
        self:unlock()
        self:handleServerData(inData.result)
        if callback then
            callback()
        end
    end,
    function(status, errorCode, response)
        self:unlock()
        if callback then
            callback()
        end
    end,
    GameStatic.useHttpDns_Global)
end

function LoginView:setServerStatePic(data)
    local picName = nil
    local maintain = tonumber(data.maintain)
    local status = tonumber(data.status)
    if maintain == 0 then
        if status == 0 then

        elseif status == 1 then
            -- picName = "login_mask1_new.png"
        elseif status == 2 then
            -- picName = "login_mask1_hot.png"
        end
        self._maintain = false
    elseif maintain == 1 then
        picName = "login_mask1_weihu.png"
        self._maintain = true
    end
    if picName then
        self._state:setVisible(true)
        self._state:loadTexture(picName, 1)
    else
        self._state:setVisible(false)
    end
end

function LoginView:setServerName(info)
    local name
    if self._hasMixed then
        if info.mixed and info.mixed ~= "" then
            name = info.name--"双平台 "..info.name
        else
            if DIFF_PLATFORM then
                if OS_IS_ANDROID then
                    name = "iOS "..info.name
                elseif OS_IS_IOS then
                    name = "安卓 "..info.name
                else
                    name = "Win "..info.name
                end
            else
                if OS_IS_ANDROID then
                    name = "安卓 "..info.name
                elseif OS_IS_IOS then
                    name = "iOS "..info.name
                else
                    name = "Win "..info.name
                end
            end
        end
    else
        name = info.name
    end
    self._serverTitle:setString(name)
    if self._serverTitle:getContentSize().width > 210 then
        self._serverTitle:setScale(210 / self._serverTitle:getContentSize().width)
    else
        self._serverTitle:setScale(1)
    end
end
-- 获取服务器列表
function LoginView:handleServerData(result)
    self._serverBtn:setVisible(true)
    self._loginBtn:setVisible(true)
    self._bottom:setVisible(true)
    self._copyRight:setVisible(false)
    self._logoutBtn:setVisible(true)
    self._noticeBtn:setVisible(true)

    self._token = result.gs_token
    self._accountName = result.account_name
    self._account_id = result.account_id
    -- 服务器列表
    -- dump(result, "a", 20)
    self._serverList = result["sec_info"]
    self._modelMgr:getModel("LeagueModel"):initServerNameMap(result["sec_info"])
    if self._serverList == nil then
        self:showErrorMsg("获取服务器列表失败", 6662007, function ()
            self:logout()
        end)   
        return
    end

    local lastLoginList = result["roles"]
    if lastLoginList then
        for k, v in pairs(lastLoginList) do
            -- 检查合法性
            if not (v.avatar and v.level and v.logoutTime and v.maxarena and v.name and v.rid and v.storyId and v.tequan and v.usid and v.vipLvl) then
                lastLoginList[k] = nil
                if OS_IS_WINDOWS then
                    self._viewMgr:showTip("roles 非法, id:".. k)
                end
            end
        end
    end

    self._hasMixed = false
    local serverArray = {}
    for k, v in pairs(self._serverList) do
        serverArray[#serverArray + 1] = v
        if v.mixed and v.mixed ~= "" then
            self._hasMixed = true
        end
        if lastLoginList ~= nil and lastLoginList[k] ~= nil then 
            v.role = lastLoginList[k]
        end
    end
   
    -- 按照字母顺序排序
    local sortFunc = function(a, b) 
        return (a.server_start_date or "2017-06-19 10:00:00") > (b.server_start_date or "2017-06-19 10:00:00")
        
    end
    table.sort(serverArray, sortFunc)

    self._serverArray = serverArray

    local recommendArray = {}
    for i = 1, #serverArray do
        if tonumber(serverArray[i].recommend) == 1 then
            recommendArray[#recommendArray + 1] = serverArray[i]
            if #recommendArray >= 1 then
                break
            end
        end
    end
    if #recommendArray == 0 then
        local time
        local _idx
        for i = 1, #serverArray do
            if time == nil then
                time = serverArray[i].server_start_date
                _idx = i
            else
                if serverArray[i].server_start_date and serverArray[i].server_start_date > time then
                    time = serverArray[i].server_start_date
                    _idx = i
                end
            end 
        end
        if _idx then
            recommendArray[#recommendArray + 1] = serverArray[_idx]
        end
    end

    -- 上次登录记录
    local localLastLogin = self:loadLocalData("LAST_LOGIN")
    if localLastLogin ~= nil and 
        self._serverList[tostring(localLastLogin)] ~= nil then 
        local lastLoginServer = self._serverList[tostring(localLastLogin)]
        local key = self._serverList[tostring(localLastLogin)].id
        -- 区id
        GameStatic.sec = key
        GameStatic.serverName = self._serverList[tostring(localLastLogin)].name
        self:setServerName(self._serverList[tostring(localLastLogin)])
        self:setServerStatePic(self._serverList[tostring(localLastLogin)])
        self._lastServerId = tostring(localLastLogin)
        GameStatic.ipAddress = self._serverList[tostring(localLastLogin)].ws.. "/"
        GameStatic.server_start_date = self._serverList[tostring(localLastLogin)].server_start_date
    elseif lastLoginList and next(lastLoginList) then
        -- 选择登录时间最大的服务器
        local max = 0
        local key = ""
        for k, v in pairs(lastLoginList) do
            if v.logoutTime and v.logoutTime > max then
                max = v.logoutTime
                key = k
            end
        end
        if key == "" or self._serverList[tostring(key)] == nil then
            -- 没有上次登录的记录, 默认最新的服务器
            if #recommendArray > 0 then
                local info = recommendArray[math.random(#recommendArray)]
                local key = info.id
                GameStatic.ipAddress = info.ws.. "/"
                GameStatic.server_start_date = info.server_start_date
                GameStatic.sec = info.id
                GameStatic.serverName = info.name
                self:setServerName(info)
                self:setServerStatePic(info)
                self._lastServerId = key  
            else
                self._serverTitle:setString("无可用服务器") 
                self._serverTitle:setScale(1)
                self._state:setVisible(false)       
                self._loginBtn:setTouchEnabled(false)
            end
        else
            GameStatic.ipAddress = self._serverList[key].ws.. "/"
            GameStatic.server_start_date = self._serverList[key].server_start_date
            GameStatic.sec = key
            GameStatic.serverName = self._serverList[key].name
            self:setServerName(self._serverList[key])
            self:setServerStatePic(self._serverList[key])

            self._lastServerId = key
        end
    else
        -- 没有上次登录的记录, 默认最新的服务器
        if #recommendArray > 0 then
            local info = recommendArray[math.random(#recommendArray)]
            local key = info.id
            GameStatic.ipAddress = info.ws.. "/"
            GameStatic.server_start_date = info.server_start_date
            GameStatic.sec = info.id
            GameStatic.serverName = info.name
            self:setServerName(info)
            self:setServerStatePic(info)
            self._lastServerId = key
        else
            self._serverTitle:setString("无可用服务器")    
            self._serverTitle:setScale(1)
            self._state:setVisible(false)
            self._loginBtn:setTouchEnabled(false)
        end
    end

    self._selectServerCallback = function (id)
        self._lastServerId = id
        GameStatic.sec = self._serverList[id].id
        GameStatic.serverName = self._serverList[id].name
        self:setServerName(self._serverList[id])
        self:setServerStatePic(self._serverList[id])
        self:saveLocalData("LAST_LOGIN",id)
        self._bg:setVisible(true)
        GameStatic.ipAddress = self._serverList[id].ws.. "/"
        GameStatic.server_start_date = self._serverList[id].server_start_date
    end
    print(GameStatic.serverName)
end

-- 平台登录成功
function LoginView:_platformLoginSuccess()
    if self._platformLoginInv > 0 then
         self._platformLoginInv = 0
         SystemUtils.saveGlobalLocalData("L_platformLoginInv", 0)
         self._canPlatformLoginTime = 0
         SystemUtils.saveGlobalLocalData("L_canPlatformLoginTime", 0)
    end
    self._PLFailedInfo = {}
    sdkMgr:showJGLauncher() -- 切换账号重设JGLaunchoer
end

local INV_LOGIN_FAILED_3 = 10
local INV_LOGIN_FAILED_6 = 300
-- 平台登录失败
function LoginView:_platformLoginFailed()
    if #self._PLFailedInfo >= 5 then
        if self._platformLoginInv < INV_LOGIN_FAILED_6 then
            self._platformLoginInv = INV_LOGIN_FAILED_6
            SystemUtils.saveGlobalLocalData("L_platformLoginInv", INV_LOGIN_FAILED_6)
        end
    elseif #self._PLFailedInfo >= 2 then
        self._PLFailedInfo[#self._PLFailedInfo + 1] = os.time()
        if self._platformLoginInv < INV_LOGIN_FAILED_3 then
            self._viewMgr:showTip("登录频繁请稍后尝试")
            self._platformLoginInv = INV_LOGIN_FAILED_3
            SystemUtils.saveGlobalLocalData("L_platformLoginInv", INV_LOGIN_FAILED_3)
        end
    else
        self._PLFailedInfo[#self._PLFailedInfo + 1] = os.time()
    end
    self._canPlatformLoginTime = os.time() + self._platformLoginInv
    if self._platformLoginInv > 0 then
        SystemUtils.saveGlobalLocalData("L_canPlatformLoginTime", self._canPlatformLoginTime)
        self:_disablePlatformLogin()
    end
end

-- 登录成功
function LoginView:_loginSuccess()
    if self._loginInv > 0 then
        self._loginInv = 0
        SystemUtils.saveGlobalLocalData("L_loginInv", 0)
        self._canLoginTime = 0
        SystemUtils.saveGlobalLocalData("L_canLoginTime", 0)
    end
    self._LFailedInfo = {}
end
-- 登录失败
function LoginView:_loginFailed()
    if #self._LFailedInfo >= 5 then
        if self._loginInv < INV_LOGIN_FAILED_6 then
            self._loginInv = INV_LOGIN_FAILED_6
            SystemUtils.saveGlobalLocalData("L_loginInv", INV_LOGIN_FAILED_6)
        end
    elseif #self._LFailedInfo >= 2 then
        self._LFailedInfo[#self._LFailedInfo + 1] = os.time()
        if self._loginInv < INV_LOGIN_FAILED_3 then
            self._viewMgr:showTip("登录频繁请稍后尝试")
            self._loginInv = INV_LOGIN_FAILED_3
            SystemUtils.saveGlobalLocalData("L_loginInv", INV_LOGIN_FAILED_3)
        end
    else
        self._LFailedInfo[#self._LFailedInfo + 1] = os.time()
    end
    self._canLoginTime = os.time() + self._loginInv
    if self._loginInv > 0 then
        SystemUtils.saveGlobalLocalData("L_canLoginTime", self._canLoginTime)
        self:_disableLogin()
    end
end

-- 登出
function LoginView:logout()
    if not GameStatic.enableSDK then
        self._viewMgr:restart()
    else
        sdkMgr:hideJGLauncher()
        sdkMgr:logout({}, function(code, data)
            code = tonumber(code)
            if code == sdkMgr.SDK_STATE.SDK_LOGOUT_SUCCESS then
                self._viewMgr:restart()
            elseif code == sdkMgr.SDK_STATE.SDK_LOGOUT_FAIL then
                self._viewMgr:restart()
            end
        end)
    end
end

-- 登录
function LoginView:login()
    if not self._xieyiSelect:isVisible() then
        self._viewMgr:showTip("请勾选同意下方的服务协议，即可进入游戏！")
        return
    end
    -- 判断是否禁止登录中
    if not self._loginBtn:isScaleAnim() then
        local sec = self._canLoginTime - os.time()
        if sec < 1 then
            sec = 1
        end
        self._viewMgr:showTip("登录过于频繁，请在"..sec.."秒后重新尝试登录")
        return
    end
    -- 判断是否在维护中
    if self._is_white ~= 1 and self._maintain then
        self:updateServerState(function ()
            if self._maintain then
                self._viewMgr:showTip("服务器维护中，请稍后重试")
                self._canLoginTime = os.time() + 4
            else
                self:login()
            end
        end)
        return
    end
    -- 判断网络是否连通
    if not OS_IS_WINDOWS and AppInformation:getInstance():getNetworkType() == 1 then
        self:showErrorMsg("网络未连通，请稍后重试")
        return
    end
    -- iosdemo
    local configMgr = kakura.Config:getInstance()
    if self._serverList[self._lastServerId] ~= nil then
        local version = self._serverList[self._lastServerId]["version"]
        -- 开发版本不处理灰度
        if configMgr:getValue("APP_BUILD_NUM") ~= "" then
            local upgradePath = version[configMgr:getValue("UPGRADE_PATH")]
            if upgradePath == nil then
                self:showErrorMsg("数据不匹配", 6663002, function ()
                    self._viewMgr:restart() 
                end)
                return
            end
            -- walle灰度特殊处理
            if configMgr:getValue("APP_BUILD_NUM") ~= upgradePath.version then
                local appinfoMgr = AppInformation:getInstance()
                appinfoMgr:setValue("vmsTargetVersion", upgradePath.version)
                self:showErrorMsg("版本号变更", 6663003, function ()
                    self._viewMgr:restart() 
                end)
                return
            end
        end
    end

    local walleVersion = 0.1
    if configMgr:getValue("APP_BUILD_NUM") ~= "" then 
        walleVersion = configMgr:getValue("APP_BUILD_NUM")
    end
    local walleUpgrade = "iosdemo"
    if configMgr:getValue("UPGRADE_PATH") ~= "" then 
        walleUpgrade = configMgr:getValue("UPGRADE_PATH")
    end
    
    -- walleUpgrade = "gvg"
    -- walleUpgrade = "celebrity"


    self._viewMgr:lock(2000)
    self._serverMgr:setVer(walleVersion)
    self._serverMgr:setUpgrade(walleUpgrade)
    self._serverMgr:setPushEnabled(false)
    self._serverMgr:initSocket(function ()
        ApiUtils.playcrab_device_monitor_action("initSocket")
        self._viewMgr:unlock()
        local param = {
                sec = GameStatic.sec, 
                gs_token = self._token,
                account_id = self._account_id,
                account_name = self._accountName,
                ver = walleVersion,
                upgrade = walleUpgrade,
                deviceId = ApiUtils.getDeviceID(),
                pGroup = GameStatic.userSimpleChannel,
            }
        -- 利用game.conf设定方便快速登录
        if OS_IS_WINDOWS then
            local superTlsEnter = self._configMgr:getValue("SERVER_NAME", "")
            if superTlsEnter ~= "" then 
                param.tlsEnter = pc.PCTools:md5(superTlsEnter .. GameStatic.userSimpleChannel)
            end
        end    
        self._serverMgr:sendMsg("UserServer", "login", param, true, {}, 
        function(result)
            ApiUtils.playcrab_device_monitor_action("loginSuccess")
            self:_loginSuccess()
            self:logined()
            ApiUtils.gsdkSetEvent({tag = "6", status = "true", msg = GameStatic.sec})
        end,
        function (error, msg,replaceMsg)
            if error then
                local _state = error
                if _state == nil then
                    _state = "null"
                end
                if msg and msg ~= "" then
                    self:_loginFailed()
                    -- 登录时加判断是否是防沉迷
                    if error == 145 then
                        dump(replaceMsg or {})
                        local status = tonumber(replaceMsg["status"]) or 3
                        local totalTime = replaceMsg and replaceMsg["t"] or 0
                        local awake = replaceMsg and replaceMsg["a"] or 0
                        local isAdult = replaceMsg and tonumber(replaceMsg["is_adult"]) or 0
                        local notRest = status == 3 and isAdult == 0
                        local indugeMsg = lang("JIANKANGXITONG_6") or ""
                        -- if notRest then
                        --     indugeMsg = lang("JIANKANGXITONG_4") or ""
                        -- end
                        -- 加未成年人 宵禁和累积N小时不玩
                        if isAdult == 0 then
                            if status == 5 then
                                indugeMsg = lang("JIANKANGXITONG_7")
                            elseif status == 6 then
                                indugeMsg = lang("JIANKANGXITONG_5")
                            end
                        end
                        local indulgeTab = require("indulge")
                        indugeMsg = string.gsub(indugeMsg,"%b{}",function( catchStr )
                            local result = string.gsub(catchStr,"{","")
                            result = string.gsub(result,"}","")
                            local timeStr = ""
                            if status == 6 and isAdult == 0 then
                                timeStr = math.floor(totalTime/1800)/2
                            -- elseif notRest then
                            --     timeStr = indulgeTab["PROHIBITEDIME_TYPE1"] 
                            --                 and indulgeTab["PROHIBITEDIME_TYPE1"].value 
                            --                 and indulgeTab["PROHIBITEDIME_TYPE1"].value[1] or 0
                            --     timeStr = math.floor(timeStr/1800)/2
                            else
                                local nextSec = awake
                                local nextTime = self._modelMgr:getModel("UserModel"):getCurServerTime()+nextSec
                                nextTime = nextTime-nextTime%60
                                timeStr = TimeUtils.getDateString(nextTime)
                            end
                            result = string.gsub(result,"$time",timeStr or 0)
                            return result
                        end)
                        self:showErrorMsg(indugeMsg, "6663009.".._state,function( )
                            AppExit()
                        end)
                    else
                        self:showErrorMsg(msg, "6663009.".._state)
                    end
                else
                    self:_loginFailed()
                    self:showErrorMsg("连接服务器失败，请稍候尝试", "6663005", nil, serialize({errorCode = error, msg = msg}), 
                        function () end, function ()
                            CustomServiceUtils.loginFailed()
                        end, nil, "关闭", "帮助")
                end
                ApiUtils.gsdkSetEvent({tag = "6", status = "false", msg = tostring(_state)})
                self._serverMgr:clear()
            end
        end, false, function ()
            self:_loginFailed()
            self._serverMgr:clear()      
            self._viewMgr:showTip("服务器连接超时，请稍后尝试")
        end) 
    end, function (errorCode)
        ApiUtils.gsdkSetEvent({tag = "6", status = "false", msg = tostring(errorCode)})
        self:_loginFailed()
        self:showErrorMsg("连接服务器失败，请稍候尝试", 6663006, nil, serialize({errorCode = errorCode, url = GameStatic.ipAddress}), 
        function () end, function ()
            CustomServiceUtils.loginFailed()
        end, nil, "关闭", "帮助")
        if GameStatic.useGetIP then
            GameStatic.useGetIP = false
            ApiUtils.getPublicIP(function (state, response)
                if response and response ~= "" then
                    ApiUtils.playcrab_lua_error("errorCode_6663006", response, "code")
                end
            end)
        end
        self:updateServerState()
    end)
end

function LoginView:logined()
    local _network = 0
    local _netType = AppInformation:getInstance():getNetworkType()
    if _netType == 2 then
        _network = 2
    elseif _netType == 3 then
        _network = 1
    end
    self._serverMgr:sendMsg("UserServer", "logined", {network = _network}, true, {}, 
    function(data)
        dump(data)
        -- data["constList"] -- todo
        -- 如有其他需要处理建议移到usermodel中统一处理，注意此时还没有usermodel的data数据
        if data["constList"] ~= nil then
            ModelManager:getInstance():getModel("UserModel"):handleConstList(data["constList"])
        end
        if data["ret"] == 0 then
            -- 新号
            self:init()
        elseif data["ret"] == 1 then
            self:enterGame(false)
        end
    end,
    function (error)
        if error then
            self:_loginFailed()
            local _state = error
            if _state == nil then
                _state = "null"
            end
            self:showErrorMsg("登录失败，请稍候尝试", "6663007."..tostring(_state))
            self._serverMgr:clear()
        end
    end)    
end

function LoginView:init()
    -- 新号 新手引导初始化成1, 并且跟随init协议一起发送
    GuideUtils.saveIndex(1)
    local _network = 0
    local _netType = AppInformation:getInstance():getNetworkType()
    if _netType == 2 then
        _network = 2
    elseif _netType == 3 then
        _network = 1
    end
    local deviceInfo = self:getDeviceInfo()
    self._serverMgr:sendMsg("UserServer", "init", {network = _network,logParams = deviceInfo}, true, {}, 
    function(data)
        self:enterGame(true)
    end,
    function (error)
        if error then
            self:_loginFailed()
            local _state = error
            if _state == nil then
                _state = "null"
            end
            self:showErrorMsg("登录失败，请稍候尝试", "6663008."..tostring(_state))
            self._serverMgr:clear()
        end
    end)  
end

--获取设备信息
function LoginView:getDeviceInfo()
    local deviceInfo = ApiUtils.getDeviceInfo()
    local glview = cc.Director:getInstance():getOpenGLView()
    local sys_version = ""                                         --系统版本号
    local sys_model = ""                                           --机型 
    if deviceInfo and type(deviceInfo) == "table" then
        sys_version = deviceInfo["os_version"]          
        sys_model = deviceInfo["model"]                 
    end
    local screenWidth = glview:getFrameSize().width                    --屏幕宽度
    local screenHeight = glview:getFrameSize().height                  --屏幕高度  
    local dpi = cc.Device:getDPI() or 0                              --像素密度

    local glRender,glVersion = "",""
    local openGLInfo = pc.PCTools:getOpenGLInfo()
    local getGlValue = function(keyValue)
        local maxLength = 10000
        local pos1 = string.find(openGLInfo,keyValue)
        local string1 = string.sub(openGLInfo,pos1 +  string.len(keyValue),maxLength)
        local pos2 = string.find(string1,"\n")
        local string2 = string.sub(string1,0,pos2 - 1)
        return string2
    end
    glRender = getGlValue("gl.version:") or ""                      --glRender信息
    glVersion = getGlValue("gl.renderer") or ""                     --glVersion信息
    local deviceInfoTable = {
        ["SystemSoftware"] =  sys_version,
        ["SystemHardware"] =  sys_model,
        ["ScreenWidth"] =  screenWidth,
        ["ScreenHeight"] =  screenHeight,
        ["Density"] =  dpi,
        ["GLRender"] =  glRender,
        ["GLVersion"] =  glVersion
    }
    return json.encode(deviceInfoTable)
end
-- 1 texture
-- 2 plist
-- 3 send
-- 4 mc
-- 5 sf
-- 6 table
-- 8 voice

-- 小旗子
local isJieRi = GameStatic.mainViewJieRi
if isJieRi == nil then
    isJieRi = true
end
-- 中秋节
local isJieRi2 = GameStatic.mainViewJieRi2
if isJieRi2 == nil then
    isJieRi2 = true
end
-- 圣诞节
local isJieRi3 = GameStatic.mainViewJieRi3
if isJieRi3 == nil then
    isJieRi3 = true
end
function LoginView:enterGame(newAccount)
    ApiUtils.playcrab_device_monitor_action("beginloading")
    mcMgr:retain("mainviewuianim")
    mcMgr:retain("firstrechargeanim")

    TimeUtils.reCalculateMainViewTimeType()
    local bgNameExt = ""
    if TimeUtils.mainViewVer == 1 then
        bgNameExt = ""
    else
        bgNameExt = tostring(TimeUtils.mainViewVer)
    end
    local loadingList = 
    {
        {6}, -- table
        {4, "firstrechargeanim"},
        {4, "mainviewcoin"},
        {2, {"asset/ui/mainView.plist", "asset/ui/mainView.png"}},
        {2, {"asset/ui/mainView2.plist", "asset/ui/mainView2.png"}},
        {2, {"asset/ui/mainView3.plist", "asset/ui/mainView3.png"}},
        {2, {"asset/ui/mainView-HD.plist", "asset/ui/mainView-HD.png"}},
        {2, {"asset/bg/mainViewBg"..bgNameExt..".plist", "asset/bg/mainViewBg"..bgNameExt..".png"}},
        {8, {}}, -- voice
        {3, {"UserServer", "getPlayerAction"}},
        {3, {"TaskServer", "getTask", "Task"}},
        {3, {"ArenaServer", "enterArena", "Arena"}},-- by guojun 2016.08.24 change by 2017.1.3  
        {3, {"MailServer", "getMails", "Mail"}},
        {3, {"PrivilegesServer", "getPrivilegeInfo", "Privilege"}}, -- "Privilege"}},
        {3, {"PokedexServer", "getPokedexInfo", "Pokedex"}},
        {3, {"PokedexServer", "getPFormation", "Pokedex"}},
        {3, {"BossServer", "getBossInfo", "DwarvenTreasury"}},
        {3, {"TreasureServer", "getTreasure","Treasure"}},
        {3, {"SignServer", "getSignInfo", "sign"}},
        {3, {"MFServer", "getMFInfo", "MF"}},
        {3, {"GodWarServer", "getJoinList", "GodWar"}},
        {3, {"BackFlowServer", "getBackFlowInfo", "BackFlow"}},
        {3, {"GlobalServer", "getAll"}},
        -- add by wangyan 增加网络请求参数，设定为第四个属性
        {3, {"GameFriendServer", "getBlackList", "GameFriend"}},  --黑名单优先于聊天获取,请勿动请求顺序
        {3, {"ChatServer", "getMessage", nil, {type="pri"} }},
        {3, {"ChatServer", "getMessage", nil, {type="guild"} }},
        {3, {"ChatServer", "getMessage", nil, {type="all"} }},
        {3, {"GameFriendServer", "getGameFriendList", "GameFriend"}},
        {3, {"GameFriendServer", "getApplyList", "GameFriend"}},
        {3, {"CloudyCityServer", "getCloudyCityInfo", "CloudCity"}},        
        {3, {"TrainingServer", "init", "Training"}},                    --训练所
        {3, {"NoticeServer", "getSysNotice", nil}},     -- 获取循环跑马灯
        {3, {"NoticeServer", "getFlauntNotice", nil}},  -- 获取跑马灯
        {3, {"AvatarsServer", "getAvatarInfo", nil}},   -- 获取头像
        {3, {"HeroDuelServer", "hDuelGetBaseInfo", "HeroDuel"}},
        {3, {"HandbookServer", "getAllTaskInfo", "Handbook"}},
        {3, {"ExtraServer", "getSiegeInfo", nil}},
        {3, {"RecallServer", "getRecallInfo", "FriendShop"}},
    }
    if isJieRi then
        loadingList[#loadingList + 1] = {2, {"asset/anim/donghuaflaimage.plist", "asset/anim/donghuaflaimage.png"}}
        loadingList[#loadingList + 1] = {2, {"asset/anim/qiziimage.plist", "asset/anim/qiziimage.png"}}
    end
    if isJieRi2 then
        loadingList[#loadingList + 1] = {2, {"asset/ui/zhongqiujie.plist", "asset/ui/zhongqiujie.png"}}
    end
    if isJieRi3 then
        loadingList[#loadingList + 1] = {2, {"asset/ui/shengdanjie.plist", "asset/ui/shengdanjie.png"}}
    end
    self._loadingView = self:createLayer("global.LoadingView", {type = 0, title = "正在进入游戏 ... "})
    self:getLayerNode():addChild(self._loadingView)
    self._loadingView:reflashUI({progress = 0})
    audioMgr:playMusic("loading", true)
    sdkMgr:hideJGLauncher()
    self._loadingView:loadStart(loadingList, function ()
        local pid = ModelManager:getInstance():getModel("UserModel"):getData().pid
        if ApiUtils.gsdkSetUserName then ApiUtils.gsdkSetUserName({openId = pid}) end
        SRDATAID = pid
        ApiUtils.gsdkSetEvent({tag = "7", status = "true", msg = "success"})
        ApiUtils.playcrab_device_monitor_action("endloading")
        self._serverMgr:tss()

        self._serverMgr:setPushEnabled(true)
        if newAccount then
            -- 1-1/1-2引导不触发
            SystemUtils.saveAccountLocalData("GBHU_1_7100101", 1)
            SystemUtils.saveAccountLocalData("GBHU_5_7100102", 1)
        end
        local triggerData = ModelManager:getInstance():getModel("UserModel"):getData().trigger
        if triggerData then
            print("**********************")
            for k, v in pairs(triggerData) do
                print("TriggerConfig_"..k..": 1")
            end
            print("**********************")
        end
        GuideUtils.firstView = true
        ViewManager:getInstance():updateGuideIndexLabel()
        if GuideUtils.ENABLE then
            local config = GuideUtils.getCurConfig()
            if config and config.beginning then
                if config.beginning ~= "main.MainView" then
                    ViewManager:getInstance():switchView(config.beginning)
                    ViewManager:getInstance():doReleaseRes(true, true, config.beginning)
                    return
                else
                    ViewManager:getInstance():switchView("main.MainView")
                    ViewManager:getInstance():doReleaseRes(true, true, "main.MainView")
                    return
                end
            end
        end
        -- 走到这里说明进入界面没有强制引导了
        GuideUtils.firstView = false
        ViewManager:getInstance():switchView("main.MainView", {showAd = true})
        ViewManager:getInstance():doReleaseRes(true, true, "main.MainView")
        sfResMgr:clear(true)
        mcMgr:clear(true)
    end)
end

function LoginView:onError()
    self:unlock()
end

function LoginView:isAsyncRes()
    return false
end

function LoginView:isReleaseTextureOnPop()
    return false
end

function LoginView:setNoticeBar()
    self._viewMgr:hideNotice()
end

function LoginView.dtor()
    httpManager = nil
    EFF_DEBUG = nil
    INV_LOGIN_FAILED_3 = nil
    INV_LOGIN_FAILED_6 = nil
    sfc = nil
    tc = nil
    LoginView = nil
end
return LoginView
