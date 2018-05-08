--[[
    Filename:    CityBattleWorldLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-11-26 10:30:26
    Description: File description
--]]

local GlobalScrollLayer = require "game.view.global.GlobalScrollLayer"

local CityBattleWorldLayer = class("CityBattleWorldLayer", GlobalScrollLayer)


local areaMaskColor = {cc.c4b(250, 24, 24, 255), cc.c4b(0, 16, 249, 255), cc.c4b(127, 223, 35, 255), cc.c4b(255, 255, 255, 255)}

local cityStateColor = {cc.c4b(255, 58, 51, 255), cc.c4b(130, 183, 255, 255), cc.c4b(127, 223, 35, 255), cc.c4b(255, 255, 255, 255)}

local nameColor = {cc.c4b(227, 93, 80, 255), cc.c4b(131, 166, 255, 255), cc.c4b(127, 223, 35, 255), cc.c4b(255, 255, 255, 255)}


local occupyColorPlan  
local serverNum 
local realSec

local cityPointImg = {["15"]=1,["3"]=2,["1"]=3}

function CityBattleWorldLayer:ctor(inParent)
    CityBattleWorldLayer.super.ctor(self)

    self._parentView = inParent
    self._userModel = self._modelMgr:getModel("UserModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            CityBattleWorldLayer.super.onExit(self)
            UIUtils:reloadLuaFile("citybattle.CityBattleWorldLayer")
            if OS_IS_WINDOWS then
                package.loaded["game.view.citybattle.CityBattleWorldListen"] = nil 
                package.loaded["game.view.citybattle.GlobalScrollLayer"] = nil    
                package.loaded["game.view.guild.map.ProgressNode"] = nil     
                
            end  
             
        elseif eventType == "enter" then 
            CityBattleWorldLayer.super.onEnter(self)
        end
    end)
    self._touchesMovedEx = true
    require("game.view.citybattle.CityBattleWorldListen")

    --检测消息丢失
    self._messageLoseCheckList = {}
    self._sec = self._cityBattleModel:getMineSec()
    realSec = self._cityBattleModel:getMineSec()
end

function CityBattleWorldLayer:onTop()
    setMultipleTouchEnabled()
end

function CityBattleWorldLayer:onHide()
    setMultipleTouchDisabled()
end

--[[
--! @function loadBigMap
--! @desc 加载大地图
--! @return 
--]]
function CityBattleWorldLayer:loadBigMap()
    self._miniIconInCity = {}


    self._cityFallTips = {}

    self._formationWithIndex = {}

    self._cityServerData = self._cityBattleModel:getCityServerList()
    for i=1,4 do
        local fid = self._formationModel["kFormationTypeCityBattle" .. i]
        self._formationWithIndex[fid] = i
    end
    self._selectedCityId = 0
    self._battleState, weekday, self._timeType = self._cityBattleModel:getState()
    self._usingIcon = {}
    occupyColorPlan = self._cityBattleModel:getData().c.co
    if self._bgLayer ~= nil then self._bgLayer:removeFromParent() self._bgLayer = nil end
    cc.Texture2D:setDefaultAlphaPixelFormat(RGB565)
    self._bgLayer = cc.Sprite:create()
    self._bgLayer:setName("bgLayer")
    self._sceneLayer:addChild(self._bgLayer)
    self._bgLayer:setTexture("asset/uiother/map/chaodaditu.jpg")
    self._bgLayer:setPosition(self._bgLayer:getContentSize().width/2, self._bgLayer:getContentSize().height/2)
    self._bgLayer:setAnchorPoint(0.5, 0.5)
    self._bgLayer:setScale(self:getInitScale())
    cc.Texture2D:setDefaultAlphaPixelFormat(RGBAUTO)


    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 120))
    layer:setContentSize(self._bgLayer:getContentSize().width, self._bgLayer:getContentSize().height)
    layer:setPosition(self._bgLayer:getContentSize().width/2, self._bgLayer:getContentSize().height/2)
    layer:setPosition(0, 0)
    self._bgLayer:addChild(layer)


    local mapMask = cc.Sprite:createWithSpriteFrameName("citybattle_map_mask.png")
    mapMask:setPosition(self._bgLayer:getContentSize().width/2  - 142, self._bgLayer:getContentSize().height/2 - 52)
    mapMask:setScale(1.666667)
    mapMask:setOpacity(100)
    self._bgLayer:addChild(mapMask, 3)


    self._selectBgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    self._selectBgLayer:setContentSize(self._bgLayer:getContentSize().width, self._bgLayer:getContentSize().height)
    self._selectBgLayer:setVisible(false)
    self._selectBgLayer:setAnchorPoint(0, 0)
    self._selectBgLayer:setPosition(cc.p(0, 0))
    self._bgLayer:addChild(self._selectBgLayer, 100)

    serverNum = table.nums(occupyColorPlan)


    local cityInfos = self._cityBattleModel:getData().c.c
    for k,v in pairs(tab.cityBattleMap) do
        local sysCityBattle = tab:CityBattle(v.id)
        local cityInfo = cityInfos[tostring(v.id)]

        local cityIcon = ccui.ImageView:create("citybattle_map_0" .. sysCityBattle["type"] .. sysCityBattle["citylv" .. serverNum] .. ".png", 1)
        -- self.adImg:addChild(cityIcon)
        -- local cityIcon = cc.Sprite:createWithSpriteFrameName("citybattle_map_city" .. v.cityart .. ".png")
        local cityIconBg = ccui.Widget:create()

        cityIconBg:setContentSize(cc.size(cityIcon:getContentSize().width * cityIcon:getScaleX(), cityIcon:getContentSize().height* cityIcon:getScaleX()))
        cityIconBg.cityIcon = cityIcon
        cityIcon:setPosition(cityIcon:getContentSize().width * 0.5, cityIcon:getContentSize().height * 0.5)
        cityIconBg:addChild(cityIcon, 4)
        
        cityIconBg:setName("cityIconBg" .. v.id)
        cityIconBg:setPosition(v.citypoint[1], v.citypoint[2])
        self._bgLayer:addChild(cityIconBg, 4)  
        self:registerTouchEventWithLight(cityIcon, nil)

        registerTouchEvent(cityIconBg, nil, nil, function()
            self:touchEventIcon(v.id)
        end)
        cityIconBg:setTouchEnabled(false)
        table.insert(self._usingIcon, cityIconBg)

        if CityBattleConst.SHOW_CITY_ID then
            local memLabel = cc.Label:createWithTTF(v.id, UIUtils.ttfName, 20)
            memLabel:setPosition(cityIconBg:getContentSize().width/2 , cityIconBg:getContentSize().height/2 )
            memLabel:setAnchorPoint(0.5, 0.5)
            memLabel:setColor(cc.c3b(255, 255, 255))
            memLabel:enableOutline(cc.c4b(0,0,0,255), 1)
            cityIconBg:addChild(memLabel, 10)
        end
        -- 特权图标处理

        if sysCityBattle["citypvl" .. serverNum] then
            local citypvl = cc.Sprite:createWithSpriteFrameName("citybattle_prev_1.png")
            citypvl:setAnchorPoint(0, 0.5)
            citypvl:setPosition(cityIconBg:getContentSize().width, cityIconBg:getContentSize().height * 0.5 + 5)
            cityIconBg:addChild(citypvl)
        end
        local occupyColor = occupyColorPlan[cityInfo.b] or 4
        local nameLab = cc.Label:createWithTTF(lang(sysCityBattle.name), UIUtils.ttfName, 16)
        
        nameLab:setAnchorPoint(0.5, 0.5)
        nameLab:setColor(nameColor[occupyColor])
        cityIconBg.nameLab = nameLab

        local nameBg = cc.Scale9Sprite:createWithSpriteFrameName("citybattle_view_namebg.png")
        nameBg:setContentSize(nameLab:getContentSize().width + 30, 25)
        nameBg:setAnchorPoint(0.5, 1)
        nameBg:setPosition(cityIconBg:getContentSize().width * 0.5, 8)
        cityIconBg:addChild(nameBg, 5)
        nameBg:setCapInsets(cc.rect(15, 0, 1, 1))

        nameLab:setPosition(nameBg:getContentSize().width * 0.5 , nameBg:getContentSize().height * 0.5 -2)
        nameBg:addChild(nameLab)
    end
    print("resetBigMap=========================================================")
    self:resetBigMap()
    self:screenToPos(self:getMaxScrollWidthPixel() * 0.5, self:getMaxScrollHeightPixel() * 0.5, false)

end


