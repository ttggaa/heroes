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
function ViewManager:combinationHotKey_148_81() 
    BattleUtils.XBW_SKILL_TEAM_DEBUG = not BattleUtils.XBW_SKILL_TEAM_DEBUG
    if BattleUtils.XBW_SKILL_TEAM_DEBUG then self:showTip("战斗DEBUG模式显示所有的士兵") else self:showTip("战斗DEBUG模式显示单个的士兵") end
end
function ViewManager:combinationHotKey_148_82() 
    GameStatic.showWalleUpdate = not GameStatic.showWalleUpdate
    self:walleUpgradeUI()
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


-- [d]组合快捷键战斗使用
function ViewManager:combinationHotKey_127_77() 
    if self._views["battle.BattleView"] then
        local _battleView = self._views["battle.BattleView"]
        if _battleView and _battleView.view then
            _battleView.view._battleScene:setBattleSpeed(0)
        end
    end
end
function ViewManager:combinationHotKey_127_78() 
    if self._views["battle.BattleView"] then
        local _battleView = self._views["battle.BattleView"]
        if _battleView and _battleView.view then
            _battleView.view._battleScene:setBattleSpeed(1)
        end
    end
end

function ViewManager:combinationHotKey_127_79()
    if BC and BC.logic then
        BC.logic:doSurrender()
    end
end

function ViewManager:combinationHotKey_127_80()
    if BC and BC.objLayer then
        if BC.objLayer._selectTeam and BC.objLayer._selectTeam.lSetForceDie then
            BC.objLayer._selectTeam:lSetForceDie()
            ViewManager:getInstance():showTip("杀死成功")   
        else
            ViewManager:getInstance():showTip("请先点击死亡的军团")  
        end
    end
end

function ViewManager:combinationHotKey_127_81(bBool)
--    os.execute("D:/project/war/svn/Resources/startWarProc.bat")
    if BattleUtils then
        if bBool == nil then
            BattleUtils.BATTLE_PROC_RECORD_DATA = not BattleUtils.BATTLE_PROC_RECORD_DATA
        else
            if BattleUtils.BATTLE_PROC_RECORD_DATA == bBool then
                return
            end
            BattleUtils.BATTLE_PROC_RECORD_DATA = bBool
        end
        if BattleUtils.BATTLE_PROC_RECORD_DATA then
            BattleUtils._BerjsonData2lua_battleData = BattleUtils.jsonData2lua_battleData
            if BattleUtils._BerjsonData2lua_battleData then
                BattleUtils.jsonData2lua_battleData = function(data)
                    if _G.jsonToTableData == nil or _G.jsonToTableData["atk"] == nil then
                        _G.jsonToTableData = _G.jsonToTableData or {}
                        _G.jsonToTableData["atk"] = clone(data)
                    else
                        _G.jsonToTableData["def"] = clone(data)
                    end
                    return BattleUtils._BerjsonData2lua_battleData(data)
                end
                BattleUtils._forcSaveAttackData = function(table)
                    if _G.jsonToTableData then
                        if _G.jsonToTableData.atk then
                            --释放的技能列表
                            _G.jsonToTableData.atk.skillList = json.encode(clone(table._playCastTime))
                        end
                        _G.jsonToTableData["r1"] = table.r1
                        _G.jsonToTableData["r2"] = table.r2
                        _G.jsonToTableData["attackType"] = table.attackType
                        
                        if table.attackType == BattleUtils.BATTLE_TYPE_WORDBOSS then
                            _G.jsonToTableData["def"] = table.def
                        end

                        --打印出战斗数据和复盘数据进行对比 
                        local resData
                        local time = math.floor(table.battleTime)
                        local value1, value2, value3, value4 = BC.logic:getCurHP()
                        local v1, v2, v3, v4 = BC.logic:getSummonHP()
                        local hp = {value1+v1, value2+v2, value3+v3, value4+v4}
                        local hpex = {value1, value2, value3, value4}
