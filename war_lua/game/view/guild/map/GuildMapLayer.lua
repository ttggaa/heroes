--[[
    Filename:    GuildMapLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-04 14:28:20
    Description: File description
--]]

local MapLayer = require "game.view.guild.map.MapLayer"
local GuildMapLayer = class("GuildMapLayer", MapLayer)

-- 层级位置
-- 1000 为大地图迷雾遮罩
-- 100 + 格子id 为原件

function GuildMapLayer:ctor(inData)
    self._parentView = inData.parent
    self._settingData = inData.setting

    GuildMapLayer.super.ctor(self)

    self._isTagTouch = false
    
    self:setName("GuildMapLayer")
    self:setClassName("GuildMapLayer")
end

function GuildMapLayer:onInit()
    require("game.view.guild.map.GuildMapListen")
    require("game.view.guild.map.GuildMapEvent")
    require("game.view.guild.map.GuildMapEffect")

    GuildConst.GUILD_MAP_MINI_MAX_WIDTH = self:getMaxScrollWidthPixel()

    GuildConst.GUILD_MAP_MINI_MAX_HEIGHT = self:getMaxScrollHeightPixel()
    
    print("GuildConst.GUILD_MAP_MINI_MAX_WIDTH========", GuildConst.GUILD_MAP_MINI_MAX_WIDTH)

    self._playerIndex = 1
    self._battleTips = {}

    GuildMapLayer.super.onInit(self)

    self._floorLayer = cc.Layer:create()
    self._bgSprite:addChild(self._floorLayer, 5)
    self._floorLayer:setContentSize(GuildConst.GUILD_MAP_MINI_MAX_WIDTH, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT)
    
    self._fogLayer = cc.Layer:create()
    self._bgSprite:addChild(self._fogLayer, 1000)
    self._fogLayer:setContentSize(GuildConst.GUILD_MAP_MINI_MAX_WIDTH, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT)
    
    if GuildConst.SHOW_TIP_GRID or GuildConst.SHOW_NOT_GO_GRID then 
        for k,v in pairs(self._shapes) do
            local state = self:getGridState(v.grid.a, v.grid.b)
            local temp 
            if state == 1 and GuildConst.SHOW_TIP_GRID == true then
                temp = cc.Sprite:create("asset/dev/guildMapImg_temp1.png")
                temp:setScale(self._intScale)
                temp:setPosition(v.pos.x, v.pos.y)
                self._bgSprite:addChild(temp)
            elseif state ~= 1 and GuildConst.SHOW_NOT_GO_GRID == true then
                temp = cc.Sprite:create("asset/dev/guildMapImg_temp10.png")
                temp:setPosition(v.pos.x, v.pos.y)
                temp:setOpacity(100)
                -- temp:setColor(cc.c3b(255,23,23))
                self._bgSprite:addChild(temp)     
            end
        end 
    end
    if GuildConst.SHOW_GRID_ID then 
        for k,v in pairs(self._shapes) do
            local memLabel = cc.Label:createWithTTF(k, UIUtils.ttfName, 20)
            memLabel:setPosition(v.pos.x, v.pos.y)
            memLabel:setAnchorPoint(0.5, 0.5)
            memLabel:setColor(cc.c3b(255, 255, 255))
            memLabel:enableOutline(cc.c4b(0,0,0,255), 1)
            self._bgSprite:addChild(memLabel)
            memLabel:setOpacity(100)
        end
    end

    if self._settingData.cloudImg ~= nil then
        local tempSprite = cc.Sprite:createWithSpriteFrameName(self._settingData.cloudImg ..".png")
        tempSprite:setPosition(self._bgSprite:getContentSize().width/2, self._bgSprite:getContentSize().height/2)
        tempSprite:setAnchorPoint(cc.p(0.5, 0.5)) 
        tempSprite:setScale((2.9674))
        self._bgSprite:addChild(tempSprite, 99)
    end

    self._userId = self._modelMgr:getModel("UserModel"):getData()._id
    self._guildId = self._modelMgr:getModel("UserModel"):getData().guildId

    -- 防止瞬间点击
    self._lockGrid = {}

    self._safeArea = {}
    local safeArea = self._settingData.safeArea or {}
    for k,v in pairs(safeArea) do
        self._safeArea[v] = 1
    end

    self._centerSafeArea = {}
    local centerSafeArea = self._settingData.centerSafeArea or {}
    for k, v in pairs(centerSafeArea) do
        if self._centerSafeArea[k] == nil then 
            self._centerSafeArea[k] = {}
        end
        for k1, v1 in pairs(v) do
           self._centerSafeArea[k][v1[1] .. "," .. v1[2]] = 1
        end
        
    end
    
    self._currentGuildId = self._guildMapModel:getData().currentGuildId 

    -- 玩家计时队列
    self._playerTimngQueue = {}

    self._eleTimngQueue = {}


    self._userMcs = {}
    self._userGridKeys = {}

    self._lastCountDownEleTime = -1
    self._lastCountDownPlayerTime = -1

    self._gridElements = {}
    self._gridPlayers = {}
    self._mcfps =  {}


    self:initElement()


    local selfPoint = self._guildMapModel:getData().selfPoint

    if selfPoint ~= nil then 
        self._curGrid = self._shapes[selfPoint].grid
        self:updateMySelfState()
        self:updateGuideArrow()
        self:moveToGridByMyself(self._curGrid.a, self._curGrid.b, false, true)
    else
        if self._currentGuildId ~= "center" then
            self:screenToGrid(4, 17, false)
        end
    end
    self:showCommonEffect()

    if self._mapLayerUpdateId ~= nil then 
        ScheduleMgr:unregSchedule(self._mapLayerUpdateId)
        self._mapLayerUpdateId = nil
    end

    self._mapLayerUpdateId = ScheduleMgr:regSchedule(1000, self, function(self, dt)
        self:updateTimngQueue()
    end)

    -- 针对不同地图处理当前玩家各自缩放值
    if self._settingData.isCenter == true then
        for i=1,6 do
            if self._nearPic[i] ~= nil then
                self._nearPic[i]:setScale(1.1)
            end
        end

        if self._curPlayerMc ~= nil then 
            self._curPlayerMc:setScale(1.1)
        end
    else
        for i=1,6 do
            if self._nearPic[i] ~= nil then
                self._nearPic[i]:setScale(1)
            end
        end

        if self._curPlayerMc ~= nil then 
            self._curPlayerMc:setScale(1)
        end
    end
end

function GuildMapLayer:onExit()
    GuildMapLayer.super.onExit(self)
    if self._mapLayerUpdateId ~= nil then 
        ScheduleMgr:unregSchedule(self._mapLayerUpdateId)
        self._mapLayerUpdateId = nil
    end
    ScheduleMgr:cleanMyselfDelayCall(self)   
    if OS_IS_WINDOWS then
        package.loaded["game.view.guild.map.MapLayer"] = nil
        package.loaded["game.view.guild.map.GuildMapListen"] = nil
        package.loaded["game.view.guild.map.GuildMapEvent"] = nil
        package.loaded["game.view.guild.map.GuildMapEffect"] = nil   
    end
    UIUtils:reloadLuaFile("guild.map.GuildMapLayer") 
end


function GuildMapLayer:updateMySelfHeroMc()
    if self._intanceMcAnimNode == nil or self._intanceMcAnimNode.heroId == nil then
        return
    end
    
    local formationModel = self._modelMgr:getModel("FormationModel")
    local heroID = formationModel:getFormationDataByType(formationModel.kFormationTypeGuild).heroId   

    if self._intanceMcAnimNode.heroId == heroID then 
        return
    end
    local userId = self._intanceMcAnimNode.userId
    self._userMcs[userId] = nil
    self._playerTimngQueue[userId] = nil
    self._intanceMcAnimNode:removeFromParent(true)
    self._intanceMcAnimNode = nil
    self:updateMySelfState()
    self:updateGuideArrow()
end


function GuildMapLayer:updateMySelfState()
    local curGridKey = self._curGrid.a .. "," .. self._curGrid.b

    local tempGrid = self._shapes[curGridKey]

    local formationModel = self._modelMgr:getModel("FormationModel")
    local heroID = formationModel:getFormationDataByType(formationModel.kFormationTypeGuild).heroId

    local heroModel = self._modelMgr:getModel("HeroModel")
    local userHeroData = heroModel:getHeroData(heroID)
    local heroart
    if userHeroData.skin ~= nil then 
        local heroSkinD = tab.heroSkin[userHeroData.skin]
        heroart =  heroSkinD.heroart
    end
    if heroart == nil then
        local sysHero = tab:Hero(heroID)
        if sysHero == nil then 
            sysHero = tab:NpcHero(heroID)
        end
        heroart = sysHero.heroart
    end

    self._intanceMcAnimNode = self:createHeroMc(1, heroart, self._modelMgr:getModel("UserModel"):getData().name, self._userId, self._guildId)

    self._intanceMcAnimNode:setPosition(tempGrid.pos.x, tempGrid.pos.y)

    self._bgSprite:addChild(self._intanceMcAnimNode, 100 + (self._curGrid.a + self._curGrid.b))

    self._intanceMcAnimNode.heroId = heroID

    self._userGridKeys[self._userId] = curGridKey

    local userList = self._guildMapModel:getData().userList
    local userInfo = userList[self._userId]

    --传送动画  wangyan
    if self._guildMapModel:getTransferState() == true then
        local order = self._intanceMcAnimNode:getLocalZOrder()
        local backcity3 = mcMgr:createViewMC("huicheng3_guildmaphuicheng", false, true, function() end)
        backcity3:setPosition(self._intanceMcAnimNode:getPosition())
        self._bgSprite:addChild(backcity3, order - 1)
        local backcity4 = mcMgr:createViewMC("huicheng4_guildmaphuicheng", false, true, function() end)                                                                                                                                                            
        self._bgSprite:addChild(backcity4, order + 1)
        backcity4:setPosition(self._intanceMcAnimNode:getPosition())

        self._guildMapModel:setTransferState(false)
    end  
    
    self:handlePlayerTimngQueue(self._userId, curGridKey, userInfo)
end

function GuildMapLayer:initFogs()
    -- if self._shadowTexture ~= nil then 
    --     self._shadowTexture:removeFromParent()
    --     self._shadowTexture = nil
    -- end

    local tempBuildShapes = {}
    if self._currentGuildId ~= "center" and not GuildConst.HIDE_FOG then
        local backMapList = self._guildMapModel:getData().mapList
        -- self._shadowTexture = cc.RenderTexture:create(GuildConst.GUILD_MAP_MINI_MAX_WIDTH * 0.5, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT * 0.5, RGBART)
        -- self._shadowTexture:setPosition(GuildConst.GUILD_MAP_MINI_MAX_WIDTH * 0.5, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT * 0.5)
        -- self._shadowTexture:getSprite():setOpacity(80)
        -- self._shadowTexture:getSprite():getTexture():setAntiAliasTexParameters()
        -- self._bgSprite:addChild(self._shadowTexture)
        -- self._shadowTexture:getSprite():setScale(2)
        -- self._shadowLayer = cc.Layer:create()
        -- self._shadowLayer:setContentSize(GuildConst.GUILD_MAP_MINI_MAX_WIDTH * 0.5, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT * 0.5)

        local fogs = self._guildMapModel:getData().fogs
        for k,v in pairs(self._shapes) do
            if fogs[k] == 1 then
                local sp = cc.Sprite:createWithSpriteFrameName("guildMapImg_fog.png")
                sp:setAnchorPoint(cc.p(0.5, 0.5))
                sp:setPosition(v.pos.x, v.pos.y)
                sp:setOpacity(80)
                sp:setScale(2)
                -- self._shadowLayer:addChild(sp, 99) 
                -- sp:setBlendFunc({src = gl.ZERO, dst = gl.ONE_MINUS_SRC_ALPHA})
                sp.gridKey = k
                self._gridFogs[k] = sp
                self._bgSprite:addChild(sp, 300)
            end
            if backMapList[k] ~= nil then 
                tempBuildShapes[k] = v
            end
        end
        -- self._shadowTexture:beginWithClear(0, 0, 0, 0)
        -- self._shadowLayer:visit()
        -- self._shadowTexture:endToLua()
    end
    return tempBuildShapes
end

function GuildMapLayer:initEnableTag()
    for k,v in pairs(self._shapes) do
        local state = self:getGridState(v.grid.a, v.grid.b)
        if state == 1 and self._gridFogs[k] == nil then
            local testSprite = cc.Sprite:createWithSpriteFrameName("guild_map_test.png")
            testSprite:setPosition(v.pos)
            testSprite:setOpacity(90)
            testSprite:setName("tag_"..k)
            self._bgSprite:addChild(testSprite, 8)
        end
    end
end

function GuildMapLayer:removeEnableTag()
    for k,v in pairs(self._shapes) do
        local tagObj = self._bgSprite:getChildByName("tag_"..k)
        if tagObj then
            tagObj:removeFromParent(true)
            tagObj = nil
        end
    end
end


