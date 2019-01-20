--[[
    Filename:    CrusadeBattleNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-30 18:56:58
    Description: File description
--]]


local CrusadeBattleNode = class("CrusadeBattleNode", BasePopView)

function CrusadeBattleNode:ctor()
    CrusadeBattleNode.super.ctor(self)
    self._mercenaryId = 0
    self._userId = 0
end


function CrusadeBattleNode:onInit()
    -- self:registerClickEventByName("bg.closeBtn", function ()
 --        self:close()
 --    end)
    local labScore = self:getUI("bg.labScore")
    labScore:setFntFile(UIUtils.bmfName_zhandouli_little) 
    labScore:setScale(0.8)
    labScore:setPosition(10, 115)


    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(180)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(bgLayer)

    registerClickEvent(bgLayer, function()
        UIUtils:reloadLuaFile("crusade.CrusadeBattleNode")
        self:close()
    end)
end

function CrusadeBattleNode:reflashUI(data)
    self._curCrusadeId = data.crusadeId
    self._crusadeData = data.crusadeData
    self._crusadeEnemy = data.enemyD

    self._callback = data.callback
    self._callback2 = data.callback2
    local formationBg = self:getUI("bg.formationBg")
    local x, y = 30, 100

    local teamModel = self._modelMgr:getModel("TeamModel")


    local filter = {}
    if self._crusadeEnemy.formation.filter ~= nil then 
        local tempFilter = string.split(self._crusadeEnemy.formation.filter, ",")
        for k,v in pairs(tempFilter) do
            if string.len(v) > 0 then 
                filter[tostring(v)] = true
            end
        end
    end
    local j = 0
    for i=1,8 do
        -- data.crusadeData.formation.heroId 英雄ID
        local teamId = data.crusadeData.formation["team" .. i]
        local teamData = self._crusadeEnemy.teams[tostring(teamId)]
        -- local _,changeId = TeamUtils.changeArtForHeroMastery(data.crusadeData.formation.heroId,teamId)
        local _,changeId = TeamUtils.changeArtForHeroMasteryByData(self._crusadeEnemy.hero,data.crusadeData.formation.heroId,teamId)
        if changeId then
            teamId = changeId
        end
        if teamId ~= nil and tonumber(teamId) > 0 and teamData ~= nil then
            j = j + 1
            local backQuality = teamModel:getTeamQualityByStage(teamData.stage)
            -- data.teams[teamId]
            local sysTeam = tab:Team(teamId)
            local icon = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = sysTeam, quality = backQuality[1], quaAddition = backQuality[2], eventStyle = 0})
            icon:setPosition(x, y)
            icon:setAnchorPoint(0, 0)
            icon:setScale(0.8)
            x = x + icon:getContentSize().width * icon:getScale() + 5
            if j == 4 then 
                x = 30
                y = 10
            end
            formationBg:addChild(icon)
        end
    end
    -- 死亡
    for k,v in pairs(filter) do
        local teamId = clone(k)
        local teamData = self._crusadeEnemy.teams[tostring(k)]
        local _,changeId = TeamUtils.changeArtForHeroMasteryByData(self._crusadeEnemy.hero,data.crusadeData.formation.heroId,k)
        if changeId then
            teamId = changeId
        end
        if teamId ~= nil and tonumber(teamId) > 0 and teamData ~= nil then
            j = j + 1
            local backQuality = teamModel:getTeamQualityByStage(teamData.stage)
            -- data.teams[teamId]
            local sysTeam = tab:Team(tonumber(teamId))
            local icon = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = sysTeam, quality = backQuality[1], quaAddition = backQuality[2], eventStyle = 0})
            icon:setPosition(x, y)
            icon:setAnchorPoint(0, 0)
            icon:setScale(0.8)
            local dieTip = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
            dieTip:setPosition(x + icon:getContentSize().width * 0.8 / 2 ,y + icon:getContentSize().height * 0.8 / 2)
            formationBg:addChild(dieTip, 100)
            icon:setSaturation(-180)
            x = x + icon:getContentSize().width * icon:getScale() + 5
            if j == 4 then 
                x = 30
                y = 10
            end
            formationBg:addChild(icon)
        end
    end

    local labScore = self:getUI("bg.labScore")
    labScore:setString("a" .. data.crusadeData.formation.score)
    labScore:setFntFile(UIUtils.bmfName_zhandouli) 

    self:getUI("bg.Label_36"):enableOutline(cc.c4b(60,30,10,255), 2)
    local labName = self:getUI("bg.labName")
    labName:setString(data.crusadeData.name)
    labName:setColor(cc.c3b(255, 255, 255))
    labName:enableOutline(cc.c4b(60, 34, 10, 255), 2)

    local sysCrusadeMain = tab:CrusadeMain(self._curCrusadeId)

    local goldTipImg = self:getUI("bg.goldTipImg")    
    local scaleNum1 = math.floor((32/goldTipImg:getContentSize().width)*100)
    goldTipImg:setScale(scaleNum1/100)

    local labGold = self:getUI("bg.labGold")
    labGold:setPositionX(goldTipImg:getPositionX()+goldTipImg:getContentSize().width*scaleNum1/100/2 + 1)
    local lvl = self._modelMgr:getModel("UserModel"):getData().lvl
    labGold:setString(sysCrusadeMain.goldBasic * (1 + (lvl - 30) * sysCrusadeMain.goldRatio))
    labGold:enableOutline(cc.c4b(0, 0, 0,255), 1)

    local cruGoldTipImg = self:getUI("bg.cruGoldTipImg")
    local scaleNum2 = math.floor((32/cruGoldTipImg:getContentSize().width)*100)
    cruGoldTipImg:setScale(scaleNum2/100)
    local labCruGold = self:getUI("bg.labCruGold")
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local discount = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_12)
    labCruGold:setColor(discount ~= 0 and UIUtils.colorTable.ccUIBaseColor2 or UIUtils.colorTable.ccUIBaseColor1)
    if sysCrusadeMain.coin then
        local vipInfo = self._modelMgr:getModel("VipModel"):getData()
        local sysVip = tab:Vip(vipInfo.level)
        labCruGold:setString(sysCrusadeMain.coin * (sysVip.crusadeAdd / 100 + 1 + discount))
        labCruGold:enableOutline(cc.c4b(0, 0, 0,255), 1)
    else
        labCruGold:setVisible(false)
        cruGoldTipImg:setVisible(false)
    end
    self:initAbilityEffect(value)

    if data.enemyD.hero.skin then
        local sysSkin = tab:HeroSkin(data.enemyD.hero.skin)
        if sysSkin then
            local panelBg = self:getUI("bg.Panel_105")
            local heroSp = cc.Sprite:create("asset/uiother/hero/" .. sysSkin.wholecut .. ".png")
            heroSp:setAnchorPoint(0.5,0)
            panelBg:addChild(heroSp)
            if sysSkin.crusadePosi == nil then
                heroSp:setVisible(false)
            else
                heroSp:setPosition(sysSkin.crusadePosi[1], sysSkin.crusadePosi[2])
                if sysSkin.crusadePosi[3] then
                    heroSp:setScale(sysSkin.crusadePosi[3])
                end
            end
        end
    else
        local sysHero = tab:Hero(data.crusadeData.formation.heroId)
        local panelBg = self:getUI("bg.Panel_105")
        local heroSp = cc.Sprite:create("asset/uiother/hero/" .. sysHero.crusadeRes .. ".png")
        heroSp:setPosition(sysHero.crusadePosi[1], sysHero.crusadePosi[2])
        heroSp:setAnchorPoint(0.5,0)
        panelBg:addChild(heroSp)
    end
    
    local battleBtn = self:getUI("bg.battleBtn")
    local amin1 = mcMgr:createViewMC("zhandouguangxiao_battlebtn", true)
    amin1:setPosition(battleBtn:getContentSize().width/2, battleBtn:getContentSize().height/2)
    battleBtn:addChild(amin1)   

    local image_38 = self:getUI("bg.battleBtn.Image_38")
    local amin2 = mcMgr:createViewMC("zhengfusaoguang_battlebtn", true)
    amin2:setPosition(image_38:getContentSize().width/2, image_38:getContentSize().height/2)
    image_38:addChild(amin2)

    --战斗
    registerClickEvent(battleBtn,function()
        print("beforeAttackCrusade")
        -- dump(userCruasade,"test",10)
        local crusadeEnemy = clone(self._crusadeEnemy)
        self:beforeAttackCrusade(crusadeEnemy)
    end)

    --扫荡
    self:refreshSweepState()
