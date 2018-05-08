--[[
    Filename:    BattleObjectLayer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-29 12:52:17
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
local mcMgr = mcMgr

local ETeamState = BC.ETeamState
local EMotion = BC.EMotion
local EDirect = BC.EDirect
local ECamp = BC.ECamp
local EState = BC.EState

local EEffFlyType = BC.EEffFlyType
-- 此层包括人物 战斗建筑 等等元件

local SpriteFrameAnim = SpriteFrameAnim
local MovieClipAnim = MovieClipAnim
local BattleObjectLayer = class("BattleObjectLayer")

local sfc = cc.SpriteFrameCache:getInstance()
local MAX_COUNT_HUD = 100

local BATTLE_3D_ANGLE = BC.BATTLE_3D_ANGLE
local GLOBAL_SP_SCALE = 0.9
local sfResMgr = sfResMgr
local _3dVertex1 = cc.Vertex3F(BATTLE_3D_ANGLE, 0, 0)
local _3dVertex2 = cc.Vertex3F(-BATTLE_3D_ANGLE, 0, 0)
local battleTick

local MCSPEEDK = 0.6

local abs = math.abs

-- 是否开启牛逼影子
local ENABLE_REAL_SHADOW = false

local SHADOW_SCALE = 0.5
local frameInv

local BC_reverse = BC.reverse
local mainCamp = BC_reverse and 2 or 1

local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL

local HUD_TYPE
-- 显示单兵血条的血上限
local SHOW_HP_PRO = 1.0

function BattleObjectLayer:ctor(objLayer)
    frameInv = BC.frameInv
    _3dVertex1 = cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0)
    _3dVertex2 = cc.Vertex3F(-BC.BATTLE_3D_ANGLE, 0, 0)
    battleTick = BC.BATTLE_DISPLAY_TICK
    sfc:addSpriteFrames("asset/role/shadow.plist", "asset/role/shadow.png")
    self._animShadowCache = {}
    self:_cacheAnimShadow(51, 6)
    self._rootLayer = objLayer

    self._skillArea = mcMgr:createMovieClip("fanweiquan_skillarea")
    self._skillArea:setVisible(false)
    self._skillArea:setCascadeColorEnabled(true)
    self._skillArea:setCascadeOpacityEnabled(true)
    self._skillArea:stop()
    self._rootLayer:addChild(self._skillArea, -10001)

    self._skillArea2 = cc.Sprite:createWithSpriteFrameName("skillAreaLine_battle.png")
    self._skillArea2:setVisible(false)
    self._rootLayer:addChild(self._skillArea2, -10001)

    self._skillArea3 = mcMgr:createMovieClip("dazhaofanwei_skillarea")
    self._skillArea3:setVisible(false)
    self._skillArea3:setCascadeColorEnabled(true)
    self._skillArea3:setCascadeOpacityEnabled(true)
    self._skillArea3:stop()
    self._rootLayer:addChild(self._skillArea3, -10001)

    if ENABLE_REAL_SHADOW then
        self._shadowTexture = cc.RenderTexture:create(BC.MAX_SCENE_WIDTH_PIXEL * SHADOW_SCALE, BC.MAX_SCENE_HEIGHT_PIXEL * SHADOW_SCALE, RGBART)
        self._shadowTexture:setPosition(BC.MAX_SCENE_WIDTH_PIXEL * 0.5, BC.MAX_SCENE_HEIGHT_PIXEL * 0.5)
        self._shadowTexture:setLocalZOrder(-10000)
        self._shadowTexture:getSprite():setOpacity(90)
        self._shadowTexture:getSprite():setScale(1 / SHADOW_SCALE)
        self._shadowTexture:getSprite():getTexture():setAntiAliasTexParameters()
        self._rootLayer:addChild(self._shadowTexture)
    end
    self._shadowLayer = cc.SpriteBatchNode:create("asset/role/shadow.png")
    if ENABLE_REAL_SHADOW then
        self._shadowLayer:setScale(SHADOW_SCALE)
        self._shadowLayer:retain()
    end

    self._black = ccui.Layout:create()
    self._black:setLocalZOrder(9999)
    self._black:setRotation3D(_3dVertex1)
    self._black:setBackGroundColorOpacity(255)
    self._black:setBackGroundColorType(1)
    self._black:setBackGroundColor(cc.c3b(0,0,0))
    self._black:setContentSize(BC.MAX_SCENE_WIDTH_PIXEL, BC.MAX_SCENE_HEIGHT_PIXEL)
    self._black:setOpacity(0)
    self._rootLayer:addChild(self._black)
    if not ENABLE_REAL_SHADOW then
        self._shadowLayer:setLocalZOrder(-10000)
        self._shadowLayer:setCascadeOpacityEnabled(true)
        self._shadowLayer:setOpacity(100)
        self._rootLayer:addChild(self._shadowLayer)
    end

    self._effectMgr = require("game.view.battle.logic.BattleEffectManager").new(self._rootLayer)

    self._objs = {}

    self._updateIndex = 1

    -- 一般, 不需要卡动作帧的MC
    self._mcPool = {}

    self._mcUpdatePool = {}
    self._mcUpdate = true

    -- 击飞池
    self._hitFlyPools = {}
    -- 吹飞池
    self._windFlyPools = {}

    self._hudPool = {}
    for i = 1, MAX_COUNT_HUD do
        local hpLabel = cc.Label:createWithBMFont(UIUtils.bmfName_red, "")
        hpLabel.tick = battleTick
        hpLabel:setAdditionalKerning(-5)
        
        local labelnode = cc.Node:create()
        labelnode:addChild(hpLabel)
        labelnode:setLocalZOrder(9998)
        labelnode:setRotation3D(_3dVertex1)
        hpLabel.node = labelnode
        self._rootLayer:addChild(labelnode)  
        self._hudPool[i] = hpLabel
    end
    self._hudIndex = 1

    -- 阵营sp容器, 用于调整亮度
    self._camp = {{}, {}}
    self._building = {}

    -- 方阵选中状态框
    local bg = cc.Node:create()
    bg = cc.Node:create()
    bg:setRotation3D(_3dVertex1)
    self._rootLayer:addChild(bg)
    local bg1 = cc.Sprite:createWithSpriteFrameName("head1_battle.png")
    bg:addChild(bg1)
    local icon = cc.Sprite:create()
    icon:setScale(0.48)
    icon:setPosition(25, 25)
    bg1:addChild(icon, -1)
    local bg2 = cc.Sprite:createWithSpriteFrameName("hp1_battle.png")
    bg:addChild(bg2)

    local hp = ccui.LoadingBar:create("hp2_battle.png", 1, 100)
    hp:setPosition(24, 20)
    bg2:addChild(hp)

    bg:setScale(0.8)
    bg.bg1 = bg1
    bg.bg2 = bg2
    bg.icon = icon
    bg.hp = hp
    bg:setLocalZOrder(10000)
    self._selectTeamBg = bg
    self._selectTeamBg:setVisible(false)

    if BattleUtils.XBW_SKILL_DEBUG then
        for i = 1, 16 do
            local label = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
            label:setColor(cc.c3b(255, 255, 120))
            label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
            label:setAnchorPoint(0, 0.5)
            label:setPosition(100, (i - 1) * 20)
            bg:addChild(label)
            bg["label"..i] = label
        end
    end

    -- 通用buff图标池
    self._commonBuffPool = {}
    -- 通用buff属性图标池
    self._commonAttrPool = {}

    -- 方阵死亡图标
    -- id 是方阵DI
    self._teamDieIcon = {}

    -- 方阵血条
    self._teamHUD = {}

    -- 技能范围选择, 判断是否需要检查在不在范围内
    self._campBright = {false, false}
    -- 优化, 每次只更新一部分
    self._campBrightAreaCheckIndex = {1, 1}

    -- NPC脚下光环
    self._teamHalo = {}
end

function BattleObjectLayer:_cacheAnimShadow(id, maxFrame)
    self._animShadowCache[id] = {}
    local arr = self._animShadowCache[id]
    local strF = "shadow_"..id.."_"
    local sf
    for i = 1, maxFrame do
        sf = sfc:getSpriteFrame(strF..i..".png")
        arr[i] = sf
    end
    for i = 1, maxFrame - 1 do
        arr[i].next = arr[i + 1]
    end
    arr[maxFrame].next = arr[1]
end

function BattleObjectLayer:getView()
    return self._rootLayer
end

function BattleObjectLayer:initLayer(sceneLayer, uiLayer)
    self._sceneLayer = sceneLayer
    self._uiLayer = uiLayer

    self._skillNameNode = cc.Node:create()
    self._uiLayer:addChild(self._skillNameNode)

    self._skillLine = cc.Sprite:createWithSpriteFrameName("skillline_battle.png")
    self._skillLine:setAnchorPoint(0.5, 0)
    self._uiLayer:addChild(self._skillLine)

    self._teamHUDNode = cc.Node:create()
    self._uiLayer:addChild(self._teamHUDNode)

    self._totemLayer = cc.Node:create()
    self._uiLayer:addChild(self._totemLayer)

    local name = cc.Label:createWithTTF("", UIUtils.ttfName, 30)
    name:enableOutline(cc.c4b(121, 65, 0, 255), 2)
    name:setColor(cc.c3b(251, 238, 196))
    name:enable2Color(1, cc.c4b(255, 193, 40, 255))
    name:setPositionY(22)
    self._skillNameNode:addChild(name)
    self._skillNameNode.name = name

    local des = cc.Label:createWithTTF("", UIUtils.ttfName, 24)
    des:setColor(cc.c3b(255, 255, 255))
    des:enableOutline(cc.c4b(121, 65, 0, 255), 2)
    des:setPositionY(-8)
    self._skillNameNode:addChild(des)
    self._skillNameNode.des = des

    self._skillNameNode:setVisible(false)
    self._skillLine:setVisible(false)
end

function BattleObjectLayer:enableBlack()
    self._black:setOpacity(80)
end

function BattleObjectLayer:disableBlack()
    self._black:setOpacity(0)
end

function BattleObjectLayer:beforeClear()
    self._isBeforeClear = true
end

function BattleObjectLayer:replay()
    battleTick = BC.BATTLE_DISPLAY_TICK
    self._effectMgr:reset()

    self._shadowLayer = cc.SpriteBatchNode:create("asset/role/shadow.png")
    if not ENABLE_REAL_SHADOW then
        self._shadowLayer:setLocalZOrder(-10000)
        self._shadowLayer:setCascadeOpacityEnabled(true)
        self._shadowLayer:setOpacity(85)
        self._rootLayer:addChild(self._shadowLayer)
    end

    self._hudPool = {}
    for i = 1, MAX_COUNT_HUD do
        local hpLabel = cc.Label:createWithBMFont(UIUtils.bmfName_red, "")
        hpLabel.tick = battleTick
        hpLabel:setAdditionalKerning(-5)
        
        local labelnode = cc.Node:create()
        labelnode:addChild(hpLabel)
        labelnode:setLocalZOrder(9998)
        labelnode:setRotation3D(_3dVertex1)
        hpLabel.node = labelnode
        self._rootLayer:addChild(labelnode)  
        self._hudPool[i] = hpLabel
    end
    self._hudIndex = 1

    self._objs = {}

    self._updateIndex = 1

    self._camp = {{}, {}}
    self._building = {}

    self._skillArea = mcMgr:createMovieClip("fanweiquan_skillarea")
    self._skillArea:setVisible(false)
    self._skillArea:setCascadeColorEnabled(true)
    self._skillArea:setCascadeOpacityEnabled(true)
    self._skillArea:stop()
    self._rootLayer:addChild(self._skillArea, -10001)

    self._skillArea2 = cc.Sprite:createWithSpriteFrameName("skillAreaLine_battle.png")
    self._skillArea2:setVisible(false)
    self._rootLayer:addChild(self._skillArea2, -10001)

    self._skillArea3 = mcMgr:createMovieClip("dazhaofanwei_skillarea")
    self._skillArea3:setVisible(false)
    self._skillArea3:setCascadeColorEnabled(true)
    self._skillArea3:setCascadeOpacityEnabled(true)
    self._skillArea3:stop()
    self._rootLayer:addChild(self._skillArea3, -10001)
    
    self._black = ccui.Layout:create()
    self._black:setLocalZOrder(9999)
    self._black:setRotation3D(_3dVertex1)
    self._black:setBackGroundColorOpacity(255)
    self._black:setBackGroundColorType(1)
    self._black:setBackGroundColor(cc.c3b(0,0,0))
    self._black:setContentSize(BC.MAX_SCENE_WIDTH_PIXEL, BC.MAX_SCENE_HEIGHT_PIXEL)
    self._black:setOpacity(0)
    self._rootLayer:addChild(self._black)

    self._objs = {}
    self._mcPool = {}
    self._mcUpdatePool = {}
    self._commonBuffPool = {}
    self._commonAttrPool = {}
    self:clearTeamHalo()
    self._selectTeamBg = nil
    self:hideAllTeamHUD()
    self:delAllTeamHUD()
end

function BattleObjectLayer:destroy()
    self:clear()
    self._effectMgr:destroy()
end

function BattleObjectLayer:clear()
    local count = #self._objs
    local node
    for i = 1, count do
        local node = self._objs[i].node
        local sp = self._objs[i].sp
        if sp then
            sp:clear()
        end 
        self._objs[i] = nil
    end
    self._totemLayer:removeAllChildren()
    self._objs = {}
    self._mcPool = {}
    self._mcUpdatePool = {}
    self._commonBuffPool = {}
    self._commonAttrPool = {}
    self._hitFlyPools = {}
    self._windFlyPools = {}
    self:clearTeamHalo()
    if ENABLE_REAL_SHADOW then
        self._shadowTexture:retain()
    end
    self._selectTeamBg = nil
    self._effectMgr:clear()
    self._updateIndex = 1
    self:hideAllTeamHUD()
    self:delAllTeamHUD()
    if not BC.jump then
        if ENABLE_REAL_SHADOW then
            self._shadowLayer:release()
        end
        sfc:removeSpriteFramesFromFile("asset/role/shadow.plist")
        cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/role/shadow.png")
    else
        if ENABLE_REAL_SHADOW then
            self._shadowLayer:removeAllChildren()
            self._rootLayer:addChild(self._shadowTexture)
        end
    end
    if ENABLE_REAL_SHADOW then
        self._shadowTexture:release()
    end
    ScheduleMgr:cleanMyselfDelayCall(self)
end

local EMotionCAST1 = EMotion.CAST1
local EMotionCAST2 = EMotion.CAST2
local EMotionCAST3 = EMotion.CAST3
local EMotionATTACK = EMotion.ATTACK
local EMotionIDLE = EMotion.IDLE
local EMotionMOVE = EMotion.MOVE
local EMotionDIE = EMotion.DIE
local EMotionBORN = EMotion.BORN

local enable_shadow = true
local kscale = 0.16
local kmaxalpha = 229
local hpBar_type = {1, 1, 2, 2, 3, 3}
local AnimAP = require "base.anim.AnimAP"
function BattleObjectLayer:createObj(soldier, id, dieExist, camp, scale, x, y, res, shadow, shadowScale, isBuilding, init)
    if BC.jump then return end
    local picname, animClass, param1, param2, _type, dieType, dieShadow
    if res == nil then
        animClass = NullAnim
        _type = 3
        shadow = nil
        dieType = 2
    else
        if AnimAP["mcList"][res] then
            scale = scale * AnimAP["mcList"][res]["scale"]
            dieShadow = AnimAP["mcList"][res]["dieShadow"]
            picname = res
            animClass = MovieClipAnim
            param1 = (camp == 2)
            param2 = (init == 0)
            _type = 2
            dieType = 2
        else
            picname = res
            animClass = SpriteFrameAnim
            param1 = (camp == 2)
            param2 = nil
            _type = 1
            dieType = 2
        end
    end
    local obj = {camp = camp, soldier = soldier, dieExist = dieExist, scale = scale, node = nil, sp = nil, die = false, 
                dieTick = nil, dieType = dieType, x = 0, y = 0, dieShadow = dieShadow, hasDie = true, animType = _type,
                altitude = 0, shadowType = 0, hitFly = -1, windFly = -1}
    self._objs[id] = obj
    local node = cc.Node:create()
    node:setAnchorPoint(0.5, 0.5)
    local scaleNode = cc.Node:create()
    scaleNode:setAnchorPoint(0.5, 0.5)
    node:addChild(scaleNode)
    local role = cc.Node:create()
    role:setCascadeColorEnabled(true)
    role.y = 0
    scaleNode:addChild(role)
    node.scaleNode = scaleNode
    node.scale = 1
    node.role = role
    role:setAnchorPoint(0.5, 0.5)
    node:setRotation3D(_3dVertex1)
    obj.node = node
    obj.tick = battleTick
    local sp = animClass.new(node.role, picname, function (sp)
        sp.role = role
        sp.node = node
        sp.obj = obj
        sp:setScale(scale * GLOBAL_SP_SCALE)
        sp.soldier = soldier
        if not isBuilding then
            self._camp[camp][#self._camp[camp] + 1] = sp
        else
            self._building[#self._building + 1] = sp
        end
        obj.hasDie = sp:hasDie()
        if not obj.hasDie then
            obj.dieType = 1
        end
        if enable_shadow then
            local fnode = cc.Node:create()
            fnode:setLocalZOrder(8888)
            fnode:setRotation3D(_3dVertex1)
            self._rootLayer:addChild(fnode)
            node:setPositionNode(fnode)
            node.fnode = fnode

            -- 单兵血条
            local team = soldier.team
            local volume = team.volume
            local hpbg = cc.Sprite:createWithSpriteFrameName("soldier_hud_bg_"..volume..".png")
            hpbg:setCascadeOpacityEnabled(true)
            fnode:addChild(hpbg)
            local ap = sp:getAp(2)
            local w, h = sp:getSize()
            hpbg.h = ap[2] * scale - h * 0.2 * scale
            hpbg:setPosition(0, hpbg.h)

            local hudCamp = BC_reverse and 3 - camp or camp
            local hp = cc.Sprite:createWithSpriteFrameName("soldier_hud_"..hudCamp.."_"..volume..".png")
            hp:setAnchorPoint(0, 0)
            hpbg:addChild(hp)
            hpbg:setVisible(false)
            hpbg.visible = false
            hpbg.hpPro2 = 1
            hpbg:setScale(0.5)
            obj.hp = hp
            obj.hpbg = hpbg
            sp.hpbg = hpbg
            sp.hp = hp
      
            if shadow and shadow > 0 then
                if shadow < 5 then
                    obj.shadowType = 1
                    local shadow = cc.Sprite:createWithSpriteFrameName("shadow_"..shadow..".png")
                    shadow:setAnchorPoint(0.5, 0.5)
                    if shadowScale then
                        shadow.scale = scale * 1.5 * shadowScale
                        shadow:setScale(shadow.scale)
                    else
                        shadow.scale = scale * 1.5
                        shadow:setScale(shadow.scale)
                    end
                    shadow:setRotation3D(_3dVertex2)
                    self._shadowLayer:addChild(shadow)
                    fnode:setPositionNode(shadow)
                    
                    obj.shadow = shadow

                    if obj.dir then
                        node.role:setScaleX(obj.dir)
                        obj.shadow:setFlipX(obj.dir < 0)
                    end
                elseif shadow > 50 then
                    obj.shadowType = 2
                    -- 序列帧影子
                    local ran = GRandom(6)
                    local frame = self._animShadowCache[shadow][ran]
                    local _shadow = cc.Sprite:createWithSpriteFrame(frame)
                    _shadow.scale = scale * team.artzoom
                    _shadow.curFrame = frame
                    _shadow:setScale(_shadow.scale)
                    _shadow.nextUpdate = BC.BATTLE_DISPLAY_TICK + 0.0214 * ran
                    obj.shadow = _shadow
                    node.role:addChild(_shadow, 2)        
                end
            end
        end
    end, param1, nil, nil, param2) 
    obj.sp = sp


    self._rootLayer:addChild(node)
    return node
end

function BattleObjectLayer:getRoleCenterScreenPt(id)
    local obj = self._objs[id]
    local sp = obj.sp
    return obj.node:nodeConvertToScreenSpace(0, sp:getAp(1)[2] * sp:getScale())
end

function BattleObjectLayer:changeRes(id, resname, cacheColor)
    if BC.jump then return end
    local obj = self._objs[id]
    obj.sp:changeRes(resname, cacheColor)
end

function BattleObjectLayer:getMotionFrame(id)
    if BC.jump then return end
    local obj = self._objs[id]
    return obj.sp:getMotionFrame()
end

function BattleObjectLayer:setDirect(id, dir)
    if BC.jump then return end
    local obj = self._objs[id]
    if obj.dir ~= dir then
        local node = obj.node
        if BC_reverse then
            node.role:setScaleX(-dir)
            if obj.shadow then
                obj.shadow:setFlipX(dir > 0)
            end
        else
            node.role:setScaleX(dir)
            if obj.shadow then
                obj.shadow:setFlipX(dir < 0)
            end
        end
        obj.dir = dir
    end
end

-- 设置人物缩放
function BattleObjectLayer:setScale(id, scale, now)
    if BC.jump then return end
    local obj = self._objs[id]
    local node = obj.node
    node.destScale = scale
    if now then
        node:setScale(scale)
        node.scale = scale
        local shadow = obj.shadow
        if shadow then
            shadow:setScale(shadow.scale * scale)
        end
    end
end

-- update缩放
function BattleObjectLayer:_updateScale(obj)
    local node = obj.node
    local scale = node.scale
    local dScale = node.destScale
    if dScale == scale then return end
    scale = scale + (dScale - scale) * 0.1
    if math.abs(scale - dScale) < 0.05 then
        scale = node.destScale
    end
    node:setScale(scale)
    node.scale = scale

    local sp = obj.sp
    local spScale = sp:getScale()
    local hpbg = obj.hpbg
    local ap = sp:getAp(2)
    local w, h = sp:getSize()
    if hpbg then
        hpbg:setPosition(0, ap[2] * spScale * scale - h * 0.2 * spScale * scale)
    end

    local shadow = obj.shadow
    if shadow then
        shadow:setScale(shadow.scale * scale)
    end
end

local floor = math.floor
function BattleObjectLayer:setPos(id, x, y)
    if BC.jump then return end
    local obj = self._objs[id]
    local node = obj.node
    -- if obj.y ~= y then
    --     node:setLocalZOrder(-y)
    --     if node.fnode then node.fnode:setLocalZOrder(8888 - y) end
    -- end
    local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    obj.x, obj.y = _x, y
    node:setPositionAndLocalZorder(_x, y, -y)  
end

function BattleObjectLayer:setRolePosX(id, x)
    if BC.jump then return end
    local obj = self._objs[id]
    local node = obj.node
    node.role:setPositionX(x)
end

-- 攻击动作关键帧的时候, 把他稍微移到前层
function BattleObjectLayer:Zfront(id, value)
    if BC.jump then return end
    local obj = self._objs[id]
    local node = obj.node
    node:setLocalZOrder(-(obj.y - value))
end

function BattleObjectLayer:Zback(id)
    if BC.jump then return end
    local obj = self._objs[id]
    local node = obj.node
    node:setLocalZOrder(-obj.y)
end

-- 不设Z
function BattleObjectLayer:setAltitude(id, x, y)
    if BC.jump then return end
    local obj = self._objs[id]
    local node = obj.node
    local role = node.role
    role:setPosition(x, y)
    role.y = y
    if obj.hpbg then obj.hpbg:setPosition(x, y + obj.hpbg.h) end
    obj.altitude = y
end

-- 不设Z
function BattleObjectLayer:setZ(id, z)
    if BC.jump then return end
    local obj = self._objs[id]
    local node = obj.node
    node:setLocalZOrder(z)
    -- node.fnode:setLocalZOrder(8888 + z)
end

-- disappearDie 死的时候定帧直接消失
function BattleObjectLayer:setMotion(id, motion, inv, callback, idleAfterAttack, noloop, disappearDie)
    if BC.jump then return end
    local obj = self._objs[id]
    local node = obj.node 
    local sp = obj.sp
    local lastMotion = sp:getMotion()
    if motion == EMotionDIE then
        node:setScale(1.0)
        -- 死亡动作不循环
        if disappearDie then
            sp:stopAnim()
        else
            sp:changeMotion(motion, battleTick, function ()
                if callback then
                    callback()
                end
            end, true, inv)
        end
        if enable_shadow and obj.shadow then
            if obj.dieShadow or not obj.hasDie then
                obj.shadow:setVisible(false)
            else
                obj.shadow:setVisible(sp.visible)
            end
        end
        obj.die = true
        if obj.dieType == 2 or not sp.visible then
            obj.dieTick = battleTick + BC.DIE_EXIST_TIME
        else
            obj.dieTick = battleTick + 1.3
            node:setLocalZOrder(-obj.y + 2000)
        end
        if disappearDie then
            obj.dieTick = battleTick
        end
        if obj.dieExist then
            obj.dieTick = nil
        end

        if sp.hpbg and sp.hpbg:getOpacity() > 0 then
            sp.hp:stopAllActions()
            sp.hp:setScaleX(0)
        end
    else
        if motion == EMotionATTACK or (motion >= EMotionCAST1 and motion <= EMotionBORN) or motion == 15 then
            -- 攻击动作之后 切回站立
            sp:changeMotion(motion, battleTick, function ()
                if idleAfterAttack then
                    self:setMotion(id, EMotionIDLE)
                end
                if callback then
                    callback()
                end
            end, noloop, inv)
        elseif (motion == EMotionMOVE or motion == EMotionIDLE) and motion == lastMotion then

        else
            sp:changeMotion(motion, battleTick, function ()
                if callback then
                    callback()
                end
            end, noloop, inv)
        end
        if obj.die then
            node:setLocalZOrder(-obj.y)
            local role = node.role
            role:stopAllActions()
            role:setPosition(0, 0)
            role.y = 0
            obj.die = false
            if enable_shadow and obj.shadow then
                obj.shadow:setVisible(true)
                obj.shadow:setOpacity(255)
            end
            sp:setVisible(true)
            sp:setOpacity(255)
        end
    end
end

function BattleObjectLayer:setVisible(id, visible)
    if BC.jump then return end
    local obj = self._objs[id]
    local sp = obj.sp
    sp:setVisible(visible)
    if enable_shadow and obj.shadow then
        obj.shadow:setVisible(visible)
    end
end

function BattleObjectLayer:setShadowVisible(id, visible)
    if BC.jump then return end
    local obj = self._objs[id]
    local sp = obj.sp
    if enable_shadow and obj.shadow then
        obj.shadow:setVisible(visible)
    end
end

function BattleObjectLayer:getSize(id)
    if BC.jump then return 0, 0 end
    local obj = self._objs[id]
    local sp = obj.sp
    return sp:getSize()
end

function BattleObjectLayer:getRealSize(id)
    if BC.jump then return 0, 0 end
    local obj = self._objs[id]
    local sp = obj.sp
    local w, h = sp:getSize()
    return w * obj.scale, h * obj.scale
end

function BattleObjectLayer:rap(id, r, g, b)
    if BC.jump then return end
    local obj = self._objs[id] 
    if self._skillAreaIsShow then return end
    local role = obj.node.role
    role:stopAllActions()
    role:setColor(cc.c3b(r, g, b))
    role:runAction(cc.TintTo:create(0.25, 255, 255, 255))
end

function BattleObjectLayer:setPColor(id, r, g, b, pro, alpha)
    if BC.jump then return end
    local obj = self._objs[id] 
    local sp = obj.sp
    local pro1 = pro * 0.01
    local pro2 = 1 - pro1
    sp:setCM(pro2, pro2, pro2, 1, r * pro1, g * pro1, b * pro1, 0)
    if alpha then
        sp:setOpacity(alpha)
    end
end

function BattleObjectLayer:setSaturation(id, value)
    if BC.jump then return end
    local obj = self._objs[id] 
    obj.node.scaleNode:setSaturation(value)
end

local defaultColor = cc.c3b(255, 255, 255)
function BattleObjectLayer:cancelColor(id)
    if BC.jump then return end
    local obj = self._objs[id] 
    local sp = obj.sp
    sp:setCM(1, 1, 1, 1, 0, 0, 0, 0)
    sp:setOpacity(255)
end

local hplabeltable = {
                        [1] = {0.5, UIUtils.bmfName_red, 1, "-"}, -- 玩家技能
                        [2] = {0.7, UIUtils.bmfName_red, 4, "-"}, -- 玩家技能暴击
                        [3] = {0.4, UIUtils.bmfName_green, 2, "+"}, -- 治疗
                        [4] = {0.6, UIUtils.bmfName_green, 2, "+"}, -- 治疗暴击
                        [5] = {0.4, UIUtils.bmfName_yellow, 5, "-"}, -- 怪兽普攻
                        [6] = {0.4, UIUtils.bmfName_crit, 4, ""}, -- 怪兽普攻暴击
                        [7] = {0.4, UIUtils.bmfName_yellow, 4, "-"}, -- 怪兽技能
                        [8] = {0.4, UIUtils.bmfName_crit, 4, ""}, -- 怪兽技能暴击    
                        [10] = {0.5, UIUtils.bmfName_sp, 3, ""},  -- 闪避       
                        [11] = {0.4, UIUtils.bmfName_sp, 4, ""},  -- 暴击      
                        [12] = {0.5, UIUtils.bmfName_sp, 1, ""},  -- 吸收 
                        [13] = {0.5, UIUtils.bmfName_sp, 1, ""},  -- 免疫      
                    }
local PCTools = pc.PCTools
local seq = cc.Sequence
local dt = cc.DelayTime
local scaleTo = cc.ScaleTo
local fadeOut = cc.FadeOut
local callFunc = cc.CallFunc
function BattleObjectLayer:HPLabelMove(id, kind, camp, hpNumber, hpAnim, hpPro1, hpPro2)
    if BC.jump then return end
    if BC.noEff then return end
    local obj = self._objs[id]
    if hpAnim then
        local hpLabel = self._hudPool[self._hudIndex]
        self._hudIndex = self._hudIndex + 1
        if self._hudIndex > MAX_COUNT_HUD then
            self._hudIndex = 1
        end
        local node = obj.node
        local sp = obj.sp
        local color, scale
        scale = hplabeltable[kind][1]
        -- local tick = battleTick
        -- if tick > obj.tick + frameInv then
        hpLabel:setString(hplabeltable[kind][4]..hpNumber)
        hpLabel:setBMFontFilePath(hplabeltable[kind][2])
        local _x, _y
        local w, h = sp:getSize()
        w = w * 0.25 * obj.scale
        h = h * 0.25 * obj.scale
        local role = node.role
        local ap = sp:getAp(1)
        _x = ap[1] * role:getScaleX() * obj.scale - w + GRandom(w * 2)
        _y = ap[2] * obj.scale + GRandom(h) + obj.altitude
        hpLabel.node:setPosition(obj.x, obj.y)
        hpLabel:setPosition(_x, _y)
        local motion = hplabeltable[kind][3]
        hpLabel:setScale(scale)
        PCTools:diyAction(hpLabel, motion)

            -- obj.tick = tick
        -- end
    end

    if HUD_TYPE == 2 then
        if hpPro1 and hpPro1 ~= hpPro2 then
            -- 技能伤害 显示血条
            local hpbg = obj.hpbg
            local hp = obj.hp
            if hpbg then
                hpbg.hpPro2 = hpPro2
                hpbg.hpPro1 = hpPro1
                if hpPro2 >= SHOW_HP_PRO then
                    if hpbg.visible ~= false then
                        hpbg.visible = false
                        hpbg:setVisible(false)
                    end
                else
                    if hpbg.visible ~= true then
                        hpbg.visible = true
                        hpbg:setVisible(true)
                        hpbg:setOpacity(255)
                    end
                    hp:setScaleX(hpPro1)
                    hp:stopAllActions()
                    local t = abs(hpPro2 - hpPro1) * 0.5
                    hp:runAction(seq:create(dt:create(0.05), scaleTo:create(t, hpPro2, 1)))
                    -- print(id, obj.die, hpPro1, hpPro2)
                    if obj.die or hpPro2 == 0 then
                        local t2 = 0.3
                        hpbg:stopAllActions()
                        hpbg:runAction(seq:create(dt:create(t2 + t), fadeOut:create(0.1), callFunc:create(function ()
                            hpbg:setVisible(false)
                            hpbg.visible = false
                        end)))
                    end
                end
            end
        end
    else
        local hpbg = obj.hpbg
        if hpbg == nil then return end
        hpbg.hpPro2 = hpPro2
    end
end

-- 显示小兵技能名称
local LABEL = cc.Label
local ttfname = UIUtils.ttfName_Title
local showSkillNameBg = {{"castbg_battle.png", "castbg_battle.png", "castbg_battle.png", "castbg_battle.png"}, 
                        {"castbg_battle.png", "castbg_battle.png", "castbg_battle.png", "castbg_battle.png"}}
function BattleObjectLayer:showSkillName(id, one, x, y, camp, name, noAnim)
    if BC.jump then return end
    if name == nil then return end
    if BC.noEff then return end
    if string.len(name) == 0 then return end
    local index = floor(string.len(name) / 3)
    if index == 0 then return end

    local _x, _y = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x, y
    
    if one then
        local obj = self._objs[id]
        local node = obj.node
        local role = node.role
        local sp = obj.sp
        local ap = sp:getAp(1)
        local scale = obj.scale * node.scale
        local x, y = node:getPosition()
        _x, _y = ap[1] * role:getScaleX() * scale + x, ap[2] * scale + y
    end

    local labelnode = cc.Node:create()
    local label = LABEL:createWithTTF(name, ttfname, index >= 4 and 18 or 22)
    local bg = cc.Sprite:createWithSpriteFrameName(showSkillNameBg[camp][index])
    bg:addChild(label)
    label:setPosition(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.5)
    label:setColor(cc.c3b(255, 255, 255))
    label:enable2Color(1, cc.c4b(249, 236, 123, 0))
    label:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    -- label:setScale(.92)
    bg:setCascadeOpacityEnabled(true)
    labelnode:setLocalZOrder(10000)
    labelnode:setRotation3D(_3dVertex1)
    self._rootLayer:addChild(labelnode)
    labelnode:setPosition(_x, _y)
    labelnode:addChild(bg)
    bg:setPosition(0, 30)
    bg:runAction(seq:create(scaleTo:create(0.2, 1.5), scaleTo:create(0.2, 1.0), cc.Spawn:create(cc.MoveTo:create(0.3, {x = 0, y = 80}), cc.FadeOut:create(0.3)),
        cc.CallFunc:create(function () labelnode:removeFromParent() end)))

    if not noAnim then
        self:playEffect_skill1("skill_skillarea", x, y, true, true)
    end
end

-- 显示小兵血条
function BattleObjectLayer:showHP(showCamp1, showCamp2)
    if BC.jump then return end
    if not SHOW_HP_ENABLE then return end
end

local sqrt = math.sqrt
function BattleObjectLayer:rangeAttack(id1, id2, delay, speed, flytype, bulletname, dis, scale)
    if BC.jump then return end
    local node1 = nil
    local node2 = nil
    local sp1 = nil
    local sp2 = nil
    local role1 = nil
    local role2 = nil
    local obj1 = self._objs[id1]
    local obj2 = self._objs[id2]
    node1 = obj1.node
    sp1 = obj1.sp
    role1 = node1.role

    node2 = obj2.node
    sp2 = obj2.sp
    role2 = node2.role
    if scale == nil then
        scale = 100
    end
    local scale1 = obj1.scale
    local scale2 = obj2.scale
    local ap1 = sp1:getAp(3)
    local ap2 = sp2:getAp(1)
    local offsetx = 0
    local offsety = 0
    local destx = (ap2[1] + offsetx) * role2:getScaleX() * scale2
    local desty = (ap2[2] + offsety) * scale2
    self._effectMgr:playBullet(delay, bulletname, flytype, speed,
        1, {ap1[1] * role1:getScaleX() * scale1, ap1[2] * scale1 + obj1.altitude, node1},
        1, {destx, desty + obj2.altitude, node2}, 
        dis, node1.scale * scale * 0.01)
end

function BattleObjectLayer:rangeAttackPt(id1, x, y, delay, speed, flytype, bulletname, dis, scale)
    if BC.jump then return end
    local node1 = nil
    local sp1 = nil
    local role1 = nil
    local obj1 = self._objs[id1]
    node1 = obj1.node
    sp1 = obj1.sp
    role1 = node1.role
    if scale == nil then
        scale = 100
    end
    local scale1 = obj1.scale
    local ap1 = sp1:getAp(3)
    local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    self._effectMgr:playBullet(delay, bulletname, flytype, speed,
        1, {ap1[1] * role1:getScaleX() * scale1, ap1[2] * scale1, node1},
        2, {_x, y, 0, 0}, 
        dis, node1.scale * scale * 0.01)
end

function BattleObjectLayer:rangeAttackPt2(x1, y1, addx1, addy1, x2, y2, addx2, addy2, delay, speed, flytype, bulletname, dis, scale)
    if BC.jump then return end
    if scale == nil then
        scale = 100
    end
    local _x1 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x1 or x1
    local _x2 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x2 or x2
    self._effectMgr:playBullet(delay, bulletname, flytype, speed,
        2, {_x1, y1, addx1, addy1},
        2, {_x2, y2, addx2, addy2}, 
        dis, scale * 0.01)
end

local bulletname = {"bingxibeiji", "huoxibeiji", "shuixibeiji", "dianxibeiji", "tuxibeiji", 
                    "shenshengbeiji", "duxibeiji", "liaoshangbeiji", "guihunbeiji", "leiniaobeiji",
                     "youlingbeiji", "dujiaoshoubeiji", "bingxibeiji", "youhuobeiji"}
function BattleObjectLayer:rangeHit(soldier, idx)
    if BC.jump then return end
    local id = soldier.ID
    local _scale = soldier.team.artzoom
    local obj = self._objs[id] 
    if obj == nil then return end
    local node = obj.node
    local role = node.role
    local sp = obj.sp
    local ap = sp:getAp(1)
    local scale = obj.scale * node.scale
    local x, y = node:getPosition()
    if soldier.team.volume == 6 then
        self._effectMgr:playBoom(bulletname[idx], ap[1] * role:getScaleX() * scale + x - 20 + GRandom(40), ap[2] * scale + y + obj.altitude - 20 + GRandom(40), (0.5 + (_scale - 1) * 0.125) * node.scale)
    else
        self._effectMgr:playBoom(bulletname[idx], ap[1] * role:getScaleX() * scale + x, ap[2] * scale + y + obj.altitude, (0.5 + (_scale - 1) * 0.125) * node.scale)
    end
end

function BattleObjectLayer:runEffect(id, _scale)
    if BC.jump then return nil end
    local obj = self._objs[id] 
    local node = obj.node
    local role = node.role
    local sp = obj.sp
    local scale = obj.scale
    local x, y = node:getPosition()
    return self._effectMgr:playRunArt(node, 0, 0, _scale * 0.5 * node.scale)
end

function BattleObjectLayer:runEffectStop(eff)
    if eff then
        self._effectMgr:stopRunArt(eff)
    end
end

-- 动作暂停
function BattleObjectLayer:pause(id)
    if BC.jump then return end
    if self._objs[id] == nil then return end
    local sp = self._objs[id].sp
    sp:freeze()
end

-- 动作恢复
function BattleObjectLayer:resume(id)
    if BC.jump then return end
    if self._objs[id] == nil then return end
    local sp = self._objs[id].sp
    sp:unfreeze()
end

-- 尸体消失
function BattleObjectLayer:bodyDisappear(ID)
    if BC.jump then return end
    local obj = self._objs[ID]
    obj.sp:setVisible(false)
end

-- 通用buff图标动画
function BattleObjectLayer:playCommonBuff(name, camp, x, y)
    if BC.jump then return end
    local sp = cc.Sprite:create("asset/uiother/battle/b_" .. name .. ".png")
    local node = cc.Node:create()
    local buffData = {sp = sp, node = node, frame = 1, beginTick = BC.BATTLE_DISPLAY_TICK}
    node:setRotation3D(_3dVertex1)
    local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    node:setPosition(_x, y)
    node:setLocalZOrder(1005)
    self._rootLayer:addChild(node)
    sp:setPositionY(100)
    if camp == 2 then
        sp:setHue(160)
        sp:setSaturation(33)
        sp:setBrightness(10)
    end
    node:addChild(sp)
    self._commonBuffPool[buffData] = buffData
end

local COMMONBUFF_ACTION = 
{   
    {-60, 25},
    {-30, 50},
    {-20, 100},
    {-10, 180},
    {-5, 210},
    {0, 255},
    {-1},
    {-2},
    {-3},
    {-4},
    {-5},
    {-6},
    {-6.6},
    {-6.88},
    {-7.16},
    {-7.44},
    {-7.72},
    {-8},
    {-7.95},
    {-7.75},
    {-7.35},
    {-6.95, 210},
    {-6.275, 180},
    {-5.6, 150},
    {-4.48, 120},
    {-3.36, 90},
    {-2.24, 60},
    {-1.12, 30},
    {0, 0},
}
local COMMONBUFF_MAX_FRAME = #COMMONBUFF_ACTION
local floor = math.floor
function BattleObjectLayer:updateCommonBuff(buffData, battleTick)
    local frame = floor((battleTick - buffData.beginTick) * 30) + 1
    if frame > COMMONBUFF_MAX_FRAME then
        buffData.node:removeFromParent()
        self._commonBuffPool[buffData] = nil
        return
    end
    local fa = COMMONBUFF_ACTION[frame]
    buffData.sp:setPositionY(100 + fa[1])
    if fa[2] then
        buffData.sp:setOpacity(fa[2])
    end
    buffData.frame = frame
end

-- 通用buff属性增减动画
local format = string.format
function BattleObjectLayer:playCommonAttr(filename, camp, x, y)
    if BC.jump then return end
    local name = format("%03d", filename)
    local sp = cc.Sprite:createWithSpriteFrameName("ba_" .. name .. ".png")
    local node = cc.Node:create()
    local buffData = {sp = sp, node = node, frame = 1, beginTick = BC.BATTLE_DISPLAY_TICK}
    node:setRotation3D(_3dVertex1)
    local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    node:setPosition(_x, y)
    node:setLocalZOrder(9999)
    self._rootLayer:addChild(node)
    sp:setPositionY(100)
    if camp == 2 then
        sp:setHue(160)
        sp:setSaturation(33)
        sp:setBrightness(10)
    end
    sp:setOpacity(0)
    node:addChild(sp)
    self._commonAttrPool[buffData] = buffData
end

local COMMONATTR_ACTION = 
{   
    {0, 0, 0.5},
    {11.1, 140, 0.5},
    {17.8, 227, 0.83},
    {20, 255, 1.03},
    {22.5, nil, 1.1},
    {25, nil, 1.09},
    {27.5, nil, 1.08},
    {30, nil, 1.07},
    {32.5, nil, 1.055},
    {35, nil, 1.044},
    {37.5, nil, 1.033},
    {40, nil, 1.022},
    {42.5, nil, 1.011},
    {43.95, 234, 1.0},
    {45.4, 211, nil},
    {46.85, 191, nil},
    {48.35, 170, nil},
    {49.8, 147, nil},
    {51.25, 127, nil},
    {52.7, 107, nil},
    {54.15, 84, nil},
    {55.6, 63, nil},
    {57.1, 43, nil},
    {58.55, 20, nil},
    {60, 0, nil},

}
local COMMONATTR_MAX_FRAME = #COMMONATTR_ACTION
local floor = math.floor
function BattleObjectLayer:updateCommonAttr(buffData, battleTick)
    local frame = floor((battleTick - buffData.beginTick) * 50) + 1
    if frame > COMMONATTR_MAX_FRAME then
        buffData.node:removeFromParent()
        self._commonAttrPool[buffData] = nil
        return
    end
    local fa = COMMONATTR_ACTION[frame]
    buffData.sp:setPositionY(fa[1])
    if fa[2] then
        buffData.sp:setOpacity(fa[2])
    end
    if fa[3] then
        buffData.sp:setScale(fa[3] * 0.8)
    end
    buffData.frame = frame
end

-- 击飞动画
local HIT_FLY_ACTION = 
{
    0,
    0,
    0,
    0,
    30,
    43.25,
    46.15,
    48.45,
    50.05,
    51.05,
    51.35,
    51.1,
    50.3,
    48.95,
    47.1,
    44.7,
    40.1,
    26.3,
    0,
    8.3,
    11.1,
    8.3,
    0,
}
function BattleObjectLayer:hitFly(id, scale)
    if BC.jump then return end
    local obj = self._objs[id] 
    if obj.hitFly ~= -1 then return end
    if scale then
        obj.hitFlyScale = scale
    else
        obj.hitFlyScale = 1
    end
    obj.hitFly = BC.BATTLE_DISPLAY_TICK - GRandom(3) * 0.025
    self._hitFlyPools[obj] = obj
end

function BattleObjectLayer:updateHitFly(obj, battleTick)
    local tick = obj.hitFly
    local role = obj.node.role
    local frame = floor((battleTick - tick) * (50 / obj.hitFlyScale)) + 1
    if frame > #HIT_FLY_ACTION then
        obj.hitFly = -1
        role:setPositionY(0)
        role.y = 0
        obj.altitude = 0
        self._hitFlyPools[obj] = nil
        return
    end
    local y = HIT_FLY_ACTION[frame] * obj.hitFlyScale
    role:setPositionY(y)
    role.y = y
    obj.altitude = y
end
local WIND_FLY_ACTION = 
{
    0,
    2,
    3.5,
    4.4,
    5.2,
    5.8,
    6.2,
    6.5,
    6.2,
    5.8,
    5.2,
    4.4,
    3.5,
    2,
    0,
    -2,
    -3.5,
    -4.4,
    -5.2,
    -5.8,
    -6.2,
    -6.5,
    -6.2,
    -5.8,
    -5.2,
    -4.4,
    -3.5,
    -2,
}
-- 吹飞
function BattleObjectLayer:windFly(id, height)
    if BC.jump then return end
    local obj = self._objs[id] 
    if obj.windFly ~= -1 then return end
    obj.windFly = BC.BATTLE_DISPLAY_TICK - GRandom(3) * 0.025
    obj.windHeight = height
    self._windFlyPools[obj] = obj
end

function BattleObjectLayer:updateWindFly(obj, battleTick)
    local tick = obj.windFly
    local role = obj.node.role
    local frame = math.fmod(floor((battleTick - tick) * 25) + 1, #WIND_FLY_ACTION)
    if frame == 0 then frame = 1 end
    local h = obj.windHeight + WIND_FLY_ACTION[frame]
    local y = role.y
    y = y + (h - y) * 0.3
    role:setPositionY(y)
    role.y = y
    obj.altitude = y
end

-- 需要手动取消
function BattleObjectLayer:cancelWindFly(id)
    if BC.jump then return end
    local obj = self._objs[id]
    obj.windFly = -1
    self._windFlyPools[obj] = nil
    self:hitFly(id, obj.windHeight * 0.02)
    obj.hitFly = obj.hitFly - 0.25
end

-- 方阵死亡图标
function BattleObjectLayer:updateTeamDieIcon(teamID, isDie, x, y, headPic)
    if BC.jump then return end
    if isDie then
        if self._teamDieIcon[teamID] == nil then
            local sp = cc.Sprite:createWithSpriteFrameName("die_battle.png")
            local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
            sp:setPosition(_x, y, -y)
            sp:setRotation3D(_3dVertex1)
            self._teamDieIcon[teamID] = sp
            self._rootLayer:addChild(sp)
            local headBg = cc.Sprite:createWithSpriteFrameName("head_die_battle.png")
            sp:addChild(headBg)
            headBg:setVisible(false)
            headBg:setPosition(50, 230)
            headBg:setScale(0.8)
            sp.headBg = headBg
            local head = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. headPic..".jpg")
            head:setPosition(25, 30)
            head:setScale(0.5)
            headBg:addChild(head, -1)
            sp:setVisible(false)
        end
    else
        if self._teamDieIcon[teamID] then
            self._teamDieIcon[teamID]:removeFromParent()
            self._teamDieIcon[teamID] = nil
        end
    end
end

function BattleObjectLayer:showTeamDieHead()
    if BC.jump then return end
    for _, sp in pairs(self._teamDieIcon) do
        sp:setVisible(true)
        sp.headBg:setVisible(true)
        sp.headBg:stopAllActions()
        sp.headBg:setPosition(50, 230)
        sp.headBg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.6, {x = 50, y = 225}), cc.MoveTo:create(0.6, {x = 50, y = 230}))))
    end
