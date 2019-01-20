--[[
    Filename:    ViewManager.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-27 18:31:56
    Description: File description
--]]
local ViewManager = class("ViewManager")
local tc = cc.Director:getInstance():getTextureCache()

local _viewManager = nil

-- 超过100M 开始释放内存
local MAX_MEMORY_VALUE = 120
if OS_IS_WINDOWS then
    MAX_MEMORY_VALUE = 1024
end
function ViewManager:getInstance()
    if _viewManager == nil  then 
        _viewManager = ViewManager.new()
        return _viewManager
    end
    return _viewManager
end
--[[
        self._viewLayer用于添加全屏view, 为每一个添加的view生成一个node, node分两层, 一层为view本身, 一层为弹出框, 弹出框基于view存在
        self._navigationLayer用于添加全局导航条,不跟随view的切换变化, 只可以设置显示/隐藏
--]]
--[[
                Z_Click         9000
                    
                hotKey          1100

                debug           1000

                lua_error       999

                indulge         998

                voice           980

                bulletScreens   970       

                lock_mask       900

                noticeLayer     850

                guideLayer      800

                taskLayer       795

                redbox          790

                tipLayer        500 

                hintLayer       200 

                globalDialog    100
                                        
                                        lock_mask   90000
                                        dialogLayer 40000  (BasePopView)
                                        black_mask  30000
                                        layerNode   20000  (BaseLayer)
                                        navigation  10000
                                                            widget 0 (cocostudio)
                                        view  0 (BaseView)
                                node3  0

                                node2  0
                        
                                node1  0
                viewLayer 0
    rootLayer 
--]]
local Z_Navigation = 10000 -- node

local Z_GlobalDialog = 100 -- root
local Z_Hint = 200 -- root
local Z_REDBOX = 790  --root  by wangyan
local Z_TASK = 795  --root
local Z_Guide = 800 -- root
local Z_Tip = 810 -- root
local Z_Other = 820 -- root
local Z_Notice = 850 -- root
local Z_Lock = 900 -- root
local Z_BS = 970 -- root
local Z_Voice = 980 -- root
local Z_Indulge = 998 -- root
local Z_Error = 999 -- root
local Z_Debug = 1000 -- root
local Z_HotKey = 1100 -- root
local Z_Click = 9000 -- root
local Z_BIO = 10000     -- root by hgf

local onGuideLock = onGuideLock
local onGuideUnlock = onGuideUnlock
local getGuideLock = getGuideLock
function ViewManager:ctor()
    -- scene
    self._rootLayer = nil
    -- 全屏界面层
    self._viewLayer = nil
    -- 悬浮信息条层
    self._navigationLayer = nil
    -- 信息提示层
    self._hintLayer = nil
    self._hintCount = 0 -- 用于统计关闭

    -- 全局dialog层
    self._globalDialogLayer = nil

    -- tip层
    self._tipLayer = nil
    -- 红包层
    self._redBoxLayer = nil  --by wangyan
    -- 引导层
    self._guideLayer = nil
    -- 其他层 返回登录全部清除
    self._otherLayer = nil
    -- 广播层
    self._noticeLayer = nil
    -- 语音层
    self._voiceLayer = nil
    -- 弹幕层
    self._bulletScreensLayer = nil

    -- view
    self._views = {}

    -- 悬浮条
    self._navigations = {}

    -- 正在使用中的plist列表
    self._plistList = {}
    -- 可以卸载的plist资源列表
    self._releasePlistList = {}

    -- 正要显示的view
    self._nextShowView = nil
    -- texture管理
    self:textureManager()
    -- 适配超宽屏幕分辨率
    self:screenXOffset()

    self._canShowGiftMoneyTip = nil

    -- 引导暂停，类似lock的计数
    self.__guidePause = 0
    -- 全局弹框
    self.__GDPause = 0
end

function ViewManager:showName(view, name)
    if GuideUtils.DEBUG then
        self._btnName:setString(name)
        local pt = view:convertToWorldSpace(cc.p(0, 0))
        local x, y = pt.x, pt.y
        local w = view:getContentSize().width * view:getScaleX()
        local h = view:getContentSize().height * view:getScaleY()
        -- print(name, x, y, w, h, view:getLocalZOrder())
    end
end

function ViewManager:getRootLayer()
    return self._rootLayer
end

function ViewManager:getOtherLayer()
    return self._otherLayer
end

function ViewManager:getHintLayer()
    return self._hintLayer
end
-- 启动
function ViewManager:startup()

    -- 二维码开启/关闭假引导 然后关闭游戏
    if G_falseGuide then
        if G_falseGuide == 1 then
            GLOBAL_VALUES.falseGuideFlag = true
            self:combinationHotKey_143_77(true)
        elseif G_falseGuide == 0 then
            GLOBAL_VALUES.falseGuideFlag = true
            self:combinationHotKey_143_78(true)
        end   
    end
    self._rootLayer = cc.Scene:create()
    
    cc.Director:getInstance():replaceScene(self._rootLayer)
    

    self:onWinSizeEx()
    self._bgLayer = cc.Node:create()
    self._rootLayer:addChild(self._bgLayer)

    self._viewLayer = cc.Node:create()
    self._rootLayer:addChild(self._viewLayer)

    self._fgLayer = cc.Node:create()
    self._rootLayer:addChild(self._fgLayer)

    self._navigationLayer = cc.Node:create()
    self._navigationLayer:setLocalZOrder(Z_Navigation)
    self._navigationLayer:retain()
    
    self._globalDialogLayer = cc.Node:create()
    self._globalDialogLayer:setLocalZOrder(Z_GlobalDialog)
    self._rootLayer:addChild(self._globalDialogLayer)

    self._hintLayer = cc.Node:create()
    self._hintLayer:setLocalZOrder(Z_Hint)
    self._rootLayer:addChild(self._hintLayer)

    self._tipLayer = cc.Node:create()
    self._tipLayer:setLocalZOrder(Z_Tip)
    self._rootLayer:addChild(self._tipLayer)

    self._redBoxLayer = cc.Node:create()    --by wangyan
    self._redBoxLayer:setLocalZOrder(Z_REDBOX)
    self._rootLayer:addChild(self._redBoxLayer)

    self._taskLayer = cc.Node:create()
    self._taskLayer:setLocalZOrder(Z_TASK)
    self._rootLayer:addChild(self._taskLayer)
    
    self._bioLayer = cc.Node:create()           -- biography Tip byhgf 17.12.18
    self._bioLayer:setLocalZOrder(Z_BIO)
    self._rootLayer:addChild(self._bioLayer) 

    self._otherLayer = cc.Node:create()
    self._otherLayer:setLocalZOrder(Z_Other)
    self._rootLayer:addChild(self._otherLayer)

    self._noticeLayer = cc.Node:create()
    self._noticeLayer:setLocalZOrder(Z_Notice)
    self._rootLayer:addChild(self._noticeLayer)

    self._voiceLayer = cc.Node:create()
    self._voiceLayer:setLocalZOrder(Z_Voice)
    self._rootLayer:addChild(self._voiceLayer)

    self._bulletScreensLayer = cc.Node:create()
    self._bulletScreensLayer:setLocalZOrder(Z_BS)
    self._rootLayer:addChild(self._bulletScreensLayer)

    -- 全局提示框
    self._tipDialog = self:createLayer("global.GlobalTipDialog")
    self._tipLayer:addChild(self._tipDialog)
    
    self._tipDialogEx = self:createLayer("global.GlobalTipDialogEx")
    self._tipLayer:addChild(self._tipDialogEx)

    self._lockMask = ccui.Layout:create()
    self._lockMask:setBackGroundColorOpacity(255)
    self._lockMask:setBackGroundColorType(1)
    self._lockMask:setBackGroundColor(cc.c3b(255,0,0))
    self._lockMask:setContentSize(MAX_SCREEN_WIDTH + 200, MAX_SCREEN_HEIGHT)
    self._lockMask:setTouchEnabled(true)
    self._lockMask:setLocalZOrder(Z_Lock)
    self._lockMask:setOpacity(0)
    self._rootLayer:addChild(self._lockMask)   
    self._lockMask:setVisible(false)

    if GameStatic.showLockDebug then
        local debugColor = ccui.Layout:create()
        debugColor:setBackGroundColorOpacity(255)
        debugColor:setBackGroundColorType(1)
        debugColor:setBackGroundColor(cc.c3b(255,0,0))
        debugColor:setContentSize(100, 2)
        debugColor:setPosition(2, 1)
        self._lockMask:addChild(debugColor)
    end

    -- 锁几次,就需要解锁几次
    self._lockCount = 0


    -- 防沉迷
    self._indulgeLayer = cc.Node:create()
    self._indulgeLayer:setLocalZOrder(Z_Indulge)
    self._rootLayer:addChild(self._indulgeLayer)

    self._errorLayer = cc.Node:create()
    self._errorLayer:setLocalZOrder(Z_Error)
    self._rootLayer:addChild(self._errorLayer)

    if OS_IS_WINDOWS then
        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(function (keyid)
            self:onKeyboardDown(keyid)
        end, cc.Handler.EVENT_KEYBOARD_PRESSED)
        listener:registerScriptHandler(function (keyid)
            self:onKeyboardUp(keyid)
        end, cc.Handler.EVENT_KEYBOARD_RELEASED)
         
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        dispatcher:addEventListenerWithSceneGraphPriority(listener, self._rootLayer)
    end

    self:initGuideLayer()

    if GameStatic.deviceGuideOpen then
        local playVideo
        if OS_IS_ANDROID or OS_IS_IOS then
            playVideo = sdkMgr:getDataFromDevice(GameStatic.deviceGuideKey_Video)
            if playVideo == "" then
                playVideo = nil
            else
                playVideo = tonumber(playVideo)
            end
            playVideo = playVideo or SystemUtils.loadGlobalLocalData(GameStatic.deviceGuideKey_Video)
        else
            playVideo = SystemUtils.loadGlobalLocalData(GameStatic.deviceGuideKey_Video)
        end
        if playVideo == nil or playVideo ~= 1 then
            -- 第一次进游戏 先播放视频, 然后进行未登录新手引导
            sdkMgr:saveDataInDevice(GameStatic.deviceGuideKey_Video, "1")
            SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Video, 1)

            SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Enable, 1)
            SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Index, 1)
            GuideUtils.unloginGuideEnable = true
            GuideUtils.unloginGuideIndex = 0
            self:showView("logo.TextView")
        else
            -- 有可能有玩家删了端，导致getDataFromDevice里面有值而loadGlobalLocalData里面没值，
            -- 一旦getDataFromDevice出问题，loadGlobalLocalData则无法补救，所以这里强制设置一下两个值
            sdkMgr:saveDataInDevice(GameStatic.deviceGuideKey_Video, "1")
            SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Video, 1)

            local unloginGuideEnable = SystemUtils.loadGlobalLocalData(GameStatic.deviceGuideKey_Enable)
            if not unloginGuideEnable or unloginGuideEnable == 0 then
                -- 已经进行过未登录新手引导, 直接到登录界面
                self:showView("login.LoginView")
            else
                GuideUtils.unloginGuideEnable = true
                local unloginGuideIndex = SystemUtils.loadGlobalLocalData(GameStatic.deviceGuideKey_Index)
                if not unloginGuideIndex then unloginGuideIndex = 1 end
                GuideUtils.unloginGuideIndex = unloginGuideIndex
                self:showView("logo.EnterView", {freeRes = true, callback = function ()
                    GuideUtils.unloginGuide()
                end})    
            end
        end
    else
        self:showView("login.LoginView")
    end
    self:onViewChange()

    self:showDebugInfo(GameStatic.showDEBUGInfo)

    -- 全局点击动画
    local listener = cc.EventListenerTouchOneByOne:create()

    listener:registerScriptHandler(function (touch) 
        if not GameStatic.showDEBUGInfo and GameStatic.showClickMc and  GameStatic.setting_ClickEff then
            local x = touch:getLocation().x
            local y = touch:getLocation().y
            if tc:getTextureForKey("asset/anim/shalouimage.png") then
                if self._globalClickMc == nil then
                    self._globalClickMc = mcMgr:createViewMC("click_click-HD", false, true, function ()
                        self._globalClickMc = nil
                    end)
                    self._globalClickMc:setPosition(x, y)
                    self._globalClickLayer:addChild(self._globalClickMc)
                else
                    self._globalClickMc:setPosition(x, y)
                    self._globalClickMc:gotoAndPlay(1)
                    self._globalClickMc:setRotation(math.random(359))
                end
            end
        end
        -- ios关闭全局输入框
        closeGlobalInputBox()
        -- 关闭新手引导prompt
        if self._guidePromptCallback then
            self._guidePromptCallback()
        end
        -- 关闭全局状态码显示
        removeGlobalErrorCodeTip()
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function (touch) 

    end, cc.Handler.EVENT_TOUCH_ENDED)
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    self._globalClickLayer = cc.Layer:create()
    self._rootLayer:addChild(self._globalClickLayer, Z_Click)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._globalClickLayer)

    -- add by wangy
    self._canShowGiftMoneyTip = true

    self._indulgeEnable = true
end

function ViewManager:showDebugInfo(enable)
    if enable then
        if self._memLabel == nil then
            local format = string.format
            self._memLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            self._memLabel:setPosition(2, 88)
            self._memLabel:setAnchorPoint(0, 0)
            self._memLabel:setColor(cc.c3b(255, 255, 255))
            self._memLabel:enableOutline(cc.c4b(0,0,0,255), 1)
            self._rootLayer:addChild(self._memLabel, Z_Debug)

            self._SpriteCountLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            self._SpriteCountLabel:setPosition(150, 2)
            self._SpriteCountLabel:setAnchorPoint(0, 0)
            self._SpriteCountLabel:setColor(cc.c3b(0, 255, 0))
            self._SpriteCountLabel:enableOutline(cc.c4b(0,0,0,255), 1)
            self._rootLayer:addChild(self._SpriteCountLabel, Z_Debug)

            self._socketState = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            self._socketState:setPosition(190, 24)
            self._socketState:setAnchorPoint(0, 0)
            self._socketState:setColor(cc.c3b(0, 255, 255))
            self._socketState:enableOutline(cc.c4b(0,0,0,255), 1)
            self._rootLayer:addChild(self._socketState, Z_Debug)

            self._socketState2 = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
            self._socketState2:setPosition(190, 44)
            self._socketState2:setAnchorPoint(0, 0)
            self._socketState2:setColor(cc.c3b(0, 255, 255))
            self._socketState2:enableOutline(cc.c4b(0,0,0,255), 1)
            self._rootLayer:addChild(self._socketState2, Z_Debug)

            local str = {"none", "connected", "reconnect", "connecting", "reinit"}
            local color = {cc.c3b(255, 255, 255), cc.c3b(0, 255, 0), cc.c3b(255, 128, 128), cc.c3b(0, 255, 255), cc.c3b(255, 255, 0)}
            self._memSchedule = ScheduleMgr:regSchedule(0.001, self, function()
                local state = ServerManager:getInstance():getState()
                self._socketState:setString(ServerManager:getInstance():getSocketCount() .. " " .. str[state])
                self._socketState:setColor(color[state])
                local state2 = ServerManager:getInstance():RS_getState()
                self._socketState2:setString(str[state2])
                self._socketState2:setColor(color[state2])
                self._memLabel:setString(format("LuaMem:%.2fMB", collectgarbage("count") / 1024))
                self._SpriteCountLabel:setString(cc.Sprite:getSpriteCount().."/"..cc.Node:getNodeCount())--.."/"..cc.Ref:getRefCount())
            end)
        end
        self._SpriteCountLabel:setVisible(true)
        self._memLabel:setVisible(true)
        self._socketState:setVisible(true)
        self._socketState2:setVisible(true)
    else
        if self._memLabel then
            self._memLabel:removeFromParent()
            self._memLabel = nil
            self._SpriteCountLabel:removeFromParent()
            self._SpriteCountLabel = nil
            self._socketState:removeFromParent()
            self._socketState = nil
            self._socketState2:removeFromParent()
            self._socketState2 = nil
            ScheduleMgr:unregSchedule(self._memSchedule)
        end
    end
end

