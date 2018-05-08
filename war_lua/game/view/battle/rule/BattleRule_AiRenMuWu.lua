--[[
    Filename:    BattleRule_AiRenMuWu.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-10-22 17:44:18
    Description: File description
--]]

-- 矮人木屋
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

local objLayer, logic
local delayCall = BC.DelayCall.dc

local SRData = BattleUtils.SRData

local rule = {}
function rule.init()
local BattleScene = require("game.view.battle.display.BattleScene")

local INTO_SPEED = 120
local INTO_DIS = 250
local MAX_SKILL_COUNT = 7
local INTO_SPEED_2 = 300
local INTO_DIS_2 = 900
local DIS = {300, 0, 400, 600}
-- 重生延迟
local REVIVE_TIME = 4
-- 普通矮人ID
local AIREN_COMMON_ID = 79001
-- 金矮人ID
local AIREN_GOLD_ID = 79002
-- 金矮人出现概率25%
local PRO_AIREN_GOLD = 2500
-- 回蓝矮人出现概率3%
local PRO_AIREN_BLUE = 300
-- 全局蓝耗
-- local MANA_PRO = 0.5
-- 全局减CD
local CD_PRO = 0.5
-- 英雄法术2.0
local SKILL_PRO = 2.0
-- 回蓝矮人BUFF
local BUFFID_BLUE = 4999
-- 游戏时间
local COUNT_TIME = 90

local LEVEL = BC.PLAYER_LEVEL[1]

-- 一条血的权值
local hpOneValue = 20
local hpPics = {
                "hpBar1_1_battle.png",
                "hpBar1_2_battle.png",
                "hpBar1_3_battle.png",
                }
local hpColors = {
                cc.c3b(255, 193, 193),
                cc.c3b(253, 222, 194),   
                cc.c3b(255, 255, 179),
                }
local fg
local uiLayer
local manaLabel
local jinbiIcon
local countLabel3
function BattleScene:initBattleUIEx()
    self._maxDamage = self._battleInfo.playerInfo.maxDamage or 0

    self._exLayer = self._BattleView:createLayer("battle.BattleLayerAiRenMuWu")
    self._uiLayer:addChild(self._exLayer, 10)
    uiLayer = self._uiLayer
    manaLabel = self._manaLabel
    self._BattleView:getUI("uiLayer.topLayer.timeBg"):setVisible(false)
    self._BattleView:getUI("uiLayer.topLayer.timeLabel"):setPositionY(33)
    COUNT_TIME = COUNT_TIME + self._battleInfo.exBattleTime

    self.CountTime = COUNT_TIME

    self._proBar1 = self._BattleView:getUI("uiLayer.topLayer.pro1")
    self._proBar2 = self._BattleView:getUI("uiLayer.topLayer.pro2")
    self._proBar1:loadTexture("hpBar1_battle.png", 1)

    self._countLabel1 = self._exLayer:getUI("bg2.countBg1.countLabel1")
    -- self._countLabel1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._countLabel1:setString("0")

    self._countLabel2 = self._exLayer:getUI("bg2.countBg2.countLabel2")
    -- self._countLabel2:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._countLabel2:setString("0")
    
    self._countLabel3 = self._exLayer:getUI("bg2.countBg3.countLabel3")
    -- self._countLabel3:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._countLabel3:setString("0")
    countLabel3 = self._countLabel3
    jinbiIcon = self._exLayer:getUI("bg2.countBg3.icon")

    self._damageLabel1 = self._exLayer:getUI("bg2.countBg1.damageLabel1")
    self._damageLabel1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._exLayer:getUI("bg2.countBg2.damageLabel2"):enableOutline(cc.c4b(0, 0, 0, 255), 1)

    self._maxDamageLabel = self._exLayer:getUI("bg2.countBg1.maxDamageLabel")
    self._maxDamageLabel:setColor(cc.c3b(214, 146, 47))
    self._maxDamageLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._maxDamageLabel:setString("最高纪录:" .. self._maxDamage)

    self._recordPic = cc.Sprite:createWithSpriteFrameName("globalImg_newRecord.png")
    self._recordPic:setPosition(90, 73)
    self._recordPic:setScale(0.8)
    self._recordPic:setVisible(false)
    self._exLayer:getUI("bg2.countBg1"):addChild(self._recordPic)

    self._recordAni = mcMgr:createViewMC("lishixingao_lishixingao", false, true)
    self._recordAni:setPosition(90, 73)
    self._recordAni:gotoAndStop(1)
    self._recordAni:setVisible(false)
    self._exLayer:getUI("bg2.countBg1"):addChild(self._recordAni)

    self._countBg1 = self._exLayer:getUI("bg2.countBg1")
    self._countBg2 = self._exLayer:getUI("bg2.countBg2")
    self._countBg3 = self._exLayer:getUI("bg2.countBg3")

    local offsetX1 = 252
    local offsetX2 = 260
    if ADOPT_IPHONEX then
        offsetX1 = 190
        offsetX2 = 190
    end 
    self._countBg1:setPositionX(self._countBg1:getPositionX() + offsetX1)
    self._countBg2:setPositionX(self._countBg2:getPositionX() + offsetX1)
    self._countBg3:setPositionX(self._countBg3:getPositionX() + offsetX2)

    local npcD = tab.npc[AIREN_COMMON_ID]
    local art1 = npcD["art1"]
    if npcD["match"] then
        local teamD = tab.team[npcD["match"]]
        art1 = art1 or teamD["art1"]
    end
    local head1 = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. art1..".jpg")
    head1:setScale(.45)
    head1:setPosition(130, 29)
    head1:setSaturation(-100)
    self._exLayer:getUI("bg2.countBg1"):addChild(head1)

    local npcD = tab.npc[AIREN_GOLD_ID]
    local art2 = npcD["art1"]
    if npcD["match"] then
        local teamD = tab.team[npcD["match"]]
        art2 = art2 or teamD["art1"]
    end
    local head2 = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. art2..".jpg")
    head2:setScale(.45)
    head2:setPosition(130, 22)
    head2:setSaturation(-100)
    self._exLayer:getUI("bg2.countBg2"):addChild(head2)

    self._proBar3 = cc.Sprite:create()
    self._proBar3:setAnchorPoint(0, 0)
    self._proBar2:addChild(self._proBar3, -1)
    local proBar4 = cc.Sprite:createWithSpriteFrameName("hpBar1_0_battle.png")
    proBar4:setAnchorPoint(0, 0)
    self._proBar4 = proBar4
    self._proBar2:addChild(proBar4, -2)

    self._countLabel = self._BattleView:getUI("uiLayer.topLayer.countLabel")
    self._countLabel:setVisible(true)
    self._countLabel:setString("x∞")

    fg = self._mapLayer:getFgLayer()

    self._mapNear:setVisible(false)

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
    self._hpUpdateTick = 0

    self:updateMutiHpBar(100)
