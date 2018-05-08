--[[
    Filename:    BattleScene.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-29 12:23:04
    Description: File description
--]]
local BC = BC
local pc = pc
local cc = _G.cc
local os = _G.os
local math = math
local ceil = math.ceil
local pairs = pairs
local next = next
local tab = tab
local tonumber = tonumber
local tostring = tostring
local table = table
local mcMgr = mcMgr
local delayCall = BC.DelayCall.dc

local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState
local gettime = socket.gettime

local GBHU = GuideBattleHelpUtils
local viewMgr = nil
if ViewManager then
    viewMgr = ViewManager:getInstance()
end

local EEffFlyType = BC.EEffFlyType
-- 战斗场景
local BattleScene = class("BattleScene")

local logic
local objLayer

-- 一倍速 两倍速 处理方案
-- 1. fps30 2倍速 逻辑帧跑两遍
-- 2. fps60 1倍速 两帧执行一回
local GAME_SPEED_TYPE = 1
if GameStatic and GameStatic.BattleFpsMode and type(GameStatic.BattleFpsMode) == "number" then
    GAME_SPEED_TYPE = GameStatic.BattleFpsMode
end

-- 战斗是否进行
local ENABLE_BATTLE_BEGIN = true
-- 是否矫正屏幕(不出界)
local ENABLE_ADJUST_MAP = true
-- 是否限制缩放边界值(仅针对windows鼠标滚轮)
local ENABLE_ADJUST_MAP_SCALE = true

local floor = math.floor

local tickUpdate = BC.tickUpdate
local displayTickUpdate = BC.displayTickUpdate

function BattleScene:ctor(battleInfo)    
    if GBHU then GBHU.LOCK = false end -- 先解锁, 以免卡住
    self._battleInfo = battleInfo
    print("r1r2", self._battleInfo.r1, self._battleInfo.r2)
    if self._battleInfo.r1 and self._battleInfo.r1 ~= "" then
        BC.ranSeed(tonumber(self._battleInfo.r1))
        BC.ranSeed2(tonumber(self._battleInfo.r1))
    else
        BC.ranSeed(19870515)
        BC.ranSeed2(19870515)
    end

    -- 图鉴附加属性
    BC.PokedexAttr = {}
    BC.PokedexAttr[1] = self._battleInfo.playerInfo.pokedex
    BC.PokedexAttr[2] = self._battleInfo.enemyInfo.pokedex
    require "game.view.battle.logic.BattleFormationPos"
    require "game.view.battle.logic.BattleSoldierCreator"
    
    if cc.Layer then
        self._rootLayer = cc.Layer:create()
        self._rootLayer:setVisible(false)
        self._rootLayer:setName("battleScene")
    end

    self.enableOutEnemy = true
end

local weatherOpen = false
function BattleScene:getView()
    return self._rootLayer
end

-- 不同的战斗的额外规则
local _BattleUtils = BattleUtils
local ruleTabs = 
{
    [_BattleUtils.BATTLE_TYPE_Fuben] = "BattleRule_PVE1",
    [_BattleUtils.BATTLE_TYPE_Arena] = "BattleRule_PVP1",
    [_BattleUtils.BATTLE_TYPE_AiRenMuWu] = "BattleRule_AiRenMuWu",
    [_BattleUtils.BATTLE_TYPE_Zombie] = "BattleRule_Zombie",
    [_BattleUtils.BATTLE_TYPE_Siege] = "BattleRule_Siege",
    [_BattleUtils.BATTLE_TYPE_BOSS_DuLong] = "BattleRule_BOSS_DuLong",
    [_BattleUtils.BATTLE_TYPE_BOSS_XnLong] = "BattleRule_BOSS_XnLong",
    [_BattleUtils.BATTLE_TYPE_BOSS_SjLong] = "BattleRule_BOSS_SjLong",
    [_BattleUtils.BATTLE_TYPE_Crusade] = "BattleRule_PVP2",
    [_BattleUtils.BATTLE_TYPE_Guide] = "BattleRule_Guide",
    [_BattleUtils.BATTLE_TYPE_GuildPVE] = "BattleRule_PVE1",
    [_BattleUtils.BATTLE_TYPE_GuildPVP] = "BattleRule_PVP1",
    [_BattleUtils.BATTLE_TYPE_Biography] = "BattleRule_PVE1",
    [_BattleUtils.BATTLE_TYPE_League] = "BattleRule_PVP2",
    [_BattleUtils.BATTLE_TYPE_MF] = "BattleRule_PVP2",
    [_BattleUtils.BATTLE_TYPE_CloudCity] = "BattleRule_CloudCity",
    [_BattleUtils.BATTLE_TYPE_CCSiege] = "BattleRule_CCSiege",
    [_BattleUtils.BATTLE_TYPE_GVG] = "BattleRule_GVG",
    [_BattleUtils.BATTLE_TYPE_GVGSiege] = "BattleRule_GVGSiege",
    [_BattleUtils.BATTLE_TYPE_Training] = "BattleRule_PVE1",
    [_BattleUtils.BATTLE_TYPE_Adventure] = "BattleRule_PVE1",
    [_BattleUtils.BATTLE_TYPE_HeroDuel] = "BattleRule_PVP1",
    [_BattleUtils.BATTLE_TYPE_GBOSS_1] = "BattleRule_GBOSS_1",
    [_BattleUtils.BATTLE_TYPE_GBOSS_2] = "BattleRule_GBOSS_2",
    [_BattleUtils.BATTLE_TYPE_GBOSS_3] = "BattleRule_GBOSS_3",
    [_BattleUtils.BATTLE_TYPE_GodWar] = "BattleRule_PVP1",
    [_BattleUtils.BATTLE_TYPE_Elemental_1] = "BattleRule_Elemental_1",
    [_BattleUtils.BATTLE_TYPE_Elemental_2] = "BattleRule_Elemental_2",
    [_BattleUtils.BATTLE_TYPE_Elemental_3] = "BattleRule_Elemental_3",
    [_BattleUtils.BATTLE_TYPE_Elemental_4] = "BattleRule_Elemental_4",
    [_BattleUtils.BATTLE_TYPE_Elemental_5] = "BattleRule_Elemental_5",
    [_BattleUtils.BATTLE_TYPE_Siege_Atk] = "BattleRule_Siege_Atk",
    [_BattleUtils.BATTLE_TYPE_Siege_Def] = "BattleRule_Siege_Def",
    [_BattleUtils.BATTLE_TYPE_Siege_Atk_WE] = "BattleRule_Siege_Atk",
    [_BattleUtils.BATTLE_TYPE_Siege_Def_WE] = "BattleRule_Siege_Def",
    [_BattleUtils.BATTLE_TYPE_ServerArena]  = "BattleRule_PVP1",
    [_BattleUtils.BATTLE_TYPE_ServerArenaFuben] = "BattleRule_PVE1",
    [_BattleUtils.BATTLE_TYPE_ClimbTower] = "BattleRule_PVE1",
    [_BattleUtils.BATTLE_TYPE_GuildFAM] = "BattleRule_PVP2",
}
local _updateBeginTick = nil
local _updateBeginTime = 0
function BattleScene:initScene()

    BC.setBattleType(self._battleInfo.mode, self._battleInfo.siegeReverse)--, self._battleInfo.scaleMin, self._battleInfo.scaleMax)
    if not BC.fastBattle then
        -- 场景层
        self._sceneLayer = cc.Layer:create()
        self._sceneLayer:setAnchorPoint(0.5, 0.5)
        self._rootLayer:addChild(self._sceneLayer)

        self._sceneLayer:setRotation3D(cc.Vertex3F(-BC.BATTLE_3D_ANGLE, 0, 0))

        -- 地图层
        self._mapLayer = require("game.view.battle.display.BattleMapLayer").new()
        self._sceneLayer:addChild(self._mapLayer:getView())
        self._mapLayer:initLayer(self._battleInfo.mapId, self._battleInfo.siegeId, self._battleInfo.mode)
        self._mapFar = self._mapLayer:getFar()
        self._mapNear = self._mapLayer:getNear()

        -- 元件层
        self._objectLayer = require("game.view.battle.display.BattleObjectLayer").new(self._mapLayer:getObjLayer())
        self._objectLayer:initLayer(self._sceneLayer, self._uiLayer)
        BC.objLayer = self._objectLayer
        objLayer = BC.objLayer

        -- 天气层
        self._weatherLayer = require("game.view.battle.display.BattleWeatherLayer").new()
        self._objectLayer:getView():addChild(self._weatherLayer:getView())
        if self._battleInfo.weather then
            weatherOpen = self._weatherLayer:changeWeather(self._battleInfo.weather)
        else
            weatherOpen = self._weatherLayer:initLayer(self._battleInfo.mapId)
        end

        self:initEvent()

        
        self._mapNear:setPosition(0, 640 - BC.BATTLE_BG_HEIGHT)
    else
        self._objectLayer = require("game.view.battle.display.BattleObjectLayer_null").new()
        BC.objLayer = self._objectLayer
        objLayer = BC.objLayer
    end

    -- 战斗逻辑
    logic = require("game.view.battle.logic.BattlePlayerLogic").new(self)

    -- 战斗类型不同 规则不同
    local str = "game.view.battle.rule."..ruleTabs[BC.BATTLE_TYPE]
    if self._battleInfo.battleId == 7100102 then
        -- 第一场攻城战 单独处理
        str = "game.view.battle.rule.BattleRule_GuideSiege"
    end
    self.__rule = require(str)
    if self.__rule then
        self.__rule.init()
    end
    
    self:initBattleUI()

    -- 前景层
    self._frontLayer = require("game.view.battle.display.BattleFrontLayer").new()
    self._uiLayer:addChild(self._frontLayer:getView())
    self._frontLayer:initLayer()

    -- 停止GC, 手动处理
    -- collectgarbage("stop")
    logic:initLogic(self._battleInfo)

    -- 血条下面的头像
    self:initHeadUI(logic:getOriginalTeamId())
    if BC.fastBattle then
        BC.jump = true
        self._topLayer:setVisible(true)
        self:initSkipLayer()
    end

    if BattleUtils.XBW_SKILL_DEBUG then logic:initTeamDebugLabel(self._rootLayer) end
    self:countHP()

    -- 控制循环间隔
    self._loopIndex = 1
    self._maxLoopIndex = 2
    -- 主循环
    if GAME_SPEED_TYPE == 1 then
        self._updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
            local ret = trycall("BattleScene.update", self.update, self, dt)
            if not ret then
                -- 战斗update报错
                ScheduleMgr:unregSchedule(self._updateId)
                self._BattleView:clearLock()
                BC.jump = false
                local dialog = viewMgr:showDialog("global.GlobalOkDialog", {desc = "战场遭到地狱势力入侵，需要马上撤离", button = "确定", 
                callback = function ()
                    self._BattleView:errorClose()
                end}, true)
                showGlobalErrorCode(dialog:getUI("bg"), 6665002)
            end
            if weatherOpen then
                _updateBeginTime = _updateBeginTime + 1
                if not _updateBeginTick then
                    _updateBeginTick = gettime()
                end
            end
        end)
    else
        self._updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
            if self._loopIndex == 1 then
                local ret = trycall("BattleScene.update", self.update, self, dt)
                if not ret then
                    -- 战斗update报错
                    ScheduleMgr:unregSchedule(self._updateId)
                    self._BattleView:clearLock()
                    BC.jump = false
                    local dialog = viewMgr:showDialog("global.GlobalOkDialog", {desc = "战场遭到地狱势力入侵，需要马上撤离", button = "确定", 
                    callback = function ()
                        self._BattleView:errorClose()
                    end}, true)
                    showGlobalErrorCode(dialog:getUI("bg"), 6665002)
                end
                if weatherOpen then
                    _updateBeginTime = _updateBeginTime + 1
                    if not _updateBeginTick then
                        _updateBeginTick = gettime()
                    end
                end
            end
            self._loopIndex = self._loopIndex + 1
            if self._loopIndex > self._maxLoopIndex then
                self._loopIndex = 1
            end
        end)
    end

    -- 星星显示
    if self._BattleView:getUI("uiLayer.topLayer.timeBg"):isVisible() then
        self._star = 3
    end
    self._star1 = self._BattleView:getUI("uiLayer.topLayer.timeBg.star1")
    self._star2 = self._BattleView:getUI("uiLayer.topLayer.timeBg.star2")
    self._star3 = self._BattleView:getUI("uiLayer.topLayer.timeBg.star3")

    -- 屏外敌人显示
    self._outEnemy = {}

    -- 宝物技能图标倒计时
    self._treasureIcon = {{}, {}}
    self._treasureIconDirty = {false, false}

    -- 法术刻印被动技能图标
    self._skillBookPassiveIcon = {{}, {}}

    -- 引导帮助战斗
    self._guideHelpState = GBHU.checkGuideState(self._battleInfo.mode, self._battleInfo.battleId)
    if self._guideHelpState == true then 
        self._BattleView:initBattleGuide()
        GBHU.lockView(self._BattleView)
        if self._battleInfo.battleId == GUIDE_INTANCE_CLOSE_AUTO_BATTLE 
            and logic.setAutoBattleForRightCamp ~= nil then 
            logic:setAutoBattleForRightCamp(false)
        end

        self._guildeHelpMask = ccui.Layout:create()
        self._guildeHelpMask:setBackGroundColorOpacity(0)
        self._guildeHelpMask:setBackGroundColorType(1)
        self._guildeHelpMask:setBackGroundColor(cc.c3b(0,0,0))
        self._guildeHelpMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        self._guildeHelpMask:setName("guildeHelpMask")
        self._BattleView:addChild(self._guildeHelpMask)
        registerTouchEvent(self._guildeHelpMask, 
            function(sender, x, y) 
                logic:guidePlayerSkillDown(self:getSceneLayerPoint(cc.p(x , y)))
            end,
            function(sender, x, y)
                logic:playerSkillMove(self:getSceneLayerPoint(cc.p(x, y)))
            end,
            function(sender, x, y)
                logic:playerSkillUp(self:getSceneLayerPoint(cc.p(x, y)))
                self._BattleView:enableSkillIcon()
            end,
            function(sender, x, y)

            end
            )
        self._guildeHelpMask:setTouchEnabled(false)
        -- 战前快速执行引导帮助
        self:guildHelp(-1)
    end
    if GAME_SPEED_TYPE == 1 then
        cc.Director:getInstance():setAnimationInterval(GameStatic.battleAnimInterval1)
    else
        cc.Director:getInstance():setAnimationInterval(GameStatic.battleAnimInterval2)
    end

    objLayer:onHUDTypeChange()
end

function BattleScene:onTop()
    if GAME_SPEED_TYPE == 1 then
        cc.Director:getInstance():setAnimationInterval(GameStatic.battleAnimInterval1)
    else
        cc.Director:getInstance():setAnimationInterval(GameStatic.battleAnimInterval2)
    end
end

function BattleScene:onHide()
    cc.Director:getInstance():setAnimationInterval(GameStatic.normalAnimInterval)
end


function BattleScene:replay()
    if BC.fastBattle then
        BC.jump = true
        BATTLE_PROC = true
    end
    if self._skipLayer then
        self._skipLayer:removeFromParent()
        self._skipBg:removeFromParent()
        self._skipLayer = nil
    end
    if BC.fastBattle then
        self:initSkipLayer()
    end
    BattleUtils.playBattleMusic(self._battleInfo.mode, self._battleInfo.isElite)
    self._isWin = nil
    self._replay = true
    self:disableHpWarning()
    -- 移除挡板
    if self._overMask then
        self._overMask:removeFromParent()
        self._overMask = nil
    end

    print("r1r2", self._battleInfo.r1, self._battleInfo.r2)
    if self._battleInfo.r1 and self._battleInfo.r1 ~= "" then
        BC.ranSeed(tonumber(self._battleInfo.r1))
        BC.ranSeed2(tonumber(self._battleInfo.r1))
    else
        BC.ranSeed(19870515)
        BC.ranSeed2(19870515)
    end
    BC.tickInit()
    self:clearTreasureSkillIcon()
    if not BC.fastBattle then
        self._mapLayer:siegeReset()
    end

    if self._shadowValue1 then self._shadowValue1 = 100 end
    if self._shadowValue2 then self._shadowValue2 = 100 end
    if self._destValue1 then self._destValue1 = 100 end
    if self._destValue2 then self._destValue2 = 100 end
    if self._hpUpdateTick then self._hpUpdateTick = 0 end

    if not BC.fastBattle then
        self._weatherLayer:closeWeather()
        self._weatherLayer:getView():retain()
        self._objectLayer:replay()
        self._objectLayer:getView():addChild(self._weatherLayer:getView())
        self._weatherLayer:getView():release()

        self:initEvent()
    end
    logic:replay()
    self:countHP()
    self:resetHeadUI()
    self._timeLabel:setString(formatTime(self.CountTime))
    logic:resetSkillIcon()
    self:play()
end

-- 复盘
function BattleScene:procBattle()
    self._objectLayer = require("game.view.battle.display.BattleObjectLayer_null").new()
    audioMgr = require("base.audio.AudioManager_null")
    BC.objLayer = self._objectLayer

    BC.setBattleType(self._battleInfo.mode, self._battleInfo.siegeReverse)

    -- 战斗逻辑
    logic = require("game.view.battle.logic.BattlePlayerLogic").new(self)

    self.__rule = require("game.view.battle.rule."..ruleTabs[BC.BATTLE_TYPE])
    if self.__rule then
        self.__rule.init()
    end
    BC.jump = true 
    logic:initLogic(self._battleInfo, true)

    self:initBattleSkill(nil, true)
    self:battleBegin()
    self._jump = true
    

    if BattleUtils.PROC_AUTO_SKILL[self._battleInfo.mode] then
        logic:setSkillAuto(true)
    end
        
    local over = false
    local resString = ""
    local resData
    local res
    BattleScene.onBattleEnd = function (self, leftData, rightData, dieList, dieCount, isTimeUp, isSurrender, isSkip, hero1, hero2, skillList, ex)
        if setMultipleTouchDisabled then setMultipleTouchDisabled() end
        if setEventUpDelayEnabled then setEventUpDelayEnabled() end
        -- ScheduleMgr:unregSchedule(self._updateId)
        local time = floor(logic.battleTime)
        local value1, value2, value3, value4 = logic:getCurHP()
        local v1, v2, v3, v4 = logic:getSummonHP()
        local hp = {value1+v1, value2+v2, value3+v3, value4+v4}
        local hpex = {value1, value2, value3, value4}
        resData = 
        {
            hp = hp, 
            hpex = hpex, 
            win = self._isWin, 
            isTimeUp = isTimeUp, 
            time = time, 
            r1 = self._battleInfo.r1, 
            r2 = self._battleInfo.r2, 
            dieList = dieList, 
            battleTime = floor(time * 1000), 
            heroID = hero1.ID,
            totalDamage1 = ex.totalDamage1, 
            totalDamage2 = ex.totalDamage2,
            totalRealDamage1 = ex.totalRealDamage1,
            totalRealDamage2 = ex.totalRealDamage2,
            dieCount1 = ex.dieCount1,
            dieCount2 = ex.dieCount2,
        }
        resData.teamInfo = self:getTeamInfo(leftData, rightData)
        res = {hp = hp, hpex = hpex, leftData=leftData, rightData=rightData, win=self._isWin, time=floor(time), dieList = dieList, dieCount = dieCount, 
        isTimeUp = isTimeUp, isSurrender = isSurrender, isSkip = isSkip, hero1 = hero1.heroD, hero2 = hero2.heroD, skillList = cjson.encode(skillList)}
        self:onBattleEndEx(res)
        if res.exInfo then
            for k, v in pairs(res.exInfo) do
                resData[k] = v
            end
        end

        resString = value1 .. " " .. value2 .. " " .. value3 .. " " .. value4 .. " " .. v1 .. " " .. v2 .. " " .. v3 .. " " .. v4 .. " " .. time
        over = true
    end
    local update1 = tickUpdate
    local update2 = logic.update
    while true do
        if over then
            break
        end
        update1()
        update2(logic)
    end
    logic:clear()
    return resData, resString, res
