--[[
    Filename:    AiRenMuWuView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-11-03 16:18:52
    Description: File description
--]]

local PVEID = 901
local PVETYPE = 4

local AiRenMuWuView = class("AiRenMuWuView", BaseView)

AiRenMuWuView.kGiftItemTag = 1000

function AiRenMuWuView:ctor()
    AiRenMuWuView.super.ctor(self)
    self._bossModel = self._modelMgr:getModel("BossModel")
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil
end

function AiRenMuWuView:getAsyncRes()
    return 
        {
            {"asset/ui/pveAiRen.plist", "asset/ui/pveAiRen.png"},
            {"asset/ui/pveIn.plist", "asset/ui/pveIn.png"},
        }
end

function AiRenMuWuView:getBgName()
    return "bg_airen.jpg"
end

function AiRenMuWuView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
        element:setFontName(UIUtils.ttfName)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])

    end
end


local airenOutlineColor = cc.c4b(90,44,0,255)
function AiRenMuWuView:onInit()
    self._tableData = tab:PveSetting(PVEID)

    self:registerClickEventByName("bg.btn_return", function()
        self:close()
        UIUtils:reloadLuaFile("pve.AiRenMuWuView")
    end)

    local mainNode = self:getUI("bg.mainNode")

    local titleLabel2 = mainNode:getChildByFullName("layer_recommand.label_title2")
    titleLabel2:setColor(cc.c3b(255, 224, 188))
    titleLabel2:enableOutline(airenOutlineColor, 2)
    titleLabel2:setFontName(UIUtils.ttfName_Title)

    local label_enemy_recommand = mainNode:getChildByFullName("layer_recommand.label_enemy_recommand")
    label_enemy_recommand:enableOutline(airenOutlineColor, 1)
--    label_enemy_recommand:setFontName(UIUtils.ttfName)
    label_enemy_recommand:setString(lang("TIPS_PVE_DWARF_01"))

    self._enemyLayer = {} 
    self._container = self
    for i = 1, 3 do
        self._enemyLayer[i] = mainNode:getChildByFullName("image_enemy_bg.layer_enemy_icon_" .. i)
        local iconGrid = self._enemyLayer[i]
        local teamId = self._tableData.NPC[i]
        local teamTableData = tab:Npc(teamId)
        local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamTableData.stage)
        local icon = IconUtils:createTeamIconById({
            teamData = {id = teamId, star = teamTableData.star}, 
            sysTeamData = teamTableData, 
            quality = backQuality[1], 
            quaAddition = backQuality[2], 
            tipType = 9, 
            eventStyle = 2})
        IconUtils:setTeamIconStarVisible(icon, false)
        IconUtils:setTeamIconStageVisible(icon, false)
        IconUtils:setTeamIconLevelVisible(icon, false)
        icon:setScale(72 / icon:getContentSize().width)
        icon:setPosition(0, 0)
        iconGrid:addChild(icon, 15)
    end

    local titleLabel1 = mainNode:getChildByFullName("image_enemy_bg.label_title1")
    titleLabel1:setColor(cc.c3b(255, 224, 188))
    titleLabel1:enableOutline(airenOutlineColor, 2)
    titleLabel1:setFontName(UIUtils.ttfName_Title)

    self._recommandEnemyLayer = {}
    for i = 1, 5 do
        self._recommandEnemyLayer[i] = mainNode:getChildByFullName("layer_recommand.layer_recommand_icon_" .. i)
        self._recommandEnemyLayer[i]:setVisible(false)
    end

    for i = 1, #self._tableData.recommend do
        local iconGrid = self._recommandEnemyLayer[i]
        local id = self._tableData.recommend[i]
        local icon = nil
        if string.len(id) == 5 then
            local sysHeroData = clone(tab:Hero(id))
            sysHeroData.hideFlag = true
            icon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
            icon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if icon:getChildByName("star" .. i) then
                    icon:getChildByName("star" .. i):setPositionY(icon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end
            icon:setSwallowTouches(false)
            icon:setPosition(37, 36)
            icon:setScale(75 / icon:getContentSize().width)
            registerClickEvent(icon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = id}, true)
            end)

        else
            local teamId = id
            local teamTableData = tab:Team(teamId)
            local backQuality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamTableData.stage)
