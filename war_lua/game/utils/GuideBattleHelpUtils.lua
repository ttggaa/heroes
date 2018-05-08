--[[
    Filename:    GuideBattleHelpUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-01-18 15:10:40
    Description: File description
--]]

local vmgr = ViewManager:getInstance()
local ScheduleMgr = ScheduleMgr
local SystemUtils = SystemUtils

local GuideBattleHelpUtils = {} 

local GuideBattleHelpConfig = require "game.config.guide.GuideBattleHelpConfig"

GuideBattleHelpUtils.ENABLE = GuideBattleHelpConfig.ENABLE
GuideBattleHelpUtils.DEBUG = GuideBattleHelpConfig.DEBUG

GuideBattleHelpUtils.LOCK = false

GuideBattleHelpUtils.guideKey = ""
GuideBattleHelpUtils.guideTime = -2
GuideBattleHelpUtils.guideSubIndex = 1
GuideBattleHelpUtils.guideSubMaxIndex = 1

function GuideBattleHelpUtils.checkGuideStateByKey(inKey)
    if not GuideBattleHelpUtils.ENABLE then GuideBattleHelpUtils.guideKey = "" return false end
    local config = GuideBattleHelpConfig[inKey]
    if config == nil then GuideBattleHelpUtils.guideKey = ""  return false end
    GuideBattleHelpUtils.guideKey = inKey
    return true, config
end

--[[
--! @function checkGuideState
--! @desc 检查是否有需要执行的新手战斗引导
--! @param inType int 副本类型
--! @param inMapId int 副本地图id
--! @return 
--]]
function GuideBattleHelpUtils.checkGuideState(inType, inMapId)
    if inMapId == nil then 
        inMapId = ""
    end
    GuideBattleHelpUtils.guideKey = ""
    GuideBattleHelpUtils.guideTime = -2
    GuideBattleHelpUtils.guideSubIndex = 1
    if SystemUtils.loadAccountLocalData("GBHU_" .. inType .. "_" .. inMapId) == nil then
        return GuideBattleHelpUtils.checkGuideStateByKey(inType .. "_" .. inMapId)
    else
        return false
    end
end

function GuideBattleHelpUtils.guideRunOver(inType, inMapId)
    SystemUtils.saveAccountLocalData("GBHU_" .. inType .. "_" .. inMapId, 1)
end
--[[
--! @function checkGuideTime
--! @desc 检查当前时间是否有引导
--! @param inTime int 当前战斗时间
--! @return type int 检查类型0无，1 点击，2点击点，3快速释放技能
--! @return config table 战斗引导信息
--]]
function GuideBattleHelpUtils.checkGuideTime(inTime)
    if GuideBattleHelpUtils.guideTime >= inTime then return 0 end
	local state, timeConfig = GuideBattleHelpUtils.checkGuideStateByKey(GuideBattleHelpUtils.guideKey)
	if state == false or timeConfig == nil or timeConfig[inTime] == nil then return 0 end
    GuideBattleHelpUtils.guideTime = inTime
    GuideBattleHelpUtils.guideSubIndex = 1
    GuideBattleHelpUtils.guideSubMaxIndex = #timeConfig[inTime]
	return state, timeConfig[inTime]
end

