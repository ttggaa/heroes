--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-24 15:37:26
--
local HeroDuelForbiddenView = class("HeroDuelForbiddenView", BasePopView)

local CARD_WIDTH = 260
local CARD_HEIGHT = 163
function HeroDuelForbiddenView:ctor(data)
    HeroDuelForbiddenView.super.ctor(self)

    self._matchData = nil

    self._hModel = self._modelMgr:getModel("HeroDuelModel")

    self._teamCellList = {}
    self._selectedList = {}

    self._myCardsList = {}
    self._enemyCardsList = {}

    self._myHadBanned = {}
    self._enemyHadBanned = {}

    self._maxSelctCount = 1

    self.popAnim = false

    self._errorCallBack = data.callback
end

function HeroDuelForbiddenView:getBgName()
    return "heroDuelBg.jpg"
end

function HeroDuelForbiddenView:onInit()
    self._matchData = self._hModel:getRoomData()
    self._myData = self._matchData["self"]
    self._rivalData = self._matchData["rival"]
    self._commonData = self._matchData["common"]

    local titleNode = self:getUI("bg.titleNode")
    self._leftState = titleNode:getChildByFullName("leftState")
    self._rightState = titleNode:getChildByFullName("rightState")

    self._myTimeLabel = self._leftState:getChildByFullName("tLabel")
    self._myTimeLabel:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    self._myTimeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._rivalLabel = self._rightState:getChildByFullName("tLabel")
    self._rivalLabel:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
    self._rivalLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._titleLabel = titleNode:getChildByFullName("titleLabel")
    UIUtils:setTitleFormat(self._titleLabel, 1)

--    self:registerClickEventByName("bg.titleNode", function()
--        self:close()
--        UIUtils:reloadLuaFile("heroduel.HeroDuelForbiddenView")
--    end )
    
    if self._commonData.stepInfo then
        self._maxSelctCount = self._commonData.stepInfo.num or 1
    else
        self._maxSelctCount = 1
    end
    self._desLabel = self:getUI("bg.layer.desLabel")
    self._desLabel:setColor(cc.c3b(253, 237, 167))
    self._desLabel:setString("本次可以禁用" .. self._maxSelctCount .. "个兵团")

    self._confirmBtn = self:getUI("bg.layer.confirmBtn")
    self:registerClickEvent(self._confirmBtn, specialize(self.confirmSelect, self))

    self._desLabel2 = self:getUI("bg.layer.desLabel2")
    self._desLabel2:setColor(cc.c3b(253, 237, 167))
    self._desLabel2:setString("对方正在禁用兵团，请耐心等待")

    local myCardNode = self:getUI("bg.layer.myCardNode")
    myCardNode:setPositionY(-(MAX_SCREEN_HEIGHT-MAX_DESIGN_HEIGHT)*0.5)
    local myTeamTxt = myCardNode:getChildByFullName("myTeamTxt")
    myTeamTxt:setString("我的战队")
    myTeamTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    myTeamTxt:setPositionY(MAX_SCREEN_HEIGHT - 22)

    self._myScrollView = myCardNode:getChildByFullName("myScrollView")
    self._myScrollView:setClippingType(1)
    self._myScrollView:setContentSize(myCardNode:getContentSize().width, MAX_SCREEN_HEIGHT - 37)

    local enemyCardNode = self:getUI("bg.layer.enemyCardNode")
    enemyCardNode:setPositionY(-(MAX_SCREEN_HEIGHT-MAX_DESIGN_HEIGHT)*0.5)
    local enemyTeamTxt = enemyCardNode:getChildByFullName("enemyTeamTxt")
    enemyTeamTxt:setString("对方战队")
    enemyTeamTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    enemyTeamTxt:setPositionY(MAX_SCREEN_HEIGHT - 22)

    self._enemyScrollView = enemyCardNode:getChildByFullName("enemyScrollView")
    self._enemyScrollView:setClippingType(1)
    self._enemyScrollView:setContentSize(enemyCardNode:getContentSize().width, MAX_SCREEN_HEIGHT - 37)
    self._enemyScrollView:setPositionX(8)

    self._teamNode = self:getUI("bg.layer.teamNode")
    self._maskNode = self._teamNode:getChildByFullName("maskNode")

    self._forbiddenData = self._commonData.bannable

    self._teamsData = self._hModel:getCardsInfo().teams
    table.sort(self._teamsData, function(a,b)
        local tDataA = tab:Team(a.id)
        local tDataB = tab:Team(b.id)
        if tDataA.zizhi ~= tDataB.zizhi then
            return tDataA.zizhi > tDataB.zizhi
        else
            return tDataA.id < tDataB.id
        end
    end)

    local offsetX = 77
    local offsetY = 357
    local spaceW = 105
    local spaceH = 100
    for i = 1, #self._forbiddenData do
        local teamId = self._forbiddenData[i]
        local teamCell = self:createTeamCell(teamId, 1)
        teamCell:setPosition((i-1)%4*spaceW+offsetX, offsetY-math.floor((i-1)/4)*spaceH)
        teamCell.index = i
        teamCell.id = teamId
        self._teamNode:addChild(teamCell)
        table.insert(self._teamCellList, teamCell)

        self:registerClickEvent(teamCell, specialize(self.onClickCell, self))
    end


    self:addToScrollView(self._myScrollView, self._myCardsList, self._teamsData, "my")
    self:addToScrollView(self._enemyScrollView, self._enemyCardsList, {}, "enemy")


    self._prepareNode = self:getUI("bg.prepareNode")
    self._prepareNode:setBackGroundColorOpacity(128)
    self._prepareNode:setBackGroundColor(cc.c3b(0,0,0))
    self._prepareNode:setBackGroundColorType(1)
    self._prepareNode:setVisible(false)

    local textBg = self._prepareNode:getChildByFullName("textBg")
    textBg:setPosition(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5-5)

    local prepareDes = self._prepareNode:getChildByFullName("textBg.prepreDes")
    prepareDes:setColor(cc.c3b(254, 255, 221))
    prepareDes:enable2Color(1, cc.c4b(253, 190, 77, 255))

    self:reflashUI()

    self:setListenReflashWithParam(true)
    self:listenReflash("HeroDuelModel", self.onModelReflash)
    self:listenRSResponse(specialize(self.onSocektResponse, self))

    self:sendSocketMgs("teamBanReady")
