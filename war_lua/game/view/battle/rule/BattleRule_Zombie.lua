--[[
    Filename:    BattleRule_Zombie.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-10-24 15:45:31
    Description: File description
--]]

-- 僵尸
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

-- 重生延迟
local REVIVE_TIME = 5

-- 栅栏ID
local ZHALAN_ID = 79013
local ZHALAN_2_ID = 79016

-- 普通僵尸ID
local ZOMBIE_COMMON_ID = 79011
local ZOMBIE_COMMON_2_ID = 79011--79014
-- 炸弹僵尸ID
local ZOMBIE_BOOM_ID = 79012
-- 炸弹僵尸出现概率25%
local PRO_ZOMBIE_BOOM = 2500
-- 冰僵尸出现概率2%
local PRO_ZOMBIE_FREEZE = 200

local BUFFID_BLUE = 4998
local BUFFID_FREEZE = 4997
local BUFFID_LINGHUNLIANJIE = 4996
local SKILL_PRO = 0

local ZOMBIE_RESNAME = {tab.npc[ZOMBIE_COMMON_ID]["art"], tab.npc[ZOMBIE_COMMON_2_ID]["art"]}
local ZHALAN_RESNAME = {tab.npc[ZHALAN_ID]["art"], tab.npc[ZHALAN_2_ID]["art"]}

local LEVEL = BC.PLAYER_LEVEL[1]

-- 游戏时间
local COUNT_TIME = 90

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

local warningLabel
local expIcon
local countLabel3
local uiLayer

local EMotionATTACK = EMotion.ATTACK
local EMotionBORN = EMotion.BORN
local EMotionCAST1 = EMotion.CAST1
local EMotionDIE = EMotion.DIE
function BattleScene:initBattleUIEx()
    self._maxDamage = self._battleInfo.playerInfo.maxDamage or 0

    self._exLayer = self._BattleView:createLayer("battle.BattleLayerZombie")
    self._uiLayer:addChild(self._exLayer, 10)
    uiLayer = self._uiLayer

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

    self._damageNode = self._exLayer:getUI("bg2.countBg2.damageNode")
    self._countLabel2 = self._exLayer:getUI("bg2.countBg2.damageNode.countLabel2")
    -- self._countLabel2:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._countLabel2:setString("0")

    self._countLabel3 = self._exLayer:getUI("bg2.countBg3.countLabel3")
    -- self._countLabel3:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._countLabel3:setString("0")
    countLabel3 = self._countLabel3
    expIcon = self._exLayer:getUI("bg2.countBg3.Image_48")

    self._exLayer:getUI("bg2.countBg1.waveLabel"):enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._damageLabel = self._exLayer:getUI("bg2.countBg2.damageNode.damageLabel")
    self._damageLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)

    self._maxDamageLabel = self._exLayer:getUI("bg2.countBg2.maxDamageLabel")
    self._maxDamageLabel:setColor(cc.c3b(214, 146, 47))
    self._maxDamageLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)

    self._recordPic = cc.Sprite:createWithSpriteFrameName("globalImg_newRecord.png")
    self._recordPic:setPosition(90, 73)
    self._recordPic:setScale(0.8)
    self._recordPic:setVisible(false)
    self._exLayer:getUI("bg2.countBg2"):addChild(self._recordPic)

    self._recordAni = mcMgr:createViewMC("lishixingao_lishixingao", false, true)
    self._recordAni:setPosition(90, 73)
    self._recordAni:gotoAndStop(1)
    self._recordAni:setVisible(false)
    self._exLayer:getUI("bg2.countBg2"):addChild(self._recordAni)

    local maxDamageStr = 0
    if self._maxDamage > 100000000 then
        maxDamageStr = string.format("%.3f", self._maxDamage / 100000000) .. "亿"
	elseif self._maxDamage > 100000 then
        maxDamageStr = string.format("%.1f", self._maxDamage / 10000) .. "万"
	else
		maxDamageStr = tostring(self._maxDamage)
	end
    self._maxDamageLabel:setString("最高纪录:" .. maxDamageStr)

    self._countBg1 = self._exLayer:getUI("bg2.countBg1")
    self._countBg2 = self._exLayer:getUI("bg2.countBg2")
    self._countBg3 = self._exLayer:getUI("bg2.countBg3")

    local offsetX = 204
    if ADOPT_IPHONEX then
        offsetX = 150
    end 
    self._countBg1:setPositionX(self._countBg1:getPositionX() + offsetX)
    self._countBg2:setPositionX(self._countBg2:getPositionX() + offsetX)
    self._countBg3:setPositionX(self._countBg3:getPositionX() + offsetX)

    warningLabel = self._exLayer:getUI("warningLabel")
    warningLabel:setCascadeOpacityEnabled(true)
    warningLabel:setVisible(false)

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

    self:_initFreezeEff()
end

