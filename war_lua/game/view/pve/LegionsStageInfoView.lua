--
-- Author: huangguofang
-- Date: 2018-12-17 18:25:17
--

local LegionsStageInfoView = class("LegionsStageInfoView", BaseView)

function LegionsStageInfoView:ctor(param)
    LegionsStageInfoView.super.ctor(self)
   
    self._stageId = param.stageId or 101
	self._curIndex = param.index--本日关卡列表对应的index
	self._curWeek = param.week
    self._stageData = tab:ProfessionBattle(tonumber(self._stageId)) or {}
    self._subId = self._stageData.subid or 3

    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._profBattleModel = self._modelMgr:getModel("ProfessionBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

-- function LegionsStageInfoView:getAsyncRes()
--     return 
--         {
--             {"asset/ui/professionBattle.plist", "asset/ui/professionBattle.png"},
--         }
-- end

function LegionsStageInfoView:getBgName()
    return "legionsBattle/bg_legionsBattle_".. (self._subId or 2)  ..".jpg"
end

local airenOutlineColor = cc.c4b(90,44,0,255)
function LegionsStageInfoView:onInit()
    -- self._tableData = tab:PveSetting(self._stageData.id)

    self._infoData = {
        [1] = {
            typeName = "攻",
            formationType = self._formationModel.kFormationTypeProfession1,
            teamImg = "t_datianshi.png",
        },
        [2] = {
            typeName = "防",
            formationType = self._formationModel.kFormationTypeProfession2,
            teamImg = "t_bimeng.png",
        },
        [3] = {
            typeName = "突",
            formationType = self._formationModel.kFormationTypeProfession3,
            teamImg = "t_qishi.png",
        },
        [4] = {
            typeName = "射",
            formationType = self._formationModel.kFormationTypeProfession4,
            teamImg = "t_feima.png",
        },
        [5] = {
            typeName = "魔",
            formationType = self._formationModel.kFormationTypeProfession5,
            teamImg = "t_fenghuang.png",
        },
    }

    self:registerClickEventByName("bg.btn_return", function()
        self:close()
        UIUtils:reloadLuaFile("pve.LegionsStageInfoView")
    end)    

    local title = self:getUI("bg.titlePanel.titleImg.titleTxt1")
    self._title = self:getUI("bg.titlePanel.titleImg.titleTxt2")
    local info = self._infoData[self._subId] or {}
    self._title:setString(info.typeName or "")
    local flagImg = self:getUI("bg.titlePanel.titleImg.flagImg")
    flagImg:loadTexture("battle_type_img_" .. self._subId .. ".png",1)


    local mainNode = self:getUI("bg.mainNode")
    mainNode:setSwallowTouches(false)
    local leftPanel = self:getUI("bg.leftPanel")
    leftPanel:setSwallowTouches(false)
    local teamImg = leftPanel:getChildByFullName("teamImg")
    local desTxt = leftPanel:getChildByFullName("desTxt")
    local flagImg = leftPanel:getChildByFullName("flagImg")
    local typeTxt = leftPanel:getChildByFullName("typeTxt")
    local leftTimeTxt = leftPanel:getChildByFullName("leftTimeTxt")
    local ruleBtn = leftPanel:getChildByFullName("ruleBtn")
    teamImg:loadTexture("asset/uiother/team/" .. info.teamImg)

    local currWday = self._stageData.time[1] or 1--self._profBattleModel:getCurWeekDay()
    local wDay = currWday + 1    
    local nextDayID = self._profBattleModel:getCurWeekType(wDay)   

    local leftTime = self:getNextDayTime()
    self._leftTimeTxt = leftTimeTxt    
    self._leftTime = leftTime
    if not nextDayID then 
        desTxt:setString("明日试炼:不开放")
        flagImg:setVisible(false)
        typeTxt:setVisible(false)
        -- leftTimeTxt:setVisible(false)
        leftTimeTxt:setString("不开放")
    else
        desTxt:setString("明日试炼:")
        flagImg:setVisible(true)
        typeTxt:setVisible(true)
        -- leftTimeTxt:setVisible(true)
        flagImg:loadTexture("battle_type_img_" .. nextDayID .. ".png",1)
        typeTxt:setString(self._infoData[nextDayID].typeName)
        leftTimeTxt:setString(leftTime .. "小时")
        
    end
    leftTimeTxt:runAction(
        CCRepeatForever:create(
            cc.Sequence:create(cc.DelayTime:create(5),
                cc.CallFunc:create(function()
                    local currWday = self._stageData.time[1] --self._profBattleModel:getCurWeekDay()
                    local wDay = currWday + 1    
                    local nextDayID = self._profBattleModel:getCurWeekType(wDay) 
                    if not nextDayID then
                        self._leftTimeTxt:setString("不开放")
                    else
                        self._leftTime = self:getNextDayTime()
                        self._leftTimeTxt:setString(self._leftTime .. "小时")
                    end
            end))
        )        
    )  
    self:registerClickEvent(ruleBtn, function()
        local ruleDesc = lang("ArmyTestRule")
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = ruleDesc},true)
    end)
    
    local stageTitleTxt = mainNode:getChildByFullName("titleImg.titleTxt")
    stageTitleTxt:setString("关卡推荐等级：" .. (self._stageData.level or 0) .. "级")

    local label_title = mainNode:getChildByFullName("enemyPanel.label_title")
    label_title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:addPanelScrollView(mainNode:getChildByFullName("enemyPanel"),clone(self._stageData.monsterShow),"team")

    label_title = mainNode:getChildByFullName("recommandPanel.label_title")
    label_title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:addPanelScrollView(mainNode:getChildByFullName("recommandPanel"),clone(self._stageData.recommend),"team")

    label_title = mainNode:getChildByFullName("rewardPanel.label_title")
    label_title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:addPanelScrollView(mainNode:getChildByFullName("rewardPanel"),clone(self._stageData.reward),"reward")

    self._leftCounts = mainNode:getChildByFullName("label_times_value")

    self._btnBattle = mainNode:getChildByFullName("btn_battle")    
    self:registerClickEvent(self._btnBattle, function()
        self:doBattle()
    end)

    -- 扫荡
    self._btnSweep = mainNode:getChildByFullName("btn_sweep")
    self:registerClickEvent(self._btnSweep, function()
        self:onSweepBtnClicked()        
    end)

    self:listenReflash("ProfessionBattleModel", self.updateUI)