function GuildMapLayer:initEnableYearTrans()
	local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
	local currentGuildId = self._guildMapModel:getData().currentGuildId
	local ignoreSafeArea = tostring(currentGuildId)~="center" and tostring(currentGuildId)~=tostring(guildId)
	for i,v in pairs(self._shapes) do
		local state = self:getGridState(v.grid.a, v.grid.b)
        if state==1 and self._gridFogs[i]==nil and self._gridElements[i]==nil then
			if ignoreSafeArea then
				if not self._safeArea[i] then
					local testSprite = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp9.png")
					testSprite:setPosition(v.pos)
					testSprite:setName("yearTrans_"..i)
					self._bgSprite:addChild(testSprite, 8)
				end
			else
				local testSprite = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp9.png")
				testSprite:setPosition(v.pos)
				testSprite:setName("yearTrans_"..i)
				self._bgSprite:addChild(testSprite, 8)
			end
        end
	end
end
function GuildMapLayer:removeEnableYearTrans()
	for k,v in pairs(self._shapes) do
        local tagObj = self._bgSprite:getChildByName("yearTrans_"..k)
        if tagObj then
            tagObj:removeFromParent(true)
            tagObj = nil
        end
    end
end

function GuildMapLayer:initElement()
    local backMapList = self._guildMapModel:getData().mapList
    local userList = self._guildMapModel:getData().userList
    
    local tempBuildShapes = self:initFogs()

    if table.nums(tempBuildShapes) == 0 then 
        tempBuildShapes = self._shapes
    end

    for k,v in pairs(tempBuildShapes) do
        if backMapList[k] ~= nil then
            local sysGuildMapThing = self:updateMapEle(k, v, backMapList[k])
            -- if sysGuildMapThing == nil or sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.CITY then
            self:initMapPlayer(k, v, backMapList[k].player, userList)
            -- end
        end
    end
    -- self:initHill()
    self:createTagElement()
end

--[[
--! @function initHill
--! @desc 初始化裝飾物
--! @return 
--]]
function GuildMapLayer:initHill()
    if self._settingData.decorate == nil then 
        return
    end
    -- local sfc = cc.SpriteFrameCache:getInstance()
    -- sfc:addSpriteFrames("asset/ui/" .. self._settingData.decoratePlist .. ".plist", "asset/ui/" .. self._settingData.decoratePlist .. ".png")
    local hills = tab[self._settingData.decorate]
    -- local hills = tab.guildMapDecorate
    for k,v in pairs(hills) do
        local sp = cc.Sprite:createWithSpriteFrameName(v.pic .. ".png")
        -- local gridKeyData = string.split(k, ",")
        local gridData = self._shapes[k]
        sp:setPosition(gridData.pos.x, gridData.pos.y)
        self._bgSprite:addChild(sp, 100 + gridData.grid.a + gridData.grid.b)
    end
end


function GuildMapLayer:updateGuideArrow()
    self._guideArrow:removeAllChildren()

    if self._intanceMcAnimNode == nil or self._intanceMcAnimNode.heroId == nil then
        return
    end
    local heroIconCircle = cc.Sprite:createWithSpriteFrameName("guildMapBtn_heroIconCircle.png")
    self._guideArrow:setContentSize(heroIconCircle:getContentSize().width, heroIconCircle:getContentSize().height)
    heroIconCircle:setPosition(heroIconCircle:getContentSize().width/2, heroIconCircle:getContentSize().height/2)
    self._guideArrow:addChild(heroIconCircle, 5)

    local headWidget = ccui.Widget:create()
    headWidget:setPosition(35,35)
    headWidget:setAnchorPoint(cc.p(0.5, 0.5))
    headWidget:setName("headClip")
    self._guideArrow:addChild(headWidget, 4)
    
    local sp = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. tab:Hero(self._intanceMcAnimNode.heroId).herohead .. ".jpg")


    local clipNode = cc.ClippingNode:create()
    clipNode:setInverted(false)

    local mask = cc.Sprite:createWithSpriteFrameName("guildMapBtn_iconMask.png")
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    clipNode:addChild(sp)
    headWidget:addChild(clipNode)
end

function GuildMapLayer:updateMap()
    -- 数据发生大变化，重新绘制页面
    if self._guildMapModel:getData().isReflashMap == true then 
        self._guildMapModel:getData().isReflashMap = false
        self._parentView:reflashView()
        return
    end
end

--[[
--! @function createHeroMc
--! @desc 创建地图英雄mc
--! @return 
--]]
function GuildMapLayer:createHeroMc(inType, inMcFileName, inName, inUserId, inGuildId)
    local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")

    local heroMc = nil
    if inType == 1 then 
        heroMc = IntanceMcAnimNode.new({"stop", "run2", "win", "run"}, inMcFileName,
        function(sender) 
        sender:runStandBy()
        end
        ,100,100,
        {"stop", "run2"},{{3,10},1})
    else
        heroMc = IntanceMcAnimNode.new({"stop", "win", "run"}, inMcFileName,
        function(sender) 
                sender:stop()
                sender:changeMotion(1, nil, true)
            end
            ,100,100,
            {"stop" },{{3,10},1}, false) 
    end
    heroMc.userId = inUserId
    heroMc.guildId = inGuildId
    heroMc:setScale(0.4)

    local nameBg = cc.Scale9Sprite:createWithSpriteFrameName("guildMapImg_nameBg.png")
    nameBg:setScale(2.5)
    nameBg:setPosition(0, 225)
    heroMc:addChild(nameBg, 30)
    nameBg:setOpacity(80)
        
    local nameLab = cc.Label:createWithTTF(inName, UIUtils.ttfName, 20) 
    local width = 92 
    if (nameLab:getContentSize().width + 60) > width then 
        width = nameLab:getContentSize().width + 60
    end
    nameBg:setContentSize(width, 30)

    nameLab:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2)
    nameBg:addChild(nameLab)
    if tostring(self._guildId) ~= tostring(inGuildId) then
        nameLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    else
        nameLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    end
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseTextColor2, 1)
    heroMc.nameBg = nameBg

    heroMc.runProgress = function()
        if heroMc.progress ~= nil then 
            return
        end
        local param = {}
        param.style = 1
        local progressNode = require("game.view.guild.map.ProgressNode").new(param)
        progressNode:setScale(2.5)
        progressNode:setAnchorPoint(0, 0.5)
        progressNode:setPosition(0, 305)
        heroMc:addChild(progressNode, 29)
        heroMc.progress = progressNode
        local directoin = -1
        if heroMc:getScaleX() > 0 then 
            directoin = 1
        end
        heroMc.progress:setScaleX(directoin * math.abs(heroMc.progress:getScaleX()))
    end

    heroMc.updateProgress = function(sender, inPercent)
        if heroMc.progress ~= nil then 
            heroMc.progress:updateProgress(inPercent)
        end
    end

    heroMc.stopProgress = function()
        if heroMc.progress ~= nil then 
            heroMc.progress:removeFromParent()
            heroMc.progress = nil
        end
    end

    heroMc.removeProgress = function()
        if heroMc.progress ~= nil then 
            heroMc.progress:removeFromParent()
            heroMc.progress = nil
        end
    end
    self._userMcs[inUserId] = heroMc
    return heroMc
end


