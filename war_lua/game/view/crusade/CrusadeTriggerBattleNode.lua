--[[
    Filename:    CrusadeTriggerBattleNode.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-06-12 13:39:58
    Description: File description
--]]


local CrusadeTriggerBattleNode = class("CrusadeTriggerBattleNode", BasePopView)

function CrusadeTriggerBattleNode:ctor(data)
    self._atk = data.cruData.atk
    self._crusadeEnemy = data.cruData.def
    self._token = data.cruData.token
    self._cruType = data.cruType
    self._callback = data.callback
    CrusadeTriggerBattleNode.super.ctor(self)
end

function CrusadeTriggerBattleNode:onInit()
    -- self:registerClickEventByName("bg.closeBtn", function ()
 --        self:close()
 --    end)
    local labScore = self:getUI("bg.labScore")
    labScore:setFntFile(UIUtils.bmfName_zhandouli) 


    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(180)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(bgLayer)

    registerClickEvent(bgLayer, function()
        self:close()
    end)
end

function CrusadeTriggerBattleNode:reflashUI(data)
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
        local teamId = self._crusadeEnemy.formation["team" .. i]
        local teamData = self._crusadeEnemy.teams[tostring(teamId)]
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
        local teamData = self._crusadeEnemy.teams[tostring(k)]
        if k ~= nil and tonumber(k) > 0 and teamData ~= nil then
            j = j + 1
            local backQuality = teamModel:getTeamQualityByStage(teamData.stage)
            -- data.teams[teamId]
            local sysTeam = tab:Team(tonumber(k))
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
    labScore:setString("a" .. self._crusadeEnemy.formation.score)
    labScore:setFntFile(UIUtils.bmfName_zhandouli) 

    self:getUI("bg.Label_36"):enableOutline(cc.c4b(60,30,10,255), 2)
    local labName = self:getUI("bg.labName")
    labName:setString(self._crusadeEnemy.name)
    labName:setColor(cc.c3b(255, 255, 255))
    labName:enableOutline(cc.c4b(60, 34, 10, 255), 2)

    if self._crusadeEnemy.hero.skin then
        local sysSkin = tab:HeroSkin(self._crusadeEnemy.hero.skin)
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
        local sysHero = tab:Hero(self._crusadeEnemy.formation.heroId)
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

    registerClickEvent(battleBtn,function()
        print("beforeAttackCrusade")
        -- dump(userCruasade,"test",10)
        self:beforeAttackCrusade(self._crusadeEnemy)
    end)
end

function CrusadeTriggerBattleNode:beforeAttackCrusade(enemyD)
    self._battleWin = 0

    -- 初始化敌方数据
    local enemyInfo = self:initBattleData(enemyD)
    -- if tab.crusadeMain[self._curCrusadeId]["siegeid"] then
    --     BattleUtils.crusadeSiegeUpdateFormation(enemyInfo, enemyD)
    -- end
    local function callBattle(inLeftData)  
        -- inLeftData = BattleUtils.jsonData2lua_battleData(self._atk)
        self._serverMgr:sendMsg("FormationServer", "getSelfBattleInfo", {fid = 6}, true, {}, function(_result)
            local serAtkData = clone(_result["atk"])   --by wangyan getSelfBattleInfo返回的数据里面没有远征buff
            serAtkData["buff"] = self._atk["buff"]
            inLeftData = BattleUtils.jsonData2lua_battleData(serAtkData)
            -- 我方远征buffer
            -- local buff = {}
            -- local crusadeModel = self._modelMgr:getModel("CrusadeModel")
            -- if crusadeModel:getData().buff ~= nil then 
            --     for k,v in pairs(crusadeModel:getData().buff) do
            --         buff[tonumber(k)] = v
            --     end
            -- end

            -- if crusadeModel:getResetData().buff ~= nil then --特殊buff wangyan
            --     for k,v in pairs(crusadeModel:getResetData().buff) do
            --         local isHas = false
            --         for p,q in pairs(buff) do
            --             if p == k then
            --                 isHas = true
            --                 q = v + q
            --             end
            --         end
            --         if not isHas then
            --             buff[tonumber(k)] = v
            --         end
            --     end
            -- end
            
            -- inLeftData.hero.buff = buff
            self._viewMgr:popView()
            BattleUtils.enterBattleView_Crusade_Trigger(inLeftData, enemyInfo, 
            function (info, callback)
                -- 战斗结束
                -- callback(info)
                self:afterArenaBattle(info, callback)
            end,
            function (info)
                print("退出战斗")
                if self._battleWin == 1 and self._callback ~= nil then 
                    self._callback()
                end   

                if self._battleWin == 1 then
                    GuideUtils.checkTriggerByType("action", "7")
                end
                -- 退出战斗
                self:close(true)
            end)
        end)
    end

    -- 给布阵传递怪兽数据
    local crusadeModel = self._modelMgr:getModel("CrusadeModel")
    crusadeModel:setEnemyTeamData(enemyD.teams)

    -- 给布阵传递英雄数据
    local crusadeModel = self._modelMgr:getModel("CrusadeModel")
    crusadeModel:setEnemyHeroData(enemyInfo.hero)

    -- enemyD.formation.score = self._crusadeData.score
    enemyD.formation.heroId = enemyInfo.hero.id

    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
    -- local enemyFormation = IntanceUtils:initFormationData(sysStage)
    local formationModel = self._modelMgr:getModel("FormationModel")
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeCrusade,
        enemyFormationData = {[formationModel.kFormationTypeCrusade] = enemyD.formation},
        callback = function(inLeftData, teamNum, inTeamdieNum)
            if teamNum == 0 then 
                self._viewMgr:showTip(lang("CRUSADE_TIPS_6"))
                return 
            end
            callBattle(inLeftData)
        end,
        closeCallback = function()
            self.parentView:setMaskLayerOpacity(0)
            self:setVisible(false)
            self:close(false)
        end
        }
    )
end


function CrusadeTriggerBattleNode:initBattleData(enemyD)
    local formationModel = self._modelMgr:getModel("FormationModel")
    local currentHid = formationModel:getFormationDataByType(formationModel.kFormationTypeCrusade).heroId
    --self._modelMgr:getModel("UserModel"):getData().currentHid
    local heroData = self._modelMgr:getModel("HeroModel"):getData()[tostring(currentHid)]

    --  合成敌人数据
    -- dump(enemyD, "aaa")
    local enemyInfo = BattleUtils.jsonData2lua_battleData(enemyD)
    return enemyInfo
end

function CrusadeTriggerBattleNode:afterArenaBattle(data, inCallBack)
    if data.win then
        self._battleWin = 1
    end

    local param = {type = self._cruType, token = self._token, win = self._battleWin}
    self._serverMgr:sendMsg("CrusadeServer", "getCrusadeTriggerReward", param, true, {}, function(result)
        -- 像战斗层传送数据
        if inCallBack ~= nil then
            inCallBack(result)
        end
    end)
end

return CrusadeTriggerBattleNode