local keyDown = {}
-- 组合Key 前面那个按键
local HOTKEY_LABEL
local keyTab = 
{
    {140, "Q", "[1:副本]", "[2:竞技场]", "[3:矮人]", "[4:僵尸]", "[5:攻城战]", "[6:毒龙]", "[7:仙女龙]", "[8:水晶龙]", "[9:云中城]", "[0:远征]"},
    {146, "W", "[1:重复支线引导]", "[2:防沉迷]", "[3:中断引导]", "[4:掉线]", "[5:RS掉线]", "[6:下行丢失]", "[7:上行丢失]", "[8:reauth丢失]", "[9:发完断开]"},
    {128, "E", "[1:色相-]", "[2:色相+]", "[3:饱和度-]", "[4:饱和度+]", "[5:亮度-]", "[6:亮度+]", "[7:对比度-]", "[8:对比度+]"},
    {141, "R", "[1:FPS-]", "[2:FPS+]", "[3:清屏]"},
    {143, "T", "[1:设备引导.开]", "[2:设备引导.关]", "[3:设备引导.1-2]"},
    {148, "Y", "[1:FPS开关]", "[2:战斗debug开关]", "[3:登录解锁]", "[4:右下角时间开关]", "[5:战斗debug显示所有士兵开关]","[6:登录升级序列开关]"},
    {124, "A", "[1:删除本地记录]", "[2:删除本地log]", "[3:删除帐号]", "[4:重启客户端]", "[5:返回主界面]"},
    {142, "S", "[1:打开log文件夹]"},
    {127, "D", "[1:停止战斗]", "[2:恢复战斗]", "[3:结束战斗失败]", "[4:杀死选中的兵团]", "[5:是否保存复盘数据]", "[6:显示攻击范围]", "[7:GM指令]"},
}
function ViewManager:onKeyboardDown(keyid)
    if isInputBoxEnable and isInputBoxEnable() then return end
    self:printKeyid(keyid)
    if self["hotKey_"..keyid] then
        self["hotKey_"..keyid](self)
        return
    end

    if keyid == 59 then--空格 
        if HOTKEY_LABEL == nil then
            -- 主菜单
            local str = "组合快捷键大全"
            for i = 1, #keyTab do
                if keyTab[i][2] ~= "" then
                    str = str .. "\n[" .. keyTab[i][2] .. "] +"
                    for k = 3, 12 do
                        if keyTab[i][k] == nil then break end
                        str = str .. " " .. keyTab[i][k]
                    end
                end
            end
            HOTKEY_LABEL = cc.Label:createWithTTF(str, UIUtils.ttfName, 20)
            HOTKEY_LABEL:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
            

            local mask = ccui.Layout:create()
            mask:setBackGroundColorOpacity(255)
            mask:setBackGroundColorType(1)
            mask:setBackGroundColor(cc.c3b(0,0,0))
            mask:setContentSize(HOTKEY_LABEL:getContentSize().width, HOTKEY_LABEL:getContentSize().height)
            mask:setOpacity(180)
            mask:setAnchorPoint(0.5, 0.5)
            mask:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
            self._rootLayer:addChild(mask, Z_HotKey - 2)  
            self._rootLayer:addChild(HOTKEY_LABEL, Z_HotKey - 1)
            HOTKEY_LABEL.mask = mask
        else
            HOTKEY_LABEL.mask:removeFromParent()
            HOTKEY_LABEL:removeFromParent()  
            HOTKEY_LABEL = nil
        end
    elseif keyid == 38 then
        -- pageup
        print("SHOW_UI_DETAILS   ON")
        SHOW_UI_DETAILS = true
    elseif keyid == 36 then
        -- home
        BATTLE_DEBUG_MAX_SPEED = true
    end
    if keyDown == nil then return end
    keyDown[keyid] = true


    for i = 1, #keyTab do
        if keyDown[keyTab[i][1]] then
            if self._hotkey_baseKey ~= keyTab[i][1] then
                self._hotkey_baseKey = keyTab[i][1]
                self:hotkey_base_extend(i)
            end
            break
        end
    end
    if self._hotkey_sp then
        local index = keyid - 76
        if index == 0 then index = 10 end
        local label = self._hotkey_sp.labels[index]
        if label then
            label:setColor(cc.c3b(0, 255, 255))
            label:stopAllActions()
            label:runAction(cc.ScaleTo:create(0.02, 1.05))
        end
    end
    -- "hero_skill_bg2_forma.png"
end

function ViewManager:onKeyboardUp(keyid)
    if isInputBoxEnable and isInputBoxEnable() then return end

    -- if not self:isViewChanging() then
        if self["viewHotKey_"..keyid] then
            self["viewHotKey_"..keyid](self)
            return
        end
        if keyTab == nil then return end
        for i = 1, #keyTab do
            if keyDown[keyTab[i][1]] then
                if self["combinationHotKey_"..keyTab[i][1].."_"..keyid] then
                    self["combinationHotKey_"..keyTab[i][1].."_"..keyid](self)
                    if self._hotkey_sp then
                        local index = keyid - 76
                        if index == 0 then index = 10 end
                        local label = self._hotkey_sp.labels[index]
                        if label then
                            label:setColor(cc.c3b(255, 255, 255))
                            label:stopAllActions()
                            label:setScale(1.0)
                        end
                    end
                    return
                end
            end
        end
    -- end
    if keyid == 38 then
        -- pageup
        print("SHOW_UI_DETAILS   OFF")
        SHOW_UI_DETAILS = nil
    elseif keyid == 36 then
        -- home
        BATTLE_DEBUG_MAX_SPEED = nil
    end
    if keyDown then 
        if self._hotkey_baseKey == keyid then
            self._hotkey_baseKey = nil
            self:hotkey_base_antiextend()
        end
        keyDown[keyid] = nil 
    end
end

function ViewManager:hotkey_base_extend(keyTabIndex)
    local data = keyTab[keyTabIndex]
    if self._hotkey_sp then
        self._hotkey_sp:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0), cc.RemoveSelf:create(true)))
        self._hotkey_sp = nil
    end
    local sp = cc.Sprite:createWithSpriteFrameName("hero_skill_bg2_forma.png")
    sp:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)

    local centerX, centerY = sp:getContentSize().width * 0.5, sp:getContentSize().height * 0.5
    local label = cc.Label:createWithTTF(data[2], UIUtils.ttfName, 50)
    label:setPosition(centerX, centerY)
    label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    sp:addChild(label)

    self._rootLayer:addChild(sp, Z_HotKey)
    self._hotkey_sp = sp
    sp:setScale(0)
    sp:runAction(cc.ScaleTo:create(0.05, 1))

    sp.labels = {}
    local count = #data - 2
    local dr = 360 / count
    local r = 90
    for i = 1, count do
        local label = cc.Label:createWithTTF(data[i + 2], UIUtils.ttfName, 24)
        label:setPosition(centerX + 150 * math.cos(r * 3.14 / 180), centerY + 150 * math.sin(r * 3.14 / 180))
        label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        sp:addChild(label)
        sp.labels[i] = label
        r = r - dr
    end
end

function ViewManager:hotkey_base_antiextend()
    if self._hotkey_sp then
        self._hotkey_sp:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0), cc.RemoveSelf:create(true)))
        self._hotkey_sp = nil
    end
end

function ViewManager:onWinSize(width, height)
    local glview = cc.Director:getInstance():getOpenGLView()
    glview:setFrameSize(width, height)
    if glview:getFrameSize().width / glview:getFrameSize().height > 3 / 2 then
        glview:setDesignResolutionSize(960, 640, cc.ResolutionPolicy.FIXED_HEIGHT)
    else
        glview:setDesignResolutionSize(960, 640, cc.ResolutionPolicy.FIXED_WIDTH)
    end
    -- 屏幕分辨率
    MAX_SCREEN_WIDTH = cc.Director:getInstance():getWinSizeInPixels().width
    MAX_SCREEN_HEIGHT = cc.Director:getInstance():getWinSizeInPixels().height
    MAX_SCREEN_REAL_WIDTH, MAX_SCREEN_REAL_HEIGHT = MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT

    if MAX_SCREEN_WIDTH > 1600 then
        MAX_SCREEN_WIDTH = 1600
    end
    SCREEN_X_OFFSET = (MAX_SCREEN_REAL_WIDTH - MAX_SCREEN_WIDTH) * 0.5

    self:setAdoptValue()
    self:onWinSizeEx()

    -- 背景全局缩放比例
    BG_SCALE_WIDTH = MAX_SCREEN_WIDTH / MAX_DESIGN_WIDTH
    BG_SCALE_HEIGHT = MAX_SCREEN_HEIGHT / MAX_DESIGN_HEIGHT
    -- 背景等比缩放比例
    if BG_SCALE_WIDTH > BG_SCALE_HEIGHT then
        BG_SCALE = BG_SCALE_WIDTH
    else
        BG_SCALE = BG_SCALE_HEIGHT
    end
    for i = 1, #self._viewLayer:getChildren() do
        self._viewLayer:getChildren()[i].view:onWinSizeChange()
    end
    for i = 1, #self._navigationLayer:getChildren() do
        self._navigationLayer:getChildren()[i]:onWinSizeChange()
    end
    if self._tipDialog then
        self._tipDialog:onWinSizeChange()
    end
    if self._tipDialogEx then
        self._tipDialogEx:onWinSizeChange()
    end
    self:showTip("win:" .. width .. "×" .. height .. "  ui:" .. MAX_SCREEN_WIDTH .. "×" .. MAX_SCREEN_HEIGHT)
end

function ViewManager:onWinSizeEx()
    if SCREEN_X_OFFSET == 0 then return end
    self._rootLayer:setPositionX(SCREEN_X_OFFSET)
    if self._rootLayer.left then
        self._rootLayer.left:removeFromParent()
        self._rootLayer.left = nil
    end
    if self._rootLayer.right then
        self._rootLayer.right:removeFromParent()
        self._rootLayer.right = nil
    end
    local left = ccui.Layout:create()
    left:setBackGroundColorOpacity(255)
    left:setBackGroundColorType(1)
    left:setBackGroundColor(cc.c3b(0,0,0))
    left:setContentSize(SCREEN_X_OFFSET, MAX_SCREEN_HEIGHT)
    left:setTouchEnabled(true)
    left:setLocalZOrder(99999999)
    left:setPosition(-SCREEN_X_OFFSET, 0)
    self._rootLayer:addChild(left)
    self._rootLayer.left = left
    local leftBar = self._oldSprite_create(cc.Sprite,"asset/bg/screen_width_bar.jpg")
    leftBar:setAnchorPoint(1,0.5)
    leftBar:setPosition(SCREEN_X_OFFSET,MAX_SCREEN_HEIGHT/2)
    leftBar:setFlipX(true)
    local barWidth = leftBar:getContentSize().width 
    local barHeight = leftBar:getContentSize().height
    if MAX_SCREEN_REAL_HEIGHT > barHeight then
        local scale = MAX_SCREEN_REAL_HEIGHT / barHeight
        leftBar:setScale(scale)
    end
    self._rootLayer.left:addChild(leftBar,100)

    local right = ccui.Layout:create()
    right:setBackGroundColorOpacity(255)
    right:setBackGroundColorType(1)
    right:setBackGroundColor(cc.c3b(0,0,0))
    right:setContentSize(SCREEN_X_OFFSET, MAX_SCREEN_HEIGHT)
    right:setTouchEnabled(true)
    right:setLocalZOrder(99999999)
    right:setPosition(MAX_SCREEN_WIDTH, 0)
    self._rootLayer:addChild(right)
    self._rootLayer.right = right
    local rightBar = self._oldSprite_create(cc.Sprite,"asset/bg/screen_width_bar.jpg")
    rightBar:setAnchorPoint(0,0.5)
    rightBar:setPosition(0,MAX_SCREEN_HEIGHT/2)
    local barWidth = rightBar:getContentSize().width 
    local barHeight = rightBar:getContentSize().height
    if MAX_SCREEN_REAL_HEIGHT > barHeight then
        local scale = MAX_SCREEN_REAL_HEIGHT / barHeight
        rightBar:setScale(scale)
    end
    self._rootLayer.right:addChild(rightBar,100)
end
--[[
    参数 isAdjustXMM2:  是否适配小米MAX2
]]
function ViewManager:enableScreenWidthBar()
    if not ADOPT_IPHONEX then return end
    local screen_x_offset = (MAX_SCREEN_REAL_WIDTH - 1136) * 0.5
    if self._rootLayer.left then
        self._rootLayer.left:removeFromParent()
        self._rootLayer.left = nil
    end
    if self._rootLayer.right then
        self._rootLayer.right:removeFromParent()
        self._rootLayer.right = nil
    end
    local left = ccui.Layout:create()
    left:setBackGroundColorOpacity(255)
    left:setBackGroundColorType(1)
    left:setBackGroundColor(cc.c3b(0,0,0))
    left:setContentSize(screen_x_offset, MAX_SCREEN_HEIGHT)
    left:setTouchEnabled(true)
    left:setPosition(0, 0)
    self._rootLayer:addChild(left)
    self._rootLayer.left = left
    local leftBar = self._oldSprite_create(cc.Sprite,"asset/bg/screen_width_bar.jpg")
    leftBar:setAnchorPoint(1,0.5)
    leftBar:setPosition(screen_x_offset,MAX_SCREEN_HEIGHT/2)
    leftBar:setFlipX(true)
    local barWidth = leftBar:getContentSize().width 
    local barHeight = leftBar:getContentSize().height
    if MAX_SCREEN_REAL_HEIGHT > barHeight then
        local scale = MAX_SCREEN_REAL_HEIGHT / barHeight
        leftBar:setScale(scale)
    end
    self._rootLayer.left:addChild(leftBar)

    local right = ccui.Layout:create()
    right:setBackGroundColorOpacity(255)
    right:setBackGroundColorType(1)
    right:setBackGroundColor(cc.c3b(0,0,0))
    right:setContentSize(screen_x_offset, MAX_SCREEN_HEIGHT)
    right:setTouchEnabled(true)
    right:setPosition(MAX_SCREEN_REAL_WIDTH - screen_x_offset, 0)
    self._rootLayer:addChild(right)
    self._rootLayer.right = right
    local rightBar = self._oldSprite_create(cc.Sprite,"asset/bg/screen_width_bar.jpg")
    rightBar:setAnchorPoint(0,0.5)
    rightBar:setPosition(0,MAX_SCREEN_HEIGHT/2)
    local barWidth = rightBar:getContentSize().width 
    local barHeight = rightBar:getContentSize().height
    if MAX_SCREEN_REAL_HEIGHT > barHeight then
        local scale = MAX_SCREEN_REAL_HEIGHT / barHeight
        rightBar:setScale(scale)
    end
    self._rootLayer.right:addChild(rightBar)
end
--设置适配变量值
function ViewManager:setAdoptValue()
    -- iphoneX
    ADOPT_IPHONEX = MAX_SCREEN_WIDTH > 1300
    --适配小米MAX2
    ADOPT_XIAOMIM2 = false
    if MAX_SCREEN_WIDTH >= 1280 and MAX_SCREEN_WIDTH <= 1300 then
        ADOPT_XIAOMIM2 = true
    end
end

function ViewManager:disableScreenWidthBar()
    self:setAdoptValue()
    if not ADOPT_IPHONEX and not ADOPT_XIAOMIM2 then return end
    if self._rootLayer.left then
        self._rootLayer.left:removeFromParent()
        self._rootLayer.left = nil
    end
    if self._rootLayer.right then
        self._rootLayer.right:removeFromParent()
        self._rootLayer.right = nil
    end
end

-- 通过自定义data 刷新view的UI
function ViewManager:reflashUI(name, data)
    if self._views[name] then
        self._views[name].view:reflashUI(data)
    end
end

--check is view loaded
function ViewManager:isViewLoad(name)
    if self._views[name] then
        return true
    end
end

-- 锁定界面2.0 改成锁全局

function ViewManager:showLockMc()
    self:clearLockMc()
    if self._shalouRan == nil then
        self._shalouRan = GRandom(4)
        self._shalouRandomTick = socket.gettime()
    elseif socket.gettime() > self._shalouRandomTick + 1 then
        self._shalouRan = GRandom(4)
        self._shalouRandomTick = socket.gettime()
    end
    if self._lockMask.mc then
        self._lockMask.mc:removeFromParent()
        self._lockMask.mc = nil
    end
    local mc = pc.DisplayNodeFactory:getInstance():createMovieClip("shalou"..self._shalouRan.."_shalou")
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self._lockMask:addChild(mc)
    self._lockMask.mc = mc
    self._lockMask.playMc = true
end

function ViewManager:clearLockMc()
    if self._lockMask.mc then
        self._lockMask.mc:removeFromParent()
        self._lockMask.mc = nil
    end
end

function ViewManager:lock(delay)
    print("lock", self._lockCount, "=>", self._lockCount + 1, delay)
    if self._lockCount == 0 then
        if delay == nil then
            delay = 3000
        end
        self._lockMask:setTouchEnabled(true)
        if not self._pauseLock then
            self._lockMask:setVisible(true)
            -- cc.Director:getInstance():getEventDispatcher():setTouchEventEnabled(false)
        end
        if delay > 0 then
            -- print(delay)
            if delay < 10 then
                self:showLockMc()
            else
                self._lockMask:runAction(cc.Sequence:create(cc.DelayTime:create(delay / 1000), cc.CallFunc:create(function ()
                    self:showLockMc()
                end)))
            end
        end
    else
        -- print(delay)
        if delay then
            if delay < 0 then
                self._lockMask:stopAllActions()
                self:clearLockMc()
                self._lockMask.playMc = false
            elseif not self._lockMask.playMc then
                self._lockMask:stopAllActions()
                if delay < 10 then
                    self:showLockMc()
                else
                    self._lockMask:runAction(cc.Sequence:create(cc.DelayTime:create(delay / 1000), cc.CallFunc:create(function ()
                        self:showLockMc()
                    end)))
                end
            end
        end
    end
    self._lockCount = self._lockCount + 1
end

