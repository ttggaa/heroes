--[[
    Filename:    BattleRule_Siege_Def.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-09-22 16:37:44
    Description: File description
--]]

-- 攻城战战斗相关
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
local random = BC.ran

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

local LEVEL1 = 0
local LEVEL2 = 0
local BUFFID_LINGHUNLIANJIE = 4996
local INTO_SPEED = 120
local INTO_DIS = 490
local COUNT_TIME = 180

local siegeHPBar = nil
local uiLayer
function BattleScene:initBattleUIEx()
    self._exLayer = self._BattleView:createLayer("battle.BattleLayerSiege")
    self._uiLayer:addChild(self._exLayer, 10)
    uiLayer = self._uiLayer

    self._BattleView:getUI("uiLayer.topLayer.timeBg"):setVisible(false)
    self._BattleView:getUI("uiLayer.topLayer.timeLabel"):setPositionY(33)

    self.CountTime = COUNT_TIME

    self._proBar1 = self._BattleView:getUI("uiLayer.topLayer.pro1")
    self._proBar2 = self._BattleView:getUI("uiLayer.topLayer.pro2")
    self._proBar1:loadTexture("hpBar1_battle.png", 1)

    self._countLabel1 = self._exLayer:getUI("bg2.countBg1.countLabel1")
    self._countLabel1:setString("0")

    self._countLabel2 = self._exLayer:getUI("bg2.countBg2.countLabel2")
    self._countLabel2:setString("0")

    self._countLabel3 = self._exLayer:getUI("bg2.countBg3.countLabel3")
    self._countLabel3:setString("0")

    self._countLabel4 = self._exLayer:getUI("bg2.countBg4.countLabel4")
    self._countLabel4:setString("0")

    self._countIcon = self._exLayer:getUI("bg2.countBg3.icon")
    self._countIcon2 = self._exLayer:getUI("bg2.countBg4.icon")

    self._exLayer:getUI("bg2.countBg1.waveLabel"):enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._exLayer:getUI("bg2.countBg2.damageLabel"):enableOutline(cc.c4b(0, 0, 0, 255), 1)

    self._countBg1 = self._exLayer:getUI("bg2.countBg1")
    self._countBg2 = self._exLayer:getUI("bg2.countBg2")
    self._countBg3 = self._exLayer:getUI("bg2.countBg3")
    self._countBg4 = self._exLayer:getUI("bg2.countBg4")

    if self._battleInfo.mode == BattleUtils.BATTLE_TYPE_Siege_Def_WE then
        self._countBg3:setVisible(false)
        self._countBg4:setVisible(false)
    end

    self._countBg1:setPositionX(self._countBg1:getPositionX() + 204)
    self._countBg2:setPositionX(self._countBg2:getPositionX() + 204)
    self._countBg3:setPositionX(self._countBg3:getPositionX() + 204)
    self._countBg4:setPositionX(self._countBg4:getPositionX() + 204)

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

    self:updateMutiHpBar(100)
    
    if self._battleInfo.isReport then
        self._autoBtn:loadTextureNormal("autoBtn_battleSelected.png", 1)
        self._autoBtn.lock:setVisible(true)
        self._autoBtn:setTouchEnabled(false)
    end

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
end