end

--一键扫荡
function CrusadeBattleNode:refreshSweepState()
    local skipBtn = self:getUI("bg.skipBtn")
    local battleBtn = self:getUI("bg.battleBtn")
    skipBtn:setTitleText("扫荡")

    local crusadeModelData = self._modelMgr:getModel("CrusadeModel"):getData()
    local privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    local isPrivOpen = privilegesModel:getPeerageEffect(PrivilegeUtils.peerage_ID.MuXueHuLan)  --特权开启判断
    if crusadeModelData["sweepId"] and self._curCrusadeId <= crusadeModelData["sweepId"] * 2 and isPrivOpen ~= 0 then
        skipBtn:setVisible(true)
        battleBtn:setPosition(807, 248)
    else
        skipBtn:setVisible(false)
        battleBtn:setPosition(807, 208)
    end

    registerClickEvent(skipBtn, function()
        self._serverMgr:sendMsg("CrusadeServer", "sweepCrusade", {id = self._curCrusadeId}, true, {}, function (result) 
            local random = math.random(1, 1000)
            local cruModel = self._modelMgr:getModel("CrusadeModel"):getData()
            local sCallback = function()
                if self._callback ~= nil then 
                    self._callback()
                end   
                GuideUtils.checkTriggerByType("action", "7")
                if self._callback2 ~= nil then
                    self._callback2()
                end
                self._modelMgr:getModel("GuildRedModel"):checkRandRed()
                self:close(false)
            end

            if cruModel["accSweep"] > 7 and random == 666 then
                self._viewMgr:showDialog("crusade.CrusadeSweepRewardView", {data = result, sCallback = sCallback}, true)
                self:setVisible(false)
            else
                DialogUtils.showGiftGet( {
                    gifts = result["reward"],
                    callback = sCallback, 
                    notPop = true} )
            end
        end)
    end)   