end

function BattleObjectLayer:hideTeamDieHead()
    if BC.jump then return end
    for _, sp in pairs(self._teamDieIcon) do
        sp.headBg:setVisible(false)
        sp.headBg:stopAllActions()   
        sp:setVisible(false)
    end
end

function BattleObjectLayer:battleEnd()

end

-- 切换hud类型
function BattleObjectLayer:onHUDTypeChange()
    HUD_TYPE = BattleUtils.HUD_TYPE
    if HUD_TYPE == 1 then
        -- 兵团血条
        self._teamHUDNode:setVisible(true)
        local sp, hpbg, hp
        for index, obj in pairs(self._objs) do
            sp = obj.sp
            hpbg = sp.hpbg
            if hpbg then
                hpbg:setVisible(false)
                hpbg.visible = false
                hpbg:stopAllActions()
                sp.hp:stopAllActions()
            end
        end
    else
        -- 单兵血条
        self._teamHUDNode:setVisible(false)
        local sp, hpbg, hp, hpPro2
        for index, obj in pairs(self._objs) do
            sp = obj.sp
            hpbg = sp.hpbg
            if hpbg and hpbg.hpPro1 then
                hpPro2 = hpbg.hpPro2
                if not obj.die then
                    if hpPro2 then
                        if hpPro2 < SHOW_HP_PRO then
                            hpbg:setVisible(true)
                            hpbg.visible = true
                            hpbg:setOpacity(255)
                        end
                    else
                        hpbg:setVisible(true)
                        hpbg.visible = true
                        hpbg:setOpacity(255)
                    end
                end
                hpbg:stopAllActions()
                sp.hp:stopAllActions()
                if hpPro2 then
                    sp.hp:setScaleX(hpPro2)
                end
            end
        end
    end
