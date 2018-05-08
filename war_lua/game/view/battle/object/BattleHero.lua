--[[
    Filename:    BattleHero.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-07-09 15:36:23
    Description: File description
--]]
local BC = BC
local table = table
local BattleHero = class("BattleHero", require("game.view.battle.object.BattleObject"))

local BATTLE_3D_ANGLE = BC.BATTLE_3D_ANGLE
local _3dVertex1 = cc.Vertex3F(BATTLE_3D_ANGLE, 0, 0)
local _3dVertex2 = cc.Vertex3F(-BATTLE_3D_ANGLE, 0, 0)
local ceil = math.ceil

local super = BattleHero.super

function BattleHero:ctor(objLayer, playerInfo, camp)
    local hero = playerInfo.hero
    local id = hero.id
    local level = hero.level
    local slevel = hero.slevel
    local star = hero.star
    local mastery = hero.mastery
    local globalMasterys = playerInfo.globalMasterys
    local treasure = playerInfo.treasure
    local npcHero = hero.npcHero
    local buff = hero.buff
    local talent = playerInfo.talent
    local hAb = hero.hAb
    local uMastery = hero.uMastery
    local skin = hero.skin
    local skillex = hero.skillex
    local skillBookTalent = playerInfo.spTalent
    local manabase = playerInfo.manabase
    local manarec = playerInfo.manarec
    local qhab = playerInfo.qhab 
    local starCharts = hero.sc
    local hStar = playerInfo.hStar 

    BATTLE_3D_ANGLE = BC.BATTLE_3D_ANGLE
    _3dVertex1 = cc.Vertex3F(BATTLE_3D_ANGLE, 0, 0)
    _3dVertex2 = cc.Vertex3F(-BATTLE_3D_ANGLE, 0, 0)
    self._layer = objLayer:getView()
    self._camp = camp
    local values, heroD
    if npcHero then
        -- npc英雄
        heroD = tab.npcHero[id]
        self.level = heroD["herolv"]
        local modeT = {
            [BattleUtils.BATTLE_TYPE_Fuben]             = 1,
            [BattleUtils.BATTLE_TYPE_ServerArenaFuben]  = 1,
            [BattleUtils.BATTLE_TYPE_ClimbTower]        = 1,
            [BattleUtils.BATTLE_TYPE_Biography]         = 1,
        }
        if (BattleUtils.CUR_BATTLE_TYPE and modeT[BattleUtils.CUR_BATTLE_TYPE]) or (BattleUtils.CUR_BATTLE_SUB_TYPE and modeT[BattleUtils.CUR_BATTLE_SUB_TYPE]) then
            -- 副本的npc英雄要使用宝物
            values = BattleUtils.getNpcHeroBaseAttr(heroD, treasure, talent, hAb, true)
        else
            values = BattleUtils.getNpcHeroBaseAttr(heroD)
        end
    else
        -- 玩家英雄
	    heroD = tab.hero[id]
        self.level = level
        local isBattleData = true
        values = BattleUtils.getHeroBaseAttr(
            heroD, 
            self.level, 
            slevel, 
            star, 
            mastery, 
            globalMasterys, 
            treasure, 
            buff, 
            talent, 
            hAb, 
            uMastery, 
            skillex, 
            playerInfo.weapons,
            isBattleData, 
            manabase and manarec,
            manabase,
            manarec,
            qhab,
            starCharts,
            hStar,
            isBattleData and BattleUtils.CUR_BATTLE_TYPE
            )

        -- 获得叠加魔法天赋值
        local isUseSkillBookTalent = true
        if BattleUtils.NO_TALENT[BattleUtils.CUR_BATTLE_TYPE]  then
           isUseSkillBookTalent = false
        end 

        if isUseSkillBookTalent and skillBookTalent then
            local skillBTalent = BattleUtils.getSkillBookTalent(skillBookTalent, values.skillReplace)
            values.skillBookTalent = skillBTalent
        end 

    end
    self.ID = id
    self.skin = skin
    self.heroD = heroD
    self.atk = values.atk
    self.def = values.def
    self.int = values.int
    self.ack = values.ack
    self.shiQi = values.shiQi
    self.ap = values.ap
    self.apAdd = values.apAdd
    self.isEnemyHero = values.isEnemyHero
    self.manaBase = values.manaBase
    self.manaMax = values.manaMax
    self.manaRec = values.manaRec
    
    self.cd = values.cd
    self.initCd = values.initCd

    self.MCD = values.MCD
    self.RI = values.RI
    self.DE = values.DE
    self.hinder = values.hinder

    self.shield = values.shield
    self.MGTPro = values.MGTPro

    -- 自己的最终属性加成
    self.attrInc = values.attrInc
    -- 降低别人的最终属性加成
    self.attrDec = values.attrDec

    self.attr = values.monsterAttr
    self.attr1 = values.monsterAttr1
    self.attr2 = values.monsterAttr2
    self.attr3 = values.monsterAttr3
    self.attr4 = values.monsterAttr4

    self.revivePro = values.revivePro
    self.reviveBuff = values.reviveBuff
    self.allReviveBuff = values.allReviveBuff
    self.skills = values.skills
    self.openSkills = values.openSkills
    self.autoSkills = values.autoSkills
    self.skillBookPassive = values.skillBookPassive
    self.weaponSkills = values.weaponSkills

    self.teamReplace = values.teamReplace

    BC.BuffReplace[camp] = values.buffReplace
    BC.BuffOpen[camp] = values.buffOpen

    -- 怪兽追加技能
    self.monsterSkill = values.monsterSkill
    self.monsterSkill1 = values.monsterSkill1
    self.monsterSkill2 = values.monsterSkill2
    self.monsterSkill3 = values.monsterSkill3
    self.monsterSkill4 = values.monsterSkill4
    self.monsterSkill5 = values.monsterSkill5

    self.summonDie_RecMana = values.summonDie_RecMana
    self.summonDie_DecCd = values.summonDie_DecCd
    self.summonCount_ApPro = values.summonCount_ApPro

    -- 显示宝物特效的宝物ID
    self.treasureEff = values.treasureEff

    self.attrValues = values

    self.skillBookTalent = values.skillBookTalent

    -- 技能解锁
    if not BATTLE_PROC then
        if camp == 1 then
            local userModel = ModelManager:getInstance():getModel("UserModel")
            local skillOpen = userModel:getSkillOpen()
            if skillOpen == nil then
                for i = 1, #self.skills do
                    -- enable
                    self.skills[i][3] = true
                end
            else
                local modeT = {
                    [BattleUtils.BATTLE_TYPE_Arena]                 = 1,
                    [BattleUtils.BATTLE_TYPE_ServerArena]           = 1,
                    [BattleUtils.BATTLE_TYPE_GuildPVP]              = 1,
                    [BattleUtils.BATTLE_TYPE_HeroDuel]              = 1,
                    [BattleUtils.BATTLE_TYPE_Training]              = 1,
                    [BattleUtils.BATTLE_TYPE_Biography]             = 1,
                    [BattleUtils.BATTLE_TYPE_GVG]                   = 1,
                    [BattleUtils.BATTLE_TYPE_GVGSiege]              = 1,
                    [BattleUtils.BATTLE_TYPE_GodWar]                = 1,
                }

                local modeReport = {
                    [BattleUtils.BATTLE_TYPE_League]                = 1,
                    [BattleUtils.BATTLE_TYPE_CloudCity]             = 1,
                    [BattleUtils.BATTLE_TYPE_CCSiege]               = 1,
                    [BattleUtils.BATTLE_TYPE_Fuben]                 = 1,
                    [BattleUtils.BATTLE_TYPE_ServerArenaFuben]      = 1,
                    [BattleUtils.BATTLE_TYPE_ClimbTower]            = 1,
                    [BattleUtils.BATTLE_TYPE_Siege]                 = 1,
                }
                if BattleUtils.CUR_BATTLE_TYPE == BattleUtils.BATTLE_TYPE_Guide then
                    self.skills[1][3] = true
                    self.skills[2][3] = true
                    self.skills[4][3] = true
                elseif (BattleUtils.CUR_BATTLE_TYPE and modeT[BattleUtils.CUR_BATTLE_TYPE]) or 
                       (BattleUtils.CUR_BATTLE_TYPE and modeReport[BattleUtils.CUR_BATTLE_TYPE] and BattleUtils.isReport) 
                    then
                        for i = 1, #self.skills do
                            -- enable
                            self.skills[i][3] = true
                        end
                else
                    for i = 1, #self.skills do
                        -- enable
                        if skillOpen[tostring(i)] and i <= 4 then
                            self.skills[i][3] = (skillOpen[tostring(i)] == 1)
                        else
                            self.skills[i][3] = true
                        end
                    end      
                end
            end
        else
            for i = 1, #self.skills do
                -- enable
                self.skills[i][3] = true
            end
        end

        self._sp = nil
        self._node = nil
        if self.skin then
            local heroSkinD = tab.heroSkin[self.skin]
            self:initSprite(heroSkinD["heroart"] or heroD["heroart"])
            self.heroHeadName = heroSkinD["halfcut"] or heroD["halfcut"]       
        else
            self:initSprite(heroD["heroart"])
            self.heroHeadName = heroD["halfcut"]
        end
    else
        for i = 1, #self.skills do
            -- enable
            self.skills[i][3] = true
        end
    end
    for i = 1, #self.skills do
        if self.skills[i][1] == 0 then
            self.skills[i][3] = false
        end 
    end

    if BattleUtils.XBW_SKILL_DEBUG and  not BATTLE_PROC then
        self:initDebugLabel()
    end 
