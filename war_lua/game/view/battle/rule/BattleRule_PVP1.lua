--[[
    Filename:    BattleRule_PVP1.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-7-1 16:35:01
    Description: File description
--]]

-- 通用PVP1
-- 用于竞技场和联盟PVP和诸神之战
-- 自动战斗
local BC = BC
local pc = pc
local cc = _G.cc
local os = _G.os
local math = math
local pairs = pairs
local next = next
local tab = tab
local tonumber = tonumber
local tostring = tostring
local table = table
local floor = math.floor
local ceil = math.ceil
local mcMgr = mcMgr


local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType

local logic, objLayer
local delayCall = BC.DelayCall.dc

local rule = {}
function rule.init()

local Y_OFFSET = 30

local BattleScene = require("game.view.battle.display.BattleScene")
local COUNT_TIME = 180

function BattleScene:initBattleUIEx()
    self.CountTime = COUNT_TIME

    self._proBar1 = self._BattleView:getUI("uiLayer.topLayer.pro1")
    self._proBar2 = self._BattleView:getUI("uiLayer.topLayer.pro2")
    if BC.reverse then
        self._proBar1:loadTexture("hpBar2_battle.png", 1)
        self._proBar2:loadTexture("hpBar1_battle.png", 1)
    else
        self._proBar1:loadTexture("hpBar1_battle.png", 1)
        self._proBar2:loadTexture("hpBar2_battle.png", 1)
    end
    
    self._BattleView:getUI("uiLayer.topLayer.timeBg"):setVisible(false)
    self._BattleView:getUI("uiLayer.topLayer.timeLabel"):setPositionY(33)

    -- 竞技场不让点自动战斗
    self._autoBtn:loadTextureNormal("autoBtn_battleSelected.png", 1)
    self._autoBtn.lock:setVisible(true)
    self._autoBtn:setTouchEnabled(false)

    local battleInfo = self._battleInfo
    if not battleInfo.isReport then
        self._pauseBtn.lock:setVisible(true)
        self._pauseBtn:setTouchEnabled(false)
    end

    -- windows 好友切磋，手动战斗
    if OS_IS_WINDOWS then
        if (battleInfo.mode == BattleUtils.BATTLE_TYPE_Arena or battleInfo.mode == BattleUtils.BATTLE_TYPE_ServerArena)
          and battleInfo.isFriend then
                self._autoBtn:loadTextureNormal("autoBtn_battle.png", 1)
                self._autoBtn.lock:setVisible(false)
                self._autoBtn:setTouchEnabled(true)
                self._pauseBtn.lock:setVisible(false)
                self._pauseBtn:setTouchEnabled(true)
        end
    end
    
    if battleInfo.mode == BattleUtils.BATTLE_TYPE_Arena or battleInfo.mode == BattleUtils.BATTLE_TYPE_ServerArena or battleInfo.mode == BattleUtils.BATTLE_TYPE_GloryArena then
        self._skipBtn:setVisible(true)
    elseif battleInfo.mode == BattleUtils.BATTLE_TYPE_GuildPVP then
        -- self._skipBtn:setVisible(true)
    elseif battleInfo.mode == BattleUtils.BATTLE_TYPE_GodWar or battleInfo.mode == BattleUtils.BATTLE_TYPE_CrossGodWar then
        if battleInfo.mode == BattleUtils.BATTLE_TYPE_CrossGodWar then
            self._skipBtn:setVisible(true)
        end
        self._speedBtn.lock:setVisible(true)
        self._speedBtn:setTouchEnabled(false)
        local battleView = self._BattleView
        local name1 = battleView:getUI("uiLayer.topLayer.name1")
        local name2 = battleView:getUI("uiLayer.topLayer.name2")
        name1:enableOutline(cc.c4b(0,0,0,255), 1)
        name2:enableOutline(cc.c4b(0,0,0,255), 1)
        local winloseLayer = battleView:getUI("uiLayer.topLayer.winloseLayer")
        local winlose = battleInfo.winlose
        winloseLayer:setVisible(winlose ~= nil)
        local win1 = battleView:getUI("uiLayer.topLayer.winloseLayer.win3")
        local win2 = battleView:getUI("uiLayer.topLayer.winloseLayer.win2")
        local win3 = battleView:getUI("uiLayer.topLayer.winloseLayer.win1")
        local win4 = battleView:getUI("uiLayer.topLayer.winloseLayer.win6")
        local win5 = battleView:getUI("uiLayer.topLayer.winloseLayer.win5")
        local win6 = battleView:getUI("uiLayer.topLayer.winloseLayer.win4")
        if BC.reverse then
            name1:setString(battleInfo.enemyInfo.name or "")
            name2:setString(battleInfo.playerInfo.name or "")
        else
            name1:setString(battleInfo.playerInfo.name or "")
            name2:setString(battleInfo.enemyInfo.name or "")
        end
        if winlose then
            win1:loadTexture("winlose_"..winlose[1].."_battle.png", 1)
            win2:loadTexture("winlose_"..winlose[2].."_battle.png", 1)
            win3:loadTexture("winlose_"..winlose[3].."_battle.png", 1)
            if winlose[1] == 1 or winlose[1] == 2 then
                win4:loadTexture("winlose_"..(3 - winlose[1]).."_battle.png", 1)
            else
                win4:loadTexture("winlose_"..winlose[1].."_battle.png", 1)
            end
            if winlose[2] == 1 or winlose[2] == 2 then
                win5:loadTexture("winlose_"..(3 - winlose[2]).."_battle.png", 1)
            else
                win5:loadTexture("winlose_"..winlose[2].."_battle.png", 1)
            end
            if winlose[3] == 1 or winlose[3] == 2 then
                win6:loadTexture("winlose_"..(3 - winlose[3]).."_battle.png", 1)
            else
                win6:loadTexture("winlose_"..winlose[3].."_battle.png", 1)
            end
        end
    elseif battleInfo.mode == BattleUtils.BATTLE_TYPE_HeroDuel then
        self._speedBtn.lock:setVisible(true)
        self._speedBtn:setTouchEnabled(false)
