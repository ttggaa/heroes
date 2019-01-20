--[[
    Filename:    GuildMapEvent.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-07-03 14:37:53
    Description: File description
--]]


local GuildMapLayer = require("game.view.guild.map.GuildMapLayer")

function GuildMapLayer:showEvent30(inParam)
	self._viewMgr:lock(-1)
	local anim = mcMgr:createViewMC("wabaodonghua_lianmengxunbao", false, true, function (  )
		local eleData = self._guildMapModel:getShowElementDataByGridKey(inParam.targetId)
		inParam.treasureType = eleData.tType
		if inParam.treasureType==2 then
			inParam.treasureData = eleData
		end
		inParam.treasureEventKey = eleData.tmKey
		self._viewMgr:showDialog("guild.map.GuildMapTreasureEventDialog", inParam, true)
		self._viewMgr:unlock()
	end)
	anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
	self._bgSprite:addChild(anim)
end

function GuildMapLayer:showEvent29(inParam)
	inParam.callback = function(result)
		self:listenModelDelEleCur()
		DialogUtils.showGiftGet( {
			gifts = result["reward"], 
			callback = function()
				if self.showEvent1 == nil then
					return
				end
				self._viewMgr:lock(-1)
				local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
					anim:addCallbackAtFrame(8, function() 
							self._viewMgr:unlock()
						end)
				anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
				self._bgSprite:addChild(anim, 1000)
			end
		})
	end
	self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end

function GuildMapLayer:showEvent28(inParam)
	UIUtils:reloadLuaFile("guild.map.GuildMapOfficerFuncDialog")
	local storyId = tab.guildMapThing[inParam.eleId]["story"]
        ViewManager:getInstance():enableTalking(storyId, {}, function()
			self._viewMgr:showDialog("guild.map.GuildMapOfficerFuncDialog", inParam)
		end)
end

function GuildMapLayer:showEvent27(inParam)
	local playerLevel = self._modelMgr:getModel("UserModel"):getPlayerLevel()
	local needLevel = tab:Setting("OFFICER_OPEN_LV").value
	if playerLevel<needLevel then
		self._viewMgr:showTip(lang("GUILD_MILITARY_TIP_5"))
		return
	end
	local eleData = self._guildMapModel:getShowElementDataByGridKey(inParam.targetId)
	local officerGid = self._guildMapModel:getOfficerTargetGuildId()
	if eleData.actime and officerGid~=0 then--指挥官已激活，并且有物资官存在
		self._viewMgr:showTip(lang("GUILD_MILITARY_TIP_2"))
		return
	end
	local commanderData = self._guildMapModel:getCommanderData()
	if commanderData and commanderData.actime and commanderData.rtime then
		local maxRewardTime = tab:Setting("OFFICER_REWARD_TOTAL").value*60
		if tonumber(eleData.actime)<commanderData.actime then
			if commanderData.rtime-commanderData.actime<maxRewardTime then
				--已经激活物资官、没领完奖
				inParam.commanderData = commanderData
				inParam.rewardState = true
				if tonumber(commanderData.type)==3 then
					inParam.callback = function()
						self:lockTouch()
						self._viewMgr:lock(-1)
						local mc1 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true, false) 
						mc1:setName("mc1")
						mc1:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
						self._parentView:addChild(mc1, 500)

						local mc2 = mcMgr:createViewMC("lashentiao_lianmengjihuo", false, false)  
						mc2:setAnchorPoint(cc.p(0.5, 0))
						mc2:setScaleX(0)
						mc1:addChild(mc2, -1)

						local equipBtn = self._parentView:getUI("Panel_29.extendBar.bg.map_equip_btn")
						local equipX, equipY = equipBtn:getPosition()

						local mcPos = self._parentView:convertToWorldSpace(cc.p(equipX, equipY))
						mcPos.x = mcPos.x - equipBtn:getContentSize().width

						local disicon = MathUtils.pointDistance(mcPos, cc.p(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2))
						local speed = disicon/1000
						local scay = 1
						if disicon < 150 then
							scay = 0.5
						elseif disicon > 400 then
							scay = 2
						end
						local angle = 180 - MathUtils.angleAtan2(mcPos, cc.p(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)) + 90
						mc1:setRotation(angle)

						local move1 = cc.Sequence:create(   
							cc.DelayTime:create(0.2), 
							cc.MoveTo:create(speed + 0.1, mcPos), 
							cc.CallFunc:create(function()
								mc1:removeFromParent()
								local mc3 = mcMgr:createViewMC("fankui_lianmengjihuo", false, true, nil, RGBA8888)  
								mc3:setPosition(mcPos)
								self._parentView:addChild(mc3,100)
								self._viewMgr:unlock()
								self:unLockTouch()
							end)
						)
						mc1:runAction(move1)

						local spSeq = cc.Sequence:create(
								cc.ScaleTo:create(0.2, 0, 1), 
								cc.ScaleTo:create(speed+0.1, scay, 1), 
								cc.ScaleTo:create(0, 0, 1), cc.FadeOut:create(0.1))
						mc2:runAction(spSeq)
					end
				end
				inParam.getAllRewardCallback = function()
					local isCrossDay = TimeUtils.checkIsOtherDay(tonumber(eleData.actime), self._modelMgr:getModel("UserModel"):getCurServerTime())
					if isCrossDay then
						local elementSp = self._gridElements[inParam.targetId]
						if elementSp then
							if elementSp._fuhao then
								elementSp._fuhao:removeFromParent(true)
								elementSp._fuhao = nil
							end
							local tipAnim = mcMgr:createViewMC("tanhao_lianmengdonghua", true)
							tipAnim:setPosition(elementSp:getContentSize().width * 0.5, elementSp:getContentSize().height + 30)
							elementSp._fuhao = tipAnim
							elementSp:addChild(tipAnim, 20)
						end
					end
				end
				self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
				return
			elseif not TimeUtils.checkIsOtherDay(tonumber(eleData.actime), self._modelMgr:getModel("UserModel"):getCurServerTime()) then
				self._viewMgr:showTip(lang("GUILD_MILITARY_TIP_7"))--当天已经领过奖，不可再次激活。
				return
			end
		end
	end
	inParam.callback = function()
		local mc = mcMgr:createViewMC("jieshouweituo_jieshouweituo", false, true)
		mc:setPosition(cc.p(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT-100))
		self._parentView:addChild(mc)
		local elementSp = self._gridElements[inParam.targetId]
		if elementSp._fuhao then--激活后清除头顶叹号
			elementSp._fuhao:removeFromParent(true)
			elementSp._fuhao = nil
		end
	end
	self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end