end

function LegionsStageInfoView:getNextDayTime()
    local currTime = self._userModel:getCurServerTime()
    local nextStartTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 05:00:00"))
    if nextStartTime < currTime then
        nextStartTime = nextStartTime + 86400
    end
    local leftTime = nextStartTime - currTime
    if leftTime <= 0 then
        leftTime = 0 
    end
    leftTime = math.ceil(leftTime/3600)

    return leftTime
end

function LegionsStageInfoView:addPanelScrollView(panel,awards,iconType)
    local iconScro = panel:getChildByFullName("iconScro")
    if not iconScro then return end
    iconScro:removeAllChildren()
    iconScro:setBounceEnabled(true)
    local tempAwards = {}
    if iconType == "reward" then
        for k,v in pairs(awards) do
            if not tempAwards[v[2]] then
                tempAwards[v[2]] = v
            end
        end
        awards = {}
        for k,v in pairs(tempAwards) do
            table.insert(awards, v)
        end
    end
   

    local itemH = 60
    local itemW = 60
    local itemNum = #awards
    local width = itemH * itemNum
    if width < iconScro:getContentSize().width then
        width = iconScro:getContentSize().width
    end
    local posY = width
    iconScro:setInnerContainerSize(cc.size(width, iconScro:getContentSize().height))
    
    for i=1,itemNum do
        local rewardD = awards[i]
        local icon 
        if iconType == "reward" then
            local itemId = rewardD[2]
            if rewardD[1] == "team" then
                itemId = rewardD[2]
                local teamD = tab.team[itemId] or tab.npc[itemId]
                icon = IconUtils:createSysTeamIconById({sysTeamData = teamD})
                icon:setScale(0.52)
                icon:setPosition((i-1)*itemW,1)
            else
                if rewardD[1] == "tool" then
                    itemId = rewardD[2]
                else
                    itemId = IconUtils.iconIdMap[rewardD[1]]
                end
                local toolD = tab:Tool(tonumber(itemId))
                
                local toolData = tab:Tool(itemId)
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD}) --,num = rewardD[3]
                icon:setScale(0.58)
                icon:setPosition((i-1)*itemW,1)
            end
            icon:setSwallowTouches(false)
            icon:setAnchorPoint(0,0)
            
            iconScro:addChild(icon)
        else
            local itemId = rewardD
            local teamD = tab.team[itemId] or tab.npc[itemId]
            icon = IconUtils:createSysTeamIconById({sysTeamData = teamD,star = false})
            icon:setScale(0.52)
            icon:setPosition((i-1)*itemW,1)
            icon:setSwallowTouches(false)
            icon:setAnchorPoint(0,0)
            
            iconScro:addChild(icon)
        end
    end

end