function GuideBattleHelpUtils.doGuideEvent(inTimeConfig, inView, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    local config = inTimeConfig[GuideBattleHelpUtils.guideSubIndex]
    local nextGuideFun = function()
        GuideBattleHelpUtils.doNextGuide(config, inView, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
        if config.unLock then
            GuideBattleHelpUtils.unLockView(inView)
        end
    end
    if config.event == nil then
        nextGuideFun()
    else
        local functionName = "event_"..config.event
        if GuideBattleHelpUtils[functionName] then
            GuideBattleHelpUtils[functionName](config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
        else
            nextGuideFun()
        end
    end
end

function GuideBattleHelpUtils.event_click(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    vmgr:doGuideBattleClick(config, inView, function() 
        local _key = GuideBattleHelpUtils.guideKey .. "_" .. GuideBattleHelpUtils.guideTime .. "_" ..GuideBattleHelpUtils.guideSubIndex
        if GuideBattleHelpUtils.guideKey == "1_7100101" then
            ApiUtils.playcrab_device_monitor_action(_key)
        else
            local uploadIndex = SystemUtils.loadAccountLocalData(_key)
            if uploadIndex == nil or uploadIndex == "" then
                SystemUtils.saveAccountLocalData(_key, 1)
                ApiUtils.playcrab_monitor_action(_key)
            end
        end
        nextGuideFun()
        vmgr:guideUnlock()
    end)
end

function GuideBattleHelpUtils.event_point(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    vmgr:doGuideBattlePoint(config, inView, inTransformCallback, function() 
        local _key = GuideBattleHelpUtils.guideKey .. "_" .. GuideBattleHelpUtils.guideTime .. "_" ..GuideBattleHelpUtils.guideSubIndex
        if GuideBattleHelpUtils.guideKey == "1_7100101" then
            ApiUtils.playcrab_device_monitor_action(_key)
        else
            local uploadIndex = SystemUtils.loadAccountLocalData(_key)
            if uploadIndex == nil or uploadIndex == "" then
                SystemUtils.saveAccountLocalData(_key, 1)
                ApiUtils.playcrab_monitor_action(_key)
            end
        end
        nextGuideFun()
        vmgr:guideUnlock()
    end)
end

function GuideBattleHelpUtils.event_manatip(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    vmgr:doGuideBattleManaTip(config, function() 
        nextGuideFun()
    end)
end

function GuideBattleHelpUtils.event_story(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    vmgr:doGuideBattleStory(config, function() 
        nextGuideFun()
    end)
end

function GuideBattleHelpUtils.event_jump(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    inView:onjumpBtnClicked()
    nextGuideFun()
end

function GuideBattleHelpUtils.event_quite(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    inView:onquiteBtnClicked()
    nextGuideFun()
end

function GuideBattleHelpUtils.event_quick(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    if inCallback ~= nil then 
        inCallback(1, config)
    end
    nextGuideFun()
end

function GuideBattleHelpUtils.event_initcd(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    if inCallback ~= nil then 
        inCallback(2, config)
    end
    nextGuideFun()
end

function GuideBattleHelpUtils.event_initmana(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    if inCallback ~= nil then 
        inCallback(3, config)
    end
    nextGuideFun()
end

function GuideBattleHelpUtils.event_action(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    if inCallback ~= nil then 
        inCallback(4, config, function ()
            nextGuideFun()
        end)
    end 
end

function GuideBattleHelpUtils.event_pause(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    if inPauseCallback ~= nil  then 
        inPauseCallback(config.pauseTime)
    end
    nextGuideFun()
end

function GuideBattleHelpUtils.event_resume(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    if inResumeCallback ~= nil  then 
        inResumeCallback(config.pauseTime)
    end
    nextGuideFun()
end

function GuideBattleHelpUtils.event_camera(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    inView:screenToPos(config.pt.x, config.pt.y, config.pt.anim, function ()
        nextGuideFun()
    end)
end

function GuideBattleHelpUtils.event_lockSkill(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    inView:onLockSkill()
    nextGuideFun()
end

function GuideBattleHelpUtils.event_unlockSkill(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    inView:onUnlockSkill()
    nextGuideFun()
end

function GuideBattleHelpUtils.event_senglv(config, inView, nextGuideFun, inTransformCallback, inPauseCallback, inResumeCallback, inCallback)
    inView:onSengLvEff(function ()
        nextGuideFun()
    end)
end

function GuideBattleHelpUtils.doNextGuide(config, inView, inTransformCallback, inPauseCallback, inResumeCallback, inQuickCallback)
    vmgr:doFinishGuide(config) 

    if GuideBattleHelpUtils.guideSubIndex + 1 > GuideBattleHelpUtils.guideSubMaxIndex then 
        return 
    end
    GuideBattleHelpUtils.guideSubIndex = GuideBattleHelpUtils.guideSubIndex + 1

    local state, timeConfigs = GuideBattleHelpUtils.checkGuideStateByKey(GuideBattleHelpUtils.guideKey)
    if state == false or 
        timeConfigs[GuideBattleHelpUtils.guideTime] == nil or
        timeConfigs[GuideBattleHelpUtils.guideTime][GuideBattleHelpUtils.guideSubIndex] == nil  then
        return false        
    end
    GuideBattleHelpUtils.lockView(inView)
    ScheduleMgr:delayCall(0, self, function ()
        GuideBattleHelpUtils.doGuideEvent(timeConfigs[GuideBattleHelpUtils.guideTime], inView, inTransformCallback, inPauseCallback, inResumeCallback, inQuickCallback)
    end)
end


--[[
--! @function lockView
--! @desc 锁定整个战斗过程
--]]

function GuideBattleHelpUtils.lockView(view)
    GuideBattleHelpUtils.LOCK = true
    view:lockSkillIcon()
end

--[[
--! @function unLockView
--! @desc 解除锁定
--]]
function GuideBattleHelpUtils.unLockView(view)
    GuideBattleHelpUtils.LOCK = false
    view:unlockSkillIcon()
end

function GuideBattleHelpUtils.dtor()
    GuideBattleHelpConfig = nil
    GuideBattleHelpUtils = nil
    ScheduleMgr = nil
    SystemUtils = nil
    vmgr = nil
end

return GuideBattleHelpUtils