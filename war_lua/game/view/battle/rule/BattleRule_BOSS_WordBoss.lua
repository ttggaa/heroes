--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--[[
    FileName:       BattleRule_BOSS_WordBoss
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-09-21 14:45:35
    Description:    世界BOSS
]]

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
local format = string.format
local INTO_DIS = 250
local INTO_SPEED = 120

local motionFrame = {30, 0, 30, 47, 53, 37, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

local hpOneValue = 5
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

-- 游戏时间
local COUNT_TIME = 120

local rule = {}

function rule.init()

    local BattleScene = require("game.view.battle.display.BattleScene")
    

    local floor = math.floor
    local ceil = math.ceil
    local BattleTeam = require "game.view.battle.object.BattleTeam"
    local BattleTeam_addDamage = BattleTeam.addDamage
    local BattleTeam_addHurt = BattleTeam.addHurt
    local abs = math.abs

    --------------------------------------------------------------------------------
    -- BattleScene 补充函数
    --------------------------------------------------------------------------------

    --  初始化Ui的函数(BattleScene:initBattleUI() not BATTLE_PROC)
    function BattleScene:initBattleUIEx()
        self._BattleView:getUI("uiLayer.topLayer.timeBg"):setVisible(false)
        self._BattleView:getUI("uiLayer.topLayer.timeLabel"):setPositionY(33)

        self.CountTime = COUNT_TIME

        self._proBar1 = self._BattleView:getUI("uiLayer.topLayer.pro1")
        self._proBar2 = self._BattleView:getUI("uiLayer.topLayer.pro2")
        self._proBar1:loadTexture("hpBar1_battle.png", 1)

        self._proBar3 = cc.Sprite:create()
        self._proBar3:setAnchorPoint(0, 0)
        self._proBar2:addChild(self._proBar3, -1)

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

        self._pauseBtn.lock:setVisible(true)
        self._pauseBtn:setTouchEnabled(false)

--        self._skipBtn:getChildByName("lock"):setVisible(true)
        if OS_IS_WINDOWS then
            self._skipBtn:setTouchEnabled(true)
            self._skipBtn:setVisible(true)
        else
            self._skipBtn:setTouchEnabled(false)
            self._skipBtn:setVisible(false)
        end
        

        local uiLayer = self._BattleView:getUI("uiLayer")

        self._hurtNode = cc.Node:create()
        self._hurtNode:setPosition(uiLayer:getContentSize().width, uiLayer:getContentSize().height - 170)
        uiLayer:addChild(self._hurtNode)

        local hurtBgImage = ccui.ImageView:create()
        hurtBgImage:loadTexture("common_bg_battle.png", ccui.TextureResType.plistType)
        hurtBgImage:setScale9Enabled(true)
        hurtBgImage:setContentSize(cc.size(251, 70))
        hurtBgImage:setPosition(cc.p(hurtBgImage:getContentSize().width / 2 * -1, 0))
        self._hurtNode:addChild(hurtBgImage)

        local curHurt = ccui.Text:create()
        curHurt:setString("伤害：0")
        curHurt:setFontSize(22)
        curHurt:setFontName(UIUtils.ttfName)
        curHurt:setColor(cc.c3b(255, 255, 255))
        curHurt:setAnchorPoint(cc.p(0, 0.5))
        curHurt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        curHurt:setPosition(cc.p(-200, 15))
        self._hurtNode:addChild(curHurt)
        self._hurtNode._curHurt = curHurt

        local maxHurt = ccui.Text:create()
        maxHurt:setString("最高纪录：0")
        maxHurt:setFontSize(20)
        maxHurt:setFontName(UIUtils.ttfName)
        maxHurt:setColor(cc.c3b(183, 125, 40))
        maxHurt:setAnchorPoint(cc.p(0, 0.5))
        maxHurt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        maxHurt:setPosition(cc.p(-200, -15))
        self._hurtNode:addChild(maxHurt)
        self._hurtNode._maxHurt = maxHurt

        self._hurtNode:setVisible(false)

    end

    function BattleScene:lSetHurt(nType, nValue)
        if self._hurtNode == nil then
            return
        end
        if nType == 1 then
            self._hurtNode._curHurt:setString("伤害：" .. self:lGetShowHurt(nValue))
        elseif nType == 2 then
            self._hurtNode._maxHurt:setString("最高纪录：" .. self:lGetShowHurt(nValue))
        elseif nType == 3 then
            self._hurtNode._curHurt:setString("伤害：" .. self:lGetShowHurt(nValue))
            self._hurtNode._maxHurt:setString("最高纪录：" .. self:lGetShowHurt(nValue))
        end
    end

    function BattleScene:lShowHurtNode()
        if self._hurtNode then
            self._hurtNode:setVisible(true)
        end
    end

    function  BattleScene:lGetShowHurt(nValue)
        if nValue == nil then
            return 0
        end
        if nValue > 100000000 then
            return format("%.2f", nValue / 100000000) .. "亿"
        elseif nValue > 10000 then
            return format("%.2f", nValue / 10000) .. "万"
        else    
            return nValue
        end
    end

    --  更新HP显示函数(BattleScene:updateSkipLayer()[跳过战斗], BattleScene:countHP() not BATTLE_PROC)
    function BattleScene:countHPEx()
        
        local hp1, maxhp1, hp2, maxhp2 = logic:getCurHP()
        local shp1, maxshp1, shp2, maxshp2 = logic:getSummonHP()
        self._destValue1 = ((hp1 + shp1) / (maxhp1 + maxshp1)) * 100
        self._proBar1:setPercent(self._destValue1)

        self:updateMutiHpBar((hp2 / maxhp2) * 100)
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

    --  额外的更新函数(BattleScene:update(dt) not BATTLE_PROC)
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

    --  战斗结束调用的函数(BattleScene:onBattleEnd not BATTLE_PROC)
    function BattleScene:setOverTime(time)
        self._timeLabel:setString(formatTime(ceil(COUNT_TIME - time)))
    end

    --  战斗开始 (BattleScene:play not BATTLE_PROC)
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

    --  更新玩家touch(BattleScene:updateTouch )
    function BattleScene:updateTouchEx()
        return true
    end
 
    --地图多点触摸函数的处理 start

    -- self._sceneLayer触摸事件(BattleScene:onMouseScroll)
    function BattleScene:onMouseScrollEx()
        return true
    end

    -- self._sceneLayer触摸事件(BattleScene:onTouchesBegan)
    function BattleScene:onTouchesBeganEx()
        return true
    end

    -- self._sceneLayer触摸事件(BattleScene:onTouchesMoved)
    function BattleScene:onTouchesMovedEx()
        return true
    end

    -- self._sceneLayer触摸事件(BattleScene:onTouchesEnded)
    function BattleScene:onTouchesEndedEx()
        return true
    end

    --地图多点触摸函数的处理 end

    -- 战斗开始动画(BattleScene:battleBeginAnim()) 这个时候logic.battleState == EState.READY
    function BattleScene:battleBeginAnimEx()
        -- 黑屏渐变
        self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
            self._frontLayer:getView():setVisible(false)
        end)))

        self._camera = cc.Node:create()
        self._rootLayer:addChild(self._camera)
        local dx1, dy1 = logic:getLeftTeamCenterPoint()
        -- local dx1 = MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale() + 150
        -- local dy1 = BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 - 20
        local dx2 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + 100
        local dy2 = dy1
        local dx3 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 - 130
        local dy3 = dy1
    
        self:screenToPos(0, dy1, false)
        self._animId = ScheduleMgr:regSchedule(1, self, function(self)
            if self._follow then
                if self._camera then
                    local _x, _y = logic:getLeftTeamCenterPoint()
                    self._camera:setPosition(_x, _y)
                else
                    self._follow = nil
                end
            end
            if self._camera then
                self:screenToPos(self._camera:getPositionX(), self._camera:getPositionY(), 0.2)
            end
        end)

        local tick = logic:getBossBornTick()
        self._follow = true
        logic:goInto(function ()
            logic.battleState = EState.READY
            self._follow = false
            self._camera:runAction(
            cc.Sequence:create(
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
                    cc.DelayTime:create(tick),
                    cc.EaseIn:create(cc.MoveTo:create(0.8, cc.p(dx3, dy3)), 3),
                    cc.CallFunc:create(function ()
                        self:lShowHurtNode()
                        self:commonRealBattleBegin()
                    end)
                    ))
        end)
    end


    --  跳过开场动画
    function BattleScene:jumpBattleBeginAnimEx()
        self._follow = nil
        if self._camera then
            local dx1 = MAX_SCREEN_WIDTH * 0.5 / self._sceneLayer:getScale() + 150
            local dy1 = BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 - 20
            local dx2 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5
            local dy2 = dy1
            local dx3 = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 - 230 + 100
            local dy3 = dy1

            logic:jumpBattleBeginAnimEx()
            self._frontLayer:getView():stopAllActions()
            self._frontLayer:getView():setOpacity(0)

            self._camera:stopAllActions()
            self._camera:setPosition(dx3, dy3)
            self:screenToPos(dx3, dy3, false)

            self:commonRealBattleBegin()
        end
        self:lShowHurtNode()
    end

    -- 中断开场动画 (比如跳过战斗)
    function BattleScene:battleBeginAnimCancelEx()
        if self._camera then
            self._camera:stopAllActions()
            self._camera:removeFromParent()
            self._camera = nil
        end
        ScheduleMgr:unregSchedule(self._animId)
    end

    -- 号角MC 号角的动画创建一般走到这个函数说明战斗已经开始了 logic.battleState == EStateING 这个是开始流程的最后(BattleScene:battleBeginMC)
    function BattleScene:battleBeginMCEx()
        audioMgr:playSoundForce("horn")

        local mc = mcMgr:createViewMC("chuihaodonghua_quanjunchuji", false, true)
        mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 14)
        self._rootLayer:getParent():addChild(mc)
    end

    --  战斗结束(BattleScene:onBattleEnd)
    function BattleScene:onBattleEndEx(res)
        ScheduleMgr:unregSchedule(self._animId)
        res["curTotalHurt"] = abs(logic._curTotalHurt)
    end




    --------------------------------------------------------------------------------
    -- BattleLogic 补充函数
    --------------------------------------------------------------------------------

    local BattleLogic = require("game.view.battle.logic.BattleLogic")

    local random = BC.ran
    local ETeamStateDIE = BC.ETeamState.DIE
    local initSoldierBuff = BC.initSoldierBuff 
    local EMotionBORN = EMotion.BORN
    -- boss造成伤害
    local countDamage_attack = BC.countDamage_attack
    local randomSelect = BC.randomSelect
    local getRowIndex = BC.getRowIndex

    -- 初始化(BattleLogic:initLogic)
    function BattleLogic:initLogicEx(procBattle)
        logic = BC.logic
        objLayer = BC.objLayer
        local team, soldier

        -- if not procBattle then
        --     for i = 1, #self._teams[1] do
        --         team = self._teams[1][i]
        --         team.goBack = false
        --         -- 初始位置往后挪
        --         team.__x = team.x + 100
        --         team.__y = team.y
        --         for k = 1, #team.soldier do
        --             soldier = team.soldier[k]
        --             soldier.__x = soldier.x + 100
        --             soldier.__y = soldier.y
        --             soldier:setPos(soldier.x - INTO_DIS + 100, soldier.y)
        --         end
        --     end
        -- else
        --     for i = 1, #self._teams[1] do
        --         team = self._teams[1][i]
        --         team.goBack = false
        --     end
        -- end

        -- self._heros[1]:setPos(15 * 40 - INTO_DIS + 100, 15 * 40)

        -- self._heros[1]:moveTo(15 * 40 + 350, 15 * 40, INTO_SPEED)

        self._heros[1]:setPos(15 * 40 + 350, 15 * 40, INTO_SPEED)

        local bossTeam = BattleTeam.new(ECamp.RIGHT, 2) 
        bossTeam.showHP = false
        bossTeam.showHead = false

        local bosslevel = self._battleInfo.bossLevel or 1
        local info = {npcid = self._battleInfo.bossId, level = bosslevel, summon = false}
        BC.initTeamAttr_Npc(bossTeam, self._heros[2], info, 1300, 340)    
        self:_raceCountAdd(2, bossTeam.race1, bossTeam.race2)
        self.classCount[2][bossTeam.classLabel] = self.classCount[2][bossTeam.classLabel] + 1
        bossTeam.noHUD = true
        self:addTeam(bossTeam)   