end

function CrusadeBattleNode:beforeAttackCrusade(enemyD)
    self._battleWin = 0

    -- 初始化敌方数据
    local enemyInfo = BattleUtils.jsonData2lua_battleData(enemyD)
    local isSiege = tab.crusadeMain[self._curCrusadeId]["siegeid"] ~= nil
    if isSiege then
        BattleUtils.crusadeSiegeUpdateFormation(enemyInfo, enemyD)
    end
    local function callBattle(formationData)
        if self._serverMgr == nil then
            return
        end
        local battleParamTable = {
                                    id = self._curCrusadeId,
                                    serverInfoEx = BattleUtils.getBeforeSIE(),
                                    mercenaryUserId = formationData[8],
                                    mercenaryId = formationData[7],
                                    mercenaryPos= formationData[6]
                                }
        self._serverMgr:sendMsg("CrusadeServer", "beforeAttackCrusade",battleParamTable, true, {}, function(result)
            self._mercenaryId = formationData[7]
            self._userId = formationData[8]
            self._token = result.token
            local inLeftData = BattleUtils.jsonData2lua_battleData(result["atk"])
            local siegeBroken = (result.siegeBroken == 1)
            local _enemyInfo = BattleUtils.jsonData2lua_battleData(result["def"]) 
            local isSiege = tab.crusadeMain[self._curCrusadeId]["siegeid"] ~= nil
            if isSiege then
                BattleUtils.crusadeSiegeUpdateFormation(_enemyInfo, result["def"])
            end
            -- 我方远征buffer
            -- local buff = {}
            -- local crusadeModel = self._modelMgr:getModel("CrusadeModel")
            -- if crusadeModel:getData().buff ~= nil then 
            --     for k,v in pairs(crusadeModel:getData().buff) do
            --         buff[tonumber(k)] = v
            --     end
            -- end
            -- inLeftData.hero.buff = buff
            self._viewMgr:popView()
            -- dump(inLeftData, "a", 20)
            -- dump(_enemyInfo, "a", 20)
            BattleUtils.enterBattleView_Crusade(inLeftData, _enemyInfo, self._curCrusadeId, siegeBroken,
            function (info, callback)
                -- 战斗结束
                -- callback(info)
                self:afterArenaBattle(info, callback)
            end,
            function (info)
                print("退出战斗")
                if self._battleWin == 1 then
                    if self._callback ~= nil then 
                        self._callback()
                    end   

                    GuideUtils.checkTriggerByType("action", "7")

                    if self._callback2 ~= nil then
                        self._callback2()
                    end
                end

                -- 退出战斗
                self:close(true)
            end)
        end,
        function (errorCode)
           if errorCode == 3120 or errorCode == 3121 or errorCode == 2703 or errorCode == 2742 then
                self:lock()
                ScheduleMgr:delayCall(400, self, function( )
                    self:unlock()
                    self._viewMgr:popView()
                end)

            end
        end)
    end

    -- 给布阵传递怪兽数据
    local crusadeModel = self._modelMgr:getModel("CrusadeModel")
    crusadeModel:setEnemyTeamData(enemyD.teams)

    -- 给布阵传递英雄数据
    crusadeModel:setEnemyHeroData(enemyInfo.hero)

    -- enemyD.formation.score = self._crusadeData.score
    enemyD.formation.heroId = enemyInfo.hero.id

    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
    -- local enemyFormation = IntanceUtils:initFormationData(sysStage)
    local formationModel = self._modelMgr:getModel("FormationModel")
    if isSiege then
        enemyD.formation.siegeid = true
    end

    local enterFormationFunc = function(hireInfo,isShowHireTeam)
        self._viewMgr:showView("formation.NewFormationView", {
                formationType = formationModel.kFormationTypeCrusade,
                enemyFormationData = {[formationModel.kFormationTypeCrusade] = enemyD.formation},
                extend = {
                    hireTeams = hireInfo,
                    isShowHireTeam = isShowHireTeam,
                },
                callback = function(...)
                    local paramTable = {...}
                    dump(paramTable,"=======paramTable========")
                    if paramTable[2] == 0 then 
                        self._viewMgr:showTip(lang("CRUSADE_TIPS_6"))
                        return 
                    end
                    callBattle(paramTable)
                end,
                closeCallback = function()
                    if self.parentView ~= nil then
                        self.parentView:setMaskLayerOpacity(0)
                    end
                    if self.setVisible then
                        self:setVisible(false)
                    end
                    if self.close then
                        self:close(false)
                    end
                end
                }
            )
    end


    local hireInfo = {}
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    print("======guildId=====",guildId)
    if not guildId or tonumber(guildId) == 0 then             --是否加入联盟
        enterFormationFunc(hireInfo,1)
    else
        local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
        local limitLevel = tab:SystemOpen("Lansquenet")[1]
        if tonumber(userLevel) < tonumber(limitLevel) then
            enterFormationFunc(hireInfo,2)
            return
        end
        self._serverMgr:sendMsg("GuildServer", "getMercenaryList", {}, true, {}, function(result, errorCode)
            if errorCode ~= 0 then 
                print("======errorCode========"..errorCode)
                if errorCode == 2703 then
                    --更新联盟id
                    self._modelMgr:getModel("UserModel"):simulationGuildId()
                end
                self._viewMgr:unlock(51)
                return
            end
            hireInfo = self._modelMgr:getModel("GuildModel"):getAllEnemyId()
            enterFormationFunc(hireInfo,0)
        end)
    end



    

    -- local formationModel = self._modelMgr:getModel("FormationModel")
    -- enemyD.formation.type = formationModel.kFormationTypeCrusade
    -- self._viewMgr:showView("global.GlobalFormationView", {
    --     formationType = formationModel.kFormationTypeCrusade, 
    --     formationData = enemyD.formation,
    --     heroId = enemyInfo.hero.id,
    --     callback = function(inLeftData) 
    --         local teamNum, inTeamdieNum = formationModel:getFormationTeamCountWithFilter(formationModel.kFormationTypeCrusade)
    --         if teamNum == 0 then 
    --             self._viewMgr:showTip("将军，没有兵团不能出战")
    --             return 
    --         end
    --         if inTeamdieNum > 0 then 
    --             self._viewMgr:showDialog("global.GlobalSelectDialog",
    --                 {desc = "当前阵容有损，是否依然前往战斗",
    --                 button1 = "确定", 
    --                 button2 = "取消" ,
    --                 callback1 = function ()
    --                    callBattle()
    --                 end,
    --                 callback2 = function()
    --                 end})
    --             return
    --         end
    --         callBattle()
    --     end
    -- })