function BattleScene:rewardAnim()
    self._countLabel3:stopAllActions()
    self._countLabel3:setScale(1.3)
    self._countLabel3:runAction(cc.ScaleTo:create(0.04, 1.0))

    if _countIcon then
        self._countIcon:stopAllActions()
        self._countIcon:setRotation(-20)
        self._countIcon:runAction(cc.Sequence:create(
                cc.RotateTo:create(0.02, 20),
                cc.RotateTo:create(0.02, -20),
                cc.RotateTo:create(0.02, 20),
                cc.RotateTo:create(0.02, 0)
            ))
    end 
    
    local mc = mcMgr:createViewMC("jishaguang_airenjisha", false, true)
    mc:setLocalZOrder(50)
    mc:setScale(.7)
    mc:setPosition(self._countLabel3:getPositionX() + 15, self._countLabel3:getPositionY())
    self._countLabel3:getParent():addChild(mc)
    self._countLabel3:setString(logic.rewardCount)

    self._countLabel4:stopAllActions()
    self._countLabel4:setScale(1.3)
    self._countLabel4:runAction(cc.ScaleTo:create(0.04, 1.0))

    if _countIcon then
        self._countIcon:stopAllActions()
        self._countIcon:setRotation(-20)
        self._countIcon:runAction(cc.Sequence:create(
                cc.RotateTo:create(0.02, 20),
                cc.RotateTo:create(0.02, -20),
                cc.RotateTo:create(0.02, 20),
                cc.RotateTo:create(0.02, 0)
            ))
    end 
    
    local mc = mcMgr:createViewMC("jishaguang_airenjisha", false, true)
    mc:setLocalZOrder(50)
    mc:setScale(.7)
    mc:setPosition(self._countLabel4:getPositionX() + 15, self._countLabel4:getPositionY())
    self._countLabel4:getParent():addChild(mc)
    self._countLabel4:setString(logic.rewardCount2)
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
        self._countLabel2:setString(format("%.2f", logic.damageCount / 100000000) .. "亿")
    elseif logic.damageCount > 100000 then
        self._countLabel2:setString(format("%.1f", logic.damageCount / 10000) .. "万")
    else
        self._countLabel2:setString(logic.damageCount)
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
    if self._hpUpdateTick == nil then
        self._hpUpdateTick = tick
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
    self:screenToPos(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5, false)
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
    self._frontLayer:getView():runAction(cc.Sequence:create(cc.FadeOut:create(1.0), cc.CallFunc:create(function ()
        self._frontLayer:getView():setVisible(false)
    end)))
    ScheduleMgr:delayCall(1000, self, function()
        self:realBegin()
    end)
    self:playGongChengEff() 
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

function BattleScene:countBgAnim()
    if BATTLE_PROC then return end
    local offsetX = 200
    if ADOPT_IPHONEX then
        offsetX = 265
    end 
    self._countBg1:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg1:getPositionX() - offsetX, self._countBg1:getPositionY())))
    self._countBg2:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg2:getPositionX() - offsetX, self._countBg2:getPositionY())))
    self._countBg3:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg3:getPositionX() - offsetX, self._countBg3:getPositionY())))
    self._countBg4:runAction(cc.MoveTo:create(0.2, cc.p(self._countBg4:getPositionX() - offsetX, self._countBg4:getPositionY())))
end

function BattleScene:realBegin()
    if BattleUtils.unLockSkillIndex == nil then
        self._touchMask:addClickEventListener(function () end)
        self:initBattleSkill(function ()
            self:battleBeginMC()
            ScheduleMgr:delayCall(1100, self, function()
                self:countBgAnim()
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
                    self:countBgAnim()
                    self:battleBegin()
                    self._touchMask:removeFromParent()
                end)
            end)
        end)
    end
end

-- 战斗开始动画
function BattleScene:battleBeginMCEx()
    audioMgr:playSoundForce("horn")

    local mc = mcMgr:createViewMC("chuihaodonghua_quanjunchuji", false, true)
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 14)
    self._rootLayer:getParent():addChild(mc)
    siegeHPBar:setVisible(true)
end

-- 跳过开场动画
function BattleScene:jumpBattleBeginAnimEx()

end

-- 中断开场动画
function BattleScene:battleBeginAnimCancelEx()

end