function BattleScene:_initFreezeEff()
    self._freezeIng = false
    
    self._freezeLayer = cc.Node:create()
    self._uiLayer:addChild(self._freezeLayer, -21)
    self._freezeLayer:setVisible(false)

    self._freezeMc = {}
    self._freezeMc[1] = mcMgr:createViewMC("jiebing_jiebing", true, nil, nil, RGBA8888)
    self._freezeMc[1]:setPosition(0, 0)
    self._freezeLayer:addChild(self._freezeMc[1], -1)
    self._freezeMc[1]:addEndCallback(function (_, sender)
        self._freezeIng = false
        self._freezeLayer:setVisible(false)
        self._freezeMc[1]:stop()
        self._freezeMc[2]:stop()
        self._freezeMc[3]:stop()
        self._freezeMc[4]:stop()
    end)
    self._freezeMc[1]:stop()

    self._freezeMc[2] = mcMgr:createViewMC("jiebing_jiebing", true, nil, nil, RGBA8888)
    self._freezeMc[2]:setPosition(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._freezeMc[2]:setScaleX(-1)
    self._freezeMc[2]:setScaleY(-1)
    self._freezeLayer:addChild(self._freezeMc[2], -1)
    self._freezeMc[2]:stop()

    self._freezeMc[3] = mcMgr:createViewMC("jiebing_jiebing", true, nil, nil, RGBA8888)
    self._freezeMc[3]:setScaleX(-1)
    self._freezeMc[3]:setPosition(MAX_SCREEN_WIDTH, 0)
    self._freezeLayer:addChild(self._freezeMc[3], -1)
    self._freezeMc[3]:stop()

    self._freezeMc[4] = mcMgr:createViewMC("jiebing_jiebing", true, nil, nil, RGBA8888)
    self._freezeMc[4]:setPosition(0, MAX_SCREEN_HEIGHT)
    self._freezeMc[4]:setScaleY(-1)
    self._freezeLayer:addChild(self._freezeMc[4], -1)
    self._freezeMc[4]:stop()
end

function BattleScene:_doFreezeEff()
    if BC.jump then return end
    if self._freezeIng then
        for i = 1, 4 do
            self._freezeMc[i]:gotoAndPlay(40)
        end
    else
        self._freezeIng = true
        self._freezeLayer:setVisible(true)
        for i = 1, 4 do
            self._freezeMc[i]:gotoAndPlay(1)
        end
    end
end

-- 显示HP
local format = string.format
function BattleScene:countHPEx()
    local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
    local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
    self._destValue1 = ((hp1 + shp1) / (maxhp1 + maxshp1)) * 100
    self._proBar1:setPercent(self._destValue1)
    self:updateMutiHpBar(100 - logic.damageCount / (logic.oneHpBarValue * 2) * 20)

	self._countLabel1:setString(logic.waveCount)

	if logic.damageCount > 100000000 then
		self._countLabel2:setString(format("%.3f", logic.damageCount / 100000000) .. "亿")
	elseif logic.damageCount > 100000 then
		self._countLabel2:setString(format("%.1f", logic.damageCount / 10000) .. "万")
	else
		self._countLabel2:setString(logic.damageCount)
	end

    if logic.damageCount > self._maxDamage and not self._isNewRecord then
        self._isNewRecord = true
        self._recordAni:setVisible(true)
        self._recordPic:setVisible(true)
        self._countLabel2:setColor(cc.c3b(255, 255, 0))
        self._damageLabel:setColor(cc.c3b(255, 255, 0))
        self._damageNode:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.05, 1.5),
            cc.EaseOut:create(cc.ScaleTo:create(0.1, 1), 3)
        ))
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
    self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(function ()
        self._frontLayer:getView():setVisible(false)
    end)))
    logic:beginAnim1()
    self:screenToSize(BC.SCENE_SCALE_INIT + (BC.MAX_SCENE_SCALE - BC.SCENE_SCALE_INIT) * 0.5)
    self._scale1 = BC.SCENE_SCALE_INIT + (BC.MAX_SCENE_SCALE - BC.SCENE_SCALE_INIT) * 0.5
    self._scale2 = BC.SCENE_SCALE_INIT
    self._nowScale = self._scale1
    self._destScale = self._scale1
    self._camera = cc.Node:create()
    self._rootLayer:addChild(self._camera)
    local sx = MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale()
    local _, sy = logic:getLeftTeamCenterPoint()
    local dx1 = BC.MAX_SCENE_WIDTH_PIXEL - MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale() - 300 - 240
    local dy1 = sy
    local dx2 = sx + 400
    local dy2 = sy
    self._camera:setPosition(sx, sy)
    self._animId = ScheduleMgr:regSchedule(1, self, function(self)
        self:screenToPos(self._camera:getPositionX(), self._camera:getPositionY(), false)
        if self._nowScale ~= self._destScale then
        	self._nowScale = self._nowScale + (self._destScale - self._nowScale) * 0.3
        	if math.abs(self._destScale - self._nowScale) < 0.05 then
        		self._nowScale = self._destScale
        	end
        	self:screenToSize(self._nowScale)
        end
    end)
    self._camera:runAction(cc.Sequence:create(cc.DelayTime:create(32 * 0.05), 
    									cc.CallFunc:create(function ()
    										self:screenToSize(BC.SCENE_SCALE_INIT)
    										self._destScale = self._scale2
    										self:shake(2, 5)
                                            logic:warnning()
    									end),
    									cc.DelayTime:create(0.6), 
                                        cc.EaseIn:create(cc.MoveTo:create(1.4, cc.p(dx1 - 200, dy1)), 3),
                                        cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(dx1, dy1)), 5),
                                        cc.DelayTime:create(0.3),
                                        cc.CallFunc:create(function ()
    										logic:beginAnim2()
    									end),
                                        cc.DelayTime:create(5),
                                        cc.EaseIn:create(cc.MoveTo:create(0.8, cc.p(dx2 + 300, dy2)), 3),
                                        cc.EaseOut:create(cc.MoveTo:create(0.6, cc.p(dx2 + 200, dy2)), 5),
                                        cc.DelayTime:create(0.2),
                                        cc.CallFunc:create(function ()
                                            self:realBattleBegin()
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
        logic:jumpBattleBeginAnimEx()
        self._frontLayer:getView():stopAllActions()
        self._frontLayer:getView():setOpacity(0)
        self:screenToSize(BC.SCENE_SCALE_INIT)
        local sx = MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale()
        local _, sy = logic:getLeftTeamCenterPoint()
        local dx1 = BC.MAX_SCENE_WIDTH_PIXEL - MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale() - 300
        local dy1 = sy
        local dx2 = sx + 400
        local dy2 = sy

        self:screenToPos(dx2 + 200, dy2, false)
        self._camera:setPosition(dx2, dy2)

        self:realBattleBegin()
    end
end

function BattleScene:realBattleBegin()
    if BattleUtils.unLockSkillIndex == nil then
        self._touchMask:addClickEventListener(function () end)
        self._camera:stopAllActions()
        self:initBattleSkill(function ()
            local _, sy = logic:getLeftTeamCenterPoint()
            self._camera:runAction(
                cc.Sequence:create(
                                    cc.CallFunc:create(function ()
                                        self:battleBeginMC()
                                    end), 
                                    cc.DelayTime:create(22 * 0.05),
                                    cc.CallFunc:create(function ()
                                        self._countBg1:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg1:getPositionX() - 200, self._countBg1:getPositionY())))
                                        self._countBg2:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg2:getPositionX() - 200, self._countBg2:getPositionY())))
                                        self._countBg3:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg3:getPositionX() - 200, self._countBg3:getPositionY())))
                                        self:battleBegin()
                                    end),
                                    cc.DelayTime:create(0.2),
                                    cc.CallFunc:create(function ()
                                        self._touchMask:removeFromParent()
                                    end),     
                                    cc.MoveTo:create(5.0, cc.p(BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + 100, sy)),
                                    cc.CallFunc:create(function ()
                                        self._camera:stopAllActions()
                                        self._camera:removeFromParent()
                                        ScheduleMgr:unregSchedule(self._animId)
                                        self._camera = nil
                                    end)                     
                                    ))
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
                local _, sy = logic:getLeftTeamCenterPoint()
                self._camera:runAction(
                    cc.Sequence:create(
                                        cc.CallFunc:create(function ()
                                            self:battleBeginMCEx()
                                            logic:battleBeginMC()
                                        end), 
                                        cc.DelayTime:create(22 * 0.05),
                                        cc.CallFunc:create(function ()
                                            self._countBg1:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg1:getPositionX() - 200, self._countBg1:getPositionY())))
                                            self._countBg2:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg2:getPositionX() - 200, self._countBg2:getPositionY())))
                                            self._countBg3:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg3:getPositionX() - 200, self._countBg3:getPositionY())))
                                            self:battleBegin()
                                        end),
                                        cc.DelayTime:create(0.2),
                                        cc.CallFunc:create(function ()
                                            self._touchMask:removeFromParent()
                                        end),     
                                        cc.MoveTo:create(5.0, cc.p(BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + 100, sy)),
                                        cc.CallFunc:create(function ()
                                            self._camera:stopAllActions()
                                            self._camera:removeFromParent()
                                            ScheduleMgr:unregSchedule(self._animId)
                                            self._camera = nil
                                        end)                     
                                        ))
            end)
        end)
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
    local v1 = logic.killCount1
    local v2 = logic.killCount2
    local v3 = logic.waveCount
    local v4 = logic.damageCount
    if not BATTLE_PROC then
        -- 检查数据
        if logic.__killCount1_1 and logic.__killCount1_2 and logic.__killCount2_1 and logic.__killCount2_2 then
            local v1_1 = 0
            for i = 1, #logic.__killCount1_1 do
                v1_1 = v1_1 + logic.__killCount1_1[i]
            end
            local v1_2 = 0
            for i = 1, #logic.__killCount1_2 do
                v1_2 = v1_2 + (200 - logic.__killCount1_2[i])
            end
            local v2_1 = 0
            for i = 1, #logic.__killCount2_1 do
                v2_1 = v2_1 + logic.__killCount2_1[i]
            end
            local v2_2 = 0
            for i = 1, #logic.__killCount2_2 do
                v2_2 = v2_2 + (200 - logic.__killCount2_2[i])
            end
            if v1 ~= v1_1 or v1 * 5 ~= v1_2 or v1_1 * 5 ~= v1_2 then
                if OS_IS_WINDOWS then
                     ViewManager:getInstance():onLuaError(serialize({11, v1, v1_1, v1_2, logic.__teamCount1}))
                end
                v1 = logic.__teamCount1 * 16
                if v1 > v1_1 or v1 * 5 > v1_2 or v1_1 * 5 ~= v1_2 then
                    if OS_IS_WINDOWS then
                         ViewManager:getInstance():onLuaError(serialize({22, v1, v1_1, v1_2, logic.__teamCount1}))
                    end
                    v1 = 16
                end
            end
            if v2 ~= v2_1 or v2 * 5 ~= v2_2 or v2_1 * 5 ~= v2_2 then
                if OS_IS_WINDOWS then
                     ViewManager:getInstance():onLuaError(serialize({33, v2, v2_1, v2_2, logic.__teamCount2}))
                end
                v2 = logic.__teamCount2
                if v2 ~= v2_1 or v2 * 5 ~= v2_2 then
                    if OS_IS_WINDOWS then
                         ViewManager:getInstance():onLuaError(serialize({44, v2, v2_1, v2_2, logic.__teamCount2}))
                    end
                    v2 = 1
                end
            end   
        end

        if logic.__waveCount_1 and logic.__waveCount_2 and logic.__damageCount_1 and logic.__damageCount_2 then
            local v3_1 = 0
            for i = 1, #logic.__waveCount_1 do
                v3_1 = v3_1 + logic.__waveCount_1[i]
            end
            local v3_2 = 0
            for i = 1, #logic.__waveCount_2 do
                v3_2 = v3_2 + (300 - logic.__waveCount_2[i])
            end
            local v4_1 = 0
            for i = 1, #logic.__damageCount_1 do
                v4_1 = v4_1 + logic.__damageCount_1[i]
            end
            local v4_2 = 0
            for i = 1, #logic.__damageCount_2 do
                v4_2 = v4_2 + (300 - logic.__damageCount_2[i])
            end
            if v3 ~= v3_1 or v3 * 7 ~= v3_2 or v3_1 * 7 ~= v3_2 then
                if OS_IS_WINDOWS then
                     ViewManager:getInstance():onLuaError(serialize({55, v3, v3_1, v3_2}))
                end
                v3 = 2
            end
            if v4 ~= v4_1 or v4 * 7 ~= v4_2 or v4_1 * 7 ~= v4_2 then
                if OS_IS_WINDOWS then
                     ViewManager:getInstance():onLuaError(serialize({66, v4, v4_1, v4_2}))
                end
                v4 = 1000
            end
        end 
       
    end
	res["exInfo"] = {waveCount = v3, damageCount = v4, 
    killCount1 = v1, killCount2 = v2, id1 = ZOMBIE_COMMON_ID, id2 = ZOMBIE_BOOM_ID}