function ViewManager:unlock(value)
    print("unlock", self._lockCount, "=>", self._lockCount - 1, value)
    self._lockCount = self._lockCount - 1
    if self._lockCount <= 0 then 
        self._lockMask.playMc = false
        self._lockMask:stopAllActions()
        self:clearLockMc()
        self._lockMask:setVisible(false)
        self._lockMask:setTouchEnabled(false)
        if self._lockCount < 0 then
            self._lockCount = 0
            if value then
                print("self._lockCount < 0", value)
                -- self:showTip("self._lockCount < 0, " .. value)
            end
        end
        self._lockCount = 0
        -- cc.Director:getInstance():getEventDispatcher():setTouchEventEnabled(true)
    end
end

function ViewManager:stopLockMc()
    self._lockMask:stopAllActions()
    self:clearLockMc()
    self._lockMask.playMc = false
end

function ViewManager:clearLock()
    self._lockMask:stopAllActions()
    self:clearLockMc()
    self._lockMask:setVisible(false)
    self._lockMask:setTouchEnabled(false)
    self._lockCount = 0 
end

function ViewManager:pauseLock()
    self._pauseLock = true
    self._lockMask:setVisible(false)
    self._lockMask:setTouchEnabled(false)
    -- cc.Director:getInstance():getEventDispatcher():setTouchEventEnabled(true)
end

function ViewManager:resumeLock()
    self._pauseLock = false
    if self._lockCount > 0 then
        self._lockMask:setVisible(true)
        self._lockMask:setTouchEnabled(true)
        -- cc.Director:getInstance():getEventDispatcher():setTouchEventEnabled(false)
        if self._shalouRan == nil then
            self._shalouRan = GRandom(4)
            self._shalouRandomTick = socket.gettime()
        elseif socket.gettime() > self._shalouRandomTick + 1 then
            self._shalouRan = GRandom(4)
            self._shalouRandomTick = socket.gettime()
        end
        if self._lockMask.mc then
            self._lockMask.mc:removeFromParent()
            self._lockMask.mc = nil
        end
        local mc = pc.DisplayNodeFactory:getInstance():createMovieClip("shalou"..self._shalouRan.."_shalou")
        mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        self._lockMask:addChild(mc)
        self._lockMask.mc = mc
    end
end

function ViewManager:onError()
    local count = #self._viewLayer:getChildren()
    local node = self._viewLayer:getChildren()[count]
    node.view:onError()
end

-- 刷新导航条
function ViewManager:reflashNavigationUI(name, data)
    if self._navigations[name] then
        self._navigations[name]:reflashUI(data)
    end
end

function ViewManager:createViewNode(name)
    local viewNode = cc.Layer:create()
    viewNode:retain()
    viewNode.viewname = name
    return viewNode
end

-- 用于标识界面是否在切换中
function ViewManager:viewChangeBegin()
    self._isViewChanging = true
    self:lock(2000)
end

function ViewManager:viewChangeEnd(value)
    self._isViewChanging = false
    self:unlock(value)
    if self._isViewChangeEndCallback then
        self._isViewChangeEndCallback()
        self._isViewChangeEndCallback = nil
    end
end

function ViewManager:isViewChanging()
    return self._isViewChanging
end

function ViewManager:isOnBeforeAdd()
    return self._isOnBeforeAdd
end

function ViewManager:setViewChangeEndCallback(callback)
    self._isViewChangeEndCallback = callback
end

function ViewManager:setViewChangeCallback(callback)
    self._viewChangeCallback = callback
end

function ViewManager:onViewChange()
    if GuideUtils.firstView then
        -- 进游戏第一个界面 特殊规则
        GuideUtils.firstView = false
        self:doFirstViewGuide()
    else
        self:doViewGuide()
    end
    if self._viewChangeCallback then
        self._viewChangeCallback()
        self._viewChangeCallback = nil
    end
end

-- 弹幕相关
-- 通过BulletScreensUtils来调用
function ViewManager:getBulletScreensLayer()
    return self._bulletScreensLayer
end

-- 语音层
-- 通过VoiceUtils来调用
function ViewManager:getVoiceLayer()
    return self._voiceLayer
end

