--[[
    Filename:    IntanceStageInfoNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-08-24 15:44:20
    Description: File description
--]]

local IntanceStageInfoNode = class("IntanceStageInfoNode", BaseLayer)

function IntanceStageInfoNode:ctor(data)
    IntanceStageInfoNode.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceStageInfoNode")
        elseif eventType == "enter" then 
        end
    end)
end

function IntanceStageInfoNode:onInit()
    self:setFullScreen()
    self._bgLayer = ccui.Layout:create()
    self._bgLayer:setBackGroundColorOpacity(0)
    self._bgLayer:setBackGroundColorType(1)
    self._bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    self._bgLayer:setTouchEnabled(true)
    self._bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(self._bgLayer)
    -- self._bgLayer:setTouchEnabled(false)

    self:registerClickEventByName("bg", function ()
       --注册用来屏蔽底层点击事件
    end)

    registerClickEvent(self._bgLayer, function()
        self:hideView(true)
    end)

    self:registerClickEventByName("bg.closeBtn", function ()
        self:hideView(true)
    end)
    local battleBtn = self:getUI("bg.battleBtn")


    local amin1 = mcMgr:createViewMC("zhandouguangxiao_battlebtn", true)  --火
    amin1:setPosition(battleBtn:getContentSize().width/2, battleBtn:getContentSize().height/2)
    battleBtn:addChild(amin1)

    if battleBtn.positionX == nil then 
        battleBtn.positionX = battleBtn:getPositionX()
    end
    local Image_29 = self:getUI("bg.battleBtn.Image_29")     
    local amin2 = mcMgr:createViewMC("zhandousaoguang_battlebtn", true)   --文字放缩
    amin2:setPosition(Image_29:getContentSize().width/2 , Image_29:getContentSize().height/2)
    Image_29:addChild(amin2)
    

    self:registerClickEvent(battleBtn, function ()
        self:clickEnterBtn()
    end)
    self:registerClickEventByName("bg.sweepMBtn", function ()
        -- audioMgr:playSound("Sweep")
        self:wideEnterMBtn()
  
    end)
    self:registerClickEventByName("bg.sweepBtn", function ()
        -- audioMgr:playSound("Sweep")
        self:wideEnterBtn(1)
    end)
  
    local Image_25 = self:getUI("bg.Image_91.Image_25")


    local tili = self:getUI("bg.Image_26_0")
    local scaleNum1 = math.floor((26/tili:getContentSize().width)*100)
    tili:setScale(scaleNum1/100)

    local tili1 = self:getUI("bg.Image_26_0_0")
    local scaleNum1 = math.floor((26/tili1:getContentSize().width)*100)
    tili1:setScale(scaleNum1/100)

    self:registerClickEventByName("bg.recordPanel.recordBtn", function ()
        self._battleResult = {}
        self:showReport(self._curStageBaseId, 2, function()
            self:showReport(self._curStageBaseId, 1, function()
                self._viewMgr:showDialog("intance.IntanceRecordView", {
                  stageId = self._curStageBaseId,
                  battleResult = self._battleResult,
                  callback = function()
                    self.parentView:loadBigMap()
                    end
                  })
            end)
        end) 
    end)

end



