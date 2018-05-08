--[[
    ===================================
    =    <<  英雄无敌 战争纪元  >>    =
    =    2014年12月20日               =
    ===================================
--]]
-- 该文件禁止热更新
-- 该文件禁止热更新
-- 该文件禁止热更新
-- 该文件禁止热更新
local startGame = 1
local function main()
    cc.FileUtils:getInstance():addSearchPath("config")
    if startGame ~= 1 then
        require "main_profiler"
        return
    end
    require "socket"
    -- 64位
    OS_IS_64 = true
    local reqFunction = require
    require = function (name)
        return reqFunction(name .. "64")
    end
    pcall(loadstring("require \"main_patch1\""))

    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    -- openglInfo
    print(pc.PCTools:getOpenGLInfo())
    --log写入地址
    print(cc.FileUtils:getInstance():getWritablePath())

    Gprint = print

    require "cocos.init"
    
    local platform = cc.Application:getInstance():getTargetPlatform()
    OS_IS_WINDOWS = (platform == cc.PLATFORM_OS_WINDOWS)
    OS_IS_IOS = (platform == cc.PLATFORM_OS_IPHONE
        or platform == cc.PLATFORM_OS_IPAD)
    OS_IS_IPHONE = (platform == cc.PLATFORM_OS_IPHONE)
    OS_IS_IPAD = (platform == cc.PLATFORM_OS_IPAD)
    OS_IS_ANDROID = (platform == cc.PLATFORM_OS_ANDROID)
    OS_IS_MAC = (platform == cc.PLATFORM_OS_MAC)
    if OS_IS_IOS then
        OS_IS_IPHONE_SIMULATOR = pc.PCTools:isIphoneSimulator()
    else
        OS_IS_IPHONE_SIMULATOR = false
    end
    
    if OS_IS_WINDOWS then
        WINDOWS_DEVICEID = os.time()
        -- 查内存泄漏用
        require "base.boot.MemLeakCheck"
    end

    -- 防止每次getInstance的时候判断文件是否可写造成冲突
    UserDefault = cc.UserDefault:getInstance()
    while UserDefault == nil do
        UserDefault = cc.UserDefault:getInstance()
        socket.sleep(1)
    end

    pcall(loadstring("require \"main_patch2\""))

    require "utils.init"
    HttpManager = require "base.network.HttpManager"
    ApiUtils.playcrab_device_monitor_action("qidong")

    pcall(loadstring("require \"main_patch3\""))

    RestartMgr = require("base.boot.RestartManager").new()
    RestartMgr:start()

    pcall(loadstring("require \"main_patch4\""))
end

function trycall(name, func, ...)
    local args = { ... }
    local a, b, c, d
    local ret = xpcall(function() a, b, c, d = func(unpack(args)) end, __G__TRACKBACK__)
    return ret, a, b, c, d
end

function applicationWillResignActive() if ApplicationUtils then ApplicationUtils.applicationWillResignActive() end end
function applicationDidBecomeActive() if ApplicationUtils then ApplicationUtils.applicationDidBecomeActive() end end
function applicationDidEnterBackground() if ApplicationUtils then ApplicationUtils.applicationDidEnterBackground() end end
function applicationWillEnterForeground() if ApplicationUtils then ApplicationUtils.applicationWillEnterForeground() end end

-- 全局错误处理, 游戏启动后会覆盖此方法
function playcrab_lua_error(msg)
    pc.PCTools:showError(msg)
end

local function reset_walle_version()
    local gameData = cc.FileUtils:getInstance():getStringFromFile("game.conf")
    if gameData == "" then return end
    local jsonData = cjson.decode(gameData)
    local baseVersion = jsonData["APP_BUILD_NUM"]
    if baseVersion ~= nil and type(baseVersion) == "number" then 
        local configMgr = kakura.Config:getInstance()
        configMgr:setValue("APP_BUILD_NUM", tonumber(baseVersion))
        configMgr:save()
        if not OS_IS_WINDOWS then 
            kakura.PCDBManager:getInstance():setCurrentVersion(tonumber(baseVersion))       
        end
    end
end
-- 文件找不到，要么是文件有语法错误导致编译失败，要么是文件找不到（热更新文件被清除）
function playcrab_lua_error_not_found(msg)
    pc.PCTools:showError("游戏文件不完整，请清除缓存后重启游戏")
    reset_walle_version()
end

function SdkCallback(code, data)
    if tonumber(code) == 1001 then
        local info = cjson.decode(data)
        if info.flag == "0" or info.flag == "3004" or info.flag == "3002" then
            return
        end
        _G.sdkAutoLoginPlatform = info.platform
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end

pcall(loadstring("require \"main_patch5\""))