-- 关闭当前view
function ViewManager:closeCurView(noAnim)
    self:closeHintView()
    if #self._viewLayer:getChildren() > 1 then
        self._viewLayer:getChildren()[#self._viewLayer:getChildren()].view:close(noAnim)
    end
end

function ViewManager:checkViewOpen(name)
    local systemClose = GameStatic.systemClose
    if systemClose == nil or systemClose == "" then return true end
    local list = string.split(systemClose, ":")
    for i = 1, #list do
        if name == list[i] then
            self:showTip(GameStatic.closeTip)
            return false
        end
    end
    return true
end

function ViewManager:showView(name, params, forceSync)
    if not self:checkViewOpen(name) then return end
    if self._disableChangeView then return end
    self:viewChangeBegin()
    self:closeTip()
    self:_showView(name, params, forceSync)
end
function ViewManager:_showView(name, params, forceSync)
    local changeView = function (showNode, hideNode)
        if not showNode.view.noSound then
            audioMgr:playSound("Popup")
        end
        showNode.view.visible = true
        showNode.view:onShow()
        showNode:setVisible(true)
        if self._navigationLayer:getParent() then
            self._navigationLayer:removeFromParent(false)  
        end
        showNode:addChild(self._navigationLayer)
        showNode.view:setNavigation()
        showNode.view:beforePopAnim()
        showNode.view:onAdd()

        showNode.view:popAnim(function ()
            -- 积分联赛进入界面引导 需要判断时间
            if name == "league.LeagueView" then 
                if not ModelManager:getInstance():getModel("LeagueModel"):isInMidSeasonRestTime() then
                    GuideUtils.checkTriggerByType("view", name)
                    print("进入 ======== 积分联赛引导")
                else
                    print("屏蔽  休息期间 积分联赛引导")
                end
            elseif name == "training.TrainingView" then
                -- 从活动进入 不播放新手引导
                if not ModelManager:getInstance():getModel("TrainingModel"):getIgnoreGuide() then
                    GuideUtils.checkTriggerByType("view", name)
                end
            else
                GuideUtils.checkTriggerByType("view", name)
            end    
            self:onViewChange()
            if showNode.view then
                showNode.view:onAnimEnd()
            end
            self:viewChangeEnd(13)
        end)
        pcall(function ()
            showNode.view:setNoticeBar()
        end)
        showNode.view:setGiftMoneyTip()

        if hideNode then
            local viewname = hideNode.view:getClassName()
            hideNode.view.visible = false
            hideNode.view:onHide()
            print("onHide", viewname)
            hideNode:setVisible(false)
            if hideNode.updateRealVisible then
                hideNode:updateRealVisible(false)
            end
            if viewname == "main.MainView" then
                self:ReleaseRes(viewname, hideNode.view:getReleaseDelay())
                self._viewTexList[viewname] = {}
            end
        end
        showNode.view:onComplete()
    end
    local hideNode = nil
    if self._views[name] == nil then
        local node = self:createViewNode(name)
        self._viewTexList[name] = {}
        if not xpcall(function ()
            node.view = require("game.view."..name).new(params)
        end, __G__TRACKBACK__) then
            -- baseView ctor里面出错
            node:release()
            self._viewTexList[name] = nil
            self:viewChangeEnd(29)
            return
        end
        if name == "battle.BattleView" then
            for k, _node in pairs(self._views) do
                _node.view:enterBattle()
            end
        end
        node.view:setClassName(name)
        self._nextShowView = node.view
        self:doReleaseRes(node.view:isReleaseAllOnShow(), node.view:isReleaseTextureOnShow(), name)

        node:addChild(node.view)
        node.view:addModalLayer()
        pcall(function()
            node.view:hideNoticeBar()
        end)
        node.view:hideGiftMoneyTip()
        -- 多线程加载UI资源
        local async = forceSync
        if async == nil then
            async = node.view:isAsyncRes()
        end
        node.view:initUI(name, not self._switchViewing and async, function (ret)
            self._isOnBeforeAdd = true
            if not trycall("onBeforeAdd", node.view.onBeforeAdd, node.view, function ()
                self._isOnBeforeAdd = false
                self:stopLockMc()
                self._views[name] = node
                local count = #self._viewLayer:getChildren()
                if count > 0 then
                    hideNode = self._viewLayer:getChildren()[count]
                end
                node:setLocalZOrder(count + 1)
                self._viewLayer:addChild(node)
                node:release()

                changeView(node, hideNode, ret == 0)
                if ret ~= 0 then
                    -- ui加载出错
                    self:popView()
                end
            end, function ()

            end) then
                self._isOnBeforeAdd = false
                self:unlock(52)
            end
        end)
    else 
        if name == "battle.BattleView" then
            for k, _node in pairs(self._views) do
                _node.view:enterBattle()
            end
        end
        local count = #self._viewLayer:getChildren()
        local _node = nil
        if count ~= 1 then
            hideNode = self._viewLayer:getChildren()[count]
            local index = 1
            for i = 1, count do
                local node = self._viewLayer:getChildren()[i]
                if node == self._views[name] then
                    print("load class name", name)
                    node:setLocalZOrder(count)
                    _node = node
                else
                    node:setLocalZOrder(index)
                    index = index + 1
                end
            end
        else
            _node = self._views[name]
        end
        self._nextShowView = _node.view
        if self._viewTexList[name] == nil then
            self._viewTexList[name] = {}
        end
        if _node ~= hideNode then
            changeView(_node, hideNode)
        else
            self:viewChangeEnd(14)
        end
    end

end

-- 关闭当前显示的界面
function ViewManager:popView(_, dontOnTop)
    if self._disableChangeView then return end
    local removeNode = self._viewLayer:getChildren()[#self._viewLayer:getChildren()]
    if not removeNode.view.noSound then
        audioMgr:playSound("Close")
    end
    if #self._viewLayer:getChildren() == 1 then
        if self._viewLayer:getChildren()[1].view:getClassName() == "main.MainView" then return end
        self:switchView("main.MainView")
        return
    end
    self:closeTip()
    removeNode.view:beforePop()
    self:viewChangeBegin()

    self:_popView(removeNode, dontOnTop)
    self:onViewChange()
end
function ViewManager:_popView(removeNode, dontOnTop)
    local count = #self._viewLayer:getChildren()
    -- removeNode.view:onHide()
    self._views[removeNode.viewname] = nil
    self._navigationLayer:removeFromParent(false)
    removeNode.view:destroy(true)
    local releaseAll = removeNode.view:isReleaseAllOnPop()
    local isReleaseTextureOnPop = removeNode.view:isReleaseTextureOnPop()
    self._viewLayer:removeChild(removeNode, true)
    self:doReleaseRes(releaseAll, isReleaseTextureOnPop)
    local topNode = self._viewLayer:getChildren()[count - 1]
    ScheduleMgr:delayCall(0, self, function ()
        self:viewChangeEnd(23)
    end)
    if count == 1 then
        return
    end
    self._nextShowView = topNode.view
    local name = topNode.view:getClassName()
    topNode.view:dispatchModelEvent()
    if not dontOnTop then
        topNode.view.visible = true
        topNode.view:onTop()
        if OS_IS_WINDOWS then ApplicationUtils.checkAllSignatureTabs() end
    end
    if self._viewTexList[name] == nil then
        self._viewTexList[name] = {}
    end
    if not dontOnTop then
        topNode:setVisible(true)
        if topNode.updateRealVisible then
            topNode:updateRealVisible(true)
        end
        if self._navigationLayer:getParent() then
            self._navigationLayer:removeFromParent(false)
        end
        topNode:addChild(self._navigationLayer)
        topNode.view:setNavigation()
        pcall(function ()
            topNode.view:setNoticeBar()
        end)
        topNode.view:setGiftMoneyTip()
    end
end

-- 关闭当前页面, 同时打开新的界面
function ViewManager:switchView(name, params, callback)
    if self._disableChangeView then return end
    self._switchViewing = true

    self:viewChangeBegin()
    self:viewChangeBegin()


    self:_popView(self._viewLayer:getChildren()[#self._viewLayer:getChildren()], true)
    self:_showView(name, params)
    self._switchViewing = false
end

function ViewManager:getNavigation(name)
    return self._navigations[name]
end

-- 全局悬浮条, 显示
function ViewManager:showNavigation(name, data, zOrder, w)
    if self._navigations[name] == nil then
        if zOrder == nil then 
            zOrder = 1
        end
        local view = require("game.view."..name).new()
        view:setClassName(name)
        view.visible = true
        self._navigationLayer:addChild(view, zOrder)
        view:initUI(name)
        self._navigations[name] = view
        self._navigations[name]:setOpacity(255)
        self._navigations[name]:setCascadeOpacityEnabled(true, true)
        view:reflashUI(data) --data.isAnim 是否播放特效
    else
        self._navigations[name]:setVisible(true)
        self._navigations[name].visible = true
        self._navigations[name]:setOpacity(255)
        self._navigations[name]:reflashUI(data)
    end
    if w then
        self._navigations[name]:setWidgetContentSize(w, MAX_SCREEN_HEIGHT)
    else
        if ADOPT_IPHONEX then
            self._navigations[name]:setWidgetContentSize(MAX_SCREEN_WIDTH - 120, MAX_SCREEN_HEIGHT)
        else
            self._navigations[name]:setWidgetContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        end
    end
end

-- 隐藏悬浮条
function ViewManager:hideNavigation(name)
    if self._navigations[name] then
        self._navigations[name]:setVisible(false)
        self._navigations[name].visible = false
    end
end

-- 显示广播
function ViewManager:showNotice()
    if self._noticeView == nil then
        local name = "global.GlobalNoticeView"
        local view = require("game.view." .. name).new()
        view:setClassName(name)
        view.visible = true
        self._noticeLayer:addChild(view)
        view:initUI(name)
        self._noticeView = view
        view:reflashUI(nil)
    else
        self._noticeView:setVisible(true)
        self._noticeView.visible = true
        self._noticeView:reflashUI(nil)
    end
end

-- 隐藏广播
function ViewManager:hideNotice(clearState)
    if self._noticeView then
        self._noticeView:setVisible(false)
        self._noticeView.visible = false
        if clearState ~= nil and clearState == true then
            self._noticeView:reflashUI({clearState = true})
        end
    end
end

function ViewManager:showCustomNotice(inView)
    if inView == nil then
        return 
    end

    if self._customNoticeView == nil then
        self._noticeLayer:addChild(inView)
        self._customNoticeView = inView
    else
        if self._customNoticeView:getClassName() ~= inView:getClassName() then
            self:removeCustomNotice()
            self._noticeLayer:addChild(inView)
            self._customNoticeView = inView
        end
    end
    self._customNoticeView.visible = true
    self._customNoticeView:setVisible(true)
end

function ViewManager:hideCustomNotice()
    if self._customNoticeView then
        self._customNoticeView.visible = false
        self._customNoticeView:setVisible(false)
    end
end

function ViewManager:removeCustomNotice()
    if self._customNoticeView then
        self._customNoticeView:destroy()
        self._customNoticeView:removeFromParent()
        self._customNoticeView = nil
    end
end

-- 抢红包弹窗  wangyan
function ViewManager:activeGiftMoneyTip(data, inType)
    if GameStatic.appleExamine == true then
        return
    end
    if self._canShowGiftMoneyTip then
        if inType == "packet1" then     --春节红包活动
            if self._redBoxLayer.springRedLayer == nil then
                local name = "activity.springRed.AcSpringRedPopView"
                local robLayer = require("game.view." .. name).new()
                self._redBoxLayer.springRedLayer = robLayer
                self._redBoxLayer:addChild(robLayer)
            else
                self._redBoxLayer.springRedLayer:refreshUI()
            end

            
        elseif inType == "packet2" then  --红包跑马灯
            if self._redBoxLayer.springNoticeLayer == nil then 
                local name = "activity.springRed.AcSpringRedNoticeView"
                local noticeLayer = require("game.view." .. name).new() 
                self._redBoxLayer.springNoticeLayer = noticeLayer
                self._redBoxLayer:addChild(noticeLayer)
            else
                self._redBoxLayer.springNoticeLayer:refreshUI()
            end

        else                             --联盟红包 / 争霸赛
            if self._redBoxLayer.robLayer == nil then
                local name = "guild.redgift.GuildRedTipLayer"
                local robLayer = require("game.view." .. name).new(data)
                self._redBoxLayer.robLayer = robLayer
                self._redBoxLayer:addChild(robLayer)
            else
                self._redBoxLayer.robLayer:refreshUI()
            end
        end 
        
    end
end

-- 弹出任务完成界面
function ViewManager:taskChangeTip()
    if self._taskLayer.taskLayer == nil then
        local name = "task.AwakingTaskTipView"
        local taskLayer = require("game.view." .. name).new()
        self._taskLayer:addChild(taskLayer)
        taskLayer:setClassName(name)
        taskLayer:initUI(name)
        self._taskLayer.taskLayer = taskLayer
    else
        self._taskLayer.taskLayer:refreshUI()
    end
end

-- 弹出触发传记条件界面 hgf
function ViewManager:biographyChangeTip()     
    if self._bioLayer.bioLayer == nil then
        local name = "hero.HeroBiographyTipView"
        local bioLayer = require("game.view." .. name).new()
        self._bioLayer:addChild(bioLayer)
        bioLayer:setClassName(name)
        bioLayer:initUI(name)
        self._bioLayer.bioLayer = bioLayer
    else
        self._bioLayer.bioLayer:refreshUI()
    end
end

--弹出随机红包界面
function ViewManager:activeRandRedDialog(data)
    if data.gifts then
        DialogUtils.showGiftGet({gifts = data.gifts})
    elseif data.redIdList then
        local count = #self._viewLayer:getChildren()
        local node = self._viewLayer:getChildren()[count]
        node.view:showDialog("guild.dialog.GuildDropRedDialog",data.redIdList,true)
    end
end

function ViewManager:showGiftMoneyTip()
    if not self._canShowGiftMoneyTip then
        self._canShowGiftMoneyTip = true
    end
end

function ViewManager:hideGiftMoneyTip()
    if self._canShowGiftMoneyTip then
        self._canShowGiftMoneyTip = false
    end
end

-- 对话框显示, 只会对当前激活的view操作
-- Async是否多线程载入UI以及他的回调callback
function ViewManager:showDialog(name, data, forceShow, Async, callback, noPop)
    self._lastShowDialogName = name
    local count = #self._viewLayer:getChildren()
    local node = self._viewLayer:getChildren()[count]
    return node.view:showDialog(name, data, forceShow, Async, callback, noPop)
end

function ViewManager:getLastShowDialogName()
    return self._lastShowDialogName
end

function ViewManager:closeDialog(view)
    if view.parentView == self then
        self:closeGlobalDialog(view)
        return
    end
    local count = #self._viewLayer:getChildren()
    local node = self._viewLayer:getChildren()[count]
    node.view:closeDialog(view)
end

-- 全局dialog
-- 不跟随当前baseView而销毁
-- 新手引导和战斗的时候会自动关闭, 并且期间不能弹出
function ViewManager:pauseGlobalDialog()
    self.__GDPause = self.__GDPause + 1
    if self.__GDPause == 1 then
        self:clearGlobalDialog()
    end
end

function ViewManager:resumeGlobalDialog()
    self.__GDPause = self.__GDPause - 1
    if self.__GDPause == 0 then
        
    end
end

function ViewManager:clearGlobalDialog()
    if self.__GDMaskLayer then
        self.__GDMaskLayer:removeFromParent()
        self.__GDMaskLayer = nil
    end
    local pop
    for i = #self._globalDialogLayer:getChildren(), 1, -1 do
        pop = self._globalDialogLayer:getChildren()[i]
        pop:destroy()
    end
    self._globalDialogLayer:removeAllChildren()
end

function ViewManager:showGlobalDialog(name, data, Async, callback, noPop)
    if self.__GDPause > 0 then return end
    local view = require("game.view."..name).new(data)
    if view.isPopView == nil then
        self._viewMgr:showTip(name .. " is not a BasePopView")
        view:destroy()
        return
    end
    view.visible = true
    view.parentView = self

    self:lock(-1)

    view:setClassName(name)
    view:initUI(name, Async, function (ret)
        trycall("reflashUI", view.reflashUI, view, data)
        self._globalDialogLayer:addChild(view)
        view:onShow()
        if not noPop then
            view:doPop(function ()
                self:unlock(43)
                if callback then
                    callback()
                end
            end)
        else
            self:unlock(44)
            if callback then
                callback()
            end
        end
        if ret ~= 0 then
            view:close()
            self:showTip("界面好像出错了")
        end
        return view
    end)
    -- print(#self._globalDialogLayer:getChildren())
    if #self._globalDialogLayer:getChildren() == 1 then
        self.__GDMaskLayer = ccui.Layout:create()
        self.__GDMaskLayer:setBackGroundColorOpacity(255)
        self.__GDMaskLayer:setBackGroundColorType(1)
        self.__GDMaskLayer:setBackGroundColor(cc.c3b(0,0,0))
        self.__GDMaskLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        self.__GDMaskLayer:setOpacity(0)
        self._globalDialogLayer:addChild(self.__GDMaskLayer, -100)
        self.__GDMaskLayer:runAction(cc.FadeTo:create(0.2, 120))
    end

    return view
end

function ViewManager:closeGlobalDialog(view)
    view:destroy()
    view:removeFromParent()
    -- print(#self._globalDialogLayer:getChildren())
    if #self._globalDialogLayer:getChildren() == 1 then
        self.__GDMaskLayer:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), 
            cc.CallFunc:create(function ()
                 self.__GDMaskLayer:removeFromParent()
                 self.__GDMaskLayer = nil
            end)))
    end
end

function ViewManager:createLayer(name, params, async, callback)
    local layer = require("game.view."..name).new(params)
    layer:setClassName(name)
    layer:initUI(name, async, callback)
    return layer
end

function ViewManager:showTip(msg)
    if not msg then return end
    print(msg)
    if self._tipDialog then
        self._tipDialog:showTip(msg)
    end
end

function ViewManager:closeTip()
    if self._tipDialog then
        self._tipDialog:closeTip()
    end
end

function ViewManager:showTipEx(msg)
    if self._tipDialogEx then
        self._tipDialogEx:showTip(msg)
    end
end

function ViewManager:closeTipEx()
    if self._tipDialogEx then
        self._tipDialogEx:closeTip()
    end
end

-- 显示物品hint
function ViewManager:showHintView(name, data, callback)

    if self._hintView == nil then
        local view = require("game.view." .. name).new(data)
        self._hintView = view
        view:initUI(name) 
        view:setClassName(name)   
        self._hintLayer:addChild(view)
        view:onShow()
        view:reflashUI(data)
        if callback then
            callback()
        end
    else
        self._hintView:onShow()
        self._hintView:reflashUI(data)
        self._hintView:setVisible(true)
    end
    --手离开屏幕前是否自动关闭 默认为true
    if data.autoCloseTip ~= nil then
        UIUtils.autoCloseTip = data.autoCloseTip        
    end
    self._hintCount = self._hintCount + 1
    return self._hintView
end

function ViewManager:closeHintView()
    if self._hintView ~= nil and self._hintView:isVisible() then
        self._hintCount = self._hintCount - 1
        if self._hintCount <= 0 then
            self._hintView:setVisible(false)
            -- if OS_IS_WINDOWS then -- 调试用
                self._hintView:removeFromParent()
                self._hintView = nil
            --      -- 移入view中进行不用在这里UIUtils:reloadLuaFile("global.GlobalTipView")
            -- end
        end
    end
end

function ViewManager:showError(errorCode)
    self:unlock(61)
    local count = #self._viewLayer:getChildren()
    local node = self._viewLayer:getChildren()[count]
    return node.view:showDialog("global.GlobalMessageDialog", {desc = lang("ERROR_CODE_" .. errorCode), button = "确定"}, true)
end


function ViewManager:showSelectDialog(desc, btn1name, callback1, btn2name, callback2)
    local count = #self._viewLayer:getChildren()
    local node = self._viewLayer:getChildren()[count]
    return node.view:showDialog("global.GlobalSelectDialog", {desc = desc, button1 = btn1name, callback1 = callback1, 
        button2 = btn2name, callback2 = callback2}, true)
end

function ViewManager:showNotificationDialog(desc)
    local count = #self._viewLayer:getChildren()
    local node = self._viewLayer:getChildren()[count]
    return node.view:showDialog("global.GlobalMessageDialog", {desc = desc}, true)
end

function ViewManager:showSecondConfirmDialog(desc, btn1name, callback1, btn2name, callback2)
	local count = #self._viewLayer:getChildren()
	local node = self._viewLayer:getChildren()[count]
	if OS_IS_WINDOWS then
		UIUtils:reloadLuaFile("global.GlobalSecondConfirmDialog")
	end
	return node.view:showDialog("global.GlobalSecondConfirmDialog", {desc = desc, button1 = btn1name, callback1 = callback1, 
			button2 = btn2name, callback2 = callback2}, true)
end

-- 资源管理 --
local fu = cc.FileUtils:getInstance()
local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
-- 加入卸载列表
function ViewManager:ReleaseRes(viewName, delay)
    -- texture 加入卸载列表
    if self._viewTexList[viewName] then
        local tick = socket.gettime()
        for k, v in pairs(self._viewTexList[viewName]) do
            self._textureList[k] = tick + delay
        end
        self._viewTexList[viewName] = nil
    end
end

function ViewManager:addToPlistList(resList)
    for k, v in pairs(resList) do
        if self._plistList[k] then
            self._plistList[k].count = self._plistList[k].count + 1
        else
            self._plistList[k] = {count = 1, v = v}
        end
        self._releasePlistList[k] = nil
    end
end

function ViewManager:removeFromPlistList(resList, delay)
    for k, v in pairs(resList) do
        if self._plistList[k] then
            self._plistList[k].count = self._plistList[k].count - 1
            if self._plistList[k].count == 0 then
                -- plist加入卸载列表
                self._releasePlistList[k] = {png = self._plistList[k].v, tick = socket.gettime(), delay = delay}
                self._plistList[k] = nil
            end
        end
    end
end

-- 主动释放到期资源
-- 卸载资源
function ViewManager:doReleaseRes(allRelease, releaseTexture, filter)
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
    local tick = socket.gettime()
    if allRelease then
        mcMgr:clear(true)
        sfResMgr:clear(true)
        for plist, v in pairs(self._releasePlistList) do
            if fu:isFileExist(plist) then
                sfc:removeSpriteFramesFromFile(plist)
                tc:removeTextureForKey(v.png)
                -- print("release plist: " .. v.png)
            end
        end
        self._releasePlistList = {}
    else
        for plist, v in pairs(self._releasePlistList) do
            -- 卸载超时资源
            if tick > v.tick + v.delay then
                if fu:isFileExist(plist) then
                    sfc:removeSpriteFramesFromFile(plist)
                    tc:removeTextureForKey(v.png)
                    -- print("release plist: " .. v.png)
                end
                self._releasePlistList[plist] = nil
            end
        end
    end
    -- 卸载texture
    if releaseTexture then
        self:releaseTexture(allRelease, filter)
    end

    local mb1 = SystemUtils.getTotalTextureMBytes()
    if mb1 > MAX_MEMORY_VALUE then
        print("1级释放, force release ========================")
        if not releaseTexture then
            self:releaseTexture(allRelease, filter)
        end
        mcMgr:clear(true)
        sfResMgr:clear(true)
        if not allRelease then
            for plist, v in pairs(self._releasePlistList) do
                if fu:isFileExist(plist) then
                    sfc:removeSpriteFramesFromFile(plist)
                    tc:removeTextureForKey(v.png)
                    -- print("release plist: " .. v.png)
                end
            end
            self._releasePlistList = {}
        end
        local mb2 = SystemUtils.getTotalTextureMBytes()
        if mb2 > MAX_MEMORY_VALUE then
            print("2级释放, self:releaseTexture(true, filter)")
            self:releaseTexture(true, filter)
        end
        local mb3 = SystemUtils.getTotalTextureMBytes()
        if mb3 > MAX_MEMORY_VALUE then
            print("3级释放, cc.Director:getInstance():getTextureCache():removeUnusedTextures()")
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end

local find = string.find
local reverse = string.reverse
local sub = string.sub
local len = string.len
-- texture资源管理
function ViewManager:textureManager()
    local _overload = function (func)
        local _func = func
        return function (...)
            local args = {...} 
            local arg = args[2]
            if arg  then
                local viewname = self._nextShowView:getClassName()
                self._viewTexList[viewname][arg] = 1
                local res = _func(...)
                if res._subEx ~= nil and res._subEx.removeFromParent ~= nil then
                    res._subEx:removeFromParent(true)
                    res._subEx = nil
                end
                if find(arg, SIM_EX_PATH) == nil then
                    local strLen = len(arg)
                    local first_ret = reverse(arg)
                    local firstSub = find(first_ret, "/")
                    local subStr = sub(arg, strLen-firstSub+ 2, strLen)
                    if SIM_EX[subStr] then

                        local subSprite = cc.Sprite:create(SIM_EX_PATH .. subStr)
                        subSprite:setAnchorPoint(0, 0)
                        subSprite:setPosition(SIM_EX[subStr][1], SIM_EX[subStr][2])
                        res:addChild(subSprite)
                        res._subEx = subSprite
                        return res
                    end
                end
                return res
            else
                return _func(...)
            end
        end
    end

    self._viewTexList = {}
    self._textureList = {}
    self._oldSprite_create = cc.Sprite.create
    self._oldSprite_setTexture = cc.Sprite.setTexture
    self._oldSpriteBatchNode_create = cc.SpriteBatchNode.create
    self._oldImageView_loadTexture = ccui.ImageView.loadTexture
    self._oldImageView_create = ccui.ImageView.create
    self._oldLayout_setBackGroundImage = ccui.Layout.setBackGroundImage

    cc.Sprite.create = _overload(cc.Sprite.create)
    cc.Sprite.setTexture = _overload(cc.Sprite.setTexture)
    cc.SpriteBatchNode.create = _overload(cc.SpriteBatchNode.create)
    
    local _overloadFrame = function (func)
        local _func = func
        return function (...)
            local args = {...}
            local arg = args[2]
            local res = func(...)
            if res._subEx ~= nil and res._subEx.removeFromParent ~= nil then
                res._subEx:removeFromParent(true)
                res._subEx = nil
            end
            if UI_FONT_EX[arg] then   
                if res._subTxt ~= nil and res._subTxt.removeFromParent ~= nil then
                    res._subTxt:removeFromParent(true)
                    res._subTxt = nil
                end                 
                local param = UI_FONT_EX[arg]
                local subExLabel = cc.Label:createWithTTF(lang(param[3]), UIUtils.ttfName, param[4])
                subExLabel:setPosition(param[1], param[2])
                subExLabel:setAnchorPoint(0.5, 0.5)
                if param[5] ~= 0 then 
                    subExLabel:setRotation(param[5])
                end
                subExLabel:setColor(cc.c3b(param[6][1], param[6][2], param[6][3]))

                if #param[7] > 0 then
                    subExLabel:enableOutline(cc.c3b(param[7][1], param[7][2], param[7][3]), param[8])
                end
                if #param[9] > 0 then
                    subExLabel:enable2Color(1, cc.c3b(param[9][1], param[9][2], param[9][3]))
                end

                res:addChild(subExLabel)
                res._subTxt = subExLabel
                return res
            end
            return res
        end
    end
    cc.Sprite.createWithSpriteFrameName = _overloadFrame(cc.Sprite.createWithSpriteFrameName)
    cc.Sprite.setSpriteFrame = _overloadFrame(cc.Sprite.setSpriteFrame)


    local _overloadImage = function (func)
        local _func = func
        return function (...)
            local args = {...} 
            local arg = args[2]
            if arg  then
                if arg and args[3] == nil or args[3] == 0 then
                    local viewname = self._nextShowView:getClassName()
                    self._viewTexList[viewname][arg] = 1
                    if find(arg, SIM_EX_PATH) == nil then
                        local strLen = len(arg)
                        local first_ret = reverse(arg)
                        local firstSub = find(first_ret, "/")
                        local subStr = sub(arg, strLen-firstSub+ 2, strLen)
                        if SIM_EX[subStr] then                        
                            local res = loadTexture(...)
                            if res._subEx ~= nil and res._subEx.removeFromParent ~= nil then
                                res._subEx:removeFromParent(true)
                                res._subEx = nil
                            end
                            local subSprite = cc.Sprite:create(SIM_EX_PATH .. subStr)
                            subSprite:setAnchorPoint(0, 0)
                            subSprite:setPosition(SIM_EX[subStr][1], SIM_EX[subStr][2])
                            res:addChild(subSprite)
                            return res
                        end
                    end
                end
                if UI_FONT_EX[arg] then   
                    local res = _func(...)
                    if res._subTxt ~= nil and res._subTxt.removeFromParent ~= nil then
                        res._subTxt:removeFromParent(true)
                        res._subTxt = nil
                    end
                    local param = UI_FONT_EX[arg]
                    local subExLabel = cc.Label:createWithTTF(lang(param[3]), UIUtils.ttfName, param[4])
                    subExLabel:setPosition(param[1], param[2])
                    subExLabel:setAnchorPoint(0.5, 0.5)
                    if param[5] ~= 0 then 
                        subExLabel:setRotation(param[5])
                    end
                    subExLabel:setColor(cc.c3b(param[6][1], param[6][2], param[6][3]))

                    if #param[7] > 0 then
                        subExLabel:enableOutline(cc.c3b(param[7][1], param[7][2], param[7][3]), param[8])
                    end
                    if #param[9] > 0 then
                        subExLabel:enable2Color(1, cc.c3b(param[9][1], param[9][2], param[9][3]))
                    end

                    res:addChild(subExLabel)
                    res._subTxt = subExLabel
                    return res
                end
                return _func(...)
            else
                return _func(...)
            end
        end
    end
    ccui.ImageView.create = _overloadImage(ccui.ImageView.create)
    ccui.ImageView.loadTexture= _overloadImage(ccui.ImageView.loadTexture)

    local setBackGroundImage = ccui.Layout.setBackGroundImage
    ccui.Layout.setBackGroundImage = function (...)
        local args = {...}
        if args[3] == nil or args[3] == 0 then
            local viewname = self._nextShowView:getClassName()
            self._viewTexList[viewname][args[2]] = 1
        end
        return setBackGroundImage(...)
    end
end
function ViewManager:addGlobalTexture(filename, tick)
    self._textureList[filename] = tick
end
function ViewManager:addTexture(viewname, filename)
    self._viewTexList[viewname][filename] = 1
end
local tc = cc.Director:getInstance():getTextureCache()
function ViewManager:removeTexture(viewname, filename)
    self._viewTexList[viewname][filename] = nil
    tc:removeTextureForKey(filename)
end

-- 卸载texture
function ViewManager:releaseTexture(allRelease, filter)
    if allRelease then
        for name, list in pairs(self._viewTexList) do
            if name ~= filter and self._views[name] == nil then
                for k, v in pairs(list) do
                    self._textureList[k] = 0
                end
                self._viewTexList[name] = nil
            end
        end
        local tick = socket.gettime()
        for filename, _ in pairs(self._textureList) do
            -- print("removeTex: " .. filename)
            tc:removeTextureForKey(filename)
            self._textureList[filename] = nil
        end
    else
        local tick = socket.gettime()
        for filename, useTick in pairs(self._textureList) do
            if tick > useTick then
                -- print("removeTex: " .. filename)
                tc:removeTextureForKey(filename)
                self._textureList[filename] = nil
            end
        end
    end
end

function ViewManager:screenXOffset()
    -- 超长屏幕左边转换
    local _convertToWorldSpaceAR = cc.Node.convertToWorldSpaceAR
    cc.Node.convertToWorldSpaceAR = function (_, pt1)
        local pt = _convertToWorldSpaceAR(_, pt1)
        pt.x = pt.x - SCREEN_X_OFFSET
        return pt
    end
    self._oldConvertToWorldSpaceAR = _convertToWorldSpaceAR

    local _convertToWorldSpace = cc.Node.convertToWorldSpace
    cc.Node.convertToWorldSpace = function (_, pt1)
        local pt = _convertToWorldSpace(_, pt1)
        pt.x = pt.x - SCREEN_X_OFFSET
        return pt
    end
    self._oldConvertToWorldSpace = _convertToWorldSpace

    local _convertToNodeSpace = cc.Node.convertToNodeSpace
    cc.Node.convertToNodeSpace = function (_, pt1)
        pt1.x = pt1.x + SCREEN_X_OFFSET
        local pt = _convertToNodeSpace(_, pt1)
        return pt
    end
    self._oldConvertToNodeSpace = _convertToNodeSpace


    local _getTouchBeganPosition = ccui.Widget.getTouchBeganPosition
    ccui.Widget.getTouchBeganPosition = function (...)
        local pt = _getTouchBeganPosition(...)
        pt.x = pt.x - SCREEN_X_OFFSET
        return pt
    end
    self._oldGetTouchBeganPosition = _getTouchBeganPosition

    local _getTouchMovePosition = ccui.Widget.getTouchMovePosition
    ccui.Widget.getTouchMovePosition = function (...)
        local pt = _getTouchMovePosition(...)
        pt.x = pt.x - SCREEN_X_OFFSET
        return pt
    end
    self._oldGetTouchMovePosition = _getTouchMovePosition

    local _getTouchEndPosition = ccui.Widget.getTouchEndPosition
    ccui.Widget.getTouchEndPosition = function (...)
        local pt = _getTouchEndPosition(...)
        pt.x = pt.x - SCREEN_X_OFFSET
        return pt
    end
    self._oldGetTouchEndPosition = _getTouchEndPosition

    local _getLocation = cc.Touch.getLocation
    cc.Touch.getLocation = function (...)
        local pt = _getLocation(...)
        pt.x = pt.x - SCREEN_X_OFFSET
        return pt
    end
    self._oldGetLocation = _getLocation
end

-- test 删号
function ViewManager:deleteAccount()
    self:showDialog("global.GlobalMessageDialog", {desc = "确定要删号么?", button = "确定", callback = function ()
        self:showDialog("global.GlobalMessageDialog", {desc = "再按确定可就真删了?", button = "はい", callback = function ()
            local model = ModelManager:getInstance():getModel("UserModel")
            if model and model.roleGuild and type(model.roleGuild.id) == "number" then
                ServerManager:getInstance():sendMsg("GuildServer", "quitGuild", {}, true, {}, function (result)
                    ServerManager:getInstance():sendMsg("ToolsServer", "clearUser", {}, true, {}, function() 
                        self:restart()
                    end)  
                end)
            else
                ServerManager:getInstance():sendMsg("ToolsServer", "clearUser", {}, true, {}, function() 
                    self:restart()
                end)
            end 
        end})
    end})
end

-- 返回登录界面
function ViewManager:_returnLogin()
    ServerManager:getInstance():clear()
    ModelManager:getInstance():clear()
    ViewManager:getInstance():clear()
    AudioManager:getInstance():clear()
end

function ViewManager:checkLevelUpReturnMain(level)
    local gotoview = tab.userLevel[level]["gotoview"]
    if gotoview and gotoview == 1 then
        self:returnMain()
    end
end

-- 禁止切换界面 用于网络错误, 需要返回登录的状况
function ViewManager:disableChangeView()
    self._disableChangeView = true
end

function ViewManager:enableChangeView()
    self._disableChangeView = false
end

function ViewManager:getCurViewName()
    local count = #self._viewLayer:getChildren()
    if count > 0 then
        local node = self._viewLayer:getChildren()[count]
        return node.view:getClassName()
    else
        return ""
    end
end

function ViewManager:getCurView()
    local count = #self._viewLayer:getChildren()
    if count > 0 then
        local node = self._viewLayer:getChildren()[count]
        return node.view
    else
        return nil
    end
end

function ViewManager:isReturnMaining()
    return self._returnMaining
end

function ViewManager:isEnableChangeView()
    return self._disableChangeView
end

function ViewManager:returnMain(viewname, param)
    if self._disableChangeView then return end
    local popView = false
    self._returnMaining = true
    if viewname == nil then
        while #self._viewLayer:getChildren() > 1 do
            local dontOnTop = true
            if self._viewLayer:getChildren()[1].view:getClassName() == "main.MainView" and #self._viewLayer:getChildren() == 2 then
                dontOnTop = false
            end
            self:popView(nil, dontOnTop)
            popView = true
        end
        if self._viewLayer:getChildren()[1].view:getClassName() ~= "main.MainView" then
            self:popView()
            popView = true
        end
        if self._viewLayer:getChildren()[1].view:getClassName() == "main.MainView" then
            self._viewLayer:getChildren()[1].view:onReturnMain()
        end
    else
        while #self._viewLayer:getChildren() > 2 do
            self:popView(nil, true)
        end
        self:switchView(viewname, param)
    end
    self._returnMaining = false
    if not popView then
        self:onViewChange()
    end
end

-- 需要退出游戏重新登录时候用到
function ViewManager:clear()
    BulletScreensUtils.clear()
    VoiceUtils.clear()
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:removeEventListenersForTarget(self._globalClickLayer, true)
    self._otherLayer:removeAllChildren()
    if self._talkLayer then
        self._talkLayer:over()
        self._talkLayer:removeFromParent()
        self._talkLayer = nil
    end
    if self._curtainLayer then
        self._curtainLayer:removeFromParent()
        self._curtainLayer = nil
    end
    -- 销毁全局弹出框
    self:clearGlobalDialog()

    -- 销毁广播
    if self._noticeView then
        self._noticeView:destroy()
        self._noticeView = nil
        self:removeCustomNotice()
        self._noticeLayer:removeAllChildren()
    end
    -- 销毁导航条
    for k, v in pairs(self._navigations) do
        v:destroy()
    end
    self._navigations = {}
    if self._navigationLayer then
        self._navigationLayer:removeAllChildren()
        self._navigationLayer:removeFromParent(false)
        self._navigationLayer:release()
        self._navigationLayer = nil
        self._guideAnimUI = nil
    end
    local node, view
    for i = #self._viewLayer:getChildren(), 1, -1 do
        node = self._viewLayer:getChildren()[i]
        view = node.view
        view:beforePop()
        view:onHide()
        view:destroy(true)
        self._views[view:getClassName()] = nil
        if view:getParent() then
            view:removeFromParent()
        end
    end
    self._viewLayer:removeAllChildren()
    self:doReleaseRes(true, true)
    self._views = {}

    tab:clear()
    mcMgr:clear()
    sfResMgr:clear()
    ScheduleMgr:clear()
    self:guideDelEvent()
    self:guideMaskDisable()
    self:guideUnlock()
    self:clearLock()
    GuideUtils.resetConfig()
end

function ViewManager:restart()
    if mcMgr then
        mcMgr:release("firstrechargeanim")
    end
    -- sfResMgr:release("commondie")
    self:_returnLogin()
    cc.Sprite.create = self._oldSprite_create
    cc.Sprite.setTexture = self._oldSprite_setTexture
    cc.SpriteBatchNode.create = self._oldSpriteBatchNode_create
    ccui.ImageView.loadTexture = self._oldImageView_loadTexture
    ccui.ImageView.create  = self._oldImageView_create
    ccui.Layout.setBackGroundImage = self._oldLayout_setBackGroundImage

    cc.Node.convertToWorldSpaceAR = self._oldConvertToWorldSpaceAR
    cc.Node.convertToWorldSpace = self._oldConvertToWorldSpace
    cc.Node.convertToNodeSpace = self._oldConvertToNodeSpace

    ccui.Widget.getTouchBeganPosition = self._oldGetTouchBeganPosition
    ccui.Widget.getTouchMovePosition = self._oldGetTouchMovePosition
    ccui.Widget.getTouchEndPosition = self._oldGetTouchEndPosition

    cc.Touch.getLocation = self._oldGetLocation

    ScheduleMgr:cleanMyselfTicker(self)
    self:clear()
    sfc:removeSpriteFramesFromFile("asset/bg/mainViewBg.plist")
    tc:removeTextureForKey("asset/bg/mainViewBg.png")
    sfc:removeSpriteFramesFromFile("asset/bg/mainViewBg2.plist")
    tc:removeTextureForKey("asset/bg/mainViewBg2.png")
    sfc:removeSpriteFramesFromFile("asset/bg/mainViewBg3.plist")
    tc:removeTextureForKey("asset/bg/mainViewBg3.png")
    sfc:removeSpriteFramesFromFile("asset/bg/mainViewBg4.plist")
    tc:removeTextureForKey("asset/bg/mainViewBg5.png")
    sfc:removeSpriteFramesFromFile("asset/bg/mainViewBg5.plist")
    tc:removeTextureForKey("asset/bg/mainViewBg6.png")
    sfc:removeSpriteFramesFromFile("asset/bg/mainViewBg6.plist")
    tc:removeTextureForKey("asset/bg/mainViewBg4.png")
    sfc:removeSpriteFramesFromFile("asset/ui/mainView.plist")
    tc:removeTextureForKey("asset/ui/mainView.png")
    sfc:removeSpriteFramesFromFile("asset/ui/mainView2.plist")
    tc:removeTextureForKey("asset/ui/mainView2.png")
    sfc:removeSpriteFramesFromFile("asset/ui/mainView3.plist")
    tc:removeTextureForKey("asset/ui/mainView3.png")
    sfc:removeSpriteFramesFromFile("asset/ui/mainView-HD.plist")
    tc:removeTextureForKey("asset/ui/mainView-HD.png")
    RestartMgr:restart()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function ViewManager:onRestart()
    for i = 1, #self._viewLayer:getChildren() do
        self._viewLayer:getChildren()[i].view:onRestart()
    end
end

--[[
    新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导
    新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导
    新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导新手引导
]]--
function ViewManager:initGuideLayer()
    self._guideLayer = cc.Node:create()
    self._guideLayer:setLocalZOrder(Z_Guide)
    self._rootLayer:addChild(self._guideLayer)

    self._guideLock = ccui.Layout:create()
    self._guideLock:setBackGroundColorOpacity(255)
    self._guideLock:setBackGroundColorType(1)
    self._guideLock:setBackGroundColor(cc.c3b(0,255,0))
    self._guideLock:setContentSize(MAX_SCREEN_WIDTH + 200, MAX_SCREEN_HEIGHT)
    self._guideLock:setTouchEnabled(false)
    self._guideLock:setVisible(false)
    self._guideLock:setOpacity(0)
    self._guideLock.noSound = true
    self._guideLayer:addChild(self._guideLock)   

    if GameStatic.showLockDebug then
        local debugColor = ccui.Layout:create()
        debugColor:setBackGroundColorOpacity(255)
        debugColor:setBackGroundColorType(1)
        debugColor:setBackGroundColor(cc.c3b(255,255,0))
        debugColor:setContentSize(100, 2)
        debugColor:setPosition(2, 3)
        self._guideLock:addChild(debugColor)
    end

    self._guideMask = cc.RenderTexture:create(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    self._guideMask:setScale(2)
    self._guideMask:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self._guideMask:setVisible(false)
    self._guideMask:getSprite():getTexture():setAntiAliasTexParameters()
    self._guideLayer:addChild(self._guideMask)

    registerTouchEvent(self._guideLock, 
        function (sender, x, y)
            if sender.callback then
                sender.callback(0, x, y)
            end
        end,
        function (sender, x, y)
            if sender.callback then
                sender.callback(1, x, y)
            end
        end,
        function (sender, x, y)
            if sender.callback then
                sender.callback(2, x, y)
            end
        end,
        function (sender, x, y)
            if sender.callback then
                sender.callback(3, x, y)
            end
        end
    )
    self._guideLock:setTouchEnabled(false)

    self._guideTipNode = cc.Node:create()
    self._guideLayer:addChild(self._guideTipNode)

    self._guideDebugNode = cc.Node:create()
    self._guideLayer:addChild(self._guideDebugNode)
    if GuideUtils.DEBUG then
        self._btnName = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
        self._btnName:setPosition(2, 120)
        self._btnName:setColor(cc.c3b(0, 255, 255))
        self._btnName:enableOutline(cc.c4b(0,0,0,255), 1)
        self._btnName:setAnchorPoint(0, 0.5)
        self._guideDebugNode:addChild(self._btnName, 1000000)

        self._viewName = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self._viewName:setPosition(2, 160)
        self._viewName:setColor(cc.c3b(0, 255, 0))
        self._viewName:enableOutline(cc.c4b(0,0,0,255), 1)
        self._viewName:setAnchorPoint(0, 0.5)
        self._guideDebugNode:addChild(self._viewName, 1000000)

        self._lockLabel = cc.Label:createWithTTF("unlock", UIUtils.ttfName, 20)
        self._lockLabel:setPosition(2, 140)
        self._lockLabel:setColor(cc.c3b(0, 255, 0))
        self._lockLabel:enableOutline(cc.c4b(0,0,0,255), 1)
        self._lockLabel:setAnchorPoint(0, 0.5)
        self._guideDebugNode:addChild(self._lockLabel, 1000000)

        self._indexLabel = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self._indexLabel:setPosition(2, 180)
        self._indexLabel:setColor(cc.c3b(255, 255, 0))
        self._indexLabel:enableOutline(cc.c4b(0,0,0,255), 1)
        self._indexLabel:setAnchorPoint(0, 0.5)
        self._guideDebugNode:addChild(self._indexLabel, 1000000)
    end
end

function ViewManager:guideLock()
    if GuideUtils.isGuideRunning then return end
    GuideUtils.isGuideRunning = true
    self._guideLock:setTouchEnabled(true)
    self._guideLock:setVisible(true)
    if self._lockLabel then
        self._lockLabel:setString("lock")
        self._lockLabel:setColor(cc.c3b(255, 0, 0))
    end
    self:pauseGlobalDialog()
    if self.__guidePause > 0 then return end
    onGuideLock(self._guideLock)
    if self._isIndulgePopViewShow then
        self._indulgeGuideLockView = self._guideLock
        onGuideUnlock()
    end
end

function ViewManager:guideAddEvent(callback)
    self._guideLock.callback = callback
end

function ViewManager:guideDelEvent()
    self._guideLock.callback = nil
end

function ViewManager:guideUnlock()
    if not GuideUtils.isGuideRunning then return end
    if self._lockLabel then
        self._lockLabel:setString("unlock")
        self._lockLabel:setColor(cc.c3b(0, 255, 0))
    end
    GuideUtils.isGuideRunning = false
    self._guideLock.callback = nil
    onGuideUnlock()
    self._guideLock:setTouchEnabled(false)
    self._guideLock:setVisible(false)
    self:resumeGlobalDialog()
end

-- 屏幕压暗, 高亮重点
function ViewManager:guideMaskEnable(x, y, w, h, mask, _scalex, _scaley, _offsetx, _offsety)
    local filename, scalex, scaley
    local _type = 1
    local _scalex = 1
    local _scaley = 1
    local _offsetx = 0
    local _offsety = 0
    if mask then
        if mask.type then _type = mask.type end
        if mask.scalex then _scalex = mask.scalex end
        if mask.scaley then _scaley = mask.scaley end
        if mask.x then _offsetx = mask.x end
        if mask.y then _offsety = mask.y end
    end

    if _type == 1 then
        filename = "asset/other/circle.png"
        scalex = w * 0.01 * 2 * _scalex
        scaley = h * 0.01 * 2 * _scaley
    else
        filename = "asset/other/rect.png"
        scalex = w / 163 * 2 * _scalex
        scaley = h / 142 * 2 * _scaley
    end
    self._guideMask:beginWithClear(0, 0, 0, 0.65)
    local sprite = cc.Sprite:create(filename)
    sprite:setPosition((x + _offsetx) * 0.5, (y + _offsety) * 0.5)
    sprite:setScale(scalex * 0.5, scaley * 0.5)
    sprite:setBlendFunc({src = gl.ZERO, dst = gl.ONE_MINUS_SRC_ALPHA})
    sprite:visit()
    self._guideMask:endToLua()
    -- self._guideMask:setVisible(true)
    self._guideMask:getSprite():setOpacity(0)
end

function ViewManager:guideMaskShowAction()
    self._guideMask:setVisible(true)
    self._guideMask:getSprite():stopAllActions()
    self._guideMask:getSprite():runAction(cc.Sequence:create(cc.FadeIn:create(0.2), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))
end

function ViewManager:guideMaskShow()
    self._guideMask:setVisible(true)
    self._guideMask:getSprite():setOpacity(255)
end

function ViewManager:guideMaskDisable()
    self._guideTipNode:removeAllChildren()
    if self._guideTip then self._guideTip:setVisible(false) end
    self._guideMask:getSprite():runAction(cc.FadeOut:create(0.2))
    if self._guideAnimUI then
        self._guideAnimUI:removeFromParent()
        self._guideAnimUI = nil
    end
end

function ViewManager:updateGuideIndexLabel()
    if GuideUtils.DEBUG then
        if GuideUtils.enableTrigger then
            self._indexLabel:setColor(cc.c3b(255, 128, 128))
            self._indexLabel:setString(GuideUtils.triggerName .. GuideUtils.triggerIndex)
        else
            self._indexLabel:setColor(cc.c3b(255, 255, 0))
            self._indexLabel:setString(GuideUtils.guideIndex)
        end
    end
end
function ViewManager:doTriggerByName(name, callback)
    if name == nil then return false end
    local config = GuideUtils.triggerByName(name, callback)
    if config then
        ServerManager:getInstance():sendMsg("GuideServer", "setGuildTrigger", {point = tostring(name)}, false)
        ModelManager:getInstance():getModel("UserModel"):setTrigger(name)
        self._triggerIndex = nil
        self:doGuideEvent(config)
        return true
    end
    return false
end

-- 由view触发的事件
function ViewManager:doViewGuide()
    local children = self._viewLayer:getChildren()
    if #children > 0 then
        local view = children[#children].view
        local name = view:getClassName()
        if GuideUtils.DEBUG then
            self._viewName:setString(name)
        end

        -- 触发view事件
        local ret, config = GuideUtils.checkGuide_view(name)
        if ret then
            self:doGuideEvent(config)
            return true
        end
    end
end

function ViewManager:doFirstViewGuide()
    local children = self._viewLayer:getChildren()
    if #children > 0 then
        local view = children[#children].view
        local name = view:getClassName()
        if GuideUtils.DEBUG then
            self._viewName:setString(name)
        end

        -- 触发view事件
        local ret, config = GuideUtils.checkGuide_firstView(name)
        if ret then
            self:doGuideEvent(config)
            return true
        end
    end
end

-- 由layer触发的事件
function ViewManager:doLayerGuide(layer)
    local ret, config = GuideUtils.checkGuide_layer(layer:getClassName())
    if ret then
        self:doGuideEvent(config)
        return true
    end
end

-- 由弹框弹出触发的事件
function ViewManager:doPopShowGuide(popView)
    local ret, config = GuideUtils.checkGuide_popshow(popView:getClassName())
    if ret then
        self:doGuideEvent(config)
        return true
    end
end

-- 由弹框关闭触发的事件
function ViewManager:doPopCloseGuide(popView)
    local ret, config = GuideUtils.checkGuide_popclose(popView:getClassName())
    if ret then
        self:doGuideEvent(config)
        return true
    end
end

-- 继续触发的事件
function ViewManager:doDoneGuide()
    local ret, config = GuideUtils.checkGuide_done()
    if ret then
        self:doGuideEvent(config)
        return true
    end
end

function ViewManager:doStoryoverGuide()
    local ret, config = GuideUtils.checkGuide_storyover()
    if ret then
        self:doGuideEvent(config)
        return true
    end
end

function ViewManager:doCustomGuide(name)
    local ret, config = GuideUtils.checkGuide_custom(name)
    if ret then
        self:doGuideEvent(config)
        return true
    end
end

function ViewManager:doNewoverGuide()
    local ret, config = GuideUtils.checkGuide_newover()
    if ret then
        self:doGuideEvent(config)
        return true
    end
end

function ViewManager:doGuideEvent(config)
    if GuideUtils.ENABLE or GuideUtils.ENABLE_TRIGGER then
        if GuideUtils.enableTrigger then
            if self._triggerIndex ~= GuideUtils.triggerIndex then
                dump(config, "tri:"..GuideUtils.triggerIndex)
                self._triggerIndex = GuideUtils.triggerIndex
            else
                print("重复触发tri", GuideUtils.triggerIndex)
                return
            end
        else
            if self._guideIndex ~= GuideUtils.guideIndex then
                dump(config, GuideUtils.guideIndex)
                self._guideIndex = GuideUtils.guideIndex
            else
                print("重复触发", GuideUtils.guideIndex)
                return
            end
        end
        self:updateGuideIndexLabel()

        local count = #self._viewLayer:getChildren()
        if count > 0 then
        local node = self._viewLayer:getChildren()[count]
            node.view:onDoGuide(config)
        end
        if config.event == "click" then
            self:doGuideClick(config)
        elseif config.event == "close" then
            self:doGuideClose(config)
        elseif config.event == "story" then
            self:doGuideStory(config)
        elseif config.event == "prompt" then
            self:doGuidePrompt(config)
        elseif config.event == "drag" then
            self:doGuideDrag(config)
        elseif config.event == "rush" then
            self:doGuideRush(config)
        elseif config.event == "zhanling" then
            self:doGuideZhanling(config)
        elseif config.event == "herozhuanchang" then
            self:doGuideHerozhuanchang(config)
        elseif config.event == "fenghuang" then
            self:doGuideGenghuang(config)
        elseif config.event == nil then
            -- 空事件
            ScheduleMgr:delayCall(config.delay, self, function()
                self:doNextGuide(config)
            end)
        end
    end
end

local guide_click_delay = 1000
function ViewManager:doGuideClick(config)
    self:guideLock()
    ScheduleMgr:delayCall(config.delay, self, function()
        local ui = self:getGuideUIByFullName(self._rootLayer, config.clickName)
        if ui == nil then 
            if OS_IS_WINDOWS then
                self:showTip(config.clickName)
            end
            -- 中断引导, 以防万一
            self:breakOffGuide()
            return
        end
        local w, h = self:_guide_getRealSize(ui)
        local pt = ui:convertToWorldSpace(cc.p(0, 0))
        local x, y = pt.x, pt.y
        -- print(x, y, w, h)
        self:guideMaskEnable(x + w * 0.5, y + h * 0.5, w, h, config.mask)
        x, y, w, h = self:_guide_clickArea(config, x, y, w, h)

        self:_guide_talk(config, x, y, w, h)
        if config.talk and config.shouzhi then
            ScheduleMgr:delayCall(guide_click_delay, self, function()
                self:_guide_shouzhi(config, x + w * 0.5, y + h * 0.5)
                self:_guide_Addevent(true, config, ui, x, y, w, h, nil, 0, 0)
            end)
        else
            self:_guide_shouzhi(config, x + w * 0.5, y + h * 0.5)
            self:_guide_Addevent(true, config, ui, x, y, w, h, nil, 0, 0)
        end

        if config.scaleanim then
            local animui = self:getGuideUIByFullName(self._rootLayer, config.scaleanim)
            if animui then
                local beatImg = animui:clone()
                beatImg:setPosition(cc.p(animui:getContentSize().width/2,animui:getContentSize().height/2))
                animui:addChild(beatImg)
                local seq = cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.FadeOut:create(0.4),
                    cc.FadeIn:create(0),cc.ScaleTo:create(0,1),cc.DelayTime:create(0.2))
                beatImg:runAction(cc.RepeatForever:create(seq))
                self._guideAnimUI = beatImg
            end
        end
    end)
end

function ViewManager:doGuideDrag(config)
    self:guideLock()
    ScheduleMgr:delayCall(config.delay, self, function()
        if config.showtip then
            self:showTipEx(lang(config.showtip))
        end

        -- 起始位置
        local ui1 = self:getGuideUIByFullName(self._rootLayer, config.dragName1)
        if ui1 == nil then 
            if OS_IS_WINDOWS then
                self:showTip(config.dragName1)
            end
            -- 中断引导, 以防万一
            self:breakOffGuide()
            return
        end
        -- 移动接收
        local ui2 = self:getGuideUIByFullName(self._rootLayer, config.dragName2)
        if ui2 == nil then 
            if OS_IS_WINDOWS then
                self:showTip(config.dragName2)
            end
            -- 中断引导, 以防万一
            self:breakOffGuide()
            return
        end
        -- 结束位置
        local ui3 = self:getGuideUIByFullName(self._rootLayer, config.dragName3)
        if ui3 == nil then 
            if OS_IS_WINDOWS then
                self:showTip(config.dragName3)
            end
            -- 中断引导, 以防万一
            self:breakOffGuide()
            return
        end
        local x1, y1 = ui1:nodeConvertToScreenSpace(ui1:getContentSize().width * 0.5, ui1:getContentSize().height * 0.5)
        local x2, y2 = ui3:nodeConvertToScreenSpace(ui3:getContentSize().width * 0.5, ui3:getContentSize().height * 0.5)
        local scaleui1, scaleui2
        if config.scale1 then
            scaleui1 = ui1
        end
        if config.scale2 then
            scaleui2 = ui3
        end
        self:showDragGuide(scaleui1, scaleui2, x1, y1, x2, y2)
        local w1, h1 = self:_guide_getRealSize(ui1)
        local pt = ui1:convertToWorldSpace(cc.p(0, 0))
        local x1, y1 = pt.x, pt.y

        self:_guide_talk(config, x1, y1, w1, h1)
        self:_guide_AddDragEvent(config, ui1, ui2, ui3)
    end)
end

function ViewManager:doGuideRush(config)
    self:guideLock()
    ScheduleMgr:delayCall(config.delay, self, function()
        self:showDialog("global.IntroduceRushDialog", {kind = config.kind, str = config.str})
        self:doNextGuide(config)
    end)
end

function ViewManager:doGuideBattleOver1()
    ScheduleMgr:delayCall(0, self, function()
        local bgLayer = ccui.Layout:create()
        bgLayer:setBackGroundColorOpacity(255)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgLayer:setOpacity(0)
        self:getRootLayer():addChild(bgLayer, 100)
        bgLayer:runAction(cc.FadeIn:create(2))
        self._guideBattleBgLayer = bgLayer
    end)
end

function ViewManager:doGuideBattleOver2()
    ScheduleMgr:delayCall(0, self, function()
        self:switchView("logo.VideoView", {runType = 2})
        if self._guideBattleBgLayer then
            self._guideBattleBgLayer:removeFromParent()
            self._guideBattleBgLayer = nil
        end
    end)
end

-- 假新手引导占领动画
function ViewManager:doGuideZhanling(config)
    self:guideLock()
    ScheduleMgr:delayCall(config.delay, self, function()
        local bgLayer = ccui.Layout:create()
        bgLayer:setBackGroundColorOpacity(255)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgLayer:setOpacity(0)
        self:getRootLayer():addChild(bgLayer, 100)
        bgLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(1.5), cc.CallFunc:create(function ()
            self:popView(nil, true)
            audioMgr:stopMusic()
            self:enableScreenWidthBar()
            local templeAnim = mcMgr:createViewMC("rucheng_rucheng", false, true, function(_, sender)
                self:guideUnlock()
                bgLayer:removeFromParent()
                tab:antiInit()
                self:disableScreenWidthBar()
                self:switchView("logo.VideoView", {runType = 3})
            end)
            audioMgr:playSoundForce("rucheng", false, 0.25)
            ScheduleMgr:delayCall(500, self, function()
                audioMgr:playSoundForce("cg", false, 1, 1)
            end)
            templeAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 2)   
            bgLayer:addChild(templeAnim)  
            local xscale = MAX_SCREEN_WIDTH / 1136
            local yscale = MAX_SCREEN_HEIGHT / 640
            if ADOPT_IPHONEX then
                xscale = 1.3
            end
            if xscale > yscale then
                templeAnim:setScale(xscale)
            else
                templeAnim:setScale(yscale)
            end

        end)))
    end)
end

-- 英雄专长引导提示框
function ViewManager:doGuideHerozhuanchang(config)
    self:guideLock()
    local ui = self:getGuideUIByFullName(self._rootLayer, config.ui)
    local tip = cc.Scale9Sprite:createWithSpriteFrameName("zhanchangguide_hero.png")
    tip:setContentSize(370, 96)
    tip:setPosition(config.uix + 5, config.uiy + 5)
    ui:addChild(tip)
    tip:setOpacity(0)
    tip:runAction(cc.Sequence:create(
        cc.FadeIn:create(0.5), cc.FadeOut:create(0.5), cc.FadeIn:create(0.5), cc.FadeOut:create(0.5),
        cc.CallFunc:create(function ()
            self:doNextGuide(config)
        end),
        cc.RemoveSelf:create(true)
    ))
end

-- 凤凰引导
function ViewManager:doGuideGenghuang(config)
    self:guideLock()
    ScheduleMgr:delayCall(config.delay, self, function()
        self:showDialog("global.GlobalSkillPreviewDialog", {teamId = 907, skillId = 50134})
        self:doNextGuide(config)
    end)
end

function ViewManager:_guide_getRealSize(ui)
    local pt1 = ui:convertToWorldSpace(cc.p(0, 0))
    local w = ui:getContentSize().width
    local h = ui:getContentSize().height
    local pt2 = ui:convertToWorldSpace(cc.p(w, h))
    return pt2.x - pt1.x, pt2.y - pt1.y
end

function ViewManager:_guide_clickArea(config, x, y, w, h)
    local _x, _y, _w, _h = x, y, w, h
    if config.clickArea then
        if config.clickArea.x then _x = _x + config.clickArea.x end
        if config.clickArea.y then _y = _y + config.clickArea.y end
        if config.clickArea.w then _w = config.clickArea.w end
        if config.clickArea.h then _h = config.clickArea.h end
        if GuideUtils.DEBUG then
            local debugArea = ccui.Layout:create()
            debugArea:setBackGroundColorOpacity(128)
            debugArea:setBackGroundColorType(1)
            debugArea:setBackGroundColor(cc.c3b(255,0,0))
            debugArea:setContentSize(_w, _h)
            debugArea:setPosition(_x, _y)
            self._guideTipNode:addChild(debugArea)
        end
    end
    return _x, _y, _w, _h
end

function ViewManager:_guide_talk(config, x, y, w, h)
    -- 提示文字
    if config.talk then
        if self._guideTip == nil then
            self._guideTip = cc.Scale9Sprite:createWithSpriteFrameName("guideImage_bg.png")
            self._guideTip:setCapInsets(cc.rect(320,0,1,1))
            self._guideTip:setContentSize(517, 185)
            self._guideTip:setCascadeOpacityEnabled(true)
            self._guideTip:setAnchorPoint(0.5, 0.5)
            self._guideTip:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
            self._guideLayer:addChild(self._guideTip)
        else
            self._guideTip.label:removeFromParent()
            self._guideTip.label = nil
        end
        local str = lang(config.talk.str)
        if string.find(str, "color=") == nil then
            str = "[color=000000]"..str.."[-]"
        end
        local label = RichTextFactory:create(str, 290, 800)
        label:setPixelNewline(true)
        label:formatText()
        label:setPosition(194 + 156, 82)
        self._guideTip:setContentSize(517, 185)
        self._guideTip:addChild(label)
        self._guideTip.label = label
        local _x = 0
        local _y = 0
        if config.talk.x then _x = config.talk.x end
        if config.talk.y then _y = config.talk.y end
        self._guideTip:setPosition(MAX_SCREEN_WIDTH * 0.5 + _x, MAX_SCREEN_HEIGHT * 0.5 + _y)
        self._guideTip:setVisible(true)
        self._guideTip:setOpacity(0)
        self._guideTip:stopAllActions()
        self._guideTip.label:stopAllActions()
        self._guideTip.label:setOpacity(0)
        self._guideTip:runAction(cc.Sequence:create(cc.FadeIn:create(0.2), cc.CallFunc:create(function ()
            self._guideTip.label:runAction(cc.FadeIn:create(0.1))
        end)))
    end
    if config.sound then audioMgr:playTalk(config.sound) end
    -- 弱文字提示
    if config.tip then
        local _x = 0
        local _y = 0
        if config.tip.x then _x = config.tip.x end
        if config.tip.y then _y = config.tip.y end
        local str = lang(config.tip.str)
        if string.find(str, "color=") == nil then
            str = "[color=000000]"..str.."[-]"
        end   
        local label = RichTextFactory:create(str, 1136, 0)
        label:formatText()
        local _w = label:getRealSize().width
        local _h = label:getRealSize().height
        label:setContentSize(_w, _h)
        local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("guideTip_bg.png")
        tipbg:setContentSize(_w + 40, 72)
        label:setPosition((_w + 40)*0.5, 36 + _h * 0.5)
        tipbg:addChild(label, 2)
        local jian = cc.Sprite:createWithSpriteFrameName("guideTip_bg_dir.png")
        jian:setPosition((_w + 40)*0.5, -4)
        tipbg:addChild(jian)
        local __x = x + w * 0.5 + _x
        local __y = y + h * 0.5 + 44 + _y
        tipbg:setPosition(__x, __y)

        if config.tip.filpy then
            tipbg:setScaleY(-1)
            label:setScaleY(-1)
            label:setPosition((_w + 40)*0.5, 12 + _h * 0.5)
        end

        self._guideTipNode:addChild(tipbg)
        -- tipbg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(__x, __y + 25)), cc.MoveTo:create(0.3, cc.p(__x, __y)))))
    end