--        if battleInfo.isReport then
            self._skipBtn:setVisible(true)
--        end
    end
        
    self._hpShadow1 = ccui.LoadingBar:create("hpBar1_0_battle.png", 1, 100)
    self._hpShadow1:setAnchorPoint(1, 0)
    self._hpShadow1:setScaleX(-1)
    self._hpShadow1:setOpacity(255)
    self._hpShadow1:setColor(BC.reverse and cc.c3b(255, 193, 193) or cc.c3b(206, 232, 255))
    self._proBar1:addChild(self._hpShadow1, -1)

    self._hpShadow2 = ccui.LoadingBar:create("hpBar1_0_battle.png", 1, 100)
    self._hpShadow2:setAnchorPoint(0, 0)
    self._hpShadow2:setOpacity(255)
    self._hpShadow2:setColor(BC.reverse and cc.c3b(206, 232, 255) or cc.c3b(255, 193, 193))
    self._proBar2:addChild(self._hpShadow2, -1)

    self._shadowValue1 = 100
    self._shadowValue2 = 100
    self._destValue1 = 100
    self._destValue2 = 100
    self._hpUpdateTick = 0
end

-- 显示HP
function BattleScene:countHPEx()
    local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
    local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
    self._destValue1 = ((hp1 + shp1) / (maxhp1 + maxshp1)) * 100
    self._destValue2 = ((hp2 + shp2) / (maxhp2 + maxshp2)) * 100
    if BC.reverse then
        self._proBar1:setPercent(self._destValue2)
        self._proBar2:setPercent(self._destValue1)
    else
        self._proBar1:setPercent(self._destValue1)
        self._proBar2:setPercent(self._destValue2)
    end
end

-- update
local abs = math.abs
function BattleScene:updateEx(dt)
    if not BATTLE_PROC then
        local tick = BC.BATTLE_TICK
        if tick > self._hpUpdateTick + 1.0 then
            self._hpUpdateTick = tick
            self._hpAnim1 = false
            self._hpAnim2 = false
        elseif tick > self._hpUpdateTick + 0.8 then
            self._shadowValue1 = self._shadowValue1 + (self._destValue1 - self._shadowValue1) * 0.5
            self._shadowValue2 = self._shadowValue2 + (self._destValue2 - self._shadowValue2) * 0.5
            if abs(self._shadowValue1 - self._destValue1) < 1 then
                self._shadowValue1 = self._destValue1
            end
            if abs(self._shadowValue2 - self._destValue2) < 1 then
                self._shadowValue2 = self._destValue2
            end
            if BC.reverse then
                self._hpShadow1:setPercent(self._shadowValue2)
                self._hpShadow2:setPercent(self._shadowValue1)
            else
                self._hpShadow1:setPercent(self._shadowValue1)
                self._hpShadow2:setPercent(self._shadowValue2)
            end
        else
            if not self._hpAnim1 and abs(self._destValue1 - self._shadowValue1) > 5 then
                self._hpAnim1 = true
                self._hpShadow1:setOpacity(255)
                self._hpShadow1:stopAllActions()
                --self._hpShadow1:runAction(cc.FadeTo:create(0.1, 185))
            end
            if not self._hpAnim2 and abs(self._destValue2 - self._shadowValue2) > 5 then
                self._hpAnim2 = true
                self._hpShadow2:setOpacity(255)
                self._hpShadow2:stopAllActions()
                --self._hpShadow2:runAction(cc.FadeTo:create(0.1, 185))
            end
        end
    end