function LegionsStageInfoView:updateUI()
    local maxTimes = self._profBattleModel:getMaxTimes()
    local hasTimes = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(96)
    self._leftCounts:setString((maxTimes-hasTimes).."/"..maxTimes)
    self._leftCounts:setColor((maxTimes-hasTimes) == 0 and cc.c3b(255, 0, 0) or cc.c3b(0, 255, 0))
    
    print("==============self._leftCounts=========",maxTimes,hasTimes,self._stageId)
    -- 更新扫荡和战斗按钮的显示及位置
    local serverData = self._profBattleModel:getDataById(self._stageId)
    dump(serverData,"serverData",5)
    dump(self._profBattleModel:getData(),"serverData123",5)
    local sweepIsVisible = serverData and serverData.win == 1
    self._btnSweep:setVisible(sweepIsVisible)
    if not sweepIsVisible then        
        self._btnBattle:setPositionX(933)
    else
        self._btnBattle:setPositionX(1029)
    end

end

function LegionsStageInfoView:onSweepBtnClicked()
    -- 判断次数限制
    local maxTimes = self._profBattleModel:getMaxTimes()
    local hasTimes = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(96)
    if maxTimes - hasTimes <= 0 then
        self._viewMgr:showTip(lang("TIPS_PVE_01"))
        return
    end
    -- 时间过期
    local weekDay = self._profBattleModel:getCurWeekDay()
    local currWDay = self._stageData.time and self._stageData.time[1] or 1
    if weekDay ~= currWDay or self._leftTime <= 0 then
        self._viewMgr:showTip("挑战时间已过期")
        return
    end

    local sweepFunc = function()        
        self._serverMgr:sendMsg("ProfessionBattleServer", "sweep", {barrierId = self._stageData.id}, true, {}, function(success, result)
            if not success then
                self._viewMgr:showTip("扫荡失败。")
                return
            end

            local params = {gifts = result.reward}      --,pveDes=lang("PVE_SAODANG_901")       
            DialogUtils.showGiftGet(params)
            -- self:updateUI()
        end)
    end

    sweepFunc()
end

function LegionsStageInfoView:doBattle()
    -- 判断次数限制
    local maxTimes = self._profBattleModel:getMaxTimes()
    local hasTimes = self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(96)
    if maxTimes - hasTimes <= 0 then
        self._viewMgr:showTip(lang("TIPS_PVE_01"))
        return
    end
    -- 时间过期
    local weekDay = self._profBattleModel:getCurWeekDay()
    local currWDay = self._stageData.time and self._stageData.time[1] or 1
    if weekDay ~= currWDay or self._leftTime <= 0 then
        self._viewMgr:showTip("挑战时间已过期")
        return
    end

    local battle = function(battleData)
        -- 时间过期
        local weekDay = self._profBattleModel:getCurWeekDay()
        local currWDay = self._stageData.time and self._stageData.time[1] or 1
        if weekDay ~= currWDay or self._leftTime <= 0 then
            print("===========battle=============",weekDay,currWDay)
            self._viewMgr:showTip("挑战时间已过期")
            return
        end
        self._serverMgr:sendMsg("ProfessionBattleServer", "beforeBattle", {barrierId = self._stageData.id, 
            serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(errorCode, result)
                if 0 ~= errorCode then 
                    print("==========sendMsg=beforeBattle=============",weekDay,currWDay)
                    print("beforeBattle error:", self._stageData.id, errorCode)
                    -- self._viewMgr:onLuaError("beforeBattle error:" .. "id:" .. self._stageData.id .. "error code:" .. errorCode)
                    if 9852 == errorCode then 
                        self._viewMgr:showTip("挑战时间已过期")
                    end
                    return 
                end
                self._token = result.token
                self._viewMgr:popView()

                local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
                BattleUtils.enterBattleView_Legion(playerInfo,
                    self._stageData.id,
                    function (info, callback)
                        if info.isSurrender then
                            callback(info)
                            return
                        end
                        local args = {win = info.win and 1 or 0, 
                                      time = info.time,
                                      serverInfoEx = info.serverInfoEx,
                                      }
                        local hp = info.hp or {}
                        local hpPercent = 0
                        if hp[3] and hp[4] then
                            hpPercent = math.ceil(hp[3]/hp[4]*100)
                        end
                        info.hpPercent = hpPercent
                        -- print(hp[3],hp[4],"=info.hpPercent===",info.hpPercent)
                        info.stageData = self._stageData
                        self._serverMgr:sendMsg("ProfessionBattleServer", "afterBattle", {barrierId = self._stageData.id, 
                            token = self._token,
                            win = info.win and 1 or 0,
                            pace = hpPercent,
                            args = json.encode(args)},
                            true,
                            {},
                            function(errorCode, result)
                                if 0 ~= errorCode then 
                                    -- print("afterBattle error:", self._stageData.id, errorCode)
                                    -- self._viewMgr:onLuaError("afterBattle error:" .. "id:" .. self._stageData.id .. "error code:" .. errorCode)
                                    -- return 
                                    self._isErrorExit = true
                                    info.isSurrender = true
                                    info.isErrorExit = true
                                end
                                -- dump(result, "afterAttackBoss", 10)
                                local reward = nil
                                if result and result.reward then
                                    reward = result.reward
                                end
                                callback(info, reward)
								self._win = info.win
								--[[--]]
							end)
                    end,
                    function(info)
						local isWin = self._win
						self._win = nil
						local nextIndex = self._curIndex + 1--下一关的index
						local myLevel = self._userModel:getPlayerLevel()
						local weekData = self._profBattleModel:getWeekList(self._curWeek)
						local maxTimes = self._profBattleModel:getMaxTimes()
						local hasTimes = maxTimes - self._modelMgr:getModel("PlayerTodayModel"):getDayInfo(96)
						local isClose = false
                        if isWin and--赢了
							weekData[nextIndex] and--有下一关
								myLevel>=weekData[nextIndex].level and hasTimes>0 then--等级足够并且还有剩余可用次数
									isClose = true
						end
                        if self._isErrorExit then   --跨时间异常退出
                            -- print(self._isErrorExit,"===================挑战时间已过期=========================")
                            -- ScheduleMgr:nextFrameCall(self, function()
                            --      ViewManager:getInstance():showTip("挑战时间已过期")
                            -- end)
                            isClose = true
                        end
                        if isClose then
                            self:close()
                        end
					end)
            end)
    end


    local infoD = self._infoData[self._stageData.subid]
    local formationType = self._formationModel.kFormationTypeProfession1
    if infoD then
        formationType = infoD.formationType or self._formationModel.kFormationTypeProfession1
    end
    local enemyInfo ,recommend= self:formatFormationData(self._stageData)
    -- print("======formationType====",formationType)
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationType,
        recommend = recommend,
        enemyFormationData = {[formationType] = enemyInfo},
        extend = {pveData = {formationinf = self._stageData.formationinf}},
        callback = function(battleData)
            battle(battleData)
        end
    })