end

-- 显示HP
function BattleScene:countHPEx()
    local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
    local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
    self._destValue1 = ((hp1 + shp1) / (maxhp1 + maxshp1)) * 100
    self._proBar1:setPercent(self._destValue1)
    self:updateMutiHpBar(100 - logic.damageCount / (logic.oneHpBarValue * 2) * 20)

    local values = {100, 1}
    for i = 1, 2 do
        local label = self["_countLabel"..i]
        local count = tonumber(label:getString())
        if count ~= logic["killCount"..i] then
            if floor(count / values[i]) ~= floor(logic["killCount"..i] / values[i]) then
                local labelEff = cc.Label:createWithTTF(floor(logic["killCount"..i] / values[i]) * values[i], UIUtils.ttfName, 20)
                labelEff:setColor(label:getColor())
                labelEff:setPosition(label:getPosition())
                label:getParent():addChild(labelEff)
                labelEff:setLocalZOrder(100)
                labelEff:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 1.75), cc.Spawn:create(cc.TintTo:create(0.25, cc.c3b(255, 255, 255)), cc.FadeOut:create(0.25), cc.ScaleTo:create(0.25, 3)), cc.RemoveSelf:create(true)))
                
                local mc = mcMgr:createViewMC("jishaguang_airenjisha", false, true)
                mc:setLocalZOrder(50)
                mc:setPosition(label:getPosition())
                label:getParent():addChild(mc)
                
            end
            label:stopAllActions()
            label:setScale(1.3)
            label:runAction(cc.ScaleTo:create(0.04, 1.0))
        end
    	label:setString(logic["killCount"..i])
    end

    if logic["killCount1"] > self._maxDamage and not self._isNewRecord then
        self._isNewRecord = true
        self._recordAni:setVisible(true)
        self._recordPic:setVisible(true)
        self._countLabel1:setColor(cc.c3b(255, 255, 0))
        self._damageLabel1:setColor(cc.c3b(255, 255, 0))
        self._recordAni:play()
    end
end