function IntanceStageInfoNode:reflashUI(data)
    IntanceStageInfoNode.super.reflashUI(self)
    self._curStageBaseId = data.stageBaseId

    local intanceModel = self._modelMgr:getModel("IntanceModel")

    local isFirst = false
    local curStageInfo = intanceModel:getStageInfo(self._curStageBaseId)
    if curStageInfo.star == 0 then
        isFirst = true 
        self._finishWarType = IntanceConst.FINISH_WAR_TYPE.FIRST_WAR
    elseif curStageInfo.star == 3 then
        self._finishWarType = IntanceConst.FINISH_WAR_TYPE.FULL_STAR
    else
        self._finishWarType = IntanceConst.FINISH_WAR_TYPE.OTHER
    end
    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))

    local recordPanel = self:getUI("bg.recordPanel")
    if sysStage.record == 1 then
        recordPanel:setVisible(true)
    else
        recordPanel:setVisible(false)
    end

    local labTipSweep = self:getUI("bg.labTipSweep")
    labTipSweep:setFontName(UIUtils.ttfName)
    labTipSweep:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    local titleLab = self:getUI("bg.titleBg.title")
    titleLab:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)    
    titleLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- UIUtils:setTitleFormat(titleLab, 1)
    titleLab:setString(lang(sysStage.title))
    -- titleLab:setFontSize(22)

    local descLab = self:getUI("bg.descLab")
    descLab:ignoreContentAdaptWithSize(true)
    descLab:setString(lang(sysStage.describe))
    descLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)    
    descLab:getVirtualRenderer():setLineHeight(30)
    -- 更新奖励
    IntanceUtils:updateDropNode(self:getUI("bg.dropNode"), sysStage, isFirst, 10, 0.7)
     
    self:updateAboutStage()
end

--[[
--! @function updateAboutStage
--! @desc  更新关卡
--! @param
--! @return 
--]]

function IntanceStageInfoNode:updateAboutStage()
    -- 更新当前界面
    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local mainsData = intanceModel:getData().mainsData
    local stageNum = 0
    local stage = intanceModel:getStageInfo(self._curStageBaseId)

    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
    
    local powerLab = self:getUI("bg.powerLab")
    powerLab:setString(sysStage.costPhysical)
    powerLab:setFontName(UIUtils.ttfName)
    powerLab:setColor(UIUtils.colorTable.ccUIBaseColor2) 
    powerLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) 
    
    local userModel = self._modelMgr:getModel("UserModel")
    local residuePowerLab = self:getUI("bg.residuePowerLab")
    residuePowerLab:setString(userModel:getData().physcal)
    residuePowerLab:setFontName(UIUtils.ttfName)
    residuePowerLab:setColor(UIUtils.colorTable.ccUIBaseColor2)  
    residuePowerLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local tmpLab01 = self:getUI("bg.tmpLab01")
    tmpLab01:setPosition(residuePowerLab:getPositionX() + residuePowerLab:getContentSize().width, tmpLab01:getPositionY())

    local sweepMBtn = self:getUI("bg.sweepMBtn")
    sweepMBtn:setTitleText("扫荡10次")

    local sweepBtn = self:getUI("bg.sweepBtn")


    local battleBtn = self:getUI("bg.battleBtn")
    local Image_29 = self:getUI("bg.battleBtn.Image_29")

    for i=1, 3 do
        local star = self:getUI("bg.starBg.star" .. i)
        if i <= stage.star then 
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end

    local labTipSweep = self:getUI("bg.labTipSweep")
    

    -- local bg = self:getUI("bg")
    -- local starBg = self:getUI("bg.starBg")
    if stage.star <= 0 then 
        labTipSweep:setVisible(true)
        sweepMBtn:setVisible(false)
        sweepBtn:setVisible(false)
        -- battleBtn:setPosition(bg:getContentSize().width * 0.5, sweepMBtn:getPositionY() - 20)
        -- labTipSweep:setPosition(battleBtn:getPositionX(), battleBtn:getPositionY() + battleBtn:getContentSize().height * 0.5 + 20)
        -- starBg:setPosition(bg:getContentSize().width* 0.5, )
    else
        labTipSweep:setVisible(false)
        sweepMBtn:setVisible(true)
        sweepBtn:setVisible(true)
        -- battleBtn:setPosition(battleBtn.positionX, sweepMBtn:getPositionY())
        -- labTipSweep:setPosition(sweepBtn:getPositionX() - (sweepBtn:getContentSize().width * 0.5) + (labTipSweep:getContentSize().width * 0.5) + 8, sweepBtn:getPositionY() + sweepBtn:getContentSize().height * 0.5 + 20)
    end
end



--[[
--! @function wideEnterMBtn
--! @desc 多次扫荡
--]]
function IntanceStageInfoNode:wideEnterMBtn()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
    local canDoTime = math.floor((userData.physcal / sysStage.costPhysical))
    local time = 10
    if canDoTime >= 1 and  canDoTime < time then 
        time = canDoTime
    end
    self:wideEnterBtn(time)