end

function HeroDuelForbiddenView:reflashUI()
    self:resetData()

    self._maxSelctCount = self._commonData.stepInfo.num or 1
    self._desLabel:setString("本次可以禁用" .. self._maxSelctCount .. "个兵团")

    -- 公共区域禁用
    if self._commonData.banned ~= nil then
        for banI = 1, #self._commonData.banned do
            for cellI = 1, #self._teamCellList do
                if self._teamCellList[cellI].id == self._commonData.banned[banI] then
                    self:forbiddenTeamCell(self._teamCellList[cellI])
                    break
                end 
            end
        end
    end

    -- 我方被禁
    if self._myData.banned ~= nil then
        local bannedList = self:getNewBanned(self._myData.banned, self._myHadBanned)

        if #bannedList > 0 then
            self._myScrollView:jumpToTop()
        end

        for banI = 1, #bannedList do
            local cellList = self._myCardsList
            local teamId = bannedList[banI]
            for cellI = 1, #cellList do
                if cellList[cellI].teamId == teamId and cellList[cellI].state ~= "forbidden"  then
                    table.insert(self._myHadBanned, teamId)
                    self:popCardCell(self._myScrollView, cellI)
                    break
                end 
            end
        end
    end

    -- 敌方被禁
    if self._rivalData.banned ~= nil then
        local bannedList = self:getNewBanned(self._rivalData.banned, self._enemyHadBanned)

        if #bannedList > 0 then
            self._enemyScrollView:jumpToTop()
        end

        for banI = 1, #bannedList do
            local cellList = self._enemyScrollView:getChildren()
            local teamId = bannedList[banI]
            for cellI = 1, #cellList do
                if cellList[cellI].state ~= "forbidden" then
                    table.insert(self._enemyHadBanned, teamId)
                    self:overTurnCardCell(cellList[cellI], teamId)
                    break
                end 
            end
        end
    end

    if self._myData.banOp.turn == 0 then

        self:updateTitleLabel("对手回合")

        self._confirmBtn:setVisible(false)
        self._desLabel2:setVisible(true)

        self._maskNode:setVisible(true)

        if  self._commonData.stepInfo ~= nil and
            self._commonData.stepInfo.time ~= nil and
            self._commonData.stepInfo.time > 0
        then
            self._countDownTime = self:getLeftTime(self._commonData.stepInfo.lot, self._commonData.stepInfo.time)
            self._realPerTime = self._commonData.stepInfo.time / self._commonData.stepInfo.ptime
            self._rivalLabel:setString(tostring(math.round(self._countDownTime / self._realPerTime)))

            self:startCountDown(specialize(self.rivalTurnCountDown, self))

        else 
            self._rivalLabel:setString("等待中")
        end

        self._myTimeLabel:setString("等待中")

        for i = 1, #self._teamCellList do
            if self._teamCellList[i].state ~= "forbidden" then
                self:waitTeamCell(self._teamCellList[i])
            end
        end

    elseif self._myData.banOp.turn == 1 then
        if self._maxSelctCount == 0 then

--            self:updateTitleLabel("等待中")
            self._titleLabel:setString("等待中")

            self._myTimeLabel:setString("等待中")
            self._rivalLabel:setString("等待中")

            self._confirmBtn:setVisible(false)
            self._desLabel2:setVisible(false)

            self._maskNode:setVisible(true)

            for i = 1, #self._teamCellList do
                if self._teamCellList[i].state ~= "forbidden" then
                    self:waitTeamCell(self._teamCellList[i])
                end
            end

        else
            self:updateTitleLabel("我的回合")

            self._confirmBtn:setVisible(true)
            self._desLabel2:setVisible(false)

            self._maskNode:setVisible(false)

            if  self._commonData.stepInfo ~= nil and
                self._commonData.stepInfo.time ~= nil and
                self._commonData.stepInfo.time > 0
            then
                self._countDownTime = self:getLeftTime(self._commonData.stepInfo.lot, self._commonData.stepInfo.time)
                self._realPerTime = self._commonData.stepInfo.ptime / self._commonData.stepInfo.ptime
                self._myTimeLabel:setString(tostring(math.round(self._countDownTime / self._realPerTime)))

                self:startCountDown(specialize(self.myTurnCountDown, self))
            else
                self._myTimeLabel:setString("等待中")
            end

            self._rivalLabel:setString("等待中")


            for i = 1, #self._teamCellList do
                if self._teamCellList[i].state ~= "forbidden" then
                    self:resetTeamCell(self._teamCellList[i])
                end
            end
        end

    elseif self._myData.banOp.turn == 2 then
        self:updateTitleLabel("准备布阵")

        self._myTimeLabel:setString("等待中")
        self._rivalLabel:setString("等待中")

        self._confirmBtn:setVisible(false)
        self._desLabel2:setVisible(false)

        self:gotoFormation()
    end