function BattleScene:updateMutiHpBar(pro)
    local count = ceil(100/hpOneValue)
    local oneBar = hpOneValue
    local a = pro - floor(pro/oneBar)*oneBar -- 余数
    local b = floor(pro/oneBar) -- 除数
    if b == count then
        b = b - 1
        a = oneBar
    end
    self._proBar2:setPercent((a / oneBar) * 100)

    local picIndex = b - floor(b/#hpPics)*#hpPics
    local picName = hpPics[picIndex + 1]
    if picName then
        self._proBar2:loadTexture(picName, 1)
        self._hpShadow2:setColor(hpColors[picIndex + 1])
    end
    picIndex = (b - 1) - floor((b - 1)/#hpPics)*#hpPics
    picName = hpPics[picIndex + 1]
    if picName then
        self._proBar3:setSpriteFrame(picName)
    end
end

-- update
local abs = math.abs
function BattleScene:updateEx(dt)
    local tick = logic.battleTime
    local dest2 = self._proBar2:getPercent()
    if dest2 > self._shadowValue2 then
        self._shadowValue2 = 100
        self._hpShadow2:setPercent(self._shadowValue2)
    end
    if tick > self._hpUpdateTick + 1.0 then
        self._hpUpdateTick = tick
        self._hpAnim1 = false
        self._hpAnim2 = false
    elseif tick > self._hpUpdateTick + 0.8 then
        self._shadowValue1 = self._shadowValue1 + (self._destValue1 - self._shadowValue1) * 0.5
        if dest2 > self._shadowValue2 then
            self._shadowValue2 = 100
        else
            self._shadowValue2 = self._shadowValue2 + (dest2 - self._shadowValue2) * 0.5
        end
        if abs(self._shadowValue1 - self._destValue1) < 1 then
            self._shadowValue1 = self._destValue1
        end
        if abs(self._shadowValue2 - dest2) < 1 then
            self._shadowValue2 = dest2
        end
        self._hpShadow1:setPercent(self._shadowValue1)
        self._hpShadow2:setPercent(self._shadowValue2)
    else
        if not self._hpAnim1 and abs(self._destValue1 - self._shadowValue1) > 5 then
            self._hpAnim1 = true
            self._hpShadow1:setOpacity(255)
            self._hpShadow1:stopAllActions()
            --self._hpShadow1:runAction(cc.FadeTo:create(0.1, 185))
        end
        if not self._hpAnim2 and abs(dest2 - self._shadowValue2) > 5 then
            self._hpAnim2 = true
            self._hpShadow2:setOpacity(255)
            self._hpShadow2:stopAllActions()
            --self._hpShadow2:runAction(cc.FadeTo:create(0.1, 185))
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
    self._follow = false 
    self._camera = cc.Node:create()
    self._rootLayer:addChild(self._camera)
    local dx1 = MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale() + 150
    local _, dy1 = logic:getLeftTeamCenterPoint()
    local dx2 = BC.MAX_SCENE_WIDTH_PIXEL - MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale()
    local dy2 = dy1
    local dx3 = logic.__centerPointX
    local dy3 = dy1
    
    self:screenToPos(0, dy1, false)
    self._animId = ScheduleMgr:regSchedule(1, self, function(self)
        if self._follow1 then
            local x = logic:getLeftTeamCenterPoint()
            self._camera:setPosition(x, dy1)
        end
        if self._follow then
            local x = logic:getLeftTeamCenterPoint()
            self:screenToPos(x, dy1, 0.1)
        elseif self._camera then
            self:screenToPos(self._camera:getPositionX(), self._camera:getPositionY(), 0.2)
        end
    end)
    self._follow1 = true
    logic:goInto(function ()
        logic.battleState = EState.READY
        self._follow1 = false
        self._camera:runAction(cc.Sequence:create(
                                            cc.CallFunc:create(function ()
                                                logic:warnning()
                                            end),
                                            cc.DelayTime:create(0.2),
                                            cc.CallFunc:create(function ()
                                                logic:bossInto1()
                                            end),
                                            cc.DelayTime:create(0.3),
                                            cc.CallFunc:create(function ()
                                                logic:bossInto2()
                                            end),
                                            cc.EaseIn:create(cc.MoveTo:create(0.8, cc.p(dx2 - 100, dy2)), 3),
                                            cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(dx2, dy2)), 3),
                                            cc.DelayTime:create(0.3),
                                            cc.CallFunc:create(function ()
                                                logic:bossInto3()
                                            end),
                                            cc.DelayTime:create(3),
                                            cc.EaseIn:create(cc.MoveTo:create(1.2, cc.p(dx3, dy3)), 3),
                                            cc.CallFunc:create(function ()
                                                self:realBattleBegin(0)
                                            end)
                                            ))
    end)
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
        local dx1 = MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale() + 150
        local _, dy1 = logic:getLeftTeamCenterPoint()
        local dx2 = BC.MAX_SCENE_WIDTH_PIXEL - MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale()
        local dy2 = dy1
        local dx3 = logic.__centerPointX
        local dy3 = dy1

        self._touchMask:addClickEventListener(function () end)
        logic:jumpBattleBeginAnimEx()
        self._frontLayer:getView():stopAllActions()
        self._frontLayer:getView():setOpacity(0)

        self._camera:stopAllActions()
        self._camera:setPosition(dx3, dy3)
        self:screenToPos(dx3, dy3, false)

        self:realBattleBegin()
    end
end

function BattleScene:realBattleBegin()
    self._follow = true
    if BattleUtils.unLockSkillIndex == nil then
        self._touchMask:addClickEventListener(function () end)
        self._camera:stopAllActions()
        self:initBattleSkill(function ()
            self._camera:runAction(
                    cc.Sequence:create(
                        cc.CallFunc:create(function ()
                            self:battleBeginMC()
                        end), 
                        cc.DelayTime:create(22 * 0.05),
                        cc.CallFunc:create(function ()
                            self._countBg1:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg1:getPositionX() - 250, self._countBg1:getPositionY())))
                            self._countBg2:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg2:getPositionX() - 250, self._countBg2:getPositionY())))
                            self._countBg3:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg3:getPositionX() - 250, self._countBg3:getPositionY())))
                            logic:jumpBattleBeginAnimEx()
                            self:battleBegin()
                        end),
                        cc.DelayTime:create(0.2),
                        cc.CallFunc:create(function ()
                            self._touchMask:removeFromParent()
                        end),     
                        cc.CallFunc:create(function ()
                            self._camera:stopAllActions()
                            self._camera:removeFromParent()
                            self._camera = nil
                            self._follow1 = nil
                        end)   
                    )
            )
        end)
    else
        -- 解锁技能逻辑
        self._touchMask:addClickEventListener(function () end)
        self._camera:stopAllActions()
        self:battleBeginMC(true)

        logic:doSkillUnlock(self._BattleView, self._allMpBg, BattleUtils.unLockSkillIndex, function()
            BattleUtils.unLockSkillIndex = nil
            self._camera:stopAllActions()
            self:initBattleSkill(function ()
                self._camera:runAction(
                        cc.Sequence:create(
                            cc.CallFunc:create(function ()
                                self:battleBeginMCEx()
                                logic:battleBeginMC()
                            end), 
                            cc.DelayTime:create(22 * 0.05),
                            cc.CallFunc:create(function ()
                                self._countBg1:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg1:getPositionX() - 250, self._countBg1:getPositionY())))
                                self._countBg2:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg2:getPositionX() - 250, self._countBg2:getPositionY())))
                                self._countBg3:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg3:getPositionX() - 250, self._countBg3:getPositionY())))
                                logic:jumpBattleBeginAnimEx()
                                self:battleBegin()
                            end),
                            cc.DelayTime:create(0.2),
                            cc.CallFunc:create(function ()
                                self._touchMask:removeFromParent()
                            end),     
                            cc.CallFunc:create(function ()
                                self._camera:stopAllActions()
                                self._camera:removeFromParent()
                                self._camera = nil
                                self._follow1 = nil
                            end)   
                        )
                )
            end)
        end)
    end