end

function BattleHero:initDebugLabel()
    -- debug
    local label = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
    label:setColor(cc.c3b(255, 255, 120))
    label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    label:setAnchorPoint(0, 0.5)
    label:setPosition(300 + (self._camp -1) * 500, MAX_SCREEN_HEIGHT - 120)
    BC.logic._control._rootLayer:getParent():addChild(label)
    label:setLocalZOrder(2048)
    self._debugLabel = label
end

function BattleHero:clearDebugLabel()
    if self._debugLabel == nil then return end
    self._debugLabel:removeFromParent()
    self._debugLabel = nil
end

local MOTION_IDLE = "stop"
local MOTION_RUN = "run2"
local MOTION_WALK = "run"
local MOTION_CAST = "atk2"
local MOTION_WIN = "win"
function BattleHero:setScale(scale)
    if not self._sp.visible then return end
    self._sp:setScale(scale)
end

function BattleHero:setVisible(visible)
    self._sp:setVisible(visible)
    self._sp.visible = visible
end

function BattleHero:initSprite(heroart)
    local mainCamp = BC.reverse and 2 or 1

    if self._camp == mainCamp then
        self:setPos(24 * 40, 15 * 40)
    else
        self:setPos(37 * 40, 15 * 40)
    end
    if heroart == nil then return end
    self._node = cc.Node:create()
    self._node:setAnchorPoint(0.5, 0.5)
    self._node:setRotation3D(_3dVertex1)
    HeroAnim.new(self._node, heroart, {MOTION_IDLE, MOTION_RUN, MOTION_WALK, MOTION_CAST, MOTION_WIN}, function (sp)
        self._sp = sp
        self._sp:setScale(0.2)
        self._sp:setScaleX(-0.2)
        self._sp:changeMotion(MOTION_IDLE, BC.BATTLE_DISPLAY_TICK)
        self._sp:setLocalZOrder(5)
    end, false, nil, nil, true)
    self._layer:addChild(self._node)
    if self._camp == mainCamp then
        self:setPos(24 * 40, 15 * 40)
        self._node:setScaleX(-1)
    else
        self:setPos(37 * 40, 15 * 40)
    end
    if #self.treasureEff > 0 then
        for _, id in ipairs(self.treasureEff) do
            local comTreasureD = tab.comTreasure[id]
            if comTreasureD["frontstk_v"] then 
                local mc = mcMgr:createViewMC(comTreasureD["frontstk_v"], true)
                mc:setScaleX(-1)
                self._node:addChild(mc, 6)
            end
            if comTreasureD["frontstk_h"] then 
                local mc = mcMgr:createViewMC(comTreasureD["frontstk_h"], true)
                mc:setScaleX(-1)
                self._node:addChild(mc, 6)
            end
            if comTreasureD["backstk_v"] then 
                local mc = mcMgr:createViewMC(comTreasureD["backstk_v"], true)
                mc:setScaleX(-1)
                self._node:addChild(mc, 4)
            end
            if comTreasureD["backstk_h"] then 
                local mc = mcMgr:createViewMC(comTreasureD["backstk_h"], true)
                mc:setScaleX(-1)
                self._node:addChild(mc, 4)
            end
        end
    end
