--[[
 	@FileName 	BattleArrayLayer.lua
	@Authors 	yuxiaojing
	@Date    	2018-07-13 14:37:17
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local cc = cc
local GlobalScrollLayer = require "game.view.global.GlobalScrollLayer"
local BattleArrayLayer = class("BattleArrayLayer", GlobalScrollLayer)

local LAYER_WIDHT = 2000        -- 可滑动显示宽
local LAYER_HEIGHT = 1300       -- 可滑动显示高
local MAP_WIDTH = 960           -- 阵图ui宽
local MAP_HEIGHT = 640          -- 阵图ui高
local TIP_INFO_WIDHT = 370      -- 右侧信息栏宽

function BattleArrayLayer:ctor(switchCallback, parentView)
	BattleArrayLayer.super.ctor(self)

	self._parentView = parentView
	self:initBigMap()
	self:initMapView()
end

function BattleArrayLayer:initBigMap(  )
	-- if self._bgLayer ~= nil then self._bgLayer:removeFromParent() self._bgLayer = nil end
 --    cc.Texture2D:setDefaultAlphaPixelFormat(RGB565)
 --    self._bgLayer = cc.Sprite:create()
 --    self._bgLayer:setName("bgLayer")
 --    self._sceneLayer:addChild(self._bgLayer)
 --    self._bgLayer:setTexture("asset/uiother/starCharts/starCharts_bg.jpg")
 --    self._bgLayer:setPosition(0, 0)
 --    self._bgLayer:setAnchorPoint(0, 0)
 --    self._bgLayer:setScale(1.3)
 --    cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)
end

function BattleArrayLayer:initMapView(  )
	self._map = self._parentView:createLayer("battleArray.BattleArrayMap", {baLayer = self})
	self._map:setPosition((LAYER_WIDHT - MAP_WIDTH - TIP_INFO_WIDHT) / 2, (LAYER_HEIGHT - MAP_HEIGHT) / 2)
    self._sceneLayer:addChild(self._map, 1)

    -- local bgMC = mcMgr:createViewMC("beijing_yangchengjiemian-HD", true, false)
    -- bgMC:setPosition((LAYER_WIDHT - TIP_INFO_WIDHT) / 2 + 200, (LAYER_HEIGHT) / 2)
    -- self._sceneLayer:addChild(bgMC, -2)

    self:screenToPos(self._map:getPositionX() + MAP_WIDTH / 2 + TIP_INFO_WIDHT / 2, self._map:getPositionY() + MAP_HEIGHT / 2, false, nil, nil, nil, 0.3)
end

function BattleArrayLayer:onExit()
    BattleArrayLayer.super.onExit(self)
    setMultipleTouchDisabled()
end

function BattleArrayLayer:onHide()
    setMultipleTouchDisabled()
end

function BattleArrayLayer:onTop()
    setMultipleTouchEnabled()
end

function BattleArrayLayer:onEnter()
    BattleArrayLayer.super.onEnter(self)
    setMultipleTouchEnabled()
end

function BattleArrayLayer:getMaxScrollHeightPixel(inScale)
    return LAYER_HEIGHT
end

function BattleArrayLayer:getMaxScrollWidthPixel(inScale)
    return LAYER_WIDHT
end

function BattleArrayLayer:getMinScale()
    return 0.75
end

function BattleArrayLayer:getMaxScale()
    return 1.25
end

function BattleArrayLayer.dtor()
    cc = nil
end

return BattleArrayLayer