end

-- 中断开场动画
function BattleScene:battleBeginAnimCancelEx()
    self._follow1 = nil
    if self._camera then
        self._camera:stopAllActions()
        self._camera:removeFromParent()
        self._camera = nil
    end
    ScheduleMgr:unregSchedule(self._animId)
    self._follow = false
end

function BattleScene:onBattleEndEx(res)
    logic.isEnd = true
    ScheduleMgr:unregSchedule(self._animId)
    local v1 = logic.killCount1
    local v2 = logic.killCount2
    if not BATTLE_PROC then
        -- 检查数据
        local v1_1 = 0
        for i = 1, #logic.__killCount1_1 do
            v1_1 = v1_1 + logic.__killCount1_1[i]
        end
        local v1_2 = 0
        for i = 1, #logic.__killCount1_2 do
            v1_2 = v1_2 + (100 - logic.__killCount1_2[i])
        end
        local v2_1 = 0
        for i = 1, #logic.__killCount2_1 do
            v2_1 = v2_1 + logic.__killCount2_1[i]
        end
        local v2_2 = 0
        for i = 1, #logic.__killCount2_2 do
            v2_2 = v2_2 + (100 - logic.__killCount2_2[i])
        end
        if v1 ~= v1_1 or v1 * 3 ~= v1_2 or v1_1 * 3 ~= v1_2 then
            if OS_IS_WINDOWS then
                 ViewManager:getInstance():onLuaError(serialize({111, v1, v1_1, v1_2, logic.__teamCount1}))
            end
            v1 = logic.__teamCount1 * 16
            if v1 > v1_1 or v1 * 3 > v1_2 or v1_1 * 3 ~= v1_2 then
                if OS_IS_WINDOWS then
                     ViewManager:getInstance():onLuaError(serialize({222, v1, v1_1, v1_2, logic.__teamCount1}))
                end
                v1 = 16
            end
        end
        if v2 ~= v2_1 or v2 * 3 ~= v2_2 or v2_1 * 3 ~= v2_2 then
            if OS_IS_WINDOWS then
                 ViewManager:getInstance():onLuaError(serialize({333, v2, v2_1, v2_2, logic.__teamCount2}))
            end
            v2 = logic.__teamCount2
            if v2 ~= v2_1 or v2 * 3 ~= v2_2 then
                if OS_IS_WINDOWS then
                     ViewManager:getInstance():onLuaError(serialize({444, v2, v2_1, v2_2, logic.__teamCount2}))
                end
                v2 = 1
            end
        end
    end
	res["exInfo"] = {killCount1 = v1, killCount2 = v2, id1 = AIREN_COMMON_ID, id2 = AIREN_GOLD_ID}
end

local BattleLogic = require("game.view.battle.logic.BattleLogic")
local BattleTeam = require("game.view.battle.object.BattleTeam")

function BattleLogic:jumpBattleBeginAnimEx()
    self._jsJumpBeginAnim = true

    local team, soldier
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if team.__x then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                soldier:stopMove()
                soldier:setPos(soldier.__x, soldier.__y)
            end
            team.x = team.__x
            team.y = team.__y
        end
    end
    for i = 1, #self._teams[2] do
        team = self._teams[2][i]
        if team.__x then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                soldier:stopMove()
                soldier:setPos(soldier.__x, soldier.__y)
            end
            team.x = team.__x
            team.y = team.__y
        end
    end
    self._heros[1]:stopMove()
    self._heros[1]:setPos(15 * 40, 15 * 40)
    self.battleState = EState.READY
end

local random = BC.ran
local ETeamStateDIE = BC.ETeamState.DIE
local initSoldierBuff = BC.initSoldierBuff 