function BattleScene:onBattleEndEx(res)
    res["exInfo"] = {waveCount = logic.waveCount, damageCount = logic.damageCount, rewardCount = logic.rewardCount, rewardCount2 = logic.rewardCount2}
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
local cqchTotemTab = 
{
    ["chengbao"] = "huchenghechengbao",
    ["chengbaor"] = "huchenghechengbao",
    ["bilei"] = "huchenghebilei",
    ["muyuan"] = "huchenghemuyuan",
    ["diyu"] = "huchenghediyu",
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

    self.oneHpBarValue = self._teams[2][1].maxHP * 16
    self.waveCount = 0
    self.damageCount = 0
    self.rewardCount = 0
    self.rewardCount2 = 0

    self.__teamDieCount1 = 0
    self.__teamDieCount2 = 0

    self._siegeId = self._battleInfo.siegeId
    self._siegeD = tab.siege[self._siegeId]
    self._cqchEffName = cqchEffTab[self._siegeD["art"]]
    LEVEL1 = self._battleInfo.siegeLevel
    LEVEL2 = self._battleInfo.arrowLevel

    if not BATTLE_PROC then
        self._heros[camp2]:setPos(650, 12 * 40)
    end

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

    local spwanIndexMap = {}
    local siegeBattleGroupD = self._battleInfo.siegeBattleGroupD
    local defultMonsters = siegeBattleGroupD["defultMonsters"]
    for i = 1, #defultMonsters do
        spwanIndexMap[siegeBattleGroupD["m"..defultMonsters[i]]] = defultMonsters[i]
    end
    if siegeR_logic then dis = -dis end
    for i = 1, #self._teams[camp1] do
        team = self._teams[camp1][i]
        team.goBack = false
        team.__turnFire = team.turnFire
        team.turnFire = false
        team.original = false
        team.summon = true
        team.spwanIndex = spwanIndexMap[team.D["id"]]
        if team.isMelee then
            team.canTaunt = false
        end
    end
    
    if not self._battleInfo.siegeBroken then
        -- 右边为待机
        local team
        for i = 1, #self._teams[camp2] do
            team = self._teams[camp2][i]
            if team.isMelee then
                if team.walk then
                    team:setState(ETeamStateIDLE)
                    team.canDestroy = false
                    team.__attackArea = team.attackArea
                    team.attackArea = -1
                end
            else
                team:setState(ETeamStateIDLE)
                team.canDestroy = false
                team.__attackArea = team.attackArea
                team.attackArea = team.attackArea + 400
            end
        end
    end
    
    local posx1 = {xx - 73, xx - 120, xx - 127, xx - 80}
    local posy1 = {yy + 152, yy + 65, yy - 75, yy - 170}
    if not self._battleInfo.siegeBroken then
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
        if LEVEL2 > 0 then
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
        end             
    else
        self._aliveSiegesCount = -1
        self:siegeBroken()
    end
    self._halfBroken = false


    if not BATTLE_PROC then
        self._feijianTick = 5 + GRandom(5)
    end

    self.waveCount = self.waveCount + 1

    -- 护城河图腾
    self._moatattrObjects = {}
    if not self._battleInfo.siegeBroken and self._battleInfo.totemLevel > 0 then
        local moatattrObject = self._siegeD["moatattrObject"]
        if moatattrObject then
            local objectD = tab.object[moatattrObject[1]]
            local level = self._battleInfo.totemLevel or moatattrObject[2]
            local attacker = self._teams[1][1].soldier[1]
            local offsetX
            if siegeR_logic then
                offsetX = 80
            else
                offsetX = -80
            end
            for i = 1, 4 do
                -- 护城河图腾
                self._moatattrObjects[i] = self:addTotemToPos(objectD, level, attacker, posx1[i] + offsetX, posy1[i])
            end

            if not BATTLE_PROC then
                local siegeBg = self._control._mapLayer:getSiegeLayer()
                local mc = mcMgr:createViewMC(self._siegeD["art"].."_"..cqchTotemTab[self._siegeD["art"]], true, false)
                if siegeBg:isFlippedX() then
                    mc:setScaleX(-1)
                    mc:setPosition(0, 0)
                else
                    mc:setPosition(siegeBg:getContentSize().width, 0)
                end
                
                siegeBg:addChild(mc)
            end
        end
    end

    -- 冲车, 箭塔优先攻击
    self._chongChes = {}
    self._canTurnFireTick = 0

    -- 敌方英雄无CD
    self:setCDPro2(0)

    self:initSpawnParam()
end

-- 初始化刷怪参数
function BattleLogic:initSpawnParam()
    local siegeBattleGroupD = self._battleInfo.siegeBattleGroupD
    local sequence = siegeBattleGroupD["sequence"]
    local levelup = siegeBattleGroupD["levelup"]
    local dietrigger = siegeBattleGroupD["dietrigger"]
    local cd = siegeBattleGroupD["cd"]
    local roundPos = siegeBattleGroupD["roundPos"]
    
    local spawnList = clone(sequence)

    self._siegeBattleGroupD = siegeBattleGroupD

    self._spawnListIndex = 1
    self._spawnList = spawnList

    -- 初始等级增加
    self._spawnLevel = tab.svEnforcement[self._battleInfo.defWin or 0]["enforcement"]

    self._spawnLevelInv = levelup

    self._spawnCD = cd

    self._dietrigger = dietrigger

    self._canSpawnTick = cd

    self.killCount = 0
    self._spawnKillCount = self._dietrigger[1]

    self._roundPos = roundPos

    -- 重复利用怪，数组，下标为1-12对应m1-m12
    self._dieMonsters = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}

    local eliteInernal = siegeBattleGroupD["eliteInernal"]
    
    self._tip1 = {}
    if eliteInernal then
        for i = 1, #eliteInernal do
            self._tip1[eliteInernal[i]] = 1
        end
    end

    local bossInernal = siegeBattleGroupD["bossInernal"]
    
    self._tip2 = {}
    if bossInernal then
        for i = 1, #bossInernal do
            self._tip2[bossInernal[i]] = 1
        end
    end

    self._heroMana = siegeBattleGroupD["heroMana"]
