--[[
    Filename:    BaseEvent.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-05-21 17:54:13
    Description: File description
--]]
local cc = cc
local BaseEvent = class("BaseEvent")

local luabridge
local I18N = I18N
local platform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_IPHONE == platform
    or cc.PLATFORM_OS_IPAD == platform then
    luabridge = require "cocos.cocos2d.luaoc"
elseif cc.PLATFORM_OS_ANDROID == platform then
    luabridge = require "cocos.cocos2d.luaj"
end

local isMultipleTouchEnabled = false
-- 防止多点触控UI
local curView = nil

local PRESSLONG_TIME = 0.2

function setMultipleTouchEnabled()
    isMultipleTouchEnabled = true
    curView = nil
    if cc.PLATFORM_OS_IPHONE == platform
        or cc.PLATFORM_OS_IPAD == platform then
        luabridge.callStaticMethod("AppController", "setMultipleTouchEnabled")
    elseif cc.PLATFORM_OS_ANDROID == platform then
        luabridge.callStaticMethod("org/cocos2dx/lib/Cocos2dxGLSurfaceView", "setMultipleTouchEnabled", {}, "()V")
    end
end

function setMultipleTouchDisabled()
    isMultipleTouchEnabled = false
    curView = nil
    if cc.PLATFORM_OS_IPHONE == platform
        or cc.PLATFORM_OS_IPAD == platform then
        luabridge.callStaticMethod("AppController", "setMultipleTouchDisabled")
    elseif cc.PLATFORM_OS_ANDROID == platform then
        luabridge.callStaticMethod("org/cocos2dx/lib/Cocos2dxGLSurfaceView", "setMultipleTouchDisabled", {}, "()V")
    end
end

local EventUp_Delay = 0
function setEventUpDelayEnabled()
    EventUp_Delay = 0
end

function setEventUpDelayDisabled()
    EventUp_Delay = 0
end

-- 新手引导防止点穿
-- 在ios环境下, 有可能出现点穿带事件蒙板的情况
local __guideLock = nil
function onGuideLock(lockView)
    __guideLock = lockView
end

function onGuideUnlock()
    __guideLock = nil
end

function getGuideLock()
    return __guideLock
end

function BaseEvent:ctor()
    BaseEvent.super.ctor(self)

end

function BaseEvent:getUI(name)
    return self._widget:getChildByFullName(name)
end

function BaseEvent:registerUI(names)
    if names then
        for _,data in pairs (names) do 
            self["_"..data[1]] = self:getUI(data[2])
        end
    end
end

--- 事件相关 ---
-- 可以注册touch事件与click事件
-- touch事件会回传坐标
-- 触摸事件

function BaseEvent:registerTouchEvent(view, downCallback, moveCallback, upCallback, outCallback, longCallback)
    registerTouchEvent(view, downCallback, moveCallback, upCallback, outCallback, longCallback)
end

ccui.Widget.setScaleAnimMin = function (widget, scaleMin)
    widget.__scaleMin = scaleMin
end

local function ButtonBeginAnim(view)
    if view:isScaleAnim() then
        local ax, ay = view:getAnchorPoint().x, view:getAnchorPoint().y
        if ax == 0.5 and ay == 0.5 then
            if view.__oriScale == nil then
                view.__oriScale = view:getScaleX()
            end
            local scaleMin = 0.92
            if view.__scaleMin then
                scaleMin = view.__scaleMin
            end
            view:stopAllActions()
            view:setScale(view.__oriScale * 0.98)
            view:runAction(cc.EaseIn:create(cc.ScaleTo:create(0.05, view.__oriScale * scaleMin), 2))
        end
    end
end

