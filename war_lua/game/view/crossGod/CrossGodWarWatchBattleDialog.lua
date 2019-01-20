--[[
    Filename:    CrossGodWarWatchBattleDialog.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-05-16 14:44:07
    Description: File description
--]]

local CrossGodWarWatchBattleDialog = class("CrossGodWarWatchBattleDialog", BasePopView)
local readlyTime = GodWarUtil.readlyTime -- 准备间隔
local fightTime = GodWarUtil.fightTime -- 战斗间隔
local heroWidth = 975
local heroHeight = 283

function CrossGodWarWatchBattleDialog:ctor(param)
    CrossGodWarWatchBattleDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._getStateCallback = param.callback1
    self._enterBattleCallback = param.callback2
    self.popAnim = false
    self._stakeInfo = param.stakeInfo
    self._tabIndex = param.tabIndex
end

function CrossGodWarWatchBattleDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("crossGod.CrossGodWarWatchBattleDialog")
        end
        self:close()
    end)  

    self._userModel = self._modelMgr:getModel("UserModel")
    self._crossGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
    self._subTime = 0
    self._leftNumber = 0
    self._rightNumber = 0

    local jieduanLab = self:getUI("bg.jieduanLab")
    jieduanLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local jieduanTime = self:getUI("bg.jieduanTime")
    jieduanTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._powImg = self:getUI("bg.layerBg.battleBg.powImg")

    self:setUI()
    self:realTimeData()
    self:listenReflash("CrossGodWarModel", self.updateData)

    self:closeDialogView()
    self:updateReviewBtn()
    -- 弹幕 -- 从godwar 拷贝

    self._updateId = ScheduleMgr:regSchedule(5000, self, function(self, dt)
        self:updateRewards(dt)
    end)
end

function CrossGodWarWatchBattleDialog:updateData()
    -- ScheduleMgr:delayCall(5000, self, function()
    --     if self.updateUIData then
    --         self:updateUIData()
    --     end
    -- end)
end

-- 更新玩家 fans 数量 and 支持数
function CrossGodWarWatchBattleDialog:updateRewards( dt )
    local chang,powId,ju = self._crossGodWarModel:getPowIdAndChang(self._tabIndex)
    self._serverMgr:sendMsg("CrossGodWarServer", "getStakeInfo", {pow = powId,round = ju}, true, {},  function(result)
        self._stakeInfo = result
        self:updateUIData()
    end)
end

function CrossGodWarWatchBattleDialog:realTimeData()
    if self.updateUIData then
        self:updateUIData()
    end
end

