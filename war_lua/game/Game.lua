--[[
    Filename:    Game.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-27 17:40:42
    Description: File description
--]]
local Game = class("Game")

function Game:ctor()
    ApiUtils.playcrab_device_monitor_action("updateover")
    
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))

    RGBA8888 = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888
    RGBA4444 = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444
    RGB888 = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888
    RGB565 = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565
    RGBAUTO = cc.TEXTURE2_D_PIXEL_FORMAT_AUTO
    if OS_IS_IOS then
        RGBART = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444
    elseif OS_IS_ANDROID then
        RGBART = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444
    else
        RGBART = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444
    end
    if OS_IS_IOS or OS_IS_ANDROID then
        RGBA8888 = RGBAUTO
        RGBA4444 = RGBAUTO
        RGB888 = RGBAUTO
        RGB565 = RGBAUTO
    end

    -- c++版本号
    CPP_VERSION = pc.PCTools.getCppVersion and pc.PCTools:getCppVersion() or 212

    -- 屏幕分辨率
    MAX_SCREEN_WIDTH = cc.Director:getInstance():getWinSizeInPixels().width
    MAX_SCREEN_HEIGHT = cc.Director:getInstance():getWinSizeInPixels().height
    MAX_SCREEN_REAL_WIDTH, MAX_SCREEN_REAL_HEIGHT = MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT
    if MAX_SCREEN_WIDTH > 1600 then
        MAX_SCREEN_WIDTH = 1600
    end
    -- iphoneX适配1.0
    SCREEN_X_OFFSET = (MAX_SCREEN_REAL_WIDTH - MAX_SCREEN_WIDTH) * 0.5
    -- UI设计分辨率
    MAX_DESIGN_WIDTH = 960
    MAX_DESIGN_HEIGHT = 640

    -- iphoneX2.0
    --[[
        BaseView的self._widget的宽度会缩小120，两边各60
        self.dontAdoptIphoneX可以无视这个设定
        调用self._viewMgr:enableScreenWidthBar和self._viewMgr:disableScreenWidthBar可以采用iphoneX适配1.0
        个别界面如果有适配问题，可以判断ADOPT_IPHONEX是否为true去单独处理
    ]]
    ADOPT_IPHONEX = MAX_SCREEN_WIDTH > 1300
    --适配小米MAX2
    ADOPT_XIAOMIM2 = false
    if MAX_SCREEN_WIDTH >= 1280 and MAX_SCREEN_WIDTH <= 1300 then
        ADOPT_XIAOMIM2 = true
    end

    -- 背景全局缩放比例
    BG_SCALE_WIDTH = MAX_SCREEN_WIDTH / MAX_DESIGN_WIDTH
    BG_SCALE_HEIGHT = MAX_SCREEN_HEIGHT / MAX_DESIGN_HEIGHT
    -- 背景等比缩放比例
    if BG_SCALE_WIDTH > BG_SCALE_HEIGHT then
        BG_SCALE = BG_SCALE_WIDTH
    else
        BG_SCALE = BG_SCALE_HEIGHT
    end

    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)

    -- 海外版容错
    if GLOBAL_VALUES.LANGUAGE == nil or GLOBAL_VALUES.NEED_INIT_LANGUAGE then 
        GLOBAL_VALUES.LANGUAGE = "cn"
        UI_EX = {}
        UI_EX_PATH = ""
        SIM_EX = {}
        SIM_EX_PATH =  ""
        I18N = {}
        UI_FONT_EX = {}
        GLOBAL_VALUES.NEED_INIT_LANGUAGE = true
    end

    -- edit by vv 移动到updateview中进行require 
    -- require "game.GameStatic"
    
    tab = require("game.config.DataTableManager").new()
    tab:initLoading()
    -- 全局类名
    BaseMvcs = require("base.mvcs.BaseMvcs")
    BaseModel = require("base.mvcs.BaseModel")
    BaseServer = require("base.mvcs.BaseServer")
    BaseEvent = require("base.cocostudio.BaseEvent")
    BaseView = require("base.mvcs.BaseView")
    BasePopView = require("base.ui.BasePopView")
    BaseLayer = require("base.ui.BaseLayer")

    SpriteFrameResManager = require("base.anim.SpriteFrameResManager")
    MovieClipManager = require("base.anim.MovieClipManager")
    SpineManager = require("base.anim.SpineManager")
    ViewManager = require("game.controller.ViewManager")
    -- DEBUG快捷键
    require "game.controller.HotKeyProc"
    ServerManager = require("game.controller.ServerManager")
    ModelManager = require("game.controller.ModelManager")
    AudioManager = require("base.audio.AudioManager")
    

    SpriteFrameAnim = require("base.anim.SpriteFrameAnim")
    MovieClipAnim = require("base.anim.MovieClipAnim")
    HeroAnim = require("base.anim.HeroAnim")
    NullAnim = require("base.anim.NullAnim")

    HeroSoloPlayer = require("game.common.HeroSoloPlayer")
    NewHeroSoloPlayer = require "game.common.NewHeroSoloPlayer"


    SdkManager = require("game.controller.SdkManager")
    sdkMgr = SdkManager:getInstance()
    
    -- 从SDK取变量
    local superDebug = sdkMgr:getPokeballValue("superDebug")
    if superDebug and superDebug == "true" then
        GameStatic.superDebug = "playcrab19870515"
    end
    local falseGuide = sdkMgr:getPokeballValue("falseGuide")
    if falseGuide and not GLOBAL_VALUES.falseGuideFlag then
        if falseGuide == "true" then
            G_falseGuide = 1
        elseif falseGuide == "false" then
            G_falseGuide = 0
        end
    end
    require "game.utils.init"

    -- 上传纹理小于4096的设备信息
    if (OS_IS_ANDROID or OS_IS_IOS) and GameStatic.upload_max_texture_size_4096 then
        pcall(loadstring("require \"device\""))
    end

    -- 全局
    sfResMgr = SpriteFrameResManager:getInstance()
    mcMgr = MovieClipManager:getInstance()
    spineMgr = SpineManager:getInstance()
    audioMgr = AudioManager:getInstance()
    
    if GameStatic.superDebug == "playcrab19870515" then 
        GameStatic.showGuideDebug = true
        GameStatic.showLuaError = true
        GameStatic.showDEBUGInfo = true
        GameStatic.showLockDebug = true
        GameStatic.showServerTime = true
        GameStatic.deviceGuideOpen = false
    end

    setMultipleTouchDisabled()
    setEventUpDelayEnabled()
    cc.Director:getInstance():setDisplayStats(GameStatic.showDEBUGInfo)
    if GameStatic.dumpFPS_ios then
        cc.Director:getInstance():setDisplayStats(true)
    end

    sfResMgr:retain("commondie")
    sfResMgr:cache("commondie")
    mcMgr:retain("click-HD")
    mcMgr:retain("shalou")
    mcMgr:retain("itemeffectcollection")

    self:initGlobalSetting()
