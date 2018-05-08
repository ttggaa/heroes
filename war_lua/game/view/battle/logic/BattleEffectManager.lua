--[[
    Filename:    BattleEffectManager.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-01-16 11:54:07
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

local BattleEffectManager = class("BattleEffectManager")

local MAX_COUNT_POOL = 317
local BATTLE_3D_ANGLE = BC.BATTLE_3D_ANGLE
local _3dVertex1 = cc.Vertex3F(BATTLE_3D_ANGLE, 0, 0)
local cosA = math.cos(math.rad(BATTLE_3D_ANGLE))
local sinA = math.sin(math.rad(BATTLE_3D_ANGLE))
local battleTick
function BattleEffectManager:ctor(layer)
    BATTLE_3D_ANGLE = BC.BATTLE_3D_ANGLE
    _3dVertex1 = cc.Vertex3F(BATTLE_3D_ANGLE, 0, 0)
    cosA = math.cos(math.rad(BATTLE_3D_ANGLE))
    sinA = math.sin(math.rad(BATTLE_3D_ANGLE))

    battleTick = BC.BATTLE_TICK
    self:loadBulletRes()
    self._batchNode = cc.SpriteBatchNode:create("asset/role/bullet.png", MAX_COUNT_POOL)
    self._batchNode:setLocalZOrder(1024)
    self._batchNode:setRotation3D(_3dVertex1)
    self._rootLayer = layer
    self._rootLayer:addChild(self._batchNode)

    self._batchNode2 = cc.SpriteBatchNode:create("asset/role/bullet.png", MAX_COUNT_POOL)
    self._batchNode2:setLocalZOrder(-1024)
    self._batchNode2:setRotation3D(_3dVertex1)
    self._rootLayer:addChild(self._batchNode2)
    -- 正在使用的bullet
    self._bullet = {}
    -- 未在使用的bullet
    self._bulletPool = {}

    -- 缓存
    local sp, eff
    for i = 1, MAX_COUNT_POOL do
        sp = cc.Sprite:createWithSpriteFrame(self._resCache["putongjian"][1])
        sp:setScale(0.5)
        sp:retain()
        self._batchNode:addChild(sp)
        sp:setVisible(false)
        eff = {flyType = 0, value = 0, beginTick = 0, endTick = 0, 
                beginPos = {x = 0, y = 0}, beginOffset = {x = 0, y = 0},
                endPos = {x = 0, y = 0}, target = nil, endOffset = {x = 0, y = 0},
                sp = sp, res = nil, frame = 1, line = nil, rotateSpeed = 0, loop = false}
        self._bulletPool[i] = eff
    end

end
local sfc = cc.SpriteFrameCache:getInstance()
local slen = string.len
local tonumber = tonumber
local sub = string.sub
function BattleEffectManager:loadBulletRes()
    self._resCache = {}
    sfc:addSpriteFrames("asset/role/bullet.plist", "asset/role/bullet.png")
    local map = cc.FileUtils:getInstance():getValueMapFromFile("asset/role/bullet.plist")
    local len, frame, name
    for k, v in pairs(map["frames"]) do
        len = slen(k)
        frame = tonumber(sub(k, len - 4, len - 4))
        name = sub(k, 1, len - 6)
        if self._resCache[name] == nil then
            self._resCache[name] = {}
        end
        self._resCache[name][frame] = sfc:getSpriteFrame(k) 
    end
    for name, cache in pairs(self._resCache) do
        if #cache > 1 then
            local list = {}
            for i = 1, #cache do
                list[i] = {cache[i], nil}
            end
            for i = 1, #cache do
                if i == #cache then
                    list[i][2] = list[1]
                else
                    list[i][2] = list[i + 1]
                end
            end
            list[#cache][3] = true
            cache.head = list[1]
        else
            cache.head = {cache[1], nil, true}
        end
    end
end

function BattleEffectManager:unloadBulletRes()
    sfc:removeSpriteFramesFromFile("asset/role/bullet.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/role/bullet.png")
end

local fmod = math.fmod
function BattleEffectManager:update()
    battleTick = BC.BATTLE_TICK
    local fi = BC.frameInv
    if next(self._bullet) ~= nil then
        for k, v in pairs(self._bullet) do
            self:bulletUpdate(k, v, battleTick, fi)
        end
    end
end

local EEffFlyTypePARABOLA = EEffFlyType.PARABOLA
local EEffFlyTypeLINE = EEffFlyType.LINE
local EEffFlyTypePARABOLA_L = EEffFlyType.PARABOLA_L
local EEffFlyTypePARABOLA_R = EEffFlyType.PARABOLA_R
local EEffFlyTypePARABOLA_L_R = EEffFlyType.PARABOLA_L_R
local EEffFlyTypeDISAPPEAR = EEffFlyType.DISAPPEAR

local deg = math.deg
local atan = math.atan
local floor = math.floor
function BattleEffectManager:bulletUpdate(key, eff, tick, fi)
    local sp = eff.sp
    if tick > eff.endTick then
        sp:setVisible(false)
        self._bulletPool[key] = eff
        self._bullet[key] = nil
    else
        if not sp.begin and tick > eff.beginTick + fi then
            sp:setVisible(true)
            sp.begin = true
        end
        if sp.begin and eff.res[2] then
            if eff.frame == 1 then
                eff.frame = 2
            else
                eff.frame = 1
                if not eff.loop and eff.res[3] then
                    eff.endTick = -1
                    sp:setVisible(false)
                end
                eff.res = eff.res[2]
                sp:setSpriteFrame(eff.res[1])
            end
        end
        if eff.followNode then
            local node = eff.followNode
            local flipX = node.role:getScaleX() == -1
            sp:setFlipX(flipX)
            local __x, __y = node:getPosition()
            if flipX then
                __x = __x + eff.beginOffset.x
            else
                __x = __x - eff.beginOffset.x
            end
            __y = __y + eff.beginOffset.y
            sp:setPosition(__x, __y * cosA)
            sp:setPositionZ(-__y * sinA)
        end
        if eff.flyType == nil then return end
        if eff.flyType == EEffFlyTypeDISAPPEAR then
            if tick - eff.beginTick > 1.75 then
                local o = tick - eff.beginTick - 1.75
                o = 255 - floor(o * 2 * 255)
                eff.sp:setOpacity(o)
            end
            return
        end
        local rate = (tick - eff.beginTick) / (eff.endTick - eff.beginTick)
        local pt1x, pt1y, pt2x, pt2y, x, y
        pt1x = eff.beginPos.x
        pt1y = eff.beginPos.y
        if eff.target == nil then
            pt2x = eff.endPos.x
            pt2y = eff.endPos.y
        else
            x, y = eff.target:getPosition()
            pt2x = x + eff.endOffset.x
            pt2y = y + eff.endOffset.y
        end
        
        local lastPtx, lastPty = sp.x, sp.y
        local nowPtx = lastPtx
        local nowPty = lastPty
        if eff.flyType == EEffFlyTypeLINE then
            -- 匀加速
            local dis = eff.line.dis
            local a = eff.line.a
            local speed = eff.line.speed
            local t = tick - eff.beginTick
            rate = (speed * t + 0.5 * a * t * t) / dis
            nowPtx = pt1x + (pt2x - pt1x) * rate 
            nowPty = pt1y + (pt2y - pt1y) * rate
        -- elseif eff.flyType == EEffFlyTypePARABOLA_L then
            -- rate = (tick - eff.beginTick) / (eff.endTick - eff.beginTick)
            -- nowPtx = pt1x + (pt2x - pt1x) * rate 
            -- nowPty = pt1y + (pt2y - pt1y) * rate
        else
        -- elseif eff.flyType == EEffFlyTypePARABOLA then
            -- 抛物线
            local x1 = pt1x 
            local y1 = pt1y
            local x3 = pt2x
            local y3 = pt2y
            local width = x3 - x1
            local x2 = x1 + width / 2
            local y2 = y1 + eff.value
            local x1x1 = x1*x1
            local x1_x2 = x1x1-x2*x2
            local x1_x3 = x1x1-x3*x3
            local b = ((y1-y3)*x1_x2-(y1-y2)*x1_x3)/((x1-x3)*x1_x2-(x1-x2)*x1_x3)
            local a = ((y1-y2)-b*(x1-x2))/x1_x2
            local c = y1-a*x1x1-b*x1
            local _x = pt1x + (pt2x - pt1x) * rate
            local _y = a*_x*_x + b*_x + c
            nowPtx = _x
            nowPty = _y
        end
        local yy1 = pt1y - eff.beginOffset.y
        local yy2 = pt2y - eff.endOffset.y
        local py = yy1 + (yy2 - yy1) * rate 
        sp:setPosition(nowPtx, nowPty * cosA)
        sp:setPositionZ(- py * sinA)
        sp.x, sp.y = nowPtx, nowPty
        if floor(nowPtx) == floor(lastPtx) and floor(nowPty) == floor(lastPty) then
            return
        end
        local angle = deg(-atan((nowPty - lastPty) / (nowPtx - lastPtx)))
        if eff.flyType ~= EEffFlyTypePARABOLA_R and eff.flyType ~= EEffFlyTypePARABOLA_L_R then
            if nowPtx - lastPtx > 0 then
                eff.sp:setRotation(angle)
                if eff.sp.__filpy ~= false then
                    eff.sp:setFlipY(false)
                    eff.sp.__filpy = false
                end
            else
                eff.sp:setRotation(180 + angle)
                if eff.sp.__filpy ~= true then
                    eff.sp:setFlipY(true)
                    eff.sp.__filpy = true
                end
            end
        else
            local rotate = eff.sp.rotate
            rotate = rotate + eff.rotateSpeed * fi
            if rotate > 360 then
                rotate = rotate - 360
            end
            if rotate < 0 then
                rotate = rotate + 360
            end
            eff.sp.rotate = rotate
            eff.sp:setRotation(rotate)
        end

    end
end

-- 播放特效, 两点之间运动
local sqrt = math.sqrt
local abs = math.abs
-- 如果target或者caster存在, 前面的坐标则为偏移值
-- stype/dtype  1 跟随点   2 固定点
function BattleEffectManager:playBullet(delays, name, _type, speed, stype, spt, dtype, dpt, dis, scale)
    if self._resCache[name] == nil then
        print("not bullet named " .. name)
        return 0
    end
    local eff = nil
    if next(self._bulletPool) ~= nil then
        for k, v in pairs(self._bulletPool) do
            eff = v
            self._bulletPool[k] = nil
            self._bullet[k] = eff
            break
        end
    end
    if eff == nil then
        return 0
    end
    eff.loop = true
    eff.followNode = nil
    eff.frame = 1
    eff.res = self._resCache[name].head
    eff.frameCount = #self._resCache[name]
    local sp = eff.sp
    sp:setSpriteFrame(eff.res[1])
    sp:setOpacity(255)
    sp:setAnchorPoint(0.5, 0.5)
    sp:setScale(0.5 * scale)
    sp:setFlipX(false)
    sp:setVisible(false)
    sp.begin = false
    sp.rotate = 0
    if sp:getParent() == self._batchNode2 then
        sp:removeFromParent()
        self._batchNode:addChild(sp)
    end
    local x, y
    local caster, target
    local srcx, srcy
    local destx, desty
    if stype == 1 then
        caster = spt[3]
        srcx, srcy = spt[1], spt[2]
        x, y = caster:getPosition()
        eff.beginPos.x = x + srcx
        eff.beginPos.y = y + srcy
        eff.beginOffset.x = srcx
        eff.beginOffset.y = srcy
    else
        srcx, srcy = spt[1], spt[2]
        eff.beginPos.x = srcx + spt[3]
        eff.beginPos.y = srcy + spt[4]
        eff.beginOffset.x = spt[3]
        eff.beginOffset.y = spt[4]
    end
    if dtype == 1 then
        target = dpt[3]
        destx, desty = dpt[1], dpt[2]
        x, y = target:getPosition()
        eff.endPos.x = x + destx
        eff.endPos.y = y + desty
        eff.endOffset.x = destx
        eff.endOffset.y = desty
    else
        destx, desty = dpt[1], dpt[2]
        eff.endPos.x = destx + dpt[3]
        eff.endPos.y = desty + dpt[4]
        eff.endOffset.x = dpt[3]
        eff.endOffset.y = dpt[4]
    end
    eff.target = target   

    local pt1x, pt1y, pt2x, pt2y
    pt1x = eff.beginPos.x
    pt1y = eff.beginPos.y
    pt2x = eff.endPos.x
    pt2y = eff.endPos.y
    sp.x, sp.y = pt1x, pt1y
    sp:setPosition(pt1x, pt1y)

    local angle = deg(-atan((pt2y - pt1y) / (pt2x - pt1x)))
    if pt2x - pt1x > 0 then
        sp:setRotation(angle)
    else
        sp:setRotation(180 + angle)
    end
    local ms = 0
    local value
    sp:stopAllActions()
    if _type == EEffFlyTypeLINE then
        local a = speed * 5
        local v0 = speed * 0.3
        ms = (sqrt(v0 * v0 + 2 * a * dis) - v0) / a
        eff.line = {dis = dis, speed = v0, a = a}
    elseif _type == EEffFlyTypePARABOLA_L or _type == EEffFlyTypePARABOLA_L_R then
        local h
        if dis < 100 then
            h = dis * 0
        else
            h = dis * 0.05
        end
        if pt2y > pt1y then
            value = pt2y - pt1y + h
        else
            value = h
        end
        ms = dis / speed
        if _type == EEffFlyTypePARABOLA_L_R then
            if pt2x > pt1x then
                eff.rotateSpeed = 360 * 5
            else
                eff.rotateSpeed = -360 * 5
                sp:setFlipX(true)
            end

        end
    else
        local h
        if dis < 100 then
            h = dis * 0.2
        else
            h = dis * 0.25
        end
        if pt2y > pt1y then
            value = pt2y - pt1y + h
        else
            value = h
        end
        ms = dis / speed
        if _type == EEffFlyTypePARABOLA_R then
            if pt2x > pt1x then
                eff.rotateSpeed = 360
            else
                eff.rotateSpeed = -360
                sp:setFlipX(true)
            end
        end
    end

    local tick = battleTick + delays
    eff.flyType = _type
    eff.value = value
    eff.beginTick = tick
    eff.endTick = tick + ms
    return ms
end

function BattleEffectManager:playBoom(name, x, y, scale)
    if name == nil or self._resCache[name] == nil then return end
    local eff = nil
    if next(self._bulletPool) ~= nil then
        for k, v in pairs(self._bulletPool) do
            eff = v
            self._bulletPool[k] = nil
            self._bullet[k] = eff
            break
        end
    end
    if eff == nil then
        return 0
    end
    eff.loop = false
    eff.followNode = nil
    eff.frame = 1
    eff.res = self._resCache[name].head
    local sp = eff.sp
    sp:setSpriteFrame(eff.res[1])
    sp:setOpacity(255)
    sp:setAnchorPoint(0.5, 0.5)
    sp:setVisible(false)
    if sp:getParent() == self._batchNode2 then
        sp:removeFromParent()
        self._batchNode:addChild(sp)
    end
    sp.begin = false
    sp:setScale(2 * scale)
    sp:setFlipX(false)
    sp:setRotation(0)
    sp.x, sp.y = x, y
    sp:setPosition(x, y * cosA)
    sp:setPositionZ(- y * sinA)
    local tick = battleTick
    eff.flyType = nil
    eff.value = value
    eff.beginTick = tick
    eff.endTick = tick + #self._resCache[name] * 0.07
end

local runArtName = "jiasu"
function BattleEffectManager:playRunArt(node, offsetx, offsety, scale)
    local eff = nil
    if next(self._bulletPool) ~= nil then
        for k, v in pairs(self._bulletPool) do
            eff = v
            self._bulletPool[k] = nil
            self._bullet[k] = eff
            break
        end
    end
    if eff == nil then
        return nil
    end
    eff.loop = true
    eff.frame = 1
    eff.res = self._resCache[runArtName].head
    local sp = eff.sp
    sp:setSpriteFrame(eff.res[1])
    sp:setOpacity(255)
    if sp:getParent() == self._batchNode then
        sp:removeFromParent()
        self._batchNode2:addChild(sp)
    end
    sp:setAnchorPoint(0.5, 0.5)
    sp:setVisible(false)
    sp.begin = false
    sp:setScale(scale)
    sp:setRotation(0)
    local x, y = node:getPosition()
    sp.x, sp.y = x + offsetx, y + offsety
    eff.beginOffset.x, eff.beginOffset.y = offsetx + 94 * scale, offsety
    sp:setPosition(x, y * cosA)
    sp:setPositionZ(- y * sinA)
    local tick = battleTick
    eff.flyType = nil
    eff.value = value
    eff.beginTick = tick
    eff.endTick = tick + 1000
    eff.followNode = node
    return eff
end

function BattleEffectManager:stopRunArt(eff)
    eff.endTick = battleTick
end


local dieArtName = "commondie"
-- 死的时候地上的血迹
function BattleEffectManager:playDieBlood(node, camp, scale)
    local eff = nil
    if next(self._bulletPool) ~= nil then
        for k, v in pairs(self._bulletPool) do
            eff = v
            self._bulletPool[k] = nil
            self._bullet[k] = eff
            break
        end
    end
    if eff == nil then
        return nil
    end
    eff.loop = false
    eff.frame = 1
    eff.res = self._resCache[dieArtName..camp].head
    local sp = eff.sp
    sp:setSpriteFrame(eff.res[1])
    sp:setOpacity(255)
    if sp:getParent() == self._batchNode then
        sp:removeFromParent()
        self._batchNode2:addChild(sp)
    end
    sp:setAnchorPoint(0.5, 0.5)
    sp:setVisible(false)
    sp.begin = false
    sp:setScale(scale)
    sp:setRotation(0)
    local x, y = node:getPosition()
    sp.x, sp.y = x, y
    eff.beginOffset.x, eff.beginOffset.y = 0, 0
    sp:setPosition(x, y)
    sp:setPositionZ(-y)
    local tick = battleTick
    eff.flyType = EEffFlyTypeDISAPPEAR
    eff.value = value
    eff.beginTick = tick
    eff.endTick = tick + 2.25
    eff.followNode = node
    return eff
end

function BattleEffectManager:clear()
    self:reset()
end

function BattleEffectManager:destroy()
    for k, v in pairs(self._bullet) do
        self._bullet[k] = nil
        v.sp:release()
        v.sp = nil
    end
    for k, v in pairs(self._bulletPool) do
        self._bulletPool[k] = nil
        v.sp:release()
        v.sp = nil
    end
    self._rootLayer:removeAllChildren()

    self:unloadBulletRes()
end

function BattleEffectManager:reset()
    self._batchNode:retain()
    self._batchNode2:retain()
    self._rootLayer:removeAllChildren()
    self._rootLayer:addChild(self._batchNode)
    self._rootLayer:addChild(self._batchNode2)
    self._batchNode:release()
    self._batchNode2:release()

    for k, v in pairs(self._bullet) do
        self._bulletPool[k] = v
        self._bullet[k] = nil
    end
    for k, v in pairs(self._bulletPool) do
        v.sp:setVisible(false)
    end
end

function BattleEffectManager.dtor()
    _3dVertex1 = nil
    abs = nil
    atan = nil
    BATTLE_3D_ANGLE = nil
    
    BattleEffectManager = nil
    battleTick = nil
    BC = nil
    cc = nil
    
    cosA = nil
    deg = nil
    dieArtName = nil
    ECamp = nil
    EDirect = nil
    EEffFlyType = nil
    EEffFlyTypeDISAPPEAR = nil
    EEffFlyTypeLINE = nil
    EEffFlyTypePARABOLA = nil
    EEffFlyTypePARABOLA_L = nil
    EEffFlyTypePARABOLA_L_R = nil
    EEffFlyTypePARABOLA_R = nil
    EMotion = nil
    EState = nil
    ETeamState = nil
    floor = nil
    fmod = nil
    math = nil
    MAX_COUNT_POOL = nil
    mcMgr = nil
    next = nil
    os = nil
    pairs = nil
    pc = nil
    runArtName = nil
    sfc = nil
    sinA = nil
    slen = nil
    sqrt = nil
    sub = nil
    tab = nil
    table = nil
    tonumber = nil
    tonumber = nil
    tostring = nil
end

return BattleEffectManager