--                        local remainHpProp1 = hp[1] / hp[2] * 30
--                        local remainHpProp2 = hp[3] / hp[4] * 30
--                        local remainTeamProp1 = table.ex.remainTeamCount1 / table.ex.maxTeamCount1 * 70
--                        local remainTeamProp2 = table.ex.remainTeamCount2 / table.ex.maxTeamCount2 * 70
                        local remainHpProp1 = 0 
                        if hp[2] ~= 0 then
                            remainHpProp1 = hp[1] / hp[2] * 30
                        end
                        local remainHpProp2 = 0
                        if hp[4] ~= 0 then
                            remainHpProp2 = hp[3] / hp[4] * 30
                        end
        
                        local remainTeamProp1 = 0
                        if table.ex.maxTeamCount1 ~= 0 then
                            remainTeamProp1 = table.ex.remainTeamCount1 / table.ex.maxTeamCount1 * 70
                        end
                        local remainTeamProp2 = 0
                        if table.ex.maxTeamCount2 ~= 0 then
                            remainTeamProp2 = table.ex.remainTeamCount2 / table.ex.maxTeamCount2 * 70
                        end
                        local atkRid = "0"
                        local defRid = "0"
                        if table.atkRid then
                            atkRid = table.atkRid
                        end
                        if table.defRid then
                            defRid = table.defRid
                        end
                        resData = 
                        {
                            hp = hp, 
                            hpex = hpex, 
                            win = table._isWin, 
                            isTimeUp = table.isTimeUp, 
                            time = time, 
                            r1 = table.r1, 
                            r2 = table.r2, 
                            dieList = table.dieList, 
                            battleTime = math.floor(time * 1000), 
                            heroID = table.hero1.ID,
                            totalDamage1 = table.ex.totalDamage1, 
                            totalDamage2 = table.ex.totalDamage2,
                            totalRealDamage1 = table.ex.totalRealDamage1,
                            totalRealDamage2 = table.ex.totalRealDamage2,
                            dieCount1 = table.ex.dieCount1,
                            dieCount2 = table.ex.dieCount2,
                            remainHpProp1 = remainHpProp1,
                            remainHpProp2 = remainHpProp2,
                            remainTeamProp1 = remainTeamProp1,
                            remainTeamProp2 = remainTeamProp2,
                            attackType = table.attackType,
                            atkRid = atkRid,
                            defRid = defRid,
                            curTotalHurt = table.curTotalHurt or 0,
                        }
                        resData.teamInfo = table.teamInfo
                        if table.exInfo then
                            for k, v in pairs(table.exInfo) do
                                resData[k] = v
                            end
                        end
                        _G.jsonToTableData["resData"] = clone(resData)
                        local path = cc.FileUtils:getInstance():getWritablePath()
                        local f = io.open(path .. "/test.txt", "w+")
                        f:write(json.encode(_G.jsonToTableData))
                        f:close()
                        _G.jsonToTableData = nil
                        dump(resData)
                        if table.attackType == BattleUtils.BATTLE_TYPE_WORDBOSS 
                            or table.attackType == BattleUtils.BATTLE_TYPE_WoodPile_1
                        then
                            --暂时客户端的战斗复盘只支持，世界boss，木桩战斗
                            os.execute("startWarProc.bat")
                        end
                    end
                end
                ViewManager:getInstance():showTip("保存战斗复盘数据开启")
            end
        else
            if BattleUtils._BerjsonData2lua_battleData then
                BattleUtils.jsonData2lua_battleData = BattleUtils._BerjsonData2lua_battleData
                BattleUtils._BerjsonData2lua_battleData = nil
            end
            BattleUtils._forcSaveAttackData = nil
            ViewManager:getInstance():showTip("保存战斗复盘数据关闭")
        end 
    end
end

function ViewManager:combinationHotKey_127_82()
    BattleUtils.XBW_SKILL_TEAM_ATTACK_ARER = not BattleUtils.XBW_SKILL_TEAM_ATTACK_ARER
    ViewManager:getInstance():showTip((BattleUtils.XBW_SKILL_TEAM_ATTACK_ARER and "显示攻击范围" or "不显示攻击范围"))    
end

function ViewManager:combinationHotKey_127_83()
   xpcall(function()
       require "game.view.gmlayer.GMLayer"
       GM.lSwitch()
   end,function()
       ViewManager:getInstance():showTip("对不起你本地没有GMLayer文件")   
   end)
--    __autoChoiceBattle(2)
end

