--[[
    Filename:    GodWarWatchBattleDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-18 20:48:07
    Description: File description
--]]

-- 直播间 BasePopView
local GodWarWatchBattleDialog = class("GodWarWatchBattleDialog", BasePopView)
local readlyTime = GodWarUtil.readlyTime -- 准备间隔
local fightTime = GodWarUtil.fightTime -- 战斗间隔
local watchPowImg = GodWarUtil.watchPowImg
local showScoreTime = GodWarUtil.showScoreTime
local heroWidth = 975
local heroHeight = 283

function GodWarWatchBattleDialog:ctor(param)
    GodWarWatchBattleDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._dataCallback = param.callback1
    self._battleCallback = param.callback2
    self._bulletSynCallback = param.callback3
    self._updateDirectTip = param.callback4
    self.popAnim = false
end

function GodWarWatchBattleDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarWatchBattleDialog")
        end
        if self._bulletSynCallback then
            self._bulletSynCallback()
        end
        self:close()
    end)  

    self._userModel = self._modelMgr:getModel("UserModel")
    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._subTime = 0
    self._leftNumber = 0
    self._rightNumber = 0

    local jieduanLab = self:getUI("bg.jieduanLab")
    jieduanLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local jieduanTime = self:getUI("bg.jieduanTime")
    jieduanTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local bifentishi = self:getUI("bg.bifentishi")
    bifentishi:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local biScoreLab = self:getUI("bg.biScoreLab")
    biScoreLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._powImg = self:getUI("bg.layerBg.battleBg.powImg")

    self:setUI()
    self:realTimeData()
    self:listenReflash("GodWarModel", self.updateData)

    self:closeDialogView()
    self:updateReviewBtn()
    -- 弹幕 -- 从godwar 拷贝
    self:updateBulletBtnState()
    self:showGodWarBullet()
end

function GodWarWatchBattleDialog:updateData()
    ScheduleMgr:delayCall(5000, self, function()
        if self.updateUIData then
            self:updateUIData()
        end
    end)
end

function GodWarWatchBattleDialog:realTimeData()
    if self.updateUIData then
        self:updateUIData()
    end
end

-- 获取当前是哪一场
function GodWarWatchBattleDialog:getStrPower(powerId)
    local round, ju = 1, 1
    local curServerTime = self._userModel:getCurServerTime()
    if powerId == 32 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local allTime = curServerTime - beginBattle
        ju = math.floor(allTime/fightTime)
        round = math.floor(ju/3)
        ju = ju - round*3 + 1
        round = round + 1
    elseif powerId == 8 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local roundTime = readlyTime+fightTime*3
        local allTime = curServerTime - beginBattle
        round = math.floor(allTime/roundTime)

        local tTime = allTime - round*roundTime
        if tTime < (readlyTime+fightTime) then
            ju = 1
        elseif tTime < (readlyTime+fightTime*2) then
            ju = 2
        elseif tTime < (readlyTime+fightTime*3) then
            ju = 3
        end
        round = round + 1
        if curServerTime < beginBattle then
            round = 1
            ju = 1
        end
    elseif powerId == 4 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local roundTime = readlyTime+fightTime*3
        local allTime = curServerTime - beginBattle
        round = math.floor(allTime/roundTime)

        local tTime = allTime - round*roundTime
        if tTime < (readlyTime+fightTime) then
            ju = 1
        elseif tTime < (readlyTime+fightTime*2) then
            ju = 2
        elseif tTime < (readlyTime+fightTime*3) then
            ju = 3
        end
        round = round + 1
        if curServerTime < beginBattle then
            round = 1
            ju = 1
        end
    elseif powerId == 2 then
        local beginBattle = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        local readlyTime = 300
        local roundTime = readlyTime+fightTime*3
        local allTime = curServerTime - beginBattle
        round = math.floor(allTime/roundTime)

        local tTime = allTime - round*roundTime
        if tTime < (readlyTime+fightTime) then
            ju = 1
        elseif tTime < (readlyTime+fightTime*2) then
            ju = 2
        elseif tTime < (readlyTime+fightTime*3) then
            ju = 3
        end
        round = 1
    end
    return round, ju
end