end


function ViewManager:guideQuan1(x, y)
    local quan = mcMgr:createViewMC("c2_guidecircle-HD", false, true)
    quan:setPosition(x, y)
    self._guideTipNode:addChild(quan)
end

function ViewManager:_guide_quan(x, y)
    local quan = mcMgr:createViewMC("c1_guidecircle-HD", true)
    quan:setPosition(x, y)
    self._guideTipNode:addChild(quan)
end

function ViewManager:_guide_shouzhi(config, x, y)
    if config.shouzhi then
        -- 光圈
        local _x = 0
        local _y = 0
        if config.shouzhi.cx then _x = config.shouzhi.cx end
        if config.shouzhi.cy then _y = config.shouzhi.cy end
        local quan = mcMgr:createViewMC("c1_guidecircle-HD", true)
        quan:setPosition(x + _x, y + _y)
        self._guideTipNode:addChild(quan)

        local angle = 0
        local _x = 0
        local _y = 0
        if config.shouzhi.x then _x = config.shouzhi.x end
        if config.shouzhi.y then _y = config.shouzhi.y end
        if config.shouzhi.angle then angle = config.shouzhi.angle end
        local shouzhi = mcMgr:createViewMC("shou_guidexiaoshou", true)
        shouzhi:setPosition(x + _x, y + _y)
        shouzhi:setRotation(angle)
        if angle > 0 and angle < 180 then
            shouzhi:setScaleX(-1)
        end
        self._guideTipNode:addChild(shouzhi)
    end