--        bossTeam.
        -- 原始出场方阵标记
        bossTeam.boss = true
        bossTeam.original = true
        --true 战斗结束的时候直接停止移动
        bossTeam.cantSort = true
        bossTeam.goBack = false
        --第一次攻击之后是否转移攻击目标
        bossTeam.turnFire = false

        --强制boss不能移动
        bossTeam.speedMove = 0
        bossTeam.speedAttack = 0

        self._bossTeam = bossTeam
        self._boss = self._bossTeam.soldier[1]
        self._boss.minHPEx = 1
        self._boss._worldBoss = true
        --记录伤害
        self._curTotalHurt = 0
        self._maxTotalHurt = self._battleInfo.wordBoosMaxhurt or 0
        if not BC.jump and not BATTLE_PROC then
            self._control:lSetHurt(1, abs(self._curTotalHurt))
            self._control:lSetHurt(2, abs(self._maxTotalHurt))
        end
    end

    -- 清理函数(BattleLogic:clear())
    function BattleLogic:clearEx()
        logic = nil
        objLayer = nil
    end

    -- 战斗开始(BattleLogic:BattleBegin())
    function BattleLogic:BattleBeginEx()

    end


    --跳过开场战斗的逻辑处理
    function BattleLogic:jumpBattleBeginAnimEx()
        self._jsJumpBeginAnim = true

        self._boss:changeMotion(7)

        -- local team, soldier
        -- for i = 1, #self._teams[1] do
        --     team = self._teams[1][i]
        --     if team.__x then
        --         for k = 1, #team.soldier do
        --             soldier = team.soldier[k]
        --             soldier:stopMove()
        --             soldier:setPos(soldier.__x, soldier.__y)
        --         end
        --         team.x = team.__x
        --         team.y = team.__y
        --     end
        -- end
        -- self._heros[1]:stopMove()
        -- self._heros[1]:setPos(15 * 40 + 350, 15 * 40, INTO_SPEED)
        -- self.battleState = EState.READY
    end

    -- 游戏的主循环 BattleLogic:update()
    function BattleLogic:updateEx()
       
    end

    -- 攻击结束 BattleLogic:teamAttackOver(team)
    function BattleLogic:teamAttackOverEx(team)

    end

    -- 兵团死亡(BattleLogic:onTeamDie(team))
    function BattleLogic:onTeamDieEx(team)
    	
    end

    -- 小兵死亡(BattleTeam:soldierDie(id))
    function BattleLogic:onSoldierDieEx(soldier)

    end

    -- 血量变化(BattleSkillLogic:onHPChange)
    function BattleLogic:onHPChangeEx(soldier, change)
    	if soldier.camp == 2 then
            if change < 0 then
                self._curTotalHurt = self._curTotalHurt + change
                if (abs(self._curTotalHurt) > self._maxTotalHurt) then
                    self._maxTotalHurt = abs(self._curTotalHurt)
                end
                
                if not BC.jump and not BATTLE_PROC then
                    self._control:lSetHurt(1, abs(self._curTotalHurt))
                    self._control:lSetHurt(2, abs(self._maxTotalHurt))
                end
            end
        end
    end

    function BattleLogic:bossInto1()
        self:shake(4, 1)
        ScheduleMgr:delayCall(770, self, function ()
            if self._jsJumpBeginAnim then return end
            self:shake(4, 2)
        end)
        ScheduleMgr:delayCall(770 * 2, self, function ()
            if self._jsJumpBeginAnim then return end
            self:shake(4, 3)
        end)
        ScheduleMgr:delayCall(770 * 3, self, function ()
            if self._jsJumpBeginAnim then return end
            self:shake(4, 4)
        end)
    end

    function BattleLogic:bossInto2()

    end

    function BattleLogic:bossInto3()
        local frame = motionFrame[7]
        self._boss:changeMotion(7)
        self._boss:changeMotion(EMotionBORN)
        ScheduleMgr:delayCall(21 * 50, self, function ()
            if self._jsJumpBeginAnim then return end
            self:shake(2, 5)
        end)
        ScheduleMgr:delayCall(46 * 50, self, function ()
            if self._jsJumpBeginAnim then return end
            audioMgr:playSound("boss_sjl_houjiao")
            self:shake(5, 5)
        end)
        return frame
    end

    function BattleLogic:getBossBornTick()
        return motionFrame[7] * 0.05
    end

    -- 胜利条件
    function BattleLogic:checkWinEx()
        if self._surrender or self.battleTime > COUNT_TIME then
            self:bossOver()
            self:surrender(1)
            return true
        end

        for i = 1, 2 do
            if self._lastTeamCount[i] == 0 and self._reviveCount[i] == 0 then
                self:bossOver()
                self:Win(3 - i)
                return true
            end
        end
    end

    -- boss 结束的特殊处理
    function BattleLogic:bossOver()

    end
    
    -- 战斗结束设置显示效果(BattleLogic:setCampBrightness)
    function BattleLogic:setCampBrightnessEx(camp, value)

    end

    -- 攻击方是否自动战斗
    function BattleLogic:isOpenAutoBattleForLeftCamp()
        return true
    end

    -- 防守方是否自动战斗
    function BattleLogic:isOpenAutoBattleForRightCamp()
        return false
    end

    --惊叹号动画
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

    -- 进场
    function BattleLogic:goInto(callback)
        callback()
        -- local allCount = 0
        -- local count = 0
        -- for i = 1, #self._teams[1] do
        --     local team = self._teams[1][i]
        --     if team.original then
        --         for k = 1, #team.soldier do
        --             local soldier = team.soldier[k]
        --             allCount = allCount + 1
        --             if not team.walk then
        --                soldier:setPos(soldier.x + INTO_DIS, soldier.y)
        --                soldier:setVisible(true)
        --                count = count + 1
        --             else
        --                 soldier:moveTo(soldier.x + INTO_DIS, soldier.y, INTO_SPEED, function ()
        --                     count = count + 1
        --                     if count == allCount then
        --                         callback()
        --                     end
        --                 end, true)
        --             end
        --         end
        --     end
        -- end
        -- self.battleState = EState.INTO
    end