end

local red = cc.c3b(162, 13, 20)
local blue = cc.c3b(0, 107, 189)
local black = cc.c4b(0, 0, 0, 255)
local brown = cc.c3b(70, 40, 10)
function BattleHero:showSkillName(name)
    if not self._sp.visible then return end
    local clear = self._chatType ~= 1
    self._chatType = 1
    local chatBg = self._chatBg
    if chatBg and not clear then
        local label = chatBg.label
        if label == nil then return end
        local str = label:getString()
        if string.find(str, name) then
            return
        end
        self:_onChat(name .. "\n" .. str, clear, self._camp)
    else
        self:_onChat(name, true, self._camp)
    end
end

function BattleHero:onChat(msg, clear, color)
    if not self._sp.visible then return end
    self._chatType = 2
    self:_onChat(msg, clear, color)
end

function BattleHero:_onChat(msg, clear, color)
    if self._node == nil then return end
    if clear then
        if self._chatBg then
            self._chatBg:removeFromParent()
            self._chatBg = nil
        end
    end
    local mainCamp = BC.reverse and 2 or 1
    local camp = self._camp
    local chatBg, label
    local width1
    if clear then
        label = cc.Label:createWithTTF(msg, UIUtils.ttfName, 16)
        if color == nil then
            label:setColor(brown)
        elseif color == 1 then
            label:setColor(blue)
        else
            label:setColor(red)
        end
        if camp == mainCamp then
            chatBg = cc.Scale9Sprite:createWithSpriteFrameName("qipao_battle1.png")
            chatBg:setCapInsets(cc.rect(54, 23, 1, 1))
        else
            chatBg = cc.Scale9Sprite:createWithSpriteFrameName("qipao_battle2.png")
            chatBg:setCapInsets(cc.rect(43, 23, 1, 1))
        end
    
        chatBg.label = label
        chatBg:addChild(label)
        chatBg.label = label
        local node = cc.Node:create()
        node:setRotation3D(_3dVertex1)
        chatBg:setPositionY(85)
        node:addChild(chatBg)
        self._node:getParent():addChild(node, 1)
        if camp == mainCamp then
            node:setPosition(self._node:getPosition())
        else
            node:setPosition(self._node:getPosition())
        end
        chatBg:setLocalZOrder(self._node:getLocalZOrder())
        chatBg:setCascadeOpacityEnabled(true)
    else
        chatBg = self._chatBg
        label = chatBg.label
        label:setString(msg)

    end
    if color == nil then
        label:setColor(brown)
    elseif color == 1 then
        label:setColor(blue)
    else
        label:setColor(red)
    end

    width1 = label:getContentSize().width
    if self._chatType == 2 then
        if width1 > 136 then
            label:setDimensions(136, 0)
        else
            label:setDimensions(0, 0)
        end
    else
        label:setDimensions(0, 0)
    end

    local width
    if width1 > 136 then
        width = 170
    else
        width = width1 + 40
    end
    local height = 63 + label:getContentSize().height - 24
    if height < 63 then
        height = 63
    end
    chatBg:setContentSize(width, height)
    if camp == mainCamp then
        chatBg:setAnchorPoint(41 / width, 0)
    else
        chatBg:setAnchorPoint(1 - (41 / width), 0)
    end
    if width1 > 136 then
        label:setPosition(90, height * 0.5 + 5)
    else
        label:setPosition(width * 0.5, height * 0.5 + 5)
    end

    if clear then
        chatBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.4), cc.ScaleTo:create(0.1, 1.2), cc.DelayTime:create(1.0), cc.ScaleTo:create(0.1, 0.2), 
            cc.CallFunc:create(function () self._chatBg = nil end),
            cc.RemoveSelf:create(true)))
    else
        chatBg:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.ScaleTo:create(0.1, 0.2), 
            cc.CallFunc:create(function () self._chatBg = nil end),
            cc.RemoveSelf:create(true)))
    end
    self._chatBg = chatBg