end

function HeroDuelForbiddenView:updateTitleLabel(str)
    self._titleLabel:stopAllActions()
    self._titleLabel:setString(str)
    local titleGhost = self._titleLabel:clone()
    titleGhost:setVisible(false)
    self._titleLabel:getParent():addChild(titleGhost)
    self._titleLabel:setScale(2)
    self._titleLabel:setOpacity(50)
    self._titleLabel:runAction(cc.Sequence:create(
        cc.Spawn:create(cc.EaseOut:create(cc.ScaleTo:create(0.1, 3),3), cc.FadeIn:create(0.01)),
        cc.EaseIn:create(cc.ScaleTo:create(0.1, 0.9),3),
        cc.ScaleTo:create(0.1, 1),
        cc.CallFunc:create(function()
            titleGhost:setVisible(true)
            titleGhost:runAction(
                cc.Sequence:create(
                    cc.Spawn:create(cc.ScaleTo:create(0.1, 1.5), cc.FadeOut:create(0.1)),
                    cc.CallFunc:create(function()
                        titleGhost:stopAllActions()
                        titleGhost:removeFromParent(true)
                    end)
                )
            )
        end)
    ))
end


-- 添加卡牌信息
function HeroDuelForbiddenView:addToScrollView(scrollView, cardsList, tData, isMine)
    local cellW, cellH = CARD_WIDTH, CARD_HEIGHT
    local spaceH = -52
    local cellNum = 16
    local innerH = cellNum * cellH + (cellNum - 1) * spaceH
    local innerW = cellW
    scrollView:setInnerContainerSize(cc.size(innerW, innerH))
    scrollView:setBounceEnabled(true)

    for i = 1, 16 do
        local teamId = isMine == "my" and tData[i].id or nil
        local cell = self:createCardCell(teamId, isMine)
        cell.teamId = teamId
        cell:setPosition(cellW*0.5, innerH-((i*cellH)+(i-1)*spaceH)+cellH*0.5)
        cell:setFlippedX(isMine == "enemy")
        scrollView:addChild(cell, 1)
        table.insert(cardsList, cell)
    end
end

-- 创建卡牌
function HeroDuelForbiddenView:createCardCell(id, isMine)
    local cardbg = ccui.Layout:create()
	cardbg:setAnchorPoint(0.5, 0.5)
    cardbg:setBackGroundColorOpacity(0)
    cardbg:setBackGroundColorType(1)
    cardbg:setBackGroundColor(cc.c3b(255,255,255))
    cardbg:setContentSize(CARD_WIDTH, CARD_HEIGHT)
    cardbg:setName("cardbg")

    local centerx, centery = CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5

    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(-2,-3)
    local mask = cc.Sprite:createWithSpriteFrameName("img_cardMask2_heroDuel.png")
    mask:setPosition(centerx, centery)
    mask:setScaleY(0.95)
--    clipNode:setInverted(true)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.9)
    clipNode:setName("clipNode")
    cardbg:addChild(clipNode, 1)


    if isMine == "my" then
        local teamD = tab:Team(id)
        local race = teamD["race"][1]
        cardbg.teamId = id

--        local bg = cc.Sprite:create("asset/uiother/card/card_bg_" .. race .. ".jpg")
--        bg:setPosition(centerx - 9, centery - 13)
--        bg:setName("bg")

    
        local lihui = teamD["heroDuelIm"]
        local cardoffset = teamD["card"]

        if self._hModel:isTeamJx(id) then
            lihui = "cta_" .. string.sub(lihui, 4)
        end

 	    local roleSp = cc.Sprite:create("asset/uiother/cteam/"..lihui..".jpg")
        roleSp:setPosition(centerx + teamD["heroDuelco"][1], centery + teamD["heroDuelco"][2])
        roleSp:setScale(1.2)
--        roleSp:setPosition(teamD["heroDuelco"][1], teamD["heroDuelco"][2])
--        roleSp:setScale(teamD["heroDuelco"][3])
        roleSp:setName("roleSp")
        cardbg.picName = "asset/uiother/cteam/ct_"..id..".jpg"