end

function BattleScene:lock()
    self._lockMask = ccui.Layout:create()
    self._lockMask:setBackGroundColorOpacity(0)
    self._lockMask:setBackGroundColorType(1)
    self._lockMask:setBackGroundColor(cc.c3b(0,0,0))
    self._lockMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._lockMask:setTouchEnabled(true)
    self._rootLayer:getParent():addChild(self._lockMask)
end

function BattleScene:unlock()
    if self._lockMask then
        self._lockMask:removeFromParent()
        self._lockMask = nil
    end
end

-- 有一些需要在clear前一帧执行的
function BattleScene:beforeClear()
    if self._objectLayer then
        self._objectLayer:beforeClear()
    end
end

function BattleScene:clear()

    collectgarbage("collect")
    -- collectgarbage("restart")
    self._callback = nil
    ScheduleMgr:unregSchedule(self._updateId)
    if self._delayInitId then
        ScheduleMgr:unregSchedule(self._delayInitId)
        self._delayInitId = nil 
    end
    if self._delaybeginId then
        ScheduleMgr:unregSchedule(self._delaybeginId)
        self._delaybeginId = nil 
    end
    ScheduleMgr:cleanMyselfTicker(self)

    if self._sceneLayer then
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        dispatcher:removeEventListenersForTarget(self._sceneLayer, true)
    end
    if logic then
        logic:clear()
        delete(logic)
        logic = nil
    end
    BC.logic = nil

    if self._objectLayer then
        self._objectLayer:destroy()
        delete(self._objectLayer)
        self._objectLayer = nil
    end
    if self._mapLayer then
        self._mapLayer:clear()
        delete(self._mapLayer)
        self._mapLayer = nil
    end
    if self._frontLayer then
        self._frontLayer:clear()
        delete(self._frontLayer)
        self._frontLayer = nil
    end
    if self._weatherLayer then
        self._weatherLayer:clear()
        delete(self._weatherLayer)
        self._weatherLayer = nil
    end
    self._sceneLayer = nil
    self._manaLabel = nil

    self._rootLayer:removeAllChildren()
    self._rootLayer = nil
end
-- 战斗开始
function BattleScene:play()    
    if BC.fastBattle then
        self:initBattleSkill(nil, true)
        self:battleBegin()

        logic:setSkillAuto(true)
        return
    end
    BC.BATTLE_SPEED = 1.0
    self._touchScale = BC.SCENE_SCALE_INIT
    self._touchMoveX = 0
    self._touchMoveY = 0

    self._touche1Down = false
    self._touche2Down = false
    self._touche1X = 0
    self._touche1Y = 0
    self._touche2X = 0
    self._touche2Y = 0

    self._skillDownTouchID = -1
    self._totemDownTouchID = -1
    self._skillX = 0
    self._skillY = 0

    if self._warpFrame then
        self:playEx()
        self:jumpBattleBeginAnim()
        self:battleBeginAnimCancel()
        self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5, false)
        self._frontLayer:getView():setVisible(false)
        self:commonRealBattleBegin() 
    else
        if not self._battleInfo.isShare then
            -- 正常战斗
            if self._replay then
                self:playEx()
                self:battleBeginAnim()
                self:jumpBattleBeginAnim()
            else
                self:playEx()
                self:battleBeginAnim()
            end
        else
            self._dontRealBegin = true
            self:playEx()
            self:battleBeginAnim()
            self:jumpBattleBeginAnim()
            self:battleBeginAnimCancel()
            -- 战报
            self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + 200, false)
            self._frontLayer:getView():stopAllActions()
            self._frontLayer:getView():setOpacity(255)
            self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
                self._frontLayer:getView():setVisible(false)
            end)))
            local h = 200
            self._shareAnimId = ScheduleMgr:regSchedule(1, self, function(self)
                h = h + (100 - h) * 0.1
                if h <= 101 then
                    h = 100
                    ScheduleMgr:unregSchedule(self._shareAnimId)
                    self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + h, false)
                    self._dontRealBegin = nil
                    self:commonRealBattleBegin()
                    return
                end
                self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + h, false)
            end)
        end
    end
end
-- 播放战斗开始动画
function BattleScene:battleBeginAnim()
    self._battleBeginAniming = true
    self:battleBeginAnimEx()
end
-- 跳过开场动画
function BattleScene:jumpBattleBeginAnim()
    self:jumpBattleBeginAnimEx()
end
-- 用于取消战斗前屏幕向中间移动的动画
function BattleScene:battleBeginAnimCancel()
    if self._battleBeginAniming then
        self._battleBeginAniming = false
        self:battleBeginAnimCancelEx()
    end
end

function BattleScene:isBattleBeginAniming()
    return self._battleBeginAniming 
end

-- 号角MC
function BattleScene:battleBeginMC(noBeginAnim)
    if not self._replay then
        local bottomLayer = self._bottomLayer
        local bottomLayer2 = self._bottomLayer2
        local topLayer = self._topLayer
        local chatBtn = self._chatBtn
        if self._battleInfo.mode ~= BattleUtils.BATTLE_TYPE_Guide then
            if self._battleInfo.showSkill ~= nil then
                if self._battleInfo.showSkill then
                    bottomLayer:setVisible(true)
                end
            else
                bottomLayer:setVisible(true)
            end
            bottomLayer2:setVisible(true)
        end
        topLayer:setVisible(true)
        chatBtn:setPositionX(chatBtn:getPositionX() - 120)
        local pt1 = cc.p(bottomLayer:getPositionX(), bottomLayer:getPositionY() + 5)
        local pt2 = cc.p(topLayer:getPositionX(), topLayer:getPositionY() - 5)
        local pt4 = cc.p(bottomLayer2:getPositionX(), bottomLayer2:getPositionY() + 5)
        local pt11 = cc.p(bottomLayer:getPositionX(), bottomLayer:getPositionY())
        local pt22 = cc.p(topLayer:getPositionX(), topLayer:getPositionY())
        local pt44 = cc.p(bottomLayer2:getPositionX(), bottomLayer2:getPositionY())
        bottomLayer:setPositionY(bottomLayer:getPositionY() - 200)
        bottomLayer2:setPositionY(bottomLayer2:getPositionY() - 200)
        topLayer:setPositionY(topLayer:getPositionY() + 200)
        bottomLayer:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.2, pt1), 2), cc.MoveTo:create(0.07, pt11)))
        topLayer:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.2, pt2), 2), cc.MoveTo:create(0.07, pt22)))
        bottomLayer2:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.2, pt4), 2), cc.MoveTo:create(0.07, pt44), 
            cc.CallFunc:create(function ()
                chatBtn:runAction(cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(chatBtn:getPositionX() + 120, chatBtn:getPositionY())), 2))
            end)))

        local battleView = self._BattleView
        local pro1 = battleView:getUI("uiLayer.topLayer.pro1")
        local hpbg1 = battleView:getUI("uiLayer.topLayer.hpBg1")
        local hpfg1 = battleView:getUI("uiLayer.topLayer.hpFg1")
        local hpFg1_1 = battleView:getUI("uiLayer.bottomLayer2.hpFg1_1")
        local subPro1 = battleView:getUI("uiLayer.bottomLayer2.hpFg1_1.pro3")
        pro1:setAnchorPoint(1, 0.5)
        pro1:setPositionX(pro1:getPositionX() + pro1:getContentSize().width * 0.5)
        pro1:setScaleX(0)
        pro1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.ScaleTo:create(0.2, 1)))
        hpbg1:setAnchorPoint(0, 0.5)
        hpbg1:setPositionX(hpbg1:getPositionX() + hpbg1:getContentSize().width * 0.5)
        hpbg1:setScaleX(0)
        hpbg1:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.2, 1)))
        hpfg1:setAnchorPoint(0, 0.5)
        hpfg1:setPositionX(hpfg1:getPositionX() + hpfg1:getContentSize().width * 0.5)
        hpfg1:setScaleX(0)
        hpfg1:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.2, 1)))
        hpFg1_1:setAnchorPoint(0, 0.5)
        hpFg1_1:setPositionX(hpFg1_1:getPositionX() - hpFg1_1:getContentSize().width * 0.5 - 400)
        hpFg1_1:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.MoveTo:create(0.2, cc.p(hpFg1_1:getPositionX() + 400, hpFg1_1:getPositionY()))))

        local pro2 = battleView:getUI("uiLayer.topLayer.pro2")
        local hpbg2 = battleView:getUI("uiLayer.topLayer.hpBg2")
        local hpfg2 = battleView:getUI("uiLayer.topLayer.hpFg2")
        local hpFg2_1 = battleView:getUI("uiLayer.topLayer.hpFg2_1")
        pro2:setAnchorPoint(0, 0.5)
        pro2:setPositionX(pro2:getPositionX() - pro2:getContentSize().width * 0.5)
        pro2:setScaleX(0)
        pro2:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.ScaleTo:create(0.2, 1)))
        hpbg2:setAnchorPoint(0, 0.5)
        hpbg2:setPositionX(hpbg2:getPositionX() - hpbg2:getContentSize().width * 0.5)
        hpbg2:setScaleX(0)
        hpbg2:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.2, 1)))
        hpfg2:setAnchorPoint(0, 0.5)
        hpfg2:setPositionX(hpfg2:getPositionX() - hpfg2:getContentSize().width * 0.5)
        hpfg2:setScaleX(0)
        hpfg2:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.2, 1)))
        hpFg2_1:setAnchorPoint(0, 0.5)
        hpFg2_1:setPositionX(hpFg2_1:getPositionX() - hpFg2_1:getContentSize().width * 0.5)
        hpFg2_1:setScaleX(0)
        hpFg2_1:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.2, 1)))
    end
    if not noBeginAnim then
        self:battleBeginMCEx()
        logic:battleBeginMC()
    end

end  

-- 分享站前界面
function BattleScene:initShareUI(callback)
    if self._battleInfo.isShare then
        local BC_reverse = BC.reverse
        local mainCamp = BC_reverse and 2 or 1
        local subCamp = 3 - mainCamp
        local mask = ccui.Layout:create()
        mask:setBackGroundColorOpacity(255)
        mask:setBackGroundColorType(1)
        mask:setBackGroundColor(cc.c3b(0,0,0))
        mask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        mask:setOpacity(180)
        self._BattleView:addChild(mask, 99999)   

        local x1 = MAX_SCREEN_WIDTH * 0.5 - 312
        local x2 = MAX_SCREEN_WIDTH * 0.5 + 312
        local bg1 = cc.Sprite:createWithSpriteFrameName("report_bg_"..mainCamp.."_battle.png")
        local y1 = MAX_SCREEN_HEIGHT - bg1:getContentSize().height * 0.5
        bg1:setPosition(x1, y1)
        mask:addChild(bg1)

        local bg2 = cc.Sprite:createWithSpriteFrameName("report_bg_"..subCamp.."_battle.png")
        local y2 = MAX_SCREEN_HEIGHT - bg2:getContentSize().height * 0.5
        bg2:setPosition(x2, y2)
        mask:addChild(bg2)

        local vs1 = cc.Sprite:createWithSpriteFrameName("report_vs_battle.png")
        vs1:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        vs1:setOpacity(0)
        vs1:setScale(3)
        mask:addChild(vs1)

        local vs2 = cc.Sprite:createWithSpriteFrameName("report_vs_battle.png")
        vs2:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        vs2:setOpacity(0)
        mask:addChild(vs2)

        local vs3 = cc.Sprite:createWithSpriteFrameName("report_vs_battle.png")
        vs3:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        vs3:setBrightness(40)
        vs3:setOpacity(0)
        mask:addChild(vs3)

        -- 动画
        bg1:setPositionX(0 - bg1:getContentSize().width * 0.5)
        bg2:setPositionX(MAX_SCREEN_WIDTH + bg2:getContentSize().width * 0.5)
        bg1:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.01),
            cc.MoveTo:create(0.1, cc.p(x1 + 10, y1)),
            cc.MoveTo:create(0.05, cc.p(x1, y1)),
            cc.DelayTime:create(1.31),
            cc.MoveTo:create(0.15, cc.p(x1 + 20, y1)),
            cc.DelayTime:create(0.03),
            cc.MoveTo:create(0.1, cc.p(0 - bg1:getContentSize().width * 0.5, y1))
        ))
        bg2:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.01),
            cc.MoveTo:create(0.1, cc.p(x2 - 10, y2)),
            cc.MoveTo:create(0.05, cc.p(x2, y2)),
            cc.DelayTime:create(1.31),
            cc.MoveTo:create(0.15, cc.p(x2 - 20, y2)),
            cc.DelayTime:create(0.03),
            cc.MoveTo:create(0.15, cc.p(MAX_SCREEN_WIDTH + bg2:getContentSize().width * 0.5, y2))
        ))
        vs1:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.21),
            cc.FadeTo:create(0.01, 130),
            cc.ScaleTo:create(0.15, 4),
            cc.Spawn:create(cc.ScaleTo:create(0.1, 1.0), cc.FadeIn:create(0.1)),
            cc.DelayTime:create(1.0),
            cc.ScaleTo:create(0.15, 1.3),
            cc.DelayTime:create(0.03),
            cc.Spawn:create(cc.ScaleTo:create(0.1, 0.7), cc.FadeTo:create(0.1, 120)),
            cc.RemoveSelf:create(true)
        ))
        vs2:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.47),
            cc.FadeTo:create(0.01, 100),
            cc.Spawn:create(cc.ScaleTo:create(0.15, 1.5), cc.FadeOut:create(0.15))
        ))
        vs3:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.47),
            cc.FadeTo:create(0.01, 255),
            cc.FadeOut:create(0.3)
        ))

        mask:runAction(cc.Sequence:create(
            cc.DelayTime:create(1.86),
            cc.FadeOut:create(0.3),
            cc.CallFunc:create(function ()
                callback()
            end)
        ))
        -- 内容信息
        function fitInfo(bg, info, camp)
            local name = info.name
            if name == nil then
                name = "无名氏"
            end
            local lv = info.lv
            if lv == nil then
                lv = 1
            end
            local centerX = bg:getContentSize().width * 0.5
            local nameLabel = cc.Label:createWithTTF(name .. " Lv." .. lv, UIUtils.ttfName, 24)
            nameLabel:setAnchorPoint(0.5, 0.5)
            nameLabel:setPosition(centerX, 336)
            bg:addChild(nameLabel)

            local guildName = info.guildName
            if guildName == nil then
                guildName = ""
            end
            local guildLabel = cc.Label:createWithTTF(guildName, UIUtils.ttfName, 22)
            guildLabel:setColor(cc.c3b(0, 255, 255))
            guildLabel:enableShadow(cc.c4b(0, 0, 0, 255))
            guildLabel:setAnchorPoint(0.5, 0.5)
            guildLabel:setPosition(centerX, 304)
            bg:addChild(guildLabel)

            local score = info.curScore
            if score == nil then
                score = 12345000
            end
            local scoreLab = ccui.TextBMFont:create("a"..score, UIUtils.bmfName_zhandouli)
            scoreLab:setScale(0.55)
            scoreLab:setAnchorPoint(0.5, 0)
            scoreLab:setPosition(centerX, 268)
            bg:addChild(scoreLab)

            local dizuo = cc.Sprite:create("asset/uiother/dizuo/heroDizuo.png")
            local subCamp = BC_reverse and 1 or 2
            if camp == subCamp then
                dizuo:setScale(-0.75, 0.75)
            else
                dizuo:setScale(0.75, 0.75)
            end
            dizuo:setPosition(centerX, 458)
            bg:addChild(dizuo)

            local battleHero = logic:getHero(camp)
            local filename
            if battleHero.skin then
                local heroSkinD = tab.heroSkin[battleHero.skin]
                filename = "asset/uiother/shero/"..(heroSkinD["shero"] or battleHero.heroD["shero"])..".png"
            else
                filename = "asset/uiother/shero/"..battleHero.heroD["shero"]..".png"
            end
            local hero = cc.Sprite:create(filename)
            hero:setAnchorPoint(0.5, 0)
            if camp == subCamp then
                hero:setScale(-0.55, 0.55)
            else
                hero:setScale(0.55, 0.55)
            end
            hero:setPosition(centerX, 390)
            bg:addChild(hero)

            -- 兵团头像
            local teams = info.team
            local data, quality, x, y, a, b
            for i = 1, #teams do
                data = teams[i]
                local quality = BattleUtils.TEAM_QUALITY[data.stage]
                local icon = IconUtils:createTeamIconById({teamData = {id = data.id, star = data.star, level = data.level, ast = data.jx and 3 or 0},
                sysTeamData = tab.team[data.id], quality = quality[1], quaAddition = quality[2], eventStyle = 0})        
                icon:setScale(0.6)
                a, b = math.modf((i - 1) / 4) 
                x = 26 + b * 71 * 4
                y = 178 - a * 71
                icon:setPosition(x, y)
                bg:addChild(icon)
            end
        end
        if BC_reverse then
            fitInfo(bg2, self._battleInfo.playerInfo, 1)
            fitInfo(bg1, self._battleInfo.enemyInfo, 2)
        else
            fitInfo(bg1, self._battleInfo.playerInfo, 1)
            fitInfo(bg2, self._battleInfo.enemyInfo, 2)
        end
    else
        callback()
    end
end

function BattleScene:initBattleSkill(callback, noEff)
    if not ENABLE_BATTLE_BEGIN then return false end
    if not logic then return false end
    return logic:initBattleSkill(callback, noEff)
end

local background = 0
function BattleScene:applicationDidEnterBackground()
    if weatherOpen then
        background = gettime()
    end
end

function BattleScene:applicationWillEnterForeground(second)
    if weatherOpen and _updateBeginTick then
        _updateBeginTick = _updateBeginTick + (gettime() - background)
    end
    -- 冠军对决假装是实时，所以从后台回来后，自动跳过一定回合数
    if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_League then
        -- 跳过回合数
        if self._warpFrame then
            self._warpFrame = self._warpFrame + math.floor(second * 30 * BC.BATTLE_SPEED)
        else
            self._warpFrame = math.floor(second * 30 * BC.BATTLE_SPEED)
        end
    end
end

