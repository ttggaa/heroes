--[[
    Filename:    GuideUtils.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-19 17:28:29
    Description: File description
--]]

if cc.Node.getFullName == nil then
    cc.Node.getFullName = function (sender)
        local name = sender:getName()
        if name == nil or name == "" and sender.getClassName then
            name = sender:getClassName()
        end
        if sender:getParent() then
            if name == nil or name == "" then
                local ret = sender:getParent():getFullName()
                return ret
            else
                local fullname = sender:getParent():getFullName()
                if fullname == nil or fullname == "" then
                    local ret = name
                    return ret
                else
                    local ret = fullname .. "." .. name
                    return ret
                end
            end
        else
            return name
        end
    end
end

local GuideUtils = {}

local GuideConfig = require "game.config.guide.GuideConfig"
GuideUtils.GuideConfig = GuideConfig
-- 重复触发支线引导
GuideUtils.DEBUG_REPEAT_TRIGGER = false

GuideUtils.ENABLE = GuideConfig.ENABLE
GuideUtils.ENABLE_BATTLE = GuideConfig.ENABLE_BATTLE
GuideUtils.DEBUG = GuideConfig.DEBUG
GuideUtils.ENABLE_TRIGGER = GuideConfig.ENABLE_TRIGGER

GuideUtils.isGuideRunning = false

function GuideUtils.resetConfig()
    GuideUtils.ENABLE = GuideConfig.ENABLE
    GuideUtils.ENABLE_BATTLE = GuideConfig.ENABLE_BATTLE
    GuideUtils.DEBUG = GuideConfig.DEBUG
end

function GuideUtils.getGuideBattleInfo()
    return require "game.config.guide.GuideBattleConfig"
end

-- 强制引导
GuideUtils.firstView = false

GuideUtils.guideIndex = 1
GuideUtils.guideChange = nil
GuideUtils.maxGuideIndex = #GuideConfig
print("新手引导一共"..GuideUtils.maxGuideIndex.."步")

function GuideUtils.inGuide()
    return GuideUtils.guideIndex <= GuideUtils.maxGuideIndex
end

-- 自动修正机制
function GuideUtils.autoAdjust(index, level)
    local maxLevel
    for i = #GuideConfig, 1, -1 do
        if GuideConfig[i].level then
            maxLevel = GuideConfig[i].level
            break
        end
    end
    -- 如果超过所有引导最大等级，设置10000
    if level > maxLevel then
        if index ~= 10000 then
            return 10000
        else
            return
        end
    end
    local newIndex = nil
    -- 如果引导步骤已经超过最大步骤，跳出
    if index > GuideUtils.maxGuideIndex then 
        return 
    end
    -- 找到一个当前等级，恰好超过的等级的步骤
    for i = 1, #GuideConfig do
        if GuideConfig[i].level then
            if level >= GuideConfig[i].level then
                if index < i then
                    newIndex = i
                end
            else
                break
            end
        end
    end
    return newIndex
end

function GuideUtils.saveIndex(index)
    if index == nil then return end
    if index <= GuideUtils.maxGuideIndex + 1 then
        GuideUtils.guideChange = index
    end
end

function GuideUtils.getNextBeginningIndex()
    local i = GuideUtils.guideIndex
    while GuideConfig[i] do
        if GuideConfig[i].beginning then
            return i
        end
        i = i + 1
    end
    return GuideUtils.guideIndex
end

-- 触发引导, 触发后 triggerConfig不为空, 触发引导触发后, 强制引导暂停触发

GuideUtils.enableTrigger = false
GuideUtils.triggerName = ""
local triggerConfig = nil

GuideUtils.triggerIndex = 0
GuideUtils.maxTriggerIndex = 0
GuideUtils.triggerOverCallback = nil

GuideUtils.triggerTLog = nil