--            icon = IconUtils:createTeamIconById({teamData = {id = teamId, star = teamTableData.star}, sysTeamData = teamTableData, quality = backQuality[1], quaAddition = backQuality[2], tipType = 9, eventStyle = 2})
            icon = IconUtils:createTeamIconById({teamData = {id = teamId, star = teamTableData.star}, sysTeamData = teamTableData, quality = nil, quaAddition = backQuality[2], tipType = 9, eventStyle = 2})
            IconUtils:setTeamIconStarVisible(icon, false)
            IconUtils:setTeamIconStageVisible(icon, false)
            IconUtils:setTeamIconLevelVisible(icon, false)            
            icon:setPosition(0, 0)
            icon:setScale(72 / icon:getContentSize().width)
        end        
        iconGrid:setVisible(true)
        iconGrid:addChild(icon, 15)
    end

    self._labelTimes = mainNode:getChildByFullName("label_times")
    self._labelTimes:setFontName(UIUtils.ttfName)
    self._labelTimes:setColor(cc.c3b(255, 252, 226))
    self._labelTimes:enable2Color(1, cc.c4b(255, 232, 125, 255))
    self._labelTimes:enableOutline(airenOutlineColor, 1)

    self._labelTimesValue = mainNode:getChildByFullName("label_times_value")
    self._labelTimesValue:setFontName(UIUtils.ttfName)
    self._labelTimesValue:setColor(UIUtils.colorTable.ccUIBaseColor2)
    self._labelTimesValue:enableOutline(airenOutlineColor, 1)


    self._btnBattle = mainNode:getChildByFullName("btn_battle")    
    -- self:formatButton(self._btnBattle)
    self:registerClickEvent(self._btnBattle, function()
        self:doBattle()
    end)

    -- 扫荡
    self._btnSweep = mainNode:getChildByFullName("btn_sweep")
    -- self:formatButton(self._btnSweep)

    self:registerClickEvent(self._btnSweep, function()
        self:onSweepBtnClicked()        
    end)

--    local mc = mcMgr:createViewMC("zhandouguangxiao_battlebtn", true)
--    mc:setPosition(btnBattle:getContentSize().width/2, btnBattle:getContentSize().height/2)
--    btnBattle:addChild(mc, 0)