--        clipNode:addChild(bg)
        clipNode:addChild(roleSp)

        local shadow = cc.Sprite:createWithSpriteFrameName("img_cardMask1_heroDuel.png")
        shadow:setPosition(centerx, centery-4)
        cardbg:addChild(shadow, 2)

        local classIcon = cc.Sprite:createWithSpriteFrameName(teamD.classlabel .. ".png")
        classIcon:setPosition(230, 92)
        classIcon:setName("classIcon")
        classIcon:setScale(38/classIcon:getContentSize().width)
        cardbg:addChild(classIcon, 2)

    else
        local cardBack = cc.Sprite:createWithSpriteFrameName("img_cardBack_heroDuel.png")

        if MAX_SCREEN_WIDTH < 1042 then
	        cardBack:setPosition(centerx + 42 , centery - 8)
        else
	        cardBack:setPosition(centerx, centery)
        end
        cardBack:setFlippedX(true)
        clipNode:addChild(cardBack)
    end


    local zhaozi = cc.Sprite:createWithSpriteFrameName("img_cardBorder_heroDuel.png")
	zhaozi:setPosition(centerx, centery)
    cardbg:addChild(zhaozi, 2)

    local blackMask = cc.Sprite:createWithSpriteFrameName("img_cardMask2_heroDuel.png")
	blackMask:setPosition(centerx, centery-4)
    blackMask:setName("mask")
    blackMask:setVisible(false)
    blackMask:setOpacity(100)
	cardbg:addChild(blackMask, 3)

    local icon = cc.Sprite:createWithSpriteFrameName("img_yiJinYong_heroDuel.png")
    icon:setPosition(centerx, centery - 10)
    icon:setFlippedX(isMine == "enemy")
    icon:setName("forbiddenIcon")
    icon:setVisible(false)
    cardbg:addChild(icon, 4)

    return cardbg
end

-- 我方卡牌移到顶部
function HeroDuelForbiddenView:popCardCell(scrollView, index)
    local popCell = self._myCardsList[index]
--    popCell:setVisible(false)
    popCell:setPositionY(self._myCardsList[1]:getPositionY())

    for i = 1, #self._myCardsList do
        if i < index then
            self._myCardsList[i]:setPositionY(self._myCardsList[i]:getPositionY() - 111)
        end
    end
    table.remove(self._myCardsList, index)
    table.insert(self._myCardsList, 1, popCell)

    for i = 1, #self._myCardsList do
        self._myCardsList[i]:setLocalZOrder(i)
    end
    self:addForbiddenIconToCard(popCell)
end

-- 翻开敌方卡牌
function HeroDuelForbiddenView:overTurnCardCell(inview, id)
    local teamD = tab:Team(id)
    local race = teamD["race"][1]
    inview.teamId = id

    local updateFunc = function()
        local lihui = teamD["heroDuelIm"]
        local cardoffset = teamD["card"]

        if self._hModel:isTeamJx(id) then
            lihui = "cta_" .. string.sub(lihui, 4)
        end

 	    local roleSp = cc.Sprite:create("asset/uiother/cteam/"..lihui..".jpg")
        roleSp:setPosition(CARD_WIDTH * 0.5 + teamD["heroDuelco"][1], CARD_HEIGHT * 0.5 + teamD["heroDuelco"][2])
        roleSp:setScale(1.2)
--        roleSp:setPosition(teamD["heroDuelco"][1], teamD["heroDuelco"][2])
--        roleSp:setScale(teamD["heroDuelco"][3])
        roleSp:setName("roleSp")
        inview.picName = "asset/uiother/cteam/ct_"..id..".jpg"

        local clipNode = inview:getChildByName("clipNode")
--        clipNode:addChild(bg)
        clipNode:addChild(roleSp)

        local classIcon = cc.Sprite:createWithSpriteFrameName(teamD.classlabel .. ".png")
        classIcon:setPosition(230, 92)
        classIcon:setName("classIcon")
        classIcon:setFlippedX(true)
        classIcon:setScale(38/classIcon:getContentSize().width)
        inview:addChild(classIcon, 2)

        local shadow = cc.Sprite:createWithSpriteFrameName("img_cardMask1_heroDuel.png")
        shadow:setPosition(CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5-4)
        inview:addChild(shadow, 2)

        local blackZhao = cc.Sprite:createWithSpriteFrameName("img_cardMask2_heroDuel.png")
	    blackZhao:setPosition(CARD_WIDTH * 0.5, CARD_HEIGHT * 0.5-4)
        blackZhao:setOpacity(100)
        inview:addChild(blackZhao, 2)
    end

    inview.state = "forbidden"
    inview:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1, 0), 
        cc.CallFunc:create(updateFunc),
        cc.ScaleTo:create(0.05, 1, 1),
        cc.CallFunc:create(specialize(self.addForbiddenIconToCard, self, inview))
        ))
end


function HeroDuelForbiddenView:addForbiddenIconToCard(inview)
    inview.state = "forbidden"
    inview:getChildByName("mask"):setVisible(true)
    inview:getChildByName("forbiddenIcon"):setVisible(true)
end


function HeroDuelForbiddenView:onModelReflash(eventName)
    if eventName == self._hModel.ROOM_UPDATE or (eventName == self._hModel.FORMATION and not self._hasGoFormation) then  
        self._matchData = self._hModel:getRoomData()
        self._myData = self._matchData["self"]
        self._rivalData = self._matchData["rival"]
        self._commonData = self._matchData["common"]
        self:reflashUI()
                        
    elseif eventName == self._hModel.BATTLE_END_EVENT and not self._hasResult then