function BattleScene:battleBegin()
    if not ENABLE_BATTLE_BEGIN then return end
    logic:BattleBegin()
    if not BATTLE_PROC then
        if weatherOpen then
            if _updateBeginTick then
                local fps = _updateBeginTime / (gettime() - _updateBeginTick)
                print(fps)
                if fps < 20 then
                    self._weatherLayer:closeWeather()
                end
                weatherOpen = false
            end
        end
    end
    -- if OS_IS_ANDROID then
    --     self.__fpsBeginTime = gettime()
    --     self.__battleBeginTime = self.__fpsBeginTime
    --     self.__fpsCount = 0
    --     file = io.open(cc.FileUtils:getInstance():getWritablePath() .."/fps.txt", "a")
        
    --     file:write("\n" .. "left Teams: ".. #logic._teams[1].. " right Teams: ".. #logic._teams[2] ..  "\n")
    --     file:write("battleBegin ".. self.__battleBeginTime.. "\n")
    --     file:close()
    -- end
    if not BATTLE_PROC then 
        self._skipBtn:setTouchEnabled(true) 
    end
end

function BattleScene:battleEnd()
    if not BATTLE_PROC and not BC.jump then
        self:onPlayerSkillMoveEnd()
    end
    -- if OS_IS_ANDROID then
    --     local t = gettime()
    --     local fps = self.__fpsCount / (t - self.__fpsBeginTime)
    --     file = io.open(cc.FileUtils:getInstance():getWritablePath() .."/fps.txt", "a")
    --     file:write("time: " .. (t - self.__battleBeginTime) .. " fps: ".. fps .. "\n")
    --     file:write("battleEnd " .. gettime() .. "\n\n")
    --     file:close()
    --     self.__fpsCount = nil
    -- end
end

-- 战斗结束并且收到服务器结果后调用
function BattleScene:over()
    if self._guideHelpState then
        GBHU.guideRunOver(self._battleInfo.mode, self._battleInfo.battleId)
    end
    logic:totemOver()
end
 
local EStateING = EState.ING
local EStateINTO = EState.INTO
local EStateREADY = EState.READY

function BattleScene:update(dt)
    -- 主循环
    -- if self.__fpsCount then
    --     self.__fpsCount = self.__fpsCount + 1
    --     local t = gettime()
    --     if t > self.__fpsBeginTime + 5 then
    --         local fps = self.__fpsCount / (t - self.__fpsBeginTime)
    --         file = io.open(cc.FileUtils:getInstance():getWritablePath() .."/fps.txt", "a")
    --         file:write("time: " .. (t - self.__battleBeginTime) .. " fps: ".. fps .. "\n")
    --         file:close()
    --         self.__fpsBeginTime = t
    --         self.__fpsCount = 0
    --     end
    -- end
    if self._isOver then return end
    if not BC.jump then
        -- 蓝显示
        if self._manaLabel then
            if BC.reverse then
                self._manaLabel:setString(floor(logic.mana[2]))
            else
                self._manaLabel:setString(floor(logic.mana[1]))
            end
        end

        -- 更新玩家touch
        self:updateTouch()
        -- 逻辑update
        if BC.BATTLE_SPEED > 0 then
            if GAME_SPEED_TYPE == 1 then
                if self._warpFrame and logic.battleState == EState.ING then
                    -- 跃迁
                    if self._warpFrame > 1000 then
                        self:doJump()
                    else
                        for i = 1, self._warpFrame do
                            tickUpdate()
                            displayTickUpdate()
                            if logic:update() then
                                break
                            end
                        end
                        logic:updateDisplay()
                    end
                    self._warpFrame = nil  
                else
                    for i = 1, BC.BATTLE_SPEED do
                        if BC.BATTLE_SPEED > 0 then
                            tickUpdate()
                            displayTickUpdate()
                            if logic:update() then
                                break
                            end
                            if i > BC.BATTLE_SPEED then
                                break
                            end
                        end
                    end
                    logic:updateDisplay()
                end
            else
                tickUpdate()
                displayTickUpdate()
                logic:update()
                logic:updateDisplay()
            end
        else
            -- 方阵血条
            if BattleUtils.HUD_TYPE == 1 then
                objLayer:updateTeamHUD(logic.battleTime)
            else

            end
        end

        -- 统计双方HP
        if logic.battleState ~= EState.READY then
            self:countHP()
        end
        -- 每帧手动GC
        -- collectgarbage("step", 0)

        if self._jump then
            self._jump = false
            self:jump()
            return
        end
        if not BATTLE_PROC then
            self:updatePlayerSkillCount()
            -- 更新星星界面
            self:updateStar()
            -- 更新屏外敌人提示
            self:updateOutEnemy()

            self:updateTreasureSkillIcon()

            self:updateTime()

            self:updateEx(dt)

            self:guildHelp()
        end
    else
        local updateCount = 45
        while logic.battleTime < 350 and self._isWin == nil and updateCount > 0 do
            tickUpdate()
            logic:update()
            updateCount = updateCount - 1
        end
        if self._isWin ~= nil then
            -- 结束 
            GameStatic.showClickMc = true
            self:removeSkipLayer(logic._isTimeUp)
            if not BC.fastBattle then
                self._isOver = true
                ScheduleMgr:delayCall(1000, self, function()
                    self._BattleView:unlock()
                    audioMgr:enable()
                    logic:BattleEnd(logic._isTimeUp, logic._isSurrender, logic._isSkip, 1)
                    BC.jump = false
                    self._isOver = false
                end)
            end
        else
            self:updateSkipLayer()
        end
    end
end

function BattleScene:guildHelp(inTime)
    if inTime == nil then
        if logic.battleBeginTick == nil then return end
        if logic.battleState ~= EStateING then return end
        if self._guideHelpState == false then return end

        time = ceil(logic.battleTime)
    else
        time = inTime
    end

    local state, configs = GBHU.checkGuideTime(time)
    -- click或point类型的
    if state == true then
        GBHU.doGuideEvent(
            configs, 
            self._BattleView,
            function(x, y)
                return self._sceneLayer:nodeConvertToScreenSpace(x, y)
            end, 
            function(pauseTime) -- 个别情况需要暂停游戏，回调此方法
                if pauseTime then
                    logic:battlePause()
                else
                    self._pauseSpeed = BC.BATTLE_SPEED
                    self:setBattleSpeed(0)
                end
            end,
            function(pauseTime) -- 个别情况需要暂停游戏，回调此方法
                if not self:isHeroSkillAnim() then
                    if pauseTime then
                        logic:battleResume()
                    else
                        self:setBattleSpeed(self._pauseSpeed)
                    end
                else
                    self._HSSpeed = self._pauseSpeed
                end
            end,
            -- 根据类型区分调用方法
            function(inType, inConfig, callback)
                if inType == 1 then -- 快速释放技能
                    delayCall(inConfig.delay * 0.001, self, function ()
                        logic:quickCastPlayerSkill(inConfig.camp, inConfig.skillIndex, inConfig.beginP, inConfig.endP)
                    end)
                elseif inType == 2 then -- 影响技能前置cd
                    logic:guideHelpUpdateInitCd(inConfig.camp, inConfig.skillIndex, inConfig.value)
                elseif inType == 3 then -- 影响技能战前魔法值
                    logic:guideHelpUpdatePlayerMana(inConfig.camp, inConfig.value)
                elseif inType == 4 then -- 召唤方阵
                    logic:guideAction(inConfig.action, callback)
                end
            end
        )
    end

end

-- 跳过战斗
function BattleScene:jump()
    if logic.battleBeginTick == nil then
        return
    end
    self:onPlayerSkillMoveEnd()
    logic:clearSkill()
    self._BattleView:enableSkillIcon()
    BC.jump = true
    -- audioMgr:stopAll()
    audioMgr:disable()
    logic:clearHero()
    self._weatherLayer:closeWeather()
    self._weatherLayer:getView():retain()
    self._objectLayer:clear()
    self._objectLayer:getView():addChild(self._weatherLayer:getView())
    self._weatherLayer:getView():release()

    if not BATTLE_PROC then
        self._objectLayer:hideAllTeamHUD()
    end
    logic:clearTotemEff()
    logic:clearTeamStateLabel()
    if BATTLE_PROC then
        -- 复盘的时候是否自动释放技能
        if BattleUtils.PROC_AUTO_SKILL[self._battleInfo.mode] then
            logic:setSkillAuto(true)
        end
    end
    self:battleBeginAnimCancel()
    self:clearOutEnemy()
    self._BattleView:lock(-1)

    GameStatic.showClickMc = false

    self:initSkipLayer()
end

local ETeamStateDIE = ETeamState.DIE
-- 跳过界面初始化
function BattleScene:initSkipLayer()
    local notShowHero2 = false
    local mode = self._battleInfo.mode
    if mode == BattleUtils.BATTLE_TYPE_BOSS_DuLong or
        mode == BattleUtils.BATTLE_TYPE_BOSS_SjLong or
        mode == BattleUtils.BATTLE_TYPE_BOSS_XnLong or
        mode == BattleUtils.BATTLE_TYPE_GBOSS_1 or
        mode == BattleUtils.BATTLE_TYPE_GBOSS_3 or
        mode == BattleUtils.BATTLE_TYPE_GBOSS_2 or
        mode == BattleUtils.BATTLE_TYPE_AiRenMuWu or
        mode == BattleUtils.BATTLE_TYPE_Zombie then
        notShowHero2 = true
    end

    self:resetHeadUI()
    self:clearTreasureSkillIcon()

    local bg = cc.Sprite:create("asset/bg/bg_jump.jpg")
    bg:setAnchorPoint(0, 1)

    local xscale = MAX_SCREEN_WIDTH / 1022
    local yscale = MAX_SCREEN_HEIGHT / 576
    if xscale > yscale then
        bg:setScale(xscale)
    else
        bg:setScale(yscale)
    end
    local scale = bg:getScale()
    self._skipSceneScale = scale

    local dx = (bg:getContentSize().width * scale - MAX_SCREEN_WIDTH) * 0.5
    local dy = (bg:getContentSize().height * yscale - MAX_SCREEN_HEIGHT) * 0.5

    bg:setPosition((self._topLayer:getContentSize().width - MAX_SCREEN_WIDTH) * 0.5 - dx, self._topLayer:getContentSize().height - dy + 2)
    self._topLayer:addChild(bg, -1)

    self._skipBg = bg

    self._hpShadow1:setPercent(0)
    self._hpShadow2:setPercent(0)

    local layer = ccui.Layout:create()
    layer:setBackGroundColorOpacity(255)
    layer:setBackGroundColorType(1)
    layer:setBackGroundColor(cc.c3b(0,0,0))
    layer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    layer:setOpacity(0)
    self._BattleView:addChild(layer, 99999)
    self._skipLayer = layer

    local node = cc.Node:create()
    node:setPosition((MAX_SCREEN_WIDTH - 960) * 0.5, (MAX_SCREEN_HEIGHT - 640) * 0.5)
    layer:addChild(node)

    local textbg = cc.Sprite:createWithSpriteFrameName("jumpTextBg_battle.png")
    textbg:setPosition(MAX_SCREEN_WIDTH * 0.5, 64)
    textbg:setScaleX(1.5)
    layer:addChild(textbg, 100)

    -- 跳过界面文字
    local text = cc.Label:createWithTTF(lang("JUMPDES_01_0"..math.random(3)), UIUtils.ttfName, 24)
    text:setPosition(MAX_SCREEN_WIDTH * 0.5, 64)
    text:setColor(cc.c3b(250, 230, 203))
    text:enableOutline(cc.c4b(60,30,10,255), 1)
    layer:addChild(text, 10001)
    self._skipText = text

    -- 英雄头像
    local BC_reverse = BC.reverse
    local info = BC_reverse and self._battleInfo.enemyInfo or self._battleInfo.playerInfo
    local id = info.hero.id
    local heroD = tab.hero[id]
    if heroD == nil then
        heroD = tab.npcHero[id]
    end
    local heroData = clone(heroD)
    heroData.star = info.hero.star
    local hero1 = IconUtils:createHeroIconById({sysHeroData = heroData, skin = info.hero.skin})
    hero1:setPosition(70, MAX_SCREEN_HEIGHT - 56)
    hero1:setScale(0.8)
    layer:addChild(hero1, 100)
    self._jumpHero1 = hero1

    local dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
    layer:addChild(dieIcon, 101)
    dieIcon:setPosition(70, MAX_SCREEN_HEIGHT - 56)
    dieIcon:setVisible(false)
    hero1.die = dieIcon

    if not notShowHero2 then
        info = BC_reverse and self._battleInfo.playerInfo or self._battleInfo.enemyInfo
        id = info.hero.id
        local heroD = tab.hero[id]
        if heroD == nil then
            heroD = tab.npcHero[id]
        end
        local heroData = clone(heroD)
        heroData.star = info.hero.star
        local hero2 = IconUtils:createHeroIconById({sysHeroData = heroData, skin = info.hero.skin})
        hero2:setScale(0.8)
        hero2:setPosition(MAX_SCREEN_WIDTH - 70, MAX_SCREEN_HEIGHT - 56)
        layer:addChild(hero2, 100)
        self._jumpHero2 = hero2

        local dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
        layer:addChild(dieIcon, 101)
        dieIcon:setPosition(MAX_SCREEN_WIDTH - 70, MAX_SCREEN_HEIGHT - 56)
        dieIcon:setVisible(false)
        hero2.die = dieIcon
    end

    local mainCamp = BC_reverse and 2 or 1
    local subCamp = 3 - mainCamp
    local dieIcon, proBg, proHp, sp
    local team, info, star, stage, teamid, npcD, x, y
    local count1 = 0
    for i = 1, #logic._teams[mainCamp] do
        team = logic._teams[mainCamp][i]
        if team.original then
            count1 = count1 + 1
        end
    end
    -- 左方兵团
    self._jumpIcon1 = {}
    self._jumpIcon2 = {}
    for i = 1, 8 do
        if i > count1 then break end
        team = logic._teams[mainCamp][i]
        local pic = TeamUtils.getNpcTableValueByTeam(team.D, team.jx and "jxart1" or "art1")

        local class = TeamUtils.getNpcTableValueByTeam(team.D, "classlabel") .. ".png"

        local icon = cc.Node:create()
        icon:setScale(.8)
        layer:addChild(icon)

        local headNode = cc.Node:create()
        icon:addChild(headNode)
        icon.headNode = headNode

        local head = cc.Sprite:createWithSpriteFrameName(pic .. ".jpg")

        head:setScale(0.68)

        headNode:addChild(head)

        dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
        icon:addChild(dieIcon)

        dieIcon:setScale(0.8)
        icon.die = dieIcon

        proBg = cc.Sprite:createWithSpriteFrameName("jumpHeadBg_"..mainCamp..".png")
        proBg:setPositionY(-18)
        headNode:addChild(proBg)

        local classIcon = cc.Sprite:createWithSpriteFrameName(class)

        classIcon:setPosition(-22, 22)

        classIcon:setScale(.6)
        headNode:addChild(classIcon)

        sp = cc.Sprite:createWithSpriteFrameName("jumpHP_"..mainCamp..".png")
        proHp = cc.ProgressTimer:create(sp)
        proHp:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        proHp:setMidpoint(cc.p(0, 0.5))
        proHp:setBarChangeRate(cc.p(1, 0))   

        proHp:setAnchorPoint(1, 0)

        proHp:setPercentage(team.curHP / team.maxHP * 100)
        proHp:setPosition(70, 28)
        proBg:addChild(proHp)
        icon.hp = proHp
        icon:setPosition(-1000, -1000)

        if team.state == ETeamStateDIE then
            icon.headNode:setSaturation(-100)
        else
            dieIcon:setVisible(false)
        end
        self._jumpIcon1[i] = icon
    end

    local count2 = 0
    for i = 1, #logic._teams[subCamp] do
        team = logic._teams[subCamp][i]
        if team.original then
            count2 = count2 + 1
        end
    end
    -- 右方兵团
    for i = 1, 8 do
        if i > count2 then break end
        team = logic._teams[subCamp][i]

        local pic = TeamUtils.getNpcTableValueByTeam(team.D, team.jx and "jxart1" or "art1")

        local class = TeamUtils.getNpcTableValueByTeam(team.D, "classlabel") .. ".png"

        local icon = cc.Node:create()
        icon:setScale(.8)
        layer:addChild(icon)

        local headNode = cc.Node:create()
        icon:addChild(headNode)
        icon.headNode = headNode

        local head = cc.Sprite:createWithSpriteFrameName(pic .. ".jpg")

        head:setScale(-0.68, 0.68)

        headNode:addChild(head)

        dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
        icon:addChild(dieIcon)
        
        dieIcon:setScale(0.8)
        icon.die = dieIcon

        proBg = cc.Sprite:createWithSpriteFrameName("jumpHeadBg_"..subCamp..".png")
        proBg:setPositionY(-18)
        headNode:addChild(proBg)

        local classIcon = cc.Sprite:createWithSpriteFrameName(class)

        classIcon:setPosition(22, 22)

        classIcon:setScale(.6)
        headNode:addChild(classIcon)

        sp = cc.Sprite:createWithSpriteFrameName("jumpHP_"..subCamp..".png")
        proHp = cc.ProgressTimer:create(sp)
        proHp:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        proHp:setMidpoint(cc.p(0, 0.5))
        proHp:setBarChangeRate(cc.p(1, 0))  

        proHp:setScaleX(-1)
        proHp:setAnchorPoint(0, 0) 

        proHp:setPercentage(team.curHP / team.maxHP * 100)
        proHp:setPosition(70, 28)
        proBg:addChild(proHp)
        icon.hp = proHp
        icon:setPosition(-1000, -1000)

        if team.state == ETeamStateDIE then
            icon.headNode:setSaturation(-100)
        else
            dieIcon:setVisible(false)
        end
        self._jumpIcon2[i] = icon
    end
    self._jumpDieText = math.random(count1 + count2)
    if self._jumpDieText > count1 then
        self._jumpDieTextCamp = 2
    else
        self._jumpDieTextCamp = 1
    end
end

function BattleScene:updateSkipLayer()
    local mainCamp = BC.reverse and 2 or 1
    local subCamp = 3 - mainCamp

    -- 总血条
    self:countHPEx()
    if self._destValue1 then self._shadowValue1 = self._destValue1 end
    if self._destValue2 then self._shadowValue2 = self._destValue2 end

    local time = ceil(self.CountTime - logic.battleTime)
    local str = self._timeLabel:getString()
    local newStr = formatTime(time)
    self._timeLabel:setString(newStr)

    -- 场景坐标
    -- 0    2400
    -- 600  1800
    -- -600 / 1200
    local bx = 600
    local scalex = MAX_SCREEN_WIDTH / 1200
    local by = 0
    local scaley = 360 / 540 * self._skipSceneScale

    local icon, team
    local x, y
    local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL
    local BC_reverse = BC.reverse
    for i = 1, #self._jumpIcon1 do
        icon = self._jumpIcon1[i]
        team = logic._teams[mainCamp][i]
        if team.state == ETeamStateDIE then
            icon.headNode:setSaturation(-100)
            icon.die:setVisible(true)
            if self._jumpDieTextCamp == mainCamp then
                if self._jumpDieText == i then
                    self._jumpDieTextCamp = 0
                    local str = lang("JUMPDES_02_0"..math.random(3))
                    str = string.gsub(str, "{$deadname}", lang(team.D["name"]))
                    self._skipText:setString(str)
                end
            end
        else
            icon.headNode:setSaturation(0)
            icon.die:setVisible(false)
        end
        icon.hp:setPercentage(team.curHP / team.maxHP * 100)
        x, y = BC_reverse and MAX_SCENE_WIDTH_PIXEL - team.x or team.x, team.y
        icon:setPositionAndLocalZorder((x - bx) * scalex, (y + by) * scaley, 8000-y)
    end
    for i = 1, #self._jumpIcon2 do
        icon = self._jumpIcon2[i]
        team = logic._teams[subCamp][i]
        if team.state == ETeamStateDIE then
            icon.headNode:setSaturation(-100)
            icon.die:setVisible(true)
            if self._jumpDieTextCamp == subCamp then
                if self._jumpDieText - #self._jumpIcon1 == i then
                    self._jumpDieTextCamp = 0
                    local str = lang("JUMPDES_02_0"..math.random(3))
                    str = string.gsub(str, "{$deadname}", lang(team.D["name"]))
                    self._skipText:setString(str)
                end
            end
        else
            icon.headNode:setSaturation(0)
            icon.die:setVisible(false)
        end
        icon.hp:setPercentage(team.curHP / team.maxHP * 100)
        x, y = BC_reverse and MAX_SCENE_WIDTH_PIXEL - team.x or team.x, team.y
        icon:setPositionAndLocalZorder((x - bx) * scalex, (y + by) * scaley, 8000-y)
    end
    if self._isWin ~= nil then
        local win
        if BC.reverse then
            win = not self._isWin
        else
            win = self._isWin
        end
        if win then
            if self._jumpHero2 then
                self._jumpHero2:setSaturation(-100)
                self._jumpHero2.die:setVisible(true)
            end
        else
            self._jumpHero1:setSaturation(-100)
            self._jumpHero1.die:setVisible(true)
        end
    end
end

function BattleScene:removeSkipLayer(isTimeUp)
    self:updateSkipLayer()
    if isTimeUp then
        self._skipText:setString(lang("JUMPDES_03_04"))
    else
        local hp
        local name
        local hp1 = (logic._HP[1] + logic._summonHP[1] / logic._MaxHP[1] + logic._summonMaxHP[1]) * 100
        local hp2 = (logic._HP[2] + logic._summonHP[2] / logic._MaxHP[2] + logic._summonMaxHP[2]) * 100

        local win = self._isWin
        if win then
            hp = hp1
            name = BC.reverse and "防守方" or "进攻方"
            if self._battleInfo.playerInfo.name then
                name = self._battleInfo.playerInfo.name
            end
        else
            hp = hp2
            name = BC.reverse and "进攻方" or "防守方"
            if self._battleInfo.enemyInfo.name then
                name = self._battleInfo.enemyInfo.name
            end
        end
        if hp > 70 then
            local str = string.gsub(lang("JUMPDES_03_01"), "{$winside}", name)
            self._skipText:setString(str)
        elseif hp > 40 then
            self._skipText:setString(lang("JUMPDES_03_02"))
        else
            self._skipText:setString(lang("JUMPDES_03_03"))
        end
    end
    BC.DelayCall:clear()
end

function BattleScene:countHP()
    if BATTLE_PROC then return end
    self:countHPEx()
    if OS_IS_WINDOWS then
        local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
        local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
        local str1 = hp1 + shp1 .. "/" .. maxhp1 + maxshp1 .. "\n" .. string.format("%.3f", (hp1 + shp1) / (maxhp1 + maxshp1) * 100) .. "%"
        self._debugHPLabel1:setString(str1)
        local str2 = hp2 + shp2 .. "/" .. maxhp2 + maxshp2 .. "\n" .. string.format("%.3f", (hp2 + shp2) / (maxhp2 + maxshp2) * 100) .. "%"
        self._debugHPLabel2:setString(str2)
    end
    
    if BC.reverse then
        if self._destValue2 then
            if self._destValue2 > 15 then
                self:disableHpWarning()
            else
                self:enableHpWarning()
            end
        end
    else
        if self._destValue1 > 15 then
            self:disableHpWarning()
        else
            self:enableHpWarning()
        end
    end
end

function BattleScene:onBattleBegin()
    -- 战斗开始
    self._callback("onBattleBegin")
    if setMultipleTouchEnabled then setMultipleTouchEnabled() end
    if setEventUpDelayDisabled then setEventUpDelayDisabled() end
    -- audioMgr:playSound("war_start")
    -- self._war_render = audioMgr:playSound("war_render", true, 0.2)
end

function BattleScene:onBattleEnd(leftData, rightData, dieList, dieCount, isTimeUp, isSurrender, isSkip, hero1, hero2, skillList, ex, zuobi)
    audioMgr:stopAll()
    self:disableHpWarning()
    self._pauseBtn:loadTextureNormal("pauseBtn_battle.png", 1)
    if not self._autoBtn.lock:isVisible() then
        self._autoBtn:loadTextureNormal("autoBtn_battle.png", 1)
    end
    self._speedBtn:loadTextureNormal("speedBtn_battle.png", 1)
    self._speedBtn:loadTexturePressed("speedBtn_battle.png", 1)
    -- 战斗结束
    local time = logic.battleTime
    if self._timeLabel then
        self:setOverTime(time)
    end
    if self._star then 
        if not self._isWin then
            self:_setStar(0)
        else
            if time > 61 and logic.originalDieCount >= 3 then
                self:_setStar(1)           
            elseif time > 61 then
                self:_setStar(2)
            elseif logic.originalDieCount >= 3 then
                self:_setStar(2) 
            else
                self:_setStar(3) 
            end
        end
    end
    self:battleBeginAnimCancel()

    local mask = ccui.Layout:create()
    mask:setBackGroundColorOpacity(0)
    mask:setBackGroundColorType(1)
    mask:setBackGroundColor(cc.c3b(255,0,0))
    mask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    mask:setTouchEnabled(true)
    self._rootLayer:getParent():addChild(mask)
    self._overMask = mask

    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:removeEventListenersForTarget(self._sceneLayer, true)
    -- dump(skillList)
    local value1, value2, value3, value4 = logic:getCurHP()
    local v1, v2, v3, v4 = logic:getSummonHP()

    local damageServer = 0
    local abs = math.abs
    
    -- edit by hxp : 使用真实伤害_playerDamage表
    for k,v in pairs(logic._playerDamage[1]) do
        damageServer = damageServer  + abs(v)
    end
    damageServer = floor(damageServer)
    local healServer = 0 
    for k,v in pairs(logic._playerHeal[1]) do
        healServer = healServer + abs(v)
    end
    healServer = floor(healServer)

    local res = {hp = {value1+v1, value2+v2, value3+v3, value4+v4}, 
        hpex = {value1, value2, value3, value4},
        leftData=leftData, rightData=rightData, win=self._isWin, time=floor(time), dieList = dieList, dieCount = dieCount, 
        battleId = self._battleInfo.battleId,
        isTimeUp = isTimeUp, isSurrender = isSurrender, isSkip = isSkip, hero1 = hero1.heroD, hero2 = hero2.heroD, 
        hero1skin = hero1.skin, hero2skin = hero2.skin,
        skillList = cjson.encode(skillList), zuobi = zuobi,
        -- 服务器需要传的一些字段
        serverInfoEx = 
        {
            battleTime = floor(time * 1000),
            walleVersion = GameStatic.walleVersion,
            localTime = os.time(),
            heroID = hero1.ID,
            damage = damageServer,
            heal = healServer,
        },
        }
    if GameStatic.useSR then
        if BattleUtils.SRData then
            BattleUtils.endSRData()
            local data, count = BattleUtils.getFormatSRData()
            -- dump(data, count)
            if not OS_IS_WINDOWS then
                for k, v in pairs(data) do
                    res.serverInfoEx[k] = v
                end
            end
            BattleUtils.clearSRData()
        end
    end
    -- 称号
    if hero1.ID == 60102 then
        local skillCount = logic:getCastSkillCount()
        if skillCount[307] then
            res.serverInfoEx.achieve = {["3107"] = skillCount[307]}
        end 
    else
        if self._isWin then
            local teamMap = logic:getTeamMap()
            if hero1.ID == 60303 then
                if teamMap[205] or teamMap[11205] or teamMap[111205] then
                    res.serverInfoEx.achieve = {["3205"] = 1}
                end
            elseif hero1.ID == 60401 then
                if teamMap[306] then
                    res.serverInfoEx.achieve = {["320"] = 1}
                end
            end
        end
    end

    for k, v in pairs(ex) do
        res.serverInfoEx[k] = v
    end

    -- 双方伤害统计
    -- 只记录 original and DType == 1的
    local teamInfo = self:getTeamInfo(leftData, rightData)
    -- dump(teamInfo, "a", 20)
    res.totalDamage1 = ex.totalDamage1
    res.totalDamage2 = ex.totalDamage2
    res.totalRealDamage1 = ex.totalRealDamage1
    res.totalRealDamage2 = ex.totalRealDamage2
    res.dieCount1 = ex.dieCount1
    res.dieCount2 = ex.dieCount2
    res.serverInfoEx.teamInfo = teamInfo
    res.serverInfoEx = cjson.encode(res.serverInfoEx)
    if self._war_render then
        audioMgr:stopSound(self._war_render)
    end
    setMultipleTouchDisabled()
    setEventUpDelayEnabled()


    self:onBattleEndEx(res)
    self._callback("onBattleEnd", res)
    -- print(logic:getCurHP())
    -- print(logic:getSummonHP())
    dump({value1+v1, value2+v2, value3+v3, value4+v4})
    dump({value1, value2, value3, value4})
    if self._weatherLayer then self._weatherLayer:closeWeather() end
end

function BattleScene:getTeamInfo(leftData, rightData)
    local leftTeam = {}
    local key
    for k, v in pairs(leftData) do
        if k == 0 then
            leftTeam["hero"] = 
            {
                damage = v.damage,
                heal = v.heal,
            }
        else
            if v.original and v.DType == 1 then
                key = tostring(v.D["id"])
                if v.dhr then
                    key = key .. "#" .. v.dhr
                end
                leftTeam[key] = 
                {
                    damage = v.damage,
                    hurt = v.hurt,
                    heal = v.heal,
                }
            end
        end
    end
    local rightTeam = {}
    for k, v in pairs(rightData) do
        if k == 0 then
            rightTeam["hero"] = 
            {
                damage = v.damage,
                heal = v.heal,
            }
        else
            if v.original and v.DType == 1 then
                key = tostring(v.D["id"])
                if v.dhr then
                    key = key .. "#" .. v.dhr
                end
                rightTeam[key] = 
                {
                    damage = v.damage,
                    hurt = v.hurt,
                    heal = v.heal,      
                }
            end
        end
    end
    return {leftTeam = leftTeam, rightTeam = rightTeam}
end

function BattleScene:onWinner(winner)
    -- 分出胜负
    self._isWin = (winner == ECamp.LEFT)
    self:countHP()
end

function BattleScene:initEvent()
    -- 注册多点触摸
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function (touches, event)
        self:onTouchesBegan(touches, event)
    end, cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(function (touches, event)
        self:onTouchesMoved(touches, event)
    end, cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(function (touches, event)
        self:onTouchesEnded(touches, event)
    end, cc.Handler.EVENT_TOUCHES_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._sceneLayer)

    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function (event)
        self:onMouseScroll(event)
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._sceneLayer)
end
function BattleScene:distance(pt1x, pt1y, pt2x, pt2y)
    local dx = math.abs(pt2x - pt1x)
    local dy = math.abs(pt2y - pt1y)
    return math.sqrt(dx * dx + dy * dy)
end

function BattleScene:onSceneScale(scale)
    local s = scale / BC.MIN_SCENE_SCALE
    if s ~= BC.NOW_SCENE_SCALE then
        BC.NOW_SCENE_SCALE = s
        logic:onSceneScale()
    end
end

function BattleScene:updateTouch()
    if self._skillAreaDown then
        local _x, _y = self:getSceneLayerPoint(cc.p(self._skillAreaX, self._skillAreaY))
        logic:onPlayerSkillMove(_x, _y, self._skillAreaX, self._skillAreaY)
        if self._BattleView:isInSkillCancelArea(self._skillAreaX, self._skillAreaY) then
            self._BattleView:setSkillCancelAreaType(2)
        else
            self._BattleView:setSkillCancelAreaType(1)
        end
    end
    if self._skillDownTouchID ~= -1 then
        self:playerSkillMove(self._skillX, self._skillY)
    elseif self._totemDownTouchID ~= -1 then
        self:totemMove(self._skillX, self._skillY)
    else
        if not self:updateTouchEx() then return end 
        if GBHU.LOCK then return end
        if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
            self:updateScenePos(self._touchMoveX, self._touchMoveY, 0.7)
        elseif self._touche1Down and self._touche2Down then
            local scale = self._touchScale--self._sceneLayer:getScale() + (self._touchScale - self._sceneLayer:getScale()) * 0.7
            self._sceneLayer:setScale(scale)
            self:onSceneScale(scale)
            self._touchesBeganPositionX = self._touchesBeganPositionX or 0
            self._touchesBeganPositionY = self._touchesBeganPositionY or 0
            local nx = self._touchesBeganPositionX * scale
            local ny = self._touchesBeganPositionY * scale
            self:updateScenePos(nx, ny)
        end
    end
end

function BattleScene:onMouseScroll(event)
    if logic.battleState ~= EStateING then return end
    if self._battleBeginAniming then return end
    if not self:onMouseScrollEx() then return end 
    self._touchesBeganScale = self._touchScale
    self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
    self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    local scale = self._touchesBeganScale + event:getScrollY() * 0.1
    if ENABLE_ADJUST_MAP_SCALE then
        scale = math.min(BC.MAX_SCENE_SCALE, math.max(BC.MIN_SCENE_SCALE, scale)) 
        -- print(scale)
    end
    self._sceneLayer:setScale(scale)
    self:onSceneScale(scale)
    self._touchScale = scale
    local nx = self._touchesBeganPositionX * scale
    local ny = self._touchesBeganPositionY * scale
    self._sceneLayer:setPosition(nx, ny)
    self:updateScenePos(nx, ny)
end
local selectRoleTick = 0.5
function BattleScene:onTouchesBegan(touches)
    if GBHU.DEBUG then
        local skillX, skillY = self:getSceneLayerPt(touches[1])
        print("点击场景坐标为x=" .. skillX .. ",y=" .. skillY .. ",  战斗id=" .. self._battleInfo.battleId)
    end
    local touchID = touches[1]:getId()

    if touchID == self._totemDownTouchID then
        self._totemDownTouchID = -1
    end
    if self._totemDownTouchID ~= -1 then
        return
    end
    if self:playerSkillDown(touches[1]) then
        self._skillDownTouchID = touchID
        self._skillX, self._skillY = self:getSceneLayerPt(touches[1])
        self._skillAreaDown = true
        self._skillAreaX = touches[1]:getLocation().x
        self._skillAreaY = touches[1]:getLocation().y
        -- self:lock()
        self._BattleView:resetSkillIcon()
        return
    end
    -- 保险, 避免技能卡住
    self._BattleView:enableSkillIcon()

    if self:totemDown(touches[1]) then
        self._totemDownTouchID = touchID
        self._skillX, self._skillY = self:getSceneLayerPt(touches[1])
        return
    end

    local count = #touches
    for i = 1, count do
        if touches[i]:getId() == 0 then
            self._touche1Down = true
            self._touche1DownEx = true
            self._touche1X = touches[i]:getLocation().x
            self._touche1Y = touches[i]:getLocation().y
        elseif touches[i]:getId() == 1 then
            self._touche2Down = true
            self._touche2DownEx = true
            self._touche2X = touches[i]:getLocation().x
            self._touche2Y = touches[i]:getLocation().y
        end
    end

    self._toucheDownTick = BC.BATTLE_TICK
    self._toucheRole = true

    if not self:onTouchesBeganEx() then return end 
    if GBHU.LOCK or logic.battleState ~= EStateING then 
        self._touche1Down = false
        self._touche2Down = false
        return 
    end

    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        if self._touche1Down then
            self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
            self._touchBeganPositionX = self._touche1X
            self._touchBeganPositionY = self._touche1Y
            self:onTouchMoved(self._touche1X, self._touche1Y)
        elseif self._touche2Down then
            self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
            self._touchBeganPositionX = self._touche2X
            self._touchBeganPositionY = self._touche2Y
            self:onTouchMoved(self._touche2X, self._touche2Y)
        end
    elseif self._touche1Down and self._touche2Down then
        self._touchesBeganDistance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        self._touchesBeganScale = self._sceneLayer:getScale()
        self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
        self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    end
end

function BattleScene:onTouchesMoved(touches)
    local count = #touches

    if self._skillDownTouchID ~= -1 then
        for i = 1, count do
            if self._skillDownTouchID == touches[i]:getId() then         
                self._skillAreaX = touches[i]:getLocation().x
                self._skillAreaY = touches[i]:getLocation().y
                self._skillX, self._skillY = self:getSceneLayerPt(touches[i])
                return
            end
        end
        return
    end
    if self._totemDownTouchID ~= -1 then
        for i = 1, count do
            if self._totemDownTouchID == touches[i]:getId() then
                self._skillX, self._skillY = self:getSceneLayerPt(touches[i])
                return
            end
        end
        return
    end

    for i = 1, count do
        if touches[i]:getId() == 0 then
            if math.abs(touches[i]:getLocation().x - self._touche1X) > 5 or math.abs(touches[i]:getLocation().y - self._touche1Y) > 5 then
                self._toucheRole = false
            end
            self._touche1X = touches[i]:getLocation().x
            self._touche1Y = touches[i]:getLocation().y
        elseif touches[i]:getId() == 1 then
            self._toucheRole = false
            self._touche2X = touches[i]:getLocation().x
            self._touche2Y = touches[i]:getLocation().y
        end
    end
    if self._toucheRole then
        if BC.BATTLE_TICK - self._toucheDownTick > selectRoleTick then
            self._toucheRole = false
        end
    end

    if not self:onTouchesMovedEx() then return end 
    if GBHU.LOCK or logic.battleState ~= EStateING then 
        self._touche1Down = false
        self._touche2Down = false
        return 
    end
    if self:isBattleBeginAniming() then
        if self._touchBeganPositionX and self._touchBeganPositionY then
            if math.abs(self._touchBeganPositionX - self._touche1X) > 10 or math.abs(self._touchBeganPositionY - self._touche1Y) > 10 then
                self:battleBeginAnimCancel()
                self._touche1Down = self._touche1DownEx
                self._touche2Down = self._touche2DownEx

                if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
                    if self._touche1Down then
                        self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
                        self._touchBeganPositionX = self._touche1X
                        self._touchBeganPositionY = self._touche1Y
                        self:onTouchMoved(self._touche1X, self._touche1Y)
                    elseif self._touche2Down then
                        self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
                        self._touchBeganPositionX = self._touche2X
                        self._touchBeganPositionY = self._touche2Y
                        self:onTouchMoved(self._touche2X, self._touche2Y)
                    end
                elseif self._touche1Down and self._touche2Down then
                    self._touchesBeganDistance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
                    self._touchesBeganScale = self._sceneLayer:getScale()
                    self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
                    self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
                end
            end
        end
    end
    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        if self._touche1Down then
            self:onTouchMoved(self._touche1X, self._touche1Y, event)
        elseif self._touche2Down then
            self:onTouchMoved(self._touche2X, self._touche2Y, event)
        end
    elseif self._touche1Down and self._touche2Down then
        local distance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        local scale = self._touchesBeganScale * (distance / self._touchesBeganDistance)
        scale = math.min(BC.MAX_SCENE_SCALE, math.max(BC.MIN_SCENE_SCALE, scale)) 
        self._touchScale = scale
    end
end

function BattleScene:onTouchMoved(x, y)   
    -- 地图移动
    local lastPtx = self._touchBeganPositionX
    local lastPty = self._touchBeganPositionY
    if lastPtx == nil or lastPty == nil then return end
    local nowPtx = x
    local nowPty = y
    local dx = nowPtx - lastPtx
    local dy = nowPty - lastPty
    local nx = self._touchBeganScenePositionX + dx
    local ny = self._touchBeganScenePositionY + dy
    self._touchMoveX = nx
    self._touchMoveY = ny
end

function BattleScene:onTouchesEnded(touches)
    local count = #touches

    if self._skillDownTouchID ~= -1 then
        for i = 1, count do
            if self._skillDownTouchID == touches[i]:getId() then
                self._skillAreaDown = false
                if not self._BattleView:isInSkillCancelArea(touches[i]:getLocation().x, touches[i]:getLocation().y) then
                    self:playerSkillUp(touches[i])
                else
                    local index = logic:getCurSkillIndex()
                    self:onPlayerSkill(index)
                    self:onPlayerSkillMoveEnd(index)
                    self._BattleView:enableSkillIcon()
                end
                self._skillDownTouchID = -1
                -- self:unlock()
                return
            end
        end
        return
    end

    if self._totemDownTouchID ~= -1 then
        for i = 1, count do
            if self._totemDownTouchID == touches[i]:getId() then
                self:totemUp(touches[i])
                self._totemDownTouchID = -1
                return
            end
        end
        return
    end

    for i = 1, count do
        if touches[i]:getId() == 0 then
            self._touche1Down = false
            self._touche1DownEx = false
        elseif touches[i]:getId() == 1 then
            self._touche2Down = false
            self._touche2DownEx = false
        end
    end

    if BC.CAN_SELECT_TEAM and self._toucheRole and BC.BATTLE_TICK - self._toucheDownTick <= selectRoleTick then
        logic:selectTeam(self:getSceneLayerPt(touches[1]))
        return
    end

    if not self:onTouchesEndedEx() then return end 
    if GBHU.LOCK or logic.battleState ~= EStateING then return end

    if (self._touche1Down and not self._touche2Down) or (not self._touche1Down and self._touche2Down) then
        if self._touche1Down then
            self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
            self._touchBeganPositionX = self._touche1X
            self._touchBeganPositionY = self._touche1Y
            self:onTouchMoved(self._touche1X, self._touche1Y)
        elseif self._touche2Down then
            self._touchBeganScenePositionX, self._touchBeganScenePositionY = self._sceneLayer:getPosition()
            self._touchBeganPositionX = self._touche2X
            self._touchBeganPositionY = self._touche2Y
            self:onTouchMoved(self._touche2X, self._touche2Y)
        end
    elseif self._touche1Down and self._touche2Down then
        self._touchesBeganDistance = self:distance(self._touche1X, self._touche1Y, self._touche2X, self._touche2Y)
        self._touchesBeganScale = self._sceneLayer:getScale()
        self._touchesBeganPositionX = self._sceneLayer:getPositionX() / self._touchesBeganScale
        self._touchesBeganPositionY = self._sceneLayer:getPositionY() / self._touchesBeganScale
    end
end

-- 更新场景坐标
function BattleScene:updateScenePos(x, y, anim)
    self._sceneLayer:stopAllActions()
    if anim then
        local _x, _y = self._sceneLayer:getPosition()
        if x == nil then
            x = _x
        end
        local dx = (x - _x) * anim
        local nx = _x + dx
        if y == nil then
            y = _y
        end
        local dy = (y - _y) * anim
        local ny = _y + dy
        self._sceneLayer:setPosition(self:adjustPos(nx, ny))
    else
        self._sceneLayer:setPosition(self:adjustPos(x, y))
    end
    self._mapLayer:update()
end

function BattleScene:getScenePosition()
    return self._sceneLayer:getPosition()
end

-- 矫正坐标
function BattleScene:adjustPos(x, y)
    local nx = x
    local ny = y
    if ENABLE_ADJUST_MAP then
        local width = BC.MAX_SCENE_WIDTH_PIXEL
        -- boss战比一般场景小
        local BATTLE_TYPE = BC.BATTLE_TYPE
        if BATTLE_TYPE == BattleUtils.BATTLE_TYPE_BOSS_DuLong
            or BATTLE_TYPE == BattleUtils.BATTLE_TYPE_BOSS_XnLong
            or BATTLE_TYPE == BattleUtils.BATTLE_TYPE_BOSS_SjLong then 
            width = 2000
        elseif BATTLE_TYPE == BattleUtils.BATTLE_TYPE_GBOSS_1
            or BATTLE_TYPE == BattleUtils.BATTLE_TYPE_GBOSS_2
            or BATTLE_TYPE == BattleUtils.BATTLE_TYPE_GBOSS_3 then
            width = 1700
        elseif BATTLE_TYPE == BattleUtils.BATTLE_TYPE_Zombie then
            width = 2040
        end
        local x, y = self._sceneLayer:getPosition()
        local x1 = self:convertToScreenPt(0, BC.MAX_SCENE_HEIGHT_PIXEL)
        local x2 = self:convertToScreenPt(width, BC.MAX_SCENE_HEIGHT_PIXEL)
        local k = (width * self._sceneLayer:getScale()) / (x2 - x1)
        local maxX = x - x1 * k
        local minX = x - x2 * k + MAX_SCREEN_WIDTH * k
        local _, y1 = self._mapFar:nodeConvertToScreenSpace(0, 0)
        local _, y2 = self._mapFar:nodeConvertToScreenSpace(0, 256)
        local k = (256 * self._sceneLayer:getScale()) / (y2 - y1)
        local minY = y - (y2 - MAX_SCREEN_HEIGHT) * k + 2

        local _, y3 = self._mapNear:nodeConvertToScreenSpace(0, 0)
        local _, y4 = self._mapNear:nodeConvertToScreenSpace(0, 512)
        local k = (512 * self._sceneLayer:getScale()) / (y4 - y3)
        local maxY = y - y3 * k 

        if BC.BATTLE_TYPE == BattleUtils.BATTLE_TYPE_Zombie then
            maxX = maxX - 100
        end
        minX = minX + SCREEN_X_OFFSET
        if nx > maxX then
            nx = maxX
        end
        if nx < minX then
           nx = minX 
        end
        if ny > maxY then
            ny = maxY
        end
        if ny < minY then
           ny = minY
        end
    end
    return math.floor(nx), math.floor(ny)
end

-- 以某点为屏幕中心
function BattleScene:screenToPos(x, y, anim)
    self._touche1Down = false
    self._touche2Down = false
    local scale = self._sceneLayer:getScale()
    local nx = nil
    if x ~= nil then
        nx = (MAX_SCREEN_WIDTH * 0.5 - x) * scale
    end
    local ny = nil
    if y ~= nil then
        ny = (MAX_SCREEN_HEIGHT * 0.5 - y) * scale
    end
    self:updateScenePos(nx, ny, anim)
end

function BattleScene:screenToSize(scale)
    local x = self._sceneLayer:getPositionX() / self._sceneLayer:getScale()
    local y = self._sceneLayer:getPositionY() / self._sceneLayer:getScale()
    self._sceneLayer:setScale(scale)
    self:onSceneScale(scale)
    local nx = x * scale
    local ny = y * scale
    self:updateScenePos(nx, ny)
end

function BattleScene:playerSkillDown(touch)
    return logic:playerSkillDown(self:getSceneLayerPt(touch))
end

function BattleScene:playerSkillMove(x, y)
    return logic:playerSkillMove(x, y)
end

function BattleScene:playerSkillUp(touch)
    local _x, _y = self:getSceneLayerPt(touch)
    local res = logic:playerSkillUp(_x, _y, true)
    if res then self._BattleView:enableSkillIcon() end
    return res
end

function BattleScene:playerSkillUp_xy(x, y)
    local _x, _y = self:getSceneLayerPt_xy(x, y)
    -- 位置是相对于背景地图
    local res = logic:playerSkillUp(_x, _y, true)
    if res then self._BattleView:enableSkillIcon() end
    return res
end

function BattleScene:totemDown(touch)
    return logic:totemDown(self:getSceneLayerPt(touch))
end

function BattleScene:totemMove(x, y)
    return logic:totemMove(x, y)
end

function BattleScene:totemUp(touch)
    return logic:totemUp(self:getSceneLayerPt(touch))
end

local MAX_SCREEN_WIDTH = MAX_SCREEN_WIDTH
local MAX_SCREEN_HEIGHT = MAX_SCREEN_HEIGHT
function BattleScene:getSceneLayerPt(touch)
    return self._sceneLayer:screenConvertToNodeSpace(touch:getLocation().x, touch:getLocation().y)
end

function BattleScene:getSceneLayerPt_xy(x, y)
    return self._sceneLayer:screenConvertToNodeSpace(x, y)
end

function BattleScene:getSceneLayerPoint(touch)
    return self._sceneLayer:screenConvertToNodeSpace(touch.x, touch.y)
end

function BattleScene:convertToScreenPt(x, y)
    return self._sceneLayer:nodeConvertToScreenSpace(x, y)
end

function BattleScene:convertToNodePt(x, y)
    return self._sceneLayer:screenConvertToNodeSpace(x, y)
end

function BattleScene:onPlayerSkill(index)
    if self._guideHelpState == true then 
        local idx = logic:onGuildePlayerSkill(index)
        if idx ~= 0 then
            self._BattleView:disableSkillIcon(idx)
        end
    else
        logic:onPlayerSkill(index)
    end
end

function BattleScene:onLockSkill()
    if BATTLE_PROC then return end
    self._BattleView:onLockSkill()
end

function BattleScene:onUnlockSkill()
    if BATTLE_PROC then return end
    self._BattleView:onUnlockSkill()
end

function BattleScene:isPlayerSkillSelect(index)
    return logic:isPlayerSkillSelect(index)
end

-- 激活拖动施法方式
function BattleScene:onPlayerSkillMoveBegin(index, x, y)
    logic:onPlayerSkillMoveBegin(index)
    local _x, _y = self:getSceneLayerPoint(cc.p(x, y))
    self._skillAreaDown = true
    self._skillAreaX = x
    self._skillAreaY = y
end

function BattleScene:onPlayerSkillMove(x, y)
    self._skillAreaX = x
    self._skillAreaY = y
end

function BattleScene:onPlayerSkillMoveEnd(index)
    logic:onPlayerSkillMoveEnd(index)
    self._skillAreaDown = false
end

function BattleScene:isSkillAreaShow()
    return self._skillAreaDown
end

function BattleScene:doJump()
    if self._isWin ~= nil then return end
    self._jump = true
end

-- 直接略过
function BattleScene:doSkip()
    logic:doSkip()
end

function BattleScene:onChat(camp, msg)  
    -- logic:getHero(camp):onChat(msg, true)

    local mainCamp = BC.reverse and 2 or 1
    local label = cc.Label:createWithTTF(msg, UIUtils.ttfName, 16)
    label:setColor(cc.c3b(70, 40, 10))
    local node = cc.Node:create()
    local chatBg = cc.Scale9Sprite:createWithSpriteFrameName("globalImgUI_talkBg.png")
    chatBg:setCapInsets(cc.rect(50, 0, 1, 1))
    label:setDimensions(190, 0)
    if camp == mainCamp then
        chatBg:setAnchorPoint(0, 0)
        label:setAnchorPoint(0, 1)
        label:setPosition(40, 68)
    else
        chatBg:setScale(-1, 1)
        chatBg:setAnchorPoint(0, 0)
        label:setAnchorPoint(0, 1)
        label:setPosition(-224, 68)
    end
    
    chatBg:setContentSize(244, 84)

    node:addChild(chatBg)
    node:addChild(label)
    node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.1, 1.0), cc.DelayTime:create(2.5), cc.ScaleTo:create(0.1, 0.2), 
                    cc.RemoveSelf:create(true)))

    
    if camp == mainCamp then
        node:setPosition(160, -70)
    else
        node:setPosition(800, -70)
    end
    self._topLayer:addChild(node, 5)

    local BC_reverse = BC.reverse
    local info
    if camp == 1 then
        info = self._battleInfo.playerInfo
    else
        info = self._battleInfo.enemyInfo
    end

    local id = info.hero.id
    local heroD = tab.hero[id]
    if heroD == nil then
        heroD = tab.npcHero[id]
    end
    local heroData = clone(heroD)
    heroData.star = 0
    local hero1 = IconUtils:createHeroIconById({sysHeroData = heroData, skin = info.hero.skin})
    if camp == mainCamp then
        hero1:setPosition(-36, 41)
    else
        hero1:setPosition(36, 41)
    end 
    hero1:setScale(0.65)
    node:addChild(hero1)