function GodWarWatchBattleDialog:updateUIData()
    local state, staIndexId = self._godWarModel:getStatus()
    local warMatchTime = self._godWarModel:getGodWarMatchTime()
    local warMatchData = warMatchTime[staIndexId]
    dump(warMatchData)
    local chang, ju, powId = 1, 1, 8
    if self._dataCallback then
        chang, ju, powId = self._dataCallback()
        chang, ju = self:getStrPower(powId)
    end
    print("updateUIData==++++++++========", powId)
    if self._powImg and watchPowImg[powId] then
        self._powImg:loadTexture(watchPowImg[powId], 1)
    end
    -- self:updateAtmosphere(powId)
    local godWar = self._godWarModel:getWarDataById(powId)
    local curServerTime = self._userModel:getCurServerTime()
    local cTime = curServerTime - warMatchData[2]
    if curServerTime + 1800 >= warMatchData[2] and curServerTime < warMatchData[2] then
        chang = 1
        ju = 1
    else
        ju = math.fmod(ju, 3)
        if ju == 0 then
            ju = 3
        end
    end
    print("ju===========", ju, chang)

    local roundLab = self:getUI("bg.roundLab")
    local juLab = self:getUI("bg.juLab")
    local str = powId .. "强赛第" .. chang .. "场 第" .. ju .. "局"
    if powId == 8 or powId == 4 then
        
    elseif powId == 2 then
        str = "冠军对决 第" .. ju .. "局"
    end
    roundLab:setString(chang)
    juLab:setString(ju)
    -- saiTimeLab:setString(str)

    -- local juLab = self:getUI("bg.juLab")
    -- str = "第" .. ju .. "局"
    -- juLab:setString(str)


    chang = tostring(chang)
    local warData
    if godWar and godWar[chang] then
        warData = godWar[chang]
    end
    if not warData then
        -- self:close()
        return
    end

    local boBattle = self:getUI("bg.boBattle")
    boBattle:setVisible(true)
    self:registerClickEvent(boBattle, function()
        local flag, fflag = self:isStakeFight(warMatchData, warData, powId)
        if fflag == 2 then
            if self._battleCallback then
                local param = {pow = powId, round = chang, ju = ju}
                self._battleCallback(param)
            end
        else
            self._viewMgr:showTip("战斗尚未开始，请耐心等待")
        end
        print("flag ========", fflag)
    end)


    local flag = self._godWarModel:isReverse(warData.def)
    if flag == true then
        warData = self._godWarModel:reversalData(warData)
    end
    local biScoreLab = self:getUI("bg.biScoreLab")
    biScoreLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local atkWin, defWin = self:getWarBattleWinData(warData)
    -- self:registerClickEvent(biScoreLab,function() 
    --     self:showBattleResultAnim(1, 1,true)
    -- end)
    print("powId, chang========", atkWin, defWin,biScoreLab._preAtkWin)
    str = atkWin .. ":" .. defWin
    -- biScoreLab:stopAllActions()
    -- biScoreLab:setString(str)
    -- if biScoreLab._preAtkWin then
    --     if (biScoreLab._preAtkWin ~= atkWin or biScoreLab._preDefWin ~= defWin) then
    --         if (atkWin ~= 0 or defWin ~= 0) then
    --             self:showBattleResultAnim(atkWin,defWin,biScoreLab._preAtkWin ~= atkWin)
    --         else
    --             -- biScoreLab:setFontSize(38)
    --             biScoreLab:setAnchorPoint(0.5,0.5)
    --             biScoreLab:setPositionX(658)
    --             -- biScoreLab:setString(str)
    --         end
    --     end
    -- else
    --     biScoreLab:stopAllActions()
    --     -- biScoreLab:setFontSize(38)
    --     biScoreLab:setAnchorPoint(0.5,0.5)
    --     biScoreLab:setPositionX(658)
    -- end
    -- biScoreLab._preAtkWin = atkWin
    -- biScoreLab._preDefWin = defWin
    print("chang=======", chang)
    -- dump(warData, "warData=========")
    if warData then
        local atkId = warData.atk
        local defId = warData.def
        local atkData = self._godWarModel:getPlayerById(atkId)
        local defData = self._godWarModel:getPlayerById(defId)

        local leftPanel = self:getUI("bg.leftPanel")
        self:updateLeftPanel(leftPanel, atkData, false, warData, defData, powId)

        local rightPanel = self:getUI("bg.rightPanel")
        self:updateRightPanel(rightPanel, defData, true, warData, atkData, powId)

        self:updateZhichi(atkData, defData, tonumber(chang), powId)

        local flag = self:isStakeFight(warMatchData, warData, powId)
        print("false==========", flag)
        if flag == 1 then
            self:supportAndFight(3)
            -- self:canSupport()
        -- elseif flag == 2 then
        --     self:supportAndFight(2)
            -- self:canFight()
        else
            self:supportAndFight(1)
            -- self:noSupportAndFight()
        end

        local jieduanLab = self:getUI("bg.jieduanLab")
        jieduanLab:setPositionX(253)
        jieduanLab:setVisible(true)
        local jieduanTime = self:getUI("bg.jieduanTime")
        local bifentishi = self:getUI("bg.bifentishi")
        local callFunc = cc.CallFunc:create(function()
            local readlyTime = readlyTime
            if powId == 2 then
                readlyTime = 300
            end
            local middleTime = readlyTime + fightTime*3
            local curServerTime = self._userModel:getCurServerTime()
            local cTime = curServerTime - warMatchData[2]
            local daojishi = 0
            if cTime < 0 then
                daojishi = math.abs(cTime) + 180
                jieduanTime:setVisible(true)
                bifentishi:setVisible(true)
                biScoreLab:setString("0:0")
            else
                local _tTime = math.fmod(cTime, middleTime)
                local ttime = _tTime - readlyTime
                daojishi = ttime
                if ttime < 0 then -- 支持阶段
                    daojishi = math.abs(ttime)
                    jieduanTime:setVisible(true)
                    biScoreLab:setVisible(true)
                    jieduanLab:setVisible(true)
                    bifentishi:setString("比分")
                    biScoreLab:setString("0:0")
                    self._quanAnim:setVisible(false)
                    self._quanImg:setVisible(true)
                else -- 战斗阶段
                    self._quanAnim:setVisible(true)
                    self._quanImg:setVisible(false)
                    jieduanTime:setVisible(false)
                    jieduanLab:setVisible(false)
                    -- jieduanLab:setString("     正在战斗") 
                    local fTime = math.fmod(ttime, fightTime)
                    -- print("fTime ============", fTime, ttime)
                    if fTime < showScoreTime + 10 then
                        biScoreLab:setVisible(false)
                        bifentishi:setString("比分上传中") 
                    else
                        biScoreLab:setVisible(true)
                        bifentishi:setString("比分")
                        warData = godWar[chang]
                        if warData then
                            local flag = self._godWarModel:isReverse(warData.def)
                            if flag == true then
                                warData = self._godWarModel:reversalData(warData)
                            end
                            local atkWin, defWin = self:getWarBattleWinData(warData)
                            biScoreLab:setString(atkWin .. ":" .. defWin) 
                        end
                    end
                end
            end

            -- local cTime = curServerTime - warMatchData[2]
            -- local ttime = math.fmod(cTime, 300)
            -- local zhichitime = math.fmod(cTime, 300*3)
            -- local zhichiMax = 180
            -- local daojishi = 180 - ttime
            -- if cTime < 0 then
            --     daojishi = math.abs(cTime) + 180
            --     zhichiMax = zhichiMax + 600
            -- end

            local flag = self:isStakeFight(warMatchData, warData, powId)
            -- print("flag==========", flag)
            if flag == 1 then
                self:supportAndFight(3)
            -- elseif flag == 2 then
            --     self:supportAndFight(2)
            else
                self:supportAndFight(1)
            end

            -- print("===daojishi============", daojishi)
            local minTime = math.floor(daojishi/60)
            local secTime = math.fmod(daojishi, 60)
            local ddTime = string.format("00:%.2d:%.2d", minTime, math.fmod(daojishi, 60))
            str = ddTime
            jieduanTime:setString(str)   
            -- jieduanTime:setPositionX(330) 
        end)
        local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
        jieduanTime:stopAllActions()
        jieduanTime:runAction(cc.RepeatForever:create(seq))
    end

    self:updateReviewBtn()
end