--        print("*********************** onModelReflash")

        self:onBattleResult()
    end
end

-- 重置状态
function HeroDuelForbiddenView:resetData()
    self:closeCountDown()
    self._selectedList = {}
end

-- 办卡倒计时
function HeroDuelForbiddenView:myTurnCountDown()
--    self._countDownTime = self._countDownTime - 1
--    self._myTimeLabel:setString(tostring(self._countDownTime))

    self._countDownTime = self:getLeftTime(self._commonData.stepInfo.lot, self._commonData.stepInfo.ptime)
    local leftTime = math.round(self._countDownTime / self._realPerTime)
    if tostring(leftTime) ~= self._myTimeLabel:getString() then
        self._myTimeLabel:setString(tostring(leftTime))
    end
    
    if self._countDownTime <= 0 and self._isInBackGround ~= true then
        self:closeCountDown()

        ScheduleMgr:nextFrameCall(self, function()
            -- 从后台回到前台，若本局已结束，将不自动BAN卡
            if self._hModel:gethDuelState() ~= nil and self._hModel:gethDuelState() < self._hModel.BATTLE_END then
                self:autoSelect()
            end
        end)
    end
end

-- 等待倒计时（敌方办卡）
function HeroDuelForbiddenView:rivalTurnCountDown()
    self._countDownTime = self:getLeftTime(self._commonData.stepInfo.lot, self._commonData.stepInfo.time)
    local leftTime = math.round(self._countDownTime / self._realPerTime)
    if tostring(leftTime) ~= self._rivalLabel:getString() then
        self._rivalLabel:setString(tostring(leftTime))
    end
    
    if self._countDownTime <= 0 and self._isInBackGround ~= true then
        self:closeCountDown()
    end
end

-- 开始倒计时
function HeroDuelForbiddenView:startCountDown(timerFunc)
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end

    self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        timerFunc(dt)
    end, 0, false)

--    self.timer = ScheduleMgr:regSchedule(1000 * self._realPerTime,self,function( )
--        timerFunc()
--    end)
end

-- 关闭倒计时
function HeroDuelForbiddenView:closeCountDown()
    if self.timer then
        ScheduleMgr:unregSchedule(self.timer)
        self.timer = nil
    end
end

-- 创建兵团CEll
-- @param teamId 兵团ID
-- @param tp CELL类型 1:选择中  2:等待中
function HeroDuelForbiddenView:createTeamCell(teamId, tp)
    local realWidth, realHeight = 100, 100
    local cellW, cellH = 108, 108
    local cell = ccui.Widget:create()
    cell:setContentSize(cc.size(realWidth, realWidth))
    cell:setAnchorPoint(cc.p(0.5,0.5))
    cell:setScaleAnim(true)

    local iconNode = cc.Node:create()
    iconNode:setContentSize(cc.size(cellW, cellH))
    iconNode:setName("iconNode")
    iconNode:setPosition(0, 0)
    cell:addChild(iconNode)

    local pathKey = "art1"
    if self._hModel:isTeamJx(teamId) then
        pathKey = "jxart1"
    end

    local sysTeam = tab:Team(tonumber(teamId))
    local filename = IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(sysTeam, pathKey) .. ".jpg"
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(filename) then
        filename = IconUtils.iconPath .. TeamUtils.getNpcTableValueByTeam(sysTeam, pathKey) .. ".png"
    end

    local teamIcon = cc.Sprite:createWithSpriteFrameName(filename)
    teamIcon:setPosition(cellW*0.5, cellH*0.5)
    iconNode:addChild(teamIcon)

    local border = cc.Sprite:createWithSpriteFrameName("globalImageUI4_squality5.png")
    border:setPosition(cellW*0.5, cellH*0.5)
    iconNode:addChild(border)

    local classIcon = cc.Sprite:createWithSpriteFrameName(sysTeam.classlabel .. ".png")
    classIcon:setPosition(classIcon:getContentSize().width*0.5+4,cellH-classIcon:getContentSize().height*0.5-4)
    classIcon:setScale(0.88)
    iconNode:addChild(classIcon)

    if self:hasCard(teamId) then
        local haveIcon = cc.Sprite:createWithSpriteFrameName("icon_have_heroDuel.png")
        haveIcon:setPosition(cellW*0.5, classIcon:getContentSize().height*0.5)
        iconNode:addChild(haveIcon)
    end

    local selectFrame = cc.Sprite:createWithSpriteFrameName("globalImageUI4_selectFrame.png")
    selectFrame:setVisible(false)
    selectFrame:setName("selectFrame")
    selectFrame:setPosition(cellW*0.5, cellH*0.5)
    iconNode:addChild(selectFrame)

    iconNode:setScale(realWidth/cellW)

    if tp == 1 then
        local checkBoxBg = cc.Sprite:createWithSpriteFrameName("bg_checkBox_heroDuel.png")
        checkBoxBg:setPosition(realWidth-20, realHeight-20)
        checkBoxBg:setName("checkBoxBg")
        cell:addChild(checkBoxBg)

        local selectIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI7_checkbox_p.png")
        selectIcon:setScale(0.65)
        selectIcon:setPosition(realWidth-12, realHeight-16)
        selectIcon:setName("selectIcon")
        selectIcon:setVisible(false)
        cell:addChild(selectIcon)
    end

    local forbiddenIcon = cc.Sprite:createWithSpriteFrameName("img_yiJinYong_heroDuel.png")
    forbiddenIcon:setPosition(realWidth*0.5, realHeight*0.5)
    forbiddenIcon:setScale(0.77)
    forbiddenIcon:setName("forbiddenIcon")
    forbiddenIcon:setVisible(false)
    cell:addChild(forbiddenIcon)

    return cell
