--[[
    Filename:    GuildMiniMapView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-16 11:39:45
    Description: File description
--]]

local GuildMiniMapView = class("GuildMiniMapView", BasePopView, require("game.view.guild.GuildBaseView"))

function GuildMiniMapView:ctor(data)
    self._miniMapImg =  data.mapImg
    self._mapTable =  data.mapTable
    GuildMiniMapView.super.ctor(self)

end


function GuildMiniMapView:onInit( ... )
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMiniMapView")
        elseif eventType == "enter" then 
        end
    end)    
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(180)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(bgLayer)
    self:registerClickEvent(bgLayer, function ()
        self:close()
    end)

    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    
    self._bgSprite = cc.Sprite:createWithSpriteFrameName(self._miniMapImg ..".png")
    self._bgSprite:setPosition(self:getContentSize().width/2, self:getContentSize().height/2 - 58)

    self:addChild(self._bgSprite)


    print("GuildConst.GUILD_MAP_MINI_MAX_WIDTH===", GuildConst.GUILD_MAP_MINI_MAX_WIDTH,GuildConst.GUILD_MAP_MINI_MAX_HEIGHT )
    self._miniSprite = cc.Sprite:create()
    self._miniSprite:setContentSize(GuildConst.GUILD_MAP_MINI_MAX_WIDTH, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT)
    self._miniSprite:setScale(0.1995)
    self._miniSprite:setPosition(220, 230)
    self._miniSprite:setAnchorPoint(0, 0)

    -- local bgLayer = ccui.Layout:create()
    -- bgLayer:setBackGroundColorOpacity(180)
    -- bgLayer:setBackGroundColorType(1)
    -- bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    -- bgLayer:setTouchEnabled(false)
    -- bgLayer:setContentSize(GuildConst.GUILD_MAP_MINI_MAX_WIDTH, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT)
    -- self._miniSprite:addChild(bgLayer)
    self._bgSprite:addChild(self._miniSprite)


    self._guildId = self._modelMgr:getModel("UserModel"):getData().guildId

    self._userId = self._modelMgr:getModel("UserModel"):getData()._id

    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")

    self._shapes = self._guildMapModel:getShapes()



    local backMapList = self._guildMapModel:getData().mapList

    self._userList = self._guildMapModel:getData().userList


    local selfPoint = self._guildMapModel:getData().selfPoint
    if selfPoint ~=  nil  then 
        local myselfGridData = self._shapes[selfPoint]
        if myselfGridData ~= nil then 
            local pointTip = mcMgr:createViewMC("jiantou_intancejiantou", true)
            pointTip:setPosition(myselfGridData.pos.x, myselfGridData.pos.y + 136)
            pointTip:setScale(3)
            self._miniSprite:addChild(pointTip, 112)

            local pointTip1 = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp11.png")
            pointTip1:setPosition(myselfGridData.pos.x, myselfGridData.pos.y)
            pointTip1:setScale(3)
            self._miniSprite:addChild(pointTip1)
        end
    end

    local fogs = self._guildMapModel:getData().fogs
    for k,v in pairs(self._shapes) do
        local guildMap = tab[self._mapTable]
        local sysGuildMap = guildMap["b" .. v.grid.b]
        local mapInfo = backMapList[k]
        if backMapList[k] ~= nil and k ~= selfPoint then 
            local mapItem
            if mapInfo ~= nil then 
                if mapInfo.guild ~= nil then 
                    mapItem = mapInfo.guild
                    typeName = GuildConst.ELEMENT_TYPE.GUILD
                elseif mapInfo.common ~= nil then 
                    
                    mapItem = mapInfo.common
                    typeName = GuildConst.ELEMENT_TYPE.COMMON
                elseif mapInfo.my ~= nil then
                    mapItem = mapInfo.my
                    typeName = GuildConst.ELEMENT_TYPE.MY
                end
            end

            if (mapItem ~= nil and  mapItem.eid ~= nil) then
                local sysGuildMapThing = tab.guildMapThing[tonumber(mapItem.eid)] 
                if  sysGuildMapThing.mini ~= nil then 
                    local playerPoint = cc.Sprite:createWithSpriteFrameName(sysGuildMapThing.mini .. ".png")
                    playerPoint:setPosition(v.pos.x, v.pos.y)
                    playerPoint:setAnchorPoint(0.5, 0)
                    playerPoint:setScale(1 / self._miniSprite:getScale())
                    self._miniSprite:addChild(playerPoint, 100 + (v.grid.a + v.grid.b))                
                end
            end     
            if not (sysGuildMap["a" .. v.grid.a] ~= nil and fogs[k] == 1 ) then 
                if backMapList[k].player ~= nil and backMapList[k].player[self._userId] == nil then 
                    self:updateMapPlayer(k, v, backMapList[k].player)
                end
            end
        end
    end


    local buildingAnim = mcMgr:createViewMC("jianzhuguangxiao_intancebuildingeffect-HD", true, false)
    buildingAnim:setCascadeOpacityEnabled(true, true)
    buildingAnim:setOpacity(0)
    buildingAnim:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT +20)
    buildingAnim:setPlaySpeed(0.1, true)
    buildingAnim:setScaleY(0.8)
    buildingAnim:setScaleX(1.2)
    self:addChild(buildingAnim)
    buildingAnim:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.FadeIn:create(0.5)))
    buildingAnim:getChildren()[1]:setVisible(false)
    -- local x, y = buildingAnim:getChildren()[1]:getPosition()
    -- print("x=====================================",x, y)
    -- buildingAnim:getChildren()[1]:setPosition(x -200, y -100)
end



function GuildMiniMapView:updateMapPlayer(inGridKey, inGrid, inMapPlayer)
    if inMapPlayer == nil or next(inMapPlayer) == nil then 
        return 
    end
    local userId, temppara = next(inMapPlayer)
    if self._userList[userId] == nil then 
        return
    end
    if tostring(self._userList[userId].guildId) ~= tostring(self._guildId) then 
        local playerPoint = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp12.png")
        playerPoint:setPosition(inGrid.pos.x, inGrid.pos.y)
        playerPoint:setScale(3)
        self._miniSprite:addChild(playerPoint, 300 + (inGrid.grid.a + inGrid.grid.b))

    else
        local playerPoint = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp13.png")
        playerPoint:setPosition(inGrid.pos.x, inGrid.pos.y)
        playerPoint:setScale(3)
        self._miniSprite:addChild(playerPoint, 200 + (inGrid.grid.a + inGrid.grid.b))
    end
end


return GuildMiniMapView