end

function BattleHero:update(tick)
    if self.isMove then
        super.updateMove(self, tick)
    end
end

function BattleHero:displayUpdate(tick)
    if self._sp then
        self._sp:update(tick)
    end
end

function BattleHero:clear()
    if self._node then
        self:clearDebugLabel()
        self._node:removeFromParent()
        self._node = nil
        self._sp = nil
    end
end

function BattleHero:BattleBegin()
    if self._sp == nil then return end
    self._sp:changeMotion(MOTION_WIN, BC.BATTLE_DISPLAY_TICK, function ()
        self:onStop()
    end)
end

function BattleHero:Win()
    if self._sp == nil then return end
    self._sp:changeMotion(MOTION_WIN, BC.BATTLE_DISPLAY_TICK)
end

function BattleHero:Lose()
    if self._sp == nil then return end
end

function BattleHero:Cast()
    if self._sp == nil then return end
    if self._sp:getMotion() == MOTION_CAST then return end
    self._sp:changeMotion(MOTION_CAST, BC.BATTLE_DISPLAY_TICK, function ()
        self:onStop()
    end, true, nil, 8)
end

function BattleHero:onMove()
    if self._sp == nil then return end
    self._sp:changeMotion(MOTION_WALK, BC.BATTLE_DISPLAY_TICK)