end

-- 点击事件
function ViewManager:_guide_Addevent(canBreak, config, ui, x, y, w, h, callback, dx, dy, force)
    -- 引导ui限定纹理名称，如果不一致则中断引导
    if config.textureName then
        if ui.textureName ~= config.textureName then
            self:breakOffGuide()
            return
        end
    end
    local clickCount = 0
    local down = false
    local uiTouchEnable = ui:isTouchEnabled()
    local uiSwallowTouches = ui:isSwallowTouches()
    ui:setTouchEnabled(false)
    self._breakUI = ui
    self:guideAddEvent(function (type, _x, _y)
        -- 伪装事件
        _x = _x
        if type == 0 then
            if w < 0 then
                w = -w
                x = x - w
            end
            if h < 0 then
                h = -h
                y = y - h
            end
            if _x + dx >= x and _x + dx <= x + w and _y + dy >= y and _y + dy <= y + h then
                if ui and ui.setBrightStyle then ui:setBrightStyle(1) end
                if ui.eventDownCallback then
                    ui:eventDownCallback(_x, _y, ui)
                end
                down = true
            else
                local __x, __y = 0, 0
                if config.shouzhi.cx then __x = config.shouzhi.cx end
                if config.shouzhi.cy then __y = config.shouzhi.cy end
                local quan = mcMgr:createViewMC("c2_guidecircle-HD", false, true)
                quan:setPosition(x + w * 0.5 - dx + __x, y + h * 0.5 - dy + __y)
                self._guideTipNode:addChild(quan)
                self._guideMask:setVisible(true)
                self._guideMask:getSprite():stopAllActions()
                self._guideMask:getSprite():runAction(cc.Sequence:create(cc.FadeIn:create(0.2), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))
                if false then --canBreak then
                    clickCount = clickCount + 1
                    if clickCount >= 5 then
                        self._guideMask:getSprite():stopAllActions()
                        self._guideMask:getSprite():setOpacity(0)
                        self._guideLock:setVisible(false)
                        self._guideLayer:setVisible(false)
                        self:showDialog("global.GlobalSelectDialog",
                            {desc = lang("TIPS_QUIT_XINSHOU"),
                            button1 = "确定",
                            button2 = "取消", 
                            callback1 = function ()
                                self:breakOffGuide()
                            end,
                            callback2 = function()
                                clickCount = 0
                                self._guideLayer:setVisible(true)
                                self._guideLock:setVisible(true)
                            end})
                    end
                end
            end
        elseif type == 1 then
            -- move
            if not down then return end
            if _x + dx >= x and _x + dx <= x + w and _y + dy >= y and _y + dy <= y + h then
                if ui and ui.setBrightStyle then ui:setBrightStyle(1) end
            else
                if ui and ui.setBrightStyle then ui:setBrightStyle(0) end
            end
        elseif type == 3 then
            down = false
            -- out
        elseif type == 2 then
            if not down then return end
            down = false
            if _x + dx >= x and _x + dx <= x + w and _y + dy >= y and _y + dy <= y + h then
                if callback == nil then
                    self:doNextGuide(config)
                end
                if ui and ui.setBrightStyle then ui:setBrightStyle(0) end
                if callback then 
                    GuideBattleHelpUtils.LOCK = false 
                    ui:setTouchEnabled(uiTouchEnable)
                    ui:setSwallowTouches(uiSwallowTouches)
                else
                    ui:setTouchEnabled(uiTouchEnable)
                    ui:setSwallowTouches(uiSwallowTouches)
                end
                self._breakUI = nil
                if ui.eventUpCallback then
                    if force then
                        ui:eventUpCallback(x + w * 0.5 - dx, y + h * 0.5 - dy, ui, true)
                    else
                        ui:eventUpCallback(_x, _y, ui, true)
                    end
                end
                if callback then GuideBattleHelpUtils.LOCK = true end
                if callback then callback(config) end
                
            else
                if ui.eventOutCallback then
                    ui:eventOutCallback()
                end    
            end
        end
    end)