--[[
--! @function showEvent26
--! @desc 联盟新年使者
--! @param inParam 目标信息
--! @return 
--]]
function GuildMapLayer:showEvent26(inParam)
	--[[self._serverMgr:sendMsg("GuildMapServer", "acYearAmb",{tagPoint = inParam.targetId}, true, {}, function(result)
		inParam.yearData = result
		if result.yearType==GuildConst.YEAR_TYPE.MISS_FOG then
			inParam.callback = function()
				local fogGrid = string.split(result.fogBid, ",")
				local a,b = tonumber(fogGrid[1]), tonumber(fogGrid[2])
				self._viewMgr:lock(-1)
				self:screenToGrid(a, b, true, function()
					local tempGrids = self:getCircleGrids(a, b, 1)
					tempGrids[fogGrid] = {a = a, b = b, dis = 1}
					self:openFog(tempGrids)
					ScheduleMgr:delayCall(1500, self, function ()
						self:screenToGrid(self._curGrid.a, self._curGrid.b, true, function()
							self._viewMgr:unlock()
						end)
					end)
				end)
			end
		elseif result.yearType==GuildConst.YEAR_TYPE.SKIP_MAP then
			inParam.callback = function()
				self:setYearTransTouchState(true)
				self._parentView:refreshWidgetVisible(0)
				self:initEnableYearTrans()
			end
		end
	end)--]]
	inParam.resultCallback = function(result)
		if result.yearType==GuildConst.YEAR_TYPE.MISS_FOG then
			local fogGrid = string.split(result.fogBid, ",")
			local a,b = tonumber(fogGrid[1]), tonumber(fogGrid[2])
			self:setYearMissFogLockState(true)
--			self._viewMgr:lock(-1)
			self:screenToGrid(a, b, true, function()
				local tempGrids = self:getCircleGrids(a, b, 1)
				tempGrids[fogGrid] = {a = a, b = b, dis = 1}
				self:openFog(tempGrids)
				ScheduleMgr:delayCall(1500, self, function ()
					self:screenToGrid(self._curGrid.a, self._curGrid.b, true, function()
						self:setYearMissFogLockState(false)
--						self._viewMgr:unlock()
					end)
				end)
			end)
		elseif result.yearType==GuildConst.YEAR_TYPE.SKIP_MAP then
			self:setYearTransTouchState(true)
			self._parentView:refreshWidgetVisible(0, true)
			self:initEnableYearTrans()
		end
	end
	self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
--	self._viewMgr:showDialog("guild.map.GuildMapEventView", {eventType = 26, eleId = 6002}, true)
end

function GuildMapLayer:showEvent25(inParam)
	self._serverMgr:sendMsg("GuildMapServer", "getSecretLandInfo", {tagPoint = inParam.targetId}, true, {targetId = inParam.targetId}, function(result, errorCode)
		if errorCode and errorCode~=0 then
			if errorCode == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SECRETLAND_NOT_EXIST then
				self._viewMgr:showTip(lang("GUILD_FAM_TIPS_15"))
                self:removeEleByGridKeyAndType(inParam.targetId, "guild")
			end
			return
		end
		local famData = {}
		for i,v in pairs(result) do
			famData[tonumber(i)] = v
		end
        self._modelMgr:getModel("GuildMapFamModel"):addData(inParam.targetId, result)
		self._viewMgr:showView("guild.map.GuildMapFamView", {param = inParam, famData = famData})
	end)
end