end

-- 显示方阵总血条
function BattleObjectLayer:addTeamHUD(team, show, _type)
    if BC.jump then return end
    local sp = cc.Sprite:createWithSpriteFrameName("team_hud_bg.png")
    local visible = true
    if not show then
        sp:setVisible(false)
        visible = false
    end
    self._teamHUDNode:addChild(sp)

    local shieldRGB = team.shield
    local hasTimeBar = (team.lifeOverTime ~= nil) or (shieldRGB ~= nil)
    local camp = team.camp
    local hudCamp = BC_reverse and 3 - camp or camp
    local str, bgName
    if _type == 1 then
        if hasTimeBar then
            str = "team_hud_"..hudCamp.."_time.png"
            bgName = "team_hud_bg_time.png"
        else
            str = "team_hud_"..hudCamp..".png"
            bgName = "team_hud_bg.png"
        end
    else
        str = "team_hud2_"..hudCamp..".png"
        bgName = "team_hud_bg.png"
    end
    local _hp = cc.Sprite:createWithSpriteFrameName(str)
    if _type == 1 then
        _hp:setPosition(0, 0)
    else
        _hp:setPosition(-5, -2)
    end
    _hp:setAnchorPoint(0, 0)
    sp:addChild(_hp)
    sp:setScaleX(-1)

    local hp = cc.Sprite:createWithSpriteFrameName(bgName)
    if hasTimeBar then
        hp:setPosition(0, 3)
    else
        hp:setPosition(0, 0)
    end
    hp:setAnchorPoint(0, 0)
    sp:addChild(hp)
    hp:setScaleX(0)

    local timeBar
    if hasTimeBar then
        timeBar = cc.Sprite:createWithSpriteFrameName("team_hud_time.png")
        timeBar:setAnchorPoint(1, 0)
        timeBar:setPosition(89, 1)
        sp:addChild(timeBar)
        if shieldRGB then
            timeBar:setColor(cc.c3b(shieldRGB[1], shieldRGB[2], shieldRGB[3]))
        end
    end

    local _y, _h
    local __h
    if camp == 1 then
        __h = 0
    else
        __h = 0
    end
    local scale = team.picScale * GLOBAL_SP_SCALE
    local res = team.resID
    if AnimAP["mcList"][res] then
        _h = AnimAP["mcList"][res][0][2] + __h
    elseif AnimAP[res] then
        _h = AnimAP[res]["H"] + __h
    else
        _h = 200 + __h
    end
    _y = team.y + _h
    local node = cc.Node:create()
    node:setRotation3D(_3dVertex1)
    self._rootLayer:addChild(node)
    self._teamHUD[team] = 
    {
        x = team.x,
        y = _y,
        h = _h,
        sp = sp,
        hp = hp,
        timeBar = timeBar,
        shield = shieldRGB ~= nil,
        hpPro = 0,
        shieldPro = 0.01,
        scale = scale,
        visible = visible,
        node = node,
        anim = false, -- 消失动画
    }
    sp:setLocalZOrder(-_y)