end

function BattleLogic:updateSpawn()
    local tick = self.battleTime
    if self.killCount >= self._spawnKillCount and tick > self._canSpawnTick then
        self._canSpawnTick = tick + self._spawnCD
        self.killCount = self.killCount - self._spawnKillCount
        self:spawnMonster()
    end
end

-- 刷怪
local spawnPos = {1, 5, 9, 13, 1, 5, 9, 13, 1, 5, 9, 13, 1, 5, 9, 13}
function BattleLogic:spawnMonster()
    self.waveCount = self.waveCount + 1
    if ((self.waveCount - 1) % self._spawnLevelInv) == 0 then
        -- 等级提升
        self._spawnLevel = self._spawnLevel + 1
    end
    local spawnGroup = self._spawnList[self._spawnListIndex]
    self._spawnListIndex = self._spawnListIndex + 1
    if self._spawnListIndex > #self._spawnList then
        self._spawnListIndex = self._roundPos
    end
    self._spawnKillCount = self._dietrigger[self._spawnListIndex]

    -- 增加回蓝
    self.manaRec[2] = self._heroMana[self._spawnListIndex]
    -- self:EnemyManaRec(0.1)
    -- pcall(function ()
    self:showWarning(self._spawnListIndex)--, lang(tab.npc[siegeBattleGroupD["m"..spawnGroup[1]]]["name"]))
    -- end)
    local monster, index
    local siegeBattleGroupD = self._siegeBattleGroupD
    local offsetX = 100
    local count = 0
    for i = 1, #spawnGroup do
        index = spawnGroup[i]
        monster = siegeBattleGroupD["m"..index]
        self:createMonster(index, monster, spawnPos[i], offsetX)
        count = count + 1
        if count >= 4 then
            count = 0
            offsetX = offsetX + 100
        end
    end
    -- local count = 0
    -- for i = 1, #self._teams[2] do
    --     if self._teams[2][i].state ~= ETeamStateDIE then
    --         count = count + 1
    --     end
    -- end
    -- print("shua", self._spawnListIndex - 1, #spawnGroup, count + self.killCount)
end

local getFormationScenePos = BC.getFormationScenePos
local getRowIndex = BC.getRowIndex
local getPosInFormation = BC.getPosInFormation
local ATTR_COUNT = BC.ATTR_COUNT
function BattleLogic:createMonster(index, npcid, pos, offsetX)
    local x, y = getFormationScenePos(pos, 2)
    x = x + offsetX
    local dieMonster = self._dieMonsters[index]

    local id, team = next(dieMonster)
    if team == nil then
        team = BattleTeam.new(2)   

        local info = {npcid = npcid, level = self._spawnLevel, summon = false}
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
        team.spwanIndex = index
        team.summon = true
        self:addToUpdateList(team)

        if team.label1 == 9 then
            self._chongChes[team.ID] = team
        end
    else
        if team.level ~= self._spawnLevel then
            -- 怪物升级
            local soldier, baseAttr, D, attr
            local soldiers = team.soldier
            for i = 1, #soldiers do
                soldier = soldiers[i]
                baseAttr = soldier.baseAttr
                D = team.D
                for k = 1, ATTR_COUNT do
                    attr = D["a"..k]
                    if attr then
                        baseAttr[k] = baseAttr[k] + attr[2]
                    end
                end
                soldier.baseSum = nil
                soldier:resetAttr()
            end
        end
        self:teamRevive(team, true)
        local newRow = getRowIndex(y)
        if newRow ~= team.row then
            table.removebyvalue(self._rowTeam[2][team.row], team)
            team.row = newRow
            table.insert(self._rowTeam[2][team.row], team)
        end

        local volume = team.volume
        local soldiers = team.soldier
        for i = 1, #soldiers do
            soldiers[i]:setPos(getPosInFormation(x, y, i, volume, 2))
        end
        team.x = x
        team.y = y
        dieMonster[id] = nil
    end
    team.posDirty = 99
    team.dynamicCD = self.dynamicCD
    team.dynamicPreCD = self.battleTime + random(self.dynamicCD)
end

function BattleLogic:clearEx()
    logic = nil
    objLayer = nil
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

    local buff = BC.initSoldierBuff(BUFFID_LINGHUNLIANJIE, 1, team.soldier[1].caster, team.soldier[1])
    team.soldier[1]:addBuff(buff)

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
    -- self:showWarning()
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
            if self._pylons[1].soldier[1].HP / self._pylons[1].soldier[1].maxHP < 0.1 then
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
            else
                if self.battleTime > self._canTurnFireTick then
                    local id, chongChe = next(self._chongChes)
                    if chongChe then
                        self._canTurnFireTick = self.battleTime + 1
                        local arrow = self._arrows
                        local team
                        for i = 1, #arrow do
                            team = arrow[i].team
                            if team.targetT and team.targetT.label1 ~= 9 then
                                -- 转火
                                self:teamAttackOver(team)
                                self:attackToTarget(team, chongChe)
                            end
                        end
                    end
                end
            end
        end
    end
    self:updateSpawn()
end

-- 覆盖该方法
function BattleLogic:teamAttackOverEx(team)
    if team.camp == camp2 and self._aliveSiegesCount > 0 and team.walk then
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

function BattleLogic:onTeamDieEx(team)
    if team.isSiege then
        self._aliveSiegesCount = self._aliveSiegesCount - 1
    else
        self._chongChes[team.ID] = nil
        if team.camp == 2 and team.spwanIndex then
            self.killCount = self.killCount + 1
            local __index = team.spwanIndex
            local __ID = team.ID
            local __team = team
            delayCall(3, self, function ()
                self._dieMonsters[__index][__ID] = __team
            end)
            local t = self.battleTime / 180
            local defWin = self._battleInfo.defWin
            local damageCount = self.damageCount
            self.rewardCount = ceil(1000 * (1 + 0.05 * defWin) * (2 * t) / (1 + t))
            self.rewardCount2 = ceil(50000 * (1 + 0.05 * defWin) * (1.2 * damageCount) / (damageCount + 100000000 + 10000000 * defWin))
            if not BATTLE_PROC then
                if self._battleInfo.mode ~= BattleUtils.BATTLE_TYPE_Siege_Def_WE then
                    self._control:rewardAnim()
                end
            end
        end
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

        for i = 1, #self._moatattrObjects do
            self._moatattrObjects[i]._endTick = 0
        end
        self._moatattrObjects = {}
    end
end

function BattleLogic:showWarning(wave, name)
    if BATTLE_PROC then return end
    local _type = 1
    if self._tip1[wave] then
        _type = 1

    elseif self._tip2[wave] then
        _type = 2
    else
        return
    end
    if _type == 1 then
        local mc = mcMgr:createViewMC("chongchetexiao_gongchengtanchuang", false, true)
        uiLayer:addChild(mc)
        mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 200)
        local label1 = cc.Label:createWithTTF("冲车", UIUtils.ttfName, 28)
        label1:setColor(cc.c3b(255, 215, 29))
        label1:setPositionX(-34)
        mc:getChildren()[2]:addChild(label1)
        local label2 = cc.Label:createWithTTF("即将来袭", UIUtils.ttfName, 28)
        label2:setColor(cc.c3b(255, 255, 255))
        label2:setPositionX(50)
        mc:getChildren()[2]:addChild(label2)
    else
        local mc = mcMgr:createViewMC("bosschuchang_gongchengtanchuang", false, true)
        uiLayer:addChild(mc)
        mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 200)
        local label1 = cc.Label:createWithTTF("BOSS", UIUtils.ttfName, 28)
        label1:setColor(cc.c3b(255, 0, 0))
        label1:setPosition(-84, -3)
        mc:getChildren()[1]:addChild(label1)
        local label2 = cc.Label:createWithTTF("即将抵达战场", UIUtils.ttfName, 28)
        label2:setColor(cc.c3b(255, 255, 255))
        label2:setPosition(40, -3)
        mc:getChildren()[1]:addChild(label2)
    end
end

function BattleLogic:onSoldierDieEx(soldier)
    if soldier.team.isSiege then
        soldier:setVisible(false)
    end
    local count = 0
    local teams = self._teams[2]
    for i = 1, #teams do
        count = count + teams[i].hurt
    end
    self.damageCount = count
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
    BUFF_ID_SHIQIGAOZHANG = nil
    delayCall = nil
    siegeR_show = nil
    siegeR_logic = nil
    camp1 = nil
    camp2 = nil
end
return rule