function CityBattleWorldLayer:updateAreaState(inCityBattleMap, inCityInfos)
    local cbId = inCityBattleMap.id
    local cityInfo = inCityInfos[tostring(cbId)]
    if cityInfo == nil then return end

    local sysCityBattle = tab.cityBattle[cbId]
    local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. cbId)
    
    local occupyColor = occupyColorPlan[cityInfo.b] or 4
    local areaMask = self._bgLayer:getChildByName("mask_" .. cbId)
    -- npc 处理
    if cityInfo.b == "npc" then
        if areaMask ~= nil then 
            areaMask:removeFromParent()
            areaMask = nil
        end
    else
        if areaMask == nil then 
            areaMask = cc.Sprite:createWithSpriteFrameName("citybattle_map_bg_" .. cbId .. ".png")
            areaMask:setPosition(inCityBattleMap.terrainpoint[1], inCityBattleMap.terrainpoint[2])
            areaMask:setName("mask_" .. cbId)
            areaMask:setScale(2)
            -- areaMask:setColor(areaMaskColor[randColor])
            self._bgLayer:addChild(areaMask, 2)
            areaMask:setOpacity(100)
        end
        areaMask:setColor(areaMaskColor[occupyColor])

        local tempAreaMask = self._bgLayer:getChildByName("remove_mask_" .. cbId)
        if tempAreaMask ~= nil then
            tempAreaMask:removeFromParent()
            areaMask:setOpacity(255)
            areaMask:setLocalZOrder(10000)
        end
    end
    local selectedIcon = self._selectBgLayer:getChildByName("selectedIcon" .. cbId)
    if selectedIcon ~= nil then 
        selectedIcon:setColor(areaMaskColor[occupyColor])
        if occupyColor ~= 4 then
            selectedIcon:setBrightness(50)
        end
    end

    if cityIconBg.nameLab ~= nil then
        cityIconBg.nameLab:setColor(nameColor[occupyColor])
    end
    
    -- 旗子
    if cityIconBg.flagSp ~= nil then 
        cityIconBg.flagSp:setVisible(false)
    end
    -- npc不显示进度条
    if occupyColor == 4 then 
        if cityIconBg.progressNode ~= nil then 
            cityIconBg.progressNode:setVisible(false)
        end
    else
        if cityIconBg.occupyColor ~= occupyColor then 
            if cityIconBg.progressNode ~= nil then
                cityIconBg.progressNode:removeFromParent()
                cityIconBg.progressNode = nil
            end
        end
        if cityIconBg.progressNode == nil then 
            local param = {}
            param.style = 2 
            param.type = occupyColor
            local progressNode = require("game.view.guild.map.ProgressNode").new(param)
            progressNode:setAnchorPoint(0.5, 0)
            progressNode:setPosition(cityIconBg:getContentSize().width * 0.5 , -progressNode:getContentSize().height - 18)
            cityIconBg:addChild(progressNode)
            cityIconBg.progressNode = progressNode
        end
        cityIconBg.occupyColor = occupyColor
        -- cityIconBg.progressNode:updateType(occupyColor)
        cityIconBg.progressNode:setVisible(true)
        local maxHp = sysCityBattle["cityhp" .. serverNum]
        cityIconBg.progressNode:updateProgress(cityInfo.bl / maxHp * 100)

        -- 旗子标记
        if cityIconBg.flagSp == nil then 
            local flagSp = cc.Sprite:createWithSpriteFrameName("citybattle_view_occupy" .. occupyColor .. ".png")
            flagSp:setPosition(1, 0)
            flagSp:setPosition(cityIconBg:getContentSize().width + 10, cityIconBg:getContentSize().width * 0.5 )
            cityIconBg:addChild(flagSp, 5)
            cityIconBg.flagSp = flagSp
            cityIconBg.flagSp:setVisible(false)
        end
        if cityInfo.b == tostring(realSec) then 
            cityIconBg.flagSp:setSpriteFrame("citybattle_view_occupy" .. occupyColor .. ".png")
            cityIconBg.flagSp:setVisible(true)
        end

    end
    if self._battleState == 0 or self._battleState == 2 then 
        if cityIconBg.progressNode ~= nil then
            cityIconBg.progressNode:setVisible(false)
        end
    end    
    -- if cityIconBg.selfMc ~= nil then 
    --     cityIconBg.selfMc:setVisible(false)
    -- end
    -- 可以进攻
    if cityIconBg.canBattleMc1 ~= nil then 
        cityIconBg.canBattleMc1:setVisible(false)
    end    

    -- 多方进攻
    if cityIconBg.siegeMc ~= nil then 
        cityIconBg.siegeMc:setVisible(false)
    end

    -- 废墟锤子动画
    if cityIconBg.discardSp ~= nil then 
        cityIconBg.discardSp:removeFromParent()
        cityIconBg.discardSp = nil
    end

    -- 正在战斗
    if cityIconBg.battlingMc ~= nil then 
        cityIconBg.battlingMc:removeFromParent()
        cityIconBg.battlingMc = nil
    end

    if serverNum ~= cityIconBg.cityIcon.serverNum then
        cityIconBg.cityIcon:loadTexture("citybattle_map_0" .. sysCityBattle["type"] .. sysCityBattle["citylv" .. serverNum] .. ".png", 1)
    end

    cityIconBg.cityIcon:setVisible(true)

    if self._battleState == 1 then
        if (cityInfo.isBattle ~= nil and cityInfo.isBattle == true ) then 
            local battlingMc = mcMgr:createViewMC("zhandou_citybattlechengchidianji", true)
            battlingMc:setPosition(cityIconBg:getContentSize().width * 0.5 , cityIconBg:getContentSize().height)
            cityIconBg:addChild(battlingMc, 5)
            cityIconBg.battlingMc = battlingMc
        end
        -- 废墟恢复中
        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
        if cityInfo.t ~= nil and cityInfo.t > curTime then
            local discardSp = cc.Sprite:createWithSpriteFrameName("citybattle_map_00" .. sysCityBattle["citylv" .. serverNum] .. ".png")
            discardSp:setAnchorPoint(0.5, 0)
            discardSp:setPosition(cityIconBg:getContentSize().width * 0.5, 0)
            cityIconBg:addChild(discardSp)
            cityIconBg.discardSp = discardSp   

            discardSp:runAction(cc.Sequence:create(
                cc.DelayTime:create(cityInfo.t - curTime),
                cc.CallFunc:create(
                    function()
                        discardSp.hammerMc:removeFromParent()
                        discardSp.hammerMc = nil

                        local guangMc = mcMgr:createViewMC("chengchihuifu_citybattlechengchidianji", true)
                        guangMc:setPosition(discardSp:getContentSize().width * 0.5 + 20, discardSp:getContentSize().height * 0.5 + 30)
                        discardSp:addChild(guangMc)
                        discardSp.guangMc = guangMc    
                    end                
                    ),
                cc.DelayTime:create(0.5),
                cc.CallFunc:create(
                    function()
                        cityIconBg.isRunFallTip = false
                        self:updateAreaState(inCityBattleMap, inCityInfos)
                    end)
            ))
            local hammerMc = mcMgr:createViewMC("chengchihuifuchuizi_citybattlechengchidianji", true)
            hammerMc:setPosition(discardSp:getContentSize().width * 0.5 + 20, discardSp:getContentSize().height * 0.5 + 30)
            discardSp:addChild(hammerMc)
            discardSp.hammerMc = hammerMc

            cityIconBg.cityIcon:setVisible(false)
        else

            local manCity = tab:Setting("G_CITYBATTLE_START_" .. serverNum).value
            local isMain = table.indexof(manCity, sysCityBattle.id)
            if isMain == false and (self._timeType == "s3" or self._timeType == "s5") then
                -- 判断如果周围已经都是敌方的时候做出提示
                local count = 0
                for k1,v1 in pairs(sysCityBattle.nearby) do
                    if inCityInfos[tostring(v1)].b == inCityInfos[tostring(sysCityBattle.id)].b then 
                        break
                    end
                    count = count + 1
                end
                -- count = #sysCityBattle.nearby
                if count == #sysCityBattle.nearby then 
                    if cityIconBg.siegeMc == nil then
                        local siegeMc = mcMgr:createViewMC("jingong_citybattlechengchidianji", true)
                        siegeMc:setPosition(cityIconBg:getContentSize().width * 0.5 + 5, cityIconBg:getContentSize().height * 0.5)
                        cityIconBg:addChild(siegeMc, 10)
                        cityIconBg.siegeMc = siegeMc
                    end
                    cityIconBg.siegeMc:setVisible(true)        
                end
            end
        end

    end
end


function CityBattleWorldLayer:activeCanBattleTip(callback)
    local canBattleCitys = {}
    local cityInfos = self._cityBattleModel:getData().c.c
    for k,v in pairs(tab.cityBattle) do
        local isNear = false
        if cityInfos[tostring(v.id)].b ~= tostring(realSec) then 
            for k1,v1 in pairs(v.nearby) do
                if cityInfos[tostring(v1)].b == tostring(realSec) then 
                    isNear = true
                    break
                end
            end
        end
        if isNear == true then
            table.insert(canBattleCitys, v.id)

        end
    end
    if #canBattleCitys > 0 then
        local index = math.random(1, #canBattleCitys)
        self:screenToCity(canBattleCitys[index], function()
            for k,v in pairs(canBattleCitys) do
                local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. v)
                if cityIconBg.canBattleMc1 ~= nil then
                    cityIconBg.canBattleMc1:gotoAndPlay(1)
                    -- cityIconBg.canBattleMc1:removeFromParent()
                    -- cityIconBg.canBattleMc1 = nil
                else
                    local canBattleMc1 = mcMgr:createViewMC("kegongji2_citybattlechengchidianji", false, true)
                    canBattleMc1:addCallbackAtFrame(canBattleMc1:getTotalFrames(), function()
                        cityIconBg.canBattleMc1 = nil
                    end)
                    canBattleMc1:setPosition(cityIconBg:getContentSize().width * 0.5 + 5, 10)
                    cityIconBg:addChild(canBattleMc1)
                    cityIconBg.canBattleMc1 = canBattleMc1
                end


                if cityIconBg.canBattleMc2 ~= nil then
                    cityIconBg.canBattleMc2:gotoAndPlay(1)
                else
                    local canBattleMc2 = mcMgr:createViewMC("kegongji1_citybattlechengchidianji", false, true)
                    canBattleMc2:addCallbackAtFrame(canBattleMc2:getTotalFrames(), function()
                        cityIconBg.canBattleMc2 = nil

                    end)            
                    canBattleMc2:setPosition(cityIconBg:getContentSize().width * 0.5 + 5, cityIconBg:getContentSize().height * 0.5)
                    cityIconBg:addChild(canBattleMc2, 20)
                    cityIconBg.canBattleMc2 = canBattleMc2 
                end
            end
            self:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.8),
                    cc.CallFunc:create(function()
                        if callback ~= nil then 
                            callback()
                        end  
                    end)
                )) 


        end)
    end
    
end

function CityBattleWorldLayer:resetBigMap()
    self:resetSelectedCityState()
    self._cityServerData = self._cityBattleModel:getCityServerList()
    self._battleState, weekday, self._timeType = self._cityBattleModel:getState()


    local cityInfos = self._cityBattleModel:getData().c.c
    for k,v in pairs(tab.cityBattleMap) do
        self:updateAreaState(v, cityInfos)
    end

    -- 重置地图时清除地图上的小派遣图
    for k,v in pairs(self._miniIconInCity) do
        self:removeCityMiniHeroIcon(v, k)
    end
    -- 初始化编组在地图上的位置
    local cityFormation = self._cityBattleModel:getData().f
    for i=1,4 do
        local fid = self._formationModel["kFormationTypeCityBattle" .. i]
        if cityFormation[tostring(fid)] ~= nil and cityFormation[tostring(fid)].cid ~= nil and cityFormation[tostring(fid)].cid ~= "-1" then
            local fid = self._formationModel["kFormationTypeCityBattle" .. i]
            local formation = self._formationModel:getFormationDataByType(fid)
            local state = self._cityBattleModel:getFormationState(fid, formation)
            if state == CityBattleConst.FORMATION_STATE.READY or state == CityBattleConst.FORMATION_STATE.BATTLE then
                self:createCityMiniHeroIcon(cityFormation[tostring(fid)].cid, formation["heroId"], tostring(fid))
            end
        end
    end

end


--[[
--! @function touchIcon
--! @desc 点击事件
--！@param x x坐标
--！@param y y坐标
--! @return 
--]]
function CityBattleWorldLayer:checkTouchEnd(x, y)
    if x == nil or y == nil then   
        return false
    end
    if self._touchBeganPositionX == nil then return false end
    if math.abs(self._touchBeganPositionX - x) > 10
        or math.abs(self._touchBeganPositionY- y) > 10 then 
        return false
    end
    if self:checkIconTouch(x, y) then return true end

    return false
end

--[[
--! @function resetSelectedCityState
--! @desc 点击其他任意区域重置圆盘面板
--! @return 
--]]
function CityBattleWorldLayer:resetSelectedCityState()
    if self._selectedCityId ~= 0 and self._selectedCityPanel ~= nil then 
        self._selectBgLayer:setVisible(false)
        local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. self._selectedCityId)
        cityIconBg:setLocalZOrder(4)
        local selectedIcon = self._selectBgLayer:getChildByName("selectedIcon" .. self._selectedCityId)
        if selectedIcon ~= nil then selectedIcon:removeFromParent(true) end


        local mask = self._bgLayer:getChildByName("mask_" .. self._selectedCityId)
        if mask ~= nil then
            mask:setLocalZOrder(3)
            mask:setOpacity(100)
        end

        local removeMask = self._bgLayer:getChildByName("remove_mask_" .. self._selectedCityId)
        if removeMask ~= nil then 
            removeMask:removeFromParent()
        end

        self._selectedCityId = 0
        self._selectedCityPanel:setVisible(false)
        self._touchesMovedEx = true

        return 1
    end
    return 0
end