function GodWarWatchBattleDialog:updateLeftPanel(inView, data, fan, warData, enemyData, powId)
    local zhandouli = inView:getChildByFullName("zhandouli")
    if zhandouli then
        local score = data.score or 100
        zhandouli:setString("a" .. score)
    end

    local pname = inView:getChildByFullName("pname")
    if pname then
        local name = data.name
        pname:setString(name)
    end
    local pnumber = inView:getChildByFullName("zhichiBg.pnumber")
    if pnumber then
        pnumber:setString("6666")
    end

    local heroId = data.hId or 60101
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["crusadeRes"]
    local heroPosx = heroWidth
    local heroPosy = heroHeight
    local heroScale = 1
    local heroFlip = 0
    local shine, shinePos
    if data.skin and data.skin ~= 0 then
        local heroSkinD = tab.heroSkin[data.skin]
        heroArt = heroSkinD["wholecut"]
        local heroPos = heroSkinD["godWar"]
        if heroPos then
            heroPosx = heroWidth - heroPos[1] or 0
            heroPosy = heroHeight - heroPos[2] or 0
            heroScale = heroPos[3] or 1
            heroFlip = heroPos[4] or 0
        end

        shine = heroSkinD["shineanim"]
        shinePos = heroSkinD["shine2"]
    end

    self._leftHeroBg:loadTexture("asset/uiother/hero/" .. heroArt .. ".png")
    self._leftHeroBg:setPosition(heroPosx, heroPosy)
    self._leftHeroBg:setScale(heroScale)
    if heroFlip == 1 then
        self._leftHeroBg:setFlippedX(true)
    else
        self._leftHeroBg:setFlippedX(false)
    end


    local heroBg = self._leftHeroBg
    local heroModel = self._modelMgr:getModel("HeroModel")
    if shine then
        for i=1,4 do
            local anim = heroBg["anim" .. i]
            if anim then
                anim:removeFromParent()
            end
            local _shine = shine[i]
            if _shine then
                local heroPosx = shinePos[i][1]
                local heroPosy = shinePos[i][2]
                local heroScale = shinePos[i][3]
                local skinRotate = shinePos[i][4]
                -- local animStr = heroModel:getSkinMcNameByIndex(_shine)
                anim = mcMgr:createViewMC(_shine, true, false)
                anim:setName("anim" .. i)
                anim:setPosition(heroPosx, heroPosy)
                anim:setScale(heroScale)
                anim:setRotation(skinRotate)
                heroBg:addChild(anim,50)
                heroBg["anim" .. i] = anim
            end
        end
    else
        for i=1,4 do
            local anim = heroBg["anim" .. i]
            if anim then
                anim:removeFromParent()
            end
        end
    end

    -- 玩家头像
    if inView then
        local param = {avatar = data.avatar, level = data.lvl, tp = 4, avatarFrame = data["avatarFrame"]}
        local icon = inView:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param)
            icon:setName("icon")
            icon:setScale(0.9)
            icon:setPosition(8, 25)
            inView:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param)
        end

        self:registerClickEvent(icon, function()
            local data = {tagId = data.rid, fid = 101}
            self:getTargetUserBattleInfo(data)
        end)
    end

    -- warData.rate
    local winAward = inView:getChildByFullName("winAward")
    if winAward then
        dump(warData.rate,"warData.rate====".. powId)
        local rateBase = tab:Setting("G_GODWAR_STAGE" .. powId)["value"][1][1]
        if warData and warData.rate then
            local rateValue = warData.rate["1"]
            if fan == true then
                rateValue = warData.rate["2"]
            end
            local rateNum = rateValue * rateBase
            print("warrate base,",rateBase,"rateValue",rateValue)
            winAward:setString(rateNum)
        end
    end

    local zhichiImg = inView:getChildByFullName("zhichiImg")
    zhichiImg:setVisible(false)
    if not warData.stake or warData.stake == 0 then
        zhichiImg:loadTexture("godwarImageUI_img252.png", 1)
        -- zhichiImg:setVisible(false)
    elseif warData.stake == 1 then
        zhichiImg:loadTexture("godwarImageUI_img254.png", 1)
        zhichiImg:setVisible(true)
    elseif warData.stake == 2 then
        zhichiImg:loadTexture("godwarImageUI_img252.png", 1)
        zhichiImg:setVisible(true)
    end

    local zhichi = inView:getChildByFullName("zhichi")
    if zhichi then
        self:registerClickEvent(zhichi, function()
            local flag, fflag, fightFlag = self:isStakeFight(warMatchData, warData, powId)
            if fightFlag == 1 then
                self._viewMgr:showTip("支持时间已过，战斗开始前可支持选手")
                return
            end
            local enemyflag = self._godWarModel:isReverse(enemyData.rid)
            if enemyflag == true then
                self._viewMgr:showTip("您无法支持您的对手")
                return
            end
            local chang, ju, powId = self._dataCallback()
            local to = 1
            if fan == true then
                to = 2
            end
            if warData.onReverse == true then
                if to == 2 then
                    to = 1
                else
                    to = 2
                end
            end
            local param = {pow = powId, round = warData.round, to = to}
            self:stakeFight(param, warData)
        end)
    end
end

-- 1 不能战斗也不能支持
-- 2 可以战斗
-- 3 可以支持
function GodWarWatchBattleDialog:supportAndFight(supportType)
    local lzhichiBtn = self:getUI("bg.leftPanel.zhichi")
    local rzhichiBtn = self:getUI("bg.rightPanel.zhichi")
    if supportType == 1 then -- 战斗开始已经支持
        lzhichiBtn:setVisible(false)
        rzhichiBtn:setVisible(false)
    elseif supportType == 2 then -- 支持阶段没有支持
        lzhichiBtn:setVisible(true)
        rzhichiBtn:setVisible(true)
    elseif supportType == 3 then -- 战斗阶段可以支持
        lzhichiBtn:setVisible(true)
        rzhichiBtn:setVisible(true)
    elseif supportType == 4 then -- 战斗阶段已经支持
        --todo
    end
end

function GodWarWatchBattleDialog:reflashUI()
    self:updateUIData()