local function ButtonEndAnim(view)
    if view:isScaleAnim() then
        local ax, ay = view:getAnchorPoint().x, view:getAnchorPoint().y
        if ax == 0.5 and ay == 0.5 then
            view:stopAllActions()
            if view.__oriScale then
                local scaleMin = 0.92
                if view.__scaleMin then
                    scaleMin = view.__scaleMin
                end
                local rate = 1 - ((view:getScaleX() - view.__oriScale * scaleMin) / (view.__oriScale * 0.2))
                view:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale * (1.00 + 0.03 * rate)), 
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale * (1.00 - 0.03 * rate)),
                    cc.ScaleTo:create(0.02 + 0.03 * rate, view.__oriScale)
                ))
            end
        end
    end
end

local presslongScheduleId

local function scheduleEnd()
    if presslongScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(presslongScheduleId) 
        presslongScheduleId = nil
    end
end

local function scheduleBegin(view, callback)
    scheduleEnd()
    local time = PRESSLONG_TIME
    if view.pressLongTime then
        time = view.pressLongTime
    end
    presslongScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(presslongScheduleId)
        view.__disableUp = true
        -- ButtonEndAnim(view)
        if callback then callback() end
    end, time, false)
end

local function _getRealSize(ui)
    local pt1 = ui:convertToWorldSpace(cc.p(0, 0))
    local w = ui:getContentSize().width
    local h = ui:getContentSize().height
    local pt2 = ui:convertToWorldSpace(cc.p(w, h))
    return pt2.x - pt1.x, pt2.y - pt1.y
end

GLOBAL_VALUES.last_click_ui_name = {}
local last_click_ui_name_index = 1

