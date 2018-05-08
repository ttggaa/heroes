--[[
    Filename:    BattleRule_Guide.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-21 15:33:28
    Description: File description
--]]

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

local siegeR_show = BC.siegeR_show
local siegeR_logic = BC.siegeR_logic
local BC_reverse = BC.reverse

local camp1 = siegeR_logic and 2 or 1
local camp2 = siegeR_logic and 1 or 2

local rule = {}
function rule.init()

local BattleScene = require("game.view.battle.display.BattleScene")

local GLOBAL_SP_SCALE = 0.9

local LEVEL1 = 0
local LEVEL2 = 0
local BUFFID_LINGHUNLIANJIE = 4996
local INTO_SPEED = 120
local INTO_DIS = 490
local COUNT_TIME = 180

local siegeHPBar = nil

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
    
    self._speedBtn:setVisible(false)
    self._pauseBtn:setVisible(false)
    self._autoBtn:setVisible(false)

    siegeHPBar = cc.Sprite:createWithSpriteFrameName("siegehpbg_battle.png")
    siegeHPBar:setCascadeOpacityEnabled(true)
    local hp = ccui.LoadingBar:create("siegehp_battle.png", 1, 100)
    hp:setPosition(67.5, 6)
    hp:setScaleX(-1)
    siegeHPBar:addChild(hp)
    siegeHPBar.hp = hp
    local icon = cc.Sprite:createWithSpriteFrameName("siegeicon_battle.png")
    icon:setPosition(145, 6)
    siegeHPBar:addChild(icon)
    siegeHPBar:setPosition(0, -1000)
    siegeHPBar:setVisible(false)
    siegeHPBar:setFlipX(siegeR_show)
    self._uiLayer:addChild(siegeHPBar, -100)

    if self._mapNear then
        self._mapNear:setCascadeOpacityEnabled(true)
        self._mapNear:setOpacity(180)
        local k = MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT
        local kk = (k - 1.775) / (1.333 - 1.775)
        self._mapNear:getChildren()[1]:setPositionY(50 - 50 * kk)
    end
    -- self._mapNear:setVisible(false)

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

    if self.__jump then
        self.__jump = false

        local frame = BC.frameInv
        while logic.battleTime < 5 and self._isWin == nil do
            BC.BATTLE_TICK = BC.BATTLE_TICK + frame
            BC.BATTLE_DISPLAY_TICK = BC.BATTLE_DISPLAY_TICK + frame
            logic:update(true)
        end
        BC.noEff = false
        BC.BATTLE_TICK = BC.BATTLE_TICK + frame
        BC.BATTLE_DISPLAY_TICK = BC.BATTLE_DISPLAY_TICK + frame
        logic:update()
        delayCall(0, self, function()
            self.enableOutEnemy = true
            self._touchMask:removeFromParent()
            self:playGongChengEff()
            self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
                self._frontLayer:getView():setVisible(false)   
            end)))
        end)
    end
end

function BattleScene:setOverTime(time)
    self._timeLabel:setString(formatTime(ceil(COUNT_TIME - time)))
end

function BattleScene:playEx()
    self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5, false)
    self:screenToSize(BC.SCENE_SCALE_INIT)
     
    if logic:hasAssist2() then
        local _x, _y = self:convertToScreenPt(43 * 40, 11.4 * 40)
        local x, y = self:convertToNodePt(MAX_SCREEN_WIDTH - 100, _y)
        x = BC_reverse and BC.MAX_SCENE_WIDTH_PIXEL - x or x
        logic._heros[2]:setPos(x, 12 * 40)
    end

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
    return false
end

function BattleScene:onMouseScrollEx()
    return false
end

function BattleScene:onTouchesBeganEx()
    return false
end

function BattleScene:onTouchesMovedEx()
    return false
end

function BattleScene:onTouchesEndedEx()
    return false
end

-- 战斗开始动画
function BattleScene:battleBeginAnimEx()
    -- 黑屏渐变
    if logic:hasAssist2() then
        self:realBegin()
    else
        self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
            self._frontLayer:getView():setVisible(false)
        end)))
        local callback = logic:goInto(function ()
            logic.battleState = EState.READY
            if self._battleInfo.showNpc == nil then
                self:realBegin()
            else
                self:introduceNPC(self._battleInfo.showNpc, function ()
                    self:realBegin()
                end)
            end
        end, true)
        logic:heroEnter(callback)
        self:playGongChengEff() 
    end
end