end

local BattleLogic = require("game.view.battle.logic.BattleLogic")
local BattleTeam = require("game.view.battle.object.BattleTeam")

local random = BC.ran
local ETeamStateDIE = ETeamState.DIE
local ETeamStateIDLE = ETeamState.IDLE
local ETeamStateMOVE = ETeamState.MOVE
local initSoldierBuff = BC.initSoldierBuff 

function BattleLogic:jumpBattleBeginAnimEx()
    self._jsJumpBeginAnim = true
    for i = 1, #self._beginAnimMcs do
        self._beginAnimMcs[i]:removeFromParent()
    end

    if self._boomMc then
        self._boomMc:gotoAndStop(self._boomMc:getTotalFrames())
    end

    local team, soldiers
    for i = 1, #self._teams[1] do
        soldiers = self._teams[1][i].soldier
        for k = 1, #soldiers do
            if not soldiers[k].zhalan then
                soldiers[k]:setDirect(1)    
            end
        end
    end

    local team
    for i = 1, #self._teams[2] do
        team = self._teams[2][i]
        for k = 1, #team.soldier do
            team.soldier[k]:setVisible(true)
            if i == 6 then
                if k == 1 then
                    team.soldier[k]:setPos(2100 - 360, 350)
                end
            end
        end
    end

