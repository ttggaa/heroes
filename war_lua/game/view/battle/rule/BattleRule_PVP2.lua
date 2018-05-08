--[[
    Filename:    BattleRule_PVP2.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-7-18 11:35:01
    Description: File description
--]]

-- 通用PVP2
-- 用于远征和积分联赛
-- 手动放技能
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

    if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_League then
        if not self._battleInfo.isReport and not self._battleInfo.isShare then
            self._countHPPro = true
            self._pauseBtn.lock:setVisible(true)
            self._pauseBtn:setTouchEnabled(false)
            self._speedBtn.lock:setVisible(true)
            self._speedBtn:setTouchEnabled(false)
            self._chatBtn:setVisible(true)
            self._surrenderBtn:setVisible(true)
            local chatBtn = self._chatBtn
            chatBtn.btn1:setTitleText("吹牛")
            chatBtn.btn2:setTitleText("问候")
            chatBtn.btn3:setTitleText("不服")
            chatBtn.btn4:setTitleText("调侃")
            for i = 1, 4 do
                chatBtn["btn"..i]:setTitleFontSize(18)
                chatBtn["btn"..i]:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)
            end
        else
            self._autoBtn:loadTextureNormal("autoBtn_battleSelected.png", 1)
            self._autoBtn.lock:setVisible(true)
            self._autoBtn:setTouchEnabled(false)
        end
    elseif self._battleInfo.mode == BattleUtils.BATTLE_TYPE_MF then
        self._skipBtn:setVisible(true)
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
    if self._countHPPro then
        logic.hpPro1 = self._destValue1
        logic.hpPro2 = self._destValue2
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
    objLayer = BC.objLayer

    if not BATTLE_PROC and not BC.jump then
        if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_League then
            if not self._battleInfo.isReport and not self._battleInfo.isShare then
                -- 积分联赛 AI喊话 托管
                self._surrendered = false
                self._lastSurrenderUpdateTick = 0
                self._lastChatUpdateTick = 0
                self._chatPro = 15
            end
        end
    end
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

function BattleLogic:BattleBeginEx()

end

function BattleLogic:updateEx()
    if not BATTLE_PROC and not BC.jump then
        -- 积分联赛 AI喊话 托管
        if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_League then
            if not self._battleInfo.isReport and not self._battleInfo.isShare then
                if self.battleTime > 5 then
                    local tick = socket.gettime()
                    if not self._surrendered then
                        if tick > self._lastChatUpdateTick then
                            self._lastChatUpdateTick = tick + 1
                            if self.hpPro1 > self.hpPro2 + 50 then
                                if GRandom(100) <= 5 then
                                    self._surrendered = true
                                    self._control:onTuoGuan(true)
                                end
                            else
                                if GRandom(10000) == 1 then
                                    self._surrendered = true
                                    self._control:onTuoGuan(true)
                                end
                            end
                        end
                    end
                    if tick > self._lastChatUpdateTick then
                        self._lastChatUpdateTick = tick + 3 + GRandom(2)
                        if GRandom(100) <= self._chatPro then
                            self._control:onChat(2, lang("CALL_BATTLE_0"..GRandom(4).."_0"..GRandom(3)))
                            -- self._heros[2]:onChat(lang("CALL_BATTLE_0"..GRandom(4).."_0"..GRandom(3)), true)
                            self._chatPro = 3
                        end
                    end
                end
            end
        end
    end
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
    if self._surrender then
        self:surrender(2)
        return true
    end
    if self.battleTime > COUNT_TIME then
        self:timeUp(2)
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