end

function BattleScene:setOverTime(time)
    self._timeLabel:setString(formatTime(ceil(COUNT_TIME - time)))
end

function BattleScene:playEx()
    self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL, BC.MAX_SCENE_HEIGHT_PIXEL, false)
    self:screenToSize(BC.SCENE_SCALE_INIT)

    -- 禁止操作挡板
    self._touchMask = ccui.Layout:create()
    self._touchMask:setBackGroundColorOpacity(0)
    self._touchMask:setBackGroundColorType(1)
    self._touchMask:setBackGroundColor(cc.c3b(0,0,0))
    self._touchMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._touchMask:setTouchEnabled(true)
    self._touchMask:addClickEventListener(function (sender)
        self:jumpBattleBeginAnim()
    end)
    self._rootLayer:getParent():addChild(self._touchMask)
end

function BattleScene:updateTouchEx()
    return true
end

function BattleScene:onMouseScrollEx()
    return true
end

function BattleScene:onTouchesBeganEx()
    return true
end

function BattleScene:onTouchesMovedEx()
    return true
end

function BattleScene:onTouchesEndedEx()
    return true
end

-- 战斗开始动画
function BattleScene:battleBeginAnimEx()
    -- 黑屏渐变
    self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
        self._frontLayer:getView():setVisible(false)
    end)))
    self._camera = cc.Node:create()
    self._rootLayer:addChild(self._camera)
    local sy = BC.MAX_SCENE_HEIGHT_PIXEL - 200
    local dx1, dy1 = logic:getRightTeamCenterPoint(BC.reverse)
    local dx2, dy2 = logic:getLeftTeamCenterPoint(BC.reverse)
    dy1 = dy1 + Y_OFFSET
    dy2 = dy2 + Y_OFFSET
    self._camera:setPosition(dx1, sy)
    self._animId = ScheduleMgr:regSchedule(1, self, function(self)
        if self._follow then
            local x, y
            if logic.battleBeginTick and logic.battleTime > 3 then
                x, y = logic:getAllTeamCenterPoint(BC.reverse)
                self:screenToPos(x, nil, 0.05)
            else
                x, y = logic:getLeftTeamCenterPoint(BC.reverse)
                y = y + Y_OFFSET
                self:screenToPos(x, nil, 0.1)
            end 
        elseif self._camera then
            self:screenToPos(self._camera:getPositionX(), self._camera:getPositionY(), false)
        end
    end)
    self._camera:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), 
                                        cc.EaseIn:create(cc.MoveTo:create(1.4, cc.p(dx1, dy1)), 2),
                                        cc.DelayTime:create(0.1),
                                        cc.EaseIn:create(cc.MoveTo:create(0.8, cc.p(dx2 + 100, dy2)), 3),
                                        cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(dx2, dy2)), 5),
                                        cc.DelayTime:create(0.2),
                                        cc.CallFunc:create(function ()
                                            self._follow = true 
                                            self:commonRealBattleBegin()
                                        end)
                                        ))

end

-- 战斗开始动画
function BattleScene:battleBeginMCEx()
    audioMgr:playSoundForce("horn")

    local mc = mcMgr:createViewMC("chuihaodonghua_quanjunchuji", false, true)
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 14)
    self._rootLayer:getParent():addChild(mc)
end

--  跳过开场动画
function BattleScene:jumpBattleBeginAnimEx()
    if self._camera then
        self._touchMask:addClickEventListener(function () end)
        self._frontLayer:getView():stopAllActions()
        self._frontLayer:getView():setOpacity(0)
        local dx2, dy2 = logic:getLeftTeamCenterPoint(BC.reverse)
        dy2 = dy2 + Y_OFFSET
        self:screenToPos(dx2, dy2, false)
        self._camera:setPosition(dx2, dy2)
        self._follow = true 
        self:commonRealBattleBegin()
    end