--[[
--! @function showEvent24
--! @desc 斯芬克斯答题
--! @param inParam 目标信息
--! @return 
--]]
function GuildMapLayer:showEvent24(inParam)
    local curShowTime = self._guildMapModel:getAQAcTime()
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    if curShowTime == nil or #curShowTime < 3 or curTime >= curShowTime[2] or curTime < curShowTime[1] then
        self._viewMgr:showTip("活动已结束")
        return
    end

    local sysGuildMapThing = tab.guildMapThing[tonumber(inParam.eleId)]
    if inParam.isRemote == true and sysGuildMapThing.tip ~= nil then
        self._viewMgr:showTip("回答它的问题可以获得认可与奖励")
        return 
    end
    
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end

        self._viewMgr:lock(-1)
        local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
            anim:addCallbackAtFrame(8, function() 
                    self:listenModelDelEleCur()
                    self._viewMgr:unlock()
                    self:unLockTouch()
                end)
        anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
        self._bgSprite:addChild(anim, 1000)
    end

    self._serverMgr:sendMsg("GuildMapServer", "sphinxBefore", {tagGid = inParam.targetId}, true, {}, function(result)
        local mapList = self._guildMapModel:getData().mapList
        if mapList[inParam.targetId] and mapList[inParam.targetId]["my"] then
            inParam["gridInfo"] = mapList[inParam.targetId]["my"]
            self._viewMgr:showDialog("guild.map.GuildMapAQView", inParam, true)
        end
    end)
end


--[[
--! @function showEvent23
--! @desc 先知小屋领取宝箱
--! @param inTargetId 目标id
--! @return 
--]]
function GuildMapLayer:showEvent23(inParam)
    self._serverMgr:sendMsg("GuildMapServer", "getRoleReward23", {tagPoint = inParam.targetId}, true, {}, function (result)
        DialogUtils.showGiftGet( {
            gifts = result["reward"], 
            callback = function()
                -- 防止地图刷新，无法继续执行下面动作
                self._viewMgr:lock(-1)
                local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
                anim:addCallbackAtFrame(8, function() 
                    self:listenModelDelEleCur()
                    self._viewMgr:unlock()
                    end)
                anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
                self._bgSprite:addChild(anim, 1000)
                self:getParent():reflashPushMapTask()
            end
        })
        end)
end

function GuildMapLayer:showEvent22(inParam)
    self:showEvent21(inParam)
end

--[[
--! @function showEvent21
--! @desc 直接领取奖励
--! @param inTargetId 目标id
--! @return 
--]]
function GuildMapLayer:showEvent21(inParam)
    print("showEvent1=============================",socket.gettime())
    self:lockTouch()
    inParam.closePopCallback = function()
        if self.unLockTouch ~= nil then
            self:unLockTouch()
        end
    end
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        -- 锁定建筑，防止连续点击
        if self._gridElements[inParam.targetId] ~= nil then 
            self._gridElements[inParam.targetId].lock = true
        end
        DialogUtils.showGiftGet( {
            gifts = result["reward"], 
            callback = function()
                -- 防止地图刷新，无法继续执行下面动作
                if self.showEvent1 == nil then
                    return
                end
                self._viewMgr:lock(-1)
                local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
                    anim:addCallbackAtFrame(8, function() 
                            self:listenModelDelEleCur()
                            self._viewMgr:unlock()
                            self:unLockTouch()
                        end)
                anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
                self._bgSprite:addChild(anim, 1000)
                self:getParent():reflashPushMapTask()
            end
        })
    end     
    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end