end

function BattleObjectLayer:delAllTeamHUD()
    self._teamHUD = {}
end

function BattleObjectLayer:delTeamHUD(team)
    if not self._teamHUD[team] then return end
    self._teamHUD[team].sp:removeFromParent()
    self._teamHUD[team].node:removeFromParent()
    self._teamHUD[team] = nil
end

function BattleObjectLayer:showAllTeamHUD(battleTime)
    for team, data in pairs(self._teamHUD) do
        data.sp:setVisible(true)
        data.visible = true
        data.anim = false
    end
    self:updateTeamHUD(battleTime)
end

function BattleObjectLayer:hideAllTeamHUD()
    for team, data in pairs(self._teamHUD) do
        data.sp:setVisible(false)
        data.visible = false
        data.anim = false
    end
end

function BattleObjectLayer:showTeamHUD(team)
    local data = self._teamHUD[team]
    if not data then return end
    data.sp:stopAllActions()
    data.sp:setScale(-1, 1)
    data.sp:setVisible(true)
    data.visible = true
    data.anim = false
    data.hpPro = 0
    data.shieldPro = 0.01
end

function BattleObjectLayer:hideTeamHUD(team)
    local data = self._teamHUD[team]
    if not data then return end
    data.visible = false
    data.anim = true
    data.hp:setScaleX(1)
    data.sp:stopAllActions()
    data.sp:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.15, -1, 0),
                            cc.CallFunc:create(function () data.sp:setVisible(false) data.anim = false end)
                        ))