end

-- 拖动事件
function ViewManager:_guide_AddDragEvent(config, ui1, ui2, ui3)
    local begin = false
    local beginx, beginy
    local mc = mcMgr:createViewMC("xuanzhong_selectedanim", true)
    mc:setPosition(ui3:getContentSize().width * 0.5, ui3:getContentSize().height * 0.5)
    ui3:addChild(mc)
    self:guideAddEvent(function (type, _x, _y, sender)
        _x = _x
        -- 伪装事件
        if type == 0 then
            if ui1:isScreenPointInNodeRect(_x, _y) then
                if ui1.eventDownCallback then
                    ui1:eventDownCallback(_x, _y, ui1)
                end
                if ui2.eventDownCallback then
                    ui2:eventDownCallback(_x, _y, ui2)
                end
                if ui2.eventMoveCallback then
                    ui2:eventMoveCallback(_x, _y, ui2)
                end
                begin = true
                beginx = _x
                beginy = _y
            end
        elseif type == 1 then
            -- move
            if ui2.eventMoveCallback then
                ui2:eventMoveCallback(_x, _y, ui2)
            end
        elseif type == 3 then
            -- out
            if begin then
                if ui2.eventOutCallback then
                    ui2:eventOutCallback(beginx, beginy, ui2)
                end
            end
        elseif type == 2 then
            if begin then
                if ui3:isScreenPointInNodeRect(_x, _y) then
                    if config.showtip then
                        self:closeTipEx()
                    end
                    mc:removeFromParent()
                    self:doNextGuide(config)

                    local str = config.dragName3
                    local list = string.split(str, "_")
                    if ui2.eventUpCallback then
                        ui2:eventUpCallback(_x, _y, ui2, tonumber(list[#list]), true)
                    end
                else
                    begin = false
                    if ui2.eventMoveCallback then
                        ui2:eventMoveCallback(beginx, beginy, ui2)
                    end
                    if ui2.eventUpCallback then
                        ui2:eventUpCallback(beginx, beginy, ui2, true)
                    end
                end
            end
        end
    end)
end


function ViewManager:guidePause()
    if self.__guidePause == 0 then
        self._guideLayer:setVisible(false)
        if onGuideUnlock then onGuideUnlock() end
    end
    self.__guidePause = self.__guidePause + 1
end

function ViewManager:guideResume()
    self.__guidePause = self.__guidePause - 1
    if self.__guidePause == 0 then
        if GuideUtils.isGuideRunning then
            if onGuideLock then onGuideLock(self._guideLock) end
            self._guideLock:setTouchEnabled(true)
            self._guideLock:setVisible(true)
        end
        self._guideLayer:setVisible(true)
    end
end

function ViewManager:doGuideClose(config)
    self:doNextGuide(config)
    ScheduleMgr:delayCall(config.delay, self, function()
        self:returnMain()
    end)
end

function ViewManager:doGuideStory(config)
    local view = self._viewLayer:getChildren()[#self._viewLayer:getChildren()].view
    self:enableTalking(config.storyid, view:getHideListInStory(), function ()
        self:guideLock()
        self:doNextGuide(config)
        self:doStoryoverGuide()
    end)
end

function ViewManager:doGuidePrompt(config)
    if config.text then
        local _x = 0
        local _y = 0
        if config.text.x then _x = config.text.x end
        if config.text.y then _y = config.text.y end
        local str = lang(config.text.str)
        if string.find(str, "color=") == nil then
            str = "[color=000000]"..str.."[-]"
        end   
        local label = RichTextFactory:create(str, 1136, 0)
        label:formatText()
        local _w = label:getRealSize().width
        local _h = label:getRealSize().height
        label:setContentSize(_w, _h)
        local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("guideTip_bg.png")
        tipbg:setContentSize(_w + 40, 72)
        label:setPosition((_w + 40)*0.5, 36 + _h * 0.5)
        tipbg:addChild(label, 2)
        local jian = cc.Sprite:createWithSpriteFrameName("guideTip_bg_dir.png")
        jian:setPosition((_w + 40)*0.5, -4)
        tipbg:addChild(jian)
        local __x = MAX_SCREEN_WIDTH * 0.5 + _x
        local __y = MAX_SCREEN_HEIGHT * 0.5 + 44 + _y
        tipbg:setPosition(__x, __y)
        self._guideLayer:addChild(tipbg)
        self._guidePromptCallback = function ()
            self._guidePromptCallback = nil
            tipbg:removeFromParent()
            self:doNextGuide(config)
        end
    end
end

function ViewManager:doFinishGuide(config)
    if config.unLock then
        self:guideUnlock()
    end
    self:guideDelEvent()
    self:guideMaskDisable()

end

function ViewManager:doNextGuide(config)
    self:doFinishGuide(config)

    if GuideUtils.enableTrigger then
        GuideUtils.nextTrigger()
    else
        local curIndex = GuideUtils.guideIndex
        GuideUtils.guideIndex = GuideUtils.guideIndex + 1
        local nextConfig = GuideUtils.getCurConfig()
        if nextConfig and nextConfig.jump then
            GuideUtils.guideIndex = GuideUtils.guideIndex + nextConfig.jump
        end
        if config.save then
            GuideUtils.saveIndex(curIndex + config.save)
        end
        local uploadIndex = SystemUtils.loadAccountLocalData("guideUploadIndex")
        if uploadIndex == nil or uploadIndex == "" then
            uploadIndex = 0
        end
        if curIndex > tonumber(uploadIndex) then
            SystemUtils.saveAccountLocalData("guideUploadIndex", curIndex)
            ApiUtils.playcrab_monitor_action("g"..curIndex)
        end
    end

    ScheduleMgr:delayCall(0, self, function ()
        if ServerManager:getInstance():isSending() then
            ServerManager:getInstance():setGlobalCallback(function ()
                self:doDoneGuide()
            end)
        else
            self:doDoneGuide()
        end
    end)
end



function ViewManager:doGuideBattleStory(config, callback)
    local view = self._viewLayer:getChildren()[#self._viewLayer:getChildren()].view
    self:enableTalking(config.storyid, view:getHideListInStory(), function ()
        if not config.unLock then
            GuideBattleHelpUtils.unLockView(view)
        end
        if callback ~= nil then
            callback()
        end
    end, config.notClose, config.notClose)
end

function ViewManager:doGuideBattleManaTip(config, callback)
    local tip = mcMgr:createViewMC("tip_manatip", true)
    tip:setPosition(MAX_SCREEN_WIDTH - (ADOPT_IPHONEX and 323 or 264), 26)
    tip:setScale(1.2)
    self._guideTipNode:addChild(tip)

    local label = cc.Label:createWithTTF(string.gsub(lang("RUOTIP_03"),"%b[]",""), UIUtils.ttfName, 20)
    label:setColor(cc.c3b(88, 64, 40))
    local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("guideTip_bg.png")
    tipbg:setContentSize(label:getContentSize().width + 40, 72)
    label:setPosition((label:getContentSize().width + 40) * 0.5, 36)
    tipbg:addChild(label, 2)
    local jian = cc.Sprite:createWithSpriteFrameName("guideTip_bg_dir.png")
    jian:setPosition((label:getContentSize().width + 40) * 0.5, -4)
    tipbg:addChild(jian)
    tipbg:setPosition(MAX_SCREEN_WIDTH - (ADOPT_IPHONEX and 323 or 263), 92)
    self._guideTipNode:addChild(tipbg)
    tipbg:setScale(0)
    local x, y = MAX_SCREEN_WIDTH - (ADOPT_IPHONEX and 323 or 263), 92
    tipbg:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.2, 1), 
        cc.MoveTo:create(0.4, cc.p(x, y - 3)), 
        cc.MoveTo:create(0.4, cc.p(x, y)), 
        cc.ScaleTo:create(0.2, 0)))

    ScheduleMgr:delayCall(1400, self, function()
        self._guideTipNode:removeAllChildren()
        local tip = mcMgr:createViewMC("tip_manatip", true)
        tip:setPosition(MAX_SCREEN_WIDTH - (ADOPT_IPHONEX and 234 or 174), 14)
        self._guideTipNode:addChild(tip)

        local label = cc.Label:createWithTTF(string.gsub(lang("RUOTIP_02"),"%b[]",""), UIUtils.ttfName, 20)
        label:setColor(cc.c3b(88, 64, 40))
        local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("guideTip_bg.png")
        tipbg:setContentSize(label:getContentSize().width + 40, 72)
        label:setPosition((label:getContentSize().width + 40) * 0.5, 36)
        tipbg:addChild(label, 2)
        local jian = cc.Sprite:createWithSpriteFrameName("guideTip_bg_dir.png")
        jian:setPosition((label:getContentSize().width + 40) * 0.5, -2)
        tipbg:addChild(jian)
        tipbg:setPosition(MAX_SCREEN_WIDTH - (ADOPT_IPHONEX and 234 or 174), 150)
        self._guideTipNode:addChild(tipbg)
        tipbg:setScale(0)
        local x, y = MAX_SCREEN_WIDTH - (ADOPT_IPHONEX and 234 or 174), 150
        tipbg:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.2, 1), 
            cc.MoveTo:create(0.4, cc.p(x, y - 3)), 
            cc.MoveTo:create(0.4, cc.p(x, y)), 
            cc.ScaleTo:create(0.2, 0)))

        ScheduleMgr:delayCall(1400, self, function()
            self._guideTipNode:removeAllChildren()
            if callback then
                callback()
            end
        end)
    end)
end

function ViewManager:doGuideBattleClick(config, inView, callback)
    self:guideLock()
    ScheduleMgr:delayCall(config.delay, self, function()
        local ui = self:getGuideUIByFullName(self._rootLayer, config.clickName)
        if ui == nil then 
            self:guideUnlock()
            return
        end
        local w, h = self:_guide_getRealSize(ui)
        local pt = ui:convertToWorldSpace(cc.p(0, 0))
        local x, y = pt.x, pt.y
        self:guideMaskEnable(x + w * 0.5, y + h * 0.5, w, h, config.mask)

        x, y, w, h = self:_guide_clickArea(config, x, y, w, h)

        self:_guide_talk(config, x, y, w, h)
        if config.talk and config.shouzhi then
            ScheduleMgr:delayCall(guide_click_delay, self, function()
                if config.shouzhi then
                    local shouzhi = mcMgr:createViewMC("click_battleguide", true)
                    shouzhi:setPosition(x + w * 0.5, y + h * 0.5 + 13)
                    self._guideTipNode:addChild(shouzhi)
                end
                self:_guide_Addevent(false, config, ui, x, y, w, h, callback, 0, 0)
            end)
        else
            if config.shouzhi then
                local shouzhi = mcMgr:createViewMC("click_battleguide", true)
                shouzhi:setPosition(x + w * 0.5, y + h * 0.5 + 13)
                self._guideTipNode:addChild(shouzhi)
            end
            self:_guide_Addevent(false, config, ui, x, y, w, h, callback, 0, 0)
        end
    end)
end