--[[
--! @function initMapPlayer
--! @desc 更新地图玩家状态
--! @return 
--]]
function GuildMapLayer:initMapPlayer(inGridKey, inGrid, inMapPlayer, userList)
    if self._gridPlayers[inGridKey] == nil then 
        self._gridPlayers[inGridKey] = {}
    end
    if #self._gridPlayers[inGridKey] > 0 then 
        while true do
            if #self._gridPlayers[inGridKey] <= 0 then 
                break
            end
            self:removeUserByGridKeyAndUserId(inGridKey, self._gridPlayers[inGridKey][1].userId)
        end
        self._gridPlayers[inGridKey] = nil
    end

    if inMapPlayer == nil or next(inMapPlayer) == nil then
        return
    end
    local sortPlayer = {}
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    for k1,v1 in pairs(inMapPlayer) do
        local userInfo = userList[k1]
         -- 当前用户特殊处理
         if userInfo ~= nil and k1 ~= self._userId then
            -- 防止后端数据异常，造成下面的优先级比对报错
            
            sortPlayer[#sortPlayer + 1] = {userId = k1, skin = userInfo.skin, priority = tonumber(userInfo.mt), heroId = userInfo.heroId, name = userInfo.name, guildId = userInfo.guildId}
            if userInfo.mt == nil then
                sortPlayer[#sortPlayer].priority = 0 
            end
        end
    end
    local guildList = self._guildMapModel:getData().guildList
    -- 按时间排序优先级
    local comp = function(a,b) return a["priority"] > b["priority"] end
    table.sort(sortPlayer, comp)
    for k,v in pairs(sortPlayer) do
        local sysHero = tab.hero[v.heroId]
        if sysHero ~= nil and v.guildId ~= nil and guildList[tostring(v.guildId)] ~= nil then
            local heroart 
            if v.skin ~= nil then 
                local heroSkinD = tab.heroSkin[v.skin]
                heroart = heroSkinD.heroart
            end
            -- 如果没有走皮肤，则获取默认的
            if heroart == nil then
                heroart = sysHero.heroart
            end
            local heroMc = self:createHeroMc(2, heroart, v.name, v.userId, v.guildId)
            heroMc:setPosition(inGrid.pos.x, inGrid.pos.y)

            self._bgSprite:addChild(heroMc, 100 + (inGrid.grid.a + inGrid.grid.b))
            self._mcfps[#self._mcfps + 1]= heroMc
            -- self._gridPlayers[inGridKey] = heroMc
            heroMc:setVisible(false)
            heroMc.isLock = true

            self._gridPlayers[inGridKey][#self._gridPlayers[inGridKey] + 1] = heroMc

            self._userGridKeys[v.userId] = inGridKey
            -- 处理用户倒计时状态，我自己由updateMyselfState处理
            local userInfo = userList[v.userId]
            self:handlePlayerTimngQueue(v.userId, inGridKey, userInfo)


        end
    end

    local sysGuildMapThing 
    if self._gridElements[inGridKey] ~= nil then 
        sysGuildMapThing = tab.guildMapThing[tonumber(self._gridElements[inGridKey].eleId)]
    end

    if sysGuildMapThing ~= nil and 
        sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.CITY then
        for k,v in pairs(self._gridPlayers[inGridKey]) do
            v.isLock = true
            v:setVisible(false)
        end
    else
        local lastHero = self._gridPlayers[inGridKey][#self._gridPlayers[inGridKey]]
        if lastHero ~= nil then 
            lastHero.isLock = false
            lastHero:setVisible(true)
        end
    end
    
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    local showFriendHero = 0
    -- 迷雾下面需要隐藏
    if self._gridFogs[inGridKey] ~= nil then
        for k,v in pairs(self._gridPlayers[inGridKey]) do
            if tostring(v.guildId) ~= tostring(guildId) then
                v.isLock = true
                v:setVisible(false)
            elseif showFriendHero == 0 then 
                v.isLock = false
                v:setVisible(true)
                showFriendHero = 1
            end  
        end
    end
end


function GuildMapLayer:timeUpdate()
    self:wakeUpMcFPS()
end


--[[
--! @function wakeUpMcFPS
--! @desc 唤起英雄动画mc处理
--! @return 
--]]
function GuildMapLayer:wakeUpMcFPS() 
    local count = 0
    if not self._mcfps or #self._mcfps == 0 then return end
    while count < 2 do
        local heroMc = self._mcfps[self._playerIndex]
        if heroMc and heroMc.isVisible ~= nil and  heroMc:isVisible() then
            if heroMc:getCurrentFrame() == heroMc:getTotalFrames() then
                heroMc:gotoAndPlay(1)
            end
        end
        self._playerIndex = self._playerIndex + 1
        if self._playerIndex > #self._mcfps then self._playerIndex = 1 end
        count = count + 1
    end
end


-- --[[
-- --! @function performanceBossMc
-- --! @desc 
-- --! @return 
-- --]]
-- function GuildMapLayer:performanceBossMc()
    
--     for k,v in pairs(self._bossGrids) do
--         repeat
--             print("test================================", v)
--             if self._gridElements[v] == nil then break end
--             local element = self._gridElements[v]
--             if element.animSp == nil then break end

--             local nearGrids = self:getNearGrids(self._curGrid.a, self._curGrid.b)
--             for k1,v1 in pairs(nearGrids) do
--                 if (v1.grid.a .. "," .. v1.grid.b) == v then 
--                     element.animSp:changeMotion(3, nil, 
--                         function()
--                             element.animSp:changeMotion(10)
--                             element.animSp:play()
--                         end)
--                     element.animSp:play()
--                     return
--                 end
--             end
--         until true
--     end
-- end

--[[
--! @function updateMapEle
--! @desc 更新地图元素状态，涉及到删除和添加
--! @return 
--]]

function GuildMapLayer:updateMapEle(inGridKey, inGrid, inMapInfo)
    local userModel = self._modelMgr:getModel("UserModel")
	local curTime = userModel:getCurServerTime()
    local mapItem = nil
    local typeName = ""
	if inMapInfo ~= nil then 
		local isGetData = false
		if inMapInfo.guild ~= nil then
			local isSkipGuild= false
			if inMapInfo.guild.eid==9001 then--秘境可能和sphinx重叠，判断秘境的lifeTime
				local lifeTime = tab.famAppear[inMapInfo.guild.stype].time
				--[[local scieneLv = self._modelMgr:getModel("GuildModel"):getGuildScienceLvWithId(17)--预防科技影响秘境lifeTime功能复发 by lannan
				if scieneLv>0 then
					local tabData = tab:TechnologyChild(17)
					lifeTime = lifeTime + tabData.effectNum[1][scieneLv]
				end--]]
				local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
				local isTimeOver = nowTime >= inMapInfo.guild.stime + lifeTime
				local isOtherJoin = userModel:getRID()~=inMapInfo.guild.stid and inMapInfo.guild.ifJoin==1
				if isTimeOver or isOtherJoin then
					isSkipGuild = true
				end
			end
			if not isSkipGuild then
				mapItem = inMapInfo.guild
				typeName = GuildConst.ELEMENT_TYPE.GUILD
				isGetData = true
			end
		end
		if not isGetData then
			if inMapInfo.common ~= nil then 
				local tempSysGuildMapThing = tab.guildMapThing[tonumber(inMapInfo.common.eid)] 
				local  flag = 0
				if (inMapInfo.common.locktime == nil and inMapInfo.common.openTime == nil) then 
					flag = 1
				elseif(inMapInfo.common.locktime ~= nil and 
						inMapInfo.common.owner ~= nil and
					(tonumber(inMapInfo.common.locktime) > curTime or 
						(tonumber(inMapInfo.common.locktime) <= curTime and 
						inMapInfo.common.owner == self._userId))) then 
					flag = 1
				elseif(inMapInfo.common.openTime ~= nil and
					tonumber(inMapInfo.common.openTime) > curTime) then 
					flag = 1
				elseif tempSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.OUTPUT_GOLD then
					flag = 1
				-- 地下城有opentime 时间限制，但时间结束后建筑还需要显示
				elseif tempSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.UNDERGROUND_CITY then
					flag = 1
				end
				
				if flag == 1 then 
					mapItem = inMapInfo.common
					typeName = GuildConst.ELEMENT_TYPE.COMMON
					isGetData = true
				end
			end
			
			if not isGetData and inMapInfo.my ~= nil then
				mapItem = inMapInfo.my
				typeName = GuildConst.ELEMENT_TYPE.MY
				isGetData = true
			end
		end
	end

    if (mapItem == nil or mapItem.eid == nil) then
        self:removeEleByGridKey(inGridKey)
        return 
    end

    -- 同元素存在一个格子内，需要整理展示优先级
    local priority = 0
    local sysGuildMapThing
    -- if inGridKey == "11,22" then 
    --     mapItem.eid = 100
    -- elseif inGridKey == "21,13" then 
    --     mapItem.eid = 98
    -- elseif inGridKey == "21,32" then 
    --     mapItem.eid = 101    
    -- end
    local tempSysGuildMapThing = tab.guildMapThing[tonumber(mapItem.eid)]
    if tempSysGuildMapThing ~= nil and tempSysGuildMapThing.type > priority then 
        sysGuildMapThing = tempSysGuildMapThing
        priority = tempSysGuildMapThing.type
    end
    if sysGuildMapThing ~= nil then 
        -- 如果已经存在的元素不重新创建
        if self._gridElements[inGridKey] ~= nil and 
            self._gridElements[inGridKey].eleId == sysGuildMapThing.id then 
            return
        end
        self:removeEleByGridKey(inGridKey, true)

        local elementSp = nil
        if sysGuildMapThing.qiangdu == 1 then
            elementSp = self:createBossElement(mapItem, sysGuildMapThing)
        elseif mapItem.formation ~= nil then
            elementSp = self:createTeamElement(mapItem, sysGuildMapThing, typeName)

        elseif sysGuildMapThing.func ==  GuildConst.ELEMENT_EVENT_TYPE.NPC or
				sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.OFFICER or
				sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.MATERIAL then
            elementSp = self:createAnimElement(mapItem, sysGuildMapThing)

        elseif sysGuildMapThing.func ==  GuildConst.ELEMENT_EVENT_TYPE.TEAM_RECRUIT or
               sysGuildMapThing.func ==  GuildConst.ELEMENT_EVENT_TYPE.TEAM_ESCAPE or 
               sysGuildMapThing.func ==  GuildConst.ELEMENT_EVENT_TYPE.TEAM_JOIN  then
            elementSp = self:createTeamPicElement(mapItem, sysGuildMapThing)

        elseif sysGuildMapThing.qiangdu ~= 1 and sysGuildMapThing.art ~= nil then 
            elementSp = self:createBuildingElement(mapItem, sysGuildMapThing, inGridKey)

        else
            elementSp = cc.Sprite:create("static/WhenCannotFindShowThis.png")
            
        end
        if elementSp ~= nil then
            elementSp:setAnchorPoint(cc.p(0.5, 0))
            -- 针对pve特殊处理坐标
            if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.PVE then 
                elementSp:setPosition(inGrid.pos.x, inGrid.pos.y - 10)
            elseif sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.FAM then--针对联盟秘境传送门处理坐标
				elementSp:setPosition(inGrid.pos.x-10, inGrid.pos.y - 25)
			else
                elementSp:setPosition(inGrid.pos.x, inGrid.pos.y - 20)
            end
            
            self._bgSprite:addChild(elementSp, 100 + (inGrid.grid.a + inGrid.grid.b))
            elementSp.eleId = sysGuildMapThing.id
            elementSp.typeName = typeName
            self._gridElements[inGridKey] = elementSp

            -- 特殊点高亮提示
            self:showElementHighlightTip(elementSp, sysGuildMapThing, typeName)

            if GuildConst.SHOW_ELE_ID then
                local memLabel = cc.Label:createWithTTF(sysGuildMapThing.id .. "," .. sysGuildMapThing.func, UIUtils.ttfName, 20)
                memLabel:setPosition(elementSp:getContentSize().width/2 , elementSp:getContentSize().height/2 )
                memLabel:setAnchorPoint(0.5, 0.5)
                memLabel:setColor(cc.c3b(39,247,58,255))
                memLabel:enableOutline(cc.c4b(0,0,0,255), 1)
                elementSp:addChild(memLabel, 10)
            end
			
			--联盟秘境
			if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.FAM then
				elementSp.inGridKey = inGridKey
				local createTime = mapItem.stime
				local lifeTime = tab.famAppear[mapItem.stype].time
				local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
				local endTime = createTime + lifeTime
				--[[local scieneLv = self._modelMgr:getModel("GuildModel"):getGuildScienceLvWithId(17)--预防科技影响秘境lifeTime功能复发 by lannan
				if scieneLv>0 then
					local tabData = tab:TechnologyChild(17)
					endTime = endTime + tabData.effectNum[1][scieneLv]
				end--]]
				if nowTime < endTime then
					local repeatAction = cc.RepeatForever:create(
						cc.Sequence:create(cc.CallFunc:create(function()
							if elementSp then
								local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
								local stopTime = endTime - nowTime
								local str = TimeUtils.getTimeStringMS(stopTime)
								elementSp.timeLabel:setString(string.format("%s后消失", str))
								local countDownTime = tonumber(tab:Setting("FAMEXPLORATIONCOUNTDOWN").value)
								elementSp.timeBg:setVisible(nowTime>=endTime-countDownTime)
								if stopTime<=0 then
									local backMapList = self._guildMapModel:getData().mapList
									local targetData = backMapList[elementSp.inGridKey]
									if targetData and targetData.guild then
										backMapList[elementSp.inGridKey].guild = nil
									end
									local param = { [elementSp.inGridKey] = 1 }
									self:handleListenModelEleState(param)
									self:listenModelEleStateCur()
								end
							end
						end),
						cc.DelayTime:create(1)))
					elementSp:runAction(repeatAction)
				end
			end
			
			--新年使者
			if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.YEAR then
				local activityData = self._modelMgr:getModel("ActivityModel"):getAcShowDataByType(36)
				if activityData and activityData.end_time then
					local endTime = tonumber(activityData.end_time)
					elementSp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
						if elementSp then
							local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
							local stopTime = endTime - nowTime
							if stopTime<=0 then
								self:removeEleByGridKey(inGridKey)
							end
						end
					end), cc.DelayTime:create(1))))
				end
			end

            --斯芬克斯答题类型建筑
            if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.SPHINX_AQ then
                local curShowTime = self._guildMapModel:getAQAcTime()
                if not (curShowTime == nil or #curShowTime < 3) then
                    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                    local disTime = math.max(curShowTime[2] - curTime, 0)
                    elementSp:runAction(cc.Sequence:create(
                        cc.DelayTime:create(disTime),
                        cc.CallFunc:create(function()
                            if elementSp and inGridKey then   --删除点 隐藏还可点击
                                -- self:removeEleByGridKeyAndType(inGridKey, "my")
                                local param = { [inGridKey] = 1 }
                                self:handleListenModelEleState(param)
                            end
                            end)))
                end
            end

            --保存先知小屋/学者sp/宝箱的位置  by wangyan
            if sysGuildMapThing.func ==  GuildConst.ELEMENT_EVENT_TYPE.TRIGGER_TASK or
             sysGuildMapThing.func ==  GuildConst.ELEMENT_EVENT_TYPE.NPC or
			 sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.MATERIAL or
			 sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.OFFICER or
             sysGuildMapThing.func ==  GuildConst.ELEMENT_EVENT_TYPE.XUEZHE_BOX then
                self:openFog({inGrid.grid}, false)
                elementSp:setVisible(true)
            else
                if self._gridFogs[inGridKey] ~= nil then 
                    elementSp:setVisible(false)
                    if elementSp.earthAnim ~= nil then
                        elementSp.earthAnim:setVisible(false)
                    end
                end
            end
        end

        if mapItem.openTime ~= nil and sysGuildMapThing.func ~= GuildConst.ELEMENT_EVENT_TYPE.UNDERGROUND_CITY then 
            local tempMapItem = {}
            tempMapItem.locktime = mapItem.openTime
            tempMapItem.eid = mapItem.eid
            self:handleEleTimngQueue(inGridKey, tempMapItem, sysGuildMapThing)
        end
    end
    return sysGuildMapThing
end

local AnimAp = require "base.anim.AnimAP"

function GuildMapLayer:createTagElement()
    local mapMark = self._guildMapModel:getData().mapMark
    local labTalk = self._bgSprite:getChildByName("tag_talk")
    if labTalk ~= nil then
        labTalk:removeFromParent()
        labTalk = nil
    end

    local pointTip = self._bgSprite:getChildByName("tag_jiantou")
    if pointTip ~= nil then
        pointTip:removeFromParent()
        pointTip = nil
    end

    local pointTip = self._bgSprite:getChildByName("tag_jiantou")
    if pointTip ~= nil then
        pointTip:removeFromParent()
        pointTip = nil
    end

    local gridBg = self._bgSprite:getChildByName("tag_grid")
    if gridBg ~= nil then
        gridBg:removeFromParent()
        gridBg = nil
    end

    if self._currentGuildId == "center" then
        return
    end

    --非本联盟玩家
    if tonumber(self._guildId) ~= tonumber(self._currentGuildId) then
        return
    end


    if not mapMark or next(mapMark) == nil then
        return
    end

    local gridKey = mapMark[1]["pos"]
    local eleData = self._shapes[gridKey]
    local tipPosX, tipPosY = eleData.pos.x - 5, eleData.pos.y + 50
    local build = self._gridElements[gridKey]
    if build then
        -- dump(build:getContentSize(), "build", 10)
        tipPosX, tipPosY = eleData.pos.x - 5, eleData.pos.y + 40 + build:getContentSize().height * 0.5
    else
        tipPosX, tipPosY = eleData.pos.x - 5, eleData.pos.y + 40
    end

    --蓝格子
    local gridBg = cc.Sprite:createWithSpriteFrameName("guild_map_test.png")
    gridBg:setPosition(eleData.pos)
    gridBg:setOpacity(255)
    gridBg:setName("tag_grid")
    self._bgSprite:addChild(gridBg, 8)

    --wordBg
    local wordBg = cc.Scale9Sprite:createWithSpriteFrameName("guildMapImg_temp17.png")
    wordBg:setContentSize(200, 80)    
    wordBg:setCapInsets(cc.rect(26,15,1,1))
    wordBg:setAnchorPoint(cc.p(0, 0))
    wordBg:setPosition(tipPosX, tipPosY + 10)
    wordBg:setName("tag_talk")
    self._bgSprite:addChild(wordBg, 1000)

    --职位
    local post = cc.Sprite:createWithSpriteFrameName("chatImg_channel_guild1.png")
    post:setAnchorPoint(cc.p(0, 1))
    post:setScale(0.8)
    wordBg:addChild(post)

    --文字
    local des = "     " .. (mapMark[1]["des"] or "")
    local labTalk = cc.Label:createWithTTF(des, UIUtils.ttfName, 18, cc.size(150, 70))
    labTalk:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    labTalk:setAnchorPoint(cc.p(0, 1)) 
    labTalk:setVerticalAlignment(1)
    labTalk:setHorizontalAlignment(0)
    labTalk:setLineBreakWithoutSpace(true)
    labTalk:setDimensions(150, 0)
    wordBg:addChild(labTalk)

    wordBg:setContentSize(cc.size(labTalk:getContentSize().width + 10, labTalk:getContentSize().height + 22))
    post:setPosition(7, wordBg:getContentSize().height - 6)
    labTalk:setPosition(7, wordBg:getContentSize().height - 7)

    --箭头anim
    local pointTip = mcMgr:createViewMC("jiantou_intancejiantou", true)
    pointTip:setPosition(tipPosX + 7, tipPosY - 11)
    pointTip:setScale(0.8)
    pointTip:setName("tag_jiantou")
    self._bgSprite:addChild(pointTip, 1000)
end

function GuildMapLayer:createAnimElement(mapItem, sysGuildMapThing)
    local elementSp = ccui.Widget:create()
    elementSp:setContentSize(cc.size(87, 87))

    local sp = mcMgr:createViewMC(sysGuildMapThing.art, true, false)
    sp:setPosition(elementSp:getContentSize().width * 0.5, 14)
	if sysGuildMapThing.scale ~= nil then 
        sp:setScale(sysGuildMapThing.scale)
    end
    elementSp:addChild(sp, 10)

    local titleImg = ccui.ImageView:create()
    titleImg:loadTexture("guildMapImg_rule_nameBg.png", 1)
    titleImg:setPosition(elementSp:getContentSize().width * 0.5, -5)
    elementSp:addChild(titleImg, 11)

    local titleDes = ccui.Text:create()
    titleDes:setString(lang(sysGuildMapThing.name))
    titleDes:setFontName(UIUtils.ttfName)
    titleDes:setFontSize(16)
    titleDes:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    titleDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    titleDes:setPosition(titleImg:getContentSize().width * 0.5, titleImg:getContentSize().height * 0.5)
    titleImg:addChild(titleDes, 11)


    self:showElementEffect(elementSp, sysGuildMapThing["id"], mapItem)

    if sysGuildMapThing.flipX == 1 then 
        elementSp:setFlippedX(true)
    else
        elementSp:setFlippedX(false)
    end      
    return elementSp
end

function GuildMapLayer:createBossElement(mapItem, sysGuildMapThing)
    local elementSp = ccui.Widget:create()
    elementSp:setContentSize(cc.size(117 * self._intScale, 59 * self._intScale))
    if AnimAp["mcList"][sysGuildMapThing.art] then 
    local branchIcon = MovieClipAnim.new(elementSp, sysGuildMapThing.art, function (sp)
            local w, h = sp:getSize()
            sp:setPosition(elementSp:getContentSize().width * 0.5, 0)
            sp:changeMotion(10)
            sp:play()
            elementSp.animSp = sp

            sp:setLocalZOrder(8)

            if sysGuildMapThing.scale ~= nil then 
                sp:setScale(sysGuildMapThing.scale * 0.5)
            end

            if sysGuildMapThing.flipX == 1 then 
                sp:setScaleX(-1 * sp:getScale())
            else
                sp:setScaleX(1 * sp:getScale())
            end
        end)
    elementSp.runNearAction = function(sender, inDis)
        if inDis > 1 then return end
        print(" elementSp.runNearAction===================",  elementSp.runNearAction)
        elementSp.animSp:changeMotion(3, nil, 
            function()
                elementSp.animSp:changeMotion(10)
                elementSp.animSp:play()
            end)
        elementSp.animSp:play()        
    end
    else
        local branchIcon = SpriteFrameAnim.new(elementSp, sysGuildMapThing.art, function (sp)
            local w, h = sp:getSize()
            -- elementSp:setContentSize(cc.size(w, h))
            sp:setName("anim_sp")
            sp:setPosition(elementSp:getContentSize().width * 0.5, 0)
            sp:setLocalZOrder(8)
            sp:play()
            if sysGuildMapThing.flipX == 1 then 
                sp:setScaleX(-1)
            else
                sp:setScaleX(1)
            end            
        end)
        if sysGuildMapThing.flipX == 1 then 
            elementSp:setFlippedX(true)
        else
            elementSp:setFlippedX(false)
        end  
    end

    return elementSp
end

function GuildMapLayer:createBuildingElement(mapItem, sysGuildMapThing, inGridKey)
	if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.FAM then
		local myId = self._modelMgr:getModel("UserModel"):getRID()
		
		local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
		local lifeTime = tab.famAppear[mapItem.stype].time
		
		--[[local scieneLv = self._modelMgr:getModel("GuildModel"):getGuildScienceLvWithId(17)--预防科技影响秘境lifeTime功能复发 by lannan
		if scieneLv>0 then
			local tabData = tab:TechnologyChild(17)
			lifeTime = lifeTime + tabData.effectNum[1][scieneLv]
		end--]]
		
		if curTime >= mapItem.stime + lifeTime then
			return
		end
		
		local limitTimes = tonumber(tab:Setting("FAMEXPLORATIONTIMES").value)
		local nowTimes = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(74)
		if nowTimes>=limitTimes and mapItem.stid~=myId then
			return
		end
		
		if mapItem.ifJoin and mapItem.ifJoin==1 and mapItem.stid~=myId then
			return
		end
	end

    --斯芬克斯答题类型建筑
    if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.SPHINX_AQ then
        local curShowTime = self._guildMapModel:getAQAcTime()
        if curShowTime == nil or #curShowTime < 3 then
            return
        end

        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local disTime = math.max(curShowTime[2] - curTime, 0)
        if disTime <= 0 then
            return
        end
    end

    local elementSp = ccui.Widget:create()
    local tempSp = cc.Sprite:createWithSpriteFrameName(sysGuildMapThing.art .. ".png")
    if sysGuildMapThing.scale ~= nil then 
        tempSp:setScale(sysGuildMapThing.scale)
    end
        
    elementSp:setContentSize(tempSp:getContentSize().width * tempSp:getScale(), tempSp:getContentSize().height * tempSp:getScale())
    
    elementSp:addChild(tempSp, 10)
	

    if sysGuildMapThing.id == 74 or sysGuildMapThing.id == 5001 then 
        tempSp:setPosition(elementSp:getContentSize().width/2 - 8, elementSp:getContentSize().height/2 - 40)
    else
        tempSp:setPosition(elementSp:getContentSize().width/2, elementSp:getContentSize().height/2)
    end
	if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.YEAR then
		local shadow = cc.Sprite:createWithSpriteFrameName("guildMapImg_spShadow.png")
		shadow:setAnchorPoint(0.5, 0.5)
		shadow:setScale(1.2)
		shadow:setPosition(elementSp:getContentSize().width/2, 17)
		elementSp:addChild(shadow,8)
		tempSp:setPositionY(tempSp:getPositionY()+15)
	end
    -- sp = cc.Sprite:createWithSpriteFrameName(sysGuildMapThing.art .. ".png")
    self:showElementEffect(elementSp, sysGuildMapThing["id"], mapItem, inGridKey)

    if sysGuildMapThing.flipX == 1 then 
        elementSp:setFlippedX(true)
    else
        elementSp:setFlippedX(false)
    end
	
	--秘境入口
	if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.FAM then
		local nameBg = cc.Scale9Sprite:createWithSpriteFrameName("guild_fam_nameBgImg.png")
		nameBg:setContentSize(59, 30)
		nameBg:setCapInsets(cc.rect(29, 15, 1, 1))
		nameBg:setPosition(elementSp:getContentSize().width/2+10, 5)
		elementSp:addChild(nameBg, 10)
		
		local nameLabel = cc.Label:createWithTTF(lang("famdoorname"), UIUtils.ttfName, 16)
		nameLabel:setTextColor(cc.c4b(252, 244, 197, 255))
		nameLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		local nameWidth = nameLabel:getContentSize().width
		nameBg:setContentSize(nameWidth+40, 30)
		nameLabel:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2)
		nameBg:addChild(nameLabel)
		
		local timeBg = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI12_worldMenuNameBg1.png")
		timeBg:setContentSize(120, 35)
		nameBg:setCapInsets(cc.rect(20, 10, 1, 1))
		timeBg:setAnchorPoint(0.5, 0.5)
		timeBg:setPosition(elementSp:getContentSize().width/2+10, -22)
		timeBg:setVisible(false)
		timeBg:setOpacity(255*0.8)
		elementSp.timeBg =timeBg
		elementSp:addChild(timeBg, 10)
		
		local timeLabel = cc.Label:createWithTTF("x分x秒后消失", UIUtils.ttfName, 16)
		timeLabel:setColor(cc.c3b(255, 31, 31))
		timeLabel:setAnchorPoint(0.5, 0.5)
		timeLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		timeLabel:setOpacity(255)
		timeLabel:setPosition(timeBg:getContentSize().width/2, timeBg:getContentSize().height/2+2)
		elementSp.timeLabel = timeLabel
		timeBg:addChild(timeLabel)
		
		--秘境入口箭头特效
		if mapItem.stid==self._modelMgr:getModel("UserModel"):getRID() then
			local famArrowEffect = mcMgr:createViewMC("mijingjiantou_mijingrukou", true)
			famArrowEffect:setPosition(elementSp:getContentSize().width/2+10, elementSp:getContentSize().height+20)
			famArrowEffect:setName("famArrow")
			elementSp:addChild(famArrowEffect, 10)
		end
	end
    
    -- 水车类建筑特殊处理
    if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.OUTPUT_GOLD then
        elementSp.runNearAction = function(inDis)
            if elementSp.rewardTip ~= nil then
                elementSp.rewardTip.closeTime = os.time() + 5
                return
            end
            local mapList = self._guildMapModel:getData().mapList
            local thisTarget = mapList[inGridKey]
            if thisTarget == nil then return end
            local thisEle = thisTarget.common
            if thisEle == nil then return end
            if thisEle.haduse ~= nil and 
                tonumber(thisEle.haduse) >= 1 then   
                return 
            end
            local serverLvl = self._guildMapModel:getData().servLv
            local tempV
            for k,v in pairs(sysGuildMapThing.produceAward) do
                if serverLvl >= v[1] and serverLvl <= v[2] then 
                    tempV = v[3]
                    break
                end
            end 
            if tempV == nil then return end
            local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
            local icon = GuildMapUtils:showItems(tempV, 0.4, 1, true, 0)   
            rewardTip = cc.Scale9Sprite:createWithSpriteFrameName("guildMapImg_temp17.png")
            rewardTip:setContentSize(58, 59)
            rewardTip:setCapInsets(cc.rect(26, 13, 1, 1))
            rewardTip:setAnchorPoint(0.5, 0)
            rewardTip:setPosition(elementSp:getContentSize().width * 0.5 + 20, elementSp:getContentSize().height)
            elementSp:addChild(rewardTip,11)
            icon:setAnchorPoint(0.5, 0.5)
            icon:setPosition(rewardTip:getContentSize().width * 0.5, 5 + rewardTip:getContentSize().height * 0.5 )
            rewardTip:addChild(icon)
            rewardTip.closeTime = os.time()
            rewardTip:runAction(
                cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.DelayTime:create(1), 
                        cc.CallFunc:create(function() 
                                if rewardTip.closeTime < os.time() then 
                                    rewardTip:stopAllActions()
                                    rewardTip:removeFromParent(true)
                                    elementSp.rewardTip = nil
                                end
                            end
                            )
                        )
                    )
                )
            elementSp.rewardTip = rewardTip
            rewardTip.closeTime = os.time() + 5
        end
    end

    return elementSp