-- 写死的特殊条件
function GuideUtils.checkTriggerEx(name)
    if name == "intanceWin_7100208" then
        return #ModelManager:getInstance():getModel("TeamModel"):getData() <= 6
    elseif name == "intanceLose_7100209" then
        local formationModel = ModelManager:getInstance():getModel("FormationModel")
        local data = formationModel:getFormationDataByType(1)
        local has102 = false
        local has105 = false
        for i = 1, 8 do
            if data["team"..i] == 0 then break end
            if data["team"..i] == 102 and data["g"..i] == 5 then
                has102 = true
            end
            if data["team"..i] == 105 and data["g"..i] == 6 then
                has105 = true
            end
        end
        return has102 and has105
    elseif name == "intanceLose_7100305" then
        local teamModel = ModelManager:getInstance():getModel("TeamModel")
        local teamData = teamModel:getTeamAndIndexById(104)
        return teamData == nil
    elseif name == "action_9" then
        local itemModel = ModelManager:getInstance():getModel("ItemModel")
        local _, count = itemModel:getItemsById(40323)
        return count >= 1
    elseif name == "view_team.TeamView" then
        return ModelManager:getInstance():getModel("UserModel"):getPlayerLevel() >= 34
    elseif name == "view_training.TrainingView" then
        return ModelManager:getInstance():getModel("UserModel"):getPlayerLevel() < 33
    elseif name == "view_treasure.TreasureView" then
        return (ModelManager:getInstance():getModel("UserModel"):getPlayerLevel() >= 49) and SystemUtils:enableTreasureStar()
    elseif name == "purgatory_winFirstStage" then
        return (ModelManager:getInstance():getModel("PurgatoryModel"):getCurrentSite() > 1)
    else
        return true
    end
end

-- 触发点配置
local triggerPoint = require "game.config.guide.TriggerConfig"

-- 按类型检查是否触发引导
function GuideUtils.checkTriggerByType(type, name, callback)
    if GuideUtils.ENABLE_TRIGGER and not GuideUtils.isGuideRunning then
        -- print("Trigger", type, name)
        local res = false
        local tConfig = triggerPoint[type][tostring(name)]
        if GuideUtils.checkTriggerEx(type .. "_" .. tostring(name)) then
            res = ViewManager:getInstance():doTriggerByName(tConfig, callback)
        end
        if not res then
            if callback then
                callback()
            end
        end
    else
        if callback then
            callback()
        end
    end
end 

-- 触发引导
function GuideUtils.triggerByName(name, callback)
    -- 检查是否已经触发过
    if not GuideUtils.DEBUG_REPEAT_TRIGGER then
        if ModelManager:getInstance():getModel("UserModel"):hasTrigger(name) then
            return nil
        end
    end
    triggerConfig = require ("game.config.guide.TriggerConfig_" .. name)
    GuideUtils.triggerIndex = 1

    if name == "2" or name == "10" or name == "11" then
        local uploadIndex = SystemUtils.loadAccountLocalData("guideTrigger"..name.."Index")
        if uploadIndex == nil or uploadIndex == "" then
            SystemUtils.saveAccountLocalData("guideTrigger"..name.."Index", 0)
            ApiUtils.playcrab_monitor_action("t"..name.."_0")
        end
    end
    -- tlog
    if name == "1" or name == "10" or name == "21" then
        if GuideUtils.triggerTLog == nil then
            GuideUtils.triggerTLog = {}
        end
        GuideUtils.triggerTLog[tonumber(name) * 100] = true
    end

    GuideUtils.triggerNameEx = name
    GuideUtils.maxTriggerIndex = #triggerConfig
    GuideUtils.enableTrigger = true
    GuideUtils.triggerName = "TriggerConfig_" .. name .. ":"
    GuideUtils.triggerOverCallback = callback
    return GuideUtils.getCurConfig()
end