--获取当前已拥有的hero和team 
function  __getTableTeamData()
    if _G.heroId == nil or _G.teamId == nil then
        _G.heroId = {}
        _G.teamId = {}
        _G.teamIdClass = {{}, {}, {}, {}, {}}
        _G.tformationNumber = 0
        _G.weaponsData = {{}, {}, {}, {}}
        local teamModel = ModelManager:getInstance():getModel("TeamModel")
        local heroModel = ModelManager:getInstance():getModel("HeroModel")

        local heroData = heroModel:getData()
        local teamData = teamModel:getUserTeamData()

        for key, var in pairs(heroData) do
            _G.heroId[#_G.heroId + 1] = tonumber(key)
        end
        
        for key, var in pairs(teamData) do
            if var then
                _G.teamId[#_G.teamId + 1] = tonumber(var.teamId)
                local teamData = tab:Team(tonumber(var.teamId))
                if teamData then
                    if teamData.class then
                        _G.teamIdClass[teamData.class][#_G.teamIdClass[teamData.class] + 1] = tonumber(var.teamId)
                    end
                end
            end
        end

        local TformationModel = ModelManager:getInstance():getModel("TformationModel")
        local TformationData = TformationModel:getData()
        if TformationData then
            _G.tformationNumber = table.nums(TformationData)
        end

        local weaponsModel = ModelManager:getInstance():getModel("WeaponsModel")
        local weaponsData = weaponsModel:getWeaponsDataF()
        if weaponsData then
            for key, var in ipairs(weaponsData) do
--                _G.weaponsData
                if var then
                    _G.weaponsData[tonumber(var.weaponType)][#_G.weaponsData[tonumber(var.weaponType)] + 1] = var.weaponId
                end
            end
        end
    end
    return _G.heroId, _G.teamId, _G.teamIdClass, _G.tformationNumber, _G.weaponsData
end

function __clearAutoGlobalData()
    _G.heroId, _G.teamId, _G.teamIdClass, _G.tformationNumber, _G.weaponsData = nil, nil, nil, nil, nil
end

--自动选择上证兵团，英雄，援助兵团，宝物，器械
function __autoChoiceBattle(formationId, callback, camp, bNoHelpTeam, bNoWeapons, bIsInAttack)

    if bIsInAttack and callback then
        --GM指令直接进战斗，但是援助，器械自己去掉，还有战斗类型，自己控制
        callback(true)
    end

    local heroIds, teamIdsAll, teamIdClass, tformationNumber, weaponsData = __getTableTeamData()
    local curHeroId = heroIds[math.random(1, #heroIds)]
    local isWea, isTform = true, true
    local _heroId, _teamsId, _backTeamType = nil, {}, {}
    local backTypa = nil
    if camp == nil then
        camp = 1
    end
    local teamIds = {}
    if BattleUtils.__attackType == 3 then
        --只能上阵 输出 防御 突击
        for i,v in ipairs(teamIdClass[1]) do
            teamIds[#teamIds + 1] = v
        end
        for i,v in ipairs(teamIdClass[2]) do
            teamIds[#teamIds + 1] = v
        end
        for i,v in ipairs(teamIdClass[3]) do
            teamIds[#teamIds + 1] = v
        end
    elseif BattleUtils.__attackType == 4 then
        --只能上证 远程 魔法
        for i,v in ipairs(teamIdClass[4]) do
            teamIds[#teamIds + 1] = v
        end
        for i,v in ipairs(teamIdClass[5]) do
            teamIds[#teamIds + 1] = v
        end
    else
        teamIds = teamIdsAll
    end
        
    if _G.autoAttackTable and _G.autoAttackTable[camp] then
        isWea = _G.autoAttackTable[camp][4]
        isTform = _G.autoAttackTable[camp][5]
        _heroId = _G.autoAttackTable[camp][1]
        _teamsId = _G.autoAttackTable[camp][2]
        _backTeamType = _G.autoAttackTable[camp][3]
        backTypa = _G.autoAttackTable[camp][3][1]
    end

    local teamsDataId = {}
    local teamsDataIdPod = {}
    local maxCount = 8
    if #teamIds >= 8 then
        maxCount = 8
    else
        maxCount = #teamIds
    end

    local numberSetAuto = #_teamsId

    for i = 1, maxCount do
        repeat
            local _curId = 0
            if numberSetAuto == 0 then
                _curId = teamIds[math.random(1, #teamIds)]
            else
                _curId = _teamsId[math.random(1, #_teamsId)]
            end
            if not table.indexof(teamsDataId, _curId) then
                local curTable = {}
                curTable[1] = _curId
                local teamData = tab:Team(_curId) --clone(tab:Team[_curId])
                local possiton = clone(tab:GodWarPosition(teamData.posclass).position)
                for key = #possiton, 1, -1 do
                    --过略掉不能存放的位置
                    for _key, _var in ipairs(teamsDataIdPod) do
                        if _var and _var[2] == possiton[key] then
                            table.remove(possiton, key)
                        end
                    end
                end
                
                if #possiton > 0 then
                    curTable[2] = possiton[math.random(1, #possiton)]
                    teamsDataId[#teamsDataId + 1] = _curId
                    teamsDataIdPod[#teamsDataIdPod + 1] = curTable
                    if numberSetAuto > 0 then
                        numberSetAuto = numberSetAuto - 1
                    else
                        numberSetAuto = 0
                    end
                    break
                end
            end
        until true;
--        print(i, #teamsDataIdPod)
    end
    
    local backTeamData = {}
    local bid = backTypa or math.random(1, 6)
    if #teamIds > 8 then
        --兵团数量大于8的时候才会上阵援助
        local backupData = tab.backupMain[bid]
        if backupData and backupData.class then
            for key, var in ipairs(backupData.class) do
                if var then
                    if #teamIdClass[var[1]] > 0 then
                        local count = 10
                        repeat
                            local teamId = teamIdClass[var[1]][math.random(1, #teamIdClass[var[1]])]
                            if not table.indexof(teamsDataId, teamId) then
                                teamsDataId[#teamsDataId + 1] = teamId
                                backTeamData[key] = teamId
                                break
                            end
                            count = count - 1
                            if count <= 0 then
                                --找了10次没找到直接退出
                                backTeamData[key] = 0
                                break
                            end
                        until true;
                    else
                        backTeamData[key] = 0
                    end
                end
            end
        end
    end

    local _tformationNumber = 0
    if isTform then
        --宝物编组的随机
        if tformationNumber > 0 then
            _tformationNumber = math.random(1, tformationNumber)
        end 
    end
    local lWeaponsData = {}
    if isWea then
        --器械的随机weaponsData
        
        for i = 1, 3 do
            if #weaponsData[i] >= 1 then
                lWeaponsData[i] = weaponsData[i][math.random(1, #weaponsData[i])]
            end
        end
    end
--    dump(teamsDataId)
--    dump(backTeamData)
--    if true then
--        return
--    end
    local function startRandomChoice() 
        local formationModel = ModelManager:getInstance():getModel("FormationModel")
        local data = clone(formationModel:getFormationData())
        data = data[formationId]
        for i=1, 8 do
            local teamId = data["team" .. i]
            if teamId then
                data["team" .. i] = 0
                data["g" .. i] = 0
            end
        end
        --修改当前的数据否则下次打开布阵界面会出现问题
        for key, var in pairs(teamsDataIdPod) do
            if var then
                data["g"..key] = tonumber(var[2])
                data["team"..key] = tonumber(var[1])
            end
        end
        data.heroId = _heroId or curHeroId

        --援助的数据    
        if not bNoHelpTeam then
            if data["backupTs"] and data["backupTs"][tostring(bid)] then
                data.bid = bid
                data["backupTs"][tostring(data.bid)]["bt1"] = nil
                data["backupTs"][tostring(data.bid)]["bt2"] = nil
                data["backupTs"][tostring(data.bid)]["bt3"] = nil
                for key, var in pairs(backTeamData) do
                    if var then
                        data["backupTs"][tostring(data.bid)]["bt" .. key] = var
                    end
                end
            end
        else
            data.bid = bid
            if data.bid and data["backupTs"] and data["backupTs"][tostring(data.bid)] then
                data["backupTs"][tostring(data.bid)]["bt1"] = nil
                data["backupTs"][tostring(data.bid)]["bt2"] = nil
                data["backupTs"][tostring(data.bid)]["bt3"] = nil
            end
            data.bid = nil
        end
        --器械的数据
        if not bNoWeapons then
            if #lWeaponsData > 0 then
                data["weapon" .. 1] = 0
                data["weapon" .. 2] = 0
                data["weapon" .. 3] = 0
                for key, var in pairs(lWeaponsData) do
                    if var then
                        data["weapon" .. key] = var
                    end
                end
            end
        else
            data["weapon" .. 1] = 0
            data["weapon" .. 2] = 0
            data["weapon" .. 3] = 0
        end
--        dump(data)
        formationModel:saveData(data, formationId, nil, nil, nil, callback)
    end

    if _tformationNumber > 0 then
        ServerManager:getInstance():sendMsg("FormationServer", "changeTformation", {id = formationId,tid = _tformationNumber}, true, { }, function(result)
            startRandomChoice()
--            ViewManager:getInstance():showTip("宝物随机成功")
        end)
    else
        startRandomChoice()
    end

end

--自动战斗的脚本设置
function ViewManager:autoSwitchAttackFormationView(nAttackType, bIsInAttack)


    local function currencyAutoBattleView(nType, callback, bNoHelpTeam, bNoWeapons, bIsInAttack)
        local function loadingStartAttack() 
            local formationModel = ModelManager:getInstance():getModel("FormationModel")  
            self:showView("formation.NewFormationView", {
                formationType = formationModel.kFormationTypeStakeAtk2,
                extend = {
                    enterBattle = {
                        [formationModel.kFormationTypeStakeAtk2] = false,
                        [formationModel.kFormationTypeStakeDef2] = true
                    }
                },
                callback = function(playerInfo, teamCount, filterCount, formationType)                            
                    ServerManager:getInstance():sendMsg("StakeServer", "stakeDefiningAttack", {id = 1, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result)
                        self:popView()
                        if callback then
                            callback(result)
                        end
                    end)
                end
            })
       end
        __autoChoiceBattle(41, function(sucess)
            if sucess then
                loadingStartAttack()
            else
                self:showTip("保存战斗类型" .. nAttackType .. "出错")
                _G._nStep = 0
            end
        end, 1, bNoHelpTeam, bNoWeapons, bIsInAttack)
    end

    if nAttackType == BattleUtils.BATTLE_TYPE_Arena then
        local function _startBattle(result)
            local UserModel = ModelManager:getInstance():getModel("UserModel")
            local userRid = UserModel:getUID()
            local enemyRid  = "8001_2967"
            local left 
            local right 
            left  = BattleUtils.jsonData2lua_battleData(result.atk)
            right = BattleUtils.jsonData2lua_battleData(result.def)
            -- BattleUtils.disableSRData()
            -- 关闭布阵
            self:popView()
            BattleUtils.enterBattleView_Arena( left, right, result.r1, result.r2, 3, false,
            function (info, callback)
                -- dump(info)
                -- 战斗结束
                _G._nStep = 3
                callback(info)
            end,
            function (info)
                -- 退出战斗
            end)
        end

        local detailCallback = function( result,isPlat )
            local info = result.info
            if not info.battle or not info.battle.formation then
                self:showTip("对方尚未在竞技场布阵，无法切磋")
                return 
            end
            info.battle.msg = info.msg
            info.battle.rank = info.rank
            local enemyFormation = clone(info.battle.formation)
            enemyFormation.filter = ""
                -- 给布阵传递数据
            ModelManager:getInstance():getModel("ArenaModel"):setEnemyData(info.battle.teams)
            ModelManager:getInstance():getModel("ArenaModel"):setEnemyHeroData(info.battle.hero)
            local formationType = nAttackType
            _G._nStep = 1
            self:showView("formation.NewFormationView", {
                formationType = formationType,
                enemyFormationData = {[formationType] = enemyFormation},
                callback = function(leftData)
                    -- 实质上还是播战报
                    
                    if enemyRid and enemyRid ~= "" then
                        local competeMethod = isPlat and "platCompete" or "compete"
                        ServerManager:getInstance():sendMsg("GameFriendServer", competeMethod, {rid = userRid, fid = enemyRid,tSec = nil}, true, {}, function(result)
                            if result then
                                ServerManager:getInstance():sendMsg("BattleServer","getBattleReport",{reportKey = result},true,{},function( result1 )
                                    _startBattle(result1)
                                end)
                            end
                        end)
                    end
                end,
            })
        end
        __autoChoiceBattle(2, function(sucess)
            if sucess then
                ServerManager:getInstance():sendMsg("ArenaServer", "getDetailInfo", {roleId = userRid}, true, {}, function(result) 
                        detailCallback(result)
                end)
            else
                self:showTip("保存战斗队列出问题")
                _G._nStep = 0
            end
        end)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_WoodPile_1 then
        -- 41 108
        local function loadingStartAttack() 
            local formationModel = ModelManager:getInstance():getModel("FormationModel")  
            self:showView("formation.NewFormationView", {
                formationType = formationModel.kFormationTypeStakeAtk2,
                extend = {
                    enterBattle = {
                        [formationModel.kFormationTypeStakeAtk2] = false,
                        [formationModel.kFormationTypeStakeDef2] = true
                    }
                },
                callback = function(playerInfo, teamCount, filterCount, formationType)                            
                    ServerManager:getInstance():sendMsg("StakeServer", "stakeDefiningAttack", {id = 1, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result)
                        self:popView()
                        local token = result.token or nil
                        local leftInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
                        local rightInfo = BattleUtils.jsonData2lua_battleData(result["def"])
                        BattleUtils.enterBattleView_WoodPile_1(leftInfo, rightInfo, 
                            function (info, callback)
                            -- 战斗结束
                                callback(info)
                                _G._nStep = 3
                            end,
                            function (info)
                                -- 退出战斗
                            end,false)
                    end)
                end
        
            })
        end

        local isAttack = false
        __autoChoiceBattle(41, function(sucess)
                if sucess then
                    __autoChoiceBattle(108, function(sucess)
                        if sucess then
                            loadingStartAttack()
                        else
                            self:showTip("保存木桩防守方战斗队列出问题")
                            _G._nStep = 0
                        end
                    end, 2)
                else
                    self:showTip("保存木桩战斗方战斗队列出问题")
                    _G._nStep = 0
                end
        end, 1)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_WORDBOSS then
        --世界BOSS
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        local function loadingStartAttack() 
            local formationModel = ModelManager:getInstance():getModel("FormationModel")  
            self:showView("formation.NewFormationView", {
                formationType = formationModel.kFormationTypeStakeAtk2,
                extend = {
                    enterBattle = {
                        [formationModel.kFormationTypeStakeAtk2] = false,
                        [formationModel.kFormationTypeStakeDef2] = true
                    }
                },
                callback = function(playerInfo, teamCount, filterCount, formationType)                            
                    ServerManager:getInstance():sendMsg("StakeServer", "stakeDefiningAttack", {id = 1, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result)
                        self:popView()
                        local token = result.token or nil
                        local leftInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
                        -- local rightInfo = BattleUtils.jsonData2lua_battleData(result["def"])
                        local _data = BattleUtils.enterBattleView_BOSS_WordBoss(leftInfo, 
                        function(info, callback)
                            -- 战斗结束
                            callback(info)
                            _G._nStep = 3
                        end,
                        function(info, callback)
                            -- 退出战斗
                        end,
                        nil, nil, 7110031, 0, 5, 75020001
                        )
                    end)
                end
            })
       end
        __autoChoiceBattle(41, function(sucess)
            if sucess then
                loadingStartAttack()
            else
                self:showTip("保存世界boss战斗报错")
                _G._nStep = 0
            end
        end, 1, true)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_WoodPile_2 then
        --木桩战斗
        local function loadingStartAttack() 
            local formationModel = ModelManager:getInstance():getModel("FormationModel")  
            local stageId = 1
            local stakeHeroTb = tab:StakeHero(stageId) 
            self:showView("formation.NewFormationView", {
                formationType = formationModel.kFormationTypeStakeAtk1,
                enemyFormationData = {[formationModel.kFormationTypeStakeAtk1] = ModelManager:getInstance():getModel('StakeModel'):initEnemyFormationData(stageId)},
                recommend = stakeHeroTb.hotHero, 
                extend = {sortFront = stakeHeroTb.hotHero},
                callback = function(playerInfo, teamCount, filterCount, formationType)                            
                    ServerManager:getInstance():sendMsg("StakeServer", "beforeStakeAttack", {id = stageId, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result)
                        self:popView()
                        local token = result.token or nil
                        -- dump(result,"-------",10)
                        local leftInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
                        BattleUtils.enterBattleView_WoodPile_2(leftInfo, stageId, 
                            function (info, callback)
                                -- 战斗结束
                                -- info.win = 1
                                callback(info)  
                                _G._nStep = 3                
                            end,
                            function (info)
                                -- 退出战斗
                            end,false)
                    end)
                end
            })
       end
        __autoChoiceBattle(40, function(sucess)
            if sucess then
                loadingStartAttack()
            else
                self:showTip("保存木桩NPC战斗报错")
                _G._nStep = 0
            end
        end, 1, true, false, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_BOSS_DuLong then
        --仙女龙
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_BOSS_XnLong(201, playerInfo,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
     
    elseif nAttackType == BattleUtils.BATTLE_TYPE_BOSS_XnLong then
        --毒龙
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_BOSS_DuLong(101, playerInfo,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_BOSS_SjLong then
        --水晶龙
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_BOSS_SjLong(301, playerInfo,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_Elemental_1
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_2
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_3
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_4
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_5
    then
        --元素位面 
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            local kind = nAttackType - 25
            BattleUtils.enterBattleView_Elemental(playerInfo, kind or 5, 4,
            function (info, callback)
                -- 战斗结束
                -- dump(info)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_GBOSS_1 then
        --联盟探索BOSS1
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_GBOSS_1(100, true, playerInfo,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_GBOSS_2 then
        --联盟探索BOSS2
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_GBOSS_2(100, true, playerInfo,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_GBOSS_3 then
        --联盟探索BOSS3
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_GBOSS_3(100, true, playerInfo,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_Siege then
        --攻城战(副本&远征)
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_Fuben(playerInfo, BattleUtils.PVE_INTANCE_SIEGE_ID, false,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    -- elseif nAttackType == BattleUtils.BATTLE_TYPE_CloudCity then
        --云中城
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
    elseif nAttackType == BattleUtils.BATTLE_TYPE_AiRenMuWu then
        --矮人
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_AiRenMuWu(901, playerInfo, 0,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_Zombie then
        --僵尸
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_Zombie(902, playerInfo, 0, 2, 0,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end)
        end, true, true, bIsInAttack)
    elseif nAttackType == BattleUtils.BATTLE_TYPE_Legion then
        --军团
        --暂时没有什么接口，所以直接使用木桩战斗中阵容进行战斗
        currencyAutoBattleView(nAttackType, function(result)
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"]) 
            BattleUtils.enterBattleView_Legion(playerInfo, 101,
            function (info, callback)
                callback(info)
                _G._nStep = 3
            end,
            function ()

            end,
            nil, nil, false)
        end, true, true, bIsInAttack)
    else
        self:showTip("这个战斗类型不支持，请找王者成加")
    end
end

function ViewManager:autoSstartAttack(nAttackType, popView)
    print("nAttackType = ", nAttackType)
    if popView == nil then
        print("popView is null")
        return
    end
    if nAttackType == BattleUtils.BATTLE_TYPE_Arena then
        if popView.view and popView.view.doBattle then
            BattleUtils.onceFastBattle = true
            popView.view:doBattle()
        end
    elseif nAttackType == BattleUtils.BATTLE_TYPE_WoodPile_1 then
        ScheduleMgr:delayCall(2000, self, function()
            if popView.view and popView.view.switchStakeFormation then
                popView.view:switchStakeFormation()
            end
            ScheduleMgr:delayCall(2000, self, function()
                if popView.view and popView.view.doBattle then
                    BattleUtils.onceFastBattle = false
                    popView.view:doBattle()
                end
            end
            )
        end    
        )
    elseif nAttackType == BattleUtils.BATTLE_TYPE_WORDBOSS
        or nAttackType == BattleUtils.BATTLE_TYPE_BOSS_DuLong
        or nAttackType == BattleUtils.BATTLE_TYPE_BOSS_XnLong
        or nAttackType == BattleUtils.BATTLE_TYPE_BOSS_SjLong
        or nAttackType == BattleUtils.BATTLE_TYPE_Crusade
        or nAttackType == BattleUtils.BATTLE_TYPE_GBOSS_1
        or nAttackType == BattleUtils.BATTLE_TYPE_GBOSS_2
        or nAttackType == BattleUtils.BATTLE_TYPE_GBOSS_3
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_1
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_2
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_3
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_4
        or nAttackType == BattleUtils.BATTLE_TYPE_Elemental_5
        or nAttackType == BattleUtils.BATTLE_TYPE_AiRenMuWu
        or nAttackType == BattleUtils.BATTLE_TYPE_Zombie
        or nAttackType == BattleUtils.BATTLE_TYPE_WoodPile_2
        or nAttackType == BattleUtils.BATTLE_TYPE_Siege
        or nAttackType == BattleUtils.BATTLE_TYPE_Legion
    then
        if popView.view and popView.view.doBattle then
            BattleUtils.onceFastBattle = false
            popView.view:doBattle()
        end
    end
end

function ViewManager:combinationHotKey_127_84()
    _G._nStep = 0
    _G.___countluaError = 0
    if _G._autoBattleSchedule == nil then
--        self:combinationHotKey_127_81(true)
        local function callback(dt)
            local popView = self._viewLayer:getChildren()[#self._viewLayer:getChildren()]
            if popView == nil then
                print("popView is nil")
            end

            if self._luaError then
                if _G.___countluaError == nil then
                    _G.___countluaError = 0
                end
                if #self._luaError >  _G.___countluaError then
                    ---这个时候战斗报错了
                    --复制test.txt文件中的战斗数据方便寻找报错
                    print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
                    local path = cc.FileUtils:getInstance():getWritablePath()
                    local f1 = io.open(path .. "/test.txt", "r+")
                    local str = f1:read()
                    f1:close()

                    local path = cc.FileUtils:getInstance():getWritablePath()
                    local f2 = io.open(path .. "/BattleError" .. os.time() ..".txt", "w+")
                    f2:write(str)
                    f2:close()

                    _G.___countluaError = #self._luaError
                end
            end

            print(popView.view:getClassName(), _G._nStep)
            if popView.view:getClassName() == "battle.BattleView" and _G._nStep == 2 then
                
                --战斗界面
            elseif popView.view:getClassName() == "formation.NewFormationView" and _G._nStep == 1 then
                _G._nStep = 2
                --进入战斗
                self:autoSstartAttack(BattleUtils.__attackType, popView)
            elseif popView.view:getClassName() == "main.MainView" and _G._nStep == 0 then
                _G._nStep = 1
                --进战斗选择界面
                if BattleUtils.__attackTypeTable and #BattleUtils.__attackTypeTable > 1 then
                    BattleUtils.__attackType = BattleUtils.__attackTypeTable[math.random(1, #BattleUtils.__attackTypeTable)]
                end
                self:autoSwitchAttackFormationView(BattleUtils.__attackType)
            elseif popView.view:getClassName() == "global.GlobalOkDialog" then
                --战斗报错
                _G.jsonToTableData = nil
                if popView.view and popView.view.close then
                    popView.view:close(false, popView.view._callback)
                end
                _G._nStep = 3
            elseif  _G._nStep == 3 then
                --回到主界面
                _G._nStep = 0
                if popView.view:getClassName() ~= "main.MainView" then
                    ScheduleMgr:delayCall(2000, self, function()
                        self:popView()
                    end)
--                    self:returnMain()
                end
            end
        end
        _G._autoBattleSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 4.0, false)
    else
        self:combinationHotKey_127_81(false)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_G._autoBattleSchedule)
        _G._autoBattleSchedule = nil
        __clearAutoGlobalData()
    end
end

--去除正常的print和dump的输出
function ViewManager:combinationHotKey_127_85()
    if _G._IsPrint == nil then
        _G._IsPrint = true
        _G._print = print
        print = function(...)
--            _print("+++++++++++++++++++")
        end
        _G.__dump = dump
        dump = function(...)

        end
       self:showTip("111111111111")
--        _G.__dump = function(value, desciption, nesting)
--                        if type(nesting) ~= "number" then nesting = 6 end

--                        local lookupTable = {}
--                        local result = {}

--                        local traceback = string.split(debug.traceback("", 2), "\n")
--                        if traceback[4] then
--                            _print("dump from: " .. string.trim(traceback[4]))
--                        end

--                        local function dump_(value, desciption, indent, nest, keylen)
--                            desciption = desciption or "<var>"
--                            local spc = ""
--                            if type(keylen) == "number" then
--                                spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
--                            end
--                            if type(value) ~= "table" then
--                                result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
--                            elseif lookupTable[tostring(value)] then
--                                result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
--                            else
--                                lookupTable[tostring(value)] = true
--                                if nest > nesting then
--                                    result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
--                                else
--                                    result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
--                                    local indent2 = indent.."    "
--                                    local keys = {}
--                                    local keylen = 0
--                                    local values = {}
--                                    for k, v in pairs(value) do
--                                        keys[#keys + 1] = k
--                                        local vk = dump_value_(k)
--                                        local vkl = string.len(vk)
--                                        if vkl > keylen then keylen = vkl end
--                                        values[k] = v
--                                    end
--                                    table.sort(keys, function(a, b)
--                                        if type(a) == "number" and type(b) == "number" then
--                                            return a < b
--                                        else
--                                            return tostring(a) < tostring(b)
--                                        end
--                                    end)
--                                    for i, k in ipairs(keys) do
--                                        dump_(values[k], k, indent2, nest + 1, keylen)
--                                    end
--                                    result[#result +1] = string.format("%s}", indent)
--                                end
--                            end
--                        end
--                        dump_(value, desciption, "- ", 1)

--                        for i, line in ipairs(result) do
--                            _print(line)
--                        end
--                    end
    else
        print = _G._print
        dump = _G.__dump
        _G._IsPrint = nil
--        _G.__dump = dump
    end
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
                    {1280, 640},
                    {1280, 800},
                    }
-- F1 ~ F8
for i = 1, 9 do
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