function registerTouchEvent(view, downCallback, moveCallback, upCallback, outCallback, longCallback)
    view:setTouchEnabled(true)
    view.eventDownCallback = function (...)
        if SHOW_UI_DETAILS then
            print( )
            print("name　"..view:getFullName())
            print("size　"..view:getContentSize().width.."　"..view:getContentSize().height)
            print("ap　"..view:getAnchorPoint().x.."　"..view:getAnchorPoint().y)
            print("pos　"..view:getPositionX().."　"..view:getPositionY())
            print("class　"..view:getDescription())
        end
        if GameStatic.btnClose and GameStatic.btnClose ~= "" then
            local __fullname = view:getFullName()
            local list = string.split(GameStatic.btnClose, ":")
            for i = 1, #list do
                if __fullname == list[i] then
                    ViewManager:getInstance():showTip(GameStatic.closeTip)
                    return false
                end
            end
        end
        ButtonBeginAnim(view)
        ViewManager:getInstance():showName(view, view:getFullName())
        if not view.noSound then
            audioMgr:playSound("click")
        end
        if downCallback then
            downCallback(...)
        end
    end
    view.eventMoveCallback = function (...)
        if moveCallback then
            moveCallback(...)
        end
    end
    -- now 是为了应付新手引导
    view.eventUpCallback = function (_, x, y, ui, now)
        if GameStatic.btnClose and GameStatic.btnClose ~= "" then
            local __fullname = view:getFullName()
            local list = string.split(GameStatic.btnClose, ":")
            for i = 1, #list do
                if __fullname == list[i] then
                    return false
                end
            end
        end
        if GLOBAL_VALUES and GLOBAL_VALUES.last_click_ui_name then
            GLOBAL_VALUES.last_click_ui_name[last_click_ui_name_index] = {view:getFullName(), os.time()}
            last_click_ui_name_index = last_click_ui_name_index + 1
            if last_click_ui_name_index > 10 then last_click_ui_name_index = 1 end
        end
        ButtonEndAnim(view)
        local name = view:getFullName()
        if upCallback then
            if EventUp_Delay > 0 and not now then
                ViewManager:getInstance():lock(-1)
                ScheduleMgr:delayCall(EventUp_Delay, self, function()
                    ViewManager:getInstance():unlock()
                    upCallback(_, x, y, ui)
                end)
            else
                upCallback(_, x, y, ui)
            end
        end 
        if UIUtils == nil then 
            return 
        end
        if UIUtils.autoCloseTip then   
            ViewManager:getInstance():closeHintView()
        end
        GuideUtils.checkTriggerByType("btn", name)
    end
    view.eventOutCallback = function (...)
        ButtonEndAnim(view)
        if outCallback then
            outCallback(...)
        end 
        if UIUtils.autoCloseTip then   
            ViewManager:getInstance():closeHintView()
        end   
    end
    local handleLongPress = (longCallback ~= nil)
    view:addRemoveEventListener(function ()
        if handleLongPress then
            scheduleEnd() 
        end
        if curView == view then
            curView = nil
        end
    end)
    view:addTouchEventListener(function (sender, eventType)
        if isMultipleTouchEnabled then
            if eventType == 0 then
                if curView == nil then
                    curView = sender
                end
                if curView ~= sender then 
                    if curView.isVisible and curView:isVisible() == false then
                        curView = nil
                    end
                    return 
                end
                sender.isDown = true
                sender.__disableUp = nil
                -- down
                if sender.eventDownCallback == nil then return end
                sender:eventDownCallback(sender:getTouchBeganPosition().x, sender:getTouchBeganPosition().y, sender)
                if handleLongPress then 
                    sender.__longPress = true
                    scheduleBegin(sender, longCallback) 
                end
            elseif eventType == 1 then
                if curView ~= sender then return end
                -- move
                if sender.isDown then
                    if sender.eventMoveCallback == nil then return end
                    sender:eventMoveCallback(sender:getTouchMovePosition().x, sender:getTouchMovePosition().y, sender)
                    if handleLongPress and sender.__longPress then
                        local x, y = sender:getTouchMovePosition().x, sender:getTouchMovePosition().y
                        local _pt = sender:convertToWorldSpace(cc.p(0, 0))
                        local _x, _y = _pt.x, _pt.y
                        local w, h = _getRealSize(sender)
                        if x < _x or y < _y or x > _x + w or y > _y + h then
                            sender.__longPress = false
                            scheduleEnd()
                        end
                    end
                end
            elseif eventType == 2 then
                if curView ~= sender then return end
                curView = nil
                -- up
                if sender.isDown then
                    sender.isDown = false
                    -- if sender.__disableUp then return end
                    if sender.eventUpCallback == nil then return end
                    sender:eventUpCallback(sender:getTouchEndPosition().x, sender:getTouchEndPosition().y, sender)
                    if handleLongPress then 
                        sender.__longPress = false
                        scheduleEnd() 
                    end
                end
            elseif eventType == 3 then
                if curView ~= sender then return end
                curView = nil
                -- out
                if sender.isDown then
                    sender.isDown = false
                    -- if sender.__disableUp then return end
                    if sender.eventOutCallback == nil then return end
                    sender:eventOutCallback(sender:getTouchEndPosition().x, sender:getTouchEndPosition().y, sender)
                    if handleLongPress then 
                        sender.__longPress = false
                        scheduleEnd() 
                    end
                end
            end
        else
            if __guideLock and __guideLock ~= sender then return end
            if eventType == 0 then
                -- down
                sender.__disableUp = nil
                if sender.eventDownCallback == nil then return end
                sender:eventDownCallback(sender:getTouchBeganPosition().x, sender:getTouchBeganPosition().y, sender)
                if handleLongPress then 
                    sender.__longPress = true
                    scheduleBegin(sender, longCallback) 
                end
            elseif eventType == 1 then
                -- move
                if sender.eventMoveCallback == nil then return end
                sender:eventMoveCallback(sender:getTouchMovePosition().x, sender:getTouchMovePosition().y, sender)
                if handleLongPress and sender.__longPress then
                    local x, y = sender:getTouchMovePosition().x, sender:getTouchMovePosition().y
                    local _pt = sender:convertToWorldSpace(cc.p(0, 0))
                    local _x, _y = _pt.x, _pt.y
                    local w, h = _getRealSize(sender)
                    if x < _x or y < _y or x > _x + w or y > _y + h then
                        sender.__longPress = false
                        scheduleEnd()
                    end
                end
            elseif eventType == 2 then
                -- up
                -- if sender.__disableUp then return end
                if sender.eventUpCallback == nil then return end
                sender:eventUpCallback(sender:getTouchEndPosition().x, sender:getTouchEndPosition().y, sender)
                if handleLongPress then 
                    sender.__longPress = false
                    scheduleEnd() 
                end
            elseif eventType == 3 then
                -- out
                -- if sender.__disableUp then return end
                if sender.eventOutCallback == nil then return end
                sender:eventOutCallback(sender:getTouchEndPosition().x, sender:getTouchEndPosition().y, sender)
                if handleLongPress then 
                    sender.__longPress = false
                    scheduleEnd() 
                end
            end
        end
    end)