-- 触发引导下一步
function GuideUtils.nextTrigger()
    GuideUtils.triggerIndex = GuideUtils.triggerIndex + 1
    local name = GuideUtils.triggerNameEx
    if name == "2" or name == "10" or name == "11" then
        local uploadIndex = SystemUtils.loadAccountLocalData("guideTrigger"..name.."Index")
        if uploadIndex == nil or uploadIndex == "" then
            uploadIndex = 0
        end
        if GuideUtils.triggerIndex > tonumber(uploadIndex) then
            ApiUtils.playcrab_monitor_action("t"..name.."_"..GuideUtils.triggerIndex - 1)
            SystemUtils.saveAccountLocalData("guideTrigger"..name.."Index", GuideUtils.triggerIndex - 1)
        end
    end
    -- tlog
    if name == "1" or name == "10" or name == "21" then
        if GuideUtils.triggerTLog == nil then
            GuideUtils.triggerTLog = {}
        end
        GuideUtils.triggerTLog[tonumber(name) * 100 + (GuideUtils.triggerIndex - 1)] = true
    end
    print("nextTrigger")
    if GuideUtils.triggerIndex > GuideUtils.maxTriggerIndex then
        GuideUtils.breakTrigger()
    end
end

-- 中断触发引导
function GuideUtils.breakTrigger()
    print("breakTrigger")
    triggerConfig = nil
    GuideUtils.enableTrigger = false
    if GuideUtils.triggerOverCallback then
        GuideUtils.triggerOverCallback()
        GuideUtils.triggerOverCallback = nil
    end
    ViewManager:getInstance():updateGuideIndexLabel()
end

function GuideUtils.getCurConfig()
    local config
    if triggerConfig then
        config = triggerConfig[GuideUtils.triggerIndex]
    else
        config = GuideConfig[GuideUtils.guideIndex]
    end
    return config
end

-- 检查是否有需要执行的新手引导
function GuideUtils.checkGuide_done()
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.trigger ~= "done" then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_done(name)
    end

    return true, config
end

function GuideUtils.checkGuide_view(name)
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.trigger ~= "view" then return false end
    if config.name ~= name then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_view(name)
    end

    return true, config
end

function GuideUtils.checkGuide_firstView(name)
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.beginning ~= name then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_firstView(name)
    end

    return true, config
end

function GuideUtils.checkGuide_layer(name)
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.trigger ~= "layer" then return false end
    if config.name ~= name then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_layer(name)
    end

    return true, config
end

function GuideUtils.checkGuide_popshow(name)
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.trigger ~= "popshow" then return false end
    if config.name ~= name then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_popshow(name)
    end

    return true, config
end

function GuideUtils.checkGuide_popclose(name)
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.trigger ~= "popclose" then return false end
    if config.name ~= name then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_popclose(name)
    end

    return true, config
end

function GuideUtils.checkGuide_storyover()
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.trigger ~= "storyover" then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_storyover(name)
    end

    return true, config
end

function GuideUtils.checkGuide_newover()
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.trigger ~= "newover" then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_newover(name)
    end

    return true, config
end

function GuideUtils.checkGuide_custom(name)
    if not GuideUtils.ENABLE and GuideUtils.enableTrigger == nil then return end
    local config = GuideUtils.getCurConfig()
    if config == nil then return false end
    if config.trigger ~= "custom" then return false end
    if config.name ~= name then return false end
    local res = GuideUtils.checkLevel(config)
    if res == 0 then return false end
    if res == 2 then
        return GuideUtils.checkGuide_custom(name)
    end

    return true, config
end