end


--[[
--! @function wideEnterBtn
--! @desc 扫荡
--! @param inTime int 次数
--]]
function IntanceStageInfoNode:wideEnterBtn(inTime)

    local userModel = self._modelMgr:getModel("UserModel")
    if self._oldUserLevel == nil then 
        self._oldUserLevel = userModel:getData().lvl
    end
    local limitLevel = tonumber(tab.systemOpen["Sweep"][1])
    if self._oldUserLevel < limitLevel then 
        local str = lang("SAODANG_BEGIN")
        local result, count = string.gsub(str, "$num", tab:Setting("G_SAODANG_BEGIN_LEVEL").value)
        if count > 0  then 
            str = result
        end
        self._viewMgr:showTip(str)
        return 
    end
    
    if inTime > 1 then 
        local vipInfo = self._modelMgr:getModel("VipModel"):getData()
        local sysVip = tab:Vip(vipInfo.level)
        if sysVip.sweepTimes == 0 then 
            local str = lang("SAODANGS_BEGIN")
            local result, count = string.gsub(str, "$num", tab:Setting("G_SAODANGS_BEGIN_LEVEL").value)
            if count > 0  then 
                str = result
            end
            self._viewMgr:showTip(str)
            return
        end
    end
    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local curStageInfo = intanceModel:getStageInfo(self._curStageBaseId)
    if curStageInfo.star < 1 then 
        self._viewMgr:showTip("三星通关可以扫荡")
        return
    end
    if self:checkBattle(inTime, true) == false then 
        return
    end

    local oldUserPrePhysic = userModel:getData().physcal
    local oldPlvl = userModel:getData().plvl or 0
    local oldPTalentPoint = userModel:getData().pTalentPoint or 0

    local param = {id = self._curStageBaseId,num = inTime}
    self._serverMgr:sendMsg("StageServer", "sweepStage", param, true, {}, function (result)
        if result == nil or result["rewards"] == nil then 
            return 
        end
        -- 更新当前界面
        self:updateAboutStage()
        
        local mainStage = tab:MainStage(tonumber(self._curStageBaseId))

        local tmpRewards = IntanceUtils:handleWideReward(result["rewards"], result["tRewards"])
 
        local newUserData = userModel:getData()
        local newPlvl = newUserData.plvl or 0
        local isAutoClose = false
        if self._oldUserLevel < newUserData.lvl then 
            isAutoClose =  true
        elseif oldPlvl < newPlvl then
            isAutoClose = true
        end
        local function userUpdate()
            self._intanceWideRewardView = nil
            if self._oldUserLevel == nil then 
                return
            end
            if self._oldUserLevel < newUserData.lvl then 
                local tempOldUserLevel = self._oldUserLevel
                self._viewMgr:checkLevelUpReturnMain(newUserData.lvl)
                oldUserPrePhysic = oldUserPrePhysic - (mainStage.costPhysical * inTime)
                ViewManager:getInstance():showDialog("global.DialogUserLevelUp",{preLevel = tempOldUserLevel,level = newUserData.lvl,prePhysic = oldUserPrePhysic,physic = newUserData.physcal}, nil, nil, nil, false)
                self._oldUserLevel = nil
            elseif oldPlvl < newPlvl then
                ViewManager:getInstance():showDialog("global.DialogUserParagonLevelUp", {oldPlvl = oldPlvl, plvl = newPlvl, pTalentPoint = (newUserData.pTalentPoint - oldPTalentPoint)}, true, nil, nil, false)
            end
        end

        local data = {type = 1, reward = tmpRewards, callback = userUpdate, autoClose = isAutoClose, againCallback = function()
                if inTime > 1 then 
                    self:wideEnterMBtn()
                else
                    self:wideEnterBtn(inTime)
                end
             end }
        if self._intanceWideRewardView ~= nil then 
            self._intanceWideRewardView:reflashUI(data)
        else
            self._intanceWideRewardView = self._viewMgr:showDialog("intance.IntanceWideRewardView",data,true)
        end
    end)