end

function BaseEvent:registerTouchEventByName(name, downCallback, moveCallback, upCallback, outCallback, longCallback)
    local view = self:getUI(name)
    if view then
        self:registerTouchEvent(view, downCallback, moveCallback, upCallback, outCallback, longCallback)
    end
end

-- 点击事件
function BaseEvent:registerClickEvent(view, callback)
    registerClickEvent(view, callback)
end

function registerClickEvent(view, callback)
    registerTouchEvent(view, nil, nil, function (...)
        if callback then
            callback(...)
        end
    end)
end

function BaseEvent:registerClickEventByName(name, callback)
    local view = self:getUI(name)
    if view then
        self:registerClickEvent(view, callback)
    end
end

-- 长按事件
function registerPressLongEvent(view, callback)
    registerTouchEvent(view, nil, nil, nil, nil, function (...)
        if callback then
            callback(...)
        end
    end)
end

function BaseEvent:registerPressLongEvent(view, callback)
    registerPressLongEvent(view, callback)
end

function BaseEvent:registerPressLongEventByName(name, callback)
    local view = self:getUI(name)
    if view then
        self:registerPressLongEvent(view, callback)
    end
end

-- 替换字符串和字体
local sub = string.sub
local len = string.len
local ttf = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local ttf_title = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local ttf_number = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
local inputBoxBg = nil -- 用于在键盘弹出时显示的输入框
local inputBox = nil
local inputCur = nil
local TextField = nil
function closeGlobalInputBox()
    if inputBoxBg then
        inputBoxBg:removeFromParent()
        inputBoxBg = nil
    end
    if TextField then
        pcall(function () TextField:didNotSelectSelf() end)
        TextField = nil
    end
end

function isInputBoxEnable()
    return TextField ~= nil
end
  
local color1 = cc.c4b(136, 20, 10, 255)     -- button_1_1 button_1_2
local color2 = cc.c4b(115, 63, 32, 255)     -- button_3_1 button_3_2
local color3 = cc.c4b(1, 67, 128, 255)      -- button_2_1 button_2_2
local color4 = cc.c4b(85, 38, 10, 255)      -- button_float_o

local btnColor = cc.c4b(255,243,229,255)

local button_1_1 = "globalButtonUI13_1_1.png" -- 带框确定
local button_1_2 = "globalButtonUI13_1_2.png" -- 确定
local button_3_1 = "globalButtonUI13_3_1.png" -- 带框取消
local button_3_2 = "globalButtonUI13_3_2.png" -- 取消
local button_2_1 = "globalButtonUI13_2_1.png" -- 带框前往
local button_2_2 = "globalButtonUI13_2_2.png" -- 前往

local button_float_o = "globalButtonUI7_float_yellow.png"   -- 三级 

local button_tab_l = "globalBtnUI4_page1_n.png"   -- 页签左 
local button_tab_r = "TeamBtnUI_tab_n.png"        -- 页签右