end


function rule.dtor()
    BattleLogic = nil
    BattleTeam = nil
    random = nil
    ETeamStateDIE = nil
    initSoldierBuff = nil
    EMotionBORN = nil
    countDamage_attack = nil
    randomSelect = nil
    getRowIndex = nil
    BattleScene = nil
    COUNT_TIME = nil
    floor = nil
    ceil = nil
    BattleTeam_addDamage = nil
    BattleTeam_addHurt = nil
    abs = nil
    hpOneValue = nil
    hpPics = nil
    hpColors = nil
    INTO_DIS = nil
    INTO_SPEED = nil
    BC = nil --BC
    pc = nil --pc
    cc = nil --_G.cc
    os = nil --_G.os
    math = nil --math
    tab = nil --
    table = nil --table
    floor = nil --math.floor
    ceil = nil --math.ceil
    mcMgr = nil --mcMgr
    ETeamState = nil --BC.ETeamState
    EMotion = nil --BC.EMotion
    EDirect = nil --BC.EDirect
    ECamp = nil --BC.ECamp
    EState = nil --BC.EState
    EEffFlyType = nil --BC.EEffFlyType
    delayCall = nil --BC.DelayCall.dc
    SRData = nil --BattleUtils.SRData
    format = nil
end 
return rule


--endregion