end

function BattleObjectLayer:updateTeamHUD(battleTime)
    local x, y, dx, dy, _x, _y, _index
    local sceneLayer = self._sceneLayer
    local H_CELL = 8
    local yPools1 = {}
    local yPools2 = {}
    local yPools3 = {}
    local yPools4 = {} -- 用于判断当前行，上下两行是否存在
    local lineIndex
    local _h
    local node
    local first = true
    local d = 0
    for team, data in pairs(self._teamHUD) do
        if not data.anim and data.visible then
            x, y = BC_reverse and MAX_SCENE_WIDTH_PIXEL - team.x or team.x, team.y
            _x = data.x
            _y = data.y
            if abs(_x - x) > 50 or abs(_y - y) > 50 then
                _x = x
                _y = y
            else
                _x = _x + (x - _x) * 0.2
                _y = _y + (y - _y) * 0.2
            end
            data.x = _x
            data.y = _y

            node = data.node
            node:setPosition(_x, _y)
            _h = data.h * data.scale
            local dx, dy = node:nodeConvertToScreenSpace(0, _h)
            lineIndex = floor(dy / H_CELL)
            if yPools1[lineIndex] then
                if yPools2[lineIndex] == nil and dx - yPools1[lineIndex][2] > 100 then
                    yPools2[lineIndex] = {data, dx, dy, lineIndex}
                    yPools4[lineIndex + 1] = true
                    yPools4[lineIndex - 1] = true
                elseif yPools3[lineIndex] == nil and dx - yPools1[lineIndex][2] < -100 then
                    yPools3[lineIndex] = {data, dx, dy, lineIndex}
                    yPools4[lineIndex + 1] = true
                    yPools4[lineIndex - 1] = true

                else
                    local add = 1
                    while true do
                        _index = lineIndex - add
                        if yPools1[_index] == nil then 
                            yPools1[_index] = {data, dx, dy, _index}
                            yPools4[_index + 1] = true
                            yPools4[_index - 1] = true
                            break 
                        elseif yPools2[_index] == nil and dx - yPools1[_index][2] > 100 then
                            yPools2[_index] = {data, dx, dy, _index}
                            yPools4[_index + 1] = true
                            yPools4[_index - 1] = true
                            break
                        elseif yPools3[_index] == nil and dx - yPools1[_index][2] < -100 then
                            yPools3[_index] = {data, dx, dy, _index}
                            yPools4[_index + 1] = true
                            yPools4[_index - 1] = true
                            break
                        end
                        _index = lineIndex + add
                        if yPools1[_index] == nil then 
                            yPools1[_index] = {data, dx, dy, _index}
                            yPools4[_index + 1] = true
                            yPools4[_index - 1] = true
                            break 
                        elseif yPools2[_index] == nil and dx - yPools1[_index][2] > 100 then
                            yPools2[_index] = {data, dx, dy, _index}
                            yPools4[_index + 1] = true
                            yPools4[_index - 1] = true
                            break
                        elseif yPools3[_index] == nil and dx - yPools1[_index][2] < -100 then
                            yPools3[_index] = {data, dx, dy, _index}
                            yPools4[_index + 1] = true
                            yPools4[_index - 1] = true
                            break
                        end
                        add = add + 1
                    end  
                end
            else
                yPools1[lineIndex] = {data, dx, dy, lineIndex}
                yPools4[lineIndex + 1] = true
                yPools4[lineIndex - 1] = true
            end
        end

        if data.visible then
            local hp = team.curHP / team.maxHP
            if data.hpPro ~= hp then
                local _hp = data.hpPro
                _hp = _hp + (hp - _hp) * 0.2
                if abs(_hp - hp) < 0.02 then
                    _hp = hp
                end
                local scale = 1 - _hp
                scale = 0.01098 + 0.97802 * scale
                data.hp:setScaleX(scale)
                data.hpPro = _hp
            end
            if data.timeBar then
                if team.lifeOverTime then
                    local pro = (team.lifeOverTime - battleTime) / team.lifeTime
                    if pro < 0 then pro = 0 end
                    data.timeBar:setScaleX(pro)
                elseif team.shield then
                    -- 特殊能量条
                    local pro = team.shieldCur / team.shieldMax
                    if data.shieldPro ~= pro then
                        local _pro = data.shieldPro
                        _pro = _pro + (pro - _pro) * 0.2
                        if abs(_pro - pro) < 0.02 then
                            _pro = pro
                        end
                        if _pro < 0 then _pro = 0 end
                        data.timeBar:setScaleX(_pro)
                        data.shieldPro = _pro
                    end
                end
            end
        end
    end
    for index, data in pairs(yPools1) do
        local data, dx, dy, lineIndex = data[1], data[2], data[3], data[4]
        if yPools4[index] then
            dy = lineIndex * H_CELL
            local spy = data.spy
            if spy then
                spy = spy + (dy - spy) * 0.65
            else
                spy = dy
            end
            data.spy = spy
            data.sp:setPosition(dx, spy)
        else
            data.spy = dy
            data.sp:setPosition(dx, dy)
        end
    end
    for index, data in pairs(yPools2) do
        local data, dx, dy, lineIndex = data[1], data[2], data[3], data[4]
        if yPools4[index] then
            dy = lineIndex * H_CELL
            local spy = data.spy
            if spy then
                spy = spy + (dy - spy) * 0.65
            else
                spy = dy
            end
            data.spy = spy
            data.sp:setPosition(dx, spy)
        else
            data.spy = dy
            data.sp:setPosition(dx, dy)
        end
    end
    for index, data in pairs(yPools3) do
        local data, dx, dy, lineIndex = data[1], data[2], data[3], data[4]
        if yPools4[index] then
            dy = lineIndex * H_CELL
            local spy = data.spy
            if spy then
                spy = spy + (dy - spy) * 0.65
            else
                spy = dy
            end
            data.spy = spy
            data.sp:setPosition(dx, spy)
        else
            data.spy = dy
            data.sp:setPosition(dx, dy)
        end
    end
end

-- 将mc 添加到mcpool中 统一管理
function BattleObjectLayer:addToMCUpdatePool(mc, loop, endRemove, endCallback)
    mc:stop(false)
    local data = 
    {
        bt = BC.BATTLE_DISPLAY_TICK,
        loop = loop,
        endRemove = endRemove,
        endCallback = endCallback,
        loopCount = 0,
        anim = true,
    }
    self._mcUpdatePool[mc] = data
end

function BattleObjectLayer:delMCfromUpdatePoolByTeamId(teamid)
    for mc, _ in pairs(self._mcUpdatePool) do
        if mc.teamid == teamid then
            mc:stop(false)
            mc:setCascadeOpacityEnabled(true)
            mc:stopAllActions()
            mc:setSaturation(-100)
            mc:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeOut:create(1), cc.MoveBy:create(1, {x = 0, y = 80})), cc.RemoveSelf:create(true)))
            self._mcUpdatePool[mc] = nil
        end
    end
end

function BattleObjectLayer:delMCfromUpdatePoolBySoldierId(soldierid)
    for mc, _ in pairs(self._mcUpdatePool) do
        if mc.soldierid == soldierid then
            mc:stop(false)
            mc:setCascadeOpacityEnabled(true)
            mc:stopAllActions()
            mc:setSaturation(-100)
            mc:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeOut:create(1), cc.MoveBy:create(1, {x = 0, y = 80})), cc.RemoveSelf:create(true)))
            self._mcUpdatePool[mc] = nil
        end
    end
end

function BattleObjectLayer:updateMC(tick)
    local loopCount
    for mc, data in pairs(self._mcUpdatePool) do
        if data.anim then
            loopCount = mc:updateAndStop(data.bt, tick, 0.05, true)
            if loopCount > data.loopCount then
                data.loopCount = loopCount
                if data.endCallback then
                    data.endCallback()
                end
                if not data.loop then
                    data.anim = false
                    mc:gotoAndStop(mc:getTotalFrames())
                end
                if data.endRemove then
                    mc:removeFromParent()
                    self._mcUpdatePool[mc] = nil
                end
            end
        end
    end
end

local floor = math.floor
local ETeamStateDIE = ETeamState.DIE
local self_updateScale = BattleObjectLayer._updateScale
local self_updateHitFly = BattleObjectLayer.updateHitFly
local self_updateWindFly = BattleObjectLayer.updateWindFly
local self_updateCommonBuff = BattleObjectLayer.updateCommonBuff
local self_updateCommonAttr = BattleObjectLayer.updateCommonAttr
local self_updateMC = BattleObjectLayer.updateMC
function BattleObjectLayer:update(battleTime)
    if BC.jump then return end
    local objCount = #self._objs
    local sp, hpLabel, node
    battleTick = BC.BATTLE_DISPLAY_TICK
    local index = self._updateIndex

    local count = objCount
    for i = 1, count do
        local obj = self._objs[index]
        index = index + 1
        if index > objCount then
            index = 1
        end
        sp = obj.sp 
        node = obj.node
        -- 缩放
        self_updateScale(self, obj)
        -- 人物序列帧
        sp:update(battleTick, 1)
        -- 序列帧影子
        if obj.shadowType == 2 then
            local shadow = obj.shadow
            if battleTick > shadow.nextUpdate then
                shadow.nextUpdate = shadow.nextUpdate + 0.15
                shadow.curFrame = shadow.curFrame.next
                shadow:setSpriteFrame(shadow.curFrame)
            end
        end

        if obj.die then
            if obj.dieTick then
                if sp.visible then
                    if battleTick > obj.dieTick + 0.5 then
                        sp:setVisible(false)
                        if enable_shadow and obj.shadow then
                            obj.shadow:setVisible(false)
                        end
                    elseif battleTick > obj.dieTick then
                        local o = battleTick - obj.dieTick
                        o = 255 - floor(o * 2 * 255)
                        sp:setOpacity(o)
                        if enable_shadow and obj.shadow then
                            obj.shadow:setOpacity(o)
                        end
                    end
                end
            end
        end
    end

    -- 击飞
    for obj, _ in pairs(self._hitFlyPools) do
        self_updateHitFly(self, obj, battleTick)
    end
    -- 吹飞
    for obj, _ in pairs(self._windFlyPools) do
        self_updateWindFly(self, obj, battleTick)
    end

    self._updateIndex = index
    -- 特效
    self._effectMgr:update()

    for k, v in pairs(self._commonBuffPool) do
        self_updateCommonBuff(self, v, battleTick)
    end
    for k, v in pairs(self._commonAttrPool) do
        self_updateCommonAttr(self, v, battleTick)
    end

    self:updateTeamHUD(battleTime)

    if ENABLE_REAL_SHADOW then
        if not self._isBeforeClear then
            self._shadowTexture:beginWithClear(0, 0, 0, 0)
            self._shadowLayer:visit()
            self._shadowTexture:endToLua()
        end
    end

    -- 技能mc
    if self._mcUpdate then
        self_updateMC(self, battleTick)
    end

    -- 脚下光环
    self:updateTeamHalo()

    -- 血条
    if BattleUtils.XBW_SKILL_DEBUG then
        if self._selectTeam then
            if self._selectTeam.state == ETeamStateDIE then
                self._selectTeam = nil
                if self._selectTeamBg then
                    self._selectTeamBg:setVisible(false)
                end
            else
                if self._selectTeamBg then
                    local x, y = self._selectTeamBg.x, self._selectTeamBg.y
                    local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
                    self._selectTeamBg.x = _x + (self._selectTeam.x - _x) * 0.2
                    self._selectTeamBg.y = y + (self._selectTeam.y - y) * 0.2
                    self._selectTeamBg:setPosition(self._selectTeamBg.x, self._selectTeamBg.y)
                end
                self:setSelectTeamHP()
            end
        end
    end
end

function BattleObjectLayer:onSpeedChange(speed)
    if speed == 0 then
        -- self._mcPool 不需要卡动作帧的mc集合
        for _, v in pairs(self._mcPool) do
            if v:isPlaying() then
                v:stop()
                v.__pause = true
            end
        end
        -- 每帧会根据self._mcUpdate在BattleObjectLayer:update中调用
        self._mcUpdate = false
    else
        for _, v in pairs(self._mcPool) do
            v:setPlaySpeed(speed)
            if v.__pause then
                v:play()
                v.__pause = nil
            end
        end
        self._mcUpdate = true
    end
    
    if speed == 0 then
        for i = 1, #self._objs do
            local obj = self._objs[i]
            if obj.sp then obj.sp:pause() end
        end
    else
        for i = 1, #self._objs do
            local obj = self._objs[i]
            if obj.sp then obj.sp:resume() end
        end
    end
end

local atan = math.atan
local deg = math.deg
local sqrt = math.sqrt
local mcScale = 0.5
-- 技能特效, 场景上一次性
function BattleObjectLayer:playEffect_skill1(name, x, y, isfront, isstand, direct, scale, callback, stkpoint, soldier)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    if mc == nil then
        print(name, "没图")
        return
    end
    self._rootLayer:addChild(mc)
    local __x, __y = 0, 0
    if stkpoint then
        local sp = self._objs[soldier.ID].sp
        local spScale = sp:getScale()
        if stkpoint == 1 then
            -- 头
            local ap = sp:getAp(2)
            __x, __y = ap[1] * spScale, ap[2] * spScale + 5
        elseif stkpoint == 2 then
            -- 身
            local ap = sp:getAp(1)
             __x, __y = ap[1] * spScale, ap[2] * spScale
        elseif stkpoint == 3 then
            -- 脚
        else   
            local ap = sp:getAp(3)
            __x, __y = ap[1] * spScale, ap[2] * spScale     
        end    
    end
    if direct then
        if BC_reverse then
            direct = -direct
        end
        __x = __x * direct
    end
    local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    local s = mcScale
    if scale then
        s = s * scale
    end
    
    if direct then
        mc:setScale(direct * s, s)
    else
        mc:setScale(s)
    end
    local z
    if isfront then
        if isfront == 1 then
            z = 1100
        else
            z = 1000
        end
    else
        z = -1000
    end
    mc:setPositionAndLocalZorder(_x + __x, y + __y, z)
    if isstand then
        mc:setRotation3D(_3dVertex1)
    end
    self:addToMCUpdatePool(mc, false, true, callback)
    return mc