end

-- 兵团CELL重置为未选中状态
function HeroDuelForbiddenView:resetTeamCell(tCell)
    tCell.state = nil

    local iconNode = tCell:getChildByName("iconNode")
    iconNode:setBrightness(0)
    iconNode:getChildByName("selectFrame"):setVisible(false)
    tCell:getChildByName("forbiddenIcon"):setVisible(false)

    local selectIcon = tCell:getChildByName("selectIcon")
    if selectIcon then
        selectIcon:setVisible(false)
        tCell:getChildByName("checkBoxBg"):setVisible(true)
    end

    tCell:setTouchEnabled(true)
end

-- 兵团CELL设置为选中状态
function HeroDuelForbiddenView:selectTeamCell(tCell)
    tCell.state = "selected"

    local iconNode = tCell:getChildByName("iconNode")
    iconNode:getChildByName("selectFrame"):setVisible(true)

    local selectIcon = tCell:getChildByName("selectIcon")
    if selectIcon then
        selectIcon:setVisible(true)
        tCell:getChildByName("checkBoxBg"):setVisible(true)
    end

    tCell:setTouchEnabled(true)
end

-- 兵团CELL设置为禁用状态
function HeroDuelForbiddenView:forbiddenTeamCell(tCell)
    tCell.state = "forbidden"

    local iconNode = tCell:getChildByName("iconNode")
    iconNode:setBrightness(-50)
    iconNode:getChildByName("selectFrame"):setVisible(false)
    tCell:getChildByName("forbiddenIcon"):setVisible(true)

    local selectIcon = tCell:getChildByName("selectIcon")
    if selectIcon then
        selectIcon:setVisible(false)
        tCell:getChildByName("checkBoxBg"):setVisible(false)
    end

    tCell:setTouchEnabled(false)
end

-- 兵团CELL设置为等待状态
function HeroDuelForbiddenView:waitTeamCell(tCell)
    local iconNode = tCell:getChildByName("iconNode")
    iconNode:setBrightness(0)
    iconNode:getChildByName("selectFrame"):setVisible(false)
    tCell:getChildByName("forbiddenIcon"):setVisible(false)

    local selectIcon = tCell:getChildByName("selectIcon")
    if selectIcon then
        selectIcon:setVisible(false)
        tCell:getChildByName("checkBoxBg"):setVisible(false)
    end
    tCell:setTouchEnabled(false)
end


function HeroDuelForbiddenView:onClickCell(sender)
    if self._maxSelctCount == 1 then
        for i = 1, #self._teamCellList do
            if self._teamCellList[i].state ~= "forbidden" then
                self:resetTeamCell(self._teamCellList[i])
            end
        end
        self:selectTeamCell(sender)
        self._selectedList = {}
        table.insert(self._selectedList, sender)

    elseif self._maxSelctCount >= 2 then

        if #self._selectedList == 0 then
            self:selectTeamCell(sender)
            table.insert(self._selectedList, sender)

        elseif #self._selectedList < self._maxSelctCount then
            
            for i = 1, #self._selectedList do
                if self._selectedList[i] == sender then
                    self:resetTeamCell(sender)
                    table.remove(self._selectedList, i)
                    return
                end
            end
            self:selectTeamCell(sender)
            table.insert(self._selectedList, sender)

        elseif #self._selectedList == self._maxSelctCount then
            for i = 1, #self._selectedList do
                if self._selectedList[i] == sender then
                    self:resetTeamCell(sender)
                    table.remove(self._selectedList, i)
                    return
                end
            end
        end
    end
end

-- 确认选择
function HeroDuelForbiddenView:confirmSelect()
    local selctParam = {}

    for i = 1, #self._selectedList do
        selctParam["id" .. i] = self._selectedList[i].id
    end

    if #self._selectedList < self._maxSelctCount then
        self._viewMgr:showTip("请选择" .. self._maxSelctCount .. "个兵团")
        return
    end

    self:sendBanTeam(selctParam)
end


-- 倒计时结束，自动选择办卡
function HeroDuelForbiddenView:autoSelect()
    local selctParam = {}

    local keyI = 1
    while #self._selectedList < self._maxSelctCount do
        if self._teamCellList[keyI].state == nil then
            table.insert(self._selectedList, self._teamCellList[keyI])
        end
        keyI = keyI + 1
    end

    for i = 1, #self._selectedList do
        selctParam["id" .. i] = self._selectedList[i].id
    end

    self:sendBanTeam(selctParam)