--    local image_battle = self:getUI("bg.layer.image_bottom_bg.btn_battle.image_battle")
--    local amin2 = mcMgr:createViewMC("zhandousaoguang_battlebtn", true)
--    amin2:setPosition(image_battle:getContentSize().width/2, image_battle:getContentSize().height/2)
--    image_battle:addChild(amin2)

    local rankNode = self:getUI("bg.rankNode")
    -- 排行面板点击出排行榜  17.4.28
    self:registerClickEvent(rankNode, function()
        self._bossModel:reSetPVEScoreRank()
        self._serverMgr:sendMsg("BossServer", "getPVEScoreRank", {bossId = PVETYPE}, true, {}, function(success)
            self._viewMgr:showDialog("pve.DialogAiRenRank", {callback = function()
                self:updateRankListPanel()
                end}, true, true)
        end)        
    end)

    local myRankTxt = rankNode:getChildByFullName("rankBg.myRankTxt")
    -- myRankTxt:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    myRankTxt:enableOutline(airenOutlineColor, 1)
    self._rankNameNo1 = rankNode:getChildByFullName("rankBg.rankName1")
    self._rankNameNo2 = rankNode:getChildByFullName("rankBg.rankName2")
    self._rankNameNo3 = rankNode:getChildByFullName("rankBg.rankName3")
    self._rankAwardNo1 = rankNode:getChildByFullName("rankBg.awardNum1")
    self._rankAwardNo2 = rankNode:getChildByFullName("rankBg.awardNum2")
    self._rankAwardNo3 = rankNode:getChildByFullName("rankBg.awardNum3")
    self._rankNameNo1:enableOutline(airenOutlineColor,1)
    self._rankNameNo2:enableOutline(airenOutlineColor,1)
    self._rankNameNo3:enableOutline(airenOutlineColor,1)
    self._rankAwardNo1:enableOutline(airenOutlineColor,1)
    self._rankAwardNo2:enableOutline(airenOutlineColor,1)
    self._rankAwardNo3:enableOutline(airenOutlineColor,1)

    self._myRank = rankNode:getChildByFullName("rankBg.myRankLabel")
    self._myRankaward = rankNode:getChildByFullName("rankBg.awardNum4")

    local rankTxt = rankNode:getChildByFullName("rankBg.rankTxt")
    local awardTxt = rankNode:getChildByFullName("rankBg.awardTxt")
    rankTxt:setFontName(UIUtils.ttfName)
    rankTxt:setColor(cc.c3b(250,224,188))
    -- rankTxt:enable2Color(1, cc.c4b(255, 232, 125, 255))
    rankTxt:enableOutline(airenOutlineColor, 2)
    awardTxt:setFontName(UIUtils.ttfName)
    awardTxt:setColor(cc.c3b(250,224,188))
    -- awardTxt:enable2Color(1, cc.c4b(255, 232, 125, 255))
    awardTxt:enableOutline(airenOutlineColor, 2)

    UIUtils:addFuncBtnName(rankNode:getChildByFullName("btn_rule"), "规则",cc.p(rankNode:getChildByFullName("btn_rule"):getContentSize().width/2,0),true,18)
    UIUtils:addFuncBtnName(rankNode:getChildByFullName("btn_reward"), "奖励",cc.p(rankNode:getChildByFullName("btn_reward"):getContentSize().width/2,0),true,18)
    UIUtils:addFuncBtnName(rankNode:getChildByFullName("btn_rank"), "排行榜",cc.p(rankNode:getChildByFullName("btn_rank"):getContentSize().width/2,0),true,18)

    self:registerClickEvent(rankNode:getChildByFullName("btn_rule"), function()
        self._viewMgr:showDialog("pve.PveRuleView", {viewType = 1}, true, true)
    end)
    -- 添加奖励回调
    self:registerClickEvent(rankNode:getChildByFullName("btn_reward"), function()
        self._viewMgr:showDialog("pve.AiRenMuWuRewardView", {}, true, true)
    end)

    -- 排行按钮回调
    self:registerClickEvent(rankNode:getChildByFullName("btn_rank"), function()
        self._bossModel:reSetPVEScoreRank()

        self._serverMgr:sendMsg("BossServer", "getPVEScoreRank", {bossId = PVETYPE}, true, {}, function(success)
            self._viewMgr:showDialog("pve.DialogAiRenRank", {callback = function()
                self:updateRankListPanel()
                end}, true, true)
        end)

        -- self._serverMgr:sendMsg("BossServer", "getBossInfo", {}, true, {}, function(success)
        -- end) 
        
    end)

    --by wangyan
    local mapTip = self:getUI("bg.mainNode.popImg")
    mapTip:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.ScaleTo:create(0.7, 0.9),
            cc.ScaleTo:create(0.7, 1)
            )))

    self:listenReflash("BossModel", self.onModelReflash)
end

--判断推荐 wangyan
function AiRenMuWuView:checkRecomment()
    local bossData = self._bossModel:getDataByPveId(PVETYPE)
    local userlv = self._userModel:getPlayerLevel()
    local hLvl = bossData.atkLvl or 0
    local curTime = self._userModel:getCurServerTime()
    local hDays = bossData.atkTime or 0
    local disDays = (curTime - (bossData.atkTime or 0)) / 86400

    if userlv - hLvl >= 3 or disDays >= 5 then
        return true
    end

    return false
end

