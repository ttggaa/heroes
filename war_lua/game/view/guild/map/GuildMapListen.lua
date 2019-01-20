--[[
    Filename:    GuildMapListen.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-07-03 14:33:04
    Description: File description
--]]

local GuildMapLayer = require("game.view.guild.map.GuildMapLayer")

function GuildMapLayer:listenModelSkipPosCur()
    local otherSkipPosEvent = self._guildMapModel:getEvents()["SkipPos_CUR"]
    self:handleListenModelMyselfSkipPos(otherSkipPosEvent)
    self._guildMapModel:getEvents()["SkipPos_CUR"] = nil
end
 
function GuildMapLayer:listenModelSkipPos()
    local otherSkipPosEvent = self._guildMapModel:getEvents()["SkipPos"]
    self:handleListenModelSkipPos(otherSkipPosEvent)
    self._guildMapModel:getEvents()["SkipPos"] = nil
end


--[[
--! @function handleListenModelMyselfSkipPos
--! @desc 传送到其他地方
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelMyselfSkipPos(otherSkipPosEvent)
    print("handleListenModelMyselfSkipPos====================================")

    local playerWillGoGridKey = otherSkipPosEvent["end"]
    local endGridData = self._shapes[playerWillGoGridKey]
    if endGridData == nil then return end

    self._viewMgr:lock(-1)
    local order = self._intanceMcAnimNode:getLocalZOrder()
    local backcity1 = mcMgr:createViewMC("huicheng1_guildmaphuicheng", false, true, function()

    end)
    backcity1:setPosition(self._intanceMcAnimNode:getPosition())
    self._bgSprite:addChild(backcity1, order - 1)
    self._intanceMcAnimNode:setLocalZOrder(200 + (endGridData.grid.a  + endGridData.grid.b))
    local backcity2 = mcMgr:createViewMC("huicheng2_guildmaphuicheng", false, true, function()
        self:moveToGridByMyself(endGridData.grid.a, endGridData.grid.b, false, true, function()
            self._userGridKeys[self._userId] = playerWillGoGridKey
            local backcity3 = mcMgr:createViewMC("huicheng3_guildmaphuicheng", false, true, function()

            end)
            backcity3:setPosition(endGridData.pos.x, endGridData.pos.y)
            self._bgSprite:addChild(backcity3, order - 1)
            self._intanceMcAnimNode:setLocalZOrder(100 + (endGridData.grid.a  + endGridData.grid.b))
            local backcity4 = mcMgr:createViewMC("huicheng4_guildmaphuicheng", false, true, function()
                self._viewMgr:unlock()
            end)
            self._bgSprite:addChild(backcity4, order + 1)
            backcity4:setPosition(endGridData.pos.x, endGridData.pos.y)
			
			local tempGrids = self:getCircleGrids(endGridData.grid.a, endGridData.grid.b, 2)
			self:openFog(tempGrids)
        end)
    end)
    self._bgSprite:addChild(backcity2, order + 1)
    backcity2:setPosition(self._intanceMcAnimNode:getPosition())
end

--[[
--! @function handleListenModelSkipPos
--! @desc 传送到其他地方
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelSkipPos(otherSkipPosEvent)
    print("handleListenModelSkipPos====================================")
    if otherSkipPosEvent == nil then 
        return
    end
    -- self:openFog(otherSkipPosEvent.fog)

    local playerInBeginGridKey = otherSkipPosEvent["begin"]
    if playerInBeginGridKey== nil  or playerInBeginGridKey == nil then 
        return
    end

    -- 移动起始点处理
    local gridPlayersBegin = self._gridPlayers[playerInBeginGridKey]
    if gridPlayersBegin == nil or #gridPlayersBegin == 0 then 
        return
    end

    local heroMc = nil
    local heroIndex = 0
    for k,v in pairs(gridPlayersBegin) do
        if v.userId == otherSkipPosEvent.userId then 
            heroIndex = k
            heroMc = v
            break
        end
    end
    if heroMc == nil then 
        return
    end
    table.remove(gridPlayersBegin, heroIndex)


    -- 移动结束点处理
    local playerWillGoGridKey = otherSkipPosEvent["end"]
    if self._shapes[playerWillGoGridKey] == nil then
        otherSkipPosEvent.currentGuildId =  self._guildMapModel:getData().currentGuildId
        ApiUtils.playcrab_lua_error("GuildMapListen Verify Will Go Grid", serialize(otherSkipPosEvent))
        return
    end
        
    if self._gridFogs[playerWillGoGridKey] == nil then
        -- 默认最大的显示，需求是同一点只有一人显示
        local lastHeroMc = gridPlayersBegin[#gridPlayersBegin]
        if lastHeroMc ~= nil then 
            lastHeroMc.isLock = false
            lastHeroMc:setOpacity(255)
            lastHeroMc:setVisible(true)
        end

        heroMc.isLock = false
        heroMc:setVisible(true)
        heroMc:setOpacity(255)
        heroMc:runByName("run")
    end

    local endGrid = self._shapes[playerWillGoGridKey].grid
    local tempGrids = self:getCircleGrids(endGrid.a, endGrid.b, 2)
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    if tostring(heroMc.guildId) == tostring(guildId) then 
        self:openFog(tempGrids)
    end

    local gridPlayersEnd = self._gridPlayers[playerWillGoGridKey]
    if gridPlayersEnd == nil then 
        gridPlayersEnd = {}
        self._gridPlayers[playerWillGoGridKey] = gridPlayersEnd
    end

    heroMc:setLocalZOrder(100 + (endGrid.a  + endGrid.b))

    self:moveToGrid(heroMc, endGrid.a, endGrid.b, false, false, function()
        self._userGridKeys[heroMc.userId] = playerWillGoGridKey
        heroMc:runByName("stop")
        if #gridPlayersEnd > 0 then 
            gridPlayersEnd[#gridPlayersEnd]:setVisible(false)
            gridPlayersEnd[#gridPlayersEnd].isLock = true
        end
        gridPlayersEnd[#gridPlayersEnd + 1] = heroMc
        self._viewMgr:unlock()
        if self._curGrid.a == endGrid.a and  self._curGrid.b == endGrid.b then 
            heroMc:setVisible(false)
            heroMc.isLock = true
            self._intanceMcAnimNode:setLocalZOrder(100 + (endGrid.a  + endGrid.b))
        end
    end)
end



function GuildMapLayer:listenModelRoleMoveCur()
    local otherRoleMoveEvent = self._guildMapModel:getEvents()["RoleMove_CUR"]
    self:handleListenModelMyselfRoleMove(otherRoleMoveEvent)
    self._guildMapModel:getEvents()["RoleMove_CUR"] = nil
end

function GuildMapLayer:listenModelRoleMove()
    local otherRoleMoveEvent = self._guildMapModel:getEvents()["RoleMove"]
    self:handleListenModelRoleMove(otherRoleMoveEvent)
    self._guildMapModel:getEvents()["RoleMove"] = nil
end


--[[
--! @function handleListenModelRoleMove
--! @desc 监听其他玩家移动
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelMyselfRoleMove(otherRoleMoveEventKey)
    print("handleListenModelMyselfRoleMove====================================")
    if otherRoleMoveEventKey == nil then 
        return
    end

    -- 移动结束点处理
    if self._userGridKeys[self._userId] == otherRoleMoveEventKey then
        return
    end
    local endGrid = self._shapes[otherRoleMoveEventKey].grid
    if endGrid == nil then 
        return
    end
    self:lockTouch()
    
    local tempGrids = self:getCircleGrids(endGrid.a, endGrid.b, 2)

    self:openFog(tempGrids)
    
    self._intanceMcAnimNode:runByName("run")
    self._intanceMcAnimNode:setLocalZOrder(200 + (endGrid.a  + endGrid.b))
    self:moveToGridByMyself(endGrid.a, endGrid.b, true, true, function()

        self._intanceMcAnimNode:setLocalZOrder(100 + (endGrid.a  + endGrid.b))
        self._userGridKeys[self._userId] = otherRoleMoveEventKey
        self._intanceMcAnimNode:runStandBy()
        self:unLockTouch()
        local nearGrids = self:getCircleGrids(endGrid.a, endGrid.b, 2)
        for k1,v1 in pairs(nearGrids) do
            local gridElement = self._gridElements[k1]
            if gridElement ~= nil and gridElement.runNearAction ~= nil then 
                gridElement:runNearAction(v1.dis)
            end
        end
        local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
        local currentGuildId = self._guildMapModel:getData().currentGuildId
        local isSelfMap = (tostring(guildId) == tostring(currentGuildId))
        if self._intanceMcAnimNode and self._intanceMcAnimNode.compass then
            self._intanceMcAnimNode.compass:setVisible(isSelfMap)
            self._intanceMcAnimNode.treasureDisBg:setVisible(isSelfMap)
        end
        if not isSelfMap then
            return
        end
		
		self:reloadTreasureCompass()
    end)
end

--[[
--! @function handleListenModelRoleMove
--! @desc 监听其他玩家移动
--! @param 
--! @return  
--]]
function GuildMapLayer:handleListenModelRoleMove(otherRoleMoveEvent)
    if otherRoleMoveEvent == nil then 
        return
    end
    -- self:openFog(otherRoleMoveEvent.fog)

    local playerInBeginGridKey = otherRoleMoveEvent["begin"]
    if playerInBeginGridKey== nil  or playerInBeginGridKey == nil then 
        return
    end
    -- 移动起始点处理
    local gridPlayersBegin = self._gridPlayers[playerInBeginGridKey]
    if gridPlayersBegin == nil or #gridPlayersBegin == 0 then 
        return
    end
    local heroMc = nil
    local heroIndex = 0
    for k,v in pairs(gridPlayersBegin) do
        if v.userId == otherRoleMoveEvent.userId then 
            heroIndex = k
            heroMc = v
            break
        end
    end
    if heroMc == nil then 
        return
    end
    table.remove(gridPlayersBegin, heroIndex)


    local beginGuildMapThing 
    if self._gridElements[playerInBeginGridKey] ~= nil then 
        beginGuildMapThing = tab.guildMapThing[tonumber(self._gridElements[playerInBeginGridKey].eleId)]
    end

    local beginGrid = self._shapes[playerInBeginGridKey].grid
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
     
    -- 防止3个人站在此处，当前玩家也站在此处出现重叠现象
    if self._curGrid.a ~= beginGrid.a or  self._curGrid.b ~= beginGrid.b then 
        -- 默认最大的显示，需求是同一点只有一人显示
        local lastHeroMc = gridPlayersBegin[#gridPlayersBegin]
        if lastHeroMc ~= nil and 
            tostring(lastHeroMc.guildId) == tostring(heroMc.guildId) and 
            (beginGuildMapThing == nil or beginGuildMapThing.func ~= GuildConst.ELEMENT_EVENT_TYPE.CITY) then 
            lastHeroMc.isLock = false
            lastHeroMc:setOpacity(255)
            lastHeroMc:setVisible(true)
            lastHeroMc:setLocalZOrder(100 + (beginGrid.a  + beginGrid.b))
        end
    else
        self._intanceMcAnimNode:setLocalZOrder(100 + (beginGrid.a  + beginGrid.b))
    end
    heroMc.isLock = false
    heroMc:setVisible(true)
    heroMc:setOpacity(255)
    -- heroMc:changeMotion(4, nil, false)
    heroMc:runByName("run")

    -- 移动结束点处理
    local playerWillGoGridKey = otherRoleMoveEvent["end"]
    if self._shapes[playerWillGoGridKey] == nil then
        otherRoleMoveEvent.currentGuildId =  self._guildMapModel:getData().currentGuildId
        ApiUtils.playcrab_lua_error("GuildMapListen Verify Will Go Grid", serialize(otherRoleMoveEvent))
        return
    end    


    local endGrid = self._shapes[playerWillGoGridKey].grid


    if tostring(heroMc.guildId) == tostring(guildId) then
        local tempGrids = self:getCircleGrids(endGrid.a, endGrid.b, 2)
        self:openFog(tempGrids)
    end

    local gridPlayersEnd = self._gridPlayers[playerWillGoGridKey]
    if gridPlayersEnd == nil then 
        gridPlayersEnd = {}
        self._gridPlayers[playerWillGoGridKey] = gridPlayersEnd
    end

    -- 是否是快速移动（多用于处理回程)
    local anim = true
    if otherRoleMoveEvent.isQuick ~= nil and otherRoleMoveEvent.isQuick == true  then 
        anim = false 
    end
    
    -- 迷雾下面需要隐藏
    if self._gridFogs[playerWillGoGridKey] ~= nil then 
        heroMc:setVisible(false)
        heroMc.isLock = true    
    end    
    heroMc:setLocalZOrder(100 + (endGrid.a  + endGrid.b))
    self:moveToGrid(heroMc, endGrid.a, endGrid.b, anim, false, function()
        self._userGridKeys[heroMc.userId] = endGrid.a .. "," .. endGrid.b
        heroMc:runByName("stop")
        -- 如果英雄在移动前被设置了隐藏说明不是同公会
        if heroMc:isVisible() == true then
            if #gridPlayersEnd > 0 then 
                gridPlayersEnd[#gridPlayersEnd]:setVisible(false)
                gridPlayersEnd[#gridPlayersEnd].isLock = true
            end
        end
        gridPlayersEnd[#gridPlayersEnd + 1] = heroMc
        self._viewMgr:unlock()
        if self._curGrid.a == endGrid.a and  self._curGrid.b == endGrid.b then 
            heroMc:setVisible(false)
            heroMc.isLock = true
            self._intanceMcAnimNode:setLocalZOrder(100 + (endGrid.a  + endGrid.b))
        end    

        local sysGuildMapThing 
        if self._gridElements[playerWillGoGridKey] ~= nil then 
            sysGuildMapThing = tab.guildMapThing[tonumber(self._gridElements[playerWillGoGridKey].eleId)]
        end
        if heroMc:isVisible() == true and 
            sysGuildMapThing ~= nil and 
            sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.CITY then

            heroMc:setVisible(false)
            heroMc.isLock = true              
        end
    end)

end



function GuildMapLayer:listenModelMissFogCur()
    local maissFogEvent = self._guildMapModel:getEvents()["MissFog_CUR"]
    self:handleListenModelMissFog(maissFogEvent)
    self._guildMapModel:getEvents()["MissFog_CUR"] = nil
end

function GuildMapLayer:listenModelMissFog()
    local maissFogEvent = self._guildMapModel:getEvents()["MissFog"]
    self:handleListenModelMissFog(maissFogEvent)
    self._guildMapModel:getEvents()["MissFog"] = nil
end

--[[
--! @function handleListenModelMissFog
--! @desc 处理MissFog返回结果 迷雾开启
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelMissFog(maissFogEvent)
    if maissFogEvent == nil then return end

    local operateGrid = self._shapes[maissFogEvent].grid
    if operateGrid == nil then return end

    local tempGrids = self:getCircleGrids(operateGrid.a, operateGrid.b, 4)
    self:openFog(tempGrids)
end


function GuildMapLayer:listenModelDelEleCur()
    local delEleEvent = self._guildMapModel:getEvents()["DelEle_CUR"]
    self:handleListenModelDelEle(delEleEvent)
    self._guildMapModel:getEvents()["DelEle_CUR"] = nil
end

function GuildMapLayer:listenModelDelEle()
    local delEleEvent = self._guildMapModel:getEvents()["DelEle"]
    self:handleListenModelDelEle(delEleEvent)
    self._guildMapModel:getEvents()["DelEle"] = nil
end

--[[
--! @function handleListenModelDelEle
--! @desc 处理DelEle 事件，目前用于删除建筑
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelDelEle(delEleEvent)
    if delEleEvent == nil then 
        return
    end
    self._viewMgr:lock(-1)
    local backMapList = self._guildMapModel:getData().mapList
    -- 删除建筑，后要处理重叠建筑显示
    for k,v in pairs(delEleEvent) do
        -- if self._gridElements[k] ~= nil  then 
        --     for k1,v1 in pairs(v) do
        --         -- if self._gridElements[k].typeName == k1 then 
        --         --     self._gridElements[k]:removeFromParent()
        --         --     self._gridElements[k] = nil
        --         --     break
        --         -- end
        --     end
        -- end
        if not (self._gridElements[k] ~= nil and self._gridElements[k].isNihility == true ) then 
            local grid = self._shapes[k]
            self:updateMapEle(k, grid, backMapList[k])
        end

    end
    self._viewMgr:unlock()
end


function GuildMapLayer:listenModelEleStateCur()
    local eleStateEvent = self._guildMapModel:getEvents()["EleState_CUR"]
    self:handleListenModelEleState(eleStateEvent)
    self._guildMapModel:getEvents()["EleState_CUR"] = nil
end

function GuildMapLayer:listenModelEleState()
    local eleStateEvent = self._guildMapModel:getEvents()["EleState"]
    self:handleListenModelEleState(eleStateEvent)
    self._guildMapModel:getEvents()["EleState"] = nil
end

--[[
--! @function listenModelEleState
--! @desc 更新建筑状态
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelEleState(eleStateEvent)
    if eleStateEvent == nil then
        return
    end
    local backMapList = self._guildMapModel:getData().mapList
    -- 添加建筑，后要处理重叠建筑显示 
    for k,v in pairs(eleStateEvent) do
        if self._gridElements[k] ~= nil and 
            self._gridElements[k].eleId ~= nil then 
            local sysGuildMapThing = tab.guildMapThing[tonumber(self._gridElements[k].eleId)]
            if sysGuildMapThing.func ~= GuildConst.ELEMENT_EVENT_TYPE.ELAPSED_REWARD then
                self:removeEleByGridKey(k)
            end
        end
        -- if backMapList[k] ~= nil then 
        local grid = self._shapes[k]
        self:updateMapEle(k, grid, backMapList[k])
        -- end
    end
end


--[[
--! @function listenModelAddEle
--! @desc 处理AdEle 事件，目前用于添加建筑
--! @param 
--! @return 
--]]
function GuildMapLayer:listenModelAddEle()
    local addEleEvent = self._guildMapModel:getEvents()["AddEle"]
    if addEleEvent == nil then 
        return
    end
    self._guildMapModel:getEvents()["AddEle"] = nil
    
    local backMapList = self._guildMapModel:getData().mapList
    -- 添加建筑，后要处理重叠建筑显示
    for k,v in pairs(addEleEvent) do
        self:removeEleByGridKey(k, true)
        if backMapList[k] ~= nil then 
            local grid = self._shapes[k]
            self:updateMapEle(k, grid, backMapList[k])
        end
    end
end



--[[
--! @function listenModelNewRoleJoin
--! @desc 新用户添加
--! @param 
--! @return 
--]]
function GuildMapLayer:listenModelNewRoleJoin()
    local roleJoinEvent = self._guildMapModel:getEvents()["NewRoleJoin"]
    if roleJoinEvent == nil then 
        return
    end
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local userList = self._guildMapModel:getData().userList


    if self._gridPlayers[roleJoinEvent.gid] == nil  then 
        self._gridPlayers[roleJoinEvent.gid] = {}
    end

    local gridPlayers = self._gridPlayers[roleJoinEvent.gid]
    -- 取消当前点人物显示 
    local lastHeroMc = gridPlayers[#gridPlayers]
    if lastHeroMc ~= nil then 
        lastHeroMc:setVisible(false)
        lastHeroMc.isLock = true
    end
    local userData = userList[roleJoinEvent.userId]

    local sysHero = tab.hero[userData.heroId]
    local gridData = self._shapes[roleJoinEvent.gid]

    local heroMc = self:createHeroMc(2, sysHero.heroart, userData.name, roleJoinEvent.userId, userData.guildId)
    heroMc:setPosition(gridData.pos.x, gridData.pos.y)

    self._bgSprite:addChild(heroMc, 100 + (gridData.grid.a + gridData.grid.b))



    if self._curGrid.a == gridData.grid.a and  self._curGrid.b == gridData.grid.b then 
        heroMc:setVisible(false)
        heroMc.isLock = true
        self._intanceMcAnimNode:setLocalZOrder(100 + (gridData.grid.a  + gridData.grid.b))
    else
        heroMc:setVisible(true)
        heroMc.isLock = false
        heroMc:setOpacity(255)        
    end

    gridPlayers[#gridPlayers + 1] = heroMc

    self._mcfps[#self._mcfps + 1]= heroMc

    self._userGridKeys[roleJoinEvent.userId] = roleJoinEvent.gid
    -- self:performanceHideMc(heroMc, false)

    self._guildMapModel:getEvents()["NewRoleJoin"] = nil
end


function GuildMapLayer:listenModelBackReviveCur()
    local backReviveEvent = self._guildMapModel:getEvents()["BackRevive_CUR"]
    self:handleListenModelBackRevive(backReviveEvent, true)
    self._guildMapModel:getEvents()["BackRevive_CUR"] = nil
end

function GuildMapLayer:listenModelBackRevive()
    local backReviveEvent = self._guildMapModel:getEvents()["BackRevive"]
    self:handleListenModelBackRevive(backReviveEvent)
    self._guildMapModel:getEvents()["BackRevive"] = nil
end


--[[
--! @function handleListenModelBackRevive
--! @desc 回城，只处理当前用户的BackRevive，其他用户的回程利用Event RoleMove处理
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelBackRevive(backReviveEvent, isMyself)
    if backReviveEvent == nil then 
        return
    end
    for k,v in pairs(backReviveEvent) do
        if v.userId == self._userId then
            self:handleListenModelBackCity(v, isMyself)
        else
            self:handleListenModelRoleMove(v)
        end
    end
end

function GuildMapLayer:listenModelBackCityCur()
    local backCityEvent = self._guildMapModel:getEvents()["BackCity_CUR"]
    self:handleListenModelBackCity(backCityEvent, true)
    self._guildMapModel:getEvents()["BackCity_CUR"] = nil
end

function GuildMapLayer:listenModelBackCity()
    local backCityEvent = self._guildMapModel:getEvents()["BackCity"]
    self:handleListenModelBackCity(backCityEvent, false)
    self._guildMapModel:getEvents()["BackCity"] = nil
end

--[[
--! @function handleListenModelBackCity
--! @desc 回城，只处理当前用户的backcity，其他用户的回程利用Event RoleMove处理
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelBackCity(backCityEvent, isMyself)
    if backCityEvent == nil then 
        return
    end
    if backCityEvent.userId == self._userId then
		if self:getYearTransTouchState() then
			self:setYearTransTouchState(false)
			self:removeEnableYearTrans()
			self._parentView:refreshWidgetVisible(1, true)
		end
		if self:getYearMissFogLockState() then
			self:setYearMissFogLockState(false)
		end
		ViewManager:getInstance():closeHintView()
        local gridData = self._shapes[backCityEvent["end"]]
        -- self._curGrid = gridData.grid
        self:lockTouch()
        local order = self._intanceMcAnimNode:getLocalZOrder()
        local backcity1 = mcMgr:createViewMC("huicheng1_guildmaphuicheng", false, true, function()

        end)
        backcity1:setPosition(self._intanceMcAnimNode:getPosition())
        self._bgSprite:addChild(backcity1, order - 1)
        local backcity2 = mcMgr:createViewMC("huicheng2_guildmaphuicheng", false, true, function()

            self:moveToGridByMyself(gridData.grid.a, gridData.grid.b, false, true, function()
                self._userGridKeys[self._userId] = self._curGrid.a .. "," .. self._curGrid.b
				self:reloadTreasureCompass()
                local backcity3 = mcMgr:createViewMC("huicheng3_guildmaphuicheng", false, true, function()

                end)
                backcity3:setPosition(gridData.pos.x, gridData.pos.y)
                self._bgSprite:addChild(backcity3, order - 1)
                local backcity4 = mcMgr:createViewMC("huicheng4_guildmaphuicheng", false, true, function()
                    self:unLockTouch()
                end)
                self._bgSprite:addChild(backcity4, order + 1)
                backcity4:setPosition(gridData.pos.x, gridData.pos.y)
            end)
        end)
        self._bgSprite:addChild(backcity2, order + 1)
        backcity2:setPosition(self._intanceMcAnimNode:getPosition())
        
        if isMyself ~= true then
            self._viewMgr:lock(-1)
            if string.find(ViewManager:getInstance():getCurViewName(), "Battle") == nil then 
                local popViews  = self._parentView:getPopViews()
                if popViews ~= nil and next(popViews) ~= nil then 
                    for k,v in pairs(popViews) do
                        if v ~= nil and v.close ~= nil and v:getClassName() ~= "global.NetWorkDialog" then
                            v:close(true)
                        end
                    end
                end
                if ViewManager:getInstance():getCurViewName() == "formation.NewFormationView" then
                    ViewManager:getInstance():popView()
                end                
            end

            self._viewMgr:unlock()
        end
    end
end



function GuildMapLayer:listenModelBattleTipCur()
    local battleTipEvent = self._guildMapModel:getEvents()["BattleTip_CUR"]
    self:handleListenModelBattleTip(battleTipEvent)
    self._guildMapModel:getEvents()["BattleTip_CUR"] = nil
end

--[[
--! @function handleListenModelBattleTip
--! @desc 监听战斗结果提示
--! @param battleTipEvent
--! @return 
--]]
function GuildMapLayer:listenModelBattleTip()
    local battleTipEvent = self._guildMapModel:getEvents()["BattleTip"]
    self:handleListenModelBattleTip(battleTipEvent)
    self._guildMapModel:getEvents()["BattleTip"] = nil
end

--[[
--! @function handleListenModelBattleTip
--! @desc 处理战斗结果提示
--! @param battleTipEvent
--! @return 
--]]
function GuildMapLayer:handleListenModelBattleTip(battleTipEvent)
    if battleTipEvent == nil then 
        return
    end
    table.insert(self._battleTips, 1, battleTipEvent)
    ScheduleMgr:delayCall(0, self, function()
        self:activeBattleTip()
    end)
end

--[[
--! @function listenModelRoleQuit
--! @desc 退出公会
--! @param 
--! @return 
--]]
function GuildMapLayer:listenModelRoleQuit()
    print("listenModelRoleQuit===================")
    local roleQuitEvent = self._guildMapModel:getEvents()["RoleQuit"]
    if roleQuitEvent == nil then 
        return
    end
    print("1listenModelRoleQuit===================")
    -- 当前玩家被踢出公会则执行
    if roleQuitEvent.userId == self._userId then
        self:listenModelLogoutMap("您已经被踢出公会！")
        return
    end
    print("2listenModelRoleQuit===================")
    -- local gridData = self._shapes[roleQuitEvent.gid]
    self:removeUserByGridKeyAndUserId(roleQuitEvent.gid, roleQuitEvent.userId)
    local gridPlayers = self._gridPlayers[roleQuitEvent.gid]
    -- 移除要删除觉得heromc后显示最后进入场景的玩家
    if gridPlayers ~= nil and #gridPlayers > 0 then 
        print("3listenModelRoleQuit===================")
       local lastHeroMc = gridPlayers[#gridPlayers]
       lastHeroMc.isLock = false
       lastHeroMc:setVisible(true)
       lastHeroMc:setOpacity(255)
    end

    -- self:updateMapPlayer(roleQuitEvent.gridKey, gridData, backMapList[roleQuitEvent.gridKey].player, userList)
    self._guildMapModel:getEvents()["RoleQuit"] = nil
end


--[[
--! @function listenModelMatching
--! @desc 数据不匹配，开始更新数据
--! @param 
--! @return 
--]]
function GuildMapLayer:listenModelMatching()
    self._viewMgr:lock(1)
end


function GuildMapLayer:listenModelMatchingFinish()
    self._viewMgr:unlock()
    self._parentView:refreshUIUnify()
end

function GuildMapLayer:listenModelRoleProgressCur()
    local roleProgressEvent = self._guildMapModel:getEvents()["RoleProgress_CUR"]
    self:handleListenModelRoleProgress(roleProgressEvent)
    self._guildMapModel:getEvents()["RoleProgress_CUR"] = nil
end

function GuildMapLayer:listenModelRoleProgress()
    local roleProgressEvent = self._guildMapModel:getEvents()["RoleProgress"]
    self:handleListenModelRoleProgress(roleProgressEvent)
    self._guildMapModel:getEvents()["RoleProgress"] = nil
end

--[[
--! @function handleListenModelRoleProgress
--! @desc 地图玩家展示进度条
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelRoleProgress(roleProgressEvent)
    if roleProgressEvent == nil then 
        return
    end
    local userId, userInfo = next(roleProgressEvent)
    if self._userMcs[userId] == nil or self._userGridKeys[userId] == nil then 
        return
    end
    self:handlePlayerTimngQueue(userId, self._userGridKeys[userId], userInfo)
end 


function GuildMapLayer:listenModelCancelRoleProgressCur()
    local cancelRoleProgressEvent = self._guildMapModel:getEvents()["CancelRoleProgress_CUR"]
    self:handleListenModelCancelRoleProgress(cancelRoleProgressEvent)
    self._guildMapModel:getEvents()["CancelRoleProgress_CUR"] = nil
end

function GuildMapLayer:listenModelCancelRoleProgress()
    local cancelRoleProgressEvent = self._guildMapModel:getEvents()["CancelRoleProgress"]
    self:handleListenModelCancelRoleProgress(cancelRoleProgressEvent)
    self._guildMapModel:getEvents()["CancelRoleProgress"] = nil
end

--[[
--! @function listenModelCancelRoleProgress
--! @desc 取消地图玩家展示进度条
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelCancelRoleProgress(cancelRoleProgressEvent)
    if cancelRoleProgressEvent == nil then 
        return
    end
    for k,v in pairs(cancelRoleProgressEvent) do
        if self._userMcs[k] ~= nil and self._userGridKeys[k] ~= nil 
            and (v.curOp == nil or next(v.curOp) == nil) then 
            self:handlePlayerTimngQueue(k, self._userGridKeys[k], nil)
        end
    end

    -- local userId, userInfo = next(cancelRoleProgressEvent)
    -- if self._userMcs[userId] == nil or self._userGridKeys[userId] == nil then 
    --     return
    -- end
    -- -- 以下数据不为nil的说明并没有取消，们不用执行下列程序
    -- if userInfo ~= nil and userInfo.curOp ~= nil and next(userInfo.curOp) ~= nil then 
    --     return
    -- end
    -- self:handlePlayerTimngQueue(userId, self._userGridKeys[userId], nil)
end 



function GuildMapLayer:listenModelReleaceGuild()
    self:listenModelLogoutMap(lang("GUILDMAPTIPS_13"))
end

--[[
--! @function listenModelLogoutMap
--! @desc 后端强制玩家退出地图
--! @param 
--! @return 
--]]
function GuildMapLayer:listenModelLogoutMap(inDesc)
    if inDesc == nil then 
        inDesc = "联盟地图重置中，请稍后再来！"
    end
    -- self._viewMgr:lock(-1)
    -- self._viewMgr:unlock()
    self._viewMgr:showTip(inDesc)
    self._viewMgr:lock()
    ScheduleMgr:delayCall(500, self, function()
        self._viewMgr:unlock()
        self._viewMgr:returnMain("guild.GuildView")
    end)

    -- self._viewMgr:showTip(inDesc)
    -- self._parentView:runAction(cc.Sequence(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
    --         print("test----------------------------------------------")
    --         self._viewMgr:unlock()
    --         self._parentView:close()
    --         -- self:close()
    --     end)))
end

function GuildMapLayer:listenModelLogoutToMap()
	local data = self._guildMapModel:getEvents()["LogoutToMap"]
	local desc
	if data.errorCode == 3044 then
		desc = (data.famType and data.famType==1 and lang("GUILD_FAM_TIPS_16")) or lang("GUILD_FAM_TIPS_17")
	elseif data.errorCode == 3041 then
		desc = lang("GUILD_FAM_TIPS_15")
	end
    self._viewMgr:showTip(desc)
	self._guildMapModel:getEvents()["LogoutToMap"] = nil
    self._viewMgr:lock()
    ScheduleMgr:delayCall(500, self, function()
        self._viewMgr:unlock()
        self._viewMgr:returnMain("guild.map.GuildMapView")
    end)
end


function GuildMapLayer:listenModelSwitchGuildCur()
    local otherSwitchGuildEvent = self._guildMapModel:getEvents()["SwitchGuild_CUR"]
    self._guildMapModel:getEvents()["SwitchGuild_CUR"] = nil
    self:handleListenModelSwitchGuild(otherSwitchGuildEvent)
end

function GuildMapLayer:listenModelSwitchGuild()
    local otherSwitchGuildEvent = self._guildMapModel:getEvents()["SwitchGuild"]
    self._guildMapModel:getEvents()["SwitchGuild"] = nil
    self:handleListenModelSwitchGuild(otherSwitchGuildEvent)
end
--[[
--! @function listenModelSwitchGuild
--! @desc 传送到其他公会
--! @param 
--! @return 
--]]
function GuildMapLayer:handleListenModelSwitchGuild()
    self._parentView:refreshUIUnify()
end


--[[
--! @function listenModelPushSwitchGuild
--! @desc 传送到其他公会
--! @param 
--! @return 
--]]
function GuildMapLayer:listenModelPushSwitchGuild()
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    guildMapModel:clear()    
    self._parentView:getMapInfo()
end


--[[
--! @function listenModelUpNearCur
--! @desc 当前玩家主动刷新
--! @param 
--! @return 
--]]
function GuildMapLayer:listenModelUpNearCur()
    local upNearEvent = self._guildMapModel:getEvents()["UpNear_CUR"]
    self:handleListenModelUpNear(upNearEvent)
    self._guildMapModel:getEvents()["UpNear_CUR"] = nil
end

--[[
--! @function listenModelUpNear
--! @desc 多数情况下是服务器主动刷新
--! @param 
--! @return 
--]]
function GuildMapLayer:listenModelUpNear()
    local upNearEvent = self._guildMapModel:getEvents()["UpNear"]
    self:handleListenModelUpNear(upNearEvent)
    self._guildMapModel:getEvents()["UpNear"] = nil
end

--[[
--! @function handleListenModelUpNear
--! @desc 数据不同步的时候，强制刷新附近点
--! @param upNearEvent 附近点信息
--! @return 
--]]
function GuildMapLayer:handleListenModelUpNear(upNearEvent)
    local tempBuildShapes = {}
    local backMapList = self._guildMapModel:getData().mapList
    local userList = self._guildMapModel:getData().userList  

    for k,v in pairs(upNearEvent) do
        if self._shapes[k] ~= nil then 
            tempBuildShapes[k] = self._shapes[k]
        end
    end

    for k,v in pairs(tempBuildShapes) do
        if backMapList[k] ~= nil then
            local sysGuildMapThing = self:updateMapEle(k, v, backMapList[k])
            if sysGuildMapThing == nil or sysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.CITY then
                self:initMapPlayer(k, v, backMapList[k].player, userList)
            end
        end
    end
end