end

function BattleScene:onTuoGuan(tuoguan)
    self._BattleView:onTuoGuan(tuoguan)
end

function BattleScene:isEnableAuto()
    return not GBHU.LOCK
end

function BattleScene:isEnableSpeed()
    return not GBHU.LOCK and not self._HSAniming
end

function BattleScene:isEnablePause()
    return not GBHU.LOCK
end

function BattleScene:isEnableJump()
    return not GBHU.LOCK
end

function BattleScene:isEnableSkip()
    return not GBHU.LOCK
end

function BattleScene:setSkillAuto(isAuto)
    -- self._jump = true
    if isAuto then
        self._BattleView:enableSkillIcon()
    end
    logic:setSkillAuto(isAuto)
end

function BattleScene:updateSkillLock()
    logic:updateSkillLock()
end

function BattleScene:lockSkill()
    logic:lockSkill()
end

function BattleScene:getSkills()
    return logic:getSkills()
end

function BattleScene:getSkillBookPassive()
    return logic:getSkillBookPassive()
end

function BattleScene:setSkillBookPassiveIcon(icon, index)
    logic:setSkillBookPassiveIcon(icon, index)
end

function BattleScene:addSkillIcon(icon, index)
    logic:addSkillIcon(icon, index)
end

-- 怒气显示
function BattleScene:setManaLabel(label)
    self._manaLabel = label