--[[
--! @function showEvent2
--! @desc 兑换奖励
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent20(inParam)
    -- if self._lockGrid[inParam.targetId] ~= nil then 
    --     return
    -- end
    -- self._lockGrid[inParam.targetId] = 1
    self:lockTouch()
    inParam.closePopCallback = function()
        if self.unLockTouch ~= nil then
            self:unLockTouch()
        end
    end   
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end    
        if result == nil then 
            self:unLockTouch()
            -- self:unLockTouch()
            return
        end
        local mcCallback = function()
            self:unLockTouch()
            -- 防止地图刷新，无法继续执行下面动作
            if self.showEvent1 == nil then
                return
            end
            print("mcCallback=============================",os.time())
            self._viewMgr:lock(-1)
            local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
                anim:addCallbackAtFrame(8, function() 
                    self:listenModelDelEleCur()
                    self._viewMgr:unlock()
                    -- self:unLockTouch()
                    end)
            anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
            self._bgSprite:addChild(anim, 1000)
        end
        if result["reward"] ~= nil then
            DialogUtils.showGiftGet( {
                gifts = result["reward"], 
                callback = mcCallback
            })  
        else
            mcCallback()     
        end
    end       
    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end

--[[
--! @function showEvent19
--! @desc 触发任务[先知学者]
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent19(inParam)
    local taskType1 = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_XUEZHE
    local taskType2 = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_BOX
    local taskState1 = self._guildMapModel:getTaskStateByStatis(taskType1)
    local taskState2 = self._guildMapModel:getTaskStateByStatis(taskType2)
    -- 远程访问提示
    if inParam.isRemote == true then   --小精灵
        local tip =  ""
        if taskState2 == 2 or taskState2 == 1 then
            tip = "backmantips_3"
        elseif taskState1 == 1 then
            tip = "backmantips_1"
        elseif taskState1 == 0 then
            tip = "backmantips_2"
        end
        self._viewMgr:showTip(lang(tip))
        return 
    end  

    -- 第一次点击
    if taskState1 == 1 then
        local storyId = tab.guildMapThing[inParam["eleId"]]["story"]
        ViewManager:getInstance():enableTalking(storyId, {}, function()
            --交任务领取奖励
            self._serverMgr:sendMsg("GuildMapServer", "acMTask2", {tagPoint = inParam.targetId}, true, {}, function (result)
                DialogUtils.showGiftGet( {
                    gifts = result["reward"], 
                    title2 = lang("GUILDMAPTASKDES_TIPS_1"),
                    callback = function()
                        self:getParent():reflashPushMapTask()

                        --渐隐
                        local build = self._gridElements[inParam.targetId]
                        if build._fuhao then
                            build._fuhao:runAction(cc.Sequence:create(
                                cc.FadeOut:create(0.5),
                                cc.CallFunc:create(function()
                                    build._fuhao:setVisible(false)
                                    local tempParam = {}
                                    tempParam[inParam.targetId] = 1
                                    self:handleListenModelEleState(tempParam)
                                    self:listenModelEleStateCur()
                                    end)
                                ))
                        end

                        --移动屏幕到宝箱位置
                        local buildData = self._guildMapModel:getData().spTaskData
                        if buildData["sp3"] and buildData["sp3"]["pos"] then
                            local npcGridKeys = string.split(buildData["sp3"]["pos"], ",")
                            self:screenToGridAndDelayBack(npcGridKeys[1], npcGridKeys[2])
                        end
                    end})
                end)
            end)
        return
    end

    if taskState2 == 2 or taskState2 == 1 then
        self._viewMgr:showTip(lang("backmantips_3"))
    elseif taskState1 == 0 then
        self._viewMgr:showTip(lang( "backmantips_2"))
    else
        ApiUtils.playcrab_lua_error("GuildMapLayer showEvent18=====", taskState2, "taskState1", taskState1)
    end
end

--[[
--! @function showEvent18
--! @desc 触发任务[先知小屋]
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent18(inParam)
    --已领取任务  
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    local taskType = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_XUEZHE
    local taskState = guildMapModel:getTaskStateByStatis(taskType)

    if taskState == 2 then
        self._viewMgr:showTip("本周没有可用情报了")
        return
    end

    if taskState == 1 then
        local goGuildName = self._guildMapModel:getPassGuildName()
        local curTip = string.gsub(lang("GUILDMAPDES_3101_tip"), "${name}", goGuildName)
        self._viewMgr:showTip(curTip)
        return
    end

    -- 远程访问提示
    local sysGuildMapThing = tab.guildMapThing[tonumber(inParam.eleId)]
    if inParam.isRemote == true and sysGuildMapThing.tip ~= nil then
        self._viewMgr:showTip(lang(sysGuildMapThing.tip))
        return 
    end
    
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end

        self:getParent():reflashPushMapTask()

        local build = self._gridElements[inParam.targetId]
        if build._fuhao and guildMapModel:getTaskStateByStatis(taskType) == 1 then
            build._fuhao:runAction(cc.Sequence:create(
                cc.FadeOut:create(0.5),
                cc.CallFunc:create(function()
                    build._fuhao:setVisible(false)
                    local tempParam = {}
                    tempParam[inParam.targetId] = 1
                    self:handleListenModelEleState(tempParam)
                    end)
                ))
        end
    end

    self._viewMgr:showDialog("guild.map.GuildMapSecondEventView", inParam, true)
end


--[[
--! @function showEvent17
--! @desc 城池
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent17(inParam)
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        self:listenModelSkipPosCur()
    end
    self._viewMgr:showDialog("guild.map.GuildMapSecondEventView", inParam, true)
end



--[[
--! @function showEvent14
--! @desc 城池
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent14(inParam)
    inParam.callback = function(inType, result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        -- 驻守
        if inType == 1 then 
            self:listenModelEleStateCur()
            self:listenModelRoleMoveCur()
        end
        -- self:listenModelSkipPosCur()
    end
    self._viewMgr:showDialog("guild.map.GuildMapSecondEventView", inParam, true)
end

--[[
--! @function showEvent16
--! @desc 地下城入口
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent16(inParam)
    inParam.callback = function(result)
        self:switchGuildAction()
    end
    self._viewMgr:showDialog("guild.map.GuildMapSecondEventView", inParam, true)
end


--[[
--! @function showEvent10
--! @desc 传送门
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent10(inParam)
    inParam.callback = function(result)
        self:switchGuildAction()
    end
    self._viewMgr:showDialog("guild.map.GuildMapSecondEventView", inParam, true)
end

--[[
--! @function switchGuildAction   by wangyan
--! @desc 传送门/地下城入口 传送动画
--! @param 
--! @return 
--]]
function GuildMapLayer:switchGuildAction()
    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(0, self, function()
        self._guildMapModel:setTransferState(true)
        
        local order = self._intanceMcAnimNode:getLocalZOrder()
        local backcity1 = mcMgr:createViewMC("huicheng1_guildmaphuicheng", false, true, function() end)
        backcity1:setPosition(self._intanceMcAnimNode:getPosition())
        self._bgSprite:addChild(backcity1, order - 1)

        local backcity2 = mcMgr:createViewMC("huicheng2_guildmaphuicheng", false, true, function()
            self._viewMgr:unlock()
            -- 防止地图刷新，无法继续执行下面动作
            if self.showEvent1 == nil then
                return
            end
            self:listenModelSwitchGuildCur()
        end)
        self._bgSprite:addChild(backcity2, order + 1)
        backcity2:setPosition(self._intanceMcAnimNode:getPosition())
    end)
end

--[[
--! @function showEvent13
--! @desc 方尖塔
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent13(inParam)
    inParam.callback = function(inType, result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then 
            return
        end    
        self:getParent():reflashPushMapTask()
        self:listenModelEleStateCur()
    end
    self._viewMgr:showDialog("guild.map.GuildMapSecondEventView", inParam, true)
end

--[[
--! @function showEvent12
--! @desc 首领帐篷
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent12(inParam)
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil or result == nil then
            return
        end
        -- 锁定建筑，防止连续点击
        if self._gridElements[inParam.targetId] ~= nil then 
            self._gridElements[inParam.targetId].lock = true
        end
        local sysGuildMapThing = tab.guildMapThing[tonumber(inParam.eleId)]
        if sysGuildMapThing.open ~= nil then
            self._viewMgr:lock(-1)
            print("sysGuildMapThing.open===========", sysGuildMapThing.open)
            local gridKeyData = string.split(sysGuildMapThing.open, ",")
            -- 移动位置到哨塔
            self:screenToGrid(gridKeyData[1], gridKeyData[2], true, function()
                local tempPos = self._shapes[sysGuildMapThing.open].pos
                local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true, 
                function ()
                    if self._gridElements[inParam.targetId] ~= nil then 
                        self._gridElements[inParam.targetId].lock = false
                    end
                    -- 移动位置回帐篷位置
                    local targetGrid = self._shapes[inParam.targetId].grid
                    self:screenToGrid(targetGrid.a, targetGrid.b, true, function()

                        self._viewMgr:unlock()
                        -- 展示奖励
                        if result["reward"] ~= nil and next(result["reward"]) ~= nil then 
                            DialogUtils.showGiftGet( {
                                gifts = result["reward"], 
                                callback = function()
                                    self:getParent():reflashPushMapTask()
                                end
                            })
                        else
                            self:getParent():reflashPushMapTask()
                        end              
                    end, false, nil, 1)
                end)
                anim:addCallbackAtFrame(8, function() 
                            self:listenModelDelEleCur()
                            self:listenModelEleStateCur()
                        end)
                anim:setPosition(tempPos.x, tempPos.y)
                self._bgSprite:addChild(anim, 1000)
            end, false, nil, 1)
        end
    end         

    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end


--[[
--! @function showEvent11
--! @desc 边境大门
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent11(inParam)
    inParam.callback = function(inType, result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        self:listenModelEleStateCur()
    end
    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end


--[[
--! @function showEvent8
--! @desc pve战斗
--! @param inTargetId 目标id
--! @return 
--]]
function GuildMapLayer:showEvent8(inParam)
    local sysGuildMapThing = tab.guildMapThing[tonumber(inParam.eleId)]
    inParam.callback = function(result)
        if self._parentView ~= nil and self._parentView:checkMapUpdate() == true then return true end
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        if result == nil then return end

        -- 战斗前请求
        if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_PVE_NOT_EXIST then 
            self:listenModelDelEleCur()
            self:listenModelEleStateCur()
            self:listenModelBackCityCur()
            self._viewMgr:showTip(lang("GUILDMAPTIPS_4"))
            return
        end
        if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SWITCH_MAP then
            self._guildMapModel:clear()
            self._parentView:getMapInfo()
            return
        end
        if self._guildMapModel:getEvents()["DelEle_CUR"] ~= nil then 
            self._viewMgr:lock(-1)
            local element = self._gridElements[inParam.targetId]
            if element ~= nil and 
            element.animSp ~= nil  then 
                element.animSp:changeMotion(4, nil, 
                    function()
                        element.animSp:stop()
                        self:listenModelDelEleCur()
                        self:listenModelBackCityCur()
                        self:getParent():reflashPushMapTask() 
                        self._viewMgr:unlock()
                    end)
                element.animSp:play()
            else
                local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true, function()
                    self:listenModelBackCityCur()
                    self._viewMgr:unlock()
                end)
                anim:addCallbackAtFrame(8, function() 
                        self:getParent():reflashPushMapTask()
                        self:listenModelDelEleCur()
                    end)
                anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
                self._bgSprite:addChild(anim, 1000)
            end
            if result.leftDie ~= nil and #result.leftDie > 0 then 
                local str = lang("GUILDMAPTIPS_11")  
                local teamId = result.leftDie[1]
                local sysTeam = tab:Team(teamId)
                if sysTeam == nil then 
                    if sysGuildMapThing.qiangdu == 1 then
                        self._viewMgr:showTip(lang("GUILD_BOSS_DIE"))
                    else
                        self._viewMgr:showTip(lang("GUILD_MONSTER_DIE"))
                    end
                else
                    local uresult,count1 = string.gsub(str, "{$teamname}", lang(sysTeam.name))
                    if count1 > 0 then 
                        str = uresult
                    end
                    self._viewMgr:showTip(str)
                end
            else
                if sysGuildMapThing.qiangdu == 1 then
                    self._viewMgr:showTip(lang("GUILD_BOSS_DIE"))
                else
                    self._viewMgr:showTip(lang("GUILD_MONSTER_DIE"))
                end
            end
            -- local backcity = mcMgr:createViewMC("huicheng1_guildmaphuicheng", false, true, function()
        else
            if result.win ~= 1 then 

                self._viewMgr:showTip(lang("GUILDMAPTIPS_3"))
            end
            self:listenModelBackCityCur()
        end
    end
    if sysGuildMapThing.qiangdu == 1 then
        self:getPointInfo(inParam.targetId, function()
            self._viewMgr:showDialog("guild.map.GuildMapBossView", inParam, true)
        end)
    else
        self._viewMgr:showDialog("guild.map.GuildMapPveView", inParam, true)
    end
end

--[[
--! @function showEvent7
--! @desc 金矿、招募点（联盟）
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent7(inParam)
    inParam.callback = function(inType, result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        -- 敌方占领展示处理
        if inType == 3  then 
            self:listenModelEleStateCur()
            DialogUtils.showGiftGet( {
                gifts = result["reward"], 
                callback = function()
                end
            })
        -- 敌方占领展示处理
        elseif inType == 2 or  inType == 1 then 
            self:listenModelEleStateCur()
            -- 占领
            if inType == 1  then 
                self:listenModelRoleProgressCur()
            else
                self:listenModelCancelRoleProgressCur()
            end
        else
            -- 我方自己占领展示
            self:listenModelEleStateCur()
            local mapList = self._guildMapModel:getData().mapList
            self:showFlagEffect(self._gridElements[inParam.targetId], inParam.eleId, mapList[inParam.targetId][inParam.typeName])

        end
        -- self:listenModelEleState()
    end
    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end

--[[
--! @function showEvent9
--! @desc 故事情节
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent9(inParam)
    local sysGuildMapThing = tab:GuildMapThing(inParam.eleId)
    if sysGuildMapThing.story == nil then 
        return
    end
    local storyView = ViewManager:getInstance():enableTalking(sysGuildMapThing.story, "", function()

    end, false)
end


--[[
--! @function showEvent6
--! @desc 读条获得buff
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent6(inParam)
    inParam.callback = function(inType, result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end

        if type(inType) == "table" and inType.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SWITCH_MAP then
            self._guildMapModel:clear()
            self._parentView:getMapInfo()
            return
        end

        if inType == 3  then 
            self:listenModelDelEleCur()
            local sysGuildMapThing = tab:GuildMapThing(inParam.eleId)
            self._viewMgr:showTip(lang(sysGuildMapThing.feedback))
        else
            self:listenModelEleStateCur()
            -- 占领
            if inType == 1  then 
                self:listenModelRoleProgressCur()
            else
                self:listenModelCancelRoleProgressCur()
            end
             -- 敌方处理
            self:listenModelDelEle()
            self:listenModelEleState()
            self:listenModelRoleMove()
            self:listenModelRoleQuit()
            
            -- 我方处理
            self:listenModelDelEleCur()
            self:listenModelEleStateCur()
            self:listenModelBackCityCur()              
        end
    end
    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end



--[[
--! @function showEvent5
--! @desc 读条获得奖励
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent5(inParam)
    inParam.callback = function(inType, result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        
        if type(inType) == "table" and inType.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SWITCH_MAP then
            self._guildMapModel:clear()
            self._parentView:getMapInfo()
            return
        end
        local userId = self._modelMgr:getModel("UserModel"):getData()._id
        self._gridElements[inParam.targetId].occupyId = userId
        if inType == 3  then 
            self:listenModelDelEleCur()
            DialogUtils.showGiftGet( {
                gifts = result["reward"], 
                callback = function()
                    -- 防止地图刷新，无法继续执行下面动作
                    if self.showEvent1 == nil then
                        return
                    end
                    self._viewMgr:lock(-1)
                    local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
                        anim:addCallbackAtFrame(8, function() 
                                self._viewMgr:unlock()
                            end)
                    anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
                    self._bgSprite:addChild(anim, 1000)
                end
            })
        else
            self:listenModelEleStateCur()
            -- 占领
            if inType == 1  then 
                self:listenModelRoleProgressCur()
            else
                self:listenModelCancelRoleProgressCur()
            end
             -- 敌方处理
            self:listenModelDelEle()
            self:listenModelEleState()
            self:listenModelRoleMove()
            self:listenModelRoleQuit()
            
            -- 我方处理
            self:listenModelDelEleCur()
            self:listenModelEleStateCur()
            self:listenModelBackCityCur()           
        end
    end
    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end

--[[
--! @function showEvent3
--! @desc buff兑换
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent3(inParam)
    -- if self._lockGrid[inParam.targetId] ~= nil then 
    --     return
    -- end
    -- self._lockGrid[inParam.targetId] = 1
     inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        local sysGuildMapThing = tab:GuildMapThing(inParam.eleId)
        self._viewMgr:lock(-1)
        local building = self._gridElements[inParam.targetId]
        local equipId = sysGuildMapThing.equip[1][1]
        local sysEquip = tab:GuildEquipment(equipId)     
        self._viewMgr:showTip("获得装备" .. lang(sysEquip.name))   
        local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
            anim:addCallbackAtFrame(8, function() 

                    local equipSp = cc.Sprite:createWithSpriteFrameName(sysEquip.art .. ".png")
                    local buildingX, buildingY = building:getPosition()
                    equipSp:setPosition(buildingX, buildingY + 80)
                    equipSp:setAnchorPoint(0.5, 0)
                    equipSp:setScale(0.8)
                    self._bgSprite:addChild(equipSp, 500)
                    equipSp:runAction(
                        cc.Sequence:create(
                            cc.EaseIn:create(cc.MoveTo:create(0.1, cc.p(buildingX, buildingY + 120)), 1),
                            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(buildingX, buildingY)), 1),
                            cc.DelayTime:create(0.2),
                            cc.FadeOut:create(0.1),
                            cc.CallFunc:create(function()
                                
                                local equipBtn = self._parentView:getUI("Panel_29.extendBar.bg.map_equip_btn")
                                
                                local buildingWorldPos = self._bgSprite:convertToWorldSpace(cc.p(buildingX, buildingY + equipSp:getContentSize().height * 0.6))
                                
                                local mc1 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true, false) 
                                mc1:setName("mc1")
                                mc1:setPosition(buildingWorldPos.x, buildingWorldPos.y)
                                self._parentView:addChild(mc1, 500)
                                equipSp:removeFromParent()

                                local mc2 = mcMgr:createViewMC("lashentiao_lianmengjihuo", false, false)  
                                mc2:setAnchorPoint(cc.p(0.5, 0))
                                mc2:setScaleX(0)
                                mc1:addChild(mc2, -1)

                                local equipX, equipY = equipBtn:getPosition()

                                local mcPos = self._parentView:convertToWorldSpace(cc.p(equipX, equipY))
                                mcPos.x = mcPos.x - equipBtn:getContentSize().width

                                local disicon = MathUtils.pointDistance(mcPos, buildingWorldPos)
                                local speed = disicon/1000
                                local scay = 1
                                if disicon < 150 then
                                    scay = 0.5
                                elseif disicon > 400 then
                                    scay = 2
                                end
                                local angle = 180 - MathUtils.angleAtan2(mcPos, buildingWorldPos) + 90
                                mc1:setRotation(angle)

                                local move1 = cc.Sequence:create(   
                                        cc.DelayTime:create(0.2), 
                                        cc.MoveTo:create(speed + 0.1, mcPos), 
                                        cc.CallFunc:create(function()
                                            mc1:removeFromParent()
                                            local mc3 = mcMgr:createViewMC("fankui_lianmengjihuo", false, true, nil, RGBA8888)  
                                            mc3:setPosition(mcPos)
                                            self._parentView:addChild(mc3,100) 
                                        end)
                                        )
                                mc1:runAction(move1)

                                local spSeq = cc.Sequence:create(
                                        cc.ScaleTo:create(0.2, 0, 1), 
                                        cc.ScaleTo:create(speed+0.1, scay, 1), 
                                        cc.ScaleTo:create(0, 0, 1), cc.FadeOut:create(0.1))
                                mc2:runAction(spSeq)

                             end)
                            ))
                self:listenModelDelEleCur()
                self._viewMgr:unlock()
                end)
        anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
        self._bgSprite:addChild(anim, 1000)
    end   
    self:getBuff(inParam.targetId, inParam.callback)
    -- self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end

--[[
--! @function showEvent2
--! @desc 兑换奖励
--! @param inTargetId 目标id
--! @param inEleId  固件id
--! @return 
--]]
function GuildMapLayer:showEvent2(inParam)
    -- if self._lockGrid[inParam.targetId] ~= nil then 
    --     return
    -- end
    -- self._lockGrid[inParam.targetId] = 1
    self:lockTouch()
    inParam.closePopCallback = function()
        if self.unLockTouch ~= nil then
            self:unLockTouch()
        end
    end   
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end    
        if result == nil then 
            self:unLockTouch()
            -- self:unLockTouch()
            return
        end
        local mcCallback = function()
            self:unLockTouch()
            -- 防止地图刷新，无法继续执行下面动作
            if self.showEvent1 == nil then
                return
            end        
            print("mcCallback=============================",os.time())
            self._viewMgr:lock(-1)
            local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
                anim:addCallbackAtFrame(8, function() 
                    self:listenModelDelEleCur()
                    self._viewMgr:unlock()
                    -- self:unLockTouch()
                    end)
            anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
            self._bgSprite:addChild(anim, 1000)
        end
        if result["reward"] ~= nil then
            DialogUtils.showGiftGet( {
                gifts = result["reward"], 
                callback = mcCallback
            })  
        else
            mcCallback()     
        end
    end       
    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end

--[[
--! @function showEvent4
--! @desc 散迷雾
--! @param inTargetId 目标id
--! @return 
--]]
function GuildMapLayer:showEvent4(inParam)
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end         
        self:listenModelMissFogCur() 
        local mapList = self._guildMapModel:getData().mapList
        self:showActiveEventEffect(self._gridElements[inParam.targetId], inParam.eleId, mapList[inParam.targetId][inParam.typeName])
    end        
    self._viewMgr:showDialog("guild.map.GuildMapEventView",inParam, true)
end

--[[
--! @function showEvent1
--! @desc 直接领取奖励
--! @param inTargetId 目标id
--! @return 
--]]
function GuildMapLayer:showEvent1(inParam)
    print("showEvent1=============================",socket.gettime())
    -- if self._lockGrid[inParam.targetId] ~= nil then 
    --     return
    -- end
    -- self._lockGrid[inParam.targetId] = 1
    self:lockTouch()
    inParam.closePopCallback = function()
        if self.unLockTouch ~= nil then
            self:unLockTouch()
        end
    end
    inParam.callback = function(result)
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        -- 锁定建筑，防止连续点击
        if self._gridElements[inParam.targetId] ~= nil then 
            self._gridElements[inParam.targetId].lock = true
        end
        DialogUtils.showGiftGet( {
            gifts = result["reward"], 
            callback = function()
                -- 防止地图刷新，无法继续执行下面动作
                if self.showEvent1 == nil then
                    return
                end
                self._viewMgr:lock(-1)
                local anim = mcMgr:createViewMC("ziyuanxiaoshi_guildmapzhanling", false, true)
                    anim:addCallbackAtFrame(8, function() 
                            self:listenModelDelEleCur()
                            self._viewMgr:unlock()
                            self:unLockTouch()
                        end)
                anim:setPosition(inParam.targetPos.x, inParam.targetPos.y)
                self._bgSprite:addChild(anim, 1000)
                self:getParent():reflashPushMapTask()
            end
        ,notPop = true})
    end     
    self._viewMgr:showDialog("guild.map.GuildMapEventView", inParam, true)
end


--[[
--! @function showPVPEvent
--! @desc 敌对势力
--! @param inGridKey 目標點id
--! @param inUserIds 用戶id列表
--! @param isFriend 友方查看
--! @return 
--]]
function GuildMapLayer:showPVPEvent(inGridKey, inUserIds, inIsFriends)
    GuildConst.IS_ENTER_BACK = false
    local param = {}
    param.targetId = inGridKey
    param.userIds = inUserIds
    param.callback = function(result)
        if self._parentView ~= nil and self._parentView:checkMapUpdate() == true then return true end
        -- 防止地图刷新，无法继续执行下面动作
        if self.showEvent1 == nil then
            return
        end
        if result == nil then return end
        
        -- 战斗前请求
        if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_PVP_NOT_EXIST then 
            self:listenModelDelEleCur()
            self:listenModelEleStateCur()
            self:listenModelBackCityCur()
            self:listenModelBackReviveCur()
            self._viewMgr:showTip(lang("GUILDMAPTIPS_7"))
            return 
        end    
        if result.code == GuildConst.GUILD_MAP_RESULT_CODE.GUILD_MAP_SWITCH_MAP then
            self._guildMapModel:clear()
            self._parentView:getMapInfo()
            return
        end
        -- 敌方处理
        self:listenModelDelEle()
        self:listenModelEleState()
        self:listenModelRoleMove()
        self:listenModelRoleQuit()
        
        -- 我方处理
        self:listenModelDelEleCur()
        self:listenModelEleStateCur()
        self:listenModelBackCityCur()
        self:listenModelBackReviveCur()
    end
    param.isFriends = inIsFriends
    self._viewMgr:showDialog("guild.map.GuildMapPvpView", param, true)    
end


function GuildMapLayer:getPointInfo(inTargetId, inCallback)
    self._serverMgr:sendMsg("GuildMapServer", "getPointInfo", {tagPoint = inTargetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        dump(result, "test", 10)
        if inCallback  ~= nil then 
            inCallback()
        end
    end)
end

function GuildMapLayer:getBuff(inTargetId, inCallback)
    self._serverMgr:sendMsg("GuildMapServer", "getBuff", {tagPoint = inTargetId}, true, {}, function(result)
        if result == nil then 
            return
        end
        if inCallback ~= nil then 
            inCallback(result)
        end
    end)
end