end
function GodWarWatchBattleDialog:updateRightPanel(inView, data, fan, warData, enemyData, powId)
    local pimg = inView:getChildByFullName("pimg")
    local zhichi = inView:getChildByFullName("zhichi")
    local heroBg = inView:getChildByFullName("heroBg")
    -- zhandouli:setVisible(false)
    -- local zhandouli = inView:getChildByFullName("nameBg.fightScore")
    -- local zhandouliLab = inView:getChildByFullName("nameBg.tishi")
    local winAward = inView:getChildByFullName("winAward")

    local zhandouli = inView:getChildByFullName("zhandouli")
    if zhandouli then
        local score = data.score or 100
        zhandouli:setString("a" .. score)
    end

    local pname = inView:getChildByFullName("pname")
    if pname then
        local name = data.name or "小精灵"
        pname:setString(name)
    end
    local pnumber = inView:getChildByFullName("zhichiBg.pnumber")
    if pnumber then
        pnumber:setString("1221")
    end

    local heroId = data.hId or 60101
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["crusadeRes"]
    local heroPosx = heroWidth
    local heroPosy = heroHeight
    local heroScale = 1
    local heroFlip = 1
    local shine, shinePos
    if data.skin and data.skin ~= 0 then
        local heroSkinD = tab.heroSkin[data.skin]
        heroArt = heroSkinD["wholecut"]
        local heroPos = heroSkinD["godWar"]
        if heroPos then
            heroPosx = heroWidth + heroPos[1] or 0
            heroPosy = heroHeight - heroPos[2] or 0
            heroScale = heroPos[3] or 1
            heroFlip = heroPos[4] or 1
        end

        shine = heroSkinD["shine"]
        shinePos = heroSkinD["shine2"]
    end

    self._rightHeroBg:loadTexture("asset/uiother/hero/" .. heroArt .. ".png")
    self._rightHeroBg:setPosition(heroPosx, heroPosy)
    self._rightHeroBg:setScale(heroScale)
    if heroFlip == 0 then
        self._rightHeroBg:setFlippedX(true)
    else
        self._rightHeroBg:setFlippedX(false)
    end

    local heroBg = self._rightHeroBg
    local heroModel = self._modelMgr:getModel("HeroModel")
    if shine then
        for i=1,4 do
            local anim = heroBg["anim" .. i]
            if anim then
                anim:removeFromParent()
            end
            local _shine = shine[i]
            if _shine then
                local heroPosx = shinePos[i][1]
                local heroPosy = shinePos[i][2]
                local heroScale = shinePos[i][3]
                local skinRotate = shinePos[i][4]
                -- local animStr = heroModel:getSkinMcNameByIndex(_shine)
                anim = mcMgr:createViewMC(_shine, true, false)
                anim:setName("anim" .. i)
                anim:setPosition(heroPosx, heroPosy)
                anim:setScale(heroScale)
                anim:setRotation(skinRotate)
                heroBg:addChild(anim,50)
                heroBg["anim" .. i] = anim
            end
        end
    else
        for i=1,4 do
            local anim = heroBg["anim" .. i]
            if anim then
                anim:removeFromParent()
            end
        end
    end

    if inView then
        local param = {avatar = data.avatar, level = data.lvl, tp = 4, avatarFrame = data["avatarFrame"]}
        local icon = inView:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param)
            icon:setName("icon")
            icon:setScale(0.9)
            icon:setPosition(8, 25)
            inView:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param)
        end

        self:registerClickEvent(icon, function()
            local data = {tagId = data.rid, fid = 101}
            self:getTargetUserBattleInfo(data)
        end)
    end

    local zhichiImg = inView:getChildByFullName("zhichiImg")
    zhichiImg:setVisible(false)
    if not warData.stake or warData.stake == 0 then
        zhichiImg:loadTexture("godwarImageUI_img253.png", 1)
        zhichiImg:setVisible(false)
    elseif warData.stake == 1 then
        zhichiImg:loadTexture("godwarImageUI_img253.png", 1)
        zhichiImg:setVisible(true)
    elseif warData.stake == 2 then
        zhichiImg:loadTexture("godwarImageUI_img251.png", 1)
        zhichiImg:setVisible(true)
    end

    -- warData.rate
    if winAward then
        dump(warData.rate,"warData.rate====".. powId)
        local rateBase = tab:Setting("G_GODWAR_STAGE" .. powId)["value"][1][1]
        if warData and warData.rate then
            local rateValue = warData.rate["1"]
            if fan == true then
                rateValue = warData.rate["2"]
            end
            local rateNum = rateValue * rateBase
            print("warrate base,",rateBase,"rateValue",rateValue)
            winAward:setString(rateNum)
        end
    end

    if zhichi then
        self:registerClickEvent(zhichi, function()
            local flag, fflag, fightFlag = self:isStakeFight(warMatchData, warData, powId)
            if fightFlag == 1 then
                self._viewMgr:showTip("支持时间已过，战斗开始前可支持选手")
                return
            end
            local enemyflag = self._godWarModel:isReverse(enemyData.rid)
            if enemyflag == true then
                self._viewMgr:showTip("您无法支持您的对手")
                return
            end
            local chang, ju, powId = self._dataCallback()
            local to = 1
            if fan == true then
                to = 2
            end
            if warData.onReverse == true then
                if to == 2 then
                    to = 1
                else
                    to = 2
                end
            end
            local param = {pow = powId, round = warData.round, to = to}
            self:stakeFight(param, warData)
        end)
    end
end

function GodWarWatchBattleDialog:updateZhichi(atkData, defData, round, powId)
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()
    local timer = curServerTime - userData.sec_open_time
    local opennum = math.floor(timer/86400)
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local roundTime = readlyTime + fightTime*3
        local fenTime = math.floor(roundTime/60)
        local minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:" .. fenTime*(round-1) .. ":00"))
        local second = curServerTime - minTime
        local maxSec = 180
        -- print("============", round, powId)
        if round == 1 and powId ~= 2 then
            maxSec = maxSec + 1800
            minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 19:30:00"))
            second = curServerTime - minTime
        elseif round == 1 and powId == 2  then
            maxSec = maxSec + 120
            minTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
            second = curServerTime - minTime
        end
        -- print("============", second, maxSec)
        if second > maxSec then
            second = maxSec
        end
        local atkNum = self:getZhichiNum(opennum, second, atkData, defData)
        local defNum = self:getZhichiNum(opennum, second, defData, atkData)
        self._leftNumber = atkNum
        self._rightNumber = defNum
        local zhichiBg = self:getUI("bg.leftPanel.zhichiBg")  
        local lpnumber = self:getUI("bg.leftPanel.zhichiBg.pnumber")  
        local lpimg = self:getUI("bg.leftPanel.zhichiBg.pimg")  
        lpnumber:setString(atkNum) 
        local posX = (zhichiBg:getContentSize().width - lpimg:getContentSize().width - lpnumber:getContentSize().width)*0.5
        lpimg:setPositionX(posX)
        posX = posX + lpimg:getContentSize().width
        lpnumber:setPositionX(posX)
        local rpnumber = self:getUI("bg.rightPanel.zhichiBg.pnumber")   
        local rpimg = self:getUI("bg.rightPanel.zhichiBg.pimg")  
        rpnumber:setString(defNum) 
        local posX = (zhichiBg:getContentSize().width - rpimg:getContentSize().width - rpnumber:getContentSize().width)*0.5
        rpimg:setPositionX(posX)
        posX = posX + rpimg:getContentSize().width
        rpnumber:setPositionX(posX)
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(10))
    local pnumber = self:getUI("bg.leftPanel.zhichiBg.pnumber")   
    if pnumber then
        pnumber:stopAllActions()
        pnumber:runAction(cc.RepeatForever:create(seq))
    end