function BattleLogic:initLogicEx(procBattle)
    logic = BC.logic
    objLayer = BC.objLayer
	-- self:setManaPro(MANA_PRO)

    if BATTLE_PROC then
        COUNT_TIME = COUNT_TIME + self._battleInfo.exBattleTime
    end

    self:setCDPro1(CD_PRO)
    self:setHeroDamagePro(SKILL_PRO)

    -- 矮人最大刷新数, 根据己方出场人数调整
    self._airenMaxCount = #self._teams[1] * 2
    if self._airenMaxCount < 6 then
        self._airenMaxCount = 6
    end
    if self._airenMaxCount > 16 then
        self._airenMaxCount = 16
    end

    self.__centerPointX = self:getLeftTeamCenterPoint()
    local team, soldier
    if not procBattle then
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            -- 初始位置往后挪
            team.__x = team.x
            team.__y = team.y
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                soldier.__x = soldier.x
                soldier.__y = soldier.y
                soldier:setPos(soldier.x - INTO_DIS, soldier.y)
            end
        end
    else
        for i = 1, #self._teams[1] do
            team = self._teams[1][i]
            team.goBack = false
        end
    end

    -- 远程无伤害
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if not team.isMelee then
            for k = 1, #team.soldier do
                team.soldier[k].noDamage = true
            end
        end
    end

    self._heros[1]:setPos(15 * 40 - INTO_DIS, 15 * 40)
    self._heros[1]:moveTo(15 * 40, 15 * 40, INTO_SPEED)


	BC.DIE_EXIST_TIME = REVIVE_TIME - 1
    self.damageCount = 0

    self._goldAiren = {}

    self._blueAirenIds = {}

    self.killCount1 = 0
    self.killCount2 = 0
    if not BATTLE_PROC then
        -- 破修改措施
        self.__killCount1_1 = {}
        self.__killCount1_2 = {}
        self.__killCount2_1 = {}
        self.__killCount2_2 = {}
        self.__killCount1_1_count = GRandom(10) + GRandom(12)
        self.__killCount1_2_count = GRandom(10) + GRandom(12)
        self.__killCount2_1_count = GRandom(10) + GRandom(12)
        self.__killCount2_2_count = GRandom(10) + GRandom(12)
        for i = 1, self.__killCount1_1_count do
            self.__killCount1_1[i] = 0
        end
        for i = 1, self.__killCount1_2_count do
            self.__killCount1_2[i] = 100
        end
        for i = 1, self.__killCount2_1_count do
            self.__killCount2_1[i] = 0
        end
        for i = 1, self.__killCount2_2_count do
            self.__killCount2_2[i] = 100
        end
        self.__teamCount1 = 0
        self.__teamCount2 = 0
    end

	-- 初始12个矮人
	local pos = {4, 8, 12, 16, 3, 7, 11, 15, 2, 6, 10, 14, 1, 5, 9, 13} 
	local revivePos = {1, 5, 9, 13, 1, 5, 9, 13, 1, 5, 9, 13, 1, 5, 9, 13}
	local line = {1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4}
	local npcs = {}
    local all = self._airenMaxCount
    if all < 10 then
        all = 10
    end
	for i = 1, all do
		npcs[i] = {AIREN_COMMON_ID, pos[i]}
	end
    local monster
    local team
    local info
    local x, y

    self._airenCount = 0
    for i = 1, #npcs do
        if i <= 4 then
            monster = npcs[i]
            x, y = BC.getFormationScenePos(monster[2], 2)
            x = x + 200
            team = BattleTeam.new(ECamp.RIGHT)   
            team.revivePos = revivePos[i]
            team.lineIdx = line[i]

            local info = {npcid = AIREN_GOLD_ID, level = LEVEL, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[2], info, x, y)    
            self:_raceCountAdd(2, team.race1, team.race2)
            self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
            self:addTeam(team)     
            -- 原始出场方阵标记
            -- gold.original = true
            team.cantSort = true
            team.airenSummonTeam = nil
            team.pen = false
            self._goldAiren[line[i]] = team
        else
            monster = npcs[i]
            team = BattleTeam.new(ECamp.RIGHT)   
            
            team.revivePos = revivePos[i]
            team.lineIdx = line[i]

            x, y = BC.getFormationScenePos(monster[2], 2)
            x = x + 200
            local info = {npcid = monster[1], level = LEVEL, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[2], info, x, y)    
            self:_raceCountAdd(2, team.race1, team.race2)
            self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
            self:addTeam(team)     
            -- 原始出场方阵标记
            -- team.original = true
            team.cantSort = true
            self._airenCount = self._airenCount + 1
            team._index = self._airenCount
            local soldiers = team.soldier
    		local ran
    		for k = 1, #soldiers do
    			ran = random(10000)
    			if ran < PRO_AIREN_BLUE then
    				self._blueAirenIds[soldiers[k].ID] = true
    		        local buff = initSoldierBuff(BUFFID_BLUE, 1, soldiers[k].caster, soldiers[k])
    	            soldiers[k]:addBuff(buff)
    			end
    		end
        end

        -- 初始位置往后挪
        team.__x = team.x
        team.__y = team.y
        for k = 1, #team.soldier do
            soldier = team.soldier[k]
            soldier.__x = soldier.x
            soldier.__y = soldier.y
            soldier:setPos(soldier.x + INTO_DIS_2 + DIS[line[i]], soldier.y)
        end

    end
    self.oneHpBarValue = self._teams[2][1].maxHP

    if not procBattle then
        self:initMap()
    end

    if SRData then
        local soldier1 = self._teams[2][1].soldier[1]
        local soldier2 = self._teams[2][5].soldier[1]
        SRData[105] = soldier1.atk
        SRData[107] = soldier1.maxHP
        SRData[108] = soldier2.maxHP
    end
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
    self._isClear = true
end

function BattleLogic:initMap()
    local layer = objLayer:getView()

    local sp1 = cc.Sprite:create("asset/map/airenbaowu1/airenbaowu_jin_2.png")
    sp1:setAnchorPoint(1, 0.28)
    sp1:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    sp1:setLocalZOrder(-200)
    sp1:setPosition(2250, 200)
    layer:addChild(sp1)

    local sp2 = cc.Sprite:create("asset/map/airenbaowu1/airenbaowu_jin_3.png")
    sp2:setAnchorPoint(1, 0.3)
    sp2:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    sp2:setLocalZOrder(-320)
    sp2:setPosition(2300, 320)
    layer:addChild(sp2)

    local sp3 = cc.Sprite:create("asset/map/airenbaowu1/airenbaowu_jin_4.png")
    sp3:setAnchorPoint(1, 0.28)
    sp3:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    sp3:setLocalZOrder(-460)
    sp3:setPosition(2350, 460)
    layer:addChild(sp3)
    self._sp3 = sp3

    -- 闪亮小星星
    local starInfo = {
        {1248, 145, 1.2, 3000, 2200, fg},
        {937, 199, 1, 3800, 2200, fg},
        -- {1197, 201, 1, 3700, 2200, fg},
        {1178, 170, 1, 3500, 2200, fg},
        -- {1308, 163, 0.8, 3300, 2200, fg},
        {657, 184, 0.7, 3000, 2200, fg},

        {200, 184, 0.8, 3000, 2200, sp1},
        -- {400, 50, 0.5, 3000, 2200, sp1},
        {100, 222, 0.7, 3000, 2200, sp1},

        {400, 20, 0.7, 3000, 2200, sp2},
        -- {200, 184, 0.9, 3000, 2200, sp2},
        {100, 70, 0.4, 3000, 2200, sp2},

        {200, 40, 0.3, 3000, 2200, sp3},
        -- {500, 100, 0.7, 3000, 2200, sp3},
        {40, 20, 0.4, 3000, 2200, sp3},
    }
    local info
    for i = 1, #starInfo do
        info = starInfo[i]
        self:_addStar(info[1], info[2], info[3], info[4], info[5], info[6])
    end