end

function GuildMapLayer:createTeamPicElement(mapItem, sysGuildMapThing, inGridKey)
    print("sysGuildMapThing.id=============", sysGuildMapThing.id, sysGuildMapThing.corart)
    local elementSp = ccui.Widget:create()
    local sysTeam = tab:Team(sysGuildMapThing.corart)
    local elementSp = ccui.Widget:create()

    local tempSp = cc.Sprite:create("asset/uiother/steam/" .. sysTeam.steam .. ".png")

    
    if sysGuildMapThing.scale ~= nil then 
        tempSp:setScale(sysGuildMapThing.scale)
    end
        
    elementSp:setContentSize(tempSp:getContentSize().width * tempSp:getScale(), tempSp:getContentSize().height * tempSp:getScale())
    
    elementSp:addChild(tempSp, 10)

    tempSp:setPosition(elementSp:getContentSize().width * 0.5, elementSp:getContentSize().height * 0.5)
    -- sp = cc.Sprite:createWithSpriteFrameName(sysGuildMapThing.art .. ".png")
    self:showElementEffect(elementSp, sysGuildMapThing["id"], mapItem)

    if sysGuildMapThing.flipX == 1 then 
        elementSp:setFlippedX(true)
    else
        elementSp:setFlippedX(false)
    end   

    return elementSp
end