function AiRenMuWuView:onSweepBtnClicked()

    local sweepFunc = function()
        
        self._serverMgr:sendMsg("BossServer", "sweepBoss", {id = PVEID}, true, {}, function(success, result)
            if not success then
                self._viewMgr:showTip("扫荡失败。请策划配表")
                return
            end
            self._bossModel:setTimes(PVETYPE, result["d"]["boss"][tostring(PVETYPE)].times)
            self._bossModel:setHighScore(PVETYPE,result["d"]["boss"][tostring(PVETYPE)])
            local params = {gifts = result.reward,pveDes=lang("PVE_SAODANG_901")}
            
            DialogUtils.showGiftGet(params)
            self:updateUI()
        end)
    end

    local times = 0
    local bossData = self._bossModel:getDataByPveId(PVETYPE)
    if bossData then
        times = bossData.times or 0
    end
    local totalTimes = tab:Setting("G_PVE_" .. PVETYPE).value
    if times >= totalTimes then
        self._viewMgr:showTip(lang("TIPS_PVE_01"))
        return
    end

    local isAwakingTask = self._modelMgr:getModel("AwakingModel"):getAwakingTaskAirenCondition()
    -- isAwakingTask = true
    if isAwakingTask then 
        DialogUtils.showShowSelect({desc = lang("AWAKING_TIPS_4"), callback1=function( )
            sweepFunc()
        end})
        return
    end
    -- 二次确认
    if self:checkRecomment() == true then
        DialogUtils.showShowSelect({desc = lang("TIPS_PVE_DWARF_04"), callback1=function( )
            sweepFunc()
        end})
    else
        -- 发送获取奖励协议
        self._serverMgr:sendMsg("BossServer", "getSweepReward", {id = PVEID}, true, {}, function(result,success)
            if not success then
                self._viewMgr:showTip("扫荡失败。")
                return
            end
            -- dump(result,'result=>',5)
            local num = result[1].num or 0
            local curDesc = string.gsub(lang("TIPS_PVE_DWARF_03"), "{$gold}", ItemUtils.formatItemCount(num))
            DialogUtils.showShowSelect({desc = curDesc, addValue = "airen", callback1=function( )
                sweepFunc()
            end})
        end)
    end
end

function AiRenMuWuView:formatButton(btn)
    if not btn then return end
    btn:enableOutline(cc.c4b(36,65,121,255), 2)
    btn:setTitleFontSize(28)  
    btn:setTitleFontName(UIUtils.ttfName)
end

function AiRenMuWuView:updateUI()
    -- dump(self._bossModel:getData(), "self._bossModel:getData() ")
    local times = 0
    local rankList = {}
    local hValue = {}
    local bossData = self._bossModel:getDataByPveId(PVETYPE)
    if bossData then
        times = bossData.times or 0
        rankList = bossData.rankList
        hValue = bossData.hValue
    end
    local totalTimes = tab:Setting("G_PVE_" .. PVETYPE).value 
    local remainTimes = totalTimes - times
    self._labelTimesValue:setColor(UIUtils.colorTable.ccUIBaseColor2)
    if 0 == remainTimes then
        self._labelTimesValue:setColor(cc.c4b(255,65,65,255))
        self._labelTimesValue:enableOutline(airenOutlineColor, 1)
    else
        self._labelTimesValue:setColor(cc.c4b(39,247,58,255))
        self._labelTimesValue:enableOutline(airenOutlineColor, 1)
    end
    self._labelTimesValue:setString(string.format("%d/%d", remainTimes, totalTimes))

    self:updateRankListPanel(rankList or {})

    -- 更新扫荡和战斗按钮的显示及位置
    local sweepIsVisible = false
    if hValue and table.nums(hValue) > 0 then
        sweepIsVisible = true
    end 
    self._btnSweep:setVisible(sweepIsVisible)
    if not sweepIsVisible then
        self._btnBattle:setPositionX(247)
        -- self._labelTimes:setPositionX(182)
        -- self._labelTimesValue:setPositionX(277)
    else
        self._btnBattle:setPositionX(344)
        -- self._labelTimes:setPositionX(280)
        -- self._labelTimesValue:setPositionX(375)
    end

    local popImg = self:getUI("bg.mainNode.popImg")
    if self:checkRecomment() == true and sweepIsVisible and remainTimes > 0 then
        popImg:setVisible(true)
    else
        popImg:setVisible(false)
    end

    -- 更新奖励按钮红点
    self:addRewardNotice()