end

-- 中断开场动画
function BattleScene:battleBeginAnimCancelEx()
    if self._camera then
        self._camera:stopAllActions()
        self._camera:removeFromParent()
        self._camera = nil
    end
    ScheduleMgr:unregSchedule(self._animId)
end

function BattleScene:onBattleEndEx(res)
    ScheduleMgr:unregSchedule(self._animId)
end

local BattleLogic = require("game.view.battle.logic.BattleLogic")

function BattleLogic:initLogicEx()
    logic = BC.logic
    if ((self._battleInfo.mode == BattleUtils.BATTLE_TYPE_Arena or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_ServerArena) and not self._battleInfo.isReport) 
       or (self._battleInfo.mode == BattleUtils.BATTLE_TYPE_HeroDuel and not self._battleInfo.isReport) 
        or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_GuildPVP then
        BC.BATTLE_QUIT = false
    end
    objLayer = BC.objLayer
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

function BattleLogic:BattleBeginEx()

end

function BattleLogic:updateEx()

end

function BattleLogic:teamAttackOverEx(team)

end

function BattleLogic:onTeamDieEx(team)

end

function BattleLogic:onSoldierDieEx(soldier)

end

function BattleLogic:onHPChangeEx(soldier, change)

end

-- 胜利条件
function BattleLogic:checkWinEx()
    if self._skip then
        self:skip(1)
        return true
    end
    if self._surrender then
        self:surrender(2)
        return true
    end
    if self.battleTime > COUNT_TIME then
        if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_HeroDuel 
            or self._battleInfo.mode == BattleUtils.BATTLE_TYPE_GodWar then
            local hp1, maxhp1, hp2, maxhp2 = self:getCurHP()
            local shp1, maxshp1, shp2, maxshp2 = self:getSummonHP()
            local pro1 = math.floor(((hp1 + shp1) / (maxhp1 + maxshp1)) * 100)
            local pro2 = math.floor(((hp2 + shp2) / (maxhp2 + maxshp2)) * 100)
            if pro1 == pro2 then
                if hp1 + shp1 == hp2 + shp2 then
                    self:timeUp(2)
                else
                    if hp1 + shp1 > hp2 + shp2 then
                        self:timeUp(1)
                    else
                        self:timeUp(2)
                    end
                end
            else
                if pro1 > pro2 then
                    self:timeUp(1)
                else
                    self:timeUp(2)
                end
            end
        elseif self._battleInfo.mode == BattleUtils.BATTLE_TYPE_CrossGodWar then
            local value1, value2, value3, value4 = logic:getCurHP()
            local v1, v2, v3, v4 = logic:getSummonHP()
            local hp = {value1 + v1, value2 + v2, value3 + v3, value4 + v4}
            local remainHpProp1 = hp[1] / hp[2] * 30
            local remainHpProp2 = hp[3] / hp[4] * 30
            local remainTeamCount1, maxTeamCount1 = logic:getTeamCountInfo(1)
            local remainTeamCount2, maxTeamCount2 = logic:getTeamCountInfo(2)
            local remainTeamProp1 = remainTeamCount1 / maxTeamCount1 * 70
            local remainTeamProp2 = remainTeamCount2 / maxTeamCount2 * 70
            local score1 = remainHpProp1 + remainTeamProp1
            local score2 = remainHpProp2 + remainTeamProp2
            self:timeUp(score1 > score2 and 1 or 2)
        else
            self:timeUp(2)
        end
        return true
    end
    for i = 1, 2 do
        if self._lastTeamCount[i] == 0 and self._reviveCount[i] == 0 then
            self:Win(3 - i)
            return true
        end
    end
    return false
end

function BattleLogic:setCampBrightnessEx(camp, value)

end

function BattleLogic:isOpenAutoBattleForLeftCamp()
    return true
end

function BattleLogic:isOpenAutoBattleForRightCamp()
    return true
end

end 
function rule.dtor()
    BattleLogic = nil
    BattleScene = nil
    BC = nil
    cc = nil
    ceil = nil
    delayCall = nil
    COUNT_TIME = nil
    ECamp = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil
    EState = nil
    ETeamState = nil
    floor = nil
    logic = nil
    objLayer = nil
    math = nil
    mcMgr = nil
    next = nil
    os = nil
    pairs = nil
    pc = nil
    rule = nil
    tab = nil
    table = nil
    tonumber = nil
    tostring = nil
    Y_OFFSET = nil
    abs = nil
end
return rule