end

-- CD没到
function BattleScene:cdYet(x, y)
    self:showTip("法术冷却时间未到", x, y)
end

-- 蓝不够
function BattleScene:outOfMana(x, y)
    self:showTip("魔法值不足", x, y)
    self._manaLabel:stopAllActions()
    self._manaLabel:runAction(cc.Sequence:create(
        cc.TintTo:create(0.3, 255, 0, 0), cc.TintTo:create(0.3, 255, 255, 255), 
        cc.TintTo:create(0.3, 255, 0, 0), cc.TintTo:create(0.3, 255, 255, 255)))

    self._manaLabel.tip:stopAllActions()
    self._manaLabel.tip:setOpacity(0)
    self._manaLabel.tip:runAction(cc.Sequence:create(
        cc.FadeIn:create(0.3), cc.FadeOut:create(0.3), cc.FadeIn:create(0.3), cc.FadeOut:create(0.3)))

    local bg = self._manaLabel:getParent()
    bg:stopAllActions()
    bg:setColor(cc.c3b(255, 255, 255))
    bg:runAction(cc.Sequence:create(
        cc.TintTo:create(0.3, 255, 0, 0), cc.TintTo:create(0.3, 255, 255, 255), cc.TintTo:create(0.3, 255, 0, 0), cc.TintTo:create(0.3, 255, 255, 255)))
end

function BattleScene:skillCannotCastTip(index, x, y)
    self:showTip(lang("PLAYERSKILL_TIP_0"..index), x, y)
end

function BattleScene:showTip(str, x, y)
    if self._tipbg then
        self._tipbg:removeFromParent()
        self._tipbg = nil
    end
    if self._tiplabel then
        self._tiplabel:removeFromParent()
        self._tiplabel = nil
    end
    local _x, _y = self:convertToScreenPt(x, y)
    local bg = cc.Sprite:createWithSpriteFrameName("globalPanelUI_tipbg.png")
    local label = cc.Label:createWithTTF(str, UIUtils.ttfName, 22)
    local w, h = label:getContentSize().width + 80, 44
    bg:setScale(w / 286, h / 32)
    bg:setPosition(_x, _y + 80)
    label:setPosition(_x, _y + 80)
    bg:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.FadeOut:create(0.5), cc.RemoveSelf:create(true), cc.CallFunc:create(function () self._tipbg = nil end) ))
    label:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.FadeOut:create(0.5), cc.RemoveSelf:create(true), cc.CallFunc:create(function () self._tiplabel = nil end)))
    self._uiLayer:addChild(bg)
    self._uiLayer:addChild(label)
    self._tipbg = bg
    self._tiplabel = label
end

function BattleScene:showWarning(str, time, x, y)
    if BATTLE_PROC then return end
    if self._warningbg then
        self._warningbg:removeFromParent()
        self._warningbg = nil
    end
    if self._warninglabel then
        self._warninglabel:removeFromParent()
        self._warninglabel = nil
    end
    local _x, _y = x, y
    local bg = cc.Sprite:createWithSpriteFrameName("cloudcity_tip_battle.png")
    local label = cc.Label:createWithTTF(str, UIUtils.ttfName, 24)
    local w, h = label:getContentSize().width + 80, 55
    bg:setScale(w / 196, 1)
    bg:setPosition(_x, _y + 80)
    local node = cc.Node:create()
    node:setCascadeColorEnabled(true)
    node:setCascadeOpacityEnabled(true)
    node:setPosition(_x, _y + 80)
    node:addChild(label)
    bg:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.FadeOut:create(0.5), cc.RemoveSelf:create(true), cc.CallFunc:create(function () self._warningbg = nil end) ))
    node:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.FadeOut:create(0.5), cc.RemoveSelf:create(true), cc.CallFunc:create(function () self._warninglabel = nil end)))
    label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(0.8, 255, 100, 100), cc.TintTo:create(0.8, 255, 255, 255))))
    self._uiLayer:addChild(bg)
    self._uiLayer:addChild(node)
    self._warningbg = bg
    self._warninglabel = label
end

function BattleScene:setBattleSpeed(speed)
    --[[
        1 BC.BATTLE_SPEED 为0就不会去调用BattleScene:update里的logic:update方法
          除动画之外的行为都会停止
          ==》{
                1 倒计时停止：logic.battleTime没有变化
                2 技能CD停止：logic.battleTime没有变化
          }
    ]]
    BC.BATTLE_SPEED = speed
    if logic then
        --当speed为0时所有动画停止
        logic:onSpeedChange(speed)
    end
    if self.setBattleSpeedEx then
        self:setBattleSpeedEx(speed)
    end

    if BC.BATTLE_SPEED == 1 then
        self._maxLoopIndex = 2
    else
        self._maxLoopIndex = 1
    end
end

-- 4个按钮的实例
function BattleScene:setControlUI(btn)
    self._speedBtn = btn[1]
    self._pauseBtn = btn[2]
    self._autoBtn = btn[3]
    self._skipBtn = btn[4]
    self._surrenderBtn = btn[5]
    self._chatBtn = btn[6]
end

function BattleScene:enableBtns()
    if not self._speedBtn.lock:isVisible() then
        self._speedBtn:setTouchEnabled(true)
    end
    if not self._pauseBtn.lock:isVisible() then
        self._pauseBtn:setTouchEnabled(true)
    end
    if not self._autoBtn.lock:isVisible() then
        self._autoBtn:setTouchEnabled(true)
    end
end

function BattleScene:disableBtns()
    self._speedBtn:setTouchEnabled(false)
    self._pauseBtn:setTouchEnabled(false)
    self._autoBtn:setTouchEnabled(false)
end

function BattleScene:setView(view)
    self._BattleView = view
    self._uiLayer = view._widget
end

function BattleScene:initBattleUI()
    self._countLabel = self._BattleView:getUI("uiLayer.topLayer.countLabel")
    self._countLabel:setVisible(false)
    self:initBattleUIEx()
    self._uiLayer = self._BattleView:getUI("uiLayer")
    self._bottomLayer = self._BattleView:getUI("uiLayer.bottomLayer")
    self._bottomLayer2 = self._BattleView:getUI("uiLayer.bottomLayer2")
    self._topLayer = self._BattleView:getUI("uiLayer.topLayer")
    self._bottomLayer:setVisible(false)
    self._bottomLayer2:setVisible(false)
    self._topLayer:setVisible(false)

    self._timeLabel = self._BattleView:getUI("uiLayer.topLayer.timeLabel")
    self._timeLabel:setString(formatTime(self.CountTime))

    -- 血量警告
    self._hpWarningSp = cc.Sprite:createWithSpriteFrameName("warning_battle.png")
    self._uiLayer:addChild(self._hpWarningSp, -5)
    self._hpWarningSp:setScale(MAX_SCREEN_WIDTH / self._hpWarningSp:getContentSize().width, MAX_SCREEN_HEIGHT / self._hpWarningSp:getContentSize().height)
    local offsetX = 0 
    if ADOPT_IPHONEX then
        offsetX = 60
    end 
    self._hpWarningSp:setPosition(MAX_SCREEN_WIDTH * 0.5 - offsetX, MAX_SCREEN_HEIGHT * 0.5)
    self._hpWarningSp:setVisible(false)

    if OS_IS_WINDOWS then
        local topLayer = self._BattleView:getUI("uiLayer.topLayer")
        local proBar1 = self._BattleView:getUI("uiLayer.topLayer.pro1")
        local proBar2 = self._BattleView:getUI("uiLayer.topLayer.pro2")

        self._debugHPLabel1 = cc.Label:createWithTTF("0/0", UIUtils.ttfName, 18)
        self._debugHPLabel1:setColor(cc.c3b(255, 255, 255))
        self._debugHPLabel1:enableOutline(cc.c4b(0, 0, 0, 0), 1)
        self._debugHPLabel1:setPosition(proBar1:getPosition())
        topLayer:addChild(self._debugHPLabel1, 9999)

        self._debugHPLabel2 = cc.Label:createWithTTF("0/0", UIUtils.ttfName, 18)
        self._debugHPLabel2:setColor(cc.c3b(255, 255, 255))
        self._debugHPLabel2:enableOutline(cc.c4b(0, 0, 0, 0), 1)
        self._debugHPLabel2:setPosition(proBar2:getPosition())
        topLayer:addChild(self._debugHPLabel2, 9999)
    end
end

function BattleScene:enableHpWarning()
    if self._isHpWarningEnable then return end
    self._isHpWarningEnable = true
    self._hpWarningSp:setVisible(true)
    self._hpWarningSp:stopAllActions()
    self._hpWarningSp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.8), cc.FadeIn:create(0.8))))