function BattleScene:playGongChengEff()
    self._gongchengzhan = mcMgr:createViewMC("yanwu_gongchengzhan", true)
    self._gongchengzhan:setScaleX(siegeR_show and -1 or 1)
    self._gongchengzhan:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self._uiLayer:getParent():addChild(self._gongchengzhan, -5)   

    local feishi = mcMgr:createViewMC("feishi_gongchengzhan", false, true)
    feishi:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    feishi:setScaleX(siegeR_show and -1 or 1)
    self._uiLayer:getParent():addChild(feishi, -2)   
    feishi:addCallbackAtFrame(41, function ()
        self:shake(2, 1)
    end)
    feishi:addCallbackAtFrame(52, function ()
        self:shake(1, 1)
    end)
    feishi:addCallbackAtFrame(77, function ()
        self:shake(2, 1)
    end)
    feishi:addCallbackAtFrame(89, function ()
        self:shake(2, 1)
    end)
end

function BattleScene:realBegin()
    if logic:hasAssist2() then
        ViewManager:getInstance():enableBlack()
        self:battleBegin()
        self.__jump = true
    else
        if BattleUtils.unLockSkillIndex == nil then
            self._touchMask:addClickEventListener(function () end)
            objLayer:playEffect_skill1("fazhenzhaohuan_fazhenzhaohuan", logic._heros[camp1].x, logic._heros[camp1].y, true, true)
            ScheduleMgr:delayCall(2000, self, function()
                -- print("###########################")
                logic._heros[camp1]:setVisible(true)
                ViewManager:getInstance():enableTalking(1010, {}, function ()
                    self:battleBeginMC()
                    self:battleBegin()
                    self._touchMask:removeFromParent()
                end)
            end)
        else
            -- 解锁技能逻辑
            self._touchMask:addClickEventListener(function () end)
            self:battleBeginMC(true)

            logic:doSkillUnlock(self._BattleView, self._allMpBg, BattleUtils.unLockSkillIndex, function()
                BattleUtils.unLockSkillIndex = nil
                self:initBattleSkill(function ()
                    self:battleBeginMCEx()
                    logic:battleBeginMC()
                    ScheduleMgr:delayCall(1100, self, function()
                        self:battleBegin()
                        self._touchMask:removeFromParent()
                    end)
                end)
            end)
        end
    end
end

-- 战斗开始动画
function BattleScene:battleBeginMCEx()
    -- audioMgr:playSoundForce("horn")

    -- local mc = mcMgr:createViewMC("chuihaodonghua_quanjunchuji", false, true)
    -- mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 14)
    -- self._rootLayer:getParent():addChild(mc)
    siegeHPBar:setVisible(true)
end

-- 跳过开场动画
function BattleScene:jumpBattleBeginAnimEx()

end

-- 中断开场动画
function BattleScene:battleBeginAnimCancelEx()

end

function BattleScene:onBattleEndEx(res)
    res["exInfo"] = {siegeBroken = (logic._aliveSiegesCount == -1)}
end

function BattleScene:setBattleSpeedEx(speed)
    if self._gongchengzhan then
        if speed == 0 then
            self._gongchengzhan:stop()
        else
            self._gongchengzhan:setPlaySpeed(speed)
            self._gongchengzhan:play()
        end
    end
    if logic and logic._feijian then
        if speed == 0 then
            logic._feijian:stop()
        else
            logic._feijian:setPlaySpeed(speed)
            logic._feijian:play()
        end
    end
end


local BattleLogic = require("game.view.battle.logic.BattleLogic")
local BattleTeam = require("game.view.battle.object.BattleTeam")