function CrossGodWarWatchBattleDialog:updateUIData()
    local chang,powId,ju = self._crossGodWarModel:getPowIdAndChang(self._tabIndex)

    local godWar = self._crossGodWarModel:getEliminateFightData()

    local roundLab = self:getUI("bg.roundLab")
    roundLab:setString(chang)

    local warData
    if godWar and godWar[powId] then
        warData = godWar[powId][ju]
    end
    if not warData then
        -- self:close()
        return
    end
    dump(warData)
    local boBattle = self:getUI("bg.boBattle")
    boBattle:setVisible(true)

    print("chang=======", chang)
    if warData then
        local atkData = warData.player1
        local defData = warData.player2

        local leftPanel = self:getUI("bg.leftPanel")
        self:updateLeftPanel(leftPanel, atkData, false, warData, defData, powId)

        local rightPanel = self:getUI("bg.rightPanel")
        self:updateRightPanel(rightPanel, defData, true, warData, atkData, powId)

        self:updateZhichi()

        local flag = self:isStakeFight()
        print("false==========", flag)
        self:supportAndFight(flag)

        local jieduanLab = self:getUI("bg.jieduanLab")
        jieduanLab:setPositionX(253)
        jieduanLab:setVisible(true)
        local jieduanTime = self:getUI("bg.jieduanTime")
        local callFunc = cc.CallFunc:create(function()

            local curServerTime = self._userModel:getCurServerTime()
            local state,endTime,tabIndex = self._getStateCallback()
            local daojishi = endTime - curServerTime

            local flag = self:isStakeFight()
            -- print("flag==========", flag)
            self:supportAndFight(flag)

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

function CrossGodWarWatchBattleDialog:updateLeftPanel(inView, data, fan, warData, enemyData, powId)
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
    local pnumber = self:getUI("bg.leftPanel.zhichiBg.pnumber")
    if pnumber then
        pnumber:setString(self._stakeInfo.atkStakeCount)
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
        local param = {avatar = data.avatar, level = data.lvl, tp = 4, avatarFrame = data["avatarFrame"], plvl = data.plvl}
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

        -- self:registerClickEvent(icon, function()
        --     local data = {tagId = data.rid, fid = 101}
        --     self:getTargetUserBattleInfo(data)
        -- end)
    end

    -- warData.rate
    local winAward = inView:getChildByFullName("winAward")
    if winAward then
        -- local rateBase = tab:Setting("CROSS_FIGHT_RATIO_L")["value"]
        -- local rate = tab:Setting("CROSS_FIGHT_RATIO_U")["value"]
        -- local totalZC = self._stakeInfo.atkStakeCount + self._stakeInfo.defStakeCount
        -- local num = self._stakeInfo.atkStakeCount ~= 0 and self._stakeInfo.atkStakeCount or 1
        -- local rateNum =  math.floor((totalZC/num)*(1+rate/100)*rateBase)
        winAward:setString(self._stakeInfo.atkStakeOdds)
    end

    local zhichiImg = inView:getChildByFullName("zhichiImg")
    zhichiImg:setVisible(false)
    if not self._stakeInfo.haveStaked or self._stakeInfo.haveStaked == 0 then
        zhichiImg:loadTexture("godwarImageUI_img252.png", 1)
    elseif self._stakeInfo.haveStaked == 1 then
        zhichiImg:loadTexture("godwarImageUI_img254.png", 1)
        zhichiImg:setVisible(true)
    elseif self._stakeInfo.haveStaked == 2 then
        zhichiImg:loadTexture("godwarImageUI_img252.png", 1)
        zhichiImg:setVisible(true)
    end

    local zhichi = inView:getChildByFullName("zhichi")
    if zhichi then
        self:registerClickEvent(zhichi, function()
            local flag = self:isStakeFight()
            if flag ~= 0 then
                self._viewMgr:showTip("已结支持过选手")
                return
            end
            local chang, ju, powId = self._getStateCallback()
            local to = 1
            if fan == true then
                to = 2
            end
            local param = {to = to}
            self:stakeFight(param, warData)
        end)
    end
end

-- 1 不能战斗也不能支持
-- 2 可以战斗
-- 3 可以支持
function CrossGodWarWatchBattleDialog:supportAndFight(supportType)
    local lzhichiBtn = self:getUI("bg.leftPanel.zhichi")
    local rzhichiBtn = self:getUI("bg.rightPanel.zhichi")
    lzhichiBtn:setVisible(supportType==0)
    rzhichiBtn:setVisible(supportType==0)
end

function CrossGodWarWatchBattleDialog:reflashUI()
    self:updateUIData()
end
function CrossGodWarWatchBattleDialog:updateRightPanel(inView, data, fan, warData, enemyData, powId)
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
    local pnumber = self:getUI("bg.rightPanel.zhichiBg.pnumber")
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
        local param = {avatar = data.avatar, level = data.lvl, tp = 4, avatarFrame = data["avatarFrame"], plvl = data.plvl}
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

        -- self:registerClickEvent(icon, function()
        --     local data = {tagId = data.rid, fid = 101}
        --     self:getTargetUserBattleInfo(data)
        -- end)
    end

    local zhichiImg = inView:getChildByFullName("zhichiImg")
    zhichiImg:setVisible(false)
    if not self._stakeInfo.haveStaked or self._stakeInfo.haveStaked == 0 then
        zhichiImg:loadTexture("godwarImageUI_img253.png", 1)
        zhichiImg:setVisible(false)
    elseif self._stakeInfo.haveStaked == 1 then
        zhichiImg:loadTexture("godwarImageUI_img253.png", 1)
        zhichiImg:setVisible(true)
    elseif self._stakeInfo.haveStaked == 2 then
        zhichiImg:loadTexture("godwarImageUI_img251.png", 1)
        zhichiImg:setVisible(true)
    end

    if winAward then
        -- local rateBase = tab:Setting("CROSS_FIGHT_RATIO_L")["value"]
        -- local rate = tab:Setting("CROSS_FIGHT_RATIO_U")["value"]
        -- local totalZC = self._stakeInfo.atkStakeCount + self._stakeInfo.defStakeCount
        -- local num = self._stakeInfo.defStakeCount ~= 0 and self._stakeInfo.defStakeCount or 1
        -- local rateNum =  math.floor((totalZC/num)*(1+rate/100)*rateBase)
        -- defStakeOdds 这个不是赔率  是粉丝卷数量
        winAward:setString(self._stakeInfo.defStakeOdds)
    end

    if zhichi then
        self:registerClickEvent(zhichi, function()
            local flag = self:isStakeFight()
            if flag ~= 0 then
                self._viewMgr:showTip("已经支持过选手")
                return
            end
            local to = 1
            if fan == true then
                to = 2
            end
            local param = {to = to}
            self:stakeFight(param, warData)
        end)
    end
end

function CrossGodWarWatchBattleDialog:updateZhichi()
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()
    local timer = curServerTime - userData.sec_open_time
    local opennum = math.floor(timer/86400)
    local callFunc = cc.CallFunc:create(function()
        local atkNum = self:getZhichiNum(true)
        local defNum = self:getZhichiNum(false)
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

function CrossGodWarWatchBattleDialog:getZhichiNum(isAtk)

    local sumNum = self._stakeInfo.atkStakeCount
    if not isAtk  then
        sumNum = self._stakeInfo.defStakeCount
    end
    return sumNum
end

function CrossGodWarWatchBattleDialog:stakeFight(param, warData)
    if not param then
        return
    end
    self._serverMgr:sendMsg("CrossGodWarServer","stakeFight",param,true,{},function( result )
        dump(warData,"warData==========")
        self._stakeInfo.haveStaked = param.to
        local zhichi = self:getUI("bg.leftPanel.zhichiImg")
        local pnumber = self:getUI("bg.leftPanel.zhichiBg.pnumber")  
        local tnumber = self._leftNumber + 1
        if param.to == 2 then
            zhichi = self:getUI("bg.rightPanel.zhichiImg")
            pnumber = self:getUI("bg.rightPanel.zhichiBg.pnumber")   
            tnumber = self._rightNumber + 1
        end
        -- if self._updateDirectTip then
        --     self._updateDirectTip(warData)
        -- end
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

-- 0 没有支持  1 left  2 right
function CrossGodWarWatchBattleDialog:isStakeFight()
    return self._stakeInfo.haveStaked
end

function CrossGodWarWatchBattleDialog:getTargetUserBattleInfo(param)
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result) 
        self._viewMgr:showDialog("godwar.GodwarUserInfoDialog", result, true)
    end)
end

-- 根据时间关闭界面
function CrossGodWarWatchBattleDialog:closeDialogView()
    local saiTimeLab = self:getUI("bg.saiTimeLab")
    local curServerTime = self._userModel:getCurServerTime()
    local state,endTime,tabIndex = self._getStateCallback()
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local cTime = endTime - curServerTime
        if cTime <= 0  then
            if self.close then
                self:close()
                if self._enterBattleCallback then
                    self._enterBattleCallback()
                end
            end
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    saiTimeLab:runAction(cc.RepeatForever:create(seq))
end

function CrossGodWarWatchBattleDialog:doPop(callback)
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

function CrossGodWarWatchBattleDialog:close(noAnim, callback)
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

function CrossGodWarWatchBattleDialog:setUI()

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

end

function CrossGodWarWatchBattleDialog:updateReviewBtn( )
    local reviewBtn1 = self:getUI("bg.layerBg.reviewBtn1")
    local reviewBtn2 = self:getUI("bg.layerBg.reviewBtn2")
    reviewBtn1:setVisible(false)
    reviewBtn2:setVisible(false)
end


function CrossGodWarWatchBattleDialog.dtor()

end

return CrossGodWarWatchBattleDialog