-- 战斗专用
function ViewManager:doGuideBattlePoint(config, inView, inTransformCallback, callback)
    self:guideLock()
    ScheduleMgr:delayCall(config.delay, self, function()
        if config.point == nil then 
            self:guideUnlock()
            return
        end
        local ui = self:getGuideUIByFullName(self._rootLayer, config.clickName)
        if ui == nil then 
            self:guideUnlock()
            return
        end
        local w = config.size.w
        local h = config.size.h
        local x, y = inTransformCallback(config.point.x, config.point.y)

        self:guideMaskEnable(x, y, w, h, config.mask)

        x, y, w, h = self:_guide_clickArea(config, x, y, w, h)
        self:_guide_talk(config, x, y, w, h)
        if config.talk and config.shouzhi then
            ScheduleMgr:delayCall(guide_click_delay, self, function()
                if config.shouzhi then
                    local circle = mcMgr:createViewMC("circle_battleguide", true)
                    circle:setPosition(x, y)
                    self._guideTipNode:addChild(circle)

                    local shouzhi = mcMgr:createViewMC("click_battleguide", true)
                    shouzhi:setPosition(x, y)
                    shouzhi:setRotation(120)
                    self._guideTipNode:addChild(shouzhi)
                end
                self:_guide_Addevent(false, config, ui, x, y, w, h, callback, w * 0.5, h * 0.5, true)
            end)
        else
            if config.shouzhi then
                local circle = mcMgr:createViewMC("circle_battleguide", true)
                circle:setPosition(x, y)
                self._guideTipNode:addChild(circle)

                local shouzhi = mcMgr:createViewMC("click_battleguide", true)
                shouzhi:setPosition(x, y)
                shouzhi:setRotation(120)
                self._guideTipNode:addChild(shouzhi)
            end

            self:_guide_Addevent(false, config, ui, x, y, w, h, callback, w * 0.5, h * 0.5, true)
        end
    end)
end

-- 拖动引导
function ViewManager:showDragGuide(scaleui1, scaleui2, x1, y1, x2, y2)
    local tan = 0.04
    local arrow = cc.Sprite:createWithSpriteFrameName("guideImage_arrow.png")
    arrow:setAnchorPoint(0.5, 0)
    arrow:setPosition(x1, y1)
    local angle = math.deg(-math.atan((y2 - y1) / (x2 - x1)))
    if x2 - x1 > 0 then
        arrow:setRotation(angle + 90)
    else
        arrow:setRotation(180 + angle + 90)
    end
    local dis = math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1))
    arrow:setScale(0)
    local destScale = dis / 383
    local scale2 = destScale
    if scale2 < 0.5 then
        scale2 = 0.5
        destScale = destScale * 1.25
    end
    arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.5,  scale2, destScale * (1 + tan)),
                     cc.ScaleTo:create(0.05, scale2, destScale),  
                     cc.DelayTime:create(0.8), 
                     cc.ScaleTo:create(0, 0.5, 0))))

    local shouzhi = cc.Sprite:createWithSpriteFrameName("guideImage_shou.png")
    shouzhi:setAnchorPoint(1, 0.8)
    shouzhi:setPosition(x1, y1)
    if x2 - x1 > 0 then
        shouzhi:setRotation(angle - 90)
    else
        shouzhi:setRotation(180 + angle - 90)
    end
    local a = math.atan((y2 - y1) / (x2 - x1))
    local sina = math.sin(a)
    local cosa = math.cos(a)
    local walkDis = dis * tan
    local bx, by
    if x2 > x1 then
        bx = x2 + walkDis * cosa
        by = y2 + walkDis * sina
    else
        bx = x2 - walkDis * cosa
        by = y2 - walkDis * sina
    end
    shouzhi:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(bx, by)),
                     cc.MoveTo:create(0.05, cc.p(x2, y2)),  
                     cc.DelayTime:create(0.8), 
                     cc.MoveTo:create(0, cc.p(x1, y1)))))
    self._guideTipNode:addChild(arrow)
    self._guideTipNode:addChild(shouzhi)

    if scaleui1 then
        local rect = cc.Sprite:createWithSpriteFrameName("guideImage_rect.png")
        rect:setPosition(scaleui1:getContentSize().width * 0.5 + 3, scaleui1:getContentSize().height * 0.5 + 2)
        rect:setScale(1.05)
        rect:setOpacity(0)
        scaleui1:addChild(rect)
        rect:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.FadeIn:create(0.675),
            cc.FadeOut:create(0.675)
        )))
        scaleui1:runAction(cc.RepeatForever:create(cc.Sequence:create(
                         cc.ScaleTo:create(0.1, 1),  
                         cc.DelayTime:create(1.25), 
                         cc.ScaleTo:create(0, 0.8))))
    end
end

local find = string.find
function ViewManager:getGuideUIByFullName(view, name)
    local fullName = view:getFullName()
    if fullName == name then return view end
    if string.find(name, fullName) == nil then return nil end
    for i = 1, #view:getChildren() do
        local ret = self:getGuideUIByFullName(view:getChildren()[i], name)
        if ret then
            return ret
        end
    end
    return nil
end

-- 强制中断引导, 之后也不会触发了
function ViewManager:breakOffGuide()
    self:guideUnlock()
    self:guideMaskDisable()
    if GuideUtils.ENABLE then
        GuideUtils.ENABLE = false
        GuideUtils.guideChange = 10000
    end
    if GuideUtils.ENABLE_TRIGGER then
        GuideUtils.ENABLE_TRIGGER = false
        if GuideUtils.enableTrigger then
            GuideUtils.breakTrigger()
        end
    end
    if self._breakUI then
        self._breakUI:setTouchEnabled(true)
        self._breakUI = nil
    end
    ServerManager:getInstance():sendMsg("UserServer", "getEmptyInfo", {}, true)
end

function ViewManager:enableBlack()
    if self._curtainLayer == nil then
        self._curtainLayer = require("game.view.intance.IntanceGuideCurtainLayer").new()
        self._rootLayer:addChild(self._curtainLayer)
        self._curtainLayer:doPlay()
    end
end

-- 对话, hideList为需要隐藏的UI
function ViewManager:enableTalking(talkId, hideList, callback, notClose, noJump)
    self:pauseGlobalDialog()
    local guideStoryConfig = require "game.config.guide.GuideStoryConfig"
    if guideStoryConfig[talkId] == nil then 
        if callback ~= nil then callback() end
        return 
    end

    if hideList then
        for i = 1, #hideList do
            hideList[i]:setVisible(false)
        end
    end
    self._talkingHideList = hideList
    self._navigationLayer:setVisible(false)

    local tempTalkContent = {}
    for k,v in pairs(guideStoryConfig[talkId]) do
        -- 5 roleImg1 6 anchor 7 color 8 zoom 缩放 9 name 名字 10 namePos名字位置, 11 flip 翻转 新增by guojun
        -- 12 textOffset
        table.insert(tempTalkContent, {
            v.side, 
            lang(v.talk),
            v.roleImg, 
            v.sound, 
            v.roleImg1, 
            v.anchor, 
            v.color, 
            v.zoom,
            v.name,
            v.namePos,
            v.flip,
            v.textOffset,
        })
    end

    if self._curtainLayer == nil then
        self._curtainLayer = require("game.view.intance.IntanceGuideCurtainLayer").new()
        self._rootLayer:addChild(self._curtainLayer)
        self._curtainLayer:play()
    end

    local data = {
        talkContent = tempTalkContent,
        stepCallback = function()

        end, 
        finishCallback = function(inCloseType) 
            pcall(function () self:resumeGlobalDialog() end)
            if notClose then
                if callback then callback() end
            else
                self:lock(-4)
                self._curtainLayer:reversePlay(function ()
                    self._curtainLayer:removeFromParent()
                    self._curtainLayer = nil
                    self._talkLayer:removeFromParent()
                    self._talkLayer = nil

                    if hideList then
                        for i = 1, #hideList do
                            hideList[i]:setVisible(true)
                        end
                    end
                    self._navigationLayer:setVisible(true)
                    self:unlock(-4)
                    if callback then callback(inCloseType) end
                end)
            end
    end}
    if self._talkLayer == nil then
        self._talkLayer = require("game.view.intance.IntanceGuideTalkLayer").new(data)
        self._rootLayer:addChild(self._talkLayer)
    else
        self._talkLayer:resetData(data)
    end
    self._talkLayer:play(notClose, noJump)
    return self._curtainLayer
end

function ViewManager:disableTalking(callback)
    if self._curtainLayer then
        self:lock(-5)
        self._curtainLayer:reversePlay(function ()
            self._curtainLayer:removeFromParent()
            self._curtainLayer = nil
            self._talkLayer:removeFromParent()
            self._talkLayer = nil

            if self._talkingHideList then
                for i = 1, #self._talkingHideList do
                    self._talkingHideList[i]:setVisible(true)
                end
            end
            self._navigationLayer:setVisible(true)
            self:unlock(-5)
            if callback then callback() end
        end)
    else
        if callback then callback() end
    end
end

-- lua报错收集
function ViewManager:onLuaError(msg)
    if not GameStatic.showLuaError then return end
    if self._errorLayer == nil then return end
    if self._luaError == nil then
        self._luaError = {msg}
        self._luaErrorCount = 1
    else
        self._luaErrorCount = self._luaErrorCount + 1
        self._luaErrorBtn.label:setString(self._luaErrorCount)
        for i = 1, #self._luaError do
            if self._luaError[i] == msg then
                return
            end
        end
        self._luaError[#self._luaError + 1] = msg
    end
    if self._luaErrorBtn == nil then
        self._luaErrorBtn = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
        self._errorLayer:addChild(self._luaErrorBtn)
        self._luaErrorBtn:setAnchorPoint(0.5, 1)
        self._luaErrorBtn:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT)
        self._luaErrorBtn:setTitleColor(cc.c3b(0, 0, 0))
        self._luaErrorBtn:setTitleFontSize(20)
        self._luaErrorBtn:setTitleFontName(UIUtils.ttfName)

        local image = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
        local label = cc.Label:createWithTTF("1", UIUtils.ttfName, 15)
        label:setColor(cc.c3b(255, 255, 255))
        label:setPosition(15, 17)
        label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        image:addChild(label)
        image:setPosition(self._luaErrorBtn:getContentSize().width - 5, self._luaErrorBtn:getContentSize().height - 14)
        self._luaErrorBtn:addChild(image)
        self._luaErrorBtn.label = label

        self._luaErrorBtn:setTitleText("lua error")
        registerClickEvent(self._luaErrorBtn, function ()
            self:showLuaError()
        end)
    end
end

function ViewManager:showLuaError()
    local view = require("game.view.global.ErrorView").new()
    view:initUI("global.ErrorView", false, function ()
        view:reflashUI({msg = self._luaError})
        view:onShow()
        view:doPop()
        self._errorLayer:addChild(view)
    end)
    self._luaError = nil
    self._luaErrorBtn:removeFromParent()
    self._luaErrorBtn = nil
    self._luaErrorCount = 0
end

-- 防沉迷
function ViewManager:enableIndulge()
    self._indulgeEnable = true
    if self._indulgeStatus ~= nil then
        self:onIndulge(self._indulgeStatus,self._indulgeInfo)
        self._indulgeStatus = nil
        self._indulgeInfo = nil
    end
end

function ViewManager:disableIndulge()
    self._indulgeEnable = false
end

function ViewManager:onIndulge(status,info)
    if #self._indulgeLayer:getChildren() > 0 then 
        local layer = self._indulgeLayer:getChildren()[1]
        if layer then
            self._indulgeLayer:removeAllChildren()
            self._isIndulgePopViewShow = false
        end
    end
    if not self._indulgeEnable then
        self._indulgeStatus = status or 1
        self._indulgeInfo = info or nil
        return
    end
    self._isIndulgePopViewShow = true
    self:guidePause()
    local mask = ccui.Layout:create()
    mask:setBackGroundColorOpacity(100)
    mask:setBackGroundColorType(1)
    mask:setBackGroundColor(cc.c3b(0,0,0))
    mask:setContentSize(MAX_SCREEN_WIDTH + 200, MAX_SCREEN_HEIGHT)
    mask:setOpacity(0)
    self._indulgeLayer:addChild(mask)   
    mask:runAction(cc.FadeIn:create(0.5))

    -- info.is_adult 成年 1 未成年 0 无信息 2
    local adultNum = info and info.is_adult or 0
    local awake = info and info.a or 0
    local t = info and info.t or 0
    local desc
    local isExit
    if status == 1 then
        desc = lang("JIANKANGXITONG_3") --"您今日在线时间已达六小时，请注意休息" --
    elseif status == 2 then
        desc = lang("JIANKANGXITONG_1") --"您本次在线时间已达两小时，请注意休息" --
    else
        -- 需要休息的时间
        dump(info or {})
        local desMap = {
            [3] = lang("JIANKANGXITONG_4"),
            [4] = lang("JIANKANGXITONG_2"),
            [5] = lang("JIANKANGXITONG_7"),
            [6] = lang("JIANKANGXITONG_5"),
        }
        if desMap[status] then -- 累计强制下线
            desc = desMap[status]
            isExit = true
        end

    end
    print(desc)
    desc = string.gsub(desc,"%b{}",function( catchStr )
        local result = string.gsub(catchStr,"{","")
        result = string.gsub(result,"}","")
        result = string.gsub(result,"$time1",math.floor(t/1800)/2)
        result = string.gsub(result,"$time2",math.ceil(awake/60))
        if adultNum == 0 and status == 5 then -- 宵禁特做显示
            local nextSec = awake
            local nextTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()+nextSec
            nextTime = nextTime-nextTime%60
            timeStr = TimeUtils.getDateString(nextTime)
            result = string.gsub(result,"$time",timeStr)
        else
            result = string.gsub(result,"$time",math.floor(t/1800)/2)
        end
        return result
    end)            
    local view = require("game.view.global.NetWorkDialog").new(
        {msg = desc, callback = function ()
            self:guideResume()
            self._indulgeLayer:removeAllChildren()
            self._isIndulgePopViewShow = false
            if isExit then
                AppExit()
            end
        end})
    view:initUI("global.NetWorkDialog", false, function ()
        view:onShow()
        view:doPop()
        self._indulgeLayer:addChild(view)
    end)
    if isExit then
        ScheduleMgr:delayCall(5000, self, function()
            AppExit()
        end)
    end
end

function ViewManager:applicationDidBecomeActive()
    for i = 1, #self._viewLayer:getChildren() do
        self._viewLayer:getChildren()[i].view:applicationDidBecomeActive()
    end
end


function ViewManager:applicationDidEnterBackground()
    if self._viewLayer then
        local views = self._viewLayer:getChildren()
        for i = 1, #views do
            views[i].view:applicationDidEnterBackground()
            if views[i].view then views[i].view:applicationDidEnterBackground_popView() end
        end
    end
    if self._navigationLayer then
        for i = 1, #self._navigationLayer:getChildren() do
            self._navigationLayer:getChildren()[i]:applicationDidEnterBackground()
        end
    end
end

function ViewManager:applicationWillEnterForeground(second)
    -- 切入后台超过4小时则强制重新登录
    print("viewMgr applicationWillEnterForeground, hour: ", second / 60 / 60)
    if second > 4 * 60 * 60 then
        -- ServerManager:getInstance():_restart("登录信息过期, 请重新登录")
        ViewManager:getInstance():restart() 
        return
    end
    local views = self._viewLayer:getChildren()
    for i = 1, #views do
        views[i].view:applicationWillEnterForeground(second)
        if views[i].view then views[i].view:applicationWillEnterForeground_popView(second) end
    end
    for i = 1, #self._navigationLayer:getChildren() do
        self._navigationLayer:getChildren()[i]:applicationWillEnterForeground(second)
    end
end

-- 断线重连后调用
function ViewManager:onReconnect()
    local views = self._viewLayer:getChildren()
    for i = 1, #views do
        views[i].view:onReconnect()
    end 
end

function ViewManager:sdk_need_login(data)
    if data then
        pcall(function ()
            local platform = cjson.decode(data)
            local flag = platform.flag
            platform = platform.platform
            if flag == "0" or flag == "3004" or flag == "3002" then
                return
            end
            if self._viewLayer:getChildren()[1].view:getClassName() == "login.LoginView" then
                self._viewLayer:getChildren()[1].view:sdk_need_login(platform, flag)
            else
                self:restart()
            end
        end)
    else
        self:restart()
    end
end


function ViewManager:walleUpgradeUI(viewname, param)
    if self._disableChangeView then return end
    local popView = false
    if viewname == nil then
        if self._viewLayer:getChildren()[1].view:getClassName() == "login.LoginView" then
            self._viewLayer:getChildren()[1].view:changeWallUpUIState()
        end
    end
end


function ViewManager.dtor()
    HOTKEY_LABEL = nil
    keyDown = nil
    keyTab = nil
    _viewManager = nil
    find = nil
    fu = nil
    guide_click_delay = nil
    MAX_MEMORY_VALUE = nil
    sfc = nil
    tc = nil
    ViewManager = nil
    Z_Click = nil
    Z_Debug = nil
    Z_Error = nil
    Z_Guide = nil
    Z_Hint = nil
    Z_Lock = nil
    Z_Navigation = nil
    Z_Notice = nil
    Z_Other = nil
    Z_Tip = nil
    Z_GlobalDialog = nil
    onGuideLock = nil
    onGuideUnlock = nil
    getGuideLock = nil
end

return ViewManager