end

function BattleLogic:_addStar(x, y, scale, timeb, ran, root)
    ScheduleMgr:delayCall(GRandom(5000), self, function ()
        if BC and BC.jump then return end
        if self.isEnd or self._sp3 == nil then return end
        local mc = mcMgr:createViewMC("star_airenjinbi", true, false, function (_, sender)
            if BC.jump then return end
            sender:setVisible(false)
            sender:stop()
            ScheduleMgr:delayCall(timeb + 2000 + GRandom(ran + 2000), self, function ()
                if BC and BC.jump then return end
                if self.isEnd or self._sp3 == nil then return end
                sender:setVisible(true)
                sender:gotoAndPlay(1)
            end)
        end)
        mc:setScale(scale * 0.8)
        mc:setPosition(x, 256 - y)
        root:addChild(mc)
    end)
end

function BattleLogic:_dropGold()
    if BC.jump then return end
    local mc = mcMgr:createViewMC("drop_airenjinbi", false, true)
    mc:setPosition(300, 100)
    self._sp3:addChild(mc)
end

function BattleLogic:BattleBeginEx()

end

-- 进场
function BattleLogic:goInto(callback)
    local allCount = 0
    local count = 0
    for i = 1, #self._teams[1] do
        local team = self._teams[1][i]
        if team.original then
            for k = 1, #team.soldier do
                local soldier = team.soldier[k]
                allCount = allCount + 1
                if not team.walk then
                   soldier:setPos(soldier.x + INTO_DIS, soldier.y)
                   -- soldier:changeMotion(EMotion.BORN)
                   soldier:setVisible(true)
                   count = count + 1
                else
                    soldier:moveTo(soldier.x + INTO_DIS, soldier.y, INTO_SPEED, function ()
                        count = count + 1
                        if count == allCount then
                            callback()
                        end
                    end, true)
                end
            end
        end
    end
    self.battleState = EState.INTO
end

function BattleLogic:bossInto1()
    self:shake(4, 4)
    self:_dropGold()
    ScheduleMgr:delayCall(770, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(4, 4)
        self:_dropGold()
    end)
    ScheduleMgr:delayCall(770 * 2, self, function ()
        if self._jsJumpBeginAnim then return end
        self:shake(4, 4)
        self:_dropGold()
    end)

    for i = 8, 24 do
        ScheduleMgr:delayCall(GRandom((i - 8) * 100), self, function ()
            local mc = mcMgr:createViewMC("drop_airenjinbi", false, true)
            mc:setPosition(i * 100 - 100 + GRandom(200), 100 - GRandom(75))
            mc:setScale((100 + GRandom(50)) * 0.01 * (1 - (GRandom(2) - 1) * 2), (100 + GRandom(50)) * 0.01)
            fg:addChild(mc)
        end)
    end
end

function BattleLogic:bossInto2()
    local team, soldier, dis
    for i = 1, #self._teams[2] do
        team = self._teams[2][i]
        for k = 1, #team.soldier do
            dis = INTO_DIS_2 + DIS[team.lineIdx]
            soldier = team.soldier[k]
            soldier:moveTo(soldier.x - dis, soldier.y, INTO_SPEED_2, nil, true)
        end
    end
end

local EMotionBORN = EMotion.BORN

function BattleLogic:bossInto3()

end

function BattleLogic:warnning()
    local team
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if not team.original then break end
        if team.__x then
            team.x = team.__x
            team.y = team.__y
        end
        objLayer:playEffect_skill1("start_tanhao", team.x, team.y + 75, true, true, 1, 2)
    end
end

function BattleLogic:updateEx()
    local gold 
    for i = 1, #self._goldAiren do
        gold = self._goldAiren[i]
        if not gold.pen and gold.state ~= ETeamStateDIE then
            if gold.x < 2200 then
                gold.pen = true
                objLayer:playEffect_skill1("pen_airenjinbi", gold.x, gold.y + 75, true, true, 1, 3)
                self:_dropGold()
            end
        end
    end
    if self._countLabel3Dest then
        local value = tonumber(countLabel3:getString())
        if math.abs(value - self._countLabel3Dest) < 3 then
            countLabel3:setString(self._countLabel3Dest)
        else
            value = value + (self._countLabel3Dest - value) * 0.5
            countLabel3:setString(math.floor(value))
        end
    end    
end

function BattleLogic:teamAttackOverEx(team)

end