end

function BattleScene:disableHpWarning()
    if not self._isHpWarningEnable then return end
    self._isHpWarningEnable = false
    self._hpWarningSp:setVisible(false)
    self._hpWarningSp:stopAllActions()
end

function BattleScene:resetHeadUI()
    for k, v in pairs(self._teamIdList) do
        v:removeFromParent()
    end
    self:initHeadUI(logic:getOriginalTeamId())
end

function BattleScene:initHeadUI(list)
    local posk
    if BC.reverse then
        posk = {1, -1}
    else
        posk = {-1, 1}
    end
    self._teamIdList = {}
    local topLayer = self._topLayer
    local Idlist = self._teamIdList
    self._headList = {{}, {}}
    local team
    for i = 1, 2 do
        local index = 1
        for k = 1, #list[i] do
            team = list[i][k]
            local headBg = cc.Sprite:createWithSpriteFrameName("headbg"..i.."_battle.png")
            local head = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. team.headPic..".jpg")
            head:setScale(0.4)
            head:setPosition(19, 19)
            headBg:addChild(head, -1)
            headBg:setScale(1.2)
            headBg:setPosition(480 + 70 * posk[i] + ((k - 1) * 46) * posk[i], -12)
            headBg.ID = team.ID
            Idlist[team.ID] = headBg
            Idlist[team.ID]:setVisible(false)
            topLayer:addChild(headBg)
            index = index + 1
        end
    end
end
local insert = table.insert
local removebyvalue = table.removebyvalue
function BattleScene:onTeamDieOrRevive(id, camp, die, height, lastone)
    if BC.jump then return end
    if die then
        local cross = cc.Sprite:createWithSpriteFrameName("cross_battle.png")
        self._teamIdList[id]:addChild(cross)
        cross:setScale(5)
        cross:setOpacity(0)
        cross:setPosition(19, 19)
        self._teamIdList[id].cross = cross
        local cross2 = cc.Sprite:createWithSpriteFrameName("cross2_battle.png")
        cross:addChild(cross2)
        cross2:setPosition(9, 9)
        cross2:setOpacity(0)
        cross2:runAction(cc.Sequence:create(cc.DelayTime:create(0.32), cc.FadeIn:create(0.01), cc.FadeOut:create(0.3)))
        cross:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(0.01), cc.ScaleTo:create(0.02, 2), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
            if logic:getTeamDieByID(id) then
                self._teamIdList[id]:setSaturation(-100)
            end
            self._teamIdList[id].cross = nil
        end), cc.FadeOut:create(0.2), cc.RemoveSelf:create(true)))
        self._teamIdList[id]:setVisible(true)
        self._teamIdList[id].anim = true
        self._teamIdList[id].height = height
        insert(self._headList[camp], self._teamIdList[id])
    else
        self._teamIdList[id].anim = false
        self._teamIdList[id]:stopAllActions()
        self._teamIdList[id]:setSaturation(0)
        self._teamIdList[id]:setVisible(false)
        removebyvalue(self._headList[camp], self._teamIdList[id])
    end
    local posk
    local BC_reverse = BC.reverse
    if BC_reverse then
        posk = {1, -1}
    else
        posk = {-1, 1}
    end
    local sqrt = math.sqrt
    for i = 1, 2 do
        local index = 1
        local headBg
        for k = 1, #self._headList[i] do
            local x, y = 480 + 90 * posk[i] + ((index - 1) * 46) * posk[i], -12
            headBg = self._headList[i][k]
            if lastone then
                headBg:stopAllActions()
                headBg:setPosition(x, y)
                headBg.anim = false
                headBg:setScale(1.2)
                headBg:setSaturation(-100)
            else
                if headBg.anim then
                    headBg.anim = false
                    local _x, _y = logic:getTeamScreenPt(headBg.ID)
                    local pt = headBg:getParent():convertToNodeSpace(cc.p(_x, _y))
                    _x = pt.x
                    _y = pt.y + headBg.height
                    headBg:setPosition(_x, _y)
                    headBg:setScale(0)
                    local time = sqrt((x - _x) * (x - _x) + (y - _y) * (y - _y)) * 0.001
                    headBg.beginAnim = gettime()
                    headBg:runAction(cc.Sequence:create(
                        cc.ScaleTo:create(0.1, 1.7), cc.ScaleTo:create(0.05, 1.4),
                        cc.DelayTime:create(0.7), 
                        cc.Spawn:create(cc.ScaleTo:create(time, 1.2), cc.MoveTo:create(time, cc.p(x, y)))))
                else
                    if headBg.beginAnim then
                        local _x, _y = headBg:getPosition()
                        local time = sqrt((x - _x) * (x - _x) + (y - _y) * (y - _y)) * 0.001
                        headBg:stopAllActions()
                        local t = gettime()
                        if t > headBg.beginAnim + 0.85 then
                            headBg:runAction(cc.Spawn:create(cc.ScaleTo:create(time, 1.2), cc.MoveTo:create(time, cc.p(x, y))))
                        else
                            headBg:setScale(1.4)
                            headBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.85 - (t - headBg.beginAnim)), cc.Spawn:create(cc.ScaleTo:create(time, 1.2), cc.MoveTo:create(time, cc.p(x, y)))))
                        end
                    else
                        headBg:stopAllActions()
                        headBg:setPosition(x, y)
                        headBg.anim = false
                        headBg:setScale(1.2)
                    end
                end
            end
            index = index + 1
        end
    end
end

function BattleScene:setCallBack(callback)
    self._callback = callback
end

-- 技能黑屏出现
local names
if lang then
    names = {lang("PLAYERSKILLTAG_1"), lang("PLAYERSKILLTAG_2"), lang("PLAYERSKILLTAG_3"), "", "", "", "", "", 
                    lang("PLAYERSKILLTAG_9")}
end

function BattleScene:enableBlack(skillD)
    if BC.jump then return end
    self._mapLayer:enableBlack()
end

-- 技能黑屏消失
function BattleScene:disableBlack(noAnim)
    if BC.jump then return end
    self._mapLayer:disableBlack(noAnim)
    self._playerCountBg1:setVisible(true)
end

-- 技能黑屏释放技能
function BattleScene:fadeOutBlack()
    if BC.jump then return end
    self._mapLayer:fadeOutBlack()
    self._playerCountBg1:setVisible(true)
end
-- 震动
function BattleScene:shake(type, strong)
    if BC.jump then return end
    if strong == nil then
        strong = 1
    end
    self["shake"..type](self, strong)
end
-- 震动小
function BattleScene:shake1(strong)
    self:frontBlackDisable()
    local scale = self._sceneLayer:getScale() * 0.5 * strong
    self._rootLayer:stopAllActions()
    self._rootLayer:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0))
    ))
end

-- 震动中
function BattleScene:shake2(strong)
    self:frontBlackDisable()
    local scale = self._sceneLayer:getScale() * 0.5 * strong
    self._rootLayer:stopAllActions()
    self._rootLayer:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-12)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-6)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-4)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-6)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-3)), cc.DelayTime:create(0.05),        
        cc.MoveTo:create(0, cc.p(0, 0))
    ))
end

-- 震动大
function BattleScene:shake3(strong)
    self:frontBlackDisable()
    local scale = self._sceneLayer:getScale() * 0.5 * strong
    self._rootLayer:stopAllActions()
    self._rootLayer:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-20)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-15)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-15)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-5)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-7)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-5)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, scale*-3)), cc.DelayTime:create(0.05),
        cc.MoveTo:create(0, cc.p(0, 0))
    ))
end
-- 连续震动
function BattleScene:shake4(strong)
    self:frontBlackDisable()
    local scale = self._sceneLayer:getScale() * 0.2 * strong
    self._rootLayer:stopAllActions()
    self._rootLayer:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0))
    ))
end

-- 连续震动+闪屏
function BattleScene:shake5(strong)
    local scale = self._sceneLayer:getScale() * 0.2 * strong
    self._rootLayer:stopAllActions()
    self._rootLayer:runAction(cc.Sequence:create(
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end),
        cc.MoveTo:create(0, cc.p(0, scale*-10)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, scale*-2)), cc.CallFunc:create(function() self:frontBlackEnable() end), cc.DelayTime:create(0.07),
        cc.MoveTo:create(0, cc.p(0, 0)), cc.CallFunc:create(function() self:frontBlackDisable() end)
    ))
end

function BattleScene:frontBlackEnable()
    self._frontLayer:getView():setVisible(true)
    self._frontLayer:getView():setOpacity(70)
end

function BattleScene:frontBlackDisable()
    self._frontLayer:getView():setVisible(false)
end

function BattleScene:surrender()
    logic:doSurrender()
end

function BattleScene:guideSurrender()
    logic:doSurrender()
    logic:checkWin()
end

-- 弹出玩家技能伤害统计
local psc_PosX1 = 0
local psc_PosX2 = 0
local psc_PosX3 = 0
local psc_PosX4 = 0
local len = string.len
local abs = math.abs
function BattleScene:playerSkillCount(camp, index, sindex, icon, skillD, oldValue, newValue)
    if BC.jump then return end
    local mainCamp = BC.reverse and 2 or 1
    if camp ~= mainCamp then return end
    if newValue == 0 then return end
    if newValue == oldValue then return end
    -- 如果来自不同index 则直接显示最新oldValue, 如果来自相同index, 从oldValue滚动到newValue
    local t
    local playerCountBg = self._playerCountBg1
    local y = playerCountBg:getPositionY()
    local x1 = psc_PosX1
    local x2 = psc_PosX2
    local x3 = -18
    if mainCamp == 2 then
        x1 = psc_PosX3
        x2 = psc_PosX4
        x3 = 18
    end
    playerCountBg.label:setVisible(newValue ~= 0)
    playerCountBg.bright:setVisible(newValue ~= 0)

    if self._PlayerSkillCountIndex1 ~= index then
        playerCountBg:setOpacity(255)
        playerCountBg.icon:loadTexture(IconUtils.iconPath .. icon .. ".png", 1)
        local index = skillD["iff"] - 99
        playerCountBg.pic:loadTexture("playerSkillBg_battle_"..index..".png", 1)
        if sindex >= 0 then
            playerCountBg.kuang:loadTexture("hero_skill_bg4_forma.png", 1)
        else
            if skillD["dazhao"] then
                playerCountBg.kuang:loadTexture("hero_skill_bg1_forma.png", 1)
            elseif skillD["calsstag"] == 3 then
                playerCountBg.kuang:loadTexture("hero_skill_bg3_forma.png", 1)
            else
                playerCountBg.kuang:loadTexture("hero_skill_bg2_forma.png", 1)
            end
        end
        
        if oldValue == 0 then
            playerCountBg.label:setString(abs(newValue))
            playerCountBg.bright:setString(abs(newValue))
        else
            playerCountBg.label:setString(abs(oldValue))
            playerCountBg.bright:setString(abs(oldValue))
            self._playerCountDestValue1 = newValue
        end
        local slen = len(tostring(newValue))
        local scale
        if slen > 4 then
            scale = 1.2 - (slen - 4) * 0.1
        else
            scale = 1.2
        end
        playerCountBg.label:setScale(scale)
        playerCountBg.bright:setScale(scale)
        playerCountBg.label:setOpacity(0)
        playerCountBg.bright:setOpacity(0)
        self._playerCountDestValue1 = newValue
        t = 0.05
    else
        local _x = playerCountBg:getPositionX()
        local dx = x1 - _x
        t = dx / 18 * 0.05
        self._playerCountDestValue1 = newValue
    end
    if newValue > 0 then
        playerCountBg.label:setBMFontFilePath(UIUtils.bmfName_green)
        playerCountBg.bright:setBMFontFilePath(UIUtils.bmfName_green)
    else
        playerCountBg.label:setBMFontFilePath(UIUtils.bmfName_red)
        playerCountBg.bright:setBMFontFilePath(UIUtils.bmfName_red)
    end
    self._playerCountShow1 = true
    playerCountBg.node:stopAllActions()
    playerCountBg:stopAllActions()
    playerCountBg.bright:stopAllActions()
    playerCountBg:runAction(cc.Sequence:create(
                                                 cc.CallFunc:create(function ()
                                                    playerCountBg.label:setOpacity(255)
                                                    playerCountBg.bright:setOpacity(128)
                                                    playerCountBg.node:setScale(1.15)
                                                 end),
                                                 cc.DelayTime:create(0.05),
                                                 cc.CallFunc:create(function ()
                                                    playerCountBg.bright:runAction(cc.FadeOut:create(0.1))
                                                    playerCountBg.node:runAction(cc.ScaleTo:create(0.1, 1.0))
                                                 end),
                                                 cc.DelayTime:create(2.0),
                                                 cc.FadeOut:create(0.1),
                                                 cc.CallFunc:create(function ()
                                                    self._playerCountShow1 = false
                                                 end)
                                ))
    self._PlayerSkillCountIndex1 = index
end

function BattleScene:setPlayerCount(view1)
    self._playerCountBg1 = view1
    psc_PosX1 = 0
    psc_PosX2 = psc_PosX1 - 50
    self._playerCountDestValue1 = 0
    self._playerCountShow1 = false

    -- psc_PosX3 = MAX_SCREEN_WIDTH - 222
    -- psc_PosX4 = psc_PosX3 + 50
    -- self._playerCountDestValue2 = 0
    -- self._playerCountShow2 = false
end

function BattleScene:setAllMpBg(allMpBg)
    self._allMpBg = allMpBg
end

local floor = math.floor
function BattleScene:updatePlayerSkillCount()
    for i = 1, 1 do
        local playerCountBg = self["_playerCountBg"..i]
        if self["_playerCountShow"..i] and playerCountBg.label:isVisible() then
            local curValue = tonumber(playerCountBg.label:getString())
            local playerCountDestValue = self["_playerCountDestValue"..i]
            if playerCountDestValue < 0 then
                curValue = -curValue
            end
            if curValue ~= playerCountDestValue then
                curValue = floor(curValue + (playerCountDestValue - curValue) * 0.5)
                if abs(curValue - playerCountDestValue) < 3 then
                    curValue = playerCountDestValue
                end
                playerCountBg.label:setString(abs(curValue))
                playerCountBg.bright:setString(abs(curValue))
                local slen = len(tostring(curValue))
                local scale
                if slen > 4 then
                    scale = 1.2 - (slen - 4) * 0.1
                else
                    scale = 1.2
                end
                playerCountBg.label:setScale(scale)
                playerCountBg.bright:setScale(scale)
            end
        end
    end
end

function BattleScene:updateStar()
    if self._star == nil then return end
    if logic.battleBeginTick == nil then return end
    if logic.battleState ~= EStateING then return end
    local time = logic.battleTime
    if time > 61 and self._timeLoseStar == nil then
        self._timeLoseStar = true
        self:_decStar()
    end
    if logic.originalDieCount >= 3 and self._dieLoseStar == nil then
        self._dieLoseStar = true
        self:_decStar()
    end
    if logic.originalDieCount < 3 and self._dieLoseStar then
        self._dieLoseStar = nil
        self:_addStar()
    end
end

function BattleScene:_addStar()
    if self._star == nil then return end
    self._star = self._star + 1
    for i = 1, 3 do
        if i <= self._star then
            self["_star"..i]:loadTexture("star_battle.png", 1)
        else
            self["_star"..i]:loadTexture("nostar_battle.png", 1)
        end
    end
end

function BattleScene:_decStar()
    if self._star == nil then return end
    self._star = self._star - 1
    for i = 1, 3 do
        if i <= self._star then
            self["_star"..i]:loadTexture("star_battle.png", 1)
        else
            self["_star"..i]:loadTexture("nostar_battle.png", 1)
        end
    end
end

function BattleScene:_setStar(number)
    self._star = number
    for i = 1, 3 do
        if i <= number then
            self["_star"..i]:loadTexture("star_battle.png", 1)
        else
            self["_star"..i]:loadTexture("nostar_battle.png", 1)
        end
    end
end

function BattleScene:updateTime()
    if logic.battleState == EStateING then
        local time = ceil(self.CountTime - logic.battleTime)
        local str = self._timeLabel:getString()
        local newStr = formatTime(time)
        self._timeLabel:setString(newStr)
        if time <= 30 then
            if not self.hurryUp then
                self._timeLabel:setColor(cc.c3b(255, 0, 0))
                self._timeLabel:enable2Color(1, cc.c4b(255, 0, 0, 255))
                local label = cc.Label:createWithTTF(newStr, UIUtils.ttfName, self._timeLabel:getFontSize())
                label:setColor(cc.c3b(255, 0, 0))
                label:setOpacity(0)
                label:setPosition(self._timeLabel:getContentSize().width * 0.5, self._timeLabel:getContentSize().height * 0.5)
                self._timeLabel:addChild(label)
                self._timeLabel.label = label
                self.hurryUp = true
            end
            if str ~= newStr then
                local label = self._timeLabel.label
                label:setString(newStr)
                label:stopAllActions()
                label:setScale(1)
                label:setOpacity(255)
                label:runAction(cc.Spawn:create(cc.ScaleTo:create(0.5, 2), cc.FadeOut:create(0.5)))
            end
        end
    end
end

function BattleScene:updateOutEnemy()
    if not self.enableOutEnemy then return end
    if logic.battleState ~= EStateING then return end
    local list = logic:getOutOfScreenEnemy()
    local info

    for ID, icon in pairs(self._outEnemy) do
        if list[ID] then
            info = list[ID]
            icon:setVisible(true)
            icon:setFlipX(info[1] < MAX_SCREEN_WIDTH * 0.5)
            icon:setPosition(info[1], info[2])
            list[ID] = nil
        else
            icon:setVisible(false)
        end
    end
    local icon 
    for ID, info in pairs(list) do
        icon = cc.Sprite:createWithSpriteFrameName("enemy_battle.png")
        icon:setFlipX(info[1] < MAX_SCREEN_WIDTH * 0.5)
        icon:setPosition(info[1], info[2])
        icon:setScale(0.8)
        self._uiLayer:addChild(icon, -1)
        self._outEnemy[ID] = icon
    end
end

function BattleScene:clearOutEnemy()
    for ID, icon in pairs(self._outEnemy) do
        icon:setVisible(false)
    end
    self._outEnemy = {}
end

-- 怪兽技能提示
function BattleScene:setSoldierSkillBg(pointer, array)
    self._curSoldierSkillBg = pointer
    self._soldierBgs = array
end

function BattleScene:pushSoldierSkillTip(bgType, iconName1, iconName2, subType, value)
    if BC.jump then return end
    local _x, _y = 0, self._playerCountBg1:getPositionY() - 70
    local yarr = {0, 0, 0, 0}
    for i = 1, 4 do
        yarr[i] = _y - (i - 1) * 66
    end
    local tick = BC.BATTLE_TICK
    local curTip = self._curSoldierSkillBg
    curTip:setVisible(true)
    curTip:setOpacity(255)
    curTip:stopAllActions()
    curTip:setPosition(_x - 80, yarr[1])
    curTip:runAction(cc.Sequence:create(
                        cc.MoveTo:create(0.1, cc.p(_x, yarr[1])),
                        cc.DelayTime:create(2.0),
                        cc.FadeOut:create(0.1)
                    ))
    curTip.index = 1
    curTip.disappearTick = tick + 2

    -- 更新提示板
    for i = 1, 2 do
        if i == bgType then
            curTip["bg"..i]:setVisible(true)
        else
            curTip["bg"..i]:setVisible(false)
        end
    end
    local bg = curTip["bg"..bgType]
    if iconName1 then
        bg.icon1:loadTexture(IconUtils.iconPath .. iconName1..".jpg", 1)
    end
    if iconName2 then
        bg.icon2:loadTexture(IconUtils.iconPath .. iconName2..".jpg", 1) 
    end

    self._curSoldierSkillBg = self._curSoldierSkillBg.next
    local tip = self._curSoldierSkillBg
    for i = 1, 3 do
        tip:stopAllActions()
        if tip.index > 0 then
            tip.index = tip.index + 1
            if tip:getOpacity() > 0 then
                if tip.index == 4 then
                    tip:runAction(cc.Sequence:create(
                                    cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(_x, yarr[tip.index])), cc.FadeOut:create(0.1))
                                ))
                else
                    local t = tip.disappearTick - tick
                    if t < 0 then t = 0 end
                    if t > 2 then t = 2 end
                    tip:runAction(cc.Sequence:create(
                                    cc.MoveTo:create(0.1, cc.p(_x, yarr[tip.index])),
                                    cc.DelayTime:create(t),
                                    cc.FadeOut:create(0.1)
                                ))
                end
            end
        end
        tip = tip.next
    end