end

-- 全局开关
function Game:initGlobalSetting()
    audioMgr:setMusicEnable(true)
    audioMgr:setSoundEnable(true)
    local musicVolume = SystemUtils.loadGlobalLocalData("musicVolume")
    if musicVolume == nil then
        musicVolume = 5
        SystemUtils.saveGlobalLocalData("musicVolume", musicVolume)
    end
    local soundVolume = SystemUtils.loadGlobalLocalData("soundVolume")
    if soundVolume == nil then
        soundVolume = 5
        SystemUtils.saveGlobalLocalData("soundVolume", soundVolume)
    end
    audioMgr:adjustMusicVolume(musicVolume)
    audioMgr:adjustSoundVolume(soundVolume)

    local value = SystemUtils.loadGlobalLocalData("setting_PowerSaving")
    if value ~= nil then GameStatic.setting_PowerSaving = value end
    value = SystemUtils.loadGlobalLocalData("setting_ClickEff")
    if value ~= nil then GameStatic.setting_ClickEff = value end
    value = SystemUtils.loadGlobalLocalData("setting_PushPhysic")
    if value ~= nil then GameStatic.setting_PushPhysic = value end

    if GameStatic.setting_PowerSaving then
        GameStatic.normalAnimInterval  = 1 / 30   
    else
        GameStatic.normalAnimInterval  = 1 / 60
    end
    cc.Director:getInstance():setAnimationInterval(GameStatic.normalAnimInterval)

    pcall(function ()
        local imageCacheTime = SystemUtils.loadGlobalLocalData("imageCacheTime")
        local delete = false
        if imageCacheTime == nil then
            delete = true
            imageCacheTime = os.time()
            SystemUtils.saveGlobalLocalData("imageCacheTime", imageCacheTime)
        else
            if os.time() > imageCacheTime + 86400 then
                delete = true
                SystemUtils.saveGlobalLocalData("imageCacheTime", os.time() + 86400)
            end
        end
        if delete then
            local fileUtils = cc.FileUtils:getInstance()
            local writablePath = fileUtils:getWritablePath()
            local downloadLocalPath = writablePath .. "imageCache/"
            if OS_IS_ANDROID then
                local appInformation = AppInformation:getInstance()
                if appInformation:getValue("external_asset_path") ~= nil and appInformation:getValue("external_asset_path") ~= "" then
                    -- 如果 sd 卡可用 , 存储到sd下
                    downloadLocalPath = appInformation:getValue("external_asset_path") .. "imageCache/"
                end
            end
            fileUtils:removeDirectory(downloadLocalPath)
            print("remove imageCache")
        end
    end)

    -- anim文件夹下动画外挂包
    -- 先载入翻译包，再载入原始动画
    -- 翻译包在语言相对的路径下 ex:  asset/anim_cn/  asset/anim_zh/
    MOVIECLIP_EX = {}
    if GLOBAL_VALUES.LANGUAGE then
        if cc.FileUtils:getInstance():isFileExist("asset/anim_" .. GLOBAL_VALUES.LANGUAGE .."/anim_ex.lua") then
            MOVIECLIP_EX = require ("asset/anim_" .. GLOBAL_VALUES.LANGUAGE .."/anim_ex")
        end
        print("动画语言包==="..GLOBAL_VALUES.LANGUAGE)
        dump(MOVIECLIP_EX)
        mcMgr.animPathEx = "asset/anim_".. GLOBAL_VALUES.LANGUAGE .."/"
        UIUtils.animPathEx = "asset/anim_".. GLOBAL_VALUES.LANGUAGE .."/"
        if string.len(UI_EX_PATH) > 0 then
            UIUtils.uiPathEx = UI_EX_PATH
        end
    end