end

--  4  3  2  1
--  8  7  6  5
-- 12 11 10  9
-- 16 15 14 13
function BattleLogic:initLogicEx()
    logic = BC.logic
    objLayer = BC.objLayer

    self:setHeroDamagePro(SKILL_PRO)
    
    if BATTLE_PROC then
        COUNT_TIME = COUNT_TIME + self._battleInfo.exBattleTime
    end

	BC.DIE_EXIST_TIME = REVIVE_TIME - 1

    self.waveCount = 0
    self.damageCount = 0

    self._heros[1]:setPos(17 * 40, 14 * 40)

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
            self.__killCount1_2[i] = 200
        end
        for i = 1, self.__killCount2_1_count do
            self.__killCount2_1[i] = 0
        end
        for i = 1, self.__killCount2_2_count do
            self.__killCount2_2[i] = 200
        end
        self.__teamCount1 = 0
        self.__teamCount2 = 0

        self.__waveCount_1 = {}
        self.__waveCount_2 = {}
        self.__damageCount_1 = {}
        self.__damageCount_2 = {}
        self.__waveCount_1_count = GRandom(10) + GRandom(12)
        self.__waveCount_2_count = GRandom(10) + GRandom(12)
        self.__damageCount_1_count = GRandom(10) + GRandom(12)
        self.__damageCount_2_count = GRandom(10) + GRandom(12)
        for i = 1, self.__waveCount_1_count do
            self.__waveCount_1[i] = 0
        end
        for i = 1, self.__waveCount_2_count do
            self.__waveCount_2[i] = 300
        end
        for i = 1, self.__damageCount_1_count do
            self.__damageCount_1[i] = 0
        end
        for i = 1, self.__damageCount_2_count do
            self.__damageCount_2[i] = 300
        end
    end

	-- 远程单位射程无限
	local team, soldiers
	for i = 1, #self._teams[1] do
		team = self._teams[1][i]
		if not team.isMelee then
			team.attackArea = 99999
			for k = 1, #team.soldier do
				team.soldier[k].caster.paramAdd = 200
			end
		end
		soldiers = team.soldier
		for k = 1, #soldiers do
			soldiers[k]:setDirect(-1)	
		end
	end

	self._building = {}
	local team, info
    local dir = {1, 1, -1, -1, 1, 1, -1, 1, 1, 1}
    local res = {ZHALAN_RESNAME[1], ZHALAN_RESNAME[1], ZHALAN_RESNAME[2], ZHALAN_RESNAME[1], ZHALAN_RESNAME[1],
                ZHALAN_RESNAME[2], ZHALAN_RESNAME[1], ZHALAN_RESNAME[1], ZHALAN_RESNAME[1], ZHALAN_RESNAME[2]}
	local pos = {{1120, 160, 4}, {1120, 230, 3}, {1120, 295, 2}, {1120, 380, 2}, {1120, 460, 1},
                {1150 + 70, 120, 4}, {1160 + 70, 200, 3}, {1160 + 70, 278, 3}, {1160 + 70, 370, 2}, {1160 + 70, 427, 1}}

    local count = 10
    if self._battleInfo.exZhalanCount and self._battleInfo.exZhalanCount == 1 then
        count = 5
    end
    local exHPPro = self._battleInfo.exZhalanHPPro
    local soldier
    local ATTR_HPPro = BC.ATTR_HPPro
	for i = 1, count do
		team = BattleTeam.new(ECamp.LEFT)   
	    info = {npcid = ZHALAN_ID, level = LEVEL, summon = false, number = 1}
	    BC.initTeamAttr_Npc(team, self._heros[1], info, pos[i][1] - 8 + random(16), pos[i][2] + 60, 1, true)    
	    self:_raceCountAdd(1, team.race1, team.race2)
	    self.classCount[1][team.classLabel] = self.classCount[1][team.classLabel] + 1
        team.noHUD = true
	    self:addTeam(team)  
        team.cantSort = true
        soldier = team.soldier[1]
	    self._building[#self._building + 1] = team.soldier[1]
        soldier:changeRes(res[i], true)
        soldier:setDirect(dir[i])
        table.removebyvalue(self._rowTeam[1][team.row], team)
        team.row = pos[i][3]
        table.insert(self._rowTeam[1][team.row], team)

        soldier.baseAttr[ATTR_HPPro] = soldier.baseAttr[ATTR_HPPro] + exHPPro
        soldier.baseSum = nil
        soldier:resetAttr()
        team.radius = 30
        soldier.radius = 30
	end
	for i = 1, #self._building do
		-- local buff = initSoldierBuff(BUFFID_LINGHUNLIANJIE, 1, self._building[i].caster, self._building[i])
  --       self._building[i]:addBuff(buff)
        self._building[i].zhalan = true
        self._building[i].maxDamage = 1
	end
	
	-- 僵尸们
	self._zombie = {}
	self._boom = {}
	self._dieZombie = {}
	self._dieBoom = {}
	self._zombieCount = 0
	self._boomCount = 0
	self._tempCount = 0

	local pos = {4, 8, 12, 16, 3, 7, 11, 15}
	local ran
	for i = 1, #pos do
		self:spawnZombie(1, pos[i], true)
	end
    self.oneHpBarValue = self._teams[2][1].maxHP
	self.waveCount = self.waveCount + 1
    if not BATTLE_PROC then
        self.__waveCount_1[1] = self.__waveCount_1[1] + 1
        self.__waveCount_2[1] = self.__waveCount_2[1] - 7
    end

    if SRData then
        local soldier1 = self._teams[2][1].soldier[1]
        SRData[105] = soldier1.atk
        SRData[107] = soldier1.maxHP
        SRData[108] = soldier1.maxHP
    end
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

local spawnPos = {{4, 3}, {8, 7}, {12, 11}, {16, 15}}
function BattleLogic:BattleBeginEx()
	delayCall(10, self, function ()
		local ran
		for i = 1, #spawnPos do
			self:spawnZombie(1, spawnPos[i][random(2)], false)
		end
		self.waveCount = self.waveCount + 1
        if not BATTLE_PROC then
            self.__waveCount_1[2] = self.__waveCount_1[2] + 1
            self.__waveCount_2[2] = self.__waveCount_2[2] - 7
        end
	end)

	if warningLabel then
		warningLabel:stopAllActions()
		warningLabel:setVisible(true)
		warningLabel:setScale(0.5)
		warningLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.15, 1.0), 
														cc.DelayTime:create(1.0), 
														cc.FadeOut:create(0.5),
														cc.CallFunc:create(function ()
															warningLabel:setVisible(false)
														end)))
	end