--[[
--! @function checkSectionTouch
--! @desc 检查章图标点击，进入章
--！@param x x坐标
--！@param y y坐标
--! @return 
--]]
function CityBattleWorldLayer:checkIconTouch(x, y)
    if self:resetSelectedCityState() == 1 then return end
    print("checkIconTouch==============================")
    if next(self._usingIcon) == nil then return false end
    for k,v in pairs(self._usingIcon) do
        local pt = v:convertToWorldSpace(cc.p(0, 0))
        if v:isVisible() and pt.x < x and pt.y < y and (pt.x + v:getContentSize().width) > x and (pt.y + v:getContentSize().height) > y  then
            print("1checkIconTouch=====================1")
            v.eventDownCallback(pt.x, pt.y, v)
            v.eventUpCallback(pt.x, pt.y, v)
            return true
        end
    end
    return false
end


function CityBattleWorldLayer:showLightTip(inX, inY, inSize)
    self._viewMgr:guideMaskEnable(inX, inY, inSize, inSize)
    self._viewMgr:guideQuan1(inX, inY)
    self._viewMgr:guideMaskShowAction()
end

--[[
--! @function touchEventIcon
--! @desc 点击其他任意区域重置圆盘面板
--！@param inCityId 城市id
--! @return bool 是否点击
--]]
function CityBattleWorldLayer:touchEventIcon(inCityId)
    if self._battleState == 0 or self._battleState == 2 then 
        if self._timeType == "s2" then 
            
            local pos = cc.p(0, 0)
            for i=1,4 do
                local fid = self._formationModel["kFormationTypeCityBattle" .. i]
                local formation = self._formationModel:getFormationDataByType(fid)
                local state, beginTime, cdTime = self._cityBattleModel:getFormationState(fid, formation)
                if state == CityBattleConst.FORMATION_STATE.CREATE then
                    local fmImg = self._parentView:getUI("leftFmPanel.fmImg" .. i)
                    pos = fmImg:convertToWorldSpaceAR(cc.p(0, 0))
                    break
                end
            end
            if pos.x == 0 and pos.y == 0 then 
                
                local fightTimeBg = self._parentView:getUI("titleBg.fightTimeBg")
                if fightTimeBg == nil then
                    local fmImg = self._parentView:getUI("leftFmPanel.fmImg1")
                    pos = fmImg:convertToWorldSpaceAR(cc.p(0, 0))
                    self._viewMgr:showTip(lang("CITYBATTLE_TIP_20"))
                else
                    pos = fightTimeBg:convertToWorldSpaceAR(cc.p(0, 0))
                    pos.x = pos.x + 65
                    self._viewMgr:showTip(lang("CITYBATTLE_TIP_36"))
                end
            else
                self._viewMgr:showTip(lang("CITYBATTLE_TIP_20"))
            end
            self:showLightTip(pos.x, pos.y, 80)
            return
        elseif self._timeType == "s7" then 
            self._viewMgr:showTip(lang("CITYBATTLE_TIP_26"))
            return
        elseif self._timeType == "s1" then 
            self._viewMgr:showTip(lang("CITYBATTLE_TIP_10"))
            local btn_ready = self._parentView:getUI("titleBg.readlyBg.btn_ready")
            local pos = btn_ready:convertToWorldSpaceAR(cc.p(0, 0))
            self:showLightTip(pos.x, pos.y, 100)
            return
        end
        return
    end

    
    local state = self:resetSelectedCityState()
    if state == 1 then return true end

    local state = self:checkDialPanel(inCityId)
    


    return true
end

-- 圆盘面板英雄icon坐标
local iconPos = {{50, 160}, {104, 242}, {205, 242}, {258, 160}}


--[[
--! @function showDialPanel
--! @desc 展示圆盘面板
--！@param inCityId 城市id
--]]
function CityBattleWorldLayer:checkDialPanel(inCityId)
    local cityData = self._cityBattleModel:getData()
    local joinIn = false
    for k,v in pairs(cityData["f"]) do
        if tostring(v.cid) == tostring(inCityId) then 
            joinIn = true
            break
        end
    end
    if joinIn == true then 
        self:showDialPanel(inCityId)
    else
        self:getDialCityInfo(inCityId, function()
            self:showDialPanel(inCityId)
        end)
    end
end


--[[
--! @function leaveRoom
--! @desc 取消派遣
--！@param inFid 编组id
--！@param callback 回调
--]]
function CityBattleWorldLayer:getDialCityInfo(inCityId, callback)
    local params = {}
    params.cid = inCityId
    params.rid = self._userModel:getData()._id
    params._m = "1"
    self._cityBattleModel:addSendCallback(10013, function(result, error)
        if callback ~= nil then callback(result, error) end
    end)
    self:sendSocketMgs("getCastleInfo", params or {})
end


--[[
--! @function showDialPanel
--! @desc 展示圆盘面板
--！@param inCityId 城市id
--]]
function CityBattleWorldLayer:showDialPanel(inCityId)
    local cityInfos = self._cityBattleModel:getData().c.c
    local cityInfo = cityInfos[tostring(inCityId)]
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
    if cityInfo.t ~= nil and cityInfo.t > curTime then
        self._viewMgr:showTip(lang("CITYBATTLE_TIP_16"))
        return false
    end


    local cityInfos = self._cityBattleModel:getData().c.c
    local cityInfo = cityInfos[tostring(inCityId)]
    local sysCityBattleMap = tab.cityBattleMap[inCityId]
    self._selectedCityId = inCityId

    -- if cityInfo.b ~= tostring(GameStatic.sec) then 
    self._selectBgLayer:setVisible(true)
    -- end
    self._touchesMovedEx = false
    
    local occupyColor = occupyColorPlan[cityInfo.b] or 4

    local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. inCityId)

    cityIconBg:setLocalZOrder(10001)

    local selectedIcon = self._bgLayer:getChildByName("selectedIcon" .. inCityId)
    if selectedIcon ~= nil then 
        selectedIcon:removeFromParent()
    end
    local removeMask = self._bgLayer:getChildByName("remove_mask_" .. inCityId)
    if removeMask ~= nil then 
        removeMask:removeFromParent()
    end
    local count = #self._selectBgLayer:getChildren()

    local selectedIcon = cc.Sprite:createWithSpriteFrameName("citybattle_view_sel" .. inCityId .. ".png")
    selectedIcon:setName("selectedIcon" .. inCityId)
    selectedIcon:setScale(2)
    selectedIcon:setPosition(sysCityBattleMap.terrainpoint[1], sysCityBattleMap.terrainpoint[2])
    selectedIcon:setColor(areaMaskColor[occupyColor])
    self._selectBgLayer:addChild(selectedIcon)

    if occupyColor ~= 4  then
        selectedIcon:setBrightness(50)
        local mask = self._bgLayer:getChildByName("mask_" .. inCityId)
        mask:setOpacity(255)
        mask:setLocalZOrder(10000)
    else
        local sysCityBattleMap = tab.cityBattleMap[inCityId]
        local areaMask = cc.Sprite:createWithSpriteFrameName("citybattle_map_bg_" .. inCityId .. ".png")
        areaMask:setPosition(sysCityBattleMap.terrainpoint[1], sysCityBattleMap.terrainpoint[2])
        areaMask:setName("remove_mask_" .. inCityId)
        areaMask:setScale(2)
        self._bgLayer:addChild(areaMask, 10000)
        areaMask:setOpacity(200)
    end


    local subData = {20, 30, 50}
    local sysCityBattleMap = tab.cityBattleMap[inCityId]
    local sysCityBattle = tab.cityBattle[inCityId]
    local cityLevel = sysCityBattle["citylv" .. serverNum]
    if cityLevel == 4 then 
        cityLevel = 3
    end
    print("serverNum====", serverNum, cityLevel)
    local cPointImgId = cityPointImg[tostring(sysCityBattle.citypoint)]
    print("ssssssssss ",cPointImgId)
    -- 城市等级
    self._selectedCityPanel = self["updateInfoPanel" .. cPointImgId](self, sysCityBattleMap)
    self._selectedCityPanel:setVisible(true)
    self._selectedCityPanel:setScale(0)

    self._selectedCityPanel.cityId = inCityId
    -- 主城
    local manCity = tab:Setting("G_CITYBATTLE_START_" .. serverNum).value
    local isMain = table.indexof(manCity, inCityId)
    print("isMain==========================", isMain)
    if isMain ~= false then
        self._selectedCityPanel.isMainCity = true
    else
        self._selectedCityPanel.isMainCity = false
    end

    local converPoint = self._bgLayer:convertToWorldSpace(cc.p(sysCityBattleMap.citypoint[1], sysCityBattleMap.citypoint[2]))
    local apX = 0
    local apY = 0
    local posX = 0
    local posY = 0
    print("converPoint.x=====", converPoint.x, MAX_SCREEN_WIDTH * 0.5 + 100, MAX_SCREEN_WIDTH * 0.5 - 100)
    if converPoint.x > MAX_SCREEN_WIDTH * 0.5 + 1  then 
        apX = 1
    elseif MAX_SCREEN_WIDTH * 0.5 - 1 > converPoint.x then 
        apX = 0
    else
        apX = 0.5
    end
    posX = converPoint.x

    if converPoint.y > MAX_SCREEN_HEIGHT * 0.5 + 1 then 
        apY = 1
    elseif MAX_SCREEN_HEIGHT * 0.5 - 1 > converPoint.y then 
        apY = 0
    else
        apY = 0.5
    end
    posY = converPoint.y
    if apX == apY and apX == 0.5 then 
        apX = 0
        posX = converPoint.x
    end

    if apX ~= 0.5 and apY ~= 0.5 then
        if apX == 1 then 
            posX = posX 
        else
            posX = posX
        end
        if apY == 1 then 
            posY = posY 
        else
            posY = posY 
        end 
    else
        if apX == 1 then 
            posX = posX - subData[cityLevel]
        elseif apX == 0 then 
            posX = posX + subData[cityLevel]
        end 
        if apY == 1 then 
            posY = posY - subData[cityLevel]
        elseif apY == 0 then 
            posY = posY + subData[cityLevel]
        end                      
    end 
    self._selectedCityPanel.sourcePoint = converPoint
    self._selectedCityPanel:setAnchorPoint(apX, apY)
    self._selectedCityPanel:setPosition(posX, posY)
    local dialImg = self._selectedCityPanel.dialImg
    dialImg:setRotation(-135)
    dialImg:setOpacity(0)
    dialImg:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.1), 
            cc.Spawn:create(
                cc.Sequence:create(cc.EaseIn:create(cc.RotateTo:create(0.3, 8.2), 1),
                cc.RotateTo:create(0.2, 0)),
                cc.FadeIn:create(0.5)
            )
        )
    )
    self._selectedCityPanel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1, 1.1), cc.ScaleTo:create(0.1, 1, 1)))

    -- 更新转盘面板城池信息
    self:updateDialPanelInfo(inCityId)

    -- 提取布阵编组信息
    for i=1,4 do
        self:updateDialFormation(inCityId, i)
    end

    if dialImg.allJoinBtn == nil then
        local allJoinBtn = ccui.ImageView:create("citybattle_view_temp16.png",1)
        allJoinBtn:ignoreContentAdaptWithSize(false)
        allJoinBtn:setName("allJoinBtn")
        allJoinBtn:setAnchorPoint(0.5, 0)
        allJoinBtn:setPosition(88, 42)
        dialImg:addChild(allJoinBtn)
        dialImg.allJoinBtn = allJoinBtn
    end

    -- 战斗结算中
    if self._timeType == "s4" or self._timeType == "s6" or 
        self._selectedCityPanel.isNearCity == false then 
        dialImg.allJoinBtn:setSaturation(-150)
    else
        dialImg.allJoinBtn:setSaturation(0)
    end
    -- 一键派遣
    registerClickEvent(dialImg.allJoinBtn, function()
        if self._timeType == "s4" or self._timeType == "s6" then self._viewMgr:showTip(lang("CITYBATTLE_TIP_25")) return end
        if self._selectedCityPanel.isNearCity == false then self._viewMgr:showTip(lang("CITYBATTLE_TIP_22")) return end
        if self._selectedCityPanel.isMainCity == true then self._viewMgr:showTip("主城不容侵犯") return end
        local params = {}
        params.f = {}
        local j = 1
        local cityData = self._cityBattleModel:getData()
        for i=1, 4 do
            local fid = self._formationModel["kFormationTypeCityBattle" .. i]
            local heroIcon = self._selectedCityPanel:getChildByName("heroIcon" ..  fid)
            local formation = self._formationModel:getFormationDataByType(fid)

            local heroId = formation["heroId"]
            local state = self._cityBattleModel:getFormationState(fid, formation)
            
            local score = self._formationModel:getCurrentFightScoreByType(fid)
            print("score================", score)

            local canJoin =  true
            if cityData["f"][tostring(fid)] ~= nil then 
                if tostring(cityData["f"][tostring(fid)].cid) == tostring(inCityId) then 
                    canJoin = false
                end
            end
            if (state == CityBattleConst.FORMATION_STATE.FREE or 
               state == CityBattleConst.FORMATION_STATE.READY) and canJoin then
                params.f[j] = {}
                params.f[j].fid = fid
                params.f[j].hid = heroId
                params.f[j].score = score
                params.f[j].lt = formation.lt
                local userHeroData = self._heroModel:getHeroData(heroId)
                if userHeroData.skin ~= nil then 
                    params.f[j].skin = userHeroData.skin
                end
                j = j + 1
            end
        end
        if #params.f == 0 then self._viewMgr:showTip("已无可派遣编组") return end
        params.cid =  inCityId
        local fids = {}
        for k,v in pairs(params.f) do
            table.insert(fids, v.fid)
        end
        self._lockBattleTipTime = os.time() + j * 1
        self:upGVGBattleInfo(fids, inCityId, function()
            self._viewMgr:lock(-1)
            self:enterRoom(params, function(result, error)
                self._viewMgr:unlock()
                if error ~= 0 then return end
                local cityInfos = self._cityBattleModel:getData().c.c
                local sysCityBattleMap = tab:CityBattleMap(tonumber(inCityId))
                self:updateAreaState(sysCityBattleMap, cityInfos)

                local dispatchAction
                dispatchAction = function(runIndex)
                    if params.f[runIndex] == nil then return end
                    local v = params.f[runIndex]
                    self:runHeroDispatchAction(params.cid, v.fid, v.hid)
                    self:updateDialPanelInfo(params.cid)
                    dialImg.allJoinBtn:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(.5), 
                            cc.CallFunc:create(
                                function()
                                    runIndex = runIndex + 1
                                    dispatchAction(runIndex)
                                end
                                )
                            )
                        )
                end
                dispatchAction(1)            
            end)
        end)

    end)        

    -- 查看按钮
    if dialImg.viewBattleBtn == nil then
        local viewBattleBtn = ccui.ImageView:create("citybattle_view_temp17.png",1)
        viewBattleBtn:ignoreContentAdaptWithSize(false)
        viewBattleBtn:setName("viewBattleBtn")
        viewBattleBtn:setAnchorPoint(0.5, 0)
        viewBattleBtn:setPosition(225, 46)
        dialImg:addChild(viewBattleBtn)
        dialImg.viewBattleBtn = viewBattleBtn

    end
    registerClickEvent(dialImg.viewBattleBtn, function()
        self._viewMgr:showTip("观战了")
        print("inCityId==========================", inCityId)
        self._viewMgr:showView("citybattle.CityBattleFightView", {cityId = inCityId})
    end)         
    return true