end

function HeroDuelForbiddenView:sendBanTeam(param)
    self:closeCountDown()

    self:sendSocketMgs("teamBan", param)
end

---- 处理办卡和办卡仲裁返回的数据
--function HeroDuelForbiddenView:updateBanData(result)
--    local resultTy = result["self"].banOp.turn

--    if resultTy > 2 then
--        self:doArbitration(result)
--    else
--        -- 办选房间
--        if result["common"].state == 12000 then
--            if result["self"].banOp.step > self._myData.banOp.step then
--                self._matchData = result
--                self._myData = self._matchData["self"]
--                self._rivalData = self._matchData["rival"]
--                self._commonData = self._matchData["common"]
--                self:reflashUI()
--            end

--        -- 布阵
--        elseif result["common"].state == 13000 then
--            self._matchData = result
--            self._myData = self._matchData["self"]
--            self._rivalData = self._matchData["rival"]
--            self._commonData = self._matchData["common"]
--            self:gotoFormation()

--        -- 战斗中
--        elseif result["common"].state == 14000 then
--            self:onBattle(true)

--        -- 战斗结束
--        elseif result["common"].state == 20000 then
--            self:onBattle(true)

--        end
--    end
--end

---- 执行仲裁结果
--function HeroDuelForbiddenView:doArbitration(result)
--    local resultTy = result["self"].banOp.turn

--    -- 未推送成功情况
--    if resultTy == 1 then
--        self._matchData = result
--        self._myData = self._matchData["self"]
--        self._rivalData = self._matchData["rival"]
--        self._commonData = self._matchData["common"]
--        self:reflashUI()

--    -- 异常导致我方胜利
--    elseif resultTy == 3 then
--        local data = {}
--        data["wins"] = result.d.heroDuel.wins or 0
--        data["seasonWins"] = result.d.heroDuel.seasonWins or 0
--        self._hModel:updateHeroDuelData(data)
--        self._hModel:saveErrorType(3)
--        self:onErrorClose()


--    -- 异常导致我方失败
--    elseif resultTy == 4 then
--        local data = {}
--        data["loses"] = result.d.heroDuel.loses or 0
--        self._hModel:updateHeroDuelData(data)
--        self._hModel:saveErrorType(4)
--        self:onErrorClose()

--    -- 异常导致双方正常退出
--    elseif resultTy == 5 then
--        self._hModel:saveErrorType(5)
--        self:onErrorClose()
--    end
--end

-- 前往布阵前倒计时
function HeroDuelForbiddenView:formationPrepare(callback)
    self._hasGoFormation = true

    self._prepareNode:setVisible(true)
    local countInNum = 3
    local animLab1 = ccui.Text:create()
    animLab1:setFontSize(150)
    animLab1:setFontName(UIUtils.ttfName)
    animLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    animLab1:setPosition(MAX_SCREEN_WIDTH *0.5, MAX_SCREEN_HEIGHT*0.5 + 100)
    animLab1:setString(" ")
    self._prepareNode:addChild(animLab1,99)
    local countMc = mcMgr:createViewMC("daojishi_leagueredian", false, true,function( _,sender )
        -- sender:gotoAndPlay(10)
        sender:stop()
    end,RGBA8888)
    -- countMc:setPlaySpeed(0.5)
    countMc:setPosition(50,100)
    -- countMc:stop()
    animLab1:addChild(countMc,2)
    local animLab2 = animLab1:clone()
    animLab2:setPosition(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT *0.5 + 100)
    animLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    animLab2:setString(" ")
    self._prepareNode:addChild(animLab2,99)
    animLab2:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.Spawn:create(cc.ScaleTo:create(0.2,1.5),cc.FadeTo:create(0.2,180)),
                cc.Spawn:create(cc.ScaleTo:create(0.3,2.5),cc.FadeOut:create(0.3)),
                cc.DelayTime:create(0.5),
                cc.CallFunc:create(function( )
                    -- animLab2:setScale(1)
                    -- animLab2:setOpacity(255)
                    countInNum = countInNum-1
                    if countInNum < 1 then
--                        audioMgr:stopAll()
                        if callback then
                            callback()
                        end
                        animLab2:stopAllActions()
                        return
                    end
                    animLab1:setString(" ")
                    animLab2:setString(" ")
--                    countMc:gotoAndPlay(0)
--                    countMc:addEndCallback(function (_, sender)
--                        sender:stop()
--                    end)
                end)
            )
        ))

end

-- 前往布阵
function HeroDuelForbiddenView:gotoFormation()
    -- 从后台回到前台，若本局已结束，将不进入布阵
    if self._hModel:gethDuelState() ~= nil and self._hModel:gethDuelState() < self._hModel.BATTLE_END then

        self:formationPrepare(function()
            self._viewMgr:showView("formation.NewFormationView", {
                formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel,
                filter = self._hModel:getForbiddenedCards(self._commonData.banned),
                extend = {
                    teams = self._hModel:getCardsInfo().teams,
                    heroes = self._hModel:getCardsInfo().heros,
                    heroDuelInfo = {offensivePosition = self._hModel:getRoomData()["self"].formFirst == 1}
                },
                callback = function() 
                    self:onBattle(false)
                end,
                closeCallback = function(result)
                    if not tolua.isnull(self) and not self._hasResult then
--                        print("*********************** formation")
                        self:onBattleResult()
                    end
                end
            })
        end)

    end