end

function BattleScene:siegeBroken()
    if BC.jump then return end
    if self._mapLayer == nil then return end
    self._mapLayer:siegeBroken()
end

function BattleScene:siegeHalf()
    if BC.jump then return end
    if self._mapLayer == nil then return end
    self._mapLayer:siegeHalf()
end

function BattleScene:reflashAudio()
    audioMgr:resumeAll()
    logic:onSceneScale()
end

-- 介绍NPC
function BattleScene:introduceNPC(info, callback)
    if #info[1] < 3 then
        self:introduceHero(info, callback)
        return 
    end
    local id = info[1][1]
    local pos = info[1][2]
    local skillIndex = info[1][3]
    if skillIndex == nil then
        skillIndex = 4
    end
    local team = logic:getTeamByCampAnaId(2, self._battleInfo.intanceD["m"..pos][1])
    local x, y = self:convertToScreenPt(team.x, team.y)
    if team.volume >= 5 then
        y = y + 55
    else
        local _, h = team.soldier[1]:getRealSize()
        y = y + h * 0.5
    end
    viewMgr:guideMaskEnable(x, y, 200, 200)
    viewMgr:_guide_quan(x, y)

    local teamD = tab:Team(id)
    local race = teamD["race"][1]
    ScheduleMgr:delayCall(1000, self, function()
        viewMgr:guideMaskDisable()
        local touchMask = ccui.Layout:create()
        touchMask:setBackGroundColorOpacity(0)
        touchMask:setBackGroundColorType(1)
        touchMask:setBackGroundColor(cc.c3b(0,0,0))
        touchMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        touchMask:setTouchEnabled(false)
        viewMgr:getOtherLayer():addChild(touchMask, 1000)
        -- 介绍UI

        local isQuit = false
        local bgimage = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI11_frame5.png")
        bgimage:setCapInsets(cc.rect(247, 0, 1, 1))
        bgimage:setContentSize(920, 471)
        touchMask:addChild(bgimage)
        bgimage:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5) -- x, y
        bgimage:setScale(0.5)
        bgimage:setOpacity(0)

        local bg = cc.Layer:create()
        bg:setContentSize(995, 486)
        -- bg:setPosition(885 * 0.5, 394 * 0.5)
        bg:setAnchorPoint(0.5, 0.5)
        bg:setScale(0.7)
        bg:setCascadeOpacityEnabled(true)
        bg:setOpacity(0)
        bgimage:addChild(bg, 5)
        bg:setVisible(false)
        bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.14), cc.CallFunc:create(function () bg:setVisible(true) end), cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.FadeTo:create(0.1, 255))))

        bgimage:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.FadeTo:create(0.1, 255)), cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)) ))
        touchMask:addClickEventListener(function (sender)
            if isQuit then return end
            isQuit = true
            bgimage:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, 0), cc.MoveTo:create(0.1, cc.p(x, y))), 
            cc.CallFunc:create(function ()
                touchMask:removeFromParent()
                if self._lihuiName then
                    cc.Director:getInstance():getTextureCache():removeTextureForKey(self._lihuiName)
                    cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/uiother/skillpre/skillpre_"..id..".png")
                    self._lihuiName = nil
                end

                callback()
            end)))
        end)

        touchMask:setTouchEnabled(false)
        ScheduleMgr:delayCall(1000, self, function()
            if isQuit then return end
            touchMask:setTouchEnabled(true)
        end)

        if teamD then
            local centerx = bgimage:getContentSize().width * 0.5
            local centery = bgimage:getContentSize().height * 0.5

            
            local clipNode = ccui.Layout:create()
            clipNode:setContentSize(bgimage:getContentSize().width + 200, 1024)
            clipNode:setPosition(0, 9)
            clipNode:setClippingEnabled(true)
            bgimage:addChild(clipNode)

            local lihui = string.sub(teamD["art1"], 4, string.len(teamD["art1"]))
            self._lihuiName = "asset/uiother/team/t_".. lihui ..".png"

            local cardoffset = teamD["card"]

            local roleSp = cc.Sprite:create(self._lihuiName)
            roleSp:setAnchorPoint(0, 0)
            clipNode:addChild(roleSp)
            local scale = .8
            roleSp:setPosition(217, -202)
            roleSp:setScale(cardoffset[3] * scale)
            roleSp:setVisible(false)
            roleSp:setOpacity(50)
            roleSp:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function () roleSp:setVisible(true) end), cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(217, -152)), cc.FadeTo:create(0.1, 255))))

            -- 阵营
            local raceIcon = cc.Sprite:create("asset/uiother/battle/bg_tt2_"..race.."-HD.png")
            raceIcon:setPosition(120, 360)
            bgimage:addChild(raceIcon)

            -- 左下定位框
            local dingweiIcon = cc.Sprite:createWithSpriteFrameName("v"..teamD["volume"].."_battle.png")
            dingweiIcon:setPosition(780, 90)
            bgimage:addChild(dingweiIcon)  

            local volumeValue = {0, 16, 9, 4, 1, 0}
            local dingweiLabel = cc.Label:createWithTTF("型"..volumeValue[teamD["volume"]].."人兵团", UIUtils.ttfName, 20)
            dingweiLabel:setColor(cc.c3b(140, 96, 35))
            dingweiLabel:setAnchorPoint(0, 0.5)
            dingweiLabel:enableOutline(cc.c4b(236, 221, 178, 255), 2)
            dingweiLabel:setPosition(751, 35)
            bgimage:addChild(dingweiLabel)   
            local colors = 
            {
                cc.c3b(205,32,30),
                cc.c3b(127,102,0),
                cc.c3b(25,123,212),
                cc.c3b(52,123,50),
                cc.c3b(191,30,205),
            }
            local dingweiLabel2 = cc.Label:createWithTTF(lang("CLASS_10"..teamD["class"].."0"), UIUtils.ttfName, 20)
            dingweiLabel2:setColor(colors[teamD["class"]])
            dingweiLabel2:enableOutline(cc.c4b(236, 221, 178, 255), 2)
            dingweiLabel2:setPosition(731, 35)
            bgimage:addChild(dingweiLabel2)   

            local skillyanshi = cc.Label:createWithTTF("技能演示", UIUtils.ttfName, 26)
            skillyanshi:setColor(cc.c3b(63, 45, 35))
            skillyanshi:enableOutline(cc.c4b(236, 221, 178, 255), 2)
            skillyanshi:setPosition(260, 256)
            bgimage:addChild(skillyanshi)

            local line1 = cc.Sprite:createWithSpriteFrameName("globalImageUI12_infoPropmtBg.png")
            line1:setPosition(260, 256)
            line1:setScale(1.2)
            bgimage:addChild(line1)  

            local picName = "asset/uiother/skillpre/skillpre_"..id..".png"
            if not cc.FileUtils:getInstance():isFileExist(picName) then
                picName = "asset/uiother/skillpre/skillpre_103.png"
            end
            local skillpre = cc.Sprite:create(picName)
            skillpre:setScale(.8)
            skillpre:setPosition(260, 140)
            bgimage:addChild(skillpre)

            local tsl = teamD["tsl"]
            if tsl then
                local skillDes = cc.Label:createWithTTF(lang(tsl), UIUtils.ttfName, 18)
                skillDes:setColor(cc.c3b(140, 96, 35))
                skillDes:setPosition(260, 35)
                skillDes:enableOutline(cc.c4b(236, 221, 178, 255), 2)
                bgimage:addChild(skillDes)
            end

            local str = lang(teamD["name"])
            local size
            local len = string.len(str)
            if len == 6 then
                size = 70
            elseif len == 9 then
                size = 62
            elseif len == 12 then
                size = 56
            elseif len == 15 then
                size = 44
            end
            local name = cc.Label:createWithTTF(str, UIUtils.ttfName_Title, size)
            name:setAnchorPoint(0.5, 0.5)
            name:setColor(cc.c3b(63, 45, 35))
            name:enableOutline(cc.c4b(236, 221, 178, 255), 2)
            name:setPosition(300, 360)
            bgimage:addChild(name)

            local englishName = cc.Label:createWithTTF(lang(teamD["ename"]), UIUtils.ttfName_Title, 20)
            englishName:setAnchorPoint(1, 0)
            englishName:setColor(cc.c3b(102, 84, 84))
            englishName:enableOutline(cc.c4b(236, 221, 178, 255), 2)
            bgimage:addChild(englishName)

            local carddes = cc.Label:createWithTTF(lang("CARDDES_"..teamD["carddes"]), UIUtils.ttfName, 24)
            carddes:setColor(cc.c3b(140, 96, 35))
            carddes:enableOutline(cc.c4b(236, 221, 178, 255), 2)
            bgimage:addChild(carddes)

            if len == 6 then
                englishName:setAnchorPoint(0.5, 0)
                name:setPosition(290, 360)
                englishName:setPosition(290, 318 + name:getContentSize().height + 2)
                carddes:setPosition(290, 310)
            elseif len == 9 then
                englishName:setPosition(300 + name:getContentSize().width * 0.5 - 2, 326 + name:getContentSize().height + 2)
                carddes:setPosition(300, 310)
            elseif len == 12 then
                englishName:setPosition(300 + name:getContentSize().width * 0.5 - 2, 330 + name:getContentSize().height + 2)
                carddes:setPosition(300, 310)
            elseif len == 15 then
                name:setPosition(300, 356)
                englishName:setPosition(300 + name:getContentSize().width * 0.5 - 2, 330 + name:getContentSize().height + 2)
                carddes:setPosition(300, 310)
            end

            local carddes = cc.Label:createWithTTF("点击任意位置关闭", UIUtils.ttfName, 20)
            carddes:setColor(cc.c3b(177, 177, 177))
            carddes:setPosition(458, -26)
            bgimage:addChild(carddes)

            local mask = ccui.Layout:create()
            mask:setBackGroundColorOpacity(255)
            mask:setBackGroundColorType(1)
            mask:setBackGroundColor(cc.c3b(0,0,0))
            mask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
            mask:setOpacity(128)
            touchMask:addChild(mask, -10)   

        end
    end)
end

-- 介绍英雄
function BattleScene:introduceHero(info, callback)
    local id = info[1][1]
    local hero = logic:getHero(2)
    local x, y = self:convertToScreenPt(hero.x, hero.y)
    y = y + 30
    viewMgr:guideMaskEnable(x, y, 200, 200)
    viewMgr:_guide_quan(x, y)
    ScheduleMgr:delayCall(1000, self, function()
        viewMgr:guideMaskDisable()
        local touchMask = ccui.Layout:create()
        touchMask:setBackGroundColorOpacity(0)
        touchMask:setBackGroundColorType(1)
        touchMask:setBackGroundColor(cc.c3b(0,0,0))
        touchMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        touchMask:setTouchEnabled(false)
        viewMgr:getRootLayer():addChild(touchMask, 100)
        -- 介绍UI

        local isQuit = false
        local bgimage = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI11_frame5.png")
        bgimage:setCapInsets(cc.rect(247, 0, 1, 1))
        bgimage:setContentSize(920, 471)
        touchMask:addChild(bgimage)
        bgimage:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5) -- x, y
        bgimage:setScale(0.5)

        local bg = cc.Layer:create()
        bg:setContentSize(885, 394)
        -- bg:setPosition(885 * 0.5, 394 * 0.5)
        bg:setAnchorPoint(0.5, 0.5)
        bg:setScale(0.7)
        bg:setCascadeOpacityEnabled(true)
        bg:setOpacity(0)
        bgimage:addChild(bg, 5)
        bg:setVisible(false)
        bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.14), cc.CallFunc:create(function () bg:setVisible(true) end), cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.FadeTo:create(0.1, 255))))

        bgimage:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)))))
        touchMask:addClickEventListener(function (sender)
            if isQuit then return end
            isQuit = true
            bgimage:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, 0), cc.MoveTo:create(0.1, cc.p(x, y))), 
            cc.CallFunc:create(function ()
                touchMask:removeFromParent()
                if self._lihuiName then
                    cc.Director:getInstance():getTextureCache():removeTextureForKey(self._lihuiName)
                    self._lihuiName = nil
                end
                if self._race then
                    cc.Director:getInstance():getTextureCache():removeTextureForKey(self._race)
                    self._race = nil
                end
                callback()
            end)))
        end)

        touchMask:setTouchEnabled(false)
        ScheduleMgr:delayCall(1000, self, function()
            if isQuit then return end
            touchMask:setTouchEnabled(true)
        end)

        local heroD = tab:Hero(id)
        if heroD then
            local centerx = bg:getContentSize().width * 0.5
            local centery = bg:getContentSize().height * 0.5
            self._race = "asset/uiother/battle/bg_tt2_"..heroD["race"].."-HD.png"
            local raceSp = cc.Sprite:create(self._race)
            raceSp:setScale(.75)
            raceSp:setPosition(128, 380)
            bg:addChild(raceSp)
            
            local clipNode = ccui.Layout:create()
            clipNode:setContentSize(bg:getContentSize().width + 25, 1024)
            clipNode:setPositionY(5)
            clipNode:setClippingEnabled(true)
            bgimage:addChild(clipNode)

            self._lihuiName = "asset/uiother/hero/".. heroD["crusadeRes"] ..".png"


            local roleSp = cc.Sprite:create(self._lihuiName)
            roleSp:setAnchorPoint(0.5, 0)
            clipNode:addChild(roleSp)
            local scale = 1.2
            roleSp:setPosition(centerx + 230, -50)
            roleSp:setScale(-scale, scale)
            roleSp:setOpacity(50)
            roleSp:setVisible(false)
            roleSp:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function () roleSp:setVisible(true) end), cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(centerx + 230, 3)), cc.FadeTo:create(0.1, 255))))

            local str = lang(heroD["heroname"])
            local size = 32
            local len = string.len(str)
            if len == 6 then
                size = 56
            elseif len == 9 then
                size = 56
            elseif len == 12 then
                size = 44
            elseif len == 15 then
                size = 32
            end

            local name = cc.Label:createWithTTF(lang(heroD["heroname"]), UIUtils.ttfName, size)
            name:setColor(cc.c3b(60, 42, 30))
            name:enableOutline(cc.c4b(236, 221, 178, 255), 2)
            name:setPosition(260, 370)
            bg:addChild(name, 30)

            local des = cc.Label:createWithTTF("　"..lang(heroD["herodes"]), UIUtils.ttfName, 16)
            des:setColor(cc.c3b(109, 90, 96))
            des:setAnchorPoint(0, 1)
            des:setDimensions(280, 600)
            des:setVerticalAlignment(0)
            des:setPosition(80, 336)
            bg:addChild(des)

            if info[2] then
                local rush = cc.Label:createWithTTF(lang(info[2]), UIUtils.ttfName, 20)
                rush:setColor(cc.c3b(255, 240, 0))
                rush:enableOutline(cc.c4b(81, 19, 0, 255), 2)        
                rush:setPosition(centerx, 32)
                bg:addChild(rush)
            end

            -- 专长
            local sp = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI12_infoPropmtBg.png")
            sp:setCapInsets(cc.rect(90, 14, 1, 1))
            sp:setContentSize(260, 28)
            sp:setScale(1.1)
            sp:setOpacity(153)
            sp:setPosition(216, 250)
            bg:addChild(sp)

            local name = cc.Label:createWithTTF("专长", UIUtils.ttfName, 24)
            name:setColor(cc.c3b(60, 42, 30))
            name:setPosition(216, 250)
            bg:addChild(name)

            local id = tonumber(heroD["special"]..1)
            local heroMasteryD = tab.heroMastery[id]
            local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. heroMasteryD["icon"] .. ".jpg")
            icon:setPosition(216 - 90, 190)
            icon:setScale(0.8)
            bg:addChild(icon)

            local zhuanchang = cc.Sprite:createWithSpriteFrameName("label_specialty_hero.png")
            zhuanchang:setRotation(-45)
            zhuanchang:setPosition(100, 216)
            bg:addChild(zhuanchang)

            local des = cc.Label:createWithTTF(lang("HEROSPECIALDES_"..heroD["special"]), UIUtils.ttfName, 20)
            des:setColor(cc.c3b(128, 90, 28))
            des:setAnchorPoint(0, 1)
            des:setDimensions(180, 600)
            des:setVerticalAlignment(0)
            des:setPosition(170, 202)
            bg:addChild(des)


            local circle = cc.Sprite:createWithSpriteFrameName("globalImageUI4_iquality0.png")
            circle:setPosition(icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5)
            circle:setScale(0.9)
            icon:addChild(circle)

            -- 大招
            local sp = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI12_infoPropmtBg.png")
            sp:setCapInsets(cc.rect(90, 14, 1, 1))
            sp:setContentSize(260, 28)
            sp:setScale(1.1)
            sp:setOpacity(153)
            sp:setPosition(216, 132)
            bg:addChild(sp)

            local name = cc.Label:createWithTTF("技能", UIUtils.ttfName, 24)
            name:setColor(cc.c3b(60, 42, 30))
            name:setPosition(216, 132)
            bg:addChild(name)

            local id = tonumber(heroD["spell"][4])
            local skillD = tab.playerSkillEffect[id]
            local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillD["art"] .. ".png")
            icon:setPosition(216 - 90, 66)
            icon:setScale(0.8)
            bg:addChild(icon)

            local circle = cc.Sprite:createWithSpriteFrameName("skill_bg_battle.png")
            circle:setPosition(icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5)
            circle:setScale(1.2)
            icon:addChild(circle)

            local dazhao = cc.Sprite:createWithSpriteFrameName("final_skill_battle.png")
            dazhao:setPosition(216 - 116, 90)
            dazhao:setScale(.9)
            bg:addChild(dazhao)

            local str = string.gsub(lang("PLAYERSKILLDES4_"..id),"%b[]","")
            str = string.gsub(str,"%b{}","")
            local des = cc.Label:createWithTTF(str, UIUtils.ttfName, 18)
            des:setColor(cc.c3b(128, 90, 28))
            des:setAnchorPoint(0, 1)
            des:setDimensions(180, 600)
            des:setVerticalAlignment(0)
            des:setPosition(170, 104)
            bg:addChild(des)
        end
    end)
end

-- 英雄放大招动画
function BattleScene:heroSkillAnim(camp, skillName, id, heroHeadName, kind, heroID, treasureD)
    if camp == self._HSCamp and skillName == self._HSSkillName then
        return
    end
    self:disableBtns()
    if self._HSAniming == nil then
        self:_heroSkillAnim(camp, skillName, id, heroHeadName, kind, heroID, treasureD)
    else
        self._HSCallback = function ()
            self:_heroSkillAnim(camp, skillName, id, heroHeadName, kind, heroID, treasureD)
            self._HSCallback = nil
        end
    end
end

function BattleScene:isHeroSkillAnim()
    return self._HSAniming
end