end

function CrusadeBattleNode:afterArenaBattle(data, inCallBack)
    if data.win then
        self._battleWin = 1
    end
    local allyDead = {}
    local enemyDead = {}
    if not data.isSurrender then
        for k,v in pairs(data.dieList[1]) do
            if data.dieList[3][k] then
                table.insert(allyDead, k)
            end
        end
        for k,v in pairs(data.dieList[2]) do
            if data.dieList[4][k] then
                table.insert(enemyDead, k)
            end
        end
    end

    if #enemyDead == 0 then 
        enemyDead = nil
    end
    if #allyDead == 0 then 
        allyDead = nil
    end


    if self._serverMgr ~= nil then
        local siegeBroken = 0
        local isQuit = 0     --是否是主动退出
        if not data.isSurrender then
            if data.exInfo and data.exInfo.siegeBroken then
                siegeBroken = 1
            end
        else
            isQuit = 1
        end

        local param = {id = self._curCrusadeId, token=self._token,
        args = json.encode({win= self._battleWin, skillList = data.skillList, time = data.time, 
            serverInfoEx = data.serverInfoEx,
            allyDead=allyDead, enemyDead=enemyDead, siegeBroken=siegeBroken,quit = isQuit})}
        self._serverMgr:sendMsg("CrusadeServer", "afterAttackCrusade", param, true, {}, function(result)
            if result == nil or result["d"] == nil then 
                return 
            end
            if result["extract"] then 
                dump(result["extract"]["hp"], "afterAttackCrusade", 10) 
            end
            -- 像战斗层传送数据
            if inCallBack ~= nil then
                result["mercenaryId"] = self._mercenaryId   --佣兵Id
                result["userId"] = self._userId
                inCallBack(result)
            end
        end)
    end