function GuildMapLayer:createTeamElement(mapItem, sysGuildMapThing, typeName)
    local formation = mapItem.formation
    local sysTeam = tab:Team(formation["team1"])
    local elementSp = ccui.Widget:create()

    local tempSp = cc.Sprite:create("asset/uiother/steam/" .. sysTeam.steam .. ".png")
    if formation["team1"] == 107 or formation["team1"] == 507 then 
        tempSp:setScale(0.5)
    else
        tempSp:setScale(0.3)
    end
    elementSp:setContentSize(tempSp:getContentSize().width * tempSp:getScale(), tempSp:getContentSize().height * tempSp:getScale())
    tempSp:setPosition(elementSp:getContentSize().width/2, elementSp:getContentSize().height/2)
    elementSp:addChild(tempSp, 10)

    -- local grayLayer = cc.LayerColor:create(cc.c4b(20, 20, 20, 99), 65, 255)
    -- grayLayer:setContentSize(elementSp:getContentSize().width, elementSp:getContentSize().height)
    -- grayLayer:setPosition(cc.p(0, 0))
    -- elementSp:addChild(grayLayer, 20)

    if typeName == GuildConst.ELEMENT_TYPE.GUILD then 
        self:showElementEffect(elementSp, mapItem.eid)
    end
    --加影子
    if sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.PVE then 
        local shadow = cc.Sprite:createWithSpriteFrameName("guildMapImg_spShadow.png")
        shadow:setAnchorPoint(0.5, 0.5)
        shadow:setPosition(elementSp:getContentSize().width/2 - 5, 0)
        elementSp:addChild(shadow,8)

        -- 强度2的增加特殊骷髅标记
        if sysGuildMapThing.qiangdu == 2 then 
            local spTip = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp33.png")
            spTip:setAnchorPoint(0.5, 0.5)
            spTip:setPosition(elementSp:getContentSize().width/2, 0)
            elementSp:addChild(spTip,11)

            local tipLab = cc.Label:createWithTTF(lang(sysTeam.name), UIUtils.ttfName, 18)
            tipLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)
            spTip:addChild(tipLab)
            tipLab:setPosition(12 + spTip:getContentSize().width * 0.5, spTip:getContentSize().height * 0.5 - 1)
            tipLab:setAnchorPoint(0.5, 0.5)

            if sysGuildMapThing.flipX == 1 then 
                spTip:setScaleX(-1)
            else
                spTip:setScaleX(1)
            end
            elementSp.runNearAction = function()
                self:showBuildingTalk(sysGuildMapThing, elementSp)
            end
        end
    end
    if sysGuildMapThing.flipX == 1 then 
        elementSp:setScaleX(-1)
    else
        elementSp:setScaleX(1)
    end    

    return elementSp
end

--[[
--! @function handleEleTimngQueue
--! @desc 处理建筑定时队列
--! @return 
--]]
function GuildMapLayer:handleEleTimngQueue(inGridKey, inTimeData, sysGuildMapThing)
    if inTimeData == nil or inTimeData.locktime == nil then 
        self._eleTimngQueue[inGridKey] = nil
        return
    end

    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    if (curTime < tonumber(inTimeData.locktime)) and 
        sysGuildMapThing["func"] ~= GuildConst.ELEMENT_EVENT_TYPE.UNDERGROUND_CITY then 
        self._eleTimngQueue[inGridKey] = {
                        locktime = tonumber(inTimeData.locktime), 
                        gridKey = inGridKey,
                        eid = inTimeData.eid
                    }
        self:updateTimngQueue()         
    end
end

--[[
--! @function handlePlayerTimngQueue
--! @desc 处理玩家定时队列
--! @return 
--]]
function GuildMapLayer:handlePlayerTimngQueue(inUserId, inGridKey, inTimeData)
    if inTimeData == nil or inTimeData.curOp == nil  then 
        self._playerTimngQueue[inUserId] = nil
        if self._userMcs[inUserId] ~= nil then 
            self._userMcs[inUserId]:removeProgress()
        end       
        return
    end
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    if inTimeData.curOp.locktime ~= nil and (curTime < tonumber(inTimeData.curOp.locktime)) then 
        local thisEle = self._guildMapModel:getShowElementDataByGridKey(inTimeData.curOp.gid)
        if thisEle ~= nil then
            self._playerTimngQueue[inUserId] = {
                            createtime = tonumber(inTimeData.curOp.createtime),
                            locktime = tonumber(inTimeData.curOp.locktime), 
                            gridKey = inGridKey, 
                            targetGridKey = inTimeData.curOp.gid
                        }
            if inUserId == self._userId then 
                self._intanceMcAnimNode:runProgress()
            else
                self._userMcs[inUserId]:runProgress()
            end                
            self:updateTimngQueue()      
        end
        return
    end
    -- 时间条件不满足说明需要移除
    self._playerTimngQueue[inUserId] = nil    
    if self._userMcs[inUserId] ~= nil then 
        self._userMcs[inUserId]:removeProgress()
    end
end

function GuildMapLayer:removeEleByGridKey(inGridKey, inNeedRemove)
    local gridElement = self._gridElements[inGridKey]
    if gridElement ~= nil and gridElement.eleId ~= nil then
        local userId = self._modelMgr:getModel("UserModel"):getData()._id
        local tempSysGuildMapThing = tab.guildMapThing[tonumber(self._gridElements[inGridKey].eleId)] 
        if tempSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.ELAPSED_REWARD and 
            gridElement.isNihility == nil and 
            gridElement.occupyId ~= userId and inNeedRemove ~= true then
            gridElement.isNihility = true
            gridElement:setCascadeOpacityEnabled(true, true)
            gridElement:setOpacity(100)
            gridElement:runAction(        
                cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.FadeTo:create(1, 200),
                        cc.FadeTo:create(1, 100)
                        )
                    )
                )
            if gridElement.earthAnim then
                gridElement.earthAnim:removeFromParent()
                gridElement.earthAnim = nil
            end
        else
            if gridElement.isNihility == true then 
                self._viewMgr:showTip(lang("GUILDBUILDTIP_1"))
            end
            if gridElement.earthAnim then
                gridElement.earthAnim:removeFromParent()
                gridElement.earthAnim = nil
            end
            gridElement:removeFromParent()
            self._gridElements[inGridKey] = nil
        end
    end   
end

function GuildMapLayer:removeEleByGridKeyAndType(inGridKey, inType)   --by wangyan 强制删除建筑点本地数据并刷新
    if not inGridKey or not inType then
        return
    end
    
    local mapList = self._guildMapModel:getData().mapList
    local targetData = mapList[inGridKey]
    if targetData and targetData[inType] then
        targetData[inType] = nil
    end
    local param = { [inGridKey] = 1 }
    self:handleListenModelEleState(param)
    self:listenModelEleStateCur()
end

function GuildMapLayer:removeEleTimeTip(inGridKey)
    local mapList = self._guildMapModel:getData().mapList
    local userList = self._guildMapModel:getData().userList
    if mapList[inGridKey] ~= nil and self._gridElements[inGridKey] ~= nil then 
        local typeName = self._gridElements[inGridKey].typeName
        if mapList[inGridKey][typeName] ~= nil then 
            local grid = self._shapes[inGridKey]
            self:updateMapEle(inGridKey, grid, mapList[inGridKey])
        end
    end
end

function GuildMapLayer:removePlayerTimeTip(inUserId)
    print("removePlayerTimeTip==============", inUserId)
end

--[[
--! @function timeUpdate
--! @desc 定时器
--! @return 
--]]
function GuildMapLayer:updateTimngQueue()
    -- 更新建筑与人的一些定时状态
    local userList = self._guildMapModel:getData().userList
    local mapList = self._guildMapModel:getData().mapList

    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    for k,v in pairs(self._playerTimngQueue) do
        local percent = math.ceil((curTime - tonumber(v.createtime)) / (tonumber(v.locktime) - tonumber(v.createtime)) * 100)
        if k == self._userId then 
            if v.locktime <= curTime then 
                self._playerTimngQueue[k] = nil
                self._intanceMcAnimNode:stopProgress()

                --wangyan  进度条走完后领取动画
                if userList[self._userId] ~= nil then
                    local curOp = userList[self._userId].curOp
                    if curOp.gid ~= nil then
                        local gridElement = self._gridElements[curOp.gid] 
                        self:showActiveEventEffect(gridElement, gridElement.eleId, 
                                                 mapList[curOp.gid][gridElement.typeName], "stop_kelingqu")
                    end
                end
            else
                self._intanceMcAnimNode:updateProgress(percent)
            end    
        elseif self._gridPlayers[v.gridKey] ~= nil then 
            for k1,v1 in pairs(self._gridPlayers[v.gridKey]) do
                if v1.userId == k then 
                    local heroMc = self._userMcs[v1.userId]
                    if v.locktime <= curTime then 
                        self._playerTimngQueue[k] = nil
                        heroMc:stopProgress()
                        if userList[v1.userId] ~= nil then
                            local curOp = userList[v1.userId].curOp
                            -- 删除锁定点
                            if curOp ~= nil and curOp.gid ~= nil then 
                                self:removeEleTimeTip(curOp.gid)
                            end
                        end
                    else
                        heroMc:updateProgress(percent)
                    end
                end
            end
        end
    end

    for k,v in pairs(self._eleTimngQueue) do
        if v.locktime <= curTime then 
            self._eleTimngQueue[k] = nil
            -- local mapList = self._guildMapModel:getData().mapList
            self:removeEleTimeTip(k)
        end          
    end
end

--[[
--! @function backCity
--! @desc 回城处理
--! @param 
--! @return 
--]]
function GuildMapLayer:backCity()
	if self:checkLockRoleState() == true then return end
	local upTime = self._guildMapModel:getData().upTime
	self._serverMgr:sendMsg("GuildMapServer", "backCity", {upTime = upTime}, true, {}, function(result)
		dump(result, "test", 10)
		if result.code == 1 then 
			return
		end
		if result["reward"] ~= nil and next(result["reward"]) ~= nil and result.cityTime ~= nil and result["reward"][1][3] > 0 then
			self._viewMgr:showDialog("guild.map.GuildMapInfoTipView", {reward = result["reward"][1], time = result.cityTime, showType = 1, callback = 
				function()
					if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SWITCH_MAP then
						self._guildMapModel:clear()
						self._parentView:getMapInfo()
						return
					end
					self:listenModelBackCityCur()

				end}, true)
			return
		end
		if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SWITCH_MAP then
			self._guildMapModel:clear()
			self._parentView:getMapInfo()
			return
		end   
		self:listenModelBackCityCur()
	end)
end

--[[
--! @function yearAmbMove
--! @desc 新年使者地图中移动
--! @param 
--! @return 
--]]
function GuildMapLayer:yearAmbMove(a, b, x, y)
	if self:checkLockRoleState() == true then return end
	local targetPoint = a..","..b
	self._serverMgr:sendMsg("GuildMapServer", "yearAmbMove", {tagPoint = targetPoint}, true, {}, function(result)
		if result.code == 1 then 
			return
		end
		
		self:lockTouch()
		self:screenToGrid(self._curGrid.a, self._curGrid.b)
        local order = self._intanceMcAnimNode:getLocalZOrder()
        local backcity1 = mcMgr:createViewMC("huicheng1_guildmaphuicheng", false, true, function()

        end)
        backcity1:setPosition(self._intanceMcAnimNode:getPosition())
        self._bgSprite:addChild(backcity1, order - 1)
        local backcity2 = mcMgr:createViewMC("huicheng2_guildmaphuicheng", false, true, function()
			local tempGrids = self:getCircleGrids(a, b, 2)
			self:openFog(tempGrids)
            self:moveToGridByMyself(a, b, false, true, function()
				self._intanceMcAnimNode:setLocalZOrder(100 + (a  + b))
                self._userGridKeys[self._userId] = self._curGrid.a .. "," .. self._curGrid.b
                local backcity3 = mcMgr:createViewMC("huicheng3_guildmaphuicheng", false, true, function()

                end)
                backcity3:setPosition(x, y)
                self._bgSprite:addChild(backcity3, order - 1)
                local backcity4 = mcMgr:createViewMC("huicheng4_guildmaphuicheng", false, true, function()
                    self:unLockTouch()
                end)
                self._bgSprite:addChild(backcity4, order + 1)
                backcity4:setPosition(x, y)
            end)
        end)
        self._bgSprite:addChild(backcity2, order + 1)
        backcity2:setPosition(self._intanceMcAnimNode:getPosition())
	end)
end


--[[
--! @function getGridThroughState
--! @desc 获取格子通过状态
--! @param 
--! @return 
--]]
function GuildMapLayer:getGridState(inA, inB)

    local guildMap = tab[self._settingData.mapTable]
    local sysGuildMap = guildMap["b" .. inB]
    if sysGuildMap ~= nil and 
        sysGuildMap["a" .. inA] ~= nil  then 
        if sysGuildMap["a" .. inA][1] == 1 then
            return 1
        end
    end
    return 0
end

--[[
--! @function getGridThroughState
--! @desc 获取格子通过状态
--! @param 
--! @return 
--]]
function GuildMapLayer:getGridThroughState(inA, inB, inTempA, inTempB)
    -- local userList = self._guildMapModel:getData().userList
    -- local curOp = userList[self._userId].curOp
    -- print('curOp.defendGid===========', curOp.defendGid, inTempA , inTempB, inA, inB)
    -- if curOp ~= nil and next(curOp) ~= nil and curOp.defendGid == (inA .."," .. inB) then
    --     print("curOp====================================")
    --     return 1
    -- end
    if self:touchSafeArea(inTempA, inTempB) == true then 
        return 0
    end
    local guildMap = tab[self._settingData.mapTable]
    local sysGuildMap = guildMap["b" .. inB]
    if sysGuildMap ~= nil and 
        sysGuildMap["a" .. inA] ~=nil  then 
        if sysGuildMap["a" .. inA][1] == 0 then
            return 0
        end
    end

    local nearGuildMap = guildMap["b" .. inTempB]
    if nearGuildMap == nil  or nearGuildMap["a" .. inTempA]  == nil then
        return 0 
    end

    if nearGuildMap["a" .. inTempA][1] == 0 then 
        return 0
    end


    return 1