end

function GodWarWatchBattleDialog:getZhichiNum(opennum, timer, data, enemyData)
    -- print("opennum==========", opennum, timer, data.score, enemyData.score)
    -- 支持人数= ceiling (748*（2*我战斗力/（我战斗力+敌战斗力）)*2*时间秒/(327+时间秒)*max(74/开服时间,1),0))
    local zhichiNum = 174*((2*data.score/(data.score+enemyData.score))^6)*1.5*timer/(156+timer)*math.max(148/opennum, 1)
    local sumNum = math.floor(zhichiNum)
    if sumNum < 0 then
        sumNum = 0
    end
    -- print("zhichiNum=======", sumNum)
    return sumNum
end

function GodWarWatchBattleDialog:stakeFight(param, warData)
    if not param then
        return
    end
    self._serverMgr:sendMsg("GodWarServer","stakeFight",param,true,{},function( result )
        -- dump(result, "result=========")
        dump(warData,"warData==========")
        local zhichi = self:getUI("bg.leftPanel.zhichiImg")
        local pnumber = self:getUI("bg.leftPanel.zhichiBg.pnumber")  
        local tnumber = self._leftNumber + 1
        if param.to == 2 and warData.onReverse ~= true then
            zhichi = self:getUI("bg.rightPanel.zhichiImg")
            pnumber = self:getUI("bg.rightPanel.zhichiBg.pnumber")   
            tnumber = self._rightNumber + 1
        end
        if self._updateDirectTip then
            self._updateDirectTip(warData)
        end
        local scale1 = cc.ScaleTo:create(0.01, 3)
        local callFunc = cc.CallFunc:create(function()
            zhichi:setVisible(true)
        end)

        local scale2 = cc.ScaleTo:create(0.1, 0.9)
        local scale3 = cc.ScaleTo:create(0.2, 1)
        local callFunc1 = cc.CallFunc:create(function()
            self:realTimeData()            
        end)
        local seq = cc.Sequence:create(scale1, callFunc, scale2, scale3, callFunc1)
        zhichi:runAction(seq)
        pnumber:setString(tnumber) 
    end)
end

-- 是否在支持时间内
function GodWarWatchBattleDialog:isReadlyTime(powId, round)
    local curServerTime = self._userModel:getCurServerTime()
    local flag = false
    local fightFlag = false
    if powId == 8 then
        local middleTime = readlyTime + fightTime*3
        local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local tempTime1 = baseTime + (round-1)*middleTime
        local tempTime2 = baseTime + (round-1)*middleTime + readlyTime - 3
        local tempTime3 = baseTime + (round-1)*middleTime + readlyTime + 5
        -- local tempTime2 = baseTime + (round)*middleTime - 5
        if round == 1 then
            tempTime1 = tempTime1 - 1800
        end
        -- print("curServerTime=======", curServerTime, tempTime1, tempTime2)
        if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
            flag = true
        else
            if curServerTime >= tempTime3 then
                fightFlag = true
            end
        end
    elseif powId == 4 then
        local middleTime = readlyTime + fightTime*3
        local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local tempTime1 = baseTime + (round-1)*middleTime
        local tempTime2 = baseTime + (round-1)*middleTime + readlyTime - 3
        local tempTime3 = baseTime + (round-1)*middleTime + readlyTime + 5
        -- local tempTime2 = baseTime + (round)*middleTime - 5
        if round == 1 then
            tempTime1 = tempTime1 - 1800
        end
        if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
            flag = true
        else
            if curServerTime >= tempTime3 then
                fightFlag = true
            end
        end
    elseif powId == 2 then
        local readlyTime = 300
        local middleTime = readlyTime + fightTime*3
        local baseTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        local tempTime1 = baseTime + (round-1)*middleTime
        local tempTime2 = baseTime + (round-1)*middleTime + readlyTime - 3
        local tempTime3 = baseTime + (round-1)*middleTime + readlyTime + 5
        -- print("curServerTime=======", curServerTime, tempTime1, tempTime2)
        if curServerTime >= tempTime1 and curServerTime <= tempTime2 then
            flag = true
        else
            if curServerTime >= tempTime3 then
                fightFlag = true
            end
        end
    end
    return flag, fightFlag
end

-- 1 支持状态 2 战斗状态
-- 1 支持状态没有支持 2 战斗状态已经支持 3 支持状态已经支持  4 战斗状态没有支持
-- 按钮展示， 点击直播， 战斗状态
function GodWarWatchBattleDialog:isStakeFight(warMatchData, godWar, powId)
    if not godWar then
        return false
    end
    local flag = 1
    local fflag = 1
    local fightFlag = 0
    local powId = godWar.pow 
    local round = godWar.round
    local stake = godWar.stake
    local readlyFlag, tfightFlag = self:isReadlyTime(powId, round)
    if readlyFlag == true then
        fightFlag = 0
    else
        fightFlag = 1
    end
    if stake == 0 then
        flag = 1
    else
        flag = 3
    end
    if tfightFlag == true then
        fflag = 2
    end

    return flag, fflag, fightFlag
end

function GodWarWatchBattleDialog:getWarBattleEnd(powId, round, ju)
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local flag = false
    if powId == 8 then
        local roundTime = readlyTime+fightTime*3
        local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local addTime = (round-1)*roundTime + readlyTime + (ju-1)*fightTime
        local endTime = tTime + addTime + 62
        if endTime < curServerTime then
            flag = true
        end
    elseif powId == 4 then
        local roundTime = readlyTime+fightTime*3
        local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:00:00"))
        local addTime = (round-1)*roundTime + readlyTime + (ju-1)*fightTime
        local endTime = tTime + addTime + 62
        if endTime < curServerTime then
            flag = true
        end
    elseif powId == 2 then
        local readlyTime = 300
        local roundTime = readlyTime+fightTime*3
        local tTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:18:00"))
        local addTime = (ju-1)*fightTime + readlyTime
        local endTime = tTime + addTime + 62
        if endTime < curServerTime then
            flag = true
        end
    end
    return flag
end