end


local serverSmallImage = {"citybattle_view_temp6","citybattle_view_temp8","citybattle_view_temp7"}
--[[
--! @function updateDialPanelInfo
--! @desc 更新展示圆盘面板信息
--！@param inCityId 城市id
--]]
function CityBattleWorldLayer:updateDialPanelInfo(inCityId)
    if self._selectedCityPanel == nil or self._selectedCityPanel:isVisible() == false then return end
    if tostring(self._selectedCityPanel.cityId)  ~= tostring(inCityId) then return end

    local sysCityBattle = tab:CityBattle(tonumber(inCityId))
    local cityInfos = self._cityBattleModel:getData().c.c
    local cityInfo = cityInfos[tostring(inCityId)]

    if cityInfo == nil then print("inCityId==================", inCityId) return end
    
    self._selectedCityPanel.isNearCity = false
    if cityInfo.b == tostring(realSec) then 
        self._selectedCityPanel.isNearCity = true
    else
        for k,v in pairs(sysCityBattle.nearby) do
            if cityInfos[tostring(v)].b == tostring(realSec) then 
                self._selectedCityPanel.isNearCity = true
            end
        end 
    end

    if self._selectedCityPanel.infoStripBg1 == nil then
        local infoStripBg1 = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp38.png")
        -- infoStripBg1:setPosition(iconPos[inIndex][1], iconPos[inIndex][2])
        -- infoStripBg1:setName("vacancy_" .. inIndex)
        self._selectedCityPanel:addChild(infoStripBg1)
        self._selectedCityPanel.infoStripBg1 = infoStripBg1
    end

    if self._selectedCityPanel.infoStripBg2 == nil then
        local infoStripBg2 = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp38.png")
        -- infoStripBg2:setPosition(iconPos[inIndex][1], iconPos[inIndex][2])
        -- infoStripBg2:setName("vacancy_" .. inIndex)
        self._selectedCityPanel:addChild(infoStripBg2)
        self._selectedCityPanel.infoStripBg2 = infoStripBg2
    end


    local serverColor = occupyColorPlan[cityInfo.b] or 4
    if self._selectedCityPanel.isMainCity and serverColor ~=  4 then 
        print("enter main city==================================================")
        if self._selectedCityPanel.tipLab1 ~= nil then
            self._selectedCityPanel.tipLab1:setVisible(false)
        end
        
        if self._selectedCityPanel.battleInfo ~= nil then 
            self._selectedCityPanel.battleInfo:setVisible(false)
        end

        if self._selectedCityPanel.battleInfo1 ~= nil then 
            self._selectedCityPanel.battleInfo1:setVisible(false)
        end

        if self._selectedCityPanel.rewardInfo ~= nil then
            self._selectedCityPanel.rewardInfo:removeFromParent()
            self._selectedCityPanel.rewardInfo = nil
        end


        local mainInfoPos  = self._selectedCityPanel.mainInfoPos


        self._selectedCityPanel.infoStripBg1:setVisible(true)
        self._selectedCityPanel.infoStripBg1:setPosition(mainInfoPos[1][1], mainInfoPos[1][2])

        -- 主城大本营提示
        if self._selectedCityPanel.sTipLab1 == nil then
            local sTipLab1 = cc.Label:createWithTTF("大本营", UIUtils.ttfName, 16)
            sTipLab1:setAnchorPoint(cc.p(0.5, 0.5))
            sTipLab1:setColor(cc.c3b(255, 223, 71))
            sTipLab1:setPosition(mainInfoPos[1][1], mainInfoPos[1][2])
            self._selectedCityPanel:addChild(sTipLab1)   
            self._selectedCityPanel.sTipLab1 = sTipLab1
        end
        self._selectedCityPanel.sTipLab1:setVisible(true)
        
        local serverName = self._cityBattleModel:getServerName(cityInfo.b)
        -- 大本营服务器信息
        if self._selectedCityPanel.serverInfo == nil then
            local tips1 = {}
            tips1[1] = cc.Sprite:createWithSpriteFrameName(serverSmallImage[serverColor] .. ".png")
            tips1[2] = cc.Label:createWithTTF(serverName.. "服", UIUtils.ttfName, 16)
            tips1[2]:enableOutline(cc.c4b(0, 0, 0, 255), 1)
            tips1[1]:setScale(0.8)
            local nodeTip1 = UIUtils:createHorizontalNode(tips1, cc.p(0, 0.5))
            nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
            nodeTip1:setPosition(mainInfoPos[2][1], mainInfoPos[2][2])
            self._selectedCityPanel:addChild(nodeTip1)   
            self._selectedCityPanel.serverInfo = nodeTip1
            self._selectedCityPanel.serverInfoWidget = tips1
        end

        

        self._selectedCityPanel.serverInfoWidget[1]:setSpriteFrame(serverSmallImage[serverColor] .. ".png")
        self._selectedCityPanel.serverInfoWidget[2]:setString(serverName .. "服")

        UIUtils:alignHorizontalNode(self._selectedCityPanel.serverInfo, self._selectedCityPanel.serverInfoWidget, nil, nil, 2, nil, false)
        self._selectedCityPanel.serverInfo:setVisible(true)

        -- 主城大本营服务器名
        if self._selectedCityPanel.serverNameLab == nil then
            local serverNameLab = cc.Label:createWithTTF(serverName, UIUtils.ttfName, 16)
            self._selectedCityPanel:addChild(serverNameLab)
            serverNameLab:enableOutline(cc.c4b(0, 0, 0, 255), 1)
            self._selectedCityPanel.serverNameLab = serverNameLab
        end
        self._selectedCityPanel.serverNameLab:setPosition(mainInfoPos[3][1], mainInfoPos[3][2])
        self._selectedCityPanel.serverNameLab:setString(serverName)
        self._selectedCityPanel.serverNameLab:setVisible(true)

        if self._selectedCityPanel.sTipLab2 == nil then
            -- 主城大本营提示
            local sTipLab2 = cc.Label:createWithTTF("不可被占领", UIUtils.ttfName, 16)
            sTipLab2:setAnchorPoint(cc.p(0.5, 0.5))
            sTipLab2:setColor(cc.c3b(255, 223, 71))
            sTipLab2:setPosition(mainInfoPos[4][1], mainInfoPos[4][2])
            self._selectedCityPanel:addChild(sTipLab2)   
            self._selectedCityPanel.sTipLab2 = sTipLab2
        end
        self._selectedCityPanel.sTipLab2:setVisible(true)

        self._selectedCityPanel.infoStripBg2:setVisible(true)
        self._selectedCityPanel.infoStripBg2:setPosition(mainInfoPos[4][1], mainInfoPos[4][2])

    else
        print("other main city==================================================")
        if self._selectedCityPanel.serverInfo ~= nil then 
            self._selectedCityPanel.serverInfo:setVisible(false)
        end
        
        if self._selectedCityPanel.serverNameLab ~= nil then 
            self._selectedCityPanel.serverNameLab:setVisible(false)
        end

        if self._selectedCityPanel.sTipLab1 ~= nil then 
            self._selectedCityPanel.sTipLab1:setVisible(false)
        end

        if self._selectedCityPanel.sTipLab2 ~= nil then 
            self._selectedCityPanel.sTipLab2:setVisible(false)
        end

        local battleInfoPos  = self._selectedCityPanel.battleInfoPos
        if self._selectedCityPanel.tipLab1 == nil then
            local tipLab1 = cc.Label:createWithTTF("实力对比", UIUtils.ttfName, 14)
            tipLab1:setAnchorPoint(cc.p(0.5, 0.5))

            tipLab1:setColor(cc.c3b(255, 223, 71))
            tipLab1:enableOutline(cc.c4b(0, 0, 0, 255), 1)            
            self._selectedCityPanel:addChild(tipLab1)   
            self._selectedCityPanel.tipLab1 = tipLab1
        end

        self._selectedCityPanel.tipLab1:setVisible(true)
        self._selectedCityPanel.tipLab1:setPosition(battleInfoPos[1][1], battleInfoPos[1][2] + 20)
        if self._selectedCityPanel.battleInfo == nil then
            local tips1 = {}
            tips1[1] = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp40.png")
            tips1[2] = cc.Label:createWithTTF(cityInfo.an, UIUtils.ttfName, 14)
            tips1[3] = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp41.png")
            tips1[4] = cc.Label:createWithTTF(cityInfo.dn, UIUtils.ttfName, 14)
            tips1[5] = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp39.png")
            local nodeTip1 = UIUtils:createHorizontalNode(tips1, cc.p(0, 0.5))
            nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
            nodeTip1:setPosition(battleInfoPos[1][1], battleInfoPos[1][2])

            self._selectedCityPanel:addChild(nodeTip1)   
            self._selectedCityPanel.battleInfo = nodeTip1
            -- 信息相关控件
            self._selectedCityPanel.battleInfoWidget = tips1
        end
        self._selectedCityPanel.battleInfo:setVisible(true)

        self._selectedCityPanel.infoStripBg1:setPosition(battleInfoPos[1][1], battleInfoPos[1][2])
        self._selectedCityPanel.infoStripBg1:setVisible(true)

        self._selectedCityPanel.battleInfoWidget[2]:setString(cityInfo.an)
        self._selectedCityPanel.battleInfoWidget[4]:setString(cityInfo.dn)

        UIUtils:alignHorizontalNode(self._selectedCityPanel.battleInfo, self._selectedCityPanel.battleInfoWidget, nil, nil, 2, nil, false)


        if self._selectedCityPanel.battleInfo1 == nil then
            local tips1 = {}
            tips1[1] = cc.Label:createWithTTF(cityInfo.as, UIUtils.ttfName, 14)
            tips1[2] = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp41.png")
            tips1[3] = cc.Label:createWithTTF(cityInfo.ds, UIUtils.ttfName, 14)

            local nodeTip1 = UIUtils:createHorizontalNode(tips1, cc.p(0, 0.5))
            nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
            
            nodeTip1:setPosition(battleInfoPos[2][1], battleInfoPos[2][2])

            self._selectedCityPanel:addChild(nodeTip1)   
            self._selectedCityPanel.battleInfo1 = nodeTip1
            -- 信息相关控件
            self._selectedCityPanel.battleInfo1Widget = tips1
        end
        self._selectedCityPanel.battleInfo1:setVisible(true)


        self._selectedCityPanel.infoStripBg2:setPosition(battleInfoPos[2][1], battleInfoPos[2][2])
        self._selectedCityPanel.infoStripBg2:setVisible(true)

        local as = ""
        if tonumber(cityInfo.as) > 100000000 then
            as = string.format("%.0f", tonumber(cityInfo.as)/ 100000000) .. "亿"
        elseif tonumber(cityInfo.as) > 100000 then
            as =  string.format("%.0f", tonumber(cityInfo.as) / 10000) .. "万"
        else
            as = tonumber(cityInfo.as)
        end

        local ds = ""
        if tonumber(cityInfo.ds) > 100000000 then
            ds =  string.format("%.0f", tonumber(cityInfo.ds)/ 100000000) .. "亿"
        elseif tonumber(cityInfo.ds) > 100000 then
            ds =  string.format("%.0f", tonumber(cityInfo.ds) / 10000) .. "万"
        else
            ds = tonumber(cityInfo.ds)
        end

        self._selectedCityPanel.battleInfo1Widget[1]:setString(as)
        self._selectedCityPanel.battleInfo1Widget[3]:setString(ds)

        UIUtils:alignHorizontalNode(self._selectedCityPanel.battleInfo1, self._selectedCityPanel.battleInfo1Widget, nil, nil, 2, nil, false)

        -- 城池奖励信息
        if self._selectedCityPanel.rewardInfo ~= nil then
            self._selectedCityPanel.rewardInfo:removeFromParent()
            self._selectedCityPanel.rewardInfo = nil
        end
        local cityReward = sysCityBattle["cityreward" .. serverNum]
        local itemId
        if IconUtils.iconIdMap[cityReward[1]] then
            itemId = IconUtils.iconIdMap[cityReward[1]]
        else
            itemId = cityReward[2]
        end

        local battleInfoPos  = self._selectedCityPanel.battleInfoPos
        local toolD = tab:Tool(itemId)
        local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = cityReward[3],eventStyle = 1, swallowTouches = true})
        icon:setScale(0.5)
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setPosition(battleInfoPos[3][1], battleInfoPos[3][2])
        self._selectedCityPanel:addChild(icon) 
        self._selectedCityPanel.rewardInfo = icon

    end