end
-- 角度
function BattleObjectLayer:playEffect_skill2(name, x1, y1, x2, y2, isfront, direct)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    self._rootLayer:addChild(mc)
    local _x1 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x1 or x1
    local _x2 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x2 or x2
    
    local dx = x2 - _x1
    local dy = y2 - y1
    local angle = deg(-atan(dy / dx)) + 90
    if x2 - x1 <= 0 then
        angle = angle + 180
    end
    local z
    if isfront then
        if isfront == 1 then
            z = 1100
        else
            z = 1000
        end
    else
        z = -1000
    end
    mc:setPositionAndLocalZorder(_x1, y1, z)
    mc:setRotation(angle)
    if direct then
        mc:setScale(direct, 1)
    end
    self:addToMCUpdatePool(mc, false, true)
end

-- 全屏光影 屏幕
function BattleObjectLayer:playEffect_skill3(name, zOrder, filpX)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    mc:setPositionAndLocalZorder(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5, -20 + zOrder)
    if filpX then
        mc:setScale(-1, 1)
        if ADOPT_IPHONEX then
            mc:setScaleX(-1.35)
        end 
    else
        mc:setScale(1, 1)
        if ADOPT_IPHONEX then
            mc:setScaleX(1.35)
        end 
    end
    self._totemLayer:addChild(mc)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    self:addToMCUpdatePool(mc, false, true)
end

-- 全屏特效脚下
function BattleObjectLayer:playEffect_skill4(name, zOrder, x, y, filpX)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    mc:setPositionAndLocalZorder(x, y, -1000 + zOrder)
    if filpX then
        mc:setScale(-1, 1)
        if ADOPT_IPHONEX then
            mc:setScaleX(-1.35)
        end
    else
        mc:setScale(1, 1)
        if ADOPT_IPHONEX then
            mc:setScaleX(1.35)
        end 
    end
    self._rootLayer:addChild(mc)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    self:addToMCUpdatePool(mc, false, true)
end

-- 飞行光影
function BattleObjectLayer:playEffect_fly(name, pt1x, pt1y, point, flytype, speed, isfront, isstand)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    self._rootLayer:addChild(mc)
    pt1x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - pt1x or pt1x
    
    mc:setScale(mcScale)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    if isfront then
        mc:setPositionAndLocalZorder(pt1x, pt1y, 1000)
    else
        mc:setPositionAndLocalZorder(pt1x, pt1y, -1000)
    end
    if isstand then
        mc:setRotation3D(_3dVertex1)
    end
    self._mcPool[mc] = mc
    local pt2x, pt2y = point.x, point.y
    pt2x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - pt2x or pt2x
    local dx = pt2x - pt1x
    local dy = pt2y - pt1y
    local dis = sqrt(dx * dx + dy * dy)
    local s = dis / speed
    local beginTick = battleTick
    local endTick = beginTick + s
    if flytype == 1 then
        -- 直线
        mc:setUpdateFrameHook(function ()
            local tick = battleTick
            local rate = (tick - beginTick) / (endTick - beginTick)
            if tick > endTick then
                self._mcPool[mc] = nil
                mc:setUpdateFrameHook(function ()

                end)
                ScheduleMgr:delayCall(1, self, function ()
                    mc:removeFromParent()
                end)
            else
                mc:setPosition(pt1x + dx * rate, pt1y + dy * rate)
            end
        end)
    else
        -- 抛物线
        local height
        if dis < 100 then
            height = dis * 0.2
        else
            height = dis * 0.35
        end
        if pt2y > pt1y then
            height = pt2y - pt1y + height
        end
        mc:setUpdateFrameHook(function ()
            local tick = battleTick
            local rate = (tick - beginTick) / (endTick - beginTick)
            if tick > endTick then
                self._mcPool[mc] = nil
                mc:setUpdateFrameHook(function ()

                end)
                ScheduleMgr:delayCall(1, self, function ()
                    mc:removeFromParent()
                end)
            else
                local x1 = pt1x 
                local y1 = pt1y
                local x3 = point.x
                local y3 = point.y
                local width = x3 - x1
                local x2 = x1 + width / 2
                local y2 = y1 + height
                local x1x1 = x1*x1
                local x1_x2 = x1x1-x2*x2
                local x1_x3 = x1x1-x3*x3
                local b = ((y1-y3)*x1_x2-(y1-y2)*x1_x3)/((x1-x3)*x1_x2-(x1-x2)*x1_x3)
                local a = ((y1-y2)-b*(x1-x2))/x1_x2
                local c = y1-a*x1x1-b*x1
                local _x = pt1x + (point.x - pt1x) * rate
                local _y = a*_x*_x + b*_x + c
                mc:setPosition(_x, _y)
            end
        end)
    end
    return s
end
-- 怪兽受击光影, 一人, 跟随人
-- pos 头身脚
function BattleObjectLayer:playEffect_hit1(name, isfront, isstand, soldier, pos, scale)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    local role = self._objs[soldier.ID].node.role
    local sp = self._objs[soldier.ID].sp
    role:addChild(mc)

    local z
    if isfront then
        if isfront == 1 then
            z = 1100
        else
            z = 1000
        end
    else
        z = -1000
    end

    local _x, _y
    local spScale = sp:getScale()
    if pos == 1 then
        -- 头
        local ap = sp:getAp(2)
        _x = ap[1] * spScale
        _y = ap[2] * spScale
        mc:setPositionAndLocalZorder(_x, _y, z)
    elseif pos == 2 then
        -- 身
        if soldier.team.volume == 6 then
            local ap = sp:getAp(1)
            _x = ap[1] * spScale - 20 + GRandom(40)
            _y = ap[2] * spScale - 20 + GRandom(40)
        else
            local ap = sp:getAp(1)
            _x = ap[1] * spScale
            _y = ap[2] * spScale
        end
        mc:setPositionAndLocalZorder(_x, _y, z)
    else
        -- 脚
        -- _x = 0
        -- _y = 0
        mc:setLocalZOrder(z)
    end
    
    if scale == nil then
        scale = 1
    end
    local _scale = soldier.team.artzoom * mcScale * scale
    mc:setScale(-_scale, _scale)
    if not isstand then
        mc:setRotation3D(_3dVertex2)
    end
    self:addToMCUpdatePool(mc, false, true)
end
-- 怪兽受击光影, 2人, 跟随
function BattleObjectLayer:playEffect_hit2(name, isfront, soldier1, soldier2)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    local obj1 = self._objs[soldier1.ID]
    local obj2 = self._objs[soldier2.ID]
    local node1 = obj1.node
    local node2 = obj2.node
    local sp1 = obj1.sp
    local sp2 = obj2.sp
    local ap1 = sp1:getAp(3)
    local ap2 = sp2:getAp(3)
    local spScale1 = sp1:getScale()
    local spScale2 = sp2:getScale()
    local xx1 = ap1[1] * spScale1
    local xx2 = ap2[1] * spScale2
    local yy1 = ap1[2] * spScale1
    local yy2 = ap2[2] * spScale2
    self._rootLayer:addChild(mc)
    if isfront then
        if isfront == 1 then
            mc:setLocalZOrder(1100)
        else
            mc:setLocalZOrder(1000)
        end
    else
        mc:setLocalZOrder(-1000)
    end
    mc:setUpdateFrameHook(function (sender)
        local x1, y1 = node1:getPosition()
        local x2, y2 = node2:getPosition()
        x1 = x1 + xx1
        x2 = x2 + xx2
        y1 = y1 + yy1
        y2 = y2 + yy2
        local dx = x2 - x1
        local dy = y2 - y1
        mc:setPosition(x1 + dx * 0.5, y1 + dy * 0.5)

        local angle = deg(-atan(dy / dx)) - 90
        if x2 - x1 > 0 then
            mc:setRotation(angle)
        else
            mc:setRotation(180 + angle)
        end
        local dis = sqrt(dx * dx + dy * dy)
        mc:setScale(dis / 200)
    end)
    self:addToMCUpdatePool(mc, false, true)
end
-- 怪兽受击光影, 点到人, 跟随
function BattleObjectLayer:playEffect_hit2_pt(name, isfront, x1, y1, soldier, height, dontScaleX)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    local node = self._objs[soldier.ID].node

    self._rootLayer:addChild(mc)
    if isfront then
        if isfront == 1 then
            mc:setLocalZOrder(1100)
        else
            mc:setLocalZOrder(1000)
        end
    else
        mc:setLocalZOrder(-1000)
    end
    mc:setUpdateFrameHook(function (sender)
        local x2, y2 = node:getPosition()
        x1 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x1 or x1
        local dx = x2 - x1
        local dy = y2 - y1
        mc:setPosition(x1 + dx * 0.5, y1 + dy * 0.5)

        local angle = deg(-atan(dy / dx)) - 90
        if x2 - x1 > 0 then
            mc:setRotation(angle)
        else
            mc:setRotation(180 + angle)
        end
        local dis = sqrt(dx * dx + dy * dy)
        if height == nil then height = 200 end
        if dontScaleX then
            mc:setScaleY(dis / height)
        else
            mc:setScale(dis / height)
        end
    end)
    self:addToMCUpdatePool(mc, false, true)
end
-- 怪兽受击光影, 点到人, 跟随
function BattleObjectLayer:playEffect_hit2_pt_team(name, isfront, x1, y1, team, height, dontScaleX)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)

    self._rootLayer:addChild(mc)
    if isfront then
        if isfront == 1 then
            mc:setLocalZOrder(1100)
        else
            mc:setLocalZOrder(1000)
        end
    else
        mc:setLocalZOrder(-1000)
    end
    mc:setUpdateFrameHook(function (sender)
        local x2, y2 = team.x, team.y
        x1 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x1 or x1
        x2 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x2 or x2
        local dx = x2 - x1
        local dy = y2 - y1
        mc:setPosition(x1 + dx * 0.5, y1 + dy * 0.5)

        local angle = deg(-atan(dy / dx)) - 90
        if x2 - x1 > 0 then
            mc:setRotation(angle)
        else
            mc:setRotation(180 + angle)
        end
        local dis = sqrt(dx * dx + dy * dy)
        if height == nil then height = 200 end
        if dontScaleX then
            mc:setScaleY(dis / height)
        else
            mc:setScale(dis / height)
        end
    end)
    self:addToMCUpdatePool(mc, false, true)
end
-- 怪兽受击光影, 点到点
function BattleObjectLayer:playEffect_hit2_pt2(name, isfront, x1, y1, x2, y2, height, dontScaleX)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)

    self._rootLayer:addChild(mc)
    if isfront then
        if isfront == 1 then
            mc:setLocalZOrder(1100)
        else
            mc:setLocalZOrder(1000)
        end
    else
        mc:setLocalZOrder(-1000)
    end
    x1 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x1 or x1
    x2 = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x2 or x2
    local dx = x2 - x1
    local dy = y2 - y1
    mc:setPosition(x1 + dx * 0.5, y1 + dy * 0.5)

    local angle = deg(-atan(dy / dx)) - 90
    if x2 - x1 > 0 then
        mc:setRotation(angle)
    else
        mc:setRotation(180 + angle)
    end
    local dis = sqrt(dx * dx + dy * dy)
    if height == nil then height = 200 end
    if dontScaleX then
        mc:setScaleY(dis / height)
    else
        mc:setScale(dis / height)
    end
    self:addToMCUpdatePool(mc, false, true)
end
-- buff光影 循环
function BattleObjectLayer:playEffect_buff(name, isfront, isstand, soldier, pos)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    if mc == nil then
        print("没有这个BUFF图", name)
        return
    end
    local obj = self._objs[soldier.ID]
    local role = obj.node.role
    local sp = obj.sp
    role:addChild(mc)

    local z
    if isfront then
        z = 1000
    else
        z = -1000
    end

    if pos == 1 then
        -- 头
        local spScale = sp:getScale()
        local ap = sp:getAp(2)
        mc:setPositionAndLocalZorder(ap[1] * spScale, ap[2] * spScale + 5, z)
    elseif pos == 2 then
        -- 身
        local spScale = sp:getScale()
        local ap = sp:getAp(1)
        mc:setPositionAndLocalZorder(ap[1] * spScale, ap[2] * spScale, z)
    else
        -- 脚
        mc:setLocalZOrder(z)
    end
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    mc:setScale(soldier.team.artzoom * mcScale)
    if not isstand then
        mc:setRotation3D(_3dVertex2)
    end
    self._mcPool[mc] = mc
    return mc
end
local actionInv = BC.actionInv
local dieEffName = {"", "ranshaosiwang", "bingdongsiwang", "dianjisiwang"}
function BattleObjectLayer:playEffect_die(idx, soldier)
    if BC.jump then return end
    if dieEffName[idx] == nil then return end
    local mc = mcMgr:createMovieClip("die_" .. dieEffName[idx])
    local sp = self._objs[soldier.ID].sp
    self._rootLayer:addChild(mc)
    local x, y = soldier.x, soldier.y
    x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    mc:setPositionAndLocalZorder(x, y, -y)
    sp:setVisible(false)
    local scale = soldier.team.artzoom * mcScale
    mc:setScale(-scale * soldier.direct, scale)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    mc:setRotation3D(_3dVertex1)
    local startFrame = GRandom(3)
    mc:gotoAndPlay(startFrame)
    self._mcPool[mc] = mc
    mc:addEndCallback(function (_, sender)
        sender:clearCallbacks()
        sender:stop()
    end)
    ScheduleMgr:delayCall(BC.DIE_EXIST_TIME * 1000, self, function(_, sender)
        if self._mcPool[sender] then
            self._mcPool[sender] = nil
            if soldier.dieMc and soldier.dieMc:isVisible() then
                self:playEffect_dieFadeOut(dieEffName[idx], soldier, x, y) 
            end
            sender:removeFromParent()    
            soldier.dieMc = nil
        end
    end, mc)
    soldier.dieMc = mc
    return mc