end

-- 前往战斗
-- @param isError 是否跳过布阵直接进入战斗
function HeroDuelForbiddenView:onBattle(isError)
    local battleInfo = self._hModel:getBattleBefore()
    self._token = battleInfo.token
    
    if isError ~= true then
        self._viewMgr:popView()
    end
    BattleUtils.enterBattleView_HeroDuel(BattleUtils.jsonData2lua_battleData(battleInfo["atk"]),
        BattleUtils.jsonData2lua_battleData(battleInfo["def"]), 
        battleInfo.r1,
        battleInfo.r2,
        0, 
        not self._hModel:isOffensiveOrder(),
        specialize(self.sendBattleEnd, self),
        specialize(self.onBattleQuit, self))
end

-- 向java服务器通知战后结果
function HeroDuelForbiddenView:sendBattleEnd(info, callback)
    if info.isSurrender then
        callback(info)
        return
    end

    self._battleCallBack = callback

    if not self._errorQuit then
        local args = {win = info.win and 1 or 0, 
                      skillList = info.skillList,
                      serverInfoEx = info.serverInfoEx,
                      time = info.time
                      }

        self._battleWin = info.win
        self:sendSocketMgs("battleEnd", {token = self._token, args = json.encode(args)})
    else
        self:onBattleResult()
    end
end

-- 向php服务器请求战后数据
function HeroDuelForbiddenView:onBattleResult()
    self._hasResult = true

    self._serverMgr:sendMsg("HeroDuelServer", "hDuelFightAfter", {}, true, {}, function(result)
        if result["extract"] then
            dump(result["extract"]["hp"], "a", 10)
        end

        dump(result)

        local hdData = {}
        if result.win == 1 then
            self._hModel:saveErrorType({isWin = 1})

            hdData["wins"] = result["d"].heroDuel.wins
            hdData["seasonWins"] = result["d"].heroDuel.seasonWins
            self._hModel:updateHeroDuelData(hdData)
        else
            self._hModel:saveErrorType({isWin = 0})

            hdData["loses"] = result["d"].heroDuel.loses
            self._hModel:updateHeroDuelData(hdData)
        end

        ServerManager:getInstance():RS_clear()

        if self._battleCallBack then
            result.win = self._battleWin
            self._battleCallBack(result, result.reward)
        end

        self:close()
    end)
end


function HeroDuelForbiddenView:onBattleQuit()


end

-- 发送协议
function HeroDuelForbiddenView:sendSocketMgs(name, params)
    ServerManager:getInstance():RS_sendMsg("PlayerProcessor", name, params or {})
end

-- java服务器的response或者push接受
function HeroDuelForbiddenView:onSocektResponse(data)
    if data.error ~= nil then
        return
    end

    local status = 0
    local result = nil
    if data.result and data.result["common"] then
        result = data.result
        status = result["common"].status
    end

    if status == self._hModel.BATTLE_END and not self._hasResult then
        if result["common"].quit == self._hModel.EXIT_NORMAL then
            self:onBattleResult()

        elseif result["common"].quit == self._hModel.EXIT_ERROR3 then
            self._errorQuit = true
        end
    end
end

---- 网络问题导致异常退出
--function HeroDuelForbiddenView:onErrorClose()
--    self:runAction(
--        cc.Sequence:create(
--        cc.DelayTime:create(0.2),
--        cc.CallFunc:create(function()
--            self._errorCallBack()
--            self:close()
--        end))
--    )
--end

-- 获取新被办卡牌ID
function HeroDuelForbiddenView:getNewBanned(allList, oldList)
    local newList = clone(allList)
    for i = 1, #oldList do
        for j = 1, #newList do
            if newList[j] == oldList[i] then
                table.remove(newList, j)
                break
            end
        end 
    end
    return newList
end

-- 判断是否有对应卡
function HeroDuelForbiddenView:hasCard(tId)
    for i = 1, #self._teamsData do
        if tostring(self._teamsData[i].id) == tostring(tId) then
            return true
        end
    end
    return false
end

-- 获取剩余倒计时时间（防止弱网问题）
function HeroDuelForbiddenView:getLeftTime(timestamp, time)
    local dT = self._modelMgr:getModel("UserModel"):getCurServerTime() - timestamp
    local leftTime = time - dT
    leftTime = math.min(leftTime, time)
    leftTime = math.max(leftTime, 0)
    return leftTime
end



function HeroDuelForbiddenView:applicationDidEnterBackground()
    self._isInBackGround = true
end

function HeroDuelForbiddenView:applicationWillEnterForeground(second)
    self._isInBackGround = false
end

function HeroDuelForbiddenView:onDestroy()
    self:closeCountDown()
    self._hModel:resethDuelState()

    HeroDuelForbiddenView.super.onDestroy(self)
end

function HeroDuelForbiddenView:dtor()
    CARD_WIDTH = nil
    CARD_HEIGHT = nil
    HeroDuelForbiddenView = nil
end
return HeroDuelForbiddenView