end

--获取英雄头像id
--@Heroid 英雄id
function CityBattleWorldLayer:getHeroHeadByHeroId(heroID)
    if not self._heroHeadList then
        self._heroHeadList = {}
    end
    if self._heroHeadList[heroID] then 
        return self._heroHeadList[heroID] 
    end
    local heroData = self._heroModel:getHeroData(heroID)
    local herohead
    local skin = heroData.skin
    if skin then
        local heroSkinD = tab.heroSkin[skin]
        herohead = heroSkinD["herohead"] or heroData.herohead
    else
        herohead = heroData.herohead
    end
    self._heroHeadList[heroID] = herohead
    return herohead
end


--[[
--! @function updateDialFormation
--! @desc 更新展示圆盘面板编组信息
--！@param inCityId 城市id
--！@param inIndex 编组下标
--]]

function CityBattleWorldLayer:updateDialFormation(inCityId, inIndex)
    if self._selectedCityPanel == nil or self._selectedCityPanel:isVisible() == false then return end
    if tostring(self._selectedCityPanel.cityId)  ~= tostring(inCityId) then return end
    local selectedCityPanel = self._selectedCityPanel
    local fid = self._formationModel["kFormationTypeCityBattle" .. inIndex]
    local heroIcon = selectedCityPanel.dialImg:getChildByName("heroIcon" ..  fid)

    local cityInfos = self._cityBattleModel:getData().c.c
    -- 空缺头像替代图
    local vacancySp = selectedCityPanel.dialImg:getChildByName("vacancy_" ..  inIndex)

    local formation = self._formationModel:getFormationDataByType(fid)
    local state, beginTime, cdTime = self._cityBattleModel:getFormationState(fid, formation)
    

    if state >= CityBattleConst.FORMATION_STATE.FREE then 
        local heroId = formation["heroId"]
        if vacancySp ~= nil then 
            vacancySp:setVisible(false)
        end
        if heroIcon ~= nil and heroIcon.sp ~= nil then 
            local heroHead = self:getHeroHeadByHeroId(heroId)
            heroIcon.sp:setSpriteFrame(IconUtils.iconPath .. heroHead .. ".jpg")
        else
            heroIcon = self:createHeroIcon(heroId)
            heroIcon:setName("heroIcon" .. fid)
            heroIcon:setPosition(iconPos[inIndex][1], iconPos[inIndex][2])
            selectedCityPanel.dialImg:addChild(heroIcon)
        end
        heroIcon:setTouchEnabled(false)
        heroIcon.heroId = heroId
        if heroIcon.stateSp == nil  then
            local stateSp = ccui.ImageView:create("citybattle_view_temp11.png",1)
            stateSp:setName("stateSp")
            stateSp:setAnchorPoint(0.5, 0)
            stateSp:setPosition(heroIcon:getContentSize().width * 0.5, -5)
            heroIcon:addChild(stateSp)
            heroIcon.stateSp = stateSp
        end
        heroIcon.stateSp:setVisible(true)
        heroIcon.stateSp:setPosition(heroIcon:getContentSize().width * 0.5, -5)
        heroIcon.sp:setSaturation(-150)
        local canClick = false
        local showTip = ""
        -- 战斗结算中
        if self._timeType == "s4" or self._timeType == "s6" then 
            canClick = false
            showTip = lang("CITYBATTLE_TIP_25")
            heroIcon.stateSp:loadTexture("citybattle_view_temp28.png", 1)
            heroIcon.stateSp:setPosition(heroIcon:getContentSize().width * 0.5, heroIcon:getContentSize().height * 0.5 - heroIcon.stateSp:getContentSize().height * 0.5)
        -- 主城无法攻击
        elseif self._selectedCityPanel.isMainCity == true then
            canClick = false
            local cityInfo = cityInfos[tostring(inCityId)]
            if cityInfo.b == tostring(realSec) then 
                showTip = lang("CITYBATTLE_TIP_27")
            else
                showTip = lang("CITYBATTLE_TIP_24")
            end
            heroIcon.stateSp:loadTexture("citybattle_view_temp28.png", 1)
            heroIcon.stateSp:setPosition(heroIcon:getContentSize().width * 0.5, heroIcon:getContentSize().height * 0.5 - heroIcon.stateSp:getContentSize().height * 0.5)
        -- 不是临近城展示不可攻击状态
        elseif not self._selectedCityPanel.isNearCity then
            heroIcon.stateSp:loadTexture("citybattle_view_temp28.png", 1)
            showTip = lang("CITYBATTLE_TIP_22")

            heroIcon.stateSp:setPosition(heroIcon:getContentSize().width * 0.5, heroIcon:getContentSize().height * 0.5 - heroIcon.stateSp:getContentSize().height * 0.5)
        elseif state == CityBattleConst.FORMATION_STATE.BATTLE then 
            heroIcon.stateSp:loadTexture("citybattle_view_temp24.png", 1)
            showTip = lang("CITYBATTLE_TIP_17")
        elseif state == CityBattleConst.FORMATION_STATE.READY then
            local cityData = self._cityBattleModel:getData()
            local cityInfo = cityInfos[tostring(cityData["f"][tostring(fid)].cid)]
            if cityInfo.b == tostring(realSec) then 
                heroIcon.stateSp:loadTexture("citybattle_view_temp36.png", 1)
            else
                heroIcon.stateSp:loadTexture("citybattle_view_temp26.png", 1)                
            end
            canClick = true
            if tostring(cityData["f"][tostring(fid)].cid) == tostring(inCityId) then 
                canClick = false
                showTip = lang("CITYBATTLE_TIP_23")
            end
        elseif state == CityBattleConst.FORMATION_STATE.FREE then
            heroIcon.stateSp:loadTexture("citybattle_view_temp25.png", 1)
            heroIcon.stateSp:setVisible(false)
            canClick = true
        elseif state == CityBattleConst.FORMATION_STATE.DIE then 
            heroIcon.stateSp:loadTexture("citybattle_view_temp27.png", 1)
            heroIcon:runAction(
                cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.CallFunc:create(
                            function()
                                local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
                                if curTime >= cdTime then 
                                    heroIcon:stopAllActions()
                                    self:updateDialFormation(inCityId, inIndex)
                                    return
                                end
                            end
                        ),
                        cc.DelayTime:create(1)
                    )
                )
            )
            showTip = lang("CITYBATTLE_TIP_19")           
        else
            heroIcon.stateSp:setVisible(false)
        end

        -- 允许点击一键派遣
        if canClick then
            heroIcon.sp:setSaturation(0)
        end
        registerClickEvent(heroIcon, function(sender)
            if canClick then
                local score =  self._formationModel:getCurrentFightScoreByType(fid)
                local params = {}
                params.cid =  inCityId
                params.f = {}
                params.f[1] = {}
                params.f[1].fid = fid
                params.f[1].hid = heroId
                params.f[1].score = score
                params.f[1].lt = formation.lt
                local userHeroData = self._heroModel:getHeroData(heroId)
                if userHeroData.skin ~= nil then 
                    params.f[1].skin = userHeroData.skin
                end

                local fids = {}
                for k,v in pairs(params.f) do
                    table.insert(fids, v.fid)
                end
                self._lockBattleTipTime = os.time() + 1
                self:upGVGBattleInfo(fids, inCityId, function()
                    self._viewMgr:lock(-1)
                    self:enterRoom(params, function(result, error)
                        self._viewMgr:unlock()
                        if error ~= 0 then return end
                        local cityInfos = self._cityBattleModel:getData().c.c
                        local sysCityBattleMap = tab:CityBattleMap(tonumber(inCityId))
                        self:updateAreaState(sysCityBattleMap, cityInfos)
                        self:runHeroDispatchAction(inCityId, fid, heroId)
                        self:updateDialPanelInfo(inCityId)
                    end)
                end)
            else
                if string.len(showTip) > 0 then 
                    self._viewMgr:showTip(showTip)
                end
            end
        end)

    else
        if heroIcon ~= nil then 
            heroIcon:setVisible(false)
        end
        
        if vacancySp == nil then
            vacancySp = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp30.png")
            vacancySp:setPosition(iconPos[inIndex][1], iconPos[inIndex][2])
            vacancySp:setName("vacancy_" .. inIndex)
            selectedCityPanel.dialImg:addChild(vacancySp)

            local mask = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp18.png")
            mask:setScale(0.8)
            mask:setAnchorPoint(0.5, 0.5)
            mask:setPosition(vacancySp:getContentSize().width * 0.5, vacancySp:getContentSize().height * 0.5)
            vacancySp:addChild(mask)

        end
        vacancySp:setVisible(true)
                
    end