end

-- 启动游戏
local _fpsUpdateId
local _file
function Game:startup()
    local viewMgr = ViewManager:getInstance()
    viewMgr:startup()

    -- 服务器时间
    if GameStatic.showServerTime then
        self:destroyTimeLabel() 
        self:createTimeLabel(viewMgr:getRootLayer())
    end
    -- 控制台
    if GameStatic.superDebug == "playcrab19870515" then 
        self:destroyConsole() 
        self:createConsole(viewMgr:getRootLayer())
    end

    if GameStatic.dumpFPS_ios then
        if _fpsUpdateId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_fpsUpdateId) 
            _file:close()
        end
        if OS_IS_IOS then
            _file = io.open(cc.FileUtils:getInstance():getWritablePath() .."/fps.txt", "a")
            _fpsUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
                _file:write(ViewManager:getInstance():getCurViewName().." "..os.date("%Y-%m-%d %H:%M:%S", os.time()).." "..cc.Director:getInstance():getFrameRate().. "\n")
            end, 0.5, false)
        end
    end
end

local _labelUpdateId
function Game:createTimeLabel(root)
    self._serverTime = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
    self._serverTime:setAnchorPoint(0, 0)
    self._serverTime:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._serverTime:setPosition(MAX_SCREEN_WIDTH - 236, 3)
    root:addChild(self._serverTime, 99999997)

    self._localTime = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
    self._localTime:setAnchorPoint(0, 0)
    self._localTime:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._localTime:setPosition(MAX_SCREEN_WIDTH - 236, 23)
    root:addChild(self._localTime, 99999997)

    self._serverStartTime = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
    self._serverStartTime:setAnchorPoint(0, 0)
    self._serverStartTime:setColor(cc.c3b(0, 255, 255))
    self._serverStartTime:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._serverStartTime:setPosition(MAX_SCREEN_WIDTH - 236, 43)
    root:addChild(self._serverStartTime, 99999997)

    _labelUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
        if ModelManager == nil then return end
        if not TimeUtils.serverTimezone then return end
        if not ModelManager:getInstance():hasModel("UserModel") then return end
        local time = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
        local _time = os.time()
        self._serverTime:setString("服 ".. TimeUtils.serverUTC .. " " .. TimeUtils.date("%Y-%m-%d %H:%M:%S", time))
        self._localTime:setString("本 ".. TimeUtils.localUTC .. " " .. os.date("%Y-%m-%d %H:%M:%S", _time))
        self._serverStartTime:setString("开 ".. TimeUtils.serverUTC .. " " .. GameStatic.server_start_date)

        local time1 = _time
        local time2 = time
        if TimeUtils.serverTimezone then
            time2 = time - (TimeUtils.localTimezone - TimeUtils.serverTimezone)
        end
        if time1 > time2 then
            self._localTime:setColor(cc.c3b(0, 255, 0))
        elseif time1 < time2 then
            self._localTime:setColor(cc.c3b(255, 80, 80))
        else
            self._localTime:setColor(cc.c3b(255, 255, 255))
        end
        self._serverTime:setVisible(GameStatic.showServerTime)
        self._localTime:setVisible(GameStatic.showServerTime)
        self._serverStartTime:setVisible(GameStatic.showServerTime)
    end, 0.2, false)