function BattleLogic:onTeamDieEx(team)
	if team.camp == 1 then return end
    local isGold = (team.D["id"] == AIREN_GOLD_ID)
    if not BATTLE_PROC then
        if isGold then
            self.__teamCount2 = self.__teamCount2 + 1
        else
            self.__teamCount1 = self.__teamCount1 + 1
        end
    end
	-- 矮人复活
    if team._index and team._index > self._airenMaxCount then
        return
    end
    local info
    if isGold then
        team.waitRevive = true
    end
    delayCall(REVIVE_TIME, self, function ()
        if team.state ~= ETeamStateDIE then return end
    	local line = team.lineIdx
    	-- print(line)
    	if isGold then
            team.waitRevive = false
    		-- 金矮人死了
    		local common = team.airenSummonTeam
            if common then
			    self:reviveAirenCommon(common)
            elseif self._airenCount < self._airenMaxCount then
                common = BattleTeam.new(ECamp.RIGHT)   
                self._airenCount = self._airenCount + 1
                common._index = self._airenCount
                common.revivePos = team.revivePos
                common.lineIdx = team.lineIdx
                local x, y = BC.getFormationScenePos(team.revivePos, 2)
                x = 2350
                info = {npcid = AIREN_COMMON_ID, level = LEVEL, summon = false}
                BC.initTeamAttr_Npc(common, self._heros[2], info, x, y)    
                self:_raceCountAdd(2, common.race1, common.race2)
                self.classCount[2][common.classLabel] = self.classCount[2][common.classLabel] + 1
                self:addTeam(common)     
                common.cantSort = true
                self:addToUpdateList(common)
            end
			-- print("金矮人死了")
			-- print("复活普通矮人")
    	else
    		-- 普通矮人死了
    		-- print("普通矮人死了")
    		if self._goldAiren[line] == nil or (self._goldAiren[line].state == ETeamStateDIE and not self._goldAiren[line].waitRevive) then
    			-- 可以召唤矮人
		    	local ran = random(10000)
		    	-- print("roll", ran)
		    	if ran <= PRO_AIREN_GOLD then
	    			-- print("复活金矮人")
	    			local gold = self._goldAiren[line]
					self:reviveAirenGold(gold)
					gold.airenSummonTeam = team
                    gold.pen = false
		    	else
		    		-- print("点小, 复活矮人")
					self:reviveAirenCommon(team)
		    	end
		    else
		    	-- print("金矮人已在, 复活矮人")
				self:reviveAirenCommon(team)
			end
		end
		-- print("----------")
		-- local count = 0
		-- for i = 1, #self._teams[2] do
		-- 	if self._teams[2][i].state ~= ETeamStateDIE then
		-- 		count = count + 1
		-- 	end
		-- end
		-- print(count)
    end)
end

function BattleLogic:reviveAirenCommon(team)
    local camp = team.camp
    local volume = team.volume
	local x, y = BC.getFormationScenePos(team.revivePos, camp)
    x = 2150
	self:teamRevive(team, true)
	local soldiers = team.soldier
	local ran
	for i = 1, #soldiers do
		soldiers[i]:setPos(BC.getPosInFormation(x, y, i, volume, camp))
		ran = random(10000)
		if ran <= PRO_AIREN_BLUE then
			self._blueAirenIds[soldiers[i].ID] = true
	        local buff = initSoldierBuff(BUFFID_BLUE, 1, soldiers[i].caster, soldiers[i])
            soldiers[i]:addBuff(buff)
		end
	end
end

function BattleLogic:reviveAirenGold(team)
	local x, y = BC.getFormationScenePos(team.revivePos, team.camp)
    x = 2150
	self:teamRevive(team, true)
	local soldiers = team.soldier
	for i = 1, #soldiers do
		soldiers[i]:setPos(x, y)
	end
end