end

--[[
--! @function runHeroDispatchAction
--! @desc 运行派遣动画
--！@param inCityId 城市id
--！@param inFormationId 编组id
--！@param inHeroId 英雄id
--]]
function CityBattleWorldLayer:runHeroDispatchAction(inCityId, inFormationId, inHeroId)
    self._viewMgr:lock(-1)
    local tempHeroIcon = self:createHeroIcon(inHeroId)
    tempHeroIcon:setName("tempHeroIcon")
    tempHeroIcon:setOpacity(255)
    tempHeroIcon:setCascadeOpacityEnabled(true, true)
    local findex = self._formationWithIndex[inFormationId]
    tempHeroIcon:setPosition(iconPos[findex][1], iconPos[findex][2])
    self._selectedCityPanel.dialImg:addChild(tempHeroIcon)
    tempHeroIcon.fid = inFormationId 

    local converPoint = self._selectedCityPanel.dialImg:convertToNodeSpace(self._selectedCityPanel.sourcePoint)
    local converPoint1 = cc.p(converPoint.x, converPoint.y)
    converPoint1.y = converPoint1.y + 100
    tempHeroIcon:runAction(cc.Sequence:create(
        cc.Spawn:create(
                cc.EaseIn:create(cc.MoveTo:create(0.2, converPoint1), 0.2),
                cc.EaseIn:create(cc.ScaleTo:create(0.2, 1.2, 1.2), 0.2)
                ),
        cc.DelayTime:create(0.1),
        cc.Spawn:create(
                cc.EaseOut:create(cc.MoveTo:create(0.1, converPoint), 0.2),
                
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 0.25, 0.25), 0.2)
                ),
        cc.FadeOut:create(0.1),
        cc.CallFunc:create(function()
            self._viewMgr:unlock()
            self:addCityMiniHeroIcon(self._selectedCityPanel.cityId, inHeroId, tempHeroIcon)
            self:updateDialFormation(inCityId, findex)
        end)
        ))
end

-- 地图mini icon 位置
local cityHeroIconPos = {{{0, 50}}, {{-25, 50}, {25, 50}, {-60, 20}, {60, 20}}}
-- local cityHeroIconScale = {{1}, {0.7, 0.7}, {0.5, 0.5, 0.5}, {0.4, 0.4, 0.4, 0.4}}
--[[
--! @function addCityMiniHeroIcon
--! @desc 添加地图mini 英雄icon
--！@param inCityId 城市id
--！@param inHeroId 英雄id
--！@param tempHeroIcon 圆盘icon的clone版本
--]]
function CityBattleWorldLayer:addCityMiniHeroIcon(inCityId, inHeroId, tempHeroIcon)

    local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. inCityId)
    -- if cityIconBg:getChildByName("dispatch_" .. inHeroId) ~= nil then return end
    tempHeroIcon:retain()
    tempHeroIcon:removeFromParent()
    tempHeroIcon:setName("dispatch_" .. inHeroId)
    cityIconBg:addChild(tempHeroIcon, 50)
    tempHeroIcon:setPosition(cityIconBg:getContentSize().width * 0.5, cityIconBg:getContentSize().height * 0.5)
    tempHeroIcon:setScale(0.6)
    tempHeroIcon:setOpacity(0)

    if cityIconBg.heros == nil then 
        cityIconBg.heros = {}
    end

    if #cityIconBg.heros == 0 then
        local pos = cc.p(cityHeroIconPos[1][1][1] + cityIconBg:getContentSize().width * 0.5, cityHeroIconPos[1][1][2] + cityIconBg:getContentSize().height * 0.5)
        tempHeroIcon:runAction(cc.Sequence:create(
                            cc.Spawn:create(
                                cc.EaseIn:create(cc.MoveTo:create(0.1, pos), 0.2),
                                cc.EaseIn:create(cc.FadeIn:create(0.1), 0.2)
                            ),
                            cc.CallFunc:create(function()
                                self:updateCityMiniHeroIconState(inCityId, inHeroId)
                            end)
                        )
                    )
    else
        if #cityIconBg.heros == 1 then
            local pos1 = cc.p(cityHeroIconPos[2][1][1] + cityIconBg:getContentSize().width * 0.5, cityHeroIconPos[2][1][2] + cityIconBg:getContentSize().height * 0.5)
            local firstHeroIcon = cityIconBg:getChildByName("dispatch_" .. cityIconBg.heros[1])
            if firstHeroIcon ~= nil then
                firstHeroIcon:runAction(cc.Sequence:create(
                                    cc.EaseIn:create(cc.MoveTo:create(0.1, pos1), 0.2)
                                )
                            )
            end
        end
        local pos2 = cc.p(cityHeroIconPos[2][#cityIconBg.heros + 1][1] + cityIconBg:getContentSize().width * 0.5, cityHeroIconPos[2][#cityIconBg.heros + 1][2] + cityIconBg:getContentSize().height * 0.5)
        tempHeroIcon:runAction(cc.Sequence:create(
                            cc.Spawn:create(
                                cc.EaseIn:create(cc.MoveTo:create(0.2, pos2), 0.2),
                                cc.EaseIn:create(cc.FadeIn:create(0.2), 0.2)
                            ),
                            cc.CallFunc:create(function()
                                self:updateCityMiniHeroIconState(inCityId, inHeroId)
                            end)
                        )
                    )
    end
    table.insert(cityIconBg.heros, inHeroId)

    self._miniIconInCity[inHeroId] = inCityId
end

--[[
--! @function removeCityMiniHeroIcon
--! @desc 删除地图mini 英雄icon
--！@param inCityId 城市id
--！@param inHeroId 英雄id
--]]
function CityBattleWorldLayer:removeCityMiniHeroIcon(inCityId, inHeroId)
    local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. inCityId)
    if cityIconBg == nil or cityIconBg.heros == nil then return end

    local tempHeroIcon = cityIconBg:getChildByName("dispatch_" .. inHeroId)
    if tempHeroIcon ~= nil then
        tempHeroIcon:removeFromParent(true)
    end
    if heroIcon ~= nil then heroIcon:removeFromParent() end
    table.removebyvalue(cityIconBg.heros, inHeroId)

    self._miniIconInCity[inHeroId] = nil
    if #cityIconBg.heros == 1 then
        local tempHeroIcon = cityIconBg:getChildByName("dispatch_" .. cityIconBg.heros[1])
        local pos = cc.p(cityHeroIconPos[1][1][1] + cityIconBg:getContentSize().width * 0.5, cityHeroIconPos[1][1][2] + cityIconBg:getContentSize().height * 0.5)
        tempHeroIcon:setPosition(pos)
   else
        for i=1,#cityIconBg.heros do
            local tempHeroIcon = cityIconBg:getChildByName("dispatch_" .. cityIconBg.heros[i])
            local pos2 = cc.p(cityHeroIconPos[2][i][1] + cityIconBg:getContentSize().width * 0.5, cityHeroIconPos[2][i][2] + cityIconBg:getContentSize().height * 0.5)
            tempHeroIcon:setPosition(pos2)
        end
    end
end

--[[
--! @function createCityMiniHeroIcon
--! @desc 创建城市派遣英雄头像
--! @param inCityId 城市id
--! @param inHeroId 英雄id
--! @return 
--]]
function CityBattleWorldLayer:createCityMiniHeroIcon(inCityId, inHeroId, inFid)
    print("createCityMiniHeroIcon=======================================================================")
    local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. inCityId)
    if cityIconBg.heros == nil then 
        cityIconBg.heros = {}
    end
    local tempHeroIcon = self:createHeroIcon(inHeroId)
    tempHeroIcon:setScale(0.6)
    tempHeroIcon:setName("dispatch_" .. inHeroId)
    cityIconBg:addChild(tempHeroIcon, 50)
    tempHeroIcon.fid = inFid
    if #cityIconBg.heros == 0 then
        local pos = cc.p(cityHeroIconPos[1][1][1] + cityIconBg:getContentSize().width * 0.5, cityHeroIconPos[1][1][2] + cityIconBg:getContentSize().height * 0.5)
        tempHeroIcon:setPosition(pos)
    else
        if #cityIconBg.heros == 1 then
            local pos1 = cc.p(cityHeroIconPos[2][1][1] + cityIconBg:getContentSize().width * 0.5, cityHeroIconPos[2][1][2] + cityIconBg:getContentSize().height * 0.5)
            local firstHeroIcon = cityIconBg:getChildByName("dispatch_" .. cityIconBg.heros[1])
            if firstHeroIcon ~= nil then
                firstHeroIcon:setPosition(pos1)
            end
        end
        local pos2 = cc.p(cityHeroIconPos[2][#cityIconBg.heros + 1][1] + cityIconBg:getContentSize().width * 0.5, cityHeroIconPos[2][#cityIconBg.heros + 1][2] + cityIconBg:getContentSize().height * 0.5)
        tempHeroIcon:setPosition(pos2)
    end
    self:updateCityMiniHeroIconState(inCityId, inHeroId)
    table.insert(cityIconBg.heros, inHeroId)

    self._miniIconInCity[inHeroId] = inCityId
end


--[[
--! @function removeCityMiniHeroIcon
--! @desc 删除地图mini 英雄icon
--！@param inCityId 城市id
--！@param inHeroId 英雄id
--]]
function CityBattleWorldLayer:updateCityMiniHeroIconState(inCityId, inHeroId)
    local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. inCityId)
    if cityIconBg == nil or cityIconBg.heros == nil then return end

    local tempHeroIcon = cityIconBg:getChildByName("dispatch_" .. inHeroId)
    if tempHeroIcon == nil then return end
    
    if tempHeroIcon.locLabel == nil then
        local tipBg = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp31.png")
       
        tempHeroIcon:addChild(tipBg)
        tempHeroIcon.tipBg = tipBg
        tipBg:setPosition(tempHeroIcon:getContentSize().width/2 , -10)
        tipBg:setAnchorPoint(0.5, 0.5)
 
        local locLabel = cc.Label:createWithTTF("队列:0", UIUtils.ttfName, 15)
        locLabel:setPosition(tempHeroIcon:getContentSize().width/2 , -11)
        locLabel:setAnchorPoint(0.5, 0.5)
        locLabel:setColor(cc.c3b(255, 255, 255))
        tempHeroIcon:addChild(locLabel)
        -- locLabel:setVisible(false)

        locLabel:setColor(cc.c3b(255, 255, 255))
        tempHeroIcon.locLabel = locLabel
    end
    local locIndex = 0
    local cityData = self._cityBattleModel:getData()
    if cityData["f"] ~= nil and cityData["f"][tostring(tempHeroIcon.fid)] ~= nil then 
        locIndex = cityData["f"][tostring(tempHeroIcon.fid)].i
    end
    print("updateCityMiniHeroIconState===", locIndex)
    tempHeroIcon.tipBg:setScale(1/tempHeroIcon:getScale())
    tempHeroIcon.locLabel:setScale(1/tempHeroIcon:getScale() * 0.5)
    tempHeroIcon.locLabel:setString("队列:" .. locIndex)

    --add 2017.11.9 如果locIndex == -1，则为非法icon,需要执行移除
    if locIndex <= 0 then
        self:removeCityMiniHeroIcon(inCityId, inHeroId)
    end
end

--[[
--! @function createHeroIcon
--! @desc 创建英雄图标
--！@param inHeroId 英雄id
--]]
function CityBattleWorldLayer:createHeroIcon(inHeroId)
    local headWidget = ccui.Widget:create()
    headWidget:setPosition(35,35)
    headWidget:setAnchorPoint(cc.p(0.5, 0.5))
    
    local heroHead = self:getHeroHeadByHeroId(inHeroId)
    local sp = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. heroHead .. ".jpg")
    sp:setScale(0.8)
    headWidget:setContentSize(sp:getContentSize().width * sp:getScale(), sp:getContentSize().height * sp:getScale())
    headWidget.sp = sp

    local clipNode = cc.ClippingNode:create()
    clipNode:setInverted(false)

    local mask = cc.Sprite:createWithSpriteFrameName("teamImageUI_img30.png")
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    clipNode:addChild(sp)
    clipNode:setPosition(headWidget:getContentSize().width * 0.5, headWidget:getContentSize().height * 0.5)
    headWidget:addChild(clipNode)

    local mask = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp18.png")
    mask:setScale(0.8)
    mask:setAnchorPoint(0.5, 0.5)
    mask:setPosition(headWidget:getContentSize().width * 0.5, headWidget:getContentSize().height * 0.5)
    headWidget:addChild(mask)

    -- local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 182))
    -- layer:setContentSize(sp:getContentSize().width * sp:getScale(), sp:getContentSize().height * sp:getScale())
    -- layer:setPosition(0, 0)
    -- headWidget:addChild(layer)

    return headWidget
