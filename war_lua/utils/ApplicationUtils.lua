--[[
    Filename:    ApplicationUtils.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-05-31 12:02:47
    Description: File description
--]]

local ApplicationUtils = {}

function ApplicationUtils.applicationWillResignActive()
	print("applicationWillResignActive")
    ApplicationUtils.applicationWillResignActiveTime = os.time()
    if AudioManager then AudioManager:getInstance():pauseAll(true) end
    if ScheduleMgr then ScheduleMgr:pause() end
end

function ApplicationUtils.checkAllSignatureTabs()
    print("检查静态表")
    local tick = socket.gettime()
    local res
    pcall(function () tab:checkAllSignatureTabs() end)
    print("查表耗时: ", socket.gettime() - tick)
    if res ~= nil then
        if OS_IS_WINDOWS then
            if ViewManager then ViewManager:getInstance():onLuaError("配置表被更改: "..res) end
            -- dump(tab[filename], filename, 5)
        else
            if ViewManager then ViewManager:getInstance():showTip("数据异常.01") end
            ApiUtils.playcrab_lua_error("tab_xiugai_app", res)
            if GameStatic.kickTable then
                do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
            end
        end
    end
end

function ApplicationUtils.applicationDidBecomeActive()
	print("applicationDidBecomeActive")
    ApplicationUtils.applicationDidBecomeActiveTime = os.time()
    if ScheduleMgr then ScheduleMgr:resume() end
    if AudioManager then
        -- 切回前台的时候 判断是否需要播放背景音乐
        if AudioManager:getInstance():isOtherAudioPlaying() then
            AudioManager:getInstance():disable()
        else
            AudioManager:getInstance():enable()
        end
    end
    -- 检查表
    if tab and GameStatic.checkTable then
        ApplicationUtils.checkAllSignatureTabs()
    end
    if ModelManager and ModelManager:getInstance():hasModel("UserModel") and GameStatic.checkZuoBi_3 then
        print("检查Model数据")
        local checkModelTab = {"TeamModel", "HeroModel", "PokedexModel", "TreasureModel"}
        for i = 1, #checkModelTab do
            local modelName = checkModelTab[i]
            local res = ModelManager:getInstance():getModel(modelName):checkData()
            if res ~= nil then
                if OS_IS_WINDOWS then
                    if ViewManager then ViewManager:getInstance():onLuaError(modelName .. "被修改: "..serialize(res)) end
                else
                    if ViewManager then ViewManager:getInstance():showTip("数据异常.02") end
                    ApiUtils.playcrab_lua_error(modelName .. "_xiugai", serialize(res))
                    if GameStatic.kickZuoBi_3 then
                        do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
                    end
                end   
            end
        end
    end
    if ViewManager then ViewManager:getInstance():applicationDidBecomeActive() end
end

-- 切入后台 回调
local isBackGournd = false
local enterBackGround = 0
local serverLock = false

function ApplicationUtils.applicationDidEnterBackground()
    if isBackGournd then return end
    ApplicationUtils.applicationDidEnterBackgroundTime = os.time()
    print("applicationDidEnterBackground")
    isBackGournd = true
    if not OS_IS_IOS then
        applicationWillResignActive()
    end
    if ModelManager and not ModelManager:getInstance():hasModel("UserModel") then return end
    enterBackGround = os.time()
    if ModelManager then
        enterBackGround = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    end
    if not serverLock then
        if ViewManager then ViewManager:getInstance():applicationDidEnterBackground() end
        if ServerManager then ServerManager:getInstance():applicationDidEnterBackground() end
    end
    if PushUtils then PushUtils:cancelLocalPush() end
    if PushUtils then PushUtils:setLocalPhysicalPush() end
end

function ApplicationUtils.applicationWillEnterForeground()
    if not isBackGournd then return end
    ApplicationUtils.applicationWillEnterForegroundTime = os.time()
    print("applicationWillEnterForeground")
    isBackGournd = false
    if not OS_IS_IOS then
        applicationDidBecomeActive()
    end
    if ModelManager and not ModelManager:getInstance():hasModel("UserModel") then return end
    local time = os.time()
    if ModelManager then
        time = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    end
    local second = time - enterBackGround

    if ServerManager then 
        print("serverLock", serverLock)
        if not serverLock then
            serverLock = true
            ServerManager:getInstance():applicationWillEnterForeground(second, function ()
                serverLock = false
                if ViewManager then ViewManager:getInstance():applicationWillEnterForeground(second) end 
            end)
        end
    end
    if PushUtils then PushUtils:cancelLocalPush() end
end

return ApplicationUtils