function BattleLogic:onSoldierDieEx(soldier)
	if soldier.team.camp == 2 then
		if soldier.team.D["id"] == AIREN_GOLD_ID then
			self.killCount2 = self.killCount2 + 1
            if not BATTLE_PROC then
                local index = GRandom(#self.__killCount2_1)
                self.__killCount2_1[index] = self.__killCount2_1[index] + 1
                index = GRandom(#self.__killCount2_2)
                self.__killCount2_2[index] = self.__killCount2_2[index] - 3
            end
		else   
			self.killCount1 = self.killCount1 + 1
            if not BATTLE_PROC then
                local index = GRandom(#self.__killCount1_1)
                self.__killCount1_1[index] = self.__killCount1_1[index] + 1
                index = GRandom(#self.__killCount1_2)
                self.__killCount1_2[index] = self.__killCount1_2[index] - 3
            end
			if self._blueAirenIds[soldier.ID] then


                -- 回30点蓝
                -- delayCall(1.6, self, function ()
                --     self:PlayerMana(30)
                -- end)
                -- self:_playManaEff(soldier.x, soldier.y)
                -- self._blueAirenIds[soldier.ID] = nil

				-- 随机恢复一个法术CD 2秒
                local tick = self.battleTime
                local skillArr = {}
                for i = 1, MAX_SKILL_COUNT do
                    if self._playSkills[1][i] then
                        local skill = self._playSkills[1][i]
                        if skill.castTick > tick then
                            skillArr[#skillArr + 1] = i
                        end
                    end
                end
                if #skillArr > 0 then
                    local res = BC.randomSelect(#skillArr, 1)
                    local index = skillArr[res[1]]
                    local skill = self._playSkills[1][index]
                    skill.castTick = skill.castTick - 2
                    if skill.castTick < tick then
                        skill.castTick = tick
                    end

                    local skillIcon = self._skillIcons[index]
                    if skillIcon ~= nil then 
                        self:_playManaEff(soldier.x, soldier.y, skillIcon)
                    end

                else

                end
                self._blueAirenIds[soldier.ID] = nil
			end
		end
        if GRandom(3) == 1 then
            self:_playJinbiEff(soldier.x, soldier.y)
        end
	end
end

local offsetTab =
{
    {11, 74},
    {39, -5},
    {-42, -4},
    {58, 58},
    {-8, 16},
    {-52, 66},
}
function BattleLogic:_playJinbiEff(x, y)
    if BC.jump then return end
    local ran = GRandom(6)
    local c1, c2 = self.killCount1, self.killCount2
    local __x, __y = offsetTab[ran][1], offsetTab[ran][2]
    local _x, _y = self._control:convertToScreenPt(x, y)
    local drop = mcMgr:createViewMC("jinbi"..ran.."_jingbi", false, true, function ()
        local jinbi = mcMgr:createViewMC("jinbi_jingbi", true)
        jinbi:setPosition(_x + __x, _y + __y)
        uiLayer:addChild(jinbi)
        local pt = jinbiIcon:convertToWorldSpace(cc.p(25, 25))
        jinbi:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveTo:create(0.3, cc.p(pt.x, pt.y)), 2), cc.CallFunc:create(function ()
            jinbi:removeFromParent()
            local guang = mcMgr:createViewMC("jinbizhuangji_jingbi", false, true)
            guang:setPosition(25, 25)
            jinbiIcon:addChild(guang)
            self:_updateGoldNumber(c1, c2)
        end)))
    end)
    drop:setPosition(_x, _y)
    uiLayer:addChild(drop)
end

local kkk = 240000 * (1.2 + 0.013 * LEVEL)
function BattleLogic:_updateGoldNumber(c1, c2)
    local value = kkk * ((2.5 * c1) / (c1 + 1500)) + 500 * math.min(c2, 15)
    self._countLabel3Dest = math.floor(value)
end

function BattleLogic:_playManaEff(x, y, ui)
    if BC.jump then return end
    -- objLayer:playEffect_skill1("die_huilan", x, y, true, true, 1, 2)

    -- local ball = mcMgr:createViewMC("lan_huilan", true)
    -- local _x, _y = self._control:convertToScreenPt(x, y + 10)
    -- ball:setPosition(_x, _y)
    -- ball:setScale(0.5)
    -- uiLayer:addChild(ball)
    -- local pt = manaLabel:convertToWorldSpace(cc.p(-13, 13))
    -- local angle = math.deg(-math.atan((_y - pt.y) / (_x - pt.x)))
    -- if _x - pt.x > 0 then
    --     ball:setRotation(angle + 90)
    -- else
    --     ball:setRotation(180 + angle + 90)
    -- end

    -- ball:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveTo:create(1.5, cc.p(pt.x, pt.y)), 2), cc.CallFunc:create(function ()
    --     ball:removeFromParent()
    --     local mana = mcMgr:createViewMC("huilan_huilan", false, true)
    --     mana:setPosition(-13, 13)
    --     manaLabel:addChild(mana)
    -- end)))
    local mana = mcMgr:createViewMC("huilan_huilan", false, true)
    mana:setPosition(ui.icon:getContentSize().width * 0.5 + 3, ui.icon:getContentSize().height * 0.5 - 15)
    ui.icon:addChild(mana, 9999)
end

function BattleLogic:onHPChangeEx(soldier, change)
    if soldier.team.camp == 1 then return end
    if change < 0 then
        self.damageCount = self.damageCount - change 
    end
end

-- 胜利条件
function BattleLogic:checkWinEx()
    if self._surrender then
        self:surrender(2)
        return true
    end
    -- 己方死干净算输
    if self._HP[1] + self._summonHP[1] + self._reviveCount[1] == 0 then
        self:Win(1)
        return true
    end
    if self.battleTime > COUNT_TIME then
        self:timeUp(1)
        return true
    end
    return false
end

function BattleLogic:setCampBrightnessEx(camp, value)

end

function BattleLogic:isOpenAutoBattleForLeftCamp()
    return true
end

function BattleLogic:isOpenAutoBattleForRightCamp()
    return false
end

end 

function rule.dtor()
    abs = nil--math.abs
    AIREN_COMMON_ID = nil--79001
    AIREN_GOLD_ID = nil--79002
    BattleLogic = nil
    BattleScene = nil
    BattleTeam = nil
    BC = nil--BC
    BUFFID_BLUE = nil--4999
    cc = nil--_G.cc
    CD_PRO = nil--0.5
    ceil = nil--math.ceil
    COUNT_TIME = nil--90
    DIS = nil--{300, 0, 400, 600}
    ECamp = nil--BC.ECamp
    EDirect = nil--BC.EDirect
    EEffFlyType = nil--BC.EEffFlyType
    EMotion = nil--BC.EMotion
    EMotionBORN = nil--EMotion.BORN
    EState = nil--BC.EState
    ETeamState = nil--BC.ETeamState
    ETeamStateDIE = nil--BC.ETeamState.DIE
    fg = nil
    floor = nil--math.floor
    hpOneValue = nil--20
    hpPics = nil
    hpColors = nil--{
    initSoldierBuff = nil--BC.initSoldierBuff 
    INTO_DIS = nil--250
    INTO_DIS_2 = nil--900
    INTO_SPEED = nil--120
    INTO_SPEED_2 = nil--300
    LEVEL = nil--BC.PLAYER_LEVEL
    manaLabel = nil
    math = nil--math
    mcMgr = nil--mcMgr
    next = nil--next
    objLayer = nil
    logic = nil
    os = nil--_G.os
    pairs = nil--pairs
    pc = nil--pc
    PRO_AIREN_BLUE = nil--600
    PRO_AIREN_GOLD = nil--2500
    random = nil--BC.ran
    REVIVE_TIME = nil--4
    rule = nil--{}
    SKILL_PRO = nil--2.0
    tab = nil--tab
    table = nil--table
    tonumber = nil--tonumber
    tostring = nil--tostring
    uiLayer = nil
    jinbiIcon = nil
    countLabel3 = nil
    delayCall = nil
    MAX_SKILL_COUNT = nil
    SRData = nil
end

return rule