end

--[[
--! @function updateInfoPanel1
--! @desc 更新小城池面板信息
--！@param inCintyInfo 城池信息
--]]
function CityBattleWorldLayer:updateInfoPanel3(inCintyInfo)
    local cityInfoBg = self._parentView:getChildByName("cityInfoBg1")
    if cityInfoBg == nil then 
        cityInfoBg = cc.Sprite:createWithSpriteFrameName("citybattle_view_panel_level1.png")
        cityInfoBg:setName("cityInfoBg1")
        self._parentView:addChild(cityInfoBg, 100) 

        local dialImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_panel_front1.png")
        dialImg:setName("dialImg")
        dialImg:setPosition(cityInfoBg:getContentSize().width * 0.5, cityInfoBg:getContentSize().height * 0.5)
        cityInfoBg:addChild(dialImg) 

        local centerWidth = cityInfoBg:getContentSize().width * 0.5
        cityInfoBg.battleInfoPos = {{centerWidth, 170}, {centerWidth, 148}, {centerWidth, 113}}
        cityInfoBg.mainInfoPos = {{centerWidth, 177}, {centerWidth, 154}, {centerWidth, 132}, {centerWidth, 109}}
        cityInfoBg.dialImg = dialImg

   
        -- local tempMc = mcMgr:createViewMC("gaojichibang1_citybattlechengchidianji", false, false)
        -- tempMc:setPosition(cityInfoBg:getContentSize().width * 0.5, cityInfoBg:getContentSize().height)
        -- tempMc:setName("bosseffet")
        -- tempMc:addCallbackAtFrame(tempMc:getTotalFrames(), function()
        --     tempMc:stop()
        -- end)
        -- tempMc:stop()
        local tempWing = ccui.ImageView:create()
        tempWing:loadTexture("citybattle_wing3.png",1)
        tempWing:setPosition(cityInfoBg:getContentSize().width * 0.5, cityInfoBg:getContentSize().height)
        tempWing:setVisible(false)
        cityInfoBg:addChild(tempWing, 7)
        cityInfoBg.tempWing = tempWing
    end
    cityInfoBg.tempWing:setVisible(false)
    cityInfoBg.tempWing:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function()
                cityInfoBg.tempWing:setVisible(true)
                -- cityInfoBg.tempMc:gotoAndPlay(1)
            end)
            ))
    return cityInfoBg
end

--[[
--! @function updateInfoPanel2
--! @desc 更新中城池面板信息
--！@param inCintyInfo 城池信息
--]]
function CityBattleWorldLayer:updateInfoPanel2(inCintyInfo)
    local cityInfoBg = self._parentView:getChildByName("cityInfoBg2")
    if cityInfoBg == nil then 
        cityInfoBg = cc.Sprite:createWithSpriteFrameName("citybattle_view_panel_level2.png")
        cityInfoBg:setName("cityInfoBg2")
        self._parentView:addChild(cityInfoBg, 100)    

        local dialImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_panel_front1.png")
        dialImg:setName("dialImg")
        dialImg:setPosition(cityInfoBg:getContentSize().width * 0.5, cityInfoBg:getContentSize().height * 0.5 + 15)
        cityInfoBg:addChild(dialImg)  

        local centerWidth = cityInfoBg:getContentSize().width * 0.5
        cityInfoBg.battleInfoPos = {{centerWidth, 218}, {centerWidth, 196}, {centerWidth, 161}}    
        cityInfoBg.mainInfoPos = {{centerWidth, 223}, {centerWidth, 201}, {centerWidth, 179}, {centerWidth, 156}}   
        cityInfoBg.dialImg = dialImg    

        local tempWing = ccui.ImageView:create()
        tempWing:loadTexture("citybattle_wing2.png",1)
        tempWing:setPosition(cityInfoBg:getContentSize().width * 0.5, cityInfoBg:getContentSize().height - 10)
        tempWing:setVisible(false)
        cityInfoBg:addChild(tempWing, 7)
        cityInfoBg.tempWing = tempWing

        local tempImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp47.png")
        tempImg:setAnchorPoint(0.5, 0.5)
        tempImg:setPosition(cityInfoBg:getContentSize().width * 0.5, 0)
        cityInfoBg:addChild(tempImg,100)    

        local tempImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp44.png")
        tempImg:setAnchorPoint(0.5, 0.5)
        tempImg:setScaleX(-1)
        tempImg:setPosition(5, cityInfoBg:getContentSize().height * 0.5 + 40)
        cityInfoBg:addChild(tempImg,1)   

 
        local tempImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp44.png")
        tempImg:setAnchorPoint(0.5, 0.5)
        tempImg:setPosition(cityInfoBg:getContentSize().width - 5, cityInfoBg:getContentSize().height * 0.5 + 40)
        cityInfoBg:addChild(tempImg)   

    end
    cityInfoBg.tempWing:setVisible(false)
    cityInfoBg.tempWing:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function()
                cityInfoBg.tempWing:setVisible(true)
                -- cityInfoBg.tempMc:gotoAndPlay(1)
            end)
            ))
    return cityInfoBg        
end

--[[
--! @function updateInfoPanel2
--! @desc 更新大城池面板信息
--！@param inCintyInfo 城池信息
--]]
function CityBattleWorldLayer:updateInfoPanel1(inCintyInfo)
    local cityInfoBg = self._parentView:getChildByName("cityInfoBg3")
    if cityInfoBg == nil then 
        cityInfoBg = cc.Sprite:createWithSpriteFrameName("citybattle_view_panel_level3.png")
        cityInfoBg:setName("cityInfoBg3")
        self._parentView:addChild(cityInfoBg, 100)    

        

        local tempImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp37.png")
        tempImg:setAnchorPoint(0.5, 1)
        tempImg:setName("dialImg")
        tempImg:setPosition(20, cityInfoBg:getContentSize().height * 0.5 + 40)
        cityInfoBg:addChild(tempImg, -1)    

        local tempImg1 = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp37.png")
        tempImg1:setScaleX(-1)
        tempImg1:setAnchorPoint(0.5, 1)
        tempImg1:setName("dialImg")
        tempImg1:setPosition(cityInfoBg:getContentSize().width - 20, cityInfoBg:getContentSize().height * 0.5 + 40)
        cityInfoBg:addChild(tempImg1, -1)

        local dialImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_panel_front1.png")
        dialImg:setName("dialImg")
        dialImg:setPosition(cityInfoBg:getContentSize().width * 0.5, cityInfoBg:getContentSize().height * 0.5)
        cityInfoBg:addChild(dialImg)    

        local centerWidth = cityInfoBg:getContentSize().width * 0.5
        cityInfoBg.battleInfoPos = {{centerWidth, 185}, {centerWidth, 163}, {centerWidth, 128}}    
        cityInfoBg.mainInfoPos = {{centerWidth, 193}, {centerWidth, 169}, {centerWidth, 145}, {centerWidth, 122}}     
        cityInfoBg.dialImg = dialImg
        -- local tempMc = mcMgr:createViewMC("gaojichibang3_citybattlechengchidianji", false, false)
        -- tempMc:setPosition(cityInfoBg:getContentSize().width * 0.5, cityInfoBg:getContentSize().height - 10)
        -- tempMc:setName("bosseffet")
        -- tempMc:addCallbackAtFrame(tempMc:getTotalFrames(), function()
        --     tempMc:stop()
        -- end)
        -- tempMc:stop()
        -- cityInfoBg:addChild(tempMc, 7)
        -- cityInfoBg.tempMc = tempMc

        local tempWing = ccui.ImageView:create()
        tempWing:loadTexture("citybattle_wing1.png",1)
        tempWing:setPosition(cityInfoBg:getContentSize().width * 0.5, cityInfoBg:getContentSize().height - 10)
        tempWing:setVisible(false)
        cityInfoBg:addChild(tempWing, 7)
        cityInfoBg.tempWing = tempWing


        local tempImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp45.png")
        tempImg:setAnchorPoint(0.5, 0.5)
        tempImg:setPosition(cityInfoBg:getContentSize().width * 0.5, 0)
        cityInfoBg:addChild(tempImg,100)    

        local tempImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp46.png")
        tempImg:setAnchorPoint(0.5, 0.5)
        tempImg:setScaleX(-1)
        tempImg:setPosition(5, cityInfoBg:getContentSize().height * 0.5 + 40)
        cityInfoBg:addChild(tempImg,1)   

 
        local tempImg = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp46.png")
        tempImg:setAnchorPoint(0.5, 0.5)
        tempImg:setPosition(cityInfoBg:getContentSize().width - 5, cityInfoBg:getContentSize().height * 0.5 + 40)
        cityInfoBg:addChild(tempImg)   
               

        
    end

    cityInfoBg.tempWing:setVisible(false)
    cityInfoBg.tempWing:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function()
                cityInfoBg.tempWing:setVisible(true)
                -- cityInfoBg.tempWing:gotoAndPlay(1)
            end)
            ))
    return cityInfoBg         
