--[[
    Filename:    HotKeyProc.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-01-07 19:46:48
    Description: File description
--]]

local hue = 0
local saturation = 0
local brightness = 0
local contrast = 0

local DelayCallForWindows
if OS_IS_WINDOWS then
DelayCallForWindows = function (callback)
    local eventId
    eventId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        function ()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(eventId)
            callback()
        end, 0, false)
end
end

function ViewManager:printKeyid(keyid)
    -- print(keyid)
end

-- 泄漏排查
-- function ViewManager:hotKey_72()--<
--     G_weak = {}
-- end

-- function ViewManager:hotKey_74()-->
--     collectgarbage("collect")
--     collectgarbage("collect")
--     collectgarbage("collect")
--     print("---------------------")
--     for k, v in pairs(G_weak) do
--         if type(v) ~= "string" and type(v) ~= "number" and type(v) ~= "boolean" then
--             print(v)
--             -- dump(v)
--             -- G_weak[k] = nil
--             -- findObjectInGlobal(k)
--         end
--     end
-- end

function ViewManager:hotKey_6()--esc
    for k, v in pairs(package.loaded) do
        if string.find(k, "game.view") or string.find(k, "game.model") or string.find(k, "game.server") or string.find(k, "game.utils") then
            package.loaded[k] = nil
            print("unload", k)
        end
    end
end

-- 效率分析
function ViewManager:hotKey_72()--<
    -- MemLC_Traversal()
    
    profiler:start()
    -- cc.Director:getInstance():getTextureCache():reloadAllTextures()
end
function ViewManager:hotKey_74()-->
    -- MemLC_Dump()

    profiler:stop()
    local outfile = io.open(cc.FileUtils:getInstance():getWritablePath().."/profile.txt", "w+") 
    profiler:report(outfile)
    outfile:close()
end
function ViewManager:hotKey_75()--/
    dump(cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo())
    -- dump(self._plistList)
    -- cc.Ref:printLeaksCount()
    -- dump(debug.getregistry(), "z", 1)
end

-- [e]组合快捷键
function ViewManager:combinationHotKey_128_77()
    hue = hue - 5
    if hue < -180 then
        hue = hue + 360
    end
    self._rootLayer:setHue(hue)
    self:showTip("色相 Hue: "..hue)
end
function ViewManager:combinationHotKey_128_78()
    hue = hue + 5
    if hue > 180 then
        hue = hue - 360
    end
    self._rootLayer:setHue(hue)
    self:showTip("色相 Hue: "..hue)	
end
function ViewManager:combinationHotKey_128_79()
    saturation = saturation - 5
    if saturation < -100 then
        saturation = -100
    end
    self._rootLayer:setSaturation(saturation)
    self:showTip("饱和度 saturation: "..saturation)
end
function ViewManager:combinationHotKey_128_80()
    saturation = saturation + 5
    if saturation > 100 then
        saturation = 100
    end
    self._rootLayer:setSaturation(saturation)
    self:showTip("饱和度 saturation: "..saturation)
end
function ViewManager:combinationHotKey_128_81()
    brightness = brightness - 5
    if brightness < -100 then
        brightness = -100
    end
    self._rootLayer:setBrightness(brightness)
    self:showTip("亮度 brightness: "..brightness)
end
function ViewManager:combinationHotKey_128_82()
    brightness = brightness + 5
    if brightness > 100 then
        brightness = 100
    end
    self._rootLayer:setBrightness(brightness)
    self:showTip("亮度 brightness: "..brightness)
end
function ViewManager:combinationHotKey_128_83()
    contrast = contrast - 5
    if contrast < -100 then
        contrast = -100
    end
    self._rootLayer:setContrast(contrast)
    self:showTip("对比度 contrast: "..contrast)
end
function ViewManager:combinationHotKey_128_84()
    contrast = contrast + 5
    if contrast > 100 then
        contrast = 100
    end
    self._rootLayer:setContrast(contrast)
    self:showTip("对比度 contrast: "..contrast)
end
-- [r]组合快捷键
local fps = 60
function ViewManager:combinationHotKey_141_77()
    fps = fps - 5
    if fps < 1 then
        fps = 1
    end
    self:showTip("fps: "..fps)
    cc.Director:getInstance():setAnimationInterval(1 / fps)