function BattleScene:_heroSkillAnim(_camp, skillName, id, heroHeadName, kind, heroID, treasureD)
    if heroID and tab.hero[heroID] and tab.hero[heroID]["soundUpload"] then
        audioMgr:playSoundForce(tab.hero[heroID]["soundUpload"] .. "_0" .. GRandom(4))
    end
    local camp = _camp
    local dirCamp = BC.reverse and 3 - camp or camp
    self._HSCamp = camp
    self._HSSkillName = skillName
    self._HSAniming = true
    if BC.BATTLE_SPEED ~= 0 then
        self._HSSpeed = BC.BATTLE_SPEED
        self:setBattleSpeed(0)
    end
    local touchMask = ccui.Layout:create()
    touchMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    touchMask:setBackGroundColorOpacity(150)
    touchMask:setBackGroundColorType(1)
    touchMask:setBackGroundColor(cc.c3b(0,0,0))
    touchMask:setTouchEnabled(true)
    self._BattleView:addChild(touchMask, 1000)

    local node = cc.Node:create()
    node:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    if dirCamp ~= 1 then
        node:setScaleX(-1)
    end
    touchMask:addChild(node)
    local layer = cc.Node:create()
    if dirCamp ~= 1 then
        layer:setScaleX(-1)
    end
    node:addChild(layer)

    local layer1 = cc.Sprite:createWithSpriteFrameName("dazhao_bg_battle.png")
    layer1:setScale((MAX_SCREEN_WIDTH + 200) / 1022, 1.1)
    if camp == 1 then
        layer1:setColor(cc.c3b(0, 150, 255))
        layer1:setSaturation(45)
        layer1:setBrightness(0)
        layer1:setHue(-4)
    else
        layer1:setColor(cc.c3b(234, 33, 33))
        layer1:setSaturation(26)
        layer1:setBrightness(16)
        layer1:setContrast(24)
        
    end
    if dirCamp == 1 then

    else
        layer1:setAnchorPoint(0, 0.5)
    end
    layer:addChild(layer1)

    layer:setCascadeOpacityEnabled(true)
    if dirCamp == 1 then
        layer:setPositionX(MAX_SCREEN_WIDTH)
        layer:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(0, 0)), cc.FadeIn:create(0.1)), 
                                                cc.DelayTime:create(0.6),
                                                cc.Spawn:create(cc.MoveTo:create(0.15, cc.p(-MAX_SCREEN_WIDTH*0.5, 0)), cc.FadeOut:create(0.15)), 
                                                cc.RemoveSelf:create(true)))
    else
        layer:setPositionX(0)
        layer:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH* 0.5, 0)), cc.FadeIn:create(0.1)), 
                                                cc.DelayTime:create(0.6),
                                                cc.Spawn:create(cc.MoveTo:create(0.15, cc.p(MAX_SCREEN_WIDTH, 0)), cc.FadeOut:create(0.15)), 
                                                cc.RemoveSelf:create(true)))
    end

    local mcName
    if camp == 1 then
        mcName = "lansedi_guochang"
    else
        mcName = "hongsedi_guochang"
    end

    local mc = mcMgr:createViewMC(mcName, false, true)
    mc:setPosition(0, 0)
    mc:setScaleY(.85)
    node:addChild(mc)

    local labelNode = cc.Node:create()
    if dirCamp ~= 1 then
        labelNode:setScale((1 - ((1136 - MAX_SCREEN_WIDTH) / 176 * 0.2))*-1, 1 - ((1136 - MAX_SCREEN_WIDTH) / 176 * 0.2))
    else
        labelNode:setScale(1 - ((1136 - MAX_SCREEN_WIDTH) / 176 * 0.2))
    end

    local fontSize = 110
    local _z = 15
    if treasureD then
        -- 宝物专用
        fontSize = 90
        _z = 15
        local _id = string.sub(tostring(treasureD["addattr"][1][2]), 1, 5)
        local label = cc.Sprite:create("asset/uiother/battle/bn_" .. _id .. ".png")
        label:setScale(.75)
        if camp == 1 then

        else
            label:setHue(175)
            label:setSaturation(100)
            label:setBrightness(-20)
        end
        labelNode:addChild(label)

        local icon = cc.Sprite:createWithSpriteFrameName(treasureD["art"].."_battle.png")
        icon:setPositionY(50)
        labelNode:addChild(icon, -1)
        label:setPositionY(-42)
    elseif id ~= nil and cc.FileUtils:getInstance():isFileExist("asset/uiother/battle/bn_" .. string.sub(tostring(id), 1, 3) .. ".png") then
        -- 用艺术字
        local label = cc.Sprite:create("asset/uiother/battle/bn_" .. string.sub(tostring(id), 1, 3) .. ".png")
        if camp == 1 then

        else
            label:setHue(175)
            label:setSaturation(100)
            label:setBrightness(-20)
        end
        labelNode:addChild(label)
    else
        -- 程序字
        local label = cc.Label:createWithTTF(skillName, UIUtils.ttfName_Title, fontSize)
        if camp == 1 then
            label:setColor(cc.c3b(60, 216, 231))
        else
            label:setColor(cc.c3b(238, 99, 120))
        end
        labelNode:addChild(label)
    end

    node:addChild(labelNode, _z)



    local w = 512 * labelNode:getScaleY() * 0.5 + 40
    labelNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH * 0.5 - w, 0)), 
                                        cc.MoveTo:create(0.6, cc.p(MAX_SCREEN_WIDTH * 0.5 - w + 20, 0)), 
                                        cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH, 0)), 
                                        cc.RemoveSelf:create(true)))



    if heroHeadName then
        local hero = cc.Sprite:create("asset/uiother/hero/"..heroHeadName .. ".png")
        hero:setAnchorPoint(0, 0)
        local y =  -92
        local x1 = 0
        local x2 = 70 - MAX_SCREEN_WIDTH * 0.5
        local x3 = 50 - MAX_SCREEN_WIDTH * 0.5
        local x4 = -300 - MAX_SCREEN_WIDTH * 0.5
        hero:setPosition(x1, y)
        node:addChild(hero, 10)
        hero:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(x2, y)), 
                                            cc.MoveTo:create(0.6, cc.p(x3, y)), 
                                            cc.MoveTo:create(0.1, cc.p(x4, y)), 
                                            cc.RemoveSelf:create(true)))
    end

    local mc = mcMgr:createViewMC("tongyongguang_guochang", false, true)
    mc:setPosition(0, 0)
    node:addChild(mc, 15)
    if dirCamp ~= 1 then
        mc:setScaleX(-1)
        if ADOPT_IPHONEX then
            mc:setScaleX(-1.3)
        end 
    else
        if ADOPT_IPHONEX then
            mc:setScaleX(1.3)
        end 
    end
    mc:setScaleY(.85)

    touchMask:runAction(cc.Sequence:create(cc.DelayTime:create(0.9),
                                        cc.CallFunc:create(function ()
                                            self._HSAniming = nil
                                            self._HSCamp = nil
                                            self._HSSkillName = nil
                                            if self._HSCallback then
                                                self:_HSCallback()
                                            else
                                                self:enableBtns()
                                                if self._HSSpeed then
                                                    self:setBattleSpeed(self._HSSpeed)
                                                    self._HSSpeed = nil
                                                else
                                                    self:setBattleSpeed(1)
                                                end
                                            end
                                        end), 
                                        cc.RemoveSelf:create(true)))
end

function BattleScene:addSkillBookPassiveIcon(index, skillId, camp, done, hide)
    if self._skillBookPassiveIcon[camp].init then return end
    local skillTableData = tab.heroMastery[skillId]
    if not skillTableData then return end
    local bg = cc.Sprite:createWithSpriteFrameName("hero_skill_bg4_forma.png")
    if 1 == camp then
        bg:setPosition(85 + (index - 1) * 60, MAX_SCREEN_HEIGHT - 40)
    else
        bg:setPosition(MAX_SCREEN_WIDTH - 85 - (index - 1) * 60, MAX_SCREEN_HEIGHT - 40)
    end
    bg:setScale(0.55)
    bg:setVisible(not (not not hide))
    self._uiLayer:addChild(bg, 1000)

    local icon = ccui.ImageView:create()
    icon:loadTexture(skillTableData.icon .. ".png", 1)
    icon:setScale(0.9)
    icon:setPosition(40, 40)

    registerTouchEvent(icon, function (_, x, y)
        local heroData = logic:getHero(camp)
        if not heroData then return end
        local spTalent = nil
        if 1 == camp then
            spTalent = self._battleInfo.playerInfo.spTalent
        else
            spTalent = self._battleInfo.enemyInfo.spTalent
        end
        local sklevel = heroData.skillBookPassive[1][2]
        local skillLevel = heroData.skillBookPassive[1][3]
        ViewManager:getInstance():showHintView("global.GlobalTipView",{
            tipType = 2, node = icon, id = skillId,
            skillLevel = skillLevel, sklevel = sklevel, posCenter = false, spTalent = spTalent, notAutoClose = true})
    end,  
    function ()
    end, 
    function ()
    end, 
    function ()
    end)
    bg:addChild(icon, -2) 

    self._skillBookPassiveIcon[camp][#self._skillBookPassiveIcon[camp] + 1] = 
    {
        icon = bg,
    }

    self:setSkillBookPassiveIcon(bg, index)

    if done then
        self._skillBookPassiveIcon[camp].init = true
    end
end

-- 增加宝物技能倒计时图标
-- time为持续时间
local pressIcon = false
function BattleScene:addTreasureSkillIcon(treasureid, quality, skillD, level, camp, time)
    local bg = cc.Sprite:createWithSpriteFrameName("globalImageUI4_squality"..quality..".png")

    bg:setPosition(-1000, 0)
    bg:setScale(.45)
    self._uiLayer:addChild(bg, 1000)

    local icon = ccui.ImageView:create()
    icon:loadTexture("treasure_"..treasureid.."_battle.jpg", 1)
    icon:setScale(1.7)
    icon:setPosition(46, 46)

    local cdmask = ccui.Layout:create()
    cdmask:setBackGroundColorOpacity(128)
    cdmask:setPosition(6, bg:getContentSize().height - 8)
    cdmask:setAnchorPoint(0, 1)
    cdmask:setBackGroundColorType(1)
    cdmask:setBackGroundColor(cc.c3b(0,0,0))
    cdmask:setContentSize(bg:getContentSize().width * .85, bg:getContentSize().height * .85)
    bg:addChild(cdmask, -1)

    local downX, downY
    local heroModel = ModelManager:getInstance():getModel("HeroModel")
    registerTouchEvent(icon, function (_, x, y)
        downX = x
        downY = y
        local heroData = heroModel:getHeroData(logic:getHero(camp).ID)
        if heroData == nil then
            heroData = {id = 60102, star = 1}
        end
        viewMgr:showHintView("global.GlobalTipView", { tipType = 2, node = icon, id = skillD["id"], skillType = 1,treasureInfo = {id = treasureid,stage = level}, skillLevel = level,  notAutoClose=true,
            heroData = heroData })
    end, 
    function ()
    end, 
    function ()
    end, 
    function ()
    end)
    bg:addChild(icon, -2) 

    self._treasureIcon[camp][#self._treasureIcon[camp] + 1] = 
    {
        overTick = time * 0.001,
        icon = bg,
        event = icon,
        cdmask = cdmask,
    }
    self._treasureIconDirty[camp] = true
end

function BattleScene:updateTreasureSkillIcon()
    if BC.reverse then
        if self._treasureIconDirty[1] then
            self._treasureIconDirty[1] = false
            local data
            for i = 1, #self._treasureIcon[1] do
                data = self._treasureIcon[1][i]
                if data then
                    data.icon:setPosition(MAX_SCREEN_WIDTH - 35 - (i - 1) * 60, MAX_SCREEN_HEIGHT - 40)
                end
            end
        end
        if self._treasureIconDirty[2] then
            self._treasureIconDirty[2] = false
            local data
            for i = 1, #self._treasureIcon[2] do
                data = self._treasureIcon[2][i]
                if data then
                    data.icon:setPosition(35 + (i - 1) * 60, MAX_SCREEN_HEIGHT - 40)
                end
            end
        end
    else
        if self._treasureIconDirty[1] then
            self._treasureIconDirty[1] = false
            local data
            for i = 1, #self._treasureIcon[1] do
                data = self._treasureIcon[1][i]
                if data then
                    data.icon:setPosition(35 + (i - 1) * 60, MAX_SCREEN_HEIGHT - 40)
                end
            end
        end
        if self._treasureIconDirty[2] then
            self._treasureIconDirty[2] = false
            local data
            for i = 1, #self._treasureIcon[2] do
                data = self._treasureIcon[2][i]
                if data then
                    data.icon:setPosition(MAX_SCREEN_WIDTH - 35 - (i - 1) * 60, MAX_SCREEN_HEIGHT - 40)
                end
            end
        end
    end
    if logic.battleTime then
        for i = 1, 2 do
            for k, data in pairs(self._treasureIcon[i]) do
                data.cdmask:setScaleY(logic.battleTime / data.overTick)
                if data.overTick < logic.battleTime then
                    if pressIcon then
                        data.event:eventUpCallback()
                        pressIcon = false
                    end
                    data.icon:removeFromParent()
                    self._treasureIcon[i][k] = nil
                    self._treasureIconDirty[i] = true
                end
            end
        end
    end
end

function BattleScene:clearTreasureSkillIcon()
    if self._treasureIcon == nil then return end
    -- 宝物技能图标倒计时
    for i = 1, #self._treasureIcon[1] do
        if self._treasureIcon[1][i] then
            self._treasureIcon[1][i].icon:removeFromParent()
        end
    end
    for i = 1, #self._treasureIcon[2] do
        if self._treasureIcon[2][i] then
            self._treasureIcon[2][i].icon:removeFromParent()
        end
    end
    self._treasureIcon = {{}, {}}
    self._treasureIconDirty = {false, false}
end

function BattleScene:getBeginMCDelay()
    return 22 * 0.05
end
-- 解锁技能通用流程
function BattleScene:commonRealBattleBegin()
    if self._dontRealBegin then return end
    if BattleUtils.unLockSkillIndex == nil 
        or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_Training
        or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_Biography 
        or self._battleInfo.isShare then
        local animNode = cc.Node:create()
        self._rootLayer:addChild(animNode)
        self._touchMask:addClickEventListener(function () end)
        if self._camera then
            self._camera:stopAllActions()
        end
        self:initShareUI(function ()
            self:initBattleSkill(function ()
                animNode:runAction(
                    cc.Sequence:create(
                                        cc.CallFunc:create(function ()
                                            self:battleBeginMC()
                                        end), 
                                        cc.DelayTime:create(self:getBeginMCDelay()),
                                        cc.CallFunc:create(function ()
                                            self:battleBegin()
                                        end),
                                        cc.DelayTime:create(0.2),
                                        cc.CallFunc:create(function ()
                                            self._touchMask:removeFromParent()
                                        end),     
                                        cc.CallFunc:create(function ()
                                            if self._camera then
                                                self._camera:stopAllActions()
                                                self._camera:removeFromParent()
                                                self._camera = nil
                                            end
                                            self._follow = true
                                        end),
                                        cc.RemoveSelf:create(true)                     
                                        ))
            end)
        end)
    else
        -- 解锁技能逻辑
        self._touchMask:addClickEventListener(function () end)
        if self._camera then
            self._camera:stopAllActions()
        end
        self:battleBeginMC(true)

        logic:doSkillUnlock(self._BattleView, self._allMpBg, BattleUtils.unLockSkillIndex, function()
            BattleUtils.unLockSkillIndex = nil
            if self._camera then
                self._camera:stopAllActions()
            end
            self:initBattleSkill(function ()
                local animNode = cc.Node:create()
                self._rootLayer:addChild(animNode)
                animNode:runAction(
                    cc.Sequence:create(
                                        cc.CallFunc:create(function ()
                                            self:battleBeginMCEx()
                                            logic:battleBeginMC()
                                        end), 
                                        cc.DelayTime:create(self:getBeginMCDelay()),
                                        cc.CallFunc:create(function ()
                                            self:battleBegin()
                                        end),
                                        cc.DelayTime:create(0.2),
                                        cc.CallFunc:create(function ()
                                            self._touchMask:removeFromParent()
                                        end),     
                                        cc.CallFunc:create(function ()
                                            if self._camera then
                                                self._camera:stopAllActions()
                                                self._camera:removeFromParent()
                                                self._camera = nil
                                            end
                                            self._follow = true
                                        end),
                                        cc.RemoveSelf:create(true)                      
                                        ))
            end)
        end)
    end
end

-- 学院大招提示
function BattleScene:enableMGTip(index)
    if index == 3 then return end
    if self._MGTipNode then
        self._MGTipNode:removeFromParent()
    end
    self._MGTipNode = cc.Node:create()
    local sp = cc.Sprite:createWithSpriteFrameName("dazhao_"..index.."_battle.png")
    self._MGTipNode:addChild(sp)
    sp:setScaleX(4)
    self._MGTipNode:setScale(0.5)
    self._uiLayer:addChild(self._MGTipNode, -1)
    self._MGTipNode:setPosition(MAX_SCREEN_WIDTH * 0.5, 154)
    self._MGTipNode:runAction(cc.ScaleTo:create(0.1, 1))

    local richText = RichTextFactory:create(lang("DAZHAO_"..index), 300, 25)
    richText:formatText()
    richText:setPosition(150 - richText:getRealSize().width * 0.5, 0)
    self._MGTipNode:addChild(richText)
end

function BattleScene:disableMGTip(index)
    if index == 3 then return end
    if self._MGTipNode then
        self._MGTipNode:removeFromParent()
        self._MGTipNode = nil
    end
end

function BattleScene:addManaAnim()
    local mana = mcMgr:createViewMC("huilan_commoncast", false, true)
    mana:setPosition(-26, 13)
    self._manaLabel:addChild(mana)
end

function BattleScene:playSurpriseMC(index)
    local nameTab = {"wy_1_25_67074_jingxiimage.png", "wy_1_23_34969_jingxiimage.png", "wy_1_24_69401_jingxiimage.png", "wy_1_22_37937_jingxiimage.png"}
    local mc = mcMgr:createViewMC("meirixiaojingxi_jingxi", false, true)
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.66)
    self._uiLayer:addChild(mc, 10000)
    mc:getChildren()[6]:getChildren()[1]:setSpriteFrame(nameTab[index[1]])
    mc:getChildren()[5]:getChildren()[1]:setSpriteFrame(nameTab[index[2]])
    mc:getChildren()[4]:getChildren()[1]:setSpriteFrame(nameTab[index[3]])
    mc:getChildren()[3]:getChildren()[1]:setSpriteFrame(nameTab[index[4]])
    local label = cc.Label:createWithTTF(lang("TIP_GLOBAL_SURPRISE"), UIUtils.ttfName, 22)
    label:setColor(cc.c3b(255, 255, 204))
    label:setPositionY(-50)
    mc:addChild(label)
    label:setScale(2)
    label:runAction(cc.ScaleTo:create(0.15, 1.0))
end

function BattleScene:onHUDTypeChange()
    objLayer:onHUDTypeChange()
end

function BattleScene:checkData()
    if logic then
        return logic:checkData()
    end
end

function BattleScene:checkTime()
    if logic then
        return logic:checkTime()
    end
end

function BattleScene.dtor()
    abs = nil
    
    BattleScene = nil
    BC = nil
    cc = nil
    ceil = nil
    
    ECamp = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil
    ENABLE_ADJUST_MAP = nil
    ENABLE_ADJUST_MAP_SCALE = nil
    ENABLE_BATTLE_BEGIN = nil
    EState = nil
    ETeamState = nil
    floor = nil
    GBHU = nil
    insert = nil
    len = nil
    logic = nil
    math = nil
    MAX_SCREEN_HEIGHT = nil
    MAX_SCREEN_WIDTH = nil
    mcMgr = nil
    names = nil
    next = nil
    os = nil
    pairs = nil
    pc = nil
    psc_PosX1 = nil
    psc_PosX2 = nil
    psc_PosX3 = nil
    psc_PosX4 = nil
    removebyvalue = nil
    selectRoleTick = nil
    tab = nil
    table = nil
    tonumber = nil
    tostring = nil
    viewMgr = nil
    delayCall = nil
    objLayer = nil
    pressIcon = nil
    ruleTabs = nil
    EStateREADY = nil
    weatherOpen = nil
    _updateBeginTick = nil
    _updateBeginTime = nil
    gettime = nil
    ETeamStateDIE = nil
    _BattleUtils = nil
end

return BattleScene
