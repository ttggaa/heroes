--[[
    Filename:    BattleMapLayer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-29 12:51:57
    Description: File description
--]]

-- 此层仅包括地表, 仅供显示
local BC = BC or 
{
    BATTLE_3D_ANGLE = 25,
    MAX_SCENE_WIDTH_PIXEL = 2400,
    MAX_SCENE_HEIGHT_PIXEL = 640,
}
local BattleMapLayer = class("BattleMapLayer")
local _3dVertex1 = cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0)
local fu = cc.FileUtils:getInstance()
function BattleMapLayer:ctor()
    self._rootLayer = cc.Layer:create()
    _3dVertex1 = cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0)
end

function BattleMapLayer:getView()
    return self._rootLayer
end

function BattleMapLayer:getFgLayer()
    return self._fg
end

function BattleMapLayer:getObjLayer()
    return self._objLayer
end

function BattleMapLayer:getFar()
    return self._far
end

function BattleMapLayer:getNear()
    return self._near
end

function BattleMapLayer:generateMap(id, spArray)
    local mapRes = "asset/map/" .. id .. "/" .. id
    local offsetx1 = 0---178
    local offsetx2 = 1022
    local sp1, sp2
--    local spArray = {}

    sp1 = cc.Sprite:create(mapRes.."_land.jpg")
    sp1:setBrightness(0)
    sp1:setEnableCulling(false)
    sp1:setAnchorPoint(0, 0)
    sp1:setPosition(0, 0)
    sp1:setScale(1.25)
    sp1:setVisible(sp1:getContentSize().width > 200)
    self._bg:addChild(sp1)
    spArray[#spArray + 1] = sp1

    sp1 = cc.Sprite:create(mapRes.."_mg.png")
    sp1:setBrightness(0)
    sp1:setScale(1.25)
    sp1:setEnableCulling(false)
    sp1:setAnchorPoint(0.5, 0)
    sp1:setPosition(offsetx1 + 1200, 0)
    sp1:setVisible(sp1:getContentSize().width > 200)
    self._fg:addChild(sp1)
    spArray[#spArray + 1] = sp1

    sp1 = cc.Sprite:create(mapRes.."_far.png")
    sp1:setBrightness(0)
    sp1:setScale(1.25)
    sp1:setVisible(sp1:getContentSize().width > 200)
    sp1:setEnableCulling(false)
    sp1:setPosition(-58 + 1080, 128)
    self._mg:addChild(sp1)
    spArray[#spArray + 1] = sp1

    sp1 = cc.Sprite:create(mapRes.."_bg.jpg")
    sp1:setScale(2)
    sp1:setPosition(960, 128)
    sp1:setVisible(sp1:getContentSize().width > 200)
    self._far:addChild(sp1)
    spArray[#spArray + 1] = sp1

    sp1 = cc.Sprite:create(mapRes.."_fg.png")
    sp1:setBrightness(0)
    sp1:setScale(1.25)
    sp1:setEnableCulling(false)
    sp1:setVisible(sp1:getContentSize().width > 200)
    sp1:setAnchorPoint(0.5, 0)
    sp1:setPosition(offsetx1 + 1200, 0)
    self._near:addChild(sp1)
    spArray[#spArray + 1] = sp1
--    return spArray
end

function BattleMapLayer:initLayer(id, siegeId, mode)
    self._mapId = id
    local mapRes = "asset/map/" .. id .. "/" .. id

--    local spArray = {}

    local offsetx1 = 0---178
    local offsetx2 = 1022
    local sp1, sp2
    self._bg = cc.Node:create()
    self._bg:setPosition(0, 0)
    self._bg:setLocalZOrder(0)
--    sp1 = cc.Sprite:create(mapRes.."_land.jpg")
--    sp1:setBrightness(0)
--    sp1:setEnableCulling(false)
--    sp1:setAnchorPoint(0, 0)
--    sp1:setPosition(0, 0)
--    sp1:setScale(1.25)
--    sp1:setVisible(sp1:getContentSize().width > 200)
--    spArray[#spArray + 1] = sp1
--    self._bg:addChild(sp1)
    -- local hasLand2 = fu:isFileExist(mapRes.."_land_2.jpg")
    -- if hasLand2 then
    --     sp2 = cc.Sprite:create(mapRes.."_land_2.jpg")
    --     sp2:setBrightness(0)
    --     sp2:setEnableCulling(false)
    --     sp2:setPosition(offsetx2, 0)
    --     self._bg:addChild(sp2)
    -- end

    self._fg = cc.Node:create()
--    sp1 = cc.Sprite:create(mapRes.."_mg.png")
--    -- sp2 = cc.Sprite:create(mapRes.."_mg_2.png")
--    sp1:setBrightness(0)
--    sp1:setScale(1.25)
--    -- sp2:setBrightness(0)
--    sp1:setEnableCulling(false)
--    -- sp2:setEnableCulling(false)
--    sp1:setAnchorPoint(0.5, 0)
--    -- sp2:setAnchorPoint(0.5, 0)
--    sp1:setPosition(offsetx1 + 1200, 0)
--    sp1:setVisible(sp1:getContentSize().width > 200)
--    -- sp2:setPosition(offsetx2 + 1200, 0)
--    self._fg:addChild(sp1)
    -- self._fg:addChild(sp2)
    self._fg:setAnchorPoint(0, 0)
    self._fg:setRotation3D(_3dVertex1)
    self._fg:setPosition(0, BC.MAX_SCENE_HEIGHT_PIXEL)
    self._fg:setLocalZOrder(-2)
--    spArray[#spArray + 1] = sp1

    self._mg = cc.Node:create()
--    sp1 = cc.Sprite:create(mapRes.."_far.png")
--    -- sp2 = cc.Sprite:create(mapRes.."_far_2.png")
--    sp1:setBrightness(0)
--    sp1:setScale(1.25)
--    sp1:setVisible(sp1:getContentSize().width > 200)
--    -- sp2:setBrightness(0)
--    sp1:setEnableCulling(false)
--    -- sp2:setEnableCulling(false)
--    sp1:setPosition(-58 + 1080, 128)
--    -- sp2:setPosition(1024 + 1080, 128)
--    self._mg:addChild(sp1)
    -- self._mg:addChild(sp2)
    self._mg:setLocalZOrder(-1)
    self._mg:setAnchorPoint(0, 0)
    self._mg:setPosition(0, 0)
    self._mg.dw = (1 - 0.8) * 1800
--    spArray[#spArray + 1] = sp1

    self._far = cc.Node:create()
--    sp1 = cc.Sprite:create(mapRes.."_bg.jpg")
--    sp1:setScale(2)
--    sp1:setPosition(960, 128)
--    sp1:setVisible(sp1:getContentSize().width > 200)
    self._far:setBrightness(0)
    -- self._far:setEnableCulling(false)
    self._far:setLocalZOrder(-2)
    self._far:setAnchorPoint(0, 0)
    self._far:setPosition(0, 0)
    self._far.dw = (1 - 0.5) * 960
--    self._far:addChild(sp1)

    self._near = cc.Node:create()
    self._near:setAnchorPoint(0, 0)
    self._near:setRotation3D(_3dVertex1)
    self._near:setPosition(0, 0)
    self._near:setLocalZOrder(10)
--    spArray[#spArray + 1] = sp1
--    sp1 = cc.Sprite:create(mapRes.."_fg.png")
--    -- sp2 = cc.Sprite:create(mapRes.."_fg_2.png")
--    sp1:setBrightness(0)
--    sp1:setScale(1.25)
--    -- sp2:setBrightness(0)
--    sp1:setEnableCulling(false)
--    sp1:setVisible(sp1:getContentSize().width > 200)
--    -- sp2:setEnableCulling(false)
--    sp1:setAnchorPoint(0.5, 0)
--    -- sp2:setAnchorPoint(0.5, 0)
--    sp1:setPosition(offsetx1 + 1200, 0)
--    -- sp2:setPosition(offsetx2 + 1200, 0)
--    self._near:addChild(sp1)
--    spArray[#spArray + 1] = sp1
    -- self._near:addChild(sp2)

    self._black = ccui.Layout:create()
    self._black:setLocalZOrder(3)
    self._black:setRotation3D(_3dVertex1)
    self._black:setBackGroundColorOpacity(255)
    self._black:setBackGroundColorType(1)
    self._black:setBackGroundColor(cc.c3b(0,0,0))
    self._black:setContentSize(BC.MAX_SCENE_WIDTH_PIXEL, BC.MAX_SCENE_HEIGHT_PIXEL + 512)
    self._black:setOpacity(0)

    self._rootLayer:addChild(self._bg)
    self._objLayer = cc.Layer:create()
    self._objLayer:setLocalZOrder(5)
    self._rootLayer:addChild(self._fg)
    self._rootLayer:addChild(self._black)
    self._rootLayer:addChild(self._objLayer)
    self._rootLayer:addChild(self._near)
    self._fg:addChild(self._far)
    self._fg:addChild(self._mg)

    -- 场景染色
    -- local pro1 = 40 * 0.01
    -- local pro2 = 1 - pro1
    -- local r, g, b = 185, 218, 255
    -- self._bg:setCM(pro2, pro2, pro2, 1, r * pro1, g * pro1, b * pro1, 0)
    -- self._fg:setCM(pro2, pro2, pro2, 1, r * pro1, g * pro1, b * pro1, 0)
    -- self._near:setCM(pro2, pro2, pro2, 1, r * pro1, g * pro1, b * pro1, 0)

    self.spArray = {}
    self:generateMap(id, self.spArray)

    --技能切换的地图缓存默认隐藏
    self:generateMap(id, self.spArray)

    -- 场景shader
    if mode == BattleUtils.BATTLE_TYPE_Elemental_5 then
        local shader = require ("utils.shader.shader_3")
        for i = 1, #self.spArray do
            if self.spArray[i] then
                self.spArray[i]:setGLProgramState(shader)
                self.spArray[i]:setUseCustomShader(true)
                if i > 5 then
                    self.spArray[i]:setVisible(false)
                end
            end
        end
    else
        for i = 1, #self.spArray do
            if self.spArray[i] then
                if i > 5 then
                    self.spArray[i]:setVisible(false)
                end
            end
        end
    end

    
    self._tiledmap = nil

    if BC.BATTLE_DEBUG_CELL then
        self:initDebugLayer()
    end
    self._blackEnable = false

    local k = MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT
    local kk = (k - 1.775) / (1.333 - 1.775)
    self._siegeBgs = {}
    if siegeId then
        local siegeR_show = BC.siegeR_show

        local MAX_SCENE_WIDTH_PIXEL = BC.MAX_SCENE_WIDTH_PIXEL
        local siegeD = tab.siege[siegeId]
        local siegeBg = cc.Sprite:create("asset/siege/"..siegeD["art"].."/bg.png")
        siegeBg:setLocalZOrder(1)
        siegeBg:setAnchorPoint(siegeR_show and 0 or 1, 0)
        siegeBg:setPosition(siegeR_show and MAX_SCENE_WIDTH_PIXEL - (1605 + 10 * kk) or (1605 + 10 * kk), 31 - 16 * kk)
        siegeBg:setScale(0.4864 + 0.03 * kk, 0.4864 + 0.05 * kk)
        siegeBg:setFlipX(siegeR_show)
        siegeBg:setSkewX(3 * kk)
        siegeBg:setRotation3D(_3dVertex1)
        self._rootLayer:addChild(siegeBg)
        self._siegeBg = siegeBg
        self._siegeBgs[#self._siegeBgs + 1] = siegeBg

        local siegeHalf = cc.Sprite:create("asset/siege/"..siegeD["art"].."/half.png")
        siegeHalf:setLocalZOrder(2)
        siegeHalf:setAnchorPoint(siegeR_show and 0 or 1, 0)
        siegeHalf:setPosition(siegeR_show and MAX_SCENE_WIDTH_PIXEL - (1610 + 10 * kk) or (1610 + 10 * kk), 31 - 16 * kk)
        siegeHalf:setScale(0.4864 + 0.03 * kk, 0.4864 + 0.05 * kk)
        siegeHalf:setFlipX(siegeR_show)
        siegeHalf:setSkewX(3 * kk)
        siegeHalf:setRotation3D(_3dVertex1)
        siegeHalf:setVisible(false)
        self._rootLayer:addChild(siegeHalf)
        self._siegeHalf = siegeHalf
        self._siegeBgs[#self._siegeBgs + 1] = siegeHalf

        local siegeBroken = cc.Sprite:create("asset/siege/"..siegeD["art"].."/broken.png")
        siegeBroken:setLocalZOrder(3)
        siegeBroken:setAnchorPoint(siegeR_show and 0 or 1, 0)
        siegeBroken:setPosition(siegeR_show and MAX_SCENE_WIDTH_PIXEL - (1610 + 10 * kk) or (1610 + 10 * kk), 31 - 16 * kk)
        siegeBroken:setScale(0.4864 + 0.03 * kk, 0.4864 + 0.05 * kk)
        siegeBroken:setFlipX(siegeR_show)
        siegeBroken:setSkewX(3 * kk)
        siegeBroken:setRotation3D(_3dVertex1)
        siegeBroken:setVisible(false)
        self._rootLayer:addChild(siegeBroken)
        self._siegeBroken = siegeBroken
        self._siegeBgs[#self._siegeBgs + 1] = siegeBroken
    end
end

--替换场景资源(upMapId 需要替换的地图 bisCreate 是否常见)
local resTable = {"_land.jpg", "_mg.png", "_far.png", "_bg.jpg", "_fg.png"}
function BattleMapLayer:setMapSceneRes(upMapId, lowMapId, bisCreate, objLayer, bIsAnim)
    --self._mapId
    
    local lowSwitch = true
    if upMapId == nil then
        upMapId = self._mapId
    end
    
    if lowMapId == nil then
        lowMapId = self._mapId
    end

--    print("++++++++++++++++++++1111111111111", upMapId, self._berMapId , self._lowMapId , lowMapId, bisCreate, BC.logic.battleFrameCount)

    if self._berMapId == upMapId then
        return
    end
    self._berMapId = upMapId

    if self._lowMapId == lowMapId then
        lowSwitch = false
    end
    self._lowMapId = lowMapId
    if bisCreate then
        local function callbackEnd()
            
        end
        local curRes = "asset/map/" .. upMapId .. "/" .. upMapId
        local lowRes = "asset/map/" .. lowMapId .. "/" .. lowMapId
        if lowSwitch then
            for i = 1, 5 do
                if self.spArray[i] then
                    self.spArray[i]:setTexture(lowRes .. resTable[i])
                end
            end
        end
        
        for i = 1, #self.spArray do
            if self.spArray[i] then
                if i >= 6 then
                    self.spArray[i]:setTexture(curRes .. resTable[i - 5])
                    self.spArray[i]:setVisible(true)
                    self.spArray[i]:setOpacity(0)
                else
                    self.spArray[i]:setOpacity(255)
                    self.spArray[i]:setVisible(true)
                end
            end
        end
        ScheduleMgr:delayCall(BC.frameInv * 5 * 1000 / 2--[[BC.BATTLE_SPEED]] , self, function()
                for i = 1, #self.spArray do
                    if self.spArray[i] then
                        if i >= 6 then
                            self.spArray[i]:stopAllActions()
                            self.spArray[i]:runAction(cc.FadeIn:create(0.8))
                        else
                            self.spArray[i]:stopAllActions()
                            self.spArray[i]:runAction(cc.Sequence:create(
                                    cc.FadeOut:create(0.8),
                                    cc.Hide:create()    
                                ))
                        end
                    end
                end
            end
        )
    else
--        print(debug.traceback())
        local lowRes = "asset/map/" .. lowMapId .. "/" .. lowMapId
        local upRes = "asset/map/" .. self._berMapId .. "/" .. self._berMapId
        if lowSwitch then
            for i = 1, 5 do
                if self.spArray[i] then
                    self.spArray[i]:setTexture(lowRes .. resTable[i])
                end
            end
        end

        if bIsAnim then
            ScheduleMgr:delayCall(0 , self, function()
                    for i = 1, #self.spArray do
                        if self.spArray[i] then
                            if i >= 6 then
                                self.spArray[i]:setTexture(upRes .. resTable[i - 5])
                                self.spArray[i]:setOpacity(255)
                                self.spArray[i]:setVisible(true)
                                self.spArray[i]:stopAllActions()
                                self.spArray[i]:runAction(cc.Sequence:create(
                                    cc.FadeOut:create(0.8),
                                    cc.Hide:create()    
                                ))
                            else
                                self.spArray[i]:stopAllActions()
                                self.spArray[i]:setOpacity(255)
                                self.spArray[i]:setVisible(true)
--                                self.spArray[i]:runAction(cc.FadeIn:create(0.8))
                            end
                        end
                    end
                end
            )
        end
    end
end

function BattleMapLayer:siegeHalf()
    self._siegeHalf:setVisible(true)
end

function BattleMapLayer:siegeBroken()
    self._siegeBroken:setVisible(true)
end

function BattleMapLayer:siegeReset()
    if self._siegeHalf then self._siegeHalf:setVisible(false) end
    if self._siegeBroken then self._siegeBroken:setVisible(false) end
end

function BattleMapLayer:getSiegeLayer()
    return self._siegeBg
end

-- 人物层下面的黑底
function BattleMapLayer:enableBlack()
    -- self._blackEnable = true
    -- self._black:stopAllActions()
    -- self._black:runAction(cc.FadeTo:create(0.2, 128))
    -- for i = 1, #self._siegeBgs do
    --     self._siegeBgs[i]:setBrightness(-75)
    -- end
end

function BattleMapLayer:disableBlack(noAnim)
    -- self._blackEnable = false
    -- self._black:stopAllActions()
    -- if not noAnim then
    --     self._black:runAction(cc.FadeOut:create(0.2))
    -- else
    --     self._black:setOpacity(0)
    -- end
    -- for i = 1, #self._siegeBgs do
    --     self._siegeBgs[i]:setBrightness(0)
    -- end
end

function BattleMapLayer:fadeOutBlack()
    -- self._blackEnable = false
    -- self._black:setOpacity(200)
    -- self._black:runAction(cc.FadeOut:create(0.2))
    -- for i = 1, #self._siegeBgs do
    --     self._siegeBgs[i]:setBrightness(0)
    -- end
end

function BattleMapLayer:update()
    local sceneLayer = self._rootLayer:getParent()
    local dx = (sceneLayer:getScaleX() - 1.0) * 0.5 * MAX_SCREEN_WIDTH
    local dy = (sceneLayer:getScaleY() - 1.0) * 0.5 * MAX_SCREEN_HEIGHT

    local ddx
    local _x = math.sin(math.rad(BC.BATTLE_3D_ANGLE + 1)) * BC.MAX_SCENE_HEIGHT_PIXEL / 2
    ddx = _x * sceneLayer:getScaleX()

    local minX = (MAX_SCREEN_WIDTH - BC.MAX_SCENE_WIDTH_PIXEL) * sceneLayer:getScaleX() - dx + ddx
    local maxX = 0 + dx - ddx

    local pro = 1 - (sceneLayer:getPositionX() - minX) / (maxX - minX)
    self._far:setPositionX(pro * self._far.dw)
    self._mg:setPositionX(pro * self._mg.dw)
end

function BattleMapLayer:clear()
    self._rootLayer:removeAllChildren()
    self._rootLayer:removeFromParent()
    self._rootLayer = nil
end

function BattleMapLayer:initDebugLayer()
    -- debug 格子
    local _x = 0
    local _y = 0
    if BC.BATTLE_DEBUG_CELL then
        self._debugLayer1 = cc.Node:create()
        self._rootLayer:addChild(self._debugLayer1)
        self._debugLayer1:setOpacity(128)
        self._debugLayer1:setCascadeOpacityEnabled(true) 
        for x = 1, BC.MAX_CELL_WIDTH do
            for y = 1, BC.MAX_CELL_HEIGHT do
                _x, _y = BC.getScenePosByCell(x, y)
                local cell = cc.Sprite:create("asset/other/cell2.png")
                cell:setColor(cc.c3b(0, 255, 255))
                cell:setAnchorPoint(0.5, 0.5)
                cell:setScale(0.5)
                self._debugLayer1:addChild(cell)
                cell:setPosition(_x, _y)
            end
        end
    end
end

---显示定义的格子(调试使用)
function BattleMapLayer:showSquare(cellSize)
    local createDebugLayer1 = function(_cellSize)
        local _debugLayer1 = cc.Node:create()
        self._rootLayer:addChild(_debugLayer1)
        _debugLayer1:setCascadeOpacityEnabled(true) 
        local _BATTLE_CELL_SIZE = _cellSize or BC.BATTLE_CELL_SIZE
        _debugLayer1.cellSize = BC.BATTLE_CELL_SIZE
        _debugLayer1:setName("test_debugLayer1")
        -- 格子总数量
        local _MAX_CELL_WIDTH = BC.MAX_SCENE_WIDTH_PIXEL / _BATTLE_CELL_SIZE
        local _MAX_CELL_HEIGHT = BC.MAX_SCENE_HEIGHT_PIXEL / _BATTLE_CELL_SIZE
        for x = 1, _MAX_CELL_HEIGHT do
            local _drawNode = cc.DrawNode:create()
            _drawNode:drawSegment(cc.p(0, x * _BATTLE_CELL_SIZE), cc.p(BC.MAX_SCENE_WIDTH_PIXEL, x * _BATTLE_CELL_SIZE), 1, cc.c4f(0, 0, 1, 1))
            _debugLayer1:addChild(_drawNode)
        end
        for y = 1, _MAX_CELL_WIDTH do
            local _drawNode = cc.DrawNode:create()
            _drawNode:drawSegment(cc.p(y * _BATTLE_CELL_SIZE, 0), cc.p(y * _BATTLE_CELL_SIZE, BC.MAX_SCENE_HEIGHT_PIXEL), 1, cc.c4f(0, 0, 1, 1))
            _debugLayer1:addChild(_drawNode)
        end
    end
    local _debugLayer1 = nil
    if self._rootLayer then
        _debugLayer1 = self._rootLayer:getChildByName("test_debugLayer1")
    end
    if not _debugLayer1 then
        createDebugLayer1(cellSize)
    else
        local bVisible = _debugLayer1:isVisible()
        if not bVisible then
            if cellSize and cellSize ~= _debugLayer1.cellSize then
                self._rootLayer:removeChild(_debugLayer1, true)
                _debugLayer1 = nil
                createDebugLayer1(cellSize)
            end
        else
            _debugLayer1:setVisible(false)
        end
        
    end
end

function BattleMapLayer.dtor()
    BC = nil
    _3dVertex1 = nil
    BattleMapLayer = nil
    fu = nil
    resTable = nil
end

return BattleMapLayer