end
function ViewManager:combinationHotKey_141_78()
    fps = fps + 5
    if fps > 60 then
        fps = 60
    end
    self:showTip("fps: "..fps)
    cc.Director:getInstance():setAnimationInterval(1 / fps)
end
function ViewManager:combinationHotKey_141_79()
    for i = 1, 50 do
        print( )
    end
end

-- function ViewManager:viewHotKey_20()  end --insert 
-- function ViewManager:viewHotKey_36()  end --home 
-- function ViewManager:viewHotKey_38()  end --pageup 
-- function ViewManager:viewHotKey_23()  end --delete 
-- function ViewManager:viewHotKey_24()  end --end 
function ViewManager:viewHotKey_44() self:popView() end --pagedown 

-- [q]组合快捷键
function ViewManager:combinationHotKey_140_77() BattleUtils.battleDemo_Fuben() end
function ViewManager:combinationHotKey_140_78() BattleUtils.battleDemo_Arena() end
function ViewManager:combinationHotKey_140_79() BattleUtils.battleDemo_AiRenMuWu() end
function ViewManager:combinationHotKey_140_80() BattleUtils.battleDemo_Zombie() end
function ViewManager:combinationHotKey_140_81() BattleUtils.battleDemo_Siege() end
function ViewManager:combinationHotKey_140_82() BattleUtils.battleDemo_BOSS_DuLong() end
function ViewManager:combinationHotKey_140_83() BattleUtils.battleDemo_BOSS_XnLong() end
function ViewManager:combinationHotKey_140_84() BattleUtils.battleDemo_BOSS_SjLong() end
function ViewManager:combinationHotKey_140_85() BattleUtils.battleDemo_Elemental() end
function ViewManager:combinationHotKey_140_76() BattleUtils.battleDemo_Crusade() end

-- [t]组合快捷键
function ViewManager:combinationHotKey_143_77(dontRestart) 
    if OS_IS_ANDROID or OS_IS_IOS then
        sdkMgr:saveDataInDevice(GameStatic.deviceGuideKey_Video, "0")
        SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Video, 0)
    else
        SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Video, 0)
    end
    SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Enable, 0)
    SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Index, 0)
    if not dontRestart then
        self:restart()
    end
end
function ViewManager:combinationHotKey_143_78(dontRestart) 
    if OS_IS_ANDROID or OS_IS_IOS then
        sdkMgr:saveDataInDevice(GameStatic.deviceGuideKey_Video, "1")
        SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Video, 1)
    else
        SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Video, 1)
    end
    SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Enable, 0)
    SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Index, 0)
    if not dontRestart then
        self:restart()
    end
end
function ViewManager:combinationHotKey_143_79() 
    if OS_IS_ANDROID or OS_IS_IOS then
        sdkMgr:saveDataInDevice(GameStatic.deviceGuideKey_Video, "1")
        SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Video, 1)
    else
        SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Video, 1)
    end
    SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Enable, 1)
    SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Index, 4)
    self:restart()
end

-- [y]组合快捷键
function ViewManager:combinationHotKey_148_77() 
    GameStatic.showDEBUGInfo = not GameStatic.showDEBUGInfo
    cc.Director:getInstance():setDisplayStats(GameStatic.showDEBUGInfo)
    self:showDebugInfo(GameStatic.showDEBUGInfo)
end
function ViewManager:combinationHotKey_148_78() 
    BattleUtils.XBW_SKILL_DEBUG = not BattleUtils.XBW_SKILL_DEBUG
    if BattleUtils.XBW_SKILL_DEBUG then self:showTip("战斗DEBUG模式开启") else self:showTip("战斗DEBUG模式关闭") end
end
function ViewManager:combinationHotKey_148_79() 
    SystemUtils.saveGlobalLocalData("L_platformLoginInv", 0)
    SystemUtils.saveGlobalLocalData("L_canPlatformLoginTime", 0)
    SystemUtils.saveGlobalLocalData("L_loginInv", 0)
    SystemUtils.saveGlobalLocalData("L_canLoginTime", 0)
    self:restart()