end

function BattleHero:onStop()
    if self._sp == nil then return end
    self._sp:changeMotion(MOTION_IDLE, BC.BATTLE_DISPLAY_TICK)
end

function BattleHero:pause()
    if self._sp == nil then return end
    self._sp:pause()
end

function BattleHero:resume()
    if self._sp == nil then return end
    self._sp:resume()
end

function BattleHero:setPos(x, y)
    self.x, self.y = x, y
    if self._node == nil then return end
    self._node:setPosition(x, y)
    self._node:setLocalZOrder(-y)
end

function BattleHero.dtor()
    _3dVertex1 = nil --cc.Vertex3F(BATTLE_3D_ANGLE, 0, 0)
    _3dVertex2 = nil --cc.Vertex3F(-BATTLE_3D_ANGLE, 0, 0)
    BATTLE_3D_ANGLE = nil --BC.BATTLE_3D_ANGLE
     --BC.Battle_tick
    BattleHero = nil --class("BattleHero", require("game.view.battle.object.BattleObject"))
    BC = nil --BC
    black = nil --cc.c4b(0, 0, 0, 255)
    ceil = nil --math.ceil
    MOTION_CAST = nil --13
    MOTION_IDLE = nil --12
    MOTION_RUN = nil --2
    MOTION_WALK = nil --11
    MOTION_WIN = nil --9
    red = nil --cc.c3b(255, 0, 0)
    table = nil --table
    super = nil
end

return BattleHero