end

-- 更新左下角排行信息      
function AiRenMuWuView:updateRankListPanel(rankList)

    local bossData = self._bossModel:getDataByPveId(PVETYPE) or {}
    local rankData = rankList
    if not rankData then
        rankData = self._bossModel:getPVEScoreRank() or {} 
    end
    -- 按照rank排个序
    if rankData then
        table.sort(rankData, function(a, b)
            if not a.rank or not b.rank then
                return true
            else
                return a.rank < b.rank
            end
        end)
    end
    for i=1,3 do
        if rankData[i] then
            local rankAwardNum = self:getAwardNumByRank(i)
            self["_rankNameNo" .. i]:setString(rankData[i].name or "")
            self["_rankAwardNo" .. i]:setString(rankAwardNum)
        else
            self["_rankNameNo" .. i]:setString("暂无")
            self["_rankAwardNo" .. i]:setString("0")
        end
    end
    local myRank = bossData.rank or 0
    local myAwardNum
    if not myRank or 0 == myRank then
        myRank = "暂无排名"  
        myAwardNum = 0      
    end
    if not myAwardNum then
        myAwardNum = self:getAwardNumByRank(myRank)
    end
    self._myRank:setString(myRank)
    self._myRankaward:setString(myAwardNum)
end


function AiRenMuWuView:getAwardNumByRank( rank )
    if rank == 0 then return 0 end
    local dwarfWeeklyReward = tab["dwarfWeeklyReward"]
     for i,rankD in ipairs(dwarfWeeklyReward) do
        local pos = rankD.pos
        if rank >= pos[1] and rank <= pos[2] then
            local award = rankD.award 
            return award[1][3] or 0 
        end
     end 
end
function AiRenMuWuView:addRewardNotice()
    local rewardBtn = self:getUI("bg.rankNode.btn_reward")
    local dot = rewardBtn:getChildByName("noticeTip")
    if dot then 
        dot:removeFromParent()
    end
    local isNotice = false    
    local awardD = tab["dwarfDailyReward"] 
    local num = 0
    local bossData = self._bossModel:getDataByPveId(PVETYPE)
    if bossData then
        num = bossData.highScore or 0
    end
    local rewardList  = self._bossModel:getRawardList(PVETYPE)
    -- print("==========================",num)
    -- dump(awardD,"awardD")
    -- dump(rewardList,"rewardList")
    -- print("====================",table.nums(rewardList))
    for i,v in ipairs(awardD) do            
        if num >= v.condition and
            self._userModel:getPlayerLevel() >= v.effective[1] and
            self._userModel:getPlayerLevel() <= v.effective[2] and
            rewardList[tostring(v.id)] == nil
        then
            isNotice = true
            break
        end
    end

    -- print("======================",isNotice)
    if not isNotice then return end
    --如果有可领奖励 加红点提示
    local pos = cc.p(60,60)
    local dot = ccui.ImageView:create()
    dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
    dot:setPosition(pos)
    dot:setName("noticeTip")
    rewardBtn:addChild(dot,99)
end

function AiRenMuWuView:onShow()
    if self._bossModel:isNeedRequest() then
        self:doRequestData()
    else
        self:updateUI()
    end
end

function AiRenMuWuView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end
function AiRenMuWuView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function AiRenMuWuView:onDestroy( )
    self._viewMgr:disableScreenWidthBar()
    AiRenMuWuView.super.onDestroy(self)
end


function AiRenMuWuView:onTop()
    self._viewMgr:enableScreenWidthBar()
    if self._bossModel:isNeedRequest() then
        self:doRequestData()
    else
        self:updateUI()
    end
end

function AiRenMuWuView:onModelReflash()
    if self._bossModel:isNeedRequest() then
        self:doRequestData() 
    else
        self:updateUI()
    end