-- 检查强制引导等级
function GuideUtils.checkLevel(config)
    if config.level then
        local level = ModelManager:getInstance():getModel("UserModel"):getPlayerLevel()
        if level == config.level then
            -- 等级相同,可以触发
            return 1
        elseif level < config.level then
            -- 等级没到,不可触发
            return 0
        else
            -- 等级过了, 跳过等级段
            for i = GuideUtils.guideIndex, GuideUtils.maxGuideIndex do
                if GuideConfig[i].level and GuideConfig[i].level >= level then
                    GuideUtils.guideIndex = i
                    GuideUtils.guideChange = GuideUtils.guideIndex
                    ViewManager:getInstance():updateGuideIndexLabel()
                    return 2
                end
            end
            GuideUtils.guideIndex = GuideUtils.maxGuideIndex + 1
            GuideUtils.guideChange = GuideUtils.guideIndex
            ViewManager:getInstance():updateGuideIndexLabel()
            return 2
        end
    else
        return config
    end
end

-- 登陆账号之前的引导相关 ==================================
-- 登陆账号之前的引导相关 ==================================
-- 登陆账号之前的引导相关 ==================================

GuideUtils.unloginGuideIndex = 1

function GuideUtils.unloginGuide()
    local step = 0
    if GuideUtils.unloginGuideIndex == 0 then
        -- audioMgr:playMusic("loading", true)

        GuideUtils.unloginInit_server()
        ViewManager:getInstance():switchView("intance.IntanceLoading", {guideStep = 1, callback = function ()
            ApiUtils.playcrab_device_monitor_action("animBegin")
            ViewManager:getInstance():switchView("intance.IntanceMcPlotView", {plotId = 1, callback = function()
                ApiUtils.playcrab_device_monitor_action("animEnd")
                ViewManager:getInstance():switchView("intance.IntanceView", {})
            end})
        end}, false)
    else
        GuideUtils.unloginInit_server()
        step = GuideUtils.unloginGuideIndex
        local guideIndexTab = {1, 2, 3, 4}
        GuideUtils.guideIndex = guideIndexTab[step]
        audioMgr:playMusic("loading", true)
        ViewManager:getInstance():switchView("intance.IntanceLoading", {guideStep = step}, false)
    end  
end

-- 模拟假数据
function GuideUtils.unloginInit_server()
    local serverMgr = ServerManager:getInstance()
    ServerManager.sendMsgEx = function (self, name, act, context, lockview, data, callback, errorCallback, reSend)
        local server = serverMgr:_getServer(name, data)
        server:setCallback(callback)
        server:setErrorCallback(errorCallback)
        local funcName = "on" .. string.upper(string.sub(act, 1, 1)) .. string.sub(act, 2, string.len(act))
        local result
        if act == "atkBeforeStage" then
            if tonumber(context.id) == 7100101 then
                result =  
                {
                    d = {physcal = 120, dontUpdateUser = true}
                }
            elseif tonumber(context.id) == 7100102 then
                result =  
                {
                    d = {physcal = 120, dontUpdateUser = true}
                }
            end
        elseif act == "atkAfterStage" then
            if tonumber(context.id) == 7100101 then
                result =  
                {
                    d = {physcal = 120, dontUpdateUser = true,
                        story = {stages = {["7100101"] = {star = 3, num = 1, atkTime = os.time()}}, stId = 7100101, stageColls = {["71001"] = {num = 3}}},
                        starNum = 3,
                        teams = {["106"] = {exp = 0}},
                    },
                    rs = {combatRes = 1, star = 3},
                    rewards = {{{type = "tool", typeId = 301101, num = 2}, {type = "tool", typeId = 301103, num = 2}}},
                }
                SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Index, 4)
            elseif tonumber(context.id) == 7100102 then
                result =  
                {
                    d = {physcal = 120, dontUpdateUser = true,
                        story = {stages = {["7100102"] = {star = 3, num = 1, atkTime = os.time()}}, stId = 7100102, stageColls = {["71001"] = {num = 6}}},
                        starNum = 6,
                        teams = {["106"] = {exp = 0}, ["102"] = {exp = 0}},
                    },
                    rs = {combatRes = 1, star = 3},
                    rewards = {{{type = "tool", typeId = 301102, num = 2}, {type = "tool", typeId = 301104, num = 2}}},
                }
                audioMgr:playSound("shitouren_3")
                audioMgr:playSoundForce("WinBattle")
                ApiUtils.playcrab_device_monitor_action("1-2win")
                ViewManager:getInstance():enableTalking(37, {}, function ()
                    SystemUtils.saveGlobalLocalData(GameStatic.deviceGuideKey_Enable, 0)
                    GuideUtils.unloginGuideEnable = false
                    ApiUtils.playcrab_device_monitor_action("zhanling")
                    ViewManager:getInstance():doGuideZhanling({delay = 0})
                end)
                return
            end
        end
        server[funcName](server, result, 0)
    end 