end

function BattleLogic:beginAnim1()
    self._beginAnimMcs = {}
	local layer = objLayer:getView()

	local mc = mcMgr:createViewMC("shang_muxuetexiao", false)
    mc:setPosition(260, 440)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc)

    local mc = mcMgr:createViewMC("texiaozuo_muxuetexiao", false, false)
    mc:setPosition(260, 350)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc)
    self._boomMc = mc

	local mc = mcMgr:createViewMC("xia_muxuetexiao", false)
    mc:setPosition(380, 178)
    mc:setScaleX(0.8)
    mc:setScaleY(0.65)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc)

    ScheduleMgr:delayCall(2700, self, function()
        if self._jsJumpBeginAnim then return end
	    local team, soldiers
		for i = 1, #self._teams[1] do
			soldiers = self._teams[1][i].soldier
			for k = 1, #soldiers do
                if not soldiers[k].zhalan then
				    soldiers[k]:setDirect(1)	
                end
			end
		end
    end)

    local team
    for i = 1, #self._teams[2] do
        team = self._teams[2][i]
        for k = 1, #team.soldier do
            team.soldier[k]:setVisible(false)
        end
    end

    local mc = mcMgr:createViewMC("b_muzhuang", false)
    mc:setPosition(860, 575 + 60)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc, -10000)

    local mc = mcMgr:createViewMC("a_muzhuang", false)
    mc:setPosition(980, 570 + 60)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc, -10000)

    local mc = mcMgr:createViewMC("b_muzhuang", false)
    mc:setPosition(1080, 550 + 60)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc, -10000)

    local mc = mcMgr:createViewMC("a_muzhuang", false)
    mc:setPosition(870, 80 + 60)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    mc:setScaleX(-1)
    layer:addChild(mc)

    local mc = mcMgr:createViewMC("b_muzhuang", false)
    mc:setPosition(965, 70 + 60)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc)

    local mc = mcMgr:createViewMC("a_muzhuang", false)
    mc:setPosition(1080, 80 + 60)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc)