end
function ViewManager:combinationHotKey_148_80() 
    GameStatic.showServerTime = not GameStatic.showServerTime
end


-- [w]组合快捷键
function ViewManager:combinationHotKey_146_77() 
    GuideUtils.DEBUG_REPEAT_TRIGGER = not GuideUtils.DEBUG_REPEAT_TRIGGER
    if GuideUtils.DEBUG_REPEAT_TRIGGER then self:showTip("重复触发引导开启") else self:showTip("重复触发引导关闭") end
end

function ViewManager:combinationHotKey_146_78() 
    self:onIndulge(1)
end
function ViewManager:combinationHotKey_146_79() 
    if GuideUtils.unloginGuideEnable then return end
    self:breakOffGuide()
end
function ViewManager:combinationHotKey_146_80() 
    ServerManager:getInstance():disconnect()
end
function ViewManager:combinationHotKey_146_81() 
    ServerManager:getInstance():RS_reinit()
end
local test = false
function ViewManager:combinationHotKey_146_82() 
    test = not test
    ServerManager:getInstance():setTest_Recv(test)
    if test then
        -- self:lock()
        self:showTip("下行丢失")
    else
        -- self:unlock()
        self:showTip("下行正常")
    end
end
local test2 = false
function ViewManager:combinationHotKey_146_83() 
    test2 = not test2
    ServerManager:getInstance():setTest_Send(test2)
    if test2 then
        -- self:lock()
        self:showTip("上行丢失")
    else
        -- self:unlock()
        self:showTip("上行正常")
    end
end
local test3 = false
function ViewManager:combinationHotKey_146_84() 
    test3 = not test3
    ServerManager:getInstance():setTest_Reauth(test3)
    if test3 then
        -- self:lock()
        self:showTip("reauth失败")
    else
        -- self:unlock()
        self:showTip("reauth正常")
    end
end

local test4 = false
function ViewManager:combinationHotKey_146_85() 
    test4 = not test4
    ServerManager:getInstance():setTest_Disconnect(test4)
    if test4 then
        -- self:lock()
        self:showTip("请求后断线")
    else
        -- self:unlock()
        self:showTip("请求后不断线")
    end
end

-- [a]组合快捷键
function ViewManager:combinationHotKey_124_77() 
    cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath() .."/UserDefault.xml")
end
function ViewManager:combinationHotKey_124_78() 
    cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath() .."/game_system.log")
end
function ViewManager:combinationHotKey_124_79()
    self:deleteAccount()
end
function ViewManager:combinationHotKey_124_80()
    self:restart()
end
function ViewManager:combinationHotKey_124_81()
    self:returnMain()
end

--[s]组合快捷键
function ViewManager:combinationHotKey_142_77()
    DelayCallForWindows(function () 
        local ffi = require "ffi"
        ffi.cdef[[
            typedef char TCHAR;
            typedef unsigned int UINT;
            typedef const TCHAR *LPCSTR;
            typedef UINT HWND;
            int ShellExecuteA(HWND hwnd, LPCSTR lpOperation, LPCSTR lpFile, LPCSTR lpParameters, LPCSTR lpDirectory, UINT nShowCmd);
        ]]
        local str = cc.FileUtils:getInstance():getWritablePath()
        local shell32 = ffi.load("shell32.dll")
        shell32.ShellExecuteA(0, 'open', str, '', '', 1) 
    end)
end

local winsizeTab = {
					{1136, 640}, 
					{960, 640},
					{1024, 768},
                    {1386, 640}, 
					{1136 * 1.5, 640 * 1.5},
					{1024 / 1.2, 768 / 1.2},
					{1136 * 0.4, 640 * 0.4}, 
					{1024 * 0.8, 768 * 0.8},
					}
-- F1 ~ F8
for i = 1, 8 do
	ViewManager["hotKey_".. 46 + i] = function (self)
		self:onWinSize(winsizeTab[i][1], winsizeTab[i][2])
	end
end

local hotkey = {}
    
function hotkey.dtor()
    brightness = nil
    contrast = nil
    findedObjMap = nil   
    hotkey = nil
    hue = nil
    saturation = nil
    winsizeTab = nil
    fps = nil
end

return hotkey