end

--[[
--! @function updateTipLocation
--! @desc 更新提示位置状态
--! @return 
--]]
function GuildMapLayer:updateTipLocation(inGrid)
    if 1 == 1 then return end
    if self:touchSafeArea(inGrid.a, inGrid.b) == true then 
        self._viewMgr:showTip(lang("GUILDMAPTIPS_10"))
        return 0
    end
    local isTouchOk = false

    local state = self:getGridState(inGrid.a, inGrid.b)
    if state == 1 then
        isTouchOk = true
    end
    local nearGrids = self:getNearGrids(tonumber(inGrid.a), tonumber(inGrid.b))
    if isTouchOk then 
        for i=1,6 do
            local tempGrid = nearGrids[i]
            local tempGridKey = tempGrid.grid.a .. "," .. tempGrid.grid.b
            if tempGrid.isLockState == 1 and  self._gridElements[tempGridKey] == nil then
                self._nearTipGrow[i]:setVisible(true)
                self._nearTipGrow[i]:setPosition(self._shapes[tempGridKey].pos)
                self._nearTipGrow[i].gridKey = tempGridKey
            else
                self._nearTipGrow[i].gridKey = nil
                self._nearTipGrow[i]:setVisible(false)
             end
        end          
        self._curTipMc:setVisible(true)
        self._curTipMc:setPosition(self._shapes[inGrid.a .. "," .. inGrid.b].pos)
        return
    end

    self._viewMgr:showTip(lang("GUILDMAPTIPS_10"))
    self._curTipMc:setVisible(false)
    -- self._nearGrids = self:getNearGrids(tonumber(self._curGrid.a), tonumber(self._curGrid.b))
    for i=1,6 do
        local tempGrid = nearGrids[i]

        self._nearTipGrow[i].gridKey = nil
        self._nearTipGrow[i]:setVisible(false)
    end   
end



--[[
--! @function touchRemoteGridEvent
--! @desc 远距离点击各自响应事件
--! @param a 移动各自A方向
--! @param b 移动各自B方向
--! @param inNotLoop 防止策划配置错误导致死循环
--! @return 
--]]
function GuildMapLayer:touchRemoteGridEvent(inA, inB, inNotLoop)
    if self._curGrid == nil then 
        return
    end
	
    print('touchRemoteGridEvent===============================', inA, inB)
    local touchGridKey = inA .. "," .. inB
    if self._gridFogs[touchGridKey]  ~= nil then 
        return
    end

    if self:touchEventPvp(inA, inB, true, true) then return end

    -- self:updateTipLocation(self:g(inA, inB))

    local gridElement = self._gridElements[touchGridKey] 
    if gridElement == nil then 
        return
    end
    if gridElement.isNihility == true then 
        self:removeEleByGridKey(touchGridKey)
        return
    end
    local sysGuildMapThing = tab.guildMapThing[tonumber(gridElement.eleId)]
    local showRemoteEventTip = {
        [1] = true, [2] = true, [3] = true, [5] = true, [6] = true, 
        [8] = true, [9] = true, [11] = true, [12] = true, [10] = true, 
        [15] = true, [16] = true, [17] = true, [20] = true, [21] = true, [22] = true, [23] = true, [26] = true, [27] = true, [28] = true,}
    if sysGuildMapThing ~= nil then
		if sysGuildMapThing.func==GuildConst.ELEMENT_EVENT_TYPE.OFFICER then
			local playerLevel = self._modelMgr:getModel("UserModel"):getPlayerLevel()
			local needLevel = tab:Setting("OFFICER_OPEN_LV").value
			if playerLevel<needLevel then
				self._viewMgr:showTip(lang("GUILD_MILITARY_TIP_5"))
				return
			end
		end
        if showRemoteEventTip[sysGuildMapThing.func] ~= nil and sysGuildMapThing.tip ~= nil and
            -- boss特殊处理  
            sysGuildMapThing.qiangdu ~= 1 then
   
            -- 检测是否可以点击，目前只有地下城
            if self["checkRemoteClickEvent" .. sysGuildMapThing.func] ~= nil then
                if self["checkRemoteClickEvent" .. sysGuildMapThing.func](self, inA, inB, touchGridKey) == true then
                    return
                end
            end
            local mapList = self._guildMapModel:getData().mapList
            if sysGuildMapThing.func == 11 then
                local touchGrid = mapList[touchGridKey] 
                if touchGrid.guild ~= nil and  
                    touchGrid.guild.haduse ~= nil and 
                    tonumber(touchGrid.guild.haduse) >= 1 then
                    self._viewMgr:showTip(lang("GUILDMAPTIPS_14"))
                    return
                end
            end
            local GuildMapUtils = require "game.view.guild.map.GuildMapUtils"
            local userLvl = self._modelMgr:getModel("UserModel"):getData().lvl
            local serverLvl = self._guildMapModel:getData().servLv
            local backDesc = GuildMapUtils:handleDesc(lang(sysGuildMapThing.tip), userLvl, serverLvl)                
            self._viewMgr:showTip(backDesc)
            return
        end
      
        if self["showEvent" .. sysGuildMapThing.func] ~= nil and inNotLoop ~= true then
            local param = { eventType = sysGuildMapThing.func,
                            targetId = touchGridKey, 
                            eleId = sysGuildMapThing.id, 
                            isRemote = true, 
                            targetPos = self._shapes[touchGridKey].pos,
                            parentView = self
                        }
            param.typeName = gridElement.typeName
            param.closePopCallback = function()
                if self.unLockTouch ~= nil then
                    self:unLockTouch()
                end    
            end
            self["showEvent" .. sysGuildMapThing.func](self, param)
            return
        end
    end

end


--[[
--! @function touchTagEvent
--! @desc 标记选择状态中点击事件
--! @param a 移动各自A方向
--! @param b 移动各自B方向
--! @param x 坐标x
--! @param y 坐标y
--! @return 
--]]
function GuildMapLayer:touchTagEvent(a, b, x, y)
    local gridKey = a .."," .. b

    local state = self:getGridState(a, b)
    if state == 0 then
        return
    end

    if self._gridFogs[gridKey] ~= nil then 
        self._viewMgr:showTip(lang("GUILDMAPSIGN_TIPS_1"))
        return
    end

    self._viewMgr:lock(-1)

    local build = self._gridElements[gridKey]
    local jiantouX, jiantouY = x, y + 50
    local wordsX, wordsY = x, y + 50
    if build then
        jiantouX, jiantouY = x, y + 50
        wordsX, wordsY = x, y + 50
    end

    local pointTip = mcMgr:createViewMC("jiantou_intancejiantou", true)
    pointTip:setPosition(wordsX, wordsY + 50)
    pointTip:setName("tag_jiantou")
    pointTip:setOpacity(0)
    self._bgSprite:addChild(pointTip, 1000)

    param = {}
    param.tagPoint = gridKey
    param.callback1 = function()    --确认
        if pointTip then
            pointTip:removeFromParent(true)
            pointTip = nil
        end

        self:setTagTouchState(false)
        self:removeEnableTag()
        self._parentView:refreshWidgetVisible(1)
        self._parentView:reflashPushMapTask()
        self._parentView:refreshTagBtn()
        self:createTagElement()        
    end
    param.callback2 = function()   --取消
        if pointTip then
            pointTip:removeFromParent(true)
            pointTip = nil
        end
    end

    pointTip:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.12, cc.p(wordsX, wordsY)),
        cc.DelayTime:create(0.05),
        cc.CallFunc:create(function()
            self._viewMgr:unlock()
            self._viewMgr:showDialog("guild.map.GuildMapTagView", param, true)
            end)
        ))  
end

--[[
--! @function touchYearTransEvent
--! @desc 新年使者传送状态
--! @param a 移动各自A方向
--! @param b 移动各自B方向
--! @param x 坐标x
--! @param y 坐标y
--! @return 
--]]
function GuildMapLayer:touchYearTransEvent(a, b, x, y)
	local gridKey = a .."," .. b

	local state = self:getGridState(a, b)
	if state == 0 or self._gridElements[gridKey]~=nil then
		return
	end

	if self._gridFogs[gridKey] ~= nil then 
		self._viewMgr:showTip(lang("GUILDMAPSIGN_TIPS_1"))
		return
	end
	
	local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
	local currentGuildId = self._guildMapModel:getData().currentGuildId
	local ignoreSafeArea = tostring(currentGuildId)~="center" and tostring(currentGuildId)~=tostring(guildId)
	if ignoreSafeArea and self._safeArea[gridKey] then
		self._viewMgr:showTip(lang("ERROR_TIPS1"))
		return
	end
	
	if self._gridElements[gridKey]==nil then
		DialogUtils.showShowSelect({desc = lang("CONFIRM_TIPS1"),callback1=function( )
			self:setYearTransTouchState(false)
			self:removeEnableYearTrans()
			self._parentView:refreshWidgetVisible(1, true)
			self:yearAmbMove(a, b, x, y)
		end})
	end
end

--[[
--! @function touchGridEvent
--! @desc 近距离点击各自响应事件
--! @param a 移动各自A方向
--! @param b 移动各自B方向
--! @param x 坐标x
--! @param y 坐标y
--! @return 
--]]
function GuildMapLayer:touchGridEvent(a, b, x, y)
    -- self:touchEventIcon(a, b)
    local touchEleIcon = self._bgSprite:getChildByName("Grid_" .. a .."," .. b)
    if touchEleIcon ~= nil then 
        touchEleIcon.eventDownCallback(x, y, touchEleIcon)
        touchEleIcon.eventUpCallback(x, y, touchEleIcon)
    else
        self:touchEventIcon(a, b)
    end
end