end

function BattleObjectLayer:playEffect_dieFadeOut(name, soldier, x, y)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip("ap2_" .. name)
    self._rootLayer:addChild(mc)
    x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    mc:setPositionAndLocalZorder(x, y, -y)
    local scale = soldier.team.artzoom * mcScale
    mc:setScale(-scale * soldier.direct, scale)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    mc:setRotation3D(_3dVertex1)
    self._mcPool[mc] = mc
    mc:addEndCallback(function (_, sender)
        self._mcPool[sender] = nil
        sender:removeFromParent()
    end)
end

-- 图腾光影 循环
function BattleObjectLayer:playEffect_totem(name, x, y, isfront, isstand, loop, scale, dir)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    if dir == nil then
        dir = 1
    end
    if scale == nil then
        scale = 1
    end
    local _scale = mcScale * scale
    mc:setScale(_scale * dir, _scale)
    self._rootLayer:addChild(mc)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    if isfront then
        mc:setPositionAndLocalZorder(x, y, -y)
    else
        mc:setPositionAndLocalZorder(x, y, -1000)
    end
    if isstand then
        mc:setRotation3D(_3dVertex1)
    end
    self._mcPool[mc] = mc
    if loop == 0 then
        mc:addEndCallback(function (_, sender)
            sender:clearCallbacks()
            sender:stop()
        end)
    else
        mc:addEndCallback(function (_, sender)
            sender:gotoAndPlay(loop)
        end)
    end
    return mc
end

-- 图腾光影 跟随人
function BattleObjectLayer:playEffect_totem2(name, soldier, pos, isfront, isstand, loop, scale, dir)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    if dir == nil then
        dir = 1
    end
    if scale == nil then
        scale = 1
    end
    local _scale = mcScale * scale
    mc:setScale(_scale * dir, _scale)
    local obj = self._objs[soldier.ID]
    local role = obj.node.role
    local sp = obj.sp
    role:addChild(mc)

    local z
    if isfront then
        z = 1000
    else
        z = -1000
    end
    if pos == 1 then
        -- 头
        local spScale = sp:getScale()
        local ap = sp:getAp(2)
        mc:setPositionAndLocalZorder(ap[1] * spScale, ap[2] * spScale + 5, z)
    elseif pos == 2 then
        -- 身
        local spScale = sp:getScale()
        local ap = sp:getAp(1)
        mc:setPositionAndLocalZorder(ap[1] * spScale, ap[2] * spScale, z)
    else
        -- 脚
        mc:setLocalZOrder(z)
    end
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    if not isstand then
        mc:setRotation3D(_3dVertex2)
    end
    self._mcPool[mc] = mc
    if loop == 0 then
        mc:addEndCallback(function (_, sender)
            sender:clearCallbacks()
            sender:stop()
        end)
    else
        mc:addEndCallback(function (_, sender)
            sender:gotoAndPlay(loop)
        end)
    end
    return mc
end

-- 图腾光影 屏幕
function BattleObjectLayer:playEffect_totem3(name, zOrder, loop)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    mc:setPositionAndLocalZorder(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5, -20 + zOrder)
    -- mc:setScale(MAX_SCREEN_WIDTH / 1136, MAX_SCREEN_HEIGHT / 640)
    self._totemLayer:addChild(mc)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)

    if ADOPT_IPHONEX then
        mc:setScale(1.35)
        mc:setPositionAndLocalZorder(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 50, -20 + zOrder)
    end 
    self._mcPool[mc] = mc
    if loop == 0 then
        mc:addEndCallback(function (_, sender)
            sender:clearCallbacks()
            sender:stop()
        end)
    else
        mc:addEndCallback(function (_, sender)
            sender:gotoAndPlay(loop)
        end)
    end
    return mc
end

-- 图腾消失光影
function BattleObjectLayer:playEffect_totemDisappear(name, x, y, isfront, isstand, scale, dir)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    if scale == nil then
        scale = 1
    end
    if dir == nil then
        dir = 1
    end
    mc:setScale(mcScale * scale * dir, mcScale * scale)
    self._rootLayer:addChild(mc)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    if isfront then
        mc:setPositionAndLocalZorder(x, y, -y)
    else
        mc:setPositionAndLocalZorder(x, y, -1000)
    end
    if isstand then
        mc:setRotation3D(_3dVertex1)
    end
    self._mcPool[mc] = mc
    mc:addEndCallback(function (_, sender)
        self._mcPool[sender] = nil
        sender:removeFromParent()
    end)
end

function BattleObjectLayer:playEffect_totemDisappear2(name, soldier, pos, isfront, isstand, scale)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    mc:setPosition(x, y)
    if scale == nil then
        scale = 1
    end
    mc:setScale(mcScale * scale)
    local role = self._objs[soldier.ID].node.role
    local sp = self._objs[soldier.ID].sp
    role:addChild(mc)
    local z
    if isfront then
        z = 1000
    else
        z = -1000
    end
    if pos == 1 then
        -- 头
        local spScale = sp:getScale()
        local ap = sp:getAp(2)
        mc:setPositionAndLocalZorder(ap[1] * spScale, ap[2] * spScale + 5, z)
    elseif pos == 2 then
        -- 身
        local spScale = sp:getScale()
        local ap = sp:getAp(1)
        mc:setPositionAndLocalZorder(ap[1] * spScale, ap[2] * spScale, z)
    else
        -- 脚
        mc:setLocalZOrder(z)
    end
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    if not isstand then
        mc:setRotation3D(_3dVertex2)
    end
    self._mcPool[mc] = mc
    mc:addEndCallback(function (_, sender)
        self._mcPool[sender] = nil
        sender:removeFromParent()
    end)
end

-- 蓄力光影
function BattleObjectLayer:playEffect_spell(name, x, y, isfront, isstand)
    if BC.jump then return end
    local mc = mcMgr:createMovieClip(name)
    x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    mc:setScale(mcScale)
    self._rootLayer:addChild(mc)
    mc:setPlaySpeed(BC.BATTLE_SPEED * MCSPEEDK)
    if isfront then
        mc:setPositionAndLocalZorder(x, y, 1000)
    else
        mc:setPositionAndLocalZorder(x, y, -1000)
    end
    if isstand then
        mc:setRotation3D(_3dVertex1)
    end
    self._mcPool[mc] = mc
    return mc
end

-- 设置光影缩放
function BattleObjectLayer:setEffectScale(mc, scale)
    mc:setScale(mcScale * scale)
end

function BattleObjectLayer:stopEffect(mc)
    if BC.jump then return end
    if mc == nil or tolua.isnull(mc) then return end
    mc:setVisible(false)
    self._mcPool[mc] = nil
    mc:removeFromParent()
end

function BattleObjectLayer:getSoldierSp(ID)
    return self._objs[ID].sp
end

function BattleObjectLayer:setCampBrightness(camp, value)
    if BC.jump then return end
    local list = self._camp[camp]
    local color = cc.c3b(255, 255, 255)
    if value == 0 then
        if BC.SHOW_TEAM_DIE_ICON and camp == 1 then
            self:hideTeamDieHead()
        end
        -- for i = 1, #self._building do
        --     self._building[i]:setBrightness(0)
        -- end
        for i = 1, #list do
            -- list[i].role:setBrightness(value)
            -- list[i].role:setColor(color)
            list[i].role:setCM(1, 1, 1, 1, 0, 0, 0, 0)
        end
        self._campBright[camp] = false
    else
        -- for i = 1, #self._building do
        --     self._building[i]:setBrightness(-75)
        -- end
        for i = 1, #list do
            -- list[i].role:setBrightness(value)
            -- list[i].role:setColor(color)
            list[i].role:setCM(1, 1, 1, 1, 0, 0, 0, 0)
        end
        self._campBright[camp] = true
    end
end

function BattleObjectLayer:cancelCampBrightness()
    local list = self._camp[1]
    for i = 1, #list do
        list[i].role:setCM(1, 1, 1, 1, 0, 0, 0, 0)
    end
    list = self._camp[2]
    for i = 1, #list do
        list[i].role:setCM(1, 1, 1, 1, 0, 0, 0, 0)
    end
end

function BattleObjectLayer:setSelectTeam(team)
    self._selectTeam = team
    if self._selectTeamBg then
        self._selectTeamBg:setVisible(self._selectTeam ~= nil)
        if team then
            self._selectTeamBg.bg1:setSpriteFrame("head"..team.camp.."_battle.png")
            if team.headPic then
                self._selectTeamBg.icon:setSpriteFrame(IconUtils.iconPath .. team.headPic..".jpg")
            end
            self:setSelectTeamHP()
            local width, height = team.soldier[1]:getSize()
            if BattleUtils.XBW_SKILL_DEBUG then
                team.soldier[1]:printAttr()
            end
            
            self._selectTeamBg.bg1:setPosition(0, 60 + height * 0.5)
            self._selectTeamBg.bg2:setPosition(0, 30 + height * 0.5)
            local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - self._selectTeam.x or self._selectTeam.x
            self._selectTeamBg:setPosition(_x, self._selectTeam.y)
            self._selectTeamBg.x, self._selectTeamBg.y = _x, self._selectTeam.y
        end
    end
end
function BattleObjectLayer:setSelectTeamHP()
    if self._selectTeam == nil then return end
    local hp = self._selectTeam.curHP
    local maxHp = self._selectTeam.maxHP
    local pro = hp / maxHp
    if self._selectTeamBg then
        self._selectTeamBg.hp:setPercent(pro * 100)
        if pro > 0.33 then
            self._selectTeamBg.hp:loadTexture("hp2_battle.png", 1)
        else
            self._selectTeamBg.hp:loadTexture("hp3_battle.png", 1)
        end
    end
    if BattleUtils.XBW_SKILL_DEBUG then
        local bg = self._selectTeamBg
        if bg then
            if bg.label1 == nil then
                for i = 1, 16 do
                    local label = cc.Label:createWithTTF("", UIUtils.ttfName, 16)
                    label:setColor(cc.c3b(255, 255, 120))
                    label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
                    label:setAnchorPoint(0, 0.5)
                    label:setPosition(50, (i - 1) * 20)
                    label:setGlobalZOrder(1000)
                    bg:addChild(label)
                    bg["label"..i] = label
                end
            end

            local label
            local team = self._selectTeam
            local count = #team.aliveSoldier
            local soldier, def, atkspeed, moveSpeed
            local level = team.level
            for i = 1, 16 do
                label = bg["label"..i]
                if i > count then
                    label:setVisible(false)
                else
                    soldier = team.aliveSoldier[i]
                    label:setVisible(true)
                    def = (soldier.attr[BC.ATTR_Def] + soldier.attr[BC.ATTR_DefAdd] * (level + 9)) * (1 + soldier.attr[BC.ATTR_DefPro] * 0.01)
                    atkSpeed = soldier.atkspeed * (1 + BC.K_ASPEED * soldier.attr[BC.ATTR_Haste])
                    moveSpeed = soldier.team.speedMove + soldier.attr[BC.ATTR_MSpeed]
                    label:setString("hp:"..soldier.HP.."/"..soldier.maxHP.." 攻:"..soldier.atk.." 防:"..def.." 攻速:"..atkSpeed .." 移速:"..moveSpeed 
                        .. " 暴击:" .. soldier.attr[BC.ATTR_Crit] .. " 闪避:" .. soldier.attr[BC.ATTR_Dodge] .. " 命中:" .. soldier.attr[BC.ATTR_Hit]
                        .. " 破甲:" .. soldier.attr[BC.ATTR_Pen]
                        .. " 兵伤:" .. soldier.attr[BC.ATTR_DamageInc]
                        .. " 兵免:" .. soldier.attr[BC.ATTR_DamageDec]
                        .. " 法免:" .. soldier.attr[BC.ATTR_DecAll]
                        )
                end
            end
        end
    end
end

function BattleObjectLayer:stopTipEffect(mc)
    mc:setVisible(false)
    self._mcPool[mc] = nil
    mc:getParent():removeFromParent()
end

local color0 = cc.c3b(255, 51, 71)
local color1 = cc.c3b(255, 255, 255)
-- 技能区域
function BattleObjectLayer:showSkillArea(scale, name, des, level, icon, direction, tag)
    self._skillAreaIsShow = true
    if tag == 100 then
        self._skillAreaColor = 85
    else
        self._skillAreaColor = 0
    end
    
    if direction == nil then
        if scale == 999 then
            self._skillAreaType = 3
            self._skillArea3:stopAllActions()
            self._skillArea3:setVisible(true)
            self._skillArea3:play()
            self._skillArea3:setOpacity(255)
            self._skillArea3.r = 999
            self._skillArea3.visible = true
        else
            self._skillAreaType = 1
            self._skillArea:stopAllActions()
            self._skillArea:setVisible(true)
            self._skillArea:play()
            self._skillArea:setOpacity(255)
            self._skillArea:setScale(scale)
            self._skillArea.r = scale * 75
            self._skillArea.visible = true
        end
    else
        if direction == 1 then
            self._skillArea2:setRotation(90)
        else
            self._skillArea2:setRotation(0)
        end
        self._skillAreaType = 2
        self._skillArea2:setVisible(true)
        self._skillArea2.visible = true
    end
    self._skillNameNode:setVisible(true)
    self._skillNameNode.des:stopAllActions()
    self._skillNameNode.name:setString(name.." Lv."..level)
    if GameStatic.checkZuoBi_8 and self._skillNameNode and self._skillNameNode.name then
        local list = string.split(self._skillNameNode.name:getString(), " Lv.")
        if #list > 1 and tonumber(list[2]) > GameStatic.checkZuoBi_8_value then
            ApiUtils.playcrab_lua_error("jinenglevel", serialize({name, tonumber(list[2])}))
            if GameStatic.kickZuoBi_8 then
                do _G["AppExit"..math.random(10)]() if not APP_EXIT then ServerManager = nil ModelManager = nil end return end
            end
        end
    end
    self._skillNameNode.des:setString(des)
    self._skillNameNode.des:setColor(cc.c3b(255, 255, 255))
    self._skillNameNode.des:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(0.8, 100, 230, 100), cc.TintTo:create(0.8, 255, 255, 255))))
    self._skillLine:setVisible(true)
    local pt = icon:convertToWorldSpace({x = 0, y = 0})
    self._skillLine:setPosition(pt.x + 50, pt.y + 100)
    self._skillLine.x, self._skillLine.y = pt.x + 50, pt.y + 100