end

function AiRenMuWuView:doRequestData()
    self._serverMgr:sendMsg("BossServer", "getBossInfo", {}, true, {}, function(success)
        self:updateUI()
    end)
end

function AiRenMuWuView:doBattle()
    local times = 0
    local bossData = self._bossModel:getDataByPveId(PVETYPE)
    if bossData then
        times = bossData.times or 0
    end
    local totalTimes = tab:Setting("G_PVE_" .. PVETYPE).value
    if times >= totalTimes then
        self._viewMgr:showTip(lang("TIPS_PVE_01"))
        return
    end

    -- 战斗内需要展示最高伤害记录
    local maxDamage = self._bossModel:getMaxDamage(1)

    local battle = function(battleData)
        self._serverMgr:sendMsg("BossServer", "beforeAttackBoss", {id = PVEID, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(errorCode, result)
            if 0 ~= errorCode then 
                print("beforeAttackBoss error:", PVEID, errorCode)
                self._viewMgr:onLuaError("beforeAttackBoss error:" .. "id:" .. PVEID .. "error code:" .. errorCode)
                return 
            end
            self._token = result.token
            self._viewMgr:popView()
            local privilegeEffect = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_2) or 0
            local playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
            playerInfo.maxDamage = maxDamage
            BattleUtils.enterBattleView_AiRenMuWu(PVEID, playerInfo, privilegeEffect,
                function (info, callback)
                    if info.isSurrender then
                        callback(info)
                        return
                    end
                    print("========================info.exInfo.killCount1===",info.exInfo.killCount1,info.exInfo.killCount2)
                    local args = {win = info.win and 1 or 0, 
                                  killedMonsterNum = info.exInfo.killCount1 + info.exInfo.killCount2,
                                  killedMonsterInfo = {[tostring(info.exInfo.id1)] = info.exInfo.killCount1, [tostring(info.exInfo.id2)] = info.exInfo.killCount2},
                                  time = info.time,
                                  serverInfoEx = info.serverInfoEx,
                                  }
                    self._serverMgr:sendMsg("BossServer", "afterAttackBoss", {id = PVEID, token = self._token, args = json.encode(args)}, true, {}, function(errorCode, result)
                        if 0 ~= errorCode then 
                            print("afterAttackBoss error:", PVEID, errorCode)
                            self._viewMgr:onLuaError("afterAttackBoss error:" .. "id:" .. PVEID .. "error code:" .. errorCode)
                            return 
                        end

                        -- dump(result, "afterAttackBoss", 10)
                        --战斗前历史记录 wangyan
                        local curbossData = self._bossModel:getData()
                        if curbossData[tostring(PVETYPE)] and curbossData[tostring(PVETYPE)]["hValue"] then
                            info._preHValue = clone(curbossData[tostring(PVETYPE)]["hValue"])
                        else
                            info._preHValue = {}
                        end 
                        self._bossModel:setTimes(PVETYPE, result["d"]["boss"][tostring(PVETYPE)].times)
                        -- 更新排名和击杀矮人数量 
                        self._bossModel:setHighScore(PVETYPE,result["d"]["boss"][tostring(PVETYPE)])

                        -- 更新排名  
                        -- self._bossModel:setRanks(PVETYPE,result["d"]["boss"][tostring(PVETYPE)])
                        info.pveType = PVETYPE
                        callback(info, result.reward)
                    end)
                end,
                function(info) end, GRandom(99999999))
        end)
    end

    self._viewMgr:showView("formation.NewFormationView", {
        formationType = self._formationModel.kFormationTypeAiRenMuWu,
        extend = {pveData = self._tableData},
        callback = function(formationData)
            battle(formationData)
        end
    })
end

function AiRenMuWuView.dtor()
    PVEID = nil
    PVETYPE = nil
    airenOutlineColor = nil
end

function AiRenMuWuView:onIconPressOn(icon)
    print("onIconPressOn")
end

function AiRenMuWuView:onIconPressOff()
    print("onIconPressOff")
end

return AiRenMuWuView