local ETeamStateDIE = BC.ETeamState.DIE
local ETeamStateIDLE = BC.ETeamState.IDLE
local ETeamStateMOVE = BC.ETeamState.MOVE
local ETeamStateNONE = BC.ETeamState.NONE
local cqchEffTab = 
{
    ["chengbao"] = "cqchchengbao",
    ["chengbaor"] = "cqchchengbao",
    ["bilei"] = "cqchbilei",
    ["yaosai"] = "cqchbilei",
    ["muyuan"] = "cqchmuyuan",
    ["diyu"] = "cqchmuyuan",
    ["judian"] = "cqchbilei",
    ["talou"] = "cqchchengbao",
    ["dixiacheng"] = "cqchbilei",
}
-- 每一种城墙的海拔..
-- 从上到下
local cqAltitude = 
{
    ["chengbao"] = {{0, 84}, {0, 83}, {0, 85}, {0, 83}},
    ["chengbaor"] = {{0, 84}, {0, 83}, {0, 85}, {0, 83}},
    ["bilei"] = {{4, 92}, {-2, 98}, {-1, 102}, {5, 106}},
    ["yaosai"] = {{-2, 84}, {-2, 84}, {-2, 84}, {-2, 84}},
    ["muyuan"] = {{2, 70}, {-4, 82}, {-3, 84}, {-2, 84}},
    ["diyu"] = {{0, 77}, {-1, 92}, {-1, 91}, {1, 97}},
    ["judian"] = {{-4, 80}, {-8, 80}, {0, 92}, {-1, 92}},
    ["talou"] = {{0, 68}, {-3, 80}, {-1, 78}, {-1, 84}},
    ["dixiacheng"] = {{4, 92}, {-2, 98}, {-1, 102}, {5, 106}},
}
function BattleLogic:initLogicEx(procBattle)
    logic = BC.logic
    objLayer = BC.objLayer

    if self:hasAssist2() then
        BC.noEff = true
    end

    -- 援助逻辑
    self._assist = nil
    self._intanceD = self._battleInfo.intanceD
    if self._battleInfo.assist then
        if self._intanceD["helpCondition"] then
            self._assist = self._intanceD["helpCondition"][1]
            self._assistValue = self._intanceD["helpCondition"][2]
        end
    end
    self.__teamDieCount = 0

    self._siegeId = self._battleInfo.siegeId
    self._siegeD = tab.siege[self._siegeId]
    self._cqchEffName = cqchEffTab[self._siegeD["art"]]
    LEVEL1 = self._battleInfo.siegeLevel
    LEVEL2 = self._battleInfo.arrowLevel

    self._staticPylons = {}
    self._pylons = {}
    self._arrows = {}

    local xx = 1480
    local yy = 320
    local ids

    local xxx = 1718
    if not BATTLE_PROC then
        self._control:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5, false)
        self._control:screenToSize(BC.SCENE_SCALE_INIT)
        xxx = self._control:convertToNodePt(MAX_SCREEN_WIDTH, 0)
    end
    if not self._battleInfo.siegeBroken then
        if self._siegeD["cun"] then
            ids = {9, 26, 10, 26, 11, 26, 12, 13, 14, 15, 16, 1, 17, 1, 17}
        else
            ids = {9, 26, 10, 26, 11, 26, 12, 13, 14, 15, 16, 1, 17, 1, 17, 18}
        end
        local posx = {  
                        xx + 394, xx + 314, xx + 232, xx + 152, xx + 70, xx - 10,
                        xx - 50, xx - 108, xx - 124, xx - 100, xx - 38,
                        xx - 10, xx + 70, xx + 152, xx + 232,
                        xxx}
        if siegeR_show then
            local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL
            for i = 1, #posx do
                posx[i] = MAX_SCENE_WIDTH_PIXEL - posx[i]
            end
        end
        local posy = {  
                        yy + 200, yy + 199, yy + 200, yy + 199, yy + 200, yy + 199,
                        yy + 168, yy + 110, yy + 10, yy - 120, yy - 195,
                        yy - 231, yy - 230, yy - 231, yy - 230,
                        yy + 0}

        if not procBattle then
            for i = 1, #ids do
                self._staticPylons[i] = self:addStaticPylon(ids[i], posx[i], posy[i])
            end
        end
    else
        if self._siegeD["cun"] then
            ids = {}
        else
            ids = {18}
        end
        local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL
        local posx = {siegeR_show and MAX_SCENE_WIDTH_PIXEL - xxx or xxx}
        local posy = {yy + 0}

        if not procBattle then
            for i = 1, #ids do
                self._staticPylons[i] = self:addStaticPylon(ids[i], posx[i], posy[i])
            end
        end
    end

    -- 坐标不能绕背
    local team, soldier
    local dis = INTO_DIS
    if siegeR_logic then dis = -dis end
    for i = 1, #self._teams[camp1] do
        team = self._teams[camp1][i]
        team.goBack = false
        team.__turnFire = team.turnFire
        team.turnFire = false
        if team.isMelee then
            team.canTaunt = false
        end
        -- 初始位置往后挪
        if not BATTLE_PROC then
            for k = 1, #team.soldier do
                soldier = team.soldier[k]
                soldier:setPos(soldier.x - dis, soldier.y)
                if not team.walk then
                    soldier:setVisible(false)
                end
            end
        end
    end
    
    if not self._battleInfo.siegeBroken then
        -- 右边为待机
        local team
        for i = 1, #self._teams[camp2] do
            team = self._teams[camp2][i]
            team:setState(ETeamStateIDLE)
            team.canDestroy = false
            if team.isMelee then
                team.__attackArea = team.attackArea
                team.attackArea = -1
            else
                team.__attackArea = team.attackArea
                team.attackArea = team.attackArea + 400
            end
        end
    end

    if not self._battleInfo.siegeBroken then
        local posx1 = {xx - 73, xx - 120, xx - 127, xx - 80}
        local posy1 = {yy + 152, yy + 65, yy - 75, yy - 170}
        if siegeR_logic then
            local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL
            for i = 1, #posx1 do
                posx1[i] = MAX_SCENE_WIDTH_PIXEL - posx1[i]
            end
        end
        for i = 1, 4 do
            if self._siegeD["pylonid"][i] and self._siegeD["pylonid"][i] ~= 0 then
                self._pylons[i] = self:addPylon(self._siegeD["pylonid"][i], 26 - i, posx1[i], posy1[i], camp2)
            end
        end
        self._aliveSiegesCount = 4
        local altitude
        if cqAltitude[self._siegeD["art"]] then
            altitude = cqAltitude[self._siegeD["art"]]
        else
            altitude = cqAltitude["chengbao"]
        end
        for i = 1, 4 do
            if self._siegeD["arrowid"][i] and self._siegeD["arrowid"][i] ~= 0 then
                self._arrows[i] = self:addArrow(self._siegeD["arrowid"][i], posx1[i] - 1, posy1[i], altitude[i], camp2)
            end  
        end                      
    else
        self._aliveSiegesCount = -1
        self:siegeBroken()
    end
    self._halfBroken = false

    self._heros[camp1]:setVisible(false)
    -- 支援
    if self:hasAssist2() then
        -- 己方不动, 移出屏幕
        local team, soldier
        for i = 1, #self._teams[camp1] do
            team = self._teams[camp1][i]
            team:setState(ETeamStateNONE)
            team.canDestroy = false
            team.__attackArea = team.attackArea
            team.attackArea = -1
        end

        if not BATTLE_PROC then
            local _x, _y = self._control:convertToScreenPt(17 * 40, 12 * 40)
            local x, y = self._control:convertToNodePt(100, _y)
            x = BC_reverse and BC.MAX_SCENE_WIDTH_PIXEL - (x - dis) or (x - dis)
            self._heros[camp1]:setPos(x, 12 * 40)
        end

        -- 初始NPC
        for i = 1, 8 do
            if self._intanceD["hm"..i] == nil then break end
            local npcid = self._intanceD["hm"..i][1] 
            local pos = self._intanceD["hm"..i][2]
            local x, y
            if type(pos) == "table" then
                x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + pos[1], BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + pos[2]
            else
                x, y = BC.getFormationScenePos(pos, 1)
            end 
            local team = BattleTeam.new(camp1)   

            local info = {npcid = npcid, level = 1, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[camp1], info, x, y)    
            self:_raceCountAdd(camp1, team.race1, team.race2)
            self.classCount[camp1][team.classLabel] = self.classCount[camp1][team.classLabel] + 1

            team.goBack = false
            team.__turnFire = team.turnFire
            team.turnFire = false
            if team.isMelee then
                team.canTaunt = false
            end

            self:addTeam(team)     
        end   
    end
    if self._intanceD then
        if self._intanceD["help1"] then
            self._help1Tick = self._intanceD["help1"][1]
        end
        if self._intanceD["help2"] then
            self._help2Tick = self._intanceD["help2"][1]
        end
    end
    if not BATTLE_PROC then
        self._feijianTick = 5 + GRandom(5)
    end