end

function BattleObjectLayer:updateSkillAreaPos(x, y, x1, y1)
    local hue = self._skillAreaColor
    if self._skillAreaIsShow then
        if self._skillAreaType == 2 then
            self._skillArea2:setPosition(x, y)
            self._skillNameNode:setPosition(x1, y1 + 100)

            local maxHeight = MAX_SCREEN_HEIGHT - 100

            if y1 > maxHeight then
                self._skillNameNode:setVisible(false)
                self._skillArea2:setColor(color0)
                self._skillArea2:setHue(0)
                self._skillLine:setColor(color0)
                self._skillLine:setHue(0)
            else
                self._skillNameNode:setVisible(true)
                self._skillArea2:setColor(color1)
                self._skillArea2:setHue(hue)
                self._skillLine:setColor(color1)
                self._skillLine:setHue(hue)
            end

            local x2, y2 = self._skillLine.x, self._skillLine.y
            if x2 == nil then return end
            -- 连线
            local dx = x1 - x2
            local dy = y1 - y2
            local dis = math.sqrt(dx * dx + dy * dy)
            local angle = deg(-atan(dy / dx)) + 90
            if x2 - x1 >= 0 then
                angle = angle + 180
            end
            self._skillLine:setScaleY(dis / 340)
            self._skillLine:setRotation(angle)
            return
        end
        local skillArea 
        if self._skillAreaType == 3 then 
            skillArea = self._skillArea3
        else
            skillArea = self._skillArea
        end
        skillArea:setPosition(x, y)
        self._skillNameNode:setPosition(x1, y1 + 100)

        local maxHeight = MAX_SCREEN_HEIGHT - 100

            if y1 > maxHeight then
                self._skillNameNode:setVisible(false)
                skillArea:setColor(color0)
                skillArea:setHue(0)
                self._skillLine:setColor(color0)
                self._skillLine:setHue(0)
            else
                self._skillNameNode:setVisible(true)
                skillArea:setColor(color1)
                skillArea:setHue(hue)
                self._skillLine:setColor(color1)
                self._skillLine:setHue(hue)
            end

        local x2, y2 = self._skillLine.x, self._skillLine.y
        if x2 == nil then return end
        -- 连线
        local dx = x1 - x2
        local dy = y1 - y2
        local dis = math.sqrt(dx * dx + dy * dy)
        local angle = deg(-atan(dy / dx)) + 90
        if x2 - x1 >= 0 then
            angle = angle + 180
        end
        self._skillLine:setScaleY(dis / 340)
        self._skillLine:setRotation(angle)

        -- 处理被覆盖的角色
        local ceil = math.ceil
        local b = skillArea.r
        local a = b * 2
        a = a * a
        b = b * b
        local dx, dy, ptx, pty
        local pt
        local role, node, obj, sp

        local rr, gg, bb = 189, 241, 150
        local pro = 65
        local pro1 = pro * 0.01
        local pro2 = 1 - pro1
        rr, gg, bb = rr * pro1, gg * pro1, bb * pro1
        for i = 1, 2 do
            if self._campBright[i] then
                local index = self._campBrightAreaCheckIndex[i]
                local count = 0
                local campCount = #self._camp[i]
                if campCount > 0 then
                    local MAX_CHECK_FRAME = ceil(#self._camp[i] / 2.5)
                    local max = campCount
                    if max > MAX_CHECK_FRAME then
                        max = MAX_CHECK_FRAME
                    end
                    while true do
                        count = count + 1
                        sp = self._camp[i][index]
                        role = sp.role
                        node = sp.node
                        obj = sp.obj
                        ptx, pty = node:getPosition()
                        dx = x - ptx
                        dy = y - pty
                        if dx * dx / a + dy * dy / b <= 1 and not obj.die then
                            -- role:setColor(color1)
                            role:setCM(pro2, pro2, pro2, 1, rr, gg, bb, 0)
                        else
                            -- role:setColor(color2)
                            role:setCM(1, 1, 1, 1, 0, 0, 0, 0)
                        end
                        index = index + 1
                        if index > campCount then
                            index = 1
                        end
                        if count > max then
                            self._campBrightAreaCheckIndex[i] = index
                            break
                        end
                    end
                end
            end
        end
    end
end

function BattleObjectLayer:flashSkillArea(x, y)
    self._skillAreaIsShow = false
    if self._skillAreaType == 2 then
        self._skillArea2:setVisible(false)
        self._skillNameNode:setVisible(false)
        self:cancelCampBrightness()
        self._skillNameNode.des:stopAllActions()
        self._skillArea2.visible = false
    else
        local skillArea
        if self._skillAreaType == 3 then
            skillArea = self._skillArea3
        else
            skillArea = self._skillArea
        end
        skillArea:stopAllActions()
        skillArea:setVisible(true)
        skillArea:play()
        self._skillNameNode:setVisible(false)
        self:cancelCampBrightness()
        self._skillNameNode.des:stopAllActions()
        skillArea.visible = true
        skillArea:setPosition(x, y)
        skillArea:setOpacity(255)
        local scale = skillArea:getScale()
        skillArea:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, scale * 1.05), cc.Spawn:create(cc.ScaleTo:create(0.2, scale * 1.1), cc.FadeOut:create(0.2)), cc.CallFunc:create(function () 
            skillArea:setVisible(false) 
            skillArea:stop()
            skillArea:setScale(1)
            skillArea.visible = false
            end)))
    end
    self._skillLine:setVisible(false)
end

-- 独立技能圈, 播放完毕就移除
function BattleObjectLayer:flashSkillAreaEx(scale, x, y, camp)
    if scale > 3 then return end
    if self._skillAreaType == 2 then return end
    local skillArea = mcMgr:createMovieClip("fanweiquan_skillarea")
    skillArea:setCascadeOpacityEnabled(true)
    skillArea:setCascadeColorEnabled(true)
    self._rootLayer:addChild(skillArea, -10001)
    skillArea:setScale(scale)
    x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - x or x
    skillArea:setPosition(x, y)
    if camp == 1 then
        skillArea:setHue(-180)
    else
        skillArea:setHue(0)
    end
    skillArea:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, scale * 1.05), cc.Spawn:create(cc.ScaleTo:create(0.3, scale * 1.1), 
        cc.FadeOut:create(0.2)), cc.RemoveSelf:create(true)))
end

function BattleObjectLayer:hideSkillArea()
    self:cancelCampBrightness()
    self._skillAreaIsShow = false
    if self._skillAreaType == 2 then
        self._skillArea2.visible = false
        self._skillNameNode:setVisible(false)
        self._skillNameNode.des:stopAllActions()
        self._skillArea2:setVisible(false)
        self._skillLine:setVisible(false)
    else
        local skillArea
        if self._skillAreaType == 3 then
            skillArea = self._skillArea3
        else
            skillArea = self._skillArea
        end
        skillArea:stopAllActions()
        skillArea.visible = false
        self._skillNameNode:setVisible(false)
        self._skillNameNode.des:stopAllActions()
        skillArea:setVisible(false)
        skillArea:stop()
        self._skillLine:setVisible(false)
    end
end

function BattleObjectLayer:pauseSkillArea()
    self:cancelCampBrightness()
    self._skillAreaIsShow = false
    if self._skillAreaType == 2 then
        self._skillArea2.visible = false
        self._skillNameNode:setVisible(false)
        self._skillArea2:setVisible(false)
        self._skillLine:setVisible(false)
    else
        local skillArea
        if self._skillAreaType == 3 then
            skillArea = self._skillArea3
        else
            skillArea = self._skillArea
        end
        skillArea.visible = false
        self._skillNameNode:setVisible(false)
        skillArea:setVisible(false)
        skillArea:stop()
        self._skillLine:setVisible(false)
    end
end

function BattleObjectLayer:resumeSkillArea()
    self._skillAreaIsShow = true
    if self._skillAreaType == 2 then
        self._skillArea2.visible = true
        self._skillNameNode:setVisible(true)
        self._skillArea2:setVisible(true)
        self._skillLine:setVisible(true)
    else
        local skillArea
        if self._skillAreaType == 3 then
            skillArea = self._skillArea3
        else
            skillArea = self._skillArea
        end
        skillArea.visible = true
        self._skillNameNode:setVisible(true)
        skillArea:setVisible(true)
        skillArea:play()
        self._skillLine:setVisible(true)
    end
end

-- 脚下光环
function BattleObjectLayer:addTeamHalo(team)
    local mc
    if team.camp == 1 then
        mc = mcMgr:createMovieClip("hexinmubiaobuff1_hexinmubiaobuff")
    else
        mc = mcMgr:createMovieClip("hexinmubiaobuff2_hexinmubiaobuff")
    end
    self._rootLayer:addChild(mc)
    mc:setScale(team.picScale)
    local _x = BC_reverse and MAX_SCENE_WIDTH_PIXEL - team.x or team.x
    mc:setPositionAndLocalZorder(_x, team.y, -650)

    local data = 
    {
        team = team,
        x = _x,
        y = team.y,
        visible = true,
        scale = team.picScale,
        mc = mc,
    }
    self._teamHalo[#self._teamHalo + 1] = data
end

function BattleObjectLayer:updateTeamHalo()
    local data, x, y, visible, mc, team
    for i = 1, #self._teamHalo do
        data = self._teamHalo[i]
        team = data.team
        visible = data.team.state ~= ETeamStateDIE
        mc = data.mc
        if visible ~= data.visible then
            data.visible = visible
            mc:setVisible(visible)
            if visible then
                local teamx = BC_reverse and MAX_SCENE_WIDTH_PIXEL - team.x or team.x
                local teamy = team.y
                data.x = teamx
                data.y = teamy
                mc:setPosition(teamx, teamy)
                return
            end
        end
        local teamx = BC_reverse and MAX_SCENE_WIDTH_PIXEL - team.x or team.x
        local teamy = team.y
        if data.x ~= teamx or data.y ~= teamy then
            if abs(data.x - teamx) < 1 then
                x = teamx
            else
                x = data.x + (teamx - data.x) * 0.4
            end
            if abs(data.x - teamx) < 1 then
                y = team.y
            else
                y = data.y + (team.y - data.y) * 0.4
            end
            data.x = x
            data.y = y
            mc:setPosition(x, y)
        end
    end
end

function BattleObjectLayer:clearTeamHalo()
    self._teamHalo = {}
end

function BattleObjectLayer.dtor()
    _3dVertex1 = nil
    _3dVertex2 = nil
    abs = nil
    actionInv = nil
    AnimAP = nil
    atan = nil
    BATTLE_3D_ANGLE = nil
    
    BattleObjectLayer = nil
    battleTick = nil
    BC = nil
    bulletname = nil
    callFunc = nil
    cc = nil
    
    COMMONBUFF_ACTION = nil
    COMMONBUFF_MAX_FRAME = nil
    defaultColor = nil
    deg = nil
    dieEffName = nil
    dt = nil
    ECamp = nil
    EDirect = nil
    EEffFlyType = nil
    EMotion = nil
    EMotionATTACK = nil
    EMotionBORN = nil
    EMotionCAST1 = nil
    EMotionCAST2 = nil
    EMotionCAST3 = nil
    EMotionDIE = nil
    EMotionIDLE = nil
    EMotionMOVE = nil
    enable_shadow = nil
    EState = nil
    ETeamState = nil
    ETeamStateDIE = nil
    fadeOut = nil
    floor = nil
    hpBar_type = nil
    hplabeltable = nil
    kscale = nil
    LABEL = nil
    math = nil
    MAX_COUNT_HUD = nil
    mcMgr = nil
    mcScale = nil
    MovieClipAnim = nil
    next = nil
    os = nil
    pairs = nil
    pc = nil
    PCTools = nil
    scaleTo = nil
    seq = nil
    sfc = nil
    sfResMgr = nil
    SHADOW_SCALE = nil
end

function BattleObjectLayer.dtor1()
    SHOW_HP_ENABLE = nil
    showSkillNameBg = nil
    SpriteFrameAnim = nil
    sqrt = nil
    tab = nil
    table = nil
    tonumber = nil
    tostring = nil
    ttfname = nil
    GLOBAL_SP_SCALE = nil
    kmaxalpha = nil
    format = nil
    frameInv = nil
    HIT_FLY_ACTION = nil
    color0 = nil
    color1 = nil
    color2 = nil
    BC_reverse = nil
    MAX_SCENE_WIDTH_PIXEL = nil
    self_updateScale = nil
    self_updateHitFly = nil
    self_updateWindFly = nil
    self_updateCommonBuff = nil
    self_updateCommonAttr = nil
    self_updateMC = nil
end

return BattleObjectLayer