end




--[[
--! @function checkBattle
--! @desc 检查战斗条件
--! @param inTime int 战斗次数
--! @param isCheckItem bool 是否检查扫荡卷
--! @return bool
--]]
function IntanceStageInfoNode:checkBattle(inTime,isCheckItem)
    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
    
    local userData = self._modelMgr:getModel("UserModel"):getData()
    
    if userData.physcal - (sysStage.costPhysical * inTime) < 0 then 
        DialogUtils.showBuyRes( {goalType = "physcal", callback = function(success)
            if success then 
                -- local userModel = self._modelMgr:getModel("UserModel")
                -- local residuePowerLab = self:getUI("bg.residuePowerLab")
                -- residuePowerLab:setString(userModel:getData().physcal)
                -- local tmpLab01 = self:getUI("bg.tmpLab01")
                -- tmpLab01:setPosition(residuePowerLab:getPositionX() + residuePowerLab:getContentSize().width, tmpLab01:getPositionY())
            end
        end})

        return false
    end

    return true
end

--[[
--! @function clickEnterBtn
--! @desc 进入副本按钮
--! @return 
--]]
function IntanceStageInfoNode:clickEnterBtn()
    if self:checkBattle(1) == false then
        return
    end
    self:enterBattle()
end

function IntanceStageInfoNode:enterBattle()
    print("enterBattle=================================================")
    self._userUpdateCallBack = nil
    self._userUpdateReturnMain = nil
    local formationModel = self._modelMgr:getModel("FormationModel")
    if self._curStageBaseId <= IntanceConst.FIRST_SECTION_LAST_STAGE_ID
        and self._finishWarType == IntanceConst.FINISH_WAR_TYPE.FIRST_WAR then 
        self:formationCallBack(formationModel:initBattleData(formationModel.kFormationTypeCommon)[1], true)
    else
        local sysStage = tab:MainStage(tonumber(self._curStageBaseId))
        local enemyFormation = IntanceUtils:initFormationData(sysStage)

        local intanceModel = self._modelMgr:getModel("IntanceModel")
        local acSectionId = intanceModel:getData().mainsData.acSectionId 

        local sectionId = tonumber(string.sub(self._curStageBaseId, 1 , 5))
        local sysSectionMap = tab:MainSectionMap(sectionId)
        local sysSection = tab:MainSection(sectionId)

        local stageInfo = intanceModel:getStageInfo(sysStage.id)

        local lastStageId = sysSection.includeStage[#sysSection.includeStage]
        local lastStageInfo = intanceModel:getStageInfo(lastStageId)
        
        local userStoryHeroId = SystemUtils.loadAccountLocalData(IntanceConst.USE_STORY_HERO_SECTION)
        
        -- 章节英雄
        local heroes = nil
        local fixedHero = nil
        local defaultHero  = nil
        self._isMustUseHero = false
        -- local finishSectionId = tab:Setting("G_FINISH_SECTION_STORY").value
        -- local finishSysSection = tab:MainSection(finishSectionId)

        -- local sectionLastStageId = finishSysSection.includeStage[#finishSysSection.includeStage]

        if sysSectionMap ~= nil and sysSectionMap.hero ~= nil and acSectionId == sectionId and lastStageInfo.star == 0 then  
            -- 必上英雄的判断
            if sysStage.storyHero ~= nil and stageInfo.star == 0 then 
                fixedHero = sysSectionMap.hero
               self._isMustUseHero = true
            end
            heroes = {[1] = sysSectionMap.hero}
            if userStoryHeroId == sysSectionMap.hero then 
                defaultHero = sysSectionMap.hero
            end
            
        end
        local function userStoryHero(inIsNpcHero)
            if self._isMustUseHero == true then return end
            local storyHero = 0
            if inIsNpcHero  == true then 
                storyHero = sysSectionMap.hero
            end
            SystemUtils.saveAccountLocalData(IntanceConst.USE_STORY_HERO_SECTION, storyHero)
        end
        BulletScreensUtils.clear()
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = formationModel.kFormationTypeCommon,
            enemyFormationData = {[formationModel.kFormationTypeCommon] = enemyFormation},
            extend = {
                physical = sysStage.costPhysical,
                intanceId = self._curStageBaseId,
                heroes = heroes,
                fixedHero = fixedHero,
                defaultHero = defaultHero,
                talkId = sysStage.storyHeroTalk,
                hideWeapon = true
            },
            callback = 
                function(inLeftData, _, _, _, inIsNpcHero)
                    userStoryHero(inIsNpcHero)
                    self:formationCallBack(inLeftData, false, inIsNpcHero)
                end,
            closeCallback = 
                function(inIsNpcHero)
                    userStoryHero(inIsNpcHero)
                    local intanceModel = self._modelMgr:getModel("IntanceModel")
                    intanceModel:noticeView("showIntanceBullet")
                end}
            )
    end