end

-- 是否处于援助类型2
function BattleLogic:hasAssist2()
    if BC.jump then return false end
    return (self._assist and self._intanceD["helpType"] == 2)
end
-- 执行支援逻辑
function BattleLogic:doAssist()
    self._assist = nil
    self._doAssist = true
    if BC.jump then return end
    local helpType = self._intanceD["helpType"] 
    if helpType == 1 then
        -- 大天使来复活
        self:battlePause()
        ViewManager:getInstance():enableTalking(self._intanceD["helpDialogue"] , {}, function ()
            for i = 2, 8 do
                if self._intanceD["hm"..i] == nil then break end
                local npcid = self._intanceD["hm"..i][1] 
                local pos = self._intanceD["hm"..i][2]
                local x, y
                if type(pos) == "table" then
                    x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + pos[1], BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + pos[2]
                else
                    x, y = BC.getFormationScenePos(pos, 1)
                end 
                local team = BattleTeam.new(camp1)   

                local info = {npcid = npcid, level = 1, summon = false}
                BC.initTeamAttr_Npc(team, self._heros[camp1], info, x, y)    
                self:_raceCountAdd(camp1, team.race1, team.race2)
                self.classCount[camp1][team.classLabel] = self.classCount[camp1][team.classLabel] + 1
                self:addTeam(team)     

                if self._aliveSiegesCount > 0 then
                    team.goBack = false
                    team.__turnFire = team.turnFire
                    team.turnFire = false
                    if team.isMelee then
                        team.canTaunt = false
                    end
                end
                self:addToUpdateList(team)
            end
            local npcid = self._intanceD["hm1"][1] 
            local pos = self._intanceD["hm1"][2]
            local x, y
            if type(pos) == "table" then
                x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + pos[1], BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + pos[2]
            else
                x, y = BC.getFormationScenePos(pos, 1)
            end 
            
            local team = BattleTeam.new(ECamp.LEFT)   

            local info = {npcid = npcid, level = 1, summon = false}
            BC.initTeamAttr_Npc(team, self._heros[camp1], info, x, y)    
            self:_raceCountAdd(camp1, team.race1, team.race2)
            self.classCount[camp1][team.classLabel] = self.classCount[camp1][team.classLabel] + 1
            self:addTeam(team)     

            if self._aliveSiegesCount > 0 then
                team.goBack = false
                team.__turnFire = team.turnFire
                team.turnFire = false
                if team.isMelee then
                    team.canTaunt = false
                end
            end
            self:addToUpdateList(team)
            team.soldier[1]:changeMotion(EMotion.BORN)
            delayCall(1.0, self, function()
                if self._intanceD["helpEffect"] == 1 then
                    -- 复活
                    team.soldier[1]:changeMotion(EMotion.CAST1)
                    delayCall(0.5, self, function()
                        delayCall(0.1, self, function()
                            -- 全体复活
                            local _team
                            for i = 1, #self._teams[camp1] do
                                _team = self._teams[camp1][i]
                                objLayer:playEffect_skill1("fuhuo1_fuhuo", _team.x, _team.y, true, true, 1)
                                objLayer:playEffect_skill1("fuhuo2_fuhuo", _team.x, _team.y, false, false, 1)
                                if _team.state == ETeamStateDIE then
                                    local _soldier
                                    for k = 1, #_team.soldier do
                                        _soldier = _team.soldier[k]
                                        if _soldier.die then
                                            _soldier:setRevive(false, 100)
                                        end
                                    end
                                end
                            end
                            delayCall(1.3, self, function()
                                self:battleResume()
                            end)
                        end)
                        
                    end)
                else
                    self:battleResume()
                end
            end)
            
        end)
    elseif helpType == 2 then
        -- 玩家进场
        self:battlePause()
        ViewManager:getInstance():enableTalking(self._intanceD["helpDialogue"] , {}, function ()
            local team
            for i = 1, #self._teams[camp1] do
                team = self._teams[camp1][i]
                if team.original then
                    team.canDestroy = true
                    team:setState(ETeamStateMOVE)
                    team.attackArea = team.__attackArea
                end
            end
            local callback = self:goInto(function ()
                self._control:initBattleSkill(function ()
                    self._control:battleBeginMC()
                    delayCall(1.1, self, function()
                        self:battleResume()
                    end)
                end)
            end)
            self:heroEnter(callback)
        end)
    end