--[[
--! @function touchEventPvp
--! @desc 检测是否是pvp攻击
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @return 
--]]
function GuildMapLayer:touchEventPvp(inA, inB, inIsRemote)
    local touchGridKey = inA .. "," .. inB
    local flag = 0
    local tempUserIds = {}
    if self._gridPlayers[touchGridKey] ~= nil and 
        #self._gridPlayers[touchGridKey]> 0 then
        local lastHeroMc = self._gridPlayers[touchGridKey][#self._gridPlayers[touchGridKey]]
        if tostring(lastHeroMc.guildId) ~= tostring(self._guildId) and lastHeroMc:isVisible() == true then
            flag = 1
        else
            flag = 2
        end
        for k,v in pairs(self._gridPlayers[touchGridKey]) do
            table.insert(tempUserIds, v.userId)
        end
    end
    print("flag-===================", flag)
    if flag == 1 then 
        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local userList = self._guildMapModel:getData().userList
        -- 当前地形有限制
        local curOp = userList[self._userId].curOp
        if inIsRemote ~= true and curOp ~= nil and next(curOp) ~= nil and 
            curOp.locktime ~= nil and  
            curTime < tonumber(curOp.locktime) and 
            curOp.gid ~= touchGridKey then 
            self._viewMgr:showTip("正在进行其他操作，无法攻打别人")
            return true
        end
        self:showPVPEvent(touchGridKey, tempUserIds, inIsRemote == true)
        return true
    end
    if flag == 2 and inIsRemote == true then 
        if self._gridElements[touchGridKey] == nil then
            self:showPVPEvent(touchGridKey, tempUserIds, true)
            return true
        end
        return false
    end
    return false
end

--[[
--! @function checkRoleMoveEvent11
--! @desc 边境大门检测
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @param inTouchGridKey 操作点
--! @return 
--]]
function GuildMapLayer:checkRoleMoveEvent11(inA, inB, inTouchGridKey)
    local mapList = self._guildMapModel:getData().mapList
    local gridElement = self._gridElements[inTouchGridKey] 
    if mapList[inTouchGridKey] ~= nil and 
    mapList[inTouchGridKey][gridElement.typeName] ~= nil and 
    mapList[inTouchGridKey][gridElement.typeName].haduse ~= nil and
    tonumber(mapList[inTouchGridKey][gridElement.typeName].haduse) >= 1 then
        return true
    end
    return false
end


--[[
--! @function checkRoleMoveEvent16
--! @desc 地下城城门检测
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @param inTouchGridKey 操作点
--! @return 
--]]
function GuildMapLayer:checkClickEvent16(inA, inB, inTouchGridKey)
    return self:checkRoleMoveEvent15(inA, inB, inTouchGridKey)
end


--[[
--! @function checkRemoteClickEvent16
--! @desc 地下城城门远程点击检测
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @param inTouchGridKey 操作点
--! @return 
--]]
function GuildMapLayer:checkRemoteClickEvent16(inA, inB, inTouchGridKey)
    return self:checkRoleMoveEvent15(inA, inB, inTouchGridKey)
end

--[[
--! @function checkRemoteClickEvent16
--! @desc 地下城城门远程点击检测
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @param inTouchGridKey 操作点
--! @return 
--]]
function GuildMapLayer:checkRemoteClickEvent15(inA, inB, inTouchGridKey)
    return self:checkRoleMoveEvent15(inA, inB, inTouchGridKey)
end


--[[
--! @function checkRoleMoveEvent15
--! @desc 中立地图大门检测
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @param inTouchGridKey 操作点
--! @return 
--]]
function GuildMapLayer:checkRoleMoveEvent15(inA, inB, inTouchGridKey)
    local mapList = self._guildMapModel:getData().mapList
    local gridElement = self._gridElements[inTouchGridKey] 

    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    if mapList[inTouchGridKey] ~= nil and 
        mapList[inTouchGridKey][gridElement.typeName] ~= nil then
        if mapList[inTouchGridKey][gridElement.typeName].openTime == nil then 
            return true
        end
        local openTime = tonumber(mapList[inTouchGridKey][gridElement.typeName].openTime)
        if openTime > 1 and openTime <= curTime then 
            return true
        end
    end
    return false
end

--[[
--! @function touchSafeArea
--! @desc 安全区限制点击
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @return 
--]]
function GuildMapLayer:touchSafeArea(inA, inB)
    local touchGridKey = inA .. "," .. inB
    if self._currentGuildId ~= "center" then
        if self._safeArea[touchGridKey] == nil then return false end

        if tostring(self._currentGuildId) ~= tostring(self._guildId) then
            return true
        end
    else
        local guildList = self._guildMapModel:getData().guildList
        for k,v in pairs(guildList) do
            if v.sid ~= nil and tostring(k) ~= tostring(self._guildId) and self._centerSafeArea[v.sid + 1] ~= nil then 
                if self._centerSafeArea[v.sid + 1][touchGridKey] ~= nil then 
                    return true
                end
            end
        end
    end

    return false
end


--[[
--! @function touchEventIcon
--! @desc 近距离点击操作
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @return 
--]]
function GuildMapLayer:touchEventIcon(inA, inB)
    print("touchEventIcon================================")
    local touchGridKey = inA .. "," .. inB
    if self._gridFogs[touchGridKey]  ~= nil then 
        return
    end

    print("1pvp============================================")
    -- 检测是否是pvp攻击
    if self:touchEventPvp(inA, inB) then return end
    print("2pvp============================================")
    -- 没有建筑位置
    local gridElement = self._gridElements[touchGridKey]
    if gridElement == nil or (gridElement and tonumber(gridElement.eleId)==9001) then --秘境传送门特殊处理，防堵路
        self:roleMove(inA, inB)
		if gridElement == nil then
			return
		end
    end
    if gridElement.isNihility == true then 
        self:removeEleByGridKey(touchGridKey)
        return
    end
    local mapList = self._guildMapModel:getData().mapList
    local sysGuildMapThing = tab.guildMapThing[tonumber(gridElement.eleId)]
    if sysGuildMapThing ~= nil and gridElement.lock ~= true then 
        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        local userList = self._guildMapModel:getData().userList
        -- 限制地形按照远程访问提示
        if userList[self._userId] ~= nil then
            local curOp = userList[self._userId].curOp
            if curOp ~= nil and next(curOp) ~= nil and 
                curOp.locktime ~= nil and  
                curTime < tonumber(curOp.locktime) and 
                curOp.gid ~= touchGridKey then 
                self:touchRemoteGridEvent(inA, inB, true)
                return
            end
        end

        -- 根据建筑类型检查是否可以移动
        if self["checkRoleMoveEvent" .. sysGuildMapThing.func] ~= nil then
            if self["checkRoleMoveEvent" .. sysGuildMapThing.func](self, inA, inB, touchGridKey) == true then
                self:roleMove(inA, inB)
            else
                self:touchRemoteGridEvent(inA, inB, true)
            end
            return
        end
        -- 检测是否可以点击，目前只有地下城
        if self["checkClickEvent" .. sysGuildMapThing.func] ~= nil then
            if self["checkClickEvent" .. sysGuildMapThing.func](self, inA, inB, touchGridKey) == false then
                self:touchRemoteGridEvent(inA, inB, true)
                return
            end
        end


        print('sysGuildMapThing.func====', sysGuildMapThing.func)

        if self["showEvent" .. sysGuildMapThing.func] ~= nil and gridElement.lock ~= true then 
            local param = {eventType = sysGuildMapThing.func, targetId = touchGridKey, eleId = sysGuildMapThing.id, isRemote = false, targetPos = self._shapes[touchGridKey].pos}
            param.typeName = gridElement.typeName
            param.parentView = self
            -- param.closePopCallback = function()
            --     self:unLockTouch()
            -- end 
            self["showEvent" .. sysGuildMapThing.func](self, param)
            return
        end

        self._viewMgr:showTip("功能赶制中，稍安勿躁")
    end
   
    return true
end

function GuildMapLayer:checkLockRoleState()
    local userList = self._guildMapModel:getData().userList

    if userList[self._userId] == nil then return false end

    -- 当前是否有限制形移动
    local curOp = userList[self._userId].curOp
    if curOp == nil or next(curOp) == nil then 
        return false
    end

    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    -- 占领其他地方无法移动
    if curOp.locktime ~= nil and  curTime < tonumber(curOp.locktime) then 
        local gridElement = self._gridElements[curOp.gid] 
        if gridElement ~= nil then 
            local sysGuildMapThing = tab.guildMapThing[tonumber(gridElement.eleId)]
            if sysGuildMapThing ~= nil then 
                if sysGuildMapThing.func ~= GuildConst.ELEMENT_EVENT_TYPE.OUTPUT_GOLD then
                    self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_3016"))
                else
                    self._viewMgr:showTip(lang("GUILD_MAP_RESULT_CODE_TIP_3025"))
                end
                return true 
            end
        end
        
        self._viewMgr:showTip("占领中，不能移动")
        return true
    end
    return false
end

--[[
--! @function checkLockRoleMove
--! @desc 检查有限制锁住玩家
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @return 
--]]
function GuildMapLayer:checkLockRoleMove(inA, inB)
    local userList = self._guildMapModel:getData().userList
    if userList == nil then return false end
    -- 当前是否有限制形移动
    local curOp = userList[self._userId].curOp
    if curOp == nil or next(curOp) == nil then 
        return false
    end
    if self:checkLockRoleState() == true then return true end
    print("curOp.defendGid===============", curOp.defendGid)
    -- 城内离开判断
    if curOp.defendGid ~= nil then 
        local guildPower = self._modelMgr:getModel("UserModel"):getData().guildPower
        if guildPower < 10 then 
            self._viewMgr:showTip("行动力不足")
            return true
        end
        self:leaveCenterCity(inA .. "," .. inB)
        return true
    end

    return false
end

--[[
--! @function roleMove
--! @desc 处理当前玩家移动
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @return 
--]]
function GuildMapLayer:roleMove(inA, inB)
    if self:checkLockRoleMove(inA, inB) == true then return end

    if (inA .. "," .. inB) == (self._curGrid.a .. "," .. self._curGrid.b) then 
        return
    end
    self._serverMgr:sendMsg("GuildMapServer", "roleMove", {tagPoint = inA .. "," .. inB}, true, {}, function(result, error)
        if error ~= 0 then 
            if error == 3003 then 
                self._viewMgr:showTip("行动力不足")
                return
			elseif error == 3048 then--代表触发了联盟秘境
				return
            end
        end
        if result == nil or result.code == 1 then 
            return
        end
        if self.listenModelRoleMoveCur == nil then return end
		if result.reward then
			DialogUtils.showGiftGet({gifts = result.reward, notPop = true})
		end
        self:listenModelRoleMoveCur()
    end)
end



--[[
--! @function openFog
--! @desc 开启迷雾
--! @param inFogs table 迷雾集合 需要优化迷雾
--! @return 
--]]
function GuildMapLayer:openFog(inFogs, inAnim)
    if inFogs == nil or next(inFogs) == nil then 
        return
    end
    -- dump(inFogs,"test", 10)
    for k,v in pairs(inFogs) do
        local tempKey = v.a .."," .. v.b
        if self._gridFogs[tempKey] ~= nil then 
            
            -- self._gridFogs[tempKey]:setOpacity(80)
            if inAnim == nil or inAnim == true then
                self._gridFogs[tempKey]:runAction(cc.Sequence:create(cc.FadeOut:create(0.3), cc.CallFunc:create(function()
                    self._gridFogs[tempKey]:removeFromParent()
                    self._gridFogs[tempKey] = nil
                end)))
                if self._gridElements[tempKey] ~= nil then 
                    self._gridElements[tempKey]:setVisible(true)
                    self._gridElements[tempKey]:setOpacity(0)
                    self._gridElements[tempKey]:runAction(cc.FadeIn:create(1))
                    local earthAnim = self._gridElements[tempKey].earthAnim
                    if earthAnim then
                        earthAnim:setVisible(true)
                    end
                end
            else
                self._gridFogs[tempKey]:removeFromParent()
                self._gridFogs[tempKey] = nil
                if self._gridElements[tempKey] ~= nil then 
                    self._gridElements[tempKey]:setVisible(true)
                    local earthAnim = self._gridElements[tempKey].earthAnim
                    if earthAnim then
                        earthAnim:setVisible(true)
                    end
                end                
            end
            local gridPlayers = self._gridPlayers[tempKey]
            if gridPlayers ~= nil and next(gridPlayers) ~= nil then 
                local lastHeroMc = gridPlayers[#gridPlayers]
                if lastHeroMc ~= nil then 
                    lastHeroMc.isLock = false
                    lastHeroMc:setOpacity(255)
                    lastHeroMc:setVisible(true)
                end
            end
        end
        local fogs = self._guildMapModel:getData().fogs
        fogs[tempKey] = nil
    end
    -- self:initFogs()
end

--[[
--! @function moveToGridByMyself
--! @desc 移动我自己的位置
--! @param inA 移动各自A方向
--! @param inB 移动各自B方向
--! @param inAnim 是否动画
--! @param inFollowScreen 是否跟随屏幕
--! @param inCallback 移动完成callback
--! @return
--]]
function GuildMapLayer:moveToGridByMyself(inA, inB, inAnim, inFollowScreen, inCallback)
    self._curPlayerMc:setVisible(false)
    -- 隐藏所要移动区域的其他玩家mc
    local curGridPlayers = self._gridPlayers[self._curGrid.a .. "," ..  self._curGrid.b]
    if curGridPlayers ~= nil then 
        local lastHeroMc = curGridPlayers[#curGridPlayers]
        -- 因为初始化时已经过滤了显示，所以当前玩家不在_gridPlayers数据集中，可直接取最后一人
        if lastHeroMc ~= nil then 
            lastHeroMc:setVisible(true)
            lastHeroMc.isLock = false
            lastHeroMc:setAdjustLocalZOrder(lastHeroMc:getLocalZOrder())
        end 
    end    
    self._curGrid = self:g(inA, inB)
    self:moveToGrid(self._intanceMcAnimNode, inA, inB, inAnim, inFollowScreen, function(inX, inY)
        self._curPlayerMc:setPosition(cc.p(inX, inY))
        self._curPlayerMc:setVisible(true)
        self:updateNearLocation()
        
        local otherRoleMoveEvent = self._guildMapModel:getEvents()["RoleMove_CUR"]
        if otherRoleMoveEvent ~= nil and otherRoleMoveEvent.fog ~= nil then 
            self._guildMapModel:getEvents()["RoleMove_CUR"] = nil
            self:openFog(otherRoleMoveEvent.fog)    
        end

        local curGridPlayers = self._gridPlayers[inA .. "," ..  inB]
        if curGridPlayers ~= nil then 
            local lastHeroMc = curGridPlayers[#curGridPlayers]
            -- 因为初始化时已经过滤了显示，所以当前玩家不在_gridPlayers数据集中，可直接取最后一人
            if lastHeroMc ~= nil then 
                lastHeroMc:setVisible(false)
                lastHeroMc.isLock = true
            end
        end        
        if inCallback ~= nil then 
            inCallback()
        end
        
    end)   
end


--[[
--! @function touchGuideArrow
--! @desc 点击方向箭头头像
--! @return
--]]
function GuildMapLayer:touchGuideArrow(sender)
    if self._curGrid == nil then 
        return
    end
    sender:setTouchEnabled(false)
    self:lockTouch()
    self:screenToGrid(self._curGrid.a, self._curGrid.b, true, function()
        self._guideArrow:setVisible(false)
        sender:setTouchEnabled(true)
        self:unLockTouch()
    end, false, nil, 0.5)
end


--[[
--! @function touchGuideArrow
--! @desc 点击方向箭头头像
--! @return
--]]
function GuildMapLayer:screenToGridAndDelayBack(inA, inB,  callback)
    if self._curGrid == nil then 
        return
    end
    self._viewMgr:lock(-1)
    self:screenToGrid(inA, inB, true, function()
        ScheduleMgr:delayCall(1000, self, function ()
            self:screenToGrid(self._curGrid.a, self._curGrid.b, true, function()
                self._viewMgr:unlock()
                if callback ~= nil then callback() end
            end, false, nil, 0.5)
        end)
    end)

end


--[[
--! @function removeUserByGridKeyAndUserId
--! @desc 根据各自id与用户id删除地图上相关展示
--! @param inGridKey 各自位置
--! @param inUserId 用户id
--! @return 
--]]
function GuildMapLayer:removeUserByGridKeyAndUserId(inGridKey, inUserId)
    print("0=removeUserByGridKeyAndUserId===============")
    local gridPlayers = self._gridPlayers[inGridKey]
    if gridPlayers ~= nil  then 
        print("1=removeUserByGridKeyAndUserId===============")
        local tempHero = nil
        local removeIndex = 0
        for k,v in pairs(gridPlayers) do
            if v.userId == inUserId then 
                removeIndex = k
                tempHero = v
                break
            end
        end

        -- 优先其他移除计时队里内数据，以免不必要错误
        self._playerTimngQueue[inUserId] = nil
        self._userMcs[inUserId] =  nil
        self._userGridKeys[inUserId] = nil

        if removeIndex > 0 then 
            table.remove(gridPlayers, removeIndex)
        end
        removeIndex = 0
        for k,v in pairs(self._mcfps) do
            if v.userId == inUserId then 
                removeIndex = k
                break
            end
        end
        if removeIndex > 0 then 
            table.remove(self._mcfps, removeIndex)
        end
        print("1=removeUserByGridKeyAndUserId===============", tempHero, removeIndex)

        if tempHero ~= nil then 
            tempHero:stop()
            tempHero:clear()
        end
    end
end

function GuildMapLayer:showBuildingTalk(inSysGuildMapThing, inBuildingIcon, inPt)
    local labTalk = nil 
    if inBuildingIcon.talk ~= nil then 
        inBuildingIcon.talk.closeTime = os.time() + 5
        return
    end
    local talkBg = cc.Sprite:createWithSpriteFrameName("globalImageUI5_sayBg.png")
    talkBg:setPosition(27+ inBuildingIcon:getContentSize().width * 0.5, inBuildingIcon:getContentSize().height - 24)
    talkBg:setAnchorPoint(0.5, 0)
    labTalk = cc.Label:createWithTTF(lang(inSysGuildMapThing.words), UIUtils.ttfName, 16, cc.size(100, 0))
    labTalk:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    labTalk:setPosition(68, 45)
    labTalk:setAnchorPoint(0.5, 0.5)
    labTalk:setDimensions(100, 0)
    labTalk:setVerticalAlignment(1)
    labTalk:setHorizontalAlignment(1)
    labTalk:setName("labTalk")
    talkBg:addChild(labTalk)
    
    inBuildingIcon:addChild(talkBg, 11)
    inBuildingIcon.talk = talkBg
    talkBg:stopAllActions()
    talkBg:setVisible(inBuildingIcon:isVisible())

    if (labTalk:getContentSize().height * labTalk:getScaleX())> (30* labTalk:getScaleX()) then
        labTalk:setScale(0.8)
    else
        labTalk:setScale(1)
    end
    labTalk:setPosition(talkBg:getContentSize().width/2, talkBg:getContentSize().height/2+ 10)
    talkBg:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(1), 
                cc.CallFunc:create(function() 
                        if talkBg.closeTime < os.time() then 
                            talkBg:stopAllActions()
                            talkBg:removeFromParent(true)
                            inBuildingIcon.talk = nil
                        end
                    end
                    )
                )
            )
        )
    talkBg.closeTime = os.time() + 5
end

function GuildMapLayer:stopBattleTip()
    if self._parentView.battleTip ~= nil then
        self._parentView.battleTip:stopAllActions()
        self._parentView.battleTip:setOpacity(0)
        self._isRunBattleTip = false
    end
end

function GuildMapLayer:activeBattleTip()
    if self._isRunBattleTip == true then return end
    if self._parentView == nil then self._isRunBattleTip = false return end
    if self._viewMgr:getCurViewName() ~= self._parentView:getClassName() then self._isRunBattleTip = false return end

    if #self._battleTips == 0  then self._isRunBattleTip = false return end
    local userId = self._modelMgr:getModel("UserModel"):getData()._id

    self._isRunBattleTip = true
    local tmpMessage = self._battleTips[#self._battleTips]
    table.remove(self._battleTips, #self._battleTips)

    local avatar = tonumber(tmpMessage.win.avatar)
    if avatar == 0 then
        avatar = 1101
    end
    local art = (tab:RoleAvatar(avatar) and tab:RoleAvatar(avatar).icon) or tab:RoleAvatar(1101).icon
    local fu = cc.FileUtils:getInstance()
    local sfc = cc.SpriteFrameCache:getInstance()
    local leftFilename = art .. ".jpg"
    if sfc:getSpriteFrameByName(leftFilename) then
        leftFilename = art .. ".jpg"
    elseif sfc:getSpriteFrameByName(art ..".png") then
        leftFilename = art .. ".png"
    end

    local avatar = tonumber(tmpMessage.lose.avatar)
    if avatar == 0 then
        avatar = 1101
    end
    local art = (tab:RoleAvatar(avatar) and tab:RoleAvatar(avatar).icon) or tab:RoleAvatar(1101).icon
    local fu = cc.FileUtils:getInstance()
    local sfc = cc.SpriteFrameCache:getInstance()
    local rightFilename = art .. ".jpg"
    if sfc:getSpriteFrameByName(rightFilename) then
        rightFilename = art .. ".jpg"
    elseif sfc:getSpriteFrameByName(art ..".png") then
        rightFilename = art .. ".png"
    end

    if self._parentView.battleTip == nil then 
        local bg = ccui.Widget:create()
        bg:setContentSize(571, 134)
        bg:setAnchorPoint(0.5, 1)
        bg:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT - 50)
        self._parentView:addChild(bg, 100)
        self._parentView.battleTip = bg
    end
    local bg = self._parentView.battleTip

    if bg.batteState == nil then 
        local batteState = cc.Sprite:createWithSpriteFrameName("guildMap2Img_battleTipBg1.png")
        batteState:setPosition(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.5)
        bg:addChild(batteState)
        bg.batteState = batteState

        local sp = cc.Sprite:createWithSpriteFrameName(leftFilename)
        local clipNode = cc.ClippingNode:create()
        clipNode:setInverted(false)

        
        local mask = cc.Sprite:createWithSpriteFrameName("guildMapBtn_iconMask.png")
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.05)
        clipNode:addChild(sp)
        clipNode:setScale(0.8)
        clipNode:setPosition(70, 65)
        bg:addChild(clipNode)
        bg.leftIcon = sp

        local mask = cc.Sprite:createWithSpriteFrameName("guildMap2Img_battleTipIcon2.png")
        mask:setPosition(70, 65)
        bg:addChild(mask)
        bg.leftMask = mask

        local leftNameLab = cc.Label:createWithTTF(tmpMessage.win.name, UIUtils.ttfName, 16)
        leftNameLab:setPosition(105, 75)
        leftNameLab:setAnchorPoint(0, 0.5)
        leftNameLab:setColor(cc.c3b(248, 240, 198))
        bg:addChild(leftNameLab)        
        bg.leftNameLab = leftNameLab


        local leftTmpLab = cc.Label:createWithTTF("生命:", UIUtils.ttfName, 16)
        leftTmpLab:setPosition(105, 53)
        leftTmpLab:setAnchorPoint(0, 0.5)

        leftTmpLab:setColor(cc.c3b(248, 240, 198))
        bg:addChild(leftTmpLab)        

        local leftHpLab = cc.Label:createWithTTF(tmpMessage.win.after .. "(-" .. tmpMessage.win.less .. ")", UIUtils.ttfName, 16)
        leftHpLab:setPosition(143, 53)
        leftHpLab:setAnchorPoint(0, 0.5)
        bg:addChild(leftHpLab) 
        bg.leftHpLab = leftHpLab
        leftHpLab:setColor(UIUtils.colorTable.ccUIBaseColor2)

        local sp = cc.Sprite:createWithSpriteFrameName(rightFilename)
        local clipNode = cc.ClippingNode:create()
        clipNode:setInverted(false)
        
        local mask = cc.Sprite:createWithSpriteFrameName("guildMapBtn_iconMask.png")
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.05)
        clipNode:addChild(sp)
        clipNode:setScale(0.8)
        clipNode:setPosition(400, 65)
        bg:addChild(clipNode)
        bg.rightIcon = sp
        
        local mask = cc.Sprite:createWithSpriteFrameName("guildMap2Img_battleTipIcon1.png")
        mask:setPosition(400, 65)
        bg:addChild(mask)
        bg.rightMask = mask

        local mask = cc.Sprite:createWithSpriteFrameName("guildMap2Img_battleTipTmp1.png")
        mask:setPosition(400, 65)
        bg:addChild(mask)  


        local rightNameLab = cc.Label:createWithTTF(tmpMessage.lose.name, UIUtils.ttfName, 16)
        rightNameLab:setPosition(435, 75)
        rightNameLab:setAnchorPoint(0, 0.5)
        rightNameLab:setColor(cc.c3b(248, 240, 198))
        bg:addChild(rightNameLab)        
        bg.rightNameLab = rightNameLab     


        local rightTmpLab = cc.Label:createWithTTF("生命:", UIUtils.ttfName, 16)
        rightTmpLab:setPosition(435, 53)
        rightTmpLab:setAnchorPoint(0, 0.5)
        rightTmpLab:setColor(cc.c3b(248, 240, 198))
        bg:addChild(rightTmpLab)          


        local rightHpLab = cc.Label:createWithTTF(tmpMessage.lose.after .. "(-" .. tmpMessage.lose.less .. ")", UIUtils.ttfName, 16)
        rightHpLab:setPosition(473, 53)
        rightHpLab:setAnchorPoint(0, 0.5)
        bg:addChild(rightHpLab) 
        bg.rightHpLab = rightHpLab
        rightHpLab:setColor(UIUtils.colorTable.ccUIBaseColor6)
    end
    bg.leftNameLab:setString(tmpMessage.win.name)
    bg.rightNameLab:setString(tmpMessage.lose.name)
    
    bg.leftHpLab:setString(tmpMessage.win.after .. "(-" .. tmpMessage.win.less .. ")")
    bg.rightHpLab:setString(tmpMessage.lose.after .. "(-" .. tmpMessage.lose.less .. ")")
    bg.leftIcon:setSpriteFrame(leftFilename)
    bg.rightIcon:setSpriteFrame(rightFilename)

    if userId == tmpMessage.win.rid then 
        bg.batteState:setSpriteFrame("guildMap2Img_battleTipBg2.png")
        bg.leftMask:setSpriteFrame("guildMap2Img_battleTipIcon2.png")
        bg.rightMask:setSpriteFrame("guildMap2Img_battleTipIcon1.png")
    else
        bg.batteState:setSpriteFrame("guildMap2Img_battleTipBg1.png")
        bg.leftMask:setSpriteFrame("guildMap2Img_battleTipIcon1.png")
        bg.rightMask:setSpriteFrame("guildMap2Img_battleTipIcon2.png")
    end

    bg:setCascadeOpacityEnabled(true, true)
    bg:setOpacity(0)
    bg:runAction(cc.Sequence:create(
            cc.FadeIn:create(0.3),
            cc.DelayTime:create(1.5),
            cc.FadeOut:create(0.5),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function()
                self._isRunBattleTip = false
				if self.activeBattleTip then
					self:activeBattleTip()
				end
            end)
        ))