end

--[[
--! @function formationCallBack
--! @desc 布阵callback
--! @param inLeftData table 左侧阵容
--]]
function IntanceStageInfoNode:formationCallBack(inLeftData, isQuick, inIsNpcHero)
    self._formationData = inLeftData
    self._formationData.hero.npcHero = inIsNpcHero

    local param = {id = self._curStageBaseId, serverInfoEx = BattleUtils.getBeforeSIE()}
    if self._formationData.hero.npcHero == true then 
        param.npcHero = "1"
    end
    self._serverMgr:sendMsg("StageServer", "atkBeforeStage", param, true, {}, function (result)
        if result == nil or result["d"] == nil or result["d"]["physcal"] == nil then 
            self._viewMgr:showTip("请求战斗失败")
            return 
        end
        self._battleToken = result["token"]
        local userModel = self._modelMgr:getModel("UserModel")
        local oldSkillOpen = clone(userModel:getSkillOpen())
        if not result["d"].dontUpdateUser then
            userModel:updateUserData(result["d"])
        end

        local newSkillOpen = userModel:getSkillOpen()
        for i = 1, 5 do
            if newSkillOpen[tostring(i)] ~= oldSkillOpen[tostring(i)] then
                BattleUtils.unLockSkillIndex = i
                break
            end
        end

        self:hideView(false)
        --进入战斗
        if not isQuick then 
            self._viewMgr:popView(nil, true)
        end
        local lose = false

        local lose1 = false
        local playerInfo
        if result["atk"] then
            playerInfo = BattleUtils.jsonData2lua_battleData(result["atk"])
        else
            playerInfo = self._formationData
        end

        BattleUtils.enterBattleView_Fuben(playerInfo, tonumber(self._curStageBaseId), false, function (info, callBack, error)
            if error == true then 
                if self._battleFinishCallback ~= nil then
                    self._battleFinishCallback(self._curStageBaseId, 2, self._finishWarType)
                end                
                return
            end
            self:battleCallBack(info, callBack)
            -- dump(info)
            lose = (info.win == false and info.isSurrender == false)
            -- lose1 = (info.win == false or info.isSurrender == true)
        end,
        function (_type)
            local winType = self._battleWin
            -- 如果是通关副本，则动画到下一个关卡
            if self._battleWin == 1 then 
                winType = 2
            end
            if not BattleUtils.loseReturnMainind then
                if self._battleFinishCallback ~= nil then
                    self._battleFinishCallback(self._curStageBaseId, winType, self._finishWarType)
                end
            end

            if self._userUpdateCallBack ~= nil then 
                if self._userUpdateReturnMain then
                    self._userUpdateCallBack()
                else
                    if winType == 2 then
                        GuideUtils.checkTriggerByType("intanceWin", self._curStageBaseId, function()
                            if self._userUpdateCallBack then
                                self._userUpdateCallBack()
                            end
                        end)
                    elseif lose and _type ~= 1 then
                        GuideUtils.checkTriggerByType("intanceLose", self._curStageBaseId, function ()
                            if self._userUpdateCallBack then
                                self._userUpdateCallBack()
                            end
                        end)   
                    else
                        self._userUpdateCallBack()
                    end
                end
            else
                if winType == 2 then
                    GuideUtils.checkTriggerByType("intanceWin", self._curStageBaseId)
                elseif lose and _type ~= 1 then
                    GuideUtils.checkTriggerByType("intanceLose", self._curStageBaseId) 
                end
            end
            -- if lose1 then
            --     self._refreshHero()  --英雄形象刷新
            -- end
        end)
        -- self:battleCallBack({win = true}, nil)
    end)