local BaseEvent_L10N_Text
function BaseEvent:L10N_Text(root)
    if root == nil then
        root = self._widget
    end
    local color
    local desc = root:getDescription()
    if desc == "Label" then
        local str = root:getString()
        if I18N[str] then
            root:setString(I18N[str])
        end
    elseif desc == "Button" then
        root:setTitleColor(btnColor)
        local textureName = root:getNormalTextureName()
        if button_1_1 == textureName or button_1_2 == textureName then
            root:enableOutline(color1, 2)
        elseif button_3_1 == textureName   or button_3_2 == textureName then
            root:enableOutline(color2, 2)
        elseif button_2_1 == textureName   or button_2_2 == textureName then
            root:enableOutline(color3, 2)
        elseif button_float_o == textureName then
            root:enableOutline(color4, 1)
        elseif button_tab_l == textureName then
            root:setTitleFontSize(24)  
            root:getTitleRenderer():disableEffect()
        elseif button_tab_r == textureName then
            root:setTitleFontSize(24)  
            root:getTitleRenderer():disableEffect()
        else 
            root:enableOutline(color4, 2)
        end
        local str = root:getTitleText()
        if I18N[str] then
            root:setTitleText(I18N[str])
        end
    else
        if desc == "TextField" then
            if true then
            -- if cc.PLATFORM_OS_IPHONE == platform
            --     or cc.PLATFORM_OS_IPAD == platform or 
            --     cc.PLATFORM_OS_WINDOWS == platform then
                -- 重写该方法
                root.__addEventListener = root.addEventListener
                root.addEventListener = function (_, callback)
                    root.__callback = callback
                end
                local str = root:getString()
                if I18N[str] then
                    root:setString(I18N[str])
                end
                local str = root:getPlaceHolder()
                if I18N[str] then
                    root:setPlaceHolder(I18N[str])
                end
                root.__setString = root.setString
                root.setString = function(sender, param)
                    sender:__setString(param)
                    sender:checkString(param)
                end
                root.checkString = function (sender, param)
                    if string.len(param) <= 0 then 
                        if sender.rectifyPos == true then
                            sender:setPosition(0, sender:getPositionY())
                        end
                        return
                    end
                    if sender.openCustom ~= true then
                        return
                    end
                    if sender:isMaxLengthEnabled() then
                        if (utf8.len(param) > (sender:getMaxLength() - 1)) then
                            if sender.handleLen ~= nil then 
                                sender:handleLen(param)
                            else
                                sender:setString(utf8.sub(param, 1 , (sender:getMaxLength() - 1)))
                            end
                            if sender.maxLengTip ~= nil then 
                                ViewManager:getInstance():showTip(sender.maxLengTip)
                            else
                                ViewManager:getInstance():showTip("字数上限为:" .. (sender:getMaxLength() - 1) .. "个字")
                            end
                        end                
                    end
                    if sender.rectifyPos == true then 
                        if sender:getContentSize().width >= sender:getParent():getContentSize().width then 
                            sender:setPosition(sender:getParent():getContentSize().width - sender:getContentSize().width, sender:getPositionY())
                        else
                            sender:setPosition(0, sender:getPositionY())
                        end
                    end
                end
                local function createInputBox(str)
                    -- 避免快速切换输入与隐藏输入框时可能会出现的重复添加inpoutBoxBg
                    if inputBoxBg ~= nil then return end
                    TextField = root
                    inputBoxBg = cc.Scale9Sprite:createWithSpriteFrameName("globalImage_input.png")
                    inputBoxBg:setContentSize(MAX_SCREEN_WIDTH, 59)

                    inputBoxBg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 59 * 0.5)
                    inputBoxBg:setLocalZOrder(99999)
                    ViewManager:getInstance():getRootLayer():addChild(inputBoxBg)

                    inputBox = cc.Label:createWithTTF(str, UIUtils.ttfName, 24)
                    inputBox:setColor(cc.c3b(0, 0, 0))
                    inputBox:setAnchorPoint(0, 0.5)
                    inputBox:setPosition(24, 28)
                    -- inputBoxBg:addChild(inputBox)

                    inputCur = ccui.Layout:create()
                    inputCur:setBackGroundColorOpacity(255)
                    inputCur:setBackGroundColorType(1)
                    inputCur:setBackGroundColor(cc.c3b(0,104,183))
                    inputCur:setContentSize(4, 27)
                    inputCur:setPosition(15 + inputBox:getContentSize().width + 10, 16)
                    inputCur:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.8), cc.FadeIn:create(0.8))))
                    inputBoxBg:addChild(inputCur)

                    local mask = cc.Scale9Sprite:createWithSpriteFrameName("globalImage_input.png")
                    mask:setContentSize(inputBoxBg:getContentSize().width - 38, 59)
                    mask:setPosition(inputBoxBg:getContentSize().width/2, inputBoxBg:getContentSize().height/2)
                    mask:setAnchorPoint(0.5, 0.5)

                    local clipNode = cc.ClippingNode:create()
                    clipNode:setInverted(false)
                    clipNode:setStencil(mask)
                    clipNode:setAlphaThreshold(0.05)
                    clipNode:addChild(inputBox)
                    clipNode:setPosition(cc.p(0, 0))
                    inputBoxBg:addChild(clipNode)
                end
                root:__addEventListener(function (sender, event)
                    if event == 0 then
                        createInputBox(sender:getString())
                    elseif event == 1 then
                        closeGlobalInputBox()
                    else
                        if inputBoxBg == nil then
                            createInputBox(sender:getString())
                        end
                        local tempData = sender:getString()
                        sender:checkString(tempData)

                        inputBox:setString(sender:getString())
                   
                        if inputBox:getContentSize().width > (inputBoxBg:getContentSize().width - 48) then 
                            inputBox:setPosition((inputBoxBg:getContentSize().width - 24) - inputBox:getContentSize().width, inputBox:getPositionY())
                        else
                            inputBox:setPosition(24, inputBox:getPositionY())
                        end
                        inputCur:setPositionX(inputBox:getPositionX() + inputBox:getContentSize().width)
                    end
                    if root.__callback then root.__callback(root, event) end
                end)
            end
        end
    end
    local children = root:getChildren()
    local count = #children
    for i = 1, count do
        BaseEvent_L10N_Text(self, children[i])
    end