function GodWarWatchBattleDialog:getWarBattleWinData(godWar)
    local win1 = 0
    local win2 = 0
    if godWar then
        local reps = godWar["reps"]
        for i=1,3 do
            local indexId = tostring(i)
            if reps and reps[indexId] then
                local flag = self:getWarBattleEnd(godWar.pow, godWar.round, i)
                if flag == true then
                    if reps[indexId]["w"] == 1 then
                        win1 = win1 + 1
                    elseif reps[indexId]["w"] == 2 then
                        win2 = win2 + 1
                    end
                end
            end
        end
    end
    return win1, win2
end

function GodWarWatchBattleDialog:getTargetUserBattleInfo(param)
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result) 
        self._viewMgr:showDialog("godwar.GodwarUserInfoDialog", result, true)
    end)
end

-- 根据时间关闭界面
function GodWarWatchBattleDialog:closeDialogView()
    local saiTimeLab = self:getUI("bg.saiTimeLab")
    local curServerTime = self._userModel:getCurServerTime()
    local maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:36:00"))
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    if weekday == 4 then
        maxTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 20:29:00"))
    end
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local cTime = maxTime - curServerTime
        if cTime <= -3 then
            if self.close then
                self:close()
            end
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    saiTimeLab:runAction(cc.RepeatForever:create(seq))
end

function GodWarWatchBattleDialog:doPop(callback)
    self._widget:setBackGroundColorOpacity(0)
    self._widget:setTouchEnabled(true)
    local bg = self:getUI("bg")
    if bg then
        bg:setAnchorPoint(0.5, 0.5)
        bg:setVisible(false)
        bg:stopAllActions()
        bg:setScale(0.2)
        self._doPopCallback = callback
        audioMgr:playSound("Popup")
        ScheduleMgr:delayCall(0, self, function()
            if not bg then return end
            local bgposx = bg:getPositionX()
            local bgposy = bg:getPositionY()
            local posx = 100 -- MAX_SCREEN_WIDTH + 100
            local posy = MAX_SCREEN_HEIGHT - 100
            bg:setPosition(posx, posy)
            bg:setVisible(true)
            local move1 = cc.MoveTo:create(0.1, cc.p(bgposx, bgposy))
            local ease = cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.05), 3)
            local spawn = cc.Spawn:create(ease, move1)
            bg:runAction(cc.Sequence:create(spawn, 
                cc.ScaleTo:create(0.07, 1.0),
                cc.CallFunc:create(function ()
                self._viewMgr:doPopShowGuide(self)
                if callback then
                    callback()
                end
                self._doPopCallback = nil
                self:onPopEnd()
            end)))
        end)
    else
        callback()
        audioMgr:playSound("Popup")
        self._viewMgr:doPopShowGuide(self)
        self:onPopEnd()
    end 
end

function GodWarWatchBattleDialog:close(noAnim, callback)
    local bg = self:getUI("bg")
    if bg then
        audioMgr:playSound("Close")
        bg:setAnchorPoint(0.5, 0.5)
        bg:stopAllActions()
        local posx = 100 -- MAX_SCREEN_WIDTH + 100
        local posy = MAX_SCREEN_HEIGHT - 100
        local move1 = cc.MoveTo:create(0.11, cc.p(posx, posy))
        local scale1 = cc.ScaleTo:create(0.05, 1.1)
        local scale2 = cc.ScaleTo:create(0.06, 0.01)
        local seq = cc.Sequence:create(scale1, scale2)
        local spawn = cc.Spawn:create(seq, move1)
        bg:runAction(cc.Sequence:create(
            spawn,
            cc.CallFunc:create(function () bg:setVisible(false) end), cc.DelayTime:create(0.05), 
            cc.CallFunc:create(function ()
            self._viewMgr:doPopCloseGuide(self)  
            self:_remove()
            if callback then
                callback()
            end
        end)))
    else
        self._viewMgr:doPopCloseGuide(self)
        audioMgr:playSound("Close")
        self:_remove()
        if callback then
            callback()
        end
    end
end

-- function GodWarWatchBattleDialog:updateAtmosphere(powId)
--     -- local powId = self._powId or 8
--     local powId = powId or 8
--     local atmosphere = atmosphereTab[powId]
--     local atBg = atmosphere.atBg
--     local atHeroDizuo = atmosphere.atHeroDizuo
--     local qizi = atmosphere.qizi
--     local layerBg = self:getUI("bg.layerBg")
--     layerBg:loadTexture("asset/bg/" .. atBg, 0)
--     -- local dizuo = self:getUI("bg.leftPanel.dizuo")
--     -- dizuo:loadTexture(atHeroDizuo, 1)
--     -- -- dizuo:setScale(0.8)
--     -- local dizuo = self:getUI("bg.rightPanel.dizuo")
--     -- dizuo:loadTexture(atHeroDizuo, 1)
--     -- dizuo:setScale(0.8)
--     -- local qiziBg = self:getUI("bg.layerBg.Image_57")
--     -- qiziBg:loadTexture(qizi, 1)
-- end