end

-- 显示VIP、活动加成
function CrusadeBattleNode:initAbilityEffect()
    local vipImg = self:getUI("bg.addPanel.vipImg")
    local vipAddNum = self:getUI("bg.addPanel.vipImg.addNum")
    local acImg = self:getUI("bg.addPanel.activityImg")
    local acAddNum = self:getUI("bg.addPanel.activityImg.addNum")
    vipImg:setVisible(false)
    acImg:setVisible(false)

    local vipAddValue = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).crusadeAdd
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local acAddValue = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_12)

    if tonumber(vipAddValue) > 0 then
        vipImg:setVisible(true)
        vipAddNum:setColor(cc.c3b(255, 252, 226))
        vipAddNum:enable2Color(1, cc.c4b(255, 232, 125, 255))
        vipAddNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        vipAddNum:setString("+" .. vipAddValue .. "%")

        if acAddValue <= 0 then
            vipImg:setPositionX(25)
        end
    end

    if acAddValue > 0 then
        acImg:setVisible(true)
        acAddNum:setColor(cc.c3b(255, 252, 226))
        acAddNum:enable2Color(1, cc.c4b(255, 232, 125, 255))
        acAddNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        acAddNum:setString("+" .. (acAddValue * 100) .. "%")

        if vipAddValue <= 0 then
            acImg:setPositionX(25)
        end
    end
end

return CrusadeBattleNode