end

-- 格式化敌方布阵数据
function LegionsStageInfoView:formatFormationData(data)
    -- 敌方上阵兵团
    local enemyFormationData = {}
    local enemynpc = data.NPC or {}
    local fightScore = 0
    for i=1,8 do
        local npcData = enemynpc[i]
        if npcData then
            enemyFormationData["team" .. i] = tonumber(npcData[1])
            enemyFormationData["g" .. i] = tonumber(npcData[2])
            local enemyData = tab:Npc(tonumber(npcData[1]))
            if enemyData and enemyData.score then
                fightScore = fightScore + tonumber(enemyData.score) 
            end
        else
            enemyFormationData["team" .. i] = 0
            enemyFormationData["g" .. i] = 0
        end
    end
    -- 过滤不显示的兵团id
    enemyFormationData.filter = "" 
    --上阵英雄
    enemyFormationData.heroId = tonumber(data.hero)
    local heroData = tab:NpcHero(tonumber(data.hero))
    if heroData and heroData.score then
        fightScore = fightScore + tonumber(heroData.score) 
    end
    -- 战斗力
    enemyFormationData.score = fightScore

    local recommend = data.recommend or {}

    return enemyFormationData ,recommend
end

--进入动画
function LegionsStageInfoView:beforePopAnim()
    local titleImg = self:getUI("bg.titlePanel.titleImg")
    if titleImg then
        titleImg:setOpacity(0)
    end
end

function LegionsStageInfoView:popAnim(callback)
    local titleImg = self:getUI("bg.titlePanel.titleImg")
    if titleImg then
        ScheduleMgr:nextFrameCall(self, function()
            titleImg:stopAllActions()
            titleImg:setOpacity(255)
            local x, y = titleImg:getPositionX(), titleImg:getPositionY()
            titleImg:setPosition(x, y + 80)
            titleImg:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                cc.MoveTo:create(0.07, cc.p(x, y)),
                cc.CallFunc:create(function ()
                    self.__popAnimOver = true
                    if callback then callback() end
                end)
            ))
        end)
    else
        self.__popAnimOver = true
    end
end
function LegionsStageInfoView:onShow()
    self:updateUI()
end
function LegionsStageInfoView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end
function LegionsStageInfoView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function LegionsStageInfoView:onDestroy( )
    self._viewMgr:disableScreenWidthBar()
    LegionsStageInfoView.super.onDestroy(self)
end


function LegionsStageInfoView:onTop()
    self._viewMgr:enableScreenWidthBar()

    self:updateUI()
end

--[[
function LegionsStageInfoView.dtor()
    PVETYPE = nil
    airenOutlineColor = nil
end
]]

return LegionsStageInfoView