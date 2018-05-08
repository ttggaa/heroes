--[[
    Filename:    BattleWeapon.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-10-12 15:36:23
    Description: File description
--]]
local BC = BC
local table = table
local BattleWeapon = class("BattleWeapon")

local BATTLE_3D_ANGLE = BC.BATTLE_3D_ANGLE
local _3dVertex1 = cc.Vertex3F(BATTLE_3D_ANGLE, 0, 0)
local _3dVertex2 = cc.Vertex3F(-BATTLE_3D_ANGLE, 0, 0)
local ceil = math.ceil

local super = BattleWeapon.super

function BattleWeapon:ctor(objLayer, weaponData, index, camp)
    BATTLE_3D_ANGLE = BC.BATTLE_3D_ANGLE
    _3dVertex1 = cc.Vertex3F(BATTLE_3D_ANGLE, 0, 0)
    _3dVertex2 = cc.Vertex3F(-BATTLE_3D_ANGLE, 0, 0)
    self._layer = objLayer:getView()
    self._camp = camp
    self._index = index

    if not BATTLE_PROC then
        local weaponD = tab.siegeWeapon[weaponData.id]
        self:initSprite(weaponD["steam"])
    end
end

local MOTION_IDLE = "stop"
local MOTION_RUN = "run2"
local MOTION_WALK = "run"
local MOTION_CAST = "atk1"
local MOTION_WIN = "win"
local MOTION_ATK = "atk"
function BattleWeapon:setScale(scale)
    if not self._sp.visible then return end
    self._sp:setScale(scale)
end

function BattleWeapon:setVisible(visible)
    self._sp:setVisible(visible)
    self._sp.visible = visible
end

function BattleWeapon:initSprite(heroart)
    local mainCamp = BC.reverse and 2 or 1

    if heroart == nil then return end
    self._node = cc.Node:create()
    self._node:setAnchorPoint(0.5, 0.5)
    self._node:setRotation3D(_3dVertex1)
    HeroAnim.new(self._node, heroart, {MOTION_IDLE, MOTION_ATK, MOTION_CAST}, function (sp)
        self._sp = sp
        self._sp:setScale(0.2)
        self._sp:setScaleX(-0.2)
        self._sp:changeMotion(MOTION_IDLE, BC.BATTLE_DISPLAY_TICK)
        self._sp:setLocalZOrder(5)
    end, false, nil, nil, true)
    self._layer:addChild(self._node)
    local ttt = {3, 1, 2}
    if self._camp == mainCamp then
        self:setPos(24 * 40 - ttt[self._index] * 150, 15 * 40)
        self._node:setScaleX(-1)
    else
        self:setPos(37 * 40 + ttt[self._index] * 150, 15 * 40)
    end
end

local red = cc.c3b(162, 13, 20)
local blue = cc.c3b(0, 107, 189)
local black = cc.c4b(0, 0, 0, 255)
local brown = cc.c3b(70, 40, 10)
function BattleWeapon:showSkillName(name)
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

function BattleWeapon:onChat(msg, clear, color)
    if not self._sp.visible then return end
    self._chatType = 2
    self:_onChat(msg, clear, color)
end

function BattleWeapon:_onChat(msg, clear, color)
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

function BattleWeapon:update(tick)

end

function BattleWeapon:displayUpdate(tick)
    if self._sp then
        self._sp:update(tick)
    end
end

function BattleWeapon:clear()
    if self._node then
        self._node:removeFromParent()
        self._node = nil
        self._sp = nil
    end
end

function BattleWeapon:Cast()
    if self._sp == nil then return end
    local nowMotion = self._sp:getMotion()
    if nowMotion == MOTION_ATK or nowMotion == MOTION_CAST then return end
    self._sp:changeMotion(MOTION_ATK, BC.BATTLE_DISPLAY_TICK, function ()
        self:onStop()
    end, true, nil, 8)
    self._sp:changeMotion(MOTION_CAST, BC.BATTLE_DISPLAY_TICK, function ()
        self:onStop()
    end, true, nil, 8)
end

function BattleWeapon:onStop()
    if self._sp == nil then return end
    self._sp:changeMotion(MOTION_IDLE, BC.BATTLE_DISPLAY_TICK)
end

function BattleWeapon:pause()
    if self._sp == nil then return end
    self._sp:pause()
end

function BattleWeapon:resume()
    if self._sp == nil then return end
    self._sp:resume()
end

function BattleWeapon:setPos(x, y)
    self.x, self.y = x, y
    if self._node == nil then return end
    self._node:setPosition(x, y)
    self._node:setLocalZOrder(-y)
end

function BattleWeapon.dtor()
    _3dVertex1 = nil
    _3dVertex2 = nil
    BATTLE_3D_ANGLE = nil
    BC = nil
    black = nil
    ceil = nil
    MOTION_CAST = nil
    MOTION_IDLE = nil
    MOTION_RUN = nil
    MOTION_WALK = nil
    MOTION_WIN = nil
    red = nil
    table = nil
    super = nil
end

return BattleWeapon