function GodWarWatchBattleDialog:setUI()
    -- local layerBg = self:getUI("bg.layerBg")
    -- layerBg:loadTexture("asset/bg/bg_godwar_003.jpg", 0)
    -- local dizuo = self:getUI("bg.leftPanel.dizuo")
    -- dizuo:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    -- dizuo:setScale(0.8)
    -- local dizuo = self:getUI("bg.rightPanel.dizuo")
    -- dizuo:loadTexture("asset/uiother/dizuo/heroDizuo.png", 0)
    -- dizuo:setScale(0.8)

    local qipaoLab = self:getUI("bg.layerBg.qipao.lab")
    qipaoLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    -- 背景
    local layerBg = self:getUI("bg.layerBg")
    local spBg = cc.Sprite:create("asset/bg/bg_godwar_013.jpg")
    local scale = MAX_SCREEN_WIDTH/1022
    spBg:setScale(scale)
    spBg:setName("spBg")
    spBg:setPosition(layerBg:getContentSize().width*0.5, layerBg:getContentSize().height*0.5)
    layerBg:addChild(spBg, -1)

    -- left英雄
    -- local leftHeroBg = cc.Sprite:create("asset/uiother/hero/crusade_Adelaide.png")
    -- leftHeroBg:setName("leftHeroBg")
    -- leftHeroBg:setPosition(layerBg:getContentSize().width*0.5-50, layerBg:getContentSize().height*0.5)
    -- layerBg:addChild(leftHeroBg, 1)
    self._leftHeroBg = self:getUI("bg.layerBg.heroBg.leftHero")
    self._leftHeroBg:setAnchorPoint(0.5, 0.5)

    -- local rightHeroBg = cc.Sprite:create("asset/uiother/hero/crusade_Adelaide.png")
    -- rightHeroBg:setName("rightHeroBg")
    -- rightHeroBg:setPosition(layerBg:getContentSize().width*0.5+50, layerBg:getContentSize().height*0.5)
    -- layerBg:addChild(rightHeroBg, 1)
    self._rightHeroBg = self:getUI("bg.layerBg.heroBg.rightHero")
    self._rightHeroBg:setAnchorPoint(0.5, 0.5)

    local leftPanel = self:getUI("bg.leftPanel")
    local leftFightLab = cc.LabelBMFont:create("a100", UIUtils.bmfName_zhandouli_little)
    leftFightLab:setName("zhandouli")
    leftFightLab:setAnchorPoint(cc.p(0,0.5))
    leftFightLab:setPosition(95, 75)
    leftFightLab:setScale(0.35)
    leftPanel:addChild(leftFightLab, 10)
    leftPanel.leftFightLab = leftFightLab

    local rightPanel = self:getUI("bg.rightPanel")
    local rightFightLab = cc.LabelBMFont:create("a100", UIUtils.bmfName_zhandouli_little)
    rightFightLab:setName("zhandouli")
    rightFightLab:setAnchorPoint(cc.p(0,0.5))
    rightFightLab:setPosition(95, 75)
    rightFightLab:setScale(0.35)
    rightPanel:addChild(rightFightLab, 10)
    rightPanel.rightFightLab = rightFightLab

    local lzhichi = self:getUI("bg.leftPanel.zhichi")
    lzhichi:setTitleColor(cc.c3b(78, 50, 13))
    lzhichi:getTitleRenderer():disableEffect()

    local rzhichi = self:getUI("bg.rightPanel.zhichi")
    rzhichi:setTitleColor(cc.c3b(78, 50, 13))
    rzhichi:getTitleRenderer():disableEffect()

    local battleBg = self:getUI("bg.layerBg.battleBg")
    local fdout = cc.FadeTo:create(0.1, 150)
    local fdin = cc.FadeIn:create(0.1)
    local tcount = 1
    local callFunc = cc.CallFunc:create(function()
        if battleBg then
            local num = math.fmod(tcount, 7) + 1
            tcount = tcount + 1
            battleBg:loadTexture("godwarImageUI_fightimg" .. num .. ".png", 1)
        end
    end)
    local seq = cc.Sequence:create(cc.DelayTime:create(2), fdout, callFunc, fdin)
    battleBg:runAction(cc.RepeatForever:create(seq))

    local quan = self:getUI("bg.layerBg.battleBg.quan")
    local ration = cc.RotateBy:create(2, 360)
    quan:runAction(cc.RepeatForever:create(ration))
    self._quanAnim = quan
    self._quanImg = self:getUI("bg.layerBg.battleBg.quanImg")

    -- local quan = self:getUI("bg.layerBg.battleBg.quan")
    -- local ration = cc.RotateBy:create(0.5, 90)
    -- quan:runAction(cc.RepeatForever:create(ration))

    local layerBg = self:getUI("bg.layerBg")
    local suipian1 = mcMgr:createViewMC("suipian1_suipian", true, false)
    suipian1:setPosition(150, 200)
    suipian1:setName("suipian1")
    layerBg:addChild(suipian1, 5)

    local suipian2 = mcMgr:createViewMC("suipian2_suipian", true, false)
    suipian2:setPosition(800, 240)
    suipian2:setName("suipian2")
    layerBg:addChild(suipian2, 5)

    -- local mc2 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    -- mc2:setPosition(lzhichi:getContentSize().width*0.5, lzhichi:getContentSize().height*0.5)
    -- mc2:setName("mc2")
    -- lzhichi:addChild(mc2, 1)
    -- lzhichi.mc2 = mc2

    -- local rzhichi = self:getUI("bg.rightPanel.zhichi")
    -- local mc1 = mcMgr:createViewMC("zhichianniu_godwar", true, false)
    -- mc1:setPosition(rzhichi:getContentSize().width*0.5, rzhichi:getContentSize().height*0.5+30)
    -- mc1:setName("mc1")
    -- rzhichi:addChild(mc1, -1)
    -- rzhichi.donghua = mc1

    -- local mc2 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
    -- mc2:setPosition(rzhichi:getContentSize().width*0.5, rzhichi:getContentSize().height*0.5)
    -- mc2:setName("mc2")
    -- rzhichi:addChild(mc2, 1)
    -- rzhichi.mc2 = mc2
end



function GodWarWatchBattleDialog:showBattleResultAnim( num1,num2,isLeftChange )
    local bifentishi = self:getUI("bg.bifentishi")
    local biScoreLab = self:getUI("bg.biScoreLab")
    -- biScoreLab:setFontSize(38)
    biScoreLab:setAnchorPoint(0.5,0.5)
    biScoreLab:stopAllActions()
    -- biScoreLab:setOpacity(0)
    biScoreLab:setString(":")
    biScoreLab:setPositionX(480)

    -- 更新动画
    local moveDis = 40
    local moveTime = 0.3
    local leftNum = ccui.Text:create()
    leftNum:setFontSize(38)
    leftNum:setAnchorPoint(1,0.5)
    leftNum:setFontName(UIUtils.ttfName)
    leftNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    leftNum:setOpacity(255)
    biScoreLab:addChild(leftNum,99)
    leftNum:setString(isLeftChange and num1-1 or num1)
    leftNum:setPosition(-moveDis-leftNum:getContentSize().width/2,leftNum:getContentSize().height/2)
    
    local rightNum = ccui.Text:create()
    rightNum:setFontSize(38)
    rightNum:setAnchorPoint(0,0.5)
    rightNum:setFontName(UIUtils.ttfName)
    rightNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    biScoreLab:addChild(rightNum,99)
    rightNum:setOpacity(255)
    rightNum:setString(not isLeftChange and num2-1 or num2)
    rightNum:setPosition(moveDis+rightNum:getContentSize().width/2,rightNum:getContentSize().height/2)

    local runStamptAction = function( orignLab,nextNum )
        orignLab:setString(nextNum)
        local stamptTime = 0.2
        local stamptLab = orignLab --ccui.Text:create()
        -- stamptLab:setFontSize(52)
        -- stamptLab:setPositionX(-orignLab:getContentSize().width)
        -- stamptLab:setString(nextNum)
        -- orignLab:addChild(stamptLab)
        stamptLab:setScale(2)
        stamptLab:setOpacity(0)
        stamptLab:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.ScaleTo:create(stamptTime,1),
                cc.FadeIn:create(stamptTime)
            ),
            cc.CallFunc:create(function(  )
                stamptLab:removeFromParent()
                orignLab:setString(nextNum)
                biScoreLab:setOpacity(255)
                biScoreLab:stopAllActions()
                biScoreLab:removeAllChildren()
                biScoreLab:setString(num1 .. ":" .. num2)
                -- biScoreLab:setFontSize(38)
                biScoreLab:setAnchorPoint(0.5,0.5)
                biScoreLab:setPositionX(658)
                bifentishi:setVisible(true)
            end)
        ))
    end

    leftNum:runAction(cc.Sequence:create(
        cc.MoveTo:create(moveTime,cc.p(0+5,leftNum:getContentSize().height/2)),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function()
            if isLeftChange then
                runStamptAction(leftNum,num1)
            else
                runStamptAction(rightNum,num2)
            end
        end)
    ))

    rightNum:runAction(cc.Sequence:create(
        cc.MoveTo:create(moveTime,cc.p(biScoreLab:getContentSize().width+5,rightNum:getContentSize().height/2)),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function()
            if not isLeftChange then
                runStamptAction(rightNum,num1)
            end
        end)
    ))