end

--[[
--! @function leaveCenterCity
--! @desc 离开中立点城池请求
--! @param inTagPoint 移动到点
--! @return 
--]]
function GuildMapLayer:leaveCenterCity(inTagPoint)
    self._serverMgr:sendMsg("GuildMapServer", "leaveCenterCity", {tagPoint = inTagPoint}, true, {}, function(result)
        self:listenModelEleStateCur()
        self:listenModelRoleMoveCur()  
        if result["reward"] ~= nil and next(result["reward"]) ~= nil and result.cityTime ~= nil and result["reward"][1][3] > 0 then
            self._viewMgr:showDialog("guild.map.GuildMapInfoTipView", {reward = result["reward"][1], time = result.cityTime, showType = 1}, true)
        end
    end)
end

function GuildMapLayer:getMapBg()
    return self._settingData.bgImg
    -- return {"asset/uiother/guildMap/0001.jpg", "asset/uiother/guildMap/0002.jpg", "asset/uiother/guildMap/0003.jpg"}
     --return self._settingData.bgImg .. ".jpg"
end


function GuildMapLayer:setTagTouchState(inState)
    self._isTagTouch = inState
end
function GuildMapLayer:getTagTouchState()
    return self._isTagTouch
end


--新年使者点击地图传送
function GuildMapLayer:setYearTransTouchState(inState)
	self._isYearTransTouch = inState
end
function GuildMapLayer:getYearTransTouchState()
	return self._isYearTransTouch
end

function GuildMapLayer:setYearMissFogLockState(inState)
	if inState then
		self._viewMgr:lock(-1)
	else
		self._viewMgr:unlock()
	end
	self._yearMissFogLockState = inState
end

function GuildMapLayer:getYearMissFogLockState()
	return self._yearMissFogLockState
end


function GuildMapLayer:getGridScale()
    print("self._settingData.param[1]==========", self._settingData.param[1])
    return self._settingData.param[1]
end

function GuildMapLayer:getMaxVerticalGrid()
    return self._settingData.param[2]
end

function GuildMapLayer:getMaxHorizontalGrid()
    return self._settingData.param[3]
end

function GuildMapLayer:getFirstGridPoint()
    return self._settingData.param[4], self._settingData.param[5]
end

function GuildMapLayer:getMaxScrollHeightPixel(inScale)
    if self._settingData.param[6] == nil then 
        return 1457
    else
        return self._settingData.param[6]
    end
end

function GuildMapLayer:getMaxScrollWidthPixel(inScale)
    if self._settingData.param[7] == nil then 
        return 2848
    else
        return self._settingData.param[7]
    end    
end

return GuildMapLayer

 