end

function GuideUtils.unloginInitByStep(step)
    local modelMgr = ModelManager:getInstance()
    local intanceModel = modelMgr:getModel("IntanceModel")
    local intanceEliteModel = modelMgr:getModel("IntanceEliteModel")
    local userModel = modelMgr:getModel("UserModel")
    local formationModel = modelMgr:getModel("FormationModel")
    local teamModel = modelMgr:getModel("TeamModel")
    local heroModel = modelMgr:getModel("HeroModel")
    
    if step == 1 then
        intanceModel:setData(nil)
    elseif step == 2 then
        intanceModel:setData({spBranch = {["700001"] = 1}})
    elseif step == 3 then
        intanceModel:setData({spBranch = {["700001"] = 1, ["700002"] = 1}})
    elseif step >= 4 then
        intanceModel:setData({spBranch = {["700001"] = 1, ["700002"] = 1}, stages = {["7100101"] = {star = 3, num = 1, atkTime = os.time()}}, stId = 7100101, stageColls = {["71001"] = {num = 3}}})
    end
    intanceEliteModel:setData(nil)

    local data = {}
    data.lvl = 1
    data.accelerate = 1
    data.quit = 0
    data.physcal = 120
    data.skillOpen = {["1"] = 1, ["2"] = 0, ["3"] = 1, ["4"] = 0, ["5"] = 0}
    userModel._data = data
    local teams = {}
    teams["106"] = {el1 = 1, el2 = 1, el3 = 1, el4 = 1,
                es1 = 1, es2 = 1, es3 = 1, es4 = 1,
                exp = 0, level = 30, pScore = 0, score = 470, 
                sl1 = 1, sl2 = -1, sl3 = -1, sl4 = -1,
                se1 = 1, se2 = 1, se3 = 1, se4 = 1,
                smallStar = 0, stage = 1, star = 1, status = 0,
        }
    teams["102"] = {el1 = 1, el2 = 1, el3 = 1, el4 = 1,
                es1 = 1, es2 = 1, es3 = 1, es4 = 1,
                exp = 0, level = 30, pScore = 0, score = 470, 
                sl1 = 1, sl2 = -1, sl3 = -1, sl4 = -1,
                se1 = 1, se2 = 1, se3 = 1, se4 = 1,
                smallStar = 0, stage = 1, star = 1, status = 0,
        }
    teamModel:setData(teams)
    local hero = {["60102"] = {m1 = 62001, m2 = 62031, m3 = 62011, m4 = 62121,
                            sl1 = 1, sl2 = 1, sl3 = 1, sl4 = 1,
                            se1 = 0, se2 = 0, se3 = 0, se4 = 0, star = 1, status = 0}}
    heroModel:setData(hero)
    local formations = {{heroId = 60102, score = 989, team1 = 106, team2 = 102, team3 = 0, team4 = 0, team5 = 0, team6 = 0, team7 = 0, team8 = 0,
                            g1 = 7, g2 = 6, g3 = 0, g4 = 0, g5 = 0, g6 = 0, g7 = 0, g8 = 0}}
    formationModel:setFormationData(formations) 
end

-- ============================

function GuideUtils.dtor()
    GuideConfig = nil
    GuideUtils = nil
    triggerConfig = nil
    triggerPoint = nil
end

return GuideUtils