end

-- by guojun 结果上传中动画
function GodWarWatchBattleDialog:showUploadDataDes( )
    -- local desMap = {[0] = "结果上传中   ","结果上传中·  ","结果上传中·· ","结果上传中···"}
    local desMap = {[0] = "结果上传中","结果上传中","结果上传中","结果上传中"}
    local idx = 0
    local baseCount = 4
    local biScoreLab = self:getUI("bg.biScoreLab")
    biScoreLab:setFontSize(22)
    biScoreLab:setAnchorPoint(0,0.5)
    biScoreLab:stopAllActions()
    biScoreLab:setString(desMap[idx])
    biScoreLab:setPositionX(600)
    biScoreLab:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.DelayTime:create(0.3),
            cc.CallFunc:create(function( )
                idx = (idx+1)%baseCount
                biScoreLab:setString(desMap[idx]) 
            end)
        )
    ))
end

-- by guojun copy from godwarView
function GodWarWatchBattleDialog:updateBulletBtnState()
    -- BulletScreensUtils.clear()

    local bulletBtn = self:getUI("bg.layerBg.barrage")
    local bulletLab = self:getUI("bg.layerBg.bulletLab")
    self._sysBullet = tab:Bullet("GodWar")
    
    if self._sysBullet == nil then 
        bulletBtn:setVisible(false)
        bulletLab:setVisible(false)
        return
    else
        bulletBtn:setVisible(true)
        bulletLab:setVisible(true)
    end
    bulletLab:enable2Color(1, cc.c4b(255, 195, 17, 255))
    bulletLab:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    self:registerClickEvent(bulletBtn, function ()
        self._viewMgr:showDialog("global.BulletSettingView", {bulletD = self._sysBullet, 
            callback = function (open) 
                local fileName = open and "godwarImageUI_img145.png" or "godwarImageUI_img144.png"
                bulletBtn:loadTextures(fileName, fileName, fileName, 1)       
            end})
    end)    
end


-- 弹幕
function GodWarWatchBattleDialog:showGodWarBullet()
    self:progressGodWarBullet()
    if self._sysBullet == nil then 
        return
    end
    local bulletBtn = self:getUI("bg.layerBg.barrage")
    local open = BulletScreensUtils.getBulletChannelEnabled(self._sysBullet)
    local fileName = open and "godwarImageUI_img145.png" or "godwarImageUI_img144.png"
    bulletBtn:loadTextures(fileName, fileName, fileName, 1)    
    -- if open then
    --     BulletScreensUtils.initBullet(self._sysBullet)
    -- end    
end

function GodWarWatchBattleDialog:progressGodWarBullet()
    local curServerTime = self._userModel:getCurServerTime()
    local weekday = tonumber(TimeUtils.date("%w", curServerTime))
    local begTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 00:00:00"))
    local endTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime >= begTime and curServerTime <= endTime then
        curServerTime = curServerTime - 86400
        weekday = tonumber(TimeUtils.date("%w", curServerTime))
    end
    self._sysBullet = tab:Bullet("GodWar")
    local godWarConstData = self._userModel:getGodWarConstData()
    local begTime = godWarConstData["RACE_BEG"]
    if begTime == 0 then
        self._sysBullet = nil
    end
    local bulletBtn = self:getUI("bg.layerBg.barrage")
    local bulletLab = self:getUI("bg.layerBg.bulletLab")
    if self._sysBullet == nil then 
        bulletBtn:setVisible(false)
        bulletLab:setVisible(false)
        -- BulletScreensUtils.clear()
        return
    else
        bulletBtn:setVisible(true)
        bulletLab:setVisible(true)
    end
end

-- 局数回放 by guojun 2017.6.16
function GodWarWatchBattleDialog:updateReviewBtn( )
    local reviewBtn1 = self:getUI("bg.layerBg.reviewBtn1")
    local reviewBtn2 = self:getUI("bg.layerBg.reviewBtn2")

    local reViewBatte = function( powId,chang,ju )
        local param = {pow = powId, round = chang, ju = ju}
        self._battleCallback(param)
    end
    reviewBtn1:setVisible(false)
    reviewBtn2:setVisible(false)
    print("self._dataCallback")
    if self._dataCallback then
        local chang, ju, powId = self._dataCallback()
        chang, ju = self:getStrPower(powId)
        if ju == 1 then
            reviewBtn1:setVisible(false)
            reviewBtn2:setVisible(false)
        elseif ju == 2 then
            reviewBtn1:setVisible(true)
            -- reviewBtn1:setPositionX(485)
            reviewBtn2:setVisible(false)
        elseif ju == 3 then
            reviewBtn1:setVisible(true)
            reviewBtn2:setVisible(true)
            -- reviewBtn1:setPositionX(445)
            -- reviewBtn2:setPositionX(525)
        end
    end
    registerClickEvent(reviewBtn1,function( )
        if self._dataCallback then
            local chang, ju, powId = self._dataCallback()
            chang = self:getStrPower(powId)
            reViewBatte( powId,chang,1 )
        end
    end)

    registerClickEvent(reviewBtn2,function( )
        if self._dataCallback then
            local chang, ju, powId = self._dataCallback()
            chang= self:getStrPower(powId)
            reViewBatte( powId,chang,2 )
        end
    end)
end


function GodWarWatchBattleDialog.dtor()
    atmosphereTab = nil
end

return GodWarWatchBattleDialog