end

--[[
--! @function battleCallBack
--! @desc 战斗结束callback
--! @param inResult table 战斗相关
--! @param inCallBack function 是否检查扫荡卷
--! @return bool
--]]
function IntanceStageInfoNode:battleCallBack(inResult, inCallBack)
    -- 请求参数
    local tempTeams = {}
    for k,v in pairs(self._formationData.team) do
        table.insert(tempTeams,v.id)
    end
    -- 缓存数据对比是否升级
    local teamModel = self._modelMgr:getModel("TeamModel")
    local tempCacheTeams = {}
    for k,v in pairs(self._formationData.team) do
        local team, index = teamModel:getTeamAndIndexById(v.id)
        if index > 0 then 
            table.insert(tempCacheTeams,table.deepCopy(team))
        end
    end
    self._battleWin = 0
    if inResult.win ~= nil 
        and inResult.win == true then 
       self._battleWin = 1
    end
    local battleId = inResult.battleId
    local zzid = GameStatic.zzid1
    local param = { id = battleId, 
                    args = json.encode({win = self._battleWin, 
                                        time = inResult.time,
                                        zzid = zzid,
                                        dieCount = inResult.dieCount, 
                                        serverInfoEx = inResult.serverInfoEx,
                                        skillList = inResult.skillList}),
                    token = self._battleToken}
    if self._formationData.hero.npcHero == true then 
        param.npcHero = "1"
    end

    if self._battleWin == 0 then 
        self._serverMgr:sendMsg("StageServer", "atkStageLose", param, true, {}, function (result)
            if inCallBack ~= nil then
                inCallBack({})
            end
        end)
        return
    end


    local userModel = self._modelMgr:getModel("UserModel")
    local oldUserLevel = userModel:getData().lvl 
    local oldUserPrePhysic = userModel:getData().physcal
    local oldPlvl = userModel:getData().plvl or 0
    local oldPTalentPoint = userModel:getData().pTalentPoint or 0
    GuideUtils.saveIndex(GuideUtils.getNextBeginningIndex())
    self._serverMgr:sendMsg("StageServer", "atkAfterStage", param, true, {}, function (result)
        if result == nil then 
            if battleId <= 7100202 then
                local stage = self._modelMgr:getModel("IntanceModel"):getStageInfo(battleId)
                if stage.star == 0 then 
                    -- 强制引导中, 如果这个请求出问题, 就中断引导
                    self._viewMgr:breakOffGuide()
                    self._battleWin = 0
                    if inCallBack ~= nil then
                        inCallBack({failed = true, __code = 9, extract = result["extract"]})
                    end
                end
            else
                self._battleWin = 0
                if inCallBack ~= nil then
                    inCallBack({failed = true, __code = 10, extract = result["extract"]})
                end
            end
            return 
        end
        if result["cheat"] == 1 then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 11, extract = result["extract"]})
            end
            return
        end
        if result["d"] == nil then 
            if battleId <= 7100202 then
                local stage = self._modelMgr:getModel("IntanceModel"):getStageInfo(battleId)
                if stage.star == 0 then 
                    -- 强制引导中, 如果这个请求出问题, 就中断引导
                    self._viewMgr:breakOffGuide()
                    self._battleWin = 0
                    if inCallBack ~= nil then
                        inCallBack({failed = true, __code = 12})
                    end
                end
            else
                self._battleWin = 0
                if inCallBack ~= nil then
                    inCallBack({failed = true, __code = 13})
                end
            end
            return 
        end
        if result["extract"] then dump(result["extract"]["hp"]) end
        if battleId <= 7100202 then
            -- 打点
            local has = SystemUtils.loadAccountLocalData("guideFuben_"..battleId)
            if has == nil or has == "" then
                SystemUtils.saveAccountLocalData("guideFuben_"..battleId, 1)
                ApiUtils.playcrab_monitor_action("fuben"..battleId)
            end    
        end

        local resultData = table.deepCopy(result)

        -- 缓存数据对比是否升级
        local teamModel = self._modelMgr:getModel("TeamModel")
        if resultData.d.teams ~= nil then
            for k,v in pairs(tempCacheTeams) do
                local team, index = teamModel:getTeamAndIndexById(v.teamId)
                if index ~= nil and 
                    resultData.d.teams[""..v.teamId] ~= nil then
                    resultData.d.teams[""..v.teamId].oldLevel = v.level
                    resultData.d.teams[""..v.teamId].totalExp = tab:TeamLevel(team.level).exp
                end
            end
        end

        -- 升级提示
        local newUserData = userModel:getData()
        local newPlvl = newUserData.plvl or 0
        local mainStage = tab:MainStage(tonumber(battleId))
        
        if oldUserLevel < newUserData.lvl then 

            local sysUserLevel = tab.userLevel[newUserData.lvl]
            if sysUserLevel.gotoview and sysUserLevel.gotoview == 1 then
                BattleUtils.loseReturnMainind = true
                self._userUpdateReturnMain = true
            end 
            self._userUpdateCallBack = function()
                self._viewMgr:checkLevelUpReturnMain(newUserData.lvl)
                BattleUtils.loseReturnMainind = false
                oldUserPrePhysic = oldUserPrePhysic - mainStage.costPhysical + 1
                ViewManager:getInstance():showDialog("global.DialogUserLevelUp", {preLevel = oldUserLevel,level = newUserData.lvl, prePhysic = oldUserPrePhysic, physic = newUserData.physcal}, nil, nil, nil, false)
            end

        elseif oldPlvl < newPlvl then
            self._userUpdateCallBack = function (  )
                ViewManager:getInstance():showDialog("global.DialogUserParagonLevelUp", {oldPlvl = oldPlvl, plvl = newPlvl, pTalentPoint = (newUserData.pTalentPoint - oldPTalentPoint)}, true, nil, nil, false)
            end
        else
            self._userUpdateCallBack = nil
        end
        resultData.star = resultData.rs.star
        if self._finishWarType == IntanceConst.FINISH_WAR_TYPE.FIRST_WAR then 
            resultData.firstReward = mainStage["firstReward"]
        end
        -- 像战斗层传送数据
        if inCallBack ~= nil then
            inCallBack(resultData)
        end
    end, function (error)
        if error then
            self._battleWin = 0
            if inCallBack ~= nil then
                inCallBack({failed = true, __code = 15, __error = error})
            end
        end
    end)
end
 

function IntanceStageInfoNode:showReport(inId, inSubType, inCallback)
    --回放
    local param = {id = inId, type  = 1, subType  = inSubType}
    self._serverMgr:sendMsg("StageServer", "showReport", param, true, {}, function (result)
        if result == nil or next(result) == nil then 
            self._viewMgr:showTip(lang("TIP_ZHUXIAN_8"))
            return
        end
        self._battleResult[inSubType] = result
        if inCallback ~= nil then 
            inCallback()
        end
    end)    
end

function IntanceStageInfoNode:getUserUpdateState()
    if self._userUpdateCallBack == nil then
        return false
    end
    return true
end

function IntanceStageInfoNode:hideView(isClose)
    self:setVisible(false)
    if self._hideCallback ~= nil then 
        self._hideCallback(isClose)
    end
end

function IntanceStageInfoNode:setHideCallback(inCallback)
    self._hideCallback = inCallback
end

function IntanceStageInfoNode:setBattleFinishCallback(inCallback)
    self._battleFinishCallback = inCallback
end


return IntanceStageInfoNode