end

function BattleLogic:beginAnim2()
	local layer = objLayer:getView()
	self:shake(2, 3)
	local mc = mcMgr:createViewMC("texiaoyou_muxuetexiao", false)
    mc:setPosition(2100 - 360, 350)
    mc:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    layer:addChild(mc)
    self._beginAnimMcs[#self._beginAnimMcs + 1] = mc

    ScheduleMgr:delayCall(2400, self, function()
        if self._jsJumpBeginAnim then return end
    	self:shake(4, 3)
    end)

    local team, ran
    for i = 1, #self._teams[2] do
        team = self._teams[2][i]
        for k = 1, #team.soldier do
            if i == 6 then
                if k == 1 then
                    ran = 0
                    team.soldier[k]:setPos(2100 - 360, 350)
                else
                    ran = 800 + GRandom(1200)
                end
            else
                ran = 2400 + GRandom(1700)
            end
            ScheduleMgr:delayCall(ran, self, function (_, sender)
                if self._jsJumpBeginAnim then return end
                sender:setVisible(true)
                sender:changeMotion(EMotionBORN)
            end, team.soldier[k])
        end
    end
end

function BattleLogic:warnning()
    local team
    for i = 1, #self._teams[1] do
        team = self._teams[1][i]
        if not team.original then break end
        objLayer:playEffect_skill1("start_tanhao", team.x, team.y + 75, true, true, 1, 2)
    end
end

function BattleLogic:updateEx()
	for id, boom in pairs(self._boom) do
        if boom.soldier then
            local soldier = boom.soldier[1]
            if soldier and soldier.targetS and soldier.targetS.zhalan then
                local zhalan = soldier.targetS
                if math.abs(zhalan.x - soldier.x) < 100 then
                    soldier:stopMove()
                    soldier.team:setState(ETeamStateIDLE)
                    soldier.team.attackArea = -1
                    soldier:HPChange(nil, -soldier.HP, false, 1, nil, true)
                    soldier:changeMotion(EMotionCAST1, nil, nil, false, true)
                    delayCall(27 * 0.05, self, function ()
                        soldier:setShadowVisible(false)
                        zhalan:beDamaged(nil, -soldier.atk * 20, false, 6)
                    end)
                end
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
	if team.D["id"] == ZOMBIE_COMMON_ID then
		self._zombie[team.ID] = nil
		delayCall(REVIVE_TIME, self, function ()
			self._dieZombie[team.ID] = team
		end)
		self._zombieCount = self._zombieCount - 1
        if not BATTLE_PROC then
            self.__teamCount1 = self.__teamCount1 + 1
        end
	else
		self._boom[team.ID] = nil
		delayCall(REVIVE_TIME, self, function ()
			self._dieBoom[team.ID] = team
		end)
		self._boomCount = self._boomCount - 1
        if not BATTLE_PROC then
            self.__teamCount2 = self.__teamCount2 + 1
        end
	end
	if self._zombieCount + self._boomCount + self._tempCount < 12 then
		self._tempCount = self._tempCount + 4
		-- 刷新
	    delayCall(REVIVE_TIME - 3, self, function ()
	    	self.waveCount = self.waveCount + 1
            if not BATTLE_PROC then
                local index = GRandom(#self.__waveCount_1)
                self.__waveCount_1[index] = self.__waveCount_1[index] + 1
                index = GRandom(#self.__waveCount_2)
                self.__waveCount_2[index] = self.__waveCount_2[index] - 7
            end

	    	self._tempCount = self._tempCount - 4
	    	local ran
			for i = 1, #spawnPos do
				ran = random(10000)
				if ran <= PRO_ZOMBIE_BOOM then
					self:spawnZombie(2, spawnPos[i][random(2)], false)
				else
					self:spawnZombie(1, spawnPos[i][random(2)], false)
				end
			end
			if not BC.jump and warningLabel then
				warningLabel:stopAllActions()
				warningLabel:setVisible(true)
				warningLabel:setScale(0.5)
				warningLabel:setOpacity(255)
				warningLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.15, 1.0), 
																cc.DelayTime:create(1.0), 
																cc.FadeOut:create(0.5),
																cc.CallFunc:create(function ()
																	warningLabel:setVisible(false)
																end)))
			end
	    end)
	end
end