end

function BattleLogic:heroEnter(callback)
    local _x, _y = self._control:convertToScreenPt(17 * 40, 12 * 40)
    local x, y = self._control:convertToNodePt(100, _y)
    local r = BC_reverse
    local dis = INTO_DIS
    if siegeR_logic then 
        r = not r 
    end
    self._heros[camp1]:setPos(r and BC.MAX_SCENE_WIDTH_PIXEL - x or x, 12 * 40)
    -- self._heros[camp1]:moveTo(r and BC.MAX_SCENE_WIDTH_PIXEL - x or x, 12 * 40, INTO_SPEED, callback)

    local _x, _y = self._control:convertToScreenPt(43 * 40, 11.4 * 40)
    local x, y = self._control:convertToNodePt(MAX_SCREEN_WIDTH - 100, _y)
    x = r and BC.MAX_SCENE_WIDTH_PIXEL - x or x
    self._heros[camp2]:setPos(x, 12 * 40)
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
end

-- 进场
function BattleLogic:goInto(callback, noborn)
    local allCount = 0
    local count = 0
    local dis = INTO_DIS
    if siegeR_logic then dis = -dis end
    for i = 1, #self._teams[camp1] do
        local team = self._teams[camp1][i]
        if team.original then
            for k = 1, #team.soldier do
                local soldier = team.soldier[k]
                allCount = allCount + 1
                if not team.walk then
                    soldier:setPos(soldier.x + dis, soldier.y)
                    if not noborn then
                        soldier:changeMotion(EMotion.BORN)
                    end
                    soldier:setVisible(true)
                    count = count + 1
                else
                    soldier:moveTo(soldier.x + dis, soldier.y, INTO_SPEED, function ()
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
    if count == allCount then
        return callback
    end
end

-- 添加静态城墙
function BattleLogic:addStaticPylon(id, x, y)
    if BC.fastBattle then return end
    local node = cc.Node:create()
    local sp = SpriteFrameAnim.new(node, self._siegeD["art"], function (sp)
        sp:changeMotion(id)
    end, false) 
    objLayer:getView():addChild(node)
    node:setPosition(x, y)
    if y <= 125 then
        node:setLocalZOrder(1025 + 125 - y)
    else
        node:setLocalZOrder(-y)
    end
    node:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    sp.node = node
    sp.motionId = id
    sp.x, sp.y = x, y
    sp:setFlipX(siegeR_show)
    return sp
end

function BattleLogic:countPylonHP()
    local HP = 0
    local maxHP = 0
    for i = 1, #self._pylons do
        HP = HP + self._pylons[i].curHP
        maxHP = maxHP + self._pylons[i].maxHP
    end
    return HP, maxHP
end

-- 添加可攻击城墙
function BattleLogic:addPylon(npcid, motion, x, y, camp)
    local team = BattleTeam.new(camp)
    local info = {npcid = npcid, level = LEVEL1, summon = false}
    BC.initTeamAttr_Npc(team, self._heros[camp], info, x, y, 2 / GLOBAL_SP_SCALE, true)    
    self:_raceCountAdd(camp, team.race1, team.race2)
    self.classCount[camp][team.classLabel] = self.classCount[camp][team.classLabel] + 1
    team.noHUD = true
    self:addTeam(team)     
    -- 原始出场方阵标记
    -- team.original = true
    team.cantSort = true
    team.isSiege = true
    team.radius = 100
    team.showHP = false
    team.soldier[1].radius = 100
    team.soldier[1]:changeMotion(motion)
    team.soldier[1]:setDirect(camp == 1 and -1 or 1)
    team.soldier[1].motionId = motion
    local buff = BC.initSoldierBuff(BUFFID_LINGHUNLIANJIE, 1, team.soldier[1].caster, team.soldier[1])
    team.soldier[1]:addBuff(buff)

    team.immuneBuff = {true, true, true, true, true, true, true, true, true, true, true, true, true, true}

    return team
end

-- 添加弓箭手
function BattleLogic:addArrow(npcid, x, y, altitude, camp)
    local team = BattleTeam.new(camp)   
    local info = {npcid = npcid, level = LEVEL2, summon = false, number = 1}
    BC.initTeamAttr_Npc(team, self._heros[camp], info, x, y, 1.5, true)    
    self:_raceCountAdd(camp, team.race1, team.race2)
    self.classCount[camp][team.classLabel] = self.classCount[camp][team.classLabel] + 1
    team.noHUD = true
    self:addTeam(team)     
    -- 原始出场方阵标记
    team.cantSort = true
    team.radius = 100
    team.showHead = false
    team.soldier[1].radius = 100
    team.soldier[1]:setAltitude(altitude[1], altitude[2])
    team.soldier[1].fightPtX, team.soldier[1].fightPtY = x, y
    return team.soldier[1]
end

function BattleLogic:BattleBeginEx()
    local team
    local camp = siegeR_logic and 1 or 2
    for i = 1, #self._pylons do
        team = self._pylons[i]
        if team then
            table.removebyvalue(self._rowTeam[camp][team.row], team)
            team.row = i
            table.insert(self._rowTeam[camp][team.row], team)
        end
    end
    local soldier
    for i = 1, #self._arrows do
        soldier = self._arrows[i]
        if soldier then
            team = soldier.team
            table.removebyvalue(self._rowTeam[camp][team.row], team)
            team.row = i
            table.insert(self._rowTeam[camp][team.row], team)
        end
    end

    if not BATTLE_PROC then
        if not self._battleInfo.siegeBroken then
            local x, y = self:convertToScreenPt(self._pylons[3].x, self._pylons[3].y)
            local r = siegeR_show
            if siegeR_logic then r = not siegeR_show end
            siegeHPBar:setPosition(r and MAX_SCREEN_WIDTH - x or x, y + 80)
        end
    end
end

function BattleLogic:setCampBrightnessEx(camp, value)
    -- if camp == 1 then return end
    -- if self._aliveSiegesCount <= 0 then return end
    -- if value == 0 then
    --     for i = 1, #self._staticPylons do
    --         self._staticPylons[i]:setBrightness(0)
    --     end
    -- else
    --     for i = 1, #self._staticPylons do
    --         self._staticPylons[i]:setBrightness(-75)
    --     end
    -- end
end

function BattleLogic:updateEx()
    if not BATTLE_PROC and self._aliveSiegesCount > 0 then
        local HP, maxHP = logic:countPylonHP()
        siegeHPBar.hp:setPercent(HP / maxHP * 100)
    end
    if self._assist == 2 and self.battleBeginTick and self._assistValue <= self.battleTime then
        self:doAssist()
    end
    if self._help1Tick then
        if self._help1Tick <= self.battleTime then
            self._help1Tick = nil
            local help1 = self._intanceD["help1"]
            for i = 2, #help1 do
                local npcid = help1[i][1] 
                local x, y = help1[i][2], help1[i][3] 
                x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + x, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + y
                local team = BattleTeam.new(camp1)   

                local info = {npcid = npcid, level = 1, summon = false}
                BC.initTeamAttr_Npc(team, self._heros[camp1], info, x, y)    
                self:_raceCountAdd(camp1, team.race1, team.race2)
                self.classCount[camp1][team.classLabel] = self.classCount[camp1][team.classLabel] + 1
                self:addTeam(team)     
                if self._aliveSiegesCount > 0 then
                    team.goBack = false
                    team.__turnFire = team.turnFire
                    team.turnFire = false
                    if team.isMelee then
                        team.canTaunt = false
                    end
                end
                self:addToUpdateList(team)
            end    
        end
    end
    if self._help2Tick then
        if self._help2Tick <= self.battleTime then
            self._help2Tick = nil
            local help2 = self._intanceD["help2"]
            for i = 2, #help2 do
                local npcid = help2[i][1] 
                local x, y = help2[i][2], help2[i][3] 
                x, y = BC.MAX_SCENE_WIDTH_PIXEL * 0.5 + x, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5 + y
                local team = BattleTeam.new(camp2)   

                local info = {npcid = npcid, level = 1, summon = false}
                BC.initTeamAttr_Npc(team, self._heros[camp2], info, x, y)    
                self:_raceCountAdd(camp2, team.race1, team.race2)
                self.classCount[camp2][team.classLabel] = self.classCount[camp2][team.classLabel] + 1
                self:addTeam(team)     
                self:addToUpdateList(team)
            end        
        end
    end
    if self.battleState == EState.ING then
        if not BATTLE_PROC and self.battleTime > self._feijianTick then
            self._feijianTick = self._feijianTick + 7 + GRandom(5)
            if self._feijian == nil then
                self._feijian = mcMgr:createViewMC("jian_gongchengzhan", false, true, function ()
                    self._feijian = nil
                end)
                self._feijian:setScaleX(siegeR_show and -1 or 1)
                self._feijian:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
                self._control._uiLayer:getParent():addChild(self._feijian, -5)   
            end
        end
        if not self._battleInfo.siegeBroken and not self._halfBroken then
            if self._pylons[1].soldier[1].HP / self._pylons[1].soldier[1].maxHP < 0.5 then
                self._halfBroken = true
                if not BC.jump then
                    objLayer:playEffect_totem("yan2_chengqiangcuihuiyan", 1480 - 73, 472 - 1, true, true, 1):setScale(1.5)
                    objLayer:playEffect_totem("yan1_chengqiangcuihuiyan", 1480 - 120, 385 - 1, true, true, 1):setScale(1.5)
                    objLayer:playEffect_totem("yan1_chengqiangcuihuiyan", 1480 - 127, 245 - 1, true, true, 1):setScale(1.5)
                    objLayer:playEffect_totem("yan2_chengqiangcuihuiyan", 1480 - 80, 150 - 1, true, true, 1):setScale(1.5) 
                end
                if self._aliveSiegesCount ~= -1 then
                    if not BC.jump then
                        audioMgr:playSoundForce("broken_1")

                        for i = 1, #self._staticPylons do
                            self._staticPylons[i]:changeMotion(self._staticPylons[i].motionId + 20)
                        end
                        for i = 1, #self._pylons do
                            if self._cqchEffName then
                                objLayer:playEffect_hit1("ta1_"..self._cqchEffName, true, true, self._pylons[i].soldier[1], 2, 0.5)
                            end
                            objLayer:playEffect_hit1("baozhayan_chengqiangcuihuiyan", true, true, self._pylons[i].soldier[1], 1, 0.7)
                            self._pylons[i].soldier[1]:changeMotion(self._pylons[i].soldier[1].motionId + 20)
                        end
                        self:siegeHalf()    
                        self:shake(3, 1)
                    end
                end
                for i = 1, #self._arrows do
                    if not self._arrows[i].die then
                        self._arrows[i]:HPChange(nil, -self._arrows[i].HP, false, 1, nil, true)
                        self._arrows[i]:setVisible(false)
                    end
                end
            end
        end
    end
end

-- 覆盖该方法
function BattleLogic:teamAttackOverEx(team)
    if team.camp == camp2 and self._aliveSiegesCount > 0 then
        team:setState(ETeamStateIDLE)
    else
        team:stopMove(true)
        if BC.canMove(team) then
            team:setState(ETeamStateMOVE)
        else
            team:setState(ETeamStateIDLE)
        end
    end
    return true
end

-- 召唤生物
function BattleLogic:summonTeamEx(team)
    if team.camp == camp1 then 
        if (self._aliveSiegesCount == nil or self._aliveSiegesCount > 0)then
            team.goBack = false
        end
    end
end


local initSoldierBuff = BC.initSoldierBuff
function BattleLogic:onTeamDieEx(team)
    if team.camp == camp1 then
        self.__teamDieCount = self.__teamDieCount + 1
        if self._assist == 1 and self._assistValue == self.__teamDieCount then
            -- 触发支援
            self:doAssist()
        end
    end
    if team.isSiege then
        self._aliveSiegesCount = self._aliveSiegesCount - 1
    else
        return
    end
    if self._aliveSiegesCount == 0 then
        self._aliveSiegesCount = -1
        if not BATTLE_PROC then
            self:siegeBroken()
            audioMgr:playSoundForce("broken_2")
            siegeHPBar.hp:setPercent(0)
            siegeHPBar:runAction(cc.FadeOut:create(0.3))
            for i = 1, #self._staticPylons do
                if self._staticPylons[i].motionId ~= 18 then
                    if not BC.jump then
                        self._staticPylons[i].node:setVisible(false)
                    end
                end
            end
        end
        if not BC.jump then
            for i = 1, #self._pylons do
                self._pylons[i].soldier[1]:setZ(-999)
                if self._cqchEffName then
                    objLayer:playEffect_hit1("ta2_"..self._cqchEffName, true, true, self._pylons[i].soldier[1], 2, 0.5)
                end
                objLayer:playEffect_hit1("baozhayan_chengqiangcuihuiyan", true, true, self._pylons[i].soldier[1], 1, 0.7)
                local effname = "ta3_chengqiangcuihuiyan"
                if self._siegeD["art"] == "muyuan" then
                    effname = "ta3_cqchmuyuan"
                end
                local mc = mcMgr:createViewMC(effname, false)
                mc:setScaleX(siegeR_show and -1 or 1)
                mc:setPosition(self._pylons[i].soldier[1].x, self._pylons[i].soldier[1].y)
                mc:setLocalZOrder(-1000)
                objLayer:getView():addChild(mc)   
            end

            self:shake(3, 1)
        end

        local _team, buff, list
        for i = 1, #self._teams[camp1] do
            _team = self._teams[camp1][i]
            _team.goBack = true
            _team.turnFire = _team.__turnFire
            _team.canTaunt = true
        end
        local _team
        for i = 1, #self._teams[camp2] do
            _team = self._teams[camp2][i]
            _team.canDestroy = true
            if _team.state == ETeamStateIDLE then
                _team:setState(ETeamStateMOVE)
            end
            if _team.__attackArea then
                _team.attackArea = _team.__attackArea
            end
        end
    end
end

function BattleLogic:onSoldierDieEx(soldier)
    if soldier.team.isSiege then
        soldier:setVisible(false)
    end
end

function BattleLogic:onHPChangeEx(soldier, change)
    if soldier.team.isSiege then
        if not BC.jump then
            if GRandom(12) == 1 then
                objLayer:playEffect_hit1("shouji_chengqiangshouji", true, true, soldier, 2, 1)
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
    -- 三分钟没结果,算左边输

    if not self.guideBattleOver and self.battleTime > self._battleInfo.guideTime - 3 then
        self.guideBattleOver = true
        ViewManager:getInstance():doGuideBattleOver1()
    end
    if self.battleTime > self._battleInfo.guideTime then--COUNT_TIME then
        self:timeUp(camp2)
        return true
    end
    for i = 1, 2 do
        if self._lastTeamCount[i] == 0 and self._reviveCount[i] == 0 then
            if self._battleInfo.mustWin then
                self:Win(1)
            else
                self:Win(3 - i)
            end
            return true
        end
    end
    return false
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
    BattleTeam = nil 
    BC = nil -- BC
    BUFFID_LINGHUNLIANJIE = nil -- 4996
    cc = nil -- _G.cc
    ceil = nil -- math.ceil
    COUNT_TIME = nil
    ECamp = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil 
    EState = nil 
    ETeamState = nil
    ETeamStateIDLE = nil
    ETeamStateMOVE = nil
    ETeamStateNONE = nil
    ETeamStateDIE = nil
    floor = nil -- math.floor
    INTO_DIS = nil -- 490
    INTO_SPEED = nil -- 120
    LEVEL1 = nil -- 0
    LEVEL2 = nil -- 0
    logic = nil
    objLayer = nil
    math = nil -- math
    mcMgr = nil -- mcMgr
    next = nil -- next
    os = nil -- _G.os
    pairs = nil -- pairs
    pc = nil -- pc
    rule = nil -- {}
    siegeHPBar = nil -- nil
    tab = nil -- tab
    table = nil -- table
    tonumber = nil -- tonumber
    tostring = nil -- tostring
    cqchEffTab = nil
    abs = nil
    cqAltitude = nil
    initSoldierBuff = nil
    delayCall = nil
    siegeR_show = nil
    siegeR_logic = nil
    camp1 = nil
    camp2 = nil
end
return rule