end
BaseEvent_L10N_Text = BaseEvent.L10N_Text
-- 用于解决退出界面截屏时候的各种问题
function BaseEvent:beforePop(root, k)
    do return end
    if root == nil then
        root = self._widget
        if root == nil then return end
    end
    local _k = k
    if _k == nil then
        _k = 1
    end
    -- if _k > 5 then
    --     return
    -- end
    -- local desc = root:getDescription()
    -- if desc == "PageView" or desc == "ScrollView" then
    --     -- 截屏时候的BUG
    --     root:setClippingType(0)
    -- end
    if root.eventDownCallback then
        root.eventDownCallback = nil
        root.eventMoveCallback = nil
        root.eventUpCallback = nil
        root.eventOutCallback = nil
    end
    local count = #root:getChildren()
    for i = 1, count do
        self:beforePop(root:getChildren()[i], _k + 1)
    end
end

function BaseEvent.dtor()
    EventUp_Delay = nil
    BaseEvent = nil 
    curView = nil
    __guideLock = nil
    ButtonBeginAnim = nil
    ButtonEndAnim = nil
    inputBox = nil
    inputBoxBg = nil 
    inputCur = nil 
    isMultipleTouchEnabled = nil 
    len = nil 
    luabridge = nil
    platform = nil 
    sub = nil 
    ttf = nil 
    ttf_title = nil
    buttonColorMap = nil
    TextField = nil 
    color1 = nil
    color2 = nil
    color3 = nil
    color4 = nil
    cc = nil
    last_click_ui_name_index = nil
    BaseEvent_L10N_Text = nil
end

return BaseEvent