end

function Game:destroyTimeLabel()
    if not _labelUpdateId then return end
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_labelUpdateId) 
end

-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台
-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台
-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台
-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台-- 控制台
local _consoleUpdateId
local _consolePause = false
function Game:createConsole(root)
    self._console = MAX_SCREEN_WIDTH * 0.5 + GameStatic.consoleWidth
    local ybegin = 190
    local mask = ccui.Layout:create()
    mask:setBackGroundColorOpacity(255)
    mask:setBackGroundColorType(1)
    mask:setBackGroundColor(cc.c3b(0,0,0))
    mask:setContentSize(self._console, MAX_SCREEN_HEIGHT - ybegin)
    mask:setLocalZOrder(99999998)
    mask:setOpacity(GameStatic.consoleBgAlpha)
    mask:setPositionY(ybegin)
    root:addChild(mask)   
    self._consoleMask = mask

    local turnBtn = ccui.Layout:create()
    turnBtn:setBackGroundColorOpacity(255)
    turnBtn:setBackGroundColorType(1)
    turnBtn:setBackGroundColor(cc.c3b(255,0,0))
    turnBtn:setContentSize(60, 60)
    turnBtn:setLocalZOrder(99999998)
    turnBtn:setOpacity(0)
    turnBtn:setTouchEnabled(true)
    root:addChild(turnBtn)  
    turnBtn:addTouchEventListener(function (sender, eventType)
        if eventType == 2 then
            GameStatic.showDEBUGInfo = not GameStatic.showDEBUGInfo
            cc.Director:getInstance():setDisplayStats(GameStatic.showDEBUGInfo)
            ViewManager:getInstance():showDebugInfo(GameStatic.showDEBUGInfo)
            self._tableView:setVisible(not self._tableView:isVisible())
            mask:setVisible(not mask:isVisible())
        end
    end)
    
    local turnBtn = ccui.Layout:create()
    turnBtn:setBackGroundColorOpacity(255)
    turnBtn:setBackGroundColorType(1)
    turnBtn:setBackGroundColor(cc.c3b(255,0,0))
    turnBtn:setContentSize(60, 60)
    turnBtn:setPosition(0, MAX_SCREEN_HEIGHT - 60)
    turnBtn:setLocalZOrder(99999998)
    turnBtn:setOpacity(0)
    turnBtn:setTouchEnabled(true)
    root:addChild(turnBtn)  
    turnBtn:addTouchEventListener(function (sender, eventType)
        if eventType == 2 then
            _consolePause = not _consolePause
            if _consolePause then
                for i = #self._consoleData, 1, -1 do
                    if self._labels[i] then
                        self._labels[i]:setColor(cc.c3b(0, 255, 128))
                    end
                end
                self._consoleMask:setOpacity(180)
            else
                for i = #self._consoleData, 1, -1 do
                    if self._labels[i] then
                        self._labels[i]:setColor(cc.c3b(0, 255, 0))
                    end
                end
                self._consoleMask:setOpacity(GameStatic.consoleBgAlpha)
            end
        end
    end)

    local tableView = cc.TableView:create(cc.size(self._console, MAX_SCREEN_HEIGHT - ybegin))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(0, ybegin)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(false)
    -- tableView:setTouchEnabled(false)
    root:addChild(tableView, 99999999)

    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(function(table, cell ) return self:tableCellWillRecycle(table,cell) end ,cc.TABLECELL_WILL_RECYCLE)

    self._tableView = tableView
    root.consoleView = tableView
    _consoleUpdateId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
        if self._tableView:isDragging() or _consolePause then return end
        if CONSOLE_HASNEW and CONSOLE_HASNEW() then
            self._consoleData = CONSOLE_GETLOG()
            if self._labels then
                if CONSOLE_NEEDRELOAD() then
                    for i = 1, #self._labels do
                        self._labels[i]:release()
                    end
                    self._labels = {}
                end
            else
                self._labels = {}
            end
            
            local size = GameStatic.consoleFontSize
            for i = #self._consoleData, 1, -1 do
                if self._labels[i] == nil then
                    local label = cc.Label:createWithSystemFont(self._consoleData[i], "Arial", size)
                    label:setAnchorPoint(0, 0)
                    label:setColor(cc.c3b(0,255,0))
                    label:setDimensions(self._console - 20, 0)
                    label:setVerticalAlignment(0)
                    label:retain()
                    label:setPositionX(10)
                    self._labels[i] = label
                end
            end  
            self._tableView:stopScroll()
            self._count = #self._consoleData
            self._tableView:reloadData()
            self._tableView:setContentOffset(self._tableView:maxContainerOffset())    
            self._tableView:setTouchEnabled(false)
            self._tableView:setTouchEnabled(true)
        end
    end, 0.1, false)
end

function Game:cellSizeForTable(table,index)
    return self._labels[index + 1]:getContentSize().height, self._console - 20
end

function Game:tableCellAtIndex(table,index)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    self._labels[index + 1]:removeFromParent()
    cell:addChild(self._labels[index + 1])
    return cell
end

function Game:tableCellWillRecycle(table,cell)
    cell:removeAllChildren()
end

function Game:numberOfCellsInTableView(table)
    return self._count
end

function Game:destroyConsole()
    if not _consoleUpdateId then return end
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_consoleUpdateId) 
end


function Game.dtor()
    if _consoleUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_consoleUpdateId) 
    end
    if _labelUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_labelUpdateId) 
    end
    if _fpsUpdateId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_fpsUpdateId) 
        _file:close()
    end
    Game = nil
    _consolePause = nil
end

return Game