--[[
    Filename:    VideoView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-03-16 20:43:31
    Description: File description
--]]

local VideoView = class("VideoView", BaseView)

function VideoView:ctor(data)
    VideoView.super.ctor(self)
    if data then
        self._runType = data.runType
        -- 1 为第一段
        -- 2 为第二段
        -- 3 为第三段
        -- 4 为重播
    end
    if self._runType == nil then
        self._runType = 4
    end
    self.dontAdoptIphoneX = true
end

function VideoView:onInit()
    audioMgr:stopMusic()
	self:videoBegin()
    self.noSound = true
    ApiUtils.playcrab_device_monitor_action("cgbegin")
end

function VideoView:onDestroy()
    self._btn2 = nil
    ScheduleMgr:cleanMyselfDelayCall()
    VideoView.super.onDestroy(self)
end

function VideoView:videoBegin()
    local btn = ccui.Button:create("globalBtnUI_skip.png", "globalBtnUI_skip.png", "globalBtnUI_skip.png", 1)
    
    btn:setVisible(true)
    btn.noSound = true
    btn:setScaleAnim(false)
    if not OS_IS_WINDOWS then
        btn:setOpacity(0)
    end
    --1280 720 1.77777
    local _scale = 4
    local w, h = btn:getContentSize().width, btn:getContentSize().height
    if MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT >= 1.77777 then
        local scale = MAX_SCREEN_HEIGHT / 720
        btn:setScale(93 / w * scale * _scale, 41 / h * scale * _scale)
        btn:setPosition(MAX_SCREEN_WIDTH - 76 * scale - (MAX_SCREEN_WIDTH - 1280 * scale) * 0.5, MAX_SCREEN_HEIGHT - 48 * scale)
    else
        local scale = MAX_SCREEN_WIDTH / 1280
        btn:setScale(93 / w * scale * _scale, 41 / h * scale * _scale)
        btn:setPosition(MAX_SCREEN_WIDTH - 76 * scale, MAX_SCREEN_HEIGHT - 48 * scale - (MAX_SCREEN_HEIGHT - 720 * scale) * 0.5)
    end
    
    self:addChild(btn, 10000)

    if OS_IS_ANDROID then
        local btn2 = ccui.Button:create("globalBtnUI_skip.png", "globalBtnUI_skip.png", "globalBtnUI_skip.png", 1)
        btn2:setPosition(btn:getPosition())
        btn2:setTouchEnabled(false)
        self:addChild(btn2, 10001)
        btn2:setVisible(false)
        self._btn2 = btn2
        ScheduleMgr:delayCall(5000, self, function()
            if self._btn2 then
                self._btn2:setVisible(true)
            end
        end)
    end
    local name1
    if self._runType <= 3 then
        name1 = "asset/other/cg"..self._runType..".mp4"
    else
        name1 = "asset/other/cg1.mp4"
    end
    local name2
    if self._runType == 4 then
        name2 = "asset/other/cg2.mp4"
    end
    if ccexp.VideoPlayer == nil then
        local label = cc.Label:createWithTTF("我是视频"..name1..", 但是并不支持windows, 请自行脑补, 脑补结束之后, 请按skip", UIUtils.ttfName, 20)
        label:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        self:addChild(label)
        self:registerClickEvent(btn, function () 
            self:videoEnd(false)
        end)
    else
        local vp = ccexp.VideoPlayer:create()
        self:addChild(vp)

        local skip = false
        self:registerClickEvent(btn, function () 
            skip = true
            vp:stop()
            btn:setVisible(false)
            vp:removeFromParent()
            self:videoEnd(true)
        end)
        vp:addEventListener(function (_, event)
            if event == 0 then
                
            elseif event == 1 then
                vp:play()
            elseif event >= 2 then
                if not skip then
                    if name2 then
                        local realPath = cc.FileUtils:getInstance():fullPathForFilename(name2)
                        vp:setFileName(realPath)
                        name2 = nil
                        vp:play()
                    else
                        skip = true
                        vp:setVisible(false)
                        btn:setVisible(false)
                        self:videoEnd(false)
                    end
                end
            end
        end)
        vp:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        vp:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        vp:setKeepAspectRatioEnabled(true)
        local realPath = cc.FileUtils:getInstance():fullPathForFilename(name1)
        vp:setFileName(realPath)
        vp:setFullScreenEnabled(false)
        vp:setTouchEnabled(false)
        vp:play()
    end
end

function VideoView:videoEnd(jump)
    if self._btn2 then
        self._btn2:setVisible(false)
        self._btn2 = nil
    end
    ApiUtils.playcrab_device_monitor_action("cgend")
    ScheduleMgr:delayCall(0, self, function()
        if self._runType == 1 then
            -- BattleUtils.enterBattleView_Guide()
            if jump then
                ViewManager:getInstance():popView()
                GuideUtils.unloginGuide()
            else
                ViewManager:getInstance():popView()
                ViewManager:getInstance():switchView("logo.VideoView", {runType = 2})
            end
        elseif self._runType == 2 then
            GuideUtils.unloginGuide()
        elseif self._runType == 3 then
            -- ViewManager:getInstance():switchView("login.LoginView", {})
            -- RestartMgr:restart()
            if BackgroundUp then
                BackgroundUp.deviceGuideOver = true
            end
            ViewManager:getInstance():restart()
        else
            if self._runType == 4 then -- 登录完处理JGLaunchor
                sdkMgr:showJGLauncher()
            end
            ViewManager:getInstance():popView()
        end
    end)
end

return VideoView