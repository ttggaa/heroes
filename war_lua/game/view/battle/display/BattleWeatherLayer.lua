--[[
    Filename:    BattleWeatherLayer.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2014-12-29 12:52:54
    Description: File description
--]]

local BattleWeatherLayer = class("BattleWeatherLayer")

function BattleWeatherLayer:ctor()
    self._rootLayer = cc.Layer:create()
    self._rootLayer:setRotation3D(cc.Vertex3F(BC.BATTLE_3D_ANGLE, 0, 0))
    self._rootLayer:setLocalZOrder(5000)
end

function BattleWeatherLayer:getView()
    return self._rootLayer
end

function BattleWeatherLayer:clear()
    self._rootLayer = nil
end

function BattleWeatherLayer:initLayer(mapId)
    local battleWeather = SystemUtils.loadGlobalLocalData("battleWeather")
    if battleWeather ~= 1 then return end
    local weatherRes = BattleUtils.weatherTab[mapId]
    if weatherRes then
        if weatherRes == "xiayu" then
            if GRandom(5) ~= 5 then
                return
            end
        end
        local mc = mcMgr:createViewMC(weatherRes .. "_" .. weatherRes, true, false)
        mc:setPosition(1200, 420)
        self._rootLayer:addChild(mc)
        return true
    end
end

function BattleWeatherLayer:changeWeather(weather)
    local battleWeather = SystemUtils.loadGlobalLocalData("battleWeather")
    -- if battleWeather ~= 1 then return end
    self._rootLayer:removeAllChildren()
    local mc = mcMgr:createViewMC(weather .. "_" .. weather, true, false)
    mc:setPosition(1200, 420)
    self._rootLayer:addChild(mc)
    return true
end

function BattleWeatherLayer:closeWeather()
    if self._rootLayer == nil then return end
    self._rootLayer:removeAllChildren()
    SystemUtils.saveGlobalLocalData("battleWeather", 0)
end

function BattleWeatherLayer.dtor()
    BattleWeatherLayer = nil
end


return BattleWeatherLayer