local getRowIndex = BC.getRowIndex
-- kind 1.普通僵尸, 2.自爆僵尸
function BattleLogic:spawnZombie(kind, pos, init)
	local x, y = BC.getFormationScenePos(pos, ECamp.RIGHT)
	x = x - 10
	local id, team
	if kind == 1 then
		id, team = next(self._dieZombie)
		if team == nil then
			team = BattleTeam.new(ECamp.RIGHT)   

		    local info = {npcid = ZOMBIE_COMMON_ID, level = LEVEL, summon = false}
		    BC.initTeamAttr_Npc(team, self._heros[2], info, x, y)    
		    self:_raceCountAdd(2, team.race1, team.race2)
		    self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
		    self:addTeam(team)     
		    -- 原始出场方阵标记
		    -- team.original = true
		    team.cantSort = true
		    team.goBack = false
		    team.turnFire = false
            team.__attackArea = team.attackArea
			self._zombie[team.ID] = team
			if not init then
				self:addToUpdateList(team)
			end
		else
			self:teamRevive(team, true)
			local newRow = getRowIndex(y)
			if newRow ~= team.row then
				table.removebyvalue(self._rowTeam[2][team.row], team)
        		team.row = newRow
        		table.insert(self._rowTeam[2][team.row], team)
        	end
			self._dieZombie[id] = nil
			self._zombie[id] = team
		end
		local ran
        local _x, _y
		local soldiers = team.soldier
		for i = 1, #soldiers do
            _x = - 80 + random(160)
            _y = - 50 + random(100)
            soldiers[i]:setPos(x + _x, y + _y)
            soldiers[i]:setOffsetPos(_x, _y)
            if not init then
    			ran = random(10000)
    			if ran <= PRO_ZOMBIE_FREEZE then
    				soldiers[i].freeze = true
    				local buff = initSoldierBuff(BUFFID_BLUE, 1, soldiers[i].caster, soldiers[i])
    	            soldiers[i]:addBuff(buff)
    			end
            end
            if i > 1 then
			    soldiers[i]:changeRes(ZOMBIE_RESNAME[GRandom(#ZOMBIE_RESNAME)], true)
            end
		end
		self._zombieCount = self._zombieCount + 1
	elseif kind == 2 then
		id, team = next(self._dieBoom)
		if team == nil then
			team = BattleTeam.new(ECamp.RIGHT)   

		    local info = {npcid = ZOMBIE_BOOM_ID, level = LEVEL, summon = false}
		    BC.initTeamAttr_Npc(team, self._heros[2], info, x, y)    
		    self:_raceCountAdd(2, team.race1, team.race2)
		    self.classCount[2][team.classLabel] = self.classCount[2][team.classLabel] + 1
		    self:addTeam(team)     
		    -- 原始出场方阵标记
		    -- team.original = true
		    team.cantSort = true
		    team.goBack = false
		    team.turnFire = false
            team.__attackArea = team.attackArea
			self._boom[team.ID] = team
            team.radius = 30
            team.attackRange = 0.3
            team.soldier[1].radius = 30
			if not init then
				self:addToUpdateList(team)
			end
		else
			self:teamRevive(team, true)
			local soldiers = team.soldier
			for i = 1, #soldiers do
				local nx, ny = BC.getPosInFormation(x, y, i, team.volume, team.camp)
				soldiers[i]:setPos(nx, ny)
                soldiers[i]:setVisible(true)
			end
			local newRow = getRowIndex(y)
			if newRow ~= team.row then
				table.removebyvalue(self._rowTeam[2][team.row], team)
        		team.row = newRow
        		table.insert(self._rowTeam[2][team.row], team)
        	end
			self._dieBoom[id] = nil
			self._boom[id] = team
		end
		self._boomCount = self._boomCount + 1
	end
    if not init then
        team:setState(ETeamStateIDLE)
        team.attackArea = -1
        delayCall(3, self, function ()
            if team.state ~= ETeamStateDIE then
                team:setState(ETeamStateMOVE)
            end
            team.attackArea = team.__attackArea
        end)
        if not BC.jump then
            for i = 1, #team.soldier do
                team.soldier[i]:setVisible(false)
                team.soldier[i]:setDirect(-1)   
                ScheduleMgr:delayCall(GRandom(1000), self, function (_, sender)
                    if self.battleState ~= EState.OVER then
                        sender:setVisible(true)
                        if not sender.die then
                            sender:changeMotion(EMotionBORN)
                        end
                    end
                end, team.soldier[i])
            end
        end
    end
end

function BattleLogic:onSoldierDieEx(soldier)
	if soldier.team.camp == 1 then return end
	-- 冰僵尸冰冻所有人
    if soldier.team.D["id"] == ZOMBIE_BOOM_ID then
        self.killCount2 = self.killCount2 + 1
        if not BATTLE_PROC then
            local index = GRandom(#self.__killCount2_1)
            self.__killCount2_1[index] = self.__killCount2_1[index] + 1
            index = GRandom(#self.__killCount2_2)
            self.__killCount2_2[index] = self.__killCount2_2[index] - 5
        end
    else
        self.killCount1 = self.killCount1 + 1
        if not BATTLE_PROC then
            local index = GRandom(#self.__killCount1_1)
            self.__killCount1_1[index] = self.__killCount1_1[index] + 1
            index = GRandom(#self.__killCount1_2)
            self.__killCount1_2[index] = self.__killCount1_2[index] - 5
        end
    end
    if GRandom(3) == 1 then
        self:_playEXPEff(soldier.x, soldier.y)
    end
	if soldier.freeze then
		local team
		local buff 
		for i = 1, #self._teams[2] do
			team = self._teams[2][i]
			local soldiers = team.aliveSoldier
			for k = 1, #soldiers do
				buff = initSoldierBuff(BUFFID_FREEZE, 1, soldiers[k].caster, soldiers[k])
	            soldiers[k]:addBuff(buff)
			end
		end
        self._control:_doFreezeEff()
		soldier.freeze = nil
	end
end

local offsetTab =
{
    {12, 58},
    {39, 1},
    {-41, 7},
    {57, 50},
    {-6, 18},
    {-51, 34},
}
function BattleLogic:_playEXPEff(x, y)
    if BC.jump then return end
    local ran = GRandom(6)
    local c1, c2 = self.damageCount, self.waveCount
    local __x, __y = offsetTab[ran][1] + 1, offsetTab[ran][2] - 5
    local _x, _y = self._control:convertToScreenPt(x, y)
    local drop = mcMgr:createViewMC("EXP"..ran.."_jingyan", false, true, function ()
        local EXP = mcMgr:createViewMC("EXP_jingyan", true)
        EXP:setPosition(_x + __x, _y + __y)
        EXP:setRotation(-90)
        EXP:setScale(0.74)
        uiLayer:addChild(EXP)
        local pt = expIcon:convertToWorldSpace(cc.p(22, 24))
        EXP:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveTo:create(0.3, cc.p(pt.x, pt.y)), 2), cc.CallFunc:create(function ()
            EXP:removeFromParent()
            local guang = mcMgr:createViewMC("kuosan_jingyan", false, true)
            guang:setPosition(22, 24)
            expIcon:addChild(guang)
            self:_updateExpNumber(c1, c2)
        end)))
    end)
    drop:setPosition(_x, _y)
    uiLayer:addChild(drop)
end

local kkk = 14000 * (0.8 + 0.05 * LEVEL)
function BattleLogic:_updateExpNumber(c1, c2)
    local value = kkk * ((2 * c1) / (c1 + 120000 * LEVEL)) * math.min(1.5, (0.8 + 0.01 * c2))
    self._countLabel3Dest = math.floor(value)
end

function BattleLogic:onHPChangeEx(soldier, change)
	if soldier.team.camp == 1 then
        if soldier.zhalan and not soldier.die then
            soldier:changeMotion(EMotionATTACK)
        end
    else
    	if change < 0 then
    		self.damageCount = self.damageCount - change 
            if not BATTLE_PROC then
                local index = GRandom(#self.__damageCount_1)
                self.__damageCount_1[index] = self.__damageCount_1[index] - change
                index = GRandom(#self.__damageCount_2)
                self.__damageCount_2[index] = self.__damageCount_2[index] + (7 * change)
            end     
    	end
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
    
    BattleLogic = nil
    BattleScene = nil
    BattleTeam = nil
    BC = nil -- BC
    BUFFID_BLUE = nil -- 4998
    BUFFID_FREEZE = nil -- 4997
    BUFFID_LINGHUNLIANJIE = nil -- 4996
    cc = nil -- _G.cc
    ceil = nil -- math.ceil
    
    COUNT_TIME = nil -- 180
    ECamp = nil -- BC.ECamp
    EDirect = nil -- BC.EDirect
    EEffFlyType = nil -- BC.EEffFlyType
    EMotion = nil -- BC.EMotion
    EMotionATTACK = nil -- EMotion.ATTACK
    EMotionBORN = nil -- EMotion.BORN
    EMotionCAST1 = nil -- EMotion.CAST1
    EMotionDIE = nil -- EMotion.DIE
    EState = nil -- BC.EState
    ETeamState = nil -- BC.ETeamState
    ETeamStateDIE = nil -- ETeamState.DIE
    ETeamStateIDLE = nil -- ETeamState.IDLE
    ETeamStateMOVE = nil -- ETeamState.MOVE
    floor = nil -- math.floor
    format = nil -- string.format
    getRowIndex = nil -- BC.getRowIndex
    hpOneValue = nil -- 20
    hpPics = nil
    hpColors = nil -- {
    initSoldierBuff = nil -- BC.initSoldierBuff 
    LEVEL = nil -- BC.PLAYER_LEVEL
    math = nil -- math
    mcMgr = nil -- mcMgr
    next = nil -- next
    objLayer = nil
    logic = nil
    os = nil -- _G.os
    pairs = nil -- pairs
    pc = nil -- pc
    PRO_ZOMBIE_BOOM = nil -- 2500
    PRO_ZOMBIE_FREEZE = nil -- 1500
    random = nil -- BC.ran
    REVIVE_TIME = nil -- 5
    rule = nil -- {}
    SKILL_PRO = nil -- 0
    spawnPos = nil -- {{4, 3}, {8, 7}, {12, 11}, {16, 15}}
    tab = nil -- tab
    table = nil -- table
    tonumber = nil -- tonumber
    tostring = nil -- tostring
    warningLabel = nil
    ZHALAN_2_ID = nil -- 79016
    ZHALAN_ID = nil -- 79013
    ZHALAN_RESNAME = nil -- {tab.npc[ZHALAN_ID]["art"], tab.npc[ZHALAN_2_ID]["art"]}
    ZOMBIE_BOOM_ID = nil -- 79012
    ZOMBIE_COMMON_2_ID = nil -- 79014
    ZOMBIE_COMMON_ID = nil -- 79011
    ZOMBIE_RESNAME = nil 
    abs = nil
    expIcon = nil
    countLabel3 = nil
    uiLayer = nil
    delayCall = nil
    SRData = nil
end
return rule