end

--[[
    统计id,_type send发消息，其他收消息
]]
function CityBattleWorldLayer:countMessage(id,_type)
    if not OS_IS_WINDOWS then
        return
    end
    if not id then return end
    if _type == "send" then
        if not self._messageLoseCheckList[id] then
            self._messageLoseCheckList[id] = {count = 1}
        else
            self._messageLoseCheckList[id].count = self._messageLoseCheckList[id].count + 1
        end
    else
        self._messageLoseCheckList[id].count = self._messageLoseCheckList[id].count - 1
    end
end

--[[
    打印消息日志
]]
function CityBattleWorldLayer:printMessageLog()
    if not OS_IS_WINDOWS then
        return
    end
    for messageKey,data in pairs (self._messageLoseCheckList) do 
        print("messageKey:",messageKey,"count:",count)
    end
end


--[[
--! @function getPlayerFormation
--! @desc 获取编组状态
--！@param callback 回调
--]]
function CityBattleWorldLayer:getPlayerFormation()
    print("callback=================", callback)
    local cityData = self._cityBattleModel:getData()
    local params = {}
    params._m = "1"
    self._parentView:lock(-1)
    -- if self._schedule then
    --     ScheduleMgr:unregSchedule(self._schedule)
    --     self._schedule = nil
    -- end
    -- self._schedule = ScheduleMgr:regSchedule(5000,self,function( )
    --     if self._parentView then
    --         self._parentView:clearLock()
    --     end
    -- end)
    self._cityBattleModel:addSendCallback(10005, function(result, error)
        self:countMessage("getPlayerFormation")
        self._parentView:unlock()
        self._parentView:clearLock()
        print("CityBattleWorldLayer:getPlayerFormation2")
        -- if self._schedule then
        --     ScheduleMgr:unregSchedule(self._schedule)
        --     self._schedule = nil
        -- end
    end)
    self:countMessage("getPlayerFormation","send")
    self:sendSocketMgs("getPlayerFormation", params or {})
end



function CityBattleWorldLayer:upGVGBattleInfo(inFms, inCityId, callback)
    -- 检查城池是否处于废墟状态
    local cityInfos = self._cityBattleModel:getData().c.c
    local cityInfo = cityInfos[tostring(inCityId)]
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime() 
    if cityInfo.t ~= nil and cityInfo.t > curTime then 
        self._viewMgr:showTip(lang("CITYBATTLE_TIP_16"))
        return false
    end
    self._serverMgr:sendMsg("CityBattleServer", "upGVGBattleInfo", {fids = inFms}, true, {}, function (result, error)
        if error ~= 0 then self._viewMgr:showTip("派遣失败")  return end
        if callback ~= nil then callback() end
    end)
end


--[[
--! @function enterRoom
--! @desc 取消派遣
--！@param inFid 编组id
--！@param callback 回调
--]]
function CityBattleWorldLayer:enterRoom(params, callback)
    params.rid = self._userModel:getData()._id
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId 
    params.gid = 0
    if guildId ~= nil and guildId > 0 then  
        params.gid = guildId
    end
    params._m = "1"
    self._cityBattleModel:addSendCallback(10002, function(result, error)
        if callback ~= nil then callback(result, error) end
    end)
    self:sendSocketMgs("enterRoom", params or {})
end


--[[
--! @function leaveRoom
--! @desc 取消派遣
--！@param inFid 编组id
--！@param callback 回调
--]]
function CityBattleWorldLayer:leaveRoom(inFid, callback)
    print("callback=================", callback)
    local cityData = self._cityBattleModel:getData()
    print("inFid============", inFid)
    dump(cityData["f"], "test", 10)
    local params = {}
    params.cid = cityData["f"][tostring(inFid)].cid
    params.fid = inFid
    params._m = "1"
    self._cityBattleModel:addSendCallback(10003, function(result, error)
        if callback ~= nil then callback(result, error) end
    end)
    self:sendSocketMgs("leaveRoom", params or {})
end


-- 发送协议
function CityBattleWorldLayer:sendSocketMgs(name, params)
    params.mapId = self._cityBattleModel:getMapId()
    params.rid = self._userModel:getData()._id
    params.name = self._userModel:getData().name
    params.sec = self._cityBattleModel:getMineSec()
    ServerManager:getInstance():RS_sendMsg("PlayerProcessor", name, params or {})
end

--[[
--! @function locateCity
--! @desc 定位城市
--！@param inCintyInfo 城池信息
--]]
function CityBattleWorldLayer:locateCity(inCityId)
    self:screenToCity(inCityId, function()
        local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. inCityId)
        if cityIconBg ~= nil then 
            local runTime = 0
            local jiantouMc = mcMgr:createViewMC("jiantou_intancejiantou", true, true)
            jiantouMc:addCallbackAtFrame(jiantouMc:getTotalFrames() - 1, function(_, sender)
                if runTime < 1 then
                    sender:gotoAndPlay(1)
                    runTime = runTime + 1
                end
            end)
            jiantouMc:setPosition(cityIconBg:getContentSize().width * 0.5, cityIconBg:getContentSize().height + 50)
            cityIconBg:addChild(jiantouMc, 1000)
        end
    end)
end


function CityBattleWorldLayer:activeFallTipShow()
    if #self._cityFallTips <= 0 then 
        return 
    end
    if self._actionCityFall == true then return end
    self._actionCityFall = true
    local lastId = self._cityFallTips[#self._cityFallTips]
    table.remove(self._cityFallTips, #self._cityFallTips)
    local fallTip = self._parentView:getChildByName("fall_tip")
    local cityInfos = self._cityBattleModel:getData().c.c
    local cityInfo = cityInfos[tostring(lastId)]
    local serverColor = occupyColorPlan[cityInfo.b] or 4

    local cityIconBg = self._bgLayer:getChildByName("cityIconBg" .. lastId)
    if cityIconBg == nil or cityIconBg.discardSp == nil or cityIconBg.isRunFallTip == true then return end
    
    cityIconBg.isRunFallTip = true
    if fallTip == nil then 
        local sysCityBattle = tab.cityBattle[tonumber(lastId)]
        fallTip = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp42.png")
        fallTip:setAnchorPoint(0.5, 0.5)
        fallTip:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        self._parentView:addChild(fallTip, 1000)
        -- fallTip:setOpacity(0)
        -- 大本营服务器信息
        if fallTip.serverInfo == nil then
            local tips1 = {}
            tips1[1] = cc.Sprite:createWithSpriteFrameName("citybattle_view_temp43.png")
            local serverImage = cc.Sprite:createWithSpriteFrameName(serverSmallImage[serverColor] .. ".png")
            serverImage:setPosition(tips1[1]:getContentSize().width * 0.5, tips1[1]:getContentSize().height * 0.5)
            tips1[1]:addChild(serverImage)
            tips1[2] = cc.Label:createWithTTF("“" .. lang(sysCityBattle.name) .. "“", UIUtils.ttfName, 30)
            tips1[3] = cc.Label:createWithTTF(" 已被攻陷", UIUtils.ttfName, 30)
            tips1[2]:setColor(UIUtils.colorTable.ccUIBasePromptColor)
            tips1[3]:setColor(UIUtils.colorTable.ccUIBasePromptColor)

            local nodeTip1 = UIUtils:createHorizontalNode(tips1, cc.p(0, 0.5))
            nodeTip1:setAnchorPoint(cc.p(0.5, 0.5))
            nodeTip1:setPosition(fallTip:getContentSize().width * 0.5, fallTip:getContentSize().height * 0.5 - 2)
            fallTip:addChild(nodeTip1)   
            fallTip.serverInfo = nodeTip1
            fallTip.serverInfoWidget = tips1
            fallTip.serverImage = serverImage
        end
        fallTip.serverImage:setSpriteFrame(serverSmallImage[serverColor] .. ".png")
        fallTip.serverInfoWidget[2]:setString("\"" .. lang(sysCityBattle.name) .. "\"")
        UIUtils:alignHorizontalNode(fallTip.serverInfo, fallTip.serverInfoWidget, nil, nil, 2, nil, false)
        fallTip.serverInfoWidget[1]:setPositionY(fallTip.serverInfoWidget[1]:getPositionY() + 2)
    end
    fallTip:setCascadeOpacityEnabled(true, true)
    fallTip:setOpacity(0)
    fallTip:setScale(0)
    fallTip:runAction(cc.Sequence:create(
        cc.EaseIn:create(cc.Spawn:create(
                cc.FadeIn:create(0.2),
                cc.ScaleTo:create(0.2, 1, 1)
            ), 0.1),
        cc.DelayTime:create(1),
        cc.Spawn:create(
                    cc.FadeOut:create(0.1),
                    cc.ScaleTo:create(0.1, 0, 0)
                ),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()
            self._actionCityFall = false
            self:activeFallTipShow()
        end)
        ))
    local tempMc = mcMgr:createViewMC("zitiguang_kaiqi", false, true)
    tempMc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    self._parentView:addChild(tempMc, 1000)
end


--[[
--! @function screenToCity
--! @desc 镜头移动到某个城市
--！@param inCintyInfo 城池信息
--]]
function CityBattleWorldLayer:screenToCity(inCityId, inCallback)
    print("screenToCity==============", inCityId)
    local sysCityBattleMap = tab:CityBattleMap(tonumber(inCityId))
    if sysCityBattleMap == nil then return end

    self:screenToPos(sysCityBattleMap.citypoint[1], sysCityBattleMap.citypoint[2], true, inCallback, nil, nil, 0.4)
end

function CityBattleWorldLayer:onTouchesMovedEx()
    return self._touchesMovedEx
end

function CityBattleWorldLayer:getMaxScrollHeightPixel()
    return 2000
end

function CityBattleWorldLayer:getMaxScrollWidthPixel()
    return 2000
end

function CityBattleWorldLayer:getMinScale()
    return 1
end

function CityBattleWorldLayer:getMaxScale()
    return 1
end

function CityBattleWorldLayer.dtor()
    areaMaskColor = nil

    cityStateColor = nil

    occupyColorPlan = nil

    cityHeroIconPos = nil

    iconPos = nil


    cityStateColor = nil

    nameColor = nil

    serverNum = nil

end


return CityBattleWorldLayer